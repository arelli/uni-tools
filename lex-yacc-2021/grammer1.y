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
%token BOOL TRUE FALSE WRITE_REAL WRITE_INT WRITE_STRING READ_REAL READ_INT READ_STRING
%token VAR CONST IF ELSE FOR WHILE BREAK CONTINUE SEMIC FUNC NIL RETURN KW_BEGIN PLUS  MINUS STAR SLASH PERCENT 
%token DOUBLE_STAR LOGIC_EQUALS LOGIC_NOT_EQUALS LESS_THAN LESS_THAN_OR_EQUALS GREATER_THAN  GREATER_OR_EQUALS LOGIC_AND  LOGIC_OR LOGIC_NOT
%token LEFT_PARENTESIS RIGHT_PARENTHESIS COMMA LEFT_BRACKET RIGHT_BRACKET LEFT_CURLY RIGHT_CURLY COMMENT MULTI_LINE_COMMENT 

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

%type <str> expression function_call  array_call list_of_arguments var_decl list_of_assignments array_type data_type
%type <str> expr_or_string var_decl_section lines line const_decl const_decl_section prologue function_decl parameters
%type <str> function_body  statement return_line assignment assignment_line if_stmt else_stmt statements for_loop while_loop
%type <str> function_decl_section func_begin begin_body read_string read_int read_real write_string write_int write_real
%type <str> special_functions_read special_functions_write
%start prologue

//%glr-parser  https://stackoverflow.com/questions/39781557/bison-cant-solve-conflicts-shift-reduce-and-reduce-reduce


%%  // the beginning of the rules section
prologue : lines {        // the print is at the top of the recursion tree! important.
        puts("#include<pilib.h>"); 
        puts("#include<math.h>");  //include it for the pow() function
        printf("/* transcribed pi program*/ \n\n");
        if (yyerror_count == 0) {
            printf("%s\n", $1);  // this is needed(at the top of the recursion tree) to produce code.
        }
    };


lines :  line {$$ = $1;}  // just to read multiple lines
    | lines line {$$ = template("%s\n%s", $1, $2);}   // TODO: find out why 3 conflicts are being caused from this line.
;
        
line : var_decl_section | const_decl_section | function_decl_section | func_begin ;
        
func_begin : FUNC KW_BEGIN LEFT_PARENTESIS RIGHT_PARENTHESIS LEFT_CURLY begin_body RIGHT_CURLY
{$$ = template("void main(){\n%s\n}", $6);}
;

begin_body : const_decl_section var_decl_section statements return_line
{$$=template("%s \n %s \n %s\n %s;" ,$1,$2,$3, $4);}

// TODO remove 1 connflict!
function_decl_section : function_decl 
                    | function_decl_section function_decl {$$ = template("%s\n%s", $1, $2);} 

function_decl : FUNC ID LEFT_PARENTESIS parameters RIGHT_PARENTHESIS data_type LEFT_CURLY function_body RIGHT_CURLY
{$$ = template("%s %s(%s){\n%s\n}",$6, $2, $4,$8);};

parameters : expr_or_string data_type{ $$ = template("%s %s",$1, $2);}
           | parameters COMMA expr_or_string data_type{$$ = template("%s,%s %s",$1, $3,$4);};
           | %empty {$$="";}
           
// TODO: mke var and const decl section OPTIONAL! (and also statements optional!)
function_body :  var_decl_section | const_decl_section  | statements // {$$ = template("%s\n%s\n%s", $1,$2,$3);};

// removed all conflicts due to plural of statement!(may be in its components though still)
statements : statements statement {$$ = template("%s \n%s",$1,$2);}
             |statement { $$ = $1; };  

statement : assignment_line {$$ = template("%s;",$1);} 
             | if_stmt {$$ = template("%s;",$1);} 
             | return_line {$$ = template("%s;",$1);}
             | function_call SEMIC {$$ = template("%s;",$1);}  // TODO: doesnt recognize func_calls!(????) fix it
             | BREAK SEMIC {$$ = template("break;");};  
             | CONTINUE SEMIC {$$ = template("continue;");}; 
             | while_loop | for_loop
             | special_functions_read | special_functions_write
             ;

// working for loop transpiler, TODO: remove 1 conflict.             
for_loop: FOR LEFT_PARENTESIS assignment SEMIC expression SEMIC assignment RIGHT_PARENTHESIS statement {$$=template("for (%s;%s;%s)\n%s", $3, $5, $7, $9);}
            | FOR LEFT_PARENTESIS assignment SEMIC expression SEMIC assignment RIGHT_PARENTHESIS LEFT_CURLY statements RIGHT_CURLY
            {$$=template("for (%s;%s;%s){\n%s\n}",$3, $5, $7, $10);};
