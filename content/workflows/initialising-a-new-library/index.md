---
authors:
  - Patrick Ferris
title: Initialising a New Library
date: 2020-07-27 09:35:49
description: Build the scaffolding for your solution to a problem
users:
  - Library Authors
topic: 
  starter: 
    - true
tools:
  - Dune
---

## Overview

Getting started with a project should be simple - ideally a single command would initialise some kind of wizard to guide you through setting a project up. Much like the `npm init` command which takes answers to populate the `package.json` file. 

This is important because it is very easy to make mistakes in setting up a repository for a new project and the ideal workflow for a library author would to start writing code almost immediately.

## Recommended Workflow

### Opam and Dune

For a new library there are two key components you will need: 

1. Dune files to build the project with dune. 
2. An opam file to unlock the power of the OCaml platform. 

For now, there is no one tool that will accomplish this in one go so multiple tools will be used. 

Dune has a `dune init` command that is very simple and will initialise a bare bones project, executable or library. For a library we can execute `dune init library <library-main-file>`. This should generate a "Hello World" file and a simple dune file with a *library stanza*. 

The next step is to generate your opam file. There are three ways you can do this: 

1. Using opam pin - to edit an opam file  you can use `opam pin add . --edit` this will open an editor with a prefilled library in it. The slightly confusing aspect to this is that you are also simultaneously pinning the package which you might not want to do. 
2. Copying an existing opam file and editing it - from the command line `opam show <an-installed-packages> --raw` will print to stdout the opam file for whatever package you added. You can the redirect this to a file and edit it accordingly. 
3. By hand - the simplest, but perhaps longest, is to write it by hand. 

Regardless of what method you choose, the `opam lint` command is useful to ensure the opam file has correct syntax. 

### Generate an Opam file from Dune

Using the `dune-project` file to [generate your opam file](https://dune.readthedocs.io/en/stable/opam.html#generating-opam-files) is a useful way to ensure your dune dependency is correctly versioned. In this approach you can express your opam file in the dune language and this will automatically generate an opam file for you. 

Note that sometimes you need an escape-hatch as the specification in `dune-project` for opam files is not as flexible as an opam file - for this you should use the [templates](https://dune.readthedocs.io/en/stable/opam.html#opam-template) as an escape-hatch. 

## Real World Examples

Many of the community libraries use dune and opam to build their projects - [cstruct](https://github.com/mirage/ocaml-cstruct) and [alcotest](https://github.com/mirage/alcotest) for example. 

Dune itself use the [dune-project](https://github.com/ocaml/dune/blob/master/dune-project) approach of generating opam files.
