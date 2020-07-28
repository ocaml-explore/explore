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
 (name explore)
 (synopsis "Explore OCaml Sources")
 (description "Build tool, scripts and content for the Explore OCaml site")
 (depends
  (alcotest :with-test)
  (ocaml
   (and
    (>= 4.10.0)
    (< 4.11.0)))
  core
  tyxml
  omd
  yaml
  tyxml-ppx
  ppx_jane
  ezjsonm
  jekyll-format
  re))
