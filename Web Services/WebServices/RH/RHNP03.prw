#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"

#INCLUDE "RHNP03.CH"

Function RHNP03()
Return .T.


WSRESTFUL Payment DESCRIPTION EncodeUTF8(STR0001) //"Retorna o resumo do Demonstrativo de Pagamento"

WSDATA WsNull 		As String Optional
WSDATA initView		As String Optional
WSDATA endView		As String Optional
WSDATA typeChange	As String Optional
WSDATA page			As String Optional
WSDATA pageSize		As String Optional
WSDATA initDate		As String Optional
WSDATA endDate		As String Optional

//"Resumo do demonstrativo"
WSMETHOD GET DESCRIPTION EncodeUTF8(STR0002) WSSYNTAX "/payment/payments/{employeeId} | /payment/detail/{paymentId} | /payment/annualReceipts/{employeeId} | /payment/annualReceipt/report/{employeeId}/{calendarYear} | /payment/paymentReceipt/report/{employeeId}/{paymentId}"

//Retorna a disponibilidade da folha de pagamento do funcionario
WSMETHOD GET GetPayAvailable ; 
  DESCRIPTION EncodeUTF8(STR0014) ;	//"Retorna a disponibilidade da folha de pagamento do funcionario" 
  WSSYNTAX "/payment/available/{employeeId}" ;
  PATH "/available/{employeeId}" ;
  PRODUCES 'application/json;charset=utf-8'

//Retorna os tipos de alteracoes salariais
WSMETHOD GET gTypeSalaryChanges ; 
  DESCRIPTION EncodeUTF8(STR0015) ;	//"Retorna os tipos de altera��es salariais" 
  WSSYNTAX "/payment/salaryHistory/type" ;
  PATH "/salaryHistory/type" ;
  PRODUCES 'application/json;charset=utf-8'

//Retorna o historico de alteracoes salariais do funcion�rio
WSMETHOD GET SalaryChanges ; 
  DESCRIPTION EncodeUTF8(STR0016) ;	//"Retorna o hist�rico de altera��es salariais do funcion�rio" 
  WSSYNTAX "/payment/salaryHistory/{employeeId}" ;
  PATH "/salaryHistory/{employeeId}" ;
  PRODUCES 'application/json;charset=utf-8'

END	WSRESTFUL


WSMETHOD GET WSRECEIVE WsNull WSSERVICE Payment

Local oItem         := JsonObject():New()
Local oItemDetail	:= JsonObject():New()
Local oMessages     := JsonObject():New()

Local cJson 	  	:= ""
Local cMatSRA	  	:= ""
Local cToken        := ""
Local cKeyUserId	:= ""
Local cSyntax       := ""
Local cYear         := ""
Local cArqName      := ""
Local cArqLocal     := ""
Local cRD0Login     := ""
Local cIdQP			:= ""
Local cBranchVld	:= ""
Local cSavFil       := cFilAnt
Local cSavEmp       := cEmpAnt
Local cQryParam		:= ""

Local nSize         := 0
Local nTipo         := 0
Local nX            := 0
Local nLenParms     := Len(::aURLParms)

Local aMessages     := {}
Local aData         := {}
Local aPaymentId	:= {}
Local aTransfSeg    := {}
Local aIdFunc       := {}
Local aDataLogin	:= {}
Local aMultV		:= {}
Local lMultV		:= .F.
Local aTables		:= { "RCH","SRA","SRC","SRD","SRV","SRQ","SRY","RCA","SQB","RCN" }
Local aMsgDefault	:= { STR0018 }
Local aQryParam		:= Self:aQueryString

Local lAuth         := .T.
Local lPayment      := .T.
Local lRecibo       := .F.
Local lVldAut       := .F.
Local lMatTransf    := .F.
Local lTransFil		:= .F.
Local lRobot		:= .F.

cToken  	:= Self:GetHeader('Authorization')
cKeyUserId 	:= Self:GetHeader('keyId')

Private cKeyId	:= ""
Private lSucess := .F.

// - Par�metros enviados pela URL - QueryString
DEFAULT Self:initView := ""
DEFAULT Self:endView  := ""

::SetHeader('Access-Control-Allow-Credentials' , "true")

aDataLogin := GetDataLogin(cToken,,cKeyUserId)

If Len(aDataLogin) > 0
	cMatSRA    := aDataLogin[1]
	cRD0Login  := aDataLogin[2]
	cBranchVld := aDataLogin[5]
EndIf

If Empty(cMatSRA) .Or. Empty(cBranchVld)
	oMessages["type"]   := "error"
	oMessages["code"]   := "401"
	oMessages["detail"] := EncodeUTF8(STR0003) //"Dados inv�lidos."
	
	Aadd(aMessages,oMessages)
	lAuth := .F.
EndIf

//Posiciona SRA
dbSelectArea("SRA")
SRA->( dbSetOrder(1) )
If !(SRA->( dbSeek( xFilial("SRA" , cBranchVld) + cMatSRA) ))
    lAuth := .F.
Else
    //avalia transfer�ncias para tratamento de seguran�a     
    fTransfAll(@aTransfSeg,,,.T.)
EndIf

If lAuth
	cKeyId 		:= Iif(Len(Self:aUrlParms) >= 2,Self:aUrlParms[2],"")
	
	If !(cKeyId == "{current}") .And. !(cKeyId == "report") .And. !("|" $ cKeyId)
		cKeyId	:= rc4crypt( cKeyId, "MeuRH#PaymentID", .F., .T. )
	EndIf
	
	If Len(Self:aUrlParms) >= 4 .And. Self:aUrlParms[1] == "payments" .And. Self:aUrlParms[2] == "report"
		cKeyId	:= rc4crypt( Self:aUrlParms[4], "MeuRH#PaymentID", .F., .T. )		
	EndIf
	
	cYear		:= Iif(Len(Self:aUrlParms) >= 4,Self:aUrlParms[4],"")
	aPaymentId	:= StrTokArr(cKeyId, "|" )
	nSize 		:= Len(aPaymentId)
		
    //valida permissionamento de seguran�a
    If Self:aUrlParms[1] == "detail"
       
		//tratamento para transfer�ncia entre empresas, com possibilidade de troca de filial/matr�cula
		If len(aPaymentId) == 11 .and. !empty(aPaymentId[11])

			For nX:=1 to Len(aTransfSeg)
				//Verifica se as informa��es de destino s�o iguais as informa��es do usu�rio logado.
				// Filial+Mat+Empresa    
				If ( aTransfSeg[nX][5]+aTransfSeg[nX][4] ==  cBranchVld+cMatSRA+cEmpAnt) .Or. (aTransfSeg[nX][2]+aTransfSeg[nX][1] ==  cBranchVld+cMatSRA+cEmpAnt)
					lVldAut    := .T.
					//Se a empresa de origem for diferente da empresa logada, ent�o houve transfer�ncia entre grupos de empresa.
					If !(aTransfSeg[nX][1] == cEmpAnt)
						lMatTransf := .T.
					EndIf
					Exit
				EndIf
			Next

		Else
			lVldAut := fVldSolAut(cBranchVld, cMatSRA, cEmpAnt, aPaymentId[1], Iif(nSize >= 2,aPaymentId[2],"" ),cEmpAnt)
			lRecibo := If( !lVldAut, !lVldAut, lRecibo)
		EndIf    	   
	EndIf

	//Valida se o usu�rio autenticado tem acesso a essas informa��es
	//Download holerite e informe de rendimentos as informa��es de usu�rio/matricula s�o capturados do token e n�o de query param
	If nSize > 0 .And. ( (Self:aUrlParms[2] == "{current}" .Or. Self:aUrlParms[2] == "report" .Or. "annualReceipt" $ Self:aUrlParms[1] ) .Or. lVldAut  )

		cSyntax	:= ::aURLParms[1]
	
		If nLenParms == 2 .And. !Empty(::aURLParms[2]) .And. ::aURLParms[1] == "payments"
			GetPayment(cMatSRA,cBranchVld,Self:initView,Self:endView,@aData,@aMessages)
			lRecibo := .T.
		
		ElseIf nLenParms == 2 .And. !Empty(::aURLParms[2]) .And. ::aURLParms[1] == "detail"
            //Reposiciona SRA para o tratamento de transf�ncias entre empresas 
            If lMatTransf
				fNewEmpFiles(aPaymentId[11], aPaymentId[1], aTables)
				//Posiciona SRA
				dbSelectArea("SRA")
				SRA->( dbSetOrder(1) )
				If SRA->( dbSeek( xFilial("SRA" , aPaymentId[1]) + aPaymentId[2]) )
					cMatSRA := SRA->RA_MAT
					cBranchVld := SRA->RA_FILIAL
				EndIf
            EndIf
		
			GetResume(cMatSRA,cBranchVld,Self:initView,Self:endView,@aData,@oItemDetail,aPaymentId)

			lPayment := .F.
			lRecibo := .T.

		ElseIf ( nLenParms == 2 .Or. nLenParms == 4 ).And. !Empty(::aURLParms[1]) .And. "annualReceipt" $ cSyntax 
			nTipo := If( cSyntax == "annualReceipt", 2, 1 )
			MatParticipant(cRD0Login, @aMultV, .T., .T.)
			lMultV := ( Len(aMultV) > 1 )
			If 	nLenParms == 4
				FOR nX := 1 To Len(aQryParam)
					cIdQP := UPPER(aQryParam[nX,1])
					IF cIdQP == "ID"
						cQryParam := aQryParam[nX,2]
					ELSEIF cIdQP == "EXECROBO"
            			lRobot := .T.
					ENDIF
				NEXT nX

				If !Empty(cQryParam)
					cQryParam := RC4Crypt( cQryParam, "MeuRH#AnnualReceiptID" , .F.,.T.)
					aIdFunc := STRTOKARR( cQryParam, "|" )
				EndIf

				If Len(aIdFunc) > 0
				    // Verifica se houve transfer�ncia.
					// Compara Empresa, Filila e Matricula logada com o ID do informe de rendimentos.
					If !( aIdFunc[1] + aIdFunc[2] + aIdFunc[3] == cEmpAnt+cBranchVld+cMatSRA ) .And. Len(aTransfSeg) > 0
						For nX := 1 To Len(aTransfSeg)
							// Se a Empresa, Filial e Matricula logada for igual � filial de destino ou
							// Os dados da origem da transfer�ncia forem iguais ao ID do informe de rendimentos 
							If ( cEmpAnt+cBranchVld+cMatSRA == aTransfSeg[nX][4]+aTransfSeg[nX][5] ) .Or. ;
							   ( aTransfSeg[nX][1]+aTransfSeg[nX][2] == aIdFunc[1]+aIdFunc[2]+aIdFunc[3] )
							   	lTransFil := .T.
								Exit 
							EndIf
						Next nX
					EndIf

					// Caso exista, no array aTransfSeg, as posi��es 4 (Empresa) e 5 (Fil+Mat), dever�o ser iguais
					// �s Empresa Fil e Mat do usuario logado.
					If !lMultV    .And. ;
					   !lTransFil .And. ;
					   !getPermission(cBranchVld, ;
					                  cMatSRA, ;
									  aIdFunc[2],;
									  aIdFunc[3],;
									  aIdFunc[1],;
									  aIdFunc[1] )
							aMsgDefault := {}
							aAdd( aMsgDefault, STR0025 ) //"ACESSO NEGADO!"
							aAdd( aMsgDefault, "" )
							aAdd( aMsgDefault, STR0026 ) //"Voc� n�o tem permiss�o para acessar esse recurso."
					Else	
						GetAnnualRec( nTipo, cMatSRA, cBranchVld, @aData, cYear, @cjson, cQryParam, aTransfSeg, aIdFunc, NIL, NIL)
					EndIf
				EndIf
			else
				GetAnnualRec( nTipo, cMatSRA, cBranchVld, @aData, cYear, @cjson, ,aTransfSeg, NIL, aMultV, lMultV)
			EndIf
			lPayment := .F.
			
		ElseIf nLenParms == 4 .And. ::aURLParms[1] == "payments" .And. ::aURLParms[2] == "report"

			FOR nX := 1 To Len(aQryParam)
				cIdQP := UPPER(aQryParam[nX,1])
				IF cIdQP == "EXECROBO"
					lRobot := .T.
				ENDIF
			NEXT nX	

			If nSize > 10 .and. !empty(aPaymentId[11])
				//avalia permiss�o de acesso para tansfer�ncia de empresas
				For nX :=1 to Len(aTransfSeg)
					//Verifica se as informa��es de destino s�o iguais as informa��es do usu�rio logado.
					// Filial+Mat+Empresa      
					If ( aTransfSeg[nX][5]+aTransfSeg[nX][4] ==  cBranchVld+cMatSRA+cEmpAnt) .Or. (aTransfSeg[nX][2]+aTransfSeg[nX][1] ==  cBranchVld+cMatSRA+cEmpAnt)
						lVldAut    := .T.
						//Se a empresa de origem for diferente da empresa logada, ent�o houve transfer�ncia entre grupos de empresa.
						If !(aTransfSeg[nX][1] == cEmpAnt)
							lMatTransf := .T.
						EndIf
						Exit
					EndIf
				Next
			Else
				lVldAut := fVldSolAut(cBranchVld, cMatSRA, cEmpAnt, aPaymentId[1], Iif(nSize >= 2,aPaymentId[2],"" ),cEmpAnt)
			EndIf              
			
			//Reposiciona tabelas para o tratamento de transf�ncias entre empresas 
            If lMatTransf
				fNewEmpFiles(aPaymentId[11], aPaymentId[1], aTables)
				//Posiciona SRA
				dbSelectArea("SRA")
				SRA->( dbSetOrder(1) )
				If SRA->( dbSeek( xFilial("SRA" , aPaymentId[1]) + aPaymentId[2]) )
					cBranchVld := SRA->RA_FILIAL
					cMatSRA := SRA->RA_MAT
				EndIf
            Else
            	cFilAnt := cBranchVld
            EndIf
			
			//Tratamento de transf�ncias entre filiais da mesma empresa 
			If !(cBranchVld+cMatSRA == aPaymentId[1]+aPaymentId[2]) .And. Len(aTransfSeg) > 0  .And. !(lMatTransf) 
				For nX :=1 to Len(aTransfSeg)
					If cBranchVld+cMatSRA == aTransfSeg[nX][5] .Or. aTransfSeg[nX][2] == aPaymentId[1]+aPaymentId[2]
						cFilAnt := aPaymentId[1]
						cMatSRA := aPaymentId[2]	
						lTransFil := .T.
						Exit
					EndIf
				Next
			EndIf		

			If !lTransFil .And. !getPermission(cBranchVld, cMatSRA, aPaymentId[1], aPaymentId[2])
				aMsgDefault := {}
				aAdd( aMsgDefault, STR0025 ) //"ACESSO NEGADO!"
				aAdd( aMsgDefault, "" )
				aAdd( aMsgDefault, STR0026 ) //"Voc� n�o tem permiss�o para acessar esse recurso."
			Else
				GetPaymRec(aPaymentId, @cjson, @aMsgDefault)
			EndIf

			lPayment := .F.
		EndIf
	EndIf
