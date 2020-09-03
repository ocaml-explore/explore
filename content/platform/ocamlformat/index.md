---
title: OCamlFormat
date: 2020-07-27 09:35:49
description: Enforcing formatting styles to an OCaml project
repo: https://github.com/ocaml-ppx/ocamlformat
license: MIT
---

## Overview

---

[OCamlFormat](https://github.com/ocaml-ppx/ocamlformat) is a tool for applying formatting decisions to an OCaml project - it supports 

## Key Concepts

---

### Versioning

Like dune and opam, OCamlFormat uses versioning to ensure different installations of the tool don't mangle lots of code by accident when different versions are used. This is great for onboarding new people to a project preventing them from changing every file if they accidentally have the wrong version of OCamlFormat installed. Instead they will be made aware of the version mismatch. This is likely the only required property to set in the `.ocamlformat` file. 

It's important to note that OCamlFormat will not be able to change the formatting of syntactically incorrect code.

### Options

The full, tuneable options list can be seen with `ocamlformat --help` but to give you a taste of what is possible here are a few options: 

- *parse-docstring=true:*  this will ensure OCamlFormat parse documentation strings.
- *break-infix=fit-or-vertical:* this will move sequences of infix operations to new lines if they don't fit which makes these sequences much easier to read (useful for `>>=` sequences with [Lwt](http://ocsigen.org/lwt/5.2.0/manual/manual))
- *space-around-records=true*: this is set by default (along with arrays and lists) which formats these values as `{ age = 3 }` rather than `{age=3}` which again helps with legibility.

## In the Wild

---

Lots of large code bases now uses OCamlFormat to make styling one less thing to worry about. Facebook's [Infer](https://github.com/facebook/infer/blob/master/infer/src/.ocamlformat) uses it as well as [Mirage](https://github.com/mirage/mirage/blob/master/.ocamlformat).