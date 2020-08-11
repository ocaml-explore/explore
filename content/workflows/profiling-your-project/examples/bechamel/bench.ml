(* https://github.com/mirage/checkseum/blob/master/bench/main.ml *)
[@@@part "0"]

let random_string len =
  let res = Bytes.create len in
  for i = 0 to len - 1 do
    Bytes.set res i (Char.chr (Random.int 26 + 97))
  done;
  Bytes.unsafe_to_string res

(* Generating random yaml strings for different number of elements *)
[@@@part "1"]

let gen_random_yaml_strings n d =
  let gen_str () = `String (random_string 100) in
  let gen_bool () = if Random.int 2 = 1 then `Bool true else `Bool false in
  let gen_float () = `Float (Random.float 100.) in
  let rec gen_kv d () = (random_string 10, (gen_value (d - 1) ()) ())
  and gen_arr d c () = `A (List.init c (fun _ -> (gen_value (d - 1) ()) ()))
  and gen_o d () = `O (List.init n (fun _ -> gen_kv (d - 1) ()))
  and gen_value d () =
    if d <= 0 then gen_str
    else
      match Random.int 6 with
      | 0 -> gen_str
      | 1 -> gen_bool
      | 2 -> gen_float
      | _ -> gen_arr (d - 1) (Random.int 10)
  in
  Yaml.pp Format.str_formatter (gen_o d ());
  Format.flush_str_formatter ()

[@@@part "2"]

let inputs =
  List.init 6 (fun i -> (i, gen_random_yaml_strings ((i + 1) * 10) 2))

let args, inputs = List.split inputs

let of_string inputs i =
  let v = inputs.(i) in
  Bechamel.Staged.stage (fun () ->
      match Yaml.of_string v with Ok t -> t | Error _ -> assert false)

[@@@part "3"]

let tests =
  let test_of_string =
    Bechamel.Test.make_indexed ~name:"of_string" ~args
      (of_string (Array.of_list inputs))
  in
  Bechamel.Test.make_grouped ~name:"yaml" [ test_of_string ]

[@@@part "4"]

let benchmark () =
  let open Bechamel in
  let ols =
    Bechamel.Analyze.ols ~bootstrap:0 ~r_square:true
      ~predictors:Bechamel.Measure.[| run |]
  in
  let instances =
    Toolkit.Instance.[ minor_allocated; major_allocated; monotonic_clock ]
  in
  let raw_res =
    let quota = Time.second 3. in
    Benchmark.all (Benchmark.cfg ~run:3000 ~quota ()) instances tests
  in
  List.map (fun instance -> Analyze.all ols instance raw_res) instances
  |> fun r -> (Analyze.merge ols instances r, raw_res)

[@@@part "5"]

let nothing _ = Ok ()

let () =
  Random.self_init ();
  let results = benchmark () in
  let open Bechamel in
  let open Bechamel_js in
  match
    emit ~dst:(Channel stdout) nothing ~x_label:Measure.run
      ~y_label:(Measure.label Toolkit.Instance.monotonic_clock)
      results
  with
  | Ok () -> ()
  | Error (`Msg err) -> failwith err
