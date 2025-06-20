#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TECA850.CH"
#INCLUDE "GCTXDEF.CH"

// Or�amento

#DEFINE O_MARCA				1
#DEFINE O_FILIAL			2
#DEFINE O_LOJA				3
#DEFINE O_CLIENT			4
#DEFINE O_CODORC			5
#DEFINE O_RECOR				6
#DEFINE O_NOMECLI			7
#DEFINE O_GRPRH				8
#DEFINE O_ORCSIM			9
#DEFINE O_REVIS				10
#DEFINE O_DATA				11

//Itens da Proposta e Or�amento
#DEFINE P_MARCA  			1
#DEFINE P_PROPOS 			2
#DEFINE P_REVISA 			3
#DEFINE P_OPORTU 			4
#DEFINE P_CLIENT 			5
#DEFINE P_LOJA   			6
#DEFINE P_NOME   			7
#DEFINE P_DATA   			8
#DEFINE P_TIPO  			9
#DEFINE P_RECOR  			10
#DEFINE P_DESCRI			11

//Itens do browse de base de atendimento
#DEFINE B_MARCA  			1
#DEFINE B_CODPRO			2
#DEFINE B_DESCRI			3
#DEFINE B_NUMSER			4
#DEFINE B_SITE  			5
#DEFINE B_CODFAB 			6
#DEFINE B_LOJFAB 			7

//Itens Funcionarios
#DEFINE P_FILIAL			1
#DEFINE P_MAT				2
#DEFINE P_NOMEFUN			3
#DEFINE P_CARGO			4
#DEFINE P_DESCARG			5
#DEFINE P_FUNCAO			6
#DEFINE P_TURNO			7
#DEFINE P_CC				8
#DEFINE P_DESFUNC			9

//Itens de recursos humanos
#DEFINE ITEMRH_PRODUT	1
#DEFINE ITEMRH_CARGO 	2
#DEFINE ITEMRH_FUNCAO	3
#DEFINE ITEMRH_PERINI	4
#DEFINE ITEMRH_PERFIM	5
#DEFINE ITEMRH_TURNO	6
#DEFINE ITEMRH_QTD		7
#DEFINE ITEMRH_CODTFF	8
#DEFINE ITEMRH_SEQTRN	9
#DEFINE ITEMRH_RECLOC	10
#DEFINE ITEMRH_FILTFF	11
#DEFINE ITEMRH_TFFORIG	12
#DEFINE ITEMRH_QTDHRS	13
#DEFINE ITEMRH_RISCO	14

//Itens do Array ITEMRH_TFFORIG
#DEFINE TFFORIG_FILIAL	01
#DEFINE TFFORIG_COD		02
#DEFINE TFFORIG_CALEND	03
#DEFINE TFFORIG_TURNO	04
#DEFINE TFFORIG_ESCALA  05
#DEFINE TFFORIG_SEQTRN	06
#DEFINE TFFORIG_PERINI	07
#DEFINE TFFORIG_PERFIM  08
#DEFINE TFFORIG_QTDVEN  09	
#DEFINE TFFORIG_CALEND  10		
#DEFINE TFFORIG_TFFCAL 11
#DEFINE TFFORIG_TFFESC 12

Static lTecA870 := .F.	// Determina se o assistente foi chamado a partir do TECA870 ou n�o (Se sim, ent�o � um assistente de altera��o do contrato)
Static lAuto850 := .F.
Static aDadosAuto := {}
Static lTecA745 := .F.  // Determina se o assistente foi chamado a partir do TECA745 ou n�o (Se sim, ent�o � um assistente para or�amento simplficado)
Static cOrcSimp := IIF(HasOrcSimp(),SuperGetMv("MV_ORCSIMP",,"2"),"2")
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA850
Assistente de gera��o ou altera��o do contrato no SIGAGCT, a partir do SIGATEC.
Os par�metros existentes somente estar�o preenchidos quando o assistente for
chamado a partir da rotina de Gest�o de contratos (TECA870).
@param		cTFJCodigo:	C�digo da tabela TFJ referente ao contrato desejado
@param		cTFJContrt:	N�mero do contrato desejado da tabela TFJ
@param		cTFJConRev:	Revis�o do contrato desejado da tabela TFJ
@author	Servi�os
@since		31/10/13
@version	P11 R9
@return	.T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA850(cTFJCodigo, cTFJContrt, cTFJConRev, cTFJPropos, lAuto, aDados,lCtVigente)
Local aOldAlias	:= (Alias())->(GetArea())
Local aSizeDlg	:= FWGetDialogSize(oMainWnd)
Local aPeriodo	:= {STR0001, STR0002, STR0003, STR0004}  //"1 M�s"###"3 Meses"###"6 Meses"###"1 Ano"
Local aCbxSimNao	:= {STR0005, STR0006}//"Sim"###"N�o"
Local aCbxStCtr	:= {STR0107, STR0108}//"Em Elabora��o"###"Vigente"
Local aMeses		:= {1,3,6,12}
Local aProposta	:= {}
Local aOrc			:= {}
Local aBase		:= {}
Local aData		:= {}
Local aBaseAt		:= {}
Local aFuncionar	:= {}
Local nTamTpCont	:= TamSx3("CN9_TPCTO")[1]
Local nTamCnPag	:= TamSx3("E4_CODIGO")[1]
Local nTamTpPl	:= TamSx3("CNL_CODIGO")[1]
Local nTamInd		:= TamSx3("CN6_CODIGO")[1]
Local nTamNrCont	:= TamSx3("TFJ_CONTRT")[1]
Local nTamRvCont	:= TamSx3("TFJ_CONREV")[1]
Local nSaveSx8Len	:= GetSx8Len()
Local nPerCau		:= 0
Local nPanelWz	:= 0
Local nInd			:= 0
Local cLblNrCont	:= Alltrim(RetTitle("CN9_NUMERO"))
Local cNrCont		:= Space(nTamNrCont)
Local cContrRev	:= Space(nTamRvCont)
Local cTpCont		:= Space(nTamTpCont)
Local cCnPag		:= Space(nTamCnPag)
Local cTpPl		:= Space(nTamTpPl)
Local cIndice		:= Space(nTamInd)
Local cPesq1		:= Space(40)
Local cPesq		:= Space(40)
Local cPesq2		:= Space(40)
Local cCbxReajCt	:= ""
Local cCbxReajPl	:= ""
Local cCbxFgCau	:= ""
Local cCbxStCtr	:= ""
Local cPeriodo	:= ""
Local cCliProp	:= ""
Local cLjProp		:= ""
Local cOporProp	:= ""
Local cCodProp	:= ""
Local cRevProp	:= ""
Local cTitWizard	:= ""
Local cCliOrc 	 	:= ""
Local cLjOrc 	 	:= ""
Local cCodOrc 	 	:= ""
Local cRevOrc	 	:= ""
Local cOrcRec 		:= ""
Local cNumOrcSim	:= ""

Local lWhenNrCont	:= GetSx3Cache("CN9_NUMERO","X3_VISUAL") <> "V"
Local lGera		:= .F.
Local lCancel		:= .F.
Local lRet			:= .T.
Local lProcessa		:= .T.

Local dDtIni		:= dDataBase
Local dDtFim		:= CtoD("")
Local dDtAss		:= CtoD("")
Local dDtMaxIni	:= CtoD("")
Local dDtMaxFim	:= CtoD("")

Local oOk			:= LoadBitMap(GetResources(), "LBOK")
Local oNo			:= LoadBitMap(GetResourceS(), "LBNO")
Local oModel 		:= Nil
Local oWizard		:= Nil			// objeto para cria��o do assistente
Local oPanel		:= Nil			// objeto para cria��o do Panel que conter� o Assistente
Local oPesq		:= Nil			// objeto para cria��o da Pesquisa da Proposta Comercial
Local oPesq2		:= Nil			// objeto para cria��o da Pesquisa da Base de Atendimento
Local oLbxProp	:= Nil			// oBjeto para cria��o de um ListBox da Proposta Comercial
Local olbxOrc		:= Nil			// Objeto para cria��o de um ListBox dos or�amentos
Local oLbxBase	:= Nil
Local oLbxFunc	:= Nil
Local lCauc		:= .T.
//Contrato Reccorente
Local cContRec		:= ""
Local nQtdeRec 		:= 0
Local bFinish		:= {|| lGera	:= At850VldTd(cTpCont, cCbxReajCt, cIndice, cCnPag, cTpPl, dDtIni, dDtFim, cNrCont, dDtAss, cCbxStCtr, nQtdeRec,cTFJCodigo)}
Local cSubTit		:= ""
Local aBaseAutm		:= {} // Utilizada para automa��o do assistente da manuten��o
Local lHasOrcSim := HasOrcSimp()
Local lMVGeros := SuperGetMV("MV_GSGEROS",.F.,"1") == "1"
Private aItXPl	:= {}

Default cTFJCodigo	:= ""
Default cTFJContrt	:= ""
Default cTFJConRev	:= ""
Default cTFJPropos	:= ""
Default lAuto       := .F.
Default lCtVigente	:= .F.
Default aDados     := {}


lTecA870	:= IsInCallStack("TECA870")
lAuto850    := lAuto
lTecA745	:= lHasOrcSim .AND. isInCallStack("TECA745")

If lTecA745
	cContRec := TFJ->TFJ_CNTREC
EndIf

If lAuto850
	lGera := .T.
    aDadosAuto := aClone(aDados)
EndIf

If !lHasOrcSim
	lCtVigente := .F.
EndIf

If !lAuto850 .And. lTecA870 .And. !TecAprTrav(xFilial("TFJ"),cTFJCodigo)
	lProcessa	:= .F.
EndIf

If	lTecA870 .OR. (!Empty(cTFJPropos) .AND. lAuto850 ) .OR. lCtVigente 

	DbSelectArea("TFJ")
	DbSetOrder(1) //TFJ_FILIAL+TFJ_CODIGO
	If ( !Empty(cTFJCodigo) .AND. !Empty(cTFJContrt) .AND. Empty(cTFJConRev) .AND. ( cOrcSimp == "1" .Or. ! Empty(cTFJPropos) ) .AND. TFJ->( DbSeek(xFilial("TFJ")+cTFJCodigo)))
		// Somente � permitida a execu��o do assistente de manuten��o para os casos em que o contrato esteja EM ELABORA��O e N�O POSSUA revis�o.

		cNrCont	:= cTFJContrt
		cContrRev	:= cTFJConRev
		cCodProp	:= cTFJPropos

		DbSelectArea("ADY")
		DbSelectArea("CNA")
		DbSelectArea("CN9")
		ADY->( DbSetOrder(1) )	// ADY_FILIAL+ADY_PROPOS
		CNA->( DbSetOrder(1) )	// CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
		CN9->( DbSetOrder(1) )	// CN9_FILIAL+CN9_NUMERO+CN9_REVISA

		If	( CN9->( DbSeek(xFilial("CN9")+cNrCont+cContrRev) ) .AND. (CN9->CN9_SITUAC == DEF_SELAB) )	//01=Cancelado;02=Elaboracao;03=Emitido;04=Aprovacao;05=Vigente;06=Paralisa.;07=Sol. Finalizacao;08=Finalizado;09=Revisao;10=Revisado

			// Inicializa as vari�veis da tela do assistente
			cTpCont		:= CN9->CN9_TPCTO
			cCnPag			:= CN9->CN9_CONDPG

			//Contrato recorrente e em elabora��o
			If (TFJ->TFJ_CNTREC == "1") .AND. (CN9->CN9_SITUAC == '02') .AND. CNA->(DbSeek(xFilial('CNA')+cNrCont+cContrRev) )
				nQtdeRec	:= CNA->CNA_QTDREC
				cContRec	:= TFJ->TFJ_CNTREC
			EndIf

			// Posiciona na planilha associada ao contrato
			If ( CNA->(DbSeek(xFilial("CNA")+cNrCont+cContrRev)) )
				cTpPl		:= CNA->CNA_TIPPLA
			EndIf
			cCbxFgCau		:= If(CN9->CN9_FLGCAU == "1", STR0005, STR0006) 	// "Sim" ## "N�o"
			nPerCau		:= CN9->CN9_MINCAU
			dDtIni			:= CN9->CN9_DTINIC
			dDtFim			:= CN9->CN9_DTFIM
			cCbxStCtr		:= STR0107				// "Em elabora��o"
			dDtAss			:= CN9->CN9_DTASSI

			If !lHasOrcSim .OR. TFJ->TFJ_ORCSIM != '1'
				ADY->(DbSeek(xFilial("ADY")+cCodProp))
				cOporProp		:= ADY->ADY_OPORTU	// Oportunidade
				cRevProp		:= ADY->ADY_PREVIS	// Revisao Proposta
			EndIf

			If !lHasOrcSim
				aData			:= AT850DtInFim(cCodProp, cRevProp)
			Else
				aData			:= AT850DtInFim(cCodProp, cRevProp, cOrcsimp, cTFJCodigo)
			EndIf

			dDtMaxIni		:= StoD(aData[1])
			dDtMaxFim		:= StoD(aData[2])

			aBaseAt		:= {}
			aBase			:= {{.F.,"","","",""}}
			If !Empty(cTFJPropos) .AND. lAuto850
				aAdd(aBaseAutm, aDadosAuto[20])
				aAdd(aBaseAutm, aDadosAuto[21])
				If !lHasOrcSim
					At850Base(cNrCont, "", "", @aBase, aBaseAutm)
				Else
					At850Base(cNrCont, "", "", @aBase,aBaseAutm,,lCtVigente)
				EndIf
			Else
				If !lHasOrcSim
					At850Base(cNrCont, "", "", @aBase)
				Else
					At850Base(cNrCont, "", "", @aBase,,,lCtVigente)
				Endif
			EndIf
			For nInd := 1 to Len(aBase)
				aAdd(aBaseAt, aBase[nInd,B_NUMSER])
			Next nInd

			lWhenNrCont	:= .F.
			ALTERA			:= .T.
			INCLUI			:= .F.
			oModel			:= FWLoadModel("CNTA301")
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
			If	!( oModel:Activate() )
				Help( "", 1, "TECA850", , STR0121, 1, 0)  // "Falha na ativa��o do modelo 'CNTA301'"
				lProcessa	:= .F.
			EndIf

		Else

			Help( "", 1, "TECA850", , STR0122, 1, 0,,,,,,{STR0123})  // "Contrado selecionado n�o est� com o status igual a 'em elabora��o'" ## "Esta opera��o � permitida apenas para contratos 'em elabora��o'"
			lProcessa	:= .F.

		EndIf

	Else

		Help( "", 1, "TECA850", , STR0124, 1, 0,,,,,,{STR0125})  //"N�o foi poss�vel identificar o contrato para o qual se deseja executar o assistente de manuten��o." ## "Selecione um contrato v�lido"
		lProcessa	:= .F.

	EndIf

Else

	DbSelectArea("CN9")
	CN9->( DbSetOrder(1) )	// CN9_FILIAL+CN9_NUMERO+CN9_REVISA
	ALTERA		:= .F.
	INCLUI		:= .T.
	oModel		:= FWLoadModel("CNTA301")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	If	oModel:Activate()
		cNrCont	:= oModel:GetValue("CN9MASTER","CN9_NUMERO")

		// Enquanto identificar que o n�mero j� existe na base faz confirma��o e solicita um novo
		While CN9->( DbSeek(xFilial("CN9")+cNrCont) )
			ConfirmSX8()
			cNrCont	:= CriaVar("CN9_NUMERO", .T.)
		EndDo

		If oModel:GetValue("CN9MASTER","CN9_NUMERO") <> cNrCont
			oModel:GetModel("CN9MASTER"):SetValue("CN9_NUMERO", cNrCont)
		EndIf
	Else
		Help( "", 1, "TECA850", , STR0121, 1, 0)  // "Falha na ativa��o do modelo 'CNTA301'"
		lProcessa	:= .F.
	EndIf

EndIf

If	lProcessa
	//��������������������������������������������������������������Ŀ
	//� mv_par01 - Mostra Lancamentos   S/N                          �
	//� mv_par02 - Aglut Lancamentos    S/N                          �
	//� mv_par03 - Lancamentos Online   S/N                          �
	//����������������������������������������������������������������
    If !lAuto850
		SetKey(VK_F12,{|| Pergunte("CNT100",.T.)})

		cTitWizard		:= If( lTecA870, STR0126, STR0008)	// "Assistente para altera��o de contrato integrado com GCT" ## "Assistente para gera��o de contrato integrado com GCT"
		cSubTit		:= cTitWizard + CRLF + STR0136			// "Necess�rio estar vinculado a um or�amento de servi�os atrav�s de uma proposta comercial"

		oWizard		:= APWizard():New(STR0007 /*<chTitle>*/,;		// "Assistente"
						                  cTitWizard /*<chMsg>*/,;
						                  STR0007 /*<cTitle>*/,;		// "Assistente"
						                  cSubTit /*<cText>*/,;
						                  {|| .T.} /*<bNext>*/,;
						                  {|| .T.} /*<bFinish>*/,;
					    	              .T. /*<lPanel>*/,;
					       	           /*<cResHead>*/,;
					           	       /*<bExecute>*/,;
					              	    .T. /*<lNoFirst>*/,;
					                  	{aSizeDlg[1], aSizeDlg[2], aSizeDlg[3]-50, aSizeDlg[4]-12} /*<aCoord>*/)

		nPanelWz		:= 1

		If	! lTecA870 .AND. ! lCtVigente

			aFuncionar		:= At850Func()
			aProposta		:= At850Prop(aMeses[1])		//Carrega informa��es da proposta comercial

			If lHasOrcSim
				aOrc			:= At850Orc(aMeses[1])		//Carrega as informa��es do Orc. Simpl.
			EndIf

			If !lHasOrcSim .OR. (!lTecA745 .AND. cOrcSimp == "2") // Caso o campo do par�metro de or�amento simplificado tenha o valor 2, o painel para sele��o de propostas n�o ser� criado
				oWizard:NewPanel(STR0009 /*<cTitle>*/,;	// "Proposta Comercial"
				                 STR0010 /*<cMsg>*/,;		// "Selecione a Proposta Comercial para Gera��o de Contrato no GCT"
				                 {|| .T.} /*<bBack>*/,;
				                 {|| At850VldPr(oLbxProp)} /*<bNext>*/,;
				                 {|| .T.} /*<bFinish>*/,;
				                 .T. /*<lPanel>*/,;
				                 {|| .T.} /*<bExecute>*/)
			ElseIf !lTecA745
				oWizard:NewPanel(STR0174 /*<cTitle>*/,;		// "Or�amentos"
				                 STR0175 /*<cMsg>*/,;		// Selecione o or�amento para a gera��od o contrato no GCT
				                 {|| .T.} /*<bBack>*/,;
				                 {|| At850VldPr(oLbxOrc,@cTFJCodigo)} /*<bNext>*/,;
				                 {|| .T.} /*<bFinish>*/,;
				                 .T. /*<lPanel>*/,;
				                 {|| .T.} /*<bExecute>*/)
			EndIf
			If lMVGeros
				If !lHasOrcSim
					oWizard:NewPanel(STR0011 /*<cTitle>*/,;	// "Base de Atendimento"
									STR0012 /*<cMsg>*/,;		// "Selecione a Base de Atendimento"
									{|| .T.} /*<bBack>*/,;
									{|| At850VldBa(oLbxBase)} /*<bNext>*/,;
									{|| .T.} /*<bFinish>*/,;
									.T. /*<lPanel>*/,;
									{|| At850Base("", oLbxProp, oLbxBase, @aBase)} /*<bExecute>*/)
				Else
					oWizard:NewPanel(STR0011 /*<cTitle>*/,;	// "Base de Atendimento"
									STR0012 /*<cMsg>*/,;		// "Selecione a Base de Atendimento"
									{|| .T.} /*<bBack>*/,;
									{|| At850VldBa(oLbxBase)} /*<bNext>*/,;
									{|| .T.} /*<bFinish>*/,;
									.T. /*<lPanel>*/,;
									{|| At850Base("", oLbxProp, oLbxBase, @aBase,,oLbxOrc)} /*<bExecute>*/)
				EndIf
			EndIf
			If !lHasOrcSim .OR. (!lTecA745 .AND. cOrcSimp <> '1') // Caso o campo do par�metro de or�amento simplificado tenha o valor 2, o painel de atendentes  n�o ser� criado e o panel da proposta comercial n�o ser� exibido
				oWizard:NewPanel(STR0095 /*<cTitle>*/,;	// "Funcion�rios que n�o s�o Atendentes"
				                 STR0096 /*<cMsg>*/,;		// "Cadastre os novos funcion�rios como Atendentes para que sejam alocados"
				                 {|| .T.} /*<bBack>*/,;
				                 {|| .T.} /*<bNext>*/,;
				                 {|| .T.} /*<bFinish>*/,;
				                 .T. /*<lPanel>*/,;
				                 {|| .T.} /*<bExecute>*/)

					oPanel			:= oWizard:GetPanel( ++ nPanelWz )
					@ 001,005 SAY STR0009 OF oPanel PIXEL SIZE 100,9 //"Proposta Comercial"
					@ 010,007 MsGet oPesq VAR cPesq OF oPanel SIZE 105,10 PIXEL
					@ 010,115 BUTTON STR0015 SIZE 30,12 OF oPanel PIXEL Action(Tk040Busca(@oLbxProp, cPesq, @oPesq, .T.)) //"Pequisar"
					@ 010,150 BUTTON STR0016 SIZE 30,12 OF oPanel PIXEL Action(Tk040Busca(@oLbxProp, cPesq, @oPesq, .F.)) //"Proximo"
					@ 010,185 SAY STR0017 OF oPanel PIXEL SIZE 90,9 //"Proposta do(s) �ltimo(s)"
					@ 010,258 COMBOBOX oPeriodo VAR cPeriodo ITEMS aPeriodo OF oPanel SIZE 40,10 PIXEL;
													ON CHANGE (	aProposta			:= At850Prop(aMeses[oPeriodo:nAt]),;
																	oLbxProp:SetArray(aProposta),;
																	oLbxProp:bLine	:= {||	{ If(aProposta[oLbxProp:nAt,P_MARCA], oOk, oNo),;
																								     aProposta[oLbxProp:nAt,P_PROPOS],;
																								     aProposta[oLbxProp:nAt,P_REVISA],;
																								     aProposta[oLbxProp:nAt,P_OPORTU],;
																								     aProposta[oLbxProp:nAt,P_DATA],;
																								     X3Combo("ADY_TPCONT",aProposta[oLbxProp:nAt,P_TIPO]),;
																								     aProposta[oLbxProp:nAt,P_DESCRI],;
																								     aProposta[oLbxProp:nAt,P_NOME],;
																								     aProposta[oLbxProp:nAt,P_CLIENT]}},;
																	oLbxProp:Refresh()	)
					@ 025,007 LISTBOX oLbxProp FIELDS HEADER	"",;
																	STR0018,;		//"Numero da Proposta"
																	STR0019,;		//"Revis�o"
																	STR0020,;		//"Oportunidade"
																	STR0024,;		//"Emiss�o"
																	STR0025,;		//"Tipo"
																	STR0182,;		//"Descri��o"
																	STR0183,; 		//"Nome do Cliente"
																	STR0184,; 		//"Codigo do Cliente"
																	SIZE	(oPanel:nWidth/2)-20,;
																			(((oPanel:nHeight/2)*0.90)-20) OF oPanel PIXEL;
																			ON dblClick(aEval(aProposta,;
																			  					{|x| x[P_MARCA]						:= .F.}),;
																			  					aProposta[oLbxProp:nAt,P_MARCA]		:= .T.,;
																			  					cCliProp							:= aProposta[oLbxProp:nAt,P_CLIENT],;
																			  					cLjProp								:= aProposta[oLbxProp:nAt,P_LOJA],;
																			  					cOporProp							:= aProposta[oLbxProp:nAt,P_OPORTU],;
																								cCodProp							:= aProposta[oLbxProp:nAt,P_PROPOS],;
																								cRevProp							:= aProposta[oLbxProp:nAt,P_REVISA],;
																								aData								:= AT850DtInFim(cCodProp,cRevProp),;
																								cCnPag								:= aData[3],;
																								dDtIni								:= CTOD(DTOC(STOD(aData[1]))),;
																								dDtFim								:= CTOD(DTOC(STOD(aData[2]))),;
																								dDtMaxIni							:= (STOD(aData[1])),;
																								dDtMaxFim							:= (STOD(aData[2])),;
																								cContRec							:= aProposta[oLbxProp:nAt,P_RECOR],;
																								cTFJCodigo							:= Posicione("TFJ",2,xFilial("TFJ")+aProposta[oLbxProp:nAt,P_PROPOS]+aProposta[oLbxProp:nAt,P_REVISA],"TFJ_CODIGO"),;
																								oLbxProp:Refresh())

					oLbxProp:SetArray(aProposta)
					oLbxProp:bLine	:= {|| {If( aProposta[oLbxProp:nAt,P_MARCA],oOk,oNo),;
												     aProposta[oLbxProp:nAt,P_PROPOS],;
												     aProposta[oLbxProp:nAt,P_REVISA],;
												     aProposta[oLbxProp:nAt,P_OPORTU],;
												     aProposta[oLbxProp:nAt,P_DATA],;
											     X3Combo("ADY_TPCONT",aProposta[oLbxProp:nAt,P_TIPO]),;
											     aProposta[oLbxProp:nAt,P_DESCRI],;
											     aProposta[oLbxProp:nAt,P_NOME],;
											     aProposta[oLbxProp:nAt,P_CLIENT]}}
			ElseIf !lTecA745 // Painel para sele��o dos or�amenos
				/* Painel de or�amentos */
					oPanel			:= oWizard:GetPanel( ++ nPanelWz )
						@ 001,005 SAY "Or�amentos" OF oPanel PIXEL SIZE 100,9 //"Or�amento"
						@ 010,185 SAY STR0017 OF oPanel PIXEL SIZE 90,9 //"Proposta do(s) �ltimo(s)"
						@ 010,258 COMBOBOX oPeriodo VAR cPeriodo ITEMS aPeriodo OF oPanel SIZE 40,10 PIXEL;
														ON CHANGE (	aOrc := At850Orc(aMeses[oPeriodo:nAt]),;
																					    oLbxOrc:SetArray(aOrc),;
																						oLbxOrc:bLine	:= {|| {If( aOrc[oLbxOrc:nAt,O_MARCA],oOk,oNo),;
																														 aOrc[oLbxOrc:nAt, O_DATA],;
																													     aOrc[oLbxOrc:nAt, O_FILIAL],;
																													     aOrc[oLbxOrc:nAt, O_NOMECLI],;
																													     aOrc[oLbxOrc:nAt, O_CODORC],;
																													     aOrc[oLbxOrc:nAt, O_REVIS],;
																													     aOrc[oLbxOrc:nAt, O_GRPRH],}},;
																		oLbxOrc:Refresh())

						@ 025,007 LISTBOX oLbxOrc FIELDS HEADER	"",;
																		"Data do Or�amento",;
																		"Filial",;
																		"Nome do Cliente",;
																		"Numero do Or�amento",;
																		"Revis�o",;
																		"Grupo RH",;
																		SIZE	(oPanel:nWidth/2)-20,;
																				(((oPanel:nHeight/2)*0.90)-20) OF oPanel PIXEL;
																				ON dblClick(aEval(aOrc,;
																				  					{|x| x[1]						:= .F.}),;
																				  					aOrc[oLbxOrc:nAt,O_MARCA]		:= .T.,;
																				  					cCliOrc								:= aOrc[oLbxOrc:nAt,O_CLIENT],;
																				  					cLjOrc								:= aOrc[oLbxOrc:nAt,O_LOJA],;
																									cCodOrc								:= aOrc[oLbxOrc:nAt,O_CODORC],;
																									aData								:= AT850defdt(oLbxOrc),;
																									cCnPag								:= aData[3],;
																									dDtIni								:= CTOD(DTOC(STOD(aData[1]))),;
																									dDtFim								:= CTOD(DTOC(STOD(aData[2]))),;
																									dDtMaxIni							:= (STOD(aData[1])),;
																									dDtMaxFim							:= (STOD(aData[2])),;
																									cRevOrc								:= aOrc[oLbxOrc:nAt,O_REVIS],;
																									cOrcRec								:= aOrc[oLbxOrc:nAt, O_RECOR],;
																									cContRec							:= aOrc[oLbxOrc:nAt, 6],;
																									cTFJCodigo 							:= aOrc[oLbxOrc:nAt, 5],;
																									oLbxOrc:Refresh())

						oLbxOrc:SetArray(aOrc)
						oLbxOrc:bLine	:= {|| {If( aOrc[oLbxOrc:nAt,O_MARCA],oOk,oNo),;
														 aOrc[oLbxOrc:nAt, O_DATA],;
													     aOrc[oLbxOrc:nAt, O_FILIAL],;
													     aOrc[oLbxOrc:nAt, O_NOMECLI],;
													     aOrc[oLbxOrc:nAt, O_CODORC],;
													     aOrc[oLbxOrc:nAt, O_REVIS],;
													     aOrc[oLbxOrc:nAt, O_GRPRH],}}
			EndIf
			If lMVGeros
				oPanel			:= oWizard:GetPanel( ++ nPanelWz )	//Base de Atendimento
				aBase			:= {{.F.,"","","",""}}
				@ 001,005 SAY STR0011 OF oPanel PIXEL SIZE 120,9 //Base de Atendimento
				@ 010,007 MsGet oPesq2 VAR cPesq2 OF oPanel SIZE 105,10 PIXEL
				@ 010,115 BUTTON STR0015	SIZE 30,12 OF oPanel PIXEL Action(Tk040Busca(@oLbxBase, cPesq2, @oPesq2, .T.))	//"Pesquisar"
				@ 010,150 BUTTON STR0016	SIZE 30,12 OF oPanel PIXEL Action(Tk040Busca(@oLbxBase, cPesq2, @oPesq2, .F.))	//"Pr�ximo"
				If !lHasOrcSim
					@ 010,185 BUTTON STR0026	SIZE 30,12 OF oPanel PIXEL Action(IIF(At850Suges(oLbxProp, aProposta, @oLbxBase, @aBase), At850Base("", oLbxProp, @oLbxBase, @aBase), Nil)) //"Sugest�o"
					@ 010,247 BUTTON STR0027	SIZE 50,12 OF oPanel PIXEL Action(IIF(At850IncBA()==1, At850Base("", oLbxProp, oLbxBase, @aBase), Nil)) //"Incluir nova"
				Else
					@ 010,185 BUTTON STR0026	SIZE 30,12 OF oPanel PIXEL Action(IIF(At850Suges(oLbxProp, aProposta, @oLbxBase, @aBase,,,,oLbxOrc,lCtVigente), At850Base("", oLbxProp, @oLbxBase, @aBase, ,oLbxOrc), Nil)) //"Sugest�o"
					@ 010,247 BUTTON STR0027	SIZE 50,12 OF oPanel PIXEL Action(IIF(At850IncBA()==1, At850Base("", oLbxProp, oLbxBase, @aBase, ,oLbxOrc), Nil)) //"Incluir nova"
				EndIf
				@ 025,007 LISTBOX oLbxBase FIELDS HEADER	"",;
																STR0028,;	//"Produto"
																STR0029,;	//"Descri��o"
																STR0030,;	//"Identificador"
																STR0031,;	//"Site"
																SIZE	(oPanel:nWidth/2)-20,;
																		((oPanel:nHeight/2)*0.90)-20 OF oPanel PIXEL;
																		ON dblClick(aBase[oLbxBase:nAt,B_MARCA]	:= !aBase[oLbxBase:nAt,B_MARCA],;
																					Aadd(aBaseAt, aBase[oLbxBase:nAt,B_NUMSER]),;
																					oLbxBase:Refresh())

				oLbxBase:SetArray(aBase)
				oLbxBase:bLine	:= {|| {If(aBase[oLbxBase:nAt,B_MARCA], oOk, oNo),;
											aBase[oLbxBase:nAt,B_CODPRO],;
											aBase[oLbxBase:nAt,B_DESCRI],;
											aBase[oLbxBase:nAt,B_NUMSER],;
											aBase[oLbxBase:nAt,B_SITE]}}
				oLbxBase:Refresh()
			EndIf	
			If !lHasOrcSim .OR. (!lTecA745 .AND. cOrcSimp == "2")
				oPanel			:= oWizard:GetPanel( ++ nPanelWz ) //Informa��es referente a funcion�rios que n�o tem atendentes relacionados.

				@ 001, 005 SAY STR0097 OF oPanel PIXEL SIZE 220,9 //"Funcion�rios sem relacionamento com Atendentes:"
				@ 010, 007 MsGet oPesq1 VAR cPesq1 OF oPanel SIZE 105,10 F3 "CTT" PIXEL
				@ 010, 115 BUTTON STR0015 SIZE 30,12 OF oPanel PIXEL ACTION (At850AtFnc(aFuncionar, oLbxFunc, cPesq1)) //"Pesquisar"
				@ 010, 150 BUTTON STR0098 SIZE 70,12 OF oPanel PIXEL ACTION (At850GFunc(aFuncionar), At850AtFnc(aFuncionar, oLbxFunc, cPesq1)) //""
				@ 010, 225 BUTTON STR0099 SIZE 45,12 OF oPanel PIXEL ACTION (At850CaAtd( , 3, "INCLUIR"), At850AtFnc(aFuncionar, oLbxFunc, cPesq1)) //"Cad. Atendente"*/
				@ 025, 007 LISTBOX oLbxFunc FIELDS	HEADER	STR0100,; //"Matricula"
																STR0101,; //"Nome"
																STR0102,; //"Cargo"
																STR0103,; //"Desc. Cargo"
																STR0104,; //"Fun��o"
																STR0105,; //"Desc. Fun��o"
																SIZE (oPanel:nWidth/2)-20,;
																     (((oPanel:nHeight/2)*0.9)-20) of oPanel PIXEL;
																     // Popula o listbox de acordo com os valores atribuidos a variavel "afuncionar" pela function At350Func().
																     oLbxFunc:SetArray(aFuncionar)
																     oLbxFunc:bLine	:= {|| {aFuncionar[oLbxFunc:nAt,P_MAT],;
																                             aFuncionar[oLbxFunc:nAt,P_NOMEFUN],;
																                             aFuncionar[oLbxFunc:nAt,P_CARGO],;
																                             aFuncionar[oLbxFunc:nAt,P_DESCARG],;
											 					                             aFuncionar[oLbxFunc:nAt,P_FUNCAO],;
																                             aFuncionar[oLbxFunc:nAt,P_DESFUNC]}}
			EndIf

		EndIf

		oWizard:NewPanel(STR0013 /*<cTitle>*/,;	// "Informa��es para o Contrato"
		                 STR0014 /*<cMsg>*/,;	// "Informe os detalhes para gera��o do contrato."
		                 {|| .T.} /*<bBack>*/,;
		                 {|| .T.} /*<bNext>*/,;
		                 bFinish /*<bFinish>*/,;
		                 .F. /*<lPanel>*/,; 	//Desabilitar Scroll (rolamento)
		                 {|| .T.} /*<bExecute>*/)

		oPanel:= oWizard:GetPanel( ++ nPanelWz ) //Informa��es do Contrato

		If lHasOrcSim .AND. lTecA745 .AND. !lCtVigente
			aData		:= AT850defdt()
			dDtIni		:= CTOD(DTOC(STOD(aData[1])))
			dDtFim		:= CTOD(DTOC(STOD(aData[2])))
			dDtMaxIni	:= (STOD(aData[1]))
			dDtMaxFim	:= (STOD(aData[2]))
			cCnPag		:= aData[3]
		EndIf

		//N�mero do Contrato
		@ 010,010 SAY cLblNrCont + "*"	OF oPanel SIZE 200,009 PIXEL
		@ 010,230 MsGet	cNrCont ;
							VALID VldNrCont(cNrCont) ;
							WHEN lWhenNrCont ;
							OF oPanel SIZE 080,010 PIXEL

		//Tipo de Contrato
		@ 025,010 SAY STR0032	OF oPanel SIZE 200,009 PIXEL	// "Tipo de contrato*"
		@ 025,230 MsGet	cTpCont ;
							F3 "CN1" ;
							VALID	Vazio(cTpCont) .OR.;
									( ExistCpo("CN1",cTpCont,1) .AND. At850TpCt(cTpCont) ) ;
							OF oPanel SIZE 030,010 PIXEL

		//Condi��o de Pagamento
		@ 040,010 SAY STR0033	OF oPanel SIZE 200,009 PIXEL	// "Condi��o de pagamento*"
		@ 040,230 MsGet	cCnPag ;
							F3 "SE4" ;
							VALID ( Vazio(cCnPag) .OR. ExistCpo("SE4",cCnPag,1) ) ;
							OF oPanel SIZE 030,010 PIXEL

		//Tipo de Planilha
		@ 055,010 SAY STR0036	OF oPanel SIZE 200,009 PIXEL	// "Tipo de planilha*"
		@ 055,230 MsGet	cTpPl ;
							F3 "CNL" ;
							VALID ( Vazio(cTpPl) .OR. ( ExistCpo("CNL",cTpPl,1) .AND. At850TpPl(cTpPl,cContRec)) ) ;
							OF oPanel SIZE 030,010 PIXEL

		//Reajuste da cau��o
		@ 070,010 SAY STR0038	OF oPanel SIZE 200,009 PIXEL	// "Cau��o*"
		@ 070,230 Combobox oCbxFgCau ;
							VAR cCbxFgCau ;
							ITEMS aCbxSimNao ;
							VALID IIf(cCbxFgCau == "N�o", Eval({|| nPerCau := 0, lCauc := .F. ,.T.}), Eval({|| lCauc := .T., .T.})) ;
							OF oPanel SIZE 030,010 PIXEL

		//Percentual do Cau��o
		@ 085,010 SAY STR0074	OF oPanel SIZE 200,009 PIXEL	// "Percentual Cau��o*"
		@ 085,230 MsGet	nPerCau ;
							PICTURE "@R 99.99" ;
							WHEN lCauc;
							VALID If(	cCbxFgCau == "Sim",;	// "Sim"
										Eval({|| nPerCau > 0 .AND. nPerCau <= 100}),;
										Eval({|| nPerCau == 0})) ;
							OF oPanel SIZE 050,010 PIXEL

		//Data Inicial
		@ 100,010 SAY STR0039	OF oPanel SIZE 200,009 PIXEL	// "Data Inicial do contrato*"
		@ 100,230 MsGet	dDtIni ;
							VALID !( Empty(dDtIni) ) .and.( Eval({||at850ValDt(dDtIni,dDtMaxIni)}) ) ;
							OF oPanel SIZE 050,010 PIXEL

		//Data Final
		@ 115,010 SAY STR0040	OF oPanel SIZE 200,009 PIXEL	// "Data Final do contrato*"
		@ 115,230 MsGet	dDtFim ;
							WHEN !(cContRec == "1") ;	// "Contrato Reccorente"
							VALID ( !Empty(dDtFim)) .AND. (dDtFim > dDtIni) .and. ( Eval({||at850ValDt(dDtFim,dDtMaxFim,'FIM')}) ) ;
							OF oPanel SIZE 050,010 PIXEL

		//Status Contrato
		@ 130,010 SAY STR0109	OF oPanel SIZE 200,009 PIXEL	// "Status do contrato*"
		@ 130,230 Combobox oCbxStCtr ;
							VAR cCbxStCtr ;
							ITEMS aCbxStCtr ;
							WHEN At850WhOp(cTFJCodigo);
							VALID If(	cCbxStCtr == STR0107,;	// "Em elabora��o"
										Eval({|| dDtAss := CtoD(Space(08))}),;
										Eval({|| .T.})) ;
							OF oPanel SIZE 055,010 PIXEL

		//Data Assinatura do Contrato
		@ 145,010 SAY STR0117	OF oPanel SIZE 200,009 PIXEL	// "Data Assinatura do Contrato"
		@ 145,230 MsGet	dDtAss ;
							WHEN cCbxStCtr == STR0108 ;	// "Vigente"
							OF oPanel SIZE 050,010 PIXEL

		//Quantidade de Recorrencia
		@ 160,010 SAY STR0169	OF oPanel SIZE 200,009 PIXEL// "Quantidade de Recorr�ncia"
		@ 160,230 MsGet	nQtdeRec ;
							WHEN cContRec == "1" ;	// "Contrato Reccorente (1-Sim/2-N�o)"
							VALID (nQtdeRec >= 1) .And. ( Eval({||CN300VlRec(,,nQtdeRec)}));
							OF oPanel SIZE 050,010 PIXEL PICTURE PesqPict("CNA","CNA_QTDREC")
		

		oWizard:Activate(	.T. /*<lCenter>*/,;
						{|| ( lGera .OR. (lCancel := MsgYesNo(STR0041)) )} /*<bValid>*/,;	// "Tem certeza que deseja cancelar o Assistente?"
						{|| .T.} /*<bInit>*/,;
						{|| .T.} /*<bWhen>*/)
    Else

	    cTpCont := aDadosAuto[1]
	    cCnPag := aDadosAuto[2]
	    cCbxReajCt := aDadosAuto[3]
	    cIndice := aDadosAuto[4]
	    cTpPl := aDadosAuto[5]
	    cCbxReajPl := aDadosAuto[6]
	    cCodProp := aDadosAuto[7]
	    cRevProp := aDadosAuto[8]
	    dDtIni := aDadosAuto[9]
	    dDtFim := aDadosAuto[10]
	    cCbxFgCau := aDadosAuto[11]
	    aBaseAt := aDadosAuto[12]
	    nPerCau := aDadosAuto[13]
	    cCbxStCtr := aDadosAuto[14]
	    dDtAss := aDadosAuto[15]
	    nQtdeRec := aDadosAuto[18]

	    If Len(aDadosAuto) > 19
	    	cNumOrcSim	:= aDadosAuto[20]
	    Else
	    	cNumOrcSim	:= ""
	    EndIf

	    If !lHasOrcSim
		    cContRec := At850IsRecr(cCodProp,cRevProp)

		    aData := AT850DtInFim(cCodProp, cRevProp)

		    lRet := at850ValDt(dDtIni,STOD(aData[1]))
		    lRet := lRet .And. at850ValDt(dDtFim,STOD(aData[2]),'FIM')
		    lRet := lRet .And. At850TpPl(cTpPl,cContRec)

		    lRet := lRet .And. At850VldTd(cTpCont, cCbxReajCt, cIndice, cCnPag, cTpPl, dDtIni, dDtFim, cNrCont, dDtAss, cCbxStCtr, nQtdeRec)
        Else
	        cContRec 		:= At850IsRecr(cCodProp,cRevProp, cOrcsimp, cNumOrcSim)		// Verifica se � contrato recorrente.
		    aData			:= AT850DtInFim(cCodProp, cRevProp, cOrcsimp, cNumOrcSim)	//Verifica datas dos locais - TFL
		    lRet 			:= at850ValDt(dDtIni,STOD(aData[2]), 'INI')					// Valida data inicial do contrato
		    lRet 			:= lRet .And. at850ValDt(dDtFim,STOD(aData[2]),'FIM') 		// Valida data final do contrato
		    lRet 			:= lRet .And. At850TpPl(cTpPl,cContRec) 					//Verifica tipo de planilha
		    lRet			:= lRet .And. At850VldTd(cTpCont, cCbxReajCt, cIndice, cCnPag, cTpPl, dDtIni, dDtFim, cNrCont, dDtAss, cCbxStCtr, nQtdeRec) //Valida��es das informa��es do contrato e planilha
        EndIf
     EndIf

	If lHasOrcSim
	    cContRec 		:= At850IsRecr(cCodProp,cRevProp, cOrcsimp, cTFJCodigo)		// Verifica se � contrato recorrente.
	    aData			:= AT850DtInFim(cCodProp, cRevProp, cOrcsimp, cTFJCodigo)	//Verifica datas dos locais - TFL
	Else
	    cContRec := At850IsRecr(cCodProp,cRevProp)
	    aData := AT850DtInFim(cCodProp, cRevProp)
    EndIf

    If lRet .And. lGera .AND. !lCancel
    	dData := At850AtDat(cOporProp, dDtIni, dDtFim) //Captura data ini e final do contrato

    	If !lHasOrcSim
			lRet	:= At850ExcAt(	cTpCont,;										// Tipo do contrato
										cCnPag,;										// Condi��o de Pagamento
										cCbxReajCt,;									// Determina se o contrato tem Reajuste.
										cIndice,;										// Indice do reajuste
	                                    dData,;											 // Datas, com destaque para data de vig�ncia
										cTpPl,;										// Tipo da planilha
										cCbxReajPl,;									// Determina se planilha tem Reajuste.
										cCodProp,;										// Proposta Comercial
										cRevProp,;										// Revis�o da proposta
										dDtIni,;										// Data Inicial do Contrato
										dDtFim,;										// Data Final do Contrato
										cCbxFgCau,;									// Determina se cau��o tem Reajuste.
										aBaseAt,;										// Bases de atendimento
										nPerCau,;										// Percentual de cau��o
										cCbxStCtr,;									// Situa��o do contrato
										cNrCont,;										// N�mero do contrato
										dDtAss,;										// Data da Assinatura do Contrato
										oModel,;										// Modelo de dados do contrato (TECA301)
	                               	    nQtdeRec )                                                                                                                                                       // Quantidade de Recorrencia
		Else
			lRet	:= At850ExcAt(	cTpCont,;										// Tipo do contrato
										cCnPag,;										// Condi��o de Pagamento
										cCbxReajCt,;									// Determina se o contrato tem Reajuste.
										cIndice,;										// Indice do reajuste
	                                    dData,;											 // Datas, com destaque para data de vig�ncia
										cTpPl,;										// Tipo da planilha
										cCbxReajPl,;									// Determina se planilha tem Reajuste.
										cCodProp,;										// Proposta Comercial
										cRevProp,;										// Revis�o da proposta
										dDtIni,;										// Data Inicial do Contrato
										dDtFim,;										// Data Final do Contrato
										cCbxFgCau,;									// Determina se cau��o tem Reajuste.
										aBaseAt,;										// Bases de atendimento
										nPerCau,;										// Percentual de cau��o
										cCbxStCtr,;									// Situa��o do contrato
										cNrCont,;										// N�mero do contrato
										dDtAss,;										// Data da Assinatura do Contrato
										oModel,;										// Modelo de dados do contrato (TECA301)
	                               	    nQtdeRec,;										//Qtd de recorrencias
	                                    lAuto850,;										// Autom�tico?
	                                    IIF( !EMPTY(cNumOrcSim), cNumOrcSim, cCodOrc ),;	// C�digo do Or�amento
	                                    lCtVigente )
		EndIf

		If	lRet
			If	! lTecA870 .AND. !lCtVigente
				While GetSx8Len() > nSaveSx8Len
					CN9->( ConfirmSX8())
					DbSkip()
				EndDo
			EndIf
			//�������������������������������������������������������������������������Ŀ
			//�SIGATEC WorkFlow # "GC - Gera��o do Contrato no Assistente de Contratos  �
			//���������������������������������������������������������������������������
			If !Empty(TFJ->TFJ_GRPCOM)
				At774Mail("TFJ",TFJ->TFJ_GRPCOM,"GC","<b>"+STR0119+"</b> "+TFJ->TFJ_PROPOS+"<b> "+STR0120+"</b>"+TFJ->TFJ_CONTRT) //"Num.Proposta: " # "Nr. Contrato: "
			Endif
			If !lAuto850
				MsgInfo(STR0127)  // "Assistente de contratos processado!"
			EndIf
		Else
			If !lAuto850
				MsgAlert(STR0133, STR0043)  // "Ocorreu uma inconsist�ncia no momento da efetiva��o do assistente de contratos." ### "Aten��o"
			EndIf
     	EndIf
	Else

		If	! lTecA870 .AND. !lCtVigente
			While GetSx8Len() > nSaveSx8Len
				CN9->(RollBackSX8())
				DbSkip()
			EndDo
			FreeUsedCode()  //libera codigos reservados pela MayIUseCode()
		EndIf
		MsgAlert(STR0128, STR0043)  // "Assistente de contratos n�o processado ou cancelado pelo usu�rio!" ### "Aten��o"
	EndIf
