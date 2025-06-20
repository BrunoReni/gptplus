#INCLUDE "PROTHEUS.CH" 
#INCLUDE "REPORT.CH"
#INCLUDE "CNTR121.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CNTR121   �Autor  �Rogerio Melonio        �Data  �22/09/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relatorio de medicoes naoefetuadas                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CNTR121()
	Local oReport
	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef �Autor  �Rogerio Melonio        �Data  �25/09/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relatorio de medicoes naoefetuadas                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
	Local oCN9
	Local oPlanTot
	Local oPlanDet

	oReport := TReport():New("CNTR121",STR0001 ,"CNTR121",{|oReport| ReportPrint(oReport)},STR0002)//Medi��es n�o Efetuadas
	Pergunte("CNTR121",.F.)

	oCN9 := TRSection():New(oReport, STR0003,{"CN9","CN1"})

	TRCell():New(oCN9,"CN9_FILCTR","CN9")
	TRCell():New(oCN9,"FILNAME",,"")
	TRCell():New(oCN9,"CN9_NUMERO","CN9")
	TRCell():New(oCN9,"CN9_REVISA","CN9")
	TRCell():New(oCN9,"CN9_ESPCTR","CN9", STR0004 + CRLF + STR0003)
	TRCell():New(oCN9,"CN9_TPCTO" ,"CN9", STR0005 + CRLF + STR0003)
	TRCell():New(oCN9,"CN1_DESCRI","CN1")
	TRCell():New(oCN9,"CN9_SITUAC","CN9")

	oPlanTot := TRSection():New(oCN9, STR0006,{"CNA"})

	TRCell():New(oPlanTot,"CNA_NUMERO","CNA")
	TRCell():New(oPlanTot,"A2_NOME",, STR0007)
	TRCell():New(oPlanTot,"CNA_TIPPLA","CNA")
	TRCell():New(oPlanTot,"CNL_DESCRI","CNL")
	TRCell():New(oPlanTot,"QTAMED",, STR0008 + CRLF + STR0009)
	TRCell():New(oPlanTot,"VLAMED",, STR0010,PesqPict("CNA","CNA_VLTOT"))

	oPlanDet := TRSection():New(oPlanTot, STR0011,{"CNA","CNF"})
	TRCell():New(oPlanDet,"COMPET"		,, STR0012)
	TRCell():New(oPlanDet,"CNA_PROMED"	,, STR0013)
	TRCell():New(oPlanDet,"CNA_PROPAR"	,, STR0014 + CRLF + STR0015)
	TRCell():New(oPlanDet,"VLRPREV"		,, STR0016,PesqPict("CNA","CNA_VLTOT"))

Return oReport

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportPrint�Autor �Rogerio Melonio        �Data  �25/09/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Seleciona os contratos                                     ���
���          � Imprime o Relatorio tReport                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CNTR121                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport)
Local cSql  := ""
Local cSql2 := ""
Local oCN9     := oReport:Section(1)
Local oPlanTot := oReport:Section(1):Section(1)
Local oPlanDet := oReport:Section(1):Section(1):Section(1)
Local nX := 0
Local nQtdNaoMed 	:= 0
Local nVlrNaoMed 	:= 0
Local cAliasQry	 	:= GetNextAlias()
Local lRecorre		:= .F.
Local lExclCNL		:= FWModeAccess("CNL",1)+FWModeAccess("CNL",2)+FWModeAccess("CNL",3) == "EEE"
Local lExclCN1		:= FWModeAccess("CN1",1)+FWModeAccess("CN1",2)+FWModeAccess("CN1",3) == "EEE"
Local cFilCNL		:= IIF(lExclCNL, '%CN9_FILIAL%', xFilial("CNL"))//Se for exclusivo, faz o JOIN com a filial do Contrato
Local cFilCN1		:= IIF(lExclCN1, '%CN9_FILIAL%', xFilial("CN1"))//Se for exclusivo, faz o JOIN com a filial do Contrato

MakeSqlExp("CNTR121")

//- Filtra contrato por especie - 1 = Compra, 2 = Venda, 3 = Ambos
If !Empty(mv_par01) .And. mv_par01 <= 2
	cSql += " AND CN9_ESPCTR = '" + AllTrim(Str(mv_par01)) + "'"
EndIf

//- Filtra contrato por filiais
cSql += " AND CN9_FILCTR >= '" + mv_par02 + "' "
cSql += " AND CN9_FILCTR <= '" + mv_par03 + "' "

//- Filtra planilha por cliente
cSql += " AND CNA_CLIENT >= '" + mv_par04 + "' "
cSql += " AND CNA_CLIENT <= '" + mv_par06 + "' "

//- Filtra planilha por loja do cliente
cSql += " AND CNA_LOJACL >= '" + mv_par05 + "' "
cSql += " AND CNA_LOJACL <= '" + mv_par07 + "' "

