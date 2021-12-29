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
let classname_char = ['a'-'z' 'A'-'Z' '0'-'9' '-' '\\' '.' ':' '/' '[' ']' '(' ')']+
let l_comment = '/' '*'
let r_comment = '*' '/'

rule read =
parse
| white { read lexbuf }
| newline { new_line lexbuf; read lexbuf }
| l_comment { read_comment lexbuf}
| dot '-'? word classname_char { CLASS (Lexing.lexeme lexbuf) }
| _ { read lexbuf }
| eof { EOF }
and read_comment =
parse
| r_comment { read lexbuf }
| _ { read_comment lexbuf }
| newline { read lexbuf }
| eof { read lexbuf }
