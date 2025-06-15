#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWPRINTSETUP.CH" 
#INCLUDE "RPTDEF.CH"  

#INCLUDE "RHNPLIB.CH"

/*/{Protheus.doc}RHNPLIB

- Fonte agrupador de diversas Functions do Projeto MEU RH ( RH MOBILE );

@author:	Matheus Bizutti
@since:		24/08/2017

/*/

/*/{Protheus.doc} GetAccessEmployee
- Obt�m o acesso a RD0 e alimenta o array aRET com as matr�culas do usu�rio logado.

@author:	Matheus Bizutti
/*/
Function GetAccessEmployee(cRD0Login,aRet,lRetorno,lMeuRH,cMensagem)

Local lRet		:= .F.

Default cRD0Login := ""
Default aRet      := {}
Default lRetorno  := .F.
Default lMeuRH    := .F.

// - Verifica se existe o arquivo de relacionamento
// - Efetua o posicionamento no funcion�rio (SRA)
If lRetorno 

	If MatParticipant(cRD0Login, aRet, .T., lMeuRH)
		lRet := .T.
	EndIf

	//Verifica se o usu�rio j� foi admitido
	lRet      := !Empty(aRet) .And. Date() >= aRet[1][5]
	cMensagem := If( lRet, cMensagem, EncodeUTF8(STR0014) )//"Acesso n�o permitido antes da data de admiss�o!"

EndIf

Return(lRet)

/*/{Protheus.doc} GetRegisterHR
- L� a Matr�cula do USU�RIO GRAVADO NO TOKEN

@author:	Matheus Bizutti
/*/
Function GetRegisterHR(cToken)
	Local aHeader  := {}
	Default cToken := ''
	aHeader := GetClaims(cToken)
	
	If Len(aHeader) < 1
		Return ""
	EndIf
Return(aHeader[1])

/*/{Protheus.doc} GetLoginHR
- L� o LOGIN ( RD0_LOGIN ) do USU�RIO GRAVADO NO TOKEN

@author:	Matheus Bizutti
/*/
Function GetLoginHR(cToken)
	Local aHeader := {}
	Default cToken := ''
	aHeader := GetClaims(cToken)
	
	If Len(aHeader) < 2
		Return ""
	EndIf
Return(aHeader[2])

/*/{Protheus.doc} GetLoginHR
- L� o c�digo ( RD0_CODIGO ) do USU�RIO GRAVADO NO TOKEN

@author:	Matheus Bizutti
/*/
Function GetCODHR(cToken)
	Local aHeader  := {}
	Default cToken := ''
	aHeader := GetClaims(cToken)
	
	If Len(aHeader) < 3
		Return ""
	EndIf
Return(aHeader[3])

/*/{Protheus.doc} GetLoginHR
- L� a filial ( RDZ - RELACIONAMENTO ) do USU�RIO GRAVADO NO TOKEN

@author:	Matheus Bizutti
/*/
Function GetBranch(cToken)
	Local aHeader  := {}
	Default cToken := ''
	aHeader := GetClaims(cToken)
	
	If Len(aHeader) < 5
		Return ""
	EndIf
Return(aHeader[5])

/*/{Protheus.doc} GetDataLogin
- Retorna os dados de Login a partir do usuario gravado no Token
@author:	Marcelo Silveira
/*/
Function GetDataLogin(cToken, lChkFunc, cKeyId)
	Local aHeader  := {}

	Default cToken   := ''
	Default lChkFunc := .F.
	Default cKeyId 	 := ''

	If !Empty(cKeyId) //A existencia da chave indica que o login � integrado Protheus/AD
		aHeader := StrTokArr(Decode64(cKeyId), "|")
		If Len(aHeader) >= 6 
			aHeader[6] := aHeader[6] == ".T." 
		EndIf
	Else
		aHeader := GetClaims(cToken)

		/*/
			aHeader[1] = Matr�cula (Tab. SRA)
			aHeader[2] = Login (Tab. RD0)
			aHeader[3] = Codigo (Tab. RD0)
			aHeader[4] = Database
			aHeader[5] = Filial (Tab. SRA)

			Opcional
			aHeader[6] = Situacao (.T. = demitido)
		/*/
		
		If Len(aHeader) < 5
			Return ""
		Else 
			If Len(aHeader) >= 6 
				aHeader[6] := aHeader[6] == ".T." 
			EndIf
		EndIf	
	EndIf

Return(aHeader)


/*/{Protheus.doc} DecodeURL
- DECODE do corpo de requisi��es que vem no FORMDATA FORMAT.

@author:	Matheus Bizutti
/*/
Function DecodeURL(cBody)

Local cURLDecode := ""
Local cUser      := ""
Local cPw        := ""
Local cEmail     := ""
Local cRestURL   := ""
Local cHash      := ""
Local nX         := 0
Local nTamURL	 := 0
Local aPars      := {}
Local aKeyValue  := {}
Local aReturn    := {}
Local cExecRobo  := "0"

Default cBody    := ""

aPars := StrTokArr(cBody, "&")
//varinfo("aPars: ",aPars)

For nX := 1 To Len(aPars)
	aKeyValue := StrTokArr(aPars[nX], "=")
	If aKeyValue[1] == "user"
		cUser := Iif(Len(aKeyValue) >= 2,aKeyValue[2],"")
		cUser := StrTran(cUser, "+", "")
		aAdd( aReturn, {"user", cUser} )
	ElseIf	aKeyValue[1] == "password"
	 	cPw := Iif(Len(aKeyValue) >= 2,aKeyValue[2],"")
		aAdd( aReturn, {"password", cPw} )
	ElseIf	aKeyValue[1] == "redirectUrl"
		cURLDecode := StrTran( Iif(Len(aKeyValue) >= 2,aKeyValue[2],""), "%3A", ":" )
		cURLDecode := StrTran( cURLDecode, "%2F", "/" )
		aAdd( aReturn, {"redirectUrl", cURLDecode} )
    ElseIf aKeyValue[1] == "email"
       cEmail := Iif(Len(aKeyValue) >= 2,aKeyValue[2],"")
       cEmail := StrTran( cEmail, "%40", "@" )
	   aAdd( aReturn, {"email", cEmail} )
    ElseIf  aKeyValue[1] == "hash"
       cHash  := Iif(Len(aKeyValue) >= 2,aKeyValue[2],"")
	   aAdd( aReturn, {"hash", cHash} )
	ElseIf aKeyValue[1] == "execRobo"
		cExecRobo := Iif(Len(aKeyValue) >= 2, aKeyValue[2], "0")
		aAdd( aReturn, {"execRobo", cExecRobo} )			
	ElseIf aKeyValue[1] == "restUrl"
		cRestURL := Iif(Len(aKeyValue) >= 2, aKeyValue[2], "")
		nTamURL  := At( "?bust" , cRestURL )
		cRestURL := If( nTamURL > 0, SubStr(cRestURL, 1, nTamURL-1), cRestURL)
		aAdd( aReturn, {"restUrl", cRestURL} )	
	EndIf
Next nX

Return(aReturn)


/*/{Protheus.doc}fVldSolAut
Retorna se o usu�rio autenticado tem acesso as informa��es solicitadas.
@author: Gabriel A.	
@since: 24/07/2017
/*/
Function fVldSolAut(cFilAut, cMatAut, cEmpAut, cFilSol, cMatSol, cEmpSol)

Local cCpf		 := ""
Local cCpfTransf := ""
Local cTabSRA    := ""
Local cQuery     := GetNextAlias()

Local aArea      := GetArea()

Local lTemAcesso := .T.


DEFAULT cEmpAut := cEmpAnt
DEFAULT cEmpSol := cEmpAnt

//Somente checa se os dados logados forem diferentes dos dados do recibo
If !(cEmpAut + cFilAut + cMatAut == cEmpSol + cFilSol + cMatSol)

	//Buscando CPF da matricula logada.
	cTabSRA := "%" + RetFullName("SRA", cEmpAut) + "%"
	BEGINSQL ALIAS cQuery
		SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_CIC
		FROM %exp:cTabSRA% SRA
		WHERE SRA.RA_FILIAL = %exp:cFilAut% AND
			SRA.RA_MAT = %exp:cMatAut% AND 
			SRA.%notDel%
	ENDSQL

	If (cQuery)->(!Eof())
		cCpf := AllTrim( (cQuery)->RA_CIC )
	EndIF
	(cQuery)->(DbCloseArea())

	// Buscando CPF da matricula transferida.
	cQuery  := GetNextAlias()
	cTabSRA := "%" + RetFullName("SRA", cEmpSol) + "%"

	BEGINSQL ALIAS cQuery
		SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_CIC
		FROM %exp:cTabSRA% SRA
		WHERE SRA.RA_FILIAL = %exp:cFilSol% AND
			SRA.RA_MAT = %exp:cMatSol% AND 
			SRA.%notDel%
	ENDSQL

	If (cQuery)->(!Eof())
		cCpfTransf := AllTrim( (cQuery)->RA_CIC )
	EndIF
	(cQuery)->(DbCloseArea())

	If !( lTemAcesso := ( cCpf == cCpfTransf ) )
		Conout( " <<< " + EncodeUTF8(STR0001) + " >>> ") //"O usu�rio autenticado n�o possui acesso aos dados."
	EndIf
	RestArea(aArea)
EndIF

Return lTemAcesso

/*/{Protheus.doc}GetConfig()
- Fun��o respons�vel por ler uma sess�o do appserver.ini e uma chave, e retornar o valor.
@author:	Matheus Bizutti
@since:		09/08/2017
/*/
Function GetConfig(cSession, cProperty,cDefault)

