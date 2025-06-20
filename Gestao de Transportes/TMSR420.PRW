#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSR420.CH"

Static aConhecSum := {}

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR420  � Autor � Eduardo de Souza      � Data � 24/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio Averbacao de Seguro.                             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR420()

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
Local cAliasQry2 := GetNextAlias()
Local aOrdem    := {}
Local oBreak

aConhecSum := {}

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
oReport:= TReport():New("TMSR420",STR0025,"TMR420", {|oReport| ReportPrint(oReport,cAliasQry,cAliasQry2)},STR0026) // "Impressao da Averba��o de Seguro" ### "Emite a relacao de Averba��o de Seguro conforme os par�metros informados."
oReport:SetTotalInLine(.F.)
oReport:SetLandScape(.T.)
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
Aadd( aOrdem, STR0027 ) // "Ramo + Origem + Destino"

oRamo:= TRSection():New(oReport,STR0050,{"DU7","DU3"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oRamo:SetTotalInLine(.F.)
oRamo:SetPageBreak(.T.)
TRCell():New(oRamo,"DU7_COMSEG","DU7",STR0050,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRamo,"DU3_DESCRI","DU3",STR0045,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oDocto:= TRSection():New(oRamo,STR0028,{"DT6","DU7","SA1"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oDocto:SetTotalInLine(.F.)
oDocto:SetTotalText(STR0049) // "Total do Ramo"
TRCell():New(oDocto,"DT6_DATEMI","DT6",STR0029,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oDocto,"DU7_FILDOC","DT6",STR0030,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oDocto,"DU7_DOC"   ,"DT6",STR0031,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oDocto,SerieNfId("DU7",3,"DU7_SERIE") ,"DT6",STR0032,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oDocto,"DT6_TIPFRE","DT6",STR0033,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oDocto,"DT6_CLIDEV","DT6",STR0034,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oDocto,"DT6_LOJDEV","DT6",STR0035,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oDocto,"A1_NREDUZ" ,"SA1",STR0036,/*Picture*/,30         ,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oDocto,"DT6_VALMER","DT6",STR0037,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.T.)
TRCell():New(oDocto,"DT6_SERVIC","DT6",STR0038,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oDocto,"DT6_DESSVT","DT6",STR0039,/*Picture*/,20         ,/*lPixel*/, {|| Tabela("L4",(cAliasQry)->DT6_SERVIC,.F.) },,,,,,.F.)
TRCell():New(oDocto,"DT6_REGORI","DT6",STR0041,/*Picture*/,20         ,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oDocto,"DT6_REGDES","DT6",STR0043,/*Picture*/,20         ,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oDocto,"DU7_COMSEG","DU7",STR0044,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oDocto,"DU3_DESCRI","DU3",STR0045,/*Picture*/,20         ,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oDocto,"DVD_PERAJU","DVD",STR0046,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| IIf(!Empty((cAliasQry)->DU7_INTERV),(cAliasQry)->DU7_VALOR/(cAliasQry)->DU7_INTERV,(cAliasQry)->DU7_VALOR) },,,,,,.T.)
TRCell():New(oDocto,"DU7_PREMIO","DU7",STR0047,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.T.)

oBreak := TRBreak():New(oDocto,{ || TMR420Qbr((cAliasQry)->DT6_REGORI,(cAliasQry)->DT6_REGDES,(cAliasQry)->DU7_COMSEG) },STR0048,.F.) // "Total da Regi�o"
TRFunction():New(oDocto:Cell("DT6_VALMER"),/*cId*/,"SUM",oBreak    ,/*cTitle*/,/*cPicture*/,{ || If( VldSumMerc("N",(cAliasQry)->DU7_COMSEG,(cAliasQry)->DU7_FILDOC,(cAliasQry)->DU7_DOC,(cAliasQry)->DU7_SERIE), (cAliasQry)->DT6_VALMER, 0 ) },   /*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDocto:Cell("DU7_PREMIO"),/*cId*/,"SUM",oBreak    ,/*cTitle*/,/*cPicture*/,/*uFormula*/,   /*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDocto:Cell("DT6_VALMER"),/*cId*/,"SUM",          ,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,   /*lEndReport*/,.F./*lEndPage*/,oRamo)
TRFunction():New(oDocto:Cell("DU7_PREMIO"),/*cId*/,"SUM",          ,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,   /*lEndReport*/,.F./*lEndPage*/,oRamo)

oDocto1:= TRSection():New(oReport,STR0028,{"DT6","DU7","SA1"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oDocto1:SetPageBreak(.T.)
oDocto1:SetTotalInLine(.F.)
oDocto1:SetTotalText(STR0051) // "Total por parte do Cliente"
TRCell():New(oDocto1,"DT6_DATEMI","DT6",STR0029,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto1,"DU7_FILDOC","DT6",STR0030,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto1,"DU7_DOC"   ,"DT6",STR0031,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto1,SerieNfId("DU7",3,"DU7_SERIE") ,"DT6",STR0032,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto1,"DT6_TIPFRE","DT6",STR0033,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto1,"DT6_CLIDEV","DT6",STR0034,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto1,"DT6_LOJDEV","DT6",STR0035,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto1,"A1_NREDUZ" ,"SA1",STR0036,/*Picture*/,30         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto1,"DT6_VALMER","DT6",STR0037,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto1,"DT6_SERVIC","DT6",STR0038,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto1,"DT6_DESSVT","DT6",STR0039,/*Picture*/,20         ,/*lPixel*/, {|| Tabela("L4",(cAliasQry2)->DT6_SERVIC,.F.) } )
TRCell():New(oDocto1,"DT6_REGORI","DT6",STR0041,/*Picture*/,20         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto1,"DT6_REGDES","DT6",STR0043,/*Picture*/,20         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto1,"DU7_COMSEG","DU7",STR0044,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto1,"DU3_DESCRI","DU3",STR0045,/*Picture*/,20         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto1,"DVD_PERAJU","DVD",STR0046,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| IIf(!Empty((cAliasQry2)->DU7_INTERV),(cAliasQry2)->DU7_VALOR/(cAliasQry2)->DU7_INTERV,(cAliasQry2)->DU7_VALOR) } )
TRCell():New(oDocto1,"DU7_PREMIO","DU7",STR0047,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRFunction():New(oDocto1:Cell("DT6_VALMER"),/*cId*/,"SUM",/*oBreak1*/,/*cTitle*/,/*cPicture*/,{ || If( VldSumMerc("S",(cAliasQry2)->DU7_COMSEG,(cAliasQry2)->DU7_FILDOC,(cAliasQry2)->DU7_DOC,(cAliasQry2)->DU7_SERIE), (cAliasQry2)->DT6_VALMER, 0 ) },/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

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
Static Function ReportPrint(oReport,cAliasQry,cAliasQry2)

Local nCnt := 0
Local cFecht:= ""

If SerieNfId("DU7",3,"DU7_SERIE")=="DU7_SDOC"
	cFecht :='%DU7_SDOC,%'
Else
	cFecht :='%%'
EndIf

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
If mv_par07 == 2
oReport:Section(1):BeginQuery()
BeginSql Alias cAliasQry
	SELECT DU7_FILDOC, DU7_DOC   , DU7_SERIE , %Exp:cFecht% DU7_CLIAVB, DU7_LOJAVB, DU7_COMSEG , DU7_VALOR, 
	       DU7_INTERV, DT6_DATEMI, DT6_TIPFRE, DT6_CLIDEV, DT6_LOJDEV, DT6_VALMER , DT6_SERVIC,
	       DT6_CDRORI, DT6_CDRDES, DU7_PREMIO, DU7_FILIAL, A1_NREDUZ, DU3_DESCRI, DUYA.DUY_DESCRI DT6_REGORI,
			 DUYB.DUY_DESCRI DT6_REGDES
	   FROM %table:DT6% DT6
	   JOIN %table:DU7% DU7
	      ON  DU7_FILIAL = %xFilial:DU7%
	      AND DU7_FILDOC = DT6_FILDOC
	      AND DU7_DOC    = DT6_DOC
	      AND DU7_SERIE  = DT6_SERIE
	      AND DU7_COMSEG >= %Exp:mv_par05%
	      AND DU7_COMSEG <= %Exp:mv_par06%
	      AND DU7_CLIAVB = ' '
	      AND DU7_LOJAVB = ' '
	      AND DU7.%NotDel%
	   JOIN %table:DUY% DUYA
	     ON DUYA.DUY_FILIAL  = %xFilial:DUY%
	     AND DUYA.DUY_GRPVEN = DT6_CDRORI
	     AND DUYA.%NotDel%
	   JOIN %table:DUY% DUYB
	     ON DUYB.DUY_FILIAL  = %xFilial:DUY%
	     AND DUYB.DUY_GRPVEN = DT6_CDRDES
	     AND DUYB.%NotDel%
	   JOIN %table:DU3% DU3
	     ON DU3_FILIAL  = %xFilial:DU3%
	     AND DU3_COMSEG = DU7_COMSEG
	     AND DU3.%NotDel%
	   JOIN %table:SA1% SA1
	     ON A1_FILIAL = %xFilial:SA1%
	     AND A1_COD  = DT6_CLIDEV
	     AND A1_LOJA = DT6_LOJDEV
	     AND SA1.%NotDel%
	   WHERE DT6_FILIAL = %xFilial:DT6%
	      AND DT6_FILDOC >= %Exp:mv_par01%
	      AND DT6_FILDOC <= %Exp:mv_par02%
	      AND DT6_DATEMI >= %Exp:Dtos(mv_par03)%
	      AND DT6_DATEMI <= %Exp:Dtos(mv_par04)%
	      AND DT6_DOCTMS <> %Exp:StrZero(1,Len(DT6->DT6_DOCTMS))%
	      AND DT6.%NotDel%
	ORDER BY DU7_FILIAL, DU7_CLIAVB, DU7_LOJAVB, DU7_COMSEG, DT6_CDRORI, DT6_CDRDES, DU7_FILDOC, DU7_DOC, DU7_SERIE	
EndSql
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
Else 
oReport:Section(1):BeginQuery()
BeginSql Alias cAliasQry 	
	SELECT DU7_FILDOC, DU7_DOC   , DU7_SERIE , %Exp:cFecht% DU7_CLIAVB, DU7_LOJAVB, DU7_COMSEG , DU7_VALOR, 
	       DU7_INTERV, DT6_DATEMI, DT6_TIPFRE, DT6_CLIDEV, DT6_LOJDEV, DT6_VALMER , DT6_SERVIC,
	       DT6_CDRORI, DT6_CDRDES, Sum(DU7_PREMIO) as DU7_PREMIO, DU7_FILIAL, A1_NREDUZ, DU3_DESCRI, DUYA.DUY_DESCRI DT6_REGORI,
			 DUYB.DUY_DESCRI DT6_REGDES
	   FROM %table:DT6% DT6
	   JOIN %table:DU7% DU7
	      ON  DU7_FILIAL = %xFilial:DU7%
	      AND DU7_FILDOC = DT6_FILDOC
	      AND DU7_DOC    = DT6_DOC
	      AND DU7_SERIE  = DT6_SERIE
	      AND DU7_COMSEG >= %Exp:mv_par05%
	      AND DU7_COMSEG <= %Exp:mv_par06%
	      AND DU7_CLIAVB = ' '
	      AND DU7_LOJAVB = ' '
	      AND DU7.%NotDel%
	   JOIN %table:DUY% DUYA
	     ON DUYA.DUY_FILIAL  = %xFilial:DUY%
	     AND DUYA.DUY_GRPVEN = DT6_CDRORI
	     AND DUYA.%NotDel%
	   JOIN %table:DUY% DUYB
	     ON DUYB.DUY_FILIAL  = %xFilial:DUY%
	     AND DUYB.DUY_GRPVEN = DT6_CDRDES
	     AND DUYB.%NotDel%
	   JOIN %table:DU3% DU3
	     ON DU3_FILIAL  = %xFilial:DU3%
	     AND DU3_COMSEG = DU7_COMSEG
	     AND DU3.%NotDel%
	   JOIN %table:SA1% SA1
	     ON A1_FILIAL = %xFilial:SA1%
	     AND A1_COD  = DT6_CLIDEV
	     AND A1_LOJA = DT6_LOJDEV
	     AND SA1.%NotDel%
	   WHERE DT6_FILIAL = %xFilial:DT6%
	      AND DT6_FILDOC >= %Exp:mv_par01%
	      AND DT6_FILDOC <= %Exp:mv_par02%
	      AND DT6_DATEMI >= %Exp:Dtos(mv_par03)%
	      AND DT6_DATEMI <= %Exp:Dtos(mv_par04)%
	      AND DT6_DOCTMS <> %Exp:StrZero(1,Len(DT6->DT6_DOCTMS))%
	      AND DT6.%NotDel%	
	GROUP BY DU7_FILDOC, DU7_DOC   , DU7_SERIE ,  %Exp:cFecht% DU7_CLIAVB, DU7_LOJAVB, DU7_COMSEG , DU7_VALOR, 
	         DU7_INTERV, DT6_DATEMI, DT6_TIPFRE, DT6_CLIDEV, DT6_LOJDEV, DT6_VALMER , DT6_SERVIC,
	         DT6_CDRORI, DT6_CDRDES, DU7_FILIAL, A1_NREDUZ, DU3_DESCRI, DUYA.DUY_DESCRI,
			  DUYB.DUY_DESCRI
   ORDER BY DU7_FILIAL, DU7_CLIAVB, DU7_LOJAVB, DU7_COMSEG, DT6_CDRORI, DT6_CDRDES, DU7_FILDOC, DU7_DOC, DU7_SERIE
   EndSql
   oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
EndIF   			  
//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������
If mv_par07 == 2
oReport:Section(2):BeginQuery()	
BeginSql Alias cAliasQry2
	SELECT DU7_FILDOC, DU7_DOC   , DU7_SERIE , %Exp:cFecht% DU7_CLIAVB, DU7_LOJAVB, DU7_COMSEG , DU7_VALOR, 
	       DU7_INTERV, DT6_DATEMI, DT6_TIPFRE, DT6_CLIDEV, DT6_LOJDEV, DT6_VALMER , DT6_SERVIC,
	       DT6_CDRORI, DT6_CDRDES, DU7_PREMIO, DU7_FILIAL, A1_NREDUZ , DU3_DESCRI, DUYA.DUY_DESCRI DT6_REGORI,
			 DUYB.DUY_DESCRI DT6_REGDES
	   FROM %table:DT6% DT6
	   JOIN %table:DU7% DU7
	      ON  DU7_FILIAL = %xFilial:DU7%
	      AND DU7_FILDOC = DT6_FILDOC
	      AND DU7_DOC    = DT6_DOC
	      AND DU7_SERIE  = DT6_SERIE
	      AND DU7_COMSEG >= %Exp:mv_par05%
	      AND DU7_COMSEG <= %Exp:mv_par06%
	      AND DU7_CLIAVB <> ' '
	      AND DU7_LOJAVB <> ' '
	      AND DU7.%NotDel%
	   JOIN %table:DUY% DUYA
	     ON DUYA.DUY_FILIAL  = %xFilial:DUY%
	     AND DUYA.DUY_GRPVEN = DT6_CDRORI
	     AND DUYA.%NotDel%
	   JOIN %table:DUY% DUYB
	     ON DUYB.DUY_FILIAL  = %xFilial:DUY%
	     AND DUYB.DUY_GRPVEN = DT6_CDRDES
	     AND DUYB.%NotDel%
	   JOIN %table:DU3% DU3
	     ON DU3_FILIAL  = %xFilial:DU3%
	     AND DU3_COMSEG = DU7_COMSEG
	     AND DU3.%NotDel%
	   JOIN %table:SA1% SA1
	     ON A1_FILIAL = %xFilial:SA1%
	     AND A1_COD  = DT6_CLIDEV
	     AND A1_LOJA = DT6_LOJDEV
	     AND SA1.%NotDel%
	   WHERE DT6_FILIAL = %xFilial:DT6%
	      AND DT6_FILDOC >= %Exp:mv_par01%
	      AND DT6_FILDOC <= %Exp:mv_par02%
	      AND DT6_DATEMI >= %Exp:Dtos(mv_par03)%
	      AND DT6_DATEMI <= %Exp:Dtos(mv_par04)%
	      AND DT6_DOCTMS <> %Exp:StrZero(1,Len(DT6->DT6_DOCTMS))%
	      AND DT6.%NotDel%
	ORDER BY DU7_FILIAL, DU7_COMSEG, DT6_CDRORI, DT6_CDRDES, DU7_FILDOC, DU7_DOC, DU7_SERIE
EndSql 
oReport:Section(2):EndQuery(/*Array com os parametros do tipo Range*/)
Else
oReport:Section(2):BeginQuery()	
BeginSql Alias cAliasQry2	
	SELECT DU7_FILDOC, DU7_DOC   , DU7_SERIE , %Exp:cFecht% DU7_CLIAVB, DU7_LOJAVB, DU7_COMSEG , DU7_VALOR, 
	       DU7_INTERV, DT6_DATEMI, DT6_TIPFRE, DT6_CLIDEV, DT6_LOJDEV, DT6_VALMER , DT6_SERVIC,
	       DT6_CDRORI, DT6_CDRDES, Sum(DU7_PREMIO) as DU7_PREMIO, DU7_FILIAL, A1_NREDUZ , DU3_DESCRI, DUYA.DUY_DESCRI DT6_REGORI,
			 DUYB.DUY_DESCRI DT6_REGDES
	   FROM %table:DT6% DT6
	   JOIN %table:DU7% DU7
	      ON  DU7_FILIAL = %xFilial:DU7%
	      AND DU7_FILDOC = DT6_FILDOC
	      AND DU7_DOC    = DT6_DOC
	      AND DU7_SERIE  = DT6_SERIE
	      AND DU7_COMSEG >= %Exp:mv_par05%
	      AND DU7_COMSEG <= %Exp:mv_par06%
	      AND DU7_CLIAVB <> ' '
	      AND DU7_LOJAVB <> ' '
	      AND DU7.%NotDel%
	   JOIN %table:DUY% DUYA
	     ON DUYA.DUY_FILIAL  = %xFilial:DUY%
	     AND DUYA.DUY_GRPVEN = DT6_CDRORI
	     AND DUYA.%NotDel%
	   JOIN %table:DUY% DUYB
	     ON DUYB.DUY_FILIAL  = %xFilial:DUY%
	     AND DUYB.DUY_GRPVEN = DT6_CDRDES
	     AND DUYB.%NotDel%
	   JOIN %table:DU3% DU3
	     ON DU3_FILIAL  = %xFilial:DU3%
	     AND DU3_COMSEG = DU7_COMSEG
	     AND DU3.%NotDel%
	   JOIN %table:SA1% SA1
	     ON A1_FILIAL = %xFilial:SA1%
	     AND A1_COD  = DT6_CLIDEV
	     AND A1_LOJA = DT6_LOJDEV
	     AND SA1.%NotDel%
	   WHERE DT6_FILIAL = %xFilial:DT6%
	      AND DT6_FILDOC >= %Exp:mv_par01%
	      AND DT6_FILDOC <= %Exp:mv_par02%
	      AND DT6_DATEMI >= %Exp:Dtos(mv_par03)%
	      AND DT6_DATEMI <= %Exp:Dtos(mv_par04)%
	      AND DT6_DOCTMS <> %Exp:StrZero(1,Len(DT6->DT6_DOCTMS))%
	      AND DT6.%NotDel%	
	GROUP BY DU7_FILDOC, DU7_DOC   , DU7_SERIE , DU7_CLIAVB, DU7_LOJAVB, DU7_COMSEG , DU7_VALOR, 
	         DU7_INTERV, DT6_DATEMI, DT6_TIPFRE, DT6_CLIDEV, DT6_LOJDEV, DT6_VALMER , DT6_SERVIC,
	         DT6_CDRORI, DT6_CDRDES, DU7_FILIAL, A1_NREDUZ , DU3_DESCRI, DUYA.DUY_DESCRI,
			  DUYB.DUY_DESCRI
    ORDER BY DU7_FILIAL, DU7_COMSEG, DT6_CDRORI, DT6_CDRDES, DU7_FILDOC, DU7_DOC, DU7_SERIE
    EndSql 
    oReport:Section(2):EndQuery(/*Array com os parametros do tipo Range*/)
EndIF    	

//-- Inicio da impressao do fluxo do relat�rio
oReport:SetMeter(DT6->(LastRec()))

oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter( { |cParam| (cAliasQry)->DU7_COMSEG == cParam },{ || (cAliasQry)->DU7_COMSEG })

oReport:Section(1):Print()
oReport:PrintTotal()

//-- Nao imprime o totalizador geral da secao 2
For nCnt := 1 To Len(oReport:aFunction)
	oReport:aFunction[nCnt]:lEndReport := .F.
Next nCnt

oReport:Section(2):Print()
Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMR420Qbr � Autor �Eduardo de Souza       � Data � 24/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Controla a quebra do totalizador                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Regiao Origem                                        ���
���          �ExpC2: Regiao Destino                                       ���
���          �ExpC3: Ramo                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR420                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMR420Qbr(cRegOri,cRegDes,cRamo)
Default cRegOri := ''
Default cRegDes := ''
Default cRamo   := ''

Return(cRegOri + cRegDes + cRamo)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �VldSumMerc � Autor � Marcelo Nunes        � Data �09/06/2016���
�������������������������������������������������������������������������Ĵ��
���Descricao � Nao somar valor mercad. quando repetir linha para o conhec.���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldSumMerc( cPossuiCli, cComp, cFil, cDoc, cSerie)

//Local i
Local lSum := .F.  
  IF aScan(aConhecSum,cPossuiCli+cComp+cFil+cDoc+cSerie) == 0  
    lSum := .T.
    aAdd(aConhecSum,cPossuiCli+cComp+cFil+cDoc+cSerie)
  EndIF

Return lSum