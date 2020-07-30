---
authors:
  - Patrick Ferris
title: Meta-programming with PPX 
date: 2020-07-27 09:35:49
description: Automate code-generation with meta-programming
users:
  - Library Authors
  - Application Developer
tools:
  - Dune
libraries: 
  - Ppxlib
resources: 
  - url: https://tarides.com/blog/2019-05-09-an-introduction-to-ocaml-ppx-ecosystem
    title: An Introduction to OCaml PPX Ecosystem
    description: Nathan Rebours gives a very detailed and excellently explained guide to writing your own ppx using ppxlib
---

## Overview

---

Ppx allows programmers to meta-program directly on the abstract syntax tree of OCaml code. This means simple tasks like writing comparison functions or hashing functions can be automated through clever inference on types.  

## Recommended Workflow

---

### What is Meta-programming?

Meta-programming is programming for programming. 

### Using PPX libraries

Dune comes with ppx support which makes it very easy to start using different ppx libraries to meta-program in OCaml. In this example we will add `ppx_hash` to a small example. 

Suppose we have type of person - to generate a hashing function we label it with a type attribute:

```ocaml
(* person.ml file *)
open Core

type person = {
	name: string;
	age: int;
} [@@deriving hash]

let () = 
	let p = { name = "Alice"; age = 42 } in 
		Printf.fprintf stdout "%i\n" (hash_person p)
```

This example illustrates that ppx libraries can make assumptions - `ppx_hash` expects the Jane Street Core standard library to be open in order to use some of the functions that are there that aren't in the standard library packaged by OCaml. 

The dune file will be:

```
(executable
  (name person)
	(libraries core)
	(preprocess (pps ppx_hash)))
```

### Writing PPX libraries

To write your own ppx library you are strongly encourage to use `ppxlib` (linked in the libraries section). It provides a wrapper around the compiler hooks that ppx uses to modify the AST. The user documentation does a very good job at getting you started writing your own ppx libraries. 

[ppxlib's user manual - ppxlib documentation](https://ppxlib.readthedocs.io/en/latest/)

In addition to that, the article in the resources tag does a very thorough job of explaining how to use ppxlib. 

## Real World Examples

---

[ocaml-ppx/ppx_deriving_yojson](https://github.com/ocaml-ppx/ppx_deriving_yojson)

[ocaml-ppx/ppx_deriving_protobuf](https://github.com/ocaml-ppx/ppx_deriving_protobuf)