//- Filtra planilha por fornecedor
cSql += " AND CNA_FORNEC >= '" + mv_par08 + "' "
cSql += " AND CNA_FORNEC <= '" + mv_par10 + "' "

//- Filtra planilha por loja do fornecedor
cSql += " AND CNA_LJFORN >= '" + mv_par09 + "' "
cSql += " AND CNA_LJFORN <= '" + mv_par11 + "' "

//- Filtra contratos
cSql += " AND CN9_NUMERO >= '" + mv_par12 + "' "
cSql += " AND CN9_NUMERO <= '" + mv_par13 + "' "

cSql2 := cSql

cSql  += " AND ( CNA_PROMED >= '" + Dtos(mv_par14) + "' AND CNA_PROMED <= '" + Dtos(mv_par15) + "' OR "
cSql  += " ( CNA_ULTMED < '" + Dtos(mv_par14) + "' AND CNA_ULTMED <> '' ) )"
cSql2 += " AND CNF_PRUMED >= '" + Dtos(mv_par14) + "' AND CNF_PRUMED <= '" + Dtos(mv_par15) + "' "

cSql  := "%"+cSql+"%"
cSql2 := "%"+cSql2+"%"

If mv_par16 = 1
	BeginSql alias cAliasQry
		SELECT DISTINCT * FROM
			(
			SELECT
				CN9_FILCTR,
				CN9_NUMERO,
				CN9_REVISA,
				CN9_TPCTO,
				CN9_ESPCTR,
				CN9_SITUAC,

				CN1_DESCRI,
				CN1_MEDEVE,

				CNA_CONTRA,
				CNA_FORNEC,
				CNA_LJFORN,
				CNA_CLIENT,
				CNA_LOJACL,
				CNL_MEDEVE

				FROM
					%table:CN9% CN9,
					%table:CNA% CNA,
					%table:CN1% CN1,
					%table:CNL% CNL

				WHERE
						CN9.%notDel%
					AND CN9.CN9_SITUAC IN ('05','06')

					AND CNA.%notDel%
					AND CNA.CNA_FILIAL = CN9.CN9_FILIAL
					AND CNA.CNA_CONTRA = CN9.CN9_NUMERO
					AND CNA.CNA_REVISA = CN9.CN9_REVISA
					AND CNA.CNA_PERIOD <> ''

					AND CNL.%notDel%
					AND CNL.CNL_FILIAL = %exp:cFilCNL%
					AND CNL.CNL_CODIGO = CNA.CNA_TIPPLA

					AND CN1.%notDel%
					AND	CN1.CN1_FILIAL = %exp:cFilCN1%
					AND CN1.CN1_CODIGO = CN9.CN9_TPCTO
					%exp:cSql%

				UNION ALL

				SELECT
					CN9_FILCTR,
					CN9_NUMERO,
					CN9_REVISA,
					CN9_TPCTO,
					CN9_ESPCTR,
					CN9_SITUAC,

					CN1_DESCRI,
					CN1_MEDEVE,

					CNA_CONTRA,
					CNA_FORNEC,
					CNA_LJFORN,
					CNA_CLIENT,
					CNA_LOJACL,

					CNL_MEDEVE

				FROM
					%table:CN9% CN9,
					%table:CNA% CNA,
					%table:CN1% CN1,
					%table:CNF% CNF,
					%table:CNL% CNL

				WHERE
						CN9.%notDel%
					AND CN9.CN9_SITUAC IN ('05','06')

					AND CNA.%notDel%
					AND	CNA.CNA_FILIAL = CN9.CN9_FILIAL
					AND CNA.CNA_CONTRA = CN9.CN9_NUMERO
					AND CNA.CNA_REVISA = CN9.CN9_REVISA
					AND CNA.CNA_PERIOD = ''

					AND CNL.%notDel%
					AND	CNL.CNL_FILIAL = %exp:cFilCNL%
					AND CNL.CNL_CODIGO = CNA.CNA_TIPPLA

					AND CN1.%notDel%
					AND	CN1.CN1_FILIAL = %exp:cFilCN1%
					AND CN1.CN1_CODIGO = CN9.CN9_TPCTO

					AND CNF.%notDel%
					AND	CNF.CNF_FILIAL = CN9.CN9_FILIAL
					AND CNF.CNF_CONTRA = CN9.CN9_NUMERO
					AND CNF.CNF_REVISA = CN9.CN9_REVISA
					AND CNF.CNF_NUMPLA = CNA.CNA_NUMERO
					AND CNF.CNF_SALDO > 0

					%exp:cSql2%
				) RESUMO
		WHERE
			(RESUMO.CN1_MEDEVE <> '1' AND RESUMO.CNL_MEDEVE <> '1')
			OR
			(RESUMO.CNL_MEDEVE <> '1' )

		ORDER BY
			RESUMO.CN9_FILCTR,
			RESUMO.CN9_NUMERO
	EndSql
