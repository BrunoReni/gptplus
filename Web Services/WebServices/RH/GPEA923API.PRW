#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#Include "TBICONN.CH"
#Include "GPEA923API.ch"

#DEFINE HELP_URL "https://tdn.totvs.com/x/ZYNvI"
#DEFINE ERRORCODE_DEF	400 // Erro no momento da listagem do registro.
#DEFINE ERRORSRV_DEF	500 // Erro no acesso ao EndPoint.
#DEFINE TAB  			CHR ( 13 ) + CHR ( 10 )

Private oError		As Object 
Private bError      := { |e| oError := e, Break(e) }
Private bErrorBlock := ErrorBlock( bError )

// Servi�o gen�rico para controle das informa��es de Controle de Estabilidade
WSRESTFUL stabilityControl DESCRIPTION OemToAnsi(STR0001) FORMAT ("application/json") // Servi�o gen�rico para controle das informa��es de Controle de Estabilidade
	WSDATA authorization 	As Character
	WSDATA stabilityId 		As Character
	WSDATA page			 	As Integer Optional
	WSDATA pageSize		 	As Integer Optional

	WSMETHOD POST; 	
	DESCRIPTION EncodeUTF8(OemToAnsi(STR0002)); // Inclui um novo Per�odo de Estabilidade no m�dulo SIGAGPE
	WSSYNTAX "/api/rh/v1/stabilityControl" ;
	PATH "/api/rh/v1/stabilityControl" ;
	PRODUCES 'application/json;charset=utf-8'; 
	TTALK "v1" 

	WSMETHOD PUT stabilityId ;
  	DESCRIPTION EncodeUTF8(OemToAnsi(STR0004)) ; 
  	WSSYNTAX "/api/rh/v1/stabilityControl/{stabilityId}" ; //Altera um Per�odo de Estabilidade no m�dulo SIGAGPE
  	PATH "/api/rh/v1/stabilityControl/{stabilityId}" ;
  	PRODUCES 'application/json;charset=utf-8' ;
  	TTALK "v1"

	WSMETHOD DELETE stabilityId ;
  	DESCRIPTION EncodeUTF8(OemToAnsi(STR0003)) ; //Delete um Per�odo de Estabilidade no m�dulo SIGAGPE
  	WSSYNTAX "/api/rh/v1/stabilityControl/{stabilityId}" ;
  	PATH "/api/rh/v1/stabilityControl/{stabilityId}" ;
  	PRODUCES 'application/json;charset=utf-8' ;
  	TTALK "v1"

END WSRESTFUL

/*/{Protheus.doc} DELETE
// M�todo respons�vel pela exclus�o do Per�odo de Estabiliade de um funcion�rio.
@author raquel.andrade
@since 12/03/2020
@version 1.0
@return return, return_description
/*/
WSMETHOD DELETE stabilityId WSREST stabilityControl

	Local aUrlParam	:= ::aUrlParms
	Local cJsonObj	:= "JsonObject():New()"
	Local oItem		:= &cJsonObj
	Local oItemDetail	:= &cJsonObj
	Local cToken := Self:GetHeader('Authorization')
	
	Local aDelChv		As Array
	Local lRetorno		As Logical	
	Local jEstab		As Object
	Local cChave         := ""
	
	DEFAULT Self:authorization  := ""
	DEFAULT Self:stabilityId   	:= ""

	jEstab		:= JsonObject():New()
	lRetorno	:= .T.
	
	BEGIN SEQUENCE

		if Empty(aUrlParam) .OR. Len(aUrlParam) == 0
			// "Informa��o stabilityId ausente ou inv�lida." ### "Erro na valida��o do recebimento da mensagem." 
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0005), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			lRetorno := .F.
			return (lRetorno)
		else 
			cChave = aUrlParam[1]
		EndIf

		If Empty(cChave) .Or. Len(fIdValid(cChave, @aDelChv )) == 0
			// "Informa��o stabilityId ausente ou inv�lida." ### "Erro na valida��o do recebimento da mensagem." 
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0005), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			lRetorno := .F.
		EndIf

		If lRetorno	.And. Len(aDelChv) > 0

			RESET ENVIRONMENT
			RPCSetType(3)
			PREPARE ENVIRONMENT EMPRESA aDelChv[1] FILIAL aDelChv[2] TABLES "RFX" MODULO "GPE"
			fResetErrorHandler()	

			lRetorno	:= fDelData(@jEstab, aDelChv)

			If lRetorno
				cResponse := fCompress(@jEstab)
				::SetResponse(cResponse)
			Else
				//"Ocorreu uma falha no retorno desta opera��o." ### "Erro na valida��o do recebimento da mensagem."
				SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0011), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			EndIf

		EndIf

		RECOVER
			lRetorno := .F.
			ErrorBlock(bErrorBlock)
			// "Ocorreu uma falha no retorno da informa��o."
			SetRestFault(ERRORSRV_DEF ,  EncodeUTF8(STR0008) ,.T. ,ERRORSRV_DEF  , oError:Description , HELP_URL, ) 		

	END SEQUENCE

