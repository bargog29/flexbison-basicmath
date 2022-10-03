%{
#include <stdlib.h>
#include "proiect.h"
#include "proiect.tab.h"
void yyerror(char *);
%}
%%
[a-z] {
yylval.sIndex = *yytext - 'a';
return VARIABLE;
}
[A-Z] {
yylval.sIndex = *yytext - 'A';
return VARIABLE;
}
0 {
yylval.iValue = atoi(yytext);
return INTEGER;
}
[1-9][0-9]* {
yylval.iValue = atoi(yytext);
return INTEGER;
}
[0]"."[0-9][0-9]* {
yylval.dValue = atoi(yytext);
return DOUBLE;
}
[1-9][0-9]*"."[0-9][0-9]* {
yylval.dValue = atoi(yytext);
return DOUBLE;
}
[-()<>=+*/;{}.] {
return *yytext;
}
">=" return GE;
"<=" return LE;
"==" return EQ;
"!=" return NE;
"++" return INC;
"--" return DEC;
"while" return WHILE;
"do" return DO;
"for" return FOR;
"if" return IF;
"else" return ELSE;
"print" return PRINT;
"write" return WRITE;
[ \t\n]+ ; /* ignore whitespace */
\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/ ;
 "//"[^}\n]* ;	
. yyerror("Unknown character");
%%
int yywrap(void) {
return 1;
}