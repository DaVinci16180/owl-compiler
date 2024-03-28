# Compilador para OWL no formato Manchester Syntax

O objetivo do presente projeto é construir um compilador para a linguagem OWL (Web Ontology Language) no formato Manchester Syntax. O projeto conta atualmente com o analisador léxico (owl.l) e sintático (owl.y).

# Execução

Por conveniência, o arquivo executável do projeto está incluso no diretório raiz. Para executá-lo, basta executar o comando `./owl` na raiz do projeto, ou `./owl < test.txt`, para executar com o arquivo de teste.

Para criar o executável do programa é necessário realizar a build da aplicação usando o Make.

## Make

Para fazer a build usando o make, basta executar o comando `make` no diretório raiz do projeto (onde se encontra o makefile). Após isso, o programa executável será criado no mesmo diretório contendo o arquivo makefile.

Para executar o programa, execute o comando `./owl` na raiz do projeto. 

Para executar o programa utilizando o arquivo de teste, execute o comando `./owl < test.txt` na raiz do projeto. 

## VS Code

Caso esteja usando o VS Code, é possível realizar a build do projeto a partir da task definida no arquivo /.vscode/tasks.json.

## Arquivos de teste

No projeto, estão inclusos dois arquivos de teste: test.txt, contendo a ontologia da pizza, e test2.txt, contendo a ontologia do trabalho de Manoel.

# Saída

A saída será gerada no terminal, composta pela leitura das classes, classificação de seus tipos e possíveis erros.
