;;; helm-navi.el --- Helm for navi-mode -*- lexical-binding: t -*-

;; Author: Adam Porter <adam@alphapapa.net>
;; Url: http://github.com/emacs-helm/helm-navi-outshine
;; Version: 0.1-pre
;; Package-Requires: ((emacs "24.4") (helm "1.9.4") (navi-mode "2.0") (s "1.10.0"))
;; Keywords: navigation, outlines

;; Copyright (C) 2012 ~ 2017 Thierry Volpiatto <thierry.volpiatto@gmail.com>

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

;; This file provides commands to navigate a buffer using keywords and
;; headings provided by `navi-mode'.

;; Navi <https://github.com/tj64/navi> is a package that lets you
;; quickly navigate and "remotely control" buffers.

;;; Code:

;;;; Requirements

;; As `navi-mode' requires `outshine', so this package requires
;; `helm-outshine'.

(require 'helm-outshine)
(require 'navi-mode)

;;;; Customization

;;;; Functions

;;;;; Commands

;;;###autoload
(defalias 'helm-navi 'helm-navi-all-current-buffer)

;;;###autoload
(defun helm-navi-all-current-buffer ()
  "Show matches for all `navi-mode' keywords and headings in current buffer."
  (interactive)
  (save-restriction
    (helm :buffer "*helm-navi-all-current-buffer*"
          :sources (helm-build-sync-source " Navi headings and keywords in-buffer"
                     :candidates (helm-outshine--get-candidates-in-file
                                  (current-buffer)
                                  (helm-navi--get-regexp))
                     :action '(("Go to heading" . helm-outshine--goto-marker))
                     :follow 1
                     ;; Not ideal, because collapsed/hidden parts will
                     ;; be shown afterward, but I can't find a way to
                     ;; save this information and restore it
                     :init 'show-all)
          :preselect (helm-navi--in-buffer-preselect))))

;;;;; Support functions

(defun helm-navi--in-buffer-preselect ()
  "Return string containing current or previous visible heading for preselecting in Helm buffer."
  (save-excursion
    (goto-char (line-end-position))
    (when (re-search-backward (helm-navi--get-regexp))
      (match-string 0))))

(defun helm-navi--get-regexp ()
  "Return regexp for all headings and keywords in current buffer."
  (concat (navi-make-regexp-alternatives
           (navi-get-regexp (car
                             (split-string
                              (symbol-name major-mode)
                              "-mode" 'OMIT-NULLS))
                            :ALL)
           (mapconcat (lambda (s)
                        (s-trim (car s)))
                      outline-promotion-headings
                      "\\|"))
          ".*$"))

;;;; Footer

(provide 'helm-navi)

;;; helm-navi.el ends here
