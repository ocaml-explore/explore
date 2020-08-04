---
authors:
  - Patrick Ferris
title: Adding Unit Tests to your Project
date: 2020-07-30 10:43:50
description: Write tests to check the functionality of your code using Alcotest
users:
  - Library Authors
  - Application Developers
tools:
  - Dune
libraries:
  - Alcotest
---
## Overview

---

Testing is critical to ensuring the longevity of your project. When writing code it is very likely some new implementation will break something you wrote before. Testing provides visibility into this. 

There are lots of ways you can go about testing and a large part of this is dependent on the type of project you are working on - is it a command line tool, a library, a web-application etc. This workflow focuses mainly on writing unit tests for your OCaml code and so will likely be applicable to most applications. 

## Recommended Workflow

---

### Testing a library with Alcotest

[Alcotest](https://github.com/mirage/alcotest) is a unit testing framework. In the following example, we'll pretend we are testing the [ocaml-yaml](https://github.com/avsm/ocaml-yaml) library -- an OCaml interface toy he YAML 1.1 specification. Incidentally, the real library [uses alcotest](https://github.com/avsm/ocaml-yaml/blob/master/tests/test.ml).

Dune supports test stanzas which indicate that the directory is building a test suite and should be treated as such. The main fields that you need to provide are the test entry point (`(name file)`) and what libraries you are using. For our yaml example, we need the yaml library and alcotest. 

<!-- $MDX file=examples/yaml/dune -->
```
(test
 (name test)
 (libraries alcotest yaml))
```

The test entry point here is the `test.ml` file. It calls the `Alcotest.run` function with a name for the entire test and a list of unit tests which are of type `string * 'a test_case list`. 

<!-- $MDX file=examples/yaml/test.ml -->
```ocaml
let () = Alcotest.run "Yaml" [ ("Yaml", Test_yaml.tests) ]
```

From here we need to test as many compilation units as possible. This tends to be the recommended way of splitting up tests, by file. For simplicicity we will test the `of_string` yaml function which parses a string and returns a `Yaml.value` wrapped in a `Yaml.res`. 

When using alcotest you need to wrap your types in a module which provides a pretty-printing function (`pp`) and an equality checking function (`equals`). Alcotest exposes the `testable` function which will do the module wrapping for you, you just need to provide the `pp` and `equals` function. 

<!-- $MDX file=examples/yaml/test_yaml.ml,part=0 -->
```ocaml
let yaml = Alcotest.testable Yaml.pp Yaml.equal

let pp_error ppf (`Msg x) = Format.pp_print_string ppf x

let error = Alcotest.testable pp_error ( = )
```

Next we write the unit tests. Alcotest provides useful combinators for building up larger, more complex testable types. Here we have used the `result` combinator to make a `Yaml.value Yaml.res` testable with our custom `yaml` and `err` testables. It is up to to write good unit tests. 

<!-- $MDX file=examples/yaml/test_yaml.ml,part=1 -->
```ocaml
let test_of_string () =
  let open Yaml in
  let ok_str = "author: Alice\ntags:\n  - 1\n  - 2\n" in
  let err_str = "tags:  - 1\n  - 2\n" in
  let ok_correct =
    Ok
      (`O
        [ ("author", `String "Alice"); ("tags", `A [ `Float 1.; `Float 2. ]) ])
  in
  let err_correct =
    Error
      (`Msg
        "error calling parser: block sequence entries are not allowed in this \
         context character 0 position 0 returned: 0")
  in
  Alcotest.(check (result yaml error)) "same yaml" ok_correct (of_string ok_str);
  Alcotest.(check (result yaml error))
    "same err" err_correct (of_string err_str)
```

The tests can be run from the command line with `dune runtest` - it is also common to augment your opam file's build command with running tests: 

```
build: [
 ["dune" "build" "-p" name "-j" jobs]
 ["dune" "runtest" "-p" name] {with-test}
]
```

### Testing executables with MDX

Alcotest offers a flexible but relatively simple way for testing functionality within components of your program. If your project is a CLI tool or an executable run from the command-line you will need another tool for testing it.

[Mdx](/platform/mdx) allows you to write markdown with executable blocks, this could be in pure OCaml or in shell script. With dune's promote feature you can take snapshots of what *expect* your program to produce and ensure subsequent code doesn't break this. 

If it does make changes (ones you want) you can promote the new changes to your file and commit the results. If you have ever worked with [ReactJS and Jest snapshots](https://jestjs.io/docs/en/snapshot-testing), it is very similar. 

Take for example a simple CLI tool that takes a number and prints that number plus one.

<!-- $MDX file=examples/mdx/src/main.ml -->
```ocaml
let () =
  if Array.length Sys.argv < 2 then print_endline "Need to supply a number"
  else print_int (int_of_string Sys.argv.(1) + 1)
```

Which, with an appropriate opam file, can be built with the following dune file. The `public_name` field makes the tool globally available provided there is an opam file.

<!-- $MDX file=examples/mdx/src/dune -->
```
(executable
 (name main)
 (public_name main))
```

Now we can build a simple test of the CLI tool using mdx. In a `tests/bin` folder we write a `exec.t` file and pass it some tests in markdown code blocks. 

~~~
# Testing the command line 

## Should print that a number should be supplied 
```sh
$ main
Need to supply a number
```

## Should print that 11 
```sh
$ main 10
11
```

## Should print that 0 
```sh
$ main -1
0
```
~~~

And add a dune file: 

<!-- $MDX file=examples/mdx/tests/bin/dune -->
```
(mdx
 (files exec.t)
 (packages main))
```

Now when we run `dune runtest` we'll be greeted with a diff of our markdown file with the proposed outputs of our small shell scripts. We can add these to the file by promoting them with `dune promote` then commit them to the repository. If tests fail in the future we will get the diff and can decided whether to promote them or not. 

~~~diff
## Should print that a number should be supplied 
```
$ main
+Need to supply a number
```

## Should print that 11 
```
$ main 10
+11
```

## Should print that 0 
```
$ main -1
+0
```
~~~

## Alternatives

---

### QCheck

[QCheck](https://github.com/c-cube/qcheck) is based on Haskell's [QuickCheck](https://hackage.haskell.org/package/QuickCheck) library for property-based testing. It also offers a sub-library that can integrate directly with Alcotest.  

### Dune Expect Tests

These tests tend to be written inline with your source OCaml code using `ppx_inline_test`. To get expect tests you can use `ppx_expect` to write assertions about parts of your program. The [documentation](https://dune.readthedocs.io/en/stable/tests.html) covers all of this in much more detail. 

## Real World Examples

---

[Yojson](https://github.com/ocaml-community/yojson/tree/master/test) is good example of using Alcotest to unit test the different aspects of the library. [Dune-release](https://github.com/ocamllabs/dune-release/tree/master/tests/bin), part of the OCaml Platform, uses Mdx to ensure the CLI tool is properly tested.
