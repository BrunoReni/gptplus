#INCLUDE "TMSR410.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR410  � Autor � Eduardo de Souza      � Data � 23/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio Programacao Diaria                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR410()
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
���Programa  �ReportDef � Autor � Eduardo de Souza      � Data � 23/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local oServ
Local oViagem
Local oProd
Local oTotaliz
Local aOrdem     := {}
Local cAliasQry  := GetNextAlias()
Local cAliasQry2  := GetNextAlias()

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
oReport:= TReport():New("TMSR410",STR0012,"TMR410", {|oReport| ReportPrint(oReport,cAliasQry,cAliasQry2)},STR0013) // "Programacao Diaria" ### "Emite a relacao das viagens programadas conforme os parametros informados"
oReport:SetTotalInLine(.F.)
oReport:SetLandscape()

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01	 // Data De                                      �
//� mv_par02	 // Data Ate                                     �
//� mv_par03	 // Cliente De                                   �
//� mv_par04	 // Loja De                                      �
//� mv_par05	 // Cliente Ate                                  �
//� mv_par06     // Loja Ate                                     �
//� mv_par07	 // Veiculo De                                   �
//� mv_par08	 // Veiculo Ate                                  �
//� mv_par09	 // Servico de Transporte De                     �
//� mv_par10	 // Servico de Transporte Ate                    �
//����������������������������������������������������������������
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
Aadd( aOrdem, STR0014 ) // "Serv.Transp. + Fil.Origem + Viagem"

