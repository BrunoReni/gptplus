#INCLUDE "Protheus.ch"
#INCLUDE "FWADAPTEREAI.CH"

Static cEspecie   := ""
Static cTipOpe    := ""
Static cTypeDoc   := ""
Static cIdEnt     := ""
Static cTipEnv    := ""
Static cCodSEF    := ""
Static cAmbiente  := ""
Static cEntSai    := ""
Static cVersaoCTe := ""
Static lCte       := .T.
Static lUsaColab  := .T.
Static lReenvReg  := .F.
Static lCont      := .F.
Static oWs
Static oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSAE76  � Autor � Valdemar Roberto    � Data � 12.12.2016 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envio de documentos - Integra��o com Datasul               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE76(lExp01)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lExp01 := Indica se � reenvio                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMSAE76(lReenvReg,cCodRSEF,cAlias,cIndice,cConteudo,lEnvEstor)
Local cTMSERP 		:= SuperGetMV("MV_TMSERP",," ")	//-- Condi��o de integra��o com ERP (0 - Protheus, 1 - Datasul)
Local nVlrNDF    	:= 0
Local nAliqISS	 	:= 0
Local cCnpjForn	 	:= ''
Local aImpostos	 	:= {}
Local cEntitName 	:= "TRANSPORTDOCUMENT"
Local aAreaSDG		:= SDG->(GetArea())
Local aAreaSA1		:= SA1->(GetArea())
Local aAreaDTR		:= DTR->(GetArea())
Local aEAIRET       := {}
Local nVlrPdg		:= 0
Local nVlrAdi		:= 0
Local cHistory		:= ''
Local lEnvInclus	:= .T.
Local lRet			:= .T.
Local aEAIRET
Local cOriPdg		:= ""

Private oDTClass    := NIL

DEFAULT lReenvReg := .F.
DEFAULT cCodRSEF  := ""
DEFAULT cAlias	  := "" 
DEFAULT cIndice	  := ""
DEFAULT cConteudo := ""
DEFAULT lEnvEstor := .F.

lReenvio := lReenvReg
cCodSEF  := cCodRSEF

If cTMSERP == "1"
	If cAlias == 'DTY'
		DTY->(DbSetOrder(Val(cIndice)))
		If DTY->(MsSeek(cConteudo))
			//--Busca Informa��es das Despesas da Viagem.
			a240BscSDG(DTY->DTY_FILORI,DTY->DTY_VIAGEM,DTY->DTY_CODVEI , 0 ,'2', @nVlrNDF)
			//--Busca o CNPJ do Fornecedor
			cCnpjForn := Posicione('SA1',1,FwxFilial('SA1')+DTY->(DTY_CODFOR+DTY_LOJFOR),'A1_CGC')	
			//--Busca os valores dos Impostos para a viagem posicionada
			aImpostos := A250RetImp()
			
			dbSelectArea(cAlias)						

			//| Chama Rotina respons�vel pela grava��o DJR e DJQ, respons�veis pelo reenvio da mensagem �nica ao ERp PROTHEUS.
			TMSIE76GRV(cAlias, cIndice, DTY->(DTY_FILIAL+DTY_FILORI+DTY_VIAGEM+DTY_NUMCTC),'Reenvio')
			//--Verifica se ser� reenviado o valor do ped�gio
			DTR->(DbSetOrder(3))
			If DTR->(DbSeek(FwxFilial('DTR')+DTY->(DTY_FILORI+DTY_VIAGEM+DTY_CODVEI)))
				cOriPdg := AllTrim(DTR->DTR_ORIPDG)
				If cOriPdg <> 'TMSA310'
					nVlrPdg := DTY->DTY_VALPDG
				EndIf
				//--Verifica se ser� reenviado o valor do adiantamento
				If DTR->DTR_TITADI <> '1'
					nVlrAdi := DTY->DTY_ADIFRE
				EndIf
			EndIf
			
			cHistory := AllTrim(RetTitle('DTY_FILORI')) +': ' + DTY->DTY_FILORI  + '/' + AllTrim(RetTitle('DTY_VIAGEM')) + ": " + DTY->DTY_VIAGEM + '/' + Alltrim(RetTitle("DTY_NUMCTC")) + ": " + DTY->DTY_NUMCTC //--'Filial Origem //--Viagem//--'Numero Contrato: '
			//| Inici a Integra��o com Datasul
			CursorWait()
			If lEnvEstor
				MsgRun( "Enviando Dados de Integra��o...",; //--'Enviando Dados de Integra��o...'
				"Integra��o",; //--'Integra��o'
				{|| aEAIRET := TmA250Clas(	DTY->DTY_FILORI , DTY->DTY_VIAGEM 	, DTY->DTY_NUMCTC 	, DTY->DTY_VALFRE 	, DTY->DTY_BASIMP 	, nVlrPdg 			, nVlrAdi 			,;
											nVlrNDF  		, 0			 		, nAliqISS     		, DTY->DTY_CODFOR	, DTY->DTY_LOJFOR 	, cCnpjForn			, DTY->DTY_FILDEB 	,; 
											dDataBase 		, dDataBase 		, cHistory 			, "delete"   		, cEntitName   		, '2' 				, '201'      		,;
											.F.		  		,  .F. 	   			,  .F. 				, .T.				, aImpostos			, DTY->DTY_VLREEM)	 })
								
				If Len(aEAIRET) > 0
					If Len(aEAIRET) > 1
						If aEAIRET[1] == .F.
							Aviso("Aten��o",aEAIRET[2],{"OK"},2)
							lEnvInclus := .F.
						EndIf
					EndIf
				EndIf
		
			EndIf
			If lEnvInclus
				MsgRun( "Enviando Dados de Integra��o...",; //--'Enviando Dados de Integra��o...'
					"Integra��o",; //--'Integra��o'
					{|| aEAIRET := TmA250Clas(	DTY->DTY_FILORI , DTY->DTY_VIAGEM 	, DTY->DTY_NUMCTC 	, DTY->DTY_VALFRE 	, DTY->DTY_BASIMP 	, nVlrPdg 			, nVlrAdi 			,;
												nVlrNDF  		, 0			 		, nAliqISS     		, DTY->DTY_CODFOR	, DTY->DTY_LOJFOR 	, cCnpjForn			, DTY->DTY_FILDEB 	,; 
												dDataBase 		, dDataBase 		, cHistory 			, "upsert"   		, cEntitName   		, '2' 				, '201'      		,;
												.F.		  		,  .F. 	   			,  .F. 				, .F.				, aImpostos			, DTY->DTY_VLREEM)	 })
									
				If Len(aEAIRET) > 0
					If Len(aEAIRET) > 1
						If aEAIRET[1] == .F.
							Aviso("Aten��o",aEAIRET[2],{"OK"},2)
						EndIf
					EndIf
				EndIf
			EndIf
           CursorArrow()
		EndIf							
	Else
		SetRotInteg("TMSAE76")
		aEAIRET := FWINTEGDEF("TMSAE76")		
		lRet := IIf(ValType(aEAIRET) == "U" .Or. Empty(aEAIRET),.F.,aEAIRET[1])
	EndIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � IntegDef � Autor � Valdemar Roberto   � Data � 09/12/2016  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Integra��o via Mensagem �nica                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � IntegDef(cExp01,nExp01,cExp02)                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp01 - Variavel com conteudo xml para envio/recebimento  ���
