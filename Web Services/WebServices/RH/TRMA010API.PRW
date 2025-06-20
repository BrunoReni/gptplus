#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TRMA010API.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"

#include 'FIVEWIN.CH'
#include 'PROTHEUS.CH'
#Include 'FWMVCDef.ch'
#include "fileio.ch"
#INCLUDE "TBICODE.CH"

#DEFINE TAB CHR ( 13 ) + CHR ( 10 )

/*
{Protheus.doc} trainingNecessity
API de Controle de Necessidade de Treinamentos                              
@author  Wesley Alves Pereira
@since   19/03/2020
@version 12.1.27
*/

WSRESTFUL trainingNecessity DESCRIPTION STR0001 FORMAT "application/json" //"Servi�o gen�rico para retorno das informa��es de Necessidade de Treinamento"
WSDATA trainingNecessityId As Character

WSMETHOD POST; 	
DESCRIPTION EncodeUTF8(OemToAnsi(STR0002)); // "Insere uma solicita��o de treinamento no m�dulo de Treinamento"
WSSYNTAX "/api/rh/v1/trainingNecessity" ;
PATH "/api/rh/v1/trainingNecessity" ;
PRODUCES 'application/json;charset=utf-8'; 
TTALK "v1" 

WSMETHOD PUT trainingNecessityId ;
DESCRIPTION EncodeUTF8(OemToAnsi(STR0004)) ; 
WSSYNTAX "/api/rh/v1/trainingNecessity/{trainingNecessityId}" ; //"Altera uma solicita��o de treinamento no m�dulo de Treinamento"
PATH "/api/rh/v1/trainingNecessity/{trainingNecessityId}" ;
PRODUCES 'application/json;charset=utf-8' ;
TTALK "v1"

WSMETHOD DELETE trainingNecessityId ;
DESCRIPTION EncodeUTF8(OemToAnsi(STR0003)) ; //"Exclui uma solicita��o de treinamento no m�dulo de Treinamento"
WSSYNTAX "/api/rh/v1/trainingNecessity/{trainingNecessityId}" ;
PATH "/api/rh/v1/trainingNecessity/{trainingNecessityId}" ;
PRODUCES 'application/json;charset=utf-8' ;
TTALK "v1"

END WSRESTFUL

// Insere uma solicita��o de treinamento dentro do m�dulo de Treinamento
/*/{Protheus.doc} POST
 TODO M�todo respons�vel pela inclus�o de um registro de necessidade de treinamento com valores passados como param�tro no Header do REST/JSON
@author  Wesley Alves Pereira
@since   19/03/2020
@version 12.1.27
@return return, return_description
/*/

WSMETHOD POST HEADERPARAM authorization WSREST trainingNecessity 

Local json as OBJECT
Local cBody As Character
Local cRecebe As Character
Local lRetorno as Logical
Local nItem := 0
Local cRetorno := ""
Local cId As Character 
Local cParEmp As Character
Local cParFil As Character
Local cParFun As Character
Local cParCod As Character
Local aParFun := {}
Local aParCod := {}
Local aCampos := {}
Local aArea := {}
Local aSRAArea := {}
Local aRA1Area := {}
Local nOpca := 3
Local aRetorno := {}

BEGIN SEQUENCE

json		:= JsonObject():New()
cBody		:= Self:GetContent()
lRetorno	:= .F.
cRecebe   := json:FromJSON(EncodeUTF8(NoAcento(cBody)))
	
If cRecebe != Nil  .Or. Len(json:GetNames()) == 0  
	fSendMess(400,STR0005,.T.,400,STR0015,,) // STR0005: "N�o foi poss�vel reconhecer o pacote recebido. Verifique a informa��o e envie novamente."
	return (lRetorno)
EndIf

If (! ( fValidaDados(nOpca,@json,aRetorno)))
	return (lRetorno)
EndIf

aCampos := json:GetNames()

