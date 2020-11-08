open Owl.Dense
module IntArr = Ndarray.Generic

let () =
  let open Owl.Arr in
  let arr1 = Ndarray.Generic.ones Int64 [| 5; 5 |] in
  let arr2 = Ndarray.Generic.ones Int64 [| 5; 5 |] in
  Ndarray.Generic.pp_dsnda Format.std_formatter (arr1 + arr2)
