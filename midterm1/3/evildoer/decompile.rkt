#lang racket

(provide is-1 prog-1
         is-2 prog-2
         is-3 prog-3
         is-4 prog-4
         is-5 prog-5)

(require a86/ast a86/registers)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Program 1
;;
(define is-1
  (list (Global 'entry)
        (Label 'entry)
        (Sub rsp 8) ;; sub from stack
        (Mov rax 2) ;; Move 1 [#b10] to rax
        (Cmp rax 7) ;; Compare rax to #f
        (Je 'l1) ;; don't jump, rax [#b10] is not equal to #f [#b111]
        (Mov rax 4) ;; Second branch --> Move #t to rax
        (Extern 'write_byte) ;; Declare external function write byte
        (Mov rdi rax) ;; Move rax (#t) to rdi for write-byte
        (Call 'write_byte) ;; Call external function write byte
        (Mov rax 6) ;; Mov 3 [#b110] to rax
        (Jmp 'l2) ;; jump to l2
        (Label 'l1) ;; First branch
        (Mov rax 8) ;; Move 4 (#b1000) to rax to return
        (Label 'l2) ;; continue
        (Add rsp 8) ;; add to stack
        (Ret)))

(define (prog-1)
  '(if 1
    (begin
      (write-byte #t)
      3)
    4))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Program 2
;;

(define is-2
  (list (Global 'entry)
        (Label 'entry)
        (Sub rsp 8) ;; sub from stack for read_byte
        (Extern 'read_byte) ;; Declare external function read_byte
        (Call 'read_byte) ;; Call external function read_byte
        (Extern 'read_byte) ;; Declare external function read_byte
        (Call 'read_byte) ;; Call external function read_byte (overwrites)
        (Cmp rax 0) ;; Compare 0 to input
        (Mov rax 7) ;; Move #f [#b111] to rax
        (Mov r9 3) ;; Move #t [#b011] to r9
        (Cmove rax r9) ;; Move #t to be returned if 0 is second input, otherwise return #f
        (Add rsp 8) ;; add to stack for read_byte
        (Ret)))

(define (prog-2)
  '(let ([_ (read-byte)]
         [b (read-byte)])
      (zero? b)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Program 3
;;

(define is-3
  (list (Global 'entry)
        (Label 'entry)
        (Sub rsp 8) ;; Sub 8 from the stack
        (Mov rax 409) ;; Move #\f (#b110011001) to rax
        (Cmp rax 7) ;; Compare rax to #f (#b111)
        (Je 'l1) ;; jump else branch if #f is equal to #\f
        (Mov rax 84) ;; true branch --> Move 42 (#b1010100) to rax
        (Jmp 'l2) ;; Jump to l2
        (Label 'l1) ;; else branch
        (Mov rax 26) ;; Move 13 (#b11010) to rax
        (Label 'l2) ;; For both branches
        (Sub rax 2) ;; Subtract 1 (#b10) from rax
        (Cmp rax 0) ;; Compare rax to 0
        (Mov rax 7) ;; Mov #f (#b111) to rax
        (Mov r9 3) ;; Mov #t (#b011) to r9
        (Cmove rax r9) ;; False, but conditionally you would move #t (r9) to rax (#f)
        (Add rsp 8) ;; Add 8 to the stack
        (Ret)))

(define (prog-3)
  '(if #\f
    (zero? (sub1 42))
    (zero? (sub1 13))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Program 4
;;

(define is-4
  (list (Global 'entry)
        (Label 'entry)
        (Sub rsp 8) ;; Subtract 8 from the stack
        (Mov rax 200) ;; Move 100 (#b11001000) to rax
        (Sar rax 1) ;; Shift rax right 1 bit to untag integer
        (Sal rax 2) ;; Shift rax left 2 bits to get char encoding
        (Xor rax 1) ;; Apply the char tag to rax for #\d
        (And rax 3) ;; Keep lowest to bits of rax
        (Cmp rax 1) ;; Check if rax has the char tag (#b01) (which is char?)
        (Mov rax 7) ;; Move #f (#b111) to rax
        (Mov r9 3) ;; Move #t (#b011) to r9
        (Cmove rax r9) ;; If #\d (rax) is a character (it is), move #t to rax instead of #f
        (Cmp rax 7) ;; Compare #f to rax
        (Je 'l1) ;; Jump to else branch if rax is #f (it is not)
        (Mov rax 281) ;; True branch --> Move #\F (#0b100011001) to rax
        (Sar rax 2) ;; Remove char tag from rax (#\F)
        (Sal rax 1) ;; Apply integer tag to rax (which is char->integer)
        (Extern 'write_byte) ;; Defining external function write byte to be called
        (Mov rdi rax) ;; Print the byte version of rax (#\F).
        (Call 'write_byte) ;; Calling external function write byte
        (Jmp 'l2) ;; Jump to next step in this branch
        (Label 'l1) ;; Else branch
        (Mov rax 337) ;; Move #\T (#b101010001) to rax
        (Sar rax 2) ;; Remove char tag from rax (#\T) 
        (Sal rax 1) ;; Apply integer tag to rax (which is char->integer)
        (Extern 'write_byte) ;; Defining external function write byte to be called
        (Mov rdi rax) ;; Writing the byte version of rax (#\T)
        (Call 'write_byte) ;; Calling external function write byte
        (Label 'l2) ;; Second part of the true branch (also part of if branch)
        (Mov rax 15) ;; Move Void (#b1111) to rax
        (Cmp rax 11) ;; Compare Eof (#b1011) to rax
        (Mov rax 7) ;; Mov #f (#b111) to rax
        (Mov r9 3) ;; Mov #t (#b011) to r9
        (Cmove rax r9) ;; If Void equal to Eof, return #t else return #f (should be false)
        (Add rsp 8) ;; Add to stack
        (Ret)))

(define (prog-4)
  '(begin
    (if (char? (integer->char 100))
      (write-byte (char->integer #\F))
      (write-byte (char->integer #\T)))
    (eof-object? (void))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Program 5
;;

(define is-5
  (list (Global 'entry)
        (Label 'entry)
        (Sub rsp 8) ;; Subtract 8 from the stack
        (Mov rax 0) ;; Move 0 to rax
        (Sub rax 2) ;; Subtract 1 (#b10) from rax to get -1
        (Add rax 2) ;; Add 1 (#b10) from rax to get 0
        (Cmp rax 0) ;; Compare rax to 0 (true)
        (Mov rax 7) ;; Move #f (#b111) to rax
        (Mov r9 3) ;; Move #t (#b011) to r9
        (Cmove rax r9) ;; If rax is 0, move #t to rax instead of #f (which is true it should have #t)
        (Mov rax 320) ;; Mov 160 (#b101000000) to rax
        (Cmp rax 7) ;; Compare rax to #f (#b111) (which isn't true)
        (Je 'l1) ;; Jump to else branch if rax eq? #f (not true)
        (Mov rax 200) ;; True branch --> Move 100 (#b11001000) to rax
        (Add rax 2) ;; Add 1 (#b10) to rax to get 101
        (Jmp 'l2) ;; Jump to true branch's second part --> return 101 in true branch
        (Label 'l1) ;; Else branch
        (Mov rax 133) ;; Mov #\! (#b10000101) to rax
        (Extern 'write_byte) ;; Define external function write byte
        (Mov rdi rax) ;; write_byte out rax
        (Call 'write_byte) ;; call external function write byte
        (Label 'l2) ;; true branch part 2
        (Add rsp 8) ;; Add 8 to stack
        (Ret)))

(define (prog-5)
  '(begin
      (zero? (add1 (sub1 0)))
      (if 160
        (add1 100)
        (write-byte #\!))))
