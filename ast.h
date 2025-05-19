#ifndef AST_H
#define AST_H

typedef enum {
    // Literals and identifiers
    AST_NUM,
    AST_VAR,

    // Binary operators
    AST_ADD,
    AST_SUB,
    AST_MUL,
    AST_DIV,
    AST_MOD,

    // Comparisons
    AST_GT,
    AST_LT,
    AST_GE,
    AST_LE,
    AST_EQ,
    AST_NEQ,

    // Assignment, declaration
    AST_ASSIGN,
    AST_DECLARATION,

    // Compound statements
    AST_STATEMENT_LIST,

    // Control structures
    AST_IF,
    AST_IF_ELSE,
    AST_WHILE,
    AST_FOR_HEADER,  // for(init; cond; inc)
    AST_FOR          // entire for loop with body
} ASTNodeType;

typedef struct ASTNode {
    ASTNodeType type;
    char* varname;          // For AST_VAR, AST_ASSIGN, AST_DECLARATION
    int value;              // For AST_NUM
    struct ASTNode* left;   // Generic left
    struct ASTNode* middle; // Used for if-else middle (else block), for loop
    struct ASTNode* right;  // Generic right
} ASTNode;

// Constructors
ASTNode* make_ast_node(ASTNodeType type, ASTNode* left, ASTNode* middle, ASTNode* right);
ASTNode* make_leaf_node(char* varname);
ASTNode* make_num_node(int value);

// Utilities
void print_ast(ASTNode* node, int indent);
void free_ast(ASTNode* node);

#endif
