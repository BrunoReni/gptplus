#INCLUDE "TOTVS.CH"
#INCLUDE "PlsHatClient.ch"

#DEFINE 5_SEG 5000

#DEFINE PENDING "0"
#DEFINE PROCESSED "1"
#DEFINE ERROR_GEN_B1R "2"
#DEFINE ERROR_GEN_BXX "3"
#DEFINE ERROR_DOWN_XML "4"
#DEFINE ERROR_UPD_HAT "5"
#DEFINE ERROR_DELETE "6"
#DEFINE DELETE_ERROR "7"

#DEFINE TRAN_DOWNLOAD "0"
#DEFINE TRAN_DELETE "E"

/*/{Protheus.doc} PHatXMLServ
    Servico que realiza o download dos XMLs do HAT
    @type  class
    @author victor.silva
    @since 20210806
/*/
class PHatXMLServ From PLSService

    data httpClient
    data codeSusep
    data xmlPath

    public method New() constructor

    public method procNextMsg()
    public method beforeProc()
    public method runDownload(message)
    public method runDelete(recno)
    public method generateMessages()
    public method downloadXml(url, token, xml)
    public method generateBXX(xmlContent, url, result)
    public method updateHatBatch(protocol, result)
    
endclass

/*/{Protheus.doc} New
    Construtor
    @type  class
    @author victor.silva
    @since 20210806
/*/
method New() class PHatXMLServ
    _Super:New()
    self:cLogFile := "plsxmldownload.log"
    self:cAlias := "B1R"
    self:oFila := PlsFilaB1R():New()
    self:httpClient := PlHatCliBA():new()
    self:xmlPath := PLSMUDSIS(PLSMUDSIS(GetNewPar("MV_TISSDIR","\TISS\")) + "UPLOAD\")
    self:codeSusep := RetDefaultSusep()
return self

/*/{Protheus.doc} procNextMsg
@author  victor.silva
@version P12
@since   20210809
/*/
method beforeProc() class PHatXMLServ
    local lRet := _Super:beforeProc()
    if !(lRet := self:httpClient:setup())
        self:logMsg("Erro ao fazer setup do client batchesAuthorizations")
    endif
return lRet

/*/{Protheus.doc} procNextMsg
@author  victor.silva
@version P12
@since   20210809
/*/
method procNextMsg() class PHatXMLServ
    local message as object

    self:logMsg("Procurando registro na " + self:cAlias + " para processar")
    
    if self:oFila:getMsg()
    
        message := self:oFila:getNext()
        if message != nil
            self:logMsg("--> Iniciando processamento protocolo: " + message:getValue("protocol") + " alias: " + self:cAlias)
            if message:getValue("transactionType") == TRAN_DOWNLOAD
                status := self:runDownload(message)
            elseif message:getValue("transactionType") == TRAN_DELETE
                status := self:runDelete(message:getValue("sourceProtocol"))
            endif
            self:oFila:setEndProc(status)
            self:logMsg("--> Finalizando processamento protocolo: " + message:getValue("protocol") + " alias: " + self:cAlias)
        endif
        self:nTry := 0
    else
        self:logMsg("Nao existem XMLs pendente de processamento, realizando download")
        self:generateMessages(TRAN_DOWNLOAD, .F.)
        self:generateMessages(TRAN_DELETE, .F.)

        //Busca de novo quem falhou em criar B1R
        self:generateMessages(TRAN_DOWNLOAD, .T.)
        self:generateMessages(TRAN_DELETE, .T.)
        
        self:nTry++

        //Reprocessa com erro
        PLSReProB1R()
        //Reprocessa com falha na comunica��o
        PLSReComHAT()

        // Aguarda 5 segundos antes de procurar novos itens
        sleep(5_SEG)
    endif
    
return

/*/{Protheus.doc} runDownload
    Realiza o download do XML no hat a partir de um registro do B1R
    @type  class
    @author victor.silva
    @since 20210813
/*/
method runDownload(message) class PHatXMLServ
    local accessToken := message:getValue("accessToken")
    local hasError := .F.
    local rejectionDescription as character
    local status as character
    local statusTiss as character
    local trackingStatus as character
    local url := message:getValue("fileUrl")
    local xmlContent as character
    local cTipGui := ""
    
    self:logMsg("Iniciando download")
    if self:downloadXml(url, accessToken, @xmlContent)
        if !(self:generateBXX(xmlContent, message, @rejectionDescription))
            statusTiss := STTISS_ENC_SEM_PAG
            status := ERROR_GEN_BXX
            trackingStatus := BATCHAUTH_TRACK_ERR_GEN_BXX
            hasError := .T.
        else
            cTipGui := BXX->BXX_TIPGUI
            status := PROCESSED
            trackingStatus := BATCHAUTH_TRACK_SUCCESS
            statusTiss := STTISS_RECEBIDO
        endif
    else
        statusTiss := STTISS_ENC_SEM_PAG
        status := ERROR_DOWN_XML
        trackingStatus := BATCHAUTH_TRACK_ERR_DOWN_XML
        if empty(rejectionDescription)
            rejectionDescription := "Nao foi possivel enviar o XML para a operadora"
        endif
        hasError := .T.
    endif

    if cTipGui <> '10' .and. !(self:updateHatBatch(message, statusTiss, trackingStatus, hasError, rejectionDescription))
        status := ERROR_UPD_HAT
    endif

return status

/*/{Protheus.doc} runDelete
    Realiza a dele��o de um lote na BXX a partir do registro da B1R caso o mesmo esteja em fase de submiss�o
    @type  class
    @author victor.silva
    @since 20210813
/*/
method runDelete(sourceProtocol) class PHatXMLServ
	local sqlStatement  as character
    local status        as character
    local cSql          as character
    local cError    := ''
	local sqlAlias  := getNextAlias()
	local success   := .f.
    local lPodeExc  := .t.    

	sqlStatement := "SELECT R_E_C_N_O_ RECNO, BXX_TIPGUI, BXX_PROGLO " 
    sqlStatement += " FROM "+RetSqlName("BXX") + " "
	sqlStatement += " WHERE BXX_FILIAL	= '" + xFilial("BXX") + "' "
	sqlStatement += " AND BXX_PLSHAT	= '" + sourceProtocol + "' "
	sqlStatement += " AND D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,sqlStatement),sqlAlias,.F.,.T.)

    self:logMsg("Iniciando exclusao")
	if (sqlAlias)->(!eof())
        //Caso o registro na BXX a ser eliminado for um recurso de Glosa, sera executado a exclusao do recurso tambem.
		if (sqlAlias)->BXX_TIPGUI== "10"
			cSql := " SELECT B4D.R_E_C_N_O_ RECNO"
			cSql += " FROM " + RetsqlName("B4D") + " B4D "
			cSql += " WHERE B4D_FILIAL = '" + xFilial("B4D") + "' "
			cSql += " AND B4D_PROTOC = '" + (sqlAlias)->BXX_PROGLO + "' "
			cSql += " AND D_E_L_E_T_ = ' ' "
			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"RecursoGlosa",.f.,.t.)
			While !(RecursoGlosa->(EoF())) //Loop para percorrer registros sob o mesmo numero de protocolo
				B4D->(DBGoTo(RecursoGlosa->RECNO))
				lPodeExc := staticCall(PLSA974,ExcRecGlo,@cError,.t. )
				if !lPodeExc
                    self:logMsg("Erro ao excluir recurso de glosa: " + cError)
                    exit
                endif
				RecursoGlosa->(dbSkip())
			Enddo
			RecursoGlosa->(dbcloseArea())		
		endif
        if lPodeExc
            success := PLSMANBXX(,,,,,,,5,(sqlAlias)->RECNO,,)
        endif
        if !success
            status := ERROR_DELETE
            self:logMsg("Erro ao excluir BXX")
        else
            status := PROCESSED
            self:logMsg("Excluido com sucesso")
        endif
	else
        status := PROCESSED
        self:logMsg("Lote nao localizado")
	endif
	(sqlAlias)->(dbclosearea())

return status

/*/{Protheus.doc} generateMessages
@author  victor.silva
@version P12
@since   20210809
/*/
method generateMessages(transactionType, lReprocessa) class PHatXMLServ
    local atItems := 1
    local collection as object
    local filter := ""
    local item as object
    local lenItems := 0
    local protocol as character
    local responseBody as object

    if lockByName("PlsHatXmlDownload", .T., .T.)
        // Prepara os dados da requisicao
        if !lReprocessa
            if transactionType == TRAN_DOWNLOAD
                filter += "(trackingStatus eq " + BATCHAUTH_TRACK_PENDING + " and"
                filter += " not(azureStorageFilePath eq '')"
                filter += " and isDeleted eq '')"
                filter := strTran(filter, " ", "%20")
            elseif transactionType == TRAN_DELETE
                filter += "(trackingStatus eq " + BATCHAUTH_TRACK_PENDING_DEL
                filter += " and not (isDeleted eq ''))"
                filter := strTran(filter, " ", "%20")
            endif
        else
            if transactionType == TRAN_DOWNLOAD
                filter += "(trackingStatus eq " + ERROR_GEN_B1R + " and"
                filter += " not(azureStorageFilePath eq '')"
                filter += " and isDeleted eq '')"
                filter := strTran(filter, " ", "%20")
            elseif transactionType == TRAN_DELETE
                filter += "(trackingStatus eq " + ERROR_GEN_B1R
                filter += " and not (isDeleted eq ''))"
                filter := strTran(filter, " ", "%20")
            endif
        endif

        self:httpClient:pushQueryParam({"filter", filter})
        self:httpClient:pushQueryParam({"codeSusep", self:codeSusep})

        self:httpClient:pushField("status")
        self:httpClient:pushField("batchDate")
        self:httpClient:pushField("protocol")
        self:httpClient:pushField("azureStorageFilePath")
        self:httpClient:pushField("azureStorageSasToken")
        self:httpClient:pushField("batchNumber")
        self:httpClient:pushField("healthProviderId")
        self:httpClient:pushField("authType")

        self:httpClient:setPageSize("100")

        // Recupera os valores da API do hat de acordo com a paginacao definida
        while self:httpClient:hasNext() .and. self:httpClient:get()
            responseBody := self:httpClient:getResponseBody()
            if (lenItems := len(responseBody["items"])) > 0
                collection := PlsCltB1R():new()
                putBody := JsonObject():new()
                while atItems <= lenItems
                    item := responseBody["items"][atItems]
                    collection:setValue("fileUrl", item['azureStorageFilePath'])
                    collection:setValue("accessToken", item['azureStorageSasToken'])
                    collection:setValue("healthProviderId", item['healthProviderId'])
                    collection:setValue("sourceProtocol", item['batchNumber'])
                    collection:setValue("uploadDate", StrTran(item['batchDate'],"-",""))
                    collection:setValue("transactionType", transactionType)
                    collection:setValue("status", PENDING)
                    // Marca o trackingStatus do registro na origem apos fazer o commit (consultar PlsHatClient.ch para descricao)
                    if !(collection:commit(.T., @protocol))
                        self:logMsg("Erro na incluisao na B1R. PEG: " + item['batchNumber'] + " transactionType: " + transactionType + " DETALHE: " + collection:getError())
                        putBody["status"] := PROCESSED
                        putBody["trackingStatus"] := BATCHAUTH_TRACK_ERR_GEN_B1R
                        self:httpClient:put(item['batchNumber'], putBody)
                    else
                        putBody["status"] := PROCESSED
                        putBody["trackingStatus"] := BATCHAUTH_TRACK_SUCCESS
                        putBody["protocol"] := protocol
                        self:httpClient:put(item['batchNumber'], putBody)
                    endif
                    atItems++
                enddo
            endif
        enddo

        self:httpClient:reset()

        unLockByName("PlsHatXmlDownload", .T., .T.)
    else
        self:logMsg("Ja existe uma instancia do processamento de geracao de pedidos em andamento")
    endif

return

/*/{Protheus.doc} downloadXml
@author  victor.silva
@version P12
@since   20210813
/*/
method downloadXml(url, token, xmlContent) class PHatXMLServ
    local httpClient := PlHatCliAS():new()
    local success := .F.

    if (success := httpClient:downloadXml(url, token))
        xmlContent := httpClient:getResult()
        if 'PARENTNOTFOUND' $ upper(xmlContent)
            success := .F.
        endif
    endif

return success

/*/{Protheus.doc} generateBXX
@author  victor.silva
@version P12
@since   20210813
/*/
method generateBXX(xmlContent, message, result) class PHatXMLServ
    local fileName := getLastItem(message:getValue("fileUrl"))
    local healthProviderId := message:getValue("healthProviderId")
    Local cArquivo := Substr(fileName, 1, RAT(".",fileName)-1 ) + "_" + healthProviderId + "_" + allTrim(str(day(date()))) + "_"+ Alltrim(Str(month(date()))) + "_" + ( Alltrim(Str(Year(date()))) ) + "_" + Left(Time(),2) + "_" + Substr(Time(),4,2) + "_" + Right(Time(),2) + Substr(fileName, RAT(".",fileName) )
    local sourceProtocol := getLastItem(message:getValue("sourceProtocol"))
    local handle := FCREATE(self:xmlPath + cArquivo)
    local uploadDate := StoD(StrTran(message:getValue("uploadDate"),"-",""))
    local success := .T.

    if handle > 0
        
        if FWrite(handle, xmlContent) > 0
            FClose(handle)
            // Cria o registro na BXX para ser processado posteriormente pelo robo XmlRoute
            result := PLSINALUP(  'PLS_HAT', healthProviderId,;
                                .T., .T., self:xmlPath + cArquivo, nil,;
                                sourceProtocol,,uploadDate)

            if !empty(result) .and. !("SUCESSO" $ upper(result))
                success := .F.
                self:logMsg("Nao foi possivel gerar a BXX")
                result := "Nao foi possivel gravar o protocolo na Operadora: " + result
            endif
        else
            success := .F.
            self:logMsg("Nao escrever o conteudo no XML")
            result := "Nao foi possivel gravar o XML " + fileName + " no servidor"
            FClose(handle)
        endif

    else
        success := .F.
        result := "Nao foi possivel gravar o XML " + fileName + " no servidor"
        self:logMsg("Nao foi possivel gravar o XML no servidor")
    endif
    
    
    
return success

/*/{Protheus.doc} updateHatBatch
@author  victor.silva
@version P12
@since   20210813
/*/
method updateHatBatch(message, status, trackingStatus, hasError, rejectionDescription) class PHatXMLServ
    local result := JsonObject():new()
    Local lRet := .F.

    default rejectionDescription := ""

    result['codeSusep'] := self:codeSusep
    result['protocol'] := message:getValue("protocol")
    result['batchNumber'] := message:getValue("sourceProtocol")
    result['healthProviderId'] := message:getValue("healthProviderId")
    result['status'] := status
    result["trackingStatus"] := trackingStatus
    result['rejectionCauses'] := {}
    if hasError
        aadd(result['rejectionCauses'], JsonObject():new())
        result['rejectionCauses'][1]['code'] := "5012"
        result['rejectionCauses'][1]['description'] := "Recebimento de mensagem n�o finalizado. Entre em contato com a Operadora"
        result['rejectionCauses'][1]['detailedDescription'] := rejectionDescription
    endif

    lRet := self:httpClient:put(message:getValue("sourceProtocol"), result)

return lRet

/*/{Protheus.doc} getLastItem
Pega a ultima cadeia de strings separadas pelo token informado
@author victor.silva
@since 12/06/2020
@version P12
/*/
static function getLastItem(string, token)
	local itens := {}
	local result := ""
	local lenItens := 0
	default string := ""
	default token := "/"

	itens := strTokArr2(string, token, .F.)
	lenItens := len(itens)
	result := itens[lenItens]
	freeArr(@itens)

return result

/*/{Protheus.doc} RetDefaultSusep
Pega o codigo susep da operadora padrao
@author victor.silva
@since 12/06/2020
@version P12
/*/
static function RetDefaultSusep()
    local codeSusep := ""
    BA0->(dbSetOrder(1))
    if BA0->(MsSeek(xfilial("BA0") + PlsIntPad()))
        codeSusep := BA0->BA0_SUSEP
    endif
return codeSusep

/*/{Protheus.doc} freeArr
Limpa array
@author PLS TEAM
@since 12/06/2020
@version P12
/*/
static function freeArr(aArray)
	aSize(aArray,0)
	aArray := Nil
	aArray := {}
return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSReComHAT
Verifica a situa��o de registros com erro de comunica��o, tenta comunicar novamente com o HAT e atualiza B1R
@author Oscar Zanin
@since 28/01/2022
@version P12
/*/
//-------------------------------------------------------------------
static function PLSReComHAT()

Local cSql := ""
Local cProtHAT := ""
Local cProtB1R := ""
Local cRDA  := ""
Local cSql2 := ""
Local cTracking := ""
Local lExclusao := .F.
Local lBXXOk    := .F.
Local ccodOpe := PlsIntPad()
Local cRegOpeANS := ""
Local cstaTISS := ""

BA0->(dbSetOrder(1))
If BA0->(MsSeek(xfilial("BA0")+cCodOpe))
    cRegOpeANS := BA0->BA0_SUSEP
endIf

cSql += " Select R_E_C_N_O_ REC From " + retSqlName("B1R") + " B1R "
cSql += " Where "
cSql += " B1R_FILIAL = '" + xFilial('B1R') + "' AND "
cSql += " B1R_STATUS IN ('" + ERROR_UPD_HAT + "', '" + ERROR_DELETE + "') AND "
cSql += " B1R.D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,csql),"B1RST5",.F.,.T.)

While !(B1RST5->(EoF()))
    B1R->(Dbgoto(B1RST5->REC))
       cProtHAT := B1R->B1R_PROTOG
       cProtB1R := B1R->B1R_PROTOC
       cRDA := B1R->B1R_ORIGEM
       lExclusao := B1R->B1R_HATTIP == TRAN_DELETE
       lPendenteDel := B1R->B1R_STATUS == ERROR_DELETE
       cstaTISS := ""

        csql2 := "SELECT R_E_C_N_O_ REC FROM " + RetSqlName("BXX") + " BXX "
        csql2 += " WHERE "
        csql2 += " BXX_FILIAL	= '" + xFilial("BXX") + "' "
        csql2 += " AND BXX_PLSHAT	= '" + Alltrim(cProtHAT) + "' "
        csql2 += " AND BXX.D_E_L_E_T_ = ' ' "

        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,csql2),"B1RBXX",.F.,.T.)
        lBXXOk    := .F.
        if !lPendenteDel
            if !lExclusao
                if !B1RBXX->(EoF())
                    BXX->(dbGoTo(B1RBXX->REC))
                    cstaTISS := STTISS_RECEBIDO
                    cTracking := PROCESSED
                    lBXXOk    := .T.
                else
                    cstaTISS := STTISS_ENC_SEM_PAG
                    cTracking := ERROR_GEN_BXX
                endif
            else
                if B1RBXX->(EoF())
                    cTracking := PROCESSED
                else
                    cTracking := ERROR_DELETE
                endif
            endif

            if !lExclusao
                if MontRetHAT(cTracking, cProtB1R, AllTrim(cProtHAT), cRDA, cRegOpeANS, cstaTISS,.F.)
                    //se comunicou, atualiza o B1R, se falhou, da� melhor sorte na pr�xima vez que passar aqui
                    B1R->(RecLock("B1R", .F.))
                        B1R->B1R_STATUS := cTracking
                        if B1R->B1R_QTDTRY < 99
                            B1R->B1R_QTDTRY := B1R->B1R_QTDTRY + 1
                        endif
                    B1R->(MsUnlock())
                else
                    B1R->(RecLock("B1R", .F.))
                        if B1R->B1R_QTDTRY < 99
                            B1R->B1R_QTDTRY := B1R->B1R_QTDTRY + 1
                        endif
                    B1R->(MsUnlock())
                endif
            else
                //exclus�o n�o manda nada de volta no processo normal, ent�o sempre atualiza
                B1R->(RecLock("B1R", .F.))
                    B1R->B1R_STATUS := cTracking
                    if B1R->B1R_QTDTRY < 99
                        B1R->B1R_QTDTRY := B1R->B1R_QTDTRY + 1
                    endif
                B1R->(MsUnlock())
            endif
        else
            if !MontRetHAT(,,AllTrim(cProtHAT),cRDA,cRegOpeANS,,.T.)
                B1R->(RecLock("B1R", .F.))
                if B1R->B1R_QTDTRY < 99
                    B1R->B1R_QTDTRY := B1R->B1R_QTDTRY + 1
                else
                    B1R->B1R_STATUS := DELETE_ERROR
                endif
                B1R->(MsUnlock())
            else
                B1R->(RecLock("B1R", .F.))
                B1R->B1R_STATUS := PROCESSED
                B1R->(dbDelete())
                B1R->(MsUnlock())
            endif
        endif
        B1RBXX->(dbclosearea())

    B1RST5->(DbSkip())
enddo
B1RST5->(dbclosearea())
return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSReProB1R
Retorna registros com erro para serem processados de novo e incrementa o contador de tentativas
@author Oscar Zanin
@since 28/01/2022
@version P12
/*/
//-------------------------------------------------------------------
static function PLSReProB1R()

Local cSql := ""
Local lRet := .F.

cSql += " Update " + retSqlName("B1R")
cSql += " Set "
cSql += " B1R_STATUS = '0', "
cSql += " B1R_PROCES = ' ', "
cSql += " B1R_ROBOID = ' ', "
cSql += " B1R_QTDTRY = B1R_QTDTRY + 1 "
cSql += " Where "
cSql += " B1R_FILIAL = '" + xFilial('B1R') + "' AND "
cSql += " B1R_STATUS IN ('" + ERROR_GEN_BXX + "', '" + ERROR_DOWN_XML + "') AND "
cSql += " B1R_QTDTRY < 10 AND "
cSql += " D_E_L_E_T_ = ' ' "

lRet := PLSCOMMIT(cSql)

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MontRetHAT
Monta e gera o retorno da submiss�o para arquivos que chegam pela integra��o com o HAT
@author Oscar Zanin
@since 28/01/2022
@version P12
/*/
//-------------------------------------------------------------------
Static function MontRetHAT(cTracking, cProtB1R, cProtHAT, cRDA, cRegOpeANS, cstaTISS, lExclusao)
	Local oRetJson      := JsonObject():new()
	Local cJson	        := ""
	Local cMV_PHATURL   := getnewPar('MV_PHATURL', '' )
	Local cUrlPUT       := cMV_PHATURL + 'v1/batchesAuthorization/'
	Local cParamPut     := ''
	Local oRest	        := nil
	Local aHeader       := {}
	Local cMV_PHATTOK	:= getNewPar('MV_PHATTOK', '')
	Local cMV_PHATIDT	:= alltrim(getNewPar('MV_PHATIDT', '1'))//Id Tenant
	Local cMV_PHATNMT	:= alltrim(getNewPar('MV_PHATNMT', 'tenant'))//Nome Tenant
	Local lRet          := .T.

    oRest := FWRest():New(cUrlPUT + cProtHAT)
    
    aadd(aHeader, 'Authorization: ' + cMV_PHATTOK)
	aadd(aHeader, 'idTenant: '  + cMV_PHATIDT)
	aadd(aHeader, 'tenantname: ' + cMV_PHATNMT)
    
    if lExclusao

        cParamPut := '?healthProviderId=' + cRDA + '&codeSusep=' +  cRegOpeANS + '&force=true'

	    oRest:setPath(cParamPut)

        oRest:delete(aHeader)

        if !Empty(oRest:cResult)
        	lRet := .F.
        	logPlsToHat("Erro ao excluir lote: " + cProtHAT + CRLF + "Mensagem de erro: " + oRest:cResult)
        endif
    else

        cParamPut := '?codeSusep=' +  cRegOpeANS

        oretJson['codeSusep'] := cRegOpeANS
        // N�o atualizamos o status TISS pq vai ser atualizado nos outros pontos, mudar aqui poderia fazer ir pra um que j� passou
        // oretJson['status'] := cstaTISS 
        oretJson['protocol'] := cProtB1R
        oretJson['batchNumber'] := cProtHAT
        oretJson['healthProviderId'] := cRDA
        oretJson['trackingStatus'] := cTracking
        
        cJson := FWJsonSerialize(oRetJson, .F., .F.)
        
	    oRest:setPath(cParamPut)

	    lRet := oRest:Put(aHeader, cJson)

    endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} logPlsToHat
Gera log da integracao PLS > HAT

@author  Renan Sakai
@version P12
@since    26.10.18
/*/
//-------------------------------------------------------------------
static function logPlsToHat(cMsg)

	Local lLogPlsHat := GetNewPar("MV_PHATLOG","0") == "1"
	Default cMsg    := ""
	
	if lLogPlsHat
        PlsPtuLog(cMsg, ;
                  "plsxmldownload.log")
    endIf

Return
