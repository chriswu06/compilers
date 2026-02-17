#lang racket
(provide (all-defined-out))
(require a86/ast)
(module+ test
  (require rackunit)
  (require a86/interp))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Getting started with registers

;; Define a sequence of assembly instructions that swap the contents
;; of rax and rcx.

;; The sequence should leave the stack and all callee-saved registers
;; in the same state it started in.

;; Asm
(define swap-rax-rcx
  (seq
  (Mov 'rdx 'rax)
  (Mov 'rax 'rcx)
  (Mov 'rcx 'rdx)))

(module+ test
  ;; Int64 Int64 -> Boolean
  (define (run n1 n2)
    (zero?
     (asm-interp
      (prog (Global 'entry)
            (Label 'entry)
            (Mov 'rax n1)
            (Mov 'rcx n2)
            swap-rax-rcx
            (Cmp 'rax n2)
            (Mov 'rax 0)
            (Mov 'rdx 1)
            (Cmovne 'rax 'rdx)
            (Cmp 'rcx n1)
            (Cmovne 'rax 'rdx)
            ; rax is 1 if either is wrong, otherwise 0
            (Ret)))))
  (check-true (run 1 2))
  (check-true (run 42 12))
  (check-true (run 0 0)))
