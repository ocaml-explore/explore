---
authors:
  - Patrick Ferris
title: Setting up Continuous Integration
date: 2020-07-27 09:35:49
description: Add CI to your project using Github Actions 
topic: 
  testing: 
    - true
users:
  - Library Authors
  - Application Developer
tools:
  - Mdx
  - Bun
---

## Overview

Continuous integration (CI) has become a basic necessity for managing projects, especially when there are multiple contributors. The idea is that for code to make it into production (or to get a "seal of approval" to move to the main branch) - code should pass a series of quality tests. 

These tests may include: 

1. Unit tests - a series of small, functional tests to make sure implementations still do what they are supposed to. 
2. Integration tests - ensuring multiple components within your project play nicely together 
3. Formatting - although it may seem pedantic, well-formatted code (with uniformity) across the project makes it (a) easier for people to find bugs and (b) more accessible to new contributors. 

The point of CI is to automate most of this away. Wherever your project lives it should constantly be checking that new code meets the quality tests before allowing that code to make into "production". 

## Recommended Workflow

Github offers a feature called Github Actions. It works on the principle of *workflows -* different things you might want to do on different "actions" within your Github repository. This can include releasing code, testing code etc. Here we're focusing on testing. 

To get started you will need to create a `.github` directory in your repostory and inside it a `workflows` repository. Now you can specify what you want to happen by creating a `config.yml` file. 

One of the biggest advantages of Github Actions is the modularity and "action reuse". For example if you needed to use "curl" to get some resource from the internet or trigger some event at an endpoint [there's an action for that](https://github.com/marketplace/actions/github-action-for-curl).

So what does a basic OCaml config file for making quality tests look like?

```yaml
name: ospike
on: [push]
jobs:
  run:
    name: tests
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest]
        ocaml-version: ["4.07.0"]
    steps:
      - name: Checkout code
        uses: actions/checkout@master
      - name: Use OCaml ${{ matrix.ocaml-version }}
        uses: avsm/setup-ocaml@v1.0
        with:
          ocaml-version: ${{ matrix.ocaml-version }}
      - run: opam pin add ospike.dev -n .
      - run: opam depext -yt ospike
      - name: Install Deps
        run: opam install -t . --deps-only
      - name: Build
        run: opam exec -- dune build
      - name: Test
        run: opam exec -- dune runtest
```

## Alternatives

TravisCI is a continuous integration tool that is very flexible and also robust. There are two main ways you can use TravisCI.

`ocaml-ci-scripts` is a collection of useful scripts for building a complex CI testing platform. One of the main goals of CI is to make sure your code runs well *everywhere.* This implies forming a matrix of operating systems and OCaml compiler versions to make sure your code runs properly. 

There are quite few scripts such as `.travis.opam.sh` ,  `.travis.docker.sh` and even `.travis.mirage.sh`

Each is built around environment variables in order to execute different jobs with say different linux distributions, ocaml versions etc. 

## Real World Examples

[avsm/ocaml-yaml](https://github.com/avsm/ocaml-yaml/blob/master/.github/workflows/test.yml)
