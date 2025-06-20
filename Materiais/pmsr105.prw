#include "protheus.ch"
#include "pmsr105.ch"
                 
Static nTotHDurac	:= 0
Static nHDurac		:= 0
Static nTotHQuant	:= 0
Static nHQuant		:= 0
Static nHApont		:= 0
Static cTpTrf		:= ""
Static cDescTp		:= ""

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PMSR105   � Autor �Totvs                  � Data �14/06/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relatorio de Extrato de Projeto por Tipo de Tarefa.         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PMSR105()
Local oReport

If PmsBlkInt() 
	Return Nil
EndIf

Pergunte( "PMR105", .T. )

oReport := ReportDef()
oReport:PrintDialog()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Totvs                  � Data �14/06/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������
oReport := TReport():New( 	"PMSR105", STR0002, "",;
							{ |oReport| ReportPrint( oReport ) },;
							STR0001 )

If MV_PAR06 == 1
	PR105Analitico( oReport )
Else
	PR105Sintetico( oReport )
EndIf

Return oReport

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PR105Sintetico� Autor �Totvs              � Data �14/06/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PR105Sintetico( oReport )
Local oProjeto
Local oTipo
Local oTrf
Local oBrkEnd
Local oTotGer
Local oBrkTipo
Local oTotTipo
Local oTotTipo2
Local oTotGer2

Local aOrdem := {}

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
oProjeto := TRSection():New( oReport, STR0004, { "AF9" }, aOrdem /*{}*/, .F., .F. )

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
TRCell():New(oProjeto,	"AF9_PROJET"	,"AF9",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,	{|| AF9_PROJET })

oTipo := TRSection():New(oProjeto, STR0006, { "AFC" },/*aOrdem*/,.F.,.F.)
TRCell():New(oTipo,	"AF9_TIPPAR"	,"AF9",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,			{|| cTpTrf })
TRCell():New(oTipo,	"AN4_DESCRI"	,"AN4",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,			{|| cDescTp })
TRCell():New(oTipo,	"nHrDur"		,"AF9", STR0010/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,	{|| nHDurac } ) 		//"Total Hrs Prev."
TRCell():New(oTipo,	"nHrApo"		,"AF9", STR0011/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,	{|| nHQuant } )			//"Total Hrs Apont."

oBrkEnd 	:= TRBreak():New( oProjeto, { || /*cArqTmp->(Eof())*/	}, OemToAnsi( STR0008 ) ) //"T O T A L  G E R A L  ==> "
oTotGer 	:= TRFunction():New( oTipo:Cell( "nHrDur" ),, "ONPRINT", oBrkEnd, /*Titulo*/, PesqPict( "AF9", "AF9_HDURAC" ), { || nTotHDurac },.F.,.F.,.F., oTrf )
oTotGer2 	:= TRFunction():New( oTipo:Cell( "nHrApo" ),, "ONPRINT", oBrkEnd, /*Titulo*/, PesqPict( "AFU", "AFU_HQUANT" ), { || nTotHQuant },.F.,.F.,.F., oTrf )

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PR105Analitico� Autor �Totvs              � Data �14/06/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PR105Analitico( oReport )
Local oProjeto
Local oTipo
Local oTrf
Local oBrkEnd
Local oTotGer
Local oBrkTipo
Local oTotTipo
Local oTotTipo2
Local oTotGer2

Local aOrdem := {}

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
oProjeto := TRSection():New( oReport, STR0004, { "AF9" }, aOrdem /*{}*/, .F., .F. )

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
TRCell():New(oProjeto,	"AF9_PROJET"	,"AF9",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,	{|| AF9_PROJET })

oTipo := TRSection():New(oProjeto, STR0006, { "AFC" },/*aOrdem*/,.F.,.F.)
TRCell():New(oTipo,	"AF9_TIPPAR"	,"AF9",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,	{|| AF9_TIPPAR })
TRCell():New(oTipo,	"AN4_DESCRI"	,"AN4",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,	{|| AN4_DESCRI })