Return lRetorno


/*/{Protheus.doc} PUT
// M�todo respons�vel pela altera��o do Per�odo de Estabiliade de um funcion�rio.
@author raquel.andrade
@since 12/03/2020
@version 1.0
@return return, return_description
/*/
WSMETHOD PUT stabilityId WSREST stabilityControl

	Local aUrlParam	:= ::aUrlParms
	Local cJsonObj	:= "JsonObject():New()"
	Local oItem		:= &cJsonObj
	Local oItemDetail	:= &cJsonObj
	Local cToken := Self:GetHeader('Authorization')

	Local aTemp   := {}
	Local aCodi   := {}
	Local aFunc   := {}
	Local aPutChv := {}
	Local aChvPr  := {}
	Local cBody			as Character 
	Local lRetorno 		As Logical
	Local jEstab		As Object
	Local cChave         := ""

	
	DEFAULT Self:authorization  := ""
	DEFAULT Self:stabilityId   	:= ""

	cBody     	:= ::GetContent()
	lRetorno 	:= .T.
	jEstab		:= JsonObject():New()
	jEstab:FromJSON(EncodeUTF8(NoAcento(cBody)))

	BEGIN SEQUENCE

		if Empty(aUrlParam) .OR. Len(aUrlParam) == 0
			// "Informa��o stabilityId ausente ou inv�lida." ### "Erro na valida��o do recebimento da mensagem." 
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0005), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			lRetorno := .F.
			return (lRetorno)
		else 
			cChave = aUrlParam[1]
		EndIf

		aTemp := StrTokArr2(cChave,";",.T.)
	
		If ( Len(aTemp) < 5)
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0005), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			lRetorno := .F.
			Return (lRetorno)
		EndIf

		aFunc := StrTokArr2(aTemp[3],"|",.T.)
		
		aCodi := StrTokArr2(aTemp[5],"|",.T.)
		
		If ( Len(aFunc) < 3)
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0005), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			lRetorno := .F.
			Return (lRetorno)
		EndIf
		If ( Len(aCodi) < 3)
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0005), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			lRetorno := .F.
			Return (lRetorno)
		EndIf

		aChvPr	:=  {	aTemp[1],;
		 				aTemp[2],;
						aFunc[1],;
						aFunc[2],;
						aFunc[3],;
						aTemp[3],;
						aCodi[1],;
						aCodi[2],;
						aCodi[3],;
			     	} 	

		If Empty(cChave) .Or. Len(fIdValid(cChave, @aPutChv )) == 0
			// "Informa��o stabilityId ausente ou inv�lida." ### "Erro na valida��o do recebimento da mensagem." 
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0005), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			lRetorno := .F.
		ElseIf !fTratDados(@jEstab,,,aChvPr,4)
				lRetorno	:= .F.
		EndIf

		If lRetorno	.And. Len(aPutChv) > 0 

			RESET ENVIRONMENT
			RPCSetType(3)
			PREPARE ENVIRONMENT EMPRESA aPutChv[1] FILIAL aPutChv[2] TABLES "RFX" MODULO "GPE"
			fResetErrorHandler()
			
			cChave := STRTran(cChave,";","|")

			lRetorno	:= fPutData(@jEstab, aPutChv, cBody, cChave)
			
			If lRetorno
				cResponse := fCompress(@jEstab)
				::SetResponse(cResponse)
			Else
				//"Ocorreu uma falha no retorno desta opera��o." ### "Erro na valida��o do recebimento da mensagem."
				SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0011), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			EndIf

		EndIf


		RECOVER
			lRetorno := .F.
			ErrorBlock(bErrorBlock)
			// "Ocorreu uma falha no retorno da informa��o."
			SetRestFault(ERRORSRV_DEF ,  EncodeUTF8(STR0008) ,.T. ,ERRORSRV_DEF  , oError:Description , HELP_URL, ) 
		
	END SEQUENCE

