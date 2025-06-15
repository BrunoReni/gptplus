#INCLUDE "PROTHEUS.CH"

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFER084
Relatorio de Despesa de Frete por UF e Regi�o

@sample


@author Gustavo H. Baptista
@since 11/04/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFER084()
	Local oReport := Nil

	If TRepInUse() // teste padr�o 
		//-- Interface de impressao
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf
Return

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} CriaTabela
Cria tabelas auxiliares para a gera��o do relat�rio.

@sample


@author Gustavo Baptista
@since 09/04/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Static Function CriaTabela()

	// Criacao da tabela temporaria p/ imprimir o relat
	
	aTTUF:={{"UF","C",TamSX3("GW1_CDDEST" )[1],0},;
			{"DESUF","C",TamSX3("X5_DESCRI" )[1],0}}
	
	cAliasUF := GFECriaTab({aTTUF, {"UF"}})
	
	aTT :={{"UFREG"    ,"C",TamSX3("GW1_CDDEST")[1],0},;
			{"UF"       ,"C",TamSX3("GW1_CDDEST")[1],0},;
			{"REGREL"   ,"C",TamSX3("GU7_REGREL")[1],0},;
			{"DESUF"    ,"C",TamSX3("X5_DESCRI" )[1],0},;
			{"PESO"     ,"N",TamSX3("GW8_PESOR" )[1]+3,TamSX3("GW8_PESOR" )[2]},;
			{"VALOR"    ,"N",TamSX3("GW8_VALOR" )[1]+3,TamSX3("GW8_VALOR" )[2]},;
			{"VOLUME"   ,"N",TamSX3("GWM_VLFRET")[1]+3,TamSX3("GWM_VLFRET")[2]},;
			{"QTDE"     ,"N",TamSX3("GW8_QTDE"  )[1]+3,TamSX3("GW8_QTDE"  )[2]},;
			{"DESPFRETE","N",TamSX3("GWM_VLFRET")[1]+3,TamSX3("GWM_VLFRET")[2]},;
			{"FRPESO"   ,"N",TamSX3("GWM_VLFRET")[1]+3,TamSX3("GWM_VLFRET")[2]},;
			{"FRVAL"    ,"N",TamSX3("GWM_VLFRET")[1]+3,TamSX3("GWM_VLFRET")[2]},;
			{"FRVOL"    ,"N",TamSX3("GWM_VLFRET")[1]+3,TamSX3("GWM_VLFRET")[2]},;
			{"FRQTD"    ,"N",TamSX3("GWM_VLFRET")[1]+3,TamSX3("GWM_VLFRET")[2]},;
			{"QTDDC"    ,"N",7,0}}

	cAliasRel := GFECriaTab({aTT, {"UF","UFREG"}})

	aTotalTable := {{"UF"     ,"C",TamSX3("GW1_CDDEST")[1],0},;
					{"TPESO"  ,"N",TamSX3("GWM_VLFRET")[1]+3,TamSX3("GWM_VLFRET")[2]},;
					{"TVAL"   ,"N",TamSX3("GWM_VLFRET")[1]+3,TamSX3("GWM_VLFRET")[2]},;
					{"TVOL"   ,"N",TamSX3("GWM_VLFRET")[1]+3,TamSX3("GWM_VLFRET")[2]},;
					{"TQTD"   ,"N",TamSX3("GWM_VLFRET")[1]+3,TamSX3("GWM_VLFRET")[2]},;
					{"TFRETE" ,"N",TamSX3("GWM_VLFRET")[1]+3,TamSX3("GWM_VLFRET")[2]},;
					{"TFRPESO","N",TamSX3("GWM_VLFRET")[1]+3,TamSX3("GWM_VLFRET")[2]},;
					{"TFRVAL" ,"N",TamSX3("GWM_VLFRET")[1]+3,TamSX3("GWM_VLFRET")[2]},;
					{"TFRVOL" ,"N",TamSX3("GWM_VLFRET")[1]+3,TamSX3("GWM_VLFRET")[2]},;
					{"TFRQTD" ,"N",TamSX3("GWM_VLFRET")[1]+3,TamSX3("GWM_VLFRET")[2]},;
					{"TQTDDC" ,"N",7,0}}

	cAliasTot := GFECriaTab({aTotalTable, {"UF"}})
Return

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} ReportDef
Monta a estrutura do relat�rio

@sample


@author Gustavo Baptista
@since 09/04/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function ReportDef()
	Local oReport   := TReport():New("GFER084","Despesa de Frete por UF e Regi�o","GFER084", {|oReport| ReportPrint(oReport)},"Despesa de Frete por UF e Regi�o")
	Local aOrdem    := {}
	Local cTotparc  :="Total Parcial: "
	Local cTotfin   :="Total Final: "
	Local nTamVlFrt := TamSX3("GWM_VLFRET")[1]+3
	
	oReport:SetLandscape()   // define se o relatorio saira deitado
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
	oReport:SetTotalInLine(.F.)
	//oReport:nFontBody   := 10 // Define o tamanho da fonte.
	//oReport:nLineHeight := 50 // Define a altura da linha.
	oReport:NDEVICE := 4

	Pergunte("GFER084",.F.)

	Aadd( aOrdem, "Despesa de Frete por UF e Regi�o" )

	oSection1 := TRSection():New(oReport,"Despesa de Frete por UF e Regi�o",{"(cAliasUF)"},aOrdem) 
	oSection1:SetTotalInLine(.F.)
	oSection1:SetHeaderSection(.T.)

	TRCell():New(oSection1,"(cAliasUF)->UF"   ,"(cAliasUF)","UF" ,"@!",TamSX3("GW1_CDDEST" )[1])
	TRCell():New(oSection1,"(cAliasUF)->DESUF","(cAliasUF)",""   ,"@!",30                      ) //TamSX3("GW1_NMDEST" )[1]

	oSection2 := TRSection():New(oSection1,"Despesa de Frete por UF e Regi�o",{"(cAliasRel)"},aOrdem) //  //"Total Parcial"
	oSection2 :SetTotalInLine(.F.)
	oSection2:SetHeaderSection(.T.)
	TRCell():New(oSection2,"(cAliasRel)->REGREL"   ,"(cAliasRel)","Regi�o"        ,"@!", TamSX3("GU7_REGREL" )[1],/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection2,"(cAliasRel)->QTDDC"    ,"(cAliasRel)","Qt. Doc"       ,"@E 9999999", 7)
	TRCell():New(oSection2,"(cAliasRel)->PESO"     ,"(cAliasRel)","Peso Total"    ,"@E 99,999,999,999.99",TamSX3("GW8_PESOR" )[1]+3,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection2,"(cAliasRel)->VALOR"    ,"(cAliasRel)","Valor Total"   ,"@E 99,999,999,999.99",TamSX3("GW8_VALOR" )[1]+3,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection2,"(cAliasRel)->VOLUME"   ,"(cAliasRel)","Volume Total"  ,"@E 99,999,999,999.99",TamSX3("GWM_VLFRET")[1]+3,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection2,"(cAliasRel)->QTDE"     ,"(cAliasRel)","Quant Total"   ,"@E 99,999,999,999.99",TamSX3("GW8_QTDE"  )[1]+3,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection2,"(cAliasRel)->DESPFRETE","(cAliasRel)","Despesa Frete" ,"@E 99,999,999,999.99",nTamVlFrt                ,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection2,"(cAliasRel)->FRPESO"   ,"(cAliasRel)","$Frete x Peso" ,"@E 99,999,999,999.99",nTamVlFrt                ,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection2,"(cAliasRel)->FRVAL"    ,"(cAliasRel)","%Frete x Valor","@E 99,999,999,999.99",nTamVlFrt                ,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection2,"(cAliasRel)->FRVOL"    ,"(cAliasRel)","$Frete x Volm" ,"@E 99,999,999,999.99",nTamVlFrt                ,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection2,"(cAliasRel)->FRQTD"    ,"(cAliasRel)","$Frete x Qtde" ,"@E 99,999,999,999.99",nTamVlFrt                ,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")

	oSection3 := TRSection():New(oSection1,"Total Parcial",{"cAliasTot"},aOrdem) //  //"Total Parcial"
	oSection3 :SetTotalInLine(.F.)
	oSection3:SetHeaderSection(.F.)
	TRCell():New(oSection3,"cTotparc","","Total Parcial ","@!",20,/*lPixel*/,{||cTotparc},/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection3,"(cAliasTot)->TQTDDC" ,"(cAliasTot)","","@E 9999999",7,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection3,"(cAliasTot)->TPESO"  ,"(cAliasTot)","","@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection3,"(cAliasTot)->TVAL"   ,"(cAliasTot)","","@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection3,"(cAliasTot)->TVOL"   ,"(cAliasTot)","","@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection3,"(cAliasTot)->TQTD"   ,"(cAliasTot)","","@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection3,"(cAliasTot)->TFRETE" ,"(cAliasTot)","","@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection3,"(cAliasTot)->TFRPESO","(cAliasTot)","","@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection3,"(cAliasTot)->TFRVAL" ,"(cAliasTot)","","@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection3,"(cAliasTot)->TFRVOL" ,"(cAliasTot)","","@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection3,"(cAliasTot)->TFRQTD" ,"(cAliasTot)","","@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,"RIGHT")

	oSection4 := TRSection():New(oSection1,"Total Final",{"cAliasTot"},aOrdem) //  //"Total Final"
	oSection4:SetTotalInLine(.F.)
	oSection4:SetHeaderSection(.F.)
	TRCell():New(oSection4,"cTotfin"    ,"","Total Parcial ","@!",20,/*lPixel*/,{||cTotfin},/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection4,"aTotais[10]","","Qt. Doc"       ,"@E 9999999",7,/*lPixel*/,{||aTotais[10]},/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection4,"aTotais[1]" ,"","Peso Total"    ,"@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,{||aTotais[1]},/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection4,"aTotais[2]" ,"","Valor Total"   ,"@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,{||aTotais[2]},/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection4,"aTotais[3]" ,"","Volume Total"  ,"@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,{||aTotais[3]},/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection4,"aTotais[4]" ,"","Quant Total"   ,"@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,{||aTotais[4]},/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection4,"aTotais[5]" ,"","Despesa Frete" ,"@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,{||aTotais[5]},/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection4,"aTotais[6]" ,"","$Frete x Peso" ,"@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,{||aTotais[6]},/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection4,"aTotais[7]" ,"","%Frete x Valor","@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,{||aTotais[7]},/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection4,"aTotais[8]" ,"","$Frete x Volm" ,"@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,{||aTotais[8]},/*cAlign*/,/*lLineBreak*/,"RIGHT")
	TRCell():New(oSection4,"aTotais[9]" ,"","$Frete x Qtde" ,"@E 99,999,999,999.99",nTamVlFrt,/*lPixel*/,{||aTotais[9]},/*cAlign*/,/*lLineBreak*/,"RIGHT")
	
Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection1	     := oReport:Section(1)
	Local oSection2      := oReport:Section(1):Section(1)
	Local oSection3      := oReport:Section(1):Section(2)
	Local oSection4      := oReport:Section(1):Section(3)
	Local aArea          := GetArea()
	
	Private cDados       := ""
	Private cFilialIni   := ""
	Private cFilialFim   := ""
	Private dDataIni     := Nil
	Private dDataFim     := Nil
	Private cListaUF     := ""
	Private cClassFrtIni := ""
	Private cClassFrtFin := ""
	Private cImpRecup    := ""
	Private cImpAuton    := ""
	Private cDctSemDesp  := ""
	Private cTipDesp     := ""
	Private aTotais[10]
	Private cSeek        := ""
	Private cCritRat     := ""
	Private nVlFret      := 0
	Private nVlIss       := 0
	Private nVlIrrf      := 0
	Private nVlInau      := 0
	Private nVlInem      := 0
	Private nVlSest      := 0
	Private nVlIcms      := 0
	Private nVlCofi      := 0
	Private nVlPis       := 0
	Private cAliasRel    := 0
	Private cAliasTot    := 0
	Private cAliasUF     := 0
	
	oReport:SetMeter(0)

	aTotais[1] := 0
	aTotais[2] := 0
	aTotais[3] := 0
	aTotais[4] := 0	
	aTotais[5] := 0
	aTotais[6] := 0
	aTotais[7] := 0
	aTotais[8] := 0
	aTotais[9] := 0
	aTotais[10] := 0

	CriaTabela()

	CarregaDados(oReport)

	dbSelectArea((cAliasUF))
	(cAliasUF)->( dbGoTop() )
	oReport:SetMeter((cAliasRel)->( LastRec() ))	
	Do While (cAliasUF)->(!Eof()) // Para cada Estado
		oSection1:Init()
		oSection1:PrintLine()
		oSection1:Finish()
		oSection2:Init()
		dbSelectArea((cAliasRel))
		dbSetOrder(1)
		If dbSeek((cAliasUF)->UF)
			Do While (cAliasRel)->(!Eof()) .And. (cAliasRel)->UF == (cAliasUF)->UF // Imprimir todas as Regioes
				oSection2:PrintLine()
				
				(cAliasRel)->(dbSkip())
			EndDo
		EndIf
		oSection2:Finish()
		
		oSection3:Init()
		dbSelectArea((cAliasTot))
		dbSetOrder(1)
		If dbSeek((cAliasUF)->UF)
			Do While (cAliasTot)->(!Eof()) .And. (cAliasTot)->UF == (cAliasUF)->UF // Por Fim imprime o total do estado (total parcial)
				oSection3:PrintLine()
	
				//Faz a soma para gerar os totais finais
				aTotais[1] += (cAliasTot)->TPESO
				aTotais[2] += (cAliasTot)->TVAL
				aTotais[3] += (cAliasTot)->TVOL
				aTotais[4] += (cAliasTot)->TQTD	
				aTotais[5] += (cAliasTot)->TFRETE
				aTotais[6] += (cAliasTot)->TFRPESO
				aTotais[7] += (cAliasTot)->TFRVAL
				aTotais[8] += (cAliasTot)->TFRVOL
				aTotais[9] += (cAliasTot)->TFRQTD
				aTotais[10] +=(cAliasTot)->TQTDDC
	
				(cAliasTot)->(dbSkip())
	
			EndDo
		EndIF
		oSection3:Finish()

		(cAliasUF)->(dbSkip())
	EndDo

	oSection4:Init()
	oSection4:PrintLine()
	oSection4:Finish()

	GFEDelTab(cAliasTot)
	GFEDelTab(cAliasRel)
	GFEDelTab(cAliasUF)
	RestArea( aArea )

Return


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} CarregaDados
Realiza a busca dos dados da sele��o e cria a tabela tempor�ria de impress�o
Generico.

@sample
CarregaDados()

@author Gustavo Baptista
@since 11/04/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function CarregaDados(oReport)
	Local  cAliasGW1
	Local  cAliasGWM
	Local  cAliasGW8
	Local  lFrete :=0
	Local  cNRDCAnt :=""
	Local  cRegiao := ""

	cFilialIni 	:= MV_PAR01
	cFilialFim 	:= MV_PAR02
	dDataIni   	:= MV_PAR03
	dDataFim   	:= MV_PAR04
	cListaUF   	:= MV_PAR05
	cClassFrtIni	:= MV_PAR06
	cClassFrtFim	:= MV_PAR07
	cImpRecup  	:= MV_PAR08
	cImpAuton  	:= MV_PAR09
	cDctSemDesp 	:= MV_PAR10
	cTipDesp   	:= MV_PAR11	
	cCritRat		:= MV_PAR12

	// Faz a busca dos dados dos movimentos, movimentos cont�beis e c�lculo de frete
	cAliasGW1 := GetNextAlias()
	
	cQuery := "SELECT"
	cQuery += 		" GW1.GW1_FILIAL,"
	cQuery += 		" GW1.GW1_CDTPDC,"
	cQuery += 		" GW1.GW1_EMISDC,"
	cQuery += 		" GW1.GW1_SERDC," 
	cQuery += 		" GW1.GW1_NRDC,"
	cQuery += 		" GW1.GW1_CDDEST,"
	cQuery += 		" GU7.GU7_CDUF AS CDUF,"
	cQuery += 		" GU7.GU7_REGREL AS REGREL"
	
	cQuery += " FROM " + RetSQLName("GW1") + " GW1" 
	
	cQuery += " JOIN " + RetSQLName("GU3") + " GU3"
	cQuery += " ON '"+ xFilial("GU3") +"' = GU3.GU3_FILIAL AND"
	cQuery += " GW1.GW1_CDDEST = GU3.GU3_CDEMIT"
		
	cQuery += " LEFT JOIN " + RetSQLName("GU7") + " GU7"
	cQuery += " ON GU3.GU3_FILIAL = GU7.GU7_FILIAL AND"
	cQuery += " GU3.GU3_NRCID = GU7.GU7_NRCID"	
	
	cQuery += " WHERE"
	cQuery += 		" GW1.GW1_FILIAL >= '" + cFilialIni     + "' AND GW1.GW1_FILIAL <= '" + cFilialFim     + "' AND"
	cQuery += 		" GW1.GW1_DTEMIS >= '" + DTOS(dDataIni) + "' AND GW1.GW1_DTEMIS <= '" + DTOS(dDataFim) + "' AND"
	cQuery += 		" GW1.D_E_L_E_T_ = ' ' AND"
	cQuery += 		" GU7.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW1, .F., .T.)

	dbSelectArea((cAliasGW1))
	(cAliasGW1)->( dbGoTop() )

	While !oReport:Cancel() .AND. !(cAliasGW1)->( Eof() )
			
		cAliasGWM := GetNextAlias()
		
		oReport:IncMeter()
		cQuery := "SELECT * FROM " + RetSQLName("GWM") + " GWM WHERE"
		cQuery += " GWM.GWM_FILIAL = '"+(cAliasGW1)->GW1_FILIAL+"' AND "
		cQuery += " GWM.GWM_CDTPDC = '"+(cAliasGW1)->GW1_CDTPDC+"' AND "
		cQuery += " GWM.GWM_EMISDC = '"+(cAliasGW1)->GW1_EMISDC+"' AND "
		cQuery += " GWM.GWM_SERDC  = '"+(cAliasGW1)->GW1_SERDC+"' AND "
		cQuery += " GWM.GWM_NRDC   = '"+(cAliasGW1)->GW1_NRDC+"' AND "

		//cTipDesp     ->Tipo de Despesa
		if cTipDesp == 1
			//considerar os registros de Rateios de Frete de C�lculo de Frete (GWM_TPDOC = 1)
			cQuery += " GWM.GWM_TPDOC = '1' AND"
			cQuery += " GWM.D_E_L_E_T_ = ' '"		
			cQuery := ChangeQuery(cQuery)	
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGWM, .F., .T.)

			dbSelectArea((cAliasGWM))
			(cAliasGWM)->( dbGoTop() )

		elseif cTipDesp == 2
			//considerar os registros de Rateios de Frete de Documento de Frete ou Contrato com Aut�nomo (GWM_TPDOC = 2 ou 3)
			cQuery += " (GWM.GWM_TPDOC = '2' OR GWM.GWM_TPDOC = '3') AND "
			cQuery += " GWM.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGWM, .F., .T.)

			dbSelectArea((cAliasGWM))
			(cAliasGWM)->( dbGoTop())	

		else
			//verificar primeiramente se o Documento de Carga possui Rateios de Frete de Documento de Frete 
			//ou Contrato com Aut�nomo (GWM_TPDOC = 2 ou 3) usando-o em caso positivo
			// e em caso negativo usando usar os Rateios de Frete de C�lculo de Frete (GWM_TPDOC = 1). 
			
		
			cQuery += " (GWM.GWM_TPDOC = '2' OR GWM.GWM_TPDOC = '3') AND "
			cQuery += " GWM.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGWM, .F., .T.)

						
			dbSelectArea((cAliasGWM))
			(cAliasGWM)->( dbGoTop() )

			if (cAliasGWM)->( Eof() )


				dbSelectArea((cAliasGWM))
				dbCloseArea()
				cAliasGWM := GetNextAlias()				
				
				cQuery := "SELECT * FROM " + RetSQLName("GWM") + " GWM WHERE"
				cQuery += " GWM.GWM_FILIAL = '"+(cAliasGW1)->GW1_FILIAL+"' AND "
				cQuery += " GWM.GWM_CDTPDC = '"+(cAliasGW1)->GW1_CDTPDC+"' AND "
				cQuery += " GWM.GWM_EMISDC = '"+(cAliasGW1)->GW1_EMISDC+"' AND "
				cQuery += " GWM.GWM_SERDC  = '"+(cAliasGW1)->GW1_SERDC+"' AND "
				cQuery += " GWM.GWM_NRDC   = '"+(cAliasGW1)->GW1_NRDC+"' AND "
				cQuery += " GWM.GWM_TPDOC = '1' AND"
				cQuery += " GWM.D_E_L_E_T_ = ' '"		
				cQuery := ChangeQuery(cQuery)	
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGWM, .F., .T.)

				dbSelectArea((cAliasGWM))
				(cAliasGWM)->( dbGoTop() )		

			EndIf

		Endif

		//Se Documentos despesa = 2- Desconsiderar E documento de carga n�o tiver rateio (GWM), ent�o n�o deve processar		
		If (cAliasGWM)->( Eof() ) .AND. cDctSemDesp = 2
			(cAliasGW1)->(dbSkip())
			
			dbSelectArea((cAliasGWM))
			dbCloseArea()

			Loop		
		
		EndIf

		//Se o UF n�o estiver na lista, ent�o n�o deve processar
		IF Len(AllTrim(cListaUF))>0
			IF RAT((cAliasGW1)->CDUF, cListaUF) <= 0 
				(cAliasGW1)->(dbSkip())
				dbSelectArea((cAliasGWM))
				dbCloseArea()
				
				Loop
			EndIf
		EndIf
		//
		cAliasGW8 := GetNextAlias()	
		
		cQuery := "SELECT * FROM " + RetSQLName("GW8") + " GW8 WHERE"
		cQuery += " GW8.GW8_FILIAL = '"+(cAliasGW1)->GW1_FILIAL+"' AND "
		cQuery += " GW8.GW8_CDTPDC = '"+(cAliasGW1)->GW1_CDTPDC+"' AND "
		cQuery += " GW8.GW8_EMISDC = '"+(cAliasGW1)->GW1_EMISDC+"' AND "
		cQuery += " GW8.GW8_SERDC  = '"+(cAliasGW1)->GW1_SERDC+"' AND "
		cQuery += " GW8.GW8_NRDC   = '"+(cAliasGW1)->GW1_NRDC+"' AND "
		cQuery += " GW8.GW8_CDCLFR >= '"+cClassFrtIni +"' AND "
		cQuery += " GW8.GW8_CDCLFR <= '"+cClassFrtFim +"' AND "
		cQuery += " GW8.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW8, .F., .T.)

		dbSelectArea((cAliasGW8))
		(cAliasGW8)->( dbGoTop() )

		//Alimentar a parte de Informa��es da Carga (GW8)		
		While !(cAliasGW8)->( Eof() ) .AND. ;
			   (cAliasGW8)->GW8_FILIAL == (cAliasGW1)->GW1_FILIAL .AND.	;
			   (cAliasGW8)->GW8_CDTPDC == (cAliasGW1)->GW1_CDTPDC .AND.	;
			   (cAliasGW8)->GW8_EMISDC == (cAliasGW1)->GW1_EMISDC .AND.	;
			   (cAliasGW8)->GW8_SERDC  == (cAliasGW1)->GW1_SERDC  .AND.	;
			   (cAliasGW8)->GW8_NRDC   == (cAliasGW1)->GW1_NRDC

			//Cria um novo registro de estado
			dbSelectArea((cAliasUF))
			dbSetOrder(1)
			If !dbSeek((cAliasGW1)->CDUF)
				// Cria um novo registro com o novo item
				RecLock((cAliasUF), .T.)
				(cAliasUF)->UF   	:= (cAliasGW1)->CDUF
				
				dbSelectArea("SX5")
				dbSetOrder(1)
				dbSeek(xFilial("GU7")+"12"+(cAliasGW1)->CDUF)

				(cAliasUF)->DESUF 	:= X5Descri()

				MsUnlock()
			EndIf

			// Cria um novo registro com o novo estado e regiao
			dbSelectArea((cAliasRel))
			dbSetOrder(2)
			
			if Len(Alltrim((cAliasGW1)->REGREL)) > 0 
				cRegiao := Alltrim((cAliasGW1)->REGREL)
			else
				cRegiao := "Sem Regi�o"
			endif
			
			cSeek:= AllTrim((cAliasGW1)->CDUF)+AllTrim(cRegiao)
			If dbSeek(cSeek,.T.)
			    // Altera o registro corrente
			    RecLock((cAliasRel), .F.)
			Else
				// Cria um novo registro com o novo item
				RecLock((cAliasRel), .T.)
				(cAliasRel)->UF   	:= (cAliasGW1)->CDUF
				(cAliasRel)->UFREG  := AllTrim((cAliasGW1)->CDUF)+Alltrim(cRegiao)

				dbSelectArea("SX5")
				dbSetOrder(1)
				dbSeek(xFilial("GU7")+"12"+(cAliasGW1)->CDUF)
				
				(cAliasRel)->DESUF 	:= X5Descri()
				(cAliasRel)->REGREL  := cRegiao
			EndIf

			(cAliasRel)->PESO   += (cAliasGW8)->GW8_PESOR
			(cAliasRel)->VALOR  += (cAliasGW8)->GW8_VALOR
			(cAliasRel)->VOLUME += (cAliasGW8)->GW8_VOLUME
			(cAliasRel)->QTDE	+= (cAliasGW8)->GW8_QTDE

			If (cAliasGW1)->GW1_FILIAL+(cAliasGW1)->GW1_CDTPDC+(cAliasGW1)->GW1_EMISDC+(cAliasGW1)->GW1_SERDC+(cAliasGW1)->GW1_NRDC <> cNRDCAnt
				(cAliasRel)->QTDDC++
				cNRDCAnt := (cAliasGW1)->GW1_FILIAL+(cAliasGW1)->GW1_CDTPDC+(cAliasGW1)->GW1_EMISDC+(cAliasGW1)->GW1_SERDC+(cAliasGW1)->GW1_NRDC
			EndIf

			MsUnlock()
			(cAliasGW8)->(dbSkip())
		EndDo
		
		While !(cAliasGWM)->( Eof() ) .AND. ;
			   (cAliasGWM)->GWM_FILIAL == (cAliasGW1)->GW1_FILIAL .AND.	;
			   (cAliasGWM)->GWM_CDTPDC == (cAliasGW1)->GW1_CDTPDC .AND.	;
			   (cAliasGWM)->GWM_EMISDC == (cAliasGW1)->GW1_EMISDC .AND.	;
			   (cAliasGWM)->GWM_SERDC  == (cAliasGW1)->GW1_SERDC  .AND.	;
			   (cAliasGWM)->GWM_NRDC   == (cAliasGW1)->GW1_NRDC

			CarregaImpostos(cAliasGWM)
			
			//Cria um novo registro de estado
			dbSelectArea((cAliasUF))
			dbSetOrder(1)	
			If !dbSeek((cAliasGW1)->CDUF)
				// Cria um novo registro com o novo item
				RecLock((cAliasUF), .T.)
				(cAliasUF)->UF   	:= (cAliasGW1)->CDUF
				
				dbSelectArea("SX5")
				dbSetOrder(1)
				dbSeek(xFilial("GU7")+"12"+(cAliasGW1)->CDUF)
				
				(cAliasUF)->DESUF 	:= X5Descri()
				
				MsUnlock()
			EndIf			

			// Cria um novo registro com o novo item
			dbSelectArea((cAliasRel))
			dbSetOrder(2)
			
			if Len(Alltrim((cAliasGW1)->REGREL)) > 0 
				cRegiao := Alltrim((cAliasGW1)->REGREL)
			else
				cRegiao := "Sem Regi�o"
			endif
			
			cSeek:= AllTrim((cAliasGW1)->CDUF)+Alltrim(cRegiao)
			If dbSeek(cSeek,.T.)
			    // Altera o registro corrente
			    RecLock((cAliasRel), .F.)
			Else
				// Cria um novo registro com o novo item
				RecLock((cAliasRel), .T.)
				(cAliasRel)->UF   	:= (cAliasGW1)->CDUF
				(cAliasRel)->UFREG  	:= AllTrim((cAliasGW1)->CDUF)+Alltrim(cRegiao)
				
				dbSelectArea("SX5")
				dbSetOrder(1)
				dbSeek(xFilial("GU7")+"12"+(cAliasGW1)->CDUF)
				
				(cAliasRel)->DESUF 	:= X5Descri()
				(cAliasRel)->REGREL  := cRegiao
			EndIf

			/*if cNRDCAnt == ""
				(cAliasRel)->QTDDC += 1
				cNRDCAnt :=(cAliasGW1)->GW1_NRDC
			else
				if (cAliasGW1)->GW1_NRDC <> cNRDCAnt
					(cAliasRel)->QTDDC += 1
					cNRDCAnt :=(cAliasGW1)->GW1_NRDC
				EndIf
			EndIf*/

			lFrete := nVlFret
			
			//cImpRecup    ->Impostos a recuperar
			if cImpRecup == 1
				//1=Descontar, deve-se subtrair o valor de ICMS (GWM_VLICMS), PIS (GWM_VLPIS) do valor do frete (GWM_VLFRET)
				// 									e COFINS (GWM_VLCOFI) do valor do frete (GWM_VLFRET)
				if AllTrim((cAliasGWM)->GWM_TPDOC) == '1' 

					lFrete := FretePrevisto(lFrete,cAliasGWM)

				elseif AllTrim((cAliasGWM)->GWM_TPDOC) == '2'
				 
					lFrete := FreteRealizado(lFrete,cAliasGWM)
				 
				EndIf
			endif

			//cImpAuton    ->Impostos dos Aut�nomos
			if cImpAuton == 1 .AND. AllTrim((cAliasGWM)->GWM_TPDOC) == '3'

				lFrete +=nVlIss +nVlIrrf +nVlInau +nVlInem +nVlSest

			EndIf			
			(cAliasRel)->DESPFRETE	+= lFrete

			MsUnlock()

			(cAliasGWM)->( dbSkip() )
		EndDo
		
		dbSelectArea((cAliasGWM))
		dbCloseArea()
		
		dbSelectArea((cAliasGW8))
		dbCloseArea()

		(cAliasGW1)->(dbSkip())
	EndDo

	//Atualiza a tabela com os valores que precisam ser calculados. 
	(cAliasRel)->( dbGoTop() )
	While !((cAliasRel)->( Eof() )	)
		RecLock((cAliasRel), .F.)
	    	(cAliasRel)->FRPESO		:= ((cAliasRel)->DESPFRETE / (cAliasRel)->PESO )
			(cAliasRel)->FRVAL		:= ((cAliasRel)->DESPFRETE / (cAliasRel)->VALOR ) * 100
			(cAliasRel)->FRVOL		:= ((cAliasRel)->DESPFRETE / (cAliasRel)->VOLUME )
			(cAliasRel)->FRQTD		:= ((cAliasRel)->DESPFRETE / (cAliasRel)->QTDE )
		MsUnlock()

		dbselectArea(cAliasTot)
		dbSetOrder(1)
		if dbSeek((cAliasRel)->UF)
			RecLock((cAliasTot),.F.)
		else
			RecLock((cAliasTot),.T.)
			(cAliasTot)->UF := (cAliasRel)->UF
		endif

		//Gera totalizadores finais
		(cAliasTot)->TPESO	+= (cAliasRel)->PESO
		(cAliasTot)->TVAL		+= (cAliasRel)->VALOR
		(cAliasTot)->TVOL		+= (cAliasRel)->VOLUME
		(cAliasTot)->TQTD		+= (cAliasRel)->QTDE

		(cAliasTot)->TFRETE	+= (cAliasRel)->DESPFRETE
	   	(cAliasTot)->TFRPESO	+= (cAliasRel)->FRPESO
	   	(cAliasTot)->TFRVAL	+= (cAliasRel)->FRVAL
		(cAliasTot)->TFRVOL	+= (cAliasRel)->FRVOL
		(cAliasTot)->TFRQTD	+= (cAliasRel)->FRQTD
		(cAliasTot)->TQTDDC	+= (cAliasRel)->QTDDC
		MsUnlock()

		(cAliasRel)->( dbSkip() )
	EndDo
	
	dbSelectArea((cAliasGW1))
	dbCloseArea()
	
