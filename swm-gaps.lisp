;;;; swm-gaps.lisp

(in-package #:swm-gaps)

(export '(*inner-gaps-size* *outer-gaps-size* toggle-gaps))

(defvar *inner-gaps-size* 5)
(defvar *outer-gaps-size* 10)
(defvar *gaps-on* nil)

;; Redefined - with `if`s for *inner-gaps-on*
(defun stumpwm::maximize-window (win)
  "Maximize the window."
  (multiple-value-bind (x y wx wy width height border stick)
      (stumpwm::geometry-hints win)

    (if *gaps-on*
        (setf width (- width (* 2 *inner-gaps-size*))
              height (- height (* 2 *inner-gaps-size*))
              x (+ x *inner-gaps-size*)
              y (+ y *inner-gaps-size*)))

    (dformat 4 "maximize window ~a x: ~d y: ~d width: ~d height: ~d border: ~d stick: ~s~%" win x y width height border stick)
    ;; This is the only place a window's geometry should change
    (set-window-geometry win :x wx :y wy :width width :height height :border-width 0)
    (xlib:with-state ((window-parent win))
      ;; FIXME: updating the border doesn't need to be run everytime
      ;; the window is maximized, but only when the border style or
      ;; window type changes. The overhead is probably minimal,
      ;; though.
      (setf (xlib:drawable-x (window-parent win)) x
            (xlib:drawable-y (window-parent win)) y
            (xlib:drawable-border-width (window-parent win)) border)
      ;; the parent window should stick to the size of the window
      ;; unless it isn't being maximized to fill the frame.
      (if (or stick
              (find *window-border-style* '(:tight :none)))
          (setf (xlib:drawable-width (window-parent win)) (window-width win)
                (xlib:drawable-height (window-parent win)) (window-height win))
          (let ((frame (stumpwm::window-frame win)))
            (setf (xlib:drawable-width (window-parent win)) (- (frame-width frame)
                                                               (* 2 (xlib:drawable-border-width (window-parent win)))
                                                               (if *gaps-on* (* 2 *inner-gaps-size*) 0))
                  (xlib:drawable-height (window-parent win)) (- (stumpwm::frame-display-height (window-group win) frame)
                                                                (* 2 (xlib:drawable-border-width (window-parent win)))
                                                                (if *gaps-on* (* 2 *inner-gaps-size*) 0)))))
      ;; update the "extents"
      (xlib:change-property (window-xwin win) :_NET_FRAME_EXTENTS
                            (list wx wy
                                  (- (xlib:drawable-width (window-parent win)) width wx)
                                  (- (xlib:drawable-height (window-parent win)) height wy))
                            :cardinal 32))))

(defun reset-all-windows ()
  "Reset the size for all tiled windows"
  (let ((windows (mapcan (lambda (g)
                           (mapcar (lambda (w) w) (stumpwm::sort-windows g)))
                         (stumpwm::sort-groups (current-screen)))))
    (mapcar (lambda (w)
              (if (string= (class-name (class-of w)) "TILE-WINDOW")
                  (stumpwm::maximize-window w))) windows)))

(defun add-outer-gaps ()
  "Add extra gap to the outermost borders"
  (let* ((hd (current-head))
         (hn (stumpwm::head-number hd))
         (hh (stumpwm::head-height hd))
         (hw (stumpwm::head-width hd))
         (gap *outer-gaps-size*)
         (nh (- hh (* 2 gap)))
         (nw (- hw (* 2 gap))))
    (stumpwm::resize-head hn gap gap nw nh)))

(defcommand toggle-gaps () ()
  "Toggle gaps"
  (setf *gaps-on* (null *gaps-on*))
  (if *gaps-on*
      (progn
        (add-outer-gaps)
        (reset-all-windows))
      (stumpwm::refresh-heads)))
