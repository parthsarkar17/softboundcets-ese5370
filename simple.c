#include <stdio.h>
#include <stdlib.h>

int mul(int x, int y) {
    return x * y;
}

int main()
{
    int a[] = {1, 2, 3};
    int *b[] = {&a[2]};
    int **c[] = {&b[0]};

    int x = *(a + 1);
    int y = *(a + 2);

    int z = mul(x, y);

    printf("x : %d, y : %d, z : %d\n", x, y, z);

    for (int i = 0; i < 3; i++)
    {
        printf("%d\n", a[i]);
    }
    printf("%p\n", b);
    printf("%p\n", c);
    return 0;
}