Local cValue := ""

Default cSession  := ""
Default cProperty := ""
Default cDefault  := ""

cValue := GetPvProfString(cSession, cProperty, "", GetAdv97()) 

Return(Iif(Empty(cValue),cDefault,cValue))


/*/{Protheus.doc}GetClaims()
- Fun��o respons�vel por obter o Token gerado no momento do Login, e retornar os dados de acesso do usu�rio logado.
@author:	Matheus Bizutti
@since:	09/08/2017
/*/
Function GetClaims(cToken)

Local nX        := 0
Local aClaims 	:= {}
Local aReturn	:= {}
Default cToken	:= ""

aClaims := JWTClaims(Substr(cToken,8,Len(cToken)))

For nX := 1 To Len(aClaims)
   If aClaims[nX][1] == "KEY"
      aReturn := StrTokArr(aClaims[nX][2], "|")
   EndIf
Next nX

Return(aReturn)


/*/{Protheus.doc}GetVisionAI8()
- Fun��o respons�vel por ler a VIS�O de determinada rotina na tabela AI8
@author:	Matheus Bizutti
@since:	21/08/2017
@param:	cRoutine - nome da rotina que a fun��o buscar� ex: W_PWSA01.APW
		cBranchVld - Filial utilizada no acesso ao APP.
		cCodEmp - Codiqo da empresa para pesquisa em tabela diferente da empresa logada
/*/
Function GetVisionAI8(cRoutine, cBranchVld, cCodEmp)

Local aVision	:= {}
Local cQuery    := GetNextAlias()
Local cBranchAI8:= ""
Local __cAI8tab := ""
Local cCodHR	:= "000006"

Default cRoutine   := ""
Default cBranchVld := FwCodFil()
Default cCodEmp    := cEmpAnt

cBranchAI8 := xFilial("AI8", cBranchVld)

If !Empty(cRoutine)

	__cAI8tab := "% " + RetFullName("AI8", cCodEmp) + " %"

	BEGINSQL ALIAS cQuery
	
		SELECT AI8.AI8_VISAPV, AI8.AI8_INIAPV, AI8.AI8_APRVLV
	   	FROM %exp:__cAI8tab% AI8
		WHERE AI8.AI8_FILIAL =  %Exp:cBranchAI8% AND
			  AI8.AI8_ROTINA =  %Exp:cRoutine%   AND
			  AI8.AI8_PORTAL =  %Exp:cCodHR%     AND
			  AI8.%notDel%
	ENDSQL

	While (cQuery)->(!Eof())
	
		Aadd(aVision, {(cQuery)->AI8_VISAPV,(cQuery)->AI8_INIAPV,(cQuery)->AI8_APRVLV})
	
		(cQuery)->(DbSkip())
	EndDo

(cQuery)->( DbCloseArea() )

EndIf

If Empty(aVision)
	// ------------------------------
	// INICIALIZANDO O ARRAY aVision |
	// ------------------------------
	aVision	:= Array(1,3)
	aVision[1][1] := ""
	aVision[1][2] := 0
	aVision[1][3] := 0	
EndIf

Return(aVision)

/*/{Protheus.doc}Format8601()
- Fun��o respons�vel por receber um DATETIME e devolver a data ou a hora.
@author:	Matheus Bizutti
@since:	21/08/2017
@param:	lDate - Quando informada .T., a fun��o devolve a data, caso contr�rio devolve a hora.
			cValue - Valor em DATETIME ISO 8601 que ser� utilizado para retorno de data ou hora.
/*/

Function Format8601(lDate,cValue,l2Dig,lStoD)

Local cFormat	:= ""
Local cAuxFormat:= ""
Local nPosIni	:= 1
Local nTam		:= 4

Default lDate	:= .T.
Default cValue	:= ""
Default l2Dig	:= .F.
Default lStoD	:= .F.

If !Empty(cValue)
	If lDate

		If l2Dig
			nPosIni := 3
			nTam := 2
		EndIf
		
		cAuxFormat := Substr(cValue,1,10)

		If lStoD 
			//Retorna a data em formato AAAAMMDD para uso na funcao STOD
			cFormat := Substr(cAuxFormat,nPosIni,nTam) + Substr(cAuxFormat,6,2) + Substr(cAuxFormat,9,2)
		Else
			//Retorna a data em formato DD/MM/AAAA
			cFormat := Substr(cAuxFormat,9,2) + "/" + Substr(cAuxFormat,6,2) + "/" + Substr(cAuxFormat,nPosIni,nTam) 
		EndIf
	Else
		cFormat    := Substr(cValue,12,5) 
		
	EndIf
EndIf

Return(cFormat)

/*/{Protheus.doc}SumDate
- Efetua SUM em datas;
@author: 	Matheus Bizutti	
@since:	12/04/2017

/*/
Function SumDate(dDate, nDays)

Default dDate := dDataBase
Default nDays := 0

Return DaySum( dDate , nDays )


/*/{Protheus.doc}PeriodConcessive
- Retorna o Periodo concessivo ou aquisitivo a partir de uma data referencia
@author: 	Matheus Bizutti	
@since:	12/04/2017

/*/
Function PeriodConcessive(dInit, dEnd, lAquisitive)

Local aDate		:= {}
Local dInitDate	:= CtoD(" / / ") 
Local dEndDate	:= CToD(" / / ")

Default dInit := CtoD(" / / ")
Default dEnd 	:= CtoD(" / / ")
Default lAquisitive := .F.

If lAquisitive
	dEndDate	:= DaySub(STOD(dEnd),1)
	dInitDate 	:= YearSub(dEndDate,1)
	dInitDate 	:= DaySum(dInitDate,1)	
Else
	dInitDate 	:= DaySum(STOD(dEnd),1)
	dEndDate	:= YearSum(dInitDate,1)
	dEndDate	:= DaySub(dEndDate,1)
EndIf

Aadd(aDate,dInitDate)
Aadd(aDate,dEndDate)

Return(aDate)

/*/{Protheus.doc}StatusVacation
- Retorna o Status de F�rias;
@author: 	Matheus Bizutti	
@since:	12/04/2017

/*/
Function StatusVacation(dDataIni, dDataFim)

Local cStatus := ""

If dDataIni > dDataBase
	cStatus := "calculated"
ElseIf dDataIni <= dDataBase .And. dDataFim >= dDataBase
	cStatus := "vacation"	
Else
	cStatus := "closed"
EndIf

Return (cStatus)


/*/{Protheus.doc}GetDepSup
- Efetua a busca do Depto Superior
@author: 	Matheus Bizutti
@since: 	13/07/2017
@param:	cDepto - SRA->RA_DEPTO | cBranchVld - Vari�vel da Filial da RDZ

/*/
Function GetDepSup(cDepto,cBranchVld)

Local cDepSup := ""
Local aArea   := GetArea()
Local aQBArea := SQB->(GetArea())

Default cDepto := ""

DbSelectArea("SQB")
If SQB->(DbSeek(xFilial("SQB", cBranchVld)+ cDepto))
	cDepSup := SQB->QB_DEPSUP
EndIf

RestArea(aArea)
RestArea(aQBArea)

Return(cDepSup)

Function GetENUMDecode(cCode)

Local cDesc := ""
Default cCode := ""

DO CASE
	CASE cCode == "B"
		cDesc := EncodeUTF8('vacation')
	CASE cCode == "8"
		cDesc := EncodeUTF8('allowance')
	CASE cCode == "Z"
		cDesc := EncodeUTF8('clocking') 
	CASE cCode == "6"
		cDesc := EncodeUTF8('demission') 
	CASE cCode == "7"
		cDesc := EncodeUTF8('employeeDataChange') //A��o salarial
	CASE cCode == "3"
		cDesc := EncodeUTF8('staffIncrease')      //Aumento de quadro
	CASE cCode == "4"
		cDesc := EncodeUTF8('transfer') //Transferencia
	OTHERWISE
		cDesc := ''
	ENDCASE

Return (EncodeUTF8(cDesc))

