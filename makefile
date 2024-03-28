all: owl clean

# Compiladores
CPP=g++
FLEX=flex
BISON=bison

owl: lex.yy.c owl.tab.c
	$(CPP) lex.yy.c owl.tab.c -std=c++17 -o owl

lex.yy.c: owl.l
	$(FLEX) owl.l

owl.tab.c: owl.y
	$(BISON) -d owl.y

clean:
	rm lex.yy.c owl.tab.c owl.tab.h