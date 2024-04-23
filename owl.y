%{
    #include <iostream>
    #include <cctype>
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <string>
    #include <list>
    using namespace std;

    int yylex(void);
    int yyparse(void);
    void yyerror(const char*);

    extern char * yytext;
    extern int yylineno;
    int errors = 0;

    list<char *> objProps{};

    void addObjProp(char* name) {
        objProps.push_back(strdup(name));
    }

    list<char *> dataProps{};

    void addDataProp(char* name) {
        dataProps.push_back(strdup(name));
    }

    list<char *> symbolTable{};

    void addClass(char* name) {
        symbolTable.push_back(strdup(name));
    }

    typedef struct ReferenceRegistry {
        char* name;
        int line;
    } ReferenceRegistry;

    list<ReferenceRegistry *> referenceRegistry{};

    void registerReference(char* name, int line) {
        ReferenceRegistry* newEntry = (ReferenceRegistry*) malloc(sizeof(ReferenceRegistry));
        newEntry->name = strdup(name);
        newEntry->line = line;

        referenceRegistry.push_back(newEntry);
    }
%}

%union {
    char text[32];
    int integer;
    float _float;
}

%token <text> SOME
%token <text> VALUE
%token <text> MIN
%token <text> MAX
%token <text> EXACTLY
%token <text> AND
%token <text> OR
%token <text> ONLY
%token <text> INVERSE

%token CLASS
%token EQUIVALENTTO
%token INDIVIDUALS
%token SUBCLASSOF
%token DISJOINTCLASSES
%token DISJOINTWITH

%token <text> CLASS_ID
%token <text> PROP_ID
%token <text> INDIVIDUAL_ID
%token <text> DATA_TYPE
%token <_float> FLOAT
%token <integer> INTEGER
%token RELOP

%nonassoc OR
%nonassoc AND

%define parse.error verbose

%%

owl     : primitive_class owl
        | defined_class owl
        | enumerated_class owl
        | covered_class owl
        | error owl { yyerrok; yyclearin; }
        | /* ε */
        ;

class_id: CLASS_ID { registerReference($1, yylineno); }
        ;

class   : CLASS ':' CLASS_ID {
            printf("\n\n🔷 %s", $3);
            addClass($3);
        }
        ;

// ===============================================================================================================================
// CLASSE PRIMITIVA ==============================================================================================================
// CLASSE COM AXIOMA DE FECHAMENTO ===============================================================================================

primitive_class : class subclass_of disjoint_classes individuals {
                    cout << endl << "✅ Classe primitiva";
                }
                ;

// ===============================================================================================================================
// CLASSE DEFINIDA ===============================================================================================================
// CLASSE COM DESCRIÇÕES ANINHADAS ===============================================================================================

defined_class   : class equivalent_to disjoint_classes individuals {
                    cout << endl << "✅ Classe definida";
                }
                | class logi_conn_eq_to subclass_of disjoint_classes individuals {
                    cout << endl << "✅ Classe definida";
                }
                ;

// ===============================================================================================================================
// CLASSE ENUMERADA ==============================================================================================================

enumerated_class: class instance_eq_to disjoint_classes individuals {
                    cout << endl << "✅ Classe enumerada";
                }
                ;
                
// ===============================================================================================================================
// CLASSE COBERTA ================================================================================================================

covered_class   : class logi_conn_eq_to disjoint_classes individuals {
                    cout << endl << "✅ Classe coberta";
                }
                ;

// ===============================================================================================================================
// CLAUSULAS =====================================================================================================================

subclass_of     : SUBCLASSOF ':' quantifier_list
                | SUBCLASSOF ':' class_id ',' quantifier_list
                | SUBCLASSOF ':' class_id
                ;

equivalent_to   : EQUIVALENTTO ':' class_id AND logical_conn_p
                ;

instance_eq_to  : EQUIVALENTTO ':' '{' individual_list '}'
                ;

logi_conn_eq_to : EQUIVALENTTO ':' logical_conn_c
                ;

