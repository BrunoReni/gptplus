#Include "PROTHEUS.CH"
#Include "STDZREDUCTION.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} STDZRedGr
Function grava redu��o Z  
@param   	dMvmtDate - Data do movimento
@param   	cCOOIni - COO Inicial
@param   	nGTIni - Gt Inicial
@param   	aReduction - Dados da Redu��o
@param   	nOutrosR - Outros
@param   	nBas001 - Base
@param   	aField - Campos
@param   	nImpDebt -Imposto Debitado
@param   	cPafMD5 - MD5 PAF
@param   	cLoja - Loja
@author  Varejo
@version 	P11.8
@since   	03/07/2013
/*/
//-------------------------------------------------------------------
Function STDZRedGr(dMvmtDate, cCOOIni	, nGTIni, aReduction,;
				 	nOutrosR, nBas001	, aField, nImpDebt,;
					cPafMD5 , cLoja 	, cHrRedZ)

Local dDataRedZ	:= Date()								// Data da Reducao Z
Local nSaveSX8	:= GetSX8Len()							// Ultimo numero do SX8
Local cNumero	:= STDRezNum( dMvmtDate )				// Numero da Movimentacao
Local nI		:= 1					   				// Contador do For
Local lIntSIAC	:= SuperGetMV("MV_SCINTEG",NiL,.F.)	// Verifica se a integracao SIAC esta ativa  
Local aArea		:= GetArea()
Local aAreaSFI  := SFI->(GetArea())

//variaveis para separacao das aliquotas de ISS
Local cLinhaISS	:= ""
Local cTribISS	:= ""
Local cCampo	:= ""
Local cBaseISS	:= ""
Local cVlrBISS	:= ""
Local cTotIss	:= ""
Local cCodIss	:= ""
Local nSendOn	:= SuperGetMV("MV_LJSENDO",,0) //Retorno como sera a integracao da reducao Z - 0 - via job - 1 online - 2 startjob   
Local nCampos 	:= 0     
Local nX		:= 0   
Local aData		:= {}   
Local lSendRZ	:= .F.
Local lTribEspISS:= .F. //Valida tributa��o especifica para al�quotas de ISS - IS1 / NS1 / FS1

Default	nOutrosR := 0
Default nBas001	 := 0
Default aField	 := {}
Default	cPafMD5  := ""
Default	nImpDebt := 0       
Default cLoja	 := xFilial("SFI")
Default cHrRedZ	 := StrTran( Time() , ":" )
					
DbSelectArea("SFI")
SFI->( DbSetOrder(1) )
If !SFI->( DbSeek(xFilial("SFI") + DTOS(dMvmtDate) + aReduction[2] + aReduction[4]) )

	Conout("08. STWZREDUCTION - Inicia gravacao no SFI")
	LjGrvLog( Nil, "08. STWZREDUCTION - Inicia gravacao no SFI" )

	RecLock("SFI",.T.)
	Replace FI_FILIAL   WITH  cLoja
	Replace FI_DTMOVTO  WITH  dMvmtDate
	Replace FI_PDV		WITH  aReduction[2]
	Replace FI_SERPDV 	WITH  aReduction[3]
	Replace FI_NUMREDZ 	WITH  aReduction[4]
	Replace FI_NUMINI 	WITH  cCOOIni
	Replace FI_NUMFIM 	WITH  aReduction[7]
	Replace FI_CANCEL	WITH  Val(aReduction[8])
	Replace FI_VALCON 	WITH  Val(aReduction[9])
	Replace FI_DESC		WITH  Val(aReduction[10])
	Replace FI_SUBTRIB	WITH  Val(aReduction[11])
	Replace FI_ISENTO	WITH  Val(aReduction[12])
	Replace FI_NTRIB	WITH  Val(aReduction[13])
	Replace FI_ISS		WITH  Val( SubStr(aReduction[17],1,14) )
	Replace FI_CRO		WITH  aReduction[18]
	Replace FI_COO		WITH  aReduction[15]
	Replace FI_OUTROSR	WITH  Val(aReduction[16])
	Replace FI_NUMERO	WITH  cNumero
	Replace FI_GTINI	WITH  nGTIni	
	Replace FI_GTFINAL 	WITH  Val(aReduction[5])
	Replace FI_DTREDZ	WITH dDataRedZ
	Replace FI_HRREDZ	WITH cHrRedZ
	Replace FI_OUTROSR	WITH nOutrosR		
	Replace FI_BAS001	WITH nBas001
	Replace FI_DESISS 	WITH Val(aReduction[19])
	Replace FI_CANISS	WITH Val(aReduction[20])
	
	/*Gravacao dos campos extras */
	If !Empty(aField)
		For nI := 1 To Len(aField)
			If SFI->( ColumnPos(aField[nI][1]) ) > 0
				Replace &(aField[nI][1]) With aField[nI][2]
			Else
				Conout("O campo '" + aField[nI][1] + "' n�o existe na base. Dados da Al�quota n�o ser�o gravados")
				LjGrvLog( Nil, "O campo '" + cCampo + "' n�o existe na base. Dados da Al�quota n�o ser�o gravados")
			EndIf
		Next nI
	EndIf

	//���������������������������������Ŀ
	//�Tratamento para Aliquotas de ISS �
	//�����������������������������������	
	If !lIntSIAC
		//Pega as aliquotas e os valores de ISS para que sejam gravados separadamente  
		nAtAux 		:= At(";",aReduction[17])+1
		aReduction[17]:= Subs(aReduction[17], nAtAux , Len(aReduction[17]) ) // Pega a partir da "2" posi��o de aReduction[17] pois a primeira traz o valor total de ISS		
		
		While Len(aReduction[17]) > 0 .AND. nAtAux > 0

			nAtAux := At(";", aReduction[17])
			If nAtAux > 0
				lTribEspISS := .F.
				
				cLinhaISS	:= SUBS(aReduction[17],1,nAtAux-1) 
				If SubStr(cLinhaISS,1,2) $ "IS|NS|FS" //IS1 - NS1 - FS1
					cTribISS := Substr(cLinhaISS,1,3)
					nCountPos:= -3
					lTribEspISS := .T.
				ElseIf SubStr(cLinhaISS,1,1) == "S" // Caso venha com o indice da aliquota de ISS deve tratar 
					cTribISS	:= Substr(cLinhaISS,2,5)
					nCountPos	:= 0
				Else
					cTribISS	:= Substr(cLinhaISS,4,5)
					nCountPos	:= 2
				EndIf
				
				If lTribEspISS
					If cTribISS == "IS1"
						cCampo := "FI_ISSISEN"
						cCodIss:= "IS"
						
					ElseIf cTribISS == "NS1"
						cCampo := "FI_ISSNTRI"
						cCodIss:= "NS"
						
					ElseIf cTribISS == "FS1"
						cCampo := "FI_ISSFTRI"
						cCodIss:= "FS"
					EndIf
				Else
					cCodIss	:= AllTrim(Str(Val(cTribISS)))
					cTribISS	:= StrTran(cTribISS,'.','')
					cTribISS	:= StrTran(cTribISS,',','')
				
					If !(Len(cTribISS) == 4)
						cTribISS	:= StrZero( Val(cTribISS) , 5 , 2 )
						cTribISS	:= StrTran(cTribISS,'.','')
						cTribISS	:= StrTran(cTribISS,',','')
						cTribISS	:= "0" + cTribISS
					EndIf
				
					cCampo		:= "FI_BIS" + cTribISS
				EndIf
				
				cBaseISS	:= Subs(cLinhaISS,nCountPos+8,14) 			// Pega o valor de base
				cVlrBISS	:= Subs(cLinhaISS,nCountPos+23,Len(cLinhaISS))	// Pega o valor deduzido
				
				If SFI->(ColumnPos(cCampo)) > 0
				    REPLACE &(cCampo)	WITH Val(cBaseISS)
				Else				
					Conout("O campo '" + cCampo + "' n�o existe na base. Dados da Al�quota n�o ser�o gravados")
					LjGrvLog( Nil, "O campo '" + cCampo + "' n�o existe na base. Dados da Al�quota n�o ser�o gravados")
				EndIf				                      
				
				If !lTribEspISS
					cCampo 		:= "FI_ISS" + cTribISS
					If SFI->(ColumnPos(cCampo)) > 0
					    REPLACE &(cCampo) 	WITH Val(cVlrBISS)
					Else				
						Conout("O campo '" + cCampo + "' n�o existe na base. Dados da Al�quota n�o ser�o gravados")				    
						LjGrvLog( Nil, "O campo '" + cCampo + "' n�o existe na base. Dados da Al�quota n�o ser�o gravados")
					EndIf
				EndIf
				
				cCampo 		:= "FI_ICOD" + cCodIss
				If SFI->(ColumnPos(cCampo) ) > 0
					If lTribEspISS
						cTotIss := cCodIss
					Else
						cTotIss	:= StrZero( Val(cCodIss) , 5 , 2)
						cTotIss	:= StrTran( cTotIss , "." , "" )
						cTotIss	:= "S" + StrTran( cTotIss , "," ,"")
					EndIf
					REPLACE &(cCampo) 	WITH cTotIss
				Else				
					Conout("O campo '" + cCampo + "' n�o existe na base. Dados da Al�quota n�o ser�o gravados")				    
					LjGrvLog( Nil, "O campo '" + cCampo + "' n�o existe na base. Dados da Al�quota n�o ser�o gravados")
				EndIf
				
				aReduction[17]:= SUBS(aReduction[17], nAtAux + 1, LEN(aReduction[17]) )
			Else       
			    If SFI->(ColumnPos("FI_BIS0500")) > 0
					REPLACE FI_BIS0500 WITH 0
				EndIf
				If SFI->(ColumnPos("FI_ISS0500")) > 0
					REPLACE FI_ISS0500 WITH 0
				EndIf
			Endif
		End
	EndIf
	
	//Esses 3 Campos Usados no PAF mas sempre ser�o gravados
	Replace SFI->FI_XMLENV With "N"
	Replace SFI->FI_XMLRPAF With " "
	Replace SFI->FI_XMLEPAF With " "
	
	Replace FI_IMPDEBT With nImpDebt
	Replace FI_SITUA   With "00"
	
	SFI->( MsUnlock() )
	
	//Grava��o dos campos de valida��o do MD5 da SFI
	If STBIsPAF(SM0->M0_CGC)
		cPafMD5	:= STxPafMd5("SFI")
		RecLock("SFI",.F.)
		Replace SFI->FI_PAFMD5 With cPafMd5
		SFI->(MsUnlock())
		
		cPafMD5	:= STxPafMd5("SFI",,"2")
		RecLock("SFI",.F.)
		Replace SFI->FI_MD5TRIB With cPafMD5
		SFI->(MsUnlock())		
	EndIf
	
	While GetSx8Len() > nSaveSX8
		ConfirmSX8()
	End

	//Prepara os dados para envio da venda online
	If (nSendOn == 1 .OR. nSendOn == 2) .AND. SFI->FI_SITUA == "00"
	
		nCampos := FCount() 
		
		For nX := 1 To nCampos   		
		   	AAdd( aData , { FieldName( nX ), FieldGet( nX ) } ) 
		Next nX

        If Len(aData) > 0

			//Transmite a reducao Z para retaguarda
			If nSendOn == 1            
				MsgRun("Transmitindo Redu��o Z",'Aguarde...',{||STDSendRZ(aData,@lSendRZ)}) //"Transmitindo Redu��o Z"
			ElseIf nSendOn == 2
				StartJob("STDSendRZ", GetEnvServer(), .F., aData,@lSendRZ,.T.,cEmpAnt,cFilAnt)
			EndIf

            If lSendRZ
				RecLock("SFI",.F.)
				Replace SFI->FI_SITUA  With	"TX"
				SFI->(MsUnlock())                     
            EndIf
        EndIf
	EndIf