oTrf := TRSection():New(oProjeto, STR0005, { "AFC" },/*aOrdem*/,.F.,.F.)  
oTrf:SetLeftMargin(5) //tabula��o do objeto
TRCell():New(oTrf,	"AF8_DESCRI"	,"AF8",/*Titulo*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,	{|| AF8_DESCRI })
TRCell():New(oTrf,	"AF9_EDTPAI"	,"AF9",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,	{|| AF9_EDTPAI })
TRCell():New(oTrf,	"AF9_TAREFA"	,"AF9",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,	{|| AF9_TAREFA })
TRCell():New(oTrf,	"AF9_DESCRI"	,"AF9",/*Titulo*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,	{|| AF9_DESCRI })
TRCell():New(oTrf,	"AF9_TIPPAR"	,"AF9",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,	{|| AF9_TIPPAR })
TRCell():New(oTrf,	"AF9_HDURAC"	,"AF9",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,	{|| AF9_HDURAC })
TRCell():New(oTrf,	"AFU_HQUANT"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,	{|| nHApont })

oBrkTipo := TRBreak():New( oTipo, { || /*cArqTmp->(Eof())*/	}, OemToAnsi( STR0007 ) ) //"Total do Tipo de Tarefa ==>"
oTotTipo := TRFunction():New( oTrf:Cell( "AF9_HDURAC" ),, "ONPRINT", oBrkTipo, /*Titulo*/, PesqPict( "AF9", "AF9_HDURAC" ), { || nHDurac },.F.,.F.,.F., oTrf )
oTotTipo2:= TRFunction():New( oTrf:Cell( "AFU_HQUANT" ),, "ONPRINT", oBrkTipo, /*Titulo*/, PesqPict( "AFU", "AFU_HQUANT" ), { || nHQuant },.F.,.F.,.F., oTrf )

oBrkEnd 	:= TRBreak():New( oProjeto, { || /*cArqTmp->(Eof())*/	}, OemToAnsi( STR0008 ) ) //"Total no Projeto ==> "
oTotGer 	:= TRFunction():New( oTrf:Cell( "AF9_HDURAC" ),, "ONPRINT", oBrkEnd, /*Titulo*/, PesqPict( "AF9", "AF9_HDURAC" ),	{ || nTotHDurac },.F.,.F.,.F., oTrf )
oTotGer2 	:= TRFunction():New( oTrf:Cell( "AFU_HQUANT" ),, "ONPRINT", oBrkEnd, /*Titulo*/, PesqPict( "AFU", "AFU_HQUANT" ),	{ || nTotHQuant },.F.,.F.,.F., oTrf )
Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor �Totvs                 � Data �14/06/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �que faz a chamada desta funcao ReportPrint()                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport )
Local aFilTrf		:= PMSSplit( MV_PAR03, ";" )
Local aQuadro		:= {}
Local cQry			:= ""
Local cProjeto		:= ""
Local cOldProjeto	:= ""
Local cTipo			:= ""
Local cOldTipo		:= ""
Local nInc			:= 0
Local cAlias	 	:= GetNextAlias()
Local oProjeto  	:= oReport:Section( 1 )
Local oTipo	  		:= oReport:Section( 1 ):Section( 1 )
Local oTrf		  	:= oReport:Section( 1 ):Section( 2 )

cQry += "SELECT AF9.AF9_PROJET, AF8.AF8_DESCRI, AF8.AF8_REVISA, AF9.AF9_EDTPAI, AF9.AF9_TAREFA, AF9.AF9_DESCRI, AF9.AF9_TIPPAR, AF9.AF9_HDURAC, AN4.AN4_DESCRI "
cQry += "FROM " + RetSqlName( "AF9" ) + " AF9, " + RetSqlName( "AF8" ) + " AF8, " + RetSqlName( "AN4" ) + " AN4 "
cQry += "WHERE AF9.D_E_L_E_T_ <> '*' "
cQry += "AND AF8.D_E_L_E_T_ <> '*' "
cQry += "AND AN4.D_E_L_E_T_ <> '*' "
cQry += "AND AF9.AF9_TIPPAR <> '' "
cQry += "AND AF9.AF9_PROJET >= '" + MV_PAR01 + "' "
cQry += "AND AF9.AF9_PROJET <= '" + MV_PAR02 + "' "
cQry += "AND AF9.AF9_START  >= '" + DtoS( MV_PAR04 ) + "' "
cQry += "AND AF9.AF9_START  <= '" + DtoS( MV_PAR05 ) + "' "
cQry += "AND AF8.AF8_REVISA = AF9.AF9_REVISA "
cQry += "AND AF9.AF9_FILIAL = '" + xFilial( "AF9" ) + "' "
cQry += "AND AF8.AF8_FILIAL = '" + xFilial( "AF8" ) + "' "
cQry += "AND AN4.AN4_FILIAL = '" + xFilial( "AN4" ) + "' "
cQry += "AND AF9.AF9_PROJET = AF8.AF8_PROJET "
cQry += "AND AF9.AF9_TIPPAR = AN4.AN4_TIPO "

// Filtra o tipo de tarefa conforme selecao no MarkBrow
If !Empty( MV_PAR03 )
	cQry += "AND AF9.AF9_TIPPAR IN ( "
	For nInc := 1 To Len( aFilTrf )
		cQry += "'" + aFilTrf[nInc] + " '"

		If nInc < Len( aFilTrf )
			cQry += ", "
		EndIf
	Next

	cQry += " ) "
