%{
#include "tokens.h"
%}

%option noyywrap
delim               [\s\t]
ws                  {delim}+
upper               [A-Z]
lower               [a-z]
alpha               {upper}|{lower}|_

digit               [0-9]
int                 {digit}+
number              {digit}+(\.{digit}+)?

prop                {lower}{alpha}*
class               {upper}{alpha}*
indiv               {class}{int}
data_type           {alpha}+:{alpha}+

%%
{ws}                ;
\n                  return ENDL; { /* isso é para imprimir bonitinho */ }

some                return SOME;
all                 return ALL;
value               return VALUE;
min                 return MIN;
max                 return MAX;
exactly             return EXACTLY;
that                return THAT;
not                 return NOT;
and                 return AND;
or                  return OR;
only                return ONLY;

Class:              return CLASS;
EquivalentTo:       return EQUIVALENTTO;
Individuals:        return INDIVIDUALS;
SubClassOf:         return SUBCLASSOF;
DisjointClasses:    return DISJOINTCLASSES;

{prop}              return PROP_ID;
{class}             return CLASS_ID;
{indiv}             return INDIVIDUAL_ID;
{data_type}         return DATA_TYPE;

{number}            return CARDINALITY;

","                 return COMMA;

"("                 return PARENTHESES;
")"                 return PARENTHESES;
"["                 return BRACKETS;
"]"                 return BRACKETS;
"{"                 return BRACES;
"}"                 return BRACES;

">="                return RELOP;
"<="                return RELOP;
"=="                return RELOP;
"!="                return RELOP;
">"                 return RELOP;
"<"                 return RELOP;

%%

