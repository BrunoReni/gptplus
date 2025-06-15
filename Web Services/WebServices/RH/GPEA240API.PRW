#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "GPEA240API.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"

#DEFINE TAB CHR ( 13 ) + CHR ( 10 )
#DEFINE MODEL_OPERATION_UPDATE 4

/*
{Protheus.doc} leaveOfAbsenceControl
API de Controle de Afastamentos                              
@author  Wesley Alves Pereira
@since   23/03/2020
@version 12.1.27
*/

WSRESTFUL leaveOfAbsenceControl DESCRIPTION STR0001 FORMAT "application/json" //"Serviço genérico para retorno das informações de Cadastro de Ausencias"
WSDATA leaveOfAbsenceId As Character

WSMETHOD POST; 	
DESCRIPTION EncodeUTF8(OemToAnsi(STR0002)); // "Insere um registro no cadastro de ausências no módulo de Gestão de Pessoas"
WSSYNTAX "/api/rh/v1/leaveOfAbsenceControl" ;
PATH "/api/rh/v1/leaveOfAbsenceControl" ;
PRODUCES 'application/json;charset=utf-8';
TTALK "v1" 

WSMETHOD PUT leaveOfAbsenceId ;
DESCRIPTION EncodeUTF8(OemToAnsi(STR0004)) ; 
WSSYNTAX "/api/rh/v1/leaveOfAbsenceControl/{leaveOfAbsenceId}" ; //"Altera um registro no cadastro de ausências no módulo de Gestão de Pessoas"
PATH "/api/rh/v1/leaveOfAbsenceControl/{leaveOfAbsenceId}" ;
PRODUCES 'application/json;charset=utf-8' ;
TTALK "v1"

WSMETHOD DELETE leaveOfAbsenceId ;
DESCRIPTION EncodeUTF8(OemToAnsi(STR0003)) ; //"Exclui um registro no cadastro de ausências no módulo de Gestão de Pessoas"
WSSYNTAX "/api/rh/v1/leaveOfAbsenceControl/{leaveOfAbsenceId}" ;
PATH "/api/rh/v1/leaveOfAbsenceControl/{leaveOfAbsenceId}" ;
PRODUCES 'application/json;charset=utf-8' ;
TTALK "v1"

END WSRESTFUL

// Insere uma solicitação de afastamento dentro do módulo de Gestão de Pessoas
/*/{Protheus.doc} POST
 TODO Método responsável pela inclusão de um registro de afastamento com valores passados como paramêtro no Header do REST/JSON
@author  Wesley Alves Pereira
@since   23/03/2020
@version 12.1.27
@return return, return_description
/*/

WSMETHOD POST HEADERPARAM authorization WSREST leaveOfAbsenceControl 

	Local json as OBJECT
	Local cBody As Character
	Local cRecebe As Character
	Local lRetorno as Logical
	Local cRetorno := ""
	Local cId As Character 
	Local cParEmp As Character
	Local cParFil As Character
	Local aParFun := {}
	Local aParAfa := {}
	Local nOpca := 3
	Local cRCM_PD := ""
	Local dIniData 
	Local dFinData 
	Local cIniData := ""
	Local cFinData := ""
	Local nDias    := 0
	Local cNomMed  := ""
	Local cCRMMed  := ""
	Local cEstMed  := ""
	Local cDoeMed  := ""
	Local cTipMed  := ""
	Local nTam := 0
	Local cContAfa := ""
	Local nSeq		:= 0

	Private cProcesso	:= ""

	BEGIN SEQUENCE

	json		:= JsonObject():New()
	cBody		:= DecodeUTF8(Self:GetContent())
	lRetorno	:= .F.
	cRecebe   := json:FromJSON(EncodeUTF8(NoAcento(cBody)))
		
	If cRecebe != Nil  .Or. Len(json:GetNames()) == 0  
		fSendMess(400,STR0005,.T.,400,STR0015,,) //"Não foi possível reconhecer o pacote recebido. Verifique a informação e envie novamente."
		return (lRetorno)
	EndIf

	If (! ( fValidaDados(nOpca,@json)))
		return (lRetorno)
	EndIf

	prepInfoR8(json, @cParEmp, @cParFil, @aParFun, @aParAfa, @cIniData, @cFinData, @cNomMed, @cEstMed, @cTipMed, @cCRMMed, @cDoeMed, @cContAfa)

	RESET ENVIRONMENT
	RPCSetType(3)
	PREPARE ENVIRONMENT EMPRESA cParEmp FILIAL cParFil TABLES "SR8, SRA, RCM " MODULO "GPE"

		aEval({'SRA','SR8'},{|x|CHKFILE(x)})

		if !Empty(cIniData)
			dIniData := fClearDate(cIniData)
		EndIf
		if !Empty(cFinData)
			dFinData := fClearDate(cFinData)
			nDias := ( dFinData - dIniData) + 1
		Else
			dFinData := STOD("")
		EndIf
		
		nTam    := TamSx3("R8_SEQ")[1]

		RCM->(DbSetOrder(1))
		If(RCM->(DbSeek(aParAfa[2] + aParAfa[3])))
			cRCM_PD := RCM->RCM_PD		
		EndIf    
		
		SRA->(DbSetOrder(1))
		If(SRA->(DbSeek(aParFun[2] + aParFun[3])))
			oModel := FWLoadModel("GPEA240")
			oModel:SetOperation(MODEL_OPERATION_UPDATE)          
			If(oModel:Activate())              
				oSubMdl := oModel:GetModel("GPEA240_SR8")          
				If(oSubMdl:Length() > 1)                
					nSeq := oSubMdl:AddLine()
				Else
					If(oSubMdl:IsInserted())
						nSeq := 1
					Else
						nSeq := oSubMdl:AddLine()
					EndIf
				EndIf
				nSeq := Max(nSeq, Val(g240NextSq(SRA->RA_FILIAL, SRA->RA_MAT)) )

				oSubMdl:SetValue("R8_FILIAL"  , cParFil)
				oSubMdl:SetValue("R8_MAT"     , aParFun[3])
				oSubMdl:SetValue("R8_DATA"    , dIniData)
				oSubMdl:SetValue("R8_SEQ"     , StrZero(nSeq,nTam))
				oSubMdl:SetValue("R8_TIPOAFA" , aParAfa[3])
				oSubMdl:SetValue("R8_PD"      , cRCM_PD)
				oSubMdl:SetValue("R8_DATAINI" , dIniData)
				oSubMdl:SetValue("R8_DURACAO" , nDias)
				oSubMdl:SetValue("R8_NMMED"   , cNomMed)
				oSubMdl:SetValue("R8_CRMMED"  , cCRMMed)
				oSubMdl:SetValue("R8_UFCRM"   , cEstMed)
				oSubMdl:SetValue("R8_CID"     , cDoeMed)
				oSubMdl:SetValue("R8_IDEOC"   , cTipMed)

				If !Empty(cContAfa)
					oSubMdl:SetValue("R8_CONTAFA", cContAfa)
					oSubMdl:SetValue("R8_CONTINU", "1")
				Else
					oSubMdl:SetValue("R8_CONTINU", "2")				
				Endif
					
				If(oModel:VldData()) .And. oModel:CommitData()
					lRetorno := .T.
				
					cId := cParEmp+";"
					cId += cParFil+";"
					cId += aParFun[1]+"|"+aParFun[2]+"|"+aParFun[3]+";"
					cId += cIniData+";"
					cId += "00:00"+";"
					cId += cFinData+";"
					cId += aParAfa[1]+"|"+aParAfa[2]+"|"+aParAfa[3]
				
					cRetorno :=  fSendJson(json,cId)
					::SetResponse(cRetorno)
				Else
					aLog := oModel:GetErrorMessage()
					fSendMess(400,STR0012,.T.,400,ArrTokStr(aLog),,)
				EndIf          
			EndIf
		EndIf

	RECOVER
		ErrorBlock(bErrorBlock)
		fSendMess(500,oError:Description,.T.,500,STR0009,,) //"Ocorreu uma falha no retorno da informação."		
		lRetorno := .F.
	END SEQUENCE

