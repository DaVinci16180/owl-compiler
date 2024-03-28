%{
    #include <iostream>
    #include <cctype>
    #include <string>
    using namespace std;

    int yylex(void);
    int yyparse(void);
    void yyerror(const char*);

    extern char * yytext;
    extern int yylineno;
    int errors = 0;
%}

%token SOME
%token ALL
%token VALUE
%token MIN
%token MAX
%token EXACTLY
%token THAT
%token NOT
%token AND
%token OR
%token ONLY
%token INVERSE

%token CLASS
%token EQUIVALENTTO
%token INDIVIDUALS
%token SUBCLASSOF
%token DISJOINTCLASSES
%token DISJOINTWITH

%token CLASS_ID
%token PROP_ID
%token INDIVIDUAL_ID
%token DATA_TYPE
%token CARDINALITY
%token RELOP

%union {
    bool closing_nesting;
}

%type <closing_nesting> quantifier
%type <closing_nesting> quantifier_list
%type <closing_nesting> subclass_of
%type <closing_nesting> some
%type <closing_nesting> equivalent_to
%type <closing_nesting> quantifier_conn
%type <closing_nesting> logical_conn_p

%nonassoc OR
%nonassoc AND

%define parse.error verbose

%%

owl     : primitive_class owl
        | defined_class owl
        | enumerated_class owl
        | covered_class owl
        | defined_covered_class owl
        | error owl { yyerrok; yyclearin; }
        | /* ε */
        ;

class   : CLASS ':' CLASS_ID { cout << endl << "🔷 " << yytext; }
        ;

// ===============================================================================================================================
// CLASSE PRIMITIVA ==============================================================================================================
// CLASSE COM AXIOMA DE FECHAMENTO ===============================================================================================

primitive_class : class class_opt subclass_of class_opt { if ($3) cout << endl << "✅ Classe com axioma de fechamento" << endl; 
                                                             else cout << endl << "✅ Classe primitiva" << endl; }
                ;

// ===============================================================================================================================
// CLASSE DEFINIDA ===============================================================================================================
// CLASSE COM DESCRIÇÕES ANINHADAS ===============================================================================================

defined_class   : class class_opt equivalent_to class_opt { if ($3) cout << endl << "✅ Classe com descrições aninhadas" << endl;
                                                               else cout << endl << "✅ Classe definida" << endl; }
                ;

// ===============================================================================================================================
// CLASSE ENUMERADA ==============================================================================================================

enumerated_class: class class_opt instance_eq_to class_opt { cout << endl << "✅ Classe enumerada" << endl; }
                ;
                
// ===============================================================================================================================
// CLASSE COBERTA ================================================================================================================

covered_class   : class class_opt logi_conn_eq_to class_opt { cout << endl << "✅ Classe coberta" << endl; }
                ;

// ===============================================================================================================================
// CLASSE DEFINIDA E COBERTA =====================================================================================================

// Não temos certeza a respeito da classificação a ser seguida no caso da classe Evaluated. A seguinte regra reconhece tal classe 
// e a classifica como definida e coberta, que seriam as duas possíveis classificações.
defined_covered_class   : class class_opt logi_conn_eq_to subclass_of class_opt { cout << endl << "✅ Classe definida e coberta" << endl; }
                        ;

// ===============================================================================================================================
// CLAUSULAS =====================================================================================================================

subclass_of     : SUBCLASSOF ':' quantifier_list                { $$ = $3;    }
                | SUBCLASSOF ':' CLASS_ID ',' quantifier_list   { $$ = $5;    }
                | SUBCLASSOF ':' CLASS_ID                       { $$ = false; }
                ;

equivalent_to   : EQUIVALENTTO ':' CLASS_ID AND logical_conn_p  { $$ = $5;    }
                ;

instance_eq_to  : EQUIVALENTTO ':' '{' individual_list '}'
                ;

logi_conn_eq_to : EQUIVALENTTO ':' logical_conn_c
                ;

quantifier_list : quantifier ',' quantifier_list                { $$ = $1 || $3; }
                | logical_conn_p ',' quantifier_list            { $$ = false;    }
                | quantifier
                ;

// ===============================================================================================================================
// CLAUSULAS OPCIONAIS ===========================================================================================================

class_opt       : disjoint_classes class_opt
                | individuals class_opt
                | disjoint_with class_opt
                | /* ε */
                ;

disjoint_classes: DISJOINTCLASSES ':' class_list
                ;

class_list      : CLASS_ID ',' class_list
                | CLASS_ID
                ;

individuals     : INDIVIDUALS ':' individual_list
                ;

individual_list : INDIVIDUAL_ID ',' individual_list
                | INDIVIDUAL_ID
                ;

disjoint_with   : DISJOINTWITH ':' CLASS_ID
                ;

// ===============================================================================================================================
// QUANTIFICADORES ===============================================================================================================

quantifier      : some                                  { $$ = $1;    }
                | min                                   { $$ = false; }
                | max                                   { $$ = false; }
                | exactly                               { $$ = false; }
                | value                                 { $$ = false; }
                | only                                  { $$ = true;  } // gambi para identificar axioma de fechamento
                | '(' quantifier ')'                    { $$ = $2;    }
                | INVERSE quantifier                    { $$ = $2;    }
                ;

some            : PROP_ID SOME CLASS_ID                 { $$ = false; }
                | PROP_ID SOME data_type                { $$ = false; }
                | PROP_ID SOME '(' quantifier ')'       { $$ = true;  } // gambi para identificar aninhamento
                | PROP_ID SOME '(' logical_conn_c ')'   { $$ = true;  } // gambi para identificar aninhamento
                ;

only            : PROP_ID ONLY CLASS_ID
                | PROP_ID ONLY '(' logical_conn_c ')'
                ;

min             : PROP_ID MIN CARDINALITY CLASS_ID
                ;

max             : PROP_ID MAX CARDINALITY CLASS_ID
                ;

exactly         : PROP_ID EXACTLY CARDINALITY CLASS_ID
                ;

value           : PROP_ID VALUE INDIVIDUAL_ID
                ;

data_type       : DATA_TYPE '[' RELOP CARDINALITY ']'
                | DATA_TYPE
                ;

// ===============================================================================================================================
// CONECTIVOS LÓGICOS - CLASSE ===================================================================================================

logical_conn_c  : CLASS_ID AND logical_conn_c
                | CLASS_ID OR logical_conn_c
                | CLASS_ID
                ;

// ===============================================================================================================================
// CONECTIVOS LÓGICOS - PROPRIEDADE ==============================================================================================

logical_conn_p  : quantifier_conn AND quantifier_conn   { $$ = $1 || $3; }
                | quantifier_conn OR quantifier_conn    { $$ = $1 || $3; }
                | quantifier_conn
                ;

quantifier_conn : quantifier AND quantifier_conn        { $$ = $1 || $3; }
                | quantifier OR quantifier_conn         { $$ = $1 || $3; }
                | '(' quantifier_conn ')'               { $$ = $2;       }
                | quantifier
                ;

// ===============================================================================================================================

%%

void yyerror(const char* str) {
    errors++;
    cout << endl << "❌ ERRO: " << str << endl;
    cout << "❌ \"" << yytext << "\" na linha " << yylineno << endl;
}

int main() {
    yyparse();

    cout << endl << (errors ? "⚠️ " : "✅");
    cout << " Compilação finalizada. ";
    cout << errors << (errors == 1 ? " classe" : " classes");
    cout << " com erros." << endl;
}