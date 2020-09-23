let person =
    object%js (self)
      val name = "Alice" [@@readwrite]
      method get = self##.name
      method set str = self##.name := str
    end

let () = 
  print_endline person##get;
  person##set "Bob";
  print_endline person##get
