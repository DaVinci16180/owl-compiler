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

    typedef struct Node {
        char* name;
        list<Node*> children;
    } Node;

    Node* currentRoot = (Node*) malloc(sizeof(Node));

    Node* createNode(char* name) {
        Node* newEntry = (Node*) malloc(sizeof(Node));
        newEntry->name = name;
        newEntry->children = {};

        return newEntry;
    }
%}

%union {
    struct Node* node;
    // struct Node* nodes;
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

%type <text> class_id
%type <node> quantifier_list
%type <node> quantifier
%type <node> some
%type <node> only

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
            printf("\n🔷 %s", $3);
            addClass($3);
        }
        ;

// ===============================================================================================================================
// CLASSE PRIMITIVA ==============================================================================================================
// CLASSE COM AXIOMA DE FECHAMENTO ===============================================================================================

primitive_class : class subclass_of disjoint_classes individuals {
                    // if ($2) cout << endl << "✅ Classe com axioma de fechamento" << endl; 
                    cout << endl << "✅ Classe primitiva" << endl;
                }
                | class logi_conn_eq_to subclass_of disjoint_classes individuals {
                    // if ($3) cout << endl << "✅ Classe com axioma de fechamento" << endl; 
                    cout << endl << "✅ Classe primitiva" << endl;
                }
                ;

// ===============================================================================================================================
// CLASSE DEFINIDA ===============================================================================================================
// CLASSE COM DESCRIÇÕES ANINHADAS ===============================================================================================

defined_class   : class equivalent_to disjoint_classes individuals {
                    // if ($2) cout << endl << "✅ Classe com descrições aninhadas" << endl;
                    cout << endl << "✅ Classe definida" << endl;
                }
                ;

// ===============================================================================================================================
// CLASSE ENUMERADA ==============================================================================================================

enumerated_class: class instance_eq_to disjoint_classes individuals {
                    cout << endl << "✅ Classe enumerada" << endl;
                }
                ;
                
// ===============================================================================================================================
// CLASSE COBERTA ================================================================================================================

covered_class   : class logi_conn_eq_to disjoint_classes individuals {
                    cout << endl << "✅ Classe coberta" << endl;
                }
                ;

// ===============================================================================================================================
// CLAUSULAS =====================================================================================================================

subclass_of     : SUBCLASSOF ':' quantifier_list
                | SUBCLASSOF ':' class_id ',' quantifier_list {
                    // for (Node* node : $5->children) {
                    //     printf("%s\n", node->name);
                    // }
                }
                | SUBCLASSOF ':' class_id
                ;

equivalent_to   : EQUIVALENTTO ':' class_id AND logical_conn_p
                ;

instance_eq_to  : EQUIVALENTTO ':' '{' individual_list '}'
                ;

logi_conn_eq_to : EQUIVALENTTO ':' logical_conn_c
                ;

quantifier_list : quantifier ',' quantifier_list {
                    // $3->children.push_front($1);
                    // $$ = $3;
                    $$ = NULL;
                }
                | logical_conn_p ',' quantifier_list { $$ = $3; }
                | quantifier {
                    // list<Node*> nodes{$1};
                    // char name[] = "axioms";
                    // Node* root = createNode(name);
                    // root->children = nodes;
                    // $$ = root;
                    $$ = NULL;
                }
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
                | min                { $$ = NULL; }
                | max                { $$ = NULL; }
                | exactly            { $$ = NULL; }
                | value              { $$ = NULL; }
                | only               { $$ = NULL; }
                | '(' quantifier ')' { $$ = NULL; }
                | INVERSE quantifier { $$ = NULL; }
                ;

some            : PROP_ID SOME class_id {
                    addObjProp($1);
                    // Node* n1 = createNode($1);
                    // Node* n2 = createNode($2);
                    // Node* n3 = createNode($3);
                    // char some[] = "some";
                    // Node* root = createNode(some);
                    // root->children.push_back(n1);
                    // $$ = root; 
                    $$ = NULL;
                }
                | PROP_ID SOME data_type                { addDataProp($1); $$ = NULL; }
                | PROP_ID SOME '(' quantifier ')'       { $$ = NULL; }
                | PROP_ID SOME '(' logical_conn_c ')'   { addObjProp($1); $$ = NULL; }
                ;

only            : PROP_ID ONLY class_id                 { addObjProp($1); $$ = NULL; }
                | PROP_ID ONLY '(' logical_conn_c ')'   { addObjProp($1); $$ = NULL; }
                ;

min             : PROP_ID MIN INTEGER class_id          { addObjProp($1); }
                ;

max             : PROP_ID MAX INTEGER class_id          { addObjProp($1); }
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
    cout << "❌ \"" << yytext << "\" na linha " << yylineno << endl;
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
            cout << "❌ Classe " << reference->name << " não declarada referenciada na linha " << reference->line << endl;
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