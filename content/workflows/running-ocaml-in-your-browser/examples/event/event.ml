[@@@part "0"]
open Js_of_ocaml
open Lwt.Infix
module Events = Js_of_ocaml_lwt.Lwt_js_events
module Html = Dom_html

let add_handler id =
  let btn = Html.getElementById id in
  btn##.onclick :=
    Html.handler (fun _ ->
        print_endline "Clicked!";
        Js._false) 

[@@@part "1"]
let rec key_listener key =
  Events.keydown key >>= fun event ->
  if event##.keyCode = 32 then Lwt.return (print_endline "Key Pressed!")
  else key_listener key

[@@@part "2"]
let onload _ =
  add_handler "button";
  Js._false

let () =
  Html.window##.onload := Html.handler onload;
  Lwt.async (fun () -> key_listener Html.document)