EndIf
RestArea(aOldAlias)
Return (.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldNrCont

Valid n�mero do contrato
@author Servi�os
@since 17/09/14
@version P12
@param cNrCont: N�mero do contrato a ser validado
@return  lRet -> .T., Validou, .F. -> N�o validou
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function VldNrCont(cNrCont)

Local lRet	:= ExistChav("CN9",cNrCont)

//verifica se esta na memoria, sendo usado busca o proximo numero disponivel
If lRet .And. !MayIUseCode("CN9_NUMERO"+xFilial("CN9")+cNrCont)
	Aviso(STR0111,STR0112, {STR0055}, 2) //"Nr. Contrato"###"O contrato j� existe"###"OK"
	lRet := .F.
EndIf
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850Prop

Carrega propostas comerciais que sejam do tipo Integra��o com GCT
@author Servi�os
@since 31/10/13
@version P11 R9
@param nQtdMeses: Quantidade de meses para pesquisa
@return  .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At850Prop(nQtdMeses)
Local aArea			:= GetArea()
Local dCorte		:= dDataBase - (nQtdMeses * 30)
Local cAliasAD1		:= GetNextAlias()
Local cFilAD1		:= xFilial("AD1")
Local cFilADY		:= xFilial("ADY")
Local cQuery		:= ""
Local aProp			:= {}
Local cNome 		:= ""

DbSelectArea("ADY")
DbSetOrder(1) //ADY_FILIAL+ADY_PROPOS

cQuery :=	"SELECT AD1_FILIAL, AD1_DATA, AD1_STATUS, AD1_PROPOS, AD1_REVISA, AD1_CODCLI, AD1_LOJCLI, AD1_DESCRI, TFJ_CNTREC "
cQuery +=   "FROM " + RetSqlName("AD1") + " AD1 "
cQuery	+=         "INNER JOIN " + RetSqlName("ADY") + " ADY "
cQuery +=                       "ON ADY.ADY_FILIAL = AD1.AD1_FILIAL "
cQuery +=                      "AND ADY.D_E_L_E_T_ = '' "
cQuery	+=                      "AND ADY.ADY_PROPOS = AD1.AD1_PROPOS "
cQuery	+=                      "AND ADY.ADY_REVISA = AD1.AD1_REVISA "
cQuery +=         "INNER JOIN " + RetSqlName("TFJ") + " TFJ "
cQuery +=                       "ON TFJ.TFJ_FILIAL = ADY.ADY_FILIAL "
cQuery +=                      "AND TFJ.D_E_L_E_T_ = '' "
cQuery	+=                      "AND TFJ.TFJ_PROPOS = ADY.ADY_PROPOS "
cQuery	+=                      "AND TFJ.TFJ_PREVIS = ADY.ADY_PREVIS "
cQuery +=  "WHERE AD1.AD1_FILIAL = '" + cFilAD1 + "' "
cQuery +=    "AND AD1.D_E_L_E_T_ = '' "
cQuery +=    "AND AD1.AD1_DATA >= '" + DtoS(dCorte) + "' "
cQuery +=    "AND AD1.AD1_DATA <= '" + DtoS(dDataBase) + "' "
cQuery +=    "AND AD1.AD1_STATUS = '9' "
cQuery +=    "AND AD1.AD1_PROPOS <> ' ' "
cQuery +=    "AND TFJ.TFJ_CONTRT = ' ' "
cQuery +=  "ORDER BY AD1.AD1_FILIAL, AD1.AD1_DATA, AD1.AD1_NROPOR, AD1.AD1_REVISA "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAD1,.T.,.T.)
TCSetField(cAliasAD1,"AD1_DATA","D")

While (cAliasAD1)->(! Eof())
	If ADY->(DbSeek(cFilADY + (cAliasAD1)->AD1_PROPOS)) .AND. Empty(ADY->ADY_PROCES) .AND. ADY->ADY_TPCONT $ "4"
		cNome := Posicione("SA1",1,xFilial("SA1")+ADY->ADY_CODIGO+ADY->ADY_LOJA,"A1_NOME")
		//Considerar os DEFINES no inicio do fonte
		aAdd(aProp, { .F.,;							// Marca
						ADY->ADY_PROPOS,;				// Proposta
						ADY->ADY_PREVIS,;				// Revisao Proposta
						ADY->ADY_OPORTU,;				// Oportunidade
						(cAliasAD1)->AD1_CODCLI,;	// Codigo
						(cAliasAD1)->AD1_LOJCLI,;	// Loja
						cNome,;						// Nome do cliente
						ADY->ADY_DATA,;				// Emissao
						ADY->ADY_TPCONT,;			// Tipo de contrato
						(cAliasAD1)->TFJ_CNTREC,;	// Contrato Reccorente (1-Sim/2-N�o)
						(cAliasAD1)->AD1_DESCRI})	//Descri��o

	EndIf
	(cAliasAD1)->(DbSkip())
EndDo
(cAliasAD1)->(DbCloseArea())

//Se nao encontrou propostas, inicializa um array vazio
If Len(aProp) == 0
	aProp :={{.F.,"","","","","","","","","",""}}
EndIf
RestArea(aArea)
Return aProp

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850Base

Carrega Base de Atendimento
@param		oLbxProp: proposta Selecionada
@param		oLbxBase: Base selecionada
@param		aBase:array para bases
@return	.T.
@author	Servi�os
@since		31/10/13
@version	P11 R9
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At850Base(cNrCont, oLbxProp, oLbxBase, aBase, aAutomato, oLbxOrc, lCtVigente)

Local aArea		:= GetArea()
Local cAliasAA3	:= GetNextAlias()
Local cFilAA3		:= xFilial("AA3")
Local nTamNrCont	:= TamSx3("TFJ_CONTRT")[1]
Local nItSel 		:= 0
Local cQuery		:= ""
Local cCodCli		:= ""
Local cLojCli		:= ""
Local cDescPro	:= ""
Local oOk			:= NIL
Local oNo			:= NIL
Local lHasOrcSim := HasOrcSimp()
Default cNrCont	:= Space(nTamNrCont)
Default aAutomato	:= Nil
Default oLbxProp	:= Nil
Default lCtVigente	:= .F.

aBase := {}

cQuery := "SELECT AA3_FILIAL, AA3_CODCLI, AA3_LOJA, AA3_NUMSER, AA3_CODPRO, AA3_SITE, AA3_CODFAB, AA3_LOJAFA, AA3_CONTRT "
cQuery +=   "FROM " + RetSqlName("AA3") + " AA3 "
cQuery +=  "WHERE AA3.AA3_FILIAL = '" + cFilAA3 + "' "
cQuery +=    "AND AA3.D_E_L_E_T_ = '' "

If !lHasOrcSim
	If	!(lTecA870)

		If aAutomato == Nil
			nItSel 	:= aScan(oLbxProp:aArray,{|x| x[P_MARCA] })
			cCodCli	:= oLbxProp:aArray[nItSel][P_CLIENT]
			cLojCli	:= oLbxProp:aArray[nItSel][P_LOJA]
		Else
			cCodCli	:=	aAutomato[1]
			cLojCli	:=	aAutomato[2]
		EndIf

		oOk			:= LoadBitMap(GetResources(), "LBOK")
		oNo			:= LoadBitMap(GetResources(), "LBNO")

		cQuery +=    "AND AA3.AA3_CODCLI = '" + cCodCli + "' "
		cQuery +=    "AND AA3.AA3_LOJA = '" + cLojCli + "' "
	Else
		cQuery +=    "AND AA3.AA3_ORIGEM = 'CN9' "
	EndIf

	cQuery +=    "AND AA3.AA3_CONTRT = '" + cNrCont + "' "
	cQuery +=    "AND AA3.AA3_EQALOC = '2' "
	cQuery +=  "ORDER BY AA3.AA3_FILIAL, AA3.AA3_CODCLI, AA3.AA3_LOJA, AA3.AA3_CODPRO, AA3.AA3_NUMSER"

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasAA3, .T., .T.)
	While	&(cAliasAA3)->(! Eof())
		aAdd(aBase, {	.F.	,;																			//Marca
						(cAliasAA3)->AA3_CODPRO,;													//Cod. Produto
						Posicione("SB1",1,xFilial("SB1")+(cAliasAA3)->AA3_CODPRO,"B1_DESC"),;	//Descricao
						(cAliasAA3)->AA3_NUMSER,;													//Id. Unico
						(cAliasAA3)->AA3_SITE,;														//Site
						(cAliasAA3)->AA3_CODFAB,;													//Cod. Fabricante
						(cAliasAA3)->AA3_LOJAFA})													//Loja Fabricante
		&(cAliasAA3)->(DbSkip())
	EndDo
	&(cAliasAA3)->(DbCloseArea())

	If Len(aBase) == 0
		aBase := {{.F.,"","","",""}}
	EndIf

	If	!(lTecA870)
		If aAutomato == Nil
			oLbxBase:SetArray(aBase)
			oLbxBase:bLine	:= {||	{If(aBase[oLbxBase:nAt,1],oOk,oNo),;
										aBase[oLbxBase:nAt,2],;
										aBase[oLbxBase:nAt,3],;
										aBase[oLbxBase:nAt,4],;
										aBase[oLbxBase:nAt,5]}}
			oLbxBase:Refresh()
		EndIf
	EndIf
Else
	If	!(lTecA870) .AND. ! lCtVigente

		If aAutomato == Nil
			If !lTecA745
				If cOrcSimp != "1"
					nItSel 	:= aScan(oLbxProp:aArray,{|x| x[P_MARCA] })
				Else
					nItSel := aScan( oLbxOrc:aArray ,{|x| x[P_MARCA] })
				EndIf
			Else
				nItSel 		:= ''
			EndIf
			If !lTecA745
				If cOrcSimp <> "1"
					cCodCli	:= oLbxProp:aArray[nItSel][P_CLIENT]
					cLojCli	:= oLbxProp:aArray[nItSel][P_LOJA]
				Else
					cCodCli := oLbxOrc:aArray[nItSel][O_CLIENT]
					cLojCli := oLbxOrc:aArray[nItSel][O_LOJA]
				EndIf
			Else
				cCodCli := TFJ->TFJ_CODENT
				cLojCli := TFJ->TFJ_LOJA
			EndIf
		Else
			cCodCli	:=	aAutomato[1]
			cLojCli	:=	aAutomato[2]
		EndIf

		oOk			:= LoadBitMap(GetResources(), "LBOK")
		oNo			:= LoadBitMap(GetResources(), "LBNO")

		cQuery +=    "AND AA3.AA3_CODCLI = '" + cCodCli + "' "
		cQuery +=    "AND AA3.AA3_LOJA = '" + cLojCli + "' "
	ElseIf !(lTecA745)
		cQuery +=    "AND AA3.AA3_ORIGEM = 'CN9' "
	EndIf

	cQuery +=    "AND AA3.AA3_CONTRT = '" + cNrCont + "' "
	cQuery +=    "AND AA3.AA3_EQALOC = '2' "
	cQuery +=  "ORDER BY AA3.AA3_FILIAL, AA3.AA3_CODCLI, AA3.AA3_LOJA, AA3.AA3_CODPRO, AA3.AA3_NUMSER"

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasAA3, .T., .T.)
	While	&(cAliasAA3)->(! Eof())
		aAdd(aBase, {	.F.	,;																			//Marca
						(cAliasAA3)->AA3_CODPRO,;													//Cod. Produto
						Posicione("SB1",1,xFilial("SB1")+(cAliasAA3)->AA3_CODPRO,"B1_DESC"),;	//Descricao
						(cAliasAA3)->AA3_NUMSER,;													//Id. Unico
						(cAliasAA3)->AA3_SITE,;														//Site
						(cAliasAA3)->AA3_CODFAB,;													//Cod. Fabricante
						(cAliasAA3)->AA3_LOJAFA})													//Loja Fabricante
		&(cAliasAA3)->(DbSkip())
	EndDo
	&(cAliasAA3)->(DbCloseArea())

	If Len(aBase) == 0
		aBase := {{.F.,"","","",""}}
	EndIf

	If	!(lTecA870) .AND. ! lCtVigente
		If aAutomato == Nil
			oLbxBase:SetArray(aBase)
			oLbxBase:bLine	:= {||	{If(aBase[oLbxBase:nAt,1],oOk,oNo),;
										aBase[oLbxBase:nAt,2],;
										aBase[oLbxBase:nAt,3],;
										aBase[oLbxBase:nAt,4],;
										aBase[oLbxBase:nAt,5]}}
			oLbxBase:Refresh()
		EndIf
	EndIf
EndIf
RestArea(aArea)

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850Suges

