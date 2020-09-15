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

OCaml byte-code can be compiled to Javascript to run in your browser using the `js_of_ocaml` compiler linked in the libraries tag. This allows you to write statically type-checked OCaml code to run in a website rather than dynamically typed Javascript - this gives you more guarantees over what errors you will get at runtime. 

## Recommended Workflow

### Js_of_ocaml

Dune has built-in support for compiling byte-code to Javascript. Consider a "hello-world" example: 

<!-- $MDX file=examples/hello-world-js/main.ml -->
```ocaml
let () = print_endline "Hello World"
```

This can be built with `dune build`, provided the `js_of_ocaml` package is installed (to get the cross-compiler) and the following dune file: 

<!-- $MDX file=examples/hello-world-js/dune -->
```
(executable
 (name main)
 (modes js))
```

This will output your main file into a Javascript file called `main.bc.js`. To get this running in your browser you can then create an `index.html` file in the same `_build/default` folder and include the JS file in a script tag: `<script src="main.bc.js></script>`. This is the quickest way to get started. If you had node installed you could also run it using `node _build/default/main.bc.js`. 

Although Javascript has many features in common with functional-styled programming, it primarily works using objects and mutable data. To make the transition from OCaml to Javascript easier, there is a [PPX](https://ocsigen.org/js_of_ocaml/3.1.0/manual/ppx) to make objects using the OCaml syntax. Once installed, you can make objects fairly simply, make sure you add `(preprocess (pps js_of_ocaml-ppx))` to your dune file. 

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

## Alternatives

### Bucklescript

An alternative is to use Bucklescript to compile your OCaml code to Javascript. At this point you will have to leave dune behind you and venture into the world of Bucklescript and `npm` - [this post on discuss OCaml](https://discuss.ocaml.org/t/js-of-ocaml-vs-bucklescript/2293/7) might be worthwhile reading to find out which is best for you. 

[BuckleScript · A faster, simpler and more robust take on JavaScript.](https://bucklescript.github.io/)

## Real World Examples

Jane Street have written a library for building dynamic webapps that uses `js_of_ocaml` extensively: [incr_dom](https://github.com/janestreet/incr_dom). There are some great [examples](https://github.com/janestreet/incr_dom/tree/master/example) to get started with.
