#Include "Protheus.ch"

#Define nCommit 500 //Limite da string a ser confirmada na tabela( Desenvolver tratamento )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFECFN

Rotina extratora da informacoes para o Bloco N do ECF.

@Param	cTABCTL	->	Nome da tabela de controle de transa��es
		aWizard	->	Array com as informacoes da Wizard
		cFilSel	->	Filiais selecionadas para o processamento
		cJobAux	->	Respons�vel pelo controle de t�rmino do Bloco - Multi Thread

@obs Luccas ( 31/03/2016 ): Devido a mudan�a em rela��o ao compartilhamento das tabelas
do TAF ( inicialmente todas eram exclusivas, mas o cliente pode optar por ter tabelas
compartilhadas, por exemplo Plano de Contas, Centro de Custo, Itens, etc. ), as rotinas
de gera��o das obriga��es tiveram que ser alteradas ( em algumas situa��es ) para a
utiliza��o da fun��o xFilial ao inv�s da vari�vel cFilSel.
O conte�do desta vari�vel � o mesmo de cFilAnt, pois a ECF n�o fornece a op��o
de ser gerada para v�rias filiais, ela � gerada a partir da filial logada que
deve ser a Matriz ou SCP.
A vari�vel cFilSel foi mantida no programa de gera��o do arquivo por compatibilidade
de fun��es e para preenchimento do campo FILIAL da tabela TAFECF_XX.

@Author Felipe C. Seolin
@Since 17/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFECFN( cTABCTL, aWizard, cFilSel, cJobAux )

Local oError		:=	ErrorBlock( { |Obj| TAFConout( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description,3,.T.,"ECF" ) } )
Local cBloco		:=	"N"
Local cIndMov		:=	"1"
Local cFil			:=	TurnFilObr( cFilSel )
Local nSeq			:=	2
Local aECFInfo	:=	{ cFil, DToS( aWizard[1,1] ), DToS( aWizard[1,2] ), cBloco }
Local lFound		:=	.T.

//Tratamento para exibi��o de mensagem para o usu�rio final, caso ocorra erro durante o processamento
Begin Sequence

	RegN030( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )

	//Executo Registro 001 por ultimo para saber se houve movimento no Bloco
	RegN001( aECFInfo, cIndMov )

Recover
	lFound := .F.

End Sequence

//Tratamento para ocorr�ncia de erros durante o processamento
ErrorBlock( oError )

If !lFound
	//Status 9 - Indica ocorr�ncia de erro no processamento
	PutGlbValue( cJobAux , "9" )
	GlbUnlock()

Else
	//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
	PutGlbValue( cJobAux , "1" )
	GlbUnlock()

	//Altera o Status da tabela de controle para 2, indicando que o bloco foi processado
	xTafCTLObr( "2", cBloco, aWizard, cFilSel,, cTABCTL, "ECF" )
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegN001

Rotina para extrair e gravar as informacoes do Registro N001.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 17/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegN001( aECFInfo, cIndMov )

Local cDelimit := "|"
Local cStrTxt  := ""

cStrTxt := cDelimit + "N001"	//01 - REG
cStrTxt += cDelimit + cIndMov	//02 - IND_DAD
cStrTxt += cDelimit

FExecSQL( aECFInfo, 1, "N001", cStrTxt )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegN030

