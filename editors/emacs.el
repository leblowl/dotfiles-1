;;; emacs.el --- A monolithic Emacs config.
;;
;; Copyright (c) 2015-2016, Chad Stovern
;;
;; Author: Chad Stovern <chad@stovern.me>
;; URL: https://github.com/chadhs/dotfiles
;; Version: 1.0.0
;; Keywords: convenience

;; This file is not part of GNU Emacs.

;;; Commentary:

;; This file bootstraps a complete Emacs environment to my liking.
;; If you're new to Emacs check out spacemacs: http://spacemacs.org

;;; License:

;; BSD 3-Clause License
;;
;; Copyright (c) 2015-2016, Chad Stovern
;; All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are met:
;;
;; * Redistributions of source code must retain the above copyright notice, this
;;   list of conditions and the following disclaimer.
;;
;; * Redistributions in binary form must reproduce the above copyright notice,
;;   this list of conditions and the following disclaimer in the documentation
;;   and/or other materials provided with the distribution.
;;
;; * Neither the name of the copyright holder nor the names of its
;;   contributors may be used to endorse or promote products derived from
;;   this software without specific prior written permission.

;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
;; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
;; CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
;; OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;;; Code:



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; package management                                                   ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; keep track of start time for load time calculation
(defconst emacs-start-time  (current-time))

;;; load package support
(require 'package)

;;; package repositories
(setq
 package-archives '(("gnu"           . "https://elpa.gnu.org/packages/")
                    ("melpa"         . "https://melpa.org/packages/")
                    ("melpa-stable"  . "https://stable.melpa.org/packages/")))

;;; the latest version of a package is installed unless pinned to a specific repo
(setq package-pinned-packages '((cider        . "melpa-stable")
                                (clj-refactor . "melpa-stable")))

;;; packages to install
(setq package-list '(;; emacs enhancements
                     exec-path-from-shell ; make sure PATH makes shell PATH
                     diminish ; suppress modes from appearing in status bar
                     multi-term
                     restart-emacs ; restart emacs from within emacs
                     which-key

                     ;; editing enhancements
                     ace-jump-mode
                     column-enforce-mode
                     editorconfig
                     paredit
                     rainbow-delimiters

                     ;; auto-completion
                     auto-complete
                     ac-cider

                     ;; syntax checking
                     flycheck
                     flycheck-pos-tip
                     flycheck-clojure

                     ;; themes
                     cycle-themes
                     solarized-theme
                     ample-theme

                     ;; modeline
                     spaceline

                     ;; vim mode
                     evil
                     evil-leader
                     evil-matchit
                     evil-nerd-commenter
                     evil-paredit
                     evil-search-highlight-persist
                     evil-surround
                     evil-visualstar
                     vi-tilde-fringe

                     ;; docs
                     dash-at-point ; launch Dash on macOS

                     ;; projects / file / buffer mgmt
                     helm
                     helm-ag
                     helm-flx
                     helm-projectile
                     magit
                     projectile
                     zoom-window

                     ;; clojure
                     cider
                     clojure-mode
                     clojure-mode-extra-font-locking
                     clj-refactor
                     cljr-helm

                     ;; ruby
                     inf-ruby
                     robe

                     ;; python
                     elpy

                     ;; other syntaxes
                     markdown-mode
                     web-mode
                     yaml-mode))

;;; loads packages and activates them
(package-initialize)

;;; fetch the list of packages available
(unless package-archive-contents
  (package-refresh-contents))

;;; install / update packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

;;; show package load time
(let ((elapsed (float-time (time-subtract (current-time)
                                          emacs-start-time))))
  (message "Loaded packages in %.3fs" elapsed))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; package config                                                       ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; evil-mode settings