���          � nExp01 - Tipo de transacao (Envio/Recebimento)             ���
���          � cExp02 - Tipo de mensagem (Business Type, WhoIs, Etc)      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE76                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function IntegDef(cXML,nTypeTrans,cTypeMessage)
Local aRet      := {}
Local aAreas    := {DJR->(GetArea()),SF1->(GetArea()),SD1->(GetArea()),SF3->(GetArea()),GetArea()}
Local cQuery    := ""
Local cAliasDUI := ""
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)

//lCont := .F.

If nTypeTrans == TRANS_RECEIVE
	aRet := TMSIE76(cXML,nTypeTrans,cTypeMessage)
Else
	cEspecie := Alltrim(SF3->F3_ESPECIE)
	
	If !lReenvio
		cCodSEF := AllTrim(SF3->F3_CODRSEF)
	EndIf
	
	//-- Define o tipo de documento (Entrada ou Saida)
	cEntSai := "S"
	SD1->(DbSetOrder(1))
	If SD1->(DbSeek(SF3->F3_FILIAL + SF3->F3_NFISCAL + SF3->F3_SERIE))
		cEntSai := "E"
		If SD1->D1_TIPO == "D" .And. SD1->D1_FORMUL != "S"
			DT6->(DbSetOrder(1))
			If DT6->(DbSeek(xFilial("DT6") + SD1->D1_FILORI + SD1->D1_NFORI + SD1->D1_SERIORI))
				cEspecie := "CTE"
				cCodSEF  := "100"
			EndIf
		EndIf
	EndIf
	
	//-- Define especie quando documento � nota fiscal de servi�o de transporte
	cAliasDUI := GetNextAlias()
	cQuery := "SELECT 1 "	
	cQuery += "  FROM " + RetSqlName("DUI") + " DUI "
	cQuery += " WHERE DUI_FILIAL = '" + FwxFilial("DUI") + "' "
	cQuery += "   AND DUI_DOCTMS IN ('5','D','F','G') "
	cQuery += "   AND DUI_SERIE  = '" + SF3->F3_SERIE + "' "
	cQuery += "   AND DUI.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUI,.T.,.T.)
	If (cAliasDUI)->(!Eof())
		cEspecie := "RPS"
	EndIf
	(cAliasDUI)->(DbCloseArea())
	
	If cEspecie == "CTE"
		If cCodSEF == "100"
			cTipOpe := "Autenticacao"
			cTypeDoc := "CTE"
		ElseIf cCodSEF == "102"
			cTipOpe := "Inutilizacao"
			cTypeDoc := "Cancelamento_CTE"
		ElseIf cCodSEF == "101"
			cTipOpe := "Cancelamento"
			cTypeDoc := "Cancelamento_CTE"
		EndIf
	ElseIf cEspecie == "RPS"
		lCont := .T.
		If cCodSEF == "100"
			cTipOpe  := "Autenticacao"
			cTypeDoc := "NFSE"
		ElseIf cCodSEF == "102"
			cTipOpe  := "Inutilizacao"
			cTypeDoc := "Cancelamento_NFSE"
		ElseIf cCodSEF == "101"
			cTipOpe  := "Cancelamento"
			cTypeDoc := "Cancelamento_NFSE"
		EndIf
	EndIf
	
	If cCodSEF	$ "100:101:102"
	
		lCte      := Iif(FunName() $ "SPEDCTE,TMSA200,TMSAE70,TMSA500,TMSAE77,MATA103",.T.,.F.)
		lUsaColab := UsaColaboracao(Iif(lCte,"2","1"))
		cIdEnt    := GetIdEnt(lUsaColab)
		lCont     := .T.

		cTipEnv   := Iif(lReenvio,"2","1")
		DJR->(DbSetOrder(1))
		If (!lReenvio .And. !DJR->(DbSeek(xFilial("DJR") + "SF3" + "6" + PadR(SF3->(F3_FILIAL + F3_NFISCAL + F3_SERIE),Len(DJR->DJR_CONTEU)) + PadR(cTipOpe,Len(DJR->DJR_CODOPE))))) .Or. ;
			( lReenvio .And.  DJR->(DbSeek(xFilial("DJR") + "SF3" + "6" + PadR(SF3->(F3_FILIAL + F3_NFISCAL + F3_SERIE),Len(DJR->DJR_CONTEU)) + PadR(cTipOpe,Len(DJR->DJR_CODOPE))))) .Or. ;
			( lReenvio .And.  cCodSEF == "100" .And. AllTrim(SF3->F3_CODRSEF) == "101" ) 
			aRet := TMSIE76(cXML,nTypeTrans,cTypeMessage)
		EndIf
	EndIf
