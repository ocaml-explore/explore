val read_and_build :
  build:(string * string -> 'a) ->
  check:(string -> bool) ->
  dir:string ->
  'a list
(** [read_collection build check dir] will apply [build] to the contents of each
    file in [dir] where [check file] is [true] *)

val build_page : file:string -> Page.t
