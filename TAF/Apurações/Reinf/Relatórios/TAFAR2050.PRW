#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFAR2050.CH"

#DEFINE SINTETICO 1,1
#DEFINE ANALITICO 2,1
#DEFINE PROCESSOS 3,1

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAR2050
Relatório em TReport para previa análise das informações que serão transmitidas
referente ao evento R-2050

@author Matheus Prada;
@since 18/10/2019
@version 1.0
/*/
//------------------------------------------------------------------- 
Function TAFAR2050(cPerApu, aFiliais, cEvent)
Local oReport			:= ''

Default cEvent			:= 'R2050'//

	If FindFunction("TRepInUse") .And. TRepInUse()
		//-- Interface de impressao
		oReport := ReportDef(cPerApu, aFiliais, cEvent)
		oReport:PrintDialog()
	EndIf	

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Instancia a classe TReport() e monta a section

@author Matheus Prada;
@since 18/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerApu, aFiliais, cEvent)

Local cPerApu		as character
Local lAutomacao    as logical
Local oReport     	as object
Local oSection1		as object
Local oSection2		as object
Local oSection2B	as object
Local oRecBruta		as object
Private oBreak		as object

oReport	:= TReport():New('TAFAR2050',cEvent,'',{|oReport| Req2050(cPerApu, aFiliais, oReport, cEvent)},STR0001,,,,,.F.) //'Relatório de previsão da apuração dos eventos.'
oReport:SetTotalInLine(.F.) 

//Resumo dos registros do relatório
oSection1 	:= TRSection():New(oReport,,,,,,, .F.)//

				TRCell():New(oSection1,'FILIAL'		, '', "Filial"			, 							,  10						,,,"LEFT"	,,"LEFT") //'Filial'
				TRCell():New(oSection1,'CHVNF'		, '', "Num. Doc"		, 							,  14						,,,"LEFT"	,,"LEFT") //"Dt.Emissao"
				TRCell():New(oSection1,'SERIE'		, '', "Serie Doc"		, 							,  6						,,,"LEFT"	,,"LEFT") //'Descricao do Participante'
oRecBruta := 	TRCell():New(oSection1,'VLRRECBRUTA', '', "Rec. Bruta  "	, "@E 999999999999999.99" 	,  16						,,,"LEFT"	,,"LEFT") //"Bruto.Doc"
				TRCell():New(oSection1,'C1HCODPAR'	, '', "Cod. Part"		, 							,  20						,,,"LEFT"	,,"LEFT") //'Codigo do Participante'
				TRCell():New(oSection1,'NOME'		, '', "Razão Social"	, 							,  40						,,,"LEFT"	,,"LEFT") //'Razão Social do Participante'
				TRCell():New(oSection1,'CNPJ'		, '', "CNPJ Part"		, 'R@ 99.999.999/9999-99'	,  20						,,,"LEFT"	,,"LEFT") //'CNPJ Participante'
				TRCell():New(oSection1,'DTEMISSAONF', '', "Dt Emissao"		,							,  10						,,,"LEFT"	,,"LEFT") //"Nr.Documento"

oSection1:lHeaderPage 	 := .F.
oSection1:lHeaderVisible := .T.
oSection1:lHeaderSection := .T.  
oSection1:SetReadOnly()
oSection1:SetLineStyle( .T. )
oSection1:SetTotalInLine( .F. ) 
oSection1:SetPageBreak( .T. ) // Pula página na quebra da seção
    
oBreak := TRBreak( ):New( oSection1, { || FILIAL }, "Valor por filial", .T.) // Quebra por Filial

//Detalhe dos registros do relatório
oSection2 	:= TRSection():New(oSection1,STR0002,,,,,, .F.) //'Movimentacoes'
oSection2B 	:= TRSection():New(oSection2,"Item",,,,,, .F.) //'Movimentacoes'
TRCell():New(oSection2B,'NUMITE'	 	, 	'', ''				, 						,  15							,,,"RIGHT",,"RIGHT") //"Base.Trib"
TRCell():New(oSection2,'FILIAL'	 	,	'', "Filial"			, 						,  (TAMSX3("C20_FILIAL")[1]+2)	,,,"RIGHT",,"RIGHT") //"Ident"
TRCell():New(oSection2,'BASE'		,	'', "Base de Calculo"	, "@E 99999999999.99"	,  14							,,,"RIGHT",,"RIGHT") //"Valor tributo"
TRCell():New(oSection2,'VALOR'		,	'', "Val. imposto"		, "@E 99999999999.99"	,  14							,,,"RIGHT",,"RIGHT") //"Valor tributo"
TRCell():New(oSection2,'CODTRI'	 	,	'', "Cod. Trib"			,						,  15							,,,"RIGHT",,"RIGHT") //"Nr.Documento"
TRCell():New(oSection2,'DESCRI'	 	,	'', "Nome Trib."		, 				 	 	,  TAMSX3("C3S_DESCRI")[1]		,,,"RIGHT",,"RIGHT") //"Base.Trib"	

oReport:AddHeaderPage( oSection2 )
oSection2:lHeaderPage 	 := .T.
oSection2:lHeaderBreak 	 := .T. 
oSection2:lHeaderVisible := .F.
oSection2:lHeaderSection := .T.	
oSection2:SetTotalInLine( .F. ) 
oReport:AddHeaderPage( oSection2B )
oSection2B:lHeaderPage 	 := .T.
oSection2B:lHeaderBreak 	 := .T.
oSection2B:lHeaderVisible := .F. 
oSection2B:lHeaderSection := .T.	
oSection2B:SetTotalInLine( .F. ) 
 
TRFunction():New(oRecBruta  ,,'SUM',oBreak,, "@E 999999999999999.99", /*uFormula*/, .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/,oSection1)
Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} Req2050
Efetua a consulta com o próprio mecanismo da apuração e 
imprime as infommações com o método Print() do evento R2050