For nItem:= 1 to Len(aCampos)
	
	If UPPER(aCampos[nItem]) $ "COMPANYID"
		cParEmp := json[aCampos[nItem]]		
	EndIf
	
	If UPPER(aCampos[nItem]) =="BRANCHID" 
		cParFil := json[aCampos[nItem]]
	EndIf

	If UPPER(aCampos[nItem]) =="EMPLOYEEID" 
		cParFun := json[aCampos[nItem]]
		aParFun := StrTokArr2(cParFun,"|",.T.) 
	EndIf	
	
	If UPPER(aCampos[nItem]) =="TRAININGNECESSITYCODE" 
		cParCod := json[aCampos[nItem]]
		aParCod := StrTokArr2(cParCod,"|",.T.) 
	EndIf	

Next nItem

RESET ENVIRONMENT
RPCSetType(3)
PREPARE ENVIRONMENT EMPRESA cParEmp FILIAL cParFil TABLES "SRA, RA1, RA3" MODULO "TRM"

aArea := (GetArea())
aSRAArea := SRA->(GetArea())
aRA1Area := RA1->(GetArea())

DBSelectArea("RA3")
DBSetOrder(1)
If ! DBSeek(xFilial("RA3")+aParFun[3]+aParCod[3])
	If RecLock("RA3",.T.)
		RA3->RA3_FILIAL := xFilial("RA3")
		RA3->RA3_MAT    := aParFun[3]
		RA3->RA3_CURSO  := aParCod[3]
		RA3->RA3_RESERV := "S"
		RA3->RA3_DATA   := dDataBase
		
		MsUnlock()
	Else
		fSendMess(400,STR0012,.T.,400,STR0015,,) //"N�o poi poss�vel concluir esta opera��o. Verifique!"
		return (lRetorno)
	EndIf
Else
	fSendMess(400,STR0013,.T.,400,STR0015,,) //"Esta solicita��o de treinamento j� existe na base do Protheus. Verifique!"
	return (lRetorno)
EndIf

DBSelectArea("RA3")
DBSetOrder(1)
If ! DBSeek(xFilial("RA3")+aParFun[3]+aParCod[3])
	fSendMess(400,STR0012,.T.,400,STR0015,,) //"N�o poi poss�vel concluir esta opera��o. Verifique!"
	return (lRetorno)
Else
	cId := cParEmp+";"+cParFil+";"+aParFun[1]+"|"+aParFun[2]+"|"+aParFun[3]+";"+aParCod[1]+"|"+aParCod[2]+"|"+aParCod[3]
	lRetorno := .T.
	cRetorno :=  fSendJson(json,cId)
	::SetResponse(cRetorno)
	return (lRetorno)
 EndIf
	
RECOVER
	ErrorBlock(bErrorBlock)
	fSendMess(500,oError:Description,.T.,500,STR0009,,) // STR0002: "Ocorreu uma falha no retorno da informa��o."		
	lRetorno := .F.
END SEQUENCE

Return (lRetorno)

// Altera uma solicita��o de treinamento dentro do m�dulo de Treinamento
/*/{Protheus.doc} PUT
 TODO M�todo respons�vel pela altera��o de um registro de solicita�ao de treinamento com valores passados como param�tro no Header do REST/JSON
@author  Wesley Alves Pereira
@since   13/03/2020
@version 12.1.27
@return return, return_description
/*/

WSMETHOD PUT trainingNecessityId WSREST trainingNecessity

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
Local cCorEmp := ""
Local cCorFil := ""
Local cCorFun := ""
Local cCorCod := ""

Local aCorCod := {}
Local aCorFun := {}

Local aCampos := {}
Local cChave := ""
Local lRetorno := .F.
Local aRetorno := {}

Local nOpca := 4

//Variaveis do parametro
Local cEmpPar := ""
Local cFilPar := ""
Local cEmpFun := ""
Local cFilFun := ""
Local cCodFun := ""
Local cEmpTre := ""
Local cFilTre := ""
Local cCodTre := ""

Local nItem
BEGIN SEQUENCE

if Empty(aUrlParam) .OR. Len(aUrlParam) == 0
	fSendMess(400,STR0014,.T.,400,STR0015,,) //Informa��o trainingNecessityId ausente ou inv�lida."
	lRetorno := .F.
	return (lRetorno)
else 
	cChave = aUrlParam[1]
