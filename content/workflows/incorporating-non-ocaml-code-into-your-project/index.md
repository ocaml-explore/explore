---
authors:
  - Patrick Ferris
title: Incorporating non-OCaml Code into your Project
date: 2020-08-05 15:14:54
description: Add C code to your OCaml project
topic: 
  misc: 
    - false
users:
  - Library Authors
  - Application Developer
tools:
  - Dune
libraries: 
  - Cstruct
resources: 
  - url: https://rwmj.wordpress.com/2009/08/04/ocaml-internals/
    title: A Beginners Guide to OCaml Internals
    description: A series of great articles explaining the internal representation of values in OCaml, useful for understanding things like memory profiling and GC.
  - url: https://caml.inria.fr/pub/docs/oreilly-book/html/book-ora114.html
    title: Communication between C and Objective Caml 
    description: A chapter on how C and OCaml talk to each other with some useful diagrams too
---

## Overview

Sometimes OCaml just can't do what lower level languages can do or you want to use pre-existing code written in C or Rust from OCaml. 

## Recommended Workflow

### OCaml Internals 

Programming languages must have a representation of data at runtime, for example how should OCaml represent `type camel = Dromedary of int` in memory? When you interface between two languages much of the battle is converting in-and-out of each programming language's internal data represenation. A [detailed introduction](https://caml.inria.fr/pub/docs/manual-ocaml/intfc.html#s%3Ac-ocaml-datatype-repr) of OCaml's internal data representation is given in the manual, what follows is a brief summary.

OCaml has a uniform memory representation where everything is a word-sized value. These can either be immediates (represented as unboxed integers) or non-immediates (pointers to a block stored in the OCaml or the C heap). Boxing is the process of wrapping additional meta-data around a value much like IP packets and their header. 

![OCaml runtime data represenation](/images/data-repr.jpg)

To distinguish between immediates and non-immediates (pointers), OCaml uses a tag bit in the least significant bit as a flag. When it is set to 1 this indicates an immediate, otherwise it should be interpretted as a pointer. This means on a 32-bit machine OCaml integers can only be 31-bit. The runtime value of the number `7` in OCaml is actually `15`. The conversion function can be seen [here](https://github.com/ocaml/ocaml/blob/trunk/runtime/caml/mlvalues.h#L75) in the OCaml compiler.

Integers are not the only values represented as immediates. Normal and polymorphic variants with constant constructors are represented as immediates, the latter as a hash of the constructor name. The built-in boolen values are also immediates i.e. true is `1` (which in OCaml is `3`) and false is `0` (`1` in OCaml).

```ocaml env=types
# type vehicle = Car | Bicycle of string | Truck 
type vehicle = Car | Bicycle of string | Truck
# type poly = [`String | `Int]
type poly = [ `Int | `String ]
# true
- : bool = true
```

Variants with non-constant constructors are heap allocated as blocks (only the non-constant ones). Blocks in the heap start with a one-word header, either 32 or 64-bit depending on thearchitecture, which contains information about the length of the value (22 or 54 bits), 2 bits for a colour which is used in garbage collection and 8 bits for a multi-purpose tag byte to indicate what the block is. The type unsafe `Obj` module lets you inspect the runtime information of values. 

```ocaml env=types
# Obj.tag (Obj.repr Car)
- : int = 1000
# Obj.is_int (Obj.magic Car)
- : bool = true
# Obj.tag (Obj.repr (Bicycle "electric"))
- : int = 0
# Obj.is_block (Obj.magic (Bicycle "electric"))
- : bool = true
# Obj.tag (Obj.repr `String)
- : int = 1000
# Obj.tag (Obj.repr (fun x -> x)) 
- : int = 247
```

### Interacting with C from OCaml 

To interact with C code you need to use the Foreign Function Interface (FFI) in OCaml and make some changes to your `dune` files to incorporate the extra code. To use a foreign C function in OCaml you need to add: 

~~~ocaml
external <ocaml-name> : <type-of-function> = "<c-function-name>"
~~~

The C function will take OCaml values as arguments (which will be encoded using the data representation previously described). For example if we want to have an external C `add` function the C file would be. 

<!-- $MDX file=examples/c-from-ocaml/add.c -->
```c
#include <caml/mlvalues.h>

value add_c(value a, value b)
{
  return Val_long(Long_val(a) + (Long_val(b)));
}
```

To access the code in OCaml we define an external `add` function and give it proper OCaml types within our `main.ml` file. 

<!-- $MDX file=examples/c-from-ocaml/main.ml -->
```ocaml
external add : int -> int -> int = "add_c"

let () = print_int (add 10 10)
```

Finally we compile everything using dune and the *foreign_stubs* optional field.  

<!-- $MDX file=examples/c-from-ocaml/dune -->
```
(executable
 (name main)
 (foreign_stubs
  (language c)
  (names add)))
```

### Interacting with OCaml from C 

Sometimes you might want to do the inverse and access parts on an [OCaml program from a C program](https://ocaml.org/releases/4.10/htmlman/intfc.html). This still suffers from the data represenation shuffling that might need to take place. There are two main ways that you may want to call OCaml from C. Either as callbacks (OCaml calls C which calls OCaml) or just directly from a main C program. The latter requires you to initialise the OCaml code by calling `caml_main`. 

In order for C to find OCaml functions you need to register them as callbacks using `Callback.register`. This [small example](https://github.com/patricoferris/ocaml-c-example) calls a fibonacci function written in OCaml from C. Note the additional C compiler parameters in the Makefile for linking in the standard library and only producing an object OCaml file. 

## Real World Examples

[Digestif](https://github.com/mirage/digestif/tree/master/src-c/native) implements many common hashing algorithms both in C and OCaml.

[Cstruct](https://github.com/mirage/ocaml-cstruct)  is a library that allows you to read and write structures from the C programming language. It is used in many applications for handling things like packets, for example in the [Git](https://github.com/mirage/ocaml-git) implementation in pure OCaml.
