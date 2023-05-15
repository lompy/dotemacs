(server-start)

(setq custom-file  (expand-file-name "custom.el" user-emacs-directory))
(load-file custom-file)
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(setq disabled-command-function nil)
(fset 'yes-or-no-p 'y-or-n-p)

;; Packages
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package exec-path-from-shell
  :ensure t
  :if (memq window-system '(mac ns x))
  :config
  (setq exec-path-from-shell-variables '("PATH" "GOPATH"))
  (exec-path-from-shell-initialize))

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

(use-package no-littering)
(use-package saveplace)
(use-package ag)

(use-package smex
  :ensure t
  :bind (("M-x" . smex))
  :config (smex-initialize))

(use-package ob-go)
(require 'ob-clojure)
(use-package cider)

(use-package undo-tree
  :ensure t
  :defer t
  :custom
  (undo-tree-auto-save-history nil))
(use-package use-package-chords
  :ensure t
  :config (key-chord-mode t))
(use-package evil-commentary
  :ensure t
  :defer t)
(use-package evil-surround
  :ensure t
  :defer t)
(use-package evil
  :demand t
  :chords
  (:map evil-insert-state-map
    ("jk" . evil-normal-state)
    ("kj" . evil-normal-state))
  :bind
  (:map evil-normal-state-map
    ("\C-e" . end-of-line)
    ("<leader>h" . whitespace-mode)
    ("<leader>c" . whitespace-cleanup)
    ("<leader>l" . linum-mode))
  (:map evil-insert-state-map
    ("\C-a" . move-beginning-of-line)
    ("\C-e" . end-of-line))
  :custom
  (evil-shift-width 2)
  (evil-undo-system 'undo-tree)
  (evil-want-Y-yank-to-eol t)
  :config
  (evil-make-overriding-map xref--xref-buffer-mode-map 'normal)
  (evil-set-leader 'normal (kbd "SPC"))
  (evil-mode t)
  (require 'undo-tree)
  (global-undo-tree-mode)
  (require 'evil-commentary)
  (evil-commentary-mode)
  (require 'evil-surround)
  (global-evil-surround-mode))

(use-package origami
  :ensure t
  :defer t)

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory "~/Dropbox/Projects/kbase/org-roam")
  :bind (("C-c n l" . org-roam-buffer-toggle)
	 ("C-c n f" . org-roam-node-find)
	 ("C-c n i" . org-roam-node-insert))
  :init
  (setq org-roam-v2-ack t)
  :config
  (org-roam-db-autosync-enable))

(use-package geiser)
(use-package geiser-racket)

;; Custom functions
(defun compile-with-key (key command)
  "Sets global KEY to run COMMAND in projectile root dir in comint mode."
  (global-set-key (kbd key) ((lambda () (projectile-compile-project command)))))

(defun what-face (pos)
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))

;; Bindings
(global-set-key (kbd "C-x C-b") 'switch-to-buffer)
(global-set-key (kbd "C-x b") 'list-buffers)
(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "C-c a") 'org-agenda)

;; ;; Fast shortcuts
;; (require-package 'key-chord)
;; (require 'key-chord)
;; (key-chord-mode 1)
;; (key-chord-define evil-normal-state-map " c" 'string-inflection-cycle)

(use-package projectile
  :ensure t
  :custom
  (projectile-mode-line-prefix " Pj")
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
	      ("C-c p" . projectile-command-map)))

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

(use-package go-mode
  :mode "\\.go\\'"
  :config
  (defun my-go-mode-setup ()
    "Basic Go mode setup."
    (add-hook 'before-save-hook #'lsp-format-buffer t t)
    (add-hook 'before-save-hook #'lsp-organize-imports t t))
  (add-hook 'go-mode-hook #'my-go-mode-setup))
;;(add-hook 'before-save-hook 'gofmt-before-save)

(use-package ruby-mode
  :mode "\\.rb\\'"
  :ensure nil
  :custom
  (ruby-insert-encoding-magic-comment nil "Not needed in Ruby 2")
  ;;:ensure-system-package (solargraph . "gem install --user-install solargraph")
  )

(use-package kotlin-mode)

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-mode lsp-deferred)
  :hook ((ruby-mode go-mode) . lsp-deferred)
  :custom
  (lsp-prefer-flymake t)
  (lsp-enable-indentation nil)
  (lsp-enable-on-type-formatting nil)
  (lsp-file-watch-threshold nil)
  (lsp-solargraph-multi-root nil)
  ;; for filling args placeholders upon function completion candidate selection
  ;; lsp-enable-snippet and company-lsp-enable-snippet should be nil with
  ;; yas-minor-mode is enabled: https://emacs.stackexchange.com/q/53104
  :config
  (lsp-modeline-code-actions-mode)
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration))
(use-package lsp-ui)
(use-package lsp-treemacs)

(use-package company
  :defer 2
  :diminish
  :custom
  (company-begin-commands '(self-insert-command))
  (company-idle-delay .1)
  (company-minimum-prefix-length 3)
  (company-show-numbers t)
  (company-tooltip-align-annotations 't)
  (global-company-mode t))

(use-package company-go
  :after (go-mode ruby-mode company)
  :config (add-to-list 'company-backends 'company-go))

;; Fix face size
(if (eq system-type 'darwin) (set-face-attribute 'default nil :height 150))

;; Old config for insparation
;; ;; (require 'smartparens)
;; ;; (require 'smartparens-ruby)
;; ;; (require 'org-drill)
;; (dim-minor-names
;;  '((evil-commentary-mode "")
;;    (subword-mode "")))
;; (add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
;; (add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
;; (add-to-list 'auto-mode-alist '("\\.gemspec$" . ruby-mode))
;; (add-to-list 'auto-mode-alist '("\\.ru$" . ruby-mode))
;; (add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))
;; (add-to-list 'auto-mode-alist '("Guardfile$" . ruby-mode))
;; (add-to-list 'auto-mode-alist '("\\.scss$" . sass-mode))
;; (add-to-list 'auto-mode-alist '("\\.slim$" . slim-mode))
;; (add-to-list 'auto-mode-alist '("\\.js.erb$" . web-mode))
;; (add-to-list 'auto-mode-alist '("\\.coffee.erb$" . web-mode))
;; (add-to-list 'auto-mode-alist '("\\.es6$" . js-mode))
;; (add-hook 'ruby-mode-hook 'subword-mode)
;; (add-hook 'js-mode-hook 'subword-mode)
;; (projectile-mode +1)
;; (require 'smex)
;; (global-set-key (kbd "M-x") 'smex)
;; (global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; ;; (global-set-key (kbd "-") 'dired-jump)
;; (require 'string-inflection)
;; (require 'inf-ruby)
;; ;; (require 'ensime)
;; (add-hook 'after-init-hook 'inf-ruby-switch-setup)
;; (eval-after-load "hideshow"
;;   '(add-to-list 'hs-special-modes-alist
;;     `(ruby-mode
;;       ,(rx (or "def" "class" "module" "do" "{" "["))
;;       ,(rx (or "}" "]" "end"))
;;       ,(rx (or "#" "=begin"))
;;       ruby-forward-sexp nil)))

;; (eval-after-load "hideshow"
;;   '(add-to-list 'hs-special-modes-alist
;;     `(nxml-mode
;;       "<!--\\|<[^/>].*?[^/]>"
;;       "-->\\|</[^/>].*?[^/]>"
;;       "<!--"
;;       sgml-skip-tag-forward nil)))

;; (custom-set-variables
;;  ;; custom-set-variables was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(ag-ignore-list '("*.log"))
;;  '(align-c++-modes '(c++-mode c-mode java-mode go-mode))
;;  '(align-to-tab-stop nil)
;;  '(ansi-color-names-vector
;;    ["#212526" "#cc0000" "#4E9A06" "#C4A000" "#3465A4" "#75507B" "#06989A" "#eeeeec"])
;;  '(apropos-do-all t)
;;  '(avy-background t)
;;  '(backup-by-copying t)
;;  '(backup-directory-alist '(("." . "~/.emacs-backup/per-save")))
;;  '(blink-cursor-mode nil)
;;  '(coffee-tab-width 2)
;;  '(column-number-mode t)
;;  '(compilation-message-face 'default)
;;  '(cua-global-mark-cursor-color "#2aa198")
;;  '(cua-normal-cursor-color "#657b83")
;;  '(cua-overwrite-cursor-color "#b58900")
;;  '(cua-read-only-cursor-color "#859900")
;;  '(custom-enabled-themes '(my))
;;  '(custom-safe-themes
;;    '("f0ab02c006db21abe6b018330f0a45f056342d83fa931e8a9e17e2e0db2a457d" "d39a256380ad7c3a79ac25f1030e892e978bdf60f0bad50341fee2fc1c01f7a9" "e2e088f80bd20b73b4d944235dee854b5ecb25be73ff9bb0012eda0741e466bf" "26dae49349f2adf24d210e616f5ba363a953c0b582b7eb11edc1cfab5a70e24a" "7d5fce1bb8cf74d5132a84e3778ad83eec9b9ac53d415fb6b56cfc7c2ee092f7" "655dd115ab9c377edba03fecc26fcdb1ce865c7c12ab5f597abb59038409a55e" "8e7609c5acae87e2b007ecc419ab64280c214cae0d647350a476a3d00f502988" "c7b61a9a819c98a205a07da678c7888fc779ad701c450700d26f67e85bea2adf" "631b8f2c4f75ad37d02b65a912ff10f5a70a2e8674c0c6c774ad96a193ff2a40" "a8245b7cc985a0610d71f9852e9f2767ad1b852c2bdea6f4aadc12cce9c4d6d0" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" default))
;;  '(debug-on-error nil)
;;  '(delete-old-versions t)
;;  '(electric-indent-mode t)
;;  '(elfeed-db-directory "~/.emacs.d/elfeed")
;;  '(elfeed-enclosure-default-dir "~/.emacs.d/elfeed-enclosures")
;;  '(elfeed-feeds
;;    '("https://blog.golang.org/index" "http://martinfowler.com/feed.atom" "http://tenderlovemaking.com/atom.xml"))
;;  '(enable-local-variables :safe)
;;  '(evil-emacs-state-modes
;;    '(archive-mode bbdb-mode biblio-selection-mode bookmark-bmenu-mode bookmark-edit-annotation-mode browse-kill-ring-mode bzr-annotate-mode calc-mode cfw:calendar-mode completion-list-mode Custom-mode debugger-mode delicious-search-mode desktop-menu-blist-mode desktop-menu-mode doc-view-mode dvc-bookmarks-mode dvc-diff-mode dvc-info-buffer-mode dvc-log-buffer-mode dvc-revlist-mode dvc-revlog-mode dvc-status-mode dvc-tips-mode ediff-mode ediff-meta-mode efs-mode Electric-buffer-menu-mode emms-browser-mode emms-mark-mode emms-metaplaylist-mode emms-playlist-mode ess-help-mode etags-select-mode fj-mode gc-issues-mode gdb-breakpoints-mode gdb-disassembly-mode gdb-frames-mode gdb-locals-mode gdb-memory-mode gdb-registers-mode gdb-threads-mode gist-list-mode git-commit-mode git-rebase-mode gnus-article-mode gnus-browse-mode gnus-group-mode gnus-server-mode gnus-summary-mode google-maps-static-mode jde-javadoc-checker-report-mode magit-cherry-mode magit-diff-mode magit-log-mode magit-log-select-mode magit-popup-mode magit-popup-sequence-mode magit-process-mode magit-reflog-mode magit-refs-mode magit-revision-mode magit-stash-mode magit-stashes-mode magit-status-mode magit-mode magit-branch-manager-mode magit-commit-mode magit-key-mode magit-rebase-mode magit-wazzup-mode mh-folder-mode monky-mode mu4e-main-mode mu4e-headers-mode mu4e-view-mode notmuch-hello-mode notmuch-search-mode notmuch-show-mode occur-mode org-agenda-mode package-menu-mode proced-mode rcirc-mode rebase-mode recentf-dialog-mode reftex-select-bib-mode reftex-select-label-mode reftex-toc-mode sldb-mode slime-inspector-mode slime-thread-control-mode slime-xref-mode sr-buttons-mode sr-mode sr-tree-mode sr-virtual-mode tar-mode tetris-mode tla-annotate-mode tla-archive-list-mode tla-bconfig-mode tla-bookmarks-mode tla-branch-list-mode tla-browse-mode tla-category-list-mode tla-changelog-mode tla-follow-symlinks-mode tla-inventory-file-mode tla-inventory-mode tla-lint-mode tla-logs-mode tla-revision-list-mode tla-revlog-mode tla-tree-lint-mode tla-version-list-mode twittering-mode urlview-mode vc-annotate-mode vc-dir-mode vc-git-log-view-mode vc-hg-log-view-mode vc-svn-log-view-mode vm-mode vm-summary-mode w3m-mode wab-compilation-mode xgit-annotate-mode xgit-changelog-mode xgit-diff-mode xgit-revlog-mode xhg-annotate-mode xhg-log-mode xhg-mode xhg-mq-mode xhg-mq-sub-mode xhg-status-extra-mode term-mode dired-mode undo-tree-visualizer-mode xref--xref-buffer-mode))
;;  '(evil-shift-width 2)
;;  '(exec-path
;;    '("/usr/local/sbin" "/usr/local/bin" "/usr/sbin" "/usr/bin" "/sbin" "/bin" "/usr/games" "/usr/local/games" "/snap/bin" "/usr/lib/emacs/24.5/x86_64-linux-gnu" "~/bin"))
;;  '(explicit-shell-file-name "/bin/zsh")
;;  '(fci-rule-color "gray69")
;;  '(fill-column 100)
;;  '(flycheck-disabled-checkers '(go-staticcheck))
;;  '(flycheck-rubocoprc ".rubocop_todo.yml")
;;  '(flycheck-ruby-executable "/usr/local/opt/rbenv/shims/ruby")
;;  '(flycheck-ruby-rubocop-executable "/usr/local/opt/rbenv/shims/bundle exec rubocop")
;;  '(global-evil-matchit-mode t)
;;  '(global-flycheck-mode t)
;;  '(global-undo-tree-mode t)
;;  '(global-whitespace-mode nil)
;;  '(highlight-changes-colors '("#d33682" "#6c71c4"))
;;  '(highlight-symbol-colors
;;    (--map
;;     (solarized-color-blend it "#fdf6e3" 0.25)
;;     '("#b58900" "#2aa198" "#dc322f" "#6c71c4" "#859900" "#cb4b16" "#268bd2")))
;;  '(highlight-symbol-foreground-color "#586e75")
;;  '(highlight-tail-colors
;;    '(("#eee8d5" . 0)
;;      ("#B4C342" . 20)
;;      ("#69CABF" . 30)
;;      ("#69B7F0" . 50)
;;      ("#DEB542" . 60)
;;      ("#F2804F" . 70)
;;      ("#F771AC" . 85)
;;      ("#eee8d5" . 100)))
;;  '(hl-bg-colors
;;    '("#DEB542" "#F2804F" "#FF6E64" "#F771AC" "#9EA0E5" "#69B7F0" "#69CABF" "#B4C342"))
;;  '(hl-fg-colors
;;    '("#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3"))
;;  '(ibuffer-hook
;;    (lambda nil
;;      (ibuffer-vc-set-filter-groups-by-vc-root)
;;      (unless
;;          (eq ibuffer-sorting-mode 'alphabetic)
;;        (ibuffer-do-sort-by-alphabetic))))
;;  '(ido-enable-flex-matching t)
;;  '(ido-everywhere t)
;;  '(ido-ignore-files '("\\`CVS/" "\\`#" "\\`.#" "\\`\\.\\./" "\\`\\./"))
;;  '(ido-mode 'both nil (ido))
;;  '(indent-tabs-mode nil)
;;  '(inhibit-startup-screen t)
;;  '(initial-frame-alist '((fullscreen . maximized)))
;;  '(js-indent-level 2)
;;  '(kept-new-versions 10)
;;  '(kept-old-versions 0)
;;  '(load-prefer-newer t)
;;  '(magit-diff-use-overlays nil)
;;  '(menu-bar-mode nil)
;;  '(mouse-yank-at-point t)
;;  '(nrepl-message-colors
;;    '("#dc322f" "#cb4b16" "#b58900" "#546E00" "#B4C342" "#00629D" "#2aa198" "#d33682" "#6c71c4"))
;;  '(org-agenda-files
;;    '("~/Dropbox/Apps/Orgzly/inbox.org" "~/Dropbox/Projects/wheely"))
;;  '(org-agenda-prefix-format
;;    '((agenda . " %i %-12:c%?-12t% s")
;;      (todo . " %i %-12:c")
;;      (tags . " %i %-12:c")
;;      (search . " %i %-12:c")))
;;  '(org-babel-java-compiler "javac")
;;  '(org-babel-js-cmd "node")
;;  '(org-babel-load-languages
;;    '((emacs-lisp . t)
;;      (ruby . t)
;;      (C . t)
;;      (clojure . t)
;;      (js . t)
;;      (java . t)))
;;  '(org-default-notes-file "~/Dropbox/org/Inbox.org")
;;  '(org-directory "~/Dropbox/Org")
;;  '(org-modules
;;    '(org-bbdb org-bibtex org-docview org-gnus org-habit org-info org-rmail org-w3m org-drill org-learn))
;;  '(org-roam-directory "/home/lompy/Dropbox/Projects/kbase/")
;;  '(org-todo-keyword-faces '(("PRGR" . "yellow3")))
;;  '(org-todo-keywords '((sequence "TODO" "DONE")))
;;  '(org-use-property-inheritance t)
;;  '(package-archives
;;    '(("gnu" . "http://elpa.gnu.org/packages/")
;;      ("org" . "http://orgmode.org/elpa/")
;;      ("stable" . "https://melpa.org/packages/")))
;;  '(package-selected-packages
;;    '(projectile org-download org-roam-server org-roam undo-tree go-snippets rust-mode elfeed hyperbole company-go ruby-hash-syntax terraform-mode avy chess go-mode dim editorconfig flycheck rbenv magit yaml-mode web-mode string-inflection spinner smex slim-mode shampoo scala-mode sass-mode rubocop robe rhtml-mode rainbow-mode queue popup multi-term markdown-mode key-chord ido-vertical-mode ibuffer-vc flx-ido exec-path-from-shell evil-surround evil-matchit evil-commentary company-inf-ruby coffee-mode clojurescript-mode ag))
;;  '(pos-tip-background-color "#eee8d5")
;;  '(pos-tip-foreground-color "#586e75")
;;  '(rbenv-show-active-ruby-in-modeline nil)
;;  '(require-final-newline t)
;;  '(rspec-docker-command "docker-compose exec")
;;  '(rspec-docker-container "app")
;;  '(rspec-use-docker-when-possible t)
;;  '(ruby-deep-indent-paren nil)
;;  '(ruby-electric-expand-delimiters-list nil)
;;  '(ruby-end-insert-newline nil)
;;  '(ruby-insert-encoding-magic-comment nil)
;;  '(save-interprogram-paste-before-kill t)
;;  '(save-place-mode t nil (saveplace))
;;  '(scroll-bar-mode nil)
;;  '(select-enable-clipboard t)
;;  '(select-enable-primary t)
;;  '(smartrep-mode-line-active-bg (solarized-color-blend "#859900" "#eee8d5" 0.2))
;;  '(split-height-threshold 100)
;;  '(standard-indent 2)
;;  '(term-default-bg-color "#fdf6e3")
;;  '(term-default-fg-color "#657b83")
;;  '(term-mode-hook '(multi-term-keystroke-setup))
;;  '(tool-bar-mode nil)
;;  '(undo-tree-auto-save-history t)
;;  '(undo-tree-history-directory-alist '(("" . "~/.emacs.d/undo-tree-history")))
;;  '(undo-tree-mode-lighter "")
;;  '(undo-tree-visualizer-diff nil)
;;  '(uniquify-buffer-name-style 'forward nil (uniquify))
;;  '(vc-annotate-background nil)
;;  '(vc-annotate-background-mode t)
;;  '(vc-annotate-color-map
;;    '((20 . "#ffdddd")
;;      (40 . "#c85d17")
;;      (60 . "#be730b")
;;      (80 . "#b58900")
;;      (100 . "#a58e00")
;;      (120 . "#9d9100")
;;      (140 . "#959300")
;;      (160 . "#8d9600")
;;      (180 . "#859900")
;;      (200 . "#669b32")
;;      (220 . "#579d4c")
;;      (240 . "#489e65")
;;      (260 . "#399f7e")
;;      (280 . "#2aa198")
;;      (300 . "#2898af")
;;      (320 . "#2793ba")
;;      (340 . "#268fc6")
;;      (360 . "#268bd2")))
;;  '(vc-annotate-very-old-color nil)
;;  '(vc-make-backup-files t)
;;  '(version-control t)
;;  '(weechat-color-list
;;    '(unspecified "#fdf6e3" "#eee8d5" "#990A1B" "#dc322f" "#546E00" "#859900" "#7B6000" "#b58900" "#00629D" "#268bd2" "#93115C" "#d33682" "#00736F" "#2aa198" "#657b83" "#839496"))
;;  '(whitespace-action '(cleanup))
;;  '(whitespace-display-mappings
;;    '((space-mark 32
;;                  [183]
;;                  [46])
;;      (space-mark 160
;;                  [164]
;;                  [95])
;;      (tab-mark 9
;;                [187 9]
;;                [92 9])))
;;  '(whitespace-line-column 100)
;;  '(whitespace-style
;;    '(face tabs spaces trailing space-before-tab newline indentation empty space-after-tab space-mark tab-mark newline-mark))
;;  '(xterm-color-names
;;    ["#eee8d5" "#dc322f" "#859900" "#b58900" "#268bd2" "#d33682" "#2aa198" "#073642"])
;;  '(xterm-color-names-bright
;;    ["#fdf6e3" "#cb4b16" "#93a1a1" "#839496" "#657b83" "#6c71c4" "#586e75" "#002b36"]))