EndIf

If lMatTransf
	fNewEmpFiles(cSavEmp, cSavFil, aTables)
EndIf 

If lTransFil
	cFilAnt := cSavFil
EndIf 
If lRecibo
	oItem["data"]	:= Iif(Empty(aData),oItemDetail,aData)
	oItem["length"]	:= Iif(Empty(aData),1,Len(aData))
	
	If Len(aData) < 1 .And. lPayment
		oMessages["type"]   := "info"
		oMessages["code"]   := ""
		oMessages["detail"] := EncodeUTF8(STR0004) //"N�o h� recibos dispon�veis para visualiza��o."
		
		Aadd(aMessages, oMessages)
	Elseif !lPayment .and. Len(oItemDetail["events"]) < 1 
	    oItem["data"]       := aData
	    
	    oMessages["type"]   := "info"
	    oMessages["code"]   := ""
	    oMessages["detail"] := EncodeUTF8(STR0005) //"o servidor n�o respondeu nossa requisi��o :("
	
	    Aadd(aMessages, oMessages)
	EndIf
	
	oItem["messages"]	:= aMessages
Else
	If nTipo == 1
		oItem["hasNext"] 	:= .F.
		oItem["items"] 		:= aData
	EndIf
EndIf

If lRobot
	cjson := If( lSucess, "ARQUIVO_GERADO", "")
EndIf

If lRecibo .Or. nTipo == 1 
	cJson := oItem:ToJson()
	::SetResponse(cjson)
Else
	cArqName 	:= AllTrim(cBranchVld) + "_" + AllTrim(cMatSRA)
	cArqLocal 	:= GetSrvProfString ("STARTPATH","") + cArqName

	If Empty( cjson )
		fPDFMakeFileMessage( aMsgDefault, cArqName, @cjson ) //"Durante o processamento ocorreram erros que impediram a grava��o dos dados. Contate o administrador do sistema."
	EndIf

	::SetHeader("Content-Disposition", "attachment; filename="+ cArqName + ".PDF" )
	::SetResponse(cjson)    	    
EndIf

FreeObj(oItem)
FreeObj(oItemDetail)
FreeObj(oMessages)

Return(.T.)  

// -------------------------------------------------------------------
// RETORNA A DISPONIBILIDADE DA FOLHA DE PAGAMENTO DO FUNCION�RIO
// -------------------------------------------------------------------
WSMETHOD GET GetPayAvailable WSREST Payment

Local cJsonObj 	 	:= "JsonObject():New()"
Local oItem		 	:= &cJsonObj
Local aPerAtual		:= {}
Local aDateGMT		:= {}
Local cJson			:= ""
Local cQuery		:= ""
Local cTipoRot		:= ""
Local cToken		:= ""
Local cKeyId		:= ""
Local cBranchVld	:= ""
Local cMatSRA		:= ""
Local cRD0Cod		:= ""
Local cLogin		:= ""
Local cCodFol		:= ""
Local dDtPagto		:= ""
Local cDtPagto		:= ""
Local cPayIdHash	:= ""
Local nQtdTotal		:= 0
Local nTcfDFol		:= 0
Local dDtSave		:= dDataBase
Local lExibe		:= .T.
Local aQryParam		:= Self:aQueryString
Local aDataLogin	:= {}
Local lRobot		:= Len(aQryParam) > 0
Local cMod			:= ""
Local cCatFunc		:= ""
Local cRotPad		:= ""
Local lDemit		:= .F.
Local lHabil		:= .T.

::SetHeader('Access-Control-Allow-Credentials' , "true")
cToken 		:= Self:GetHeader('Authorization')
cKeyId 		:= Self:GetHeader('keyId')
aDataLogin	:= GetDataLogin(cToken, .T., cKeyId)

If Len(aDataLogin) > 0
	cMatSRA    := aDataLogin[1]
	cLogin     := aDataLogin[2]
	cRD0Cod    := aDataLogin[3]
	cBranchVld := aDataLogin[5]
	lDemit     := aDataLogin[6]
EndIf

//Valida Permissionamento
fPermission(cBranchVld, cLogin, cRD0Cod, "dashboardPayment", @lHabil)
If !lHabil .Or. lDemit
	SetRestFault(400, EncodeUTF8( STR0024 )) //"Permiss�o negada aos servi�os de hist�rico salarial!"
	Return (.F.)  
EndIf

//----------------------------------------------------------
//Obtem os dados do Funcionario e do periodo da folha
//----------------------------------------------------------
DbSelectArea("SRA")
If SRA->( dbSeek( cBranchVld + cMatSRA ) )

	nTcfDFol := Val( GetMvMrh("MV_TCFDFOL", NIL, "0", cBranchVld) )

	cMod 	 := If(SRA->RA_REGIME=='2', 'GFP','GPE')
	cCatFunc := SRA->RA_CATFUNC
	cRotPad  := If( cCatFunc $ "A/P", "9", "1") //Se for autonomo ou pr�-labore/Mensalista
	cTipoRot := fGetCalcRot(cRotPad, cMod, cBranchVld)

	fGetPerAtual( @aPerAtual, xFilial("RCH", cBranchVld), SRA->RA_PROCES, cTipoRot )
	
	If Len( aPerAtual ) > 0

		//Tratamento exclusivo para o Rob� de Testes - Database vira por queryparam
		If lRobot
			dDataBase := StoD( aQryParam[Len(aQryParam),2] )
		EndIf
		
		dDtPagto := aPerAtual[1,11]
		cDtPagto := dToS( dDtPagto )
		aDateGMT := LocalToUTC( cDtPagto, "12:00:00" )
	
		If dDataBase <= ( dDtPagto + 5 ) //Disponivel por 5 dias a partir do pagamento
		
			lExibe  := dDataBase >= ( dDtPagto + nTcfDFol ) //Considera o numero de dias do parametro MV_TCFDFOL
			cCodFol := If( cCatFunc == "A", fGetCodFol("0218"), fGetCodFol("0318") )

			cQuery	:= GetNextAlias()

			BEGINSQL ALIAS cQuery
				SELECT RC_PD, COUNT(*) QTD
				FROM
					%Table:SRC% SRC
				WHERE
					SRC.RC_FILIAL = %Exp:cBranchVld% AND
					SRC.RC_MAT = %Exp:cMatSRA% AND
					SRC.RC_PD = %Exp:cCodFol% AND
					SRC.RC_ROTEIR = %Exp:cTipoRot% AND
					SRC.RC_PROCES = %Exp:SRA->RA_PROCES% AND
					SRC.RC_DATA = %Exp:cDtPagto% AND
					SRC.%NotDel%
				GROUP BY SRC.RC_PD
			ENDSQL

			While (cQuery)->(!Eof())
				nQtdTotal += (cQuery)->QTD
				(cQuery)->(DbSkip())
			EndDo
			
			(cQuery)->(dbCloseArea())

			cPayIdHash 			 := cBranchVld +"|"+ cMatSRA +"|"+ aPerAtual[1,8] +"|"+ aPerAtual[1,3] +"|"+ aPerAtual[1,1] +"|"+ aPerAtual[1,2]	//Filial + Matricula + Processo + Roteiro + Periodo + Num.Pagto 																														
			cPayIdHash 			 := rc4crypt( cPayIdHash, "MeuRH#PaymentID" )

			oItem["paymentId"]   := rc4crypt( cPayIdHash, "MeuRH#PaymentID" )
			oItem["paymentDate"] := Substr(cDtPagto,1,4) + "-" + Substr(cDtPagto,5,2) + "-" + Substr(cDtPagto,7,2) + "T" + aDateGMT[2] + "Z"
			oItem["isAvailable"] := nQtdTotal > 0 .And. lExibe

		EndIf

		If lRobot
			dDataBase := dDtSave
		EndIf			

	EndIf		

