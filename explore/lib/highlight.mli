val transform : Omd.block list -> Omd.block list
(** [transform bs] will extract code blocks from [bs] and replace them with HTML
    code blocks with syntax highlighting spans. *)
