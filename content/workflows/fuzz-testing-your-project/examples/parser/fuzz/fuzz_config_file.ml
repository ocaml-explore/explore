let () =
  Crowbar.add_test [Crowbar.bytes] (fun s ->
    let _ : Config_file.t option = Config_file.parse s in
    ())
