---
title: Alcotest
date: 2020-07-27 09:35:49
description: A library for building unit tests
repo: https://github.com/mirage/alcotest
---

## Key Concepts

---

The structure of your tests should look something like: 

```
.
|-- suite1
|   |-- Quick
|   |   |-- test1
|   |   `-- test2
|   `-- Slow
|       `-- test1
`-- suite2
    |-- Quick
    |   `-- test1
    `-- Slow
        |-- test1
        `-- test2
```

A typical way of achieving this is to have separate files for each test-suite for a particular component of your project e.g. `test_parser.ml` where you define unit tests for your parser than in an `mli` file export the tests: 

```
val tests : unit Alcotest.test_case list
```

After that you can collect all of your suites together in `[test.ml](http://test.ml)` file that will be run for testing your project. It is also common case to have `[testable.ml](http://testable.ml)` file where you can produce testable version of your types: 

```ocaml
(* Some type you have - camel.ml *)
type camel = Bactrian of string 

let pp_camel fmt = function
	| Bactrian str  -> Format.pp_print_string fmt str 

let compare a b = match a, b with 
	| Bactrian s1, Bactrian s2 -> String.compare s1 s2

(* Making camels testable - testable.ml *) 
let camel = Alcotest.testable Camel.pp_camel Camel.compare
```
