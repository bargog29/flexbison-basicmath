%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "proiect.h"
extern FILE* yyin;
extern FILE* yyout;
/* prototypes */
nodeType *opr(int oper, int nops, ...);
nodeType *id(int i);
nodeType *con(int value);
void freeNode(nodeType *p);
int ex(nodeType *p);
int yylex(void);
void yyerror(char *s);
int sym[26]; /* symbol table */
%}
%union {
int iValue; /* integer value */
double dValue; /* integer value */
char sIndex; /* symbol table index */
nodeType *nPtr; /* node pointer */
};
%token <iValue> INTEGER
%token <sIndex> VARIABLE
%token <dValue> DOUBLE
%token WHILE IF PRINT DO FOR WRITE
%nonassoc IFX
%nonassoc ELSE
%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS
%nonassoc INC
%nonassoc DEC
%type <nPtr> stmt expr stmt_list
%%
program:
function { exit(0); }
;
function:
function stmt { ex($2); freeNode($2); }
| /* NULL */
;
stmt:
';' { $$ = opr(';', 2, NULL, NULL); }
| expr ';' { $$ = $1; }
| PRINT expr ';' { $$ = opr(PRINT, 1, $2); }
| WRITE expr ';' { $$ = opr(PRINT, 1, $2); }
| VARIABLE '=' expr ';' { $$ = opr('=', 2, id($1), $3); }
| WHILE '(' expr ')' stmt { $$ = opr(WHILE, 2, $3, $5); }
| FOR '(' stmt  expr ';'  expr ')' stmt { $$ = opr(FOR, 4 , $3, $4, $6,$8);    }
| DO stmt WHILE '(' expr ')' ';' { $$ = opr(DO, 2, $2, $5); }
| IF '(' expr ')' stmt %prec IFX { $$ = opr(IF, 2, $3, $5); }
| IF '(' expr ')' stmt ELSE stmt { $$ = opr(IF, 3, $3, $5, $7); }
| '{' stmt_list '}' { $$ = $2; }
;
stmt_list:
stmt { $$ = $1; }
| stmt_list stmt { $$ = opr(';', 2, $1, $2); }
;

expr:
INTEGER { $$ = con($1); }
| VARIABLE { $$ = id($1); }
| '-' expr %prec UMINUS { $$ = opr(UMINUS, 1, $2); }
| expr '+' expr { $$ = opr('+', 2, $1, $3); }
| expr '-' expr { $$ = opr('-', 2, $1, $3); }
| expr '*' expr { $$ = opr('*', 2, $1, $3); }
| expr '/' expr { $$ = opr('/', 2, $1, $3); }
| expr '<' expr { $$ = opr('<', 2, $1, $3); }
| expr '>' expr { $$ = opr('>', 2, $1, $3); }
| expr GE expr { $$ = opr(GE, 2, $1, $3); }
| expr LE expr { $$ = opr(LE, 2, $1, $3); }
| expr NE expr { $$ = opr(NE, 2, $1, $3); }
| expr EQ expr { $$ = opr(EQ, 2, $1, $3); }
| expr INC %prec INC { $$ = opr(INC,1,$1); }
| expr DEC %prec DEC { $$ = opr(DEC,1,$1); }
| INC expr %prec INC { $$ = opr(INC,1,$2); }
| DEC expr %prec DEC { $$ = opr(DEC,1,$2); }
| '(' expr ')' { $$ = $2; }
;
%%
nodeType *con(int value) {
nodeType *p;
/* allocate node */
if ((p = malloc(sizeof(nodeType))) == NULL)
yyerror("out of memory");
/* copy information */
p->type = typeCon;
p->con.val = value;
return p;
}
nodeType *id(int i) {
nodeType *p;
/* allocate node */
if ((p = malloc(sizeof(nodeType))) == NULL)
yyerror("out of memory");
/* copy information */
p->type = typeId;
p->id.i = i;
return p;
}
nodeType *opr(int oper, int nops, ...) {
va_list ap;
nodeType *p;
int i;
/* allocate node, extending op array */
if ((p = malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType *))) ==
NULL)
yyerror("out of memory");
/* copy information */
p->type = typeOper;
p->opr.oper = oper;
p->opr.nops = nops;
va_start(ap, nops);
for (i = 0; i < nops; i++)
p->opr.op[i] = va_arg(ap, nodeType*);
va_end(ap);
return p;
}
void freeNode(nodeType *p) {
int i;
if (!p) return;
if (p->type == typeOper) {
for (i = 0; i < p->opr.nops; i++)
freeNode(p->opr.op[i]);
}
free (p);
}
void yyerror(char *s) {
fprintf(stdout, "%s\n", s);
}
int main(int argc, char **argv) {
if (argc == 3){
        yyin = fopen(argv[1], "r");
        if(yyin == NULL){ printf("Eroare fis input\n");
            return -1;}
        yyout = fopen(argv[2], "w");
        if(yyout == NULL) {
            printf("Eroare fis output\n");
            return -2;}
	}
else if (argc ==2){
	printf("Nu ai specificat fis input si output\n Vom prelua date de la tastatura: \n");
	yyin = stdin;
	}
else{
	printf("Vom prelua date de la tastatura: \n");
            yyin = stdin;
	}

        yyparse();
        fclose(yyin);
        fclose(yyout);
        return 1;
}