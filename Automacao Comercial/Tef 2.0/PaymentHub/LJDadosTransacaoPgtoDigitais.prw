#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

Function LJPgtoDigi ; Return                    

//--------------------------------------------------------------------
/*/{Protheus.doc} LJDadosTransacaoPgtoDigitais
Armazena as informacoes para realizacao de uma transacao os meios
de pagamento digitais

@type       Class
@author     Bruno Almeida
@since      26/10/2020
@version    12.1.27
/*/
//--------------------------------------------------------------------
Class LJDadosTransacaoPgtoDigitais From LJADadosTransacao
    
	Data cFormaPgto	//Codigo da forma
	Data cAdmFin	//Administradora financeira
	Data cIdPagto	//Id do Pagamento (Qdo utilizado mais de um pagamento digital na mesma venda)

	Method New()

EndClass                

//--------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe LJDadosTransacaoPgtoDigitais.

@type       Method
@author     Bruno Almeida
@since      26/10/2020
@version    12.1.27
@return 	Self, Objeto de representa��o da classe LJDadosTransacaoPgtoDigitais.

/*/
//--------------------------------------------------------------------
Method New(	nValor, cFormaPgto, nPar, nTpTrans, cIdPagto ) Class LJDadosTransacaoPgtoDigitais 

	Default nValor 		:= 0
 	Default nPar 		:= 1
	Default nTpTrans 	:= 14
	Default cIdPagto 	:= ""

	_Super:New(nValor)
	
	Self:cFormaPgto := cFormaPgto
	Self:cAdmFin	:= ""
	Self:nParcela 	:= nPar
	Self:nTipoTrans := nTpTrans
	Self:cIdPagto 	:= cIdPagto

Return Self  
