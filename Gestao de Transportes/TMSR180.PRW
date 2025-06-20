#INCLUDE "TMSR180.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR180  � Autor � Eduardo de Souza      � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Analise diaria dos fretes                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR180()

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
���Uso       � TMSR170                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local oFilMan
Local oManifest
Local aOrdem     := {}
Local cAliasQry  := GetNextAlias()
Local cAliasQry2 := GetNextAlias()
Local aAreaSM0   := SM0->(GetArea())
Local lDTX_SERMAN := DTX->(FieldPos("DTX_SERMAN")) > 0

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
oReport:= TReport():New("TMSR180",STR0011,"TMR180", {|oReport| ReportPrint(oReport,cAliasQry,cAliasQry2)},STR0012) // "Analise Diaria dos Fretes" ### "Este programa ira emitir a analise diaria dos fretes de acordo com os parametros escolhidos pelo usuario"
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
Aadd( aOrdem, STR0013 ) // "Fil. Manif. + Manifesto"

oFilMan:= TRSection():New(oReport,STR0024,{"DTX"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Filial Manifesto"
oFilMan:SetTotalInLine(.F.)
TRCell():New(oFilMan,"DTX_FILDCA","DTX",STR0014,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // 'Fil.Destino'
TRCell():New(oFilMan,"DES.FILIAL",""   ,STR0026,""        ,15         ,          , {|| Posicione("SM0",1,cEmpAnt+(cAliasQry)->DTX_FILDCA,"M0_FILIAL") }) // 'Descri��o'

oManifest:= TRSection():New(oFilMan,STR0025,{"DTX"},/*Array com as Ordens do relat�rio*/,/*Campos do SX3*/,/*Campos do SIX*/) // "Manifesto"
oManifest:SetTotalInLine(.F.)
TRCell():New(oManifest,"DTX_MANIFE","DTX",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
If lDTX_SERMAN
	TRCell():New(oManifest,"DTX_SERMAN","DTX",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
EndIf
TRCell():New(oManifest,"PESPG" ,"",STR0015,PesqPict("DT6","DT6_PESCOB"),TamSx3("DT6_PESCOB")[1]+TamSx3("DT6_PESCOB")[2],/*lPixel*/,/*{|| code-block de impressao }*/) // Peso Pago
TRCell():New(oManifest,"PESAPG","",STR0016,PesqPict("DT6","DT6_PESCOB"),TamSx3("DT6_PESCOB")[1]+TamSx3("DT6_PESCOB")[2],/*lPixel*/,/*{|| code-block de impressao }*/) // Peso Pagar
TRCell():New(oManifest,"PESTOT","",STR0017,PesqPict("DT6","DT6_PESCOB"),TamSx3("DT6_PESCOB")[1]+TamSx3("DT6_PESCOB")[2],/*lPixel*/, {|| (cAliasQry2)->PESPG + (cAliasQry2)->PESAPG }) // Peso Total
TRCell():New(oManifest,"FREPG" ,"",STR0018,PesqPict("DT6","DT6_VALTOT"),TamSx3("DT6_VALTOT")[1]+TamSx3("DT6_VALTOT")[2],/*lPixel*/,/*{|| code-block de impressao }*/) // Frete Pago
TRCell():New(oManifest,"IMPPG" ,"",STR0019,PesqPict("DT6","DT6_VALTOT"),TamSx3("DT6_VALTOT")[1]+TamSx3("DT6_VALTOT")[2],/*lPixel*/,/*{|| code-block de impressao }*/) // Imposto Pago
TRCell():New(oManifest,"TOTPG" ,"",STR0020,PesqPict("DT6","DT6_VALTOT"),TamSx3("DT6_VALTOT")[1]+TamSx3("DT6_VALTOT")[2],/*lPixel*/, {|| (cAliasQry2)->FREPG + (cAliasQry2)->IMPPG }) // Total Pago
TRCell():New(oManifest,"FREAPG","",STR0021,PesqPict("DT6","DT6_VALTOT"),TamSx3("DT6_VALTOT")[1]+TamSx3("DT6_VALTOT")[2],/*lPixel*/,/*{|| code-block de impressao }*/) // Frete Pagar
TRCell():New(oManifest,"IMPAPG","",STR0022,PesqPict("DT6","DT6_VALTOT"),TamSx3("DT6_VALTOT")[1]+TamSx3("DT6_VALTOT")[2],/*lPixel*/,/*{|| code-block de impressao }*/) // Imposto Pagar
TRCell():New(oManifest,"TOTAPG","",STR0023,PesqPict("DT6","DT6_VALTOT"),TamSx3("DT6_VALTOT")[1]+TamSx3("DT6_VALTOT")[2],/*lPixel*/, {|| (cAliasQry2)->FREAPG + (cAliasQry2)->IMPAPG }) // Total Pagar

TRFunction():New(oManifest:Cell("PESPG" ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oManifest:Cell("PESAPG"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oManifest:Cell("PESTOT"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oManifest:Cell("FREPG" ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oManifest:Cell("IMPPG" ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oManifest:Cell("TOTPG" ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oManifest:Cell("FREAPG"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oManifest:Cell("IMPAPG"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oManifest:Cell("TOTAPG"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)

RestArea(aAreaSM0)

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
���Uso       � TMSR170                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,cAliasQry,cAliasQry2)

Local lDTX_SERMAN := DTX->(FieldPos("DTX_SERMAN")) > 0

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	 

BeginSql Alias cAliasQry
	SELECT DTX_FILIAL, DTX_FILDCA
		FROM %table:DTX%
		WHERE DTX_FILIAL = %xFilial:DTX% 
  		  AND DTX_FILORI = %Exp:mv_par01%
		  AND DTX_DATMAN = %Exp:DTOS(mv_par02)%
  		  AND %NotDel%
	GROUP BY DTX_FILIAL, DTX_FILDCA
	ORDER BY DTX_FILIAL, DTX_FILDCA
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

Begin REPORT QUERY oReport:Section(1):Section(1)

	If lDTX_SERMAN
		BeginSql Alias cAliasQry2
			SELECT DTX_FILIAL, DTX_FILMAN, DTX_MANIFE, DTX_SERMAN, SUM(PESPG)  PESPG , SUM(FREPG)  FREPG , SUM(IMPPG) IMPPG ,
			       SUM(PESAPG) PESAPG, SUM(FREAPG) FREAPG, SUM(IMPAPG)IMPAPG
			  FROM (
			  SELECT DTX_FILIAL, DTX_FILMAN, DTX_MANIFE, DTX_SERMAN, 
			  	 (CASE WHEN DT6_TIPFRE = '2' THEN 0 ELSE DT6_PESCOB END) PESPG ,
			    (CASE WHEN DT6_TIPFRE = '2' THEN 0 ELSE DT6_VALFRE END) FREPG ,
			    (CASE WHEN DT6_TIPFRE = '2' THEN 0 ELSE DT6_VALIMP END) IMPPG ,
			    (CASE WHEN DT6_TIPFRE = '1' THEN 0 ELSE DT6_PESCOB END) PESAPG,
			    (CASE WHEN DT6_TIPFRE = '1' THEN 0 ELSE DT6_VALFRE END) FREAPG,
			    (CASE WHEN DT6_TIPFRE = '1' THEN 0 ELSE DT6_VALIMP END) IMPAPG
				FROM %table:DTX% DTX, %table:DUD% DUD, %table:DT6% DT6
				WHERE DTX_FILIAL = %xFilial:DTX%
					AND DTX_FILORI = %Exp:mv_par01%
					AND DTX_DATMAN = %Exp:DTOS(mv_par02)%
					AND DTX.%NotDel%
					AND DUD_FILIAL = %xFilial:DUD%
					AND DUD_VIAGEM = DTX_VIAGEM
			      	AND DUD_FILMAN = DTX_FILMAN
			     	AND DUD_MANIFE = DTX_MANIFE
			      	AND DUD_SERMAN = DTX_SERMAN
					AND DUD_FILDCA = %report_param:(cAliasQry)->DTX_FILDCA%
					AND DUD.%NotDel%
			      AND DT6_FILIAL = %xFilial:DT6%
			      AND DT6_FILDOC = DUD_FILDOC
			      AND DT6_DOC    = DUD_DOC
			      AND DT6_SERIE  = DUD_SERIE
			      AND DT6.%NotDel% ) QUERY
			GROUP BY DTX_FILIAL, DTX_FILMAN, DTX_MANIFE, DTX_SERMAN
			ORDER BY DTX_FILIAL, DTX_FILMAN, DTX_MANIFE, DTX_SERMAN
		EndSql
	Else           
		BeginSql Alias cAliasQry2                                            
			SELECT DTX_FILIAL, DTX_FILMAN, DTX_MANIFE, SUM(PESPG)  PESPG , SUM(FREPG)  FREPG , SUM(IMPPG) IMPPG ,
		       SUM(PESAPG) PESAPG, SUM(FREAPG) FREAPG, SUM(IMPAPG)IMPAPG
			  FROM (
			  SELECT DTX_FILIAL, DTX_FILMAN, DTX_MANIFE, 
			  	 (CASE WHEN DT6_TIPFRE = '2' THEN 0 ELSE DT6_PESCOB END) PESPG ,
			    (CASE WHEN DT6_TIPFRE = '2' THEN 0 ELSE DT6_VALFRE END) FREPG ,
			    (CASE WHEN DT6_TIPFRE = '2' THEN 0 ELSE DT6_VALIMP END) IMPPG ,
			    (CASE WHEN DT6_TIPFRE = '1' THEN 0 ELSE DT6_PESCOB END) PESAPG,
			    (CASE WHEN DT6_TIPFRE = '1' THEN 0 ELSE DT6_VALFRE END) FREAPG,
			    (CASE WHEN DT6_TIPFRE = '1' THEN 0 ELSE DT6_VALIMP END) IMPAPG
				FROM %table:DTX% DTX, %table:DUD% DUD, %table:DT6% DT6
				WHERE DTX_FILIAL = %xFilial:DTX%
					AND DTX_FILORI = %Exp:mv_par01%
					AND DTX_DATMAN = %Exp:DTOS(mv_par02)%
					AND DTX.%NotDel%
					AND DUD_FILIAL = %xFilial:DUD%
					AND DUD_VIAGEM = DTX_VIAGEM
			      AND DUD_FILMAN = DTX_FILMAN
			      AND DUD_MANIFE = DTX_MANIFE
					AND DUD_FILDCA = %report_param:(cAliasQry)->DTX_FILDCA%
					AND DUD.%NotDel%
			      AND DT6_FILIAL = %xFilial:DT6%
			      AND DT6_FILDOC = DUD_FILDOC
			      AND DT6_DOC    = DUD_DOC
			      AND DT6_SERIE  = DUD_SERIE
			      AND DT6.%NotDel% ) QUERY
				GROUP BY DTX_FILIAL, DTX_FILMAN, DTX_MANIFE
				ORDER BY DTX_FILIAL, DTX_FILMAN, DTX_MANIFE
		EndSql
	EndIf
 
End REPORT QUERY oReport:Section(1):Section(1)

//-- Inicio da impressao do fluxo do relat�rio
oReport:SetMeter(DTX->(LastRec()))

oReport:Section(1):Print()

Return