#Include "Protheus.Ch"
#Include "ATFXINT.CH"

Static __lVerKernel := .F.
Static __lStruPrj
Static __lStruRat
Static __lAtfCusPrv := NIL

STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    � AfAtuComple� Autor � Wagner Mobile Costa   � Data � 10.04.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Faz gravacoes complementares nos detalhes a partir variaveis 潮�
北�          � Private                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � SigaAtf                                                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function AfAtuComple(cAlias)

If Type("__CODBAIX") <> "U"
	Replace &(Right(cAlias, 2) + "_CODBAIX") With __CODBAIX
Endif

If cAlias = "SN3" .And. Type("__IDBAIXA") <> "U"
	Replace N3_IDBAIXA With __IDBAIXA
Endif

Return .T.

//--------------------------ATF X MNT----------------------//

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矨FGRBXIntMnt� Autor � Ng Informatica        � Data �25/04/2008潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Baixa do imobilizado com integracao com SIGAMNT              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cCodBemMNT - Codigo do bem (SN1->N1_CODBEM)                  潮�
北�          � dDataBaixa - Data da baixa (SN1->N1_BAIXA)                   潮�
北�          � cRotina    - Rotina de baixa (ATFA030 / ATFA035)             潮�
北�          � lEstorno   - Indica se a baixa foi estornada, para limpeza   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorna   � Nil                                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � ATFA030 / ATFA035                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪履哪哪哪哪哪履哪哪穆哪哪哪哪哪幢�
北砇evisao   � ARNALDO R. JUNIOR         矪OPS�00000144464� Data �14/07/2008潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪聊哪哪哪哪哪聊哪哪牧哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function AFGRBXIntMnt(cCodBemMNT,dDataBaixa,cRotina,lEstorno,cNota)

Local aArea := GetArea()

Default dDataBaixa := dDataBase
Default cNota		:= Space(Len(ST9->T9_NFVENDA))

//NGMNTATFBA fun玢o replicada para poder fazer alteracao nos fontes da NG Informatica
NGMNTATFBA(cCodBemMNT,dDataBaixa,cRotina,lEstorno,cNota)
//Caso nao esteja atualizado com o ambiente NG

RestArea(aArea)
Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矨FVLBXIntMnt� Autor � Ng Informatica        � Data �25/04/2008潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Consiste se o bem integrado com o Manutencao da Ativo pode   潮�
北�          � ser baixado                                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cCodBemMNT - Codigo do bem (SN1->N1_CODBEM)                  潮�
北�          � dDataBaixa - Data da baixa (SN1->N1_BAIXA)                   潮�
北�          � cRotina    - Rotina de baixa (ATFA030 / ATFA035)             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorna   � .F.=Sem relacionamento,.T.= Com relacionamento               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � ATFA030 / ATFA035                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪履哪哪哪哪哪履哪哪穆哪哪哪哪哪幢�
北砇evisao   � ARNALDO R. JUNIOR         矪OPS�00000144464� Data �14/07/2008潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪聊哪哪哪哪哪聊哪哪牧哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function AFVLBXIntMnt(cCodBemMNT,dDataBaixa,cRotina)

Local aArea 	:= GetArea()

Local lRet

Default dDataBaixa := dDataBase

//NGMNTATFIN fun玢o replicada para poder fazer alteracao nos fontes da NG Informatica
lRet := NGMNTATFIN(cCodBemMNT,dDataBaixa,cRotina)

RestArea(aArea)

Return lRet

//--------------------------ATF X PCO----------------------//

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯屯屯屯屯送屯屯脱屯屯屯屯屯屯槐�
北篜rograma  矨tf_IntPco 篈utor 砅aulo Carnelossi     � Data �  24/10/06  罕�
北掏屯屯屯屯拓屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯屯屯屯屯释屯屯拖屯屯屯屯屯屯贡�
北篋esc.     砇otina para integracao Ativo Fixo com modulo de Planej. e   罕�
北�          矯ontrole Orcamentario PCO  (inclusao do ativo)              罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

Function Atf_IntPco(aRecAtf,aPadPCO)
Local nX, nY, nZ, cAlias
Local aArea := GetArea()
Local aAreaAlias
Local cPadPco	:= ""
Local cItPco	:= ""
Local cProgPco	:= ""

Default aPadPCO := {}

//Ordena o array por alias
ASORT(aRecAtf,,, { |x, y| y[1] < x[1] })

//Inicia processo gravacao no PCO - qdo chamado NF DE ENTRADA
If Alltrim(Upper(FunName())) $ "ATFA012;MATA103"
	If Len(aPadPCO) == 0
		PcoInilan("000154")
	ENdIf
EndIf

For nX := 1 TO Len(aRecAtf)
	
	cAlias := aRecAtf[nX, 1]
	aAreaAlias := (cAlias)->(GetArea())
	
	dbSelectArea(cAlias)
	
	//processa as exclusoes dos registros
	For nY := 1 TO Len(aRecAtf[nX, 3])
		dbGoto(aRecAtf[nX, 3, nY])
		If Len(aPadPCO) == 0
			If cAlias == "SN1"
				PcoDetLan("000154","01","ATFA010", .T.)
			ElseIf 	cAlias == "SN3"
				PcoDetLan("000154","02","ATFA010", .T.)
			ElseIf 	cAlias == "SN4"
				PcoDetLan("000154","03","ATFA010", .T.)
			EndIf
		Else
			If cAlias == "SN4"
				PcoDetLan(aPadPCO[1],aPadPCO[2],aPadPCO[3], .T.)
			EndIf
		EndIf
	Next //nY
	
	//processa as inclusoes e alteracoes dos registros
	For nZ := 1 TO Len(aRecAtf[nX, 2])
		dbGoto(aRecAtf[nX, 2, nZ])
		If Len(aPadPCO) == 0
			If cAlias == "SN1"
				PcoDetLan("000154","01","ATFA010")
			ElseIf 	cAlias == "SN3"
				PcoDetLan("000154","02","ATFA010")
			ElseIf 	cAlias == "SN4"
				PcoDetLan("000154","03","ATFA010")
			EndIf
		Else
			If cAlias == "SN4"
				PcoDetLan(aPadPCO[1],aPadPCO[2],aPadPCO[3])
			EndIf
		EndIf
	Next //nZ
	
	RestArea(aAreaAlias)
Next

If Alltrim(Upper(FunName())) $ "ATFA012;MATA103"
	If Len(aPadPCO) == 0
		PcoFinLan("000154")
	ENdIf
EndIf

RestArea(aArea)

Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯退屯屯脱屯屯屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯槐�
北篜rograma  砅co_aRecno 篈utor砅aulo Carnelossi       � Data � 24/10/06  罕�
北掏屯屯屯屯拓屯屯屯屯屯褪屯屯拖屯屯屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯贡�
北篋esc.     矨rmazena os recnos em um array para utiliza-los na integra- 罕�
北�          砪ao com modulo PCO                                          罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

Function Pco_aRecno(aRecAtf, cAliasAtf, nOpcAtf)
Local nPos

//array aRecAtf tera o seguinte layout
//posicao 1 - caliasAtf
//posicao 2 - array contendo os recnos incluidos ou alterados
//posicao 3 - array contendo os recnos excluidos

If nOpcAtf == 2
	//se for inclusao ou alteracao --- posicao 2 do array
	If (nPos := Ascan(aRecAtf,{|x| x[1] = cAliasAtf } )) == 0  // primeiro procura ALIAS <cAliasAtf>
		aAdd(aRecAtf, { cAliasAtf , { (cAliasAtf)->(Recno()) },  {} } )
	Else
		//se ja existe o alias SN4 entao procura se existe o recno no 3o. elemento
		If ( Ascan(aRecAtf[nPos,2],{|x| x == (cAliasAtf)->(Recno()) } ) ) == 0
			aAdd(aRecAtf[nPos, 2], (cAliasAtf)->(Recno()) )
		EndIf
	EndIf
ElseIf nOpcAtf == 3
	//se for exclusao --- posicao 3 do array
	If (nPos := Ascan(aRecAtf,{|x| x[1] = cAliasAtf } ) ) == 0  // primeiro procura ALIAS <cAliasAtf>
		aAdd(aRecAtf, {cAliasAtf, { },  { (cAliasAtf)->(Recno()) } } )
	Else
		//se ja existe o alias <cAliasAtf> entao procura se existe o recno no 3o. elemento
		If (Ascan(aRecAtf[nPos,3],{|x| x == (cAliasAtf)->(Recno()) } ) ) == 0
			aAdd(aRecAtf[nPos, 3], (cAliasAtf)->(Recno()) )
		EndIf
	EndIf
EndIf

Return

//--------------------------ATF X CIAP (FISCAL)----------------------//