Else
	If mv_par17 = 1

		BeginSql alias cAliasQry
			SELECT DISTINCT * FROM
				(
				SELECT DISTINCT
					CN9_FILCTR,
					CN9_NUMERO,
					CN9_REVISA,
					CN9_ESPCTR,
					CN9_TPCTO,
					CN9_SITUAC,

					CN1_DESCRI,
					CN1_MEDEVE,

					CNA_CONTRA,
					CNA_NUMERO,
					CNA_TIPPLA,
					CNA_PERIOD,
					CNA_FORNEC,
					CNA_LJFORN,
					CNA_CLIENT,
					CNA_LOJACL,

					CNL_DESCRI,
					CNL_MEDEVE

				FROM
					%table:CN9% CN9,
					%table:CNA% CNA,
					%table:CN1% CN1,
					%table:CNL% CNL

				WHERE
					CN9.%notDel%
					AND CN9.CN9_SITUAC IN ('05','06')

					AND CNA.%notDel%
					AND	CNA.CNA_FILIAL = CN9.CN9_FILIAL
					AND CNA.CNA_CONTRA = CN9.CN9_NUMERO
					AND CNA.CNA_REVISA = CN9.CN9_REVISA
					AND CNA.CNA_PERIOD <> ''

					AND CNL.%notDel%
					AND	CNL.CNL_FILIAL = %exp:cFilCNL%
					AND CNL.CNL_CODIGO = CNA.CNA_TIPPLA

					AND CN1.%notDel%
					AND CN1.CN1_FILIAL = %exp:cFilCN1%
					AND CN1.CN1_CODIGO = CN9.CN9_TPCTO
					%exp:cSql%

				UNION ALL

				SELECT DISTINCT
					CN9_FILCTR,
					CN9_NUMERO,
					CN9_REVISA,
					CN9_ESPCTR,
					CN9_TPCTO,
					CN9_SITUAC,

					CN1_DESCRI,
					CN1_MEDEVE,

					CNA_CONTRA,
					CNA_NUMERO,
					CNA_TIPPLA,
					CNA_PERIOD,
					CNA_FORNEC,
					CNA_LJFORN,
					CNA_CLIENT,
					CNA_LOJACL,

					CNL_DESCRI,
					CNL_MEDEVE

				FROM
					%table:CN9% CN9,
					%table:CNA% CNA,
					%table:CN1% CN1,
					%table:CNL% CNL,
					%table:CNF% CNF

				WHERE
						CN9.%notDel%
					AND CN9.CN9_SITUAC IN ('05','06')

					AND CNA.%notDel%
					AND	CNA.CNA_FILIAL = CN9.CN9_FILIAL
					AND CNA.CNA_CONTRA = CN9.CN9_NUMERO
					AND CNA.CNA_REVISA = CN9.CN9_REVISA
					AND CNA.CNA_PERIOD = ''

					AND CNL.%notDel%
					AND	CNL.CNL_FILIAL = %exp:cFilCNL%
					AND CNL.CNL_CODIGO = CNA.CNA_TIPPLA

					AND CN1.%notDel%
					AND	CN1.CN1_FILIAL = %exp:cFilCN1%
					AND CN1.CN1_CODIGO = CN9_TPCTO

					AND CNF.%notDel%
					AND CNF.CNF_FILIAL = CN9.CN9_FILIAL
					AND CNF.CNF_CONTRA = CN9_NUMERO
					AND CNF.CNF_REVISA = CN9_REVISA
					AND CNF.CNF_NUMPLA = CNA.CNA_NUMERO
					AND CNF.CNF_SALDO > 0
					%exp:cSql2%
				) RESUMO

			WHERE
				(RESUMO.CN1_MEDEVE <> '1' AND RESUMO.CNL_MEDEVE <> '1')
				OR
				(RESUMO.CNL_MEDEVE <> '1')

			ORDER BY
				RESUMO.CN9_FILCTR,
				RESUMO.CN9_NUMERO,
				RESUMO.CNA_NUMERO
		EndSql

	Else

		BeginSql alias cAliasQry
			SELECT DISTINCT * FROM
				(
				SELECT
					CN9_FILCTR,
					CN9_NUMERO,
					CN9_REVISA,
					CN9_ESPCTR,
					CN9_TPCTO,
					CN9_SITUAC,

					CN1_DESCRI,
					CN1_MEDEVE,

					CNA_CONTRA,
					CNA_NUMERO,
					CNA_TIPPLA,
					CNA_CRONOG,
					CNA_PERIOD,
					CNA_FORNEC,
					CNA_LJFORN,
					CNA_CLIENT,
					CNA_LOJACL,

					CNL_DESCRI,
					CNL_MEDEVE,

					CNA_CRONOG AS CNF_NUMERO,
					'REC'  	   AS COMPET,
					CNA_PROMED AS PROMED,
					CNA_PROPAR AS PROPAR,
					CNA_VLTOT  AS VLRPREV

				FROM
					%table:CN9% CN9,
					%table:CNA% CNA,
					%table:CN1% CN1,
					%table:CNL% CNL

				WHERE
						CN9.%notDel%
					AND CN9_SITUAC IN ('05','06')

					AND	CNA_FILIAL = CN9_FILIAL
					AND CNA.%notDel%
					AND CNA_CONTRA = CN9_NUMERO
					AND CNA_REVISA = CN9_REVISA
					AND CNA_PERIOD <> ''

					AND CNL_FILIAL = %exp:cFilCNL%
					AND CNL.%notDel%
					AND CNL_CODIGO = CNA_TIPPLA

					AND CN1_FILIAL = %exp:cFilCN1%
					AND CN1.%notDel%
					AND CN1_CODIGO = CN9_TPCTO
					%exp:cSql%

				UNION ALL

				SELECT
					CN9_FILCTR,
					CN9_NUMERO,
					CN9_REVISA,
					CN9_ESPCTR,
					CN9_TPCTO,
					CN9_SITUAC,

					CN1_DESCRI,
					CN1_MEDEVE,

					CNA_CONTRA,
					CNA_NUMERO,
					CNA_TIPPLA,
					CNA_CRONOG,
					CNA_PERIOD,
					CNA_FORNEC,
					CNA_LJFORN,
					CNA_CLIENT,
					CNA_LOJACL,

					CNL_DESCRI,
					CNL_MEDEVE,

					CNF_NUMERO,
					CNF_COMPET  AS COMPET,
					CNF_PRUMED 	AS PROMED,
					CNF_PARCEL 	AS PROPAR,
					CNF_SALDO 	AS VLRPREV

				FROM
					%table:CN9% CN9,
					%table:CNA% CNA,
					%table:CN1% CN1,
					%table:CNL% CNL,
					%table:CNF% CNF

				WHERE
						CN9.%notDel%
					AND CN9.CN9_SITUAC IN ('05','06')

					AND CNA.%notDel%
					AND CNA.CNA_FILIAL = CN9.CN9_FILIAL
					AND CNA.CNA_CONTRA = CN9.CN9_NUMERO
					AND CNA.CNA_REVISA = CN9.CN9_REVISA
					AND CNA.CNA_PERIOD = ''

					AND CNL.%notDel%
					AND CNL.CNL_FILIAL = %exp:cFilCNL%
					AND CNL.CNL_CODIGO = CNA.CNA_TIPPLA

					AND CN1.%notDel%
					AND	CN1.CN1_FILIAL = %exp:cFilCN1%
					AND CN1.CN1_CODIGO = CN9.CN9_TPCTO

					AND CNF.%notDel%
					AND CNF.CNF_FILIAL = CN9.CN9_FILIAL
					AND CNF.CNF_CONTRA = CN9.CN9_NUMERO
					AND CNF.CNF_REVISA = CN9.CN9_REVISA
					AND CNF.CNF_NUMPLA = CNA.CNA_NUMERO
					AND CNF.CNF_SALDO > 0
					%exp:cSql2%
				) RESUMO

			WHERE
				((RESUMO.CN1_MEDEVE <> '1' AND RESUMO.CNL_MEDEVE <> '1')
				OR
				(RESUMO.CNL_MEDEVE <> '1'))
				AND RESUMO.COMPET <> ''

			ORDER BY
				RESUMO.CN9_FILCTR,
				RESUMO.CN9_NUMERO,
				RESUMO.CNA_NUMERO,
				RESUMO.CNA_CRONOG,
				RESUMO.PROMED
		EndSql

	Endif

