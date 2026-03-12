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
        (Ret)
        ;; Error handler
        (Label 'err)
        (Extern 'raise_error)
        (Call 'raise_error)))

;; Expr -> Asm
(define (compile-e e)
  (match e
    [(Lit d) (compile-datum d)]
    [(Eof) (seq (Mov rax (value->bits eof)))]
    [(Prim0 p) (compile-prim0 p)]
    [(Prim1 p e) (compile-prim1 p e)]
    [(Begin e1 e2) (compile-begin e1 e2)]
    [(Cond ps bs el) (compile-cond ps bs el)]))

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

;; Expr Expr -> Asm
(define (compile-begin e1 e2)
  (seq (compile-e e1)
       (compile-e e2)))

;; [Listof Expr] [Listof Expr] Expr -> Asm
(define (compile-cond ps bs el)
  (define done (gensym 'cond))
  (let loop ([ps ps]
             [bs bs])
    (match* (ps bs)
      [('() '()) (seq (compile-e el)
                      (Label done))]
      [((cons p ps) (cons b bs))
       (let ([next (gensym 'cond)]
             [proceed (gensym 'cond)])
         (seq (compile-e p)
              (Mov r9 rax)
              (Cmp r9 (value->bits #t))
              (Je proceed)
              (Cmp r9 (value->bits #f))
              (Je proceed)
              (Jmp 'err)
              (Label proceed)
              (Cmp rax (value->bits #f))
              (Je next)
              (compile-e b)
              (Jmp done)
              (Label next)
              (loop ps bs)))])))
