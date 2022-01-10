{
  open Core
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
let digit = ['0'-'9']

let l_comment = "/*"
let r_comment = "*/"

let dot = '.'
let l_arbitrary_value = "\\["
let r_arbitrary_value = "\\]"
let arbitrary_value_comma = "\\2c "
let arbitrary_value_sharp = "\\#"
let tailwindcss_pseudo_class = "\\:"
let tailwindcss_dot = "\\."
let tailwindcss_frac = "\\/"
let tailwindcss_l_paren = "\\("
let tailwindcss_r_paren = "\\)"
let tailwindcss_percentage = "\\%"
let tailwindcss_plus = "\\+"
let tailwindcss_minus = "\\-"

let pseudo_class = ':'
let pseudo_element = "::"
let l_attribute_selector = '['
let end_of_class = pseudo_class | pseudo_element | l_attribute_selector | dot | newline | '>' | '{'

rule read =
parse
| white { read lexbuf }
| newline { new_line lexbuf; read lexbuf }
| l_comment { read_comment lexbuf}
| dot { read_class (Buffer.create 17) lexbuf }
| _ { read lexbuf }
| eof { EOF }

and read_comment =
parse
| r_comment { read lexbuf }
| _ { read_comment lexbuf }
| newline { new_line lexbuf; read_comment lexbuf }
| eof { EOF }

and read_class buf =
parse
| end_of_class { CLASS (Buffer.contents buf |> String.strip) }
| digit
(* if the first char following dot is a number, it is not valid class name.
if the string length of Buffer is 0, this lexeme is the first char following dot.*)
{ if Buffer.contents buf |> String.length > 0 then
(Buffer.add_string buf (Lexing.lexeme lexbuf); read_class buf lexbuf)
else read lexbuf }
| l_arbitrary_value { Buffer.add_string buf "["; read_class buf lexbuf }
| r_arbitrary_value { Buffer.add_string buf "]"; read_class buf lexbuf }
| arbitrary_value_comma { Buffer.add_string buf ","; read_class buf lexbuf }
| arbitrary_value_sharp { Buffer.add_string buf "#"; read_class buf lexbuf }
| tailwindcss_pseudo_class { Buffer.add_string buf ":"; read_class buf lexbuf }
| tailwindcss_dot { Buffer.add_string buf "."; read_class buf lexbuf }
| tailwindcss_frac { Buffer.add_string buf "/"; read_class buf lexbuf }
| tailwindcss_l_paren { Buffer.add_string buf "("; read_class buf lexbuf }
| tailwindcss_r_paren { Buffer.add_string buf ")"; read_class buf lexbuf }
| tailwindcss_percentage { Buffer.add_string buf "%"; read_class buf lexbuf }
| tailwindcss_plus { Buffer.add_string buf "+"; read_class buf lexbuf }
| tailwindcss_minus { Buffer.add_string buf "-"; read_class buf lexbuf }
| _ { Buffer.add_string buf (Lexing.lexeme lexbuf); read_class buf lexbuf }
| eof { EOF }

