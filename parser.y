%{


#include <stdio.h>
#include "lex.yy.c"
#include <windows.h>
extern FILE* yyin;
extern FILE* yyout;

int yyerror(char* s);
extern int yylex();

void append(char subject[], const char insert[], int pos);
void addTabulations(char* subject);

%}


%union {
    char str[1024];
}

%start prog

%token ASSIGN INT_TYPE COLON STRING_TYPE 
QUOTATION VAR_BEGIN VAR_END EQUALS 
UNEQUALS MOD OR XOR AND 
NOT IF ELSE_IF ELSE 
THEN END_IF FOR TO DO BY END_FOR
WHILE END_WHILE


%token<str> STRING SIGN
%token<str> NUM
%type<str> action_list action 
%type<str> create_variable create_variable_list set_string_var set_int_var
%type<str> expr expr_operand if 
%type<str> else if_init if_content
%type<str> for for_head for_head_main
%type<str> while while_head




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
    | expr
    { printf("EXPR"); strcpy($$, $1); strcat($$,";\n\t"); }
    | if
    { printf("IF"); strcpy($$, $1); strcat($$,"\n\t"); }
    | for
    { printf("FOR"); strcpy($$, $1); strcat($$,"\n\t"); }
    | while
    { printf("WHILE"); strcpy($$, $1); strcat($$,"\n\t"); }
;


/* --------------------------------------VARIABLES--------------------------------------------*/

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

expr_operand:
    STRING
    {strcpy($$, $1);} 
    | NUM
    {strcpy($$, $1);}
expr:
    expr_operand
    {strcpy($$, $1);}
    | expr_operand EQUALS expr_operand
    {strcpy($$, $1); strcat($$, " == "); strcat($$, $3);}
    | expr_operand UNEQUALS expr_operand
    {strcpy($$, $1); strcat($$, " != "); strcat($$, $3);}
    | expr_operand MOD expr_operand
    {strcpy($$, $1); strcat($$, " %% "); strcat($$, $3);}
    | expr_operand SIGN expr_operand
    {strcpy($$, $1); strcat($$, " "); strcat($$, $2); strcat($$, " "); strcat($$, $3);}
    | NOT expr_operand
    {strcpy($$, "!"); strcat($$, $2);}
    | expr_operand OR expr_operand
    {strcpy($$, $1); strcat($$, " || "); strcat($$, $3);}
    | expr_operand AND expr_operand
    {strcpy($$, $1); strcat($$, " && "); strcat($$, $3);}
    | expr_operand XOR expr_operand
    {strcpy($$, $1); strcat($$, " ^ "); strcat($$, $3);}

/* ---------------------------------------------------------------------------------------------*/

/* ----------------------------------IF STATEMENTS-----------------------------------------------*/


if:
    if_init END_IF
    { strcpy($$, $1); }

    | if_init else END_IF
    { strcpy($$, $1); strcat($$, $2); }
    

if_init:
    IF if_content
    {   
        strcpy($$, "if "); 
        strcat($$, $2);
    } 

else:
    ELSE action_list
    {
        strcpy($$, " else {\n\t\t");
        addTabulations($2);
        strcat($$, $2); 
        strcat($$, "}");
    }

    | ELSE_IF if_content
    {   
        strcpy($$, " else if "); 
        strcat($$, $2);

    } 

    | ELSE_IF if_content else
    {   
        strcpy($$, " else if "); 
        strcat($$, $2);
        strcat($$, $3);
    } 

if_content:
   expr THEN action_list
    {
        strcpy($$, "(");
        strcat($$, $1);
        strcat($$, ") {\n\t\t");
        addTabulations($3);
        strcat($$, $3); 
        strcat($$, "}");
    }
    
/* -------------------------------------------------------------------------------------------------*/

/* ---------------------------------------FOR LOOPS-------------------------------------------------*/

for: 
    FOR for_head DO action_list END_FOR
    { 
        strcpy($$, "for ");
        strcat($$, $2);
        strcat($$, " {\n\t\t");
        addTabulations($4);
        strcat($$, $4);
        strcat($$, "}");
    }

    | FOR for_head DO END_FOR
    { 
        strcpy($$, "for ");
        strcat($$, $2);
        strcat($$, " {}");
    }


for_head_main:
    STRING ASSIGN expr TO expr
    {
        strcpy($$, "int ");
        strcat($$, $1);
        strcat($$, " = ");
        strcat($$, $3);
        strcat($$, "; ");
        strcat($$, $1);
        strcat($$, " < ");
        strcat($$, $5);
        strcat($$, "; ");
        strcat($$, $1);
    }

for_head:
    for_head_main
    { 
        strcpy($$, "(");
        strcat($$, $1);
        strcat($$, "++");
        strcat($$, ")");
    }
    | for_head_main BY expr
    {
        strcpy($$, "(");
        strcat($$, $1);
        strcat($$, " += ");
        strcat($$, $3);
        strcat($$, ")");
    }

/* -------------------------------------------------------------------------------------------------*/

/* --------------------------------------WHILE LOOPS------------------------------------------------*/

while_head:
    WHILE expr DO
    {
        strcpy($$, "while "); 
        strcat($$, "("); 
        strcat($$, $2); 
        strcat($$, ")"); 
    }

while:
    while_head action_list END_WHILE
    {
        strcpy($$, $1);
        strcat($$, " {\n\t\t");
        addTabulations($2);
        strcat($$, $2);
        strcat($$, "}");
    }
    | while_head END_WHILE
    { 
        strcpy($$, $1); 
        strcat($$, " {}");
    }



/* -------------------------------------------------------------------------------------------------*/


%%
int main(void)
{
    /* #ifdef YYDEBUG
    yydebug = 1;
    #endif */
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

void append(char subject[], const char insert[], int pos) {
    char buf[100] = {};

    strncpy(buf, subject, pos); 
    int len = strlen(buf);
    strcpy(buf+len, insert); 
    len += strlen(insert);  
    strcpy(buf+len, subject+pos); 

    strcpy(subject, buf);   
}

void addTabulations(char* subject) {
    size_t length = strlen(subject);
    size_t i = 1; 
    for (; i < length - 1; i++) {
        if (subject[i - 1] == '\n') {
            append(subject, "\t", i);
        } 
    }
}