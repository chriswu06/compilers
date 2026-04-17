# CMSC 430 --- Spring 2026 --- Midterm 2 --- Part 5


## Instructions

In Hustle, we started implementing heap-allocated data structures, namely boxes
and pairs. Unfortunately, we didn't implement very many operations on these
kinds of data. This tragedy cannot stand!

Your task for this problem is to implement a couple new list primitives.


### `list-ref`

```racket
(list-ref lst n)
; lst : list?
; n   : natural?
```

The `list-ref` operation retrieves the element in list `lst` at index `n`. If
the index is out of bounds, an error is raised.

Note that the list argument does not have to be a _proper list_ (see below); it
needs only to have enough `cons` cells that the given index can be connected to
the `car` of a pair. In other words, `(list-ref (cons #\a (cons #\b #\c)) 1)`
would return `#\b`, even though the list is improper.


### `memq`

```racket
(memq v lst)
; v   : any
; lst : list?
```

The `memq` operation attempts to find an element `v` in a given list `lst` using
physical equality for comparison (i.e., the way `eq?` works). If a matching
element is found, the tail of the list starting with that element is returned;
otherwise, `#f` is returned. Note that the search must be left-to-right, and the
result depends on the **first** occurrence of the matching element in the list
(if there are multiple).


#### Extra Credit

Racket's implementation of `memq` checks that the second argument is a proper
list (see below), but for this problem you don't have to worry about that.
However, if you want a few points of extra credit on your exam, you can
implement this check to conform with Racket's behavior.


## Proper Lists

Racket defines a _proper list_ as either the empty list value `'()` or a pair
(`cons`) whose second element is a list. For example, `(cons 1 (cons 2 '()))` is
a proper list, but `(cons #\a (cons #\b #\c))` is not.


## Grading

This problem is worth 20 points:

  * 10 points for implementing `list-ref`.
  * 10 points for implementing `memq` for improper lists.
  * (Extra credit) 3 points for restricting `memq` to proper lists.


## Notes

  * We've left a number of examples as tests in `hustle/test/test-runner.rkt`.

  * These functions should work like their Racket counterparts. When in doubt,
    we recommend looking at the Racket documentation and using the Racket REPL
    for guidance.
