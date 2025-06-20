#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "Fileio.ch"

Static __cEvtTot		:= GetTotalizerEventCode("evtTot")
Static __cEvtTotContrib	:= GetTotalizerEventCode("evtTotContrib")

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WSTAF050
WS para download de XMLs na tabela SPED500 TSS.

@author Rafael de Paula Leme
@since 20/06/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSRESTFUL ExportXML DESCRIPTION "API Reinf - Retorna o caminho do arquivo zip com os XMLs dos eventos totalizadores (R-9001 e R-9011)"

	WSDATA companyId	AS STRING
	WSDATA period		AS STRING
	WSDATA event		AS STRING

	WSMETHOD POST exportXML;
		DESCRIPTION "Retorna o caminho do arquivo zip com os XMLs dos eventos totalizadores";
        WSSYNTAX "/api/taf/reinf/v1/exportXML/?{companyId}&{period}&{event}";
        PATH "/api/taf/reinf/v1/exportXML/";
        TTALK "v1";
		PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo POST
M�todo respons�vel pelas chamadas da fun��o de verifica��o do status do TSS e Gera��o dos XMLs conforme
os par�metros recebidos.

@author Rafael Leme
@since 17/06/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD POST exportXML QUERYPARAM companyId, period, event WSRESTFUL ExportXML

	Local aFilToReinf	as array
	Local aCompany		as array
	Local cMessage      as character
	Local cEmpRequest	as character
	Local cFilRequest	as character
	Local cDirOri       as character
	Local lRet			as logical
	Local oEstruct		as object
	Local cCode			as character
	Local cUser			as character
	Local cModule		as character
	Local cRoutine		as character

	aFilToReinf	:= {}
	aCompany	:= {}
	cEmpRequest	:= ""
	cFilRequest	:= ""
	cMessage    := ""
	cDirOri     := DirXmlOri()
	lRet		:= .T.
	oEstruct	:= JsonObject():New()
	cCode		:= "LS006"
	cUser		:= RetCodUsr()
	cModule		:= "84"
	cRoutine 	:= "TAFReinf"+StrTran(self:event,"-", "")+"RelXML"

	self:SetContentType("application/json")

	If self:companyId == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial n�o informado no par�metro 'companyId'." ) )
	ElseIf self:period == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Per�odo n�o informado no par�metro 'period'." ) )
	ElseIf self:event == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Evento n�o informado no par�metro 'event'." ) )
	ElseIf !(self:event $ (__cEvtTot + "|" + __cEvtTotContrib + "|"+'R-9005'+"|"+'R-9015'))
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "O evento informado no par�metro 'event' n�o � v�lido." ) )
	Else
		aCompany := StrTokArr( self:companyId, "|" )
		If Len( aCompany ) < 2
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial n�o informado no par�metro 'companyId'." ) )
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := aCompany[2]

			If PrepEnv( cEmpRequest, cFilRequest )
				aFilToReinf := { { .T., "", cFilAnt, cEmpAnt + cFilAnt, "", "", "", .T., .T. } }

				If FindFunction( "FWLSPutAsyncInfo" )
					FWLSPutAsyncInfo( cCode, cUser, cModule, cRoutine )
					TAFConOut( "-> " +cRoutine,1,.F.,"LSTAF")								
				EndIf 
				
					oEstruct["exportXML"] := {}
					oEstruct["event"]         := self:event
					oEstruct["totalEvent"]    := 0
					oEstruct["homeDirectory"] := cDirOri
					oEstruct["sucess"]        := .F.
					oEstruct["message"]       := cMessage
				
				If !TAFCTSpd(TSICheckURLTss())
					cMessage := EncodeUTF8( "N�o foi poss�vel se comunicar com o TSS." )
					oEstruct["message"] := cMessage
					self:SetResponse( FWJsonSerialize( oEstruct, .T., .T.,, .F. ) )
				Else
					If TafXmlDir(cDirOri,@oEstruct['message'])
						TafXmlTot(aFilToReinf, @oEstruct, self:period, self:event)
					Endif
					self:SetResponse( FWJsonSerialize( oEstruct, .T., .T.,, .F. ) )
				EndIf
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Falha na prepara��o do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
			EndIf
		EndIf
	EndIf

	FreeObj( oEstruct )
	oEstruct := Nil
	DelClassIntF()