quantifier_list : quantifier ',' quantifier_list
                | logical_conn_p ',' quantifier_list
                | quantifier
                ;

// ===============================================================================================================================
// CLAUSULAS OPCIONAIS ===========================================================================================================

disjoint_classes: DISJOINTCLASSES ':' class_list
                | DISJOINTWITH ':' class_id
                | /* ε */
                ;

class_list      : class_id ',' class_list
                | class_id
                ;

individuals     : INDIVIDUALS ':' individual_list
                | /* ε */
                ;

individual_list : INDIVIDUAL_ID ',' individual_list
                | INDIVIDUAL_ID
                ;

// ===============================================================================================================================
// QUANTIFICADORES ===============================================================================================================

quantifier      : some
                | min
                | max
                | exactly
                | value
                | only                                  { cout << endl << "🟢 Axioma de fechamento"; }
                | '(' quantifier ')'
                | INVERSE quantifier
                ;

some            : PROP_ID SOME class_id                 { addObjProp($1);   }
                | PROP_ID SOME data_type                { addDataProp($1);  }
                | PROP_ID SOME '(' quantifier ')'       { cout << endl << "🟢 Descrições aninhadas"; }
                | PROP_ID SOME '(' logical_conn_c ')'   { addObjProp($1);   }
                ;

only            : PROP_ID ONLY class_id                 { addObjProp($1);   }
                | PROP_ID ONLY '(' logical_conn_c ')'   { addObjProp($1);   }
                ;

min             : PROP_ID MIN INTEGER class_id          { addObjProp($1);   }
                ;

max             : PROP_ID MAX INTEGER class_id          { addObjProp($1);   }
                ;

exactly         : PROP_ID EXACTLY INTEGER class_id      { addObjProp($1); }
                ;

value           : PROP_ID VALUE INDIVIDUAL_ID           { addObjProp($1); }
                ;

data_type       : DATA_TYPE '[' RELOP number ']'
                | DATA_TYPE
                ;

number          : INTEGER
                | FLOAT
                ;

// ===============================================================================================================================
// CONECTIVOS LÓGICOS - CLASSE ===================================================================================================

logical_conn_c  : class_id AND logical_conn_c
                | class_id OR logical_conn_c
                | class_id
                ;

// ===============================================================================================================================
// CONECTIVOS LÓGICOS - PROPRIEDADE ==============================================================================================

logical_conn_p  : quantifier_conn AND quantifier_conn
                | quantifier_conn OR quantifier_conn
                | quantifier_conn
                ;

quantifier_conn : quantifier AND quantifier_conn
                | quantifier OR quantifier_conn
                | '(' quantifier_conn ')'
                | quantifier
                ;

// ===============================================================================================================================

%%

void yyerror(const char* str) {
    errors++;
    cout << endl << "❌ ERRO: " << str << endl;
    cout << "❌ \"" << yytext << "\" na linha " << yylineno;
}

int main() {
    yyparse();
    cout << endl;

    for (ReferenceRegistry* reference : referenceRegistry) {
        bool found = false;
        for (char* symbol : symbolTable) {
            if (strcmp(symbol, reference->name) == 0) {
                found = true;
                break;
            }
        }

        if (!found){
            errors++;
            cout << endl << "❌ ERRO: reference error";
            cout << endl << "❌ Classe " << reference->name << " não declarada referenciada na linha " << reference->line << endl;
        }
    }

    cout << endl << "📄 Resumo" << endl;

    if (!objProps.empty()) {
        cout << endl << "🔵 Object properties (" << objProps.size() << "): " << endl;
        for (char* prop : objProps) {
            cout << "  🔹 " << prop << endl;
        }
    }

    if (!dataProps.empty()) {
        cout << endl << "🟠 Data properties (" << dataProps.size() << "): " << endl;
        for (char* prop : dataProps) {
            cout << "  🔸 " << prop << endl;
        }
    }

    cout << endl << (errors ? "⚠️ " : "✅");
    cout << " Compilação finalizada com " << errors << (errors == 1 ? " erro." : " erros.") << endl;
}