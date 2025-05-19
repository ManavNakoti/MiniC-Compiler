%{
#include "symbol_table.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);
extern int yylineno;
void yyerror(const char *s);
%}

%union {
    char* str;
    float num;
    DataType dtype;
}

/* Token declarations */
%token <str> ID
%token <num> NUM

%token INT FLOAT CHAR VOID
%token IF ELSE WHILE FOR RETURN

%token EQ NEQ LE GE LT GT
%token ASSIGN PLUS MINUS MUL DIV MOD

%token SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE

%type <dtype> type  // This declares that the non-terminal 'type' will have a value
                    // of type DataType (accessed via the 'dtype' field of the union)
%type <dtype> expression
%type <dtype> factor

/* Operator Precedence and Associativity */
// Lower an operator is in this list, the lower its precedence
// Operators on the same line have the same precedence.
// %left means left-associative, %right means right-associative
// %nonassoc means the operator is not associative (e.g., a < b < c is an error)

%left GT LT GE LE EQ NEQ  // Relational and Equality operators
%left PLUS MINUS          // Additive operators
%left MUL DIV MOD         // Multiplicative operators
// You can add unary operators here later if needed (e.g., %right UMINUS NOT)

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
    LBRACE { symbol_table_open_scope(); } statement_list RBRACE { symbol_table_close_scope(); }
    ;

statement_list:
      statement_list statement
    | /* empty */
    ;

declaration:

    type ID {
        // printf("Declaration: Type '%s', Name: '%s'\n", datatype_to_string($1), $2);
        SymbolEntry *entry = symbol_table_insert($2, $1); // $1 is DataType from 'type'
        if (entry == NULL) {
            char error_msg[256];
            sprintf(error_msg, "Semantic error: Identifier '%s' already declared in this scope.", $2);
            yyerror(error_msg);
        }
        // No need to free $2 here if symbol_table_insert makes its own copy (which it does via strdup)
        // and assuming yylval management by Bison handles the original yylval.str if not used elsewhere.
    }
    ;

type:
    INT     { $$ = TYPE_INT; }
    | FLOAT { $$ = TYPE_FLOAT; }
    | CHAR  { $$ = TYPE_CHAR; }
    | VOID  { $$ = TYPE_VOID; }
    ;

assignment:
    ID ASSIGN expression {
        // printf("Assignment to %s\n", $1);
        SymbolEntry* entry = symbol_table_lookup($1);
        if (entry == NULL) {
            char error_msg[256];
            sprintf(error_msg, "Semantic error: Identifier '%s' not declared for assignment.", $1);
            yyerror(error_msg);
        }
    }
    ;

expression:
    expression PLUS expression      { /* Action if needed, e.g., for AST: $$ = new_ast_node('+', $1, $3); */ }
  | expression MINUS expression     { /* Action if needed */ }
  | expression MUL expression       { /* Action if needed */ }
  | expression DIV expression       { /* Action if needed */ }
  | expression MOD expression       { /* Action if needed */ }
  | expression GT expression        { /* Action if needed, e.g., for type checking or AST */ }
  | expression LT expression        { /* Action if needed */ }
  | expression GE expression        { /* Action if needed */ }
  | expression LE expression        { /* Action if needed */ }
  | expression EQ expression        { /* Action if needed */ }
  | expression NEQ expression       { /* Action if needed */ }
  | LPAREN expression RPAREN        { $$ = $2; /* Value of parenthesized expr is the inner expr's value */ }
  | factor                          { /* Value of expression can be a factor directly */ }
  ;

factor:
    NUM {
        // Assuming NUM from your lexer is always treated as float for now
        // and its yylval field is 'num'.
        // We'll assign its type as TYPE_FLOAT.
        $$ = TYPE_FLOAT;
    }
  | ID {
        SymbolEntry* entry = symbol_table_lookup($1); // $1 is char* (name of ID)
        if (entry == NULL) {
            char error_msg[256];
            sprintf(error_msg, "Semantic error: Identifier '%s' not declared.", $1);
            yyerror(error_msg);
            $$ = TYPE_UNDEFINED; // Assign a default/error type
        } else {
            $$ = entry->type;    // The "value" of the ID factor is its DataType
        }
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
    symbol_table_init(); // Initialize the symbol table
    printf("Starting parse...\n"); // Debug print
    int result = yyparse();
    if (result == 0) {
        printf("Parsing completed successfully!\n");
    } else {
        printf("Parsing failed with %d error(s).\n", result); // result from yyparse isn't error count
    }                                                        // Number of yyerror calls is more indicative
    symbol_table_print(); // Print table at the end for debugging
    return result; // Or return 0 if yyparse was successful, 1 otherwise
}
