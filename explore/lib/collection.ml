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

  type topic =
    | Starter of bool [@name "starter"]
    | Environment of bool [@name "environment"]
    | Coding of bool [@name "coding"]
    | Testing of bool [@name "testing"]
    | Publishing of bool [@name "publishing"]
    | Misc of bool [@name "misc"]
  [@@deriving yaml]

  let compare a b =
    let priority = function
      | Starter _ -> 0
      | Environment _ -> 1
      | Coding _ -> 2
      | Testing _ -> 3
      | Publishing _ -> 4
      | Misc _ -> 5
    in
    Int.compare (priority a) (priority b)

  let topic_from_string general = function
    | "starter" -> Starter general
    | "env" | "environment" -> Environment general
    | "coding" -> Coding general
    | "testing" -> Testing general
    | "publishing" -> Publishing general
    | _ -> Misc general

  type workflow = {
    title : string;
    date : string;
    authors : string list;
    description : string;
    topic : topic option;
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
      ask "Topic of the workflow" (Some "misc") >>= fun topic ->
      ask "Does the workflow generalise well (true/false)?" (Some "false")
      >>= fun general ->
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
      let topic = topic_from_string (bool_of_string general) topic in
      let libraries = split_drop libraries in
      let users = split_drop users in
      Ok
        {
          title;
          date;
          description;
          authors = [ author ];
          tools;
          topic = Some topic;
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
    let tools =
      match t.data.tools with
      | Some ts ->
          let spans =
            List.map
              (fun t ->
                let link = "/platform/" ^ Files.title_to_dirname t in
                [%html
                  "<span class='details-tools'><a href=" link ">" [ Html.txt t ]
                    "</a></span>"])
              ts
          in
          [%html "<div><p>Platform tools: " spans "</p></div>"]
      | None -> Tyxml.Html.span []
    in
    let tools =
      Format.(fprintf str_formatter "%a\n\n" (Tyxml.Html.pp_elt ()) tools);
      Format.flush_str_formatter ()
    in
    let omd = td @ Omd.of_string (tools ^ t.body) in
    let toc = Toc.(to_html (toc omd)) in
    Components.wrap_body
      ~toc:(Some [ toc ])
      ~title:t.data.title ~description:t.data.description
      ~body:
        ([
           Html.Unsafe.data
             (Omd.to_html
                (Toc.transform omd
                |> Utils.code_to_html (Files.title_to_dirname t.data.title)));
         ]
        @ resources)
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

let link typ s =
  "https://github.com/ocaml-explore/explore/tree/trunk/content/"
  ^ typ
  ^ "/"
  ^ Files.title_to_dirname s
  ^ "/index.md"

let to_html_with_workflows_generic :
      'a. Workflow.t list -> 'a info_getter -> 'a -> string -> Tyxml.Html.doc =
 fun related info t link ->
  let lst =
    Core.List.map
      ~f:(fun w ->
        ( "/" ^ fst (Core.Filename.split (Files.drop_first_dir ~path:w.path)),
          w.data.topic,
          w.data.title,
          w.data.description ))
      related
  in
  let topic = function None -> Workflow.Misc true | Some s -> s in
  let sections =
    [
      ( [%html "<div><h3>" [ Html.txt "Starter" ] "</h3></div>"],
        Core.List.filter
          ~f:(fun (_, t, _, _) -> 0 = Workflow.compare (Starter true) (topic t))
          lst );
      ( [%html "<div><h3>" [ Html.txt "Environment" ] "</h3></div>"],
        Core.List.filter
          ~f:(fun (_, t, _, _) ->
            0 = Workflow.compare (Environment true) (topic t))
          lst );
      ( [%html "<div><h3>" [ Html.txt "Coding" ] "</h3></div>"],
        Core.List.filter
          ~f:(fun (_, t, _, _) -> 0 = Workflow.compare (Coding true) (topic t))
          lst );
      ( [%html "<div><h3>" [ Html.txt "Testing" ] "</h3></div>"],
        Core.List.filter
          ~f:(fun (_, t, _, _) -> 0 = Workflow.compare (Testing true) (topic t))
          lst );
      ( [%html "<div><h3>" [ Html.txt "Publishing" ] "</h3></div>"],
        Core.List.filter
          ~f:(fun (_, t, _, _) ->
            0 = Workflow.compare (Publishing true) (topic t))
          lst );
      ( [%html "<div><h3>" [ Html.txt "Misc" ] "</h3></div>"],
        Core.List.filter
          ~f:(fun (_, t, _, _) -> 0 = Workflow.compare (Misc true) (topic t))
          lst );
    ]
  in
  let sections =
    List.map
      (fun (s, lst) -> (s, List.map (fun (a, _, b, c) -> (a, b, c)) lst))
      sections
  in
  let workflow_comp = Components.make_sectioned_ordered_list sections in
  let td =
    Components.make_omd_title_date ~title:(info.title t) ~date:(info.date t)
  in
  let edit =
    [%html
      "<p id='edit'><span class='details'><a href=" link
        ">Edit this page on Github</a></span></p>"]
  in
  let omd = td @ Omd.of_string (info.body t) in
  let toc = Toc.(to_html (toc omd)) in
  let workflows = [%html "<h2>" [ Html.txt "Related Workflows" ] "</h2>"] in
  let content =
    if Core.List.is_empty sections then
      [ Html.Unsafe.data Omd.(to_html (Toc.transform omd)); edit ]
    else
      [ Html.Unsafe.data Omd.(to_html (Toc.transform omd)); workflows ]
      @ workflow_comp
      @ [ edit ]
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
            [],
            t.data.title,
            t.data.description ))
        ts
    in
    Components.wrap_body ~toc:None ~title ~description
      ~body:[ Components.make_title title; Components.make_index_list lst ]

  let get_workflows t (workflows : Workflow.t list) =
    List.map
      (fun tt ->
        try List.find (fun (w : Workflow.t) -> tt = w.data.title) workflows
        with Not_found ->
          failwith
            ("[Workflow Error] Could not find `"
            ^ tt
            ^ "' for `"
            ^ t.data.title
            ^ "'"))
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
    let url = link "users" t.data.title in
    to_html_with_workflows_generic workflows info t url
