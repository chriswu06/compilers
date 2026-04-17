# CMSC 430 --- Spring 2026 --- Midterm 2 --- Part 3


## Instructions

In the `hoax/` subdirectory of this problem, you are provided with the
unmodified implementation of the Hoax language as presented in class. In the
`questions/` subdirectory, you will find the files in which to write your
answers.

Your task for this problem is to take Hoax programs and answer questions about
how memory would be laid out while executing them.


## Example

The following code-fenced text demonstrates a simple example of the question
format. Imagine this was written in a file `questions/0.rkt`:

```racket
#lang racket

(provide answer)

;; Consider the following Hoax program:
;;
#;   (let ([b (box 42)])
       HERE)
;;
;; Select the memory diagram below that best corresponds to how you would expect
;; memory to look JUST BEFORE the `HERE` variable would be executed.
;;
;; TODO: Replace the empty string with one of the options "A" or "B".
(define (answer) "")

(define A #<<OPTION-A

+-------------+
| 0x0101  box |
+-------------+ 0xff08  <--- rsp
|             |
+-------------+ 0xff00
//    ...    //
//    ...    //
//    ...    //
+-------------+ 0x0110
|             |
+-------------+ 0x0108  <--- rbx
| 0x02a0   42 |
+-------------+ 0x0100

OPTION-A
  )

(define B #<<OPTION-B

+-------------+
| 0x0109  box |
+-------------+ 0xff08
|             |
+-------------+ 0xff00
//    ...    //
//    ...    //
//    ...    //
+-------------+ 0x0118
|             |
+-------------+ 0x0110  <--- rbx
| 0x0101  box |
+-------------+ 0x0108
| 0x02a0   42 |
+-------------+ 0x0100

OPTION-B
  )
```

Your job is to replace the empty string `""` under the TODO with the string
representation of one of the values in the `options` list, which is either `"A"`
or `"B"` in this case.

If we look at the code in the header comment, we see that we would expect our
memory diagram to have the following characteristics:

  * A box-tagged pointer should be on the stack, corresponding to variable `b`.

  * The box-tagged pointer should point somewhere in the heap where `42` is
    stored.

  * We know nothing else of the surrounding code that may exist.

Taking this into account, memory diagram A seems the better option: it shows
only a single value on the heap, and a box-tagged pointer points to it. To
indicate A is our choice, we would replace the `""` with `"A"` as below:

```racket
(define (answer) "A")
```


## Reading the Memory Diagrams

For this problem, memory diagrams take a particular shape so that we can label
and discuss any relevant part.

Consider memory diagram A from the example above. In this diagram, we see:

  * Memory laid out vertically, with each word (8 bytes) grouped as visual
    boxes, each with their base (lowest) address labeled to the bottom-right.

  * The stack growing from the top down, i.e., from high addresses towards low
    addresses. The stack pointer `rsp` is labeled, pointing to the _bottom_ of
    the word of memory to which it points.

  * The heap growing from the bottom up, i.e., from low addresses towards high
    addresses. The heap pointer `rbx` is labeled, pointing to the _bottom_ of
    the word of memory to which it points.

  * Some garbage in between the stack and heap, annotated with ellipses `...`.

  * The value `42` is written in the lowest box, indicating that it has been
    stored on the heap. The hex representation is shown on the left of the box,
    and the decoded representation on the right.

  * The box value that results from the evaluation of `(box 42)` is on top of
    the stack. Like the `42`, we have the hex encoding on the left, but just the
    word `box` on the right. The hex encoding is `0x0101`, which we can
    interpret as `(OR 0x0100 0x0001)`, i.e., it's the result of combining the
    address `0x0100` and the box type tag `0x0001`.


## Grading

This problem is worth 20 points, 5 for each sub-part in `questions/`.


## Notes

  * A correct answer is a string containing exactly one character.