Else
	Conout("08. STWZREDUCTION  - Nao foi possivel gravar a Reducao Z, pois a mesma ja existe")
	LjGrvLog( Nil, "08. STWZREDUCTION  - Nao foi possivel gravar a Reducao Z, pois a mesma ja existe" )
EndIf    

RestArea(aAreaSFI)
RestArea(aArea) 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STDZRedData
Dados da Redu��o Z  
@type 	Function
@param  dAuxData , data , Data
@param  cPDV , caracter, PDV
@author Varejo
@version 	P11.8
@since   	03/07/2013
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function  STDZRedData(dAuxData)   
	Local aArea := GetArea()  
	Local aAreaSFI := SFI->(GetArea()) 
	
	SFI->( DbSetOrder(1) )
	SFI->( DbSeek(xFilial("SFI")) ) 	
	dAuxData := SFI->FI_DTMOVTO	

    RestArea(aAreaSFI)
	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STDZRedGTCOO
Dados da Redu��o Z  
@param   	nGTIni - GT Inicial
@param   	cCOOINI - COO Inicial
@param   	cReduction - Redu��o
@param   	dDate - Data
@author  Varejo                    
@version 	P11.8
@since   	03/07/2013
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDZRedGTCOO(nGTIni, cCOOINI, cReduction, dDate)
	Local aArea := GetArea()  
	Local aAreaSFI := SFI->(GetArea()) 
	Local lFound :=  .F.
	
	SFI->( DbSetOrder(1) )
	SFI->( DbSeek(xFilial("SFI")) ) 
		
	lFound :=  SFI->( DbSeek(xFilial("SFI") + DTOS(dDate) + cReduction) ) .OR. ;
			SFI->( DbSeek(xFilial("SFI") + DTOS(dDate) + Subs(cReduction, 2, 3)) )
			
	If 	lFound
		nGTIni 	:= SFI->FI_GTFINAL
		cCOOIni 	:= StrZero( Val(SFI->FI_COO) + 1, Len(SFI->FI_COO) )
	EndIf				
    RestArea(aAreaSFI)
	RestArea(aArea) 
