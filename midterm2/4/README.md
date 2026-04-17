# CMSC 430 --- Spring 2026 --- Midterm 2 --- Part 4


## Instructions

You've been provided a modified implementation of the Iniquity language that was
presented in class.

One observation about Iniquity that we made in class was that it is possible to
**syntactically** check if a program always calls functions with the appropriate
number of arguments.

For example, in the Iniquity program:

```racket
#lang racket
(define (f x y) x)
(f 100)
```

We can see that the application of `f` to `100` provides too few arguments.

The provided code updates the parser so that `parse` and `parse-closed` now call
a new function, `correct-arity?`, and raise an error if it returns `#f`; the
parsing functions return the program unchanged otherwise. This `correct-arity?`
function is implemented in a new file, `arity.rkt`. The function takes a `Prog`
as input, and should descend over its structure to determine whether every
application of each defined function has the correct number of arguments.

There is a small stub provided for `correct-arity?` in the `arity.rkt` file, but
you must complete the implementation of it.


## Hints

  * The AST definition in `ast.rkt` will be helpful, since it defines the shape
    of `Prog`, `Defn`, and expression structs, which you will need to write a
    working recursion over the program's structure.

  * Don't worry about performance too much: it's okay to process the same data
    multiple times. Any solution that is linear in the number of function
    definitions should have absolutely no problem running within Gradescope's
    time and memory constraints. (And if it's a bit less efficient than that,
    it's probably also fine, so DO NOT FOCUS ON PERFORMANCE.)


## Grading

This problem is worth 20 points.


## Notes

  * We have not added any new tests.

  * For a program to pass `correct-arity?` **every** application must have the
    correct number of arguments, even if an application is unreachable. For
    example, this program, when parsed and given to `correct-arity?` should
    produce `#f` even though there is no possibility of a run-time arity error.

    ```racket
    #lang racket
    (define (f x y) x)
    (if #f (f 100) (f 1 2))
    ```

  * Any program that applies an undefined function has an arity error because
    you cannot determine what the appropriate number of arguments should be. For
    example, this program should cause `correct-arity?` to produce `#f`:

    ```racket
    #lang racket
    (f 100)
    ```
