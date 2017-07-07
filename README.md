# swm-gaps

Pretty (useless) gaps for [StumpWM](https://stumpwm.github.io/).

![screen](screen.png)

This is a packed version of *useless-gaps*
by [vlnx](https://gist.github.com/vlnx/5651256) with added outer borders. Credit
goes to the original author.

```lisp
;; Clone the repo to StumpWM's load path (or add-to-load-path)

(load-module "swm-gaps")

;; Inner gaps run along all the 4 borders of a frame
(setf swm-gaps:*inner-gaps-size* 10)

;; Outer gaps add more padding to the outermost borders
;; (touching the screen border)
(setf swm-gaps:*outer-gaps-size* 20)

;; Call command
;; toggle-gaps
```
