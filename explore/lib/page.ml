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
  let td = Components.make_omd_title_date ~title:t.title ~date:t.updated in
  let omd = td @ Omd.of_string t.body in
  let toc = Toc.(to_html (toc omd)) in
  let md = Omd.(to_html (Toc.transform omd)) in
  let page = [%html [ Tyxml.Html.Unsafe.data md ]] in
  Components.wrap_body ~toc:(Some [ toc ]) ~title:t.title ~body:page

let get_body t = t.body

let get_path t = t.path
