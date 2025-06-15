#INCLUDE "BCDEFINITION.CH"

NEW APPLICATION SUPRIMENTOS

//-------------------------------------------------------------------
/*/{Protheus.doc} BCAppSuprimentos
Modelagem da area  de  Suprimentos.

@author  jose.delmondes
@since   21/11/2019

/*/
//-------------------------------------------------------------------
Class BCAppSuprimentos
	Data cApp

	Method Init() CONSTRUCTOR
	Method ListEntities()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Instancia a classe de App e gera um nome inico para a area. 

@author  jose.delmondes
@since   21/11/2019

/*/
//-------------------------------------------------------------------
Method Init() Class BCAppSuprimentos
	::cApp := "Suprimentos"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ListEntities
Lista as entidades (fatos e dimensoes) disponiveis da area, deve ser 
necessariamente o nome das classes das entidades.

@author  jose.delmondes
@since   21/11/2019

/*/
//-------------------------------------------------------------------
Method ListEntities() Class BCAppSuprimentos
//********************************* ATENCAO ****************************************//
//A ordem das entidades afetam a criacao das views caso haja dependencia entre elas //
//**********************************************************************************//
Return	{ "EMPRESA"	 ,	  + ;
          "FILIAL"	 , 	  + ;
          "PRODUTO"	 , 	  + ;
          "NFENTRADA", 	  + ; 
          "GRUPO"	 ,	  + ;
          "PEDIDO"	 ,	  + ;
          "CONSUMO"	 ,	  + ;
          "FORNECEDOR",	  + ;
          "TABELAPRECO",  + ;
          "TIPO",         + ;
          "CCUSTO",       + ;
          "CCUSTONF",	  + ;
          "CCUSTOPEDIDO", + ;
          "MOEDA" }
