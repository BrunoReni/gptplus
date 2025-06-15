#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFARCP.CH"

#DEFINE SINTETICO 1,1
#DEFINE ANALITICO 2,1
#DEFINE PROCESSOS 3,1


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFARCP
Relatório em TReport para previa análise das informações que serão transmitidas
refernte aos eventos R-2010 e R-2020 

@author Henrique Pereira;
@since 10/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Function TAFARCP(cPerApu, aFiliais, cEvent)
Local oReport			:= ''

Default cEvent			:= 'R2010'

	If FindFunction("TRepInUse") .And. TRepInUse()
		//-- Interface de impressao
		oReport := ReportDef(cPerApu, aFiliais, cEvent)
		oReport:PrintDialog()
	EndIf	

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFARCP
Instancia a classe TReport() e monta a section

@author Henrique Pereira;
@since 10/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerApu, aFiliais, cEvent)

	Local cPer			as character
	Local lAutomacao    as logical
	Local oReport     	as object
	Local oSection1		as object
	Local oSection2		as object
	Private oBreak		as object
	
	cPer 				:= StrTran(cPerApu,"-","")
	cPer				:= substr(cPer,3,6)+substr(cPer,1,2)

	oReport             := Nil
	lAutomacao          := .f.  

    oReport 	:= TReport():New('TAFARCP',cEvent,'',{|oReport| Req20XX(cPer, aFiliais, @oReport, cEvent)},STR0001) //'Relatório de previsão da apuração dos eventos.'
	oReport:SetTotalInLine(.F.) 

	//Resumo dos registros do relatório
	oSection1 	:= TRSection():New(oReport,STR0022)//'Dados Participante'

	TRCell():New(oSection1,'FILIAL'		, '', STR0024	, /*Picture*/,  25,	/*lPixel*/,) //'Filial'
	TRCell():New(oSection1,'C1HCODPAR'	, '', STR0003	, /*Picture*/,  22,	/*lPixel*/,) //'Codigo do Participante'
	TRCell():New(oSection1,'C1HNOME'	, '', STR0004	, /*Picture*/,  25,	/*lPixel*/,) //'Descricao do Participante'
	TRCell():New(oSection1,'CNPJ'		, '', STR0005	, 'R@ 99.999.999/9999-99',  18,	/*lPixel*/,) //'CNPJ Participante'
	TRCell():New(oSection1,'DESCUF'		, '', STR0006	, /*Picture*/,  15,	/*lPixel*/,) //'UF Participante'	
	TRCell():New(oSection1,'DESCMUN'	, '', STR0007	, /*Picture*/,  22,	/*lPixel*/,) //'Municipio Participante'

	oSection1:lHeaderPage 	 := .F.
	oSection1:lHeaderVisible := .T.
	oSection1:lHeaderSection := .T.
	oSection1:SetReadOnly()
	oSection1:SetLineStyle( .T. )

	//Detalhe dos registros do relatório
	oSection2 	:= TRSection():New(oSection1,STR0023) //'Movimentacoes'

	TRCell():New(oSection2,'ROTINA'		 ,	'', STR0025, /*Picture*/			 ,  03,	/*lPixel*/,) //"Ident"
	TRCell():New(oSection2,'NUMDOCTO'	 ,	'', STR0026, /*Picture*/			 ,  15,	/*lPixel*/,) //"Nr.Documento"
	TRCell():New(oSection2,'SERIE'		 ,	'', STR0027, /*Picture*/			 ,  03,	/*lPixel*/,) //"Ser"
	TRCell():New(oSection2,'DTEMISSAONF' ,	'', STR0028, /*Picture*/			 ,  14,	/*lPixel*/,) //"Dt.Emissao"
	TRCell():New(oSection2,'CODSERVIC'	 ,	'', STR0029, /*Picture*/			 ,  12,	/*lPixel*/,) //"Cod.Serv"	
	TRCell():New(oSection2,'C8CDESCRI'	 ,	'', STR0030, /*Picture*/			 ,  14,	/*lPixel*/,) //"Descr.Serv"
	TRCell():New(oSection2,'VLRBRUTO'	 ,	'', STR0031, "@E 999999999999999.99" ,  20, /*lPixel*/,) //"Bruto.Doc"
	TRCell():New(oSection2,'VLRBASERET'	 ,	'', STR0032, "@E 99999999999.99"	 ,  17, /*lPixel*/,) //"Base.Trib"
	TRCell():New(oSection2,'VLRRETENCAO' ,	'', STR0033, "@E 99999999999.99"	 ,  16, /*lPixel*/,) //"Trib.Ret"
	TRCell():New(oSection2,'VLRNRETPRINC',	'', STR0034, "@E 99999999999.99" 	 ,  16, /*lPixel*/,) //"Trib.NRet"
	TRCell():New(oSection2,'VLRRETSUB'	 ,	'', STR0035, "@E 99999999999.99"	 ,  16, /*lPixel*/,) //"Trib.RetSubC"
	TRCell():New(oSection2,'VLRSERV15'	 ,	'', STR0036, "@E 999999.99"			 ,  11, /*lPixel*/,) //"Trib.15A"
	TRCell():New(oSection2,'VLRSERV20'	 ,	'', STR0037, "@E 999999.99"			 ,  11, /*lPixel*/,) //"Trib.20A"
	TRCell():New(oSection2,'VLRSERV25'	 ,	'', STR0038, "@E 999999.99"			 ,  11, /*lPixel*/,) //"Trib.25A"
	TRCell():New(oSection2,'VLRADIC'	 ,  '', STR0039, "@E 999999.99"		 	 ,  11, /*lPixel*/,) //"Trib.25A"

	oReport:AddHeaderPage( oSection2 )
	oSection2:lHeaderPage 	 := .T.
	oSection2:lHeaderBreak 	 := .T.
	oSection2:lHeaderVisible := .F.
	oSection2:lHeaderSection := .T.	
	oSection2:SetTotalInLine( .F. ) 

	oBreak := TRBreak():New(oSection1,oSection1:Cell('FILIAL'),'Total',.F.)
	TRFunction():New(oSection2:Cell("VLRBRUTO")	 	,,'SUM',oBreak, /*cTitle*/, "@E 999999999999999.99", /*uFormula*/, .T./*lEndSection*/, .T./*lEndReport*/, .F./*lEndPage*/, , {|| VldTot(oSection2,aValores)})
	TRFunction():New(oSection2:Cell("VLRBASERET")	,,'SUM',oBreak, /*cTitle*/, "@E 999999999999999.99", /*uFormula*/, .T./*lEndSection*/, .T./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("VLRRETENCAO")	,,'SUM',oBreak, /*cTitle*/, "@E 999999999999999.99", /*uFormula*/, .T./*lEndSection*/, .T./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("VLRNRETPRINC")	,,'SUM',oBreak, /*cTitle*/, "@E 999999999999999.99", /*uFormula*/, .T./*lEndSection*/, .T./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("VLRRETSUB")	,,'SUM',oBreak, /*cTitle*/, "@E 999999999999999.99", /*uFormula*/, .T./*lEndSection*/, .T./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("VLRSERV15")	,,'SUM',oBreak, /*cTitle*/, "@E 999999999999999.99", /*uFormula*/, .T./*lEndSection*/, .T./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("VLRSERV20")	,,'SUM',oBreak, /*cTitle*/, "@E 999999999999999.99", /*uFormula*/, .T./*lEndSection*/, .T./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("VLRSERV25")	,,'SUM',oBreak, /*cTitle*/, "@E 999999999999999.99", /*uFormula*/, .T./*lEndSection*/, .T./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("VLRADIC")		,,'SUM',oBreak, /*cTitle*/, "@E 999999999999999.99", /*uFormula*/, .T./*lEndSection*/, .T./*lEndReport*/, .F./*lEndPage*/)

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} Req20XX
Efetua a consulta com o próprio mecanismo da apuração e 
imprime as infommações com o método Print()

