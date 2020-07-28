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

### Generating Documentation

OCaml has a tool, odoc, for generating documentation from comments in the code that start with a double asterisk `(** my nice comment *)`.

The full documentation for the syntax of documentation comments can be found [here](https://caml.inria.fr/pub/docs/manual-ocaml/ocamldoc.html#s%3Aocamldoc-comments). Some of the most used features of the syntax include, source code styling with `[...]`:

```ocaml
val add : int -> int -> int 
(** [add a b] takes the two integers [a] and [b] and produces their sum *) 
```

Inserting links to external sources `{{: link} text}`: 

```ocaml
val gcd : int -> int -> int 
(** [gcd a b] computes the 
	{{: https://en.wikipedia.org/wiki/Greatest_common_divisor} gcd} 
	of two integers [a] and [b] *)
```

Cross referencing other types, modules or functions:

```ocaml
val mult : int -> int -> int 
(** [mult a b] returns the product of [a] and [b] using {! Arith.add} to do so *)
```

If you are already using opam and dune then the hardest part to generating documentation is actually writing it. From the root of your project it is as simple as: 

```bash
opam install odoc 
dune build @doc 
```

This will build a documentation website in `_build/default/_doc/_html`.

### Releasing Documentation

If you are hosting your code on Github then you can also go one step further and deploy your documentation to [Github Pages](https://pages.github.com/). This is done using dune-release which will build your documentation for you and push it to a `gh-pages` branch before moving it upstream. 

Dune-release will build the documentation from the *distribution archive* - this means you need to build that first in order to get your documentation. 

```bash
$ dune-release distrib # build the distribution archive
$ dune-release publish doc # build and push docs to gh-pages
```

## Real World Examples

---

Many frequently used OCaml libraries take advantage of this easy workflow for publishing documentation as part of the release process for a new version of a package. Good examples are [Irmin](https://mirage.github.io/irmin/) and [Cohttp](https://mirage.github.io/ocaml-cohttp/).