Return lRetorno

/*/{Protheus.doc} POST
// M�todo respons�vel pela inclus�o do Per�odo de Estabiliade de um funcion�rio.
@author raquel.andrade
@since 12/03/20120
@version 1.0
@param authorization, chave de autoriza��o
/*/
WSMETHOD POST HEADERPARAM authorization WSREST stabilityControl 

	Local aConteudo		As Array
	Local cChave		As Character
	Local cBody			As Character
	Local cCatch		As Character
	Local lRetorno		As Logical	
	Local jEstab		As Object

	jEstab		:= JsonObject():New()
	cBody		:= Self:GetContent()
	lRetorno	:= .T.
	aConteudo	:= {,,,,,}
	cChave		:= ""

	BEGIN SEQUENCE

		cCatch   := jEstab:FromJSON(EncodeUTF8(NoAcento(cBody)))
		
		If cCatch != Nil  .Or. Len(jEstab:GetNames()) == 0  
			// "N�o foi poss�vel efetuar a leitura do pacote enviado, favor verificar e reenviar." ### Erro na valida��o do recebimento da mensagem
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0009), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
			lRetorno := .F.
		ElseIf !fTratDados(@jEstab, @aConteudo, @cChave,,3)
			lRetorno := .F.
		EndIf

		If lRetorno .And. Len(aConteudo) > 0 .And. !Empty(cChave)
			
			RESET ENVIRONMENT
			RPCSetType(3)
			PREPARE ENVIRONMENT EMPRESA aConteudo[1] FILIAL aConteudo[2] TABLES "RFX" MODULO "GPE"	

			lRetorno	:= NewStabPer(cBody,jEstab,aConteudo,cChave)
			
			If lRetorno
				cResponse := fCompress(@jEstab)
				::SetResponse(cResponse)
			EndIf

		EndIf

		RECOVER
			lRetorno := .F.
			ErrorBlock(bErrorBlock)
			//"Ocorreu uma falha no retorno desta opera��o."
			SetRestFault(ERRORSRV_DEF ,  EncodeUTF8(STR0008) ,.T. ,ERRORSRV_DEF  , oError:Description , HELP_URL, ) 

	END SEQUENCE

Return lRetorno

/*/{Protheus.doc} NewStabPer
// M�todo que ir� gravar o Per�odo de Estabilidade do Funcion�rio
@author raquel.andrade
@since 12/02/2020
@return lRet, Logical, defini��o se houve sucesso ou falha na gera��o do curr�culo
@param cBody, characters, corpo do pacote enviado na requisi��o do m�todo
@param ojEstab, object, Json que ser� preenchido com o retorno
/*/
Static Function NewStabPer(cBody,jEstab,aConteudo,cChave)
	
	Local cSeek			As Character
	Local cRetSqlName	As Character
	Local lRetorno		As Logical
	Default cBody  		:= ""
	Default jEstab 		:= JsonObject():New()
	Default aConteudo	:= {,,,,,} // Grupo de Empresa, Filial, Matricula, Data de In�cio, Data de T�rmino, Tipo de Estabilidade
	Default cChave		:= ""

	lRetorno 	:= .F.
	
	Begin Transaction

		cRetSqlName := RetSqlName( "RFX" )+"\3"
		dbSelectArea("RFX")
		dbSetOrder(1) // RFX_FILIAL + RFX_MAT + DOTS(RFX_DATAI) + RFX_TPESTB
		cSeek := xFilial("RFX", aConteudo[2])+aConteudo[3]+DtoS(aConteudo[4])+aConteudo[6]
		
		DbSelectArea("RFX")
		RFX->(dbSetOrder( 1 ))
		If !RFX->(dbSeek(cSeek))

			Reclock("RFX",.T.,.T.)
			RFX->RFX_FILIAL		:=	xFilial("RFX", aConteudo[2])	
			RFX->RFX_MAT		:= 	aConteudo[3]
			RFX->RFX_DATAI		:=  aConteudo[4]
			RFX->RFX_TPESTB		:= 	aConteudo[6]

			If !Empty(aConteudo[5])
				RFX->RFX_DATAF		:=  aConteudo[5]
			EndIf	

			jEstab["id"] 	:= cChave

			lRetorno := .T.			
		else
			//"Ocorreu uma falha no retorno desta opera��o." ### ""Esta solicita��o de controle de estabilidade j� existe na base do Protheus. Verifique!"
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0017), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0011) , HELP_URL, )
			
		EndIf
		
	End Transaction
	
