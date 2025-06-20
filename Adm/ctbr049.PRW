#Include "PROTHEUS.Ch"
#Include "CTBR049.Ch"


#DEFINE 	COL_SEPARA1			1
#DEFINE 	COL_CONTA 			2
#DEFINE 	COL_SEPARA2			3
#DEFINE 	COL_DESCRICAO		4
#DEFINE 	COL_SEPARA3			5
#DEFINE 	COL_SALDO_ANT    	6
#DEFINE 	COL_SEPARA4			7
#DEFINE 	COL_VLR_DEBITO   	8
#DEFINE 	COL_SEPARA5			9
#DEFINE 	COL_VLR_CREDITO  	10
#DEFINE 	COL_SEPARA6			11
#DEFINE 	COL_MOVIMENTO 		12
#DEFINE 	COL_SEPARA7			13
#DEFINE 	COL_SALDO_ATU 		14
#DEFINE 	COL_SEPARA8			15
#DEFINE 	TAM_VALOR			20

STATIC _oCtbr0491

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � Ctbr049	� Autor � Alvaro Camillo Neto  � Data � 12.09.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Balancete Analitico Plano de Contas Referencial            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ctbr049()                               			 		  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nenhum       											  ���
�������������������������������������������������������������������������Ĵ��
���Uso    	 � Generico     											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctbr049()
Local lImpBalR4		:= TRepInUse()

Private titulo		:= ""
Private nomeprog	:= "CTBR049"
PRIVATE cCvdCodPla:= ""
Private cPlanoRef	:= ""	//utilizado na consulta padrao CVN3 -> Fun��o CtbFilVers()
Private cVersao		:= ""	//utilizado na consulta padrao CVN3 -> Fun��o CtbFilVers()

If lImpBalR4
	CTBR049R4()
Else
	MsgAlert(STR0001)//"Relatorio dispon�vel apenas em TReport"
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR049R4 � Autor� Daniel Sakavicius		� Data � 01/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Balancete Analitico Sintetico Modelo 1 - R4                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR049R4												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR049R4()
Local oReport := Nil

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������

Private aSelFil		:= {}
Private cPerg2		:= "CTBPLREF2"

Pergunte("CTR049A",.F.)

oReport := ReportDef()

If Valtype( oReport ) == 'O'
	If ! Empty( oReport:uParam )
		Pergunte( oReport:uParam, .F. )
	EndIf
	
	oReport:PrintDialog()
Endif

oReport := Nil

