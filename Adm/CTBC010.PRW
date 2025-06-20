#INCLUDE "CTBC010.CH"
#INCLUDE "PROTHEUS.CH"

STATIC lCTxTABORI
STATIC lCTxRECORI
STATIC lCTxRECDES


// 17/08/2009 -- Filial com mais de 2 caracteres

// TRADUCAO DE CH'S PARA PORTUGAL
// TRADU��O RELEASE P10 1.2 - 21/07/08

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   � CTBC010  � Autor � Pilar S. Albaladejo   � Data � 17.05.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Rastreamento de Lancamento Contabil            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBC010()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION CtbC010()

PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0004) //"Rastrear Lan�amentos Contabeis"
Private cFunName := "CTBC010" //Declarada para n�o dar erro na fun��o LocxDlgNF (LOCXNF), ao rastrear documentos de entrada

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

mBrowse( 6, 1,22,75,"CT2",,,,,, { 	{ "Deleted()", "BR_VERMELHO" },{"Substr(CT2_ORIGEM,1,9)=='__CTBLC__'","BR_MARROM"},;
									{ ".T.", "BR_VERDE" } })

Set(_SET_DELETED, .T.)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �CTBC010Rot� Autor � Pilar S. Albaladejo   � Data � 17.05.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina utilizada para Rastrear Lancamento Contabil         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CtbC010Rot(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBC010                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1  : Alias do arquivo                                  ���
���          � ExpN1  : Numero do Registro                                ���
���          � ExpN2  : Numero da opcao selecionada                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBC010ROT( cAlias, nReg, nOpc, nRecDes)
Local lRet		:= .T.
Local cSequenc	:= CT2->CT2_SEQUEN
Local dDtCV3	:= CT2->CT2_DTCV3
Local lDel		:= Set(_SET_DELETED)
Local nRecno  := 0
Local aArea   := GetArea()
Local aAreaCT2:= {}
Local cTabOri := cAlias
Local nRecOri := nReg
Local dDatCT2 := CT2->CT2_DATA
Local cLote   := CT2->CT2_LOTE
Local cSbLote := CT2->CT2_SBLOTE
Local cDocto  := CT2->CT2_DOC

DEFAULT nRecDes := 0

If FunName()== "CTBC020"
	PRIVATE cCadastro := OemToAnsi(STR0004) //"Rastrear Lan�amentos Contabeis"
	DbSelectArea("CT2")
	If Val(nRecDes) > 0   //protecao para quando vier em branco nao carregar as variaveis novamente
		DbGoto(Val(nRecDes))
		cSequenc:= CT2->CT2_SEQUEN
		dDtCV3	:= CT2->CT2_DTCV3
		dDatCT2 := CT2->CT2_DATA
		cLote   := CT2->CT2_LOTE
		cSbLote := CT2->CT2_SBLOTE
		cDocto  := CT2->CT2_DOC
	EndIf
	lDel	:= Set(_SET_DELETED)
	SaveInter()
EndIf

If FwIsInCallStack("CTBA102") .And.  cAlias == "CT2"
	aArea   := CT2->(GetArea())
EndIf 

//Rastreio pela CTBA102 � realizado apenas pela CT2
If FWIsInCallStack("CTBA102") .And.  cAlias == "CTC"
	lRet := .F.

	If !IsBlind()
		Help(" ",1,"NORASCTC",, STR0020 + CRLF + CRLF + STR0021 ,1,0) //"N�o � poss�vel realizar o rastreio pela tabela CTC." // "Selecione a op��o 'Rastrear' na tela de visualiza��o ou altere o par�metro 'Modo de exibi��o' da rotina para 'Detalhe Lan�amento Cont�bil'."
	EndIf

Else
	
	lRet := Ctc010Val( cSequenc, dDtCV3, dDatCT2, cLote, cSbLote, cDocto )
	RestArea(aArea)

EndIf

If lRet

	// Se for um lan�amento aglutinado, exibe todos os lan�amentos aglutinados para que o
	// usu�rio escolha qual quer rastrear.
	If Ct2->CT2_AGLUT == "1"
		CtbAglut(cSequenc,dDtCV3,cTabOri,nRecOri)
	ElseIf CT2->CT2_AGLUT == "2"				// Lancamento nao Aglutinado
			If FunName() == "CTBC020"
				aAreaCT2:= GetArea()
				DbSelectArea("CV3")
				CV3->(DbSetOrder(2))
  				If DbSeek(xFilial("CV3")+nRecDes,.F.)
		  			nRecno:= CV3->(RECNO())
	  				CtbRastrear(nRecno)
		  		EndIf
		  		RestArea(aAreaCT2)
		  	Else
				CtbRastrear()
			Endif
	ElseIf CT2->CT2_AGLUT == "3"				// Lancamento importado
		Help(" ",1,"CTB010IMP")
	EndIf

EndIf
RestArea(aArea)
Set(_SET_DELETED, lDel)
RestInter()
Return nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �CTC010VAL � Autor � Pilar S. Albaladejo   � Data � 17.05.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida se o lancamento contabil podera ser rastreado        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CTC010Val(cSequenc,cPadrao)                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T./.F.                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBC010                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1  : Sequencia                                         ���
���          � ExpC2  : Codigo do lancamento padrao                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Ctc010Val(cSequenc,dDtCV3,dDatCT2,cLote,cSbLote,cDocto)

Local aSaveArea:= GetArea()
Local lRet		:= .T.
Local aBindCT2 
Static _oQryCT2LP

Default cSequenc := CT2->CT2_SEQUEN
Default dDtCV3	 := CT2->CT2_DTCV3
Default dDatCT2  := CT2->CT2_DATA
Default cLote    := CT2->CT2_LOTE
Default cSbLote  := CT2->CT2_SBLOTE
Default cDocto   := CT2->CT2_DOC

If _oQryCT2LP == NIL
	_oQryCT2LP := "SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_SEQUEN, CT2_DTCV3, CT2_ROTINA, CT2_LP FROM "
	_oQryCT2LP += RetSqlName("CT2")
	_oQryCT2LP += " WHERE CT2_FILIAL = ? "
	_oQryCT2LP += " AND CT2_DATA     = ? "
	_oQryCT2LP += " AND CT2_LOTE     = ? "
	_oQryCT2LP += " AND CT2_SBLOTE   = ? "
	_oQryCT2LP += " AND CT2_DOC      = ? "
	_oQryCT2LP += " AND CT2_SEQUEN   = ? "
	_oQryCT2LP += " AND CT2_DTCV3    = ? "
	_oQryCT2LP += " AND D_E_L_E_T_   = ? "
	_oQryCT2LP += " AND ( CT2_ROTINA IN ('WFNFIN','WFNCASH','WFNLEAS','CTBA101','CTBA102','CTBA500') OR CT2_SEQUEN = ' ' OR CT2_LP = ' ' )"
	_oQryCT2LP += " GROUP BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_SEQUEN, CT2_DTCV3, CT2_ROTINA, CT2_LP"
	_oQryCT2LP += " ORDER BY CT2_SEQUEN, CT2_LP, CT2_ROTINA "
	_oQryCT2LP := ChangeQuery(_oQryCT2LP) 
EndIf 
aBindCT2 := {}
AADD(aBindCT2, xFilial("CT2") )
AADD(aBindCT2, DTOS(dDatCT2) )
AADD(aBindCT2, cLote )
AADD(aBindCT2, cSbLote )
AADD(aBindCT2, cDocto )
AADD(aBindCT2, cSequenc )
AADD(aBindCT2, DTOS(dDtCV3) )
AADD(aBindCT2, Space(1) )
dbUseArea(.T.,"TOPCONN",TcGenQry2(,,_oQryCT2LP,aBindCT2),'QCT2RAST')
aSize(aBindCT2,0)
aBindCT2 := nil 
If QCT2RAST->(!Eof())

	If ALLTRIM(QCT2RAST->CT2_ROTINA) $ "WFNFIN/WFNCASH/WFNLEAS"
		Help(" ",1,"GESPLAN",,STR0022,1,0) //"Lan�amento gerado por Integra��o Gesplan"
		lRet := .F.
	ElseIf ALLTRIM(QCT2RAST->CT2_ROTINA) $ "CTBA101/CTBA102"
		Help(" ",1,"LancMan")
		lRet := .F.
	ElseIf ALLTRIM(QCT2RAST->CT2_ROTINA) == "CTBA500"
		Help(" ",1,"CONTABTXT",,STR0019,1,0)  //"Gerado por Contabilizacao TXT"
		lRet := .F.
	ElseIf Empty(QCT2RAST->CT2_SEQUEN) .Or. Empty(QCT2RAST->CT2_LP)
		Help(" ",1,"NODRILL")
		lRet := .F.
	EndIf

EndIf
QCT2RAST->( dbCloseArea() )	

RestArea(aSaveArea)

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �CTBAglut  � Autor � Pilar S. Albaladejo   � Data � 17.05.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica os lanc. a serem rasterados,caso sejam aglutinados.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CtbAglut(cSequenc,cPadrao)                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBC010                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1  : Sequencia                                         ���
���          � ExpC2  : Codigo do Lancamento Padrao                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

STATIC FUNCTION CtbAglut(cSequenc,dDtCV3,cTabOri, nRecOri)

Local cFilCV3	:= ""
Local aSize		:= MsAdvSize(,.F.,430)
Local nRecno    := 0
Local aAreaCT2  := GetArea()

PRIVATE aRotina := {	{OemToAnsi(STR0001)	,"AxPesqui"  	, 0, 1},;	// "Pesquisar"
							{OemToAnsi(STR0003)	,"CtbRastrear"	, 0, 2},;	// "Rastrear"
							{OemToAnsi(STR0018)	,"FiltraCV3"	, 0, 3}}		// "Filtro"

lCTxTABORI := Iif( lCTxTABORI == NIL, .T. , lCTxTABORI )
lCTxRECORI := Iif( lCTxRECORI == NIL, .T., lCTxRECORI )
lCTxRECDES := Iif( lCTxRECDES == NIL, .T.,  lCTxRECDES )

If !Empty(CT2->CT2_KEY) .or. (lCTxTABORI .and. lCTxRECORI .and. lCTxRECDES )	/// SE TIVER RASTREAMENTO OU RASTREAMENTO SEM CONFIGURA��O ESTIVER HABILITADO
	dbSelectArea("CV3")
	DbSetOrder(1)
	cFilCV3 := xFilial("CV3")
  	Set Filter to CV3->CV3_FILIAL == cFilCV3 .AND. CV3->CV3_DTSEQ == dDtCV3 .AND. CV3->CV3_SEQUEN == cSequenc
  	// Quando for chamada pela Consulta CTBC020 n�o aparecer esta tela.
    If FunName() != "CTBC020"
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],OemToAnsi(STR0004),"CV3",,aRotina,,;	//"Rastrear Lan�amentos Contabeis"
   	         "'"+cFilCV3+DTOS(dDtCV3)+cSequenc+"'",;
      	      "'"+cFilCV3+DTOS(dDtCV3)+cSequenc+"'",.F.,,,,xFilial('CV3')+DTOS(CV3_DTSEQ)+CV3_SEQUEN,,,.F.,.F.)
  	Else
		aAreaCT2:= GetArea()
		DbSelectArea("CV3")
		CV3->(DbSetOrder(3))
		If DbSeek(xFilial("CV3")+cTabOri+nRecOri,.F.)
  			nRecno:= CV3->(RECNO())
			CtbRastrear(nRecno)
  		EndIf
    EndIf
	dbSelectArea("CV3")
	Set Filter to
	RestArea(aAreaCT2)
