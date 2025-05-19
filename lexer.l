%{
#include "symbol_table.h"
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
%}

DIGIT       [0-9]
LETTER      [a-zA-Z_]
ID          {LETTER}({LETTER}|{DIGIT}|"_")*
NUM         {DIGIT}+(\.{DIGIT}+)?

%%

"int"           { printf("LEXER: Token INT, Text '%s'\n", yytext); return INT; }
"float"         { printf("LEXER: Token FLOAT, Text '%s'\n", yytext); return FLOAT; }
"char"          { printf("LEXER: Token CHAR, Text '%s'\n", yytext); return CHAR; }
"void"          { printf("LEXER: Token VOID, Text '%s'\n", yytext); return VOID; }
"if"            { printf("LEXER: Token IF, Text '%s'\n", yytext); return IF; }
"else"          { printf("LEXER: Token ELSE, Text '%s'\n", yytext); return ELSE; }
"while"         { printf("LEXER: Token WHILE, Text '%s'\n", yytext); return WHILE; }
"for"           { printf("LEXER: Token FOR, Text '%s'\n", yytext); return FOR; }
"return"        { printf("LEXER: Token RETURN, Text '%s'\n", yytext); return RETURN; }

"=="            { printf("LEXER: Token EQ, Text '%s'\n", yytext); return EQ; }
"!="            { printf("LEXER: Token NEQ, Text '%s'\n", yytext); return NEQ; }
"<="            { printf("LEXER: Token LE, Text '%s'\n", yytext); return LE; }
">="            { printf("LEXER: Token GE, Text '%s'\n", yytext); return GE; }
"<"             { printf("LEXER: Token LT, Text '%s'\n", yytext); return LT; }
">"             { printf("LEXER: Token GT, Text '%s'\n", yytext); return GT; }
"="             { printf("LEXER: Token ASSIGN, Text '%s'\n", yytext); return ASSIGN; }
"+"             { printf("LEXER: Token PLUS, Text '%s'\n", yytext); return PLUS; }
"-"             { printf("LEXER: Token MINUS, Text '%s'\n", yytext); return MINUS; }
"*"             { printf("LEXER: Token MUL, Text '%s'\n", yytext); return MUL; }
"/"             { printf("LEXER: Token DIV, Text '%s'\n", yytext); return DIV; }
"%"             { printf("LEXER: Token MOD, Text '%s'\n", yytext); return MOD; }

";"             { printf("LEXER: Token SEMICOLON, Text '%s'\n", yytext); return SEMICOLON; }
","             { printf("LEXER: Token COMMA, Text '%s'\n", yytext); return COMMA; }
"("             { printf("LEXER: Token LPAREN, Text '%s'\n", yytext); return LPAREN; }
")"             { printf("LEXER: Token RPAREN, Text '%s'\n", yytext); return RPAREN; }
"{"             { printf("LEXER: Token LBRACE, Text '%s'\n", yytext); return LBRACE; }
"}"             { printf("LEXER: Token RBRACE, Text '%s'\n", yytext); return RBRACE; }

{ID}            { printf("LEXER: Token ID, Text '%s'\n", yytext); yylval.str = strdup(yytext); return ID; }
{NUM}           { printf("LEXER: Token NUM, Text '%s'\n", yytext); yylval.num = atof(yytext); return NUM; }

\n              { yylineno++; /* your debug printf if you want */ }
[ \t\r]+       { /* ignore other whitespace */ }

.               { printf("LEXER: Unknown character: '%s'\n", yytext); /* Optionally return an error token or skip */ }

%%

int yywrap() {
    return 1;
}