EndIf

cJson := FWJsonSerialize(oItem, .F., .F., .T.)
::SetResponse(cJson)

Return(.T.)

// -------------------------------------------------------------------
//Retorna os tipos de alteracao salarial
// -------------------------------------------------------------------
WSMETHOD GET gTypeSalaryChanges WSREST Payment

Local cJsonObj		:= "JsonObject():New()"
Local oItem			:= &cJsonObj
Local oTipos		:= &cJsonObj
Local cJson			:= ""
Local cTabela		:= "41"
Local nX			:= 0
Local aGetTipos		:= {}
Local aTipos		:= {}

Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	aGetTipos := FWGetSX5( cTabela ) 

	If Len(aGetTipos) > 0
		For nX := 1 To Len(aGetTipos)
			oTipos 			:= &cJsonObj 
			oTipos["id"]	:= aGetTipos[nX,1] +"|"+ AllTrim(aGetTipos[nX,3])
			oTipos["name"]	:= EncodeUTF8( aGetTipos[nX,4] )
			aAdd(aTipos, oTipos)		
		Next nX
	EndIf
	
	oItem["items"] 	  := aTipos
	oItem["hasNext"]  := .F.

	cJson := FWJsonSerialize(oItem, .F., .F., .T.)
	Self:SetResponse(cJson)

Return(.T.)

// -------------------------------------------------------------------
//Retorna o historico de alteracoes salariais
// -------------------------------------------------------------------
WSMETHOD GET SalaryChanges WSREST Payment

Local cJsonObj		:= "JsonObject():New()"
Local oItem			:= &cJsonObj
Local oHistSal		:= &cJsonObj
Local oTpChange		:= &cJsonObj
Local oRegs			:= &cJsonObj
Local cSavFil       := cFilAnt
Local cSavEmp       := cEmpAnt
Local cFilter		:= ".T."
Local cTabela		:= "41"
Local cAliasSR7		:= ""
Local cJson			:= ""
Local cToken		:= ""
Local cKeyId		:= ""
Local cEmpFunc		:= ""
Local cBranchVld	:= ""
Local cMatSRA		:= ""
Local cPercent		:= ""
Local cYear			:= ""
Local cRD0Cod		:= ""
Local cLogin		:= ""
Local cDtIni		:= ""
Local cDtFim		:= ""
Local cDtRef		:= ""
Local cType			:= ""
Local nX			:= 0
Local nUltSal		:= 0
Local nTotReg		:= 0
Local nCount		:= 0
Local nIniCount	  	:= 0 
Local nFimCount 	:= 0
Local nPos			:= 0
Local nLenParms		:= Len(::aUrlParms)
Local aHist			:= {}
Local aDados		:= {}
Local aRegs			:= {}
Local aIdFunc		:= {}
Local aGetTipos		:= {}
Local aDataLogin	:= {}
Local lMorePage		:= .F.
Local lDemit		:= .F.
Local lHabil		:= .T.
Local lChangeEmp	:= .F.
Local cRoutine		:= "W_PWSA390.APW" //Hist�rico Salarial

DEFAULT Self:typeChange	:= ""
DEFAULT Self:page		:= "1"
DEFAULT Self:pageSize	:= "6"
DEFAULT Self:initDate	:= ""
DEFAULT Self:endDate	:= ""

Self:SetHeader('Access-Control-Allow-Credentials' , "true")
cToken 	   := Self:GetHeader('Authorization')
cKeyId 	   := Self:GetHeader('keyId')
aDataLogin := GetDataLogin(cToken, .T., cKeyId)

If Len(aDataLogin) > 0
	cMatSRA    := aDataLogin[1]
	cLogin     := aDataLogin[2]
	cRD0Cod    := aDataLogin[3]
	cBranchVld := aDataLogin[5]
	lDemit     := aDataLogin[6]
EndIf


//Gestor acessando dados do funcion�rio.
If nLenParms > 0 .And. !Empty(::aUrlParms[2]) .And. !("current" $ ::aUrlParms[2] )
	aIdFunc := STRTOKARR( ::aUrlParms[2], "|" )
	If Len(aIdFunc) > 0
		//Tratativa para caso seja passada a filial e matr�cula do proprio funcion�rio, por�m simulando como se fosse gestor.
		If cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2]
			//Valida Permissionamento
			fPermission(cBranchVld, cLogin, cRD0Cod, "salaryHistory", @lHabil)
			If !lHabil .Or. lDemit
				SetRestFault(400, EncodeUTF8( STR0022 )) //"Permiss�o negada aos servi�os de hist�rico salarial!"
				Return (.F.)  
			EndIf
		Else
			//Carrega permiss�o da gest�o do time.
			fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementSalaryHist", @lHabil)
			If !lHabil .Or. lDemit
				SetRestFault(400, EncodeUTF8( STR0022 )) //"Permiss�o negada aos servi�os de hist�rico salarial!"
				Return (.F.)  
			ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
				cBranchVld	:= aIdFunc[1]
				cMatSRA		:= aIdFunc[2]
				cEmpFunc	:= aIdFunc[3]
				lChangeEmp	:= !(cEmpFunc == cEmpAnt)
			Else
				SetRestFault(400, EncodeUTF8( STR0023 )) //"Voc� est� tentando acessar dados de um funcion�rio que n�o faz parte do seu time."
				Return (.F.) 
			EndIf
		EndIf
	EndIf
Else
	//Valida Permissionamento
	fPermission(cBranchVld, cLogin, cRD0Cod, "salaryHistory", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0022 )) //"Permiss�o negada aos servi�os de hist�rico salarial!"
		Return (.F.)  
	EndIf
EndIF

If lChangeEmp
	fNewEmpFiles(cEmpFunc, cBranchVld, {"SRA","SR7","SR3"})
EndIf

//Posiciona a tabela SRA na matricula que esta sendo gerado o historico
dbSelectArea("SRA")
SRA->( dbSetOrder(1) )
If SRA->( dbSeek( cBranchVld + cMatSRA ) )

	//Aplica os filtros caso sejam informados
	If !Empty(Self:typeChange)
		cType   := STRTOKARR( Self:typeChange, "|" )[2]
		cFilter += " .And. (cAliasSR7)->R7_TIPO == '" + cType + "'"
	EndIf	
	If !Empty(Self:initDate)
		cDtIni 	:= StrTran( SubStr(Self:initDate, 1, 10), "-", "" )
		cFilter += " .And. (cAliasSR7)->R7_DATA >= '" + cDtIni + "'"
	EndIf
	If !Empty(Self:endDate)
		cDtFim 	:= StrTran( SubStr(Self:endDate, 1, 10), "-", "" )
		cFilter += " .And. (cAliasSR7)->R7_DATA <= '" + cDtFim + "'"
	EndIf

	//Faz o controle de paginacao
	If Self:page == "1" .Or. Empty(Self:page)
		nIniCount := 1 
		nFimCount := If( Empty(Self:pageSize), 6, Val(Self:pageSize) )
	Else
		nIniCount := ( Val(Self:pageSize) * ( Val(Self:page) - 1 ) ) + 1
		nFimCount := ( nIniCount + Val(Self:pageSize) ) - 1
	EndIf

	cAliasSR7 := GetNextAlias()

	BeginSQL Alias cAliasSR7
		SELECT
			R7_FILIAL, R7_MAT, R7_DATA, R7_TIPO, R3_DATA, R3_TIPO, R3_VALOR, R3_DTCDISS
			FROM
			%Table:SR7% SR7
			JOIN %Table:SR3% SR3 ON R3_FILIAL = R7_FILIAL AND R3_MAT = R7_MAT AND R3_DATA = R7_DATA AND R3_TIPO = R7_TIPO AND R3_SEQ = R7_SEQ
		WHERE
			SR7.R7_FILIAL = %Exp:cBranchVld% AND
			SR7.R7_MAT = %Exp:cMatSRA% AND
			SR3.R3_PD = '000' AND //VERBA DE SALARIO BASE GERADA � PARTIR DAS ALTERA��ES SALARIAIS E/OU DISSIDIO.
			SR7.%NotDel% AND
			SR3.%NotDel%
		ORDER BY 1,2,3
	EndSQL
	
	While ( (cAliasSR7)->(!Eof()) )		
		
		cPercent := 0

		If nUltSal > 0

			If !Empty((cAliasSR7)->R3_DTCDISS)
				cDtRef := MesAno( StoD( (cAliasSR7)->R3_DATA ) )
				cPercent := fGetIndDiss((cAliasSR7)->R7_FILIAL, (cAliasSR7)->R7_MAT, cDtRef, (cAliasSR7)->R3_TIPO)
			EndIf
			
			If cPercent == 0
				cPercent := Round( ( ( (cAliasSR7)->R3_VALOR / nUltSal ) -1 ) * 100, 2 )
			EndIf

			cPercent := cValToChar( cPercent )
		Else
			cPercent := "0"
		EndIf

		If( &(cFilter) )
			aAdd( aHist, { ;
							(cAliasSR7)->R7_FILIAL, ;									//1 - Filial
							(cAliasSR7)->R7_MAT, ;										//2 - Matricula
							(cAliasSR7)->R7_DATA, ;										//3 - Data da alteracao salarial
							FwTimeStamp(6, SToD((cAliasSR7)->R7_DATA), "12:00:00" ), ;	//4 - Data formato UTF (para retorno do JSON)
							AllTrim((cAliasSR7)->R7_TIPO), ;							//5 - Tipo da alteracao salarial
							(cAliasSR7)->R3_VALOR, ;									//6 - Valor do salario atualizado
							cPercent ;													//7 - Percentual de aumento
							} )		
		EndIf
		nUltSal := (cAliasSR7)->R3_VALOR
		(cAliasSR7)->( dbSkip() )
	End

	(cAliasSR7)->(dbCloseArea())

