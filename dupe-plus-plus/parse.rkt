#lang racket
(provide parse)
(require "ast.rkt")

;; S-Expr -> Expr
(define (parse s)
  (match s
    [(? datum?) (Lit s)]
    [(list-rest (? symbol? k) sr)
     (match k
       [(? op1? o)
        (match sr
          [(list s1)
           (Prim1 o (parse s1))]
          [_ (error "op1: bad syntax" s)])]
       ['if
        (match sr
          [(list s1 s2 s3)
           (If (parse s1) (parse s2) (parse s3))]
          [_ (error "if: bad syntax" s)])]
       ['cond
        (parse-cond sr)]
       ['case
        (parse-case sr)]
       [_ (error "parse error" s)])]
    [_ (error "parse error" s)]))

;; S-Expr -> Cond
(define (parse-cond s)
  (match s
    [(list (list 'else s)) (Cond '() '() (parse s))]
    [(cons (list s1 s2) sr)
     (match (parse-cond sr)
       [(Cond qs es e)
        (Cond (cons (parse s1) qs) (cons (parse s2) es) e)])]
    [_ (error "parse error")]))

;; S-Expr -> Case
(define (parse-case s)
  (match s
    [(cons s sr)
     (parse-case-clauses s sr)]
    [_
     (error "parse error")]))

;; S-Expr S-Expr -> Case
(define (parse-case-clauses s sr)
  (match sr
    [(list (list 'else s2)) (Case (parse s) '() '() (parse s2))]
    [(cons (list d1 s1) sr)
     (match (parse-case-clauses s sr)
       [(Case e ds es el)
        (Case e
              (cons (map parse-datum d1) ds)
              (cons (parse s1) es)
              el)])]))

;; S-Expr -> Datum
(define (parse-datum s)
  (if (or (integer? s)
          (boolean? s))
      s
      (error "parse error: not a datum")))

;; Any -> Boolean
(define (datum? x)
  (or (exact-integer? x)
      (boolean? x)))

(define (op1? x)
  (memq x '(add1 sub1 zero? abs - not)))

