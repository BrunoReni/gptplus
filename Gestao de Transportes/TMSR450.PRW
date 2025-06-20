#INCLUDE "TMSR450.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR450  � Autor � Eduardo de Souza      � Data � 26/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rentabilidade x km rodado                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR450()

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
���Programa  �ReportDef � Autor � Eduardo de Souza      � Data � 26/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR450                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local oViagem
Local oVeiculo
Local nDias     := 0
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
oReport:= TReport():New("TMSR450",STR0018,"TMR450", {|oReport| ReportPrint(oReport,cAliasQry)},STR0019) // "Rentabilidade x km rodado" ### "Emite a relacao de Rentabilidade x km rodado conforme os parametros informados"
oReport:SetTotalInLine(.F.)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01	 // Periodo De                                    �
//� mv_par02	 // Periodo Ate                                   �
//� mv_par03	 // Frota                                         �
//� mv_par04	 // Veiculo De                                    �
//� mv_par05	 // Veiculo Ate                                   �
//� mv_par06	 // Tipo Relatorio                                �
//����������������������������������������������������������������
Pergunte(oReport:uParam,.F.)

nDias := TmsDiasVal(mv_par01,mv_par02,"1",.T.)
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
Aadd( aOrdem, STR0020 ) // "V�iculo + Fil. Origem + Viagem"

