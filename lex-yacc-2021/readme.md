# About the project
Design and implememnt a simple transpiler(not compiler-it just transpiles an imaginary language named PI, into c language that can then be compiled with gcc!) for the Theory of Computation class at T.U.C. The main goal of the class was first to understand the basics(lexical analysis, regular expressions and languages, grammar analysis, set theory), then move to all kinds of Automata and their working principles. We used the tool [flex](https://github.com/westes/flex) (fast lexical analyzer)  because it is open source, included in the most linux distros and well-documented and easy to use. The choice to use [bison](https://www.gnu.org/software/bison/) (the open source equivalent of yacc-yet another compiler compiler) is because bison is also open source, is quite capable at LR(1) grammars (wikipedia: <i>LR(1) parsers can handle many but not all common grammars. It is usually possible to manually modify a grammar so that it fits the limitations of LR(1) parsing</i>), and has also tons of documentation. The two programs working together to transpile one grammar to another, is the practical implementation of all the theory the class teaches.
## How to Compile and Run
To begin with, you have to run bison to the .y file, with the flags shown below:
```
bison -d -v -r all grammer.y
```
this is done for the Bison(yacc) to create the files "grammer1.tab.c" and "grammer1.tab.h", that we are gonna include in the flex file(lexer1.l, in our case are already included in the file).
These two files let the two programms communicate through the inclusion of mutual files. The return variables of the flex file, are directly referencing the Biosn tokens(same names!). Also, the parameter -r all is for bison to create a debug file, called grammar1.[output](https://www.gnu.org/software/bison/manual/html_node/Output-Files.html), that is **very** useful for debuging, especially solving conflicts([shift/reduce](https://www.gnu.org/software/bison/manual/html_node/Shift_002fReduce.html) and [reduce/reduce](https://www.gnu.org/software/bison/manual/html_node/Reduce_002fReduce.html)).
Then we can run:
```
flex lexer.l
```
to create the flex file "lex.yy.c"(default output filename). This file is included later in the gcc compilation of the bison file:
```
 gcc -o grammer grammer.tab.c lex.yy.c cgen.c -lfl
```
The "cgen.c" file is given to us by the university, and we include it in the compilation for the resulting compiler and program to be able to use it. The flag -lfl is to 
tell to the gcc that we need to include the flex libraries(Link FLex). The above results in a executable grammer1 file, which is essentialy our compiler:
```
./grammer < [sometestprogram].pi
```
We can give our compiler any input file written in "Pi", and it will translate it to C language(C99 standard) in the file "trasnpiled.c". Of course, we can then compile the program:
```
gcc transpiled.c -lm -o [executable_name]
```
The -lm library is to include the "Math.h" library, which is used in the "\*\*" notation of Pi ( it has to be implemented using function pow() ).
Last step: run the program.
```
./[executable_name]
```
Done!
# The Pi Language
## Syntax rules
The structure of the program is the following (in order):
```
[Constant Declaration Section](optional)
                  .
                  .
[Variable Declaration Section](optional)
                  .
                  .
[Function Declaration Section](optional)
                  .
                  .
[Begin() Function Body](mandatory)
```
The begin() function at the end, is the equivalent with main() in C, being mandatory and the main code execution part of the program. It is literally translated to main() by our parser.
By convention, the program is stored in a file with suffix .pi but this is not limiting, as we do not check this in the parser.
### Constant Declaration
We declare constants at the top of the file. The syntax is as follows:
```
const [const_name] = [value] [data_type];
```
Every line ends with a semicolon, except some special statements(if, for and while).
### Variable Declaration
This is a bit more complex, as we can have lists of assignments for same-type-variables in the same statement, as seen below:
```
var [var_name] [data_type];
var [var_name]=[value] [data_type];
var [var_name]=[value],[var2_name] [data_type];
var [var_name],[var1_name],[var2_name] = [value] [data_type];
```
As we see, we can declare lists of variables in one line. This needs recursion in the part of the parser(bison).
### Function Declaration
Structure of a function declaration:
```
func [name_of_func]([list_of_parameters]) [data_type] {
 [local variable or constant declaration section](order doesnt matter between variables and constants)
 [statements section](mandatory)
 [return statement](optional)
}
```
Note that the list of parameters can be empty, the name can't start with a number, and the data type specification is mandatory.
#### What are the Statements?
As statements we define the following "commands":
-> Assign commands 
```
variable_a = functionb();
```
-> Function calls:
```
print_my_data("this is a string",index1,index2);
```
-> If statements:
```
if((a>b) and is_blue(ball_color)){
 a=155;
 is_red = True;
}
else
 writeString("May be blue");
 
```
Note that we can use nested else/if statements, and both accept single statements without curly brackets, and blocks of code **with** curly brackets. Also, there is no semicolon needed at the end.
-> While Loops
```
while (counter<38){
 writeString("The counter is ");
 writeInt(counter);
 }
 ```
 No semicolon needed here either.
 -> For Loops
 ```
 var count int;
 for (count = 5; count < 100; count = count + 2){
  do_stuff();
 }
 ```
 No semicolon at the end needed here either.
 -> Break and Continue statements:
 ```
 break;
 continue;
 ```
 -> Special functions(implemented by the university)
 ```
 writeInt(integer);
 writeString(string);
 writeReal(real);
 readInt();
 readReal();
 readString();
 ```
 -> Return Statement;
 ```
 return;
 //or
 return [value];
 ```
 ## Example Code:
 ```
 /* This is an example code that calculates the twin prime numbers from 0 
 up to a given value. This is a demonstration of a multi line comment. */
 
 // below is a declaration of a function. Also, this is a one line comment.
 func ask_for_number() int {
    var input int;   <-- this is a variable declaration. Also, this is another type of signle-line comments.
    writeString("Enter a number: ");  <-- this is a function implemented inside the pilib.h file(like printf)
    input = readInt();  <-- readInt() reads an integer from the input.
    return input;
}

func do_nothing() int{  <-- this function serves no purpose.
    var a int;
    a=10;  // the statements section is mandatory.
    // do nothing!
}

func is_prime(input int) int {
    var prime_flag,counter int;
    if (input == 0)
        return 1;
    for (counter=2;counter<input;counter = counter + 1){  
        if (input%counter==0){  <-- if a divisor is found...
            return 1; <-- ...it means that the input is not prime.
        }
    }
    return prime_flag;  <-- if prime, the program reaches that point and returns 0
}

func begin() {  
    var given_number=1,return_value=1, num1, num2,counter,count_tmp,counter2 = 0, distance int; <-- multiple variable declaration
    writeString("This is a program that asks for a number \n");
    writeString("and shows you the twin primes until there.\n");
    given_number = ask_for_number(); <-- ask for a number from the input
    for (counter=2;counter<given_number;counter=counter+1){
        if((is_prime(counter)==0) and (is_prime(counter+2)==0)){  // returning 0 means it is a prime!
            writeString("The numbers ");
            writeInt(counter);
            writeString(" and ");
            count_tmp = counter + 2;
            writeInt(count_tmp);
            writeString(" are twin primes!!\n");
            counter2 = counter2 + 1;
        }  <-- at the end of an if/else statement, there is no semicolon.
    }
    writeString("Found a total of ");
    writeInt(counter2);
    writeString(" twin primes. Continue to prove the twin prime conjecture.\n");
}
 ```
 
