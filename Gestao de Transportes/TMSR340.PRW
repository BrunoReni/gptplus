#INCLUDE "TMSR340.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR340  � Autor � Eduardo de Souza      � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de Entregas sem Ocorrencia                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR340()

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
���Programa  �ReportDef � Autor � Eduardo de Souza      � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR310                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local aOrdem    := {}
Local cAliasQry := GetNextAlias()
Local lTercRbq  := DTR->(ColumnPos("DTR_CODRB3")) > 0

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
oReport:= TReport():New("TMSR340",STR0013,"TMR340", {|oReport| ReportPrint(oReport,cAliasQry)},STR0014) // "Relacao de Entregas sem Ocorr�ncia" ### "Emite Relacao de Entregas sem Ocorr�ncia conforme os parametros informados"
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//�����������������������������������Ŀ
//� mv_par01  Filial Origem De ?      �
//� mv_par02  Filial Origem Ate ?     |
//� mv_par03  Data de Entrada De ?    �
//� mv_par04  Data de Entrada Ate ?   |
//�������������������������������������
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
Aadd( aOrdem, STR0015 ) // "Fil.Origem + Viagem + Previs�o"

oFilAti := TRSection():New(oReport,STR0031,{"DTQ","DUD","DT6","DTW","DTR","DUP","DA3","DA4"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Fil. Atividade"
oFilAti:SetPageBreak(.T.)
oFilAti:SetTotalInLine(.F.)
TRCell():New(oFilAti,"DTQ_FILORI","DTQ",STR0018,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilAti,"DTQ_VIAGEM","DTQ",STR0019,/*Picture*/,TamSx3("DTQ_VIAGEM")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilAti,"DUD_FILDOC","DUD",STR0020,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilAti,"DUD_DOC"   ,"DUD",STR0021,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilAti,SerieNfId("DUD",3,"DUD_SERIE") ,"DUD",STR0022,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilAti,"DT6_PESO"  ,"DT6",STR0023,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilAti,"DT6_VALTOT","DT6",STR0024,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilAti,"DT6_QTDVOL","DT6",STR0025,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilAti,"DTW_DATPRE","DTW",STR0026,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilAti,"DTR_CODVEI","DTR",STR0027,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilAti,"DESVEI"    ,""   ,STR0016   ,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilAti,"DTR_CODRB1","DTR",STR0028,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilAti,"DESRB1"    ,""   ,STR0016   ,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilAti,"DTR_CODRB2","DTR",STR0029,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilAti,"DESRB2"    ,""   ,STR0016   ,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
If lTercRbq
	TRCell():New(oFilAti,"DTR_CODRB3","DTR",STR0033,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oFilAti,"DESRB3"    ,""   ,STR0016   ,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
EndIf
TRCell():New(oFilAti,"DUP_CODMOT","DUP",STR0030,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilAti,"DA4_NREDUZ","DA4",STR0017   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oBreak := TRBreak():New(oFilAti,oFilAti:Cell("DTW_DATPRE"),STR0032,.f.) // "Total Por Chegada"
oTotaliz:= TRFunction():New(oFilAti:Cell("DT6_PESO"  ),/*cId*/,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
oTotaliz:SetCondition( { || TMR340Doc( (cAliasQry)->DUD_FILDOC,(cAliasQry)->DUD_DOC,(cAliasQry)->DUD_SERIE + "1" ) } )

oTotaliz:= TRFunction():New(oFilAti:Cell("DT6_VALTOT"),/*cId*/,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
oTotaliz:SetCondition( { || TMR340Doc( (cAliasQry)->DUD_FILDOC,(cAliasQry)->DUD_DOC,(cAliasQry)->DUD_SERIE + "2" ) } )

oTotaliz:= TRFunction():New(oFilAti:Cell("DT6_QTDVOL"),/*cId*/,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
oTotaliz:SetCondition( { || TMR340Doc( (cAliasQry)->DUD_FILDOC,(cAliasQry)->DUD_DOC,(cAliasQry)->DUD_SERIE + "3" ) } )

Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo de Souza       � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR330                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,cAliasQry)

Local cAtivChg := Padr( GetMV("MV_ATIVCHG",," "), Len( DTW->DTW_ATIVID ) ) // Atividade de chegada
Local cFilOri  := ''
Local cViagem  := ''
Local cCodVei  := ''
Local cCodMot  := ''
Local cFilDoc  := ''
Local cDocto   := ''
Local cSerie   := ''
Local cFetch   := ''
Local cCodRb3  := ''
Local cDescRb3 := ''
Local lTercRbq := DTR->(ColumnPos("DTR_CODRB3")) > 0

If lTercRbq
	cCodRb3  := "%DTR_CODRB3%"
	cDescRb3 := "%DA3D.DA3_DESC DESRB3%"
EndIf

If SerieNfId("DUD",3,"DUD_SERIE")=="DUD_SDOC"
	cFetch := "%,DUD_SDOC%"
Else
	cFetch := "%%"	
EndIf

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQry
	SELECT DTQ_FILORI, DTQ_VIAGEM, DUD_FILDOC, DUD_DOC   , DUD_SERIE, 
	       DT6_PESO  , DT6_VALTOT, DT6_QTDVOL, DTW_DATPRE, DTR_CODVEI,
	       DA3A.DA3_DESC DESVEI, DTR_CODRB1, DA3B.DA3_DESC DESRB1, DTR_CODRB2, 
	       DA3C.DA3_DESC DESRB2, DUP_CODVEI, DUP_CODMOT, DA4_NREDUZ%Exp:cFetch%, %Exp:cCodRb3%, %Exp:cDescRb3%
		FROM %table:DTW% DTW 
		JOIN %table:DTQ% DTQ 
			ON DTQ_FILIAL = %xFilial:DTQ%
			AND DTQ_FILORI = DTW_FILORI 
			AND DTQ_VIAGEM = DTW_VIAGEM 
			AND DTQ.%NotDel%
		JOIN %table:DTR% DTR 
			ON DTR_FILIAL = %xFilial:DTR%
			AND DTR_FILORI = DTW_FILORI 
			AND DTR_VIAGEM = DTW_VIAGEM 
			AND DTR.%NotDel%
		JOIN %table:DA3% DA3A 
			ON DA3A.DA3_FILIAL = %xFilial:DA3%
			AND DA3A.DA3_COD = DTR_CODVEI
			AND DA3A.%NotDel%
		LEFT JOIN %table:DA3% DA3B 
			ON DA3B.DA3_FILIAL = %xFilial:DA3%
			AND DA3B.DA3_COD = DTR_CODRB1
			AND DA3B.%NotDel%
		LEFT JOIN %table:DA3% DA3C
			ON DA3C.DA3_FILIAL = %xFilial:DA3%
			AND DA3C.DA3_COD = DTR_CODRB2
			AND DA3C.%NotDel%
		LEFT JOIN %table:DA3% DA3D
			ON DA3D.DA3_FILIAL = %xFilial:DA3%
			AND DA3D.DA3_COD = %Exp:cCodRb3%
			AND DA3D.%NotDel%
		JOIN %table:DUP% DUP 
			ON DUP_FILIAL = %xFilial:DUP%
			AND DUP_FILORI = DTR_FILORI 
			AND DUP_VIAGEM = DTR_VIAGEM 
			AND DUP_CODVEI = DTR_CODVEI 
			AND DUP.%NotDel%
		JOIN %table:DA4% DA4 
			ON DA4_FILIAL = %xFilial:DA4%
			AND DA4_COD = DUP_CODMOT
			AND DA4.%NotDel%
		JOIN %table:DUD% DUD 
			ON DUD_FILIAL = %xFilial:DUD%
			AND DUD_FILORI = DTQ_FILORI
			AND DUD_VIAGEM = DTQ_VIAGEM    
			AND DUD.%NotDel%
		JOIN %table:DT6% DT6
			ON DT6_FILIAL = %xFilial:DT6%
			AND DT6_FILDOC = DUD_FILDOC
	      AND DT6_DOC    = DUD_DOC
	      AND DT6_SERIE  = DUD_SERIE
	      AND DT6.%NotDel%
		WHERE DTW_FILIAL = %xFilial:DTW%
			AND DTW_DATREA BETWEEN %Exp:Dtos(mv_par03)% AND %Exp:Dtos(mv_par04)%
			AND DTW_ATIVID = %Exp:cAtivChg%
			AND DTW_SERTMS = %Exp:StrZero(3,Len(DTQ->DTQ_SERTMS))%
			AND DTQ_FILORI BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
			AND DTQ_STATUS = %Exp:StrZero(4,Len(DTQ->DTQ_STATUS))%
			AND DTW.%NotDel%
			AND NOT EXISTS (
				SELECT 1 
					FROM %table:DUA%
					WHERE DUA_FILIAL = %xFilial:DUA%
						AND DUA_FILDOC = DUD_FILDOC
						AND DUA_DOC    = DUD_DOC
						AND DUA_SERIE  = DUD_SERIE
						AND %NotDel% )
	ORDER BY DTW_FILIAL, DTW_FILORI, DTW_VIAGEM, DTW_DATREA, DUD_FILDOC, DUD_DOC, DUD_SERIE, DTR_CODVEI, DUP_CODMOT
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
oReport:SetMeter(DTQ->(LastRec()))

DbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !oReport:Cancel() .And. !(cAliasQry)->(Eof())
		cFilOri := (cAliasQry)->DTQ_FILORI
		cViagem := (cAliasQry)->DTQ_VIAGEM
		cCodVei := (cAliasQry)->DTR_CODVEI
		cCodMot := (cAliasQry)->DUP_CODMOT
		cFilDoc := (cAliasQry)->DUD_FILDOC
		cDocto  := (cAliasQry)->DUD_DOC
		cSerie  := (cAliasQry)->DUD_SERIE
		oReport:Section(1):Init()
		oReport:Section(1):PrintLine()
		(cAliasQry)->(DbSkip())
		While !(cAliasQry)->(Eof()) .And.	(cAliasQry)->DTQ_FILORI == cFilOri .And. ;
										   			(cAliasQry)->DTQ_VIAGEM == cViagem .And. ;
										   			(cAliasQry)->DUD_FILDOC == cFilDoc .And. ;
										   			(cAliasQry)->DUD_DOC    == cDocto  .And. ;
										   			(cAliasQry)->DUD_SERIE  == cSerie 
				oReport:Section(1):Cell("DTQ_FILORI"):Hide()
				oReport:Section(1):Cell("DTQ_VIAGEM"):Hide()
				oReport:Section(1):Cell("DUD_FILDOC"):Hide()
				oReport:Section(1):Cell("DUD_DOC"   ):Hide()
				oReport:Section(1):Cell(SerieNfId("DUD",3,"DUD_SERIE")):Hide()
				oReport:Section(1):Cell("DT6_PESO"  ):Hide()
				oReport:Section(1):Cell("DT6_VALTOT"):Hide()
				oReport:Section(1):Cell("DT6_QTDVOL"):Hide()
				oReport:Section(1):Cell("DTW_DATPRE"):Hide()
				If (cAliasQry)->DTR_CODVEI == cCodVei
					oReport:Section(1):Cell("DTR_CODVEI"):Hide()
					oReport:Section(1):Cell("DESVEI"    ):Hide()
					oReport:Section(1):Cell("DTR_CODRB1"):Hide()
					oReport:Section(1):Cell("DESRB1"    ):Hide()
					oReport:Section(1):Cell("DTR_CODRB2"):Hide()
					oReport:Section(1):Cell("DESRB2"    ):Hide()
					If lTercRbq
						oReport:Section(1):Cell("DTR_CODRB3"):Hide()
						oReport:Section(1):Cell("DESRB3"    ):Hide()
					EndIf
				Else
					oReport:Section(1):Cell("DTR_CODVEI"):Show()
					oReport:Section(1):Cell("DESVEI"    ):Show()
					oReport:Section(1):Cell("DTR_CODRB1"):Show()
					oReport:Section(1):Cell("DESRB1"    ):Show()
					oReport:Section(1):Cell("DTR_CODRB2"):Show()
					oReport:Section(1):Cell("DESRB2"    ):Show()
					If lTercRbq
						oReport:Section(1):Cell("DTR_CODRB3"):Show()
						oReport:Section(1):Cell("DESRB3"    ):Show()
					EndIf 
				Endif
				oReport:Section(1):PrintLine()
				cCodVei := (cAliasQry)->DTR_CODVEI
				cCodMot := (cAliasQry)->DUP_CODMOT
				(cAliasQry)->(DbSkip())
			EndDo
			oReport:Section(1):Cell("DTQ_FILORI"):Show()
			oReport:Section(1):Cell("DTQ_VIAGEM"):Show()
			oReport:Section(1):Cell("DUD_FILDOC"):Show()
			oReport:Section(1):Cell("DUD_DOC"   ):Show()
			oReport:Section(1):Cell(SerieNfId("DUD",3,"DUD_SERIE")):Show()
			oReport:Section(1):Cell("DT6_PESO"  ):Show()
			oReport:Section(1):Cell("DT6_VALTOT"):Show()
			oReport:Section(1):Cell("DT6_QTDVOL"):Show()
			oReport:Section(1):Cell("DTW_DATPRE"):Show()
			oReport:Section(1):Cell("DTR_CODVEI"):Show()
			oReport:Section(1):Cell("DESVEI"    ):Show()
			oReport:Section(1):Cell("DTR_CODRB1"):Show()
			oReport:Section(1):Cell("DESRB1"    ):Show()
			oReport:Section(1):Cell("DTR_CODRB2"):Show()
			oReport:Section(1):Cell("DESRB2"    ):Show()
			If lTercRbq
				oReport:Section(1):Cell("DTR_CODRB3"):Show()
				oReport:Section(1):Cell("DESRB3"    ):Show()
			EndIf 
		EndDo
		oReport:Section(1):Finish()
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMR340Doc� Autor �Eduardo de Souza       � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se devera somar totalizador                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Filial do Documento                                  ���
���          �ExpC2: Documento                                            ���
���          �ExpC3: Serie do Documento                                   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR330                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMR340Doc( cFilDoc, cDocto, cSerie )

Static aDocto := {}
Local lRet := .F.

If Ascan(aDocto, { |x| x[1]+x[2]+x[3] == cFilDoc + cDocto + cSerie } ) == 0
	Aadd( aDocto, { cFilDoc, cDocto, cSerie } )
	lRet := .T.
EndIf

Return lRet