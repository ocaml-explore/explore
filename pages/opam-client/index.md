---
title: Opam Client 
description: The Opam client is a tool used to work with Opam, an OCaml Package Manager
date: 2020-08-03 13:20:39
---

## Overview

---

opam is an OCaml Package Manager. It handles the sharing of libraries and code, dependency management and installation. In addition to this it also handles compiler installation. Opam handles what the following do for other languages: 

- Rust: `rustup` & `cargo`
- Node (Javascript): `nvm` & `npm` (or `yarn`)
- Python: `pyenv` & `pip`

![opam client diagram](/images/opam.v1.png)

A simplfied diagram of some of the key features in opam

## Key Concepts

---

### Switches

In the official documentation switches are described as (`opam switch --help`): 

> This command is used to manage "switches", which are independent
installation prefixes with their own compiler and sets of installed and
pinned packages. This is typically useful to have different versions of
the compiler available at once.

Switches can either be local or system-wide. The former is usually installed alongside your code is an `_opam` directory whilst the latter exists in `~/.opam`. Local switches are similar to *node_modules* in the NodeJS ecosystem. 

### Repositories

Opam repositories are the source of truth for what `opam` can and cannot install. If the repostory doesn't have package `X` with an opam file, then it won't be installed. The default repository is where most people will begin and end their journey with repositories. This is where you can publish new releases of your libraries and others can update and upgrade to these versions. 

This is held on Github: 

[ocaml/opam-repository](https://github.com/ocaml/opam-repository)

Note in the diagram above, in the unselected switch, there are two repositories. There is no limit on the number you can have and when installing libraries `opam` will check each for a folder that matches what you are looking for. The above is an example of what you would have to do to start cross-compiling. If you are interested check: 

### Updating & Upgrading

Hopefully with the explanation of repositories it is a little clearer what updating and upgrading means. When you install and opam switch you get a local cloned copy of the opam repository. As you code this will remain unchanged even as library authors publish new releases. 

To get the newer (and hopefully better!) code you will essentially have to `git pull` the latest opam repostiory (`opam update`) and then tell opam to install the latests version of libraries (`opam upgrade`). By supplying a single package to these commands you won't update and upgrade everything. 

Within your library opam file you can specify constraints on version numbers to ensure your code works correctly. A major version change say `irmin.1.0.0` to `irmin.2.0.0` would likely break your code.   

### Pinning

Pinning is a method for overriding the opam repository. In the diagram our repository has a version of `alcotest` at `1.1.0` - under normal circumstances this is what will be installed and used to build libraries that depend on it. 

But say we want to add a new feature or fix some code in `alcotest` and then try building some libraries that use it, do we have to release a new version or manually change the opam repository? No. You can run `opam pin add alcotest . --kind=path` from within the `alcotest` library. 

It is important to know that opam is git-based when it comes to source code hence the need to specify `--kind=path` otherwise it will try and use the latest commit and you don't want to commit everytime you want to try to change something. 

### Source and Show

Source and show are very useful commands for library authors. Source downloads the latest code attached to the version of a given library. 

Show allows you to see the metadata associated with a library. You can even print the opam file with: `opam show <library> --raw`

### Plugins

Plugins in opam are ways to extend opam's functionality in a more accessible way (anyone can write a plugin!). One of the most used is [depext](https://github.com/ocaml-opam/opam-depext) - you can tell it is a plugin from it's opam file which has `tags: "flags:plugin"`. Depext tries to install external dependencies for you. Other plugins include `opam-user-setup` which can be used to setup common tooling for supported editors like *emacs* or *vim.*

Another plugin is [opam-tools](https://github.com/avsm/opam-tools) which initialises a local development environment (i.e. using a local switch). The goal is that you could clone a repository and run `opam tools` which should do a lot of the manual setup to start developing for you. 