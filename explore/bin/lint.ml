open Cmdliner
open Explore

let run collection path =
  let path = match path with Some p -> p | None -> "" in
  let lint v title =
    match v ~path ~content:(Files.read_file path) with
    | Ok w ->
        Fmt.(
          pf stdout "%a: %s" (styled `Green string) "[lint-success]" (title w));
        0
    | Error (`MalformedCollection e) ->
        Fmt.(
          pf stdout "%a %s"
            (styled `Red string)
            "[lint-failure : malformed collection]" e);
        -1
  in
  let open Collection in
  match collection with
  | "workflow" -> lint Workflow.v (fun t -> t.data.title)
  | "user" -> lint User.v (fun t -> t.data.title)
  | "library" -> lint Library.v (fun t -> t.data.title)
  | "tool" -> lint Tool.v (fun t -> t.data.title)
  | _ -> -2

let collection =
  let docv = "COLLECTION" in
  let doc =
    "The type of collection you want to lint e.g. workflow, user etc."
  in
  Arg.(value & pos 0 string "workflow" & info ~doc ~docv [])

let path =
  let docv = "PATH" in
  let doc = "The path to the collection you want to lint" in
  Arg.(value & opt (some string) None & info ~doc ~docv [ "path"; "p" ])

let info =
  let doc = "Lint a collection specified by its type and path." in
  Term.info ~doc "lint"

let term = Term.(pure run $ collection $ path)

let cmd = (term, info)
