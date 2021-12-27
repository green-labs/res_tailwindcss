open Core
open Css_types

let remove_backslash s =
  s |> String.split_on_chars ~on:[ '\\' ] |> String.concat

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