Endif

DbSelectArea(cAliasQry)
Count To nRecCN9
dbGoTop()

If mv_par16 = 2
	TRCell():New(oCN9,"QTAMED",,STR0017+CRLF+STR0018)//Qtd. Medicoes nao realizadas
Endif

TRCell():New(oCN9,"VLAMED",,STR0019,PesqPict("CNA","CNA_VLTOT"))//Valor nao medido

If nRecCN9 > 0
	oReport:SetMeter(nRecCN9)
	If mv_par16 = 1
		oCN9:Init()
	Endif
	While !(cAliasQry)->(EOF()) .And. !oReport:Cancel()		
		nQtdNaoMed := (cAliasQry)->( CN121Qtd(CN9_NUMERO, CN9_REVISA, /*cPlan*/, CN9_FILCTR) )
		If nQtdNaoMed = 0
			oReport:IncMeter()
			(cAliasQry)->(dbSkip())
			Loop
		Endif
		
		nVlrNaoMed := (cAliasQry)->( CN121Vlr(CN9_NUMERO, CN9_REVISA, /*cPlan*/, CN9_FILCTR) )

		If mv_par16 = 2
			oCN9:Init()
		Endif

		oCN9:Cell("CN9_FILCTR"):SetValue((cAliasQry)->CN9_FILCTR)
		oCN9:Cell("FILNAME"):SetValue(AllTrim(FWFilialName(,(cAliasQry)->CN9_FILCTR)))
		oCN9:Cell("CN9_NUMERO"):SetValue((cAliasQry)->CN9_NUMERO)
		oCN9:Cell("CN9_REVISA"):SetValue((cAliasQry)->CN9_REVISA)
		oCN9:Cell("CN9_ESPCTR"):SetValue(CNR121Combo("CN9_ESPCTR",(cAliasQry)->CN9_ESPCTR))
		oCN9:Cell("CN9_TPCTO" ):SetValue((cAliasQry)->CN9_TPCTO)
		oCN9:Cell("CN1_DESCRI"):SetValue((cAliasQry)->CN1_DESCRI)
		oCN9:Cell("CN9_SITUAC"):SetValue(CNR121Combo("CN9_SITUAC",(cAliasQry)->CN9_SITUAC))
		oCN9:Cell("VLAMED"):SetValue(nVlrNaoMed)

		If mv_par16 = 2
			oCN9:Cell("QTAMED"):SetValue(nQtdNaoMed)
			oCN9:PrintLine()
				cQuebra := (cAliasQry)->(CN9_FILCTR + CN9_NUMERO + CN9_REVISA)

				While !(cAliasQry)->(EOF()) .And. !oReport:Cancel() .And. (cAliasQry)->(CN9_FILCTR + CN9_NUMERO + CN9_REVISA) = cQuebra
					oPlanTot:Init()
					oPlanTot:Cell("CNA_NUMERO"):SetValue((cAliasQry)->CNA_NUMERO)
					lRecorre := !(Empty((cAliasQry)->CNA_PERIOD))

					If (cAliasQry)->CN9_ESPCTR == '2'
						oPlanTot:Cell("A2_NOME"):SetValue(Posicione("SA1",1,xFilial('SA1')+(cAliasQry)->(CNA_CLIENT+CNA_LOJACL),"A1_NOME")) //(1) A1_FILIAL+A1_COD+A1_LOJA
					Else
						oPlanTot:Cell("A2_NOME"):SetValue(Posicione("SA2",1,xFilial('SA2')+(cAliasQry)->(CNA_FORNEC+CNA_LJFORN),"A2_NOME")) //(1) A2_FILIAL+A2_COD+A2_LOJA
					EndIf
					oPlanTot:Cell("CNA_TIPPLA"):SetValue((cAliasQry)->CNA_TIPPLA)
					oPlanTot:Cell("CNL_DESCRI"):SetValue((cAliasQry)->CNL_DESCRI)
					
					oPlanTot:Cell("QTAMED"):SetTitle(IIF(lRecorre, STR0008, STR0020)+CRLF+STR0009)//Recorr�ncia/Parcela nao medida					

					oPlanTot:Cell("QTAMED"):SetValue( (cAliasQry)->( CN121Qtd(CN9_NUMERO, CN9_REVISA, CNA_NUMERO, CN9_FILCTR) ) )
					oPlanTot:Cell("VLAMED"):SetValue( (cAliasQry)->( CN121Vlr(CN9_NUMERO, CN9_REVISA, CNA_NUMERO, CN9_FILCTR) ) )					 

					oPlanTot:PrintLine()
					If mv_par17 = 2
						
						oPlanDet:Init()
						If !lRecorre //Se n�o for recorrente, consulta o cronograma financeiro(CNF)
							cQuebr2 := (cAliasQry)->(CN9_FILCTR + CN9_NUMERO + CN9_REVISA + CNA_NUMERO + CNF_NUMERO)

							While !(cAliasQry)->(EOF()) .And. !oReport:Cancel() .And. (cAliasQry)->(CN9_FILCTR + CN9_NUMERO + CN9_REVISA + CNA_NUMERO + CNF_NUMERO) == cQuebr2
								oPlanDet:Cell("COMPET"):SetValue((cAliasQry)->COMPET)
								oPlanDet:Cell("CNA_PROMED"):SetValue(Stod((cAliasQry)->PROMED))
								oPlanDet:Cell("CNA_PROPAR"):SetValue((cAliasQry)->PROPAR)
								oPlanDet:Cell("CNA_PROPAR"):SetTitle(STR0014)//Parcela
								oPlanDet:Cell("VLRPREV"):SetValue((cAliasQry)->VLRPREV)
								oPlanDet:PrintLine()
								oReport:IncMeter()
								(cAliasQry)->(dbSkip())
							EndDo
							oPlanDet:Finish()
							oPlanTot:Finish()
						Else//Se for recorrente
							aRecorre := (cAliasQry)->( CN121Reco(CN9_NUMERO, CN9_REVISA, CNA_NUMERO, CN9_FILCTR) )
							For nX := 1 To Len(aRecorre)
								oPlanDet:Cell("CNA_PROMED"):SetValue(aRecorre[nX][2])
								oPlanDet:Cell("CNA_PROPAR"):SetTitle(STR0021)//Recorr�ncia
								oPlanDet:Cell("CNA_PROPAR"):SetValue(aRecorre[nX][1])
								oPlanDet:Cell("VLRPREV"):SetValue(aRecorre[nX][3])
								oPlanDet:Cell("COMPET"):SetValue(aRecorre[nX][4])
								oPlanDet:PrintLine()
								oReport:IncMeter()
							Next nX
							oPlanDet:Finish()
							oPlanTot:Finish()
							(cAliasQry)->(dbSkip())
						Endif
						oReport:SkipLine()
					Else
						oReport:IncMeter()
						(cAliasQry)->(dbSkip())
					Endif
				EndDo
				If mv_par17 = 1
					oPlanTot:Finish()
					oReport:SkipLine()
				Endif
				oReport:ThinLine()
			oCN9:Finish()
		Else
			cQuebra := (cAliasQry)->(CN9_FILCTR + CN9_NUMERO + CN9_REVISA)
			oCN9:PrintLine()

			While !(cAliasQry)->(EOF()) .And. !oReport:Cancel() .And. (cAliasQry)->(CN9_FILCTR + CN9_NUMERO + CN9_REVISA) = cQuebra
				oReport:IncMeter()//Tratamento p/ contratos com m�ltiplas planilhas
				(cAliasQry)->(dbSkip())
			EndDo			
		Endif
	EndDo
	If MV_PAR16 = 1
		oCN9:Finish()
	Endif