Else
	ApMsgAlert(STR0006) //"Verifique as chaves de relacionamento"
EndIf

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FiltraCV3 �Autor  �Eduardo Nunes       � Data �  30/06/06   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina para Filtrar (atraves do botao Filtro) Lancamentos  ���
���          � Rastreados                                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FiltraCV3{)                                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBC010                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FiltraCV3()
Local cFilCV3 := ""

Set Filter to
cFilCV3 := BuildExpr("CV3")	//	Exibe a tela do filtro e retorna o filtro informado pelo usuario
Set Filter to &cFilCV3

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �CtbRastrea� Autor � Pilar S. Albaladejo   � Data � 17.05.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina utilizada para Rastrear Lancamento Contabil         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CtbRastrear()                                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBC010                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

FUNCTION CtbRastrear(nRecno)
Local cArq		:= ""
Local cChave	:= ""
Local nOrdem	:= 1
Local cSequenc	:= CT2->CT2_SEQUEN
Local cPadrao  	:= CT2->CT2_LP
Local dDtCV3	:= CT2->CT2_DTCV3
Local cCad		:= cCadastro
Local cFilOrig
Local cFilTab	:= cFilAnt
Local lCTL		:= .F.			/// indica se efetua rastreamento pelo CTL.
Local lAchou 	:= .T.
Local cRecCT2	:= ""
Local cRotina	:= ""
Local aAreaOri  := GetArea()
Local aPosCT2	:= CT2->(GetArea())
Local cChaveCT2 := ""
Local aAcho	:= {}
Local nCv3		:= TamSX3("CV3_FILIAL")[1] 