@author Henrique Pereira;
@since 10/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Req20XX(cPerApu, aFiliais, oReport, cEvent) 

Local cSelect	:= ""
Local cFromC20	:= ""
Local cIJoinC30	:= ""
Local cIJoinC35	:= ""
Local cIJoinC8C	:= ""
Local cLJoinT9C	:= ""
Local cIJoinC1H	:= ""
Local cIJoinC09 := ""
Local cIJoinC07 := ""
Local cWhere	:= ""

Local cSelect2	:= ""
Local cFromLEM	:= ""
Local cJoinT5M	:= ""
Local cJoinC8C	:= ""
Local cJoinT9C	:= ""
Local cJoinC1H	:= ""
Local cJoinC09  := ""
Local cJoinC07 	:= ""
Local cWhere2	:= ""

Local cAlItem	:= GetNextAlias()
Local cAlREs	:= GetNextAlias()
Local cCompC1H	:= Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
Local cFiliais	:= ""
Local cFil 		:= ""
Local cPartic	:= ""
Local cDataIni  := ""
Local cDataFim  := ""
Local aAreaSM0 	:= SM0->(GetArea())
Local oCab 		:= oReport:Section(1)
Local oItem 	:= oCab:Section(1)

Local aInfoEUF 	:= TamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))

Private aValores := {}

