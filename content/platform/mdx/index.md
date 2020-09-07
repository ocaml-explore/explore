---
title: Mdx
date: 2020-07-27 09:35:49
description: Executable code blocks in your markdown
repo: https://github.com/realworldocaml/mdx
license: ISC
---

## Overview

[Mdx](https://github.com/realworldocaml/mdx) is a tool for executing code blocks inside of markdown. It can be used to improve documentation workflows and write tests. Documentation struggles from becoming out-dated fairly quickly or just being incorrect given it is usually typed by a programmer into something like markdown.  

## Key Concepts

### Dune Integration

[Mdx](https://dune.readthedocs.io/en/stable/dune-files.html#mdx-since-2-4) plays nicely (although still somewhat experimentally with dune). Mdx stanzas can specify the core parts to getting Mdx working with a library: 

- `files` - specify which files mdx should check for you
- `packages` - detail the dependencies your code blocks have
- `preludes` - files to run before anything else, useful for automatically opening packages like `Core`

## In the Wild

The excellent book for learning OCaml, [Real World OCaml,](https://github.com/realworldocaml/book) uses mdx extensively to automate their book and ensure the code snippets included within it are correct. Code is written in an *examples* directory and mdx keeps the examples and embedded code blocks in the content of the book synchronised.
