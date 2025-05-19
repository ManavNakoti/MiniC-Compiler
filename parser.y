%{
#include "symbol_table.h"
#include "ast.h"
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
    struct ASTNode* ast;
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
//%type <dtype> expression
//%type <dtype> factor
%type <ast> program statement statement_list compound_statement declaration assignment expression factor if_statement loop_statement



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
      program statement    { $$ = make_ast_node(AST_STATEMENT_LIST, $1, $2, NULL); }
    | /* empty */          { $$ = NULL; }
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
      statement_list statement { $$ = make_ast_node(AST_STATEMENT_LIST, $1, $2, NULL); }
    | /* empty */              { $$ = NULL; }
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
        $$ = make_ast_node(AST_ASSIGN, make_leaf_node($1), $3, NULL);
    }
    ;

expression:
      expression PLUS expression      { $$ = make_ast_node(AST_ADD, $1, $3, NULL); }
    | expression MINUS expression     { $$ = make_ast_node(AST_SUB, $1, $3, NULL); }
    | expression MUL expression       { $$ = make_ast_node(AST_MUL, $1, $3, NULL); }
    | expression DIV expression       { $$ = make_ast_node(AST_DIV, $1, $3, NULL); }
    | expression MOD expression       { $$ = make_ast_node(AST_MOD, $1, $3, NULL); }
    | expression GT expression        { $$ = make_ast_node(AST_GT, $1, $3, NULL); }
    | expression LT expression        { $$ = make_ast_node(AST_LT, $1, $3, NULL); }
    | expression GE expression        { $$ = make_ast_node(AST_GE, $1, $3, NULL); }
    | expression LE expression        { $$ = make_ast_node(AST_LE, $1, $3, NULL); }
    | expression EQ expression        { $$ = make_ast_node(AST_EQ, $1, $3, NULL); }
    | expression NEQ expression       { $$ = make_ast_node(AST_NEQ, $1, $3, NULL); }
    | LPAREN expression RPAREN        { $$ = $2; }
    | factor                          { $$ = $1; }
    ;


factor:
      NUM {
          $$ = make_num_node($1);  // Assuming you have a function to create numeric AST node
      }
    | ID {
        SymbolEntry* entry = symbol_table_lookup($1);
        if (!entry) {
            char error_msg[256];
            sprintf(error_msg, "Semantic error: Identifier '%s' not declared.", $1);
            yyerror(error_msg);
            $$ = NULL;
        } else {
            $$ = make_leaf_node($1);  // Create an AST leaf node for variable
        }
    }
    ;

if_statement:
      IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
        {
            $$ = make_ast_node(AST_IF, $3, $5, NULL);
        }
    | IF LPAREN expression RPAREN statement ELSE statement
        {
            $$ = make_ast_node(AST_IF_ELSE, $3, $5, $7);
        }
    ;


loop_statement:
      WHILE LPAREN expression RPAREN statement
        {
            $$ = make_ast_node(AST_WHILE, $3, $5, NULL);
        }
    | FOR LPAREN assignment SEMICOLON expression SEMICOLON assignment RPAREN statement
        {
            ASTNode* for_header = make_ast_node(AST_FOR_HEADER, $3, $5, $7);
            $$ = make_ast_node(AST_FOR, for_header, $9, NULL);
        }
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
    if (result == 0) {
    printf("Parsing completed successfully!\n");
    print_ast($$);  // Assuming you have a function like this
}
    return result; // Or return 0 if yyparse was successful, 1 otherwise
}
