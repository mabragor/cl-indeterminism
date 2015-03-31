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

(def layered-method handle-undefined-reference :in find-undefined-references
     :around (type name &key &allow-other-keys)
	      (declare (special undefs))
	      (push name (cdr (assoc (ecase type
				       (:function :functions)
				       (:variable :variables))
				     undefs))))

(defmacro find-undefs (form &key (env :current))
  ;; TODO: variables and functions undefined w.r.t CURRENT lexenv, not NULL lexenv.
  `(cl-curlex:with-current-lexenv
       (let ((undefs (list (list :functions) (list :variables))))
	 (declare (special undefs))
	 (with-active-layers (find-undefined-references)
	   ,(case env
		  (:current `(walk-form ,form :environment (make-walk-environment ,(intern "*LEXENV*"))))
		  (:null `(walk-form ,form))
		  (t `(walk-form ,form :environment (make-walk-environment ,env))))
	   undefs))))


(def (layer e) transform-undefined-references ()
  ())

(defparameter *variable-transformer* nil)
(defparameter *function-transformer* nil)

(define-condition transform-not-handled (condition) ())

(defmacro fail-transform ()
  `(signal 'transform-not-handled))

(def layered-method handle-undefined-reference :in transform-undefined-references
     :around (type name &rest args &key &allow-other-keys)
     (handler-case (ecase type
                     (:function (when *function-transformer*
				  (values (walk-form (funcall *function-transformer* (getf args :form))
						     :parent (getf args :parent)
						     :environment (getf args :environment))
					  t)))
                     (:variable (when *variable-transformer*
				  (values (walk-form (funcall *variable-transformer* name)
						     :parent (getf args :parent)
						     :environment (getf args :environment))
					  t))))
       (transform-not-handled () nil)))

(defmacro with-muffled-unknown-declaration-warns (&body body)
  "KLUDGE to get rid of noize about SBCL's truly dynamic extent declaration"
  `(handler-bind
       ((alexandria:simple-style-warning
	 (lambda (warning)
	   (when (alexandria:starts-with-subseq
	   	  "Ignoring unknown declaration"
		  (simple-condition-format-control warning))
	     (muffle-warning warning)))))
     ,@body))

     
(defmacro macroexpand-all-transforming-undefs (form &key (o!-env :current))
  (let ((g!-env (gensym "G!-ENV")))
    `(let ((,g!-env ,o!-env))
       (cl-curlex:with-current-lexenv
	 (with-active-layers (transform-undefined-references)
	   (with-muffled-unknown-declaration-warns
	       (unwalk-form (walk-form ,form
				       :environment (ecase ,g!-env
						      (:current (make-walk-environment ,(intern "*LEXENV*")))
						      (:null nil))))))))))

(defun macroexpand-cc-all-transforming-undefs (form &key env)
  (with-active-layers (transform-undefined-references)
    (with-muffled-unknown-declaration-warns
      (unwalk-form (walk-form form
			      :environment (if env
					       (make-walk-environment env)
					       nil))))))

(export '(find-undefs macroexpand-all-transforming-undefs
	  macroexpand-cc-all-transforming-undefs
          *variable-transformer* *function-transformer*
          fail-transform))