Rotina para extrair e gravar as informacoes do Registro N030 e seus filhos.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 17/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegN030( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cPeriodo  := ""
Local cAliasQry := GetNextAlias()

ECFQryN( cAliasQry, aWizard, cFilSel )

//Registro N030
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "N030"										//01 - REG
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CEA_DTINI )		//02 - DT_INI
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CEA_DTFIN )		//03 - DT_FIN
	cStrTxt += cDelimit + ( cAliasQry )->CAH_CODIGO					//04 - PER_APUR
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "N030", cStrTxt )

	nSeq ++

	cPeriodo := ( cAliasQry )->CEA_DTINI + ( cAliasQry )->CEA_DTFIN + ( cAliasQry )->CAH_CODIGO

	While ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->CEA_DTINI + ( cAliasQry )->CEA_DTFIN + ( cAliasQry )->CAH_CODIGO == cPeriodo

		//Registro N500
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N500"

			If !Empty( ( cAliasQry )->N500_CH6_CODIGO )

				cStrTxt := cDelimit + "N500"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N500_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N500_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->N500_CEB_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N500", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro N600
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N600"

			If !Empty( ( cAliasQry )->N600_CH6_CODIGO )

				cStrTxt := cDelimit + "N600"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N600_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N600_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->N600_CEB_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N600", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro N610
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N610"

			If !Empty( ( cAliasQry )->N610_CH6_CODIGO )

				cStrTxt := cDelimit + "N610"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N610_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N610_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->N610_CEB_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N610", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro N615
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N615"

			If !Empty( ( cAliasQry )->CEC_BCALC )

				cStrTxt := cDelimit + "N615"									 			//01 - REG
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_BCALC, 16, 2 )		//02 - BASE_CALC
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_PFINOR, 5, 2 )		//03 - PER_INCEN_FINOR
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_VFINOR, 16, 2 )		//04 - VL_LIQ_INCEN_FINOR
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_PFINAN, 5, 2 )		//05 - PER_INCEN_FINAM
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_VFINAN, 16, 2 )		//06 - VL_LIQ_INCEN_FINAM
				If aWizard[1][5] == '0001'
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_SUBTOT, 16, 2 )		//07 - VL_SUBTOTAL
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_PERSUB, 16, 2 )		//08 - PER_VL_SUBTOTAL
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_PFUNRE, 5, 2 )		//09 - PER_INCEN_FUNRES
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_VFUNRE, 16, 2 )		//10 - VL_LIQ_INCEN_FUNRES
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_TOTAL, 16, 2 )		//11 - VL_TOTAL
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_PERTOT, 16, 2 )		//12 - PER_VL_TOTAL
				ELse
					//A partir de 2015 o registro N615 possui somente 7 campos.
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_TOTAL, 16, 2 )		//07 - VL_TOTAL				
				EndIF
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N615", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro N620
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N620"

			If !Empty( ( cAliasQry )->N620_CH6_CODIGO )

				cStrTxt := cDelimit + "N620"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N620_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N620_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->N620_CEB_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N620", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro N630
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N630"

			If !Empty( ( cAliasQry )->N630_CH6_CODIGO )

				cStrTxt := cDelimit + "N630"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N630_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N630_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->N630_CEB_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N630", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro N650
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N650"

			If !Empty( ( cAliasQry )->N650_CH6_CODIGO )

				cStrTxt := cDelimit + "N650"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N650_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N650_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->N650_CEB_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N650", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro N660
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N660"

			If !Empty( ( cAliasQry )->N660_CH6_CODIGO )

				cStrTxt := cDelimit + "N660"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N660_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N660_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->N660_CEB_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N660", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro N670
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N670"

			If !Empty( ( cAliasQry )->N670_CH6_CODIGO )

				cStrTxt := cDelimit + "N670"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N670_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N670_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->N670_CEB_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N670", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

	EndDo

EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ECFQryN

Executa a Query principal para a extracao do Bloco N do ECF.

@Param cAliasQry -> Alias para gravacao da Query
       aWizard   -> Array com as informacoes da Wizard
       cFilSel   -> Filiais selecionadas para o processamento

@Author Felipe C. Seolin
@Since 17/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ECFQryN( cAliasQry, aWizard, cFilSel )

Local cSelect  := cSelect2 := cSelect3 := cSelect4 := cSelect5 := cSelect6 := cSelect7 := cSelect8 := cSelect9 := ""
Local cFrom    := cFrom2   := cFrom3   := cFrom4   := cFrom5   := cFrom6   := cFrom7   := cFrom8   := cFrom9   := ""
Local cWhere   := cWhere2  := cWhere3  := cWhere4  := cWhere5  := cWhere6  := cWhere7  := cWhere8  := cWhere9  := ""
Local cOrderBy := ""

