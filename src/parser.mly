%{ open Types %}

%token <string> CLASS
%token EOF

%start <Types.selector option> prog
%%

prog:
| s = selector { Some s }
| EOF { None } ;

selector:
| c = CLASS { Class c }
