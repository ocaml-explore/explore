---
authors:
  - Patrick Ferris
title: Using Tools Written in OCaml
date: 2020-10-05 09:48:29
description: Run tools built with OCaml
topic: 
  misc: 
    - true
users:
  - End User
tools:
  - Dune
---
## Overview

OCaml is an industrial-strength programming-language that has been used to build many end-user tools which may be completely unrelated to actually writing OCaml code (unlike libraries for example). Here are a few examples: 

 - Facebook's static type-checker for Javascript [Flow](https://github.com/facebook/flow). 
 - [Irmin-unix](https://irmin.io/tutorial/command-line) allowing you to build Irmin stores on disk and much more.
 - [Coq](https://coq.inria.fr/), the formal proof management system. 

## Recommended Workflow

Installing binaries like this usually can be done in two ways -- through the system package manager of your operating system or building from source using the OCaml package manager, opam. Here, we will focus on the latter. 

Once you have [opam installed](https://opam.ocaml.org/doc/Install.html) the process should be pretty straightforward. 

```sh non-deterministic=output
$ opam install irmin-unix
The following actions will be performed:
  ∗ install irmin-unix 2.2.0

<><> Processing actions <><><><><><><><><><><><><><><><><><><><><><><><><><>  🐫 
⬇ retrieved irmin-unix.2.2.0  (cached)
∗ installed irmin-unix.2.2.0
Done.
$ irmin 
usage: irmin [--version]
             [--help]
             <command> [<args>]

The most commonly used subcommands are:
    init        Initialize a store.
    get         Read the value associated with a key.
    set         Update the value associated with a key.
    remove      Delete a key.
    list        List subdirectories.
    tree        List the store contents.
    clone       Copy a remote respository to a local store
    fetch       Download objects and refs from another repository.
    merge       Merge branches.
    pull        Fetch and merge with another repository.
    push        Update remote references along with associated objects.
    snapshot    Return a snapshot for the current state of the database.
    revert      Revert the contents of the store to a previous state.
    watch       Get notifications when values change.
    dot         Dump the contents of the store as a Graphviz file.
    graphql     Run a graphql server.

See `irmin help <command>` for more information on a specific command.
```

For getting unreleased versions of tools, you can use the pinning tool that opam offers instead of installing it which uses the repository that your opam switch it set up with i.e. `opam pin add flow_parser git+https://github.com/facebook/flow`. 