EndIf

If ( nTotReg := Len(aHist) ) > 0 

	aGetTipos := FWGetSX5( cTabela )

	ASORT( aHist, , , { | x,y | x[1]+x[2]+x[3] > y[1]+y[2]+y[3] } )
	For nX := 1 To nTotReg
		
		nPos	:= aScan( aGetTipos, {|x| AllTrim(x[3]) == aHist[nX,5]} )
		cYear	:= SubStr( aHist[nX,3], 1, 4 )
		lAdd	:= nX == nTotReg .Or. ( nX+1 <= nTotReg .And. !cYear == SubStr( aHist[nX+1,3], 1, 4 ) )
		nCount	+= If( nX == 1 .Or. lAdd, 1, 0)
		
		If ( nCount >= nIniCount .And. nCount <= nFimCount )
			
			//Guarda os registro de aumento de cada ano
			oTpChange			:= &cJsonObj
			oTpChange["id"]		:= cValToChar(aHist[nX,5])
			oTpChange["name"]	:= If( nPos > 0, EncodeUTF8(aGetTipos[nPos,4]), STR0017 ) //"Indefinido"
			
			oRegs				:= &cJsonObj 
			oRegs["id"]			:= aHist[nX,1] +"|"+ aHist[nX,2] +"|"+ aHist[nX,3] +"|"+ aHist[nX,5] //Filial + Matricula + Data + Tipo
			oRegs["data"]		:= aHist[nX,4]
			oRegs["reason"]		:= oTpChange 
			oRegs["percent"]	:= aHist[nX,7]
			oRegs["salary"]		:= aHist[nX,6]
			aAdd( aRegs, oRegs )
			
			//Envia o total de registros guardados quando ocorre a mudanca de ano ou quando processa o ultimo registro
			If lAdd 
				oHistSal := &cJsonObj
				oHistSal["year"]					:= Val(cYear)
				oHistSal["salaryHistoryChanges"]	:= aRegs
				aAdd( aDados, oHistSal )

				aRegs := {}
			EndIf
		Else
			If nCount > nFimCount
				lMorePage := .T.
				Exit
			EndIf				
		EndIf
		
	Next nX	
EndIf

//Tratativa para retornar o sal�rio inicial como hist�rico caso n�o existe nenhum registro no hist�rico.
If Empty(aDados)

	//Guarda o tipo como Salario Inicial
	oTpChange			:= &cJsonObj
	oTpChange["id"]		:= "001"
	oTpChange["name"]	:= EncodeUTF8(STR0019)
	
	oRegs				:= &cJsonObj 
	oRegs["id"]			:= SRA->RA_FILIAL +"|"+ SRA->RA_MAT +"|"+ DTOS(SRA->RA_ADMISSA) +"|"+ "001" //Filial + Matricula + Data + Tipo
	oRegs["data"]		:= FwTimeStamp(6, SRA->RA_ADMISSA, "12:00:00" )
	oRegs["reason"]		:= oTpChange 
	oRegs["percent"]	:= "0"
	oRegs["salary"]		:= SRA->RA_SALARIO
	aAdd( aRegs, oRegs )

	oHistSal := &cJsonObj
	oHistSal["year"]					:= YEAR(SRA->RA_ADMISSA)
	oHistSal["salaryHistoryChanges"]	:= aRegs
	aAdd( aDados, oHistSal )
EndIf

If lChangeEmp
	fNewEmpFiles(cSavEmp, cSavFil)
EndIf

oItem["items"] 	  := aDados
oItem["hasNext"]  := lMorePage
cJson := FWJsonSerialize(oItem, .F., .F., .T.)
Self:SetResponse(cJson)

Return(.T.)

/*/{Protheus.doc} GetAnnualRec
- Fun��o respons�vel carregar a lista de informes de rendimentos e disponibilizar o informe para download
@author:	Marcelo Silveira
@since:		29/01/2019
/*/
Function GetAnnualRec( nTipo, cMatSRA, cBranchVld, aEvents, cAnoBas, cFile, cQryParam, aTransf, aIdFunc, aMultV, lMultV )

	Local oItem		 := Nil
	Local aArea      := GetArea()
	Local aLog		 := {}
	Local aEmps	     := {}
	Local cTipoInsc	 := ""	
	Local cInscricao := ""
	Local cNumInscr	 := ""
	Local cAnoBase	 := ""
	Local cARAlias	 := ""
	Local cFiltro	 := ""
	Local cArqLocal	 := ""
	Local cExtFile	 := ""
	Local cEmpresa	 := cEmpAnt
	Local cIdHash	 := ""
	Local cUnion	 := ""
	Local nLenInscr	 := 0
	Local nY		 := 0
	Local nTamTransf := 0
	Local nPosDel	 := 0
	Local lAtual	 := .T. //Vari�vel de controle para saber se o cliente possui os fontes do server atualizado, mas o client est� desatualizado
	Local cRelRpo	 := GetRpoRelease()
	Local lRelease	 := ( cRelRpo == "12.1.023" .Or. cRelRpo == "12.1.017" ) // Tratativa para releases 23 ou anterior, pois nesse caso o frontend � diferente e n�o tem o qryparam ID

	DEFAULT cAnoBas	 	:= ""
	DEFAULT cFile	 	:= ""
	DEFAULT cQryParam 	:= ""
	DEFAULT aTransf		:= {}
	DEFAULT aIdFunc		:= {}
	DEFAULT aEvents  	:= {}
	DEFAULT aMultV		:= {}
	DEFAULT lMultV	    := .F.

	dbSelectArea("SRA")
	dbSetOrder(1)

	If !dbSeek( cBranchVld + cMatSRA )
		Return .F.
	Endif

	If nTipo == 1 //Relacao de informes

		nTamTransf	:= Len(aTransf)
		If nTamTransf > 0
 	
			For nY:=1 To nTamTransf // Monto um array de empresas para gerar as querys de acordo com cada empresa
				If aTransf[nY][1] <> aTransf[nY][4] .And. aScan(aEmps,aTransf[nY][1]) == 0 // S� incluo empresas diferentes e que n�o est�o no aEmps, para n�o gerar duplicidades
					aAdd(aEmps,aTransf[nY][1])
				EndIf
			Next
			
			If Len(aEmps) > 1 
				nPosDel := aScan(aEmps,cEmpAnt)
				If nPosDel > 0 // Verifico se preciso deletar o grupo de empresa atual, pois na query padr�o o sistema ir� utilizar as tabelas do grupo atual
					aDel(aEmps,nPosDel)
					aSize(aEmps,Len(aEmps)-1)
				EndIf
			EndIf

  		EndIf

		cFiltro	+= "RHX.RHX_FILIAL = '" + xFilial("RHX", cBranchVld) + "'"		
		cFiltro += " AND SR4.R4_CPFCGC = '"+ SRA->RA_CIC + "'"		
		cFiltro := "% " + cFiltro + " %"

		cARAlias:= GetNextAlias() 

		If Len(aEmps) > 0 // Cria��o da query para outros grupos de empresas
			For nY := 1 To Len(aEmps)
				cUnion += "UNION "
				cUnion += "SELECT DISTINCT SR4.R4_ANO "
				cUnion += ", SRL.RL_CGCFONT" 
				cUnion += ", SR4.R4_CPFCGC"
				cUnion += ", SR4.R4_FILIAL"
				cUnion += ", SR4.R4_MAT" 
				cUnion += ", RHX.RHX_ANOBAS"
				cUnion += ", RHX.RHX_DMLIBE"
				cUnion += ", RHX.RHX_DMINFO"
				cUnion += ", RHX.RHX_RESPON"
				cUnion += ", '" + aEmps[nY] + "' AS RHX_EMP "
				cUnion += "FROM " + RetFullName("SR4",aEmps[nY]) + " SR4 "
				cUnion += "INNER JOIN " + RetFullName("RHX",aEmps[nY]) + " RHX "
				cUnion += "ON SR4.R4_ANO = RHX.RHX_ANOBAS "
				cUnion += "INNER JOIN " + RetFullName("SRL",aEmps[nY]) + " SRL "
				cUnion += "ON SR4.R4_FILIAL = SRL.RL_FILIAL "
				cUnion += "AND SR4.R4_MAT = SRL.RL_MAT "
				cUnion += "WHERE " + StrTran(cFiltro, "%", "")
				cUnion += "AND SR4.R4_CPFCGC = '"+ SRA->RA_CIC + "'"
				cUnion += "AND RHX.D_E_L_E_T_= ' ' "
				cUnion += "AND SR4.D_E_L_E_T_= ' ' "
				cUnion += "AND SRL.D_E_L_E_T_= ' '"
			Next
			cUnion := "% " + cUnion + " %"
		Else
			cUnion := "%%"
		EndIf
		
		BeginSql alias cARAlias
			SELECT DISTINCT SR4.R4_ANO
				 , SRL.RL_CGCFONT
				 , SR4.R4_CPFCGC
				 , SR4.R4_FILIAL
				 , SR4.R4_MAT
				 , RHX.RHX_ANOBAS
			     , RHX.RHX_DMLIBE
			     , RHX.RHX_DMINFO
			     , RHX.RHX_RESPON
				 , %exp:cEmpAnt% AS RHX_EMP
			FROM %table:SR4% SR4
	        	INNER JOIN %table:RHX% RHX
	            	ON SR4.R4_ANO = RHX.RHX_ANOBAS
				INNER JOIN %table:SRL% SRL
					ON SR4.R4_FILIAL = SRL.RL_FILIAL
					AND SR4.R4_MAT = SRL.RL_MAT
	         WHERE %exp:cFiltro% 
	           AND RHX.%notDel% 
	           AND SR4.%notDel%
			   AND SRL.%notDel%
			   %exp:cUnion%
	      ORDER BY RHX_ANOBAS DESC
		EndSql

		While (cARAlias)->( !Eof())
			
			If Date() >= SToD( Soma1((cARAlias)->RHX_ANOBAS) + Substr( (cARAlias)->RHX_DMLIBE, 3, 4) + Substr( (cARAlias)->RHX_DMLIBE, 1, 2) ) 
				If cNumInscr == AllTrim( (cARAlias)->RL_CGCFONT ) .And. ;
                    cAnoBase == AllTrim( (cARAlias)->RHX_ANOBAS )
                    (cARAlias)->( dbSkip() )
                    Loop
                EndIf
                
				If lMultV
                    If !( (cARAlias)->R4_FILIAL == cBranchVld .And. (cARAlias)->R4_MAT == cMatSRA )
                        (cARAlias)->( dbSkip() )
                        Loop
                    Else
                        If fSkipMultV(cBranchVld, cMatSRA, aMultV, Val((cARAlias)->RHX_ANOBAS))
                            (cARAlias)->( dbSkip() )
                            Loop
                        EndIf
                    EndIf
                EndIf
				
				cNumInscr  := AllTrim( (cARAlias)->RL_CGCFONT )
				cIdHash    := EncodeUTF8( ALLTRIM( (cARAlias)->RHX_EMP ) ) + "|" + EncodeUTF8( (cARAlias)->R4_FILIAL + "|" + (cARAlias)->R4_MAT )
				cIdHash    := rc4crypt( cIdHash, "MeuRH#AnnualReceiptID" )
				cAnoBase   := AllTrim( (cARAlias)->RHX_ANOBAS )
				nLenInscr  := Len(cNumInscr)

				Do Case
					Case nLenInscr == 14
						cTipoInsc := "CNPJ: "
						cInscricao := Transform(cNumInscr, "@R 99.999.999/9999-99")
					Case nLenInscr == 11
						cTipoInsc := "CPF: "
						cInscricao := Transform(cNumInscr, "@R 999.999.999-99")
					Case nLenInscr == 12
						cTipoInsc  := "CEI: "
						cInscricao := Transform(cNumInscr, "@R 99.999.99999/99")
					OTHERWISE
						cTipoInsc  := "INCRA: "
						cInscricao := cNumInscr
				End Case
				
				oItem						:= JsonObject():New()
				oItem["id"]          		:= cIdHash
				oItem["calendarYear"] 		:= EncodeUTF8( (cARAlias)->RHX_ANOBAS )	//2018
				oItem["pdfDownloadVisible"] := .T.
				oItem["htmlViewVisible"]    := .F.
				oItem["label"]				:= cTipoInsc + cInscricao

				Aadd(aEvents,oItem)

				FreeObj(oItem)
			EndIf
			
			(cARAlias)->( dbSkip() )
		EndDo
		(cARAlias)->( dbCloseArea() )
		RestArea(aArea)
	
	Else //Arquivo para download
		
	    If !Empty( cAnoBas )
			If Len(aIdFunc) > 0
				cEmpresa   := aIdFunc[1]
				cBranchVld := aIdFunc[2]
				cMatSRA	   := aIdFunc[3]
			Else
				lAtual := .F.
			EndIf
			
			cExtFile	:= DTOS( DATE() ) + SubStr( TIME(), 1, 2) //Ano + Mes + Dia + Hora 
			cFileName 	:= AllTrim(cBranchVld) + "_" + AllTrim(cMatSRA) + "_IRPF_"
			cArqLocal 	:= GetSrvProfString ("STARTPATH","")
				
			//------------------------------------------------------------------------------
			//Existe um problema ainda nao solucionado que o APP envia mais de uma requisicao via mobile
			//Quando isso ocorre o sistema nao gera o arquivo e envia uma resposta sem conteudo. 
			//Solucao paliativa:
			//Caso alguma requisicao falhe tentaremos gerar o arquivo novamente por 3 vezes no maximo
			//Cada nova requisicao ira gerar o arquivo com um nome diferente (Filial + Matricula + IRPF + nX) 
			//------------------------------------------------------------------------------
			If lAtual .Or. lRelease

				If cEmpresa <> cEmpAnt // Abertura das novas tabelas de outros grupos de empresa
					cFile := GetDataForJob( "8", { cBranchVld, cMatSRA, cAnoBas, cArqLocal, cFileName, cExtFile}, cEmpresa )
				Else
					cFile := fGetFileAnnualRec(cBranchVld, cMatSRA, cAnoBas, cArqLocal, cFileName, cExtFile)
				EndIf

				lSucess := !Empty(cFile)

			EndIf
		    
	    EndIf
	    
	EndIf

	If !lAtual .And. !lRelease
		aAdd( aLog, STR0018 ) //"Durante o processamento ocorreram erros que impediram a grava��o dos dados. Contate o administrador do sistema."
		aAdd( aLog, "" )
		aAdd( aLog, STR0020 ) //"Poss�veis causas do problema:"
		aAdd( aLog, "- " + STR0021 ) //"Verifique se os seus arquivos do Portal MeuRH est�o atualizados."
		fPDFMakeFileMessage( aLog, cFileName, @cFile ) 
	EndIf	
	  		
