Making a simple transpiler(not compiler. it just transpiles an imaginary language named PI, into c language that can then be compiled with gcc!) for the Theory of Computation class at Technical University of Crete.
First run 
```
bison -d -v -r all grammer1.y
```
this is done for the Bison(yacc) to create the files "grammer1.tab.c" and "grammer1.tab.h", that we are gonna include in the flex file(lexer1.l, in our case are already included in the file).
These two files let the two programms communicate through the inclusion of mutual files. The return variables of the flex file, are directly referencing the Biosn tokens(same names!).
Then we can run:
```
flex mylexer.l
```
to create the flex file "lex.yy.c". This file is included later in the gcc compilation of the bison file:
```
 gcc -o grammer1 grammer1.tab.c lex.yy.c cgen.c -lfl
```
The "cgen.c" file is given to us by the university, and we include it in the compilation for the resulting compiler and program to be able to use it. The flag -lfl is to 
tell to the gcc that we need to include the flex libraries(Link FLex). The above results in a executable grammer1 file, which is essentialy our compiler:
```
./grammer1 < [sometestprogram].pi
```
or, if the output c code is in the stdout:
```
./grammer1 < [sometestprogram].pi > [outputfile].c
```
We can give our compiler any input file written in "Pi", and it will translate it to C language(C99 standard). Of course, we can then compile the program:
```
gcc [outputfile].c -lm -o [executable_name]
```
The -lm library is to include the "Math.h" library, which is used in the "\*\*" notation of Pi ( it has to be implemented using function pow() ).
Last step: run the program.
```
./[executable_name]
```
Done!
 