Return lRetorno


/*/{Protheus.doc} fTratDados
// Valida dados do jSon (verbo Post/Put)
@author raquel.andrade
@since 12/03/2020
@param jEstab,object, vari�vel de objeto que cont�m os dados de json
@param aConteudo , array, vari�vel array que cont�m campos grav�veis do Post
@param cChave , character, vari�vel que representa o id do Post
@param aChvPr , array, vari�vel array que cont�m  parametro stabilityId do Put
@param nOpc	, numeric, vari�vel que cont�m op��o de acesso (3-Post, 4-Put)
@return lRet, logical, vari�vel que verifica se ocorreu erro ou n�o
/*/
Static Function fTratDados(jEstab,aConteudo,cChave, aChvPr,nOpc)
	Local aNames	As Array 	
	Local aCpoObt	As Array
	Local aFunc		As Array
	Local aEstab	As Array
	Local cMsgRest	:= "" 	 
	Local ctmpCia 	:= ""
	Local ctmpFil 	:= ""
	Local ctmpEmp	:= ""
	Local ctmpDtI 	:= ""
	Local ctmpDtF 	:= ""
	Local ctmpSCd 	:= ""
	Local ctmpEstb	:= ""
	Local nItem		:= 0 	
	Local lRet		As Logical  

	Default jEstab 		:= JsonObject():New()
	Default aConteudo	:= {,,,,,}
	Default cChave		:= ""
	Default aChvPr		:= {}
	Default nOpc		:= 0

	cCpoObt		:= "companyId/branchId/employeeId/startDate/stabilityCode" // Campos obrigatorios (chave �nica)
	lRet		:= .T. 
	aNames		:= jEstab:GetNames()
	aCpoObt		:= StrToArray(cCpoObt,"/")
	aFunc		:= {} 
	aEstab		:= {}
	cMsgRest	:= ""
	

	// Verifica tags obrigat�rias
	//  "Verifique o conte�do da TAG ("
	// " ) pois ela � obrigat�ria para a manipula��o deste processo."
	If nOpc == 3 // Apenas para Post
		For nItem:= 1 to Len(aCpoObt)
			If aScan(aNames,{|x| UPPER(x) == UPPER(aCpoObt[nItem])})== 0
				cMsgRest+=  OemToAnsi(STR0012)+ aCpoObt[nItem] +OemToAnsi(STR0013) 
				lRet	:= .F.
			EndIf
		Next nItem
		
	EndIf

	If lRet
		For nItem:= 1 to Len(aNames)
			If UPPER(aNames[nItem]) $ "COMPANYID"
				ctmpCia := jEstab[aNames[nItem]]
			ElseIf UPPER(aNames[nItem]) =="BRANCHID" 
				ctmpFil := jEstab[aNames[nItem]]
			ElseIf UPPER(aNames[nItem]) $ "EMPLOYEEID" 
				If !Empty(jEstab[aNames[nItem]])    
					ctmpEmp	:= jEstab[aNames[nItem]]                                                                                        
					aFunc 	:= StrTokArr2(jEstab[aNames[nItem]],"|",.T.) 
				EndIf
			ElseIf UPPER(aNames[nItem]) $ "STARTDATE"
				ctmpDtI := jEstab[aNames[nItem]]
			ElseIf UPPER(aNames[nItem]) $ "ENDDATE"
				ctmpDtF := jEstab[aNames[nItem]]
			ElseIf UPPER(aNames[nItem]) $ "STABILITYCODE"
				If !Empty(jEstab[aNames[nItem]])   
					ctmpEstb	:= jEstab[aNames[nItem]]                                                                                         
					aEstab 		:= StrTokArr2(jEstab[aNames[nItem]],"|",.T.) 
				EndIf
			EndIf
		Next nItem
	EndIf

	
	If nOpc == 4 // Apenas para Put
		// Verifica se dados de Body s�o os mesmo de parametro stabilityId
		// ref a Grupo de Empresa + Filial + Dados Funcion�rio (dados fixos)
		If lRet .And. !Empty(aChvPr) .And. !(Len(aFunc) < 3)
			If  !(aChvPr[1] + aChvPr[2] + aChvPr[3] + aChvPr[4] + aChvPr[5] == ctmpCia + ctmpFil + aFunc[1] + aFunc[2] + aFunc[3] ) 
				// "Informa��o stabilityId difere do conte�do do pacote.
				cMsgRest		+= OemToAnsi(STR0016) 
				lRet	:= .F.
			EndIf
		EndIf
	EndIf

	//Verifica Empresa/Filial
	If lRet .And. !Empty(ctmpCia) .And. !Empty(ctmpFil) 
		If !FWFilExist(ctmpCia,ctmpFil)
			// "De-Para de Empresa/Filial n�o encontrado na base."
			cMsgRest		+= OemToAnsi(STR0007) 
			lRet	:= .F.
		EndIf
	EndIf

	// Verifica Matr�cula
 	If lRet .And. !Empty(ctmpCia) .And. !Empty(ctmpFil) 
	 	If Len(aFunc) == 3
		 	RESET ENVIRONMENT
			RPCSetType(3)
			PREPARE ENVIRONMENT EMPRESA ctmpCia FILIAL ctmpFil TABLES "SRA" MODULO "GPE"
			DBSelectArea("SRA")
			DBSetOrder(1)
			If !DBseek (aFunc[2]+aFunc[3])
				//"Verifique o conte�do da TAG () pois n�o foi poss�vel encontrar esta informa��o no Protheus."
				cMsgRest+= OemToAnsi(STR0012) +"employeeId" + OemToAnsi(STR0015) 
				lRet	:= .F.
			EndIf
		ElseIf lRet .And. Len(aFunc) < 3 .And. Len(aFunc) != 0
			//"Verifique o conte�do da TAG () pois n�o foi poss�vel encontrar esta informa��o no Protheus."
			cMsgRest+= OemToAnsi(STR0012) +"employeeId" + OemToAnsi(STR0015) 
			lRet	:= .F.
		EndIf
	EndIf

	// Verifica formato da Data de In�cio
	// "Verifique o conte�do da TAG ("
	// ") pois a data n�o est� no formato correto: 'YYYY-MM-DDTHH:MM:SS'"
	If lRet .And. !Empty(ctmpDtI)
		If  SubStr(ctmpDtI, 5,  1) != "-" .Or. SubStr(ctmpDtI, 8,  1) != "-" .Or. ;
			SubStr(ctmpDtI, 11, 1) != "T" .Or. SubStr(ctmpDtI, 14, 1) != ":" .Or. ; 
			SubStr(ctmpDtI, 17, 1) != ":" .Or. Empty(fClearDate(ctmpDtI))
			cMsgRest	+=  OemToAnsi(STR0012)+ "startDate" + OemToAnsi(STR0014)
			lRet	:= .F.
		EndIf
	EndIf

	// Verifica formato da Data de T�rmino
	// "Verifique o conte�do da TAG ("
	// ") pois a data n�o est� no formato correto: 'YYYY-MM-DDTHH:MM:SS'"
	If lRet .And. !Empty(ctmpDtF)
		If  SubStr(ctmpDtF, 5,  1) != "-" .Or. SubStr(ctmpDtF, 8,  1) != "-" .Or. ;
			SubStr(ctmpDtF, 11, 1) != "T" .Or. SubStr(ctmpDtF, 14, 1) != ":" .Or. ; 
			SubStr(ctmpDtF, 17, 1) != ":" .Or. Empty(fClearDate(ctmpDtF))
			cMsgRest	+=  OemToAnsi(STR0012)+ "endDate" + OemToAnsi(STR0014) 
			lRet	:= .F.
		EndIf
	EndIf

	// Verifica C�digo de Estabilidade
	//"Verifique o conte�do da TAG () pois n�o foi poss�vel encontrar esta informa��o no Protheus."
	If lRet .And. !Empty(ctmpCia) .And. !Empty(ctmpFil) 
		If ( Len(aEstab) == 3)
			ctmpSCd	:= aEstab[3]
			RESET ENVIRONMENT
			RPCSetType(3)
			PREPARE ENVIRONMENT EMPRESA ctmpCia FILIAL ctmpFil  TABLES "RCC" MODULO "GPE"  
			dbSelectArea( "RCC" )
			dbSetOrder(1) // RCC_FILIAL + RCC_CODIGO
			If !dbSeek(aEstab[2] + "S053") .Or. !ValidRCC('S053',ctmpSCd ,1,3) 
				cMsgRest+= OemToAnsi(STR0012) +"stabilityCode" + OemToAnsi(STR0015) 
				lRet	:= .F.
			EndIf  
		ElseIf lRet .And. Len(aEstab) < 3 .And. Len(aEstab) != 0
			cMsgRest+= OemToAnsi(STR0012) +"stabilityCode" + OemToAnsi(STR0015)
			lRet	:= .F.
		EndIf
	EndIf

	If !lRet .And. !Empty(cMsgRest)
		// "Erro na valida��o do recebimento da mensagem" 
		SetRestFault(ERRORCODE_DEF,  EncodeUTF8(STR0006), .T. ,ERRORCODE_DEF , EncodeUTF8(cMsgRest) , HELP_URL, )
	ElseIf nOpc == 3
		aConteudo	:= {	If(!Empty(aFunc[1]),aFunc[1] , ""),;					// [1] Grupo de Empresa
							If(!Empty(aFunc[2]),aFunc[2] , ""),;					// [2] Filial
							If(!Empty(aFunc[3]),aFunc[3] , ""),;					// [3] Matr�cula
							If(!Empty(ctmpDtI),fClearDate(ctmpDtI) , CtoD("//")),;  // [4] Data de In�cio
 							If(!Empty(ctmpDtF),fClearDate(ctmpDtF) , CtoD("//")),;	// [5] Data de T�rmino
							If(!Empty(ctmpSCd),ctmpSCd , "")	}					// [6] Tipo de Estabilidade
		cChave		:=  ctmpCia + ';' + ctmpFil + ';' + ctmpEmp + ';' + ctmpDtI + ';' + ctmpEstb
	EndIf 	
	
