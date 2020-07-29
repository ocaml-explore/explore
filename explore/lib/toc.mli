type t = heading list

and heading = H of int * string  (** The type for table of contents *)

type 'a tree = Br of 'a * 'a tree list

val toc : Omd.doc -> t
(** [toc doc] will create a new table of contents from an Omd document *)

val transform : Omd.doc -> Omd.doc
(** [transform doc] will change the headers to be linkable *)

val to_html : t -> [< Html_types.li_content_fun > `A `Ul ] Tyxml.Html.elt
(** [to_html toc] generates a simple HTML table of contents *)

val to_tree : t -> heading tree
(** [to_tree ts] converts a linear list of headings to a tree structure, e.g.
    [\[1; 2; 3; 2\]] becomes [Br(1, \[Br(2, \[Br(3, \[\])\]); Br(2, \[\])\]] *)

val pre : Format.formatter -> heading tree -> unit
(** prints heading tree in preorder *)

val pp : Format.formatter -> t -> unit
(** The pretty printer *)

val equal : t -> t -> bool
(** [equal a b] checks if two table of contents are equal *)
