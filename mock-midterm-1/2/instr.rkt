#lang racket
(require a86)
(provide is)

(define is
  ;; Assume encoding of c1 in rax and encoding of c2 in rbx.
  ;;
  ;; TODO: write instructions that produce encoding of (char<? c1 c2) in rax.
  ;;
  ;; NOTE: #b011 encodes #t, #b111 encodes #f.
  (seq
    (Cmp rax rbx)
    (Jl true)
    (Mov rax #b111)
    (Jmp done)
    (Label true)
    (Mov rax #b011)
    (Label done))
