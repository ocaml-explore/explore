---
title: lsp-server
repo: https://github.com/ocaml/ocaml-lsp
license: 
  ISC: []
lifecycle: 
  INCUBATE: []
date: 2020-09-14 14:04:15 +00:00
description: An OCaml implementation of the Language Server Protocol (LSP)
---

## Overview 

OCaml-lsp is a pure OCaml implementation of the [Language Server Protocol](https://en.wikipedia.org/wiki/Language_Server_Protocol) (LSP). The initial purpose for OCaml-lsp was to be used in conjunction with the [VS Code Platform Extension](https://github.com/ocamllabs/vscode-ocaml-platform). 

For setting up development environments be sure to check the [editor configuration](/workflows/configuring-ocaml-tools-for-your-editor) workflow.

## The Language Server Protocol

LSP is a JSON-based remote procedure call (RPC) protocol to allow communication between text-editors and some server offering specific programming language support. This greatly simplifies the implementation of generic editors as it offers a standard by which language information can be communicated.   