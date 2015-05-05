;;; ox-pelican-md.el --- Export org-mode to pelican markdown.

;; Copyright (c) 2015 Yen-Chin, Lee. (coldnew) <coldnew.tw@gmail.com>
;;
;; Author: coldnew <coldnew.tw@gmail.com>
;; Keywords:
;; X-URL: http://github.com/coldnew/org-pelican
;; Version: 0.1
;; Package-Requires: ((org "8.0") (cl-lib "0.5") (f "0.17.2") (noflet "0.0.11"))

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;;; Code:

(eval-when-compile (require 'cl-lib))

(require 'noflet)
(require 'f)
(require 'ox-md)
(require 'ox-publish)


;;;; Backend

(org-export-define-derived-backend 'pelican-md 'md
  :translate-alist
  '(
    (template . org-pelican-md-template)
    )
  :options-alist
  '(
    ;; Title: My super title
    ;; Date: 2010-12-03 10:20
    ;; Modified: 2010-12-05 19:30
    ;; Category: Python
    ;; Tags: pelican, publishing
    ;; Slug: my-super-post
    ;; Authors: Alexis Metaireau, Conan Doyle
    ;; Summary: Short version for index and feeds

    ;; ;; pelican metadata
    ;; (:date     "DATE"       nil     nil)
    (:category "CATEGORY"   nil     nil)
    ;; (:tags     "TAGS"       nil     nil)
    ;; (:url      "URL"        nil     nil)
    ;; (:save_as  "SAVE_AS"    nil     nil)
    ;; (:slug     "SLUG"       nil     nil)
    ;; ;; override default ox-html.el options-alist
    ;; (:html-head-include-scripts nil "html-scripts" nil)
    ;; (:html-head-include-default-style nil "html-style" nil)
    ))


(defun org-pelican-md--build-meta-info (info)
  "Return meta tags for exported document.
INFO is a plist used as a communication channel."
  (noflet ((protect-string
            (str)
            (replace-regexp-in-string
             "\"" "&quot;" (org-html-encode-plain-text str)))

           (protect-string-compact
            ;; FIXME: add option to enable/disable this
            ;; convert:
            ;;   _        -> space
            ;;   <space>  -> ,
            ;;   @        -> -
            (str)
            (replace-regexp-in-string
             "_" " "
             (replace-regexp-in-string
              " " ","
              (replace-regexp-in-string
               "@" "-"  (protect-string str)))))
           (build--metainfo (name var func)
                            (and (org-string-nw-p var)
                                 (format "%s: %s\n" name (funcall func var))))

           (build-generic-metainfo
            (name var)
            (build--metainfo name var 'protect-string))
           (build-compact-metainfo
            (name var)
            (build--metainfo name var 'protect-string-compact))
           )
    (let ((date (org-pelican-html--parse-date info))
          (category (plist-get info :category))
          (tags (plist-get info :tags))
          (save_as (plist-get info :save_as))
          (url (plist-get info :url))
          (slug (plist-get info :slug)))
      (concat
       ;;       (build-generic-metainfo "date" date)

       (build-generic-metainfo "Url" url)
       (build-generic-metainfo "save_as" save_as)
       (build-generic-metainfo "Slug" slug)

       ;; compact version
       (build-compact-metainfo "Category" category)
       (build-compact-metainfo "Tags" tags)
       ))))


(defun org-pelican-md-template (contents info)
  "Return complete document string after Markdown conversion.
CONTENTS is the transcoded contents string.  INFO is a plist used
as a communication channel."
  (concat
   (org-pelican-md--build-meta-info info)
   "\n"
   contents))


;;; End-user functions

;;;###autoload
(defun org-pelican-export-as-md
    (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer to an HTML buffer for blogit.

Export is done in a buffer named \"*Blogit HTML Export*\", which
will be displayed when `org-export-show-temporary-export-buffer'
is non-nil."
  (interactive)
  (org-export-to-buffer 'pelican-md "*pelican markdown Export*"
    async subtreep visible-only body-only ext-plist
    (lambda () (markdown-mode))))

;;;###autoload
(defun org-pelican-publish-to-rst (plist filename pub-dir)
  "Publish an org file to rst.

FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.

Return output file name."
  (org-publish-org-to 'pelican-md filename ".md"
                      plist pub-dir))

(provide 'ox-pelican-html)
;;; ox-pelican-md.el ends here.