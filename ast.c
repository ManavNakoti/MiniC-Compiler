#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

ASTNode* make_ast_node(ASTNodeType type, ASTNode* left, ASTNode* middle, ASTNode* right) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = type;
    node->left = left;
    node->middle = middle;
    node->right = right;
    node->varname = NULL;
    node->value = 0;
    return node;
}

ASTNode* make_leaf_node(char* varname) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = AST_VAR;
    node->varname = strdup(varname);
    node->left = node->middle = node->right = NULL;
    node->value = 0;
    return node;
}

ASTNode* make_num_node(int value) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = AST_NUM;
    node->value = value;
    node->varname = NULL;
    node->left = node->middle = node->right = NULL;
    return node;
}

void print_indent(int indent) {
    for (int i = 0; i < indent; i++) printf("  ");
}

void print_ast(ASTNode* node, int indent) {
    if (!node) return;

    print_indent(indent);

    switch (node->type) {
        case AST_NUM:
            printf("Num(%d)\n", node->value);
            break;
        case AST_VAR:
            printf("Var(%s)\n", node->varname);
            break;
        case AST_ADD: case AST_SUB: case AST_MUL:
        case AST_DIV: case AST_MOD:
        case AST_GT: case AST_LT: case AST_GE:
        case AST_LE: case AST_EQ: case AST_NEQ:
            printf("BinaryOp(");
            switch (node->type) {
                case AST_ADD: printf("+"); break;
                case AST_SUB: printf("-"); break;
                case AST_MUL: printf("*"); break;
                case AST_DIV: printf("/"); break;
                case AST_MOD: printf("%%"); break;
                case AST_GT: printf(">"); break;
                case AST_LT: printf("<"); break;
                case AST_GE: printf(">="); break;
                case AST_LE: printf("<="); break;
                case AST_EQ: printf("=="); break;
                case AST_NEQ: printf("!="); break;
                default: printf("?"); break;
            }
            printf(")\n");
            print_ast(node->left, indent + 1);
            print_ast(node->right, indent + 1);
            break;
        case AST_ASSIGN:
            printf("Assign(%s)\n", node->varname);
            print_ast(node->left, indent + 1);
            break;
        case AST_DECLARATION:
            printf("Declaration(%s)\n", node->varname);
            if (node->left) print_ast(node->left, indent + 1);
            break;
        case AST_STATEMENT_LIST:
            printf("StatementList\n");
            print_ast(node->left, indent + 1);
            print_ast(node->right, indent + 1);
            break;
        case AST_IF:
            printf("If\n");
            print_ast(node->left, indent + 1);   // condition
            print_ast(node->right, indent + 1);  // then block
            break;
        case AST_IF_ELSE:
            printf("IfElse\n");
            print_ast(node->left, indent + 1);    // condition
            print_ast(node->middle, indent + 1);  // then
            print_ast(node->right, indent + 1);   // else
            break;
        case AST_WHILE:
            printf("While\n");
            print_ast(node->left, indent + 1);   // condition
            print_ast(node->right, indent + 1);  // body
            break;
        case AST_FOR_HEADER:
            printf("ForHeader\n");
            print_ast(node->left, indent + 1);    // init
            print_ast(node->middle, indent + 1);  // cond
            print_ast(node->right, indent + 1);   // update
            break;
        case AST_FOR:
            printf("ForLoop\n");
            print_ast(node->left, indent + 1);    // header
            print_ast(node->right, indent + 1);   // body
            break;
        default:
            printf("Unknown AST Node\n");
            break;
    }
}

void free_ast(ASTNode* node) {
    if (!node) return;

    free_ast(node->left);
    free_ast(node->middle);
    free_ast(node->right);

    if (node->varname)
        free(node->varname);

    free(node);
}