Endif
(cAliasQry)->(dbCloseArea())

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CN121Qtd	 �Autor �Rogerio Melonio        �Data  �25/09/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula a quantidade de parcelas/recorrencias nao medidas  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CNTR121                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CN121Qtd(cContrato,cRevisa,cPlanilha, cFilCtr)
Local lRet 		:= .F.
Local aArea 	:= GetArea()
Local aAreaCNA 	:= CNA->(GetArea())
Local aAreaCNF 	:= CNF->(GetArea())
Local aParcelas := {}

Local dDataPriMed 	:= dDataBase
Local cCpoParcela 	:= ""
Local cStrRec 	  	:= "/"
Local cFilCNA		:= ""
Local cFilCNF		:= ""
Local nQtdNaoMed:= 0
Local nX 		:= 0

Default cPlanilha 	:= ""
Default cFilCtr 	:= cFilAnt


cFilCNA := xFilial("CNA", cFilCtr)
cFilCNF := xFilial("CNF", cFilCtr)

CNA->(dbSetOrder(1))
lRet := CNA->(MsSeek(cFilCNA+cContrato+cRevisa+cPlanilha))

If lRet
	While !CNA->(EOF()) .And. CNA->CNA_FILIAL+CNA->CNA_CONTRA+CNA->CNA_REVISA == cFilCNA+cContrato+cRevisa .And. IIF(Empty(cPlanilha),.T.,CNA->CNA_NUMERO <= cPlanilha )
		If !Empty(CNA->CNA_PERIOD)
			If ( CNA->CNA_PROMED >= mv_par14 .And. CNA->CNA_PROMED <= mv_par15 ) .Or. ( CNA->CNA_ULTMED < mv_par14 )				
				cStrRec += ParcelRec(cFilCtr)

				cCpoParcela := IIf( Empty(CNA->CNA_FORNEC),"E1_PARCELA","E2_PARCELA" )
				dDataPriMed := CN300RetMed(CNA->CNA_PERIOD,CNA->CNA_DTINI,CNA->CNA_DIAMES,CNA->CNA_DIASEM,CNA->CNA_PERREC,.T.)
				aParcelas 	:= CN100ParRc(CNA->CNA_PERIOD,CNA->CNA_QTDREC,CNA->CNA_DIASEM,CNA->CNA_DIAMES,dDataPriMed,CNA->CNA_DTINI,CNA->CNA_DTFIM,cCpoParcela,CNA->CNA_PERREC)

				For nX := 1 To Len(aParcelas)
					If ( aParcelas[nX][2] >= MV_PAR14 .And. aParcelas[nX][2] <= MV_PAR15 ) .And. ( aParcelas[nX][2] > CNA->CNA_ULTMED )
						If !("/"+aParcelas[nX][1]+"/" $ cStrRec)
							nQtdNaoMed := nQtdNaoMed + 1
						Endif
					Endif
				Next nX
			Endif
		Else
			CNF->(dbSetOrder(3))
			CNF->(MsSeek(cFilCNF+cContrato+cRevisa+CNA->CNA_CRONOG))

			While !CNF->(EOF()) .And. CNF->CNF_FILIAL+CNF->CNF_CONTRA+CNF->CNF_REVISA+CNF->CNF_NUMERO == cFilCNF+cContrato+cRevisa+CNA->CNA_CRONOG .And. CNF->CNF_PRUMED <= mv_par15
				If CNF->CNF_PRUMED >= mv_par14 .And. CNF->CNF_PRUMED <= mv_par15 .And. CNF->CNF_SALDO > 0
					nQtdNaoMed := nQtdNaoMed + 1
				Endif
				CNF->(dbSkip())
			EndDo
		Endif
		CNA->(dbSkip())
	EndDo
