(ql:quickload :ltk)

(defpackage :my-gui-app
  (:use :cl :ltk)
  (:export :start-app))

(in-package :my-gui-app)

;; --- RETAIL INVENTORY DATA ---
(defparameter *inventory* '(("Espresso" 3.50 "espresso.gif")
                            ("Caffe Latte" 4.25 "caffe_latte.gif")
                            ("Croissant" 3.75 "croissant.gif")
                            ("Muffin" 3.50 "muffin.gif")
                            ("Green Tea" 3.00 "green_tea.gif")
                            ("Iced Coffee" 4.00 "iced_coffee.gif")))

;; --- SYSTEM STATE VARIABLES ---
(defparameter *tax-rate* 0.08)
(defparameter *cart* nil)
(defparameter *subtotal* 0.0)

(defun update-totals ()
  (setf *subtotal* (reduce #'+ (mapcar #'cdr *cart*)))
  (let* ((tax (* *subtotal* *tax-rate*))
         (total (+ *subtotal* tax)))
    (values *subtotal* tax total)))

;; --- MAIN GUI APPLICATION ---
(defun start-app ()
  (with-ltk ()
    (wm-title *tk* "Lisp Graphic POS Terminal")
    (setf (geometry *tk*) "900x650") ; Expanded width slightly to make room for grid & text
    
    (on-close *tk* (lambda () 
                     (setf *cart* nil)
                     (exit-wish)))

    ;; --- RESPONSIVE ROOT WINDOW CONFIGURATION ---
    (grid-columnconfigure *tk* 0 :weight 1)
    (grid-rowconfigure *tk* 2 :weight 1)

    ;; --- MAIN LOGO BANNER SETUP ---
    (let* ((app-dir (or (uiop:pathname-directory-pathname (uiop:argv0))
                        *default-pathname-defaults*))
           (header-frame (make-instance 'frame :master *tk*))
           (logo-label (make-instance 'label :master header-frame))
           (header-text (make-instance 'label :master header-frame :text "LISP POS SYSTEM" :font "Arial 14 bold")))
      
      (let ((main-logo-path (namestring (merge-pathnames "logo.gif" app-dir))))
        (when (probe-file main-logo-path)
          (let ((img (make-image)))
            (image-load img main-logo-path)
            (configure logo-label :image img)
            (pack logo-label :side :left :padx 10))))

      (pack header-text :side :left :padx 5)
      (grid header-frame 0 0 :pady 10)

      ;; --- SPLIT WINDOW PANELS ---
      (let* ((content-frame (make-instance 'frame :master *tk*))
             (menu-frame (make-instance 'labelframe :master content-frame :text " Quick-Select Menu Tiles "))
             (receipt-frame (make-instance 'labelframe :master content-frame :text " Current Order Receipt "))
             
             (cart-listbox (make-instance 'listbox :master receipt-frame :width 35))
             (lbl-subtotal (make-instance 'label :master receipt-frame :text "Subtotal: $0.00" :font "Arial 10"))
             (lbl-tax (make-instance 'label :master receipt-frame :text "Tax (8%): $0.00" :font "Arial 10"))
             (lbl-total (make-instance 'label :master receipt-frame :text "Total: $0.00" :font "Arial 12 bold"))
             
             (btn-clear (make-instance 'button :master receipt-frame :text "Clear Order"))
             (btn-checkout (make-instance 'button :master receipt-frame :text "💳 Process Payment")))

        (grid content-frame 2 0 :sticky "nesw" :padx 10 :pady 5)
        (grid-columnconfigure content-frame 0 :weight 3)
        (grid-columnconfigure content-frame 1 :weight 2)
        (grid-rowconfigure content-frame 0 :weight 1)

        (grid menu-frame 0 0 :sticky "nesw" :padx 5 :pady 5)
        (grid receipt-frame 0 1 :sticky "nesw" :padx 5 :pady 5)

        (grid-columnconfigure menu-frame 0 :weight 1)
        (grid-columnconfigure menu-frame 1 :weight 1)

        ;; --- BOX TILE GRID GENERATION WITH AUTOMATIC SCALING ---
        (let ((row 0)
              (col 0))
          (dolist (item *inventory*)
            (let* ((item-name (first item))
                   (item-price (second item))
                   (item-img-file (third item))
                   ;; Double break (~%~%) ensures text stays clear of the thumbnail frame
                   (btn-text (format nil "~A~%~%$~,2F" item-name item-price))
                   (item-btn (make-instance 'button :master menu-frame :text btn-text)))
              
              (grid-rowconfigure menu-frame row :weight 1)
              (grid item-btn row col :sticky "nesw" :padx 8 :pady 8 :ipadx 10 :ipady 10)
              
              (let ((full-img-path (namestring (merge-pathnames item-img-file app-dir))))
                (when (probe-file full-img-path)
                  (let ((raw-img (make-image))
                        (scaled-img (make-image)))
                    
                    ;; 1. Load the raw big image from your folder
                    (image-load raw-img full-img-path)
                    
                    ;; 2. Tell Tk to copy and downsample it by a factor of 4 (e.g. 240px -> 60px)
                    (send-wish (format nil "~A copy ~A -subsample 4 4" 
                                       (ltk::name scaled-img) 
                                       (ltk::name raw-img)))
                    
                    ;; 3. Apply the dynamically scaled image cleanly on top of the text
                    (configure item-btn :image scaled-img :compound "top"))))

              ;; Tile Click Callback Action
              (setf (command item-btn)
                    (lambda ()
                      (push (cons item-name item-price) *cart*)
                      (listbox-append cart-listbox (format nil "  ~A (~,2F)" item-name item-price))
                      (multiple-value-bind (sub tax tot) (update-totals)
                        (setf (text lbl-subtotal) (format nil "Subtotal: $~,2F" sub)
                              (text lbl-tax) (format nil "Tax (8%): $~,2F" tax)
                              (text lbl-total) (format nil "Total: $~,2F" tot)))))

              (if (= col 0)
                  (setf col 1)
                  (progn (setf col 0)
                         (incf row))))))

        ;; --- RIGHT SIDE RECEIPT PANEL ---
        (grid-columnconfigure receipt-frame 0 :weight 1)
        (grid-columnconfigure receipt-frame 1 :weight 1)
        (grid-rowconfigure receipt-frame 0 :weight 1)

        (grid cart-listbox 0 0 :columnspan 2 :sticky "nesw" :padx 5 :pady 5)
        (grid lbl-subtotal 1 0 :columnspan 2 :sticky "e" :padx 10 :pady 2)
        (grid lbl-tax 2 0 :columnspan 2 :sticky "e" :padx 10 :pady 2)
        (grid lbl-total 3 0 :columnspan 2 :sticky "e" :padx 10 :pady 4)
        
        (grid btn-clear 4 0 :sticky "ew" :padx 5 :pady 10)
        (grid btn-checkout 4 1 :sticky "ew" :padx 5 :pady 10)

        ;; --- SYSTEM CALLBACKS ---
        (setf (command btn-clear)
              (lambda ()
                (setf *cart* nil)
                (listbox-clear cart-listbox)
                (setf (text lbl-subtotal) "Subtotal: $0.00"
                      (text lbl-tax) "Tax (8%): $0.00"
                      (text lbl-total) "Total: $0.00")))

        (setf (command btn-checkout)
              (lambda ()
                (when *cart*
                  (multiple-value-bind (sub tax tot) (update-totals)
                    (declare (ignore sub tax))
                    (do-msg (format nil "Transaction Approved!~%Processed Final Bill total: $~,2F" tot)
                            :title "POS Success")
                    (setf *cart* nil)
                    (listbox-clear cart-listbox)
                    (setf (text lbl-subtotal) "Subtotal: $0.00"
                          (text lbl-tax) "Tax (8%): $0.00"
                          (text lbl-total) "Total: $0.00")))))))))