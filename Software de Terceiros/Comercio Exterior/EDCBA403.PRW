/*
Programa   : EDCBA403 - Nacionaliza��o
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em fun��es que n�o est�o 
             definidas em um programa com o mesmo nome da fun��o. 
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 09/09/10 - 14:32 
Obs.       : Criado com gerador autom�tico de fontes 
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da fun��o MenuDef no programa onde a fun��o est� declarada. 
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 09/09/10 - 14:32 
*/ 
Static Function MenuDef() 

   aRotina := MDDBA400() //Static Call(EDCBA400, MenuDef) 

Return aRotina 
