#lang racket
(provide (all-defined-out))
(module+ test
  (require rackunit))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Representing expressions

;; Here is a datatype definition for representing expressions in a small
;; functional programming language:

;; type SExpr =
;; | Integer
;; | Boolean
;; | Variable
;; | (list e1 e2)
;; | (list 'lambda (list Variable) e)

;; type Variable = Symbol

;; Some examples of valid programs:
;; 34
;; #t
;; 'x
;; '((lambda (x) x) 17)

;; The above definition is easy to read, but can be troublesome to work with.
;; Instead of using the SExpr representation, we will transform it into a
;; more structured representation (this will be our AST).

;; type Expr =
;; | (Int Integer)
;; | (Bool Boolean)
;; | (Var Variable)
;; | (App Expr Expr)
;; | (Lam Variable Expr)

;; type Variable = Symbol

;; We will be using these structures:
(struct Int  (i)      #:prefab)
(struct Bool (b)      #:prefab)
(struct Var  (v)      #:prefab)
(struct App  (e1 e2)  #:prefab)
(struct Lam  (x e)    #:prefab)

;; After converting the above SExpr programs into Expr representation:
;; (Int 34)
;; (Bool #t)
;; (Var 'x)
;; (App (Lam 'x (Var 'x)) (Int 17))

;; We already wrote a helper function to put SExpr programs into this 
;; new representation. Feel free to play around with this in your REPL.
;; SExpr -> Expr
(define (sexpr->expr s)
  (match s
    [(? integer? s)     (Int s)]
    [(? boolean? b)     (Bool b)]
    [(? symbol? v)      (Var v)]
    [(list e1 e2)       (App (sexpr->expr e1) (sexpr->expr e2))]
    [(list 'lambda (list (? symbol? x)) e) 
     (Lam x (sexpr->expr e))]))

;; Below is a template of how to traverse this AST:

#;
(define (expr-template e)
  (match e
    [(Int i) ...]
    [(Bool b) ...]
    [(Var v) ...]
    [(App e1 e2)
     (... (expr-template e1)
          (expr-template e2) ...)]
    [(Lam x e)
     (... x (expr-template e) ...)]))


;; Note: for each of the following functions, the order of elements
;; and whether repetitions occur is left unspecified and up to you.
;; The tests are written using this function to take this in to
;; account.

(module+ test
  ;; [Listof a] [Listof a] -> Boolean
  ;; Are the two lists equal up to re-ordering and repetition?
  (define (list-set-equal? xs ys)
    (equal? (list->set xs) (list->set ys)))

  (check-equal? (list-set-equal? '() '()) #t)
  (check-equal? (list-set-equal? (list 1 2) (list 2 1)) #t)
  (check-equal? (list-set-equal? (list 1 1 2) (list 2 2 1)) #t)
  (check-equal? (list-set-equal? (list 1 1 2) (list 2 3 2 1)) #f))


;; Expr -> [Listof Integer]
;; Computes a list of all integer literals that appear in the expression
(define (expr-integers e)
  (match e
    [(Int i) (list i)]
    [(Bool _) '()]
    [(Var _) '()]
    [(App e1 e2) (append (expr-integers e1) (expr-integers e2))]
    [(Lam _ e1) (expr-integers e1)]))

(module+ test
  (check list-set-equal? (expr-integers (sexpr->expr 123)) '(123))
  (check list-set-equal? (expr-integers (sexpr->expr 'x)) '())
  (check list-set-equal? (expr-integers (sexpr->expr '((lambda (x) x) 123))) '(123))
  (check list-set-equal? (expr-integers (sexpr->expr '((lambda (x) 42) 123))) '(123 42)))

;; Expr -> [Listof Variable]
;; Compute a list of all lambda-bound variables in the expression
(define (expr-lambda-vars e)
  (match e
    [(Int _) '()]
    [(Bool _) '()]
    [(Var _) '()]
    [(App e1 e2) (append (expr-lambda-vars e1) (expr-lambda-vars e2))]
    [(Lam x e1) (cons x (expr-lambda-vars e1))]))

(module+ test
  (check list-set-equal? (expr-lambda-vars (sexpr->expr 123)) '())
  (check list-set-equal? (expr-lambda-vars (sexpr->expr 'x)) '())
  (check list-set-equal? (expr-lambda-vars (sexpr->expr '((lambda (x) x) 123))) '(x))
  (check list-set-equal? (expr-lambda-vars (sexpr->expr '((lambda (x) 42) 123))) '(x)))

;; Expr -> [Listof Variable]
;; Compute a list of all free variables, i.e. variables which occur outside
;; of any lambda that binds them.
(define (expr-free-vars e)
  (match e
    [(Int _) '()]
    [(Bool _) '()]
    [(Var x) (list x)]
    [(App e1 e2) (append (expr-free-vars e1) (expr-free-vars e2))]
    [(Lam x e1) (remove x (expr-free-vars e1))]))

(module+ test
  (check list-set-equal? (expr-free-vars (sexpr->expr 123)) '())
  (check list-set-equal? (expr-free-vars (sexpr->expr 'x)) '(x))
  (check list-set-equal? (expr-free-vars (sexpr->expr '((lambda (x) x) 123))) '())
  (check list-set-equal? (expr-free-vars (sexpr->expr '((lambda (x) 42) 123))) '()))
