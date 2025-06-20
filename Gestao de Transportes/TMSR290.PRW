#INCLUDE "TMSR290.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR290  � Autor � Eduardo de Souza      � Data � 29/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de Coletas por Rota   		                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR290()

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
���Programa  �ReportDef � Autor � Eduardo de Souza      � Data � 29/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR290                                                    ���
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
oReport:= TReport():New("TMSR290",STR0014,"TMR290A", {|oReport| ReportPrint(oReport,cAliasQry)},STR0015) // "Relacao de Coletas por Rota" ### "Emite Relacao de Coletas por Rota conforme os parametros informados"
oReport:SetTotalInLine(.F.)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� mv_par01 Data Solicitacao De      ?							 �
//� mv_par02 Data Solicitacao Ate     ?							 �
//� mv_par03 Rota De                  ?							 �
//� mv_par04 Rota Ate                 ?							 �
//� mv_par05 Solicitante De           ?							 �
//� mv_par06 Solicitante Ate          ?							 �
//� mv_par07 Filtra Status (COMBOBOX) 1 - Sim					 �
//�                                   2 - Nao					 �
//� mv_par08 Status (COMBOBOX)        1 - Em Aberto				 �
//�                                   2 - Em Transito			 �
//�                                   3 - Encerrada				 �
//�                                   4 - Chagada parcial		 �
//�                                   5 - Documento Informado	 �
//�                                   9 - Cancelada				 �
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
Aadd( aOrdem, STR0016 ) // "Status + Rota + Solic. Coleta"

