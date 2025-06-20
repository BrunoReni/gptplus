#INCLUDE "finr014.ch"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FINR014   � Autor �Paulo Augusto       � Data �  20/08/02   ���
�������������������������������������������������������������������������͹��
���Descricao � Programa para imprimir os comprovantes de entrega do talao ���
���          � de recibo para o Cobrador                                  ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FINR014()

	Local oReport

	//�������������������������Ŀ
	//�Interface de impressao   �
	//���������������������������
	oReport	:= ReportDef()
	oReport:PrintDialog()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Paulo Augusto          � Data �28/06/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
	
	Local oReport	:= Nil
	Local oSection1	:= Nil
	Local oSection2	:= Nil
	Local cReport	:= "FINR014"
	Local cTitulo	:= OemToAnsi(STR0003) //"Lista recibos pendientes por cobrador"
	Local cDescri	:= OemToAnsi(STR0001)+" "+OemToAnsi(STR0002) //"Este programa tiene como objet." - "imprimir la ctd. de recibos pend.   "

	Pergunte( "FIR014" , .F. )

	oReport  := TReport():New( cReport, cTitulo, "FIR014" , { |oReport| ReportPrint( oReport, "SAQ" ) }, cDescri )

	//������������������������������������������������������Ŀ
	//� Define a 1a. secao do relatorio Valores nas Moedas   �
	//��������������������������������������������������������
	oSection1 := TRSection():New( oReport,STR0012 , {"SAQ"} )//"Cobradores"

	TRCell():New( oSection1, "AQ_COD" ,"SAQ" ,/*X3Titulo*/  ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{code-block de impressao}*/)
	TRCell():New( oSection1, "AQ_NOME","SAQ" ,/*X3Titulo*/ ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{code-block de impressao}*/)

	oSection2 := TRSection():New( oSection1, STR0013 , {"SEY"} )//"Taloes"

	TRCell():New( oSection2, "TALAO" 	    ,   	, STR0010  ,/*Picture*/,3,/*lPixel*/,{|| 1}) //"CTD de Talon. "
	TRCell():New( oSection2, "EY_COBRAD" 	,"SEY"	, /*X3Titulo*/  ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||code-block de impressao}*/)
	TRCell():New( oSection2, "EY_TALAO" 	,"SEY"	, /*X3Titulo*/  ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao}*/)
	TRCell():New( oSection2, "EY_DATA"   	,"SEY"	, /*X3Titulo()*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||code-block de impressao }*/)
	TRCell():New( oSection2, "TIPO"      	,		, /*X3Titulo()*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{||  If (EY_TIPOREC="1",STR0008,STR0009) }) //"OFICIAL" - "PROVISORIO"
	TRCell():New( oSection2, "EY_SERIE"		,"SEY" 	, /*X3Titulo()*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection2, "EY_RECINI" 	,"SEY" 	, /*X3Titulo()*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection2, "EY_RECFIN" 	,"SEY" 	, /*X3Titulo()*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection2, "EY_RECPEND" 	,"SEY" 	, /*X3Titulo()*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

Return oReport

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �ReportPrint�Autor  �Paulo Augusto       � Data �  27/06/06   ���
��������������������������������������������������������������������������͹��
���Desc.     �Query de impressao do relatorio                              ���
��������������������������������������������������������������������������͹��
���Uso       � SIGAFIN                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport )
	
	Local oSection1	:= oReport:Section(1)
	Local oSection2	:= oSection1:Section(1)
	Local cAlias	:= GetNextAlias()
	Local oBreak1	:= Nil

	MakeSqlExpr("FIR014")
	oSection1:BeginQuery()
	BeginSql alias cAlias
		SELECT EY_COBRAD,EY_STATUS,EY_RECPEND,EY_TALAO, EY_DATA ,EY_TIPOREC,EY_SERIE,EY_RECINI,EY_RECFIN,EY_RECPEND,AQ_COD,AQ_NOME 	FROM %table:SAQ% SAQ, %table:SEY% SEY
		WHERE	SAQ.AQ_FILIAL = %xfilial:SAQ%  AND
		SAQ.AQ_COD  >= %Exp:mv_par01% AND
		SAQ.AQ_COD <= %Exp:mv_par02% AND
		SAQ.AQ_FILIAL = %xfilial:SAQ%  AND
		SAQ.AQ_COD = SEY.EY_COBRAD  AND
		SAQ.%notDel% AND
		SEY.EY_STATUS <>'2' AND
		SEY.EY_RECPEND > 0 AND
		SEY.%notDel%
	
		ORDER BY AQ_COD,EY_DATA
	EndSql

	oSection2:SetParentQuery()
	oSection2:SetParentFilter({|cParam| (cAlias)->EY_COBRAD == cParam},{|| (cAlias)->AQ_COD})

	oSection1:EndQuery()

	oBreak1 := TRBreak():New( oSection1,oSection1:Cell("AQ_COD") ,STR0010) //"CTD de Talon. "

	TRFunction():New(oSection2:Cell("EY_RECPEND")	, , "SUM"  , oBreak1, , , , .F. ,  )
	TRFunction():New(oSection2:Cell("TALAO")	, , "COUNT", oBreak1, , , , .F. ,  )

	oSection1:Print()

Return Nil
