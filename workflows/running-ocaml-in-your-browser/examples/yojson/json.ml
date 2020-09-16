open Core

[@@@part "0"]
type person = { name : string; age : int } [@@deriving yojson]

type db = person list [@@deriving yojson]

[@@@part "1"]
let () =
  let db_string = In_channel.read_all "db.json" in
  let db = Yojson.Safe.from_string db_string in
  match db_of_yojson db with
  | Ok t -> Yojson.Safe.pp Format.std_formatter (db_to_yojson t)
  | Error s -> failwith s
 