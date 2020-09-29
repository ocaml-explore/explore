module Float = struct
  type t = float

  let print : t -> unit = print_float
end

module Int = struct
  type t = int

  let print : t -> unit = print_int
end
