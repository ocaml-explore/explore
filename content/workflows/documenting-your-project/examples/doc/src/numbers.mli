(** {1 Types} *)

type err = [ `Undefined of string ]
(** The type of number errors *)

(** {1 Number Functions} *)

val fact : int -> (int, err) Result.t
(** [fact n] computes n! ({{:https://en.wikipedia.org/wiki/Factorial}
    factorial}). If [n] is less than [0] then it returns an [Error err] where
    the errors are {!err} *)
