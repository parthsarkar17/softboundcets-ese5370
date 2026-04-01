#include <stdio.h>
#include "small_lib.h"

void foo4(void) {
  printf("Hi\n");
}

int main() {

    int x = 3;
    int y = 4;
    int z = add_two_nums(x, y);
    printf("%d\n", z);

    return 0;
}