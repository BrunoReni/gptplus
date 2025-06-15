#Include "WMSMODELEVENTWMSA300.CH"
#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"


//-------------------------------------------------------------------
Static __nAcao := 0
Function WMSA300OPC(nAcao)
	If ValType(nAcao) == "N"
		__nAcao := nAcao
	EndIf
Return __nAcao

CLASS WMSModelEventWMSA300 FROM FWModelEvent
	METHOD New() CONSTRUCTOR
	METHOD Destroy()
	METHOD Activate(oModel, lCopy)
	METHOD BeforeTTS(oModel, cModelId)
	METHOD After(oModel, cModelId, cAlias, lNewRecord)
	METHOD InTTS(oModel, cModelId)
	METHOD AfterTTS(oModel, cModelId)

	METHOD ModelPreVld(oModel, cModelId)
	METHOD ModelPosVld(oModel, cModelId)
ENDCLASS

METHOD New()�CLASS WMSModelEventWMSA300
Return
�
METHOD Destroy()� Class WMSModelEventWMSA300
Return

METHOD Activate(oModel, lCopy) Class WMSModelEventWMSA300
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		// O modelo precisa sofrer altera��o
		oModel:LoadValue('DCNMASTER','DCN_STATUS','1')
		oModel:LoadValue('DCNMASTER','DCN_NUMSEQ',ProxNum())
		oModel:LoadValue('DCNMASTER','DCN_ACAO',SuperGetMV('MV_WM300EN',.F., '1'))
	ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If WMSA300OPC() == 4
			oModel:LoadValue('DCNMASTER','DCN_STATUS','2')
		ElseIf WMSA300OPC() == 5
			oModel:LoadValue('DCNMASTER','DCN_STATUS','3')
			oModel:LoadValue('DCNMASTER','DCN_DTFIM',IIf(Empty(oModel:GetValue('DCNMASTER','DCN_DTFIM')),DDataBase,oModel:GetValue('DCNMASTER','DCN_DTFIM')))
			oModel:LoadValue('DCNMASTER','DCN_HRFIM',IIf(Empty(oModel:GetValue('DCNMASTER','DCN_HRFIM')),SubStr(Time(),1,TamSX3("DCN_HRFIM")[1]),oModel:GetValue('DCNMASTER','DCN_HRFIM')))
		EndIf
	EndIf
Return
//-------------------------------------------------------------------
// M�todo que � chamado pelo MVC quando ocorrer as a��es do commit antes da transa��o.
//-------------------------------------------------------------------
METHOD BeforeTTS(oModel, cModelId) CLASS WMSModelEventWMSA300
Return

//-------------------------------------------------------------------
// M�todo que � chamado pelo MVC quando ocorrer as a��es do commit
// depois da grava��o de cada submodelo (field ou cada linha de uma grid)
//-------------------------------------------------------------------
METHOD After(oModel, cModelId, cAlias, lNewRecord) CLASS WMSModelEventWMSA300
Local lRet      := .T.
Return lRet

//-------------------------------------------------------------------
// M�todo que � chamado pelo MVC quando ocorrer as a��es do commit
// Ap�s as grava��es por�m antes do final da transa��o
//-------------------------------------------------------------------
METHOD InTTS(oModel, cModelId) CLASS WMSModelEventWMSA300
Local lRet      := .T.
Local cFunExe   := ""
Local cQuery    := ""
Local cAliasQry := Nil
Local oEstEnder := Nil
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If oModel:GetValue('DCNMASTER','DCN_STATUS') == '3'
			// Efetua a execu��o da fun��o
			DCM->(dbSetOrder(1))
			If DCM->(dbSeek(xFilial('DCM')+oModel:GetValue('DCNMASTER','DCN_OCORR'), .F.)) .And. !Empty(cFunExe:=AllTrim(DCM->DCM_FUNEXE))
				cFunExe  += If(!('('$cFunExe),'()','')
				cFunExe  := StrTran(cFunExe,'"',"'")
				lRet := &(cFunExe)
				lRet := If(!(lRet==NIL).And.ValType(lRet)=='L', lRet, .T.)
			EndIf
			// Atualiza o status do endere�o se n�o houverem ocorrencias em aberto
			If lRet
				cQuery := " SELECT 1"
				cQuery +=   " FROM "+RetSqlName("DCN")+" DCN"
				cQuery +=  " WHERE DCN.DCN_FILIAL = '"+xFilial("DCN")+"'"
				cQuery +=    " AND DCN.DCN_STATUS <> '3'"
				cQuery +=    " AND DCN.DCN_NUMSEQ <> '"+oModel:GetValue('DCNMASTER','DCN_NUMSEQ')+"'"
				cQuery +=    " AND DCN.DCN_LOCAL = '"+oModel:GetValue('DCNMASTER','DCN_LOCAL')+"'"
				cQuery +=    " AND DCN.DCN_ENDER = '"+oModel:GetValue('DCNMASTER','DCN_ENDER')+"'"
				cQuery +=    " AND DCN.D_E_L_E_T_ = ' '" 
				cQuery := ChangeQuery(cQuery)
				cAliasQry := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
				If (cAliasQry)->(Eof())
					oEstEnder := WMSDTCEstoqueEndereco():New()
					oEstEnder:oEndereco:SetArmazem(oModel:GetValue('DCNMASTER','DCN_LOCAL'))
					oEstEnder:oEndereco:SetEnder(oModel:GetValue('DCNMASTER','DCN_ENDER'))
					// Atualiza o status do endere�o
					oEstEnder:UpdEnder(.T.)
					oEstEnder:Destroy()
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
// M�todo que � chamado pelo MVC quando ocorrer as a��es do  ap�s a transa��o.
//-------------------------------------------------------------------
METHOD AfterTTS(oModel, cModelId) CLASS WMSModelEventWMSA300
Return

//-------------------------------------------------------------------
// M�todo que � chamado pelo MVC quando ocorrer as a��es de pre valida��o do Model
//-------------------------------------------------------------------
METHOD ModelPreVld(oModel, cModelId) CLASS WMSModelEventWMSA300
Local lRet := .T.

Return lRet

//-------------------------------------------------------------------
// M�todo que � chamado pelo MVC quando ocorrer as a��es de pos valida��o do Model
//-------------------------------------------------------------------
METHOD ModelPosVld(oModel, cModelId) CLASS WMSModelEventWMSA300
Local lRet    := .T.
Local cHorFim := StrTran(oModel:GetValue('DCNMASTER','DCN_HRFIM'),":"," ")
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If oModel:GetValue('DCNMASTER','DCN_STATUS') == '3' 
			If Empty(oModel:GetValue('DCNMASTER','DCN_ACAO'))
				WmsHelp(STR0001,STR0002,"ModelPosVld") //A��o n�o informada! // Informe a a��o para permitir o encerramento
				lRet := .F.
			EndIf
			// Ajusta data e hora
			If Empty(oModel:GetValue('DCNMASTER','DCN_DTFIM'))
				WmsHelp(STR0003,STR0004,"ModelPosVld") // Data Final n�o informada! // Informe a data final para permitir o encerramento
				lRet := .F.
			EndIf
			
			If Empty(cHorFim)
				WmsHelp(STR0005,STR0006,"ModelPosVld") // Hora final n�o informada! // Informe a hora final para permitir o encerramento
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet