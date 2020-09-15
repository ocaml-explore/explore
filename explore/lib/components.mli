val wrap_body :
  toc:[< Html_types.object__content_fun > `PCDATA ] Tyxml_html.elt list option ->
  title:string ->
  description:string ->
  body:[< Html_types.object__content_fun > `PCDATA ] Tyxml_html.elt list ->
  Tyxml.Html.doc
(** [wrap_body toc title description body] will take some body content and wrap
    it in a standard HTML tag with a header (with the title and description) and
    also add the supplied table of contents *)

val make_link_list : (string * string) list -> [> Html_types.ul ] Tyxml.Html.elt
(** [make_link_list lst] will use the [(path, title)] of each element to form an
    unordered list of links to [path] with the text [title]*)

val make_index_list :
  (string * string list * string * string) list ->
  [> Html_types.div ] Tyxml.Html.elt
(** [make_index_list a b lst] will use the [(path, classes, title, description)]
    of each element to form an a div of links to [path] with the text [title]
    and p tag of description. *)

val make_sectioned_list :
  ([< Html_types.div_content_fun > `Div `PCDATA ] Tyxml.Html.elt
  * (string * string list * string * string) list)
  list ->
  [> Html_types.div ] Tyxml.Html.elt list
(** Creates a [make_index_list] separate by user-defined sections *)

val make_ordered_index_list :
  (string * string * string) list -> [> Html_types.ol ] Tyxml.Html.elt
(** [make_order_index_list a b lst] will use the [(path, title, description)] of
    each element to form an ordered list of links to [path] with the text
    [title] and a description. *)

val make_sectioned_ordered_list :
  ([< Html_types.div_content_fun > `Ol `PCDATA ] Tyxml.Html.elt
  * (string * string * string) list)
  list ->
  [> `Div | `Span ] Tyxml.Html.elt list
(** Creates a [make_order_index_list] separate by user-defined sections *)

val make_omd_title_date : title:string -> date:string -> Omd.doc
(** [make_omd_title_date title date] produces a heading 1 and italicized
    paragraph for the title and date respectively *)

val emit_page : string -> Tyxml.Html.doc -> unit
(** [emit_page path doc] will ouput the HTML ([doc]) to [path] *)

val make_title : string -> [> Html_types.h1 ] Tyxml.Html.elt
(** [make_title title] will produce <h1>\{title\}</h1> *)