Return lFound   


//-------------------------------------------------------------------
/*/{Protheus.doc} STDRezNum
Numerador da Redu��o Z  
@param   	dData - Data
@author  Varejo                    
@version 	P11.8
@since   	03/07/2013
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDRezNum(dData) 
Local aArea := GetArea()  
Local aAreaSFI := SFI->(GetArea()) 
Local cRetorno

SFI->(dbSetOrder(1))
If SFI->(dbSeek(xFilial("SFI")+DTOS(dData)))
	cRetorno := SFI->FI_NUMERO
Else
	cRetorno := GetSx8Num("SFI","FI_NUMERO")
Endif
RestArea(aAreaSFI)
RestArea(aArea)

Return cRetorno 

//-------------------------------------------------------------------
/*/{Protheus.doc} STDLastRedZ
Verifica ultima reducao Z
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	lPAFECF - eh Paf-ECF
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STDLastRedZ()  
Local lRet			:= .T.
Local lMVLJVLCRO	:= SuperGetMV( "MV_LJVLCRO",, .F. )	// Sinaliza se permite recriar arquivo mesmo com incremento de CRO
Local cPDV			:= STFGetStation("PDV")
Local dDataRedZ		:= CTOD("")
Local oWS			:= WsFrtPafEcf():New()
Local cWSServer		:= AllTrim(STFGetStation("WSSRV"))
Local lCrz			:= .F.
Local lCro			:= .F.
Local lVendaBrut	:= .F. 
Local lHomolPaf		:= STBHomolPaf()    
Local aDados		:= {}
Local cReduction	:= "" 
Local aRet			:= {}   
Local nAtAux		:= 0
Local aReduction	:= {}
Local cMV_LJGRMR	 := IIF(STBIsPAF(SM0->M0_CGC), "S", SuperGetMv("MV_LJGRMR", ,"S")) 

