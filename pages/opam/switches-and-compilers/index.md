---
title: Switches and Compilers
description: Compilers and switches in opam
date: 2020-10-05 11:00:44
---

## Switches 

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

## Inside the .opam directory

You should never have to touch the `~/.opam` directory. The only interactions with it should be through the `opam` client. But it is also useful to understand what is going on inside it to give you a better mental model of how opam works. 

With a brand new `4.11` global switch the `~/.opam` directory looks something like this with some less important files and directories removed.  

```
|-- 4.11
|-- download-cache
|-- plugins
`-- repo
```

The `4.11` directory is for our switch, `plugins` stores the global [opam plugins](/pages/opam/plugins) and `repo` holds the [opam reposiory information](/pages/opam/repositories-and-pinning). The `download-cache` is exactly that. 

The `4.11` directory contains the installed executables (`~/.opam/4.11/bin`) and the installed libraries (`~/.opam/4.11/lib`) as well as manual pages, documentation and shared packages. 

Without anything installed besides the compiler, the `bin` directory has the OCaml compiler executables such as `ocamlopt` and `ocamlc`. Note our `PATH` variable contains `~/.opam/4.11/bin` hence we can run these commands from the command line.

### Installing Libraries

If we install `yaml` (`opam install yaml -y`) we will pull many more libraries into `lib` including `yaml`. In `~/.opam/4.11/lib/yaml` you will see both the source of [ocaml-yaml](https://github.com/avsm/ocaml-yaml) as well as the build artifacts. Upon installing a library, opam uses the build information stored in the opam file to also build the library. Whenever you build your own projects with `dune build`, and if they need `yaml`, this is where dune will get it from.

Much of this information remains unchanged for the **local** switches except the information now lives in the same directory as your project in `_opam`. 

## Compilers 

The [source code](https://github.com/ocaml/ocaml) for the OCaml compiler is hosted on Github. The OCaml compiler can produce assembly code or bytecode that can be interpreted. Importantly there are three distinct "types" of compiler whenever you use opam to install them: 

 - System compiler: `ocaml-system` is the [compiler installed](https://opam.ocaml.org/packages/ocaml-system/) by your distribution package manager (`brew`, `apt-get` ...), that is, it exists outside of opam.
 - Base compiler: `ocaml-base-compiler` is the [official release](https://opam.ocaml.org/packages/ocaml-base-compiler/) of the OCaml compiler i.e. the `4.11.1` or `4.08.0` compilers.
 - Variants: These compilers are different configured versions of the base compiler. They could contain extra compiler features (e.g. [4.11+flambda](https://opam.ocaml.org/packages/ocaml-variants/ocaml-variants.4.11.1+flambda/)) and/or be compiled differently (e.g. [4.11+musl+static+flambda](https://opam.ocaml.org/packages/ocaml-variants/ocaml-variants.4.11.1+musl+static+flambda/))

 If your package depends on having the `4.11.1` OCaml compiler then usually having the `4.11.1` system compiler, base compiler or some variant of `4.11.1` is enough. To ask for this, you can use the [ocaml virtual package](https://github.com/ocaml/opam-repository/blob/master/packages/ocaml/ocaml.4.11.1/opam).
