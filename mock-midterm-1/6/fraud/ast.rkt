#lang racket
(provide Lit Prim0 Prim1 Prim2 If Eof Begin Let Var)
(provide closed?)

;; type Expr = (Lit Datum)
;;           | (Eof)
;;           | (Prim0 Op0)
;;           | (Prim1 Op1 Expr)
;;           | (Prim2 Op2 Expr Expr)
;;           | (If Expr Expr Expr)
;;           | (Begin Expr Expr)
;;           | (Let Id Expr Expr)
;;           | (Var Id)

;; type Id  = Symbol
;; type Datum = Integer
;;            | Boolean
;;            | Character
;; type Op0 = 'read-byte | 'peek-byte | 'void
;; type Op1 = 'add1 | 'sub1
;;          | 'zero?
;;          | 'char? | 'integer->char | 'char->integer
;;          | 'write-byte | 'eof-object?
;; type Op2 = '+ | '- | '< | '=

(struct Eof () #:prefab)
(struct Lit (d) #:prefab)
(struct Prim0 (p) #:prefab)
(struct Prim1 (p e) #:prefab)
(struct Prim2 (p e1 e2) #:prefab)
(struct If (e1 e2 e3) #:prefab)
(struct Begin (e1 e2) #:prefab)
(struct Let (x e1 e2) #:prefab)
(struct Var (x) #:prefab)

;; Expr -> Boolean
;; Is the given expression closed?
(define (closed? e) (closed-helper? e '()))

(define (closed-helper? e bounded-vars)
  (match e
    [(Eof) #t]
    [(Lit d) #t]
    [(Prim0 p) #t]
    [(Prim1 p e) (closed-helper? e bounded-vars)]
    [(Prim2 p e1 e2) (and (closed-helper? e1 bounded-vars) (closed-helper? e2 bounded-vars))]
    [(If e1 e2 e3) (and (closed-helper? e1 bounded-vars) (closed-helper? e2 bounded-vars) (closed-helper? e3 bounded-vars))]
    [(Begin e1 e2) (and (closed-helper? e1 bounded-vars) (closed-helper? e2 bounded-vars))]
    [(Let x e1 e2) (and (closed-helper? e1 bounded-vars) (closed-helper? e2 (cons x bounded-vars)))]
    [(Var x)
      (define (loop bounds)
        (match bounds
          ['() #f]
          [(cons fst rst)
            (if (eq? x fst) 
              #t
              (loop rst))]))
      (loop bounded-vars)]))

(module+ test
  (require rackunit)
  (check-equal? (closed? (Var 'x)) #f)
  (check-equal? (closed? (Let 'x (Lit 0) (Var 'x))) #t))