Return(.T.)

/*/{Protheus.doc}GetPayment
- Fun��o respons�vel por manipular e criar o JSON do RESUMO do demonstrativo de pagamento.
@author:	Matheus Bizutti
@since:		07/06/2017
/*/
Function GetPayment(cRegistration,cFilFun,initView,endView,aData,aMessages)

Local oPayments  := Nil
Local cSRCBranch := ""
Local cSRDBranch := ""
Local nTrans 	 := 1
Local nIAux		 := 0
Local nTamArray	 := 0
Local lTransfEmp := .F.
Local aVerbas	 := {}
Local aTransf	 := {}
Local aTransAux	 := {}

Private cQuery       := ""
						
DEFAULT initView 	 := ""
DEFAULT endView  	 := ""	
DEFAULT cRegistration:= ""	
DEFAULT aData		 := {}
DEFAULT aMessages	 := {}		
DEFAULT cFilFun		 := FwCodFil()	

aAdd(aVerbas, fGetCalcRot('2',,cFilFun)) // ADI
aAdd(aVerbas, fGetCalcRot('1',,cFilFun)) // FOL
aAdd(aVerbas, fGetCalcRot('5',,cFilFun)) // 131
aAdd(aVerbas, fGetCalcRot('6',,cFilFun)) // 132
aAdd(aVerbas, fGetCalcRot('F',,cFilFun)) // PLR
aAdd(aVerbas, fGetCalcRot('9',,cFilFun)) // AUT
aAdd(aVerbas, fGetCalcRot('K',,cFilFun)) // VEX
aAdd(aVerbas, fGetCalcRot('7',,cFilFun)) // OUT

cSRCBranch := cSRDBranch := cFilFun
oPayments  := JsonObject():New()

dbSelectArea("SRA")
SRA->( dbSetOrder(1) )

If SRA->( DBSeek(xFilial("SRA", cFilFun) + cRegistration) )
    fTransfAll(@aTransf,,,.T.)
    nTamArray	:= Len(aTransf)

    // - Verifica se houve transfer�ncia apenas entre empresas e com troca de matr�culas.
    aEval( aTransf , { |x| If( x[1] != x[4] , ( lTransfEmp := .T. ) , NIL ) } )	
EndIf


If lTransfEmp
	//Despreza transferencias de centro de custo
	While nTrans > 0
		If ( nTrans := aScan( aTransf, { |x| x[1] + x[2] == x[4] + x[5] .And. x[3] <> x[6] } ) ) > 0
			aDel( aTransf, nTrans )
			aSize( aTransf, Len(aTransf) - 1 )
		EndIf
	EndDo

	//Ordena as transferencias por data a partir da mais recente
	ASORT(aTransf, , , { | x,y | x[7] > y[7] } )

	For nIAux := 1 To Len(aTransf)
		aAdd( 	aTransAux, { ;
				aTransf[nIAux][01],; //1 - Empresa Origem
				aTransf[nIAux][04],; //2 - Empresa Destino
				aTransf[nIAux][08],; //3 - Filial Origem
				aTransf[nIAux][10],; //4 - Filial Destino
				aTransf[nIAux][09],; //5 - Matricula Origem
				aTransf[nIAux][11],; //6 - Matricula Destino
				aTransf[nIAux][12] ; //7 - Ano/Mes da Transferencia 
		}) 
	Next nIAux	

	TransfEmp(aTransAux,aVerbas,oPayments,aData,initView,endView)

Else
	cQuery := GetNextAlias()

	// - Obt�m a Query
	DetailReceipts(@cQuery,nTamArray,aTransf,cSRCBranch,cRegistration,cSRDBranch,cFilFun,.T.,initView,endView,.T.,.T.)
		
	// - Setar o JSON.
	SetReceipts(cQuery,oPayments,aData,aVerbas,,cFilFun)

	(cQuery)->(dbCloseArea())
EndIf


Return(Nil)

/*/{Protheus.doc} TransfEmp
- Fun��o respons�vel por criar o corpo do JSON do resumo do demonstrativo de pagamento para funcion�rios com transfer�ncia entre empresas.
@author:	Matheus Bizutti, Marcelo Silveira (nova versao)
@since:		07/06/2017
/*/
Function TransfEmp(aTransAux, aVerbas, oPayments, aData, initView, endView)

Local nCount        := 0
Local nProc        	:= 0
Local nTotReg		:= 0
Local nPosF			:= 0
Local nPosE			:= 0
Local nMeses		:= 5
Local cRegAtu   	:= ""
Local cPerIni		:= ""
Local cPerFim		:= ""
Local cPeriodo  	:= "" 
Local cSemana   	:= "" 
Local cAnoMes   	:= ""
Local lOrigem		:= .F.
Local lViewMore		:= .F.
Local lCalc			:= .F.
Local aPerTransf	:= {}

DEFAULT aTransAux	:= {}
DEFAULT aVerbas 	:= {}
DEFAULT oPayments	:= JsonObject():New()
DEFAULT aData		:= {}
DEFAULT initView	:= ""
DEFAULT endView		:= ""

nTotReg   := Len(aTransAux)
lViewMore := !Empty(initView) .And. !Empty(endView)

