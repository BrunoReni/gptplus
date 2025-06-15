#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiGrvMsgExternoObj
Classe respons�vel em gravar o Json de publica��o no campo MHQ_MENSAG
    
/*/
//-------------------------------------------------------------------
Class RmiGrvMsgPubTerceirosObj From RmiGrvMsgPubPdvSyncObj
    Method New()            	//Metodo construtor da Classe
    Method Venda()              //Efetua tratamentos especificos na publica��o da venda 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo construtor da Classe

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class RmiGrvMsgPubTerceirosObj
    _Super:New("TERCEIROS")
    self:oBuscaObj  := RmiBusTerceirosObj():New()

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Venda
Efetua tratamentos especificos na publica��o da venda Pdv 
Terceiros

@author  Danilo Rodrigues
@version 1.0
@since   19/01/22   
/*/
//--------------------------------------------------------
Method Venda() Class RmiGrvMsgPubTerceirosObj

    LjGrvLog( "RmiGrvMsgExternoObj", "Metodo de Venda para PDV Terceiros." )

Return Nil
