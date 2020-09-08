---
authors:
  - Patrick Ferris
title: Running OCaml in your Browser
date: 2020-08-05 15:57:05
description: Use js_of_ocaml to run OCaml code in the browser
topic: 
  coding: 
    - false
users:
  - Application Developer
tools:
  - Dune
libraries: 
  - Js_of_ocaml
---

## Overview

OCaml byte-code can be compiled to Javascript to run in your browser using the [`js_of_ocaml`](https://github.com/ocsigen/js_of_ocaml). This allows you to write statically type-checked OCaml code to run in a browser rather than dynamically typed Javascript - this tends to lead to safer code at runtime.  

## Recommended Workflow

### Js_of_ocaml

Dune has built-in support for compiling byte-code to Javascript. Consider a "hello-world" example: 

<!-- $MDX file=examples/hello-world-js/main.ml -->
```ocaml
let () = print_endline "Hello World"
```

This can be built with `dune build`, provided the `js_of_ocaml` package is installed (to get the cross-compiler) and the following dune file: 

<!-- $MDX file=examples/hello-world-js/dune -->
```dune
(executable
 (name main)
 (modes js))
```

This will output your main file into a Javascript file called `main.bc.js`. To get this running in your browser you can then create an `index.html` file in the same `_build/default` folder and include the JS file in a script tag: `<script src="main.bc.js></script>`. This is the quickest way to get started. If you had node installed you could also run it using `node _build/default/main.bc.js`. 

Although Javascript has many features in common with functional-styled programming, it primarily works using objects and mutable data. To make the transition from OCaml to Javascript easier, there is a [ppx](https://ocsigen.org/js_of_ocaml/3.1.0/manual/ppx) to make objects using the OCaml syntax. There is a [separate workflow](/workflows/meta-programming-with-ppx) if you are unfamiliar with OCaml's meta-programming capabilities with ppx. Once installed, you can make objects fairly simply. Make sure you preprocess your files by adding `(preprocess (pps js_of_ocaml-ppx))` to your dune file. 

<!-- $MDX file=examples/ppx/dune -->
```
(executable
 (name main)
 (preprocess
  (pps js_of_ocaml-ppx))
 (modes js))
```

<!-- $MDX file=examples/ppx/main.ml -->
```ocaml
let () =
  let person =
    object%js (self)
      val name = "Alice" [@@readwrite]

      method set str = self##.name := str

      method get = self##.name
    end
  in
  print_endline person##get;
  person##set "Bob";
  print_endline person##get
```

Here we use the ppx in conjunction with OCaml's object system to create Javascript objects. By tagging properties (`val name`) with attributes you can change the semantics of how they are used. Here we force `name` to be readable and writable. 

```sh dir=examples/ppx
$ dune build
$ grep -A3 "person=" _build/default/main.bc.js
     person=
      {"name":t8,
       "set":caml_js_wrap_meth_callback(t9),
       "get":caml_js_wrap_meth_callback(t10)},
```

### Working with JSON 

[Javascript Object Notation](https://www.json.org/json-en.html) (JSON) is a data format that is very commonly used for web applications and exchanging information over the internet. There is a very close relationship between OCaml types and JSON structures. The two main types being objects (similar to OCaml records) and arrays (similar to OCaml lists or arrays). There are a few OCaml libraries for working with JSON including [jsonm](https://github.com/dbuenzli/jsonm) (and the simplified [ezjsonm](https://github.com/mirage/ezjsonm)) and [yojson](https://github.com/ocaml-community/yojson). 

Yojson is perhaps the friendliest interface for working with Yojson. There is also a [ppx_deriving_yojson](https://github.com/ocaml-ppx/ppx_deriving_yojson) library which will automatically generate the encoding (`to_yojson`) and decoding (`of_yojson`) functions for your OCaml types. Here's an example: 

<!-- $MDX file=examples/yojson/json.ml,part=0 -->
```ocaml
type person = { name : string; age : int } [@@deriving yojson]

type db = person list [@@deriving yojson]
```

And a small main function which reads the JSON file converting the content to Yojson before converting to the underlying OCaml types. After this it converts those types back to Yojson before printing them (of course you could then print these in JSON to a file).

<!-- $MDX file=examples/yojson/json.ml,part=1 -->
```ocaml
let () =
  let db_string = In_channel.read_all "db.json" in
  let db = Yojson.Safe.from_string db_string in
  match db_of_yojson db with
  | Ok t -> Yojson.Safe.pp Format.std_formatter (db_to_yojson t)
  | Error s -> failwith s
```

```sh dir=examples/yojson
$ dune exec ./json.exe 
`List ([`Assoc ([("name", `String ("Alice")); ("age", `Int (42))]);
         `Assoc ([("name", `String ("Bob")); ("age", `Int (24))])])
```

## Real World Examples

Jane Street have written a library for building dynamic webapps that uses `js_of_ocaml` extensively: [incr_dom](https://github.com/janestreet/incr_dom). There are some great [examples](https://github.com/janestreet/incr_dom/tree/master/example) to get started with.
