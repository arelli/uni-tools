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
%token SEMIC
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
%type <str> var_decl
%type <str> list_of_assignments
%type <str> array_type
%type <str> data_type
%type <str> expr_or_string
%type <str> var_decl_section
%type <str> lines
%type <str> line
%type <str> const_decl
%type <str> const_decl_section
%type <str> prologue
%type <str> function_declaration
%type <str> parameters
%type <str> function_body
%type <str> statement
%type <str> return_line
%type <str> assignment_line
%type <str> if_stmt
%type <str> else_stmt
%type <str> statements
//%type <str> for_loop
%type <str> while_loop

%start prologue




%%  // the beginning of the rules section
prologue : lines {        // the print is at the top of the recursion tree! important.
        puts("#include<pilib.h>"); 
        puts("#include<math.h>");  //include it for the pow() function
        printf("/* program */ \n\n");
        if (yyerror_count == 0) {
            printf("%s\n", $1);  // this is needed(at the top of the recursion tree) to produce code.
        }
    };

lines :  line {$$ = $1;}  // just to read multiple lines
    | lines line {$$ = template("%s\n%s", $1, $2);} 
;
        
line : var_decl_section | const_decl_section | function_declaration 
 ;
        
// program : var_decl_section const_decl_section func_decl_section {};


function_declaration : FUNC ID LEFT_PARENTESIS parameters RIGHT_PARENTHESIS data_type LEFT_CURLY function_body RIGHT_CURLY
{$$ = template("%s %s(%s){\n%s\n}",$6, $2, $4,$8);};

parameters : expr_or_string { $$ = template("%s",$1);}
           | parameters COMMA expr_or_string {$$ = template("%s,%s",$1, $3);};
           
// TODO: mke var and const decl section OPTIONAL! (and also statements optional!)
function_body :  var_decl_section  const_decl_section  statements {$$ = template("%s\n%s\n%s", $1,$2,$3);};


statements : statements statement {$$ = template("%s \n%s",$1,$2);}
            | statement { $$ = $1; };  // TODO: remove + 4 conflicts(of 6)

statement : assignment_line {$$ = template("%s;",$1);} 
             | if_stmt {$$ = template("%s;",$1);} 
             | return_line {$$ = template("%s;",$1);}
             | function_call SEMIC {$$ = template("%s;",$1);}  // TODO: doesnt recognize func_calls!(????) fix it
             | BREAK SEMIC {$$ = template("break;");};  // TODO remove 1 conflict from here!!!
             | CONTINUE SEMIC {$$ = template("continue;");}; // TODO remove 1 conflict from here!!!
             | while_loop 
             ;
             // for, while
             
//for_loop: FOR

while_loop : WHILE LEFT_PARENTESIS expression RIGHT_PARENTHESIS LEFT_CURLY statements RIGHT_CURLY {$$ = template("while (%s){ \n %s \n}",$3,$6);}
            | WHILE LEFT_PARENTESIS expression RIGHT_PARENTHESIS  statement {$$ = template("while (%s)\n%s",$3,$5);}  // TODO: remove 1 conflict.
            ;
// TODO: maybe instead of statements, we can use the function body.
if_stmt : IF LEFT_PARENTESIS expression RIGHT_PARENTHESIS LEFT_CURLY statements RIGHT_CURLY else_stmt {$$ = template("if (%s){ \n %s \n}\n%s",$3,$6,$8);}
        | IF LEFT_PARENTESIS expression RIGHT_PARENTHESIS LEFT_CURLY statements RIGHT_CURLY {$$ = template("if (%s){ \n %s \n}",$3,$6); }
        | IF LEFT_PARENTESIS expression RIGHT_PARENTHESIS  statement {$$ = template("if (%s) \n %s ",$3,$5); }  // for single command if.

else_stmt : ELSE statements {$$ = template("else \n %s", $2);};  // TODO: add support for ELSE IF!!!
            | ELSE LEFT_CURLY statements RIGHT_CURLY {$$ = template("else \n{%s\n}", $3);};


// a line where an assignment takes place
assignment_line : ID ASSIGN expr_or_string SEMIC {$$ = template("%s=%s", $1,$3 );};

// single constant declaration grammar 
const_decl : CONST list_of_assignments data_type SEMIC {$$ = template("const %s %s;", $3,$2);}

// multiple constant declaration grammar
const_decl_section: const_decl const_decl_section {$$ = template("%s \n%s", $1,$2);} 
                | const_decl { $$ = $1;} // TODO: make this optional
;

// multiple variable declaration
var_decl_section: var_decl var_decl_section {$$ = template("%s \n%s", $1,$2);} 
                | var_decl { $$ = $1;}  // TODO: make this optional
;

var_decl : VAR list_of_assignments data_type SEMIC {$$ = template("%s %s;", $3,$2);};  // TODO remove this scenario!!!!

return_line : RETURN expr_or_string SEMIC{$$=template("return %s;",$2);}
               //| %empty {$$=template("");}
;

list_of_assignments: ID ASSIGN  expr_or_string {$$ = template("%s=%s",$1,$3);}
                    | ID ASSIGN  expr_or_string COMMA list_of_assignments {$$ = template("%s=%s, %s",$1,$3,$5);}
                    |ID COMMA list_of_assignments {$$=template("%s,%s",$1,$3);}
                    |ID {$$=template("%s",$1);};
                    
expr_or_string: expression 
                | STR ;  // we want to assign either an expression, or a string.

data_type:  // int-->int , real --> double, string-->char*, bool--> int(0 or 1) etc
    INT_TYPE  { $$ =template("int");} 
    | REAL_TYPE { $$ =template("double");} 
    | BOOL { $$ = template("bool");} 
    | STR_TYPE { $$ = template("char*");} 
    | array_type { $$ = $1;} 
;
  
array_type : array_call data_type {$$ = template("%s %s",$2, $1);}  // TODO: doesnt accept this grammar, fix it.
           | LEFT_BRACKET RIGHT_BRACKET data_type {$$ = template("%s*",$3);}
;

expression : INT { $$ = $1;}  // print as is
	   | REAL // the default action is $$=$1
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

list_of_arguments : expr_or_string {$$ = template("%s",$1);}
                    | list_of_arguments COMMA expr_or_string {$$ = template("%s,%s",$1,$3);}
;
                    
array_call : ID LEFT_BRACKET expression RIGHT_BRACKET {$$ = template("%s[%s]",$1, $3);}
;

%%
void main() {
	if (yyparse() != 0)
		printf("Invalid input.\n");
	}