//�������������������������������������������������������������������������T�
//�Requisito XXII(Item 7 e 8):											   �
//�Comparar os n�meros do CRZ e do CRO e o valor da Venda Bruta Di�ria,    �
//�referentes a ultima Reducao Z gravada na Memoria Fiscal com os n�meros  �
//�e valor correspondentes no banco de dados.   						   �
//�A crit�rio da UF, permite recriar quando houver incremento do CRO.      �
//�Obs.: Armazena dados RedZ da memoria fiscal na tabela SFI local, utiliza�
//�SFI da Retaguarda como base nos arquivos do PAF-ECF.                    �
//�������������������������������������������������������������������������T�

                                
//Posiciona na ultima RedZ armazenada em banco local capturada da Memoria Fiscal
DBSelectArea("SFI")
DbSetOrder(1) //FI_FILIAL+DTOS(FI_DTMOVTO)+FI_PDV+FI_NUMREDZ
SFI->(dbGoBottom()) //Posiciona no ultimo registro
dDataRedZ := SFI->FI_DTMOVTO

If !lHomolPaf
	//Busca na Retaguarda dados da ultima RedZ utilizados nos arquivos do PAF-ECF
	oWs:_URL := "http://"+cWSServer+"/FRTPAFECF.apw" //Ajusta o caminho do servico
	iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oWs),Nil) //Monta o Header de Autentica��o do Web Service
	LJMsgRun("Executando consulta na retaguarda",,{||lRet := oWs:LstRedZ(dDataRedZ, dDataRedZ, cPDV, cEmpAnt,cFilAnt)}) // "Executando consulta na retaguarda"
	
	If (lRet == Nil) .OR. (!lRet)
		STFMessage("STDLastRedZ", "STOPPOPUP", STR0005)//"Erro na execu��o do WebService M�todo: LstRedZ"
		STFShowMessage("STDLastRedZ")		
		lRet := .F.
	Else
		aRetWs := aClone(oWs:oWsLstRedZResult:oWsRedZList)
		oWs:RESET()
		oWs := Nil
		                                                     
		//Compara CRZ, CRO e Venda Bruta( Memoria(SFI Local) x Banco(Consulta WS Retaguarda) )
		If Len(aRetWs) > 0 
			lCrz 		:= IIF(Val(SFI->FI_NUMREDZ) == aRetWs[01]:nContRedZ,.T.,.F.)					//CRZ - Contador de Reducoes Z
			lCro 		:= IIF(Val(SFI->FI_CRO) == aRetWs[01]:nContReinic .OR.;							//CRO - Contador de Reinicio de Operacoes,
							  (Val(SFI->FI_CRO) > aRetWs[01]:nContReinic) .AND. lMVLJVLCRO, .T.,.F.)	//quando habilitado permite Recriar mesmo com incremento do CRO na Memoria do ECF
			lVendaBrut 	:= IIF(SFI->(FI_VALCON+FI_DESC+FI_CANCEL) == aRetWs[01]:nTotBrutDia,.T.,.F.)  	//Venda Bruta     
		EndIf
			
		lRet := IIF(lCrz .AND. lCro .AND. lVendaBrut,.T.,.F.)
	EndIf
