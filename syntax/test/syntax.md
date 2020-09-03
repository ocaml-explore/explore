# Testing Syntax Highlighting 

```ocaml env=ocaml 
# #require "tyxml,syntax"
# let err = function Ok t -> t | _ -> failwith "Error" 
val err : ('a, 'b) result -> 'a = <fun>
# let print lang src = List.iter (List.iter (Tyxml.Html.pp_elt () Format.std_formatter)) (err (Syntax.src_code_to_html lang src))
val print : string -> string -> unit = <fun>

# print "ocaml" "let x = 42"
<span class="ocaml-keyword">let </span><span class="ocaml-entity-name">x</span><span class="ocaml-source"> </span><span class="ocaml-keyword-operator">=</span><span class="ocaml-source"> </span><span class="ocaml-constant-numeric">42</span><span class="ocaml-source">
</span>
- : unit = ()
# print "dune" "(executable (name main))"
<span class="dune-meta">(</span><span class="dune-meta">executable</span><span class="dune-meta"> </span><span class="dune-meta">(</span><span class="dune-keyword">name</span><span class="dune-meta"> </span><span class="dune-meta">main</span><span class="dune-meta">)</span><span class="dune-meta">)</span><span class="dune-source">
</span>
- : unit = ()
# print "opam" "opam-version: \"2.0\""
<span class="opam-entity-name">opam-version</span><span class="opam-keyword-operator">:</span><span class="opam-source"> </span><span class="opam-string-quoted">&quot;</span><span class="opam-string-quoted">2.0</span><span class="opam-string-quoted">&quot;</span><span class="opam-source">
</span>
- : unit = ()
```
