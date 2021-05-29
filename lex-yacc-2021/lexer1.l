/* c inclusions and initialisations */
%{
#include<stdio.h>
#include <string.h>
#include "grammer.tab.h"
#include "cgen.h"

int line_num = 0;
%}

DIGIT [0-9]
NUMBER  {DIGIT}{DIGIT}*
DECIMAL ("."{NUMBER})|({NUMBER}("."{NUMBER}?)?)
REAL {DECIMAL}([eE][-+]?{NUMBER})?
ID  [a-zA-Z_][0-9a-zA-Z_]*  
STR \"[^\"\n]*\"

 /* define the start condition */

%x comment  

%%

"=" {printf("token EQUALS : %s\n", yytext); return ASSIGN;}

"int" {printf("token INT_TYPE: %s\n", yytext);return INT_TYPE;}
"real" {printf("token REAL_TYPE: %s\n", yytext);return REAL_TYPE;}
"string" {printf("token STR_TYPE: %s\n", yytext);return STR_TYPE;}
"bool" {printf("token BOOL: %s\n", yytext);return BOOL;}

"true" {printf("token TRUE : %s\n", yytext);return TRUE;}
"false" {printf("token FALSE : %s\n", yytext);return FALSE;}

"var" {printf("token VAR: %s\n", yytext);return VAR;}
"const" {printf("token CONST: %s\n", yytext);return CONST;}

"if" {printf("token IF: %s\n", yytext);return IF;}
"else" {printf("token ELSE: %s\n", yytext);return ELSE;}
"for" {printf("token FOR: %s\n", yytext);return FOR;}
"while" {printf("token WHILE: %s\n", yytext);return WHILE;}
"break" {printf("token BREAK: %s\n", yytext);return BREAK;}
"continue" {printf("token CONTINUE: %s\n", yytext);return CONTINUE;}

"func" {printf("token FUNC: %s\n", yytext);return FUNC;}
"nil" {printf("token NIL: %s\n", yytext);return NIL;}

"and" {printf("token LOGIC_AND: %s\n", yytext);return LOGIC_AND;}
"or" {printf("token LOGIC_OR: %s\n", yytext);return LOGIC_OR;}
"not" {printf("token LOGIC_NOT: %s\n", yytext);return LOGIC_NOT;}

"return" {printf("token RETURN: %s\n", yytext);return RETURN;}
"begin" {printf("token KW_BEGIN: %s\n", yytext);return KW_BEGIN;}

"+" {printf("token PLUS: %s\n", yytext);return PLUS;}
"-" {printf("token MINUS: %s\n", yytext);return MINUS;}
"*" {printf("token STAR: %s\n", yytext);return STAR;}
"/" {printf("token SLASH: %s\n", yytext);return SLASH;}
"%" {printf("token PERCENT: %s\n", yytext);return PERCENT;}
"**" {printf("token DOUBLE_STAR: %s\n", yytext);return DOUBLE_STAR;}

"==" {printf("token LOGIC_EQUALS: %s\n", yytext);return LOGIC_EQUALS;}
"!=" {printf("token LOGIC_NOT_EQUALS: %s\n", yytext);return LOGIC_NOT_EQUALS;}
"<" {printf("token LESS_THAN: %s\n", yytext);return LESS_THAN;}
"<=" {printf("token LESS_THAN_OR_EQUALS: %s\n", yytext);return LESS_THAN_OR_EQUALS;}
">" {printf("token GREATER_THAN: %s\n", yytext);return GREATER_THAN;}
">=" {printf("token GREATER_OR_EQUALS: %s\n", yytext);return GREATER_OR_EQUALS;}

";" {printf("token COLON: %s\n", yytext);return COLON;}
"(" {printf("token LEFT_PARENTESIS: %s\n", yytext);return LEFT_PARENTESIS;}
")" {printf("token RIGHT_PARENTHESIS: %s\n", yytext);return RIGHT_PARENTHESIS;}
"[" {printf("token LEFT_BRACKET: %s\n", yytext);return LEFT_BRACKET;}
"]" {printf("token RIGHT_BRACKET: %s\n", yytext);return RIGHT_BRACKET;}
"," {printf("token COMMA: %s\n", yytext);return COMMA;}
"{" {printf("token LEFT_CURLY: %s\n", yytext);return LEFT_CURLY;}
"}" {printf("token RIGHT_CURLY: %s\n", yytext);return RIGHT_CURLY;}

 /* " " {return WHITESPACE;} */

 /* these have to be after the above rules! */
{NUMBER} {printf("token INT: %s\n",yytext); yylval.str = strdup(yytext);return INT;}
{REAL} {printf("token REAL: %s\n", yytext); yylval.str = strdup(yytext);return REAL;}
{ID} {printf("token ID: %s\n", yytext); yylval.str = strdup(yytext);return ID;}
{STR} {printf("token STR: %s\n", yytext); yylval.str = strdup(yytext);return STR;}


\n line_num++;

[ \t\r]  /* do nothing in white space */

<<EOF>>  return EOF;

. {printf("Unrecognized tolkien %s in line %d\n", yytext, line_num);}  

"//"[^\n]*  		    /* we dont care about comments */
"/*"                    {BEGIN(comment);}
<comment>[^*\n]*        /* eat anything that's not a '*' */ 
<comment>"*"+[^*/\n]*   /* dont count * without / after them */
<comment>\n             {line_num++;} 
<comment>"*"+"/"        { BEGIN(INITIAL);} /* initial is the normal flow of flex */
