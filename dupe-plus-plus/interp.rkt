#lang racket
(provide interp)
(require "ast.rkt")
(require "interp-prim.rkt")

;; type Value =
;; | Integer
;; | Boolean
;; Expr -> Value
(define (interp e)
  (match e
    [(Lit d) d]
    [(Prim1 p e)
     (interp-prim1 p (interp e))]
    [(If e1 e2 e3)
     (if (interp e1)
         (interp e2)
         (interp e3))]
    [(Cond eqs eas el)
     (define (helper conditions evaluated)
         (match conditions
            ['() (interp el)]
            [(cons x xs)
              (if (interp x)
                (interp (car evaluated))
                (helper xs (cdr evaluated)))]))
     (helper eqs eas)]
    [(Case e ds es el)
     (define switch (interp e))
     (define (helper datums evaluated)
        (match datums
            ['() (interp el)]
            [(cons x xs)
              (if (member switch x)
                (interp (car evaluated))
                (helper xs (cdr evaluated)))]))
     (helper ds es)]))

