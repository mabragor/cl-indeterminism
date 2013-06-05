cl-indeterminism
================

Codewalk the form and find, which variables and functions are undefined.

        CL-USER> (ql:quickload 'cl-indeterminism)
        CL-USER> (cl-indeterminism:find-undefs '(foo bar baz))
        ((:FUNCTIONS FOO) (:VARIABLES BAZ BAR))

Uses profound HU.DWIM.WALKER system to do the heavy lifting of code walking
and is, in fact, just a convenience wrapper around it.

TODO:
  - find undefined variables with respect to current lexenv, not null lexenv
  - macro to manipulate undefined functions and variables conveniently


