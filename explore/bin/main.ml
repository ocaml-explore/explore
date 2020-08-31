open Core

let command =
  Core.Command.basic
    ~summary:
      "🐫🐫🐫  Explore - a tool for building OCaml Explore  🐫🐫🐫"
    Core.Command.Let_syntax.(
      let%map_open mode = anon (maybe ("mode - <build|time>" %: string))
      and _output =
        flag "-o"
          (optional_with_default "notion" string)
          ~doc:"folder for exported folder"
      in
      fun () ->
        match mode with
        | Some "serve" -> Serve.serve ~port:8000
        | Some "build" -> Make.build_phase ()
        | Some "time" -> (
            Ptime.of_float_s (Unix.gettimeofday ()) |> function
            | Some t -> Ptime.pp Format.std_formatter t
            | None -> print_endline "Could not get the time")
        | _ -> print_endline "Please specify either to build or time")

let () = Core.Command.run command