Return

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} FretePrevisto
Efetua os descontos do frete previsto ( se for poss�vel)

@sample

@author Gustavo H. Baptista
@since 10/04/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Static Function FretePrevisto(lFrete,cAliasGWM)
	// Busca o c�lculo de frete relacionado ao Movimento Cont�bil
	dbSelectArea("GWF")
	dbSetOrder(1)
	If dbSeek((cAliasGWM)->GWM_FILIAL + (cAliasGWM)->GWM_NRDOC)
		// Descontar impostos recuper�veis
		//Retira o ICMS
		If GWF->GWF_CRDICM == "1"
			lFrete -= nVlIcms  
		EndIf

		//Retira o PIS e COFINS
		If GWF->GWF_CRDPC == "1"
			lFrete -= (nVlCofi + nVlPis)
		EndIf
	EndIf
Return lFrete

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} FreteRealizado
Efetua os descontos do frete realizado ( se for poss�vel)

@sample


@author Gustavo H. Baptista
@since 10/04/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function FreteRealizado(lFrete,cAliasGWM)
	// Busca o c�lculo de frete relacionado ao Movimento Cont�bil
	dbSelectArea("GW3")
	dbSetOrder(1)
	If dbSeek((cAliasGWM)->GWM_FILIAL + (cAliasGWM)->GWM_CDESP + (cAliasGWM)->GWM_CDTRP + (cAliasGWM)->GWM_SERDOC + (cAliasGWM)->GWM_NRDOC + (cAliasGWM)->GWM_DTEMIS)             
		// Descontar impostos recuper�veis
		// Retira o ICMS
		If GW3->GW3_CRDICM == "1"
			lFrete -= nVlIcms  
		EndIf
		
		//Retira o PIS e COFINS
		If GW3->GW3_CRDPC == "1"
			lFrete -= (nVlCofi + nVlPis)
		EndIf	    
	EndIf
