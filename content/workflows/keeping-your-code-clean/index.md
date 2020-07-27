---
authors:
  - Patrick Ferris
title: Keeping your Code Clean
date: 2020-07-27 09:35:49
users:
  - Library Authors
  - Application Developer
tools:
  - Ocp-indent
  - OCamlformat
---

## Overview

---

Having a unified approach to formatting is important for multiple reasons: 

- Good for beginners: using tooling to help properly format, code-complete, syntax highlighting etc. removes this burden (somewhat) for new people lowering the barrier of entry for contributions.
- Easier to read: the code tends to be easier to read (or will be once the standard formatting is learnt) which helps onboard new people to a codebase and also discover bugs.

## Recommended Workflow

---

### OCamlformat

OCamlformat tends to be the tool of choice for enforcing formatting styles in a project. It requires a very simple `.ocamlformat` file in the root of the project which can specify a few configuration options. 

A bare bones file will contain the version of OCamlformat you want to use:

```
version=0.14.2
```

From there, depending on your setup and editor, you can:

- Run `ocamlformat` on builds
- Run `ocamlformat` when saving a file (works very well with VS Code)

Formatting on save should just work if you have the OCaml Platform plugin installed in VS Code (see related workflows)

### Ocp-indent

Ocp-indent is an indentation tool for OCaml. It is particularly useful for *vim* and *emacs.* If you followed the setup for those editors in the related workflow you should only need to add the following to your `.vimrc`. 

```
set rtp^="$(opam config var ocp-indent:share)/vim"
```

## Real World Examples

---

[mirage/alcotest](https://github.com/mirage/alcotest/blob/master/.ocamlformat)

[ocaml-ppx/ocamlformat](https://github.com/ocaml-ppx/ocamlformat/blob/master/.ocp-indent)