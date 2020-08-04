---
authors:
  - Patrick Ferris
title: Documenting your Project
date: 2020-07-27 09:35:49
description: Write maintainable and useful documentation for your library
users:
  - Library Authors
  - Application Developers
tools:
  - Mdx
  - Dune-release
  - Dune
libraries: 
  - Odoc
---

## Overview

---

Documentation is vital for your library to be used by other people, it also helps others to contribute and even reminds you of your design decisions. 

The goal of the  workflow is to make your documentation:

- Easily updatable - your documentation should evolve with your project and not be a painful experience in updating it.
- Informative yet concise - your documentation workflow should allow you to be verbose where you need to be but concise everywhere else, code examples can tell a better story than prose in most cases.
- Correct - your documentation will likely contain code examples and workflows, these should be checked for correctness in an automated way.

## Recommended Workflow

---

### Writing Documentation using Odoc 

OCaml has a tool, [odoc](/libraries/odoc), for generating documentation from comments in the code that start with a double asterisk `(** my nice comment *)`.

The full documentation for the syntax of documentation comments can be found [here](https://caml.inria.fr/pub/docs/manual-ocaml/ocamldoc.html#s%3Aocamldoc-comments). The recommended place for documentation strings are in the interface (`.mli`) files. Here is a small example for a library which offers a, very limited, selection of functions on numbers. 

<!-- $MDX file=examples/doc/src/numbers.mli -->
```ocaml
(** {1 Types} *)

type err = [ `Undefined of string ]
(** The type of number errors *)

(** {1 Number Functions} *)

val fact : int -> (int, err) Result.t
(** [fact n] computes n! ({{:https://en.wikipedia.org/wiki/Factorial}
    factorial}). If [n] is less than [0] then it returns an [Error err] where
    the errors are {!err} *)
```

The parts of the documentation strings in square brackets like `[fact n]` will be formatted as code in the documentation site. Another useful feature is the `{{: <link>} <text>}` constructor for making links to external resources. The comments with `{1 <header>}` indicate level one headers.

You can cross reference other types, functions and modules using the `{! <value>}` syntax. This is being used to link back to the `err` type. For large projects this can help moving around the interface that is exposed to your users.

### Generating Documentation

If you are already using opam and dune then the hardest part to generating documentation is actually writing it. From the root of your project it is as simple as: 

```
opam install odoc 
dune build @doc 
```

This will build a documentation website in `_build/default/_doc/_html`.

### Releasing Documentation

If you are hosting your code on Github then you can also go one step further and deploy your documentation to [Github Pages](https://pages.github.com/). This is done using dune-release which will build your documentation for you and push it to a `gh-pages` branch before moving it upstream. 

Dune-release will build the documentation from the *distribution archive* - this means you need to build that first in order to get your documentation. 

```
$ dune-release distrib # build the distribution archive
$ dune-release publish doc # build and push docs to gh-pages
```

## Real World Examples

---

Many frequently used OCaml libraries take advantage of this easy workflow for publishing documentation as part of the release process for a new version of a package. Good examples are [Irmin](https://mirage.github.io/irmin/) and [Cohttp](https://mirage.github.io/ocaml-cohttp/).
