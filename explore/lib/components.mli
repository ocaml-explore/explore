val wrap_body :
  title:string ->
  body:[< Html_types.object__content_fun > `PCDATA ] Tyxml_html.elt list ->
  Tyxml.Html.doc
(** [wrap_body title body] will take some body content and wrap it in a standard
    HTML tag with a header *)

val make_link_list : (string * string) list -> [> Html_types.ul ] Tyxml.Html.elt
(** [make_link_list lst] will use the [(path, title)] of each element to form an
    unordered list of links to [path] with the text [title]*)

val emit_page : string -> Tyxml.Html.doc -> unit
(** [emit_page path doc] will ouput the HTML ([doc]) to [path] *)

val make_title : string -> [> Html_types.h1 ] Tyxml.Html.elt
(** [make_title title] will produce <h1>{title}</h1> *)
