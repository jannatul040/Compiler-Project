
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "parser.tab.h"

static char *copyText(const char *text)
{
    char *copy = (char *)malloc(strlen(text) + 1);

    if (copy == NULL) {
        printf("Memory allocation failed!\n");
        exit(1);
    }

    strcpy(copy, text);
    return copy;
}
%}

%option noyywrap
%option yylineno

DIGIT       [0-9]
LETTER      [a-zA-Z_]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT})*

%%

"int"       { return INT; }
"float"     { return FLOAT; }
"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }
"print"     { return PRINT; }

{IDENTIFIER} {
    yylval.text = copyText(yytext);
    return ID;
}
{DIGIT}+\.{DIGIT}*\.{DIGIT}* {
    printf("\nLexical Error at line %d: Malformed number '%s'\n",
           yylineno, yytext);
    return INVALID;
}

{DIGIT}+(\.{DIGIT}+)? {
    yylval.text = copyText(yytext);
    return NUMBER;
}

"=="        { return EQ; }
"!="        { return NE; }
"<="        { return LE; }
">="        { return GE; }
"<"         { return LT; }
">"         { return GT; }

"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return MULT; }
"/"         { return DIV; }

"="         { return ASSIGN; }
";"         { return SEMICOLON; }
"("         { return LPAREN; }
")"         { return RPAREN; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }

[ \t\r\n]+  { /* Ignore whitespace */ }
"//".*      { /* Ignore comments */ }

. {
    printf("\nLexical Error at line %d: Invalid character '%s'\n",
           yylineno, yytext);
    return INVALID;
}

%%
