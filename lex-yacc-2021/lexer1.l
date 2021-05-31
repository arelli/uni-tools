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

%x comm  

%%

"=" {return ASSIGN;}

"int" {return INT_TYPE;}
"real" {return REAL_TYPE;}
"string" {return STR_TYPE;}
"bool" {return BOOL;}

"true" {return TRUE;}
"false" {return FALSE;}

"var" {return VAR;}
"const" {return CONST;}

"if" {return IF;}
"else" {return ELSE;}
"for" {return FOR;}
"while" {return WHILE;}
"break" {return BREAK;}
"continue" {;return CONTINUE;}

"func" {return FUNC;}
"nil" {return NIL;}

"and" {return LOGIC_AND;}
"or" {return LOGIC_OR;}
"not" {return LOGIC_NOT;}

"return" {return RETURN;}
"begin" {return KW_BEGIN;}

"+" {return PLUS;}
"-" {return MINUS;}
"*" {return STAR;}
"/" {return SLASH;}
"%" {return PERCENT;}
"**" {return DOUBLE_STAR;}

"==" {return LOGIC_EQUALS;}
"!=" {return LOGIC_NOT_EQUALS;}
"<" {return LESS_THAN;}
"<=" {return LESS_THAN_OR_EQUALS;}
">" {return GREATER_THAN;}
">=" {return GREATER_OR_EQUALS;}

";" {return SEMIC;}
"(" {return LEFT_PARENTESIS;}
")" {return RIGHT_PARENTHESIS;}
"[" {return LEFT_BRACKET;}
"]" {return RIGHT_BRACKET;}
"," {return COMMA;}
"{" {return LEFT_CURLY;}
"}" {return RIGHT_CURLY;}

"readString"            {return READ_STRING; }  /* Functions */
"readInt"               {return READ_INT; }
"readReal"              {return READ_REAL; }
"writeString"           {return WRITE_STRING; }
"writeInt"              {return WRITE_INT; }
"writeReal"             {return WRITE_REAL; }

 /* " " {return WHITESPACE;} */

 /* these have to be after the above rules! */
{NUMBER} {yylval.str = strdup(yytext);return INT;}
{REAL} {yylval.str = strdup(yytext);return REAL;}
{ID} {yylval.str = strdup(yytext);return ID;}
{STR} {yylval.str = strdup(yytext);return STR;}


\n line_num++;

[ \t\r]  /* do nothing in white space */

<<EOF>>  return EOF;

. {printf("Unrecognized tolkien %s in line %d\n", yytext, line_num);}  

"//"[^\n]*  		    /* we dont care about commentss */
"/*"                    {BEGIN(comm);}  
<comm>[^*\n]*        
<comm>"*"+[^*/\n]*   /* dont count * without / after them */
<comm>\n             {line_num++; }
<comm>"*"+"/"        { BEGIN(INITIAL);} /* initial is the normal flow of flex */