Return lRet

/*/{Protheus.doc} fIdValid
Valida dados da Chave (verbos Delete/Put)
@author raquel.andrade
@since 12/03/2020
@return lRetorno, return_description
@param  cChave, characters, descricao
@param  aChv, array, descricao
/*/
Static Function fIdValid(cChave, aChv)
	Local aFunc    := {}
	Local aEstab	:= {}
	Local aReto 	:= {}
	Local aErro 	:= {}
	Local aTemp := {}
	
	Local ctmpDtI   As Character
	Local lRetorno := .T.

	Default cChave	:= ""
	Default aChv	:= {} 

	aTemp := StrTokArr2(cChave,";",.T.)

	// Verifica preenchimento de todas as tags
	If ( Len(aTemp) < 5) 
		lRetorno	:= .F.
		Return (aErro)
	EndIf
	
	aFunc := StrTokArr2(aTemp[3],"|",.T.)

	If ( Len(aFunc) <> 3)
		lRetorno	:= .F.
		Return (aErro)
	EndIf

	aEstab := StrTokArr2(aTemp[5],"|",.T.)
	
	If ( Len(aEstab) <> 3)
		lRetorno	:= .F.
		Return (aErro)
	EndIf
		
	//Verifica Empresa/Filial
	If lRetorno .And. !FWFilExist(aTemp[1],aTemp[2])
		lRetorno	:= .F.
		Return (aErro)
	EndIf

	//Verifica Funcionario
	If lRetorno
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA aTemp[1] FILIAL aTemp[2] TABLES "SRA" MODULO "GPE"
		DBSelectArea("SRA")
		DBSetOrder(1)
		If ! DBseek (aFunc[2]+aFunc[3])
			lRetorno	:= .F.
			Return (aErro)
		Else
		// Verifica C�digo de Estabilidade	
			dbSelectArea( "RCC" )
			dbSetOrder(1) // RCC_FILIAL + RCC_CODIGO
			If  !dbSeek(aEstab[2] + "S053") .Or. !ValidRCC('S053',aEstab[3] ,1,3) 
				lRetorno	:= .F.
				Return (aErro)
			EndIf			
		EndIf
	EndIf

	// Verifica Data de In�cio
	// Formato Considerado como v�lido: "2001-01-01T18:25:43"
	If lRetorno .And. Len(aTemp[4]) > 0
		ctmpDtI :=  aTemp[4]
		If  SubStr(ctmpDtI, 5,  1) != "-" .Or. SubStr(ctmpDtI, 8,  1) != "-" .Or. ;
			SubStr(ctmpDtI, 11, 1) != "T" .Or. SubStr(ctmpDtI, 14, 1) != ":" .Or. ; 
			SubStr(ctmpDtI, 17, 1) != ":" .Or. Empty(fClearDate(ctmpDtI))
				lRetorno	:= .F.
				Return (aErro)
		EndIf
	EndIf

	If !lRetorno 
		// "Erro na valida��o do recebimento da mensagem" ### "Informa��o stabilityId ausente ou inv�lida."
		SetRestFault(ERRORCODE_DEF,  EncodeUTF8(STR0006), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0005) , HELP_URL, )
	Else		
		aReto	:= {	aTemp[1] ,;				// [1] Grupo de Empresa
						aTemp[2] ,;				// [2] Filial
						aFunc[3] ,;				// [3] Matr�cula
						fClearDate(ctmpDtI),;	// [4] Data de In�cio
						aEstab[3] 	}			// [5] Tipo de Estabilidade
	
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA aReto[1] FILIAL aReto[2] TABLES "RFX" MODULO "GPE"     
		dbSelectArea( "RFX" )
		dbSetOrder(1)
		If  !dbSeek(aReto[2] + aReto[3] + DtoS(aReto[4]) + aReto[5]) 
			lRetorno	:= .F.
		EndIf
	EndIf

	aChv	:= If(lRetorno,aClone(aReto),aClone(aErro))

