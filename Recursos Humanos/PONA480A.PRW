#INCLUDE "PROTHEUS.CH"
#INCLUDE "PONA480A.CH"

/*/{Protheus.doc} PONA480A
Rotina de Scheduler para buscar os dados do Dashboard RH e enviar e-mail.
@author Marco Nakazawa
@since 28/07/2022
@Type Function
/*/
Function PONA480A(lDashBoard,oResp)
Local oClient
Local oJsonFunc		:= JsonObject():New()
Local oJsonClkIn	:= JsonObject():New()
Local dData			:= Date()
Local cDia			:= Day2Str(dData)
Local cMes			:= Month2Str(dData)
Local cAno			:= Year2Str(dData)
Local cPerg 		:= "PNA480A"
Local cPergNova		:= "PNA480AN"
Local lExistPerg 	:= fExistPerg(cPerg)
Local lExstPergN 	:= fExistPerg(cPergNova)
Local cLogPatch		:= GetSrvProfString("Startpath","")
Local cURLRest		:= SuperGetMV("MV_PONREST",.F.,"") 
Local cGpeMail		:= SuperGetMV("MV_GPEMAIL",.F.,"")
Local cRelausr		:= SuperGetMV("MV_RELAUSR",.F.,"")
Local cData			:= ""
Local cHora			:= ""
Local cBody			:= ""
Local cFilBody		:= ""
Local cDataIni		:= ""
Local cDataFim		:= ""
Local cDtIniFilt	:= ""
Local cDtFimFilt	:= ""
Local cFilFilt		:= ""
Local cFilHtml		:= ""
Local cHtml			:= ""
Local cMsg			:= ""
Local cDtHrAtual	:= ""
Local cEmail		:= ""
Local cNi			:= ""
Local cFiltroBet	:= ""
Local cFiltroIn		:= ""
Local cfilial		:= ""
Local cHoraAtual	:= Time()
Local aURLApi		:= {"/api/rh/v1/DbHrAttendanceControl","/api/rh/v1/DbHrClockin"}
Local cAuthWS		:= SuperGetMV("MV_AUTHWS",.F.,"")
Local aHeader		:= {}
Local aFiliais		:= {}
Local aResp			:= {}
Local aGetFil 		:= {} 
Local lSchedule		:= IsBlind()
Local lRet			:= .T.
Local nI			:= 0
Local nPeriodo		:= 0
Local nQtdDias		:= 0
Local nLenResp		:= 0
Local nDiasSem		:= Dow(Date())

Default lDashBoard	:= .F.
Default oResp		:= Nil

