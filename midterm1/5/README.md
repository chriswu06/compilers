# CMSC 430 --- Spring 2026 --- Midterm 1 --- Part 5


## Instructions

In Evildoer, we added sequenced operations with the `begin` form, which
evaluates two expressions and returns the result of the second one. Racket also
supports another sequencing operation, called `begin0`, which evaluates
expressions and returns the result of the _first_ one.

Your job is to implement `begin0` --- but there's a catch.

You've been provided an implementation of Evildoer that has been modified:

  - We have generalized `begin` to sequence **one or more** sub-expressions,
    i.e., the syntax is now `(begin e1 ... en)`. This is implemented in the
    parser, the interpreter, and the compiler.
  - The parser and interpreter have been extended to implement `begin0` to
    handle one or more sub-expressions.
  - A stub for `compile-begin0` has been added to the compiler. You should write
    your implementation here.

As a result, you must implement the compiler for a `begin0` expression that
handles one or more sub-expressions:

  - The syntax is `(begin0 e0 e1 ...)`.
  - The arguments are evaluated from left to right.
  - The value of the whole `begin0` expression is the value of `e0`.


## Examples

```racket
;; Evaluates to [1] and prints ["a"].
(begin0 1 (write-byte 97))

;; Evaluates to [2] and prints ["ab"].
(begin0 2 3 (write-byte 97) (write-byte 98))
```


## Notes

  - There is a critical consideration in implementing `begin0`: its
    sub-components are _expressions_, so `begin0` forms can nest.

  - Because the non-initial sub-expressions' values are not returned,
    side-effecting operations like `write-byte` are the best way to test.

  - Although Racket's `begin` and `begin0` forms permit zero sub-expressions
    (i.e., `(begin)` and `(begin0)`), ours require at least one.