//Registro N500

cSelect := "  'N500' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect += ", CH6.CH6_CODIGO N500_CH6_CODIGO, CH6.CH6_DESCRI N500_CH6_DESCRI, CEB.CEB_VALOR N500_CEB_VALOR "
cSelect += ", '' N600_CH6_CODIGO, '' N600_CH6_DESCRI, 0 N600_CEB_VALOR "
cSelect += ", '' N610_CH6_CODIGO, '' N610_CH6_DESCRI, 0 N610_CEB_VALOR "
cSelect += ", 0 CEC_BCALC, 0 CEC_PFINOR, 0 CEC_VFINOR, 0 CEC_PFINAN, 0 CEC_VFINAN, 0 CEC_SUBTOT, 0 CEC_PERSUB, 0 CEC_PFUNRE , 0 CEC_VFUNRE , 0 CEC_TOTAL, 0 CEC_PERTOT "
cSelect += ", '' N620_CH6_CODIGO, '' N620_CH6_DESCRI, 0 N620_CEB_VALOR "
cSelect += ", '' N630_CH6_CODIGO, '' N630_CH6_DESCRI, 0 N630_CEB_VALOR "
cSelect += ", '' N650_CH6_CODIGO, '' N650_CH6_DESCRI, 0 N650_CEB_VALOR "
cSelect += ", '' N660_CH6_CODIGO, '' N660_CH6_DESCRI, 0 N660_CEB_VALOR "
cSelect += ", '' N670_CH6_CODIGO, '' N670_CH6_DESCRI, 0 N670_CEB_VALOR "

cFrom := RetSqlName( "CEA" ) + " CEA "

cFrom += "LEFT JOIN " + RetSqlName( "CEB" ) + " CEB "
cFrom += "  ON CEB.CEB_FILIAL = CEA.CEA_FILIAL "
cFrom += " AND CEB.CEB_ID = CEA.CEA_ID "
cFrom += " AND CEB.CEB_REGECF = '01' "
cFrom += " AND CEB.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom += " AND CAH.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom += " AND CH6.CH6_ID = CEB.CEB_IDCODL "
cFrom += " AND CH6.D_E_L_E_T_ = '' "

//cWhere := "    CEA.CEA_FILIAL IN (" + cFilSel + ") "
cWhere := "    CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere += "AND CEA.D_E_L_E_T_ = '' "

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"

//Registro N600

cSelect2 := "  'N600' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect2 += ", '', '', 0 "
cSelect2 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEB.CEB_VALOR "
cSelect2 += ", '', '', 0 "
cSelect2 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "
cSelect2 += ", '', '', 0 "
cSelect2 += ", '', '', 0 "
cSelect2 += ", '', '', 0 "
cSelect2 += ", '', '', 0 "
cSelect2 += ", '', '', 0 "

cFrom2 := RetSqlName( "CEA" ) + " CEA "

cFrom2 += "LEFT JOIN " + RetSqlName( "CEB" ) + " CEB "
cFrom2 += "  ON CEB.CEB_FILIAL = CEA.CEA_FILIAL "
cFrom2 += " AND CEB.CEB_ID = CEA.CEA_ID "
cFrom2 += " AND CEB.CEB_REGECF = '02' "
cFrom2 += " AND CEB.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom2 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom2 += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom2 += " AND CAH.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom2 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom2 += " AND CH6.CH6_ID = CEB.CEB_IDCODL "
cFrom2 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere2 := "    CEA.CEA_FILIAL IN (" + cFilSel + ") "
cWhere2 := "    CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere2 += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere2 += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere2 += "AND CEA.D_E_L_E_T_ = '' "

cSelect2 := "%" + cSelect2 + "%"
cFrom2   := "%" + cFrom2   + "%"
cWhere2  := "%" + cWhere2  + "%"

//Registro N610

