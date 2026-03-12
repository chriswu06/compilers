#lang racket
(provide Lit Prim0 Prim1 If Eof Begin Begin0)
;; type Expr = (Lit Datum)
;;           | (Eof)
;;           | (Prim0 Op0)
;;           | (Prim1 Op1 Expr)
;;           | (If Expr Expr Expr)
;;           | (Begin (Listof Expr) Expr)
;;           | (Begin0 Expr (Listof Expr))
;; type Datum = Integer
;;            | Boolean
;;            | Character
;; type Op0 = 'read-byte | 'peek-byte | 'void
;; type Op1 = 'add1 | 'sub1
;;          | 'zero?
;;          | 'char? | 'integer->char | 'char->integer
;;          | 'write-byte | 'eof-object?

(struct Eof () #:prefab)
(struct Lit (d) #:prefab)
(struct Prim0 (p) #:prefab)
(struct Prim1 (p e) #:prefab)
(struct If (e1 e2 e3) #:prefab)
(struct Begin (es ef) #:prefab)
(struct Begin0 (e1 es) #:prefab)
