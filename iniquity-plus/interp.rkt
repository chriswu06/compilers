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
;; | '()
;; | (cons Value Value)
;; | (box Value)
;; | (string Character ...)
;; | (vector Value ...)

;; type Answer = Value | 'err

;; type Env = (Listof (List Id Value))

(define (err? x) (eq? x 'err))
;; ClosedExpr -> Answer
;; Prog -> Answer
(define (interp p)
  (with-handlers ([err? identity])
    (match p
      [(Prog ds e)
       (interp-e e '() ds)])))
;l Expr Env Defns -> Value { raises 'err }
(define (interp-e e r ds) ;; where r closes e
  (match e
    [(Var x) (lookup r x)]
    [(Lit d) d]
    [(Eof)   eof]
    [(Prim0 p)
     (interp-prim0 p)]
    [(Prim1 p e)
     (interp-prim1 p (interp-e e r ds))]
    [(Prim2 p e1 e2)
     (interp-prim2 p
                   (interp-e e1 r ds)
                   (interp-e e2 r ds))]
    [(Prim3 p e1 e2 e3)
     (interp-prim3 p
                   (interp-e e1 r ds)
                   (interp-e e2 r ds)
                   (interp-e e3 r ds))]
    [(If e1 e2 e3)
     (if (interp-e e1 r ds)
         (interp-e e2 r ds)
         (interp-e e3 r ds))]
    [(Begin e1 e2)
     (begin (interp-e e1 r ds)
            (interp-e e2 r ds))]
    [(Let x e1 e2)
     (let ((v (interp-e e1 r ds)))
       (interp-e e2 (ext r x v) ds))]
    [(App f es)
     (let ((vs (interp-e* es r ds)))
        (match (defns-lookup ds f)
          [(Defn _ fun)
           (apply-fun fun vs ds)]))]))

;; (Listof Expr) REnv Defns -> (Listof Value) { raises 'err }
(define (interp-e* es r ds)
  (match es
    ['() '()]
    [(cons e es)
     (cons (interp-e e r ds)
           (interp-e* es r ds))]))

;; Fun [Listof Values] Defns -> Value { raises 'err }
(define (apply-fun f vs ds)
  (match f
    [(FunPlain xs e)
     ; check arity matches-arity-exactly?
     (if (= (length xs) (length vs))
         (interp-e e (zip xs vs) ds)
         (raise 'err))]
    [(FunRest xs x e)
     ; check arity is acceptable
     (if (< (length vs) (length xs))
         (raise 'err)
         (interp-e e
                   (zip (cons x xs)
                        (cons (drop vs (length xs))
                              (take vs (length xs))))
                   ds))]
    [(FunCase cs)
     (apply-fun (select-case-lambda cs (length vs)) vs ds)]))

;; [Listof FunCaseClause] Nat -> Fun { raises 'err }
(define (select-case-lambda cs n)
  (match cs
    ['() (raise 'err)]
    [(cons (and (FunPlain xs e) f) cs)
     (if (= (length xs) n)
         f
         (select-case-lambda cs n))]
    [(cons (and (FunRest xs x e) f) cs)
     (if (<= (length xs) n)
         f
         (select-case-lambda cs n))]))

;; Defns Symbol -> Defn
(define (defns-lookup ds f)
  (findf (match-lambda [(Defn g _) (eq? f g)])
         ds))

(define (zip xs ys)
  (match* (xs ys)
    [('() '()) '()]
    [((cons x xs) (cons y ys))
     (cons (list x y)
           (zip xs ys))]))

