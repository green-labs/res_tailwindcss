open Core

let rec find_project_root dir =
  let bsconfig = "bsconfig.json" in
  match Filename.concat dir bsconfig |> Sys.file_exists with
  | `Yes -> Ok dir
  | `Unknown -> Error "can't find the project root"
  | `No ->
      let parent = dir |> Filename.dirname in
      if String.equal parent dir then Error "can't find the project root"
      else find_project_root parent
