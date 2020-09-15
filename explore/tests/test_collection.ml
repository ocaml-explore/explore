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
  match Collection.Workflow.v ~path ~content:s with
  | Ok v ->
      Alcotest.(check string)
        "get title" "Adding Unit Tests to your Project" v.data.title;
      Alcotest.(check string)
        "get date non textual" "27, July 2020 at 09:35:49" v.data.date;
      Alcotest.(check string)
        "get description" "Add unit tests" v.data.description;
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
           [
             {
               title = "OCaml";
               description = "abcd";
               url = "https://ocaml.org";
             };
           ])
        v.data.resources
  | Error (`MalformedCollection e) -> failwith e

let handle_error = function
  | Ok _ -> ()
  | Error (`MalformedCollection e) -> failwith e

let license : Collection.license Alcotest.testable =
  Alcotest.testable
    (fun ppf -> function `MIT -> Fmt.string ppf "MIT"
      | `ISC -> Fmt.string ppf "ISC" | `LGPL f -> Fmt.pf ppf "LGPLv%f" f
      | `BSD i -> Fmt.pf ppf "%i Clause BSD" i)
    Stdlib.( = )

let test_tool () =
  let open Rresult in
  let path = "adding-unit-tests-to-your-project.md" in
  match Collection.Workflow.v ~path ~content:(Files.read_file path) with
  | Ok wf -> (
      let module T = Collection.Tool in
      let path = "dune.md" in
      let s = Files.read_file path in
      match T.v ~path ~content:s with
      | Ok v ->
          let ws = T.get_workflows v [ wf ] in
          Alcotest.(check string) "same title" "Dune" v.data.title;
          Alcotest.(check string)
            "same description"
            "Dune is a build tool that has been widely adopted in the OCaml \
             world"
            v.data.description;
          Alcotest.(check license) "same license" `MIT v.data.license;
          Alcotest.(check (list string))
            "same workflows"
            [ "Adding Unit Tests to your Project" ]
            (List.map (fun (w : Collection.Workflow.t) -> w.data.title) ws)
      | e -> handle_error e)
  | e -> handle_error e

let tests =
  [ ("test_getters", `Quick, test_getters); ("test_tool", `Quick, test_tool) ]