end

type license = [ `MIT | `ISC | `LGPL of float | `BSD of int ] [@@deriving yaml]

type lifecycle = [ `INCUBATE | `ACTIVE | `SUSTAIN | `DEPRECATE ]
[@@deriving yaml]

let license_from_string s : license =
  match String.lowercase_ascii s with
  | "mit" -> `MIT
  | "isc" -> `ISC
  | "lgplv2" -> `LGPL 2.0
  | "lgplv2.1" -> `LGPL 2.1
  | "bsd2" -> `BSD 2
  | "bsd3" -> `BSD 3
  | s ->
      Fmt.(pf stdout "%a %s" (styled `Red string) "[Decoding license failed]" s);
      failwith ""

let license_to_string : license -> string = function
  | `MIT -> "MIT"
  | `ISC -> "ISC"
  | `LGPL f -> "LGPLv" ^ string_of_float f
  | `BSD i -> string_of_int i ^ " Clause BSD"

let lifecycle_from_string s : lifecycle =
  match String.lowercase_ascii s with
  | "incubate" -> `INCUBATE
  | "active" -> `ACTIVE
  | "sustain" -> `SUSTAIN
  | "deprecate" -> `DEPRECATE
  | s ->
      Fmt.(
        pf stdout "%a %s" (styled `Red string) "[Decoding lifecycle failed]" s);
      failwith "Error"

let lifecycle_to_string_priority : lifecycle -> string * int = function
  | `INCUBATE -> ("incubate", 0)
  | `ACTIVE -> ("active", 1)
  | `SUSTAIN -> ("sustain", 2)
  | `DEPRECATE -> ("deprecate", 3)

module Tool = struct
  type tool = {
    title : string;
    repo : string;
    license : license;
    lifecycle : lifecycle;
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
      ask "Lifecyle stage of the tool" None >>= fun lifecycle ->
      let lifecycle = lifecycle_from_string lifecycle in
      let license = license_from_string license in
      let date = Utils.get_time () in
      Ok { title; description; date; repo; license; lifecycle }
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
    let ts =
      List.sort
        (fun a b ->
          Int.compare
            (snd (lifecycle_to_string_priority a.data.lifecycle))
            (snd (lifecycle_to_string_priority b.data.lifecycle)))
        ts
    in
    let lst =
      Core.List.map
        ~f:(fun t ->
          let typ = fst (lifecycle_to_string_priority t.data.lifecycle) in
          ( "/" ^ fst (Core.Filename.split (Files.drop_first_dir ~path:t.path)),
            [ typ ],
            t.data.title,
            "[" ^ license_to_string t.data.license ^ "] " ^ t.data.description
          ))
        ts
    in
    let incubate =
      "New tools that fill a gap in the ecosystem but are not quite ready for \
       wide-scale release and adoption."
    in
    let active =
      "The work-horse tools that are used daily with strong backwards \
       compatibility guarentees from the community."
    in
    let sustain =
      "Tools that will not likely see any major feature added but can be used \
       reliably even if not being actively developed."
    in
    let deprecate = "Tools that are gradually being phased out of use." in
    let p str = [ [%html "<p>" [ Html.txt str ] "</p>"] ] in
    let sections =
      [
        ( [%html
            "<div><h2>" [ Html.txt "Incubate" ] "</h2>" (p incubate) "</div>"],
          Core.List.filter ~f:(fun (_, t, _, _) -> t = [ "incubate" ]) lst );
        ( [%html "<div><h2>" [ Html.txt "Active" ] "</h2>" (p active) "</div>"],
          Core.List.filter ~f:(fun (_, t, _, _) -> t = [ "active" ]) lst );
        ( [%html "<div><h2>" [ Html.txt "Sustain" ] "</h2>" (p sustain) "</div>"],
          Core.List.filter ~f:(fun (_, t, _, _) -> t = [ "sustain" ]) lst );
        ( [%html
            "<div><h2>" [ Html.txt "Deprecate" ] "</h2>" (p deprecate) "</div>"],
          Core.List.filter ~f:(fun (_, t, _, _) -> t = [ "deprecate" ]) lst );
      ]
    in
    Components.wrap_body ~toc:None ~title ~description
      ~body:
        ([ Components.make_title title ]
        @ Components.make_sectioned_list sections)

  let to_html_with_workflows workflows t =
    let details =
      let class_ = fst (lifecycle_to_string_priority t.data.lifecycle) in
      let repo =
        [%html
          "<span class='details'><a href=" t.data.repo ">Repository</a></span>"]
      in
      [%html
        "<div>Meta-data: <span class='details'>License: "
          [ Html.txt (license_to_string t.data.license) ]
          "</span>" [ repo ] "<span class=" [ "details"; class_ ] ">Lifecycle: "
          [ Html.txt class_ ] "</span></div>"]
      |> Utils.elt_to_string
    in
    let info : t info_getter =
      {
        path = (fun t -> t.path);
        title = (fun t -> t.data.title);
        description = (fun t -> t.data.description);
        body = (fun t -> details ^ t.body);
        date = (fun t -> t.data.date);
      }
    in
    let url = link "platform" t.data.title in
    to_html_with_workflows_generic workflows info t url
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
            [],
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
    let url = link "libraries" t.data.title in
    to_html_with_workflows_generic workflows info t url
end
