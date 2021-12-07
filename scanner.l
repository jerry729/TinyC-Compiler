%{
#define YYSTYPE char *
#include "y.tab.h"
int cur_line = 1;
void yyerror(const char* msg);
void unrecognized_char(char c);
#define _DUPTEXT{yylval = strdup(yytext);}
%}

/* \042 is " */

WHITESPACE      ([ \t\r\a]+)
SINGLE_COMMENT1 ("//"[^\n]*)
SINGLE_COMMENT2 ("#"[^\n]*)
OPERATOR        ([+*-/%=,;!<>(){}])
INTEGER         ([0-9]+)
IDENTIFIER      ([_a-zA-Z][_a-zA-Z0-9]*)
UNTERM_STRING   (\042[^\042\n]*)
STRING          (\042[^042\n]*\042)


%%

\n                  {cur_line++;}
{WHITESPACE}        {/*ignore*/}
{SINGLE_COMMENT1}   {/*skip*/}
{SINGLE_COMMENT2}   {/*skip*/}


{OPERATOR}      {return yytext[0];}
"int"           {return T_Int;}
"void"          {return T_Void;}
"return"        {return T_Return;}
"print"         {return T_Print;}
"readint"       {return T_ReadInt;}
"while"         {return T_While;}
"if"            {return T_If;}
"else"          {return T_Else;}
"break"         {return T_Break;}
"continue"      {return T_Continue;}
"<="            {return T_Le;}
">="            {return T_Ge;}
"=="            {return T_Eq;}
"!="            {return T_Ne;}
"&&"            {return T_And;}
"||"            {return T_Or;}

{INTEGER}       {_DUPTEXT; return T_IntConstant;}
{STRING}        {_DUPTEXT; return T_StringConstant;}
{IDENTIFIER}    {_DUPTEXT; return T_Identifier;}

{UNTERM_STRING} {unterminated_string();}

.               {unrecognized_char(yytext[0]);}

%%

int yywrap(void){
    //yywrap 函数的作用是将多个输入文件打包成一个输入，当 yylex 函数读入到一个文件结束（EOF）时，它会向 yywrap 函数询问， yywrap 函数返回 1 的意思是告诉yylex 函数后面没有其他输入文件了，此时 yylex 函数结束，yywrap 函数也可以打开下一个输入文件，再向 yylex 函数返回 0 ，告诉它后面还有别的输入文件，此时 yylex 函数会继续解析下一个输入文件。总之，由于我们不考虑连续解析多个文件，因此此处返回 1 
    return 1;
}

void unrecognized_char(char c){
    char buf[32] = "Unrecognized character: ?";
    buf[24] = c;
    yyerror(buf);
}

void unterminated_string(){
    yyerror("unterminated string");
}

void yyerror(const char* msg){
    fprintf(stderr, "Error at line %d:\n\t%s\n", cur_line, msg);
    exit(-1);
}