//Deleta tabela temporaria do banco de dados
If _oCtbr0491 <> Nil
	_oCtbr0491:Delete()
	_oCtbr0491 := Nil
Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Daniel Sakavicius		� Data � 28/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta funcao tem como objetivo definir as secoes, celulas,   ���
���          �totalizadores do relatorio que poderao ser configurados     ���
���          �pelo relatorio.                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
local aArea	   		:= GetArea()
Local CREPORT		:= "CTBR049"
Local CTITULO		:= STR0002  			//"Emissao do Relat. Plan. Ref. "
Local CDESC			:= OemToAnsi(STR0003) // "Este programa ira imprimir o Balancete baseado na amarra�� do plano de contas com o plano de contas referencial"
Local cPerg	   		:= "CTR049A"
Local CCOLBAR		:= "|"
Local aTamConta		:= TAMSX3("CT1_CONTA")
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local aTamDesc		:= {40}
Local cPictVal 		:= PesqPict("CT2","CT2_VALOR")
Local nDecimais
Local cSeparador	:= ""
Local nTamConta		:= 20
Local nMaskFator 	:= 1
Local oReport 

 
If Pergunte( "CTR049A" , .T. )

	cPlanoRef	:= mv_par03
	cVersao		:= mv_par04
	
	If Empty(cPlanoRef) .Or. Empty(cVersao)
		MsgAlert(STR0023)	//"Plano Referencial e/ou Vers�o n�o preenchidos. " 
		Return
	EndIf	
	
	DbSelectArea("CVN")
	DbSetOrder(4) 	//CVN_FILIAL+CVN_CODPLA+CVN_VERSAO+CVN_CTAREF                                                                                                                     
	If !DbSeek(xFilial("CVN")+cPlanoRef+cVersao)	
		MsgAlert(STR0024)	//"Plano Ref. e Versao n�o cadastrados no Cad. Plano Referencial."
		Return
	Endif		 	
	 	
	If mv_par16 == 1 .And. Len( aSelFil ) <= 0  .And. !IsBlind()
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			Return
		EndIf
	EndIf
	
	Pergunte(cPerg2,.T.)	//Exibe a pergunta de Intervalo de Contas
		
	nTamConta := aTamConta[1]
	cPicture := ""
	
	//������������������������������������������������������������������������Ŀ
	//�Criacao do componente de impressao                                      �
	//�                                                                        �
	//�TReport():New                                                           �
	//�ExpC1 : Nome do relatorio                                               �
	//�ExpC2 : Titulo                                                          �
	//�ExpC3 : Pergunte                                                        �
	//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
	//�ExpC5 : Descricao                                                       �
	//��������������������������������������������������������������������������
	
	oReport	:= TReport():New( cReport,Capital(CTITULO),cPerg, { |oReport| Pergunte(cPerg , .F. ), If(! ReportPrint( oReport ), oReport:CancelPrint(), .T. ) }, CDESC )
	oReport:ParamReadOnly()
	
	IF GETNEWPAR("MV_CTBPOFF",.T.)
		oReport:SetEdit(.F.)
	ENDIF
	
	//������������������������������������������������������������������������Ŀ
	//�Criacao da secao utilizada pelo relatorio                               �
	//�                                                                        �
	//�TRSection():New                                                         �
	//�ExpO1 : Objeto TReport que a secao pertence                             �
	//�ExpC2 : Descricao da se�ao                                              �
	//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
	//�        sera considerada como principal para a se��o.                   �
	//�ExpA4 : Array com as Ordens do relat�rio                                �
	//�ExpL5 : Carrega campos do SX3 como celulas                              �
	//�        Default : False                                                 �
	//�ExpL6 : Carrega ordens do Sindex                                        �
	//�        Default : False                                                 �
	//�                                                                        �
	//��������������������������������������������������������������������������
	oSection1  := TRSection():New( oReport, STR0004, {"cArqRef","CT1"},, .F., .F.,,,,,,,,,0 ) //"Plano de contas referencial"
	
	TRCell():New( oSection1, "CONTA"	,,STR0005/*Titulo*/	,/*Picture*/, nTamConta /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"LEFT"*/,,/*"LEFT"*/,,,.F.) //"Conta"
	TRCell():New( oSection1, "DESCCTA"  ,,STR0006/*Titulo*/	,/*Picture*/, aTamDesc[1]/*Tamanho*/, /*lPixel*/,/*CodeBlock*/,  /*"LEFT"*/,.T.,/*"LEFT"*/,,,.F.)//"Descricao"
	TRCell():New( oSection1, "SALDOANT" ,,STR0007/*Titulo*/	,/*Picture*/, TAM_VALOR+2 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,,"RIGHT",,,.F.)//"Saldo anterior"
	TRCell():New( oSection1, "SALDODEB" ,,NoAcento(AnsiToOEM(STR0008))/*Titulo*/	,/*Picture*/, TAM_VALOR+2 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,,"RIGHT",,,.F.)//"D�bito"
	TRCell():New( oSection1, "SALDOCRD" ,,NoAcento(AnsiToOEM(STR0009))/*Titulo*/	,/*Picture*/, TAM_VALOR+2 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,,"RIGHT",,,.F.)//"Cr�dito"
	TRCell():New( oSection1, "MOVIMENTO",,STR0010/*Titulo*/	,/*Picture*/, TAM_VALOR+2 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,,"RIGHT",,,.F.)//"Mov  periodo"
	TRCell():New( oSection1, "SALDOATU" ,,STR0011/*Titulo*/	,/*Picture*/, TAM_VALOR+2 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,,"RIGHT",,,.F.)//"Saldo atual"
	
	TRPosition():New( oSection1, "CT1", 1, {|| xFilial( "CT1" ) + cArqRef->CONTA })
	
	oSection1:Cell("CONTA"):lHeaderSize		:= .F.
	oSection1:Cell("DESCCTA"):lHeaderSize	:= .F.
	oSection1:Cell("SALDOANT"):lHeaderSize	:= .F.
	oSection1:Cell("SALDODEB"):lHeaderSize	:= .F.
	oSection1:Cell("SALDOCRD"):lHeaderSize	:= .F.
	oSection1:Cell("MOVIMENTO"):lHeaderSize	:= .F.
	oSection1:Cell("SALDOATU"):lHeaderSize	:= .F.
	
	oSection1:SetTotalInLine(.F.)
	oSection1:SetTotalText('')
	oSection1:SetEdit(.F.)
