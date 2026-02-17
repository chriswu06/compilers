#lang racket
(provide (all-defined-out))
(require a86/ast)
(module+ test
  (require rackunit)
  (require a86/interp))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Some problems using bitwise operations


;; Define a sequence of assembly instructions that zeroes out the least
;; significant 4 bits of the rax register.

;; The sequence should leave the stack and all callee-saved registers
;; in the same state it started in.

(define zero-lower-4-rax
  (seq
  (Mov 'r10 #xfffffffffffffff0)
  (And 'rax 'r10)))


(module+ test
  ;; Int64 -> Int64
  (define (t1 n)
    (asm-interp
     (prog (Global 'entry)
           (Label 'entry)
           (Mov 'rax n)
           zero-lower-4-rax
           (Ret))))

  (check-equal? (t1 0) 0)
  (check-equal? (t1 5) 0)
  (check-equal? (t1 15) 0)
  (check-equal? (t1 16) 16)
  (check-equal? (t1 (sub1 (expt 2 32))) (- (sub1 (expt 2 32)) 15))
  (check-equal? (t1 (expt 2 32)) (expt 2 32))
  (check-equal? (t1 (sub1 (expt 2 64))) -16))


;; Define a sequence of assembly instructions that puts 1 into rcx
;; if the least signficant 4 bits of rax are equal to 5 or puts 0
;; into rcx otherwise.  The value in rax should not change.

;; The sequence should leave the stack and all callee-saved registers
;; in the same state it started in.

(define check-lower-4-rax
  (seq
  (Mov 'r10 #xf)
  (And 'r10 'rax)
  (Cmp 'r10 5)
  (Je 'equal)
  (Mov 'rcx 0)
  (Jmp 'done)
  (Label 'equal)
  (Mov 'rcx 1)
  (Label 'done)))

(module+ test
  ;; Int64 -> Boolean
  (define (t2 n)
    (zero?
     (asm-interp
      (prog (Global 'entry)
            (Label 'entry)
            (Mov 'rax n)
            check-lower-4-rax
            (Cmp 'rax n)
            (Mov 'rax 0)
            (Mov 'rdx 1)
            (Cmovne 'rax 'rdx)
            (Cmp 'rcx (if (= 5 (bitwise-and n #b1111)) 1 0))
            (Cmovne 'rax 'rdx)
            ; rax is 1 if either is wrong, otherwise 0
            (Ret)))))

  (check-true (t2 0)) ;0x00000000 --> rcx = 0
  (check-true (t2 5)) ;0x00000011 --> rcx = 1
  (check-true (t2 15)) ;0x00001111 --> rcx = 1
  (check-true (t2 16)) ;0x00010000 --> rcx = 0
  (check-true (t2 21))) ;0x00010011 --> rcx = 1