cSelect3 := "  'N610' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect3 += ", '', '', 0 "
cSelect3 += ", '', '', 0 "
cSelect3 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEB.CEB_VALOR "
cSelect3 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "
cSelect3 += ", '', '', 0 "
cSelect3 += ", '', '', 0 "
cSelect3 += ", '', '', 0 "
cSelect3 += ", '', '', 0 "
cSelect3 += ", '', '', 0 "

cFrom3 := RetSqlName( "CEA" ) + " CEA "

cFrom3 += "LEFT JOIN " + RetSqlName( "CEB" ) + " CEB "
cFrom3 += "  ON CEB.CEB_FILIAL = CEA.CEA_FILIAL "
cFrom3 += " AND CEB.CEB_ID = CEA.CEA_ID "
cFrom3 += " AND CEB.CEB_REGECF = '03' "
cFrom3 += " AND CEB.D_E_L_E_T_ = '' "

cFrom3 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom3 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom3 += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom3 += " AND CAH.D_E_L_E_T_ = '' "

cFrom3 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom3 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom3 += " AND CH6.CH6_ID = CEB.CEB_IDCODL "
cFrom3 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere3 := "    CEA.CEA_FILIAL IN (" + cFilSel + ") "
cWhere3 := "    CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere3 += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere3 += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere3 += "AND CEA.D_E_L_E_T_ = '' "

cSelect3 := "%" + cSelect3 + "%"
cFrom3   := "%" + cFrom3   + "%"
cWhere3  := "%" + cWhere3  + "%"

//Registro N615

cSelect4 := "  'N615' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', 0 "
cSelect4 += ", CEC.CEC_BCALC, CEC.CEC_PFINOR, CEC.CEC_VFINOR, CEC.CEC_PFINAN, CEC.CEC_VFINAN, CEC.CEC_SUBTOT, CEC.CEC_PERSUB, CEC.CEC_PFUNRE, CEC.CEC_VFUNRE, CEC.CEC_TOTAL, CEC.CEC_PERTOT "
cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', 0 "

cFrom4 := RetSqlName( "CEA" ) + " CEA "

cFrom4 += "LEFT JOIN " + RetSqlName( "CEC" ) + " CEC "
cFrom4 += "  ON CEC.CEC_FILIAL = CEA.CEA_FILIAL "
cFrom4 += " AND CEC.CEC_ID = CEA.CEA_ID "
cFrom4 += " AND CEC.D_E_L_E_T_ = '' "

cFrom4 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom4 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom4 += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom4 += " AND CAH.D_E_L_E_T_ = '' "

//cWhere4 := "    CEA.CEA_FILIAL IN (" + cFilSel + ") "
cWhere4 := " CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere4 += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere4 += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere4 += "AND CEA.D_E_L_E_T_ = '' "

cSelect4 := "%" + cSelect4 + "%"
cFrom4   := "%" + cFrom4   + "%"
cWhere4  := "%" + cWhere4  + "%"

//Registro N620

cSelect5 := "  'N620' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect5 += ", '', '', 0 "
cSelect5 += ", '', '', 0 "
cSelect5 += ", '', '', 0 "
cSelect5 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "
cSelect5 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEB.CEB_VALOR "
cSelect5 += ", '', '', 0 "
cSelect5 += ", '', '', 0 "
cSelect5 += ", '', '', 0 "
cSelect5 += ", '', '', 0 "

cFrom5 := RetSqlName( "CEA" ) + " CEA "

cFrom5 += "LEFT JOIN " + RetSqlName( "CEB" ) + " CEB "
cFrom5 += "  ON CEB.CEB_FILIAL = CEA.CEA_FILIAL "
cFrom5 += " AND CEB.CEB_ID = CEA.CEA_ID "
cFrom5 += " AND CEB.CEB_REGECF = '04' "
cFrom5 += " AND CEB.D_E_L_E_T_ = '' "

cFrom5 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom5 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom5 += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom5 += " AND CAH.D_E_L_E_T_ = '' "

cFrom5 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom5 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom5 += " AND CH6.CH6_ID = CEB.CEB_IDCODL "
cFrom5 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere5 := "    CEA.CEA_FILIAL IN (" + cFilSel + ") "
cWhere5 := " CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere5 += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere5 += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere5 += "AND CEA.D_E_L_E_T_ = '' "

