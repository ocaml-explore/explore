open Tyxml
open Core

let nav_bar () =
  [%html {|
    <div class="pure-g">
      <div class="pure-u-1-3">
        <a class="title-link" href="/">
          <h2 style="text-align: center">Explore OCaml</h2>
        </a>
      </div>
      <div class="pure-u-1-3"></div>
        <nav class="pure-hidden-xs pure-hidden-sm pure-u-1-3 flex-col flex-vert">
          <ul class="flex-row flex-center nav-ul">
            <li class="nav-button">
              <a href="/platform">
                Tools 
              </a>
            </li>
            <li class="nav-button">
              <a href="/users">
                Users
              </a>
            </li>
            <li class="nav-button">
              <a href="/libraries">
                Libraries
              </a>
            </li>
          </ul>
        </nav>
        <nav class="pure-hidden-md pure-hidden-lg pure-hidden-xl pure-menu pure-menu-horizontal flex-col flex-vert pure-u-1-3">
          <ul class="pure-menu-list" style="text-align: center">
            <li class="pure-menu-item pure-menu-has-children pure-menu-allow-hover">
            <a href="#" id="menuLink1" class="pure-menu-link">Menu</a>
            <ul class="pure-menu-children mob-menu-list">
                <li class="pure-menu-item mob-menu-item">
                  <a href="/platform">
                    Tools 
                  </a>
                </li>
                <li class="pure-menu-item mob-menu-item">
                  <a href="/users">
                    Users
                  </a>
                </li>
                <li class="pure-menu-item mob-menu-item">
                  <a href="/libraries">
                  Libraries
                  </a>
                </li>
              </ul>
            </li>
          </ul>
        </nav>
    </div>
  |}] [@@ocamlformat "disable"]

let make_title title = [%html "<h1>" [ Html.txt title ] "</h1>"]

let wrap_body ~toc ~title ~description ~body =
  let toc = match toc with None -> [] | Some t -> t in
  [%html
    {|
  <html lang="en">
    <head>
      <title>|} (Html.txt title)
      {|</title>
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <meta charset="utf-8">
      <meta name="description" content="|}
      description
      {|">
      <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono&family=Ubuntu:ital,wght@0,400;0,700;1,400&display=swap" rel="stylesheet">
      <link rel="stylesheet" href="https://unpkg.com/purecss@2.0.0/build/base.css" />
      <link rel="stylesheet" href="https://unpkg.com/purecss@2.0.0/build/grids-core.css" />
      <link rel="stylesheet" href="https://unpkg.com/purecss@2.0.0/build/grids-units.css" />
      <link rel="stylesheet" href="https://unpkg.com/purecss@2.0.0/build/grids-responsive.css" />
      <link rel="stylesheet" href="https://unpkg.com/purecss@2.0.0/build/menus-core.css" />
      <link rel="stylesheet" href="https://unpkg.com/purecss@2.0.0/build/menus-dropdown.css" />
      <link rel=stylesheet href="/css/main.css"/>
      <link rel="stylesheet"  href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.0.0/styles/gruvbox-dark.min.css">
      <script src="https://identity.netlify.com/v1/netlify-identity-widget.js"></script>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.0.0/highlight.min.js"></script>
      <script charset="UTF-8" src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.0.0/languages/ocaml.min.js"></script>
      <script>hljs.initHighlightingOnLoad();</script>
    </head>
    <body>
      <header>
        <a class="skip-to-content" href="#main"> Skip to main content </a>|}
        [ nav_bar () ]
        {|
      </header>
        <div class="pure-g">
          <div class="pure-u-1-12 pure-u-md-1-4">
            <div class="pure-hidden-xs pure-hidden-sm pure-hidden-md toc-container sticky">|}
              toc
          {|</div>
          </div>
          <div class="pure-u-5-6 pure-u-md-1-2">
            <main id="main"> |}
              body
          {|</main>
          </div>
        </div>
    </body>
  </html>
|}] [@@ocamlformat "disable"]

let make_omd_title_date ~title ~date =
  Omd.of_string ("# " ^ title ^ "\n*Last Updated: " ^ date ^ "*\n\n")

let make_link_list lst =
  let to_link (path, title) =
    [%html "<li><a href=" path ">" [ Html.txt title ] "</a></li>"]
  in
  [%html {|
  <ul>
    |} (List.map ~f:to_link lst) {|
  </ul>
|}]

let make_index_list lst =
  let to_elt (path, classes, title, description) =
    [%html
      "<a class='index-a' href=" path "><div class='" ("index-div" :: classes)
        "'><h3 style='margin-top: revert'>" [ Html.txt title ] "</h3><p>"
        [ Html.txt description ] "</p></div></a>"]
  in
  [%html {|
    <div>
      |} (List.map ~f:to_elt lst) {|
    </div>
  |}]

let make_sectioned_list lst =
  let section (d, lst) =
    [%html {|
  <div> |} [ d ] {|
    |} [ make_index_list lst ] {|
  </div>
|}]
  in
  List.map ~f:section lst

let make_ordered_index_list lst =
  let to_elt (path, title, description) =
    [%html
      "<li class='ordered-list'><a class='index-a' href=" path ">"
        [ Html.txt title ] " </a> - " [ Html.txt description ] "</li>"]
  in
  [%html
    {|
        <ol>
          |}
      (List.map ~f:to_elt lst)
      {|
        </ol>
      |}]

let make_sectioned_ordered_list lst =
  let section (d, lst) =
    if List.is_empty lst then [%html "<span></span>"]
    else
      [%html
        {|
    <div> |}
          [ d ]
          {|
      |}
          [ make_ordered_index_list lst ]
          {|
    </div>
  |}]
  in
  List.map ~f:section lst

let emit_page filename html =
  let outc = Out_channel.create filename in
  let fmt = Format.formatter_of_out_channel outc in
  Exn.protect
    ~f:(fun () -> Format.fprintf fmt "%a@." (Html.pp ~indent:true ()) html)
    ~finally:(fun () -> Out_channel.close outc)
