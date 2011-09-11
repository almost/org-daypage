;; org-daypage.el --- Org-Mode Day Page.
;;
;; Copyright (C) 2010-2011 Thomas Parslow
;;
;; Author: Thomas Parslow <tom@almostobsolete.net>
;; Created: June, 2010
;; Version: 1
;; Keywords: orgmode, daypage

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License version 2 as
;; published by the Free Software Foundation.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
;;

;;; Installation
;;
;; Add org-daypage.el to your load path and add (require 'org-daypage)
;; to your .emacs.

;;; Configuration:
;;
;; No keys are defined by default. So you may wish to add something
;; like the following to your .emacs as well:
;;
;; (define-key daypage-mode-map (kbd "<C-left>") 'daypage-prev)
;; (define-key daypage-mode-map (kbd "<C-right>") 'daypage-next)
;; (define-key daypage-mode-map (kbd "<C-up>") 'daypage-prev-week)
;; (define-key daypage-mode-map (kbd "<C-down>") 'daypage-next-week)
;; (define-key daypage-mode-map "\C-c." 'daypage-time-stamp)
;;
;; (global-set-key [f11] 'todays-daypage) 
;; (global-set-key [f10] 'yesterdays-daypage) 
;; (global-set-key "\C-con" 'todays-daypage)
;; (global-set-key "\C-coN" 'find-daypage)

(eval-when-compile (require 'cl))

(setq daypage-path "~/notes/days/")

(defvar daypage-mode-map
  (let ((map (make-sparse-keymap)))
    map)
  "The key map for daypage buffers.")

(defun find-daypage (&optional date)
  "Go to the day page for the specified date, or todays if none is specified."
  (interactive (list 
                (org-read-date "" 'totime nil nil
                               (current-time) "")))
  (setq date (or date (current-time)))
  (find-file (expand-file-name (concat daypage-path (format-time-string "%Y-%m-%d" date) ".org"))))

(defun daypage-p ()
  "Return true if the current buffer is visiting a daypage"
  (if (daypage-date)
      t
    nil))

(defun daypage-date ()
  "Return the date for the daypage visited by the current buffer
or nil if the current buffer isn't visiting a dayage" 
  (let ((file (buffer-file-name))
        (root-path (expand-file-name daypage-path)))
    (if (and file
               (string= root-path (substring file 0 (length root-path)))
               (string-match "\\([0-9]\\{4\\}\\)-\\([0-9]\\{2\\}\\)-\\([0-9]\\{2\\}\\).org$" file))
        (flet ((d (i) (string-to-number (match-string i file))))
          (encode-time 0 0 0 (d 3) (d 2) (d 1)))
      nil)))


(defun maybe-daypage ()
  "Set up daypage stuff if the org file being visited is in the daypage folder"
  (let ((date (daypage-date)))
    (when date
      ; set up the daypage key map
      (use-local-map daypage-mode-map)
      (set-keymap-parent daypage-mode-map
                         org-mode-map)
      (run-hooks 'daypage-hook))))

(add-hook 'org-mode-hook 'maybe-daypage)

(defun daypage-next ()
  (interactive)
  (find-daypage 
   (seconds-to-time (+ (time-to-seconds (daypage-date))
                       86400)))
  (run-hooks 'daypage-movement-hook))

(defun daypage-prev ()
  (interactive)
  (find-daypage 
   (seconds-to-time (- (time-to-seconds (daypage-date))
                       86400)))
  (run-hooks 'daypage-movement-hook))

(defun daypage-next-week ()
  (interactive)
  (find-daypage 
   (seconds-to-time (+ (time-to-seconds (daypage-date))
                       (* 86400 7))))
  (run-hooks 'daypage-movement-hook))

(defun daypage-prev-week ()
  (interactive)
  (find-daypage 
   (seconds-to-time (- (time-to-seconds (daypage-date))
                       (* 86400 7))))
  (run-hooks 'daypage-movement-hook))

(defun todays-daypage ()
  "Go straight to todays day page without prompting for a date."
  (interactive) 
  (find-daypage)
  (run-hooks 'daypage-movement-hook))

(defun yesterdays-daypage ()
  "Go straight to todays day page without prompting for a date."
  (interactive) 
  (find-daypage 
   (seconds-to-time (- (time-to-seconds (current-time))
                      86400)))
  (run-hooks 'daypage-movement-hook))

(defun daypage-time-stamp ()
  "Works like (and is basically a thin wrapper round)
org-time-stamp except the default date will be the date of the daypage."
  (interactive)
  (unless (org-at-timestamp-p)
    (insert "<" (format-time-string "%Y-%m-%d %a" (daypage-date)) ">")
    (backward-char 1))
  (org-time-stamp nil))

(defun daypage-new-item ()
  "Switches to the current daypage and inserts a top level heading and a timestamp"
  (interactive)
  (todays-daypage)
  (end-of-buffer)
  (kill-whitespace)
  (insert "\n\n* <" (format-time-string "%Y-%m-%d %a" (daypage-date)) "> "))


(provide 'org-daypage)
