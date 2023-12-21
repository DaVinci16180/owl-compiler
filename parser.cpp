#include "parser.h"
#include "tokens.h"
#include <vector>
#include <algorithm>
using namespace std;

void Parser::Start()
{
    // imprime a saida detalhada em um arquivo
    ofstream output;
    output.open("output.txt");

    if (!output.is_open()) {
        cerr << "Failed to open file." << endl;
    }

    stringstream tokenLine;
    stringstream inputLine;

    tokenLine << "|";
    inputLine << "|";

    // enquanto não atingir o fim da entrada
    while ((lookahead = scanner.yylex()) != 0)
    {
        // quando houver uma quebra de linha,
        // imprime a saida e limpa o stream
        if (lookahead == ENDL) {
            PrintChar('-', tokenLine.str().size(), output);
            output << endl << tokenLine.str() << endl;
            output << inputLine.str() << endl;
            PrintChar('-', inputLine.str().size(), output);
            output << endl;

            tokenLine.str(string());
            inputLine.str(string());

            tokenLine << "|";
            inputLine << "|";

            continue;
        }

        auto count = tokensCount.find(lookahead);

        // se já existe na tabela
        if (count != tokensCount.end()) {
            // conta +1
            count->second++;
        } else {
            // adiciona na tabela
            tokensCount[lookahead] = 1;
        }

        auto id = idTable.find(scanner.YYText());
        // se não existe na tabela
        if (id == idTable.end()) {
            // adiciona o token
            idTable[scanner.YYText()] = lookahead;
        }

        // adiciona a saida detalhada do token ao stream
        string tokenName = toString[lookahead - 1];
        int biggerString = max(int(tokenName.size()), scanner.YYLeng());

        int tokenWS = (biggerString - int(tokenName.size())) / 2 + 1;
        bool extraTokenWS = (biggerString - int(tokenName.size())) % 2;

        int inputWS = (biggerString - scanner.YYLeng()) / 2 + 1;
        bool extraInputWS = (biggerString - scanner.YYLeng()) % 2;

        // ======================================

        PrintChar(' ', tokenWS, tokenLine);
        tokenLine << tokenName;
        PrintChar(' ', tokenWS, tokenLine);

        extraTokenWS ? (tokenLine << " |") : (tokenLine << "|");

        // ======================================

        PrintChar(' ', inputWS, inputLine);
        inputLine << scanner.YYText();
        PrintChar(' ', inputWS, inputLine);

        extraInputWS ? (inputLine << " |") : (inputLine << "|");

        // ======================================
    }

    // imprime o fim da leitura e fecha o arquivo
    output << endl << tokenLine.str() << endl;
    output << inputLine.str() << endl;

    tokenLine.str("|");
    inputLine.str("|");

    output.close();
}

void Parser::PrintStatistics()
{
    ofstream out;
    out.open("statistics.txt");

    if (!out.is_open()) {
        cerr << "Failed to open file." << endl;
    }

    // ordena o map com base nos valores (inteiros)
    vector<pair<string, int>> orderedIdTable(idTable.begin(), idTable.end());
    sort(
        orderedIdTable.begin(),
        orderedIdTable.end(),
        [](const auto &a, const auto &b) {
            return a.second < b.second;
        }
    );
    
    out << "########################" << endl;
    out << "#  Tabela de tokens   " << endl;
    out << "########################" << endl << endl;
    out << "_______________________________________________" << endl;
    out << "|      Token      |           Value           |" << endl;
    out << "-----------------------------------------------" << endl;

    for (auto entry : orderedIdTable) {
        string token = toString[entry.second - 1];
        out << "| " << token;
        int ws = 16 - token.size();
        PrintChar(' ', ws, out);

        out << "| " << entry.first;
        ws = 26 - entry.first.size();
        PrintChar(' ', ws, out);
        out << "|" << endl;
    }

    out << "-----------------------------------------------" << endl;

    // ordena o map com base nas chaves (inteiros)
    vector<pair<int, int>> orderedTokensCount(tokensCount.begin(), tokensCount.end());
    sort(
        orderedTokensCount.begin(),
        orderedTokensCount.end(),
        [](const auto &a, const auto &b) {
            return a.first < b.first;
        }
    );

    out << endl;
    out << "########################" << endl;
    out << "#  Contagem de tokens   " << endl;
    out << "########################" << endl << endl;
    out << "_____________________________________" << endl;
    out << "|      Token      |      Quant      |" << endl;
    out << "-------------------------------------" << endl;

    for (auto entry : orderedTokensCount) {
        string token = toString[entry.first - 1];
        out << "| " << token;
        int ws = 16 - token.size();
        PrintChar(' ', ws, out);

        string quant = to_string(entry.second);
        out << "| " << quant;
        ws = 16 - quant.size();
        PrintChar(' ', ws, out);
        out << "|" << endl;
    }

    out << "-------------------------------------" << endl;

    out.close();
}

void Parser::PrintChar(char c, int n, stringstream& ss) {
    for (int i = 0; i < n; i++) {
        ss << c;
    }
}

void Parser::PrintChar(char c, int n, ofstream& of) {
    for (int i = 0; i < n; i++) {
        of << c;
    }
}