#INCLUDE "TMSR430.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR430  � Autor � Eduardo de Souza      � Data � 24/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de Retencao de ISS                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR430()

Local oReport
Local aArea := GetArea()

//-- Interface de impressao
oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Eduardo de Souza      � Data � 24/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR420                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local cAliasQry  := GetNextAlias()
Local aOrdem    := {}

oReport:= TReport():New("TMSR430",STR0009,"TMR430", {|oReport| ReportPrint(oReport,cAliasQry)},STR0010) // "Relacao de Retencao de ISS" ### "Emite a Relacao de Retencao de ISS"
oReport:SetTotalInLine(.F.)

//��������������������������������������������������������������Ŀ
//� Carrega as perguntas selecionadas                            �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01 - Periodo De         ?                              �
//� mv_par02 - Periodo Ate        ?                              �
//� mv_par03 - Proprietario De    ?                              �
//� mv_par04 - Loja De            ?                              �
//� mv_par05 - Proprietario Ate   ?                              �
//� mv_par06 - Loja Ate           ?                              �	 
//����������������������������������������������������������������

Pergunte(oReport:uParam,.F.)

Aadd( aOrdem, STR0011 ) // "Contrato"

oContr:= TRSection():New(oReport,STR0011,{"DTY","SA2"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oContr:SetTotalInLine(.F.)
oContr:SetTotalText(STR0013) //-- "Total Reten��o"
TRCell():New(oContr,"DTY_NUMCTC","DTC",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContr,"A2_NOME"   ,"SA2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContr,"A2_CGC"    ,"SA2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContr,"A2_END"    ,"SA2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContr,"DTY_ISS"   ,"DTY",STR0012   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRFunction():New(oContr:Cell("DTY_ISS"),/*cId*/,"SUM",/*oBreak1*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo de Souza       � Data � 24/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR420                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,cAliasQry)

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQry
	SELECT DTY_FILIAL, DTY_NUMCTC, SUM(DTY_ISS) DTY_ISS, MIN(A2_NOME) A2_NOME, MIN(A2_END) A2_END,  MIN(A2_CGC) A2_CGC
	   FROM %table:DTY% DTY
	   JOIN %table:SA2% SA2
	      ON  A2_FILIAL = %xFilial:SA2%
	      AND A2_COD  = DTY.DTY_CODFOR
	      AND A2_LOJA = DTY.DTY_LOJFOR
	      AND SA2.%NotDel%
	   WHERE DTY_FILIAL  = %xFilial:DTY%
			AND DTY.DTY_DATCTC BETWEEN %Exp:DTOS(mv_par01)% AND %Exp:DTOS(mv_par02)%
			AND DTY.DTY_CODFOR BETWEEN %Exp:mv_par03% AND %Exp:mv_par05%
			AND DTY.DTY_LOJFOR BETWEEN %Exp:mv_par04% AND %Exp:mv_par06%
			AND DTY.DTY_ISS > 0 
			AND DTY.%NotDel%
	GROUP BY DTY_FILIAL, DTY_NUMCTC
	ORDER BY DTY_FILIAL, DTY_NUMCTC
EndSql 


oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

//-- Inicio da impressao do fluxo do relat�rio
oReport:SetMeter(DTY->(LastRec()))

oReport:Section(1):Print()

Return