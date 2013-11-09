;;;; cl-indeterminism.asd

(asdf:defsystem #:cl-indeterminism
  :serial t
  :version "0.1"
  :description "Find and/or manipulate undefined variables and functions in the form."
  :author "Alexander Popolitov <popolit@gmail.com>"
  :license "GPL"
  :depends-on (#:hu.dwim.walker #:cl-curlex #:defmacro-enhance)
  :components ((:file "cl-indeterminism")
	       (:file "package")))

(defsystem :cl-indeterminism-tests
  :description "Tests for CL-INDETERMINISM."
  :licence "GPL"
  :depends-on (:cl-indeterminism :fiveam)
  :components ((:file "tests")))
