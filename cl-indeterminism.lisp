;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; cl-indeterminism.lisp
;;;
;;; Copyright (c) 2013 by Alexander Popolitov.
;;;
;;; See COPYING for details.

(in-package #:hu.dwim.walker)

(def (layer e) find-undefined-references ()
  ())

(def layered-method handle-undefined-reference :in find-undefined-references :around (type name &key)
	      (declare (special undefs))
	      (push name (cdr (assoc (ecase type
				       (:function :functions)
				       (:variable :variables))
				     undefs))))

(def (layer e) foo-undefined-references ()
  ())

(def layered-method handle-undefined-reference :in foo-undefined-references :around (type name &key)
     (values (ecase type
	       (:function 'foonction)
	       (:variable 'foobariable))
	     t))


(defun foo-undefs (form)
  (with-active-layers (foo-undefined-references)
    (walk-form form)))

(defun find-undefs (form)
  ;; TODO: variables and functions undefined w.r.t CURRENT lexenv, not NULL lexenv.
  (let ((undefs (list (list :functions) (list :variables))))
    (declare (special undefs))
    (with-active-layers (find-undefined-references)
      (walk-form form)
      undefs)))



;; TODO: macro that makes transformation of undefined variables and functions to something else easy.

(export '(find-undefs))
(export '(foo-undefs))
