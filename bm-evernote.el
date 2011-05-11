;;; bm-evernote.el --- bridging between bookmark and evernote-mode

;; Copyright (C) 2011  ARISAWA Akihiro

;; Author: ARISAWA Akihiro <awasira at gmail.com>
;; Keywords: evernote, bookmark

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Add the following snippet to the ~/.emacs.d/init.el file:

;; (autoload 'bm-evernote-bookmark-jump "bm-evernote")
;; (eval-after-load "evernote-mode"
;;  '(require 'bm-evernote))

;;; Code:

(require 'evernote-mode)
(declare-function bookmark-default-handler "bookmark" (bmk-record))
(declare-function bookmark-get-bookmark-record "bookmark" (bookmark))
(declare-function bookmark-make-record-default
		  "bookmark" (&optional no-file no-context posn))
(declare-function bookmark-name-from-full-record
		  "bookmark" (full-record))

(defun bm-evernote-bookmark-make-record ()
  "Make a emacs bookmark entry for a evernote buffer."
  `(,(buffer-name)
    ,@(bookmark-make-record-default 'no-file)
    ;; if bookmark-bmenu-toggle-filenames is t and a bookmark record doesn't
    ;; have filename field, Emacs23.2 raises an error.
    (filename . ,(buffer-name))
    (handler . bm-evernote-bookmark-jump)))

;;;###autoload
(defun bm-evernote-bookmark-jump (bookmark)
  "Default bookmark handler for evernote buffers."
  (enh-command-with-auth
   (let ((note-attrs (enh-command-get-note-attrs-from-tag-guids nil))
	 attr)
     (while (setq attr (car note-attrs))
       (let ((title (assq 'title attr)))
	 (when (and title
		    (string= (cdr title)
			     (bookmark-name-from-full-record bookmark)))
	   (enh-base-open-note-common attr)
	   (enh-browsing-update-page-list)
	   (enh-browsing-push-page
	    (enh-browsing-create-page 'note-list "All notes") note-attrs)
	   (let ((buf (current-buffer)))
	     (bookmark-default-handler
	      `("" (buffer . ,buf) . ,(bookmark-get-bookmark-record bookmark))))
	   (setq note-attrs nil)))
       (setq note-attrs (cdr note-attrs))))))

(defun bm-evernote-prepare ()
  (interactive)
  (set (make-local-variable 'bookmark-make-record-function)
       'bm-evernote-bookmark-make-record))
(add-hook 'evernote-mode-hook 'bm-evernote-prepare)

(provide 'bm-evernote)
;;; bm-evernote.el ends here
