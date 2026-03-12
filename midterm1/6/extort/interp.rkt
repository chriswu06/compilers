#lang racket
(provide interp interp-e)
(require "ast.rkt")
(require "interp-prim.rkt")

;; type Value =
;; | Integer
;; | Boolean
;; | Character
;; | Eof
;; | Void

;; type Answer = Value | 'err

(define (err? x) (eq? x 'err))
;; Expr -> Answer
(define (interp e)
  (with-handlers ([err? identity])
    (interp-e e)))


;; Expr -> Value { raises 'err }
(define (interp-e e)
  (match e
    [(Lit d) d]
    [(Eof)   eof]
    [(Prim0 p)
     (interp-prim0 p)]
    [(Prim1 p e)
     (interp-prim1 p (interp-e e))]
    [(Begin e1 e2)
     (begin (interp-e e1)
            (interp-e e2))]
    [(Cond '() '() el) (interp-e el)]
    [(Cond (cons p ps) (cons b bs) el)
     (match (interp-e p)
       [#t (interp-e b)]
       [#f (interp-e (Cond ps bs el))]
       [_ (raise 'err)])]))
