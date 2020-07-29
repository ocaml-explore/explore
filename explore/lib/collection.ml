open Core
open Tyxml

module type S = sig
  type t

  type resource = { url : string; title : string; description : string }

  val v : path:string -> content:string -> t

  val to_string : t -> string

  val get_meta : t -> Jekyll_format.fields

  val get_title : t -> string

  val get_date : t -> string

  val get_md : t -> string

  val get_path : t -> string

  val get_prop : coll:t -> ident:string -> Yaml.value option

  val get_resources : t -> resource list

  val get_description : t -> string

  val to_html : t -> Tyxml.Html.doc

  val build_index : string -> t list -> Tyxml.Html.doc

  val get_relations :
    string -> t -> (Yaml.value list, [> `Msg of string ]) Result.t
end

module Basic : S = struct
  type t = { data : Jekyll_format.t; path : string }

  type resource = { url : string; title : string; description : string }

  let get_meta t = Jekyll_format.fields t.data

  let get_path t = t.path

  let get_title t =
    match Jekyll_format.(title (fields t.data)) with
    | Ok title -> title
    | Error _ -> failwith "Failed to get title for: " ^ get_path t

  let get_md t = Jekyll_format.body t.data

  let get_date t =
    let date_to_string p =
      Ptime.pp Format.str_formatter p;
      Format.flush_str_formatter ()
    in
    match Jekyll_format.(date (fields t.data)) with
    | Ok date -> date_to_string date
    | Error _ -> failwith "Failed to get date for: " ^ get_md t

  let v ~path ~content =
    match Jekyll_format.of_string content with
    | Ok data -> { data; path }
    | Error msg ->
        Rresult.R.pp_msg Format.std_formatter msg;
        failwith ("Jekyll Parsing Error: " ^ path)

  let to_string t = t.path

  let get_prop ~coll ~ident = Jekyll_format.find ident (get_meta coll)

  let get_resources t =
    let assoc = List.Assoc.find ~equal:String.equal in
    let build_resource = function
      | `O res -> (
          match
            (assoc res "url", assoc res "title", assoc res "description")
          with
          | Some (`String url), Some (`String title), Some (`String description)
            ->
              Some { url; title; description }
          | _ -> None)
      | _ -> None
    in
    match get_prop ~coll:t ~ident:"resources" with
    | Some (`A resources) ->
        List.map ~f:build_resource resources
        |> List.filter ~f:Option.is_some
        |> List.map ~f:(function Some s -> s | None -> assert false)
    | _ -> []

  let get_description t =
    match get_prop ~coll:t ~ident:"description" with
    | Some (`String d) -> d
    | _ -> failwith "Expected to find a description property, but got none."

  let build_index title ts =
    let lst =
      List.map
        ~f:(fun t ->
          ( "/"
            ^ fst
                (Core.Filename.split (Files.drop_first_dir ~path:(get_path t))),
            get_title t,
            get_description t ))
        ts
    in
    Components.wrap_body ~toc:None ~title
      ~body:[ Components.make_title title; Components.make_index_list lst ]

  let get_relations relation t =
    match Jekyll_format.find relation (get_meta t) with
    | Some (`A lst) -> Ok lst
    | _ -> Error (`Msg "Malformed Frontmatter: Expected a list of relations")

  let to_html t =
    let make_resources lst =
      let to_elt e =
        [%html
          "<li><a href=" e.url ">" [ Html.txt e.title ] "</a> - "
            [ Html.txt e.description ] "</li>"]
      in
      [%html
        {|
        <ol>
          |} (List.map ~f:to_elt lst)
          {|
        </ol>
      |}]
    in
    let res_title = [%html "<h3>" [ Html.txt "Resources" ] "</h3>"] in
    let resources = get_resources t in
    let resources =
      if List.length resources = 0 then []
      else [ res_title; make_resources resources ]
    in
    let td =
      Components.make_omd_title_date ~title:(get_title t) ~date:(get_date t)
    in
    let omd = td @ Omd.of_string (get_md t) in
    let toc = Toc.(to_html (toc omd)) in
    Components.wrap_body
      ~toc:(Some [ toc ])
      ~title:(get_title t)
      ~body:([ Html.Unsafe.data (Omd.to_html (Toc.transform omd)) ] @ resources)
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
            Workflow.get_title w,
            Workflow.get_description w ))
        related
    in
    let workflow_comp = Components.make_index_list path_and_title in
    let td =
      Components.make_omd_title_date ~title:(get_title t) ~date:(get_date t)
    in
    let omd = td @ Omd.of_string (get_md t) in
    let toc = Toc.(to_html (toc omd)) in
    let workflows = [%html "<h3>" [ Html.txt "Related Workflows" ] "</h3>"] in
    let content =
      if List.is_empty path_and_title then
        [ Html.Unsafe.data Omd.(to_html (Toc.transform omd)) ]
      else
        [
          Html.Unsafe.data Omd.(to_html (Toc.transform omd));
          workflows;
          workflow_comp;
        ]
    in
    Components.wrap_body ~toc:(Some [ toc ]) ~title:(get_title t) ~body:content

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
