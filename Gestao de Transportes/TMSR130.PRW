#INCLUDE "TMSR130.ch"
#INCLUDE "TOPCONN.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMSR130   � Autor �Rodolfo K. Rosseto     � Data �05/06/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime Resumo de Coletas nao Efetuadas.                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMSR130()

Local oReport
Local aArea    := GetArea()
Local aHlpPor1 := {"Informe qual o filtro para as ","ocorr�ncias, ser� utilizado no ","processamento do relat�rio, de acordo ","com o seu respons�vel: ","N�o Tem - filtra as ocorr�ncias que","nao tem nenhum respons�vel.","Transportadora - filtra as ocorr�ncias","cujo respons�vel seja a transportadora.","Cliente - filtra as ocorr�ncias cujo ","respons�vel seja o cliente.","Motorista - filtra as ocorr�ncias cujo","respons�vel seja o motorista.","Todos - o relat�rio n�o utiliza filtro,","considera todas as ocorr�ncias."}
Local aHlpIng1 := {"Enter the filter for the occurrences ","that will be used to process the report",", according to its responsible: None - ","filters the occurrences that have no ","responsible. Carrier - filters the ","occurrences whose responsible is the ","carrier. Customer - filters the ","occurrences whose responsible is the ","customer.Driver - filters the ","occurrences whose responsible is the ","driver. All - the report does not use ","a filter, considers all the occurrences."}
Local aHlpEsp1 := {"Informe cual es el filtro para las ","ocurrencias, sera utilizado en el ","proceso de informe, de acuerdo con el ","responsable: No Tiene - Filtra las ","ocurrencias que no tienen ningun ","resposable.Transportadora - Filtra las ","ocurrencias por las cuales el ","resposable es la transportadora.Cliente"," - Filtra las ocurrencias por las ","cuales es responsable el conductor.","Todos - El informe no utiliza filtro, ","considera todas las ocurrencias."}

PutHelp("P.TMR13006.",aHlpPor1,aHlpIng1,aHlpEsp1,.T.)

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport := ReportDef()
oReport:PrintDialog()

RestArea(aArea)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �                       � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport
Local oFilial
Local oTipCol
Local oResp
Local oItens
Local aArea     := GetArea()
Local cAliasDUA := GetNextAlias()
Local nQtdTot   := 0

oReport := TReport():New("TMSR130",STR0020,"TMR130", {|oReport| ReportPrint(oReport,cAliasDUA,@nQtdTot)},STR0021)
oReport:SetTotalInLine(.F.)
Pergunte("TMR130",.F.)

