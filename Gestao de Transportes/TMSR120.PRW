#INCLUDE "TMSR120.CH"
#INCLUDE "TOPCONN.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMSR120   � Autor �Rodolfo K. Rosseto     � Data �01/06/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime a relacao das coletas nao efetuadas por ocorrencia  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function TMSR120()

Local oReport
Local aArea := GetArea()

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
Local oOcorren
Local oDocto
oReport := TReport():New("TMSR120",STR0015,"TMR120A", {|oReport| ReportPrint(oReport)},STR0016)

oReport:SetTotalInLine(.F.)
Pergunte("TMR120A",.F.)

oOcorren := TRSection():New(oReport,STR0017,{"DUA","DT2"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oOcorren:SetTotalInLine(.F.)
TRCell():New(oOcorren,"DUA_CODOCO"	,"DUA",STR0017,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oOcorren,"DT2_DESCRI"	,"DT2",STR0018,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oDocto := TRSection():New(oOcorren,STR0019,{"DUA","DUE","DT5"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oDocto:SetTotalInLine(.F.)
TRCell():New(oDocto,"DUA_DATOCO"	,"DUA",STR0020,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DUA_HOROCO"	,"DUA",STR0021,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DUA_FILDOC"	,"DUA",STR0022,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DUA_DOC"		,"DUA",STR0019,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DUA_SERIE"	,"DUA",STR0023,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DUE_NOME"	,"DUE",STR0024,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DT5_TIPCOL"	,"DT5",STR0025,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DUA_QTDOCO"	,"DUA",STR0026,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DUA_PESOCO"	,"DUA",STR0027,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRFunction():New(oDocto:Cell("DUA_DOC")		,,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDocto:Cell("DUA_QTDOCO")	,,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDocto:Cell("DUA_PESOCO")	,,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/)

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
Static Function ReportPrint(oReport)

Local cAliasQry := GetNextAlias()
Local cTipOco   := StrZero(4,Len(DT2->DT2_TIPOCO)) // Retorno
Local cWhere    :=  ""
//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)
//������������������������������������������������������������������������Ŀ
//�Query do relatorio da secao Rodovias                                    �
//��������������������������������������������������������������������������
oReport:Section(1):BeginQuery()

cWhere := "%"
If mv_par07 <> 3 //Ambas
	cWhere += "AND DT5_TIPCOL  = '" + AllTrim(Str(mv_par07)) + "'"
EndIf
cWhere += "%"

	BeginSql Alias cAliasQry
	
	SELECT DUA_FILIAL, DUA_CODOCO, DUA_DATOCO, DUA_HOROCO, DUA_FILDOC, DUA_DOC, DUA_SERIE, DUA_QTDOCO, DUA_PESOCO,
			 DT2_DESCRI, DUE_NOME, MAX(DT5_TIPCOL) TIPCOL

	FROM %table:DUA% DUA

	JOIN %table:DT2% DT2
	ON DT2_FILIAL      = %xFilial:DT2%	
	AND DT2.DT2_TIPOCO = %Exp:cTipOco%
	AND DT2_CODOCO     = DUA_CODOCO
	AND DT2_SERTMS     = DUA_SERTMS
	AND DT2_CODOCO BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
	AND DT2.%NotDel%

	JOIN %table:DT5% DT5
	ON DT5_FILIAL       = %xFilial:DT5%
	AND DT5_FILDOC   = DUA_FILDOC
	AND DT5_DOC      = DUA_DOC
	AND DT5_SERIE    = DUA_SERIE
	AND DT5_CODSOL BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
	AND DT5.%NotDel%
	%Exp:cWhere%

	JOIN %table:DUE% DUE
	ON DUE_FILIAL = %xFilial:DUE%
	AND DUE_CODSOL = DT5_CODSOL  
	AND DUE.%NotDel%

	WHERE DUA_FILIAL = %xFilial:DUA%
		AND DUA_DATOCO BETWEEN %Exp:DTOS(mv_par01)% AND %Exp:DTOS(mv_par02)%
		AND DUA.%NotDel%

	GROUP BY DUA_FILIAL, DUA_CODOCO, DUA_DATOCO, DUA_HOROCO,  DUA_FILDOC, DUA_DOC, DUA_SERIE,  DUA_QTDOCO, DUA_PESOCO, DT2_DESCRI, DUE_NOME
	ORDER BY DUA_FILIAL, DUA_CODOCO, DUA_DATOCO, DUA_HOROCO
	
	EndSql

oReport:Section(1):EndQuery()

oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter({ |cParam| (cAliasQry)->DUA_CODOCO == cParam },{ || (cAliasQry)->DUA_CODOCO })

oReport:Section(1):Print()

oReport:SetMeter(DUA->(LastRec()))

Return