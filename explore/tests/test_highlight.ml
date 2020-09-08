open Explore

let omd =
  Alcotest.testable
    (fun ppf t -> Format.fprintf ppf "%s" (Omd.to_html t))
    Stdlib.( = )

(* A little fragile -- formatting the html string will break the test *)
let test_transform () =
  let md = Files.read_file "highlight.md" in
  let omd_t = Omd.of_string md |> Highlight.transform in
  let correct : Omd.block = ({bl_desc = Omd.Html_block {|<pre><code><span class="ocaml-keyword">let </span><span class="ocaml-entity-name">f</span><span class="ocaml-source"> </span><span class="ocaml-source">a</span><span class="ocaml-source"> </span><span class="ocaml-source">b</span><span class="ocaml-source"> </span><span class="ocaml-keyword-operator">=</span><span class="ocaml-source"> </span><span class="ocaml-source">a</span><span class="ocaml-source"> </span><span class="ocaml-keyword-operator">+</span><span class="ocaml-source"> </span><span class="ocaml-source">b</span><span class="ocaml-source"> 
</span></code></pre>|}; bl_attributes = []})[@@ocamlformat "disable"] in 
  Alcotest.check omd "same omd"
    [correct]
    omd_t

let tests = [ ("test_transform", `Quick, test_transform) ]
