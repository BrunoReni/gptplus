#Include "GTPIRJ115.ch"
#Include "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ115

Adapter REST da rotina de BILHETE 

@type 		function
@sample 	GTPIRJ115()
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@param 	 	aParams, logical - informações pertinentes ao processo para filtro (.T.) ou não (.F.)
@param 	 	lMonit, logical - indica se a chamada foi realizada através de monitor (.T.) ou não (.F.)
@param 	 	lAuto, logical - indica se a chamada foi realizada através de automação (.T.) ou não (.F.)
@param 	 	cResultAuto, char - Vindo de script de automação
@param 	 	cXmlAuto, char - Vindo de script de automação
@return		lRet, Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	henrique.toyada
@since 		31/07/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ115(lJob,aParams,lMonit,lAuto,cResultAuto,cXmlAuto)

	Local aArea  := GetArea() 
	Local lRet   := .T.
	Local cEmpRJ  := nil
	Local dDtIni  := nil
	Local cHrIni  := nil
	Local dDtFim  := nil
	Local cHrFim  := nil
	Local cAgeIni := nil
	Local cAgeFim := nil

	Default lJob 	:= .F. 
	Default aParams	:= {}
	Default lAuto := .F.
	Default cResultAuto := ''
	Default cXmlAuto    := ''
	
	If ( Len(aParams) == 0 )
	
		If ( Pergunte('GTPIRJ115',!lJob) )

			cEmpRJ  := MV_PAR01
			dDtIni  := MV_PAR02
			cHrIni  := MV_PAR03
			dDtFim  := MV_PAR04
			cHrFim  := MV_PAR05
			cAgeIni := AllTrim(MV_PAR06)
			cAgeFim := AllTrim(MV_PAR07)
		Else
			lRet := .F.
		EndIf

	Else

		cEmpRJ  := aParams[1]
		dDtIni  := aParams[2]
		cHrIni  := aParams[3]
		dDtFim  := aParams[4]
		cHrFim  := aParams[5]
		cAgeIni := aParams[6]
		cAgeFim := aParams[7]

	EndIf

	If ( lRet )
		FwMsgRun( , {|oSelf| lRet := GI115Receb(lJob, oSelf, cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim, cAgeIni, cAgeFim,@lMonit, lAuto,cResultAuto,cXmlAuto)}, , STR0001) //"Processando registros de Bilhetes... Aguarde!"
	EndIF

	RestArea(aArea)
	GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI115Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI115Receb(cRestResult, oMessage)
@param 		oRJIntegra, objeto - classe que trata da integração
			oMessage, objeto   - trata a mensagem apresentada em tela
@return 	lRet, logical      - resultado do processamento da rotina (.T. / .F.)
@author 	henrique.toyada
@since 		29/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI115Receb(lJob, oMessage, cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim, cAgeIni, cAgeFim, lMonit, lAuto, cResultAuto, cXmlAuto)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPA115")
Local oMdlGIC	  := Nil
Local oMdlGZP     := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"GIC_FILIAL", "GIC_CODIGO"}
Local cIntID	  := ""
Local cIntAux	  := ""
Local cExtID	  := ""
Local cCode		  := ""
Local cErro		  := ""
Local cTagName    := ""
Local cCampo      := ""
Local cTipoCpo    := ""
Local xValor      := ""
Local cFormPag    := ""
Local nX          := 0
Local nY          := 0
Local nOpc		  := 0
Local nPos        := 0
Local nTotReg     := 0
Local lOk		  := .F.
Local lRet        := .T.
Local lContinua   := .T.
Local lOnlyInsert := .F.
Local lOverWrite  := .F.
Local lMessage	  := ValType(oMessage) == 'O'

Default cEmpRJ      := oRJIntegra:GetEmpRJ(cEmpAnt, cFilAnt)
Default dDtIni      := dDataBase-1
Default cHrIni      := '0000'
Default dDtFim      := dDataBase-1
Default cHrFim      := '2359'
Default cAgeIni     := ''
Default cAgeFim     := ''
Default cResultAuto := ''
Default cXmlAuto    := ''

oRJIntegra:SetPath("/bilhete/venda2")
oRJIntegra:SetServico('Bilhete')

oRJIntegra:SetParam('empresa'		 , ALLTRIM(cEmpRJ))
oRJIntegra:SetParam('dataHoraInicial', SubStr(DtoS(dDtIni), 3,8) + STRTRAN(cHrIni,":",""))
oRJIntegra:SetParam('dataHoraFinal'	 , SubStr(DtoS(dDtFim), 3,8) + STRTRAN(cHrFim,":",""))

