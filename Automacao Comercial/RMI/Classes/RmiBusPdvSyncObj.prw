#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiBusPdvSyncObj
Classe responsável pela busca de dados no PdvSync
    
/*/
//-------------------------------------------------------------------
Class RmiBusPdvSyncObj From RmiBuscaObj

    Method New()	                    //Metodo construtor da Classe

    Method SetaProcesso(cProcesso)      //Metodo responsavel por carregar as informações referente ao processo que será recebido

    Method PreExecucao()                //Metodo com as regras para efetuar conexão com o sistema de destino

    Method Busca()                      //Metodo responsavel por buscar as informações no Assinante

    Method Confirma()                   //Metodo para confirmar a publicação de venda

    Method TrataRetorno()               //Metodo para buscar/Get as publicações no PdvSync como Exemplo: Vendas ou Clientes.
    
    Method LayEstAuto(cCmpRet)          //Metodo especifico para enviar dados ao Metodo generico GetLayEst

    Method AuxTrataTag(cTag, xConteudo, nItem)      //Metodo para efetuar o tratamento das Tags que serão gravadas na publicação

    Method IgnoraPub()                  //Metodo que define se ignora uma publicação

    Method setEvento()                  //Metodo que define o Evendo a ser grvado na MHQ

    Method AddConfirma()                //Metodo que carrega os registros que serão confirmados
    
    Method GetReserva(nItem)     // Retorna o numero da reserva para grava na SL2

    Data oXmlSefaz  as Object           //Objeto com o XML da SEFAZ - TAG VendaCustodiaXml
    Data oConteudo  as Object           //Objeto json com a taga conteudo
    Data aConfirma  as Array            //Array de objetos json com as confirmações
    Data oPdvSync   as Object           //Objeto PdvSync
    Data cNumRes    as Character        //Acumula numero da reservada.

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cAssinante) Class RmiBusPdvSyncObj

    Local cTenent       := ""
    Local cUser         := ""
    Local cPassword     := ""
    Local cClientId     := ""
    Local cClientSecret := ""
    Local nEnvironment  := 0
    Default cAssinante := "PDVSYNC"
    
    _Super:New(cAssinante)

    self:oXmlSefaz := Nil
    self:oConteudo := JsonObject():New()
    self:aConfirma := {}

    If self:oConfAssin:hasProperty("autenticacao")  
        cTenent       := IIF( self:oConfAssin["autenticacao"]:hasProperty("tenent")         , self:oConfAssin["autenticacao"]["tenent"]         , "")
        cUser         := IIF( self:oConfAssin["autenticacao"]:hasProperty("user")           , self:oConfAssin["autenticacao"]["user"]           , "")
        cPassword     := IIF( self:oConfAssin["autenticacao"]:hasProperty("password")       , self:oConfAssin["autenticacao"]["password"]       , "")
        cClientId     := IIF( self:oConfAssin["autenticacao"]:hasProperty("clientId")       , self:oConfAssin["autenticacao"]["clientId"]       , "")
        cClientSecret := IIF( self:oConfAssin["autenticacao"]:hasProperty("clientSecret")   , self:oConfAssin["autenticacao"]["clientSecret"]   , "")
        nEnvironment  := IIF( self:oConfAssin["autenticacao"]:hasProperty("environment")    , self:oConfAssin["autenticacao"]["environment"]    , 1 )
    EndIf

    If self:lSucesso
        If FindClass("totvs.protheus.retail.rmi.classes.pdvsync.PdvSync") //Incluido dependencia automatica
            self:oPdvSync := totvs.protheus.retail.rmi.classes.pdvsync.PdvSync():New(cTenent, cUser, cPassword, cClientId, cClientSecret, nEnvironment)       
        EndIf
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetaProcesso
Metodo responsavel por carregar as informações referente ao processo que será buscado

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetaProcesso(cProcesso) Class RmiBusPdvSyncObj


    self:cStatus := "0"  //0=Fila;1=A Processar;2=Processada;3=Erro

    //Chama metodo da classe pai para buscar informações comuns
    _Super:SetaProcesso(cProcesso)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PreExecucao
Metodo com as regras para efetuar conexão com o sistema de destino
Exemplo obter um token

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method PreExecucao() Class RmiBusPdvSyncObj
    
    Local aMensagem := {}

    If (aMensagem := self:oPdvSync:Token())[1]
        self:aHeader := self:oPdvSync:getHeader()
    else
        self:lSucesso := aMensagem[1]
        self:cRetorno := aMensagem[2]
    EndIf

Return self:lSucesso

//-------------------------------------------------------------------
/*/{Protheus.doc} Busca
Metodo responsavel por buscar as informações no Assinante

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method Busca() Class RmiBusPdvSyncObj

    Local cIdProprietario := ""

    //Inteligencia poderá ser feita na classe filha - default em Rest com Json
    If self:lSucesso

        If self:oBusca == Nil
            self:oBusca := FWRest():New("")
        EndIf

        If  !SubStr(self:oLayoutEnv["listIdProprietario"], 1, 1) == "&" // Tratamento para macro executar a configuração de envio.
            cIdProprietario := self:oLayoutEnv["listIdProprietario"]
        else            
            cIdProprietario :=  &(AllTrim(SubStr(self:oLayoutEnv["listIdProprietario"],2)))            
        EndIf    
        
        self:oBusca:SetPath(self:oConfProce["url"] + self:oConfAssin["inquilino"] + "?listIdProprietario=" + cIdProprietario )
        
        If !Empty(cIdProprietario)            
            If self:oBusca:Get( self:aHeader )

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
                self:cRetorno := self:oBusca:GetLastError() + " - [" + self:oConfProce["url"] + "]" + CRLF
            EndIf
        else
            self:lSucesso := .F.
            LjGrvLog("RmiBusPdvSyncObj", "IdProprietario não encontrado verifique a configuração no Assinante PdvSync")
        EndIf
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Confirma
Metodo que efetua a confirmação do recebimento

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method Confirma() Class RmiBusPdvSyncObj
    
    Local cUrl      := ""
    Local cJson     := ""

    If Len(self:aConfirma) == 0

        LjGrvLog(GetClassName(self), "Não há dados para confirmar.", self:cProcesso)
    Else

        self:oConfirma := JsonObject():New()
        self:oConfirma:Set(self:aConfirma)
        cJson          := EnCodeUtf8( self:oConfirma:toJson() )

        If Rat("/",self:oConfProce["url"])
            cUrl := Substr(self:oConfProce["url"], 1, Len(self:oConfProce["url"]) - 1 )
        Else
            cUrl := self:oConfProce["url"]
        EndIf

        if self:oEnvia == Nil
            self:oEnvia := FWRest():New("")
        EndIf

        self:oEnvia:SetPath(cUrl)
        
        If self:oEnvia:Put( self:aHeader, cJson )

            self:cRetorno := self:oEnvia:GetResult()
        Else

            self:lSucesso := .F.
            self:cRetorno := self:oEnvia:GetLastError() + " - " + self:oEnvia:CRESULT + "." 
        EndIf        

        FwFreeObj(self:oConfirma)
        FwFreeArray(self:aConfirma)
        self:aConfirma := {}
    EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataRetorno
