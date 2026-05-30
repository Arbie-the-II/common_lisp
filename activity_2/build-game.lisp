;; 1. Manually boot Quicklisp since we are bypassing the auto-init file
(let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))

;; 2. Load your game code
(load "game.lisp")

(in-package :cl-user)

;; 3. Terminate background helper threads before freezing memory core
(dolist (thread (sb-thread:list-all-threads))
  (unless (eq thread sb-thread:*current-thread*)
    (ignore-errors (sb-thread:terminate-thread thread))))

;; 4. Save the executable image cleanly using a console stream
;; FIX: (intern ...) creates the symbol dynamically, completely bypassing reader package checks!
(sb-ext:save-lisp-and-die "space-invaders.exe" 
                          :toplevel (intern "START-GAME" "SPACE-GAME")
                          :executable t 
                          :compression nil
                          :application-type :console)