/*/{Protheus.doc} getSummary
- Retorna dados do funcionario
@author: 	Matheus Bizutti, Marcelo Silveira (nova versao)
@since: 	13/07/2017
@param:	
	Matricula - Matricula do funcionario
	cBranchVld - Filial do funcionario
	cEmp - Empresa do funcionario
/*/
Function getSummary(cMat, cBranch, cEmp, cFiltro)

	Local aReturn 	:= Array(05)
	Local cAliasSRA := GetNextAlias()
	Local cNome  	:= ""
	Local cWhere	:= ""
	Local __cDelete := "% SRA.D_E_L_E_T_ = ' ' AND SRJ.D_E_L_E_T_ = ' ' %"
	Local lNomeSoc  := SuperGetMv("MV_NOMESOC", NIL, .F.)

	Default cMat 	:= ""
	Default cBranch := ""
	Default cEmp    := cEmpAnt
	Default cFiltro	:= ""

		aReturn[1] := ""
		aReturn[2] := ""
		aReturn[3] := ""
		aReturn[4] := ""
		aReturn[5] := ""

		__cSRAtab 	:= "%" + RetFullName("SRA", cEmp) + "%"
		__cSRJtab 	:= "%" + RetFullName("SRJ", cEmp) + "%"
		cJoinSRJ 	:= "% SRA.RA_CODFUNC = SRJ.RJ_FUNCAO AND " + fMHRTableJoin("SRA", "SRJ") + "%"
		cWhere 		:= "RA_FILIAL = '" + cBranch + "' AND RA_MAT = '" + cMat + "'"
		cWhere 		+= If( !Empty(cFiltro), cFiltro, "" )
		cWhere 		:= "% " + cWhere + " %" 

		BeginSql ALIAS cAliasSRA
			SELECT RA_FILIAL, RA_MAT, RA_CODFUNC, RA_NOME, RA_NSOCIAL, RA_NOMECMP, RA_DEPTO, RJ_FUNCAO, RJ_DESC 
			FROM %exp:__cSRAtab% SRA
			LEFT JOIN %exp:__cSRJtab% SRJ
				ON %exp:cJoinSRJ% 
			WHERE
				%Exp:cWhere% AND %exp:__cDelete%
		EndSql	

		While (cAliasSRA)->(!Eof())
			cNome := If(lNomeSoc .And. !Empty((cAliasSRA)->RA_NSOCIAL), (cAliasSRA)->RA_NSOCIAL, (cAliasSRA)->RA_NOMECMP)
			cNome := If(Empty(cNome), (cAliasSRA)->RA_NOME, cNome)

			aReturn[1] := (cAliasSRA)->RA_MAT
			aReturn[2] := EncodeUTF8( Alltrim( cNome ) )
			aReturn[3] := EncodeUTF8( Alltrim( (cAliasSRA)->RJ_DESC ) ) 
			aReturn[4] := (cAliasSRA)->RA_FILIAL
			aReturn[5] := (cAliasSRA)->RA_DEPTO
			
			(cAliasSRA)->( DbSkip() )
		EndDo
		
		(cAliasSRA)->( DBCloseArea() )

Return(aReturn)


Function milisSecondsToHour(nMSInitParam,nMSEndParam)

Local aConvertHour	:= Array(2)

Local nMSInit	:= nMSInitParam
Local nMSEnd	:= nMSEndParam
Local nHourInit	:= 0 
Local nHourEnd	:= 0 

nMsInit := (nMsInit / (1000*60))
nMSEnd  := (nMsEnd  / (1000*60))

nHourInit := Min2Hrs(nMsInit)
nHourEnd  := Min2Hrs(nMSEnd)

aConvertHour[1] := nHourInit
aConvertHour[2] := nHourEnd

Return(aConvertHour)


Function HourToMs(cTime)
Local nMSTime	:= 0
Local aTime		:= {}

Default cTime	:= ""

	aTime := StrTokArr(cTime, ".") // = 9.05
	If Len(aTime) > 1
		If Len(aTime[2]) == 1
			aTime[2] := aTime[2] + "0"
		EndIf
		nMSTime := ((Val(aTime[1]) * 60) + Val(aTime[2])) * 60000
	Else
		nMSTime := ((Val(aTime[1]) * 60)) * 60000
	EndIf

Return(nMSTime)

/*/{Protheus.doc} formatGMT
Formata a hora para o formato json
@author:	Marcelo Silveira
@since:		23/05/2019
@param:		cValue  - Data em formato string ou caracter para conversao;
			lString - Verifica se a data veio no formato STRING(STOD) ao inv�s de CARACTER(CTOD) para realizar a convers�o.
@return:	cReturn - data no formato GMT			
/*/
Function formatGMT(cValue, lString)
Local cDateFormat	:= ""
Local cReturn		:= ""
Local aDateFormat	:= {}

Default cValue	:= ""
Default lString	:= .F.

If !lString
	cDateFormat := DTOS(CTOD(Alltrim(cValue)))
else
	cDateFormat := cValue
EndIf
aDateFormat := LocalToUTC( cDateFormat, "12:00:00" )

cReturn := Iif(Empty(aDateFormat),"",Substr(aDateFormat[1],1,4) + "-" + Substr(aDateFormat[1],5,2) + "-" + Substr(aDateFormat[1],7,2) + "T" + "12:00:00" + "Z")

Return( cReturn )


/*/{Protheus.doc} fPDFMakeFileMessage
//Gera um arquivo PDF para retorno de uma requisicao REST para exibir LOG de ocorrencias
@author:	Marcelo Silveira
@since:		20/08/2019
@return:	Nil	
/*/
Function fPDFMakeFileMessage( aMsg, cNameFile, cFile )

Local oFile
Local oPrint	
Local cArqLocal		:= ""
Local nX 			:= 0
Local nLin 			:= 0
Local nCont			:= 0
Local nTamMarg		:= 15
Local lContinua		:= .T.
Local cLocal		:= GetSrvProfString ("STARTPATH","")
Local oFont10n		:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)	//Normal negrito
Local oFont10		:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)	//Normal s/ negrito

DEFAULT aMsg		:= { OemToAnsi(STR0002) } //"Ocorreram erros durante o processamento"
DEFAULT cNameFile	:= "LOG_MESSAGE"
DEFAULT cFile		:= ""

	oPrint 		:= FWMSPrinter():New(cNameFile+".rel", IMP_PDF, .F., cLocal, .T., , , , .T., , .F., )
	
	oPrint:SetLandscape()
	oPrint:SetMargin(nTamMarg,nTamMarg,nTamMarg,nTamMarg)
	oPrint:StartPage()

	nSizePage	:= oPrint:nPageWidth / oPrint:nFactorHor

	nLin += 30
	oPrint:Say(nLin,  15, OemToAnsi(STR0003), oFont10n) //"LOG DE OCORR�NCIAS"
	nLin += 05		
	oPrint:Line(nLin, 15, nLin, nSizePage-(nTamMarg*3))
	
	nLin += 15
	For nX := 1 to Len( aMsg )
		oPrint:Say(nLin, 15, aMsg[nX], oFont10)
		nLin += 10
	Next nX
		
	oPrint:EndPage()
		
	cArqLocal		:= cLocal+cNameFile+".PDF"		
	oPrint:cPathPDF := cLocal 
	oPrint:lViewPDF := .F.
	oPrint:Print()
	
	While lContinua
	    If File( cArqLocal )
			oFile := FwFileReader():New( cArqLocal )
			
			If (oFile:Open())
		    	cFile := oFile:FullRead()
		        oFile:Close()
		        fErase(cArqLocal)		    		
			EndIf
	    EndIf
	    //Em determinados ambientes pode ocorrer demora na geracao do arquivo, entao tenta localizar por 5 segundos no maximo.
	    If ( lContinua := Empty(cFile) .And. nCont < 4 )
	    	nCont++
	    	Sleep(1000)
	    EndIf
    End	
		
Return()

/*/{Protheus.doc} fExcFileMRH
//Exclui arquivos da pasta system
//Usado para eliminar os temporarios da geracao PDF: Informe, Recibo e Espelho do Ponto
@author:	Marcelo Silveira
@since:		06/11/2019
@return:	Nil	
/*/
Function fExcFileMRH( cTpFile )
	
	Local cPath			:= GetSrvProfString("STARTPATH","")
	
	Default cTpFile 	:= ""
	
	//Verifica se foi passado o nome do arquivo que sera excluido
	//Nao sera considerado se vier somente o startPath na variavel 
	If Len(cTpFile) > Len(cPath)
		aEval( Directory(cTpFile), { |aArqToExc| fEraseArq( aArqToExc[1] ) })
	EndIf

Return

/*/{Protheus.doc} fEraseArq
//Exclui o arquivo fisico
@author:	Marcelo Silveira
@since:		18/03/2020
@return:	Nil	
/*/
STATIC Function fEraseArq( cArqToExc )

Local cExtensao := ".PDF|.PD_|.REL" //Extensoes de arquivos que podem ser excluidos

Default cArqToExc  := ""

If !Empty(cArqToExc)
	//Verifica pela extensao se o arquivo podera ser excluido 
	If SubStr( UPPER(cArqToExc), LEN(cArqToExc)-3, 4 ) $ cExtensao
		FERASE( cArqToExc )
	EndIf
EndIf	

Return

/*/{Protheus.doc} getPermission
//Veririca se o usuario pode acessar determinada rotina/recurso
@author:	
@since:		
@param:		cFilSolic = Filial do funcionario que esta solicitando a consulta
			cMatSolic = Matricula do funcionario que esta solicitando a consulta
			cFilValid = Filial do funcionario que esta sendo consultado
			cMatValid = Matricula do funcionario que esta sendo consultado			
			cEmpSolic = Empresa do funcionario que esta solicitando a consulta
			cEmpValid = Empresa do funcionario que esta sendo consultado
			cRoutine  = Qual rotina da AI8 (AI8_ROTINA) ser� considerada para verificar a vis�o.
@return:	lRet - Verdadeiro/Falso caso o usucario tenha permissao para acessar a rotina/recurso	
/*/
Function getPermission(cFilSolic, cMatSolic, cFilValid, cMatValid, cEmpSolic, cEmpValid, cRoutine)

Local aArea      := GetArea()
Local cKeyLider	 := ""
Local cKeySubord := ""
Local lRet		 := .T.
Local cOrgCFG	 := SuperGetMv("MV_ORGCFG", NIL, "0")
Local nKeyIni	 := TamSX3("QB_KEYINI")[1]
Local nLenLider  := 0
Local nLenSubor  := 0

DEFAULT cRoutine  := "W_PWSA100A.APW" // Ferias - Utilizada para buscar a VISAO a partir da rotina
DEFAULT cEmpSolic := cEmpAnt
DEFAULT cEmpValid := cEmpAnt

If empty(cFilSolic) .or. ;
   empty(cMatSolic) .or. ;
   empty(cFilValid) .or. ;
   empty(cMatValid)
   lRet := .F.
