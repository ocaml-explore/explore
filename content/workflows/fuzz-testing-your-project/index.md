---
authors:
  - Patrick Ferris
title: Fuzz Testing your Project
date: 2020-07-27 09:35:49
description: Make fuzz tests to find uncover hard to find bugs in your code
users:
  - Library Authors
  - Application Developers 
tools:
  - Bun 
---

## Overview

Fuzz testing (or fuzzing) is a way to find test cases that break your code programmatically using instrumented binaries. This can extremely useful for complex parsers or protocols which are expected to cope with a large variety of inputs.

## Recommended Workflow

To get started with fuzzing your project you will need to do the following: 

1. Install AFL on your machine 
2. Install an AFL variant of the OCaml compiler into a new switch
3. Install crowbar and bun using opam 

This Github repository and the accompanying article found in the resource tag are a great place to start. 

[NathanReb/ocaml-afl-examples](https://github.com/NathanReb/ocaml-afl-examples)

## Real World Examples
