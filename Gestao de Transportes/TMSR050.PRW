#INCLUDE "TMSR050.ch"
#INCLUDE "rwmake.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMSR050   � Autor �Rodolfo K. Rosseto     � Data �31/05/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Emiss�o da Rela�ao de Praca Pedagio Rota                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMSR050()

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
Local oRota
Local oItens

oReport := TReport():New("TMSR050",STR0010,"TMR050", {|oReport| ReportPrint(oReport)},STR0011)
oReport:SetTotalInLine(.F.)
Pergunte("TMR050",.F.)

oRota := TRSection():New(oReport,STR0012,{"DU2","DA8"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oRota:SetTotalInLine(.F.)
TRCell():New(oRota,"DU2_ROTA"	,"DU2",STR0012,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRota,"DA8_DESC"	,"DA8",STR0013,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oItens := TRSection():New(oRota,STR0014,{"DU0","DTZ","DU2"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oItens:SetTotalInLine(.F.)
TRCell():New(oItens,"DU2_ITEM"	,"DU2",STR0014,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"DU2_CODROD"	,"DU2",STR0015,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"DTZ_NOMROD"	,"DTZ",STR0016,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"DU2_SEQPDG"	,"DU2",STR0017,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"DU2_KM"		,"DU2",STR0018,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"DU0_MUNPDG"	,"DU0",STR0019,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

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
//�Query do relatorio da secao Rodovias                                    �
//��������������������������������������������������������������������������
oReport:Section(1):BeginQuery()

	BeginSql Alias cAliasQry
	
	SELECT DU2_ROTA, DA8_DESC, DU2_ITEM, DU2_CODROD, DTZ_NOMROD, DU2_SEQPDG, DU2_KM, DU0_MUNPDG

	FROM %table:DU2% DU2

	JOIN %table:DA8% DA8 ON
	DA8_FILIAL = %xFilial:DA8%
	AND DA8_COD = DU2_ROTA
	AND DA8.%NotDel%

	JOIN %table:DTZ% DTZ ON
	DTZ_FILIAL = %xFilial:DTZ%
	AND DTZ_CODROD = DU2_CODROD
	AND DTZ.%NotDel%

	JOIN %table:DU0% DU0 ON
 	DU0_FILIAL = %xFilial:DU0%
 	AND DU0_CODROD = DU2_CODROD
 	AND DU0_SEQPDG = DU2_SEQPDG
 	AND DU0.%NotDel%

	WHERE DU2_FILIAL = %xFilial:DU2%
		AND DU2_ROTA >= %Exp:mv_par01%
		AND DU2_ROTA <= %Exp:mv_par02%
		AND DU2.%NotDel%
	
	EndSql

oReport:Section(1):EndQuery()

oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter({ |cParam| (cAliasQry)->DU2_ROTA == cParam },{ || (cAliasQry)->DU2_ROTA })

oReport:Section(1):Print()

oReport:SetMeter(DU2->(LastRec()))

Return