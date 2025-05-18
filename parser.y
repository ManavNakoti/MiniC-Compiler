%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"    // Symbol table header

extern int yylex();
extern int yylineno;
void yyerror(const char *s);
%}

%union {
    char* str;
    float num;
    int type;       // For storing types like INT, FLOAT, etc.
}

/* Token declarations */
%token <str> ID
%token <num> NUM

%token INT FLOAT CHAR VOID
%token IF ELSE WHILE FOR RETURN

%token EQ NEQ LE GE LT GT
%token ASSIGN PLUS MINUS MUL DIV MOD

%token SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE

/* Specify types for nonterminals */
%type <type> type expression term factor

/* Precedence */
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

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
      type ID {
          insert_symbol($2, $1);
      }
    ;

type:
      INT { $$ = TYPE_INT; }
    | FLOAT { $$ = TYPE_FLOAT; }
    | CHAR { $$ = TYPE_CHAR; }
    | VOID { $$ = TYPE_VOID; }
    ;

assignment:
      ID ASSIGN expression {
          Symbol *sym = lookup_symbol($1);
          if (!sym) {
              fprintf(stderr, "Error: undeclared variable %s at line %d\n", $1, yylineno);
              exit(1);
          }
          if (sym->type != $3) {
              fprintf(stderr, "Type error: cannot assign type %d to variable %s of type %d at line %d\n",
                      $3, $1, sym->type, yylineno);
              exit(1);
          }
      }
    ;

expression:
      expression PLUS term {
          if ($1 != $3) {
              fprintf(stderr, "Type error in addition at line %d\n", yylineno);
              exit(1);
          }
          $$ = $1;
      }
    | expression MINUS term {
          if ($1 != $3) {
              fprintf(stderr, "Type error in subtraction at line %d\n", yylineno);
              exit(1);
          }
          $$ = $1;
      }
    | term {
          $$ = $1;
      }
    ;

term:
      term MUL factor {
          if ($1 != $3) {
              fprintf(stderr, "Type error in multiplication at line %d\n", yylineno);
              exit(1);
          }
          $$ = $1;
      }
    | term DIV factor {
          if ($1 != $3) {
              fprintf(stderr, "Type error in division at line %d\n", yylineno);
              exit(1);
          }
          $$ = $1;
      }
    | factor {
          $$ = $1;
      }
    ;

factor:
      NUM {
          $$ = TYPE_FLOAT;  // Treat numeric literals as float
      }
    | ID {
          Symbol *sym = lookup_symbol($1);
          if (!sym) {
              fprintf(stderr, "Error: undeclared variable %s at line %d\n", $1, yylineno);
              exit(1);
          }
          $$ = sym->type;
      }
    ;

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
