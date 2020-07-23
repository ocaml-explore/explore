val wrap_body :
  title:string ->
  body:[< Html_types.object__content_fun > `PCDATA ] Tyxml_html.elt list ->
  Tyxml.Html.doc

val emit_page : string -> Tyxml.Html.doc -> unit
