;; 1. Manually boot Quicklisp since we are bypassing the auto-init file
(let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))

;; 2. Load your app
(load "app.lisp")

(in-package :cl-user)

;; 3. Terminate background helper threads before freezing memory
(dolist (thread (sb-thread:list-all-threads))
  (unless (eq thread sb-thread:*current-thread*)
    (ignore-errors (sb-thread:terminate-thread thread))))

;; 4. Save the executable image cleanly WITHOUT compression
;; Save the executable image cleanly
(sb-ext:save-lisp-and-die "my-gui-app.exe" 
                          :toplevel #'my-gui-app:start-app 
                          :executable t 
                          :compression nil
                          :application-type :console) ; <-- Changed back to console
