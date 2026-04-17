#lang racket

(provide answer)

;; Consider the following Hoax program:
;;
#;   (let ([v (make-vector 2 #\a)])
       (begin
         (vector-set! v 1 #\z)
         (begin
           (cons v v)
           HERE)))
;;
;; Select the memory diagram below that best corresponds to how you would expect
;; memory to look JUST BEFORE the `HERE` variable would be executed.
;;
;; TODO: Replace the empty string with one of the options "A", "B", or "C".
(define (answer) "B")

(define A #<<OPTION-A

+--------------+
| 0x0132  cons |
+--------------+ 0xff08  <--- rsp
|              |
+--------------+ 0xff00
//    ....    //
//    ....    //
//    ....    //
+--------------+ 0x0148
|              |
+--------------+ 0x0140  <--- rbx
| 0x011b  vect |
+--------------+ 0x0138
| 0x0103  vect |
+--------------+ 0x0130
| 0x0f48   #\z |
+--------------+ 0x0128
| 0x0c28   #\a |
+--------------+ 0x0120
| 0x0020     2 |
+--------------+ 0x0118
| 0x0f48   #\z |
+--------------+ 0x0110
| 0x0c28   #\a |
+--------------+ 0x0108
| 0x0020     2 |
+--------------+ 0x0100

OPTION-A
  )

(define B #<<OPTION-B

+--------------+
| 0x011a  cons |
+--------------+ 0xff08  <--- rsp
|              |
+--------------+ 0xff00
//    ....    //
//    ....    //
//    ....    //
+--------------+ 0x0130
|              |
+--------------+ 0x0128  <--- rbx
| 0x0103  vect |
+--------------+ 0x0120
| 0x0103  vect |
+--------------+ 0x0118
| 0x0f48   #\z |
+--------------+ 0x0110
| 0x0c28   #\a |
+--------------+ 0x0108
| 0x0020     2 |
+--------------+ 0x0100

OPTION-B
  )

(define C #<<OPTION-C

+--------------+
| 0x0103  vect |
+--------------+ 0xff10
| 0x0103  vect |
+--------------+ 0xff08  <--- rsp
|              |
+--------------+ 0xff00
//    ....    //
//    ....    //
//    ....    //
+--------------+ 0x0120
|              |
+--------------+ 0x0118  <--- rbx
| 0x0f48   #\z |
+--------------+ 0x0110
| 0x0c28   #\a |
+--------------+ 0x0108
| 0x0020     2 |
+--------------+ 0x0100

OPTION-C
  )
