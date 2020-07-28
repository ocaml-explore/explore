---
authors:
  - Patrick Ferris
title: Profiling your Project 
date: 2020-07-27 09:35:49
description: Profile the memory and performance of your application
users:
  - Library Authors
  - Application Developer
tools:
  - Dune
---

## Overview

---

For profiling programs there tend to be two main properties that most developers care about: 

1. Performance
2. Memory Usage

OCaml is a garbage-collected programming language, but there are ways to alleviate the the strain on the GC. There is also good support for profiling the performance of your program to find the sections that are consuming the most execution time. 

## Recommended Workflow

---

### Memory

To enable memory profiling (much like with fuzzing) you need to install specific variants of the OCaml compiler - in particular it must have `+spacetime` in its package name. 

Spacetime monitors the OCaml heap - this is where values are stored if they are not represented as unboxed integers. You can set the interval you want spacetime to monitor at by issuing: 

```bash
ocamlopt -o <executable> somefile.ml
OCAML_SPACETIME_INTERVAL=1000 <executable>
```

***Note: this is a little dependent on what shell you use, for example with fish you will have to preprend `env` to the `OCAML...` command.*** 

The workflow is very similar to `gprof` with OCaml in that you run the instrumented version which produces additional files, and then use a tool to make sense of the results. If we have some `mem_test.ml` file we want to profile, the series of commands may look something like this: 

```bash
# Create a new spacetime enable switch 
opam switch create 4.10.0+spacetime
eval $(opam env)

# Install the memory profiling view
opam install prof_spacetime 

# Compile your code
ocamlopt -o mem_test mem_test.ml

# Run the executable with profiling enabled 
OCAML_SPACETIME_INTERVAL=1000 ./mem_test

# Process the results - fill in your unique <id>
prof_spacetime process spacetime-<id>

# View the results in a browser 
prof_spacetime serve -p spacetime-<id>.p
```

### Performance

Perf is a tool that can be used to profile programs without any additional instrumentation. 

## Alternatives

---

### Performance with `gprof`

***Note: gprof is only supported up to version 4.08.0 of the OCaml compiler. Additionally, because of the required linking options with Clang and MacOS you may encounter the following error "**the clang compiler does not support -pg option on versions of OS X 10.9 and later**"*** 

[Gprof](https://sourceware.org/binutils/docs/gprof/) is the GNU profiler and can be used to track how much time is spent in different parts of your application. Like memory profiling this requires additional instrumentation in your binaries. However, unlike spacetime profiling, it doesn't require a specific switch, just some flags to be set. 

In the simplest case (compiling by hand) the following is sufficient: 

```bash
# Create compatible compiler in new switch  
opam switch create 4.08.0
eval $(opam env)

# Compile the code with profiling enabled 
ocamlopt -p -o test test.ml 

# Run the code
./test

# View the results 
gprof test | less 
```

If you are using dune to build your project you will need something like the following in your dune file at the root of your project: 

```
(env
 (perf
  (flags (:standard -p))))
```

There after the process is very similar: 

```
# Compile the program with profiling enabled 
dune build --profile perf 

# Run the program
_build/default/test.exe

# See the profiling results 
gprof _build/default/test.exe | less 
```

### Real World Examples

---