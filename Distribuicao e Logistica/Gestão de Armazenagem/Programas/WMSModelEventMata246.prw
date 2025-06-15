#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'WMSModelEventMata246.ch'

#define WMSM24601 "WMSM24601"
#define WMSM24602 "WMSM24602"
#define WMSM24603 "WMSM24603"

//-------------------------------------------------------------------
CLASS WMSModelEventMata246 FROM FWModelEvent
	METHOD New() CONSTRUCTOR
	METHOD Destroy()
	METHOD BeforeTTS(oModel, cModelId)
	METHOD After(oModel, cModelId, cAlias, lNewRecord)
	METHOD InTTS(oModel, cModelId)
	METHOD AfterTTS(oModel, cModelId)

	METHOD ModelPreVld(oModel, cModelId)
	METHOD ModelPosVld(oModel, cModelId)
ENDCLASS

METHOD New()�CLASS WMSModelEventMata246
Return
�
METHOD Destroy()� Class WMSModelEventMata246�������
Return

//-------------------------------------------------------------------
// M�todo que � chamado pelo MVC quando ocorrer as a��es do commit antes da transa��o.
//-------------------------------------------------------------------
METHOD BeforeTTS(oModel, cModelId) CLASS WMSModelEventMata246
Return

//-------------------------------------------------------------------
// M�todo que � chamado pelo MVC quando ocorrer as a��es do commit
// depois da grava��o de cada submodelo (field ou cada linha de uma grid)
//-------------------------------------------------------------------
METHOD After(oModel, cModelId, cAlias, lNewRecord) CLASS WMSModelEventMata246
Local lRet       := .T.
Local oOrdSerDel := WMSDTCOrdemServicoDelete():New()

	oOrdSerDel:SetIdDCF(DH1->DH1_IDDCF)
	If oOrdSerDel:LoadData()
		If !oOrdSerDel:DeleteDCF()
			oModel:SetErrorMessage(cModelId,,,,WMSM24602,oOrdSerDel:GetErro())
			lRet := .F.
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
// M�todo que � chamado pelo MVC quando ocorrer as a��es do commit 
// Ap�s as grava��es por�m antes do final da transa��o
//-------------------------------------------------------------------
METHOD InTTS(oModel, cModelId) CLASS WMSModelEventMata246
Local lRet := .T.
Return lRet

//-------------------------------------------------------------------
// M�todo que � chamado pelo MVC quando ocorrer as a��es do  ap�s a transa��o.
//-------------------------------------------------------------------
METHOD AfterTTS(oModel, cModelId) CLASS WMSModelEventMata246
Return

//-------------------------------------------------------------------
// M�todo que � chamado pelo MVC quando ocorrer as a��es de pre valida��o do Model
//-------------------------------------------------------------------
METHOD ModelPreVld(oModel, cModelId) CLASS WMSModelEventMata246
Local lRet := .T.
Return lRet

//-------------------------------------------------------------------
// M�todo que � chamado pelo MVC quando ocorrer as a��es de pos valida��o do Model
//-------------------------------------------------------------------
METHOD ModelPosVld(oModel, cModelId) CLASS WMSModelEventMata246
Local lRet       := .T.
Local oOrdSerDel := Nil
Local cMessage   := ""
Local aMessage   := {}

	If AllTrim(DH1->DH1_ROTINA) == "WMSA505"
		oModel:SetErrorMessage(cModelId,,,,WMSM24603,STR0002,STR0003) // "Este registro n�o pode ser estornado manualmente."##"Realize o estorno da requisi��o WMSA505."
		lRet := .F.
	EndIf
	
	If lRet
		oOrdSerDel := WMSDTCOrdemServicoDelete():New()
		oOrdSerDel:SetIdDCF(DH1->DH1_IDDCF)
		If oOrdSerDel:LoadData()
			If !oOrdSerDel:CanDelete()
				cMessage := STR0001+" - OS "+LTrim(oOrdSerDel:GetDocto())+" - ID "+oOrdSerDel:GetIdDCF()+CRLF // Movimenta��o integrada ao SIGAWMS
				aMessage := StrTokArr2(oOrdSerDel:GetErro(),CRLF)
				AEval(aMessage, {|x| cMessage := cMessage + x + " "}, 1,Len(aMessage)-1)
				oModel:SetErrorMessage(cModelId,,,,WMSM24601,cMessage,aMessage[Len(aMessage)])
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet
