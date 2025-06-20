#INCLUDE "TMSR230.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR230  � Autor � Eduardo de Souza      � Data � 25/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Fluxo de Carga por filial.                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR230()

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
���Programa  �ReportDef � Autor � Eduardo de Souza      � Data � 25/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR230                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local cAliasQry := GetNextAlias()
Local aOrdem    := {}
Local aAreaSM0  := SM0->(GetArea())

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:= TReport():New("TMSR230",STR0012,"TMR230", {|oReport| ReportPrint(oReport,cAliasQry)},STR0013) // "Fluxo de Carga por Filial" ### "Este relat�rio ir� imprimir o fluxo de carga por filial."
oReport:SetTotalInLine(.F.)

//������������������������������������������������������������������������Ŀ
//�Verifica as Perguntas Seleciondas                                       �
//��������������������������������������������������������������������������
//��������������������������������������������������������������������������
//�mv_par01 - Filial origem De                                             �
//�mv_par02 - Filial origem Ate                                            �
//�mv_par03 - Data de Emiss�o De                                           �
//�mv_par04 - Data de Emiss�o Ate                                          �
//�mv_par05 - Docto. De                                                    �
//�mv_par06 - Docto. Ate                                                   �
//�mv_par07 - Tipo Transporte De                                           �
//�mv_par08 - Tipo Transporte Ate                                          �
//��������������������������������������������������������������������������
Pergunte(oReport:uParam,.F.)
//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
Aadd( aOrdem, STR0014 ) // "Fil.Origem + Fil.Destino"

oFilial:= TRSection():New(oReport,STR0015,{"DT6"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oFilial:SetTotalInLine(.F.)
TRCell():New(oFilial,"DT6_FILDOC","DT6",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilial,"DESFILDOC" ,""   ,STR0016   ,/*Picture*/, 15         ,/*lPixel*/, {|| Posicione("SM0",1,cEmpAnt+(cAliasQry)->DT6_FILDOC,"M0_FILIAL") })
TRCell():New(oFilial,"DT6_FILDES","DT6",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilial,"DESFILDES" ,""   ,STR0016   ,/*Picture*/, 15         ,/*lPixel*/, {|| Posicione("SM0",1,cEmpAnt+(cAliasQry)->DT6_FILDES,"M0_FILIAL") })

oDocto:= TRSection():New(oFilial,STR0017,{"DT6"},/*Ordem do relatorio*/,/*Campos do SX3*/,/*Campos do SIX*/)
oDocto:SetTotalInLine(.F.)
TRCell():New(oDocto,"DT6_DATEMI","DT6",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"QTDCTR"    ,""   ,STR0018   ,/*Picture*/, 4          ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DT6_PESO"  ,"DT6",/*cTitle*/,"@E 999,999,999.9999",15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DT6_PESOM3","DT6",/*cTitle*/,"@E 999,999,999.9999",15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DT6_VALMER","DT6",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DT6_QTDVOL","DT6",/*cTitle*/,"9999999", 7            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DT6_VALTOT","DT6",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRFunction():New(oDocto:Cell("QTDCTR"    ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oFilial)
TRFunction():New(oDocto:Cell("DT6_PESO"  ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oFilial)
TRFunction():New(oDocto:Cell("DT6_PESOM3"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oFilial)
TRFunction():New(oDocto:Cell("DT6_VALMER"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oFilial)
TRFunction():New(oDocto:Cell("DT6_QTDVOL"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oFilial)
TRFunction():New(oDocto:Cell("DT6_VALTOT"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oFilial)

RestArea( aAreaSM0 )

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
	SELECT DT6_FILDOC, DT6_FILDES, DT6_DATEMI, DT6_FILIAL, MAX(DT6_SERTMS) DT6_SERTMS, 
	       SUM(DT6_PESO) DT6_PESO    , SUM(DT6_PESOM3) DT6_PESOM3, SUM(DT6_VALMER) DT6_VALMER, 
	       SUM(DT6_QTDVOL) DT6_QTDVOL, SUM(DT6_VALTOT) DT6_VALTOT, COUNT(DT6_DOC) QTDCTR
	   FROM %table:DT6% DT6
	   WHERE DT6_FILIAL = %xFilial:DT6%
	     AND DT6_FILDOC BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
	     AND DT6_FILDES BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
	     AND DT6_DATEMI BETWEEN %Exp:DTOS(mv_par05)% AND %Exp:DTOS(mv_par06)%
	     AND DT6_SERTMS = %Exp:StrZero(2,Len(DT6->DT6_SERTMS))%
	     AND DT6.%NotDel%
	GROUP BY DT6_FILIAL, DT6_FILDOC, DT6_FILDES, DT6_DATEMI
	ORDER BY DT6_FILIAL, DT6_FILDOC, DT6_FILDES, DT6_DATEMI
EndSql 

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

//-- Inicio da impressao do fluxo do relat�rio
oReport:SetMeter(DT6->(LastRec()))

oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter( {|cParam| (cAliasQry)->DT6_FILDOC + (cAliasQry)->DT6_FILDES == cParam },{|| (cAliasQry)->DT6_FILDOC + (cAliasQry)->DT6_FILDES })

oReport:Section(1):Print()

Return