Metodo para carregar a publicação de cadastro

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method TrataRetorno() Class RmiBusPdvSyncObj

    Local nPos := 0    
  
    If !self:oRetorno["success"]

        self:lSucesso := .F.
        self:cRetorno := AllTrim(self:cProcesso) + " - " + self:oRetorno["message"]
        LjGrvLog("RmiBusPdvSyncObj", self:cRetorno, self:lSucesso)
    Else
       
        If Len(self:oRetorno["data"]) == 0

            self:lSucesso := .F.
            self:cRetorno := I18n("Não há dados a serem baixadas:", { ProcName(), self:cRetorno} )   
            LjGrvLog("RmiBusPdvSyncObj", self:cRetorno)

        Else

            For nPos:=1 To Len(self:oRetorno["data"])

                self:oRegistro   := self:oRetorno["data"][nPos]
                self:cMsgOrigem  := Decode64(self:oRegistro["conteudo"])

                self:oConteudo:FromJson(self:cMsgOrigem)
                
                self:setEvento(self:oConteudo)

                //Atualiza cChaveUnica a partir do oConfProce["ChaveUni"]
                self:setChaveUnica(self:oConteudo)

                //Define se ignora o registro
                If self:IgnoraPub()
                    LjGrvLog( "RmiBusPdvSyncObj", "Publicação ignorada, condição atendida no método IgnoraPub.", {self:cAssinante, self:cProcesso, self:oRegistro["tipoMovimento"]} )
                    Loop
                EndIf

                If self:AuxExistePub()

                    //Carrega recebimento para confirmação
                    self:AddConfirma(self:oRetorno["data"][nPos]["id"], 2, "Publicação já existe, será ignorada.")

                    LjGrvLog( "RmiBusPdvSyncObj", "Publicação já existe, será ignorada.", {self:cAssinante, self:cProcesso, self:cChaveUnica} )
                    Loop
                EndIf

                self:Grava()

                //Carrega recebimento para confirmação
                self:AddConfirma(self:oRetorno["data"][nPos]["id"], IIF(self:lSucesso, 1, 2), self:cRetorno)

                FwFreeObj(self:oRegistro)
                self:oRegistro  := Nil

            Next nPos
            
        EndIf        
    EndIf

Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LayEstAuto
Metodo que Envia os dados especificos do layout de publicação para 
o metodo generico LayEstAuto, onde cadastrará a estação AUTOMATICO caso seja necessário.

