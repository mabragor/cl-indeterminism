cl-indeterminism
================

Do some cool stuff with undefined functions and variables

Finding
-------

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


Transforming
------------

Codewalk the form and transform undefined variables and functions in it on the fly to something else.
Has a side effect of expanding all the macro in the form.

        CL-USER> (ql:quickload 'cl-indeterminism)
        CL-USER> (let ((cl-indeterminism:*variable-transformer* (lambda (x) `(quote ,x))))
                   (cl-indeterminism:macroexpand-all-transforming-undefs '(a b c)))
        (A 'B 'C)
        CL-USER> (let ((cl-indeterminism:*function-transformer* (lambda (form)
                                                                   (if (keywordp (car form))
                                                                       (cl-indeterminism:fail-transform)
                                                                       `(,(intern (string (car form)) "KEYWORD")
                                                                         ,@(cdr form))))))
                   (cl-indeterminism:macroexpand-all-transforming-undefs '(a b c)))
        (:A B C)

The API consists of the following ingredients:

  - MACROEXPAND-ALL-TRANSFORMING-UNDEFS - macro, which actually does the transformation.
    Accepts optional keyword :ENV, which can be :NULL or :CURRENT (default) and acts the same as in FIND-UNDEFS.
  - \*VARIABLE-TRANSFORMER\* and \*FUNCTION-TRANSFORMER\* - two variables, initially bound to NIL.
    Each can contain a function, which performs a transformation of undefined variables and functions, respectively.
    When a variable is bound to NIL, varibles/functions are left unchanged.
    When bound to a function, this function is expected to accept one argument, which is a name of a variable
    in case of \*VARIABLE-TRANSFORM\* and whole form of a function in case of \*FUNCTION-TRANSFORM\*.
    The function is expected to return arbitrary lisp-form, which is then also recursively code-walked,
    i.e. all undefined variables and functions in it are also transformed.
    Beware of infinite recursions! (FAIL-TRANSFORM macro helps in these cases, as in example above)
  - FAIL-TRANSFORM - a macro, which can be used inside functions, contained in \*VARIABLE-TRANSFORMER\* and
    \*FUNCTION-TRANSFORMER\*. When invoked, causes transformation to fail, that is function/variable is left
    untouched. Useful to prevent infinite recursions, as in example above, when transformation on
    unknown function is not performed if its name is already a keyword.

I personally plan to use all this machinery in my fork of ESRAP packrat parser (https://github.com/mabragor/esrap).
There, the idea is to transform all undefined variable names inside DEFRULE macro into calls to functions,
which try to continue parsing with help of a rule, corresponding to the name of undefined variable.
Hence, see branch 'liquid' there for examples of usage of MACROEXPAND-ALL-TRANSFORMING-UNDEFS.

TODO:
  - (done) find undefined variables with respect to current lexenv, not null lexenv
    - (done) allow to specify null lexenv
  - (done) macro to manipulate undefined functions and variables conveniently

BUGS:
  - MACROLETs in the enclosing scope are not handled correctly

        CL-USER> (macrolet ((bar (b) nil)) (cl-indeterminism:find-undefs '(bar a)))
        ((:FUNCTIONS) (:VARIABLES A))

    although it should see that variable A is not really there
    (hence, it does not go into the body of BAR). This is due to the limitation of
    CL-CURLEX, where only names of functions, variabes and macros are captured, not their
    definitions.

