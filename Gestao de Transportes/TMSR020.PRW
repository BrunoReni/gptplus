#INCLUDE "TMSR020.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR020  � Autor � Eduardo de Souza      � Data � 30/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tracking                                                   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR020()

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
���Programa  �ReportDef � Autor � Eduardo de Souza      � Data � 30/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local cAliasQry := GetNextAlias()
Local aOrdem    := {}

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
oReport:= TReport():New("TMSR020",STR0010,"TMR020", {|oReport| ReportPrint(oReport,cAliasQry)},STR0011) // "Tracking" ### "Emite Relacao de Tracking conforme os parametros informados."
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)
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
Aadd( aOrdem, STR0014 ) // "Sequ�ncia"

oViagem:= TRSection():New(oReport,STR0012,{"DTW","DTQ","DA8","DUY"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oViagem:SetTotalInLine(.F.)
TRCell():New(oViagem,"DTW_FILORI","DTW",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTW_VIAGEM","DTW",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTQ_TIPTRA","DTQ",/*cTitle*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/, {|| TMSValField(cAliasQry+'->DTQ_TIPTRA',.F.) })
TRCell():New(oViagem,"DTQ_SERTMS","DTQ",/*cTitle*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/, {|| TMSValField(cAliasQry+'->DTQ_SERTMS',.F.) })
TRCell():New(oViagem,"DTQ_ROTA"  ,"DTQ",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DA8_DESC"  ,"DA8",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DUY_GRPVEN","DUY",STR0015   ,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DUY_DESCRI","DUY",STR0017   ,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DUN_CDRDES","DUN",STR0016   ,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DES_CDRDES",""   ,STR0017   ,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oServic:= TRSection():New(oViagem,STR0013,{"DTW","DC6"},/*Ordem do relatorio*/,/*Campos do SX3*/,/*Campos do SIX*/)
oServic:SetTotalInLine(.F.)
TRCell():New(oServic,"DTW_SERVIC","DTW",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oServic,"DTW_DESSER","DTW",/*cTitle*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/, {|| Tabela("L4",(cAliasQry)->DTW_SERVIC,.F.) } )
TRCell():New(oServic,"DTW_TAREFA","DTW",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oServic,"DTW_DESTAR","DTW",/*cTitle*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/, {|| Tabela("L2",(cAliasQry)->DTW_TAREFA,.F.) } )
TRCell():New(oServic,"DTW_ATIVID","DTW",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oServic,"DTW_DESATI","DTW",/*cTitle*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/, {|| Tabela("L3",(cAliasQry)->DTW_ATIVID,.F.) } )
TRCell():New(oServic,"DC6_OBS"   ,"DC6",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oServic,"DTW_DATPRE","DTW",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oServic,"DTW_HORPRE","DTW",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oServic,"DTW_DATREA","DTW",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oServic,"DTW_HORREA","DTW",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

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

If Type( 'cViagem' ) != 'C'
	cFilOri := mv_par01
	cViagem := mv_par02
EndIf

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQry
	SELECT DTW_FILIAL, DTW_FILORI, DTW_VIAGEM, DTW_SEQUEN, MAX(DTQ_TIPTRA) DTQ_TIPTRA, 
			 MAX(DTQ_SERTMS) DTQ_SERTMS, MAX(DTQ_ROTA) DTQ_ROTA, MAX(DA8_DESC) DA8_DESC, 
			 MAX(DUN_CDRDES) DUN_CDRDES, MAX(DUY_DESCRI) DES_CDRDES, MAX(DTW_SERVIC) DTW_SERVIC, 
			 MAX(DTW_TAREFA) DTW_TAREFA, MAX(DTW_ATIVID) DTW_ATIVID, MAX(DC6_OBS) DC6_OBS, 
			 MAX(DTW_DATPRE) DTW_DATPRE, MAX(DTW_HORPRE) DTW_HORPRE, MAX(DTW_DATPRE) DTW_DATREA,
			 MAX(DTW_HORPRE) DTW_HORREA
	   FROM %table:DTW% DTW
	   INNER JOIN %table:DTQ% DTQ
	     ON (DTQ_FILIAL = %xFilial:DTQ%
	    AND DTQ_FILORI = DTW_FILORI
	    AND DTQ_VIAGEM = DTW_VIAGEM
	    AND DTQ.%NotDel%)
	   INNER JOIN %table:DA8% DA8
	     ON (DA8_FILIAL = %xFilial:DA8%
	     AND DA8_COD = DTQ_ROTA
	     AND DA8.%NotDel%)
	   LEFT JOIN %table:DUN% DUN
	     ON (DUN_FILIAL = %xFilial:DUN%
	     AND DUN_ROTEIR = DTQ_ROTA
	     AND DUN.%NotDel%)
	   LEFT JOIN %table:DUY% DUY
	     ON (DUY_FILIAL = %xFilial:DUY%
	     AND DUY_GRPVEN = DUN_CDRDES
	     AND DUY.%NotDel%)
	   LEFT JOIN %table:DC6% DC6
	     ON (DC6_FILIAL = %xFilial:DC6%
	     AND DC6_TAREFA = DTW_TAREFA
	     AND DC6_ATIVID = DTW_ATIVID
	     AND DC6.%NotDel%)
	   WHERE DTW_FILIAL = %xFilial:DTW%
	      AND DTW_FILORI = %Exp:cFilOri%
	      AND DTW_VIAGEM = %Exp:cViagem%
	      AND DTW.%NotDel%
	GROUP BY DTW_FILIAL, DTW_FILORI, DTW_VIAGEM, DTW_SEQUEN
	ORDER BY DTW_FILIAL, DTW_FILORI, DTW_VIAGEM, DTW_SEQUEN
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
oReport:SetMeter(DTW->(LastRec()))

TRPosition():New(oReport:Section(1),"DUY",1,{|| xFilial("DUY")+SuperGetMv('MV_CDRORI')})

oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter( {|cParam| (cAliasQry)->DTW_FILORI + (cAliasQry)->DTW_VIAGEM == cParam },{|| (cAliasQry)->DTW_FILORI + (cAliasQry)->DTW_VIAGEM })

oReport:Section(1):Print()

Return