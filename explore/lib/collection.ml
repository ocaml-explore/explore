open Core
open Tyxml

module type S = sig
  type t

  val v : path:string -> content:string -> t

  val to_string : t -> string

  val get_meta : t -> Jekyll_format.fields

  val get_title : t -> string

  val get_md : t -> string

  val get_path : t -> string

  val get_prop : coll:t -> ident:string -> Yaml.value option

  val to_html : t -> Tyxml.Html.doc

  val build_index : string -> t list -> Tyxml.Html.doc

  val get_relations :
    string -> t -> (Yaml.value list, [> `Msg of string ]) Result.t
end

module Basic : S = struct
  type t = { data : Jekyll_format.t; path : string }

  let get_meta t = Jekyll_format.fields t.data

  let get_path t = t.path

  let get_title t =
    match Jekyll_format.(title (fields t.data)) with
    | Ok title -> title
    | Error _ -> failwith "Failed to get title for: " ^ get_path t

  let get_md t = Jekyll_format.body t.data

  let v ~path ~content =
    match Jekyll_format.of_string content with
    | Ok data -> { data; path }
    | Error msg ->
        Rresult.R.pp_msg Format.std_formatter msg;
        failwith ("Jekyll Parsing Error: " ^ path)

  let to_string t = t.path

  let to_html t =
    Components.wrap_body ~title:(get_title t)
      ~body:[ Html.Unsafe.data Omd.(to_html (of_string (get_md t))) ]

  let build_index title ts =
    let lst =
      List.map
        ~f:(fun t ->
          ( "/"
            ^ fst
                (Core.Filename.split (Files.drop_first_dir ~path:(get_path t))),
            get_title t ))
        ts
    in
    Components.wrap_body ~title
      ~body:[ Components.make_title title; Components.make_link_list lst ]

  let get_prop ~coll ~ident = Jekyll_format.find ident (get_meta coll)

  let get_relations relation t =
    match Jekyll_format.find relation (get_meta t) with
    | Some (`A lst) -> Ok lst
    | _ -> Error (`Msg "Malformed Frontmatter: Expected a list of relations")
end

module Workflow = struct
  include Basic
end

module type Collection = sig
  include S

  val to_html_with_workflows : Workflow.t list -> t -> Tyxml.Html.doc

  val get_workflows : t -> Workflow.t list -> Workflow.t list
end

module C = struct
  include Basic

  let to_html_with_workflows related t =
    let path_and_title =
      List.map
        ~f:(fun w ->
          ( "/"
            ^ fst
                (Core.Filename.split (Files.drop_first_dir ~path:(get_path w))),
            Workflow.get_title w ))
        related
    in
    let workflow_comp = Components.make_link_list path_and_title in
    let title = [%html "<h1>" [ Html.txt (get_title t) ] "</h1>"] in
    let workflows = [%html "<h3>" [ Html.txt "Related Workflows" ] "</h3>"] in
    let content =
      if List.is_empty path_and_title then
        [ title; Html.Unsafe.data Omd.(to_html (of_string (get_md t))) ]
      else
        [
          title;
          Html.Unsafe.data Omd.(to_html (of_string (get_md t)));
          workflows;
          workflow_comp;
        ]
    in
    Components.wrap_body ~title:(get_title t) ~body:content

  let get_workflows t (workflows : Workflow.t list) =
    let user_title = get_title t in
    let related w =
      match get_relations "users" w with Ok lst -> lst | Error _ -> []
    in
    let extract_strings = function
      | `String str -> str
      | _ -> failwith "Workflows should only be a list of strings"
    in
    List.filter
      ~f:(fun w ->
        let users = List.map ~f:extract_strings (related w) in
        List.mem ~equal:String.equal users user_title)
      workflows
end

module User = struct
  include C
end

module Library = struct
  include C
end

module Platform = struct
  include C
end
