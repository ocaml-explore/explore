type err = [ `Undefined of string ]

let fact n =
  let rec aux = function 0 -> 1 | n -> n * aux (n - 1) in
  match n with
  | n when n < 0 ->
      Error (`Undefined "Factorial is undefined for negative numbers")
  | n -> Ok (aux n)

let () = ()
