#INCLUDE "TMSR100.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMSR100   � Autor �Rodolfo K. Rosseto     � Data �31/05/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Emissao da Relacao do Lay-out Tabela de Frete               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMSR100()

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
Local oTabFre
Local cAliasQry  := GetNextAlias()

oReport := TReport():New("TMSR100",STR0010,"TMR100", {|oReport| ReportPrint(oReport,cAliasQry)},STR0011)
oReport:SetTotalInLine(.F.)
Pergunte("TMR100",.F.)

oTabFre := TRSection():New(oReport,STR0019,{"DTL","DVE","DT3"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oTabFre:SetTotalInLine(.F.)
TRCell():New(oTabFre,"DTL_TABFRE"	,"DTL",STR0012,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oTabFre,"DTL_TIPTAB"	,"DTL",STR0013,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oTabFre,"DESCTAB"		,"   ",STR0014,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Tabela("M5", (cAliasQry)->DTL_TIPTAB, .F.) })
TRCell():New(oTabFre,"DTL_DATDE"		,"DTL",STR0015,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oTabFre,"DTL_DATATE"	,"DTL",STR0016,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oTabFre,"DVE_CODPAS"	,"DTL",STR0017,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oTabFre,"DT3_DESCRI"	,"DTL",STR0018,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

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
Static Function ReportPrint(oReport,cAliasQry)

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)
//������������������������������������������������������������������������Ŀ
//�Query do relatorio da secao Lay Out                                     �
//��������������������������������������������������������������������������
oReport:Section(1):BeginQuery()

	BeginSql Alias cAliasQry

	SELECT DTL_FILIAL, DTL_TABFRE, DTL_TIPTAB, DTL_DATDE, DTL_DATATE, DVE_CODPAS, DT3_DESCRI

	FROM %table:DTL% DTL

	JOIN %table:DVE% DVE ON
	DVE_FILIAL = %xFilial:DVE%
	AND DVE_TABFRE = DTL_TABFRE
	AND DVE_TIPTAB = DTL_TIPTAB
	AND DVE.%NotDel%

	JOIN %table:DT3% DT3 ON
	DT3_FILIAL = %xFilial:DT3%
	AND DT3_CODPAS = DVE_CODPAS
	AND DT3.%NotDel%

	WHERE DTL_FILIAL = %xFilial:DTL%
		AND DTL_TABFRE >= %Exp:mv_par01%
		AND DTL_TABFRE <= %Exp:mv_par03%
		AND DTL_TIPTAB >= %Exp:mv_par02%
		AND DTL_TIPTAB <= %Exp:mv_par04%
		AND DTL.%NotDel%
		
	ORDER BY DTL_FILIAL, DTL_TABFRE, DTL_TIPTAB, DVE_CODPAS
	
	EndSql

oReport:Section(1):EndQuery()

oReport:Section(1):Print()

oReport:SetMeter(DTL->(LastRec()))

Return