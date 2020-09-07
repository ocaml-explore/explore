open Cmdliner
open Explore

let pp_collection ~yaml ~body ppf =
  Fmt.string ppf "---\n";
  Yaml.pp ppf yaml;
  Fmt.pf ppf "---\n%s" body

let run collection path =
  match (collection, path) with
  | "workflow", Some path -> (
      match Collection.Workflow.v ~path ~content:(Files.read_file path) with
      | Ok t ->
          let t = { t with data = { t.data with date = Utils.get_time () } } in
          let content =
            pp_collection
              ~yaml:(Collection.Workflow.workflow_to_yaml t.data)
              ~body:t.body Format.str_formatter;
            Format.flush_str_formatter ()
          in
          Files.output_file ~path ~content;
          0
      | Error _ ->
          Fmt.(string stdout "Failed to update workflow time");
          -1)
  | _, None ->
      Fmt.(string stdout (Utils.get_time ()));
      0
  | _ ->
      Fmt.(
        string stdout
          "Failed to update workflow time -- make sure the path is correct");
      -1

let collection =
  let docv = "COLLECTION" in
  let doc =
    "The type of collection you want to lint e.g. workflow, user etc."
  in
  Arg.(value & pos 0 string "workflow" & info ~doc ~docv [])

let path =
  let docv = "PATH" in
  let doc = "The path to the collection whose time you would like to update." in
  Arg.(value & opt (some string) None & info ~doc ~docv [ "path"; "p" ])

let info =
  let doc = "Print the current time in UTC." in
  Term.info ~doc "time"

let term = Term.(pure run $ collection $ path)

let cmd = (term, info)