EndIf

cQry += "ORDER BY AF9.AF9_PROJET, AF9.AF9_TIPPAR, AF9.AF9_TAREFA "
cQry := ChangeQuery( cQry )
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ), cAlias, .T., .T. )

oReport:SetMeter( (cAlias)->( LastRec() ) )

// Zera os totalizadores
nHDurac		:= 0
nHQuant		:= 0
nTotHDurac	:= 0
nTotHQuant	:= 0

dbSelectArea( cAlias )
While (cAlias)->( !Eof() )
	oReport:IncMeter()
	oProjeto:lPrintHeader := .T.

	// verifica o cancelamento pelo usuario..
	If oReport:Cancel()	
		oReport:SkipLine()
		oReport:PrintText( STR0003 ) //"*** CANCELADO PELO OPERADOR ***"
	EndIf

	// Controla a quebra
	cProjeto := (cAlias)->AF9_PROJET
	If cProjeto <> cOldProjeto
		oProjeto:Init()
		oProjeto:PrintLine()

		cOldProjeto := cProjeto
		nTotHDurac	:= 0
		nTotHQuant	:= 0
	EndIf

	// Imprime as tarefas
	If MV_PAR06 == 1
		cTipo := (cAlias)->AF9_TIPPAR
		If cTipo <> cOldTipo
			oTipo:Init()
			oTipo:PrintLine()

			cOldTipo	:= cTipo
			nHDurac		:= 0
			nHQuant		:= 0
		EndIf

		// Localiza a quantidade de horas apontadas na tarefa
		nHApont		:= getApont( (cAlias)->AF9_PROJET, (cAlias)->AF8_REVISA, (cAlias)->AF9_TAREFA )
		nHQuant		+= nHApont
		nTotHQuant	+= nHApont

		// Atualiza o quadro resumo que sera impresso no final do relatorio
		nPos := aScan( aQuadro, { |x| x[1] == (cAlias)->AF9_TIPPAR } )
		If nPos > 0
			aQuadro[nPos][3] += 1
			aQuadro[nPos][4] += (cAlias)->AF9_HDURAC
			aQuadro[nPos][5] := nHQuant
		Else
			aAdd( aQuadro, { (cAlias)->AF9_TIPPAR, (cAlias)->AN4_DESCRI, 1, (cAlias)->AF9_HDURAC, nHQuant } )
		EndIf

		oTrf:Init()
		oTrf:PrintLine()

		nHDurac 	+= (cAlias)->AF9_HDURAC
		nTotHDurac	+= (cAlias)->AF9_HDURAC
		(cAlias)->( DbSkip() )
	
		// Encerra a sessao para impressao do cabecalho quando for necessario a quebra
		If (cAlias)->AF9_TIPPAR <> cOldTipo .OR. (cAlias)->AF9_PROJET <> cOldProjeto
			oReport:SkipLine()
			oTipo:Finish()
			oTrf:Finish()
		EndIf

		If (cAlias)->AF9_PROJET <> cOldProjeto
			oReport:SkipLine()
			oProjeto:Finish()
		EndIf
	Else
		nHDurac 	+= (cAlias)->AF9_HDURAC
		nTotHDurac	+= (cAlias)->AF9_HDURAC

		// Localiza a quantidade de horas apontadas na tarefa
		nHApont		:= getApont( (cAlias)->AF9_PROJET, (cAlias)->AF8_REVISA, (cAlias)->AF9_TAREFA )
		nHQuant		+= nHApont
		nTotHQuant	+= nHApont

		// Atualiza o quadro resumo que sera impresso no final do relatorio
		nPos := aScan( aQuadro, { |x| x[1] == (cAlias)->AF9_TIPPAR } )
		If nPos > 0
			aQuadro[nPos][3] += 1
			aQuadro[nPos][4] += (cAlias)->AF9_HDURAC
			aQuadro[nPos][5] := nHQuant
		Else
			aAdd( aQuadro, { (cAlias)->AF9_TIPPAR, (cAlias)->AN4_DESCRI, 1, (cAlias)->AF9_HDURAC, nHQuant } )
		EndIf

		cTipo := (cAlias)->AF9_TIPPAR
		If cTipo <> cOldTipo
			oTipo:Init()
			cOldTipo	:= cTipo
		EndIf

		// Armazena o tipo de variavel para impressao
		cTpTrf	:= (cAlias)->AF9_TIPPAR
		cDescTp	:= (cAlias)->AN4_DESCRI

		(cAlias)->( DbSkip() )

		// Encerra a sessao para impressao do cabecalho quando for necessario a quebra
		If (cAlias)->AF9_TIPPAR <> cOldTipo .OR. (cAlias)->AF9_PROJET <> cOldProjeto
			oReport:SkipLine()

			oTipo:PrintLine()
			oTipo:Finish()

			nHDurac		:= 0
			nHQuant		:= 0
		EndIf

		If (cAlias)->AF9_PROJET <> cOldProjeto
			oReport:SkipLine()
			oProjeto:Finish()
		EndIf
	EndIf