;; ;; Sane defaults
;; (global-set-key (kbd "M-/") 'hippie-expand)

;; (global-set-key (kbd "C-s") 'isearch-forward-regexp)
;; (global-set-key (kbd "C-r") 'isearch-backward-regexp)
;; (global-set-key (kbd "C-M-s") 'isearch-forward)
;; (global-set-key (kbd "C-M-r") 'isearch-backward)
;; (global-set-key (kbd "C-c C-r") 'term-send-reverse-search-history)
;; (global-set-key (kbd "C-c M-x") 'term-send-M-x)
;; (global-set-key (kbd "C-c <escape>") 'term-send-esc)
;; (global-set-key (kbd "C-c C-d") 'term-send-eof)
;; (global-set-key (kbd "C-6") 'evil-switch-to-windows-last-buffer)
;; (global-set-key (kbd "C-c c") 'org-capture)
;; (global-set-key (kbd "C-c a") 'org-agenda)
;; (defun evil-forward-symbol (&optional count)
;;   "Move forward to beginning of evil-symbol.  The motion is repeated COUNT times."
;;   (interactive)
;;   (evil-forward-beginning 'evil-symbol count))
;; (global-set-key (kbd "M-o") 'evil-forward-symbol)
;; (defun evil-backward-symbol (&optional count)
;;   "Move backward to beginning of evil-symbol.  The motion is repeated COUNT times."
;;   (interactive)
;;   (evil-backward-beginning 'evil-symbol count))
;; (global-set-key (kbd "M-O") 'evil-backward-symbol)
;; (evil-define-key 'normal org-mode-map (kbd "<tab>") 'org-cycle)

;; ;; Default and per-save backups go here:
;; (show-paren-mode 1)
;; (setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; (defun force-backup-of-buffer ()
;;   ;; Make a special "per session" backup at the first save of each
;;   ;; emacs session.
;;   (when (not buffer-backed-up)
;;     ;; Override the default parameters for per-session backups.
;;     (let ((backup-directory-alist '(("" . "~/.emacs-backup/per-session")))
;;           (kept-new-versions 3))
;;       (backup-buffer)))
;;   ;; Make a "per save" backup on each save.  The first save results in
;;   ;; both a per-session and a per-save backup, to keep the numbering
;;   ;; of per-save backups consistent.
;;   (let ((buffer-backed-up nil))
;;     (backup-buffer)))

;; (add-hook 'before-save-hook  'force-backup-of-buffer)

;; ;; Evil
;; (require-package 'evil)
;; (require 'evil)
;; (evil-mode)
;; (require 'evil-surround)
;; (global-evil-surround-mode t)
;; (defun copy-to-end-of-line ()
;;   (interactive)
;;   (evil-yank (point) (point-at-eol)))
;; (define-key evil-normal-state-map "Y" 'copy-to-end-of-line)

;; (global-undo-tree-mode)

;; ;; Coursor colors
;; (setq evil-emacs-state-cursor '("light blue" box))
;; (setq evil-normal-state-cursor '("blue" box))
;; (setq evil-visual-state-cursor '("orange" box))
;; (setq evil-insert-state-cursor '("blue" bar))
;; (setq evil-replace-state-cursor '("blue" hollow))
;; (setq evil-operator-state-cursor '("red" hollow))

;; ;; Emacs bindings in insert state

;; ;; Fast commenting
;; (require-package 'evil-commentary)
;; (require 'evil-commentary)
;; (evil-commentary-mode)

;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(default ((t (:inherit nil :stipple nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 150 :width normal :foundry "unknown" :family "JetBrains Mono"))))
;;  '(dired-directory ((t (:inherit font-lock-keyword-face))))
;;  '(erb-face ((t nil)))
;;  '(font-lock-constant-face ((t nil)))
;;  '(font-lock-function-name-face ((t nil)))
;;  '(font-lock-regexp-grouping-construct ((t (:foreground "#5c3566"))))
;;  '(font-lock-string-face ((t (:foreground "#5c3566"))))
;;  '(font-lock-type-face ((t nil)))
;;  '(font-lock-variable-name-face ((t nil)))
;;  '(term ((t (:inherit default))))
;;  '(term-color-blue ((t (:background "#3465A4" :foreground "#3465A4"))))
;;  '(term-color-cyan ((t (:background "#06989A" :foreground "#06989A"))))
;;  '(term-color-green ((t (:background "#4E9A06" :foreground "#4E9A06"))))
;;  '(term-color-magenta ((t (:background "#75507B" :foreground "#75507B"))))
;;  '(term-color-white ((t (:background "grey92" :foreground "grey92"))))
;;  '(term-color-yellow ((t (:background "#C4A000" :foreground "#C4A000"))))
;;  '(undo-tree-visualizer-active-branch-face ((t (:foreground "black" :weight extra-bold))))
;;  '(undo-tree-visualizer-default-face ((t (:foreground "gray48"))))
;;  '(undo-tree-visualizer-register-face ((t (:foreground "yellow4"))))
;;  '(undo-tree-visualizer-unmodified-face ((t (:foreground "cyan3"))))
;;  '(web-mode-html-attr-name-face ((t nil)))
;;  '(web-mode-html-tag-bracket-face ((t nil)))
;;  '(web-mode-html-tag-custom-face ((t nil)))
;;  '(web-mode-html-tag-face ((t nil)))
;;  '(web-mode-symbol-face ((t nil)))
;;  '(whitespace-empty ((t (:background "old lace" :foreground "light gray"))))
;;  '(whitespace-indentation ((t (:foreground "firebrick"))))
;;  '(whitespace-line ((t nil)))
;;  '(whitespace-space ((t (:inherit default :foreground "grey81"))))
;;  '(whitespace-trailing ((t (:background "old lace" :foreground "light gray")))))

;; ;;(defun projectile-run-multi-term ()
;; ;;  "Invoke `multi-term' in the project's root."
;; ;;  (interactive)
;; ;;  (let* ((term (concat "term " (projectile-project-name)))
;; ;;         (buffer (concat "*" term "*")))
;; ;;    (unless (get-buffer buffer)
;; ;;      (projectile-with-default-dir (projectile-project-root)
;; ;;        (set-buffer buffer)
;; ;;        (multi-term-internal)))
;; ;;    (switch-to-buffer buffer)))
;; (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

;; (defun insert-camelized-file-name ()
;;   "Insert camelize file name at point"
;;   (interactive)
;;   (let ((file-name (file-name-base (buffer-file-name (current-buffer)))))
;;     (insert (string-inflection-camelize-function file-name))))
;; (global-set-key (kbd "<f7>") 'insert-camelized-file-name)

;; (defadvice dired-create-directory (around inhibit-ido activate)
;;   "Inhibit Ido for the duration."
;;   (let ((orig-ido-everywhere  ido-everywhere))
;;     (unwind-protect
;;         (progn (ido-everywhere -1) ad-do-it)
;;       (when orig-ido-everywhere (ido-everywhere 1)))))

;; (put 'set-goal-column 'disabled nil)
;; (require 'rbenv)
;; (global-rbenv-mode)
;; (require 'exec-path-from-shell)
;; (exec-path-from-shell-initialize)

;; ;; go-mode
;; (add-hook 'before-save-hook 'gofmt-before-save)
;; (defun my-go-unused-imports-lines ()
;;   ;; FIXME Technically, -o /dev/null fails in quite some cases (on
;;   ;; Windows, when compiling from within GOPATH). Practically,
;;   ;; however, it has the same end result: There won't be a
;;   ;; compiled binary/archive, and we'll get our import errors when
;;   ;; there are any.
;;   (reverse (remove nil
;;                    (mapcar
;;                     (lambda (line)
;;                       (when (string-match "^\\(.+\\):\\([[:digit:]]+\\): imported and not used: \".+\".*$" line)
;;                         (let ((error-file-name (match-string 1 line))
;;                               (error-line-num (match-string 2 line)))
;;                           (if (string= (file-truename error-file-name) (file-truename buffer-file-name))
;;                               (string-to-number error-line-num)))))
;;                     (split-string (shell-command-to-string
;;                                    (concat go-command
;;                                            (if (string-match "_test\.go$" buffer-file-truename)
;;                                                " test -c"
;;                                              " build -o /dev/null"))) "\n")))))
;; (advice-add 'go-unused-imports-lines :override #'my-go-unused-imports-lines)

;; (define-key minibuffer-local-map
;;   [f3] (lambda () (interactive)
;;        (insert (buffer-name (current-buffer-not-mini)))))

;; (defun current-buffer-not-mini ()
;;   "Return current-buffer if current buffer is not the *mini-buffer*
;;   else return buffer before minibuf is activated."
;;   (if (not (window-minibuffer-p)) (current-buffer)
;;       (if (eq (get-lru-window) (next-window))
;;           (window-buffer (previous-window)) (window-buffer (next-window)))))

;; (defun my-increment-number-decimal (&optional arg)
;;   "Increment the number forward from point by 'arg'."
;;   (interactive "p*")
;;   (save-excursion
;;     (save-match-data
;;       (let (inc-by field-width answer)
;;         (setq inc-by (if arg arg 1))
;;         (skip-chars-backward "0123456789")
;;         (when (re-search-forward "[0-9]+" nil t)
;;           (setq field-width (- (match-end 0) (match-beginning 0)))
;;           (setq answer (+ (string-to-number (match-string 0) 10) inc-by))
;;           (when (< answer 0)
;;             (setq answer (+ (expt 10 field-width) answer)))
;;           (replace-match (format (concat "%0" (int-to-string field-width) "d")
;;                                  answer)))))))

;; (defun my-decrement-number-decimal (&optional arg)
;;   (interactive "p*")
;;   (my-increment-number-decimal (if arg (- arg) -1)))

;; (global-set-key (kbd "C-c +") 'my-increment-number-decimal)
;; (global-set-key (kbd "C-c -") 'my-decrement-number-decimal)
;; ;; (nconc org-babel-default-header-args:java
;; ;;        '((:dir . nil)
;; ;;          (:results . value)))
;; ;;; init.el ends here
