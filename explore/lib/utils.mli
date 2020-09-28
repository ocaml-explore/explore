val get_time : unit -> string

val elt_to_string : 'a Tyxml_html.elt -> string
(** [elt_to_string elt] takes a Tyxml HTML element and prints it to a string *)

val code_to_html : string -> Omd.block list -> Omd.block list
(** [code_to_html filename bs] Converts code blocks to HTML blocks for a given
    set of Omd blocks -- it adds some additional features like source code links
    hence it is a different phase *)
