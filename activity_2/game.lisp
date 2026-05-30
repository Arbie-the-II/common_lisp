(defpackage :space-game
  (:use :cl)
  (:export :start-game))

(in-package :space-game)

;; --- CONSTANTS & CONFIGURATION ---
(defparameter *width* 40)
(defparameter *height* 20)

;; --- ANSI ESCAPE COLOR CODES ---
(defconstant +reset+   (format nil "~C[0m"  #\Esc))
(defconstant +red+     (format nil "~C[31m" #\Esc))
(defconstant +green+   (format nil "~C[32m" #\Esc))
(defconstant +yellow+  (format nil "~C[33m" #\Esc))
(defconstant +blue+    (format nil "~C[34m" #\Esc))
(defconstant +cyan+    (format nil "~C[36m" #\Esc))

;; --- GAME STATE ---
(defparameter *player-x* 20)
(defparameter *bullets* nil)
(defparameter *invaders* nil)
(defparameter *invader-dir* 1)
(defparameter *score* 0)
(defparameter *game-over* nil)

;; --- LOW-LEVEL WINDOWS INPUT HOOKS (NON-BLOCKING) ---
#+sbcl
(sb-alien:define-alien-routine ("_kbhit" kbhit) sb-alien:int)
#+sbcl
(sb-alien:define-alien-routine ("_getch" getch) sb-alien:int)

(defun read-keyboard-input ()
  #+sbcl
  (if (/= (kbhit) 0)
      (let ((ch (getch)))
        (cond ((= ch 97)  :left)
              ((= ch 100) :right)
              ((= ch 32)  :space)
              ((= ch 113) :quit)
              (t nil)))
      nil)
  #-sbcl nil)

;; --- GAME LOGIC ENGINE ---

(defun init-game ()
  (setf *player-x* 20
        *bullets* nil
        *score* 0
        *game-over* nil
        *invader-dir* 1
        *invaders* nil)
  (dotimes (row 3)
    (dotimes (col 6)
      (push (cons (+ 10 (* col 4)) (+ 2 row)) *invaders*))))

(defun update-game ()
  (setf *bullets* (delete-if (lambda (b) (<= (cdr b) 0))
                             (mapcar (lambda (b) (cons (car b) (1- (cdr b)))) *bullets*)))
  (let ((shift-down nil)
        (move-tick (zerop (mod (get-internal-real-time) 4))))
    (when move-tick
      (dolist (inv *invaders*)
        (let ((next-x (+ (car inv) *invader-dir*)))
          (when (or (<= next-x 0) (>= next-x (1- *width*)))
            (setf shift-down t))))
      (if shift-down
          (progn
            (setf *invader-dir* (- *invader-dir*))
            (setf *invaders* (mapcar (lambda (inv) (cons (car inv) (1+ (cdr inv)))) *invaders*)))
          (setf *invaders* (mapcar (lambda (inv) (cons (+ (car inv) *invader-dir*) (cdr inv))) *invaders*)))))
  (dolist (bullet *bullets*)
    (let ((hit (find-if (lambda (inv) (and (= (car bullet) (car inv)) (= (cdr bullet) (cdr inv)))) *invaders*)))
      (when hit
        (setf *invaders* (remove hit *invaders*))
        (setf *bullets* (remove bullet *bullets*))
        (incf *score* 100))))
  (dolist (inv *invaders*)
    (when (>= (cdr inv) (1- *height*))
      (setf *game-over* t)))
  (unless *invaders*
    (setf *game-over* :win)))

;; --- CLI RENDERING ENGINE ---

(defun clear-screen ()
  (format t "~C[H" #\Esc)
  (finish-output))

(defun render-frame ()
  (clear-screen)
  (format t "~A==========================================~%~A" +cyan+ +reset+)
  (format t " SCORE: ~A~,5D~A       Controls: A=Left, D=Right, Space=Fire, Q=Quit~%" +yellow+ *score* +reset+)
  (format t "~A==========================================~%~A" +cyan+ +reset+)

  (dotimes (y *height*)
    (format t "~A|~A" +blue+ +reset+)
    (dotimes (x *width*)
      (cond
        ((and (= y (1- *height*)) (= x *player-x*)) 
         (format t "~AA~A" +green+ +reset+))
        ((member (cons x y) *bullets* :test #'equal) 
         (format t "~A|~A" +yellow+ +reset+))
        ((member (cons x y) *invaders* :test #'equal) 
         (format t "~AV~A" +red+ +reset+))
        (t (format t " "))))
    (format t "~A|~A~%" +blue+ +reset+))
  
  (format t "==========================================~%")
  (finish-output))

;; --- MAIN RUNTIME GAME LOOP ---

(defun start-game ()
  (format t "~C[2J" #\Esc)
  (init-game)
  (loop
    (let ((input (read-keyboard-input)))
      (case input
        (:left  (setf *player-x* (max 0 (1- *player-x*))))
        (:right (setf *player-x* (min (1- *width*) (1+ *player-x*))))
        (:space (push (cons *player-x* (- *height* 2)) *bullets*))
        (:quit  (return)))
      (update-game)
      (render-frame)
      (cond 
        ((eq *game-over* t)
         (format t "~%~AGA GAME OVER! The invaders reached Earth.~A~%" +red+ +reset+)
         (return))
        ((eq *game-over* :win)
         (format t "~%~A?? VICTORY! You saved the galaxy! ??~A~%" +green+ +reset+)
         (return)))
      (sleep 0.03))))