EndIf

If Empty(cChave)
	fSendMess(400,STR0014,.T.,400,STR0015,,) //Informa��o trainingNecessityId ausente ou inv�lida."
	lRetorno := .F.
	Return (lRetorno)
EndIf

aRetorno := fValidaChave(cChave)

If (Len(aRetorno) == 0)
	fSendMess(400,STR0014,.T.,400,STR0015,,) //"Informa��o trainingNecessityId ausente ou inv�lida."
	lRetorno := .F.
	Return (lRetorno)
EndIf

json		:= JsonObject():New()
cBody		:= Self:GetContent()
lRetorno	:= .F.
cRecebe   := json:FromJSON(EncodeUTF8(NoAcento(cBody)))
	
If cRecebe != Nil  .Or. Len(json:GetNames()) == 0  
	fSendMess(400,STR0005,.T.,400,STR0015,,) // STR0005: "N�o foi poss�vel reconhecer o pacote recebido. Verifique a informa��o e envie novamente."
	return (lRetorno)
EndIf

If (! ( fValidaDados(nOpca,@json,aRetorno)))
	lRetorno := .F.
	return (lRetorno)
EndIf

aCampos := json:GetNames()

For nItem:= 1 to Len(aCampos)
	
	If UPPER(aCampos[nItem]) $ "COMPANYID"
		cCorEmp := json[aCampos[nItem]]		
	EndIf
	
	If UPPER(aCampos[nItem]) =="BRANCHID" 
		cCorFil := json[aCampos[nItem]]
	EndIf

	If UPPER(aCampos[nItem]) =="EMPLOYEEID" 
		cCorFun := json[aCampos[nItem]]
		aCorFun := StrTokArr2(cCorFun,"|",.T.) 
	EndIf	
	
	If UPPER(aCampos[nItem]) =="TRAININGNECESSITYCODE" 
		cCorCod := json[aCampos[nItem]]
		aCorCod := StrTokArr2(cCorCod,"|",.T.) 
	EndIf
	
Next nItem

cEmpPar := aRetorno[1]
cFilPar := aRetorno[2]
cEmpFun := aRetorno[3]
cFilFun := aRetorno[4]
cCodFun := aRetorno[5]
cEmpTre := aRetorno[6]
cFilTre := aRetorno[7]
cCodTre := aRetorno[8]

If (Empty(cCorEmp))
	cCorEmp = cEmpPar
EndIf
If (Empty(cCorFil))
	cCorFil = cFilPar
EndIf
If (Empty(aCorFun))
	aCorFun = {cEmpFun,cCodFun,cCodFun}
EndIf
If (Empty(aCorCod))
	aCorCod = {cEmpTre,cFilTre,cCodTre}
EndIf

RESET ENVIRONMENT
RPCSetType(3)
PREPARE ENVIRONMENT EMPRESA cEmpPar FILIAL cFilPar TABLES "SRA, RA1, RF0" MODULO "TRM"

aArea := (GetArea())
aSRAArea := SRA->(GetArea())
aRA1Area := RA1->(GetArea())

DBSelectArea("RA3")
DBSetOrder(1)
If ! DBSeek(xFilial("RA3")+cCodFun+cCodTre)
	fSendMess(400,STR0015,.T.,400,STR0016) // "Erro na TAG trainingNecessityId. Verifique o conte�do das chaves informadas."
	return (lRetorno)
EndIf

DBSelectArea("RA3")
DBSetOrder(1)
If DBSeek(xFilial("RA3")+cCodFun+aCorCod[3])
	fSendMess(400,STR0013,.T.,400,STR0015,,) //"Esta solicita��o de treinamento j� existe na base do Protheus. Verifique!"
	return (lRetorno)
EndIf

DBSelectArea("RA3")
DBSetOrder(1)
If DBSeek(xFilial("RA3")+cCodFun+cCodTre)
	If RecLock("RA3",.F.)
		RA3->RA3_CURSO  := aCorCod[3]
		RA3->RA3_RESERV := "S"
		RA3->RA3_DATA   := dDataBase
		
		MsUnlock()
	Else
		fSendMess(400,STR0012,.T.,400,STR0015,,) //"N�o poi poss�vel concluir esta opera��o. Verifique!"
		return (lRetorno)
	EndIf
