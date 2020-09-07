---
title: Utop
date: 2020-07-27 09:35:49
description: OCaml's Universal Toplevel
license: 3-Clause BSD
repo: https://github.com/ocaml-community/utop
---

## Overview

[Utop](https://github.com/ocaml-community/utop) is the *universal top-level* for OCaml. It is essentially a *read-evaluate-print* loop which makes it great for prototyping functions, learning OCaml and checking type signatures. It can be installed using opam with `opam install utop`. 

## Key Concepts

Utop is much more than just a learning tool - it can help any OCaml programmer discover type signatures and prototype new ideas quickly without having to build a full program. Some of the most useful directives are: 

```ocaml
(* load external packages *)
utop # #require "omd" 

(* load source files providing dependent packages are loaded *)
utop # #use "src/utils.ml" 
```

With packages loaded into the toplevel we can explore them to help speed up are development process when using them, for example if we wished to know what all of the exposed functions and types are for the `Omd` module we can run `#show omd` . For specific functions we can just print them.

```ocaml
(* load omd *)
utop # #require "omd"

(* see type signature of the of_channel function *)
utop # Omd.of_channel;;
- : in_channel -> Omd.doc = <fun>

(* see what the doc type aliases *)
utop # #show Omd.doc;; 
- : type nonrec doc = Omd.block list
```

This process is much faster and smoother than checking the online documentation or the source code. It also prints the return types of functions which is especially useful when you move beyond the primitive types like `float` and `int`.

```ocaml
(* see what the doc type aliases *)
utop # Omd.of_string "[OCaml](https://ocaml.org/)"
- : Omd.doc =
[{Omd.bl_desc =
   Omd.Paragraph
    {Omd.il_desc =
      Omd.Link
       {Omd.label = {Omd.il_desc = Omd.Text "OCaml"; il_attributes = []};
        destination = "https://ocaml.org/"; title = None};
     il_attributes = []};
  bl_attributes = []}]
```

This can help you make sure functions return the types you expect instead of having to find the pretty printer and add print statements over parts of your code you want to inspect.
