---
title: Switches and Compilers
description: Compilers and switches in opam
date: 2020-10-05 11:00:44
---

In the official documentation switches are described as (`opam switch --help`): 

> This command is used to manage "switches", which are independent
installation prefixes with their own compiler and sets of installed and
pinned packages. This is typically useful to have different versions of
the compiler available at once.

![opam client diagram](/images/opam.v1.png)

A switch is a set of installed packages with some compiler version or variant. All of the installed packages will have been built with that compiler so you can be sure that this won't be a problem. The diagram shows two switches, for now unless you have read the [repositories](/pages/opam/repositories-and-pinning) page, you can ignore the *Default Repository* part. Each switch has a compiler associated with it (`4.10.0` and `4.11.0+cross-riscv`). 

Switches can either be local or system-wide. The former is usually installed alongside your code in an `_opam` directory whilst the latter exists in `~/.opam`. Local switches can be treated like *node_modules* in the NodeJS ecosystem. See the [opam-tools plugin](/pages/opam/plugins) for more about this.

Switches can be created with: 

```sh
# System switches 
$ opam switch create 4.11.0
# Local switches 
$ opam switch create . 4.11.0
```

One common question is why does opam tell me `You should run: eval $(opam env)`? This sets up the correct environment for opam. For example, it ensures the correct bin folder is stored in your `PATH` variable on MacOS and Linux. That way when you try to run and installed executable the correct one is selected from the current switch. Likewise, this becomes part of dune's installed world and so dune can find external dependencies from this.  

