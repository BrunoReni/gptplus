#INCLUDE "TMSR370.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR370  � Autor � Eduardo de Souza      � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime a Relacao Datas de Entrega em Aberto     	        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR370()

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
���Uso       � TMSR370                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()
Local oReport
Local aOrdem     := {}
Local cAliasQry  := GetNextAlias()

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
oReport:= TReport():New("TMSR370",STR0010,"TMR370", {|oReport| ReportPrint(oReport,cAliasQry)},STR0011) // "Relacao Datas de Entrega em Aberto" ### "Emite a Relacao Datas de Entrega em Aberto conforme os parametros informados"
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01	 // Filial Origem De ?   	                       �
//� mv_par02	 // Filial Origem Ate ?                           �
//� mv_par03	 // Filial Destino De ?                           �
//� mv_par04	 // Filial Destino Ate ?                          �
//� mv_par05	 // Cliente Remetente De ?                        �
//� mv_par06	 // Loja Remetente Ate ?                          �
//� mv_par07	 // Cliente Remetente Ate ?                       �
//� mv_par08	 // Loja Remetente Ate ?                          �
//� mv_par09	 // Data Emissao De ?   	                       �
//� mv_par10	 // Data Emissao Ate ?                            �
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
Aadd( aOrdem, STR0012 ) // "Fil. Docto + Documento + Serie"

