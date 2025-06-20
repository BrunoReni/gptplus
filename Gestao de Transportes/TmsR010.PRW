#INCLUDE "TmsR010.ch"
#include 'Protheus.ch'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMSR010   � Autor �Rodolfo K. Rosseto     � Data �30/05/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao dos Documentos com Bloqueio                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR010()

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
Local oItens
Local cAliasQry   := GetNextAlias()

oReport := TReport():New("TMSR010",STR0015,"TMR010", {|oReport| ReportPrint(oReport,cAliasQry)},STR0014)
oReport:SetTotalInLine(.F.)
Pergunte("TMR010",.F.)

oBloqueio := TRSection():New(oReport,STR0016,{"SC9"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oBloqueio:SetPageBreak(.T.)
oBloqueio:SetTotalInLine(.F.)
TRCell():New(oBloqueio,"BLOQUEIO"	,"   ",STR0017,/*Picture*/,10,/*lPixel*/,{|| IIf(Empty((cAliasQry)->C9_BLCRED),STR0019,STR0020) })
TRCell():New(oBloqueio,"C9_LOTNFC"	,"SC9",STR0018,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oItens := TRSection():New(oBloqueio,STR0021,{"SC9","SA1"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oItens:SetTotalInLine(.F.)
TRCell():New(oItens,"C9_PEDIDO"	,"SC9",STR0022,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"C9_ITEM"		,"SC9",STR0021,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"TPBLQ"		,"   ",STR0023,/*Picture*/,02,/*lPixel*/,{|| IIf(Empty((cAliasQry)->C9_BLCRED),(cAliasQry)->C9_BLTMS,(cAliasQry)->C9_BLCRED)})
TRCell():New(oItens,"DESCRIBLQ"	,"   ",STR0024,/*Picture*/,32,/*lPixel*/,{|| IIf(!Empty(Tabela("M2",(cAliasQry)->C9_BLTMS,.F.)),Tabela("M2",(cAliasQry)->C9_BLTMS,.F.),TMR010Desc((cAliasQry)->C9_BLCRED))})
TRCell():New(oItens,"C9_CLIENTE"	,"SC9",STR0025,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"C9_LOJA"		,"SC9",STR0026,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"A1_NREDUZ"	,"SA1",STR0027,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"C9_PRODUTO"	,"SC9",STR0028,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"C9_QTDLIB"	,"SC9",STR0029,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

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

Local cWhere  :=  ""
//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)
//������������������������������������������������������������������������Ŀ
//�Query do relatorio da secao Bloqueios                                   �
//��������������������������������������������������������������������������
oReport:Section(1):BeginQuery()

cWhere := "%"
If mv_par03 = 1 //Bloqueio por Credito
	cWhere += " AND C9_BLCRED <> '' AND C9_BLCRED <> '10'"
ElseIf mv_par03 = 2 //Bloqueio por Transporte
	cWhere += " AND C9_BLTMS <> ''"
EndIf	
cWhere += "%"

	BeginSql Alias cAliasQry	
	
		SELECT C9_LOTNFC, C9_PEDIDO, C9_ITEM, C9_BLTMS, C9_BLCRED, C9_CLIENTE, C9_LOJA, A1_NREDUZ,
       	    C9_PRODUTO, C9_QTDLIB

		FROM %table:SC9% SC9

		JOIN %table:SA1% SA1 ON
		A1_FILIAL = %xFilial:SA1%
		AND C9_CLIENTE = A1_COD
		AND C9_LOJA = A1_LOJA
		AND SA1.%NotDel%

		WHERE C9_FILIAL = %xFilial:SC9%
		AND C9_LOTNFC >= %Exp:mv_par01%
		AND C9_LOTNFC <= %Exp:mv_par02%		
		AND C9_LOTNFC <> ' '
		AND SC9.%NotDel%
		%Exp:cWhere%

	EndSql

oReport:Section(1):EndQuery()

oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter({ |cParam| (cAliasQry)->C9_LOTNFC+(cAliasQry)->C9_PEDIDO == cParam },{ || (cAliasQry)->C9_LOTNFC+(cAliasQry)->C9_PEDIDO })

oReport:Section(1):Print()

oReport:SetMeter(SC9->(LastRec()))

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMR010Desc� Autor � Rodolfo K. Rosseto    � Data �30.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a Descricao dos Bloqueios de Credito               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMR010Desc(ExpC1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo do Bloqueio de Credito                      ���
���          �                                                            ���
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMR010Desc(cCodBlq)

Local cDesc := ""

Default cCodBlq := ""

If cCodBlq == "01"
	cDesc := STR0030 //"BLOQUEIO DE CREDITO POR VALOR"
ElseIf cCodBlq == "04"
	cDesc := STR0031 //"VENCTO DO LIMITE DE CREDITO"
ElseIf cCodBlq == "05"
	cDesc := STR0032 //"BLOQUEIO DE CREDITO POR ESTORNO"
ElseIf cCodBlq == "06"
	cDesc := STR0033 //"BLOQUEIO DE CREDITO POR RISCO"
ElseIf cCodBlq == "09"
	cDesc := STR0034 //"REJEICAO DE CREDITO"
EndIf

Return cDesc
