#INCLUDE "TMSR070.ch"
#INCLUDE "rwmake.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMSR070   � Autor �Rodolfo K. Rosseto     � Data �31/05/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Emissao da Relacao do Cadastro de Solicitantes              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMSR070()

Local oReport
Local aArea := GetArea()
Local aCposProtg      := {}
Local aCpoAccess	  := {'DUE_BAIRRO','DUE_CEP','DUE_DDD','DUE_TEL','DUE_CODMUN','DUE_END','DUE_MUN','DUE_EST','DUE_CGC','DUE_CONTAT','DUE_NOME','DUE_NREDUZ','DUE_EMAIL'}

If ExistFunc('TMLGPDCpPr')
	aCposProtg := TMLGPDCpPr(aCpoAccess, "DUE")
	If ExistFunc('FWPDCanUse') .And. FWPDCanUse() .And. !Empty(aCposProtg)
		If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, aCposProtg )) < Len(aCposProtg)
			Help(" ",1,STR0056,,,5,11) //"LGPD - Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Para mais informa��es contate o Administrador do sistema !!"
			Return
		EndIf	
	EndIf
EndIf

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
Local oProd
Local cAliasQry   := GetNextAlias()
Local aOrdem      := {}

Aadd( aOrdem, STR0054) // 'Cod Solicit' 
Aadd( aOrdem, STR0024) // 'Nome'

oReport := TReport():New("TMSR070",STR0019,"TMR080", {|oReport| ReportPrint(oReport,cAliasQry)},STR0020)
oReport:SetTotalInLine(.F.)
Pergunte("TMR080",.F.)

oSolic:= TRSection():New(oReport,STR0021,{"DUE"},aOrdem/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSolic:SetTotalInLine(.F.)
oSolic:SetLineBreak(.T.) //Pular linha quando execeder o numero de campos em uma linha
TRCell():New(oSolic,"DUE_CODSOL"	,"DUE",STR0054,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_DDD"		,"DUE",STR0022,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_TEL"		,"DUE",STR0023,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_NOME"	,"DUE",STR0024,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_NREDUZ"	,"DUE",STR0025,/*Picture*/,10,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_END"		,"DUE",STR0026,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_MUN"		,"DUE",STR0027,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_EST"		,"DUE",STR0028,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_BAIRRO"	,"DUE",STR0029,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_CEP"		,"DUE",STR0030,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_PONREF"	,"DUE",STR0031,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_CGC"		,"DUE",STR0032,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_INSCR"	,"DUE",STR0033,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_CONTAT"	,"DUE",STR0034,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_EMAIL"	,"DUE",STR0035,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_DATCAD"	,"DUE",STR0036,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_TIPTRA"	,"DUE",STR0037,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DESCTIPTRA"	,"   ",STR0038,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| TMSValField(cAliasQry+'->DUE_TIPTRA',.F.) })
TRCell():New(oSolic,"DUE_TIPCOL"	,"DUE",STR0039,/*Picture*/,10,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"SEGUNDA"		,"   ",STR0040,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Iif((cAliasQry)->DUE_COLSEG == "1",STR0015,STR0016) })
TRCell():New(oSolic,"TERCA"		,"   ",STR0041,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Iif((cAliasQry)->DUE_COLTER == "1",STR0015,STR0016) })
TRCell():New(oSolic,"QUARTA"		,"   ",STR0042,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Iif((cAliasQry)->DUE_COLQUA == "1",STR0015,STR0016) })
TRCell():New(oSolic,"QUINTA"		,"   ",STR0043,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Iif((cAliasQry)->DUE_COLQUI == "1",STR0015,STR0016) })
TRCell():New(oSolic,"SEXTA"		,"   ",STR0044,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Iif((cAliasQry)->DUE_COLSEX == "1",STR0015,STR0016) })
TRCell():New(oSolic,"SABADO"		,"   ",STR0045,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Iif((cAliasQry)->DUE_COLSAB == "1",STR0015,STR0016) })
TRCell():New(oSolic,"DOMINGO"		,"   ",STR0046,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Iif((cAliasQry)->DUE_COLDOM == "1",STR0015,STR0016) })
TRCell():New(oSolic,"DUE_HORCOI"	,"DUE",STR0047,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_HORCOF"	,"DUE",STR0048,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oProd:= TRSection():New(oSolic,STR0049,{"DVJ","SB1"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oProd:SetTotalInLine(.F.)
TRCell():New(oProd,"DVJ_CODPRO"	,"DVJ",STR0049,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProd,"B1_DESC"		,"SB1",STR0050,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProd,"DVJ_CODEMB"	,"DVJ",STR0051,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProd,"DESCEMB"		,"   ",STR0052,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Tabela("MG", (cAliasQry)->DVJ_CODEMB, .F.) })

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

Local cOrder := ''
//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)
//������������������������������������������������������������������������Ŀ
//�Query do relatorio da secao Rodovias                                    �
//��������������������������������������������������������������������������
oReport:Section(1):BeginQuery()

If oReport:Section(1):GetOrder() == 1
	cOrder := "%, DUE_CODSOL%"
Else
	cOrder := "%, DUE_NOME%"
EndIf

	BeginSql Alias cAliasQry
	
	SELECT DUE_CODSOL, DUE_DDD, DUE_TEL, DUE_NOME, DUE_NREDUZ, DUE_END, DUE_MUN, DUE_EST, DUE_BAIRRO, DUE_CEP, DUE_PONREF,
		    DUE_CGC, DUE_INSCR, DUE_CONTAT, DUE_EMAIL, DUE_DATCAD, DUE_TIPTRA, DUE_TIPCOL, DUE_HORCOI, DUE_HORCOF,
		    DUE_COLSEG, DUE_COLTER, DUE_COLQUA, DUE_COLQUI, DUE_COLSEX, DUE_COLSAB, DUE_COLDOM, DUE_FILIAL,
		    DVJ_CODPRO, B1_DESC, DVJ_CODEMB

	FROM %table:DUE% DUE

	JOIN %table:DVJ% DVJ ON
	DVJ_FILIAL = %xFilial:DVJ%
	AND DVJ_CODSOL = DUE_CODSOL
	AND DVJ.%NotDel%
	
	JOIN %table:SB1% SB1 ON
	B1_FILIAL = %xFilial:SB1%
	AND B1_COD = DVJ_CODPRO
	AND SB1.%NotDel%

	WHERE DUE_FILIAL = %xFilial:DUE%
		AND DUE_CODSOL >= %Exp:mv_par01%
		AND DUE_CODSOL <= %Exp:mv_par02%
		AND DUE.%NotDel%
		
	ORDER BY DUE_FILIAL%Exp:cOrder%

	EndSql

oReport:Section(1):EndQuery()

oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter({ |cParam| (cAliasQry)->DUE_CODSOL == cParam },{ || (cAliasQry)->DUE_CODSOL})

oReport:Section(1):Print()

oReport:SetMeter(DUE->(LastRec()))

Return