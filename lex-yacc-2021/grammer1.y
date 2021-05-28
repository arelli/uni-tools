/* includes */%{
    #include "pilib.h"  // aftakia because it is user defined
%}



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


%empty empty_lex


%%  // the beginning of the rules section

%start main_body  // the action thet begins the program

/*rules */

main_body : opt_const_decl opt_var_decl opt_func_decl start_function
{
    if (yyerror_count == 0) {
    // include the pilib.h file
    puts(c_prologue); 
    printf("/* my program title */ \n\n");
    printf("%s\n%s\n%s\n%s\n", $1,$2,$3,$4);
};

/* begin function declaration */
start_function : FUNC_KEYWORD BEGIN_FUNC LEFT_PAREN RIGHT_PAREN LEFT_CURLY main_body_of_begin RIGHT_CURLY;
{
    printf("int main() {\n%s\n} \n", $7);
}

function_body :  opt_var_decl  opt_const_decl statements 
{$$ = template("%s \n %s \n %s ", $1,$2,$3);};

exp_or_string : expression { $$ = template("%s",$1);}
               | STR { $$ = template("%s",$1);}
               | IDENTIFIER { $$ = template("%s",$1);}  // TODO check if needed


const_decl : KEYWORD_CONST IDENTIFIER ASSIGNMENT_KEYWORD  exp_or_string data_type SEMIC
{$$ = template("const %s %s =  %s", $5,$2,$4);}

var_decl : KEYWORD_VAR list_of_assignments data_type SEMIC
{$$ = template("%s %s;", $3,$2);}

//for the var_decl to be able to assign a list of variables
list_of_assignments: IDENTIFIER ASSIGNMENT_KEYWORD  expression {$$ = template{"%s=%s",$1,$3);}
                    | IDENTIFIER ASSIGNMENT_KEYWORD  expression ',' list_of_assignments{$$ = template{"%s=%s, %s",$1,$3,$5);}
                    |IDENTIFIER ',' list_of_assignments {$$=template("%s,%s",$1,$3);}
                    |IDENTIFIER {$$=template("%s",$1);}

func_declaration : FUNC_KEYWORD IDENTIFIER LEFT_PAREN parameters RIGHT_PAREN  
                    data_type LEFT_CURLY body_of_function RIGHT_CURLY
                    {$$=template("%s %s(%s){\n%s\n}",$6,$2,$4,$8);};
                    
parameters : exp_or_string { $$ = template("$s",$1);}
            | parameters COMMA exp_or_string { $$ = template("%s,$s",$1, $3);}
                    
body_of_simple_function : opt_var_decl  opt_const_decl statements return_line
{$$ = template("%s \n %s \n %s \n %s", $1,$2,$3,$4);}
;

return_line : KEYWORD_RETURN exp_or_string {$$=template("return %s",$2);}
               | %empty {$$=template("");};

statement:  // all the statements(one line only!)
            // for, while,if(all revursive), assignment_line, function_call,break,continue
            
many_statements : statement statements %empty {$$=template("%s \n %s", $1, $2);};
            | %empty {$$=template("");};
            

block_of_code : LEFT_CURLY body_of_simple_function RIGHT_CURLY
{$$ = template("{ %s }", $2);};


for_loop : FOR_KEYWORD IDENTIFIER

while_loop: WHILE_KEYWORD LEFT_PAREN expression RIGHT_PAREN LEFT_CURLY function_body RIGHT_CURLY SEMIC
{$$ = template("while (%s)\n{ %s \n};", $3,$6);};

if_stmt : IF_KEYWORD LEFT_PAREN expression RIGHT_PAREN block_of_code else_stmt {$$ = template("if (%s) \n %s \n %s",$3, $5, $6);}
        | IF_KEYWORD LEFT_PAREN expression RIGHT_PAREN statement else_stmt {$$ = template("if (%s) \n %s \n %s",$3, $5, $6);}

else_stmt : ELSE_KEYWORD if_stmt  {$$ = template("else %s", $2);};
            | ELSE_KEYWORD statement {$$ = template("else %s", $2);};
            | ELSE_KEYWORD block_of_code {$$ = template("else %s", $2);};
            | %empty {$$=template("");};  // else is not mandatory 

opt_func_decl : func_declaration {$$=template("%s %s")}
               | opt_func_decl SEMIC func_declaration {$$ = template("%s;\n%s", $2, $1);}
               | empty_lex  {$$=template("");}
               
opt_var_decl : var_decl {$$=template("%s %s")}
                | opt_var_declaration SEMIC var_decl {$$ = template("%s;\n%s", $2, $1);}
                | empty_lex {$$=template("");}

opt_const_decl : const_decl  {$$ = $1;}
                | opt_const_decl SEMIC const_decl {$$ = template("%s;\n%s", $2, $1);}
                | empty_lex {$$=template("");}





data_type:  // int-->int , real --> double, string-->char*, bool--> int(0 or 1) etc
    KEYWORD_INT  { template("int");} 
    | KEYWORD_REAL { template("double");} 
    | KEYWORD_BOOLEAN { template("bool");} 
    | STR {  template("char*");} 
    | array_type { $$ = $1;} 
  
  
array_type : IDENTIFIER '['expression '] ' data_type  
                {template("%s %s[%s]",$5, $1, $3);}
                | '[] ' data_type
                {template("%s*",$4);}
;

assignment_line : IDENTIFIER ASSIGNMENT_KEYWORD expression SEMIC
                  {$$ = template("%s=%s;", $1,$3 );};

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


