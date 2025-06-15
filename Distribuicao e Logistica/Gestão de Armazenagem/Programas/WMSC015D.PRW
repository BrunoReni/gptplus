#INCLUDE "WMSC015D.CH"  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"
//-----------------------------------------------------------
/*/{Protheus.doc} WMSC015D
Rastreabilidade
@author  Alexsander Burigo Corrêa
@version P11
@Since 16/05/12
/*/ 
//----------------------------------------------------------- 
Function WMSC015D(nNumSeq,cLocal,cProduto,cPrdOri)
Local aCoors   := FWGetDialogSize (oMainWnd )
Local oLayerRas
Local oPnlRas
Local aColsSX3 := {}
Local cPict    := PesqPict('SB2','B2_QATU')
	
Private aFieldRAS:= {}
Private dUltFech := GetUltFech(cLocal,cProduto)
Private dDataIni := dUltFech + 1
Private dDataFim := dDataBase

Private oBrwRas

	// Cria tabela temporária
	CriaTemp()

	// Atualiza dados Kardex
	SetRastro(nNumSeq,cLocal,cProduto,cPrdOri)

	// Trata a altura da janela de acordo com a resolução	
	Define MsDialog oDlgPrinc Title STR0001 From aCoors[1], aCoors [2] To aCoors[3], aCoors[4] Pixel // Rastreabilidade

	// Cria conteiner para os browses
	oLayerRas := FWLayer():New()
	oLayerRas:Init(oDlgPrinc, .F., .T.)

	oLayerRas:AddLine( 'RASTRO', 6, .F.)
	oPnlCapa := oLayerRas:GetLinePanel ('RASTRO')

	TSay():New( 5,5,{|| buscarSX3('B1_COD',,aColsSX3)},oPnlCapa,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Produto
	oProduto  := TGet():New( 3,30,{|| cProduto}, oPnlCapa, 50, 9,"@!",,,,,,,.T.,,,{|| .F.},,,,,,,'cProduto',,,,.T.)

	TSay():New( 5,90,{||buscarSX3('B1_DESC',,aColsSX3)},oPnlCapa,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Saldo
	oDescProd := TGet():New( 3,125,{|| Posicione('SB1',1,xFilial('SB1')+cProduto,'SB1->B1_DESC')}, oPnlCapa, 200, 9,"@!",,,,,,,.T.,,,{|| .F.},,,,,,,'cDescProd',,,,.T.)
	// Define painel Detail
	oLayerRas:AddLine( 'RAS', 94, .F.)
	oPnlRas := oLayerRas:GetLinePanel ('RAS')
	// Monta browse
	aColsRas:= {;
				{ buscarSX3('D2_EMISSAO',,aColsSX3)       ,{|| ('WMSRAS')->KR_DATA}   ,'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D2_DOC',,aColsSX3)           ,{|| ('WMSRAS')->KR_DOCTO}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D2_SERIE',,aColsSX3)         ,{|| ('WMSRAS')->KR_SERIE}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D2_CLIENTE',,aColsSX3)       ,{|| ('WMSRAS')->KR_CLIENTE},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D2_LOJA',,aColsSX3)          ,{|| ('WMSRAS')->KR_LOJA}   ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D2_TES',,aColsSX3)           ,{|| ('WMSRAS')->KR_TES}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D2_CF',,aColsSX3)            ,{|| ('WMSRAS')->KR_CF}     ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D2_LOTECTL',,aColsSX3)       ,{|| ('WMSRAS')->KR_LOTE}   ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D2_NUMLOTE',,aColsSX3)       ,{|| ('WMSRAS')->KR_NUMLOTE},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D2_LOCALIZ',,aColsSX3)       ,{|| ('WMSRAS')->KR_LOCALIZ},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D2_NUMSERI',,aColsSX3)       ,{|| ('WMSRAS')->KR_NUMSERI},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D2_QUANT',,aColsSX3)         ,{|| ('WMSRAS')->KR_QUANT}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D2_QTSEGUM',,aColsSX3)       ,{|| ('WMSRAS')->KR_QTSEGUM},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D2_NUMSEQ',,aColsSX3)        ,{|| ('WMSRAS')->KR_NUMSEQ} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,};
				}

	oBrwRas := FWMBrowse():New()
	oBrwRas:SetAlias('WMSRAS')
	oBrwRas:SetOwner(oPnlRas)
	oBrwRas:SetFields(aColsRas)
	oBrwRas:SetMenuDef('')
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'NF ENTRADA'"   ,'YELLOW',STR0002) // NF. Entrada
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'NF SAIDA'"     ,'BLUE'  ,STR0003) // NF. Saída
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'ENTRADA'"      ,'ORANGE',STR0004) // Entrada
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'SAIDA'"        ,'BLACK' ,STR0005) // Saída
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'TRANSFERENCIA'",'BROWN' ,STR0006) // Transferência
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'À ENDEREÇAR'"  ,'WHITE' ,STR0007) // À Endereçar
	oBrwRas:SetFixedBrowse(.T.)
	oBrwRas:SetAmbiente(.F.)
	oBrwRas:SetWalkThru(.F.)
	oBrwRas:SetDescription(STR0001)// Rastreabilidade
	oBrwRas:DisableDetails()
	oBrwRas:SetProfileID('1')
	oBrwRas:Activate()

	// Ativa a janela e efetua a carga das consultas e criação dos browsers
	Activate MsDialog oDlgPrinc Center
	
	delTabTmp('WMSRAS')
