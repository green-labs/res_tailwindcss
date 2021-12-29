{
  open Lexing
  open Css_parser

  exception SyntaxError of string

  let move_backward lexbuf n =
    let lcp = lexbuf.lex_curr_p in
    (* not sure how to move cursor of lexer engine backward *)
    lexbuf.lex_curr_pos <- lexbuf.lex_curr_pos - n;
    lexbuf.lex_curr_p <-
      { lcp with
        pos_cnum = lcp.pos_cnum - n;
      }
}

let white = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
let dot = '.'
let word = ['a'-'z' 'A'-'Z']
let classname_char = ['a'-'z' 'A'-'Z' '0'-'9' '-' '\\' '.' ':' '/']+

rule read =
parse
| white { read lexbuf }
| newline { new_line lexbuf; read lexbuf }
| dot '-'? word classname_char { CLASS (Lexing.lexeme lexbuf) }
| _ { read lexbuf }
| eof { EOF }