If !Empty(cAgeIni)
	oRJIntegra:SetParam('agenciaInicio', AllTrim(cAgeIni))
Endif
If !Empty(cAgeFim)
	oRJIntegra:SetParam('agenciaFim', AllTrim(cAgeFim))
Endif

If !lAuto
	oRJIntegra:SetServico("Bilhete")
Else
	oRJIntegra:SetServico("Bilhete",,,cXmlAuto)
EndIf

aFldDePara	:= oRJIntegra:GetFieldDePara()
aDeParaXXF  := oRJIntegra:GetFldXXF()

//DSERGTP-6567: Novo Log Rest RJ
oRJIntegra:oGTPLog:SetNewLog(,,oRJIntegra:GetUrl(),"GTPIRJ115")

If oRJIntegra:Get(cResultAuto)

	GIC->(DbSetOrder(1))	// GIC_FILIAL+GIC_CODIGO
	nTotReg := oRJIntegra:GetLenItens()
	
	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

	If ( nTotReg >= 0 )

		//nTotReg := IIf(nTotReg > 99, 99, nTotReg)	//TODO: Arrancar esta linha daqui
		
		For nX := 0 To nTotReg

			lContinua := .T.
		
			If lMessage .And. !lJob
				oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))  //"Processando registros de Bilhetes - #1/#2... Aguarde!"
				ProcessMessages()
			EndIf
			
			If !Empty(cExtID	:= oRJIntegra:GetJsonValue(nX, 'idTransacao', 'C'))
				cCode := GTPxRetId("TotalBus", "GIC", "GIC_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
				If Empty(cIntID) 
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lOk .And. GIC->(DbSeek(xFilial('GIC') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					oRJIntegra:oGTPLog:SetText(cErro)
				EndIf
				
				If lContinua
					
					oModel:SetOperation(nOpc)
					If oModel:Activate()
						oMdlGIC := oModel:GetModel("GICMASTER")
						oMdlGZP	:= oModel:GetModel("GZPPAGTO")

						For nY := 1 To Len(aFldDePara)
							// recuperando a TAG e o respectivo campo da tabela 
							cTagName    := aFldDePara[nY][1] 
							cCampo      := aFldDePara[nY][2]
							cTipoCpo    := aFldDePara[nY][3]
							lOnlyInsert := aFldDePara[nY][6]
							lOverWrite  := aFldDePara[nY][7]
							cFormPag := oRJIntegra:GetJsonValue(nX, "formaPagamento1", "C")
							// recuperando através da TAG o valor a ser inserido no campo 
							If !Empty(cTagName) .And. !Empty((xValor := oRJIntegra:GetJsonValue(nX, cTagName, cTipoCpo)))
									
								If cTagName == "dataHoraVendaT" .and. cCampo = "GIC_HRVEND"
									xValor := substr(xValor,12,5)
								ElseIf cTagName == "dataHoraViagemT"  .and. cCampo = "GIC_HORA"
									xValor := STRTRAN(substr(xValor,12,5),":","")
								ElseIf cTagName == "sentido"  .and. cCampo = "GIC_SENTID"
									xValor := IIF(xValor == "V",'1','2')
								ENDIF
								// verificando a necessidade de realizar o DePara XXF
								If (nPos := aScan(aDeParaXXF, {|x| x[1] == cCampo})) > 0
									xValor := GTPxRetId("TotalBus", aDeParaXXF[nPos, 2], aDeParaXXF[nPos, 3], xValor, @cIntAux, aDeParaXXF[nPos, 4], @lOk, @cErro, aDeParaXXF[nPos, 6], aDeParaXXF[nPos, 5])
								EndIf
								If !(cCampo $ 'GZP_DCART|GZP_ITEM|GZP_TPAGTO|GZP_VALOR|GZP_QNTPAR|GZP_NSU|GZP_AUT')	
									If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGIC:GetValue(cCampo)) 
										lContinua := oRJIntegra:SetValue(oMdlGIC, cCampo, xValor)
									ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
										lContinua := oRJIntegra:SetValue(oMdlGIC, cCampo, xValor)
									EndIf
								Else
									If cFormPag $ 'CR|DE|CD|VT' 
										If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGZP:GetValue(cCampo)) 
											lContinua := oRJIntegra:SetValue(oMdlGZP, cCampo, xValor)
										ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
											lContinua := oRJIntegra:SetValue(oMdlGZP, cCampo, xValor)
										EndIf
										If lContinua
											lContinua := oRJIntegra:SetValue(oMdlGZP, "GZP_BILREF", oMdlGIC:GetValue("GIC_BILHET"))
											lContinua := oRJIntegra:SetValue(oMdlGZP, "GZP_STAPRO", "0")
											lContinua := oRJIntegra:SetValue(oMdlGZP, "GZP_ITEM", "001")
											lContinua := oRJIntegra:SetValue(oMdlGZP, "GZP_DTVEND", oMdlGIC:GetValue("GIC_DTVEND"))
										EndIf
									EndIf
								EndIf

								If !lContinua 
									oRJIntegra:oGTPLog:SetText(I18N(STR0003 , {cCampo, GTPXErro(oModel)})) //"Falha ao gravar o valor do campo #1 (#2)."										
								EndIf
							EndIf
						Next nY
						
						If lContinua
							lContinua := oRJIntegra:SetValue(oMdlGIC, "GIC_INTEGR", '1', .T.)						
						EndIf
						
						If lContinua
							lContinua := oRJIntegra:SetValue(oMdlGIC, "GIC_TIPO", 'I', .T.)
						EndIf
						
						If lContinua 
							If (lContinua := oModel:VldData() )
								oModel:CommitData()
								CFGA070MNT("TotalBus", "GIC", "GIC_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGIC:GetValue('GIC_CODIGO'), 'GIC')))
							Else
								oRJIntegra:oGTPLog:SetText(I18N(STR0005, {GTPXErro(oModel)})) //"Falha ao carregar modelos de dados (#1)."
							EndIf
						Else
							oRJIntegra:oGTPLog:SetText(I18N(STR0005, {GTPXErro(oModel)})) //"Falha ao carregar modelos de dados (#1)."
						EndIf
						oModel:DeActivate()
					Else
						oRJIntegra:oGTPLog:SetText(I18N(STR0005, {GTPXErro(oModel)})) //"Falha ao carregar modelos de dados (#1)."
						//DSERGTP-6567: Novo Log Rest RJ
						RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText())
					EndIf
				EndIf
			EndIf

			//DSERGTP-6567: Novo Log Rest RJ
			If ( !lContinua )
				
				RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText())
				
				oRJIntegra:oGTPLog:ResetText()

			EndIf
		Next nX

	Else
		lMonit := .F.	//Precisará efetuar o disarmTransaction
		FwAlertHelp("Não há dados a serem processados com a parametrização utilizada.")
	EndIf