Sugere uma base de atendimento para a proposta.
@author Servi�os
@since 31/10/13
@version P11 R9
@param oLbxProp: proposta Selecionada
@param olbxOrc: or�amento (quando MV_ORCSIMP = 1)
@return  .T.
/*/
//-----------------------------------------------------------------------------------------------------
Function At850Suges(oLbxProp,aProposta,oLbxBase,aBase,lAuto,aDadosAuto,cIDNovo, oLbxOrc,lCtVigente)
Local aAreaADZ		:= ADZ->(GetArea())					// Area da tabela ADZ.
Local lRetorno		:= .T.								// Retorno da rotina.
Local nPos			:= 0								// Posicao da marca.
Local cCodProp		:= ""								// Codigo da proposta comercial.
Local cRevProp		:= ""								// Revisao da proposta comercial.
Local cIdUnico		:= ""								// Identificador da base.
Local aLocais 		:= {}								// Locais de atendimento.
Local oDlg			:= Nil								// Dialog principal.
Local aSize	 		:= FWGetDialogSize( oMainWnd ) 		// Array com tamanho da janela.
Local oColSugest	:= Nil								// Coluna sugestao de base de atendimento.
Local oBrwSugest	:= Nil								// Browse sugestao de base de atendimento.
Local cOportunid	:= ""
Local nTamNumSer	:= TAMSX3("AA3_NUMSER")[1]
Local cProBase 		:= ""
Local lTFF 			:= .F.
Local lTFI 			:= .F.
Local lTFG 			:= .F.
Local lTFH 			:= .F.
Local cCodOrc		:= ""
Local lHasOrcSim := HasOrcSimp() 
Local lGSRH 	:= GSGetIns("RH")
Local lGSMIMC	:= GSGetIns("MI")
Local lGSLE		:= GSGetIns("LE")

Default lAuto 		:= .F.
Default aDadosAuto 	:= {}
Default cIDNovo 	:= ""

If lHasOrcSim
	Default lCtVigente := .F.
Else
	Default oLbxProp 	:= Nil
	Default aBase		:= {}
	Default aProposta	:= {}
EndIf

If !lHasOrcSim
	//Codigo da proposta selecionada
	If !lAuto
		nPos 			:= 	aScan(oLbxProp:aArray,{|x| x[P_MARCA]})
		cCodProp 		:= 	oLbxProp:aArray[nPos,P_PROPOS]
		cRevProp 		:= 	oLbxProp:aArray[nPos,P_REVISA]
		cOportunid		:=	oLbxProp:aArray[nPos,P_OPORTU]
	Else
		nPos			:= 1
	    cCodProp		:= aDadosAuto[P_PROPOS]
	    cRevProp		:= aDadosAuto[P_REVISA]
	    cOportunid		:= aDadosAuto[P_OPORTU]
	EndIf

	cIDNovo	:= SUBSTR(cOportunid+cCodProp,1,nTamNumSer)+REPLICATE("0",nTamNumSer-Len(SUBSTR(cOportunid+cCodProp,1,nTamNumSer))-1)+"1"

	DbSelectArea("ADY")
	DbSetOrder(1) //ADY_FILIAL+ADY_PROPOS

	If DbSeek(xFilial("ADY")+cCodProp)

		// ADZ_FILIAL+ADZ_PROPOS+ADZ_REVISA+ADZ_FOLDER+ADZ_ITEM
		DbSelectArea("ADZ")
		ADZ->(DbSetOrder(3))

		DbSelectArea("TFJ")
		TFJ->(DbSetOrder(2)) // TFJ_FILIAL+TFJ_PROPOS+TFJ_PREVIS

		DbSelectArea("TFL")
		TFL->(DbSetOrder(2)) // TFL_FILIAL + TFL_CODPAI

		DbSelectArea("TFF")
		TFF->(DbSetOrder(3))  // TFF_FILIAL + TFF_CODPAI

		DbSelectArea("TFI")
		TFI->(DbSetOrder(3))  // TFI_FILIAL + TFI_CODPAI

		DbSelectArea("TFG")
		TFG->(DbSetOrder(3))  // TFI_FILIAL + TFI_CODPAI

		DbSelectArea("TFH")
		TFH->(DbSetOrder(3))  // TFI_FILIAL + TFI_CODPAI

		If ADZ->(DbSeek(xFilial("ADZ")+cCodProp+cRevProp)) .And. ;
			TFJ->( DbSeek( xFilial("TFJ")+cCodProp+cRevProp ) ) .And. ;
			TFL->( DbSeek( xFilial("TFL")+TFJ->TFJ_CODIGO ) ) .And. ;
			( ( lTFF := TFF->( DbSeek( xFilial("TFF")+TFL->TFL_CODIGO))) .Or.;
			(lTFI := TFI->( DbSeek( xFilial("TFI")+TFL->TFL_CODIGO ))) .Or.;
			(lTFG := TFG->( DbSeek( xFilial("TFG")+TFL->TFL_CODIGO ))) .Or. ;
			(lTFH := TFH->( DbSeek( xFilial("TFH")+TFL->TFL_CODIGO ))))

			If TFJ->TFJ_DSGCN == '1'
				// quando n�o � agrupado pega o primeiro produto de rh da TFF
				If lTFF
					cProBase := TFF->TFF_PRODUT
				ElseIf lTFI
					cProBase := TFI->TFI_PRODUT
				ElseIf lTFG
					cProBase := TFG->TFG_PRODUT
				ElseIf lTFH
					cProBase := TFH->TFH_PRODUT
				EndIf
			Else
				// quando agrupado pega o produto de rh do cabe�alho
				If lGSRH
					cProBase := TFJ->TFJ_GRPRH
				ElseIf lGSLE
					cProBase := TFJ->TFJ_GRPLE
				ElseIf lGSMIMC
					If !Empty(TFJ->TFJ_GRPMI)
						cProBase := TFJ->TFJ_GRPMI
					Else
						cProBase := TFJ->TFJ_GRPMC
					EndIf
				EndIf
			EndIf

			aAdd(aLocais, {ADY->ADY_CODIGO,;
							ADY->ADY_LOJA,;
							cProBase,;
							Posicione("SB1",1,xFilial("SB1")+cProBase,"B1_DESC"),;
							cIDNovo,;
							ADZ->ADZ_LOCAL,;
							Posicione("ABS",1,xFilial("ABS")+ADZ->ADZ_LOCAL,"ABS_DESCRI")})
		EndIf

	    If !IsBlind()
			If Len(aLocais) > 0

				DEFINE DIALOG oDlg TITLE STR0044 FROM aSize[1]*0.07,aSize[2]*0.75 TO aSize[3]*0.47,aSize[4]*0.75 PIXEL  // "Sugest�o de Bases de Atendimento"

				DEFINE FWBROWSE oBrwSugest DATA ARRAY ARRAY aLocais LINE BEGIN 1 EDITCELL { |lCancel,oBrowse| At850VdEdt(lCancel,oBrowse,aLocais) } OF oDlg

				ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][3] }")  TITLE TxDadosCpo("AA3_CODPRO")[1] SIZE TamSX3("AA3_CODPRO")[1] OF oBrwSugest   											// "Produto/Eqto"
				ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][4] }")  TITLE TxDadosCpo("AA3_DESPRO")[1] SIZE TamSX3("AA3_DESPRO")[1] OF oBrwSugest   											// "Desc.Produto"
				ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][5] }")  TITLE TxDadosCpo("AA3_NUMSER")[1] SIZE TamSX3("AA3_NUMSER")[1] PICTURE "@!" EDIT  READVAR "cIdUnico" OF oBrwSugest  	// "Id.Unico"
				ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][6] }")  TITLE TxDadosCpo("AA3_CODLOC")[1] SIZE TamSX3("AA3_CODLOC")[1] OF oBrwSugest   											// "Cod. Local"
				ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][7] }")  TITLE TxDadosCpo("ABS_DESCRI")[1] SIZE TamSX3("ABS_DESCRI")[1] OF oBrwSugest    											// "Descri��o."

				ACTIVATE FWBROWSE oBrwSugest

				ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIF(At850VdGvb(aLocais),MsgRun(STR0071,STR0068,{|| At850GvBse(aLocais),oDlg:End()}),lRetorno := .F. )},{|| lRetorno := .F.,oDlg:End()}) CENTERED // "Gerando as bases de atendimento..."###"Aguarde"
			Else
				MsgAlert(STR0042,STR0043)  // "N�o h� sugest�o de bases de atendimento para esta proposta comercial."###"Aten��o"
				lRetorno := .F.
			EndIf
		EndIf
	Else
		If !IsBlind()
			MsgStop(STR0045,STR0043)// "Proposta comercial n�o localizada."###"Aten��o"
	    EndIf
		lRetorno := .F.
	EndIf

	If IsBlind()
		lRetorno := At850GvBse(aLocais)
	EndIf

	RestArea(aAreaADZ)
	If !IsBlind()
		oLbxBase:Refresh()
	EndIf
Else
	If�(IIF(lTecA745,�TFJ->TFJ_ORCSIM�!=�'1',�cOrcSimp�!=�"1"�))
		If !lAuto
			nPos 			:= 	aScan(oLbxProp:aArray,{|x| x[P_MARCA]})
			cCodProp 		:= 	oLbxProp:aArray[nPos,P_PROPOS]
			cRevProp 		:= 	oLbxProp:aArray[nPos,P_REVISA]
			cOportunid		:=	oLbxProp:aArray[nPos,P_OPORTU]
		Else
			nPos			:= 1
		    cCodProp		:= aDadosAuto[P_PROPOS]
		    cRevProp		:= aDadosAuto[P_REVISA]
		    cOportunid		:= aDadosAuto[P_OPORTU]		    
		EndIf

		cIDNovo	:= SUBSTR(cOportunid+cCodProp,1,nTamNumSer)+REPLICATE("0",nTamNumSer-Len(SUBSTR(cOportunid+cCodProp,1,nTamNumSer))-1)+"1"
		Else
			if cOrcSimp == "1"
				If lTecA745 .OR. lCtVigente
					nPos := 0
					cCodOrc := TFJ->TFJ_CODIGO
					cCodCli := TFJ->TFJ_CODENT
				Else
					nPos := aScan(oLbxOrc:aArray,{|x| x[P_MARCA]})
					cCodOrc := oLbxOrc:aArray[nPos,O_CODORC]
					cCodCli := oLbxOrc:aArray[nPos,O_CLIENT]
				EndIf

				cIDNovo	:= SUBSTR(cCodOrc,1,nTamNumSer)+REPLICATE("0",nTamNumSer-Len(SUBSTR(cCodOrc,1,nTamNumSer))-1)+"1"
			Else
				cIDNovo	:= SUBSTR(cCodOrc,1,nTamNumSer)+REPLICATE("0",nTamNumSer-Len(SUBSTR(cCodOrc,1,nTamNumSer))-1)+"1"
			EndIf
		EndIf

		DbSelectArea("ADY")
		DbSetOrder(1) //ADY_FILIAL+ADY_PROPOS

		If�(IIF(lTecA745,�TFJ->TFJ_ORCSIM�!=�'1',�cOrcSimp�!=�"1"�))
			If DbSeek(xFilial("ADY")+cCodProp)

			// ADZ_FILIAL+ADZ_PROPOS+ADZ_REVISA+ADZ_FOLDER+ADZ_ITEM
			DbSelectArea("ADZ")
			ADZ->(DbSetOrder(3))

			DbSelectArea("TFJ")
			TFJ->(DbSetOrder(2)) // TFJ_FILIAL+TFJ_PROPOS+TFJ_PREVIS

			DbSelectArea("TFL")
			TFL->(DbSetOrder(2)) // TFL_FILIAL + TFL_CODPAI

			DbSelectArea("TFF")
			TFF->(DbSetOrder(3))  // TFF_FILIAL + TFF_CODPAI

			DbSelectArea("TFI")
			TFI->(DbSetOrder(3))  // TFI_FILIAL + TFI_CODPAI

			DbSelectArea("TFG")
			TFG->(DbSetOrder(3))  // TFI_FILIAL + TFI_CODPAI

			DbSelectArea("TFH")
			TFH->(DbSetOrder(3))  // TFI_FILIAL + TFI_CODPAI

			If ADZ->(DbSeek(xFilial("ADZ")+cCodProp+cRevProp)) .And. ;
				TFJ->( DbSeek( xFilial("TFJ")+cCodProp+cRevProp ) ) .And. ;
				TFL->( DbSeek( xFilial("TFL")+TFJ->TFJ_CODIGO ) ) .And. ;
				( ( lTFF := TFF->( DbSeek( xFilial("TFF")+TFL->TFL_CODIGO))) .Or.;
				(lTFI := TFI->( DbSeek( xFilial("TFI")+TFL->TFL_CODIGO ))) .Or.;
				(lTFG := TFG->( DbSeek( xFilial("TFG")+TFL->TFL_CODIGO ))) .Or. ;
				(lTFH := TFH->( DbSeek( xFilial("TFH")+TFL->TFL_CODIGO ))))

				If TFJ->TFJ_DSGCN == '1'
					// quando n�o � agrupado pega o primeiro produto de rh da TFF
					If lTFF
						cProBase := TFF->TFF_PRODUT
					ElseIf lTFI
						cProBase := TFI->TFI_PRODUT
					ElseIf lTFG
						cProBase := TFG->TFG_PRODUT
					ElseIf lTFH
						cProBase := TFH->TFH_PRODUT
					EndIf
				Else
					// quando agrupado pega o produto de rh do cabe�alho
					If lGSRH
						cProBase := TFJ->TFJ_GRPRH
					ElseIf lGSLE
						cProBase := TFJ->TFJ_GRPLE
					ElseIf lGSMIMC
						If !Empty(TFJ->TFJ_GRPMI)
							cProBase := TFJ->TFJ_GRPMI
						Else
							cProBase := TFJ->TFJ_GRPMC
						EndIf
					EndIf
				EndIf

				aAdd(aLocais, {ADY->ADY_CODIGO,;
								ADY->ADY_LOJA,;
								cProBase,;
								Posicione("SB1",1,xFilial("SB1")+cProBase,"B1_DESC"),;
								cIDNovo,;
								ADZ->ADZ_LOCAL,;
								Posicione("ABS",1,xFilial("ABS")+ADZ->ADZ_LOCAL,"ABS_DESCRI")})
			EndIf

			If !IsBlind()
				If Len(aLocais) > 0

					DEFINE DIALOG oDlg TITLE STR0044 FROM aSize[1]*0.07,aSize[2]*0.75 TO aSize[3]*0.47,aSize[4]*0.75 PIXEL  // "Sugest�o de Bases de Atendimento"

					DEFINE FWBROWSE oBrwSugest DATA ARRAY ARRAY aLocais LINE BEGIN 1 EDITCELL { |lCancel,oBrowse| At850VdEdt(lCancel,oBrowse,aLocais) } OF oDlg

					ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][3] }")  TITLE TxDadosCpo("AA3_CODPRO")[1] SIZE TamSX3("AA3_CODPRO")[1] OF oBrwSugest   											// "Produto/Eqto"
					ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][4] }")  TITLE TxDadosCpo("AA3_DESPRO")[1] SIZE TamSX3("AA3_DESPRO")[1] OF oBrwSugest   											// "Desc.Produto"
					ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][5] }")  TITLE TxDadosCpo("AA3_NUMSER")[1] SIZE TamSX3("AA3_NUMSER")[1] PICTURE "@!" EDIT  READVAR "cIdUnico" OF oBrwSugest  	// "Id.Unico"
					ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][6] }")  TITLE TxDadosCpo("AA3_CODLOC")[1] SIZE TamSX3("AA3_CODLOC")[1] OF oBrwSugest   											// "Cod. Local"
					ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][7] }")  TITLE TxDadosCpo("ABS_DESCRI")[1] SIZE TamSX3("ABS_DESCRI")[1] OF oBrwSugest    											// "Descri��o."

					ACTIVATE FWBROWSE oBrwSugest

					ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIF(At850VdGvb(aLocais),MsgRun(STR0071,STR0068,{|| At850GvBse(aLocais),oDlg:End()}),lRetorno := .F. )},{|| lRetorno := .F.,oDlg:End()}) CENTERED // "Gerando as bases de atendimento..."###"Aguarde"
				Else
					MsgAlert(STR0042,STR0043)  // "N�o h� sugest�o de bases de atendimento para esta proposta comercial."###"Aten��o"
					lRetorno := .F.
				EndIf
			EndIf
		Else
			If !IsBlind()
				MsgStop(STR0045,STR0043)// "Proposta comercial n�o localizada."###"Aten��o"
			EndIf
			lRetorno := .F.
		EndIf
	Else
		// Caso o par�metro MV_ORCSIMP esteja ativo, o apontamento da TFJ se d� pelo c�digo do or�amento
		IF cOrcSimp == "1"
			DbSelectArea("TFJ")
			TFJ->(DbSetOrder(1)) //TFJ_FILIAL + TFJ_CODIGO
			TFJ->(DbSeek(xFilial("TFJ") + cCodOrc ))
		EndIf

		DbSelectArea("TFL")
		TFL->(DbSetOrder(2)) // TFL_FILIAL + TFL_CODPAI

		DbSelectArea("TFF")
		TFF->(DbSetOrder(3))  // TFF_FILIAL + TFF_CODPAI

		DbSelectArea("TFI")
		TFI->(DbSetOrder(3))  // TFI_FILIAL + TFI_CODPAI

		DbSelectArea("TFG")
		TFG->(DbSetOrder(3))  // TFI_FILIAL + TFI_CODPAI

		DbSelectArea("TFH")
		TFH->(DbSetOrder(3))  // TFI_FILIAL + TFI_CODPAI

		If TFL->( DbSeek( xFilial("TFL")+TFJ->TFJ_CODIGO ) ) .And. ;
			( ( lTFF := TFF->( DbSeek( xFilial("TFF")+TFL->TFL_CODIGO))) .Or.;
			(lTFI := TFI->( DbSeek( xFilial("TFI")+TFL->TFL_CODIGO ))) .Or.;
			(lTFG := TFG->( DbSeek( xFilial("TFG")+TFL->TFL_CODIGO ))) .Or. ;
			(lTFH := TFH->( DbSeek( xFilial("TFH")+TFL->TFL_CODIGO ))))

			If TFJ->TFJ_DSGCN == '1'
				// quando n�o � agrupado pega o primeiro produto de rh da TFF
				If lTFF
					cProBase := TFF->TFF_PRODUT
				ElseIf lTFI
					cProBase := TFI->TFI_PRODUT
				ElseIf lTFG
					cProBase := TFG->TFG_PRODUT
				ElseIf lTFH
					cProBase := TFH->TFH_PRODUT
				EndIf
			Else
				// quando agrupado pega o produto de rh do cabe�alho
				If lGSRH
					cProBase := TFJ->TFJ_GRPRH
				ElseIf lGSLE
					cProBase := TFJ->TFJ_GRPLE
				ElseIf lGSMIMC
					If !Empty(TFJ->TFJ_GRPMI)
						cProBase := TFJ->TFJ_GRPMI
					Else
						cProBase := TFJ->TFJ_GRPMC
					EndIf
				EndIf
			EndIf

			aAdd(aLocais, {TFJ->TFJ_CODENT,;
							TFJ->TFJ_LOJA,;
							cProBase,;
							Posicione("SB1",1,xFilial("SB1")+cProBase,"B1_DESC"),;
							cIDNovo,;
							TFL->TFL_LOCAL,;
							Posicione("ABS",1,xFilial("ABS")+ADZ->ADZ_LOCAL,"ABS_DESCRI")})


		    If !IsBlind()
				If Len(aLocais) > 0

					DEFINE DIALOG oDlg TITLE STR0044 FROM aSize[1]*0.07,aSize[2]*0.75 TO aSize[3]*0.47,aSize[4]*0.75 PIXEL  // "Sugest�o de Bases de Atendimento"

					DEFINE FWBROWSE oBrwSugest DATA ARRAY ARRAY aLocais LINE BEGIN 1 EDITCELL { |lCancel,oBrowse| At850VdEdt(lCancel,oBrowse,aLocais) } OF oDlg

					ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][3] }")  TITLE TxDadosCpo("AA3_CODPRO")[1] SIZE TamSX3("AA3_CODPRO")[1] OF oBrwSugest   											// "Produto/Eqto"
					ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][4] }")  TITLE TxDadosCpo("AA3_DESPRO")[1] SIZE TamSX3("AA3_DESPRO")[1] OF oBrwSugest   											// "Desc.Produto"
					ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][5] }")  TITLE TxDadosCpo("AA3_NUMSER")[1] SIZE TamSX3("AA3_NUMSER")[1] PICTURE "@!" EDIT  READVAR "cIdUnico" OF oBrwSugest  	// "Id.Unico"
					ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][6] }")  TITLE TxDadosCpo("AA3_CODLOC")[1] SIZE TamSX3("AA3_CODLOC")[1] OF oBrwSugest   											// "Cod. Local"
					ADD COLUMN oColSugest DATA &("{ || aLocais[oBrwSugest:At()][7] }")  TITLE TxDadosCpo("ABS_DESCRI")[1] SIZE TamSX3("ABS_DESCRI")[1] OF oBrwSugest    											// "Descri��o."

					ACTIVATE FWBROWSE oBrwSugest

					ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIF(At850VdGvb(aLocais),MsgRun(STR0071,STR0068,{|| At850GvBse(aLocais),oDlg:End()}),lRetorno := .F. )},{|| lRetorno := .F.,oDlg:End()}) CENTERED // "Gerando as bases de atendimento..."###"Aguarde"
				Else
					MsgAlert(STR0042,STR0043)  // "N�o h� sugest�o de bases de atendimento para esta proposta comercial."###"Aten��o"
					lRetorno := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If IsBlind()
		lRetorno := At850GvBse(aLocais)
	EndIf

	RestArea(aAreaADZ)
	If !IsBlind()
		oLbxBase:Refresh()
	EndIf
EndIf
Return( lRetorno )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850VdEdt

Valida��o na sugest�o da Base de atendimento
@author Servi�os
@since 31/10/13
@version P11 R9
@param lCancel: Cancelamento
@param oBrowse: Browse
@param aLocais: Locais de atendimento
@return  .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At850VdEdt(lCancel,oBrowse,aLocais)

Local lRetorno	:= .T.						// Retorno da rotina.
Local nX			:= 0						// Incremento utilizado no For.
Local cConteudo	:= &(ReadVar())			// Conteudo em memoria do campo.
Local cChvPos		:= ""						// Chave posicionada.
Local cChvAtu		:= ""						// Chave atual.
Local nAux			:= 0						// Variavel auxiliar da linha do aCols.

If Type("n") <> "U"
	nAux := n
	n := Nil
EndIf

If !lCancel

	cChvPos := aLocais[oBrowse:nAt][1]+aLocais[oBrowse:nAt][2]+aLocais[oBrowse:nAt][3]+cConteudo

	RegToMemory("AA3",.T.,.F.,.F.)

	For nX := 1 To Len(aLocais)

		cChvAtu := aLocais[nX][1]+aLocais[nX][2]+aLocais[nX][3]+aLocais[nX][5]

		If nX <> oBrowse:nAt .AND. !Empty(cConteudo) .AND. cChvAtu == cChvPos
			MsgStop(STR0046,STR0043)	// "Identificador j� informado para este produto."###"Aten��o"
			lRetorno := .F.
			Exit
		EndIf

		If lRetorno

			M->AA3_CODCLI	:= aLocais[nX][1]
			M->AA3_LOJA 	:= aLocais[nX][2]
			M->AA3_CODPRO	:= aLocais[nX][3]
			M->AA3_NUMSER	:= cConteudo

			If !( At040SkSer() .AND. ExistChav("AA3",M->AA3_CODCLI+M->AA3_LOJA+M->AA3_CODPRO+M->AA3_NUMSER) )
				lRetorno := .F.
				Exit
			EndIf

		EndIf

	Next nX

	If lRetorno
		aLocais[oBrowse:nAt][5] := cConteudo
	EndIf

EndIf

If nAux <> 0
	n := nAux
EndIf

Return( lRetorno )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850IncBA

Inclus�o de Base de Atendimento
@author Servi�os
@since 31/10/13
@version P11 R9
@return  .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At850IncBA()

Local aArea		:= GetArea()
Local nOpcA		:= 0

SaveInter()

Private aRotina := {	{ STR0015	,"AxPesqui"  	,0	,1	,0	,.F.},;//"Pesquisar"
						{ STR0047	,"At040Visua"	,0	,2	,0	,.T.},;	//"Visualizar"
						{ STR0048	,"At040Inclu"	,0	,3	,0	,.T.}} 	//"Incluir"

Private cCadastro := STR0049 // "INCLUS�O - Base de Atendimento"

ALTERA	:= .F.
INCLUI	:= .T.

nOpcA := At040Inclu("AA3",0,3)

RestInter()
RestArea(aArea)
Return nOpcA

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850VdGvb

Valida��o Browse sugest�o
@author Servi�os
@since 31/10/13
@version P11 R9
@param aLocais:locais de atencimento
@return  .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At850VdGvb(aLocais)

Local lRetorno := .T.	// Retorno da rotina.

aEval(aLocais,{|x| IIF(Empty(x[5]),lRetorno := .F., Nil)})

If !lRetorno
	MsgStop(STR0050,STR0043) // "Identificador n�o informado."##"Aten��o"
EndIf

Return( lRetorno )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850GvBse

Grava Base de atendimento atraves dos locais de atendimento
@author Servi�os
@since 31/10/13
@version P11 R9
@param aLocais:locais de atencimento
@return  .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At850GvBse(aLocais)

Local lRetorno	:= .T.			// Retorno da rotina.
Local nX		:= 0			// Incremento utilizado no For.
Local aCabec	:= {}			// Array que contem o cabe�alho da tabela AA3.
Local aItens	:= {}			// Array itens da base de atendimento.

Private lMsErroAuto	:= .F.

For nX := 1 To Len(aLocais)

	Aadd(aCabec,{"AA3_FILIAL"	,xFilial("AA3")	,Nil})
	Aadd(aCabec,{"AA3_CODCLI"	,aLocais[nX][1]	,Nil})
	Aadd(aCabec,{"AA3_LOJA"  	,aLocais[nX][2]	,Nil})
	Aadd(aCabec,{"AA3_CODPRO"	,aLocais[nX][3]	,Nil})
	Aadd(aCabec,{"AA3_NUMSER"	,aLocais[nX][5]	,Nil})
	Aadd(aCabec,{"AA3_DTVEN"	,Date()			,Nil})
	Aadd(aCabec,{"AA3_CODLOC"	,aLocais[nX][6]	,Nil})

	MsExecAuto( {|w,x,y,z| TECA040(w,x,y,z)},Nil,aCabec,aItens, 3)

	If lMsErroAuto .And. !IsBlind()
		MostraErro()
	EndIf

	aCabec	:= {}
	aItens	:= {}

Next nX

Return( lRetorno )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850VldPr

Valida sele��o da Proposta Comercial
@author Servi�os
@since 31/10/13
@version P11 R9
@param oLbxProp:Informa��es da proposta comercial
@return  .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At850VldPr(oLbxProp,cCodTFJ)

Local lRet		:= .T.
Local nItSel	:= 0

nItSel := aScan(oLbxProp:aArray,{|x| x[P_MARCA] })

If nItSel == 0
	MsgInfo(STR0051) //"Selecione a oportunidade / proposta para gera��o dos contratos"
	lRet := .F.
ElseIf Empty(oLbxProp:aArray[nItSel][P_PROPOS])
	MsgInfo(STR0052) //"N�o h� nenhuma oportunidade encerrada com propostas para gera��o de contratos no per�odo selecionado"
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850TpCt

Verifica o tipo do contrato
@author Servi�os
@since 31/10/13
@version P11 R9
@param cTContr:Tipo do Contrato
@return  .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At850TpCt(cTContr) // Verifica o tipo do contrato

Local lRet		 := .F.
Local aArea 	 := GetArea()

Default cTContr := ""

DbSelectArea("CN1")
DbSetOrder(1)

If CN1->(DbSeek(xFilial("CN1") + cTContr))
	If CN1->CN1_MEDEVE == "1"
		Aviso(STR0053, STR0054, {STR0055}, 2)//"Tipo do Contrato"###"O Tipo de Contrato Selecionado possui medi��o eventual, em contratos com medi��o eventual n�o ser� poss�vel � realiza��o de medi��es de servi�os."###"OK"
		lRet	:=	.T.
	Else
		lRet	:= .T.
	EndIf
	If CN1->CN1_ESPCTR == "1" .OR. CN1->CN1_CTRFIX <> "1"
		lRet	:= .F.
		Do Case
			Case CN1->CN1_ESPCTR == "1"
				Aviso(STR0053, STR0057, {STR0055}, 2) //"Tipo do Contrato"###"A esp�cie do contrato deve ser de Venda!"###"OK"
			Case CN1->CN1_CTRFIX <> "1"
				Aviso(STR0053, STR0059, {STR0055}, 2) //"Tipo do Contrato"###"O tipo do contrato deve ser do tipo fixo!"###"OK"
		EndCase
	EndIf
	If CN1->CN1_CROFIS <> "2"
		Aviso(STR0053, STR0116, {STR0055}, 2)//"O Tipo de Contrato Selecionado deve ser configurado para n�o gerar cronograma fisico." ### "OK"
		lRet	:=	.F.
	EndIf
EndIf

RestArea(aArea)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850VldBa

Verifica se foi selecionado bases de atendimento
@author Servi�os
@since 31/10/13
@version P11 R9
@param oLbxBase:Informa��es da base de atendimento
@return  .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function	At850VldBa(oLbxBase)

Local lRet 		:= .T.
Local nItSel	:= 0

nItSel := aScan(oLbxBase:aArray,{|x| x[B_MARCA] })

If nItSel == 0
	MsgInfo(STR0060) //"Selecione a base de atendimento para gera��o dos contratos."
	lRet := .F.
ElseIf Empty(oLbxBase:aArray[nItSel][B_NUMSER])
	MsgInfo(STR0061) //"A base de atendimento selecionada � inv�lida."
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850VldTd

Valida��es das informa��es do contrato.
@param		cTpCont:		Tipo do contrato
@param		cCbxReajCt:	Determina se o contrato tem reajuste
@param		cIndice:		Indice do reajuste
@param		cCnPag:		Condi��o de pagamento
@param		cTpPl:			Tipo da planilha
@param		dDtIni:		Data inicial do contrato
@param		dDtFim:		Data final do contrato
@param		cNrCont:		N�mero do contrato
@param		dDtAss:		Data da assinatura do contrato
@param		cCbxStCtr:		Situa��o para o contrato
@return	.T. = Informa��es do assistente v�lidas // .F. = Informa��es do assistente inv�lidas
@author	Servi�os
@since		31/10/13
@version	P11 R9
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At850VldTd(cTpCont, cCbxReajCt, cIndice, cCnPag, cTpPl, dDtIni, dDtFim, cNrCont, dDtAss, cCbxStCtr, nQtdRec, cTFJCodigo)

Local lRet	:= .T.
Local lGeraCronFin := .F.
Local lPlanRecorrente := .F.
Local lIsFatAntecip := TFJ->TFJ_ANTECI == "1"  // verificar o posicionamento da TFJ
Local lIsRecorrente := TFJ->TFJ_CNTREC == "1"  // verificar o posicionamento da TFJ
Default cCodTFJ := ""

Do Case
	Case Empty(cTpCont)
		MsgAlert(STR0062, STR0043)  // "Tipo de Contrato � obrigat�rio!" ### "Aten��o"
		lRet	:=	.F.
	Case Empty(cCnPag)
		MsgAlert(STR0063, STR0043)  // "Condi��o de Pagamento � obrigat�rio!" ### "Aten��o"
		lRet	:= .F.
	Case cCbxReajCt == STR0005 .AND. Empty(cIndice)	// "Sim"
		MsgAlert(STR0064, STR0043)  // "Todo contrato com possibilidade de Reajuste deve ter preenchido um �ndice!" ### "Aten��o"
		lRet	:= .F.
	Case Empty(cTpPl)
		MsgAlert(STR0065, STR0043)  // "Tipo da planilha � obrigat�rio!" ### "Aten��o"
		lRet	:=	.F.
	Case Empty(DtoS(dDtIni))
		MsgAlert(STR0072, STR0043)  // "Data n�o pode ser vazia." ### "Aten��o"
		lRet	:=	.F.
	Case Empty(DtoS(dDtFim))
		MsgAlert(STR0072, STR0043)  // "Data n�o pode ser vazia." ### "Aten��o"
		lRet	:=	.F.
	Case dDtIni > dDtFim
		MsgAlert(STR0130, STR0043)  // "Data inicial deve ser anterior � data final." ### "Aten��o"
		lRet	:=	.F.
	Case cCbxStCtr == STR0108 .and. Empty(dDtAss)	// "Vigente"
		MsgAlert(STR0131, STR0043)  // "� obrigat�rio informar a data da assinatura do contrato para que seja poss�vel torn�-lo vigente." ### "Aten��o"
		lRet	:=	.F.
	Case !lTecA870	.AND. !VldNrCont(cNrCont)
		lRet	:= .F.
End Case
// valida se a o tipo de planilha ou contrato est�o exigindo cronograma financeiro
If lRet
    DbSelectArea("CNL")
    CNL->(DbSetOrder(1)) // CNL_FILIAL + CNL_CODIGO
    CNL->( DbSeek( xFilial("CNL")+cTpPl ) )

    DbSelectArea("CN1")
    CN1->( DbSetOrder(1) ) // CN1_FILIAL + CN1_CODIGO
    CN1->( DbSeek( xFilial("CN1")+cTpCont ) )

    // Avalia pelos tipos de planilha/contrato se deve gerar cronograma financeiro
    lGeraCronFin := ( ( CNL->CNL_MEDEVE $ "2/3" ) .Or. ;  // tipo de planilha define | 2-Tem Cronog (n�o h� medi��o eventual)/3-Recorrente
                    ( CNL->CNL_MEDEVE $ " /0" .And. CN1->CN1_MEDEVE == "2" ) )  // tipo de planilha respeita tipo de contrato | 2-Tem cronog (n�o h� medi��o eventual)
    // define se a planilha � recorrente
    lPlanRecorrente := ( CNL->CNL_MEDEVE == "3" )

    If lIsRecorrente .And. !lPlanRecorrente
        lRet := .F.
        MsgAlert(STR0161, STR0043)  // "� obrigat�rio utilizar um tipo de planilha com medi��o eventual igual a 3-Recorrente." ### "Aten��o"
	Elseif lIsRecorrente .And. nQtdRec <= 0
        lRet := .F.
        MsgAlert(STR0165, STR0043)  // "� obrigat�rio que a quantidade de recorr�ncia seja maior que zero" ### "Aten��o"
    EndIf

	If lRet .And. lIsFatAntecip .And. !lGeraCronFin
		lRet := .F.
		MsgAlert(STR0162, STR0043)  // "� obrigat�rio o uso de cronograma financeiro para o processo de faturamento antecipado." ### "Aten��o"
	EndIf
EndIf

If lRet .And. ExistBlock("AT850ACT")
	lRet := ExecBlock("AT850ACT",.F.,.F.,{cTFJCodigo})
EndIf

If lRet
	If !IsBlind()
		If	lTecA870
			lRet := MsgYesNo(STR0132)	//"Ao finalizar o assistente de manuten��o do contrato, ser� in�ciado o processo de altera��o do contrato no m�dulo Gest�o de Contrato. Tem certeza que deseja dar inic�o � manuten��o do contrato?"
		Else
			lRet := MsgYesNo(STR0066)	//"Ao finalizar o assistente de gera��o do contrato, ser� in�ciado o processo de gera��o do contrato no m�dulo Gest�o de Contrato. Tem certeza que deseja dar inic�o a gera��o do contrato?"
		EndIf
	EndIf
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850ExcAt
Cria estrutura do Contrato com status "Em Elabora��o"
@param	cTpCont:		Tipo do contrato
@param	cCnPag:		Condi��o de Pagamento
@param	cCbxReajCt:	Determina se o contrato tem reajuste.
@param	cIndice:		Indice do reajuste do contrato
@param	aDatas:		Datas, com destaque para data de vig�ncia
@param	cTpPl:			Tipo da planilha
@param	cCbxReajPl:	Determina se planilha tem reajuste.
@param	cProposta:		Proposta Comercial
@param	cRevisao:		Revis�o da proposta
@param	dDtIni:		Data Inicial do Contrato
@param	dDtFim:		Data Final do Contrato
@param	cCbxFgCau:		Determina se cau��o tem reajuste.
@param	aBaseAt:		Bases de atendimento
@param	nPerCau:		Percentual de cau��o
@param	cCbxStCtr:		Situa��o do contrato
@param	cNrCont:		N�mero do contrato
@param	dDtAss:		Data da assinatura do Contrato
@param	oModel:		Modelo de dados do contrato (TECA301)
@return				.T.
@author				Servi�os
@since					31/10/2013
@version				P11 R9
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At850ExcAt(cTpCont,    cCnPag,    cCbxReajCt, cIndice, aDatas, cTpPl,;
                           cCbxReajPl, cProposta, cRevisao,   dDtIni,  dDtFim, cCbxFgCau,;
                           aBaseAt,    nPerCau,   cCbxStCtr,  cNrCont, dDtAss, oModel, nQtdRec ,;
                           Auto850, cCodOrc, lCtVigente)

Local aArea			:= GetArea()
Local aLinha			:= {}
Local aLocais			:= {}
Local cRev1			:= Space(TamSx3("TFF_CONREV")[1])
Local cMsgErr 		:= ""
Local nCont			:= 0
Local lVigente 			:= (cCbxStCtr == STR0108 ) 	//"Vigente"
Local lRet				:= .T.
Local cCodTFJ
Local lHasOrcSim := HasOrcSimp()
Local lMdtGS 	:= SuperGetMv("MV_NG2GS",.F.,.F.) .And. TableInDic("TN5") .And. TableInDic("TN6") //Par�metro de integra��o entre o SIGAMDT x SIGATEC 

Private cCadastro		:= OemToAnsi(STR0082)										//"Manuten��o de Cronograma"
Default lCtVigente := .F.

If !lHasOrcSim
	If	lTecA870
		INCLUI 	:= .F.
		ALTERA 	:= .T.
	Else
		INCLUI 	:= .T.
		ALTERA 	:= .F.
	EndIf
	Private VISUAL	:= .T.

	Default nQtdRec := 0
	BEGIN TRANSACTION

	aAdd(aLinha, {"CN9_TPCTO",  cTpCont,   NIL})
	aAdd(aLinha, {"CN9_DTINIC", dDtIni,    NIL})
	aAdd(aLinha, {"CN9_UNVIGE", "1",       NIL})
	aAdd(aLinha, {"CN9_VIGE",   aDatas[1], NIL})
	aAdd(aLinha, {"CN9_CONDPG", cCnPag,    NIL})
	If cCbxReajCt == STR0005	// "Sim"
		aAdd(aLinha, {"CN9_FLGREJ", "1", NIL})
	Else
		aAdd(aLinha, {"CN9_FLGREJ", "2", NIL})
	EndIf

	If !Empty(cIndice)
		aAdd(aLinha, {"CN9_INDICE", cIndice, NIL})
	EndIf

	aAdd(aLinha, {"CN9_DTFIM",  dDtFim,  NIL})
	aAdd(aLinha, {"CN9_MOEDA",  1,       NIL})
	If	! lTecA870
		aAdd(aLinha, {"CN9_NUMERO", cNrCont, NIL})
	EndIf
	aAdd(aLinha, {"CN9_SITUAC", "02",    NIL})
	aAdd(aLinha, {"CN9_REVISA", " ",     NIL})
	aAdd(aLinha, {"CN9_ESPCTR", "2",     NIL})
	If cCbxFgCau == STR0005	// "Sim"
		aAdd(aLinha,{"CN9_FLGCAU", "1",     NIL})
		aAdd(aLinha,{"CN9_TPCAUC", "1",     NIL})
		aAdd(aLinha,{"CN9_MINCAU", nPerCau, NIL})
	Else
		aAdd(aLinha,{"CN9_FLGCAU", "2",     NIL})
	EndIf
	aAdd(aLinha,{"CN9_ASSINA", dDtAss,               NIL})
	aAdd(aLinha,{"CN9_DTASSI", dDtAss,               NIL})
	aAdd(aLinha,{"CN9_DTPROP", GetDtProp(cProposta), NIL})

	If lAuto850
		aAdd(aLinha,{"CN9_AUTO", '1', NIL})
	EndIf


	If ExistBlock("AT850FCtr")
		lRet := ExecBlock("AT850FCtr",.F.,.F.,{aLinha})
	EndIf

	If lRet
		If !lAuto850
			MsgRun ( STR0067, STR0068, {|| lRet	:=	At850CrPlan(aLinha, cTpPl, cCbxReajPl, cProposta, cRevisao, oModel, , nQtdRec, cNrCont)} )//"Criando planilhas do Contrato", "Aguarde"
	    Else
	    	lRet := At850CrPlan(aLinha, cTpPl, cCbxReajPl, cProposta, cRevisao, oModel, , nQtdRec, cNrCont)
	 	EndIf
	EndIf

	If lRet
	    If !lAuto850
			If	lTecA870
				MsgInfo(STR0129, "")	//"Contrato alterado no m�dulo da Gest�o de Contratos"
			Else
				MsgInfo(STR0080 + cNrCont + STR0081, "")	//"Foi gerado o Contrato "#" no Modulo Gest�o de Contratos"
			EndIf
	   	EndIf

		For nCont := 1 to Len(aBaseAt)
			DbSelectArea("AA3")
			DbSetOrder(6)
			If AA3->(DbSeek(xFilial("AA3")+aBaseAt[nCont]+cFilAnt))
				AA3->(RecLock("AA3"))
				AA3->AA3_CONTRT := cNrCont
				AA3->AA3_ORIGEM := "CN9"
				AA3->(MsUnlock())
			EndIf
		Next nCont

		Pergunte("CNT100",.F.)
		If lVigente	//"Vigente?"
			//tornar contrato vigente

			aLocais	:=	At850PropLoc(xFilial("CN9"), cProposta, cRevisao, .F. /*lFilLocZero*/) //recebe locais de atendimento.
			At850AtvLocAtnd(cNrCont, cRev1, aLocais, cProposta, cRevisao)//Ativa locais de atendimento

	        If !lAuto850
				MsgRun ( STR0070, STR0068, {|| lRet := CN100SitCh(cNrCont, cRev1, "05")} )  //"Tornando o contrato Vigente"###"Aguarde"
	        Else
	        	lRet := CN100SitCh(cNrCont, cRev1, "05")
	      	EndIf
		EndIf

		If lRet
			If !lVigente
				aLocais	:=	At850PropLoc(xFilial("CN9"), cProposta, cRevisao, .F. /*lFilLocZero*/) //recebe locais de atendimento.
				At850AtvLocAtnd(cNrCont, cRev1, aLocais, cProposta, cRevisao)//Ativa locais de atendimento
			EndIf
			//----------------------------------------------------------------
			//  Verifica se h� e atualiza as reservas de equipamentos
			// para o status de efetivadas
			DbSelectArea('ADY')
			ADY->( DbSetOrder( 1 ) ) // ADY_FILIAL+ADY_PROPOS+ADY_PREVIS
			If ADY->( DbSeek( xFilial('ADY')+cProposta+cRevisao ) )
				At825Ctr()
			EndIf

			//----------------------------------------------------------------
			//  Gera o movimento inicial dos equipamentos para loca��o
			DbSelectArea('TFJ')
			TFJ->( DbSetOrder( 2 ) ) //TFJ_FILIAL+TFJ_PROPOS+TFJ_PREVIS
			If TFJ->( DbSeek( xFilial('TFJ')+cProposta+cRevisao ) )
				If TFJ->TFJ_ITEMLE != Space(TamSx3("TFJ_ITEMLE")[1]) .Or. TFJ->TFJ_DSGCN == "1"
	                If !lAuto850
						MsgRun ( STR0072, STR0068, {|| lRet := At800Start( @cMsgErr, TFJ->TFJ_CODIGO ) } ) // 'Gerando movimentos para loca��o de equipamentos' ### "Aguarde..."
	              	Else
	                	lRet := At800Start( @cMsgErr, TFJ->TFJ_CODIGO )
	                EndIf
					If !lRet
						Help(,,'AT850ERRO01',, cMsgErr,1,0)
					EndIf
				Else
					lRet := .T.
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet
		ConfirmSX8()
	Else
		DisarmTransaction()
		RollBackSXE()
	EndIf

	END TRANSACTION

	RestArea(aArea)