Endif

CNF->(RestArea(aAreaCNF))
CNA->(RestArea(aAreaCNA))
RestArea(aArea)

Return(nQtdNaoMed)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CN121Vlr	 �Autor �Rogerio Melonio        �Data  �25/09/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o valor das parcelas/recorrencias nao medidas  	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CNTR121                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CN121Vlr(cContrato,cRevisa,cPlanilha, cFilCtr)
Local lRet := .F.
Local aArea := GetArea()
Local aAreaCNA := CNA->(GetArea())
Local aAreaCNF := CNF->(GetArea())
Local nQtdNaoMed := 0
Local nVlrNaoMed := 0
Local aParcelas := {}
Local dDataPriMed := dDataBase
Local cCpoParcela := ""
Local cStrRec := "/"
Local nX := 0
Local cFilCNA	:= ""
Local cFilCNF	:= ""
Default cPlanilha 	:= ""
Default cFilCtr 	:= cFilAnt

cFilCNA := xFilial("CNA", cFilCtr)
cFilCNF := xFilial("CNF", cFilCtr)
CNA->(dbSetOrder(1))
lRet := CNA->(MsSeek(cFilCNA+cContrato+cRevisa+cPlanilha))

If lRet
	While !CNA->(EOF()) .And. CNA->CNA_FILIAL+CNA->CNA_CONTRA+CNA->CNA_REVISA == cFilCNA+cContrato+cRevisa .And. Iif(Empty(cPlanilha),.T.,CNA->CNA_NUMERO <= cPlanilha )
		If !Empty(CNA->CNA_PERIOD)
			If ( CNA->CNA_PROMED >= mv_par14 .And. CNA->CNA_PROMED <= mv_par15 ) .Or. ( CNA->CNA_ULTMED < mv_par14 )
				cStrRec += ParcelRec(cFilCtr)

				cCpoParcela := IIf( Empty(CNA->CNA_FORNEC),"E1_PARCELA","E2_PARCELA" )
				dDataPriMed := CN300RetMed(CNA->CNA_PERIOD,CNA->CNA_DTINI,CNA->CNA_DIAMES,CNA->CNA_DIASEM,CNA->CNA_PERREC,.T.)
				aParcelas := CN100ParRc(CNA->CNA_PERIOD,CNA->CNA_QTDREC,CNA->CNA_DIASEM,CNA->CNA_DIAMES,dDataPriMed,CNA->CNA_DTINI,CNA->CNA_DTFIM,cCpoParcela,CNA->CNA_PERREC)
				For nX := 1 To Len(aParcelas)
					If ( aParcelas[nX][2] >= MV_PAR14 .And. aParcelas[nX][2] <= MV_PAR15 ) .And. ( aParcelas[nX][2] > CNA->CNA_ULTMED )
						If !("/"+aParcelas[nX][1]+"/" $ cStrRec)
							nQtdNaoMed := nQtdNaoMed + 1
						Endif
					Endif
				Next nX
				nVlrNaoMed += (nQtdNaoMed*CNA->CNA_VLTOT)
			Endif
		ElseIf !Empty(CNA->CNA_CRONOG)
			CNF->(dbSetOrder(3))
			CNF->(MsSeek(cFilCNF+cContrato+cRevisa+CNA->CNA_CRONOG))
			While !CNF->(EOF()) .And. CNF->CNF_FILIAL+CNF->CNF_CONTRA+CNF->CNF_REVISA+CNF->CNF_NUMERO == cFilCNF+cContrato+cRevisa+CNA->CNA_CRONOG;
				.And. CNF->CNF_PRUMED <= mv_par15
				If CNF->CNF_PRUMED >= mv_par14 .And. CNF->CNF_PRUMED <= mv_par15 .And. CNF->CNF_SALDO > 0
					nVlrNaoMed += CNF->CNF_SALDO
				Endif
				CNF->(dbSkip())
			EndDo
		Endif
		CNA->(dbSkip())
	EndDo