@author Felipe Guarnieri;
@since 01/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Req2050(cPerApu, aFiliais, oReport, cEvent)

Local cFrom		:= ""
Local cQuery	:= ""
Local aQuery	:= {}
Local cAlItem	:= GetNextAlias()
Local cAlREs	:= GetNextAlias()
Local cCompC1H	:= Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
Local cFiliais	:= ""
Local cFil 		:= ""
Local cPartic	:= "" 
Local cChvNF	:= ""
Local aAreaSM0 	:= SM0->(GetArea())
Local oCab 		:= oReport:Section(1)
Local oItem 	:= oCab:Section(1)
Local oItemB 	:= oItem:Section(1) 
Local cItem		:= ""
Local cFilAcum	:= ""
Local aInfoEUF 	:= TamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
Local aAreaAnt 	:= {}
Local lFirstFil	:= .t.

Private aValores := {} 

If ValType(aFiliais) <> "A" .Or. Empty(aFiliais)
	aFiliais 		:= {{'','D MG 01','','','','',.T.}}
EndIf

cFiliais	:= 	TafRetFilC("C20", aFiliais) 

aQuery	:= Qry2050(cPerApu, aInfoEUF, cCompC1H, cFiliais)

cQuery  := "%" + aQuery[1]	+ "%"
cFrom  	:= "%" + aQuery[2] + aQuery[3] + aQuery[4] + "%"


oCab:BeginQuery()

	BeginSql Alias cAlREs
		Column DTEMISSAONF AS DATE
		
		SELECT
			C20.C20_FILIAL AS FILIAL, C20.C20_NUMDOC AS CHVNF, C20.C20_CHVNF AS NUMDOC, C20.C20_SERIE AS SERIE, C30.C30_VLOPER AS VLRRECBRUTA,C30.C30_NUMITE AS NUMITE, C20.C20_DTDOC AS DTEMISSAONF, C1H.C1H_CNPJ AS CNPJ, C1H.C1H_CODPAR AS C1HCODPAR, C1H.C1H_NOME AS NOME, C35.C35_CODTRI AS CODTRI, C35.C35_VALOR AS VALOR 
		%Exp:cFrom%
		ORDER BY C20_FILIAL, C20_CHVNF,  C30.C30_NUMITE,  C35_CODTRI
	EndSql

