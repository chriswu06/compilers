#lang racket

(provide max-env-length)

(require "ast.rkt")

;; Expr -> Non-Negative Integer
(define (max-env-length e)
  (match e
    [(Lit d) 0]
    [(Eof) 0]
    [(Prim0 p) 0]
    [(Prim1 p e1) (max-env-length e1)]
    [(Prim2 p e1 e2) (max (max-env-length e1) (max-env-length e2))]
    [(If e1 e2 e3) (max (max-env-length e1) (max-env-length e2) (max-env-length e3))]
    [(Begin e1 e2) (max (max-env-length e1) (max-env-length e2))]
    [(Let x e1 e2) (max (+ 1 (max-env-length e1)) (+ 1 (max-env-length e2)))]
    [(Var x) 0]))

(module+ test
  (require rackunit)
  (require "parse.rkt")
  (define run (compose1 max-env-length parse))

  (check-equal? (run '42) 0)
  (check-equal? (run '(begin (let ([x 1]) x)
                             (let ([y 2])
                               (let ([z 3])
                                 y))))
                2)
  (check-equal? (run '(let ([x 1])
                        (let ([y 2])
                          (let ([z 3])
                            y))))
                3))