oDocto:= TRSection():New(oReport,STR0013,{"DT6","DUY","DUA","DT2"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Documento"
oDocto:SetTotalInLine(.F.)
oDocto:SetLineBreak(.T.) //Pular linha quando execeder o numero de campos em uma linha
TRCell():New(oDocto,"DT6_FILDOC","DT6",STR0014,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DT6_DOC"   ,"DT6",STR0013,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DT6_SERIE" ,"DT6",STR0015,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DT6_DATEMI","DT6",STR0016,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DT6_HOREMI","DT6",STR0017,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DT6_CLIREM","DT6",STR0018,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DT6_LOJREM","DT6",STR0019,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"NOMREM"    ," "  ,STR0020,/*Picture*/,TamSx3("A1_NREDUZ")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DT6_CLIDES","DT6",STR0021,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DT6_LOJDES","DT6",STR0019,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"NOMDES"    ," "  ,STR0020,/*Picture*/,TamSx3("A1_NREDUZ")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DT6_CDRDES","DT6",STR0022,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DUY_DESCRI","DUY",STR0023,/*Picture*/,20         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DUY_EST"   ,"DUY",STR0024,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DT6_PRZENT","DT6",STR0025,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"ATRASO"    ,""   ,STR0026,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| IIf( dDataBase > (cAliasQry)->DT6_PRZENT, dDataBase - (cAliasQry)->DT6_PRZENT,0 ) } )
TRCell():New(oDocto,"DT6_FILDES","DT6",STR0027,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DUA_DATOCO","DUA",STR0028,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DUA_SEQOCO","DUA",STR0029,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DUA_CODOCO","DUA",STR0030,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocto,"DT2_DESCRI","DT2",STR0023,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oNotas:= TRSection():New(oDocto,STR0031,{"DTC"},/*Ordem do relat�rio*/,/*Campos do SX3*/,/*Campos do SIX*/) // "Documento"
oNotas:SetTotalInLine(.F.)
TRCell():New(oNotas,"DTC_NUMNFC","DTC",STR0031,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oNotas,"DTC_SERNFC","DTC",STR0015,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

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
Static Function ReportPrint(oReport,cAliasQry)

Local cAliasQry2 := GetNextAlias()
Private cFilDoc  := '' 
Private cDocto   := '' 
Private cSerie   := '' 

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQry
	SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_DATEMI, DT6_HOREMI, DT6_CLIREM, DT6_LOJREM,
			 SA1A.A1_NREDUZ NOMREM, DT6_CLIDES, DT6_LOJDES, SA1B.A1_NREDUZ NOMDES, DT6_CDRDES,
			 DUY_DESCRI, DUY_EST, DT6_PRZENT, DT6_FILDES, DUA_DATOCO, DUA_CODOCO, 
			 DUA_SEQOCO, DT2_DESCRI, DT6_FILIAL
		FROM %table:DT6% DT6
		JOIN %table:SA1% SA1A
			ON  SA1A.A1_FILIAL = %xFilial:SA1%
			AND SA1A.A1_COD  = DT6_CLIREM
			AND SA1A.A1_LOJA = DT6_LOJREM
			AND SA1A.%NotDel%
		JOIN %table:SA1% SA1B
			ON  SA1B.A1_FILIAL = %xFilial:SA1%
			AND SA1B.A1_COD = DT6_CLIDES
			AND SA1B.A1_LOJA = DT6_LOJDES
			AND SA1B.%NotDel%
		JOIN %table:DUY% DUY
			ON  DUY_FILIAL = %xFilial:DUY%
			AND DUY_GRPVEN = DT6_CDRDES
			AND DUY.%NotDel%
		LEFT JOIN %table:DUA% DUA
			ON  DUA_FILIAL = %xFilial:DUA%
			AND DUA_FILDOC = DT6_FILDOC
			AND DUA_DOC    = DT6_DOC
			AND DUA_SERIE  = DT6_SERIE
			AND DUA.%NotDel%
		LEFT JOIN %table:DT2% DT2
			ON  DT2_FILIAL = %xFilial:DT2%
			AND DT2_CODOCO = DUA_CODOCO
			AND DT2.%NotDel%
		WHERE DT6_FILIAL = %xFilial:DT6%
			AND DT6_FILORI BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
			AND DT6_FILDES BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
			AND DT6_CLIREM BETWEEN %Exp:mv_par05% AND %Exp:mv_par07%
			AND DT6_LOJREM BETWEEN %Exp:mv_par06% AND %Exp:mv_par08%
			AND DT6_DATEMI BETWEEN %Exp:Dtos(mv_par09)% AND %Exp:Dtos(mv_par10)%
			AND DT6_STATUS <> %Exp:StrZero(7,Len(DT6->DT6_STATUS))% // Status diferente de Entregue
			AND DT6_SERTMS IN (%Exp:StrZero(2,Len(DT6->DT6_SERTMS))%,%Exp:StrZero(3,Len(DT6->DT6_SERTMS))%)
			AND DT6_SERIE  <> 'PED'
			AND DT6_PRZENT < %Exp:Dtos(dDataBase)%
			AND DT6.%NotDel%
	ORDER BY DT6_FILIAL, DT6_FILDOC, DT6_DOC, DT6_SERIE
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
BeginSql Alias cAliasQry2
	SELECT DTC_NUMNFC
		FROM %table:DTC%
		WHERE DTC_FILIAL = %xFilial:DTC%
		  AND DTC_FILDOC = %report_param:cFilDoc%
		  AND DTC_DOC    = %report_param:cDocto%
		  AND DTC_SERIE  = %report_param:cSerie%
		  AND %NotDel%
	UNION
	SELECT DY4_NUMNFC
		FROM %table:DY4%
		WHERE DY4_FILIAL = %xFilial:DY4%
		  AND DY4_FILDOC = %report_param:cFilDoc%
		  AND DY4_DOC    = %report_param:cDocto%
		  AND DY4_SERIE  = %report_param:cSerie%
		  AND %NotDel%
	 	  		  
EndSql 
End REPORT QUERY oReport:Section(1):Section(1)

//-- Inicio da impressao do fluxo do relat�rio
oReport:SetMeter(DT6->(LastRec()))

DbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !oReport:Cancel() .And. !(cAliasQry)->(Eof())
		cFilDoc := (cAliasQry)->DT6_FILDOC
		cDocto  := (cAliasQry)->DT6_DOC
		cSerie  := (cAliasQry)->DT6_SERIE
		oReport:Section(1):Init()
		oReport:Section(1):PrintLine()
		(cAliasQry)->(DbSkip())
		While !(cAliasQry)->(Eof()) .And. 	(cAliasQry)->DT6_FILDOC == cFilDoc .And. ;
														(cAliasQry)->DT6_DOC    == cDocto  .And. ;
														(cAliasQry)->DT6_SERIE  == cSerie
			oReport:Section(1):Cell("DT6_FILDOC"):Hide()
			oReport:Section(1):Cell("DT6_DOC"   ):Hide()
			oReport:Section(1):Cell("DT6_SERIE" ):Hide()
			oReport:Section(1):Cell("DT6_DATEMI"):Hide()
			oReport:Section(1):Cell("DT6_HOREMI"):Hide()
			oReport:Section(1):Cell("DT6_CLIREM"):Hide()
			oReport:Section(1):Cell("DT6_LOJREM"):Hide()
			oReport:Section(1):Cell("NOMREM"    ):Hide()
			oReport:Section(1):Cell("DT6_CLIDES"):Hide()
			oReport:Section(1):Cell("DT6_LOJDES"):Hide()
			oReport:Section(1):Cell("NOMDES"    ):Hide()
			oReport:Section(1):Cell("DT6_CDRDES"):Hide()
			oReport:Section(1):Cell("DUY_DESCRI"):Hide()
			oReport:Section(1):Cell("DUY_EST"   ):Hide()
			oReport:Section(1):Cell("DT6_PRZENT"):Hide()
			oReport:Section(1):Cell("ATRASO"    ):Hide()
			oReport:Section(1):Cell("DT6_FILDES"):Hide()
			oReport:Section(1):PrintLine()
			(cAliasQry)->(DbSkip())
		EndDo
		oReport:Section(1):Cell("DT6_FILDOC"):Show()
		oReport:Section(1):Cell("DT6_DOC"   ):Show()
		oReport:Section(1):Cell("DT6_SERIE" ):Show()
		oReport:Section(1):Cell("DT6_DATEMI"):Show()
		oReport:Section(1):Cell("DT6_HOREMI"):Show()
		oReport:Section(1):Cell("DT6_CLIREM"):Show()
		oReport:Section(1):Cell("DT6_LOJREM"):Show()
		oReport:Section(1):Cell("NOMREM"    ):Show()
		oReport:Section(1):Cell("DT6_CLIDES"):Show()
		oReport:Section(1):Cell("DT6_LOJDES"):Show()
		oReport:Section(1):Cell("NOMDES"    ):Show()
		oReport:Section(1):Cell("DT6_CDRDES"):Show()
		oReport:Section(1):Cell("DUY_DESCRI"):Show()
		oReport:Section(1):Cell("DUY_EST"   ):Show()
		oReport:Section(1):Cell("DT6_PRZENT"):Show()
		oReport:Section(1):Cell("ATRASO"    ):Show()
		oReport:Section(1):Cell("DT6_FILDES"):Show()
		oReport:Section(1):Finish()
		//-- Imprime notas fiscais
		oReport:Section(1):Section(1):ExecSQL()
		If !(cAliasQry2)->(Eof())
			oReport:Section(1):Section(1):Init()
			While !(cAliasQry2)->(Eof())
				oReport:Section(1):Section(1):PrintLine()
				(cAliasQry2)->(DbSkip())
			EndDo
			oReport:Section(1):Section(1):Finish()
		EndIf
	EndDo
EndIf

Return