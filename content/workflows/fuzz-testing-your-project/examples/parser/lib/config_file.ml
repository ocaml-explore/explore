open Base

type t = (string * string) list

let parse_line s =
  match String.split s ~on:'=' with
  | [] -> None
  | [key;value] -> Some (key, value)
  | _ -> assert false

let parse s =
  String.split s ~on:'\n'
  |> List.map ~f:parse_line
  |> Option.all