Else
	cReduction := cMV_LJGRMR + space(5000)	//PROBLEMAS NO TIMEOUT, CAPTURA OS DADOS DA REDUCAO
	aDados := {cReduction}
	aRet := STFFireEvent(	ProcName(0)																,;		// Nome do processo
											"STRedZData"																,;		// Nome do evento
											aDados)

	If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 0
		cReduction := aDados[1] 
		While Len(cReduction) > 0
			nAtAux := At("|", cReduction)
			If nAtAux > 0
				AAdd(aReduction, SUBS(cReduction,1,nAtAux-1) )
				cReduction := SUBS(cReduction, nAtAux + 1, LEN(cReduction) )
			Else
				cReduction := ""
			Endif
		End
		If Len(aReduction) > 0
			lCrz 		:= Val(SFI->FI_NUMREDZ) == Val(aReduction[4])					//CRZ - Contador de Reducoes Z
			lCro 		:= Val(SFI->FI_CRO) == Val(aReduction[18]) .OR.;							//CRO - Contador de Reinicio de Operacoes,
					  (Val(SFI->FI_CRO) <= Val(aReduction[18])) //teste 
			lVendaBrut 	:= SFI->(FI_VALCON+FI_DESC+FI_CANCEL) == Val(aReduction[9]) + Val(aReduction[10]) + Val(aReduction[8])  	//Venda Bruta     
	
			
			lRet := Val(SFI->FI_CRO) < Val(aReduction[18]) .OR. (lCrz .AND. Val(SFI->FI_CRO) = Val(aReduction[18]) .AND. lVendaBrut)
		Else
			//Busca na Retaguarda dados da ultima RedZ utilizados nos arquivos do PAF-ECF
			oWs:_URL := "http://"+cWSServer+"/FRTPAFECF.apw" //Ajusta o caminho do servico
			LJMsgRun("Executando consulta na retaguarda",,{||lRet := oWs:LstRedZ(dDataRedZ, dDataRedZ, cPDV, cEmpAnt,cFilAnt)}) // "Executando consulta na retaguarda"
			
			If (lRet == Nil) .OR. (!lRet)
				STFMessage("STDLastRedZ", "STOPPOPUP", STR0005)//"Erro na execu��o do WebService M�todo: LstRedZ"
				STFShowMessage("STDLastRedZ")		
				lRet := .F.
			Else
				aRetWs := aClone(oWs:oWsLstRedZResult:oWsRedZList)
				oWs:RESET()
				oWs := Nil
				lRet := .F.
				                                                     
				//Compara CRZ, CRO e Venda Bruta( Memoria(SFI Local) x Banco(Consulta WS Retaguarda) )
				If Len(aRetWs) > 0 
					lCrz 		:= Val(SFI->FI_NUMREDZ) == aRetWs[01]:nContRedZ					//CRZ - Contador de Reducoes Z
					lCro 		:=  Val(SFI->FI_CRO) == aRetWs[01]:nContReinic .OR.;							//CRO - Contador de Reinicio de Operacoes,
									  (Val(SFI->FI_CRO) > aRetWs[01]:nContReinic) 	//quando habilitado permite Recriar mesmo com incremento do CRO na Memoria do ECF
					lVendaBrut 	:= SFI->(FI_VALCON+FI_DESC+FI_CANCEL) == aRetWs[01]:nTotBrutDia  	//Venda Bruta     
					lRet :=  Val(SFI->FI_CRO) < aRetWs[01]:nContReinic .OR. (lCrz .AND. Val(SFI->FI_CRO) = aRetWs[01]:nContReinic .AND. lVendaBrut)

				EndIf					
			EndIf		     
		EndIf
	Else
		STFMessage("STDLastRedZ2", "STOPPOPUP", STR0006)//"Erro na captura dos dados da �ltima Redu��o."
		STFShowMessage("STDLastRedZ2")	
		lRet := .F.
	EndIf
 
EndIf     		

Return lRet

 
 //-------------------------------------------------------------------
/*/{Protheus.doc} STDZLastRZDt
Data da ultima reducao  
@param   	dAuxData - Data
@param   	cPDV - PDV
@author  Varejo
@version 	P11.8
@since   	03/07/2013
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function  STDZLastRZDt()   
Local aArea := GetArea()  
Local aAreaSFI := SFI->(GetArea()) 
Local dAuxData := CtoD("")

SFI->( DbSetOrder(1) )
SFI->( DbSeek(xFilial("SFI") + "29991231")) 	
SFI->( DbSkip(-1)) 
dAuxData := SFI->FI_DTMOVTO	

RestArea(aAreaSFI)
RestArea(aArea)
	
Return dAuxData 
