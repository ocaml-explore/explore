open Tyxml

let get_time () =
  Ptime.of_float_s (Unix.gettimeofday ()) |> function
  | Some t ->
      Ptime.pp Format.str_formatter t;
      Format.flush_str_formatter ()
  | None -> "2020-09-01 11:15:30 +00:00"

let elt_to_string elt =
  let open Tyxml in
  Format.(fprintf str_formatter "%a\n" (Html.pp_elt ()) elt);
  Format.flush_str_formatter ()

let extract_file s =
  let rec extract = function
    | "file" :: file :: _ -> Some file
    | _ :: xs -> extract xs
    | [] -> None
  in
  Core.String.split_on_chars ~on:[ '='; ','; ' ' ] s |> extract

let code_to_html workflow (bs : Omd.block list) =
  let rec loop (acc : Omd.block list) (bs : Omd.block list) =
    match bs with
    (* MDX requires a comment before the code block *)
    | { bl_desc = Omd.Html_block html; _ }
      :: ({ bl_desc = Omd.Code_block _; _ } as c) :: bs ->
        let file =
          match extract_file html with
          | Some f -> f
          | None -> failwith "Could not parse MDX comment"
        in
        let uri =
          "https://github.com/ocaml-explore/explore/tree/trunk/content/workflows/"
          ^ workflow
          ^ "/"
          ^ file
        in
        let button =
          [%html
            "<div><p class='toolbar'><a href=" uri ">Source Code</a></p></div>"]
        in

        let code =
          [%html
            "<div>"
              [ button; Tyxml.Html.Unsafe.data (Omd.to_html [ c ]) ]
              "</div>"]
          |> Tyxml.Html.pp_elt () Format.str_formatter;
          Format.flush_str_formatter ()
        in
        loop ({ bl_desc = Omd.Html_block code; bl_attributes = [] } :: acc) bs
    | b :: bs -> loop (b :: acc) bs
    | [] -> List.rev acc
  in
  loop [] bs
