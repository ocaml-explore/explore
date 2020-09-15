---
title: Bun
date: 2020-07-31 09:38:42
repo: https://github.com/yomimono/ocaml-bun
description: A CLI tool for helping fuzz testing commands
license: 
  MIT: []
lifecycle: 
  INCUBATE: []
---

## Overview

[Bun](https://github.com/yomimono/ocaml-bun) is a CLI tool for integrating fuzzer-based testing into a continuous integration pipeline. Some of the main problems it solves are: 

1. Fuzz tests need time to properly work and most CI tools can kill long running processes. 
2. AFL-fuzz is designed to only use one CPU, bun makes the transition to multiple CPUs easiers. 
3. Bun offers a user and CI friendly summary of what is currently happening with the different processes.

### Key Concepts

Bun is all about fuzz testing, so make sure you're [up to speed with it](/workflows/fuzz-testing-your-project). 

As a very brief synopsis, fuzz testing is about instrumenting your code to allow a fuzzer to analyse input and output from functions to cleverly detect edge cases that are more likely to break your code. This is especially useful when implementing complex functions that could take many different inputs like parsers or implementations of protocols. 


### In the Wild

[Cstruct](https://github.com/mirage/ocaml-cstruct) is a library for mapping OCaml values to C-like structs. It uses fuzz-based testing along with the [Drone](https://drone.io/) CI tool. The [fuzz](https://github.com/mirage/ocaml-cstruct/tree/master/fuzz) directory contains the relevant code.