oCab:EndQuery()

oItem:BeginQuery()

	BeginSql Alias cAlItem
		Column DTEMISSAONF AS DATE
		
		SELECT
			%EXP:cQuery%
		ORDER BY C20_FILIAL, C20_CHVNF,  C30.C30_NUMITE,  C35_CODTRI
	EndSql
oItem:EndQuery()

oCab:init()
oItem:init() 
oItemB:init() 
cFilAcum := Iif(!(cAlREs)->(Eof()), (cAlREs)->FILIAL, '')
lFirstFil	:=	.t.
While !(cAlREs)->(Eof())
	If !(cFilAcum == (cAlREs)->FILIAL)		
		oReport:SkipLine( )
		oReport:SkipLine( )
		oCab:Finish( )
		oReport:SkipLine( )
		oCab:Init( ) 
	EndIf
	
	If !((cAlREs)->FILIAL == cFil .And. (cAlREs)->CHVNF==cChvNF )
		if !lFirstFil
			oReport:ThinLine()
		Endif 
		lFirstFil	:=	.f.
		oReport:SkipLine()
		oReport:SkipLine()
		oReport:SkipLine()
		cFil 		:= (cAlREs)->FILIAL
		cFilAcum	:= (cAlREs)->FILIAL //variavel usada para o acumulador
		cChvNF 		:= (cAlREs)->CHVNF
		aAreaAnt := GETAREA()
		nValBrut := TR2050VBru(cFil,(cAlREs)->NUMDOC) 
		RESTAREA(aAreaAnt)  
		oCab:Cell( "VLRRECBRUTA" ):SetValue( nValBrut ) 
		oCab:Cell( "FILIAL" ):SetValue( cFil )
		oCab:Cell( "CHVNF" ):SetValue( cChvNF )		
		oCab:PrintLine()
	EndIf

	If (cAlItem)->FILIAL == (cAlREs)->FILIAL .And. (cAlItem)->CHVNF==(cAlREs)->CHVNF .And. (cAlItem)->SERIE==(cAlREs)->SERIE .And. (cAlItem)->NUMITE==(cAlREs)->NUMITE
		oReport:SkipLine() 
		oReport:ThinLine()
		oReport:SkipLine()
	EndIf
	lContrItem := .t.
	While !(cAlItem)->(EOF()) .And. (cAlItem)->FILIAL == (cAlREs)->FILIAL .And. (cAlItem)->CHVNF==(cAlREs)->CHVNF .And. (cAlItem)->SERIE==(cAlREs)->SERIE .And. (cAlItem)->NUMITE==(cAlREs)->NUMITE
		if lContrItem .and. oReport:nExcelPrintType < 3 
			oItemB:Cell("NUMITE"):SetValue("Item NF: "+(cAlItem)->NUMITE) 
			oItemB:PrintLine()
		endif 
		
		oItem:Cell("FILIAL"):SetValue((cAlItem)->FILIAL)
		oItem:Cell("CODTRI"):SetValue((cAlItem)->CODTRI)
		oItem:Cell("BASE"):SetValue((cAlItem)->BASE)
		oItem:Cell("VALOR"):SetValue((cAlItem)->VALOR)
		oItem:Cell("DESCRI"):SetValue( Iif('GILRAT' $ (cAlItem)->DESCRI, Alltrim(SubStr((cAlItem)->DESCRI, 1, At('(',(cAlItem)->DESCRI) - 1)),(cAlItem)->DESCRI ) )

			
		if lContrItem .and. oReport:nExcelPrintType >= 3 
			oItemB:Cell("NUMITE"):SetValue("Item NF: "+(cAlItem)->NUMITE) 
			oItem:PrintLine()
			oItemB:PrintLine()
			
		ELSE
			oItemB:Cell("NUMITE"):SetValue("") 
			oItem:PrintLine()
			if oReport:nExcelPrintType >= 3 
				oItemB:PrintLine()
			Endif

		endif  	
		(cAlItem)->(dbSkip())		
		lContrItem := .f.
		
	EndDo
	(cAlREs)->(dbSkip())
