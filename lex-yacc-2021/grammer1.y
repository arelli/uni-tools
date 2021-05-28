/* includes */
%{  
    #include <stdio.h>
    #include "cgen.h"
    
    extern int yylex(void);  /* runs from the lex.yy.c in the same dir */
    extern int line_counter;
%}


%union{
    char* str;
    int num;
    
}

/* tokens */
%token KEYWORD_CONST
%token KEYWORD_VAR
%token KEYWORD_FUNC
%token IDENTIFIER
%token SEMIC


%token INTEGER
%token REAL




%token BEGIN_FUNC  // token means terminal symbol
%token LEFT_PAREN
%token RIGHT_PAREN
%token LEFT_CURLY
%token RIGHT_CURLY
%token FUNC_KEYWORD

%type main_body  // has to define this type
%type <str> expression  // mathematical expressions
%type const_decl
%type var_decl
%type func_declaration
%type assignment_data
%type data_type
%type parameters
%type array_definition
%type list_of_assignments


%%  // the beginning of the rules section

%start start_function  // the action thet begins the program

/*rules */
/* begin function declaration */
start_function : FUNC_KEYWORD BEGIN_FUNC LEFT_PAREN RIGHT_PAREN LEFT_CURLY main_body RIGHT_CURLY;
 {$$ = template{"void main(){\n%s\n}\n", $6};// ????

main_body : const_decl var_decl func_declaration
    // TODO: main function body
    ;

    
const_decl : KEYWORD_CONST IDENTIFIER ASSIGNMENT_KEYWORD  expression data_type SEMIC
{$$ = template("const %s %s =  %s", $5,$2,$4);}

var_decl : KEYWORD_VAR list_of_assignments data_type SEMIC
{$$ = template("%s %s;", $3,$2);}


//for the var_decl to be able to assign a list of variables
list_of_assignments: IDENTIFIER ASSIGNMENT_KEYWORD  expression {$$ = template{"%s=%s",$1,$3);}
                    | IDENTIFIER ASSIGNMENT_KEYWORD  expression ',' list_of_assignments{$$ = template{"%s=%s, %s",$1,$3,$5);}
                    |IDENTIFIER ',' list_of_assignments {$$=template("%s,%s",$1,$3);}
                    |IDENTIFIER {$$=template("%s",$1);}
                    ;

func_declaration : FUNC_KEYWORD IDENTIFIER LEFT_PAREN parameters RIGHT_PAREN  
                    data_type LEFT_CURLY body_of_function RIGHT_CURLY;
                    
                    
body_of_function : var_decl { $$ = $1; }
    |var_decl   body   {template("%s %s",$1,$2);}
    | const_decl       { $$ = $1; }
    | const_decl body  {template("%s %s",$1,$2);}
    | func_declaration        { $$ = $1; }
    | func_declaration  body  {template("%s %s",$1,$2);}    
    | statement        { $$ = $1; }
    | statement body   {template("%s %s",$1,$2);}
;


data_type:  // int-->int , real --> double, string-->char*, bool--> int(0 or 1) etc
    KEYWORD_INT  { template("int");} 
    | KEYWORD_REAL { template("double");} 
    | KEYWORD_BOOLEAN { template("bool");} 
    | STR {  template("char*");} 
    | array_type { $$ = $1;} 
    ;
  
  
array_type : IDENTIFIER '['expression '] ' data_type  
                {template("%s %s[%s]",$5, $1, $3);}
                | '[] ' data_type
                {template("%s*",$4);}
;


expression : INTEGER { $$ = $1;}  // print as is
	   | REAL { SS = S1 ; }
	   | '(' expression ')' { $$ = template("(%s)",$2);}
       | expression '+' expression { $$ = template("%s + %s", $1, $3);}
       | expression '-' expression { $$ = template("%s - %s", $1, $3);}
       | expression '*' expression { $$ = template("%s * %s", $1, $3);}
       | expression '/' expression { $$ = template("%s / %s", $1, $3);}
       // needs many more operations
       | IDENTIFIER { $$ = $1 ;}  // to be able to give complex values to variables
 ;



%%
void main() {
	if (yyparse() == 0)
		printf("Accepted the input!\n");
	else
		printf("Input not accepted. \n");
	}