Return (aChv)


/*/{Protheus.doc} fDelData
@author raquel.andrade
@since 12/03/2020
@return lRet, return_description
@param jEstab, object, descricao
@param  aDelChv, array, com conte�do da mensagem
/*/
Static Function fDelData(jEstab, aDelChv)

	Local lRet 	:= .F.

	Default jEstab 		:= JsonObject():New()
	Default aDelChv		:= {,,,,} // Grupo de Empresa + Filial + Matricula + Data de In�cio + Tipo de Estabilidade
	
	// Se n�o houver erros executa a exclus�o no banco
	Begin Transaction

		DBSelectArea("RFX")
		dbSetOrder(1) // RFX_FILIAL + RFX_MAT + DOTS(RFX_DATAI) + RFX_TPESTB
		
		// Deleta conte�do
		If RFX->(DbSeek(xFilial("RFX",aDelChv[2])+aDelChv[3]+DtoS(aDelChv[4])+aDelChv[5]))
			RecLock("RFX", .F.)
				RFX->( dbDelete() )
				RFX->( MsUnLock() )

			lRet := .T.
			
			jEstab["code"]		:= "200"
			jEstab["message"]	:= STR0010 // "Opera��o realizada com sucesso!"
		else
			SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0005), .T. ,ERRORCODE_DEF , EncodeUTF8(STR0006) , HELP_URL, )
		EndIF
	
	End Transaction