/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    矨TFXBXCIAP � Autor � TOTVS SA             � Data � 10.08.10 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Funcao que realiza a baixa de um registro de CIAP vinculado潮�
北�          砤 uma ficha de imobilizado                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矨TFBxaCiap(cMoedaAtf,cRotina,dDataBaixa,cMotivo,cSerie,cNota潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Atfa250                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function ATFXBXCIAP(cBaseAF,cItemAF,cMoedaAtf,cRotina,dDataBaixa,cMotivo,nValBaixa,cSerie,cNota,nSf9Ciap,nSf9Estorn,nSldParc,nQtdParc,cSF9_CODBAIX,nSeqSFA)
LOCAL aArea     := GetArea()
LOCAL dLei102   := GetNewPar("MV_DATCIAP",CTOD("01/01/2001"))
LOCAL lCredito  := .F.
LOCAL nRegSN3   := 0
LOCAL nVlOrig   := 0
LOCAL nPropSF9  := 0
LOCAL nFatorSFA := 0
LOCAL nVlrSFA   := 0

DEFAULT cSerie  := ""
DEFAULT cNota   := ""
DEFAULT nSf9Estorn := 0
DEFAULT nSeqSFA := 0

dbSelectArea("SN1")
dbSetOrder(1)
IF ( dbSeek(xFilial("SN1")+cBaseAF+cItemAF) )
	dbSelectArea("SF9")
	dbSetOrder(1)
	If ( dbSeek(xFilial("SF9")+SN1->N1_CODCIAP) )
		If ( SF9->F9_DTENTNE >= dLei102 )
			lCredito:= .T.
		Else
			lCredito:= .F.
		EndIf
		//Inclus鉶 das vari醰eis recebendo o VALICMS e o VLESTOR
		nSf9Ciap:= SF9->F9_VALICMS
		nSf9Estorn:= SF9->F9_VLESTOR
		If cPaisLoc == "BRA"		
			nSldParc  := SF9->F9_SLDPARC
			nQtdParc  := SF9->F9_QTDPARC
			If Empty(cSF9_CODBAIX) .and. !Empty(SF9->F9_CODBAIX)
				cSF9_CODBAIX := SF9->F9_CODBAIX
			EndIf
		EndIf
		dbSelectArea("SN3")
		dbSetOrder(1)
		nRegSN3 := SN3->(Recno())
		SN3->(dbSeek(xFilial("SN3")+SN1->N1_CBASE+SN1->N1_ITEM))
		While ( SN3->(!Eof()) .And. xFilial("SN3")==SN3->N3_FILIAL .And.;
			SN1->N1_CBASE ==SN3->N3_CBASE  .And.;
			SN1->N1_ITEM  ==SN3->N3_ITEM )
			
			//N翺 considerar neste campo o valor do parametro MV_ATFMOED
			// apos solicita玢o da equipe de fiscal definido que o calculo
			//  de CIAP devera ser SEMPRE  em moeda1
			nVlOrig += &('SN3->N3_VORIG1')
			
			dbSelectArea("SN3")
			dbSkip()
		EndDo
		dbSelectArea("SN3")
		dbGoto(nRegSN3)
		nPropSF9 := NoRound((nValBaixa*(SN1->N1_ICMSAPR-nSf9Estorn))/nVlOrig,2)
		nFatorSFA:= (Year(SF9->F9_DTENTNE)+If(lCredito,4,5)-Year(dDataBaixa))
		nVlrSFA  := Round(nPropSF9*nFatorSFA*IIf(lCredito,0.25,0.20),4)
		RecLock("SF9",.F.)
		SF9->F9_DOCNFS := cNota
		SerieNfId('SF9',1,'F9_SERNFS',,,,SN1->N1_NSERIE)
		SF9->F9_DTEMINS:= dDataBaixa
		SF9->F9_MOTIVO := If(Val(SubStr(cMotivo,1,2))==1,"1",If(Val(SubStr(cMotivo,1,2))==10,"3","2"))
		SF9->F9_BXICMS += nPropSF9
		MsUnLock()
		If SN3->N3_TIPO == '01'
			RecLock("SFA",.T.)
			SFA->FA_FILIAL := xFilial("SFA")
			SFA->FA_DATA   := dDataBaixa
			SFA->FA_TIPO   := "2"
			SFA->FA_VALOR  := nVlrSFA
			SFA->FA_FATOR  := nFatorSFA * Iif(lCredito,0.25,0.20)
			SFA->FA_CODIGO := SF9->F9_CODIGO
			SFA->FA_ROTINA := cRotina
			SFA->FA_CREDIT := Iif(lCredito,"1","2") //1-Credito; 2-Debito
			//Segundo Vitor N3-FISCAL no campo FA_MOTIVO deve gravar mesmo conteudo do F9_MOTIVO para uso SPED PIS/COFINS
			SFA->FA_MOTIVO := SF9->F9_MOTIVO
		
			If ColumnPos('FA_SEQ') > 0 
				SFA->FA_SEQ	   := StrZero(nSeqSFA,3)
			EndIf
						
			MsUnLock()
		EndIf
		RecLock("SN3")
		SN3->N3_BXICMS := nPropSF9
		MsUnlock()
	EndIf
Endif
RestArea(aArea)
Return

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    矨TFXGRCIAP � Autor � TOTVS SA             � Data � 10.08.10 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Funcao que realiza a inclusao de um registro de CIAP       潮�
北�          硋inculado a uma ficha de imobilizado                        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矨TFGRVCIAP(cCODCIAP, cERRCIAP, cF9Desc, cF9Fornece,;		  潮�
北�          砪F9LojaFor, cF9Doc, cF9Serie, cF9Item, cF9FormProp,;		  潮�
北�          砫F9DtDigit, dF9DtEmiss, nF9ValICMS, cF9Rotina, cF9CFOP,;	  潮�
北�          硁F9PercICMS, nLinha, nSf9Ciap, nSf9Estorn, nSf9SldApr )	  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Atfa250                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function ATFXGRCIAP(cCODCIAP, cERRCIAP, cF9Desc, cF9Fornece, cF9LojaFor, cF9Doc,;
cF9Serie, cF9Item, cF9FormProp, dF9DtDigit, dF9DtEmiss, nF9ValICMS, cF9Rotina, cF9CFOP, nF9PercICMS, nLinha, nSf9Ciap, nSf9Estorn, nSf9SldApr,nSldParc,nQtdParc,cSF9_CODBAIX,;
nF9IcmCmp,nF9VlDbAt,nF9VlIcco, nValIcst, nValFret, __lAgrupComp, cF9Chave,cNumCta, cNumccus, cFunBem)
LOCAL aArea 	 := GetArea()
LOCAL lRet  	 := .T.
LOCAL nF9VlEstor := 0
Local nF9IcmImob := 0

// SUGESTAO DE CAMPOS DEFAULT A REVISAR
DEFAULT cF9Fornece  := ""
DEFAULT cF9LojaFor  := ""
DEFAULT cF9FormProp := "N"
DEFAULT nSF9Ciap    := 0
DEFAULT	nSF9Estorn  := 0
DEFAULT	nSF9SldApr  := 0
Default cSF9_CODBAIX:= " "
DEFAULT lAgrupComp  := .F.
Default cF9Chave 	:= ""

//TRATAMENTO PARA RETORNO DO VALOR DE ICMS CR蒁ITO

If nLinha==Len(aCols)
	nF9VlEstor := nSf9Estorn-nSf9SldApr
Else
	If nSF9Ciap > 0
		nF9VlEstor:= (nSf9Estorn/nSf9Ciap)*nF9ValICMS
		nSf9SldApr+=nF9VlEstor
	Endif
Endif
nF9IcmImob := nF9ValICMS/nQtdParc*nSldParc
// CRIAR VALIDACAO DE CAMPOS OBRIGATORIOS
// TRATAMENTO DA VARI罺EL LRET
//F9_FILIAL+F9_CODIGO

If !__lAgrupComp
	cCODCIAP := CriaVar("F9_CODIGO",.T.)
	RecLock("SF9",.T.)
Else
	If !SN1->(MsSeek(xFilial("SN1")+aCols[1][1]+aCols[1][2]))
		lRet := .F.
	Else
		cCODCIAP := SN1->N1_CODCIAP //Salva c骴igo do bem principal
		SF9->(dbSetOrder(1))
		If SF9->(dbSeek(xFilial("SF9")+cCODCIAP))
			SF9->(RecLock("SF9",.F.))
		EndIf
	EndIf 
EndIf

If lRet
	SF9->F9_FILIAL := xFilial("SF9")
	SF9->F9_CODIGO := cCODCIAP

	If !__lAgrupComp
		SF9->F9_DESCRI := cF9Desc
		SF9->F9_FORNECE := cF9Fornece
		SF9->F9_LOJAFOR := cF9LojaFor
		SF9->F9_DOCNFE := cF9Doc
		SerieNfId('SF9',1,'F9_SERNFE',,,cF9Serie)
		SF9->F9_ITEMNFE := cF9Item
	EndIf
	SF9->F9_PROPRIO:= cF9FormProp
	SF9->F9_DTENTNE:= dF9DtDigit
	SF9->F9_DTEMINE:= dF9DtEmiss
	SF9->F9_VALICMS:= nF9IcmImob
	SF9->F9_ROTINA := cF9Rotina
	SF9->F9_CFOENT := cF9CFOP
	SF9->F9_PICM   := nF9PercICMS
	SF9->F9_VLESTOR:= 0
	SF9->F9_ICMIMOB:= nF9IcmImob
	SF9->F9_VALICMP:= nF9IcmCmp
	SF9->F9_VLDBATV:= nF9VlDbAt	
	SF9->F9_VALICCO:= nF9VlIcco
	SF9->F9_VALICST:= nValIcst 
	SF9->F9_VALFRET:= nValFret
	SF9->F9_CHAVENF:= cF9Chave
	SF9->F9_PLCONTA	:= cNumCta
	SF9->F9_CCUSTO	:= cNumccus
	SF9->F9_FUNCIT  := cFunBem 

	If FWIsInCallStack("Af251Grava")
		SF9->F9_DTINIUT:= dDtIniCIAP // Variavel private declarada no fonte ATFA251
	EndIf

	If cPaisLoc == "BRA"
		SF9->F9_SLDPARC:= nQtdParc
		SF9->F9_QTDPARC:= nQtdParc
		SF9->F9_CODBAIX := cSF9_CODBAIX
		SF9->F9_TIPO	:= "01"   
	EndIf
	SF9->( MsUnLock() )

	If __lSX8 .And. !__lAgrupComp
		ConfirmSX8()
	EndIf
EndIf 

RESTAREA(aArea)
RETURN(lRet)

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    矨TFXMVCIAP � Autor � TOTVS SA             � Data � 10.08.10 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Funcao que realiza a remocao de um registro de CIAP quando 潮�
北�          � da exclusao da ficha de ativo vinculada a ele.             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � ATFRMVCIAP(cCODCIAP)                                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Atfa250                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function ATFXMVCIAP(cCODCIAP,lBmContrAg)
LOCAL aArea		:= GetArea()
LOCAL lRet 		:= .F.
Local cQuery	:= ""
Local cTab		:= GetNextAlias()
// Local cValIcms  := ""
Local cSldParc  := ""


Default lBmContrAg:= .F.

dbSelectArea("SF9")
dbSetOrder(1)

If ( MsSeek(xFilial("SF9")+cCODCIAP) )
	dbSelectArea("SFA")
	dbSetOrder(1)
	If IsInCallStack("ATFA040")
		// cValIcms := SF9->F9_VALICMS
		cSldParc := SF9->F9_SLDPARC 
	EndIf
	If ( MsSeek(xFilial("SFA")+SF9->F9_CODIGO) )
		While ( !Eof() .And. xFilial("SFA")==SFA->FA_FILIAL .And.;
			SFA->FA_CODIGO==SF9->F9_CODIGO )
			RecLock("SFA")
			dbdelete()
			MsUnLock()
			dbSkip()
		EndDo
	EndIf
	If lBmContrAg
		RecLock("SF9",.F.)
		F9_VALICMS := 0
		F9_ROTINA  :="ATFA012"
		F9_CFOENT  :=""
		F9_PICM    :=0
		F9_ICMIMOB :=0
		F9_QTDPARC :=0
		F9_SLDPARC :=0
		F9_TIPO    :="02"
		F9_CODBAIX :=""
		F9_VALICMP := 0
		F9_VALICCO := 0 
		F9_VALICST := 0
		F9_VALFRET := 0
		F9_VLDBATV := 0
		MsUnLock()
		lRet := .T.
	Else
		RecLock("SF9")
		dbDelete()
		MsUnLock()
		lRet := .T.
	EndIf
EndIf

//Busca componentes baixados pelo Bem Principal
If Select(cTab) > 0
	(cTab)->(dbCloseArea())
EndIf

cQuery := " SELECT F9_CODIGO " 
cQuery += " FROM " + RetSqlName("SF9")
cQuery += " 	WHERE F9_FILIAL = '" + xFilial("SF9") + "'"
cQuery += " 	AND F9_CODBAIX = '" + cCODCIAP + "'"
cQuery += " 	AND D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cTab)

(cTab)->(dbGoTop())

//Limpa C骴igo de baixa dos componentes
While (cTab)->(!EOF())	.And. !lBmContrAg
	If SF9->(MsSeek(xFilial("SF9") + (cTab)->F9_CODIGO))
		SF9->(RecLock("SF9", .F.))
		SF9->F9_CODBAIX := ""
		If IsInCallStack("ATFA040")
			// SF9->F9_VALICMS := cValIcms 
			SF9->F9_SLDPARC := cSldParc
		EndIf
		SF9->(MsUnLock())	
	EndIf

	(cTab)->(dbSkip())
EndDo

(cTab)->(dbCloseArea())

RestArea(aArea)
RETURN(lRet)

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    矨TFXRSCIAP � Autor � TOTVS SA             � Data � 10.08.10 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Funcao que restaura um registro de CIAP baixado em fun玢o  潮�
北�          � do cancelamento desta operacao                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � ATFRSTCIAP(cCODCIAP)										  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Atfa250                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function ATFXRSCIAP(cCodCIAP,nPropSF9)
LOCAL aArea     	:= GetArea()
LOCAL dDataBaixa    := CTOD("")

dbSelectArea("SF9")
dbSetOrder(1)
If dbSeek(xFilial("SF9")+cCodCIAP)
	
	dDataBaixa		:= SF9->F9_DTEMINS
	nPropSF9		:= SF9->F9_BXICMS
	
	RecLock("SF9")
	SF9->F9_DOCNFS 	:= ""
	SF9->F9_SERNFS 	:= ""
	SF9->F9_MOTIVO 	:= ""
	SF9->F9_DTEMINS	:= CTOD("")
	If IsInCallStack("ATFA040")
		SF9->F9_VALICMS := SF9->F9_BXICMS 
	EndIf
	SF9->F9_BXICMS	:= 0
	MsUnLock()
	
	DbSelectArea("SFA")
	DbSetOrder(1)
	IF DbSeek(xFilial("SFA")+cCodCIAP+DTOS(dDataBaixa)+"2")
		RecLock("SFA",.F.)
		DbDelete()
		MsUnLock()
	ENDIF
	
ENDIF
RestArea(aArea)
Return


/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    矨TFBxaCiap � Autor � Evaldo V. Batista    � Data � 14.08.08 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Funcao que realiza a baixa de um registro de CIAP vinculado潮�
北�          砤 uma ficha de imobilizado                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矨TFBxaCiap(cMoedaAtf,cRotina,dDataBaixa,cMotivo,cSerie,cNota潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Atfa250                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function ATFBXACIAP(cBaseAF,cItemAF,cMoedaAtf,cRotina,dDataBaixa,cMotivo,nValBaixa,cSerie,cNota,nSf9Ciap,nSf9Estorn,nSldParc,nQtdParc, cSF9_CODBAIX,nSeqSFA)
Return ATFXBXCIAP(cBaseAF,cItemAF,cMoedaAtf,cRotina,dDataBaixa,cMotivo,nValBaixa,cSerie,cNota,@nSf9Ciap,@nSf9Estorn,@nSldParc,@nQtdParc, @cSF9_CODBAIX,@nSeqSFA)


/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    矨TFGRVCIAP � Autor � Evaldo V. Batista    � Data � 14.08.08 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Funcao que realiza a inclusao de um registro de CIAP       潮�
北�          硋inculado a uma ficha de imobilizado                        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矨TFGRVCIAP(cCODCIAP, cERRCIAP, cF9Desc, cF9Fornece,;		  潮�
北�          砪F9LojaFor, cF9Doc, cF9Serie, cF9Item, cF9FormProp,;		  潮�
北�          砫F9DtDigit, dF9DtEmiss, nF9ValICMS, cF9Rotina, cF9CFOP,;	  潮�
北�          硁F9PercICMS, nLinha, nSf9Ciap, nSf9Estorn, nSf9SldApr )	  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Atfa250                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function ATFGRVCIAP(cCODCIAP, cERRCIAP, cF9Desc, cF9Fornece, cF9LojaFor, cF9Doc,;
cF9Serie, cF9Item, cF9FormProp, dF9DtDigit, dF9DtEmiss, nF9ValICMS, cF9Rotina, cF9CFOP, nF9PercICMS, nLinha, nSf9Ciap, nSf9Estorn, nSf9SldApr,nSldParc,nQtdParc,cSF9_CODBAIX,;
nF9IcmCmp,nF9VlDbAt,nF9VlIcco, nValIcst, nValFret, __lAgrupComp, cF9Chave,cNumCta, cNumccus, cFunBem)

RETURN ATFXGRCIAP(@cCODCIAP, @cERRCIAP, cF9Desc, cF9Fornece, cF9LojaFor, cF9Doc,;
cF9Serie, cF9Item, cF9FormProp, dF9DtDigit, dF9DtEmiss, nF9ValICMS, cF9Rotina, cF9CFOP, nF9PercICMS, nLinha, nSf9Ciap, nSf9Estorn, nSf9SldApr,nSldParc,nQtdParc,cSF9_CODBAIX,;
nF9IcmCmp,nF9VlDbAt,nF9VlIcco, nValIcst, nValFret, __lAgrupComp, cF9Chave,cNumCta, cNumccus, cFunBem)


/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    矨TFRMVCIAP � Autor � Evaldo V. Batista    � Data � 14.08.08 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Funcao que realiza a remocao de um registro de CIAP quando 潮�
北�          � da exclusao da ficha de ativo vinculada a ele.             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � ATFRMVCIAP(cCODCIAP)                                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Atfa250                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function ATFRMVCIAP(cCODCIAP,lBmContrAg)
RETURN ATFXMVCIAP(@cCODCIAP,lBmContrAg)

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    矨TFRSTCIAP � Autor � Evaldo V. Batista    � Data � 14.08.08 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Funcao que restaura um registro de CIAP baixado em fun玢o  潮�
北�          � do cancelamento desta operacao                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � ATFRSTCIAP(cCODCIAP)										  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Atfa250                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function ATFRSTCIAP(cCodCIAP,nPropSF9)
Return ATFXRSCIAP(cCodCIAP,nPropSF9)

//------------------ATF X CTB -------------------------------//

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    � LoteAtf  � Autor � Wagner Xavier         � Data � 30/09/93 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Devolve o numero do lote do Ativo Fixo                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpC1:= AtfLote( )                                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪� 哪哪哪哪哪哪拇北
北� Uso      � SIGAATF                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function AtfLote( )
Local cLote
Local cAlias := Alias()
dbSelectArea( "SX5" )
dbSeek( xFilial("SX5") + "09ATF" )
If Eof()
	Help( " ", 1, "NOLOTCONT" )
	cLote := Space(Iif(CtbInUse(),6,4))
Else
	If CtbInUse()
		cLote := Alltrim(SX5->X5_DESCRI)
	Else
		cLote := Substr(SX5->X5_DESCRI,1,4)
	Endif
Endif

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Verifica se � um EXECBLOCK e caso sendo, executa-o                     �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If At(UPPER("EXEC"),SX5->X5_DESCRI) > 0
	cLote := &(SX5->X5_DESCRI)
	cLote := Substr(cLote,1,Iif(CtbInUse(),6,4))
Endif
dbSelectArea(cAlias)

Return cLote

//------------------------ATF X DIOPS ----------------------------------//

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲uncao    � ATFDIOPS    � Autor � Pedro Pereira Lima      � Data � 03/06/09 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escri噮o � Cria arquivo temporario AT2 com informacoes do ativo vinculado  潮�
北�          � conforme dados da ANS.                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砈intaxe   � ATFDIOPS()                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   � NENHUM                                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       � DIOPS.INI                                                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros� cGrupo - Se "1", tipo de bem investimento, se "2" tipo de bem   潮�
北�          � imovel. Informacoes referentes ao ativo vinculado.              潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
FUNCTION ATFDIOPS(cGrupo)

Local aArea 		:= GetArea()
Local cQuery     	:= ""
Local cTypes10		:= IIF(lIsRussia,"|" + AtfNValMod({1}, "|"),"") // CAZARINI - 30/03/2017 - If is Russia, add new valuations models - main models
Local cTypes		:= "01|10" + cTypes10

Default cGrupo 		:= ""

cQuery := "SELECT "
cQuery += "	SN3.N3_VORIG1, SN1.N1_TPCUSTD, SN1.N1_CODCUSD, SN1.N1_AQUISIC, SN3.N3_DINDEPR, SN1.N1_TPBEM, SN1.N1_QUANTD, "
cQuery += "	SN1.N1_TPOUTR, SN1.N1_LOGIMOV, SN1.N1_NRIMOV, SN1.N1_COMIMOV, SN1.N1_BAIIMOV, SN1.N1_MUNIMOV, SN1.N1_SIGLAUF, "
cQuery += "	SN1.N1_CEPIMOV, SN1.N1_CODRGI, SN1.N1_NOMCART, SN1.N1_AREA, SN1.N1_BAIXA, SN1.N1_REDE, SN3.N3_TXDEPR1, "
cQuery += "	(SN3.N3_VORIG1 / SN1.N1_QUANTD) AS PRECO_UNITARIO, MAX(SN3B.N3_AQUISIC) DT_AVAL "
cQuery += "FROM " + RetSqlName("SN1") + " SN1 "
cQuery += "LEFT OUTER JOIN " + RetSqlName("SN3") + " SN3  ON SN3.N3_CBASE = SN1.N1_CBASE AND SN3.N3_TIPO IN " + FormatIn(cTypes, "|") + " "
cQuery += "LEFT OUTER JOIN " + RetSqlName("SN3") + " SN3B ON SN3.N3_CBASE = SN1.N1_CBASE AND SN3B.N3_TIPO = '02' "
cQuery += "WHERE "
If cGrupo == "1"
	cQuery += "SN1.N1_TPCUSTD <> ' ' AND "
Else
	cQuery += "SN1.N1_TPCUSTD = ' ' AND "
EndIf
cQuery += "SN1.N1_TPBEM <> ' ' AND SN3.D_E_L_E_T_ <> '*' AND SN3B.D_E_L_E_T_ <> '*' AND SN1.D_E_L_E_T_ <> '*' "
cQuery += "GROUP BY SN3.N3_VORIG1, SN1.N1_TPCUSTD, SN1.N1_CODCUSD, SN1.N1_AQUISIC, SN3.N3_DINDEPR, SN1.N1_TPBEM, SN1.N1_QUANTD, "
cQuery += "	SN1.N1_TPOUTR, SN1.N1_LOGIMOV, SN1.N1_NRIMOV, SN1.N1_COMIMOV, SN1.N1_BAIIMOV, SN1.N1_MUNIMOV, SN1.N1_SIGLAUF, "
cQuery += "	SN1.N1_CEPIMOV, SN1.N1_CODRGI, SN1.N1_NOMCART, SN1.N1_AREA, SN1.N1_BAIXA, SN1.N1_REDE, SN3.N3_TXDEPR1 "

cQuery := ChangeQuery(cQuery)

If Select("AT2") > 0
	dbSelectArea("AT2")
	dbCloseArea()
EndIf


dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"AT2",.T.,.F.)

dbSelectArea("AT2")
dbGoTop()


RestArea(aArea)

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨TFFmtData篈utor  砅edro Pereira Lima  � Data �  03/06/09   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矲ormata a data recebida como parametro para o formato       罕�
北�          砫escrito no SympleType da DIOPS - ANS                       罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � DIOPS                                                      罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function ATFFmtData(cDataStr)
Local cRetData := ""
Default cDataStr := ""

If !Empty(cDataStr)
	cRetData := SubStr(cDataStr,1,4) + "-" + SubStr(cDataStr,5,2) + "-" + SubStr(cDataStr,7,2)
EndIf

Return cRetData

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨TFDtVcto 篈utor  矼arcelo Akama       � Data �  08/06/09   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矯alcula a data de vencimento do ativo no formato descrito   罕�
北�          砫escrito no SympleType da DIOPS - ANS                       罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � DIOPS                                                      罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function ATFDtVcto(cDtIniDepr, nTxDepr)
Local cRetData := ""
Local nY, nM, nD
Local nMeses

DEFAULT cDtIniDepr := ""
DEFAULT nTxDepr := 0

If !Empty(cDtIniDepr)
	dDt := STOD(cDtIniDepr)
	nY  := Year(dDt)
	nM  := Month(dDt)
	nD  := Day(dDt)
	If nTxDepr<>0
		nMeses := Int(1200/nTxDepr)
        nM += nMeses
        nY += Int(nM/12)
        nM := nM % 12
        cRetData := StrZero(nY,4) + '-' + StrZero(nM,2) + '-' + StrZero(nD,2)
	EndIf
EndIf

Return cRetData
//---------------------------FUNCTIONS MOVIDA DO FONTE ATFXATU PARA ATFXINT--------------------//
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯屯屯屯屯突北
北篜rograma  矨TFXMOV   篈utor  矨lvaro Camillo Neto � Data �  18/08/10            罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯屯屯屯屯凸北
北篋esc.     � Rotina de Grava玢o de Movimenta玢o de Ativo Fixo                    罕�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   � .T. / .F.                                                           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros� 01-cFilMov     = Filial da Movimenta玢o                             潮�
北�          � 02-cIDMOV       = Identifica玢o do movimento, passar como referencia潮�
北�          �                = na primeira sequencia do processo e passar o ID     �
北�          �                = criado nas proximas movimenta珲es do processo       �
北�          � 03-dDataMov    = Data da movimenta玢o                              潮�
北�          � 04-cOcorr      = Tipo de movimenta玢o (definida na tabela do SX5 GO)北
北�          � 05-cBase       = C骴igo Base do Bem                                 北
北�          � 06-cItem       = Item   do Bem                                      北
北�          � 07-cTipo       = Tipo do Ativo (definido na tabela SX5 G1)          北
北�          � 08-cSeq        = Sequencia de Aquisi玢o do Bem                      北
北�          � 09-cSeqReav    = Sequencia de reavalia玢o do Bem                    北
北�          � 10-cTipoCnt    = Tipo de conta da movimenta玢o                      北
北�          � 11-nQuantd     = Quantidade da movimenta玢o                         北
北�          � 12-cTpSaldo    = Tipo de saldo da movimenta玢o (tabela do SX5 - SL) 北
北�          � 13-aEntidades  = Entidade cont醔eis do movimento:                   北
北�          �                = [1] = Conta Contabil                               北
北�          �                = [2] = Centro de Custo                              北
北�          �                = [3] = Item COntabil                                北
北�          �                = [4] = Classe de Valor                              北
北�          � 14-aValores    = Valor do Movimento nas multiplas moedas EX:        北
北�          �                = [1] = Moeda 01                                     北
北�          �                = [2] = Moeda 02                                     北
北�          �                = [3] = Moeda 03                                     北
北�          �                = [4] = Moeda 04                                     北
北�          �                = [5] = Moeda 05                                     北
北�          � 15-aDadosComp  = Array com dados complementares                     北
北�          �                = [1] = Taxa M閐ia                                   北
北�          �                = [2] = Taxa da depreciacao                          北
北�          �                = [3] = Motivo da movimenta玢o ( Tabela SX5 - 16)    北
北�          �                = [4] = Codigo de Baixa                             北
北�          �                = [5] = Filial de Origem                             北
北�          �                = [6] = Serie da Nota Fiscal                         北
北�          �                = [7] = Numero da Nota Fiscal                        北
北�          �                = [8] = Valor da Venda                               北
北�          �                = [9] = Endere鏾                                     北
北�          �                = [A] = Quantidade Produzida                         北
北�          �  16-nRecnoSN4  = Recno do registro do SN4 para atualiza玢o           北
北�          �  17-lComple    = Utiliza a fun玢o AfAtuComple                       北
北�          �  21-lOnOff     = Define se a contabiliza玢o ser� On/Off Line		  北
北�          �  22-cPadrao    = Lan鏰mento Padr鉶 utilizado no movimento do Ativo  北
				24 -cUUID	  = Reference to original document UUID
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Function ATFXMOV(cFilMov,cIDMOV,dDataMov,cOcorr,cBase,cItem,cTipo,cBaixa,cSeq,cSeqReav,cTipoCnt,nQuantd,cTpSaldo,aEntidades,aValores,aDadosComp,nRecnoSN4,lComple,lValSN1,lClassifica,lOnOff,cPadrao,cOrigem,cUUID)
Local lRet	  		:= .T.
Local cFilX	   		:= cFilAnt
Local aArea			:= GetArea()
Local aAreaSN1		:= SN1->(GetArea())
Local aAreaSN3		:= SN3->(GetArea())
Local aCTREnt		:= {}
Local aCTRDados		:= {}
Local nX			:= 0
Local lInclui		:= .T.
Local cSN1Filtro	:= SN1->(dbFilter())
Local cSN3Filtro	:= SN3->(dbFilter())
Local nSaveSx8Len 	:= GetSx8Len()
Local lAtfxOcor 	:= ExistBlock("ATFXOCOR")
Local cHora			:= If(Type("cN4_HORA") == "C",cN4_HORA,SubStr(Time(),1,5))
Local lVerPadrao	:= .F.
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)

