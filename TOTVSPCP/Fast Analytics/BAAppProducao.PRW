#INCLUDE "BADEFINITION.CH"

NEW APP PRODUC

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAppProducao
Modelagem da �rea de Produ��o.

@author  Helio Leal
@author  henrique.cesar
@since   02/03/2018
/*/
//-------------------------------------------------------------------
Class BAAppProducao
	Data cApp

	Method Init() CONSTRUCTOR
	Method ListEntities()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Instancia a classe de App e gera um nome �nico para a �rea. 

@author  Helio Leal
@author  henrique.cesar
@since   02/03/2018
/*/
//-------------------------------------------------------------------
Method Init() Class BAAppProducao
	::cApp := "Producao"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ListEntities
Lista as entidades (fatos e dimens�es) dispon�veis da �rea, deve ser 
necessariamente o nome das classes das entidades.

@author  Helio Leal
@author  henrique.cesar
@since   02/03/2018
/*/
//-------------------------------------------------------------------
Method ListEntities() Class BAAppProducao
Return	{ "PRODCART", + ; //Fato BAProdCart
		  "PRODREAL", + ; //Fato BAProdReal
		  "EMPRESA", + ; //Dimens�o BAEmpresa
		  "FILIAL", + ; //Dimens�o BAFilial
		  "ITEM", + ; //Dimens�o BAItem
		  "FAMMAT", + ; //Dimens�o BAFamMat
		  "FAMCOM", + ; //Dimens�o BAFamCom
		  "GRPESTOQUE", + ; //Dimens�o BAGrpEstoque
		  "GRPCLIENTE", + ; //Dimens�o BAGrpCliente
		  "DEPOSITO", + ;	//Dimens�o BADeposito	
		  "CLIENTE", + ;  //Dimens�o BACliente
		  "REGIAO" } //Dimens�o BARegiao