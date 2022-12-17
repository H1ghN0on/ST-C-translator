%{

/* C stuff (includes, function declarations, etc) */

#include <stdio.h>

void showError();

%}

%%

/* tokens */

[a-zA-Z][a-zA-Z0-9]* {strcpy(yylval.str, yytext); return VARIABLE;}
[0-9]+ {strcpy(yylval.str, yytext); return NUM;}
["+""-""*""/"">""<"">=""<="] {strcpy(yylval.str, yytext); return SIGN;}

"VAR" { return VAR; }
":" { return COLON; }
"INT" { return INT; }
"STRING" { return STRING; }
"REAL" { return REAL; }
":=" { return ASSIGN; }
"mod" { return MOD; }
"OR" { return OR; }
"XOR" { return XOR; }
"AND" { return AND; }
"NOT" { return NOT; }
"IF" { return IF; }
"ELSEIF" { return ELSEIF; }
"ELSE" { return ELSE; }
"THEN" { return THEN; }
"END_IF" { return END_IF; }

. {showError(); return NONE;}

%%

/* functions */

void showError() {
   printf("Unknown token");
}