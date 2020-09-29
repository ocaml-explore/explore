---
title: Debugging and Exploring OCaml Projects
date: 2020-09-29 15:16:14 +00:00
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

Dune is a widely used declarative build-tool for OCaml projects. You can use it in two ways to help debug and explore your projects. Make sure you have dune installed (`opam install dune`). 

In a fresh directory (maybe an `examples` directory) you can run:

```sh dir=examples/example
$ dune init exec example --libs batteries
Success: initialized executable component named example
```

Which will make sure dune is installed and then creates a new dune executable project. 

```sh dir=examples/example
$ ls 
_build
dune
example.ml
```

From here you can run dune exec -- ./example.exe which will print "Hello World" as that is the default example it adds. But if you look inside the dune file you’ll see an executable stanza:

```sh dir=examples/example
$ cat dune 
(executable
 (name example)
 (libraries yaml))
$ dune exec -- ./example.exe 
Info: Creating file dune-project with this contents:
| (lang dune 2.7)
Hello, World!
```

`(name example)` is the entry-point and `(libraries batteries)` specifies the other packages you want to use. The `_build` directory is used by dune. If you run dune build this will put the executable in `_build/default/example.exe`. Now you have all the power of dune if you need it but also adding more packages, changing them, adding more .ml files etc. is straightforward.

If you are building a library that already uses dune, you can include the name of it in the `(libraries ...)` field and write examples using the library. This can help with debugging and can also help with documentation. For example, consider we made a simple library called numbers. 

```sh dir=examples/library
$ cat lib/dune 
(library
 (name numbers))
$ cat lib/numbers.ml
module Float = struct
  type t = float

  let print : t -> unit = print_float
end

module Int = struct
  type t = int

  let print : t -> unit = print_int
end
```

Then we can create a small example using the library. 

```sh dir=examples/library
$ cat examples/dune 
(executable
 (name printing)
 (libraries numbers)
 (modes byte exe))

(rule
 (alias examples)
 (deps printing.exe)
 (action
  (run ./printing.exe)))
$ cat examples/printing.ml
let () = Numbers.Int.print 10
$ dune build @examples
    printing alias examples/examples
10
```

Here we create a [rule](https://dune.readthedocs.io/en/stable/dune-files.html#rule) in our `dune` file to alias to `examples` which will build and run the `printing` example. We call this with `dune build @examples`. 

Another trick is that if your library is built with dune, then you can load it into utop by running the `dune utop` command. Dune takes care of the building of the library (finding external libraries, interpreting the multiple files etc.) and then loads utop. 

### Debugging with ocamldebug

The OCaml compiler comes with a tool for debugging your OCaml programs. It only works for code compiled to bytecode so you will need to build your program using that. For executables this means adding a `(modes byte exe)` to the dune file. 

```sh dir=examples/debug
$ cat dune
(executable
 (name main)
 (modes byte exe))
$ dune build main.bc 
$ ocamldebug _build/default/main.bc
	OCaml Debugger version 4.11.0

(ocd)
```

From here you can `step` through your program, `goto` time points, set `break` points at functions and inspect variables. The full specification of `ocamldebug` can be found [in the manual](https://caml.inria.fr/pub/docs/manual-ocaml/debugger.html). Do note that the bytecode can be slow in comparison to assembly programs. You can also use [gdb](https://www.gnu.org/software/gdb/) with OCaml.

