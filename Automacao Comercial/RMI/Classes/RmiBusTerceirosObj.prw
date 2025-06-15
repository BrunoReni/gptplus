#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiBusPdvSyncObj
Classe respons�vel pela busca de dados no PdvSync
    
/*/
//-------------------------------------------------------------------
Class RmiBusTerceirosObj From RmiBusPdvSyncObj

    Method New()	                    //Metodo construtor da Classe

    Method Busca()                      //Metodo responsavel por buscar as informa��es no Assinante

    Method Confirma()

    Method GetHeader()

    Method PreExecucao()                //Metodo com as regras para efetuar conex�o com o sistema de destino

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo construtor da Classe

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cAssinante) Class RmiBusTerceirosObj

    Default cAssinante := "TERCEIROS"
    
    _Super:New(cAssinante)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} Busca
Metodo responsavel por buscar as informa��es no Assinante

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method Busca() Class RmiBusTerceirosObj

    //Inteligencia poder� ser feita na classe filha - default em Rest com Json
    If self:lSucesso

        If self:oBusca == Nil
            self:oBusca := FWRest():New(self:oConfProce["url"])
        EndIf

        self:oBusca:SetPath(self:oConfProce["Path"])

        If self:oBusca:Get(Self:GetHeader())

            self:cRetorno := self:oBusca:GetResult()

            If self:oRetorno == Nil
                self:oRetorno := JsonObject():New()
            EndIf
            self:oRetorno:FromJson(self:cRetorno)
            self:cRetorno := ""

            //Centraliza os retorno permitidos
            self:TrataRetorno()
        Else

            self:lSucesso := .F.
            self:cRetorno := self:oBusca:GetLastError() + " - [" + self:oConfProce["url"] + self:oConfProce["Path"] + "]" + CRLF
        EndIf
    EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} Confirma
Metodo que efetua a confirma��o do recebimento

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method Confirma() Class RmiBusTerceirosObj
    
    Local cJson     := ""

    If Len(self:aConfirma) == 0

        LjGrvLog(GetClassName(self), "N�o h� dados para confirmar.", self:cProcesso)
    Else

        self:oConfirma := JsonObject():New()
        self:oConfirma:Set(self:aConfirma)
        cJson          := EnCodeUtf8( self:oConfirma:toJson() )

        If self:oEnvia == Nil
            self:oEnvia := FWRest():New(self:oConfProce["url"])
        EndIf

        self:oEnvia:SetPath(self:oConfProce["Path"])

		LjGrvLog( GetClassName(self), "Envio de confirma��o da busca." , {self:oConfProce["url"],self:cProcesso, cJson,Self:GetHeader()} )
        If self:oEnvia:Put( Self:GetHeader(), cJson )

            self:cRetorno := self:oEnvia:GetResult()
        Else

            self:lSucesso := .F.
            self:cRetorno := self:oEnvia:GetLastError() + " - " + IIF(ValType(self:oEnvia:CRESULT) == "C", self:oEnvia:CRESULT," Erro n�o retornado") + "." 
        EndIf        

        FwFreeObj(self:oConfirma)
        FwFreeArray(self:aConfirma)
        self:aConfirma := {}
    EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GetHeader
Metodo responsavel  por encontrar tag's que ser�o enviadas do header

@author  Lucas Novais
@version 1.0
/*/
//-------------------------------------------------------------------

Method GetHeader() Class RmiBusTerceirosObj
    Local aHeader := {}
    Local aTags   := {} 
    Local nI      := 0
    Local cHeader := ""
    Local lHeader := .T.

    Do case
        Case self:oConfProce:hasProperty("Header")
            cHeader := "Header"
        Case self:oConfProce:hasProperty("HEADER")
            cHeader := "HEADER"
        Case self:oConfProce:hasProperty("header")
            cHeader := "header"        
        OtherWise
            lHeader := .F.
            LjGrvLog("RmiBusTerceirosObj","Tag [header] n�o encontrada na configura��o, buscamos por [Header],[HEADER] e [header]")
    End Case

    If lHeader
        aTags := self:oConfProce[cHeader]:GetNames()
        For nI := 1 To Len(aTags)
            Aadd(aHeader,aTags[nI] + ":" + self:oConfProce[cHeader][aTags[nI]]) 
        Next
    EndIf
     
    

Return aHeader
//-------------------------------------------------------------------
/*/{Protheus.doc} PreExecucao
Metodo com as regras para efetuar conex�o com o sistema de destino
Exemplo obter um token

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method PreExecucao() Class RmiBusTerceirosObj
    

Return nil
