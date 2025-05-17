%{
#include<stdio.h>
#include<stdlib.h>

int yylex(void);
int yyerror(const char *s);

%}

%union {
    int num;
    char *id;
}

%token <num> NUMBER
%token <id> ID
%token INT CHAR IF ELSE WHILE RETURN
%token EQ NE GT LT GE LE ASSIGN
%token PLUS MINUS MULT DIV
%token SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE


