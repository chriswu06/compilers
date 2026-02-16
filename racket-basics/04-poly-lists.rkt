#lang racket
(provide (all-defined-out))
(module+ test
  (require rackunit))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Polymorphic list functions

;; ∀ (α) (α -> Real) [Pairof α [Listof α]] -> α
;; Find element that minimizes the given measure (take first if more than one)
(define (minimize f xs)
  (define values (map f xs))
  (define minval (apply min values))
  (define (helper i)
    (if (equal? (f (list-ref xs i)) minval)
      (list-ref xs i)
      (helper (+ i 1))))
  (helper 0))

(module+ test
  (check-equal? (minimize abs '(1 -2 3)) 1)
  (check-equal? (minimize string-length '("abc" "d" "efg")) "d")
  (check-equal? (minimize string-length '("abc" "d" "ef" "g")) "d"))

;; ∀ (α) (α α -> Boolean) [Listof α] -> [Listof α]
;; Sort list in ascending order according to given comparison
;; ENSURE: result is stable
(define (sort < xs)
  (define (insert n ls1) ;;Assuming ascension is preserved in list
    (define (helper i)
      (if (or (>= i (length ls1)) (< n (list-ref ls1 i)))
        (append (take ls1 i) (list n) (drop ls1 i))
        (helper (+ i 1))))
      (helper 0))
  (define (insertion-applier ls1 ls2)
    (match ls1
      ['() ls2]
      [_ (insertion-applier (cdr ls1) (insert (car ls1) ls2))]))
  (insertion-applier xs '()))

(module+ test
  (check-equal? (sort < '(1 -2 3)) '(-2 1 3))
  (check-equal? (sort string<? '("d" "abc" "efg")) '("abc" "d" "efg"))
  (check-equal?
   (sort (λ (s1 s2)
           (< (string-length s1) (string-length s2)))
         '("efg" "d" "abc")) '("d" "efg" "abc")))

;; ∀ (α β) [Listof α] [Listof β] -> [Listof [List α β]]
;; Zip together lists into a list of lists
;; ASSUME: lists are the same length
(define (zip as bs) ;;Is this not just the same as one of the functions from 03?
  (define (helper i cs)
    (if (>= i (length as))
      (reverse cs)
      (helper (+ i 1) (cons (list (list-ref as i) (list-ref bs i)) cs))))
  (helper 0 '()))

(module+ test
  (check-equal? (zip '() '()) '())
  (check-equal? (zip '(1) '(2)) '((1 2)))
  (check-equal? (zip '(1 3) '(2 4)) '((1 2) (3 4)))
  (check-equal? (zip '(1 3) '("a" "b")) '((1 "a") (3 "b"))))

;; ∀ (α) (Listof (α -> α)) -> (α -> α)
;; Compose a list of functions into a single function
;; ((pipe (list f1 f2 f3)) x) ≡ (f1 (f2 (f3 x)))
(define (pipe fs)
  (lambda (x)
    (match fs
      ['() x]
      [_ ((pipe (take fs (- (length fs) 1))) ((last fs) x))])))

(module+ test
  (check-equal? ((pipe (list number->string sqr add1)) 5) "36")
  (check-equal? ((pipe (list number->string add1 sqr)) 5) "26")
  (check-equal? ((pipe (list string-length number->string add1 sqr)) 5) 2))