Return lFrete

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} CarregaImpostos
Carrega os valores de impostos que devem ser considerados no c�lculo do frete

@sample


@author Gustavo H. Baptista
@since 19/04/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function CarregaImpostos(cAliasGWM)

	if cCritRat == 1 //Peso Carga
		nVlFret 	:= (cAliasGWM)->GWM_VLFRET
		nVlIss 	:= (cAliasGWM)->GWM_VLISS 
		nVlIrrf 	:= (cAliasGWM)->GWM_VLIRRF
		nVlInau 	:= (cAliasGWM)->GWM_VLINAU
		nVlInem 	:= (cAliasGWM)->GWM_VLINEM 
		nVlSest 	:= (cAliasGWM)->GWM_VLSEST
		nVlIcms 	:= (cAliasGWM)->GWM_VLICMS 
		nVlCofi 	:= (cAliasGWM)->GWM_VLCOFI
		nVlPis 	:= (cAliasGWM)->GWM_VLPIS
	ElseIf cCritRat == 2 //Valor Carga
		nVlFret 	:= (cAliasGWM)->GWM_VLFRE1
		nVlIss 	:= (cAliasGWM)->GWM_VLISS1 
		nVlIrrf 	:= (cAliasGWM)->GWM_VLIRR1 
		nVlInau 	:= (cAliasGWM)->GWM_VLINA1 
		nVlInem 	:= (cAliasGWM)->GWM_VLINE1 
		nVlSest 	:= (cAliasGWM)->GWM_VLSES1
		nVlIcms 	:= (cAliasGWM)->GWM_VLICM1 
		nVlCofi 	:= (cAliasGWM)->GWM_VLCOF1
		nVlPis 	:= (cAliasGWM)->GWM_VLPIS1
	ElseIf cCritRat == 3 //Quantidade Itens
		nVlFret 	:= (cAliasGWM)->GWM_VLFRE2
		nVlIss 	:= (cAliasGWM)->GWM_VLISS2 
		nVlIrrf 	:= (cAliasGWM)->GWM_VLIRR2 
		nVlInau 	:= (cAliasGWM)->GWM_VLINA2 
		nVlInem 	:= (cAliasGWM)->GWM_VLINE2 
		nVlSest 	:= (cAliasGWM)->GWM_VLSES2
		nVlIcms 	:= (cAliasGWM)->GWM_VLICM2 
		nVlCofi 	:= (cAliasGWM)->GWM_VLCOF2
		nVlPis 	:= (cAliasGWM)->GWM_VLPIS2
	ElseIf cCritRat == 4 //Volume Carga
		nVlFret 	:= (cAliasGWM)->GWM_VLFRE3
		nVlIss 	:= (cAliasGWM)->GWM_VLISS3 
		nVlIrrf 	:= (cAliasGWM)->GWM_VLIRR3 
		nVlInau 	:= (cAliasGWM)->GWM_VLINA3 
		nVlInem 	:= (cAliasGWM)->GWM_VLINE3 
		nVlSest 	:= (cAliasGWM)->GWM_VLSES3
		nVlIcms 	:= (cAliasGWM)->GWM_VLICM3 
		nVlCofi 	:= (cAliasGWM)->GWM_VLCOF3
		nVlPis 	:= (cAliasGWM)->GWM_VLPIS3
	EndIf
Return
