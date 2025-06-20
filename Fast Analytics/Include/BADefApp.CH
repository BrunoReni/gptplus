#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
// XCOMMANDS.  
//-------------------------------------------------------------------
// Entidades
#XCOMMAND NEW ENTITY <entity>;
	=>;
   Function BAZ<entity>();;
   Return nil

// App
#XCOMMAND NEW APP <app>;
	=>;
   Function BAY<app>();;
   Return nil
//-------------------------------------------------------------------
// ENTITIES.
//-------------------------------------------------------------------
#DEFINE FACT		"F"
#DEFINE DIMENSION 	"D"

//-------------------------------------------------------------------
// QUERIES.
//-------------------------------------------------------------------
#DEFINE COMPANY_QUERY 1 // Posi��o da query.
#DEFINE COMPANY_NAME  2 // Posi��o da Empresa.

//-------------------------------------------------------------------
// GEN�RICOS.
//-------------------------------------------------------------------
#DEFINE CRYPT_TYPE 	"RC4" 

//-------------------------------------------------------------------
// TRATAMENTO DE ERROS
//-------------------------------------------------------------------
#DEFINE MSG_SUCESS              0 // Gerada com sucesso
#DEFINE MSG_ERR_TABLE_NOT_EXIST 1 // Tabela n�o existe; 
#DEFINE MSG_ERR_EMPTY_QUERY     2 // Erro de query em branco ou vazia.

//-------------------------------------------------------------------
// TIPO DE EXTRA��O DA ENTIDADE
// Este item define o tipo de extra��o da entidade e caso n�o seja 
// informado durante a cria��o da entidade, o sistema adota o padr�o
// P=per�odo. Este define � de uso espec�fico das fatos e n�o deve
// alterar o fluxo das dimens�es, independentemente do tipo informado. 
//-------------------------------------------------------------------
#DEFINE BYMONTH		"M"	//Mensal
