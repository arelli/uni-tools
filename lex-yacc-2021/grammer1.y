/* includes */
%{  
    #include <stdio.h>
    #include "cgen.h"
    #include <math.h>
    
    extern int yylex(void);  /* runs from the lex.yy.c in the same dir */
    extern int line_counter;
%}

%union{
    char* str;
    int num;
    
}

/* tokens */
%token <str> ID   //this needs to have the <str> !
%token <str> INT    //this needs to have the <str> !
%token <str> REAL    //this needs to have the <str> !
%token ASSIGN 
%token <str> STR    //this needs to have the <str> !
%token INT_TYPE 
%token REAL_TYPE // the rest of the tokens, do not need a defined type 
%token STR_TYPE   // because thew dont cary any variable info, only their "name"
%token BOOL 
%token TRUE 
%token FALSE 
%token VAR 
%token CONST 
%token IF 
%token ELSE 
%token FOR 
%token WHILE 
%token BREAK 
%token CONTINUE 
%token FUNC 
%token NIL 
%token AND 
%token OR 
%token NOT 
%token RETURN 
%token KW_BEGIN 
%token PLUS 
%token MINUS 
%token STAR 
%token SLASH 
%token PERCENT 
%token DOUBLE_STAR 
%token LOGIC_EQUALS 
%token LOGIC_NOT_EQUALS 
%token LESS_THAN 
%token LESS_THAN_OR_EQUALS 
%token GREATER_THAN 
%token GREATER_OR_EQUALS 
%token LOGIC_AND 
%token LOGIC_OR 
%token LOGIC_NOT
%token LEFT_PARENTESIS 
%token RIGHT_PARENTHESIS 
%token COLON 
%token COMMA 
%token LEFT_BRACKET 
%token RIGHT_BRACKET 
%token LEFT_CURLY 
%token RIGHT_CURLY 
%token COMMENT 
%token MULTI_LINE_COMMENT 

%left LOGIC_OR
%left LOGIC_AND
%left GREATER_OR_EQUALS GREATER_THAN LESS_THAN LESS_THAN_OR_EQUALS LOGIC_EQUALS LOGIC_NOT_EQUALS
%left PLUS MINUS
%left STAR SLASH PERCENT
%right DOUBLE_STAR
%left LOGIC_NOT
%left LEFT_PARENTESIS
//%left LEFT_BRACKET
//%right RIGHT_BRACKET
%right RIGHT_PARENTHESIS


%type <str> expression
%type <str> function_call
%type <str> array_call
%type <str> list_of_arguments


%start start_of_program



%%  // the beginning of the rules section

start_of_program : expression{ 
  if (yyerror_count == 0) {
    // include the pilib.h file
    puts(c_prologue); 
    puts("#include<math.h>");  //include it for the pow() function
    printf("/* program */ \n\n");
    printf("%s\n", $1);  // this is needed(at the top of the recursion tree) to produce code.
  }
}
/*rules */

expression : INT { $$ = $1;}  // print as is
	   | REAL // the default action is $$=$1
	   | LEFT_PARENTESIS expression RIGHT_PARENTHESIS { $$ = template("(%s)",$2);}
       | expression PLUS expression { $$ = template("%s + %s", $1, $3);}
       | expression MINUS expression { $$ = template("%s - %s", $1, $3);}
       | expression STAR expression { $$ = template("%s * %s", $1, $3);}
       | expression SLASH expression { $$ = template("%s / %s", $1, $3);}
       | expression GREATER_THAN expression { $$ = template("%s > %s", $1, $3);}
       | expression GREATER_OR_EQUALS expression { $$ = template("%s >= %s", $1, $3);}
       | expression LESS_THAN expression { $$ = template("%s < %s", $1, $3);}
       | expression LESS_THAN_OR_EQUALS expression { $$ = template("%s <= %s", $1, $3);}
       | expression PERCENT expression { $$ = template("%s %s %s", $1,"%", $3);}
       | expression DOUBLE_STAR expression { $$ = template("pow(%s,%s)", $1, $3);}
       | expression LOGIC_EQUALS expression { $$ = template("%s == %s", $1, $3);}
       | expression LOGIC_NOT_EQUALS expression { $$ = template("%s != %s", $1, $3);}
       | expression LOGIC_AND expression { $$ = template("%s && %s", $1, $3);}
       | expression LOGIC_OR expression { $$ = template("%s || %s", $1, $3);}
       | LOGIC_NOT expression { $$ = template("!%s", $2);}
       | PLUS expression { $$ = template("%s", $2);}
       | MINUS expression { $$ = template("(-1)*%s", $2);}
       | FALSE {$$ = template("0");}
       | TRUE {$$ = template("1");}    
       | function_call {$$ = $1;} 
       | array_call {$$ = $1;}  // array call
       | ID {$$ = $1 ;}  // variables inside expressions. Important! after the array rule!.
 ;

function_call : ID LEFT_PARENTESIS list_of_arguments RIGHT_PARENTHESIS
                {$$ = template("%s(%s)",$1,$3);};

list_of_arguments : expression {$$ = template("%s",$1);}
                    | list_of_arguments COMMA expression {$$ = template("%s,%s",$1,$3);};
                    
array_call : ID LEFT_BRACKET expression RIGHT_BRACKET {$$ = template("%s[%s]",$1, $3);};
%%
void main() {
	if (yyparse() == 0)
		printf("Input OK.\n");
	else
		printf("Invalid input.\n");
	}
