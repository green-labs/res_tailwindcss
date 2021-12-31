(* Spelling Corrector
   https://norvig.com/spell-correct.html *)
open Core
module StringSet = Set.Make (String)

let letters =
  (* append digits and slash(/) in order to correct more accurately *)
  String.to_list "abcdefghijklmnopqrstuvwxyz0123456789/"
  |> List.map ~f:(fun x -> Char.to_string x)

let init_words ~size = Hashtbl.create ~growth_allowed:true ~size (module String)

let make_words words value =
  let freq = Hashtbl.find words value in
  match freq with
  | Some freq' -> Hashtbl.set words ~key:value ~data:(freq' + 1)
  | None -> Hashtbl.set words ~key:value ~data:1

let splits word =
  let length = String.length word in
  let rec loop index acc =
    if index > length then acc
    else
      let lword = String.sub word ~pos:0 ~len:index in
      let rword = String.sub word ~pos:index ~len:(length - index) in
      loop (index + 1) ((lword, rword) :: acc)
  in
  loop 0 []

let deletes splits =
  splits
  |> List.filter_map ~f:(fun x ->
         let lword, rword = x in
         if String.length rword > 0 then
           Some (lword ^ String.drop_prefix rword 1)
         else None)

let transposes splits =
  let get_char_to_string s index = String.get s index |> Char.to_string in
  splits
  |> List.filter_map ~f:(fun x ->
         let lword, rword = x in
         if String.length rword > 1 then
           Some
             (lword ^ get_char_to_string rword 1 ^ get_char_to_string rword 0
            ^ String.drop_prefix rword 2)
         else None)

let replaces letters splits =
  splits
  |> List.filter_map ~f:(fun s ->
         let lword, rword = s in
         if String.length rword > 0 then
           Some
             (letters
             |> List.map ~f:(fun l -> lword ^ l ^ String.drop_prefix rword 1))
         else None)
  |> List.concat

let inserts letters splits =
  splits
  |> List.map ~f:(fun s ->
         let lword, rword = s in
         letters |> List.map ~f:(fun l -> lword ^ l ^ rword))
  |> List.concat

let edit1 word =
  let splited = splits word in
  let deleted = deletes splited in
  let transposed = transposes splited in
  let replaced = replaces letters splited in
  let inserted = inserts letters splited in
  let candidates = deleted @ transposed @ replaced @ inserted in
  List.fold_left candidates ~init:StringSet.empty ~f:(fun set s ->
      StringSet.add set s)
  |> StringSet.to_list

let edit2 word =
  let edit1s = edit1 word in
  let edit2s = List.map ~f:(fun s -> edit1 s) edit1s |> List.concat in
  edit1s @ edit2s

let known words ws =
  ws
  |> List.filter ~f:(fun w -> Hashtbl.mem words w)
  |> List.fold_left ~init:StringSet.empty ~f:(fun set s -> StringSet.add set s)
  |> StringSet.to_list

let candidates words word =
  let known1 = known words [ word ] in
  if List.length known1 > 0 then known1
  else
    let known2 = known words (edit1 word) in
    if List.length known2 > 0 then known2 else known words (edit2 word)

let correction words word =
  let candidates = candidates words word in
  let sorted_candidates =
    List.sort candidates ~compare:(fun a b ->
        let a' = Hashtbl.find words a in
        let b' = Hashtbl.find words b in
        match (a', b') with
        | Some a'', Some b'' -> b'' - a''
        | Some _, None -> -1
        | None, Some _ -> 1
        | None, None -> 0)
  in
  if List.length sorted_candidates > 0 then List.hd_exn sorted_candidates
  else word
