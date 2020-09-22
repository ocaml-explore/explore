---
title: Writing Scientific Computing Applications
date: 2020-09-17 10:16:52 +00:00
authors:
- Patrick Ferris
description: Use the OWL library to build scientific computing applications in OCaml
topic:
  coding:
  - true
tools:
- dune
users:
- application developers
libraries:
- owl
resources: 
---

## Overview 

Data science applications are typically written in Python thanks to the large community providing excellent libraries for nearly any area of analysis. OCaml can offer concise, fast and crucially type-safe code in the scientific computing arena. Thanks to ongoing work by [Liang Wang](https://www.cl.cam.ac.uk/~lw525/) et al. OCaml now has the Owl scientific computing library. 

What follows are some brief examples to give you a taste of scientific computing in OCaml. If you like what you see, then the next stop for you is the amazing [OCaml Scientific Computing](https://ocaml.xyz/book/) book. 

## Recommended Workflow

### Introduction to Owl 

Owl is a library for running scientific computations in OCaml. Besides providing a base of useful functions for manipulating data, Owl has the difficult task of managing memory efficiently in a functional language like OCaml. Using a computation graph, Owl can perform operations lazily and help reduce how much memory is allocated.

The most ubiquitous data type is the `Ndarray` (n-dimensional array). 

<!-- $MDX file=examples/simple/main.ml -->
```ocaml
open Owl.Dense
module IntArr = Ndarray.Generic

let () =
  let open Owl.Arr in
  let arr1 = Ndarray.Generic.ones Int64 [| 5; 5 |] in
  let arr2 = Ndarray.Generic.ones Int64 [| 5; 5 |] in
  Ndarray.Generic.pp_dsnda Format.std_formatter (arr1 + arr2)
```

Note we locally open `Owl.Arr` in order to get the infix array addition operator. 

```sh dir=examples/simple
$ dune exec -- ./main.exe

   C0 C1 C2 C3 C4
R0  2  2  2  2  2
R1  2  2  2  2  2
R2  2  2  2  2  2
R3  2  2  2  2  2
R4  2  2  2  2  2
```

The `Generic` module offers a lot of predefined functionality such as computing gaussian matrices. 


```ocaml
```

