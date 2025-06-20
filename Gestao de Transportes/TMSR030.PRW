#INCLUDE "TMSR030.ch"
#INCLUDE "rwmake.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMSR030   � Autor �Rodolfo K. Rosseto     � Data �30/05/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Emiss�o da Rela�ao de Prazos e Regioes                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMSR030()

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
Local oBloqueio
Local cAliasQry   := GetNextAlias()

oReport := TReport():New("TMSR030",STR0010,"TMR030", {|oReport| ReportPrint(oReport,cAliasQry)},STR0011)
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)
Pergunte("TMR030",.F.)

oBloqueio := TRSection():New(oReport,STR0012,{"DTD","DUY"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oBloqueio:SetTotalInLine(.F.)
TRCell():New(oBloqueio,"DTD_CDRORI"		,"DTD",STR0013,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oBloqueio,"DUY_DESCORI"	,"DUY",STR0014,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oBloqueio,"DTD_CDRDES"		,"DTD",STR0015,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oBloqueio,"DUY_DESCDES"	,"DUY",STR0016,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oBloqueio,"DTD_TIPTRA"		,"DTD",STR0017,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oBloqueio,"DESC_TIP"		,"   ",STR0018,/*Picture*/,15,/*lPixel*/,{|| TMSValField(cAliasQry+'->DTD_TIPTRA',.F.) })
TRCell():New(oBloqueio,"DTD_TMEMBI"		,"DTD",STR0019,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oBloqueio,"DTD_TMEMBF"		,"DTD",STR0020,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oBloqueio,"DTD_TMTRAI"		,"DTD",STR0021,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oBloqueio,"DTD_TMTRAF"		,"DTD",STR0022,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oBloqueio,"DTD_TMDISI"		,"DTD",STR0023,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oBloqueio,"DTD_TMDISF"		,"DTD",STR0024,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

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
//�Query do relatorio da secao Regioes                                     �
//��������������������������������������������������������������������������
oReport:Section(1):BeginQuery()

	BeginSql Alias cAliasQry

		SELECT	DTD_CDRORI, DTD_CDRDES, DTD_TIPTRA, DTD_TMEMBI, DTD_TMEMBF, DTD_TMTRAI, DTD_TMTRAF,
				DTD_TMDISI,DTD_TMDISF, DUY1.DUY_DESCRI DUY_DESCORI, DUY2.DUY_DESCRI DUY_DESCDES

		FROM %table:DTD% DTD

		JOIN %table:DUY% DUY1 ON
		DUY1.DUY_FILIAL = %xFilial:DUY%
		AND DUY1.DUY_GRPVEN = DTD_CDRORI
		AND DUY1.%NotDel%

		JOIN %table:DUY% DUY2 ON
		DUY2.DUY_FILIAL = %xFilial:DUY%
		AND DUY2.DUY_GRPVEN = DTD_CDRDES
		AND DUY2.%NotDel%

		WHERE DTD_FILIAL = %xFilial:DTD%
			AND DTD_CDRORI >= %Exp:mv_par01%
			AND DTD_CDRORI <= %Exp:mv_par02%
			AND DTD_CDRDES >= %Exp:mv_par03%
			AND DTD_CDRDES <= %Exp:mv_par04%
			AND DTD.%NotDel%
		ORDER BY DTD_FILIAL, DTD_CDRORI, DTD_CDRDES, DTD_TIPTRA

	EndSql

oReport:Section(1):EndQuery()

oReport:Section(1):Print()

oReport:SetMeter(DTD->(LastRec()))

Return