#lang racket
(provide interp interp-e)
(require "ast.rkt")
(require "interp-prim.rkt")
(require "env.rkt")

;; type Value =
;; | Integer
;; | Boolean
;; | Character
;; | Eof
;; | Void

;; type Answer = Value | 'err

;; type Env = (Listof (List Id Value))

(define (err? x) (eq? x 'err))
;; ClosedExpr -> Answer
(define (interp e)
  (with-handlers ([err? identity])
    (interp-e e '())))
;; Expr Env -> Value { raises 'err }
(define (interp-e e r) ;; where r closes e
  (match e
    [(Var x) (lookup r x)]
    [(Lit d) d]
    [(Eof)   eof]
    [(Prim0 p)
     (interp-prim0 p)]
    [(Prim1 p e)
     (interp-prim1 p (interp-e e r))]
    [(Prim2 p e1 e2)
     (interp-prim2 p
                   (interp-e e1 r)
                   (interp-e e2 r))]
    [(If e1 e2 e3)
     (if (interp-e e1 r)
         (interp-e e2 r)
         (interp-e e3 r))]
    [(Begin e1 e2)
     (begin (interp-e e1 r)
            (interp-e e2 r))]


    
    ;;Edits
    [(Cond eqs eas el)
     (define (helper conditions evaluated)
         (match conditions
            ['() (interp-e el r)]
            [(cons x xs)
              (if (interp-e x r)
                (interp-e (car evaluated) r)
                (helper xs (cdr evaluated)))]))
     (helper eqs eas)]
    [(Case e ds es el)
     (define switch (interp-e e r))
     (define (helper datums evaluated)
        (match datums
            ['() (interp-e el r)]
            [(cons x xs)
              (if (member switch x)
                (interp-e (car evaluated) r)
                (helper xs (cdr evaluated)))]))
     (helper ds es)]
    [(Let xs es e2)
     (let ((vs (map (lambda (e) (interp-e e r)) es)))
        (define (extend-env r xs vs)
          (match (list xs vs)
            [(list '() '()) r]
            [(list (cons x xs) (cons v vs))
              (extend-env (ext r x v) xs vs)]))
        (interp-e e2 (extend-env r xs vs)))]
    [(Let* xs es e2)
      (define (extend-env r xs es)
        (match (list xs es)
          [(list '() '()) r]
          [(list (cons x xs) (cons e es))
            (extend-env (ext r x (interp-e e r)) xs es)]))
      (interp-e e2 (extend-env r xs es))]))
    ;;Edits