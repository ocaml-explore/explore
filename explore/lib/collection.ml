open Tyxml
module Cal = CalendarLib
module Jf = Jekyll_format

type err = [ `MalformedCollection of string ]

type ask_err = [ `NoDefault of string ]

let ask ?(break = false) question default =
  (if break then Format.(fprintf std_formatter "%s\n%!" question)
  else Format.(fprintf std_formatter "%s: %!" question));
  let line = read_line () in
  match (line, default) with
  | "", Some d -> Ok d
  | "", None ->
      Error
        (`NoDefault "No default for that question, please provide an answer")
  | l, _ -> Ok l

let split_drop s =
  List.filter (( <> ) "")
    Core.String.(split ~on:',' (substr_replace_all ~pattern:", " ~with_:"," s))
  |> function
  | [] -> None
  | lst -> Some lst

module type S = sig
  type t

  val v : path:string -> content:string -> (t, err) result

  val build : unit -> unit
end

let get_date d =
  let date_to_string p =
    Ptime.pp Format.str_formatter p;
    Format.flush_str_formatter ()
  in
  let d = date_to_string d in
  Cal.Printer.Fcalendar.sprint "%d, %B %Y at %T"
    (CalendarLib.Printer.Fcalendar.from_fstring "%i %T %:z" d)

type 'a maker = {
  of_yaml : Yaml.value -> ('a, Rresult.R.msg) result;
  post : 'a -> ('a, err) result;
}

(* A generic constructor to avoid code duplication *)
let v_generic : 'a. 'a maker -> content:string -> ('a * string, err) result =
 fun mkr ~content ->
  match Jf.of_string content with
  | Ok data -> (
      match mkr.of_yaml Jf.(fields_to_yaml (fields data)) with
      | Ok t -> (
          match mkr.post t with
          | Ok v -> Ok (v, Jf.body data)
          | Error e -> Error e)
      | Error (`Msg m) -> Error (`MalformedCollection m))
  | Error (`Msg m) -> Error (`MalformedCollection m)

let output ~path ~title yaml =
  let dirname = Files.title_to_dirname title in
  let yaml =
    Yaml.pp Format.str_formatter yaml;
    Format.flush_str_formatter ()
  in
  Unix.mkdir (path ^ dirname) 0o777;
  Files.output_file
    ~content:("---\n" ^ yaml ^ "\n---\n")
    ~path:(path ^ dirname ^ "/index.md")

module Workflow = struct
  type resource = { title : string; description : string; url : string }
  [@@deriving yaml]

  type workflow = {
    title : string;
    date : string;
    authors : string list;
    description : string;
    tools : string list option;
    users : string list option;
    libraries : string list option;
    resources : resource list option;
  }
  [@@deriving yaml]

  type t = { path : string; data : workflow; body : string }

  let v ~path ~content =
    let post t =
      match Jf.parse_date t.date with
      | Ok date ->
          let date = get_date date in
          Ok { t with date }
      | Error (`Msg m) -> Error (`MalformedCollection m)
    in
    let mkr : workflow maker = { of_yaml = workflow_of_yaml; post } in
    match v_generic mkr ~content with
    | Ok (data, body) -> Ok { path; data; body }
    | Error err -> Error err

  let build () =
    let open Rresult in
    let content_path = "content/workflows/" in
    let user_input () =
      ask "Title of the workflow" None >>= fun title ->
      ask "Description of the workflow" None >>= fun description ->
      ask "Author of the workflow" None >>= fun author ->
      ask "Platform tools used by the workflow e.g. dune, dune-release"
        (Some "")
      >>= fun tools ->
      ask "Libraries used by the workflow e.g. alcotest, cstruct" (Some "")
      >>= fun libraries ->
      ask "Users of the workflow e.g. library authors, application developers"
        None
      >>= fun users ->
      let date = Utils.get_time () in
      let tools = split_drop tools in
      let libraries = split_drop libraries in
      let users = split_drop users in
      Ok
        {
          title;
          date;
          description;
          authors = [ author ];
          tools;
          libraries;
          users;
          resources = None;
        }
    in
    match user_input () with
    | Ok w -> (
        output ~title:w.title ~path:content_path (workflow_to_yaml w);
        match w.users with
        | Some users ->
            Format.(
              fprintf std_formatter
                "Remember to update the users (%s) to contain '%s' under the \
                 workflows section!"
                (String.concat ", " users) w.title)
        | None -> ())
    | Error (`NoDefault msg) -> failwith msg

  let to_html (t : t) =
    let make_resources lst =
      let to_elt e =
        [%html
          "<li><a href=" e.url ">" [ Html.txt e.title ] "</a> - "
            [ Html.txt e.description ] "</li>"]
      in
      [%html
        {|
        <ol>
          |}
          (Core.List.map ~f:to_elt lst)
          {|
        </ol>
      |}]
    in
    let res_title = [%html "<h3>" [ Html.txt "Resources" ] "</h3>"] in
    let resources = t.data.resources in
    let resources =
      match resources with
      | None -> []
      | Some resources -> [ res_title; make_resources resources ]
    in
    let td =
      Components.make_omd_title_date ~title:t.data.title ~date:t.data.date
    in
    let omd = td @ Omd.of_string t.body in
    let toc = Toc.(to_html (toc omd)) in
    Components.wrap_body
      ~toc:(Some [ toc ])
      ~title:t.data.title ~description:t.data.description
      ~body:([ Html.Unsafe.data (Omd.to_html (Toc.transform omd)) ] @ resources)
