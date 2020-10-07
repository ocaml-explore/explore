---
title: Package Managers
description: Understanding the job opam solves
date: 2020-10-05 11:00:44
---

Managing packages requires dealing with the two non-trivial problems: solving dependency constraints and the actual installation of packages. Here will explore how opam does this and discover why we even need opam or whatever package manager you are using.

## Solving Constraints 

When installing a package, the user has specified dependencies with additional meta-data about the exact version of the dependency and when it is needed. This is most commonly done in the [opam file](/pages/opam/opam-files). 

Let's look at a simple example in OCaml to understand the problem better: 

```ocaml
# let dep_a_package_x v = v < 10
val dep_a_package_x : int -> bool = <fun>
# let dep_a_package_y v = v > 6  
val dep_a_package_y : int -> bool = <fun>
# let sat v = dep_a_package_x v && dep_a_package_y v
val sat : int -> bool = <fun>
# sat 11
- : bool = false
# sat 9
- : bool = true
```

We are trying to install packages `x` and `y` which both depend on `a` but with different version constraints. The job of the solver is to find the right `v` to make `sat` true. 

This is a greatly simplified example and in general the problem is more complex and only gets worse as the number of packages and dependencies increases. In addition to this as you can see from the example, there are multiple solutions (`6,7,8,9` would all work). Which is the best? It is not just "install the most recent" (i.e. `9`) because what if this forces an already installed package to be removed because it needs versions `>= 10`?

Opam has a set of criteria that can be specified to set installation and upgrading preferences. The defaults are: 

 - Installing: `-removed,-changed,-notuptodate` i.e. *minimise the number of packages that would have to be removed, minimise the amount of changes made to the system, minimise the number of packages not at the most recent version* in that order.
 - Upgrading: `-removed,-notuptodate,-changes` things are different during an upgrade because you actually want to try and get to the most recent version not caring if you have to rebuild many packages but also not wanting to remove everything just to update a single package that is heavily depended on (for example).

In the general case, constraint satisfaction is NP-complete and the heavy-lifting is done by [external solvers](https://opam.ocaml.org/doc/External_solvers.html). Since version `2.0.0` opam comes with built-in [CUDF](https://www.mancoosi.org/cudf/) solver.

## Installation 

After deciding what packages (and version) satisfies the right criteria, the next step is to actually install the packages. Opam installs packages from source, that means it downloads the source code and using information stored in the opam file it builds the package. This is treated in more detail in the [switches and compiler](/pages/opam/switches-and-compilers) page.  
