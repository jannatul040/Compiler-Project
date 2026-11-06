
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

int yylex(void);
void yyerror(const char *s);

extern int yylineno;

ASTNode *root = NULL;

%}

%union {
    char *text;
    ASTNode *node;
}

%token INT FLOAT IF ELSE WHILE PRINT
%token ASSIGN PLUS MINUS MULT DIV
%token LT GT LE GE EQ NE
%token LPAREN RPAREN
%token LBRACE RBRACE SEMICOLON
%token INVALID

%token <text> ID NUMBER

%type <node> program statements statement
%type <node> declaration assignment
%type <node> if_statement while_statement
%type <node> print_statement block
%type <node> condition expression term factor

%left PLUS MINUS
%left MULT DIV

%%

program:
    statements
    {
        root = createNode(NODE_PROGRAM, "Mini-C Program");
        root->left = $1;
    }
    ;

statements:
      statements statement
    {
        if ($1 == NULL)
            $$ = $2;
        else {
            ASTNode *temp = $1;

            while (temp->next != NULL)
                temp = temp->next;

            temp->next = $2;
            $$ = $1;
        }
    }
    | statement
    {
        $$ = $1;
    }
    ;

statement:
      declaration     { $$ = $1; }
    | assignment      { $$ = $1; }
    | if_statement    { $$ = $1; }
    | while_statement { $$ = $1; }
    | print_statement { $$ = $1; }
    | block           { $$ = $1; }
    ;


declaration:
      INT ID SEMICOLON
    {
        $$ = createDeclarationNode("int", $2, NULL);
        free($2);
    }
    | FLOAT ID SEMICOLON
    {
        $$ = createDeclarationNode("float", $2, NULL);
        free($2);
    }
    | INT ID ASSIGN expression SEMICOLON
    {
        $$ = createDeclarationNode("int", $2, $4);
        free($2);
    }
    | FLOAT ID ASSIGN expression SEMICOLON
    {
        $$ = createDeclarationNode("float", $2, $4);
        free($2);
    }
    ;


assignment:
    ID ASSIGN expression SEMICOLON
    {
        $$ = createStatementNode(
            NODE_ASSIGNMENT, $1, $3);
        free($1);
    }
    ;

if_statement:
      IF LPAREN condition RPAREN statement
    {
        $$ = createNode(NODE_IF, "if");
        $$->left = $3;
        $$->right = $5;
    }
    | IF LPAREN condition RPAREN statement ELSE statement
    {
        $$ = createNode(NODE_IF, "if-else");
        $$->left = $3;
        $$->right = $5;
        $$->third = $7;
    }
    ;
while_statement:
    WHILE LPAREN condition RPAREN statement
    {
        $$ = createNode(NODE_WHILE, "while");
        $$->left = $3;
        $$->right = $5;
    }
    ;

print_statement:
    PRINT LPAREN expression RPAREN SEMICOLON
    {
        $$ = createNode(NODE_PRINT, "print");
        $$->left = $3;
    }
    ;

block:
    LBRACE statements RBRACE
    {
        $$ = createNode(NODE_BLOCK, "block");
        $$->left = $2;
    }
    ;

condition:
      expression LT expression
    {
        $$ = createBinaryNode("<", $1, $3);
    }
    | expression GT expression
    {
        $$ = createBinaryNode(">", $1, $3);
    }
    | expression LE expression
    {
        $$ = createBinaryNode("<=", $1, $3);
    }
    | expression GE expression
    {
        $$ = createBinaryNode(">=", $1, $3);
    }
    | expression EQ expression
    {
        $$ = createBinaryNode("==", $1, $3);
    }
    | expression NE expression
    {
        $$ = createBinaryNode("!=", $1, $3);
    }
    ;

expression:
      expression PLUS term
    {
        $$ = createBinaryNode("+", $1, $3);
    }
    | expression MINUS term
    {
        $$ = createBinaryNode("-", $1, $3);
    }
    | term
    {
        $$ = $1;
    }
    ;

term:
      term MULT factor
    {
        $$ = createBinaryNode("*", $1, $3);
    }
    | term DIV factor
    {
        $$ = createBinaryNode("/", $1, $3);
    }
    | factor
    {
        $$ = $1;
    }
    ;

factor:
      ID
    {
        $$ = createNode(NODE_IDENTIFIER, $1);
        free($1);
    }
    | NUMBER
    {
        $$ = createNode(NODE_NUMBER, $1);
        free($1);
    }
    | LPAREN expression RPAREN
    {
        $$ = $2;
    }
    ;

%%

void yyerror(const char *s)
{
    printf("\nSyntax Error at line %d!\n", yylineno);

    if (strstr(s, "syntax error") != NULL) {
        printf("Reason: Invalid program structure.\n");
    }
    else {
        printf("Reason: %s\n", s);
    }
}

int main()
{
    printf("=== COMPILER BATTLE ARENA ===\n");
    printf("=== SYNTAX ANALYSIS + AST GENERATION ===\n\n");

    if (yyparse() == 0) {

        printf("\nSyntax Analysis: SUCCESS!\n");
        printf("Valid Mini-C Program.\n");

        printf("\n===== ABSTRACT SYNTAX TREE =====\n");
        printAST(root, 0);

        freeAST(root);

        printf("\nProgram accepted!\n");
    }
    else {
        printf("\nProgram rejected!\n");
    }

    return 0;
}