Else
	If cOrcSimp == '1'
		If lTecA745 .OR. lCtVigente
			cCodTFJ := TFJ->TFJ_CODIGO
		ElseIf lTeca870
			cCodTFJ := TFJ->TFJ_CODIGO
		Else
			cCodTFJ := cCodOrc
		EndIf
	Else
		cCodTFJ := TFJ->TFJ_CODIGO
	EndIf


	If	lTecA870 .OR. lCtVigente
		INCLUI 	:= .F.
		ALTERA 	:= .T.
	Else
		INCLUI 	:= .T.
		ALTERA 	:= .F.
	EndIf
	Private VISUAL	:= .T.

	Default nQtdRec := 0
	BEGIN TRANSACTION

	aAdd(aLinha, {"CN9_TPCTO",  cTpCont,   NIL})
	aAdd(aLinha, {"CN9_DTINIC", dDtIni,    NIL})
	aAdd(aLinha, {"CN9_UNVIGE", "1",       NIL})
	aAdd(aLinha, {"CN9_VIGE",   aDatas[1], NIL})
	aAdd(aLinha, {"CN9_CONDPG", cCnPag,    NIL})
	If !lTECA870
		If cCbxReajCt == STR0005
			aAdd(aLinha, {"CN9_FLGREJ", "1", NIL})
		Else
			aAdd(aLinha, {"CN9_FLGREJ", "2", NIL})
		EndIf
	EndIf
	If !Empty(cIndice)
		aAdd(aLinha, {"CN9_INDICE", cIndice, NIL})
	EndIf

	aAdd(aLinha, {"CN9_DTFIM",  dDtFim,  NIL})
	aAdd(aLinha, {"CN9_MOEDA",  1,       NIL})

	If	! lTecA870 .AND. ! lCtVigente
		aAdd(aLinha, {"CN9_NUMERO", cNrCont, NIL})
	EndIf

	aAdd(aLinha, {"CN9_SITUAC", "02",    NIL})
	aAdd(aLinha, {"CN9_REVISA", " ",     NIL})
	aAdd(aLinha, {"CN9_ESPCTR", "2",     NIL})
	If cCbxFgCau == STR0005	// "Sim"
		aAdd(aLinha,{"CN9_FLGCAU", "1",     NIL})
		aAdd(aLinha,{"CN9_TPCAUC", "1",     NIL})
		aAdd(aLinha,{"CN9_MINCAU", nPerCau, NIL})
	Else

		aAdd(aLinha,{"CN9_FLGCAU", "2",     NIL})

	EndIf

	aAdd(aLinha,{"CN9_ASSINA", dDtAss,               NIL})
	aAdd(aLinha,{"CN9_DTASSI", dDtAss,               NIL})

	if AT745Simp(cCodTFJ)
		aAdd(aLinha,{"CN9_DTPROP", dDtAss, 			NIL})
	Else
		aAdd(aLinha,{"CN9_DTPROP", GetDtProp(cProposta), NIL})
	Endif

	If lAuto850
		aAdd(aLinha,{"CN9_AUTO", '1', NIL})
	EndIf

	If ExistBlock("AT850FCtr")
		lRet := ExecBlock("AT850FCtr",.F.,.F.,{aLinha})
	EndIf

	If lRet
		If !lAuto850
			MsgRun ( STR0067, STR0068, {|| lRet	:=	At850CrPlan(aLinha, cTpPl, cCbxReajPl, cProposta, cRevisao, oModel, , nQtdRec, cCodTFJ, lCtVigente, cNrCont)} )//"Criando planilhas do Contrato", "Aguarde"
	    Else
	    	lRet := At850CrPlan(aLinha, cTpPl, cCbxReajPl, cProposta, cRevisao, oModel, , nQtdRec, cCodTFJ, lCtVigente, cNrCont)
	 	EndIf
	EndIf

	If lRet
	    If !lAuto850
			If	lTecA870 .OR. lCtVigente
				MsgInfo(STR0129, "")	//"Contrato alterado no m�dulo da Gest�o de Contratos"
			Else
				MsgInfo(STR0080 + cNrCont + STR0081, "")	//"Foi gerado o Contrato "#" no Modulo Gest�o de Contratos"
			EndIf
	   	EndIf

		For nCont := 1 to Len(aBaseAt)
			DbSelectArea("AA3")
			DbSetOrder(6)
			If AA3->(DbSeek(xFilial("AA3")+aBaseAt[nCont]+cFilAnt))
				AA3->(RecLock("AA3"))
				AA3->AA3_CONTRT := cNrCont
				AA3->AA3_ORIGEM := "CN9"
				AA3->(MsUnlock())
			EndIf
		Next nCont

		Pergunte("CNT100",.F.)
		If lVigente	//"Vigente?"
			//tornar contrato vigente
			aLocais	:=	At850PropLoc(xFilial("CN9"), cProposta, cRevisao, .F. /*lFilLocZero*/,cCodTFJ) //recebe locais de atendimento.
			At850AtvLocAtnd(cNrCont, cRev1, aLocais, cProposta, cRevisao, cCodTFJ )//Ativa locais de atendimento
	        If !lAuto850
				MsgRun ( STR0070, STR0068, {|| lRet := CN100SitCh(cNrCont, cRev1, "05")} )  //"Tornando o contrato Vigente"###"Aguarde"
	        Else
	        	lRet := CN100SitCh(cNrCont, cRev1, "05")
	      	EndIf
		EndIf

		If lRet
			If !lVigente
				aLocais	:=	At850PropLoc(xFilial("CN9"), cProposta, cRevisao, .F. /*lFilLocZero*/,cCodTFJ) //recebe locais de atendimento.
				At850AtvLocAtnd(cNrCont, cRev1, aLocais, cProposta, cRevisao, cCodTFJ )//Ativa locais de atendimento
			EndIf
			//----------------------------------------------------------------
			//  Verifica se h� e atualiza as reservas de equipamentos
			// para o status de efetivadas
			If !EMPTY(cProposta)
				DbSelectArea('ADY')
				ADY->( DbSetOrder( 1 ) ) // ADY_FILIAL+ADY_PROPOS+ADY_PREVIS
				If ADY->( DbSeek( xFilial('ADY')+cProposta+cRevisao ) )
					At825Ctr(.F.)
				EndIf
			ElseIf AT745Simp(cCodTFJ) //or�amento simplificado
				At825Ctr(.T.,cCodTFJ)
			EndIf

			//----------------------------------------------------------------
			//  Gera o movimento inicial dos equipamentos para loca��o
			DbSelectArea('TFJ')

			//Verifica se � Or�amento Simplificado e posiciona
			If !(cOrcsimp == '1') .AND. !Empty(cProposta)
			TFJ->( DbSetOrder( 2 ) ) //TFJ_FILIAL+TFJ_PROPOS+TFJ_PREVIS
				TFJ->( DbSeek( xFilial('TFJ')+cProposta+cRevisao ) )
			EndIf

				If TFJ->TFJ_ITEMLE != Space(TamSx3("TFJ_ITEMLE")[1]) .Or. TFJ->TFJ_DSGCN == "1"
	                If !lAuto850
						MsgRun ( STR0072, STR0068, {|| lRet := At800Start( @cMsgErr, TFJ->TFJ_CODIGO ) } ) // 'Gerando movimentos para loca��o de equipamentos' ### "Aguarde..."
	              	Else
	                	lRet := At800Start( @cMsgErr, TFJ->TFJ_CODIGO )
	                EndIf
					If !lRet
						Help(,,'AT850ERRO01',, cMsgErr,1,0)
					EndIf
				Else
					lRet := .T.
				EndIf
			If TFJ->( ColumnPos("TFJ_ANIVER")) > 0
				TFJ->(DbSetOrder(1))
				If TFJ->( DbSeek(xFilial("TFJ")+cCodTFJ))
					RecLock("TFJ",.F.)
						TFJ->TFJ_ANIVER := SubStr(cValTochar(dDtAss),1,5)
					TFJ->(MsUnlock())
				Endif
			Endif
		EndIf
	EndIf

	If lRet .AND. lMdtGS //Integra��o entre o SIGAMDT x SIGATEC
		dBSelectArea("TFF")
		If TFF->( ColumnPos("TFF_RISCO")) > 0 
			If !lAuto850
				MsgRun ( STR0173 , STR0068 , {|| At850CrTar(cNrCont,cRev1) } )  //"Analisando/Criando tarefas de funcion�rios"###"Aguarde"
			Else 
				At850CrTar(cNrCont,cRev1)
			EndIf	
		Endif
	Endif

	If lRet
		ConfirmSX8()
	Else
		DisarmTransaction()
		RollBackSXE()
	EndIf

	END TRANSACTION

	RestArea(aArea)
EndIf

Return	lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850CrPlan

Cria planilha para o contrato.
@param		aInfo:			Informa��es do contrato
@param		cTpPl:			Tipo da planilha
@param		cCbxReajPl:	Determina se planilha tem Reajuste.
@param		cProposta:		Proposta Comercial
@param		cRevisao:		Revis�o da proposta
@param		oModel:		Modelo de dados do contrato (TECA301)
@return	.T.
@author	Servi�os
@since		31/10/13
@version	P11 R9
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At850CrPlan(aInfo, cTpPl, cCbxReajPl, cProposta, cRevisao, oModel, lVigente, nQuantRec, cCodOrc, lCtVigente, cNrCont)

Local aArea				:= GetArea()
Local aHeader			:= {}
Local aItemPl			:= {}
Local aItensPl			:= {}
Local aClien			:= {}
Local aLocal			:= {}
Local aItemRH			:= {}
Local aItRhPl			:= {} //itens do RH e seus respectivos na planilha.
Local aItLcPl			:= {} //itens de Loca��o de equipamento e seus respectivos na planilha.
Local aItMtImp			:= {} //itens material de implanta��o e seus respectivos na planilha.
Local aItMtCns			:= {} //itens material de consumo e seus respectivos na planilha.
Local aItUnif			:= {} //itens Uniformes
Local aItArm			:= {} //itens Armamento
Local aItLocal			:= {} //local de atendimento e sua respectiva planilha [1]-Local [2]-Array ref. itens (TFF, TFG, TFH, TFI)
Local aTdClient 		:= {}
Local aTdHeader 		:= {}
Local aTdItem			:= {}
Local aTdVend			:= {}
Local lParamImp 		:= SuperGetMv("MV_ATOPIMP",,.T.)
Local lOrcPrc 			:= SuperGetMv("MV_ORCPRC",,.F.)
Local lGSISS			:= SuperGetMv("MV_GSISS",,.F.)
Local lSeqTrn 			:= (TFF->(FieldPos("TFF_SEQTRN")) > 0)
Local lSomaImp 			:= .F.
Local l850GRVPL			:= .F.
Local lRetorno			:= .T.
Local nCont				:= 0
Local nX				:= 0
Local nItSomar 			:= 0
Local cAliasTFF			:= "TFF"
Local cAliasTFG			:= "TFG"
Local cAliasTFH			:= "TFH"
Local cItem				:= "000"
Local cPedTit 			:= "1"
Local cNumero			:= ""
Local cCodLocal			:= ""
Local cCodCli			:= ""
Local cLjCli			:= ""
Local cItemTFI			:= NIL
Local cItemTFF			:= NIL
Local cItemTFG			:= NIL
Local cItemTFH			:= NIL
Local lComisPorTime 	:= SuperGetMv("MV_ATTPCOM",,"1")=="2"
Local aPrdsLE			:= {}
Local aPrdsMC			:= {}
Local aPrdsMI			:= {}
Local aPrdsRH			:= {}
Local nPrd				:= 1
Local lDsgCN 			:=	.F.
Local cABSCusto 		:= ""
Local lInsereCC 		:= .F.
Local cCodTFJ 			:= ""
Local cFilTFF 			:= xFilial("TFF")
Local cFilTFG 			:= xFilial("TFG")
Local cFilTFH 			:= xFilial("TFH")
Local nPosNumero 		:= aScan( aInfo, {|x| x[1] == "CN9_NUMERO" } )
Local nPosRevisao 		:= aScan( aInfo, {|x| x[1] == "CN9_REVISA" } )
Local lRecor			:= .F.
Local lTFJ				:= .F.
Local lHasOrcSim 		:= HasOrcSimp()
Local aIDPeds 			:= {}
Local cCodISS			:= ""
Local nAux				:= 0
Local lPrHora 			:= TecABBPRHR()
Local lTecEntCtb 		:= FindFunction("TecEntCtb") .And. TecEntCtb("ABS")
Local cABSConta 		:= ""
Local cABSItem  		:= ""
Local cABSClvl  		:= ""
Local lGsOrcUnif 		:= FindFunction("TecGsUnif") .And. TecGsUnif()
Local lGsOrcArma 		:= FindFunction("TecGsArma") .And. TecGsArma()
Local lVlrCob			:= TFF->(ColumnPos("TFF_VLRCOB")) > 0
Local lFindMe			:= TFF->(ColumnPos("TFF_FINDME")) > 0
Local lCliFindMe		:= .F.
Local lCont             := .T.
Local nValorUN          := 0
Local nValorAR          := 0
If lHasOrcSim
	lTFJ := lTecA745
EndIf


Private lMsErroAuto	:= .F.

Default nQuantRec 	:= 0
Default cCodOrc := ""
Default lCtVigente := .F.
Default cNrCont	:= ""

If lHasOrcSim .AND. !EMPTY(cCodOrc)
	lComisPorTime := lComisPorTime .And. Posicione("TFJ",1,xFilial("TFJ") + cCodOrc,"TFJ_ORCSIM") != "1"
EndIf

cNumero	:= "000001"

If !lHasOrcSim
	aLocal		:= At850PropLoc(xFilial("TFJ"), cProposta, cRevisao, .T./*lFilLocZero*/) //Recebe os locais de atendimento que existem no or�amento.
Else
	aLocal		:= At850PropLoc(xFilial("TFJ"), cProposta, cRevisao, .T./*lFilLocZero*/, cCodOrc) //Recebe os locais de atendimento que existem no or�amento.
EndIf

If ExistBlock("AT850GRVPL")
	l850GRVPL := ExecBlock("AT850GRVPL",.F.,.F.,{cCbxReajPl, cProposta, cRevisao, cCodCli, cLjCli, aLocal, aInfo, cTpPl})