Return (lRetorno)

// Altera uma solicitação de afastamento dentro do módulo de Gestão de Pessoas
/*/{Protheus.doc} PUT
 TODO Método responsável pela alteração de um registro de solicitaçao de afastamento com valores passados como paramêtro no Header do REST/JSON
@author  Wesley Alves Pereira
@since   23/03/2020
@version 12.1.27
@return return, return_description
/*/

WSMETHOD PUT leaveOfAbsenceId WSREST leaveOfAbsenceControl
	Local aUrlParam	:= ::aUrlParms
	Local cJsonObj	:= "JsonObject():New()"
	Local oItem		:= &cJsonObj
	Local oItemDetail	:= &cJsonObj
	Local cToken := Self:GetHeader('Authorization')

	Local json as OBJECT
	Local cBody As Character
	Local cRecebe As Character
	Local cId := ""

	//Variaveis do corpo
	Local cParEmp As Character
	Local cParFil As Character
	Local aParFun := {}
	Local aParAfa := {}
	Local cContAfa := ""

	Local nOpca := 4
	Local nTam := 0
	Local lRetorno := .F.
	Local aRetorno := {}
	Local cChave := ""
	Local dRecDIni := CTOD("")
	Local dRecDFin := CTOD("")
	Local dIniData := CTOD("")
	Local dFinData := CTOD("")
	Local cIniData := ""
	Local cFinData := ""

	Local cRCM_PD := ""
	Local cNomMed := ""
	Local cCRMMed := ""
	Local cEstMed := ""
	Local cDoeMed := ""
	Local cTipMed := ""
	Local nDias	  := 0


	BEGIN SEQUENCE

		if Empty(aUrlParam) .OR. Len(aUrlParam) == 0
			fSendMess(400,STR0018,.T.,400,STR0015,,) // STR0018: "Informação allowanceId ausente ou inválida."
			lRetorno := .F.
			return (lRetorno)
		else 
			cChave = aUrlParam[1]
		EndIf

		If Empty(cChave)
			fSendMess(400,STR0014,.T.,400,STR0015,,) //Informação leaveOfAbsenceId ausente ou inválida."
			lRetorno := .F.
			Return (lRetorno)
		EndIf

		aRetorno := fValidaChave(cChave)

		If (Len(aRetorno) == 0)
			fSendMess(400,STR0014,.T.,400,STR0015,,) //"Informação leaveOfAbsenceId ausente ou inválida."
			lRetorno := .F.
			Return (lRetorno)
		EndIf

		dRecDIni := fClearDate(aRetorno[9])

		dRecDFin := fClearDate(aRetorno[11])

		json		:= JsonObject():New()
		cBody		:= DecodeUTF8(Self:GetContent())
		cRecebe   := json:FromJSON(EncodeUTF8(NoAcento(cBody)))
			
		If cRecebe != Nil  .Or. Len(json:GetNames()) == 0  
			fSendMess(400,STR0005,.T.,400,STR0015,,) // STR0005: "Não foi possível reconhecer o pacote recebido. Verifique a informação e envie novamente."
			return (lRetorno)
		EndIf

		If (! ( fValidaDados(nOpca,@json)))
			lRetorno := .F.
			return (lRetorno)
		EndIf

		prepInfoR8(json, @cParEmp, @cParFil, @aParFun, @aParAfa, @cIniData, @cFinData, @cNomMed, @cEstMed, @cTipMed, @cCRMMed, @cDoeMed, @cContAfa)

		If Empty(cParEmp)
			cParEmp := aRetorno[1]
		EndIf

		If Empty(cParFil)
			cParFil := aRetorno[2]
		EndIf

		If Empty(aParAfa)
			aParAfa := {aRetorno[6],aRetorno[7],aRetorno[8]}
		EndIf

		If Empty(aParFun)
			aParFun := {aRetorno[3],aRetorno[4],aRetorno[5]}
		EndIf

		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA cParEmp FILIAL cParFil TABLES "SR8, SRA, RCM " MODULO "GPE"

		DBSelectArea("SR8")
		SR8->(DbSetOrder(6)) //R8_FILIAL+R8_MAT+DTOS(R8_DATAINI)+R8_TIPOAFA+STR(R8_DIASEMP)
		If ! ( SR8-> ( DbSeek ( aRetorno[2] + aRetorno[5] + DTOS ( dRecDIni ) + aRetorno[8] ) ))
			fSendMess(400,STR0014,.T.,400,STR0015,,) //"Informação leaveOfAbsenceId ausente ou inválida."
			lRetorno := .F.
			Return (lRetorno)
		EndIf

		aEval({'SRA','SR8'},{|x|CHKFILE(x)})

		dIniData := fClearDate(cIniData)
		dFinData := fClearDate(cFinData)
		
		If Empty(dIniData)
			dIniData := dRecDIni
		EndIf
		
		If Empty(dFinData)
			dFinData := dRecDFin 
		EndIf

		If !Empty(dFinData)
			nDias := ( dFinData - dIniData) + 1
		EndIf

		nTam    := TamSx3("R8_SEQ")[1]

		RCM->(DbSetOrder(1))
		If(RCM->(DbSeek(aParAfa[2] + aParAfa[3])))
			cRCM_PD := RCM->RCM_PD		
		EndIf    

		SRA->(DbSetOrder(1))
		If(SRA->(DbSeek(aParFun[2] + aParFun[3])))
			
			aRecAltSR8 := {}
			aAltSR8 := {}

			aAdd( aRecAltSR8, { "R8_FILIAL"	, aRetorno[2] } )
			aAdd( aRecAltSR8, { "R8_MAT"	, aRetorno[5] } )
			aAdd( aRecAltSR8, { "R8_TIPOAFA", aRetorno[8] } )
			aAdd( aRecAltSR8, { "R8_DATAINI", dRecDIni } )
			aAdd( aRecAltSR8, { "R8_DATAFIM", dRecDFin } )

			aAdd(aAltSR8 , aRecAltSR8)

			oModel := FWLoadModel("GPEA240")
			oModel:SetOperation(MODEL_OPERATION_UPDATE)          
			If(oModel:Activate())  
				
				oSubMdl := oModel:GetModel("GPEA240_SR8") 
				
				If oSubMdl:SeekLine( aAltSR8[1] )

					oSubMdl:SetValue("R8_TIPOAFA" , aParAfa[3])
					oSubMdl:SetValue("R8_DATAINI" , dIniData)
					oSubMdl:SetValue("R8_DURACAO" , nDias)
					
					If !Empty(cRCM_PD)
						oSubMdl:SetValue("R8_PD"      , cRCM_PD)
					EndIf
					If !Empty(cNomMed)
						oSubMdl:SetValue("R8_NMMED"   , cNomMed)
					EndIf
					If !Empty(cCRMMed)
						oSubMdl:SetValue("R8_CRMMED"  , cCRMMed)
					EndIf
					If !Empty(cEstMed)
						oSubMdl:SetValue("R8_UFCRM"   , cEstMed)
					EndIf
					oSubMdl:SetValue("R8_CID"     , cDoeMed)
					If !Empty(cTipMed)
						oSubMdl:SetValue("R8_IDEOC"   , cTipMed)
					EndIf	

					oSubMdl:SetValue("R8_CONTAFA", cContAfa)
					oSubMdl:SetValue("R8_CONTINU", IIf(!Empty(cContAfa),"1","2") )

					If(oModel:VldData())
						oModel:CommitData()
						lRetorno := .T.

						cId := cParEmp+";"
						cId += cParFil+";"
						cId += aRetorno[3]+"|"+aRetorno[4]+"|"+aRetorno[5]+";"
						cId += cIniData+";"
						cId += "00:00"+";"
						cId += cFinData+";"
						cId += aParAfa[1]+"|"+aParAfa[2]+"|"+aParAfa[3]

						cRetorno :=  fSendJson(json,cId)
						::SetResponse(cRetorno)
					Else
						aLog := oModel:GetErrorMessage()
						fSendMess(400,STR0012,.T.,400,ArrTokStr(aLog),,)
					EndIf          
				Else	
					fSendMess(400,STR0014,.T.,400,STR0015,,) //"Informação leaveOfAbsenceId ausente ou inválida."
					lRetorno := .F.
					Return (lRetorno)
				EndIf
			EndIf
		EndIf
	RECOVER
		ErrorBlock(bErrorBlock)
		fSendMess(500,oError:Description,.T.,500,STR0009,,) //"Ocorreu uma falha no retorno da informação."		
		lRetorno := .F.
	END SEQUENCE

