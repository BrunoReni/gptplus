#INCLUDE "REPORT.CH"
#include "PROTHEUS.CH"
#include "ATFR033.CH"
#INCLUDE "DBINFO.CH"

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Programa  �ATFR033        �Autor  �Fernando Radu Muscalu� Data �  10/03/2011 ���
�������������������������������������������������������������������������������͹��
���Desc.     �Relatorio da ficha do ativo em nova versao					    ���
�������������������������������������������������������������������������������͹��
���Parametros�															        ���
�������������������������������������������������������������������������������͹��
���Retorno   �nil																���
�������������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                          ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

Function ATFR033()

Local oReport
Local lTReport	:= TRepInUse()
Local lDefTop 	:= IfDefTopCTB()	 // verificar se pode executar query (TOPCONN)

Private aSelFil	:= {}
Private aSelMoed:= {}
Private aSelClass:= {}
Private lTodasFil:= .F.

Private cPerg := "AFR033"

If !lDefTop
	Help("  ",1,"AFR072TOP",,STR0001 ,1,0)//"Fun��o dispon�vel apenas para ambientes TopConnect"
	Return
EndIf

If !lTReport
	Help("  ",1,"AFR072R4",,STR0002,1,0)//"Fun��o dispon�vel apenas em TReport"
	Return
ENdIf

lRet := Pergunte( cPerg , .T. )

If lRet
	If mv_par12 == 1 .And. Len( aSelFil ) <= 0
		aSelFil := AdmGetFil(@lTodasFil)
		If Len( aSelFil ) <= 0
			Return
		EndIf
	EndIf

	If mv_par13 == 1 .And. Len( aSelMoed ) <= 0
		aSelMoed := ADMGETMOED()
		If Len( aSelMoed ) <= 0
			Return
		EndIf
		If Len( aSelMoed ) > 5
			Help(" ",1,"ATR072MOE",,STR0003,1,0)//"Devem ser selecionadas no m�ximo cinco moedas"
			Return
		EndIf
	Else
		aSelMoed := {"01"}
	EndIf

	//Seleciona as classifica��es patrimoniais
	If MV_PAR14 == 1 .And. Len( aSelClass ) <= 0 
		aSelClass := AdmGetClas()
		If Len( aSelClass ) <= 0
			Return		
		EndIf
	EndIf

	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

Return()

/*���������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Programa  �ReportDef      �Autor  �Fernando Radu Muscalu� Data �  10/03/2011 ���
�������������������������������������������������������������������������������͹��
���Desc.     �Cria objeto a partir da classe TReport()   					    ���
�������������������������������������������������������������������������������͹��
���Parametros�															        ���
�������������������������������������������������������������������������������͹��
���Retorno   �oReport	- objeto TReport										���
�������������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                          ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport		:= nil
Local oSecBem		:= nil
Local oSecCTB		:= nil
Local oSecVal		:= nil
Local oSecTit		:= nil
Local oSecSumBas	:= nil
Local oSecSumEnt	:= nil
Local oSecSumFil	:= nil
Local oSecSumAll	:= nil
Local bFunction		:= {||}


Pergunte("AFR033",.f.)

bFunction 	:= {|| AFR033RptPrt(oReport) }

oReport :=	TReport():New("ATFR033",STR0036,"AFR033",bFunction,STR0036)//"Demonstrativo de Ativo Fixo"

If cPaisloc = "PER"
	oReport		:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,/*cTitulo*/STR0036,,,,,oReport) } )
EndIf

//Secoes--------------------------------------------------------------------------------

//definicao da secao//Bem
oSecBem:= TRSection():New(oReport,STR0036 ,{"SN1","NAOUSADO"})// "Demonstrativo de Ativo Fixo"
oSecBem:SetHeaderPage(.T.) //Unico cabecalho por pagina

//definicao das colunas
TRCell():New(oSecBem,"N1_FILIAL", "SN1")
TRCell():New(oSecBem,"N1_CBASE", "SN1")
TRCell():New(oSecBem,"N1_ITEM", "SN1")
TRCell():New(oSecBem,"N1_DESCRIC", "SN1", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,.T.,,,,.T.)
TRCell():New(oSecBem,"N1_CHAPA", "SN1")
TRCell():New(oSecBem,"N1_GRUPO", "SN1")
TRCell():New(oSecBem,"N1_AQUISIC", "SN1")
TRCell():New(oSecBem,"N1_PROJETO", "SN1")
TRCell():New(oSecBem,SerieNfId("SN1",3,"N1_NSERIE"), "SN1")
TRCell():New(oSecBem,"N1_NFISCAL", "SN1")
TRCell():New(oSecBem,"N1_QUANTD", "SN1")
TRCell():New(oSecBem,"N1_FORNEC", "SN1")
TRCell():New(oSecBem,"N1_LOJA", "SN1" )
TRCell():New(oSecBem,"DESC_FORN", "", STR0005, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,.T.,,,,.T.)
 //"Nome Fornec."

//definicao da secao//Dados Contabil
oSecCTB	:= TRSection():New(oSecBem, STR0034 ,{"SN3","NAOUSADO"})// "Dados Tipo"
oSecCTB:SetHeaderPage(.T.) //Unico cabecalho por pagina
oSecCTB:SetLeftMargin(3)

TRCell():New(oSecCTB,"N3_TIPO",,,,2)
TRCell():New(oSecCTB,"DESC_TIPO",,STR0006,,25,,,,.T.,,,,.T.)//"Desc. Tipo"
TRCell():New(oSecCTB,"CLASS_TIPO",,STR0007,,25,,,,.T.,,,,.T.)//"Class. Tipo"
TRCell():New(oSecCTB,"N3_HISTOR","SN3",,,25,,,,.T.,,,,.T.)
TRCell():New(oSecCTB,"N3_TIPREAV","SN3",,,5)
TRCell():New(oSecCTB,"N3_TPDEPR","SN3",,,1)
TRCell():New(oSecCTB,"MET_DESC","SN0",STR0008,,25,,,,.T.,,,,.T.)//"M�todo Depr."
TRCell():New(oSecCTB,"N3_CCONTAB","SN3",,,35)
TRCell():New(oSecCTB,"N3_CUSTBEM","SN3",,,20)
TRCell():New(oSecCTB,"N3_SUBCCON","SN3",,,20)
TRCell():New(oSecCTB,"N3_CLVLCON","SN3",,,20)
TRCell():New(oSecCTB,"N3_DTBAIXA","SN3",,,8)
TRCell():New(oSecCTB,"N2_HISTOR","SN2", STR0009,,40,,,,.T.,,,,.T.)//"Desc. Extendida"

