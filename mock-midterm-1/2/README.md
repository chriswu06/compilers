# CMSC 430 PRACTICE Midterm 1, Part 2


## Instructions

You've been provided a file `instr.rkt` that contains a definition of
instructions `is`. Update the definition to solve the following problem.

Suppose that the `rax` register holds the encoding of a character value `c1` and
the `rbx` register holds the encoding of a character value `c2`. Both encodings
use the Dodger encoding of characters.

Write a sequence of instructions that when executed will leave the encoding of
the result of evaluating `(char<? c1 c2)` in the `rax` register. Note that
`char<?` produces `#t` whenever the Unicode codepoint of `c1` is less than that
of `c2`.

So for example, if `rax` held the encoding of `#\a` and `rbx` held the encoding
of `#\b`, then after executing the instructions `is`, the encoding of `#t`
should be in `rax`.
