{
  open Lexing
  open Css_parser

  exception SyntaxError of string

  let move_backward lexbuf =
    let lcp = lexbuf.lex_curr_p in
    (* not sure how to move cursor of lexer engine backward *)
    lexbuf.lex_curr_pos <- lexbuf.lex_curr_pos - 1;
    lexbuf.lex_curr_p <-
      { lcp with
        pos_cnum = lcp.pos_cnum - 1;
      }
}

let white = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
let not_positive_int = [^ '0'-'9']

rule read =
parse
| white { read lexbuf }
| newline { new_line lexbuf; read lexbuf }
| '.' not_positive_int (* class selector should not start with number *)
{ move_backward lexbuf; read_string (Buffer.create 17) lexbuf }
| _ { read lexbuf }
| eof { EOF }
and read_string buf =
parse
| '{' { CLASS (Buffer.contents buf) }
| '.' { move_backward lexbuf; CLASS (Buffer.contents buf) }
| [^ '{' '.']+ { Buffer.add_string buf (Lexing.lexeme lexbuf); read_string buf lexbuf }
| _ { raise (SyntaxError ("Illegal class character: " ^ Lexing.lexeme lexbuf)) }
| newline { Buffer.clear buf; read lexbuf }
| eof { Buffer.clear buf; read lexbuf }