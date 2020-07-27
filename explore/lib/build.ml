open Core

let read_and_build ~build ~check ~dir =
  let files = Files.all_files dir in
  let filt = List.filter ~f:check files in
  let content = List.map ~f:(fun f -> (f, Files.read_file f)) filt in
  List.map ~f:build content

let build_page ~file =
  let content = Files.read_file file in
  Page.v ~path:file ~content
