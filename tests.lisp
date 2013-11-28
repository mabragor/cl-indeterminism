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
                                                           `(,(intern (string (car x)) "KEYWORD") ,@(cdr x))))))
               (macroexpand-all-transforming-undefs '(a b c))))))

(test transformation-on-the-fly-nontriv-lexenv
  (is (equal '(a b 'c) (let ((*variable-transformer* (lambda (x) `(quote ,x))))
			 (let ((b 1))
			   (macroexpand-all-transforming-undefs '(a b c)))))))
			     

(defmacro autoquoter (form)
  (let ((*variable-transformer* (lambda (x) `(quote ,x))))
    (macroexpand-cc-all-transforming-undefs form)))

(defun autoquoter-1 ()
  (autoquoter (list b c)))

(defun autoquoter-2 ()
  (let ((b 1))
    (autoquoter (list b c))))


(test cc-transformation-on-the-fly
  (is (equal '(b c) (autoquoter-1)))
  (is (equal '(1 c) (autoquoter-2))))
