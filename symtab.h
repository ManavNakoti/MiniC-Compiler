#ifndef SYMTAB_H
#define SYMTAB_H

#define TYPE_INT 1
#define TYPE_FLOAT 2
#define TYPE_CHAR 3
#define TYPE_VOID 4

typedef struct Symbol {
    char *name;
    int type;
    struct Symbol *next;
} Symbol;

void insert_symbol(const char *name, int type);
Symbol* lookup_symbol(const char *name);

#endif
