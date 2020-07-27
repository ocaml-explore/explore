---
title: OCaml Platform
date: 2020-07-27 09:35:49
---

[https://www.youtube.com/watch?v=oyeKLAYPmQQ](https://www.youtube.com/watch?v=oyeKLAYPmQQ)

---

### Summary in a Q&A Format

**User Concerns:**

- What is the OCaml Platform?
    - It is an idea of an ecosystem of tools that work well together along with the OCaml compiler to make it easy, fast and powerful to build projects in OCaml.
    - The OCaml Platform brings together the essential tooling for building projects to provide:
        - Unified licensing and contribution guides
        - Full CI for ***many OSes and CPU Archs.*** - this is crucial in ensuring *anybody* can get up and running with building things in OCaml.
- Why use the `opam` tool for publishing libraries?
    - Without some form of package manager the barrier to entry is high for programmers to get started building projects. How would you  easily share, update and release libraries? How would you managed dependencies and constraints? How can you quickly test new versions of a library with your changes?
    - OCaml is statically-typed - this provides some great safety properties of your code. The simplest is making sure you know what your functions expect and return.
        - Simple JS vs OCaml Example

            ```jsx
            function addOne(x) {
            	return x + 1;
            }

            addOne("1") // returns the string "11"
            ```

            Whereas in OCaml: 

            ```ocaml
            let addOne x = x + 1 

            addOne "1" 
            (* Error: 
               This expression has type string but an 
               expression was expected of type int *)
            ```

        - Static-typing and Library Dependencies

            With this static-typing comes a cost for recompiling a library. Libraries can depend on each other, and they also depend on certain function having certain types, or even certain types being defined in a specific way. In the next example `Library Y` depends on `Library X` for the `camel` type. 

            ```ocaml
            (* Library X *) 
            type camel = Bactrian of int 

            (* Library Y *)
            let print_humps = function 
              | Bactrian x -> print_int x 
            ```

            What happens if you update your `Library X` to the following: 

            ```ocaml
            type camel - Bactrian of int | Dromedary of int 
            ```

            Now `Library Y` has a non-exhaustive pattern-match. This is probably the simplest example but it illustrates how recompilation is trickier with OCaml and why a *smart* package manager is important. 

    - Opam comes with a fast, built-in constraint solver to make sure your project and its dependencies can all be met and compiler correctly. It also has great sandboxing features - source code is downloaded and built on your machine securely.
- Why use `dune` for building OCaml code?
    - Build tools are prolific (and also infamous) in any programming language - they solve the problem of taking a project and producing some executable or library.
    - Dune is built to (a) scale well for large projects with lots of dependencies and (b) be usable for small libraries or even compiling "hello-world" examples.
    - **Compositional Builds:** `dune` file per directory to define the shape of the build, one `dune build` command to build everything. Or step down to a single directory to build just that code.
- How does it support legacy code and not get bogged down in the process?
    - Versioning is also an infamous problem in programming and building projects. How do you alleviate the painful experience of something not working just because you have the wrong version of tool `X` installed.
    - In the metadata itself versions are recorded of the tools required to build projects. This allows the tools to give accurate error messages if a tool fails to do its job properly.
- How has `opam` changed the OCaml compiler?
    - By introducing a publishing and package management tool, the OCaml compiler no longer needs to provide lots of libraries and utilities out-of-the-box. Instead, these have slowly left the compiler making it more lightweight.
- How does the OCaml Platform interact with different OS Package Managers?
    - Where possible with the metadata files of `dune` and `opam` the goal is to make the CI/CD surrounding this as simple as possible.
- What can be expected from OCaml Platform releases?
    - Long term support for *important* versions of the OCaml compiler (for example those used by Bucklescript)
    - Precompiled tools to make getting started as quick as possible (similar to `go get`).
    - The *monorepo* approach provides better visibility into how changes in a single platform tools impacts others.

---

**Technical Details** 

- What is **the duniverse and why is it useful?**
    - TL;DR - it is a clever *monorepo* generator removing the need to use `opam` for those that don't need it. Also allows devs to have *distributed development*.
    - Currently all of the platform tools exist as independent git repositories e.g. [https://github.com/ocaml/opam](https://github.com/ocaml/opam) which are then published under some version to the `opam` repository.
    - Duniverse bridges `opam` and `dune` - it allows you to make a local copy of the all the source code needed in order to build it with `dune` - this is done from the `opam` metadata file.
    - What this does is alleviate the need to have `opam` for those users that do not need it.
- How does it fit in with **the platform?**
    - The end goal of the platform is simple: provide a standalone, versioned monorepo that bootstraps cleanly from a C compiler for all supported OS distributions.
    - Less *technical translation*:
        - Getting started with OCaml and the tools that allow you to build better, safer projects should be simple.
        - Currently this is not the case.
        - The root through `opam` is a scary and winding path with lots of little gotchas.
        - With the Platform this should be hidden from the end-user but also meticulously CI/CD (tested and deployed) to provide OCaml users the best experience possible not matter what they are trying to run OCaml on.