@author  Danilo Rodrigues
@since 	 03/12/2021
@version 1.0		
/*/
//-------------------------------------------------------------------------------------
Method LayEstAuto(cCmpRet) Class RmiBusPdvSyncObj
        
    Local cRetorno  := ""
    Local aCodSM0   := {}

    Default cCmpRet := ""

    self:cModelo   := cValtoChar(self:oRegistro['ModeloFiscal'])
    self:cCodLoja  := Iif(self:oRegistro['Loja'] == NIL, "", self:oRegistro['Loja']['IdRetaguarda'])
    self:cEstacao  := Iif(self:oRegistro['Periferico'] == NIL, "", self:oRegistro['Periferico']['NumeroSerie'])
    self:cSerie    := cValtoChar(self:oRegistro['SerieNota'])    

    aCodSM0 := FWSM0Util():GetSM0Data( cEmpAnt , self:cCodLoja , { "M0_CODFIL" } ) //Retorna o M0_CODFIL do grupo 99 e filial 01

    If !Empty(aCodSM0)

        If (self:cModelo == '2' .and. self:cSerie <> '0') .or. (self:cModelo == '1' .and. !Empty(self:cEstacao))
            LjGrvLog("PdvSyncLayEst", "O numero da venda: " + self:oRegistro['Ccf'] + " corresponde aos criterios esperados para criação NFC-e do PDV e Serie Protheus - SLG!")
            cRetorno := _Super:LayEstAuto(cCmpRet)
        Else
            LjGrvLog("PdvSyncLayEst", "O Numero da venda: " + self:oRegistro['Ccf'] + " não corresponde aos criterios esperados para criação NFC-e do PDV e Serie Protheus - SLG!")
            LjGrvLog("PdvSyncLayEst", "Modelo recebido: " + cModelo + " tag Periferico: " + cEstacao + " tag SerieNota: " + cSerie + ". A macroexecução retornará em branco.")
        EndIf

    Else
        LjGrvLog("PdvSyncLayEst", "A loja recebida na venda" + self:oRegistro['Ccf'] + " não corresponde ao cadastro no Protheus SM0!")
    EndIf

Return cRetorno 

//-------------------------------------------------------------------
/*/{Protheus.doc} AuxTrataTag
Metodo para efetuar o tratamento das Tags que serão gravadas na publicação

@type    method
@param   cTag, Caractere, Nome da tag que ira retornar
@param   xConteudo, Indefinido, Conteudo da tag
@param   nItem, Numerico, Numero do item quando tag esta em um lista
@return  Indefinido, Conteudo da tag tratado

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method AuxTrataTag(cTag, xConteudo, nItem) Class RmiBusPdvSyncObj

    Local xTag := _Super:AuxTrataTag(cTag, xConteudo, nItem)

    If ValType(self:oXmlSefaz) == "O" .And. !self:oXmlSefaz:getStatus()
        self:lSucesso := .F.
        self:cRetorno := self:oXmlSefaz:getErro()
    EndIf

Return xTag



//-------------------------------------------------------------------
/*/{Protheus.doc} IgnoraPub
Metodo que define se ignora uma publicação

@type    method
@return  Lógico, Define se o registro deve ser ignorado na publicação
@author  Rafael Tenorio da Costa
@since   12/05/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method IgnoraPub() Class RmiBusPdvSyncObj

    Local lIgnora   := .F.
    Local cProcesso := AllTrim(self:cProcesso)

    Do Case

        Case cProcesso == "SANGRIA"

            //Se não for FechamentoCaixa = 1, Sangria = 2,
            If !( self:oRegistro["tipoMovimento"] $ "1|2" )
                lIgnora := .T.
            EndIf

        Case cProcesso == "SUPRIMENTO"

            //Se não for AberturaCaixa = 0, Suprimento = 3
            If !( self:oRegistro["tipoMovimento"] $ "0|3" )
                lIgnora := .T.
            EndIf
    End Case
    
Return lIgnora

//-------------------------------------------------------------------
/*/{Protheus.doc} setEvento
Metodo que define o Evento a ser utilizado na MHQ

