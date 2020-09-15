---
authors:
  - Patrick Ferris
title: Meta-programming with PPX 
date: 2020-08-19 15:08:11
description: Automate code-generation with meta-programming
users:
  - Library Authors
  - Application Developer
topic: 
  coding: 
    - true
tools:
  - ppxlib
  - dune
  - omp
resources: 
  - url: https://tarides.com/blog/2019-05-09-an-introduction-to-ocaml-ppx-ecosystem
    title: An Introduction to OCaml PPX Ecosystem
    description: Nathan Rebours gives a very detailed and excellently explained guide to writing your own ppx using ppxlib.
---

## Overview

Meta-programming is programming for programming. You can think of it as a program which works with another program as data. Ppx is the OCaml syntax extension allowing programmers to meta-program directly on the abstract syntax tree (AST) of OCaml code. This means simple tasks like writing comparison functions or hashing functions can be automated through clever inference on types. 

### The Abstract Syntax Tree 

Before diving into using a ppx or writing your own, it is important to understand the OCaml AST. Your program starts its life in OCaml's concrete syntax. This is the predefined set of strings which are given some semantic meaning in the OCaml world like `let ... in ...`. The first important job of the compiler is to render this as abstract syntax, a simpler internal representation of your program often structured as a labelled tree. 

As a tree data-structure, transformations become much easier. The purpose of a ppx is to move from one AST to another. The OCaml AST is called the [Parsetree](https://github.com/ocaml/ocaml/blob/trunk/parsing/parsetree.mli). Using this definition, let's find the AST for:

```ocaml
# let add_one a = a + 1 
val add_one : int -> int = <fun>
```

We can actually print the Parsetree using the OCaml compiler from the command line: `ocamlopt -dparsetree file.ml`. What follows is the Parsetree component for the `add_one` function. The `pexp` function takes a `Parsetree.expression_desc` and creates a `Parsetree.expression` by filling in details like attributes and location with dummy information to make the example more readable. `ppat` and `pvb` are similar functions for those types. 

<!-- $MDX file=examples/parsetree/main.ml,part=1 -->
```ocaml
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
```

If the tree structure does not reveal itself from the code, this greatly simplified diagram should help.

![The OCaml AST for let add_one x = x + 1](/images/parsetree.png)

Manipulating the tree structure is much simpler than working with text. A ppx works on these structures allowing you to access the information and perform transformations from one tree to another. 

## Recommended Workflow

--- 

### PPX 

Before we build ppx libraries, there are a few important, ppx-specific concepts to look at. Firstly is the difference between derivers and extensions.

#### Derivers

In our AST, derivers will add new nodes to the tree. They use information from types to generate something useful and add this to the tree. See the [using ppx libraries](#using-ppx-libraries) example where derivers like [`ppx_compare`](https://github.com/janestreet/ppx_compare/tree/master/src) builds comparison functions based on type signatures. 

#### Extension Rewriters

Extensions (rewriters) allow you to take part of an AST and rewrite (transform) it into a different, valid AST. Take for example the [Tyxml ppx](https://github.com/ocsigen/tyxml/tree/master/ppx) which allows you to write HTML directly in your OCaml code and convert it to the Tyxml HTML internal representation. 

```ocaml env=tyxml
# open Tyxml
# let s = "Hello World" 
val s : string = "Hello World"
# [%html "<h1>"[Html.txt s]"</h1>"]
- : [> Html_types.h1 ] Html5.elt = <abstr>
```

### Using PPX libraries

Dune comes with ppx support which makes it very easy to start using different ppx libraries to meta-program in OCaml. In this example we will define a new type of `person` and try to use it with the `Core.Hashtbl` module.

The Core implementation of a [hashtable expects](https://github.com/janestreet/base/blob/master/src/hashtbl_intf.ml#L425) an `'a Key.t` which should be a first-class module with hash, compare and s-expression functions. This is very common for Jane Street modules so they made ppxes to auto-generate such functions from type signatures. 

To generate these functions we label it with a type deriving attribute.

<!-- $MDX file=examples/ppx_jane/main.ml -->
```ocaml
open Core

module Person = struct 
  type t = {
    name: string;
    age: int;
  } [@@deriving hash, sexp, compare]
end 

let () = 
  let tbl = Hashtbl.create (module Person) in 
  let alice : Person.t = { name = "Alice"; age = 42 } in 
    Hashtbl.add_exn tbl ~key:alice ~data:"1234"; 
    print_string (Hashtbl.find_exn tbl alice)
```

The dune file will be:

<!-- $MDX file=examples/ppx_jane/dune -->
```
(executable
 (name main)
 (libraries core)
 (preprocess
  (pps ppx_jane)))
```

The `[@@deriving...]` attribute tells the compiler to insert new nodes derived from the type. For example, consider deriving the compare function. 

```ocaml
type t = { id : int } [@@deriving compare]
```

To see what the compiler is actually compiling we can add `(ocamlopt_flags (:standard -dsource))` to our dune file's executable stanza to print the actual compiled source code. With this, a simplified version of what we get is:

```ocaml
open Core
type t = {
  age: int }[@@deriving compare]
include
  struct
    let _ = fun (_ : t) -> ()
    let compare =
      (fun a__001_ ->
         fun b__002_ ->
           if Ppx_compare_lib.phys_equal a__001_ b__002_
           then 0
           else compare_int a__001_.age b__002_.age : t -> t -> int)
    let _ = compare
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
```

The main part being the new compare function which first uses physical equality before using integer equality on the integer record field of our type. 

### Writing a Ppx Deriver

To write your own ppx library you are strongly encouraged to use [`ppxlib`](/libraries/ppxlib). It provides a wrapper around the compiler hooks that a ppx can use to modify the AST. The [user documentation](https://ppxlib.readthedocs.io/en/latest/) does a very good job at getting you started writing your own ppx libraries. 

One of the best ways to learn is by building. To start, we will build a simple deriver for turning OCaml types into strings. It will not be complete or perfect, but it should expose the right number of concepts to help you get started writing ppx libraries. 

As we have noted, a deriver is something that adds additional nodes to our AST based on the meta-programming information inferred from our types. A good deriver tends to be one where you can almost imagine writing all of the functions by hand and you just want to crank the wheel and turn them out. One example would be generating string producing functions for OCaml types. 

Here are a few that might feel obvious: 

```ocaml env=main
# string_of_int
- : int -> string = <fun>
# let int_list_stringify lst = "[" ^ List.fold_left (fun acc s -> acc ^ (string_of_int s) ^ ";") "" lst ^ "]"
val int_list_stringify : int list -> string = <fun>
# int_list_stringify [1;2;3;4]
- : string = "[1;2;3;4;]"
```

The tedium should be apparent, not to mention how (without supplying many different arguments) it would be difficult to add more `*_list_stringify` functions. 

This can be solved with a ppx which derives our stringify functions straight from the type definitions. For succinctness, we will focus on making functions for simple types like `int` and `t list`.

#### From types to expressions

The cornerstone of our ppx will be a function, `expr_of_type : Ppxlib.core_type -> Ppxlib.expression`. Note that these are aliases to the `Parsetree` definitions in the compiler. Actually trying to reconstruct a [`core_type`](https://github.com/ocaml/ocaml/blob/trunk/parsing/parsetree.mli#L82) or an [`expression`](https://github.com/ocaml/ocaml/blob/trunk/parsing/parsetree.mli#L259) by hand is doable, but accident prone and will quickly fill up your file making it hard to read and find bugs. Luckily, we can use `Ppxlib.metaquot`. 

Metaquot is a ppx for writing ppxes. It allows you to write valid OCaml syntax and transform it into the `Parsetree` equivalent using the preprocessor. This is useful in building up large and complex AST components.  

```ocaml env=ppx
# #require "ppxlib,ppxlib.metaquot" 
# open Ppxlib
# let loc = !Ast_helper.default_loc in [%expr 23]
- : expression =
{pexp_desc = Pexp_constant (Pconst_integer ("23", None));
 pexp_loc =
  {loc_start =
    {pos_fname = "_none_"; pos_lnum = 0; pos_bol = 0; pos_cnum = -1};
   loc_end = {pos_fname = "_none_"; pos_lnum = 0; pos_bol = 0; pos_cnum = -1};
   loc_ghost = true};
 pexp_loc_stack = []; pexp_attributes = []}
```

The three main metaquot extensions are: 
1. `[%expr]` - for building expressions like functions 
2. `[%pat]` - for building patterns for things like function arguments 
3. `[%type:]` - for building types 

We can build our `expr_of_type` function by pattern-matching on different types (using `[%type ...]`) and producing the right **stringifying** functions (using `[%expr...]`). 

```ocaml file=examples/ppx_stringify/ppx/ppx_stringify.ml,part=0
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
```

The first thing to notice is the definition of the `loc` variable. Most `Parsetree` types have some meta-information including their location for things like better error messages. As we build new expressions we need to supply a good location so that ppx-induced errors are also useful. `[%expr...]` expects a location to be called `loc` to be available. 

After this we match are type declaration with types we are interested in. For example, `int` produces a function which is really just `string_of_int`. This is similar for `bool`, `float` and `string`. 

The more interesting example is list. It has some additional type to describe the elements. Note this isn't a type variable `'a` here, this is a statically known element like `int list` or `float list` (later we'll talk a little about handling the `'a` case). We use the `[%t? t]` to extract that type. 

From here it builds one of the many possible ways you could 'stringify' a list. Note the recursive call in the `fold_left` function to `expr_of_type` supplying it with the element type of the list. Like the `[%t...]` syntax, `[%e...]` within an `[%expr...]` is like a hole where you can supply things of type `expression` and the preprocessor will just leave them be.

#### Building a structure

Once we're happy with the functions we are generating we need to register the deriver. Ppxlib provides a lot of functions to make this easy. Firstly, we'll use `Deriving.Generator.V2.make_noarg` to make a `('output_ast, 'input_ast) Deriving.Generator.t`. In order to do so, we need to supply it with an implementation.

<!-- $MDX file=examples/ppx_stringify/ppx/ppx_stringify.ml,part=1 -->
```ocaml
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
```

`make_noarg` is expecting a function which takes an `Expansion_context` and an input AST which in this case will be a pair - a recursive flag which we can ignore and the type declarations. We need to produce a `structure_item list` which is essentially an OCaml program. We can do this with some help from metaquot again. 

Type declarations fall into four possible type kinds: 

1. `Ptype_abstract`: For types like `type t = int list`.
2. `Ptype_variants`: normal variants such as `type camel = Bactrian | Dromedary`. 
3. `Ptype_open`: used to mark types which are [extensible variants](http://caml.inria.fr/pub/docs/manual-ocaml/extensiblevariants.html).
4. `Ptype_record`: for record types, `type t = { name : string }`. 

For our very simple ppx we only care about the first, so we can pattern-match on only values that match this. The manifest is the actual types that come after the `=`. These are what we want to pass to our `expr_of_type` function to generate our function (`stringify`). We also need to provide a name for our function, to do this we simply take the name of our type and add the suffix `_stringify`. 
Conventionally if the name is `t` then you drop this and just use the suffix. 

Using the structure item generating ppx from metaquot (`[%stri]`) we finally generate the function with the correct name and the correct expression for the body. 

The final steps are just registering the ppx using functions provided by ppxlib. 

<!-- $MDX file=examples/ppx_stringify/ppx/ppx_stringify.ml,part=2 -->
```ocaml
let impl_generator = Deriving.Generator.V2.make_noarg generate_impl

let stringify = Deriving.add "stringify" ~str_type_decl:impl_generator
```

And a special dune file to mark our code as a ppx deriver, preprocess our files with `ppxlib.metaquot` and include `ppxlib`. 

<!-- $MDX file=examples/ppx_stringify/ppx/dune -->
```
(library
 (name ppx_stringify)
 (kind ppx_deriver)
 (libraries ppxlib)
 (preprocess
  (pps ppxlib.metaquot)))
```

### Writing a Ppx Extension Rewriter 

Instead of adding new nodes to an AST, we will now focus on rewriting them. The example we will use is turning association lists into hashtables. If you followed the deriver example there are many shared concepts. At the heart of this ppx will be a function `expand : Ppxlib.expression -> Ppxlib.expression`. 

A hashtable is just a key-value store with `O(1)` amortised access time and association lists are just key-value stores but with `O(n)` access time. Both have their use cases. `Ppx_hashtbl` will take an association list (e.g. `[("hello", 1)]`) and rewrite it as a hashtable using the standard library functions to do so. 

Again, it is worthwhile thinking how you might go about this in code. For empty lists we might just create an empty hashtable of size `10`. For non-empty lists, we need to check that it is indeed of type `('a * 'b) list` before creating a fresh hashtable and adding each key-value pair into it and finally returning that table for the programmer to use.

<!-- $MDX file=examples/ppx_hashtbl/ppx/ppx_hashtbl.ml,part=0 -->
```ocaml
let expand ~ctxt expr =
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
```

The main pattern-matching here finds the list where there is a head and tail. It passes the list expression to a separate `handle_list` function which returns a list of `Hashtbl.add` functions (skip ahead to see that function). We then produce an expression which creates a hashtable (the same length as the number of elements in the list), iterates over the add functions which expect a table to add the key-value pairs to and finally returns the table.

The use of `eint` and `elist` is from the `Ast_builder.Default` module making it easier to build expressions matching integers, lists etc. 

<!-- $MDX file=examples/ppx_hashtbl/ppx/ppx_hashtbl.ml,part=1 -->
```ocaml
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
```

The `get_tuple` function simple extracts key-value pairs from an expression that is a tuple and raises an error otherwise. The `handle_list` function builds the functions for adding elements to the hashtable.

This is the core of the ppx finished, all that is left is to register it, build it and use it. 

<!-- $MDX file=examples/ppx_hashtbl/ppx/ppx_hashtbl.ml,part=2 -->
```ocaml
let my_extension =
  Extension.V3.declare "hashtbl" Extension.Context.expression
    Ast_pattern.(single_expr_payload __)
    expand

let rule = Ppxlib.Context_free.Rule.extension my_extension

let () = Driver.register_transformation ~rules:[ rule ] "hashtbl"
```

The `declare` function lets us produce a new extension. It needs a label, the context which dictates what type of things we should be returning from our expander and then the pattern of inputs (here just an single expression). The final step is to convert the extension to a rule and register the transformation.

The following dune file will be sufficient to build our ppx rewriter.

<!-- $MDX file=examples/ppx_hashtbl/ppx/dune -->
```
(library
 (name ppx_hashtbl)
 (kind ppx_rewriter)
 (libraries ppxlib)
 (preprocess
  (pps ppxlib.metaquot)))
```

And here it is in use!

<!-- $MDX file=examples/ppx_hashtbl/example/main.ml -->
```ocaml
let () =
  let tbl = [%hashtbl [ ("Hello", 1) ]] in
  print_int (Hashtbl.find tbl "Hello")
```

## Real World Examples

---

There are lots of great ppx libraries. [Ppx_deriving_yojson](https://github.com/ocaml-ppx/ppx_deriving_yojson) allows you to generate json from OCaml types and convert json back to OCaml types and [ppx_deriving_protobuf](https://github.com/ocaml-ppx/ppx_deriving_protobuf) is very similar only for Google's [protocol buffers](https://developers.google.com/protocol-buffers/).

As already mentioned, Tyxml offer [rewriters](https://github.com/ocsigen/tyxml/tree/master/ppx) for building statically correct HTML in your OCaml files.
