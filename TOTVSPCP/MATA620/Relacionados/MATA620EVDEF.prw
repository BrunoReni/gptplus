#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA620.CH"

/*/{Protheus.doc} MATA620EVDEF
Eventos padr�o do cadastro de centro de trabalho.
@author Carlos Alexandre da Silveira
@since 27/07/2018
@version 1
/*/
CLASS MATA620EVDEF FROM FWModelEvent

	Data oModelSFC

	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld() 
	METHOD AfterTTS()
	METHOD InTTS()
	METHOD BeforeTTS()

EndClass

/*/{Protheus.doc} New
M�todo construtor
@author Carlos Alexandre da Silveira
@since 27/07/2018
@version 1
/*/
METHOD New() CLASS MATA620EVDEF

	::oModelSFC := {}

Return

/*/{Protheus.doc} ModelPosVld
M�todo de P�s-valida��o do modelo de dados.
@author Carlos Alexandre da Silveira
@since 27/07/2018
@param oModel	- Modelo de dados a ser validado
@param cModelId	- ID do modelo de dados que ser� validado.
@return lRet	- Indicador se o modelo � v�lido.
/*/
METHOD ModelPosVld(oModel,cModelId) CLASS MATA620EVDEF

	Local lRet		:= .T.
	Local nOpc		:= oModel:GetOperation()
	Local cCodigo  	:= oModel:GetModel("SH4MASTER"):GetValue("H4_CODIGO")
	Local lIntSFC 	:= ExisteSFC("SH4") .And. !IsInCallStack("AUTO620")
	Local lIntDPR 	:= IntegraDPR() .And. !IsInCallStack("AUTO620")// Determina se existe integracao com o DPR	
	
	If nOpc == 5
		If lRet .And. ExistBlock("A620DEL")
			lRet := ExecBlock("A620DEL",.F.,.F.)
			If ValType(lRet) # "L"
				lRet := .T.
			EndIf
		EndIf

		SG2->(dbSetOrder(6))
		If SG2->(dbSeek(xFilial("SG2")+cCodigo))
			Help(" ",1,"A620DELFER")
			lRet := .F.
		EndIf
		
		SH9->(dbSetOrder(3))
		If lRet .And. SH9->(dbSeek(cFilial+"F"+cCodigo))
			Help(" ",1,"A620FERBLO")
			lRet := .F.
		Else
		// Funcao Especifica NG INFORMATICA
			If !NGVALSX9("SH4",,.T.)
				lRet:= .F.
			EndIf
		EndIf
	EndIf

	If nOpc # 5 .And. ExistBlock("MA620TOK")
		lRet := ExecBlock("MA620TOK",.F.,.F.)
		If ValType(lRet) # "L"
			lRet := .T.
		EndIf
	EndIf

	If lRet .And. ( lIntSFC .Or. lIntDPR )
		::oModelSFC := FWLoadModel("SFCA006")
		lRet := A620IntSFC(nOpc,,,@::oModelSFC,.T.)
		if !lRet
			if ::oModelSFC:isActive()
				::oModelSFC:DeActivate()
			EndIf
			::oModelSFC:Destroy()
			FwModelActive(oModel)
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} AfterTTS()
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit ap�s a transa��o.
@author Carlos Alexandre da Silveira
@since 26/07/2018
@version 1.0
@return Nil
/*/
METHOD AfterTTS(oModel, cModelId) CLASS MATA620EVDEF
	
	Local nOpc		:= oModel:GetOperation()
	Local cCodigo	:= oModel:GetModel("SH4MASTER"):GetValue("H4_CODIGO")
	Local aArea		:= GetArea()
	Local lPendAut 	:= .T.
	Local lStkAut620 := IsInCallStack("AUTO620")
	Local lIntSFC 	 := ExisteSFC("SH4") .And. !lStkAut620
	Local lIntegMES	 := PCPIntgPPI() .And. !lStkAut620	
	
	If nOpc == 3 .Or. nOpc == 4
		If (ExistBlock("A620GRV"))
			ExecBlock("A620GRV",.F.,.F.,{cCodigo})
		EndIf	
	EndIf

	// Integra��o TOTVS MES.
	// Executa apenas se N�O estiver integrado com o SIGASFC, pois a rotina do ch�o de f�brica j� realiza a integra��o.
	If !lIntSFC .And. lIntegMES .And. nOpc <> 5
		If !MATA620PPI(, , nOpc==5, .T., lPendAut)
			Help( ,, 'Help',, STR0013 + AllTrim(cCodigo) + STR0014, 1, 0 ) // STR0013 - "N�o foi poss�vel realizar a integra��o com o TOTVS MES para a ferramenta 'XX'. // STR0014 - Foi gerada uma pend�ncia de integra��o para esta ferramenta."
		EndIf
	EndIf

	Restarea(aArea)
Return 
/*/{Protheus.doc} InTTS
M�todo executado ap�s as grava��es do modelo e antes do commit.
@author Carlos Alexandre da Silveira
@since 27/07/2018
@version 1.0
@param oModel	- Modelo de dados que est� sendo gravado
@param cModelId	- ID do modelo de dados que est� sendo gravado
@return lRet	- Indicador se a grava��o ocorreu corretamente.
/*/
METHOD InTTS(oModel, cModelId) CLASS MATA620EVDEF
	
	Local lIntSFC	:= ExisteSFC("SH4") .And. !IsInCallStack("AUTO620")

	If lIntSFC
		// Efetiva grava��o dos dados na tabela
		::oModelSFC:CommitData()

		::oModelSFC:DeActivate()
	EndIf

Return


/*/{Protheus.doc} BeforeTTS()
No momento do commit do modelo
@author Carlos Alexandre da Silveira
@since 30/07/2018
@version 1.0
@return Nil
/*/
METHOD BeforeTTS(oModel, cModelId) CLASS MATA620EVDEF
	Local cCodigo	:= oModel:GetModel("SH4MASTER"):GetValue("H4_CODIGO")
	Local lStkAut620 := IsInCallStack("AUTO620")
	Local lIntSFC 	 := ExisteSFC("SH4") .And. !lStkAut620
	Local lIntegMES	 := PCPIntgPPI() .And. !lStkAut620

	//Integra��o TOTVS MES para a exclus�o da ferramenta
	If lIntegMES .And. !lIntSFC .And. oModel:GetOperation() == MODEL_OPERATION_DELETE
		If !MATA620PPI(, AllTrim(cCodigo), .T., .T., .T.)
			Help( ,, 'Help',, STR0013 + AllTrim(cCodigo) + STR0014, 1, 0 ) // STR0013 - "N�o foi poss�vel realizar a integra��o com o TOTVS MES para a ferramenta 'XX'. // STR0014 - Foi gerada uma pend�ncia de integra��o para esta ferramenta."
		EndIf
	EndIf

Return Nil
