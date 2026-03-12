# CMSC 430 --- Spring 2026 --- Midterm 1 --- Part 6


## Instructions

In assignment 3, we implemented the `cond` form on top of Dupe. A key element of
this implementation lay in Racket's notion of _truthiness_: the concept that any
value that isn't `#f` is considered "true" when used in conditional forms like
`if` and `cond`. We've decided we're sick of "truthiness" and want the
implementation of conditionals to only work for the Boolean values `#t` and `#f`
directly.

For this problem, you've been provided a modified implementation of the Extort
language presented in class, which has been extended with a correct (but truthy)
implementation of `cond`. In addition, because `cond` does all the work of `if`,
we've removed the native `if` implementation; the parser now parses `if`
expressions as `Cond` AST nodes. Remove the truthiness by restricting `cond` to
only accept Boolean-returning values and error for anything else. The parser and
interpreter have been updated for you; you only need to update the compiler.


## Notes

  - The normal Extort tests have been provided, which were written assuming a
    truthy implementation. You are encouraged to update these tests according to
    the new notion of correctness, and you may want to write more tests of your
    own, but you will not be graded on them.

  - The evaluation order for this `cond` expression should be the same as that
    for the `cond` in assignment 3.
