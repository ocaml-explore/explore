open Owl
open Owl_plplot

let _ = Random.init 42

(* The function we are trying to make *)
let f ?(randomness = 10.) m c x =
  let e = Random.float randomness -. (randomness /. 2.) in
  (m *. x) +. c +. e

let round3dp f = float_of_int (int_of_float (f *. 1000.)) /. 1000.

[@@@part "1"]

let () =
  (* The parameters we will try to guess *)
  let m = 3.7 in
  let c = 0.5 in
  let h = Plot.create "linreg.png" in
  (* The function with some randomness *)
  let f = f ~randomness:20. m c in
  let line m c x = (m *. x) +. c in
  Plot.set_title h
    ( "Linear Regression for y = " ^ string_of_float m ^ "x + "
    ^ string_of_float c );
  Plot.set_font_size h 8.;
  Plot.set_pen_size h 3.;
  (* Generating training and plotting data *)
  let xs_train, xs_plot =
    (Mat.linspace (-5.) 20. 1000, Mat.linspace (-5.) 20. 40)
  in
  let ys_train, ys_plot = (Mat.map f xs_train, Mat.map f xs_plot) in
  (* Scatter plot the plotting data *)
  Plot.scatter ~h ~spec:[ Marker "o" ] xs_plot ys_plot;
  (* Use the built-in linear regression (on doubles) *)
  let c, m = Linalg.D.linreg xs_train ys_train in
  (* Our guess *)
  let guess = line m c in
  Plot.plot_fun ~h ~spec:[ RGB (255, 165, 0) ] guess (-5.) 20.;
  Plot.set_font_size h 6.;
  Plot.(
    text ~h
      ~spec:[ RGB (255, 165, 0) ]
      (-3.)
      (guess 10. -. 0.2)
      ( "y = "
      ^ string_of_float (round3dp m)
      ^ "x + "
      ^ string_of_float (round3dp c) ));
  Plot.output h
