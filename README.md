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

## A Workflow for Workflows 

The recommend way to create a new workflow is from the command-line. Once `explore` is installed you can run `explore new workflow` this will setup a small workflow wizard to guide you through adding the mandatory information for generating a new workflow. If you give the workflow a title of `Building multiple packages` it will be added under `content/workflows/building-multiple-packages/index.md`. 

We use [mdx](https://github.com/realworldocaml/mdx) to keep our content maintained and synchronised, the recommended way of doing this is to add a `dune` file and a `prelude.ml` file to a workflow and then any larger examples in an `examples` directory. The "Adding Unit Tests" workflow exemplifies this and can be used as guidance for how to set it up. Running `dune runtest` will run mdx and check all of the examples. 

## A Brief Guide to Explore OCaml

What follows is a brief explanation of the build process of Explore OCaml using `lib`. This is aimed at developers wanting to change the layout of the site or fix bugs in the site generation. 

The site content is stored in the `content` folder as markdown. The markdown contains yaml front-matter for holding meta-data. The `index.md` file just inside `content` is the homepage content. Pages without a clear home, say the `opam-client` information page live in the `pages` folder. 

The process of building the site is mainly conversion from markdown to HTML handled primarily by [omd](https://github.com/ocaml/omd). Libraries, users, tools and workflows are `Collections`. There types are described in `collection.mli` and we are using `ppx_deriving_yaml` to transform yaml to these types and where needed transforming the types to yaml. 

Collections also build so-called index pages for listing all of the users or tools etc. The `(workflow, user)` relation is stored with the user file. The ordering in the markdown represents the ordering we think makes sense as a user to follow through the different workflows. 

The `components.ml` provides some basic `Tyxml` components for building pages. The `toc.ml` contains code for generating a table of contents from markdown files using the headers. It also enforces good heading-nesting practices. 