EndIf

//Nao verifica as permissoes quando o funcionario esta consultando seus proprios dados
//Somente checa para o ORGCFG = 0. Outras hier�rquias, neste momento, n�o ser�o checadas.
If lRet .And. cOrgCFG == "0" .And. !( cFilSolic+cMatSolic+cEmpSolic == cFilValid+cMatValid+cEmpValid )

	//Primeira checagem. Gestor � lider direto do departamento do liderado.
	lRet := ( fMHRResp( cFilValid, cMatValid ) ==  cFilSolic + cMatSolic )

	// Caso n�o seja o lider direto, checa o QB_KEYINI
	If !lRet 
		// Primeiro, busca o QB_KEYINI do gestor.
		cKeyLider := AllTrim( fMHRKeyTree(cFilSolic, cMatSolic, nKeyIni) )

		// Segundo, busca QB_KEYINI do subordinado.
		cKeySubord := AllTrim( fMHRKeyTree(cFilValid, cMatValid, nKeyIni) )

		nLenLider  := Len( cKeyLider )
		nLenSubor  := Len( cKeySubord )
		
		//Garante que KEYINI do subordinado seja sempre maior ou igual ao do gestor.
		nLenLider := Iif( nLenLider > nLenSubor, nLenSubor, nLenLider )

		// Se o usu�rio logado for gestor e este possuir a mesma chave de hierarquia do subordinado, ent�o fazem parte da mesma estrutura
		// Logo, o gestor poder� consultar.
		lRet := ( Left( cKeySubord, nLenLider ) == cKeyLider )
	EndIf
EndIf

RestArea( aArea )

Return(lRet)

/*/{Protheus.doc} fStatusLabel
Retorna o statuslabel de acordo com o status
@author:	Henrique Ferreira
@since:		10/12/2019
@param:		cStatus  - Status a ser tratado;

@return: Descri��o do status label.
/*/
Function fStatusLabel(cStatus)
Local cStatusLabel := ""

DEFAULT cStatus := ""

Do Case
	Case (cStatus) == "1"
		cStatusLabel := EncodeUTF8(STR0004) // Em processo de aprova��o
	Case (cStatus) == "2"
		cStatusLabel := EncodeUTF8(STR0005) // Atendida
	Case (cStatus) == "3"
		cStatusLabel := EncodeUTF8(STR0006) // Reprovada
	Otherwise
		cStatusLabel := EncodeUTF8(STR0007) // Aguardando efetiva��o do RH
End Case

Return cStatusLabel


Function getRGKJustify(cFil,cCode,cSeq,lLastSeq)
Local cQueryRGK := GetNextAlias()
Local cQueryRDY := GetNextAlias()
Local cFilRDY   := ""
Local cJustify  := ""
Local cFilRGK   := ""
Local cChave    := ""
Local cWhere    := "%"

DEFAULT cFil     := ""
DEFAULT cCode    := ""
DEFAULT cSeq     := ""
DEFAULT lLastSeq := .F.

If !empty(cSeq)
   cWhere += " RGK.RGK_SEQUEN = " +cSeq +" AND "
EndIf
cWhere += "%"

If !empty(cCode)

	BEGINSQL ALIAS cQueryRGK
		SELECT RGK.RGK_CODCON,RGK.RGK_FILIAL
		FROM %table:RGK% RGK
			WHERE RGK.RGK_FILIAL  = %exp:cFil%  AND
			      RGK.RGK_CODIGO  = %exp:cCode% AND
                  RGK.RGK_CODCON != ' '         AND
				  %Exp:cWhere% 
                  RGK.%notDel%
	ENDSQL
	
	If !(cQueryRGK)->(Eof() )
		If lLastSeq
			WHILE !(cQueryRGK)->(Eof())
				cChave  += "'" + (cQueryRGK)->RGK_CODCON + "',"
				cFilRGK := (cQueryRGK)->RGK_FILIAL
				(cQueryRGK)->( dbSkip() )
			END
			cChave := "%" + SubStr(cChave,1,Len(cChave)-1) + "%"
		Else
			cFilRGK := (cQueryRGK)->RGK_FILIAL
			cChave  := "%'" + (cQueryRGK)->RGK_CODCON + "'%"
		EndIf

		cFilRDY := "%'" + xFilial('RDY', cFilRGK) + "'%"

		BEGINSQL ALIAS cQueryRDY
			SELECT RDY.RDY_TEXTO
			FROM %table:RDY% RDY
				WHERE RDY.RDY_FILIAL = %exp:cFilRDY%  AND
					RDY.RDY_CHAVE IN (%exp:cChave% ) AND
					RDY.%notDel%
		ENDSQL

		If lLastSeq
			WHILE !(cQueryRDY)->(Eof())
				cJustify := (cQueryRDY)->RDY_TEXTO
				(cQueryRDY)->( dbSkip() )
			END
		Else
			cJustify := (cQueryRDY)->RDY_TEXTO
		EndIf
		(cQueryRDY)->(DbCloseArea())
	EndIf
	(cQueryRGK)->(DbCloseArea())

EndIf

Return(EncodeUTF8(cJustify))


/*/{Protheus.doc} fMHRTableJoin
//Tratamento do campo filial para uso em queryes quando envolver tabelas com compartilhamento diferente
@author:	Marcelo Silveira
@since:		14/04/2020
@param:		ExpC1 - Vari�vel com Primeira tabela do "inner join"
			ExpC2 - Vari�vel com Segunda  tabela do "inner join"
			ExpC3 - Vari�vel indica se retorno dever� conter "%   %". Default = ""
@return:	cFilJoin - Campo filial das tabelas com Substring ou SubStr	
/*/
Function fMHRTableJoin( cTabela1, cTabela2, cEmbedded )

Local cFilJoin := ""

Default cEmbedded := ""

cFilJoin := cEmbedded + FWJoinFilial(cTabela1, cTabela2) + cEmbedded

If ( TCGETDB() $ 'DB2|ORACLE|POSTGRES|INFORMIX' )
	cFilJoin := STRTRAN(cFilJoin, "SUBSTRING", "SUBSTR")
EndIf

Return( cFilJoin )

/*/{Protheus.doc} fInvString
//Fun��o para inverter uma string
@author:	Henrique Ferreira
@since:		28/04/2020
@param:		cString - String a ser invertida

@return:	cRet - String invertida.	
/*/
Function fInvString(cString)

Local nX		:= 0
Local cRet		:= ""
Local nTamanho	:= Len(cString)

DEFAULT cString := ""

For nX := nTamanho To 1 Step -1
	cRet += SubStr(cString,nX,1)
Next nX

Return cRet

/*/{Protheus.doc} fRemoveStr
//Fun��o para remover uma substring de uma string
@author:	Henrique Ferreira
@since:		28/04/2020
@param:		cString - String a ser pesquisada.

@return:	cRet - String com os caracteres removidos.	
/*/
Function fRemoveStr(cString)

Local cStrOne	:= "<||$&%||>"
Local cStrTwo	:= ">[/;-="
Local cStrThree := "&%#@>.<"

If ( cStrOne $ cString )
	cString := StrTran(cString, cStrOne, "")
EndIf

If ( cStrTwo $ cString )
	cString := StrTran(cString, cStrTwo, "")
EndIf

If ( cStrThree $ cString)
	cString := StrTran(cString, cStrThree, "")
EndIf

Return cString


/*/{Protheus.doc} fMHRKeyTree
//Tratamento do campo filial para uso em queryes quando envolver tabelas com compartilhamento diferente
@author:	Marcelo Faria
@since:		28/04/2020
@param:		cFil - Filial do Funcion�rio
			cMat - Matr�cula do Funcion�rio
@return:	cKeyTree - Chave principal da arvore na estrutura	
/*/
Function fMHRKeyTree(cFil, cMat, nSize)
Local cKeyTree	:= ""
Local aArea		:= GetArea()
Local cOrgCFG	:= SUPERGETMV("MV_ORGCFG")

Default cFil	:= ""
Default cMat	:= ""
Default nSize   := 3

	If !empty(cFil) .and. !empty(cMat) .and. cOrgCFG == '0'

		DbSelectArea("SRA")
		If SRA->(DbSeek(cFil+cMat))

			DbSelectArea("SQB")
			If SQB->(DbSeek(xFilial("SQB", SRA->RA_FILIAL)+ SRA->RA_DEPTO))
				cKeyTree := Left(SQB->QB_KEYINI,nSize)
			EndIf

		EndIf	

	EndIf

RestArea(aArea)
Return( cKeyTree )

/*/{Protheus.doc} fRetDataReq
Essa funcao retorna os dados do cabecalhado de uma requisicao (RH3) a partir da validacao de um dado do item da requisicao (RH4)
@type function
@version 1.1
@author jose.silveira
@since 31/08/2020
@return Array, Retorna os campos da requisicao: RH3_EMP, RH3_FILIAL, RH3_CODIGO, RH3_STATUS, RH3_NVLAPR
/*/
Function fRetDataReq( cFilRH3, cMatRH3, cEmpRH3, cTpReq, cCodRH3, aCpoRH4, aValRH4 )

Local aRet			:= {}
Local aCompRH4		:= {}
Local nX 			:= 0
Local nNumCpos		:= 5 //Indica o numero fixo de campos da tabela RH3 que sera retornado (RH3_EMP, RH3_FILIAL, RH3_CODIGO, RH3_STATUS, RH3_NVLAPR)
Local lAdd			:= .F.
Local cQryRH3		:= ""
Local cCpoRH4		:= ""
Local cSX3Tipo		:= ""
Local cCpoQry		:= ""
Local cQryRH4		:= "%%"
Local cFiltro		:= "%%"
Local cRH3Del		:= "% RH3.D_E_L_E_T_ = ' ' %"
Local cRH4Del		:= "% RH4.D_E_L_E_T_ = ' ' %"

