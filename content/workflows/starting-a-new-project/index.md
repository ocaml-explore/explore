---
title: Starting a new Project
date: 2020-09-24 09:34:26 +00:00
authors:
- Patrick Ferris
description: Build the scaffolding for your solution to a problem
tools:
- Dune
topic: 
  starter: 
    - true
users:
- beginner
- library authors
libraries: 
resources:
---

## Overview

Starting a new coding project is exciting. This excitement shouldn't be taken away by hard-to-understand (or worse, broken) tooling. There's no correct way to set up your OCaml project, but what follows is a fairly common structure that works for a majority of programs. Along the way we'll be using dune as the the build tool and [opam](/pages/opam) as the package manager. 

## Recommended Workflow

### Opam and Dune

For a new library there are two key components you will need, a build tool and a package manager. The build tool compiles your program whether that be to bytecode, assembly or even [javascript](/workflows/running-ocaml-in-your-browser). The package manager allows you to make use of third party libraries and eventually even share your code for others to use. 

Most OCaml projects have a structure of *binaries* (executables), *libraries* and *tests*. These map to the three most common dune stanzas: *executable, library and test*. Not all fall into this structure, but it acts as a simple base to begin building your project. The [navigating OCaml projects](/workflows/navigating-ocaml-projects) workflow shines some more light onto this structure.

A typical directory layout would then be: 

```
.
|-- README
|-- dune-project
|-- bin
|   |-- dune
|   `-- main.ml
|-- lib
|   |-- dune
|   `-- numbers.ml
`-- test
    |-- dune
    `-- test.ml
```

### Adding Dune Files 

The [dune platform page](/platform/dune) describes some of the key concepts behind dune. One of the most important is its declarative nature and how it builds based on the presence of dune files. It is not uncommon for nearly all directories in your project to have some form of dune file.

Dune has a `dune init` command that is very simple and will initialise a bare bones project, executable, test or library. For a library we can execute `dune init library <library-main-file>`. This should generate a "Hello World" file and a simple dune file with a *library stanza*. If you are using the [VS Code Platform](/workflows/configuring-ocaml-tools-for-your-editor), it supports auto-completion for these files as well. 

```sh dir=examples/project/lib
$ dune init library numbers --libs yaml
Success: initialized library component named numbers
$ cat dune 
(library
 (name numbers)
 (libraries yaml))
```

### Using Libraries 

Opam allows you to install libraries from the [opam-repository](https://github.com/ocaml/opam-repository). If you run `opam install irmin` this will build the [irmin](https://irmin.io/) library for you in the global switch directory (somewhere like `~/.opam/<switch>/lib/irmin`) or in the local directory (`./_opam`). Once installed whenever you add a library to your dune file, dune will be able to build your code to include that library. 

```
(executable
  (name main)
  (libraries irmin))
```

You may want to specify a specific version of the libraries you use, or you may even want to use the unreleased development version. Read on about generating opam files to find out how to do this. 

### Generating an Opam File 

The next step is to generate your [opam file](/pages/opam-file). An opam file unlocks the power of the opam package manager and often other parts of the OCaml Platform tooling. It is always recommended to have one, even if you have no intention of publishing the code to the central opam repository. There are three ways you can do this: 

1. Using opam pin - to edit an opam file you can use `opam pin add . --edit` this will open an editor with a pre-filled library in it. The slightly confusing aspect to this is that you are also simultaneously pinning the package which you might not want to do. For more information on pinning, [read the opam page](/pages/opam). 
2. Copying an existing opam file and editing it - from the command line `opam show <an-installed-package> --raw` will print to stdout the opam file for whatever package you added. You can the redirect this to a file and edit it accordingly. 
3. By hand - the simplest, but perhaps longest, is to write it by hand. 

Regardless of what method you choose, the `opam lint` command is useful to ensure the opam file has correct syntax. 

The standard way is to use the `dune-project` file to [generate your opam file](https://dune.readthedocs.io/en/stable/opam.html#generating-opam-files) . It is a useful way to ensure your dune dependency is correctly versioned. In this approach you can express your opam file in the dune language and this will automatically generate an opam file for you. 

```sh dir=examples/project
$ cat dune-project 
(lang dune 2.7)

(name numbers)

(generate_opam_files true)

(source
 (github alicesmith/numbers))

(license ISC)

(authors "Alice Smith")

(maintainers "alice@example.com")

(package
 (name numbers)
 (synopsis "A library for useful number functions")
 (description "This library provides useful number functions")
 (depends
  (alcotest :with-test)
  (yaml
   (= 2.1.0))))
$ dune build 
$ cat numbers.opam
# This file is generated by dune, edit dune-project instead
opam-version: "2.0"
synopsis: "A library for useful number functions"
description: "This library provides useful number functions"
maintainer: ["alice@example.com"]
authors: ["Alice Smith"]
license: "ISC"
homepage: "https://github.com/alicesmith/numbers"
bug-reports: "https://github.com/alicesmith/numbers/issues"
depends: [
  "dune" {>= "2.7"}
  "alcotest" {with-test}
  "yaml" {= "2.1.0"}
  "odoc" {with-doc}
]
build: [
  ["dune" "subst"] {dev}
  [
    "dune"
    "build"
    "-p"
    name
    "-j"
    jobs
    "@install"
    "@runtest" {with-test}
    "@doc" {with-doc}
  ]
]
dev-repo: "git+https://github.com/alicesmith/numbers.git"
```

Adding dependencies is not automatic in OCaml. For example, you might have `yaml` already installed and your dune file might add it in a `libraries` field, but you need to add it to your `dune-project`'s description of the opam file. This means other people who might not have it installed will get it whenever they try and install your library.

The `:with-test` flag tells opam that unless specified this dependency does not need to be installed in order to use the package. Another similar flag is `:with-doc` for documentation only dependencies. 

The dune-project file also supports version constraints on the dependencies. Here, `yaml` must be version `2.1.0`. The [dune documentation](https://dune.readthedocs.io/en/stable/opam.html#generating-opam-files) does a great job explaining what's available.

Note that sometimes you need an escape-hatch as the specification in `dune-project` for opam files is not as flexible as an opam file - for this you should use the [templates](https://dune.readthedocs.io/en/stable/opam.html#opam-template) to include things like `pin-depends` to add unreleased packages. This website [uses a template](https://github.com/ocaml-explore/explore/blob/trunk/explore.opam.template) in order to use unreleased versions of packages -- remember they still need to be dependencies in the opam file as well as pin-depends.

### Next steps

The simple project above should be enough to get you started with building OCaml projects outlining the most important features like directory structure, dune files and opam files. There are multiple next steps you can take, here are just a few: 

 - Test your libraries using [unit tests](/workflows/adding-unit-tests-to-your-project) and the Alcotest library. 
 - Keep your code clean with [automatic formatting](/workflows/keeping-your-code-clean).
 - Add and [generate documentation](/workflows/documenting-your-project) for your project.
 - [Preprocess](/workflows/meta-programming-with-ppx) your library using a ppx for adding additional functionality.

## Real World Examples

Many of the community libraries use dune and opam to build their projects - [cstruct](https://github.com/mirage/ocaml-cstruct) and [alcotest](https://github.com/mirage/alcotest) are just two of many for example. 

Dune itself use the [dune-project](https://github.com/ocaml/dune/blob/master/dune-project) approach of generating opam files.
