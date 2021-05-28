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
 /* #define WHITESPACE 52 */

int counter_of_lines = 0;
%}

DIGIT [0-9]
NUMBER  {DIGIT}{DIGIT}*
DECIMAL ("."{NUMBER})|({NUMBER}("."{NUMBER}?)?)
REAL {DECIMAL}([eE][-+]?{NUMBER})?
ID  [a-zA-Z_][0-9a-zA-Z_]*  
STR \"[^\"\n]*\"

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

{REAL} {printf("token REAL: %s\n", yytext);return REAL;}
{ID} {printf("token ID: %s\n", yytext);return ID;}
{STR} {printf("token STR: %s\n", yytext);return STR;}


\n counter_of_lines++;

[ \t\r]  /* do nothing in white space */

<<EOF>>  return EOF;

. {printf("Unrecognized tolkien %s in line %d\n", yytext, counter_of_lines);}  

"//"[^\n]*  		    /* we dont care about comments */
"/*"                    {BEGIN(comment);}
<comment>[^*\n]*        /* eat anything that's not a '*' */ 
<comment>"*"+[^*/\n]*   /* dont count * without / after them */
<comment>\n             {counter_of_lines++;} 
<comment>"*"+"/"        { BEGIN(INITIAL);} /* initial is the normal flow of flex */


%%

int main() {
	int token;
	while ((token=yylex())!=EOF)
		yylex();  /* the prints happen inside the rules section above */
}
