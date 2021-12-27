%{ open Css_types %}

%token <string> CLASS
%token EOF

%start <Css_types.selector option> prog
%%

prog:
| s = selector { Some s }
| EOF { None } ;

selector:
| c = CLASS { Class c }