Else

	If !lHasOrcSim .OR. !lTecA745
		If lHasOrcSim .AND. (!EMPTY(cCodOrc) .AND. POSICIONE("TFJ",1,xFilial("TFJ") + cCodOrc,"TFJ_ORCSIM") == '1')
			lTFJ := .T.
		Else
			DbSelectArea("TFJ")
			DbSetOrder(2) // TFJ_FILIAL+ TFJ_PROPOS + TFJ_PREVIS
			If lHasOrcSim
				lTFJ := TFJ->( DbSeek(xFilial("TFJ") + cProposta + cRevisao) )
			EndIf
		Endif
	EndIf

	If (!lHasOrcSim .AND. TFJ->( DbSeek(xFilial("TFJ") + cProposta + cRevisao) )) .OR. (lHasOrcSim .AND. lTFJ)
		cCodTFJ := TFJ->TFJ_CODIGO
		lDsgCN := TFJ->TFJ_DSGCN == '1'
		If	!lTecA870 .AND. !lCtVigente
			lSomaImp := lParamImp .And. ( !Empty( TFJ->TFJ_TABXML) .OR. !Empty( TFJ->TFJ_CODTAB) )

			// adiciona todos os clientes poss�veis como op��es dentro da CNC
			// Cliente da Proposta Comercial
			If TFJ->TFJ_ENTIDA == "1"
				If aScan(aTdClient, {|x| x[4][2]==TFJ->TFJ_CODENT .AND. x[5][2]==TFJ->TFJ_LOJA}) == 0 //Adiciona cliente somente se n�o existir no aTdClient
					Aadd(aClien,{"CNC_FILIAL", xFilial("CNC"), NIL})
					Aadd(aClien,{"CNC_NUMERO", aInfo[nPosNumero][2],   NIL})
					Aadd(aClien,{"CNC_REVISA", aInfo[nPosRevisao][2],   NIL})
					Aadd(aClien,{"CNC_CLIENT", TFJ->TFJ_CODENT,NIL})
					Aadd(aClien,{"CNC_LOJACL", TFJ->TFJ_LOJA,  NIL})
					Aadd(aTdClient, aClone(aClien))
					aSize( aClien, 0 )
				EndIf
			EndIf
			// Clientes Principais do Local de Atendimento
			// Clientes de Faturamento do Local de Atendimento
			For nCont := 1 To Len(aLocal)
				// Posiciona na ABS - Local de Atendimento
				ABS->( DbGoTo( aLocal[nCont][4] ) )

				// Clientes Principais do Local de Atendimento
				If !Empty( ABS->ABS_CODIGO ) .And. !Empty( ABS->ABS_LOJA )
					If aScan(aTdClient, {|x| x[4][2]==ABS->ABS_CODIGO .AND. x[5][2]==ABS->ABS_LOJA}) == 0 //Adiciona cliente somente se n�o existir no aTdClient
						Aadd(aClien,{"CNC_FILIAL", xFilial("CNC"), NIL})
						Aadd(aClien,{"CNC_NUMERO", aInfo[nPosNumero][2],   NIL})
						Aadd(aClien,{"CNC_REVISA", aInfo[nPosRevisao][2],   NIL})
						Aadd(aClien,{"CNC_CLIENT", ABS->ABS_CODIGO,NIL})
						Aadd(aClien,{"CNC_LOJACL", ABS->ABS_LOJA,  NIL})
						Aadd(aTdClient, aClone(aClien))
						aSize( aClien, 0 )
					EndIf
				EndIf

				// Clientes de Faturamento do Local de Atendimento
				If !Empty( ABS->ABS_CLIFAT ) .And. !Empty( ABS->ABS_LJFAT )
					If aScan(aTdClient, {|x| x[4][2]==ABS->ABS_CLIFAT .AND. x[5][2]==ABS->ABS_LJFAT}) == 0 //Adiciona cliente somente se n�o existir no aTdClient
						Aadd(aClien,{"CNC_FILIAL", xFilial("CNC"), NIL})
						Aadd(aClien,{"CNC_NUMERO", aInfo[nPosNumero][2],   NIL})
						Aadd(aClien,{"CNC_REVISA", aInfo[nPosRevisao][2],   NIL})
						Aadd(aClien,{"CNC_CLIENT", ABS->ABS_CLIFAT,NIL})
						Aadd(aClien,{"CNC_LOJACL", ABS->ABS_LJFAT,  NIL})
						Aadd(aTdClient, aClone(aClien))
						aSize( aClien, 0 )
					EndIf
				EndIf
			Next nCont

			//Para cria��o das planilhas de acordo com a quantidade de locais de atendimento.
			For nCont := 1 To Len(aLocal)
				aHeader	:=	{}
				aItemPl	:=	{}
				aClien		:=	{}
				aItensPl	:=	{}
				cCodLocal	:= aLocal[nCont][1]
				cItem		:= "000"
				cItemTFI 	:= ""
				cItemTFF 	:= ""
				cItemTFG 	:= ""
				cItemTFH 	:= ""
				cABSCusto  	:= aLocal[nCont][3]
				lInsereCC 	:= !Empty(cABSCusto)
				aIDPeds		:= {}
				If lTecEntCtb
					ABS->( DbGoTo( aLocal[nCont][4] ) )
					cABSConta := ABS->ABS_CONTA
					cABSItem  := ABS->ABS_ITEM
					cABSClvl  := ABS->ABS_CLVL
				Endif

				// busca os dados de c�digo e loja do cliente conforme a defini��o no or�amento de servi�os
				At850GetCli( @cCodCli, @cLjCli, aLocal[nCont][2], TFJ->TFJ_AGRUP ) //Busca o cliente do local de atendimento

				//Informa��o para cria��o da planilha.
				Aadd(aHeader,{"CNA_FILIAL", xFilial("CNA"), NIL})
				Aadd(aHeader,{"CNA_NUMERO", cNumero,        NIL})
				Aadd(aHeader,{"CNA_TIPPLA", cTpPl,          NIL})
				Aadd(aHeader,{"CNA_CLIENT", cCodCli, NIL})
				Aadd(aHeader,{"CNA_LOJACL", cLjCli,  NIL})
				Aadd(aHeader,{"CNA_DTINI",  aLocal[nCont][5],    NIL})
				Aadd(aHeader,{"CNA_DTFIM",  aLocal[nCont][6],    NIL})
				If nQuantRec > 0
					Aadd(aHeader,{"CNA_RPGANT",	"1" 		,	NIL})
					Aadd(aHeader,{"CNA_PERIOD",	"3"			,	NIL})
					Aadd(aHeader,{"CNA_PERREC",	1			,	NIL})
					Aadd(aHeader,{"CNA_QTDREC",	nQuantRec 	,	NIL})
				Endif
				Aadd(aTdHeader,aHeader)

				DbSelectArea("TFL")
				TFL-> ( DbSetOrder(1) )	//TFL_FILIAL+TFL_CODIGO
				If TFL->( DbSeek(xFilial("TFL")+cCodLocal) )
					cPedTit := If( TFL->TFL_PEDTIT == "2", "2", "1" )
					If lGsOrcUnif
						nValorUN := At850TUN(TFL->TFL_CODPAI,cCodLocal)
					Endif
					If lGsOrcArma	
						nValorAR := At850TAR(TFL->TFL_CODPAI,cCodLocal)
					Endif	
					IF nValorAR + nValorUN == 0
						lCont := .F.
					Endif
					If TFL->TFL_TOTRH > 0  .Or. lCont 
						If !lDsgCN
							aItemPl	:=	{}
							cItem		:=	SOMA1(cItem)
							Aadd(aItemPl,{"CNB_FILIAL", xFilial("CNB"), NIL})
							Aadd(aItemPl,{"CNB_NUMERO", cNumero,        NIL})
							Aadd(aItemPl,{"CNB_ITEM",   cItem,          NIL})
							Aadd(aItemPl,{"CNB_PRODUT", TFJ->TFJ_GRPRH, NIL})
							Aadd(aItemPl,{"CNB_QUANT",  1,              NIL})
							Aadd(aItemPl,{"CNB_VLUNIT", TFL->TFL_TOTRH, NIL})
							Aadd(aItemPl,{"CNB_TS",     TFJ->TFJ_TES,   NIL})
							Aadd(aItemPl,{"CNB_PEDTIT", cPedTit,        NIL})
							If lInsereCC
								Aadd(aItemPl,{"CNB_CC", cABSCusto,      NIL})
							EndIf
							If lTecEntCtb
								Aadd(aItemPl,{"CNB_CONTA" , cABSConta, NIL})
								Aadd(aItemPl,{"CNB_ITEMCT", cABSItem,	NIL})										
								Aadd(aItemPl,{"CNB_CLVL"  , cABSClvl,	NIL})
							Endif
							Aadd(aItensPl, aItemPl)
							cItemTFF	:= cItem
						Else
							aPrdsRH := GetPrdCTR(aLocal[nCont,1],aLocal[nCont,2	], "RH",TFJ->TFJ_CODIGO,lVlrCob)
							For nPrd := 1 To Len(aPrdsRH)
								If aPrdsRH[nPrd,3] > 0
									aItemPl	:=	{}
									cItem		:=	SOMA1(cItem)
									Aadd(aItemPl,{"CNB_FILIAL", xFilial("CNB"), NIL})
									Aadd(aItemPl,{"CNB_NUMERO", cNumero,        NIL})
									Aadd(aItemPl,{"CNB_ITEM",   cItem,          NIL})
									Aadd(aItemPl,{"CNB_PRODUT", aPrdsRH[nPrd,1],NIL})
									Aadd(aItemPl,{"CNB_QUANT",  aPrdsRH[nPrd,2],NIL})
									Aadd(aItemPl,{"CNB_VLUNIT", aPrdsRH[nPrd,3],NIL})
									Aadd(aItemPl,{"CNB_TS",     aPrdsRH[nPrd,5],NIL})
									Aadd(aItemPl,{"CNB_PEDTIT", cPedTit,        NIL})
									If lInsereCC
										Aadd(aItemPl,{"CNB_CC", cABSCusto,      NIL})
									EndIf
									If lGsISS .AND. !lOrcPrc
										Aadd(aItemPl,{"CNB_PRODSV", aPrdsRH[nPrd,1],NIL})
										cCodISS := TECBGetISS(aPrdsRH[nPrd,1])
										If !EMPTY(cCodISS)
											If (nAux := ASCAN(aIDPeds, {|s| s[2] == cCodISS})) == 0
												AADD(aIDPeds, {Soma1(cValToChar(LEN(aIDPeds))),cCodISS})
												Aadd(aItemPl,{"CNB_IDPED", aIDPeds[LEN(aIDPeds)][1], NIL})
											Else
												Aadd(aItemPl,{"CNB_IDPED", aIDPeds[nAux][1], NIL})
											EndIf
										EndIf
									EndIf
									If lTecEntCtb
										Aadd(aItemPl,{"CNB_CONTA" , cABSConta, NIL})
										Aadd(aItemPl,{"CNB_ITEMCT", cABSItem,  NIL})										
										Aadd(aItemPl,{"CNB_CLVL"  , cABSClvl,  NIL})
									Endif
									Aadd(aItensPl, aItemPl)
									A850AtItCNB('TFF',aPrdsRH[nPrd,4],'TFF_ITCNB',cItem)
									cItemTFF	:= cItem
								EndIf
							Next nPrd
						EndIf
					EndIf
					If TFL->TFL_TOTMI > 0
						// verifica se � o mesmo produto, quando n�o for ir� adicionar nova linha
						If ( nItSomar := aScan( aItensPl, {|x| x[4][2]==TFJ->TFJ_GRPMI } ) ) > 0
							aItensPl[nItSomar][6][2] += TFL->TFL_TOTMI
						Else
							If !lDsgCN
									aItemPl	:=	{}
									cItem		:=	SOMA1(cItem)
									Aadd(aItemPl,{"CNB_FILIAL", xFilial("CNB"), NIL})
									Aadd(aItemPl,{"CNB_NUMERO", cNumero,        NIL})
									Aadd(aItemPl,{"CNB_ITEM",   cItem,          NIL})
									Aadd(aItemPl,{"CNB_PRODUT", TFJ->TFJ_GRPMI, NIL})
									Aadd(aItemPl,{"CNB_QUANT",  1,              NIL})
									Aadd(aItemPl,{"CNB_VLUNIT", TFL->TFL_TOTMI, NIL})
									Aadd(aItemPl,{"CNB_TS",     TFJ->TFJ_TESMI, NIL})
									Aadd(aItemPl,{"CNB_PEDTIT", cPedTit,        NIL})
									If lInsereCC
										Aadd(aItemPl,{"CNB_CC", cABSCusto,      NIL})
									EndIf
									If lTecEntCtb
										Aadd(aItemPl,{"CNB_CONTA" , cABSConta, NIL})
										Aadd(aItemPl,{"CNB_ITEMCT", cABSItem,	NIL})										
										Aadd(aItemPl,{"CNB_CLVL"  , cABSClvl,	NIL})
									Endif
									Aadd(aItensPl, aItemPl)
							Else
								aPrdsMI := GetPrdCTR(aLocal[nCont,1],aLocal[nCont,2	], "MI",TFJ->TFJ_CODIGO)
								For nPrd := 1 To Len(aPrdsMI)
									If aPrdsMI[nPrd][3] > 0
										aItemPl	:=	{}
										cItem		:=	SOMA1(cItem)
										Aadd(aItemPl,{"CNB_FILIAL", xFilial("CNB"), NIL})
										Aadd(aItemPl,{"CNB_NUMERO", cNumero,        NIL})
										Aadd(aItemPl,{"CNB_ITEM",   cItem,          NIL})
										Aadd(aItemPl,{"CNB_PRODUT", aPrdsMI[nPrd,1], NIL})
										Aadd(aItemPl,{"CNB_QUANT",  aPrdsMI[nPrd,2],NIL})
										Aadd(aItemPl,{"CNB_VLUNIT", aPrdsMI[nPrd,3], NIL})
										Aadd(aItemPl,{"CNB_TS",     aPrdsMI[nPrd,5], NIL})
										Aadd(aItemPl,{"CNB_PEDTIT", cPedTit,        NIL})
										If lInsereCC
											Aadd(aItemPl,{"CNB_CC", cABSCusto,      NIL})
										EndIf
										If LEN(aPrdsMI[nPrd]) >= 6 .AND. lGsISS .AND. !lOrcPrc
											Aadd(aItemPl,{"CNB_PRODSV", aPrdsMI[nPrd,6],        NIL})
											cCodISS := TECBGetISS(aPrdsMI[nPrd,6])
											If !EMPTY(cCodISS)
												If (nAux := ASCAN(aIDPeds, {|s| s[2] == cCodISS})) == 0
													AADD(aIDPeds, {Soma1(cValToChar(LEN(aIDPeds))),cCodISS})
													Aadd(aItemPl,{"CNB_IDPED", aIDPeds[LEN(aIDPeds)][1], NIL})
												Else
													Aadd(aItemPl,{"CNB_IDPED", aIDPeds[nAux][1], NIL})
												EndIf
											EndIf
										EndIf
										If lTecEntCtb
											Aadd(aItemPl,{"CNB_CONTA" , cABSConta, NIL})
											Aadd(aItemPl,{"CNB_ITEMCT", cABSItem,  NIL})										
											Aadd(aItemPl,{"CNB_CLVL"  , cABSClvl,  NIL})
										Endif
										A850AtItCNB('TFG',aPrdsMI[nPrd,4],'TFG_ITCNB',cItem)
										Aadd(aItensPl, aItemPl)
									EndIf
								Next nI
							EndIf
						EndIf
						cItemTFG	:= cItem
						// caso n�o tenha valor mas o produto refer�ncia para o conceito de produto seja o mesmo usa o item para vincular
						// e permitir adicionar os itens posteriormente
					ElseIf ( nItSomar := aScan( aItensPl, {|x| x[4][2]==TFJ->TFJ_GRPMI } ) ) > 0
						cItemTFG	:= aItensPl[nItSomar][3][2]
					EndIf
					If TFL->TFL_TOTMC > 0
						// verifica se � o mesmo produto, quando n�o for ir� adicionar nova linha
						If ( nItSomar := aScan( aItensPl, {|x| x[4][2]==TFJ->TFJ_GRPMC } ) ) > 0
							aItensPl[nItSomar][6][2] += TFL->TFL_TOTMC
						Else
							aItemPl	:=	{}
							If !lDsgCN
								cItem	:=	SOMA1(cItem)
								Aadd(aItemPl,{"CNB_FILIAL", xFilial("CNB"), NIL})
								Aadd(aItemPl,{"CNB_NUMERO", cNumero,        NIL})
								Aadd(aItemPl,{"CNB_ITEM",   cItem,          NIL})
								Aadd(aItemPl,{"CNB_PRODUT", TFJ->TFJ_GRPMC, NIL})
								Aadd(aItemPl,{"CNB_QUANT",  1,              NIL})
								Aadd(aItemPl,{"CNB_VLUNIT", TFL->TFL_TOTMC, NIL})
								Aadd(aItemPl,{"CNB_TS",     TFJ->TFJ_TESMC, NIL})
								Aadd(aItemPl,{"CNB_PEDTIT", cPedTit,        NIL})
								If lInsereCC
									Aadd(aItemPl,{"CNB_CC", cABSCusto,      NIL})
								EndIf
								If lTecEntCtb
									Aadd(aItemPl,{"CNB_CONTA" , cABSConta, NIL})
									Aadd(aItemPl,{"CNB_ITEMCT", cABSItem,	NIL})										
									Aadd(aItemPl,{"CNB_CLVL"  , cABSClvl,	NIL})
								Endif
								Aadd(aItensPl, aItemPl)
							Else
								aPrdsMC := GetPrdCTR(aLocal[nCont,1],aLocal[nCont,2	], "MC",TFJ->TFJ_CODIGO)
								For nPrd := 1 To Len(aPrdsMC)
									If aPrdsMC[nPrd,3] > 0
										cItem	:=	SOMA1(cItem)
										aItemPl	:=	{}
										Aadd(aItemPl,{"CNB_FILIAL", xFilial("CNB"), NIL})
										Aadd(aItemPl,{"CNB_NUMERO", cNumero,        NIL})
										Aadd(aItemPl,{"CNB_ITEM",   cItem,          NIL})
										Aadd(aItemPl,{"CNB_PRODUT", aPrdsMC[nPrd,1], NIL})
										Aadd(aItemPl,{"CNB_QUANT",  aPrdsMC[nPrd,2], NIL})
										Aadd(aItemPl,{"CNB_VLUNIT", aPrdsMC[nPrd,3], NIL})
										Aadd(aItemPl,{"CNB_TS",     aPrdsMC[nPrd,5], NIL})
										Aadd(aItemPl,{"CNB_PEDTIT", cPedTit,        NIL})
										If lInsereCC
											Aadd(aItemPl,{"CNB_CC", cABSCusto,      NIL})
										EndIf
										If LEN(aPrdsMC[nPrd]) >= 6 .AND. lGsISS .AND. !lOrcPrc 
											Aadd(aItemPl,{"CNB_PRODSV", aPrdsMC[nPrd,6],        NIL})
											cCodISS := TECBGetISS(aPrdsMC[nPrd,6])
											If !EMPTY(cCodISS)
												If (nAux := ASCAN(aIDPeds, {|s| s[2] == cCodISS})) == 0
													AADD(aIDPeds, {Soma1(cValToChar(LEN(aIDPeds))),cCodISS})
													Aadd(aItemPl,{"CNB_IDPED", aIDPeds[LEN(aIDPeds)][1], NIL})
												Else
													Aadd(aItemPl,{"CNB_IDPED", aIDPeds[nAux][1], NIL})
												EndIf
											EndIf
										EndIf
										If lTecEntCtb
											Aadd(aItemPl,{"CNB_CONTA" , cABSConta, NIL})
											Aadd(aItemPl,{"CNB_ITEMCT", cABSItem,	NIL})										
											Aadd(aItemPl,{"CNB_CLVL"  , cABSClvl,	NIL})
										Endif
										A850AtItCNB('TFH',aPrdsMC[nPrd,4],'TFH_ITCNB',cItem)
										Aadd(aItensPl, aItemPl)
									EndIf
								Next nProd
							EndIf
						EndIf
						cItemTFH	:= cItem
						// caso n�o tenha valor mas o produto refer�ncia para o conceito de produto seja o mesmo usa o item para vincular
						// e permitir adicionar os itens posteriormente
					ElseIf ( nItSomar := aScan( aItensPl, {|x| x[4][2]==TFJ->TFJ_GRPMC } ) ) > 0
						cItemTFH	:= aItensPl[nItSomar][3][2]
					EndIf
					If TFL->TFL_TOTLE > 0
						// verifica se � o mesmo produto, quando n�o for ir� adicionar nova linha
						If ( nItSomar := aScan( aItensPl, {|x| x[4][2]==TFJ->TFJ_GRPLE } ) ) > 0
							aItensPl[nItSomar][6][2] += TFL->TFL_TOTLE
						Else
							aItemPl	:=	{}
							If !lDsgCN
								cItem	:=	SOMA1(cItem)
								Aadd(aItemPl,{"CNB_FILIAL", xFilial("CNB"), NIL})
								Aadd(aItemPl,{"CNB_NUMERO", cNumero,        NIL})
								Aadd(aItemPl,{"CNB_ITEM",   cItem,          NIL})
								Aadd(aItemPl,{"CNB_PRODUT", TFJ->TFJ_GRPLE, NIL})
								Aadd(aItemPl,{"CNB_QUANT",  1,              NIL})
								Aadd(aItemPl,{"CNB_VLUNIT", TFL->TFL_TOTLE, NIL})
								Aadd(aItemPl,{"CNB_TS",     TFJ->TFJ_TESLE, NIL})
								Aadd(aItemPl,{"CNB_PEDTIT", cPedTit,        NIL})
								If lInsereCC
									Aadd(aItemPl,{"CNB_CC", cABSCusto,      NIL})
								EndIf
								If lTecEntCtb
									Aadd(aItemPl,{"CNB_CONTA" , cABSConta, NIL})
									Aadd(aItemPl,{"CNB_ITEMCT", cABSItem,	NIL})										
									Aadd(aItemPl,{"CNB_CLVL"  , cABSClvl,	NIL})
								Endif
								Aadd(aItensPl, aItemPl)
							Else
								aPrdsLE := GetPrdCTR(aLocal[nCont,1],aLocal[nCont,2	], "LE",TFJ->TFJ_CODIGO)
								For nPrd := 1 To Len(aPrdsLE)
									If aPrdsLE[nPrd,3] > 0
										cItem	:=	SOMA1(cItem)
										aItemPl	:=	{}
										Aadd(aItemPl,{"CNB_FILIAL", xFilial("CNB"), NIL})
										Aadd(aItemPl,{"CNB_NUMERO", cNumero,        NIL})
										Aadd(aItemPl,{"CNB_ITEM",   cItem,          NIL})
										Aadd(aItemPl,{"CNB_PRODUT", aPrdsLE[nPrd,1], NIL})
										Aadd(aItemPl,{"CNB_QUANT",  aPrdsLE[nPrd,2], NIL})
										Aadd(aItemPl,{"CNB_VLUNIT", aPrdsLE[nPrd,3], NIL})
										Aadd(aItemPl,{"CNB_TS",     aPrdsLE[nPrd,5], NIL})
										Aadd(aItemPl,{"CNB_PEDTIT", cPedTit,        NIL})
										If lInsereCC
											Aadd(aItemPl,{"CNB_CC", cABSCusto,      NIL})
										EndIf
										If lTecEntCtb
											Aadd(aItemPl,{"CNB_CONTA" , cABSConta, NIL})
											Aadd(aItemPl,{"CNB_ITEMCT", cABSItem,	NIL})										
											Aadd(aItemPl,{"CNB_CLVL"  , cABSClvl,	NIL})
										Endif
										Aadd(aItensPl, aItemPl)
										A850AtItCNB('TFI',aPrdsLE[nPrd,4],'TFI_ITCNB',cItem)
									EndIF
								Next nProd

							EndIf
						EndIf
						cItemTFI	:= cItem
						// caso n�o tenha valor mas o produto refer�ncia para o conceito de produto seja o mesmo usa o item para vincular
						// e permitir adicionar os itens posteriormente
					ElseIf ( nItSomar := aScan( aItensPl, {|x| x[4][2]==TFJ->TFJ_GRPLE } ) ) > 0
						cItemTFI	:= aItensPl[nItSomar][3][2]
					EndIf

					If lSomaImp
						aItensPl[1,6,2] += TFL->TFL_TOTIMP // adiciona o valor ao total unit�rio do item
					EndIf
					Aadd(aTdItem,aItensPl)
					// se a gera��o deve acontecer com os itens agrupados no contrato
					If !lDsgCN .And. ( Empty(cItemTFF) .Or. Empty(cItemTFG) .Or. Empty(cItemTFH) .Or. Empty(cItemTFI) )
						// quando existir algum item n�o preenchido, verifica se o produto refer�ncia no cabe�alho � o mesmo
						// isso � importante pois se o item n�o estiver preenchido na TFL e o produto for o mesmo
						//  ter� problemas na revis�o, pois uma linha na CNB deveria ser alterada e n�o criada
						// RH
						If !Empty(cItemTFF)
							If Empty(cItemTFG) .And. TFJ->TFJ_GRPRH == TFJ->TFJ_GRPMI
								cItemTFG := cItemTFF
							EndIf
							If Empty(cItemTFH) .And. TFJ->TFJ_GRPRH == TFJ->TFJ_GRPMC
								cItemTFH := cItemTFF
							EndIf
							If Empty(cItemTFI) .And. TFJ->TFJ_GRPRH == TFJ->TFJ_GRPLE
								cItemTFI := cItemTFF
							EndIf
						EndIf
						// MC
						If !Empty(cItemTFG)
							If Empty(cItemTFF) .And. TFJ->TFJ_GRPMI == TFJ->TFJ_GRPRH
								cItemTFF := cItemTFG
							EndIf
							If Empty(cItemTFH) .And. TFJ->TFJ_GRPMI == TFJ->TFJ_GRPMC
								cItemTFH := cItemTFG
							EndIf
							If Empty(cItemTFI) .And. TFJ->TFJ_GRPMI == TFJ->TFJ_GRPLE
								cItemTFI := cItemTFG
							EndIf
						EndIf
						// MI
						If !Empty(cItemTFH)
							If Empty(cItemTFF) .And. TFJ->TFJ_GRPMC == TFJ->TFJ_GRPRH
								cItemTFF := cItemTFH
							EndIf
							If Empty(cItemTFG) .And. TFJ->TFJ_GRPMC == TFJ->TFJ_GRPMI
								cItemTFG := cItemTFH
							EndIf
							If Empty(cItemTFI) .And. TFJ->TFJ_GRPMC == TFJ->TFJ_GRPLE
								cItemTFI := cItemTFH
							EndIf
						EndIf
						// LE
						If !Empty(cItemTFI)
							If Empty(cItemTFF) .And. TFJ->TFJ_GRPLE == TFJ->TFJ_GRPRH
								cItemTFF := cItemTFI
							EndIf
							If Empty(cItemTFG) .And. TFJ->TFJ_GRPLE == TFJ->TFJ_GRPMI
								cItemTFG := cItemTFI
							EndIf
							If Empty(cItemTFH) .And. TFJ->TFJ_GRPLE == TFJ->TFJ_GRPMC
								cItemTFH := cItemTFI
							EndIf
						EndIf

					EndIf

				EndIf
				aAdd(aItLocal, {cCodLocal, cNumero, {cItemTFF, cItemTFG, cItemTFH, cItemTFI} })//inclui referencia para o local

				cNumero	:= SOMA1(cNumero)
			Next nCont

		//Verifica qtd de recorrencia para assistente de manuten��o de contratos
		ElseIf nQuantRec > 0

			Aadd(aClien,{"CNC_CLIENT", TFJ->TFJ_CODENT, NIL})
			Aadd(aClien,{"CNC_LOJACL", TFJ->TFJ_LOJA,  NIL})
			Aadd(aTdClient, aClone(aClien))
			Aadd( aHeader, { "CNA_QTDREC", nQuantRec, NIL } )
			Aadd(aTdHeader,aHeader)

			lRecor	:= TFJ->TFJ_CNTREC == '1'
			lVigente := IIF(CN9->CN9_SITUAC == '02', .F., lVigente)	//Verifica se o contrato possui situa��o igual elabora��o

		EndIf

		DbSelectArea("TFI")
		DbSetOrder(3)	//TFI_FILIAL+TFI_CODPAI

		DbSelectArea("TFF")
		DbSetOrder(3)	//TFF_FILIAL+TFF_CODPAI

		DbSelectArea("TFG")
		DbSetOrder(3)	//TFG_FILIAL+TFG_CODPAI

		DbSelectArea("TFH")
		DbSetOrder(3)	//TFH_FILIAL+TFH_CODPAI

		For nX := 1 to Len(aItLocal)

			aItemRH	:=	{}
			// Guarda os valores de cada produto e sua rela��o com a planilha e o item da planilha, que ser� utilizado para ativa��o do local de atendimento
			If TFI->(DbSeek(xFilial("TFI") + aItLocal[nX][1]))
				While TFI->(! Eof()) .And. TFI->TFI_FILIAL == xFilial("TFI") .And. TFI->TFI_CODPAI == aItLocal[nX][1]
					Aadd(aItLcPl,{TFI->TFI_COD, aItLocal[nX][2]}) //guarda o valor da planilha e item da planilha referente ao produtorh

					TFI->(DbSkip())
				EndDo
			EndIf

			If TFF->(DbSeek(xFilial("TFF") + aItLocal[nX][1]))
				While TFF->(! Eof()) .And. TFF->TFF_FILIAL == cFilTFF .And. TFF->TFF_CODPAI == aItLocal[nX][1]
					Aadd(aItRhPl,{(cAliasTFF)->TFF_COD, aItLocal[nX][2]}) //guarda o valor da planilha e item da planilha referente ao produtorh

					Aadd(aItemRH,{ (cAliasTFF)->TFF_PRODUT	,; //ITEMRH_PRODUT
									(cAliasTFF)->TFF_CARGO	,;	//ITEMRH_CARGO
									(cAliasTFF)->TFF_FUNCAO	,; 	//ITEMRH_FUNCAO
									(cAliasTFF)->TFF_PERINI	,; 	//ITEMRH_PERINI
									(cAliasTFF)->TFF_PERFIM	,;	//ITEMRH_PERFIM
									(cAliasTFF)->TFF_TURNO	,; 	//ITEMRH_TURNO
									(cAliasTFF)->TFF_QTDVEN	,; 	//ITEMRH_QTD
									(cAliasTFF)->TFF_COD,; 		//ITEMRH_CODTFF
									If( lSeqTrn, (cAliasTFF)->TFF_SEQTRN, ""),;//	ITEMRH_SEQTRN
									.T. ,; // ITEMRH_RECLOC
									(cAliasTFF)->TFF_FILIAL,;//ITEMRH_FILTFF
									{},;
									IF(lPrHora, TecConvHr((cAliasTFF)->TFF_QTDHRS), 0),;
									""})
									// Intergracao Find-me
									If lFindMe .And. !lCliFindMe
										lCliFindMe := (cAliasTFF)->TFF_FINDME == "1"
									EndIf
					If !lOrcPrc
						If TFG->(DbSeek(xFilial("TFG") + (cAliasTFF)->TFF_COD))
							While TFG->(! Eof())  .And. TFG->TFG_FILIAL == cFilTFG .And. TFG->TFG_CODPAI == (cAliasTFF)->TFF_COD
								Aadd(aItMtImp,{(cAliasTFG)->TFG_COD, aItLocal[nX][2]}) //guarda o valor da planilha e item da planilha referente ao produtorh

								TFG->(DbSkip())
							EndDo
						EndIf

						If TFH->(DbSeek(xFilial("TFH") + (cAliasTFF)->TFF_COD))
							While TFH->(! Eof()) .And. TFH->TFH_FILIAL == cFilTFH .And. TFH->TFH_CODPAI == (cAliasTFF)->TFF_COD
								Aadd(aItMtCns,{(cAliasTFH)->TFH_COD, aItLocal[nX][2]}) //guarda o valor da planilha e item da planilha referente ao produtorh

								TFH->(DbSkip())
							EndDo
						EndIf

						If lGsOrcUnif 
							DbSelectArea("TXP")
							TXP->(DbSetOrder(2))	//TXP_FILIAL+TXP_CODTFF
							If TXP->(DbSeek(xFilial("TXP") + (cAliasTFF)->TFF_COD))
								While TXP->(! Eof()) .And. TXP->TXP_FILIAL == xFilial("TXP") .And. TXP->TXP_CODTFF == (cAliasTFF)->TFF_COD
									Aadd(aItUnif,{TXP->TXP_CODIGO, aItLocal[nX][2]}) //Guarda o codigo da TXP e codigo do local
									TXP->(DbSkip())
								EndDo
							EndIf								
						EndIf

						If lGsOrcArma 
							DbSelectArea("TXQ")
							TXQ->(DbSetOrder(2))	//TXQ_FILIAL+TXQ_CODTFF
							If TXQ->(DbSeek(xFilial("TXQ") + (cAliasTFF)->TFF_COD))
								While TXQ->(! Eof()) .And. TXQ->TXQ_FILIAL == xFilial("TXQ") .And. TXQ->TXQ_CODTFF == (cAliasTFF)->TFF_COD
									Aadd(aItArm,{TXQ->TXQ_CODIGO, aItLocal[nX][2]}) //Guarda o codigo da TXQ e codigo do local
									TXQ->(DbSkip())
								EndDo
							EndIf								
						EndIf

					EndIf
					TFF->(DbSkip())
				EndDo

			EndIf

			If lOrcPrc
				If TFG->(DbSeek(xFilial("TFG") + aItLocal[nX][1]))
					While TFG->(! Eof()) .And. TFG->TFG_FILIAL == cFilTFG .And. TFG->TFG_CODPAI == aItLocal[nX][1]
						Aadd(aItMtImp,{(cAliasTFG)->TFG_COD, aItLocal[nX][2]}) //guarda o valor da planilha e item da planilha referente ao produtorh

						TFG->(DbSkip())
					EndDo
				EndIf

				If TFH->(DbSeek(xFilial("TFH") + aItLocal[nX][1]))
					While TFH->(! Eof()) .And. TFH->TFH_FILIAL == cFilTFH .And. TFH->TFH_CODPAI == aItLocal[nX][1]
						Aadd(aItMtCns,{(cAliasTFH)->TFH_COD, aItLocal[nX][2]}) //guarda o valor da planilha e item da planilha referente ao produtorh

						TFH->(DbSkip())
					EndDo
				EndIf
			EndIf

			At850CnfAlc(aInfo[nPosNumero][2],aLocal[nX][2],aItemRH,,,!lTFJ,TFJ->TFJ_CNTREC == "1" )

		Next nX

		Aadd(aItXPl,{aItLcPl, aItRhPl, aItMtImp, aItMtCns, aItLocal, aItUnif, aItArm })

		aLocais	:=	At850PropLoc(xFilial("CN9"), cProposta, cRevisao, .F. /*lFilLocZero*/,cCodOrc) //recebe locais de atendimento.
		If nPosNumero <> 0 
			At850AtvLocAtnd(aInfo[nPosNumero][2], ""/*Revis�o do Contrato*/, aLocais, cProposta, cRevisao,cCodTFJ)//Ativa locais de atendimento
		else
			At850AtvLocAtnd(cNrCont, ""/*Revis�o do Contrato*/, aLocais, cProposta, cRevisao,cCodTFJ)//Ativa locais de atendimento
		EndIf

		//Informa o Vendedor configurado na oportunidade para fins de comiss�o
		If !lHasOrcSim
			aTdVend := At850Comiss(ADY->ADY_VEND, cCodCli, cLjCli, lComisPorTime)
			lRetorno := At850GCTCr(aInfo, aTdClient, aTdHeader, aTdItem, aTdVend, oModel, cTpPl,lVigente, lRecor) //Fun��o para gerar planilha
		Else
			aTdVend := At850Comiss(IIF(TFJ->TFJ_ORCSIM == '2', ADY->ADY_VEND, TFJ->TFJ_VEND), cCodCli, cLjCli, lComisPorTime)
			lRetorno := At850GCTCr(aInfo, aTdClient, aTdHeader, aTdItem, aTdVend, oModel, cTpPl,lVigente, lRecor, lCtVigente) //Fun��o para gerar planilha
		EndIf
	Else

		lRetorno := .F.

	EndIf
EndIf

If !lRetorno
	aItLocal := {}
Else
	If lCliFindMe
		// Integra��o Find-me
		At850Findme(TFJ->TFJ_CODENT,TFJ->TFJ_LOJA)
	EndIf
EndIf

RestArea(aArea)
Return lRetorno

//------------------------------------------------------------------------------
/*/{Protheus.doc} At850Findme

@since	06/12/2022
@author	flavio.vicco
@description Integracao Find-me
/*/
//------------------------------------------------------------------------------
Static Function At850Findme(cCodCLi, cLoja)
Local oGsFindMe	:= GsFindMe():new()
Local lAuth		:= oGsFindMe:lAuth
Local aPost		:= {}
Local aLogs		:= {}

DbSelectArea("SA1")
SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
If lAuth .And. SA1->(DbSeek(xfilial("SA1")+cCodCLi+cLoja)) 
	If oGsFindMe:canAddClient(cCodCLi, xfilial("SA1"), cLoja)
		AADD(aPost,{"codigo",SA1->A1_COD})
		AADD(aPost,{"filial",SA1->A1_FILIAL})
		AADD(aPost,{"loja",SA1->A1_LOJA})
		AADD(aPost,{"descricao",SA1->A1_NOME})
		AADD(aPost,{"name",SA1->A1_NREDUZ})
		AADD(aLogs,aPost)
		If oGsFindMe:addClient(aPost)
			// Geracao dos Logs
			TECLOGFME(aLogs)
		EndIf
	EndIf
EndIf
Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850AtDat

Captura os valores das datas
@author Servi�os
@since 31/10/13
@version P11 R9
@param cOport:Oportunidade de Venda do Contrato
@param dDtIni:Data Inicial do Contrato
@param dDtFim:Data Final do Contrato
@return  .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At850AtDat(cOport, dDtIni, dDtFim)

Local aArea	:= GetArea()
Local aDatas	:= {}
Local dDatVig

dDatVig := (dDtFim - dDtIni+1)
Aadd(aDatas,	dDatVig)

RestArea(aArea)
Return aDatas

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850PropLoc
Verifica quantos Locais de atendimento tem para a proposta comercial, para definir a quantidade de planilhas que devem ser criadas e os valores que deve ter atribuido ao produto na planilha.
@param		cFilProp:Filial da Proposta
@param		cPropCont:Proposta Comercial do Contrato
@param		cRevisao:Revis�o da proposta
@return	.T.
@author	Servi�os
@since		31/10/13
@version	P11 R9
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At850PropLoc(cFilProp, cPropCont, cRevisao, lFilLocZero, cCodOrc)

Local aArea		:= GetArea()
lOCAL aLocais		:= {}
Local cQuery		:= ""
Local nValARM       := 0
Local nValUNI       := 0
Local lGsOrcUnif 		:= FindFunction("TecGsUnif") .And. TecGsUnif()
Local lGsOrcArma 		:= FindFunction("TecGsArma") .And. TecGsArma()
Local cAliasTFJ	:= GetNextAlias()
Local lHasOrcSim := HasOrcSimp()

Default lFilLocZero := .T.

If lGsOrcArma
	nValARM := At850TAR(cCodOrc)
Endif

If lGsOrcUnif
	nValUNI := At850TUN(cCodOrc)
Endif	

If !lHasOrcSim
	cQuery	:= "SELECT TFL_CODIGO, TFL_LOCAL, TFL.TFL_TOTRH, TFL.TFL_TOTMI, TFL.TFL_TOTMC,"
	cQuery	+= 		" TFL.TFL_TOTLE, ABS1.ABS_CCUSTO, ABS1.R_E_C_N_O_ ABSRECNO, TFL.TFL_DTINI, TFL.TFL_DTFIM "
	cQuery	+= "FROM " + RetSQLName("TFJ") + " TFJ "
	cQuery	+= 	"INNER JOIN " + RetSQLName("TFL") + " TFL ON TFL.TFL_FILIAL = '"+xFilial("TFL")+"' "
	cQuery	+=                                          "AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO "
	cQuery	+=                                          "AND TFL.D_E_L_E_T_ = ' ' "
	cQuery	+=	"INNER JOIN "+RetSQLName("ABS")+" ABS1 ON ABS_FILIAL = '"+xFilial("ABS")+"' "
	cQuery	+=								"AND ABS_LOCAL = TFL_LOCAL "
	cQuery	+=								"AND ABS1.D_E_L_E_T_=' ' "
	cQuery	+=  "WHERE TFJ.TFJ_FILIAL = '" + cFilProp + "' "
	cQuery	+=    "AND TFJ.TFJ_PROPOS = '" + cPropCont + "' "
	cQuery	+=    "AND TFJ.TFJ_PREVIS = '" + cRevisao + "' "
	cQuery	+=    "AND TFJ.D_E_L_E_T_ = ' ' "
Else
	cQuery	:= "SELECT TFL_CODIGO, TFL_LOCAL, TFL.TFL_TOTRH, TFL.TFL_TOTMI, TFL.TFL_TOTMC,"
	cQuery	+= 		" TFL.TFL_TOTLE, ABS1.ABS_CCUSTO, ABS1.R_E_C_N_O_ ABSRECNO, TFL.TFL_DTINI, TFL.TFL_DTFIM "
	cQuery	+= "FROM " + RetSQLName("TFJ") + " TFJ "
	cQuery	+= 	"INNER JOIN " + RetSQLName("TFL") + " TFL ON TFL.TFL_FILIAL = '"+xFilial("TFL")+"' "
	cQuery	+=                                          "AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO "
	cQuery	+=                                          "AND TFL.D_E_L_E_T_ = ' ' "
	cQuery	+=	"INNER JOIN "+RetSQLName("ABS")+" ABS1 ON ABS_FILIAL = '"+xFilial("ABS")+"' "
	cQuery	+=								"AND ABS_LOCAL = TFL_LOCAL "
	cQuery	+=								"AND ABS1.D_E_L_E_T_=' ' "
	cQuery	+=  "WHERE TFJ.TFJ_FILIAL = '" + cFilProp + "' "
	If lTecA745
		cQuery	+=  "AND TFJ.TFJ_CODIGO = '" + cCodOrc + "' "
	Else
		If POSICIONE("TFJ",1,xFilial("TFJ")+cCodOrc,"TFJ_ORCSIM") == "1"
			cQuery	+=  "AND TFJ.TFJ_CODIGO = '"+cCodOrc+"' "
		Else
	cQuery	+=    "AND TFJ.TFJ_PROPOS = '" + cPropCont + "' "
	cQuery	+=    "AND TFJ.TFJ_PREVIS = '" + cRevisao + "' "
		EndIf
	EndIf
	cQuery	+=    "AND TFJ.D_E_L_E_T_ = ' ' "
