# CMSC 430 PRACTICE Midterm 1, Part 5


## Instructions

Many programming languages have looping constructs like `while` loops, yet none
of the languages we've built have such a feature. Let's fix that.

You are given a modified version of the Evildoer language which has been
extended with an `until` loop form (a close cousin of the common `while` loop).

Concretely:

  - `(until e0 e1)` first evaluates `e0`.

  - If the result of `e0` is `#f`, then `e1` is evaluated and the `until` loop
    repeats, causing `e0` and `e1` to be re-evaluated until `e0` produces a
    non-`#f` value.

  - If the result of `e0` is not `#f`, then evaluation of the `until` completes.
    The result is the most recent value of `e1` if there is one; otherwise, the
    result is the void value.

Some examples;

  - `(until (eof-object? (peek-byte)) (write-byte (read-byte)))`: copies bytes
    from the input stream to the output stream until encountering the
    end-of-file marker.

  - `(until (eof-object? (peek-byte)) (read-byte))`: consumes all available
    bytes until the end-of-file marker and returns the last byte (or void if
    there are no bytes available).

  - `(until (if (eof-object? (peek-byte)) #t (zero? (read-byte))) 0)` consumes
    all bytes up to and including the first `0` byte or the end-of-file marker
    and returns `0` (or void if there are no such bytes).

  - `(until #t 0)` evaluates to the void value.

  - `(until #f (write-byte 97))` writes an infinite sequence of the byte 97 to
    the output stream, never terminating.

The AST, parser, and interpreter have all been extended to specify the behavior
of `until`. The compiler has been stubbed and you must complete the
implementation of `until`. A few tests have been included.

NOTE: The `until` loop form is *not* an expression form in Racket, so you will
not be able to try examples in Racket. However, you can use the provided
modified interpreter.