Return (lRetorno)

//Deleta uma solicitação de afatamento dentro do módulo de Gestão de Pessoas
/*/{Protheus.doc} DELETE
 TODO Método responsável pela exclusão de um registro de solicitação de afastamento com valores passados como paramêtro no Header do REST/JSON
@author  Wesley Alves Pereira
@since   19/03/2020
@version 12.1.27
@return return, return_description
/*/
WSMETHOD DELETE leaveOfAbsenceId WSREST leaveOfAbsenceControl
Local aUrlParam	:= ::aUrlParms
Local cJsonObj	:= "JsonObject():New()"
Local oItem		:= &cJsonObj
Local oItemDetail	:= &cJsonObj
Local cToken := Self:GetHeader('Authorization')

Local cChave := ""
Local lRetorno := .F.
Local aRetorno := {}

Local cEmpPar := ""
Local cFilPar := ""
Local cEmpFun := ""
Local cFilFun := ""
Local cCodFun := ""
Local cEmpAfa := ""
Local cFilAfa := ""
Local cCodAfa := ""
Local dDatIni 
Local cDatIni := ""
Local dDatFin
Local cDatFin := "" 

BEGIN SEQUENCE

if Empty(aUrlParam) .OR. Len(aUrlParam) == 0
	fSendMess(400,STR0018,.T.,400,STR0015,,) // STR0018: "Informação allowanceId ausente ou inválida."
	lRetorno := .F.
	return (lRetorno)