If (lExistPerg .And. !Empty(cURLRest) .And. lSchedule .And. (!Empty(cGpeMail) .Or. !Empty(cRelausr))) .Or. (lDashBoard .And. oResp <> Nil)
	
	If !Empty(cGpeMail)
		cEmail := cGpeMail
	Else
		cEmail := cRelausr
	EndIf

	If !lDashBoard
		If lExstPergN
			MakeAdvplExpr(cPergNova)
		EndIf
		// Parâmetros preenchidos
		cFilFilt 	:= mv_par01
		nPeriodo	:= mv_par02
		nQtdDias	:= mv_par03

		// Data que foi gerado o Dashboard
		cDtHrAtual := SubStr(cHoraAtual,1,5) + " " + cDia + "/" + cMes + "/" + cAno

		// Validação do pergunte antigo
		If !lExstPergN .And. lExistPerg .And. !Empty(cFilFilt)
			aAdd(aFiliais,cFilFilt)
		ElseIf lExstPergN
			// Formatação das Filiais que serão enviadas para as APIs
			If At("$",cFilFilt) > 0
				cFiltroIn	:= SubStr(cFilFilt, At("$",cFilFilt) + 2)
				cFiltroIn	:= StrTran(cFiltroIn,")","")
				cFiltroIn	:= StrTran(cFiltroIn,"'","")
				aFiliais	:= StrTokArr2(cFiltroIn,",")
			EndIf

			If At(">=",cFilFilt) > 0
				cFiltroBet := StrTran(cFilFilt, "RA_FILIAL","aGetFil[nI,1]")
				cFiltroBet := SubStr(cFiltroBet, At("aGetFil",cFiltroBet), At(")",cFiltroBet) - At("aGetFil",cFiltroBet))
				
				aGetFil := GetFilRecnos(cEmpAnt , Space(FWGETTAMFILIAL), Replicate("Z", FWGETTAMFILIAL))	

				For nI := 1 To Len(aGetFil)
					If &(cFiltroBet)
						aAdd(aFiliais,aGetFil[nI,1])
					EndIf
				Next
			EndIf
		EndIf

		If !Empty(aFiliais)
			aFiliais := aSort(aFiliais)
		EndIf

		If Empty(aFiliais)
			cFilFilt := "todas"
			cFilHtml := "Todas"
			aAdd(aFiliais,cFilFilt)
		Else
			If Len(aFiliais) > 2
				cFilHtml := aFiliais[1] + " " + aFiliais[2] + " +" + cValToChar(Len(aFiliais) - 2)
			ElseIf Len(aFiliais) ==  2
				cFilHtml := aFiliais[1] + " " + aFiliais[2]
			Else
				cFilHtml := aFiliais[1]
			EndIf

			cFilHtml := StrTran(cFilHtml," ","&nbsp;")
		EndIf
		
		// Formatação das Datas que será utilizada no filtro
		If nPeriodo == 1 // Mensal
			cDataIni	:= "01/" + cMes + "/" + cAno
			cDataFim	:= cDia + "/" + cMes + "/" + cAno
			cDtIniFilt	:= cAno + "-" + cMes + "-01"
			cDtFimFilt	:= cAno + "-" + cMes + "-" + cDia
		ElseIf nPeriodo == 2 // Semanal
			cDtFimFilt	:= cAno + "-" + cMes + "-" + cDia
			cDataFim	:= cDia + "/" + cMes + "/" + cAno

			If nDiasSem <> 2
				If nDiasSem == 1
					dData := dData - 6
				Else
					dData := dData - (nDiasSem - 2)
				EndIf

				cDia		:= Day2Str(dData)
				cMes		:= Month2Str(dData)
				cAno		:= Year2Str(dData)
				cDataIni	:= cDia + "/" + cMes + "/" + cAno
				cDtIniFilt	:= cAno + "-" + cMes + "-" + cDia
			Else
				cDataIni	:= cDia + "/" + cMes + "/" + cAno
				cDtIniFilt	:= cAno + "-" + cMes + "-" + cDia
			Endif
		ElseIf nPeriodo == 3 // Quinzenal
			If Val(Day2Str(cDia)) > 15
				cDataIni	:= "16/" + cMes + "/" + cAno
				cDataFim	:= cDia + "/" + cMes + "/" + cAno
				cDtIniFilt	:= cAno + "-" + cMes + "-" + "16"
				cDtFimFilt	:= cAno + "-" + cMes + "-" + cDia
			Else
				cDataIni	:= "01/" + cMes + "/" + cAno
				cDataFim	:= cDia + "/" + cMes + "/" + cAno
				cDtIniFilt	:= cAno + "-" + cMes + "-" + "01"
				cDtFimFilt	:= cAno + "-" + cMes + "-" + cDia
			EndIf
		ElseIf nPeriodo == 4 // Qtde Dias
			cDataFim	:= cDia + "/" + cMes + "/" + cAno
			cDtFimFilt	:= cAno + "-" + cMes + "-" + cDia

			If nQtdDias > 60
				nQtdDias := 60
			EndIf

			dData	:= DaySub(dData,nQtdDias)
			cDia	:= Day2Str(dData)
			cMes	:= Month2Str(dData)
			cAno	:= Year2Str(dData)

			cDataIni	:= cDia + "/" + cMes + "/" + cAno
			cDtIniFilt	:= cAno + "-" + cMes + "-" + cDia
		EndIf

		// Montagem do body da chamada das APIs
		cFilBody := ArrTokStr(aFiliais,'","') 

		BeginContent var cBody
			{
				"startDate":"%Exp:cDtIniFilt%",
				"endDate":"%Exp:cDtFimFilt%",
				"branches":["%Exp:cFilBody%"]
			}
		EndContent

		// Header da chamada das APIs
		aAdd(aHeader,"Accept: application/json")
		aAdd(aHeader,"content-type: application/json")
		aAdd(aHeader,"charset: UTF-8")
		
		// Autenticação para utilização das APIs
		If !Empty(cAuthWS)
			aAdd(aHeader,"Authorization: BASIC " + ENCODE64(rc4crypt( cAuthWS ,"AuthWS#ReceiptID", .F.,.T.)))
		EndIf

		// Configuração para consumir as APIs
		oClient := FwRest():New(cURLRest)
		For nI := 1 To Len(aURLApi)
			oClient:SetPath(aURLApi[nI])
			oClient:SetPostParams(cBody)
			If oClient:Post(aHeader)
				If "DbHrAttendanceControl" $ aURLApi[nI]
					oJsonFunc:fromJson(oClient:GetResult())
					nLenResp := Len(oJsonFunc:GetNames())
				ElseIf "DbHrClockin" $ aURLApi[nI]
					oJsonClkIn:fromJson(oClient:GetResult())
				EndIf
			ElseIf "Unauthorized" $ AllTrim(oClient:cInternalError)
				Conout(AnsiToOEM(STR0027)) //"A chave Security está ativada, porém o parâmetro MV_AUTHWS está com um conteúdo inválido. Por favor configure novamente o parâmetro acessando a rotina AUTHWSRH."
				Return
			Else
				Conout(AnsiToOEM(STR0028)) //"Erro na reposta da API. Verifique se o parâmetro MV_PONREST está configurado corretamente"
				Return
			EndIf
		Next

		// Formatação das respostas das APIs para a montagem do HTML
		For nI := 1 To nLenResp
			cNi := cValToChar(nI)
			If oJsonFunc:hasProperty(cNi)
				aAdd(aResp,{EncodeUTF8(STR0004) + " - " + oJsonFunc[cNi,'branch'],{oJsonFunc[cNi,'totalEmployees'],oJsonFunc[cNi,'clockMarkingsComplete'],oJsonFunc[cNi,'clockMarkingsIncomplete'],oJsonFunc[cNi,'withoutClockMarkings']}})
			EndIf

			If oJsonClkIn:hasProperty(cNi)
				aAdd(aResp,{EncodeUTF8(STR0012) + " - " + oJsonClkIn[cNi,'branch'],{oJsonClkIn[cNi,'totalClockMarkings'],oJsonClkIn[cNi,'totalIntegrated'],oJsonClkIn[cNi,'totalToBeIntegrated'],oJsonClkIn[cNi,'totalWhitoutNSR']}})
			EndIf
		Next

		cDia	:= Day2Str(Date())
		cMes	:= Month2Str(Date())
		cAno	:= Year2Str(Date())

		cData	:= cDia + "/" + cMes + "/" + cAno
		cHora	:= SubStr(Time(),1,5)
	Else
		cDtHrAtual := oResp['lastUpdate']
		
		cData := SubStr(oResp['lastUpdate'],8,10)
		cHora := SubStr(oResp['lastUpdate'],1,5)

		cDataIni := SubStr(oResp['startDate'],9,2) + "/" + SubStr(oResp['startDate'],6,2) + "/" + SubStr(oResp['startDate'],1,4)
		cDataFim := SubStr(oResp['endDate'],9,2) + "/" + SubStr(oResp['endDate'],6,2) + "/" + SubStr(oResp['endDate'],1,4)

		For nI := 1 to Len(oResp['details'])
			aAdd(aResp,{oResp['details',nI,'branch'],{oResp['details',nI,'informations',1], oResp['details',nI,'informations',2], oResp['details',nI,'informations',3], oResp['details',nI,'informations',4]}})
			If Mod(nI,2) == 1
				cfilial := AllTrim(SubStr(oResp['details',nI,'branch'],At("-",oResp['details',nI,'branch']) + 2,Len(oResp['details',nI,'branch'])))
				If cfilial <> "Todas as Filiais"
					aAdd(aFiliais,cfilial)
				EndIf
			EndIf
		Next
		
		If Empty(aFiliais)
			cFilHtml := "Todas"
		Else
			If Len(aFiliais) > 2
				cFilHtml := aFiliais[1] + " " + aFiliais[2] + " +" + cValToChar(Len(aFiliais) - 2)
			ElseIf Len(aFiliais) ==  2
				cFilHtml := aFiliais[1] + " " + aFiliais[2]
			Else
				cFilHtml := aFiliais[1]
			EndIf
			cFilHtml := StrTran(cFilHtml," ","&nbsp;")
		EndIf
	EndIf

	// Montagem do HTML
	cHtml := "<!DOCTYPE html>"
	cHtml += "<html>"
	cHtml += 	"<head>"
	cHtml += 		"<meta charset='UTF-8'/>"
	cHtml += 		"<style type='text/css'>"
	cHtml += 			".title{"
	cHtml += 				"font-family: Roboto-Condensed-Light,sans-serif;"
	cHtml += 				"font-style: normal;"
	cHtml += 				"font-weight: 200;"
	cHtml += 				"font-size: 25px;"
	cHtml += 				"line-height: 55px;"
	cHtml += 				"color: #1D2426;"
	cHtml += 				"vertical-align: bottom;"
	cHtml += 				"width: 100%;"
	cHtml += 				"display: inline-block;"
	cHtml += 			"}"
	cHtml += 			".lastUpdate {"
	cHtml += 				"font-family: Roboto,sans-serif;"
	cHtml += 				"font-style: normal;"
	cHtml += 				"font-weight: 400;"
	cHtml += 				"font-size: 14px;"
	cHtml += 				"line-height: 24px;"
	cHtml += 				"text-align: left;"
	cHtml += 				"color: #4A5C60;"
	cHtml += 				"white-space: nowrap;"
	cHtml += 				"vertical-align: bottom;"
	cHtml += 				"width: 11%;"
	cHtml += 			"}"
	cHtml += 			".lastUpdateDate {"
	cHtml += 				"font-family: Roboto,sans-serif;"
	cHtml += 				"font-style: normal;"
	cHtml += 				"font-weight: 700;"
	cHtml += 				"font-size: 14px;"
	cHtml += 				"line-height: 24px;"
	cHtml += 				"text-align: left;"
	cHtml += 				"color: #4A5C60;"
	cHtml += 				"white-space: nowrap;"
	cHtml += 				"vertical-align: bottom;"
	cHtml += 			"}"
	cHtml += 			".filters {"
	cHtml += 				"white-space: nowrap;"
	cHtml += 				"font-family: Roboto-Bold,sans-serif;"
	cHtml += 				"font-size: 14px;"
	cHtml += 				"line-height: 24px;"
	cHtml += 				"color: #4a5c60;"
	cHtml += 			"}"
	cHtml += 			".inputFilter {"
	cHtml += 				"padding-left: 8px;"
	cHtml += 				"margin-top: 5px;"
	cHtml += 				"margin-right: 12px;"
	cHtml += 				"text-align: left;"
	cHtml += 				"height: 34.5px;"
	cHtml += 				"width: 150px;"
	cHtml += 				"border: 1px solid #D3D3D3;"
	cHtml += 				"border-radius: 3px;"
	cHtml += 			"}"
	cHtml += 			".inputRefresh {"
	cHtml += 				"border: 1px solid #0C9ABE;"
	cHtml += 				"margin-top: 5px;"
	cHtml += 				"border-radius: 3px;"
	cHtml += 				"margin-right: 4px;"
	cHtml += 				"font-weight: bold;"
	cHtml += 				"text-align: center;"
	cHtml += 				"height: 34.5px;"
	cHtml += 				"width: 90px;"
	cHtml += 				"color: #0c9abe;"
	cHtml += 			"}"
	cHtml += 			".inputEmail {"
	cHtml += 				"border: 1px solid #0C9ABE;"
	cHtml += 				"margin-top: 5px;"
	cHtml += 				"border-radius: 3px;"
	cHtml += 				"font-weight: bold;"
	cHtml += 				"text-align: center;"
	cHtml += 				"height: 34.5px;"
	cHtml += 				"width: 125px;"
	cHtml += 				"color: #0c9abe;"
	cHtml += 			"}"
	cHtml += 			".indicators {"
	cHtml += 				"font-family:Roboto-Condensed-Light,sans-serif;"
	cHtml += 				"height: 80px;"
	cHtml += 				"padding: 8px;"
	cHtml += 				"font-size: 24px;"
	cHtml += 				"line-height: 32px;"
	cHtml += 				"align-items: center;"
	cHtml += 				"color: #374548;"
	cHtml += 			"}"
	cHtml += 			".alert {"
	cHtml += 				"font-family:Roboto-Condensed-Light,sans-serif;"
	cHtml += 				"font-size: 10px;"
	cHtml += 				"color: #1D2426;"
	cHtml += 				"border-radius: 3px;"
	cHtml += 				"display: inline-block;"
	cHtml += 				"float: right;"
	cHtml += 				"margin-right: 25px;"
	cHtml += 				"margin-top: 10px;"
	cHtml += 				"padding: 5px;"
	cHtml += 			"}"
	cHtml += 			"tableCards {"
	cHtml += 				"border: 1px solid #000;"
	cHtml += 			"}"
	cHtml += 			".divIndicators {"
	cHtml += 				"display: flex;"
	cHtml += 			"}"
	cHtml += 			".cardDescriptionTotal{"
	cHtml += 				"font-family: Roboto,sans-serif;"
	cHtml += 				"font-size: 16px;"
	cHtml += 				"color: #ffffff;"
	cHtml += 				"text-align: center;"
	cHtml += 				"vertical-align: top;"
	cHtml += 			"}"
	cHtml += 			".cardAmountTotal{"
	cHtml += 				"font-family: Calibri,sans-serif;"
	cHtml += 				"font-size: 50px;"
	cHtml += 				"vertical-align: top;"
	cHtml += 				"justify-content: center;"
	cHtml += 				"flex: 1 1 auto;"
	cHtml += 				"color: #ffffff;"
	cHtml += 				"text-align: center;"
	cHtml += 			"}"
	cHtml += 			".cardDescription{"
	cHtml += 				"font-family: Roboto,sans-serif;"
	cHtml += 				"font-size: 16px;"
	cHtml += 				"color: #4a5c60;"
	cHtml += 				"text-align: center;"
	cHtml += 				"vertical-align: top;"
	cHtml += 			"}"
	cHtml += 			".cardAmount{"
	cHtml += 				"font-family: Calibri,sans-serif;"
	cHtml += 				"font-size: 50px;"
	cHtml += 				"color: #4a5c60;"
	cHtml += 				"justify-content: center;"
	cHtml += 				"flex-direction: column;"
	cHtml += 				"flex: 1 1 auto;"
	cHtml += 				"text-align: center;"
	cHtml += 				"vertical-align: top;"
	cHtml += 			"}"
	cHtml += 			".separator {"
    cHtml += 			"border: 1px dotted #4a5c60;"
	cHtml += 			"}"
	cHtml += 		"</style>"
	cHtml += 	"</head>"
	cHtml += 	"<body>"
	cHtml += 		"<div style='display: flex;'>"
	cHtml += 			"<div class='title'>Dashboard</div>"
	cHtml += 			"<div style='display:inline;'>"
	cHtml += 				"<div class='lastUpdate'>" + EncodeUTF8(STR0001) + "</div>"
	cHtml += 				"<div class='lastUpdateDate'>" + cDtHrAtual + "</div>"
	cHtml += 			"</div>"
	cHtml += 		"</div>"
	cHtml += 		"<div style='height: 25px'></div>"
	cHtml += 		"<div>"
	cHtml += 			"<table class='filters'>"
	cHtml += 				"<tr>"
	cHtml += 					"<td><b>" + EncodeUTF8(STR0002) + "</b></td>"
	cHtml += 					"<td><b>" + EncodeUTF8(STR0003) + "</b></td>"
	cHtml += 					"<td><b>Selecione o Local</b></td>"
	cHtml += 					"<td></td>"
	cHtml += 					"<td></td>"
	cHtml += 				"</tr>"
	cHtml += 				"<tr>"
	cHtml += 					"<td><input class='inputFilter'	type='text' value=" + cDataIni + "></td>"
	cHtml += 					"<td><input class='inputFilter'	type='text' value=" + cDataFim + "></td>"
	cHtml += 					"<td><input class='inputFilter'	type='text' value=" + cFilHtml + " style='width:280px; color: #0c9abe;'></td>"
	cHtml += 					"<td><input class='inputRefresh' type='text' value='Atualizar'></td>"
	cHtml += 					"<td><input class='inputEmail' type='text' value='Enviar E-mail'></td>"
	cHtml += 				"</tr>"
	cHtml += 			"</table>"
	cHtml += 		"</div>"
	For nI := 1 To Len(aResp)
		cHtml += 		"<div class='indicators'>"
		cHtml += 			"<p><b>" + aResp[nI,1] + "</b></p>"
		cHtml += 		"</div>"
		cHtml += 		"<div class='divIndicators'>"
		cHtml += 			"<table class='tableCards' style='border-radius: 3px; width: 300px; height:220px; background-color: #0C9ABE; color: #ffffff;'>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 					"<td style='width:100%;'></td>"
		cHtml += 				"</tr>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 					"<td class='cardAmountTotal'>" + cValToChar(aResp[nI,2,1]) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 				"<td class='cardDescriptionTotal'>" + If (Mod(nI,2) == 1, EncodeUTF8(STR0005), EncodeUTF8(STR0013)) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 			"</table>"
		cHtml += 			"<div style='width: 15px' ></div>"
		cHtml += 			"<table class='tableCards' style='border: 1px solid #D3D3D3; border-radius: 3px; width: 300px; height:220px;'>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 					"<td class='alert' style='background-color: #DAECE5;'>" + EncodeUTF8(STR0006) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 					"<td class='cardAmount'>" + cValToChar(aResp[nI,2,2]) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 				"<td class='cardDescription'>" + If (Mod(nI,2) == 1, EncodeUTF8(STR0007),EncodeUTF8(STR0014)) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 			"</table>"
		cHtml += 			"<div style='width: 15px' ></div>"
		cHtml += 			"<table class='tableCards' style='border: 1px solid #D3D3D3; border-radius: 3px; width: 300px; height:220px;'>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 				"<td class='alert' style='background-color: #FFEACB;'>" + EncodeUTF8(STR0008) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 				"<tr>"
		cHtml += 					"<td class='cardAmount'>" + cValToChar(aResp[nI,2,3]) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 				"<td class='cardDescription'>" + If (Mod(nI,2) == 1, EncodeUTF8(STR0009),EncodeUTF8(STR0015)) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 			"</table>"
		cHtml += 			"<div style='width: 15px' ></div>"
		cHtml += 			"<table class='tableCards' style='border: 1px solid #D3D3D3; border-radius: 3px; width: 300px; height:220px;'>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 				"<td class='alert' style='background-color: #F6E0E0;'>" + EncodeUTF8(STR0010) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 					"<td class='cardAmount'>" + cValToChar(aResp[nI,2,4]) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 				"<td class='cardDescription'>" + If (Mod(nI,2) == 1, EncodeUTF8(STR0011),EncodeUTF8(STR0016)) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 			"</table>"
		cHtml += 		"</div>"
		If Mod(nI,2) == 0
			cHtml +=	"<br>"
			cHtml +=	"<hr class='separator'>"			
			cHtml +=	"<p></p>"			
			cHtml +=	"<hr class='separator'>"
		EndIf 
	Next
	cHtml += 	"</body>"
	cHtml += "</html>"

	// Criação o arquivo HTML
	nHandle := fcreate(cLogPatch + "dashboard_rh.html")
	FWrite(nHandle, cHtml)
	fclose(nHandle)

	cMsg := STR0017 + cData + STR0018 + cHora + "."

	// Envio do E-mail
	If gpeMail("Dashboard",cMsg,cEmail,{cLogPatch + "dashboard_rh.html"})
		Conout(OemToAnsi(STR0025)) // "E-mail com os dados do Dashboard RH foi enviado com sucesso."
	Else
		Conout(OemToAnsi(STR0026)) // "Falha no envio do e-mail com os dados do Dashboard RH. Verifique as configurações para o envio do e-mail."
		lRet := .F.
	EndIf
