open Cmdliner
open Explore

let run collection =
  match collection with
  | "workflow" ->
      Collection.Workflow.build ();
      0
  | _ -> assert false

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
