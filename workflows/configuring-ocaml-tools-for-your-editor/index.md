---
authors:
  - Patrick Ferris
title: Configuring OCaml Tools for your Editor
date: 2020-08-05 11:00:45
description: Add syntax highlighting and code completion to your editor
users:
  - Beginner
  - Teacher
  - Library Authors
  - Application Developers
tools:
  - Merlin
  - Visual Studio Code
resources: 
  - url: https://github.com/ocaml/merlin/wiki/vim-from-scratch
    title: Vim from Scratch
    description: Wiki explaining how to get started with an OCaml setup for Vim users 
  - url: https://github.com/ocaml/merlin/wiki/vim-from-emacs
    title: Emacs from Scratch 
    description: Wiki explaining how to get started with an OCaml setup for Emacs users 
---

## Overview

Having a helpful development environment can boost productivity and help catch errors early. OCaml has a powerful type system which reduces runtime errors, with a good editor setup you'll be able to catch them before you run `dune build`.

## Recommended Workflow

### Visual Studio Code 

The recommended editor for OCaml is **Visual Studio Code**, an editor with a rich ecosystem of useful plugins, themes and developer tools. 

To get the best setup, there is a marketplace plugin and an opam package that must be installed. The plugin is called [vscode-ocaml-platform](https://github.com/ocamllabs/vscode-ocaml-platform) and offers syntax highlighting for Dune, OCaml, opam files, ReasonML and much more. 

It also has built-in snippets so, for example, writing `exec` in a dune file and hitting the tab key will generate a simple executable stanza.

```bash
# This is the language server protocol for OCaml
opam install ocaml-lsp-server

# Install the OCaml Platform on VS Code Marketplace 
```

From here make sure to add a `workplace` to VS Code for your project. And watch out for the following errors: 

- VS Code might complain about not being able to find `ocaml-lsp` - this is done on a per switch basis and clicking on the dialog box should let you pick the switch you installed it on. This is important: it will only work with switches where the LSP server is installed.
- Sometimes the syntax highlighting can seem outdated (e.g. changing the type signature of a function but no visual errors). The best thing to do is to restart the LSP server by opening the command palette and typing `> OCaml: Restart language server`. 

### Tips for using VS Code 

There are a few quality of life improvements you can make when working with OCaml and VS Code beyond installing the plugin. One very useful feature is running [OCamlFormat](/platform/ocamlformat) on save. To do this you can: 

1. Open the VS Code settings JSON file by typing `> Preferences: Open Settings (JSON)` into the command palette 
2. Add the following to the configurations `"editor.formatOnSave": true`. 

Now whenever you save a file it will apply the formatting changes for you. 

## Alternatives

### Other VS Code Plugins

Other extensions exist which offer support for OCaml and ReasonML including [vscode-ocaml](https://github.com/hackwaly/vscode-ocaml) and [vscode-reasonml](https://github.com/reasonml-editor/vscode-reasonml).

### Vim

The following is based heavily on the excellent wiki, [Vim from scratch](https://github.com/ocaml/merlin/wiki/vim-from-scratch). If you are new to vim, [this tutorial](https://habr.com/en/post/440130/) should help you get started. 

The tool to use with vim is [merlin](/platform/merlin). OCaml LSP is the next generation of merlin, but for vim you will need merlin installed. There is also a useful opam plugin for getting up and running with the merlin features:

```bash
opam install merlin ocp-indent 
opam user-setup install 
```

If you already have a `.vimrc` file you may need to manually modify it to add additional features. For example the following will switch between different merlins depending on which opam switch you are on. 

```
let g:opamshare = substitute(system('opam config var share'),'\n$','','''')
execute "set rtp+=" . g:opamshare . "/merlin/vim"
```

To get code completion you will need to enable omnipresent in your `.vimrc` file: 

```
filetype plugin on
set omnifunc=syntaxcomplete#Complete
```

Then whilst in `INSERT` mode type `ctrl+x ctrl+o` to see completions for something like `List.m`. 

For syntax errors you need to add *syntastic* as a vim plugin. For this you'll need a vim plugin manager like pathogen. The [syntastic documentation](https://github.com/vim-syntastic/syntastic) will let you get started and then add the following to your `.vimrc` file. 

```
execute pathogen#infect()

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_ocaml_checkers = ['merlin']
```

#### Useful Merlin Commands 

When working with vim you can use different commands from Merlin to do useful things, here are a few to get you started. 

- `:MerlinUse <packages>`: this will make the package available for tab completion and type information. 
- `:MerlinTypeOf`: this will give you type information for the currently selected value in your OCaml program. For example, if you are on the `a` in `let a = 3` this will tell you it is an `int`. If you were on `Core.List.map` you would get `'a list -> f:('a -> 'b) -> 'b list`. 
- `:MerlinErrorCheck`: this will perform a quick type check of the current file. 

You can see the full list by typing `:h merlin.txt`. Typing lots of these commands to say source packages can become tedious, you can use a `.merlin` file to configure merlin for a project. For more information on that check the [merlin](/platform/merlin) platform tool page.

### Emacs

The workflow for emacs is very similar to vim. If you are completely new to emacs, [this tutorial](http://www.jesshamrick.com/2012/09/10/absolute-beginners-guide-to-emacs/) should help you understand the key concepts. 

```bash
opam install merlin ocp-indent tuareg
opam user-setup install 
```

Note that in addition to merlin it is also recommended to install the OCaml Emacs mode called [tuareg](https://github.com/ocaml/tuareg). This will allow you to use a REPL and debug mode within the emacs editor.

You can then run [utop](/platform/utop), providing you have it installed, from within the editor by typing `M-x run-ocaml` and then typing `utop` and swapping to that window (`C-x o`). 

What follows is a short list of useful shortcuts to make your experience working with OCaml and emacs better. 

- `C-c C-t`: type information for the currently selected phrase. 
- `C-c C-l`: this will try to take you to wherever this phrase was first defined, usually the `.mli` file for a value. 
- `M-x completion-at-point`: code completition from within the editor.

 The same [merlin advice](/platform/merlin) applies to using emacs as it did with vim.