oServ:= TRSection():New(oReport,STR0015,{"DTQ"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Serv.Transp."
oServ:SetTotalInLine(.T.)
oServ:SetTotalText(STR0038) // "Total de Viagens"
oServ:SetPageBreak(.T.)
TRCell():New(oServ,"DTQ_SERTMS","DTQ",STR0015,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oServ,"DTQ_DESSVT","DTQ",STR0016,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| TMSValField(cAliasQry+'->DTQ_SERTMS',.F.) } )

oViagem:= TRSection():New(oServ,STR0017,{"DTQ","DUD","SA1","DTR","DA4"},/*Array com as Ordens do relat�rio*/,/*Campos do SX3*/,/*Campos do SIX*/) // "Viagem"
oViagem:SetTotalInLine(.F.)
TRCell():New(oViagem,"DTQ_FILORI","DTQ",STR0018,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTQ_VIAGEM","DTQ",STR0017,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTQ_DATINI","DTQ",STR0019,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTQ_DATFIM","DTQ",STR0020,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTR_CODVEI","DTR",STR0028,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTR_CODRB1","DTR",STR0029,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTR_CODRB2","DTR",STR0030,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DA4_NREDUZ","DA4",STR0031,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oProd:= TRSection():New(oViagem,STR0032,{"SB1"},/*Array com as Ordens do relat�rio*/,/*Campos do SX3*/,/*Campos do SIX*/) // "Produto"
oProd:SetTotalInLine(.F.)
oProd:SetTotalText(STR0039) // "Total de Documentos"
TRCell():New(oProd,"DUD_FILDOC","DUD",STR0021,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",,"LEFT")
TRCell():New(oProd,"DUD_DOC"   ,"DUD",STR0022,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",,"LEFT")
TRCell():New(oProd,"DUD_SERIE" ,"DUD",STR0023,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",,"LEFT")
TRCell():New(oProd,"A1_NREDUZ" ,"SA1",STR0024,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",,"LEFT")
TRCell():New(oProd,"DESTIN"    ,"  " ,STR0025,/*Picture*/,TamSx3("A1_NREDUZ")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",,"LEFT")
TRCell():New(oProd,"A1_MUN"    ,"SA1",STR0026,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",,"LEFT")
TRCell():New(oProd,"MUNDES"    ,"  " ,STR0027,/*Picture*/,TamSx3("A1_NREDUZ")[1],/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",,"LEFT")
TRCell():New(oProd,"B1_DESC"   ,"SB1",STR0032,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,"LEFT",,"LEFT")
TRCell():New(oProd,"DTC_DESEMB","DTC",STR0033,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| Tabela("MG",(cAliasQry2)->DTC_CODEMB,.F.) },"LEFT",,"LEFT")
TRCell():New(oProd,"DTC_QTDVOL","DTC",STR0034,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")
TRCell():New(oProd,"DTC_QTDUNI","DTC",STR0035,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")
TRCell():New(oProd,"DTC_PESO"  ,"DTC",STR0036,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")
TRCell():New(oProd,"DTC_PESOM3","DTC",STR0037,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")

oTotaliz := TRFunction():New(oProd:Cell("DUD_DOC"),/*cId*/,"COUNT",/*oBreak*/,STR0040/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
oTotaliz:SetCondition( { || TMR410Doc((cAliasQry2)->DUD_FILDOC,(cAliasQry2)->DUD_DOC,(cAliasQry2)->DUD_SERIE+"1") } )

oTotaliz := TRFunction():New(oProd:Cell("DUD_DOC"),/*cId*/,"COUNT",/*oBreak*/,STR0040/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,oServ)
oTotaliz:SetCondition( { || TMR410Doc((cAliasQry2)->DUD_FILDOC,(cAliasQry2)->DUD_DOC,(cAliasQry2)->DUD_SERIE+"2") } )

oTotaliz := TRFunction():New(oViagem:Cell("DTQ_VIAGEM"),/*cId*/,"COUNT",/*oBreak*/,STR0041/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,oServ)
oTotaliz:SetCondition( { || TMR410Vge((cAliasQry)->DTQ_FILORI,(cAliasQry)->DTQ_VIAGEM) } )

Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo de Souza       � Data � 23/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,cAliasQry,cAliasQry2)

Local cFilDoc := ''
Local cDocto  := ''
Local cSerie  := ''
Local cCodVei := ''
Local cSerTms := ''
Private cFilOri := ''
Private cViagem := ''

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQry
	SELECT DTQ_FILIAL, DTQ_SERTMS, DTQ_FILORI, DTQ_VIAGEM,  DTQ_DATINI, 
			 DTQ_DATFIM, DTR_CODVEI, DTR_CODRB1, DTR_CODRB2, DA4_NREDUZ
		FROM %table:DTQ% DTQ    
		JOIN %table:DTR% DTR      
			ON  DTR_FILIAL = %xFilial:DTR%
			AND DTR_FILORI = DTQ_FILORI      
			AND DTR_VIAGEM = DTQ_VIAGEM      
			AND DTR_CODVEI BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%
			AND DTR.%NotDel%
		JOIN %table:DUP% DUP      
			ON  DUP_FILIAL = %xFilial:DUP%
			AND DUP_FILORI = DTQ_FILORI      
			AND DUP_VIAGEM = DTQ_VIAGEM      
			AND DUP_CODVEI = DTR_CODVEI      
			AND DUP.%NotDel%
		JOIN %table:DA4% DA4      
			ON  DA4_FILIAL = %xFilial:DA4%
			AND DA4_COD    = DUP_CODMOT      
			AND DA4.%NotDel%
		WHERE DTQ_FILIAL = %xFilial:DTQ%
			AND DTQ_SERTMS BETWEEN %Exp:mv_par09% AND %Exp:mv_par10%
			AND DTQ_SERTMS = %Exp:StrZero(1,Len(DTQ->DTQ_SERTMS))%
			AND DTQ_STATUS BETWEEN %Exp:StrZero(1,Len(DTQ->DTQ_STATUS))% AND %Exp:StrZero(5,Len(DTQ->DTQ_STATUS))%
			AND DTQ_DATINI BETWEEN %Exp:DTOS(mv_par01)% AND %Exp:DTOS(mv_par02)%
			AND DTQ.%NotDel%
	UNION ALL
	SELECT DTQ_FILIAL, DTQ_SERTMS, DTQ_FILORI, DTQ_VIAGEM,  DTQ_DATINI, 
	       DTQ_DATFIM, DTR_CODVEI, DTR_CODRB1, DTR_CODRB2, DA4_NREDUZ
		FROM %table:DTQ% DTQ    
		JOIN %table:DTR% DTR      
			ON  DTR_FILIAL = %xFilial:DTR%
			AND DTR_FILORI = DTQ_FILORI      
			AND DTR_VIAGEM = DTQ_VIAGEM      
			AND DTR_CODVEI BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%
			AND DTR.%NotDel%
		JOIN %table:DUP% DUP      
			ON  DUP_FILIAL = %xFilial:DUP%
			AND DUP_FILORI = DTQ_FILORI      
			AND DUP_VIAGEM = DTQ_VIAGEM      
			AND DUP_CODVEI = DTR_CODVEI      
			AND DUP.%NotDel%
		JOIN %table:DA4% DA4      
			ON  DA4_FILIAL = %xFilial:DA4%
			AND DA4_COD    = DUP_CODMOT      
			AND DA4.%NotDel%
		WHERE DTQ_FILIAL = %xFilial:DTQ%
			AND DTQ_SERTMS BETWEEN %Exp:mv_par09% AND %Exp:mv_par10%
			AND DTQ_SERTMS <> %Exp:StrZero(1,Len(DTQ->DTQ_SERTMS))%
			AND DTQ_STATUS BETWEEN %Exp:StrZero(1,Len(DTQ->DTQ_STATUS))% AND %Exp:StrZero(5,Len(DTQ->DTQ_STATUS))%
			AND DTQ_DATINI BETWEEN %Exp:DTOS(mv_par01)% AND %Exp:DTOS(mv_par02)%
			AND DTQ.%NotDel%
	ORDER BY DTQ_FILIAL, DTQ_SERTMS, DTQ_FILORI, DTQ_VIAGEM
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


Begin REPORT QUERY oReport:Section(1):Section(1):Section(1)
BeginSql Alias cAliasQry2
	SELECT DUD_FILDOC, DUD_DOC, DUD_SERIE, MAX(SA1A.A1_NREDUZ) A1_NREDUZ, 
			 MAX(SA1A.A1_MUN) A1_MUN, MAX(SA1B.A1_NREDUZ) DESTIN, MAX(SA1B.A1_MUN) MUNDES,
			 MAX(B1_DESC) B1_DESC, MAX(DUM_QTDVOL) DTC_QTDVOL, MAX(0) DTC_QTDUNI, MAX(DUM_PESO) DTC_PESO, 
	       MAX(DUM_PESOM3) DTC_PESOM3, B1_COD, MAX(DUM_CODEMB) DTC_CODEMB
		FROM %table:DUD% DUD      
		JOIN %table:DT5% DT5      
			ON  DT5_FILIAL = %xFilial:DT5%
			AND DT5_FILDOC = DUD_FILDOC      
			AND DT5_DOC    = DUD_DOC      
			AND DT5_SERIE  = DUD_SERIE      
			AND DT5.%NotDel%
		JOIN %table:DUE% DUE      
			ON  DUE_FILIAL = %xFilial:DUE%
			AND DUE_DDD    = DT5_DDD      
			AND DUE_TEL    = DT5_TEL      
			AND DUE.%NotDel%
		JOIN %table:SA1% SA1A
			ON  SA1A.A1_FILIAL = %xFilial:SA1%
			AND SA1A.A1_COD     = DUE_CODCLI      
			AND SA1A.A1_LOJA    = DUE_LOJCLI      
			AND SA1A.A1_COD  BETWEEN %Exp:mv_par03% AND %Exp:mv_par05%
			AND SA1A.A1_LOJA BETWEEN %Exp:mv_par04% AND %Exp:mv_par06%
			AND SA1A.%NotDel%
		LEFT JOIN %table:SA1% SA1B
			ON  SA1B.A1_FILIAL = %xFilial:SA1%
			AND SA1B.A1_COD     = DT5_CLIDES      
			AND SA1B.A1_LOJA    = DT5_LOJDES
			AND SA1B.%NotDel%
		LEFT JOIN %table:DUM% DUM      
			ON  DUM_FILIAL = %xFilial:DUM%
			AND DUM_FILORI = DT5_FILORI      
			AND DUM_NUMSOL = DT5_NUMSOL      
			AND DUM.%NotDel%
		LEFT JOIN %table:SB1% SB1      
			ON  B1_FILIAL = %xFilial:SB1%
			AND B1_COD     = DUM_CODPRO      
			AND SB1.%NotDel%
		WHERE DUD_FILIAL = %xFilial:DUD%
			AND DUD_FILORI = %report_param:cFilOri%
			AND DUD_VIAGEM = %report_param:cViagem%
			AND DUD.%NotDel%
	GROUP BY DUD_FILDOC, DUD_DOC, DUD_SERIE, B1_COD
	UNION ALL
	SELECT DUD_FILDOC, DUD_DOC,  DUD_SERIE, MAX(SA1A.A1_NREDUZ) A1_NREDUZ, 
			 MAX(SA1A.A1_MUN) A1_MUN, MAX(SA1B.A1_NREDUZ) DESTIN, MAX(SA1B.A1_MUN) MUNDES,
			 MAX(B1_DESC) B1_DESC, MAX(DTC_QTDVOL) DTC_QTDVOL, MAX(DTC_QTDUNI) DTC_QTDUNI, MAX(DTC_PESO)   DTC_PESO,
	       MAX(DTC_PESOM3) DTC_PESOM3, B1_COD, MAX(DTC_CODEMB) DTC_CODEMB
		FROM %table:DUD% DUD      
		JOIN %table:DT6% DT6 
			ON DT6_FILIAL = %xFilial:DT6%
			AND DT6_FILDOC = DUD_FILDOC 
			AND DT6_DOC    = DUD_DOC 
			AND DT6_SERIE  = DUD_SERIE 
			AND DT6_CLIREM BETWEEN %Exp:mv_par03% AND %Exp:mv_par05%
			AND DT6_LOJREM BETWEEN %Exp:mv_par04% AND %Exp:mv_par06%
			AND DT6.%NotDel%
		LEFT JOIN %table:SA1% SA1A
			ON  SA1A.A1_FILIAL = %xFilial:SA1%
			AND SA1A.A1_COD     = DT6_CLIREM
			AND SA1A.A1_LOJA    = DT6_LOJREM
			AND SA1A.%NotDel%
		LEFT JOIN %table:SA1% SA1B
			ON  SA1B.A1_FILIAL = %xFilial:SA1%
			AND SA1B.A1_COD     = DT6_CLIDES
			AND SA1B.A1_LOJA    = DT6_LOJDES
			AND SA1B.%NotDel%
		JOIN %table:DTC% DTC 
		  ON DTC_FILIAL = %xFilial:DTC%
			AND DTC_FILDOC = DUD_FILDOC
			AND DTC_DOC    = DUD_DOC
			AND DTC_SERIE  = DUD_SERIE
			AND DTC.%NotDel%
		JOIN %table:SB1% SB1 
			ON B1_FILIAL = %xFilial:SB1%
			AND B1_COD = DTC.DTC_CODPRO 
			AND SB1.%NotDel%
		WHERE DUD_FILIAL = %xFilial:DUD%
			AND DUD_FILORI = %report_param:cFilOri%
			AND DUD_VIAGEM = %report_param:cViagem%
			AND DUD.%NotDel%
	GROUP BY DUD_FILDOC, DUD_DOC, DUD_SERIE, B1_COD
	UNION
	SELECT DUD_FILDOC, DUD_DOC,  DUD_SERIE, MAX(SA1A.A1_NREDUZ) A1_NREDUZ, 
			 MAX(SA1A.A1_MUN) A1_MUN, MAX(SA1B.A1_NREDUZ) DESTIN, MAX(SA1B.A1_MUN) MUNDES,
			 MAX(B1_DESC) B1_DESC, MAX(DTC_QTDVOL) DTC_QTDVOL, MAX(DTC_QTDUNI) DTC_QTDUNI, MAX(DTC_PESO)   DTC_PESO,
	       MAX(DTC_PESOM3) DTC_PESOM3, B1_COD, MAX(DTC_CODEMB) DTC_CODEMB
		FROM %table:DUD% DUD      
		JOIN %table:DT6% DT6 
			ON DT6_FILIAL = %xFilial:DT6%
			AND DT6_FILDOC = DUD_FILDOC 
			AND DT6_DOC    = DUD_DOC 
			AND DT6_SERIE  = DUD_SERIE 
			AND DT6_CLIREM BETWEEN %Exp:mv_par03% AND %Exp:mv_par05%
			AND DT6_LOJREM BETWEEN %Exp:mv_par04% AND %Exp:mv_par06%
			AND DT6.%NotDel%
		LEFT JOIN %table:SA1% SA1A
			ON  SA1A.A1_FILIAL = %xFilial:SA1%
			AND SA1A.A1_COD     = DT6_CLIREM
			AND SA1A.A1_LOJA    = DT6_LOJREM
			AND SA1A.%NotDel%
		LEFT JOIN %table:SA1% SA1B
			ON  SA1B.A1_FILIAL = %xFilial:SA1%
			AND SA1B.A1_COD     = DT6_CLIDES
			AND SA1B.A1_LOJA    = DT6_LOJDES
			AND SA1B.%NotDel%
		JOIN %table:DY4% DY4 
		  ON DY4_FILIAL = %xFilial:DY4%
			AND DY4_FILDOC = DUD_FILDOC
			AND DY4_DOC    = DUD_DOC
			AND DY4_SERIE  = DUD_SERIE
			AND DY4.%NotDel%
		JOIN %table:DTC% DTC
		  ON DTC_FILIAL = %xFilial:DTC%
			AND DTC_NUMNFC = DY4_NUMNFC
			AND DTC_SERNFC = DY4_SERNFC
			AND DTC_LOTNFC = DY4_LOTNFC
			AND DTC_CLIREM = DY4_CLIREM
			AND DTC_LOJREM = DY4_LOJREM
			AND DTC.%NotDel% 	
		JOIN %table:SB1% SB1 
			ON B1_FILIAL = %xFilial:SB1%
			AND B1_COD = DY4.DY4_CODPRO 
			AND SB1.%NotDel%
		WHERE DUD_FILIAL = %xFilial:DUD%
			AND DUD_FILORI = %report_param:cFilOri%
			AND DUD_VIAGEM = %report_param:cViagem%
			AND DUD.%NotDel%
	GROUP BY DUD_FILDOC, DUD_DOC, DUD_SERIE, B1_COD
EndSql 
End REPORT QUERY oReport:Section(1):Section(1):Section(1)

oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter( { |cParam| (cAliasQry)->DTQ_SERTMS == cParam }, { || (cAliasQry)->DTQ_SERTMS } )
oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):Section(1):SetParentFilter( { |cParam| (cAliasQry)->DTQ_FILORI + (cAliasQry)->DTQ_VIAGEM == cParam }, { || (cAliasQry)->DTQ_FILORI + (cAliasQry)->DTQ_VIAGEM } )

//-- Inicio da impressao do fluxo do relat�rio
oReport:SetMeter(DTQ->(LastRec()))

DbSelectArea(cAliasQry)
While !oReport:Cancel() .And. !(cAliasQry)->(Eof())
	//-- Impressao da secao Servico
	cSerTms := (cAliasQry)->DTQ_SERTMS

	//-- Valida filtro de clientes
	If !TMR410Cli((cAliasQry)->DTQ_FILORI,(cAliasQry)->DTQ_VIAGEM,(cAliasQry)->DTQ_SERTMS)
		(cAliasQry)->(DbSkip())
		Loop	
	EndIf

	oReport:Section(1):Init()
	oReport:Section(1):PrintLine()
	While !oReport:Cancel() .And. !(cAliasQry)->(Eof()) .And. (cAliasQry)->DTQ_SERTMS == cSerTms
		cFilOri := (cAliasQry)->DTQ_FILORI
		cViagem := (cAliasQry)->DTQ_VIAGEM
		oReport:Section(1):Section(1):Init()
		While !oReport:Cancel() .And. !(cAliasQry)->(Eof()) .And. (cAliasQry)->DTQ_SERTMS == cSerTms .And. ;
																						(cAliasQry)->DTQ_FILORI == cFilOri .And. ;
																						(cAliasQry)->DTQ_VIAGEM == cViagem
			//-- Valida filtro de clientes
			If !TMR410Cli((cAliasQry)->DTQ_FILORI,(cAliasQry)->DTQ_VIAGEM,(cAliasQry)->DTQ_SERTMS)
				(cAliasQry)->(DbSkip())
				Loop	
			EndIf

			cCodVei := (cAliasQry)->DTR_CODVEI
			oReport:Section(1):Section(1):PrintLine()
			(cAliasQry)->(DbSkip())
			While !oReport:Cancel() .And. !(cAliasQry)->(Eof()) .And. (cAliasQry)->DTQ_SERTMS == cSerTms .And. ;
																							(cAliasQry)->DTQ_FILORI == cFilOri .And. ;
																							(cAliasQry)->DTQ_VIAGEM == cViagem
				oReport:Section(1):Section(1):Cell("DTQ_FILORI"):Hide()
				oReport:Section(1):Section(1):Cell("DTQ_VIAGEM"):Hide()
				oReport:Section(1):Section(1):Cell("DTQ_DATINI"):Hide()
				oReport:Section(1):Section(1):Cell("DTQ_DATFIM"):Hide()
				If cCodVei == (cAliasQry)->DTR_CODVEI
					oReport:Section(1):Section(1):Cell("DTR_CODVEI"):Hide()
					oReport:Section(1):Section(1):Cell("DTR_CODRB1"):Hide()
					oReport:Section(1):Section(1):Cell("DTR_CODRB2"):Hide()
				Else
					oReport:Section(1):Section(1):Cell("DTR_CODVEI"):Show()
					oReport:Section(1):Section(1):Cell("DTR_CODRB1"):Show()
					oReport:Section(1):Section(1):Cell("DTR_CODRB2"):Show()
				EndIf
				cCodVei := (cAliasQry)->DTR_CODVEI
				oReport:Section(1):Section(1):PrintLine()
				(cAliasQry)->(DbSkip())
			EndDo
			oReport:Section(1):Section(1):Cell("DTQ_FILORI"):Show()
			oReport:Section(1):Section(1):Cell("DTQ_VIAGEM"):Show()
			oReport:Section(1):Section(1):Cell("DTQ_DATINI"):Show()
			oReport:Section(1):Section(1):Cell("DTQ_DATFIM"):Show()
			oReport:Section(1):Section(1):Cell("DTR_CODVEI"):Show()
			oReport:Section(1):Section(1):Cell("DTR_CODRB1"):Show()
			oReport:Section(1):Section(1):Cell("DTR_CODRB2"):Show()
		EndDo
		oReport:Section(1):Section(1):Finish()
		
		//-- Impressao dos documentos
		oReport:Section(1):Section(1):Section(1):ExecSql()
		If (cAliasQry2)->(!Eof())
			oReport:Section(1):Section(1):Section(1):Init()
			While (cAliasQry2)->(!Eof())
				cFilDoc := (cAliasQry2)->DUD_FILDOC
				cDocto  := (cAliasQry2)->DUD_DOC
				cSerie  := (cAliasQry2)->DUD_SERIE
				oReport:Section(1):Section(1):Section(1):PrintLine()				
				(cAliasQry2)->(DbSkip())
				While (cAliasQry2)->(!Eof()) .And.	(cAliasQry2)->DUD_FILDOC == cFilDoc .And. ;
																(cAliasQry2)->DUD_DOC    == cDocto .And. ;
																(cAliasQry2)->DUD_SERIE  == cSerie
					oReport:Section(1):Section(1):Section(1):Cell("DUD_FILDOC"):Hide()
					oReport:Section(1):Section(1):Section(1):Cell("DUD_DOC"   ):Hide()
					oReport:Section(1):Section(1):Section(1):Cell("DUD_SERIE" ):Hide()
					oReport:Section(1):Section(1):Section(1):Cell("A1_NREDUZ" ):Hide()
					oReport:Section(1):Section(1):Section(1):Cell("DESTIN"    ):Hide()
					oReport:Section(1):Section(1):Section(1):Cell("A1_MUN"    ):Hide()
					oReport:Section(1):Section(1):Section(1):Cell("MUNDES"    ):Hide()
					oReport:Section(1):Section(1):Section(1):PrintLine()				
					(cAliasQry2)->(DbSkip())
				EndDo
				oReport:Section(1):Section(1):Section(1):Cell("DUD_FILDOC"):Show()
				oReport:Section(1):Section(1):Section(1):Cell("DUD_DOC"   ):Show()
				oReport:Section(1):Section(1):Section(1):Cell("DUD_SERIE" ):Show()
				oReport:Section(1):Section(1):Section(1):Cell("A1_NREDUZ" ):Show()
				oReport:Section(1):Section(1):Section(1):Cell("DESTIN"    ):Show()
				oReport:Section(1):Section(1):Section(1):Cell("A1_MUN"    ):Show()
				oReport:Section(1):Section(1):Section(1):Cell("MUNDES"    ):Show()
			EndDo
			oReport:Section(1):Section(1):Section(1):Finish()
		EndIf
		//- Zera variaveis controladoras do totalizador
		TMR410Doc(,,,.T.)
		TMR410Vge(,,.T.)
	EndDo	
	oReport:Section(1):Finish()
EndDo

//- Zera variaveis controladoras do totalizador
TMR410Doc(,,,.T.)
TMR410Vge(,,.T.)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMR410Cli � Autor �Eduardo de Souza       � Data � 23/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida clientes                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Filial Origem                                        ���
���          �ExpC2: Viagem                                               ���
���          �ExpC3: Servico de Transporte                                ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMR410Cli(cFilOri,cViagem,cSerTms)

Local lRet       := .F.
Local cAliasQry3 := GetNextAlias()
Local aArea      := GetArea()

If cSerTms == StrZero(1,Len(DTQ->DTQ_SERTMS)) // Coleta
	BeginSql Alias cAliasQry3
		SELECT COUNT(A1_FILIAL) CNT
			FROM %table:DUD% DUD
			JOIN %table:DT5% DT5
				ON  DT5_FILIAL = %xFilial:DT5%
				AND DT5_FILDOC = DUD_FILDOC      
				AND DT5_DOC    = DUD_DOC      
				AND DT5_SERIE  = DUD_SERIE      
				AND DT5.%NotDel%
			JOIN %table:DUE% DUE
				ON  DUE_FILIAL = %xFilial:DUE%
				AND DUE_DDD    = DT5_DDD
				AND DUE_TEL    = DT5_TEL
				AND DUE.%NotDel%
			JOIN %table:SA1% SA1A
				ON  SA1A.A1_FILIAL = %xFilial:SA1%
				AND SA1A.A1_COD     = DUE_CODCLI
				AND SA1A.A1_LOJA    = DUE_LOJCLI
				AND SA1A.A1_COD  BETWEEN %Exp:mv_par03% AND %Exp:mv_par05%
				AND SA1A.A1_LOJA BETWEEN %Exp:mv_par04% AND %Exp:mv_par06%
				AND SA1A.%NotDel%
			WHERE DUD_FILIAL = %xFilial:DUD%
				AND DUD_FILORI = %Exp:cFilOri%
				AND DUD_VIAGEM = %Exp:cViagem%
				AND DUD.%NotDel%
	EndSql 
Else
	BeginSql Alias cAliasQry3
		SELECT COUNT(DT6_FILIAL) CNT
			FROM %table:DUD% DUD
			JOIN %table:DT6% DT6
				ON DT6_FILIAL = %xFilial:DT6%
				AND DT6_FILDOC = DUD_FILDOC
				AND DT6_DOC    = DUD_DOC
				AND DT6_SERIE  = DUD_SERIE
				AND DT6_CLIREM BETWEEN %Exp:mv_par03% AND %Exp:mv_par05%
				AND DT6_LOJREM BETWEEN %Exp:mv_par04% AND %Exp:mv_par06%
				AND DT6.%NotDel%
			WHERE DUD_FILIAL = %xFilial:DUD%
				AND DUD_FILORI = %Exp:cFilOri%
				AND DUD_VIAGEM = %Exp:cViagem%
				AND DUD.%NotDel%
	EndSql
EndIf

If (cAliasQry3)->CNT > 0
	lRet := .T.
EndIf
(cAliasQry3)->(DbCloseArea())

RestArea( aArea )

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMR410Doc � Autor �Eduardo de Souza       � Data � 23/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Controla totalizador                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Filial Documento                                     ���
���          �ExpC2: Documento                                            ���
���          �ExpC3: Serie                                                ���
���          �ExpL1: Zera                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMR410Doc(cFilDoc,cDocto,cSerie,lZera)

Static aDocto := {}
Local lRet    := .F.
Default lZera := .F.

If lZera
	aDocto := {}
Else
	If Ascan( aDocto, { |x| x[1]+x[2]+x[3] == cFilDoc + cDocto + cSerie } ) == 0
		Aadd( aDocto, { cFilDoc, cDocto, cSerie } )
		lRet := .T.
	EndIf
EndIf

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMR410Vge � Autor �Eduardo de Souza       � Data � 23/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Controla totalizador                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Filial Viagem                                        ���
���          �ExpC2: Viagem                                               ���
���          �ExpL1: Zera                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMR410Vge(cFilOri,cViagem,lZera)
                                                                   
Static cVge := ''
Local lRet  := .T.
Default lZera := .F.

If lZera
	cVge := ''
Else
	If cVge == cFilOri + cViagem
		lRet := .F.
	EndIf
	cVge := cFilOri + cViagem
EndIf

Return lRet