Endif

Return( oReport )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Daniel Sakavicius	� Data � 28/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime o relatorio definido pelo usuario de acordo com as  ���
���          �secoes/celulas criadas na funcao ReportDef definida acima.  ���
���          �Nesta funcao deve ser criada a query das secoes se SQL ou   ���
���          �definido o relacionamento e filtros das tabelas em CodeBase.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportPrint(oReport)                                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPO1: Objeto do relat�rio                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport )

Local oSection1 	:= oReport:Section(1)
Local lExterno		:= .F.
Local dDataFim 		:= mv_par02
Local lFirstPage	:= .T.
Local lJaPulou		:= .F.
Local lRet			:= .T.
Local lPrintZero	:= (mv_par11==1)
Local lVlrZerado	:= (mv_par06==1)
Local l132			:= .T.
Local nDecimais
Local nDivide		:= 1
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotMov		:= 0
Local nGrpDeb		:= 0
Local nGrpCrd		:= 0
Local nDigitAte		:= 0
Local lImpAntLP		:= (mv_par13 == 1)
Local dDataLP		:= mv_par14
Local lImpMov		:= (mv_par10== 1)
Local n
Local oMeter
Local oText
Local oDlg
Local oBreak
Local lImpPaisgm	:= .F.
Local nMaxLin   	:= mv_par15
Local cMoedaDsc		:= mv_par05
Local aCtbMoeda		:= {}
Local aCtbMoedadsc	:= {}
Local CCOLBAR		:= "|"
Local cTipoAnt		:= ""
Local cGrupoAnt		:= ""
Local cArqRef		:= "cArqRef"
Local Tamanho		:= "M"
Local cSeparador	:= ""
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local oTotGerDeb
Local oTotGerCrd
Local cPicture
Local cContaSint
Local cBreak		:= "2"
Local cGrupo		:= ""
Local nTotGerDeb	:= 0
Local nTotGerCrd	:= 0
Local nTotGerMov	:= 0
Local nCont			:= 0
Local nMasc			:= 0
Local cMasc			:= ""
Local lEnd
Local aSetOfBook := CTBSetOf("")
Local cFilTit		:= ""
Local nX


Private nLinReport    := 9

If oReport:nDevice == 5 .OR. oReport:nDevice == 3
	oSection1:Cell("SALDOANT"):SetAlign("RIGHT")
	oSection1:Cell("SALDODEB"):SetAlign("RIGHT")
	oSection1:Cell("SALDOCRD"):SetAlign("RIGHT")
	oSection1:Cell("MOVIMENTO"):SetAlign("RIGHT")
	oSection1:Cell("SALDOATU"):SetAlign("RIGHT")
Endif

VldPlanRef(mv_par03)

If mv_par12 == 2			// Divide por cem
	nDivide := 100
ElseIf mv_par12 == 3		// Divide por mil
	nDivide := 1000
ElseIf mv_par12 == 4		// Divide por milhao
	nDivide := 1000000
EndIf

If lRet
	aCtbMoeda := CtbMoeda( mv_par07 , nDivide )
	
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		lRet := .F.
		Return lRet
	Endif
	
	// valida��o da descri��o da moeda
	if lRet .And. ! Empty( mv_par05 ) 
		aCtbMoedadsc := CtbMoeda( mv_par05 , nDivide )
		
		If Empty( aCtbMoedadsc[1] )
			Help( " " , 1 , "NOMOEDA")
			lRet := .F.
			Return lRet
		Endif
	Endif
Endif

aCtbMoeda  	:= CtbMoeda(mv_par07,nDivide)

cDescMoeda 	:= Alltrim(aCtbMoeda[2])
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par07)
cPicture 	:= ""

lPrintZero	:= Iif(mv_par11==1,.T.,.F.)

