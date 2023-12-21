# Compilador para OWL no formato Manchester Syntax

O objetivo do presente projeto é construir um compilador para a linguagem OWL (Web Ontology Language) no formato Manchester Syntax. O projeto conta atualmente apenas com o analisador léxico.

# Execução

Por conveniência, o arquivo executável do projeto está incluso no diretório Build. Para executá-lo, basta executar o comando `Build/analyzer` na raiz do projeto, ou `Build/analyzer < test.txt`, para executar com o arquivo de teste.

Para criar o executável do programa é necessário realizar a build da aplicação usando o Make ou o CMake.

## Make

Para fazer a build usando o make, basta executar o comando `make` na pasta raiz do projeto (onde se encontra o makefile). Após isso, os arquivos-objetos e o programa executável serão criados na pasta raiz do projeto.

Para executar o programa, execute o comando `./analyzer` na raiz do projeto. 

Para executar o programa utilizando o arquivo de teste, execute o comando `./analyzer < test.txt` na raiz do projeto. 

## CMake

Para fazer a build usando o CMake, é necessrio executar o comando `cmake ../` no diretório Build (executar o comando `cd ./Build` na raiz do projeto antes do CMake) do projeto. Um arquivo Makefile será criado em Build. Após isso, basta executar o comando `make` no diretório Build para criar o executável.

Para executar o programa, execute o comando `Build/analyzer` na raiz do projeto ou `./analyzer` no diretório Build.

Para executar o programa utilizando o arquivo de teste, execute o comando `Build/analyzer < test.txt` na raiz do projeto ou `./analyzer < ../test.txt` no diretório Build.

## VS Code

Caso esteja usando o VS Code, é possível realizar a build do projeto a partir das tasks definidas no arquivo /.vscode/tasks.json. O arquivo contém a definição de tasks apenas para o CMake.

# Saída

A saída será gerada em arquivos de texto no diretório atual (diretório de execução). Serão criados dois arquivos: output.txt, contendo o reconhecimento detalhado da entrada, e statistics.txt, contendo a tabela de tokens e o contador de tokens.
