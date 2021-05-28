 /* c inclusions and initialisations */
%{
#include<stdio.h>

#define ID 1
#define INT 2
#define REAL 3
#define ASSIGN 4
#define STR 5
#define INT_TYPE 6
#define REAL_TYPE 7
#define STR_TYPE 8
#define BOOL 9
#define TRUE 10
#define FALSE 11
#define VAR 12
#define CONST 13
#define IF 14
#define ELSE 15
#define FOR 16
#define WHILE 17 
#define BREAK 18
#define CONTINUE 19
#define FUNC 20
#define NIL 21 
#define AND 22
#define OR 23
#define NOT 24
#define RETURN 25
#define KW_BEGIN 26
#define PLUS 27
#define MINUS 28 
#define STAR 29
#define SLASH 30
#define PERCENT 31
#define DOUBLE_STAR 32
#define LOGIC_EQUALS 33
#define LOGIC_NOT_EQUALS 34
#define LESS_THAN 35
#define LESS_THAN_OR_EQUALS 36
#define GREATER_THAN 37
#define GREATER_OR_EQUALS 38
#define LOGIC_AND 39
#define LOGIC_OR 40
#define LOGIC_NOT 41
#define LEFT_PARENTESIS 42
#define RIGHT_PARENTHESIS 43
#define COLON 44
#define COMMA 45
#define LEFT_BRACKET 46
#define RIGHT_BRACKET 47
#define LEFT_CURLY 48
#define RIGHT_CURLY 49
#define COMMENT 50
#define MULTI_LINE_COMMENT 51
#define WHITESPACE 52

int counter_of_lines = 0;
%}

DIGIT [0-9]
NUMBER  {DIGIT}{DIGIT}*
DECIMAL ("."{NUMBER})|({NUMBER}("."{NUMBER}?)?)
REAL {DECIMAL}([eE][-+]?{NUMBER})?
ID  [a-zA-Z_][0-9a-zA-Z_]*  
STR \"[^\"\n]*\"



%%

{REAL} {return REAL;}
{ID} {return ID;}
{STR} {return STR;}

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
"continue" {return CONTINUE;}

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

";" {return COLON;}
"(" {return LEFT_PARENTESIS;}
")" {return RIGHT_PARENTHESIS;}
"[" {return LEFT_BRACKET;}
"]" {return RIGHT_BRACKET;}
"," {return COMMA;}
"{" {return LEFT_CURLY;}
"}" {return RIGHT_CURLY;}

" " {return WHITESPACE;}


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
