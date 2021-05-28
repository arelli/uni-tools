%{
#include<stdio.h>
int counter_of_lines = 0;
%}

DIGIT [0-9]
NUMBER  {DIGIT}{DIGIT}*
DECIMAL ("."{NUMBER})|({NUMBER}("."{NUMBER}?)?)
REAL {DECIMAL}([eE][-+]?{NUMBER})?
ID  [a-zA-Z_][0-9a-zA-Z_]*  
STR \"[^\"\n]*\"



%%
{DECIMAL} {printf("token DECIMAL: %s\n", yytext);}
{ID} {printf("token IDENTIFIER: %s\n", yytext);}
{STR} {printf("token STR: %s\n", yytext);}
\n {counter_of_lines++;}
[ \t\r]  /* do nothing in white space */
<<EOF>>  {return EOF;}
. {printf("Unrecognized tolkien %s in line %d\n", yytext, counter_of_lines);}  

%%

int main() {
	yylex();
}