Default cTpSaldo	:= '1'
Default cIDMOV		:= ""
Default aDadosComp	:= {}
Default aValores	:= {}
Default aEntidades	:= {}
Default cFilMov  	:= cFilAnt
Default nRecnoSN4  	:= 0
Default lComple  	:= .F.
Default nQuantd  	:= 0
Default dDataMov  	:= dDataBase
Default cOcorr  	:= "01"
Default lValSN1  	:= .T.
Default lClassifica  	:= .F.
Default lOnOff	:= .F.
Default cPadrao	:= ""
Default cOrigem 	:= FunName()

lVerPadrao := VerPadrao(cPadrao)
cTpSaldo := IIF(Empty(cTpSaldo),'1',cTpSaldo)

//谀哪哪哪哪哪哪哪哪�
//矻impa os filtros  �
//滥哪哪哪哪哪哪哪哪�
If !Empty(cSN1Filtro)
	SN1->(dbClearFilter())
EndIf

If !Empty(cSN3Filtro)
	SN3->(dbClearFilter())
EndIf

If lAtfxOcor
	cOcorr := ExecBlock("ATFXOCOR",.F.,.F.,{cOcorr})
EndIf


SN1->(dbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM
SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
SN4->(dbSetOrder(1)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ

aAdd(aCTREnt,"N4_CONTA")
aAdd(aCTREnt,"N4_CCUSTO")
aAdd(aCTREnt,"N4_SUBCTA")
aAdd(aCTREnt,"N4_CLVL")

aAdd(aCTRDados,"N4_TXMEDIA")
aAdd(aCTRDados,"N4_TXDEPR")
aAdd(aCTRDados,"N4_MOTIVO")
aAdd(aCTRDados,"N4_CODBAIX")
aAdd(aCTRDados,"N4_FILORIG")
aAdd(aCTRDados,"N4_SERIE")
aAdd(aCTRDados,"N4_NOTA")
aAdd(aCTRDados,"N4_VENDA")
aAdd(aCTRDados,"N4_LOCAL")
aAdd(aCTRDados,"N4_QUANTPR")

cFilAnt := IIF(!Empty(cFilMov),cFilMov,cFilAnt)

If ( !lValSN1 .Or. SN1->(MsSeek( xFilial("SN1")+cBase+cItem )) ) .And. SN3->(MsSeek( xFilial("SN3")+cBase+cItem+cTipo+cBaixa+cSeq))
	
	If Empty(aEntidades)
		aEntidades := ATFXEntid(cTipoCnt)
	EndIf
	
	If !Empty(nRecnoSN4)
		SN4->(dbGoTo(nRecnoSN4))
		cIdMov := SN4->N4_IDMOV
		lInclui := .F.
	EndIf
	
	If Empty(cIDMOV)
		cIdMov := GetSXENum("SN4","N4_IDMOV",,6)
	EndIf
	// Se for passado o nRecnoSN4 o registro ser� travado
	// caso contrario un novo registro ser� incluido na 
	// Tabela SN4
	
	If cTipo != "01" .And. cPaisLoc <> "RUS"
		dbselectarea("SN4")
		dbsetorder(1)
		lInclui := .T.
	Endif
	
	
	Reclock("SN4",lInclui)

	If lInclui .OR. lClassifica
		SN4->N4_FILIAL := xFilial("SN4")
		SN4->N4_CBASE  := cBase
		SN4->N4_ITEM   := cItem
		SN4->N4_TIPO   := cTipo
		SN4->N4_OCORR  := cOcorr
		SN4->N4_DATA   := dDataMov
		SN4->N4_SEQ    := cSeq
		SN4->N4_SEQREAV:= cSeqReav
		SN4->N4_IDMOV  := cIdMov
		SN4->N4_TPSALDO:= cTpSaldo
	EndIf

	If cPaisLoc == "RUS" .AND. lInclui
		SN4->N4_UID			:= RU01UUIDV4()
		If !Empty(cUUID)
			SN4->N4_ORIUID	:= cUUID
		EndIf
		SN4->N4_STORNO		:= &(GetSX3Cache("N4_STORNO", "X3_RELACAO"))
	EndIf
	if cPaisLoc == "RUS" .and. (FWisincallstack("A050CALC") .and. FWisincallstack("A070CALC"))
		SN4->N4_STORNO:= "2"
	endif
	SN4->N4_QUANTD := nQuantd
	SN4->N4_TIPOCNT:= cTipoCnt
	
	If lOnOff .And. !lUsaFlag .And. lVerPadrao //Contabiliza online e n?o tem controle de flag autom醫ico 
		SN4->N4_LA := "S"
	Else
		SN4->N4_LA := "N" //Contabiliza offline ou controle de flag autom醫ico
	EndIf
	
	SN4->N4_ORIGEM := cOrigem
	SN4->N4_LP     := cPadrao
	SN4->N4_HORA   := cHora
	If lValSN1 .AND. cPaisLoc == "BRA" //se esta posicionado em SN1 e tem o campo Calcula PIS
		SN4->N4_CALCPIS := SN1->N1_CALCPIS
	EndIf
	
	If Len(aEntidades) > 0
		For nX := 1 to Len(aCTREnt)
			SN4->&(aCTREnt[nX]) := aEntidades[nX]
		Next nX
	EndIf
	
	If Len(aDadosComp) > 0
		For nX := 1 to Len(aCTRDados)
			If aCTRDados[nX] == 'N4_SERIE'
				SerieNfId('SN4',1,'N4_SERIE',dDataMov,,aDadosComp[nX])
			Else
				SN4->&(aCTRDados[nX]) := aDadosComp[nX]
			EndIf
		Next nX
	EndIf
	
	If Len(aValores) > 0
		For nX := 1 to Len(aValores)
			SN4->&( "N4_VLROC" + cValToChar(nX) ) := aValores[nX]
		Next nX
	EndIf

	If ExistBlock("ATFXMOV")
		ExecBlock( "ATFXMOV", .F., .F. )
	EndIf
	If lComple
		AfAtuComple("SN4")
	EndIf
	FKCOMMIT()
	MsUnlock()
Else
	lRet := .F.
	Conout("ATFXMOV: Bem N鉶 Encontrado :" +xFilial("SN3")+cBase+cItem+cTipo+cBaixa+cSeq )
EndIf

If lRet
	nRecnoSN4 := SN4->(Recno())	
EndIf

//谀哪哪哪哪哪哪哪��
//矯onfirma o IDMOV�
//滥哪哪哪哪哪哪哪��
While (GetSx8Len() > nSaveSx8Len)
	If lRet
		ConfirmSX8()
	Else
		RollBackSX8()
	Endif
End

cFilAnt := cFilX

//谀哪哪哪哪哪哪哪哪�
//砇etorna o filtros�
//滥哪哪哪哪哪哪哪哪�
If !Empty(cSN1Filtro)
	SN1->(DbSetfilter({||&cSN1Filtro},cSN1Filtro))
EndIf

//谀哪哪哪哪哪哪哪哪�
//砇etorna o filtros�
//滥哪哪哪哪哪哪哪哪�
If !Empty(cSN3Filtro)
	SN3->(DbSetfilter({||&cSN3Filtro},cSN3Filtro))
EndIf

RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)
SN4->(dbGoTo(nRecnoSN4))
Return nRecnoSN4

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨TFXEntid 篈utor  矨lvaro Camillo Neto � Data �  01/09/10   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Retorna o Array de entidades cont醔eis para grava玢o       罕�
北�          � do Movimento                                               罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function ATFXEntid(cTipoCnt,cBase,cItem,cTipo,cBaixa,cSeq)
Local aEntidades := {}
Local aArea		 := GetArea()
Local aAreaSN3	 := SN3->(GetArea())
Local cConta	 := ""
Local cCusto 	 := ""
Local cItemCtb	 := ""
Local cClvl      := ""

Default cBase		:= SN3->N3_CBASE
Default cItem		:= SN3->N3_ITEM
Default cTipo		:= SN3->N3_TIPO
Default cBaixa      := SN3->N3_BAIXA
Default cSeq		:= SN3->N3_SEQ

SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ

If SN3->(MsSeek(xFilial("SN3") + cBase + cItem + cTipo + cBaixa + cSeq ))
	If cTipoCnt == "1" // Conta do Bem
		cConta	 := SN3->N3_CCONTAB
		cCusto 	 := SN3->N3_CUSTBEM
		cItemCtb := SN3->N3_SUBCCON
		cClvl    := SN3->N3_CLVLCON
	ElseIf cTipoCnt == "2" // Conta de Corre玢o do Bem
		cConta	 := SN3->N3_CCORREC
		cCusto 	 := SN3->N3_CCCORR
		cItemCtb := SN3->N3_SUBCCOR
		cClvl    := SN3->N3_CLVLCOR
	ElseIf cTipoCnt == "3" // Conta de Despesa Deprecia玢o
		cConta	 := SN3->N3_CDEPREC
		cCusto 	 := SN3->N3_CCDESP
		cItemCtb := SN3->N3_SUBCDEP
		cClvl    := SN3->N3_CLVLDEP
	ElseIf cTipoCnt == "4" // Conta de Deprecia玢o Acumulada
		cConta	 := SN3->N3_CCDEPR
		cCusto 	 := SN3->N3_CCCDEP
		cItemCtb := SN3->N3_SUBCCDE
		cClvl    := SN3->N3_CLVLCDE
	ElseIf cTipoCnt == "5" // Conta de Corre玢o Deprecia玢o Acumulada
		cConta	 := SN3->N3_CDESP
		cCusto 	 := SN3->N3_CCCDES
		cItemCtb := SN3->N3_SUBCDES
		cClvl    := SN3->N3_CLVLDES
	ElseIf cTipoCnt == "6" // Conta de Corre玢o da COnta de Capitaliza玢o
		cConta	 := SN3->N3_CCONTAB
		cCusto 	 := SN3->N3_CUSTBEM
		cItemCtb := SN3->N3_SUBCCON
		cClvl    := SN3->N3_CLVLCON
	EndIf
	
	aAdd(aEntidades,cConta)
	aAdd(aEntidades,cCusto)
	aAdd(aEntidades,cItemCtb)
	aAdd(aEntidades,cClvl)
	
EndIf

RestArea(aAreaSN3)
RestArea(aArea)
Return aEntidades

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨TFXCompl 篈utor  矨lvaro Camillo Neto � Data �  01/09/10   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Retorna o Array com os dados complementares para a grava玢o罕�
北�          � do Movimento                                               罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北�          �          = [1] = Taxa M閐ia                                 北
北�          �          = [2] = Taxa da depreciacao                        北
北�          �          = [3] = Motivo da movimenta玢o ( Tabela SX5 - 16)  北
北�          �          = [4] = Codigo de Baixa                            北
北�          �          = [5] = Filial de Origem                           北
北�          �          = [6] = Serie da Nota Fiscal                       北
北�          �          = [7] = Numero da Nota Fiscal                      北
北�          �          = [8] = Valor da Venda                             北
北�          �          = [9] = Endere鏾                                   北
北�          �          = [A] = Quantidade Produzida                       北
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function ATFXCompl(nTaxaMedia, nTaxaDepr,cMotivo,cCodBaix,cFIlOrig,cSerie,cNota,nVenda,cLocal,cQtdPrd)
Local aDadosComp := {}

Default nTaxaMedia 	:= 0
Default nTaxaDepr 	:= 0
Default cMotivo 	:= ""
Default cCodBaix 	:= ""
Default cFIlOrig 	:= ""
Default cSerie 		:= ""
Default cNota  		:= ""
Default nVenda 		:= 0
Default cLocal 		:= ""
Default cQtdPrd		:= 0

aAdd(aDadosComp,nTaxaMedia)
aAdd(aDadosComp,nTaxaDepr)
aAdd(aDadosComp,cMotivo)
aAdd(aDadosComp,cCodBaix)
aAdd(aDadosComp,cFIlOrig)
aAdd(aDadosComp,cSerie)
aAdd(aDadosComp,cNota)
aAdd(aDadosComp,nVenda)
aAdd(aDadosComp,cLocal)
aAdd(aDadosComp,cQtdPrd)

Return aDadosComp

//--------------------------------------------------------------------------------------------
//Rateio de movimentos do Ativo Fixo
//--------------------------------------------------------------------------------------------
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    � ATFRTMOV   � Autor � Rad�				  � Data � 03/05/11 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭� Prepara os itens do rateio para  passa-los como par鈓etro      潮�
北硃ara a fun玢o AtfRecordMov que ir� gravar o movimento                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Generico                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function ATFRTMOV(cFilAtu,cCodigo,cItem,cTipo,cSeq,dDtMov,cIdMov,aValores,lContabil,cOper,nHdlPrv,cLoteATF,nTotal,cBaixa,cOrigem,cLP,lOnOff)

Local aRet			:= {}
Local aAreas		:= {}
Local aVlrRat		:= {}

Local cKeySN3		:= ""
Local cKeySNV		:= ""
Local cKeySNX		:= ""
Local cRevAtu		:= ""

Local nI			:= 0
Local nVlrRat		:= 0

Local lDone			:= .F.

Default cFilAtu		:= ""
Default cCodigo		:= ""
Default cItem		:= ""
Default cTipo		:= ""
Default cSeq		:= ""
Default dDtMov		:= dDataBase
Default cIdMov		:= ""
Default aValores	:= {}
Default lContabil	:= .F.
Default cOper		:= "1"
Default nHdlPrv		:= 0
Default cLoteATF	:= ""
Default cBaixa		:= "0"
Default cOrigem		:= IIf( cOper == "1", IIf(IsInCallStack("ATFA050") .or. IsInCallStack("ATFA010"),"ATFA050","ATFA036"), IIf(IsInCallStack("ATFA070") .or. IsInCallStack("ATFA010"),"ATFA070","ATFA036"))
Default cLP			:= IIf( cOper == "1", IIf(IsInCallStack("ATFA050") .or. IsInCallStack("ATFA010"),"823","81E"), IIf(IsInCallStack("ATFA070") .or. IsInCallStack("ATFA010"),"828","81F"))
Default lOnOff		:= .T.

//Caso nao exista uma das tabelas no dicionario, aborta a operacao
If !(cPaisLoc $ "ARG|BRA|COS|COL")
	Return(aRet)
Endif

If !AFXVerRat()
	Return(aRet)
EndIf

aAdd(aAreas,SN3->(GetArea()))
aAdd(aAreas,SNV->(GetArea()))

SN3->(DbSetOrder(1))

If !Alltrim(cBaixa) $ "0|1"
	cBaixa := "0"
Endif

If Alltrim(cOper) == "1"
	
	cKeySN3	:= 	PadR(cFilAtu	,TamSx3("NV_FILIAL")[1]) +;
	PadR(cCodigo	,TamSx3("N3_CBASE")[1]) +;
	PadR(cItem		,TamSX3("N3_ITEM")[1]) +;
	PadR(cTipo		,TamSx3("N3_TIPO")[1]) +;
	PadR(cBaixa		,TamSx3("N3_BAIXA")[1])+;
	PadR(cSeq		,TamSx3("N3_SEQ")[1])
	
	If SN3->(DbSeek(cKeySN3))
		If SN3->N3_RATEIO == "1" .and. !Empty(SN3->N3_CODRAT)
			
			cRevAtu := Af011GetRev(SN3->N3_CODRAT)
			
			cKeySNV	:=	PadR(SN3->N3_FILIAL,TamSx3("NV_FILIAL")[1]) +;
			PadR(SN3->N3_CODRAT,TAMSX3("NV_CODRAT")[1]) +;
			PadR(cRevAtu,TamSx3("NV_REVISAO")[1])
			
			SNV->(DbSetOrder(1))
			
			For nI := 1 to len(aValores)
				
				If !Empty(aValores[nI])
					If SNV->(DbSeek(cKeySNV))
						
						If Empty(aRet)
							aRet := {SNV->NV_CODRAT,SNV->NV_REVISAO}
						Endif
						
						While !SNV->(Eof())	 .and. cKeySNV == SNV->NV_FILIAL + Padr(SNV->NV_CODRAT,TamSx3("NV_CODRAT")[1]) + PadR(SNV->NV_REVISAO,TamSx3("NV_REVISAO")[1])
							
							If SNV->NV_MSBLQL == "1" 
								Exit
							Endif
							
							If cOper == "1"
								
								nVlrRat := aValores[nI] * ( SNV->NV_PERCEN / 100 )
								nVlrRat := round(nVlrRat,TamSx3("NX_VLRMOV")[2]) //MsDecimais(1)
							Else
								
								cKeySNX := PadR(cFilAtu,TamSX3("NX_FILIAL")[1])+;
								PadR(SNV->NV_CONTA,TamSx3("NX_NIV01")[1])+;
								PadR(SNV->NV_CC,TamSx3("NX_NIV02")[1])+;
								PadR(SNV->NV_ITEMCTA,TamSx3("NX_NIV03")[1])+;
								PadR(SNV->NV_CLVL,TamSx3("NX_NIV04")[1])+;
								Dtos(dDtMov)+;
								PadR(SN3->N3_TPSALDO,TamSx3("NX_TPSALDO")[1])+;
								strzero(nI,TamSX3("NX_MOEDA")[1])
								
								nVlrRat := SNX->(GetAdvFVal("SNX","NX_VLRMOV",cKeySNX,2))
							Endif
							
							aAdd(aVlrRat,{	cFilAtu,;								//NX_FILIAL
							dDtMov,;								//NX_DTMOV
							cIdMov,;								//NX_IDMOV
							SNV->NV_CODRAT,;						//NX_CODRAT
							SNV->NV_REVISAO,;						//NX_REVISAO
							strzero(nI,TamSX3("NX_MOEDA")[1]),;	//NX_MOEDA
							aValores[nI],;							//NX_VLRBASE
							SN3->N3_TPDEPR,;						//NX_TPDEPR
							SNV->NV_SEQUEN,;						//NX_SEQUEN
							nVlrRat,;								//NX_VLRMOV
							SN3->N3_TPSALDO,;						//NX_TPSALDO
							{	SNV->NV_CONTA,;						//NX_NIV01
							SNV->NV_CC,;						//NX_NIV02
							SNV->NV_ITEMCTA,;					//NX_NIV03
							SNV->NV_CLVL};						//NX_NIV04
							})
							SNV->(DbSkip())
						EndDo
						
						SNV->(DbGotop())
					EndIf
				Endif
			Next nI
			
		Endif
		
	Endif
	
	If len(aVlrRat) > 0
		AtfxSldRat(aVlrRat)
		lDone := AtfRecordMov(aVlrRat,lContabil,nHdlPrv,cLoteATF,@nTotal,cOrigem,cLP,lOnOff)
	Endif
	
Else
	lDone := AtfDeleteMov(cFilAtu,dDtMov,cIdMov,lContabil,nHdlPrv,cLoteATF,@nTotal,@aRet,cOrigem,cLP)
Endif

For nI := 1 to len(aAreas)
	RestArea(aAreas[nI])
Next nI

If !lDone
	aRet := {}
Endif

Return(aRet)

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    � AtfRecordMov   � Autor � Rad�    		  � Data � 02/05/11 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭� Efetua a grava玢o do movimento de Rateio		     		   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Generico                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function AtfRecordMov(aVlrRat,lCtb,nHdlPrv,cLoteATF,nTotal,cOrig,cLP,lOnOff)

Local lRet		:= .F.
Local lContabil	:= .F.

Local nI		:= 0
Local nX		:= 0
Local nOrd		:= 0
Local nHead		:= nHdlPrv

Local cChave    := ""
Local cEntidades:= ""
Local cKeySNW	:= ""
Local cKeySNY	:= ""
Local cOrigem	:= cOrig
Local cLPInUse	:= cLP
Local aArea	:= GetArea()
Local lRatGrv   := ExistBlock("RatGrav")

Default lOnOff		:= .T.

SNW->(DbSetOrder(2))//NW_FILIAL+NW_NIV01+NW_NIV02+NW_NIV03+NW_NIV04+DTOS(NW_DTSALD)+NW_TPSALDO+NW_MOEDA
SNY->(DbSetOrder(2))//NY_FILIAL+NY_NIV01+NY_NIV02+NY_NIV03+NY_NIV04+DTOS(NY_DTSALD)+NY_TPSALDO+NY_MOEDA

If Len(aVlrRat) > 0
	
	If lCtb
		If VerPadrao(cLPInUse)
			lContabil := lCtb
		Endif
	Endif
	
	If lContabil
		If nHead <= 0
			lContabil := .F.
		EndIf
	Endif
	
	Begin Transaction
	
	For nI := 1 to len(aVlrRat)
		//Inclusao dos dados em SNX
		RecLock("SNX",.t.)
		SNX->NX_FILIAL	:= aVlrRat[nI,1]
		SNX->NX_DTMOV	:= aVlrRat[nI,2]
		SNX->NX_IDMOV	:= aVlrRat[nI,3]
		SNX->NX_CODRAT	:= aVlrRat[nI,4]
		SNX->NX_REVISAO	:= aVlrRat[nI,5]
		SNX->NX_MOEDA	:= aVlrRat[nI,6]
		SNX->NX_VLRBASE	:= aVlrRat[nI,7]
		SNX->NX_TPDEPR 	:= aVlrRat[nI,8]
		SNX->NX_SEQUEN 	:= aVlrRat[nI,9]
		SNX->NX_VLRMOV 	:= aVlrRat[nI,10]
		SNX->NX_TPSALDO	:= aVlrRat[nI,11]
		SNX->NX_ORIGEM	:= FunName() 
		SNX->NX_LP			:= cLP 
		SNX->NX_LA			:= Iif(lOnOff,"S","N")
				
		For nX := 1 to len(aVlrRat[nI,12])
			
			cEntity := "NX_NIV" + strzero(nX,2)
			SNX->&(cEntity) := aVlrRat[nI,12,nX]
			
		Next nX
		SNX->(MsUnlock())
						
		
		cKeySNW := xFilial("SNW") + SNX->(NX_NIV01+NX_NIV02+NX_NIV03+NX_NIV04+DTOS(NX_DTMOV)+NX_TPSALDO+NX_MOEDA)
		
		lSeek := SNW->(DbSeek(cKeySNW))
		
		RecLock("SNW",!lSeek)
		SNW->NW_FILIAL 	:= aVlrRat[nI,1]
		SNW->NW_DTSALD	:= aVlrRat[nI,2]
		SNW->NW_MOEDA		:= aVlrRat[nI,6]
		SNW->NW_VLRSALD	+= aVlrRat[nI,10]
		SNW->NW_TPSALDO	:= aVlrRat[nI,11]
		
		For nX := 1 to len(aVlrRat[nI,12])			
			cEntity := "NW_NIV" + strzero(nX,2)
			SNW->&(cEntity) := aVlrRat[nI,12,nX]			
		Next nX
		
		SNW->(MsUnlock())
		
		
		
		cKeySNY := xFilial("SNY") + SNX->(NX_NIV01+NX_NIV02+NX_NIV03+NX_NIV04+DTOS(LastDay(NX_DTMOV))+NX_TPSALDO+NX_MOEDA)
		lSeek := SNY->(DbSeek(cKeySNY))
		
		RecLock("SNY",!lSeek)
		SNY->NY_FILIAL 	:= aVlrRat[nI,1]
		SNY->NY_DTSALD	:= LastDay(aVlrRat[nI,2])	//aVlrRat[nI,2]
		SNY->NY_MOEDA		:= aVlrRat[nI,6]
		SNY->NY_VLRSALD	+= aVlrRat[nI,10]
		SNY->NY_TPSALDO	:= aVlrRat[nI,11]
		
		For nX := 1 to len(aVlrRat[nI,12])
			
			cEntity := "NY_NIV" + strzero(nX,2)
			SNY->&(cEntity) := aVlrRat[nI,12,nX]
			
		Next nX
		SNY->(MsUnlock())
		
		cEntidades := ""
		
		If !lRet
			lRet := .T.
		Endif
		
		If lRet
			If lContabil .And. lOnOff
				If lRatGrv
					ExecBlock("RatGrav",.F.,.F.,{aVlrRat, nI}) 
				EndIf
				nTotal += DetProva(nHead,cLPInUse,cOrigem,cLoteATF,,,,,,,,,{"SNX",SNX->(Recno())})
			Endif
		Endif
		
	Next nI
	
	End Transaction
	
EndIf

RestArea(aArea)
Return(lRet)


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨tfDeleteMov篈utor  矼icrosiga           � Data �  02/13/12   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Exclui o movimento de rateio                               罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function AtfDeleteMov(cFilAtu,dDtMov,cIdMov,lCtb,nHdlPrv,cLoteATF,nTotal,aDadoRat,cOrig,cLP)
Local aArea		:= GetArea()
Local aAreaSN3	:= SN3->(GetArea())
Local aAreaSN1  := SN1->(GetArea())
Local aAreaSN4  := SN4->(GetArea())
Local lRet		:= .F.
Local lContabil	:= .F.

Local nI		:= 0
Local nHead		:= 0

Local cListExc	:= ""
Local nValSNW	:= 0
Local nRecnoSNW := 0
Local nValSNY	:= 0
Local nRecnoSNY := 0

Local aRegAux   := {}
Local nVlrAux   := 0

Local _oHashSNW
Local _oHashSNY
Local _oHashSNX

Local cKeySNX	:= ""
Local cOrigem	:= cOrig
Local cLPInUse	:= cLP
Local cCodRat	:= ""

Local nFilial := TamSX3("NX_FILIAL")[1]
Local nIDMov 	:= TamSX3("NX_IDMOV")[1]
If lCtb
	If VerPadrao(cLPInUse)
		lContabil := lCtb
	Endif
Endif

If lContabil
	
	nHead	:= nHdlPrv
	
	If nHead <= 0
		lContabil := .F.
	EndIf
	
Endif

_oHashSNW := tHashMap():New() //Cria o Objeto do Hash Map SNW
_oHashSNX := tHashMap():New() //Cria o Objeto do Hash Map SNX
_oHashSNY := tHashMap():New() //Cria o Objeto do Hash Map SNY


Begin Transaction
	
	SNX->(DbSetOrder(1))	//NX_FILIAL+DTOS(NX_DTMOV)+NX_IDMOV+NX_TPSALDO+NX_MOEDA
	SNW->(DbSetOrder(2))//NW_FILIAL+NW_NIV01+NW_NIV02+NW_NIV03+NW_NIV04+DTOS(NW_DTSALD)+NW_TPSALDO+NW_MOEDA
	SNY->(DbSetOrder(2))//NY_FILIAL+NY_NIV01+NY_NIV02+NY_NIV03+NY_NIV04+DTOS(NY_DTSALD)+NY_TPSALDO+NY_MOEDA
	
	cKeySNX := PadR(cFilAtu,nFilial) + dtos(dDtMov) + PadR(cIdMov,nIDMov)
	
	If SNX->( dbSeek(cKeySNX) )

		//-------------------------------------------------------------------
		// Altera a ordem para posicionar o SN3 com base no c骴igo do rateio
		//-------------------------------------------------------------------
		SN3->(DBSetOrder(10)) //N3_FILIAL+N3_CODRAT
		SN1->(DBSetOrder(1))  //N1_FILIAL+N1_CBASE+N1_ITEM
		SN4->(DBSetOrder(1))  //N4_FILIAL+N4_CBASE+N4_ITEM

		While !SNX->(Eof()) .AND. cKeySNX == PadR(SNX->NX_FILIAL,nFilial)+ dtos(SNX->NX_DTMOV)+ PadR(SNX->NX_IDMOV,nIDMov)

			//------------------------------------------------------------------
			// Posiciona na SN3 para auxiliar o cliente a criar as regras do LP
			//------------------------------------------------------------------
			If cCodRat != SNX->NX_CODRAT
				SN3->(dbSeek(XFilial("SN3")+SNX->NX_CODRAT))
				SN1->(dbSeek(XFilial("SN3")+SN3->N3_CBASE+SN3->N3_ITEM))
				SN4->(dbSeek(XFilial("SN3")+SN3->N3_CBASE+SN3->N3_ITEM))
				cCodRat := SNX->NX_CODRAT
			EndIf

			cKeySNW := SNX->NX_FILIAL + SNX->(NX_NIV01+NX_NIV02+NX_NIV03+NX_NIV04+DTOS(NX_DTMOV)+NX_TPSALDO+NX_MOEDA)
			If SNW->( dbSeek(cKeySNW) )
				
				nRecnoSNW := SNW->(Recno())

				If ( SNW->NW_VLRSALD - SNX->NX_VLRMOV ) <= 0
					_oHashSNW:Set(nRecnoSNW,0)
				Else
					If _oHashSNW:Get(nRecnoSNW,@nValSNW)
						nValSNW -= SNX->NX_VLRMOV
						_oHashSNW:Set(nRecnoSNW,nValSNW)
					Else
						nValSNW := (SNW->NW_VLRSALD-SNX->NX_VLRMOV)
						_oHashSNW:Set(nRecnoSNW,nValSNW)
					EndIf
				Endif
			Endif
			
			cKeySNY := SNX->NX_FILIAL + SNX->(NX_NIV01+NX_NIV02+NX_NIV03+NX_NIV04+DTOS(LastDay(NX_DTMOV))+NX_TPSALDO+NX_MOEDA)
			If SNY->( dbSeek(cKeySNY) )
			
				nRecnoSNY := SNY->(Recno())

				If ( SNY->NY_VLRSALD - SNX->NX_VLRMOV ) <= 0
					_oHashSNY:Set(nRecnoSNY,0)
				Else
					If _oHashSNY:Get(nRecnoSNY,@nValSNY)
						nValSNY -= SNX->NX_VLRMOV
						_oHashSNY:Set(nRecnoSNY,nValSNY)
					Else
						nValSNY := (SNY->NY_VLRSALD-SNX->NX_VLRMOV)
						_oHashSNY:Set(nRecnoSNY,nValSNY)
					EndIf
				Endif
			Endif
						
			If lContabil
				nTotal += DetProva(nHead,cLPInUse,cOrigem,cLoteATF,,,,,,,,,{"SNX",SNX->(Recno())})
			Endif
			
			_oHashSNX:Set(SNX->(Recno()),0)

			SNX->(DbSkip())
			
			If !lRet
				lRet := .T.
			Endif
		EndDo
		
		
	Endif

	_oHashSNW:List(aRegAux)
	For nI := 1 to Len(aRegAux)
		SNW->(dbGoTo(aRegAux[nI,1]))
		nVlrAux := aRegAux[nI,2]		
		SNW->(RecLock("SNW",.F.))
			If nVlrAux > 0
				SNW->NW_VLRSALD := nVlrAux
			Else
				SNW->(dbDelete())
			EndIf
		SNW->(MsUnlock())
	Next nI
	_oHashSNW:Clean()

	_oHashSNY:List(aRegAux)
	For nI := 1 to Len(aRegAux)
		SNY->(dbGoTo(aRegAux[nI,1]))
		nVlrAux := aRegAux[nI,2]		
		SNY->(RecLock("SNY",.F.))
			If nVlrAux > 0
				SNY->NY_VLRSALD := nVlrAux
			Else
				SNY->(dbDelete())
			EndIf
		SNY->(MsUnlock())
	Next nI
	_oHashSNY:Clean()

	_oHashSNX:List(aRegAux)
	For nI := 1 to Len(aRegAux)
		cListExc += "'"+cValToChar(aRegAux[nI,1])+"',"
		If Mod(nI,1000)==0
			ATDelRat(cListExc)
			cListExc := ""
		EndIf
	Next nI
	_oHashSNX:Clean()
	
	If !Empty(cListExc)
		ATDelRat(cListExc)
	EndIf
	
End Transaction

RestArea(aAreaSN1)
RestArea(aAreaSN3)
RestArea(aAreaSN4)
RestArea(aArea)

Return(lRet)


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨tfxSldRat 篈utor  矼icrosiga           � Data �  02/13/12   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     �                                                            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function AtfxSldRat(aRateio)

Local nI 			:= 0
Local nPos 			:= 0
Local nValTotal		:= 0
Local nVlrBase		:= 0
Local nVlrAbate		:= 0
Local nVlrAcresc	:= 0

Local cAuxFil	:= ""
Local cDtMov	:= ""
Local cIdMov	:= ""
Local cTpSld	:= ""
Local cMoMov	:= ""
/*
NX_FILIAL 	[01]
NX_DTMOV	[02]
NX_IDMOV	[03]
NX_TPSALDO	[11]
NX_MOEDA    [06]
*/

If Len(aRateio) > 0

	aSort(aRateio,,,{|x,y| x[1]+dtos(x[2])+x[3]+x[11]+x[6] < y[1]+dtos(y[2])+y[3]+y[11]+y[6]})

	cAuxFil	:= aRateio[1,1]
	cDtMov	:= dtos(aRateio[1,2])
	cIdMov	:= aRateio[1,3]
	cTpSld	:= aRateio[1,11]
	cMoMov	:= aRateio[1,6]

	For nI := 1 to len(aRateio)

		If aRateio[nI,1]+dtos(aRateio[nI,2])+aRateio[nI,3]+aRateio[nI,11]+aRateio[nI,6] <> cAuxFil+cDtMov+cIdMov+cTpSld+cMoMov
			nValTotal := Round(nValTotal,TamSx3("NX_VLRMOV")[2])
			If nValTotal > nVlrBase
				nVlrAbate := nValTotal - nVlrBase
			ElseIf nValTotal < nVlrBase
				nVlrAcresc := nVlrBase - nValTotal
			Endif

			nPos := aScan(aRateio, {|x| x[1]+dtos(x[2])+x[3]+x[11]+x[6] == cAuxFil+cDtMov+cIdMov+cTpSld+cMoMov})
			aRateio[nPos,10] += Iif(Empty(nVlrAbate),nVlrAcresc,-nVlrAbate)
			nValTotal := 0
		Endif

		nValTotal += aRateio[nI,10]

		cAuxFil	:= aRateio[nI,1]
		cDtMov	:= dtos(aRateio[nI,2])
		cIdMov	:= aRateio[nI,3]
		cTpSld	:= aRateio[nI,11]
		cMoMov	:= aRateio[nI,6]

		nVlrBase:= Round(aRateio[nI,7],TamSx3("NX_VLRMOV")[2])

	Next nI

	nValTotal := Round(nValTotal,TamSx3("NX_VLRMOV")[2])

	If nValTotal > nVlrBase
		nVlrAbate := nValTotal - nVlrBase
	ElseIf nValTotal < nVlrBase
		nVlrAcresc := nVlrBase - nValTotal
	Endif

	aRateio[len(aRateio),10] += Iif(Empty(nVlrAbate),nVlrAcresc,-nVlrAbate)

Endif
Return()

//--------------------------------------------------------------------------------------------
//AVP
//--------------------------------------------------------------------------------------------

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪勘�
北砅rograma  矨fGrvAvp	  � Autor � Mauricio Pequim Jr    � Data �08/10/2011      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪幢�
北矰escri噭o � Gravacao dos dados do Processo de Ajuste a Valor Presente (AVP)    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� 01 cFilial    - Filial do bem                                      潮�
北�          � 02 cProcesso  - Processo do AVP que esta sendo gravado             潮�
北�          �                   1 = Constituicao                                 潮�
北�          �                   2 = Apropriacao                                  潮�
北�          �                   3 = Realizacao                                   潮�
北�          �                   4 = Baixa                                        潮�
北�          � 03 cBase      - Codigo base do ativo                               潮�
北�          � 04 cItem      - Item do ativo                                      潮�
北�          � 05 cTipo      - Tipo do ativo                                      潮�
北�          � 06 cTpSaldo   - Tipo de saldo do ativo                             潮�
北�          � 07 cBaixa     - Ocorrencia de Baixa                                潮�
北�          � 08 cSeq       - Sequencia de Aquisi玢o do Bem                      潮�
北�          � 09 cSeqReav   - Sequencia de reavalia玢o do Bem                    潮�
北�          � 10 nValAVP    - Valor do AVP (referencia)                          潮�
北�          � 11 lContabiliza - Contabiliza estorno                              潮�
北�          � 12 nTotal     - Valor acumulado de contabilizacao                  潮�
北�          � 13 nHdlPrv    - Handle do arquivo de contabilizacao                潮�
北�          � 14 cLoteAtf   - Lote contabil ATF                                  潮�
北�          � 15 nRecnoSN3  - Recno do registro tipo 14 do SN3 (inclusao apenas) 潮�
北�          � 16 cIdProcAvp - ID do processo de apuracao periodica do AVP        潮�
北�          � 17 lBxTotal   - Identifica se eh um processo de baixa total do bem 潮�
北�          � 18 cIdMovAtf  - ID do processo de movto do bem (SN4->N4_IDMOV)     潮�
北�          � 19 nValPres	  - Valor Presente calculado                           潮�
北�          � 20 cRotina    - ID da rotina para contabilizacao                   潮�
北�          � 21 cArquivo   - ID do arquivo para contabilizacao                  潮�
北�          � 22 nRecFNF    - Recno do FNF                                       潮�
北�          � 23 lCvMtDpr   - Flag que informa se origem da chamada eh o processo潮�
北�          �                  de Conversao de Metodo de Depreciacao             潮�
北�          � 24 cIndAvp    - codigo do indice do AVP                            潮�
北�          � 25 cPerInd    - periodicidade do indice do AVP                     潮�
北�          � 26 nRecFNF    - Taxa do indice do AVP                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorna   � Nil                                                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Processos de Ajuste a Valor Presente                               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function AFGrvAvp(cFilMov,cProcesso,dDataMov,cBase,cItem,cTipo,cTpSaldo,cBaixa,cSeq,cSeqReav,nValAVP,;
						lContabiliza,nTotal,nHdlPrv,cLoteAtf,nRecnoSN3,cIdProcAvp,aRecCtb,lBxTotal,cIdMovAtf,;
						nValPres,cRotina,cArquivo,nRecFNF,lCvMtdDpr,cIndAvp,cPerInd,nTaxaInd,dDtExecAVP)

Local lRet	  		:= .T.
Local cFilX	   	:= cFilAnt
Local aArea			:= GetArea()
Local aAreaSN1		:= SN1->(GetArea())
Local aAreaSN3		:= SN3->(GetArea())
Local nX				:= 0 
Local nY				:= 0 
Local lInclui		:= .T.
Local cSN1Filtro	:= SN1->(dbFilter())
Local cSN3Filtro	:= SN3->(dbFilter()) 
Local cRevisao		:= Criavar("FNF_REVIS")
Local nQtdEntid		:= CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
Local cPadrao		:= ""
Local lPadrao		:= .F.
Local lUsaFlag		:= GetNewPar("MV_CTBFLAG",.F.)
Local aFlagCTB		:= {} 
Local cTipoAF		:= '10' 
Local lRealizou	:= .F.
Local lBaixa		:= (IsInCallStack("ATFA030") .OR. IsInCallStack("ATFA035"))
Local lGeraConst	:= .F.
Local cTpMov		:= "1"
Local cIdProcPai	:= ""
Local nTamSeqAVP	:= TamSX3("FNF_SEQAVP")[1]
Local lTransf		:= IsInCallStack("ATFA060")
Local nVAcmAvp		:= 0 
Local lIncAtf		:= IsInCallStack("ATFA010") .OR. IsInCallStack("ATFA251")
Local nValAvpDif	:= 0
Local lDtExec		:= .T.
Local lGrvAvp		:= .F.

Default cFilMov  	:= cFilAnt
Default cProcesso	:= ''
Default dDataMov	:= dDatabase
Default cBase		:= ''
Default cItem		:= ''
Default cTipo		:= ''
Default cTpSaldo	:= '1'
Default cBaixa		:= '0'
Default cSEQ		:= ''
Default cSEQREAV	:= ''
Default nValAvp	:= 0
Default lContabiliza	:= .F.
Default nTotal		:= 0
Default nHdlPrv	:= 0
Default cLoteAtf	:= ''
Default nRecnoSN3 := 0
Default cIdProcAvp:= ""  
Default aRecCtb	:= {}
Default lBxTotal	:= .F.
Default cIdMovAtf	:= "" 
Default nValPres	:= 0
Default cRotina	:= "ATFA010"
Default cArquivo	:= ""
Default nRecFNF	:= 0
Default lCvMtdDpr	:= .F.
Default cIndAvp		:= SN1->N1_INDAVP
Default cPerInd		:= FIT->FIT_PERIOD
Default nTaxaInd    := SN1->N1_TAXAVP
Default dDtExecAvp	:= SN1->N1_DTAVP

cTpSaldo := IIF(Empty(cTpSaldo),'1',cTpSaldo)

//Controle de lancamento - Detprova
LanceiCtb	:= If(Type("LanceiCtb") != "L",.F.,LanceiCtb) 

//谀哪哪哪哪哪哪哪哪�
//矻impa os filtros �
//滥哪哪哪哪哪哪哪哪�
If !Empty(cSN1Filtro) 
	SN1->(dbClearFilter())
EndIf

If !Empty(cSN3Filtro) 
	SN3->(dbClearFilter())
EndIf

SN1->(dbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM 
SN3->(dbSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO

cFilAnt := IIF(!Empty(cFilMov),cFilMov,cFilAnt) 

//Posicionamento do registro SN3
//- para Constituicao, posicionar no Tipo 10
//- para os demais, posicionar no Tipo informado (cTipo)
If cProcesso != '1'
	cTipoAF := cTipo
Endif

//Por padrao, cBaixa vinha vazia
//Por necessidade da Transferencia interfiliais, ela passa a vir preenchida 
//e neste caso, assumo o valor enviado.
If Empty(cBaixa)
	cBaixa := '0'
Endif

//Garanto posicionamento na ficha de ativo
If SN1->(MsSeek( xFilial("SN1")+cBase+cItem )) .And. ;
	SN3->(MsSeek( xFilial("SN3")+cBase+cItem+cTipoAF+cBaixa+cTpSaldo)) .And. ;
	FIT->(MsSeek( xFilial("FIT")+SN1->N1_INDAVP))

	//Constituicao
	If cProcesso == '1' 
		nVlrPres	:= SN3->N3_VORIG1
		nBaseAVP	:= SN3->N3_VORIG1 + nValAvp
 		cSeqAvp	:= If(lIncAtf,'0001',AFGetSeqAvp())
		cTpMov	:= '1'           

		If lBaixa
			If SN3->(MsSeek( xFilial("SN3")+cBase+cItem+'14'+"0"+cTpSaldo))
				nBaseAVP := nVlrPres + SN3->N3_VORIG1
				nVlrPres := nBaseAvp - nValAvp  
				cIdProcPai := FNF->FNF_IDPROC
				If nRecnoSN3 == 0 // Para garantir a grava玢o dos dados cont醔eis no movimento de constitui玢o (FNF)
					nRecnoSN3 := SN3->(Recno())
				EndIf
			Endif
		//Constituicao gerada pela transferencia de bem entre filiais
		ElseIf lTransf .or. lCvMtdDpr
			If nRecFNF > 0
				FNF->(dbGoto(nRecFNF))
				nBaseAVP := FNF->FNF_BASE
				nVAcmAvp := FNF->FNF_ACMAVP
				nVlrPres	:= nValPres				
				cIdProcPai	:= FNF->FNF_IDPROC			
			Endif				
		Endif				
		//Reposiciono no registro Tipo 14
		SN3->(dbGoto(nRecnoSN3))
				
	//2 - Apropriacao por calculo de AVP
	//3 - Apropriacao por baixa de AVP
	ElseIf cProcesso $ '2/3'
		//Tabela FNF esta posicionada no movimento de constituicao ativo.
		nVlrPres := FNF->(FNF_AVPVLP + FNF_ACMAVP )
		nBaseAVP	:= FNF->FNF_BASE
		nRecFNF	:= FNF->(RECNO())	
		cSeqAvp	:= AFGetSeqAvp()
		cRevisao := FNF->FNF_REVIS 
		cTpMov	:= IIF(cProcesso == '2','2','3')
		cIdProcPai := FNF->FNF_IDPROC

		//Verifico se na apuracao foi atingido o valor de realizacao
		//Caso positivo, gravo o processo como Realizacao e nao como Apuracao
		If !lBaixa
			If nBaseAvp == (nVlrPres + nValAvp) .or. (SN1->N1_DTAVP <= dDatabase)
				lRealizou := .T.
			Endif
		Endif		


	//Baixa de AVP
	ElseIf cProcesso == '4'
		//Tabela FNF esta posicionada no movimento de constituicao ativo.
		nVlrPres := FNF->(FNF_AVPVLP + FNF_ACMAVP)
		nBaseAVP	:= FNF->FNF_BASE
		nRecFNF	:= FNF->(RECNO())	
		cSeqAvp	:= AFGetSeqAvp()
		cRevisao := FNF->FNF_REVIS 
		cTpMov	:= '4'
		cIdProcPai := FNF->FNF_IDPROC		
		
		//Verifico se na apuracao foi atingido o valor de realizacao
		//Caso positivo, gravo o processo como Realizacao e nao como Apuracao
		If nBaseAvp != (nVlrPres + nValAvp)
			lGeraConst := .T.
		Else
			lRealizou := .T.
		Endif


	//5 - Realizacao por calculo do AVP
	//6 - Realizacao por baixa do bem
	ElseIf cProcesso $ '5/6'
		//Tabela FNF esta posicionada no movimento de constituicao ativo.
		nVlrPres := FNF->(FNF_AVPVLP + FNF_ACMAVP)
		nBaseAVP	:= FNF->FNF_BASE
		nRecFNF	:= FNF->(RECNO())	
		cSeqAvp	:= AFGetSeqAvp()
		cRevisao := FNF->FNF_REVIS 
		nValAVP	:= FNF->FNF_ACMAVP
		cTpMov	:= IIF(cProcesso == '5','5','6')
		cIdProcPai := FNF->FNF_IDPROC		

	//7 - Baixa por revis鉶
	ElseIf cProcesso == "7"
		nBaseAVP	:= FNF->FNF_BASE
		cSeqAvp		:= AFGetSeqAvp()
		cRevisao	:= FNF->FNF_REVIS
		cTpMov 		:= '7'
		nVlrPres	:= FNF->FNF_AVPVLP
		nValAvp		:= FNF->(FNF_VALOR - FNF_ACMAVP)
		cIdProcPai	:= FNF->FNF_IDPROC
		
	//8 - Constitui玢o por revis鉶
	ElseIf cProcesso == "8"
		nBaseAVP	:= FNF->FNF_BASE
		cSeqAvp		:= STRZERO(1,nTamSeqAVP,0)
		cRevisao	:= AFGetRevAvp()
		cTpMov 		:= '1'
		nVlrPres	:= nValPres
		nRecFNF		:= FNF->(RECNO())
		cIdProcPai	:= FNF->FNF_IDPROC

	//9 - Baixa por transferencia entre filiais
	ElseIf cProcesso == "9"
		nBaseAVP	:= FNF->FNF_BASE
		cSeqAvp	:= AFGetSeqAvp()
		cRevisao	:= FNF->FNF_REVIS
		cTpMov	:= '8'
		nVlrPres	:= nValPres
		nRecFNF	:= FNF->(RECNO())
		cIdProcPai	:= FNF->FNF_IDPROC

	//A - Diferenca de AVP por revisao de taxa
	ElseIf cProcesso == "A"
		nBaseAVP   := FNF->FNF_BASE
		cSeqAvp    := AFGetSeqAvp()
		cRevisao   := FNF->FNF_REVIS
		cTpMov     := '9'	//Ajuste de AVP por revis鉶 (+)
		nVlrPres   := FNF->FNF_AVPVLP
		nValAvpDif := nValAvp
		nValAvp	   := FNF->(FNF_VALOR - FNF_ACMAVP) - nValAvp
		nRecFNF    := FNF->(RECNO())
		cIdProcPai := FNF->FNF_IDPROC  
		If nValAvp < 0 
			cTpMov	:= 'A' //Ajuste de AVP por revis鉶 (-)
		Endif
	Endif

	//Grava registro do FNF
	If nValAvp > 0 .OR. (cTpMov == "A" .and. nValAvp != 0)

		RecLock("FNF",.T.)

		FNF_FILIAL	:= xFilial("FNF")
		FNF_CBASE	:= cBase
		FNF_ITEM	:= cItem
		FNF_TIPO	:= cTipo
		FNF_SEQ		:= cSeq
		FNF_TPSALD	:= cTpSaldo
		FNF_REVIS	:= cRevisao
		FNF_SEQAVP	:= cSeqAvp
		FNF_TPMOV	:= cTpMov
		FNF_DTAVP	:= dDataMov
		FNF_INDAVP	:= cIndAvp
		FNF_PERIND	:= cPerInd
		FNF_TAXA	:= nTaxaInd
		FNF_VALOR	:= ABS(nValAvp)
		FNF_AVPVLP	:= nVlrPres + IIF(cTpMov == "2", nValAvp, 0 )
		FNF_BASE	:= nBaseAVP
		FNF_STATUS	:= "1"
		FNF_MSBLQL	:= "2"
		FNF_MOEDA	:= "01"  //Por enquanto....

		//Se for constituicao, o valor acumulado de AVP eh zero (exceto para transferencias interfiliais)
		//Se for apropriacao, sera gravado do registro de constituicao ativo
		If lTransf .and. cProcesso == '1'
			FNF_ACMAVP	:=	nVAcmAvp
		Else
			FNF_ACMAVP	:= 0		
		Endif

		//Identificador de processo de avp
		FNF_IDPROC	:= cIdProcAVP		
		//Identificador da constituicao ativa no momento do processo (utilizado para cancelamentos)
		FNF_IDPRCP	:= cIdProcPai
		//Identificador de movimento do ativo (SN4->N4_IDMOV)
		FNF_IDMVAF	:= cIdMovAtf
		
		//Grava as entidades contabeis
		FNF_ENT01		:= SN3->N3_CCONTAB				
		FNF_ENT02		:= SN3->N3_CUSTBEM
		FNF_ENT03		:= SN3->N3_SUBCCON
		FNF_ENT04		:= SN3->N3_CLVLCON            
		For nY := 5 to nQtdEntid
			if SN3->(Fieldpos("N3_EC"+StrZero(nY, 2)+"DB" )) > 0 .and. FNF->(FieldPos("FNF_EC"+StrZero(nY, 2)+"DB")) > 0 
				&("FNF_EC"+StrZero(nY, 2)+"DB" )  := SN3->(&("N3_EC"+StrZero(nY, 2)+"DB" ))
			endif	
		Next       

		//Grava data da execucao do AVP na FNF (necessario para revisao de AVP)        
		If lDtExec
			FNF_DTEXEC := dDtExecAvp
		Endif

		FNF->(MsUnlock())
		
		//Confirma que gravou AVP
		lGrvAvp := .T.

		//Recno do novo registro incluso
		nRecNewFNF := FNF->(Recno())
	
		//Posiciono no Tipo 14 ativo para permitir a contabilizacao (entidades contabeis)
		If nRecnoSN3 > 0
		   SN3->(dbGoTo(nRecnoSN3))
		Else
			SN3->(dbSetOrder(11))//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO	
			SN3->(MsSeek( xFilial("SN3")+cBase+cItem+"14"+"0"+cTpSaldo))
		Endif	
	
		cPadrao := AFXPadAVP(cProcesso)
		
		//Contabilizacao do AVP		
		If lContabiliza
	
			lPadrao := VerPadrao(cPadrao)
		                                  										
			If lPadrao 
		
				//Verifico Handle de contabilizacao
				If ValType(nHdlPrv) != "N" .Or. nHdlPrv <= 0
					nHdlPrv := HeadProva(cLoteAtf,cRotina,Substr(cUsername,1,6),@cArquivo)
				EndIf
		
				If nHdlPrv > 0
					//Verifico o uso de Flag contabil automatico	
					If lUsaFlag
						aAdd(aFlagCTB,{"FNF_DTCONT","S","FNF",FNF->(Recno()),0,0,0})
					EndIf
			
					nTotal +=	DetProva(nHdlPrv,cPadrao,cRotina,cLoteAtf,,,,,,,,@aFlagCTB)
			
					If LanceiCtb // Vem do DetProva																								
						If !lUsaFlag
							RecLock("FNF")
							FNF->FNF_DTCONT  := dDatabase
							MsUnlock( )
						EndIf 
					ElseIf lUsaFlag
						If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == FNF->(Recno()) }))>0
							aFlagCTB := Adel(aFlagCTB,nPosReg)
							aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
						Endif
					EndIf		
				Endif					
		   Endif
	   Endif

		FNF->(RecLock("FNF",.F.))	   
		FNF->FNF_LA		:= iIf(lContabiliza,"S","N")
		FNF->FNF_ORIGEM 	:= Funname()
		FNF->FNF_LP		:= cPadrao			
		FNF->(MsUnlock())
			
		If nRecFNF > 0
			FNF->(dbGoto(nRecFNF))
			RecLock("FNF")
	
			//Se processo de apropriacao (baixa ou calculo)
			//Atualizo Valor Acumulado de apropriacoes no registro de constituicao ativo
			//O mesmo se aplica ao movimento de baixa quando esta for TOTAL
			If cProcesso $ '2/3/4/A'
				FNF->FNF_ACMAVP += nValAvp
			//Se processo de Realizacao (baixa ou calculo)
			//Atualizo Status para Encerrado no registro de constituicao ativo
			ElseIF cProcesso $ '5/6/8/9' 
				FNF->FNF_STATUS := '2' //Encerrado
			Endif			 			
				
			FNF_LA		:= iIf(lContabiliza,"S","N")
			FNF_ORIGEM := Funname()
			FNF_LP		:= cPadrao			
	
			MsUnlock( ) 
		Endif
		
		//Atualiza o projeto do Ativo
		If cProcesso $ '1/2/3/4'
			AFGrvPrjAvp(cBase,cItem,'10',cTpSaldo)
		EndIf  
		
		//Volto para o registro novo que foi gerado.
		FNF->(dbGoto(nRecNewFNF))
		aadd(aRecCtb,nRecNewFNF) 
	
		//Se realizou o AVP por calculo do AVP
		//Gravo registro de realizacao do bem
		If cProcesso == '2' .and. lRealizou
			//Posiciono registro de constituicao do AVP Ativo
			FNF->(dbGoto(nRecFNF))
			AfGrvAvp(cFilAnt,"5",dDataMov,FNF->FNF_CBASE,FNF->FNF_ITEM,FNF->FNF_TIPO,FNF->FNF_TPSALD,' ',FNF->FNF_SEQ,,nValAvp,.F.,,,,,cIdProcAVP,aRecCtb)	
		Endif
	
		//Se restou valor de AVP a  por baixa calculo do AVP
		//Gravo registro de de constituicao
		If cProcesso == '4'                                         
			//Caso nao seja baixa total
			//Gravo a realizacao por baixa parcial com valor do AVP acumulado ate o momento.
			If !lRealizou
				nValAvp := FNF->FNF_ACMAVP
			Endif

			//Gravo registro de realizacao do bem
			//Posiciono registro de constituicao do AVP Ativo
			FNF->(dbGoto(nRecFNF))
			AfGrvAvp(cFilAnt,"6",dDataMov,FNF->FNF_CBASE,FNF->FNF_ITEM,FNF->FNF_TIPO,FNF->FNF_TPSALD,' ',FNF->FNF_SEQ,,nValAvp,.F.,,,,,cIdProcAVP,aRecCtb,,cIdMovAtf)	
		Endif
		
		//Grava o RECNO do novo registro para posicionamento antes de gerar os novos tipos 10 e 14
		If cProcesso == '8'
			nRecFNF := nRecNewFNF
		EndIf

		//Restauro o Valor do AVP calculado quando do processo de gravacao de diferenca de AVP por revisao
		If cProcesso == 'A'
			FNF->(dbGoto(nRecFNF))
			nValAvp := nValAvpDif
		EndIf

	Endif
