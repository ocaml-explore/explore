let () =
  if Array.length Sys.argv < 2 then print_endline "Need to supply a number"
  else print_int (int_of_string Sys.argv.(1) + 1)
