open Cmdliner
open Explore

let run collection =
  match collection with
  | "workflow" ->
      Collection.Workflow.build ();
      0
  | "user" ->
      Collection.User.build ();
      0
  | "tool" ->
      Collection.Tool.build ();
      0
  | "platform" ->
      Collection.Tool.build ();
      0
  | "library" ->
      Collection.Library.build ();
      0
  | s ->
      Fmt.(
        pf stdout "%a: No support for %s - try workflow, user, tool or library"
          (styled `Red string)
          "[BUILD FAILURE]" s);
      -1

let collection =
  let docv = "COLLECTION" in
  let doc =
    "The type of collection you want to build e.g. workflow, user etc."
  in
  Arg.(value & pos 0 string "workflow" & info ~doc ~docv [])

let info =
  let doc =
    "Build the scaffolding for a new collection from the command line."
  in
  Term.info ~doc "new"

let term = Term.(pure run $ collection)

let cmd = (term, info)