cDescPlan := GetAdvFval("CVN","CVN_DSCPLA",xFilial("CVN") + mv_par03 ,2 )
If oReport:Title() == oReport:cRealTitle
	Titulo:=	OemToAnsi(STR0012) + " " + Alltrim(cDescPlan) + CRLF 	//"BALANCETE PLANO REFERENCIAL: "
	Titulo += 	STR0013 + DTOC(mv_par01) + OemToAnsi(STR0014) + Dtoc(mv_par02) + ;//" DE "##" ATE "
	OemToAnsi(STR0015) + cDescMoeda + CtbTitSaldo(mv_par09)//" EM "
Else
	Titulo := oReport:Title()
Endif

If Len(aSelFil) > 0
	For nX := 1 to Len(aSelFil)
		cFilTit += Alltrim(aSelFil[nX]) + If( nX<Len(aSelFil),If(nX+1 == Len(aSelFil),STR0016,",")," ")//" E "
	Next nX
	Titulo += If(Len(aSelFil)>1,STR0017,STR0018)+cFilTit //" - FILIAIS: "##" - FILIAL: "
EndIf

oReport:SetPageNumber( mv_par08 )
oReport:SetCustomText( {|| nCtCGCCabTR(dDataFim,titulo,oReport)})


//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao			  		     �
//����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
CtSalPlanRef(oMeter, oText, oDlg, @lEnd,@cArqRef,mv_par01,mv_par02,mv_par03,mv_par04,;
mv_par07,mv_par09,lImpAntLP,dDataLP,nDivide,lVlrZerado,aSelfil)},;
OemToAnsi(OemToAnsi(STR0019)),;  //"Criando Arquivo Temporario..."
OemToAnsi(STR0020))  				//"Balancete Verificacao"

nCount := (cArqRef)->(RecCount())

oReport:SetMeter(nCont)

