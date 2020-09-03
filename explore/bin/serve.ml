open Httpaf
open Lwt.Infix
open Httpaf_lwt_unix
open Fmt

let info ppf = pf ppf "[explore.ocaml] %a \n%!"

let router ?(top_dir = "content") =
  let open Explore in
  function
  | [ ""; "" ] | [ "" ] | [ "/" ] ->
      Files.read_file ("./" ^ top_dir ^ "/index.html")
  | f -> (
      let path = "./" ^ top_dir ^ String.concat "/" f in
      try Files.read_file path
      with Sys_error _ -> Files.read_file (path ^ "/index.html"))

let get_content_type s =
  let ct s = ("Content-Type", s) in
  match Filename.extension s with
  | ".html" -> ct "text/html"
  | ".css" -> ct "text/css"
  | ".js" -> ct "text/javascript"
  | ".png" -> ct "image/png"
  | ".jpg" | ".jpeg" -> ct "image/jpeg"
  | ".svg" -> ct "image/svg+xml"
  | _ -> ct "text/html"

let handle_get reqd =
  match Reqd.request reqd with
  | { Request.meth = `GET; Request.target = t; _ } ->
      Build.build_phase ();
      let str = router (String.split_on_char '/' t) in
      let resp =
        let content_type = get_content_type t in
        Response.create
          ~headers:
            (Headers.of_list
               [
                 content_type;
                 ("Content-length", string_of_int (String.length str));
               ])
          `OK
      in
      info stdout (fun ppf t -> pf ppf "Handling GET request: %s" t) t;
      Reqd.respond_with_string reqd resp str
  | _ ->
      let headers = Headers.of_list [ ("connection", "close") ] in
      Reqd.respond_with_string reqd
        (Response.create ~headers `Method_not_allowed)
        ""

let error_handler ?request:_ error start_response =
  let response_body = start_response Headers.empty in
  (match error with
  | `Exn exn ->
      Body.write_string response_body (Base.Exn.to_string exn);
      Body.write_string response_body "\n"
  | #Status.standard as error ->
      Body.write_string response_body (Status.default_reason_phrase error));
  Body.close_writer response_body

let serve port : int =
  info stdout
    (fun ppf a -> pf ppf "Starting server at: http://localhost:%i" a)
    port;
  let promise, _resolver = Lwt.wait () in
  let request_handler (_ : Unix.sockaddr) = handle_get in
  let error_handler (_ : Unix.sockaddr) = error_handler in
  let localhost = Unix.inet_addr_loopback in
  Lwt.async (fun () ->
      Lwt_io.establish_server_with_client_socket
        (Unix.ADDR_INET (localhost, port))
        (Server.create_connection_handler ~request_handler ~error_handler)
      >|= fun _ -> ());
  Lwt_main.run promise

(* Command Line Tool *)
open Cmdliner

let run port = serve port

let port =
  let docv = "PORT" in
  let doc = "Specifiy the port the local server should run on." in
  Arg.(value & pos 0 int 8000 & info ~doc ~docv [])

let info =
  let doc =
    "Run a local server which serves the contents of content. It rebuilds the \
     entire site for each page load so changes made will be automatically \
     synced."
  in
  Term.info ~doc "serve"

let cmd = (Term.(pure run $ port), info)
