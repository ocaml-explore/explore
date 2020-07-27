---
title: Dune
date: 2020-07-27 09:35:49
description: Dune is a build tool that has been widely adopted in the OCaml world
license: MIT
---
## Overview

---

Dune is a build tool that has been widely adopted in the OCaml world - it plays nicely with lots of other tools like opam and mdx. The documentation is very thorough - but do checkout the *key concepts* to get a high-level overview of how dune works and how to get started building your OCaml project. 

[Welcome to dune's documentation! - dune documentation](https://dune.readthedocs.io/en/stable/)

## Key Concepts

---

### Compositional Builds

Dune builds projects in a modular way generally based on file structure. This is somewhat different to say how `npm` would build Javascript projects more or less only based on the `package.json` at the root of the project. Looking at *Typical Project Layout* the compositionality is portrayed by the `dune` files in each directory. Each part is doing something different (building tests, the library, the unix version of the library etc.). 

### Declarative

Unlike say `Makefiles`, dune is declarative. You tell it what you want and dune handles the nitty-gritty details but provides escape-hatches and **a lot of customisability** in your `dune` file to build complex projects. 

This allows dune to be a great build tool no matter what your project size or complexity is. 

### Build Types

There tend to be three main types of builds that will suffice for most projects: *executables, libraries and tests*. Each has its own [stanza reference](https://dune.readthedocs.io/en/stable/dune-files.html#dune). The executable stanza will by default build a binary that you can run in the `_build/default` folder. Libraries are units of reusable code for other projects to benefit from packaged up under a module.

### Typical Project Layout

The following file structure is taken from `ocaml-yaml` and has been trimmed to show only the relevant dune-related parts and still be readable. 

[avsm/ocaml-yaml](https://github.com/avsm/ocaml-yaml)

```
.
|-- CHANGES.md
|-- LICENSE.md
|-- README.md
|-- dune
|-- dune-project
|-- fuzz
|   |-- dune
|   `-- fuzz.ml
|-- lib
|   |-- dune
|   |-- stream.ml
|   |-- types.ml
|   |-- yaml.ml
|   `-- yaml.mli
|-- tests
|   |-- dune
|   |-- test.ml
|   |-- test_emit.ml
|   |-- test_parse.ml
|   `-- yaml
|-- unix
|   |-- dune
|   |-- yaml_unix.ml
|   `-- yaml_unix.mli
`-- yaml.opam
```

## In the Wild

---

Dune is used in a lot of OCaml projects thanks to its flexibility, integration with opam and lightweightness. Below are just a few projects using dune: 

[mirage/irmin](https://github.com/mirage/irmin)

[janestreet/re2](https://github.com/janestreet/re2/)