Endif

CNF->(RestArea(aAreaCNF))
CNA->(RestArea(aAreaCNA))
RestArea(aArea)

Return(nVlrNaoMed)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CN121Reco	 �Autor �Rogerio Melonio        �Data  �25/09/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna as recorencias nao medidas                     	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CNTR121                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CN121Reco(cContrato,cRevisa,cPlanilha, cFilCtr)
Local lRet := .F.
Local aArea := GetArea()
Local aAreaCNA := CNA->(GetArea())
Local aParcelas := {}
Local dDataPriMed := dDataBase
Local cCpoParcela := ""
Local nX := 0
Local aRecorre := {}
Local cStrRec := "/"
Local cCompet := ""
Default cFilCtr := cFilAnt

CNA->(dbSetOrder(1))
lRet := CNA->(MsSeek(xFilial("CNA", cFilCtr)+cContrato+cRevisa+cPlanilha))

If lRet
	If ( CNA->CNA_PROMED >= mv_par14 .And. CNA->CNA_PROMED <= mv_par15 ) .Or. ( CNA->CNA_ULTMED < mv_par14 )
		cStrRec += ParcelRec(cFilCtr)
		
		cCpoParcela := IIf( Empty(CNA->CNA_FORNEC),"E1_PARCELA","E2_PARCELA" )
		dDataPriMed := CN300RetMed(CNA->CNA_PERIOD,CNA->CNA_DTINI,CNA->CNA_DIAMES,CNA->CNA_DIASEM,CNA->CNA_PERREC,.T.)
		aParcelas := CN100ParRc(CNA->CNA_PERIOD,CNA->CNA_QTDREC,CNA->CNA_DIASEM,CNA->CNA_DIAMES,dDataPriMed,CNA->CNA_DTINI,CNA->CNA_DTFIM,cCpoParcela,CNA->CNA_PERREC)
		For nX := 1 To Len(aParcelas)
			If ( aParcelas[nX][2] >= MV_PAR14 .And. aParcelas[nX][2] <= MV_PAR15 ) .And. ( aParcelas[nX][2] > CNA->CNA_ULTMED )
				If !("/"+aParcelas[nX][1]+"/" $ cStrRec)
					cCompet := StrZero( Month( aParcelas[nX,2] ),2) + "/" + Str(Year( aParcelas[nX,2] ),4)

					aAdd(aRecorre, { aParcelas[nX][1],aParcelas[nX][2],CNA->CNA_VLTOT, cCompet } )
				Endif
			Endif
		Next
	EndIf
