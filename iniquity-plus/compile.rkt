#lang racket
(provide compile
         compile-e
         compile-es
         compile-define)

(require "ast.rkt")
(require "compile-ops.rkt")
(require "types.rkt")
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

           (compile-e e '())
           (Pop r15)     ; restore callee-save register
           (Pop rbx)
           (Ret)
           (compile-defines ds)
           (Label 'err)
           pad-stack
           (Extern 'raise_error)
           (Call 'raise_error)
           (Data)
           (Label 'empty)
           (Dq 0))]))

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
    [(Defn f fun)
     (compile-fun f fun)]))

;; Id Fun -> Asm
(define (compile-fun f fun)
  (match fun
    [(FunPlain xs e)
     (seq (Label (symbol->label f))
          (Cmp r8 (length xs))
          (Jne 'err)
          (compile-e e (reverse xs))
          (Add rsp (* 8 (length xs)))
          (Ret))]
    [(FunRest xs x e)
     (let ((loop (gensym 'loop))
           (done (gensym 'done)))
        (seq (Label (symbol->label f))
             (Cmp r8 (length xs))
             (Jl 'err)
             (Mov rax (value->bits '()))
             (Mov rcx r8)
             (Sub rcx (length xs))
             (Label loop)
             (Cmp rcx 0)
             (Je done)
             (Mov r9 (Mem rsp 0))
             (Add rsp 8)
             (Mov (Mem rbx 0) r9)
             (Mov (Mem rbx 8) rax)
             (Mov rax rbx)
             (Or rax type-cons)
             (Add rbx 16)
             (Sub rcx 1)
             (Jmp loop)
             (Label done)
             (Push rax)
             (compile-e e (cons x (reverse xs)))
             (Add rsp (* 8 (add1 (length xs))))
             (Ret)))]
    [(FunCase cs)
     (let ((labels (map (lambda (_) (gensym 'clause)) cs)))
        (seq (Label (symbol->label f))
             (apply seq
                (map (lambda (c label)
                  (match c
                    [(FunPlain xs _)
                     (seq (Cmp r8 (length xs))
                          (Je label))]
                    [(FunRest xs _ _)
                     (seq (Cmp r8 (length xs))
                          (Jge label))]))
                cs labels))
             (Jmp 'err)
             (apply seq
                (map (lambda (c label)
                  (match c
                    [(FunPlain xs e)
                     (seq (Label label)
                          (compile-e e (reverse xs))
                          (Add rsp (* 8 (length xs)))
                          (Ret))]
                    [(FunRest xs x e)
                     (let ((loop (gensym 'loop))
                           (done (gensym 'done)))
                        (seq (Label label)
                             (Mov rax (value->bits '()))
                             (Mov rcx r8)
                             (Sub rcx (length xs))
                             (Label loop)
                             (Cmp rcx 0)
                             (Je done)
                             (Mov r9 (Mem rsp 0))
                             (Add rsp 8)
                             (Mov (Mem rbx 0) r9)
                             (Mov (Mem rbx 8) rax)
                             (Mov rax rbx)
                             (Or rax type-cons)
                             (Add rbx 16)
                             (Sub rcx 1)
                             (Jmp loop)
                             (Label done)
                             (Push rax)
                             (compile-e e (cons x (reverse xs)))
                             (Add rsp (* 8 (add1 (length xs))))
                             (Ret)))]))
                cs labels))))]))

;; type CEnv = (Listof [Maybe Id])
;; Expr CEnv -> Asm
(define (compile-e e c)
  (match e
    [(Lit d) (compile-datum d)]
    [(Eof) (seq (Mov rax (value->bits eof)))]
    [(Var x) (compile-variable x c)]
    [(Prim0 p) (compile-prim0 p)]
    [(Prim1 p e) (compile-prim1 p e c)]
    [(Prim2 p e1 e2) (compile-prim2 p e1 e2 c)]
    [(Prim3 p e1 e2 e3) (compile-prim3 p e1 e2 e3 c)]
    [(If e1 e2 e3) (compile-if e1 e2 e3 c)]
    [(Begin e1 e2) (compile-begin e1 e2 c)]
    [(Let x e1 e2) (compile-let x e1 e2 c)]
    [(App f es) (compile-app f es c)]))

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

;; Op1 Expr CEnv -> Asm
(define (compile-prim1 p e c)
  (seq (compile-e e c)
       (compile-op1 p)))

;; Op2 Expr Expr CEnv -> Asm
(define (compile-prim2 p e1 e2 c)
  (seq (compile-e e1 c)
       (Push rax)
       (compile-e e2 (cons #f c))
       (compile-op2 p)))

;; Op3 Expr Expr Expr CEnv -> Asm
(define (compile-prim3 p e1 e2 e3 c)
  (seq (compile-e e1 c)
       (Push rax)
       (compile-e e2 (cons #f c))
       (Push rax)
       (compile-e e3 (cons #f (cons #f c)))
       (compile-op3 p)))
;; Expr Expr Expr CEnv -> Asm
(define (compile-if e1 e2 e3 c)
  (let ((l1 (gensym 'if))
        (l2 (gensym 'if)))
    (seq (compile-e e1 c)
         (Cmp rax (value->bits #f))
         (Je l1)
         (compile-e e2 c)
         (Jmp l2)
         (Label l1)
         (compile-e e3 c)
         (Label l2))))
;; Expr Expr CEnv -> Asm
(define (compile-begin e1 e2 c)
  (seq (compile-e e1 c)
       (compile-e e2 c)))

;; Id Expr Expr CEnv -> Asm
(define (compile-let x e1 e2 c)
  (seq (compile-e e1 c)
       (Push rax)
       (compile-e e2 (cons x c))
       (Add rsp 8)))

;; Id [Listof Expr] CEnv -> Asm
;; The return address is placed above the arguments, so callee pops
;; arguments and return address is next frame
(define (compile-app f es c)
  (let ((r (gensym 'ret)))
    (seq (Lea rax r)
         (Push rax)
         (compile-es es (cons #f c))
         (Mov r8 (length es)) ; pass arity info
         (Jmp (symbol->label f))
         (Label r))))

;; [Listof Expr] CEnv -> Asm
(define (compile-es es c)
  (match es
    ['() '()]
    [(cons e es)
     (seq (compile-e e c)
          (Push rax)
          (compile-es es (cons #f c)))]))

;; Id CEnv -> Integer
(define (lookup x cenv)
  (match cenv
    ['() (error "undefined variable:" x)]
    [(cons y rest)
     (match (eq? x y)
       [#t 0]
       [#f (+ 8 (lookup x rest))])]))