Endif   

cFilAnt := cFilX 

//谀哪哪哪哪哪哪哪哪�
//砇etorna o filtros�
//滥哪哪哪哪哪哪哪哪�
If !Empty(cSN1Filtro) 
	SN1->(DbSetfilter({||&cSN1Filtro},cSN1Filtro)) 
EndIf

//谀哪哪哪哪哪哪哪哪�
//砇etorna o filtros�
//滥哪哪哪哪哪哪哪哪�
If !Empty(cSN3Filtro) 
	SN3->(DbSetfilter({||&cSN3Filtro},cSN3Filtro)) 
EndIf

RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

Return lGrvAvp


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨tfRetInd 篈utor  矼auricio Pequim Jr. � Data �  11/10/11   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Retorna o Indice financeiro ou o ultimo indice disponivel  罕�
北�          � at� a data                                                 罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
//AVP
*/
Function AtfRetInd(cCodInd,dDataProc)
Local nIndice 	:= 0
Local aArea		:= GetArea()
Local cQuery	:= ""
Local dDataConv:= StoD("")
Local cTab		:= AFAVPNextAlias()

If Select(cTab) > 0
	(cTab)->(dbCloseArea())
EndIf

cQuery := " SELECT MAX(FIU_DATA) FIU_DATA FROM " + RetSQLTab("FIU")+ " WHERE "
cQuery += " FIU_CODIND = '" +cCodInd+"' AND"
cQuery += " FIU_DATA <= '" + DtoS(dDataProc) +"' AND "
cQuery += RetSQLCond("FIU")

