open Core
open Explore

let build_collection f dir =
  Build.read_and_build
    ~build:(fun t -> f t)
    ~check:(fun f -> String.equal (Stdlib.Filename.extension f) ".md")
    ~dir

let build_workflows () =
  build_collection
    (fun (path, content) -> Collection.Workflow.v ~path ~content)
    "content/workflows/"

let build_users () =
  build_collection
    (fun (path, content) -> Collection.User.v ~path ~content)
    "content/users/"

let build_libraries () =
  build_collection
    (fun (path, content) -> Collection.Library.v ~path ~content)
    "content/libraries/"

let build_platform () =
  build_collection
    (fun (path, content) -> Collection.Tool.v ~path ~content)
    "content/platform/"

let build_pages () =
  build_collection
    (fun (path, content) -> Page.v ~path ~content)
    "content/pages/"

let output_workflows workflows =
  List.iter
    ~f:(fun (w : Collection.Workflow.t) ->
      Files.output_html
        ~path:(Filename.chop_extension w.path ^ ".html")
        ~doc:(Collection.Workflow.to_html w))
    workflows

let output_collection path_f to_html build_path build_index get_workflows
    workflows collections =
  List.iter
    ~f:(fun w ->
      Files.output_html
        ~path:(Filename.chop_extension (path_f w) ^ ".html")
        ~doc:(to_html (get_workflows w workflows) w))
    collections;
  Files.output_html ~path:build_path ~doc:(build_index collections)

let output_pages pages =
  List.iter
    ~f:(fun p ->
      Files.output_html
        ~path:(Filename.chop_extension (Page.get_path p) ^ ".html")
        ~doc:(Page.to_html p))
    pages
