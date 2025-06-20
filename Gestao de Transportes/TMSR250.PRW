#INCLUDE 'TMSR250.CH'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR250  � Autor � Eduardo de Souza      � Data � 26/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Contratos Emitidos por Tipo de Frota                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR250()

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
���Uso       � TMSR240                                                    ���
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
oReport:= TReport():New("TMSR250",STR0017,"TMR250", {|oReport| ReportPrint(oReport,cAliasQry)},STR0018) // "Relatorio Diario de Contratos Emitidos" ### "Este programa ira emitir o relatorio diario de contratos emitidos de acordo com os parametros escolhidos pelo usuario"
oReport:SetTotalInLine(.F.)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01	 // Data Fechamento De	                          �
//� mv_par02	 // Data Fechamento Ate                           �
//� mv_par03	 // Filial Origem De                              �
//� mv_par04	 // Filial Origem Ate                             �
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
Aadd( aOrdem, STR0019 ) // "Data Contr. + Fil. Origem"

oData:= TRSection():New(oReport,STR0020,{"DTY"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oData:SetTotalInLine(.F.)
oData:SetPageBreak(.T.)
TRCell():New(oData,"DTY_DATCTC","DTC",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oFilOri:= TRSection():New(oData,STR0021,{"DTY"},/*Ordem do reltatorio*/,/*Campos do SX3*/,/*Campos do SIX*/)
oFilOri:SetTotalInLine(.F.)
oFilOri:SetTotalText(STR0027)//-- "Total da Filial"
TRCell():New(oFilOri,"DTY_FILORI","DTY",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oFrota:= TRSection():New(oFilOri,STR0022,{"DA3"},/*Ordem do reltatorio*/,/*Campos do SX3*/,/*Campos do SIX*/)
oFrota:SetTotalInLine(.F.)
oFrota:SetTotalText(STR0026) //-- "Total do Tipo"
TRCell():New(oFrota,"DA3_FROVEI","DA3",/*cTitle*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oContrato:= TRSection():New(oFrota,STR0023,{"DTY","DTQ","DA3"},/*Ordem do reltatorio*/,/*Campos do SX3*/,/*Campos do SIX*/)
oContrato:SetTotalInLine(.F.)
TRCell():New(oContrato,"DTY_NUMCTC","DTY",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DTQ_FILDES","DTQ",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DTY_VIAGEM","DTY",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DTY_VALFRE","DTY",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DTY_PESO"  ,"DTY",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"DA3_CAPACM","DA3",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContrato,"KMPERC"    ,""   ,STR0024   ,PesqPict("DUV","DUV_ODOENT"),TamSx3("DUV_ODOENT")[1],/*lPixel*/, {|| Tmsr250Km((cAliasQry)->DTY_FILORI,(cAliasQry)->DTY_VIAGEM) })
TRCell():New(oContrato,"CUSTO"     ,""   ,STR0025   ,PesqPict("DTY","DTY_VALFRE"),TamSx3("DTY_VALFRE")[1],/*lPixel*/, {|| Iif( (cAliasQry)->DTY_PESO>0, ((cAliasQry)->DTY_VALFRE/(cAliasQry)->DTY_PESO)*1000,0) })

TRFunction():New(oContrato:Cell("DTY_VALFRE"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,oFrota)
TRFunction():New(oContrato:Cell("DTY_PESO"  ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,oFrota)
TRFunction():New(oContrato:Cell("DA3_CAPACM"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,oFrota)
TRFunction():New(oContrato:Cell("KMPERC"    ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,oFrota)
TRFunction():New(oContrato:Cell("CUSTO"     ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,oFrota)

TRFunction():New(oContrato:Cell("DTY_VALFRE"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oFilOri)
TRFunction():New(oContrato:Cell("DTY_PESO"  ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oFilOri)
TRFunction():New(oContrato:Cell("DA3_CAPACM"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oFilOri)
TRFunction():New(oContrato:Cell("KMPERC"    ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oFilOri)
TRFunction():New(oContrato:Cell("CUSTO"     ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oFilOri)

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

Local cWhere  := " "

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

cWhere := "%"
If mv_par07 == 1 // Frota Terceiro
	cWhere += " AND DA3_FROVEI = '2'"
ElseIf mv_par07 == 2 // Frota Agregado
	cWhere += " AND DA3_FROVEI = '3'"
EndIf
cWhere += "%"

BeginSql Alias cAliasQry
	SELECT DTY_DATCTC, DTY_FILORI, DTY_NUMCTC, DTQ_FILDES, DTY_VIAGEM , DTY_VALFRE, DTY_PESO, DA3_CAPACM, DA3_FROVEI
	   FROM %table:DTY% DTY
	   JOIN %table:DTQ% DTQ
	     ON  DTQ_FILIAL = %xFilial:DTQ%
	     AND DTQ_FILORI = DTY_FILORI 
	     AND DTQ_VIAGEM = DTY_VIAGEM 
		  AND DTQ_FILDES >= %Exp:mv_par05%
		  AND DTQ_FILDES <= %Exp:mv_par06%
	     AND DTQ_SERTMS >= %Exp:mv_par08%
	     AND DTQ_SERTMS <= %Exp:mv_par09%	     	     
	     AND DTQ.%NotDel%
	   JOIN %table:DUP% DUP
	     ON  DUP_FILIAL = %xFilial:DUP%
	     AND DUP_FILORI = DTY_FILORI 
	     AND DUP_VIAGEM = DTY_VIAGEM 
	     AND DUP_CODMOT = DTY_CODMOT 
	     AND DUP.%NotDel%
	   JOIN %table:DA3% DA3  
	     ON DA3_FILIAL = %xFilial:DA3%
	     AND DA3_COD = DUP_CODVEI 
	     AND DA3.%NotDel%
		  %Exp:cWhere%
	   WHERE DTY_FILIAL = %xFilial:DTY%
			AND DTY_DATCTC >= %Exp:Dtos(mv_par01)%
			AND DTY_DATCTC <= %Exp:Dtos(mv_par02)%
			AND DTY_FILORI >= %Exp:mv_par03%
			AND DTY_FILORI <= %Exp:mv_par04%
			AND DTY.%NotDel%
	ORDER BY DTY_FILIAL, DTY_DATCTC, DTY_FILORI, DA3_FROVEI, DTY_NUMCTC
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
oReport:Section(1):Section(1):SetParentFilter( {|cParam| (cAliasQry)->DTY_DATCTC == cParam  }, {|| (cAliasQry)->DTY_DATCTC }   )

oReport:Section(1):Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):Section(1):SetParentFilter( {|cParam| DtoS((cAliasQry)->DTY_DATCTC)+(cAliasQry)->DTY_FILORI == cParam  }, {|| DtoS((cAliasQry)->DTY_DATCTC)+(cAliasQry)->DTY_FILORI }   )

oReport:Section(1):Section(1):Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):Section(1):Section(1):SetParentFilter( {|cParam| DtoS((cAliasQry)->DTY_DATCTC)+(cAliasQry)->DTY_FILORI+(cAliasQry)->DA3_FROVEI == cParam  }, {|| DtoS((cAliasQry)->DTY_DATCTC)+(cAliasQry)->DTY_FILORI+(cAliasQry)->DA3_FROVEI }   )

oReport:Section(1):Print()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMSR250Km   �Autor  �Henry Fila          � Data �  21/06/01 ���
�������������������������������������������������������������������������͹��
���Desc.     � Traz kilometragem percorrida da viagem                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1: Nome do arquivo que sera gerado por referencia       ���
���          �ExpN2: Ordem dos produtos a serem listados                  ���
�������������������������������������������������������������������������͹��
���Uso       � TMSR250                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Tmsr250Km(cFilOri,cViagem)

Local aArea     := GetArea()
Local aAreaDUV  := DUV->(GetArea())
Local nKmViagem := 0

DUV->(dbSetOrder(1))
If DUV->(MsSeek(xFilial("DUV")+cFilOri+cViagem))
	While DUV->(!Eof()) .And. DUV->DUV_FILIAL == xFilial("DUV") .And. ;	
										DUV->DUV_FILORI == cFilOri .And. ;
										DUV->DUV_VIAGEM == cViagem

		nKmViagem += DUV->DUV_ODOSAI - DUV->DUV_ODOENT
	  	DUV->(dbSkip())
	Enddo												
Endif																

RestArea(aAreaDUV)
RestArea(aArea)

Return(nKmViagem)