Endif

CNA->(RestArea(aAreaCNA))
RestArea(aArea)

Return aRecorre

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CNR121Combo�Autor �Rogerio Melonio        �Data  �28/09/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna descricao de campo combo                       	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CNTR121                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CNR121Combo(cCampo,cValor)
Local aSx3Box := RetSx3Box( Posicione("SX3", 2, cCampo, "X3CBox()" ),,, 1 )
Local cTxtBox := ""
Local nQual	  := Iif(cCampo=="CN9_SITUAC",1,2)
Local nPosBox := Ascan( aSx3Box, { |aBox| aBox[nQual] = cValor } )

cTxtBox := Upper(AllTrim( aSx3Box[nPosBox][3] ))

Return cTxtBox

/*/{Protheus.doc} ParcelRec
	Verifica quais parcelas de um contrato recorrente j� foram medidas considerando a filial do contrato(CND_FILCTR)
@author philipe.pompeu
@since 21/04/2021
@return cResult, caractere, parcelas j� medidas de um contrato recorrente
/*/
Static Function ParcelRec(cFilCtr) 
	Local cResult := ""
	Local cMyAlias:= GetNextAlias()

	BeginSql alias cMyAlias

		SELECT  CXN_PARCEL
		FROM %table:CXN% CXN
		INNER JOIN %table:CND% CND ON(
			CND_FILIAL = CXN_FILIAL 
			AND CND_CONTRA = CXN_CONTRA
			AND CND_REVISA = CXN_REVISA
			AND CND_NUMMED = CXN_NUMMED
			AND CND.%notDel%		
		)
		WHERE 
		CXN.%notDel%
		AND CXN_CONTRA = %Exp:CNA->CNA_CONTRA%
		AND CXN_REVISA = %Exp:CNA->CNA_REVISA%
		AND CXN_NUMPLA = %Exp:CNA->CNA_NUMERO%
		AND CND_FILCTR = %Exp:cFilCtr%
	EndSql			
		
	while ( (cMyAlias)->(!Eof()) )		
		cResult += (cMyAlias)->CXN_PARCEL + "/"
		(cMyAlias)->(dbSkip())
	End
	(cMyAlias)->(dbCloseArea())
	
Return cResult
