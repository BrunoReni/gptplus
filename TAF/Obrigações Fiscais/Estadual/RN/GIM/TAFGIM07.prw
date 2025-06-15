#Include 'Protheus.ch'


Function TAFGIM07(aWizard, cJobAux)

	//17� Registro - ICMS do Per�odo (Servi�o de Transporte / Diferen�a de Al�quotas)

	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   	:= MsFCreate( cTxtSys )
	Local cStrTxt		as char
	Local cData 		:= Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)
	Local oError		:= ErrorBlock( { |Obj| Alert( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description ) } )

	Local nValColA as numeric
	Local nValColB as numeric

	Begin Sequence

 		nValColA := FnGetColB("A", cData)
	 	nValColB := FnGetColB("B", cData)

	 	cStrTxt := padL(cValToChar(nValColA * 100),14) //Saldo Devedor Apurado no Per�odo
		cStrTxt += padL(cValToChar(nValColB * 100),14) //Valor Total do ICMS Retido por Terceiros Relativo �s Aquisi��es Sujeitas � ST
		cStrTxt += CRLF

	 	WrtStrTxt( nHandle, cStrTxt )
		GerTxtGIM( nHandle, cTxtSys, "07")

		Recover
		lFound := .F.
	End Sequence

	//Tratamento para ocorr�ncia de erros durante o processamento
	ErrorBlock( oError )

	If !lFound
		//Status 9 - Indica ocorr�ncia de erro no processamento
		PutGlbValue( cJobAux , "7" )
		GlbUnlock()

	Else
		//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
		PutGlbValue( cJobAux , "1" )
		GlbUnlock()

	EndIf

Return

Static Function FnGetColB(cCol as char, cPeriodo as char)

	Local cAliasQry		:= GetNextAlias()

	Local cSelect as char
	Local cFrom 	as char
	Local cWhere 	as char

	cSelect := " SUM(C35_VALOR) VALOR  "

	cFrom := RetSqlName('C20') + ' C20, '
	cFrom += RetSqlName('C30') + ' C30, '
	cFrom += RetSqlName('C0Y') + ' C0Y, '
	cFrom += RetSqlName('C35') + ' C35  '

	cWhere := "     C20.C20_FILIAL  = '" + xFilial("C20") + "' "
	cWhere += " AND C20.C20_INDOPE  = '0' "
	cWhere += " AND SUBSTRING(C20.C20_DTDOC,1,6)	= '" + cPeriodo + "' "
	cWhere += " AND C20.C20_CODSIT IN ('000001', '000002', '000007', '000008', '000009')"

	/*
	========TIPOS DE DOCUMENTOS CONSIDERADOS===========

	000001	DOCUMENTO REGULAR
	000002 ESCRITURACAO EXTEMPORANEA DE DOCUMENTO REGULAR
	000007	DOCUMENTO FISCAL COMPLEMENTAR
	000008	ESCRITURACAO EXTEMPORANEA DE DOCUMENTO COMPLEMENTAR
	000009	DOCUMENTO FISCAL EMITIDO COM BASE EM REGIME ESPECIAL OU NORMA ESPECIFICA
	*/

	cWhere += " AND C30.C30_FILIAL  = C20.C20_FILIAL "
	cWhere += " AND C30.C30_CHVNF   = C20.C20_CHVNF  "
	cWhere += " AND C0Y.C0Y_ID      = C30.C30_CFOP"
	cWhere += " AND C0Y.C0Y_CODIGO  IN ('1351', '1352', '1353', '1354', '1355', '1356', '1360', '1931', '1932') "
	cWhere += " AND C35.C35_FILIAL  = C30.C30_FILIAL "
	cWhere += " AND C35.C35_CHVNF   = C30.C30_CHVNF  "
	cWhere += " AND C35.C35_NUMITE  = C30.C30_NUMITE "
	cWhere += " AND C35.C35_CODITE  = C30.C30_CODITE "
	cWhere += " AND C35.C35_CODTRI  = '000002' "

	If cCol == "B"
		cWhere += " AND C35.C35_CODANT  = '2' "
	EndIf

	cWhere += " AND C20.D_E_L_E_T_  = '' "
	cWhere += " AND C30.D_E_L_E_T_  = '' "
	cWhere += " AND C35.D_E_L_E_T_  = '' "

	cSelect      := "%" + cSelect    + "%"
	cFrom        := "%" + cFrom      + "%"
	cWhere       := "%" + cWhere     + "%"

	BeginSql Alias cAliasQry
       SELECT
             %Exp:cSelect%
       FROM
             %Exp:cFrom%
       WHERE
             %Exp:cWhere%
	EndSql

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	Return (cAliasQry)->VALOR

	(cAliasQry)->(DbCloseArea())

Return 0
