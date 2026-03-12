#lang racket
(provide test)
(require rackunit)

(define (test run)
  (begin ;; Abscond
    (check-equal? (run 7) 7)
    (check-equal? (run -8) -8))

  (begin ;; Blackmail
    (check-equal? (run '(add1 (add1 7))) 9)
    (check-equal? (run '(add1 (sub1 7))) 7))

  (begin ;; Con
    (check-equal? (run '(if (zero? 0) 1 2)) 1)
    (check-equal? (run '(if (zero? 1) 1 2)) 2)
    (check-equal? (run '(if (zero? -7) 1 2)) 2)
    (check-equal? (run '(if (zero? 0)
                            (if (zero? 1) 1 2)
                            7))
                  2)
    (check-equal? (run '(if (zero? (if (zero? 0) 1 0))
                            (if (zero? 1) 1 2)
                            7))
                  7))

  (begin ;; Dupe
    (check-equal? (run #t) #t)
    (check-equal? (run #f) #f)
    (check-equal? (run '(if #t 1 2)) 1)
    (check-equal? (run '(if #f 1 2)) 2)
    (check-equal? (run '(if 0 1 2)) 1)
    (check-equal? (run '(if #t 3 4)) 3)
    (check-equal? (run '(if #f 3 4)) 4)
    (check-equal? (run '(if  0 3 4)) 3)
    (check-equal? (run '(zero? 4)) #f)
    (check-equal? (run '(zero? 0)) #t))

  ;; SOLN
  (begin ;; Midterm
    (check-equal? (run '(odd? -1)) #t)
    (check-equal? (run '(odd? -2)) #f)
    (check-equal? (run '(odd?  0)) #f)
    (check-equal? (run '(odd?  1)) #t)
    (check-equal? (run '(odd?  2)) #f)
    (check-equal? (run '(odd?  3)) #t)
    (check-equal? (run '(odd?  4)) #f)
    (check-equal? (run '(odd?  5)) #t)
    (check-equal? (run '(odd?  6)) #f)
    (check-equal? (run '(odd?  7)) #t)
    (check-equal? (run '(odd?  8)) #f)
    (check-equal? (run '(odd?  9)) #t)
    (check-equal? (run '(odd?  10)) #f)
    (check-equal? (run '(odd?  11)) #t)
    (check-equal? (run '(odd?  12)) #f)
    (check-equal? (run '(odd?  13)) #t)
    (check-equal? (run '(odd?  14)) #f)
    (check-equal? (run '(odd?  15)) #t)
    (check-equal? (run '(odd?  16)) #f)
    (check-equal? (run '(odd?  17)) #t)
    (check-equal? (run '(odd?  18)) #f)
    (check-equal? (run '(odd?  19)) #t)
    (check-equal? (run '(odd?  20)) #f)
    (check-equal? (run '(odd?  12039475)) #t)
    (check-equal? (run '(odd?  -109320)) #f)))

