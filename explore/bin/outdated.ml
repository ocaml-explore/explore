open Cmdliner
open Explore
module Jf = Jekyll_format

let time () =
  Ptime.of_float_s (Unix.gettimeofday ()) |> function
  | Some t -> t
  | None -> failwith "Couldn't get current time"

let time_span days =
  match Ptime.Span.of_d_ps (days, Int64.of_int 0) with
  | Some t -> t
  | None -> failwith "Number of days incorrect"

let run fail span =
  let md_files =
    List.filter
      (fun f -> Filename.extension f = ".md")
      (Files.all_files "content")
  in
  let pp_good path =
    Fmt.(pf stdout "[%a] %s\n" (styled `Green string)) "Up to date" path
  in
  let pp_warn path =
    Fmt.(pf stdout "[%a] %s\n" (styled `Yellow string)) "Update soon" path
  in
  let pp_bad path by =
    Fmt.(pf stdout "[%a] %s by %i days\n" (styled `Red string))
      "Out of date" path by
  in
  let check_file time f =
    let content = Files.read_file f in
    let data = Jf.of_string_exn content in
    let now =
      match Jf.(find "date" (fields data)) with
      | Some (`String s) -> Jf.parse_date_exn s
      | _ ->
          Fmt.(pf stdout "%a" (styled `Red string) "[Failed to get time]");
          failwith "error"
    in
    let diff = Ptime.diff time now in
    let comp = diff < time_span span in
    let days = fst (Ptime.Span.to_d_ps diff) in
    if comp then if span - days < 5 then pp_warn f else pp_good f
    else pp_bad f (-(span - days));
    comp
  in
  let status = ref 0 in
  List.map (check_file (time ())) md_files
  |> List.iter (fun f -> if fail && f = false then incr status);
  !status

let span =
  let docv = "SPAN" in
  let doc =
    "Span is the number of days that distinguishes information being out of \
     date."
  in
  Arg.(value & pos 0 int 90 & info ~doc ~docv [])

let fail =
  let docv = "FAIL" in
  let doc =
    "When this flag is set, the outdated command will produce an non-zero \
     error if some content is found to be outdated"
  in
  Arg.(value & flag & info ~doc ~docv [ "f"; "fail" ])

let info =
  let doc =
    "Check all files to see which are outdated based on their last update \
     timestamp."
  in
  Term.info ~doc "outdated"

let cmd = (Term.(const run $ fail $ span), info)
