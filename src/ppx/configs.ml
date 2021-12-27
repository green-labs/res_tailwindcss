open Core
open Util

let config_filename = "ppx_tailwindcss.config.json"

let config_path () =
  let project_root = find_project_root @@ Sys.getcwd () in
  match project_root with
  | Ok project_root' -> Filename.concat project_root' config_filename
  | Error msg ->
      fprintf stderr "%s\n" msg;
      exit (-1)

let tailwindcss () =
  let config_json = Yojson.Basic.from_file @@ config_path () in
  let open Yojson.Basic.Util in
  config_json |> member "source" |> to_string
