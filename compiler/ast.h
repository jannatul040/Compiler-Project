
#ifndef AST_H
#define AST_H

typedef enum {
    NODE_PROGRAM,
    NODE_DECLARATION,
    NODE_ASSIGNMENT,
    NODE_IF,
    NODE_WHILE,
    NODE_PRINT,
    NODE_BLOCK,
    NODE_BINARY,
    NODE_IDENTIFIER,
    NODE_NUMBER
} NodeType;

typedef struct ASTNode {
    NodeType type;

    char value[50];
    char dataType[20];

    struct ASTNode *left;
    struct ASTNode *right;
    struct ASTNode *third;
    struct ASTNode *next;

} ASTNode;

ASTNode *createNode(NodeType type, const char *value);

ASTNode *createBinaryNode(const char *operator,
                          ASTNode *left,
                          ASTNode *right);

ASTNode *createDeclarationNode(const char *dataType,
                               const char *name,
                               ASTNode *expression);

ASTNode *createStatementNode(NodeType type,
                             const char *name,
                             ASTNode *expression);

void printAST(ASTNode *root, int level);

void freeAST(ASTNode *root);

#endif
