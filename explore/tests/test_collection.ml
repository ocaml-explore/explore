(* open Core *)
open Explore
module W = Collection.Workflow

let test_getters () =
  let pp_res ppf (p : W.resource) =
    Format.pp_print_string ppf
      (p.title ^ " " ^ p.description ^ " " ^ p.url ^ " ")
  in
  let equal_res = Stdlib.( = ) in
  let resource = Alcotest.testable pp_res equal_res in
  let path = "adding-unit-tests-to-your-project.md" in
  let s = Files.read_file path in
  let v = Collection.Workflow.v ~path ~content:s in
  Alcotest.(check string)
    "get title" "Adding Unit Tests to your Project" v.data.title;
  Alcotest.(check string)
    "get date non textual" "27, July 2020 at 09:35:49" v.data.date;
  Alcotest.(check string) "get description" "Add unit tests" v.data.description;
  Alcotest.(check (option (list string)))
    "same libraries"
    (Some [ "Alcotest" ])
    v.data.libraries;
  Alcotest.(check (option (list string)))
    "same tools"
    (Some [ "Dune" ])
    v.data.tools;
  Alcotest.(check (option (list resource)))
    "get resources"
    (Some
       [ { title = "OCaml"; description = "abcd"; url = "https://ocaml.org" } ])
    v.data.resources

let test_tool () =
  let path = "adding-unit-tests-to-your-project.md" in
  let wf = Collection.Workflow.v ~path ~content:(Files.read_file path) in
  let module T = Collection.Tool in
  let path = "dune.md" in
  let s = Files.read_file path in
  let v = T.v ~path ~content:s in
  let ws = T.get_workflows v [ wf ] in
  Alcotest.(check string) "same title" "Dune" v.data.title;
  Alcotest.(check string)
    "same description"
    "Dune is a build tool that has been widely adopted in the OCaml world"
    v.data.description;
  Alcotest.(check string) "same license" "MIT" v.data.license;
  Alcotest.(check (list string))
    "same workflows"
    [ "Adding Unit Tests to your Project" ]
    (List.map (fun (w : Collection.Workflow.t) -> w.data.title) ws)

let tests =
  [ ("test_getters", `Quick, test_getters); ("test_tool", `Quick, test_tool) ]
