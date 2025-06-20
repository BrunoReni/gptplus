#INCLUDE "TMSR080.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMSR080   � Autor �Rodolfo K. Rosseto     � Data �31/05/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Emissao da Relacao dos Enderecos do Solicitante             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMSR080()

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
Local oSolic
Local oEnd

oReport := TReport():New("TMSR080",STR0012,"TMR080", {|oReport| ReportPrint(oReport)},STR0013)
oReport:SetTotalInLine(.F.)
Pergunte("TMR080",.F.)

oSolic := TRSection():New(oReport,STR0014,{"DUE","DUL"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSolic:SetTotalInLine(.F.)
TRCell():New(oSolic,"DUL_CODSOL"	,"DUL",STR0024,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_NOME"		,"DUE",STR0015,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_DDD"		,"DUE",STR0016,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_TEL"		,"DUE",STR0017,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oEnd := TRSection():New(oSolic,STR0018,{"DUL"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oEnd:SetTotalInLine(.F.)
TRCell():New(oEnd,"DUL_SEQEND"	,"DUL",STR0019,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnd,"DUL_END"		,"DUL",STR0018,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnd,"DUL_BAIRRO"	,"DUL",STR0020,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnd,"DUL_MUN"		,"DUL",STR0021,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnd,"DUL_EST"		,"DUL",STR0022,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnd,"DUL_CEP"		,"DUL",STR0023,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

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
//�Query do relatorio da secao Enderecos do Solicitante                    �
//��������������������������������������������������������������������������
oReport:Section(1):BeginQuery()

	BeginSql Alias cAliasQry
	
	SELECT DUL_FILIAL, DUL_CODSOL, DUE_DDD, DUE_TEL, DUL_SEQEND, DUL_END, DUL_BAIRRO, DUL_MUN, DUL_EST, DUL_CEP, DUE_NOME

	FROM %table:DUL% DUL

	JOIN %table:DUE% DUE ON
	DUE_FILIAL = %xFilial:DUE%
	AND DUE_CODSOL = DUL_CODSOL
	AND DUE.%NotDel%

	WHERE DUL_FILIAL = %xFilial:DUL%
		AND DUL_CODSOL >= %Exp:mv_par01%
		AND DUL_CODSOL <= %Exp:mv_par02%
		AND DUL.%NotDel%
		
	ORDER BY DUL_FILIAL, DUL_CODSOL, DUL_SEQEND

	EndSql

oReport:Section(1):EndQuery()

oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter({ |cParam| (cAliasQry)->DUL_CODSOL == cParam },{ || (cAliasQry)->DUL_CODSOL })

oReport:Section(1):Print()

oReport:SetMeter(DUL->(LastRec()))

Return