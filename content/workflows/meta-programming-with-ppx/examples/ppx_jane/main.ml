open Core

module Person = struct 
  type t = {
    name: string;
    age: int;
  } [@@deriving hash, sexp, compare]
end 

let () = 
  let tbl = Hashtbl.create (module Person) in 
  let alice : Person.t = { name = "Alice"; age = 42 } in 
    Hashtbl.add_exn tbl ~key:alice ~data:"1234"; 
    print_string (Hashtbl.find_exn tbl alice)