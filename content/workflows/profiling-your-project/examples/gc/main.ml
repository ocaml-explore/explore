[@@@part "0"]
let alloc n =
  let lst_lst = List.init n (fun i -> List.init i (fun j -> string_of_int j)) in
  let lst_lst =
    List.map (fun lst -> List.map (fun s -> "Hello " ^ s) lst) lst_lst
  in
  lst_lst

[@@@part "1"]
let () =
  let _lst : string list list = alloc 10 in
  Gc.print_stat stdout
