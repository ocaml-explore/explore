(* This example is the alloc from the Sandmark test suite *)
(* https://github.com/ocaml-bench/sandmark/blob/77ec0e5f85a21b7e5ae46939e17a8a022740fb61/benchmarks/simple-tests/alloc.ml *)
[@@@part "1"]
let iterations = try int_of_string Sys.argv.(1) with _ -> 1_000_000

type a_mutable_record = { an_int : int; mutable a_string : string ; a_float: float } 

let rec create f n =
  match n with 
  | 0 -> ()
  | _ -> let _ = f () in
    create f (n - 1)

let () = for _ = 0 to iterations do
  Sys.opaque_identity create (fun () -> { an_int = 5; a_string = "foo"; a_float = 0.1 }) 1000
done