EndIf

DBSelectArea("RA3")
DBSetOrder(1)
If ! DBSeek(xFilial("RA3")+cCodFun+aCorCod[3])
	fSendMess(400,STR0012,.T.,400,STR0015,,) //"N�o poi poss�vel concluir esta opera��o. Verifique!"
	return (lRetorno)
Else
	cId := cEmpPar+";"+cFilPar+";"+cEmpFun+"|"+cFilFun+"|"+cCodFun+";"+aCorCod[1]+"|"+aCorCod[2]+"|"+aCorCod[3]
	lRetorno := .T.
	cRetorno :=  fSendJson(json,cId)
	::SetResponse(cRetorno)
	return (lRetorno)
 EndIf
	
RECOVER
	ErrorBlock(bErrorBlock)
	fSendMess(500,oError:Description,.T.,500,STR0009,,) // STR0002: "Ocorreu uma falha no retorno da informa��o."		
	lRetorno := .F.
END SEQUENCE

Return (lRetorno)


//Deleta uma solicita��o de treinamento dentro do m�dulo de Treinamento
/*/{Protheus.doc} DELETE
 TODO M�todo respons�vel pela exclus�o de um registro de solicita��o de treinamento com valores passados como param�tro no Header do REST/JSON
@author  Wesley Alves Pereira
@since   19/03/2020
@version 12.1.27
@return return, return_description
/*/
WSMETHOD DELETE trainingNecessityId WSREST trainingNecessity
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
Local cDatPar := ""
Local cHorPar := ""
Local cEmpFun := ""
Local cFilFun := ""
Local cCodFun := ""
Local cEmpTre := ""
Local cFilTre := ""
Local cCodTre := ""

Local nItem

BEGIN SEQUENCE

if Empty(aUrlParam) .OR. Len(aUrlParam) == 0
	fSendMess(400,STR0014,.T.,400,STR0015,,) //Informa��o trainingNecessityId ausente ou inv�lida."
	lRetorno := .F.
	return (lRetorno)
else 
	cChave = aUrlParam[1]
EndIf

If Empty(cChave)
	fSendMess(400,STR0014,.T.,400,STR0015,,) //"Informa��o trainingNecessityId ausente ou inv�lida."
	lRetorno := .F.
	Return (lRetorno)
EndIf

aRetorno := fValidaChave(cChave)

If (Len(aRetorno) == 0)
	fSendMess(400,STR0014,.T.,400,STR0015,,) //"Informa��o trainingNecessityId ausente ou inv�lida."
	lRetorno := .F.
	Return (lRetorno)
EndIf

cEmpPar := aRetorno[1]
cFilPar := aRetorno[2]
cEmpFun := aRetorno[3]
cFilFun := aRetorno[4]
cCodFun := aRetorno[5]
cEmpTre := aRetorno[6]
cFilTre := aRetorno[7]
cCodTre := aRetorno[8]

RESET ENVIRONMENT
RPCSetType(3)
PREPARE ENVIRONMENT EMPRESA cEmpPar FILIAL cFilPar TABLES "SRA, RA1, RF0" MODULO "TRM"

aArea := (GetArea())
aSRAArea := SRA->(GetArea())
aRA1Area := RA1->(GetArea())

DBSelectArea("RA3")
DBSetOrder(1)
If ! DBSeek(xFilial("RA3")+cCodFun+cCodTre)
	fSendMess(400,STR0015,.T.,400,STR0016) // "Erro na TAG trainingNecessityId. Verifique o conte�do das chaves informadas."
	return (lRetorno)
EndIf

DBSelectArea("RA3")
DBSetOrder(1)
If DBSeek(xFilial("RA3")+cCodFun+cCodTre)
	If RecLock("RA3",.F.)
		DBDelete()
		MsUnlock()
	Else
		fSendMess(400,STR0012,.T.,400,STR0015,,) //"N�o poi poss�vel concluir esta opera��o. Verifique!"
		return (lRetorno)
	EndIf
