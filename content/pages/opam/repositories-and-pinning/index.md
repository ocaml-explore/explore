---
title: Repositories and Pinning
description: Opam repositories and the pinning mechanism
date: 2020-10-05 11:00:44
---

## Repositories

Opam repositories are the source of truth for what `opam` can and cannot install. If the repostory doesn't have package `X` with an opam file, then it won't be installed. The default repository is where most people will begin and end their journey with repositories. This is where you can publish new releases of your libraries and others can update and upgrade to these versions. 

This is held on Github: [ocaml/opam-repository](https://github.com/ocaml/opam-repository)

![Opam diagram with two switches](/images/opam.v1.png)

Note in the diagram above, in the unselected switch, there are two repositories. There is no limit on the number you can have and when installing libraries `opam` will check each for a folder that matches what you are looking for. The above is an example of what you would have to do to start cross-compiling. Sometimes larger organisations might want to keep their own repository so that it doesn't update and break code, for example the [tezos repository](https://gitlab.com/tezos/opam-repository).

An important (and quite common misconception) is that the repository contains your code. It doesn't. It contains the opam file with an additional field pointing to where your code is available. For more information on this, check out the [publishing to opam](/workflows/publishing-a-new-package-on-opam) workflow.

### Updating & Upgrading

Hopefully with the explanation of repositories it is a little clearer what updating and upgrading means. When you install and opam switch you get a local, cloned copy of the opam repository. As you code this will remain unchanged even as library authors publish new releases. This is nice as it means the ground will not move from under you. 

To get the newer (and hopefully better!) code you will essentially have to `git pull` the latest opam repository using `opam update` and then tell opam to install the latests version of libraries (`opam upgrade`). Remember, unlike installing packages the priorities for upgrading focus on not removing packages (because of dependency conflicts) and trying to get to the latest version. Changing the repository is less important than during a single package install. By supplying a single package to these commands you won't update and upgrade everything. 

Within your library opam file you can specify constraints on version numbers to ensure your code works correctly. A major version change say `irmin.1.0.0` to `irmin.2.0.0` would likely break your code. As explained in the [publishing workflow](/workflows/publishing-a-new-package-on-opam), opam has a serious of continuous integration checks to make sure reverse dependencies do not break code. If it does then you either need to constrain the dependency or change your code to build with the latest version of the dependency. 

## Pinning

Pinning is a method for overriding the opam repository. In the diagram at the top of the page, our repository has a version of `alcotest` at `1.1.0` - under normal circumstances this is what will be installed and used to build libraries that depend on it. 

But say we want to add a new feature or fix some code in `alcotest` and then try building some libraries that use it, do we have to release a new version or manually change the opam repository? No. You can run `opam pin add alcotest . --kind=path` from within the `alcotest` library. Opam will dutifully recompile reverse dependencies for you.

It is important to know that opam is git-based when it comes to source code hence the need to specify `--kind=path` otherwise it will try and use the latest commit and you don't want to commit every time you want to try to change something.