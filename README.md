cl-indeterminism
================

Codewalk the form and find, which variables and functions are undefined.

        CL-USER> (ql:quickload 'cl-indeterminism)
        CL-USER> (cl-indeterminism:find-undefs '(foo bar baz))
        ((:FUNCTIONS FOO) (:VARIABLES BAZ BAR))

FIND-UNDEFS is now a macro which expands in the surrounding context, making it possible to
catch undefined variables relative to the current lexenv.

        CL-USER> (let ((a 1)) (cl-indeterminism:find-undefs 'a))
        ((:FUNCTIONS) (:VARIABLES))

Still, one can explicitly specify to find undefs with respect to top-level environment

        CL-USER> (let ((a 1)) (cl-indeterminism:find-undefs 'a :env :null))
        ((:FUNCTIONS) (:VARIABLES A))


Uses profound HU.DWIM.WALKER system to do the heavy lifting of code walking
and is, in fact, just a convenience wrapper around it.

TODO:
  - (done) find undefined variables with respect to current lexenv, not null lexenv
    - (done) allow to specify null lexenv
  - macro to manipulate undefined functions and variables conveniently