cQuery := ChangeQuery(cQuery)

DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTab )

TCSetField(cTab, "FIU_DATA" ,"D", 8, 0 )
If (cTab)->(!EOF())
	dDataConv := (cTab)->FIU_DATA
	If FIU->(MsSeek( xFilial("FIU") + cCodInd + dToS(dDataConv)  ))
		nIndice := FIU->FIU_INDICE
	Endif
EndIf

(cTab)->(dbCloseArea())

RestArea(aArea)

Return nIndice

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯屯屯送屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯槐�
北篜rograma  矨FAVPNextAlias篈utor矼auricio Pequim Jr. � Data � 11/10/11  罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯释屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯贡�
北篋esc.     砅rote玢o para retornar o pr髕imo alias disponivel no Banco  罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
//AVP
*/
Function AFAVPNextAlias()
Local cNextAlias := ""
Local aArea := GetArea()

While .T.
	cNextAlias := GetNextAlias()
	If !TCCanOpen(cNextAlias) .And. Select(cNextAlias) == 0
		Exit
	EndIf
EndDo

RestArea(aArea)
Return cNextAlias

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯屯送屯屯脱屯屯屯屯屯屯屯屯屯屯送屯屯脱屯屯屯屯屯屯槐�
北篜rograma  矨FGetSeqAvp 篈utor 矼auricio Pequim Jr. � Data �  11/10/11  罕�
北掏屯屯屯屯拓屯屯屯屯屯屯释屯屯拖屯屯屯屯屯屯屯屯屯屯释屯屯拖屯屯屯屯屯屯贡�
北篋esc.     � Retorna o a proxima sequencia do movimento de AVP do bem   罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
//AVP
*/
Function AFGetSeqAvp()

