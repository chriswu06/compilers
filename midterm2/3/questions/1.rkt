#lang racket

(provide answer)

;; Consider the following Hoax program:
;;
#;   (let ([l (cons 98 (cons 62 '()))])
       HERE)
;;
;; Select the memory diagram below that best corresponds to how you would expect
;; memory to look JUST BEFORE the `HERE` variable would be executed.
;;
;; TODO: Replace the empty string with one of the options "A", "B", or "C".
(define (answer) "A")

(define A #<<OPTION-A

+--------------+
| 0x0112  cons |
+--------------+ 0xff08  <--- rsp
|              |
+--------------+ 0xff00
//    ....    //
//    ....    //
//    ....    //
+--------------+ 0x0128
|              |
+--------------+ 0x0120  <--- rbx
| 0x0102  cons |
+--------------+ 0x0118
| 0x0620    98 |
+--------------+ 0x0110
| 0x0098   '() |
+--------------+ 0x0108
| 0x03e0    62 |
+--------------+ 0x0100

OPTION-A
  )

(define B #<<OPTION-B

+--------------+
| 0x0112  cons |
+--------------+ 0xff08  <--- rsp
|              |
+--------------+ 0xff00
//    ....    //
//    ....    //
//    ....    //
+--------------+ 0x0128
|              |
+--------------+ 0x0120  <--- rbx
| 0x0102  cons |
+--------------+ 0x0118
| 0x03e0    62 |
+--------------+ 0x0110
| 0x0098   '() |
+--------------+ 0x0108
| 0x0620    98 |
+--------------+ 0x0100

OPTION-B
  )

(define C #<<OPTION-C

+--------------+
| 0x011a  cons |
+--------------+ 0xff08  <--- rsp
|              |
+--------------+ 0xff00
//    ....    //
//    ....    //
//    ....    //
+--------------+ 0x0128
|              |
+--------------+ 0x0120  <--- rbx
| 0x0620    98 |
+--------------+ 0x0118
| 0x010a  cons |
+--------------+ 0x0110
| 0x03e0    62 |
+--------------+ 0x0108
| 0x0098   '() |
+--------------+ 0x0100

OPTION-C
  )
