#lang racket

(provide explanation program)


;; Replace the TODO below with your explanation. Everything between the
;; #<<EXPLANATION and EXPLANATION lines will be counted.
(define explanation
  #<<EXPLANATION 

Within the disj (or) pattern matching, rax is pushed onto the stack initially. But in the case
that p1 works, the rax is never popped before jumping to the 'success' branch. So (Add rsp 8) before jumping
moves the stack pointer past the pushed rax and discards what was pushed onto the stack (we don't need any more rax anymore).

EXPLANATION
)  ;; don't move this


;; TODO: Replace the Knock program in this list with one that demonstrates the
;; bug. We use a list so you can add function definitions if you like, e.g.,
;; you could write:
;;
;;   (list '(define (foo x) x)
;;         '(add1 (foo 2)))
;;
;; NOTE: You need to quote the S-expressions to prevent Racket running them.
(define program
  (list '(match 1
          [(or x x) x])))
