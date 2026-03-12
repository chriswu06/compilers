# CMSC 430 --- Spring 2026 --- Midterm 1 --- Part 2


## Instructions

In our discussion of Fraud, we talked about _environments_, which let us keep
track of variables that are currently in-scope and their values. Consider the
occurrence of the variable `y` below:

```racket
(let ([x 1])
  (let ([y 2])
    (let ([z 3])
      y)))        ;; <-- This is the variable occurrence.
```

At the time that the occurrence of the variable `y` is evaluated, we know that
the environment will consist of three bindings: one for `x`, one for `y`, and
one for `z`.

For this problem, you are tasked with writing a function to compute the maximum
length of the environment for a given Fraud program:

```racket
;; Expr -> Non-Negative Integer
(define (max-env-length e)
  ;; TODO
  0)
```

Some examples:

  - Returns 3:

    ```racket
    (max-env-length
      (parse
        '(let ([x 1])
          (let ([y 2])
            (let ([z 3])
              y)))))
    ```

  - Returns 2:

    ```racket
    (max-env-length
      (parse
        '(begin (let ([x 1]) x)
                (let ([y 2])
                  (let ([z 3])
                    y)))))
    ```

  - Returns 0:

    ```racket
    (max-env-length
      (parse '42))
    ```

For this problem, you are given:

  - `ast.rkt`, which contains the (unmodified) AST definition for Fraud.

  - `length.rkt`, which includes a stub of the `max-env-length` function.

  - `parse.rkt`, which includes the (unmodified) parser for Fraud. This is
    provided so it's easy to write concrete examples. You do not need to use or
    modify the parser.


## Notes

  - You may write any helper function you think will be useful (which is always
    true!). You may **not** modify the signature of the `max-env-length`
    function, or else the autograder will not work properly.

  - The examples above are given as tests within the `length.rkt` file. You can
    run these tests with `raco test length.rkt`.
