open Core
open Explore
module Lib = Collection.Library
module User = Collection.User
module Plat = Collection.Platform

let build_phase () =
  let pages = Make.build_pages () in
  let index = Build.build_page ~file:"content/index.md" in
  let workflows = Make.build_workflows () in
  let libraries = Make.build_libraries () in
  let platform = Make.build_platform () in
  let users = Make.build_users () in
  Make.output_pages (index :: pages);
  Make.output_workflows workflows;
  Make.output_collection Lib.get_path Lib.to_html_with_workflows
    "content/libraries/index.html"
    (Lib.build_index "Libraries" "Useful OCaml community libraries")
    Lib.get_workflows workflows libraries;
  Make.output_collection User.get_path User.to_html_with_workflows
    "content/users/index.html"
    (User.build_index "Users" "People using OCaml to get things done")
    User.get_workflows workflows users;
  Make.output_collection Plat.get_path Plat.to_html_with_workflows
    "content/platform/index.html"
    (Plat.build_index "Platform" "The OCaml Platform")
    Plat.get_workflows workflows platform

let command =
  Core.Command.basic
    ~summary:
      "🐫🐫🐫  Explore - a tool for building OCaml Explore  🐫🐫🐫"
    Core.Command.Let_syntax.(
      let%map_open mode = anon (maybe ("mode - <build>" %: string))
      and _output =
        flag "-o"
          (optional_with_default "notion" string)
          ~doc:"folder for exported folder"
      in
      fun () ->
        match mode with
        | Some "build" -> build_phase ()
        | _ -> print_endline "Please specify either to export or build")

let () = Core.Command.run command
