open Core
open Css_types

let pseudo_classes =
  [ ":active"; ":focus"; ":hover"; ":checked"; ":disabled"; "::.+" ]

let remove_backslash s =
  s |> String.split_on_chars ~on:[ '\\' ] |> String.concat

let remove_pseudo_classes s =
  pseudo_classes |> List.map ~f:Str.regexp
  |> List.fold_left ~init:s ~f:(fun s' re -> Str.replace_first re "" s')

let strip s =
  String.drop_prefix (s |> String.strip |> remove_backslash) 1
  |> remove_pseudo_classes

let rec find_project_root dir =
  let bsconfig = "bsconfig.json" in
  match Filename.concat dir bsconfig |> Sys.file_exists with
  | `Yes -> Ok dir
  | `Unknown -> Error "can't find the project root"
  | `No ->
      let parent = dir |> Filename.dirname in
      if String.equal parent dir then Error "can't find the project root"
      else find_project_root parent

let has_classname class_selectors name =
  class_selectors
  |> List.map ~f:(fun n ->
         match n with Class n' -> String.strip n' |> remove_backslash)
  |> List.exists ~f:(String.equal name)