// - Percorrer as transf�rencias do funcion�rio.
For nCount := 1 To nTotReg

	lOrigem := .F.
	nPosF   := 4 //Filial destino
	nPosE   := 2 //Empresa destino
	cRegAtu := aTransAux[nCount,nPosE] + aTransAux[nCount,nPosF] //Empresa + Filial Destino

	//Obtem a faixa de datas para pesquisa nos acumulados
	If lViewMore
		cPerFim := SUBSTR( DtoS(DaySub(StoD(SUBSTR(endView,1,4)+SUBSTR(endView,6,2)+SUBSTR(endView,9,2)), 1) ), 1, 6 )
		cPerIni := SUBSTR( Format8601(.T.,initView,,.T.), 1, 6 )
	Else
		//Busca per�odo em aberto
		If Empty(cAnoMes)
			getOpenPer(SRA->RA_MAT,SRA->RA_FILIAL,@cPeriodo,@cSemana,@cAnoMes)
		EndIf
		lCalc := fChkCalcFol( SRA->RA_FILIAL, SRA->RA_MAT, cPeriodo )
		cPerFim := cAnoMes
		nMeses += Iif( lCalc, 0, 1 )
		cPerIni := SubStr(DtoS(MonthSub(STOD(cAnoMes + "01"), nMeses)), 1, 6)
	EndIf

	/*
	O usuario sempre tera acesso aos dados das empresas anteriores. Exemplo: funcionario trabalhou nas empresas: T1, T2, e T3 (atual)
	Ao acessar T3 -> Exibe os recibos: empresas T3, T2 e T1
	Ao acessar T2 -> Exibe os recibos: empresas T2 e T1
	Ao acessar T1 -> Exibe os recibos: empresa T1

	Quando a empresa destino da transferencia mais recente � diferente da cEmpAnt indica que o usuario est� acessando por alguma empresa anterior
	Nesse caso, valida todos os registros a partir do mais recente at� encontrar o grupo que corresponde aquele que o usuario est� acessando
	*/
	If (nProc == 0 .And. !(cRegAtu == cEmpAnt + SRA->RA_FILIAL)) //Empresa Destino
		If aTransAux[nCount,1] + aTransAux[nCount,3] == cEmpAnt + SRA->RA_FILIAL //Empresa origem
			nPosF   := 3 //Filial origem
			nPosE   := 1 //Empresa origem
			lOrigem := .T.
			If !lViewMore
				cPerFim := aTransAux[nCount,7]
				cPerIni := SubStr(DtoS(MonthSub(STOD(cPerFim + "01"), 5)), 1, 6)
			EndIf
		Else
			Loop
		EndIf
	EndIf

	nProc ++
	cQuery := GetNextAlias()
	If GetTrfDetails(@aTransAux, nCount, @cQuery, cPerIni, cPerFim, lOrigem)
		//Monta o Json
		SetReceipts(@cQuery, oPayments, @aData, aVerbas, aTransAux[nCount,nPosE], aTransAux[nCount,nPosF], aPerTransf)
	EndIf
	(cQuery)->( DBCloseArea() )

	//As pesquisas s�o consideram os dados da empresa destino e quando chega no ultimo registro realiza uma nova 
	//pesquisa a partir dos dados da empresa origem, exceto se a ultima consulta j� tiver sido com dados da origem
	If nCount == nTotReg .And. !lOrigem
		cQuery := GetNextAlias()
		If GetTrfDetails(@aTransAux, nCount, @cQuery, cPerIni, cPerFim, .T.)
			SetReceipts(@cQuery, oPayments, @aData, aVerbas, aTransAux[nCount,1], aTransAux[nCount,3], aPerTransf)
		EndIf
		(cQuery)->( DBCloseArea() )
	EndIf

Next nCount

//ordena os per�odos por (Data de Referencia + Data de Pagamento + Roteiro)
ASORT(aPerTransf, , , { | x,y | x[14]+x[9]+x[5] > y[14]+y[9]+y[5] } )

//Checa se existe duplicidade de verbas devido ao filtro pegar uma interseccao de transferencias
fChkRegsDup(@aPerTransf)

MountPayments(aPerTransf,oPayments,aData,aVerbas) 

Return(Nil)

/*/{Protheus.doc}SetReceipts
- Fun��o respons�vel por criar o corpo do JSON do resumo do demonstrativo de pagamento (data de pagamento, tipo e valor l�quido)
@author:	Matheus Bizutti
@since:	07/06/2017
/*/
Function SetReceipts(cQuery,oPayments,aData,aVerbas,cEmp,cBranchVld,aPerTransf)

Local nType       := 0
Local cKey        := ""
Local nPos        := 0
Local nX, nTam    := 0
Local aPeriodo    := {}
Local lExistPE    := ExistBlock("LIBRECPAG")
Local lMostraRec  := .F.
Local cOpReg      := GetMvMrh('MV_TCF013A',,'01.02.03.04.05.06.07.08',cBranchVld) //01-ADI, 02-FOL, 03-131, 04-132, 05-PLR, 06-AUT, 07-VEX, 08-Outros Roteiros
Local aLibDemo    := { Val(GetMvMrh("MV_TCFDADT", NIL, "0",cBranchVld)),;
                       Val(GetMvMrh("MV_TCFDFOL", NIL, "0",cBranchVld)),;
                       Val(GetMvMrh("MV_TCFD131", NIL, "0",cBranchVld)),;
                       Val(GetMvMrh("MV_TCFD132", NIL, "0",cBranchVld)),;
                       Val(GetMvMrh("MV_TCFDEXT", NIL, "0",cBranchVld)),;
					   Val(GetMvMrh("MV_TCFDFOL", NIL, "0",cBranchVld)),; // Parametro para ser considerado o pagamento do Autonomo. Mesma tratativa do Portal.
					   Val(GetMvMrh("MV_TCFDEXT", NIL, "0",cBranchVld)),;
					   Val(GetMvMrh("MV_TCFDOUT", NIL, "0",cBranchVld))}  // Outros roteiros - RY_TIPO == 7

DEFAULT oPayments := JsonObject():New()
DEFAULT aData	  := {}
DEFAULT cQuery	  := GetNextAlias()
DEFAULT aVerbas	  := {}
DEFAULT cEmp	  := ""
DEFAULT aPerTransf:= {}

If !Empty(cQuery)
	
	While !(cQuery)->(Eof()) 

		cKey := (cQuery)->FILIAL + (cQuery)->MATRICULA + (cQuery)->PROCESSO + (cQuery)->RC_ROTEIR + (cQuery)->RC_PERIODO + (cQuery)->RC_SEMANA +'-' +cEmp
		
		nType := aScan(aVerbas, {|aItemVerba| aItemVerba == (cQuery)->RC_ROTEIR } )
		nPos := Ascan(aPeriodo,{|x| x[1] == cKey})
		cTipVerba := (cQuery)->RV_TIPOCOD

		//valida��o de carregamento de recibo na lista
		lMostraRec  := .F.

		If lExistPE
			lRetBlock := ExecBlock("LIBRECPAG",.F.,.F.,{(cQuery)->DATAPAGTO,(cQuery)->FILIAL,(cQuery)->MATRICULA, nType, Val(SubStr((cQuery)->RC_PERIODO,1,4)), Val(SubStr((cQuery)->RC_PERIODO,5,2)) })
			lMostraRec := If( ValType(lRetBlock) == "L" , lRetBlock , .T. )         
		Else
			If ( nType == 2 .Or. nType == 6 .Or. nType == 8 ) // Folha ou ( Pro-labore e Autonomos) ou Outros Roteiros
				//������������������������������������������������������������������������������������������������������������Ŀ
				//�Trata o parametro "MV_TCFDFOL" como excecao, pois este parametro indica a quantidade de dias para liberacao �
				//�do demonstrativo. Os demais parametros, indicam a data inicial de liberacao.                                �
				//��������������������������������������������������������������������������������������������������������������			
				If ( aLibDemo[nType] < 0 )
					lMostraRec  :=  dDataBase - STOD((cQuery)->DATAPAGTO) >= aLibDemo[nType]
				Else
					lMostraRec  :=  dDataBase >= STOD((cQuery)->DATAPAGTO) + aLibDemo[nType]
				EndIf
			Else
				If nType > 0
					//Monta a data de libera��o do recibo de pagamento.
					dDataLib    :=  StoD(SubStr((cQuery)->DATAPAGTO,1,4) + SubStr((cQuery)->DATAPAGTO,5,2) + STRZERO(aLibDemo[nType],2))
					lMostraRec  := ( dDataBase  >= dDataLib )
				EndIf
			EndIf

			//valida se o tipo de holerite deve ser mostrado, para que aconte�a os itens dever�o ser lanctos no Param
			//01-Adiantamento, 02-Folha, 03-1� parcela do 13�, 04-2� parcela do 13�, 05-PLR, 06-Autonomos, 07-Valores Extras 
			If lMostraRec .and. !Empty(cOpReg) .and. !( cValToChar(nType) $ cOpReg )
				lMostraRec := .F.
			EndIF
		EndIf
             
		If ( lMostraRec )
			If nPos == 0
				If cTipVerba == "1"
					aadd(aPeriodo,{ cKey, (cQuery)->FILIAL , (cQuery)->MATRICULA , (cQuery)->PROCESSO , (cQuery)->RC_ROTEIR , (cQuery)->RC_PERIODO , (cQuery)->RC_SEMANA, (cQuery)->ARCHIVED, (cQuery)->DATAPAGTO, nType, (cQuery)->RC_VALOR, .T., cEmp})
				Elseif cTipVerba == "2"
					aadd(aPeriodo,{ cKey, (cQuery)->FILIAL , (cQuery)->MATRICULA , (cQuery)->PROCESSO , (cQuery)->RC_ROTEIR , (cQuery)->RC_PERIODO , (cQuery)->RC_SEMANA, (cQuery)->ARCHIVED, (cQuery)->DATAPAGTO, nType, (cQuery)->RC_VALOR * -1, .T., cEmp})
				EndIf
			Else
				If cTipVerba == "1"
					aPeriodo[nPos][11] := aPeriodo[nPos][11] + (cQuery)->RC_VALOR
				Elseif cTipVerba == "2"
					aPeriodo[nPos][11] := aPeriodo[nPos][11] + ((cQuery)->RC_VALOR * -1)
				EndIf
			EndIf
		EndIf
		
		//Se alguma verba n�o puder ser exibida no recibo, todo o envelope nao ser� apresentado para n�o mostrar valores incorretos
		If !lMostraRec .And. nPos > 0
			aPeriodo[nPos, 12] := .F.
		EndIf
			
		(cQuery)->(dbSkip()) 

	EndDo
	

	//Registra data de referencia nas ocorr�ncias antes do ordenamento
	aPeriodo := SaveDtReference(aPeriodo)

	If Len(aPeriodo) > 0 .and. empty(cEmp)
		//ordena os per�odos por (Data de Referencia + Data de Pagamento + Roteiro)
		ASORT(aPeriodo, , , { | x,y | x[14]+x[9]+x[5] > y[14]+y[9]+y[5] } )

		MountPayments(aPeriodo,oPayments,aData,aVerbas) 

	ElseIf Len(aPeriodo) > 0

		//acumula array para tratar transfer�ncias
		If len(aPerTransf) > 0
			nTam := len(aPerTransf) + 1
			For nX := 1 To Len(aPeriodo)
				aAdd(aPerTransf)
			Next nX

			aCopy(aPeriodo, aPerTransf, , , nTam) 
		Else
			aPerTransf := aPeriodo      
		EndIf 

	EndIf
EndIf

Return(Nil)


/*/{Protheus.doc}SaveDtReference
- Prepara data de refer�ncia para ordena��o
/*/
Function SaveDtReference(aPeriodo)
Local nI            := 1
Local aDatePg       := {}
Local aPerReference := {}
Local cEmpREF     	:= ""
Local cEmpRCH       := ""
Local cFilRCH       := ""
Local cKeyPg        := ""
Local cDtRef        := ""
Local cDtPagto      := ""
Local cQryRCH       := GetNextAlias()

