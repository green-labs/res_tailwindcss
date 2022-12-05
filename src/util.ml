let rec find_project_root dir =
  let bsconfig = "bsconfig.json" in
  match Filename.concat dir bsconfig |> Sys.file_exists with
  | true -> Ok dir
  | false ->
      let parent = dir |> Filename.dirname in
      if String.equal parent dir then Error "can't find the project root"
      else find_project_root parent
