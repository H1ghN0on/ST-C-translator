%{


#include <stdio.h>
#include "lex.yy.c"
#include <windows.h>
extern FILE* yyin;
extern FILE* yyout;

int yyerror(char* s);
extern int yylex();

%}


%union {
    char str[1024];
}

%start prog

%token ASSIGN INT_TYPE COLON  STRING_TYPE QUOTATION VAR_BEGIN VAR_END
%token<str> STRING
%token<str> NUM
%type<str> action_list create_variable action create_variable_list set_string_var set_int_var



%%

prog:
    action_list
    { printf("MAIN");fprintf(yyout, "\t"); fprintf(yyout, $1);fprintf(yyout, "\n\treturn 0;\n");return 0;}
;
action_list:
    action
    { printf("HI2"); strcpy($$, $1);}
    | action_list action
    { printf("HI"); strcpy($$, $1); strcat($$, $2); }
    
;
action:
    create_variable
    { printf("VAR"); strcpy($$, $1); strcat($$,";\n\t");}
    | VAR_BEGIN create_variable_list VAR_END
    { printf("Var start"); strcpy($$, $2); printf("Var end"); }
;


/*--------------------------------------- VARIABLES ---------------------------------------------*/

create_variable_list:
    create_variable
    { printf("VAR"); strcpy($$, $1); strcat($$,";\n\t");}
    | create_variable create_variable_list
    { printf("VAR"); strcpy($$, $1); strcat($$,";\n\t"); strcat($$, $2);}
;


create_variable:
    set_int_var ASSIGN NUM
    {
        strcpy($$, $1);  
        strcat($$, " = ");
        strcat($$, $3);
    }
    | set_int_var
    {
        strcpy($$, $1); 
        strcat($$, " = 0");
    }
    | set_string_var ASSIGN QUOTATION STRING QUOTATION
    {
        strcpy($$, $1);  
        strcat($$, " = \"");
        strcat($$, $4); 
        strcat($$, "\""); 
    }
    | set_string_var
    {
        strcpy($$, $1);
        strcat($$, " = \"\"");
    }

set_string_var:
    STRING COLON STRING_TYPE
    { strcpy($$, "char "); strcat($$, $1); strcat($$, "[255]") }

set_int_var:
    STRING COLON INT_TYPE
    { strcpy($$, "int "); strcat($$, $1) }

/* ---------------------------------------------------------------------------------------------*/

/* --------------------------------------EXPRESSIONS--------------------------------------------*/




%%

int main(void)
{

    yyin = fopen("input.txt","r");
    yyout = fopen("output.txt","w");

	fprintf(yyout, "#include <stdio.h>\n#include <stdlib.h>\n\nint main()\n{\n");
    yyparse();
	fprintf(yyout, "}");
    fclose(yyin);
    fclose(yyout);
    system("pause");
    return 0;
}


int yyerror(char* s)
{
    fprintf(yyout, "%s\n", s);
}