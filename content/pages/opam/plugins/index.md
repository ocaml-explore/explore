---
title: Plugins
description: Community authored tools that extends the functionality of opam
date: 2020-10-05 13:33:31
---

Opam plugins are tools which extend opam's functionality. They are automatically installed if you do not have them, but because they are not part of the opam source code, they are free to move at quicker pace of development rather than waiting on a new release of opam. To a user, they appear like normal opam commands such as `opam install` or `opam list`. 

To tell if a project is an opam plugin you need to look in the opam file itself for the `plugin` [flag](https://github.com/ocaml/opam-repository/blob/master/packages/opam-compiler/opam-compiler.0.1.1/opam#L35). Opam plugins are also called `opam-<plugin-name>` and can then be run (and installed) with `opam <plugin-name>`. 

## Opam Compiler 

The [Opam compiler](https://github.com/ocaml-opam/opam-compiler) plugin extends the functionality of the usual way to create compilers in opam with `opam switch create`. With this plugin you can test OCaml compiler pull requests just by referencing the PR number: 

```
$ opam compiler create '#1234'
```

This makes it more straightforward to test PRs on the OCaml compiler rather than having to clone the repository yourself. The README also explains how you can use this to do the same thing for your own branches.

## Opam Tools 

Currently unreleased, opam tools lets you build local switches for a given package which feels similar to the treatment of modules in the node ecosystem. The default list of tools installed is essentially the OCaml Platform. [See the source code](https://github.com/avsm/opam-tools/blob/master/opam_tools.ml#L38) for the list.