Return( lRet )

/*/{Protheus.doc} TafXmlTot
Fun��o de consulta as tabelas espelhos dos eventos totalizadores e chamada para gera��o e compress�o (.zip) dos XMLS.
@type  Static Function
@author Rafael Leme
@since 17/06/2022
@version version
@param
	oEstruct  - Json de retorno.
	cPeriod   - Periodo enviado pelo painel Reinf.
	cEvent    - Evento totalizador selecionado no painel Reinf (R-9001 ou R-9011).
@return 
@see (links_or_references)
/*/
Static Function TafXmlTot(aFilToReinf, oEstruct, cPeriod, cEvent)

	Local nTamTot    as numeric
	Local nTotal     as numeric
	Local nTamEvt    as numeric
	Local nTotEvtQry as numeric
	Local nTotEsp    as numeric
	Local nRetZip    as numeric
	Local nTotalDel  as numeric
	Local nItem      as numeric
	Local cDirOri    as character
	Local cAliasTot  as character
	Local cEvento    as character
	Local cIdEvt     as character
	Local cArqZip    as character
	Local cMessage   as character
	Local lRetXml    as logical
	Local lSucess    as logical
	Local aEvento    as array
	Local aRecEve    as array
	Local aRecDel    as array
	Local aRetTss    as array
	Local aRetDel    as array
	Local aRetXml    as array
	Local aEvtDel    as array

	Default aFilToReinf := {}
	DeFault cPeriod     := ''
	Default cEvent      := ''

	nTamTot    := 0
	nTotal     := 0
	nTamEvt    := 0
	nTotEvtQry := 0
	nTotEsp    := 0
	nRetZip    := 0
	nTotalDel  := 0
	nItem      := 0
	cDirOri    := DirXmlOri()
	cAliasTot  := ''
	cEvento    := ''
	cIdEvt     := ''
	cArqZip    := ''
	cMessage   := ''
	lRetXml    := .T.
	lSucess    := .T.
	aEvento    := {}
	aRecEve    := {}
	aRetTss    := {}
	aRetDel    := {}
	RetXml     := {}
	aEvtDel    := TAFRotinas( 'R-9000', 4, .F., 5 )

	dbSelectArea('T9D')
	T9D->(dbSetOrder(2))

	If cEvent == __cEvtTot
		cAliasTot := QRY5001(cPeriod)
	ElseIf cEvent == __cEvtTotContrib
		cAliasTot := QRY5011(cPeriod)
	ElseIf cEvent $ 'R-9005|R-9015'
		cAliasTot := QRY90XX(cPeriod,cEvent)
	Endif

	// Invers�o das barras do diret�rio de origem caso o SO seja linux.
	If 'Linux' $ GetSrvInfo()[2];cDirOri := StrTran(cDirOri,'\','/');EndIf

	oEstruct["event"]         := cEvent
    oEstruct["totalEvent"]    := 0
	oEstruct["homeDirectory"] := cDirOri
	oEstruct["sucess"]        := .F.
	oEstruct["message"]       := cMessage

	Do While (cAliasTot)->(!Eof())
        
        cEvento    := Alltrim((cAliasTot)->EVENTO)
		aEvento    := TAFRotinas( 'R-' + (cAliasTot)->EVENTO, 4, .F., 5 )
		cIdEvt     := Posicione('T9B',2,xFilial('T9B')+'R-' + (cAliasTot)->EVENTO,'T9B_ID')
		cArqZip    := ''
		nTotEsp    := 0
		nTotEvtQry := 0
		nTotalDel  := 0
		aRecEve    := {}
		aRetTss    := {}
		aRetDel    := {}
		aRetXml    := {}
		aRecDel    := {}

		aadd(oEstruct["exportXML"],JsonObject():New())
		
		nTamEvt := Len(oEstruct["exportXML"]) 
		
		// Evento sendo processado.
		oEstruct["exportXML"][nTamEvt]["event"]      := 'R-' + Alltrim((cAliasTot)->EVENTO)
		// Total de registros encontrados na tabela espelho do evento processado.
		oEstruct["exportXML"][nTamEvt]["totalFound"] := 0
		// Total de registros encontrados na tabela SPED500 para o evento processado.
		oEstruct["exportXML"][nTamEvt]["totalTss"]   := 0
		// Status da cria��o do XMLs.
		oEstruct["exportXML"][nTamEvt]["createXml"]  := .F.
		// Status da cria��o do ZIP.
		oEstruct["exportXML"][nTamEvt]["createZip"]  := .F.
		// Caminho e nome do arquivo ZIP gerado.
		oEstruct["exportXML"][nTamEvt]["zipFile"]    := ''

		dbSelectArea(aEvento[3])
	    (aEvento[3])->(dbSetOrder(aEvento[13]))
        
		Do While (cAliasTot)->(!Eof()) .AND. cEvento == Alltrim((cAliasTot)->EVENTO)
			nTotal++
			nTotEvtQry++

			// Busca na tabela espelho do evento processado.
			If (aEvento[3])->(dbSeek(xFilial(aEvento[3]) + PadR((cAliasTot)->PROTOCOLO,TamSX3(aEvento[3] + '_PROTUL')[1]) + '1'))
				nTotEsp++
            	AADD(aRecEve,(aEvento[3])->(RECNO()))
				//Total de registros encontrados na tabela espelho do evento processado
				oEstruct["exportXML"][nTamEvt]["totalFound"] := nTotEsp
			Else
				// Caso n�o seja encontrado na tabela espelho do evento processado, verifico se existe na tabela espelho do evento R-9000
				If T9D->(dbSeek(xFilial('T9D') + PadR(Alltrim(cIdEvt),TamSX3('T9D_IDTPEV')[1]) + PadR((cAliasTot)->PROTOCOLO,TamSX3('T9D_NRRECI')[1]) + '1'))
					AADD(aRecDel,('T9D')->(RECNO()))
					nTotalDel++
				EndIf
			Endif
         
            (cAliasTot)->(DbSkip())
        EndDo

		// Total de registros encontrados na tabela espelho do evento totalizador.
		oEstruct["totalEvent"]                        := nTotal
		// Total de registros por evento encontrado na tabela espelho do evento totalizador.
		oEstruct["exportXML"][nTamEvt]["totalQuery"]  := nTotEvtQry
		// Total de registros encontrados na tabela espelho do evento R-9000.
		oEstruct["exportXML"][nTamEvt]["totalDelete"] := nTotalDel

		(aEvento[3])->(DbCloseArea())

		If Len(aRecEve) > 0
			// Retorno dos XMLs encontrados na SPED500 para o evento processado.
			aRetTss := TAFProc10TSS( .F., aEvento, , , , , , , , , , , aRecEve, , .F. )
			lRetXml := TafGerXml(aRetTss,  @aRetXml, cDirOri)
		Endif

		If Len(aRecDel) > 0
			// Retorno dos XMLs encontrados na SPED500 para o evento R-9000.
			aRetDel := TAFProc10TSS( .F., aEvtDel, , , , , , , , , , , aRecDel, , .F. )
			lRetXml := TafGerXml(aRetDel, @aRetXml, cDirOri,"_R9000")
		Endif

		// Total de registros encontrados na tabela SPED500 TSS
		oEstruct["exportXML"][nTamEvt]["totalTss"]  := Len(aRetXml)
		// Status da cria��o dos XMLs
		oEstruct["exportXML"][nTamEvt]["createXml"] := lRetXml

		If Len(aRetXml) > 0 .And. lRetXml
			cArqZip := cDirOri + "XML" + Alltrim(StrTran( cEvent, "-", "" )) + "R" + cEvento + "P" + cPeriod + ".zip"
			nRetZip := TafZipXml(cArqZip, aRetXml, cDirOri)	
		Endif

		// Status da cria��o do arquivo ZIP.
		oEstruct["exportXML"][nTamEvt]["createZip"] := Iif(nRetZip == 0, .T., .F.)
		// Caminho e nome do arquivo ZIP gerado.
		oEstruct["exportXML"][nTamEvt]["zipFile"]   := cArqZip
    EndDo

	T9D->(DbCloseArea())
    (cAliasTot)->(DbCloseArea())

	lSucess := .F.
	
	If nTotal == 0
		cMessage := EncodeUTF8('N�o foram encontrados eventos ' + cEvent + ' para o periodo informado.')
	Else
		//Tratamento para ver se tem erro na cria��o dos XMLs ou ZIP.
		for nItem := 1 to len(oEstruct["exportXML"])
			if  oEstruct["exportXML"][nItem]['createXml'] .And. oEstruct["exportXML"][nItem]['createZip']
				lSucess := .T.
			Else
				If oEstruct["exportXML"][nItem]['createXml'] == .F.
					cMessage += EncodeUTF8('Erro ao criar XML para o evento ' + oEstruct["exportXML"][nItem]['event'] + CHR(13)+CHR(10))
				Endif
				If oEstruct["exportXML"][nItem]['createZip'] == .F.
					cMessage += EncodeUTF8('Erro ao criar Zip para o evento ' + oEstruct["exportXML"][nItem]['event'] + CHR(13)+CHR(10))
				Endif
			Endif
		next
	Endif

    // Retorno do processamento do evento totalizador e per�odo informado.
	oEstruct["sucess"]  := lSucess
	// Mensagem dos erros encontrados no processamento.
	oEstruct["message"] := cMessage

Return 

/*/{Protheus.doc} QRY5001
Fun��o de consulta a tabela V0W, espelo do evento totalizador R-9001.
@type  Static Function
@author Rafael Leme
@since 17/06/2022
@version version
@param
	cPeriod   - Periodo enviado pelo painel Reinf.
@return 
@see (links_or_references)
/*/
Static Function QRY5001(cPeriod)

	Local cAlias   as character
	Local cSelect  as character
	Local cFrom    as character
	Local cWhere   as character
	Local cOrderBy as character

	Default cPeriod := ''

	cAlias   :=  getnextalias()
	cSelect  := ""
	cFrom    := ""
	cWhere   := ""
	cOrderBy := ""

	cSelect += " V0W.V0W_FILIAL FILIAL "
	cSelect += " ,V0W.V0W_TPEVEN EVENTO "
	cSelect += " ,V0W.V0W_PERAPU PERIODO "
	cSelect += " ,V0W.V0W_PROTUL PROTOCOLO "

	cFrom += " " + RetSqlName( "V0W" ) + " V0W "

	cWhere += " V0W.V0W_FILIAL = '" + xFilial("V0W") + "' AND "
	cWhere += " V0W.V0W_PERAPU = '" + cPeriod + "' AND "
	cWhere += " V0W.V0W_ATIVO  = '1' AND "
	cWhere += " V0W.D_E_L_E_T_ = ' ' "

	cOrderBy += " EVENTO "

	cSelect     :=  "%" +   cSelect     +   "%"
    cFrom       :=  "%" +   cFrom       +   "%"
    cWhere      :=  "%" +   cWhere      +   "%"
    cOrderBy    :=  "%" +   cOrderBy    +   "%"

    BeginSql Alias cAlias
        SELECT
        %Exp:cSelect% 
        FROM 
        %Exp:cFrom%
        WHERE
        %Exp:cWhere%
        ORDER BY 
        %Exp:cOrderBy%
    EndSql


Return (cAlias)

/*/{Protheus.doc} QRY90XX
Fun��o de consulta a tabela V9D, espelo do evento totalizador R-9005.
Fun��o de consulta a tabela V9Q, espelo do evento totalizador R-9015.
@type  Static Function
@author Wesley Matos
@since 31/01/2023
@version version
@param
Period   - Periodo enviado pelo painel Reinf.
@return 
@see (links_or_references)
/*/
Static Function QRY90XX(cPeriod,cEvent)

	Local cAlias   as character
	Local cSelect  as character
	Local cFrom    as character
	Local cWhere   as character
	Local cOrderBy as character

	Default cPeriod := ''

	cAlias   :=  getnextalias()
	cSelect  := ""
	cFrom    := ""
	cWhere   := ""
	cOrderBy := ""

	If cEvent == 'R-9005'
		cSelect += " V9D.V9D_FILIAL FILIAL "
		cSelect += " ,V9D.V9D_TPEVEN EVENTO "
		cSelect += " ,V9D.V9D_PERAPU PERIODO "
		cSelect += " ,V9D.V9D_PROTUL PROTOCOLO "

		cFrom += " " + RetSqlName( "V9D" ) + " V9D "

		cWhere += " V9D.V9D_FILIAL = '" + xFilial("V9D") + "' AND "
		cWhere += " V9D.V9D_PERAPU = '" + cPeriod + "' AND "
		cWhere += " V9D.V9D_ATIVO  = '1' AND "
		cWhere += " V9D.D_E_L_E_T_ = ' ' "

		cOrderBy += " EVENTO "
	
	Else //R-9015

		cSelect += " V9F.V9F_FILIAL FILIAL "
		cSelect += " ,V9F.V9F_TPEVEN EVENTO "
		cSelect += " ,V9F.V9F_PERAPU PERIODO "
		cSelect += " ,V9F.V9F_PROTUL PROTOCOLO "

		cFrom += " " + RetSqlName( "V9F" ) + " V9F "

		cWhere += " V9F.V9F_FILIAL = '" + xFilial("V9F") + "' AND "
		cWhere += " V9F.V9F_PERAPU = '" + cPeriod + "' AND "
		cWhere += " V9F.V9F_ATIVO  = '1' AND "
		cWhere += " V9F.D_E_L_E_T_ = ' ' "

		cOrderBy += " EVENTO "


	EndIf

	cSelect     :=  "%" +   cSelect     +   "%"
	cFrom       :=  "%" +   cFrom       +   "%"
	cWhere      :=  "%" +   cWhere      +   "%"
	cOrderBy    :=  "%" +   cOrderBy    +   "%"

    BeginSql Alias cAlias
        SELECT
        %Exp:cSelect% 
        FROM 
        %Exp:cFrom%
        WHERE
        %Exp:cWhere%
        ORDER BY 
        %Exp:cOrderBy%
    EndSql

Return (cAlias)

/*/{Protheus.doc} QRY5011
Fun��o de consulta a tabela V0C, espelo do evento totalizador R-9011.
@type  Static Function
@author Rafael Leme
@since 17/06/2022
@version version
@param
	cPeriod   - Periodo enviado pelo painel Reinf.
@return 
@see (links_or_references)
/*/
Static Function QRY5011(cPeriod)

	Local cAlias   as character
	Local cSelect  as character
	Local cFrom    as character
	Local cWhere   as character
	Local cOrderBy as character

	Default cPeriod := ''

	cAlias   := getnextalias()
	cSelect  := ""
	cFrom    := ""
	cWhere   := ""
	cOrderBy := ""

	cSelect += " V0C.V0C_FILIAL FILIAL "
	cSelect += " ,V0C.V0C_TPEVT EVENTO "
	cSelect += " ,V0C.V0C_PERAPU PERIODO "
	cSelect += " ,V0C.V0C_PROTUL PROTOCOLO "

	cFrom += " " + RetSqlName( "V0C" ) + " V0C "

	cWhere += " V0C.V0C_FILIAL = '" + xFilial("V0C") + "' AND "
	cWhere += " V0C.V0C_PERAPU = '" + cPeriod + "' AND "
	cWhere += " V0C.V0C_ATIVO  = '1' AND "
	cWhere += " V0C.D_E_L_E_T_ = ' ' "

	cOrderBy += " EVENTO "

	cSelect     :=  "%" +   cSelect     +   "%"
    cFrom       :=  "%" +   cFrom       +   "%"
    cWhere      :=  "%" +   cWhere      +   "%"
    cOrderBy    :=  "%" +   cOrderBy    +   "%"

    BeginSql Alias cAlias
        SELECT
        %Exp:cSelect% 
        FROM 
        %Exp:cFrom%
        WHERE
        %Exp:cWhere%
        ORDER BY 
        %Exp:cOrderBy%
    EndSql
Return (cAlias)

/*/{Protheus.doc} TafXmlDir
Fun��o para cria��o do diretorio TAFXML na protheus_data
@type  Static Function
@author Rafael Leme
@since 17/06/2022
@version version
@param
	cDirOri - Adicionado passagem de par�metro para caso de teste.
	lRet    - Retorno da cria��o do diret�rio
@return 
@see (links_or_references)
/*/
Function TafXmlDir(cDirOri, cMessage)
	
	Local lRet as logical
	
	Default cDirOri := DirXmlOri()
	
	lRet := .T.

	// Cria o diretorio TAFXML caso n�o exista
	If !ExistDir(cDirOri)
        If MakeDir(cDirOri) <> 0
			lRet := .F.
			cMessage := EncodeUTF8( "Falha ao tentar criar o diretorio TAFXML no ROOTPATH." )
		EndIf
	Endif
Return (lRet)

/*/{Protheus.doc} TafGerXml
Fun��o para cria��o dos XMLS no diret�rio TAFXML. A cria��o � feita por evento encontrado na tabela do evento totalizador
@type  Static Function
@author Rafael Leme
@since 17/06/2022
@version version
@param
	aRetTss - XMLs encontrados do evento na SPED500. 
	aRetDel - XMLs encontrados na tabela espelho do evento R-9000 para o evento contido no array aRetTss.
	aRetXml - Retorno do caminho e nome dos XMLs gerados.
	cDirOri - Diret�rio (/TAFXML/) onde ser�o criados os XMLs.
@return 
@see (links_or_references)
/*/
Function TafGerXml(aRetTss, aRetXml, cDirOri,cSufix)

	Local cArqXml as character
	Local nX      as numeric
	Local nY      as numeric
	Local nHandle as numeric
	Local lRet    as logical

	Default aRetTss := {}
	Default cDirOri := DirXmlOri()
	Default cSufix  := ""

	cArqXml := ''
	nX      := 0
	nY      := 0
	nHandle := 0
	lRet    := .f.

	// Gera os XMLs do evento processado.
	For nX := 1 to Len(aRetTss)
		For nY := 1 to Len(aRetTss[nX])
			If aRetTss[nX][nY]:CCHAVE != ' '
				cArqXml := lower(AllTrim(aRetTss[nX][nY]:CCHAVE) +cSufix+ '.xml')
				nHandle := FCREATE(cDirOri + cArqXml)
				If nHandle != -1
					lRet    := .T.
					FWrite(nHandle, aRetTss[nX][nY]:CXMLRETEVEN)
					FClose(nHandle)
					Aadd(aRetXml, cDirOri + cArqXml)
				ElseIF !lRet
					lRet := .F.
				EndIf
			Endif
		Next
	Next


Return (lRet)

/*/{Protheus.doc} TafZipXml
Fun��o para compactar (.zip) os arquivos XMLs gerados.
@type  Static Function
@author Rafael Leme
@since 17/06/2022
@version version
@param
	cArqZip - Nome do arquivo ZIP 
	aArqZip - Caminho e nome dos XMLs que ser�o compactados.
	cDirOri - Diret�rio (/TAFXML/) onde est�o os XMLs a serem compactados.
@return 
@see (links_or_references)
/*/
Function TafZipXml(cArqZip, aArqZip, cDirOri)

	Local nX   as numeric
	Local nRet as numeric

	Default cArqzip := ''
	Default aArqZip := {}
	Default cDirOri := DirXmlOri()

    nX      := 0
	cArqZip := lower(cArqZip)
	nRet    := FZip(cArqZip, aArqZip, cDirOri)

    // Excluo os arquivos XMLs ap�s tentar gerar o ZIP para n�o ficar acumulado na protheus_data.
	For nX := 1 to Len(aArqZip)
        FErase(aArqZip[nX])
    Next

Return (nRet)

Static Function TSICheckURLTss()

	Local cCheckURL as character
	Local cUrl      as character

	cCheckURL := ''
	cUrl      := GetMv("MV_TAFSURL")

	If !("TSSWSREINF.APW" $ Upper(cUrl)) 
		cCheckURL := cUrl
		cUrl += "/TSSWSREINF.apw"
	Else
		cCheckURL := Substr(cUrl,1,Rat("/",cUrl)-1)
	EndIf

Return (cCheckURL)

Static Function DirXmlOri()

	Local cDirOri as character

	cDirOri := '\tafxml\'
	
	// Prote��o caso o server seja SO Linux
	If 'Linux' $ GetSrvInfo()[2];cDirOri := StrTran(cDirOri,'\','/');EndIf

Return (cDirOri)


