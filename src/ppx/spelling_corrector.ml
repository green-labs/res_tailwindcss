(* Spelling Corrector
https://norvig.com/spell-correct.html *)
open Core
module StringSet = Set.Make (String)

let letters =
  String.to_list "abcdefghijklmnopqrstuvwxyz"
  |> List.map ~f:(fun x -> Char.to_string x)

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
  |> List.filter ~f:(fun x ->
         let _, rword = x in
         String.length rword > 0)
  |> List.map ~f:(fun x ->
         let lword, rword = x in
         lword ^ String.drop_prefix rword 1)

let transposes splits =
  let get_char_to_string s index = String.get s index |> Char.to_string in
  splits
  |> List.filter ~f:(fun x ->
         let _, rword = x in
         String.length rword > 1)
  |> List.map ~f:(fun x ->
         let lword, rword = x in
         lword ^ get_char_to_string rword 1 ^ get_char_to_string rword 0
         ^ String.drop_prefix rword 2)

let replaces letters splits =
  let splits' =
    splits
    |> List.filter ~f:(fun x ->
           let _, rword = x in
           String.length rword > 0)
  in
  let rec loop cs acc =
    match cs with
    | [] -> acc
    | hd :: tl ->
        loop tl
          ((splits'
           |> List.map ~f:(fun x ->
                  let lword, rword = x in
                  lword ^ hd ^ String.drop_prefix rword 1))
          @ acc)
  in
  loop letters []

let inserts letters splits =
  let rec loop cs acc =
    match cs with
    | [] -> acc
    | hd :: tl ->
        loop tl
          ((splits
           |> List.map ~f:(fun x ->
                  let lword, rword = x in
                  lword ^ hd ^ rword))
          @ acc)
  in
  loop letters []

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

let known hashtbl words =
  words
  |> List.filter ~f:(fun word -> Hashtbl.mem hashtbl word)
  |> List.fold_left ~init:StringSet.empty ~f:(fun set s -> StringSet.add set s)
  |> StringSet.to_list

let candidates hashtbl word =
  let known1 = known hashtbl [ word ] in
  if List.length known1 > 0 then known1
  else
    let known2 = known hashtbl (edit1 word) in
    if List.length known2 > 0 then known2 else known hashtbl (edit2 word)

let correction hashtbl word =
  let candidates = candidates hashtbl word in
  let sorted_candidates =
    List.sort candidates ~compare:(fun a b ->
        let a' = Hashtbl.find hashtbl a in
        let b' = Hashtbl.find hashtbl b in
        match (a', b') with
        | Some a'', Some b'' -> b'' - a''
        | Some _, None -> -1
        | None, Some _ -> 1
        | None, None -> 0)
  in
  if List.length sorted_candidates > 0 then List.hd_exn sorted_candidates
  else word