end

module type Collection = sig
  type t

  include S with type t := t

  val to_html_with_workflows : Workflow.t list -> t -> Tyxml.Html.doc

  val build_index : string -> string -> t list -> Tyxml.Html.doc

  val get_workflows : t -> Workflow.t list -> Workflow.t list
end

type 'a info_getter = {
  path : 'a -> string;
  title : 'a -> string;
  date : 'a -> string;
  description : 'a -> string;
  body : 'a -> string;
}

let to_html_with_workflows_generic :
      'a. Workflow.t list -> 'a info_getter -> 'a -> Tyxml.Html.doc =
 fun related info t ->
  let path_and_title =
    Core.List.map
      ~f:(fun w ->
        ( "/" ^ fst (Core.Filename.split (Files.drop_first_dir ~path:w.path)),
          w.data.title,
          w.data.description ))
      related
  in
  let workflow_comp = Components.make_ordered_index_list path_and_title in
  let td =
    Components.make_omd_title_date ~title:(info.title t) ~date:(info.date t)
  in
  let omd = td @ Omd.of_string (info.body t) in
  let toc = Toc.(to_html (toc omd)) in
  let workflows = [%html "<h3>" [ Html.txt "Related Workflows" ] "</h3>"] in
  let content =
    if Core.List.is_empty path_and_title then
      [ Html.Unsafe.data Omd.(to_html (Toc.transform omd)) ]
    else
      [
        Html.Unsafe.data Omd.(to_html (Toc.transform omd));
        workflows;
        workflow_comp;
      ]
  in
  Components.wrap_body
    ~toc:(Some [ toc ])
    ~title:(info.title t) ~description:(info.description t) ~body:content

