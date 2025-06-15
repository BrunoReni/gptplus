#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIBUSCHEFOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiBusChefObj
Classe respons�vel pela busca de dados no Chef
    
/*/
//-------------------------------------------------------------------
Class RmiBusChefObj From RmiBuscaObj

    Data cLayoutFil     As Character    //Layout referente as filias que serao processadas pela API data de integra��o

    Data oLayoutFil     As Objetc       //Objeto jSonObject com layout das filias utilizadas pela API data de integra��o

    Data cDtIntegracao  As Character    //Data da Integra��o da Venda usada na API data de Integra��o

    Data cTime          As Character    //Hora para valida��o 

    Method New()	                    //Metodo construtor da Classe

    Method Busca()                      //Metodo responsavel por buscar as informa��es no Assinante

    Method SetaProcesso(cProcesso)      //Metodo responsavel por carregar as informa��es referente ao processo que ser� recebido

    Method TrataRetorno()               //Metodo que centraliza os retorno permitidos    

    Method Venda()	                    //Metodo para carregar a publica��o de venda

    Method Inutiliza()                  //Metodo para carregar a publica��o de inutiliza��o

    Method GravaFilial()	            //Metodo para gravar a data e hora da venda da API - CapaVenda/DatadeIntegracao

    Method CheckTime(cTime)

    Method AjustaJsonRepro()            //Metodo para verificar se esta utilizando o metodo ListPorDataMovimento

    Method LayEstAutoChef(cCmpRet, cModelo, cSerie, cEstacao, cCodLoja)    //Metodo que Retorna informa��es da SLG a partir do campo recebido no par�metro cCmpRet ou cadastra a SLG

    Method VldVendErro() // Descarta ou prepara para reprocessamento

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo construtor da Classe

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class RmiBusChefObj
    
    _Super:New("CHEF")

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Busca
Metodo responsavel por enviar a mensagens ao Chef

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Busca() Class RmiBusChefObj

    Local nItem := 0
    Local lDtIntegra := .F. //Variavel para verificar se esta configurado o metodo ListPorDataIntegracaoChefWeb

    //Atualiza o token no body - para o Chef o token vale apenas para uma utiliza��o
    self:oBody["token"] := self:cToken
    self:cBody          := self:oBody:ToJson()

    self:cLayoutFil     := ""

    self:oLayoutFil     := Nil

    self:cDtIntegracao  := ""

    If ("MHP")->(ColumnPos("MHP_LAYFIL")) > 0
    
        self:cLayoutFil := AllTrim(MHP->MHP_LAYFIL)
        lDtIntegra      := SubStr(self:oConfProce["url"],Rat("/",self:oConfProce["url"]) + 1) == "ListPorDataIntegracaoChefWeb"

        If lDtIntegra

            If Empty(self:cLayoutFil)
                LjGrvLog("RMIBUSCHEFOBJ","MHP_LAYFIL em branco")
                self:cLayoutFil := GatMHP(AllTrim(MHP->MHP_FILPRO),"CHEF","VENDA",.F.)
                LjGrvLog("RMIBUSCHEFOBJ","Retorno de GatMHP", self:cLayoutFil)

                RecLock("MHP",.F.)
                MHP->MHP_LAYFIL := self:cLayoutFil
                MHP->( MsUnLock() )
                LjGrvLog("RMIBUSCHEFOBJ","Campo MHP_LAYFIL ajustado")
            EndIf

            //Carrega layout de filial para 
            If !Empty(self:cLayoutFil) .And. SubStr(self:cLayoutFil, 1, 1) == "{"

                self:oLayoutFil := JsonObject():New()
                self:oLayoutFil:FromJson(self:cLayoutFil)

                If !(self:oLayoutFil == Nil) .and. Valtype(self:oLayoutFil["Filiais"]) == "A"
                    For nItem:=1 To Len( self:oLayoutFil["Filiais"] )
                        If Alltrim(self:oLayoutFil["Filiais"][nItem]["Filial"])  == Alltrim(self:aArrayFil[self:nFil][2])
                            If !Empty(self:oLayoutFil["Filiais"][nItem]["Data"])
                                self:cDtIntegracao := substr(FwTimeStamp(3,CtoD(self:oLayoutFil["Filiais"][nItem]["Data"])),1,rat("T",FwTimeStamp(3,CtoD(self:oLayoutFil["Filiais"][nItem]["Data"])))) + self:oLayoutFil["Filiais"][nItem]["Hora"]

                                If self:cDtIntegracao < self:oLayoutEnv["DataInicialIntegracaoChefweb"]  
                                    self:oBody["DataHoraUltimaIntegracaoChefweb"] := self:oLayoutEnv["DataInicialIntegracaoChefweb"]
                                Else 
                                    If  self:cDtIntegracao <  FwTimeStamp(3,dDataBase)    
                                        self:oBody["DataInicialIntegracaoChefweb"]     := substr(self:cDtIntegracao, 1,rat("T",self:cDtIntegracao)) +  self:oLayoutFil["Filiais"][nItem]["Hora"]
                                        self:oBody["DataHoraUltimaIntegracaoChefweb"]  := substr(self:cDtIntegracao, 1,rat("T",self:cDtIntegracao)) +  self:oLayoutFil["Filiais"][nItem]["Hora"]
                                        self:oBody["DataFinalIntegracaoChefweb"]       := substr(FwTimeStamp(3,CtoD(self:oLayoutFil["Filiais"][nItem]["Data"])+1),1,rat("T",FwTimeStamp(3,CtoD(self:oLayoutFil["Filiais"][nItem]["Data"])))) + self:oLayoutFil["Filiais"][nItem]["Hora"]
                                        self:cBody                                     := self:oBody:ToJson()
                                    EndIF
                                EndIf
                            EndIf
                        EndIf
                    Next nItem
                Else
                    LjGrvLog("RMIBUSCHEFOBJ", "Conte�do de cLayoutFil deve ser diferente de NIL")
                    LjGrvLog("RMIBUSCHEFOBJ", 'Conte�do de self:oLayoutFil["Filiais"] deve ser um array')
                EndIf
            Else
                LjGrvLog("RMIBUSCHEFOBJ","Conte�do do campo MHP_LAYFIL fora do formato esperado", self:cLayoutFil)
            EndIf
        Else
            LjGrvLog( "RMIBUSCHEFOBJ", "N�o esta configurado para utilizar o metodo ListPorDataIntegracaoChefWeb", SubStr(self:oConfProce["url"],Rat("/",self:oConfProce["url"]) + 1) )
        EndIf
    Else
        LjGrvLog("RMIBUSCHEFOBJ", "Campo MHP_LAYFIL n�o encontrado na tabela MHP - Efetue a cria��o do campo")
    EndIf

    _Super:Busca()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetaProcesso
Metodo responsavel por carregar as informa��es referente ao processo que ser� buscado

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetaProcesso(cProcesso) Class RmiBusChefObj

    If AllTrim(cProcesso) == "VENDA"
        self:cStatus := "0"  //0=Fila;1=A Processar;2=Processada;3=Erro
    EndIf

    //Chama metodo da classe pai para buscar informa��es comuns
    _Super:SetaProcesso(cProcesso)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataRetorno
Metodo que centraliza os retorno permitidos

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method TrataRetorno() Class RmiBusChefObj

    Local cProcesso := AllTrim(self:cProcesso)

    Do Case 

        Case cProcesso == "VENDA"
            self:Venda()
            self:Inutiliza()

        OTherWise

            self:lSucesso := .F.
            self:cRetorno := I18n(STR0001, {cProcesso})    //"Processo #1 sem tratamento para busca implementado"
            LjGrvLog("RMIBUSCHEFOBJ",self:cRetorno)

    End Case

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Venda
Metodo para carregar a publica��o de venda

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Venda() Class RmiBusChefObj

    Local nVenda     := 0
    Local nStatus    := 0                            //1=Aberto, 2=Finalizado, 3=Cancelado
    Local nItem      := 0 
    Local cHoraAux   := ""                           //Variavel auxiliar para uso de tempo
    Local cTimeAux   := ""                           //Variavel auxiliar para uso de tempo

    //Verifica se as vendas foram retornadas
    If !self:oRetorno["Sucesso"]

        self:lSucesso := .F.
        self:cRetorno := IIF(Valtype(self:oRetorno["Sucesso"]) =="U",AllTrim(self:cProcesso) + " - " + STR0004,AllTrim(self:cProcesso) + " - " + self:oRetorno["Erros"][1]["DescricaoErro"])//"Mensagem Recebida inv�lida verifique na Origem o Json Enviado"
        LjGrvLog("RMIBUSCHEFOBJ", self:cRetorno)

    //Processa as vendas
    Else

        //Verifica se existem vendas
        If Len(self:oRetorno["Vendas"]) == 0

            self:lSucesso := .F.
            self:cRetorno := I18n(STR0003, { ProcName(), self:cRetorno} )   //"[#1] N�o h� vendas a serem baixadas: #2"
            LjGrvLog("RMIBUSCHEFOBJ", self:cRetorno)

            If !(self:oLayoutFil == Nil)
                self:GravaFilial()
            Else
                LjGrvLog("RMIBUSCHEFOBJ", "oLayoutFil retornou NIL")
            EndIf
        Else

            For nVenda:=1 To Len(self:oRetorno["Vendas"])

                //Status da venda no Chef 1=Em Aberto, 2=Finalizada, 3=Cancelada
                nStatus := self:oRetorno["Vendas"][nVenda]["StatusVenda"]

                //S� carrega vendas Finalizadas ou Canceladas
                If nStatus > 1

                    //Carrega informa��es da publica��o que ser� gerada
                    self:oRegistro      := self:oRetorno["Vendas"][nVenda]  //Objeto que poder� ser utilizado para gerar o layout da publica��o. (MHP_LAYPUB)

                    self:cMsgOrigem := FWJsonSerialize(self:oRegistro) 

                    self:cChaveUnica    := self:oRegistro["ChaveVenda"]     //Chave �nica do registro publicado. (MHQ_CHVUNI)
                    self:cEvento        := IIF(nStatus == 2, "1", "2")      //Evento da publica��o 1=Upsert, 2=Delete (MHQ_EVENTO)

                    self:cDtIntegracao  := self:oRegistro["DataIntegracaoChefweb"]

                    //Verifica se a venda j� foi publicada
                    If self:AuxExistePub()
                        Loop
                    EndIf
                    
                    If !(self:oLayoutFil == Nil) .and. Valtype(self:oLayoutFil["Filiais"]) == "A"
                        For nItem:=1 To Len( self:oLayoutFil["Filiais"] )
                            If Alltrim(self:oLayoutFil["Filiais"][nItem]["Filial"])  == Alltrim(self:oPublica["L1_FILIAL"])
                                cTimeAux := self:CheckTime(substr(self:cDtIntegracao,rat("T",self:cDtIntegracao) +1 , 8))
                                self:cDtIntegracao :=  DtoC(Stod(StrTran( self:cDtIntegracao, "-", "" )))
                                If self:cDtIntegracao > self:oLayoutFil["Filiais"][nItem]["Data"]
                                    self:oLayoutFil["Filiais"][nItem]["Data"] := self:cDtIntegracao
                                    self:oLayoutFil["Filiais"][nItem]["Hora"] := cTimeAux
                                Else
                                    cHoraAux := ElapTime(self:oLayoutFil["Filiais"][nItem]["Hora"],cTimeAux)
                                    cTimeAux := Iif(self:oLayoutFil["Filiais"][nItem]["Hora"] < cHoraAux, self:oLayoutFil["Filiais"][nItem]["Hora"], cTimeAux)
                                    self:oLayoutFil["Filiais"][nItem]["Hora"] := cTimeAux
                                EndIf
                            EndIf
                        Next nItem
                    Else
                        LjGrvLog("RMIBUSCHEFOBJ", "oLayoutFil retornou NIL")
                        LjGrvLog("RMIBUSCHEFOBJ", 'self:oLayoutFil["Filiais"] deve ser um array')
                    EndIf

                    //Grava a publica��o
                    self:Grava()

                    If self:lSucesso .and. !(self:oLayoutFil == Nil)                        
                        self:GravaFilial()
                    EndIf

                    //Limpa objeto da publica��o
                    FwFreeObj(self:oRegistro)
                    FwFreeObj(self:oPublica)
                    self:oRegistro  := Nil
                    self:oPublica   := Nil
                    
                EndIf

            Next nVenda
        EndIf        
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Inutiliza
Metodo para carregar a publica��o de inutiliza��o MHQ_EVENTO = 3

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method Inutiliza() Class RmiBusChefObj

    Local nInutil    := 0

    If Valtype(self:oRetorno["NotasInutilizadas"]) !="U" .AND. Len(self:oRetorno["NotasInutilizadas"]) > 0
        For nInutil:=1 To Len(self:oRetorno["NotasInutilizadas"])

            //Carrega informa��es da publica��o que ser� gerada           
            self:cEvento        := "3"

            self:oRegistro      := self:oRetorno["NotasInutilizadas"][nInutil]

            self:cMsgOrigem     := FWJsonSerialize(self:oRegistro) 

            self:cChaveUnica    := self:oRegistro["ChaveVenda"]

            //Verifica se a inutilizacao j� foi publicada
            If self:AuxExistePub()
                Loop
            EndIf

            //Grava a publica��o
            self:Grava()
            
            LjGrvLog("RMIBUSCHEFOBJ", "Existe nota inutilizada" + self:oRetorno:ToJson() )

            //Limpa objeto da publica��o
            FwFreeObj(self:oRegistro)                
            self:oRegistro  := Nil
            
        Next nInutil
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaFilial
Metodo responsavel por gravar a data e hora da venda para 
a API - CapaVenda/DatadeIntegracao

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method GravaFilial() Class RmiBusChefObj

Local nItem     := 0

    self:cDtIntegracao := DtoC(Stod(StrTran( self:cDtIntegracao, "-", "" )))

    If !self:lSucesso
        LjGrvLog("RMIBUSCHEFOBJ","lSucesso retornou falso")

        If !(self:oLayoutFil == Nil) .and. Valtype(self:oLayoutFil["Filiais"]) == "A"
            For nItem:=1 To Len( self:oLayoutFil["Filiais"] )
                If Alltrim(self:oLayoutFil["Filiais"][nItem]["Filial"])  ==  Alltrim(self:aArrayFil[self:nFil][2])
                    If self:cDtIntegracao <= self:oLayoutFil["Filiais"][nItem]["Data"]
                        self:oLayoutFil["Filiais"][nItem]["Data"] := DtoC(Stod(StrTran( self:oBody["DataFinalIntegracaoChefweb"], "-", "" )))
                    EndIf
                EndIf
            Next nItem
        Else
            LjGrvLog("RMIBUSCHEFOBJ","oLayoutFil deve vir diferente de NIL")
            LjGrvLog("RMIBUSCHEFOBJ",'self:oLayoutFil["Filiais"] n�o � um array')
        EndIf
    EndIF

    //Atualiza o token no body - para o Chef o token vale apenas para uma utiliza��o
    If !(self:oLayoutFil == Nil)
        self:cLayoutFil := self:oLayoutFil:ToJson()
    Else
        LjGrvLog("RMIBUSCHEFOBJ","cLayoutFil igual a NIL - Token n�o atualizado")
    EndIf

    If !Empty(self:cLayoutFil)
        MHP->( DbSetOrder(1) )  //MHP_FILIAL, MHP_CASSIN, MHP_CPROCE, MHP_TIPO
        If MHP->( DbSeek(xFilial("MHP") + PadR(self:cOrigem, TamSx3("MHP_CASSIN")[1]) + PadR(self:cProcesso, TamSx3("MHP_CPROCE")[1])) )
            RecLock("MHP", .F.)
                MHP->MHP_LAYFIL := self:cLayoutFil
            MHP->( MsUnLock() )
            LjGrvLog("RMIBUSCHEFOBJ","Campo MHP_LAYFIL ajustado",self:cLayoutFil)
        EndIf
    Else
        LjGrvLog("RMIBUSCHEFOBJ","cLayoutFil em branco")
    EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckTime
Metodo responsavel por validar data e hora 

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method CheckTime(cTime) Class RmiBusChefObj
   
	Local cH := SubStr(cTime,1,2)
	Local cM := SubStr(cTime,4,2)
    Local cS := SubStr(cTime,7,2)
    Local nSec := Val(cS) + 1
    Local nMin := Val(cM)
    Local nHor := Val(cH)

    Default cTime := ""
	
    If (nSec > 59)
        cS := "00"
        cM := StrZero( nMin + 1, 2)
    Else    
        cS := StrZero( nSec, 2)
    EndIf

    If (nMin > 59)
		cM := "00"
        cH := StrZero( nHor + 1, 2)
	EndIf

    If (nHor > 23)
		cH := "00"
	EndIf 

    If Len(AllTrim(cTime)) == 8
		cTime := cH + ":" + cM + ":" + cS
	EndIf
   
Return cTime

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaJsonRepro
Metodo para verificar se esta utilizando o metodo ListPorDataMovimento
e tambem para alterar a data de inicio e fim do movimento.

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method AjustaJsonRepro() Class RmiBusChefObj

Local cJson := '{"CodigoLoja":"&self:aArrayFil[self:nFil][1]","DataMovimentoInicial":"&Str( Year(dDatabase), 4) +'-'+  StrZero( Month(dDatabase), 2) +'-'+ StrZero( Day(dDatabase), 2)","DataMovimentoFinal":"&Str( Year(dDatabase), 4) +'-'+  StrZero( Month(dDatabase), 2) +'-'+ StrZero( Day(dDatabase), 2)"}'
Local cUrl  := ""

If !("LISTPORDATAMOVIMENTO" $ Upper(self:oConfProce["url"]))
    Self:oLayoutEnv:FromJson(cJson)
    cUrl := StrTran(self:oConfProce["url"],"ListPorDataIntegracaoChefWeb","ListPorDataMovimento")
    self:oConfProce["url"] := cUrl
EndIf

Self:oLayoutEnv["DataMovimentoInicial"] := FWTimeStamp(3,RmiGetDate(),"00:00:00")
Self:oLayoutEnv["DataMovimentoFinal"]   := FWTimeStamp(3,RmiGetDate(),"23:59:59")

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LayEstAutoChef
Metodo que Retorna informa��es da SLG a partir do campo recebido no par�metro cCmpRet ou cadastra a SLG
Cadastra a esta��o AUTOMATICO caso seja necess�rio.
Utilizado no layout

@param cCmpRet      - Nome do campo que ir� retornar LG_SERIE, LG_PDV

@return cRetorno    - Caracter com a serie ou pdv 
				
@author  Danilo Rodrigues
@since 	 29/04/2021
@version 1.0				
/*/	
//-------------------------------------------------------------------------------------------------
Method LayEstAutoChef(cCmpRet, cModelo, cSerie, cEstacao, cCodLoja) Class RmiBusChefObj

    Local aArea     := GetArea()
    Local cRetorno  := ""
	Local aEstacao	:= {}
	Local aErro		:= {}
	Local cErro		:= ""
	Local nCont		:= 0
	Local cQuery    := ""
    Local cTab      := ""
    Local nOpc      := 3
    Local cFilRmi   := ""
    Local cPdv      := ""
    Local lContinua := .T.

    Default cModelo   := cValtoChar(self:oRegistro['ModeloFiscal'])
    Default cCodLoja  := cValtoChar(self:oRegistro['Loja']['Codigo'])
    Default cEstacao  := ""
    Default cSerie    := ""


    LjGrvLog("LayEstAutoChef","Dados recebidos para query. Modelo: " + cModelo + ", CodLoja: " + cCodLoja + ".")

	Private lMsErroAuto	   := .F.	//Cria a variavel do retorno da rotina automatica

    cFilRmi   := PadR( self:DePara("SM0", cCodLoja, 1, 0), TamSX3("LG_FILIAL")[1] )

    If !Empty(cFilRmi)

        LjGrvLog("LayEstAutoChef","Filial do De/Para de Loja: " + cFilRmi)

        cQuery := " SELECT LG_CODIGO, LG_NOME, LG_SERIE, LG_PDV, LG_SERPDV, LG_NFCE "
        cQuery += " FROM " + RetSqlName("SLG")
        cQuery += " WHERE LG_FILIAL = '" + cFilRmi + "'"

        Do Case
            Case cModelo == "1" .And. !Empty(self:oRegistro['SerieSAT'])
                cEstacao :=  self:oRegistro['SerieSAT']              
                cQuery +=   " AND LG_SERSAT = '" + cEstacao + "'"

            Case cModelo == "2" .And. !Empty(self:oRegistro['SerieNota'])
                cEstacao :=  self:oRegistro['SerieNota']              
                cQuery +=   " AND LG_SERIE = '" + cEstacao + "'"
                
            Case cModelo == "4" .And. Empty(self:oRegistro['SerieECF'])
                cEstacao :=  self:oRegistro['SerieECF']              
                cQuery +=   " AND LG_SERPDV = '" + cEstacao + "'"

            OTherWise
                lContinua     := .F.
                self:lSucesso := .F.
                self:cTipoRet := "ESTACAO"
                self:cRetorno += I18n("Dados recebidos n�o conferem com as regras estabelecidas: Modelo=[#1] Serie=[#2]", {cModelo, cSerie}) + CRLF

        End Case

        cQuery +=   " AND D_E_L_E_T_ = ' ' "

        LjGrvLog("LayEstAutoChef","Query executada: " + cQuery)

        If lContinua

            cTab := GetNextAlias()
            DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTab, .T., .F.)

            //N�o encontrou nenhuma esta��o
            If (cTab)->( Eof() )                        

                If cModelo == "1"
                    cSerie := "999"
                Else
                    cSerie := "001"
                EndIf

                SLG->( DbSetOrder(1) )
                While SLG->(DbSeek(cFilRmi + cSerie))
                    cSerie := Soma1(cSerie,TamSX3("LG_CODIGO")[1])
                End

                If cModelo == '1' .or. cModelo == '4'
                    cPdv := Substr( GetSxeNum("SLG", "LG_PDV", "LG_PDV" + cFilRmi), 8, 3)

                    Aadd( aEstacao, {"LG_FILIAL", cFilRmi            , Nil} )
                    Aadd( aEstacao, {"LG_CODIGO", cSerie            , Nil} )
                    Aadd( aEstacao, {"LG_NOME"	, "ESTACAO" + cSerie, Nil} )
                    Aadd( aEstacao, {"LG_SERIE"	, cEstacao	        , Nil} )
                    Aadd( aEstacao, {"LG_PDV"	, cPdv              , Nil} )
                    Aadd( aEstacao, {"LG_NFCE"  , .F.               , Nil} )

                    If cModelo == '1'
                        Aadd( aEstacao, {"LG_SERSAT", cEstacao      , Nil} )
                        Aadd( aEstacao, {"LG_USESAT", .T.           , Nil} )
                    Else
                        Aadd( aEstacao, {"LG_SERPDV", cEstacao      , Nil} )
                        Aadd( aEstacao, {"LG_USESAT", .F.           , Nil} )
                    EndIf
                    
                Else            

                    cPdv := Substr( GetSxeNum("SLG","LG_PDV","LG_PDV" + cFilRmi), 8, 3)

                    Aadd( aEstacao, {"LG_FILIAL", cFilRmi            , Nil} )
                    Aadd( aEstacao, {"LG_CODIGO", cSerie            , Nil} )
                    Aadd( aEstacao, {"LG_NOME"	, "ESTACAO" + cSerie, Nil} )
                    Aadd( aEstacao, {"LG_SERIE"	, cEstacao	        , Nil} )
                    Aadd( aEstacao, {"LG_PDV"	, cPdv              , Nil} )
                    Aadd( aEstacao, {"LG_NFCE"	, .T.               , Nil} )
                EndIF
                
                
                //Cadastra a esta��o AUTOMATICA
                MSExecAuto({|a,b,c,d| LOJA121(a,b,c,d)}, /*cFolder*/, /*lCallCenter*/, aEstacao, nOpc)
                
                If lMsErroAuto

                    aErro := GetAutoGRLog()

                    For nCont := 1 To Len(aErro)
                        cErro += aErro[nCont] + CRLF
                    Next nCont

                    self:lSucesso := .F.
                    self:cTipoRet := "ESTACAO"
                    self:cRetorno += cErro
                Else

                    cRetorno := &("SLG->" + cCmpRet)                    
                EndIf
            Else

                If cModelo == "2" .And. (cTab)->LG_NFCE == "F"

                    self:lSucesso := .F.
                    self:cTipoRet := "ESTACAO"
                    self:cRetorno += I18n("A esta��o #1 do Protheus n�o se refere ao tipo NFCE.", {(cTab)->LG_CODIGO} ) + CRLF
                Else

                    cRetorno := &(cTab + "->" + cCmpRet)
                EndIf
            EndIf

        EndIf
    Else

        self:lSucesso := .F.
        self:cTipoRet := "ESTACAO"
        self:cRetorno += I18n("N�o foi realizado o De/Para da Filial: CodigoLoja=[#1]", cCodLoja ) + CRLF
    EndIf

	Asize(aEstacao, 0)
	ASize(aErro   , 0)

    RestArea(aArea)

    LjGrvLog("LayEstAutoChef","Retorno do conteudo do campo: ", cRetorno)

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} VldVendErro 
Esse metodo valida erro para efetuar deletar e receber os
novos registros.
@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method VldVendErro() Class RmiBusChefObj
Local lRet          := .F.

If MHQ->MHQ_STATUS == '4'
    LjGrvLog("VldVendErro", "RmiBusChefObj - Encontrado Reprocessamento na tabela MHQ")
    lRet := .T.    
    Self:DelVenda(MHQ->MHQ_UUID)// S� deletar a venda e MHQ ja estiver com 4 para reprocessar.
EndIf

Return lRet
