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

module Lib = Collection.Library
module User = Collection.User
module Tool = Collection.Tool

let build_phase () =
  let pages = build_pages () in
  let index = Build.build_page ~file:"content/index.md" in
  let workflows = build_workflows () in
  let libraries = build_libraries () in
  let platform = build_platform () in
  let users = build_users () in
  output_pages (index :: pages);
  output_workflows workflows;
  output_collection
    (fun (t : Lib.t) -> t.path)
    Lib.to_html_with_workflows "content/libraries/index.html"
    (Lib.build_index "Libraries" "Useful OCaml community libraries")
    Lib.get_workflows workflows libraries;
  output_collection
    (fun (t : User.t) -> t.path)
    User.to_html_with_workflows "content/users/index.html"
    (User.build_index "Users" "People using OCaml to get things done")
    User.get_workflows workflows users;
  output_collection
    (fun (t : Tool.t) -> t.path)
    Tool.to_html_with_workflows "content/platform/index.html"
    (Tool.build_index "Platform" "The OCaml Platform")
    Tool.get_workflows workflows platform

(* Command Line Tool *)
open Cmdliner

let run () =
  build_phase ();
  0

let info =
  let doc = "Build the site to static files" in
  Term.info ~doc "build"

let cmd = (Term.(const run $ const ()), info)
