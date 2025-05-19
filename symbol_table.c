#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

// --- Global Variables for Symbol Table Management ---
Scope* current_scope = NULL;
int global_scope_level_counter = -1; // To assign unique levels

// --- Scope Management Functions ---
void symbol_table_init() {
    current_scope = NULL;
    global_scope_level_counter = -1;
    symbol_table_open_scope(); // Open the global scope (level 0)
    printf("[SymbolTable] Initialized. Global scope (level 0) opened.\n");
}

void symbol_table_open_scope() {
    global_scope_level_counter++;
    Scope* new_scope = (Scope*)malloc(sizeof(Scope));
    if (!new_scope) {
        fprintf(stderr, "Fatal Error: Out of memory creating new scope.\n");
        exit(EXIT_FAILURE);
    }
    new_scope->level = global_scope_level_counter;
    new_scope->count = 0;
    new_scope->capacity = INITIAL_SCOPE_CAPACITY;
    new_scope->entries = (SymbolEntry**)malloc(new_scope->capacity * sizeof(SymbolEntry*));
    if (!new_scope->entries) {
        fprintf(stderr, "Fatal Error: Out of memory for scope entries array.\n");
        free(new_scope);
        exit(EXIT_FAILURE);
    }
    new_scope->enclosing_scope = current_scope;
    current_scope = new_scope;
    // printf("[SymbolTable] Opened scope level %d.\n", current_scope->level);
}

void symbol_table_close_scope() {
    if (current_scope == NULL) {
        fprintf(stderr, "Error: No scope to close.\n");
        return;
    }
    // Global scope (level 0) is usually not closed until program termination.
    // For simplicity here, we'll allow it to be "closed" in terms of popping,
    // but a real compiler might handle global symbol cleanup separately.
    if (current_scope->level == 0 && current_scope->enclosing_scope == NULL) { // <<< CORRECTED LINE
     printf("[SymbolTable] Global scope (level 0) is now effectively inactive for new entries if closed.\n");
    }


    // printf("[SymbolTable] Closing scope level %d.\n", current_scope->level);
    Scope* scope_to_close = current_scope;
    current_scope = current_scope->enclosing_scope;
    // global_scope_level_counter--; // Decrement only if you want levels to be strictly sequential after closes

    // Free entries in the closed scope
    for (int i = 0; i < scope_to_close->count; ++i) {
        if (scope_to_close->entries[i] != NULL) {
            free(scope_to_close->entries[i]->name); // Free the duplicated name
            free(scope_to_close->entries[i]);
        }
    }
    free(scope_to_close->entries); // Free the array of pointers
    free(scope_to_close);          // Free the scope structure itself
}

// --- Symbol Manipulation Functions ---
SymbolEntry* symbol_table_insert(const char* name, DataType type) {
    if (current_scope == NULL) {
        fprintf(stderr, "Error: Cannot insert symbol, no current scope.\n");
        return NULL;
    }

    if (symbol_table_lookup_current_scope(name) != NULL) {
        return NULL; // Re-declaration in current scope, error handled by parser
    }

    // Expand array if needed
    if (current_scope->count >= current_scope->capacity) {
        current_scope->capacity *= 2;
        SymbolEntry** new_entries = (SymbolEntry**)realloc(current_scope->entries, current_scope->capacity * sizeof(SymbolEntry*));
        if (!new_entries) {
            fprintf(stderr, "Fatal Error: Out of memory reallocating scope entries array.\n");
            // Not exiting here as some symbols might still be valid, but this is critical.
            // A real compiler might try more graceful error handling or cleanup.
            current_scope->capacity /= 2; // Revert capacity
            return NULL; // Indicate failure
        }
        current_scope->entries = new_entries;
    }

    SymbolEntry* new_entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    if (!new_entry) {
        fprintf(stderr, "Fatal Error: Out of memory creating new symbol entry.\n");
        exit(EXIT_FAILURE); // Malloc failure for entry is usually fatal
    }

    new_entry->name = strdup(name);
    if (!new_entry->name) {
        fprintf(stderr, "Fatal Error: Out of memory duplicating symbol name.\n");
        free(new_entry);
        exit(EXIT_FAILURE);
    }
    new_entry->type = type;
    new_entry->scope_level = current_scope->level;

    current_scope->entries[current_scope->count++] = new_entry;
    // printf("[SymbolTable] Inserted '%s' (type: %s) into scope level %d.\n", name, datatype_to_string(type), current_scope->level);
    return new_entry;
}

SymbolEntry* symbol_table_lookup_current_scope(const char* name) {
    if (current_scope == NULL) {
        return NULL;
    }
    for (int i = 0; i < current_scope->count; ++i) {
        if (current_scope->entries[i] != NULL && strcmp(current_scope->entries[i]->name, name) == 0) {
            return current_scope->entries[i];
        }
    }
    return NULL;
}

SymbolEntry* symbol_table_lookup(const char* name) {
    Scope* search_scope = current_scope;
    while (search_scope != NULL) {
        for (int i = 0; i < search_scope->count; ++i) {
            if (search_scope->entries[i] != NULL && strcmp(search_scope->entries[i]->name, name) == 0) {
                return search_scope->entries[i]; // Found
            }
        }
        search_scope = search_scope->enclosing_scope; // Move to outer scope
    }
    return NULL; // Not found
}

// --- Utility Functions ---
const char* datatype_to_string(DataType type) {
    switch (type) {
        case TYPE_INT: return "INT";
        case TYPE_FLOAT: return "FLOAT";
        case TYPE_CHAR: return "CHAR";
        case TYPE_VOID: return "VOID";
        case TYPE_UNDEFINED: return "UNDEFINED";
        default: return "UNKNOWN_TYPE";
    }
}

void symbol_table_print() {
    printf("\n----- Symbol Table (Current View from Innermost Scope) -----\n");
    Scope* s = current_scope;
    while (s != NULL) {
        printf("Scope Level: %d (Capacity: %d, Count: %d)\n", s->level, s->capacity, s->count);
        printf("------------------------------------------------------\n");
        if (s->count == 0) {
            printf("  (Scope is empty)\n");
        } else {
            for (int i = 0; i < s->count; ++i) {
                if (s->entries[i] != NULL) {
                    printf("  Name: %-15s | Type: %-10s | Defined Scope: %d\n",
                           s->entries[i]->name,
                           datatype_to_string(s->entries[i]->type),
                           s->entries[i]->scope_level);
                }
            }
        }
        printf("------------------------------------------------------\n");
        s = s->enclosing_scope;
        if (s != NULL) printf("  |\n  V (Enclosing Scope)\n");
    }
    printf("--- End Symbol Table ---\n\n");
}