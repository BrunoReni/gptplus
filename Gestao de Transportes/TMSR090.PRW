#INCLUDE "TMSR090.ch"
#INCLUDE "rwmake.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMSR090   � Autor �Rodolfo K. Rosseto     � Data �31/05/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Emissao da Relacao de Componentes de Frete                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMSR090()

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
Local oComp

oReport := TReport():New("TMSR090",STR0010,"TMR090", {|oReport| ReportPrint(oReport)},STR0011)
oReport:SetTotalInLine(.F.)
Pergunte("TMR090",.F.)

oComp := TRSection():New(oReport,STR0012,{"DT3"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oComp:SetTotalInLine(.F.)
TRCell():New(oComp,"DT3_CODPAS"	,"DT3",STR0012,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oComp,"DT3_DESCRI"	,"DT3",STR0013,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oComp,"DT3_FAIXA"	,"DT3",STR0014,/*Picture*/,65,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oComp,"DT3_ATALHO"	,"DT3",STR0016,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oComp,"DT3_APLDES"	,"DT3",STR0017,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

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
	
	SELECT DT3_FILIAL, DT3_CODPAS, DT3_DESCRI, DT3_FAIXA, DT3_ATALHO, DT3_APLDES

	FROM %table:DT3% DT3

	WHERE DT3_FILIAL = %xFilial:DT3%
		AND DT3_CODPAS >= %Exp:mv_par01%
		AND DT3_CODPAS <= %Exp:mv_par02%
		AND DT3.%NotDel%
		
	ORDER BY DT3_FILIAL, DT3_CODPAS	
	
	EndSql

oReport:Section(1):EndQuery()

oReport:Section(1):Print()

oReport:SetMeter(DT3->(LastRec()))

Return