cSelect5 := "%" + cSelect5 + "%"
cFrom5   := "%" + cFrom5   + "%"
cWhere5  := "%" + cWhere5  + "%"

//Registro N630

cSelect6 := "  'N630' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect6 += ", '', '', 0 "
cSelect6 += ", '', '', 0 "
cSelect6 += ", '', '', 0 "
cSelect6 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "
cSelect6 += ", '', '', 0 "
cSelect6 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEB.CEB_VALOR "
cSelect6 += ", '', '', 0 "
cSelect6 += ", '', '', 0 "
cSelect6 += ", '', '', 0 "

cFrom6 := RetSqlName( "CEA" ) + " CEA "

cFrom6 += "LEFT JOIN " + RetSqlName( "CEB" ) + " CEB "
cFrom6 += "  ON CEB.CEB_FILIAL = CEA.CEA_FILIAL "
cFrom6 += " AND CEB.CEB_ID = CEA.CEA_ID "
cFrom6 += " AND CEB.CEB_REGECF = '05' "
cFrom6 += " AND CEB.D_E_L_E_T_ = '' "

cFrom6 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom6 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom6 += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom6 += " AND CAH.D_E_L_E_T_ = '' "

cFrom6 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom6 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom6 += " AND CH6.CH6_ID = CEB.CEB_IDCODL "
cFrom6 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere6 := "    CEA.CEA_FILIAL IN (" + cFilSel + ") "
cWhere6 := " CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere6 += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere6 += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere6 += "AND CEA.D_E_L_E_T_ = '' "

cSelect6 := "%" + cSelect6 + "%"
cFrom6   := "%" + cFrom6   + "%"
cWhere6  := "%" + cWhere6  + "%"

//Registro N650

cSelect7 := "  'N650' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect7 += ", '', '', 0 "
cSelect7 += ", '', '', 0 "
cSelect7 += ", '', '', 0 "
cSelect7 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "
cSelect7 += ", '', '', 0 "
cSelect7 += ", '', '', 0 "
cSelect7 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEB.CEB_VALOR "
cSelect7 += ", '', '', 0 "
cSelect7 += ", '', '', 0 "

cFrom7 := RetSqlName( "CEA" ) + " CEA "

cFrom7 += "LEFT JOIN " + RetSqlName( "CEB" ) + " CEB "
cFrom7 += "  ON CEB.CEB_FILIAL = CEA.CEA_FILIAL "
cFrom7 += " AND CEB.CEB_ID = CEA.CEA_ID "
cFrom7 += " AND CEB.CEB_REGECF = '07' "
cFrom7 += " AND CEB.D_E_L_E_T_ = '' "

cFrom7 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom7 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom7 += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom7 += " AND CAH.D_E_L_E_T_ = '' "

cFrom7 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom7 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom7 += " AND CH6.CH6_ID = CEB.CEB_IDCODL "
cFrom7 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere7 := "    CEA.CEA_FILIAL IN (" + cFilSel + ") "
cWhere7 := " CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere7 += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere7 += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere7 += "AND CEA.D_E_L_E_T_ = '' "

cSelect7 := "%" + cSelect7 + "%"
cFrom7   := "%" + cFrom7   + "%"
cWhere7  := "%" + cWhere7  + "%"

//Registro N660

cSelect8 := "  'N660' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect8 += ", '', '', 0 "
cSelect8 += ", '', '', 0 "
cSelect8 += ", '', '', 0 "
cSelect8 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "
cSelect8 += ", '', '', 0 "
cSelect8 += ", '', '', 0 "
cSelect8 += ", '', '', 0 "
cSelect8 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEB.CEB_VALOR "
cSelect8 += ", '', '', 0 "

cFrom8 := RetSqlName( "CEA" ) + " CEA "

