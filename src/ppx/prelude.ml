open Core

module List = struct
  include List

  let sequence_opt xs =
    xs
    |> List.fold ~init:(Some []) ~f:(fun ys x ->
           match (ys, x) with
           | Some ys', Some x' -> Some (ys' @ [ x' ])
           | None, _ -> None
           | Some _, None -> None)
end

module String = struct
  include String

  let string_to_chars s = List.init (String.length s) ~f:(String.get s)
end