//definicao da secao//Valores
oSecVal := TRSection():New(oSecCTB, STR0035)// "Valores"
oSecVal:SetHeaderPage(.T.)
oSecVal:SetLeftMargin(3)

TRCell():New(oSecVal,"MOEDA",,"",,10)
TRCell():New(oSecVal,"VIDA"	,,STR0010,"@e 9,999,999,999.9999",18,,,,,"RIGHT")//"Vida �til"
TRCell():New(oSecVal,"VALORES",,STR0011,"@e 9,999,999,999.9999",18,,,,,"RIGHT") //"Valor Original"
TRCell():New(oSecVal,"VAL_AMPL",,STR0032,"@e 9,999,999,999.9999",18,,,,,"RIGHT") //"Valor Amplia��o"
TRCell():New(oSecVal,"VAL_ACUM",,STR0012,"@e 9,999,999,999.9999",18,,,,,"RIGHT")//"Vlr. Depr. Acum."
TRCell():New(oSecVal,"VAL_BAI",,STR0017,"@e 9,999,999,999.9999",18,,,,,"RIGHT")//"Vlr. Baixa"
TRCell():New(oSecVal,"VAL_RES",,STR0013,"@e 9,999,999,999.9999",18,,,,,"RIGHT")//"Vlr. Residual"
TRCell():New(oSecVal,"BAIXA","", STR0014,,10,,,,.T.,,,,.T.)//"Baixa"
TRCell():New(oSecVal,"N3_CODIND","", STR0037,,10,,,,.T.,,,,.T.)//"Cod. �ndice"


//definicao da secao//Totais por Base
oSecSumBas := TRSection():New(oReport,STR0016)//"Totais"
oSecSumBas:SetHeaderSection(.F.)
oSecSumBas:SetLeftMargin(3)

//Celulas

TRCell():New(oSecSumBas,"MOEDA"			,,""					,,10)
TRCell():New(oSecSumBas,"FAKE_VIDA"		,,""					,,18)
TRCell():New(oSecSumBas,"VALORES"		,,STR0010		,"@e 9,999,999,999.9999",18)//"Vida �til"
TRCell():New(oSecSumBas,"VAL_AMPL",,STR0032,"@e 9,999,999,999.9999",18,,,,,"RIGHT") //"Valor Amplia��o"
TRCell():New(oSecSumBas,"VAL_ACUM"		,,STR0012	,"@e 9,999,999,999.9999",18)//"Valor Original"
TRCell():New(oSecSumBas,"VAL_BAI"	,,STR0017		,"@e 9,999,999,999.9999",18)//"Vlr Baixa"
TRCell():New(oSecSumBas,"VAL_RESID"		,,STR0013		,"@e 9,999,999,999.9999",18)//"Vlr. Depr. Acum."
TRCell():New(oSecSumBas,"FAKE_BAIXA"	,,""		,,10)

//definicao da secao//Totais por entidade
oSecSumEnt := TRSection():New(oReport,STR0016)//"Totais"
oSecSumEnt:SetHeaderSection(.F.)
oSecSumEnt:SetLeftMargin(3)

//Celulas
TRCell():New(oSecSumEnt,"MOEDA"			,,""					,,10)
TRCell():New(oSecSumEnt,"FAKE_VIDA"		,,""					,,18)
TRCell():New(oSecSumEnt,"VALORES"		,,STR0012		,"@e 9,999,999,999.9999",18)//"Valor Original"
TRCell():New(oSecSumEnt,"VAL_AMPL",,STR0032,"@e 9,999,999,999.9999",18,,,,,"RIGHT") //"Valor Amplia��o"
TRCell():New(oSecSumEnt,"VAL_ACUM"		,,STR0013	,"@e 9,999,999,999.9999",18)//"Vlr. Depr. Acum."
TRCell():New(oSecSumEnt,"VAL_BAI"	,,STR0017		,"@e 9,999,999,999.9999",18)//"Vlr Baixa"
TRCell():New(oSecSumEnt,"VAL_RESID"		,,STR0015		,"@e 9,999,999,999.9999",18)//"Vlr. Residual"
TRCell():New(oSecSumEnt,"FAKE_BAIXA"	,,""		,,10)

//definicao da secao//Totais por filial
oSecSumFil := TRSection():New(oReport,STR0016)//"Totais"
oSecSumFil:SetHeaderSection(.F.)
oSecSumFil:SetLeftMargin(3)

//Celulas
TRCell():New(oSecSumFil,"MOEDA"			,,""					,,10)
TRCell():New(oSecSumFil,"FAKE_VIDA"		,,""					,,18)
TRCell():New(oSecSumFil,"VALORES"		,,STR0012		,"@e 9,999,999,999.9999",18)//"Valor Original"
TRCell():New(oSecSumFil,"VAL_AMPL",,STR0032,"@e 9,999,999,999.9999",18,,,,,"RIGHT") //"Valor Amplia��o"
TRCell():New(oSecSumFil,"VAL_ACUM"		,,STR0013	,"@e 9,999,999,999.9999",18)//"Vlr. Depr. Acum."
TRCell():New(oSecSumFil,"VAL_BAI"	,,STR0017		,"@e 9,999,999,999.9999",18)//"Vlr Baixa"
TRCell():New(oSecSumFil,"VAL_RESID"		,,STR0015		,"@e 9,999,999,999.9999",18)//"Vlr. Residual"
TRCell():New(oSecSumFil,"FAKE_BAIXA"	,,""		,,10)


//definicao da secao//Total Geral
oSecSumAll := TRSection():New(oReport,STR0016)//"Totais"
oSecSumAll:SetHeaderSection(.F.)
oSecSumAll:SetLeftMargin(3)

