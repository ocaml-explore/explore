---
title: Debugging and Exploring OCaml Projects
date: 2020-09-29 11:46:59 +00:00
authors:
- Patrick Ferris
description: Learn how to effectively debug your OCaml projects and explore packages
topic:
  starter:
  - true
tools:
- utop
- dune
users:
- beginners
libraries: 
resources: 
---

## Overview 

Programming is one part technical, another part creative and the rest is about debugging and exploring code. This workflow will introduce a few good ways to help you debug programs, test libraries and explore other packages. 

## Explore using utop 

If you are looking for trying out packages installed using opam (like batteries in your example) then the universal toplevel (utop) for OCaml is a great tool to get familiar with. It can be installed also using opam: 

```
$ opam install utop 
$ opam install batteries
$ utop 
```

Once in a utop session you can pull in packages that you have installed to explore them. To do this use the `#require` directive which is specific to the toplevel (it won’t work in OCaml files being compiled with something like dune).

```ocaml env=yaml
# #require "yaml";;
# open Yaml;;
# of_string "hello: world";;
- : value res = Result.Ok (`O [("hello", `String "world")])
```

If you want to open your own file then you will need to use the `#use` directive - again this is specific to the toplevel and cannot be used in a standard `.ml` file. 

```
#use "myfile.ml"
```

If your example is more complicated and uses multiple files (modules) to do what it needs to do then I recommend reading on to the [dune solution](#debugging-with-dune) which offers greater flexibility.

### Discovering APIs 

One of the most common things you might want to do is to discover the API of a particular package. The nice thing about utop is that it will interpret and print almost anything that you evaluate. So if you are trying to use a function but can't remember the parameters then just evaluate the function and read the type signature which should provide hints.

```ocaml env=yaml
# Yaml.of_string;;
- : string -> value res = <fun>
# #require "core";;
# Core.List.map;;
- : 'a list -> f:('a -> 'b) -> 'b list = <fun>
```

You can also use the `#show` directive to see what functions and modules a certain module offers. 

```ocaml env=yaml
# #show Yaml.Stream.Mark;;
module Mark :
  sig
    type t = { index : int; line : int; column : int; }
    val t_of_sexp : Sexplib0.Sexp.t -> t
    val sexp_of_t : t -> Sexplib0.Sexp.t
  end
```

If you have a good [environment setup](/workflows/configuring-ocaml-tools-for-your-editor) then this can also help discovering APIs. 

### Debugging with dune 

### Debugging with ocamldebugger 



