# Compiladores
CC=g++
LEX=flex++

# Dependências
all: analyzer

analyzer: analyzer.o parser.o lex.yy.o
	$(CC) analyzer.o parser.o lex.yy.o -o analyzer

analyzer.o: analyzer.cpp parser.h
	$(CC) -c -std=c++17 analyzer.cpp

parser.o: parser.cpp parser.h tokens.h
	$(CC) -c -std=c++17 parser.cpp

lex.yy.o: lex.yy.cc tokens.h
	$(CC) -c -std=c++17 lex.yy.cc

lex.yy.cc: lexer.l tokens.h
	$(LEX) lexer.l

clean:
	rm analyzer lex.yy.cc lex.yy.o parser.o analyzer.o