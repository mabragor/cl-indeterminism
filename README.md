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

Note: if your implementation is not supported by HU.DWIM.WALKER or CL-CURLEX,
then branch "without-curlex" is for you - there initial unsophisticated behaviour
 of the system is fixed forever.

TODO:
  - (done) find undefined variables with respect to current lexenv, not null lexenv
    - (done) allow to specify null lexenv
  - macro to manipulate undefined functions and variables conveniently

BUGS:
  - MACROLETs in the enclosing scope are not handled correctly

        CL-USER> (macrolet ((bar (b) nil)) (cl-indeterminism:find-undefs '(bar a)))
        ((:FUNCTIONS) (:VARIABLES A))

    although it should see that variable A is not really there
    (hence, it does not go into the body of BAR). This is due to the limitation of
    CL-CURLEX, where only names of functions, variabes and macros are captured, not their
    definitions.

