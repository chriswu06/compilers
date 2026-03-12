#lang racket
(provide compile
         compile-e)

(require "ast.rkt")
(require "compile-ops.rkt")
(require "types.rkt")
(require a86/ast a86/registers)

;; Expr -> Asm
(define (compile e)
  (prog (Global 'entry)
        (Label 'entry)
        (Sub rsp 8)
        (compile-e e)
        (Add rsp 8)
        (Ret)))

;; Expr -> Asm
(define (compile-e e)
  (match e
    [(Lit d) (compile-datum d)]
    [(Eof) (seq (Mov rax (value->bits eof)))]
    [(Prim0 p) (compile-prim0 p)]
    [(Prim1 p e) (compile-prim1 p e)]
    [(If e1 e2 e3) (compile-if e1 e2 e3)]
    [(Begin '() ef) (compile-e ef)]
    [(Begin (cons e1 es) ef) (compile-begin e1 (Begin es ef))]
    [(Begin0 e1 es) (compile-begin0 e1 es)]))

;; Datum -> Asm
(define (compile-datum d)
  (seq (Mov rax (value->bits d))))

;; Op0 -> Asm
(define (compile-prim0 p)
  (compile-op0 p))

;; Op1 Expr -> Asm
(define (compile-prim1 p e)
  (seq (compile-e e)
       (compile-op1 p)))

;; Expr Expr Expr -> Asm
(define (compile-if e1 e2 e3)
  (let ((l1 (gensym 'if))
        (l2 (gensym 'if)))
    (seq (compile-e e1)
         (Cmp rax (value->bits #f))
         (Je l1)
         (compile-e e2)
         (Jmp l2)
         (Label l1)
         (compile-e e3)
         (Label l2))))

;; Expr Expr -> Asm
(define (compile-begin e1 e2)
  (seq (compile-e e1)
       (compile-e e2)))

;; Expr [Listof Expr] -> Asm
(define (compile-begin0 e1 es)
  (seq (compile-e e1)
       (Push rax)
       (compile-begin0-helper es)
       (Pop rax)))

(define (compile-begin0-helper es)
  (match es
    ['() (seq)]
    [(cons es-first es-rest)
      (seq (compile-e es-first)
           (compile-begin0-helper es-rest))]))
