#lang racket
(provide test test/io)
(require rackunit)
(define (test run)
  (begin
    (check-equal? (run '(raise 0)) 'err)
    (check-equal? (run '(with-handlers ([(λ (x) #t) (λ (x) 1)]) 0)) 0)
    (check-equal? (run '(with-handlers ([(λ (x) #t) (λ (x) 1)]) (raise 0))) 1)
    (check-equal? (run '(with-handlers ([(λ (x) #f) (λ (x) 1)]) (raise 22))) 'err)
    (check-equal? (run '(define (f x) (raise x))
                       '(with-handlers ([(λ (x) #t) (λ (x) 1)]) (f 0))) 1)
    (check-equal? (run '(add1 (with-handlers ([(λ (x) #t) (λ (x) 1)]) (raise 0)))) 2)
    (check-equal? (run '(add1 (with-handlers ([(λ (x) #t) (λ (x) 1)]) 0))) 1)
    (check-equal? (run '(add1 (with-handlers ([(λ (x) #t) (λ (x) 1)]) (+ #f (raise 0))))) 2)


    (check-equal? (run '(define (f x) (zero? x))
                       '(with-handlers ([f (λ (x) 1)]) (raise 0))) 1)

    
    (check-equal? (run '(with-handlers ([(λ (x) #t) (λ (x) x)]) (raise 42))) 42)
    ; handler transforms the raised value
    (check-equal? (run '(with-handlers ([(λ (x) #t) (λ (x) (add1 x))]) (raise 5))) 6)

    ; predicate inspects the raised value — matches
    (check-equal? (run '(with-handlers ([(λ (x) (zero? x)) (λ (x) 99)]) (raise 0))) 99)
    ; predicate inspects the raised value — doesn't match → err
    (check-equal? (run '(with-handlers ([(λ (x) (zero? x)) (λ (x) 99)]) (raise 1))) 'err)

    ; nested: no raise, value flows through both handlers untouched
    (check-equal? (run '(with-handlers ([(λ (x) #t) (λ (x) 2)])
                          (with-handlers ([(λ (x) #t) (λ (x) 1)])
                            5))) 5)
    ; nested: inner predicate returns #f, outer always-true catches
    (check-equal? (run '(with-handlers ([(λ (x) #t) (λ (x) 2)])
                          (with-handlers ([(λ (x) #f) (λ (x) 1)])
                            (raise 0)))) 2)
    ; nested: inner catches, outer never reached
    (check-equal? (run '(with-handlers ([(λ (x) #t) (λ (x) 2)])
                          (with-handlers ([(λ (x) #t) (λ (x) 1)])
                            (raise 0)))) 1)

    ; raise inside a let binding → caught
    (check-equal? (run '(with-handlers ([(λ (x) #t) (λ (x) 7)])
                          (let ((y (raise 0))) y))) 7)

    ; raise inside if condition → caught
    (check-equal? (run '(with-handlers ([(λ (x) #t) (λ (x) 8)])
                          (if (raise 0) 1 2))) 8)

    ; no raise, handler never invoked, body value returned
    (check-equal? (run '(with-handlers ([(λ (x) #t) (λ (x) 42)]) 5)) 5)

    ; function raises, handler receives and returns the value
    (check-equal? (run '(define (thrower) (raise 99))
                       '(with-handlers ([(λ (x) #t) (λ (x) x)]) (thrower))) 99)

    ; raise inside handler body → err (handler itself errors)
    (check-equal? (run '(with-handlers ([(λ (x) #t) (λ (x) (raise x))]) (raise 0))) 'err)))

(define (test/io run)
  (void))