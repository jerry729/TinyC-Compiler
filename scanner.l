%{
#define YYSTYPE char *
#include "y.tab.h"
int cur_line = 1;
void yyerror(const char* msg);
void unrecognized_char(char c);
#define _DUPTEXT{yylval = strdup(yytext);}
%}

/* \042 is " */

OPERATOR        ([-/+*()=,;])
INTEGER         ([0-9]+)
STRING          (\042[^042\n]*\042)
IDENTIFIER      ([_a-zA-Z][_a-zA-Z0-9]*)
WHITESPACE      ([ \t]*)

%%

{OPERATOR}      {return yytext[0];}
"int"           {return T_Int;}
"print"         {return T_Print;}

{INTEGER}       {_DUPTEXT; return T_IntConstant;}
{STRING}        {_DUPTEXT; return T_StringConstant;}
{IDENTIFIER}    {_DUPTEXT; return T_Identifier;}

{WHITESPACE}    {/*ignore*/}
\n              {cur_line++;}
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

void yyerror(const char* msg){
    printf("Error at line %d:\n\t%s\n", cur_line, msg);
    exit(-1);
}