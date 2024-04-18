%{
    #include "owl.tab.h"
    #include <iostream>
    #include <stdio.h>
    #include <string.h>
%}

%option noyywrap
%option yylineno

delim               [\n\t ]
ws                  {delim}+
upper               [A-Z]
lower               [a-z]
alpha               {upper}|{lower}|_

digit               [0-9]
int                 {digit}+
number              {digit}+\.{digit}+

prop                {lower}{alpha}*
class               {upper}{alpha}*
indiv               {class}{int}
data_type           {alpha}+:{alpha}+

symbols             [\{\}\(\)\[\]:,]

%%

{ws}                

some                    { strcpy(yylval.text, yytext); return SOME;     }
value                   { strcpy(yylval.text, yytext); return VALUE;    }
min                     { strcpy(yylval.text, yytext); return MIN;      }
max                     { strcpy(yylval.text, yytext); return MAX;      }
exactly                 { strcpy(yylval.text, yytext); return EXACTLY;  }
and                     { strcpy(yylval.text, yytext); return AND;      }
or                      { strcpy(yylval.text, yytext); return OR;       }
only                    { strcpy(yylval.text, yytext); return ONLY;     }
inverse                 { strcpy(yylval.text, yytext); return INVERSE;  }

Class                   return CLASS;
EquivalentTo            return EQUIVALENTTO;
Individuals             return INDIVIDUALS;
SubClassOf              return SUBCLASSOF;
DisjointClasses         return DISJOINTCLASSES;
DisjointWith            return DISJOINTWITH;

{prop}                  { strcpy(yylval.text, yytext); return PROP_ID;       }
{class}                 { strcpy(yylval.text, yytext); return CLASS_ID;      }
{indiv}                 { strcpy(yylval.text, yytext); return INDIVIDUAL_ID; }
{data_type}             { strcpy(yylval.text, yytext); return DATA_TYPE;     }

{number}                { yylval._float = atof(yytext); return FLOAT;         }
{digit}                 { yylval.integer = atoi(yytext); return INTEGER;      }

{symbols}               return yytext[0];

">="                    return RELOP;
"<="                    return RELOP;
"=="                    return RELOP;
"!="                    return RELOP;
">"                     return RELOP;
"<"                     return RELOP;

%%
