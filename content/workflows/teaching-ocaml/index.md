---
authors:
  - Patrick Ferris
title: Teaching OCaml
date: 2020-09-21 10:21:03
description: Teach OCaml using Jupyter notebooks or online resources
topic: 
  starter: 
    - true
users:
  - Teacher
  - Beginner 
resources: 
  - url: https://kcsrk.info/ocaml/prolog/jupyter/notebooks/2020/01/19/OCaml-Prolog-Jupyter/
    title: KC's Paradigms of Programming Languages
    description: KC explains his setup for using Jupyter notebooks to teach a course on paradigms of programming languages using OCaml and Prolog. 
---

## Overview

There are lots of reasons to teach OCaml (it's a great language, it is multi-paradigm, it's great for introducing more theoretical aspects of programming languages) and there are lots of ways to teach it. Before jumping into more complex solutions, two resources currently available may be all you need. OCamlpro's [try ocaml](https://try.ocamlpro.com/) is a great way to introduce people to things like syntax or modules. The OCaml Software Foundation's [learn-ocaml](http://ocaml.hackojo.org/) is a much more complex platform for building essentially a course on OCaml. 

The solution this workflow describes using Jupyter notebooks which combines an interactive read-evaluate-print-loop (REPL) with markdown text (with support for LATEX) to offer a unique solution for people wanting to teach or explore OCaml. This is based largely on [KC Sivaramakrishnan's experiences](https://kcsrk.info/ocaml/prolog/jupyter/notebooks/2020/01/19/OCaml-Prolog-Jupyter/) when teaching a paradigms of programming languages course. 

## Recommended Workflow

### Locally Running an OCaml Jupyter Notebook

The best way to get *ocaml-juptyer* up and running is through `opam` and installing `jupyter` using `pip` the python package manager. More information on python and `pip` can be found in their [documentation](https://docs.python.org/3/installing/index.html).

With `pip` and `opam` installed, the following should represent a typical way of getting started with a jupyter notebook with an OCaml kernel.

```bash
$ pip install jupyter # Install jupyter
$ opam install jupyter # Install jupyter opam package 
$ opam install jupyter-archimedes  # Jupyter-friendly 2D plotting library
$ ocaml-jupyter-opam-genspec
$ jupyter kernelspec install [ --user ] --name ocaml-jupyter "$(opam var share)/jupyter"
```

Further documentation can be found at in the [OCaml Jupyter repository](https://github.com/akabe/ocaml-jupyter). 

### Using Docker 

Docker is a tool for running containers, isolated, light-weight environments for running code in a reproducible and uniform manner with great support on MacOS and Linux. This can provide a nice way to abstract the nitty-gritty details of setting up an OCaml environment for many students. 

[OCaml-teaching](https://github.com/patricoferris/ocaml-teaching) is a solution building on [KC's docker images](https://github.com/kayceesrk/cs3100_f19/blob/gh-pages/_docker/dockerfile). It offers an environment with preconfigured editors (vim and emacs), preinstalled Jupyter notebook and opam installed. The repository also contains an example of using [nbgrader](https://nbgrader.readthedocs.io/en/stable/) to provide an environment for writing assignments and auto-grading them.

To try this out for yourself, with Docker installed, you can run: 

```
$ docker run -it -p 8888:8888 -v=$(pwd):/notebooks patricoferris/ocaml-teaching:4.10 
```

Then navigate to `https://localhost:8888` to explore OCaml in a Jupyter notebook that persists to the current directory.

### Presentation tools

For teachers or presenters you can use the [RISE](https://rise.readthedocs.io/en/stable/) tool to present your code and text in the browser from a running OCaml Jupyter Notebook. It will generate interactive slides from the code and text blocks in your notebook. OCaml-teaching comes with this preconfigured. 