EndDo

oItem:init()
oCab:Finish()

RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Qry2050
Realiza a montagem da query para geração do relatório do evento R-2050

@author Felipe Guarnieri;
@since 01/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function Qry2050(cPerApu, aInfoEUF, cCompC1H, cFiliais)

Local cQuery 	:= ""
Local cSelect	:= ""
Local cFrom		:= ""
Local cJoin		:= ""
Local cWhere	:= ""
Local cBd		:= ""
Local cPer      := ""

Default cFiliais := ""
Default aInfoEUF := {}
Default cCompC1H := ""
Default cPerApu  := ""

cPer := STRTRAN(cPerApu, '-')

cBd	:= TcGetDb()

cSelect	:= "C20.C20_FILIAL AS FILIAL, C20.C20_DTDOC AS DTEMISSAONF, C20.C20_NUMDOC AS CHVNF, C20.C20_CHVNF AS NUMDOC, C20.C20_SERIE AS SERIE,C35.C35_BASE AS BASE, C35.C35_VALOR AS VALOR, C35_CODTRI AS CODTRI, C30.C30_VLOPER AS VLRRECBRUTA, C30.C30_NUMITE AS NUMITE,   C1H.C1H_CNPJ AS CNPJ, C1H.C1H_CODPAR AS C1HCODPAR, C1H.C1H_NOME AS NOME, C3S.C3S_DESCRI AS DESCRI, "

cSelect 	+= " CASE "
		
If GetMV('MV_TAFVLRE') == '1_04_00'
	cSelect		+= " WHEN C30.C30_INDISE = '1'"
	cSelect		+= " THEN '7'"
EndIf

cSelect 	+= " WHEN C1H.C1H_PAA = '1'" 
cSelect 	+= " THEN '8'"
cSelect 	+= " WHEN C1H.C1H_PAA <> '1' AND "

If cBd $ "ORACLE|POSTGRES|DB2"
	cSelect 	+= " SUBSTR(C0Y.C0Y_CODIGO,1,1) = '7' "
		
ElseIf cBd $ "INFORMIX"
	cSelect 	+= " C0Y.C0Y_CODIGO[1,1] = '7'" 			
		
Else //MSSQL,MYSQL,PROGRESS
	cSelect 	+= " SUBSTRING(C0Y.C0Y_CODIGO,1,1) = '7' "
EndIf
	
cSelect 	+= " THEN '9'"
cSelect 	+= " WHEN C1H.C1H_PAA <> '1' AND "
		
If cBd $ "ORACLE|POSTGRES|DB2"
	cSelect 	+= " SUBSTR(C0Y.C0Y_CODIGO,1,1) <> '7'"
		
ElseIf cBd $ "INFORMIX"
	cSelect 	+= " C0Y.C0Y_CODIGO[1,1] <> '7'"
		
Else //MSSQL,MYSQL,PROGRESS
	cSelect 	+= " SUBSTRING(C0Y.C0Y_CODIGO,1,1) <> '7'"
EndIf
		
cSelect	+= " THEN '1'"
cSelect  += " END AS INDCOM "
	   
cFrom	+= " FROM " + RetSqlName("C20") + " C20"
	
cJoin	+= " INNER JOIN " + RetSqlName("C30") + " C30 On C20.C20_FILIAL 	= C30_FILIAL AND C30.D_E_L_E_T_ <> '*' AND C20.C20_CHVNF = C30.C30_CHVNF AND "
cJoin	+= " C30.C30_IDTSER = '" + Padr(" ", TamSx3("C30_IDTSER")[1]) + "' AND C30.C30_SRVMUN = '" + Padr(" ", TamSx3("C30_SRVMUN")[1]) + "' AND C30.C30_CODSER = '" + Padr(" ", TamSx3("C30_CODSER")[1]) + "' AND C30.C30_TPREPA = '" + Padr(" ", TamSx3("C30_TPREPA")[1]) + " ' "	
cJoin	+= " INNER JOIN " + RetSqlName("C35") + " C35 On C30.C30_FILIAL 	= C35_FILIAL AND C30.C30_CHVNF = C35.C35_CHVNF AND "
cJoin	+= " C30.C30_NUMITE = C35.C35_NUMITE AND C35.C35_CODTRI IN ('000013','000024','000025') AND C35.D_E_L_E_T_ <> '*' "
cJoin	+= " INNER JOIN " + RetSqlName("C1H") + " C1H ON C1H.C1H_ID = C20.C20_CODPAR " // " AND C1H.C1H_PPES IN ('2','3') "
cJoin	+= " AND C1H.C1H_INDDES <> '1' AND C1H.D_E_L_E_T_ <> '*' "

