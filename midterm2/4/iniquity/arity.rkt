#lang racket

(provide correct-arity?)
(require "ast.rkt")

;; TODO: Implement this function.
;;
;; Prog -> Boolean
;; Determines if every application of every function has the correct number of
;; arguments in the program.
(define (correct-arity? p)
  (match p
    [(Prog ds e)
      (define (search f ds)
        (match ds
          ['() #f]
          [(cons (Defn name xs body) rest)
            (if (eq? name f)
                xs
                (search f rest))]))
      (define (check-everything es)
        (match es
          ['() #t]
          [(cons e rest) (and (check e) (check-everything rest))]))
      (define (check e)
        (match e
          [(Lit _) #t]
          [(Eof) #t]
          [(Var _) #t]
          [(Prim0 _) #t]
          [(Prim1 _ e) (check e)]
          [(Prim2 _ e1 e2) (and (check e1) (check e2))]
          [(Prim3 _ e1 e2 e3) (and (check e1) (check e2) (check e3))]
          [(If e1 e2 e3) (and (check e1) (check e2) (check e3))]
          [(Begin e1 e2) (and (check e1) (check e2))]
          [(Let _ e1 e2) (and (check e1) (check e2))]
          [(App f es) (define params (search f ds)) (and params (= (length es) (length params)) (check-everything es))]))
      (define (check-defns ds)
        (match ds
          ['() #t]
          [(cons (Defn _ _ body) rest) (and (check body) (check-defns rest))]))
      (and (check-defns ds) (check e))]))
