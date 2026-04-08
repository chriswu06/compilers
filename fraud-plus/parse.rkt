#lang racket
(provide parse parse-closed)
(require "ast.rkt")

;; S-Expr -> Datum
(define (parse-datum s)
  (if (datum? s)
      s
      (error "parse error: not a datum")))

;; s:S-Expr -> e:ClosedExpr
;; Parse s into (a potentially open) expr e
(define (parse s)
  (match (parse/acc s '() '())
    [(list _ e) e]))

;; s:S-Expr -> e:ClosedExpr
;; Parse s into closed expr e; signal an error when e is open
(define (parse-closed s)
  (match (parse/acc s '() '())
    [(list '() e) e]
    [(list fvs e) (error "unbound identifiers" fvs)]))

;; s:S-Expr bvs:[Listof Id] fvs:[Listof Id]
;;   -> (list fvs-e:[Listof Id] e:Expr)
;; Parse s into expr e and list of free variables fvs-e,
;; assuming variables in bvs are bound and fvs are free.
(define (parse/acc s bvs fvs)
  (define (rec s bvs fvs)
    (match s
      [(and 'eof (? (not-in bvs)))
       (list fvs (Eof))]
      [(? datum?)
       (list fvs (Lit s))]
      [(? symbol?)
       (list (if (memq s bvs) fvs (cons s fvs)) (Var s))]
      [(list-rest (? symbol? (? (not-in bvs) k)) sr)
       (match k
         ['let*
          (parse-let* sr bvs fvs)]
         ['let
          (parse-let sr bvs fvs)]
         ['cond
          (parse-cond sr bvs fvs)]
         ['case
          (parse-case sr bvs fvs)]
         [_
          (match (parse-es/acc sr bvs fvs)
            [(list fvs es)
             (list fvs
                   (match (cons k es)
                     [(list (? op0? o)) (Prim0 o)]
                     [(list (? op1? o) e1) (Prim1 o e1)]
                     [(list (? op2? o) e1 e2) (Prim2 o e1 e2)]
                     [(list 'begin e1 e2) (Begin e1 e2)]
                     [(list 'if e1 e2 e3) (If e1 e2 e3)]
                     [_ (error "bad syntax" s)]))])])]
      [_ (error "parse error" s)]))
  (rec s bvs fvs))

;; s:S-Expr bvs:[Listof Id] fvs:[Listof Id] ->
;;   -> (list fvs-e:[Listof Id] e:Expr)
(define (parse-let s bvs fvs)
  (define (rec sr xs es fvs)
    (match sr
      [(list (list) sb)
       (match (parse/acc sb (append xs bvs) fvs)
         [(list fvs e)
          (list fvs (Let (reverse xs) (reverse es) e))])]
      [(list (cons (list (? symbol? x) s1) sr) sb)
       (if (member x xs)
           (error "let: duplicate variable" x)
           (match (parse/acc s1 bvs fvs)
             [(list fvs e1)
              (rec (list sr sb) (cons x xs) (cons e1 es) fvs)]))]
      [_ (error "let: bad syntax" s)]))
  (rec s '() '() fvs))


;; S-Expr [Listof Id] [Listof Id] -> (list [Listof Id] Cond)
(define (parse-cond s bvs fvs)
  (match s
    [(list (list (and 'else (? (not-in bvs) 'else)) s))
     (match (parse/acc s bvs fvs)
       [(list fvs e)
        (list fvs (Cond '() '() e))])]
    [(cons (list s1 s2) sr)
     (match (parse-cond sr bvs fvs)
       [(list fvs (Cond qs es e))
        (match (parse/acc s1 bvs fvs)
          [(list fvs e1)
           (match (parse/acc s2 bvs fvs)
             [(list fvs e2)
              (list fvs (Cond (cons e1 qs) (cons e2 es) e))])])])]
    [_ (error "parse error")]))

;; S-Expr [Listof Id] [Listof Id] -> (list [Listof Id] Case)
(define (parse-case s bvs fvs)
  (match s
    [(cons s sr)
     (parse-case-clauses s sr bvs fvs)]
    [_
     (error "parse error")]))

;; S-Expr S-Expr [Listof Id] [Listof Id] -> (list [Listof Id] Case)
(define (parse-case-clauses s sr bvs fvs)
  (match sr
    [(list (list (and 'else (? (not-in bvs) 'else)) s2))
     (match (parse/acc s bvs fvs)
       [(list fvs e)
        (match (parse/acc s2 bvs fvs)
          [(list fvs e2)
           (list fvs (Case e '() '() e2))])])]
    [(cons (list d1 s1) sr)
     (match (parse/acc s1 bvs fvs)
       [(list fvs e1)
        (match (parse-case-clauses s sr bvs fvs)
          [(list fvs (Case e ds es el))
           (list fvs
                 (Case e
                       (cons (map parse-datum d1) ds)
                       (cons e1 es)
                       el))])])]))

;; s:S-Expr bvs:[Listof Id] fvs:[Listof Id] ->
;;   -> (list fvs-e:[Listof Id] e:Expr)
(define (parse-let* s bvs fvs)
  (define (rec sr xs es fvs bvs)
    (match sr
      [(list (list) sb)
       (match (parse/acc sb bvs fvs)
         [(list fvs e)
          (list fvs (Let* (reverse xs) (reverse es) e))])]
      [(list (cons (list (? symbol? x) s1) sr) sb)
       (match (parse/acc s1 bvs fvs)
         [(list fvs e1)
          (rec (list sr sb) (cons x xs) (cons e1 es) fvs (cons x bvs))])]
      [_ (error "let: bad syntax" s)]))
  (rec s '() '() fvs bvs))

;; s:S-Expr bvs:[Listof Id] fvs:[Listof Id]
;;   -> (list fvs-e:[Listof Id] es:[Listof Expr])
;; Parse s into a list of expr es and list of free variables fvs-e,
;; assuming variables in bvs are bound and fvs are free.
(define (parse-es/acc s bvs fvs)
  (match s
    ['() (list fvs '())]
    [(cons s ss)
     (match (parse/acc s bvs fvs)
       [(list fvs e)
        (match (parse-es/acc ss bvs fvs)
          [(list fvs es)
           (list fvs (cons e es))])])]
    [_ (error "parse error")]))

;; xs:[Listof Any] -> p:(x:Any -> Boolean)
;; Produce a predicate p for things not in xs
(define (not-in xs)
  (λ (x) (not (memq x xs))))

;; Any -> Boolean
(define (datum? x)
  (or (exact-integer? x)
      (boolean? x)
      (char? x)))

;; Any -> Boolean
(define (op0? x)
  (memq x '(read-byte peek-byte void)))

(define (op1? x)
  (memq x '(add1 sub1 zero? abs - not
                 integer? boolean?
                 char? integer->char char->integer
                 write-byte eof-object?)))

(define (op2? x)
  (memq x '(+ - < =)))

