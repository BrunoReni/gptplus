/*
Programa   : SI101REMAN
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em fun��es que n�o est�o 
             definidas em um programa com o mesmo nome da fun��o. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:12 
Obs.       : Criado com gerador autom�tico de fontes 
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da fun��o MenuDef no programa onde a fun��o est� declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:12 
*/ 
Static Function MenuDef() 
Private cAvStaticCall := "SI101REMAN"

   aRotina := MDESI101() //Static Call(EECSI101, MenuDef) 

Return aRotina 