EndIf

DBSelectArea("RA3")
DBSetOrder(1)
If DBSeek(xFilial("RA3")+cCodFun+cCodTre)
	fSendMess(400,STR0012,.T.,400,STR0015,,) //"N�o poi poss�vel concluir esta opera��o. Verifique!"
	return (lRetorno)
Else
	lRetorno := .T.
	cRetorno :=  fSendDelete(STR0017) //"Opera��o realizada com sucesso!"
	::SetResponse(cRetorno)
	return (lRetorno)
 EndIf
	
RECOVER
	ErrorBlock(bErrorBlock)
	fSendMess(500,oError:Description,.T.,500,STR0009,,) // STR0002: "Ocorreu uma falha no retorno da informa��o."		
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


/*
oMsgReturn["type"]       := ""
oMsgReturn["code"]       := "200"
oMsgReturn["id"]         := cid
oMsgReturn["detail"]     := EncodeUTF8(cMessage) //"Atualiza��o realizada com sucesso"
aMessages := {}
Aadd(aMessages, oMsgReturn)
oItem["data"] 		  := ojson
oItem["messages"] 	  := aMessages
oItem["length"]   	  := 1 

If(lCompact)    	
	cJson := fCompress(oItem)				
Else
	cJson :=  FWJsonSerialize(oItem, .F., .F., .T.)   	
Endif
*/
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
oMsgReturn["description"] := cMessage

If(lCompact)    	
	cJson := fCompress(oMsgReturn)				
Else
	cJson :=  FWJsonSerialize(oMsgReturn, .F., .F., .T.)   	
Endif

Return (cJson)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendPut
Gera as mensagens para o retorno REST/JSON
@author  Wesley Alves Pereira
@since  12/03/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fSendPut(cMessage,oJson)
Local cJsonObj := "JsonObject():New()"
Local oMsgReturn	:= &cJsonObj
Local cJson			:= ""
Local lcompact := .F.

