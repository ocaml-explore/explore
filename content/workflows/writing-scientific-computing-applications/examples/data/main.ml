open Owl

let () =
  let open Dataframe in
  let csv = of_csv "data.csv" in
  Owl_pretty.pp_dataframe Format.std_formatter csv;
  (* Print the first row's kind *)
  Format.(
    fprintf std_formatter "\n==== %s ====" (unpack_string csv.%((0, "kind"))));
  let is_functional arr = function "functional" -> Some arr | _ -> None in
  let keep_functional =
    filter_map_row (fun arr -> is_functional arr (unpack_string arr.(2))) csv
  in
  Owl_pretty.pp_dataframe Format.std_formatter keep_functional