Return lRet

/*/{Protheus.doc} fPutData
// Inclui dados na tabela.
@author raquel.andrade
@since 12/03/2020
@return lRet, return_description
@param  jEstab, object, descricao
@param  aConteudo, array, com conte�do da mensagem
@param  cBody, characters, descricao
/*/
Static Function fPutData(jEstab, aPutChv, cBody, cChave)
	
	Local aNewChv		As Array
	Local aEstab		As Character	
	Local cDataI		As Character
	Local cDataF		As Character
	Local cObjDtI		As Character
	Local cObjDtF		As Character
	Local lRet			As Logical
	Local lDtTroca		As Logical

	Default jEstab 		:= JsonObject():New()
	Default aPutChv		:= {,,,,} // Grupo de Empresa + Filial + Matricula + Data de In�cio + Tipo de Estabilidade
	Default	cBody 		:= ""
	Default cChave		:= ""

	lRet 		:= .T.
	lDtTroca 	:= .F.
	aEstab		:= {}

	// Pega o conteudo do Body
	If !Empty(cBody)

		// Se n�o houver erros executa a altera��o no banco
		Begin Transaction
			RFX->(DBSelectArea("RFX"))
			RFX->(DBSetOrder(1)) // Filial + Matr�cula + Data de In�cio + Tipo de Estabilidade

			// Recebe novos valores dos campos
			If RFX->(DbSeek(xFilial("RFX",aPutChv[2])+aPutChv[3]+DtoS(aPutChv[4])+aPutChv[5]))
				
				RecLock("RFX", .F.)	

					If jEstab:hasProperty("startDate") .And. jEstab["startDate"] != ""
						cObjDtI	:= jEstab["startDate"]
						cDataI	:= fClearDate(cObjDtI)
						If !Empty(cDataI)
							RFX->RFX_DATAI  := cDataI 
							lDtTroca		:= .T.
						Else
							lRet	:= .F.
						EndIf
					EndIf

					If jEstab:hasProperty("endDate") .And. jEstab["endDate"] != ""
						cObjDtF	:= jEstab["endDate"]
						cDataF	:= fClearDate(cObjDtF)
						If !Empty(cDataF)
							RFX->RFX_DATAF := cDataF  
						Else
							lRet	:= .F.
						EndIf
					EndIf

					
					If jEstab:hasProperty("stabilityCode") .And. jEstab["stabilityCode"] != ""			                                                                                           
						aEstab = StrTokArr2(jEstab["stabilityCode"],"|",.T.)
						If Len(aEstab) == 3						
							RFX->RFX_TPESTB := aEstab[3]
						Else
							lRet	:= .F.
						EndIf
					EndIf


				RFX->( MsUnLock() )
				
				If lRet 
					aNewChv	:= StrTokArr2(cChave,"|",.T.)
					cChave	:= 	 	aNewChv[1] + ';' +; // Grupo de Empresa
									aNewChv[2] + ';' +; // Filial
									aNewChv[3] + '|' +; // Grupo de Empresa Funcion�rio
									aNewChv[4] + '|' +; // Filial Funcion�rio
									aNewChv[5] + ';' +; // Matr�cula Funcion�rio
									If(lDtTroca,cObjDtI,aNewChv[6]) + ';' +; // Data de In�cio
									aNewChv[7] + '|' +; // Grupo de Empresa Cod. Estabilidade
									aNewChv[8] + '|' +; // Filial Cod. Estabilidade
									If(Len(aEstab) == 0, aNewChv[9], aEstab[3])			// Cod. Estabilidade



					jEstab["id"] 		:= cChave
				EndIf

			EndIF
		End Transaction
	EndIf