If cCompC1H == "EEE"
	cJoin += "AND C1H.C1H_FILIAL = C20.C20_FILIAL "			
Else
	If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 
		cJoin += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
	ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0 
		cJoin += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") " 
	EndIf
EndIf

cJoin	+= " INNER JOIN " + RetSqlName("C0Y") + " C0Y ON C0Y.C0Y_ID = C30.C30_CFOP"
cJoin	+= " INNER JOIN " + RetSqlName("C3S") + " C3S ON C3S.C3S_ID = C35.C35_CODTRI"
	
	// Where
cWhere	+= " WHERE C20.C20_FILIAL IN " + cFiliais + " AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') AND C20.D_E_L_E_T_ <> '*' AND "
cWhere	+=  " C20.C20_INDOPE = '1' AND "
	
If cBd $ "ORACLE|POSTGRES|DB2"
	cWhere	+=  " SUBSTR(C20.C20_DTDOC,1,6) = '"+ Right(cPer, 4)+Left(cPer, 2) +"'"
			
ElseIf cBd $ "INFORMIX"
	cWhere	+=  " C20.C20_DTDOC[1,6] = '"+ Right(cPer, 4)+Left(cPer, 2) +"'"
	
Else
	cWhere	+=  " SUBSTRING(C20.C20_DTDOC,1,6) = '"+ Right(cPer, 4)+Left(cPer, 2) +"'"
EndIf
	
cQuery := cSelect + cFrom + cJoin + cWhere
 // Retornar From, Join, Where e a query separado para que eu consiga executar a query no BeginSQL

Return {cQuery, cFrom, cJoin, cWhere}


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

/*/{Protheus.doc} TR2050VBru
	(long_description)
	@type  Static Function
	@author Henriuque Pereira
	@since 06/03/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function TR2050VBru(cFil2050, cChave2050) 
Local nVlrBruto	:= 0
Local cAlsLocal	:= GetNExtAlias()

Default cFil2050 	:= ''	
Default cChave2050 	:= ''
	BeginSql Alias cAlsLocal

		SELECT C30.C30_VLOPER C30VLOPER, C30.C30_CHVNF from  %table:C30% C30    
		INNER JOIN  %table:C35% C35 ON C30.C30_FILIAL = C35_FILIAL
		AND C30.C30_CHVNF = C35.C35_CHVNF
		AND C30.C30_NUMITE = C35.C35_NUMITE
		AND C35.D_E_L_E_T_ <> '*' 
		AND C30.D_E_L_E_T_ <> '*'
		AND C35.C35_CODTRI IN (	'000013', 
								'000024',
								'000025')

		Where C30.C30_FILIAL = %EXP:cFil2050% 

		AND C30.C30_CHVNF = %EXP:cChave2050%    	                                       
		AND C30.C30_IDTSER = '      '
		AND C30.C30_SRVMUN = '                    '
		AND C30.C30_CODSER = '      '
		AND C30.C30_TPREPA = '  '
		GROUP BY C30.C30_VLOPER, C30_CHVNF,C30_CODITE
	EndSql

	(cAlsLocal)->(DbGoTop())
	While !(cAlsLocal)->(Eof())
		nVlrBruto	+= (cAlsLocal)->C30VLOPER
	(cAlsLocal)->(DbSkip( ))
	EndDo 
	
Return nVlrBruto//Alltrim(Transform(nVlrBruto,"@E 999999999999999.99"))
