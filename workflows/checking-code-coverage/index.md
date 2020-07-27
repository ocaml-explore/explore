---
authors:
  - Patrick Ferris
title: Checking Code Coverage
date: 2020-07-27 09:35:49
users:
  - Library Authors
  - Application Developers
tools:
  - Dune
libraries:
  - Alcotest
  - Bisect-ppx
---

## Overview

---

Code coverage can be a good indicator into how well your code does what it is supposed to do. Of course, the goal is not to blindly chase 100% coverage, but to use the output to help you write correct and maintainable code. 

## Recommended Workflow

---

Setting up code coverage requires changes to your `dune` file for the libraries you want to cover. You will also need to update your opam file to depend on `ppx_bisect`. The opam file will add `bisec_ppx` as a dependency: 

```
depends: [
	...
  "bisect_ppx" {dev & >= "2.0.0"}
] 
```

And in the a library we want to cover, say a library called `numberz` we need to add a preprocessor. 

```
(library
 (name numberz)
 (public_name numberz)
 (preprocess (pps bisect_ppx --conditional)))
```

To run the tests with bisect enabled and to get the summary of the coverage you can run: 

```bash
# This will produce the bisect results 
BISECT_ENABLE=yes dune runtest --force

# Tells you in the terminal 
bisect-ppx-report summary

# Produces coverage in _coverage directory
bisect-ppx-report html
```

## Real World Examples

---

[arenadotio/ocaml-mssql](https://github.com/arenadotio/ocaml-mssql)