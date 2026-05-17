#lang racket
(provide compile
         compile-e
         compile-es
         compile-define
         compile-match
         compile-match-clause
         compile-lambda-define
         copy-env-to-stack
         free-vars-to-heap)

(require "ast.rkt")
(require "compile-ops.rkt")
(require "types.rkt")
(require "lambdas.rkt")
(require "fv.rkt")
(require a86/ast a86/registers)

;; Prog -> Asm
(define (compile p)
  (match p
    [(Prog ds e)
     (prog (Global 'entry)
           (Label 'entry)
           (Push rbx)    ; save callee-saved register
           (Push r15)
           (Mov rbx rdi) ; recv heap pointer
           (Mov r12 0)
           (compile-defines-values ds)
           (compile-e e (reverse (define-ids ds)) #f)
           (Add rsp (* 8 (length ds))) ;; pop function definitions
           (Pop r15)     ; restore callee-save register
           (Pop rbx)
           (Ret)
           (compile-defines ds)
           (compile-lambda-defines (lambdas p))
           (Label 'err)
           pad-stack
           (Extern 'raise_error)
           (Call 'raise_error)
           (Data)
           (Label 'empty)
           (Dq 0))]))

;; [Listof Defn] -> [Listof Id]
(define (define-ids ds)
  (match ds
    ['() '()]
    [(cons (Defn f xs e) ds)
     (cons f (define-ids ds))]))

;; [Listof Defn] -> Asm
(define (compile-defines ds)
  (match ds
    ['() (seq)]
    [(cons d ds)
     (seq (compile-define d)
          (compile-defines ds))]))

;; Defn -> Asm
(define (compile-define d)
  (match d
    [(Defn f xs e)
     (compile-lambda-define (Lam f xs e))]))

;; [Listof Lam] -> Asm
(define (compile-lambda-defines ls)
  (match ls
    ['() (seq)]
    [(cons l ls)
     (seq (compile-lambda-define l)
          (compile-lambda-defines ls))]))

;; Lam -> Asm
(define (compile-lambda-define l)
  (let ((fvs (fv l)))
    (match l
      [(Lam f xs e)
       (let ((env  (append (reverse fvs) (reverse xs) (list #f))))
         (seq (Label (symbol->label f))
              (Cmp r8 (length xs))
              (Jne 'err)
              (Mov rax (Mem rsp (* 8 (length xs))))
              (copy-env-to-stack fvs 8)
              (compile-e e env #t)
              (Add rsp (* 8 (length env))) ; pop env
              (Ret)))])))

;; [Listof Id] Int -> Asm
;; Copy the closure environment at given offset to stack
(define (copy-env-to-stack fvs off)
  (match fvs
    ['() (seq)]
    [(cons _ fvs)
     (seq (Mov r9 (Mem rax (- off type-proc)))
          (Push r9)
          (copy-env-to-stack fvs (+ 8 off)))]))

;; type CEnv = (Listof [Maybe Id])
;; Expr CEnv Boolean -> Asm
(define (compile-e e c t?)
  (match e
    [(Lit d) (compile-datum d)]
    [(Eof) (seq (Mov rax (value->bits eof)))]
    [(Var x) (compile-variable x c)]
    [(Prim0 p) (compile-prim0 p)]
    [(Prim1 p e) (compile-prim1 p e c)]
    [(Prim2 p e1 e2) (compile-prim2 p e1 e2 c)]
    [(Prim3 p e1 e2 e3) (compile-prim3 p e1 e2 e3 c)]
    [(If e1 e2 e3) (compile-if e1 e2 e3 c t?)]
    [(Begin e1 e2) (compile-begin e1 e2 c t?)]
    [(Let x e1 e2) (compile-let x e1 e2 c t?)]
    [(App e es)
     (compile-app e es c t?)]
    [(Lam f xs e)
     (compile-lam f xs e c)]
    [(Match e ps es) (compile-match e ps es c t?)]
    [(Raise e) (compile-raise e c)]
    [(WithHandler e1 e2 e) (compile-with-handler e1 e2 e c)]))


;; Expr CEnv -> Asm
(define (compile-raise e c)
  (let ((predicate-applied (gensym 'predicate-applied))
        (handler-applied (gensym 'handler-applied))
        (apply-handler (gensym 'apply-handler))
        (raise-loop (gensym 'raise-loop)))
    (seq (compile-e e c #f)
         ;At the start of loop, rax = value raised, r12 = handler
         ;After pushing raised value onto stack, working layout (rsp):
         ; [rsp+0] = raised value (pushed here so it survives internal raises in predicate/handler)
         ; [rsp+8] = old r12 (parent handler pointer)
         ; [rsp+16] = outside address/label that tells us where to go after done applying handle (both the predicate & function)
         ; [rsp+24] = function pointer
         ; [rsp+32] = predicate pointer
         (Label (symbol->label raise-loop))

         ;If there is no exception handler installed/written, error
         (Cmp r12 0)
         (Je 'err)

         ;Assigning registers and clearing stack of unneeded computations
         (Mov rsp r12) ;Removing stack computations between rsp and the handler (computation leading to raise)
         (Push rax) ;Saving raised value to stack so it survives internal raises inside the predicate or handler (which would clobber any register we stored it in)
         (Mov r12 (Mem rsp 8)) ;Setting r12 back to the old handler pointer (by dereferencing stack) while the current handler handles this exception (for next time)

         ;Applying predicate to the raised value
         (Mov r9 (Mem rsp 32)) ;Setting r9 to the handler predicate pointer (by dereferencing stack)
         ;Calling convention requires these values on stack
         (Lea rax (symbol->label predicate-applied))
         (Push rax) ;Firstly pushing the return address so that after the predicate is applied we can jump back here after
         (Push r9) ;Secondly pushing the predicate pointer
         (Mov rax (Mem rsp 16)) ;Loading saved raised value from stack (now at offset 16 after pushing return address and predicate pointer above it)
         (Push rax) ;Lastly pushing the raised value as the argument
         ;Calling predicate w/ raised value
         (Mov rax r9) ;Moving predicate pointer to rax to check for procedure (assert-proc only works on rax)
         (assert-proc rax) ;Checking that the predicate is actually a procedure
         (Mov rax (Mem rax (- type-proc))) ;Dereferencing predicate pointer after removing its type-proc tag (by subtracting type-proc tag), storing address of raw predicate in rax
         (Mov r8 1) ;Indicating that we're passing one argument
         (Jmp rax) ;Jumping into the predicate application instructions with argument, predicate pointer, and where to return
         (Label (symbol->label predicate-applied)) ;Return address for after applying the predicate; we jump back here
         ;rax = predicate(raised value) result, rsp = saved raised value slot again

         ;If predicate(raised value) = false, then value is raised to next (outside) exception handler
         (Cmp rax (value->bits #f))
         (Jne (symbol->label apply-handler)) ;If truthy, jump to apply handler
         (Mov rax (Mem rsp 0)) ;Setting rax = raised value (from stack) for next (outside) handler, r12 is already set as next (outside) handler
         (Jmp (symbol->label raise-loop)) ;Try next handler for this exception

         ;Predicate(raised value) truthy case
         (Label (symbol->label apply-handler))
         (Mov r9 (Mem rsp 24)) ;Setting r9 to the handler function pointer (by dereferencing stack)
         ;Same calling convention as the predicate calling convention with the same raised value argument
         (Lea rax (symbol->label handler-applied))
         (Push rax)
         (Push r9)
         (Mov rax (Mem rsp 16)) 
         (Push rax)
         (Mov rax r9)
         (assert-proc rax)
         (Mov rax (Mem rax (- type-proc)))
         (Mov r8 1)
         (Jmp rax)
         (Label (symbol->label handler-applied))

         ;Seeing where to go after applying the predicate & function in the handler to the raised value
         (Mov r9 (Mem rsp 16)) ;Setting r9 to the "where to go after handling w/ predicate & function w/ the raised value?" address (by dereferencing stack)
         (Add rsp 40) ;Popping the saved raised value slot and the handler frame
         (Jmp r9) ;Jump to where to go after applying everything from the handler
         )))

;; Expr Expr Expr CEnv -> Asm
(define (compile-with-handler e1 e2 e c)
  (let ((after-handling (gensym 'after-handling)))
    (seq ;r12 currently has the old parent handler pointer
         ;Constructing new handler frame (new r12):
         ; [rsp+0] = old r12 (parent handler pointer)
         ; [rsp+8] = outside address/label that tells us where to go after done applying handle (both the predicate & function)
         ; [rsp+16] = function pointer
         ; [rsp+24] = predicate pointer
         (compile-e e1 c #f)
         (Push rax) ;Push the handler predicate pointer first
         (compile-e e2 (cons #f c) #f)
         (Push rax) ;Push the handler function pointer second
         (Lea rax (symbol->label after-handling))
         (Push rax) ;Push address of where to go after handling (end of this function)
         (Push r12) ;Pushing old parent handler pointer
         (Mov r12 rsp) ;Setting r12 to the top of the stack - top of stack is our handler stack frame (Installing the handler to r12)

         ;Compile e with four extra #f slots in cenv to account for our four-slot handler stack frame
         (compile-e e (cons #f (cons #f (cons #f (cons #f c)))) #f) ;When compiling the expression e, sometimes this calls compile-raise to handle an exception - which jumps to last line in this function
         
         ;Normal return, no exception/raised value to handle
         (Mov r12 (Mem rsp 0)) ;;Setting r12 back to the old/outside handler pointer (by dereferencing stack) since the current handler wasn't used (unneeded, body ran out)
         (Add rsp 32) ;Popping the handler stack frame we just put onto the stack
         (Label (symbol->label after-handling))))) ;Where to go after handling everything (useful if exception raised/handler was used)

;; Datum -> Asm
(define (compile-datum d)
  (cond [(string? d) (compile-string d)]
        [else (seq (Mov rax (value->bits d)))]))

;; String -> Asm
(define (compile-string s)
  (let ((l (gensym 'string))
        (n (string-length s)))
    (match s
      ["" (seq (Lea rax (Mem 'empty type-str)))]
      [_
       (seq (Data)
            (Label l)
            (Dq (value->bits n))
            (compile-string-chars (string->list s))
            (if (odd? n) (Dd 0) (seq))
            (Text)
            (Lea rax (Mem l type-str)))])))

;; [Listof Char] -> Asm
(define (compile-string-chars cs)
  (match cs
    ['() (seq)]
    [(cons c cs)
     (seq (Dd (char->integer c))
          (compile-string-chars cs))]))


;; Id CEnv -> Asm
(define (compile-variable x c)
  (let ((i (lookup x c)))
    (seq (Mov rax (Mem rsp i)))))

;; Op0 -> Asm
(define (compile-prim0 p)
  (compile-op0 p))

(define (compile-prim1 p e c)
  (seq (compile-e e c #f)
       (compile-op1 p)))

;; Op2 Expr Expr CEnv -> Asm
(define (compile-prim2 p e1 e2 c)
  (seq (compile-e e1 c #f)
       (Push rax)
       (compile-e e2 (cons #f c) #f)
       (compile-op2 p)))

;; Op3 Expr Expr Expr CEnv -> Asm
(define (compile-prim3 p e1 e2 e3 c)
  (seq (compile-e e1 c #f)
       (Push rax)
       (compile-e e2 (cons #f c) #f)
       (Push rax)
       (compile-e e3 (cons #f (cons #f c)) #f)
       (compile-op3 p)))
;; Expr Expr Expr CEnv Boolean -> Asm
(define (compile-if e1 e2 e3 c t?)
  (let ((l1 (gensym 'if))
        (l2 (gensym 'if)))
    (seq (compile-e e1 c #f)
         (Cmp rax (value->bits #f))
         (Je l1)
         (compile-e e2 c t?)
         (Jmp l2)
         (Label l1)
         (compile-e e3 c t?)
         (Label l2))))
;; Expr Expr CEnv Boolean -> Asm
(define (compile-begin e1 e2 c t?)
  (seq (compile-e e1 c #f)
       (compile-e e2 c t?)))
;; Id Expr Expr CEnv Boolean -> Asm
(define (compile-let x e1 e2 c t?)
  (seq (compile-e e1 c #f)
       (Push rax)
       (compile-e e2 (cons x c) t?)
       (Add rsp 8)))

;; Id [Listof Expr] CEnv -> Asm
;; The return address is placed above the arguments, so callee pops
;; arguments and return address is next frame
;; Expr [Listof Expr] CEnv Boolean -> Asm
(define (compile-app e es c t?)
  (if t?
      (compile-app-tail e es c)
      (compile-app-nontail e es c)))

;; Expr [Listof Expr] CEnv -> Asm
(define (compile-app-tail e es c)
  (seq (compile-es (cons e es) c)
       (move-args (add1 (length es)) (length c))
       (Add rsp (* 8 (length c)))
       (Mov rax (Mem rsp (* 8 (length es))))
       (assert-proc rax)
       (Mov rax (Mem rax (- type-proc)))
       (Mov r8 (length es)) ; pass arity info
       (Jmp rax)))

;; Integer Integer -> Asm
(define (move-args i off)
  (cond [(zero? off) (seq)]
        [(zero? i)   (seq)]
        [else
         (seq (Mov r8 (Mem rsp (* 8 (sub1 i))))
              (Mov (Mem rsp (* 8 (+ off (sub1 i)))) r8)
              (move-args (sub1 i) off))]))

;; Expr [Listof Expr] CEnv -> Asm
;; The return address is placed above the arguments, so callee pops
;; arguments and return address is next frame
(define (compile-app-nontail e es c)
  (let ((r (gensym 'ret))
        (i (* 8 (length es))))
    (seq (Lea rax r)
         (Push rax)
         (compile-es (cons e es) (cons #f c))
         (Mov rax (Mem rsp i))
         (assert-proc rax)
         (Mov rax (Mem rax (- type-proc))) ; fetch the code label
         (Mov r8 (length es)) ; pass arity info
         (Jmp rax)
         (Label r))))

;; Defns -> Asm
;; Compile the closures for ds and push them on the stack
(define (compile-defines-values ds)
  (seq (alloc-defines ds 0)
       (init-defines ds (reverse (define-ids ds)) 8)
       (add-rbx-defines ds 0)))

;; Defns Int -> Asm
;; Allocate closures for ds at given offset, but don't write environment yet
(define (alloc-defines ds off)
  (match ds
    ['() (seq)]
    [(cons (Defn f xs e) ds)
     (let ((fvs (fv (Lam f xs e))))
       (seq (Lea rax (symbol->label f))
            (Mov (Mem rbx off) rax)
            (Mov rax rbx)
            (Add rax off)
            (Xor rax type-proc)
            (Push rax)
            (alloc-defines ds (+ off (* 8 (add1 (length fvs)))))))]))

;; Defns CEnv Int -> Asm
;; Initialize the environment for each closure for ds at given offset
(define (init-defines ds c off)
  (match ds
    ['() (seq)]
    [(cons (Defn f xs e) ds)
     (let ((fvs (fv (Lam f xs e))))
       (seq (free-vars-to-heap fvs c off)
            (init-defines ds c (+ off (* 8 (add1 (length fvs)))))))]))

;; Defns Int -> Asm
;; Compute adjustment to rbx for allocation of all ds
(define (add-rbx-defines ds n)
  (match ds
    ['() (seq (Add rbx (* n 8)))]
    [(cons (Defn f xs e) ds)
     (add-rbx-defines ds (+ n (add1 (length (fv (Lam f xs e))))))]))

;; Id [Listof Id] Expr CEnv -> Asm
(define (compile-lam f xs e c)
  (let ((fvs (fv (Lam f xs e))))
    (seq (Lea rax (symbol->label f))
         (Mov (Mem rbx) rax)
         (free-vars-to-heap fvs c 8)
         (Mov rax rbx) ; return value
         (Xor rax type-proc)
         (Add rbx (* 8 (add1 (length fvs)))))))

;; [Listof Id] CEnv Int -> Asm
;; Copy the values of given free variables into the heap at given offset
(define (free-vars-to-heap fvs c off)
  (match fvs
    ['() (seq)]
    [(cons x fvs)
     (seq (Mov r8 (Mem rsp (lookup x c)))
          (Mov (Mem rbx off) r8)
          (free-vars-to-heap fvs c (+ off 8)))]))

;; [Listof Expr] CEnv -> Asm
(define (compile-es es c)
  (match es
    ['() '()]
    [(cons e es)
     (seq (compile-e e c #f)
          (Push rax)
          (compile-es es (cons #f c)))]))

;; Expr [Listof Pat] [Listof Expr] CEnv Bool -> Asm
(define (compile-match e ps es c t?)
  (let ((done (gensym)))
    (seq (compile-e e c #f)
         (Push rax) ; save away to be restored by each clause
         (compile-match-clauses ps es (cons #f c) done t?)
         (Jmp 'err)
         (Label done)
         (Add rsp 8)))) ; pop the saved value being matched

;; [Listof Pat] [Listof Expr] CEnv Symbol Bool -> Asm
(define (compile-match-clauses ps es c done t?)
  (match* (ps es)
    [('() '()) (seq)]
    [((cons p ps) (cons e es))
     (seq (compile-match-clause p e c done t?)
          (compile-match-clauses ps es c done t?))]))

;; Pat Expr CEnv Symbol Bool -> Asm
(define (compile-match-clause p e c done t?)
  (let ((next (gensym)))
    (match (compile-pattern p '() next)
      [(list i cm)
       (seq (Mov rax (Mem rsp)) ; restore value being matched
            i
            (compile-e e (append cm c) t?)
            (Add rsp (* 8 (length cm)))
            (Jmp done)
            (Label next))])))

;; Pat CEnv Symbol -> (list Asm CEnv)
(define (compile-pattern p cm next)
  (match p
    [(Var '_)
     (list (seq) cm)]
    [(Var x)
     (list (seq (Push rax)) (cons x cm))]
    [(Lit l)
     (let ((ok (gensym)))
       (list (seq (Mov r8 rax)
                  (compile-datum l)
                  (Cmp rax r8)
                  (Je ok)
                  (Add rsp (* 8 (length cm)))
                  (Jmp next)
                  (Label ok))
             cm))]
    [(Conj p1 p2)
     (match (compile-pattern p1 (cons #f cm) next)
       [(list i1 cm1)
        (match (compile-pattern p2 cm1 next)
          [(list i2 cm2)
           (list
            (seq (Push rax)
                 i1
                 (Mov rax (Mem rsp (* 8 (- (sub1 (length cm1)) (length cm)))))
                 i2)
            cm2)])])]
    [(Box p)
     (match (compile-pattern p cm next)
       [(list i1 cm1)
        (let ((ok (gensym)))
          (list
           (seq (Mov r8 rax)
                (And r8 ptr-mask)
                (Cmp r8 type-box)
                (Je ok)
                (Add rsp (* 8 (length cm))) ; haven't pushed anything yet
                (Jmp next)
                (Label ok)
                (Mov rax (Mem rax (- type-box)))
                i1)
           cm1))])]
    [(Cons p1 p2)
     (match (compile-pattern p1 (cons #f cm) next)
       [(list i1 cm1)
        (match (compile-pattern p2 cm1 next)
          [(list i2 cm2)
           (let ((ok (gensym)))
             (list
              (seq (Mov r8 rax)
                   (And r8 ptr-mask)
                   (Cmp r8 type-cons)
                   (Je ok)
                   (Add rsp (* 8 (length cm))) ; haven't pushed anything yet
                   (Jmp next)
                   (Label ok)
                   (Xor rax type-cons)
                   (Mov r8 (Mem rax 8))
                   (Push r8)                ; push cdr
                   (Mov rax (Mem rax 0))    ; mov rax car
                   i1
                   (Mov rax (Mem rsp (* 8 (- (sub1 (length cm1)) (length cm)))))
                   i2)
              cm2))])])]))

;; Id CEnv -> Integer
(define (lookup x cenv)
  (match cenv
    ['() (error "undefined variable:" x)]
    [(cons y rest)
     (match (eq? x y)
       [#t 0]
       [#f (+ 8 (lookup x rest))])]))

