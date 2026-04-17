# CMSC 430 --- Spring 2026 --- Midterm 2 --- Part 6


## Instructions

This problem has two sub-parts: one for the interpreter, and one for the
compiler. Both parts relate to the same topic, which is described below.


### Patterns of Disjunction

Students at a rival school have stolen our Knock compiler and tried to implement
a new pattern: `or`. However, something is wrong with their implementation.
Fortunately, we were able to extract a copy of their latest code so we can
correct the mistake and use it for our own purposes. Unfortunately, we have no
idea what the problem is.

An `or` pattern is like an `and` pattern: it has sub-patterns that it processes
in order. However, as the name suggests, an `or` pattern succeeds if _any_ of
its sub-patterns succeeds.

The `or` pattern the rival students have implemented has the shape `(or p1 p2)`,
i.e., it has exactly two sub-patterns. The intended semantics of this pattern
are that it first tries to match sub-pattern `p1`; if the match succeeds,
nothing else is done. If `p1` fails to match, sub-pattern `p2` is tried instead.

In this implementation, as in Racket, the sub-patterns of the `or` **must bind
the same pattern variables**. So `(or x x)` is fine, as is `(or x (cons _ x_))`,
but `(or x y)` will not work. **This is enforced by the parser.**

Unlike Racket, this implementation has an additional restriction **which is not
in the scope of your tasks:** the variables must be bound in the same order. So
`(or (cons x y) (and x y))` is fine, but `(or (cons x y) (and y x))` will not
work. **This is also enforced by the parser.**

Consider the following examples:

  * `(or x (cons 1 x))` matches anything trivially, because the first
    sub-pattern `x` will always match and bind to the data being matched.

  * `(or (cons 1 x) (cons 2 x))` will match a pair whose first element is either
    `1` or `2`, and it will bind the variable `x` to the second element of
    whichever pair matches.

  * `(or (box x) (cons x _))` will match either a box or a pair, and it will
    bind the pattern variable `x` to either the contents of the box or the first
    element of the pair, respectively.


### Compiler

Your task for this part is to examine the new compiler code in
`knock/compile.rkt` and perform three actions:

  1. In `answer.rkt`, you should explain in your own words what the problem is.

  2. In `answer.rkt`, you should write an S-expression representing a Knock
     program that demonstrates the bug.

  3. In `knock/compile.rkt`, you should fix the bug so the behavior is correct.

You will find that the rival students added a couple tests to
`knock/test/test-runner.rkt` and all of their tests pass. It seems likely that
adding additional tests would be beneficial.

Other than that, we've only added a TODO comment above the buggy code in
`knock/compile.rkt` to get you going.


### Interpreter

While we were able to extract the rival students' compiler, we could not get
hold of their interpreter --- if they even had one. As all good compiler
engineers know, one of the best ways to help ensure a bug-free implementation is
to also implement the semantics of your features in a higher-level host language
through an interpreter, so it falls to you to implement `or` patterns in the
interpreter.

We've gone ahead and added a small stub with a TODO comment to point you in the
right direction.


## Grading

This problem is worth 20 points:

  * 5 points for your explanation.
  * 5 points for a program that demonstrates the bug.
  * 5 points for fixing the broken compiler code.
  * 5 points for implementing `or` patterns in the interpreter.


## Notes

  * As noted above, Racket's `or` pattern requires that the subordinate patterns
    must bind the exact same set of variables. This is enforced by the updated
    parser.

  * As noted above, Racket's `or` allows the variables to occur in any order
    between the two branches, but this would make managing the compile-time
    environment essentially impossible with our current set-up. Instead of
    making the exam more fun and interesting, we have opted to guarantee for you
    that the variables in both branches --- which are already guaranteed to be
    the same! --- must also occur in the same order. This property is also
    enforced by the parser in our rivals' code, so they must have made the same
    decision.

  * We have not added any new tests other than those we found in the rival
    students' code. We recommend you write more tests of your own.
