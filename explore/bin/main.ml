open Cmdliner

let cmds = [ Build.cmd; Serve.cmd; New.cmd; Lint.cmd ]

let setup_std_outputs : unit = Fmt_tty.setup_std_outputs ()

let doc = "Explore OCaml CLI tool"

let main = (fst Build.cmd, Term.info "explore" ~doc)

let main () = Term.(exit_status @@ eval_choice main cmds)

let () = main ()
