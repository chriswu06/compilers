#lang racket
(provide (all-defined-out))
(require racket/match)
(module+ test
  (require rackunit))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Numeric functions

;; Natural -> Natural
;; Compute n!
(define (fact n)
  (match n 
    [0 1]
    [1 1]
    [_ (* n (fact (- n 1)))]))

(module+ test
  (check-equal? (fact 0) 1)
  (check-equal? (fact 1) 1)
  (check-equal? (fact 2) 2)
  (check-equal? (fact 5) 120))

;; Natural -> Natural
;; Compute nth Fibonnaci number
(define (fib n)
  (match n 
    [0 0]
    [1 1]
    [_ (define (helper n num1 num2)
        (match n
          [1 num2]
          [_ (helper (- n 1) num2 (+ num1 num2))]))
      (helper n 0 1)]))j

(module+ test
  (check-equal? (fib 0) 0)
  (check-equal? (fib 1) 1)
  (check-equal? (fib 2) 1)
  (check-equal? (fib 3) 2)
  (check-equal? (fib 4) 3)
  (check-equal? (fib 5) 5)
  (check-equal? (fib 6) 8)
  (check-equal? (fib 20) 6765))