else 
	cChave = aUrlParam[1]
EndIf

If Empty(cChave)
	fSendMess(400,STR0014,.T.,400,STR0015,,) //"Informação leaveOfAbsenceId ausente ou inválida."
	lRetorno := .F.
	Return (lRetorno)
EndIf

aRetorno := fValidaChave(cChave)

If (Len(aRetorno) == 0)
	fSendMess(400,STR0014,.T.,400,STR0015,,) //"Informação leaveOfAbsenceId ausente ou inválida."
	lRetorno := .F.
	Return (lRetorno)
EndIf

cEmpPar := aRetorno[1]
cFilPar := aRetorno[2]
cEmpFun := aRetorno[3]
cFilFun := aRetorno[4]
cCodFun := aRetorno[5]
cEmpAfa := aRetorno[6]
cFilAfa := aRetorno[7]
cCodAfa := aRetorno[8]
cDatIni := aRetorno[9]
cDatFin := aRetorno[11]

dDatIni := fClearDate(cDatIni)
dDatFin := fClearDate(cDatFin)

RESET ENVIRONMENT
RPCSetType(3)
PREPARE ENVIRONMENT EMPRESA cEmpPar FILIAL cFilPar TABLES "SRA, RA1, RF0" MODULO "GPE"

	DBSelectArea("SR8")
	SR8->(DbSetOrder(6)) //R8_FILIAL+R8_MAT+DTOS(R8_DATAINI)+R8_TIPOAFA+STR(R8_DIASEMP)
	If ! ( SR8-> ( DbSeek ( cFilPar + cCodFun + DTOS ( dDatIni ) + cCodAfa ) ))
		fSendMess(400,STR0014,.T.,400,STR0015,,) //"Informação leaveOfAbsenceId ausente ou inválida."
		lRetorno := .F.
		Return (lRetorno)
	EndIf
	
	aEval({'SRA','SR8'},{|x|CHKFILE(x)})
	
    SRA->(DbSetOrder(1))
	If(SRA->(DbSeek(cFilFun + cCodFun)))

		aRecDelSR8 := {}
		aDelSR8 := {}

		aAdd( aRecDelSR8, { "R8_FILIAL"	, cFilPar } )
		aAdd( aRecDelSR8, { "R8_MAT"	, cCodFun } )
		aAdd( aRecDelSR8, { "R8_TIPOAFA", cCodAfa } )
		aAdd( aRecDelSR8, { "R8_DATAINI", dDatIni } )
		aAdd( aRecDelSR8, { "R8_DATAFIM", dDatFin } )	
		
		aAdd(aDelSR8 , aRecDelSR8)

    	oModel := FWLoadModel("GPEA240")
        oModel:SetOperation(MODEL_OPERATION_UPDATE)          
        If(oModel:Activate())  
			
			oSubMdl := oModel:GetModel("GPEA240_SR8") 
		 	
			If oSubMdl:SeekLine( aDelSR8[1] )

				If (!oSubMdl:IsDeleted())                 
					If ( oSubMdl:DeleteLine() .AND. oModel:VldData() ) 
						lRetorno := .T.
						If oModel:CommitData()
							cRetorno :=  fSendDelete(STR0017) //"Operação realizada com sucesso!"
							::SetResponse(cRetorno)
						Else
							aLog := oModel:GetErrorMessage()
							fSendMess(400,STR0012,.T.,400,ArrTokStr(aLog),,)
							//fSendMess(400,STR0014,.T.,400,STR0015,,)
							lRetorno := .F.
							Return (lRetorno)
						EndIf
					Else
						aLog := oModel:GetErrorMessage()
						fSendMess(400,STR0012,.T.,400,ArrTokStr(aLog),,)
					EndIf
				Else
					fSendMess(400,STR0014,.T.,400,STR0015,,) //"Informação leaveOfAbsenceId ausente ou inválida."
					lRetorno := .F.
					Return (lRetorno)
				EndIf
			Else
				fSendMess(400,STR0014,.T.,400,STR0015,,) //"Informação leaveOfAbsenceId ausente ou inválida."
				lRetorno := .F.
				Return (lRetorno)
			EndIf          
        EndIf
	EndIf

