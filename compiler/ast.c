
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ast.h"

ASTNode *createNode(NodeType type, const char *value)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));

    if (node == NULL) {
        printf("Memory allocation failed!\n");
        exit(1);
    }

    node->type = type;

    if (value != NULL)
        strncpy(node->value, value, sizeof(node->value) - 1);
    else
        node->value[0] = '\0';

    node->value[sizeof(node->value) - 1] = '\0';
    node->dataType[0] = '\0';

    node->left = NULL;
    node->right = NULL;
    node->third = NULL;
    node->next = NULL;

    return node;
}

ASTNode *createBinaryNode(const char *operator,
                          ASTNode *left,
                          ASTNode *right)
{
    ASTNode *node = createNode(NODE_BINARY, operator);

    node->left = left;
    node->right = right;

    return node;
}

ASTNode *createDeclarationNode(const char *dataType,
                               const char *name,
                               ASTNode *expression)
{
    ASTNode *node = createNode(NODE_DECLARATION, name);

    strncpy(node->dataType, dataType, sizeof(node->dataType) - 1);
    node->dataType[sizeof(node->dataType) - 1] = '\0';

    node->left = expression;

    return node;
}

ASTNode *createStatementNode(NodeType type,
                             const char *name,
                             ASTNode *expression)
{
    ASTNode *node = createNode(type, name);

    node->left = expression;

    return node;
}

const char *getNodeName(NodeType type)
{
    switch (type) {
        case NODE_PROGRAM: return "PROGRAM";
        case NODE_DECLARATION: return "DECLARATION";
        case NODE_ASSIGNMENT: return "ASSIGNMENT";
        case NODE_IF: return "IF";
        case NODE_WHILE: return "WHILE";
        case NODE_PRINT: return "PRINT";
        case NODE_BLOCK: return "BLOCK";
        case NODE_BINARY: return "BINARY OPERATION";
        case NODE_IDENTIFIER: return "IDENTIFIER";
        case NODE_NUMBER: return "NUMBER";
        default: return "UNKNOWN";
    }
}

void printAST(ASTNode *root, int level)
{
    int i;

    if (root == NULL)
        return;

    for (i = 0; i < level; i++)
        printf("  ");

    printf("%s", getNodeName(root->type));

    if (root->value[0] != '\0')
        printf(" : %s", root->value);

    if (root->dataType[0] != '\0')
        printf(" [Type: %s]", root->dataType);

    printf("\n");

    printAST(root->left, level + 1);
    printAST(root->right, level + 1);
    printAST(root->third, level + 1);
    printAST(root->next, level);
}

void freeAST(ASTNode *root)
{
    if (root == NULL)
        return;

    freeAST(root->left);
    freeAST(root->right);
    freeAST(root->third);
    freeAST(root->next);

    free(root);
}
