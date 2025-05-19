#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdio.h> // For NULL primarily

// Define the types of symbols your language supports
typedef enum {
    TYPE_INT,
    TYPE_FLOAT,
    TYPE_CHAR,
    TYPE_VOID,
    TYPE_UNDEFINED // For errors or uninitialized types
} DataType;

// Structure for a symbol table entry
typedef struct SymbolEntry {
    char* name;         // Identifier name
    DataType type;      // Data type from the enum above
    int scope_level;    // Scope level where it's defined (useful for debugging/context)
    // Add more fields later: e.g., line number, const flag
} SymbolEntry;

// Structure for a single scope using a dynamic array
#define INITIAL_SCOPE_CAPACITY 10
typedef struct Scope {
    SymbolEntry** entries;      // Dynamic array of pointers to SymbolEntry
    int count;                  // Number of entries currently in this scope
    int capacity;               // Current capacity of the entries array
    int level;                  // The level of this scope
    struct Scope* enclosing_scope; // Pointer to the scope that encloses this one
} Scope;


// --- Function Declarations ---
void symbol_table_init();
void symbol_table_open_scope();
void symbol_table_close_scope();
SymbolEntry* symbol_table_insert(const char* name, DataType type); // Makes a copy of 'name'
SymbolEntry* symbol_table_lookup(const char* name); // Searches current and enclosing scopes
SymbolEntry* symbol_table_lookup_current_scope(const char* name); // For re-declaration check
void symbol_table_print();
const char* datatype_to_string(DataType type);

#endif // SYMBOL_TABLE_H