module User = struct
  type user = {
    title : string;
    date : string;
    description : string;
    workflows : string list;
  }
  [@@deriving yaml]

  type t = { path : string; data : user; body : string }

  let v ~path ~content =
    let post t =
      match Jekyll_format.parse_date t.date with
      | Ok date ->
          let date = get_date date in
          Ok { t with date }
      | Error (`Msg m) -> Error (`MalformedCollection m)
    in
    let mkr : user maker = { of_yaml = user_of_yaml; post } in
    match v_generic mkr ~content with
    | Ok (data, body) -> Ok { path; data; body }
    | Error err -> Error err

  let build () =
    let open Rresult in
    let content_path = "content/users/" in
    let user_input () =
      ask "Title of the user" None >>= fun title ->
      ask "Description of the user" None >>= fun description ->
      let date = Utils.get_time () in
      Ok { title; description; date; workflows = [] }
    in
    match user_input () with
    | Ok u -> output ~title:u.title ~path:content_path (user_to_yaml u)
    | Error (`NoDefault m) -> failwith m

  let build_index title description ts =
    let lst =
      Core.List.map
        ~f:(fun t ->
          ( "/" ^ fst (Core.Filename.split (Files.drop_first_dir ~path:t.path)),
            t.data.title,
            t.data.description ))
        ts
    in
    Components.wrap_body ~toc:None ~title ~description
      ~body:[ Components.make_title title; Components.make_index_list lst ]

  let get_workflows t (workflows : Workflow.t list) =
    List.map
      (fun tt ->
        List.find (fun (w : Workflow.t) -> tt = w.data.title) workflows)
      t.data.workflows

  let to_html_with_workflows workflows t =
    let info : t info_getter =
      {
        path = (fun t -> t.path);
        title = (fun t -> t.data.title);
        description = (fun t -> t.data.description);
        body = (fun t -> t.body);
        date = (fun t -> t.data.date);
      }
    in
    to_html_with_workflows_generic workflows info t
end

module Tool = struct
  type tool = {
    title : string;
    repo : string;
    license : string;
    date : string;
    description : string;
  }
  [@@deriving yaml]

  type t = { path : string; data : tool; body : string }

  let v ~path ~content =
    let post t =
      match Jekyll_format.parse_date t.date with
      | Ok date ->
          let date = get_date date in
          Ok { t with date }
      | Error (`Msg m) -> Error (`MalformedCollection m)
    in
    let mkr : tool maker = { of_yaml = tool_of_yaml; post } in
    match v_generic mkr ~content with
    | Ok (data, body) -> Ok { path; data; body }
    | Error err -> Error err

  let build () =
    let open Rresult in
    let content_path = "content/platform/" in
    let user_input () =
      ask "Name of the tool" None >>= fun title ->
      ask "Description of the user" None >>= fun description ->
      ask "Repository of the tool" None >>= fun repo ->
      ask "License of the tool" None >>= fun license ->
      let date = Utils.get_time () in
      Ok { title; description; date; repo; license }
    in
    match user_input () with
    | Ok t -> output ~title:t.title ~path:content_path (tool_to_yaml t)
    | Error (`NoDefault m) -> failwith m

  let get_workflows t (workflows : Workflow.t list) =
    List.filter
      (fun (w : Workflow.t) ->
        List.mem t.data.title
          (match w.data.tools with Some t -> t | None -> []))
      workflows

  let build_index title description ts =
    let lst =
      Core.List.map
        ~f:(fun t ->
          ( "/" ^ fst (Core.Filename.split (Files.drop_first_dir ~path:t.path)),
            t.data.title,
            t.data.description ))
        ts
    in
    Components.wrap_body ~toc:None ~title ~description
      ~body:[ Components.make_title title; Components.make_index_list lst ]

  let to_html_with_workflows workflows t =
    let info : t info_getter =
      {
        path = (fun t -> t.path);
        title = (fun t -> t.data.title);
        description = (fun t -> t.data.description);
        body = (fun t -> t.body);
        date = (fun t -> t.data.date);
      }
    in
    to_html_with_workflows_generic workflows info t
end

module Library = struct
  type library = {
    title : string;
    repo : string;
    date : string;
    description : string;
  }
  [@@deriving yaml]

  type t = { path : string; data : library; body : string }

  let v ~path ~content =
    let post t =
      match Jekyll_format.parse_date t.date with
      | Ok date ->
          let date = get_date date in
          Ok { t with date }
      | Error (`Msg m) -> Error (`MalformedCollection m)
    in
    let mkr : library maker = { of_yaml = library_of_yaml; post } in
    match v_generic mkr ~content with
    | Ok (data, body) -> Ok { path; data; body }
    | Error err -> Error err

  let build () =
    let open Rresult in
    let content_path = "content/libraries/" in
    let user_input () =
      ask "Name of the tool" None >>= fun title ->
      ask "Description of the user" None >>= fun description ->
      ask "Repository of the tool" None >>= fun repo ->
      let date = Utils.get_time () in
      Ok { title; description; date; repo }
    in
    match user_input () with
    | Ok t -> output ~title:t.title ~path:content_path (library_to_yaml t)
    | Error (`NoDefault m) -> failwith m

  let get_workflows t (workflows : Workflow.t list) =
    List.filter
      (fun (w : Workflow.t) ->
        List.mem t.data.title
          (match w.data.libraries with Some t -> t | None -> []))
      workflows

  let build_index title description ts =
    let lst =
      Core.List.map
        ~f:(fun t ->
          ( "/" ^ fst (Core.Filename.split (Files.drop_first_dir ~path:t.path)),
            t.data.title,
            t.data.description ))
        ts
    in
    Components.wrap_body ~toc:None ~title ~description
      ~body:[ Components.make_title title; Components.make_index_list lst ]

  let to_html_with_workflows workflows t =
    let info : t info_getter =
      {
        path = (fun t -> t.path);
        title = (fun t -> t.data.title);
        description = (fun t -> t.data.description);
        body = (fun t -> t.body);
        date = (fun t -> t.data.date);
      }
    in
    to_html_with_workflows_generic workflows info t
end
