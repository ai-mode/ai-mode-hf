;;; ai-mode-hf.el --- HuggingFace completion backend for AI mode -*- lexical-binding: t -*-
;;
;; Copyright (C) 2023 Alex (https://github.com/lispython)

;; URL: https://github.com/ai-mode/ai-mode-hf
;; Version: 0.1
;; Package-Requires: ((emacs "27.1") (ai-mode "0.1") cl-lib)
;; Keywords: help, tools


;; This file is part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <https://www.gnu.org/licenses/>.
;;; Commentary:
;;
;; The package allows using HuggingFace service as a backend for code completion
;; for ai-mode.


;;; Code:


(require 'ai-utils)
(require 'json)

(defgroup ai-mode-hf nil
  "Integration with HuggingFace API."
  :prefix "ai-mode-hf"
  :group 'ai-mode
  :link '(url-link :tag "Repository" "https://github.com/ai-mode/ai-mode-hf"))


(defcustom ai-mode-hf--request-timeout 60
  "Codeium request timeout."
  :type '(choice integer (const nil))
  :group 'ai-mode-hf)


(defcustom ai-mode-hf--base-url "https://api-inference.huggingface.co"
  "Base HuggingFace compatible api base."
  :type 'string
  :group 'ai-mode-hf)

(defvar ai-mode-hf--completions--url "/models/")


(defcustom ai-mode-hf--model "bigcode/starcoder"
  "The used HuggingFace model."
  :type 'string
  :group 'ai-mode-hf)


(defcustom ai-mode-hf--stop-tokens '("<|endoftext|>")
  "The used HuggingFace model."
  :type 'string
  :group 'ai-mode-hf)


(defcustom ai-mode-hf--api-key ""
  "Key for Codeium API."
  :type 'string
  :group 'ai-mode-hf)


(defcustom ai-mode-hf--default-max-tokens 1000
  "The maximum number of tokens to generate in the completion."
  :type '(choice integer (const nil))
  :group 'ai-mode-hf)


(defcustom ai-mode-hf--model-temperature 1
  "What sampling temperature to use, between 0 and 100."
  :type '(choice integer (const nil))
  :group 'ai-mode-hf)

(defcustom ai-mode-hf--top-p 0.8
  "What sampling temperature to use, between 0 and 1."
  :type '(choice integer (const nil))
  :group 'ai-mode-hf)


(defun ai-mode-hf--get-completion-url ()
  "Get completion API url."
  (concat ai-mode-hf--base-url ai-mode-hf--completions--url ai-mode-hf--model))


(cl-defun ai-mode-hf--completion-backend (code callback &key (fail-callback nil) (extra-params nil))
  "Codeium completion backend.

CODE - the code that needs to be completed
CALLBACK - the function that will be executed upon successful request completion
FAIL-CALLBACK - the function that will be executed upon unsuccessful request completion
EXTRA-PARAMS - an alist with additional parameters."

  (ai-mode-hf--async-request
   code
   (lambda (request response)
     (let* ((completion-items response)
            (completions (mapcar (lambda (item) (funcall #'ai-mode-hf-make-completion-string code item)) completion-items)))
       (funcall callback completions)))
   :fail-callback fail-callback
   :extra-params extra-params))


(defun ai-mode-hf-make-completion-string (text completion-item)
  "Create and return completion string for TEXT from COMPLETION-ITEM."
  (let* ((completion (map-elt completion-item 'generated_text)))
    (dolist (item ai-mode-hf--stop-tokens)
      (setq completion (replace-regexp-in-string item "" completion)))
    completion))


(cl-defun ai-mode-hf--async-request (input callback &key (fail-callback nil) (extra-params nil))
  "Execute a request to the API.

INPUT - the code that needs to be completed
CALLBACK - the function that will be executed upon successful request completion
FAIL-CALLBACK - the function that will be executed upon unsuccessful request completion
EXTRA-PARAMS - an alist with additional parameters."

  (let* ((context-end (map-elt extra-params :context-end))
         (context-beginning (map-elt extra-params :context-beginning))
         (cursor-offset (or (if (and context-end context-beginning)
                                (- context-end context-beginning))
                            (length input)))
         (buffer (map-elt extra-params :buffer))
         (timeout (map-elt extra-params :timeout ai-mode-hf--request-timeout))
         (parameters `(("max_new_tokens" . ,(map-elt extra-params :max-tokens ai-mode-hf--default-max-tokens))
                       ("temperature" . ,(map-elt extra-params :temperature ai-mode-hf--model-temperature))
                       ("top_p" . ,(map-elt extra-params :top-p ai-mode-hf--top-p))
                       ("return_full_text" . ,json-false)
                       ("stop" . ,(map-elt extra-params :stop-tokens ai-mode-hf--stop-tokens))))
         (request-data `(("inputs" . ,input)
                         ("parameters" . ,parameters)))
         (headers `(("Content-Type" . "application/json")))
         (headers (if ai-mode-hf--api-key
                      (append headers `(("Authorization" . ,(format "Bearer %s" ai-mode-hf--api-key))))
                    header))
         (wrapped-callback (lambda (response) (funcall callback request-data response)))
         (encoded-request-data (encode-coding-string (json-encode request-data) 'utf-8)))
    (ai-utils--async-request (ai-mode-hf--get-completion-url) "POST" encoded-request-data headers wrapped-callback :timeout timeout)))





(defun ai-mode-hf--setup-api-token ()
  "Setup api token."
  (interactive)
  (let* ((api-token (read-from-minibuffer "Enter api token: ")))
    (customize-set-variable 'ai-mode-hf--api-key api-token)))


(provide 'ai-mode-hf)

;;; ai-mode-hf.el ends here
