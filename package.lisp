;;;; package.lisp

(defpackage #:cl-indeterminism
  (:use #:cl #:hu.dwim.walker)
  (:export #:find-undefs #:macroexpand-all-transforming-undefs
	   #:macroexpand-cc-all-transforming-undefs
           #:*variable-transformer* #:*function-transformer*
           #:fail-transform))
  

