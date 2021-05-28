 /* c inclusions and initialisations */
%{
#include<stdio.h>

#define TK_ID 1
#define TK_POSINT 2
#define TK_REAL 3
#define TK_ASSIGN 4
#define TK_STR 5


int counter_of_lines = 0;
%}

DIGIT [0-9]
NUMBER  {DIGIT}{DIGIT}*
DECIMAL ("."{NUMBER})|({NUMBER}("."{NUMBER}?)?)
REAL {DECIMAL}([eE][-+]?{NUMBER})?
ID  [a-zA-Z_][0-9a-zA-Z_]*  
STR \"[^\"\n]*\"



%%
{REAL} {return TK_REAL;}
{ID} {return TK_ID;}
{STR} {return TK_STR;}

"=" {return TK_ASSIGN;}

\n counter_of_lines++;

[ \t\r]  /* do nothing in white space */

<<EOF>>  return EOF;

. {printf("Unrecognized tolkien %s in line %d\n", yytext, counter_of_lines);}  

%%

int main() {
	int token;
	while ((token=yylex())!=EOF)
		printf("token %d at line %d: %s\n", token,counter_of_lines, yytext);
	yylex();
}
