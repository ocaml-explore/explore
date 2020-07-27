open Tyxml
open Core

let nav_bar () =
  [%html
    {|
  <div class="pure-g">
    <div class="pure-u-1-3">
      <a class="title-link" href="/">
        <h2 style="text-align: center">Explore OCaml</h2>
      </a>
    </div>
    <div class="pure-u-1-3">
    </div>
    <div class="pure-u-1-3 flex-col flex-vert">
      <div class="flex-row flex-center">
        <div class="nav-button">
          <a href="/platform">
            Tools 
          </a>
        </div>
        <div class="nav-button">
          <a href="/users">
            Users
          </a>
        </div>
        <div class="nav-button">
          <a href="/libraries">
          Libraries
          </a>
        </div>
      </div>
    </div>
  </div>
|}]

let make_title title = [%html "<h1>" [ Html.txt title ] "</h1>"]

let wrap_body ~title ~body =
  [%html
    {|
  <html>
    <head>
      <title>|} (Html.txt title)
      {|</title>
      <meta name = "viewport" content = "width = device-width, initial-scale = 1">
      <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono&family=Ubuntu:ital,wght@0,400;0,700;1,400&display=swap" rel="stylesheet">
      <link rel="stylesheet" href="https://unpkg.com/purecss@2.0.0/build/base.css" />
      <link rel="stylesheet" href="https://unpkg.com/purecss@2.0.0/build/grids-core.css" />
      <link rel="stylesheet" href="https://unpkg.com/purecss@2.0.0/build/grids-units.css" />
      <link rel="stylesheet" href="https://unpkg.com/purecss@2.0.0/build/grids-responsive.css" />
      <link rel=stylesheet href="/static/css/main.css"/>
      <link rel="stylesheet"  href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.0.0/styles/gruvbox-dark.min.css">
      <script src="https://identity.netlify.com/v1/netlify-identity-widget.js"></script>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.0.0/highlight.min.js"></script>
      <script charset="UTF-8" src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.0.0/languages/ocaml.min.js"></script>
      <script>hljs.initHighlightingOnLoad();</script>
    </head>
    <body>|}
      [ nav_bar () ]
      {|
        <div class="pure-g">
          <div class="pure-u-1-12 pure-u-md-1-4">
          </div>
          <div class="pure-u-5-6 pure-u-md-1-2">
        |}
      body {| 
          </div>
        </div>
    </body>
  </html>
|}]

let make_link_list lst =
  let to_link (path, title) =
    [%html "<li><a href=" path ">" [ Html.txt title ] "</a></li>"]
  in
  [%html {|
  <ul>
    |} (List.map ~f:to_link lst) {|
  </ul>
|}]

let emit_page filename html =
  let outc = Out_channel.create filename in
  let fmt = Format.formatter_of_out_channel outc in
  Exn.protect
    ~f:(fun () -> Format.fprintf fmt "%a@." (Html.pp ~indent:true ()) html)
    ~finally:(fun () -> Out_channel.close outc)