If FunName() == "CTBC020"

	DbSelectArea("CV3")
	DbGoto(nRecno)
EndIf


lCTxTABORI := Iif( lCTxTABORI == NIL, .T., lCTxTABORI )
lCTxRECORI := Iif( lCTxRECORI == NIL, .T. , lCTxRECORI )
lCTxRECDES := Iif( lCTxRECDES == NIL, .T. , lCTxRECDES )

If (lCTxTABORI .and. lCTxRECORI .and. lCTxRECDES )	/// SE RASTREAMENTO SEM CONFIGURA��O ESTIVER HABILITADO

	If CT2->CT2_MOEDLC <> "01"		/// SE FOR LAN�AMENTO EM OUTRA MOEDA POSICIONA NO REGISTRO DA MOEDA 01
		cChaveCT2 := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+"01")
		dbSelectArea("CT2")
		dbSetOrder(1)
		If !dbSeek(cChaveCT2,.F.)		/// SE N�O ENCONTROU REG. DA MOEDA 01
			RestArea(aPosCT2)			/// RESTAURA POSICIONAMENTO NO CT2
			lAchou := .F. 				/// INDICA QUE N�O ACHOU PARA TENTAR RASTREAMENTO PELO CTL
		EndIf
	EndIf

	If lAchou			/// INDICA QUE ACHO REGISTRO DA MOEDA 01 NO CT2 (POR ENQUANTO).
		cRecCT2 := ALLTRIM(STR(INT(CT2->(Recno()))))
		If CT2->CT2_AGLUT <> "1"    /// SE N�O ESTIVER AGLUTINADO J� ESTA POSICIONADO NO CV3 (FUNCAO CTBAGLUT() USANDO CT2_SEQUEN )
			/// SE N�O ESTIVER AGLUTINADO LOCALIZA POSICIONA NO CV3 PELO RECNO DO CT2
			dbSelectArea("CV3")
			CV3->(DBSETORDER(2)) //Para realizar o indice, pois antes o indice corrente chegava como 1
			If dBOrdRecDes()	// SE N�O ACHOU O �NDICE PELO CV3_RECDES (NICKNAME CV3RECDES) J� SETOU O �NDICE
				If !dbSeek(xFilial("CV3")+cRecCT2,.F.)
					lAchou := .F.
				EndIf
			Else
				lAchou := .F.
			EndIf
		EndIf
	EndIf

	If lAchou			/// INDICA QUE ACHOU REGISTRO NO CV3 (POR ENQUANTO).
		If !Empty(CV3->CV3_TABORI) .and. !Empty(CV3->CV3_RECORI)
			/// PROCURA NO CT5 OU NO CTL PARA VER A ROTINA A EXECUTAR NA VISUALIZA��O
			dbSelectArea("CTL")
			dbSetOrder(1)
			dbSelectArea("CT5")
			dbSetOrder(1)
			If CT5->(dbSeek(xFilial("CT5")+CV3->CV3_LP,.F.)) .and. !Empty(CT5->CT5_ROTRAS)
				/// 1� ROTINA DE RASTREAMENTO SE HOUVER O CAMPO NO CT5
				cRotina := CT5->CT5_ROTRAS
			ElseIf CTL->(dbSeek(xFilial("CTL")+CV3->CV3_LP)) .AND. !Empty(CTL->CTL_EXECUT) /// SE HOUVER CTL CONFIGURADO PARA O LAN�AMENTO...
				/// 2� ROTINA DE RASTREAMENTO SE HOUVER NO CTL
				cRotina := CTL->CTL_EXECUT
			Else
				/// SE N�O TIVER EXECUTA ROTINA PADRAO AXVISUAL
				cRotina := "AxVisual(CV3->CV3_TABORI,Recno(),2)"
			EndIf

			dbSelectArea("SX2")
			dbSetOrder(1)
			If dbSeek(CV3->CV3_TABORI)

					cCadastro := alltrim(X2Nome())

				cCadastro += STR0016+alltrim(CV3->CV3_RECORI) //" - Registro: "

				dbSelectArea(CV3->CV3_TABORI)          /// SELECIONA A TABELA DE ORIGEM
				nRecOri := int(val(CV3->CV3_RECORI))   /// CONVERTE RECNO ORIGEM PARA NUMERICO
				dbGoTo(nRecOri)						   /// POSICIONA NO REGISTRO DE ORIGEM

				If CV3->CV3_TABORI $ 'SD1|SD2'
					If CV3->CV3_TABORI == 'SD1'
						dbSelectArea("SF1")
						dbSetOrder(1)
						dbSeek(SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_TIPO))
						dbSelectArea("SD1")
					Else
						dbSelectArea("SF2")
						dbSetOrder(2)
						dbSeek(SD2->(D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_DOC+D2_SERIE))
						dbSelectArea("SD2")
					EndIf
				Endif

				If (CV3->CV3_TABORI)->(!Eof()) .and. (CV3->CV3_TABORI)->(Recno()) == nRecOri	/// SE LOCALIZOU
					dbSetOrder(1)
					If Deleted()
						cCadastro := STR0017+cCadastro //" j� excluido."
					EndIf
					cFilOrig := cFilAnt
					If !Empty( CV3->CV3_TABORI )
						cFilAnt := &( PrefixoCpo(CV3->CV3_TABORI)+"_FILIAL" )
					EndIf
					If FunName() == "CTBC020"
						aRotina := { {OemToAnsi(STR0001),"AxPesqui"	, 0 , 1},;	// "Pesquisar"
									{OemToAnsi(STR0002),"AxVisual"	, 0 , 2}} 	// "Visualizar"
					End
					If cPaisLoc == "ARG" .And. Alltrim(cRotina) == "CTBRECIBO()"
						cFilAnt := cFilOrig
						&(cRotina)
					Else
						&(cRotina)
						cFilAnt := cFilOrig
					EndIf
				Else
					lAchou := .F.		/// /// SE N�O LOCALIZOU PELO RECNO DE ORIGEM TENTA RASTREAR PELO CTL
				EndIf
			Else
				lAchou := .F.
			EndIf
		Else
			lAchou := .F.
		EndIf
	EndIf

	If !lAchou 		// INDICA QUE N�O ENCONTROU NA ORIGEM.
		/// Se houver inconsistencia no rastreamento sem configura��o, rastrear pelo CTL
		If !Empty(CT2->CT2_KEY)		/// SE A CHAVE DE RASTREAMENTO ESTIVER PREENCHIDA
			lCTL   	:= .T.			/// EXECUTA RASTREAMENTO PELO CTL
		Else
			ApMsgAlert(STR0006) //"Verifique as chaves de relacionamento"
		EndIf
	EndIf
