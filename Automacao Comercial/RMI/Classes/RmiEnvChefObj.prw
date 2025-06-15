#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiEnvChefObj
Classe respons�vel pelo envio das distribui��es para o Chef

/*/
//-------------------------------------------------------------------
Class RmiEnvChefObj From RmiEnviaObj

    Method New()    //Metodo construtor da Classe

    Method Envia()  //Metodo responsavel por enviar a mensagens ao sistema de destino

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo construtor da Classe

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cProcesso) Class RmiEnvChefObj
    
    _Super:New("CHEF",cProcesso) 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Envia
Metodo responsavel por enviar a mensagens ao Chef

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Envia() Class RmiEnvChefObj

    //Atualiza o token no body - para o Chef o token vale apenas para uma utiliza��o
    self:oBody["token"] := self:cToken
    self:cBody          := self:oBody:ToJson()

    _Super:Envia()

Return Nil
