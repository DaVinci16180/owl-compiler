#include <FlexLexer.h>
#include <unordered_map>
#include <string>
#include <iostream>
#include <sstream>
#include <fstream>
using namespace std;

// gambi para traduzir o token para string. Apenas para imprimir a saída bonita
const string toString[] = {
    "SOME", "ALL", "VALUE", "MIN", "MAX", "EXACTLY", "THAT", "NOT", "AND", "OR", "ONLY",
    "CLASS", "EQUIVALENTTO", "INDIVIDUALS", "SUBCLASSOF", "DISJOINTCLASSES",
    "CLASS_ID", "PROP_ID", "INDIVIDUAL_ID", "DATA_TYPE", "CARDINALITY",
    "PARENTHESES", "BRACKETS", "BRACES", "RELOP", "COMMA", "ENDL"
};

class Parser
{
    private:
        yyFlexLexer scanner;
        int lookahead;
        unordered_map<int, int> tokensCount;
        unordered_map<string, int> idTable;

        void PrintChar(char c, int n, stringstream& ss);  // imprime multiplos caracteres
        void PrintChar(char c, int n, ofstream& of);      // imprime multiplos caracteres
        
    public:
        void Start();           // roda o parser
        void PrintStatistics(); // cria o arquivo de estatisticas
};