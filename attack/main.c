#include "uninstr.h"
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

int main()
{

    // these arrays live next to each other on the stack
    int array1[] = {1, 2, 3};
    int array2[] = {4, 5, 6};

    // ensure pointer `array1` has an entry in the metadata table by
    // storing the pointer to a location in memory (i.e. not register-saved)
    int *array1_ptr[] = {array1};

    // modify the metadata table so that we can use `array1` to modify
    // a part of memory that should only be addressable by variable `array2`,
    // according to SOFTBOUND guarantees
    overwrite_metadata_map(array1_ptr, 3);

    // ensure the base-and-bounds check goes through the metadata table,
    // and not base-and-bound variables "inlined" into the function body
    int *array1_alias = *array1_ptr;
    *(array1_alias + 3) = 37;

    // verify change
    int attack_success = (array2[0] == 37);
    assert(attack_success);
    if (attack_success)
    {
        printf("successfully escalated privilege of stack pointer\n");
    }

    return 0;
}