oVeiculo:= TRSection():New(oReport,STR0021,{"DTR","DA3","SA2"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oVeiculo:SetTotalInLine(.F.)
oVeiculo:SetTotalText(STR0025) //-- "Total Ve�culo"
oVeiculo:SetPageBreak(.T.)
TRCell():New(oVeiculo,"DTR_CODVEI","DTR",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DA3_PLACA" ,"DA3",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DA3_DESC"  ,"DA3",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DA3_FROVEI","DA3",/*cTitle*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DTR_CODFOR","DTR",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DTR_LOJFOR","DTR",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"A2_NOME"   ,"SA2",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oViagem := TRSection():New(oVeiculo,STR0027,{"DTQ"},/*Ordem do relatorio*/,/*Campos do SX3*/,/*Campos do SIX*/)
oViagem:SetTotalInLine(.F.)
oViagem:SetLineCondition( { || Iif(mv_par07 == 2 .And. TMSR450VFre((cAliasQry)->DTQ_FILORI,(cAliasQry)->DTQ_VIAGEM,(cAliasQry)->DTQ_SERTMS,(cAliasQry)->DUV_ODOENT-(cAliasQry)->DUV_ODOSAI) == 0,.F.,.T.) } )

TRCell():New(oViagem,"DTQ_FILORI","DTQ",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTQ_VIAGEM","DTQ",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTQ_SERTMS","DTQ",/*cTitle*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/, {|| TMSValField((cAliasQry)+'->DTQ_SERTMS',.F.) } )
TRCell():New(oViagem,"DUV_ODOSAI","DUV",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DUV_DATSAI","DUV",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DUV_ODOENT","DUV",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DUV_DATENT","DUV",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"TOTALKM"   ,""   ,STR0022   ,PesqPict("DUV","DUV_ODOENT"),4 /*Tamanho*/,/*lPixel*/, {|| (cAliasQry)->DUV_ODOENT-(cAliasQry)->DUV_ODOSAI })
TRCell():New(oViagem,"VALFRETE"  ,""   ,STR0023   ,PesqPict("DT6","DT6_VALFRE"),TamSx3("DT6_VALFRE")[1],/*lPixel*/, {|| TMSR450VFre((cAliasQry)->DTQ_FILORI,(cAliasQry)->DTQ_VIAGEM,(cAliasQry)->DTQ_SERTMS,oViagem:Cell("TOTALKM"):UPRINT ) })
TRCell():New(oViagem,"RENTKM"    ,""   ,STR0024   ,"@E 99999.99" ,5 /*Tamanho*/,/*lPixel*/, {|| oViagem:Cell("VALFRETE"):UPRINT / oViagem:Cell("TOTALKM"):UPRINT })
TRCell():New(oViagem,"DTQ_ROTA"  ,"DTQ",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DA8_DESC"  ,"DA8",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRFunction():New(oViagem:Cell("TOTALKM"   ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oVeiculo)
TRFunction():New(oViagem:Cell("VALFRETE"  ),"FRETE","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oVeiculo)
TRFunction():New(oViagem:Cell("RENTKM"    ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oVeiculo)

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

Local cSerTms := StrZero(2,Len(DTQ->DTQ_SERTMS))
Local cWhere  := " "

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

cWhere := "%"
If mv_par03 == 1 .Or. mv_par03 == 2 .Or. mv_par03 == 3 //-- Propria / Terceiro / Agregado
	cWhere += "     AND DA3_FROVEI = '" + StrZero(mv_par03,Len(DA3->DA3_FROVEI)) + "' "
ElseIf mv_par03 == 4 //-- Agregado/Terceiro
	cWhere += "     AND DA3_FROVEI BETWEEN '" + StrZero(2,Len(DA3->DA3_FROVEI)) + "' AND '" + StrZero(3,Len(DA3->DA3_FROVEI)) + "' "
EndIf
cWhere += "%"

BeginSql Alias cAliasQry
	SELECT DTR_FILIAL, DTQ_FILORI, DTQ_VIAGEM, DTQ_SERTMS, DTR_CODVEI, DUV_ODOSAI, DUV_DATSAI, DUV_ODOENT, 
	       DUV_DATENT, DA3_PLACA, DA3_DESC, DA3_FROVEI, DTR_CODFOR, DTR_LOJFOR, A2_NOME, DTQ_ROTA, DA8_DESC
	   FROM %table:DTQ% DTQ
	   JOIN %table:DTR% DTR
	     ON  DTR_FILIAL = %xFilial:DTR%
	     AND DTR_FILORI = DTQ_FILORI 
	     AND DTR_VIAGEM = DTQ_VIAGEM 
	     AND DTR_CODVEI BETWEEN %Exp:mv_par04% AND %Exp:mv_par05%
	     AND DTR.%NotDel%
	   JOIN %table:DUV% DUV
	      ON  DUV_FILIAL = %xFilial:DUV%
	      AND DUV_FILORI = DTQ_FILORI 
	      AND DUV_VIAGEM = DTQ_VIAGEM 
	      AND DUV_CODVEI = DTR_CODVEI 
	      AND DUV_ODOSAI > 0 
	      AND DUV_ODOENT > 0 
	      AND DUV.%NotDel%
	   JOIN %table:DA3% DA3
	      ON  DA3_FILIAL = %xFilial:DA3%
	      AND DA3_COD    = DTR_CODVEI 
	      AND DA3.%NotDel%
			%Exp:cWhere%
	   JOIN %table:SA2% SA2
	      ON A2_FILIAL = %xFilial:SA2%
	      AND A2_COD  = DA3_CODFOR 
	      AND A2_LOJA = DA3_LOJFOR 
	      AND SA2.%NotDel%
	   JOIN %table:DA8% DA8 
	     ON DA8_FILIAL = %xFilial:DA8%
	     AND DA8_COD = DTQ_ROTA 
	     AND DA8.%NotDel%
	   WHERE DTQ_FILIAL = %xFilial:DTQ%
	      AND DTQ_STATUS = %Exp:StrZero(3,Len(DTQ->DTQ_STATUS))%
	      AND DTQ_DATENC BETWEEN %Exp:DToS(mv_par01)% AND %Exp:DToS(mv_par02)%
	      AND DTQ.%NotDel%
	ORDER BY DTR_FILIAL, DTR_CODVEI, DTQ_FILORI, DTQ_VIAGEM, DUV_DATENT
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
oReport:SetMeter(DTY->(LastRec()))

oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter( {|cParam| (cAliasQry)->DTR_CODVEI == cParam  }, {|| (cAliasQry)->DTR_CODVEI } )

oReport:Section(1):Print()

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSR450VFre� Autor �Eduardo de Souza      � Data � 06/11/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna valor dos documentos da viagem                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSR450VFre(ExpC1,ExpC2)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Filial da Viagem                                   ���
���          � ExpC2 - Viagem                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSR450                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function TMSR450VFre(cFilOri,cViagem,cSerTms,nTotKm)

Local cAliasTRB1 := ""
Local nValFre    := 0
Local cQuery     := ""

cAliasTRB1 := GetNextAlias()

If cSerTms == StrZero(1,Len(DTQ->DTQ_SERTMS)) //-- Coleta
	cQuery := " SELECT "
	cQuery += "   DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_VALTOT, DT5_FILORI, DT5_NUMSOL "
	cQuery += "   FROM " 
	cQuery += RetSqlName("DUD") + " DUD, "
	cQuery += RetSqlName("DT5") + " DT5, "
	cQuery += RetSqlName("DTC") + " DTC, "
	cQuery += RetSqlName("DT6") + " DT6 "
	cQuery += "   WHERE "
	If Empty(xFilial("DUD"))
		cQuery += " DUD.DUD_FILIAL = '" + xFilial("DUD") + "' AND "
	EndIf
	cQuery += "     DUD.DUD_FILORI = '" + cFilOri + "' "
	cQuery += "     AND DUD.DUD_VIAGEM = '" + cViagem + "' "
	cQuery += "     AND DUD.DUD_SERTMS = '" + cSerTms + "' "
	cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
	If Empty(xFilial("DT5"))
		cQuery += " AND DT5.DT5_FILIAL = '" + xFilial("DT5") + "' "
	EndIf
	cQuery += "     AND DT5.DT5_FILDOC = DUD.DUD_FILDOC "
	cQuery += "     AND DT5.DT5_DOC    = DUD.DUD_DOC "
	cQuery += "     AND DT5.DT5_SERIE  = DUD.DUD_SERIE "
	cQuery += "     AND DT5.D_E_L_E_T_ = ' ' "
	If Empty(xFilial("DTC"))
		cQuery += " AND DTC.DTC_FILIAL = '" + xFilial("DTC") + "' "
	EndIf
	cQuery += "     AND DTC.DTC_FILORI = DT5.DT5_FILORI "
	cQuery += "     AND DTC.DTC_NUMSOL = DT5.DT5_NUMSOL "
	cQuery += "     AND DTC.D_E_L_E_T_ = ' ' "
	If Empty(xFilial("DT6"))
		cQuery += " AND DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
	EndIf
	cQuery += "     AND DT6.DT6_FILDOC = DTC.DTC_FILDOC  "
	cQuery += "     AND DT6.DT6_DOC    = DTC.DTC_DOC "
	cQuery += "     AND DT6.DT6_SERIE  = DTC.DTC_SERIE "
	cQuery += "     AND DT6.D_E_L_E_T_ = ' ' "
Else
	cQuery := " SELECT "
	cQuery += "   DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_VALTOT "
	cQuery += "   FROM " 
	cQuery += RetSqlName("DUD") + " DUD, "
	cQuery += RetSqlName("DT6") + " DT6 "
	cQuery += "   WHERE "
	If Empty(xFilial("DUD"))
		cQuery += " DUD.DUD_FILIAL = '" + xFilial("DUD") + "' AND "
	EndIf
	cQuery += "     DUD.DUD_FILORI = '" + cFilOri + "' "
	cQuery += "     AND DUD.DUD_VIAGEM = '" + cViagem + "' "
	cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
	If Empty(xFilial("DT6"))
		cQuery += " AND DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
	EndIf
	cQuery += "     AND DT6.DT6_FILDOC = DUD.DUD_FILDOC "
	cQuery += "     AND DT6.DT6_DOC    = DUD.DUD_DOC "
	cQuery += "     AND DT6.DT6_SERIE  = DUD.DUD_SERIE "
	cQuery += "     AND DT6.D_E_L_E_T_ = ' ' "
EndIf

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTRB1, .F., .T.)
While (cAliasTRB1)->(!Eof())
	
	nValFre += (cAliasTRB1)->DT6_VALTOT
	(cAliasTRB1)->(DbSkip())
EndDo

(cAliasTRB1)->(DbCloseArea())

Return nValFre

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsDiasVal� Autor �Eduardo de Souza       � Data � 11/11/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a quantidade de Dias entre as datas informadas,    ���
���          � desconsiderando dias da semana e/ou feriado de acordo com  ���
���          � os parametros informados.                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TmsDiasVal()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpD1 - Data Inicio                                        ���
���          � ExpD2 - Data Final                                         ���
���          � ExpC1 - Dias a Desconsidera (1;2;3;4;5;6;7)                ���
���          � ExpL1 - Valida Feriado (True/False)                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSR450                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function TmsDiasVal(dDataDe,dDataAte,cNoDias,lFeriado)

Local nDias      := 0
Local dDataAtu   := dDataDe
Local aFeriados  := RetFeriados()
Local nCnt

Default cNoDias  := ""
Default lFeriado := .F.

If dDataDe <= dDataAte
	For nCnt := 1 To ( dDataAte - dDataDe )
		//-- Verifica se a data eh feriado.
		If !lFeriado .Or. ( lFeriado .And. Ascan(aFeriados,Dtos(dDataAtu)) == 0 )
			//-- Nao considera os dias da semana passados atraves do parametro.
			If !( AllTrim(Str(Dow(dDataAtu))) $ cNoDias )
				nDias ++
			EndIf
		EndIf
		dDataAtu += 1
	Next nCnt
EndIf

Return nDias
