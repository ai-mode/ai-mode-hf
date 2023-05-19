# HuggingFace backend for AI mode


[![LICENSE](https://img.shields.io/github/license/ai-mode/ai-mode-hf)](https://github.com/ai-mode/ai-mode-hf/blob/master/LICENSE)

# Overview
This package provides a code autocomplete backend through HuggingFace Inference API or local [Text Generation Interference server](https://github.com/huggingface/text-generation-inference) for [ai-mode](https://github.com/ai-mode/ai-mode/) extension.

# Installation

First of all, install [ai-mode](https://github.com/ai-mode/ai-mode/), if you haven't already done so.


### Installation via MELPA

It's easiest/recommended to install from MELPA. Here's a minimal MELPA configuration for your ~/.emacs:

```elisp
(package-initialize)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
```

Afterwards, M-x package-install RET ai-mode-hf RET (you might want to M-x package-refresh-contents RET beforehand if you haven't done so recently).


### Installation via GIT

Clone this repository somewhere

```bash
$ cd ~/.emacs.d/plugins
$ git clone --recursive https://github.com/ai-mode/ai-mode-hf
```

Add the following in your .emacs file:

```elisp
(add-to-list 'load-path
              "~/.emacs.d/plugins/ai-mode-hf")
(require 'ai-mode-hf)
```

or you can use use-package

```elisp
(use-package ai-mode-hf
  :load-path "~/.emacs.d/plugins/ai-mode-hf`"
  :config (progn
            (add-to-list 'ai-completions--backends '("HuggingFace" . ai-mode-hf--completion-backend))

            ;; Optionally, we are setting up HuggingFace as the default backend for AI completions.
            (setq ai-completions--current-backend #'ai-mode-hf--completion-backend)
            ))

```


### Configuration


To use HuggingFace cloud backend, you need to obtain an authorization key. You can get the key on the [page](https://huggingface.co/settings/tokens).

There are several ways to assign your key to the variable `ai-mode-hf--api-key`.

1. Put `(setq ai-mode-hf--api-key "you key")` in the configuration file.
2. Use the command M-x `set-variable ai-mode-hf--api-key`.
3. Use the command M-x `customize-variable ai-mode-hf--api-key`.


| Configuration variable           | Description                      |
|----------------------------------|----------------------------------|
| `ai-mode-hf--request-timeout`    | Default request timeout          |
| `ai-mode-hf--base-url`           | API base                         |
| `ai-mode-hf--completions--url`   | Completions api                  |
| `ai-mode-hf--model`              | Used model                       |
| `ai-mode-hf--stop-tokens`        | List of stop tokens              |
| `ai-mode-hf--default-max-tokens` | Max number of tokens in response |
| `ai-mode-hf--model-temperature`  | Sampling temperature             |
| `ai-mode-hf--top-p`             | Top-p sampling                   |




#### Add the HuggingFace completion backend to ai-completions--backends:

```elisp
(add-to-list 'ai-completions--backends '("HuggingFace" . ai-mode-hf--completion-backend))
```

Now you can choose available backends by calling the command `ai-completions-change-backend`.

If you want to change the default backend, you need to redefine the value of the variable `ai-completions--current-backend` in your Emacs config.
