# CMSC 430 PRACTICE Midterm 1, Part 6


## Instructions

In our discussion of Fraud, we noted that to be a well-formed Fraud program, an
expression must not only follow the grammar of Fraud, but additionally the
expression must be *closed*, i.e., it must not contain any occurrences of free
variables. A free variable occurrence is one that occurs in a scope without a
binding.

For this problem, you've been given the AST definition for Fraud and you are
asked to write a function `closed?` that computes whether a given Fraud
expression is closed.

For example:

  - The expression `(Var 'x)` is not closed.
  - The expression `(Let 'x (Lit 0) (Lit 1))` is closed.
  - The expression `(Let 'x (Lit 0) (Var 'x))` is closed.

Update the code for `closed?` in `ast.rkt` to implement this function.

NOTE: You are allowed to add new helper functions if you like, but the signature
of the `closed?` function must remain the same for the autograder to work.