(require 'evil-leader) ; load evil-leader first so it's initialized for evil
(setq evil-leader/in-all-states 1)
(global-evil-leader-mode)
(evil-leader/set-leader ",")

(require 'evil)
(evil-mode 1)

(require 'evil-matchit)
(global-evil-matchit-mode 1)

(evilnc-default-hotkeys)

(require 'evil-surround)
(global-evil-surround-mode 1)

(global-evil-visualstar-mode)

(require 'evil-search-highlight-persist)
(global-evil-search-highlight-persist t)

;;; terminal settings
(setq multi-term-dedicated-window-height 30
      multi-term-program "/usr/local/bin/zsh")
(add-hook 'term-mode-hook
          (lambda ()
            (setq term-buffer-maximum-size 10000)
            (setq yas-dont-activate t)
            (setq-local scroll-margin 0)
            (setq-local scroll-conservatively 0)
            (setq-local scroll-step 1)))

;;; window management
(require 'zoom-window)
(setq zoom-window-mode-line-color nil)

;;; navigation
(require 'helm)
(helm-mode 1)
(helm-autoresize-mode 1)
(helm-flx-mode +1)

(setq helm-mode-fuzzy-match t ; global
      helm-completion-in-region-fuzzy-match t ; global
      helm-apropos-fuzzy-match t
      helm-bookmark-show-location t
      helm-buffers-fuzzy-matching t
      helm-file-cache-fuzzy-match t
      helm-imenu-fuzzy-match t
      helm-lisp-completion-at-point t
      helm-locate-fuzzy-match t
      helm-M-x-fuzzy-match t
      helm-mode-fuzzy-match t
      helm-recentf-fuzzy-match t
      helm-quick-update t ; show only enough candidates to fill the buffer
      helm-semantic-fuzzy-match t)

;; speed up matching by giving emacs garbage collection a more modern threshold
(setq gc-cons-threshold 20000000)

;;; project management
(require 'projectile)
(setq projectile-require-project-root nil)
(setq projectile-globally-ignored-directories
      (append '(".git"
                ".cljs_rhino_repl"
                ".svn"
                "out"
                "repl"
                "target"
                "venv")
              projectile-globally-ignored-directories))
(setq projectile-globally-ignored-files
      (append '(".DS_Store"
                ".lein-repl-history"
                "*.gz"
                "*.pyc"
                "*.png"
                "*.jpg"
                "*.jar"
                "*.svg"
                "*.tar.gz"
                "*.tgz"
                "*.zip")
              projectile-globally-ignored-files))
(setq projectile-globally-unignored-files
      (append '("profiles.clj")
              projectile-globally-unignored-files))
(projectile-mode)

;;; code auto-completion settings
(ac-config-default)
(setq ac-disable-faces nil)
(define-key ac-completing-map "\t" 'ac-complete) ; set tab key for completion
(define-key ac-completing-map "\r" nil)          ; disable return
(add-to-list 'ac-modes #'yaml-mode)
(add-to-list 'ac-modes #'markdown-mode)
(add-to-list 'ac-modes #'html-mode)
(add-to-list 'ac-modes #'sql-mode)
(add-to-list 'ac-modes #'cider-mode)
(add-to-list 'ac-modes #'cider-repl-mode)

;;; syntax checking
(add-hook 'after-init-hook #'global-flycheck-mode)
;; floating tooltips only works in graphical mode
(when (display-graphic-p (selected-frame))
  (with-eval-after-load 'flycheck
    (setq flycheck-display-errors-function #'flycheck-pos-tip-error-messages)
    (flycheck-pos-tip-mode)))
(setq flycheck-check-syntax-automatically '(mode-enabled save))

;;; paredit
(autoload 'enable-paredit-mode "Pseudo-structural editing of Lisp code." t)
(add-hook 'prog-mode-hook #'enable-paredit-mode)
(add-hook 'prog-mode-hook #'evil-paredit-mode)

;;; rainbow delimiters
(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

;;; 80 column enforcement
(setq column-enforce-column 81
      column-enforce-comments nil)
(add-hook 'prog-mode-hook #'column-enforce-mode)

;;; spaceline
(require 'spaceline-config)
(setq spaceline-highlight-face-func #'spaceline-highlight-face-evil-state
      powerline-default-separator nil
      spaceline-buffer-size-p nil)
(spaceline-spacemacs-theme)
(set-face-attribute
 'spaceline-evil-emacs   nil :background "#6c71c4" :foreground "#eee8d5")
(set-face-attribute
 'spaceline-evil-normal  nil :background "#859900" :foreground "#eee8d5")
(set-face-attribute
 'spaceline-evil-insert  nil :background "#268bd2" :foreground "#eee8d5")
(set-face-attribute
 'spaceline-evil-visual  nil :background "#cb4b16" :foreground "#eee8d5")
(set-face-attribute
 'spaceline-evil-replace nil :background "#dc322f" :foreground "#eee8d5")
(set-face-attribute
 'spaceline-evil-motion  nil :background "#d33682" :foreground "#eee8d5")

;;; keybind discovery
(require 'which-key)
(which-key-mode)

;;; ace-jump
(setq ace-jump-word-mode-use-query-char nil) ; no leading word character needed

;;; editorconfig: indentation and whitespace settings
(require 'editorconfig)
(editorconfig-mode 1)

;;; clojure support
(require 'clojure-mode-extra-font-locking)
(require 'ac-cider)
(require 'clj-refactor)
(require 'cljr-helm)
(setq cider-repl-pop-to-buffer-on-connect nil ; don't show repl buffer on launch
      cider-show-error-buffer nil             ; don't show error buffer automatically
      cider-auto-select-error-buffer nil      ; don't switch to error buffer on error
      cider-repl-use-clojure-font-lock t      ; nicer repl output
      cider-repl-history-file (concat user-emacs-directory "cider-history")
      cider-repl-wrap-history t
      cider-repl-history-size 3000)
(add-hook 'clojure-mode-hook (lambda ()
                               (clj-refactor-mode 1)
                               (yas-minor-mode)))
(add-hook 'cider-repl-mode-hook (lambda ()
                                  (paredit-mode)
                                  (ac-cider-setup)))
(add-hook 'cider-mode-hook (lambda ()
                             (ac-flyspell-workaround)
                             (ac-cider-setup)))
(eval-after-load 'flycheck '(flycheck-clojure-setup))

;;; web templates
(require 'web-mode)
(setq web-mode-markup-indent-offset 2
      web-mode-css-indent-offset 2
      web-mode-code-indent-offset 2)
(add-to-list 'auto-mode-alist '("\\.html?\\'"   . web-mode))
(add-to-list 'auto-mode-alist '("\\.css?\\'"    . web-mode))
(add-to-list 'auto-mode-alist '("\\.scss?\\'"   . web-mode))
(add-to-list 'auto-mode-alist '("\\.less?\\'"   . web-mode))
(add-to-list 'auto-mode-alist '("\\.js?\\'"     . web-mode))
(add-to-list 'auto-mode-alist '("\\.php?\\'"    . web-mode))
(add-to-list 'auto-mode-alist '("\\.jinja?\\'"  . web-mode))

;;; yaml support
(require 'yaml-mode)

;;; ruby support
(add-hook 'ruby-mode-hook (lambda ()
                            (inf-ruby-minor-mode)
                            (robe-mode)))
(add-hook 'robe-mode-hook #'ac-robe-setup)

;;; python support
(add-hook 'python-mode-hook #'elpy-enable)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; user functions                                                       ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; yes and no prompts
(defalias 'yes-or-no-p 'y-or-n-p)

;;; electric return functionality
(defvar electrify-return-match
  "[\]}\)]"
  "If this regexp matches the text after the cursor, do an \"electric\" return.")

(defun electrify-return-if-match (arg)
  "When text after cursor and ARG match, open and indent an empty line.
Do this between the cursor and the text.  Then move the cursor to the new line."
  (interactive "P")
  (let ((case-fold-search nil))
    (if (looking-at electrify-return-match)
	(save-excursion (newline-and-indent)))
    (newline arg)
    (indent-according-to-mode)))

;;; make escape act like C-g in evil-mode
(defun minibuffer-keyboard-quit ()
  "Abort recursive edit.
In Delete Selection mode, if the mark is active, just deactivate it;
then it takes a second \\[keyboard-quit] to abort the minibuffer."
  (interactive)
  (if (and delete-selection-mode transient-mark-mode mark-active)
      (setq deactivate-mark  t)
    (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
    (abort-recursive-edit)))

;;; suppress function not defined warnings caused by referring to functions not yet loaded with #' (sharp quotes).
(declare-function browse-url-default-macosx-browser nil)
(declare-function cider-repl-mode nil)
(declare-function flycheck-buffer nil)
(declare-function flycheck-list-errors nil)
(declare-function flycheck-next-error nil)
(declare-function flycheck-pos-tip-error-messages nil)
(declare-function flycheck-previous-error nil)
(declare-function magit-discard nil)
(declare-function markdown-insert-bold nil)
(declare-function markdown-insert-footnote nil)
(declare-function markdown-insert-hr nil)
(declare-function markdown-insert-image nil)
(declare-function markdown-insert-italic nil)
(declare-function markdown-insert-link nil)
(declare-function markdown-insert-strike-through nil)
(declare-function markdown-insert-uri nil)
(declare-function with-editor-cancel nil)
(declare-function with-editor-finish nil)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; user config                                                          ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; path fix for os x gui mode
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;;; os x keybinding fix
;; For iTerm: Go to Preferences > Profiles > (your profile) > Keys > Left option key acts as: > choose +Esc

;;; startup behavior
(setq inhibit-startup-message t)

;;; set default starting directory (avoid launching projectile at HOME or src root)
(defvar --user-home-dir (concat (getenv "HOME") "/"))
(defvar --user-src-dir (concat --user-home-dir "src/"))
(defvar --user-scratch-dir (concat --user-src-dir "scratch/"))
(unless (file-exists-p --user-scratch-dir)
  (make-directory --user-scratch-dir t))
(when (or (string= default-directory "~/")
          (string= default-directory --user-home-dir)
          (string= default-directory --user-src-dir))
  (setq default-directory --user-scratch-dir))

;;; default to utf8
(prefer-coding-system 'utf-8)

;;; pretty symbols
(global-prettify-symbols-mode)

;;; highlight matching parens
(show-paren-mode 1)
(setq show-paren-delay 0)

;;; show end of buffer in editing modes (easily see empty lines)
(add-hook 'prog-mode-hook #'vi-tilde-fringe-mode)
(add-hook 'markdown-mode-hook #'vi-tilde-fringe-mode)

;;; themes
(if (display-graphic-p)
    ;; load graphical theme
    (progn
      (load-theme 'solarized-dark t)
      (load-theme 'solarized-light t))
  ;; load terminal theme
  (load-theme 'ample t))

;;; cycle themes
(setq cycle-themes-theme-list
      '(solarized-dark
	solarized-light))
(require 'cycle-themes)

;;; font settings
(set-face-attribute 'default nil :family "Menlo" :height 140 :weight 'normal)

;;; turn off menu-bar, tool-bar, and scroll-bar
(menu-bar-mode -1)
(when (display-graphic-p)
  (tool-bar-mode -1)
  (scroll-bar-mode -1))

;;; hi-light current line
(global-hl-line-mode)

;;; smoother scrolling
(setq scroll-margin 8
      scroll-conservatively 9999
      scroll-step 1)

;;; fix ls warning when dired launches on macOS
(when (eq system-type 'darwin)
  (require 'ls-lisp)
  (setq ls-lisp-use-insert-directory-program nil))

;;; initial widow size and position (`left . -1` is to get close to right align)
(setq initial-frame-alist '((top . 0) (left . -1) (width . 120) (height . 80)))

;;; tab settings
(setq indent-tabs-mode nil)

;;; remember cursor position in buffers
(if (version< emacs-version "25.1")
    (lambda ()
      (require 'saveplace)
      (setq-default save-place t))
  (save-place-mode 1))

;;; store auto-save and backup files in ~/.emacs.d/backups/
(defvar --backup-dir (concat user-emacs-directory "backups"))
(unless (file-exists-p --backup-dir)
  (make-directory --backup-dir t))
(setq backup-directory-alist `((".*" . ,--backup-dir)))
(setq auto-save-file-name-transforms `((".*" ,--backup-dir t)))
(setq backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t
      auto-save-default t)

;;; file type to mode mappings
(add-to-list 'auto-mode-alist '(".editorconfig" . editorconfig-conf-mode))
(add-to-list 'auto-mode-alist '("\\.emacs"      . emacs-lisp-mode))
(add-to-list 'auto-mode-alist '("\\.md"         . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.txt"        . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.sls"        . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yml"        . yaml-mode))

;;; version control
(setq vc-follow-symlinks t)

;;; set initial evil state for particular modes
(cl-loop for (mode . state) in '((cider-test-report-mode . emacs)
                                 (dired-mode             . normal)
				 (magit-mode             . normal)
				 (magit-status-mode      . emacs)
				 (magit-diff-mode        . normal)
				 (magit-log-mode         . normal)
				 (magit-process-mode     . normal)
				 (magit-popup-mode       . emacs))
	 do (evil-set-initial-state mode state))

;;; declutter the modeline
(require 'diminish)
;; altered
(eval-after-load "auto-complete"       '(diminish #'auto-complete-mode "⇥"))
                                        (diminish #'auto-revert-mode "↺")
(eval-after-load "clj-refactor"        '(diminish #'clj-refactor-mode "↻"))
(eval-after-load "editorconfig"        '(diminish #'editorconfig-mode "↹"))
(eval-after-load "flycheck"            '(diminish #'flycheck-mode "✓"))
(eval-after-load "paredit"             '(diminish #'paredit-mode "‹›"))
;; hidden
(eval-after-load "column-enforce-mode" '(diminish #'column-enforce-mode))
(eval-after-load "helm"                '(diminish #'helm-mode))
(eval-after-load "undo-tree"           '(diminish #'undo-tree-mode))
(eval-after-load "vi-tilde-fringe"     '(diminish #'vi-tilde-fringe-mode))
(eval-after-load "which-key"           '(diminish #'which-key-mode))
(eval-after-load "yasnippet"           '(diminish #'yas-minor-mode))

;;; modeline tweaks
(setq projectile-mode-line '(:eval (format " [%s] " (projectile-project-name))))

;;; open urls in default browser
(when (display-graphic-p)
  (setq browse-url-browser-function #'browse-url-default-macosx-browser))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; key bindings                                                         ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; (e)dit (e)macs user init file
(evil-leader/set-key "ee" (lambda () (interactive) (find-file user-init-file)))

;;; (s)ource (e)macs user init file
(evil-leader/set-key "se" (lambda () (interactive) (load-file user-init-file)))

;;; (r)estart (e)macs
(evil-leader/set-key "re" #'restart-emacs)

;;; evil emacs conflicts
(define-key evil-normal-state-map (kbd "C-u") #'evil-scroll-up)
(define-key evil-visual-state-map (kbd "C-u") #'evil-scroll-up)

;;; evil vim inconsistencies
(define-key evil-visual-state-map (kbd "x") #'evil-delete)

;;; evil escape (use escape for C-g in evil-mode)
(define-key evil-normal-state-map           [escape] #'keyboard-quit)
(define-key evil-visual-state-map           [escape] #'keyboard-quit)
(define-key minibuffer-local-map            [escape] #'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map         [escape] #'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] #'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] #'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map    [escape] #'minibuffer-keyboard-quit)
(global-set-key                             [escape] #'evil-exit-emacs-state)

;;; evil line movement tweaks
(define-key evil-motion-state-map "j" #'evil-next-visual-line)
(define-key evil-motion-state-map "k" #'evil-previous-visual-line)
(define-key evil-visual-state-map "j" #'evil-next-visual-line)
(define-key evil-visual-state-map "k" #'evil-previous-visual-line)

;;; cycle themes
(evil-leader/set-key "ct" #'cycle-themes)

;;; full screen toggle
(global-set-key (kbd "s-<return>") #'toggle-frame-fullscreen) ; s = super (⌘ on mac)

;;; hide others with macOS default keyboard shortcut of `⌥⌘H`
(global-set-key (kbd "M-s-˙") #'ns-do-hide-others)
;; the `˙` in the above keybind is due to opt h producing that char

;;; window splitting
(global-set-key (kbd "C--")  #'evil-window-split)
(global-set-key (kbd "C-\\") #'evil-window-vsplit)
(global-set-key (kbd "C-=")  #'balance-windows)

;;; resize windows
(global-set-key (kbd "s-<right>") #'evil-window-increase-width)
(global-set-key (kbd "s-<left>")  #'evil-window-decrease-width)
(global-set-key (kbd "s-<up>")    #'evil-window-increase-height)
(global-set-key (kbd "s-<down>")  #'evil-window-decrease-height)

;;; move to next / prev window
(define-key evil-motion-state-map (kbd "C-j") #'evil-window-next)
(define-key evil-motion-state-map (kbd "C-k") #'evil-window-prev)
(define-key evil-motion-state-map (kbd "C-h") #'evil-window-left)
(define-key evil-motion-state-map (kbd "C-l") #'evil-window-right)

;;; close windows
;; evil-mode built in with `C-w c`

;;; close all other windows
(define-key evil-motion-state-map (kbd "C-z") #'zoom-window-zoom)
(evil-leader/set-key "wm" #'delete-other-windows) ; (w)indow (m)ain

;;; clear / recenter screen
(evil-leader/set-key "cs" #'recenter-top-bottom)     ; (c)lear (s)creen
(evil-leader/set-key "cr" #'cider-repl-clear-buffer) ; (c)lear (r)epl

;;; text scale
(global-set-key (kbd "s-+") #'text-scale-increase)
(global-set-key (kbd "s--") #'text-scale-decrease)
(global-set-key (kbd "s-=") #'text-scale-adjust)

;;; bookmarks
(evil-leader/set-key "ml" #'bookmark-jump)
(evil-leader/set-key "mj" #'bookmark-jump)
(evil-leader/set-key "ms" #'bookmark-set)
(evil-leader/set-key "md" #'bookmark-delete)

;;; set emacs command hotkey (M-x) to (helm-M-x)
(global-set-key (kbd "M-x") #'helm-M-x)

;;; helm menu nav
(define-key helm-map (kbd "s-j") #'helm-next-line)
(define-key helm-map (kbd "s-k") #'helm-previous-line)

;;; projects / files / buffers
(evil-leader/set-key "F"  #'find-file)                      ; (F)ind file
(evil-leader/set-key "t"  #'helm-projectile-find-file-dwim) ; emulate command-(t)
(evil-leader/set-key "b"  #'helm-buffers-list)              ; switch to (b)uffer
(evil-leader/set-key "kb" #'kill-buffer)                    ; (k)ill (b)uffer
(evil-leader/set-key "gf" #'helm-projectile-ag)             ; (g)rep in (f)iles

;;; dired navigation
;; g to update dired buffer info
;; s to toggle between sort by name and by date/time
;; for creating, deleting, renaming, just toggle shell visor, then update dired

;;; toggle/open shell
(evil-leader/set-key "sv" (lambda () (interactive)               ; toggle (s)hell (v)isor
			    (multi-term-dedicated-toggle)
			    (multi-term-dedicated-select)))
(evil-leader/set-key "sn" 'multi-term)                      ; toggle (s)hell (n)ew

;;; multi term keybind setup - thanks to rawsyntax (eric h)
(defcustom term-unbind-key-list
  '("C-z" "C-x" "C-c" "C-h" "C-y" "<ESC>")
  "The key list that will need to be unbind."
  :type 'list
  :group 'multi-term)

(defcustom term-bind-key-alist
  '(("C-c C-c" . term-interrupt-subjob)
    ("s-k"     . term-send-up)
    ("s-j"     . term-send-down)
    ("s-{"     . multi-term-prev)
    ("s-}"     . multi-term-next))
  "The key alist that will need to be bind.
If you do not like default setup, modify it, with (KEY . COMMAND) format."
  :type  'alist
  :group 'multi-term)

(evil-define-key 'normal term-raw-map "p"         #'term-paste)
(evil-define-key 'normal term-raw-map "j"         #'term-send-down)
(evil-define-key 'normal term-raw-map "k"         #'term-send-up)
(evil-define-key 'normal term-raw-map (kbd "C-c") #'term-send-raw)
(evil-define-key 'insert term-raw-map (kbd "C-c") #'term-send-raw)

;;; electric return
(global-set-key (kbd "RET") #'electrify-return-if-match)

;;; jump to line / word
(evil-leader/set-key "jl" #'evil-ace-jump-line-mode)
(evil-leader/set-key "jw" #'evil-ace-jump-word-mode)
(evil-leader/set-key "jc" #'evil-ace-jump-char-mode)

;;; remove search highlight
(evil-leader/set-key "/" #'evil-search-highlight-persist-remove-all)

;;; commenting
(evil-leader/set-key "cl" #'evilnc-comment-or-uncomment-lines)
(evil-leader/set-key "cp" #'evilnc-comment-or-uncomment-paragraphs)

;;; kill-ring
(evil-leader/set-key "kr" #'helm-show-kill-ring)

;;; doc search
(evil-leader/set-key "d" #'dash-at-point)

;;; line number toggle
(evil-leader/set-key "nn" #'linum-mode)

;; flycheck
(evil-leader/set-key "fcb" #'flycheck-buffer)         ; (f)ly(c)heck (b)uffer
(evil-leader/set-key "fcn" #'flycheck-next-error)     ; (f)ly(c)heck (n)ext
(evil-leader/set-key "fcp" #'flycheck-previous-error) ; (f)ly(c)heck (p)revious
(evil-leader/set-key "fcl" #'flycheck-list-errors)    ; (f)ly(c)heck (l)ist

;;; paredit
(evil-leader/set-key "W"  #'paredit-wrap-sexp)
(evil-leader/set-key "w(" #'paredit-wrap-sexp)
(evil-leader/set-key "w[" #'paredit-wrap-square)
(evil-leader/set-key "w{" #'paredit-wrap-curly)
;; barf == push out of current sexp
;; slurp == pull into current sexp
(evil-leader/set-key ">>" #'paredit-forward-barf-sexp)
(evil-leader/set-key "><" #'paredit-forward-slurp-sexp)
(evil-leader/set-key "<<" #'paredit-backward-barf-sexp)
(evil-leader/set-key "<>" #'paredit-backward-slurp-sexp)
(evil-leader/set-key "D"  #'paredit-splice-sexp)         ; del surrounding ()[]{}
(evil-leader/set-key "rs" #'raise-sexp)                  ; (r)aise (s)exp
(evil-leader/set-key "ss" #'paredit-split-sexp)          ; (s)plit (s)exp
(evil-leader/set-key "xs" #'kill-sexp)                   ; (x)delete (s)exp
(evil-leader/set-key "xS" #'backward-kill-sexp)          ; (x)delete (S)exp backward
;; use `Y` not `yy` for yanking a line maintaining balanced parens
;; use `y%` for yanking a s-expression

;;; magit
;; you can also use built-in hotkeys from status mode:
;; ? - show commands
;; s - stage S - stage all
;; c - commit (then c again to move to commit message and change review)
;; b u - to set/reset the upstream
;; P u - push to push to upstream
;; b b - branch to choose a branch to checkout
;; b c - branch create and then checkout a branch
;; F u - pull from upstream
(evil-leader/set-key "gg"  #'magit-dispatch-popup)
(evil-leader/set-key "gst" #'magit-status)
(evil-leader/set-key "gd"  #'magit-diff-working-tree)
(evil-leader/set-key "gco" #'magit-checkout)
(evil-leader/set-key "gcm" #'magit-checkout)
(evil-leader/set-key "gcb" #'magit-branch-and-checkout)
(evil-leader/set-key "gl"  #'magit-pull-from-upstream)
(evil-leader/set-key "gaa" #'magit-stage-modified)
(evil-leader/set-key "grh" #'magit-reset-head)
(evil-leader/set-key "gca" #'magit-commit)
(evil-leader/set-key "cc"  #'with-editor-finish)
(evil-leader/set-key "cC"  #'with-editor-cancel)
(evil-leader/set-key "gp"  #'magit-push-current-to-upstream)
;; let's improve evil-mode compatability
(with-eval-after-load "magit"
  (define-key magit-status-mode-map (kbd "k") #'previous-line)
  (define-key magit-status-mode-map (kbd "K") #'magit-discard)
  (define-key magit-status-mode-map (kbd "j") #'next-line))

;;; clojure - cider
(evil-leader/set-key "ri"  #'cider-jack-in)                     ; (r)epl (i)nitialize
(evil-leader/set-key "rr"  #'cider-restart)                     ; (r)epl (r)estart
(evil-leader/set-key "rq"  #'cider-quit)                        ; (r)epl (q)uit
(evil-leader/set-key "rc"  #'cider-connect)                     ; (r)epl (c)onnect
(evil-leader/set-key "eb"  #'cider-eval-buffer)                 ; (e)val (b)uffer
(evil-leader/set-key "ef"  #'cider-eval-defun-at-point)         ; (e)val de(f)un
(evil-leader/set-key "es"  #'cider-eval-last-sexp)              ; (e)val (s)-expression
(evil-leader/set-key "rtn" #'cider-test-run-ns-tests)           ; (r)un (t)ests (n)amespace
(evil-leader/set-key "rtp" #'cider-test-run-project-tests)      ; (r)un (t)ests (p)roject
(evil-leader/set-key "rtl" #'cider-test-run-loaded-tests)       ; (r)un (t)ests (l)oaded namespaces
(evil-leader/set-key "rtf" #'cider-test-rerun-failed-tests)     ; (r)erun (t)ests (f)ailed tests
(evil-leader/set-key "rta" #'cider-auto-test-mode)              ; (r)un (t)ests (a)utomatically
(evil-leader/set-key "rb"  #'cider-switch-to-repl-buffer)       ; (r)epl (b)uffer
(evil-leader/set-key "rp"  #'cider-repl-toggle-pretty-printing) ; (r)epl (p)retty print
(evil-leader/set-key "ff"  #'cider-format-defun)                ; (f)ormat (f)orm
(evil-leader/set-key "fr"  #'cider-format-region)               ; (f)ormat (r)egion
(evil-leader/set-key "fb"  #'cider-format-buffer)               ; (f)ormat (b)uffer
(evil-leader/set-key "rf"  #'cljr-helm)                         ; (c)lj (r)efactor
;; set evil style j and k in cider-test-report-mode
(with-eval-after-load "cider"
  (define-key cider-test-report-mode-map (kbd "k") #'previous-line)
  (define-key cider-test-report-mode-map (kbd "j") #'next-line))

;;; markdown
(evil-leader/set-key "Mb" #'markdown-insert-bold)
(evil-leader/set-key "Me" #'markdown-insert-italic)
(evil-leader/set-key "Ms" #'markdown-insert-strike-through)
(evil-leader/set-key "Ml" #'markdown-insert-link)
(evil-leader/set-key "Mu" #'markdown-insert-uri)
(evil-leader/set-key "Mi" #'markdown-insert-image)
(evil-leader/set-key "Mh" #'markdown-insert-hr)
(evil-leader/set-key "Mf" #'markdown-insert-footnote)

;;; ruby-mode
;; TODO keybinds for buffer eval

;;; python-mode
;; TODO keybinds for buffer eval

;;;; report total load time
(let ((elapsed (float-time (time-subtract (current-time)
					  emacs-start-time))))
  (message "Loaded emacs in %.3fs" elapsed))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Emacs file footer settings                                           ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Local Variables:
;; byte-compile-warnings: (not free-vars)
;; End:

;;; emacs.el ends here



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Values Set via Customize                                             ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )