/* includes */
%{  
    #include <stdio.h>
    #include "cgen.h"
    #include <math.h>
    
    extern int yylex(void);  /* runs from the lex.yy.c in the same dir */
    extern int line_counter;
    
%}
%define parse.error verbose  // to have a verbose output for syntax errrs.
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
%token <str> ERROR_MESSAGE

%left LOGIC_OR
%left LOGIC_AND
%left GREATER_OR_EQUALS GREATER_THAN LESS_THAN LESS_THAN_OR_EQUALS LOGIC_EQUALS LOGIC_NOT_EQUALS
%left PLUS MINUS
%left STAR SLASH PERCENT
%right DOUBLE_STAR
%left LOGIC_NOT
%left LEFT_PARENTESIS
%right RIGHT_PARENTHESIS

%type <str> expression function_call  array_call list_of_arguments var_decl list_of_assignments array_type data_type
%type <str> expr_or_string var_decl_section lines line const_decl const_decl_section prologue function_decl parameters
%type <str> function_body  statement return_line assignment assignment_line if_stmt else_stmt statements for_loop while_loop
%type <str> function_decl_section func_begin function_body5
%type <str> line1  line2  line3  line4  line5  line6 line7  line8  //priorities of body types
%type <str> function_body1 function_body2 function_body3 function_body4 if_stmt1 if_stmt2 if_stmt3
%type <str> id_func_arr_solver id_func_arr_solver1 id_or_array
// declaration of the starting point of the parsing.
%start prologue



%%  // the beginning of the rules section
prologue : lines{        // the print is at the top of the recursion tree! important.
        FILE *fp;
        fp = fopen("transpiled.c", "w+");
        fputs(c_prologue, fp);
        fputs("#include <math.h>\n", fp);
        fputs($1, fp);
        fputs("\n", fp);
        fclose(fp); }
;
        
lines :  line {$$ = $1;}  // just to read multiple lines
    | lines line {$$ = template("%s\n%s", $1, $2);} 
;

// this is the parent of    
line :  line8 | line1 | line2 | line3 | line4| line5 | line6 | line7 ;

 // the below "table" implements the "optional" features of the code.
line8 : const_decl_section var_decl_section  function_decl_section  func_begin {$$ = template("%s\n%s\n%s\n %s",$1, $2, $3,$4);};
line1 : const_decl_section  function_decl_section  func_begin {$$ = template("%s\n%s\n%s",$1, $2, $3);};
line2 : var_decl_section  function_decl_section  func_begin {$$ = template("%s\n%s\n%s",$1, $2, $3);};
line3 : const_decl_section var_decl_section func_begin {$$ = template("%s\n%s\n%s",$1, $2, $3);};
line4 : function_decl_section  func_begin {$$ = template("%s\n%s",$1, $2);};
line5 : var_decl_section   func_begin {$$ = template("%s\n%s",$1, $2);};
line6 : const_decl_section  func_begin {$$ = template("%s\n%s",$1, $2);};
line7 : func_begin ;


// here the FUNC kewyord is removed from the expression because it doesnt let the begin function to be recognized. TODO: fix it!.       
func_begin : FUNC KW_BEGIN LEFT_PARENTESIS RIGHT_PARENTHESIS LEFT_CURLY function_body RIGHT_CURLY {$$ = template("void main(){\n%s\n}", $6);} ;

// TODO remove 1 connflict!
function_decl_section : function_decl  | function_decl_section function_decl {$$ = template("%s\n%s", $1, $2);} ;

function_decl : FUNC ID LEFT_PARENTESIS parameters RIGHT_PARENTHESIS data_type LEFT_CURLY function_body RIGHT_CURLY
{$$ = template("%s %s(%s){\n%s\n}",$6, $2, $4,$8);}
|FUNC ID LEFT_PARENTESIS parameters RIGHT_PARENTHESIS LEFT_CURLY function_body RIGHT_CURLY
{$$ = template("void %s(%s){\n%s\n}", $2, $4,$7);}
;

// the parameters that we give to a function.
parameters : id_or_array data_type{ $$ = template("%s %s",$2, $1);}
           | parameters COMMA id_or_array data_type {$$ = template("%s,%s %s",$1, $4,$3);};
           | %empty {$$="";}
;           
           
// TODO: mke var and const decl section OPTIONAL! (and also statements optional!)
function_body :  function_body1 | function_body2 | function_body3 | function_body4 | function_body5 ;

// Implementation of "optional" features inside functions.(and their hierarchy)
function_body1 :  var_decl_section  const_decl_section  statements {$$ = template("%s\n%s\n%s", $1,$2,$3);};
function_body5 :  const_decl_section var_decl_section  statements {$$ = template("%s\n%s\n%s", $1,$2,$3);};
function_body2 :  var_decl_section  statements {$$ = template("%s\n%s", $1,$2);};
function_body3 :  const_decl_section  statements {$$ = template("%s\n%s", $1,$2);};
function_body4 :  statements ;// only the statements are mandatory.

// the statements are all the commands of the PI language that can be used for example, in a function body.
statements : statements statement {$$ = template("%s \n%s",$1,$2);}
             |statement { $$ = $1; }
;  
             
statement : assignment_line {$$ = template("%s;",$1);} 
             | if_stmt {$$ = template("%s;",$1);} 
             | return_line {$$ = template("%s;",$1);}
             | function_call SEMIC {$$ = template("%s;",$1);} 
             | BREAK SEMIC {$$ = template("break;");};  
             | CONTINUE SEMIC {$$ = template("continue;");}; 
             | while_loop | for_loop
;

// working for loop transpiler          
for_loop: FOR LEFT_PARENTESIS assignment SEMIC expression SEMIC assignment RIGHT_PARENTHESIS statement {$$=template("for (%s;%s;%s)\n%s", $3, $5, $7, $9);}
            | FOR LEFT_PARENTESIS assignment SEMIC expression SEMIC assignment RIGHT_PARENTHESIS LEFT_CURLY statements RIGHT_CURLY
            {$$=template("for (%s;%s;%s){\n%s\n}",$3, $5, $7, $10);}
;
//TODO add brackets in the statements!
while_loop : WHILE LEFT_PARENTESIS expression RIGHT_PARENTHESIS LEFT_CURLY statements RIGHT_CURLY {$$ = template("while (%s){ \n %s \n}",$3,$6);}
            | WHILE LEFT_PARENTESIS expression RIGHT_PARENTHESIS  statement {$$ = template("while (%s)\n%s",$3,$5);}  
;
            
// TODO: maybe instead of statements, we can use the function body.
if_stmt : if_stmt3 else_stmt{$$ = template("%s\n%s",$1,$2);}
        | if_stmt3  //TODO: fix the conflict from this exact line!
;

if_stmt1 : IF LEFT_PARENTESIS expression RIGHT_PARENTHESIS LEFT_CURLY statements RIGHT_CURLY {$$ = template("if (%s){ \n %s \n}",$3,$6); } ;

if_stmt2 : IF LEFT_PARENTESIS expression RIGHT_PARENTHESIS  statement {$$ = template("if (%s) \n %s ",$3,$5); } ;

if_stmt3: if_stmt1 | if_stmt2;

else_stmt : ELSE statement {$$ = template("else \n %s", $2);}; 
            | ELSE LEFT_CURLY statements RIGHT_CURLY {$$ = template("else \n{\n%s\n}", $3);};


// a line where an assignment takes place
assignment_line : assignment SEMIC {$$ = template("%s", $1);};

id_or_array: ID | array_call ;  // to accept array " calls" at the left side of an assignment

// wee need an assignment without a SEMIC for use inside the for() loop
assignment : id_or_array ASSIGN expr_or_string {$$ = template("%s=%s", $1,$3);};

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

return_line : RETURN expr_or_string SEMIC{$$=template("return %s",$2);}
            | RETURN SEMIC{$$=template("return");}
               //| %empty {$$=template("");}
;
// the assignments that go inside a variable or constant declaration
list_of_assignments: ID ASSIGN  expr_or_string {$$ = template("%s=%s",$1,$3);}
                    | ID ASSIGN  expr_or_string COMMA list_of_assignments {$$ = template("%s=%s, %s",$1,$3,$5);}
                    |id_or_array COMMA list_of_assignments {$$=template("%s,%s",$1,$3);}
                    |id_or_array {$$=template("%s",$1);};
                    
// TODO: make this rule recognize special functions. It doesnt, even if they are here.                    
expr_or_string: expression | STR ;  // we want to assign either an expression, or a string.

// a list of the data types("int","real","bool" etc.)
data_type:  // int-->int , real --> double, string-->char*, bool--> int(0 or 1) etc
    INT_TYPE  { $$ =template("int");} 
    | REAL_TYPE { $$ =template("double");} 
    | BOOL { $$ = template("int");} 
    | STR_TYPE { $$ = template("char*");} 
    | array_type { $$ = $1;} 
;
  
array_type : array_call data_type {$$ = template("%s %s",$2, $1);}  // TODO: doesnt accept this grammar, fix it.
           | LEFT_BRACKET expression RIGHT_BRACKET data_type {$$ = template("[%s] %s", $2, $4);} 
           | LEFT_BRACKET RIGHT_BRACKET data_type {$$ = template("%s*",$3);}
           

;
// all the mathematical and logical expressions, including variable names and function calls.
expression :  LEFT_PARENTESIS expression RIGHT_PARENTHESIS { $$ = template("(%s)", $2);}
       | expression PLUS expression { $$ = template("%s+%s", $1, $3);}
       | expression MINUS expression { $$ = template("%s-%s", $1, $3);}
       | expression STAR expression { $$ = template("%s*%s", $1, $3);}
       | expression SLASH expression { $$ = template("%s/%s", $1, $3);}
       | expression GREATER_THAN expression { $$ = template("%s>%s", $1, $3);}
       | expression GREATER_OR_EQUALS expression { $$ = template("%s>=%s", $1, $3);}
       | expression LESS_THAN expression { $$ = template("%s<%s", $1, $3);}
       | expression LESS_THAN_OR_EQUALS expression { $$ = template("%s<=%s", $1, $3);}
       | expression PERCENT expression { $$ = template("%s%s%s", $1,"%", $3);}
       | expression DOUBLE_STAR expression { $$ = template("pow(%s,%s)", $1, $3);}
       | expression LOGIC_EQUALS expression { $$ = template("%s==%s", $1, $3);}
       | expression LOGIC_NOT_EQUALS expression { $$ = template("%s!=%s", $1, $3);}
       | expression LOGIC_AND expression { $$ = template("%s&&%s", $1, $3);}
       | expression LOGIC_OR expression { $$ = template("%s||%s", $1, $3);}
       | LOGIC_NOT expression { $$ = template("!%s", $2);}
       | PLUS expression { $$ = template("%s", $2);}
       | MINUS expression { $$ = template("(-1)*%s", $2);}
       | INT   // print as is 
	   | REAL // the default action is $$=$1
       | ID   // in conflict with the id_func_arr_solver(which already solves 1)
       | FALSE {$$ = template("0");}
       | TRUE {$$ = template("1");}    
       //| function_call {$$ = $1;} 
       //| array_call {$$ = $1;}  // array call  //the other last confl comes from ID,func_call and array_call
       | id_func_arr_solver
       // | ID LEFT_BRACKET RIGHT_BRACKET {$$ = template("%s*", $1);}
;
       
id_func_arr_solver : ID id_func_arr_solver1 {$$ = template("%s %s", $1, $2);}
                    |ID LEFT_BRACKET RIGHT_BRACKET {$$ = template("*%s", $1);}
                 
 
id_func_arr_solver1: LEFT_PARENTESIS list_of_arguments RIGHT_PARENTHESIS {$$ = template("(%s)",$2);};  // for the function
                   | LEFT_BRACKET expression RIGHT_BRACKET {$$ = template("[%s]", $2);}  // for the array
                   
 ;                
                   
//id_func_arr_solver3 : ID | id_func_arr_solver
 
// the format of a function call
function_call : ID LEFT_PARENTESIS list_of_arguments RIGHT_PARENTHESIS
                {$$ = template("%s(%s)",$1,$3);}
 ;
// the list of arguments of a function
list_of_arguments : expr_or_string {$$ = template("%s",$1);}
                    | list_of_arguments COMMA expr_or_string {$$ = template("%s,%s",$1,$3);}
                    | %empty {$$="";}
;
// the format of an array "call" or reference.                  
array_call : ID LEFT_BRACKET expression RIGHT_BRACKET {$$ = template("%s[%s]",$1, $3);}
           | ID LEFT_BRACKET  RIGHT_BRACKET {$$ = template("*%s",$1);}
;


%%
void main() {
	if (yyparse() != 0)
		printf("\n-->Pi Compiler: Invalid Input!<--\n");
    else
        printf("-->Pi Compiler: Compilation Succeeded!<--\n\n");
}