//Celulas
TRCell():New(oSecSumAll,"MOEDA"			,,""					,,10)
TRCell():New(oSecSumAll,"FAKE_VIDA"		,,""					,,18)
TRCell():New(oSecSumAll,"VALORES"		,,STR0012		,"@e 9,999,999,999.9999",18)//"Valor Original"
TRCell():New(oSecSumAll,"VAL_AMPL",,STR0032,"@e 9,999,999,999.9999",18,,,,,"RIGHT") //"Valor Amplia��o"
TRCell():New(oSecSumAll,"VAL_ACUM"		,,STR0013	,"@e 9,999,999,999.9999",18)//"Vlr. Depr. Acum."
TRCell():New(oSecSumAll,"VAL_BAI"	,,STR0017		,"@e 9,999,999,999.9999",18)//"Vlr Baixa"
TRCell():New(oSecSumAll,"VAL_RESID"		,,STR0015		,"@e 9,999,999,999.9999",18)//"Vlr. Residual"
TRCell():New(oSecSumAll,"FAKE_BAIXA"	,,""		,,10)

//definicao da secao//Titulos dos totais
oSecTit := TRSection():New(oReport,STR0016)//"Totais"
oSecTit:SetHeaderSection(.f.)
oSecTit:SetLeftMargin(3)

//Celulas
TRCell():New(oSecTit,"TITULO1"			,,,,100)

oReport:SetLandScape()
oReport:ParamReadOnly()
oReport:DisableOrientation()


//--------------------------------------------------------------------------------Secoes
Return(oReport)

/*���������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Programa  �ReportDef      �Autor  �Fernando Radu Muscalu� Data �  10/03/2011 ���
�������������������������������������������������������������������������������͹��
���Desc.     �Impressao da Ficha do ativo de acordo com os parametros definidos ���
���          �pelo usuario.			 											���
�������������������������������������������������������������������������������͹��
���Parametros�oReport	- Objeto TReport								        ���
�������������������������������������������������������������������������������͹��
���Retorno   �nil																���
�������������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                          ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/
Static Function AFR033RptPrt(oReport)

Local oSecBem		:= oReport:Section(1)
Local oSecCTB		:= oReport:Section(1):Section(1)
Local oSecVal		:= oReport:Section(1):Section(1):Section(1)
Local oSecSumBas	:= oReport:Section(2)
Local oSecSumEnt	:= oReport:Section(3)
Local oSecSumFil	:= oReport:Section(4)
Local oSecSumAll	:= oReport:Section(5)
Local oSecTit		:= oReport:Section(6)
Local cAliasTmp	:= Criatrab( , .F. )
Local oMeter
Local oText
Local oDlg
Local lEnd

Local nI			:= 0
Local nP			:= 0
Local nTpDepr 		:= 0

Local aSN1			:= {}
Local aSN3			:= {}
Local aQuebras		:= {}
Local aSumBase		:= {}
Local aSumEnt		:= {}
Local aSumFil		:= {}
Local aSumAll		:= {}

Local bRefreshVar 	:= {||}

Local cMoeda		:= ""
Local cMoedaAnt		:= ""
Local cAfr33Filial	:= ""

Local dDataSLD  	:= MV_PAR01
Local cBemIni   	:= MV_PAR02
Local cBemFim   	:= MV_PAR03
Local cItemIni  	:= MV_PAR04
Local cItemFim  	:= MV_PAR05
Local cGrupoIni	:= MV_PAR06
Local cGrupoFim	:= MV_PAR07
Local cBaixa		:= cValtoChar(MV_PAR08)
Local nTotCBase	:= MV_PAR09
Local nOrdEnt  	:= MV_PAR10
Local nEntida		:= MV_PAR11
Local lFirst		:= .T.
Local lRealProv	:= .T.
Local cArqAux

Private cAfr33Base		:= ""
Private cAfr33Tipo		:= ""
Private cAfr33Item		:= ""
Private cAfr33Baix		:= ""
Private cAfr33Seq			:= ""
Private cAfr33Reav		:= ""
Private cAfr33Conta		:= ""
Private cAfr33Custo		:= ""
Private cAfr33ItCtb		:= ""
Private cAfr33ClVl		:= ""

If Select(cAliasTmp) > 0
	cAliasTmp->(DbCloseArea())
	MSErase(cAliasTmp)
End If

aQuebras := Afr033RetBlock(nEntida,nOrdEnt,cAliasTmp)

/*
 * Verifica��o do campo para ativos de custo de provis�o
 */
DbSelectArea("SN3")
lRealProv := MV_PAR15 == 1

//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao						 �
//����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
ATFGERSLDM(oMeter,oText,oDlg,lEnd,cAliasTmp,,dDataSLD,dDataSLD,cBemIni,cBemFim,cItemIni,cItemFim,,,;
,,,,,,cGrupoIni,cGrupoFim,aSelMoed,aSelFil,lTodasFil,aQuebras[4],,,,cBaixa,,aSelClass,lRealProv) },;
OemToAnsi(OemToAnsi(STR0018)),;//"Criando Arquivo Tempor�rio..."
OemToAnsi(STR0036))

bRefreshVar := aQuebras[1] // atualiza variaveis

aSumBase    := Afr033Totais(aSelMoed)
aSumEnt		:= Afr033Totais(aSelMoed)
aSumFil		:= Afr033Totais(aSelMoed)
aSumAll		:= Afr033Totais(aSelMoed)

oSecTit:Init()
oSecSumBas:Init()
oSecSumEnt:Init()
oSecSumFil:Init()
oSecSumAll:Init()

oReport:SetMeter( lastRec() )

(cAliasTmp)->(DBGOTOP())

lRet := (cAliasTmp)->(!Eof())

