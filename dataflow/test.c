#include <stdio.h>
#include <stdlib.h>

int main()
{
    int a[] = {1, 2, 3};
    int *b[] = {&a[2]};
    int **c[] = {&b[0]};

    for (int i = 0; i < 3; i++)
    {
        printf("%d\n", a[i]);
    }
    printf("%p\n", b);
    printf("%p\n", c);
    return 0;
}