Else
	If !Empty(CT2->CT2_KEY)		/// SE A CHAVE DE RASTREAMENTO ESTIVER PREENCHIDA
		lCTL   	:= .T.			/// EXECUTA RASTREAMENTO PELO CTL
	Else
		ApMsgAlert(STR0006) //"Verifique as chaves de relacionamento"
	EndIf
EndIf



If lCTL   /// EFETUA RASTREAMENTO PELO CTL
	// Esta rotina podera ser chamada da CtbAglut ou de Ctba010Rot. Se for chamada de
	// CtbAglut, existir� um arq. de trabalho o qual conter� a posi��o do CV3, sen�o
	// ser� necess�rio pesquisar no CTK pela chave do CT2.
	If CT2->CT2_AGLUT == "1"
		//Caso seja lancamento aglutinado, considerar o LP do CV3, pois o lancamento poder ter sido aglutinado por LP
		//diferentes pela contabilizacao off-line
		cPadrao	:= CV3->CV3_LP

		dbSelectArea("CTL")
		DbSetOrder( 1 )
		If dbSeek( xFilial() + cPadrao )
			cArq		:= CTL->CTL_ALIAS
			nOrdem 		:= Val( CTL->CTL_ORDER )
			cChave 		:= RTrim(CV3->CV3_KEY)
			If	ChkFile( cArq )
				dbSelectArea(cArq)
				dbSetOrder(nOrdem)
				If dbSeek(cChave)
					If !Empty(CTL->CTL_EXECUT)
						&(CTL->CTL_EXECUT)
					Else
						cFilOrig := cFilAnt
						if !Empty( xFilial(cArq) )
							cFilAnt := &( PrefixoCpo(cArq)+"_FILIAL" )
						EndIf
						cCadastro := Alltrim(CTL->CTL_DESC)
						If !MaMakeView( cArq )
							dbSelectArea("SX2")
							dbSetOrder(1)
							dbSeek(cArq)
							cCadastro := AllTrim(X2NOME())+" - "+STR0002 // Visualizar
							dbSelectArea("SX3")
							dbSetOrder(1)
							dbSeek(cArq)
							While !Eof() .And. cArq==SX3->X3_ARQUIVO
								aAdd(aAcho,SX3->X3_CAMPO)
								dbSkip()
							End
							dbSelectArea(cArq)
							axVisual(cArq,(cArq)->(RecNo()),2,aAcho)
						EndIf
						cFilAnt := cFilOrig
					EndIf
				ElseIF ! Empty(cChave)
					ApMsgAlert(STR0007) //"Movimento correspondente nao encontrado !"
				Else
					ApMsgAlert(STR0008) //"Este lancamento foi gerado sem chave de relacionamento !"
				EndIf
			EndIf
		Else
			ApMsgAlert(STR0009) //"Verifique as chaves de relacionamento !"
		EndIf
	Else
		cPadrao	:= CT2->CT2_LP

		dbSelectArea("CTL")
		DbSetOrder( 1 )
		If dbSeek( xFilial("CTL") + cPadrao )
			cArq		:= CTL->CTL_ALIAS
			nOrdem 		:= Val( CTL->CTL_ORDER )
			cChave 		:= RTrim(CT2->CT2_KEY)
	  		If	ChkFile( cArq )
				dbSelectArea(cArq)
				dbSetOrder(nOrdem)
				If dbSeek(cChave)
					If !Empty(CTL->CTL_EXECUT)
						cFilOrig := cFilAnt
						if !Empty( xFilial(cArq) )
							cFilAnt := &( PrefixoCpo(cArq)+"_FILIAL" )
						EndIf
						&(CTL->CTL_EXECUT)
						cFilAnt := cFilOrig
					Else
						cFilOrig := cFilAnt
						if !Empty( xFilial(cArq) )
							cFilAnt := &( PrefixoCpo(cArq)+"_FILIAL" )
						EndIf
						cCadastro := Alltrim(CTL->CTL_DESC)
						AxVisual(cARQ,Recno(),2)
						cFilAnt := cFilOrig
					EndIf
				ElseIF !Empty(cChave)
					ApMsgAlert(STR0007) //"Movimento correspondente nao encontrado !"
				Else
					ApMsgAlert(STR0008) //"Este lancamento foi gerado sem chave de relacionamento !"
				EndIf
			EndIf
		Else
			ApMsgAlert(STR0009) //"Verifique as chaves de relacionamento !"
		EndIf
	Endif