RECOVER
	ErrorBlock(bErrorBlock)
	fSendMess(500,oError:Description,.T.,500,STR0009,,) //"Ocorreu uma falha no retorno da informação."		
	lRetorno := .F.
END SEQUENCE

Return (lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendMess
Gera as mensagens para o retorno REST/JSON
@author  Wesley Alves Pereira
@since   09/03/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fSendMess(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

DEFAULT nCode := 500
DEFAULT cMessage := STR0006
DEFAULT lJson := .T.
DEFAULT nStatus := 500
Default cDetailMsg := STR0006
Default cHelpUrl := "https://tdn.totvs.com/x/BJuMHw"
DEFAULT aDetails := {}

SetRestFault(nCode,EncodeUTF8(NoAcento(OemToAnsi(cMessage))),lJson,nStatus,EncodeUTF8(NoAcento(OemToAnsi(cDetailMsg))),cHelpUrl,aDetails)

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendJson
Gera as mensagens para o retorno REST/JSON
@author  Wesley Alves Pereira
@since  12/03/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fSendJson(ojson,cId)
Local cJsonObj := "JsonObject():New()"
Local oMsgReturn	:= &cJsonObj
Local oItem		 	:= &cJsonObj
Local aMessages := {}
Local cJson			:= ""
Local lcompact := .F.

If Type("Self:GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(Self:GetHeader('Accept-Encoding') )        
	lCompact := .T.
EndIf

ojson["id"] := cId

If(lCompact)    	
	cJson := fCompress(ojson)				
Else
	cJson :=  FWJsonSerialize(ojson, .F., .F., .T.)   	
Endif

Return (cJson)
//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendDelete
Gera as mensagens para o retorno REST/JSON
@author  Wesley Alves Pereira
@since  12/03/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fSendDelete(cMessage)
Local cJsonObj := "JsonObject():New()"
Local oMsgReturn	:= &cJsonObj
Local cJson			:= ""
Local lcompact := .F.

If Type("Self:GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(Self:GetHeader('Accept-Encoding') )        
	lCompact := .T.
EndIf

oMsgReturn["code"] 		:= "200"
oMsgReturn["description"] := EncodeUTF8(NoAcento(OemToAnsi(cMessage)))

If(lCompact)    	
	cJson := fCompress(oMsgReturn)				
Else
	cJson :=  FWJsonSerialize(oMsgReturn, .F., .F., .T.)   	
Endif

Return (cJson)

/*/{Protheus.doc} fValidaDados
//Tratamento e validação de dados do Json
@author  Wesley Alves Pereira
@since   19/03/2020
@version 12.1.27
@param nOpc,integer, 3 = Insert; 4 = Upsert
@param json,object, variável de objeto que contém os dados de json
@return lRet, logical, variável que verifica se ocorreu erro ou não
/*/
Static Function fValidaDados(nOpc,json)
Local aNames	As Array //array de nomes das propriedades
Local aCpoObt	As Array
Local cMsgRest	As Character //Mensagem de erro
Local nItem		As Numeric //Posição do item para varredura
Local ctmpCia   As Character 
Local ctmpfil   As Character
Local ctmpDIn   As Character
Local ctmpHrI   As Character
Local ctmpHrF   As Character
Local dTmpDIn
Local cTmpTip   As Character  
Local aCode     as ARRAY
Local aFunc     as ARRAY
Local cAllowEmpty := "ENDDATE/INTERNATIONALDISEASECLASSIFICATION" // devem ser informados, ainda que vazios
	
Local lResult	As Logical //Retorno lógico de erro ou sucesso.
Default json := JsonObject():New()
Default nOpc := 3

cCpoObt := ""	
cCpoObt += "companyId/"
cCpoObt += "branchId/"
cCpoObt += "employeeId/"
cCpoObt += "startDate/"
cCpoObt += "endDate/"
cCpoObt += "leaveOfAbsenceCode/"
cCpoObt += "classEntityRegistrationCode/"
cCpoObt += "doctorName/"
cCpoObt += "classEntityState/"
cCpoObt += "classEntity/"

lResult	:= .T. 

aNames		:= json:GetNames()
aCpoObt		:= StrToArray(cCpoObt,"/") 
cMsgRest	:= ""
If ( nOpc <> 4 )
	//Verifica TAGS obrigatórias	
	For nItem:= 1 to Len(aCpoObt)
		If aScan(aNames,{|x| UPPER(x) == UPPER(aCpoObt[nItem])})== 0
			cMsgRest+=  OemToAnsi(STR0007)+ aCpoObt[nItem] +OemToAnsi(STR0008) + CRLF //"Verifique se a TAG ("") foi informada, pois ela é obrigatória para a manipulação deste processo."
		EndIf
	Next nItem
	If !Empty(cMsgRest)
		lResult:= .F.
		fSendMess(400,cMsgRest,.T.,400,STR0015,,) 
		return (lResult)
	EndIf
EndIf

If ( nOpc <> 4 )
	//Verifica TAGS preenchidas
	For nItem:= 1 to Len(aNames)
		If aScan(aCpoObt,{|x| UPPER(x) == UPPER(aNames[nItem])}) > 0
			If !(UPPER(aNames[nItem]) $ cAllowEmpty)
				If (json[aNames[nItem]]== NIL .Or. Empty(json[aNames[nItem]]))
					cMsgRest+=  OemToAnsi(STR0010)+ aNames[nItem] +OemToAnsi(STR0008) + CRLF//"Verifique se a TAG ("") foi informada, pois ela é obrigatória para a manipulação deste processo."
				Endif
			EndIf
		EndIf 
	Next nItem
	If !Empty(cMsgRest)
		lResult:= .F.
		fSendMess(400,cMsgRest,.T.,400,STR0015,,) 
		return (lResult)
	EndIf
EndIf

aCode := {}
aFunc := {}

For nItem:= 1 to Len(aNames)
	If UPPER(aNames[nItem]) $ "COMPANYID"
		ctmpCia := json[aNames[nItem]]
	ElseIf UPPER(aNames[nItem]) =="BRANCHID" 
		ctmpFil := json[aNames[nItem]]
	ElseIf UPPER(aNames[nItem]) $ "EMPLOYEEID" 
		If !Empty(json[aNames[nItem]])                                                                                             
			aFunc = StrTokArr2(json[aNames[nItem]],"|",.T.) 
		EndIf
	ElseIf UPPER(aNames[nItem]) $ "LEAVEOFABSENCECODE" 
		If !Empty(json[aNames[nItem]])                                                                                             
			aCode = StrTokArr2(json[aNames[nItem]],"|",.T.) 
		EndIf
	ElseIf UPPER(aNames[nItem]) $ "STARTDATE" 
		If !Empty(json[aNames[nItem]])                                                                                             
			ctmpDIn = json[aNames[nItem]] 
		EndIf
	ElseIf UPPER(aNames[nItem]) $ "STARTTIME" 
		If !Empty(json[aNames[nItem]])                                                                                             
			ctmpHrI = json[aNames[nItem]] 
		EndIf
	ElseIf UPPER(aNames[nItem]) $ "ENDTIME" 
		If !Empty(json[aNames[nItem]])                                                                                             
			ctmpHrF = json[aNames[nItem]]
		EndIf
	ElseIf UPPER(aNames[nItem]) $ "CLASSENTITY" 
		If !Empty(json[aNames[nItem]])                                                                                             
			ctmpTip = json[aNames[nItem]]
		EndIf
	EndIf
Next nItem

//Validação de Tipo
If !Empty(ctmpTip)
	If ! ( Len(ctmpTip) == 1 .AND. (ctmpTip $ "123"))
		cMsgRest+= OemToAnsi(STR0010) +"classEntity"+ OemToAnsi(STR0013) + CRLF //"Verifique o conteúdo da TAG () pois a informação está diferente do formato correto: 1 ou 2 ou 3"
		lResult:= .F.
		fsendMess(400,cMsgRest,.T.,400,STR0015,,) 
		return (lResult)
	EndIf
EndIf

//Validação de Datas
If !Empty(ctmpDIn)
	dTmpDIn := fClearDate(ctmpDIn)
	If Empty(dTmpDIn)
		cMsgRest+= OemToAnsi(STR0010) +"startDate"+ OemToAnsi(STR0018) + CRLF //"Verifique o conteúdo da TAG () pois está diferente do formado esperado: (yyyy-mm-ddThh:mm:ss)."
		lResult:= .F.
		fsendMess(400,cMsgRest,.T.,400,STR0015,,) 
		return (lResult)
	EndIf
EndIf

// Formato Considerado como válido: "HH:MM"
//Verifica Hora Inicial
	If !Empty(ctmpHrI)
		If  SubStr(ctmpHrI, 3,  1) != ":"
			cMsgRest+= OemToAnsi(STR0010) +"startTime" + OemToAnsi(STR0016) + CRLF //"Verifique o conteúdo da TAG () pois a hora não está no formato correto: 'HH:MM'""
		ElseIf Len (ctmpHrI) <> 5
			cMsgRest+= OemToAnsi(STR0010) +"startTime" + OemToAnsi(STR0016) + CRLF //"Verifique o conteúdo da TAG () pois a hora não está no formato correto: 'HH:MM'""
		ElseIf ! ( ( SubStr(ctmpHrI, 1,  1) $ "0123456789") .AND. ( SubStr(ctmpHrI, 2,  1) $ "0123456789") .AND. ( SubStr(ctmpHrI, 4,  1) $ "0123456789") .AND. ( SubStr(ctmpHrI, 5,  1) $ "0123456789") )
			cMsgRest+= OemToAnsi(STR0010) +"startTime" + OemToAnsi(STR0016) + CRLF //"Verifique o conteúdo da TAG () pois a hora não está no formato correto: 'HH:MM'""
		EndIf	
	EndIf
//Verifica Hora Final
	If !Empty(ctmpHrF)
		If  SubStr(ctmpHrF, 3,  1) != ":"
			cMsgRest+= OemToAnsi(STR0010) +"endTime" + OemToAnsi(STR0016) + CRLF //"Verifique o conteúdo da TAG () pois a hora não está no formato correto: 'HH:MM'""
		ElseIf Len (ctmpHrF) <> 5
			cMsgRest+= OemToAnsi(STR0010) +"endTime" + OemToAnsi(STR0016) + CRLF //"Verifique o conteúdo da TAG () pois a hora não está no formato correto: 'HH:MM'""
		ElseIf ! ( ( SubStr(ctmpHrI, 1,  1) $ "0123456789") .AND. ( SubStr(ctmpHrI, 2,  1) $ "0123456789") .AND. ( SubStr(ctmpHrI, 4,  1) $ "0123456789") .AND. ( SubStr(ctmpHrI, 5,  1) $ "0123456789") )
			cMsgRest+= OemToAnsi(STR0010) +"startTime" + OemToAnsi(STR0016) + CRLF //"Verifique o conteúdo da TAG () pois a hora não está no formato correto: 'HH:MM'""
		EndIf	
	EndIf	

If ( nOpc <> 4 )
	//Verifica Empresa/Filial
	If ! FWFilExist(ctmpCia,ctmpFil)
		cMsgRest+= OemToAnsi(STR0010) +"companyId + branchId "+ OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
		lResult:= .F.
		fsendMess(400,cMsgRest,.T.,400,STR0015,,) 
		return (lResult)
	EndIf
EndIf

If ( nOpc <> 4 )
	//Verifica Funcionario
	If ( Len (aFunc) <> 3)
		cMsgRest+= OemToAnsi(STR0010) +"employeeId" + OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
	else
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA ctmpCia FILIAL ctmpFil TABLES "SRA" MODULO "GPE"
		DBSelectArea("SRA")
		DBSetOrder(1)
		If ! DBseek (aFunc[2]+aFunc[3])
			cMsgRest+= OemToAnsi(STR0010) +"employeeId" + OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
		Endif
	Endif	
Else
	If ( Len (aFunc) == 3)
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA ctmpCia FILIAL ctmpFil TABLES "SRA" MODULO "GPE"
		DBSelectArea("SRA")
		DBSetOrder(1)
		If ! DBseek (aFunc[2]+aFunc[3])
			cMsgRest+= OemToAnsi(STR0010) +"employeeId" + OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
		Endif
	Endif	
EndIf

//Verifica Codigo de Afastamento
If ( nOpc <> 4 )
	If ( Len (aCode) <> 3)
		cMsgRest+= OemToAnsi(STR0010) +"leaveOfAbsenceCode" + OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
	else
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA ctmpCia FILIAL ctmpFil TABLES "RCM" MODULO "GPE"
		DBSelectArea("RCM")
		DBSetOrder(1)
		If ! DBseek (aCode[2]+aCode[3])
			cMsgRest+= OemToAnsi(STR0010) +"leaveOfAbsenceCode" + OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
		Endif
	EndIf
Else
	If ( Len (aCode) == 3)
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA ctmpCia FILIAL ctmpFil TABLES "RCM" MODULO "GPE"
		DBSelectArea("RCM")
		DBSetOrder(1)
		If ! DBseek (aCode[2]+aCode[3])
			cMsgRest+= OemToAnsi(STR0010) +"leaveOfAbsenceCode" + OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
		Endif
	EndIf
EndIf

If !Empty(cMsgRest)
	lResult:= .F.
	fsendMess(400,cMsgRest,.T.,400,STR0015,,) 
EndIf 	

Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} function fCompress
Compacta os dados do retorno solicitado
@author  Wesley Alves Pereira
@since   12/03/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fCompress(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.
	
	// Set gzip format to Json Object
	cJson := FWJsonSerialize(oObj,.T.,.T.)

	If Type("::GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )
		lCompact := .T.
	EndIf
	
	If(lCompact)
		::SetHeader('Content-Encoding','gzip')
		GzStrComp(cJson, @cComp, @nLenComp )
	Else
		cComp := cJson
	Endif

Return cComp

/*/{Protheus.doc} fValidaChave
//Tratamento e validação de dados do Json
@author  Wesley Alves Pereira
@since   19/03/2020
@version 12.1.27
@param json,object, variável de objeto que contém os dados de json
@return lRet, logical, variável que verifica se ocorreu erro ou não
/*/
Static Function fValidaChave(cChave)
Local aTemp := {}
Local aReto := {}
Local aErro := {}
Local aFunc := {}
Local aCode := {}
Local dTmpDIn
Local dTmpDFn

//leaveOfAbsenceId = companyId;branchId;employeeId;startDate;startTime;endDate;leaveOfAbsenceCode

aTemp := StrTokArr2(cChave,";",.T.)

If Len(aTemp) < 7
	return (aErro)
EndIf

aFunc :=  StrTokArr2(aTemp[3],"|",.T.)

If Len(aFunc) <> 3
	return (aErro)
EndIf

aCode :=  StrTokArr2(aTemp[7],"|",.T.)

If Len(aCode) <> 3
	return (aErro)
EndIf

aReto := { 	aTemp[1],; //companyId
			aTemp[2],; //branchId
			aFunc[1],; //companyemployee
			aFunc[2],; //branchemployee
			aFunc[3],; //employeeId
			aCode[1],; //companyleaveOfAbsenceCode
			aCode[2],; //branchleaveOfAbsenceCode
			aCode[3],; //leaveOfAbsenceCode
			aTemp[4],; //startDate
			aTemp[5],; //startTime
			aTemp[6],; //endDate
		 }

//Verifica Empresa/Filial
If Empty(FWSM0Util():GetSM0Data(aReto[1],aReto[2],{"M0_CODFIL","M0_FILIAL"}))
	return (aErro)
EndIf

//Verifica Data Inicial
If !Empty(aReto[9])
	dTmpDIn := fClearDate(aReto[9])
	If Empty(dTmpDIn)
		return (aErro)
	EndIf
EndIf

//Verifica Data Final
If !Empty(aReto[11])
	dTmpDFn := fClearDate(aReto[11])
	If Empty(dTmpDFn)
		return (aErro)
	EndIf
EndIf

RESET ENVIRONMENT
RPCSetType(3)
PREPARE ENVIRONMENT EMPRESA aReto[1] FILIAL aReto[2] TABLES "SRA" MODULO "GPE"

//Verifica Funcionario
DBSelectArea("SRA")
DBSetOrder(1)
If ! DBseek (aFunc[2]+aFunc[3])
	return (aErro)
Endif

//Verifica Afastamento
DBSelectArea("RCM")
DBSetOrder(1)
If !DbSeek(PADR(aCode[2],Len(aReto[4])) + aCode[3])
	return (aErro)
Endif

Return (aReto)

/*/{Protheus.doc} function ValideDate
Clean especial character from Date Input. Input Format: 2012-04-23T18:25:43
@author  Wesley Alves Pereira
@since   02/05/2019
@version 12.1.23
/*/
Static Function fClearDate(cDate)
Local dData := STOD("")
	
	If !Empty(cDate)
		cDate := StrTran(cDate, "T", "")
		cDate := StrTran(cDate, ":", "")
		cDate := StrTran(cDate, "-", "")
		cDate := SubStr(cDate,1,8)
		dData := StoD(cDate)
	EndIf
	
Return ( dData )

/*/{Protheus.doc} function prepInfoR8
Prepara as informações recebidas na API
@author  martins.marcio
@since   28/07/2022
@version 12.1.33
/*/
Static Function prepInfoR8(json, cParEmp, cParFil, aParFun, aParAfa, cIniData, cFinData, cNomMed, cEstMed, cTipMed, cCRMMed, cDoeMed, cContAfa)

	Local nItem
	Local cParFun	:= ""
	Local cParAfa	:= ""
	Local cSequence	:= ""
	Local aCampos	:= {}

	Default json	:= ""
	Default cParEmp	:= ""
	Default cParFil	:= ""
	Default aParFun	:= {}
	Default aParAfa	:= {}
	Default cIniData := ""
	Default cFinData := ""
	Default cNomMed := ""
	Default cEstMed := ""
	Default cTipMed := ""
	Default cCRMMed := ""
	Default cDoeMed := ""
	Default cContAfa := ""

	If ValType(json) == "J"
		aCampos := json:GetNames()
		For nItem := 1 to Len(aCampos)			
			If UPPER(aCampos[nItem]) == "COMPANYID"
				cParEmp := json[aCampos[nItem]]		
			ElseIf UPPER(aCampos[nItem]) == "BRANCHID" 
				cParFil := json[aCampos[nItem]]
			ElseIf UPPER(aCampos[nItem]) == "EMPLOYEEID" 
				cParFun := json[aCampos[nItem]]
				aParFun := StrTokArr2(cParFun,"|",.T.) 
			ElseIf UPPER(aCampos[nItem]) == "LEAVEOFABSENCECODE" 
				cParAfa := json[aCampos[nItem]]
				aParAfa := StrTokArr2(cParAfa,"|",.T.) 
			ElseIf UPPER(aCampos[nItem]) == "STARTDATE" 
				cIniData := json[aCampos[nItem]]
			ElseIf UPPER(aCampos[nItem]) == "ENDDATE" 
				cFinData := If( Empty(json[aCampos[nItem]]), "", json[aCampos[nItem]] ) //caso venha null
			ElseIf UPPER(aCampos[nItem]) == "DOCTORNAME" 
				cNomMed := json[aCampos[nItem]]
			ElseIf UPPER(aCampos[nItem]) == "CLASSENTITYSTATE" 
				cEstMed := json[aCampos[nItem]]
			ElseIf UPPER(aCampos[nItem]) == "CLASSENTITY" 
				cTipMed := json[aCampos[nItem]]
			ElseIf UPPER(aCampos[nItem]) == "CLASSENTITYREGISTRATIONCODE" 
				cCRMMed := json[aCampos[nItem]]
			ElseIf UPPER(aCampos[nItem]) == "INTERNATIONALDISEASECLASSIFICATION" 
				cDoeMed := json[aCampos[nItem]]
			ElseIf UPPER(aCampos[nItem]) == "SEQUENCE" 
				cSequence := json[aCampos[nItem]]
				cContAfa  := getSeqAfa(cSequence)
			EndIf		
		Next nItem
	EndIf

Return

/*/{Protheus.doc} function getSeqAfa
Retorna a sequencia do afastamento
@author  martins.marcio
@since   26/07/2022
@version 12.1.33
/*/
Static Function getSeqAfa(cSequence)
	Local aArea		:= GetArea()
	Local aChave	:= {}
	Local cFilR8	:= ""
	Local cMatR8	:= ""
	Local cDtIni	:= ""
	Local cTpAfa	:= ""
	Local cSeqAfa	:= ""

	Default cSequence := ""

	aChave	:= IIf(!Empty(cSequence), StrTokArr2(cSequence,";",.T.), {})
	If Len(aChave) >= 7
		cFilR8	:= aChave[2]
		cMatR8	:= IIf(Len(StrTokArr2(aChave[3],"|",.T.)) >=3, StrTokArr2(aChave[3],"|",.T.)[3], "")
		cDtIni	:= DtoS(fClearDate(aChave[4]))
		cTpAfa	:= StrTokArr2(aChave[7],"|",.T.)[3]

		DbSelectArea("SR8")
		DbSetOrder(6) //R8_FILIAL+R8_MAT+DTOS(R8_DATAINI)+R8_TIPOAFA+STR(R8_DIASEMP)                                                                                                    
		If DbSeek(cFilR8 + cMatR8 + cDtIni + cTpAfa)
			cSeqAfa := SR8->R8_SEQ
		Endif
	Endif

	RestArea(aArea)
Return cSeqAfa