Else
	oRJIntegra:oGTPLog:SetText(I18N("Falha ao processar o retorno do serviço #2 (#1).", {oRJIntegra:GetLastError(),oRJIntegra:cUrl}))
	//DSERGTP-6567: Novo Log Rest RJ
	RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText()/*,oRJIntegra:GetResult("")*/)
EndIf

If !lJob .And. oRJIntegra:oGTPLog:HasInfo() 
	oRJIntegra:oGTPLog:ShowLog()
	lRet := .F.
ElseIf !lJob .And. !oRJIntegra:oGTPLog:HasInfo()
	If lMessage 
		oMessage:SetText(STR0007) //"Processo finalizado."
		ProcessMessages()
	Else
		Alert(STR0007) //"Processo finalizado."
	EndIf	
EndIf

oRJIntegra:Destroy()
GTPDestroy(oModel)
GTPDestroy(oMdlGIC)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI115Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI115Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	henrique.toyada
@since 		28/03/2019
@version 	1.0
/*/
//GI115Job('10','20200326','0000','20200326','2359','000000','999999')
//------------------------------------------------------------------------------------------
Function GI115Job(aParam, lAuto)
Local nPosEmp := 0
Local nPosFil := 0

Default lAuto := .F.

nPosEmp := IF(Len(aParam) == 11, 8, IF(Len(aParam) == 9, 6, 1))
nPosFil := IF(Len(aParam) == 11, 9, IF(Len(aParam) == 9, 7, 2))
//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[nPosEmp],aParam[nPosFil])
If Len(aParam) == 11
	GI115Receb(.F., Nil, aParam[1], STOD(aParam[2]), aParam[3], STOD(aParam[4]), aParam[5], aParam[6], aParam[7],,lAuto)
ElseIf Len(aParam) == 9
	GI115Receb(.F., Nil, aParam[1], STOD(aParam[2]), aParam[3], STOD(aParam[4]), aParam[5],,,,lAuto)
Else
	GTPIRJ115(.F.,,,lAuto)
EndIf

RpcClearEnv()

Return
