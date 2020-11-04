let () =
  let tbl = [%hashtbl [ ("Hello", 1) ]] in
  print_int (Hashtbl.find tbl "Hello")