Else
	If lSchedule
		If !lExistPerg
			Conout(OemToAnsi(STR0019) + ": " + OemToAnsi(STR0020)) // "Erro de dicionário" "O grupo de perguntas PNA480A não está criado. Execute o UPPDISTR com o pacote de dicionários da expedição contínua para a criação."
		ElseIf Empty(cURLRest)
			Conout(OemToAnsi(STR0021) + ": " + OemToAnsi(STR0022)) // "Erro no parâmetro MV_PONREST." "O parâmetro MV_PONREST não está preenchido."
		ElseIf Empty(cGpeMail) .And. Empty(cRelausr)
			Conout(OemToAnsi(STR0026)) // "Falha no envio do e-mail com os dados do Dashboard RH. Verifique as configurações para o envio do e-mail."
		EndIf
	Else
		Help(,,STR0023,,STR0024,1,0) // "Erro na execução da rotina." "Esta rotina só deve ser executada pelo Scheduler."
	EndIf
EndIf
	fErase(cLogPatch + "dashboard_rh.html")
Return lRet

/*/{Protheus.doc} fExistPerg
//Função para verificar se existe o grupo de perguntas
@author marco.nakazawa
@since 25/07/2022
@version 1.0
@return NIL
@type static function
/*/
Static Function fExistPerg(cPergunte)
Local lRet	:= .F.
Local oSX1	:= FWSX1Util():New()

oSX1:AddGroup(cPergunte)
oSX1:SearchGroup()

If !Empty(oSX1:aGrupo[1,2])
	lRet:= .T.
EndIf

FreeObj(oSX1)
Return lRet

/*/{Protheus.doc} Scheddef
//Função para execução da rotina pelo Scheduler
@author marco.nakazawa
@since 25/07/2022
@version 1.0
@return NIL
@type static function
/*/
Static Function Scheddef()
Local aOrd			:= {}
Local aParam		:= {}
Local lExstPergN	:= fExistPerg("PNA480AN")

If lExstPergN
	aParam := {	"P"			, ; // Tipo R para relatorio P para processo
				"PNA480AN"	, ;	// Pergunte do relatorio, caso nao use passar ParamDef
				""			, ; // Alias para o relatório
				aOrd		, ; // Array de ordens para o relatório
				""			}
Else
	aParam := {	"P"			, ; // Tipo R para relatorio P para processo
				"PNA480A"	, ;	// Pergunte do relatorio, caso nao use passar ParamDef
				""			, ; // Alias para o relatório
				aOrd		, ; // Array de ordens para o relatório
				""			}
EndIf
Return aParam
