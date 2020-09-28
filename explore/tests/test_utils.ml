open Explore

let test_code_to_html () =
  let md = "<!-- $MDX file=examples/lib -->\n```ocaml\nlet () = ()\n```" in
  let test = Utils.code_to_html "my-file" (Omd.of_string md) in
  let correct : Omd.block list = [{ bl_desc = Omd.Html_block "<div><div><p class=\"toolbar\"><a href=\"https://github.com/ocaml-explore/explore/tree/trunk/content/workflows/my-file/examples/lib\">Source Code</a></p></div><pre><code class=\"language-ocaml\">let () = ()
</code></pre>
</div>"; bl_attributes = []}] [@@ocamlformat "disable"] in
  let pp ppf b = Format.pp_print_string ppf (Omd.to_sexp b) in
  let omd = Alcotest.testable pp Stdlib.( = ) in
  Alcotest.check omd "same omd" correct test

let tests = [ ("test_code_to_html", `Quick, test_code_to_html) ]
