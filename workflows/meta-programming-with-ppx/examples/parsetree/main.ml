[@@@part "0"]

open Parsetree
open Asttypes

let fake_position : Location.t =
  {
    loc_start = Lexing.dummy_pos;
    loc_end = Lexing.dummy_pos;
    loc_ghost = false;
  }

let pexp p =
  {
    pexp_desc = p;
    pexp_loc = fake_position;
    pexp_loc_stack = [];
    pexp_attributes = [];
  }

let pvb pat expr =
  {
    pvb_pat = pat;
    pvb_expr = expr;
    pvb_attributes = [];
    pvb_loc = fake_position;
  }

let ppat p =
  {
    ppat_desc = p;
    ppat_loc = fake_position;
    ppat_loc_stack = [];
    ppat_attributes = [];
  }

[@@@part "1"]

let (p : structure) =
  [
    {
      pstr_desc =
        Pstr_value
          ( Nonrecursive,
            [
              pvb
                (ppat (Ppat_var { txt = "f"; loc = fake_position }))
                (pexp
                   (Pexp_fun
                      ( Nolabel,
                        None,
                        ppat (Ppat_var { txt = "a"; loc = fake_position }),
                        pexp
                          (Pexp_apply
                             ( pexp
                                 (Pexp_ident
                                    {
                                      txt = Longident.Lident "+";
                                      loc = fake_position;
                                    }),
                               [
                                 ( Nolabel,
                                   pexp
                                     (Pexp_ident
                                        {
                                          txt = Longident.Lident "a";
                                          loc = fake_position;
                                        }) );
                                 ( Nolabel,
                                   pexp
                                     (Pexp_constant (Pconst_integer ("1", None)))
                                 );
                               ] )) )));
            ] );
      pstr_loc = fake_position;
    };
  ]
