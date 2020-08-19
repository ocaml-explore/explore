open Ppxlib
open Ast_builder.Default

[@@@part "1"]

let get_tuple ~loc = function
  | { pexp_desc = Pexp_tuple [ key; value ]; _ } -> (key, value)
  | _ -> Location.raise_errorf ~loc "Expected a list of tuple pairs"

let rec handle_list ~loc = function
  | [%expr []] -> []
  | [%expr [%e? pair] :: [%e? tl]] ->
      let k, v = get_tuple ~loc pair in
      let add = [%expr fun tbl -> Hashtbl.add tbl [%e k] [%e v]] in
      let rest = handle_list ~loc tl in
      add :: rest
  | _ -> Location.raise_errorf ~loc "Expected a list of tuple pairs"

[@@@part "0"]

let rec expand ~ctxt expr =
  let loc = Expansion_context.Extension.extension_point_loc ctxt in
  match expr with
  | [%expr []] -> [%expr Hashtbl.create 10]
  | [%expr [%e? _pair] :: [%e? _]] ->
      let fun_list = handle_list ~loc expr in
      let len = List.length fun_list in
      [%expr
        Hashtbl.create [%e eint ~loc len] |> fun tbl ->
        List.iter (fun f -> f tbl) [%e elist ~loc fun_list];
        tbl]
  | _ -> Location.raise_errorf ~loc "Expected a list"

[@@@part "2"]

let my_extension =
  Extension.V3.declare "hashtbl" Extension.Context.expression
    Ast_pattern.(single_expr_payload __)
    expand

let rule = Ppxlib.Context_free.Rule.extension my_extension

let () = Driver.register_transformation ~rules:[ rule ] "hashtbl"
