---
authors:
  - Patrick Ferris
title: Meta-programming with PPX 
date: 2020-08-04 11:22:35
description: Automate code-generation with meta-programming
users:
  - Library Authors
  - Application Developer
tools:
  - ppxlib
  - dune
  - omp
resources: 
  - url: https://tarides.com/blog/2019-05-09-an-introduction-to-ocaml-ppx-ecosystem
    title: An Introduction to OCaml PPX Ecosystem
    description: Nathan Rebours gives a very detailed and excellently explained guide to writing your own ppx using ppxlib
---

## Overview

Meta-programming is programming for programming. You can think of it as a program which works with another program as data. Ppx is the OCaml syntax extension allowing programmers to meta-program directly on the abstract syntax tree (AST) of OCaml code. This means simple tasks like writing comparison functions or hashing functions can be automated through clever inference on types. 

### The Abstract Syntax Tree 

Before diving into using a ppx or writing your own, it is important to understand the OCaml AST. Your program starts its life in OCaml's concrete syntax. This is the predefined set of strings which are given some semantic meaning in the OCaml world like `let ... in ...`. The first important job of the compiler is to render this as abstract syntax, a simpler internal represenation of your program often structured as a labelled tree. 

As a tree data-structure, transformations become much easier. The purpose of a ppx is to move from one AST to another. The OCaml AST is called the [Parsetree](https://github.com/ocaml/ocaml/blob/trunk/parsing/parsetree.mli). Using this definition, let's find the AST for:

```ocaml
# let add_one a = a + 1 
val add_one : int -> int = <fun>
```

We can actually print the Parsetree using the OCaml compiler from the command line: `ocamlopt -dparsetree file.ml`. What follows is the Parsetree component for the `add_one` function. The `pexp` function takes a `Parsetree.expression_desc` and creates a `Parsetree.expression` by filling in details like attributes and location with dummy information to make the example more readable. `ppat` and `pvb` are similar functions for those types. 

<!-- $MDX file=examples/parsetree/main.ml,part=1 -->
```ocaml
let (p : structure) =
  [
    {
      pstr_desc =
        Pstr_value
          ( Nonrecursive,
            [
              pvb
                (ppat (Ppat_var { txt = "f"; loc = fake_position }))
                (pexp
                   (Pexp_fun
                      ( Nolabel,
                        None,
                        ppat (Ppat_var { txt = "a"; loc = fake_position }),
                        pexp
                          (Pexp_apply
                             ( pexp
                                 (Pexp_ident
                                    {
                                      txt = Longident.Lident "+";
                                      loc = fake_position;
                                    }),
                               [
                                 ( Nolabel,
                                   pexp
                                     (Pexp_ident
                                        {
                                          txt = Longident.Lident "a";
                                          loc = fake_position;
                                        }) );
                                 ( Nolabel,
                                   pexp
                                     (Pexp_constant (Pconst_integer ("1", None)))
                                 );
                               ] )) )));
            ] );
      pstr_loc = fake_position;
    };
  ]
```

If the tree structure does not reveal itself from the code, this greatly simplified diagram should help.

![The OCaml AST for let add_one x = x + 1](/images/parsetree.png)

Manipulating the tree structure is much simpler than working with text. A ppx works on these structures allowing you to access the information and perform transformations from one tree to another. 

## Recommended Workflow

### Using PPX libraries

Dune comes with ppx support which makes it very easy to start using different ppx libraries to meta-program in OCaml. In this example we will define a new type of person and try to use it with the `Core.Hashtbl` module.

The Core implementation of a [hashtable expects](https://github.com/janestreet/base/blob/master/src/hashtbl_intf.ml#L425) an `'a Key.t` which should be a first-class module with hash, compare and s-expression functions. This is very common for Jane Street modules so they made ppxes to auto-generate such functions from type signatures. 

To generate these functions we label it with a type deriving attribute.

<!-- $MDX file=examples/ppx_jane/main.ml -->
```ocaml
open Core

module Person = struct 
  type t = {
    name: string;
    age: int;
  } [@@deriving hash, sexp, compare]
end 

let () = 
  let tbl = Hashtbl.create (module Person) in 
  let alice : Person.t = { name = "Alice"; age = 42 } in 
    Hashtbl.add_exn tbl ~key:alice ~data:"1234"; 
    print_string (Hashtbl.find_exn tbl alice)
```

The dune file will be:

<!-- $MDX file=examples/ppx_jane/dune -->
```
(executable
 (name main)
 (libraries core)
 (preprocess
  (pps ppx_jane)))
```

The `[@@deriving...]` attribute tells the compiler to insert new nodes derived from the type. For example, consider deriving the compare function. 

```ocaml
type t = { id : int } [@@deriving compare]
```

To see what the compiler is actually compiling we can add `(ocamlopt_flags (:standard -dsource))` to our dune file's executable stanza to print the actual compiled source code. With this, a simplified version of what we get is:

```ocaml
open Core
type t = {
  age: int }[@@deriving compare]
include
  struct
    let _ = fun (_ : t) -> ()
    let compare =
      (fun a__001_ ->
         fun b__002_ ->
           if Ppx_compare_lib.phys_equal a__001_ b__002_
           then 0
           else compare_int a__001_.age b__002_.age : t -> t -> int)
    let _ = compare
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
```

The main part being the new compare function which first uses physical equality before using integer equality on the integer record field of our type. 

### Writing PPX libraries

To write your own ppx library you are strongly encourage to use `ppxlib` (linked in the libraries section). It provides a wrapper around the compiler hooks that ppx uses to modify the AST. The user documentation does a very good job at getting you started writing your own ppx libraries. 

[ppxlib's user manual - ppxlib documentation](https://ppxlib.readthedocs.io/en/latest/)

The best way to learn is by example. Let's continue with some of Jane Street's ppxes and look at how `ppx_compare` works. 

## Real World Examples

[ocaml-ppx/ppx_deriving_yojson](https://github.com/ocaml-ppx/ppx_deriving_yojson)

[ocaml-ppx/ppx_deriving_protobuf](https://github.com/ocaml-ppx/ppx_deriving_protobuf)
