open Tyxml

type t = { title : string; updated : string; path : string; body : string }

let v ~path ~content =
  let jkl = Jekyll_format.of_string_exn content in
  let title =
    match Jekyll_format.(title (fields jkl)) with
    | Ok title -> title
    | Error _ -> failwith ("No title for: " ^ path)
  in
  let updated =
    Ptime.pp Format.str_formatter Jekyll_format.(date_exn (fields jkl));
    Format.flush_str_formatter ()
  in
  { title; updated; path; body = Jekyll_format.body jkl }

let to_html t =
  let md = Omd.(to_html (of_string t.body)) in
  let page =
    [%html
      {|<h1>|} [ Html.txt t.title ] {|</h1>
    <p><em> Last updated: |}
        [ Html.txt t.updated ] {| </em></p><hr> |}
        [ Tyxml.Html.Unsafe.data md ]]
  in
  Components.wrap_body ~title:t.title ~body:page

let get_body t = t.body

let get_path t = t.path
