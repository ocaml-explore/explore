---
title: OCaml Ecosystem History
description: An explanation of how the OCaml ecosystem has evolved to include the rich diversity of tools it now has
date: 2020-07-27 09:35:49
---

In my quest to understand OCaml and the platform tools I found it very challenging to be given for example, `opam` or `dune` and then told things like:

> You could use `ocamlbuild` and cross-compiling with `dune` just uses an `ocamlfind` trick with the toolchain...

Although these are no longer the recommended ways of compiling code, an appreciation for their existence is important and sometimes they do exactly the job you need. A very good example is people new to the language having to use, say, `ocamlopt`. As soon as you have two dependent modules ( `[a.ml](http://a.ml)` and `[b.ml](http://b.ml)`) am I forced to install `dune`, learn `dune` and use it to build my project for me? 