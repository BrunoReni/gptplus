#INCLUDE "PWSA010PRW.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "AP5MAIL.CH"

#DEFINE CODUSUARIO "MSALPHA"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PWSA090   �Autor  �Microsiga           � Data �  07/16/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Web Function PWSA090()
	Local cHtml := ""
	Local oWsCfgDictionary
	Private aEvaluations	
	Private aAutoEvaluations
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	oWsCfgDictionary	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
	WsChgURL(@oWsCfgDictionary,"CFGDICTIONARY.APW")
	
	If oWsCfgDictionary:GETPARAM(CODUSUARIO, "MV_APDRLV" )
		HttpSession->cCpoRelev := AllTrim( oWsCfgDictionary:cGETPARAMRESULT )
	EndIf
	
	//Verifica se Busca Descricao da Rede
	If oWsCfgDictionary:GETPARAM( CODUSUARIO, "MV_APDREDE" )
		HttpSession->lDescRede := oWsCfgDictionary:cGETPARAMRESULT		
		   
		If !ValType(HttpSession->lDescRede) == "L"
			If !CheckExecForm( {|| HttpSession->lDescRede:= __ExecMacro(HttpSession->lDescRede)}, .F. )
				HttpSession->lDescRede:= .F.
			EndIf
		EndIf			
	EndIf
			
	//SE STATUS = 1 - ALTERACAO
	//SE STATUS = 2 - CONSULTA FINALIZADOS
	If !Empty(HttpGet->cStatus)
		HttpSession->cStatus := HttpGet->cStatus
	EndIf
	
	If !Empty(HttpGet->cTpAval)
		HttpSession->cTpAval := HttpGet->cTpAval
	EndIf
	
	//HttpSession->cTipoAv:= "3"
	
	If Empty( HttpSession->cParticipantID )
		HttpSession->_HTMLERRO := {STR0001, STR0002, "W_PWSA001.APW" }	//"Erro"##"Participante n�o encontrado"
		Return ExecInPage("PWSAMSG" )
	EndIf

	aAutoEvaluations:= GetAutoEvaluates(HttpSession->cParticipantID, HttpSession->cTpAval, HttpSession->cStatus, HttpSession->lDescRede)	
	aEvaluations:= GetProjEvaluates(HttpSession->cParticipantID, HttpSession->cTpAval, HttpSession->cStatus, HttpSession->lDescRede)

	If aAutoEvaluations == NIL .OR.;
	   aEvaluations == NIL
		Return ExecInPage("PWSAMSG" )
	EndIf
	
	If Len(aAutoEvaluations[1]) == 0 .AND.;
	   Len(aEvaluations) == 0
		HttpSession->_HTMLERRO := {IIf(HttpSession->cTpAval == "3", STR0018, STR0004) + " - " + IIf(HttpSession->cStatus == "1", STR0019, STR0020), STR0011, "javascript:history.back();" }
		Return ExecInPage("PWSAMSG" )
	EndIf

	cHtml += ExecInPage( "PWSA090" )
	
	WEB EXTENDED END
Return cHtml



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �		    �Autor  �Microsiga           � Data �  07/16/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Consulta se existem avaliacoes de subordinados para o 	  ���
���			 �participante logado										  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
/*Static Function GetSubEvaluates(cParticipantID, cEvaluateType, cStatus, lNetDescription)
	Local oWSPerformanceEvaluate := WSRHPERFORMANCEEVALUATE():New()
	WsChgURL(@oWSPerformanceEvaluate, "RHPERFORMANCEEVALUATE.APW")

	If !oWSPerformanceEvaluate:BRWMYEVALUATED(	CODUSUARIO,;
												cParticipantID,;
												cEvaluateType,;
												NIL,;
												cStatus,;
												"2")
		HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA001.APW" }	//"Erro"
		Return NIL
	EndIf
	
	If lNetDescription
		Return SplitByNet(oWSPerformanceEvaluate:oWSBRWMYEVALUATEDRESULT:oWSEVALUATELIST)
	EndIf
Return {oWSPerformanceEvaluate:oWSBRWMYEVALUATEDRESULT:oWSEVALUATELIST}
*/

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PWSA090   �Autor  �Microsiga           � Data �  07/16/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �consulta se existem auto-avaliacoes do participante logado  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GetAutoEvaluates(cParticipantID, cEvaluateType, cStatus, lNetDescription)
	Local oWSPerformanceEvaluate := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
	WsChgURL(@oWSPerformanceEvaluate, "RHPERFORMANCEEVALUATE.APW")

	If !oWSPerformanceEvaluate:BRWMYEVALUATES(	CODUSUARIO,;
												cParticipantID,;
												cEvaluateType,;
												NIL,;
												NIL,;
												NIL,;												
												cStatus)
		HttpSession->_HTMLERRO := {STR0001, PWSGetWSError(), "W_PWSA001.APW" }			//"Erro"
		Return NIL
	EndIf
	
	If lNetDescription
		Return SplitByNet(oWSPerformanceEvaluate:oWSBRWMYEVALUATESRESULT:oWSEVALUATELIST)
	EndIf
