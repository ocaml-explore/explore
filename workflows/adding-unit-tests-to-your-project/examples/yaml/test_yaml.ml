[@@@part "0"]

let yaml = Alcotest.testable Yaml.pp Yaml.equal

let pp_error ppf (`Msg x) = Format.pp_print_string ppf x

let error = Alcotest.testable pp_error ( = )

[@@@part "1"]

let test_of_string () =
  let open Yaml in
  let ok_str = "author: Alice\ntags:\n  - 1\n  - 2\n" in
  let err_str = "tags:  - 1\n  - 2\n" in
  let ok_correct =
    Ok
      (`O
        [ ("author", `String "Alice"); ("tags", `A [ `Float 1.; `Float 2. ]) ])
  in
  let err_correct =
    Error
      (`Msg
        "error calling parser: block sequence entries are not allowed in this \
         context character 0 position 0 returned: 0")
  in
  Alcotest.(check (result yaml error)) "same yaml" ok_correct (of_string ok_str);
  Alcotest.(check (result yaml error))
    "same err" err_correct (of_string err_str)

[@@@part "2"]

let tests = [ ("test_of_string", `Quick, test_of_string) ]
