module type S = sig
  type t
  (** Collections are either a workflow or the others. Workflows contain more
      metadata than other collections hence the distinction - metadata for
      collections like users and libraries can be built from the workflows. They
      do share some common functions *)

  val v : path:string -> content:string -> t

  val to_string : t -> string

  val get_meta : t -> Jekyll_format.fields

  val get_title : t -> string

  val get_md : t -> string

  val get_path : t -> string

  val get_prop : coll:t -> ident:string -> Yaml.value option

  val get_description : t -> string

  val to_html : t -> Tyxml.Html.doc

  val build_index : string -> t list -> Tyxml.Html.doc
  (** [build_index ts] builds the index page for a list of collection items [ts] *)

  val get_relations :
    string -> t -> (Yaml.value list, [> `Msg of string ]) Result.t
end

module Workflow : sig
  include S
end

module type Collection = sig
  include S

  val to_html_with_workflows : Workflow.t list -> t -> Tyxml.Html.doc

  val get_workflows : t -> Workflow.t list -> Workflow.t list
end

module User : Collection

module Library : Collection

module Platform : Collection