cFrom8 += "LEFT JOIN " + RetSqlName( "CEB" ) + " CEB "
cFrom8 += "  ON CEB.CEB_FILIAL = CEA.CEA_FILIAL "
cFrom8 += " AND CEB.CEB_ID = CEA.CEA_ID "
cFrom8 += " AND CEB.CEB_REGECF = '08' "
cFrom8 += " AND CEB.D_E_L_E_T_ = '' "

cFrom8 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom8 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom8 += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom8 += " AND CAH.D_E_L_E_T_ = '' "

cFrom8 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom8 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom8 += " AND CH6.CH6_ID = CEB.CEB_IDCODL "
cFrom8 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere8 := "    CEA.CEA_FILIAL IN (" + cFilSel + ") "
cWhere8 := " CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere8 += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere8 += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere8 += "AND CEA.D_E_L_E_T_ = '' "

cSelect8 := "%" + cSelect8 + "%"
cFrom8   := "%" + cFrom8   + "%"
cWhere8  := "%" + cWhere8  + "%"

//Registro N670

cSelect9 := "  'N670' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect9 += ", '', '', 0 "
cSelect9 += ", '', '', 0 "
cSelect9 += ", '', '', 0 "
cSelect9 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "
cSelect9 += ", '', '', 0 "
cSelect9 += ", '', '', 0 "
cSelect9 += ", '', '', 0 "
cSelect9 += ", '', '', 0 "
cSelect9 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEB.CEB_VALOR "

cFrom9 := RetSqlName( "CEA" ) + " CEA "

cFrom9 += "LEFT JOIN " + RetSqlName( "CEB" ) + " CEB "
cFrom9 += "  ON CEB.CEB_FILIAL = CEA.CEA_FILIAL "
cFrom9 += " AND CEB.CEB_ID = CEA.CEA_ID "
cFrom9 += " AND CEB.CEB_REGECF = '09' "
cFrom9 += " AND CEB.D_E_L_E_T_ = '' "

cFrom9 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom9 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom9 += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom9 += " AND CAH.D_E_L_E_T_ = '' "

cFrom9 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom9 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom9 += " AND CH6.CH6_ID = CEB.CEB_IDCODL "
cFrom9 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere9 := "    CEA.CEA_FILIAL IN (" + cFilSel + ") "
cWhere9 := " CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere9 += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere9 += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere9 += "AND CEA.D_E_L_E_T_ = '' "

cSelect9 := "%" + cSelect9 + "%"
cFrom9   := "%" + cFrom9   + "%"
cWhere9  := "%" + cWhere9  + "%"

//Ordenacao da Query

cOrderBy := "CEA_FILIAL, CAH_CODIGO, REGISTRO "

cOrderBy := "%" + cOrderBy + "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%

	UNION

	SELECT
		%Exp:cSelect2%
	FROM
		%Exp:cFrom2%
	WHERE
		%Exp:cWhere2%

	UNION

	SELECT
		%Exp:cSelect3%
	FROM
		%Exp:cFrom3%
	WHERE
		%Exp:cWhere3%

	UNION

	SELECT
		%Exp:cSelect4%
	FROM
		%Exp:cFrom4%
	WHERE
		%Exp:cWhere4%

	UNION

	SELECT
		%Exp:cSelect5%
	FROM
		%Exp:cFrom5%
	WHERE
		%Exp:cWhere5%

	UNION

	SELECT
		%Exp:cSelect6%
	FROM
		%Exp:cFrom6%
	WHERE
		%Exp:cWhere6%

	UNION

	SELECT
		%Exp:cSelect7%
	FROM
		%Exp:cFrom7%
	WHERE
		%Exp:cWhere7%

	UNION

	SELECT
		%Exp:cSelect8%
	FROM
		%Exp:cFrom8%
	WHERE
		%Exp:cWhere8%

	UNION

	SELECT
		%Exp:cSelect9%
	FROM
		%Exp:cFrom9%
	WHERE
		%Exp:cWhere9%

	ORDER BY
		%Exp:cOrderBy%

EndSql

Return() 
