let get_time () =
  Ptime.of_float_s (Unix.gettimeofday ()) |> function
  | Some t ->
      Ptime.pp Format.str_formatter t;
      Format.flush_str_formatter ()
  | None -> "2020-09-01 11:15:30 +00:00"

let elt_to_string elt =
  let open Tyxml in
  Format.(fprintf str_formatter "%a\n" (Html.pp_elt ()) elt);
  Format.flush_str_formatter ()