If nCount > 0
	
	(cArqRef)->(dbGoTop())
	
	oSection1:Cell("CONTA"):SetBlock( {|| (cArqRef)->CONTA } )
	
	oSection1:Cell("DESCCTA"):SetBlock( { || (cArqRef)->DESCCTA } )
	
	oSection1:Cell("SALDOANT"):SetBlock( { || ValorCTB((cArqRef)->SALDOANT,,,TAM_VALOR-2,nDecimais,.T.,cPicture,,,,,,,lPrintZero,.F.) } )
	oSection1:Cell("SALDODEB"):SetBlock( { || ValorCTB((cArqRef)->SALDODEB,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) } )
	oSection1:Cell("SALDOCRD"):SetBlock( { || ValorCTB((cArqRef)->SALDOCRD,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) } )
	oSection1:Cell("SALDOATU"):SetBlock( { || ValorCTB((cArqRef)->SALDOATU,,,TAM_VALOR-2,nDecimais,.T.,cPicture,,,,,,,lPrintZero,.F.) } )
	
	//	 Imprime Movimento
	If !lImpMov
		oSection1:Cell("MOVIMENTO"):SetSize(0)
		oSection1:Cell("MOVIMENTO"):Disable()
	Else
		oSection1:Cell("MOVIMENTO"):SetBlock( { || ValorCTB((cArqRef)->MOVIMENTO,,,TAM_VALOR-2,nDecimais,.T.,cPicture,,,,,,, lPrintZero,.F.) } )
	EndIf
	
	//******************************
	// Total Geral do relatorio    *
	//******************************
	oBrkGeral := TRBreak():New(oSection1, { || (cArqRef)->(!Eof()) },{|| STR0021 },,,.F.)	//	" T O T A I S "
	
	// Totaliza
	oTotGerDeb := TRFunction():New(oSection1:Cell("SALDODEB"),,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	{ || (cArqRef)->SALDODEB },.F.,.F.,.F.,oSection1)
	oTotGerDeb:Disable()
	
	oTotGerCrd := TRFunction():New(oSection1:Cell("SALDOCRD"),,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	{ || (cArqRef)->SALDOCRD },.F.,.F.,.F.,oSection1)
	oTotGerCrd:Disable()
	
	
	TRFunction():New(oSection1:Cell("SALDODEB"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	{ || ValorCTB(oTotGerDeb:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) },.F.,.F.,.F.,oSection1)
	
	
	// Imprime
	TRFunction():New(oSection1:Cell("SALDOCRD"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	{ || ValorCTB(oTotGerCrd:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.)},.F.,.F.,.F.,oSection1)
	
	oSection1:OnPrintLine( {|| 	CTR049OnPrint( nMaxLin, @nLinReport,oReport ) } )
	
	oSection1:Print()
	
EndIf

dbSelectArea(cArqRef)
Set Filter To
dbCloseArea()
//Deleta tabela temporaria do banco de dados
If _oCtbr0491 <> Nil
	_oCtbr0491:Delete()
	_oCtbr0491 := Nil
Endif

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CtSalPlanRef�Autor�Alvaro Camillo Neto � Data �  28/05/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna o arquivo de trabalho com os saldos do plano       ���
���          � de contas referencial                                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CtSalPlanRef(oMeter, oText, oDlg,lEnd,cArqTrab,dDataIni,dDataFim,cPlanRef,cVersao,cMoeda,cTpSald,lImpAntLP,dDataLP,nDivide,lVlrZerado,aSelfil)
Local cQuery 		:= ""
Local cAliasCVD		:= ""
Local cArqCVD		:= ""
Local aCampos		:= {}
Local aTamConta		:= TAMSX3("CT1_CONTA")
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local nTamCta 		:= Len(CriaVar("CT1->CT1_DESC"+cMoeda))
Local aTamClasse	:= TAMSX3("CVD_CLASSE")
Local aTamCtaSup	:= TAMSX3("CVD_CTASUP")
Local aCtbMoeda 	:= CTbMoeda(cMoeda)
Local nDecimais 	:= aCtbMoeda[5]
Local aSaldoAnt		:= {}
Local aSaldoAtu		:= {}
Local cWhere		:= ""

Local nRegSupTmp 	:= 0
Local nSldSupAnt	:= 0 
Local nSldSupAtu	:= 0 
Local nSldSupDeb	:= 0
Local nSldSupCrd 	:= 0
Local nMovSup		:= 0
Local cSuperior		:= ''

Local nCont			:= 0
		
Default cArqTrab		:= "cArqRef"
Default nDivide			:= 1


Pergunte(cPerg2,.F.)

MakeSqlExpr(cPerg2)

cWhere	:= MV_PAR01 //SUBSTRING(MV_PAR01,13,LEN(ALLTRIM(MV_PAR01))-13)

//�����������������������������(�
//�Monta a estrutura do arquivo�
//�����������������������������(�
aAdd(aCampos, { "CONTA"		, "C", aTamConta[1]	, 0 })
aAdd(aCampos, { "DESCCTA"	, "C", nTamCta		, 0 })
aAdd(aCampos, { "SALDOANT"	, "N", aTamVal[1]+2	, nDecimais })
aAdd(aCampos, { "SALDODEB"	, "N", aTamVal[1]+2	, nDecimais })
aAdd(aCampos, { "SALDOCRD"	, "N", aTamVal[1]+2	, nDecimais })
aAdd(aCampos, { "SALDOATU"	, "N", aTamVal[1]+1	, nDecimais })
aAdd(aCampos, { "MOVIMENTO"	, "N", aTamVal[1]+1	, nDecimais })
aAdd(aCampos, { "CLASSE"	, "C", aTamClasse[1], 0 })
aAdd(aCampos, { "SUPERIOR"	, "C", aTamCtaSup[1], 0 })
cChave := "CONTA"

If _oCtbr0491 <> Nil
	_oCtbr0491:Delete()
	_oCtbr0491 := Nil
Endif

_oCtbr0491 := FWTemporaryTable():New( cArqTrab )  
_oCtbr0491:SetFields(aCampos) 
_oCtbr0491:AddIndex("1", {cChave})

//------------------
//Cria��o da tabela temporaria
//------------------
_oCtbr0491:Create()  

dbSelectArea(cArqTrab)		

//�������������������Ŀ
//�Seleciona o arquivo�
//���������������������
cAliasCVD := GetNextAlias()
cQuery 	+= " SELECT "
cQuery 	+= " 	CVD_CONTA, "
cQuery 	+= " 	CVD_ENTREF, "
cQuery 	+= " 	CVD_CODPLA, "
cQuery 	+= " 	CVD_CTAREF, "
cQuery 	+= " 	CVD_CUSTO, "
cQuery 	+= " 	CVD_CLASSE,	"
cQuery 	+= " 	CVD_CTASUP  "
cQuery 	+= " FROM  "
cQuery 	+= RetSQLTab("CVD")
cQuery 	+= " WHERE  "
cQuery 	+= " 	CVD_CODPLA = '"+cPlanRef+"' AND "
cQuery 	+= " 	CVD_VERSAO = '"+cVersao+"' AND "
cQuery	+= "    CVD_CTAREF <> '' AND "
If !Empty(cWhere)
	cQuery  += cWhere
	cQuery	+= " AND " 
EndIf	
cQuery 	+= RetSQLCond("CVD")
cQuery 	+= "ORDER BY CVD_CODPLA,CVD_CTAREF, CVD_CTASUP "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCVD,.T.,.T.)

//���������������������������Ŀ
//�Processa o saldo das contas�
//�����������������������������
If (cAliasCVD)->(!Eof())
	While  (cAliasCVD)->(!Eof()) 
		lCusto := !Empty((cAliasCVD)->CVD_CUSTO )
		
		If lCusto
			aSaldoAnt	:= SaldoCT3Fil((cAliasCVD)->CVD_CONTA,(cAliasCVD)->CVD_CUSTO,dDataIni,cMoeda,cTpSald,'CTBXFUN',lImpAntLP,dDataLP,aSelFil)
			aSaldoAtu	:= SaldoCT3Fil((cAliasCVD)->CVD_CONTA,(cAliasCVD)->CVD_CUSTO,dDataFim,cMoeda,cTpSald,'CTBXFUN',lImpAntLP,dDataLP,aSelFil)
		Else
			aSaldoAnt	:= SaldoCT7Fil((cAliasCVD)->CVD_CONTA,dDataIni,cMoeda,cTpSald,'CTBXFUN',lImpAntLP,dDataLP,aSelFil)
			aSaldoAtu	:= SaldoCT7Fil((cAliasCVD)->CVD_CONTA,dDataFim,cMoeda,cTpSald,'CTBXFUN',lImpAntLP,dDataLP,aSelFil)
		EndIf
		
		nSaldoAntD 	:= aSaldoAnt[7]
		nSaldoAntC 	:= aSaldoAnt[8]
		
		nSldAnt		:= nSaldoAntC - nSaldoAntD
		
		nSaldoAtuD 	:= aSaldoAtu[4]
		nSaldoAtuC 	:= aSaldoAtu[5]
		nSldAtu		:= nSaldoAtuC - nSaldoAtuD
		
		nSaldoDeb  := nSaldoAtuD - nSaldoAntD
		nSaldoCrd  := nSaldoAtuC - nSaldoAntC
		
		If nDivide > 1
			nSaldoDeb	:= Round(NoRound((nSaldoDeb/nDivide),3),2)
			nSaldoCrd	:= Round(NoRound((nSaldoCrd/nDivide),3),2)
		EndIf
		
		nMovimento	:= nSaldoCrd-nSaldoDeb
		
		If nDivide > 1
			For nCont := 1 To Len(aSaldoAnt)
				aSaldoAnt[nCont] := Round(NoRound((aSaldoAnt[nCont]/nDivide),3),2)
			Next nCont
			For nCont := 1 To Len(aSaldoAtu)
				aSaldoAtu[nCont] := Round(NoRound((aSaldoAtu[nCont]/nDivide),3),2)
			Next nCont
		EndIf
		
		
		If lVlrZerado .Or. (aSaldoAnt[6] <> 0 .Or. aSaldoAtu[1] <> 0 )
			If(cArqTrab)->(MsSeek( (cAliasCVD)->CVD_CTAREF ) )
				RecLock(cArqTrab,.F.)
				
				(cArqTrab)->SALDOANT 	+= aSaldoAnt[6]				// Saldo anterior
				(cArqTrab)->SALDOATU 	+= aSaldoAtu[1]	   			// Saldo Atual
				(cArqTrab)->SALDODEB	+= nSaldoDeb				// Saldo Debito
				(cArqTrab)->SALDOCRD	+= nSaldoCrd				// Saldo Credito
				(cArqTrab)->MOVIMENTO 	:= (cArqTrab)->(SALDOCRD-SALDODEB)////Movimento
				
				MsUnlock()
			Else
				RecLock(cArqTrab,.T.)
				(cArqTrab)->CONTA		:= (cAliasCVD)->CVD_CTAREF
				(cArqTrab)->DESCCTA		:= GetAdvFval("CVN","CVN_DSCCTA",xFilial("CVN") + (cAliasCVD)->(CVD_CODPLA + CVD_CTAREF),2 )
				(cArqTrab)->SALDOANT 	:= aSaldoAnt[6]			   				// Saldo anterior
				(cArqTrab)->SALDOATU 	:= aSaldoAtu[1]	   		   				// Saldo Atual
				(cArqTrab)->SALDODEB	:= nSaldoDeb			   				// Saldo Debito
				(cArqTrab)->SALDOCRD	:= nSaldoCrd			   				// Saldo Credito
				(cArqTrab)->MOVIMENTO 	:= (cArqTrab)->(SALDOCRD-SALDODEB)		// Movimento
				(cArqTrab)->CLASSE		:= (cAliasCVD)->CVD_CLASSE
				(cArqTrab)->SUPERIOR	:= (cAliasCVD)->CVD_CTASUP
				MsUnlock()
			EndIf
		EndIf
		(cAliasCVD)->(dbSkip())
	EndDo
	
EndIf

//-----------------------------------------
// Atualiza o saldo das Contas Sint�ticas
// Somente ser�o impresso o saldo das contas 
//   sinteticas, caso o parametros Imprime
//   Contas Zeradas esteja igual a SIM.
// Isso porque as contas sinteticas nao 
//   possuem valores;
//-----------------------------------------

	dbSelectArea(cArqTrab)
	(cArqTrab)->(dbGoTop())
	
	While ( (cArqTrab)->( !Eof() ) )
		If (cArqTrab)->CLASSE == '2'
			nRegSupTmp 	:= Recno()
			nSldSupAnt	:= (cArqTrab)->SALDOANT 
			nSldSupAtu	:= (cArqTrab)->SALDOATU 
			nSldSupDeb	:= (cArqTrab)->SALDODEB
			nSldSupCrd 	:= (cArqTrab)->SALDOCRD
			nMovSup		:= (cArqTrab)->MOVIMENTO
			cSuperior	:= (cArqTrab)->SUPERIOR
	
			While ( (cArqTrab)->( !Eof() ) .And. !(AllTrim((cArqTrab)->CONTA) == AllTrim(cSuperior)) ) 
				If (cArqTrab)->(MsSeek(cSuperior) )
					RecLock(cArqTrab,.F.)
					(cArqTrab)->SALDOANT 	+= nSldSupAnt	// Saldo anterior
					(cArqTrab)->SALDOATU 	+= nSldSupAtu	// Saldo Atual
					(cArqTrab)->SALDODEB	+= nSldSupDeb	// Saldo Debito
					(cArqTrab)->SALDOCRD	+= nSldSupCrd	// Saldo Credito
					(cArqTrab)->MOVIMENTO 	+= nMovSup      // Movimento
					MsUnlock()
					cSuperior	:= (cArqTrab)->SUPERIOR
				Else

					//Busca conta superior e inclui tmp					
					If ! Empty( cSuperior )
						
						CVD->(DbSelectArea("CVD"))
						CVD->(DbSetOrder(2)) //CVD_FILIAL, CVD_CODPLA, CVD_CTAREF, CVD_CONTA, CVD_VERSAO

						If CVD->(MsSeek( xFilial("CVD") + cPlanRef + cSuperior ))							

							RecLock(cArqTrab,.T.)
								(cArqTrab)->CONTA		:= cSuperior
								(cArqTrab)->DESCCTA		:= GetAdvFval("CVN","CVN_DSCCTA",xFilial("CVN") + ( cPlanRef + cSuperior),2 )
								(cArqTrab)->SALDOANT 	:= nSldSupAnt		   	// Saldo anterior
								(cArqTrab)->SALDOATU 	:= nSldSupAtu	   		// Saldo Atual
								(cArqTrab)->SALDODEB	:= nSldSupDeb			// Saldo Debito
								(cArqTrab)->SALDOCRD	:= nSldSupCrd			// Saldo Credito
								(cArqTrab)->MOVIMENTO 	:= nMovSup				// Movimento															
								(cArqTrab)->CLASSE		:= CVD->CVD_CLASSE
								(cArqTrab)->SUPERIOR	:= CVD->CVD_CTASUP
							MsUnlock()	

						EndIf	
					EndIf
					cSuperior	:= (cArqTrab)->SUPERIOR
				EndIf
				
				//Verifica se chegou at� a conta de maior n�vel
				If AllTrim(cSuperior) = ''
					Exit
				EndIf
			EndDo
	
			//Zera o saldo das contas
			nSldSupAnt 	:= 0	//Saldo anterior
			nSldSupAtu 	:= 0	//Saldo Atual
			nSldSupDeb	:= 0	//Saldo Debito
			nSldSupCrd	:= 0	//Saldo Credito
			nMovSup 	:= 0	//Movimento
			
			dbGoto(nRegSupTmp)
		EndIf
		
		(cArqTrab)->(dbSkip())
	EndDo

dbSelectArea(cAliasCVD)
dbCloseArea()
dbSelectArea("CVD")

Pergunte("CTR049A",.F.)

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTR049OnPrint �Autor � Gustavo Henrique � Data � 07/02/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Executa acoes especificadas nos parametros do relatorio,   ���
���          � antes de imprimir cada linha.                              ���
�������������������������������������������������������������������������͹��
���Parametros� EXPL1 - Indicar se deve saltar linha entre conta sintetica ���
���          � EXPL2 - Indicar se deve quebrar pagina por conta           ���
���          � EXPN3 - Informar o total de linhas por pagina do balancete ���
���          � EXPC4 - Guardar o tipo da conta impressa (sint./analitica) ���
���          � EXPN5 - Guardar linha atual do relatorio para validacao    ���
���          �         com o valor do parametro EXPN3.                    ���
�������������������������������������������������������������������������͹��
���Retorno   � EXPL1 - Indicar se deve imprimir a linha (.T.)             ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTR049OnPrint(  nMaxLin, nLinReport,oReport )

Local lRet := .T.

If ! Empty(nMaxLin)
	CTR049MaxL(nMaxLin,@nLinReport,oReport)
EndIf

Return lRet


/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  � CTR049MAXL �Autor � Eduardo Nunes Cirqueira � Data �  31/01/07 ���
�����������������������������������������������������������������������������͹��
���Desc.     � Baseado no parametro MV_PAR15 ("Num.linhas p/ o Balancete      ���
���          � Modelo 1"), cujo conteudo esta na variavel "nMaxLin", controla ���
���          � a quebra de pagina no TReport                                  ���
�����������������������������������������������������������������������������͹��
���Uso       � AP                                                             ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function CTR049MaxL(nMaxLin,nLinReport,oReport)

nLinReport++

If nLinReport > nMaxLin
	oReport:EndPage()
	nLinReport := 10
EndIf

Return Nil


/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � nCtCGCCabTR  � Autor � Fabio Jadao Caires      � Data � 31/01/07���
������������������������������������������������������������������������������͹��
���Desc.     � Chama a funcao padrao CtCGCCabTR reiniciando o contador de      ���
���          � linhas para o controle do relatorio.                            ���
���          �                                                                 ���
������������������������������������������������������������������������������͹��
���Uso       � AP                                                              ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
STATIC FUNCTION nCtCGCCabTR(dDataFim,titulo,oReport)

nLinReport := 10

RETURN CtCGCCabTR(,,,,,dDataFim,titulo,,,,,oReport)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VldPlanRef�Autor  �Alvaro Camillo Neto � Data �  05/31/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida��o do plano de contas referencial                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VldPlanRef(cCodPlan)
Local lRet := .T.

If !Empty( AllTrim(cCodPlan) )
	lRet := ExistCpo("CVN",AllTrim(cCodPlan))
	
	If lRet
		cCvdCodPla := AllTrim(cCodPlan)
	Else
		cCvdCodPla := ""
	EndIf
Else
	cCvdCodPla := ""
Endif

Return lRet
