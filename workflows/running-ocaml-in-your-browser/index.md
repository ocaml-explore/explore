---
authors:
  - Patrick Ferris
title: Running OCaml in your Browser
date: 2020-09-08 15:00:09
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

OCaml byte-code can be compiled to Javascript to run in your browser using the [`js_of_ocaml`](https://github.com/ocsigen/js_of_ocaml) compiler. This allows you to write statically type-checked OCaml code to run in a browser, rather than dynamically typed Javascript leading to safer code at runtime. 

This workflow introduces the key concepts to writing OCaml for the browser, manipulating JSON and programming in an event-driven way which is common for web applications.

## Recommended Workflow

### Cross compiling to Javascript

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

Here we use the ppx in conjunction with OCaml's object system to create Javascript objects. By tagging properties (`val name`) with attributes you can change the semantics of how they are used. With `[@@readwrite]` we force `name` to be readable and writable. 

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

Yojson is perhaps the friendliest interface for working with JSON. There is also a [ppx_deriving_yojson](https://github.com/ocaml-ppx/ppx_deriving_yojson) library which will automatically generate the encoding (`to_yojson`) and decoding (`of_yojson`) functions for your OCaml types. Here's an example: 

<!-- $MDX file=examples/yojson/json.ml,part=0 -->
```ocaml
type person = { name : string; age : int } [@@deriving yojson]

type db = person list [@@deriving yojson]
```

Which must be compiled with an appropriate dune file.

<!-- $MDX file=examples/yojson/dune -->
```
(executable
 (name json)
 (libraries core yojson)
 (preprocess
  (pps ppx_deriving_yojson)))
```

This produces the functions `person_to_yojson` and `person_of_yojson` to convert between types (similarly for `db`). With a small main function we can read a JSON file converting the content to Yojson before converting to the underlying OCaml types. After this it converts those types back to Yojson and then prints them (of course you could then print these in JSON to a file).

<!-- $MDX file=examples/yojson/json.ml,part=1 -->
```ocaml
let () =
  let db_string = In_channel.read_all "db.json" in
  let db = Yojson.Safe.from_string db_string in
  match db_of_yojson db with
  | Ok t -> Yojson.Safe.pp Format.std_formatter (db_to_yojson t)
  | Error s -> failwith s
```

The JSON file.

<!-- $MDX file=examples/yojson/db.json -->
```json
[
  {
    "name": "Alice",
    "age": 42
  },
  {
    "name": "Bob",
    "age": 24
  }
]
```

And the output of the program.

```sh dir=examples/yojson
$ dune exec ./json.exe 
`List ([`Assoc ([("name", `String ("Alice")); ("age", `Int (42))]);
         `Assoc ([("name", `String ("Bob")); ("age", `Int (24))])])
```

### Event-driven programming 

A lot of web development is based on events and more specifically user interaction with the HTML Document Object Model (DOM). Js_of_ocaml offers a solution to writing OCaml programs that interact with DOM and trigger events on user input. 

One of the simplest programs is to log some message whenever a button is pressed. To do this we need to: 

1. Find the button in the HTML DOM.
2. Add some function to the `onClick` handler that we want to be called whenever the button is clicked.
3. Register all of this once the window has loaded (otherwise the elements won't be there). 

<!-- $MDX file=examples/event/event.ml,part=0 -->
```ocaml
open Js_of_ocaml
open Lwt.Infix
module Events = Js_of_ocaml_lwt.Lwt_js_events
module Html = Dom_html

let add_handler id =
  let btn = Html.getElementById id in
  btn##.onclick :=
    Html.handler (fun _ ->
        print_endline "Clicked!";
        Js._false)
```

After opening some important modules and creating shorter aliases to others, the first function we define is `add_handler`. This takes an (HTML) element id and adds a simple function to the `onClick` handler. This is built using the `handler` function which returns a `Js` value of `true` or `false`. Returning `false` suppresses the default behaviour. 

<!-- $MDX file=examples/event/event.ml,part=1 -->
```ocaml
let rec key_listener key =
  Events.keydown key >>= fun event ->
  if event##.keyCode = 32 then Lwt.return (print_endline "Key Pressed!")
  else key_listener key
```

The `key_listener` example is a little more complex as it uses Lwt to provide asynchronous functions using promises. Here we are listening to the `keydown` event and checking if the `keyCode` matches the "space" key (32) and printing `"Key Pressed!"` if it does. Otherwise we recursively wait for the next key down event.

<!-- $MDX file=examples/event/event.ml,part=2 -->
```ocaml
let onload _ =
  add_handler "button";
  Js._false

let () =
  Html.window##.onload := Html.handler onload;
  Lwt.async (fun () -> key_listener Html.document)
```

The final part to our small JS program is to load everything we need. We add a handler that is called when the `Html.window` loads. We also call the `key_listener` function asynchronously. 

## Real World Examples

Whilst programming in pure `js_of_ocaml` is very much a possibility, it is also nice to use frameworks which can help build more complex and performant web applications. One such framework is [bonsai](https://github.com/janestreet/bonsai). It uses Jane Street's `Incremental` and `Incr_dom` library under the hood to make DOM re-rendering faster. They provide a good set of [examples](https://github.com/janestreet/bonsai/tree/master/examples) to get you started. 

There is also Ocsigen's [Eliom](https://ocsigen.org/eliom/6.6/manual/intro) framework for building web and mobile applications. Their [client-server](https://ocsigen.org/eliom/6.6/manual/clientserver-applications) example introduces a lot of the key ideas behind their framework.
