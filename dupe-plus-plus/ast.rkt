#lang racket
(provide Lit Prim1 If Cond Case)
;; type Expr = (Lit Datum)
;;           | (Prim1 Op1 Expr)
;;           | (If Expr Expr Expr)
;;           | (Cond [Listof Expr] [Listof Expr] Expr)
;;           | (Case Expr [Listof [Listof Datum]] [Listof Expr] Expr)
;; type Datum = Integer
;;            | Boolean
;; type Op1 = 'add1 | 'sub1
;;          | 'zero?
;;          | 'abs | '- | 'not
(struct Lit (d) #:prefab)
(struct Prim1 (p e) #:prefab)
(struct If (e1 e2 e3) #:prefab)
(struct Cond (cs es el) #:prefab)
(struct Case (e ds es el) #:prefab)

