#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM939.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} fJsPMSt
Retorna o status do Json da API de Get do processamento
Obs.: fun��o criada para ser poss�vel finalizar o processo de issue x cobertura, 
sendo poss�vel manipular o status que seria retornado pela API do P&M
@author  Allyson Luiz Mesashi
@since   25/04/2022
/*/
//-------------------------------------------------------------------
Function fJsPMSt( oJson, cStatus )

cStatus := cValToChar( oJson["status"] )

Return cStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} fTokenPM()
Fun��o que gera o token de acesso no P&M
@author  Allyson Luiz Mesashi
@since   18/04/2022
/*/
//-------------------------------------------------------------------
Function fTokenPM( cToken, cErrToken )

Local aHeader	:= {}
Local cBody		:= ""
Local cRet		:= ""
Local lRet 		:= .F.
Local oClient 	:= Nil
Local oJson 	:= JsonObject():New()

oClient := FwRest():New(cPMToken)

aAdd( aHeader, "content-type: application/x-www-form-urlencoded" ) 
aAdd( aHeader, "User-Agent: Protheus")

cBody := "client_id=" + cPMClient + "&client_secret=" + cPMSecret + "&grant_type=client_credentials&client_credentials&scope=authorization_api"

oClient:SetPostParams(cBody)
oClient:SetPath("")

If oClient:Post(aHeader)
	lRet := .T.
	cRet := oClient:GetResult()
	oJson:fromJson(cRet)
	cToken := oJson["access_token"]
Else
	cErrToken := oClient:GetResult()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} f939BAPI
Retorna as op��es de combobox do campo REF_TIPO
@author  Allyson Luiz Mesashi
@since   10/05/2022
/*/
//-------------------------------------------------------------------
Function f939BAPI()

Local cOpcBox := STR0142//"1=Filiais;2=Grupos de cargo;3=Cargos;4=Departamentos;5=Funcion�rios;6=Grupos de contrato;7=Movimenta��o de cargos;8=Movimenta��o de departamentos;9=Movimenta��o de filiais;A=Movimenta��o de grupos de cargo;B=Afastamentos;C=Faltas;D=L�der dos funcion�rios"

Return cOpcBox

//-------------------------------------------------------------------
/*/{Protheus.doc} f939BStat
Retorna as op��es de combobox do campo REF_STATUS
@author  Allyson Luiz Mesashi
@since   10/05/2022
/*/
//-------------------------------------------------------------------
Function f939BStat()

Local cOpcBox := STR0143//"0=N�o iniciado;1=Executando;2=Conclu�do;3=Houve erro de valida��o;X=N�o encontrado"

Return cOpcBox

//-------------------------------------------------------------------
/*/{Protheus.doc} f939BSist
Retorna as op��es de combobox do campo REF_TPINT
@author  Allyson Luiz Mesashi
@since   09/05/2023
/*/
//-------------------------------------------------------------------
Function f939BSist()

Local cOpcBox := STR0270//"1=P&M;2=Feedz"

Return cOpcBox

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldTpInt
Valid do campo REF_TPINT
@author  Allyson Luiz Mesashi
@since   10/05/2023
/*/
//-------------------------------------------------------------------
Function fVldTpInt( cValor )

DEFAULT cValor := " "

Return cValor $ " /1/2"


//-------------------------------------------------------------------
/*/{Protheus.doc} fMsgErr()
Fun��o que exibe o alerta que houve erros e direciona para a documenta��o do P&M
@author  Allyson Luiz Mesashi
@since   12/05/2022
/*/
//-------------------------------------------------------------------
Function fMsgErr()

Local oButton1
Local oGroup1
Local oPanel1
Local oSay1
Local oSay2
Local oDlg

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0148) FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL //"Valida��o"

    @ 000, 000 MSPANEL oPanel1 SIZE 300, 150 OF oDlg COLORS 0, 16777215 RAISED
    @ 005, 012 GROUP oGroup1 TO 055, 237 PROMPT OemToAnsi(STR0001) OF oPanel1 COLOR 0, 16777215 PIXEL //"Aten��o"
    @ 017, 017 SAY oSay1 PROMPT OemToAnsi(STR0149 + CRLF + STR0150) SIZE 215, 035 OF oPanel1 COLORS 0, 16777215 PIXEL //"Foram retornados erros na integra��o com o P&M"##"Verifique a documenta��o do P&M conforme orienta��es no link abaixo"
    @ 063, 012 SAY oSay2 PROMPT "https://tdn.totvs.com/x/rKpLK" SIZE 095, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
    @ 070, 200 BUTTON oButton1 PROMPT "OK" SIZE 037, 012 OF oPanel1 PIXEL

    oSay2:bLClicked := {|| ShellExecute("open", "https://tdn.totvs.com/pages/viewpage.action?pageId=676047532", "", "", 1) }

    oButton1:bLClicked := {|| oDlg:End() }

ACTIVATE MSDIALOG oDlg CENTERED

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GPS04328()
Fun��o que exibe as op��es da consulta padr�o S04328
@author  Allyson Luiz Mesashi
@since   13/05/2022
/*/
//-------------------------------------------------------------------
Function GPS04328(l1Elem)

Local cTitulo		:= STR0183//"Tipo de desligamento"
Local cMvPar
Local aDesc		    := { STR0184, STR0185, STR0186 }//"Pedido de desligamento"##"Sem justa causa"##"Com justa causa"
Local lRet			:= .T.

l1Elem	:= IF( l1Elem == NIL .and. ValType( l1Elem ) != "L" , .T. , .F. )

If f_Opcoes(@cMvPar, cTitulo, aDesc, "123", Nil, Nil, l1Elem, 1, 1)
	VAR_IXB	:= StrTran(cMvPar, "*")
	lRet:= .T.
EndIf

Return lRet
