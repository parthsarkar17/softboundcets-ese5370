#include "uninstr.h"

int main()
{

    // these arrays live next to each other on the stack
    int array1[] = {1, 2, 3};
    int array2[] = {4, 5, 6};

    // modify the metadata table so that we can use `array1` to modify
    // a part of memory that should only be addressable by variable `array2`
    overwrite_metadata_map();
    array1[4] = 37;

    // verify change
    printf("%d\n", array2[0]);

    return 0;
}