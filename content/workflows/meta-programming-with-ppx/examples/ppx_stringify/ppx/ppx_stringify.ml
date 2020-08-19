open Ppxlib
open Ast_helper

[@@@part "0"]

let rec expr_of_type typ =
  let loc = typ.ptyp_loc in
  match typ with
  | [%type: int] -> [%expr string_of_int]
  | [%type: string] -> [%expr fun i -> i]
  | [%type: bool] -> [%expr string_of_bool]
  | [%type: float] -> [%expr string_of_float]
  | [%type: [%t? t] list] ->
      [%expr
        fun lst ->
          "["
          ^ List.fold_left
              (fun acc s -> acc ^ [%e expr_of_type t] s ^ ";")
              "" lst
          ^ "]"]
  | _ ->
      Location.raise_errorf ~loc "No support for this type: %s"
        (string_of_core_type typ)

[@@@part "1"]

let generate_impl ~ctxt (_rec_flag, type_decls) =
  let loc = Expansion_context.Deriver.derived_item_loc ctxt in
  List.map
    (fun typ_decl ->
      match typ_decl with
      | { ptype_kind = Ptype_abstract; ptype_manifest; _ } -> (
          match ptype_manifest with
          | Some t ->
              let stringify = expr_of_type t in
              let func_name =
                if typ_decl.ptype_name.txt = "t" then { loc; txt = "stringify" }
                else { loc; txt = typ_decl.ptype_name.txt ^ "_stringify" }
              in
              [%stri let [%p Pat.var func_name] = [%e stringify]]
          | None ->
              Location.raise_errorf ~loc "Cannot derive anything for this type"
          )
      | _ -> Location.raise_errorf ~loc "Cannot derive anything for this type")
    type_decls

[@@@part "2"]

let impl_generator = Deriving.Generator.V2.make_noarg generate_impl

let stringify = Deriving.add "stringify" ~str_type_decl:impl_generator