oStatus:= TRSection():New(oReport,STR0017,{"DT5"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oStatus:SetTotalInLine(.F.)
oStatus:SetTotalText(STR0018) //-- "Total do Status"
TRCell():New(oStatus,"DT5_STATUS","DT5",/*cTitle*/,/*Picture*/,25/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oRota:= TRSection():New(oStatus,STR0019,{"DA8"},/*Ordem do Relatorio*/,/*Campos do SX3*/,/*Campos do SIX*/)
oRota:SetTotalInLine(.F.)
TRCell():New(oRota,"DA8_COD" ,"DA8",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRota,"DA8_DESC","DA8",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oSolic:= TRSection():New(oRota,STR0020,{"DT5","DUE","DT6"},/*Ordem do Relatorio*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSolic:SetTotalInLine(.F.)
TRCell():New(oSolic,"DT5_FILORI","DT5",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DT5_NUMSOL","DT5",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DT5_FILDOC","DT5",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DT5_DOC"   ,"DT5",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DT5_SERIE" ,"DT5",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DUE_NOME"  ,"DUE",STR0021   ,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DT6_QTDVOL","DT6",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DT6_PESO"  ,"DT6",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DT5_DATSOL","DT5",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSolic,"DT5_HORSOL","DT5",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRFunction():New(oSolic:Cell("DT5_NUMSOL"),/*cId*/,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oStatus)
TRFunction():New(oSolic:Cell("DT6_QTDVOL"),/*cId*/,"SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oStatus)
TRFunction():New(oSolic:Cell("DT6_PESO"  ),/*cId*/,"SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oStatus)

Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo de Souza       � Data � 25/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR430                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,cAliasQry)

Local cWhere := ''

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

// Verifica se filtra ou nao pelo Status
cWhere := "%"
If mv_par07 == 1
	cWhere += " AND DT5_STATUS = '" + mv_par08 + "' "
EndIf
cWhere += "%"

BeginSql Alias cAliasQry
	SELECT DT5_FILIAL, DT5_FILORI, DT5_NUMSOL, DT5_FILDOC, DT5_DOC, DT5_SERIE, MAX(DUE_NOME) DUE_NOME, 
	       MAX(DT5_STATUS) DT5_STATUS, MAX(DT5_DATSOL) DT5_DATSOL, MAX(DT5_HORSOL) DT5_HORSOL,
	       MAX(DA8_COD   ) DA8_COD   , MAX(DA8_DESC  ) DA8_DESC  , MAX(DT6_QTDVOL) DT6_QTDVOL, 
	       MAX(DT6_PESO  ) DT6_PESO
	   FROM %table:DT5% DT5 
	   JOIN %table:DT6% DT6 
	      ON DT6_FILIAL  = %xFilial:DT6%
	      AND DT6_FILDOC = DT5_FILDOC
	      AND DT6_DOC    = DT5_DOC 
	      AND DT6_SERIE  = DT5_SERIE 
	      AND DT6.%NotDel%
	   JOIN %table:DUD% DUD
	      ON DUD_FILIAL = %xFilial:DUD%
	      AND DUD_FILDOC = DT6_FILDOC
	      AND DUD_DOC    = DT6_DOC
	      AND DUD_SERIE  = DT6_SERIE
	      AND DUD_VIAGEM <> ' '
	      AND DUD.%NotDel%
	   JOIN %table:DUE% DUE 
	      ON DUE_FILIAL = %xFilial:DUE%
	      AND DUE_CODSOL = DT5_CODSOL 
	      AND DUE.%NotDel%
	   LEFT JOIN %table:DTQ% DTQ 
	      ON DTQ_FILIAL = %xFilial:DTQ%
	      AND DTQ_FILORI = DUD_FILORI
	      AND DTQ_VIAGEM = DUD_VIAGEM
			AND DTQ_ROTA BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
	      AND DTQ.%NotDel%
	   LEFT JOIN %table:DA8% DA8
	     ON DA8_FILIAL = %xFilial:DA8%
	     AND ( DA8_COD = DT5_ROTPRE 
	      OR DA8_COD = DTQ_ROTA )
	     AND DA8.%NotDel%
	    WHERE DT5_FILIAL = %xFilial:DT5%
	      AND DT5_FILORI = %Exp:cFilAnt%
	      AND DT5_DATSOL BETWEEN %Exp:Dtos(mv_par01)% AND %Exp:Dtos(mv_par02)%
	      AND DT5_CODSOL    BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
	      AND DT5.%NotDel%
	      %Exp:cWhere%
	   GROUP BY DT5_FILIAL, DT5_FILORI, DT5_NUMSOL, DT5_FILDOC, DT5_DOC, DT5_SERIE
	UNION ALL 
	SELECT DT5_FILIAL, DT5_FILORI, DT5_NUMSOL, DT5_FILDOC, DT5_DOC, DT5_SERIE, DUE_NOME, DT5_STATUS, DT5_DATSOL, DT5_HORSOL, DA8_COD, 
	       DA8_DESC   , DT6_QTDVOL, DT6_PESO
	   FROM %table:DT5% DT5 
	   JOIN %table:DT6% DT6 
	       ON DT6_FILIAL = %xFilial:DT6%
	       AND DT6_FILDOC = DT5_FILDOC
	       AND DT6_DOC    = DT5_DOC 
	       AND DT6_SERIE  = DT5_SERIE 
	       AND DT6_NUMVGA = ' ' 
	       AND DT6.%NotDel%
	   JOIN %table:DUD% DUD
	      ON DUD_FILIAL = %xFilial:DUD%
	      AND DUD_FILDOC = DT6_FILDOC
	      AND DUD_DOC    = DT6_DOC
	      AND DUD_SERIE  = DT6_SERIE
	      AND DUD_VIAGEM = ' '
	      AND DUD.%NotDel%
	   JOIN %table:DUE% DUE 
	       ON DUE_FILIAL = %xFilial:DUE%
	       AND DT5_CODSOL = DUE_CODSOL 
	       AND DUE.%NotDel%
	    LEFT JOIN %table:DA8% DA8 
	       ON DA8_FILIAL = %xFilial:DA8%
	       AND DA8_COD   = DT5_ROTPRE
	       AND DA8_COD BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
	       AND DA8.%NotDel%
	    WHERE DT5_FILIAL = %xFilial:DT5%
	       AND DT5_FILORI = %Exp:cFilAnt%
	       AND DT5_DATSOL BETWEEN %Exp:Dtos(mv_par01)% AND %Exp:Dtos(mv_par02)%
	       AND DT5_CODSOL BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
	       AND DT5.%NotDel%
			 %Exp:cWhere%
	ORDER BY DT5_FILIAL, DT5_STATUS, DA8_COD, DT5_FILORI, DT5_NUMSOL
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
oReport:SetMeter(DT5->(LastRec()))

oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter( {|cParam| (cAliasQry)->DT5_STATUS == cParam  }, {|| (cAliasQry)->DT5_STATUS } )
oReport:Section(1):Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):Section(1):SetParentFilter( {|cParam| (cAliasQry)->DT5_STATUS + (cAliasQry)->DA8_COD == cParam  }, {|| (cAliasQry)->DT5_STATUS + (cAliasQry)->DA8_COD } )

oReport:Section(1):Print()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsR290Sta� Autor � Alex Egydio           � Data �25.08.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Apresenta o status da solicitacao de coleta para selecao   ���
���          � via consulta F3( DLY )                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TmsR290Sta()

Local aStatus := {}
Local aSx3Box := RetSx3Box( Posicione('SX3', 2, 'DT5_STATUS', 'X3CBox()' ),,, 1 )
Local cTitSta := Posicione('SX3',2,'DT5_STATUS','X3Titulo()')
Local nItem   := 0
Local nCntFor

//-- Preenche o vetor astatus com o codigo e descricao do status
For nCntFor := 1 To Len(aSx3Box)
	If	!Empty(aSx3Box[nCntFor,2])
		AAdd(aStatus,{aSx3Box[nCntFor,2],aSx3Box[nCntFor,3]})
	EndIf
Next
//-- VAR_IXB eh utilizada como retorno da consulta F3( DLY )
VAR_IXB := ''
If	!Empty(aStatus)
	nItem   := TmsF3Array( {'',cTitSta}, aStatus, cTitSta )
	If	nItem > 0
		VAR_IXB := aStatus[nItem,1]
	EndIf
EndIf

Return(.T.)
