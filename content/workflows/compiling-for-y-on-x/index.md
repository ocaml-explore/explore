---
authors:
  - Patrick Ferris
title: Compiling for Y on X
date: 2020-07-27 09:35:49
users:
  - Application Developers
tools:
  - Dunes
---

## Overview

---

Cross-compiling in OCaml is still an experimental feature, but there are plans to make it a fully supported one in the future. 

Cross-compiling allows a programmer on an *x86* machine to compile OCaml code to run on a *RISC-V* device. **Usually the target architecture is the same as the architecture our machine is running on. This is particularly useful for embedded devices running architectures like *ARM-32, ESP-32 or RISC-V*. 

## Recommended Workflow

---

Dune has built-in support for cross-compilation thanks to toolchains in OCamlfind. To work with cross-compiling you will need the following: 

1. The appropriate cross-compiling toolchains installed - OCaml uses a C compiler to build the OCaml compiler so a cross-compiling C compiler will be necessary. 
2. A switch with a cross-compiling repository setup - this will handle installing the OCaml cross-compiler.

Luckily, that is fairly easy. Below, in real world examples, there are some repositories you can use. Instructions for installing say the *RISC-V* cross-compiler can be found in [this Dockerfile](https://github.com/patricoferris/ocaml-on-riscv/blob/trunk/opam/Dockerfile). In the future the OCaml compiler will support cross-compilation out-of-the-box but for now you will have to use some modified versions of the compiler. 

## Real World Examples

---

### Example opam repositories

[Well-typed lightbulbs](https://github.com/well-typed-lightbulbs)

[mirage-shakti-iitm](https://github.com/mirage-shakti-iitm)