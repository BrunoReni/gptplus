#INCLUDE "TMSR110.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMSR110   � Autor �Rodolfo K. Rosseto     � Data �01/06/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Emissao da Relacao de Contratos Emitidos                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMSR110()

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
Local oContrato

oReport := TReport():New("TMSR110",STR0011,"TMR110", {|oReport| ReportPrint(oReport)},STR0012)
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)
Pergunte("TMR110",.F.)

oContrato := TRSection():New(oReport,STR0013,{"DTY","SA2","DA4"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oContrato:SetTotalInLine(.F.)
TRCell():New(oContrato,"DTY_FILORI"	,"DTY",STR0014,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DTY_NUMCTC"	,"DTY",STR0015,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DTY_VIAGEM"	,"DTY",STR0028,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DTY_DATCTC"	,"DTY",STR0016,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"A2_NOME"		,"SA2",STR0017,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DA4_NOME"	,"DA4",STR0018,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DTY_VALFRE"	,"DTY",STR0019,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DTY_VALPDG"	,"DTY",STR0020,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DTY_ADIFRE"	,"DTY",STR0021,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DTY_QTDDOC"	,"DTY",STR0022,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DTY_QTDVOL"	,"DTY",STR0023,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DTY_PESO"	,"DTY",STR0024,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DTY_IRRF"	,"DTY",STR0025,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DTY_SEST"	,"DTY",STR0026,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DTY_INSS"	,"DTY",STR0027,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRFunction():New(oContrato:Cell("DTY_VALFRE")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oContrato:Cell("DTY_VALPDG")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oContrato:Cell("DTY_ADIFRE")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oContrato:Cell("DTY_QTDDOC")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oContrato:Cell("DTY_QTDVOL")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oContrato:Cell("DTY_PESO")		,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oContrato:Cell("DTY_IRRF")		,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oContrato:Cell("DTY_SEST")		,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oContrato:Cell("DTY_INSS")		,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)

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
//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)
//������������������������������������������������������������������������Ŀ
//�Query do relatorio da secao Contratos                                   �
//��������������������������������������������������������������������������
oReport:Section(1):BeginQuery()

	BeginSql Alias cAliasQry
	
	SELECT DTY_FILIAL, DTY_FILORI, DTY_NUMCTC, DTY_VIAGEM, DTY_DATCTC, A2_NOME, DA4_NOME,
			 DTY_VALFRE, DTY_CODFOR, DTY_LOJFOR, DTY_VALPDG, DTY_ADIFRE, DTY_QTDDOC, 
			 DTY_QTDVOL, DTY_PESO, DTY_IRRF, DTY_SEST, DTY_INSS

	FROM %table:DTY% DTY

	JOIN %table:SA2% SA2 ON
   A2_FILIAL = %xFilial:SA2%
	AND A2_COD = DTY_CODFOR
	AND A2_LOJA = DTY_LOJFOR
	AND SA2.%NotDel%

	JOIN %table:DA4% DA4 ON
	DA4_FILIAL = %xFilial:DA4%
	AND DA4_COD = DTY_CODMOT
	AND DA4.%NotDel%

	WHERE DTY_FILIAL = %xFilial:DTY%
		AND DTY_DATCTC >= %Exp:Dtos(mv_par01)%
		AND DTY_DATCTC <= %Exp:Dtos(mv_par02)%
		AND DTY_CODFOR >= %Exp:mv_par03%
		AND DTY_CODFOR <= %Exp:mv_par05%
		AND DTY_LOJFOR >= %Exp:mv_par04%
		AND DTY_LOJFOR <= %Exp:mv_par06%		
		AND DTY.%NotDel%
		
	ORDER BY DTY_FILIAL, DTY_CODFOR, DTY_LOJFOR, DTY_DATCTC
	
	EndSql

oReport:Section(1):EndQuery()

oReport:Section(1):Print()

oReport:SetMeter(DTY->(LastRec()))

Return