oFilial := TRSection():New(oReport,STR0022,{"DUA"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oFilial:SetTotalInLine(.F.)
TRCell():New(oFilial,"M0_CODFIL","",STR0022,/*Picture*/,15,/*lPixel*/,{|| Posicione("SM0",1,cEmpAnt+(cAliasDUA)->DUA_FILOCO,"M0_FILIAL") })

oTipCol := TRSection():New(oFilial,STR0023,{"DT5"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oTipCol:SetTotalInLine(.F.)
TRCell():New(oTipCol,"DT5_TIPCOL","DT5",STR0023,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oResp := TRSection():New(oTipCol,STR0024,{"DT2"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oResp:SetTotalInLine(.F.)
TRCell():New(oResp,"DT2_RESOCO","DT2",STR0024,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oItens := TRSection():New(oResp,STR0025,{"DUA"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oItens:SetTotalInLine(.F.)
TRCell():New(oItens,"DUA_CODOCO"	,"DUA",STR0026,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"DT2_DESCRI"	,"DT2",STR0025,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasDUA)->DESCRICAO })
TRCell():New(oItens,"QTDE"			,""	,STR0027,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"PERC"     	,""	,STR0028,"@E 999.99",6,/*lPixel*/, {|| TMR130Acum(0,(cAliasDUA)->QTDE,nQtdTot,"1") } )
TRCell():New(oItens,"ACUMULADO" 	,""	,STR0029,"@E 999.99",6,/*lPixel*/, {||  TMR130Acum(oItens:Cell("PERC"):Uprint,(cAliasDUA)->QTDE,nQtdTot,"2") } )

TRFunction():New(oItens:Cell("QTDE")	,,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oItens:Cell("PERC")	,,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)

RestArea(aArea)

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo Riera          � Data �04.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport,cAliasDUA,nQtdTot)

Local cSerTms   := StrZero(1,Len(DT2->DT2_SERTMS)) // Coleta
Local cTipOco   := StrZero(4,Len(DT2->DT2_TIPOCO)) // Retorno
Local cCond     := ''
Local cWhere    := ''

nQtdTot         := TmsR130Qtd()

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)
//������������������������������������������������������������������������Ŀ
//�Query do relatorio da secao Ocorrencias                                 �
//��������������������������������������������������������������������������
oReport:Section(1):BeginQuery()

cCond := "%"
If mv_par06 <> 5 //-- Ambas
	cCond += "AND DT2_RESOCO = '" + AllTrim(Str(mv_par06-1)) + "' "
EndIf
cCond += "%"

cWhere := "%"
If mv_par05 <> 3 //-- Ambas
	cWhere += "AND DT5_TIPCOL  = '" + AllTrim(Str(mv_par05)) + "' "
EndIf
cWhere += "%"

	BeginSql Alias cAliasDUA

	SELECT DUA_FILIAL, DUA_FILOCO, DT5_TIPCOL, DT2_RESOCO, DUA_CODOCO, COUNT(DUA_CODOCO) QTDE,
			 MAX(DT2_DESCRI) DESCRICAO

	FROM %table:DUA% DUA

	JOIN %table:DT5% DT5
	ON  DT5_FILIAL  = %xFilial:DT5%
	AND DT5_FILDOC = DUA_FILDOC
	AND DT5_DOC    = DUA_DOC
	AND DT5_SERIE  = DUA_SERIE
	AND DT5.%NotDel%

	JOIN %table:DT2% DT2
	ON  DT2_FILIAL = %xFilial:DT2%
	AND DT2_SERTMS = %Exp:cSerTms%
	AND DT2_TIPOCO = %Exp:cTipOco%
	AND DT2.%NotDel%
	%Exp:cCond%

	WHERE DUA_FILIAL = %xFilial:DUA%
		AND DUA_CODOCO = DT2_CODOCO
		AND DUA_SERTMS = DT2_SERTMS
		AND DUA_FILOCO BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
		AND DUA_DATOCO BETWEEN %Exp:Dtos(mv_par03)% AND %Exp:Dtos(mv_par04)%
		AND DUA.%NotDel%
		%Exp:cWhere%

	GROUP BY DUA_FILIAL, DUA_FILOCO, DT5_TIPCOL, DT2_RESOCO, DUA_CODOCO
	ORDER BY DUA_FILIAL, DUA_FILOCO, DT5_TIPCOL, DT2_RESOCO, DUA_CODOCO
	
	EndSql

oReport:Section(1):EndQuery()

oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter({ |cParam| (cAliasDUA)->DUA_FILOCO == cParam },{ || (cAliasDUA)->DUA_FILOCO })

oReport:Section(1):Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):Section(1):SetParentFilter({ |cParam| (cAliasDUA)->DUA_FILOCO+(cAliasDUA)->DT5_TIPCOL == cParam },{ || (cAliasDUA)->DUA_FILOCO+(cAliasDUA)->DT5_TIPCOL })

oReport:Section(1):Section(1):Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):Section(1):Section(1):SetParentFilter({ |cParam| (cAliasDUA)->DUA_FILOCO+(cAliasDUA)->DT5_TIPCOL+(cAliasDUA)->DT2_RESOCO == cParam },{ || (cAliasDUA)->DUA_FILOCO+(cAliasDUA)->DT5_TIPCOL+(cAliasDUA)->DT2_RESOCO })

oReport:Section(1):Print()
  
TMR130Acum(0,0,0,"3") //Zerar variaveis statics

oReport:SetMeter(DUA->(LastRec()))

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMR130Acum� Autor �Rodolfo K. Rosseto     � Data �05/06/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Calcula o valor do Acumulado                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Numerico                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1 - Valor Acumulado das Ocorrencias                     ���
���          �ExpN2 - Quantidade de Ocorrencias                           ���
���          �ExpN3 - Quantidade Total de Coletas                         ���
���          �ExpC1 - Acao(1=Percentual;2=Acumulado;3=Zerar Variaveis)    ���
���          �                                                            ���
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMR130Acum(nValor,nQtd,nQtdTot,cAcao)

Static nAcumulado := 0
Static nPerc      := 0
Static nQtdOco    := 0

If cAcao == "3" //--Zera as variaveis staticas
	nAcumulado := 0
	nPerc      := 0
	nQtdOco    := 0
ElseIf cAcao == "1" //--Calcula o Percentual
	nQtdOco    += nQtd
	nPerc := (nQtd / nQtdTot) * 100
	If nQtdOco == nQtdTot
		nPerc := 100 - nAcumulado
	EndIf
ElseIf cAcao == "2" //--Calcula o acumulado
	nAcumulado += nValor
EndIf

Return (IIf(cAcao == "1",Round(nPerc,2),Round(nAcumulado,2)))

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsR130Qtd� Autor � Eduardo de Souza      � Data � 14/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a Qtde Total de Coletas                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TmsR130Qtd()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSR130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function TmsR130Qtd()

Local cAliasQry := GetNextAlias()
Local cQuery    := ""
Local cTipOco   := StrZero(4,Len(DT2->DT2_TIPOCO))
Local nQtdeTot  := 0

cQuery := " SELECT COUNT(DUA.DUA_CODOCO)AS QTDE "
cQuery += "   FROM " + RetSqlName("DT2") + " DT2 "
cQuery += "   JOIN " + RetSqlName("DUA") + " DUA "
cQuery += "     ON  DT2.DT2_FILIAL = '" + xFilial("DT2") + "' "
cQuery += "     AND DT2.DT2_TIPOCO = '" + cTipOco + "' "
If mv_par06 <> 5
	cQuery += "     AND DT2.DT2_RESOCO = '" + AllTrim(Str(mv_par06-1)) + "' "
EndIf
cQuery += "     AND DT2.D_E_L_E_T_ <> '*' "
cQuery += "     AND DUA.DUA_FILIAL = '" + xFilial("DUA") + "' "
cQuery += "     AND DUA.DUA_CODOCO = DT2.DT2_CODOCO "
cQuery += "     AND DUA.DUA_SERTMS = DT2.DT2_SERTMS "
cQuery += "     AND DUA.DUA_FILOCO BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
cQuery += "     AND DUA.DUA_DATOCO BETWEEN '" + DTOS(mv_par03)+ "' AND '" + DTOS(mv_par04) + "' "
cQuery += "     AND DUA.D_E_L_E_T_ <> '*' "
If mv_par05 <> 3 //-- Ambas
	cQuery += "   JOIN " + RetSqlName("DT5") + " DT5 "
	cQuery += "     ON  DT5.DT5_FILIAL  = '" + xFilial("DT5") + "' "
	cQuery += "     AND DT5.DT5_FILDOC = DUA.DUA_FILDOC "
	cQuery += "     AND DT5.DT5_DOC    = DUA.DUA_DOC "
	cQuery += "     AND DT5.DT5_SERIE  = DUA.DUA_SERIE "
	cQuery += "     AND DT5.DT5_TIPCOL  = '" + AllTrim(Str(mv_par05)) + "' "
	cQuery += "     AND DT5.D_E_L_E_T_ <> '*' "
EndIf

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

nQtdeTot := QTDE
(cAliasQry)->(DbCloseArea())

Return nQtdeTot
