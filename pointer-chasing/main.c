#include <stdlib.h>
#include <stdio.h>

struct node {
    u_int64_t val;
    struct node *next;
}; 

struct node *initialize_ll_of_size(u_int64_t length)
{
    struct node *head = NULL;
    struct node *tail = NULL;
    for (u_int64_t i = 0; i < length; i++)
    {
        struct node *new_node = (struct node *)malloc(sizeof(struct node));
        new_node->val = i;
        new_node->next = NULL;

        if (i == 0)
        {
            head = new_node;
            tail = new_node;
        } else
        {
            tail->next = new_node;
            tail = new_node;
        }
    }
    return head;
}

u_int64_t sum_nodes(struct node *head)
{ 
    u_int64_t sum = 0;
    struct node *curr_node = head;
    while (curr_node != NULL)
    {
        sum = sum + curr_node->val;
        curr_node = curr_node->next;
    }
    return sum;
}

void free_nodes(struct node *head)
{
    struct node *curr_node = head;
    struct node *next_node = NULL;
    while (curr_node != NULL)
    {
        next_node = curr_node->next;
        free(curr_node);
        curr_node = next_node;
    }
}

int main() {
    struct node *head = initialize_ll_of_size(100000);
    printf("%llu\n", sum_nodes(head));
    free_nodes(head);
    return 0;
}