For nI := 1 To Len(aPeriodo)

	If aPeriodo[nI, 12]

		//Apresenta a data de pagamento conforme a data de pagamento do periodo (RCH)
		cKeyPg := aPeriodo[nI,2] + aPeriodo[nI,4] + aPeriodo[nI,6] + aPeriodo[nI,7] + aPeriodo[nI,5]
		
		If ( nPos := aScan( aDatePg, {|x| x[1] == cKeyPg }) ) > 0
			cDtPagto := aDatePg[nPos,2]
		Else
			If cEmpAnt == aPeriodo[nI,13]
				If fPosPeriodo( xFilial("RCH", aPeriodo[nI,2]), aPeriodo[nI,4], aPeriodo[nI,6], aPeriodo[nI,7], aPeriodo[nI,5] )
					aAdd( aDatePg, { aPeriodo[nI,2] + RCH->RCH_PROCES + RCH->RCH_NUMPAG + RCH->RCH_ROTEIR, DTOS(RCH->RCH_DTPAGO) } )
					cDtPagto := DTOS( RCH->RCH_DTPAGO )
					cDtRef   := DTOS( RCH->RCH_DTFIM )
				Else
					cDtPagto := LocalToUTC( aPeriodo[nI][9], "12:00:00" )[1]
					cDtRef   := LocalToUTC( aPeriodo[nI][9], "12:00:00" )[1]
				EndIf
			Else
				//Busca RCH da empresa de origem para carregar as informa��es do holerite
				cEmpREF := If( Empty(aPeriodo[nI,13]), cEmpAnt, aPeriodo[nI,13] )
				cEmpRCH := "%"+RetFullName("RCH", cEmpREF )+"%"
				cFilRCH := xEmpFilial("RCH", aPeriodo[nI,2], cEmpREF)

				BeginSql alias cQryRCH
					SELECT *
					FROM  %exp:cEmpRCH%  RCH
					WHERE RCH_FILIAL       = %exp:cFilRCH%                                   AND
						RCH.RCH_PER      = %exp:aPeriodo[nI,6]%                            AND
						RCH.RCH_NUMPAG  >= %exp:aPeriodo[nI,7]%                            AND
						(RCH.RCH_ROTEIR  = '   ' OR RCH.RCH_ROTEIR = %exp:aPeriodo[nI,5]%) AND
						RCH.RCH_PROCES   = %exp:aPeriodo[nI,4]%                            AND
						RCH.%notDel%
				EndSql
			
				If (cQryRCH)->( !Eof() )
					aAdd( aDatePg, { aPeriodo[nI,2] + (cQryRCH)->RCH_PROCES + (cQryRCH)->RCH_NUMPAG + (cQryRCH)->RCH_ROTEIR, (cQryRCH)->RCH_DTPAGO } )
					cDtPagto := (cQryRCH)->RCH_DTPAGO
					cDtRef   := (cQryRCH)->RCH_DTFIM
				Else
					cDtPagto := LocalToUTC( aPeriodo[nI][9], "12:00:00" )[1]
					cDtRef   := LocalToUTC( aPeriodo[nI][9], "12:00:00" )[1]
				EndIf

				(cQryRCH)->( dbCloseArea() )
			EndIf
				
		EndIf       

		aadd(aPerReference     , ; 
				{ aPeriodo[nI,1]  , ; 
				aPeriodo[nI,2]  , ;
				aPeriodo[nI,3]  , ;
				aPeriodo[nI,4]  , ;
				aPeriodo[nI,5]  , ;
				aPeriodo[nI,6]  , ;
				aPeriodo[nI,7]  , ;
				aPeriodo[nI,8]  , ;
				cDtPagto        , ;
				aPeriodo[nI,10] , ;
				aPeriodo[nI,11] , ;
				aPeriodo[nI,12] , ;
				aPeriodo[nI,13] , ;
				cDtRef           })

	EndIf  

Next nI

Return(aPerReference)


/*/{Protheus.doc}montaPayments
- Fun��o respons�vel por montar o objeto de payuments
/*/
Function MountPayments(aPeriodo,oPayments,aData,aVerbas)
Local nI          := 1
Local cEmpREF     := ""
Local cEmpSRY     := ""
Local cFilSRY     := ""
Local cPayIdHash  := ""
Local cQrySRY     := GetNextAlias()

DEFAULT aPeriodo  := {}
DEFAULT oPayments := JsonObject():New()
DEFAULT aData     := {}
DEFAULT aVerbas   := {}

For nI := 1 To Len(aPeriodo)

	If aPeriodo[nI, 12]
		oPayments               :=  JsonObject():New()                               
		
		cPayIdHash              :=  aPeriodo[nI][2]              +"|" ;
									+aPeriodo[nI][3]              +"|" ;
									+aPeriodo[nI][4]              +"|" ;
									+aPeriodo[nI][5]              +"|" ;
									+aPeriodo[nI][6]              +"|" ;
									+aPeriodo[nI][7]              +"|" ;
									+cValToChar(aPeriodo[nI][8])  +"|" ;
									+aPeriodo[nI][9]              +"|" ;
									+cValToChar(aPeriodo[nI][10]) +"|" ;
									+aPeriodo[nI][6]              +"|" ;
									+aPeriodo[nI, 13] 
		
		cPayIdHash				:= rc4crypt( cPayIdHash, "MeuRH#PaymentID" )
		oPayments["id"]         := cPayIdHash 
		aDateGMT                := {}
		aDateGMT                := LocalToUTC( aPeriodo[nI][9], "12:00:00" )
		
		oPayments["paymentDate"]:= Substr(aPeriodo[nI][9],1,4) + "-" + ;
									Substr(aPeriodo[nI][9],5,2) + "-" + ;
									Substr(aPeriodo[nI][9],7,2) + "T" + aDateGMT[2] + "Z"
		
		aDateGMT                := {}
		aDateGMT                := LocalToUTC( aPeriodo[nI][6]+"15", "12:00:00"  )

		oPayments["referenceDate"] := Substr(aPeriodo[nI][14],1,4) + "-" + ;
										Substr(aPeriodo[nI][14],5,2) + "-" + ;
										Substr(aPeriodo[nI][14],7,2) + "T" + aDateGMT[2] + "Z"
		
		oPayments["value"]      := aPeriodo[nI][11]

		If cEmpAnt == aPeriodo[nI,13]
			oPayments["type"]   := Alltrim(EncodeUTF8(PosAlias("SRY", aPeriodo[nI][5], aPeriodo[nI][2], "RY_DESC")))
		Else
			//busca descri��o do roteiro na empresa de origem 
			cEmpREF := If( Empty(aPeriodo[nI,13]), cEmpAnt, aPeriodo[nI,13] )
			cEmpSRY := "%"+RetFullName("SRY", cEmpREF )+"%"
			cFilSRY := xEmpFilial("SRY", aPeriodo[nI,2], cEmpREF)

			BeginSql Alias cQrySRY
				SELECT RY_DESC
				FROM   %exp:cEmpSRY% SRY
				WHERE  SRY.RY_FILIAL  = %exp:cFilSRY%         And
						SRY.RY_CALCULO = %exp:aPeriodo[nI][5]% And
						SRY.%notDel%
			EndSql

			If (cQrySRY)->( !Eof() )
				oPayments["type"] := (cQrySRY)->RY_DESC
			ELSE
				oPayments["type"] := ""
			EndIf
			
			(cQrySRY)->( dbCloseArea() )
		EndIf
		
		Aadd(aData,oPayments)
		oPayments := Nil
		
	EndIf
		
Next nI

Return(Nil)


/*/{Protheus.doc}GetResume
- Fun��o respons�vel por criar o corpo do JSON de resumo do demonstrativo de pagamento
@author:	Matheus Bizutti
@since:		07/06/2017
/*/
Function GetResume(cRegistration,cFilFun,initView,endView,aData,oItemDetail,aPaymentId)

Local PaymentReceipt    :=  WSClassNew("TPaymentReceipts")
Local aEvents           := {}
Local aSubTotals        := {}
Local cCompany          := ""

DEFAULT cRegistration   := ""
DEFAULT cFilFun         := FwCodFil()	
DEFAULT initView        := ""
DEFAULT endView         := ""	
DEFAULT aData           := {}
DEFAULT aPaymentId      := {}

PaymentReceipt:FGTSBase					:= 0		//nBaseFgts
PaymentReceipt:MontlyFGTS				:= 0		//nFgts
PaymentReceipt:IRRFCalculationBasis     := 0		//nBaseIr
PaymentReceipt:INSSSalaryContribution	:= 0
PaymentReceipt:Alimony					:= 0
PaymentReceipt:DiscountTotal			:= 0
PaymentReceipt:RevenueTotal				:= 0
PaymentReceipt:ReceivableNetValue		:= 0 
PaymentReceipt:Itens                    := {}

If len(aPaymentId) < 11 .or. empty(aPaymentId[11])
   cCompany := cEmpAnt
   PaymentReceipt:Branch := cFilFun 	// Filial do Funcion�rio
Else   
   cCompany := aPaymentId[11]
   PaymentReceipt:Branch := aPaymentId[1] 
EndIf

If Len(aPaymentId) > 0
	fBuildItens(@PaymentReceipt, 					; //01
				aPaymentId[1],   					; //02
				aPaymentId[2],   					; //03
				Val(Substr(aPaymentId[5],5,2)), 	; //04
				Val(Substr(aPaymentId[5],1,4)), 	; //05
				aPaymentId[6], 						; //06
				Val(aPaymentId[9]), 				; //07
				Iif(aPaymentId[7] == "1" ,.T.,.F.), ; //08
				Stod(aPaymentId[8]), 				; //09
				cCompany, 							; //10
				AllTrim(aPaymentId[3]) ,			; //11
				.T.)								  //12
EndIf

PaymentReceipt:ReceivableNetValue := PaymentReceipt:RevenueTotal - PaymentReceipt:DiscountTotal

GetEvents(PaymentReceipt,@aEvents)
GetSubTotals(PaymentReceipt,@aSubTotals)

FreeObj(PaymentReceipt)
oItemDetail 			  := JsonObject():New()    
oItemDetail["id"]         := cKeyId //"D MG 01 |900001|00020|132|201712|1|2|T1"
oItemDetail["events"]     := aEvents
oItemDetail["subtotals"]  := aSubTotals

Return (Nil)


/*/{Protheus.doc}GetEvents
- Fun��o respons�vel por criar o corpo do JSON dos eventos do demonstrativo de pagamento
@author:	Matheus Bizutti
@since:		07/06/2017
/*/
Static Function GetEvents(PaymentReceipt,aEvents)

Local oItemEvents		:= Nil
Local nX				:= 0

Default aEvents         := {}
Default PaymentReceipt  := WSClassNew("TPaymentReceipts")

For nX := 1 To Len(PaymentReceipt:Itens)
	
	oItemEvents					:= JsonObject():New()
	
	oItemEvents["id"]          := PaymentReceipt:Itens[nX]:Code
	oItemEvents["description"] := Alltrim(EncodeUTF8(PaymentReceipt:Itens[nX]:Description))
	oItemEvents["quantity"]    := PaymentReceipt:Itens[nX]:Reference
	oItemEvents["type"]        := Iif(PaymentReceipt:Itens[nX]:Revenue > 0, "proceeds", "deduction")
	oItemEvents["value"]       := Iif(PaymentReceipt:Itens[nX]:Revenue > 0, PaymentReceipt:Itens[nX]:Revenue, PaymentReceipt:Itens[nX]:Discount) 
	
	Aadd(aEvents,oItemEvents)
	
