---
authors:
  - Patrick Ferris
title: Fuzz Testing your Project
date: 2020-07-27 09:35:49
description: Make fuzz tests to find uncover hard to find bugs in your code
users:
  - Library Authors
  - Application Developers 
tools:
  - Bun 
---

## Overview

---

Fuzz testing consists in generating random values and feeding them to functions from your code base and looking for unusual behavior in an automated way. Compared to regular testing, it takes longer to run, but can find cases that would be difficult to find by hand.
This can extremely useful for complex parsers or protocols which are expected to cope with a large variety of inputs.
We rely on the crowbar library and the AFL fuzzer to do so.

## Fuzz testing an OCaml library

---

The simplest kind of code to test is a parser: the fuzzer will generate random strings, feed them to the parsing function, and look for crashes.

Suppose the library to test exposes a parser function.

<!-- $MDX file=examples/parser/lib/config_file.mli -->
```
type t

val parse : string -> t option
```

We can use the crowbar library to write a test executable that generates random strings.

<!-- $MDX file=examples/parser/fuzz/fuzz_config_file.ml -->
```
let () =
  Crowbar.add_test [Crowbar.bytes] (fun s ->
    let _ : Config_file.t option = Config_file.parse s in
    ())
```

This executable can be built and run with dune:

<!-- TK no highlight -->

```sh dir=examples/parser
$ dune exec ./fuzz/fuzz_config_file.exe
test1: FAIL

When given the input:

    "\164\194\239\194\144S\131\218\252\210\029\2372\224cR\225r,\028\243\159\139m\004\018\254\152\016\207\176>\194\r\245#\189\128\n\179]\007\251\162O\247\134\1655\173\006\019\216\024W\182\219\245u\145%O\026\193"

the test threw an exception:

    "Assert_failure lib/config_file.ml:9:9"
    Raised at file "lib/config_file.ml", line 9, characters 9-21
    Called from file "src/list.ml", line 390, characters 13-17
    Called from file "src/list.ml" (inlined), line 418, characters 15-31
    Called from file "lib/config_file.ml" (inlined), line 13, characters 5-27
    Called from file "lib/config_file.ml", line 12, characters 2-53
    Called from file "fuzz/fuzz_config_file.ml", line 3, characters 35-54
    Called from file "src/crowbar.ml", line 329, characters 16-19

[1]
```

Indeed, when we look at the source code, the `parse_line` function fails when
there is no `'='` character on a line:

<!-- $MDX file=examples/parser/lib/config_file.ml -->
```
open Base

type t = (string * string) list

let parse_line s =
  match String.split s ~on:'=' with
  | [] -> None
  | [key;value] -> Some (key, value)
  | _ -> assert false

let parse s =
  String.split s ~on:'\n'
  |> List.map ~f:parse_line
  |> Option.all
```

Running the fuzzer directly is called standalone mode. In this mode, Crowbar will only generate a few tests and is unlikely to find any interesting errors.
To run more tests, you can run crowbar under AFL. It will start from a few known good examples, alter them, and re-run the fuzzer based on the coverage data.

To do so, you will need the afl fuzzer (or the newer fork afl++), usually installable from your distribution:

```
# example
$ apt install afl++
```

AFL will inspect the binary as it runs, and needs special compilation flags for
this mechanism to work. Use an AFL-enabled opam switch to have this

```
# example
$ opam switch create ./ 4.11.0+afl
```

In normal operation, AFL requires a set of known-good files. But when using crowbar,
the situation is different since files are just seeds for AFL. So it is possible
to use just an almost empty file.

```
$ mkdir in
$ echo x > in/empty
```

Then we can run AFL, instructing it to store its state and results in an `out`
folder. Note that this command does not rebuild the fuzzer, make sure
it is up to date before running the command. The `@@` part corresponds to the
input file. With crowbar, it is always the sole argument.

```
$ afl-fuzz -i in -o out -- ./_build/default/fuzz.exe @@
```

This runs for a long time, and will put inputs that crash the function in the out/crashes folder.

To investigate results, it is possible to run the fuzzer on these output files to determine the cause of the crash:

```
./_build/default/fuzz.exe out/crashes/id:000000,sig:06,src:000000,time:3,op:flip4,pos:0
test1: ....
test1: FAIL

When given the input:

    ""

the test threw an exception:

   ...

Fatal error: exception Crowbar.TestFailure

```

## Hooking into the build system

A fuzzer is just an executable, but it might not be something that you want to run with your tests on every commit. On the other hand, if the library changes, it is good to keep the fuzzer in sync. A tradeoff is to:

- build the fuzzer as part of tests, without actually running it
- attach running the fuzzer (in standalone mode) to a `@fuzz` alias
mode.

<!-- $MDX file=examples/parser/fuzz/dune -->
```
(executable
 (name fuzz_config_file)
 (libraries config_file crowbar))

(alias
 (name runtest)
 (deps fuzz_config_file.exe))

(rule
 (alias fuzz)
 (action
  (run ./fuzz_config_file.exe)))
```

Note that this makes crowbar a test-dependency at the opam level, so this should
be marked as such in `dune-project`:

<!-- $MDX file=examples/parser/dune-project -->
```
(lang dune 2.7)

(generate_opam_files true)

(package
 (name config_file)
 (depends
   base
   (crowbar :with-test)))
```

## Examples

---

- [NathanReb/ocaml-afl-examples](https://github.com/NathanReb/ocaml-afl-examples)
- [colombe](https://github.com/mirage/colombe/blob/da2281afa60cf906405120f647d8c247d189cb85/fuzz/fuzz.ml)
- [eqaf](https://github.com/mirage/eqaf/blob/234ac0b414ba6740fbceedf25ad6cab4633b7de0/fuzz/fuzz.ml)
- [opam](https://github.com/ocaml/opam/tree/7803ac4c3ad0697c3607ef3c05572ec3b894dfc0/src/crowbar)