EndIf

If lFilLocZero
	cQuery	+=  "GROUP BY TFL_CODIGO, TFL_LOCAL, TFL.TFL_TOTRH, TFL.TFL_TOTMI, TFL.TFL_TOTMC, TFL.TFL_TOTLE, ABS1.ABS_CCUSTO, ABS1.R_E_C_N_O_,"
	cQuery	+=  		" TFL.TFL_DTINI, TFL.TFL_DTFIM "
	If nValARM + nValUNI == 0
		cQuery	+=  "HAVING ( TFL_TOTRH + TFL_TOTMI + TFL_TOTMC + TFL_TOTLE ) > 0 "
	Endif
EndIf

cQuery	:= ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cAliasTFJ, .T., .T.)

TCSetField(cAliasTFJ,"TFL_DTINI","D")
TCSetField(cAliasTFJ,"TFL_DTFIM","D")

While (cAliasTFJ)->(! EOF())
	aAdd( aLocais, { (cAliasTFJ)->TFL_CODIGO,;
					(cAliasTFJ)->TFL_LOCAL,;
					(cAliasTFJ)->ABS_CCUSTO,;
					(cAliasTFJ)->ABSRECNO,;
					(cAliasTFJ)->TFL_DTINI,;
					(cAliasTFJ)->TFL_DTFIM } )
	(cAliasTFJ)->(DbSkip())
EndDo
(cAliasTFJ)->(DbCloseArea())
RestArea(aArea)
Return aLocais

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850CnfAlc
Configura��o da aloca��o
@author Servi�os
@since 31/10/13
@version P11 R9
@param cContr:N�mero do Contrato
@param cLocal:Local de Atendimento
@param aItemRH:Itens de recursos humanos, material operacional e material de consumo
@return  .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At850CnfAlc(cContr,cLocal,aItemRH,oDlg,oMeter, lConsRec, lContrRec)

Local lRet			:= .T.
Local lRecLock	:= .T.
Local aArea		:= GetArea()
Local cAliasABQ	:= "ABQ"
Local cItem		:= ""
Local cTurno	:= ""
Local cAliasQRY	:= ""
Local cQuery	:= ""
Local nCont		:= 0
Local nTotHrsEst	:= 0
Local dDataIni
Local dDataFim

Default oDlg := nil
Default oMeter := nil
Default lConsRec := .T. 
Default lContrRec := .F.

DbSelectArea(cAliasABQ)
DbSetOrder(1)

For nCont	:= 1 To Len(aItemRH)

	dDataIni	:= aItemRH[nCont][ITEMRH_PERINI]
 	dDataFim	:= aItemRH[nCont][ITEMRH_PERFIM]
 	cTurno		:= aItemRH[nCont][ITEMRH_TURNO]
 	cSeqTrn	:= If(Empty(aItemRH[nCont][ITEMRH_SEQTRN]), "01", aItemRH[nCont][ITEMRH_SEQTRN])

	nTotHrsEst	:= 0
	lRecLock	:= .T.

	If Len(aItemRH[nCont]) >= ITEMRH_RECLOC .And. ValType(aItemRH[nCont,ITEMRH_RECLOC]) == "L"
		lRecLock := aItemRH[nCont,ITEMRH_RECLOC]
	EndIf

	If lRecLock
		If Empty(cItem)
			cAliasQRY := GetNextAlias()

			cQuery := ""
			cQuery += " SELECT Max(ABQ.ABQ_ITEM) ITEM "
			cQuery += " FROM " + RetSqlName("ABQ") + " ABQ "
			cQuery += " WHERE "
			cQuery += " ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "' "
			cQuery += " AND ABQ.ABQ_CONTRT = '" + cContr + "' "
			cQuery += " AND ABQ.D_E_L_E_T_ = ' ' "

			cQuery		:= ChangeQuery(cQuery)
			DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cAliasQRY, .T., .T.)

			If !(cAliasQRY)->(EOF())
				cItem := (cAliasQry)->ITEM
			EndIf

			(cAliasQry)->(DbCloseArea())
		EndIf
		
		cItem := SOMA1(cItem)
	Else
		ABQ->(DbSetOrder(3))//ABQ_FILIAL+ABQ_CODTFF+ABQ_FILTFF
		ABQ->(DbSeek(xFilial("ABQ")+aItemRH[nCont][ITEMRH_CODTFF] + aItemRH[nCont][ITEMRH_FILTFF]))
	EndIf
	
	//Contrato n�o � recorrente, ent�o atualiza o saldo de horas trabalhadas
	If (lConsRec .and. At740Recor(cContr) ) .OR. (!lConsRec .and. !lContrRec)
		If  aItemRH[nCont][ITEMRH_QTDHRS] == 0
			nTotHrsEst := At850GtHr(cContr, aItemRH[nCont], lRecLock, cSeqTrn, cTurno, dDataIni,dDataFim)
		Else
			nTotHrsEst := aItemRH[nCont][ITEMRH_QTDHRS]
		EndIf
	EndIf

	RecLock( cAliasABQ, lRecLock )
	ABQ->ABQ_FILIAL	:=	xFilial("ABQ")
	ABQ->ABQ_CONTRT	:=	cContr
	If lRecLock
		ABQ->ABQ_ITEM	:= cItem
	EndIf
	ABQ->ABQ_PRODUT	:=	aItemRH[nCont][ITEMRH_PRODUT]
	ABQ->ABQ_TPPROD	:=	"2"
	ABQ->ABQ_TPREC	:=	"1"
	ABQ->ABQ_CARGO	:= aItemRH[nCont][ITEMRH_CARGO]
	ABQ->ABQ_FUNCAO	:= aItemRH[nCont][ITEMRH_FUNCAO]
	ABQ->ABQ_PERINI	:= aItemRH[nCont][ITEMRH_PERINI]
	ABQ->ABQ_PERFIM	:= aItemRH[nCont][ITEMRH_PERFIM]
	ABQ->ABQ_TURNO	:= aItemRH[nCont][ITEMRH_TURNO]
	ABQ->ABQ_HRSEST	:=	nTotHrsEst
	ABQ->ABQ_FATOR	:= aItemRH[nCont][ITEMRH_QTD]
	ABQ->ABQ_TOTAL	:= ABQ->ABQ_HRSEST*aItemRH[nCont][ITEMRH_QTD]
	ABQ->ABQ_SALDO	:= ABQ->ABQ_HRSEST*aItemRH[nCont][ITEMRH_QTD]
	ABQ->ABQ_ORIGEM	:=	"CN9"
	ABQ->ABQ_CODTFF	:= aItemRH[nCont][ITEMRH_CODTFF]
	ABQ->ABQ_LOCAL	:= cLocal
	ABQ->ABQ_FILTFF	:= aItemRH[nCont][ITEMRH_FILTFF]
	ABQ->(MsUnlock())
	
	If isInCallStack("copyABQ") .AND. !isBlind() .AND. oMeter != nil .AND. oDlg != nil
		oMeter:Set(nCont)
		oMeter:Refresh()
	EndIf
	
Next nCont
If isInCallStack("copyABQ") .AND. !isBlind() .AND. oMeter != nil .AND. oDlg != nil
	oDlg:End()
EndIf
RestArea(aArea)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850AtvLocAtnd
Ativa Locais de Atendimento
@author Servi�os
@since 31/10/13
@version P11 R9
@param cContr:N�mero do Contrato
@param cRevis:Revis�o do Contrato
@param aLocais:Locais de Atendimento
@param cProp:Proposta Comercial
@param cReviPr:Revis�o da Proposta
@return  .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At850AtvLocAtnd(cContr, cRevis, aLocais, cProp, cReviPr, cCodTFJ)

Local aArea			:= GetArea()
Local lRet			:= .T.
Local cAliasTFL		:= "TFL"
Local cAliasTFF		:= "TFF"
Local cAliasTFI		:= "TFI"
Local cAliasTFG		:= "TFG"
Local cAliasTFH		:= "TFH"
Local cAliasTEV		:= "TEV"
Local cAliasTFJ		:= "TFJ"
Local lGsOrcUnif 	:= FindFunction("TecGsUnif") .And. TecGsUnif()
Local lGsOrcArma 	:= FindFunction("TecGsArma") .And. TecGsArma()
Local nPos 			:= 0
Local nCont			:= 0
Local cSeekTFJ		:= ""
Local lHasOrcSim 	:= HasOrcSimp()

For nCont	:= 1 to Len(aLocais)   //Atribui � TFL o contrato e revis�o a qual ele pertence
	DbSelectArea(cAliasTFL)
	DbSetOrder(1)//TFL_FILIAL + TFL_CODIGO
	If DbSeek(xFilial(cAliasTFL) + aLocais[nCont][1])

		RecLock(cAliasTFL,.F.)
		(cAliasTFL)->TFL_CONTRT	:= cContr
		(cAliasTFL)->TFL_CONREV	:= cRevis

		//Atribui referencias as planilhas
		nPos := aScan(aItXPl[1][5], {|x|x[1]==aLocais[nCont][1]})
		If nPos > 0
			(cAliasTFL)->TFL_PLAN := aItXPl[1][5][nPos][2]//Planilha
			(cAliasTFL)->TFL_ITPLRH := aItXPl[1][5][nPos][3][1]//Item RH
			(cAliasTFL)->TFL_ITPLMI := aItXPl[1][5][nPos][3][2]//Item material implanta��o
			(cAliasTFL)->TFL_ITPLMC := aItXPl[1][5][nPos][3][3]//Item Material de Consumo
			(cAliasTFL)->TFL_ITPLLE := aItXPl[1][5][nPos][3][4]//Item Loca��o de equipamentos
		EndIf
		MsUnlock()
	EndIf
Next nCont

//Atualiza Numero de Contrato TFF
TFF->(DbSetOrder(1))//TFF_FILIAL+TFF_CODIGO
For nCont	:= 1 to Len(aItXPl[1][2])
	If TFF->(DbSeek(xFilial(cAliasTFF)+aItXPl[1][2][nCont][1]))
		RecLock(cAliasTFF,.F.)
		(cAliasTFF)->TFF_CONTRT	:= cContr
		(cAliasTFF)->TFF_CONREV	:= cRevis
		MsUnlock()
	EndIf
Next nCont

//Atualiza Numero de Contrato TFI
(cAliasTFI)->(DbSetOrder(1))//TFI_FILIAL+TFI_CODIGO
For nCont	:= 1 to Len(aItXPl[1][1])		//Atribui � TFI referente ao contrato a planilha e o item que eles est�o associados.
	If (cAliasTFI)->(DbSeek(xFilial(cAliasTFI)+aItXPl[1][1][nCont][1]))
		RecLock(cAliasTFI,.F.)
		(cAliasTFI)->TFI_CONTRT	:= cContr
		(cAliasTFI)->TFI_CONREV	:= cRevis
		MsUnlock()
	EndIf
Next nCont

DbSelectArea(cAliasTFJ)		//Atribui � TFJ o contrato e revis�o a qual ele est� relacionado.
If !lHasOrcSim
	DbSetOrder(2)
	If DbSeek(xFilial(cAliasTFJ) + cProp + cReviPr)
		RecLock(cAliasTFJ,.F.)
		(cAliasTFJ)->TFJ_CONTRT	:= cContr
		(cAliasTFJ)->TFJ_CONREV	:= cRevis
		MsUnlock()
	EndIf
Else
	If lTecA745 .OR. ( !EMPTY(cCodTFJ) .AND. POSICIONE("TFJ",1,xFilial("TFJ")+cCodTFJ,"TFJ_ORCSIM") == '1')
		(cAliasTFJ)->(DbSetOrder(1))
		cSeekTFJ := xFilial(cAliasTFJ) + cCodTFJ
	Else
		(cAliasTFJ)->(DbSetOrder(2))
		cSeekTFJ := xFilial(cAliasTFJ) + (cProp + cReviPr)
	EndIf

	If DbSeek(cSeekTFJ)
		RecLock(cAliasTFJ,.F.)
		(cAliasTFJ)->TFJ_CONTRT	:= cContr
		(cAliasTFJ)->TFJ_CONREV	:= cRevis
		MsUnlock()
	EndIf
EndIf
For nCont := 1 to Len(aItXPl[1][1])		//Atribui � TFI referente ao contrato a planilha e o item que eles est�o associados.
	DbSelectArea(cAliasTEV)
	(cAliasTEV)->(DbSetOrder(1))
	If DbSeek(xFilial(cAliasTEV)+aItXPl[1][1][nCont][1])
		While (cAliasTEV)->(!Eof())
			If (cAliasTEV)->TEV_CODLOC == aItXPl[1][1][nCont][1]
				RecLock(cAliasTEV,.F.)
				(cAliasTEV)->TEV_SLD	:= (cAliasTEV)->TEV_QTDE
				MsUnlock()
			Else
				Exit
			EndIf
			(cAliasTEV)->(DbSkip())
		EndDo
	Endif
Next nCont

For nCont	:= 1 to Len(aItXPl[1][3])	//Atribui � TFI referente ao contrato a planilha e o item que eles est�o associados.
	DbSelectArea(cAliasTFG)
	DbSetOrder(1)
	If DbSeek(xFilial(cAliasTFG) + aItXPl[1][3][nCont][1])
		RecLock(cAliasTFG,.F.)
		(cAliasTFG)->TFG_SLD	:= (cAliasTFG)->TFG_QTDVEN
		(cAliasTFG)->TFG_CONTRT	:= cContr
		(cAliasTFG)->TFG_CONREV	:= cRevis
		MsUnlock()
	EndIf
Next nCont

For nCont	:= 1 to Len(aItXPl[1][4]) //Atribui � TFI referente ao contrato a planilha e o item que eles est�o associados.
	DbSelectArea(cAliasTFH)
	DbSetOrder(1)
	If DbSeek(xFilial(cAliasTFH) + aItXPl[1][4][nCont][1])
		RecLock(cAliasTFH,.F.)
		(cAliasTFH)->TFH_SLD	:= (cAliasTFH)->TFH_QTDVEN
		(cAliasTFH)->TFH_CONTRT	:= cContr
		(cAliasTFH)->TFH_CONREV	:= cRevis
		MsUnlock()
	EndIf
Next nCont

//Aba de Uniformes
If lGsOrcUnif .And. Len(aItXPl[1][6]) > 0
	DbSelectArea("TXP")
	TXP->(DbSetOrder(1))
	For nCont	:= 1 to Len(aItXPl[1][6]) //Atribui � TXP contrato e revis�o
		If TXP->(DbSeek(xFilial("TXP") + aItXPl[1][6][nCont][1]))
			RecLock("TXP",.F.)
				TXP->TXP_CONTRT	:= cContr
				TXP->TXP_CONREV	:= cRevis
			MsUnlock()
		EndIf
	Next nCont
EndIf

//Aba de Armamento
If lGsOrcArma .And. Len(aItXPl[1][7]) > 0
	DbSelectArea("TXQ")
	TXQ->(DbSetOrder(1))
	For nCont	:= 1 to Len(aItXPl[1][7]) //Atribui � TXQ contrato e revis�o
		If TXQ->(DbSeek(xFilial("TXQ") + aItXPl[1][7][nCont][1]))
			RecLock("TXQ",.F.)
				TXQ->TXQ_CONTRT	:= cContr
				TXQ->TXQ_CONREV	:= cRevis
			MsUnlock()
		EndIf
	Next nCont
EndIf

RestArea(aArea)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT850DtInFim
Determina a data inicial e final do contrato de acordo com a menor data de in�cio e a maior data final dos locais da
proposta comercial.
@author Servi�os
@since 28/11/13
@version P11 R9
@return  aRet: Array com o valor da data inicial e final.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AT850DtInFim(cCodProp,cRevProp, cOrcsimp, cCodTFJ)

Local aArea     	:= GetArea()
Local aAreaTFL	:= TFL->(GetArea())
Local cAliasTFL	:= GetNextAlias()
Local cQuery		:=""
Local aRet			:={}
Local dDtIni
Local dDtFim
Local cCnPag 		:=""
Local lHasOrcSim := HasOrcSimp()

Default cOrcSimp := ""

DbSelectArea("TFL")
TFL->(DbsetOrder(1))

cQuery	:=	"SELECT * " + CRLF
cQuery	+=	" FROM " + RetSqlName("TFL") + " TFL " + CRLF
cQuery	+=	" INNER JOIN " + RetSqlName("TFJ") + " TFJ " + CRLF
cQuery +=	" 	 ON TFJ_FILIAL = '" + xFilial("TFJ") + "' " + CRLF
cQuery +=	"   AND TFJ_CODIGO = TFL_CODPAI " + CRLF
cQuery	+=	" WHERE " + CRLF
cQuery	+=	"	TFL_FILIAL = '" + xFilial("TFL") + "' AND " + CRLF
If !lHasOrcSim .OR. cOrcsimp != '1'
	cQuery	+=	" 	TFJ_PROPOS = '" + cCodProp + "' AND " + CRLF
	cQuery	+=	" 	TFJ_PREVIS = '" + cRevProp + "' AND " + CRLF
Else
	cQuery	+= "  TFJ_ORCSIM = '" + cOrcsimp + "' AND " + CRLF
	cQuery	+= "  TFJ_CODIGO = '" + cCodTFJ + "' AND " + CRLF
EndIf
cQuery	+=	" 	TFJ.D_E_L_E_T_ = '' AND " + CRLF
cQuery	+=	" 	TFL.D_E_L_E_T_ = ' '"

cQuery		:= ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cAliasTFL, .T., .T.)

dDtIni:= (cAliasTFL)->TFL_DTINI
dDtFim:= (cAliasTFL)->TFL_DTFIM

While (cAliasTFL)->(! Eof())
	If (cAliasTFL)->TFL_DTINI < dDtIni
		dDtIni	:= (cAliasTFL)->TFL_DTINI
	EndIf
	If (cAliasTFL)->TFL_DTFIM > dDtFim
		dDtFim	:= (cAliasTFL)->TFL_DTFIM
	EndIf
	cCnPag:= (cAliasTFL)->TFJ_CONDPG
	(cAliasTFL)->(DbSkip())
EndDo
(cAliasTFL)->(DbCloseArea())

aadd(aRet, dDtIni)
aadd(aRet, dDtFim)
aadd(aRet, cCnPag)
RestArea(aAreaTFL)
RestArea(aArea)
Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850ValCau
Valida o campo do percentual de cau��o.
@author Servi�os
@since 26/12/13
@version P11 R9
@return  aRet: Array com o valor da data inicial e final.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At850ValCau(cCbxFgCau)

Local lRet := (cCbxFgCau == STR0005)	// "Sim"
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850GCTCr
Gera planilha do contrato e cronogramas financeiros e cont�beis.
@param		aMaster:	Contrato
@param		aDetCli:	Clientes
@param		aDetCab:	Planilhas
@param		aDetItem:	Itens Planilhas
@return	lRet, l�gico
@author	Bruno.Rosa
@since		10/02/14
@version	P11 R9
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At850GCTCr(aMaster, aDetCli, aDetCab, aDetItem, aDetVend, oModel, cTpPl, lVigente, lRecor, lCtVigente)

Local oAux
Local oStruct 
Local nI				:= 0
Local nJ				:= 0
Local nL				:= 0
Local nK				:= 0
Local nW				:= 0
Local nX				:= 0
Local nZ				:= 0
Local nPos				:= 0
Local nCount			:= 0
Local nPlan				:= 0
Local nItErro			:= 0
Local nAuxCNA			:= 0
Local cMaster			:= "CN9"
Local cDetItm			:= "CNB"
Local aDetail			:= {"CNC", "CNA", "CNU"}
Local aAux				:= {}
Local aCposCab			:= {}
Local aCposDet			:= {}
Local lIniContrato		:= ( ValType(oModel) == "U" )
Local lAux				:= .T.
Local lRet				:= .T.
Local lCronF			:= .T.
Local lCronC			:= .T.
Local cConfirm          := "0"
Local cMedEve			:= ""
Local cCroCTB			:= ""
Local cCodCNL			:= ""
Local nTipoGerCron 		:= 0
Local cMsgErro 			:= ""
Local bWhen				:= Nil
Local lMantElab			:= .F.
Local aPergunte			:= {}
Default lVigente := .F.
Default oModel := FwLoadModel("CNTA301")
Default lRecor	:= .F.
Default lCtVigente := .F.

If lIniContrato
	oModel:SetOperation( 3 )
	oModel:Activate()
EndIf

lMantElab := IsInCallStack('TECA870') .AND. !(lVigente) .AND. lRecor //Em elabora��o e recorrente

If lMantElab
	aCposCab := aClone(aMaster)
	aAdd( aCposDet, aDetCli )
	aAdd( aCposDet, aDetCab )
	aAdd( aCposDet, aDetVend )

Else
	aCposCab := aClone(aMaster)

	If	Len(aDetCli) > 0
		aAdd( aCposDet, aDetCli )
	EndIf
	If	Len(aDetCab) > 0
		aAdd( aCposDet, aDetCab )
	EndIf
	If	Len(aDetVend) > 0
		aAdd( aCposDet, aDetVend )
	EndIf

EndIf

DbSelectArea( "CNC" )
DbSetOrder( 1 )	//CNC_FILIAL+CNC_NUMERO+CNC_REVISA+CNC_CODIGO+CNC_LOJA

DbSelectArea( "CNU" )
DbSetOrder( 1 )	//CNU_FILIAL+CNU_CONTRA+CNU_CODVD

DbSelectArea( "CNA" )
DbSetOrder( 1 )	//CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO

DbSelectArea( "CNB" )
DbSetOrder( 1 )	//CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM

DbSelectArea( cMaster )
DbSetOrder( 1 )

// Instanciamos apenas a parte do modelo referente aos dados de cabe�alho
oAux := oModel:GetModel( cMaster + 'MASTER' )

// Obtemos a estrutura de dados do cabe�alho
oStruct := oAux:GetStruct()
aAux := oStruct:GetFields()

If lRet
	For nI := 1 To Len( aCposCab )
		// Verifica se os campos passados existem na estrutura do cabe�alho
		If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCposCab[nI][1] ) } ) ) > 0
			If !( lAux := oModel:SetValue( cMaster + 'MASTER', aCposCab[nI][1],aCposCab[nI][2] ) )
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next
EndIf

If lRet

	For nI := 1 To Len( aCposDet )

		// Instanciamos apenas a parte do modelo referente aos dados do item
		oAux := oModel:GetModel( aDetail[nI] + 'DETAIL' )

		// Obtemos a estrutura de dados do item
		oStruct := oAux:GetStruct()
		aAux := oStruct:GetFields()

		For nJ := 1 To Len( aCposDet[nI] )
			nItErro := 0  //Pensar caso tenha mais itens para um mesmo detalhe do model
			If nJ > 1
				If ( nItErro := oAux:AddLine() ) <> nJ
					lRet := .F.
					Exit
				EndIf
			EndIf

			oModel:GetModel(aDetail[nI]+'DETAIL'):GoLine(nJ)

			For nL := 1 To Len(aCposDet[nI][nJ])
				
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCposDet[nI][nJ][nL][1] ) } ) ) > 0
					If aCposDet[nI][nJ][nL][1] $ "CNA_FLREAJ|CNA_UNPERI"
						bWhen := oStruct:GetProperty(Alltrim(aCposDet[nI][nJ][nL][1]),MODEL_FIELD_WHEN)
						oStruct:SetProperty(Alltrim(aCposDet[nI][nJ][nL][1]),MODEL_FIELD_WHEN,{||.T.})
					Endif

					If aDetail[nI] == 'CNC'
						If ( aCposDet[nI][nJ][nL][1] == "CNC_LOJACL" .Or. EMPTY(oModel:GetModel(aDetail[nI] + 'DETAIL'):GetValue(aCposDet[nI][nJ][nL][1])) ) ;
									.AND. !( lAux := oModel:SetValue( aDetail[nI] + 'DETAIL', aCposDet[nI][nJ][nL][1], aCposDet[nI][nJ][nL][2] ) )
							lRet := .F.
							nItErro := nJ
							Exit
						EndIf
					Else
						If aDetail[nI] == 'CNA' .AND.;
								oModel:GetModel("CN9MASTER"):GetValue("CN9_DTFIM") <;
								oModel:GetModel("CNADETAIL"):GetValue("CNA_DTFIM")
							If (nAuxCNA := ASCAN(aCposDet[nI][nJ], {|a| a[1] == "CNA_DTFIM"})) > 0
								If !( lAux := oModel:LoadValue( aDetail[nI] + 'DETAIL', aCposDet[nI][nJ][nAuxCNA][1], aCposDet[nI][nJ][nAuxCNA][2] ) )
									lRet := .F.
									nItErro := nJ
									Exit
								EndIf
							EndIf
						EndIf
						If !( lAux := oModel:SetValue( aDetail[nI] + 'DETAIL', aCposDet[nI][nJ][nL][1], aCposDet[nI][nJ][nL][2] ) )
							lRet := .F.
							nItErro := nJ
							Exit
						EndIf
					EndIf
					If aCposDet[nI][nJ][nL][1] $ "CNA_FLREAJ|CNA_UNPERI"
						oStruct:SetProperty(Alltrim(aCposDet[nI][nJ][nL][1]),MODEL_FIELD_WHEN, bWhen )
					Endif
				EndIf
			Next nL

			If lRet .and. nI == 2

				// Instanciamos apenas a parte do modelo referente aos dados do item
				oAux := oModel:GetModel( cDetItm + 'DETAIL' )

				// Obtemos a estrutura de dados do item
				oStruct := oAux:GetStruct()
				aAux := oStruct:GetFields()

				For nk := 1 To Len(aDetItem) //Itens da planilha

					For nX := 1 To Len(aDetItem[nk])

						If ( nPlan := aScan(aDetItem[nK],{ || aDetItem[nK][nX][2][2] == aCposDet[nI][nJ][2][2] } ) ) > 0

							nItErro := 0
							If nX > 1
								If ( nItErro := oAux:AddLine() ) <> nX
									lRet := .F.
									Exit
								EndIf
							EndIf

							For nW := 1 To Len(aDetItem[nK][nX])
								If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aDetItem[nk][nX][nW][1] ) } ) ) > 0
									If !( lAux := oModel:SetValue( cDetItm + 'DETAIL', aDetItem[nk][nX][nW][1], aDetItem[nk][nX][nW][2] ) )
										lRet := .F.
										nItErro := nX
										Exit
									EndIf
								EndIf
							Next nW

							If !lRet
								Exit
							EndIf
						EndIf

					Next nX
					// posiciona na primeira linha
					oAux:GoLine(1)

					If !lRet
						Exit
					EndIf
				Next nk

				If !lRet
					Exit
				EndIf

				// Instanciamos apenas a parte do modelo referente aos dados do item
				oAux := oModel:GetModel( aDetail[nI] + 'DETAIL' )
				// posiciona na primeira linha do grid

				oAux:GoLine(1)
				// Obtemos a estrutura de dados do item
				oStruct := oAux:GetStruct()
				aAux := oStruct:GetFields()

			EndIf

		Next nJ

		If !lRet
			Exit
		EndIf
	Next nI
EndIf

If lRet
    If !lAuto850
    	nTipoGerCron := GSEscolha( STR0144,; // "Cronogramas financeiros"
    									STR0145,;  // "Selecione como deseja definir os cronogramas financeiros."
										{ STR0146, STR0147 },; // "Sem Interface/Processo Antigo" ##  "Visualizando Contrato"
										1)
    Else
    	nTipoGerCron := 1
   	EndIf


	If nTipoGerCron == 1
		If !lTecA870  .AND. !lCtVigente
			cCodCNL := aDetCab[1][3][2]
		Else
			cCodCNL := cTpPl
		EndIf

		DbSelectArea("CNL")
		CNL->(DbSetOrder(1))

		DbSelectArea("CN1")
		CN1->(DbSetOrder(1))
		CN1->(DbSeek(xFilial("CN1")+aCposCab[1][2]))

		If CNL->(DbSeek(xFilial("CNL")+cCodCNL))
			//Tratativas para validar quando o tipo de planilha estiver como conforme o contrato
			If ( CNL->CNL_MEDEVE == "0" .And. CNL->CNL_CROCTB == "0" ) .Or. ;
				( CNL->CNL_MEDEVE == " " .And. CNL->CNL_CROCTB == " " )

				cMedEve	:= CN1->CN1_MEDEVE
				cCroCTB	:= CN1->CN1_CROCTB
			ElseIf CNL->CNL_MEDEVE == "0" .And. CNL->CNL_CROCTB <> "0"
				cMedEve	:= CN1->CN1_MEDEVE
				cCroCTB	:= CNL->CNL_CROCTB
			ElseIf CNL->CNL_MEDEVE <> "0" .And. CNL->CNL_CROCTB == "0"
				cMedEve	:= CNL->CNL_MEDEVE
				cCroCTB	:= CN1->CN1_CROCTB
			Else
				cMedEve	:= CNL->CNL_MEDEVE
				cCroCTB	:= CNL->CNL_CROCTB
			EndIf
			
			If	lTecA870 .OR. lCtVigente
				For nZ := 1 To oModel:GetModel("CNADETAIL"):Length()
					oModel:GetModel("CNADETAIL"):GoLine(nZ)
					oModel:GetModel("CNADETAIL"):SetValue("CNA_TIPPLA",cTpPl)

					//Atualiza qtd de recorr�ncia caso seja alterada no assistente de manutencao
					If lMantElab .AND. ( LEN(aDetCab[1][1]) > 0 )
						oModel:GetModel("CNADETAIL"):SetValue("CNA_QTDREC", aDetCab[1][1][2])
					EndIf

					CN300TpPla()
					If cMedEve == "2"
						For nCount := 1 to oModel:GetModel("CNFDETAIL"):Length()
							oModel:GetModel("CNFDETAIL"):GoLine(nCount)
							If !oModel:GetModel("CNFDETAIL"):IsDeleted() .And. !Empty(oModel:GetModel("CNFDETAIL"):GetValue("CNF_COMPET"))
								lCronF := .F.
								AVISO("AT850VAZIO", STR0141, { "OK" }, 1)	//"Esta planilha j� cont�m um cronograma associado. N�o ser� gerado um novo cronograma!"
								Exit
							EndIf
						Next nCount
						
						If lCronF
							If !lAuto850 
							 	// Verifica se j� escolheu, caso ainda n�o tenha escolhido define a op��o
							 	If cConfirm == '0' 
							 		If oModel:GetModel("CNADETAIL"):Length() > 1 .And. MsgYesNo( STR0185,STR0186)
							 			cConfirm := '1' //Replica configura��es
							 		Else
							 			cConfirm := '2' //N�o Replica configura��es
							 		EndIf
							 	EndIf						
							// Sen�o replicar ou for a primeira passagem, pergunta informa��es do cronograma
								If cConfirm == '2' .Or. nz == 1 
									Pergunte("CN300CRG",.T.) 
									aPergunte := {}
									aAdd(aPergunte,MV_PAR01)
									aAdd(aPergunte,MV_PAR02)
									aAdd(aPergunte,MV_PAR03 != 2)
									aAdd(aPergunte,MV_PAR04)
									aAdd(aPergunte,MV_PAR05)
									aAdd(aPergunte,MV_PAR06)
									aAdd(aPergunte,MV_PAR07)
									If TecHasPerg("MV_PAR08", "CN300CRG")   
         	 							aAdd(aPergunte, MV_PAR08)   
									EndIf
								EndIf
								lRet := CN300AddCrg(aPergunte)
							Else
								lRet := CN300AddCrg(aDadosAuto[19,nZ])  //Cria cronograma financeiro
              				EndIf
						EndIf
					EndIf
					If cCroCTB == "1"
						For nCount := 1 to oModel:GetModel("CNVDETAIL"):Length()
							oModel:GetModel("CNVDETAIL"):GoLine(nCount)
							If !oModel:GetModel("CNVDETAIL"):IsDeleted() .And. !Empty(oModel:GetModel("CNVDETAIL"):GetValue("CNV_NUMERO"))
								lCronC := .F.
								AVISO("AT850VAZIO", STR0141, { "OK" }, 1)	//"Esta planilha j� cont�m um cronograma associado. N�o ser� gerado um novo cronograma!"
								Exit
							EndIf
						Next nCount
						If lCronC
							oModel:GetModel("CNWDETAIL"):SetNoUpdateLine(.F.)
							oModel:GetModel("CNWDETAIL"):SetNoInsertLine(.F.)

							oModel:GetModel("CNVDETAIL"):SetNoUpdateLine(.F.)
							oModel:GetModel("CNVDETAIL"):SetNoInsertLine(.F.)
							lRet := CN300AddCtb()	 //Cria cronograma cont�bil
						EndIf
					EndIf
				Next nZ
			Else
				For nZ := 1 To Len(aCposDet[2])
					oModel:GetModel(aDetail[2]+'DETAIL'):GoLine(nZ)
					If lRet .And. cMedEve == "2"
						If !lAuto850
							// Verifica se j� escolheu, caso ainda n�o tenha escolhido, define a op��o
							If cConfirm == '0' 
								If Len(aCposDet[2]) > 1 .And. MsgYesNo( STR0185,STR0186)
									cConfirm := '1' //Replica configura��es
								Else
									cConfirm := '2' //N�o Replica configura��es
								EndIf
							EndIf						
							// Sen�o replicar ou for a primeira passagem, pergunta informa��es do cronograma
							If cConfirm == '2' .Or. nz == 1 
								Pergunte("CN300CRG",.T.) 
								aPergunte := {}	
								aAdd(aPergunte,MV_PAR01)
								aAdd(aPergunte,MV_PAR02)
								aAdd(aPergunte,MV_PAR03 != 2)
								aAdd(aPergunte,MV_PAR04)
								aAdd(aPergunte,MV_PAR05)
								aAdd(aPergunte,MV_PAR06)
								aAdd(aPergunte,MV_PAR07)
								If TecHasPerg("MV_PAR08", "CN300CRG")   
         	 						aAdd(aPergunte, MV_PAR08)   
								EndIf				
							EndIf
							lRet := CN300AddCrg(aPergunte)
                        Else
           		   		   lRet := CN300AddCrg(aDadosAuto[19,nZ])  //Cria cronograma financeiro
           		   		EndIf                   	
					EndIf
					If lRet .And. cCroCTB == "1"
						oModel:GetModel("CNWDETAIL"):SetNoUpdateLine(.F.)
						oModel:GetModel("CNWDETAIL"):SetNoInsertLine(.F.)

						oModel:GetModel("CNVDETAIL"):SetNoUpdateLine(.F.)
						oModel:GetModel("CNVDETAIL"):SetNoInsertLine(.F.)
						lRet := CN300AddCtb()	 //Cria cronograma cont�bil
					EndIf
				Next nZ
			EndIf
		EndIf
		lRet := lRet .And. oModel:VldData() .And. oModel:CommitData()
	ElseIf nTipoGerCron == 2
		// bloqueia as altera��es nas planilhas, itens e pool de clientes
		oModel:GetModel("CNADETAIL"):SetNoDeleteLine(.T.)
		oModel:GetModel("CNADETAIL"):SetNoInsertLine(.T.)
		oModel:GetModel("CNBDETAIL"):SetNoDeleteLine(.T.)
		oModel:GetModel("CNBDETAIL"):SetNoInsertLine(.T.)
		oModel:GetModel("CNCDETAIL"):SetNoDeleteLine(.T.)
		oModel:GetModel("CNCDETAIL"):SetNoInsertLine(.T.)
		// Realiza a exibi��o do contrato de venda utilizando o model o populado
		lRet := (FWExecView(STR0148,"CNTA301", OP_INCLUIR,,{|| .T.},{|oModel|At850Ok301(oModel, lVigente)}/*bOk*/,,,;
							{|oModel|At850Cn301(oModel, lVigente)}/*bCancel*/,,,oModel) == 0 )  // "Gera��o do Contrato GS"
		If !lRet
			cMsgErro := STR0149
		EndIf
	Else
		cMsgErro := STR0149
		lRet := .F.
	EndIf