@type    method
@return  Nil
@author  Everson S P Junior
@since   12/05/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method setEvento(oConteudo) Class RmiBusPdvSyncObj

    self:cEvento := "1"

    If Alltrim(self:cProcesso) == "VENDA"
        self:cEvento := Iif(oConteudo["SituacaoVenda"] == 0,'1',self:cEvento) //Venda
        self:cEvento := Iif(oConteudo["SituacaoVenda"] == 1,'2',self:cEvento) //Venda canc
        self:cEvento := Iif(oConteudo["SituacaoVenda"] == 3,'3',self:cEvento) //Venda Inut
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AddConfirma
Incrementa retornos de confirmação

@type    method
@param   cIdMensagem, Caractere, Código da mensagem que será confirmada
@param   nStatus, Numerico, Tipo de status de confirmação
@param   cObservacao, Caractere, Mensagem de retorno
@author  Rafael Tenorio da Costa
@since   06/07/2022
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Method AddConfirma(cIdMensagem, nStatus, cObservacao) Class RmiBusPdvSyncObj

    Local nConfirma := Len(self:aConfirma) + 1

    aAdd( self:aConfirma, JsonObject():New() )

    self:aConfirma[nConfirma]["idMensagem"] := cIdMensagem
    self:aConfirma[nConfirma]["status"]     := nStatus          //0=Processar, 1=Processada, 2=Erro, 3=Reprocessar
    self:aConfirma[nConfirma]["observacao"] := cObservacao
    
Return Nil
//--------------------------------------------------------
/*/{Protheus.doc} GetRetRes
Retorna a reserva

@type    Method
@return  Caractere, Código da reserva
@author  Everson S P Junior
@version 1.0
@since   24/01/23   
/*/
//--------------------------------------------------------
Method GetReserva(nItem) Class RmiBusPdvSyncObj
Local cReserva := ""
Local cProduto := self:oXmlSefaz:getDet({'prod', 'cProd'}, self:oRegistro['VendaItems'][nItem]['Sequencia'],'')
Local cFilint  := self:oRegistro['Loja']['IdRetaguarda']
Local cDocRes  := Alltrim(STR(IIF(self:oRegistro['preVendaId']==NIL,0,self:oRegistro['preVendaId'])))
Local nQuant   := self:oXmlSefaz:getDet({'prod', 'qCom'}, self:oRegistro['VendaItems'][nItem]['Sequencia'],'')
Local cQuery    := "" 
Local cAlias    := GetNextAlias()


cQuery := "SELECT C0_NUM "
cQuery += "  FROM " + RetSqlName("SC0")
cQuery += " WHERE C0_FILIAL = '" + PADR(cFilint,TAMSX3("C0_FILIAL")[1]) + "'"
cQuery += " AND C0_DOCRES = '" + PADR(cDocRes,TAMSX3("C0_DOCRES")[1]) + "'"
cQuery += " AND C0_PRODUTO = '" + PADR(cProduto,TAMSX3("C0_PRODUTO")[1]) + "'"
cQuery += " AND C0_QUANT = " + Alltrim(STR(nQuant)) +""
cQuery += " AND D_E_L_E_T_ <> '*'"

If !Empty(Self:cNumRes)
    cQuery += " AND C0_NUM NOT IN (" + Self:cNumRes + ")"
EndIf

DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

If Empty(Self:cNumRes)
    Self:cNumRes := (cAlias)->C0_NUM
Else
    Self:cNumRes += ","+(cAlias)->C0_NUM
EndIf

If !(cAlias)->(Eof())
    cReserva := (cAlias)->C0_NUM
    LjGrvLog("GetReserva", "Documento da Reserva enviado na venda: "+cDocRes)
    LjGrvLog("GetReserva", "Numero da Reserva no Protheus: "+cReserva)
Else
    self:lSucesso := .F.
    Self:cRetorno := "A Venda com reserva, não foi encontrado reserva para o documento enviado numero: "+cDocRes    
EndIf    

(cAlias)->( DbCloseArea() )

Return cReserva
