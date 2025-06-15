#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiGrvMsgExternoObj
Classe responsável em gravar o Json de publicação no campo MHQ_MENSAG
    
/*/
//-------------------------------------------------------------------
Class RmiGrvMsgPubTerceirosObj From RmiGrvMsgPubPdvSyncObj
    Method New()            	//Metodo construtor da Classe
    Method Venda()              //Efetua tratamentos especificos na publicação da venda 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

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
Efetua tratamentos especificos na publicação da venda Pdv 
Terceiros

@author  Danilo Rodrigues
@version 1.0
@since   19/01/22   
/*/
//--------------------------------------------------------
Method Venda() Class RmiGrvMsgPubTerceirosObj

    LjGrvLog( "RmiGrvMsgExternoObj", "Metodo de Venda para PDV Terceiros." )

Return Nil