EndIf

cEspecie   := ""
cTipOpe    := ""
cTypeDoc   := ""
cIdEnt     := ""
cTipEnv    := ""
cCodSEF    := ""
cAmbiente  := ""
cEntSai    := ""
cVersaoCTe := ""
lCte       := .T.
lUsaColab  := .T.
lReenvReg  := .F.

AEval(aAreas,{|x,y| RestArea(x)})

Return aRet    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE76Sta � Autor � Valdemar Roberto � Data � 10/01/2017  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna vari�veis estaticas                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE76Sta(cExp01)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp01 - Vari�vel que ser� retornada                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE76                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMSAE76Sta(cNomVar)
Local cRet := ""

DEFAULT cNomVar := ""

If !Empty(cNomVar)
	cRet := &(cNomVar)
EndIf

Return cRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GetIdEnt � Autor � Valdemar Roberto   � Data � 27/12/2016  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Busca identificador para busca do XML                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GetIdEnt(lExp01)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lExp01 - Indicada se usa Totvs Colabora��o                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cRet - Identificador                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSIE76                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function GetIdEnt(lUsaColab)
Local aArea      := GetArea()
Local cIdEnt     := ""
Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local lUsaGesEmp := IIF(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)
Local lEnvCodEmp := GetNewPar("MV_ENVCDGE",.F.)
Local oWs

Default lUsaColab := .F.

If !lUsaColab
	//������������������������������������������������������������������������Ŀ
	//�Obtem o codigo da entidade                                              �
	//��������������������������������������������������������������������������
	
	oWS := WsSPEDAdm():New()
	oWS:cUSERTOKEN := "TOTVS"
		
	oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
	oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
	oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   := IIF(lUsaGesEmp,FWFilialName(),Alltrim(SM0->M0_NOME))
	oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
	oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     := Nil
	oWS:oWSEMPRESA:cCP         := Nil
	oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  := ""
	oWS:oWSEMPRESA:cID_MATRIZ  := ""

	If lUsaGesEmp .And. lEnvCodEmp
		oWS:oWSEMPRESA:CIDEMPRESA:= FwGrpCompany()+FwCodFil()
	EndIf

	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
	If oWs:ADMEMPRESAS()
		cIdEnt := oWs:cADMEMPRESASRESULT
	EndIf
	
	FreeObj(oWs)
	oWs := Nil
Else
	If ColCheckUpd()
		cIdEnt := "000000"
	Endif	 
EndIf	

RestArea(aArea)

Return cIdEnt
