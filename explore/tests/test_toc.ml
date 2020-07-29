open Explore.Toc

let test_toc () =
  let toc_testable = Alcotest.testable pp equal in
  let s = Omd.of_string "# Top\n## Second\n### Third\n" in
  let correct = [ H (1, "Top"); H (2, "Second"); H (3, "Third") ] in
  Alcotest.(check toc_testable) "same toc" correct (toc s)

let test_transform () =
  let pp ppf b = Format.pp_print_string ppf (Omd.to_html b) in
  let omd = Alcotest.testable pp Stdlib.( = ) in
  let s = Omd.of_string "# OCaml is great\nSome other text after" in
  let correct =
    Omd.of_string "# OCaml is great {#ocaml-is-great}\nSome other text after"
  in
  Alcotest.check omd "same omd ast" correct (transform s)

let test_tree () =
  let tree = Alcotest.testable pre Stdlib.( = ) in
  let lst = [ H (1, "a"); H (2, "b"); H (3, "c"); H (2, "d") ] in
  let t = to_tree lst in
  let correct =
    Br
      ( H (0, ""),
        [
          Br
            ( H (1, "a"),
              [ Br (H (2, "b"), [ Br (H (3, "c"), []) ]); Br (H (2, "d"), []) ]
            );
        ] )
  in
  Alcotest.check tree "same heading tree" correct t

let tests =
  [
    ("test_toc", `Quick, test_toc);
    ("test_transform", `Quick, test_transform);
    ("test_tree", `Quick, test_tree);
  ]