Local cSeqAvp 	:= "0001"
Local aArea		:= GetArea()
Local cQuery	:= ""
Local cTab2		:= AFAVPNextAlias()
Local cCbase	:= FNF->FNF_CBASE
Local cItem		:= FNF->FNF_ITEM
Local cTipo		:= FNF->FNF_TIPO
Local cSeq		:= FNF->FNF_SEQ
Local cTpSaldo	:= FNF->FNF_TPSALD
Local cRevis	:= FNF->FNF_REVIS
Local cMoeda	:= FNF->FNF_MOEDA

If Select(cTab2) > 0
	(cTab2)->(dbCloseArea())
EndIf

cQuery := " SELECT MAX(FNF_SEQAVP) CSEQAVP FROM " + RetSQLTab("FNF")+ " WHERE "
cQuery += " FNF_CBASE  = '" + cCBase          +"' AND "
cQuery += " FNF_ITEM   = '" + cItem           +"' AND "
cQuery += " FNF_TIPO   = '" + cTipo           +"' AND "
cQuery += " FNF_SEQ    = '" + cSeq            +"' AND "
cQuery += " FNF_TPSALD = '" + cTpSaldo        +"' AND "
cQuery += " FNF_REVIS  = '" + cRevis          +"' AND "
cQuery += " FNF_MOEDA  = '" + cMoeda          +"' AND "
cQuery += " FNF_STATUS IN ('1','7') AND "
cQuery += RetSQLCond("FNF")