EndIf

If !lRet .AND. !lAuto850

	If oModel:HasErrorMessage()
		aErro := oModel:GetErrorMessage()

		AutoGrLog( STR0083 + ' [' + AllToChar( aErro[1] ) + ']' )	//"Id do formul�rio de origem:"
		AutoGrLog( STR0084 + ' [' + AllToChar( aErro[2] ) + ']' )	//"Id do campo de origem: "
		AutoGrLog( STR0085 + ' [' + AllToChar( aErro[3] ) + ']' )	//"Id do formul�rio de erro: "
		AutoGrLog( STR0086 + ' [' + AllToChar( aErro[4] ) + ']' )	//"Id do campo de erro: "
		AutoGrLog( STR0087 + ' [' + AllToChar( aErro[5] ) + ']' )	//"Id do erro: "
		AutoGrLog( STR0088 + ' [' + AllToChar( aErro[6] ) + ']' )	//"Mensagem do erro: "
		AutoGrLog( STR0089 + ' [' + AllToChar( aErro[7] ) + ']' )	//"Mensagem da solu��o: "
		AutoGrLog( STR0090 + ' [' + AllToChar( aErro[8] ) + ']' )	//"Valor atribu�do: "
		AutoGrLog( STR0091 + ' [' + AllToChar( aErro[9] ) + ']' )	//"Valor anterior: "
		If nItErro > 0
			AutoGrLog( STR0092 + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' )	//"Erro no Item: "
		EndIf
		MostraErro()
	ElseIf !Empty(cMsgErro)
		MsgAlert( cMsgErro, STR0150 ) // "Problemas na gera��o do contrato"
	Else
		MsgAlert( STR0151, STR0150 ) // "Contrato n�o p�de ser gerado!" ### "Problemas na gera��o do contrato"
	EndIf
EndIf

oModel:DeActivate()
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850Func
Consulta funcion�rios que n�o tenham atendentes relacionados.
@since 21/02/14
@version P12
@param cCusto:Centro de Custo a ser pesquisado
@return aFunc: Funcion�rios do centro de custo informado que n�o tenham atendentes relacionados.
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At850Func(cCcusto)

Local aArea			:= GetArea()
Local cAliasSRA		:= GetNextAlias()
Local aFunc			:= {}
Local aFilPesq		:= {}
Local aSM0 			:= FWArrFilAtu()
Local cCompE		:= FWModeAccess("SRA",1)
Local cCompU		:= FWModeAccess("SRA",2)
Local cCompF		:= FWModeAccess("SRA",3)
Local cQuery		:= ""
Local cFilPesq		:= ""
Local nX

Default cCCusto := ""

If FWModeAccess("AA1",1) == 'C' .OR. FWModeAccess("AA1",2) == 'C' .OR. FWModeAccess("AA1",3) == 'C'
	If cCompE == 'C' .AND. cCompU == 'C' .AND. cCompF == 'C'
		cFilPesq := XFilial("SRA")
	ElseIf cCompU == 'E'
		aFilPesq := FWAllFilial(aSM0[SM0_EMPRESA],aSM0[SM0_UNIDNEG])
	ElseIf cCompE == 'E'
		aFilPesq := FWAllUnitBusiness(aSM0[SM0_EMPRESA])
	EndIf

	For nX := 1 To Len(aFilPesq)
		If nX > 1
			cFilPesq+="','"
		EndIf
		If cCompF == 'E'
			cFilPesq += aSM0[SM0_EMPRESA]+aSM0[SM0_UNIDNEG]+aFilPesq[nX]
		ElseIf cCompU == 'E'
			cFilPesq += aSM0[SM0_EMPRESA]+aSM0[SM0_UNIDNEG]+Space(Len(aFilPesq[nX]))
		ElseIf cCompE == 'E'
			cFilPesq += aSM0[SM0_EMPRESA]+Space(Len(aSM0[SM0_UNIDNEG]))+Space(Len(aSM0[SM0_FILIAL]))
		EndIf
	Next nX
Else
	cFilPesq := XFilial("SRA")
EndIf
cQuery		:= "SELECT SRA.RA_FILIAL, SRA.RA_TNOTRAB, SRA.RA_CC, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CARGO, SRA.RA_CODFUNC "
cQuery		+=   "FROM " + RetSqlName("SRA")+" SRA "
// Where para selecionar funcion�rios que n�o estejam cadastrados como atendente
cQuery		+=  "WHERE SRA.RA_FILIAL IN ('" + cFilPesq + "') "
cQuery		+=    " AND SRA.D_E_L_E_T_ = '' "
If SuperGetMv("MV_MSBLQL",,.F.)
	cQuery	+=    "AND SRA.RA_MSBLQL = '2' "
EndIf
If AllTrim(cCCusto) <> ""
	cQuery	+=    "AND SRA.RA_CC = '" + cCcusto + "' "
EndIf
cQuery += " AND SRA.RA_DEMISSA = '' "
cQuery += " AND SRA.RA_AFASFGT = '' "
cQuery += " AND SRA.RA_EAPOSEN <> '1' "
cQuery += " AND SRA.RA_FILIAL || SRA.RA_MAT NOT IN ( SELECT AA1.AA1_FUNFIL || AA1.AA1_CDFUNC FROM " + RetSqlName("AA1") + " AA1 WHERE AA1.D_E_L_E_T_ = '' "
cQuery += " AND AA1.AA1_FUNFIL IN ('" + cFilPesq + "') )"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasSRA, .T., .T. )
//	Preenche o array com as informa��es de funcion�rios que n�o s�o atendentes.
While &(cAliasSRA)->(! Eof())
	aAdd(aFunc,{ (cAliasSRA)->RA_FILIAL,;
	             (cAliasSRA)->RA_MAT,;
	             (cAliasSRA)->RA_NOME,;
	             (cAliasSRA)->RA_CARGO,;
	             Posicione("SQ3", 1, xFilial("SQ3") + (cAliasSRA)->RA_CARGO, "Q3_DESCSUM"),;
	             (cAliasSRA)->RA_CODFUNC,;
	             (cAliasSRA)->RA_TNOTRAB,;
	             (cAliasSRA)->RA_CC,;
	             Posicione("SRJ", 1, xFilial("SRJ") + (cAliasSRA)->RA_CODFUNC, "RJ_DESC") })
	&(cAliasSRA)->(DbSkip())
EndDo
&(cAliasSRA)->(DbCloseArea())

If Len(aFunc)==0
	aFunc :={{"","","","","","","","",""}}
EndIf
RestArea(aArea)
Return ( aFunc )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850GFunc
Gera atendentes com os funcion�rios do centro de custo informado que n�o possuem relacionamento com atendentes.
@since 21/02/14
@version P12
@param cCusto:Centro de Custo a ser pesquisado
@return lMsErroAuto: Caso n�otenha conseguido gravar os atendentes
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At850GFunc(aFuncionar)

Local aRotAuto := {}
Local nCont	:= 0
Private lMsErroAuto := .F.

If aFuncionar[1][1]<>""
	Begin Transaction
	For nCont := 1 To Len(aFuncionar)

		aAdd(aRotAuto,{"AA1_NOMTEC",aFuncionar[nCont,P_NOMEFUN],Nil})
		aAdd(aRotAuto,{"AA1_FUNCAO",aFuncionar[nCont,P_FUNCAO],Nil})
		aAdd(aRotAuto,{"AA1_CDFUNC",aFuncionar[nCont,P_MAT],Nil})
		aAdd(aRotAuto,{"AA1_FUNFIL",aFuncionar[nCont,P_FILIAL],Nil})
		aAdd(aRotAuto,{"AA1_CC",aFuncionar[nCont,P_CC],Nil})
		aAdd(aRotAuto,{"AA1_TURNO",aFuncionar[nCont,P_TURNO],Nil})
		If IsBlind()
			MsExecAuto( {|a,b| TECA020(a,b)},3,aRotAuto)
		Else

			MsgRun( STR0043,STR0068,{|| MsExecAuto( {|a,b| TECA020(a,b)},3,aRotAuto)})// 'Aten��o' ### "Aguarde..."]
		EndIf

		If lMsErroAuto
			If !(IsBlind())
				MostraErro()
			EndIf
			DisarmTransacation()
			Exit
		EndIf

		//limpa o array
		aRotAuto := {}

	Next nCont
	End Transaction
Else
	Help(,,'AT850VAZIO',, STR0106,1,0)//"Sem funcion�rios com este centro de custo que n�o tenham relacionamento com um Atendente!"
EndIf

Return lMsErroAuto


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850CaAtd
Abre tela para cadastro de atendente
@since 21/02/14
@version P12
@param cCodAtend:C�digo do atendente
@param nOperation:N�mero da Opera��o a ser realizada
@param cOperation:String com a��o a realizar
@return .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At850CaAtd(cCodAtend, nOperation, cOperation)

Default cCodAtend := ""

If nOperation=3
	FwExecView(cOperation, "VIEWDEF.TECA020", nOperation, /*oDlg*/, {|| .T.}, /*bOK */,/*nPercReducao*/)
Else
	DbSelectArea("AA1")
	DbsetOrder(1)
	DbSeek(xFilial("AA1")+cCodAtend)
	FwExecView(cOperation, "VIEWDEF.TECA020", nOperation, /*oDlg*/, {|| .T.}, /*bOK */,/*nPercReducao*/)
EndIf
Return ( .T. )


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850AtFnc
Atualiza grid de funcion�rios
@since 21/02/14
@version P12
@param aFuncionar:Funcion�rios
@param oLbxFunc:objeto do listbox
@param cCcusto:Centro de Custo
@return .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At850AtFnc(aFuncionar, oLbxFunc, cCcusto)

aFuncionar := At850Func(cCcusto)
oLbxFunc:SetArray(aFuncionar)
	oLbxFunc:bLine	:= {|| {aFuncionar[oLbxFunc:nAt,P_MAT],;
						        aFuncionar[oLbxFunc:nAt,P_NOMEFUN],;
						        aFuncionar[oLbxFunc:nAt,P_CARGO],;
						        aFuncionar[oLbxFunc:nAt,P_DESCARG],;
						        aFuncionar[oLbxFunc:nAt,P_FUNCAO],;
						        aFuncionar[oLbxFunc:nAt,P_DESFUNC]}}
oLbxFunc:Refresh()
Return( .T. )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850Comiss
Retorna a Comiss�o a ser utilizada no contrato de acordo com a configura��o
do cliente ou do vendedor.
@since 15/12/15
@version P12
@param cVend : Codigo do Vendedor
@param cCli : Codigo do Cliente
@param cLoja : Codigo da Loja do Cliente
@return aRet
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At850Comiss(cVend,cCli,cLoja, lComisPorTime)

Local aRet	:= {}
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSA3	:= SA3->(GetArea())
Local nComis	:= 0
Local aVend := {}
Local aTime := {}
Local cFilAD2 := xFilial("AD2")
Local nI := 0

Default lComisPorTime 	:= .F.

//Verifica se tem comiss�o para o cliente
DbSelectArea("SA1")
SA1->(DbSetOrder(1))

// se for comiss�o por time troca o cliente para o cliente da oprtunidade de venda
If lComisPorTime .And. ADY->ADY_ENTIDA == "1"
	cCli := ADY->ADY_CODIGO
	cLoja := ADY->ADY_LOJA
EndIf

// 	Procura o percentual de comiss�o do cliente
// quando comiss�o por time utiliza o cliente da oportunidade de venda
// quando comiss�o pelo vendedor da oportunidade de venda, utiliza o cliente do �ltimo local do or�amento de servi�os
If SA1->( DbSeek(xFilial("SA1") + cCli + cLoja) )
	nComis := SA1->A1_COMIS
EndIf

If lComisPorTime

	DbSelectArea("AD2")
	AD2->( DbSetOrder( 1 ) ) // AD2_FILIAL+AD2_NROPOR+AD2_REVISA+AD2_VEND
	If AD2->( DbSeek( cFilAD2 + ADY->ADY_OPORTU + ADY->ADY_REVISA ) )
		// procura no time de vendas pelos percentuais para os vendedores
		While AD2->( !EOF() ) .And. AD2->AD2_FILIAL == cFIlAD2 .And. ;
			AD2->AD2_NROPOR == ADY->ADY_OPORTU .And. AD2->AD2_REVISA == ADY->ADY_REVISA

			aAdd( aTime, { AD2->AD2_VEND, AD2->AD2_PERC, 0 } )

			AD2->( DbSkip() )
		End
		// 	Converte os valores de percentuais encontrados no time de vendas
		// conforme o percentual encontrado para o cliente ou vendedores
		//   Por exemplo:
		/* 	Primeira situa��o: Cliente com 5% na comiss�o e dois vendedores no time de vendas com 60% um e 40% outro
						primeiro vendedor ficar� com 3% <= [ 5% * (60/100) ]
						segundo vendedor ficar� com 2% <= [ 5% * (40/100) ]
			Segunda situa��o: Cliente com 0% na comiss�o e dois vendedores no time de vendas com 60% um e 40% outro,
				mas o percentual de comiss�o para cada vendedor em seus cadastros s�o 4 e 7 respectivamente.
						primeiro vendedor ficar� com 2,4% <= [ 4% * (60/100) ]
						segundo vendedor ficar� com 2,8% <= [ 7% * (40/100) ]
		*/
		If nComis > 0
			aEval( aTime, {|x| x[3] := ( nComis * ( x[2]/100 ) ) } )
		Else
			DbSelectArea("SA3")
			SA3->(DbSetOrder(1))

			For nI := 1 To Len( aTime )

				If SA3->( DbSeek(xFilial("SA3") + aTime[nI,1]) )
					aTime[nI,3] := ( SA3->A3_COMIS * ( aTime[nI,2]/100 ) )
				EndIf
			Next nI
		EndIf
		// adiciona ao array de retorno a ser utilizado na cria��o do contrato
		For nI := 1 To Len( aTime )
			If aTime[nI,3] > 0
				aSize( aVend, 0 )
				Aadd(aVend,{"CNU_CODVD"	, aTime[nI,1], NIL })
				Aadd(aVend,{"CNU_PERCCM", aTime[nI,3], NIL })

				Aadd(aRet,aClone(aVend))
			EndIf
		Next nI

	EndIf
Else
//Verifica se tem comiss�o com vendedor.
	If nComis == 0
		DbSelectArea("SA3")
		SA3->(DbSetOrder(1))

		If SA3->( DbSeek(xFilial("SA3") + cVend) )
			nComis := SA3->A3_COMIS
		EndIf
	EndIf

	If nComis > 0
		Aadd(aVend,{"CNU_CODVD"		, cVend		, NIL })
		Aadd(aVend,{"CNU_PERCCM"	, nComis	, NIL })

		Aadd(aRet,aClone(aVend))
	EndIf
EndIf

RestArea(aAreaSA1)
RestArea(aAreaSA3)
Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetDtProp
Retorna a data de assinatura da proposta comercial
@param		cProposta : Codigo da proposta comercial sendo convertida em contrato
@return	dRet
@since		12/05/16
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetDtProp(cProposta)

Local aArea	:= GetArea()
Local dData	:= CtoD(Space(08))

DbSelectArea("ADY")
ADY->(dbSetOrder(1))
If	ADY->(DbSeek(xFilial("ADY") + Padr(cProposta,TamSx3("ADY_PROPOS")[1])))
	DbSelectArea('AD1')
	AD1->(dbSetOrder(1))
	If	AD1->(DbSeek(xFilial("AD1") + ADY->ADY_OPORTU))
		dData	:= AD1->AD1_DTASSI
	EndIf
EndIf

RestArea(aArea)
Return dData

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} at850ValDt

Valid Data do Contrato
@author Servi�os
@since 11/08/16
@version P12
@param cDt: Data digitada pelo Usuario
@param cDtMax: Data Maior da Localidade
@param cTp: String que Informa qual o Tipo INI ou FIM

@return  lRet -> .T., Validou, .F. -> N�o validou
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function at850ValDt(dDt,dDtMax,cTp)

Local lRet := .F.

Default cTp := 'INI'

If cTp == 'INI'
	lRet := dDt <= dDtMax
ElseIf cTp == 'FIM'
	lRet := (dDt >= dDtMax)
EndIf

If !lRet
	MsgAlert(STR0135,STR0134)//#"Data n�o pode estar dentro do periodo de vigencia desse or�amento"  #"Verificar Data"
EndIf
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850TpPl

Verifica o tipo de Planilha
@author Joni.carmo
@since 21/09/2016
@version P12
@param cTPlan:Tipo de Planilha
@return  .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At850TpPl(cTpPl,cRecor)

Local lRet		 := .T.
Local aArea 	 := GetArea()
Local aAreaCNL	 := CNL->(GetArea())

Default cTpPl  := ""
Default cRecor := ""

DbSelectArea("CNL")
CNL->(DbSetOrder(1))

If CNL->(DbSeek(xFilial("CNL") + cTpPl))

	If (CNL->CNL_MEDEVE == "1")// .OR.; //-- Tipo de Planilha Selecionado possui000 medi��o eventual, em contratos com medi��o eventual n�o � poss�vel realizar medi��es de servi�os."###"OK"
		cAviso := STR0176
		lRet := .F.


	ElseIf (CNL->CNL_CTRFIX == "2") //-- Tipo de Planilha deve ser do tipo fixo!"###"OK"
			cAviso := STR0177
			lRet := .F.

	ElseIf (CNL->CNL_CROFIS == "1")//-- Tipo de Planilha selecionado deve ser configurado para n�o gerar cronograma fisico."
			cAviso := STR0178
			lRet := .F.

	ElseIf	(CNL->CNL_MEDEVE <> "3" .And. cRecor == "1")//-- Tipo de Planilha selecionado n�o possui Medi��o Recorrente, informe um Tipo de Planilha com Medi��o Recorrente."
			cAviso := STR0179
			lRet := .F.

	ElseIf (CNL->CNL_MEDEVE == "3" .And. cRecor == "2")//-- Or�amento de Servi�os n�o esta configurado para gerar Contrato Recorrente, informe um Tipo de Planilha que n�o esteja configurado com Medi��o Recorrente."
			cAviso := STR0180
			lRet := .F.

	ElseIf (CNL->CNL_PLSERV == "1")
			cAviso := STR0181
			lRet := .F.

	EndIf

		/*(CNL->CNL_CTRFIX == "2") .OR.; //-- Tipo de Planilha deve ser do tipo fixo!"###"OK"
		(CNL->CNL_CROFIS == "1") .OR.; //-- Tipo de Planilha selecionado deve ser configurado para n�o gerar cronograma fisico." ### "OK"
		(CNL->CNL_MEDEVE <> "3" .And. cRecor == "1") .OR.; //-- Tipo de Planilha selecionado n�o possui Medi��o Recorrente, informe um Tipo de Planilha com Medi��o Recorrente."" ### "OK"
		(CNL->CNL_MEDEVE == "3" .And. cRecor == "2") .OR.; //-- Or�amento de Servi�os n�o esta configurado para gerar Contrato Recorrente, informe um Tipo de Planilha que n�o esteja configurado com Medi��o Recorrente." ### "OK"
		(CNL->CNL_PLSERV == "1") //-- Tipo de Planilha de Servi�os
*/

	If !lRet
		Aviso(STR0137, cAviso, {STR0055}, 2)
	EndIf




EndIf

RestArea(aAreaCNL)
RestArea(aArea)

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A850AtItCNB

/*/
//--------------------------------------------------------------------------------------------------------------------
Function A850AtItCNB(cTabela,nRecno,cCampo,cValor)
Local aArea	:= GetArea()

(cTabela)->(dbGoto(nRecno))
RecLock( cTabela,.F.)
(cTabela)->&(cCampo) = cValor
(cTabela)->(MsUnlock())

RestArea(aArea)

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850GetCli
	Busca o cliente do local de atendimento conforme o preenchimento no or�amento de servi�os
@author 	josimar.assuncao
@since		12/05/16
@version	P12
@param 		cCodCli, Caracter, Refer�ncia, vari�vel para retorno do c�digo cliente
@param 		cLojCli, Caracter, Refer�ncia, vari�vel para retorno da loja do cliente
@param 		cCodigoLoc, Caracter, c�digo do local a ser avaliado o cliente
@param 		cTFJAGrupa, Caracter, defini��o no or�amento de servi�os de qual cliente dos locais de atendimento dever� ser utilizado
@return		L�gico, n�o encontrou o cliente para retornar
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At850GetCli( cCodCli, cLojCli, cCodigoLoc, cTFJAgrupa )
Local lCliOk := .F.

cCodCli := ""
cLojCli := ""

DbSelectArea("ABS")
ABS->( DbSetOrder(1) )	//ABS_FILIAL+ABS_LOCAL

If ABS->( DbSeek(xFilial("ABS") + cCodigoLoc ))

	If TFJ->TFJ_AGRUP == "2"
		If Empty(ABS->ABS_CLIFAT) .AND. Empty (ABS->ABS_LJFAT)
			ABS->(RecLock("ABS"))
			ABS->ABS_CLIFAT := ABS->ABS_CODIGO
			ABS->ABS_LJFAT := ABS->ABS_LOJA
			ABS->(MsUnlock())
		EndIf
		cCodCli := ABS->ABS_CLIFAT
		cLojCli	 := ABS->ABS_LJFAT
		lCliOk := .T.
	ElseIf TFJ->TFJ_AGRUP == "1" .AND. ABS->ABS_ENTIDA == "1"
		cCodCli := ABS->ABS_CODIGO
		cLojCli	 := ABS->ABS_LOJA
		lCliOk := .T.
	ElseIf TFJ->TFJ_AGRUP == "1" .AND. ABS->ABS_ENTIDA == "2"
		If !Empty(Posicione("SUS",1,xFilial("SUS")+ABS->ABS_CODIGO,"US_CODCLI"))
			cCodCli := Posicione("SUS",1,xFilial("SUS")+ABS->ABS_CODIGO,"US_CODCLI")
			cLojCli	 := Posicione("SUS",1,xFilial("SUS")+ABS->ABS_CODIGO,"US_LOJACLI")
			lCliOk := .T.
		Else
			lCliOk := .F.
			Help(,,'AT850LOCXCLI',, STR0110,3,0)//"N�o ser� poss�vel realizar a Gera��o do Contrato porque o Local de Atendimento do Or�amento de Servi�os da Proposta Comercial n�o pode estar relacionado a um Prospect que ainda n�o seja um Cliente!"
		EndIf
	EndIf
EndIf

Return lCliOk

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPrdCTR

Faz a carga dos produtos quando o parametro MV_GSDSGCN est� como 1-SIM
@author Filipe Gon�alves
@since 27/12/2016
@version P12
@param cCodPai:C�digo Pai do or�amento
@param cLocal:Local de Atendimento
@return  aProds:Array com os produtos para cria��o dos itens da planilha
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetPrdCTR(cCodPai,cLocal,cOrc,cCodOrc,lVlrCob)
Local cAliasRH	:= GetNextAlias()
Local cAliasMC	:= GetNextAlias()
Local cAliasMI	:= GetNextAlias()
Local cAliasLE	:= GetNextAlias()
Local aProds	:= {}
Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)
Local aArea 	:= GetArea()
Local cSlctTFF := "%%"
Local lGsOrcUnif 		:= FindFunction("TecGsUnif") .And. TecGsUnif()
Local lGsOrcArma 		:= FindFunction("TecGsArma") .And. TecGsArma()
Local nValUNI       := 0
Local nValArm       := 0
Local lValorUni := .F.
Local lValorArm := .F.
Default lVlrCob := .F.

DbSelectArea("TFJ")
DbSetOrder(1) //TFJ_FILIAL+TFJ_CODIGO
If TFJ->( DbSeek(xFilial("TFJ")+cCodOrc) )
	If lVlrCob
		cSlctTFF := ", TFF_VLRCOB"
		cSlctTFF := "%"+cSlctTFF+"%"
	Endif
	If cOrc == "RH"
		BeginSql Alias cAliasRH
			SELECT TFF_PRODUT,TFF_COD,TFF_QTDVEN,TFF_PRCVEN,TFF.R_E_C_N_O_, TFF_TESPED,
					TFF_TXLUCR, TFF_TXADM, TFF_VALDES %exp:cSlctTFF%
			FROM %Table:TFF% TFF
			WHERE TFF.TFF_FILIAL = %xfilial:TFF%
				AND TFF.%NotDel%
			  	AND TFF.TFF_CODPAI = %exp:cCodPai%
		EndSql

		While (cAliasRH)->(!EOF())
			nTot := 0

			If lGsOrcUnif
				nValUNI := At850TUN(cCodOrc,cCodPai,(cAliasRH)->TFF_COD)
				iF nValUNI > 0
					lValorUni := .T.
				Endif	
			Endif 

			If lGsOrcArma
				nValArm := At850TAR(cCodOrc,cCodPai,(cAliasRH)->TFF_COD)
				iF nValArm > 0
					lValorArm := .T.
				Endif	
			Endif 

			If lVlrCob .And. TFJ->TFJ_CNTREC == "1"
				If (cAliasRH)->TFF_VLRCOB <> 0
					nTot := (cAliasRH)->TFF_VLRCOB/(cAliasRH)->TFF_QTDVEN
				Else
					If lGsOrcUnif .Or. lGsOrcArma 
						If  lValorUni .And. lValorArm
							nTot := (cAliasRH)->TFF_PRCVEN + nValUNI + nValArm +((cAliasRH)->TFF_TXLUCR / (cAliasRH)->TFF_QTDVEN) + ((cAliasRH)->TFF_TXADM / (cAliasRH)->TFF_QTDVEN) - (cAliasRH)->TFF_VALDES	
						elseif lValorUni
							nTot := (cAliasRH)->TFF_PRCVEN + nValUNI +((cAliasRH)->TFF_TXLUCR / (cAliasRH)->TFF_QTDVEN) + ((cAliasRH)->TFF_TXADM / (cAliasRH)->TFF_QTDVEN) - (cAliasRH)->TFF_VALDES
						elseif  lValorArm
							nTot := (cAliasRH)->TFF_PRCVEN + nValArm +((cAliasRH)->TFF_TXLUCR / (cAliasRH)->TFF_QTDVEN) + ((cAliasRH)->TFF_TXADM / (cAliasRH)->TFF_QTDVEN) - (cAliasRH)->TFF_VALDES
						else
							nTot := (cAliasRH)->TFF_PRCVEN + ((cAliasRH)->TFF_TXLUCR / (cAliasRH)->TFF_QTDVEN) + ((cAliasRH)->TFF_TXADM / (cAliasRH)->TFF_QTDVEN) - (cAliasRH)->TFF_VALDES	
						Endif
					else
						nTot := (cAliasRH)->TFF_PRCVEN + ((cAliasRH)->TFF_TXLUCR / (cAliasRH)->TFF_QTDVEN) + ((cAliasRH)->TFF_TXADM / (cAliasRH)->TFF_QTDVEN) - (cAliasRH)->TFF_VALDES		
					Endif			
				EndIf
			Else
				If lGsOrcUnif .Or. lGsOrcArma 
					If  lValorUni .And. lValorArm
						nTot := (cAliasRH)->TFF_PRCVEN + nValUNI + nValArm +((cAliasRH)->TFF_TXLUCR / (cAliasRH)->TFF_QTDVEN) + ((cAliasRH)->TFF_TXADM / (cAliasRH)->TFF_QTDVEN) - (cAliasRH)->TFF_VALDES	
					elseif lValorUni
						nTot := (cAliasRH)->TFF_PRCVEN + nValUNI +((cAliasRH)->TFF_TXLUCR / (cAliasRH)->TFF_QTDVEN) + ((cAliasRH)->TFF_TXADM / (cAliasRH)->TFF_QTDVEN) - (cAliasRH)->TFF_VALDES
					elseif  lValorArm
						nTot := (cAliasRH)->TFF_PRCVEN + nValArm +((cAliasRH)->TFF_TXLUCR / (cAliasRH)->TFF_QTDVEN) + ((cAliasRH)->TFF_TXADM / (cAliasRH)->TFF_QTDVEN) - (cAliasRH)->TFF_VALDES
					else
						nTot := (cAliasRH)->TFF_PRCVEN + ((cAliasRH)->TFF_TXLUCR / (cAliasRH)->TFF_QTDVEN) + ((cAliasRH)->TFF_TXADM / (cAliasRH)->TFF_QTDVEN) - (cAliasRH)->TFF_VALDES	
					Endif
				else
					nTot := (cAliasRH)->TFF_PRCVEN + ((cAliasRH)->TFF_TXLUCR / (cAliasRH)->TFF_QTDVEN) + ((cAliasRH)->TFF_TXADM / (cAliasRH)->TFF_QTDVEN) - (cAliasRH)->TFF_VALDES		
				Endif	
				nValUNI := 0
				lValorUni := .F.
				nValArm := 0
				lValorArm := .F.
			Endif
			aAdd(aProds,{(cAliasRH)->TFF_PRODUT,(cAliasRH)->TFF_QTDVEN, nTot,(cAliasRH)->R_E_C_N_O_,(cAliasRH)->TFF_TESPED })
			(cAliasRH)->(dbSkip())
		EndDo

		(cAliasRH)->(DbCloseArea())
	EndIf

	If lOrcPrc
		If cOrc == "MI"
			BeginSql Alias cAliasMI
				SELECT TFG_PRODUT,TFG_QTDVEN,TFG_PRCVEN,TFG.R_E_C_N_O_, TFG_TESPED,
						TFG_TXLUCR, TFG_TXADM,TFG_VALDES
				FROM %Table:TFG% TFG
				WHERE TFG.TFG_FILIAL = %xfilial:TFG%
					AND TFG.%NotDel%
			  		AND TFG.TFG_CODPAI = %exp:cCodPai%
			EndSql

			While (cAliasMI)->(!EOF())
					nTot :=  0
					nTot :=  (cAliasMI)->TFG_PRCVEN + ((cAliasMI)->TFG_TXLUCR / (cAliasMI)->TFG_QTDVEN) + ((cAliasMI)->TFG_TXADM / (cAliasMI)->TFG_QTDVEN) - (cAliasMI)->TFG_VALDES
					aAdd(aProds,{(cAliasMI)->TFG_PRODUT,(cAliasMI)->TFG_QTDVEN, nTot,(cAliasMI)->R_E_C_N_O_, (cAliasMI)->TFG_TESPED})
				(cAliasMI)->(dbSkip())
			EndDo
			(cAliasMI)->(DbCloseArea())
		ElseIf cOrc == "MC"
			BeginSql Alias cAliasMC
				SELECT TFH_PRODUT,TFH_QTDVEN,TFH_PRCVEN,TFH.R_E_C_N_O_, TFH_TESPED,
						TFH_TXLUCR, TFH_TXADM, TFH_VALDES
				FROM %Table:TFH% TFH
				WHERE TFH.TFH_FILIAL = %xfilial:TFH%
					AND TFH.%NotDel%
				  	AND TFH.TFH_CODPAI = %exp:cCodPai%
			EndSql

			While (cAliasMC)->(!EOF())
					nTot :=  0
					nTot :=  (cAliasMC)->TFH_PRCVEN + ((cAliasMC)->TFH_TXLUCR/(cAliasMC)->TFH_QTDVEN) + ((cAliasMC)->TFH_TXADM/(cAliasMC)->TFH_QTDVEN) - (cAliasMC)->TFH_VALDES
					aAdd(aProds,{(cAliasMC)->TFH_PRODUT,(cAliasMC)->TFH_QTDVEN,nTot,(cAliasMC)->R_E_C_N_O_, (cAliasMC)->TFH_TESPED})
				(cAliasMC)->(dbSkip())
			EndDo
			(cAliasMC)->(DbCloseArea())
		EndIf
	Else
		If cOrc == "MI"
			BeginSql Alias cAliasMI
				SELECT TFG_PRODUT,TFG_QTDVEN,TFG_PRCVEN,TFG.R_E_C_N_O_, TFG_TESPED, TFF.TFF_PRODUT,
						TFG_TXLUCR, TFG_TXADM, TFG_VALDES
				FROM %Table:TFG% TFG
				INNER JOIN %Table:TFF% TFF ON TFF.TFF_FILIAL = %xfilial:TFF% AND TFG.TFG_CODPAI = TFF.TFF_COD
				WHERE TFG.TFG_FILIAL = %xfilial:TFG%
					AND TFF.%NotDel%
					AND TFG.%NotDel%
			  		AND TFF.TFF_CODPAI = %exp:cCodPai%
			EndSql

			While (cAliasMI)->(!EOF())
					nTot :=  0
					nTot := (cAliasMI)->TFG_PRCVEN + ((cAliasMI)->TFG_TXLUCR / (cAliasMI)->TFG_QTDVEN) + ((cAliasMI)->TFG_TXADM / (cAliasMI)->TFG_QTDVEN) - (cAliasMI)->TFG_VALDES
					aAdd(aProds,{(cAliasMI)->TFG_PRODUT,(cAliasMI)->TFG_QTDVEN, nTot,(cAliasMI)->R_E_C_N_O_, (cAliasMI)->TFG_TESPED, (cAliasMI)->TFF_PRODUT})
				(cAliasMI)->(dbSkip())
			EndDo
			(cAliasMI)->(DbCloseArea())
		ElseIf cOrc == "MC"
			BeginSql Alias cAliasMC
				SELECT TFH_PRODUT,TFH_QTDVEN,TFH_PRCVEN,TFH.R_E_C_N_O_, TFH_TESPED, TFF.TFF_PRODUT,
						TFH_TXLUCR, TFH_TXADM , TFH_VALDES
				FROM %Table:TFH% TFH
				INNER JOIN %Table:TFF% TFF ON TFF.TFF_FILIAL = %xfilial:TFF% AND TFH.TFH_CODPAI = TFF.TFF_COD
				WHERE TFH.TFH_FILIAL = %xfilial:TFH%
					AND TFH.%NotDel%
				  	AND TFF.%NotDel%
			  		AND TFF.TFF_CODPAI = %exp:cCodPai%
			EndSql

			While (cAliasMC)->(!EOF())
					nTot :=  0
					nTot :=  (cAliasMC)->TFH_PRCVEN + ((cAliasMC)->TFH_TXLUCR/(cAliasMC)->TFH_QTDVEN) + ((cAliasMC)->TFH_TXADM/(cAliasMC)->TFH_QTDVEN) - (cAliasMC)->TFH_VALDES
					aAdd(aProds,{(cAliasMC)->TFH_PRODUT,(cAliasMC)->TFH_QTDVEN, nTot,(cAliasMC)->R_E_C_N_O_, (cAliasMC)->TFH_TESPED, (cAliasMC)->TFF_PRODUT})
				(cAliasMC)->(dbSkip())
			EndDo
			(cAliasMC)->(DbCloseArea())
		EndIf
	EndIf

	If cOrc == "LE"  
		BeginSql Alias cAliasLE
			SELECT TFI_PRODUT,TFI_QTDVEN,TFI_TOTAL / TFI_QTDVEN  TFI_PRCUN,TFI.R_E_C_N_O_, TFI_TESPED
			FROM %Table:TFI% TFI
			WHERE TFI.TFI_FILIAL = %xfilial:TFI%
				AND TFI.%NotDel%
				AND TFI.TFI_CODPAI = %exp:cCodPai%
		EndSql

		While (cAliasLE)->(!EOF())
		  aAdd(aProds,{(cAliasLE)->TFI_PRODUT,(cAliasLE)->TFI_QTDVEN,(cAliasLE)->TFI_PRCUN,(cAliasLE)->R_E_C_N_O_, (cAliasLE)->TFI_TESPED})
		  (cAliasLE)->(dbSkip())
		EndDo
		(cAliasLE)->(DbCloseArea())
	EndIf
EndIf

RestArea(aArea)

Return aProds

/*/{Protheus.doc} At850Cn301
@description 	Confirma se o usu�rio realmente deseja abortar a opera��o de gera��o do contrato
@since 			03.01.2017
@version 		12
@param 			oModel, Objeto FwFormModel/MpFormModel, objeto geral do contrato CNTA301
@return 		L�gico, define se deve fechar e continuar com o cancelamento ou voltar para a interface do contrato
/*/
Static Function At850Cn301(oModel, lVigente)
Local lCancela := .F.

lCancela := MsgNoYes( STR0152, STR0153 )  // "Deseja realmente desistir da gera��o do contrato?" ###  "Confirma opera��o?"

Return lCancela

/*/{Protheus.doc} At850Ok301
@description 	Confirma se o usu�rio realmente deseja continuar com o processo de gera��o do contrato
@since 			03.01.2017
@version 		12
@param 			oModel, Objeto FwFormModel/MpFormModel, objeto geral do contrato CNTA301
@return 		L�gico, define se deve fechar e continuar com o cancelamento ou voltar para a interface do contrato
/*/
Static Function At850Ok301(oModel, lVigente)
Local lContinua 	:= .F.

If lVigente
	lContinua := MsgNoYes( STR0154 + CRLF + ;  // "Caso os cronogramas n�o estejam definidos o processo ser� abortado."
			STR0155, STR0153 ) // "Deseja realmente prosseguir com a opera��o?" ### "Confirma opera��o?"
Else
	lContinua := .T.
EndIf

Return lContinua


/*/{Protheus.doc} At850IsRecr
@description 	Indica se o or�amento � recorrente
@since 			03.08.2017

