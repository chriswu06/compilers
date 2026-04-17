#lang racket

(provide answer)

;; Consider the following memory diagram for a Hoax program:
#;#<<DIAGRAM

+--------------+
| 0x0132  cons |
+--------------+ 0xff10
| 0x0142  cons |
+--------------+ 0xff08  <--- rsp
|              |
+--------------+ 0xff00
//    ....    //
//    ....    //
//    ....    //
+--------------+ 0x0158
|              |
+--------------+ 0x0150  <--- rbx
| 0x0132  cons |
+--------------+ 0x0148
| 0x0132  cons |
+--------------+ 0x0140
| 0x011b  vect |
+--------------+ 0x0138
| 0x0103  vect |
+--------------+ 0x0130
| 0x0c28   #\a |
+--------------+ 0x0128
| 0x0c48   #\b |
+--------------+ 0x0120
| 0x0020     2 |
+--------------+ 0x0118
| 0x0c48   #\b |
+--------------+ 0x0110
| 0x0c28   #\a |
+--------------+ 0x0108
| 0x0020     2 |
+--------------+ 0x0100

DIAGRAM
;;
;; Select the Hoax program below that, if you were to pause execution JUST
;; BEFORE the `HERE` variable would be executed, best corresponds to this memory
;; diagram.
;;
;; TODO: Replace the empty string with one of the options "A", "B", "C", or "D".
(define (answer) "D")

(define A
  '(let ([v (make-vector 2 #\a)])
     (let ([c (cons v v)])
       (begin (begin (vector-set! (car c) 0 #\b)
                     (vector-set! (cdr c) 1 #\a))
              HERE))))

(define B
  '(let ([v1 (make-vector 2 #\a)])
     (let ([v2 (make-vector 2 #\a)])
       (begin
         (vector-set! v1 1 #\b)
         (let ([c (cons v2 v1)])
           (begin (vector-set! v2 0 #\b)
                  HERE))))))

(define C
  '(let ([c (cons (make-vector 2 #\a)
                  (make-vector 2 #\b))])
     (begin (begin (vector-set! (car c) 0 #\b)
                   (vector-set! (cdr c) 0 #\a))
            (cons (cons c c)
                  HERE))))

(define D
  '(let ([c (cons (make-vector 2 #\a)
                  (make-vector 2 #\b))])
     (begin (begin (vector-set! (car c) 1 #\b)
                   (vector-set! (cdr c) 1 #\a))
            (cons (cons c c)
                  HERE))))
