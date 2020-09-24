---
authors:
  - Patrick Ferris
title: Publishing a Package on Opam
date: 2020-07-27 09:35:49
description: Share your libraries or applications with the community
topic: 
  publishing: 
    - true
users:
  - Library Authors
  - Application Developer
tools:
  - Dune-release
  - opam-publish
  - Dune
---

## Overview

*Some prerequisites -- there are lots of ways to publish packages. This workflow will be using the git version control system along with a workflow for dune users and a workflow for non-dune users.*

Part of the appeal of open-source software is the ability to share the code with other users. This could be as a library, a command-line tool for an end user or something completely different. Ultimately the code needs to be put somewhere and a central source of where to find it needs to be updated. This workflow focuses on using [opam](/pages/opam) to do just that. 

Opam is a package manager for OCaml. If you are reading this workflow then chances are you have interacted with the [opam-client](/pages/opam-client) probably to install packages like [dune](/platform/dune) or [OCamlFormat](/platform/ocamlformat). If you are looking to publish your code then you should also have [an opam file](/workflows/starting-a-new-project#generating-an-opam-file) for your project.

### Opam Internals

Before diving into the tools for publishing your code, it is important to understand how the opam ecosystem works. One of the key concepts to understand is the idea of an [opam repository](/pages/opam-client#repositories). This is a structured collection of opam files indicating where to find different versions of packages and how to build and install them. The main repository can be [found on Github](https://github.com/ocaml/opam-repository) and here is an example of a package: [ocamlformat.0.15.0](https://github.com/ocaml/opam-repository/blob/master/packages/ocamlformat/ocamlformat.0.15.0/opam).

In order to publish to the opam repository you need to tag your project - this means adding a **tag** to indicate that a particular commit represents your piece of software at a particular version. The OCaml community strive to use [semantic versioning](https://semver.org/).

![A diagram showing a git tree with the latest main branch commit tagged](/images/git-tag.png)

Tagging is used in order to create a *release* of your package. A release is an [archive](https://en.wikipedia.org/wiki/Tar_(computing)) of the source code. The most common place to do this is on [Github](https://github.blog/2013-07-02-release-your-software/). You specify where a package is released to in the `url` field of the opam-repository opam files (not in the source code version as they change because of the checksum that is also added).

How you tag, produce the archive, generate the slightly different opam file and create a pull-request to the opam-repository differs depending on the tool you use. Skip ahead to [the dune-release workflow](#for-dune-users) or the [opam-publish workflow](#for-everyone-else) if you don't want some information on the continuous integration opam offers.

### Opam Continuous Integration 

Whenever you make a pull-request to add your latest package information to the central opam repository a series of continuous integration tools are run to check your code build, installs and how it impacts reverse dependencies (those tools that depend on your package). [TravisCI](https://travis-ci.com/) is used to check if your new release will install on a variety of platforms including MacOS and FreeBSD. [Camelus](https://github.com/ocaml-opam/Camelus) reports on a variety of problems to help ease the burden on maintainers like linting the file and checking what new packages have become available (or not) as a result of the PR. 

Finally, a tool called [DataKit-CI](https://github.com/moby/datakit/tree/master/ci) does the heavy lifting and checks more platforms and the reverse dependencies. For those interested, there is a new CI tool based on [ocurrent](https://github.com/ocurrent/ocurrent) pipelines [coming soon](https://www.youtube.com/watch?v=HjcCUZ9i-ug).

## Recommended Workflow

### For Dune Users 

[Dune-release](/platform/dune-release) is a the recommended tool for people using dune and opam. Provided you follow some conventions, most of the hard work is taken care of by `dune-release`. To install it, simply run `opam install dune-release`. 

A good first step is to run `dune-release lint` at the root of your project. This will check for the conventions that dune-release is expecting and report back on any errors. 

```sh non-deterministic=output,dir=examples/project
$ dune build
$ dune-release lint 
[ OK ] File README is present.
[FAIL] File LICENSE is missing.
[FAIL] File CHANGES is missing.
[ OK ] File opam is present.
[ OK ] lint opam file lib.opam.
[ OK ] opam field description is present
[ OK ] opam fields homepage and dev-repo can be parsed by dune-release
[ OK ] Skipping doc field linting, no doc field found
```

One of the more important documents is the `CHANGES` file. This specifies what parts of codebase have changed (new functionality, bug fixes etc.) since the last version. Not only is this important for users of your package, the `dune-release` tool can use it to automatically tag the latest commit with the correct version. The [Irmin CHANGES](https://github.com/mirage/irmin/blob/master/CHANGES.md#220-2020-06-26) file is a good example. 

Licensing your software is also important. The [open source initiative](https://opensource.org/licenses) details their approved list. Another fairly common license is [ISC](https://en.wikipedia.org/wiki/ISC_license).

### For Everyone Else 