While (cAliasTmp)->(!Eof())  .And. lRet

	cMoeda := Alltrim(str(val((cAliasTmp)->MOEDA)))
	nTpDepr := AF33TPDEPR((cAliasTmp)->TIPO)

	If nTotCBase == 1 //soma pelo codigo base
		//efetua a soma
		If (nP := aScan(aSumBase,{|x| alltrim(x[1]) == Alltrim((cAliasTmp)->MOEDA)})) > 0
			aSumBase[nP,nTpDepr,1] += (cAliasTmp)->ORIGINAL
			aSumBase[nP,nTpDepr,2] += (cAliasTmp)->DEPRECACM
			aSumBase[nP,nTpDepr,3] += (cAliasTmp)->VLBAIXAS
			aSumBase[nP,nTpDepr,4] += (cAliasTmp)->RESIDUAL
			aSumBase[nP,nTpDepr,5] += (cAliasTmp)->AMPLIACAO
		Endif
	Endif

	If nOrdEnt == 1 //soma pela entidade
		//efetua a soma
		If (nP := aScan(aSumEnt,{|x| alltrim(x[1]) == Alltrim((cAliasTmp)->MOEDA)})) > 0
			aSumEnt[nP,nTpDepr,1] += (cAliasTmp)->ORIGINAL
			aSumEnt[nP,nTpDepr,2] += (cAliasTmp)->DEPRECACM
			aSumEnt[nP,nTpDepr,3] += (cAliasTmp)->VLBAIXAS
			aSumEnt[nP,nTpDepr,4] += (cAliasTmp)->RESIDUAL
			aSumEnt[nP,nTpDepr,5] += (cAliasTmp)->AMPLIACAO
		Endif
	Endif

	//soma pela filial
	If (nP := aScan(aSumFil,{|x| alltrim(x[1]) == Alltrim((cAliasTmp)->MOEDA)})) > 0
		aSumFil[nP,nTpDepr,1] += (cAliasTmp)->ORIGINAL
		aSumFil[nP,nTpDepr,2] += (cAliasTmp)->DEPRECACM
		aSumFil[nP,nTpDepr,3] += (cAliasTmp)->VLBAIXAS
		aSumFil[nP,nTpDepr,4] += (cAliasTmp)->RESIDUAL
		aSumFil[nP,nTpDepr,5] += (cAliasTmp)->AMPLIACAO
	Endif

	//soma do total geral
	If (nP := aScan(aSumAll,{|x| alltrim(x[1]) == Alltrim((cAliasTmp)->MOEDA)})) > 0
		aSumAll[nP,nTpDepr,1] += (cAliasTmp)->ORIGINAL
		aSumAll[nP,nTpDepr,2] += (cAliasTmp)->DEPRECACM
		aSumAll[nP,nTpDepr,3] += (cAliasTmp)->VLBAIXAS
		aSumAll[nP,nTpDepr,4] += (cAliasTmp)->RESIDUAL
		aSumAll[nP,nTpDepr,5] += (cAliasTmp)->AMPLIACAO
	Endif

	If &(aQuebras[2])
	   If !lFirst
			oReport:SkipLine()
			oReport:ThinLine()
		Else
			lFirst:= .F.
		EndIf
		
		oSecBem:Init()

		cFilSN1 := xFilial("SN1",(cAliasTmp)->FILIAL)
		If oSecBem:UseFilter()
		TRPosition():New(oSecBem,"SN1",1,{|| cFilSN1 + (cAliasTmp)->CBASE + (cAliasTmp)->ITEM })
		Endif
		aSN1 := GetAdvFVal("SN1",{"N1_PROJETO", SerieNfId("SN1",3,"N1_NSERIE"),"N1_NFISCAL","N1_FORNEC","N1_LOJA"}, cFilSN1 + (cAliasTmp)->CBASE + (cAliasTmp)->ITEM ,1,{"","","","",""})
		oSecBem:Cell("N1_FILIAL"):SetValue( cFilSN1 )		//(cAliasTmp)->FILIAL
		oSecBem:Cell("N1_CBASE"):SetValue( (cAliasTmp)->CBASE )			//(cAliasTmp)->CBASE
		oSecBem:Cell("N1_ITEM"):SetValue( (cAliasTmp)->ITEM )       	//(cAliasTmp)->ITEM
		oSecBem:Cell("N1_DESCRIC"):SetValue( (cAliasTmp)->DESC_SINT )	//(cAliasTmp)->DESC_SINT
		oSecBem:Cell("N1_CHAPA"):SetValue( (cAliasTmp)->CHAPA )			//(cAliasTmp)->CHAPA
		oSecBem:Cell("N1_GRUPO"):SetValue( (cAliasTmp)->GRUPO )			//(cAliasTmp)->GRUPO
		oSecBem:Cell("N1_AQUISIC"):SetValue( (cAliasTmp)->AQUISIC )		//(cAliasTmp)->AQUISIC
		oSecBem:Cell("N1_PROJETO"):SetValue( aSN1[1] )				//SEEK NO SN1
		oSecBem:Cell(SerieNfId("SN1",3,"N1_NSERIE")):SetValue( aSN1[2] )				//SEEK NO SN1
		oSecBem:Cell("N1_NFISCAL"):SetValue( aSN1[3] )				//SEEK NO SN1
		oSecBem:Cell("N1_QUANTD"):SetValue( (cAliasTmp)->QUANTD )		//(cAliasTmp)->QUANTD
		oSecBem:Cell("N1_FORNEC"):SetValue( aSN1[4] )				//SEEK NO SN1
		oSecBem:Cell("N1_LOJA"):SetValue( aSN1[5] )				//SEEK NO SN1
		oSecBem:Cell("DESC_FORN"):SetValue( GetAdvFVal("SA2","A2_NREDUZ",xFilial("SA2") + aSN1[4] + aSN1[5] ,1,"") ) //SEEK NO SA2
		oSecBem:PrintLine()
		oSecBem:Finish()

		oReport:SkipLine()	

	Endif
	
	If &(aQuebras[3])
		
		oReport:SkipLine()
		oSecCTB:Init()
		
		cFilSN3 := xFilial("SN3",(cAliasTmp)->FILIAL)
		If oSecCTB:UseFilter()
		TRPosition():New(oSecCTB,"SN3",1,{|| cFilSN3 + (cAliasTmp)->( CBASE + ITEM + TIPO + FLAGBAIXA + SEQ + SEQREAV) })
		Endif
		aSN3 := GetAdvFVal("SN3",{"N3_HISTOR","N3_TIPREAV","N3_TPDEPR","N3_TXDEPR" + cMoeda,"N3_PERDEPR","N3_PRODMES","N3_PRODANO","N3_CODIND"},cFilSN3 + (cAliasTmp)->( CBASE + ITEM + TIPO + FLAGBAIXA + SEQ + SEQREAV)  ,1,{"","","","","","",""})
		oSecCTB:Cell("N3_TIPO"):SetValue(  (cAliasTmp)->TIPO  ) //(cAliasTmp)->TIPO
		oSecCTB:Cell("DESC_TIPO"):SetValue(  GetAdvFVal("SX5","X5_DESCRI",xFilial("SX5") + "G1" + (cAliasTmp)->TIPO,1,"") )
		oSecCTB:Cell("CLASS_TIPO"):SetValue(  ATFXDTPBEM((cAliasTmp)->TIPO)  )
		oSecCTB:Cell("N3_HISTOR"):SetValue(  aSN3[1] )		//SEEK NO SN3
		oSecCTB:Cell("N3_TIPREAV"):SetValue(  aSN3[2] )	//SEEK NO SN3
		oSecCTB:Cell("N3_TPDEPR"):SetValue(  aSN3[3] )		//SEEK NO SN3
		oSecCTB:Cell("MET_DESC"):SetValue( GetAdvFVal("SN0","N0_DESC01",xFilial("SN0") + "04" + Alltrim(aSN3[3]),1,"")  )//SEEK NO SN0
		oSecCTB:Cell("N3_CCONTAB"):SetValue(  (cAliasTmp)->CONTA )	//(cAliasTmp)->CONTA
		oSecCTB:Cell("N3_CUSTBEM"):SetValue(  (cAliasTmp)->CCUSTO )	//(cAliasTmp)->CCUSTO
		oSecCTB:Cell("N3_SUBCCON"):SetValue(  (cAliasTmp)->SUBCTA )	//(cAliasTmp)->SUBCTA
		oSecCTB:Cell("N3_CLVLCON"):SetValue(  (cAliasTmp)->CLVL )	//(cAliasTmp)->CLVL
		oSecCTB:Cell("N3_DTBAIXA"):SetValue(  (cAliasTmp)->DTBAIXA )//(cAliasTmp)->DTBAIXA
		oSecCTB:Cell("N2_HISTOR"):SetValue( af033Texto((cAliasTmp)->(FILIAL+CBASE+ITEM+TIPO)) )
		oSecCTB:PrintLine()
		oSecCTB:Finish()

		oReport:SkipLine()

	EndIf
	oSecVal:Init()
	oSecVal:Cell("MOEDA"):SetValue(  SuperGetMV( "MV_SIMB" + cMoeda ) )
	oSecVal:Cell("VIDA"):SetValue(  AtfxVUtil(aSN3[3],aSN3[4],aSN3[5],aSN3[7],aSN3[6])  )
	oSecVal:Cell("VALORES"):SetValue(  (cAliasTmp)->ORIGINAL  )
	oSecVal:Cell("VAL_AMPL"):SetValue(  (cAliasTmp)->AMPLIACAO  )
	oSecVal:Cell("VAL_ACUM"):SetValue(  (cAliasTmp)->DEPRECACM )
	oSecVal:Cell("VAL_BAI"):SetValue(  (cAliasTmp)->VLBAIXAS  )
	oSecVal:Cell("VAL_RES"):SetValue( IIF((cAliasTmp)->RESIDUAL > 0 ,(cAliasTmp)->RESIDUAL,0)  )
	oSecVal:Cell("BAIXA"):SetValue( ATFXBaixa( (cAliasTmp)->(FILIAL+CBASE+ITEM+TIPO),mv_par01 )  )
	oSecVal:Cell("N3_CODIND"):SetValue(  aSN3[8]  )		//SEEK NO SN3
	oSecVal:PrintLine()
	oSecVal:Finish()

	Eval(&bRefreshVar)

	cAfr33Filial	:= (cAliasTmp)->FILIAL

	(cAliasTmp)->(DbSkip())

	If nTotCBase == 1
		If (cAliasTmp)->(FILIAL + CBASE ) <> cAfr33Filial + cAfr33Base
			oReport:SkipLine()
			If nOrdEnt == 1

				Do Case
					Case nEntida == 1
						cEntidade := "cAfr33Conta"
					Case nEntida == 2
						cEntidade := "cAfr33Custo"
					Case nEntida == 3
						cEntidade := "cAfr33ItCtb"
					Case nEntida == 4
						cEntidade := "cAfr33Clvl"
				End Case

				oSecTit:Cell("TITULO1"):SetValue( STR0020  +  alltrim(cAfr33Base) + STR0021 + &(cEntidade) )//"Total por Codigo Base: "##" ref. Ent. Contab.: "
			Else
				oSecTit:Cell("TITULO1"):SetValue(  STR0022  + alltrim(cAfr33Base) )//"Total por Codigo Base: "
			Endif

			oSecTit:PrintLine()
			oReport:ThinLine()

			//Imprime os Totais por codigo base
			Afr033PrtTotal(aSumBase,oSecSumBas,oSecTit)

			oReport:ThinLine()
			oReport:SkipLine()

			//Zera os Totais por codigo base
			aSumBase    := Afr033Totais(aSelMoed)
		Endif
	Endif

	If nOrdEnt == 1 //Se ordenar por entidade contabil
		Do Case
			Case nEntida == 1 //Entidade Conta Contabil
				If (cAliasTmp)->(FILIAL + CONTA) <> cAfr33Filial + cAfr33Conta

					oSecTit:Cell("TITULO1"):SetValue(  STR0023 + alltrim(cAfr33Conta) ) //"Total por Conta Contabil: "
					oSecTit:PrintLine()
					oReport:ThinLine()

					//Imprime os totais por conta contabil
					Afr033PrtTotal(aSumEnt,oSecSumEnt,oSecTit)

					oReport:ThinLine()
					oReport:SkipLine()

					//Zerar os totais por conta contabil
					aSumEnt		:= Afr033Totais(aSelMoed)
				Endif
			Case nEntida == 2  //Entidade Centro de Custo
				If (cAliasTmp)->(FILIAL + CCUSTO) <> cAfr33Filial + cAfr33Custo

					oSecTit:Cell("TITULO1"):SetValue( STR0024  + alltrim(cAfr33Custo) ) //"Total por Centro de Custo: "
					oSecTit:PrintLine()
					oReport:ThinLine()

					//Imprime os totais por centro de custo
					Afr033PrtTotal(aSumEnt,oSecSumEnt,oSecTit)

					oReport:ThinLine()
					oReport:SkipLine()

					//Zerar os totais por centro de custo
					aSumEnt		:= Afr033Totais(aSelMoed)
				Endif
			Case nEntida == 3 //Entidade Item da Conta
				If (cAliasTmp)->(FILIAL + SUBCTA)  <> cAfr33Filial + cAfr33ItCtb

					oSecTit:Cell("TITULO1"):SetValue(  STR0025+ alltrim(cAfr33ItCtb) ) //"Total por Item Contabil: "
					oSecTit:PrintLine()
					oReport:ThinLine()

					//Imprime os totais por item da conta contabil
					Afr033PrtTotal(aSumEnt,oSecSumEnt,oSecTit)

					oReport:ThinLine()
					oReport:SkipLine()

					//Zerar os totais por item da conta contabil
					aSumEnt		:= Afr033Totais(aSelMoed)
				EndIf
			Case nEntida == 4 //Entidade Classe de Valor
				If (cAliasTmp)->(FILIAL + CLVL) <> cAfr33Filial + cAfr33ClVl

					oSecTit:Cell("TITULO1"):SetValue(  STR0026 + alltrim(cAfr33Clvl) ) //"Total por Classe de Valor: "
					oSecTit:PrintLine()
					oReport:ThinLine()

					//Imprime os totais por classe de valor
					Afr033PrtTotal(aSumEnt,oSecSumEnt,oSecTit)

					oReport:ThinLine()
					oReport:SkipLine()

					//Zerar os totais por classe de valor
					aSumEnt		:= Afr033Totais(aSelMoed)
				EndIf
		End Case
	Endif

	If cAfr33Filial	<> (cAliasTmp)->FILIAL

		oSecTit:Cell("TITULO1"):SetValue(  STR0027 + alltrim(cAfr33Filial) + "-" + GetAdvFval("SM0","M0_FILIAL",cEmpAnt+cAfr33Filial,1,"") ) //"Total por Filial: "
		oSecTit:PrintLine()
		oReport:ThinLine()

		//Imprime os totais por Filial
		Afr033PrtTotal(aSumFil,oSecSumFil,oSecTit)

		oReport:ThinLine()
		oReport:SkipLine()

		//Zera Totais por Filial
		aSumFil		:= Afr033Totais(aSelMoed)
	Endif

	oReport:IncMeter()