DEFAULT cEmpRH3		:= cEmpAnt
DEFAULT cCodRH3		:= ""
DEFAULT aCpoRH4		:= {}
DEFAULT aValRH4		:= {}

nCpoRH4 	:= Len(aCpoRH4)
nValRH4 	:= Len(aValRH4)

If nCpoRH4 == nValRH4 .And. nCpoRH4 > 0

	//Trata os campos e valores da tabela RH4 que serao avaliados e comparados. 
	//Os arrays precisam ter a mesma quantidade de elementos para que campo e valor possam ser comparados em pares 
	//Exemplo x[1] = campo R8_DATAINI (DATA) e ser� comparado com y[1] que precisa ter o mesmo tipo ex.: '99/99/9999'
	For nX := 1 To Len( aCpoRH4 )
		cSX3Tipo := FWSX3Util():GetFieldType( aCpoRH4[nX] )
		cCpoRH4  += "'" + aCpoRH4[nX] + "',"
		aAdd( aCompRH4, { aCpoRH4[nX], cSX3Tipo, aValRH4[nX] } )
	Next nX

	If !Empty( cCpoRH4 )
		cCpoRH4	:= SubStr(cCpoRH4, 2, Len(cCpoRH4)-3 )
		cCpoQry := "% RH4.RH4_CAMPO IN ('" + cCpoRH4 +"') %"
	EndIf

	//� possivel validar o valor de uma requisicao especifica
	If !Empty( cCodRH3 )
		cFiltro := "% AND RH3_CODIGO = '" + cCodRH3 +"' %"
	EndIf

	cQryRH3	:= GetNextAlias()

	BeginSql alias cQryRH3
		SELECT RH3_EMP, RH3_FILIAL, RH3_CODIGO, RH3_STATUS, RH3_NVLAPR
		FROM  %table:RH3% RH3
		WHERE
			%exp:cRH3Del% AND
			RH3.RH3_FILIAL = %exp:cFilRH3% AND
			RH3.RH3_MAT = %exp:cMatRH3% AND
			RH3.RH3_EMP = %exp:cEmpRH3% AND
			RH3.RH3_TIPO = %exp:cTpReq% AND
			RH3.RH3_STATUS <> '3'
			%exp:cFiltro%				
		ORDER BY 1, 2, 3 DESC
	EndSql

	While !(cQryRH3)->(Eof())

		cQryRH4 := GetNextAlias()

		BeginSql alias cQryRH4
			SELECT *
			FROM  %table:RH4% RH4
			WHERE
				RH4.RH4_CODIGO = %exp:(cQryRH3)->RH3_CODIGO% AND			
				%exp:cRH4Del% AND
				%exp:cCpoQry%
		EndSql

		While !(cQryRH4)->(Eof())

			//Compara o campo com o valor correspondente que sera validado na RH4 conforme seu tipo
			For nX := 1 To nCpoRH4
				If AllTrim((cQryRH4)->RH4_CAMPO) == aCompRH4[nX, 1]
					If aCompRH4[nX, 2] == "N"
						lAdd := ( aCompRH4[nX, 3] == Val( AllTrim((cQryRH4)->(RH4_VALNOV)) ) )
					ElseIf aCompRH4[nX, 2] == "D"
						lAdd := ( aCompRH4[nX, 3] == cToD( AllTrim((cQryRH4)->(RH4_VALNOV)) ) )
					Else
						lAdd := ( UPPER(aCompRH4[nX, 3]) == UPPER(AllTrim((cQryRH4)->(RH4_VALNOV))) )
					EndIf
					If !lAdd
						Exit
					EndIf
				EndIf
			Next nX

			(cQryRH4)->(DBSkip())

		Enddo

		If lAdd
			If Empty(aRet)
				aRet := Array(1, nNumCpos, "" )				
				aRet[1,1] := (cQryRH3)->RH3_EMP
				aRet[1,2] := (cQryRH3)->RH3_FILIAL
				aRet[1,3] := (cQryRH3)->RH3_CODIGO
				aRet[1,4] := (cQryRH3)->RH3_STATUS
				aRet[1,5] := (cQryRH3)->RH3_NVLAPR
			Else
				aAdd( aRet, { ;
						(cQryRH3)->RH3_EMP, ;
						(cQryRH3)->RH3_FILIAL, ; 
						(cQryRH3)->RH3_CODIGO, ;
						(cQryRH3)->RH3_STATUS, ;
						(cQryRH3)->RH3_NVLAPR ;
					})
			EndIf
		EndIf		

		(cQryRH4)->(DBCloseArea())

		(cQryRH3)->(DBSkip())
	Enddo
	(cQryRH3)->(DBCloseArea())

EndIf

Return(aRet)


/*/{Protheus.doc} fClearStr
Fun��o que limpa os caracteres especiais da string
@type function
@version 1.0
@author marcelo.faria
@since 13/10/2020
@return cConteudo
/*/
Function fClearStr(cConteudo)
Default cConteudo := ""