Return lRet

/*/{Protheus.doc} fResetErrorHandler
//TODO fSetErro Seta c�digo e mensagem de erro
@author oliveira.hugo
@return return, boolean, valor fixo .T.
@param cTitle, characters, t�tulo do erro
/*/
Static Function fResetErrorHandler(cTitle)
	bError  := { |e| oError := e , Break(e) }
	bErrorBlock    := ErrorBlock( bError )
Return(.T.)


/*/{Protheus.doc} fCompress
//TODO Descri��o auto-gerada.
@author oliveira.hugo
@since 07/08/2019
@return return, return_description
@param oObj, object, descricao
/*/
Static Function fCompress(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.
	
	// Set gzip format to Json Object
	cJson := oObj:toJSON()
	
	cJson := EncodeUTF8(cJson)

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


/*/{Protheus.doc} function ClearDate
Clean especial character from Date Input. Input Format: 2012-04-23T18:25:43
@author  Wesley Alves Pereira
@since   02/05/2019
@version 12.1.23
/*/
Static Function fClearDate(cDate)
Local dData := STOD("")
	
	cDate := StrTran(cDate, "T", "")
	cDate := StrTran(cDate, ":", "")
	cDate := StrTran(cDate, "-", "")
	cDate := SubStr(cDate,1,8)
	dData := StoD(cDate)
	
Return ( dData )