Return Nil
//-----------------------------------------------------------
/*/{Protheus.doc} GetUltFech
Busca Data Ultimo Fechamento

@author  Alexsander Burigo Corrêa
@version P12
@Since	16/05/12
@version 1.0
@obs Busca Data Ultimo Fechamento
/*/ 
//-----------------------------------------------------------
Static Function GetUltFech(cLocal,cProduto)
Local aAreaSB2    := SB2 -> (GetArea())
Local cAliasSB9  := GetNextAlias()
Local dUltFech
	BeginSql Alias cAliasSB9
		SELECT MAX(SB9.B9_DATA)B9_DATA
		FROM %Table:SB9% SB9
		WHERE SB9.B9_FILIAL = %xFilial:SB9%
		AND SB9.B9_LOCAL = %Exp:cLocal%
		AND SB9.B9_COD = %Exp:cProduto%
		AND SB9.B9_DATA < %Exp:DTOS(dDatabase)%
		AND SB9.%NotDel%
	EndSql
	TcSetField(cAliasSB9,'B9_DATA','D')
	dUltFech := (cAliasSB9)->B9_DATA
	(cAliasSB9)->( DBCloseArea())
	RestArea(aAreaSB2)
Return dUltFech
//-----------------------------------------------------------
/*/{Protheus.doc} CriaTemp
Cria tabelas temporárias

@author  Alexsander Burigo Corrêa
@version P12
@Since	16/05/12
@version 1.0
@obs Cria tabelas temporárias
/*/ 
//-----------------------------------------------------------
Static Function CriaTemp()
	//----------------------------------------
	// Cria tabela temporária Rastreabilidade
	//---------------------------------------- 	
	AAdd(aFieldRAS,{'KR_ORDEM' ,'C',13,0})
	AAdd(aFieldRAS,{'KR_TABELA','C',30,0})
	AAdd(aFieldRAS,{'KR_ORIGEM','C',13,0})
	
	buscarSX3('D2_EMISSAO',,aColsSX3)
	AAdd(aFieldRAS,{'KR_DATA','D',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_DOC',,aColsSX3)
	AAdd(aFieldRAS,{'KR_DOCTO','C',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_SERIE',,aColsSX3)
	AAdd(aFieldRAS,{'KR_SERIE','C',aColsSX3[3],aColsSX3[4]}) 
	
	buscarSX3('D2_CLIENTE',,aColsSX3)
	AAdd(aFieldRAS,{'KR_CLIENTE','C',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_LOJA',,aColsSX3)
	AAdd(aFieldRAS,{'KR_LOJA','C',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_TES',,aColsSX3)
	AAdd(aFieldRAS,{'KR_TES','C',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_CF',,aColsSX3)
	AAdd(aFieldRAS,{'KR_CF','C',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_LOTECTL',,aColsSX3)
	AAdd(aFieldRAS,{'KR_LOTE','C',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_NUMLOTE',,aColsSX3)
	AAdd(aFieldRAS,{'KR_NUMLOTE','C',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_LOCALIZ',,aColsSX3)
	AAdd(aFieldRAS,{'KR_LOCALIZ','C',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_NUMSERI',,aColsSX3)
	AAdd(aFieldRAS,{'KR_NUMSERI','C',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_QUANT',,aColsSX3)
	AAdd(aFieldRAS,{'KR_QUANT','N',aColsSX3[3],aColsSX3[4]}) 
	
	buscarSX3('D2_QTSEGUM',,aColsSX3)
	AAdd(aFieldRAS,{'KR_QTSEGUM','N',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_NUMSEQ',,aColsSX3)
	AAdd(aFieldRAS,{'KR_NUMSEQ','C',aColsSX3[3],aColsSX3[4]})
	
	// Cria tabelas temporárias
	criaTabTmp(aFieldRAS,{'KR_NUMSEQ+KR_ORDEM+KR_TES'},'WMSRAS')
Return .T.
//-----------------------------------------------------------
/*/{Protheus.doc} SetRastro
Rastreabilidade

@author  Alexsander Burigo Corrêa
@version P12
@Since	16/05/12
@version 1.0
@obs astreabilidade
/*/ 
//-----------------------------------------------------------
Static Function SetRastro(nNumSeq,cLocal,cProduto,cPrdOri)
Local aRastrear := {}
Local cAliasQry := GetNextAlias()
Local cLocaliz  := PadR("", TamSx3("D2_LOCALIZ")[1])
Local cNumSer   := PadR("", TamSx3("D2_NUMSERI")[1])
Local cDtValid  := PadR("", TamSx3("D5_DTVALID")[1])
Local cTipo     := PadR("", TamSx3("D1_TIPO")[1])
Local cOriLan   := PadR("", TamSx3("D2_ORIGLAN")[1])
Local cTes      := PadR("", TamSx3("D2_TM")[1])
Local cCf       := PadR("", TamSx3("D2_CF")[1])
Local cSerie    := PadR("", TamSx3("D2_SERIE")[1])
Local cCliFor   := PadR("", TamSx3("D2_CLIENTE")[1])
Local cLoja     := PadR("", TamSx3("D2_LOJA")[1])

	BeginSql Alias cAliasQry
		SELECT 'A' AS TIPO, 
				'NF ENTRADA' AS OPERACAO,
				SD1.D1_DOC AS DOC,
				SD1.D1_SERIE AS SERIE, 
				SD1.D1_FORNECE AS CLIFOR,
				SD1.D1_LOJA AS LOJA,
				SD1.D1_TIPO AS TPDOC,
				SD1.D1_ORIGLAN AS ORIGEM,
				SD1.D1_DTDIGIT AS DATLAN,
				SD1.D1_TES AS TES,
				SD1.D1_CF AS CF,
				SD1.D1_QUANT AS QUANT,
				SD1.D1_QTSEGUM AS QTSEGUM, 
				SD1.D1_NUMSEQ AS NUMSEQ,
				SD1.D1_LOTECTL AS LOTECTL,
				SD1.D1_NUMLOTE AS NUMLOTE,
				%Exp:cLocaliz% AS LOCALIZ,
				%Exp:cNumSer% AS NUMSERI,
				%Exp:cDtValid% AS DTVALID
		FROM %Table:SD1% SD1
		INNER JOIN %Table:SF4% SF4
		ON SF4.F4_FILIAL = %xFilial:SF4%
		AND SF4.F4_CODIGO = SD1.D1_TES
		AND SF4.F4_ESTOQUE = 'S'
		AND SF4.%NotDel%
		WHERE SD1.D1_FILIAL  = %xFilial:SD1%
		AND SD1.D1_LOCAL = %Exp:cLocal%
		AND SD1.D1_COD = %Exp:cProduto%
		AND SD1.D1_NUMSEQ = %Exp:nNumSeq%
		AND SD1.%NotDel%
		UNION ALL
		SELECT 'B' AS TIPO,
				'NF SAIDA' AS OPERACAO,
				SD2.D2_DOC AS DOC,
				SD2.D2_SERIE AS SERIE,
				SD2.D2_CLIENTE AS CLIFOR,
				SD2.D2_LOJA AS LOJA,
				%Exp:cTipo% AS TPDOC,
				SD2.D2_ORIGLAN AS ORIGEM,
				SD2.D2_EMISSAO AS DATLAN,
				SD2.D2_TES AS TES,
				SD2.D2_CF AS CF,
				SD2.D2_QUANT AS QUANT,
				SD2.D2_QTSEGUM AS QTSEGUM,
				SD2.D2_NUMSEQ AS NUMSEQ,
				SD2.D2_LOTECTL AS LOTECTL,
				SD2.D2_NUMLOTE AS NUMLOTE,
				SD2.D2_LOCALIZ AS LOCALIZ,
				SD2.D2_NUMSERI AS NUMSERI,
				%Exp:cDtValid% AS DTVALID
		FROM %Table:SD2% SD2
		INNER JOIN %Table:SF4% SF4
		ON SF4.F4_FILIAL = %xFilial:SF4%
		AND SF4.F4_CODIGO = SD2.D2_TES
		AND SF4.F4_ESTOQUE = 'S'
		AND SF4.%NotDel%
		WHERE SD2.D2_FILIAL  = %xFilial:SD2%
		AND SD2.D2_LOCAL = %Exp:cLocal%
		AND SD2.D2_COD = %Exp:cProduto%
		AND SD2.D2_NUMSEQ = %Exp:nNumSeq%
		AND SD2.%NotDel%
		UNION ALL
		SELECT 'C' AS TIPO,
		CASE WHEN SD3.D3_TM IN ('499','999') THEN 'TRANSFERENCIA'
			WHEN SD3.D3_TM NOT IN ('499','999') AND SD3.D3_TM <= '500' THEN 'ENTRADA'
			WHEN SD3.D3_TM NOT IN ('499','999') AND SD3.D3_TM > '500' THEN 'SAIDA' END OPERACAO,
		SD3.D3_DOC AS DOC,
		%Exp:cSerie% AS SERIE,
		%Exp:cCliFor% AS CLIFOR,
		%Exp:cLoja% AS LOJA,
		%Exp:cTipo% AS TPDOC,
		%Exp:cOriLan% AS ORIGEM,
		SD3.D3_EMISSAO AS DATLAN,
		SD3.D3_TM AS TES,
		SD3.D3_CF AS CF,
		SD3.D3_QUANT AS QUANT,
		SD3.D3_QTSEGUM AS QTSEGUM,
		SD3.D3_NUMSEQ AS NUMSEQ,
		SD3.D3_LOTECTL AS LOTECTL,
		SD3.D3_NUMLOTE AS NUMLOTE,
		SD3.D3_LOCALIZ AS LOCALIZ,
		SD3.D3_NUMSERI AS NUMSERI,
		%Exp:cDtValid% AS DTVALID
		FROM %Table:SD3% SD3
		WHERE SD3.D3_FILIAL  = %xFilial:SD3%
		AND SD3.D3_LOCAL = %Exp:cLocal%
		AND SD3.D3_COD = %Exp:cProduto%
		AND SD3.D3_NUMSEQ  = %Exp:nNumSeq%
		AND SD3.D3_EMISSAO >= %Exp:DTOS(dDataIni)%
		AND SD3.D3_EMISSAO <= %Exp:DTOS(dDataFim)%
		AND SD3.D3_ESTORNO = ' '
		AND SD3.%NotDel%
		UNION ALL	
		SELECT 'D' AS TIPO,"
				CASE WHEN SD5.D5_ORIGLAN IN ('499','999') THEN 'TRANSFERENCIA'
					WHEN SD5.D5_ORIGLAN NOT IN ('499','999') AND SD5.D5_ORIGLAN <= '500' THEN 'ENTRADA'
					WHEN SD5.D5_ORIGLAN NOT IN ('499','999') AND SD5.D5_ORIGLAN > '500' THEN 'SAIDA' END OPERACAO,
				SD5.D5_DOC AS DOC,
				SD5.D5_SERIE AS SERIE,
				SD5.D5_CLIFOR AS CLIFOR,
				SD5.D5_LOJA AS LOJA,
				%Exp:cTipo% AS TPDOC,
				SD5.D5_ORIGLAN AS ORIGEM,
				SD5.D5_DATA AS DATLAN,
				%Exp:cTes% AS TES,
				%Exp:cCf% AS CF,
				SD5.D5_QUANT AS QUANT,
				SD5.D5_QTSEGUM AS QTSEGUM,
				SD5.D5_NUMSEQ AS D5_NUMSEQ,
				SD5.D5_LOTECTL AS LOTECTL,
				SD5.D5_NUMLOTE AS NUMLOTE,
				%Exp:cLocaliz% AS LOCALIZ,
				%Exp:cNumSer% AS NUMSERI,
				SD5.D5_DTVALID AS DTVALID
		FROM %Table:SD5% SD5
		WHERE SD5.D5_FILIAL = %xFilial:SD5%
		AND SD5.D5_LOCAL = %Exp:cLocal%
		AND SD5.D5_PRODUTO = %Exp:cProduto%
		AND SD5.D5_NUMSEQ = %Exp:nNumSeq%
		AND SD5.D5_ESTORNO = ' '
		AND SD5.%NotDel%
		UNION ALL
		SELECT 'E' AS TIPO,
				CASE WHEN D13.D13_TM IN ('499','999') THEN 'TRANSFERENCIA'
					WHEN D13.D13_TM NOT IN ('499','999') AND D13.D13_TM <= '500' THEN 'ENTRADA'
					WHEN D13.D13_TM NOT IN ('499','999') AND D13.D13_TM > '500' THEN 'SAIDA' END OPERACAO,
				D13.D13_DOC AS DOC,
				D13.D13_SERIE AS SERIE,
				D13.D13_CLIFOR AS CLIFOR,
				D13.D13_LOJA AS LOJA,
				%Exp:cTipo% AS TPDOC,
				%Exp:cOriLan% AS ORIGEM,
				D13.D13_DTESTO AS DATLAN,
				D13.D13_TM AS TES,
				%Exp:cCf% AS CF,
				D13.D13_QTDEST AS QUANT,
				D13.D13_QTDES2 AS QTSEGUM,
				D13.D13_NUMSEQ AS NUMSEQ,
				D13.D13_LOTECT AS LOTECT,
				D13.D13_NUMLOT AS NUMLOTE,
				D13.D13_ENDER AS LOCALIZ,
				D13.D13_NUMSER AS NUMSERI,
				%Exp:cDtValid AS DTVALI
		FROM %Table:D13% D13
		WHERE D13.D13_FILIAL = %xFilial:D13%
		AND D13.D13_LOCAL = %Exp:cLocal%
		AND D13.D13_PRODUT = %Exp:cProduto%
		AND D13.D13_PRDORI = %Exp:cPrdOri%
		AND D13.D13_NUMSEQ = %Exp:nNumSeq%
		AND D13.%NotDel%
		ORDER BY TIPO,
					DATLON,
					NUMSEQ
	EndSql
	TcSetField(cAliasQry,'DATA','D')
	TcSetField(cAliasQry,'DTVALID','D')
	Do While (cAliasQry)->(!Eof())
		// Movimentos SD1/SD2/SD3/SD5/D13	
		AAdd(aRastrear,{(cAliasQry)->TIPO,X2NOME(),(cAliasQry)->OPERACAO,(cAliasQry)->DATLAN,(cAliasQry)->DOC,(cAliasQry)->SERIE,(cAliasQry)->CLIFOR,(cAliasQry)->LOJA,(cAliasQry)->TES,(cAliasQry)->CF,(cAliasQry)->LOTECTL,(cAliasQry)->NUMLOTE,(cAliasQry)->LOCALIZ,(cAliasQry)->NUMSERI,(cAliasQry)->QUANT,(cAliasQry)->QTSEGUM,(cAliasQry)->NUMSEQ})
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	MntCargDad('WMSRAS',aRastrear, aFieldRAS)
Return .T.