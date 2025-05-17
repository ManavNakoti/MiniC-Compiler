%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yylineno;
void yyerror(const char *s);
%}

%union {
    char* str;
    float num;
}

/* Token Declarations */
%token <str> ID
%token <num> NUM

%token INT FLOAT CHAR VOID
%token IF ELSE WHILE FOR RETURN

%token EQ NEQ LE GE LT GT
%token ASSIGN PLUS MINUS MUL DIV MOD

%token SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

/* Grammar Rules Start Here */
%%
program:
      program statement
    | /* empty */
    ;

statement:
      declaration SEMICOLON
    | assignment SEMICOLON
    | expression SEMICOLON
    | compound_statement
    | if_statement
    | loop_statement
    ;

compound_statement:
      LBRACE statement_list RBRACE
    ;

statement_list:
      statement_list statement
    | /* empty */
    ;

declaration:
      type ID                 { printf("Declaration: %s\n", $2); }
    ;

type:
      INT
    | FLOAT
    | CHAR
    | VOID
    ;

assignment:
      ID ASSIGN expression    { printf("Assignment to %s\n", $1); }
    ;

expression:
      expression PLUS term
    | expression MINUS term
    | term
    ;

term:
      term MUL factor
    | term DIV factor
    | factor
    ;

factor:
      NUM
    | ID
if_statement:
      IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
    | IF LPAREN expression RPAREN statement ELSE statement
    ;

loop_statement:
      WHILE LPAREN expression RPAREN statement
    | FOR LPAREN assignment SEMICOLON expression SEMICOLON assignment RPAREN statement
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error at line %d: %s\n", yylineno, s);
}

int main() {
    return yyparse();
}