Return {oWSPerformanceEvaluate:oWSBRWMYEVALUATESRESULT:oWSEVALUATELIST}



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PWSA090   �Autor  �Microsiga           � Data �  07/16/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �consulta se existem avaliacoes do superior para o 		  ���
���          �participante logado                                     	  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
/*Static Function GetSuperEvaluates(cParticipantID, cEvaluateType, cStatus, lNetDescription)
	Local oWSPerformanceEvaluate := WSRHPERFORMANCEEVALUATE():New()
	WsChgURL(@oWSPerformanceEvaluate, "RHPERFORMANCEEVALUATE.APW")


	If !oWSPerformanceEvaluate:BRWMYEVALUATED(	CODUSUARIO,;
												cParticipantID,;
												cEvaluateType,;
												NIL,;
												cStatus,;
												"3")
		HttpSession->_HTMLERRO := {STR0001, PWSGetWSError(), "W_PWSA001.APW"}	//"Erro"
		Return NIL
	EndIf
	
	If lNetDescription
		Return SplitByNet(oWSPerformanceEvaluate:oWSBRWMYEVALUATEDRESULT:oWSEVALUATELIST)
	EndIf
Return {oWSPerformanceEvaluate:oWSBRWMYEVALUATEDRESULT:oWSEVALUATELIST}
*/


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PWSA090   �Autor  �Microsiga           � Data �  07/16/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �CONSULTA SE EXISTEM AVALIACOES DE PARES PARA O PARTICIPANTE ���
���          �LOGADO                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
/*Static Function GetPairEvaluates(cParticipantID, cEvaluateType, cStatus, lNetDescription)
	Local oWSPerformanceEvaluate := WSRHPERFORMANCEEVALUATE():New()
	WsChgURL(@oWSPerformanceEvaluate, "RHPERFORMANCEEVALUATE.APW")
	
	If !oWSPerformanceEvaluate:BRWMYEVALUATED(	CODUSUARIO,;
												cParticipantID,;
												cEvaluateType,;
												NIL,;
												cStatus,;
												"1")
		HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA001.APW" }	//"Erro"
		Return NIL
	EndIf

	If lNetDescription
		Return SplitByNet(oWSPerformanceEvaluate:oWSBRWMYEVALUATEDRESULT:oWSEVALUATELIST)
	EndIf
Return {oWSPerformanceEvaluate:oWSBRWMYEVALUATEDRESULT:oWSEVALUATELIST}
*/


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PWSA090   �Autor  �Microsiga           � Data �  07/16/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function SplitByNet(aEvaluate)
	//Separa itens por rede
	Local nCount
	Local cRede		:= ""
	Local aReturn	:= {}
	
	Asort(aEvaluate,,,{ |oNumber1, oNumber2| oNumber1:cNet < oNumber2:cNet } )

	For nCount := 1 To Len(aEvaluate)
		If cRede != aEvaluate[nCount]:cNetDescription
			cRede := aEvaluate[nCount]:cNetDescription
			Aadd(aReturn, {})
		EndIf

		Aadd(aReturn[Len(aReturn)], aEvaluate[nCount] )
	Next nCount
	
	If Len(aReturn) == 0
		Aadd(aReturn, {})	
	EndIf
Return aReturn




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PWSA090   �Autor  �Microsiga           � Data �  07/16/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �consulta se existem avaliacoes do superior para o 		  ���
���          �participante logado                                     	  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GetProjEvaluates(cParticipantID, cEvaluateType, cStatus, lNetDescription)
	Local oWSPerformanceEvaluate := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPROJECTEVALUATE"), WSRHPROJECTEVALUATE():New())
	WsChgURL(@oWSPerformanceEvaluate, "RHPROJECTEVALUATE.APW")


	If !oWSPerformanceEvaluate:GetEvaluations(	cParticipantID,;
												cEvaluateType,;
												cStatus,;
												"3")
		HttpSession->_HTMLERRO := {STR0001, PWSGetWSError(), "W_PWSA001.APW"}	//"Erro"
		Return NIL
	EndIf	
Return oWSPerformanceEvaluate:oWSGetEvaluationsRESULT:oWSTEVALUATION


Web Function PWSA091()
	Local cHtml := ""
	Local oWSPerformanceEvaluate
	Private aEvaluated
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	oWSPerformanceEvaluate := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPROJECTEVALUATE"), WSRHPROJECTEVALUATE():New())
	WsChgURL(@oWSPerformanceEvaluate, "RHPROJECTEVALUATE.APW")
	
	If !oWSPerformanceEvaluate:GetEvaluated(HttpGet->cEvaluationID, HttpGet->cEvaluatorID)
		HttpSession->_HTMLERRO := {STR0001, PWSGetWSError(), "W_PWSA001.APW"}	//"Erro"
		Return ExecInPage("PWSAMSG" )
	EndIf

	aEvaluated:= oWSPerformanceEvaluate:oWSGetEvaluatedRESULT:oWSTParticipant
	ASort(aEvaluated,,, { |oNumber1, oNumber2| oNumber1:cName < oNumber2:cName })

	cHtml += ExecInPage( "PWSA091" )
	
	WEB EXTENDED END
Return cHtml

Web Function PWSA092()
	Local cHtml := ""
	Local oWSPerformanceEvaluate
	Private aEvaluationItems
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	oWSPerformanceEvaluate := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPROJECTEVALUATE"), WSRHPROJECTEVALUATE():New())
	WsChgURL(@oWSPerformanceEvaluate, "RHPROJECTEVALUATE.APW")
	
	If !oWSPerformanceEvaluate:GetEvaluationItems(HttpGet->cEvaluationID, HttpGet->cEvaluatorID, HttpGet->cEvaluatedID)
		HttpSession->_HTMLERRO := {STR0001, PWSGetWSError(), "W_PWSA001.APW"}	//"Erro"
		Return ExecInPage("PWSAMSG" )
	EndIf

	aEvaluationItems:= oWSPerformanceEvaluate:oWSGetEvaluationItemsRESULT:oWSTEvaluationItem

	cHtml += ExecInPage("PWSA092")
	
	WEB EXTENDED END
Return cHtml


