type t
(** The type for standalone pages *)

val v : path:string -> content:string -> t

val to_html : t -> Tyxml.Html.doc

val get_path : t -> string

val get_body : t -> string
