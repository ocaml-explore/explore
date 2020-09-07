---
title: Merlin
date: 2020-08-05 11:49:15 
description: Brining IDE features to editors like Vim and Emacs
repo: https://github.com/ocaml/merlin
license: MIT
---

## Overview

[Merlin](https://github.com/ocaml/merlin) is a tool for providing IDE features for OCaml with support for Vim and Emacs. If you want to set up either of these editors for a modern OCaml editting experience be sure to check out the related workflows section. 

## Key Concepts

### Installation 

With opam installation (and some configuration) is as simple as running: 

```
opam install merlin
opam user-setup install 
```

### Configuration Files

Working with merlin adds modern IDE features to Vim and Emacs, but some of the commands can become tedious. Merlin can be configured with a `.merlin` file. This can be use to describe the structure of your project along with the external packages it uses. Instead of running `:MerlinUse Core` every time you open your editor you can add a `PKG core` to a `.merlin` file. 

There is a very [thorough handling](https://github.com/ocaml/merlin/wiki/Project-configuration) of `.merlin` files on the Merlin wiki, but as brief summary of what is supported. 

The three most commonly used direcives are `S`, `B` and `PKG`. `S` is used to describe source paths, that is, the other files in your project. `B` unsurprisingly is for build paths. `PKG` for external packages. Consider the following structure: 

```
.
|-- dune
|-- main.ml
|-- utils.ml
`-- utils.mli
```

The dune file is building an executable from `main.ml` that uses the `utils.ml` file. Since we are using dune whenever we run`dune build` a `.merlin` file will be generated for us. The most important aspects of the file are: 

```
B _build/default/.main.eobjs/byte
S .
```

If our project used the Core library then the `.merlin` file would include many links to the sources of that library in our opam switch.

The source should be fairly straightforward since all of our sources are located at the root of this simple project. Dune stores the compiled interface files (`.cmi` files) in the `_build/default/.main.eobjs/byte` folder. For an overview of the different OCaml file types there is a good explanation [here](http://caml.inria.fr/pub/ml-archives/caml-list/2008/09/2bc9b38171177af5dc0d832a365d290d.en.html).
