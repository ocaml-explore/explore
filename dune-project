(lang dune 2.6)

(name explore)

(using mdx 0.1)

(formatting disabled)

(generate_opam_files true)

(source
 (github patricoferris/explore))

(license ISC)

(authors "Patrick Ferris")

(maintainers "pf341@patricoferris.com")

(package
 (name explore-cli)
 (synopsis "Explore OCaml Sources")
 (description "Build tool, scripts and content for the Explore OCaml site")
 (depends core httpaf httpaf-lwt-unix fmt ptime calendar))

(package
 (name explore)
 (synopsis "Explore OCaml Sources")
 (description "Build tool, scripts and content for the Explore OCaml site")
 (depends
  (alcotest :with-test)
  (ocaml
   (= 4.11.0))
  core
  (dune-release
   (= 1.4.0))
  bechamel
  tyxml
  omd
  yaml
  memtrace
  tyxml-ppx
  mdx
  owl
  owl-plplot
  ppx_jane
  ezjsonm
  js_of_ocaml-ppx
  js_of_ocaml-lwt
  lwt_ppx
  js_of_ocaml-compiler
  jekyll-format
  re
  ppx_deriving_yaml
  ppx_deriving_yojson))
