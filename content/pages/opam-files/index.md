---
title: Opam Files 
date: 2020-07-27 09:35:49
---

Your project's opam file is the key to unlocking the power of the OCaml Platform. It will be used for much more than just publishing your library for others to use - with it for example you can:

- Automate the installation of external dependencies
- Give users points of contact - like where to submit issues
- Pin your project locally making it much easier to develop other tools and do continuous integration
- Install your project as a CLI tool

## Versioning

One of the best features of opam files is versioning. Every file begins with `opam-version`, a field indicating what version of opam your project uses.  This solves the problem that *[nvm solves with nvmrc files](https://github.com/nvm-sh/nvm#nvmrc).* It makes it easier to catch versioning mismatches quickly. 

## Example File

Below is a very minimal opam file - there tend to be two main sections to an opam file. Metadata about the package and dependency/build information. 

```
opam-version: "2.0"
version: "~dev"
synopsis: "A short sentence about your project"
maintainer: "<username> <email>"
authors: ["<username1> <email1>"]
license: "ISC"
homepage: "<github-page-or-similar>"
bug-reports: "<github-issues-page-or-similar>"
depends: [
  "ocaml"   {>= "4.07.0"}
  "dune"    {>= "2.0.0"}
  "zarith"
  "alcotest" {with-test}
]
build: [
  ["dune" "build" "-p" name "-j" jobs]
  ["dune" "runtest" "-p" name] {with-test}
]
```

### Common Opam File Parameters

- *depends*: this describes your project's dependencies with versioning constraints and [package variables](https://opam.ocaml.org/doc/Manual.html#Package-variables). For example `with-test` is a boolean variable which is set to true if tests have been enabled, if they haven't then opam will not try and installed `alcotest`.
- *build:* specifies the list of commands to run in order to build your program. The same filtering can applied here to ensure only certain commands run. When using dune there is no need to add an `install` parameter to your opam file - dune can install the package for you.
- *pin-depends: s*ome times your package will depend on unreleased versions of other packages, this mean if you spe them as dependencies in *depends* opam will not be able to find them. To handles this you can add a *pin-depends* parameter to point opam in the direction of the latest source code.

```
depends: [
  ...
  "omd"
  ...
]
pin-depends: [
  "omd.dev" "git+https://github.com/ocaml/omd"
]
```