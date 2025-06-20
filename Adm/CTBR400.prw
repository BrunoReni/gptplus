#Include "CTBR400.Ch"
#Include "PROTHEUS.Ch"
#Include "FWLIBVERSION.CH"
//AMARRACAO
#DEFINE TAM_VALOR  20
#DEFINE TAM_CONTA   17
#DEFINE AJUST_CONTA  10

Static lFWCodFil := .T.
Static cTpValor  := "D"
Static __cSegOfi := ""

Static _oCTBR400
Static lCtbRazBD := NIL  //RECEBERA MV_CTBRAZB (L)
Static __lBlind  := IsBlind()

Static lIsRedStor := FindFunction("IsRedStor") .and. IsRedStor() //Used to check if the Red Storn Concept used in russia is active in the system | Usada para verificar se o Conceito Red Storn utilizado na Russia esta ativo no sistema | Se usa para verificar si el concepto de Red Storn utilizado en Rusia esta activo en el sistema

Static nR400Char := Iif( Alltrim(UPPER(TcGetDb())) == "INFORMIX", 250, 1000 )

Static __cTipoSinal := NIL
Static __nDecimais  := NIL
Static __cPicture   := Nil
//Metricas apenas em Lib a partir de 20210517 e Binario 19.3.0.6
Static __lMetric	:= FwLibVersion() >= "20210517" .And. GetSrvVersion() >= "19.3.0.6"
Static __cMvCtbPlan := SuperGetMV("MV_CTBPLAN",.F.,"N")  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR400  � Autor � Cicero J. Silva   	� Data � 04.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Raz�o Cont�bil         			 		 				 ���
�������������������������������������������������������������������������Ĵ��MS
���Sintaxe	 � CTBR400()    											  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nenhum       											  ���
�������������������������������������������������������������������������Ĵ��
���Uso 		 � SIGACTB      			cTmpCTHFil								  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function CTBR400(cContaIni, cContaFim, dDataIni, dDataFim, cMoeda, cSaldos,;
				 cBook, lCusto, cCustoIni, cCustoFim, lItem, cItemIni, cItemFim,;
				 lClVl, cClvlIni, cClvlFim,lSaltLin,cMoedaDesc,aSelFil )


Local aArea := GetArea()
Local aCtbMoeda		:= {}

Local cArqTmp		:= ""
Local lOk := .T.
Local lExterno		:= cContaIni <> Nil
Local lImpRazR4	:= TRepInUse()

Local lTodasFil 	:= .F.
Local cTmpProc      := ""  // procedure SaldoCT7fIL
Local cTmpCTX       := ""  // Tabela Temp filiais
Local lProcSldP     := .F.
Local cTmpFil       := ""
Local cQuery        := ""
Local cTmpCq1		:= ""

PRIVATE cTipoAnt	:= ""
PRIVATE cPerg	 	:= "CTR400"
PRIVATE nomeProg  	:= "CTBR400"
PRIVATE nSldTransp	:= 0 // Esta variavel eh utilizada para calcular o valor de transporte
PRIVATE oReport
PRIVATE nLin		:= 0
PRIVATE nLinha		:= 6
PRIVATE nTipoRel    := 0
PRIVATE lDeTransp   := .F.
Private nStart		:= 0

DEFAULT lCusto		:= .F.
DEFAULT lItem		:= .F.
DEFAULT lCLVL		:= .F.
DEFAULT lSaltLin	:= .T.
DEFAULT cMoedaDesc  := cMoeda // RFC - 18/01/07 | BOPS 103653
DEFAULT aSelFil		:= {}


cTpValor := Alltrim(SuperGetMV("MV_TPVALOR"))
__cSegOfi  := SuperGetMV("MV_SEGOFI",,"0")

lOk := AMIIn(34)		// Acesso somente pelo SIGACTB

If lOk
	Pergunte("CTR400", .F.)
	If !lExterno
		lOk := Pergunte("CTR400", .T.)
	Endif
Endif

If lOk
	//Verifica se o relatorio foi chamado a partir de outro programa. Ex. CTBC400
	If !lExterno
		lCusto	:= Iif(mv_par12 == 1,.T.,.F.)
		lItem	:= Iif(mv_par15 == 1,.T.,.F.)
		lCLVL	:= Iif(mv_par18 == 1,.T.,.F.)
		// Se aFil nao foi enviada, exibe tela para selecao das filiais
		If lOk .And. mv_par36 == 1 .And. Len( aSelFil ) <= 0
				aSelFil := AdmGetFil(@lTodasFil)

			If Len( aSelFil ) <= 0
				lOk := .F.
			EndIf
		EndIf
	Else  //Caso seja externo, atualiza os parametros do relatorio com os dados passados como parametros.
		mv_par01 := cContaIni
		mv_par02 := cContaFim
		mv_par03 := dDataIni
		mv_par04 := dDataFim
		mv_par05 := cMoeda
		mv_par06 := cSaldos
		mv_par07 := cBook
		mv_par12 := If(lCusto =.T.,1,2)
		mv_par13 := cCustoIni
		mv_par14 := cCustoFim
		mv_par15 := If(lItem =.T.,1,2)
		mv_par16 := cItemIni
		mv_par17 := cItemFim
		mv_par18 := If(lClVl =.T.,1,2)
		mv_par19 := cClVlIni
		mv_par20 := cClVlFim
		mv_par31 := If(lSaltLin==.T.,1,2)
		mv_par32 := 56
		mv_par34 := cMoedaDesc
	Endif
Endif

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)			 �
//����������������������������������������������������������������
If ! ct040Valid(mv_par07) // Set Of Books
		lOk := .F.
EndIf

If lOk .And. mv_par32 < 15
		ShowHelpDlg("MINQTDELIN", {"Valor informado inv�lido do","'Num. linhas p/ o raz�o'"},5,{"Favor preencher uma quantidade","m�nima de 15 linhas"},5)
		lOk := .F.
EndIf

If lOk
    aCtbMoeda  	:= CtbMoeda(MV_PAR05) // Moeda?
    If Empty( aCtbMoeda[1] )
			Help(" ",1,"NOMOEDA")
		    lOk := .F.
		Endif

	IF lOk .And. ! Empty( mv_par34 )
			aCtbMoeddesc := CtbMoeda(mv_par34) // Moeda?

		    If Empty( aCtbMoeddesc[1] )
				Help(" ",1,"NOMOEDA")
			    lOk := .F.
			Endif
			aCtbMoeddesc := nil
		Endif
Endif

If Select("cArqTmp") > 0
	cArqTmp->(dbCloseArea())
EndIf

If lOk
	If lImpRazR4

		lCtbRazBD := CTB400RAZB()
		/*  ----------------------------------------------------------------------------------
			Crio procedure xfilial - cTmpFil
			Crio Procedure para SaldoCT7Fil caso par�metro (MV_CTBRZAB) de procedure habilitado
			-----------------------------------------------------------------------
			Se par�metro MV_CTBRAZB .T. e se BD Homologados (MSSQL7/DB2/ORACLE/INFORMIX)
		    ----------------------------------------------------------------------------------- */
		If lCtbRazBD 
			//ConOut( " INICIO Cria SaldoCT7FIl : "+ Time())
			//lProcSldF :=  CallXFilial(@cTmpFil) //removido procedure callXFilial pois causava erro quando selecionado range de filiais
			// If lProcSldF
			If __lBlind
				lProcSldP := CTR400SldP(@cTmpProc, aSelFil, lTodasFil, @cTmpCTX, cTmpFil,@cTmpCq1 )
			else
				FWMsgRun(, {|oSay| lProcSldP := CTR400SldP(@cTmpProc, aSelFil, lTodasFil, @cTmpCTX, cTmpFil,@cTmpCq1) }, "Processando", "Executando Procedure...")
			endIf 
			// EndIf
			//ConOut( " FIM Cria SaldoCT7FIl    : "+ Time())
		Endif
		//ConOut( " INICIO Impressao : "+ Time())
		CTBR400R4(aCtbMoeda,lCusto,lItem,lCLVL,@cArqTmp,aSelFil,lTodasFil, lProcSldP, @cTmpProc )
		//ConOut( " FIM Impressao    : "+ Time())
	Else
		CTBR400R3( cContaIni, cContaFim, dDataIni, dDataFim, cMoeda, cSaldos,;
					cBook, lCusto, cCustoIni, cCustoFim, lItem, cItemIni, cItemFim,;
					lClVl, cClvlIni, cClvlFim,lSaltLin,cMoedaDesc,aSelFil ) // Executa vers�o anterior do fonte
	Endif
Endif

If lCtbRazBD != nil .and. lCtbRazBD
	If lProcSldP
		cQuery := "Drop procedure "+cTmpProc + CRLF 
		If TcSqlExec(cQuery) <> 0
			If !__lBlind
				MsgAlert(STR0067+ cTmpProc+STR0068) //"Erro na exclusao da Procedure: "###". Excluir manualmente no banco"
			Endif
		Endif
	EndIf

	If !Empty(cTmpCq1) // apada o tempor�rio com o range de filiais quando esse foi criado
		CtbTmpErase(cTmpCq1)
	EndIf
	If !Empty(cTmpCTX)
		CtbTmpErase(cTmpCTX)
	Endif
	// If lProcSldF // cria��o da procedure foi removida
	// 	cQuery := "Drop procedure "+cTmpFil + CRLF
	// 	If TcSqlExec(cQuery) <> 0
	// 		If !__lBlind
	// 			MsgAlert(STR0067+ cTmpFil+STR0068) //"Erro na exclusao da Procedure: "###". Excluir manualmente no banco"
	// 		EndIf
	// 	Endif
	// EndIf
EndIf

CTBRazClean() //Fechar a TMP caso exista
lCtbRazBD := NIL
RestArea(aArea)
aSize(aArea,0)
aArea := nil 

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CTBR400R4 � Autor �                    � Data �  15/09/09  ���
�������������������������������������������������������������������������͹��
���Descricao �Impressao do relatorio em R4                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTBR400R4(aCtbMoeda,lCusto,lItem,lCLVL,cArqTmp,aSelFil,lTodasFil, lProcSld, cTmpProc  )
Default lProcSld := .F.
Default cTmpProc := ""
oReport := ReportDef(aCtbMoeda,lCusto,lItem,lCLVL,@cArqTmp,aSelFil,lTodasFil,lProcSld, cTmpProc)
oReport:PrintDialog()

oReport := Nil

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ReportDef � Autor � Cicero J. Silva    � Data �  01/08/06  ���
�������������������������������������������������������������������������͹��
���Descricao � Definicao do objeto do relatorio personalizavel e das      ���
���          � secoes que serao utilizadas                                ���
�������������������������������������������������������������������������͹��
���Parametros� aCtbMoeda  - Matriz ref. a moeda                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef(aCtbMoeda,lCusto,lItem,lCLVL,cArqTmp,aSelFil,lTodasFil, lProcSld, cTmpProc)

Local oReport
Local oSection1		//Conta
Local oSection1_1  	// Totalizador da Conta
Local oSection2
Local oSection3
Local cDesc1		:= STR0001	//"Este programa ir� imprimir o Raz�o Contabil,"
Local cDesc2		:= STR0002	// "de acordo com os parametros solicitados pelo"
Local cDesc3		:= STR0003	// "usuario."
Local titulo		:= STR0006 	//"Emissao do Razao Contabil"

Local aTamConta	:= TAMSX3("CT1_CONTA")
Local aTamCusto	:=  TAMSX3("CT3_CUSTO")
Local nTamConta	:= Len(CriaVar("CT1_CONTA"))
Local nTamHist	:= If(cPaisLoc$"CHI|PAR",29,40)
Local nTamItem	:= Len(CriaVar("CTD_ITEM"))
Local nTamCLVL	:= Len(CriaVar("CTH_CLVL"))
Local nTamLote	:= Len(CriaVar("CT2_LOTE")+CriaVar("CT2_SBLOTE")+CriaVar("CT2_DOC")+CriaVar("CT2_LINHA"))
Local nTamData	:= 10

Local lAnalitico	:= If(mv_par08 == 1,.T.,.F.)

Local lSalto		:= Iif(mv_par21==1,.T.,.F.)// Salto de pagina                       �

Local cSayCusto	:= CtbSayApro("CTT")
Local cSayItem		:= CtbSayApro("CTD")
Local cSayClVl		:= CtbSayApro("CTH")

Local aSetOfBook 	:= CTBSetOf(mv_par07)// Set Of Books
Local cPicture 		:= aSetOfBook[4]
Local cDescMoeda 	:= aCtbMoeda[2]
Local nDecimais 	:= Iif(DecimalCTB(aSetOfBook,mv_par05) = 0, SuperGetMv("MV_CENT"), DecimalCTB(aSetOfBook,mv_par05))// Moeda
Local nTamFilial 	:= IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3( "CT2_FILIAL" )[1] )
Local lNumAsto     := Iif(cPaisLoc == "PAR" .And. CT2->(FieldPos("CT2_NACSEQ")) > 0, .T., .F.)
DEFAULT aSelFil		:= {}
Default lProcSld    := .F.
Default cTmpProc    := ""

//Iniciar telemetria - Tempo m�dio
If FunName() <> "CTBC400" .And. __lMetric
	nStart := Seconds()
EndIf
nTipoRel := mv_par08  // Tipo de Relatorio -> Analitico, Resumido ou Sintetico

aTamCusto[1]	:= 20
nTamItem		:= 20
nTamCLVL		:= 20

If mv_par11 == 3 						//// SE O PARAMETRO DO CODIGO ESTIVER PARA IMPRESSAO
	nTamConta := Len(CT1->CT1_CODIMP)	//// USA O TAMANHO DO CAMPO CODIGO DE IMPRESSAO
Else
	If nTipoRel == 1 // se analitico
		If (lCusto .Or. lItem .Or. lCLVL)
			nTamConta := 30						// Tamanho disponivel no relatorio para imprimir
		Else
			nTamConta := 40						// Tamanho disponivel no relatorio para imprimir
		Endif
	EndIf
Endif

oReport := TReport():New(nomeProg,titulo,cPerg, {|oReport| ReportPrint(oReport,aCtbMoeda,aSetOfBook,cPicture,cDescMoeda,nDecimais,nTamConta,lAnalitico,lCusto,lItem,lCLVL,cArqTmp,aSelFil,lTodasFil,lProcSld,cTmpProc)},cDesc1+cDesc2+cDesc3)

//Habilitado o parametro de personaliza��o por�m,
// n�o ser� permitido a altera��o das sections
IF GETNEWPAR("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
ENDIF

oReport:SetTotalInLine(.F.)
oReport:EndPage(.T.)

If nTipoRel == 1 // Analitico
	oReport:SetLandScape(.T.)
Else
	oReport:SetPortrait(.T.)
EndIf

// oSection1
oSection1 := TRSection():New(oReport,STR0043,{"cArqTmp"},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/)	//"Conta"

If lSalto
	oSection1:SetPageBreak(.T.)
EndIf

TRCell():New(oSection1,"CONTA"	,"cArqTmp",STR0041,/*Picture*/,aTamConta[1],/*lPixel*/,/*{|| }*/)	//"CONTA"
TRCell():New(oSection1,"DESCCC"	,"cArqTmp",STR0042,/*Picture*/,nTamConta+20,/*lPixel*/,/*{|| }*/)		//"DESCRICAO"
oSection1:SetReadOnly()
oSection1:SetEdit(.F.)

// oSection2
oSection2 := TRSection():New(oReport,STR0044,{"cArqTmp","CT2"},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/,,,,,,.F.,,,,/*AutoSize*/.T.)	//"Custo"
oSection2:SetReadOnly()
oSection2:SetEdit(.F.)


If ( !Ctr400HasAut() )	//Somente se n�o for rob�
	TRCell():New(oSection2,"CONTA"	,"cArqTmp",STR0041,/*Picture*/,aTamConta[1],/*lPixel*/,/*{|| }*/)	//"CONTA"
	//TRCell():New(oSection2,"DESCCC"	,"cArqTmp",STR0042,/*Picture*/,nTamConta+20,/*lPixel*/,/*{|| }*/)		//"DESCRICAO"
EndIf

TRCell():New(oSection2,"DATAL"	,"cArqTmp",STR0019,/*Picture*/,11,/*lPixel*/,/*{|| }*/,/*"LEFT"*/,,/*"LEFT"*/,,,.F.)	// "DATA"
TRCell():New(oSection2,"DOCUMENTO"	,"cArqTmp"       ,STR0034,/*Picture*/,If(nTamLote < 20, 20,nTamLote),/*lPixel*/,{|| cArqTmp->LOTE+cArqTmp->SUBLOTE+cArqTmp->DOC+cArqTmp->LINHA },/*"LEFT"*/,,/*"LEFT"*/,,,.F.)// "LOTE/SUB/DOC/LINHA"
TRCell():New(oSection2,"HISTORICO"	,""		  ,STR0035,/*Picture*/,nTamHist+5	,/*lPixel*/,{|| cArqTmp->HISTORICO},/*"LEFT"*/,.T.,"LEFT",.T.,,.F.)// "HISTORICO"
TRCell():New(oSection2,"XPARTIDA"	,"cArqTmp",STR0036,/*Picture*/,24,/*lPixel*/,/*{|| }*/,/*"LEFT"*/,,/*"LEFT"*/,,,.F.)// "XPARTIDA"
TRCell():New(oSection2,"Filial"		,""		  ,STR0058,/*Picture*/,4,/*lPixel*/,/*{|| }*/)// "FILIAL"
TRCell():New(oSection2,"CCUSTO"		,"cArqTmp",Upper(cSayCusto),/*Picture*/,aTamCusto[1],/*lPixel*/,{|| IIF(lCusto == .T.,cArqTmp->CCUSTO,Nil) },"CENTER",,"CENTER",,,.F.)// Centro de Custo
TRCell():New(oSection2,"ITEM"		,"cArqTmp",Upper(cSayItem) ,/*Picture*/,nTamItem,/*lPixel*/,{|| IIF(lItem == .T.,cArqTmp->ITEM,Nil) },/*"LEFT"*/,,/*"LEFT"*/,,,.F.)// Item Contabil
TRCell():New(oSection2,"CLVL"		,"cArqTmp",Upper(cSayClVl) ,/*Picture*/,nTamCLVL,/*lPixel*/,{|| IIF(lCLVL == .T.,cArqTmp->CLVL,Nil) },/*"LEFT"*/,,/*"LEFT"*/,,,.F.)// Classe de Valor
If cTpValor != "P"
	TRCell():New(oSection2,"CLANCDEB"	,"cArqTmp",STR0037,/*Picture*/,TAM_VALOR,/*lPixel*/,/*{|| }*/,/*"RIGHT"*/,,"CENTER",,,.F.)// "DEBITO"
	TRCell():New(oSection2,"CLANCCRD"	,"cArqTmp",STR0038,/*Picture*/,TAM_VALOR,/*lPixel*/,/*{|| }*/,/*"RIGHT"*/,,"CENTER",,,.F.)// "CREDITO"
	TRCell():New(oSection2,"CTPSLDATU"	,"cArqTmp",STR0039,/*Picture*/,TAM_VALOR+2,/*lPixel*/,/*{|| }*/,/*"RIGHT"*/,,"CENTER",,,.F.)// "SALDO ATUAL"
Else
	TRCell():New(oSection2,"CLANCDEB"	,"cArqTmp",STR0037,/*Picture*/,TAM_VALOR,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT",,,.F.)// "DEBITO"
	TRCell():New(oSection2,"CLANCCRD"	,"cArqTmp",STR0038,/*Picture*/,TAM_VALOR,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT",,,.F.)// "CREDITO"
	TRCell():New(oSection2,"CTPSLDATU"	,"cArqTmp",STR0039,/*Picture*/,TAM_VALOR+2,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT",,,.F.)// "SALDO ATUAL"
EndIf
oSection2:Cell("DOCUMENTO"):lHeaderSize	:= .F.
oSection2:Cell("HISTORICO"):lHeaderSize	:= .F.
oSection2:Cell("XPARTIDA"):lHeaderSize	:= .F.
oSection2:Cell("FILIAL"):lHeaderSize	:= .F.
oSection2:Cell("CCUSTO"):lHeaderSize	:= .F.
oSection2:Cell("ITEM"):lHeaderSize		:= .F.
oSection2:Cell("CLVL"):lHeaderSize		:= .F.
oSection2:Cell("CLANCDEB"):lHeaderSize	:= .F.
oSection2:Cell("CLANCCRD"):lHeaderSize	:= .F.
oSection2:Cell("CTPSLDATU"):lHeaderSize	:= .F.

//Desabilita a coluna conta na Se��o 2 por princ�pio
If ( !Ctr400HasAut() )	//Somente se n�o for rob�
	oSection2:Cell("CONTA"):Disable()
	//oSection2:Cell("DESCCC"):Disable()
EndIf	

If !Empty(__cSegOfi) .And. __cSegOfi != "0"
	TRCell():New(oSection2,"SEGOFI"	,"cArqTmp","SEGOFI",/*Picture*/,TamSx3("CT2_SEGOFI")[1],/*lPixel*/,{|| cArqTmp->SEGOFI }) //"SEGOFI"
EndIf

//*************************************************************
// Tratamento do campo SEGOFI para Chile e Argentina          *
// Caso o relatorio seja resumido imprime na coluna historico *
// Caso seja analitico imprime em uma nova coluna.            *
//*************************************************************

If cPaisLoc $ "CHI" .and. nTipoRel == 1 //Se for relatorio analitico

	oSection2:Cell("HISTORICO"):SetSize(29)
	oSection2:Cell("HISTORICO"):SetBlock( { || Subs(cArqTmp->HISTORICO,1,29)})
Elseif cPaisLoc == "ARG" .and. nTipoRel == 1
	oSection2:Cell("HISTORICO"):SetSize(40)
	oSection2:Cell("HISTORICO"):SetBlock( { || Subs(cArqTmp->HISTORICO,1,40)})
ElseIf !Empty(__cSegOfi) .And. __cSegOfi != "0" .AND. nTipoRel = 3 //Se for relatorio Sintetico

	oSection2:Cell("SEGOFI"):Hide()
	oSection2:Cell("SEGOFI"):HideHeader()

	oSection2:Cell("DOCUMENTO"):SetTitle(STR0034 + " - " + "SEGOFI")
	oSection2:Cell("DOCUMENTO"):SetSize(oSection2:Cell("DOCUMENTO"):GetSize() + Len(CriaVar("CT2_SEGOFI")) )
 	oSection2:Cell("DOCUMENTO"):SetBlock( { || cArqTmp->LOTE+cArqTmp->SUBLOTE+cArqTmp->DOC+cArqTmp->LINHA+" - "+cArqTmp->SEGOFI } )
 	oSection2:Cell("HISTORICO"):SetBlock( { || Subs(cArqTmp->HISTORICO,1,40)})
EndIf


//****************************************
// Oculta campos para relatorio resumido *
//****************************************

If nTipoRel == 3 // Sintetico

  	oSection2:Cell("DOCUMENTO"):Hide()
	oSection2:Cell("DOCUMENTO"):SetTitle('')

  	oSection2:Cell("HISTORICO"):Hide()
 	oSection2:Cell("HISTORICO"):SetTitle('')
  	oSection2:Cell("HISTORICO"):SetSize(0)

    oSection2:Cell("XPARTIDA"):Disable()
    oSection2:Cell("FILIAL"):Disable()

EndIf

If nTamFilial > 4
	oSection2:Cell("FILIAL"):Disable()
Endif

//********************************
// Imprime linha saldo anterior  *
//********************************

//oSection1_1 - Totalizadores Conta

oSection1_1 := TRSection():New(oReport,STR0050,/*{"cArqTmp","CT2"}*/,/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/)

// Tamanho da coluna descri��o da se��o Section1_1
nTamDesc := Len(STR0016)+nTamConta+65

TRCell():New(oSection1_1,"DESCRICAO","cArqTmp","",/*Picture*/,nTamDesc,/*lPixel*/,{|| })
TRCell():New(oSection1_1,"SALDOANT","cArqTmp","",/*Picture*/,TAM_VALOR + 20,/*lPixel*/,{|| },"RIGHT",,"RIGHT")
oSection1_1:SetHeaderSection(.F.)
oSection1_1:SetReadOnly()
oSection1_1:SetEdit(.F.)

//oSection3 - Totalizadores Transporte

oSection3 := TRSection():New(oReport,STR0051,/*Alias*/,/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/,,,,,,.F.,,,)	//"Transporte"

If nTipoRel == 3 // relatorio sintetico
	TRCell():New(oSection3,"CTRANSP"	,/*Alias*/,/*titulo*/,/*Picture*/,80,/*lPixel*/,/*{|| }*/,/*"LEFT"*/,,/*"LEFT"*/,,,.F.)
	TRCell():New(oSection3,"DUMMY"	,/*Alias*/,/*titulo*/,/*Picture*/,If(nTamLote < 20, 20,nTamLote) /**/,/*lPixel*/,/*{||}*/,,,,,,.F.)

else
	TRCell():New(oSection3,"CTRANSP"	,/*Alias*/,/*titulo*/,/*Picture*/,If(nTamLote < 20, 20,nTamLote) /**/,/*lPixel*/,/*{||}*/,,,,,,.F.)
endif

If lNumAsto .and. nTipoRel == 1
	TRCell():New(oSection2,"NASIENTO"	,""		  ,"Nro Asiento",/*Picture*/,6	,/*lPixel*/,{|| cArqTmp->NASIENTO},"CENTER",.F.,"RIGHT",,,.F.)// N�mero asiento
EndIf

TRCell():New(oSection3,"HISTORICO"	,""		  ,STR0035,/*Picture*/,nTamHist+2	,/*lPixel*/,{|| cArqTmp->HISTORICO},/*"LEFT"*/,.T.,/*"LEFT"*/,,,.F.)// "HISTORICO"
TRCell():New(oSection3,"XPARTIDA"	,"cArqTmp",STR0036,/*Picture*/,24,/*lPixel*/,/*{|| }*/,/*"LEFT"*/,,/*"LEFT"*/,,,.F.)// "XPARTIDA"
TRCell():New(oSection3,"Filial"		,""		  ,"Fil"/*STR0052*/,/*Picture*/,4,/*lPixel*/,/*{|| }*/)// "FILIAL"
TRCell():New(oSection3,"CCUSTO"		,"cArqTmp",Upper(cSayCusto),/*Picture*/,aTamCusto[1],/*lPixel*/,,/*"LEFT"*/,,/*"LEFT"*/,,,.F.)// Centro de Custo
TRCell():New(oSection3,"ITEM"		,"cArqTmp",Upper(cSayItem) ,/*Picture*/,nTamItem,/*lPixel*/,,/*"LEFT"*/,,/*"LEFT"*/,,,.F.)// Item Contabil
TRCell():New(oSection3,"CLVL"		,"cArqTmp",Upper(cSayClVl) ,/*Picture*/,nTamCLVL,/*lPixel*/,,/*"LEFT"*/,,/*"LEFT"*/,,,.F.)// Classe de Valor

If cTpValor != "P"
	TRCell():New(oSection3,"CLANCDEB"	,"cArqTmp",STR0037,/*Picture*/,TAM_VALOR,/*lPixel*/,,/*"RIGHT"*/,,"CENTER",,,.F.)// "DEBITO"
	TRCell():New(oSection3,"CLANCCRD"	,"cArqTmp",STR0038,/*Picture*/,TAM_VALOR,/*lPixel*/,,/*"RIGHT"*/,,"CENTER",,,.F.)// "CREDITO"
	TRCell():New(oSection3,"CSLDATU"	,/*Alias*/,/*titulo*/,/*Picture*/,TAM_VALOR+2,/*lPixel*/,/*{||}*/,,,"CENTER",,,.F.)// "SALDO"
Else
	TRCell():New(oSection3,"CLANCDEB"	,"cArqTmp",STR0037,/*Picture*/,TAM_VALOR,/*lPixel*/,,"RIGHT",,"RIGHT",,,.F.)// "DEBITO"
	TRCell():New(oSection3,"CLANCCRD"	,"cArqTmp",STR0038,/*Picture*/,TAM_VALOR,/*lPixel*/,,"RIGHT",,"RIGHT",,,.F.)// "CREDITO"
	TRCell():New(oSection3,"CSLDATU"	,/*Alias*/,/*titulo*/,/*Picture*/,TAM_VALOR+2,/*lPixel*/,/*{||}*/,"RIGHT",,"RIGHT",,,.F.)// "SALDO"
EndIf


oSection3:Cell("HISTORICO"):Hide()
oSection3:Cell("XPARTIDA"):Hide()
oSection3:Cell("Filial"):Hide()
oSection3:Cell("CCUSTO"):Hide()
oSection3:Cell("ITEM"):Hide()
oSection3:Cell("CLVL"):Hide()
oSection3:Cell("CLANCDEB"):Hide()
oSection3:Cell("CLANCCRD"):Hide()

If lNumAsto .and. nTipoRel == 1
	oSection2:Cell("NASIENTO"):SetSize(6)
EndIf

If nTipoRel == 3 // Sintetico

  	oSection3:Cell("DUMMY"):Hide()

  	oSection3:Cell("HISTORICO"):Hide()
 	oSection3:Cell("HISTORICO"):SetTitle('')
  	oSection3:Cell("HISTORICO"):SetSize(0)

    oSection3:Cell("XPARTIDA"):Disable()
    oSection3:Cell("Filial"):Disable()

EndIf

If nTamFilial > 4
	oSection3:Cell("Filial"):Disable()
Endif

oSection3:SetHeaderSection(.F.)
oSection3:SetReadOnly()
oSection3:SetEdit(.F.)

oSection3:Cell("CTRANSP"):lHeaderSize := .F.
oSection3:Cell("CSLDATU"):lHeaderSize := .F.

oSection4 := TRSection():New(oReport,STR0053,/*{"cArqTmp","CT2"}*/,/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/)  // Data

TRCell():New(oSection4,"DATAL"	,"cArqTmp",STR0019,/*Picture*/,nTamData,/*lPixel*/,/*{|| }*/,/*"LEFT"*/,,/*"LEFT"*/,,,.F.)	// "DATA"
oSection4:SetHeaderSection(.F.)
oSection4:SetReadOnly()
oSection4:SetEdit(.F.)

//N�o Imprimir cabe�alho
If MV_PAR37 == 2
    oReport:HideHeader()
	oReport:OnPageBreak( { || oReport:SkipLine(6)})
Endif

oReport:ParamReadOnly()

Return oReport

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportPrint� Autor � Cicero J. Silva    � Data �  14/07/06  ���
�������������������������������������������������������������������������͹��
���Descricao � Definicao do objeto do relatorio personalizavel e das      ���
���          � secoes que serao utilizadas                                ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,aCtbMoeda,aSetOfBook,cPicture,cDescMoeda,nDecimais,nTamConta,lAnalitico,lCusto,lItem,lCLVL,cArqTmp,aSelFil,lTodasFil, lProcSld, cTmpProc)

Local oSection1 	:= oReport:Section(1)
Local oSection2		:= oReport:Section(2)
Local oSection1_1	:= oReport:Section(3)
Local oSection3		:= oReport:Section(4)
Local oSection4		:= oReport:Section(5)

Local cFiltro		:= oSection2:GetAdvplExp()

Local aTamCusto		:= TAMSX3("CT3_CUSTO")

Local aSaldo		:= {}
Local aSaldoAnt		:= {}

Local cContaIni		:= mv_par01 // da conta
Local cContaFIm		:= mv_par02 // ate a conta
Local cMoeda		:= mv_par05 // Moeda
Local cSaldo		:= mv_par06 // Saldos
Local cCustoIni		:= mv_par13 // Do Centro de Custo
Local cCustoFim		:= mv_par14 // At� o Centro de Custo
Local cItemIni		:= mv_par16 // Do Item
Local cItemFim		:= mv_par17 // Ate Item
Local cCLVLIni		:= mv_par19 // Imprime Classe de Valor?
Local cCLVLFim		:= mv_par20 // Ate a Classe de Valor
Local cContaAnt		:= ""
Local cDescConta	:= ""
Local cCodRes		:= ""
Local cResCC		:= ""
Local cResItem		:= ""
Local cResCLVL		:= ""
Local cDescSint		:= ""
Local cContaSint	:= ""
Local cNormal 		:= ""

Local xConta		:= ""

Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""
Local cMascara1		:= ""
Local cMascara2		:= ""
Local cMascara3		:= ""
Local cMascara4		:= ""

Local dDataAnt		:= CTOD("  /  /  ")
Local dDataIni		:= mv_par03 // da data
Local dDataFim		:= mv_par04 // Ate a data

Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotGerDeb	:= 0
Local nTotGerCrd	:= 0
Local nVlrDeb		:= 0
Local nVlrCrd		:= 0
Local nCont			:= 0
Local lNoMov		:= Iif(mv_par09==1,.T.,.F.) // Imprime conta sem movimento?
Local lSldAnt		:= Iif(mv_par09==3,.T.,.F.) // Imprime conta sem movimento?
Local lJunta		:= Iif(mv_par10==1,.T.,.F.) // Junta Contas com mesmo C.Custo?
Local lPrintZero	:= Iif(mv_par30==1,.T.,.F.) // Imprime valor 0.00    ?
Local lPlanilha 	:= .F.
Local lImpLivro		:= .t.
Local lImpTermos	:= .f.
Local lSldAntCC		:= Iif(mv_par33 == 2, .T.,.F.)// Saldo Ant. nivel?Cta/C.C/Item/Cl.Vlr
Local lSldAntIt  	:= Iif(mv_par33 == 3, .T.,.F.)// Saldo Ant. nivel?Cta/C.C/Item/Cl.Vlr
Local lSldAntCv  	:= Iif(mv_par33 == 4, .T.,.F.)// Saldo Ant. nivel?Cta/C.C/Item/Cl.Vlr
Local lSintetico	:= Iif(mv_par08 == 3, .T.,.F.)// Verifica se � sint�tico.
Local lSalto		:= Iif(mv_par21==1,.T.,.F.)// Salto de pagina 

Local cMoedaDesc	:= iif( Empty( mv_par34 ) , cMoeda , mv_par34 ) // RFC - 18/01/07 | BOPS 103653
Local nMaxLin   	:= mv_par32 // Num.linhas p/ o Razao?

Local lResetPag		:= .T.
Local m_pag			:= 1 // controle de numera��o de pagina
Local nPagIni		:= mv_par22
Local nPagFim		:= mv_par23
Local nReinicia		:= mv_par24
Local nBloco		:= 0
Local nBlCount		:= 1
Local nX
Local lColDbCr 		:= .T. // Disconsider cTipo in RZValorCTB function, setting cTipo to empty
Local lAvancaReg 	:= .T.
Local aRet          := {}
Local cTipoSinal    := SuperGetMV("MV_TPVALOR")
Local lCancel		:= .F.
Local nTamContaD    := 0
Local cFilialAnt	:= ''
Local cSelFilial	:= ''
Local cTrataLen	    := ''
Local cQueryTam		:= ''

Local nLnMxLand		:= 75
Local nLnMxPort		:= 58
Local nIncMeter as numeric

Local nQtdReg 		:= 0
Local oPrepared    :=  NIL
Local nStart		:= 0 //Tratativa telemetria embarcando nessa att.
Default lProcSld    := .F.
Default cTmpProc     := ""
DEFAULT aSelFil		:= {}
nIncMeter := 0

If oReport:nDevice == 4
	lPlanilha := .T.
EndIf

If nDecimais = 0
	nDecimais := SuperGetMv("MV_CENT")
EndIf

lCtbRazBD := CTB400RAZB()

aTamCusto[1] := 25

If ( !Ctr400HasAut() )	//Somente se n�o for rob� e o Formato de impressao selecionado pelo usuario foi Tabela em Excel
	
	If ( oReport:lXLSTable )
		oReport:Section(2):Cell("CONTA"):Enable()
		//oReport:Section(2):Cell("DESCCC"):Enable()
	EndIf

EndIf

//Limita��o de linhas para impress�o do relat�rio.
If oReport:GetOrientation() == 1 .And. nMaxLin > nLnMxLand //Retrato
	//Alert("Aten��o. Para esta vers�o do relat�rio, o n�mero de linhas n�o pode ser maior que 75.")
	nMaxLin := nLnMxLand
ElseIf oReport:GetOrientation() == 2 .And. nMaxLin > nLnMxPort //Paisagem
	//Alert("Aten��o. Para esta vers�o do relat�rio, o n�mero de linhas n�o pode ser maior que 58.")
	nMaxLin := nLnMxPort
EndIf

If oReport:GetOrientation() == 1 .or. nTipoRel > 1 // Resumido ou Sintetico

   	oSection2:Cell("CCUSTO"):Disable()
  	oSection2:Cell("ITEM"):Disable()
  	oSection2:Cell("CLVL"):Disable()

    oSection3:Cell("CCUSTO"):Disable()
  	oSection3:Cell("ITEM"):Disable()
  	oSection3:Cell("CLVL"):Disable()

    MsgAlert(STR0049) // "Aten��o, as colunas das entidades Cl Valor, C.Custo e Item Cont�bil  n�o ser�o impressas no modo retrato ou na op��o Resumido.")

Endif

If oReport:nDevice == 4	//Tratativa para modo planilha 

    If Len( aSelFil ) > 0 
		cFilialAnt := cFilAnt
		For nX := 1 To Len(aSelFil)
			cFilAnt := aSelFil[nx]
			cSelFilial += "'"+ xFilial( "CT1" ) + "'"	 
			If nX < Len(aSelFil)
				cSelFilial += ','
			EndIf
		Next
		cFilAnt := cFilialAnt
	Else
		cSelFilial += "'"+ xFilial( "CT1" ) + "'"	
	EndIf
	If (Alltrim(UPPER(TcGetDb())) $ "MSSQL7||MSSQL||MYSQL"  )
		cTrataLen := 'LEN'
	Else 
		cTrataLen := 'LENGTH'
	EndIf	
	/*procuro no range de contas selecionado o valor maior da soma dos campos
	 conta e descri��o para definir o tamanho exato que a celula ir� precisar */
	cQueryTam := "SELECT MAX("+cTrataLen+"(CT1_CONTA)+"+cTrataLen+"(CT1_DESC01)) TAM" 
	cQueryTam +=			 	" FROM " + RetSqlName("CT1") 
	
	If Len( aSelFil ) > 0 
		cQueryTam +=				" WHERE CT1_FILIAL IN (?) AND"//					" WHERE CT1_FILIAL IN (" + cSelFilial + ") AND" +;
	else
		cQueryTam +=				" WHERE CT1_FILIAL = ? AND"
	EndIf
	
	cQueryTam +=				" CT1_CONTA >= ? AND CT1_CONTA<= ?" //" CT1_CONTA >= '" + cContaIni + "' AND CT1_CONTA<='"+ cContaFIm +"'" +;
	cQueryTam +=				" AND D_E_L_E_T_ = ' ' "
	//cQueryTam := ChangeQuery(cQueryTam)

	oPrepared := FWPreparedStatement():New(cQueryTam)

	If Len( aSelFil ) > 0 
		oPrepared:SetIn( 1, aSelfil	)
	else
		oPrepared:SetString( 1, cSelFilial	)
	EndIf
	oPrepared:SetString( 2, cContaIni	)
	oPrepared:SetString( 3, cContaFIm	)
	cQueryTam := oPrepared:GetFixQuery()

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryTam),"cAliasTam",.T.,.F.)

	nTamContaD := cAliasTam->(TAM)
	cAliasTam->(dbCloseArea())
	
	oSection1_1:Cell("DESCRICAO"):SetSize(nTamContaD+11) //tamanho da descri��o + tamanho da conta+Len(STR0016)+ " - "
	oSection2:Cell("FILIAL"):Enable()
	oSection3:Cell("FILIAL"):Enable()
	oSection2:Cell("DATAL"):Enable()
	oSection4:Cell("DATAL"):Disable()
Else
	If lSintetico
		oSection2:Cell("DATAL"):Enable()
		oSection4:Cell("DATAL"):Disable()
	Else
		oSection2:Cell("DATAL"):Disable()
		oSection4:Cell("DATAL"):Enable()
	EndIf
Endif

// Mascara da Conta
cMascara1 := IIf (Empty(aSetOfBook[2]),SuperGetMv("MV_MASCARA"),RetMasCtb(aSetOfBook[2],@cSepara1) )

If lCusto .Or. lItem .Or. lCLVL
	// Mascara do Centro de Custo
	cMascara2 := IIf ( Empty(aSetOfBook[6]),SuperGetMv("MV_MASCCUS"),RetMasCtb(aSetOfBook[6],@cSepara2) )
	// Mascara do Item Contabil
	dbSelectArea("CTD")
	cMascara3 := IIf ( Empty(aSetOfBook[7]),SuperGetMv("MV_MASCCTD"),RetMasCtb(aSetOfBook[7],@cSepara3) )
	// Mascara da Classe de Valor
	dbSelectArea("CTH")
	cMascara4 := IIf ( Empty(aSetOfBook[8]),SuperGetMv("MV_MASCCTH"),RetMasCtb(aSetOfBook[8],@cSepara4) )

EndIf

//��������������������������������������������������������������Ŀ
//� Impressao de Termo / Livro                                   �
//����������������������������������������������������������������
Do Case
	Case mv_par29==1 ; lImpLivro:=.t. ; lImpTermos:=.f.
	Case mv_par29==2 ; lImpLivro:=.t. ; lImpTermos:=.t.
	Case mv_par29==3 ; lImpLivro:=.f. ; lImpTermos:=.t.
EndCase

//��������������������������������������������������������������������������Ŀ
//�Titulo do Relatorio                                                       �
//����������������������������������������������������������������������������

If oReport:Title() == oReport:cRealTitle //If Type("NewHead")== "U"
	IF nTipoRel == 1 //lAnalitico
		Titulo	:=	STR0007	//"RAZAO ANALITICO EM "
	ElseIf nTipoRel == 2 // Resumido
		Titulo	:=	STR0054	//"RAZAO RESUMIDO EM "
	Else  // Sintetico
		Titulo	:=	STR0008	//"RAZAO SINTETICO EM "
	EndIf
	Titulo += 	cDescMoeda + STR0009 + DTOC(dDataIni) +;	// "DE"
				STR0010 + DTOC(dDataFim) + CtbTitSaldo(mv_par06)	// "ATE"
Else
	Titulo := oReport:Title()  //NewHead
EndIf

oReport:SetTitle(Titulo)

oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataFim,oReport:Title(),,,,,oReport,.T.,@lResetPag,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.,mv_par03) } )
oSection2:SetHeaderPage(.T.)
oSection1:OnPrintLine( {|| CTR400Maxl(@nMaxLin,.F.,.F.)} )
oSection1_1:OnPrintLine( {|| CTR400Maxl(@nMaxLin,.F.,.F.)} )
oSection2:OnPrintLine( {|| CTR400Maxl(@nMaxLin,.F.,.F.)} )
oSection4:OnPrintLine( {|| CTR400Maxl(@nMaxLin,.F.,.F.)} )

oReport:OnPageBreak( {|| CTR400Maxl(@nMaxLin,.T.,.F.) } )

If lImpLivro
	//��������������������������������������������������������������Ŀ
	//� Monta Arquivo Temporario para Impressao   					 �
	//����������������������������������������������������������������
	If IsBlind()
		CTBGerRaz(,,,,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
								cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
								aSetOfBook,lNoMov,cSaldo,lJunta,"1",lAnalitico,,,cFiltro,lSldAnt,aSelFil, .T.)

	Else
		MsgMeter({|	oMeter, oText, oDlg, lEnd |;
		CTBGerRaz(	oMeter,oText,oDlg,@lEnd,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
								cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
								aSetOfBook,lNoMov,cSaldo,lJunta,"1",lAnalitico,,,cFiltro,lSldAnt,aSelFil,,@lCancel) },;
					STR0018,;		// "Criando Arquivo Tempor�rio..."
					STR0006)		// "Emissao do Razao"
	EndIf

	dbSelectArea("cArqTmp")
	dbGoTop()

	oReport:SetMeter( RecCount() )
	oReport:NoUserFilter()

Endif
/*RZValorCTB(	nSaldo,nLin,nCol,nTamanho,nDecimais,lSinal,cPicture,;
					cTipo,cConta,lGraf,oPrint,cTipoSinal, cIdentifi,lPrintZero,lSay,lColDbCr,lCharSinal,lPlanilha)*/

oBrkConta 	:= TRBreak():New( oSection2, { || cContaAnt }, OemToAnsi(STR0020), )
If cTpValor != "P" .Or. lPlanilha
	oTotDeb 	:= TRFunction():New( oSection2:Cell("CLANCDEB")	, ,"ONPRINT", oBrkConta,/*Titulo*/,cPicture,;
						{ || RZValorCTB(nTotDeb  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,,,lPlanilha) },.F.,.F.,.F.,oSection2)

	oTotCred	:= TRFunction():New( oSection2:Cell("CLANCCRD")	, ,"ONPRINT", oBrkConta,/*Titulo*/,cPicture,;
						{ || RZValorCTB(nTotCrd  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,,,lPlanilha) },.F.,.F.,.F.,oSection2)
	If lIsRedStor
		oTotTpSld2 	:= TRFunction():New( oSection2:Cell("CTPSLDATU")	, ,"ONPRINT", oBrkConta,/*Titulo*/,cPicture,;
							{ || RZValorCTB(RedStorTt(nTotDeb,nTotCrd,,cNormal,"D"),,,TAM_VALOR-2,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.,lColDbCr)},.F.,.F.,.F.,oSection2)
	Else
		oTotTpSld2 	:= TRFunction():New( oSection2:Cell("CTPSLDATU")	, ,"ONPRINT", oBrkConta,/*Titulo*/,cPicture,;
							{ || RZValorCTB(nSaldoAtu,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.,,,lPlanilha)},.F.,.F.,.F.,oSection2)
	EndIF
Else
	oTotDeb 	:= TRFunction():New( oSection2:Cell("CLANCDEB")	, ,"ONPRINT", oBrkConta,/*Titulo*/,cPicture,;
						{ || PadL(RZValorCTB(nTotDeb  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,,,lPlanilha),TAM_VALOR) },.F.,.F.,.F.,oSection2)


	oTotCred	:= TRFunction():New( oSection2:Cell("CLANCCRD")	, ,"ONPRINT", oBrkConta,/*Titulo*/,cPicture,;
						{ || PadL(RZValorCTB(nTotCrd  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr,,lPlanilha),TAM_VALOR) },.F.,.F.,.F.,oSection2)

	If lIsRedStor
		oTotTpSld2 	:= TRFunction():New( oSection2:Cell("CTPSLDATU")	, ,"ONPRINT", oBrkConta,/*Titulo*/,cPicture,;
							{ || PadL(RZValorCTB(RedStorTt(nTotDeb,nTotCrd,,cNormal,"D"),,,TAM_VALOR-2,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.,lColDbCr),TAM_VALOR+2)},.F.,.F.,.F.,oSection2)
	Else
		oTotTpSld2 	:= TRFunction():New( oSection2:Cell("CTPSLDATU")	, ,"ONPRINT", oBrkConta,/*Titulo*/,cPicture,;
							{ || PadL(RZValorCTB(nSaldoAtu,,,TAM_VALOR,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.,,,lPlanilha),TAM_VALOR+2)},.F.,.F.,.F.,oSection2)
	Endif
EndIf

If lImpLivro .And. mv_par28 == 1	//Imprime total Geral

	oBrkEnd 	:= TRBreak():New( oReport, { || /*cArqTmp->(Eof())*/	}, OemToAnsi(STR0025), )//"T O T A L  G E R A L  ==> "
	If cTpValor != "P" .Or. lPlanilha
		oTotGerDeb 	:= TRFunction():New( oSection2:Cell("CLANCDEB")	, ,"ONPRINT", oBrkEnd,/*Titulo*/,cPicture,;
					{ || RZValorCTB(nTotGerDeb  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,,,lPlanilha) },.F.,.F.,.F.,oSection2)
		oTotGerCred	:= TRFunction():New( oSection2:Cell("CLANCCRD")	, ,"ONPRINT", oBrkEnd,/*Titulo*/,cPicture,;
					{ || RZValorCTB(nTotGerCrd  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,,,lPlanilha) },.F.,.F.,.F.,oSection2)
	Else
		oTotGerDeb 	:= TRFunction():New( oSection2:Cell("CLANCDEB")	, ,"ONPRINT", oBrkEnd,/*Titulo*/,cPicture,;
					{ || PADL(RZValorCTB(nTotGerDeb  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,,,lPlanilha),TAM_VALOR) },.F.,.F.,.F.,oSection2)
		oTotGerCred	:= TRFunction():New( oSection2:Cell("CLANCCRD")	, ,"ONPRINT", oBrkEnd,/*Titulo*/,cPicture,;
					{ || PADL(RZValorCTB(nTotGerCrd  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,,,lPlanilha),TAM_VALOR) },.F.,.F.,.F.,oSection2)
	EndIf

EndIf



//����������������������������������������������Ŀ
//�Impressao do Saldo Anterior do Centro de Custo�
//������������������������������������������������
oSection1_1:Cell("DESCRICAO"):SetBlock( {|| xConta } )
oSection1_1:Cell("SALDOANT"):SetBlock( {|| STR0033 + AsString(RZValorCTB(aSaldoAnt[6],,,TAM_VALOR,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.,,,lPlanilha)) } )//"SALDO ANTERIOR: "


oSection1_1:Cell("DESCRICAO"):HideHeader()
oSection1_1:Cell("SALDOANT"):HideHeader()

//Se tiver parametrizado com Plano Gerencial, exibe a mensagem que o Plano Gerencial
//nao esta disponivel e sai da rotina.

if MV_PAR31 <> 1 // N�o salta linha entre contas
	oSection1:setLinesBefore(0)
	oSection1_1:setLinesBefore(0)
	oSection2:setLinesBefore(0)
endif

If lImpLivro
	If cArqTmp->(EoF())
		// Atencao ### "Nao existem dados para os par�metros especificados."
		Aviso(STR0047,STR0048,{"Ok"})
		Return
	Else
		oReport:IncMeter()
		While lImpLivro .And. cArqTmp->(!Eof())

		nQtdReg ++ // Incrementa a cada registro para capturar o total de impressos
			//�������������������������������Ŀ
			//�INICIO DA 1a SECAO             �
			//���������������������������������
		    If oReport:Cancel() .Or. lCancel
				oReport:CancelPrint()
		    	Exit
		    EndIf
			nIncMeter := nIncMeter + 1
			If lSldAntCC
				aSaldo    := SaldTotCT3(cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
				aSaldoAnt := SaldTotCT3(cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
			ElseIf lSldAntIt
				aSaldo    := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
				aSaldoAnt := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
			ElseIf lSldAntCv
				aSaldo    := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
				aSaldoAnt := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
			Else
				If lProcSld  // se existe parametro MV_CTBRAZD com .t. e conseguiu criar procedure
					aRet   := {}
					aRet   := TcSpExec(cTmpProc, cFilAnt, "CQ1",cArqTmp->CONTA," "," ", " ",cSaldo,cMoeda, Dtos(cArqTmp->DATAL))
					If Empty(aRet)
						aSaldo 		:= SaldoCT7Fil(cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,,,,aSelFil,,lTodasFil)
					Else
						aSaldo    := { aRet[1], aRet[2], aRet[3], aRet[4], aRet[5], aRet[6], aRet[7],aRet[8]}
					EndIf

					aRet   := {}
					aRet   := TcSpExec(cTmpProc, cFilAnt, "CQ1",cArqTmp->CONTA," "," ", " ",cSaldo,cMoeda, Dtos(dDataIni))
					If Empty(aRet)
						aSaldoAnt 		:= SaldoCT7Fil(cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,,,,aSelFil,,lTodasFil)
					Else
						aSaldoAnt    := { aRet[1], aRet[2], aRet[3], aRet[4], aRet[5], aRet[6], aRet[7],aRet[8]}
					EndIf
				Else
					aSaldo 	:= SaldoCT7Fil(cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,,,,aSelFil,,lTodasFil)
					aSaldoAnt	:= SaldoCT7Fil(cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,"CTBR400",,,aSelFil,,lTodasFil)
				EndIf
			EndIf

			If f180Fil(lNoMov,aSaldo,dDataIni,dDataFim)
				dbSkip()
				Loop
			EndIf

			// Conta Sintetica
			cContaSint := Ctr400Sint(cArqTmp->CONTA,@cDescSint,cMoeda,@cDescConta,@cCodRes,cMoedaDesc)
			cNormal := CT1->CT1_NORMAL

 			oSection1:Cell("DESCCC"):SetBlock( { || " - " + cDescSint } )
			oSection1:Cell("DESCCC"):SetSize(LEN(cDescSint)+3)
			If mv_par11 == 3
				oSection1:Cell("CONTA" ):SetBlock( { || EntidadeCTB(CT1->CT1_CODIMP,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.) } )
			Else
				oSection1:Cell("CONTA" ):SetBlock( { || EntidadeCTB(cContaSint,0,0,Len(cContaSint),.F.,cMascara1,cSepara1,,,,,.F.) } )
			Endif

			//AJUSTAR A PICTURE PARA ELIMINAR PONTOS E VIRGULAS 
			If !Empty(cPicture) .And. AT(",",cPicture) > 0 .And. Len(AllTrim(Str(nSldTransp))) > TAM_VALOR-2
				cPicture := aSetOfBook[4]
			EndIf

			oSection3:Cell("CTRANSP"):SetBlock( { || Iif(lDeTransp,  STR0091, STR0090)})
			oSection3:Cell("CSLDATU"):SetBlock( { || RZValorCTB(nSldTransp,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cNormal,,,,cTipoSinal,,lPrintZero,.F.,,,lPlanilha) })

			//�������������������������������Ŀ
			//�INICIO DA IMPRESSAO DA 1A SECAO�
			//���������������������������������
	  	 	oSection1:Init()
	     	oSection1:PrintLine()
		    oSection1:Finish()

			xConta := STR0016 //"CONTA - "

			If mv_par11 == 1							// Imprime Cod Normal
				xConta += EntidadeCTB(cArqTmp->CONTA,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.)
			Else
				dbSelectArea("CT1")
				dbSetOrder(1)
				MsSeek(xFilial("CT1")+cArqTMP->CONTA,.F.)
				If mv_par11 == 3						// Imprime Codigo de Impressao
					xConta += EntidadeCTB(CT1->CT1_CODIMP,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.)
				Else										// Caso contr�rio usa codigo reduzido
					xConta += EntidadeCTB(CT1->CT1_RES,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.)
				EndIf

				cDescConta := &("CT1->CT1_DESC" + cMoedaDesc )
			Endif

			xConta := Alltrim(xConta) 

			If nTipoRel == 3 // Resumido
				xConta +=  " - " + Left(cDescConta,30)
			Else
				xConta +=  " - " + Left(cDescConta,40)
			Endif
			xConta := Alltrim(xConta)

			oSection1_1:Init()
	     	oSection1_1:PrintLine()
		    oSection1_1:Finish()

			nSaldoAtu := aSaldoAnt[6]
			//���������������Ŀ
			//�FIM DA 1a SECAO�
			//�����������������


			//������������������Ŀ
			//�INICIO DA 2a SECAO�
			//��������������������
			dbSelectArea("cArqTmp")
			cContaAnt:= cArqTmp->CONTA
			dDataAnt	:= CTOD("  /  /  ")
			oSection2:Init()

			Do While cArqTmp->(!Eof() .And. CONTA == cContaAnt )

				If oReport:Cancel()
					oReport:CancelPrint()
					Exit
				EndIf

				If dDataAnt <> cArqTmp->DATAL

					If mv_par08 == 3
						If oReport:nDevice == 4 .And. !__lBlind	//se n�o chamado via robo e se for formato tabela
							oSection2:Cell("CONTA"):SetBlock( { || cContaAnt } )
						Endif
						If ( cArqTmp->LANCDEB <> 0 .Or. cArqTmp->LANCCRD <> 0 )
							oSection2:Cell("DATAL"):SetBlock( { || dDataAnt } )
						Endif
					Else
						//Caso a linha do pr�ximo registro seja maior/igual que o n�mero m�ximo de linhas e n�o saltar p�gina
						//Chamada a fun��o CTR400Maxl para quebrar a p�gina e assim continar a impress�o na pr�xima p�gina		
						If nLinha + 1 >= nMaxLin  .AND. !lSalto
						CTR400Maxl(@nMaxLin,.T.,.F.)
						Endif
						oSection4:Init()
						oSection4:PrintLine()
						oSection4:Finish()
					Endif

					dDataAnt := cArqTmp->DATAL
				EndIf

				If mv_par08 < 3 //Se for relatorio analitico ou resumido
					
					nSaldoAtu 	:= Round(nSaldoAtu - cArqTmp->LANCDEB + cArqTmp->LANCCRD, nDecimais)
					nTotDeb		+= cArqTmp->LANCDEB
					nTotCrd		+= cArqTmp->LANCCRD
					nTotGerDeb	+= cArqTmp->LANCDEB
					nTotGerCrd	+= cArqTmp->LANCCRD

					dbSelectArea("cArqTmp")

					If mv_par11 == 1 // Impr Cod (Normal/Reduzida/Cod.Impress)
						oSection2:Cell("XPARTIDA"):SetBlock( { || EntidadeCTB(cArqTmp->XPARTIDA,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.) } )
					ElseIf mv_par11 == 3
						oSection2:Cell("XPARTIDA"):SetBlock( { || EntidadeCTB(CT1->CT1_CODIMP,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.) } )
					Else
						dbSelectArea("CT1")
						dbSetOrder(1)
						MsSeek(xFilial("CT1")+cArqTmp->XPARTIDA,.F.)
						oSection2:Cell("XPARTIDA"):SetBlock( { || EntidadeCTB(CT1->CT1_RES,0,0,TAM_CONTA,.F.,cMascara1,cSepara1,,,,,.F.) } )
					Endif

					oSection2:Cell("Filial"):SetBlock( { || cArqTmp->FILORI } )

					If lCusto
						If mv_par25 == 1 //Imprime Cod. Centro de Custo Normal
							oSection2:Cell("CCUSTO"):SetBlock( { || EntidadeCTB(cArqTmp->CCUSTO,0,0,25,.F.,cMascara2,cSepara2,,,,,.F.) } )
						Else
							dbSelectArea("CTT")
							dbSetOrder(1)
							dbSeek(xFilial("CTT")+cArqTmp->CCUSTO)
							cResCC := CTT->CTT_RES
							oSection2:Cell("CCUSTO"):SetBlock( { || EntidadeCTB(cResCC,0,0,25,.F.,cMascara2,cSepara2,,,,,.F.) } )
							dbSelectArea("cArqTmp")
						Endif
					Endif
					If lItem 						//Se imprime item
						If mv_par26 == 1 //Imprime Codigo Normal Item Contabl
							oSection2:Cell("ITEM"):SetBlock( { || EntidadeCTB(cArqTmp->ITEM,0,0,25,.F.,cMascara3,cSepara3,,,,,.F.) } )
						Else
							dbSelectArea("CTD")
							dbSetOrder(1)
							dbSeek(xFilial("CTD")+cArqTmp->ITEM)
							cResItem := CTD->CTD_RES
							oSection2:Cell("ITEM"):SetBlock( { || EntidadeCTB(cResItem,0,0,25,.F.,cMascara3,cSepara3,,,,,.F.) } )
							dbSelectArea("cArqTmp")
						Endif
					Endif
					If lCLVL //Se imprime classe de valor
						If mv_par27 == 1 //Imprime Cod. Normal Classe de Valor
							oSection2:Cell("CLVL"):SetBlock( { || EntidadeCTB(cArqTmp->CLVL,0,0,25,.F.,cMascara4,cSepara4,,,,,.F.) } )
						Else
							dbSelectArea("CTH")
							dbSetOrder(1)
							dbSeek(xFilial("CTH")+cArqTmp->CLVL)
							cResClVl := CTH->CTH_RES
							oSection2:Cell("CLVL"):SetBlock( { || EntidadeCTB(cResClVl,0,0,25,.F.,cMascara4,cSepara4,,,,,.F.) } )
							dbSelectArea("cArqTmp")
						Endif
					Endif
					
					//AJUSTAR A PICTURE PARA ELIMINAR PONTOS E VIRGULAS 
					If !Empty(cPicture) .And. AT(",",cPicture) > 0 .And. (Len(AllTrim(Str(cArqTmp->LANCDEB))) > TAM_VALOR .OR. Len(AllTrim(Str(cArqTmp->LANCCRD))) > TAM_VALOR)
						cPicture := aSetOfBook[4]
					EndIf	

					If !Empty(cPicture) .And. AT(",",cPicture) > 0 .And. Len(AllTrim(Str(nSaldoAtu))) > TAM_VALOR-2 
						cPicture := aSetOfBook[4]
					EndIf
			
					oSection2:Cell("CLANCDEB" ):SetBlock( { || RZValorCTB(cArqTmp->LANCDEB,,,TAM_VALOR  ,nDecimais,.F.,cPicture,"1"    ,,,,cTipoSinal,,lPrintZero,.F.,,,lPlanilha) })// Debito
				  	oSection2:Cell("CLANCCRD" ):SetBlock( { || RZValorCTB(cArqTmp->LANCCRD,,,TAM_VALOR  ,nDecimais,.F.,cPicture,"2"    ,,,,cTipoSinal,,lPrintZero,.F.,,,lPlanilha) })// Credito
					oSection2:Cell("CTPSLDATU"):SetBlock( { || RZValorCTB(nSaldoAtu		,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cNormal,,,,cTipoSinal,,lPrintZero,.F.,,,lPlanilha) })					

					nSldTransp := nSaldoAtu // Valor a Transportar - 1
			     	oSection2:PrintLine()

					/* Se par�metro for T e existir procedure */
		        	lAvancaReg := .T.

				 	//Procura complemento de historico e imprime
			  		If ( !lCtbRazBD )
						ImpCompl( oSection2, @lAvancaReg ) // oReport)
		       		EndIf

		        	If lAvancaReg
					cArqTmp->(dbSkip())
					EndIf

				Else      // -- Se for sintetico

					dbSelectArea("cArqTmp")

					While dDataAnt == cArqTmp->DATAL .And. cContaAnt == cArqTmp->CONTA
						nVlrDeb	+= cArqTmp->LANCDEB
						nVlrCrd	+= cArqTmp->LANCCRD
						nTotGerDeb	+= cArqTmp->LANCDEB
						nTotGerCrd	+= cArqTmp->LANCCRD
						dbSkip()
					EndDo
					
					nSaldoAtu	:= nSaldoAtu - nVlrDeb + nVlrCrd
					
					//AJUSTAR A PICTURE PARA ELIMINAR PONTOS E VIRGULAS 
					If !Empty(cPicture) .And.  AT(",",cPicture) > 0 .And. (Len(AllTrim(Str(nVlrDeb))) > TAM_VALOR .OR. Len(AllTrim(Str(nVlrCrd))) > TAM_VALOR)
						cPicture := aSetOfBook[4]
					EndIf 	

					If !Empty(cPicture) .And. AT(",",cPicture) > 0 .And. Len(AllTrim(Str(nSaldoAtu))) > TAM_VALOR-2
						cPicture := aSetOfBook[4]
					EndIf

				  	oSection2:Cell("CLANCDEB" ):SetBlock( { || RZValorCTB(nVlrDeb  ,,,TAM_VALOR,nDecimais  ,.F.,cPicture,"1"    ,,,,cTipoSinal,,lPrintZero,.F.,,,lPlanilha) })// Debito
				  	oSection2:Cell("CLANCCRD" ):SetBlock( { || RZValorCTB(nVlrCrd  ,,,TAM_VALOR,nDecimais  ,.F.,cPicture,"2"    ,,,,cTipoSinal,,lPrintZero,.F.,,,lPlanilha) })// Credito
					oSection2:Cell("CTPSLDATU"):SetBlock( { || RZValorCTB(nSaldoAtu,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cNormal,,,,cTipoSinal,,lPrintZero,.F.,,,lPlanilha) })// Sinal do Saldo Atual => Consulta Razao

					//Imprime Section(1) - resumida.
			     	oSection2:PrintLine()

					nSldTransp := nSaldoAtu // Valor a Transportar

					nTotDeb		+= nVlrDeb
					nTotCrd		+= nVlrCrd
					nVlrDeb	:= 0
					nVlrCrd	:= 0
				Endif // lAnalitico

			EndDo //cArqTmp->(!Eof()) .And. cArqTmp->CONTA == cContaAnt

 			oSection2:Finish()

           	nSldTransp  := 0
			nSaldoAtu   := 0
			nTotDeb	    := 0
			nTotCrd	    := 0

			//���������������Ŀ
			//�FIM DA 2a SECAO�
			//�����������������
			If nIncMeter >= 3000
				oReport:IncMeter()
				nIncMeter := 0
			EndIf
		EndDo //lImpLivro .And. !cArqTmp->(Eof())

		If lImpLivro .And. mv_par28 == 1 .And. lImpTermos .And. oReport:nDevice != 4  	//Imprime total Geral  //diferente de excel
			//Tratativa para que o total geral seja impresso
			//antes dos termos de abertura e encerramento.
			oReport:Finish()

			oBrkEnd:SetTitle("")
			oSection2:Cell("CLANCDEB"):SetSize(0)
			oSection2:Cell("CLANCDEB"):Disable()

			oSection2:Cell("CLANCCRD"):SetSize(0)
			oSection2:Cell("CLANCCRD"):Disable()

			oSection2:Cell("CTPSLDATU"):SetSize(0)
			oSection2:Cell("CTPSLDATU"):Disable()
		EndIf
	EndIf //!(cArqTmp->(RecCount()) == 0 .And. !Empty(aSetOfBook[5]))
EndIf // lImpLivro

//���������������������Ŀ
//�Impressao dos Termos �
//�����������������������
If lImpTermos 							// Impressao dos Termos

	//Inibido cabe�alho na impressao dos termos
	oReport:HideHeader()
	oSection2:Hide()
	oSection2:SetHeaderPage(.F.) // Desabilita a impressao

	cArqAbert:=GetNewPar("MV_LRAZABE","")
	cArqEncer:=GetNewPar("MV_LRAZENC","")

    If Empty(cArqAbert)
		ApMsgAlert(	STR0027 +; //"Devem ser criados os parametros MV_LRAZABE e MV_LRAZENC. "
					STR0028) //"Utilize como base o parametro MV_LDIARAB."
	Endif
Endif

If lImpTermos .And. ! Empty(cArqAbert)
	dbSelectArea("SM0")
	aVariaveis:={}

	For nCont:=1 to FCount()
		If FieldName(nCont)=="M0_CGC"
			AADD(aVariaveis,{FieldName(nCont),Transform(FieldGet(nCont),"@R 99.999.999/9999-99")})
		Else
            If FieldName(nCont)=="M0_NOME"
                Loop
            EndIf
			AADD(aVariaveis,{FieldName(nCont),FieldGet(nCont)})
		Endif
	Next

	dbSelectArea("SX1")
	dbSeek( padr( "CTR400" , Len( X1_GRUPO ) , ' ' ) + "01" )
	While ! Eof() .And. SX1->X1_GRUPO  == padr( "CTR400" , Len( X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(X1_VAR01)),&(X1_VAR01)})
		dbSkip()
	End

	dbSelectArea( "CVB" )
	CVB->(dbSeek( xFilial( "CVB" ) ))
	For nCont:=1 to FCount()
		If FieldName(nCont)=="CVB_CGC"
			AADD(aVariaveis,{FieldName(nCont),Transform(FieldGet(nCont),"@R 99.999.999/9999-99")})
		ElseIf FieldName(nCont)=="CVB_CPF"
			AADD(aVariaveis,{FieldName(nCont),Transform(FieldGet(nCont),"@R 999.999.999-99")})
		Else
			AADD(aVariaveis,{FieldName(nCont),FieldGet(nCont)})
		Endif
	Next

	AADD(aVariaveis,{"M_DIA",StrZero(Day(dDataBase),2)})
	AADD(aVariaveis,{"M_MES",MesExtenso()})
	AADD(aVariaveis,{"M_ANO",StrZero(Year(dDataBase),4)})

	If !File(cArqAbert)
		aSavSet:=__SetSets()
		cArqAbert:=CFGX024(,"Raz�o") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If !File(cArqEncer)
		aSavSet:=__SetSets()
		cArqEncer:=CFGX024(,"Raz�o") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqAbert#NIL
		oReport:EndPage()
		ImpTerm2(cArqAbert,aVariaveis,,,,oReport)
	Endif
	If cArqEncer#NIL
		oReport:EndPage()
		ImpTerm2(cArqEncer,aVariaveis,,,,oReport)
	Endif
Endif

dbselectArea("CT2")
If !Empty(dbFilter())
	dbClearFilter()
Endif

//apaga arquivo temporario antes de voltar para menu
If Select("cArqTmp") > 0
	dbSelectArea("cArqTmp")
	dbCloseArea()
	dbselectArea("CT2")
	CtbTmpErase(cArqTmp)  //Comentar
EndIf

//Metrica - Qtd Registros
If FunName() <> "CTBC400" .And. __lMetric
	//Chamar metrica passando nQtdReg e sem nStart pra capturar apenas a qtd de registros
	CTB400Metrics("02" /*cEvent*/, /* nStart */, "001" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/, nQtdReg /* nQtdReg */)
	CTB400Metrics("01" /*cEvent*/, nStart, "001" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/)
	nStart := 0
EndIf
// lCtbRazBD := NIL // nao igualar a nil aqui pois precisa dessa variavel para deletar as procedures

Return

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTR400MaxL�Autor  �                    � Data �  25/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �														      ���
���          �						                                      ���
�������������������������������������������������������������������������͹��
���Uso       � CTBR400                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function CTR400MaxL(nMaxLin, lQuebra, lTotConta)
Local oSection1 	:= oReport:Section(1)
Local oSection2		:= oReport:Section(2)
Local oSection1_1	:= oReport:Section(3)
Local oSection3		:= oReport:Section(4)
Local oSection4		:= oReport:Section(5)
Local lSalLin 		:= IIf(mv_par31==1,.T.,.F.)//"Salta linha entre contas?"
Local nLenHist		:= 0



If lQuebra
	nLinha := 6
Endif

If lTotConta
	nLinha += 3
	nSldTransp := 0
Endif

//---------------------------------------------------------
//Conta
//---------------------------------------------------------
If oSection1:Printing()
	If nLinha > 7
		nLinha += 3 // Caso n�o seja inicio de p�gina, soma a quantidade referente ao cabe�alho
	Else
		nLinha += 1
	EndIf
Endif

//---------------------------------------------------------
//Totalizador da Conta
//---------------------------------------------------------
If oSection1_1:Printing()
	If lSalLin
		nLinha += 2
	Else
		nLinha += 1
	Endif
EndIf

//---------------------------------------------------------
// Custo e Data
//---------------------------------------------------------
If oSection2:Printing() .And. ( oSection4 != Nil .And. !oSection4:Printing() ) .And. !oSection1:Printing()

	nLenHist := 40//oSection2:Cell("HISTORICO"):GetSize()

	If ( Len(Alltrim((_oCTBR400:GetAlias())->HISTORICO)) > nLenHist .And. lCtbRazBD)
		nLinha += 1
		nLinha += Int(Len(Alltrim((_oCTBR400:GetAlias())->HISTORICO)) / nLenHist )
	Else
		nLinha += 1
	EndIf

Endif

//---------------------------------------------------------
// Data
//---------------------------------------------------------

nLinha += Iif( ( oSection4 != Nil .And. oSection4:Printing() ), 2, 0 )

//---------------------------------------------------------
// Totalizador - A Transportar / De Transporte
//---------------------------------------------------------
If ( (nLinha > nMaxLin .AND. oReport:nDevice != 4) ) // N�o realizar a quebra de p�gina quando for em excel

	

	If nSldTransp != 0

		lDeTransp   := .F.
		oSection3:Init()
		oSection3:PrintLine()	//A Transportar
		
			oReport:EndPage()
		
		nLinha := 7
		lDeTransp   := .T.

		// Exibir conta / descricao em todo inicio de pagina
		oSection1:Init()
		oSection1:PrintLine()
		oSection1:Finish()
		oSection1_1:Init()
		oSection1_1:PrintLine()
		oSection1_1:Finish()
		oSection3:PrintLine()  // De Transporte
		oReport:SkipLine()
		oSection3:Finish()
		lDeTransp   := .F.
    Else
    	oReport:EndPage()
    	nLinha := 6
    Endif
Endif

Return Nil


/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpCompl  �Autor  �Cicero J. Silva     � Data �  27/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a descricao, da conta contabil, item, centro de     ���
���          �custo ou classe valor                                       ���
�������������������������������������������������������������������������͹��
���Uso       � CTBR390                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function ImpCompl(oSection2,lAvancaReg)
Local lNumAsto     := Iif(cPaisLoc == "PAR" .And. CT2->(FieldPos("CT2_NACSEQ")) > 0, .T., .F.)
local cFilTmp
Local cLote
Local cSubLote
Local cDoc
Local cSeqLan
Local cEmpOri
Local cFilOri
Local dData
Local aBindHist 
Static _oQryImpH

Default lAvancaReg := .T.
	If nTipoRel == 3 // relatorio sintetico
  		oSection2:Cell("DATAL"		):Hide()
	EndIf
	oSection2:Cell("DOCUMENTO"	):Hide()
 	oSection2:Cell("XPARTIDA"	):Hide()
	oSection2:Cell("CCUSTO"		):Hide()
	oSection2:Cell("ITEM"		):Hide()
	oSection2:Cell("CLVL"		):Hide()
	oSection2:Cell("CLANCDEB"	):Hide()
	oSection2:Cell("CLANCCRD"	):Hide()
	oSection2:Cell("CTPSLDATU"	):Hide()
	oSection2:Cell("FILIAL"		):Hide()

	lCtbRazBD := CTB400RAZB()

	If !lCtbRazBD
		// Procura pelo complemento de historico	
		If _oQryImpH == NIL
			_oQryImpH := "SELECT CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,"
			_oQryImpH += " CT2_SEQLAN,CT2_EMPORI,CT2_FILORI,CT2_MOEDLC,CT2_SEQHIS, "
			_oQryImpH += " CT2_HIST FROM "
			_oQryImpH += RetSqlName("CT2")
			_oQryImpH += " WHERE CT2_FILIAL = ?"
			_oQryImpH += " AND CT2_DATA     = ?"
			_oQryImpH += " AND CT2_LOTE     = ?"
			_oQryImpH += " AND CT2_SBLOTE   = ?"
			_oQryImpH += " AND CT2_DOC      = ?"
			_oQryImpH += " AND CT2_SEQLAN   = ?"
			_oQryImpH += " AND CT2_EMPORI   = ?"
			_oQryImpH += " AND CT2_FILORI   = ?"
			_oQryImpH += " AND CT2_MOEDLC   = ?"
			_oQryImpH += " AND CT2_DC       = ?"
			_oQryImpH += " AND D_E_L_E_T_   = ?"
			_oQryImpH += " ORDER BY CT2_SEQHIS"
			_oQryImpH := ChangeQuery(_oQryImpH) 
		EndIf 
		aBindHist := {}
		AADD(aBindHist,cArqTMP->FILIAL)
		AADD(aBindHist,DTOS(cArqTMP->DATAL))
		AADD(aBindHist,cArqTMP->LOTE)
		AADD(aBindHist,cArqTMP->SUBLOTE)
		AADD(aBindHist,cArqTMP->DOC)
		AADD(aBindHist,cArqTMP->SEQLAN)
		AADD(aBindHist,cArqTMP->EMPORI)
		AADD(aBindHist,cArqTMP->FILORI)
		AADD(aBindHist,'01')
		AADD(aBindHist,'4')
		AADD(aBindHist,Space(1))
		dbUseArea(.T.,"TOPCONN",TcGenQry2(,,_oQryImpH,aBindHist),'QCT2IMPH')
		aSize(aBindHist,0)
		aBindHist := nil 
		If QCT2IMPH->(!Eof())
			If nTipoRel == 3 // relatorio sintetico
				oSection2:Cell("DATAL"):Hide()
			EndIf

			While !QCT2IMPH->(Eof())

				oSection2:Cell("HISTORICO"):SetBlock({|| QCT2IMPH->CT2_HIST } )
				oSection2:Printline()

				QCT2IMPH->(dbSkip())
			EndDo
		EndIf
		QCT2IMPH->(dbCloseArea())

		oSection2:Cell("HISTORICO"):SetBlock( { || cArqTmp->HISTORICO } )

		If lNumAsto .and. nTipoRel == 1
			oSection2:Cell("NASIENTO"):SetBlock( { || cArqTmp->NASIENTO } )
		EndIf
	Else
		// Procura pelo complemento de historico
		nRecTmp  := cArqTmp->( Recno() )
		cFilTmp  := cArqTMP->FILIAL
		cLote    := cArqTMP->LOTE
		cSubLote := cArqTMP->SUBLOTE
		cDoc     := cArqTmp->DOC
		cSeqLan  := cArqTmp->SEQLAN
		cEmpOri  := cArqTmp->EMPORI
		cFilOri  := cArqTmp->FILORI
		dData    := cArqTmp->DATAL
		//AVANCA REGISTRO
		cArqTmp->( dbSkip() )
		//VERIFICA SE PROXIMO REGISTRO EH CONTINUACAO DE HISTORICO
		If cArqTmp->TIPO == "4"			//// TRATAMENTO PARA IMPRESSAO DAS CONTINUACOES DE HISTORICO
			While 	cArqTmp->(! Eof() .And.;
					cArqTMP->FILIAL 	== cFilTmp .And.;
					cArqTMP->LOTE 		== cLote .And.;
					cArqTMP->SUBLOTE 	== cSubLote .And.;
					cArqTmp->DOC 		== cDoc .And.;
					cArqTmp->SEQLAN 	== cSeqLan .And.;
					cArqTmp->EMPORI 	== cEmpOri .And.;
					cArqTmp->FILORI 	== cFilOri .And.;
					cArqTmp->TIPO 	== "4" .And.;
					DTOS(cArqTmp->DATAL)== DTOS(dData) )

		   		oSection2:Cell("HISTORICO"):SetBlock({|| cArqTmp->HISTORICO } )
				oSection2:Printline()

				cArqTmp->( dbSkip() )
			EndDo
		EndIf

		//somente seta variavel false para nao saltar no laco principal do relatorio
		lAvancaReg := .F.

	EndIf
	If nTipoRel == 3 // relatorio sintetico
		oSection2:Cell("DATAL"		):Show()					//-- JRJ 20170830-A
	EndIf
	oSection2:Cell("DOCUMENTO"	):Show()
  	oSection2:Cell("XPARTIDA"	):Show()
	oSection2:Cell("CCUSTO"		):Show()
	oSection2:Cell("ITEM"		):Show()
	oSection2:Cell("CLVL"		):Show()
	oSection2:Cell("CLANCDEB"	):Show()
	oSection2:Cell("CLANCCRD"	):Show()
	oSection2:Cell("CTPSLDATU"	):Show()
	oSection2:Cell("FILIAL"		):Show()

	dbSelectArea("cArqTmp")

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �f180Fil   �Autor  �Cicero J. Silva     � Data �  24/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTBR400                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function f180Fil(lNoMov,aSaldo,dDataIni,dDataFim)

Local lDeixa	:= .F.

 	If !lNoMov //Se imprime conta sem movimento
		If aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0
			lDeixa	:= .T.
		Endif
	Endif

	If lNoMov .And. aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0
		If CtbExDtFim("CT1")
			dbSelectArea("CT1")
			dbSetOrder(1)
			If MsSeek(xFilial()+cArqTmp->CONTA)
				If !CtbVlDtFim("CT1",dDataIni)
					lDeixa	:= .T.
	            EndIf

	            If !CtbVlDtIni("CT1",dDataFim)
					lDeixa	:= .T.
	            EndIf

		    EndIf
		EndIf
	EndIf

	dbSelectArea("cArqTmp")

Return (lDeixa)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBR400R3� Autor � Pilar S. Albaladejo   � Data � 05.02.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emiss�o do Raz�o                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBR400R3()                                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR400R3(	cContaIni, cContaFim, dDataIni, dDataFim, cMoeda, cSaldos,;
					cBook, lCusto, cCustoIni, cCustoFim, lItem, cItemIni, cItemFim,;
					lClVl, cClvlIni, cClvlFim,lSaltLin,cMoedaDesc,aSelFil )

Local aCtbMoeda	:= {}
Local WnRel			:= "CTBR400"
Local cDesc1		:= STR0001	//"Este programa ir� imprimir o Raz�o Contabil,"
Local cDesc2		:= STR0002	// "de acordo com os parametros solicitados pelo"
Local cDesc3		:= STR0003	// "usuario."
Local cString		:= "CT2"
Local titulo		:= STR0006 	//"Emissao do Razao Contabil"
Local lAnalitico 	:= .T.
Local nTamLinha	:= 220
Local nTamConta		:= 22
Local cSepara1		:= ""

DEFAULT lCusto		:= .F.
DEFAULT lItem		:= .F.
DEFAULT lCLVL		:= .F.
DEFAULT lSaltLin	:= .T.
DEFAULT cMoedaDesc  := cMoeda
DEFAULT aSelFil 		:= {}

Private aReturn	:= { STR0004, 1,STR0005, 2, 2, 1, "", 1 }  //"Zebrado"###"Administracao"
Private nomeprog	:= "CTBR400"
Private aLinha		:= {}
Private nLastKey	:= 0
Private cPerg		:= "CTR400"
Private Tamanho 	:= "G"
Private lSalLin		:= .T.

//Iniciar telemetria - Tempo m�dio
If FunName() <> "CTBC400" .And. __lMetric
	nStart := Seconds()
EndIf
lAnalitico	:= ( mv_par08 == 1 )
nTamLinha	:= If( lAnalitico, 220, 132)

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books -> Conf. da Mascara / Valores   �
//����������������������������������������������������������������
aSetOfBook := CTBSetOf(mv_par07)

//�������������������������������Ŀ
//�Carrega as informacoes da moeda�
//���������������������������������
aCtbMoeda  	:= CtbMoeda(MV_PAR05)

// Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara1 := SuperGetMv("MV_MASCARA")
Else
	cMascara1	:= RetMasCtb(aSetOfBook[2],@cSepara1)
	//A mascara sera considerada no tamanho da conta somente com a mascara da configuracao de livros.
	//Quando nao tiver configuracao de livros, o relatorio podera ser impresso em formato retrato e, caso
	//nao haja espaco para a impressao do codigo da conta (contra-partida), esse codigo sera truncado.
	nTamConta	:= nTamConta+Len(ALLTRIM(cSepara1))
EndIf

If (lAnalitico .And. (!lCusto .And. !lItem .And. !lCLVL) .And. nTamConta <= 22) .Or. ! lAnalitico
	Tamanho := "M"
	nTamLinha := 132
EndIf

wnrel := SetPrint(cString,wnrel,,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey = 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| CTR400Imp(@lEnd,wnRel,cString,aSetOfBook,lCusto,lItem,lCLVL,;
	   	lAnalitico,Titulo,nTamlinha,aCtbMoeda, nTamConta,aSelFil)})
Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CTR400Imp � Autor � Pilar S. Albaladejo   � Data � 05/02/01 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o � Impressao do Razao                                         ���
��������������������������������������������������������������������������Ĵ��
��� Sintaxe   �Ctr400Imp(lEnd,wnRel,cString,aSetOfBook,lCusto,lItem,;      ���
���           �          lCLVL,Titulo,nTamLinha,aCtbMoeda)                 ���
��������������������������������������������������������������������������Ĵ��
��� Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � lEnd       - A�ao do Codeblock                             ���
���           � wnRel      - Nome do Relatorio                             ���
���           � cString    - Mensagem                                      ���
���           � aSetOfBook - Array de configuracao set of book             ���
���           � lCusto     - Imprime Centro de Custo?                      ���
���           � lItem      - Imprime Item Contabil?                        ���
���           � lCLVL      - Imprime Classe de Valor?                      ���
���           � Titulo     - Titulo do Relatorio                           ���
���           � nTamLinha  - Tamanho da linha a ser impressa               ���
���           � aCtbMoeda  - Moeda                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function CTR400Imp(lEnd,WnRel,cString,aSetOfBook,lCusto,lItem,lCLVL,lAnalitico,Titulo,nTamlinha,aCtbMoeda,nTamConta,aSelFil)

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local aSaldo		:= {}
Local aSaldoAnt		:= {}
Local aColunas

Local cArqTmp
Local cSayCusto		:= CtbSayApro("CTT")
Local cSayItem		:= CtbSayApro("CTD")
Local cSayClVl		:= CtbSayApro("CTH")

Local cDescMoeda
Local cMascara1
Local cMascara2
Local cMascara3
Local cMascara4
Local cPicture
Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""
Local cSaldo		:= mv_par06
Local cContaIni	:= mv_par01
Local cContaFIm	:= mv_par02
Local cCustoIni	:= mv_par13
Local cCustoFim	:= mv_par14
Local cItemIni		:= mv_par16
Local cItemFim		:= mv_par17
Local cCLVLIni		:= mv_par19
Local cCLVLFim		:= mv_par20
Local cContaAnt	:= ""
Local cDescConta	:= ""
Local cCodRes		:= ""
Local cResCC		:= ""
Local cResItem		:= ""
Local cResCLVL		:= ""
Local cDescSint	:= ""
Local cMoeda		:= mv_par05
Local cContaSint	:= ""
Local cNormal 		:= ""

Local dDataAnt		:= CTOD("  /  /  ")
Local dDataIni		:= mv_par03
Local dDataFim		:= mv_par04

Local lNoMov		:= Iif(mv_par09==1,.T.,.F.)
Local lSldAnt		:= Iif(mv_par09==3,.T.,.F.)
Local lJunta		:= Iif(mv_par10==1,.T.,.F.)
Local lSalto		:= Iif(mv_par21==1,.T.,.F.)
Local lFirst		:= .T.
Local lImpLivro		:= .t.
Local lImpTermos	:= .f.
Local lPrintZero	:= Iif(mv_par30==1,.T.,.F.)

Local nDecimais     := Iif(DecimalCTB(aSetOfBook,mv_par05) = 0, SuperGetMv("MV_CENT"), DecimalCTB(aSetOfBook,mv_par05))
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotGerDeb	:= 0
Local nTotGerCrd	:= 0
Local nPagIni		:= mv_par22
Local nReinicia 	:= mv_par24
Local nPagFim		:= mv_par23
Local nVlrDeb		:= 0
Local nVlrCrd		:= 0
Local nCont			:= 0
Local lQbPg			:= .F.
Local LIMITE		:= If(TAMANHO=="G",220,If(TAMANHO=="M",132,80))
Local nInutLin		:= 1
Local nMaxLin   	:= mv_par32

Local nBloco		:= 0
Local nBlCount		:= 0

Local lSldAntCC		:= Iif(mv_par33 == 2, .T.,.F.)
Local lSldAntIt  	:= Iif(mv_par33 == 3, .T.,.F.)
Local lSldAntCv  	:= Iif(mv_par33 == 4, .T.,.F.)
Local cMoedaDesc	:= iif( Empty( mv_par34 ) , cMoeda , mv_par34)

Local nQtdReg		:= 0
Local nStart		:= 0
//Limita��o de linhas para impress�o do relat�rio.
If aReturn[4] == 1 .And. nMaxLin > 75 //Retrato
	nMaxLin := 75
ElseIf aReturn[4] == 2 .And. nMaxLin > 58 //Paisagem
	nMaxLin := 58
EndIf

nTipoRel := mv_par08

lSalLin	:= If(mv_par31 ==1 ,.T.,.F.)
m_pag   := 1

CtbQbPg(.T.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

//��������������������������������������������������������������Ŀ
//� Impressao de Termo / Livro                                   �
//����������������������������������������������������������������
Do Case
	Case mv_par29==1 ; lImpLivro:=.t. ; lImpTermos:=.f.
	Case mv_par29==2 ; lImpLivro:=.t. ; lImpTermos:=.t.
	Case mv_par29==3 ; lImpLivro:=.f. ; lImpTermos:=.t.
EndCase

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80

cDescMoeda 	:= Alltrim(aCtbMoeda[2])

// Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara1 := SuperGetMv("MV_MASCARA")
Else
	cMascara1	:= RetMasCtb(aSetOfBook[2],@cSepara1)
EndIf

If lCusto .Or. lItem .Or. lCLVL
	// Mascara do Centro de Custo
	If Empty(aSetOfBook[6])
		cMascara2 := SuperGetMv("MV_MASCCUS")
	Else
		cMascara2	:= RetMasCtb(aSetOfBook[6],@cSepara2)
	EndIf

	// Mascara do Item Contabil
	If Empty(aSetOfBook[7])
		dbSelectArea("CTD")
		cMascara3 := SuperGetMv("MV_MASCCTD")
	Else
		cMascara3 := RetMasCtb(aSetOfBook[7],@cSepara3)
	EndIf

	// Mascara da Classe de Valor
	If Empty(aSetOfBook[8])
		dbSelectArea("CTH")
		cMascara4 := SuperGetMv("MV_MASCCTH")
	Else
		cMascara4 := RetMasCtb(aSetOfBook[8],@cSepara4)
	EndIf
EndIf

cPicture 	:= aSetOfBook[4]

//��������������������������������������������������������������������������Ŀ
//�Titulo do Relatorio                                                       �
//����������������������������������������������������������������������������
If Type("NewHead")== "U"
	IF nTipoRel == 1 //lAnalitico
		Titulo	:=	STR0007	//"RAZAO ANALITICO EM "
	ElseIf nTipoRel == 2 // Resumido
		Titulo	:=	STR0054	//"RAZAO RESUMIDO EM "
	Else  // Sintetico
		Titulo	:=	STR0008	//"RAZAO SINTETICO EM "
	EndIf
	Titulo += 	cDescMoeda + STR0009 + DTOC(dDataIni) +;	// "DE"
				STR0010 + DTOC(dDataFim) + CtbTitSaldo(mv_par06)	// "ATE"
Else
	Titulo := NewHead
EndIf

//��������������������������������������������������������������������������Ŀ
//�Resumido                                  						         �
//����������������������������������������������������������������������������
// DATA                         					                                DEBITO               CREDITO            SALDO ATUAL
// XX/XX/XXXX 			                                 		     99,999,999,999,999.99 99,999,999,999,999.99 99,999,999,999,999.99D
// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16         17        18        19        20       21        22
//��������������������������������������������������������������������������Ŀ
//�Cabe�alho Conta                                                           �
//����������������������������������������������������������������������������
// DATA
// LOTE/SUB/DOC/LINHA H I S T O R I C O                        C/PARTIDA                      DEBITO          CREDITO       SALDO ATUAL"
// XX/XX/XXXX
// XXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX 9999999999999.99 9999999999999.99 9999999999999.99D
// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16
//��������������������������������������������������������������������������Ŀ
//�Cabe�alho Conta + CCusto + Item + Classe de Valor								  �
//����������������������������������������������������������������������������
// DATA
// LOTE/SUB/DOC/LINHA  H I S T O R I C O                        C/PARTIDA                      CENTRO CUSTO         ITEM                 CLASSE DE VALOR                     DEBITO               CREDITO           SALDO ATUAL"
// XX/XX/XXXX
// XXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX 99,999,999,999,999.99 99,999,999,999,999.99 99,999,999,999,999.99D
// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16         17        18        19        20       21        22

#DEFINE 	COL_NUMERO 			1
#DEFINE 	COL_HISTORICO		2
#DEFINE 	COL_CONTRA_PARTIDA	3
#DEFINE 	COL_CENTRO_CUSTO 	4
#DEFINE 	COL_ITEM_CONTABIL 	5
#DEFINE 	COL_CLASSE_VALOR  	6
#DEFINE 	COL_VLR_DEBITO		7
#DEFINE 	COL_VLR_CREDITO		8
#DEFINE 	COL_VLR_SALDO  		9
#DEFINE 	TAMANHO_TM       	10
#DEFINE 	COL_VLR_TRANSPORTE  11

If mv_par11 == 3 						//// SE O PARAMETRO DO CODIGO ESTIVER PARA IMPRESSAO
	nTamConta := Len(CT1->CT1_CODIMP)	//// USA O TAMANHO DO CAMPO CODIGO DE IMPRESSAO
Endif

If lAnalitico .And. (lCusto .Or. lItem .Or. lCLVL)
	nTamConta := 25						// Tamanho disponivel no relatorio para imprimir
EndIf

If nTipoRel > 1  // Relatorio Sintetico
	aColunas := { 000, 019, 060,    ,    ,    , 84, 100, 115, 15, 097}
Else
	If cPaisLoc $ "CHI|ARG"
		If ((!lCusto .And. !lItem .And. !lCLVL) .And. nTamConta< 25)
			aColunas := { 000, 030, 060,    ,    ,    , 84, 100, 115, 15, 097}
		Else
			aColunas := { 000, 030, 060, 92, 113, 134, 156, 178, 198, 20 ,178 }
		Endif
	Else
		If ((!lCusto .And. !lItem .And. !lCLVL) .And. nTamConta< 25)
			aColunas := { 000, 019, 060,    ,    ,    , 84, 100, 115, 15, 097}
		Else
			aColunas := { 000, 019, 060, 085, 112, 138, 154, 176, 196, 20 ,176 }
		Endif
	EndIf
Endif

If nTipoRel == 1 // Relatorio Analitico
	Cabec1 := STR0019					   	// "DATA"
	Cabec2 := ""
	If (!lCusto .And. !lItem .And. !lCLVL)
		If nTamConta < 25
			Cabec2:= STR0031        	//LOTE/SUB/DOC/LINHA H I S T O R I C O                          C/PARTIDA                      DEBITO          CREDITO       SALDO ATUAL
		Else
			Cabec2 := STR0032			//LOTE/SUB/DOC/LINHA H I S T O R I C O                          C/PARTIDA                      													                                                                             DEBITO               CREDITO         SALDO ATUAL
		EndIf
	Else
		Cabec2 := STR0013			   	// "LOTE/SUB/DOC/LINHA  H I S T O R I C O                    C/PARTIDA            CENTRO CUSTO         ITEM                 CLASSE DE VALOR                     DEBITO               CREDITO           SALDO ATUAL

		// impress�o da descri��o do custo
		If lCusto
			Cabec2 += Upper(cSayCusto)
		Else
			Cabec2 += Space( Len( cSayCusto ) )
		Endif

		Cabec2 += Space(16)

		// impress�o da descri��o do item
		If lItem
			Cabec2 += Upper(cSayItem)
		Else
			Cabec2 += Space( Len( cSayItem ) )
		Endif

		Cabec2 += Space(16)

		// impress�o da descri��o do clvl
		If lCLVL
			Cabec2 += Upper(cSayClVl)
		Else
			Cabec2 += Space( Len( cSayClVl ) )
		Endif

		// impress�o dos totalizadores
		Cabec2 += Space(18) + STR0029
	EndIf
ElseIf nTipoRel == 2 //Relatorio Resumido
	lCusto := .F.
	lItem  := .F.
	lCLVL  := .F.
	Cabec1 := STR0019		   	// "DATA"
	Cabec2 := STR0031        	//LOTE/SUB/DOC/LINHA H I S T O R I C O                          C/PARTIDA                      DEBITO          CREDITO       SALDO ATUAL
Else 	//Relatorio Sintetico
	lCusto := .F.
	lItem  := .F.
	lCLVL  := .F.
	Cabec1 := STR0055 // 		"DATA                                                                                         DEBITO         CREDITO    SALDO ATUAL"
	Cabec2 := ""
EndIf

If cPaisLoc $ "CHI|ARG"
	Cabec2 := SubStr(Cabec2,1,18) + "-SEGOFI    " + SubStr(Cabec2,20,31) + SubStr(Cabec2,62)
EndIf

m_pag := mv_par22

If lImpLivro
	//��������������������������������������������������������������Ŀ
	//� Monta Arquivo Temporario para Impressao   					 �
	//����������������������������������������������������������������
	If IsBlind()
		CTBGerRaz(,,,,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
		cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
		aSetOfBook,lNoMov,cSaldo,lJunta,"1",lAnalitico,,,aReturn[7],lSldAnt,aSelFil,.T.)// "Emissao do Razao"
	Else
		MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
		CTBGerRaz(oMeter,oText,oDlg,lEnd,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
				cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
				aSetOfBook,lNoMov,cSaldo,lJunta,"1",lAnalitico,,,aReturn[7],lSldAnt,aSelFil)},;
				STR0018,;		// "Criando Arquivo Tempor�rio..."
				STR0006)		// "Emissao do Razao"
			EndIf

	dbSelectArea("CT2")
	If !Empty(dbFilter())
		dbClearFilter()
	Endif
	dbSelectArea("cArqTmp")
	SetRegua(RecCount())
	dbGoTop()
Endif

While lImpLivro .And. !cArqTmp->(Eof())
	IF lEnd
		@Prow()+1,0 PSAY STR0015  //"***** CANCELADO PELO OPERADOR *****"
		Exit
	EndIF
	nQtdReg ++ // Incrementa a cada registro para capturar o total de impressos
	IncRegua()

	If lSldAntCC
		aSaldo    := SaldTotCT3(cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
		aSaldoAnt := SaldTotCT3(cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
	ElseIf lSldAntIt
		aSaldo    := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
		aSaldoAnt := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
	ElseIf lSldAntCv
		aSaldo    := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
		aSaldoAnt := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
	Else
		aSaldo 		:= SaldoCT7Fil(cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,,,,aSelFil)
		aSaldoAnt	:= SaldoCT7Fil(cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,"CTBR400",,,aSelFil)
	EndIf

	If !lNoMov //Se imprime conta sem movimento
		If aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0
			dbSelectArea("cArqTmp")
			dbSkip()
			Loop
		Endif
	Endif

	If lNomov .And. aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0
		If CtbExDtFim("CT1")
			dbSelectArea("CT1")
			dbSetOrder(1)
			If MsSeek(xFilial()+cArqTmp->CONTA)
				If !CtbVlDtFim("CT1",dDataIni)
					dbSelectArea("cArqTmp")
					dbSkip()
					Loop
				EndIf

				If !CtbVlDtIni("CT1",dDataFim)
					dbSelectArea("cArqTmp")
					dbSkip()
					Loop
				EndIf

			EndIf
			dbSelectArea("cArqTmp")
		EndIf
	EndIf

	If li > nMaxLin .Or. lSalto
		CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

		CtCGCCabec(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)

		If !lFirst
			lQbPg	:= .T.
		Else
			lFirst := .F.
		Endif

	EndIf

	nSaldoAtu:= 0
	nTotDeb	:= 0
	nTotCrd	:= 0

	// Conta Sintetica
	cContaSint := Ctr400Sint(cArqTmp->CONTA,@cDescSint,cMoeda,@cDescConta,@cCodRes,cMoedaDesc)
	cNormal := CT1->CT1_NORMAL

	If mv_par11 == 3
		EntidadeCTB(CT1->CT1_CODIMP,li,000,nTamConta,.F.,cMascara1,cSepara1)
		@li,Len(CT1->CT1_CODIMP) PSAY " - " + cDescSint
	Else
		EntidadeCTB(cContaSint,li,000,Len(cContaSint),.F.,cMascara1,cSepara1)
		@li,Len(cContaSint) PSAY " - " + cDescSint
	Endif

	If lSalLin
		li+=2
	Else
		li+=1
	EndIf
	// Conta Analitica

	@li,001 PSAY STR0016 	//"CONTA - "

	If mv_par11 == 1							// Imprime Cod Normal
		EntidadeCTB(cArqTmp->CONTA,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
	Else
		dbSelectArea("CT1")
		dbSetOrder(1)
		MsSeek(xFilial("CT1")+cArqTMP->CONTA,.F.)
		If mv_par11 == 3						// Imprime Codigo de Impressao
			EntidadeCTB(CT1->CT1_CODIMP,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
		Else										// Caso contr�rio usa codigo reduzido
			EntidadeCTB(CT1->CT1_RES,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
		EndIf

		cDescConta := &("CT1->CT1_DESC" + cMoedaDesc )
	Endif
	If !lAnalitico
		@ li, 9+nTamConta+AJUST_CONTA PSAY "- " + Left(cDescConta,30)
	Else
		@ li, 9+nTamConta+AJUST_CONTA PSAY "- " + Left(cDescConta,38)
	Endif

	@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0033) - 1;
		 PSAY STR0033	//"SALDO ANTERIOR: "

	// Impressao do Saldo Anterior do Centro de Custo
	RZValorCTB(aSaldoAnt[6],li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais,;
							         .T.,cPicture, cNormal, , , , , ,lPrintZero)

	nSaldoAtu := aSaldoAnt[6]

	If lSalLin
		li+=2
	Else
		li += 1
	EndIf

	dbSelectArea("cArqTmp")

	cContaAnt:= cArqTmp->CONTA
	dDataAnt	:= CTOD("  /  /  ")

	While cArqTmp->(!Eof()) .And. cArqTmp->CONTA == cContaAnt

		If li > nMaxLin

			If lSalLin
				li++
			EndIf

			@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0090) - 1;
						 PSAY STR0090	//"A TRANSPORTAR : "
					RZValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
					   aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal , , , , , ,lPrintZero)

			CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

			CtCGCCabec(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)

			lQbPg := .T.

			@li,001 PSAY STR0016 	//"CONTA - "

			If mv_par11 == 1							// Imprime Cod Normal
				EntidadeCTB(cArqTmp->CONTA,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
			Else
				dbSelectArea("CT1")
				dbSetOrder(1)
				MsSeek(xFilial("CT1")+cArqTMP->CONTA,.F.)
				If mv_par11 == 3						// Imprime Codigo de Impressao
					EntidadeCTB(CT1->CT1_CODIMP,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
				Else										// Caso contr�rio usa codigo reduzido
					EntidadeCTB(CT1->CT1_RES,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
				EndIf
				cDescConta := &("CT1->CT1_DESC" + cMoedaDesc)
			Endif
			@ li, 9+nTamConta+AJUST_CONTA PSAY "- " + Left(cDescConta,38)

			@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0091) - 1 PSAY STR0091	//"DE TRANSPORTE : " 
			RZValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal , , , , , ,lPrintZero)
			li+= 2
		EndIf

		// Imprime os lancamentos para a conta

		If dDataAnt != cArqTmp->DATAL
			If (cArqTmp->LANCDEB <> 0 .Or. cArqTmp->LANCCRD <> 0)
				If nTiporel < 3
					@li,000 PSAY cArqTmp->DATAL
					li++
				Else
					@li,000 PSAY cArqTmp->DATAL
				Endif
			Endif
			dDataAnt := cArqTmp->DATAL
			lQbPg := .F.
		ElseIf lQbPg
			@li,000 PSAY dDataAnt
			li++
			lQbPg := .F.
		EndIf

		If nTipoRel < 3	//Se for relatorio analitico ou resumido

			nSaldoAtu 	:= Round(nSaldoAtu - cArqTmp->LANCDEB + cArqTmp->LANCCRD, nDecimais)
			nTotDeb		+= cArqTmp->LANCDEB
			nTotCrd		+= cArqTmp->LANCCRD
			nTotGerDeb	+= cArqTmp->LANCDEB
			nTotGerCrd	+= cArqTmp->LANCCRD

			dbSelectArea("CT1")
			dbSetOrder(1)

			MsSeek(xFilial("CT1")+cArqTmp->XPARTIDA)

			cCodRes := CT1->CT1_RES

			dbSelectArea("cArqTmp")

			If cPaisLoc $ "CHI|ARG"
				@li,aColunas[COL_NUMERO] PSAY cArqTmp->LOTE+cArqTmp->SUBLOTE+cArqTmp->DOC+cArqTmp->LINHA+"-"+cArqTmp->SEGOFI
				@li,aColunas[COL_HISTORICO] PSAY Subs(cArqTmp->HISTORICO,1,29)

				// historico complementar da linha (deve-se imprimir na proxima linha)
				cHistComp := Subs(Alltrim(cArqTmp->HISTORICO),30)
			Else
  				@li,aColunas[COL_NUMERO] PSAY cArqTmp->LOTE+cArqTmp->SUBLOTE+cArqTmp->DOC+cArqTmp->LINHA
				@li,aColunas[COL_HISTORICO] PSAY Subs(cArqTmp->HISTORICO,1,40)

				// historico complementar da linha (deve-se imprimir na proxima linha)
				cHistComp := Subs(Alltrim(cArqTmp->HISTORICO),41)
			EndIf

			If mv_par11 == 1
				EntidadeCTB(cArqTmp->XPARTIDA,li,aColunas[COL_CONTRA_PARTIDA], nTamConta ,.F.,cMascara1 ,cSepara1)
			ElseIf mv_par11 == 3
				EntidadeCTB(CT1->CT1_CODIMP,li,aColunas[COL_CONTRA_PARTIDA],nTamConta,.F., cMascara1 ,cSepara1)
			Else
				EntidadeCTB(CT1->CT1_RES,li,aColunas[COL_CONTRA_PARTIDA],17,.F., cMascara1 ,cSepara1)
			Endif

			If lCusto

				If mv_par25 == 1 //Imprime Cod. Centro de Custo Normal
					EntidadeCTB(cArqTmp->CCUSTO,li,aColunas[COL_CENTRO_CUSTO],25,.F.,cMascara2,cSepara2)
				Else
					dbSelectArea("CTT")
					dbSetOrder(1)
					dbSeek(xFilial("CTT")+cArqTmp->CCUSTO)
					cResCC := CTT->CTT_RES
					EntidadeCTB(cResCC,li,aColunas[COL_CENTRO_CUSTO],25,.F.,cMascara2,cSepara2)
					dbSelectArea("cArqTmp")
				Endif

			Endif

			If lItem 						//Se imprime item
				If mv_par26 == 1 //Imprime Codigo Normal Item Contabl
					EntidadeCTB(cArqTmp->ITEM,li,aColunas[COL_ITEM_CONTABIL],25,.F.,cMascara3,cSepara3)
				Else
					dbSelectArea("CTD")
					dbSetOrder(1)
					dbSeek(xFilial("CTD")+cArqTmp->ITEM)
					cResItem := CTD->CTD_RES
					EntidadeCTB(cResItem,li,aColunas[COL_ITEM_CONTABIL],25,.F.,cMascara3,cSepara3)
					dbSelectArea("cArqTmp")
				Endif
			Endif

			If lCLVL						//Se imprime classe de valor
				If mv_par27 == 1 //Imprime Cod. Normal Classe de Valor
					EntidadeCTB(cArqTmp->CLVL,li,aColunas[COL_CLASSE_VALOR],16,.F.,cMascara4,cSepara4)
				Else
					dbSelectArea("CTH")
					dbSetOrder(1)
					dbSeek(xFilial("CTH")+cArqTmp->CLVL)
					cResClVl := CTH->CTH_RES
					EntidadeCTB(cResClVl,li,aColunas[COL_CLASSE_VALOR],16,.F.,cMascara4,cSepara4)
					dbSelectArea("cArqTmp")
				Endif
			Endif

			RZValorCTB(cArqTmp->LANCDEB,li,aColunas[COL_VLR_DEBITO] 	, aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)
			RZValorCTB(cArqTmp->LANCCRD,li,aColunas[COL_VLR_CREDITO]	, aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)
			RZValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO]			, aColunas[TAMANHO_TM],nDecimais,.T.,cPicture,cNormal, , , , , ,lPrintZero)	

			// rotina de impress�o do restante do historico da linha
			While ! Empty( ALLTRIM( cHistComp ) )

				li++
				// controle de quebra de pagina do raz�o
				If li > nMaxLin
					//// VALOR A TRANSPORTAR NA QUEBRA DE PAGINA

					If lSalLin
						li++
					EndIf

					@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0090) - 1 PSAY STR0090	//"A TRANSPORTAR : "
					RZValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal, , , , , ,lPrintZero)
				    //// FIM DO TRATAMENTO PARA QUEBRA DO VALORA A TRANSPORTAR

					CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

					CtCGCCabec(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)

					//// VALOR DE TRANSPORTE NA QUEBRA DE P�GINA
					@li,001 PSAY STR0016 	//"CONTA - "

					If mv_par11 == 1							// Imprime Cod Normal
						EntidadeCTB(cArqTmp->CONTA,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
					Else
						CT1->(dbSetOrder(1))
						CT1->(MsSeek(xFilial("CT1")+cArqTMP->CONTA,.F.))
						If mv_par11 == 3						// Imprime Codigo de Impressao
							EntidadeCTB(CT1->CT1_CODIMP,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
						Else										// Caso contr�rio usa codigo reduzido
							EntidadeCTB(CT1->CT1_RES,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
						Endif
						cDescConta := &("CT1->CT1_DESC" + cMoedaDesc)
						dbSelectArea("CT2")
					EndIf
					@ li, 9+nTamConta+AJUST_CONTA PSAY "- " + Left(cDescConta,38)

					@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0091) - 1 PSAY STR0091	//"DE TRANSPORTE : "
					RZValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal , , , , , ,lPrintZero)
					li+= 2
					//// FINAL DO TRATAMENTO PARA O VALOR DE TRANSPORTE NA QUEBRA DE PAGINA

					If !lFirst
						@li,000 PSAY dDataAnt
						li++
					Else
						lFirst := .F.
					Endif

				EndIf

				If cPaisLoc $ "CHI|ARG"
					@li,aColunas[COL_HISTORICO] PSAY Subs(cHistComp,1,29)

					// historico complementar da linha (deve-se imprimir na proxima linha)
					cHistComp := Subs(cHistComp,30)
				Else
					@li,aColunas[COL_HISTORICO] PSAY Subs(cHistComp,1,40)

					// historico complementar da linha (deve-se imprimir na proxima linha)
					cHistComp := Subs(cHistComp,41)
				EndIf

			EndDo

			// Procura pelo complemento de historico - quando n�o usa proc
			If ( !lCtbRazBD )

				CT2->(dbSetOrder(10))

				If CT2->(MsSeek(cArqTMP->(FILIAL+DTOS(DATAL)+LOTE+SUBLOTE+DOC+SEQLAN+EMPORI+FILORI),.F.))

					CT2->(dbSkip())

					If CT2->CT2_DC == "4"			//// TRATAMENTO PARA IMPRESSAO DAS CONTINUACOES DE HISTORICO

						While !CT2->(Eof()) .And.;
							CT2->CT2_FILIAL == cArqTMP->FILIAL .And.;
							CT2->CT2_LOTE == cArqTMP->LOTE 		.And.;
							CT2->CT2_SBLOTE == cArqTMP->SUBLOTE .And.;
							CT2->CT2_DOC == cArqTmp->DOC 		.And.;
							CT2->CT2_SEQLAN == cArqTmp->SEQLAN 	.And.;
							CT2->CT2_EMPORI == cArqTmp->EMPORI	.And.;
							CT2->CT2_FILORI == cArqTmp->FILORI	.And.;
							CT2->CT2_DC == "4" 					.And.;
							DTOS(CT2->CT2_DATA) == DTOS(cArqTmp->DATAL)

							li++

							// controle de quebra de pagina do raz�o
							If li > nMaxLin
								//// VALOR A TRANSPORTAR NA QUEBRA DE PAGINA

								If lSalLin
									li++
								EndIf

								@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0090) - 1 PSAY STR0090	//"A TRANSPORTAR : "
								RZValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal, , , , , ,lPrintZero)
								//// FIM DO TRATAMENTO PARA QUEBRA DO VALORA A TRANSPORTAR

								CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

								CtCGCCabec(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)

								//// VALOR DE TRANSPORTE NA QUEBRA DE P�GINA
								@li,001 PSAY STR0016 	//"CONTA - "

								If mv_par11 == 1							// Imprime Cod Normal
									EntidadeCTB(cArqTmp->CONTA,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
								Else
									CT1->(dbSetOrder(1))
									CT1->(MsSeek(xFilial("CT1")+cArqTMP->CONTA,.F.))
									If mv_par11 == 3						// Imprime Codigo de Impressao
										EntidadeCTB(CT1->CT1_CODIMP,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
									Else										// Caso contr�rio usa codigo reduzido
										EntidadeCTB(CT1->CT1_RES,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
									Endif
									cDescConta := &("CT1->CT1_DESC" + cMoedaDesc)
									dbSelectArea("CT2")
								EndIf
								@ li, 9+nTamConta+AJUST_CONTA PSAY "- " + Left(cDescConta,38)

								@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0091) - 1 PSAY STR0091	//"DE TRANSPORTE : "
								RZValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal , , , , , ,lPrintZero)
								li+= 2
								//// FINAL DO TRATAMENTO PARA O VALOR DE TRANSPORTE NA QUEBRA DE PAGINA

								If !lFirst
									@li,000 PSAY dDataAnt
									li++
								Else
									lFirst := .F.
								Endif

							EndIf

							@li,aColunas[COL_NUMERO] PSAY Space(15)+CT2->CT2_LINHA

							If cPaisLoc $ "CHI|ARG"
								@li,aColunas[COL_HISTORICO] PSAY Subs(CT2->CT2_HIST,1,29)

								// historico complementar da linha (deve-se imprimir na proxima linha)
								cHistComp := Subs(CT2->CT2_HIST,30)
							Else
								@li,aColunas[COL_HISTORICO] PSAY Subs(CT2->CT2_HIST,1,40)

								// historico complementar da linha (deve-se imprimir na proxima linha)
								cHistComp := Subs(CT2->CT2_HIST,41)
							EndIf

							// rotina de impress�o do restante do historico da linha
							While ! Empty( cHistComp )

								li++

								// controle de quebra de pagina do raz�o
								If li > nMaxLin
									//// VALOR A TRANSPORTAR NA QUEBRA DE PAGINA

									If lSalLin
										li++
									EndIf

									@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0090) - 1 PSAY STR0090	//"A TRANSPORTAR : "
									RZValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal, , , , , ,lPrintZero)
									//// FIM DO TRATAMENTO PARA QUEBRA DO VALORA A TRANSPORTAR

									CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

									CtCGCCabec(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)

									//// VALOR DE TRANSPORTE NA QUEBRA DE P�GINA
									@li,001 PSAY STR0016 	//"CONTA - "

									If mv_par11 == 1							// Imprime Cod Normal
										EntidadeCTB(cArqTmp->CONTA,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
									Else
										dbSelectArea("CT1")
										dbSetOrder(1)
										MsSeek(xFilial("CT1")+cArqTMP->CONTA,.F.)
										If mv_par11 == 3						// Imprime Codigo de Impressao
											EntidadeCTB(CT1->CT1_CODIMP,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
										Else										// Caso contr�rio usa codigo reduzido
											EntidadeCTB(CT1->CT1_RES,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
										Endif
										cDescConta := &("CT1->CT1_DESC" + cMoedaDesc)
										dbSelectArea("CT2")
									EndIf
									@ li, 9+nTamConta+AJUST_CONTA PSAY "- " + Left(cDescConta,38)

									@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0091) - 1 PSAY STR0091	//"DE TRANSPORTE : "
									RZValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal , , , , , ,lPrintZero)
									li+= 2
									//// FINAL DO TRATAMENTO PARA O VALOR DE TRANSPORTE NA QUEBRA DE PAGINA

									If !lFirst
										@li,000 PSAY dDataAnt
										li++
									Else
										lFirst := .F.
									Endif

								EndIf

								If cPaisLoc $ "CHI|ARG"
									@li,aColunas[COL_HISTORICO] PSAY Subs(cHistComp,1,29)

									// historico complementar da linha (deve-se imprimir na proxima linha)
									cHistComp := Subs(cHistComp,30)
								Else
									@li,aColunas[COL_HISTORICO] PSAY Subs(cHistComp,1,40)

									// historico complementar da linha (deve-se imprimir na proxima linha)
									cHistComp := Subs(cHistComp,41)
								EndIf
							EndDo

							CT2->(dbSkip())
						EndDo
					EndIf
				EndIf

			EndIf

			cArqTmp->(dbSkip())
		Else		// Se for sintetico.

			While dDataAnt == cArqTmp->DATAL .And. cContaAnt == cArqTmp->CONTA

				nVlrDeb	+= cArqTmp->LANCDEB
				nVlrCrd	+= cArqTmp->LANCCRD
				nTotGerDeb	+= cArqTmp->LANCDEB
				nTotGerCrd	+= cArqTmp->LANCCRD

				cArqTmp->(dbSkip())

			EndDo

			nSaldoAtu	:= nSaldoAtu - nVlrDeb + nVlrCrd

			RZValorCTB(nVlrDeb,li,aColunas[COL_VLR_DEBITO],aColunas[TAMANHO_TM],;
				nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)

			RZValorCTB(nVlrCrd,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],;
				nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)

			RZValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],;
				nDecimais,.T.,cPicture,cNormal, , , , , ,lPrintZero)

			nTotDeb		+= nVlrDeb
			nTotCrd		+= nVlrCrd
			nVlrDeb	:= 0
			nVlrCrd	:= 0

		Endif

		li++
	EndDo

   	If lSalLin
		li+=2
	EndIf
	If li > nMaxLin
		If lSalLin
			li++
		EndIf

		@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0090) - 1;
					 PSAY STR0090	//"A TRANSPORTAR : "
		RZValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
		   aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal, , , , , ,lPrintZero)

		CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

		CtCGCCabec(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
		If !lFirst
			lQbPg := .T.
		Else
			lFirst := .F.
		Endif

		@li,001 PSAY STR0016 	//"CONTA - "

		If Empty(cContaAnt) .or. cArqTMP->CONTA == cContaAnt			//// SE O REG NO COMECO DA PAGINA FOR DA MESMA CONTA DA PG ANTERIOR
			If mv_par11 == 1							// Imprime Cod Normal
				EntidadeCTB(cArqTmp->CONTA,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
			Else
				dbSelectArea("CT1")
				dbSetOrder(1)
				MsSeek(xFilial("CT1")+cArqTMP->CONTA,.F.)
				If mv_par11 == 3						// Imprime Codigo de Impressao
					EntidadeCTB(CT1->CT1_CODIMP,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
				Else										// Caso contr�rio usa codigo reduzido
					EntidadeCTB(CT1->CT1_RES,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
				EndIf
			Endif
		Else									//// SE NAO FOR DA MESMA CONTA
			dbSelectArea("CT1")
			dbSetOrder(1)
			If MsSeek(xFilial("CT1")+cContaAnt,.F.)		/// IMPRIME OS DADOS DA CONTA ANTERIOR
				If mv_par11 == 1							// Imprime Cod Normal
					EntidadeCTB(cContaAnt,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
				ElseIf mv_par11 == 3						// Imprime Codigo de Impressao
					EntidadeCTB(CT1->CT1_CODIMP,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
				Else										// Caso contr�rio usa codigo reduzido
					EntidadeCTB(CT1->CT1_RES,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
				EndIf
			Endif
		Endif
		cDescConta := &("CT1->CT1_DESC" + cMoedaDesc)
		@ li, 9+nTamConta+AJUST_CONTA PSAY "- " + Left(cDescConta,38)

		@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0091) - 1 PSAY STR0091	//"DE TRANSPORTE "
		RZValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal, , , , , ,lPrintZero)

		If lSalLin
			li+=2
		Else
			li+= 1
		EndIf

		If lQbPg
			If cArqtmp->(!Eof()) .And. cArqTmp->CONTA == cContaAnt
				@li,000 PSAY dDataAnt
			EndIf
			li++
			lQbPg := .F.
		Endif
   EndIf

	@li,aColunas[If(lAnalitico,COL_HISTORICO,COL_NUMERO)] PSAY STR0020  //"T o t a i s  d a  C o n t a  ==> "

	RZValorCTB(nTotDeb,li,aColunas[COL_VLR_DEBITO],aColunas[TAMANHO_TM],nDecimais,;
			 .F.,cPicture,"1", , , , , ,lPrintZero)
	RZValorCTB(nTotCrd,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],nDecimais,;
			 .F.,cPicture,"2", , , , , ,lPrintZero)
	RZValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais,;
			 .T.,cPicture,cNormal, , , , , ,lPrintZero)

	li++
	@li, 00 PSAY Replicate("-",nTamLinha)
	li++
	dbSelectArea("cArqTMP")
EndDo

If li != 80 .And. lImpLivro .And. mv_par28 == 1	//Imprime total Geral
	@li, 30 PSAY STR0025  //"T O T A L  G E R A L  ==> "
	If lAnalitico .And. (lCusto .Or. lItem .Or. lClVl)
		RZValorCTB(nTotGerDeb,li,aColunas[COL_VLR_DEBITO],aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)
		RZValorCTB(nTotGerCrd,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)
		li++
		@li, 00 PSAY Replicate("-",nTamLinha)
	Else
		RZValorCTB(nTotGerDeb,li,aColunas[COL_VLR_DEBITO],aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)
		RZValorCTB(nTotGerCrd,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)
		li++
		@li, 00 PSAY Replicate("-",nTamLinha)
	Endif
Endif

nLinAst := GetNewPar("MV_INUTLIN",0)
If li < nMaxLin .and. nLinAst <> 0 .and. !lEnd
	For nInutLin := 1 to nLinAst
		li++
		@li,00 PSAY REPLICATE("*",LIMITE)
		If li == nMaxLin
			Exit
		EndIf
	Next
EndIf

If lImpTermos 							// Impressao dos Termos

	cArqAbert:=GetNewPar("MV_LRAZABE","")
	cArqEncer:=GetNewPar("MV_LRAZENC","")

	If Empty(cArqAbert)
		ApMsgAlert(	STR0027 +; //"Devem ser criados os parametros MV_LRAZABE e MV_LRAZENC. "
		STR0028) //"Utilize como base o parametro MV_LDIARAB."
	Endif
Endif

If lImpTermos .And. ! Empty(cArqAbert)	// Impressao dos Termos
	li+=2
	dbSelectArea("SM0")
	aVariaveis:={}

	For nCont:=1 to FCount()
		If FieldName(nCont)=="M0_CGC"
			AADD(aVariaveis,{FieldName(nCont),Transform(FieldGet(nCont),"@R 99.999.999/9999-99")})
		Else
			If FieldName(nCont)=="M0_NOME"
				Loop
			EndIf
			AADD(aVariaveis,{FieldName(nCont),FieldGet(nCont)})
		Endif
	Next

	dbSelectArea("SX1")
	dbSeek( padr( "CTR400" , Len( X1_GRUPO ) , ' ' ) + "01" )
	While ! Eof() .And. SX1->X1_GRUPO  == padr( "CTR400" , Len( X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(X1_VAR01)),&(X1_VAR01)})
		dbSkip()
	End

	dbSelectArea( "CVB" )
	CVB->(dbSeek( xFilial( "CVB" ) ))
	For nCont:=1 to FCount()
		If FieldName(nCont)=="CVB_CGC"
			AADD(aVariaveis,{FieldName(nCont),Transform(FieldGet(nCont),"@R 99.999.999/9999-99")})
		ElseIf FieldName(nCont)=="CVB_CPF"
			AADD(aVariaveis,{FieldName(nCont),Transform(FieldGet(nCont),"@R 999.999.999-99")})
		Else
			AADD(aVariaveis,{FieldName(nCont),FieldGet(nCont)})
		Endif
	Next

	AADD(aVariaveis,{"M_DIA",StrZero(Day(dDataBase),2)})
	AADD(aVariaveis,{"M_MES",MesExtenso()})
	AADD(aVariaveis,{"M_ANO",StrZero(Year(dDataBase),4)})

	If !File(cArqAbert)
		aSavSet:=__SetSets()
		cArqAbert:=CFGX024(,"Raz�o") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If !File(cArqEncer)
		aSavSet:=__SetSets()
		cArqEncer:=CFGX024(,"Raz�o") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqAbert#NIL
		ImpTerm(cArqAbert,aVariaveis,AvalImp(132))
	Endif

	If cArqEncer#NIL
		ImpTerm(cArqEncer,aVariaveis,AvalImp(132))
	Endif
Endif

If aReturn[5] = 1
	Set Printer To
	Commit

		//Gerar metrica FWMetrics - Tempo m�dio
	If FunName() <> "CTBC400" .And. __lMetric
		CTB400Metrics("02" /*cEvent*/, /* nStart */, "001" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/, nQtdReg /* nQtdReg */)
		CTB400Metrics("01" /*cEvent*/, nStart, "002" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/)
		nStart := 0
	EndIf
	Ourspool(wnrel)
End

dbselectArea("CT2")

MS_FLUSH()

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CtbGerRaz
Cria Arquivo Temporario para imprimir o Razao

@author Alvaro Camillo Neto

@param	oMeter = Objeto oMeter
@param	oText = Objeto oText
@param	oDlg = Objeto oDlg
@param	lEnd = Acao do Codeblock
@param	cArqTmp = Arquivo temporario
@param	cContaIni = Conta Inicial
@param	cContaFim = Conta Final
@param	cCustoIni = C.Custo Inicial
@param	cCustoFim = C.Custo Final
@param	cItemIni = Item Inicial
@param	cItemFim = Cl.Valor Inicial
@param	cCLVLIni = Cl.Valor Final
@param	cCLVLFim = Moeda
@param	cMoeda = Data Inicial
@param	dDataIni = Data Final
@param	dDataFim = Matriz aSetOfBook
@param	aSetOfBook = Indica se imprime movimento zerado ou nao.
@param	lNoMov = Tipo de Saldo
@param	lJunta = Indica se junta CC ou nao.
@param	lJunta = Tipo do lancamento
@param	lAnalit = Indica se imprime analitico ou sintetico
@param	c2Moeda = Indica moeda 2 a ser incluida no relatorio
@param cUFilter= Conteudo Txt com o Filtro de Usuario (CT2)

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CtbGerRaz(oMeter,oText,oDlg,lEnd,cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
						cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
						aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,lAnalit,c2Moeda,;
						nTipo,cUFilter,lSldAnt,aSelFil,lExterno, lCancel)

Local aTamConta		:= TAMSX3("CT1_CONTA")
Local aTamCusto		:= TAMSX3("CTT_CUSTO")
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local aCtbMoeda		:= {}
Local aSaveArea 	:= GetArea()
Local aCampos
Local cChave
Local aChave		:= {}
Local nTamItem		:= Len(CriaVar("CTD_ITEM"))
Local nTamCLVL		:= Len(CriaVar("CTH_CLVL"))
Local nDecimais		:= 0
Local cMensagem		:= STR0030// O plano gerencial nao esta disponivel nesse relatorio.
Local lCriaInd 		:= .F.
Local nTamFilial 	:= IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3( "CT2_FILIAL" )[1] )
Local cTableNam1 	:= ""
Local lNumAsto      := Iif(cPaisLoc == "PAR" .And. CT2->(FieldPos("CT2_NACSEQ")) > 0, .T., .F.)

DEFAULT c2Moeda 	:= ""
DEFAULT nTipo		:= 1
DEFAULT cUFilter	:= ""
DEFAULT lSldAnt		:= .F.
DEFAULT aSelFil 	:= {}
DEFAULT lExterno 	:= .F.
DEFAULT lEnd 	 	:= .F.
DEFAULT lCancel 	:= .F.

lCtbRazBD := CTB400RAZB(cUFilter)

If cTipo == "1" .And. FunName() == 'CTBR400' .And. TCGetDb() $ "MSSQL7/MSSQL"
	DEFAULT cUFilter	:= ".T."
Else
	DEFAULT cUFilter	:= ""
Endif

// Retorna Decimais
aCtbMoeda := CTbMoeda(cMoeda)
nDecimais := aCtbMoeda[5]

aCampos :={	{ "CONTA"		, "C", aTamConta[1], 0 },;  		// Codigo da Conta
			{ "XPARTIDA"   	, "C", aTamConta[1] , 0 },;		// Contra Partida
			{ "TIPO"       	, "C", 01			, 0 },;			// Tipo do Registro (Debito/Credito/Continuacao)
			{ "LANCDEB"		, "N", aTamVal[1]+2, nDecimais },; // Debito
			{ "LANCCRD"		, "N", aTamVal[1]+2	, nDecimais },; // Credito
			{ "SALDOSCR"	, "N", aTamVal[1]+2, nDecimais },; 			// Saldo
			{ "TPSLDANT"	, "C", 01, 0 },; 					// Sinal do Saldo Anterior => Consulta Razao
			{ "TPSLDATU"	, "C", 01, 0 },; 					// Sinal do Saldo Atual => Consulta Razao
			{ "HISTORICO"	, "C", nR400Char, 0 },;			// Historico
			{ "CCUSTO"		, "C", aTamCusto[1], 0 },;			// Centro de Custo
			{ "ITEM"		, "C", nTamItem		, 0 },;			// Item Contabil
			{ "CLVL"		, "C", nTamCLVL		, 0 },;			// Classe de Valor
			{ "DATAL"		, "D", 10			, 0 },;			// Data do Lancamento
			{ "LOTE" 		, "C", 06			, 0 },;			// Lote
			{ "SUBLOTE" 	, "C", 03			, 0 },;			// Sub-Lote
			{ "DOC" 		, "C", 06			, 0 },;			// Documento
			{ "LINHA"		, "C", Len(CT2->CT2_LINHA), 0 },;			// Linha  03
			{ "SEQLAN"		, "C", Len(CT2->CT2_SEQLAN), 0 },;			// Sequencia do Lancamento  03
			{ "SEQHIST"		, "C", 03			, 0 },;			// Seq do Historico
			{ "EMPORI"		, "C", 02			, 0 },;			// Empresa Original
			{ "FILORI"		, "C", nTamFilial	, 0 },;			// Filial Original
			{ "NOMOV"		, "L", 01			, 0 },;			// Conta Sem Movimento
			{ "FILIAL"		, "C", nTamFilial	, 0 }} // Filial do sistema

If !Empty(__cSegOfi) .And. __cSegOfi != "0"
	Aadd(aCampos,{"SEGOFI","C",TamSx3("CT2_SEGOFI")[1],0})
EndIf

If ! Empty(c2Moeda)
	Aadd(aCampos, { "LANCDEB_1"	, "N", aTamVal[1]+2, nDecimais }) // Debito
	Aadd(aCampos, { "LANCCRD_1"	, "N", aTamVal[1]+2, nDecimais }) // Credito
	Aadd(aCampos, { "TXDEBITO"	, "N", aTamVal[1]+2, 6 }) // Taxa Debito
	Aadd(aCampos, { "TXCREDITO"	, "N", aTamVal[1]+2, 6 }) // Taxa Credito
Endif

If lCtbRazBD
	Aadd(aCampos, { "RECNOCT2"	, "N", 10, 6 }) // Recno da CT2
EndIf

If lNumAsto .and. FunName() $ "CTBR400|CTBR410|CTBC400|CTBR440"
	IF Type("nTipoRel") = "U"
		IF FunName() $ "CTBR400|CTBR440"
			nTipoRel := MV_PAR08
		ElseIf FunName() == "CTBC400"
			nTipoRel := 1 
		Else
			nTipoRel := MV_PAR09
		EndIf
	EndIf
	
	If nTipoRel == 1
		Aadd(aCampos,{"NASIENTO","C",TamSx3("CT2_NACSEQ")[1],0})
	EndIf
EndIf


//Apaga a tabela tempor�ria do banco caso j� exista
If _oCTBR400 <> Nil
	_oCTBR400:Delete()
    _oCTBR400 := Nil
Endif
//-------------------
//Cria��o do objeto
//-------------------
_oCTBR400 := FWTemporaryTable():New("cArqTmp")
_oCTBR400:SetFields( aCampos )

lCriaInd := .T.

//��������������������������������������������������������������Ŀ
//� Cria Indice Temporario do Arquivo de Trabalho 1.             �
//����������������������������������������������������������������
If cTipo == "1"			// Razao por Conta
    If FunName() <> "CTBC400"
		cChave   := "CONTA+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
		aChave	 :=  {"CONTA","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
	Else
		// Alterado o �ndice, para na consulta do raz�o, o hist�rico complementar vir depois do lan�amento
		cChave   := "DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+CONTA+EMPORI+FILORI"
		aChave	 :=  {"DATAL","LOTE","SUBLOTE","DOC","LINHA","CONTA","EMPORI","FILORI"}
	EndIf
ElseIf cTipo == "2"		// Razao por Centro de Custo
	If lAnalit 				// Se o relatorio for analitico
		If FunName() <> "CTBC440"
			If FunName() <> "CTBR440"
				cChave 	:= "CCUSTO+CONTA+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
				aChave	 :=  {"CCUSTO","CONTA","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
			Else
				cChave 	:= "FILIAL+CCUSTO+CONTA+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
				aChave	 :=  {"FILIAL","CCUSTO","CONTA","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
			EndIf
		Else
			// Alterado o �ndice, para na consulta do raz�o, o hist�rico complementar vir depois do lan�amento, assim como CTBR480
			cChave 	:= "DTOS(DATAL)+LOTE+SUBLOTE+DOC+EMPORI+FILORI+LINHA+CCUSTO+CONTA"
			aChave	 :=  {"DATAL","LOTE","SUBLOTE","DOC","EMPORI","FILORI","LINHA","CCUSTO","CONTA"}
		EndIf
	Else
		If FunName() <> "CTBR440"
	   		cChave 	:= "CCUSTO+CONTA+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
	   		aChave	 :=  {"CCUSTO","CONTA","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
        Else
			cChave 	:= "FILIAL+CCUSTO+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
			aChave	 :=  {"FILIAL","CCUSTO","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
		EndIf
	Endif
ElseIf cTipo == "3" 		//Razao por Item Contabil
	If lAnalit 				// Se o relatorio for analitico
		If FunName() <> "CTBC480"
			cChave 	:= "ITEM+CONTA+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
			aChave	 :=  {"ITEM","CONTA","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
		Else
			cChave		:=	"DTOS(DATAL)+LOTE+SUBLOTE+DOC+EMPORI+FILORI+LINHA+ITEM+CONTA"
			aChave		:=	{"DATAL","LOTE","SUBLOTE","DOC","EMPORI","FILORI","LINHA","ITEM","CONTA"}
		Endif
	Else
		cChave 	:= "ITEM+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
		aChave	 :=  {"ITEM","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
	Endif
ElseIf cTipo == "4"		//Razao por Classe de Valor
	If lAnalit 				// Se o relatorio for analitico
		If FunName() <> "CTBC490"
			cChave 	:= "CLVL+CONTA+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
			aChave	 :=  {"CLVL","CONTA","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
		Else
		// Alterado o �ndice, para na consulta do raz�o, o hist�rico complementar vir depois do lan�amento, assim como CTBR480
			cChave	:=	"DTOS(DATAL)+LOTE+SUBLOTE+DOC+EMPORI+FILORI+LINHA+CLVL+CONTA"
			aChave	:=	{"DATAL","LOTE","SUBLOTE","DOC","EMPORI","FILORI","LINHA","CLVL","CONTA"}
		EndIf
	Else
		cChave 	:= "CLVL+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
		aChave	 :=  {"CLVL","DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"}
	Endif
EndIf


If lCriaInd
	_oCTBR400:AddIndex("1", aChave)
Endif

//------------------
//Cria��o da tabela
//------------------
_oCTBR400:Create()

cTableNam1 		:= _oCTBR400:GetRealName()
If lCtbRazBD
	cArqTmp := _oCTBR400:GetRealName()
	cArqTmp := STRTRAN(cArqTmp, "dbo.", "")      //SQLSERVER
EndIf

If !Empty(aSetOfBook[5])
	MsgAlert(cMensagem)
	Return
EndIf

DbSelectarea("cArqTmp")
DbSetOrder(1)
If !lCtbRazBD .And. cTipo == "1" .And. FunName() == 'CTBR400' .And. TCGetDb() $ "MSSQL7/MSSQL"

	CtbQryRaz(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
		cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
		aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,c2Moeda,cUFilter,lSldAnt,aSelFil,lExterno)

Else

	If FunName() <> 'CTBR400'
		If lAnalit 
			nTipoRel := 1 //Tipo Relat�rio Analitico
		Else
			nTipoRel := 2 //Tipo Relat�rio Resumido
		EndIf
	EndIf
	// Monta Arquivo para gerar o Razao
	CtbRazao(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
		cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
			aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,c2Moeda,nTipo,cUFilter,lSldAnt,aSelFil,lExterno,cArqTmp)

EndIf

lCancel := lEnd

RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea := nil 

Return cArqTmp

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CtbRazao  � Autor � Pilar S. Albaladejo   � Data � 05/02/01 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Realiza a "filtragem" dos registros do Razao                ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �CtbRazao(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,		   ���
���			  �cCustoIni,cCustoFim, cItemIni,cItemFim,cCLVLIni,cCLVLFim,   ���
���			  �cMoeda,dDataIni,dDataFim,aSetOfBook,lNoMov,cSaldo,lJunta,   ���
���			  �cTipo)                                                      ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � ExpO1 = Objeto oMeter                                      ���
���           � ExpO2 = Objeto oText                                       ���
���           � ExpO3 = Objeto oDlg                                        ���
���           � ExpL1 = Acao do Codeblock                                  ���
���           � ExpC2 = Conta Inicial                                      ���
���           � ExpC3 = Conta Final                                        ���
���           � ExpC4 = C.Custo Inicial                                    ���
���           � ExpC5 = C.Custo Final                                      ���
���           � ExpC6 = Item Inicial                                       ���
���           � ExpC7 = Cl.Valor Inicial                                   ���
���           � ExpC8 = Cl.Valor Final                                     ���
���           � ExpC9 = Moeda                                              ���
���           � ExpD1 = Data Inicial                                       ���
���           � ExpD2 = Data Final                                         ���
���           � ExpA1 = Matriz aSetOfBook                                  ���
���           � ExpL2 = Indica se imprime movimento zerado ou nao.         ���
���           � ExpC10= Tipo de Saldo                                      ���
���           � ExpL3 = Indica se junta CC ou nao.                         ���
���           � ExpC11= Tipo do lancamento                                 ���
���           � c2Moeda = Indica moeda 2 a ser incluida no relatorio       ���
���           � cUFilter= Conteudo Txt com o Filtro de Usuario (CT2)       ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function CtbRazao(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
					  	cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
					  	aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,c2Moeda,nTipo,cUFilter,lSldAnt,aSelFil,lExterno,cArqTmp)

Local cCpoChave		:= ""
Local cTmpChave		:= ""
Local cContaI			:= ""
Local cContaF			:= ""
Local cCustoI			:= ""
Local cCustoF			:= ""
Local cValid			:= ""
Local cItemI			:= ""
Local cItemF			:= ""
Local cClVlI			:= ""
Local cClVlF			:= ""
Local cVldEnt			:= ""
Local cAlias			:= ""
Local lUFilter		:= !Empty(cUFilter)			//// SE O FILTRO DE USU�RIO N�O ESTIVER VAZIO - TEM FILTRO DE USU�RIO
Local cFilMoeda		:= ""
Local cAliasCT2		:= "CT2"
Local bCond			:= {||.T.}
Local cQryFil			:= '' // variavel de condicional da query
Local cTmpCT2Fil
Local cQuery			:= ""
Local cOrderBy		:= ""
Local nI				:= 0
Local aStru			:= {}
Local nRange			:= 0
Local cContaRang		:= ""
Local cCentroRang		:= ""
Local cItemRang		:= ""
Local cClasRang		:= ""
Local cQryTemp		:= ""
Local cAliasTemp		:= GetNextAlias()
Local cFil_Save
Local nX
Local lNumAsto     := Iif(cPaisLoc == "PAR" .And. CT2->(FieldPos("CT2_NACSEQ")) > 0, .T., .F.)
Local lAutomR400   := FWIsInCallStack("UTSTARTRPT") .And. cPerg == "CTR400"
Local lAutomR440   := FWIsInCallStack("UTSTARTRPT") .And. cPerg == "CTR440"
Local lCTBC400In   := FunName()=="CTBC400" //Quando a vindo do CTBC400 para tratamento de movimentacoes sem saldo, nao devendo aparecer no CTBC400
Local oPrepared    :=  NIL
Local nSeq		   :=  1
Local lExclusivo   := .F.
Local lComparFil   := .F. //Somente compartilhado por Filial
Local lCT2EmpExc   := FwModeAccess("CT2", 1) == "E"
Local lCT2UniExc   := FwModeAccess("CT2", 2) == "E"
Local lCT2FilExc   := FwModeAccess("CT2", 3) == "E"
Local aSelxfil 	   := {}

DEFAULT cUFilter := ".T."
DEFAULT lSldAnt	 := .F.
DEFAULT aSelFil  := {}
DEFAULT lExterno := .F.

SaveInter()//Usado o Save Inter para salvar as Variaveis

If (FWIsInCallStack("CTBR400") .OR. lAutomR400) .AND. !lCTBC400In

	Pergunte(cPerg,.F.)

	//Carregando a Fun��o do MakeSQL
	MakeSQLEXPR(cPerg)
	nRange      := MV_PAR38
	cContaRang  := MV_PAR39
	cCentroRang := MV_PAR40
	cItemRang   := MV_PAR41
	cClasRang   := MV_PAR42
ElseIf lAutomR440
	nRange := 1
Else
	nRange := 1
EndIf

lExclusivo := IIF( lCT2EmpExc .And. lCT2UniExc .And. lCT2FilExc, .T., .F. )
lComparFil := IIF( lCT2EmpExc .And. lCT2UniExc .And. !lCT2FilExc, .T., .F. ) //Somente compartilhado por Filial

If lComparFil
	Aeval(aSelFil, {|a| aAdd( aSelxFil, xFilial('CT2',a) ) } ) //Compatibiliza o compartilhamento das filiais selecionadas
EndIf

// define se vai criar o temporario no banco de dados
lCtbRazBD := CTB400RAZB(cUFilter)

If !lCtbRazBD
	If len(aSelFil) <= 0 .Or. !lExclusivo
		cQryFil := xFilial("CT2")
	EndIf

	cCustoI	:= CCUSTOINI
	cCustoF	:= CCUSTOFIM
	cContaI	:= CCONTAINI
	cContaF	:= CCONTAFIM
	cItemI		:= CITEMINI
	cItemF		:= CITEMFIM
	cClvlI		:= CCLVLINI
	cClVlF 	:= CCLVLFIM



	If !lExterno
		If !IsBlind()
				oMeter:nTotal := CT1->(RecCount())
		Endif
	Endif

	// ������������������Ŀ
	// � Obt�m os d�bitos �
	// ��������������������

	If cTipo <> "1"

		If Len(aSelFil) == 0 .OR. ( Len(aSelFil) == 1 .And. aSelFil[1]==cFilAnt)
			If cTipo = "2" .And. Empty(cCustoIni)
				CTT->(DbSeek(xFilial("CTT")))
				cCustoIni := CTT->CTT_CUSTO
			Endif
			If cTipo = "3" .And. Empty(cItemIni)
				CTD->(DbSeek(xFilial("CTD")))
				cItemIni := CTD->CTD_ITEM
			Endif
			If cTipo = "4" .And. Empty(cClVlIni)
				CTH->(DbSeek(xFilial("CTH")))
				cClVlIni := CTH->CTH_CLVL
			Endif
		Else
			If cTipo = "2" .And. Empty(cCustoIni)
				cCustoIni := PadR( cCustoIni ,Len(CTT->CTT_CUSTO) )
			Endif
			If cTipo = "3" .And. Empty(cItemIni)
				cItemIni := PadR( cItemIni ,Len(CTD->CTD_ITEM) )
			Endif
			If cTipo = "4" .And. Empty(cClVlIni)
				cClVlIni := PadR( cClVlIni ,Len(CTH->CTH_CLVL) )
			Endif
		EndIf
	Endif

	If cTipo == "1"
		dbSelectArea("CT2")
		dbSetOrder(2)

		//Verificando se foi selecionado o tipo Range e se ja esta preenchido
		If(nRange == 2)

			If(!Empty(cContaRang))
				cValid := cContaRang
			EndIf

			If(!Empty(cCentroRang))
				cVldEnt := cCentroRang
			EndIf

			If(!Empty(cItemRang))
				If(!Empty(cVldEnt))
					cVldEnt += " AND "
				EndIf
				cVldEnt += cItemRang
			EndIf

			if(!Empty(cClasRang))
				If(!Empty(cVldEnt))
					cVldEnt += " AND "
				EndIf
				cVldEnt +=  cClasRang
			EndIf
		Else

			cValid	:= 	"CT2_DEBITO>=?" +; //"CT2_DEBITO>='" + cContaIni + "'" //#2
				       "AND CT2_DEBITO<=?" //cContaFim //#3
			cVldEnt :=  "CT2_CCD>=?" +; //"CT2_CCD>='" + cCustoIni + "'" +; //#4
				        "AND CT2_CCD<=?" +; //"AND CT2_CCD<='" + cCustoFim + "'" +; //#5
				        "AND CT2_ITEMD>=?" +; //"AND CT2_ITEMD>='" + cItemIni + "'" +; //#6
				        "AND CT2_ITEMD<=?" +; //cItemFim //#7
				        "AND CT2_CLVLDB>=?" +; //cClVlIni //#8
				        "AND CT2_CLVLDB<=?" //cClVlFim //#9
		EndIf
		cOrderBy:= " CT2_FILIAL, CT2_DEBITO, CT2_DATA "

	ElseIf cTipo == "2"

		dbSelectArea("CT2")
		dbSetOrder(4)
		//Verificando se foi selecionado o tipo Range e se ja esta preenchido
		If(nRange == 2 )

			If(!Empty(cCentroRang))
				cValid := cCentroRang
			EndIf

			If(!Empty(cContaRang))
				cVldEnt := cContaRang
			EndIf

			If(!Empty(cItemRang))
				If(!Empty(cVldEnt))
					cVldEnt += " AND "
				EndIf
				cVldEnt +=  cItemRang
			EndIf

			if(!Empty(cClasRang))
				If(!Empty(cVldEnt))
					cVldEnt += " AND "
				EndIf
				cVldEnt+= cClasRang
			EndIf
		Else

			If Empty(cCustoIni)
				cValid	:= 	"CT2_CCD > ?  AND  " +; //cCustoIni //#10
							"CT2_CCD <= ?" //cCustoFim //#11
			Else
				cValid	:= 	"CT2_CCD >= ?" +; //cCustoIni //#12
							"AND CT2_CCD <= ?" //cCustoFim //#13
			EndIf
			cVldEnt := 	"CT2_DEBITO >= ?" +; //cContaIni //#14
							"AND CT2_DEBITO <= ?" +; //cContaFim  //#15
							"AND CT2_ITEMD >= ?" +; //cItemIni //#16
							"AND CT2_ITEMD <=?" +; //cItemFim //#17
							"AND CT2_CLVLDB >= ?" +; //cClVlIni //#18
							"AND CT2_CLVLDB <= ?" //cClVlFim //#19
		EndIF
		cOrderBy:= " CT2_FILIAL, CT2_CCD, CT2_DATA "

	ElseIf cTipo == "3"

		dbSelectArea("CT2")
		dbSetOrder(6)
		//Verificando se foi selecionado o tipo Range e se ja esta preenchido
		If(nRange == 2)
			If(!Empty(cItemRang))
				cValid := cItemRang
			EndIf

			If(!Empty(cCentroRang))
				cVldEnt := cCentroRang
			EndIf

			If(!Empty(cItemRang))
				If(!Empty(cVldEnt))
					cVldEnt += " AND "
				EndIf
				cVldEnt +=  cItemRang
			EndIf
			
			if(!Empty(cClasRang))
				If(!Empty(cVldEnt))
					cVldEnt += " AND "
				EndIf
				cVldEnt+= cClasRang
			EndIf
		Else

			If Empty(cItemIni)
				cValid 	:= 	"CT2_ITEMD > ?  AND  " +; //cItemIni //#20
								"CT2_ITEMD <= ?" //cItemFim //#21
			Else
				cValid 	:= 	"CT2_ITEMD >= ?" +; //cItemIni //#22
								"AND CT2_ITEMD <= ?" //cItemFim //#23
			EndIf
			cVldEnt		:= 	"CT2_DEBITO >= ?" +; //cContaIni //#24
								"AND CT2_DEBITO <= ?" +; //cContaFim //#25
								"AND CT2_CCD >= ?" +; //cCustoIni //#26
								"AND CT2_CCD <= ?" +; //cCustoFim //#27
								"AND CT2_CLVLDB >= ?" +; //cClVlIni //#28
								"AND CT2_CLVLDB <= ?" //cClVlFim //#29
		EndIf
		cOrderBy:= " CT2_FILIAL, CT2_ITEMD, CT2_DATA "

	ElseIf cTipo == "4"

		dbSelectArea("CT2")
		dbSetOrder(8)
		//Verificando se foi selecionado o tipo Range e se ja esta preenchido
		If(nRange == 2)
			If(!Empty(cClasRang))
				cValid := cClasRang
			EndIf

			If(!Empty(cContaRang))
				cVldEnt := cContaRang
			EndIf

			If(!Empty(cCentroRang))
				If(!Empty(cVldEnt))
					cVldEnt += " AND "
				EndIf
				cVldEnt += cCentroRang
			EndIf

			if(!Empty(cItemRang))
				If(!Empty(cVldEnt))
					cVldEnt += " AND "
				EndIf
				cVldEnt+= cItemRang
			EndIf
		Else

			If Empty(cClVlIni)
				cValid 	:= 	"CT2_CLVLDB > ? AND  " +; //cClVlIni //#30
								"CT2_CLVLDB <= ?" //cClVlFim //#31
			Else
				cValid 	:= 	"CT2_CLVLDB >= ?" +; //cClVlIni //#32
								"AND CT2_CLVLDB <= ?" //cClVlFim //#33
			EndIf
			cVldEnt	:= 	"CT2_DEBITO >= ?" +; //cContaIni //#34
							"AND CT2_DEBITO <= ?" +; //cContaFim //#35
							"AND CT2_CCD >= ?" +; //cCustoIni //#36
							"AND CT2_CCD <= ?" +; //cCustoFim //#37
							"AND CT2_ITEMD >= ?" +; //cItemIni //#38
							"AND CT2_ITEMD <= ?" //cItemFim //#39

		EndIf
		cOrderBy:= " CT2_FILIAL, CT2_CLVLDB, CT2_DATA "

	EndIf

	cAliasCT2	:= "cAliasCT2"

	cQuery	:= " SELECT * "
	cQuery	+= " FROM " + RetSqlName("CT2")
	
	If len(aSelfil) > 0 .And. lExclusivo 
		cQuery	+= " WHERE CT2_FILIAL IN (?) AND " //#1
	ElseIf len(aSelFil) > 0 .And. !lExclusivo .And. !lComparFil
		cQuery	+= " WHERE CT2_FILORI IN (?) AND " //#1
	ElseIf Len(aSelFil) > 0 .And. lComparFil //Somente compartilhado por Filial
		cQuery += " WHERE CT2_FILIAL IN (?) AND " //#1
	else
		cQuery	+= " WHERE CT2_FILIAL=? AND " //#1
	EndIf

	If(!Empty(cValid))
		cQuery	+= cValid + " AND "
	EndIf

	If(!Empty(cVldEnt))
		cQuery	+= cVldEnt+ " AND "
	EndIf

	cQuery	+= " CT2_DATA >= ? AND " //DTOS(dDataIni) #40
	cQuery	+= " CT2_DATA <= ? AND " //DTOS(dDataFim) #41

	If !Empty(c2Moeda)
		cQuery	+= " (CT2_MOEDLC = ? OR " //#42
		cQuery	+= " CT2_MOEDLC = ?) AND "  //#43 
	Else
		cQuery	+= " CT2_MOEDLC = ? AND "  //#42
	EndIf

	cQuery	+= " CT2_TPSALD = ?" //cSaldo //#44 //cSaldo
	cQuery	+= " AND (CT2_DC = '1' OR CT2_DC = '3')"
	cQuery   += " AND CT2_VALOR <> 0 "
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	cQuery	+= " ORDER BY "+ cOrderBy

	oPrepared := FWPreparedStatement():New(cQuery)
	
	If len(aSelfil) > 0 .And. lExclusivo .And. !lComparFil
		oPrepared:SetIn( nSeq++, aSelFil	) //#1
	ElseIf len(aSelfil) > 0 .And. !lExclusivo .And. !lComparFil
		oPrepared:SetIn( nSeq++, aSelFil	) //#1
	ElseIf len(aSelfil) > 0 .And. !lExclusivo .And. lComparFil //Somente compartilhado por Filial
		oPrepared:SetIn( nSeq++, aSelxFil	) //#1
	else
		oPrepared:SetString( nSeq++, cQryFil	) //#1
	EndIf

	If cTipo == "1"
		//Verificando se foi selecionado o tipo Range e se ja esta preenchido
		If(nRange <> 2)
			oPrepared:SetString( nSeq++, cContaIni	) //#2
			oPrepared:SetString( nSeq++, cContaFim	) //#3
			oPrepared:SetString( nSeq++, cCustoIni	) //#4
			oPrepared:SetString( nSeq++, cCustoFim	) //#5
			oPrepared:SetString( nSeq++, cItemIni	) //#6
			oPrepared:SetString( nSeq++, cItemFim	) //#7
			oPrepared:SetString( nSeq++, cClVlIni	) //#8
			oPrepared:SetString( nSeq++, cClVlFim	) //#9
		EndIf

	ElseIf cTipo == "2"

		//Verificando se foi selecionado o tipo Range e se ja esta preenchido
		If(nRange <> 2 )

			If Empty(cCustoIni)
				oPrepared:SetString( nSeq++, cCustoIni	) //#10
				oPrepared:SetString( nSeq++, cCustoFim	) //#11
			Else
				oPrepared:SetString( nSeq++, cCustoIni	) //#12
				oPrepared:SetString( nSeq++, cCustoFim	) //#13
			EndIf

			oPrepared:SetString( nSeq++, cContaIni	) //#14
			oPrepared:SetString( nSeq++, cContaFim	) //#15
			oPrepared:SetString( nSeq++, cItemIni	) //#16
			oPrepared:SetString( nSeq++, cItemFim	) //#17
			oPrepared:SetString( nSeq++, cClVlIni	) //#18
			oPrepared:SetString( nSeq++, cClVlFim	) //#19
		EndIF

	ElseIf cTipo == "3"

		//Verificando se foi selecionado o tipo Range e se ja esta preenchido
		If(nRange <> 2)

			If Empty(cItemIni)
				oPrepared:SetString( nSeq++, cItemIni	) //#20
				oPrepared:SetString( nSeq++, cItemFim	) //#21
			Else
				oPrepared:SetString( nSeq++, cItemIni	) //#22
				oPrepared:SetString( nSeq++, cItemFim	) //#23
			EndIf

			oPrepared:SetString( nSeq++, cContaIni	) //#24
			oPrepared:SetString( nSeq++, cContaFim	) //#25
			oPrepared:SetString( nSeq++, cCustoIni	) //#26
			oPrepared:SetString( nSeq++, cCustoFim	) //#27
			oPrepared:SetString( nSeq++, cClVlIni	) //#28
			oPrepared:SetString( nSeq++, cClVlFim	) //#29
		EndIf

	ElseIf cTipo == "4"

		//Verificando se foi selecionado o tipo Range e se ja esta preenchido
		If(nRange <> 2)

			If Empty(cClVlIni)
				oPrepared:SetString( nSeq++, cClVlIni	) //#30
				oPrepared:SetString( nSeq++, cClVlFim	) //#31
			Else
				oPrepared:SetString( nSeq++, cClVlIni	) //#32
				oPrepared:SetString( nSeq++, cClVlFim	) //#33
			EndIf

			oPrepared:SetString( nSeq++, cContaIni	) //#34
			oPrepared:SetString( nSeq++, cContaFim	) //#35
			oPrepared:SetString( nSeq++, cCustoIni	) //#36
			oPrepared:SetString( nSeq++, cCustoFim	) //#37
			oPrepared:SetString( nSeq++, cItemIni	) //#38
			oPrepared:SetString( nSeq++, cItemFim	) //#39

		EndIf

	EndIf

	oPrepared:SetString( nSeq++, DTOS(dDataIni)	) //#40
	oPrepared:SetString( nSeq++, DTOS(dDataFim)	) //#41

	If !Empty(c2Moeda)
		oPrepared:SetString( nSeq++, cMoeda	) //#42
		oPrepared:SetString( nSeq++, c2Moeda) //#43
	Else
		oPrepared:SetString( nSeq++, cMoeda	) //#42
	EndIf

	oPrepared:SetString( nSeq++,cSaldo	) //#44
	cQuery := oPrepared:GetFixQuery()

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCT2,.T.,.F.)
	aStru := CT2->(dbStruct())

	For ni := 1 to Len(aStru)
		If aStru[ni,2] != 'C'
			TCSetField(cAliasCT2, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		Endif
	Next ni

	If lUFilter					//// ADICIONA O FILTRO DEFINIDO PELO USU�RIO SE N�O ESTIVER EM BRANCO
		If !Empty(cVldEnt)
			cVldEnt  += " AND "			/// SE J� TIVER CONTEUDO, ADICIONA "AND"
			cVldEnt  += cUFilter				/// ADICIONA O FILTRO DE USU�RIO
		EndIf
	EndIf

	If (!lUFilter) .or. Empty(cUFilter)
		cUFilter := ".T."
	EndIf

	dbSelectArea(cAliasCT2)
	While !Eof()
		If &cUFilter
			CtbGrvRAZ(lJunta,cMoeda,cSaldo,"1",c2Moeda,cAliasCT2,nTipo)
			dbSelectArea(cAliasCT2)
		EndIf
		dbSkip()
	EndDo
	If ( Select ( "cAliasCT2" ) <> 0 )
		dbSelectArea ( "cAliasCT2" )
		dbCloseArea ()
	Endif

	// ������������������Ŀ
	// � Obt�m os creditos�
	// ��������������������
	If cTipo == "1"
		dbSelectArea("CT2")
		dbSetOrder(3)
	ElseIf cTipo == "2"
		dbSelectArea("CT2")
		dbSetOrder(5)
	ElseIf cTipo == "3"
		dbSelectArea("CT2")
		dbSetOrder(7)
	ElseIf cTipo == "4"
		dbSelectArea("CT2")
		dbSetOrder(9)
	EndIf

	cVldEnt := ""
	cValid  :=	 ""

	If cTipo == "1"
		If(nRange == 2)

			If(!Empty(cContaRang))
				cValid := STRTRAN(cContaRang,'CT2_DEBITO','CT2_CREDIT')
			EndIf

			If(!Empty(cCentroRang))
				cVldEnt := STRTRAN(cCentroRang,'CT2_CCD','CT2_CCC')
			EndIf
			If(!Empty(cItemRang))
				If(!Empty(cVldEnt))
					cVldEnt += " AND "
				EndIf
				cVldEnt += STRTRAN(cItemRang,'CT2_ITEMD','CT2_ITEMC')
			EndIf
			if(!Empty(cClasRang))
				If(!Empty(cVldEnt))
					cVldEnt += " AND "
				EndIf
				cVldEnt+= STRTRAN(cClasRang,'CT2_CLVLDB','CT2_CLVLCR')
			EndIf

		Else

			cValid	:= 	"CT2_CREDIT>= ?" +; //cContaIni
				"AND CT2_CREDIT<= ?" //cContaFim
			cVldEnt :=	"CT2_CCC>= ?" +; //cCustoIni
				"AND CT2_CCC<= ?" +; //cCustoFim
				"AND CT2_ITEMC>= ?" +; //cItemIni
				"AND CT2_ITEMC<= ?" +; //cItemFim
				"AND CT2_CLVLCR>= ?" +; //cClVlIni
				"AND CT2_CLVLCR<= ?" //cClVlFim

		EndIf
		cOrderBy:= " CT2_FILIAL, CT2_CREDIT, CT2_DATA "
	ElseIf cTipo == "2"
		If(nRange == 2)
			If(!Empty(cCentroRang))
				cValid := STRTRAN(cCentroRang,'CT2_CCD','CT2_CCC')
			EndIf

			If(!Empty(cContaRang))
				cVldEnt := STRTRAN(cContaRang,'CT2_DEBITO','CT2_CREDIT')
			EndIf

			If(!Empty(cClasRang))
				If(!Empty(cVldEnt))
					cVldEnt += " AND "
				EndIf
				cVldEnt +=  STRTRAN(cClasRang,'CT2_CLVLDB','CT2_CLVLCR')

			EndIf
			if(!Empty(cItemRang))
				If(!Empty(cVldEnt))
					cVldEnt += " AND "
				EndIf
				cVldEnt+=  STRTRAN(cItemRang,'CT2_ITEMD','CT2_ITEMC')

			EndIf
		Else

			If Empty(cCustoIni)
					cValid 	:= 	"CT2_CCC > ?  AND  " +; //cCustoIni
								"CT2_CCC <= ?" //cCustoFim
			Else
				cValid 	:= 	"CT2_CCC >= ?" +; //cCustoIni
								"AND CT2_CCC <= ?" //cCustoFim
			EndIf
			cVldEnt	:= 	"CT2_CREDIT >= ?" +; //cContaIni
							"AND CT2_CREDIT <= ?" +; //cContaFim
							"AND CT2_ITEMC >= ?" +; //cItemIni
							"AND CT2_ITEMC <= ?" +; //cItemFim
							"AND CT2_CLVLCR >= ?" +; //cClVlIni
							"AND CT2_CLVLCR <= ?" //cClVlFim

		EndIf
		cOrderBy:= " CT2_FILIAL, CT2_CCC, CT2_DATA "
	ElseIf cTipo == "3"
		If(nRange == 2)
			If(!Empty(cItemRang))

				cValid := STRTRAN(cItemRang,'CT2_ITEMD','CT2_ITEMC')

			EndIf
			If(!Empty(cContaRang))

				cVldEnt := STRTRAN(cContaRang,'CT2_DEBITO','CT2_CREDIT')

			EndIf
			If(!Empty(cCentroRang))
				If(!Empty(cVldEnt))
					cVldEnt += " AND "
				EndIf
				cVldEnt += STRTRAN(cCentroRang,'CT2_CCD','CT2_CCC')

			EndIf
			if(!Empty(cClasRang))
				If(!Empty(cVldEnt))
					cVldEnt += " AND "
				EndIf
				cVldEnt+= STRTRAN(cClasRang,'CT2_CLVLDB','CT2_CLVLCR')

			EndIf

		Else

			If Empty(cItemIni)
				cValid 	:= 	"CT2_ITEMC > ?  AND  " +; //cItemIni
								"CT2_ITEMC <= ?" //cItemFim
			Else
				cValid 	:= 	"CT2_ITEMC >= ?" +; //cItemIni
								"AND CT2_ITEMC <= ?" //cItemFim
			EndIf
			cVldEnt := 	"CT2_CREDIT >= ?" +; //cContaIni
							"AND CT2_CREDIT <= ?" +; //cContaFim
							"AND CT2_CCC >= ?" +; //cCustoIni
							"AND CT2_CCC <= ?" +; //cCustoFim
							"AND CT2_CLVLCR >= ?" +; //cClVlIni
							"AND CT2_CLVLCR <= ?" //cClVlFim

		EndIf
		cOrderBy:= " CT2_FILIAL, CT2_ITEMC, CT2_DATA "
	ElseIf cTipo == "4"
		If(nRange == 2)
			If(!Empty(cClasRang))

				cValid := STRTRAN(cClasRang,'CT2_CLVLDB','CT2_CLVLCR')

			EndIf
			If(!Empty(cContaRang))
				cVldEnt := STRTRAN(cContaRang,'CT2_DEBITO','CT2_CREDIT')
			EndIf
			If(!Empty(cCentroRang))
				If(!Empty(cVldEnt))
					cVldEnt += " AND "
				EndIf
				cVldEnt += STRTRAN(cCentroRang,'CT2_CCD','CT2_CCC')
			EndIf
			if(!Empty(cItemRang))
				If(!Empty(cVldEnt))
					cVldEnt += " AND "
				EndIf
				cVldEnt+=  STRTRAN(cItemRang,'CT2_ITEMD','CT2_ITEMC')
			EndIf

		Else

			If Empty(cClVlIni)
				cValid 	:= 	"CT2_CLVLCR >? AND  " +; //cClVlIni
							"CT2_CLVLCR <= ?" //cClVlFim
			Else
				cValid 	:= 	"CT2_CLVLCR >= ?" +; //cClVlIni
								"AND CT2_CLVLCR <= ?" //cClVlFim
			EndIf
			cVldEnt := 	"CT2_CREDIT >= ?" +; //cContaIni
							"AND CT2_CREDIT <= ?" +; //cContaFim
							"AND CT2_CCC >= ?" +; //cCustoIni
							"AND CT2_CCC <= ?" +; //cCustoFim
							"AND CT2_ITEMC >= ?" +; //cItemIni
							"AND CT2_ITEMC <= ?" //cItemFim

		EndIf
		cOrderBy := " CT2_FILIAL, CT2_CLVLCR, CT2_DATA "
	EndIf

	cAliasCT2	:= "cAliasCT2"

	cQuery	:= " SELECT * "
	cQuery	+= " FROM " + RetSqlName("CT2")
	
	If len(aSelfil) > 0 .And. lExclusivo 
		cQuery	+= " WHERE CT2_FILIAL IN (?) AND "
	ElseIf len(aSelFil) > 0 .And. !lExclusivo .And. !lComparFil
		cQuery	+= " WHERE CT2_FILORI IN (?) AND " 
	ElseIf Len(aSelFil) > 0 .And. lComparFil //Somente compartilhado por Filial
		cQuery += " WHERE CT2_FILIAL IN (?) AND " 
	else
		cQuery	+= " WHERE CT2_FILIAL=? AND "
	EndIf

	If(!Empty(cValid))
		cQuery	+= cValid + " AND "
	EndIf

	If(!Empty(cVldEnt))
		cQuery	+= cVldEnt+ " AND "
	EndIf

	cQuery	+= " CT2_DATA >= ? AND " // DTOS(dDataIni)
	cQuery	+= " CT2_DATA <= ? AND " //DTOS(dDataFim) 

	If !Empty(c2Moeda)
		cQuery	+= " (CT2_MOEDLC = ? OR " //#42
		cQuery	+= " CT2_MOEDLC = ?) AND "  //#43 
	Else
		cQuery	+= " CT2_MOEDLC = ? AND "  //#42
	EndIf
	
	cQuery	+= " CT2_TPSALD = ? AND " //cSaldo
	cQuery	+= " (CT2_DC = '2' OR CT2_DC = '3') AND "
	cQuery	+= " CT2_VALOR <> 0 AND "
	cQuery	+= " D_E_L_E_T_ = ' ' "
	cQuery	+= " ORDER BY "+ cOrderBy

	oPrepared := FWPreparedStatement():New(cQuery)
	nSeq := 1

	If len(aSelfil) > 0 .And. lExclusivo .And. !lComparFil
		oPrepared:SetIn( nSeq++, aSelFil	)
	ElseIf len(aSelfil) > 0 .And. !lExclusivo .And. !lComparFil
		oPrepared:SetIn( nSeq++, aSelFil	)
	ElseIf len(aSelfil) > 0 .And. !lExclusivo .And. lComparFil //Somente compartilhado por Filial
		oPrepared:SetIn( nSeq++, aSelxFil	) 
	else
		oPrepared:SetString( nSeq++, cQryFil	)
	EndIf
	
	If cTipo == "1"
		If(nRange <> 2)

			oPrepared:SetString( nSeq++, cContaIni	)
			oPrepared:SetString( nSeq++, cContaFim	)
			oPrepared:SetString( nSeq++, cCustoIni	)
			oPrepared:SetString( nSeq++, cCustoFim	)
			oPrepared:SetString( nSeq++,cItemIni	)
			oPrepared:SetString( nSeq++,cItemFim	)
			oPrepared:SetString( nSeq++,cClVlIni	)
			oPrepared:SetString( nSeq++,cClVlFim	)
		EndIf

	ElseIf cTipo == "2"
		If(nRange <> 2)

			If Empty(cCustoIni)
				oPrepared:SetString( nSeq++,cCustoIni	)
				oPrepared:SetString( nSeq++,cCustoFim	)
			Else
				oPrepared:SetString( nSeq++,cCustoIni	)
				oPrepared:SetString( nSeq++,cCustoFim	)
			EndIf

			oPrepared:SetString( nSeq++,cContaIni	)
			oPrepared:SetString( nSeq++,cContaFim	)
			oPrepared:SetString( nSeq++,cItemIni	)
			oPrepared:SetString( nSeq++,cItemFim	)
			oPrepared:SetString( nSeq++,cClVlIni	)
			oPrepared:SetString( nSeq++,cClVlFim	)

		EndIf
	ElseIf cTipo == "3"
		If(nRange <> 2)

			If Empty(cItemIni)
				oPrepared:SetString( nSeq++,cItemIni	)
				oPrepared:SetString( nSeq++,cItemFim	)
			Else
				oPrepared:SetString( nSeq++,cItemIni	)
				oPrepared:SetString( nSeq++,cItemFim	)
			EndIf

			oPrepared:SetString( nSeq++,cContaIni	)
			oPrepared:SetString( nSeq++,cContaFim	)
			oPrepared:SetString( nSeq++,cCustoIni	)
			oPrepared:SetString( nSeq++,cCustoFim	)
			oPrepared:SetString( nSeq++,cClVlIni	)
			oPrepared:SetString( nSeq++,cClVlFim	)

		EndIf
	ElseIf cTipo == "4"
		If(nRange <> 2)
			If Empty(cClVlIni)
				oPrepared:SetString( nSeq++,cClVlIni	)
				oPrepared:SetString( nSeq++,cClVlFim	)
			Else
				oPrepared:SetString( nSeq++,cClVlIni	)
				oPrepared:SetString( nSeq++,cClVlFim	)
			EndIf
			oPrepared:SetString( nSeq++,cContaIni	)
			oPrepared:SetString( nSeq++,cContaFim	)
			oPrepared:SetString( nSeq++,cCustoIni	)
			oPrepared:SetString( nSeq++,cCustoFim	)
			oPrepared:SetString( nSeq++,cItemIni	)
			oPrepared:SetString( nSeq++,cItemFim	)

		EndIf

	EndIf

	oPrepared:SetString( nSeq++, DTOS(dDataIni)	)
	oPrepared:SetString( nSeq++, DTOS(dDataFim) )

	If !Empty(c2Moeda)
		oPrepared:SetString( nSeq++, cMoeda	)
		oPrepared:SetString( nSeq++, c2Moeda)
	Else
		oPrepared:SetString( nSeq++, cMoeda	)
	EndIf

	oPrepared:SetString( nSeq++,cSaldo	)

	cQuery := oPrepared:GetFixQuery()

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCT2,.T.,.F.)

	aStru := CT2->(dbStruct())

	For ni := 1 to Len(aStru)
		If aStru[ni,2] != 'C'
			TCSetField(cAliasCT2, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		Endif
	Next ni


	If lUFilter					//// ADICIONA O FILTRO DEFINIDO PELO USU�RIO SE N�O ESTIVER EM BRANCO
		If !Empty(cVldEnt)
			cVldEnt  += " AND "			/// SE J� TIVER CONTEUDO, ADICIONA "AND"
			cVldEnt  += cUFilter				/// ADICIONA O FILTRO DE USU�RIO
		EndIf
	EndIf

	If (!lUFilter) .or. Empty(cUFilter)
		cUFilter := ".T."
	EndIf

	dbSelectArea(cAliasCT2)
	While !Eof()
		If &cUFilter
			CtbGrvRAZ(lJunta,cMoeda,cSaldo,"2",c2Moeda,cAliasCT2,nTipo)
			dbSelectArea(cAliasCT2)
		EndIf
		dbSkip()
	EndDo

	If ( Select ( "cAliasCT2" ) <> 0 )
		dbSelectArea ( "cAliasCT2" )
		dbCloseArea ()
	Endif

	If lNoMov .or. lSldAnt

		If Len(aSelFil) == 0 .OR. (Len(aSelFil)==1 .And. aSelFil[1]==cFilAnt)

			If cTipo == "1"

				cQryTemp := " SELECT CT1_CONTA FROM " + RetSqlName('CT1') + " WHERE CT1_FILIAL = '" + xFilial("CT1") + "'"
				cQryTemp += " AND CT1_CLASSE = '2' AND D_E_L_E_T_ = ' '"

				If(!Empty(cContaRang) .And. nRange == 2)

					cQryTemp += " AND " + STRTRAN(cContaRang,'CT2_DEBITO','CT1_CONTA')

				Else

					cQryTemp += " AND CT1_CONTA >= '"+cContaI+ "' AND CT1_CONTA <= '" + cContaF + "'"

				EndIf

				cQryTemp += " ORDER BY "+ SqlOrder( CT1->(IndexKey(3)) )
				cCpoChave := "CT1_CONTA"
				cTmpChave := "CONTA"
			ElseIf cTipo == "2"

				cQryTemp := " SELECT CTT_CUSTO FROM " + RetSqlName('CTT') + " WHERE CTT_FILIAL = '" + xFilial("CTT") + "'"
				cQryTemp += " AND CTT_CLASSE = '2' AND D_E_L_E_T_ = ' '"

				If(!Empty(cCentroRang).And. nRange == 2)


					cQryTemp += " AND " + STRTRAN(cCentroRang,'CT2_CCD','CTT_CUSTO')

				Else

					cQryTemp += "AND CTT_CUSTO >= '"+cCustoI+"' AND CTT_CUSTO <= '" + cCUSTOF + "'

				EndIf

				cQryTemp += " ORDER BY "+ SqlOrder( CTT->(IndexKey(2)) )
				cCpoChave := "CTT_CUSTO"
				cTmpChave := "CCUSTO"
			ElseIf ctipo == "3"

				cQryTemp := " SELECT CTD_ITEM FROM " + RetSqlName('CTD') + " WHERE CTD_FILIAL = '" + xFilial("CTD") + "'"
				cQryTemp += " AND CTD_CLASSE = '2' AND D_E_L_E_T_ = ' '"

				If(!Empty(cItemRang) .And. nRange == 2)

					cQryTemp += " AND " + STRTRAN(cItemRang,'CT2_ITEMD','CTD_ITEM')

				Else

					cQryTemp += " AND CTD_ITEM >= '"+cItemI+"' AND CTD_ITEM <= '" + cITEMF + "'"

				EndIf

				cQryTemp  += " ORDER BY " + SqlOrder( CTD->(IndexKey(2)) )
				cCpoChave := "CTD_ITEM"
				cTmpChave := "ITEM"
			ElseIf ctipo == "4"

				cQryTemp := " SELECT CTH_CLVL FROM " + RetSqlName('CTH') + " WHERE CTH_FILIAL = '" + xFilial("CTH") + "'
				cQryTemp += " AND CTH_CLASSE = '2' AND D_E_L_E_T_ = ' '"

				If(!Empty(cClasRang) .And. nRange == 2)

					cQryTemp += " AND " + STRTRAN(cClasRang,'CT2_CLVLDB','CTH_CLVL')

				Else

					cQryTemp += " AND CTH_CLVL >= '"+ cClVlI +"' AND CTH_CLVL <= '" + cCLVLF + "'"

				EndIf

				cQryTemp += " ORDER BY " + SqlOrder( CTH->(IndexKey(2)) )
				cCpoChave := "CTH_CLVL"
				cTmpChave := "CLVL"
			EndIf

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryTemp),cAliasTemp,.T.,.F.)


			cAlias := cAliasTemp

			If !lCTBC400In
				While ! Eof()

					dbSelectArea("cArqTmp")
					cKey2Seek	:= &(cAlias + "->" + cCpoChave)
					If !DbSeek(cKey2Seek)
						If lNoMov
							CtbGrvNoMov(cKey2Seek,dDataIni,cTmpChave)
						ElseIf cTipo == "1"		/// SOMENTE PARA O RAZAO POR CONTA
							/// TRATA OS DADOS PARA A PERGUNTA "IMPRIME CONTA SEM MOVIMENTO" = "NAO C/ SLD.ANT."
							If SaldoCT7Fil(cKey2Seek,dDataIni,cMoeda,cSaldo,'CTBR400')[6] <> 0 .and. cArqTMP->CONTA <> cKey2Seek
								/// SE TIVER SALDO ANTERIOR E N�O TIVER MOVIMENTO GRAVADO
								CtbGrvNoMov(cKey2Seek,dDataIni,cTmpChave)
							Endif
						EndIf
					Endif
					DbSelectArea(cAlias)
					DbSkip()
				EndDo
			Endif
			DbSelectArea(cAlias)
			DbClearFil()

		Else

			//salvar cfilant
			cFil_Save := cFilAnt

			For nX := 1 to Len(aSelFil)

				cFilAnt := aSelFil[nX]

				If cTipo == "1"

					cQryTemp := " SELECT CT1_CONTA FROM " + RetSqlName('CT1') + " WHERE CT1_FILIAL = '" + xFilial("CT1") + "'"
					cQryTemp += " AND CT1_CLASSE = '2' AND D_E_L_E_T_ = ' '"

					If(!Empty(cContaRang) .And. nRange == 2)

						cQryTemp += " AND " + STRTRAN(cContaRang,'CT2_DEBITO','CT1_CONTA')

					Else

						cQryTemp += " AND CT1_CONTA >= '"+cContaI+ "' AND CT1_CONTA <= '" + cContaF + "'"

					EndIf

					cQryTemp += " ORDER BY "+ SqlOrder( CT1->(IndexKey(3)) )
					cCpoChave := "CT1_CONTA"
					cTmpChave := "CONTA"
				ElseIf cTipo == "2"

					cQryTemp := " SELECT CTT_CUSTO FROM " + RetSqlName('CTT') + " WHERE CTT_FILIAL = '" + xFilial("CTT") + "'"
					cQryTemp += " AND CTT_CLASSE = '2' AND D_E_L_E_T_ = ' '"

					If(!Empty(cCentroRang).And. nRange == 2)


						cQryTemp += " AND " + STRTRAN(cCentroRang,'CT2_CCD','CTT_CUSTO')

					Else

						cQryTemp += "AND CTT_CUSTO >= '"+cCustoI+"' AND CTT_CUSTO <= '" + cCUSTOF + "'

					EndIf

					cQryTemp += " ORDER BY "+ SqlOrder( CTT->(IndexKey(2)) )
					cCpoChave := "CTT_CUSTO"
					cTmpChave := "CCUSTO"
				ElseIf ctipo == "3"

					cQryTemp := " SELECT CTD_ITEM FROM " + RetSqlName('CTD') + " WHERE CTD_FILIAL = '" + xFilial("CTD") + "'"
					cQryTemp += " AND CTD_CLASSE = '2' AND D_E_L_E_T_ = ' '"

					If(!Empty(cItemRang) .And. nRange == 2)

						cQryTemp += " AND " + STRTRAN(cItemRang,'CT2_ITEMD','CTD_ITEM')

					Else

						cQryTemp += " AND CTD_ITEM >= '"+cItemI+"' AND CTD_ITEM <= '" + cITEMF + "'"

					EndIf

					cQryTemp  += " ORDER BY " + SqlOrder( CTD->(IndexKey(2)) )
					cCpoChave := "CTD_ITEM"
					cTmpChave := "ITEM"
				ElseIf ctipo == "4"

					cQryTemp := " SELECT CTH_CLVL FROM " + RetSqlName('CTH') + " WHERE CTH_FILIAL = '" + xFilial("CTH") + "'
					cQryTemp += " AND CTH_CLASSE = '2' AND D_E_L_E_T_ = ' '"

					If(!Empty(cClasRang) .And. nRange == 2)

						cQryTemp += " AND " + STRTRAN(cClasRang,'CT2_CLVLDB','CTH_CLVL')

					Else

						cQryTemp += " AND CTH_CLVL >= '"+ cClVlI +"' AND CTH_CLVL <= '" + cCLVLF + "'"

					EndIf

					cQryTemp += " ORDER BY " + SqlOrder( CTH->(IndexKey(2)) )
					cCpoChave := "CTH_CLVL"
					cTmpChave := "CLVL"
				EndIf

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryTemp),cAliasTemp,.T.,.F.)


				cAlias := cAliasTemp
				If !lCTBC400In
					While ! Eof()

						dbSelectArea("cArqTmp")
						cKey2Seek	:= &(cAlias + "->" + cCpoChave)
						If !DbSeek(cKey2Seek)
							If lNoMov
								CtbGrvNoMov(cKey2Seek,dDataIni,cTmpChave)
							ElseIf cTipo == "1"		/// SOMENTE PARA O RAZAO POR CONTA
								/// TRATA OS DADOS PARA A PERGUNTA "IMPRIME CONTA SEM MOVIMENTO" = "NAO C/ SLD.ANT."
								If SaldoCT7Fil(cKey2Seek,dDataIni,cMoeda,cSaldo,'CTBR400')[6] <> 0 .and. cArqTMP->CONTA <> cKey2Seek
									/// SE TIVER SALDO ANTERIOR E N�O TIVER MOVIMENTO GRAVADO
									CtbGrvNoMov(cKey2Seek,dDataIni,cTmpChave)
								Endif
							EndIf
						Endif
						DbSelectArea(cAlias)
						DbSkip()
					EndDo
				Endif
				DbSelectArea(cAlias)
				DbClearFil()
				DbSelectArea(cAlias)
				dbCloseArea()

			NEXT //nX := 1 to Len(aSelFil)

			//restaurar cfilant
			cFilAnt := cFil_Save

		EndIf

	Endif

	CtbTmpErase(cTmpCT2Fil)

Else

	//todo o processamento e carga do temporario sera feito no banco
	If !Empty(cUFilter)
		cUFilter := ADMParSQL(cUFilter)
	EndIf
	if __lBlind
	CtbAuxRazao(@cContaIni,@cContaFim,@cCustoIni,@cCustoFim,;
				@cItemIni,@cItemFim,@cCLVLIni,@cCLVLFim,@cMoeda,@dDataIni,@dDataFim,;
				@aSetOfBook,@lNoMov,@cSaldo,@lJunta,@cTipo,@c2Moeda,@nTipo,@cUFilter,@lSldAnt,@aSelFil,@lExterno,@cArqTmp)
	else
			FWMsgRun(, {|oSay| CtbAuxRazao(@cContaIni,@cContaFim,@cCustoIni,@cCustoFim,;
			@cItemIni,@cItemFim,@cCLVLIni,@cCLVLFim,@cMoeda,@dDataIni,@dDataFim,;
			@aSetOfBook,@lNoMov,@cSaldo,@lJunta,@cTipo,@c2Moeda,@nTipo,@cUFilter,@lSldAnt,@aSelFil,@lExterno,@cArqTmp,oSay) },;
				"Processando", "Executando Procedure...")	
	endIf

EndIf

RestInter()

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CtbGrvRaz � Autor � Pilar S. Albaladejo   � Data � 05/02/01 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Grava registros no arq temporario - Razao                   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �CtbGrvRaz(lJunta,cMoeda,cSaldo,cTipo)                       ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � ExpL1 = Se Junta CC ou nao                                 ���
���           � ExpC1 = Moeda                                              ���
���           � ExpC2 = Tipo de saldo                                      ���
��            � ExpC3 = Tipo do lancamento                                 ���
���           � c2Moeda = Indica moeda 2 a ser incluida no relatorio       ���
���           � cAliasQry = Alias com o conteudo selecionado do CT2        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function CtbGrvRAZ(lJunta,cMoeda,cSaldo,cTipo,c2Moeda,cAliasCT2,nTipo)

Local cConta
Local cContra
Local cCusto
Local cItem
Local cCLVL
Local cLanc :=DTOS((cAliasCT2)->(CT2_DATA)) //para compara��o de datas
Local cChave   	:= ""
Local lFind   	:= .F.
Local lImpCPartida := GetNewPar("MV_IMPCPAR",.T.) // Se .T.,     IMPRIME Contra-Partida para TODOS os tipos de lan�amento (D�bito, Credito e Partida-Dobrada),
                                                  // se .F., N�O IMPRIME Contra-Partida para NENHUM   tipo  de lan�amento.
Local lNumAsto     := Iif(cPaisLoc == "PAR" .And. CT2->(FieldPos("CT2_NACSEQ")) > 0, .T., .F.)

DEFAULT cAliasCT2	:= "CT2"

lCtbRazBD := CTB400RAZB() 

If !Empty(c2Moeda)
	If cTipo == "1"
		cChave	:=	(cAliasCT2)->(CT2_DEBITO+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)
	Else
    	cChave	:=	(cAliasCT2)->(CT2_CREDIT+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)
	 EndIf
EndIf

If cTipo == "1"
	cConta 	:= (cAliasCT2)->CT2_DEBITO
	cContra	:= (cAliasCT2)->CT2_CREDIT
	cCusto	:= (cAliasCT2)->CT2_CCD
	cItem	:= (cAliasCT2)->CT2_ITEMD
	cCLVL	:= (cAliasCT2)->CT2_CLVLDB
EndIf
If cTipo == "2"
	cConta 	:= (cAliasCT2)->CT2_CREDIT
	cContra := (cAliasCT2)->CT2_DEBITO
	cCusto	:= (cAliasCT2)->CT2_CCC
	cItem	:= (cAliasCT2)->CT2_ITEMC
	cCLVL	:= (cAliasCT2)->CT2_CLVLCR
EndIf

dbSelectArea("cArqTmp")
dbSetOrder(1)
If !Empty(c2Moeda)
	If MsSeek(cChave,.F.)
   		While !Eof() .and.!lFind
			lFind := cCusto==cArqTmp->CCUSTO.and.cItem==cArqTmp->ITEM.and.cCLVL==cArqTmp->CLVL .and. cLanc == Dtos(cArqTmp->DATAL)
			if !lFind
				dbSkip()
			EndIf
		EndDo
		Reclock("cArqTmp",!lFind)
	Else
		RecLock("cArqTmp",.T.)
	EndIf
Else
	RecLock("cArqTmp",.T.)
EndIf


Replace FILIAL		With (cAliasCT2)->CT2_FILIAL
Replace DATAL		With (cAliasCT2)->CT2_DATA
Replace TIPO		With cTipo
Replace LOTE		With (cAliasCT2)->CT2_LOTE
Replace SUBLOTE		With (cAliasCT2)->CT2_SBLOTE
Replace DOC			With (cAliasCT2)->CT2_DOC
Replace LINHA		With (cAliasCT2)->CT2_LINHA
Replace CONTA		With cConta

If lImpCPartida
	Replace XPARTIDA	With cContra
EndIf

Replace CCUSTO		With cCusto
Replace ITEM		With cItem
Replace CLVL		With cCLVL
Replace HISTORICO	With (cAliasCT2)->CT2_HIST
Replace EMPORI		With (cAliasCT2)->CT2_EMPORI
Replace FILORI		With (cAliasCT2)->CT2_FILORI
Replace SEQHIST		With (cAliasCT2)->CT2_SEQHIS
Replace SEQLAN		With (cAliasCT2)->CT2_SEQLAN
If !lCtbRazBD
	Replace NOMOV		With .F.							// Conta com movimento
Else
	if FWIsInCallStack('CTBR400')
		Replace NOMOV		With '0'							// Conta com movimento
	Else
		Replace NOMOV		With .F.							// Conta com movimento
	EndIf
EndIf

If !Empty(__cSegOfi) .And. __cSegOfi != "0"
	Replace SEGOFI With (cAliasCT2)->CT2_SEGOFI// Correlativo para Chile
EndIf

If lNumAsto .and. Type("nTipoRel") <> "U" .and. nTipoRel == 1
	Replace NASIENTO	With (cAliasCT2)->CT2_NACSEQ
EndIf

If Empty(c2Moeda)	//Se nao for Razao em 2 Moedas
	If cTipo == "1"
		Replace LANCDEB	With LANCDEB + (cAliasCT2)->CT2_VALOR
	EndIf
	If cTipo == "2"
		Replace LANCCRD	With LANCCRD + (cAliasCT2)->CT2_VALOR
	EndIf
	If (cAliasCT2)->CT2_DC == "3"
		Replace TIPO	With cTipo
	Else
		Replace TIPO 	With (cAliasCT2)->CT2_DC
	EndIf
Else	//Se for Razao em 2 Moedas
	If (nTipo = 1 .Or. nTipo = 3) .And. (cAliasCT2)->CT2_MOEDLC = cMoeda //Se Imprime Valor na Moeda ou ambos
		If cTipo == "1"
			Replace LANCDEB With (cAliasCT2)->CT2_VALOR
		Else
			Replace LANCCRD With (cAliasCT2)->CT2_VALOR
		EndIf
	EndIf
    If (nTipo = 2 .Or. nTipo = 3) .And. (cAliasCT2)->CT2_MOEDLC = c2Moeda	//Se Imprime Moeda Corrente ou Ambas
		If cTipo == "1"
			Replace LANCDEB_1	With (cAliasCT2)->CT2_VALOR
		Else
			Replace LANCCRD_1	With (cAliasCT2)->CT2_VALOR
		Endif
	EndIf
	If LANCDEB_1 <> 0 .And. LANCDEB <> 0
		Replace TXDEBITO  	With LANCDEB_1 / LANCDEB
	Endif
	If LANCCRD_1 <> 0 .And. LANCCRD <> 0
		Replace TXCREDITO 	With LANCCRD_1 / LANCCRD
	EndIf
	If (cAliasCT2)->CT2_DC == "3"
		Replace TIPO	With cTipo
	Else
		Replace TIPO 	With (cAliasCT2)->CT2_DC
	EndIf
EndIf

If nTipo = 1 .And. (LANCDEB + LANCCRD) = 0
	DbDelete()
ElseIf nTipo = 2 .And. (LANCDEB_1 + LANCCRD_1) = 0
	DbDelete()
Endif
If ! Empty(c2Moeda) .And. LANCDEB + LANCDEB_1 + LANCCRD + LANCCRD_1 = 0
	DbDelete()
Endif
MsUnlock()

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CtbGrvNoMov � Autor � Pilar S. Albaladejo � Data � 05/02/01 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Grava registros no arq temporario sem movimento.            ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �CtbGrvNoMov(cConta)                                         ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � cConteudo = Conteudo a ser gravado no campo chave de acordo���
���           �             com o razao impresso                           ���
���           � dDataL = Data para verificacao do movimento da conta       ���
���           � cCpoChave = Nome do campo para gravacao no temporario      ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function CtbGrvNoMov(cConteudo,dDataL,cCpoTmp)

dbSelectArea("cArqTmp")
dbSetOrder(1)

RecLock("cArqTmp",.T.)
Replace FILIAL      With xFilial( 'CT2' )
Replace &(cCpoTmp)	With cConteudo
If cCpoTmp = "CONTA"
	Replace HISTORICO		With STR0021		//"CONTA SEM MOVIMENTO NO PERIODO"
ElseIf cCpoTmp = "CCUSTO"
	Replace HISTORICO		With Upper(AllTrim(CtbSayApro("CTT"))) + " "  + STR0026	//"SEM MOVIMENTO NO PERIODO"
ElseIf cCpoTmp = "ITEM"
	Replace HISTORICO		With Upper(AllTrim(CtbSayApro("CTD"))) + " "  + STR0026	//"SEM MOVIMENTO NO PERIODO"
ElseIf cCpoTmp = "CLVL"
	Replace HISTORICO		With Upper(AllTrim(CtbSayApro("CTH"))) + " "  + STR0026	//"SEM MOVIMENTO NO PERIODO"
Endif
Replace DATAL 			WITH dDataL
// Grava filial do sistema para uso no relatorio
Replace FILORI		With cFilAnt
MsUnlock()

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �Ctr400Sint� Autor � Pilar S. Albaladejo   � Data � 05/02/01 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Imprime conta sintetica da conta do razao                   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �Ctr400Sint( cConta,cDescSint,cMoeda,cDescConta,cCodRes	   ���
���		      |		   	 , cMoedaDesc)									   ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Conta Sintetic		                                       ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � ExpC1 = Conta                                              ���
���           � ExpC2 = Descricao da Conta Sintetica                       ���
���           � ExpC3 = Moeda                                              ���
���           � ExpC4 = Descricao da Conta                                 ���
���           � ExpC5 = Codigo reduzido                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function Ctr400Sint(cConta,cDescSint,cMoeda,cDescConta,cCodRes,cMoedaDesc)

Local aSaveArea := GetArea()

Local nPosCT1					//Guarda a posicao no CT1
Local cContaPai	:= ""
Local cContaSint	:= ""

// seta o default da descri��o da moeda para a moeda corrente
Default cMoedaDesc := cMoeda

//dbSelectArea("CT1")
CT1->(dbSetOrder(1))
If CT1->(MsSeek(xFilial("CT1")+cConta))
	nPosCT1 	:= CT1->(Recno())
	cDescConta  := &("CT1->CT1_DESC" + cMoedaDesc )

	If Empty( cDescConta )
		cDescConta  := CT1->CT1_DESC01
	Endif

	cCodRes		:= CT1->CT1_RES
	cContaPai	:= CT1->CT1_CTASUP

	If CT1->(MsSeek(xFilial("CT1")+cContaPai))
		cContaSint 	:= CT1->CT1_CONTA
		cDescSint	:= &("CT1->CT1_DESC" + cMoedaDesc )

		If Empty(cDescSint)
			cDescSint := CT1->CT1_DESC01
		Endif
	EndIf

	CT1->(MsGoto(nPosCT1))
EndIf

RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea := nil 


Return cContaSint

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CtbQryRaz � Autor � Simone Mie Sato       � Data � 22/01/04 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Realiza a "filtragem" dos registros do Razao                ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �CtbQryRaz(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,	   ���
���			  �	cCustoIni,cCustoFim, cItemIni,cItemFim,cCLVLIni,cCLVLFim,  ���
���			  �	cMoeda,dDataIni,dDataFim,aSetOfBook,lNoMov,cSaldo,lJunta,  ���
���			  �	cTipo)                                                     ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � ExpO1 = Objeto oMeter                                      ���
���           � ExpO2 = Objeto oText                                       ���
���           � ExpO3 = Objeto oDlg                                        ���
���           � ExpL1 = Acao do Codeblock                                  ���
���           � ExpC2 = Conta Inicial                                      ���
���           � ExpC3 = Conta Final                                        ���
���           � ExpC4 = C.Custo Inicial                                    ���
���           � ExpC5 = C.Custo Final                                      ���
���           � ExpC6 = Item Inicial                                       ���
���           � ExpC7 = Cl.Valor Inicial                                   ���
���           � ExpC8 = Cl.Valor Final                                     ���
���           � ExpC9 = Moeda                                              ���
���           � ExpD1 = Data Inicial                                       ���
���           � ExpD2 = Data Final                                         ���
���           � ExpA1 = Matriz aSetOfBook                                  ���
���           � ExpL2 = Indica se imprime movimento zerado ou nao.         ���
���           � ExpC10= Tipo de Saldo                                      ���
���           � ExpL3 = Indica se junta CC ou nao.                         ���
���           � ExpC11= Tipo do lancamento                                 ���
���           � c2Moeda = Indica moeda 2 a ser incluida no relatorio       ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function CtbQryRaz(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
				  cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
				  aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,c2Moeda,cUFilter,lSldAnt,aSelFil,lExterno)

Local aSaveArea := GetArea()
Local nMeter	:= 0
Local cQuery	:= ""
Local aTamVlr	:= TAMSX3("CT2_VALOR")
Local lNoMovim	:= .F.
Local cContaAnt	:= ""
Local cCampUSU	:= ""
local aStrSTRU	:= {}
Local nStr			:= 0
Local cQryFil		:= '' // variavel de condicional da query
Local lImpCPartida := GetNewPar( "MV_IMPCPAR" , .T.)	// Se .T.,     IMPRIME Contra-Partida para TODOS os tipos de lan�amento (D�bito, Credito e Partida-Dobrada),
														// se .F., N�O IMPRIME Contra-Partida para NENHUM   tipo  de lan�amento.
Local cContaRang		:= ""
Local cCentroRang		:= ""
Local cItemRang			:= ""
Local cClasRang			:= ""
Local nRange			:= 0
Local nSeq			    := 1
Local cTmpCT2Fil
Local lNumAsto     := Iif(cPaisLoc == "PAR" .And. CT2->(FieldPos("CT2_NACSEQ")) > 0, .T., .F.)
Local lAutomR400   := FWIsInCallStack("UTSTARTRPT") .And. cPerg == "CTR400"
Local lAutomR440   := FWIsInCallStack("UTSTARTRPT") .And. cPerg == "CTR440"
Local oPrepared    :=  NIL
Local lExclusivo   := .F.
Local lComparFil   := .F. //Somente compartilhado por Filial
Local lCT2EmpExc	:= FwModeAccess("CT2", 1) == "E"
Local lCT2UniExc	:= FwModeAccess("CT2", 2) == "E"
Local lCT2FilExc 	:= FwModeAccess("CT2", 3) == "E"
Local aSelxfil 		:= {}
DEFAULT lSldAnt 	:= .F.
DEFAULT aSelFil 	:= {}
DEFAULT lExterno	:= .F.
SaveInter()//Usado o Save Inter para salvar as Variaveis
 
If (FWIsInCallStack("CTBR400") .OR. lAutomR400) .And. !(cPaisLoc $ "PER")

	Pergunte(cPerg,.F.)

	//Carregando a Fun��o do MakeSQL
	MakeSQLEXPR(cPerg)

	nRange      := MV_PAR38
	cContaRang  := MV_PAR39
	cCentroRang := MV_PAR40
	cItemRang   := MV_PAR41
	cClasRang   := MV_PAR42
ElseIf lAutomR440
	nRange := 1
Else
	nRange := 1
EndIf

lExclusivo := IIF( lCT2EmpExc .And. lCT2UniExc .And. lCT2FilExc, .T., .F. )
lComparFil := IIF( lCT2EmpExc .And. lCT2UniExc .And. !lCT2FilExc, .T., .F. ) //Somente compartilhado por Filial

If lComparFil
	Aeval(aSelFil, {|a| aAdd( aSelxFil, xFilial('CT2',a) ) } ) //Compatibiliza o compartilhamento das filiais selecionadas
EndIf

// trataviva para o filtro de multifiliais - multifilial ser� utilizado o aSelFil no fwpreparament
If len(aSelFil) <= 0 .Or. !lExclusivo
	cQryFil :=  xFilial("CT2") //#1
EndIf

If !lExterno
	oMeter:SetTotal(CT2->(RecCount()))
	oMeter:Set(0)
Endif

cQuery	:= " SELECT CT2_FILIAL FILIAL, CT1_CONTA CONTA, ISNULL(CT2_CCD,'') CUSTO,ISNULL(CT2_ITEMD,'') ITEM, ISNULL(CT2_CLVLDB,'') CLVL, ISNULL(CT2_DATA,'') DDATA, ISNULL(CT2_TPSALD,'') TPSALD, "
cQuery	+= " ISNULL(CT2_DC,'') DC, ISNULL(CT2_LOTE,'') LOTE, ISNULL(CT2_SBLOTE,'') SUBLOTE, ISNULL(CT2_DOC,'') DOC, ISNULL(CT2_LINHA,'') LINHA, ISNULL(CT2_CREDIT,'') XPARTIDA, ISNULL(CT2_HIST,'') HIST, ISNULL(CT2_SEQHIS,'') SEQHIS, ISNULL(CT2_SEQLAN,'') SEQLAN, '1' TIPOLAN, "

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USU�RIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USU�RIO
If !Empty(cUFilter)									//// SE O FILTRO DE USU�RIO NAO ESTIVER VAZIO
	aStrSTRU := CT2->(dbStruct())				//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA
		cCampUSU += aStrSTRU[nStr][1]+","			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY

////////////////////////////////////////////////////////////
cQuery  += " ISNULL(CT2_VALOR,0) VALOR, ISNULL(CT2_EMPORI,'') EMPORI, ISNULL(CT2_FILORI,'') FILORI"
If !Empty(__cSegOfi) .And. __cSegOfi != "0"
	cQuery	+= ", ISNULL(CT2_SEGOFI,'') SEGOFI"
EndIf

If lNumAsto .and. nTipoRel == 1
	cQuery	+= ", ISNULL(CT2_NACSEQ,'') NASIENTO"
EndIf
cQuery += Iif( CT1->(FIELDPOS("CT1_DTEXSF")) > 0, ", CT1_DTEXSF", " ")
cQuery += " FROM "+ RetSqlName("CT1") + " CT1 LEFT JOIN " + RetSqlName("CT2") + " CT2 "

If Len(aSelFil) > 0 .And. lExclusivo
	cQuery += " ON CT2.CT2_FILIAL IN (?)" //+ cQryFil //#1
ElseIf Len(aSelFil) > 0 .And. !lExclusivo .And. !lComparFil
	cQuery += " ON CT2.CT2_FILORI IN (?)" //+ cQryFil //#1		
ElseIf Len(aSelFil) > 0 .And. lComparFil //Somente compartilhamento por Filial
	cQuery += " ON CT2.CT2_FILIAL IN (?)" //+ cQryFil //#1
else 
	cQuery += " ON CT2.CT2_FILIAL = ?" //+ cQryFil //#1
EndIf

cQuery	+= " AND CT2.CT2_DEBITO = CT1.CT1_CONTA"
cQuery  += " AND CT2.CT2_DATA >= ? AND CT2.CT2_DATA <= ?" //#2 #3

If(nRange == 2)
		If(!Empty(cCentroRang))
			cQuery += " AND "+ cCentroRang
		EndIf

		If(!Empty(cClasRang))
			cQuery += " AND " + cClasRang 
		EndIf

		if(!Empty(cItemRang))
			cQuery+= " AND " + cItemRang 
		EndIf
Else
	cQuery  += " AND CT2.CT2_CCD >= '" + cCustoIni + "' AND CT2.CT2_CCD <= '" + cCustoFim +"'"
	cQuery  += " AND CT2.CT2_ITEMD >= '" + cItemIni + "' AND CT2.CT2_ITEMD <= '"+ cItemFim +"'"
	cQuery  += " AND CT2.CT2_CLVLDB >= '" + cClvlIni + "' AND CT2.CT2_CLVLDB <= '" + cClVlFim +"'"
EndIf

cQuery  += " AND CT2.CT2_TPSALD = ?"//+ cSaldo + "'" //#4
cQuery	+= " AND CT2.CT2_MOEDLC = ?"// + cMoeda +"'" //#5
cQuery  += " AND (CT2.CT2_DC = '1' OR CT2.CT2_DC = '3') "
cQuery  += " AND CT2_VALOR <> 0 "
cQuery	+= " AND CT2.D_E_L_E_T_ = ' ' "
cQuery	+= " WHERE CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
cQuery	+= " AND CT1.CT1_CLASSE = '2' "

If(!Empty(cContaRang) .And. nRange == 2)
	cQuery += "AND " + STRTRAN(cContaRang,'CT2_DEBITO','CT1_CONTA')
Else
	cQuery	+= " AND CT1.CT1_CONTA >= '"+ cContaIni+"' AND CT1.CT1_CONTA <= '"+cContaFim+"'"
Endif

cQuery	+= " AND CT1.D_E_L_E_T_ = '' "

cQuery	+= " UNION ALL "

cQuery	+= " SELECT CT2_FILIAL FILIAL, CT1_CONTA CONTA, ISNULL(CT2_CCC,'') CUSTO, ISNULL(CT2_ITEMC,'') ITEM, ISNULL(CT2_CLVLCR,'') CLVL, ISNULL(CT2_DATA,'') DDATA, ISNULL(CT2_TPSALD,'') TPSALD, "
cQuery	+= " ISNULL(CT2_DC,'') DC, ISNULL(CT2_LOTE,'') LOTE, ISNULL(CT2_SBLOTE,'')SUBLOTE, ISNULL(CT2_DOC,'') DOC, ISNULL(CT2_LINHA,'') LINHA, ISNULL(CT2_DEBITO,'') XPARTIDA, ISNULL(CT2_HIST,'') HIST, ISNULL(CT2_SEQHIS,'') SEQHIS, ISNULL(CT2_SEQLAN,'') SEQLAN, '2' TIPOLAN, "

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USU�RIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USU�RIO
If !Empty(cUFilter)									//// SE O FILTRO DE USU�RIO NAO ESTIVER VAZIO
	aStrSTRU := CT2->(dbStruct())				//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA
		cCampUSU += aStrSTRU[nStr][1]+","			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif

cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY

cQuery  += " ISNULL(CT2_VALOR,0) VALOR, ISNULL(CT2_EMPORI,'') EMPORI, ISNULL(CT2_FILORI,'') FILORI"
If !Empty(__cSegOfi) .And. __cSegOfi != "0"
	cQuery	+= ", ISNULL(CT2_SEGOFI,'') SEGOFI"
EndIf

If lNumAsto .and. nTipoRel == 1
	cQuery	+= ", ISNULL(CT2_NACSEQ,'') NASIENTO"
EndIf
cQuery += Iif(CT1->(FIELDPOS("CT1_DTEXSF")) > 0, ", CT1_DTEXSF", " ")

cQuery += " FROM "+RetSqlName("CT1")+ ' CT1 LEFT JOIN '+ RetSqlName("CT2") + ' CT2 '

If Len(aSelFil) > 0 .And. lExclusivo
	cQuery += " ON CT2.CT2_FILIAL IN (?)" //+ cQryFil
ElseIf Len(aSelFil) > 0 .And. !lExclusivo .And. !lComparFil
	cQuery += " ON CT2.CT2_FILORI IN (?)" //+ cQryFil //#1		
ElseIf Len(aSelFil) > 0 .And. lComparFil //Somente compartilhado por Filial
	cQuery += " ON CT2.CT2_FILIAL IN (?)" //+ cQryFil //#1	
else 
	cQuery += " ON CT2.CT2_FILIAL = ?" //+ cQryFil 
EndIf

cQuery	+= " AND CT2.CT2_CREDIT =  CT1.CT1_CONTA "
cQuery  += " AND CT2.CT2_DATA >= ? AND CT2.CT2_DATA <= ?" //#6 //#7

If(nRange == 2)
	If(!Empty(cCentroRang))
		cQuery += " AND " + STRTRAN(cCentroRang,'CT2_CCD','CT2_CCC')
	EndIf
	If(!Empty(cClasRang))
		cQuery += " AND " + STRTRAN(cClasRang,'CT2_CCD','CT2_CCC')
	EndIf
	if(!Empty(cItemRang))
		cQuery+= " AND " + STRTRAN(cItemRang,'CT2_ITEMD','CT2_ITEMC')
	EndIf
Else
	cQuery  += " AND CT2.CT2_CCC >= '" + cCustoIni + "' AND CT2.CT2_CCC <= '" + cCustoFim +"'"
	cQuery  += " AND CT2.CT2_ITEMC >= '" + cItemIni + "' AND CT2.CT2_ITEMC <= '"+ cItemFim +"'"
	cQuery  += " AND CT2.CT2_CLVLCR >= '" + cClvlIni + "' AND CT2.CT2_CLVLCR <= '" + cClVlFim +"'"
EndIf

cQuery  += " AND CT2.CT2_TPSALD = ?"//+ cSaldo + "'" //#8
cQuery	+= " AND CT2.CT2_MOEDLC = ?"// + cMoeda +"'" //#9
cQuery  += " AND (CT2.CT2_DC = '2' OR CT2.CT2_DC = '3') "
cQuery  += " AND CT2_VALOR <> 0 "
cQuery	+= " AND CT2.D_E_L_E_T_ = ' ' "
cQuery	+= " WHERE CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
cQuery	+= " AND CT1.CT1_CLASSE = '2' "

If(!Empty(cContaRang) .And. nRange == 2)
	cQuery += "AND " + STRTRAN(cContaRang,'CT2_DEBITO','CT1_CONTA')
Else
	cQuery	+= " AND CT1.CT1_CONTA >= '"+ cContaIni+"' AND CT1.CT1_CONTA <= '"+cContaFim+"'"
Endif

cQuery	+= " AND CT1.D_E_L_E_T_ = ''"
If FunName() <> "CTBR440"
	cQuery  += " ORDER BY CONTA, DDATA"
EndIf

oPrepared := FWPreparedStatement():New(cQuery)
If Len(aSelFil) > 0 .And. !lComparFil
	oPrepared:SetIn( nSeq, aSelFil	) //#1
ElseIf Len(aSelFil) > 0 .And. lComparFil //Somente compartilhado por Filial
	oPrepared:SetIn( nSeq, aSelxFil	) //#1
else
	oPrepared:SetString( nSeq, cQryFil	) //#1
EndIf

nSeq++
oPrepared:SetString( nSeq++, DTOS(dDataIni)	) //#2
oPrepared:SetString( nSeq++, DTOS(dDataFim)	) //#3

oPrepared:SetString( nSeq++,cSaldo	) //#4
oPrepared:SetString( nSeq++,cMoeda	) //#5

If Len(aSelFil) > 0  .And. !lComparFil
	oPrepared:SetIn( nSeq++,aSelFil	) //#1
ElseIf Len(aSelFil) > 0 .And. lComparFil //Somente compartilhado por Filial
	oPrepared:SetIn( nSeq++, aSelxFil	) //#1
else
	oPrepared:SetString( nSeq++,cQryFil	) //#1
EndIf

oPrepared:SetString( nSeq++,DTOS(dDataIni)	) //#6
oPrepared:SetString( nSeq++,DTOS(dDataFim)	) //#7

oPrepared:SetString( nSeq++,cSaldo	)  //#8
oPrepared:SetString( nSeq++,cMoeda	) //#9

cQuery := oPrepared:GetFixQuery()

If Select("cArqCT2") > 0
	dbSelectArea("cArqCT2")
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"cArqCT2",.T.,.F.)

TcSetField("cArqCT2","CT2_VLR"+cMoeda,"N",aTamVlr[1],aTamVlr[2])
TcSetField("cArqCT2","DDATA","D",8,0)
If(CT1->(FieldPos("CT1_DTEXSF")) > 0 ,TcSetField("cArqCT2","CT1_DTEXSF","D",8,0),nil)

If !Empty(cUFilter)									//// SE O FILTRO DE USU�RIO NAO ESTIVER VAZIO
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA
		If aStrSTRU[nStr][2] <> "C" .and. cArqCT2->(FieldPos(aStrSTRU[nStr][1])) > 0
			TcSetField("cArqCT2",aStrSTRU[nStr][1],aStrSTRU[nStr][2],aStrSTRU[nStr][3],aStrSTRU[nStr][4])
		EndIf
	Next
Endif

dbSelectarea("cArqCT2")

If Empty(cUFilter)
	cUFilter := ".T."
Endif

While cArqCT2->(!Eof())
	If Empty(cArqCT2->DDATA) //Se nao existe movimento
		cContaAnt	:= cArqCT2->CONTA
		cArqCT2->(dbSkip())
		If Empty(cArqCT2->DDATA) .And. cContaAnt == cArqCT2->CONTA
			lNoMovim	:= .T.
		EndIf
	Endif

	If &("cArqCT2->("+cUFilter+")")
		If lNoMovim
			If lNoMov
				If CtbExDtFim("CT1")
					If CtbVlDtFim("cArqCT2",dDataIni,'CT1')
						CtbGrvNoMov(cArqCT2->CONTA,dDataIni,"CONTA")	//Esta sendo passado "CONTA" fixo, porque essa funcao esta sendo
					EndIf												//chamada somente para o CTBR400
				Else
					CtbGrvNoMov(cArqCT2->CONTA,dDataIni,"CONTA")	//Esta sendo passado "CONTA" fixo, porque essa funcao esta sendo
				EndIf												//chamada somente para o CTBR400
			ElseIf lSldAnt
				If SaldoCT7Fil(cArqCT2->CONTA, dDataIni, cMoeda, cSaldo, 'CTBR400',,,aSelFil)[6] <> 0 .and. cArqTMP->CONTA <> cArqCT2->CONTA
					CtbGrvNoMov(cArqCT2->CONTA,dDataIni,"CONTA")
				Endif
			EndIf
		Else
			RecLock("cArqTmp",.T.)
		    cArqTmp->FILIAL		:= cArqCT2->FILIAL
		    cArqTmp->DATAL		:= cArqCT2->DDATA
			cArqTmp->TIPO		:= cArqCT2->DC
			cArqTmp->LOTE		:= cArqCT2->LOTE
			cArqTmp->SUBLOTE	:= cArqCT2->SUBLOTE
			cArqTmp->DOC		:= cArqCT2->DOC
			cArqTmp->LINHA		:= cArqCT2->LINHA
			cArqTmp->CONTA		:= cArqCT2->CONTA
			cArqTmp->CCUSTO		:= cArqCT2->CUSTO
			cArqTmp->ITEM		:= cArqCT2->ITEM
			cArqTmp->CLVL		:= cArqCT2->CLVL

			If lImpCPartida
				cArqTmp->XPARTIDA	:= cArqCT2->XPARTIDA
			EndIf

			cArqTmp->HISTORICO	:= cArqCT2->HIST
			cArqTmp->EMPORI		:= cArqCT2->EMPORI
			cArqTmp->FILORI		:= cArqCT2->FILORI
			cArqTmp->SEQHIST	:= cArqCT2->SEQHIS
			cArqTmp->SEQLAN		:= cArqCT2->SEQLAN

			If lNumAsto .and. nTipoRel == 1
				cArqTmp->NASIENTO := cArqCT2->NASIENTO
			EndIf


			If !Empty(__cSegOfi) .And. __cSegOfi != "0"
				cArqTmp->SEGOFI := cArqCT2->SEGOFI // Correlativo para Chile
			EndIf

			If cArqCT2->TIPOLAN = '1'
				cArqTmp->LANCDEB += cArqCT2->VALOR
			EndIf
			If cArqCT2->TIPOLAN = '2'
				cArqTmp->LANCCRD += cArqCT2->VALOR
			EndIf
			cArqTmp->(MsUnlock())
		Endif
	EndIf
	lNoMovim	:= .F.
	dbSelectArea("cArqCT2")
	cArqCT2->(dbSkip())
	nMeter++

	If !lExterno
		oMeter:Set(nMeter)
	Endif

Enddo

CtbTmpErase(cTmpCT2Fil)
RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea := nil 
RestInter()
Return

//-------------------------------------------------------------------
/*{Protheus.doc} CTBRazClean
Fun��o respons�vel por limpar os arquivos tempor�rio do banco das fun��es do raz�o

@author Simone Mie Sato Kakinoana

@version P12
@since   01/11/2016
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CTBRazClean()

If _oCTBR400 <> Nil
	_oCTBR400:Delete()
	_oCTBR400 := Nil
Endif

Return



//-------------------------------------------------------------------
/*{Protheus.doc}CTBR400
Relatorio Razao - Criar temporario no banco e popular via procedure
Static Function CtbAuxRazao
@author Paulo Carnelossi - Totvs
@since  04/11/2015
@version 11.8
*/
//-------------------------------------------------------------------
Static Function CtbAuxRazao(	cContaIni,cContaFim,cCustoIni,cCustoFim,;
								cItemIni,cItemFim,cCLVLIni,cCLVLFim,;
								cMoeda,dDataIni,dDataFim,;
								aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,;
								c2Moeda,nTipo,cUFilter,lSldAnt,aSelFil,lExterno,cArqTmp,oSay)

Local cTmpCT2Fil
Local cTmpCT1Fil
Local cTmpCTTFil
Local cTmpCTDFil
Local cTmpCTHFil
Local cGetRngFil := ""
Local cRngFilCT1 := ""
Local cRngCTTFil := ""
Local cRngCTDFil := ""
Local cRngCTHFil := ""
Local aStru
Local cProcCT2   := ""
Local cNomProc   := ""
Local aCposCT2   := {}
Local aVarsCT2   := {}
Local lUFilter	:= !Empty(cUFilter)	// SE O FILTRO DE USU�RIO N�O ESTIVER VAZIO - TEM FILTRO DE USU�RIO
Local nX

Local cContaI	:= ""
Local cContaF	:= ""
Local cCustoI	:= ""
Local cCustoF	:= ""
Local cItemI	:= ""
Local cItemF	:= ""
Local cClVlI	:= ""
Local cClVlF	:= ""
Local lExclusivo := .F.
Local aResult := {}
Local cCommit := ""
Local cRealTmp  := ""
Local nTamFil   := TamSX3("CT1_FILIAL")[1]
Local nTamEnt   := 0

If (Alltrim(UPPER(TcGetDb())) $ "MSSQL7||ORACLE||POSTGRES" )
	//Fun��o nova
	 CtbNewAuxRazao(	cContaIni,cContaFim,cCustoIni,cCustoFim,;
								cItemIni,cItemFim,cCLVLIni,cCLVLFim,;
								cMoeda,dDataIni,dDataFim,;
								aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,;
								c2Moeda,nTipo,cUFilter,lSldAnt,aSelFil,lExterno,cArqTmp)   
Else

If (Alltrim(UPPER(TcGetDb())) $ "MSSQL7" )
	cCommit := "Commit Tran"
ElseIf (Alltrim(UPPER(TcGetDb())) $ "ORACLE||DB2" )
	cCommit := "Commit"
ElseIf (Alltrim(UPPER(TcGetDb())) = "INFORMIX" )
	cCommit := "COMMIT WORK"
EndIf

If Empty(aSelFil)
	aAdd(aSelFil, cFilAnt)
EndIf

cContaI	:= CCONTAINI
cContaF := CCONTAFIM
cCustoI	:= CCUSTOINI
cCustoF := CCUSTOFIM
cItemI	:= CITEMINI
cItemF 	:= CITEMFIM
cClvlI	:= CCLVLINI
cClVlF 	:= CCLVLFIM

cGetRngFil := GetRngFil( aSelFil ,"CT2", .T., @cTmpCT2Fil, 0, , @cRealTmp)  //0 ultimo param forca criacao no banco de dados, pois vai utilizar a tabela
cRngFilCT1 := GetRngFil( aSelFil ,"CT1", .T., @cTmpCT1Fil)
cRngCTTFil := GetRngFil( aSelFil ,"CT1", .T., @cTmpCTTFil)
cRngCTDFil := GetRngFil( aSelFil ,"CT1", .T., @cTmpCTDFil)
cRngCTHFil := GetRngFil( aSelFil ,"CT1", .T., @cTmpCTHFil)

lExclusivo := !Empty(xFilial("CT2"))

If cTipo <> "1"

	If Len(aSelFil) == 0 .OR. ( Len(aSelFil) == 1 .And. aSelFil[1]==cFilAnt)
		If cTipo = "2" .And. Empty(cCustoIni)
			CTT->(DbSeek(xFilial("CTT")))
			cCustoIni := CTT->CTT_CUSTO
		Endif
		If cTipo = "3" .And. Empty(cItemIni)
			CTD->(DbSeek(xFilial("CTD")))
			cItemIni := CTD->CTD_ITEM
		Endif
		If cTipo = "4" .And. Empty(cClVlIni)
			CTH->(DbSeek(xFilial("CTH")))
			cClVlIni := CTH->CTH_CLVL
		Endif
	Else
		If cTipo = "2" .And. Empty(cCustoIni)
			cCustoIni := PadR( cCustoIni ,Len(CTT->CTT_CUSTO) )
		Endif
		If cTipo = "3" .And. Empty(cItemIni)
			cItemIni := PadR( cItemIni ,Len(CTD->CTD_ITEM) )
		Endif
		If cTipo = "4" .And. Empty(cClVlIni)
			cClVlIni := PadR( cClVlIni ,Len(CTH->CTH_CLVL) )
		Endif
	EndIf
Endif

aStru := CT2->(dbStruct())

CtbR400Cpos(aCposCT2, aStru)   //array campos da CT2
CtbR400Vars(aVarsCT2, aStru)   //variaveis para uso na procedure /cursor

cNomProc := CriaTrab(,.F.)+"_"+cEmpAnt

cProcCT2 := "CREATE PROCEDURE "+cNomProc+"( "+CRLF
cProcCT2 += "  @OUT_RET 		char(1) output" +CRLF
cProcCT2 += " ) as "+ CRLF
cProcCT2 += " "+ CRLF

//declara as variaveis
CtbR400Decl(@cProcCT2, aStru)

//variaveis que serao utilizada na funcao CtbAuxGrvRAZ
cProcCT2 += "Declare @iRecno int "+ CRLF
cProcCT2 += "Declare @cConta Char("+Alltrim(Str(Len(CT2->CT2_DEBITO)))+") "+CRLF
cProcCT2 += "Declare @cContra Char("+Alltrim(Str(Len(CT2->CT2_DEBITO)))+") "+CRLF
cProcCT2 += "Declare @cCusto Char("+Alltrim(Str(Len(CT2->CT2_CCD)))+") "+CRLF
cProcCT2 += "Declare @cItem Char("+Alltrim(Str(Len(CT2->CT2_ITEMD)))+") "+CRLF
cProcCT2 += "Declare @cCLVL Char("+Alltrim(Str(Len(CT2->CT2_CLVLDB)))+") "+CRLF
//variaveis para segundo cursor na funcao CtbAuxGrvRaz
cProcCT2 += "Declare @cAuxCusto Char("+Alltrim(Str(Len(CT2->CT2_CCD)))+") "+CRLF
cProcCT2 += "Declare @cAuxItem Char("+Alltrim(Str(Len(CT2->CT2_ITEMD)))+") "+CRLF
cProcCT2 += "Declare @cAuxClvl Char("+Alltrim(Str(Len(CT2->CT2_CLVLDB)))+") "+CRLF
cProcCT2 += "Declare @iAuxRecno int "+ CRLF
cProcCT2 += "Declare @iInclui int "+CRLF
cProcCT2 += "Declare @nLancDeb float"+CRLF
cProcCT2 += "Declare @nLancCrd float"+CRLF
cProcCT2 += "Declare @nLancDeb_1 float"+CRLF
cProcCT2 += "Declare @nLancCrd_1 float"+CRLF
cProcCT2 += "Declare @nTxDebito float"+CRLF
cProcCT2 += "Declare @nTxCredito float"+CRLF
cProcCT2 += "Declare @cDelet_ char(1)"+CRLF
cProcCT2 += "Declare @iRecnoCT2 int"+CRLF
cProcCT2 += "Declare @nSaldoAnt float"+CRLF
cProcCT2 += "Declare @nAntDeb float"+CRLF
cProcCT2 += "Declare @nAntCred float"+CRLF
cProcCT2 += "Declare @iCommit    integer"+CRLF
cProcCT2 += "Declare @iTranCount integer"+CRLF  // Ser� substituida por commit ap�s passar pelo Msparse
cProcCT2 += "Declare @cHistCT2 varchar("+cValToChar(nR400Char)+")"+CRLF  // Radu
cProcCT2 += "Declare @cFilial char(" + Alltrim(Str(Len(CT2->CT2_FILIAL))) + ")"+CRLF  // Radu
cProcCT2 += "DECLARE @cContaHist Char(" + Alltrim(Str(Len(CT2->CT2_DEBITO))) + ")"+CRLF
cProcCT2 += "Declare @cData char(8)"+CRLF  // Radu
cProcCT2 += "Declare @cLote char(" + Alltrim(Str(Len(CT2->CT2_LOTE))) + ")" + CRLF  // Radu
cProcCT2 += "Declare @cSubLote char(" + Alltrim(Str(Len(CT2->CT2_SBLOTE))) + ")" + CRLF  // Radu
cProcCT2 += "Declare @cDoc char(" + Alltrim(Str(Len(CT2->CT2_DOC))) + ")" + CRLF  // Radu
cProcCT2 += "Declare @cSeqLan char(" + Alltrim(Str(Len(CT2->CT2_SEQLAN))) + ")" + CRLF  // Radu
cProcCT2 += "DECLARE @cHistCT2FIM  varchar("+cValToChar(nR400Char)+")"  + CRLF  
cProcCT2 += "DECLARE @iRecnoTmp Integer " + CRLF  
cProcCT2 += "DECLARE @iRecnoTmpAnt Integer " + CRLF  
cProcCT2 += "DECLARE @cHistOri  varchar("+cValToChar(nR400Char)+")"+ CRLF  

//inicio do processamento
cProcCT2 += "Begin " + CRLF
cProcCT2 += "   " + CRLF
cProcCT2 += "	select @OUT_RET = '0' " + CRLF
cProcCT2 += "	select @iCommit = 0" + CRLF
cProcCT2 += "	select @iRecno = 0" + CRLF
cProcCT2 += "	select @nAntDeb = 0" + CRLF
cProcCT2 += "	select @nAntCred = 0" + CRLF

//declaracao do cursor
cProcCT2 += "	Declare cCursor insensitive cursor for" + CRLF
cProcCT2 += "	Select "

//campos da select
For nX := 1 TO Len(aCposCT2)
	cProcCT2 += aCposCT2[nX]+", "
Next

cProcCT2 += "	R_E_C_N_O_ " + CRLF
cProcCT2 += "	From " + RetSqlName("CT2") + CRLF
cProcCT2 += "	Where CT2_FILIAL " + cGetRngFil+CRLF

//-------------------------//
//  Obtem os debitos       //
//-------------------------//
If cTipo == "1"

	cProcCT2 += "	and CT2_DEBITO >='" + cContaIni + "' "+CRLF
	cProcCT2 += "	and CT2_DEBITO <='" + cContaFim + "' "+CRLF
	cProcCT2 += "	and CT2_CCD    >='" + cCustoIni + "' "+CRLF
	cProcCT2 += "	and CT2_CCD    <='" + cCustoFim + "' "+CRLF
	cProcCT2 += "	and CT2_ITEMD  >='" + cItemIni  + "' "+CRLF
	cProcCT2 += "	and CT2_ITEMD  <='" + cItemFim  + "' "+CRLF
	cProcCT2 += "	and CT2_CLVLDB >='" + cClVlIni  + "' "+CRLF
	cProcCT2 += "	and CT2_CLVLDB <='" + cClVlFim  + "' "+CRLF

ElseIf cTipo == "2"

		If Empty(cCustoIni)
			cProcCT2 += "	and CT2_CCD >  '" + cCustoIni + "' "+CRLF
			cProcCT2 += "	and CT2_CCD <= '" + cCustoFim + "' "+CRLF
		Else
			cProcCT2 += "	 and CT2_CCD >= '" + cCustoIni + "' "+CRLF
			cProcCT2 += "	 and CT2_CCD <= '" + cCustoFim + "' "+CRLF
		EndIf

		cProcCT2 += "	and CT2_DEBITO >= '" + cContaIni + "' "+CRLF
		cProcCT2 += "	and CT2_DEBITO <= '" + cContaFim + "' "+CRLF
		cProcCT2 += "	and CT2_ITEMD  >= '" + cItemIni  + "' "+CRLF
		cProcCT2 += "	and CT2_ITEMD  <= '" + cItemFim  + "' "+CRLF
		cProcCT2 += "	and CT2_CLVLDB >= '" + cClVlIni  + "' "+CRLF
		cProcCT2 += "	and CT2_CLVLDB <= '" + cClVlFim  + "' "+CRLF

ElseIf cTipo == "3"

		If Empty(cItemIni)
			cProcCT2 += "	and CT2_ITEMD > '" + cItemIni  + "' "+CRLF
			cProcCT2 += "	and CT2_ITEMD <= '" + cItemFim + "' "+CRLF
		Else
			cProcCT2 += "	and CT2_ITEMD >= '" + cItemIni + "' "+CRLF
			cProcCT2 += "	and CT2_ITEMD <= '" + cItemFim + "' "+CRLF
		EndIf

		cProcCT2 += "	and CT2_DEBITO >= '" + cContaIni + "' "+CRLF
		cProcCT2 += "	and CT2_DEBITO <= '" + cContaFim + "' "+CRLF
		cProcCT2 += "	and CT2_CCD    >= '" + cCustoIni + "' "+CRLF
		cProcCT2 += "	and CT2_CCD    <= '" + cCustoFim + "' "+CRLF
		cProcCT2 += "	and CT2_CLVLDB >= '" + cClVlIni  + "' "+CRLF
		cProcCT2 += "	and CT2_CLVLDB <= '" + cClVlFim  + "' "+CRLF

ElseIf cTipo == "4"

	If Empty(cClVlIni)
		cProcCT2 += "	and CT2_CLVLDB > '" + cClVlIni  + "' "+CRLF
		cProcCT2 += "	and CT2_CLVLDB <= '" + cClVlFim + "' "+CRLF
	Else
		cProcCT2 += "	and CT2_CLVLDB >= '" + cClVlIni + "' "+CRLF
		cProcCT2 += "	and CT2_CLVLDB <= '" + cClVlFim + "' "+CRLF
	EndIf
		cProcCT2 += "	and CT2_DEBITO >= '" + cContaIni + "' "+CRLF
		cProcCT2 += "	and CT2_DEBITO <= '" + cContaFim + "' "+CRLF
		cProcCT2 += "	and CT2_CCD    >= '" + cCustoIni + "' "+CRLF
		cProcCT2 += "	and CT2_CCD    <= '" + cCustoFim + "' "+CRLF
		cProcCT2 += "	and CT2_ITEMD  >= '" + cItemIni  + "' "+CRLF
		cProcCT2 += "	and CT2_ITEMD  <= '" + cItemFim  + "' "+CRLF

EndIf

If lUFilter			//ADICIONA O FILTRO DEFINIDO PELO USU�RIO SE N�O ESTIVER EM BRANCO
	cProcCT2 += "	and "	// SE J� TIVER CONTEUDO, ADICIONA "AND"
	cProcCT2 += cUFilter // ADICIONA O FILTRO DE USU�RIO  NA SINTAXE SQL
EndIf

cProcCT2	+= "	and CT2_DATA >= '" + DTOS(dDataIni) + "' "+CRLF
cProcCT2	+= "	and CT2_DATA <= '" + DTOS(dDataFim) + "' "+CRLF

If !Empty(c2Moeda)
	cProcCT2	+= "	and ( CT2_MOEDLC = '" + cMoeda  + "' OR "
	cProcCT2	+= " 	CT2_MOEDLC = '" + c2Moeda + "'  ) "
Else
	cProcCT2	+= "	and CT2_MOEDLC = '" + cMoeda  + "' "+CRLF
EndIf

cProcCT2	+= "	 and CT2_TPSALD = '"+ cSaldo + "' "+CRLF
cProcCT2	+= "	and CT2_DC IN ('1','3') "+CRLF
cProcCT2	+= "	and CT2_VALOR <> 0 "+CRLF
cProcCT2	+= "	and D_E_L_E_T_ = ' ' "+CRLF
cProcCT2 += "	Open cCursor "+ CRLF
cProcCT2 += "	Fetch cCursor into "

For nX := 1 TO Len(aVarsCT2)
	cProcCT2 += aVarsCT2[nX]+", "
Next
cProcCT2 += "	@iRecnoCT2 " + CRLF
cProcCT2 += CRLF
cProcCT2 += "	while @@FETCH_STATUS = 0 begin"+CRLF
cProcCT2 += CRLF

CtbAuxGrvRAZ(@cProcCt2,cArqTmp,cMoeda,"1",c2Moeda,nTipo) //"1" = debitos

cProcCT2 += "		If @iCommit >= 10240 begin"+CRLF
cProcCT2 += "			select @iCommit = 0"+CRLF
cProcCT2 += "         	select @iTranCount = 0"+CRLF
cProcCT2 += "      	end"+CRLF
cProcCT2 += "		Fetch cCursor into "

For nX := 1 TO Len(aVarsCT2)
	cProcCT2 += aVarsCT2[nX]+", "
Next

cProcCT2 += "@iRecnoCT2 "
cProcCT2 += + CRLF
cProcCT2 += "	End "+ CRLF  //finaliza While

//finaliza debito
cProcCT2 += "	If @iCommit > 0 begin"+CRLF
cProcCT2 += "		select @iCommit = 0"+CRLF
cProcCT2 += "		select @iTranCount = 0"+CRLF
cProcCT2 += "	end"+CRLF
cProcCT2 += "	close cCursor"+CRLF
cProcCT2 += "	deallocate cCursor"+CRLF
cProcCT2 += CRLF

//declaracao do cursor para creditos
cProcCT2 += "	Declare cCursor3 insensitive cursor for" + CRLF
cProcCT2 += "	SELECT "

//campos da select
For nX := 1 TO Len(aCposCT2)
	cProcCT2 += aCposCT2[nX]+", "
Next
cProcCT2 += "R_E_C_N_O_ "+CRLF
cProcCT2 += "	FROM "+RetSqlName("CT2")+CRLF
cProcCT2 += "	WHERE "
cProcCT2 += "	CT2_FILIAL " + cGetRngFil+CRLF

//obtem creditos
If cTipo == "1"

	cProcCT2 += "	and CT2_CREDIT >='" + cContaIni + "' "+CRLF
	cProcCT2 += "	and CT2_CREDIT <='" + cContaFim + "' "+CRLF
	cProcCT2 += "	and CT2_CCC    >='" + cCustoIni + "' "+CRLF
	cProcCT2 += "	and CT2_CCC    <='" + cCustoFim + "' "+CRLF
	cProcCT2 += "	and CT2_ITEMC  >='" + cItemIni  + "' "+CRLF
	cProcCT2 += "	and CT2_ITEMC  <='" + cItemFim  + "' "+CRLF
	cProcCT2 += "	and CT2_CLVLCR >='" + cClVlIni  + "' "+CRLF
	cProcCT2 += "	and CT2_CLVLCR <='" + cClVlFim  + "' "+CRLF

ElseIf cTipo == "2"

	If Empty(cCustoIni)
		cProcCT2 += "	and CT2_CCC >  '" + cCustoIni + "' "+CRLF
		cProcCT2 += "	and CT2_CCC <= '" + cCustoFim + "' "+CRLF
	Else
		cProcCT2 += "	and CT2_CCC >= '" + cCustoIni + "' "+CRLF
		cProcCT2 += "	and CT2_CCC <= '" + cCustoFim + "' "+CRLF
	EndIf

	cProcCT2 += "	and CT2_CREDIT >= '" + cContaIni + "' "+CRLF
	cProcCT2 += "	and CT2_CREDIT <= '" + cContaFim + "' "+CRLF
	cProcCT2 += "	and CT2_ITEMC  >= '" + cItemIni  + "' "+CRLF
	cProcCT2 += "	and CT2_ITEMC  <= '" + cItemFim  + "' "+CRLF
	cProcCT2 += "	and CT2_CLVLCR >= '" + cClVlIni  + "' "+CRLF
	cProcCT2 += "	and CT2_CLVLCR <= '" + cClVlFim  + "' "+CRLF

ElseIf cTipo == "3"

	If Empty(cItemIni)
		cProcCT2 += "	and CT2_ITEMC > '" + cItemIni  + "' "+CRLF
		cProcCT2 += "	and CT2_ITEMC <= '" + cItemFim + "' "+CRLF
	Else
		cProcCT2 += "	and CT2_ITEMC >= '" + cItemIni + "' "+CRLF
		cProcCT2 += "	and CT2_ITEMC <= '" + cItemFim + "' "+CRLF
	EndIf

	cProcCT2 += "	and CT2_CREDIT >= '" + cContaIni + "' "+CRLF
	cProcCT2 += "	and CT2_CREDIT <= '" + cContaFim + "' "+CRLF
	cProcCT2 += "	and CT2_CCC    >= '" + cCustoIni + "' "+CRLF
	cProcCT2 += "	and CT2_CCC    <= '" + cCustoFim + "' "+CRLF
	cProcCT2 += "	and CT2_CLVLCR >= '" + cClVlIni  + "' "+CRLF
	cProcCT2 += "	and CT2_CLVLCR <= '" + cClVlFim  + "' "+CRLF

ElseIf cTipo == "4"

	If Empty(cClVlIni)
		cProcCT2 += "	and CT2_CLVLCR > '" + cClVlIni  + "' "+CRLF
		cProcCT2 += "	and CT2_CLVLCR <= '" + cClVlFim + "' "+CRLF
	Else
		cProcCT2 += "      and CT2_CLVLCR >= '" + cClVlIni + "' "+CRLF
		cProcCT2 += "      and CT2_CLVLCR <= '" + cClVlFim + "' "+CRLF
	EndIf
		cProcCT2 += "      and CT2_CREDIT >= '" + cContaIni + "' "+CRLF
		cProcCT2 += "      and CT2_CREDIT <= '" + cContaFim + "' "+CRLF
		cProcCT2 += "      and CT2_CCC    >= '" + cCustoIni + "' "+CRLF
		cProcCT2 += "      and CT2_CCC    <= '" + cCustoFim + "' "+CRLF
		cProcCT2 += "      and CT2_ITEMC  >= '" + cItemIni  + "' "+CRLF
		cProcCT2 += "      and CT2_ITEMC  <= '" + cItemFim  + "' "+CRLF

EndIf

If lUFilter			//ADICIONA O FILTRO DEFINIDO PELO USU�RIO SE N�O ESTIVER EM BRANCO
	cProcCT2 += "	and "	// SE J� TIVER CONTEUDO, ADICIONA "AND"
	cProcCT2 += cUFilter // ADICIONA O FILTRO DE USU�RIO  NA SINTAXE SQL
EndIf

cProcCT2	+= "	and CT2_DATA >= '" + DTOS(dDataIni) + "' "+CRLF
cProcCT2	+= "	and CT2_DATA <= '" + DTOS(dDataFim) + "' "+CRLF

If !Empty(c2Moeda)
	cProcCT2	+= "	and ( CT2_MOEDLC = '" + cMoeda  + "' OR "
	cProcCT2	+= "	CT2_MOEDLC = '" + c2Moeda + "'  ) "
Else
	cProcCT2	+= "	and CT2_MOEDLC = '" + cMoeda  + "' "
EndIf

cProcCT2 += CRLF

cProcCT2	+= "	and CT2_TPSALD = '"+ cSaldo + "' "+CRLF

cProcCT2	+= "	and CT2_DC IN ('2','3') "+CRLF
cProcCT2	+= "	and CT2_VALOR <> 0 "+CRLF
cProcCT2	+= "	and D_E_L_E_T_ = ' ' "+CRLF

cProcCT2 += "	Open cCursor3 "+ CRLF
cProcCT2 += "	Fetch cCursor3 into "

For nX := 1 TO Len(aVarsCT2)
	cProcCT2 += aVarsCT2[nX]+", "
Next
cProcCT2 += "@iRecnoCT2 "
cProcCT2 += + CRLF

cProcCT2 += "	while @@FETCH_STATUS = 0"
cProcCT2 += "		begin"+CRLF
cProcCT2 += CRLF

CtbAuxGrvRAZ(@cProcCt2,cArqTmp,cMoeda,"2",c2Moeda,nTipo)   //"2" = creditos

cProcCT2 += "		If @iCommit >= 10240 begin"+CRLF
cProcCT2 += "			select @iCommit = 0"+CRLF
cProcCT2 += "			select @iTranCount = 0"+CRLF
cProcCT2 += "		end"+CRLF
cProcCT2 += "		Fetch cCursor3 into "

For nX := 1 TO Len(aVarsCT2)
	cProcCT2 += aVarsCT2[nX]+", "
Next

cProcCT2 += "@iRecnoCT2 "

cProcCT2 += + CRLF

cProcCT2 += "	End "+ CRLF  //finaliza While
cProcCT2 += "	If @iCommit > 0 begin"+CRLF
cProcCT2 += "		select @iCommit = 0"+CRLF
cProcCT2 += "		select @iTranCount = 0"+CRLF
cProcCT2 += "	end"+CRLF
cProcCT2 += "	close cCursor3"+CRLF
cProcCT2 += "	deallocate cCursor3"+CRLF

cProcCT2 += CRLF
//CURSOR NO TEMPORARIO PARA PEGAR AS CONTINUACOES DE HISTORICO

If ( nTipoRel <> 3 )

	If FunName() == "CTBR400" .OR. IsInCallStack("CT400Imp")
    cProcCT2 += "SELECT  @cHistCT2FIM = ''   "+ CRLF
	  cProcCT2 += "SELECT @iRecnoTmp = 0 "+ CRLF
	 	cProcCT2 += "SELECT  @iRecnoTmpAnt = 0 " + CRLF
	  cProcCT2 += "SELECT @cHistOri ='' "+ CRLF
		cProcCT2 += "Declare cCursor4 insensitive cursor for" + CRLF

		cProcCT2 += "	 SELECT "
		cProcCT2 += " 	CT2_FILIAL, "
		cProcCT2 += " 	CARQTMP.CONTA, "
		cProcCT2 += " 	CT2_DATA, "
		cProcCT2 += " 	CT2_DC, "
		cProcCT2 += " 	CT2_LOTE, "
		cProcCT2 += " 	CT2_SBLOTE, "
		cProcCT2 += " 	CT2_DOC, "
		cProcCT2 += " 	CT2_LINHA, "
		cProcCT2 += " 	CT2_HIST, "
		cProcCT2 += " 	CT2_EMPORI, "
		cProcCT2 += " 	CT2_FILORI, "
		cProcCT2 += " 	CT2_SEQHIS, "
		cProcCT2 += " 	CT2_SEQLAN  ,CARQTMP.R_E_C_N_O_ "+CRLF
		cProcCT2 += "	  FROM "+cArqTmp+" CARQTMP ,"+RetSqlName("CT2")+ " CT2 "+CRLF
		cProcCT2 += "	  WHERE CT2_FILIAL = FILIAL "+ CRLF
		cProcCT2 += "		AND CT2_DATA = DATAL "+ CRLF
		cProcCT2 += "		AND CT2_LOTE = LOTE "+ CRLF
		cProcCT2 += "		AND CT2_SBLOTE = SUBLOTE "+ CRLF
		cProcCT2 += "		AND CT2_DOC = DOC "+ CRLF
		cProcCT2 += "		AND CT2_SEQLAN = SEQLAN "+ CRLF
		cProcCT2 += "		AND CT2_EMPORI = EMPORI "+ CRLF
		cProcCT2 += "		AND CT2_FILORI = FILORI "+ CRLF
		cProcCT2 += "		AND (CT2_DC = '4' OR (CT2_DC <> '4' AND CT2_SEQHIS = '001' ) ) "+ CRLF    //SOMENTE CONTINUACAO DE HISTORICO
		cProcCT2 += "		AND CT2.D_E_L_E_T_ = ' '  "+ CRLF
	  cProcCT2 += "		AND CT2_MOEDLC = '"+MV_PAR05+"' "+ CRLF
		cProcCT2 += "		AND CARQTMP.D_E_L_E_T_ = ' ' "+ CRLF
		cProcCT2 += "	  ORDER BY CARQTMP.R_E_C_N_O_,CT2_FILIAL, CARQTMP.CONTA, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_SEQHIS "+ CRLF
		cProcCT2 += "	Open cCursor4 "+CRLF
		cProcCT2 += "	Fetch cCursor4 into "
		cProcCT2 += "		@cCT2_FILIAL, "
		cProcCT2 += "		@cConta, "
		cProcCT2 += "		@cCT2_DATA, "
		cProcCT2 += "		@cCT2_DC, "
		cProcCT2 += "		@cCT2_LOTE, "
		cProcCT2 += "		@cCT2_SBLOTE, "
		cProcCT2 += "		@cCT2_DOC, "
		cProcCT2 += "		@cCT2_LINHA, "
		cProcCT2 += "		@cCT2_HIST, "
		cProcCT2 += "		@cCT2_EMPORI, "
		cProcCT2 += "		@cCT2_FILORI, "
		cProcCT2 += "		@cCT2_SEQHIS, "
		cProcCT2 += "		@cCT2_SEQLAN,  @iRecnoTmp "

		cProcCT2 += CRLF

		If ( "MSSQL" $ Upper(TCGetDb()) )
			cProcCT2 += "	SELECT @cHistCT2 = RTRIM( @cCT2_HIST ) " + CRLF
		Else
			cProcCT2 += "	SELECT @cHistCT2 = TRIM( @cCT2_HIST ) " + CRLF
		EndIf

		cProcCT2 += CRLF

		cProcCT2 += "	while @@FETCH_STATUS = 0"
		cProcCT2 += "	begin"+CRLF
		cProcCT2 += CRLF

		//Fernando Radu
	cProcCT2 += "		SELECT @cFilial = @cCT2_FILIAL " + CRLF
	cProcCT2 += "		SELECT @cContaHist = @cConta " + CRLF
	cProcCT2 += "		SELECT @cData = @cCT2_DATA " + CRLF
	cProcCT2 += "		SELECT @cLote = @cCT2_LOTE " + CRLF
	cProcCT2 += "		SELECT @cSubLote = @cCT2_SBLOTE " + CRLF
	cProcCT2 += "		SELECT @cDoc = @cCT2_DOC " + CRLF
	cProcCT2 += "		SELECT @cSeqLan = @cCT2_SEQLAN " + CRLF
	cProcCT2 += "   SELECT @cHistOri =  @cCT2_HIST " +CRLF
	
  cProcCT2 += "   SELECT  @iRecnoTmpAnt  = @iRecnoTmp " + CRLF 
	cProcCT2 += CRLF
	cProcCT2 += "  IF @iRecnoTmp = @iRecnoTmpAnt  BEGIN "+CRLF
	
		If ( "MSSQL" $ Upper(TCGetDb()) )
			cProcCT2 += " 	SELECT @cHistCT2FIM  =  SUBSTRING(@cHistCT2FIM||RTRIM( @cCT2_HIST),1,"+cValToChar(nR400Char)+") " +CRLF
		Else
			cProcCT2 += " 	SELECT @cHistCT2FIM  =  SUBSTRING(@cHistCT2FIM|| TRIM( @cCT2_HIST),1,"+cValToChar(nR400Char)+") " +CRLF
		EndIf

	cProcCT2 += "    END "+CRLF
	cProcCT2 += " 	 FETCH cCursor4 "+CRLF
	cProcCT2 += " 	 INTO @cCT2_FILIAL , @cConta , @cCT2_DATA , @cCT2_DC , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cCT2_LINHA , @cCT2_HIST , " +CRLF
  cProcCT2 += "    @cCT2_EMPORI , @cCT2_FILORI , @cCT2_SEQHIS , @cCT2_SEQLAN,@iRecnoTmp"+CRLF
			 	

   cProcCT2 += " IF  @iRecnoTmp != @iRecnoTmpAnt  BEGIN  "+CRLF
		cProcCT2 += "			BEGIN TRAN " + CRLF
		cProcCT2 += CRLF
		cProcCT2 += "			UPDATE " + CRLF
		cProcCT2 += "				" + cArqTmp + CRLF
		cProcCT2 += "			SET " + CRLF
		cProcCT2 += "			HISTORICO = @cHistCT2FIM " + CRLF
		cProcCT2 += "			WHERE " + CRLF
		cProcCT2 += "		   R_E_C_N_O_ = @iRecnoTmpAnt "
		cProcCT2 += CRLF
		cProcCT2 += "			COMMIT TRAN " + CRLF
	 	cProcCT2 += "     SELECT  @cHistCT2FIM = '' "+ CRLF
		cProcCT2 += "	    End "+ CRLF 
		cProcCT2 += "	    End "+ CRLF  //finaliza While
			cProcCT2 += "   BEGIN TRAN "+ CRLF 
  	cProcCT2 += "     UPDATE "+CRLF
			cProcCT2 += "		 "+ cArqTmp+  CRLF
  	cProcCT2 += "      SET  "
		cProcCT2 += "       HISTORICO  = @cHistCT2FIM "+ CRLF 
  	cProcCT2 += "       WHERE R_E_C_N_O_  = @iRecnoTmpAnt "+ CRLF 
  	cProcCT2 += "         COMMIT TRAN  "+ CRLF
	  
		cProcCT2 += "   If @iCommit > 0 begin"+CRLF
		cProcCT2 += "      select @iCommit = 0"+CRLF
		cProcCT2 += "      select @iTranCount = 0"+CRLF
		cProcCT2 += "	end"+CRLF

		cProcCT2 += "   close cCursor4"+CRLF
		cProcCT2 += "   deallocate cCursor4"+CRLF
		cProcCT2 += CRLF

	EndIf

EndIf

//CURSOR PARA PEGAR AS ENTIDADES SEM MOVIMENTACAO
If lNoMov .or. lSldAnt

	If !lExclusivo   //CT2 COMPARTILHADA
		cProcCT2 += "   Declare cCursor5 insensitive cursor for" + CRLF

		cProcCT2 += "    SELECT "

		If cTipo == "1"  //SE CT2 COMPARTILHADA OBRIGATORIAMENTE CT1 VAI SER COMPARTILHADO
			cProcCT2 += " CT1_FILIAL, CT1_CONTA  "+CRLF
			cProcCT2 += "      FROM "+RetSqlName("CT1")+ " CT1 "
			cProcCT2 += " WHERE CT1_FILIAL = '" +xFilial("CT1")+"' "+CRLF
			cProcCT2 += "       AND CT1_CONTA >= '"+cContaI+"' "+ CRLF
			cProcCT2 += "       AND CT1_CONTA <= '"+cContaF+"' "+ CRLF
			cProcCT2 += "       AND CT1_CLASSE = '2' "+ CRLF
			cProcCT2 += "       AND CT1.D_E_L_E_T_  = ' ' "+ CRLF
			cProcCT2 += "       AND CT1_CONTA NOT IN  ( SELECT CONTA "+ CRLF
			cProcCT2 += "                                 FROM "+cArqTmp+" "+ CRLF
			cProcCT2 += "                        	     )"
			cProcCT2 += CRLF
			cProcCT2 += "   Open cCursor5 "+CRLF
			cProcCT2 += "   Fetch cCursor5 into "
			cProcCT2 += " @cCT2_FILIAL, "
			cProcCT2 += " @cConta "

		ElseIf cTipo == "2"  //SE CT2 COMPARTILHADA OBRIGATORIAMENTE CTT VAI SER COMPARTILHADO
			cProcCT2 += " CTT_FILIAL, CTT_CUSTO  "
			cProcCT2 += "      FROM "+RetSqlName("CTT")+ " CTT "+CRLF
			cProcCT2 += "     WHERE CTT_FILIAL = '"+xFilial("CTT")+"' "+ CRLF
			cProcCT2 += "       AND CTT_CUSTO >= '"+cCustoI+"' "+ CRLF
			cProcCT2 += "       AND CTT_CUSTO <= '"+cCustoF+"' "+ CRLF
			cProcCT2 += "       AND CTT_CLASSE = '2' "+ CRLF
			cProcCT2 += "       AND CTT.D_E_L_E_T_  = ' ' "+ CRLF
			cProcCT2 += "       AND CTT_CUSTO NOT IN  ( SELECT CCUSTO "+ CRLF
			cProcCT2 += "                                 FROM "+cArqTmp+" "+ CRLF
			cProcCT2 += "                                WHERE CTT_FILIAL = FILIAL " + CRLF
			cProcCT2 += "                        	     )"
			cProcCT2 += CRLF
			cProcCT2 += "   Open cCursor5 "+CRLF
			cProcCT2 += "   Fetch cCursor5 into "
			cProcCT2 += " @cCT2_FILIAL, "
			cProcCT2 += " @cCusto "

		ElseIf ctipo == "3"

			cProcCT2 += " CTD_FILIAL, CTD_ITEM  "
			cProcCT2 += "      FROM "+RetSqlName("CTD")+ " CTD "+CRLF
			cProcCT2 += "     WHERE CTD_FILIAL = '"+xFilial("CTD")+"' "+ CRLF
			cProcCT2 += "       AND CTD_ITEM >= '"+cItemI+"' "+ CRLF
			cProcCT2 += "       AND CTD_ITEM <= '"+cITEMF+"' "+ CRLF
			cProcCT2 += "       AND CTD_CLASSE = '2' "+ CRLF
			cProcCT2 += "       AND CTD.D_E_L_E_T_  = ' ' "+ CRLF
			cProcCT2 += "       AND CTD_ITEM NOT IN  ( SELECT ITEM "+ CRLF
			cProcCT2 += "                                FROM "+cArqTmp+" "+ CRLF
			cProcCT2 += "                               )"+CRLF
			cProcCT2 += CRLF
			cProcCT2 += "   Open cCursor5 "+CRLF
			cProcCT2 += "   Fetch cCursor5 into "
			cProcCT2 += " @cCT2_FILIAL, "
			cProcCT2 += " @cItem "

		ElseIf ctipo == "4"

			cProcCT2 += " CTH_FILIAL, CTH_CLVL  "
			cProcCT2 += "      FROM "+RetSqlName("CTH")+ " CTH "+ CRLF
			cProcCT2 += "     WHERE CTH_FILIAL = '"+xFilial("CTH")+"' "+ CRLF
			cProcCT2 += "       AND CTH_CLVL >= '"+cClVlI+"' "+ CRLF
			cProcCT2 += "       AND CTH_CLVL <= '"+cCLVLF+"' "+ CRLF
			cProcCT2 += "       AND CTH_CLASSE = '2' "+ CRLF
			cProcCT2 += "       AND CTH.D_E_L_E_T_  = ' ' "+ CRLF
			cProcCT2 += "       AND CTH_CLVL NOT IN  ( SELECT CLVL "+ CRLF
			cProcCT2 += "                                FROM "+cArqTmp+" "+ CRLF
			cProcCT2 += "                               )"+CRLF
			cProcCT2 += CRLF
			cProcCT2 += "   Open cCursor5 "+CRLF
			cProcCT2 += "   Fetch cCursor5 into "
			cProcCT2 += " @cCT2_FILIAL, "
			cProcCT2 += " @cClVl "

		EndIf

		cProcCT2 += CRLF
		cProcCT2 += "   SELECT @cCT2_DATA = '"+DTOS(dDataIni)+"' "+CRLF
		cProcCT2 += "   SELECT @cCT2_EMPORI = '"+cEmpAnt+"' "+CRLF
		cProcCT2 += "   SELECT @cCT2_FILORI = '"+cFilAnt+"' "+CRLF


		If ctipo == "1"  //CONTA
			cProcCT2 += "   SELECT @cCT2_HIST = '"+STR0021+"' "+CRLF  		//"CONTA SEM MOVIMENTO NO PERIODO"
		ElseIf 	ctipo == "2"  //CUSTO
			cProcCT2 += "   SELECT @cCT2_HIST = '"+Upper(AllTrim(CtbSayApro("CTT"))) + " "  + STR0026+"' "+CRLF  		//"SEM MOVIMENTO NO PERIODO"
		ElseIf 	ctipo == "3"  //ITEM
			cProcCT2 += "   SELECT @cCT2_HIST = '"+Upper(AllTrim(CtbSayApro("CTD"))) + " "  + STR0026+"' "+CRLF  		//"SEM MOVIMENTO NO PERIODO"
		ElseIf 	ctipo == "4"  //CLVL
			cProcCT2 += "   SELECT @cCT2_HIST = '"+Upper(AllTrim(CtbSayApro("CTH"))) + " "  + STR0026+"' "+CRLF  		//"SEM MOVIMENTO NO PERIODO"
		EndIf

		cProcCT2 += "   while @@FETCH_STATUS = 0 "
		cProcCT2 += " begin"+CRLF
		cProcCT2 += CRLF

		If lSldAnt .And. ctipo == "1"  //CONTA

			//query para pegar saldo anterior
			cProcCT2 += CRLF
			cProcCT2 += "      SELECT @nAntDeb = ISNULL( SUM(CQ1_DEBITO), 0),  @nAntCred = ISNULL( SUM(CQ1_CREDIT), 0)"+CRLF
			cProcCT2 += " 	     FROM "+RetSqlName("CQ1")+" CQ1 "
			cProcCT2 += "       WHERE CQ1.CQ1_FILIAL  " + cGetRngFil+CRLF  //tem o mesmo compartilhamento da CT2
			If !Empty(c2Moeda)
				cProcCT2 += "         AND ( CQ1.CQ1_MOEDA = '" + cMoeda  + "' OR "
				cProcCT2 += "       CQ1.CQ1_MOEDA = '" + c2Moeda + "'  ) "
			Else
				cProcCT2 += "         AND CQ1.CQ1_MOEDA = '" + cMoeda  + "' "+CRLF
			EndIf
			cProcCT2 += "         AND CQ1.CQ1_TPSALD = '"+ cSaldo + "' "+CRLF
			cProcCT2 += "         AND CQ1.CQ1_CONTA  =  @cConta "+CRLF
			cProcCT2 += "         AND CQ1.D_E_L_E_T_ = ' ' "+CRLF
			cProcCT2 += "         AND CQ1.CQ1_DATA   < '" + DTOS(dDataIni) + "' "+CRLF
			// removido filtro de Lucros e perdas que causavam erro na composi��o do saldo anterior
			// cProcCT2 += "         AND CQ1.CQ1_LP = (SELECT MAX(CQ1_LP) "+CRLF 
			// cProcCT2 += "                             FROM "+RetSqlName("CQ1")+" CQ13 "+CRLF

			// cProcCT2 += "                            WHERE CQ13.CQ1_FILIAL = CQ1.CQ1_FILIAL "+CRLF
			// cProcCT2 += "                              AND CQ13.CQ1_MOEDA  = CQ1.CQ1_MOEDA "+CRLF
			// cProcCT2 += "                              AND CQ13.CQ1_TPSALD = CQ1.CQ1_TPSALD "+CRLF
			// cProcCT2 += "                              AND CQ13.CQ1_CONTA  = CQ1.CQ1_CONTA "+CRLF
			// cProcCT2 += "                              AND CQ13.CQ1_DATA   < '" + DTOS(dDataIni) + "' "+CRLF
			// cProcCT2 += "                              AND CQ13.D_E_L_E_T_ = ' ') "+CRLF
			cProcCT2 += "      GROUP BY D_E_L_E_T_ "+CRLF

			cProcCT2 += "      if @nAntDeb != 0 OR  @nAntCred != 0 begin"+CRLF

		EndIf

		//INSERT CONTAS SEM MOVIMENTACAO
		//cProcCT2 += "         select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from "+cArqTmp + CRLF
		cProcCT2 += "         select @iRecno = @iRecno + 1 "+ CRLF

		cProcCT2 += "         If @iCommit = 0 begin"+CRLF
		cProcCT2 += "            select @iCommit = 0"+CRLF
		cProcCT2 += "            Begin tran"+CRLF
		cProcCT2 += "         End"+CRLF
		cProcCT2 += "         INSERT INTO "+cArqTmp
		cProcCT2 += " ("
		cProcCT2 += " FILIAL, "
		cProcCT2 += " DATAL, "
		If ctipo == "1"  //CONTA
			cProcCT2 += " CONTA, "
		ElseIf 	ctipo == "2"  //CUSTO
			cProcCT2 += " CCUSTO, "
		ElseIf 	ctipo == "3"  //ITEM
			cProcCT2 += " ITEM, "
		ElseIf 	ctipo == "4"  //CLVL
			cProcCT2 += " CLVL, "
		EndIf
		cProcCT2 += " HISTORICO, "
		cProcCT2 += " EMPORI, "
		cProcCT2 += " FILORI "
		cProcCT2 += ") "+CRLF
		cProcCT2 += "         VALUES "
		cProcCT2 += " ("
		cProcCT2 += " @cCT2_FILIAL, "
		cProcCT2 += " @cCT2_DATA, "
		If ctipo == "1"  //CONTA
			cProcCT2 += " @cConta, "
		ElseIf 	ctipo == "2"  //CUSTO
			cProcCT2 += " @cCusto, "
		ElseIf 	ctipo == "3"  //ITEM
			cProcCT2 += " @cItem, "
		ElseIf 	ctipo == "4"  //CLVL
			cProcCT2 += " @cClVl, "
		EndIf
		cProcCT2 += " @cCT2_HIST, "
		cProcCT2 += " @cCT2_EMPORI, "
		cProcCT2 += " @cCT2_FILORI "
		cProcCT2 += ")" + CRLF    //acabou a inclusao
		cProcCT2 += "         select @iCommit = @iCommit + 1"+CRLF
		//cProcCT2 += "         Commit tran "+ CRLF

		If lSldAnt
			cProcCT2 += "      end "+CRLF  //finalizar o if do saldo anterior != 0
		EndIf
		cProcCT2 += "      If @iCommit >= 10240 begin"+CRLF
		cProcCT2 += "         select @iCommit = 0 "+CRLF
		cProcCT2 += "         select @iTranCount = 0"+CRLF
		//cProcCT2 += "         Commit tran"+CRLF
		cProcCT2 += "      end"+CRLF

		If cTipo == "1"  //SE CT2 COMPARTILHADA OBRIGATORIAMENTE CT1 VAI SER COMPARTILHADO
			cProcCT2 += "      Fetch cCursor5 into "
			cProcCT2 += " @cCT2_FILIAL, "
			cProcCT2 += " @cConta "

		ElseIf cTipo == "2"  //SE CT2 COMPARTILHADA OBRIGATORIAMENTE CTT VAI SER COMPARTILHADO
			cProcCT2 += "      Fetch cCursor5 into "+CRLF
			cProcCT2 += " @cCT2_FILIAL, "
			cProcCT2 += " @cCusto "

		ElseIf ctipo == "3"
			cProcCT2 += "      Fetch cCursor5 into "+CRLF
			cProcCT2 += " @cCT2_FILIAL, "
			cProcCT2 += " @cItem "

		ElseIf ctipo == "4"
			cProcCT2 += "      Fetch cCursor5 into "
			cProcCT2 += " @cCT2_FILIAL, "
			cProcCT2 += " @cClVl "
		EndIf
		cProcCT2 += CRLF

		cProcCT2 += "   End "+ CRLF  //finaliza While
		cProcCT2 += "   If @iCommit > 0 begin"+CRLF
		cProcCT2 += "      select @iCommit = 0 "+CRLF
		cProcCT2 += "      select @iTranCount = 0"+CRLF
		cProcCT2 += "   end"+CRLF
		cProcCT2 += "   close cCursor5"+CRLF
		cProcCT2 += "   deallocate cCursor5"+CRLF
		cProcCT2 += CRLF

	Else  //CT2 EXCLUSIVO EM ALGUM SEGMENTO

		cProcCT2 += "   SELECT @cCT2_DATA = '"+DTOS(dDataIni)+"' "+CRLF
		cProcCT2 += "   SELECT @cCT2_EMPORI = '"+cEmpAnt+"' "+CRLF
		cProcCT2 += "   SELECT @cCT2_FILORI = '"+cFilAnt+"' "+CRLF

		If 	ctipo == "1"  //CONTA
			cProcCT2 += "   SELECT @cCT2_FILIAL = '"+xFilial("CT1")+"'"
			cProcCT2 += "   SELECT @cCT2_HIST = '"+STR0021+"' "+CRLF  		//"CONTA SEM MOVIMENTO NO PERIODO"
		ElseIf 	ctipo == "2"  //CUSTO
			cProcCT2 += "   SELECT @cCT2_HIST = '"+Upper(AllTrim(CtbSayApro("CTT"))) + " "  + STR0026+"' "+CRLF  		//"SEM MOVIMENTO NO PERIODO"
		ElseIf 	ctipo == "3"  //ITEM
			cProcCT2 += "   SELECT @cCT2_HIST = '"+Upper(AllTrim(CtbSayApro("CTD"))) + " "  + STR0026+"' "+CRLF  		//"SEM MOVIMENTO NO PERIODO"
		ElseIf 	ctipo == "4"  //CLVL
			cProcCT2 += "   SELECT @cCT2_HIST = '"+Upper(AllTrim(CtbSayApro("CTH"))) + " "  + STR0026+"' "+CRLF  		//"SEM MOVIMENTO NO PERIODO"
		EndIf

		cProcCT2 += "   Declare cCursor5 insensitive cursor for" + CRLF

		If cTipo == "1"

			nTamEnt := Len(Alltrim(xFilial("CT1")))

			cProcCT2 += "    SELECT DISTINCT CT1_CONTA  "
			cProcCT2 += "      FROM "+RetSqlName("CT1")+ " CT1,  "
			cProcCT2 += " "+cRealTmp+ " XFILCT2  "

		 	If xFilial("CT1") == xFilial("CT2")  //se tem o mesmo compartilhamento e for exclusivo em ambas em algum segmento
				cProcCT2 += " WHERE CT1_FILIAL = XFILCT2.TMPFIL "+CRLF
			Else
				cProcCT2 += " WHERE CT1_FILIAL = SUBSTRING(XFILCT2.TMPFIL,1,"+cValToChar(nTamEnt)+")||'"+Space(nTamFil-nTamEnt)+"'"+CRLF
			EndIf

			cProcCT2 += "       AND CT1_CONTA >= '"+cContaI+"' "+ CRLF
			cProcCT2 += "       AND CT1_CONTA <= '"+cContaF+"' "+ CRLF
			cProcCT2 += "       AND CT1_CLASSE = '2' "+ CRLF
			cProcCT2 += "       AND CT1.D_E_L_E_T_  = ' ' "+ CRLF
			cProcCT2 += "       AND CT1_CONTA NOT IN  ( SELECT CONTA "+ CRLF
			cProcCT2 += "                                 FROM "+cArqTmp+" "+ CRLF

			If !Empty(xFilial("CT1"))
			 	If xFilial("CT1") == xFilial("CT2")  //se for exclusivo em ambas em algum segmento
					cProcCT2 += " WHERE CT1_FILIAL = FILIAL "+CRLF
				Else
					cProcCT2 += " WHERE CT1_FILIAL = SUBSTRING(FILIAL,1,"+cValToChar(nTamEnt)+")||'"+Space(nTamFil-nTamEnt)+"'"+CRLF
				EndIf
			EndIf

			cProcCT2 += " ) "
			cProcCT2 += CRLF

			cProcCT2 += "   Open cCursor5 "+CRLF
			cProcCT2 += "   Fetch cCursor5 into "
			cProcCT2 += " @cConta "
			cProcCT2 += CRLF

		ElseIf cTipo == "2"

			nTamEnt := Len(Alltrim(xFilial("CTT")))

			cProcCT2 += "    SELECT DISTINCT XFILCT2.TMPFIL CT2_FILIAL, CTT_CUSTO  "
			cProcCT2 += "      FROM "+RetSqlName("CTT")+ " CTT,  "
			cProcCT2 += " "+cRealTmp+ " XFILCT2  "

		 	If xFilial("CTT") == xFilial("CT2")  //se tem o mesmo compartilhamento e for exclusivo em ambas em algum segmento
				cProcCT2 += " WHERE CTT_FILIAL = XFILCT2.TMPFIL "+CRLF
			Else
				cProcCT2 += " WHERE CTT_FILIAL = SUBSTRING(XFILCT2.TMPFIL,1,"+cValToChar(nTamEnt)+")||'"+Space(nTamFil-nTamEnt)+"'"+CRLF
			EndIf

			cProcCT2 += "       AND CTT_CUSTO >= '"+cCustoI+"' "+ CRLF
			cProcCT2 += "       AND CTT_CUSTO <= '"+cCustoF+"' "+ CRLF
			cProcCT2 += "       AND CTT_CLASSE = '2' "+ CRLF
			cProcCT2 += "       AND CTT.D_E_L_E_T_  = ' ' "+ CRLF

			cProcCT2 += "       AND CTT_CUSTO NOT IN ( SELECT CCUSTO "+ CRLF
			cProcCT2 += "                                FROM "+cArqTmp+" "+ CRLF

			If !Empty(xFilial("CTT"))
			 	If xFilial("CTT") == xFilial("CT2")  //se for exclusivo em ambas em algum segmento
					cProcCT2 += " WHERE CTT_FILIAL = FILIAL " + CRLF
				Else
					cProcCT2 += " WHERE CTT_FILIAL = SUBSTRING(FILIAL,1,"+cValToChar(nTamEnt)+")||'"+Space(nTamFil-nTamEnt)+"'"+CRLF
				EndIf
			EndIf
			cProcCT2 += "                               )"
			cProcCT2 += CRLF

			cProcCT2 += "   Open cCursor5 "+CRLF
			cProcCT2 += "   Fetch cCursor5 into "
			cProcCT2 += " @cCT2_FILIAL, "
			cProcCT2 += " @cCusto "
			cProcCT2 += CRLF

		ElseIf ctipo == "3"
			nTamEnt := Len(Alltrim(xFilial("CTD")))

			cProcCT2 += "    SELECT DISTINCT XFILCT2.TMPFIL CT2_FILIAL, CTD_ITEM  "
			cProcCT2 += "      FROM "+RetSqlName("CTD")+ " CTD,  "
			cProcCT2 += " "+cRealTmp+ " XFILCT2  "

			If xFilial("CTD") == xFilial("CT2")
				cProcCT2 += " WHERE CTD_FILIAL = XFILCT2.TMPFIL "+CRLF
			Else
				cProcCT2 += " WHERE CTD_FILIAL = SUBSTRING(XFILCT2.TMPFIL,1,"+cValToChar(nTamEnt)+")||'"+Space(nTamFil-nTamEnt)+"'"+CRLF
			EndIf

			cProcCT2 += "       AND CTD_ITEM >= '"+cItemI+"' "+ CRLF
			cProcCT2 += "       AND CTD_ITEM <= '"+cITEMF+"' "+ CRLF
			cProcCT2 += "       AND CTD_CLASSE = '2' "+ CRLF
			cProcCT2 += "       AND CTD.D_E_L_E_T_  = ' ' "+ CRLF
			cProcCT2 += "       AND CTD_ITEM NOT IN  ( SELECT ITEM "+ CRLF
			cProcCT2 += "   FROM "+cArqTmp+" "+ CRLF

			If !Empty(xFilial("CTD"))
			 	If xFilial("CTD") == xFilial("CT2")  //se for exclusivo em ambas em algum segmento
					cProcCT2 += " WHERE CTD_FILIAL = FILIAL " + CRLF
				Else
					cProcCT2 += " WHERE CTH_FILIAL = SUBSTRING(FILIAL,1,"+cValToChar(nTamEnt)+")||'"+Space(nTamFil-nTamEnt)+"'"+CRLF
				EndIf
			EndIf

			cProcCT2 += "                                )"+CRLF
			cProcCT2 += CRLF

			cProcCT2 += "   Open cCursor5 "+CRLF
			cProcCT2 += "   Fetch cCursor5 into "+CRLF
			cProcCT2 += " @cCT2_FILIAL, "
			cProcCT2 += " @cItem "
			cProcCT2 += CRLF

		ElseIf ctipo == "4"
			nTamEnt := Len(Alltrim(xFilial("CTH")))

			cProcCT2 += "   SELECT DISTINCT XFILCT2.TMPFIL CT2_FILIAL, CTH_CLVL  "
			cProcCT2 += "     FROM "+RetSqlName("CTH")+ " CTH,  "
			cProcCT2 += " "+cRealTmp+ " XFILCT2  "+CRLF

			If xFilial("CTH") == xFilial("CT2")  //se tem o mesmo compartilhamento e for exclusivo em ambas em algum segmento
				cProcCT2 += " WHERE CTH_FILIAL = XFILCT2.TMPFIL "+CRLF
			Else
				cProcCT2 += " WHERE CTH_FILIAL = SUBSTRING(XFILCT2.TMPFIL,1,"+cValToChar(nTamEnt)+")||'"+Space(nTamFil-nTamEnt)+"'"+CRLF
			EndIf

			cProcCT2 += "       AND CTH_CLVL >= '"+cClVlI+"' "+ CRLF
			cProcCT2 += "       AND CTH_CLVL <= '"+cCLVLF+"' "+ CRLF
			cProcCT2 += "       AND CTH_CLASSE = '2' "+ CRLF
			cProcCT2 += "       AND CTH.D_E_L_E_T_  = ' ' "+ CRLF
			cProcCT2 += "       AND CTH_CLVL NOT IN  ( SELECT CLVL "+ CRLF
			cProcCT2 += "                                FROM "+cArqTmp+" "+ CRLF

			If !Empty(xFilial("CTH"))
			 	If xFilial("CTH") == xFilial("CT2")  //se for exclusivo em ambas em algum segmento
					cProcCT2 += " WHERE CTH_FILIAL = FILIAL " + CRLF
				Else
					cProcCT2 += " WHERE CTH_FILIAL = SUBSTRING(FILIAL,1,"+cValToChar(nTamEnt)+")||'"+Space(nTamFil-nTamEnt)+"'"+CRLF
				EndIf
			EndIf

			cProcCT2 += "                               )"+CRLF
			cProcCT2 += CRLF

			cProcCT2 += "   Open cCursor5 "+CRLF
			cProcCT2 += "   Fetch cCursor5 into "+CRLF
			cProcCT2 += " @cCT2_FILIAL, "
			cProcCT2 += " @cClVl "
			cProcCT2 += CRLF

		EndIf

		cProcCT2 += "   while @@FETCH_STATUS = 0 "
		cProcCT2 += " begin"+CRLF
		cProcCT2 += CRLF

		If lSldAnt .And. ctipo == "1"  //CONTA

			//query para pegar saldo anterior
			cProcCT2 += CRLF

			cProcCT2 += "      SELECT @nAntDeb = ISNULL( SUM(CQ1_DEBITO), 0), @nAntCred = ISNULL( SUM(CQ1_CREDIT), 0) "+CRLF
			cProcCT2 += " 		 FROM "+RetSqlName("CQ1")+" CQ1 "+CRLF
			cProcCT2 += "       WHERE CQ1.CQ1_FILIAL  " + cGetRngFil+CRLF  //tem o mesmo compartilhamento da CT2

			If !Empty(c2Moeda)
				cProcCT2 += "         AND ( CQ1.CQ1_MOEDA = '" + cMoeda  + "' OR "
				cProcCT2 += " CQ1.CQ1_MOEDA = '" + c2Moeda + "'  ) "
			Else
				cProcCT2 += "         AND CQ1.CQ1_MOEDA = '" + cMoeda  + "' "
			EndIf

			cProcCT2 += CRLF
			cProcCT2 += "        AND CQ1.CQ1_TPSALD = '"+ cSaldo + "' "+CRLF
			cProcCT2 += "        AND CQ1.CQ1_CONTA  =  @cConta "+CRLF
			cProcCT2 += "        AND CQ1.D_E_L_E_T_ = ' ' "+CRLF
			cProcCT2 += "        AND CQ1.CQ1_DATA   < '" + DTOS(dDataIni) + "' "+CRLF
			// removido filtro de Lucros e perdas
			// cProcCT2 += "        AND CQ1.CQ1_LP = (SELECT MAX(CQ1_LP) "+CRLF 
			// cProcCT2 += "                            FROM "+RetSqlName("CQ1")+" CQ13 "+CRLF
			// cProcCT2 += "                           WHERE CQ13.CQ1_FILIAL = CQ1.CQ1_FILIAL "+CRLF
			// cProcCT2 += "                             AND CQ13.CQ1_MOEDA  = CQ1.CQ1_MOEDA "+CRLF
			// cProcCT2 += "                             AND CQ13.CQ1_TPSALD = CQ1.CQ1_TPSALD "+CRLF
			// cProcCT2 += "                             AND CQ13.CQ1_CONTA  = CQ1.CQ1_CONTA "+CRLF
			// cProcCT2 += "                             AND CQ13.CQ1_DATA   < '" + DTOS(dDataIni) + "' "+CRLF
			// cProcCT2 += "                             AND CQ13.D_E_L_E_T_ = ' ') "+CRLF
			cProcCT2 += "   GROUP BY D_E_L_E_T_ "+CRLF   //SOMENTE PARA RODAR EM TODOS OS BANCOS (NA VERDADE AGRUPA TODOS)

			cProcCT2 += "   if @nAntDeb != 0 OR  @nAntCred != 0 begin"+CRLF

		EndIf

		//INSERT CONTAS SEM MOVIMENTACAO
		//cProcCT2 += "      select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from "+cArqTmp + CRLF
		cProcCT2 += "      select @iRecno = @iRecno + 1 "+ CRLF

		cProcCT2 += ""+ CRLF
		cProcCT2 += "      If @iCommit = 0 begin"+CRLF
		cProcCT2 += "         select @iCommit = 0"+CRLF
		cProcCT2 += "         Begin tran"+CRLF
		cProcCT2 += "      End"+CRLF
		cProcCT2 += "      INSERT INTO "+cArqTmp
		cProcCT2 += " ("
		cProcCT2 += " FILIAL, "
		cProcCT2 += " DATAL, "

		If ctipo == "1"  //CONTA
			cProcCT2 += " CONTA, "
		ElseIf 	ctipo == "2"  //CUSTO
			cProcCT2 += " CCUSTO, "
		ElseIf 	ctipo == "3"  //ITEM
			cProcCT2 += " ITEM, "
		ElseIf 	ctipo == "4"  //CLVL
			cProcCT2 += " CLVL, "
		EndIf

		cProcCT2 += " HISTORICO, "
		cProcCT2 += " EMPORI, "
		cProcCT2 += " FILORI
		cProcCT2 += ") "+CRLF
		cProcCT2 += "      VALUES "
		cProcCT2 += " ("
		cProcCT2 += " @cCT2_FILIAL, "
		cProcCT2 += " @cCT2_DATA, "

		If 	ctipo == "1"  //CONTA
			cProcCT2 += " @cConta, "
		ElseIf 	ctipo == "2"  //CUSTO
			cProcCT2 += " @cCusto, "
		ElseIf 	ctipo == "3"  //ITEM
			cProcCT2 += " @cItem, "
		ElseIf 	ctipo == "4"  //CLVL
			cProcCT2 += " @cClVl, "
		EndIf

		cProcCT2 += " @cCT2_HIST, "
		cProcCT2 += " @cCT2_EMPORI, "
		cProcCT2 += " @cCT2_FILORI "
		cProcCT2 += ")" + CRLF    //acabou a inclusao
		cProcCT2 += ""+ CRLF
		cProcCT2 += "      select @iCommit = @iCommit + 1"+CRLF

		If lSldAnt
			cProcCT2 += "   end "+CRLF  //finalizar o if do saldo anterior != 0
		EndIf
		cProcCT2 += "      If @iCommit >= 10240 begin"+CRLF
		cProcCT2 += "         select @iCommit = 0 "+CRLF
		cProcCT2 += "         select @iTranCount = 0"+CRLF
		cProcCT2 += "      end"+CRLF

		If cTipo == "1"  //SE CT2 COMPARTILHADA OBRIGATORIAMENTE CT1 VAI SER COMPARTILHADO

			cProcCT2 += "   Fetch cCursor5 into "
			cProcCT2 += " @cConta "

		ElseIf cTipo == "2"  //SE CT2 COMPARTILHADA OBRIGATORIAMENTE CTT VAI SER COMPARTILHADO

			cProcCT2 += "   Fetch cCursor5 into "
			cProcCT2 += " @cCT2_FILIAL, "
			cProcCT2 += " @cCusto "

		ElseIf ctipo == "3"

			cProcCT2 += "   Fetch cCursor5 into "
			cProcCT2 += " @cCT2_FILIAL, "
			cProcCT2 += " @cItem "

		ElseIf ctipo == "4"

			cProcCT2 += "   Fetch cCursor5 into "
			cProcCT2 += " @cCT2_FILIAL, "
			cProcCT2 += " @cClVl "

		EndIf

		cProcCT2 += CRLF

		cProcCT2 += "   End "+ CRLF  //finaliza While
		cProcCT2 += "   If @iCommit > 0 begin"+CRLF
		cProcCT2 += "      select @iCommit = 0 "+CRLF
		cProcCT2 += "      select @iTranCount = 0"+CRLF
		cProcCT2 += "   end"+CRLF
		cProcCT2 += "   close cCursor5"+CRLF
		cProcCT2 += "   deallocate cCursor5"+CRLF
		cProcCT2 += CRLF

	EndIf

EndIf

cProcCT2 += "   select @OUT_RET = '1' "+CRLF  //atribui retorno 1 se bem sucedido
//finaliza
cProcCT2 += "End "+CRLF

If TcGetDB() == "DB2"
	cProcCT2 := STRTRAN(cProcCT2, "SESSION.", "XYZ_ZYX")  //DB2
EndIf

cProcCT2 := MsParse(cProcCT2,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))

If (Alltrim(UPPER(TcGetDb())) $ "MSSQL7" )
	cProcCT2 := StrTran(cProcCT2, "SET @iTranCount  = 0", cCommit)
ElseIf (Alltrim(UPPER(TcGetDb())) = "DB2" )
	cProcCT2 := StrTran(cProcCT2, "set viTranCount  = 0", cCommit)
	cProcCT2 := STRTRAN(cProcCT2, "XYZ_ZYX", "SESSION.")  //DB2
ElseIf (Alltrim(UPPER(TcGetDb())) = "ORACLE" )
	cProcCT2 := StrTran(cProcCT2, "viTranCount  := 0", cCommit)
ElseIf (Alltrim(UPPER(TcGetDb())) = "INFORMIX" )
	cProcCT2 := StrTran(cProcCT2, "BEGIN WORK ;", "")
	cProcCT2 := StrTran(cProcCT2, "COMMIT WORK ;", "")
EndIf

//ajustar pois MSPARSE esta retirando um # do nome da tabela nos select .... From cArqTmp
cProcCT2 := StrTran(cProcCT2, " #TMP", " ##TMP")

//instalar a procedure
If Empty( cProcCT2 )
	MsgAlert(MsParseError(),STR0069+cNomProc)  //'A query nao passou pelo Parse '
	lRet := .F.
Else

	If !TCSPExist( cNomProc )

		cRet := TcSqlExec(cProcCT2)

		If cRet <> 0

			If !__lBlind

				MsgAlert(STR0070+cProcCT2)  //'Erro na criacao da procedure '
				lRet:= .F.

			EndIf

		EndIf

	EndIf

EndIf

//executa a procedure
aResult := TCSPExec( cNomProc  )
TcRefresh(cArqTmp)

If Empty(aResult) .Or. aResult[1] = "0"
	MsgAlert(tcsqlerror(), STR0071) //"Erro na gera��o arquivo temporario para relatorio."
	lRet := .F.
Else
	//apaga a procedure apos carregar o temporario
	If TCSPExist( cNomProc )
		If TcSqlExec("DROP PROCEDURE "+cNomProc) <> 0
	 		UserException(STR0072 + cNomProc + CRLF + TCSqlError() ) //"Erro na dele��o da Procedure de extra��o dos dados no arquivo temporario."
	   	Else
			lRet := .T.
		EndIf
	Endif
EndIf

CtbTmpErase(cTmpCT2Fil)
CtbTmpErase(cTmpCT1Fil)
CtbTmpErase(cTmpCTTFil)
CtbTmpErase(cTmpCTDFil)
CtbTmpErase(cTmpCTHFil)
EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc}CTBR400
Relatorio Razao - Criar temporario no banco e popular via procedure
Static Function CtbAuxGrvRAZ
@author Paulo Carnelossi - Totvs
@since  04/11/2015
@version 11.8
*/
//-------------------------------------------------------------------

Static Function CtbAuxGrvRAZ(cProcCt2,cArqTmp,cMoeda,cTipo,c2Moeda,nTipo)

Local lImpCPartida := GetNewPar("MV_IMPCPAR",.T.) // Se .T.,     IMPRIME Contra-Partida para TODOS os tipos de lan�amento (D�bito, Credito e Partida-Dobrada),
                                                  // se .F., N�O IMPRIME Contra-Partida para NENHUM   tipo  de lan�amento.
cProcCT2 += "      SELECT @iInclui = 1 "+CRLF

If cTipo == "1"
	cProcCT2 += "      SELECT @cConta = @cCT2_DEBITO "+CRLF
	cProcCT2 += "      SELECT @cContra = @cCT2_CREDIT "+CRLF
	cProcCT2 += "      SELECT @cCusto = @cCT2_CCD "+CRLF
	cProcCT2 += "      SELECT @cItem = @cCT2_ITEMD "+CRLF
	cProcCT2 += "      SELECT @cCLVL = @cCT2_CLVLDB "+CRLF
EndIf
If cTipo == "2"
	cProcCT2 += "      SELECT @cConta = @cCT2_CREDIT "+CRLF
	cProcCT2 += "      SELECT @cContra = @cCT2_DEBITO "+CRLF
	cProcCT2 += "      SELECT @cCusto = @cCT2_CCC "+CRLF
	cProcCT2 += "      SELECT @cItem = @cCT2_ITEMC "+CRLF
	cProcCT2 += "      SELECT @cCLVL = @cCT2_CLVLCR "+CRLF
EndIf
//variaveis para uso no update
cProcCT2 += "      SELECT @nLancDeb = 0 "+CRLF
cProcCT2 += "      SELECT @nLancCrd = 0 "+CRLF
cProcCT2 += "      SELECT @nLancDeb_1 = 0 "+CRLF
cProcCT2 += "      SELECT @nLancCrd_1 = 0 "+CRLF
cProcCT2 += "      SELECT @nTxDebito = 0 "+CRLF
cProcCT2 += "      SELECT @nTxCredito = 0 "+CRLF
cProcCT2 += "      SELECT @cDelet_ = ' ' "+CRLF
cProcCT2 += CRLF
If !Empty(c2Moeda)
	cProcCT2 += "      SELECT @iInclui = 1 "+CRLF
	If cTipo == "1"
		cProcCT2 += " Declare cCursor1 insensitive cursor for" + CRLF
	Else
		cProcCT2 += " Declare cCursor2 insensitive cursor for" + CRLF
	EndIf
	cProcCT2 += " "+ CRLF
	cProcCT2 += "      SELECT CCUSTO, ITEM, CLVL, R_E_C_N_O_ "+CRLF
	cProcCT2 += " FROM "+cArqTmp +" CARQTMP "+CRLF
	cProcCT2 += " WHERE " + CRLF
	If cTipo == "1"
		cProcCT2 += " CONTA = @cCT2_DEBITO" +CRLF
	Else
		cProcCT2 += " CONTA = @cCT2_CREDIT" +CRLF
	EndIf
	cProcCT2 += " AND DATAL = @cCT2_DATA " +CRLF
	cProcCT2 += " AND LOTE = @cCT2_LOTE " +CRLF
	cProcCT2 += " AND SUBLOTE = @cCT2_SBLOTE "+CRLF
	cProcCT2 += " AND DOC = @cCT2_DOC " +CRLF
	cProcCT2 += " AND LINHA = @cCT2_LINHA" +CRLF
	cProcCT2 += " AND EMPORI = @cCT2_EMPORI" +CRLF
	cProcCT2 += " AND FILORI = @cCT2_FILORI" +CRLF
	cProcCT2 += " AND CARQTMP.D_E_L_E_T_ = ' ' " +CRLF
	If cTipo == "1"
		cProcCT2 += "Open cCursor1 "+ CRLF
		cProcCT2 += "    Fetch cCursor1 into @cAuxCusto, @cAuxItem, @cAuxClvl, @iAuxRecno "+CRLF
	Else
		cProcCT2 += "Open cCursor2 "+ CRLF
		cProcCT2 += "    Fetch cCursor2 into @cAuxCusto, @cAuxItem, @cAuxClvl, @iAuxRecno "+CRLF
	EndIf
	//laco
	cProcCT2 += " while @@FETCH_STATUS = 0"+CRLF
	cProcCT2 += "	begin"+CRLF

	cProcCT2 += "	if @cCusto = @cAuxCusto AND @cItem = @cAuxItem AND @cCLVL = @cAuxClvl begin "+CRLF
	cProcCT2 += "	   SELECT @iInclui = 0 "+CRLF
	cProcCT2 += "	   break "+CRLF
	cProcCT2 += "	   end"+CRLF

	If cTipo == "1"
		cProcCT2 += "    Fetch cCursor1 into @cAuxCusto, @cAuxItem, @cAuxClvl "+CRLF
	Else
		cProcCT2 += "    Fetch cCursor2 into @cAuxCusto, @cAuxItem, @cAuxClvl "+CRLF
	EndIf

	cProcCT2 += "End "+ CRLF  //finaliza While
	If cTipo == "1"
		cProcCT2 += "close cCursor1 "+CRLF
		cProcCT2 += "deallocate cCursor1 "+CRLF
		cProcCT2 += CRLF
	Else
		cProcCT2 += "close cCursor2 "+CRLF
		cProcCT2 += "deallocate cCursor2 "+CRLF
		cProcCT2 += CRLF
	EndIf
Else
	cProcCT2 += "      SELECT @iInclui = 1 "+CRLF
EndIf
cProcCT2 += ""+CRLF
cProcCT2	+= "   If @iCommit = 0 begin"+CRLF
cProcCT2 	+= "      select @iCommit = 0"+CRLF
cProcCT2 	+= "      Begin tran"+CRLF
cProcCT2 	+= "   End"+CRLF
cProcCT2 += "      if @iInclui = 1 begin"+CRLF   //inclusao na tabela temporaria cArqTmp

If Empty(c2Moeda)	//Se nao for Razao em 2 Moedas
	If cTipo == "1"
		cProcCT2	+= "         SELECT @nLancDeb = @nCT2_VALOR  "+CRLF
	EndIf
	If cTipo == "2"
		cProcCT2	+= "         SELECT @nLancCrd = @nCT2_VALOR  "+CRLF
	EndIf
Else	//Se for Razao em 2 Moedas
	If (nTipo = 1 .Or. nTipo = 3) //Se Imprime Valor na Moeda ou ambos
		If cTipo == "1"
			cProcCT2	+= "         if @cCT2_MOEDLC = '"+cMoeda+"' "
			cProcCT2	+= " SELECT @nLancDeb =  @nCT2_VALOR "+CRLF
		Else
			cProcCT2	+= "         if @cCT2_MOEDLC = '"+cMoeda+"' "
			cProcCT2	+= " SELECT @nLancCrd = @nCT2_VALOR "+CRLF
		EndIf
	EndIf
	If (nTipo = 2 .Or. nTipo = 3) //Se Imprime Moeda Corrente ou Ambas
		If cTipo == "1"
			cProcCT2	+= "         if @cCT2_MOEDLC = '"+c2Moeda+"' "
			cProcCT2	+= " SELECT @nLancDeb_1 =  @nCT2_VALOR "+CRLF
		Else
			cProcCT2	+= "         if @cCT2_MOEDLC = '"+c2Moeda+"' "
			cProcCT2	+= " SELECT @nLancCrd_1 = @nCT2_VALOR "+CRLF
		Endif
	EndIf
EndIf

//cProcCT2	+= "         select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from "+cArqTmp + CRLF
cProcCT2	+= "         select @iRecno = @iRecno + 1 "+ CRLF

cProcCT2	+= "         INSERT INTO "+cArqTmp
cProcCT2	+= " ("
cProcCT2	+= " FILIAL, "
cProcCT2	+= " DATAL, "
cProcCT2	+= " TIPO, "
cProcCT2	+= " LOTE, "
cProcCT2	+= " SUBLOTE, "
cProcCT2	+= " DOC, "
cProcCT2	+= " LINHA, "
cProcCT2	+= " CONTA, "
If lImpCPartida
	cProcCT2	+= " XPARTIDA, "
EndIf
cProcCT2	+= " CCUSTO, "
cProcCT2	+= " ITEM, "
cProcCT2	+= " CLVL, "
cProcCT2	+= " HISTORICO, "
cProcCT2	+= " EMPORI, "
cProcCT2	+= " FILORI, "
cProcCT2	+= " SEQHIST, "
cProcCT2	+= " SEQLAN, "
cProcCT2	+= " NOMOV, "
If cPaisLoc $ "CHI|ARG"  .or. (cPaisLoc $ "BRA"  .and. !Empty(__cSegOfi) .And. __cSegOfi != "0")
	cProcCT2	+= " SEGOFI, "
EndIf
If Empty(c2Moeda)	//Se nao for Razao em 2 Moedas
	If cTipo == "1"
		cProcCT2	+= " LANCDEB, "
	EndIf
	If cTipo == "2"
		cProcCT2	+= " LANCCRD, "
	EndIf
Else	//Se for Razao em 2 Moedas
	If (nTipo = 1 .Or. nTipo = 3) //Se Imprime Valor na Moeda ou ambos
		If cTipo == "1"
			cProcCT2	+= " LANCDEB, "
		Else
			cProcCT2	+= " LANCCRD, "
		EndIf
	EndIf
    If (nTipo = 2 .Or. nTipo = 3) //Se Imprime Moeda Corrente ou Ambas
		If cTipo == "1"
			cProcCT2	+= " LANCDEB_1, "
		Else
			cProcCT2	+= " LANCCRD_1, "
		Endif
	EndIf
EndIf
cProcCT2	+= " RECNOCT2  "

cProcCT2	+= ") "+CRLF
cProcCT2	+= "         VALUES ("
cProcCT2	+= " @cCT2_FILIAL, "
cProcCT2	+= " @cCT2_DATA, "
cProcCT2	+= "'"+cTipo+"', "
cProcCT2	+= " @cCT2_LOTE, "
cProcCT2	+= " @cCT2_SBLOTE, "
cProcCT2	+= " @cCT2_DOC, "
cProcCT2	+= " @cCT2_LINHA, "
cProcCT2	+= " @cConta, "
If lImpCPartida
	cProcCT2	+= " @cContra, "
EndIf
cProcCT2	+= " @cCusto, "
cProcCT2	+= " @cItem, "
cProcCT2	+= " @cCLVL, "
cProcCT2	+= " @cCT2_HIST, "
cProcCT2	+= " @cCT2_EMPORI, "
cProcCT2	+= " @cCT2_FILORI, "
cProcCT2	+= " @cCT2_SEQHIS, "
cProcCT2	+= " @cCT2_SEQLAN, "
cProcCT2	+= " '0', "

If cPaisLoc $ "CHI|ARG"  .or. (cPaisLoc $ "BRA"  .and. !Empty(__cSegOfi) .And. __cSegOfi != "0")
	cProcCT2	+= " @cCT2_SEGOFI, "
Endif
If Empty(c2Moeda)	//Se nao for Razao em 2 Moedas
	If cTipo == "1"
		cProcCT2	+= " @nLancDeb, "
	EndIf
	If cTipo == "2"
		cProcCT2	+= " @nLancCrd, "
	EndIf
Else	//Se for Razao em 2 Moedas
	If (nTipo = 1 .Or. nTipo = 3) //Se Imprime Valor na Moeda ou ambos
		If cTipo == "1"
			cProcCT2	+= " @nLancDeb, "
		Else
			cProcCT2	+= " @nLancCrd, "
		EndIf
	EndIf
    If (nTipo = 2 .Or. nTipo = 3) //Se Imprime Moeda Corrente ou Ambas
		If cTipo == "1"
			cProcCT2	+= " @nLancDeb_1, "
		Else
			cProcCT2	+= " @nLancCrd_1, "
		Endif
	EndIf
EndIf
cProcCT2	+= " @iRecnoCT2 "
cProcCT2	+= ")" + CRLF    //acabou a inclusao
cProcCT2	+= "         select @iCommit = @iCommit + 1"+CRLF

cProcCT2	+= "      end else begin	"+ CRLF
			//UPDATE CASO ENCONTRE O RECNO JA GRAVADO NA TABELA CARQTMP
If Empty(c2Moeda)	//Se nao for Razao em 2 Moedas
	If cTipo == "1"
		cProcCT2	+= "         SELECT @nLancDeb = @nCT2_VALOR  "+CRLF
	EndIf
	If cTipo == "2"
		cProcCT2	+= "         SELECT @nLancCrd = @nCT2_VALOR  "+CRLF
	EndIf
Else	//Se for Razao em 2 Moedas
	If (nTipo = 1 .Or. nTipo = 3) //Se Imprime Valor na Moeda ou ambos
		If cTipo == "1"
			cProcCT2	+= "       if @cCT2_MOEDLC = '"+cMoeda+"' "
			cProcCT2	+= " SELECT @nLancDeb =  @nCT2_VALOR "+CRLF
		Else
			cProcCT2	+= "      if @cCT2_MOEDLC = '"+cMoeda+"' "
			cProcCT2	+= " SELECT @nLancCrd = @nCT2_VALOR "+CRLF
		EndIf
	EndIf
	If (nTipo = 2 .Or. nTipo = 3) //Se Imprime Moeda Corrente ou Ambas
		If cTipo == "1"
			cProcCT2	+= "      if @cCT2_MOEDLC = '"+c2Moeda+"' "
			cProcCT2	+= " SELECT @nLancDeb_1 =  @nCT2_VALOR "+CRLF
		Else
			cProcCT2	+= "      if @cCT2_MOEDLC = '"+c2Moeda+"' "
			cProcCT2	+= " SELECT @nLancCrd_1 = @nCT2_VALOR "+CRLF
		Endif
	EndIf
EndIf

cProcCT2	+= "        UPDATE "+cArqTmp + " SET "

If Empty(c2Moeda)	//Se nao for Razao em 2 Moedas
	If cTipo == "1"
		cProcCT2	+= " LANCDEB = LANCDEB + @nLancDeb "+CRLF
	EndIf
	If cTipo == "2"
		cProcCT2	+= " LANCCRD = LANCCRD + @nLancCrd "+CRLF
	EndIf
Else	//Se for Razao em 2 Moedas
	If (nTipo = 1 .Or. nTipo = 3) //Se Imprime Valor na Moeda ou ambos
		If cTipo == "1"
			cProcCT2	+= " LANCDEB = LANCDEB + @nLancDeb "+CRLF
		Else
			cProcCT2	+= " LANCCRD = LANCCRD + @nLancCrd "+CRLF
		EndIf
	EndIf
    If (nTipo = 2 .Or. nTipo = 3) //Se Imprime Moeda Corrente ou Ambas
    	If nTipo = 3
			cProcCT2	+= ", "
		EndIf
		If cTipo == "1"
			cProcCT2	+= " LANCDEB_1 = LANCDEB_1 + @nLancDeb_1 "+CRLF
		Else
			cProcCT2	+= " LANCCRD_1 = LANCCRD_1 + @nLancCrd_1 "+CRLF
		Endif
	EndIf
EndIf
cProcCT2	+= "        WHERE R_E_C_N_O_ = @iAuxRecno "+ CRLF
cProcCT2	+= "         select @iCommit = @iCommit + 1"+CRLF
cProcCT2	+= "     end"+ CRLF

If ! Empty(c2Moeda)

	cProcCT2 += "      if @iInclui = 1 begin"+CRLF   //neste update utiliza a variave @iRecno
        //neste update utiliza a variave @iRecno

        //armazena os valores gravados na variavel
	cProcCT2 += "         SELECT @nLancDeb = LANCDEB, @nLancCrd = LANCCRD"
	cProcCT2 += " , @nLancDeb_1 = LANCDEB_1, @nLancCrd_1 = LANCCRD_1 "+CRLF
	cProcCT2 += "          FROM "+cArqTmp+" WHERE R_E_C_N_O_ = @iRecno "+CRLF

	cProcCT2 += "         if @nLancDeb_1 <> 0 AND @nLancDeb <> 0 "
	cProcCT2 += " SELECT @nTxDebito = @nLancDeb_1 / @nLancDeb "+CRLF

	cProcCT2 += "         if @nLancCrd_1 <> 0 AND @nLancCrd <> 0 "
	cProcCT2 += " SELECT @nTxCredito = @nLancCrd_1 / @nLancCrd "+CRLF

	cProcCT2 += "         if @nLancDeb + @nLancDeb_1 + @nLancCrd + @nLancCrd_1 = 0 "
	cProcCT2 += " SELECT @cDelet_ = '*' "+CRLF

	//agora vai avaliar os campos LANC_DEB1 / LANCCRD_1 para gravar taxa debito / credito quando Empty(c2Moeda)
	cProcCT2 += " UPDATE "+cArqTmp + " SET "
	cProcCT2 += " 	TXDEBITO = @nTxDebito, "
	cProcCT2 += "	TXCREDITO = @nTxCredito , "
	cProcCT2 += "	D_E_L_E_T_ = @cDelet_ "+ CRLF
	cProcCT2 += " WHERE R_E_C_N_O_ = @iRecno "+ CRLF

	cProcCT2 += "         select @iCommit = @iCommit + 1"+CRLF
	cProcCT2 += "      end else begin "+ CRLF//neste update utiliza a variave @iAuxRecno

	//agora vai avaliar os campos LANC_DEB1 / LANCCRD_1 para gravar taxa debito / credito quando Empty(c2Moeda)
	//armazena os valores gravados na variavel
	cProcCT2 += "         SELECT @nLancDeb = LANCDEB, @nLancCrd = LANCCRD "
	cProcCT2 += " , @nLancDeb_1 = LANCDEB_1, @nLancCrd_1 = LANCCRD_1 "+CRLF
	cProcCT2 += "           FROM "+cArqTmp+" WHERE R_E_C_N_O_ = @iAuxRecno "+CRLF

	cProcCT2 += "         if @nLancDeb_1 <> 0 AND @nLancDeb <> 0 "
	cProcCT2 += " SELECT @nTxDebito = @nLancDeb_1 / @nLancDeb "+CRLF

	cProcCT2 += "         if @nLancCrd_1 <> 0 AND @nLancCrd <> 0 "
	cProcCT2 += " SELECT @nTxCredito = @nLancCrd_1 / @nLancCrd "+CRLF

	cProcCT2 += "         if @nLancDeb + @nLancDeb_1 + @nLancCrd + @nLancCrd_1 = 0 "
	cProcCT2 += " SELECT @cDelet_ = '*' "+CRLF

  	cProcCT2 += "         UPDATE "+cArqTmp + " SET "
	cProcCT2 += " TXDEBITO = @nTxDebito, "
	cProcCT2 += " TXCREDITO =@nTxCredito , "
	cProcCT2 += " D_E_L_E_T_ = @cDelet_ "+CRLF
	cProcCT2 += "         WHERE R_E_C_N_O_ = @iAuxRecno "+ CRLF
	cProcCT2 += "         select @iCommit = @iCommit + 1"+CRLF

	cProcCT2 += "      end "+ CRLF

Else

	cProcCT2 += "      if @iInclui = 1 begin"+CRLF   //neste update utiliza a variave @iRecno
        //neste update utiliza a variave @iRecno

        //armazena os valores gravados na variavel
	cProcCT2 += "         SELECT @nLancDeb = LANCDEB, @nLancCrd = LANCCRD "
	If !Empty(c2Moeda)
		cProcCT2 += " , @nLancDeb_1 = LANCDEB_1, @nLancCrd_1 = LANCCRD_1 "+CRLF
	EndIf
	cProcCT2 += "           FROM "+cArqTmp+" WHERE R_E_C_N_O_ = @iRecno "+CRLF

	If nTipo = 1
		cProcCT2 += "         if @nLancDeb + @nLancCrd = 0 "
		cProcCT2 += " SELECT @cDelet_ = '*' "+CRLF
	ElseIf nTipo = 2
		cProcCT2 += "         if @nLancDeb_1 + @nLancCrd_1 = 0 "
		cProcCT2 += "	SELECT @cDelet_ = '*' "+CRLF
	Endif

  	cProcCT2 += "         UPDATE "+cArqTmp + " SET "
	cProcCT2 += " D_E_L_E_T_ = @cDelet_ "+CRLF
	cProcCT2 += "         WHERE R_E_C_N_O_ = @iRecno "+ CRLF
	cProcCT2 += "         select @iCommit = @iCommit + 1"+CRLF

	cProcCT2 += "      end else begin	"+ CRLF//neste update utiliza a variave @iAuxRecno
	//agora vai avaliar os campos LANC_DEB1 / LANCCRD_1 para gravar taxa debito / credito quando Empty(c2Moeda)
	//armazena os valores gravados na variavel
	cProcCT2 += "         SELECT @nLancDeb = LANCDEB, @nLancCrd = LANCCRD "
	If !Empty(c2Moeda)
		cProcCT2 += " , @nLancDeb_1 = LANCDEB_1, @nLancCrd_1 = LANCCRD_1 "
	EndIf
	cProcCT2 += " FROM "+cArqTmp+" WHERE R_E_C_N_O_ = @iAuxRecno "+CRLF
	If nTipo = 1
		cProcCT2 += "         if @nLancDeb  + @nLancCrd = 0 "
		cProcCT2 += " SELECT @cDelet_ = '*' "+CRLF
	ElseIf nTipo = 2
		cProcCT2 += "         if @nLancDeb_1 + @nLancCrd_1 = 0 "
		cProcCT2 += " SELECT @cDelet_ = '*' "+CRLF
	Endif

   	cProcCT2 += "         UPDATE "+cArqTmp + " SET "
	cProcCT2 += " D_E_L_E_T_ = @cDelet_ " +CRLF
	cProcCT2 += "          WHERE R_E_C_N_O_ = @iAuxRecno "+ CRLF
	cProcCT2 += "         select @iCommit = @iCommit + 1"+CRLF
	cProcCT2 += "      end"+ CRLF

Endif

Return

//-------------------------------------------------------------------
/*{Protheus.doc}CTBR400
Relatorio Razao - Carrega no array aCposCT2 os nomes dos campos
Static Function CtbR400Cpos(aCposCT2, aStru)
@author Paulo Carnelossi - Totvs
@since  04/11/2015
@version 11.8
*/
//-------------------------------------------------------------------
Static Function CtbR400Cpos(aCposCT2, aStru)
Local nX
//carrega array campos da CT2
For nX := 1 TO Len(aStru)
	// desconsidera os campos que forem memo
	If aStru[nX][2] <> "M"
		aAdd(aCposCT2, Alltrim(aStru[nX][1]) )
	EndIf
Next

Return

//-------------------------------------------------------------------
/*{Protheus.doc}CTBR400
Relatorio Razao - Carrega no array aVarsCT@ as variaveis referente campos CT2
Static Function CtbR400Vars(aVarsCT2, aStru)
@author Paulo Carnelossi - Totvs
@since  04/11/2015
@version 11.8
*/
//-------------------------------------------------------------------
Static Function CtbR400Vars(aVarsCT2, aStru)
Local nX
Local cVarProc

//carrega array aVarsCT2  - variaveis para uso na procedure /cursor
For nX := 1 TO Len(aStru)
	cVarProc := ""
	If 		aStru[nX][2] == "C"
		cVarProc 	:= "@c"
	Elseif 	aStru[nX][2] == "N"
		cVarProc 	:= "@n"
	Elseif 	aStru[nX][2] == "D"
		cVarProc 	:= "@c"
	Elseif 	aStru[nX][2] == "L"
		cVarProc 	:= "@l"
	Endif

	// adiciona no array de variaveis apenas campos tratados
	If ! Empty(cVarProc)
		aAdd(aVarsCT2, cVarProc+Alltrim(aStru[nX][1]) )
	EndIf
Next

Return

//-------------------------------------------------------------------
/*{Protheus.doc}CTBR400
Relatorio Razao - Declare das variaveis ref cpos CT2 para utilizar na procedure
Static Function CtbR400Decl(cProcCT2, aStru)
@author Paulo Carnelossi - Totvs
@since  04/11/2015
@version 11.8
*/
//-------------------------------------------------------------------
Static Function CtbR400Decl(cProcCT2, aStru)
Local nX
Local cVarProc

//declare as variaveis correspondente aos campos da tabela CT2
For nX := 1 TO Len(aStru)
	cVarProc := ""
	If 		aStru[nX][2] == "C"
		cVarProc 	:= "@c"
		cProcCt2 	+= "Declare "+cVarProc+Alltrim(aStru[nX][1])+" char(" + Alltrim(Str(aStru[nX][3])) + ")" + CRLF

	Elseif 	aStru[nX][2] == "N"
		cVarProc 	:= "@n"
		cProcCt2 	+= "Declare "+cVarProc+Alltrim(aStru[nX][1])+" float" + CRLF

	Elseif 	aStru[nX][2] == "D"
		cVarProc 	:= "@c"
		cProcCt2 	+= "Declare "+cVarProc+Alltrim(aStru[nX][1])+" char(8)" + CRLF
	Elseif 	aStru[nX][2] == "L"
		cVarProc 	:= "@l"
		cProcCt2 	+= "Declare "+cVarProc+Alltrim(aStru[nX][1])+" char(1)" + CRLF
	Endif
Next

Return


/*
�����������������������������������������������������������������������������
���Fun��o	 � CTR400SldP  � Autor �                   	� Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Balancete Centro de Custo/Conta         			 		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR400()    											  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nenhum       											  ���
�������������������������������������������������������������������������Ĵ��
���Uso 		 � SIGACTB      											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�       													  ���
�����������������������������������������������������������������������������
*/
Static Function CTR400SldP(cTmpProc, aSelFil, lTodasFil, cTmpCTX, cTmpFil ,cTmpCq1)
Local lRet    := .T.
Local cRet    := 0
Local cQuery := ""
Local cIsNull := Iif( Alltrim(TcGetDB()) == "DB2" , "COALESCE" , "ISNULL" )
Local cRngFilCq1 := ""

Default cTmpCq1 := ""

if aSelFil != NIL .and. Len(aSelFil) > 0   //Busco o range de filiais selecionado | caso for maior que 50 retorna a cria��o de um temporario no BD
	cRngFilCq1:=  GetRngFil( aSelFil ,"CQ1",.T.,@cTmpCq1) 
Else // o modo de compartilhamento da tabela cq1 deve ser o mesmo para todas as CQS 
	cRngFilCq1:=   " = '" + xFilial("CQ1") +"' "
EndIF

cTmpProc:= CriaTrab(,.F.)
cTmpProc:= cTmpProc+'SLD'+"_"+cEmpAnt

cQuery := "Create Procedure "+cTmpProc+" ( "+CRLF
cQuery += "   @IN_FILIAL        Char( "+StrZero(TamSx3("CQ1_FILIAL")[1],3)+" ),"+CRLF
cQuery += "   @IN_TABELA        Char( 03 ),"+CRLF
cQuery += "   @IN_CONTA         Char( "+StrZero(TamSx3("CQ1_CONTA")[1],3)+" ),"+CRLF
cQuery += "   @IN_CUSTO         Char( "+StrZero(TamSx3("CQ3_CCUSTO")[1],3)+" ),"+CRLF
cQuery += "   @IN_ITEM          Char( "+StrZero(TamSx3("CQ5_ITEM")[1],3)+" ),"+CRLF
cQuery += "   @IN_CLVL          Char( "+StrZero(TamSx3("CQ7_CLVL")[1],3)+" ),"+CRLF
cQuery += "   @IN_TPSALDO       Char( "+StrZero(TamSx3("CQ1_TPSALD")[1],3)+" ),"+CRLF
cQuery += "   @IN_MOEDA         Char( "+StrZero(TamSx3("CQ1_MOEDA")[1],3)+" ),"+CRLF
cQuery += "   @IN_DATATMP       Char( 08 ),"+CRLF
cQuery += "   @OUT_SLDATU       Float OutPut,"+CRLF
cQuery += "   @OUT_DEBDATA      Float OutPut,"+CRLF
cQuery += "   @OUT_CREDATA      Float OutPut,"+CRLF
cQuery += "   @OUT_SLDATUDEB    Float OutPut,"+CRLF
cQuery += "   @OUT_SLDATUCRE    Float OutPut,"+CRLF
cQuery += "   @OUT_SLDANT       Float OutPut,"+CRLF
cQuery += "   @OUT_SLDANTDEB    Float OutPut,"+CRLF
cQuery += "   @OUT_SLDANTCRE    Float OutPut "+CRLF

cQuery += ")"+CRLF
/* ------------------------------------------------------------------------------------
    Vers�o          - <v>  Protheus P.11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBxfun.PRW </s>
    Procedure       -      Saldoct7fil
    Descricao       - <d>  Saldos base anterior a debito e credito </d>
    Funcao do Siga  -      SALDOCT7FIL ---> CT7/CT3/CT4/CTI - Saldo anterior a debito e credito de saldos base
    Entrada         - <ri> @IN_FILIAL     - Filial Corrente
                           @IN_TABELA     - Tabela
                           @IN_CONTA      - Conta que tera os dados gerados
                           @IN_CUSTO      - Ccusto que tera os dados gerados
                           @IN_ITEM       - Item que tera os dados gerados
                           @IN_CLVL       - Clvl que tera os dados gerados
                           @IN_TPSALDO    - Tipo de Saldo
                           @IN_MOEDA      - Moeda
                           @IN_DATATMP    - Data do TMP
    Saida           - <o>  @OUT_SLDATU    - [1] Saldo Atual (com sinal)
                           @OUT_DEBDATA   - [2] Debito na Data
                           @OUT_CREDATA   - [3] Credito na Data
                           @OUT_SLDATUDEB - [4] Saldo Atual Devedor
                           @OUT_SLDATUCRE - [5] Saldo Atual Credor
                           @OUT_SLDANT    - [6] Saldo Anterior (com sinal)
                           @OUT_SLDANTDEB - [7] Saldo Anterior Devedor
                           @OUT_SLDANTCRE - [8] Saldo Anterior Credor
                           @OUT_SLDATUANT    - [9] Saldo Atual (com sinal)
    Responsavel :     <r>  	</r>
         //������������������������������������������������������Ŀ
         //� Retorno para o array aSaldo - @IN_DATATMP            �
         //� [1] Saldo Atual (com sinal)                          �
         //� [2] Debito na Data                                   �
         //� [3] Credito na Data                                  �
         //� [4] Saldo Atual Devedor                              �
         //� [5] Saldo Atual Credor                               �
         //� [6] Saldo Anterior (com sinal)                       �
         //� [7] Saldo Anterior Devedor                           �
         //� [8] Saldo Anterior Credor                            �
        //��������������������������������������������������������
         //      [1]       [2]     [3]      [4]     [5]     [6]       [7]     [8]
         Return {nSaldoAtu,nDebito,nCredito,nAtuDeb,nAtuCrd,nSaldoAnt,nAntDeb,nAntCrd}
         ---------------------------------------------------------
    --------------------------------------------------------------------------- */
cQuery += "as"+CRLF
cQuery += "Declare @cAux  Char( 03 )"+CRLF
// cQuery += "declare @cFilial_CQ3 Char( "+StrZero(TamSx3("CQ3_FILIAL")[1],3)+" )"+CRLF //apos remo��o da callxfilial nao precisa declarar as variaveis
// cQuery += "declare @cFilial_CQ5 Char( "+StrZero(TamSx3("CQ5_FILIAL")[1],3)+" )"+CRLF
// cQuery += "declare @cFilial_CQ1 Char( "+StrZero(TamSx3("CQ1_FILIAL")[1],3)+" )"+CRLF
// cQuery += "declare @cFilial_CQ7 Char( "+StrZero(TamSx3("CQ7_FILIAL")[1],3)+" )"+CRLF
cQuery += "declare @cConta      Char( "+StrZero(TamSx3("CQ1_CONTA")[1],3)+" )"+CRLF
cQuery += "declare @cCusto      Char( "+StrZero(TamSx3("CQ3_CCUSTO")[1],3)+" )"+CRLF
cQuery += "declare @cItem       Char( "+StrZero(TamSx3("CQ5_ITEM")[1],3)+" )"+CRLF
cQuery += "declare @cClVl       Char( "+StrZero(TamSx3("CQ7_CLVL")[1],3)+" )"+CRLF
cQuery += "declare @nSldAtu     Float"+CRLF
cQuery += "declare @nAtuDeb     Float"+CRLF
cQuery += "declare @nAtuCrd     Float"+CRLF
cQuery += "declare @nDebito     Float"+CRLF
cQuery += "declare @nCredito    Float"+CRLF
cQuery += "declare @nSldAnt     Float"+CRLF
cQuery += "declare @nAntDeb     Float"+CRLF
cQuery += "declare @nAntCrd     Float"+CRLF
cQuery += ""+CRLF
cQuery += "begin"+CRLF
cQuery += "   "+CRLF
cQuery += "   Select @OUT_SLDATU    = 0"+CRLF
cQuery += "   Select @OUT_DEBDATA   = 0"+CRLF
cQuery += "   Select @OUT_CREDATA   = 0"+CRLF
cQuery += "   Select @OUT_SLDATUDEB = 0"+CRLF
cQuery += "   Select @OUT_SLDATUCRE = 0"+CRLF
cQuery += "   Select @OUT_SLDANT    = 0"+CRLF
cQuery += "   Select @OUT_SLDANTDEB = 0"+CRLF
cQuery += "   Select @OUT_SLDANTCRE = 0"+CRLF

cQuery += "   Select @nSldAtu       = 0"+CRLF
cQuery += "   Select @nAtuDeb       = 0"+CRLF
cQuery += "   Select @nAtuCrd       = 0"+CRLF
cQuery += "   Select @nDebito       = 0"+CRLF
cQuery += "   Select @nCredito      = 0"+CRLF
cQuery += "   Select @nSldAnt       = 0"+CRLF
cQuery += "   Select @nAntDeb       = 0"+CRLF
cQuery += "   Select @nAntCrd       = 0"+CRLF
cQuery += "   Select @cConta        = ' '"+CRLF
cQuery += "   Select @cCusto        = ' '"+CRLF
cQuery += "   Select @cItem         = ' '"+CRLF
cQuery += "   Select @cClVl         = ' '"+CRLF


//---------------------------------------inicio da query por conta contabil---------------------------------//
   /*---------------------------------------------------------------
     C�lculo de valores - CQ1
     --------------------------------------------------------------- */
cQuery += "   If @IN_TABELA = 'CQ1' begin"+CRLF
// cQuery += "      select @cAux = 'CQ1'"+CRLF
// cQuery += "	     exec "+cTmpFil +" @cAux, @IN_FILIAL, @cFilial_CQ1 OutPut"+CRLF
      /* ---------------------------------------------------------------
        Retorno para aSaldo -> DEBITO / CREDITO =  @IN_DATATMP
         --------------------------------------------------------------- */
cQuery += "      Select @cConta = CQ1_CONTA, @nDebito = " + cIsNull + "(SUM(CQ1_DEBITO),0), @nCredito = " + cIsNull + "(SUM(CQ1_CREDIT), 0) "+CRLF
cQuery += "        From "+RetSqlName("CQ1")+" CQ1 "+CRLF
cQuery += "      Where CQ1.CQ1_FILIAL "+ cRngFilCq1 +" "+CRLF
cQuery += "        and CQ1.CQ1_MOEDA  = @IN_MOEDA"+CRLF
cQuery += "        and CQ1.CQ1_TPSALD = @IN_TPSALDO"+CRLF
cQuery += "        and CQ1.CQ1_CONTA  = @IN_CONTA"+CRLF
cQuery += "        and CQ1.D_E_L_E_T_ = ' '"+CRLF
cQuery += "        and CQ1.CQ1_DATA   = @IN_DATATMP"+CRLF
// removido filtro de Lucros e perdas que causavam erro na composi��o do saldo anterior
// cQuery += "        and CQ1.CQ1_LP = (Select MAX(CQ1_LP)"+CRLF
// cQuery += "                            from "+RetSqlName("CQ1")+" CQ13"+CRLF
// cQuery += "                           Where CQ13.CQ1_FILIAL = CQ1.CQ1_FILIAL"+CRLF
// cQuery += "                             and CQ13.CQ1_MOEDA  = @IN_MOEDA"+CRLF
// cQuery += "                             and CQ13.CQ1_TPSALD = @IN_TPSALDO"+CRLF
// cQuery += "                             and CQ13.CQ1_CONTA  = @IN_CONTA"+CRLF
// cQuery += "                             and CQ13.CQ1_DATA   = @IN_DATATMP"+CRLF
// cQuery += "                             and CQ13.D_E_L_E_T_ = ' ')"+CRLF
cQuery += "      Group by CQ1_CONTA"+CRLF
cQuery += "      "+CRLF
      /* ---------------------------------------------------------------
        Retorno para aSaldo -> DEBITO / CREDITO <  @IN_DATATMP
         --------------------------------------------------------------- */
cQuery += "      Select @cConta = CQ1_CONTA, @nAntDeb = " + cIsNull + "(SUM(CQ1_DEBITO),0), @nAntCrd = " + cIsNull + "(SUM(CQ1_CREDIT), 0) "+CRLF
cQuery += "        From "+RetSqlName("CQ1")+" CQ1 "+CRLF
cQuery += "      Where CQ1.CQ1_FILIAL "+ cRngFilCq1 +" "+CRLF
cQuery += "        and CQ1.CQ1_MOEDA  = @IN_MOEDA"+CRLF
cQuery += "        and CQ1.CQ1_TPSALD = @IN_TPSALDO"+CRLF
cQuery += "        and CQ1.CQ1_CONTA  = @IN_CONTA"+CRLF
cQuery += "        and CQ1.D_E_L_E_T_ = ' '"+CRLF
cQuery += "        and CQ1.CQ1_DATA   < @IN_DATATMP"+CRLF
// removido filtro de Lucros e perdas que causavam erro na composi��o do saldo anterior
// cQuery += "        and CQ1.CQ1_LP = (Select MAX(CQ1_LP)"+CRLF
// cQuery += "                            from "+RetSqlName("CQ1")+" CQ13"+CRLF
// cQuery += "                           Where CQ13.CQ1_FILIAL = CQ1.CQ1_FILIAL"+CRLF
// cQuery += "                             and CQ13.CQ1_MOEDA  = @IN_MOEDA"+CRLF
// cQuery += "                             and CQ13.CQ1_TPSALD = @IN_TPSALDO"+CRLF
// cQuery += "                             and CQ13.CQ1_CONTA  = @IN_CONTA"+CRLF
// cQuery += "                             and CQ13.CQ1_DATA   < @IN_DATATMP"+CRLF
// cQuery += "                             and CQ13.D_E_L_E_T_ = ' ')"+CRLF
cQuery += "      Group by CQ1_CONTA"+CRLF
cQuery += "      "+CRLF

//C�lculo de saldos, removido da query por conta do MSPARSE
cQuery += "      Select @nSldAnt = @nAntCrd - @nAntDeb"+CRLF
cQuery += "      Select @nAtuCrd = @nAntCrd + @nCredito"+CRLF
cQuery += "      Select @nAtuDeb = @nAntDeb + @nDebito"+CRLF
cQuery += "      Select @nSldAtu = @nAtuCrd - @nAtuDeb"+CRLF

cQuery += "      Select @OUT_SLDATU    = @nSldAtu"+CRLF
cQuery += "      Select @OUT_DEBDATA   = @nDebito"+CRLF
cQuery += "      Select @OUT_CREDATA   = @nCredito"+CRLF
cQuery += "      Select @OUT_SLDATUDEB = @nAtuDeb"+CRLF
cQuery += "      Select @OUT_SLDATUCRE = @nAtuCrd"+CRLF
cQuery += "      Select @OUT_SLDANT    = @nSldAnt"+CRLF
cQuery += "      Select @OUT_SLDANTDEB = @nAntDeb"+CRLF
cQuery += "      Select @OUT_SLDANTCRE = @nAntCrd"+CRLF
cQuery += "   end"+CRLF
//---------------------------------------final da query por conta contabil---------------------------------//

//--------------------------------------inicio da query por centro de custo-------------------------------//
   /*---------------------------------------------------------------
     C�lculo de valores  - CQ3 - CENTRO DE CUSTOS
     Retorno para aSaldo - @IN_DATATMP
     --------------------------------------------------------------- */
cQuery += "   If @IN_TABELA = 'CQ3' begin"+CRLF
// cQuery += "      select @cAux = 'CQ3'"+CRLF
// cQuery += "      exec "+cTmpFil +" @cAux, @IN_FILIAL, @cFilial_CQ3 OutPut"+CRLF
// cQuery += "      "+CRLF
cQuery += "      Select @cConta = CQ3_CONTA, @cCusto = CQ3_CCUSTO, @nDebito = " + cIsNull + "(SUM(CQ3_DEBITO), 0), @nCredito = " + cIsNull + "(SUM(CQ3_CREDIT), 0) "+CRLF
cQuery += "       From "+RetSqlName("CQ3")+" CQ3"+CRLF
cQuery += "       Where CQ3.CQ3_FILIAL "+cRngFilCq1+" "+CRLF
cQuery += "         and CQ3.CQ3_MOEDA  = @IN_MOEDA"+CRLF
cQuery += "         and CQ3.CQ3_TPSALD = @IN_TPSALDO"+CRLF
cQuery += "         and CQ3.CQ3_CONTA  = @IN_CONTA"+CRLF
cQuery += "         and CQ3.CQ3_CCUSTO  = @IN_CUSTO"+CRLF
cQuery += "         and CQ3.D_E_L_E_T_ = ' '"+CRLF
cQuery += "         and CQ3.CQ3_DATA =  @IN_DATATMP"+CRLF
// removido filtro de Lucros e perdas que causavam erro na composi��o do saldo anterior
// cQuery += "         and CQ3.CQ3_LP = (Select Max(CQ3_LP)"+CRLF
// cQuery += "                             From "+RetSqlName("CQ3")+" CQ33"+CRLF
// cQuery += "                            Where CQ33.CQ3_FILIAL = CQ3.CQ3_FILIAL"+CRLF
// cQuery += "                              and CQ33.CQ3_MOEDA  = @IN_MOEDA"+CRLF
// cQuery += "                              and CQ33.CQ3_TPSALD = @IN_TPSALDO"+CRLF
// cQuery += "                              and CQ33.CQ3_CONTA  = @IN_CONTA"+CRLF
// cQuery += "                              and CQ33.CQ3_CCUSTO  = @IN_CUSTO"+CRLF
// cQuery += "                              and CQ33.CQ3_DATA   = @IN_DATATMP"+CRLF
// cQuery += "                              and CQ33.D_E_L_E_T_ = ' ')"+CRLF
cQuery += "      Group by CQ3_CONTA, CQ3_CCUSTO"+CRLF
cQuery += "      "+CRLF

cQuery += "      Select @cConta = CQ3_CONTA, @cCusto = CQ3_CCUSTO, @nAntDeb = " + cIsNull + "(SUM(CQ3_DEBITO), 0), @nAntCrd = " + cIsNull + "(SUM(CQ3_CREDIT), 0) "+CRLF
cQuery += "       From "+RetSqlName("CQ3")+" CQ3"+CRLF
cQuery += "       Where CQ3.CQ3_FILIAL "+cRngFilCq1+" "+CRLF
cQuery += "         and CQ3.CQ3_MOEDA  = @IN_MOEDA"+CRLF
cQuery += "         and CQ3.CQ3_TPSALD = @IN_TPSALDO"+CRLF
cQuery += "         and CQ3.CQ3_CONTA  = @IN_CONTA"+CRLF
cQuery += "         and CQ3.CQ3_CCUSTO  = @IN_CUSTO"+CRLF
cQuery += "         and CQ3.D_E_L_E_T_ = ' '"+CRLF
cQuery += "         and CQ3.CQ3_DATA   < @IN_DATATMP"+CRLF
// removido filtro de Lucros e perdas que causavam erro na composi��o do saldo anterior
// cQuery += "         and CQ3.CQ3_LP = (Select Max(CQ3_LP)"+CRLF
// cQuery += "                             From "+RetSqlName("CQ3")+" CQ33"+CRLF
// cQuery += "                            Where CQ33.CQ3_FILIAL = CQ3.CQ3_FILIAL"+CRLF
// cQuery += "                              and CQ33.CQ3_MOEDA  = @IN_MOEDA"+CRLF
// cQuery += "                              and CQ33.CQ3_TPSALD = @IN_TPSALDO"+CRLF
// cQuery += "                              and CQ33.CQ3_CONTA  = @IN_CONTA"+CRLF
// cQuery += "                              and CQ33.CQ3_CCUSTO  = @IN_CUSTO"+CRLF
// cQuery += "                              and CQ33.CQ3_DATA   < @IN_DATATMP"+CRLF
// cQuery += "                              and CQ33.D_E_L_E_T_ = ' ')"+CRLF
cQuery += "      Group by CQ3_CONTA, CQ3_CCUSTO"+CRLF
cQuery += "      "+CRLF

//C�lculo de saldos, removido da query por conta do MSPARSE
cQuery += "      Select @nAtuCrd = @nAntCrd + @nCredito"+CRLF
cQuery += "      Select @nAtuDeb = @nAntDeb + @nDebito"+CRLF
cQuery += "      Select @nSldAtu = @nAtuCrd - @nAtuDeb"+CRLF
cQuery += "      Select @nSldAnt = @nAntCrd - @nAntDeb"+CRLF

cQuery += "      Select @OUT_SLDATU    = @nSldAtu"+CRLF
cQuery += "      Select @OUT_DEBDATA   = @nDebito"+CRLF
cQuery += "      Select @OUT_CREDATA   = @nCredito"+CRLF
cQuery += "      Select @OUT_SLDATUDEB = @nAtuDeb"+CRLF
cQuery += "      Select @OUT_SLDATUCRE = @nAtuCrd"+CRLF
cQuery += "      Select @OUT_SLDANT    = @nSldAnt"+CRLF
cQuery += "      Select @OUT_SLDANTDEB = @nAntDeb"+CRLF
cQuery += "      Select @OUT_SLDANTCRE = @nAntCrd"+CRLF
cQuery += "   end"+CRLF
//--------------------------------------final da query por centro de custo-------------------------------//

//--------------------------------------inicio da query por item contabil--------------------------------//
   /*---------------------------------------------------------------
     C�lculo de valores  - CQ5 - Item
     Retorno para aSaldo - @IN_DATATMP
     --------------------------------------------------------------- */
cQuery += "   If @IN_TABELA = 'CQ5' begin"+CRLF
// cQuery += "      select @cAux = 'CQ5'"+CRLF
// cQuery += "      exec "+cTmpFil +" @cAux, @IN_FILIAL, @cFilial_CQ5 OutPut"+CRLF
// cQuery += "      "+CRLF
cQuery += "      Select @cConta = CQ5_CONTA, @cCusto = CQ5_CCUSTO, @cItem = CQ5_ITEM, @nDebito = " + cIsNull + "(SUM(CQ5_DEBITO), 0), @nCredito = " + cIsNull + "(SUM(CQ5_CREDIT), 0) "+CRLF
cQuery += "        From "+RetSqlName("CQ5")+" CQ5"+CRLF
cQuery += "      Where CQ5.CQ5_FILIAL "+cRngFilCq1+ " "+CRLF
cQuery += "         and CQ5.CQ5_MOEDA  = @IN_MOEDA"+CRLF
cQuery += "         and CQ5.CQ5_CONTA  = @IN_CONTA"+CRLF
cQuery += "         and CQ5.CQ5_CCUSTO  = @IN_CUSTO"+CRLF
cQuery += "         and CQ5.CQ5_ITEM   = @IN_ITEM"+CRLF
cQuery += "         and CQ5.D_E_L_E_T_ = ' '"+CRLF
cQuery += "         and CQ5.CQ5_DATA = @IN_DATATMP"+CRLF
// removido filtro de Lucros e perdas que causavam erro na composi��o do saldo anterior
// cQuery += "        and CQ5.CQ5_LP = (Select Max(CQ5_LP)"+CRLF
// cQuery += "                            From "+RetSqlName("CQ5")+" CQ53"+CRLF
// cQuery += "                           Where CQ53.CQ5_FILIAL = CQ5.CQ5_FILIAL"+CRLF
// cQuery += "                             and CQ53.CQ5_MOEDA  = @IN_MOEDA"+CRLF
// cQuery += "                             and CQ53.CQ5_TPSALD = @IN_TPSALDO"+CRLF
// cQuery += "                             and CQ53.CQ5_CONTA  = @IN_CONTA"+CRLF
// cQuery += "                             and CQ53.CQ5_CCUSTO  = @IN_CUSTO"+CRLF
// cQuery += "                             and CQ53.CQ5_ITEM   = @IN_ITEM"+CRLF
// cQuery += "                             and CQ53.CQ5_DATA   = @IN_DATATMP"+CRLF
// cQuery += "                             and CQ53.D_E_L_E_T_ = ' ')"+CRLF
cQuery += "      Group by CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM"+CRLF
cQuery += "      "+CRLF

cQuery += "      Select @cConta = CQ5_CONTA, @cCusto = CQ5_CCUSTO, @cItem = CQ5_ITEM, "+CRLF
cQuery += "             @nAntDeb = " + cIsNull + "(SUM(CQ5_DEBITO), 0), @nAntCrd = " + cIsNull + "(SUM(CQ5_CREDIT), 0)"+CRLF
cQuery += "        From "+RetSqlName("CQ5")+" CQ5"+CRLF
cQuery += "      Where CQ5.CQ5_FILIAL "+cRngFilCq1+" "+CRLF
cQuery += "         and CQ5.CQ5_MOEDA  = @IN_MOEDA"+CRLF
cQuery += "         and CQ5.CQ5_CONTA  = @IN_CONTA"+CRLF
cQuery += "         and CQ5.CQ5_CCUSTO  = @IN_CUSTO"+CRLF
cQuery += "         and CQ5.CQ5_ITEM   = @IN_ITEM"+CRLF
cQuery += "         and CQ5.D_E_L_E_T_ = ' '"+CRLF
cQuery += "         and CQ5.CQ5_DATA < @IN_DATATMP"+CRLF
// removido filtro de Lucros e perdas que causavam erro na composi��o do saldo anterior
// cQuery += "        and CQ5.CQ5_LP = (Select Max(CQ5_LP)"+CRLF
// cQuery += "                            From "+RetSqlName("CQ5")+" CQ53"+CRLF
// cQuery += "                           Where CQ53.CQ5_FILIAL = CQ5.CQ5_FILIAL"+CRLF
// cQuery += "                             and CQ53.CQ5_MOEDA  = @IN_MOEDA"+CRLF
// cQuery += "                             and CQ53.CQ5_TPSALD = @IN_TPSALDO"+CRLF
// cQuery += "                             and CQ53.CQ5_CONTA  = @IN_CONTA"+CRLF
// cQuery += "                             and CQ53.CQ5_CCUSTO  = @IN_CUSTO"+CRLF
// cQuery += "                             and CQ53.CQ5_ITEM   = @IN_ITEM"+CRLF
// cQuery += "                             and CQ53.CQ5_DATA   < @IN_DATATMP"+CRLF
// cQuery += "                             and CQ53.D_E_L_E_T_ = ' ')"+CRLF
cQuery += "      Group by CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM"+CRLF
cQuery += "      "+CRLF

//C�lculo de saldos, removido da query por conta do MSPARSE
cQuery += "      Select @nAtuCrd = @nAntCrd + @nCredito "+CRLF
cQuery += "      Select @nAtuDeb = @nAntDeb + @nDebito "+CRLF

cQuery += "      Select @nSldAtu = @nAtuCrd - @nAtuDeb"+CRLF
cQuery += "      Select @nSldAnt = @nAntCrd - @nAntDeb"+CRLF

cQuery += "      Select @OUT_SLDATU    = @nSldAtu"+CRLF
cQuery += "      Select @OUT_DEBDATA   = @nDebito"+CRLF
cQuery += "      Select @OUT_CREDATA   = @nCredito"+CRLF
cQuery += "      Select @OUT_SLDATUDEB = @nAtuDeb"+CRLF
cQuery += "      Select @OUT_SLDATUCRE = @nAtuCrd"+CRLF
cQuery += "      Select @OUT_SLDANT    = @nSldAnt"+CRLF
cQuery += "      Select @OUT_SLDANTDEB = @nAntDeb"+CRLF
cQuery += "      Select @OUT_SLDANTCRE = @nAntCrd"+CRLF
cQuery += "   end"+CRLF
//--------------------------------------Fim da query por item contabil-----------------------------------//

//--------------------------------------inicio da query por classe de valor--------------------------------//
   /*---------------------------------------------------------------
     C�lculo de valores  - CQ7 - Casse de Valores
     ---------------------------------------------------------------*/
cQuery += "   If @IN_TABELA = 'CQ7' begin"+CRLF
// cQuery += "      select @cAux = 'CQ7'"+CRLF
// cQuery += "      exec "+cTmpFil +" @cAux, @IN_FILIAL, @cFilial_CQ7 OutPut"+CRLF
// cQuery += "      "+CRLF
      /*---------------------------------------------------------------
        Retorno para aSaldo - @IN_DATATMP
        --------------------------------------------------------------- */
cQuery += "      Select @cConta = CQ7_CONTA, @cCusto = CQ7_CCUSTO, @cItem = CQ7_ITEM, @cClVl = CQ7_CLVL,"+CRLF
cQuery += "             @nDebito = " + cIsNull + "(SUM(CQ7_DEBITO), 0), @nCredito = " + cIsNull + "(SUM(CQ7_CREDIT), 0) "+CRLF
cQuery += "        From "+RetSqlName("CQ7")+" CQ7"+CRLF
cQuery += "      Where CQ7.CQ7_FILIAL "+ cRngFilCq1 + " "+CRLF
cQuery += "         and CQ7.CQ7_MOEDA  = @IN_MOEDA"+CRLF
cQuery += "         and CQ7.CQ7_TPSALD = @IN_TPSALDO"+CRLF
cQuery += "         and CQ7.CQ7_CONTA  = @IN_CONTA"+CRLF
cQuery += "         and CQ7.CQ7_CCUSTO  = @IN_CUSTO"+CRLF
cQuery += "         and CQ7.CQ7_ITEM   = @IN_ITEM"+CRLF
cQuery += "         and CQ7.CQ7_CLVL   = @IN_CLVL"+CRLF
cQuery += "         and CQ7.D_E_L_E_T_ = ' '"+CRLF
cQuery += "         and CQ7.CQ7_DATA = @IN_DATATMP"+CRLF
// removido filtro de Lucros e perdas que causavam erro na composi��o do saldo anterior
// cQuery += "         and CQ7.CQ7_LP = (Select Max(CQ7_LP)"+CRLF
// cQuery += "                             From "+RetSqlName("CQ7")+" CQ73"+CRLF
// cQuery += "                            Where CQ73.CQ7_FILIAL = CQ7.CQ7_FILIAL"+CRLF
// cQuery += "                              and CQ73.CQ7_MOEDA  = @IN_MOEDA"+CRLF
// cQuery += "                              and CQ73.CQ7_TPSALD = @IN_TPSALDO"+CRLF
// cQuery += "                              and CQ73.CQ7_CONTA  = @IN_CONTA"+CRLF
// cQuery += "                              and CQ73.CQ7_CCUSTO  = @IN_CUSTO"+CRLF
// cQuery += "                              and CQ73.CQ7_ITEM   = @IN_ITEM"+CRLF
// cQuery += "                              and CQ73.CQ7_CLVL   = @IN_CLVL"+CRLF
// cQuery += "                              and CQ73.CQ7_DATA   = @IN_DATATMP"+CRLF
// cQuery += "                              and CQ73.D_E_L_E_T_ = ' ' )"+CRLF
cQuery += "      Group By CQ7_CONTA, CQ7_CCUSTO, CQ7_ITEM, CQ7_CLVL"+CRLF
cQuery += "      "+CRLF

cQuery += "      Select @cConta = CQ7_CONTA, @cCusto = CQ7_CCUSTO, @cItem = CQ7_ITEM, @cClVl = CQ7_CLVL,"+CRLF
cQuery += "             @nAntDeb = " + cIsNull + "(SUM(CQ7_DEBITO), 0), @nAntCrd = " + cIsNull + "(SUM(CQ7_CREDIT), 0)"+CRLF
cQuery += "        From "+RetSqlName("CQ7")+" CQ7"+CRLF
cQuery += "      Where CQ7.CQ7_FILIAL "+cRngFilCq1+ " "+CRLF
cQuery += "         and CQ7.CQ7_MOEDA  = @IN_MOEDA"+CRLF
cQuery += "         and CQ7.CQ7_TPSALD = @IN_TPSALDO"+CRLF
cQuery += "         and CQ7.CQ7_CONTA  = @IN_CONTA"+CRLF
cQuery += "         and CQ7.CQ7_CCUSTO  = @IN_CUSTO"+CRLF
cQuery += "         and CQ7.CQ7_ITEM   = @IN_ITEM"+CRLF
cQuery += "         and CQ7.CQ7_CLVL   = @IN_CLVL"+CRLF
cQuery += "         and CQ7.D_E_L_E_T_ = ' '"+CRLF
cQuery += "         and CQ7.CQ7_DATA   < @IN_DATATMP"+CRLF
// removido filtro de Lucros e perdas que causavam erro na composi��o do saldo anterior
// cQuery += "         and CQ7.CQ7_LP = (Select Max(CQ7_LP)"+CRLF
// cQuery += "                             From "+RetSqlName("CQ7")+" CQ73"+CRLF
// cQuery += "                            Where CQ73.CQ7_FILIAL = CQ7.CQ7_FILIAL"+CRLF
// cQuery += "                              and CQ73.CQ7_MOEDA  = @IN_MOEDA"+CRLF
// cQuery += "                              and CQ73.CQ7_TPSALD = @IN_TPSALDO"+CRLF
// cQuery += "                              and CQ73.CQ7_CONTA  = @IN_CONTA"+CRLF
// cQuery += "                              and CQ73.CQ7_CCUSTO  = @IN_CUSTO"+CRLF
// cQuery += "                              and CQ73.CQ7_ITEM   = @IN_ITEM"+CRLF
// cQuery += "                              and CQ73.CQ7_CLVL   = @IN_CLVL"+CRLF
// cQuery += "                              and CQ73.CQ7_DATA   < @IN_DATATMP"+CRLF
// cQuery += "                              and CQ73.D_E_L_E_T_ = ' ' )"+CRLF
cQuery += "      Group By CQ7_CONTA, CQ7_CCUSTO, CQ7_ITEM, CQ7_CLVL"+CRLF
cQuery += "      "+CRLF

//C�lculo de saldos, removido da query por conta do MSPARSE
cQuery += "      Select @nSldAtu = @nAtuCrd - @nAtuDeb"+CRLF
cQuery += "      Select @nSldAnt = @nAntCrd - @nAntDeb"+CRLF


cQuery += "      Select @nAtuCrd = @nAntCrd + @nCredito"+CRLF
cQuery += "      Select @nAtuDeb = @nAntDeb + @nDebito"+CRLF

cQuery += "      Select @OUT_SLDATU    = @nSldAtu"+CRLF
cQuery += "      Select @OUT_DEBDATA   = @nDebito"+CRLF
cQuery += "      Select @OUT_CREDATA   = @nCredito"+CRLF
cQuery += "      Select @OUT_SLDATUDEB = @nAtuDeb"+CRLF
cQuery += "      Select @OUT_SLDATUCRE = @nAtuCrd"+CRLF
cQuery += "      Select @OUT_SLDANT    = @nSldAnt"+CRLF
cQuery += "      Select @OUT_SLDANTDEB = @nAntDeb"+CRLF
cQuery += "      Select @OUT_SLDANTCRE = @nAntCrd"+CRLF
cQuery += "   End"+CRLF

//--------------------------------------final da query por classe de valor--------------------------------//

cQuery += "End"+CRLF

cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
If Upper(TcSrvType())= "ISERIES" .and. !Empty( cQuery )
	cQuery := pVldDb2400( cQuery )
EndIf

If Empty( cQuery )
	MsgAlert(MsParseError(),STR0069 +cTmpProc) //'A query nao passou pelo Parse '
	lRet := .F.
Else
	If !TCSPExist( cTmpProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert(STR0073+cTmpProc)  //"Erro na criacao da procedure "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf


Return(lRet)

/* --------------------------------------------------------------------
Funcao xFilial para uso dentro do corpo das procedures dinamicas do PCO
Recebe como parametro as strings das variaveis da procedure a serem
utilizadas : Alias, Filial atual ou default, e filial de retorno
Retorna o corpo da xfilial a ser executado.
OUTRA OBSERVACAO : Deu erro no AS400 , nao sabemos por que. Reclama de passagem de valores null como parametro.
Nao achamos onde era, e trocamos pela query direta. Funciona, sem erro, e torna esse programa
totalmente independente da aplicacao de procedures do padrao.
-------------------------------------------------------------------- */

// Static Function CallXFilial( cArq )   //removido procedure callXFilial pois causava erro quando selecionado range
// Local aSaveArea := GetArea()
// Local cProc   := ""
// Local cQuery  := ""
// Local lRet    := .T.
// Local aCampos := CT2->(DbStruct())
// Local nPos    := 0
// Local cTipo   := ""

// cArq := CriaTrab(,.F.)
// cProc := cArq+"_"+cEmpAnt
// cArq := cProc

// cQuery :="Create procedure "+cProc+CRLF
// cQuery +="( "+CRLF
// cQuery +="  @IN_ALIAS        Char(03),"+CRLF
// nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_FILIAL" } )
// cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
// cQuery +="  @IN_FILIALCOR    "+cTipo+","+CRLF
// cQuery +="  @OUT_FILIAL      "+cTipo+" OutPut"+CRLF
// cQuery +=")"+CRLF
// cQuery +="as"+CRLF

// /* -------------------------------------------------------------------
//     Vers�o      -  <v> Gen�rica </v>
//     Assinatura  -  <a> 010 </a>
//     Descricao   -  <d> Retorno o modo de acesso da tabela em questao </d>

//     Entrada     -  <ri> @IN_ALIAS        - Tabela a ser verificada
//                         @IN_FILIALCOR    - Filial corrente </ri>

//     Saida       -  <ro> @OUT_FILIAL      - retorna a filial a ser utilizada </ro>
//                    <o> brancos para modo compartilhado @IN_FILIALCOR para modo exclusivo </o>

//     Responsavel :  <r> Alice Yaeko </r>
//     Data        :  <dt> 14/12/10 </dt>

//    X2_CHAVE X2_MODO X2_MODOUN X2_MODOEMP X2_TAMFIL X2_TAMUN X2_TAMEMP
//    -------- ------- --------- ---------- --------- -------- ---------
//    CT2      E       E         E          3.0       3.0        2.0
//       X2_CHAVE   - Tabela
//       X2_MODO    - Comparti/o da Filial, 'E' exclusivo e 'C' compartilhado
//       X2_MODOUN  - Comparti/o da Unidade de Neg�cio, 'E' exclusivo e 'C' compartilhado
//       X2_MODOEMP - Comparti/o da Empresa, 'E' exclusivo e 'C' compartilhado
//       X2_TAMFIL  - Tamanho da Filial
//       X2_TAMUN   - Tamanho da Unidade de Negocio
//       X2_TAMEMP  - tamanho da Empresa

//    Existe hierarquia no compartilhamento das entidades filial, uni// de negocio e empresa.
//    Se a Empresa for compartilhada as demais entidades DEVEM ser compartilhadas
//    Compartilhamentos e tamanhos poss�veis
//    compartilhaemnto         tamanho ( zero ou nao zero)
//    EMP UNI FIL             EMP UNI FIL
//    --- --- ---             --- --- ---
//     C   C   C               0   0   X   -- 1 - somente filial
//     E   C   C               0   X   X   -- 2 - filial e unidade de negocio
//     E   E   C               X   0   X   -- 3 - empresa e filial
//     E   E   E               X   X   X   -- 4 - empresa, unidade de negocio e filial
// ------------------------------------------------------------------- */
// cQuery +="Declare @cModo    Char( 01 )"+CRLF
// cQuery +="Declare @cModoUn  Char( 01 )"+CRLF
// cQuery +="Declare @cModoEmp Char( 01 )"+CRLF
// cQuery +="Declare @iTamFil  Integer"+CRLF
// cQuery +="Declare @iTamUn   Integer"+CRLF
// cQuery +="Declare @iTamEmp  Integer"+CRLF

// cQuery +="begin"+CRLF

// cQuery +="  Select @OUT_FILIAL = ' '"+CRLF
// cQuery +="  Select @cModo = ' ', @cModoUn = ' ', @cModoEmp = ' '"+CRLF
// cQuery +="  Select @iTamFil = 0, @iTamUn = 0, @iTamEmp = 0"+CRLF

// cQuery +="  Select @cModo = X2_MODO,   @cModoUn = X2_MODOUN, @cModoEmp = X2_MODOEMP,"+CRLF
// cQuery +="         @iTamFil = X2_TAMFIL, @iTamUn = X2_TAMUN, @iTamEmp = X2_TAMEMP"+CRLF
// cQuery +="    From SX2"+cEmpAnt+"0 "+CRLF
// cQuery +="   Where X2_CHAVE = @IN_ALIAS"+CRLF
// cQuery +="     and D_E_L_E_T_ = ' '"+CRLF

//   /*   SITUACAO -> 1 somente FILIAL */
// cQuery +="  If ( @iTamEmp = 0 and @iTamUn = 0 and @iTamFil >= 2 ) begin"+CRLF   //  -- so tem filial tam 2
// cQuery +="    If @cModo = 'C' select @OUT_FILIAL = '  '"+CRLF
// cQuery +="    else select @OUT_FILIAL = @IN_FILIALCOR"+CRLF
// cQuery +="  end else begin"+CRLF
//     /*  SITUACAO -> 2 UNIDADE DE NEGOCIO e FILIAL  */
// cQuery +="    If @iTamEmp = 0 begin"+CRLF
// cQuery +="      If @cModoUn = 'E' begin"+CRLF
// cQuery +="        If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamUn + 1, @iTamFil )"+CRLF
// cQuery +="        else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)"+CRLF
// cQuery +="      end"+CRLF
// cQuery +="    end else begin"+CRLF
//       /* SITUACAO -> 4 EMPRESA, UNIDADE DE NEGOCIO e FILIAL */
// cQuery +="      If @iTamUn > 0 begin"+CRLF
// cQuery +="        If @cModoEmp = 'E' begin"+CRLF
// cQuery +="          If @cModoUn = 'E' begin"+CRLF
// cQuery +="            If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamEmp+@iTamUn + 1, @iTamFil )"+CRLF
// cQuery +="            else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)"+CRLF
// cQuery +="          end else begin"+CRLF
// cQuery +="            select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
// cQuery +="          end"+CRLF
// cQuery +="        end"+CRLF
// cQuery +="      end else begin"+CRLF
//         /*  SITUACAO -> 3 EMPRESA e FILIAL */
// cQuery +="        If @cModoEmp = 'E' begin"+CRLF
// cQuery +="          If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring( @IN_FILIALCOR, @iTamEmp+1, @iTamFil )"+CRLF
// cQuery +="          else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
// cQuery +="        end"+CRLF
// cQuery +="      end"+CRLF
// cQuery +="    end"+CRLF
// cQuery +="  end"+CRLF
// cQuery +="end"+CRLF
// cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
// cQuery := CtbAjustaP(.F., cQuery, 0)

// If Empty( cQuery )
// 	MsgAlert(MsParseError(),STR0074 +cProc)  //"A query da filial nao passou pelo Parse "
// 	lRet := .F.
// Else
// 	If !TCSPExist( cProc )
// 		cRet := TcSqlExec(cQuery)
// 		If cRet <> 0
// 			If !__lBlind
// 				MsgAlert(STR0075+cProc)//"Erro na criacao da proc filial: "
// 				lRet:= .F.
// 			EndIf
// 		EndIf
// 	EndIf
// EndIf
// RestArea(aSaveArea)

// Return(lRet)
//-------------------------------------------------------------------
/*{Protheus.doc}CTBR400
Relatorio Razao - Define se vai criar o temporario no banco de dados
Static Function CTB400RAZB()
@author Totvs
@since  19/07/2018
@version 12.1.17
*/
//-------------------------------------------------------------------
Static Function CTB400RAZB(cUserFil)

Local _lRet := .F.
Default cUserFil	:= ""

If ( Empty(cUserFil) )

	If ( lCtbRazBD == NIL )//RECEBERA MV_CTBRAZB (L)
		If Alltrim(TCGetDb())$"MSSQL7|ORACLE|DB2|INFORMIX|POSTGRES"
			If FunName()=="CTBR400" .Or. FWIsInCallStack("CTBR400")
				_lRet := Iif(cPaisLoc $ "PER", .T. , MV_PAR38 == 1 ).And. SuperGetMV("MV_CTBRAZB",,.F.)
			EndIf
		EndIf
	Else
		_lRet := lCtbRazBD
	EndIf

EndIf

Return _lRet

//-------------------------------------------------------------------
/*{Protheus.doc}Ctr400HasAut
Verifica se a chamada da execu��o do relat�rio � proveniente de 
interface de automa��o

@author Totvs
@since  23/04/2019
@version 12.1.17
*/
//-------------------------------------------------------------------
Static Function Ctr400HasAut(cPerg)

Default cPerg := "CTR400"

Return(FWIsInCallStack("UTSTARTRPT") .And. cPerg == "CTR400") 
/*/
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������Ŀ��
���Fun��o    �RZValorCTB   � Autor � Pilar S Albaladejo    � Data � 15.12.99 		     ���
������������������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime O Valor                                             			 ���
������������������������������������������������������������������������������������Ĵ��
���Sintaxe   �RZValorCTB(nSaldo,nLin,nCol,nTamanho,nDecimais,lSinal,cPicture,;         ���
���          �						cTipo,cConta,lGraf,oPrint)					  	 ���
������������������������������������������������������������������������������������Ĵ��
���Retorno   �.T.   .                                                                ���
������������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                  			 ���
������������������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Valor                            	                 		 ���
���          � ExpN2 = Numero da Linha                                   		     ���
���          � ExpN3 = Numero da Coluna                                  		     ���
���          � ExpN4 = Tamanho                                           		     ���
���          � ExpN5 = Numero de Decimais											 ���
���          � ExpL1 = Se devera ser impresso com sinal ou nao.          		     ���
���          � ExpC1 = Picture                                           		     ���
���          � ExpC2 = Tipo                                              		     ���
���          � ExpC3 = Conta                                             		     ���
���          � ExpL2 = Se eh grafico ou nao                              		     ���
���          � ExpO1 = Objeto oPrint                                     		     ���
���          � ExpC4 = Tipo do sinal utilizado                           		     ���
���          � ExpC5 = Identificar [USADO em modo gerencial]             		     ���
���          � ExpL3 = Imprime zero                                      		     ���
���          � ExpL4 = Se .F., ao inves de imprimir retornara o valor como caracter���
���          � ExpL5 = If .T. (debit or credit balance column) and Red Storn is      ���
���          �         active, set cTipo value to empty (to show negative signal)    ���
�������������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
Function RZValorCtb(	nSaldo,nLin,nCol,nTamanho,nDecimais,lSinal,cPicture,;
					cTipo,cConta,lGraf,oPrint,cTipoSinal, cIdentifi,lPrintZero,lSay,lColDbCr,lCharSinal,lPlanilha)
Local aSaveArea	:= GetArea()
Local cImpSaldo := ""
Local cPicAux	:= ""
Local lDifZero	:= .T.
Local lInformada:= .T.
Local cCharSinal:= ""
    
If cPaisLoc = 'BRA'
	DEFAULT lPlanilha := .F.
    lPrintZero := Iif(lPrintZero==Nil,.T.,lPrintZero)
    // Nao imprime o valor 0,00
    If !lPrintZero
        If (Int(nSaldo*100)/100) == 0
            lDifZero := .F.			// O saldo nao eh diferente de zero
        EndIf
    EndIf

  
    If __cTipoSinal == NIL
        __cTipoSinal := SuperGetMV("MV_TPVALOR") // Assume valor default
    EndIf
    If __nDecimais == NIL
        __nDecimais := Iif(nDecimais==Nil,SuperGetMV("MV_CENT"),nDecimais)
    Endif
    Default cTipoSinal := __cTipoSinal
    Default nDecimais  := __nDecimais
    //��������������������������������������������������������������Ŀ
    //� Retorna a picture. Caso nao exista espaco, retira os pontos  �
    //� separadores de dezenas, centenas e milhares 				  �
    //����������������������������������������������������������������\
	If Empty(cPicture)
		If cTipoSinal $ "D/C" .Or. (cPaisLoc == "RUS" .And. cTipoSinal == "R")
			cPicture := RZTmContab(Abs(nSaldo),nTamanho,nDecimais)
		Else
			cPicture := RZTmContab(nSaldo,nTamanho,nDecimais)
		EndIf
		lInformada  := .F.
    EndIf
	//f������������������������������������������������������������Ŀ
    //��������������������������������������������������������������Ŀ
    //� Tipo D -> Default (D/C)												  �
    //� Tipo S -> Imprime saldo com sinal									  �
    //� Tipo P -> Imprime saldo entre parenteses (qdo. negativo)	  �
    //� Tipo C -> So imprime "C" (o "D" nao e impresso)              �
    //� Tipo N -> Imprime saldo com sinal (-) se o saldo for credor�
    //� Tipo R -> Default Red Storno: Imprime natureza da conta  (C/D) e saldo relativo a ela	     �
    //����������������������������������������������������������������
    DEFAULT lSay := .T.
    //��������������������������������������������������������������Ŀ
    //� RUSSIA                                                       �
    //� lColDbCr .F. -> Consider account normal according with cTipo �
    //� lColDbCr .T. -> Disconsider cTipo, setting cTipo to empty    �
    //����������������������������������������������������������������
    DEFAULT lColDbCr	:= .F.  //RUSSIA
    DEFAULT lCharSinal	:= .T.  //RUSSIA

	If lDifZero
		cTipo 		:= Iif(cTipo == Nil, Space(1), cTipo)
		dbSelectArea("CT1")
		dbSetOrder(1)
		
		If !Empty(cConta) .And. Empty(cTipo)
			If MsSeek(cFilial+cConta)
				cTipo := CT1->CT1_NORMAL
			Endif
		EndIf
	EndIf	
	//��������������������������������������������������������������Ŀ
    //�* Alguns valores, apesar de  terem sinal devem ser impressos  �
    //� sem sinal (lSinal). Ex: valores de colunas Debito e Credito  �
    //�* Se estiver com a opcao de lingua estrangeira (lEstrang) a   �
    //� picture sera invertida para exibir valores: 999,999,999.99   �
    //�* O tipo de sinal "D" - default nao leva em consideracao a    �
    //� a natureza da conta. Dessa forma valores negativos serao	  �
    //� impressos sem sinal, e ao seu lado "D" (Devedor) e valores   �
    //� positivos terao um "C" (Credito) impresso ao seu lado.       �
    //�* O tipo de Sinal "P" - Parenteses, imprimira valores de saldo�
    //�  invertidos da condicao normal da conta entre parenteses.	  �
    //�* O tipo de Sinal "S" - Sinal, imprimira valores de saldo in- �
    //�  vertidos da condicao normal da conta com sinal - 			  �
    //�EXEMPLOS  -  EXEMPLOS  -  EXEMPLOS	-	EXEMPLOS  - EXEMPLOS   �
    //�Cond Normal 	Saldo 	Default      Sinal   Parenteses		  �
    //�	D			   -1000	   1000 D 		 1000		 1000			  	  �
    //�	D				 1000 	1000 C		-1000 	(1000)			  �
    //�	C				-1000 	1000 D		-1000 	(1000)			  �
    //�	C				 1000 	1000 C		 1000 	 1000 			  �
    //����������������������������������������������������������������
    //lSinal - f
    // So imprime valor se for diferente de zero!
    If lDifZero
        //��������������������������������������������������������������Ŀ
        //� Neste caso (Default), nao importa a natureza da conta! Saldos�
        //� devedores serao impressos com "D" e credores com "C".        �
        //����������������������������������������������������������������
        // Neste caso, nao importa a natureza da conta!!
        If cTipoSinal == "D" .Or. cTipoSinal == "C" .Or. cTipoSinal == "N"			// D(Default) ou C(so Credito)
            If !lInformada
                cPicture := "@E " + cPicture
            Endif
            If lSinal
                If nSaldo < 0
                    If lGraf
                        If cTipoSinal == "D"
                            cCharSinal := Iif(cPaisLoc<>"MEX","D","C")
                        EndIf
                    Else
                        // No Tipo C -> so sao impressos os "C�s"
                        If cTipoSinal == "D"
                            cCharSinal := Iif(cPaisLoc<>"MEX","D","C")
                        EndIf
                    Endif
                ElseIf nSaldo > 0
                    If lGraf
                        If cIdentifi # Nil .And. cIdentifi $ "34"
                            If cTipoSinal == "D"
                                cCharSinal := Iif(cPaisLoc<>"MEX","C","A")
                            EndIf
                        Else
                            cCharSinal := Iif(cPaisLoc<>"MEX","C","A")
                        Endif
                    Else
                        cCharSinal := Iif(cPaisLoc<>"MEX","C","A")
                    Endif
                EndIf
                cCharSinal := " "+cCharSinal
            EndIf

            //Se o parametro MV_TPVALOR == "N" => nao considera a condicao normal da conta.
            //So imprime sinal (-) se o saldo for credor.
            If cTipoSinal == "N"
                If lSinal
                    cImpSaldo := Transform(nSaldo*(-1),cPicture)
					nSaldo    := nSaldo*(-1)
                Else
                    cImpSaldo := Transform(ABS(nSaldo),cPicture)
                EndIf
            Else
                cImpSaldo := Transform(Abs(nSaldo),cPicture)+cCharSinal
            EndIf

            If lGraf
                If cIdentifi # Nil .And. cIdentifi $ "34"
                    If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
                        oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
                    Else
                        oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
                    EndIf
                Else
                    oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
                Endif
            ElseIf lSay
                @ nLin, nCol pSay cImpSaldo
            Endif
        Else
            //Utiliza conceito de conta estourada e a conta eh redutora.
            If Select("cArqTmp") > 0 .And. cArqTmp->(FieldPos("ESTOUR")) <> 0 .And.  cArqTmp->ESTOUR == "1"
                If cTipo == "1" 								// Conta Devedora
                    If cTipoSinal == "S"              			// Sinal
                        If !lSinal
                            nSaldo := Abs(nSaldo)
                        EndIf
                        If !lInformada
                            cPicture := "@E " + cPicture
                        EndIf
                        If lGraf
                            cImpSaldo := Transform(nSaldo,cPicture)
                            If cIdentifi # Nil .And. cIdentifi $ "34"
                                If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
                                    oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
                                Else
                                    oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
                                EndIf
                            Else
                                oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
                            Endif
                        ElseIf lSay
                            @ nLin, nCol PSAY nSaldo Picture cPicture
                        Else
                            cImpSaldo := Transform(nSaldo,cPicture)
                        Endif
                    ElseIf (cTipoSinal) == "P"              	// Parenteses
                        If !lSinal
                            nSaldo := Abs(nSaldo)
                        EndIf

                        If !lInformada
                            If (Len(cPicture) + 2) > nTamanho
                                cPicture := SubStr(cPicture,(Len(cPicture) + 3)-nTamanho,Len(cPicture))
                            EndIf
                            cPicture := "@E( " + cPicture

                        ElseIf nSaldo < 0
                            IF AT("@E", cPicture) > 0
                                cPicAux  := SubStr(cPicture,AT(" ",cPicture),Len(cPicture))
                                If (Len(cPicAux) + 2) > nTamanho
                                    cPicAux := SubStr(cPicAux,(Len(cPicture) + 3)-nTamanho,Len(cPicture))
                                EndIf
                                cPicture := "@E( " + cPicAux
                            Else
                                cPicture := "@E( " + cPicture
                            EndIf

                        EndIf

                        If lGraf
                            cImpSaldo := Transform(nSaldo,cPicture)
                            If cIdentifi # Nil .And. cIdentifi $ "34"
                                If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
                                    oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
                                Else
                                    oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
                                EndIf
                            Else
                                oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
                            Endif
                        ElseIf lSay
                            @ nLin, nCol pSay nSaldo Picture cPicture
                        Else
                            cImpSaldo := Transform(nSaldo,cPicture)
                        Endif
                    EndIf
                Else
                    If (cTipoSinal) == "S"                  	// Sinal
                        If lSinal
                            nSaldo := nSaldo * (-1)
                        Else
                            nSaldo := Abs(nSaldo)
                        EndIf
                        If !lInformada
                            cPicture := "@E " + cPicture
                        EndIf
                        If lGraf
                            cImpSaldo := Transform(nSaldo,cPicture)
                            If cIdentifi # Nil .And. cIdentifi $ "34"
                                If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
                                    oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
                                Else
                                    oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
                                EndIf
                            Else
                                oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
                            Endif
                        ElseIf lSay
                            @ nLin, nCol PSAY nSaldo Picture cPicture
                        Else
                            cImpSaldo := Transform(nSaldo,cPicture)
                        Endif
                    ElseIf (cTipoSinal) == "P"              // Parenteses
                        If lSinal
                            nSaldo := nSaldo * (-1)
                        Else
                            nSaldo := Abs(nSaldo)
                        EndIf

                        If !lInformada
                            If (Len(cPicture) + 2) > nTamanho
                                cPicture := SubStr(cPicture,(Len(cPicture) + 3)-nTamanho,Len(cPicture))
                            EndIf
                            cPicture := "@E( " + cPicture

                        ElseIf nSaldo < 0
                            IF AT("@E", cPicture) > 0
                                cPicAux  := SubStr(cPicture,AT(" ",cPicture),Len(cPicture))
                                If (Len(cPicAux) + 2) > nTamanho
                                    cPicAux := SubStr(cPicAux,(Len(cPicture) + 3)-nTamanho,Len(cPicture))
                                EndIf
                                cPicture := "@E( " + cPicAux
                            Else
                                cPicture := "@E( " + cPicture
                            EndIf

                        EndIf


                        If lGraf
                            cImpSaldo := Transform(nSaldo,cPicture)			// Debito
                            If cIdentifi # Nil .And. cIdentifi $ "34"
                                If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
                                    oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
                                Else
                                    oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
                                EndIf
                            Else
                                oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
                            Endif
                        ElseIf lSay
                            @ nLin, nCol pSay nSaldo Picture cPicture
                        Else
                            cImpSaldo := Transform(nSaldo,cPicture)
                        Endif
                    EndIf
                EndIf
            Else	//Se nao utiliza conceito de conta estourada
                If cTipo == "1" 								// Conta Devedora
                    If cTipoSinal == "S"              			// Sinal
                        If lSinal
                            nSaldo := nSaldo * (-1)
                        Else
                            nSaldo := Abs(nSaldo)
                        EndIf
                        If !lInformada
                            cPicture := "@E " + cPicture
                        EndIf
                        If lGraf
                            cImpSaldo := Transform(nSaldo,cPicture)
                            If cIdentifi # Nil .And. cIdentifi $ "34"
                                If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
                                    oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
                                Else
                                    oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
                                EndIf
                            Else
                                oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
                            Endif
                        ElseIf lSay
                            @ nLin, nCol PSAY nSaldo Picture cPicture
                        Else
                            cImpSaldo := Transform(nSaldo,cPicture)
                            cImpSaldo := PADL(STRTRAN(cImpSaldo,' ',''),len(cImpSaldo))
                        Endif
                    ElseIf (cTipoSinal) == "P"              	// Parenteses
                        If lSinal
                            nSaldo := nSaldo * (-1) 		  		// a Picture so exibe parenteses para numeros negativos
                        Else
                            nSaldo := Abs(nSaldo)
                        EndIf

                        If !lInformada
                            If (Len(cPicture) + 2) > nTamanho
                                cPicture := SubStr(cPicture,(Len(cPicture) + 3)-nTamanho,Len(cPicture))
                            EndIf
                            cPicture := "@E( " + cPicture

                        ElseIf nSaldo < 0
                            IF AT("@E", cPicture) > 0
                                cPicAux  := SubStr(cPicture,AT(" ",cPicture),Len(cPicture))
                                If (Len(cPicAux) + 2) > nTamanho
                                    cPicAux := SubStr(cPicAux,(Len(cPicture) + 3)-nTamanho,Len(cPicture))
                                EndIf
                                cPicture := "@E( " + cPicAux
                            Else
                                cPicture := "@E( " + cPicture
                            EndIf

                        EndIf


                        If lGraf
                            cImpSaldo := Transform(nSaldo,cPicture)
                            If cIdentifi # Nil .And. cIdentifi $ "34"
                                If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
                                    oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
                                Else
                                    oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
                                EndIf
                            Else
                                oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
                            Endif
                        ElseIf lSay
                            @ nLin, nCol pSay nSaldo Picture cPicture
                        Else
                            cImpSaldo := Transform(nSaldo,cPicture)
                            cImpSaldo := PADL(STRTRAN(cImpSaldo,' ',''),len(cImpSaldo))
                        Endif
                    EndIf
                Else
                    If (cTipoSinal) == "S"                  	// Sinal
                        If !lSinal .And. cTipo == "2" 			// Conta Credora
                            nSaldo := Abs(nSaldo)
                        EndIf
                        If !lInformada
                            cPicture := "@E " + cPicture
                        EndIf
                        If lGraf
                            cImpSaldo := Transform(nSaldo,cPicture)
                            If cIdentifi # Nil .And. cIdentifi $ "34"
                                If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
                                    oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
                                Else
                                    oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
                                EndIf
                            Else
                                oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
                            Endif
                        ElseIf lSay
                            @ nLin, nCol PSAY nSaldo Picture cPicture
                        Else
                            cImpSaldo := Transform(nSaldo,cPicture)
                        Endif
                    ElseIf (cTipoSinal) == "P"              // Parenteses
                        If !lSinal .And. cTipo == "2" 			// Conta Credora
                            nSaldo := Abs(nSaldo)
                        EndIf

                        If !lInformada
                            If (Len(cPicture) + 2) > nTamanho
                                cPicture := SubStr(cPicture,(Len(cPicture) + 3)-nTamanho,Len(cPicture))
                            EndIf
                            cPicture := "@E( " + cPicture

                        ElseIf nSaldo < 0
                            IF AT("@E", cPicture) > 0
                                cPicAux  := SubStr(cPicture,AT(" ",cPicture),Len(cPicture))
                                If (Len(cPicAux) + 2) > nTamanho
                                    cPicAux := SubStr(cPicAux,(Len(cPicture) + 3)-nTamanho,Len(cPicture))
                                EndIf
                                cPicture := "@E( " + cPicAux
                            Else
                                cPicture := "@E( " + cPicture
                            EndIf

                        EndIf

                        If lGraf
                            cImpSaldo := Transform(nSaldo,cPicture)			// Debito
                            If cIdentifi # Nil .And. cIdentifi $ "34"
                                If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
                                    oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
                                Else
                                    oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
                                EndIf
                            Else
                                oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
                            Endif
                        ElseIf lSay
                            @ nLin, nCol pSay nSaldo Picture cPicture
                        Else
                            cImpSaldo := Transform(nSaldo,cPicture)
                        Endif
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
    RestArea(aSaveArea)
	aSize(aSaveArea,0)
	aSaveArea := nil 

    If lPlanilha .And. __cMvCtbPlan $ 'N' .And. (Upper(AllTrim(cTipoSinal)) $ "S|N" .Or. !lSinal) 
        Return nSaldo
    EndIf

    If !lSay
        If Empty( cImpSaldo ) .And. lPrintZero
            cImpSaldo := Transform(nSaldo,cPicture)		
        EndIf
        Return cImpSaldo
    EndIf
Else
    Return ValorCTB(	nSaldo,nLin,nCol,nTamanho,nDecimais,lSinal,cPicture,;
	    				cTipo,cConta,lGraf,oPrint,cTipoSinal, cIdentifi,lPrintZero,lSay,lColDbCr,lCharSinal,lPlanilha)
EndIf

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o	  �TmContab  � Autor � Pilar S. Albaladejo	� Data � 23/09/98 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o � Retorna a picture a ser impressa e corta pontos se nao ti- ���
���			  � ver espaco 																���
��������������������������������������������������������������������������Ĵ��
��� Sintaxe   � TmContab(cCampo,nTamanho,nDecimais)								���
���			  � Onde:																		���
���			  � cCampo	= Campo a ser impresso										���
���			  � nTamanho= Tamanho maximo disponivel para impressao			���
���			  � nDecimais = Numero de decimais a serem impressas				���
��������������������������������������������������������������������������Ĵ��
��� Uso		  � SIGACON 																	���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function RZTMContab(cCampo,nTamanho,nDecimais)

Local cCpo
Local cDecimais := ""
Local cPicture  := ""

If __cPicture == Nil
	 __cPicture := Iif(SuperGetMv("MV_MILHAR"),"999,999,999,999,999","999999999999999")
Endif

cDecimais:= Iif(nDecimais==0,"","."+Replicate("9",nDecimais))

cPicture := __cPicture + cDecimais
cCpo	:= Transform(cCampo,cPicture)

//��������������������������������������������������������������Ŀ
//� VerIfica se ha tamanho suficiente para imprimir. Se nao 	  �
//� existir tamanho suficiente, serao cortados pontos e virgulas �
//� para caber.																  �
//����������������������������������������������������������������
If Len(AllTrim(cCpo)) > nTamanho 
	cPicture := Replicate("9",nTamanho)+cDecimais
End

cPicture 		 :=	Right(cPicture,nTamanho)
cPicture 		 :=	Iif(Substr(cPicture,1,1)=',',"9"+Substr(cPicture,2),cPicture)

cCpo := (Transform(cCampo,cPicture))
If Len(LTrim(cCpo)) > nTamanho
	cPicture := "�"+Substr(cPicture,2,20)
EndIf

Return cPicture

/*/{Protheus.doc} CTB400Metrics
	
	CTB400Metrics - Fun��o utilizada para metricas no CTBR400

	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function CTB400Metrics(cEvent, nStart, cSubEvent, cSubRoutine, nQtdReg)

Local cFunBkp	:= ""
Local cFunMet	:= ""

Local nFim := 0

Local cIdMetric  := ""
Local dDateSend := CtoD("") 
Local nLapTime := 0
Local cTotal := ""

Default cEvent := ""
Default nStart := Seconds()
Default cSubEvent := ""
Default cSubRoutine := Alltrim(ProcName(1))
Default nQtdReg := 0

//S� capturar metricas se a vers�o da lib for superior a 20210517
If __lMetric .And. !Empty(cEvent)
	
	//grava funname atual na variavel cFunBkp
	cFunBkp := FunName()

	If cEvent == "01" //Evento 01 - Metrica de tempo m�dio

		
		If cSubEvent == '001' .Or. cSubEvent == '002' // 001 = R4 - 002 = R3
			
			cFunMet := cFunBkp
			SetFunName(cFunMet)

			nFim := Seconds() - nStart // Capturar tempo final | Diferen�a com o tempo inicial
			
			//atribuicao das variaveis que serao utilizadas pelo FwCustomMetrics
			
			cSubRoutine := Alltrim(cSubRoutine)
			cIdMetric  := "contabilidade-gerencial-protheus_relatorio-razao-contabil-tempo_seconds"
			cTotal := "1"
			dDateSend := LastDay( Date() )
			nLapTime := nFim

			// Metrica
			FWCustomMetrics():SetMetric(cSubRoutine, cIdMetric, cTotal, dDateSend, nLapTime)

		EndIf

	//Evento 02 - Metrica de quantidade total
	ElseIf cEvent == "02" .And. nQtdReg > 0 

		If cSubEvent == '001'

			cFunMet := cFunBkp
			
			//atribuicao das variaveis que serao utilizadas pelo FwCustomMetrics
			SetFunName(cFunMet)
			cSubRoutine := Alltrim(cSubRoutine)			
			cIdMetric  := "contabilidade-gerencial-protheus_relatorio-razao-contabil-qtd_total"
			cTotal := cValToChar(nQtdReg) //cTotal na fun��o SetMetric espera parametro do tipo caractere						
			dDateSend := LastDay( Date() )
			FWCustomMetrics():SetMetric(cSubRoutine, cIdMetric, cTotal, dDateSend)
		EndIf
	EndIf

	//Restaura setfunname a partir da variavel salva cFunBkp
	SetFunName(cFunBkp)
EndIf

Return 

//-------------------------------------------------------------------
/*{Protheus.doc}CTBR400
Relatorio Razao - Criar temporario no banco e popular
Static Function CtbNewAuxRazao
@author caio
@since  11/05/2021
@version 12.1.27
*/
//-------------------------------------------------------------------
Static Function CtbNewAuxRazao(	cContaIni,cContaFim,cCustoIni,cCustoFim,;
								cItemIni,cItemFim,cCLVLIni,cCLVLFim,;
								cMoeda,dDataIni,dDataFim,;
								aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,;
								c2Moeda,nTipo,cUFilter,lSldAnt,aSelFil,lExterno,cArqTmp)

Local cTmpCT2Fil
Local cTmpCT1Fil
Local cTmpCTTFil
Local cTmpCTDFil
Local cTmpCTHFil
Local cGetRngFil := ""
Local cRngFilCT1 := ""
Local cRngCTTFil := ""
Local cRngCTDFil := ""
Local cRngCTHFil := ""
Local aStru
Local cInsDCTmp  := ""
Local cInsSMTmp  := ""

Local aCposCT2   := {}
Local aVarsCT2   := {}
Local lUFilter	:= !Empty(cUFilter)	// SE O FILTRO DE USU�RIO N�O ESTIVER VAZIO - TEM FILTRO DE USU�RIO

Local cContaI	:= ""
Local cContaF	:= ""
Local cCustoI	:= ""
Local cCustoF	:= ""
Local cItemI	:= ""
Local cItemF	:= ""
Local cClVlI	:= ""
Local cClVlF	:= ""
Local lExclusivo := .F.

Local cRealTmp  := ""
Local nTamFil   := TamSX3("CT1_FILIAL")[1]
Local nTamEnt   := 0
Local nRet		:= 0 // Inicializador
Local cNomProc	:= ""
Local cProcCT2  := ""
Local cCommit	:= ""
Local nProcRet  := 0 // Inicializador
Local cGetDB	:= Alltrim(UPPER(TcGetDb()))
Local cConcat   := IIF("SQL" $ cGetDB, "+", "||")
Local cSubstr   := IIF("ORACLE"$ cGetDB, "SUBSTR", "SUBSTRING")
Local nFilTab	

If Empty(aSelFil)
	aAdd(aSelFil, cFilAnt)
EndIf

cContaI	:= CCONTAINI
cContaF := CCONTAFIM
cCustoI	:= CCUSTOINI
cCustoF := CCUSTOFIM
cItemI	:= CITEMINI
cItemF 	:= CITEMFIM
cClvlI	:= CCLVLINI
cClVlF 	:= CCLVLFIM

nFilTab	:= IIf ( Empty(xFilial("CT2")), Nil, 0)

cGetRngFil := GetRngFil( aSelFil ,"CT2", .T., @cTmpCT2Fil, nFilTab, , @cRealTmp)  //0 ultimo param forca criacao no banco de dados, pois vai utilizar a tabela
cRngFilCT1 := GetRngFil( aSelFil ,"CT1", .T., @cTmpCT1Fil)
cRngCTTFil := GetRngFil( aSelFil ,"CT1", .T., @cTmpCTTFil)
cRngCTDFil := GetRngFil( aSelFil ,"CT1", .T., @cTmpCTDFil)
cRngCTHFil := GetRngFil( aSelFil ,"CT1", .T., @cTmpCTHFil)

lExclusivo := !Empty(xFilial("CT2"))

aStru := CT2->(dbStruct())

CtbR400Cpos(aCposCT2, aStru)   //array campos da CT2
CtbR400Vars(aVarsCT2, aStru)   //variaveis para uso na procedure /cursor

If cGetDB $ "MSSQL7" 
	cCommit := "Commit Tran"
ElseIf cGetDB $ "ORACLE||DB2" 
	cCommit := "Commit"
ElseIf cGetDB = "INFORMIX" 
	cCommit := "COMMIT WORK"
EndIf

/* A tabela temporaria ser� populada em 3 passos 
	1. INSERT INTO na tabela temporaria para buscar os lan�amentos de d�bito e cr�dito.
	2. PROCEDURE para capturar as continua��es de hist�rico, e realizar update nos hist�ricos.
	3. INSERT INTO das contas sem movimenta��o no periodo, ou com saldo anterior.

	Os comandos dos passos acima est�o separados em 3 variaveis
	cInsDCTmp - Para o passo 1.
	cProcCT2 - Para a procedure do passo 2
	cInsSMTmp - Para o passo 3
*/


//INSERT DE DEBITOS E CR�DITOS

If cGetDB $ "ORACLE" 
	cInsDCTmp += "BEGIN" +CRLF
EndIf

cInsDCTmp += " INSERT INTO " + cArqTmp + " (FILIAL , DATAL , TIPO , LOTE , SUBLOTE , DOC ," + CRLF
cInsDCTmp += " LINHA , CONTA , XPARTIDA , CCUSTO , ITEM, CLVL , HISTORICO , EMPORI , FILORI , " + CRLF
cInsDCTmp += " SEQHIST , SEQLAN , NOMOV , LANCDEB ,LANCCRD , RECNOCT2 )  " + CRLF

//Select de debitos 

cInsDCTmp += ""
cInsDCTmp += "SELECT "

cInsDCTmp += "CT2_FILIAL FILIAL,"
cInsDCTmp += "CT2_DATA DATAL,"
cInsDCTmp += "'1' TIPO,"
cInsDCTmp += "CT2_LOTE LOTE,"
cInsDCTmp += "CT2_SBLOTE SUBLOTE,"
cInsDCTmp += "CT2_DOC DOC,
cInsDCTmp += "CT2_LINHA LINHA, " + CRLF
cInsDCTmp += "CT2_DEBITO CONTA ,"
cInsDCTmp += "CT2_CREDIT XPARTIDA ,"
cInsDCTmp += "CT2_CCD CCUSTO,"
cInsDCTmp += "CT2_ITEMD ITEM,"
cInsDCTmp += "CT2_CLVLDB CLVL,"
cInsDCTmp += "CT2_HIST HISTORICO, " + CRLF
cInsDCTmp += "CT2_EMPORI EMPORI,"
cInsDCTmp += "CT2_FILORI FILORI,"
cInsDCTmp += "CT2_SEQHIS SEQHIST,"
cInsDCTmp += "CT2_SEQLAN SEQLAN,"
cInsDCTmp += "'0' NOMOV ,"
cInsDCTmp += "CT2_VALOR LANCDEB,"
cInsDCTmp += "0 LANCCRED, " 
cInsDCTmp += "R_E_C_N_O_ RECNOCT2" + CRLF

cInsDCTmp += "FROM " + RetSqlName("CT2") + CRLF
cInsDCTmp += "WHERE CT2_FILIAL " + cGetRngFil+CRLF

//-------------------------//
//  Obtem os debitos       //
//-------------------------//


cInsDCTmp += "	AND CT2_DEBITO >='" + cContaIni + "' "+CRLF
cInsDCTmp += "	AND CT2_DEBITO <='" + cContaFim + "' "+CRLF
cInsDCTmp += "	AND CT2_CCD    >='" + cCustoIni + "' "+CRLF
cInsDCTmp += "	AND CT2_CCD    <='" + cCustoFim + "' "+CRLF
cInsDCTmp += "	AND CT2_ITEMD  >='" + cItemIni  + "' "+CRLF
cInsDCTmp += "	AND CT2_ITEMD  <='" + cItemFim  + "' "+CRLF
cInsDCTmp += "	AND CT2_CLVLDB >='" + cClVlIni  + "' "+CRLF
cInsDCTmp += "	AND CT2_CLVLDB <='" + cClVlFim  + "' "+CRLF

If lUFilter			//ADICIONA O FILTRO DEFINIDO PELO USU�RIO SE N�O ESTIVER EM BRANCO
	cInsDCTmp += "	AND "	// SE J� TIVER CONTEUDO, ADICIONA "AND"
	cInsDCTmp += cUFilter // ADICIONA O FILTRO DE USU�RIO  NA SINTAXE SQL
EndIf

cInsDCTmp	+= "	and CT2_DATA >= '" + DTOS(dDataIni) + "' "+CRLF
cInsDCTmp	+= "	and CT2_DATA <= '" + DTOS(dDataFim) + "' "+CRLF

If !Empty(c2Moeda)
	cInsDCTmp	+= "	and ( CT2_MOEDLC = '" + cMoeda  + "' OR "
	cInsDCTmp	+= " 	CT2_MOEDLC = '" + c2Moeda + "'  ) "
Else
	cInsDCTmp	+= "	and CT2_MOEDLC = '" + cMoeda  + "' "+CRLF
EndIf

cInsDCTmp	+= "	and CT2_TPSALD = '"+ cSaldo + "' "+CRLF
cInsDCTmp	+= "	and CT2_DC IN ('1','3') "+CRLF
cInsDCTmp	+= "	and CT2_VALOR <> 0 "+CRLF
cInsDCTmp	+= "	and D_E_L_E_T_ = ' ' "+CRLF

cInsDCTmp	+= " UNION ALL " +CRLF

// SELECT DE CR�DITOS

cInsDCTmp += "SELECT "

cInsDCTmp += "CT2_FILIAL FILIAL,"
cInsDCTmp += "CT2_DATA DATAL,"
cInsDCTmp += "'2' TIPO,"
cInsDCTmp += "CT2_LOTE LOTE,"
cInsDCTmp += "CT2_SBLOTE SUBLOTE,"
cInsDCTmp += "CT2_DOC DOC,"
cInsDCTmp += "CT2_LINHA LINHA," + CRLF
cInsDCTmp += "CT2_CREDIT CONTA,"
cInsDCTmp += "CT2_DEBITO XPARTIDA,"
cInsDCTmp += "CT2_CCC CCUSTO,"
cInsDCTmp += "CT2_ITEMC ITEM,"
cInsDCTmp += "CT2_CLVLCR CLVL,"
cInsDCTmp += "CT2_HIST HISTORICO," + CRLF
cInsDCTmp += "CT2_EMPORI EMPORI,"
cInsDCTmp += "CT2_FILORI FILORI,"
cInsDCTmp += "CT2_SEQHIS SEQHIST,"
cInsDCTmp += "CT2_SEQLAN SEQLAN,"
cInsDCTmp += "'0' NOMOV ,"
cInsDCTmp += "0 LANCDEB,"
cInsDCTmp += "CT2_VALOR LANCCRED," 

cInsDCTmp += "R_E_C_N_O_ RECNOCT2 "+CRLF
cInsDCTmp += "FROM "+RetSqlName("CT2")+CRLF
cInsDCTmp += "WHERE "
cInsDCTmp += "CT2_FILIAL " + cGetRngFil+CRLF

//obtem creditos
//If cTipo == "1"

cInsDCTmp += "	AND CT2_CREDIT >='" + cContaIni + "' "+CRLF
cInsDCTmp += "	AND CT2_CREDIT <='" + cContaFim + "' "+CRLF
cInsDCTmp += "	AND CT2_CCC    >='" + cCustoIni + "' "+CRLF
cInsDCTmp += "	AND CT2_CCC    <='" + cCustoFim + "' "+CRLF
cInsDCTmp += "	AND CT2_ITEMC  >='" + cItemIni  + "' "+CRLF
cInsDCTmp += "	AND CT2_ITEMC  <='" + cItemFim  + "' "+CRLF
cInsDCTmp += "	AND CT2_CLVLCR >='" + cClVlIni  + "' "+CRLF
cInsDCTmp += "	AND CT2_CLVLCR <='" + cClVlFim  + "' "+CRLF

If lUFilter			//ADICIONA O FILTRO DEFINIDO PELO USU�RIO SE N�O ESTIVER EM BRANCO
	cInsDCTmp += "	AND "	// SE J� TIVER CONTEUDO, ADICIONA "AND"
	cInsDCTmp += cUFilter // ADICIONA O FILTRO DE USU�RIO  NA SINTAXE SQL
EndIf

cInsDCTmp	+= " AND CT2_DATA >= '" + DTOS(dDataIni) + "' "+CRLF
cInsDCTmp	+= " AND CT2_DATA <= '" + DTOS(dDataFim) + "' "+CRLF

If !Empty(c2Moeda)
	cInsDCTmp	+= " AND ( CT2_MOEDLC = '" + cMoeda  + "' OR "
	cInsDCTmp	+= " CT2_MOEDLC = '" + c2Moeda + "'  ) "
Else
	cInsDCTmp	+= " AND CT2_MOEDLC = '" + cMoeda  + "' "
EndIf

cInsDCTmp += CRLF

cInsDCTmp	+= "	and CT2_TPSALD = '"+ cSaldo + "' "+CRLF

cInsDCTmp	+= "	and CT2_DC IN ('2','3') "+CRLF
cInsDCTmp	+= "	and CT2_VALOR <> 0 "+CRLF
cInsDCTmp	+= "	and D_E_L_E_T_ = ' ' ;"+CRLF

//cInsDCTmp	+= "	ORDER BY TIPO;"+CRLF 

If cGetDB $ "ORACLE" 
	cInsDCTmp += "END;"
EndIf

/* 
PROCEDURE PARA CONTIUNUA��O DE HIST�RICO
*/	
If ( nTipoRel <> 3 )

	cNomProc := CriaTrab(,.F.)+"_"+cEmpAnt

	cProcCT2 := "CREATE PROCEDURE "+cNomProc+"( "+CRLF
	cProcCT2 += "  @OUT_RET 		char(1) output" +CRLF
	cProcCT2 += " ) as "+ CRLF
	cProcCT2 += " "+ CRLF

	//declara as variaveis
	CtbR400Decl(@cProcCT2, aStru)

	//variaveis que serao utilizada na funcao CtbAuxGrvRAZ
	cProcCT2 += "Declare @iRecno int "+ CRLF
	cProcCT2 += "Declare @cConta Char("+Alltrim(Str(Len(CT2->CT2_DEBITO)))+") "+CRLF
	cProcCT2 += "Declare @cContra Char("+Alltrim(Str(Len(CT2->CT2_DEBITO)))+") "+CRLF
	cProcCT2 += "Declare @cCusto Char("+Alltrim(Str(Len(CT2->CT2_CCD)))+") "+CRLF
	cProcCT2 += "Declare @cItem Char("+Alltrim(Str(Len(CT2->CT2_ITEMD)))+") "+CRLF
	cProcCT2 += "Declare @cCLVL Char("+Alltrim(Str(Len(CT2->CT2_CLVLDB)))+") "+CRLF
	//variaveis para segundo cursor na funcao CtbAuxGrvRaz
	cProcCT2 += "Declare @cAuxCusto Char("+Alltrim(Str(Len(CT2->CT2_CCD)))+") "+CRLF
	cProcCT2 += "Declare @cAuxItem Char("+Alltrim(Str(Len(CT2->CT2_ITEMD)))+") "+CRLF
	cProcCT2 += "Declare @cAuxClvl Char("+Alltrim(Str(Len(CT2->CT2_CLVLDB)))+") "+CRLF
	cProcCT2 += "Declare @iAuxRecno int "+ CRLF
	cProcCT2 += "Declare @iInclui int "+CRLF
	cProcCT2 += "Declare @nLancDeb float"+CRLF
	cProcCT2 += "Declare @nLancCrd float"+CRLF
	cProcCT2 += "Declare @nLancDeb_1 float"+CRLF
	cProcCT2 += "Declare @nLancCrd_1 float"+CRLF
	cProcCT2 += "Declare @nTxDebito float"+CRLF
	cProcCT2 += "Declare @nTxCredito float"+CRLF
	cProcCT2 += "Declare @cDelet_ char(1)"+CRLF
	cProcCT2 += "Declare @iRecnoCT2 int"+CRLF
	cProcCT2 += "Declare @nSaldoAnt float"+CRLF
	cProcCT2 += "Declare @nAntDeb float"+CRLF
	cProcCT2 += "Declare @nAntCred float"+CRLF
	cProcCT2 += "Declare @iCommit    integer"+CRLF
	cProcCT2 += "Declare @iTranCount integer"+CRLF  // Ser� substituida por commit ap�s passar pelo Msparse
	cProcCT2 += "Declare @cHistCT2 varchar("+cValToChar(nR400Char)+")"+CRLF  // Radu
	cProcCT2 += "Declare @cFilial char(" + Alltrim(Str(Len(CT2->CT2_FILIAL))) + ")"+CRLF  // Radu
	cProcCT2 += "DECLARE @cContaHist Char(" + Alltrim(Str(Len(CT2->CT2_DEBITO))) + ")"+CRLF
	cProcCT2 += "Declare @cData char(8)"+CRLF  // Radu
	cProcCT2 += "Declare @cLote char(" + Alltrim(Str(Len(CT2->CT2_LOTE))) + ")" + CRLF  // Radu
	cProcCT2 += "Declare @cSubLote char(" + Alltrim(Str(Len(CT2->CT2_SBLOTE))) + ")" + CRLF  // Radu
	cProcCT2 += "Declare @cDoc char(" + Alltrim(Str(Len(CT2->CT2_DOC))) + ")" + CRLF  // Radu
	cProcCT2 += "Declare @cSeqLan char(" + Alltrim(Str(Len(CT2->CT2_SEQLAN))) + ")" + CRLF  // Radu
	cProcCT2 += "DECLARE @cHistCT2FIM  varchar("+cValToChar(nR400Char)+")"  + CRLF  
	cProcCT2 += "DECLARE @iRecnoTmp Integer " + CRLF  
	cProcCT2 += "DECLARE @iRecnoTmpAnt Integer " + CRLF  
	cProcCT2 += "DECLARE @cHistOri  varchar("+cValToChar(nR400Char)+")"+ CRLF  

	If FunName() == "CTBR400" .OR. IsInCallStack("CT400Imp")
		cProcCT2 += "SELECT  @cHistCT2FIM = ''   "+ CRLF
		cProcCT2 += "SELECT @iRecnoTmp = 0 "+ CRLF
		cProcCT2 += "SELECT  @iRecnoTmpAnt = 0 " + CRLF
		cProcCT2 += "SELECT @cHistOri ='' "+ CRLF
		cProcCT2 += "Declare cCursor4 insensitive cursor for" + CRLF

		cProcCT2 += "	SELECT "
		cProcCT2 += " 	CT2_FILIAL, "
		cProcCT2 += " 	CARQTMP.CONTA, "
		cProcCT2 += " 	CT2_DATA, "
		cProcCT2 += " 	CT2_DC, "
		cProcCT2 += " 	CT2_LOTE, "
		cProcCT2 += " 	CT2_SBLOTE, "
		cProcCT2 += " 	CT2_DOC, "
		cProcCT2 += " 	CT2_LINHA, "
		cProcCT2 += " 	CT2_HIST, "
		cProcCT2 += " 	CT2_EMPORI, "
		cProcCT2 += " 	CT2_FILORI, "
		cProcCT2 += " 	CT2_SEQHIS, "
		cProcCT2 += " 	CT2_SEQLAN  ,CARQTMP.R_E_C_N_O_ "+CRLF
		cProcCT2 += "	FROM "+cArqTmp+" CARQTMP ,"+RetSqlName("CT2")+ " CT2 "+CRLF
		cProcCT2 += "	WHERE CT2_FILIAL = FILIAL "+ CRLF
		cProcCT2 += "		AND CT2_DATA = DATAL "+ CRLF
		cProcCT2 += "		AND CT2_LOTE = LOTE "+ CRLF
		cProcCT2 += "		AND CT2_SBLOTE = SUBLOTE "+ CRLF
		cProcCT2 += "		AND CT2_DOC = DOC "+ CRLF
		cProcCT2 += "		AND CT2_SEQLAN = SEQLAN "+ CRLF
		cProcCT2 += "		AND CT2_EMPORI = EMPORI "+ CRLF
		cProcCT2 += "		AND CT2_FILORI = FILORI "+ CRLF
		cProcCT2 += "		AND (CT2_DC = '4' OR (CT2_DC <> '4' AND CT2_SEQHIS = '001' ) ) "+ CRLF    //SOMENTE CONTINUACAO DE HISTORICO
		cProcCT2 += "		AND CT2.D_E_L_E_T_ = ' '  "+ CRLF
		cProcCT2 += "		AND CT2_MOEDLC = '"+MV_PAR05+"' "+ CRLF
		cProcCT2 += "		AND CARQTMP.D_E_L_E_T_ = ' ' "+ CRLF
		cProcCT2 += "	  ORDER BY CARQTMP.R_E_C_N_O_,CT2_FILIAL, CARQTMP.CONTA, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_SEQHIS "+ CRLF
		cProcCT2 += "	Open cCursor4 "+CRLF
		cProcCT2 += "	Fetch cCursor4 into "
		cProcCT2 += "		@cCT2_FILIAL, "
		cProcCT2 += "		@cConta, "
		cProcCT2 += "		@cCT2_DATA, "
		cProcCT2 += "		@cCT2_DC, "
		cProcCT2 += "		@cCT2_LOTE, "
		cProcCT2 += "		@cCT2_SBLOTE, "
		cProcCT2 += "		@cCT2_DOC, "
		cProcCT2 += "		@cCT2_LINHA, "
		cProcCT2 += "		@cCT2_HIST, "
		cProcCT2 += "		@cCT2_EMPORI, "
		cProcCT2 += "		@cCT2_FILORI, "
		cProcCT2 += "		@cCT2_SEQHIS, "
		cProcCT2 += "		@cCT2_SEQLAN,  @iRecnoTmp "

		cProcCT2 += CRLF

		If ( "MSSQL" $ Upper(TCGetDb()) )
			cProcCT2 += "	SELECT @cHistCT2 = RTRIM( @cCT2_HIST ) " + CRLF
		Else
			cProcCT2 += "	SELECT @cHistCT2 = TRIM( @cCT2_HIST ) " + CRLF
		EndIf

		cProcCT2 += CRLF

		cProcCT2 += "	while @@FETCH_STATUS = 0"
		cProcCT2 += "	begin"+CRLF
		cProcCT2 += CRLF

		//Fernando Radu
		cProcCT2 += "		SELECT @cFilial = @cCT2_FILIAL " + CRLF
		cProcCT2 += "		SELECT @cContaHist = @cConta " + CRLF
		cProcCT2 += "		SELECT @cData = @cCT2_DATA " + CRLF
		cProcCT2 += "		SELECT @cLote = @cCT2_LOTE " + CRLF
		cProcCT2 += "		SELECT @cSubLote = @cCT2_SBLOTE " + CRLF
		cProcCT2 += "		SELECT @cDoc = @cCT2_DOC " + CRLF
		cProcCT2 += "		SELECT @cSeqLan = @cCT2_SEQLAN " + CRLF
		cProcCT2 += "   SELECT @cHistOri =  @cCT2_HIST " +CRLF
	
		cProcCT2 += "   SELECT  @iRecnoTmpAnt  = @iRecnoTmp " + CRLF 
		cProcCT2 += CRLF
		cProcCT2 += "  IF @iRecnoTmp = @iRecnoTmpAnt  BEGIN "+CRLF
	
		If ( "MSSQL" $ Upper(TCGetDb()) )
			cProcCT2 += " 	SELECT @cHistCT2FIM  =  SUBSTRING(@cHistCT2FIM||RTRIM( @cCT2_HIST),1,"+cValToChar(nR400Char)+") " +CRLF
		Else
			cProcCT2 += " 	SELECT @cHistCT2FIM  =  SUBSTRING(@cHistCT2FIM|| TRIM( @cCT2_HIST),1,"+cValToChar(nR400Char)+") " +CRLF
		EndIf

		cProcCT2 += "    END "+CRLF
		cProcCT2 += " 	 FETCH cCursor4 "+CRLF
		cProcCT2 += " 	 INTO @cCT2_FILIAL , @cConta , @cCT2_DATA , @cCT2_DC , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cCT2_LINHA , @cCT2_HIST , " +CRLF
		cProcCT2 += "    @cCT2_EMPORI , @cCT2_FILORI , @cCT2_SEQHIS , @cCT2_SEQLAN,@iRecnoTmp"+CRLF
				

		cProcCT2 += " IF  @iRecnoTmp != @iRecnoTmpAnt  BEGIN  "+CRLF
		cProcCT2 += "			BEGIN TRAN " + CRLF
		cProcCT2 += CRLF
		cProcCT2 += "			UPDATE " + CRLF
		cProcCT2 += "				" + cArqTmp + CRLF
		cProcCT2 += "			SET " + CRLF
		cProcCT2 += "			HISTORICO = @cHistCT2FIM " + CRLF
		cProcCT2 += "			WHERE " + CRLF
		cProcCT2 += "		   R_E_C_N_O_ = @iRecnoTmpAnt "
		cProcCT2 += CRLF
		cProcCT2 += "			COMMIT TRAN " + CRLF
		cProcCT2 += "     SELECT  @cHistCT2FIM = '' "+ CRLF
		cProcCT2 += "	    End "+ CRLF 
		cProcCT2 += "	    End "+ CRLF  //finaliza While
		cProcCT2 += "   BEGIN TRAN "+ CRLF 
		cProcCT2 += "     UPDATE "+CRLF
		cProcCT2 += "		 "+ cArqTmp+  CRLF
		cProcCT2 += "      SET  "
		cProcCT2 += "       HISTORICO  = @cHistCT2FIM "+ CRLF 
		cProcCT2 += "       WHERE R_E_C_N_O_  = @iRecnoTmpAnt "+ CRLF 
		cProcCT2 += "         COMMIT TRAN  "+ CRLF
	
		cProcCT2 += "   If @iCommit > 0 begin"+CRLF
		cProcCT2 += "      select @iCommit = 0"+CRLF
		cProcCT2 += "      select @iTranCount = 0"+CRLF
		cProcCT2 += "	end"+CRLF

		cProcCT2 += "   close cCursor4"+CRLF
		cProcCT2 += "   deallocate cCursor4"+CRLF
		cProcCT2 += CRLF

		EndIf

	cProcCT2 += "   select @OUT_RET = '1' "+CRLF  //atribui retorno 1 se bem sucedido

EndIf


//CURSOR PARA PEGAR AS ENTIDADES SEM MOVIMENTACAO
If lNoMov .or. lSldAnt

	If !lExclusivo   //CT2 COMPARTILHADA

		If cGetDB $ "ORACLE" 
			cInsSMTmp += "BEGIN" +CRLF
		EndIf
	
		cInsSMTmp += "INSERT INTO " + cArqTMP + " (FILIAL , DATAL , CONTA , HISTORICO , EMPORI , FILORI ) " + CRLF

		cInsSMTmp += "SELECT "

		//If cTipo == "1"  //SE CT2 COMPARTILHADA OBRIGATORIAMENTE CT1 VAI SER COMPARTILHADO
			
		cInsSMTmp += "CT1_FILIAL, " // FILIAL
		cInsSMTmp += "'"+DTOS(dDataIni)+"', "// DATAL
		cInsSMTmp += "CT1_CONTA, " //CONTA
		cInsSMTmp += "'"+STR0021+"', "  		//"CONTA SEM MOVIMENTO NO PERIODO"
		cInsSMTmp += "'"+cEmpAnt+"', " // EMPORI
		cInsSMTmp += "'"+cFilAnt+"' "+CRLF // FILORI

		cInsSMTmp += "FROM "+RetSqlName("CT1")+ " CT1 " +CRLF

		If lSldAnt .And. cTipo == "1"
			//cInsSMTmp += ","+RetSqlName("CQ1")+" CQ1 "
			cInsSMTmp += "	INNER JOIN "+RetSqlName("CQ1")+" CQ1 " +CRLF
			cInsSMTmp += "	ON " +CRLF
			cInsSMTmp += "	CT1.CT1_CONTA = CQ1.CQ1_CONTA" +CRLF
		EndIf

		cInsSMTmp += "WHERE" +CRLF

		If lSldAnt .And. ctipo == "1"  //CONTA
			//query para pegar saldo anterior
			cInsSMTmp += CRLF

			cInsSMTmp += "        CQ1.CQ1_FILIAL  " + cGetRngFil+CRLF  //tem o mesmo compartilhamento da CT2
			
			If !Empty(c2Moeda)
				cInsSMTmp += "       AND ( CQ1.CQ1_MOEDA = '" + cMoeda  + "' OR "
				cInsSMTmp += "       CQ1.CQ1_MOEDA = '" + c2Moeda + "'  ) "
			Else
				cInsSMTmp += "       AND CQ1.CQ1_MOEDA = '" + cMoeda  + "' "+CRLF
			EndIf
			
			cInsSMTmp += "         AND CQ1.CQ1_TPSALD = '"+ cSaldo + "' "+CRLF

			cInsSMTmp += "         AND CQ1.D_E_L_E_T_ = ' ' "+CRLF
			cInsSMTmp += "         AND CQ1.CQ1_DATA   < '" + DTOS(dDataIni) + "' "+CRLF
			// removido filtro de Lucros e perdas que causavam erro na composi��o do saldo anterior
			// cInsSMTmp += "         AND CQ1.CQ1_LP = (SELECT MAX(CQ1_LP) "+CRLF
			// cInsSMTmp += "                            FROM "+RetSqlName("CQ1")+" CQ13 "+CRLF

			// cInsSMTmp += "                            WHERE CQ13.CQ1_FILIAL = CQ1.CQ1_FILIAL "+CRLF
			// cInsSMTmp += "                            AND CQ13.CQ1_MOEDA  = CQ1.CQ1_MOEDA "+CRLF
			// cInsSMTmp += "                            AND CQ13.CQ1_TPSALD = CQ1.CQ1_TPSALD "+CRLF
			// cInsSMTmp += "                            AND CQ13.CQ1_CONTA  = CQ1.CQ1_CONTA "+CRLF
			// cInsSMTmp += "                            AND CQ13.CQ1_DATA   < '" + DTOS(dDataIni) + "' "+CRLF
			// cInsSMTmp += "                            AND CQ13.D_E_L_E_T_ = ' ') "+CRLF
			cInsSMTmp += " 	   						  AND"

		EndIf
		
		cInsSMTmp += " CT1_FILIAL = '" +xFilial("CT1")+"' "+CRLF
		cInsSMTmp += " AND CT1_CONTA >= '"+cContaI+"' "+ CRLF
		cInsSMTmp += " AND CT1_CONTA <= '"+cContaF+"' "+ CRLF
		cInsSMTmp += " AND CT1_CLASSE = '2' "+ CRLF
		cInsSMTmp += " AND CT1.D_E_L_E_T_  = ' ' "+ CRLF
		cInsSMTmp += " AND CT1_CONTA NOT IN  ( SELECT CONTA "+ CRLF
		cInsSMTmp += "                         FROM "+cArqTmp+"  )"+ CRLF
		

		If lSldAnt .And. ctipo == "1"  //CONTA
			cInsSMTmp += CRLF
			cInsSMTmp += " GROUP BY CQ1.D_E_L_E_T_ ,"   //SOMENTE PARA RODAR EM TODOS OS BANCOS (NA VERDADE AGRUPA TODOS)
			cInsSMTmp += " CT1.CT1_FILIAL, CT1.CT1_CONTA"+CRLF   
			cInsSMTmp += " HAVING (COALESCE ( SUM(CQ1_DEBITO), 0) <> 0 OR COALESCE ( SUM(CQ1_CREDIT), 0) <> 0 );"+CRLF
		Else
			cInsSMTmp += ";" + CRLF
		EndIf

		If cGetDB $ "ORACLE" 
			cInsSMTmp += "END;"
		EndIf

	Else  //CT2 EXCLUSIVO EM ALGUM SEGMENTO

		If cGetDB $ "ORACLE" 
			cInsSMTmp += "BEGIN " +CRLF
		EndIf

		cInsSMTmp += "INSERT INTO " + cArqTMP + " (FILIAL , DATAL , CONTA , HISTORICO , EMPORI , FILORI ) " + CRLF

		//If cTipo == "1"
		nTamEnt := Len(Alltrim(xFilial("CT1"))) // Com gest�o corporativa
		
		cInsSMTmp += "SELECT DISTINCT '" + xFilial("CT1") + "',"
		cInsSMTmp += "'"+DTOS(dDataIni)+"',"
		cInsSMTmp += "CT1_CONTA, "
		cInsSMTmp += "'" + STR0021 + "', "
		cInsSMTmp += "'" + cEmpAnt + "', 
		cInsSMTmp += "'" + cFilAnt + "'"+ CRLF
		cInsSMTmp += "FROM "+RetSqlName("CT1")+ " CT1 "


		If lSldAnt .And. cTipo == "1"
			cInsSMTmp += "INNER JOIN "+RetSqlName("CQ1")+" CQ1 " +CRLF
			cInsSMTmp += "ON " +CRLF
			cInsSMTmp += "CT1.CT1_CONTA = CQ1.CQ1_CONTA" +CRLF
			cInsSMTmp += "INNER JOIN " +cRealTmp+ " XFILCT2" +CRLF  
			cInsSMTmp += "ON "
			cInsSMTmp += "CQ1.CQ1_FILIAL  " + cGetRngFil+CRLF  //tem o mesmo compartilhamento da CT2"
		Else
			cInsSMTmp += ", "+cRealTmp+ " XFILCT2  " + CRLF
		EndIf

		cInsSMTmp += "WHERE " +CRLF

		If lSldAnt .And. ctipo == "1"  //CONTA
			//query para pegar saldo anterior
			cInsSMTmp += CRLF

			If !Empty(c2Moeda)
				cInsSMTmp += " ( CQ1.CQ1_MOEDA = '" + cMoeda  + "' OR "
				cInsSMTmp += " CQ1.CQ1_MOEDA = '" + c2Moeda + "'  ) "
			Else
				cInsSMTmp += " CQ1.CQ1_MOEDA = '" + cMoeda  + "' "
			EndIf

			cInsSMTmp += CRLF
			cInsSMTmp += "  AND CQ1.CQ1_TPSALD = '"+ cSaldo + "' "+CRLF
			//cInsSMTmp += "        AND CQ1.CQ1_CONTA  =  @cConta "+CRLF
			cInsSMTmp += "  AND CQ1.D_E_L_E_T_ = ' ' "+CRLF
			cInsSMTmp += "  AND CQ1.CQ1_DATA   < '" + DTOS(dDataIni) + "' "+CRLF
			// removido filtro de Lucros e perdas que causavam erro na composi��o do saldo anterior
			// cInsSMTmp += "  AND CQ1.CQ1_LP = (SELECT MAX(CQ1_LP) "+CRLF  
			// cInsSMTmp += "                    FROM "+RetSqlName("CQ1")+" CQ13 "+CRLF
			// cInsSMTmp += "                    WHERE CQ13.CQ1_FILIAL = CQ1.CQ1_FILIAL "+CRLF
			// cInsSMTmp += "                    AND CQ13.CQ1_MOEDA  = CQ1.CQ1_MOEDA "+CRLF
			// cInsSMTmp += "                    AND CQ13.CQ1_TPSALD = CQ1.CQ1_TPSALD "+CRLF
			// cInsSMTmp += "                    AND CQ13.CQ1_CONTA  = CQ1.CQ1_CONTA "+CRLF
			// cInsSMTmp += "                    AND CQ13.CQ1_DATA   < '" + DTOS(dDataIni) + "' "+CRLF
			// cInsSMTmp += "                    AND CQ13.D_E_L_E_T_ = ' ') "+CRLF
			cInsSMTmp += "  AND  "
			
		EndIf



		If xFilial("CT1") == xFilial("CT2")  //se tem o mesmo compartilhamento e for exclusivo em ambas em algum segmento
			cInsSMTmp += " CT1_FILIAL = XFILCT2.TMPFIL "+CRLF
		Else
			cInsSMTmp += " CT1_FILIAL = "+ cSubstr +"(XFILCT2.TMPFIL,1,"+cValToChar(nTamEnt)+")"
			If nTamEnt > 0 .Or. cGetDB $ "ORACLE"
				cInsSMTmp += cConcat +"'"+Space(nTamFil-nTamEnt)+"'"+CRLF
			Else 
				cInsSMTmp += CRLF
			EndIf
		EndIf

		cInsSMTmp += " AND CT1_CONTA >= '"+cContaI+"' "+ CRLF
		cInsSMTmp += " AND CT1_CONTA <= '"+cContaF+"' "+ CRLF
		cInsSMTmp += " AND CT1_CLASSE = '2' "+ CRLF
		cInsSMTmp += " AND CT1.D_E_L_E_T_  = ' ' "+ CRLF
		cInsSMTmp += " AND CT1_CONTA NOT IN  ( SELECT CONTA FROM "+cArqTmp+" " + CRLF

		If !Empty(xFilial("CT1"))
			If xFilial("CT1") == xFilial("CT2")  //se for exclusivo em ambas em algum segmento
				cInsSMTmp += " WHERE CT1_FILIAL = FILIAL "+CRLF
			Else
				cInsSMTmp += " WHERE CT1_FILIAL = " + cSubstr + "(XFILCT2.TMPFIL,1,"+cValToChar(nTamEnt)+")"+ cConcat +"'"+Space(nTamFil-nTamEnt)+"'"+CRLF
			EndIf
		EndIf

		cInsSMTmp += " ) "
		

		If lSldAnt .And. ctipo == "1"  //CONTA
			cInsSMTmp += CRLF
			cInsSMTmp += "GROUP BY CQ1.D_E_L_E_T_, "+CRLF   //SOMENTE PARA RODAR EM TODOS OS BANCOS (NA VERDADE AGRUPA TODOS)
			cInsSMTmp += "CT1.CT1_CONTA "+CRLF   //SOMENTE PARA RODAR EM TODOS OS BANCOS (NA VERDADE AGRUPA TODOS)
			cInsSMTmp += "HAVING (COALESCE ( SUM(CQ1_DEBITO), 0) <> 0 OR COALESCE( SUM(CQ1_CREDIT), 0) <> 0 ); "+CRLF
			// HAVING (COALESCE ( SUM(CQ1_DEBITO ), 0 ) <> 0 OR COALESCE ( SUM(CQ1_CREDIT ), 0 ) <> 0)
		Else 
			cInsSMTmp += ";" + CRLF
		EndIf

		If cGetDB $ "ORACLE" 
			cInsSMTmp += "END;"
		EndIf

	EndIf

EndIf 

/* Ser�o executados 3 passos.
 1. Executar o insert inicial de lan�amentos de d�bito e cr�dito
 2. Executar a procedure de continua��es de hist�rico se o tipo do relat�rio for diferente de resumido.
 3. Executar o insert de contas sem movimento no per�odo
 */

//1. Insert debitos e cr�ditos

nRet := TcSqlExec(cInsDCTmp)

If nRet <> 0

	If !__lBlind

		MsgAlert(STR0089 /* + CRLF + cInsTmp */)  //'Erro na criacao da procedure '
		//lRet:= .F.

	EndIf

EndIf

// Caso o retorno do comando do passo 1 seja 0 (SUCESSO), executar o passo 2
If nRet == 0 .And. ( nTipoRel <> 3 )
    cProcCT2 := MsParse(cProcCT2,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))

	If cGetDB $ "MSSQL7" 
		cProcCT2 := StrTran(cProcCT2, "SET @iTranCount  = 0", cCommit)
	ElseIf cGetDB = "ORACLE" 
		cProcCT2 := StrTran(cProcCT2, "viTranCount  := 0", cCommit)
	EndIf

	//ajustar pois MSPARSE esta retirando um # do nome da tabela nos select .... From cArqTmp
	cProcCT2 := StrTran(cProcCT2, " #TMP", " ##TMP")

	//instalar a procedure
	If Empty( cProcCT2 )
		MsgAlert(MsParseError(),STR0069+cNomProc)  //'A query nao passou pelo Parse '
		//lRet := .F.
	Else

		If !TCSPExist( cNomProc )

			nProcRet := TcSqlExec(cProcCT2)

			If nProcRet <> 0

				If !__lBlind

					MsgAlert(STR0070+cProcCT2)  //'Erro na criacao da procedure '
					//lRet:= .F.

				EndIf

			EndIf

		EndIf

	EndIf

	//executa a procedure
	aResult := TCSPExec( cNomProc  )
	TcRefresh(cArqTmp)

	If Empty(aResult) .Or. aResult[1] = "0"
		MsgAlert(tcsqlerror(), STR0071) //"Erro na gera��o arquivo temporario para relatorio."
		//lRet := .F.
	Else
		//apaga a procedure apos carregar o temporario
		If TCSPExist( cNomProc )
			If TcSqlExec("DROP PROCEDURE "+cNomProc) <> 0
				UserException(STR0072 + cNomProc + CRLF + TCSqlError() ) //"Erro na dele��o da Procedure de extra��o dos dados no arquivo temporario."
			Else
				//lRet := .T.
			EndIf
		Endif
	EndIf	

EndIf

// Caso o passo 1 e passo 2 tenham sido executados com sucesso, executar o passo 3
If nRet == 0 .And. nProcRet == 0 .And. (lNoMov .or. lSldAnt)

	nRet := TcSqlExec(cInsSMTmp) 


	If nRet <> 0

		If !__lBlind

			MsgAlert( STR0089 /* + CRLF + cInsSMTmp */)  //'Erro na criacao da procedure '
			//lRet:= .F.

		EndIf

	EndIf

EndIf

CtbTmpErase(cTmpCT2Fil)
CtbTmpErase(cTmpCT1Fil)
CtbTmpErase(cTmpCTTFil)
CtbTmpErase(cTmpCTDFil)
CtbTmpErase(cTmpCTHFil)

Return
