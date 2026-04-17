# CMSC 430 --- Spring 2026 --- Midterm 2 --- Part 2


## Instructions

In Hoax, we added vectors and strings to our collection of heap-allocated data
structures. For the moment, we're going to focus on vectors.

Your task for this problem is to implement a couple new vector primitives.


### `vector-memq`

```racket
(vector-memq v vec)
; v   : any
; vec : vector?
```

The `vector-memq` operation searches the vector `vec` for an element that is
physically equal (i.e., the way `eq?` works) to the given value `v`. If such an
element is found, its index is returned; otherwise, `#f` is returned instead.

Note that the search must be left-to-right, and the result depends on the
**first** occurrence of the element in the vector.


### `vector-copy!`

```racket
(vector-copy! dest dest-start src)
; dest       : vector?
; dest-start : natural?
; src        : vector?
```

The `vector-copy!` operation copies elements from the `src` vector into the
`dest` vector, starting at the `dest` vector's `dest-start` index. If the copy
goes through, the `dest` vector is modified in-place and the void value is
returned.

This operation takes bounds checking pretty seriously.`If:

  * the `dest-start` index is outside the bounds of the `dest` vector, or

  * the length of `src` plus the `dest-start` index is outside the bounds of the
    `dest` vector

an error is raised with no elements copied.


## Grading

This problem is worth 20 points:

  * 10 points for implementing `vector-memq`.
  * 10 points for implementing `vector-copy!`.


## Notes

  * We've left a number of examples as tests in `hoax/test/test-runner.rkt`.

  * These functions should work like their Racket counterparts. When in doubt,
    we recommend looking at the Racket documentation and using the Racket REPL
    for guidance.
