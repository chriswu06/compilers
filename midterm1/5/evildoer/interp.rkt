#lang racket
(provide interp)
(require "ast.rkt")
(require "interp-prim.rkt")

;; type Value =
;; | Integer
;; | Boolean
;; | Character
;; | Eof
;; | Void
;; Expr -> Value
(define (interp e)
  (match e
    [(Lit d) d]
    [(Eof)   eof]
    [(Prim0 p)
     (interp-prim0 p)]
    [(Prim1 p e)
     (interp-prim1 p (interp e))]
    [(If e1 e2 e3)
     (if (interp e1)
         (interp e2)
         (interp e3))]
    [(Begin '() ef)
     (interp ef)]
    [(Begin (cons e1 es) ef)
     (begin (interp e1)
            (interp (Begin es ef)))]
    [(Begin0 e1 es)
     (interp-begin0 (interp e1) es)]))

(define (interp-begin0 v es)
  (match es
    ['() v]
    [(cons e es)
     (begin (interp e)
            (interp-begin0 v es))]))