End

oProjeto:Finish()

If !Empty( aQuadro )
	PR105Quadro( oReport, aQuadro )
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PR105Quadro� Autor �Totvs                 � Data �15/06/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para impressao do quadro resumo.                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
r�����������������������������������������������������������������������������
*/
Static Function PR105Quadro( oReport, aQuadro )
Local nInc		:= 1
Local nTotCol1	:= 0
Local nTotCol2	:= 0
Local oQuadro
Local oTipo
Local oDesc
Local oQtde
Local oHDur
Local oHApo
Local oBreak
Local oTotDur
Local oTotApo

oQuadro	:= TRSection():New( oReport, STR0009, { "AF9" },/*aOrdem*/,.F.,.F.) // "Quadro Resumo"
oTipo	:= TRCell():New( oQuadro,	"AF9_TIPPAR"	,"AF9",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,	/*{|| AF9_TIPPAR }*/ )
oDesc	:= TRCell():New( oQuadro,	"AN4_DESCRI"	,"AN4",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,	/*{|| AN4_DESCRI }*/ )
oQtde	:= TRCell():New( oQuadro,	"AF9_QUANT"		,"AF9",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,	/*{|| AF9_HDURAC }*/ )
oHDur	:= TRCell():New( oQuadro,	"nHrDur"		,"AF9", STR0010/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,	/*{|| AF9_HDURAC }*/ ) //"Total Hrs Prev."
oHApo	:= TRCell():New( oQuadro,	"nHrApo"		,"AF9", STR0011/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,	/*{|| AF9_HDURAC }*/ ) //"Total Hrs Apont."

oBreak	:= TRBreak():New( oQuadro, { || /*cArqTmp->(Eof())*/	}, OemToAnsi( STR0012 ) ) //"Total"
oTotDur	:= TRFunction():New( oQuadro:Cell( "nHrDur" ),, "ONPRINT", oBreak, /*Titulo*/, PesqPict( "AF9", "AF9_HDURAC" ), { || nTotCol1 },.F.,.F.,.F., oQuadro )
oTotApo	:= TRFunction():New( oQuadro:Cell( "nHrApo" ),, "ONPRINT", oBreak, /*Titulo*/, PesqPict( "AF9", "AF9_HDURAC" ), { || nTotCol2 },.F.,.F.,.F., oQuadro )

// Inicia a impressao do quadro resumo
oReport:SkipLine()
oReport:PrintText( Upper( STR0009 ) ) // "Quadro Resumo"
oQuadro:Init()
For nInc := 1 To Len( aQuadro )
	oTipo:setBlock( { || aQuadro[nInc][1] } )
	oDesc:setBlock( { || aQuadro[nInc][2] } )
	oQtde:setBlock( { || aQuadro[nInc][3] } )
	oHDur:setBlock( { || aQuadro[nInc][4] } )
	oHApo:setBlock( { || aQuadro[nInc][5] } )

	nTotCol1	+= aQuadro[nInc][4]
	nTotCol2	+= aQuadro[nInc][5]

	oQuadro:PrintLine()	
Next

oQuadro:Finish()
Return


/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � PMSSplit     � Autor � Totvs                 � Data � 14/06/10 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Quebra uma string com caractere separador em array             ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � Siga                                                           ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Static Function PMSSplit( cCode, cSep )
	Local nAt := At(cSep, cCode)
	Local aSplit := {}

	While nAt > 0
		Aadd(aSplit, Left(cCode, nAt - 1))
		cCode := Substr(cCode, nAt + Len(cSep))
		nAt := At(cSep, cCode)
	End
		
	Aadd(aSplit, cCode)
Return aSplit

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � getApont     � Autor � Totvs                 � Data � 15/06/10 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a quantidade de horas apontadas em determinada tarefa  ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Static Function getApont( cProjeto, cRevisa, cTarefa )
Local nRet := 0

AFU->( DbSetOrder( 1 ) )
AFU->( DbSeek( xFilial( "AFU" ) + "1" + cProjeto + cRevisa + cTarefa ) )
While AFU->( !Eof() ) .AND. AFU->( AFU_FILIAL + AFU_CTRRVS + AFU_PROJET + AFU_REVISA + AFU_TAREFA ) == xFilial( "AFU" ) + "1" + cProjeto + cRevisa + cTarefa
	nRet += AFU->AFU_HQUANT

	AFU->( DbSkip() )
End

Return nRet
