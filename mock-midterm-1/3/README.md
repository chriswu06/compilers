# CMSC 430 PRACTICE Midterm 1, Part 3


## Instructions

You've been provided an implementation of Evildoer as presented in class.

Your job is to implement two new expression forms:

  - `(when e1 e2)`
  - `(unless e1 e2)`

The expressions evaluate as follows:

  - `(when e1 e2)` evaluates `e1`.

    * If `e1`'s value is true, i.e. any value other than `#f`, then `e2` is
      evaluated and its value is the value of the entire `when` expression.

    * If `e1`'s value is `#f`, then `e2` is *not* evaluated and the entire
      `when` expression evaluates to the void value.

  - `(unless e1 e2)` evaluates `e1`.

    * If `e1`'s value is true, i.e. any value other than `#f`, then `e2` is not
      evaluated and the entire `unless` expression evaluates to the void value.

    * If `e1`'s value is `#f`, then `e2` is evaluated and its value is the value
      of the entire `unless` expression.

The AST type definition, parser, and interpreter have been updated to implement
these new forms, and a stub has been added to the compiler. You must finish the
implementation in the compiler.

Note: there are only a few `when` and `unless` tests included, so you consider
writing some of your own.
