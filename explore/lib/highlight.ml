open Tyxml

let ignored_langs = [ "bash"; "sh"; ""; "yaml"; "markdown"; "c"; "diff" ]

let transform blocks =
  let f (b : Omd.block) =
    match b.bl_desc with
    | Omd.Code_block (lang, src) -> (
        if List.mem lang ignored_langs then b
        else
          match Syntax.src_code_to_html lang src with
          | Ok lst ->
              let html =
                [%html
                  "<pre><code>"
                    (List.concat (Core.List.drop_last_exn lst))
                    "</code></pre>"]
              in
              let html =
                Html.pp_elt () Format.str_formatter html;
                Format.flush_str_formatter ()
              in
              { b with bl_desc = Omd.Html_block html }
          | Error s -> failwith s)
    | _ -> b
  in
  List.map f blocks