cQuery := ChangeQuery(cQuery)

DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTab2 )

If (cTab2)->(!EOF())
	cSeqAvp := Soma1( (cTab2)->CSEQAVP , Len(FNF->FNF_SEQAVP) )
EndIf

(cTab2)->(dbCloseArea())

RestArea(aArea)

Return cSeqAvp

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯屯送屯屯脱屯屯屯屯屯屯屯屯屯屯送屯屯脱屯屯屯屯屯屯槐�
北篜rograma  矨FGetRevAvp 篈utor 矼auricio Pequim Jr. � Data �  11/10/11  罕�
北掏屯屯屯屯拓屯屯屯屯屯屯释屯屯拖屯屯屯屯屯屯屯屯屯屯释屯屯拖屯屯屯屯屯屯贡�
北篋esc.     � Retorna codigo da nova revisao do AVP					  罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
//AVP
*/
Function AFGetRevAvp()

Local cRevis	:= Criavar("FNF_REVIS")
Local aArea		:= GetArea()
Local cQuery	:= ""
Local cTab3		:= AFAVPNextAlias()
Local cCbase	:= FNF->FNF_CBASE
Local cItem		:= FNF->FNF_ITEM
Local cTipo		:= FNF->FNF_TIPO
Local cSeq		:= FNF->FNF_SEQ
Local cTpSaldo	:= FNF->FNF_TPSALD
Local cMoeda	:= FNF->FNF_MOEDA

If Select(cTab3) > 0
	(cTab3)->(dbCloseArea())
EndIf

cQuery := " SELECT MAX(FNF_REVIS) CREVIS FROM " + RetSQLTab("FNF")+ " WHERE "
cQuery += " FNF_CBASE  = '" + cCBase          +"' AND "
cQuery += " FNF_ITEM   = '" + cItem           +"' AND "
cQuery += " FNF_TIPO   = '" + cTipo           +"' AND "
cQuery += " FNF_SEQ    = '" + cSeq            +"' AND "
cQuery += " FNF_TPSALD = '" + cTpSaldo        +"' AND "
cQuery += " FNF_MOEDA  = '" + cMoeda          +"' AND "								

cQuery += RetSQLCond("FNF")

cQuery := ChangeQuery(cQuery)

DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTab3 )

If (cTab3)->(!EOF())
	cRevis := Soma1( (cTab3)->CREVIS , Len(FNF->FNF_REVIS) )
EndIf

(cTab3)->(dbCloseArea())

RestArea(aArea)

Return cRevis

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪勘�
北砅rograma  矨FNoCanAvp  � Autor � Mauricio Pequim Jr    � Data �09/11/2011      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪幢�
北矰escri噭o � Verificacao da permissao de cancelamento de movimentos de AVP      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� 										                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorna   � Logico                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Processos de Cancelamento de baixa de imobilizado                  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
//AVP
/*/

Function AFNoCanAvp(cCBase,cItem,cTipo,cIdMov,dDataMov,cTpSaldo)

Local lRet 	 := .F.	
Local aArea	 := GetArea()
Local cQuery := ""
Local cTab4	 := AFAVPNextAlias()

Default cCBase		:= ''
Default cItem		:= ''
Default cTipo		:= ''
Default cIdMov		:= ''
Default dDataMov	:= CTOD("//")
Default cTpSaldo	:= ''

//Verifico se os dados possuem informacao
If Empty(cCBase) .or. Empty(cItem) .or. Empty(cTipo) .or. Empty(dDatamov) .or. Empty(cTpSaldo)
	lRet := .T.
Endif

If !lRet
	
	If Select(cTab4) > 0
		(cTab4)->(dbCloseArea())
	EndIf
	
	cQuery := " SELECT FNF_CBASE FROM " + RetSQLTab("FNF")+ " WHERE "
	cQuery += " FNF_CBASE  = '" + cCBase          +"' AND "
	cQuery += " FNF_ITEM   = '" + cItem           +"' AND "
	cQuery += " FNF_TPSALD = '" + cTpSaldo        +"' AND "
	cQuery += " FNF_STATUS = '1' AND "										
	cQuery += " FNF_DTAVP > '"  + DTOS(dDataMov)  +"' AND "										
	cQuery += RetSQLCond("FNF")
	
	cQuery := ChangeQuery(cQuery)
	
	DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTab4 )
	
	If (cTab4)->(!EOF())
		lRet := .T.
	EndIf
	
	(cTab4)->(dbCloseArea())
	
Endif
	
RestArea(aArea)

Return lRet

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪勘�
北砅rograma  矨FNoCanAvp  � Autor � Mauricio Pequim Jr    � Data �09/11/2011      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪幢�
北矰escri噭o � Verificacao da permissao de cancelamento de movimentos de AVP      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� 										                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorna   � Logico                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Processos de Cancelamento de baixa de imobilizado                  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
//AVP
/*/
Function AFCanAVP(cCBase,cItem,cTpSaldo,cIdMov,nHdlPrv,nTotal,cArquivo,cLoteAtf)

Local aArea14	:= GetArea()
Local cPadrao	:= "868"
Local cIdAvPai	:= ""
Local lPadrao  := VerPadrao(cPadrao)
Local nValBaixa := 0

Default cCBase		:= ''
Default cItem		:= ''
Default cTpSaldo	:= ''
Default cIdMov		:= ''
Default cPadrao	:= ''
Default nTotal		:= 0
Default cArquivo	:= ''
Default cLoteAtf	:= LoteCont("ATF")


dbSelectArea("FNF")
dbSetOrder(5) //FNF_FILIAL+FNF_IDMVAF+FNF_CBASE+FNF_ITEM+FNF_TPSALD+FNF_TPMOV+FNF_STATUS

If MsSeek(xFilial("FNF")+cIDMOV+cCBase+cItem+cTpSaldo)
	While !(FNF->(EOF())) .and. ;
			FNF->(FNF_FILIAL+FNF_IDMVAF+FNF_CBASE+FNF_ITEM+FNF_TPSALD) == ;
			xFilial("FNF")+cIDMOV+cCBase+cItem+cTpSaldo

		//No movimento de Baixa
		//obtenho o ID do movimento de constituicao anterior
		If FNF->FNF_TPMOV == '4'
			cIdAvPai := FNF->FNF_IDPRCP
		Endif

		//Se for um movimento de realizacao por baixa
		//obtenho o valor para retornar ao acumulado da constituicao anterior
		If FNF->FNF_TPMOV $ '3/4'
			nValBaixa += FNF->FNF_VALOR
		Endif

		//Contabilizo a exclusao do registro
		If lPadrao
			If nHdlPrv == 0
				nHdlPrv := HeadProva(cLoteAtf,"ATFA030",Substr(cUsername,1,6),@cArquivo)
			Endif
			nTotal += DetProva(nHdlPrv,cPadrao,"ATFA030",cLoteAtf)					
		Endif

		//Exclui o registro do FNF
		RecLock("FNF",.F.,.T.)
		FNF->(dbDelete())		
		msUnlock()
		FKCOMMIT()
	
		FNF->(dbSkip())
	
	Enddo	

	//Reativa a constituicao anterior
	If !Empty(cIdAvPai)
		FNF->(dbSetOrder(3)) //FNF_FILIAL+FNF_IDPROC+FNF_TPMOV+FNF_STATUS
		If MsSeek(xFilial("FNF")+cIdAvPai+"1")
			RecLock("FNF",.F.,.T.)			
			FNF->FNF_STATUS := '1'
			FNF->FNF_ACMAVP -= nValBaixa
			FNF->FNF_IDMVAF := ''
			Msunlock()
		Endif
	Endif
Endif	
		
RestArea(aArea14)

Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨FGrvPrjAvp篈utor  矨lvaro Camillo Neto� Data �  17/11/11   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Realiza a atualiza玢o do valor de AVP do Ativo Imobilizado罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function AFGrvPrjAvp(cBase,cItem,cTipo,cTipoSld)
Local aArea 	 := GetArea()
Local aAreaSN1 := SN1->(GetArea())
Local nVlrRlz  := 0
Local nVlrPlan := 0 
 
If __lStruPrj == Nil
	__lStruPrj := .T.
EndIf

If __lStruPrj
	SN1->(DBSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM
	FNE->(DBSetOrder(2)) //FNE_FILIAL+FNE_CODPRJ+FNE_REVIS+FNE_ETAPA+FNE_ITEM+FNE_TPATF+FNE_TPSALD

	If SN1->(MsSeek( xFilial("SN1") + cBase + cItem))
		If FNE->(MsSeek( xFilial("FNE") + SN1->(N1_PROJETO + N1_PROJREV + N1_PROJETP + N1_PROJITE) + cTipo + cTipoSld ))
			
			nVlrPlan := AFRetVlAVP(SN1->N1_PROJETO , SN1->N1_PROJREV , SN1->N1_PROJETP , SN1->N1_PROJITE, '1'     , cTipoSld, SN1->N1_CBASE)
			nVlrRlz  := AFRetVlAVP(SN1->N1_PROJETO , SN1->N1_PROJREV , SN1->N1_PROJETP , SN1->N1_PROJITE, '2'     , cTipoSld, SN1->N1_CBASE)
			           
			RecLock("FNE",.F.)
				FNE->FNE_AVPPLN := nVlrPlan
				FNE->FNE_AVPRLZ := nVlrRlz
			MsUnLock() 
		EndIf	
	EndIf
EndIf

RestArea(aAreaSN1)
RestArea(aArea)

Return  


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨FXPadAVP 篈utor  矼icrosiga           � Data �  05/24/12   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     �                                                            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function AFXPadAVP(cProcesso)
Local cPadrao := ""

Do Case
	Case cProcesso $ "1|8"
		cPadrao := "860"		//"Ativo Fixo - Ajuste a Valor Presente - Constitui玢o"
	Case cProcesso == "2"
		cPadrao := "861"		//"Ativo Fixo - Ajuste a Valor Presente - Apropria玢o"
	Case cProcesso == "3"
		cPadrao := "862"		//"Ativo Fixo - Ajuste a Valor Presente - Baixa de apropria玢o"
	Case cProcesso == "4"
		cPadrao := "863"		//"Ativo Fixo - Ajuste a Valor Presente - Baixa"
	Case cProcesso == "5"
		cPadrao := "864"		//"Ativo Fixo - Ajuste a Valor Presente - Realiza玢o"
	Case cProcesso == "6"
		cPadrao := "865"		//"Ativo Fixo - Ajuste a Valor Presente - Baixa de realiza玢o"
	Case cProcesso $ "A"
		cPadrao := "866"		//"Ativo Fixo - Ajuste a Valor Presente - Diferenca por revisao"
	Case cProcesso == "0"
		cPadrao := "868"		//Cancelamento de processo de AVP
EndCase		


Return cPadrao

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨FRetVlAVP 篈utor  矼icrosiga           � Data �  05/24/12   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Funcao que retorna o valor de AVP Planejado e Realizado    罕�
北�          � de uma Etapa.                                              罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function AFRetVlAVP(cProj , cRev , cEtapa , cItem , cTipoMov , cTipoSld ,cBase )
Local aArea     := GetArea()
Local cQuery    := ""
Local cTab      := GetNextAlias()
Local cAuxQuery := ""
Local nRet      := 0

If Select(cTab) > 0
	(cTab)->(dbCloseArea())
EndIf

cQuery    += " SELECT N1_ITEM FROM " + RetSQLName("SN1") + " SN1 "
cQuery    += " WHERE "
cQuery    += "     N1_FILIAL  = '"+xFilial("SN1")+"' "
cQuery    += " AND N1_PROJETO = '"+cProj+"' "
cQuery    += " AND N1_PROJREV = '"+cRev+"' "
cQuery    += " AND N1_PROJETP = '"+cEtapa+"' "
cQuery    += " AND N1_PROJITE = '"+cItem+"' "
cQuery    += " AND SN1.D_E_L_E_T_ = '' "
cQuery := ChangeQuery(cQuery)

DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTab )

If (cTab)->(!EOF())
	While (cTab)->(!EOF())
		cAuxQuery += (cTab)->N1_ITEM + "\"
		(cTab)->(dbSkip())
	EndDo

	(cTab)->(dbCloseArea())
	cQuery    := " "

	cAuxQuery := Left(cAuxQuery, Len(cAuxQuery) - 1 )
	cExpIn := FormatIn(cAuxQuery,"\")

	cQuery    += " SELECT "
	cQuery    += "     SUM(FNF_VALOR) FNF_VALOR "
	cQuery    += " FROM " + RetSQLName("FNF") + " FNF "
	cQuery    += " WHERE"
	cQuery    += "     FNF_FILIAL = '"+xFilial("FNF")+"' "
	cQuery    += " AND FNF_CBASE  = '" +cBase+ "' "
	cQuery    += " AND FNF_ITEM IN " +cExpIn+"  "
	cQuery    += " AND FNF_TPSALD = '"+cTipoSld+"' "

	If cTipoMov == '1'   //Constituicao
		cQuery    += " AND FNF_TPMOV = '" +cTipoMov + "' " 
		cquery 	  += " AND FNF_REVIS = ( SELECT MAX(FNF_REVIS)  
		cQuery    +=                   " FROM " + RetSQLName("FNF") + " FNF "
		cQuery    +=                   " WHERE"
		cQuery    +=                   " FNF_FILIAL = '"+xFilial("FNF")+"' "
		cQuery    +=                   " AND FNF_CBASE  = '" +cBase+ "' "
		cQuery    +=                   " AND FNF_ITEM IN " +cExpIn+"  "
	    cQuery    +=                   " AND FNF_TPSALD = '"+cTipoSld+"' "
		cQuery    +=                   " AND FNF_STATUS IN ( '1','2') "
		cQuery    +=                   " AND FNF.D_E_L_E_T_  = '' )"
	ElseIf cTipoMov == '2'	//Realizacao por calculo ou por baixa
		cQuery    += " AND FNF_TPMOV IN ('2','3') "
	Endif

	cQuery    += " AND FNF_STATUS IN ( '1','2') "
	cQuery    += " AND FNF.D_E_L_E_T_  = '' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTab )
	
	
	If (cTab)->(!EOF())
		nRet := (cTab)->FNF_VALOR
	EndIf
	
EndIf
(cTab)->(dbCloseArea())

RestArea(aArea)


Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ATFXAJLA
Fun玢o para ajuste de movimentos de ativo antes da utiliza玢o da nova
rotina de contabiliza玢o Off-Line do Ambiente Ativo Fixo CTBAATF.

@author marylly.araujo
@since 25/02/2014
@version MP12
/*/
//-------------------------------------------------------------------
Function ATFXAJLA
Local lRet			:= .T.
Local cAlsSN4		:= GetNextAlias()
Local cQrySN4		:= ''
Local aArea		:= GetArea()
Local aSN4Area	:= {}
Local cAlsSNX		:= GetNextAlias()
Local cQrySNX		:= ''

/*
 * Ajuste das Flags de Contabiliza玢o da tabela de Movimentos do Ativo
 */
DbSelectArea('SN4')
aSN4Area := SN4->(GetArea())

cQrySN4 := 'SELECT ' + CRLF
cQrySNX += 'SN4.R_E_C_N_O_  SN4RECNO ' + CRLF
cQrySN4 += ' FROM ' + RetSqlName('SN4') + ' SN4 ' + CRLF
cQrySN4 += ' WHERE ' + CRLF
cQrySN4 += " SN4.D_E_L_E_T_ = ' ' "
cQrySN4 += " AND SN4.N4_LA <> 'S' "
cQrySN4 += " AND SN4.N4_OCORR NOT IN ('06','07','08','10','11','12','20') "
cQrySN4 += " AND SN4.N4_TIPOCNT NOT IN ('2','3','5') "
cQrySN4 += " AND SN4.N4_DCONTAB <> ' ' "
cQrySN4 := ChangeQuery(cQrySN4)

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQrySN4), cAlsSN4 , .F., .T.)

