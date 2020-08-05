let () =
  let person =
    object%js (self)
      val name = "Alice" [@@readwrite]

      method set str = self##.name := str

      method get = self##.name
    end
  in
  print_endline person##get;
  person##set "Bob";
  print_endline person##get
