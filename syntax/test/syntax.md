# Testing Syntax Highlighting 

```ocaml env=ocaml 
# #require "tyxml,syntax"
# let err = function Ok t -> t | _ -> failwith "Error" 
val err : ('a, 'b) result -> 'a = <fun>
# let print lang src = List.iter (List.iter (Tyxml.Html.pp_elt () Format.std_formatter)) (err (Syntax.src_code_to_html lang src))
val print : string -> string -> unit = <fun>

# print "ocaml" "let x = 42"
entity name function binding ocaml
<span id="ocaml-keyword">let </span><span id="ocaml-other">x</span><span id="ocaml-source"> </span><span id="ocaml-keyword-operator">=</span><span id="ocaml-source"> </span><span id="ocaml-constant-numeric">42</span><span id="ocaml-source">
</span>
- : unit = ()
# print "dune" "(executable (name main))"
<span id="dune-meta-stanza">(</span><span id="dune-meta-class-stanza">executable</span><span id="dune-meta-stanza"> </span><span id="dune-meta-stanza-library-field">(</span><span id="dune-keyword">name</span><span id="dune-meta-stanza-library-field"> </span><span id="dune-meta-stanza-library-field">main</span><span id="dune-meta-stanza-library-field">)</span><span id="dune-meta-stanza">)</span><span id="dune-source">
</span>
- : unit = ()
# print "opam" "opam-version: \"2.0\""
<span id="opam-entity-name-tag">opam-version</span><span id="opam-keyword-operator">:</span><span id="opam-source"> </span><span id="opam-string-quoted">&quot;</span><span id="opam-string-quoted">2.0</span><span id="opam-string-quoted">&quot;</span><span id="opam-source">
</span>
- : unit = ()
```
