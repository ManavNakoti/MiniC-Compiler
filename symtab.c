#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

static Symbol *symbol_table = NULL;

void insert_symbol(const char *name, int type) {
    if (lookup_symbol(name)) {
        fprintf(stderr, "Error: redeclaration of variable %s\n", name);
        exit(1);
    }
    Symbol *sym = (Symbol*) malloc(sizeof(Symbol));
    sym->name = strdup(name);
    sym->type = type;
    sym->next = symbol_table;
    symbol_table = sym;
}

Symbol* lookup_symbol(const char *name) {
    Symbol *curr = symbol_table;
    while (curr) {
        if (strcmp(curr->name, name) == 0) {
            return curr;
        }
        curr = curr->next;
    }
    return NULL;
}
