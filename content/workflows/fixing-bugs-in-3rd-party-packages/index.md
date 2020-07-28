---
authors:
  - Patrick Ferris
title: Fixing Bugs in 3rd Party Packages
date: 2020-07-27 09:35:49
description: Track down and fix bugs in libraries that you use
users:
  - Library Authors
tools:
  - Dune
---

## Overview

---

Working with third-party packages means coming across areas for improvement or those that need fixing. Knowing how common codebases are structured and an appreciation for the tools allows you to more easily:

- Fix the bug if you know how.
- Raise an issue wherever the code is being hosted on.
- Find and comment on an existing issue with extra information you have from my own debugging.

This will also give you insight into how you can structure your own code to allow others to more easily debug it. 

There are multiple aspects to unpack in this workflow including: 

1. Getting the source code.
2. Pinning packages locally. 
3. Logging libraries 

Quite a lot of this workflow is made simpler by using the opam client. 

[opam client](../opam%20client%20af5eb8b02bdf4c17931004d79002243e.md)

## Recommended Workflow

---

### Getting the Source Code

If the library is part of the *opam-repository* then the easiest way to get the source code is using the opam client: `opam source <package>` - this can also be given an optional version constraint.

```bash
# Downloads latest version of Irmin - at time of writing 2.2.0
opam source irmin

# Download the 2.0.0 version of Irmin
opam source irmin.2.0.0
```

If you envisage wanting to make a pull request to fix something then forking and cloning the package is probably a better way to go about it.

```bash
git clone https://github.com/patricoferris/irmin.git
cd irmin
git checkout -b my-awesome-fix
```

### Locally pinning

To tell opam that you want to use a modified version of a package you **pin** it. This is like pinning a note to the package in the opam-respository that points to the source code you are developing (rather than the locally clone released version from Github). 

```bash
# In the clone irmin directory 
opam pin add irmin . --kind=path 
```

Note: it is quite common to have multiple opam packages per repository. Irmin for example has `irmin`, `irmin-unix`, `irmin-graphql`... If your changes are only for a certain package it is best to only pin that one package. `--kind=path` means we don't have to commit the changes as by default opam tries to use git pins. 

Opam will rebuild dependent projects as well - depending on what package you change and how many dependent projects you have installed in your switch this can take a bit of time.

### Subsequent Changes & Upgrading

Pinning a package tells opam where the source code is coming from but as you add new bits of code, opam doesn't see these. In order to add those you will have to run `opam upgrade` to get the latest changes of pinned packages. 

"The Joy of Dune Vendoring" linked in the resources discusses this process and the future of vendoring in OCaml.