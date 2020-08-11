---
title: About
description: More information about Explore OCaml, why it exists and who it is for
date: 2020-08-11 17:08:58
---

## What Explore OCaml aims to achieve

One of the biggest problems programming languages face in a real world setting is that getting started with them isn't necessarily easy. OCaml is no exception. There tend to be lots of great resources explaining interesting aspects of the language like GADTs or the module system - but not as many centred around productivity workflows i.e. getting things done in OCaml. 

Often these workflows are obvious... once you know them. Explore OCaml is a centralised source for workflows in OCaml categorised by user, tools and libraries with rich linking to external sources of information.

Here are some of the common problems users face: 

1. I'm running the `ABC` operating system, how do I get started with OCaml? (In particular the Windows experience).
2. I want to build a library that does `X`, what is the best workflow* for achieving this?
3. I just want to run some *Hello-World* examples and get started with OCaml - how do I do this? (similar to 1)
4. I've noticed a bug in library `Y` - how do I fix it and contribute to the original library?
5. OCaml seems to have many backends - *x86, ARM, RISC-V, JavaScript* - but how do I use them?
6. There is a cool tool written in OCaml - how do I install and use it? 
7. I'm running on OS `ABC` but want to compile for `XYZ` - can I do that in OCaml?

**workflow: this involves testing, publishing, formatting, building etc. all of the common tooling that needs to be in place to allow most programming languages to solve real world problems.*

This site aims to answer these questions for you, as well as let you discover more advanced workflows as your use of OCaml grows. First, we'll introduce the only essential tool you need — opam.

## How it achieves it 

Explore OCaml is an open-source collection of workflows and user-generated content for being productive in the OCaml language. It relies on the community to help keep workflows up to date.

With that being said it employs [dune](/platform/dune) and [mdx](/platform/mdx) to run the example repositories and code snippets every time the site rebuilds, adding a defensive layer against [bitrot](https://en.wikipedia.org/wiki/Software_rot).

## Who can contribute 

The site is open-sourced on [github](https://github.com/ocaml-explore/explore)!