Next nX

Return(Nil)

/*/{Protheus.doc}GetSubTotals
- Fun��o respons�vel por criar o corpo do JSON dos subtotais (subtotals) do demonstrativo de pagamento.
@author:	Matheus Bizutti
@since:		07/06/2017
/*/
Static Function GetSubTotals(PaymentReceipt,aSubTotals)

Default aSubTotals      := ""
Default PaymentReceipt  := WSClassNew("TPaymentReceipts")

/*********************************************************
- Cria os objetos JSON de subtotals:[{}]
- alimenta o Array aSubTotals passado por Refer�ncia
- e este array � utilizado na fun��o GetResume
**********************************************************/
CreateTotal(PaymentReceipt:RevenueTotal,STR0006,"proceeds",@aSubTotals) //"Proventos" - Proventos Totais
CreateTotal(PaymentReceipt:DiscountTotal,STR0007,"deductions",@aSubTotals) //"Descontos" - Descontos Totais
CreateTotal(PaymentReceipt:ReceivableNetValue,EncodeUTF8(STR0008),"net-value",@aSubTotals) //"L�quido" - Total l�quido a receber
CreateTotal(PaymentReceipt:FGTSBase,STR0009,"tax-base",@aSubTotals) //"Base de FGTS" - Base FGTS
CreateTotal(PaymentReceipt:MontlyFGTS,EncodeUTF8(STR0010),"starred",@aSubTotals) //"FGTS do m�s" - FGTS do m�s
CreateTotal(PaymentReceipt:INSSSalaryContribution,STR0011,"tax-base",@aSubTotals) //"Base de INSS" - Base de INSS
CreateTotal(PaymentReceipt:IRRFCalculationBasis,STR0012,"tax-base",@aSubTotals) //"Base de IRRF" -Base de IRRF

Return(Nil)

/*/{Protheus.doc}CreateTotal
- Fun��o respons�vel por alimentar o array aSubTotals, que cont�m a estrutura dos subtotais (subtotals) do demonstrativo de pagamento
@author:	Matheus Bizutti
@since:		07/06/2017
/*/
Static Function CreateTotal(nValue,cDescription,cType,aSubTotals)

Local oItemSubTotals := Nil

Default nValue          := 0
Default cDescription    := ""
Default cType           := ""
Default aSubTotals      := {}

oItemSubTotals 					:= JsonObject():New()
oItemSubTotals["description"]   := cDescription
oItemSubtotals["value"]         := nValue
oItemSubTotals["type"]          := cType

Aadd(aSubTotals, oItemSubTotals)

Return(Nil)


/*/{Protheus.doc} GetPaymRec
//Gera o recibo de pagamento e retorna para o parametro cFile
@author carlos.augusto
@since 28/05/2019
@version 1.0
@return ${return}, ${return_description}
@param aPaymentId, array, Array com os parametros de entrada
@param cFile, characters, Arquivo que sera retornado para impressao
@param aMsgDefault, array, Log de erros
@type function
/*/
Static Function GetPaymRec(aPaymentId, cFile, aMsgDefault)

	Local oFile
	Local cFileName 	:= ""
	Local cMsgTmp 		:= ""
	Local cPathFile 	:= ""
	Local cRootPath		:= ""
	Local cArqLocal 	:= ""
	Local cExtFile		:= ""
	Local cPDF			:= ".PDF"
	Local nX			:= 0
	Local nZ			:= 0
	Local nCont			:= 0
	Local nSleep		:= 0
	Local aFiles		:= {}
	Local lContinua 	:= .T.
	Local lRecibo 		:= ( SuperGetMV("MV_TCFDEMO",,"2") == "1" )
	Local lRdMake		:= ExistBlock("RECIBO")

	DEFAULT aMsgDefault := {}
	
    cExtFile	:= DTOS( DATE() ) + SubStr( TIME(), 1, 2) //Ano + Mes + Dia + Hora
    cFileName 	:= AllTrim(aPaymentId[1]) + "_" + AllTrim(aPaymentId[2]) + "_PAY"
    cRootPath 	:= GetSrvProfString ("ROOTPATH","")
	cArqLocal 	:= GetSrvProfString ("STARTPATH","")

	//------------------------------------------------------------------------------
	//Existe um problema ainda nao solucionado que o APP envia mais de uma requisicao via mobile
	//Quando isso ocorre o sistema nao gera o arquivo e envia uma resposta sem conteudo. 
	//Solucao paliativa:
	//Caso alguma requisicao falhe tentaremos gerar o arquivo novamente por 2 vezes no maximo
	//Cada nova requisicao ira gerar o arquivo com um nome diferente (Filial + Matricula + PAY + nX) 
	//------------------------------------------------------------------------------
    For nX := 1 To 2

		cPathFile 	:= ""
		nCont		:= 0
		nSleep 		+= 1000

		//Se existir o arquivo temporario nao executamos a GPEM580 porque indica uma requisicao em andamento
	    If !File( cArqLocal + cFileName + cExtFile + '*' )
			If lRecibo .And. lRdMake
				u_Recibo(.T., aPaymentId[1],aPaymentId[2],aPaymentId[3],aPaymentId[4],aPaymentId[5],aPaymentId[6], .T., cFileName + cExtFile + cValToChar(nX))
			else
	    		GPER030( .T. ,aPaymentId[1],aPaymentId[2],aPaymentId[3],aPaymentId[4],aPaymentId[5],aPaymentId[6], .T., cFileName + cExtFile + cValToChar(nX) )
			EndIf
	    EndIf

		aAdd( aFiles, cArqLocal + cFileName + cExtFile + cValToChar(nX) + cPDF )

	    //Avalia o arquivo gerado no servidor
	    While lContinua
			For nZ := 1 To Len(aFiles)
				cPathFile := aFiles[nZ]
				If File( cPathFile )
					oFile := FwFileReader():New( cPathFile )
					
					If (oFile:Open())
						cFile := oFile:FullRead()
						oFile:Close()
						lSucess := .T.
					EndIf
				EndIf
			Next nZ
	
		    //Em ambiente lento o sistema esta demorando para gerar o arquivo PDF
		    //Como alternativa pesquisaremos o arquivo por 5 vezes em 2 ciclos de x segundos:
			//5 segundos no primeiro ciclo, 10 segundos no segundo ciclo
		    If ( lContinua := Empty(cFile) .And. nCont <= 4 )
		    	nCont++
		    	Sleep(nSleep)
		    EndIf
	    End

	    If !Empty(cFile)
	    	Exit
	    Else
	    	lContinua := .T.
			aAdd( aMsgDefault, "" )

			cMsgTmp := ">>> "+ STR0028 +"("+ cValToChar(nX) +")" //"Aguardando a leitura do arquivo PDF..."
	    	conout( EncodeUTF8(cMsgTmp) ) 
			aAdd( aMsgDefault, cMsgTmp )

			cMsgTmp := ">>> "+ STR0027 +" ("+ cRootPath + cPathFile +")" //"Local do arquivo:"
			conout( EncodeUTF8( cMsgTmp ) ) 
			aAdd( aMsgDefault, cMsgTmp )

			If nX == 2
				aAdd( aMsgDefault, "" )
				aAdd( aMsgDefault, STR0029 ) //"Durante a execu��o do download verifique se o arquivo PDF est� sendo gerado no local indicado"

				If lRecibo .And. lRdMake
					aAdd( aMsgDefault, "" )
					aAdd( aMsgDefault, STR0030 ) //"Caso o recibo seja personalizado, atualize o sistema com uma vers�o mais recente do arquivo RECIBO.PRX dispon�vel na Central de Downloads da Totvs"
				EndIf
			EndIf
	    EndIf
    
    Next nX

    //Exclui os arquivos temporarios gerados durante o processamento (REL/PDF/PD_)
    fExcFileMRH( cArqLocal + cFileName + '*' )

Return .T.

/*/{Protheus.doc} OpenSx2Mrh
//Abre as SXs de outras empresas
@author:	Henrique Ferreira
@since:		01/05/2020
@return:		
/*/
Static Function OpenSx2Mrh(cEmp,cBckFil)

	cEmpAnt := cEmp
	cFilAnt := cBckFil	
	SX6->(dbclosearea())
	OpenSxs(,,,,cEmp,"SX6","SX6",,.F.)
	SX2->(dbclosearea())
	OpenSxs(,,,,cEmp,"SX2","SX2",,.F.)
	
Return

/*/{Protheus.doc} MyOpenFileMrh()
@author:	Henrique Ferreira
@since:		01/05/2020
- Abertura de arquivo para a empresa especificada.
@param: x1 - Alias - Tabela utilizada
@param: x2 - Alias - Tabela utilizada
@param: x3 - Padr�o - .T.
@param: x4 - Company - C�igo da empresa utilizada.
@param: x5 - Modo de compartilhamento da tabela.
/*/
Static Function MyOpenFileMrh(x1,x2,x3,x4,x5,x6)
Local xRet := .F.

xRet := EmpOpenFile(@x1,@x2,@x3,@x4,@x5,@x6)

cEmpAnt := x5

Return( xRet )

/*/{Protheus.doc} fGetIndDiss
//Obtem o indice do dissidio a partir de informa��es do c�lculo
@author Marcelo Silveira
@since 10/08/2021
@version 1.0
@since:		08/06/2019
@param:		cFunFil, string, codigo da filial do funcionario
			cFunMat, string, codigo da matricula do funcionario
			cDtRef, string, Ano/Mes referencia do calculo
			cTipo, string, tipo de aumento
@return:	nPerc, numerico, valor do indice do dissidio
/*/
Static Function fGetIndDiss( cFunFil, cFunMat, cDtRef, cTipo )

Local nPerc		:= 0
Local cDelete 	:= "% RHH.D_E_L_E_T_ = ' ' %"
Local cAliasRHH	:= GetNextAlias()
Local cRHHtab 	:= "%" + RetFullName("RHH", cEmpAnt) + "%"

BeginSql ALIAS cAliasRHH
	SELECT 
		RHH_FILIAL, RHH_MAT, RHH_VB, RHH_CALC, RHH_DATA, RHH_VALOR, RHH_TPOAUM, RHH_INDICE
	FROM 
		%exp:cRHHtab% RHH
	WHERE 	
		RHH.RHH_FILIAL = %Exp:cFunFil% AND
		RHH.RHH_MAT = %Exp:cFunMat% AND
		RHH.RHH_VB = '000' AND
		RHH.RHH_DATA = %Exp:cDtRef% AND
		RHH.RHH_TPOAUM = %Exp:cTipo% AND
		%exp:cDelete%
EndSql

If !(cAliasRHH)->(Eof())
	nPerc := (cAliasRHH)->RHH_INDICE
EndIf

(cAliasRHH)->( DBCloseArea() )

Return( nPerc )
