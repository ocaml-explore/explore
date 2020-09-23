open Js_of_ocaml

[@@@part "0"]

(* Defining the Person object type *)
class type person =
  object
    val name : Js.js_string Js.prop

    method printName : unit -> unit Js.meth
  end

[@@@part "1"]

let person : (Js.js_string Js.t -> person Js.t) Js.constr =
  Js.Unsafe.js_expr "Person"

let () =
  let v = new%js person (Js.string "Alice") in
  v##printName ()