cDataIni := cPerApu + "01"
cDataFim := DtoS( LastDay( StoD( cDataIni ) ) )

If ValType(aFiliais) <> "A" .Or. Empty(aFiliais)
	aFiliais 		:= {{'','D MG 01','','','','',.T.}}
EndIf

cFiliais	:= 	TafRetFilC("C20", aFiliais) 

//-----NF
cSelect	:= " 'NFS' AS ROTINA, C20.C20_FILIAL AS FILIAL, '0' AS ID, C20.C20_NUMDOC AS NUMDOCTO, C20.C20_SERIE AS SERIE, C20.C20_VLDOC AS VLRBRUTO, "
cSelect	+= " C35.C35_BASE AS VLRBASERET, C35.C35_VALOR AS VLRRETENCAO, C35.C35_VLSCON AS VLRRETSUB, C20.C20_DTDOC AS DTEMISSAONF, C35.C35_VLRNPG AS VLRNRETPRINC, "
cSelect	+= " C35.C35_VLCE15 AS VLRSERV15, C35.C35_VLCE20 AS VLRSERV20, C35.C35_VLCE25 AS VLRSERV25, C35.C35_VLRADI AS VLRADIC, C8C.C8C_CREINF AS CODSERVIC, C8C.C8C_DESCRI AS C8CDESCRI, C1H.C1H_CODPAR AS C1HCODPAR "

cFromC20  += RetSqlName("C20") + " C20"
cIJoinC30 := RetSqlName("C30") + " C30 ON C20.C20_FILIAL = C30_FILIAL AND C30.D_E_L_E_T_ = ' ' AND C20.C20_CHVNF = C30.C30_CHVNF AND C30.C30_IDTSER <> ' ' AND C30.C30_TPREPA = ' ' "
cIJoinC35 := RetSqlName("C35") + " C35 ON C30.C30_FILIAL = C35_FILIAL AND C30.C30_CHVNF = C35.C35_CHVNF AND C30.C30_NUMITE = C35.C35_NUMITE AND "
cIJoinC35 += " C30.C30_CODITE = C35.C35_CODITE AND C35.C35_CODTRI = '000013' AND C35.D_E_L_E_T_ = ' ' "

cIJoinC8C := RetSqlName("C8C") + " C8C ON C8C.C8C_ID = C30.C30_IDTSER AND C8C.D_E_L_E_T_ = ' ' "

cLJoinT9C := RetSqlName("T9C") + " T9C ON T9C.T9C_ID = C20.C20_IDOBR AND T9C.D_E_L_E_T_ = ' ' "
cIJoinC1H := RetSqlName("C1H") + " C1H ON C1H.C1H_ID = C20.C20_CODPAR AND C1H.C1H_PPES = '2' AND C1H.C1H_CNPJ <> '' AND C1H.C1H_INDDES <> '1' AND C1H.D_E_L_E_T_ = ' ' "

If cCompC1H == "EEE"
	cIJoinC1H += "AND C1H.C1H_FILIAL = C20.C20_FILIAL "			
Else
	If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
			cIJoinC1H += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C20.C20_FILIAL, 1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
		ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
			cIJoinC1H += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C20.C20_FILIAL, 1," + cValToChar(aInfoEUF[1]) + ") "
	EndIf
EndIf

cIJoinC09 := RetSqlName("C09") + " C09 ON C09_ID = C1H_UF AND C09.D_E_L_E_T_ = ' ' "
cIJoinC07 := RetSqlName("C07") + " C07 ON C07_FILIAL = '" + xFilial("C07") + "' AND C07_ID = C1H_CODMUN AND C07.D_E_L_E_T_ = ' ' "

