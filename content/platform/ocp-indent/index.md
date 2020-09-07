---
title: Ocp-indent
date: 2020-07-27 09:35:49
description: An indentation tool for OCaml 
license: LGPL v2.1 with linking exception
repo: https://github.com/OCamlPro/ocp-indent
---

## Overview

[Ocp-indent](https://github.com/OCamlPro/ocp-indent) is an indentation tool for OCaml. Unlike Python, the level of indentation will not change the semantics of your OCaml program, but it will make it more or less readable.  For complete styling you should use OCamlFormat and for indentation, Ocp-indent. 

## Key Concepts

### Tuneable Parameters

The complete set of tuneable parameters are quite nicely given in the `.ocp-indent` file for [Ocp-indent itself](https://github.com/OCamlPro/ocp-indent/blob/master/.ocp-indent). The simplest is the *base* parameter which will make sure code is indented in a standard way

```
(* base = 2 *)
let foo () = 
^^bar ....
```

### Syntax Extensions

Ocp-indent comes with useful extensions for the OCaml language - in particular you can use the *mll* extension for indenting the lexing file format.

## In the Wild

Ocp-indent is used in the [OCaml compiler repository](https://github.com/ocaml/ocaml/blob/trunk/.ocp-indent).
