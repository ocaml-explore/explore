type err = [ `MalformedCollection of string ]

module type S = sig
  type t
  (** The type for Collections like a [Workflow] or a [User]... *)

  val v : path:string -> content:string -> t
  (** [v path content] takes the contents of a markdown file [content] and
      either produces a [result] of type [t] or an error of tpye [err] *)

  val build : unit
  (** A small program to be run through the CLI to build a new workflow *)
end

module Workflow : sig
  type resource = { title : string; description : string; url : string }

  type workflow = {
    title : string;
    date : string;
    authors : string list;
    description : string;
    tools : string list option;
    users : string list option;
    libraries : string list option;
    resources : resource list option;
  }
  [@@deriving yaml]

  type t = { path : string; data : workflow; body : string }

  include S with type t := t

  val to_html : t -> Tyxml.Html.doc
  (** Takes a constructed Collection [t] and produces the HTML document *)
end

module type Collection = sig
  type t

  include S with type t := t

  val to_html_with_workflows : Workflow.t list -> t -> Tyxml.Html.doc
  (** Users, Libraries and Tools all have related to workflows *)

  val build_index : string -> string -> t list -> Tyxml.Html.doc
  (** [build_index title description ts] will build a page with [ts] listed on
      it adding the [title] and [description] to the HTML meta data *)

  val get_workflows : t -> Workflow.t list -> Workflow.t list
  (** A function to get the workflows which are related to a given collection *)
end

module User : sig
  type user = {
    title : string;
    date : string;
    description : string;
    workflows : string list;
  }

  type t = { path : string; data : user; body : string }

  include Collection with type t := t
end

module Tool : sig
  type tool = {
    title : string;
    repo : string;
    license : string;
    date : string;
    description : string;
  }

  type t = { path : string; data : tool; body : string }

  include Collection with type t := t
end

module Library : sig
  type library = {
    title : string;
    repo : string;
    date : string;
    description : string;
  }

  type t = { path : string; data : library; body : string }

  include Collection with type t := t
end
