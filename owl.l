%{
    #include "owl.tab.h"
    #include <iostream>
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
number              {digit}+(\.{digit}+)?

prop                {lower}{alpha}*
class               {upper}{alpha}*
indiv               {class}{int}
data_type           {alpha}+:{alpha}+

symbols             [\{\}\(\)\[\]:,]

%%

{ws}                

some                    return SOME;
all                     return ALL;
value                   return VALUE;
min                     return MIN;
max                     return MAX;
exactly                 return EXACTLY;
that                    return THAT;
not                     return NOT;
and                     return AND;
or                      return OR;
only                    return ONLY;
inverse                 return INVERSE;

Class                   return CLASS;
EquivalentTo            return EQUIVALENTTO;
Individuals             return INDIVIDUALS;
SubClassOf              return SUBCLASSOF;
DisjointClasses         return DISJOINTCLASSES;
DisjointWith            return DISJOINTWITH;

{prop}                  return PROP_ID;
{class}                 return CLASS_ID;
{indiv}                 return INDIVIDUAL_ID;
{data_type}             return DATA_TYPE;

{number}                return CARDINALITY;

{symbols}               return yytext[0];

">="                    return RELOP;
"<="                    return RELOP;
"=="                    return RELOP;
"!="                    return RELOP;
">"                     return RELOP;
"<"                     return RELOP;

%%
