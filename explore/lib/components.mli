val wrap_body :
  title:string ->
  body:[< Html_types.object__content_fun > `PCDATA ] Tyxml_html.elt list ->
  Tyxml.Html.doc
(** [wrap_body title body] will take some body content and wrap it in a standard
    HTML tag with a header *)

val make_link_list : (string * string) list -> [> Html_types.ul ] Tyxml.Html.elt
(** [make_link_list lst] will use the [(path, title)] of each element to form an
    unordered list of links to [path] with the text [title]*)

val make_index_list :
  (string * string * string) list -> [> Html_types.div ] Tyxml.Html.elt
(** [make_index_list a b lst] will use the [(path, title, description)] of each
    element to form an a div of links to [path] with the text [title] and p tag
    of description. *)

val emit_page : string -> Tyxml.Html.doc -> unit
(** [emit_page path doc] will ouput the HTML ([doc]) to [path] *)

val make_title : string -> [> Html_types.h1 ] Tyxml.Html.elt
(** [make_title title] will produce <h1>{title}</h1> *)
