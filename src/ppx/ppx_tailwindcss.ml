open Ppxlib
open Lexing
open Core
open Util

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

  let rec run lexbuf classnames =
    match parse_with_error lexbuf with
    | Some value -> run lexbuf (value :: classnames)
    | None -> classnames |> List.rev
end

let loop filename classnames ~loc =
  let inx = In_channel.create filename in
  let lexbuf = Lexing.from_channel inx in
  set_filename lexbuf filename;
  let parsed = Parser.run lexbuf [] in
  let has_one =
    classnames |> List.exists ~f:(has_classname parsed)
  in
  if has_one then () else Location.raise_errorf ~loc "Class name not found";
  In_channel.close inx

let expand ~ctxt label =
  let loc = Expansion_context.Extension.extension_point_loc ctxt in
  let classnames = String.split label ~on:' ' in
  let project_root = find_project_root @@ Sys.getcwd () in
  match project_root with
  | Ok project_root' ->
      let tailwindcss_path =
        Filename.concat project_root' (Configs.tailwindcss ())
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
let () = Ppxlib.Driver.register_transformation ~rules:[ rule ] "ppx_tailwindcss"
