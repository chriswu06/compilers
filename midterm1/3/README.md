# CMSC 430 --- Spring 2026 --- Midterm 1 --- Part 3


## Instructions

So far, we have focused on writing compilers in Racket that generate assembly
code. Sometimes it is useful to work in the opposite direction, e.g., for the
purpose of debugging.

For this problem, you must _de_-compile some given compiled programs.

You are provided with the Evildoer compiler as presented in class. In addition,
there is a file named `decompile.rkt`. In this file, you will find sequences of
instructions that were produced by an Evildoer compiler, except that all its
label names are stripped of useful information.

You are tasked with filling in the corresponding slots in that file with an
Evildoer program that will produce the same output (but the label names are not
considered important).

Here is an example of the format:

```racket
;; in [decompile.rkt]

(define is-1
  (list (Global 'entry)
        (Label 'entry)
        (Sub rsp 8)
        (Mov rax 2)
        (Add rax 2)
        (Add rsp 8)
        (Ret)))

(define (prog-1)
  ;; TODO
  '#f)
```

To answer the question, you replace the quoted program fragment `'#f` with the
(quoted) concrete representation of an Evildoer program that would compile to an
equivalent sequence of instructions. In this case:

```racket
(define (prog-1)
  '(add1 1))
```


## Notes

  - We will not compare label names for equivalence, but they must be used
    consistently between the programs. In other words, it does not matter if one
    Evildoer compiler generates the label `'if1234` and another `'if9876`, so
    long as that label is used consistently in the programs.
