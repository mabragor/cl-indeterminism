;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; tests.lisp -- tests for CL-INDETERMINISM
;;;
;;; Copyright (c) 2013 by Alexander Popolitov.
;;;
;;; See COPYING for details.


(in-package :cl-user)

(defpackage :cl-indeterminism-tests
  (:use :cl :cl-indeterminism :hu.dwim.walker :eos)
  (:export #:run-tests))

(in-package :cl-indeterminism-tests)

(def-suite indeterminism)
(in-suite indeterminism)

(defun run-tests ()
  (let ((results (run 'indeterminism)))
    (eos:explain! results)
    (unless (eos:results-status results)
      (error "Tests failed."))))

(test basic
      (is (equal '((:functions foo) (:variables baz bar))
		 (find-undefs '(foo bar baz))))
      (is (equal '((:functions foo) (:variables))
		 (let ((bar 1) (baz 2)) (declare (ignore bar baz)) (find-undefs '(foo bar baz)))))
      (is (equal '((:functions foo) (:variables baz bar))
		 (let ((bar 1) (baz 2)) (declare (ignore bar baz)) (find-undefs '(foo bar baz) :env :null)))))


