open Explore

let test_drop_first_dir () =
  let file = "content/workflows/index.md" in
  let correct = "workflows/index.md" in
  Alcotest.(check string)
    "drop first directory" correct
    (Files.drop_first_dir ~path:file)

let test_to_html () =
  let file = "a/b/c/index.md" in
  let correct = "a/b/c/index.html" in
  Alcotest.(check string)
    "change extension to html" correct (Files.to_html ~path:file)

let tests =
  [
    ("test_drop_first_dir", `Quick, test_drop_first_dir);
    ("test_to_html", `Quick, test_to_html);
  ]
