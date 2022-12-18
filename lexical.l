%{

/* C stuff (includes, function declarations, etc) */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"
extern FILE* yyin;
extern FILE* yyout;
void showError();

%}

%%

":" { return COLON; }
"INT" { return INT_TYPE; }
"STRING" { return STRING_TYPE; }

":=" { return ASSIGN; }
"VAR" { return VAR_BEGIN; }
"END_VAR" { return VAR_END; }

"=" { return EQUALS; }
"<>" { return UNEQUALS; }
"mod" { return MOD; }
"OR" { return OR; }
"XOR" { return XOR; }
"AND" { return AND; }
"NOT" { return NOT; }

"IF" { return IF; }
"ELSEIF" { return ELSE_IF; }
"ELSE" { return ELSE; }
"THEN" { return THEN; }
"END_IF" { return END_IF; }

"FOR" { return FOR; }
"TO" { return TO; }
"BY" { return BY; }
"DO" { return DO; }
"END_FOR" { return END_FOR; }

"WHILE" { return WHILE; }
"END_WHILE" { return END_WHILE; }


["] { return QUOTATION; }
[a-zA-Z][a-zA-Z0-9]* {strcpy(yylval.str, yytext); return STRING;}
[0-9]+ {strcpy(yylval.str, yytext); return NUM;}
["+""-""*""\/"">""<"">=""<="] {strcpy(yylval.str, yytext); return SIGN;}


[ \t\v\n\f] { }



%%

/* functions */

void showError() {
   printf("Unknown token");
}

int yywrap(void) {return 1;}