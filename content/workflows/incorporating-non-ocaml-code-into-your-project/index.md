---
authors:
  - Patrick Ferris
title: Incorporating non-OCaml Code into your Project
date: 2020-07-27 09:35:49
users:
  - Library Authors
  - Application Developer
tools:
  - Dune
libraries: 
  - Cstruct
---

## Overview

---

Sometimes OCaml just can't do what lower level languages can do or you want to use pre-existing code written in C or Rust from OCaml. 

## Recommended Workflow

---

### Interacting with C

To interact with C code you need to use the Foreign Function Interface (FFI) in OCaml and make some changes to your `dune` files to incorporate the extra code. To use a foreign C function in OCaml you need to add: 

```ocaml
external <ocaml-name> : <type-of-function> = "<c-function-name>"
```

And then in your dune file you need to include the C code: 

```
(executable
 (name main)
 (foreign_stubs
  (language c)
  (names <c-filename>)))
```

Take care with the difference between how C represents runtime values and how OCaml represents them (covered in the linked resources page). See this dune documentation page for more options for the `foreign_stubs` and this OCaml manual page for a more formal introduction to the C FFI.

### Interfacing with C Structs

There is a `cstruct` library linked in the libraries tag that allows you to read and write structs from the C programming language. 

### Interacting with Rust

Coming soon...

## Real World Examples

---

### Using C code

[mirage/digestif](https://github.com/mirage/digestif/tree/master/src-c/native)

### Using Cstruct

[mirage/ocaml-git](https://github.com/mirage/ocaml-git)