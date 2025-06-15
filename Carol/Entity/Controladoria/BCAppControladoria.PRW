#INCLUDE "BCDEFINITION.CH"

NEW APPLICATION CONTROL

//-------------------------------------------------------------------
/*/{Protheus.doc} BCAppControladoria
Modelagem da area  de Controladoria.

@author  Marcia Junko
@since   17/06/2019
 
/*/
//-------------------------------------------------------------------
Class BCAppControladoria
	Data cApp

	Method Init() CONSTRUCTOR
	Method ListEntities()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Instancia a classe de App e gera um nome inico para a area. 

@author  Marcia Junko
@since   17/06/2019

/*/
//-------------------------------------------------------------------
Method Init() Class BCAppControladoria
	::cApp := "Controladoria"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ListEntities
Lista as entidades (fatos e dimensoes) disponiveis da area, deve ser 
necessariamente o nome das classes das entidades.

@author  Marcia Junko
@since   17/06/2019

/*/
//-------------------------------------------------------------------
Method ListEntities() Class BCAppControladoria
//********************************* ATENCAO ****************************************//
//A ordem das entidades afetam a criacao das views caso haja dependencia entre elas //
//**********************************************************************************//
Return	{ "EMPRESA", + ;
          "FILIAL", + ;
          "TPSALDO", + ;
          "CONTACONTABIL", + ;
          "VISGER", + ;
          "MOEDACTB", + ;
          "DRE_DAY", + ;
          "BAL_DAY", + ;
          "LANCCTB", + ;
          "SALDOCUMULATIVO" }
          /*"CENTROCUSTO", +;
          "DRE", + ;
          "BALANCE", + ;
          "CCUSTO_DAY", +;
          "ITEMCONTABIL", +;
          "ITEMC_DAY", +;
          "CLASSEVALOR", +;
          "CLVALOR_DAY", +;*/
