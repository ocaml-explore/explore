---
title: Opam
description: An explanation of the OCaml Package Manager client and file format
date: 2020-08-11 17:08:58
---

## Managing Packages in OCaml

[Opam](https://opam.ocaml.org/) is the the OCaml package manager and compiler manager. Packages could be executables to run from the command-line, compilers for other languages, libraries to use in your code etc. If you are arriving at OCaml from other languages, the [opam-client](/pages/opam/opam-client) (the tool you interact with from the command line) is roughly equivalent to: 

- Rust: `rustup` & `cargo`
- Node (Javascript): `nvm` & `npm` (or `yarn`)
- Python: `pyenv` & `pip`

In order to join the OCaml open source community, all you need to do is to add an [opam file](./pages/opam/opam-files) to your project.  This `opam` file describes the build instructions for your project, as well as any dependencies it might need. An `opam` file is useful for a project of any size — from toy learning exercises to big theorem provers — since it allows someone else to easily rebuild and replicate your work, and even extend it if they choose to.

## Opam files

Once you are comfortable with your code and want to share it more publicly, an [opam file](/pages/opam/opam-files) can be published to the central OCaml [opam repository](https://github.com/ocaml/opam-repository/).  This is a collection of tens of thousands of packages that have been contributed freely by the community since 2013.  The opam-repository does not contain the full source code to your project; instead, it tracks pointers to different versions of your code, and also the various compatibility constraints to automatically figure out which versions work with each other.  The usual mechanism to track your releases is to use a version control system such as git.  You can [browse the packages](https://opam.ocaml.org) online to see what's available.

## Opam Concepts 

How do you actually manipulate opam files?  There are several tools that can parse these files and repositories and install the software you want.  The primary reference implementation that runs on macOS and Linux is also the [opam client](/pages/opam/opam-client) , and is the first thing you will want to configure on your system to get started. The following pages will guide you through a foundational understanding of how Opam works. 

1. [Solving dependencies](/pages/opam/package-managers)
2. [Switches and compilers](/pages/opam/switches-and-compilers)
3. [Repositories and pinning](/pages/opam/repositories-and-pinning)
4. [Plugins](/pages/opam/plugins)
5. [The client and common commands](/pages/opam/cheatsheet)