//TODO add brackets in the statements!
while_loop : WHILE LEFT_PARENTESIS expression RIGHT_PARENTHESIS LEFT_CURLY statements RIGHT_CURLY {$$ = template("while (%s){ \n %s \n}",$3,$6);}
            | WHILE LEFT_PARENTESIS expression RIGHT_PARENTHESIS  statement {$$ = template("while (%s)\n%s",$3,$5);}  // TODO: remove 1 conflict.
            ;
            
// TODO: maybe instead of statements, we can use the function body.
if_stmt : IF LEFT_PARENTESIS expression RIGHT_PARENTHESIS LEFT_CURLY statements RIGHT_CURLY else_stmt {$$ = template("if (%s){ \n %s \n}\n%s",$3,$6,$8);}
        | IF LEFT_PARENTESIS expression RIGHT_PARENTHESIS LEFT_CURLY statements RIGHT_CURLY {$$ = template("if (%s){ \n %s \n}",$3,$6); }
        | IF LEFT_PARENTESIS expression RIGHT_PARENTHESIS  statement else_stmt{$$ = template("if (%s) \n %s \n else \n%s",$3,$5,$6); }  // TODO: remove 2 conflicts.
        | IF LEFT_PARENTESIS expression RIGHT_PARENTHESIS  statement {$$ = template("if (%s) \n %s ",$3,$5); }  // for single command if.

else_stmt : ELSE statement {$$ = template("else \n %s", $2);};  // TODO: add support for ELSE IF!!!
            | ELSE LEFT_CURLY statements RIGHT_CURLY {$$ = template("else \n{\n%s\n}", $3);};


// a line where an assignment takes place
assignment_line : assignment SEMIC {$$ = template("%s", $1);};

// wee need an assignment without a SEMIC for use inside the for() loop
assignment : ID ASSIGN expr_or_string {$$ = template("%s=%s", $1,$3);};

// single constant declaration grammar 
const_decl : CONST list_of_assignments data_type SEMIC {$$ = template("const %s %s;", $3,$2);}

// multiple constant declaration grammar
const_decl_section: const_decl const_decl_section {$$ = template("%s \n%s", $1,$2);} 
                | const_decl { $$ = $1;} // TODO: make this optional
                //| %empty {$$=template("");}
;

// multiple variable declaration
var_decl_section: var_decl var_decl_section {$$ = template("%s \n%s", $1,$2);} 
                | var_decl { $$ = $1;}  // TODO: make this optional
                //| %empty {$$=template("");}
;

var_decl : VAR list_of_assignments data_type SEMIC {$$ = template("%s %s;", $3,$2);};  // TODO remove this scenario!!!!
           //| %empty {$$=template("");}   // +~20 conflicts

return_line : RETURN expr_or_string SEMIC{$$=template("return %s",$2);}
            | RETURN SEMIC{$$=template("return");}
            //| %empty {$$=template("");}  // adds 218 conflicts :) 
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
       | LEFT_PARENTESIS expression RIGHT_PARENTHESIS { $$ = template("(%s)", $2);}
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


// special function calls

read_string: READ_STRING LEFT_PARENTESIS RIGHT_PARENTHESIS SEMIC { $$ = template("readString();"); }
;

read_int: READ_INT LEFT_PARENTESIS RIGHT_PARENTHESIS SEMIC { $$ = template("readInt();"); }
;

read_real: READ_REAL LEFT_PARENTESIS RIGHT_PARENTHESIS SEMIC { $$ = template("readReal();"); }
;

write_string : WRITE_STRING LEFT_PARENTESIS ID RIGHT_PARENTHESIS SEMIC { $$ = template("writeString(%s);", $3); }
       | WRITE_STRING LEFT_PARENTESIS STR RIGHT_PARENTHESIS SEMIC { $$ = template("writeString(%s);", $3); }
;


write_int : WRITE_INT LEFT_PARENTESIS ID RIGHT_PARENTHESIS SEMIC { $$ = template("writeInt(%s);", $3); }
       | WRITE_INT LEFT_PARENTESIS INT RIGHT_PARENTHESIS SEMIC     { $$ = template("writeInt(%s);", $3); }
;

write_real : WRITE_REAL LEFT_PARENTESIS ID RIGHT_PARENTHESIS SEMIC { $$ = template("writeReal(%s);", $3); }
       | WRITE_REAL LEFT_PARENTESIS REAL RIGHT_PARENTHESIS SEMIC { $$ = template("writeReal(%s);", $3); }
;

special_functions_read: read_int | read_real | read_string ;
special_functions_write :  write_int | write_real | write_string;



%%
void main() {
	if (yyparse() != 0)
		printf("Invalid input.\n");
	}
