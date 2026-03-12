#lang racket
(provide compile-op1)
(require "ast.rkt")
(require "types.rkt")
(require a86/ast a86/registers)

;; Op1 -> Asm
(define (compile-op1 p)
  (match p
    ['add1 (Add rax (value->bits 1))]
    ['sub1 (Sub rax (value->bits 1))]
    ['zero?
     (seq (Cmp rax 0)
          (Mov rax (value->bits #f))
          (Mov r9  (value->bits #t))
          (Cmove rax r9))]
    ['positive?
      (let ((non-positive (gensym 'if))
            (done (gensym 'if)))
        (seq (Cmp rax 0)
             (Jle non-positive)
             (Mov rax (value->bits #t))
             (Jmp done)
             (Label non-positive)
             (Mov rax (value->bits #f))
             (Label done)))]))

