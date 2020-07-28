---
authors:
  - Patrick Ferris
title: Configuring OCaml Tools for your Editor
date: 2020-07-27 09:35:49
description: Add syntax highlighting and code completion to your editor
users:
  - Beginner
  - Teacher
  - Library Authors
  - Application Developers
tools:
  - Merlin
---

## Overview

---

Having a helpful development environment can boost productivity and help catch errors early. OCaml has a powerful type system which reduces runtime errors, with a good editor setup you'll be able to catch them before you run `dune build`.

## Recommended Workflow

---

The recommended editor for OCaml is **Visual Studio Code** - an editor with a rich ecosystem of useful plugins, themes and developer tools. 

To get the best setup, there is a marketplace plugin and an opam package that must be installed. 

```bash
# This is the language server protocol for OCaml
opam install ocaml-lsp-server

# Install the OCaml Platform on VS Code Marketplace 
```

From here make sure to add a `workplace` to VS Code for your project. And watch out for the following errors: 

- VS Code might complain about not being able to find `ocaml-lsp` - this is done on a per switch basis and clicking on the dialog box should let you pick the switch you installed it on.

## Alternatives

---

### VS Code

Other extensions exist which offer support for OCaml and Reason including: 

[hackwaly/vscode-ocaml](https://github.com/hackwaly/vscode-ocaml)

[reasonml-editor/vscode-reasonml](https://github.com/reasonml-editor/vscode-reasonml)

### Vim

The to use with vim is merlin. OCaml LSP is the next generation of merlin, but for vim you will need merlin installed. There is also a useful opam plugin for getting up and running with the merlin features:

```bash
opam install merlin ocp-indent 
opam user-setup install 
```

To get code completion you will need to enable omnipresent in your `.vimrc` file: 

```
filetype plugin on
set omnifunc=syntaxcomplete#Complete
```

Then whilst in `INSERT` mode type `ctrl+c ctrl+o` to see completions for something like `List.m`. 

For syntax errors you need to add *syntastic* as a vim plugin. For this you'll need a vim plugin manager like pathogen. The [syntastic documentation](https://github.com/vim-syntastic/syntastic) will let you get started and then add the following to your `.vimrc` file. 

```
execute pathogen#infect()

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_ocaml_checkers = ['merlin']
```

For more features and information be sure to read the wiki on merlin linked in the resources. 

### Emacs

The workflow for emacs is very similar to vim. 

```bash
opam install merlin ocp-indent 
opam user-setup install 
```

After that the documentation in "Emacs from Scratch" linked in the resources tag will guide you through setting up OCaml with emacs.