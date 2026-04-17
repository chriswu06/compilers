#lang racket

(provide answer)

;; Consider the following fragment of a compiled Hoax program:
;;
#;   (list (Mov 'rax 16)
           (Push 'rax)
           (Mov 'rax 3528)
           (Pop 'r8)
           (Push 'r8)
           (And 'r8 15)
           (Cmp 'r8 0)
           (Pop 'r8)
           (Jne 'err)
           (Cmp 'r8 0)
           (Jl 'err)
           (Cmp 'r8 0)
           (Jne 'nz10302)
           (Lea 'rax (Mem 'empty 3))
           (Jmp 'theend10304)
           (Label 'nz10302)
           (Mov (Mem 'rbx 0) 'r8)
           (Sar 'r8 1)
           (Mov 'r9 'r8)
           (Label 'loop10303)
           (Mov (Mem 'rbx 'r8) 'rax)
           (Sub 'r8 8)
           (Cmp 'r8 0)
           (Jne 'loop10303)
           (Mov 'rax 'rbx)
           (Xor 'rax 3)
           (Add 'rbx 'r9)
           (Add 'rbx 8)
           (Label 'theend10304)
           (Push 'rax)
           (Mov 'rax (Mem 'rsp 0))
           (Mov (Mem 'rbx) 'rax)
           (Mov 'rax 'rbx)
           (Xor 'rax 1)
           (Add 'rbx 8))
;;
;; Select the memory diagram below that best corresponds to how you would expect
;; memory to look after executing these instructions.
;;
;; TODO: Replace the empty string with one of the options "A", "B", or "C".
(define (answer) "B")

(define A #<<OPTION-A

+--------------+
| 0x0103  vect |
+--------------+ 0xff10
| 0x0101   box |
+--------------+ 0xff08  <--- rsp
|              |
+--------------+ 0xff00
//    ....    //
//    ....    //
//    ....    //
+--------------+ 0x0118
|              |
+--------------+ 0x0110  <--- rbx
| 0x0dc8   #\n |
+--------------+ 0x0108
| 0x0010     1 |
+--------------+ 0x0100

OPTION-A
  )

(define B #<<OPTION-B

+--------------+
| 0x0103  vect |
+--------------+ 0xff10
| 0x0111   box |
+--------------+ 0xff08  <--- rsp
|              |
+--------------+ 0xff00
//    ....    //
//    ....    //
//    ....    //
+--------------+ 0x0120
|              |
+--------------+ 0x0118  <--- rbx
| 0x0103  vect |
+--------------+ 0x0110
| 0x0dc8   #\n |
+--------------+ 0x0108
| 0x0010     1 |
+--------------+ 0x0100

OPTION-B
  )

(define C #<<OPTION-C

+--------------+
| 0x0101   box |
+--------------+ 0xff10
| 0x0113  vect |
+--------------+ 0xff08  <--- rsp
|              |
+--------------+ 0xff00
//    ....    //
//    ....    //
//    ....    //
+--------------+ 0x0120
|              |
+--------------+ 0x0118  <--- rbx
| 0x0010     1 |
+--------------+ 0x0110
| 0x0dc8   #\n |
+--------------+ 0x0108
| 0x0113  vect |
+--------------+ 0x0100

OPTION-C
  )
