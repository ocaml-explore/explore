val src_code_to_html :
  string ->
  string ->
  ([> Html_types.span ] Tyxml_html.elt list list, string) result
(** [src_code_to_html lang code] will highlight [code] in language [lang] *)
