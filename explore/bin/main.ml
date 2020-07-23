open Core

(* Returns all files with absolute and relative paths *)
let all_files root =
  let rec walk acc = function
    | [] -> acc
    | dir :: dirs ->
        let dir_content = Array.to_list (Sys.readdir dir) in
        let added_paths =
          List.rev_map ~f:(fun f -> Filename.concat dir f) dir_content
        in
        let fs =
          List.fold_left ~f:(fun acc f -> f :: acc) ~init:[] added_paths
        in
        let new_dirs = List.filter ~f:(fun f -> Stdlib.Sys.is_directory f) fs in
        walk (fs @ acc) (new_dirs @ dirs)
  in
  walk [] [ root ]

let command =
  Core.Command.basic
    ~summary:"🐫  Explore - a tool for building OCaml Explore  🐫"
    Core.Command.Let_syntax.(
      let%map_open mode = anon (maybe ("mode - <build>" %: string))
      and _output =
        flag "-o"
          (optional_with_default "notion" string)
          ~doc:"folder for exported folder"
      in
      fun () ->
        match mode with
        | Some "build" ->
            Omd.of_string (In_channel.read_all "./content/index.md")
            |> fun body ->
            Explore.Html.wrap_body ~title:"Explore OCaml"
              ~body:[ Tyxml.Html.Unsafe.data (Omd.to_html body) ]
            |> Explore.Html.emit_page "./content/index.html"
        | _ -> print_endline "Please specify either to export or build")

let () = Core.Command.run command