/*/
Function At850IsRecr(cCodProp,cRevProp, cOrcSimp, cTFJCodigo )
Local cRet := ""
Local aArea := GetArea()

Default cOrcSimp := ""
Default cTFJCodigo := ""

If cOrcSimp != '1' .OR. EMPTY(cTFJCodigo)
	TFJ->(DbSetOrder(2)) // TFJ_FILIAL+TFJ_PROPOS+TFJ_PREVIS
	If TFJ->( DbSeek( xFilial("TFJ")+cCodProp+cRevProp ))
       cRet := If(Empty(TFJ->TFJ_CNTREC),'2',TFJ->TFJ_CNTREC)
	EndIf
Else
	TFJ->(DbSetOrder(1)) //TFJ_FILIAL+TFJ_CODIGO
	If TFJ->( DbSeek( xFilial("TFJ")+cTFJCodigo) )
		cRet := If(Empty(TFJ->TFJ_CNTREC),'2',TFJ->TFJ_CNTREC)
	EndIf
EndIf

RestArea(aArea)
Return cRet

/*/{Protheus.doc} AT850defdt
Determina a data inicial e final do contrato de acordo com a menor data de in�cio e a maior data final dos locais do Or�amento Simplificado
@author diego.bezerra
@since 28/02/2018
@param	oLbxOrc:	or�amento selecionado (quando par�metro MV_ORCSIMP = 1)
@return  aRet: Array com o valor da data inicial e final.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AT850defdt(oLbxOrc)

Local aArea     	:= GetArea()
Local aAreaTFL		:= TFL->(GetArea())
Local cAliasTFL		:= GetNextAlias()
Local cQuery		:=""
Local aRet			:={}
Local dDtIni
Local dDtFim
Local cCnPag 		:=""

DbSelectArea("TFL")
TFL->(DbsetOrder(1))

If cOrcSimp == "1"
	nPos 	:= 	IIF(lTecA745, 0, aScan(oLbxOrc:aArray,{|x| x[P_MARCA]}))
	cCodOrc	:= 	IIF(lTecA745, TFJ->TFJ_CODIGO, oLbxOrc:aArray[nPos,5])
	TFJ->( DbSeek(xFilial("TFJ")+cCodOrc) ) // Apenas aponta a TFJ se o par�metro MV_ORCSIMP = 1. Caso contr�rio, a TFJ j� est� apontada
EndIf


cQuery	:=	"SELECT TFL.TFL_DTINI, TFL.TFL_DTFIM, TFJ.TFJ_CONDPG "
cQuery	+=	" FROM " + RetSqlName("TFL") + " TFL "
cQuery	+=	" INNER JOIN " + RetSqlName("TFJ") + " TFJ "
cQuery +=	" 	 ON TFJ_FILIAL = '" + xFilial("TFJ") + "' "
cQuery +=	"   AND TFJ_CODIGO = TFL_CODPAI "
cQuery	+=	" WHERE "
cQuery	+=	"	TFL_FILIAL = '" + xFilial("TFL") + "' AND "
cQuery	+=	" 	TFJ_CODIGO = '" + TFJ->TFJ_CODIGO + "' AND "
cQuery	+=	" 	TFJ.D_E_L_E_T_ = ' ' AND "
cQuery	+=	" 	TFL.D_E_L_E_T_ = ' '"

cQuery		:= ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cAliasTFL, .T., .T.)

dDtIni:= (cAliasTFL)->TFL_DTINI
dDtFim:= (cAliasTFL)->TFL_DTFIM

While (cAliasTFL)->(! Eof())
	If (cAliasTFL)->TFL_DTINI < dDtIni
		dDtIni	:= (cAliasTFL)->TFL_DTINI
	EndIf
	If (cAliasTFL)->TFL_DTFIM > dDtFim
		dDtFim	:= (cAliasTFL)->TFL_DTFIM
	EndIf
	cCnPag:= (cAliasTFL)->TFJ_CONDPG
	(cAliasTFL)->(DbSkip())
EndDo
(cAliasTFL)->(DbCloseArea())

aadd(aRet, dDtIni)
aadd(aRet, dDtFim)
aadd(aRet, cCnPag)

RestArea(aAreaTFL)
RestArea(aArea)

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850Orc

Carrega or�amentos de servi�o para sele��o no wizzard do or�amento simplificado
@author diego.bezerra
@since 05/03/2018
@return  aOrc, array, array com os dados do Local de Atendimento
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At850Orc(nQtdMeses)
Local aArea			:= GetArea()
Local cAliasTFJ		:= GetNextAlias()
Local cFilTFJ		:= xFilial("TFJ")
Local cFilSA1		:= xFilial("SA1")
Local cQuery		:= ""
Local aOrc			:= {}
Local cNome 		:= ""
Local dCorte		:= dDataBase - (nQtdMeses * 30)
Local lResTec		:= TFJ->(ColumnPos("TFJ_RESTEC"))>0

DbSelectArea("TFJ")
DbSetOrder(1) //TFJ_FILIAL + TFJ_CODIGO


cQuery := "SELECT TFJ_FILIAL, TFJ.TFJ_CODENT, TFJ_LOJA, TFJ_CODIGO, TFJ_CNTREC, A1_NOME, TFJ_GRPRH, TFJ_ORCSIM, TFJ_PREVIS, TFJ_DATA"
cQuery += " FROM	" + RetSqlName("TFJ")+" TFJ "
cQuery += " INNER JOIN " + RetSqlName("SA1")+" SA1 "
cQuery += " on A1_COD = TFJ_CODENT "
cQuery += " AND A1_LOJA = TFJ_LOJA "
cQuery += " WHERE TFJ_FILIAL = '"+ cFilTFJ +"'"
cQuery += " AND A1_FILIAL = '"+ cFilSA1 +"'"
cQuery += " AND TFJ.TFJ_ORCSIM = '1'"
cQuery += " AND TFJ.TFJ_CONTRT = '               '"
cQuery += " AND TFJ.TFJ_DATA >= '" + DtoS(dCorte) + "' "
cQuery += " AND TFJ.TFJ_DATA <= '" + DtoS(dDataBase) + "' "
If lResTec
	cQuery += " AND TFJ.TFJ_RESTEC <> '2'" // Desconsiderar Orcamento de Reserva Tecnica 
EndIf
cQuery += " AND TFJ.D_E_L_E_T_ = '' "
cQuery += " AND SA1.D_E_L_E_T_  = '' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTFJ,.T.,.T.)

While (cAliasTFJ)->(! Eof())

		aAdd(aOrc, { .F.,;								// Marca
						(cAliasTFJ)->TFJ_FILIAL,;		// Filial
						(cAliasTFJ)->TFJ_LOJA,;			// Loja
						(cAliasTFJ)->TFJ_CODENT,;		// Codigo do Cliente
						(cAliasTFJ)->TFJ_CODIGO,;		// Codigo
						(cAliasTFJ)->TFJ_CNTREC,;
						(cAliasTFJ)->A1_NOME,;
						(cAliasTFJ)->TFJ_GRPRH,;
						(cAliasTFJ)->TFJ_ORCSIM,;
						(cAliasTFJ)->TFJ_PREVIS,;
						(cAliasTFJ)->TFJ_DATA })
	(cAliasTFJ)->(DbSkip())

EndDo

(cAliasTFJ)->(DbCloseArea())

//Se nao encontrou or�amento, inicializa um array vazio
If EMPTY(aOrc)
	aOrc :={{.F.,"","","","","","","","","",""}}
EndIf

RestArea(aArea)

Return aOrc

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECBGetISS

@description Retorna o CODISS de um produto

@author	Mateus Boiani
@since	11/06/2019
/*/
//------------------------------------------------------------------------------
Function TECBGetISS(cProd)
Local cRet := ""
Local aArea := GetArea()

cRet := Posicione("SB1",1,xFilial("SB1") + cProd, "B1_CODISS")

RestArea(aArea)
Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At850GtHr

@description Calcula as horas de uma Item de RH

@author	fabiana.silva
@param 		cContr, Numero do Contrato
@param 		aItemRHIt, Array do item de RH
@param 		lRecLock, Registro Novo na ABQ?
@param 		cSeqTrn, Sequencia do Turno
@param 		cTurno, Turno
@param 		dDataIni, Data Inicial do Contrato
@param 		dDataFim, Data Final do Contrato
@return		nRet - Total de horas	
@since	02/01/2020
/*/
//------------------------------------------------------------------------------
Static Function At850GtHr(	cContr, 	aItemRHIt, 	lRecLock, 	cSeqTrn,;
							cTurno, 	dDataIni, 	dDataFim)
Local nRet 		:= 0
Local aAlias 	:= {}
Local aAliABQ 	:= {}
Local nFator 	:= 1
Local nDif 		:= 0
Local lCalc 	:= .T.


lCalc := Len(aItemRHIt) >= ITEMRH_TFFORIG .AND. ValType(aItemRHIt[ITEMRH_TFFORIG]) == "A" .and.  Len(aItemRHIt[ITEMRH_TFFORIG]) > 0

If EMPTY(cSeqTrn)
	cSeqTrn := "01"
EndIf
 
If lCalc

	//Verifica se calendario, turno e sequencia sao iguais para manter as horas ABQ/TFF j� calculadas
	lCalc := aItemRHIt[ITEMRH_TFFORIG][TFFORIG_TURNO] == cTurno .AND.  ;
	 	   aItemRHIt[ITEMRH_TFFORIG][TFFORIG_SEQTRN] == cSeqTrn .AND.  ;
	 	   aItemRHIt[ITEMRH_TFFORIG][TFFORIG_TFFESC] == aItemRHIt[ITEMRH_TFFORIG][TFFORIG_ESCALA] //
	
	If lCalc .AND. lRecLock  .AND. !Empty(aItemRHIt[ITEMRH_TFFORIG][TFFORIG_COD]) 	
		 aAlias := GetArea()
		 aAliABQ := ABQ->(GetArea())
		 ABQ->(DbSetOrder(3)) //ABQ_FILIAL + ABQ_CODTFF+ ABQ_FILTFF
		 lCalc := ABQ->(DbSeek(xFilial("ABQ")+ aItemRHIt[ITEMRH_TFFORIG][TFFORIG_COD] + aItemRHIt[ITEMRH_TFFORIG][TFFORIG_FILIAL]))
	EndIf
EndIf

If lCalc 
 	nRet := ABQ->ABQ_HRSEST	
	If dDataIni  <> ABQ->ABQ_PERINI .OR. dDataFim  <> ABQ->ABQ_PERFIM  
	//� Diferente calcula as Diferencas	
 		//Calculo da Diferen�a da Data Inicial
 		If ABQ->ABQ_PERINI <> aItemRHIt[ITEMRH_PERINI]
 			If ABQ->ABQ_PERINI < aItemRHIt[ITEMRH_PERINI]
 				nFator := -1
				dDataIni := ABQ->ABQ_PERINI
				dDataFim := aItemRHIt[ITEMRH_PERINI]	-1			
 			Else
 				nFator := 1
 				dDataIni := aItemRHIt[ITEMRH_PERINI]
				dDataFim := ABQ->ABQ_PERINI -1				
 			EndIf
 			//Escala n�o informada, vai pelo criaCalend
 			If Empty(aItemRHIt[ITEMRH_TFFORIG][TFFORIG_TFFESC])
 				nDif := At850TtHrs(dDataIni,dDataFim,cTurno,cSeqTrn)
 			Else
 				//Escala informada, vai pelo TecCalcEsc (TECA580C) - ultima calculada
 				nDif := TecCalcEsc(aItemRHIt[ITEMRH_TFFORIG][TFFORIG_TFFESC], dDataIni, dDataFim)
 			EndIf
 			nRet += nDif * nFator
 		EndIf
 		//Calculo da Diferen�a da Data Final
 		If aItemRHIt[ITEMRH_PERFIM]  <> ABQ->ABQ_PERFIM
 			If ABQ->ABQ_PERFIM < aItemRHIt[ITEMRH_PERFIM]
 				nFator := 1
				dDataIni := ABQ->ABQ_PERFIM + 1
				dDataFim := aItemRHIt[ITEMRH_PERFIM]			
 			Else
 				nFator := -1
 				dDataIni := aItemRHIt[ITEMRH_PERFIM]+1
				dDataFim := ABQ->ABQ_PERFIM			
 			EndIf
 			
 			If Empty(aItemRHIt[ITEMRH_TFFORIG][TFFORIG_TFFESC])
 				nDif := At850TtHrs(dDataIni,dDataFim,cTurno,cSeqTrn)
 			Else
 				nDif := TecCalcEsc(aItemRHIt[ITEMRH_TFFORIG][TFFORIG_TFFESC], dDataIni, dDataFim)
 			EndIf
 			nRet += nDif * nFator
 		EndIf
 		
 	EndIf

 Else
 	nRet := At850TtHrs(dDataIni,dDataFim,cTurno,cSeqTrn)
 EndIf
 
 If Len(aAlias) > 0
 	 ABQ->(RestArea(aAliABQ))
	 RestArea(aAlias)
 EndIf
 
Return nRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At850TtHrs

@description Calcula as horas de uma Item de RH

@author	fabiana.silva
@param 		dDataIni, Data Inicial do Contrato
@param 		dDataFim, Data Final do Contrato
@param 		cSeqTrn, Sequencia do Turno
@param 		cTurno, Turno
@return		nTotHrsEst - Total de horas	
@since	02/01/2020
/*/
//------------------------------------------------------------------------------
Static Function At850TtHrs(dDataIni,dDataFim,cTurno,cSeqTrn)
Local aTabPadrao	:= {}
Local aTabCalend	:=	{}
Local aExcePer	:=	{}
Local lReturn := .T.
Local nTotHrsEst := 0
Local nX := 0

lReturn := CriaCalend(dDataIni,dDataFim,cTurno,cSeqTrn,@aTabPadrao,@aTabCalend,xFilial("SRA"),,,,aExcePer)
If lReturn
	For nX := 1 To Len(aTabCalend)
		If aTabCalend[nX][6] == "S"
			If Substr(aTabCalend[nX][4],2,1) == "E"
				nTotHrsEst += TxAjtHoras(aTabCalend[nX][7])
			ElseIf Substr(aTabCalend[nX][4],2,1) == "S"
				nTotHrsEst += TxAjtHoras(aTabCalend[nX][9])
			EndIf
		EndIf
	Next nX
EndIf
			
Return nTotHrsEst

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850CrTar
Analisa recurso humano informado no contrato, caso o mesmo possua risco (1-SIM) cria automaticamente uma tarefa de funcion�rio (TN5). 
A tarefa ser� criada com um sequencia autom�tica e ser� considerado o campo LOCAL e FUN��O informada no contrato.  
@param  cNrCont, Caracter, N�mero do contrato
@param  cRev1, Caracter, Revis�o do contrato.
@return Nenhum
@author Eduardo Gomes J�nior
@since 09/01/20178
/*/
//------------------------------------------------------------------------------------------	
Function At850CrTar(cNrCont,cRev1)
Local aArea		:= {}
Local cQueryTFF	:= ""
Local cQueryNum	:= ""
Local cQueryTN5	:= ""
Local cProxTN5	:= ""
Local cFilTN5	:= ""

DbSelectArea("TN5")
TN5->(DbSetOrder(1))
If TN5->(ColumnPos("TN5_LOCAL")) > 0 .And. TN5->(ColumnPos("TN5_POSTO")) > 0

	aArea		:= GetArea()
	cQueryNum	:= GetNextAlias()

	BeginSql Alias cQueryNum
		SELECT MAX(TN5_CODTAR) ULTTAREFA  	
		FROM %Table:TN5% TN5
		WHERE TN5.TN5_FILIAL = %xFilial:TN5%
			AND TN5.%NotDel%
	EndSql
	
	cProxTN5 := Soma1( (cQueryNum)->ULTTAREFA )
	
	cQueryTFF	:= GetNextAlias()
	
	BeginSql Alias cQueryTFF
		SELECT	TFF_FILIAL, TFF_COD, TFF_ITEM, TFF_PRODUT, TFF_LOCAL, TFF_FUNCAO  	
		FROM %Table:TFF% TFF
		WHERE TFF.TFF_FILIAL	= %exp:xFilial('TFF')%
			AND TFF.TFF_CONTRT	= %exp:cNrCont%  
			AND TFF.TFF_CONREV	= %exp:cRev1%
			AND TFF.TFF_RISCO	= '1'
			AND TFF.%NotDel%
	EndSql
	
	cFilTN5 := xFilial("TN5")
	
	(cQueryTFF)->(dbGoTop())
	
	While (cQueryTFF)->(!Eof())
		
		cQueryTN5 := GetNextAlias()
		
		BeginSql Alias cQueryTN5
		
			SELECT TN5.R_E_C_N_O_ TN5RECNO
			FROM %Table:TN5% TN5
			WHERE TN5.TN5_FILIAL	= %exp:xFilial('TN5')%
				AND TN5.TN5_LOCAL	= %exp:(cQueryTFF)->TFF_LOCAL%
				AND TN5.TN5_POSTO	= %exp:(cQueryTFF)->TFF_FUNCAO%
				AND TN5.%NotDel%
		EndSql
	
		If (cQueryTN5)->(EOF())
	
			RecLock("TN5",.T.)
				TN5->TN5_FILIAL := cFilTN5
				TN5->TN5_CODTAR := cProxTN5
				TN5->TN5_NOMTAR := (cQueryTFF)->TFF_LOCAL + " - " + (cQueryTFF)->TFF_FUNCAO
				TN5->TN5_LOCAL	:= (cQueryTFF)->TFF_LOCAL
				TN5->TN5_POSTO	:= (cQueryTFF)->TFF_FUNCAO
			TN5->(MsUnlock())	
	
		EndIf
	
		(cQueryTN5)->(dbCloseArea())
		
		cProxTN5 := Soma1( cProxTN5 )
	
		(cQueryTFF)->(dbSkip())
		
	End
	
	(cQueryNum)->(dbCloseArea())
	(cQueryTFF)->(dbCloseArea())

	RestArea(aArea)

Endif

Return
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850WhOp
When do campo de elabora��o do assistente de contrato para aprova��o operacional.
@return lRet
@author Kaique Schiller
@since 02/02/2022
/*/
//------------------------------------------------------------------------------------------	
Static Function At850WhOp(cTFJCodigo)
Local lRet := .T.
If SuperGetMv("MV_GSAPROV",,"2") == "1" .And. !SuperGetMv("MV_ORCPRC",,.F.) .And. TFJ->(ColumnPos('TFJ_APRVOP')) > 0
	lRet := Posicione("TFJ",1,xFilial("TFJ")+cTFJCodigo,"TFJ_APRVOP") == "1"
Endif
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECLOGFME
Log de gravacao da Findme
@return Nil
@author Vitor kwon
@since 06/12/2022
/*/
//------------------------------------------------------------------------------------------	

Static Function TECLOGFME(aDados)

Local cLog     := ""
Local cTitle   := STR0192 //"Resumo de integracao FIND-ME" 
Local lVScroll := .F.
Local lHScroll := .F.
Local lWrdWrap := .F.
Local lCancel  := .F.
Local nX       :=  0
Default aDados   := {}

    For nX := 1 to len(aDados)

        If nX == 1 
            cLog := STR0193  +CRLF  //"Log de Integra��o : " 
            cLog += " "+CRLF 
        Endif    

        cLog += STR0187 +aDados[nX][4][2]+STR0188+CRLF // O cliente#"foi integrado com sucesso"
        cLog += STR0189+cValtochar(Date())+STR0190+time()+" "+CRLF //"A inclusao ocorreu no dia"#as#
        cLog += "" +CRLF

        If nX == len(aDados)
            cLog += STR0191 +CRLF // "Fim do processamento"
        Endif

    Next nX

    AtShowLog(cLog,cTitle,lVScroll,lHScroll,lWrdWrap,lCancel)

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850TUN
Retorna o valor de uniforme  no or�amento
@return Nil
@author Vitor kwon
@since 21/03/2023
/*/
//------------------------------------------------------------------------------------------	

Function At850TUN(cCodTFL,cCodLocal,cCodTFF)

Local nValor		:= 0
Local cAliasTFL	:= GetNextAlias()
Local cCond := ""
Local cFiltro := ""

Default cCodTFL := ""
Default cCodLocal := ""
Default cCodTFF := ""

If Empty(cCodLocal) 
	cCond := ""
	cCond := '%'+cCond+'%'	
Else
	cCond := "AND TFF_CODPAI = '"+cCodLocal+"'"
	cCond := '%'+cCond+'%'	
Endif

If Empty(cCodTFF) 
	cFiltro := ""
	cFiltro := '%'+cFiltro+'%'	
Else
	cFiltro := "AND TFF_COD = '"+cCodTFF+"'"
	cFiltro := '%'+cFiltro+'%'	
Endif

Default cCodTFL := ""
Default cCodLocal := ""

BeginSql Alias cAliasTFL
	SELECT
	TXP_QTDVEN QTDUNI,
	TXP_PRCVEN	VALORUNI
	FROM %table:TFL% TFL
	INNER JOIN %table:TFF% TFF
		ON TFF.TFF_FILIAL = %xFilial:TFF%
		AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
		AND TFF.%NotDel%
		%Exp:cFiltro%
	INNER JOIN %table:TXP% TXP
		ON TXP.TXP_FILIAL = %xFilial:TXP%
		AND TXP.TXP_CODTFF = TFF.TFF_COD
		AND TXP.%NotDel%
	WHERE
		TFL.TFL_FILIAL = %xFilial:TFL%
		AND TFL.TFL_CODPAI = %Exp:cCodTFL% 
		AND TFL.%NotDel%
		%Exp:cCond%
EndSql

While (cAliasTFL)->(!Eof())
	nValor += (cAliasTFL)->QTDUNI * (cAliasTFL)->VALORUNI
	(cAliasTFL)->(DbSkip())
Enddo

(cAliasTFL)->(DbCloseArea())

Return nValor


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} At850TAR
Retorna o valor de armas no or�amento
@return Nil
@author Vitor kwon
@since 21/03/2023
/*/
//------------------------------------------------------------------------------------------	

Function At850TAR(cCodTFL,cCodLocal,cCodTFF)

Local nValor		:= 0
Local cAliasTFL	:= GetNextAlias()
Local cCond := ""
Local cFiltro := ""

Default cCodTFL := ""
Default cCodLocal := ""
Default cCodTFF := ""


If Empty(cCodLocal) 
	cCond := ""
	cCond := '%'+cCond+'%'	
Else
	cCond := "AND TFF_CODPAI = '"+cCodLocal+"'"
	cCond := '%'+cCond+'%'	
Endif

If Empty(cCodTFF) 
	cFiltro := ""
	cFiltro := '%'+cFiltro+'%'	
Else
	cFiltro := "AND TFF_COD = '"+cCodTFF+"'"
	cFiltro := '%'+cFiltro+'%'	
Endif

BeginSql Alias cAliasTFL
	SELECT
	TXQ_QTDVEN QTDARM,
	TXQ_PRCVEN VALORARM
	FROM %table:TFL% TFL

	INNER JOIN %table:TFF% TFF
		ON TFF.TFF_FILIAL = %xFilial:TFF%
		AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
		AND TFF.%NotDel%
		%Exp:cFiltro%
	INNER JOIN %table:TXQ% TXQ
		ON TXQ.TXQ_FILIAL = %xFilial:TXQ%
		AND TXQ.TXQ_CODTFF = TFF.TFF_COD
		AND TXQ.%NotDel%
	WHERE
		TFL.TFL_FILIAL = %xFilial:TFL%
		AND TFL.TFL_CODPAI = %Exp:cCodTFL% 
		AND TFL.%NotDel%
		%Exp:cCond%
EndSql

While (cAliasTFL)->(!Eof())
	nValor += (cAliasTFL)->QTDARM * (cAliasTFL)->VALORARM
	(cAliasTFL)->(DbSkip())
Enddo

(cAliasTFL)->(DbCloseArea())

Return nValor