If Type("Self:GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(Self:GetHeader('Accept-Encoding') )        
	lCompact := .T.
EndIf

oMsgReturn["code"] 		:= "200"
oMsgReturn["description"] := cMessage

If(lCompact)    	
	cJson := fCompress(oMsgReturn)				
Else
	cJson :=  FWJsonSerialize(oMsgReturn, .F., .F., .T.)   	
Endif

Return (cJson)

/*/{Protheus.doc} fValidaDados
//Tratamento e valida��o de dados do Json
@author  Wesley Alves Pereira
@since   19/03/2020
@version 12.1.27
@param nOpc,integer, 3 = Insert; 4 = Upsert
@param json,object, vari�vel de objeto que cont�m os dados de json
@return lRet, logical, vari�vel que verifica se ocorreu erro ou n�o
/*/
Static Function fValidaDados(nOpc,json,aRetorno)
Local aNames	As Array //array de nomes das propriedades
Local aCpoObt	As Array
Local cMsgRest	As Character //Mensagem de erro
Local nItem		As Integer //Posi��o do item para varredura
Local ctmpCia   := "" 
Local ctmpfil   := ""
Local aCode     := {}
Local aFunc     := {}
	
Local lResult	As Logical //Retorno l�gico de erro ou sucesso.
Default json := JsonObject():New()
Default nOpc := 3

cCpoObt	:= "companyId/branchId/employeeId/trainingNecessityCode/"
lResult	:= .T. 

aNames		:= json:GetNames()
aCpoObt		:= StrToArray(cCpoObt,"/") 
cMsgRest	:= ""
If ( nOpc <> 4 )
	//Verifica TAGS obrigat�rias	
	For nItem:= 1 to Len(aCpoObt)
		If aScan(aNames,{|x| UPPER(x) == UPPER(aCpoObt[nItem])})== 0
			cMsgRest+=  OemToAnsi(STR0007)+ aCpoObt[nItem] +OemToAnsi(STR0008) + CRLF //"Verifique se a TAG ("") foi informada, pois ela � obrigat�ria para manipula��o do registro de solicita��o de treinamento."
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
		if aScan(aCpoObt,{|x| UPPER(x) == UPPER(aNames[nItem])}) > 0
			If (json[aNames[nItem]]== NIL .Or. Empty(json[aNames[nItem]]))
				cMsgRest+=  OemToAnsi(STR0010)+ aNames[nItem] +OemToAnsi(STR0008) + CRLF//"Verifique se a TAG ("") foi informada, pois ela � obrigat�ria para manipula��o do registro de solicita��o de treinamento."
			Endif
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
	ElseIf UPPER(aNames[nItem]) $ "TRAININGNECESSITYCODE" 
		If !Empty(json[aNames[nItem]])                                                                                             
			aCode = StrTokArr2(json[aNames[nItem]],"|",.T.) 
		EndIf
	EndIf
Next nItem

If nOpc == 4
	
	If len(aRetorno) > 1

		If (empty(ctmpCia))
			ctmpCia = aRetorno[1]
		EndIf

		If (empty(ctmpFil))
			ctmpFil = aRetorno[2]
		EndIf

	EndIf

EndIf

//Verifica Empresa/Filial
If ! FWFilExist(ctmpCia,ctmpFil)
	cMsgRest+= OemToAnsi(STR0010) +"companyId + branchId "+ OemToAnsi(STR0011) + CRLF //"Verifique o conte�do da TAG () pois n�o foi poss�vel encontrar esta informa��o no Protheus."
	lResult:= .F.
	fsendMess(400,cMsgRest,.T.,400,STR0015,,) 
	return (lResult)
EndIf

//Verifica Funcionario
If ( nOpc <> 4 )	
	If ( Len (aFunc) <> 3)
		cMsgRest+= OemToAnsi(STR0010) +"employeeId" + OemToAnsi(STR0011) + CRLF //"Verifique o conte�do da TAG () pois n�o foi poss�vel encontrar esta informa��o no Protheus."
	else
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA ctmpCia FILIAL ctmpFil TABLES "SRA" MODULO "TRM"
		
		If ! ( ExistCpo("SRA", aFunc[3]))
			cMsgRest+= OemToAnsi(STR0010) +"employeeId" + OemToAnsi(STR0011) + CRLF //"Verifique o conte�do da TAG () pois n�o foi poss�vel encontrar esta informa��o no Protheus."
		Else
		
			DBSelectArea("SRA")
			DBSetOrder(1)
			If ! DBseek (aFunc[2]+aFunc[3])
				cMsgRest+= OemToAnsi(STR0010) +"employeeId" + OemToAnsi(STR0011) + CRLF //"Verifique o conte�do da TAG () pois n�o foi poss�vel encontrar esta informa��o no Protheus."
			Endif
		EndIf

	Endif	
Else
	If ! Empty(aFunc)
		If Len(aFunc) == 3
			RESET ENVIRONMENT
			RPCSetType(3)
			PREPARE ENVIRONMENT EMPRESA ctmpCia FILIAL ctmpFil TABLES "SRA" MODULO "TRM"
		
			If ! ( ExistCpo("SRA", aFunc[3]))
				cMsgRest+= OemToAnsi(STR0010) +"employeeId" + OemToAnsi(STR0011) + CRLF //"Verifique o conte�do da TAG () pois n�o foi poss�vel encontrar esta informa��o no Protheus."
			Else
		
				DBSelectArea("SRA")
				DBSetOrder(1)
				If ! DBseek (aFunc[2]+aFunc[3])
					cMsgRest+= OemToAnsi(STR0010) +"employeeId" + OemToAnsi(STR0011) + CRLF //"Verifique o conte�do da TAG () pois n�o foi poss�vel encontrar esta informa��o no Protheus."
				Endif
			EndIf
		Else
			cMsgRest+= OemToAnsi(STR0010) +"employeeId" + OemToAnsi(STR0011) + CRLF //"Verifique o conte�do da TAG () pois n�o foi poss�vel encontrar esta informa��o no Protheus."
		Endif
	EndIf	
EndIf

//Verifica Codigo do Curso
If ( nOpc <> 4 )
	If ( Len (aCode) <> 3)
		cMsgRest+= OemToAnsi(STR0010) +"trainingNecessityCode" + OemToAnsi(STR0011) + CRLF //"Verifique o conte�do da TAG () pois n�o foi poss�vel encontrar esta informa��o no Protheus."
	Else
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA ctmpCia FILIAL ctmpFil TABLES "RA1" MODULO "TRM"
		
		If ! ( ExistCpo("RA1", aCode[3]))
			cMsgRest+= OemToAnsi(STR0010) +"trainingNecessityCode" + OemToAnsi(STR0011) + CRLF //"Verifique o conte�do da TAG () pois n�o foi poss�vel encontrar esta informa��o no Protheus."
		Else

			DBSelectArea("RA1")
			DBSetOrder(1)
			If ! DBseek (aCode[2]+aCode[3])
				cMsgRest+= OemToAnsi(STR0010) +"trainingNecessityCode" + OemToAnsi(STR0011) + CRLF //"Verifique o conte�do da TAG () pois n�o foi poss�vel encontrar esta informa��o no Protheus."
			Endif
		EndIf
	
	EndIf
Else
	If ! Empty(aCode)
		If Len(aCode) == 3
			RESET ENVIRONMENT
			RPCSetType(3)
			PREPARE ENVIRONMENT EMPRESA ctmpCia FILIAL ctmpFil TABLES "RA1" MODULO "TRM"
			
			If ! ( ExistCpo("RA1", aCode[3]))
				cMsgRest+= OemToAnsi(STR0010) +"trainingNecessityCode" + OemToAnsi(STR0011) + CRLF //"Verifique o conte�do da TAG () pois n�o foi poss�vel encontrar esta informa��o no Protheus."
			Else

				DBSelectArea("RA1")
				DBSetOrder(1)
				If ! DBseek (aCode[2]+aCode[3])
					cMsgRest+= OemToAnsi(STR0010) +"trainingNecessityCode" + OemToAnsi(STR0011) + CRLF //"Verifique o conte�do da TAG () pois n�o foi poss�vel encontrar esta informa��o no Protheus."
				Endif
			EndIf
		Else
			cMsgRest+= OemToAnsi(STR0010) +"trainingNecessityCode" + OemToAnsi(STR0011) + CRLF //"Verifique o conte�do da TAG () pois n�o foi poss�vel encontrar esta informa��o no Protheus."
		EndIf
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
//Tratamento e valida��o de dados do Json
@author  Wesley Alves Pereira
@since   19/03/2020
@version 12.1.27
@param json,object, vari�vel de objeto que cont�m os dados de json
@return lRet, logical, vari�vel que verifica se ocorreu erro ou n�o
/*/
Static Function fValidaChave(cChave)
Local aTemp := {}
Local aErro := {}
Local aReto := {}
Local aFunc := {}
Local aCode := {}

aTemp := StrTokArr2(cChave,";",.T.)

If ( Len(aTemp) < 4)
	return (aErro)
EndIf

aFunc := StrTokArr2(aTemp[3],"|",.T.)

aCode := StrTokArr2(aTemp[4],"|",.T.)

If ( Len(aFunc) <> 3)
	return (aErro)
EndIf

If ( Len(aCode) <> 3)
	return (aErro)
EndIf

aReto := { aTemp[1],;
		   aTemp[2],;
		   aFunc[1],;
		   aFunc[2],;
		   aFunc[3],;
		   aCode[1],;
		   aCode[2],;
		   aCode[3],;
	   }

//Verifica Empresa/Filial
If ! FWFilExist(aReto[1],aReto[2])
	return (aErro)
EndIf

//Verifica Funcionario
RESET ENVIRONMENT
RPCSetType(3)
PREPARE ENVIRONMENT EMPRESA aReto[1] FILIAL aReto[2] TABLES "SRA, RA1" MODULO "TRM"
DBSelectArea("SRA")
DBSetOrder(1)
If ! DBseek (aFunc[2]+aFunc[3])
	return (aErro)
Endif

//Verifica Treinamento
DBSelectArea("RA1")
DBSetOrder(1)
If ! DBseek (aCode[2]+aCode[3])
	return (aErro)
Endif

Return (aReto)