If !empty(cConteudo) .And. VALTYPE(cConteudo) == 'C'     
    //Retirando caracteres
    cConteudo := StrTran(cConteudo, "'", "")
    cConteudo := StrTran(cConteudo, "#", "")
    cConteudo := StrTran(cConteudo, "%", "")
    cConteudo := StrTran(cConteudo, "*", "")
    cConteudo := StrTran(cConteudo, "&", "")
    cConteudo := StrTran(cConteudo, ">", "")
    cConteudo := StrTran(cConteudo, "<", "")
    cConteudo := StrTran(cConteudo, "!", "")
    cConteudo := StrTran(cConteudo, "@", "")
    cConteudo := StrTran(cConteudo, "$", "")
    cConteudo := StrTran(cConteudo, "(", "")
    cConteudo := StrTran(cConteudo, ")", "")
    cConteudo := StrTran(cConteudo, "_", "")
    cConteudo := StrTran(cConteudo, "=", "")
    cConteudo := StrTran(cConteudo, "+", "")
    cConteudo := StrTran(cConteudo, "{", "")
    cConteudo := StrTran(cConteudo, "}", "")
    cConteudo := StrTran(cConteudo, "[", "")
    cConteudo := StrTran(cConteudo, "]", "")
    cConteudo := StrTran(cConteudo, "/", "")
    cConteudo := StrTran(cConteudo, "?", "")
    cConteudo := StrTran(cConteudo, ".", "")
    cConteudo := StrTran(cConteudo, "\", "")
    cConteudo := StrTran(cConteudo, "|", "")
    cConteudo := StrTran(cConteudo, ":", "")
    cConteudo := StrTran(cConteudo, ";", "")
    cConteudo := StrTran(cConteudo, '"', '')
    cConteudo := StrTran(cConteudo, '�', '')
    cConteudo := StrTran(cConteudo, '�', '')
    cConteudo := StrTran(cConteudo, ",", "")
    cConteudo := StrTran(cConteudo, "-", "")
EndIf

Return cConteudo


/*/{Protheus.doc} fSegLogin
O objetivo dessa fun��o � realizar o login e centralizar o controle de politica de seguran�a
@type function
@version 1.0
@author marcelo.faria
@since 07/10/2020
@return .T./.F. (Caso o usu�rio informe a senha corretamente e esteja dentro da pol�tica de seguran�a)
/*/
Function fSegLogin( cUsrSenha, cRD0Senha, cRD0SenhaC, lRest )
Local lRet			:= .F.
Local nPolSeg		:= SuperGetMv("MV_POLSEG", .F. , 0)
Local lSenhaC		:= RD0->(ColumnPos("RD0_SENHAC")) > 0
Local lSHA512		:= .F.
Local lAddHist		:= .F.

default cUsrSenha	:= ""	
default cRD0Senha	:= ""
default cRD0SenhaC	:= ""
default lRest		:= .F.

If lSenhaC
	lSHA512	:= IIf(TamSX3("RD0_SENHAC")[1]==128, .T. , .F.)
EndIf

If !Empty(cUsrSenha)

	If (nPolSeg == 0  .Or. !lSenhaC) .Or. (!lRest .And. nPolseg != 2)

		//processo de autentica��o realizado pelo modelo padr�o quando n�o avalia politica de seguran�a
		//ou a requisi��o de login n�o vier de uma API REST
		If Upper(AllTrim(Embaralha(cRD0Senha,1))) == Upper(AllTrim(cUsrSenha))
			lRet := .T.
		EndIf

	Else

		//Avalia se o parametro para politica de seguran�a est� ligada para o MeuRH e a requisi��o  
		//veio do app, caso positivo, atualiza automaticamente o campo de senha criptografada com a 
		//senha atual antes de realizar a valida��o/compara��o da senha.
		// 
		//O objetivo � que n�o seja necess�rio executar nenhuma carga inicial ao ligar o par�metro
		//ou seja, deixamos a execu��o de maneira transparente, atualizando no processo de autentica��o.
		//
		//O Novo modelo de criptografia n�o atualiza mais o campo RA_SENHA, pois o mesmo era 
		//utilizado no antigo Portal TCF(produto descontinuado)
		If ( nPolSeg == 1 .and. empty(cRD0SenhaC) .and. lRest ) .Or.; //MeuRH
		 	( nPolSeg ==2 .and. empty(cRD0SenhaC) ) //Portal GCH

			Begin Transaction
				If RecLock("RD0")

					If lSHA512
						//Cliente possui tamanho do campo RD0_SENHAC atualizado no dicionario
						RD0->RD0_SENHAC := SHA512(AllTrim(cUsrSenha))
					Else
						//Cliente possui tamanho padr�o(40) do campo RD0_SENHAC no dicionario
						RD0->RD0_SENHAC := SHA1(AllTrim(cUsrSenha))
					EndIf

					RD0->( MsUnlock() )
					lRet := .T.
					lAddHist := .T.
				EndIf
			End Transaction
		EndIf

		//Tratamento para prever clientes que migraram de release � o tamanho do campo
		//RD0_SENHAC passou de 40 posi��es para 128 posi��es, nesse sentido, atualizamos
		// de maneira transparente a senha atual para o novo modelo de hash SHA512 
		If 	(nPolSeg == 1 .and. lSHA512 .and. !empty(cRD0SenhaC) .and. len(cRD0SenhaC) == 40 .and. lRest) .OR.; //MeuRH
			(nPolSeg == 2 .and. lSHA512 .and. !empty(cRD0SenhaC) .and. len(cRD0SenhaC) == 40) //Portal GCH

			//Primeiro valida se o usu�rio preencheu a senha corretamente, caso positivo 
			//atualiza a senha automaticamente para o novo modelo hash antes da valida��o
			If SHA1(AllTrim(cUsrSenha)) == AllTrim(cRD0SenhaC)  
				Begin Transaction
					If RecLock("RD0")
						RD0->RD0_SENHAC := SHA512(AllTrim(cUsrSenha))
						RD0->( MsUnlock() )
						lRet := .T.
						lAddHist := .T.
					EndIf
				End Transaction
			EndIf	

		EndIf

		//Valida��o do login
		If lSHA512
			If SHA512(AllTrim(cUsrSenha)) == AllTrim(cRD0SenhaC)  
				lRet := .T.
			Endif
		Else
			If SHA1(AllTrim(cUsrSenha)) == AllTrim(cRD0SenhaC)  
				lRet := .T.
			Endif
		EndIf

		//Guarda a senha na tabela de historico
		If lAddHist .And. AliasInDic("A30")
			RecLock("A30", .T.)
			A30->A30_FILIAL := RD0->RD0_FILIAL
			A30->A30_CODIGO := RD0->RD0_CODIGO
			A30->A30_DATA   := dDataBase
			A30->A30_HORA   := NoRound( milisSecondsToHour(Seconds()*1000,Seconds()*1000)[2], 2 )
			A30->A30_SENHAC := AllTrim(RD0->RD0_SENHAC)
			A30->( MsUnlock() )		
		EndIf

	EndIf

EndIf

Return(lRet)


/*/{Protheus.doc} fPwdChange
O objetivo dessa fun��o � atualizar a senha do usu�rio MeuRH/Portal GCH, utilizando a nova politica de seguran�a
@type function
@version 1.0
@author marcelo.faria
@since 07/10/2020
@return .T./.F. (Caso a senha tenha sido alterada com sucesso)
/*/
Function fPwdChange( cNovaSenha )
Local cQuery        := GetNextAlias()
Local nPolSeg		:= SuperGetMv("MV_POLSEG", .F. , 0)
Local lSenhaC		:= RD0->(ColumnPos("RD0_SENHAC")) > 0
Local lRet			:= .F.
Local lSHA512		:= .F.
Local lAddHist		:= .F.
Local nTime         := 0
Local cA30Qry       := ""
Local cWhere        := ""
Local cPrepSenha	:= ""

If lSenhaC
	lSHA512	:= IIf(TamSX3("RD0_SENHAC")[1]==128, .T. , .F.)
EndIf

default cNovaSenha	:= ""

If !Empty(cNovaSenha)
    Begin Transaction

		//atualizando senha do registro RD0 ponterado na mem�ria
		If RecLock("RD0")

			//Inicializa campo reset password caso exista na base
			If RD0->(ColumnPos("RD0_RSTPWD")) > 0
				RD0->RD0_RSTPWD := ""
			EndIf
			
			//Zera o contador de senhas incorretas caso exista na base
			If RD0->(ColumnPos("RD0_ULI")) > 0
				RD0->RD0_ULI := 0
			EndIf

			If nPolSeg > 0 .And. lSenhaC

				If lSHA512
					//Cliente possui tamanho do campo RD0_SENHAC atualizado no dicionario
					RD0->RD0_SENHAC := SHA512(AllTrim(cNovaSenha))
				Else
					//Cliente possui tamanho padr�o(40) do campo RD0_SENHAC no dicionario
					RD0->RD0_SENHAC := SHA1(AllTrim(cNovaSenha))
				EndIf

				lAddHist := .T.
			Else

				//Prepara e atualiza nova senha para modelo padr�o
				cPrepSenha := Upper(AllTrim(cNovaSenha))
				cPrepSenha := Padr(cPrepSenha,6)
				cPrepSenha := Embaralha(cPrepSenha, 0)

				RD0->RD0_SENHA  := cPrepSenha

				//atualiza SRA
				cWhere := "%AND RDZ.RDZ_ENTIDA='SRA' AND RDZ.RDZ_CODRD0='" +RD0->(RD0_CODIGO) +"'%"
				BEGINSQL ALIAS cQuery
					SELECT RDZ.RDZ_CODRD0, RDZ.RDZ_CODENT
					FROM %table:RDZ% RDZ
					WHERE RDZ.%notDel%
						%exp:cWhere%
				ENDSQL

				While !(cQuery)->(Eof()) .And. ((cQuery)->RDZ_CODRD0==RD0->(RD0_CODIGO))
					DbSelectArea("SRA")
					DbSetOrder(1)
					If SRA->( DbSeek( AllTrim((cQuery)->RDZ_CODENT) ) )
						SRA->( Reclock("SRA",.F.) )
						SRA->RA_SENHA := cPrepSenha
						SRA->( Msunlock() )
					EndIf

					(cQuery)->(dbSkip())
				EndDo
				(cQuery)->(dbCloseArea())
			EndIf

			RD0->( MsUnlock() )
			lRet := .T.

		EndIf

		//Guarda a senha na tabela de historico
		If lAddHist .And. AliasInDic("A30")

			//Tratamento para evitar erro devido altera��es em sequencia no mesmo minuto
			cA30Qry := GetNextAlias()
			nTime   := NoRound( milisSecondsToHour(Seconds()*1000,Seconds()*1000)[2], 2 )
			
			BEGINSQL ALIAS cA30Qry
				SELECT A30_DATA, A30_HORA
				FROM
					%Table:A30% A30
				WHERE
					A30.A30_FILIAL = %Exp:RD0->(RD0_FILIAL)% AND
					A30.A30_CODIGO = %Exp:RD0->(RD0_CODIGO)% AND
					A30.A30_DATA = %Exp:DTOS(dDataBase)% AND
					A30.%NotDel%
				ORDER BY 1 DESC, 2 DESC 
			ENDSQL

			If !(cA30Qry)->(Eof())
				If (cA30Qry)->A30_HORA >= nTime
					nTime := __TimeSum( (cA30Qry)->A30_HORA, 0.01 )
				EndIf
			EndIf

			(cA30Qry)->(dbCloseArea())

			RecLock("A30", .T.)
			A30->A30_FILIAL := RD0->RD0_FILIAL
			A30->A30_CODIGO := RD0->RD0_CODIGO
			A30->A30_DATA   := dDataBase
			A30->A30_HORA   := nTime
			A30->A30_SENHAC := AllTrim(RD0->RD0_SENHAC)
			A30->( MsUnlock() )		
		EndIf

    End Transaction
EndIf

Return(lRet)


/*/{Protheus.doc} fPwdValid
O objetivo dessa fun��o � validar a nova politica de seguran�a
@type function
@version 1.0
@author marcelo.faria
@since 07/10/2020
@return cFault 
/*/
Function fPwdValid( cPwd, nTypeValid, cOldPwd, lPwdRules ) 
Local cFault		:= ""
Local cValid		:= ""
Local cOldValid		:= ""
Local lSenhaC		:= RD0->(ColumnPos("RD0_SENHAC")) > 0
Local lSHA512		:= .F.

default cPwd		:= ""
default nTypeValid	:= 0
default cOldPwd		:= ""
default lPwdRules	:= .F.

If lSenhaC
	lSHA512	:= IIf(TamSX3("RD0_SENHAC")[1]==128, .T. , .F.)
EndIf

If !empty(cPwd) .And. nTypeValid > 0 .And. lSenhaC

	If nTypeValid == 1
		//inicialmente ser� validado apenas se a senha possui letras e n�meros 
		cValid := fClearStr(cPwd)

		If cValid != cPwd
			cFault := OemToAnsi(STR0008) //"� permitido utilizar apenas letras e n�meros para senha"
		EndIf

		If empty(cFault)
			cValid := FwNoAccent(cPwd)
			If cValid != cPwd
				cFault := OemToAnsi(STR0009) //"N�o s�o permitidos caracteres acentuados para senha"
			EndIf
		EndIf
	EndIf	

	If nTypeValid == 2
		If lSHA512
			//Cliente possui tamanho do campo RD0_SENHAC atualizado no dicionario
			cValid := SHA512(AllTrim(cPwd))
			cOldValid := SHA512(AllTrim(cOldPwd))
		Else
			//Cliente possui tamanho padr�o(40) do campo RD0_SENHAC no dicionario
			cValid := SHA1(AllTrim(cPwd))
			cOldValid := SHA1(AllTrim(cOldPwd))
		EndIf

		If !lPwdRules .And. cValid == RD0->RD0_SENHAC
			cFault := OemToAnsi(STR0010) //"Utilize uma senha diferente da atual"
		EndIf

		//Quando for alteracao verifica se a �ltima senha informada est� correta
		If !Empty(cOldPwd) .And. !(cOldValid == RD0->RD0_SENHAC)
			cFault := OemToAnsi(STR0011) //"A senha antiga est� incorreta."
		EndIf
	EndIf	

EndIf

Return(cFault)


/*/{Protheus.doc} GetMvMrh
O objetivo dessa fun��o � obter o valor de um determinado par�metro.
Como no MeuRH n�o utiliza-se o conceito do cFilAnt, trocamos o cFilAnt conforme a filial do token para buscar o MV
@type function
@version 1.0
@author henrique.ferreira
@since 07/05/2021
@return xRet
/*/
Function GetMvMrh(cParametro,lHelp,xDefault,cBranchVld)
Local cBkpFil := cFilAnt
Local xRet 	  := Nil

cFilAnt := cBranchVld
xRet    := GetMv(cParametro,lHelp,xDefault)
cFilAnt := cBkpFil

Return xRet

/*/{Protheus.doc} fNewEmpFiles
Realiza a abertura de tabelas conforme o grupo de empresa e filial recebido por parametro
A funcao que originou sua chamada deve ser responsavel por guardar os dados originais para restaurar depois
@type function
@version 1.0
@author Marcelo Silveira
@since 24/05/2021
@return Nil
/*/
Function fNewEmpFiles(cNewEmp,cNewFil,aTables,lPosEmp)

Local nX	:= 0
Local nAT	:= 0
Local cModo	:= ""

DEFAULT aTables := {"SRA","RDZ","RD0","SQB","CTT","SRJ","SQ3","SQB","RCX"}
DEFAULT lPosEmp := .F.

SX2->(dbclosearea())

cEmpAnt := cNewEmp
cFilAnt := cNewFil

OpenSxs(,,,,cNewEmp,"SX2","SX2",,.F.)
For nX := 1 To Len( aTables )
	nAT		:= AT(aTables[nX],cArqTab)
	cModo	:= FWModeAccess(aTables[nX])
	cArqTab := If( nAT > 0, SubStr(cArqTab,1,nAT+2)+cModo+SubStr(cArqTab,nAT+4), cArqTab+aTables[nX]+cModo+"/"  )
	
	EmpOpenFile(aTables[nX],aTables[nX],1,.T.,cNewEmp,cModo)
Next nX

// Fun��es necess�rias para o caso de compartilhamento diferente dos grupos de empresa da SRV.
FWClearXFilialCache() //Limpa o cache do xFilial para posicionamentos futuros na filial correta
RstPosAlias() // Limpa a variavel static aPosAlias, utilizada no PosSrv

//Posiciona na empresa aberta
If( lPosEmp, SM0->(DbSeek(cNewEmp)), .T. )

Return

/*/{Protheus.doc} fDelReqById
Realiza a exclus�o de uma requisicao e das tabelas relacionadas (RH3, RH4, RKG)
@type function
@version 1.0
@author Marcelo Silveira
@since 01/07/2021
@return Nil
/*/
Function fDelReqById(cCodFil, cCodMat, cCodReq, cStatus)

	Local lRet		:= .F.
	Local cCodEmp	:= ""
	Local cKey		:= ""
	Local cKeyRGK	:= ""
	Local cDescObj	:= ""
	Local aArea 	:= {}

	DEFAULT cCodFil	:= ""
	DEFAULT cCodMat	:= ""
	DEFAULT cCodReq	:= ""
	DEFAULT cStatus	:= ""

	If !Empty(cCodFil) .And. !Empty(cCodReq)

		aArea 	:= getArea()
		cKey 	:= cCodFil + cCodReq

		dbSelectArea("RH3")
		dbSetOrder(1)
		If RH3->( dbSeek( cKey ) )

			If Empty(cStatus) .Or. (cStatus == RH3->RH3_STATUS)

				cCodEmp  := RH3->RH3_EMP
				cCodMat  := If( Empty(cCodMat), RH3->RH3_MAT, cCodMat)
				cKeyRGK	 := cCodFil + cCodMat + cCodReq
				If !Empty( RH3->RH3_BITMAP )
					cDescObj := RH3->RH3_BITMAP
				EndIf

				Begin Transaction

					RecLock("RH3",.F.)
					RH3->(dbDelete())
					RH3->(MsUnlock())

					DbSelectArea("RH4")
					RH4->( dbSetOrder(1) )
					If RH4->( dbSeek(cKey) )
						While RH4->(!Eof()) .And. RH4->(RH4_FILIAL+RH4_CODIGO) == cKey
							RecLock("RH4",.F.)
							RH4->(dbDelete())
							RH4->(MsUnlock())
							RH4->(dBSkip())
						EndDo
					EndIf

					DbSelectArea("RGK")
					RGK->( dbSetOrder(1) )
					If RGK->( dbSeek(cKeyRGK) )
						While RGK->(!Eof()) .And. RGK->(RGK_FILIAL+RGK_MAT+RGK_CODIGO) == cKeyRGK
							RecLock("RGK",.F.)
							RGK->(dbDelete())
							RGK->(MsUnlock())
							RGK->(dBSkip())
						EndDo
					EndIf

					If !Empty( cDescObj )
						//Deleta o arquivo do banco de conhecimento
						fDelBcoFile( cCodEmp, cCodFil, cDescObj )
						//Deleta a imagem do reposit�rio de imagens.
						fDelImgRep( cDescObj )
					EndIf

					lRet := .T.

				End Transaction

			EndIf
		EndIf

		RestArea(aArea)
	EndIf

Return(lRet)

/*/{Protheus.doc} AfasDtValid
Fun��o que retorna se existem afastamentos na data solicitada
@type function
@version 1.0
@author Marcelo Silveira
@since 02/07/2021
@return Nil
/*/
Function AfasDtValid(cFil,cMat,cData)

Local aArea			:= GetArea()
Local lRet 			:= .T.
Local cAliasQuery 	:= GetNextAlias()
Local dData			:= cData

BEGINSQL ALIAS cAliasQuery
	SELECT COUNT(*) QTDAFAST
	FROM %table:SR8% SR8
	WHERE R8_FILIAL = %exp:cFil% AND
	R8_MAT = %exp:cMat% AND (
	( R8_DATAINI <= %exp:DtoS(dData)% AND R8_DATAFIM >= %exp:DtoS(dData)% ) OR
	( R8_DATAINI <= %exp:DtoS(dData)% AND R8_DATAFIM = %exp:DtoS(CtoD(''))% )
	) AND
	SR8.%notDel%
ENDSQL

If (cAliasQuery)->(QTDAFAST) > 0
	lRet := .F.
EndIf

(cAliasQuery)->(DbCloseArea())

RestArea(aArea)

Return lRet

/*/{Protheus.doc} xEmpFilial
Fun��o alternativa ao xFilial() para permitir validar o campo filial 
de uma tabela de um grupo diferente daquele que o usuaario est� logado
@author Marcelo Silveira
@since 17/09/2021
/*/
Function xEmpFilial(cTab, cFilPar, cEmp)
	
	Local lOk			:= .T.
	Local nTam			:= 0
	Local cRet			:= cFilAnt
	Local cSaveEmp		:= cEmpAnt
	Local aTabRef		:= {}
	Local aCpoSX2		:= {"X2_MODOEMP", "X2_MODOUN", "X2_MODO", "X2_TAMEMP", "X2_TAMUN", "X2_TAMFIL"}

	DEFAULT cTab 	:= ""
	DEFAULT cEmp 	:= cEmpAnt
	DEFAULT cFilPar := cFilAnt

	If !( cEmp == cSaveEmp )

		SX2->(DBCloseArea())
		OpenSxs(,,,,cEmp,"SX2","SX2",,.F.)
		If Select("SX2") == 0
			lOk := .F.
		Endif

		If lOk
			aTabRef := FWSX2Util():GetSX2Data(cTab, aCpoSX2)

			//Valida no outro grupo o modo de acesso da tabela recebida via par�metro
			If Len(aTabRef) == Len(aCpoSX2)
				
				If aTabRef[1,2] == "E" //Exclusivo por empresa
					nTam += aTabRef[4,2]

					If aTabRef[2,2] == "E" //Exclusivo por Unidade de Negocio
						nTam += aTabRef[5,2]

						If aTabRef[3,2] == "E" //Exclusivo por Filial
							nTam += aTabRef[6,2]
						EndIf
					EndIf
				EndIf

				If nTam == 0 //Tabela compartilhada em todos os niveis
					cRet := Space( FWSizeFilial() )
				Else
					cRet := SubStr( cFilPar, 1, nTam )
				EndIf
			Else
				cRet := xFilial(cTab,cFilPar)
			EndIf
		EndIf

		SX2->(DBCloseArea())
		OpenSxs(,,,,cSaveEmp,"SX2","SX2",,.F.)
	Else
		cRet := xFilial(cTab,cFilPar)
	EndIf

Return cRet

/*/{Protheus.doc} getWKFByDesc
Fun��o para filtrar as solicita��es conforme a descri��o 
@author Henrique Ferreira
@since 17/11/2021
/*/
Function getWKFByDesc(cDescStatus)

Local cStatus := ""
Local aStatus := StrTokArr(cDescStatus, ",")
Local nLen	  := Len(aStatus)
Local nX      := 0

If nLen > 0
	For nX := 1 to nLen
		If nX > 1
			cStatus += ","
		EndIf
		Do Case
			Case aStatus[nX] == "approved"
				cStatus += "'4'"
			Case aStatus[nX] == "approving"
				cStatus += "'1'"
			Case aStatus[nX] == "rejected"
				cStatus += "'3'"
			Case aStatus[nX] == "close"
				cStatus += "'2'"
			OTHERWISE
				LOOP
		EndCase
	Next nX
EndIf

If Empty(cStatus)
	cStatus := "'1','4'"
EndIf

Return cStatus

/*/{Protheus.doc} getValueByQP
Fun��o para buscar filtrar conforme o conteudo de um query param. 
@author Henrique Ferreira
@since 17/11/2021
/*/
Function getValueByQP(cValue, nTamFil)

Local cCods   := ""
Local aCods   := StrTokArr(cValue, ",")
Local nLen	  := Len(aCods)
Local nX      := 0

Default nTamFil := FWSizeFilial()

If nLen > 0
	For nX := 1 to nLen
		If nX > 1
			cCods += ","
		EndIf
		cCods += "'"
		cCods += SubStr( aCods[nX], nTamFil+1, Len( aCods[nX] ) )
		cCods += "'"
	Next nX
EndIf

Return cCods


Function fChkRH3Apr(cBranchVld, cMatSRA)

Local aArea	 := GetArea()
Local cQuery := GetNextAlias()
Local lRet := .F.

DEFAULT cBranchVld := ""
DEFAULT cMatSRA    := ""


If !Empty(cBranchVld) .And. !Empty(cMatSRA)
	BEGINSQL ALIAS cQuery
		SELECT COUNT(*) QTDAPROV
		FROM %table:RH3% RH3
		WHERE RH3_FILAPR = %exp:cBranchVld% AND
		RH3_MATAPR = %exp:cMatSRA% AND
		RH3_STATUS = '1' AND //Somente solicita��es em aprova��o com o funcion�rio.
		RH3.%notDel%
	ENDSQL

	If (cQuery)->(QTDAPROV) > 0
		lRet := .T.
	EndIf

	(cQuery)->(DbCloseArea())
EndIf
RestArea(aArea)

Return lRet


/*/{Protheus.doc} fGetRANome
Retorna o nome do funcion�rio conforme a empresa. 
@author Henrique Ferreira
@since 20/04/2022
/*/
Function fGetRANome(cCodFil, cCodMat, cCodEmp)

Local cQrySRA   := GetNextAlias()
Local cNome	    := ""
Local cSRAtab   := ""
Local cEmpSRA 	:= ""
Local lNomeSoc  := .F.

DEFAULT cCodEmp := cEmpAnt

If !Empty(cCodFil) .And. !Empty(cCodMat)
	cEmpSRA	 := If( Empty(cCodEmp), cEmpAnt, cCodEmp ) 
	cSRAtab  := "%" + RetFullName("SRA", cEmpSRA) + "%"
	lNomeSoc := SuperGetMv("MV_NOMESOC", NIL, .F.)

	BeginSql ALIAS cQrySRA
		SELECT RA_NOME, 
			RA_NOMECMP,
			RA_NSOCIAL
		FROM %exp:cSRAtab% SRA
		WHERE 
			SRA.RA_FILIAL = %Exp:cCodFil% AND
			SRA.RA_MAT = %Exp:cCodMat% AND
			SRA.%notDel%
	EndSql

	If (cQrySRA)->(!Eof())
		cNome := If(lNomeSoc .And. !Empty((cQrySRA)->RA_NSOCIAL), (cQrySRA)->RA_NSOCIAL, (cQrySRA)->RA_NOMECMP)
		cNome := Alltrim(EncodeUTF8(If(Empty(cNome), (cQrySRA)->RA_NOME, cNome)))
	EndIf

	(cQrySRA)->(DbCloseArea())
EndIf

Return cNome

/*/{Protheus.doc} getJoinFilial
Fun��o que realiza a chamada da FWJoinFilial permitindo a execu��o via job para consulta em outros grupos de empresa
@author Marcelo Silveira
@since 14/07/2022
/*/
Function getJoinFilial(xCodEmp, xCodFil, aTables, lJob, cUID)
	
	Local nX			:= 0
	Local aRet			:= {""}

	DEFAULT xCodEmp	:= cEmpAnt
	DEFAULT xCodFil := cFilAnt
	DEFAULT aTables := {}
	DEFAULT lJob 	:= .F.
	DEFAULT cUID 	:= ""

	If Len(aTables) > 0
		If lJob
			//Instancia o ambiente para a empresa onde a funcao sera executada
			RPCSetType( 3 )
			RPCSetEnv( xCodEmp, xCodFil )
		EndIf

		aRet := {}
		For nX := 1 To Len(aTables)
			aAdd( aRet, FWJoinFilial(aTables[nX, 1], aTables[nX, 2]) )
		Next nX

		If lJob
			//Atualiza a variavel de controle que indica a finalizacao do JOB
			PutGlbValue(cUID, "1")
		EndIf
	EndIf

Return aRet

/*/{Protheus.doc} function fSraVal
Realiza a consulta de dados do Funcion�rio
@author  Alberto Ortiz
@since   08/08/2022
@version 1.0
/*/
Function fSraVal(cFilSRA, cMatricula, cCampoRet)

	Local cValor := ""
	Local cAlias := "SRA"
	Local aArea  := GetArea()

	DEFAULT cFilSRA    := ""
	DEFAULT cMatricula := ""
	DEFAULT cCampoRet  := ""


	If !Empty(cFilSRA) .And. !Empty(cMatricula) .And. !Empty(cCampoRet)
		DbSelectArea(cAlias)

		(cAlias)->(dbSetOrder(1)) // RA_FILIAL, RA_MAT
		
		If (cAlias)->(dbSeek(xFilial(cAlias, cFilSRA ) + ALLTRIM(cMatricula)))
			cValor := Alltrim((cAlias)->&(ALLTRIM(cCampoRet)))
		EndIf
		
		RestArea(aArea)
	EndIf

Return cValor

/*/{Protheus.doc} fMHRResp
// Buscar o respons�vel pelo departamento, conforme filial e matr�cula
@author:	Henrique Ferreira
@since:		05/09/2022
@param:		cFil - Filial do Funcion�rio
			cMat - Matr�cula do Funcion�rio
@return:	cRet - Retorno	
/*/
Function fMHRResp(cFil, cMat)
Local cRet	    := ""
Local aArea		:= GetArea()

Default cFil	:= ""
Default cMat	:= ""

If !empty(cFil) .and. !empty(cMat)
	DbSelectArea("SRA")
	DbSetOrder(1)
	If SRA->(DbSeek(cFil+cMat))
		DbSelectArea("SQB")
		DbSetOrder(1)
		If SQB->(DbSeek(xFilial("SQB", SRA->RA_FILIAL)+ SRA->RA_DEPTO))
			cRet := SQB->QB_FILRESP + SQB->QB_MATRESP
		EndIf
	EndIf	
EndIf

RestArea(aArea)
Return( cRet )

/*/{Protheus.doc} fValidAdm
Valida data de admiss�o com a data da batida
@author:	Marcelo Silveira
@since:		25/03/2022
@param:		cBranch - Filial do Funcion�rio
			cMatSRA - Matr�cula do Funcion�rio
			dData - Data a ser comparada com a admiss�o
			cMsgReturn - Mensagem de retorno
@return:	lRet - Identifica��o do per�odo conforme a transferencia
/*/	
Function fValidAdm( cBranch, cMatSRA, dData, cMsgReturn )

Local lRet  := .T.
Local aArea := GetArea()

DEFAULT cBranch 	:= ""
DEFAULT cMatSRA 	:= ""
DEFAULT dData 		:= ctod("//")
DEFAULT cMsgReturn 	:= ""

DbSelectArea("SRA")
DbSetOrder(1)

If SRA->( dbSeek( cBranch + cMatSRA ) )
	If dData < SRA->RA_ADMISSA
		lRet := .F.
		// Aten��o caso precise utilizar a fun��o EncodeUTF8. O lan�amento de marca��o, por ex, encoda no final do endpoint.
		cMsgReturn := STR0013 // "A data do lan�amento n�o pode ser anterior � admissao do funcion�rio."
	EndIf
EndIf

RestArea( aArea )

Return lRet


/*/{Protheus.doc} fHaveAttach
Verifica se a requisi��o tem arquivo anexo.
@author:	Alberto Ortiz
@since:		28/03/2023
@param:		cFilRH3 - Filial da requisi��o
			cCodRH3 - C�digo da requisi��o
@return:	lRH3BitMap - .T. caso a requisi��o tenha arquivo anexo.
/*/	
Function fHaveAttach(cFilRH3, cCodRH3)
	
	Local lRH3BitMap := .F.
	Local aArea		 := GetArea()

	DEFAULT cFilRH3 := ""
	DEFAULT cCodRH3 := ""

	If !Empty(cFilRH3) .And. !Empty(cCodRH3)
	
		DbSelectArea("RH3")
		RH3->(dbSetOrder(1))
		
		If RH3->(dbSeek(cFilRH3 + cCodRH3))
			lRH3BitMap := !Empty(AllTrim(RH3->RH3_BITMAP))
		EndIf

		RH3->(DbCloseArea())
		RestArea(aArea)
	EndIf


Return lRH3BitMap