cWhere := " C20.C20_FILIAL IN " + cFiliais + " AND C20.D_E_L_E_T_ = ' ' AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') AND "

If cEvent == "R-2010"
	cWhere += " C20.C20_INDOPE = '0' AND "
ElseIf cEvent == "R-2020"
	cWhere += " C20.C20_INDOPE = '1' AND "
EndIf

cWhere += " C20.C20_DTDOC BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "

//-----FATURA
cSelect2 := " 'FAT' AS ROTINA, LEM.LEM_FILIAL AS FILIAL, LEM.LEM_ID AS ID, LEM.LEM_NUMERO AS NUMDOCTO, LEM.LEM_PREFIX AS SERIE, LEM.LEM_VLBRUT AS VLRBRUTO, "
cSelect2 += " T5M.T5M_BSINSS AS VLRBASERET, T5M.T5M_VLINSS AS VLRRETENCAO, T5M.T5M_VLRETS AS VLRRETSUB, LEM.LEM_DTEMIS AS DTEMISSAONF, T5M.T5M_VLRETP AS VLRNRETPRINC, "
cSelect2 += " T5M.T5M_VLSV15 AS VLRSERV15, T5M.T5M_VLSV20 AS VLRSERV20, T5M.T5M_VLSV25 AS VLRSERV25, T5M.T5M_VLRADI AS VLRADIC, C8C.C8C_CREINF AS CODSERVIC, C8C.C8C_DESCRI AS C8CDESCRI, C1H.C1H_CODPAR AS C1HCODPAR "

cFromLEM += RetSqlName("LEM") + " LEM"
cJoinT5M := RetSqlName("T5M") + " T5M ON T5M.T5M_FILIAL = LEM.LEM_FILIAL AND T5M.T5M_ID = LEM.LEM_ID AND T5M.T5M_IDPART = LEM.LEM_IDPART AND T5M.T5M_IDTSER <> ' ' AND T5M.T5M_TPREPA = ' ' AND "
cJoinT5M += " T5M.T5M_NUMFAT = LEM.LEM_NUMERO AND T5M.T5M_BSINSS > 0 AND T5M.D_E_L_E_T_ = ' ' "

cJoinC8C := RetSqlName("C8C") + " C8C ON C8C.C8C_ID = T5M.T5M_IDTSER AND C8C.D_E_L_E_T_ = ' ' "

cJoinT9C := RetSqlName("T9C") + " T9C ON T9C.T9C_FILIAL = LEM.LEM_FILIAL AND T9C.T9C_ID = LEM.LEM_IDOBRA AND T9C.D_E_L_E_T_ = ' ' "
cJoinC1H := RetSqlName("C1H") + " C1H ON C1H.C1H_ID = LEM.LEM_IDPART AND C1H.C1H_PPES = '2' AND C1H.C1H_CNPJ <> '' AND C1H.C1H_INDDES <> '1' AND C1H.D_E_L_E_T_ = ' ' "

If cCompC1H == "EEE"
	cJoinC1H += "AND C1H.C1H_FILIAL = LEM.LEM_FILIAL "			
