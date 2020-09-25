Explore OCaml 
-------------

🚧 WIP: Under Construction 🚧

Explore OCaml is a centralised source for workflows in OCaml categorised by user, tools and libraries with rich linking to external sources of information. It aims to provide all users with the recommended way to be productive in getting something done in OCaml. This could be:

 - Getting started with learning the language
 - Adding CI and unit tests to your OCaml library 
 - Generating and deploying documentation for your project
 - Installing a tool built in OCaml

## Building Locally

Explore OCaml is a both a website and a tool for building the website. To install the CLI you can clone this repository and run `opam install .` from the root. Running `explore --help` from the command line will provide more details about the tool. 

The simplest way to get started is to run `explore serve <optional-port>` from the root. This will (a) build the site and (b) start a server at `http://localhost:8000` unless you specify a port. The server rebuilds the entire website on every request (it's reasonably fast) so you can make changes to markdown files and then simply refresh the page and the changes should be there.

If you are making changes to the explore CLI or build tool, then you will need to run `dune build && dune install` to make sure it builds and updates for you. 

## Content and Tests 

The recommend way to create a new workflow is from the command-line. Once `explore` is installed you can run `explore new workflow` this will setup a small workflow wizard to guide you through adding the mandatory information for generating a new workflow. If you give the workflow a title of `Building multiple packages` it will be added under `content/workflows/building-multiple-packages/index.md`. 

This repository follows a similar structure to [Real World OCaml](https://github.com/realworldocaml/book). The workflows are stored in `content/workflows/<workflow-title>`. In this directory the `index.md` contains the workflow itself and most use `mdx` to test code blocks (OCaml and shell scripts). In the `examples` directory various projects will exists that the workflow references. If they don't have a `dune-workspace` file they will be built whenever you run `dune build`. If they do have a `dune-workspace` file then a `rule` must be added to build them during a `dune runtest` (see the "running OCaml in the browser" for an example).

Whenever you update or build a workflow, be sure to run `dune build && dune runtest` from the the root of the project. If there are changes to `index.md` files that you want, promote them with `dune promote` and then commit them. 

## A Brief Guide to Explore OCaml

What follows is a brief explanation of the build process of Explore OCaml using `lib`. This is aimed at developers wanting to change the layout of the site or fix bugs in the site generation. 

The site content is stored in the `content` folder as markdown. The markdown contains yaml front-matter for holding meta-data. The `index.md` file just inside `content` is the homepage content. Pages without a clear home, say the `opam-client` information page live in the `pages` folder. 

The process of building the site is mainly conversion from markdown to HTML handled primarily by [omd](https://github.com/ocaml/omd). Libraries, users, tools and workflows are `Collections`. There types are described in `collection.mli` and we are using `ppx_deriving_yaml` to transform yaml to these types and where needed transforming the types to yaml. 

Collections also build so-called index pages for listing all of the users or tools etc. The `(workflow, user)` relation is stored with the user file. The ordering in the markdown represents the ordering we think makes sense as a user to follow through the different workflows. 

The `components.ml` provides some basic `Tyxml` components for building pages. The `toc.ml` contains code for generating a table of contents from markdown files using the headers. It also enforces good heading-nesting practices. 

## Explore CLI Tool 

```sh
$ explore --help=plain
NAME
       explore - Explore OCaml CLI tool

SYNOPSIS
       explore COMMAND ...

COMMANDS
       build
           Build the site to static files

       lint
           Lint a collection specified by its type and path.

       new Build the scaffolding for a new collection from the command line.

       outdated
           Check all files to see which are outdated based on their last
           update timestamp.

       serve
           Run a local server which serves the contents of content. It
           rebuilds the entire site for each page load so changes made will
           be automatically synced.

       time
           Print the current time in UTC.

OPTIONS
       --help[=FMT] (default=auto)
           Show this help in format FMT. The value FMT must be one of `auto',
           `pager', `groff' or `plain'. With `auto', the format is `pager` or
           `plain' whenever the TERM env var is `dumb' or undefined.

```
