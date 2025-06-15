#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFODB           
Gera o registro ODB da DIEF-CE 
Registro tipo ODB - Outros D�bitos

@Param aWizard	->	Array com as informacoes da Wizard

@author David Costa
@since  03/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFODB( aWizard, cRegime, cJobAux )

Local cNomeReg	:= "ODB"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local cAliasQry	:= GetNextAlias()
Local nHandle		:=	MsFCreate( cTxtSys )
Local oLastError := ErrorBlock({|e| AddLogDIEF("N�o foi poss�vel montar o registro ODB, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})
Local lError		:= .F.

Begin Sequence
	
	QryODB( cAliasQry, aWizard )
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	While !( cAliasQry )->( Eof() )
	
		cStrReg	:= cNomeReg
		cStrReg	+= GetEspe(cAliasQry)										//C�digo da esp�cie do d�bito
		cStrReg	+= TAFDecimal((cAliasQry)->C2T_VLRAJU, 13, 2, Nil)		//Valor do d�bito
		cStrReg	+= CRLF
		
		AddLinDIEF( )
	
		WrtStrTxt( nHandle, cStrReg )
	
		lError := lError .Or. TAFDFIDA( nHandle, cAliasQry )
		
		( cAliasQry )->( dbSkip() )
		
	EndDo
	
	( cAliasQry )->( dbCloseArea())
	
	GerTxtReg( nHandle, cTXTSys, cNomeReg )

	If( lError )
		//Status 9 - Indica ocorr�ncia de erro no processamento
		PutGlbValue( cJobAux , "9" )
		GlbUnlock()
	Else
		//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
		PutGlbValue( cJobAux , "1" )
		GlbUnlock()
	EndIf
	
Recover
	//Status 9 - Indica ocorr�ncia de erro no processamento
	PutGlbValue( cJobAux , "9" )
	GlbUnlock()

End Sequence

ErrorBlock(oLastError)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QryODB             
Seleciona os dados para gera��o do registro ODB 

@author David Costa
@since  03/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function QryODB( cAliasQry, aWizard )

Local dDataIni 	:= aWizard[1][5]
Local dDataFim	:= aWizard[1][6]
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""

cSelect 	:= " CHY_CODIGO, C2T_VLRAJU, C2T_ID, C2T_CODAJU "
cFrom   	:= RetSqlName("C2S") + " C2S "
cFrom   	+= " JOIN " + RetSqlName("C2T") + " C2T "
cFrom   	+= " 	JOIN " + RetSqlName("CHY") + " CHY "
cFrom   	+= " 		ON CHY_ID = C2T_IDSUBI "
cFrom   	+= " 		AND CHY.D_E_L_E_T_ = '' "
cFrom   	+= " 	ON C2T_ID = C2S_ID "
cFrom   	+= " 	AND C2T_FILIAL = C2S_FILIAL "
cFrom   	+= " 	AND C2T.D_E_L_E_T_ = '' "
cWhere  	:= " C2S_DTINI >= '" +  DToS(dDataIni) + "' "
cWhere  	+= " AND C2S_DTFIN <= '" +  DToS(dDataFim) + "' "
cWhere  	+= " AND C2S_FILIAL = '" + xFilial( "C2S" ) + "' "
cWhere  	+= " AND C2S.D_E_L_E_T_ = '' "
cWhere  	+= " AND CHY_CODIGO IN ('01518', '01519', '01520', '01521', '01522', '01523', '01524', "
cWhere  	+= " '01525', '01526', '01527', '01528', '01529', '01530') "  

cSelect 	:= "%" + cSelect 		+ "%"
cFrom   	:= "%" + cFrom   		+ "%"
cWhere  	:= "%" + cWhere   	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
EndSql

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetEspe             
C�digo da esp�cie do d�bito, vide tabela 09.

01	D�bito Reserva Transfer�ncia de Cr�dito.
02	D�bito Diferen�ial de Al�quota.
03	D�bito Transfer�ncia de Cr�dito.
04	D�bito compensa��o de D�bitos na D�vida Ativa
06	Estorno cr�dito Sa�das Isentas ou n�o tributadas
07	Estorno cr�dito bens de Ativo por Sa�das n�o tributadas
08	Estorno cr�dito Suframa.
09	Estorno de Cr�dito de Bens do Ativo por Baixa
10	FECOP ICMS Normal
11	Devolu��o de Compras (somente EPP e ME)
12	Diferen�a de Cart�o de Cr�dito
98	D�bito Outros
99	Estornos cr�dito Outros

@author David Costa
@since 03/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetEspe( cAliasQry )

Local cEspe	:= ""

Do Case
	//01	D�bito Reserva Transfer�ncia de Cr�dito.
	Case (cAliasQry)->CHY_CODIGO == "01518"
		cEspe := "01"
	//02	D�bito Diferen�ial de Al�quota.
	Case (cAliasQry)->CHY_CODIGO == "01519"
		cEspe := "02"
	//03	D�bito Transfer�ncia de Cr�dito.
	Case (cAliasQry)->CHY_CODIGO == "01520"
		cEspe := "03"
	//04	D�bito compensa��o de D�bitos na D�vida Ativa
	Case (cAliasQry)->CHY_CODIGO == "01521"
		cEspe := "04"
	//06	Estorno cr�dito Sa�das Isentas ou n�o tributadas
	Case (cAliasQry)->CHY_CODIGO == "01522"
		cEspe := "06"
	//07	Estorno cr�dito bens de Ativo por Sa�das n�o tributadas
	Case (cAliasQry)->CHY_CODIGO == "01523"
		cEspe := "07"
	//08	Estorno cr�dito Suframa.
	Case (cAliasQry)->CHY_CODIGO == "01524"
		cEspe := "08"
	//09	Estorno de Cr�dito de Bens do Ativo por Baixa
	Case (cAliasQry)->CHY_CODIGO == "01525"
		cEspe := "09"
	//10	FECOP ICMS Normal
	Case (cAliasQry)->CHY_CODIGO == "01526"
		cEspe := "10"
	//11	Devolu��o de Compras (somente EPP e ME)
	Case (cAliasQry)->CHY_CODIGO == "01527"
		cEspe := "11"
	//12	Diferen�a de Cart�o de Cr�dito
	Case (cAliasQry)->CHY_CODIGO == "01528"
		cEspe := "12"
	//98	D�bito Outros
	Case (cAliasQry)->CHY_CODIGO == "01529"
		cEspe := "98"
	//99	Estornos cr�dito Outros
	Case (cAliasQry)->CHY_CODIGO == "01530"
		cEspe := "99"
	OtherWise
		cEspe := "00" 
EndCase

Return( cEspe )