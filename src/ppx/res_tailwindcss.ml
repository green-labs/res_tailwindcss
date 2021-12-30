open Ppxlib
open Lexing
open Core
open Util
open Spelling_corrector

module Parser = struct
  let print_position outx lexbuf =
    let pos = lexbuf.lex_curr_p in
    fprintf outx "%s:%d:%d" pos.pos_fname pos.pos_lnum
      (pos.pos_cnum - pos.pos_bol + 1)

  let parse_with_error lexbuf =
    try Css_parser.prog Css_lexer.read lexbuf with
    | Css_lexer.SyntaxError msg ->
        fprintf stderr "%a: %s\n" print_position lexbuf msg;
        exit (-1)
    | Css_parser.Error ->
        fprintf stderr "%a: syntax error\n" print_position lexbuf;
        exit (-1)

  let rec run lexbuf tailwindcss =
    match parse_with_error lexbuf with
    | Some (Class value) ->
        let stripped_value = value in
        make_words tailwindcss stripped_value;
        run lexbuf tailwindcss
    | None -> tailwindcss
end

let loop filename classnames ~loc =
  let inx = In_channel.create filename in
  let lexbuf = Lexing.from_channel inx in
  set_filename lexbuf filename;

  let init_words = init_words ~size:1000 in
  let tailwind_classnames = Parser.run lexbuf init_words in

  let is_valid =
    classnames |> List.for_all ~f:(Hashtbl.mem tailwind_classnames)
  in
  if is_valid then ()
  else
    let not_found =
      classnames
      |> List.find_exn ~f:(fun c -> not (Hashtbl.mem tailwind_classnames c))
    in
    let corrected =
      Spelling_corrector.correction tailwind_classnames not_found
    in
    let _ =
      (* if corrected is same to not found classname, this means we can not find the suggestion *)
      if String.equal not_found corrected then
        Location.raise_errorf ~loc "Class name not found: %s" not_found
      else
        Location.raise_errorf ~loc "Class name not found: %s, do you mean %s?"
          not_found corrected
    in
    In_channel.close inx

let expand ~ctxt label =
  let loc = Expansion_context.Extension.extension_point_loc ctxt in
  let stripped_label = String.strip label in
  (* if label is emtpy string then pass it *)
  if String.length stripped_label = 0 then
    Ast_builder.Default.estring ~loc label
  else
    let classnames = stripped_label |> String.split ~on:' ' in
    let project_root = find_project_root @@ Sys.getcwd () in
    match project_root with
    | Ok project_root' ->
        let tailwindcss_path =
          Filename.concat project_root' !(Configs.get_tailwindcss_path ())
        in
        loop tailwindcss_path classnames ~loc;
        Ast_builder.Default.estring ~loc label
    | Error msg ->
        fprintf stderr "%s\n" msg;
        exit (-1)

let extension =
  Extension.V3.declare "twc" Extension.Context.expression
    Ast_pattern.(single_expr_payload (estring __))
    expand

let rule = Ppxlib.Context_free.Rule.extension extension

(** Add command line arg "--path" to get a path of tailwindcss file *)
let _ =
  Ppxlib.Driver.add_arg "--path"
    (Caml.Arg.String
       (fun tailwind_path -> Configs.set_tailwindcss_path tailwind_path))
    ~doc:""

let () = Ppxlib.Driver.register_transformation ~rules:[ rule ] "res_tailwindcss"