EndIf

cCadastro := cCad
RestArea(aPosCT2)
RestArea(aAreaOri)

Return NIL


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �CTBC010Del� Autor � Wagner Mobile Costa   � Data � 13.11.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ativa/Desativa registro deletados                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CtbC010Del                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBC010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBC010Del

Local aRet := {}

If 	ParamBox( {	{3,STR0011,If(Set(_SET_DELETED), 2, 1),; //"Mostra deletados"
	{ STR0012, STR0013 },50,"",.F.}}, STR0010,@aRet) //"Sim"###"Nao"###"Status consulta"
	If aRet[1] = 1
		Set(_SET_DELETED, .F.)
	 Else
		Set(_SET_DELETED, .T.)
	Endif
Endif

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBC010   �Autor  �Microsiga           � Data �  01/30/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function dBOrdRecDes()

Local lRetorno := .T.

If dbNickOrder("CV3","CV3RECDES") == 0
	If !IsBlind()
		nAviso := 4
			MsgInfo(STR0014+CRLF+;
					"CV3_FILIAL+CV3_RECDES - NickName CV3RECDES ",;
					STR0015)//"ATENCAO ! Administrador."
					//STR0014="Verifique criacao de indices: "
					//STR0015="ATENCAO ! Administrador."
    EndIf
   	lRetorno := .F.
EndIf

Return lRetorno



/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �06/12/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"	, 0 , 1},;	// "Pesquisar"
                     {OemToAnsi(STR0002),"AxVisual"	, 0 , 2},; 	// "Visualizar"
                     {OemToAnsi(STR0003),"CtbC010Rot"	, 0 , 2},;
                     {STR0010	,"CtbC010Del"	, 0 , 0}} //"Status consulta"
Return(aRotina)
