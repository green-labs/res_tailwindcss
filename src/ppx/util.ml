open Core

let pseudo_classes =
  [
    ":hover";
    ":focus";
    ":focus-within";
    ":focus-visible";
    ":active";
    ":visited";
    ":target";
    ":first-child";
    ":last-child";
    ":only-child";
    ":nth-child\\(.*\\)";
    ":first-of-type";
    ":last-of-type";
    ":only-of-type";
    "empty";
    ":disabled";
    ":checked";
    ":indeterminate";
    ":default";
    ":required";
    ":valid";
    ":invalid";
    ":in-range";
    ":out-of-range";
    ":placeholder-shown";
    ":autofill";
    ":read-only";
  ]

let pseudo_elements = [ "::.+" ]
let attribute_selectors = [ "\\(\\..+[^-]\\)\\[.*\\]" ]

let remove_backslash s =
  s |> String.split_on_chars ~on:[ '\\' ] |> String.concat

let remove_pseudo_classes s =
  pseudo_classes |> List.map ~f:Str.regexp
  |> List.fold_left ~init:s ~f:(fun s' re -> Str.replace_first re "" s')

let remove_pseudo_elements s =
  pseudo_elements |> List.map ~f:Str.regexp
  |> List.fold_left ~init:s ~f:(fun s' re -> Str.replace_first re "" s')

let remove_attribute_selectors s =
  attribute_selectors |> List.map ~f:Str.regexp
  |> List.fold_left ~init:s ~f:(fun s' re -> Str.replace_first re "\\1" s')

let strip s =
  let stripped =
    s |> String.strip |> remove_backslash |> remove_pseudo_classes
    |> remove_pseudo_elements |> remove_attribute_selectors
  in
  String.drop_prefix stripped 1

let rec find_project_root dir =
  let bsconfig = "bsconfig.json" in
  match Filename.concat dir bsconfig |> Sys.file_exists with
  | `Yes -> Ok dir
  | `Unknown -> Error "can't find the project root"
  | `No ->
      let parent = dir |> Filename.dirname in
      if String.equal parent dir then Error "can't find the project root"
      else find_project_root parent
