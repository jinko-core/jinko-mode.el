;;; lisp/jinko-mode/jinko-mode.el --- Major mode for the Jinko programming language -*- lexical-binding: t; -*-

;; Version: 0.1.0
;; Author: Guillaume Pagnoux
;; Url: https://github.com/jinko-core/jinko-mode
;; Keywords: languages
;;
;;; Commentary:
;; A major mode for the Jinko programming language (https://github.com/jinko-core/jinko)

;;; Code:

(eval-when-compile (require 'rx))

(defcustom jinko-before-save-hook nil
  "Function for formatting before save"
  :type 'function
  :group 'jinko-mode)

(defcustom jinko-after-save-hook nil
  "Function for formatting before save"
  :type 'function
  :group 'jinko-mode)

;; Customization:

(defgroup jinko-mode nil
  "Support for Jinko code."
  :link '(url-link "https://github.com/jinko-core/jinko")
  :group 'languages)

(defcustom jinko-indent-offset 4
  "Indent Jinko code by this number of spaces."
  :type 'integer
  :group 'jinko-mode
  :safe #'integerp)

;;; Syntax:

(defun jinko-re-word (inner) (concat "\\<" inner "\\>"))
(defun jinko-re-grab (inner) (concat "\\(" inner "\\)"))

(defconst jinko-re-ident "[[:word:][:multibyte:]_][[:word:][:multibyte:]_[:digit:]]*")

(defun jinko-re-item-def (itype)
  (concat (jinko-re-word itype)
          "[[:space:]]+" (jinko-re-grab jinko-re-ident)))

(defvar jinko-mode-syntax-table
  (let ((table (make-syntax-table)))

    ;; Operators
    (dolist (i '(?+ ?- ?* ?/))
      (modify-syntax-entry i "." table))

    ;; Strings
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?\\ "\\" table)

    ;; Comments
    (modify-syntax-entry ?/ ". 124b" table)
    (modify-syntax-entry ?* ". 23n" table)
    (modify-syntax-entry ?\n "> b" table)
    (modify-syntax-entry ?\^m "> b" table)
    (modify-syntax-entry ?# "< c" table)
    (modify-syntax-entry ?\n "> c" table)
    (modify-syntax-entry ?\^m "> c" table)

    table)
  "Syntax definitions and helpers.")

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.jk\\'" . jinko-mode))

;;; Mode:

;; (defvar jinko-mode-map nil
;;   "Keymap for Jinko major mode.")

;;;###autoload
(define-derived-mode jinko-mode prog-mode "Jinko"
  "Major mode for Jinko files.

  \\{jinko-mode-map}"
  :group 'jinko-mode
  :syntax-table jinko-mode-syntax-table

  (setq-local comment-start "// ")
  (setq-local comment-end "")
  (setq-local comment-multi-line t)
  (setq-local open-paren-in-column-0-is-defun-start nil)

   ;; Fonts
  (setq-local font-lock-defaults
                '(jinko-font-lock-keywords))

  (add-hook 'before-save-hook jinko-before-save-hook nil t)
  (add-hook 'after-save-hook jinko-after-save-hook nil t))

(defconst jinko-keywords
  '(
    "as"
    "else" "ext"
    "false" "for" "func"
    "if" "in" "incl"
    "loop"
    "mock" "mut"
    "return"
    "test" "true" "type"
    "while")
  "Font-locking definitions and helpers.")

(defconst jinko-builtin-types
  '("bool"
    "char"
    "float"
    "int"
    "string"))



(defvar jinko-font-lock-keywords
  (append
   `(
     ;;Keywords proper
     (,(regexp-opt jinko-keywords 'symbols) . font-lock-keyword-face)

     ;; Built-in types
     (,(regexp-opt jinko-builtin-types 'symbols) . font-lock-type-face))

   (mapcar #'(lambda (x)
               (list (jinko-re-item-def (car x)) 1 (cdr x)))
           '(("func" . font-lock-function-name-face)
             ("type" . font-lock-type-face)))))



(defun jinko-mode-reload ()
  (interactive)
  (unload-feature 'jinko-mode)
  (require 'jinko-mode)
  (jinko-mode))

(provide 'jinko-mode)

;;; jinko-mode.el ends here
