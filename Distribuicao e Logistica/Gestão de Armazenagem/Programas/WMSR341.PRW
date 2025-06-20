#include 'Protheus.ch'  
#include 'WMSR341.ch'

#DEFINE WMSA43101 "WMSA43101"

//---------------------------------------------------------------------------
/*/{Protheus.doc} WmsR341
Relatorio de analise de carga x pedido
@author Flavio Luiz Vicco
@since 21/06/2006
@version 1.0
/*/
//---------------------------------------------------------------------------
Function WmsR341()
Local oReport
	If !SuperGetMV("MV_WMSNEW", .F., .F.)
		Return WmsR340()
	EndIf	

	// Interface de impressao
	oReport:= ReportDef()
	oReport:PrintDialog()
Return NIL
//----------------------------------------------------------
// Defini��es do relat�rio
//----------------------------------------------------------
Static Function ReportDef()
Local oReport
Local oSection1
Local oCell
Local cTitle := OemToAnsi(STR0001) // ANALISE DE CARGA X PEDIDO
	//-----------------------------------------------------------------------
	// Criacao do componente de impressao
	// TReport():New
	// ExpC1 : Nome do relatorio
	// ExpC2 : Titulo
	// ExpC3 : Pergunte
	// ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao
	// ExpC5 : Descricao
	//-----------------------------------------------------------------------
	oReport := TReport():New("WMSR341",cTitle,"WMR340",{|oReport| ReportPrint(oReport,'SC9')},STR0009) // Analise de carga x pedido apresentando o status do servico
	//-----------------------------------------------------------------------
	//  Variaveis utilizadas para parametros
	//  mv_par01  //  Carga   De  ?
	//  mv_par02  //          Ate ?
	//  mv_par03  //  Armazem De  ?
	//  mv_par04  //          Ate ?
	//  mv_par05  //  Servico Separacao   ?
	//  mv_par06  //  Tarefa  Separacao   ?
	//  mv_par07  //  Servico Conferencia ?
	//  mv_par08  //  Tarefa  Conferecia  ?
	//  mv_par09  //  Pedidos com bloqueio? Sim / Nao
	//-----------------------------------------------------------------------
	Pergunte(oReport:uParam,.F.)
	//-----------------------------------------------------------------------
	// Criacao da secao utilizada pelo relatorio
	// TRSection():New
	// ExpO1 : Objeto TReport que a secao pertence
	// ExpC2 : Descricao da se�ao
	// ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela
	//         sera considerada como principal para a se��o.
	// ExpA4 : Array com as Ordens do relat�rio
	// ExpL5 : Carrega campos do SX3 como celulas
	//         Default : False
	// ExpL6 : Carrega ordens do Sindex
	//         Default : False
	//-----------------------------------------------------------------------
	// Criacao da celulas da secao do relatorio
	// TRCell():New
	// ExpO1 : Objeto TSection que a secao pertence
	// ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado
	// ExpC3 : Nome da tabela de referencia da celula
	// ExpC4 : Titulo da celula
	//         Default : X3Titulo()
	// ExpC5 : Picture
	//         Default : X3_PICTURE
	// ExpC6 : Tamanho
	//         Default : X3_TAMANHO
	// ExpL7 : Informe se o tamanho esta em pixel
	//         Default : False
	// ExpB8 : Bloco de c�digo para impressao.
	//         Default : ExpC2
	//-----------------------------------------------------------------------
	oSection1:= TRSection():New(oReport,STR0019,{"SC9"},/*aOrdem*/) // Itens de pedidos de venda liberados
	oSection1:SetHeaderPage()
	TRCell():New(oSection1,"C9_CARGA",		"SC9",STR0010,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // Carga
	TRCell():New(oSection1,"C9_PEDIDO",	"SC9",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"C9_PRODUTO",	"SC9",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"C9_QTDLIB",	"SC9",STR0011,PesqPictQt('C9_QTDLIB'),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // Qtde
	TRCell():New(oSection1,"C9_LOTECTL",	"SC9",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"C9_SERVIC",	"SC9",STR0012,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // Cod
	TRCell():New(oSection1,"C9_BLWMS",		"SC9",STR0013,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // Blq
	TRCell():New(oSection1,"CSTSERV",		"",STR0014,,17) // Servico
	TRCell():New(oSection1,"CSTSEPAR",		"",STR0015,,17) // Separacao
	TRCell():New(oSection1,"CSTCONFE",		"",STR0016,,17) // Conferencia
	TRCell():New(oSection1,"CLIBFAT",		"",STR0017,,3) // Lib.Faturar
Return(oReport)
//----------------------------------------------------------
// Impress�o do relat�rio
//----------------------------------------------------------
Static Function ReportPrint(oReport,cAliasSB1)
Local oSection1 := oReport:Section(1)
Local cAliasNew := "SC9"
Local aSx3Box1  := RetSx3Box(Posicione('SX3',2,'DCF_STSERV','X3CBox()'),,,1)
Local aSx3Box2  := RetSx3Box(Posicione('SX3',2,'D12_STATUS','X3CBox()'),,,1)
Local cVazio1   := Space(Len(SC9->C9_NFISCAL))
Local cVazio2   := Space(Len(SC9->C9_BLEST))
Local cVazio3   := Space(Len(SC9->C9_BLCRED))
Local cVazio4   := Space(Len(SC9->C9_CARGA))
Local cStServ   := ""
Local cStSepar  := ""
Local cStConfe  := ""
Local cSelect   := "%%"
Local cJoin     := "%%"
Local cWhere    := "%%"

	dbSelectArea(cAliasNew)
	dbSetOrder(1)
	// Filtragem do relat�rio
	If	!Empty(mv_par07) .And. !Empty(mv_par08)
		cSelect := "%, Min(D122.D12_STATUS) STCONFE%"
		cJoin   :=  "%JOIN "+RetSqlName('D12')+" D122"
		cJoin   +=    " ON D122.D12_FILIAL = '"+xFilial("D12")+"'" 
		cJoin   +=   " AND D122.D12_IDDCF  = DCR.DCR_IDORI" 
		cJoin   +=   " AND D122.D12_SERVIC = '"+mv_par07+"'" 
		cJoin   +=   " AND D122.D12_TAREFA = '"+mv_par08+"'" 
		cJoin   +=   " AND D122.D_E_L_E_T_ = ' '%"
	EndIf
	If	mv_par09 == 1
		cWhere := "%AND SC9.C9_BLWMS <> '05'%"
	EndIf
	
	cAliasNew := GetNextAlias()
	// Transforma parametros Range em expressao SQL
	MakeSqlExpr(oReport:uParam)
	// Query do relat�rio da secao 1
	oReport:Section(1):BeginQuery()
	
	BeginSql Alias cAliasNew	
		SELECT C9_CARGA, 
		       C9_PEDIDO, 
		       Min(C9_PRODUTO) C9_PRODUTO, 
		       Min(C9_QTDLIB) C9_QTDLIB, 
		       Min(C9_LOTECTL) C9_LOTECTL, 
		       Min(C9_BLWMS) C9_BLWMS, 
		       Min(C9_SERVIC) C9_SERVIC, 
		       Min(DCF_STSERV) DCF_STSERV, 
		       Min(D121.D12_STATUS) STSEPAR
		%Exp:cSelect%
		  FROM %table:SC9% SC9
		  JOIN %table:DCF% DCF  
		    ON DCF.DCF_FILIAL = %xFilial:DCF% 
		   AND DCF.DCF_ID     = SC9.C9_IDDCF
		   AND DCF.%NotDel%
		  JOIN %table:DCR% DCR
		    ON DCR.DCR_FILIAL = %xFilial:DCR% 
		   AND DCR.DCR_IDDCF  = DCF.DCF_ID
		   AND DCR.DCR_SEQUEN = DCF.DCF_SEQUEN
		   AND DCR.%NotDel% 
		  JOIN %table:D12% D121 
		    ON D121.D12_FILIAL = %xFilial:D12% 
		   AND D121.D12_IDDCF  = DCR.DCR_IDORI  
		   AND D121.D12_SERVIC = %Exp:mv_par05% 
		   AND D121.D12_TAREFA = %Exp:mv_par06% 
		   AND D121.%NotDel%
		%Exp:cJoin%
		 WHERE C9_FILIAL  = %xFilial:SC9%
		   AND C9_LOCAL   BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
		   AND C9_NFISCAL = %Exp:cVazio1%
		   AND C9_BLEST   = %Exp:cVazio2%
		   AND C9_BLCRED  = %Exp:cVazio3%
		   AND C9_CARGA  <> %Exp:cVazio4%
		   AND C9_CARGA   BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
		   AND SC9.%NotDel%
		 %Exp:cWhere%
		 GROUP BY C9_CARGA, 
		          C9_PEDIDO
		 ORDER BY C9_CARGA, 
		          C9_PEDIDO
	EndSql
	// Metodo EndQuery ( Classe TRSection )
	// Prepara o relat�rio para executar o Embedded SQL.
	// ExpA1 : Array com os parametros do tipo Range
	
	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
	
	oReport:SetMeter(RecCount())
	oSection1:Init()
	dbSelectArea(cAliasNew)
	While !oReport:Cancel() .And. !(cAliasNew)->(Eof())
		If oReport:Cancel()
			Exit
		EndIf
		oReport:IncMeter()
	
		cStServ := (cAliasNew)->DCF_STSERV
		cStSepar:= (cAliasNew)->STSEPAR
		If	!Empty(mv_par07) .And. !Empty(mv_par08)
			cStConfe:= (cAliasNew)->STCONFE
		EndIf
	
		If	( nSeek := Ascan( aSx3Box1, { |x| x[ 2 ] == cStServ } ) ) > 0
			oSection1:Cell("CSTSERV"):SetValue(Left(aSx3Box1[ nSeek, 3 ],17))
		EndIf
		If	( nSeek := Ascan( aSx3Box2, { |x| x[ 2 ] == cStSepar } ) ) > 0
			oSection1:Cell("CSTSEPAR"):SetValue(Left(aSx3Box2[ nSeek, 3 ],17))
		EndIf
		If	!Empty(mv_par07) .And. !Empty(mv_par08)
			If	( nSeek := Ascan( aSx3Box2, { |x| x[ 2 ] == cStConfe } ) ) > 0
				oSection1:Cell("CSTCONFE"):SetValue(Left(aSx3Box2[ nSeek, 3 ],17))
			EndIf
			oSection1:Cell("CLIBFAT"):SetValue(Iif((cAliasNew)->C9_BLWMS=='05' .And. cStConfe == '1',STR0006,STR0007)) // Sim // Nao
		EndIf
		oSection1:PrintLine()
		(cAliasNew)->(dbSkip())
	EndDo
	oSection1:Finish()
Return NIL
