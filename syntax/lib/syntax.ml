open Tyxml

let span class_gen =
  let span_gen c s =
    [%html "<span class=" [ class_gen c ] ">" [ Html.txt s ] "</span>"]
  in
  function
  | "constant" :: "character" :: _ -> span_gen "constant-character"
  | "constant" :: "language" :: _ -> span_gen "constant-language"
  | "comment" :: _ -> span_gen "comment"
  | "constant" :: "numeric" :: _ -> span_gen "constant-numeric"
  | "entity" :: "name" :: "tag" :: "label" :: _ ->
      span_gen "entity-name-tag-label"
  | "entity" :: "name" :: _ -> span_gen "entity-name"
  | "entity" :: "tag" :: _ -> span_gen "entity-tag"
  | "invalid" :: _ -> span_gen "invalid"
  | "keyword" :: "control" :: _ -> span_gen "keyword-control"
  | "keyword" :: "operator" :: _ -> span_gen "keyword-operator"
  | "keyword" :: _ -> span_gen "keyword"
  | "support" :: _ -> span_gen "support"
  | "meta" :: _ -> span_gen "meta"
  | "punctuation" :: "definition" :: "comment" :: _ ->
      span_gen "punctuation-definition-comment"
  | "punctuation" :: "definition" :: "string" :: _ ->
      span_gen "punctuation-definition-string"
  | "string" :: "quoted" :: _ -> span_gen "string-quoted"
  | "source" :: _ -> span_gen "source"
  | "variable" :: "parameter" :: _ -> span_gen "variable-parameter"
  | t ->
      print_endline (String.concat " " t);
      span_gen "other"

let mk_block lang =
  List.map
    (List.map (fun (scope, str) -> (span (fun c -> lang ^ "-" ^ c) scope) str))

let rec highlight_tokens i spans line = function
  | [] -> List.rev spans
  | tok :: toks ->
      let j = TmLanguage.ending tok in
      assert (j > i);
      let text = String.sub line i (j - i) in
      let scope =
        match TmLanguage.scopes tok with
        | [] -> []
        | scope :: _ -> String.split_on_char '.' scope
      in
      highlight_tokens j ((scope, text) :: spans) line toks

let highlight_string t grammar stack str =
  let lines = String.split_on_char '\n' str in
  let rec loop stack acc = function
    | [] -> List.rev acc
    | line :: lines ->
        (* Some patterns don't work if there isn't a newline *)
        let line = line ^ "\n" in
        let tokens, stack = TmLanguage.tokenize_exn t grammar stack line in
        let spans = highlight_tokens 0 [] line tokens in
        loop stack (spans :: acc) lines
  in
  loop stack [] lines

let lang_to_plist s =
  let data =
    match String.lowercase_ascii s with
    | "ocaml" -> Plists.ocaml
    | "dune" -> Plists.dune
    | "opam" -> Plists.opam
    | l -> failwith ("Language not supported: " ^ l)
  in
  Markup.string data |> Plist_xml.parse_exn

let src_code_to_html source str =
  let t = TmLanguage.create () in
  let plist = lang_to_plist source in
  let grammar = TmLanguage.of_plist_exn plist in
  TmLanguage.add_grammar t grammar;
  match TmLanguage.find_by_name t source with
  | None -> Error ("Unknown language " ^ source)
  | Some grammar ->
      Ok (highlight_string t grammar TmLanguage.empty str |> mk_block source)
