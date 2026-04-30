#lang racket
(provide interp interp-e)
(provide interp-match-pat)
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
    [(PrimN pN es)
     (interp-primN pN (interp-e* es r ds))]
    [(App f es)
     (let ((vs (interp-e* es r ds)))
        (match (defns-lookup ds f)
          [(Defn f xs e)
           ; check arity matches
           (if (= (length xs) (length vs))
               (interp-e e (zip xs vs) ds)
               (raise 'err))]))]
    [(Match e ps es)
     (let ((v (interp-e e r ds)))
       (interp-match v ps es r ds))]))

;; (Listof Expr) REnv Defns -> (Listof Value) { raises 'err }
(define (interp-e* es r ds)
  (match es
    ['() '()]
    [(cons e es)
     (cons (interp-e e r ds)
           (interp-e* es r ds))]))

;; Value [Listof Pat] [Listof Expr] Env Defns -> Answer
(define (interp-match v ps es r ds)
  (match* (ps es)
    [('() '()) 'err]
    [((cons p ps) (cons e es))
     (match (interp-match-pat p v r ds)
       [#f (interp-match v ps es r ds)]
       ['err 'err]
       [r  (interp-e e r ds)])]))
;; Pat Value Env Defns -> [Maybe Env] | 'err
(define (interp-match-pat p v r ds)
  (match p
    [(Var '_) r]
    [(Var x) (ext r x v)]
    [(Lit l) (and (eqv? l v) r)]
    [(Box p)
     (match v
       [(box v)
        (interp-match-pat p v r ds)]
       [_ #f])]
    [(Cons p1 p2)
     (match v
       [(cons v1 v2)
        (match (interp-match-pat p1 v1 r ds)
          [#f #f]
          ['err 'err]
          [r1 (interp-match-pat p2 v2 r1 ds)])]
       [_ #f])]
    [(Conj p1 p2)
     (match (interp-match-pat p1 v r ds)
       [#f #f]
       ['err 'err]
       [r1 (interp-match-pat p2 v r1 ds)])]
    [(List ps)
     (interp-match-pat-list ps v r ds)]
    [(Pred f)
     (match (defns-lookup ds f)
       [(Defn f (list x) e)
        (match (interp-e e (list (list x v)) ds)
          ['err 'err]
          [#f #f]
          [v r])]
       [_ 'err])]
    [(Vect ps)
     (and (vector? v)
          (interp-match-pat-list ps (vector->list v) r ds))]))

;; [Listof Pat] Value Env Defns -> [Maybe Env] | 'err
(define (interp-match-pat-list ps v r ds)
  (match (cons ps v)
    [(cons '() '()) r]
    [(cons (cons p ps) (cons v vs))
     (match (interp-match-pat p v r ds)
       [#f #f]
       ['err 'err]
       [r (interp-match-pat-list ps vs r ds)])]
    [_ #f]))

;; Defns Symbol -> Defn
(define (defns-lookup ds f)
  (findf (match-lambda [(Defn g _ _) (eq? f g)])
         ds))

(define (zip xs ys)
  (match* (xs ys)
    [('() '()) '()]
    [((cons x xs) (cons y ys))
     (cons (list x y)
           (zip xs ys))]))

