type i_list = int list [@@deriving stringify]

type b_list = bool list [@@deriving stringify]

type i_list_list = int list list [@@deriving stringify]

let () =
  let i_lst = [ 1; 2; 3 ] in
  let b_lst = [ true; false; true ] in
  let i_lst_lst = [ [ 1; 2; 3 ]; [ 4; 5; 6 ] ] in
  print_endline (i_list_stringify i_lst);
  print_endline (b_list_stringify b_lst);
  print_endline (i_list_list_stringify i_lst_lst)