While !(cAlsSN4)->(Eof())
	SN4->(DbGoTo((cAlsSN4)->SN4_RECNO))
	SN4->(RecLock("SN4",.F.))
	SN4->N4_LA := 'S'
	SN4->(MsUnLock())
	(cAlsSN4)->(DbSkip())
EndDo

(cAlsSN4)->(DbCloseArea())

RestArea(aSN4Area)

/*
 * Ajuste das Flags de Contabiliza玢o da tabela de Movimentos de Rateio de Despesa de Deprecia玢o
 */
DbSelectArea('SNX')
aSNXArea := SNX->(GetArea())

cQrySNX := 'SELECT ' + CRLF
cQrySNX += 'SNX.R_E_C_N_O_  SNXRECNO ' + CRLF
cQrySNX += ' FROM ' + RetSqlName('SNX') + ' SNX ' + CRLF
cQrySNX += ' WHERE ' + CRLF
cQrySNX += " SNX.D_E_L_E_T_ = ' ' "
cQrySNX += " AND SNX.NX_LA <> 'S' "
cQrySNX += " AND SNX.NX_DCONTAB <> ' ' "

cQrySNX := ChangeQuery(cQrySNX)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQrySNX), cAlsSNX , .F., .T.)

While !(cAlsSNX)->(Eof())
	SNX->(DbGoTo((cAlsSNX)->SNX_RECNO))
	SNX->(RecLock("SNX",.F.))
	SNX->NX_LA := 'S'
	SNX->(MsUnLock())	
	(cAlsSNX)->(DbSkip())
EndDo

(cAlsSNX)->(DbCloseArea())

RestArea(aSNXArea)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ATFAtuCiap
Fun玢o para atualiza�?o C骴igo da baixa para Bem principal e Bens
componentes.

@author Alessandro Santos
@since 08/10/2019
@version MP12
/*/
//-------------------------------------------------------------------

Function ATFAtuCiap(aPrinCiap, aCompCiap)

Local cCodBaixa	:= ""
Local nI 		:= 0

SF9->(dbSetOrder(1)) //F9_FILIAL+F9_CODIGO

//Atualiza F9_CODBAIX do bem principal
If SF9->(dbSeek(xFilial("SF9") + aPrinCiap[1]))
	SF9->(RecLock("SF9", .F.))
	SF9->F9_CODBAIX := "BFINAL"	
	SF9->(MsUnLock())

	cCodBaixa := SF9->F9_CODIGO //Salva c骴igo do bem principal
EndIf

//Atualiza F9_CODBAIX dos bens componentes
For nI := 1 To Len(aCompCiap)
	If SF9->(dbSeek(xFilial("SF9") + aCompCiap[nI][1]))
		SF9->(RecLock("SF9", .F.))
		SF9->F9_CODBAIX := cCodBaixa
		SF9->(MsUnLock())
	EndIf
Next nI

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ATDelRat
Fun玢o para excluir movimento de rateio SNX. 

@param cListExc - lista de recnos para ser excluido 
@author TOTVS
@since 27/04/2020
@version MP12
/*/
//-------------------------------------------------------------------
Static Function ATDelRat(cListExc)
Local cSQLExec := ""

DEFAULT cListExc := ""

cSQLExec := " UPDATE "+RetSQLName("SNX")
cSQLExec += " SET D_E_L_E_T_ = '*', "
cSQLExec += " R_E_C_D_E_L_ = R_E_C_N_O_ "
cSQLExec += " WHERE R_E_C_N_O_ IN("
cSQLExec += Left(cListExc,Len(cListExc)-1)
cSQLExec += " ) "

If TcSqlExec(cSQLExec) <> 0
	UserException(STR0001 + CRLF + TCSqlError() )
EndIf

Return


/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    矯IAPBMCONT � Autor � TOTVS SA             � Data � 20.10.20 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Funcao que realiza a inclusao de um registro de CIAP       潮�
北�          砤o gravar um Bem em constru玢o                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矯IAPBMCONT(cCODCIAP, cF9Desc)	                        	  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � ATFA012                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function CIAPBMCONT(aBmContr)

Local aArea := GetArea()
Local lRet	:= .T.

Begin Transaction

	DbSelectArea('SF9')
	DbSetOrder(1)

	RecLock("SF9", !SF9->(DbSeek(xFilial('SF9')+aBmContr[1])))
		SF9->F9_FILIAL := xFilial("SF9")
		SF9->F9_CODIGO := aBmContr[1]
		SF9->F9_DESCRI := aBmContr[2]
		SF9->F9_FORNECE:= aBmContr[3]
		SF9->F9_LOJAFOR:= aBmContr[4]
		SF9->F9_DOCNFE := aBmContr[5]
		SF9->F9_SERNFE := aBmContr[6]
		SF9->F9_ROTINA := aBmContr[7]
		SF9->F9_FUNCIT := aBmContr[8]
		SF9->F9_TIPO   := "02" //Bem em constru玢o
	SF9->(MsUnLock())

	If __lSX8
		ConfirmSX8()
	Else
		RollBackSX8()
	EndIf

	SF9->(DbCloseArea())

End Transaction

RestArea(aArea)

Return (lRet)


/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    BMCDELCIAP � Autor � TOTVS SA             � Data � 21.10.20  潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Funcao que realiza a remocao de um registro de CIAP quando 潮�
北�          � da exclusao de um bem em constru玢o  vinculada a ele.      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � BMCDELCIAP(cCODCIAP)                                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � ATFA012                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function BmcDelCiap(cBemCiap)
LOCAL aArea		:= GetArea()
LOCAL lRet 		:= .F.

dbSelectArea("SF9")
dbSetOrder(1)

If ( MsSeek(xFilial("SF9")+cBemCiap) )
	While ( !Eof() .And. xFilial("SF9")==SF9->F9_FILIAL .And. SF9->F9_CODIGO==cBemCiap)
		RecLock("SF9")
		dbdelete()
		MsUnLock()
		dbSkip()
	EndDo
	lRet := .T.
EndIf

RestArea(aArea)
RETURN(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc}CompCTE
	Autor: gustavo.campos / 23/08/2022
	Funcao para compor/estornar o valor de um Imposto de CTE no valor do BEM N3_VORIG1
	Se o mesmo nao foi classificado.
	
	ArrayCTE(Obrigatorio)
	Contextualizacao das posi�?es
	[1] = Base do documento de origem (D1_CBASEAF) -> C骴igo geral do bem N1_CBASE no ativo;
    [2] = Ultimo(N1_ITEM) recebido do mesmo D1_CBASEAF, no ativo N1_CBASE;
    [3] = Array com os valores por desmembramento da NF (Caso nao houver, sera apenas 1 posicao com o valor inteiro)
    [4] = Array com os valores por desmembramento da NF para apropria玢o do ICMS (D1_VALICM/N1_ICMSAPR) (Caso nao houver vem como 0, sera apenas 1 posicao com o valor inteiro)
		a terceira posicao pode ter varias posicoes que significam que o valor do Imposto de Frete - CTE sera composta em
		varios itens(N1_ITEM) com base do N1_CBASE.
		Exemplo -> 	 arrayCTE[3][1] = 10 , esse valor sera somado no campo N3_VORIG1 do item 0001(N1_ITEM)
		Exemplo 2 -> arrayCTE[3][1] = 10 , esse valor sera somado no campo N3_VORIG1 do item 0001(N1_ITEM)
					 arrayCTE[3][2] = 10 , E tamb閙 sera somado no campo N3_VORIG1 do item 0002(N1_ITEM)
					 .
					 .
					 .arrayCTE[3][n] = Xxx - esse valor ser� somado no N3_VORIG1 do item NNNN do N1_CBASE = xxxxxXXX
	cOperacao(Obrigatorio) ->	1 - Define que a operacao sera uma incorpora�?o do valor ao campo N3_VORIG1(Soma)
				 				2 - Define que a operacao sera um estorno do valor ao campo N3_VORIG1(Subtrai)
	/*/
//-------------------------------------------------------------------

Function CompCTE(arrayCTE,cOperacao)

	Local cBaseCTE	:=	""
	Local cItemCTE	:=	""
	Local cStart	:= "0001"
	Local aArea    	:= GetArea()
	Local aAreaSN1 	:= SN1->(GetArea())
	Local aAreaSN3 	:= SN3->(GetArea())
	Local ny		:=	0
	Local nx		:=	0
	Local aRet		:= { .F. , "" } // 1 -Retorno logico se deu certo / 2 - string com detalhe do por que falhou
	Local lContinua	:= .T.

	cBaseCTE	:= arrayCTE[1]
	cItemCTE	:= arrayCTE[2]

	SN1->(DbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM
	//Validacao para verificar se nenhum Bem foi classificado, se foi nao incrementA nenhum.
	
	For ny := 1 to len(arrayCTE[3])  //ITERANDO BENS COM CTE PASSADOS PELO TIME DE SUPRIMENTOS

		if cStart <= cItemCTE

			If SN1->( DbSeek(xFilial("SN1") + cBaseCTE + cStart ) ) //INDICE 1 - Verifica se est� a classificar.

				If SN1->N1_STATUS == "0" // N1_STATUS = 0 A CLASSIFICAR
					aRet[1]		:=	.T.
				Else
					aRet[1]		:=	.F.
					aRet[2]		:=	STR0002//"Um dos Bens da Nota Fiscal foi Classificado, nao e possivel aglutinar/Estornar os valores de Imposto de Frete(CTE) para bens classificados"
					lContinua	:=	.F.
					Exit
				EndIf
			Else
				aRet[1]			:=	.F.
				aRet[2]			:=	STR0003 //"Bem nao encontrado, Verifique se houve delecao incorreta"
				lContinua		:=	.F.	
				Exit
			EndIf
			
			cStart := soma1(cStart)

		EndIf

	Next

	If lContinua

		//zera para iniciar da primeira posicao
		cStart := "0001"
		SN3->(DbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
		SN1->(DbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM

		For nx := 1 to len(arrayCTE[3])  //ITERANDO BENS COM CTE PASSADOS PELO TIME DE SUPRIMENTOS

			if cStart <= cItemCTE

				If SN3->( DbSeek(xFilial("SN3") + cBaseCTE + cStart + "01" + "0" + "001" ) ) //Posicionando na SN3 para busca e incorporacao do CTE

					SN3->(RecLock("SN3",.F.))

						If cOperacao == "1" //Incorporar CTE do valor do bem
							SN3->N3_VORIG1	+=	arrayCTE[3][nx]
							aRet[1]			:=	.T.
						Else				//Estornar CTE do valor do bem
							SN3->N3_VORIG1	-=	arrayCTE[3][nx]
							aRet[1]			:=	.T.
						Endif
					SN3->(MsUnlock())

				EndIf

				If SN1->( DbSeek(xFilial("SN1") + cBaseCTE + cStart ) )

						SN1->(RecLock("SN1",.F.))

							If cOperacao == "1" //Incorporar CTE do valor do bem
								SN1->N1_VLAQUIS += arrayCTE[3][nx]
								aRet[1]			:=	.T.
							Else 				//Estornar CTE do valor do bem
								SN1->N1_VLAQUIS -= arrayCTE[3][nx]
								aRet[1]			:=	.T.
							Endif
						SN1->(MsUnlock())
				EndIf

				If arrayCTE[4][nx] > 0 //Composicao do valor de ICMS a apropriar.
					If SN1->( DbSeek(xFilial("SN1") + cBaseCTE + cStart ) )

						SN1->(RecLock("SN1",.F.))

							If cOperacao == "1" //Incorporar CTE ICMS A APROPRIAR
								SN1->N1_ICMSAPR	+=	arrayCTE[4][nx]
								aRet[1]			:=	.T.
							Else				//Estornar CTE ICMS A APROPRIAR
								SN1->N1_ICMSAPR	-=	arrayCTE[4][nx]
								aRet[1]			:=	.T.
							Endif
						SN1->(MsUnlock())

					EndIf
				EndIf

				cStart := soma1(cStart)

			EndIf

		Next

	Endif
	

	RestArea(aAreaSN3)
	RestArea(aAreaSN1)
	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc}VldBemCTE
	Autor: gustavo.campos / 23/08/2022
	Funcao criada por solicita�?o de regra do time de suprimentos
	para regra do imposto de frete - CTE para incorporar no bem.
	cBaseVld(Obrigatorio) -> Bem desejado para pesquisa se existe e se est� a classificar
	cItemVld(Opcional) ->	Item relacionado do cBase
		Se nAo for passado ele ira considerar na query todos os N1_ITEM do N1_CBASE
/*/
//-------------------------------------------------------------------
Function VldBemCTE(cBaseVld,cItemVld)

	Local aArea    	:= GetArea()
	Local aAreaSN1 	:= SN1->(GetArea())
	Local cQuery	:= ""
	Local lRet		:= .T.
	Local aBindSN1
	
	Default cItemVld:=	""
	SN1->(DbSetorder(1))
	If SN1->( DbSeek(xFilial("SN1") + cBaseVld + alltrim(cItemVld) ) )
		
		cQuery		:=	"SELECT COUNT(R_E_C_N_O_) TOTREC "
		cQuery		+=	"FROM " + RetSqlName("SN1") + " SN1 "
		cQuery		+=	"WHERE N1_FILIAL	= ? " 
		cQuery		+=	"AND N1_CBASE		= ? " 
		If !Empty(cItemVld)
			cQuery	+=	"AND N1_ITEM		= ? "
		EndIf
		cQuery		+=	"AND N1_STATUS 	   != ? "
		cQuery	+=	"AND SN1.D_E_L_E_T_ 	= ? "

		aBindSN1 :={}
		aADD(aBindSN1, xFilial('SN1'))
		aADD(aBindSN1, cBaseVld)
		If !Empty(cItemVld)
			aADD(aBindSN1, cItemVld)
		EndIf
		aADD(aBindSN1, '0')
		aAdd(aBindSN1, Space(1))

		dbUseArea(.T.,"TOPCONN",TcGenQry2(,,cQuery,aBindSN1),'cQryTrab')

		If cQryTrab->TOTREC > 0
			lRet	:=	.F.	//Bem j� foi classificado
		EndIF

		cQryTrab->(DbCloseArea())
		aSize(aBindSN1,0)
	Else
		lRet	:= .F. //Bem n?o existe
	EndIF
	RestArea(aAreaSN1)
	RestArea(aArea)

Return lRet
