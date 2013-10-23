;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; tests.lisp -- tests for CL-INDETERMINISM
;;;
;;; Copyright (c) 2013 by Alexander Popolitov.
;;;
;;; See COPYING for details.


(in-package :cl-user)

(defpackage :cl-indeterminism-tests
  (:use :cl :cl-indeterminism :hu.dwim.walker :fiveam)
  (:export #:run-tests))

(in-package :cl-indeterminism-tests)

(def-suite indeterminism)
(in-suite indeterminism)

(defun run-tests ()
  (let ((results (run 'indeterminism)))
    (fiveam:explain! results)
    (unless (fiveam:results-status results)
      (error "Tests failed."))))

(test basic
      (is (equal '((:functions foo) (:variables baz bar))
		 (find-undefs '(foo bar baz))))
      (is (equal '((:functions foo) (:variables))
		 (let ((bar 1) (baz 2)) (declare (ignore bar baz)) (find-undefs '(foo bar baz)))))
      (is (equal '((:functions foo) (:variables baz bar))
		 (let ((bar 1) (baz 2)) (declare (ignore bar baz)) (find-undefs '(foo bar baz) :env :null)))))

(test transformation-on-the-fly
  (is (equal '(:a 'b 'c)
             (let ((*variable-transformer* (lambda (x) `(quote ,x)))
                   (*function-transformer* (lambda (x) (if (keywordp (car x))
                                                           (fail-transform)
                                                           `(,(sb-int:keywordicate (car x)) ,@(cdr x))))))
               (macroexpand-all-transforming-undefs '(a b c))))))