Else
	If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
		cJoinC1H += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(LEM.LEM_FILIAL,1, " +  cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
	ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
		cJoinC1H += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(LEM.LEM_FILIAL,1, " +  cValToChar(aInfoEUF[1]) + ") " 
	EndIf
EndIf

cJoinC09 := RetSqlName("C09") + " C09 ON C09_ID = C1H_UF AND C09.D_E_L_E_T_ = ' ' " 
cJoinC07 := RetSqlName("C07") + " C07 ON C07_FILIAL = '" + xFilial("C07") + "' AND C07_ID = C1H_CODMUN AND C07.D_E_L_E_T_ = ' ' "

cWhere2	:= " LEM.LEM_FILIAL IN " + cFiliais + " AND LEM.LEM_DOCORI = ' ' AND LEM.D_E_L_E_T_ = ' ' AND "

If cEvent == "R-2010"
	cWhere2 += " LEM.LEM_NATTIT = '0' AND "
ElseIf cEvent == "R-2020"
	cWhere2 += " LEM.LEM_NATTIT = '1' AND "
EndIf

cWhere2 += " LEM.LEM_DTEMIS BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "

//----NF
cSelect		:= "%" + cSelect 	+ 	"%"
cFromC20	:= "%" + cFromC20	+ 	"%"
cIJoinC30	:= "%" + cIJoinC30	+	"%"
cIJoinC35	:= "%" + cIJoinC35	+	"%"
cIJoinC8C	:= "%" + cIJoinC8C	+	"%"
cLJoinT9C	:= "%" + cLJoinT9C	+	"%"
cIJoinC1H	:= "%" + cIJoinC1H	+	"%"
cIJoinC09	:= "%" + cIJoinC09  +	"%"
cIJoinC07	:= "%" + cIJoinC07  +	"%"
cWhere		:= "%" + cWhere		+	"%"

//-----FATURA
cSelect2	:= "%" + cSelect2	+ 	"%"
cFromLEM	:= "%" + cFromLEM	+	"%"
cJoinT5M	:= "%" + cJoinT5M	+	"%"
cJoinC8C	:= "%" + cJoinC8C	+	"%"
cJoinT9C	:= "%" + cJoinT9C	+	"%"
cJoinC1H	:= "%" + cJoinC1H	+	"%"
cJoinC09	:= "%" + cJoinC09 	+	"%"
cJoinC07	:= "%" + cJoinC07  	+	"%"
cWhere2		:= "%" + cWhere2	+	"%" 

oCab:BeginQuery()
	BeginSql Alias cAlREs
		COLUMN DTEMISSAONF AS DATE

		SELECT
			C20.C20_FILIAL AS FILIAL, C1H.C1H_CNPJ AS CNPJ, C1H.C1H_CODPAR AS C1HCODPAR, C1H.C1H_NOME AS C1HNOME, C09_DESCRI AS DESCUF, C07_DESCRI AS DESCMUN
		FROM
		%Exp:cFromC20%
		INNER JOIN
		%Exp:cIJoinC30%
		INNER JOIN
		%Exp:cIJoinC35%
		INNER JOIN
		%Exp:cIJoinC8C%		
		LEFT JOIN
		%Exp:cLJoinT9C%
		INNER JOIN
		%Exp:cIJoinC1H%
		INNER JOIN
		%Exp:cIJoinC09%
		INNER JOIN
		%Exp:cIJoinC07%
		WHERE
		%Exp:cWhere%
		GROUP BY C20_FILIAL, C1H_CNPJ, C1H_CODPAR, C1H_NOME, C09_DESCRI, C07_DESCRI
		
		UNION ALL

		SELECT
			LEM.LEM_FILIAL AS FILIAL, C1H.C1H_CNPJ AS CNPJ, C1H.C1H_CODPAR AS C1HCODPAR, C1H.C1H_NOME AS C1HNOME, C09_DESCRI AS DESCUF, C07_DESCRI AS DESCMUN
		FROM
		%Exp:cFromLEM%
		INNER JOIN
		%Exp:cJoinT5M%
		INNER JOIN
		%Exp:cJoinC8C%
		LEFT JOIN
		%Exp:cJoinT9C%
		INNER JOIN
		%Exp:cJoinC1H%
		INNER JOIN
		%Exp:cJoinC09%
		INNER JOIN
		%Exp:cJoinC07%
		WHERE
		%Exp:cWhere2%
		GROUP BY LEM_FILIAL, C1H_CNPJ, C1H_CODPAR, C1H_NOME, C09_DESCRI, C07_DESCRI
		ORDER BY 1,3,4,5,6
	EndSql
oCab:EndQuery()

oItem:BeginQuery()
	BeginSql Alias cAlItem
		COLUMN DTEMISSAONF AS DATE

		SELECT
		%Exp:cSelect%
		FROM
		%Exp:cFromC20%
		INNER JOIN
		%Exp:cIJoinC30%
		INNER JOIN
		%Exp:cIJoinC35%
		INNER JOIN
		%Exp:cIJoinC8C%		
		LEFT JOIN
		%Exp:cLJoinT9C%
		INNER JOIN
		%Exp:cIJoinC1H%
		INNER JOIN
		%Exp:cIJoinC09%
		INNER JOIN
		%Exp:cIJoinC07%
		WHERE
		%Exp:cWhere%

		UNION ALL

		SELECT
		%Exp:cSelect2%
		FROM
		%Exp:cFromLEM%
		INNER JOIN
		%Exp:cJoinT5M%
		INNER JOIN
		%Exp:cJoinC8C%
		LEFT JOIN
		%Exp:cJoinT9C%
		INNER JOIN
		%Exp:cJoinC1H%
		INNER JOIN
		%Exp:cJoinC09%
		INNER JOIN
		%Exp:cJoinC07%
		WHERE
		%Exp:cWhere2%
		ORDER BY 2,18,1,4,5 //FILIAL+PARTCIPANTE+ROTINA+NUMDOCTO+SERIE
	EndSql
oItem:EndQuery()

oCab:init()
oItem:init()

While !(cAlREs)->(Eof())
	If !((cAlREs)->FILIAL == cFil .And. (cAlREs)->C1HCODPAR == cPartic)
		oCab:PrintLine()
		cFil 	:= (cAlREs)->FILIAL
		cPartic := (cAlREs)->C1HCODPAR
	EndIf
 
	While !(cAlItem)->(EOF()) .And. (cAlItem)->FILIAL == (cAlREs)->FILIAL .And. (cAlItem)->C1HCODPAR == (cAlREs)->C1HCODPAR
		aAdd(aValores, (cAlItem)->FILIAL + (cAlItem)->C1HCODPAR + (cAlItem)->ROTINA + (cAlItem)->NUMDOCTO + (cAlItem)->SERIE + DtoS((cAlItem)->DTEMISSAONF) +cValToChar((cAlItem)->VLRBRUTO ) )
		oItem:PrintLine()

		(cAlItem)->(dbSkip())
	EndDo

	oReport:SkipLine()
	oReport:SkipLine()


	(cAlREs)->(dbSkip())
EndDo

oItem:init()
oCab:Finish()

RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TamEUF()

Tamanho da Estrutura SM0 para a empresa, unidade negócio e filial

@author
@since
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function TamEUF(cLayout)

	Local aTam 	As Array
	Local nAte 	As Numeric
	Local nlA 	As Numeric
	Default cLayout := Upper(AllTrim(SM0->M0_LEIAUTE))

	aTam := {0,0,0}
	nAte := Len(cLayout)
	nlA	 := 0

	For nlA := 1 to nAte
		if Upper(substring(cLayout,nlA,1)) == "E"
			++aTam[1]
		elseif Upper(substring(cLayout,nlA,1)) == "U"
			++aTam[2]
		elseif Upper(substring(cLayout,nlA ,1)) == "F"
			++aTam[3]
		endif
	Next nlA

Return aTam


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFARCP
Busca a informação na determinada tabela pelo campo _ID

@author Henrique Pereira;
@since 10/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Function SqlId20xx(cAlias as character, cId as character,  cCmpRet as character )
Local cRet		as character 
Local cAlsCons	as character
Local cSelect	as character
Local cFrom		as character
Local cWhere	as character 

cRet		:= 	''
cAlsCons	:=	GetNextAlias()
cSelect		:=	cCmpRet 
cFrom		:=	RetSqlName(cAlias) + ' ' + cAlias
cWhere		:=	cAlias + '.' + cAlias + "_ID = '" + cId + "' AND D_E_L_E_T_ <> '*' " 

	cSelect		:= "%" + cSelect 	+ 	"%"
	cFrom		:= "%" + cFrom 	+ 	"%"
	cWhere		:= "%" + cWhere 	+ 	"%"

	BeginSql Alias cAlsCons
		SELECT 
		%EXP:cSelect%
		FROM
		%EXP:cFrom%
		WHERE
		%EXP:cWhere%
	EndSql

	if SELECT(cAlsCons) > 0
		cRet := (cAlsCons)->&cCmpRet
	else
		cRet := 'Conteúdo Indisponível'
	endIf

Return (cRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFARCP
Compara as NFS para retonar o total do valor bruto por NFS.

@author Helena Adrignoli Leal
@since 27/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldTot(oSection2,aValores)

Local cValorAtual := AllTrim(aValores[Len(aValores)])
Local lRet 		  := .T.		

Local nCount	:= 0

For nCount := 1 To Len(aValores)

	If cValorAtual == AllTrim(aValores[nCount]) .And. nCount <> Len(aValores)
		lRet := .F.
		Exit
	Else
		lRet := .T.
	EndIf

Next nCount

Return(lRet)