EndDo

If lRet
	oSecTit:Cell("TITULO1"):SetValue(  STR0028  ) //"Total Geral: "
	oSecTit:PrintLine()
	oReport:ThinLine()

	//Imprime os total Geral
	Afr033PrtTotal(aSumAll,oSecSumAll,oSecTit)

	oReport:ThinLine()
	oReport:SkipLine()

	oSecTit:Finish()
	oSecSumBas:Finish()
	oSecSumEnt:Finish()
	oSecSumFil:Finish()
	oSecSumAll:Finish()
EndIf

If Select(cAliasTmp) > 0
	dbSelectArea(cAliasTmp)
	cArqAux := (cAliasTmp)->(dbInfo(DBI_FULLPATH))
	cArqAux := AllTrim(Substr(cArqAux,RAT("\",cArqAux)+1))
	DbCloseArea()
	MsErase(cArqAux)
EndIf

Return()

/*���������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Programa  �af033Texto     �Autor  �Fernando Radu Muscalu� Data �  10/03/2011 ���
�������������������������������������������������������������������������������͹��
���Desc.     �Cria string com o texto do historico do arquivo SN2               ���
�������������������������������������������������������������������������������͹��
���Parametros�cChave	- string com a chave de busca do registro em SN2        ���
�������������������������������������������������������������������������������͹��
���Retorno   �cTexto	- string com o tratamento do historico					���
�������������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                          ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/
Static Function af033Texto(cChave)

Local cTexto := ""

SN2->(Dbsetorder(1))

IF SN2->(dbSeek(cChave))

	While SN2->(!Eof()) .and. SN2->N2_FILIAL + SN2->N2_CBASE + SN2->N2_ITEM + SN2->N2_TIPO == cChave
		cTexto += Iif(!Empty(SN2->N2_HISTOR),Alltrim(SN2->N2_HISTOR),"") + CHR(13) + CHR(10)
   		SN2->(dbSkip())
	EndDo
EndIf

Return(cTexto)

/*���������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Programa  �AFr033RetBlock �Autor  �Fernando Radu Muscalu� Data �  10/03/2011 ���
�������������������������������������������������������������������������������͹��
���Desc.     �Monta a ordenacao, quebras e o bloco que atualiza as variaveis de ���
���          �quebras de acordo com as parametrizacoes do usuario 				���
�������������������������������������������������������������������������������͹��
���Parametros�nLoadOrder	- Numerico com a opcao de ordenacao selecionada pelo���
���          �usuario:                                                          ���
���          �	1 - Ordena por Conta Contabil                                   ���
���          �	2 - Ordena por Centro de Custo                                  ���
���          �	3 - Ordena por Item Contabil	                                ���
���          �	4 - Ordena por Classe de valor	                                ���
���          �nDefault		- Numerico com a Opcao de, se ordena por entidade:  ���
���          �	1 - Sim 														���
���          �	2 - Nao 														���
�������������������������������������������������������������������������������͹��
���Retorno   �cTexto	- string com o tratamento do historico					���
�������������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                          ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/
Static Function AFr033RetBlock(nLoadOrder,nDefault,cAliasTmp)

Local nVarOrder	:= 0

Local cBlock 	:= ""
Local cLSecOne	:= ""
Local cLQuebra	:= ""
Local cChave	:= ""

Local aRet		:= {}

If nDefault == 1
	nVarOrder := nLoadOrder
EndIf

Do Case
	Case nVarOrder == 0 //se nao ordenar por nenhuma entidade
		cChave 	:= "FILIAL+CBASE+ITEM+TIPO+FLAGBAIXA+SEQ+SEQREAV+MOEDA"
		cBlock := "{|| cAfr33Base := "+cAliasTmp+"->CBASE, cAfr33Item := "+cAliasTmp+"->ITEM, cAfr33Tipo := "+cAliasTmp+"->TIPO, cAfr33Baix := "+cAliasTmp+"->FLAGBAIXA , cAfr33Seq := "+cAliasTmp+"->SEQ , cAfr33Reav := "+cAliasTmp+"->SEQREAV  }"
		cLSecOne := cAliasTmp+"->(CBASE+ITEM) <> cAfr33Base+cAfr33Item "
		cLQuebra := cAliasTmp+"->(CBASE+ITEM+TIPO+FLAGBAIXA+SEQ+SEQREAV) <> cAfr33Base+cAfr33Item+cAfr33Tipo+cAfr33Baix+cAfr33Seq+cAfr33Reav "
	Case nVarOrder == 1 //Conta contabil
		cChave 	:= "FILIAL+CONTA+CBASE+ITEM+TIPO+FLAGBAIXA+SEQ+SEQREAV+MOEDA"
		cBlock := "{|| cAfr33Conta := "+cAliasTmp+"->CONTA, cAfr33Base := "+cAliasTmp+"->CBASE, cAfr33Item := "+cAliasTmp+"->ITEM, cAfr33Tipo := "+cAliasTmp+"->TIPO , cAfr33Baix := "+cAliasTmp+"->FLAGBAIXA , cAfr33Seq := "+cAliasTmp+"->SEQ , cAfr33Reav := "+cAliasTmp+"->SEQREAV  }"
		cLSecOne := cAliasTmp+"->(CONTA+CBASE+ITEM) <> cAfr33Conta+cAfr33Base+cAfr33Item "
		cLQuebra := cAliasTmp+"->(CONTA+CBASE+ITEM+TIPO+FLAGBAIXA+SEQ+SEQREAV) <> cAfr33Conta+cAfr33Base+cAfr33Item+cAfr33Tipo+cAfr33Baix+cAfr33Seq+cAfr33Reav "
	Case nVarOrder == 2 //Centro de Custo
		cChave 	:= "FILIAL+CCUSTO+CBASE+ITEM+TIPO+FLAGBAIXA+SEQ+SEQREAV+MOEDA"
		cBlock := "{|| cAfr33Custo := "+cAliasTmp+"->CCUSTO, cAfr33Base := "+cAliasTmp+"->CBASE, cAfr33Item := "+cAliasTmp+"->ITEM, cAfr33Tipo := "+cAliasTmp+"->TIPO , cAfr33Baix := "+cAliasTmp+"->FLAGBAIXA , cAfr33Seq := "+cAliasTmp+"->SEQ , cAfr33Reav := "+cAliasTmp+"->SEQREAV  }"
		cLSecOne := cAliasTmp+"->(CCUSTO+CBASE+ITEM) <> cAfr33Custo+cAfr33Base+cAfr33Item "
		cLQuebra := cAliasTmp+"->(CCUSTO+CBASE+ITEM+TIPO+FLAGBAIXA+SEQ+SEQREAV) <> cAfr33Custo+cAfr33Base+cAfr33Item+cAfr33Tipo+cAfr33Baix+cAfr33Seq+cAfr33Reav "
	Case nVarOrder == 3 //Item contabil
		cChave 	:= "FILIAL+SUBCTA+CBASE+ITEM+TIPO+FLAGBAIXA+SEQ+SEQREAV+MOEDA"
		cBlock := "{|| cAfr33ItCtb := "+cAliasTmp+"->SUBCTA, cAfr33Base := "+cAliasTmp+"->CBASE, cAfr33Item := "+cAliasTmp+"->ITEM, cAfr33Tipo := "+cAliasTmp+"->TIPO , cAfr33Baix := "+cAliasTmp+"->FLAGBAIXA , cAfr33Seq := "+cAliasTmp+"->SEQ , cAfr33Reav := "+cAliasTmp+"->SEQREAV  }"
		cLSecOne := cAliasTmp+"->(SUBCTA+CBASE+ITEM) <> cAfr33ItCtb+cAfr33Base+cAfr33Item "
		cLQuebra := cAliasTmp+"->(SUBCTA+CBASE+ITEM+TIPO+FLAGBAIXA+SEQ+SEQREAV) <> cAfr33ItCtb+cAfr33Base+cAfr33Item+cAfr33Tipo+cAfr33Baix+cAfr33Seq+cAfr33Reav "
	Case nVarOrder == 4 //Classe de valor
		cChave 	:= "FILIAL+CLVL+CBASE+ITEM+TIPO+FLAGBAIXA+SEQ+SEQREAV+MOEDA"
		cBlock := "{|| cAfr33ClVl := "+cAliasTmp+"->CLVL, cAfr33Base := "+cAliasTmp+"->CBASE, cAfr33Item := "+cAliasTmp+"->ITEM, cAfr33Tipo := "+cAliasTmp+"->TIPO , cAfr33Baix := "+cAliasTmp+"->FLAGBAIXA , cAfr33Seq := "+cAliasTmp+"->SEQ , cAfr33Reav := "+cAliasTmp+"->SEQREAV  }"
		cLSecOne := cAliasTmp+"->(CLVL+CBASE+ITEM) <> cAfr33ClVl+cAfr33Base+cAfr33Item "
		cLQuebra := cAliasTmp+"->(CLVL+CBASE+ITEM+TIPO+FLAGBAIXA+SEQ+SEQREAV) <> cAfr33ClVl+cAfr33Base+cAfr33Item+cAfr33Tipo+cAfr33Baix+cAfr33Seq+cAfr33Reav "
End Case

aRet := {cBlock,cLSecOne,cLQuebra,cChave}

Return(aRet)

/*���������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Programa  �Afr033Totais   �Autor  �Fernando Radu Muscalu� Data �  10/03/2011 ���
�������������������������������������������������������������������������������͹��
���Desc.     �Montagem de array que contera os totais do relatorio              ���
���          �aATF33Fil, as filiais que foram selecionadas.                     ���
�������������������������������������������������������������������������������͹��
���Parametros�aMoedas	- array com as moedas selecionadas                      ���
�������������������������������������������������������������������������������͹��
���Retorno   �aTotais	- array com os totais									���
���          �	aTotais[nI,1] - Moeda											���
���          �	aTotais[nI,2] - array com os totais fiscais						���
���          �		aTotais[nI,2,1] - total por	valores gerais					���
���          �		aTotais[nI,2,2] - Total por Valores Depreciados acumulados	���
���          �		aTotais[nI,2,3] - Total por Valores maximo depreciado		���
���          �		aTotais[nI,2,4] - Total por Valores residuais				���
���          �	aTotais[nI,3] - array com os totais gerenciais					���
���          �		aTotais[nI,3,1] - total por	valores gerais					���
���          �		aTotais[nI,3,2] - Total por Valores Depreciados acumulados	���
���          �		aTotais[nI,3,3] - Total por Valores maximo depreciado		���
���          �		aTotais[nI,3,4] - Total por Valores residuais        		���
���          �	aTotais[nI,4] - array com os totais incentivados				���
���          �		aTotais[nI,4,1] - total por	valores gerais					���
���          �		aTotais[nI,4,2] - Total por Valores Depreciados acumulados  ���
���          �		aTotais[nI,4,3] - Total por Valores maximo depreciado       ���
���          �		aTotais[nI,4,4] - Total por Valores residuais			    ���
�������������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                          ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/
Static Function Afr033Totais(aMoedas)

Local aTotais	:= {}

Local nI		:= 0

For nI := 1 to len(aMoedas)
	aAdd(aTotais,{aMoedas[nI],array(5),array(5),array(5)})
	aFill(aTotais[len(aTotais),2],0)
	aFill(aTotais[len(aTotais),3],0)
	aFill(aTotais[len(aTotais),4],0)
Next nI

Return(aTotais)

/*���������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Programa  �AF33TPDEPR   �Autor  �Fernando Radu Muscalu� Data �  10/03/2011 ���
�������������������������������������������������������������������������������͹��
���Desc.     �Retorna o indice do subarray do array de totais para o tipo de    ���
���          �de depreciacao de acordo com o codigo passado pelo parametro      ���
�������������������������������������������������������������������������������͹��
���Parametros�cTpDepr	- string com o tipo de Depreciacao                      ���
�������������������������������������������������������������������������������͹��
���Retorno   �nRet	- Valor de 2 a 4, dos tipos de depreciacao. Estes valores	���
���          �sao os indices dos elementos do array de totais. Ressalta-se		���
���          �que a posicao destes elementos no array de totais contem outro	���
���          �array com os valores	das somas.									���
���          �		2 - Tipo Fiscal												���
���          �		3 - Tipo Gerencial											���
���          �		4 - Tipo Incentivado										���
�������������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                          ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/
Static Function AF33TPDEPR(cTpDepr)

Local nRet	:= 0
Local cTipoFiscal		:= ATFXTpBem(1)
Local cTipoGerenc    := ATFXTpBem(2)
Local cTipoIncent		:= ATFXTpBem(3)

Do Case
	Case cTpDepr $ cTipoFiscal
		nRet := 2
	Case cTpDepr $ cTipoGerenc
		nRet := 3
	Case cTpDepr $ cTipoIncent
		nRet := 4
End Case

Return(nRet)

/*���������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Programa  �Afr033PrtTotal �Autor  �Fernando Radu Muscalu� Data �  10/03/2011 ���
�������������������������������������������������������������������������������͹��
���Desc.     �Impressao dos totais              								���
�������������������������������������������������������������������������������͹��
���Parametros�aTotais	- array com os totais									���
���          �	aTotais[nI,1] - Moeda											���
���          �	aTotais[nI,2] - array com os totais fiscais						���
���          �		aTotais[nI,2,1] - total por	valores gerais					���
���          �		aTotais[nI,2,2] - Total por Valores Depreciados acumulados	���
���          �		aTotais[nI,2,3] - Total por Valores maximo depreciado		���
���          �		aTotais[nI,2,4] - Total por Valores residuais				���
���          �	aTotais[nI,3] - array com os totais gerenciais					���
���          �		aTotais[nI,3,1] - total por	valores gerais					���
���          �		aTotais[nI,3,2] - Total por Valores Depreciados acumulados	���
���          �		aTotais[nI,3,3] - Total por Valores maximo depreciado		���
���          �		aTotais[nI,3,4] - Total por Valores residuais        		���
���          �	aTotais[nI,4] - array com os totais incentivados				���
���          �		aTotais[nI,4,1] - total por	valores gerais					���
���          �		aTotais[nI,4,2] - Total por Valores Depreciados acumulados  ���
���          �		aTotais[nI,4,3] - Total por Valores maximo depreciado       ���
���          �		aTotais[nI,4,4] - Total por Valores residuais			    ���
���          �oSection	- objeto da Secao de Totais que sera impressa, ex:      ���
���          �secao dos totais por codigo base								    ���
���          �oTitulo	- Objeto com a secao do Titulo dos totais		        ���
�������������������������������������������������������������������������������͹��
���Retorno   �Nil																���
�������������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                          ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/
Static Function Afr033PrtTotal(aTotais,oSection,oTitulo)

Local nX		:= 0
Local nI		:= 0

Local cMoeda	:= ""

//oSection:Init()

For nX := 2 to 4 //Laco para os tres tipos de depreciacao 2 fiscal, 3 - gerencial e 4 - incentivado

	Do Case
		Case nX == 2
			oTitulo:Cell("TITULO1"):SetValue(  STR0029  ) //" ******FISCAL****** "
		Case nX == 3
			oTitulo:Cell("TITULO1"):SetValue(  STR0030  )//" *****GERENCIAL***** "
		Case nX == 4
			oTitulo:Cell("TITULO1"):SetValue(  STR0031  )//" ****INCENTIVADO**** "
	End Case

	oTitulo:PrintLine()

	For nI := 1 to len(aTotais)

		cMoeda := Alltrim(str(val(aTotais[nI,1])))

		If len(aTotais[nI,nX]) > 0
			oSection:Cell("MOEDA"):SetValue( SuperGetMV( "MV_SIMB" + cMoeda)  )
			oSection:Cell("VALORES"):SetValue(  aTotais[nI,nX,1] )
			oSection:Cell("VAL_ACUM"):SetValue(  aTotais[nI,nX,2] )
			oSection:Cell("VAL_BAI"):SetValue(  aTotais[nI,nX,3] )
			oSection:Cell("VAL_RESID"):SetValue(  aTotais[nI,nX,4] )
			oSection:Cell("VAL_AMPL"):SetValue(  aTotais[nI,nX,5] )

			oSection:PrintLine()
		Endif
	Next nI
Next nX

Return()

