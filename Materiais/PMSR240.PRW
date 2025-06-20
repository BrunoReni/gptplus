#include "protheus.ch"
#include "PMSR240.ch"
                 
Static cStatus		:= ""
Static nTotHQuant	:= 0

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PMSR240   � Autor �Totvs                  � Data �21/06/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relatorio de Pre-Apontamento dos Recursos.                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PMSR240()
Private cRetSX1		:= ""

If PmsBlkInt() 
	Return Nil
EndIf

Pergunte( "PMR240", .F. )

oReport := ReportDef()

oReport:PrintDialog()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Totvs                  � Data �21/06/2010���
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
oReport := TReport():New( 	"PMSR240", STR0002, "PMR240",;
							{ |oReport| ReportPrint( oReport ) },;
							STR0001 )

PR240Analitico( oReport )

Return oReport

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PR240Analitico� Autor �Totvs              � Data �21/06/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PR240Analitico( oReport )
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
Local cObfNRecur := IIF(FATPDIsObfuscate("AE8_DESCRI",,.T.),FATPDObfuscate("RESOURCE NAME","AE8_DESCRI",,.T.),"")      

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
TRCell():New(oProjeto,	"AJK_RECURS"	,"AJK",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,		{|| AJK_RECURS })
TRCell():New(oProjeto,	"AE8_DESCRI"	,"AE8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,		{|| IIF(Empty(cObfNRecur),AE8_DESCRI,cObfNRecur) })

oTrf := TRSection():New(oProjeto, STR0005, { "AJK" },/*aOrdem*/,.F.,.F.)
TRCell():New(oTrf,	"AJK_DATA"		,"AJK",/*Titulo*/,/*Picture*/,10/*Tamanho*/,/*lPixel*/,			{|| StoD( AJK_DATA ) })  
TRCell():New(oTrf,	"AJK_PROJET"	,"AJK",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,			{|| AJK_PROJET })
TRCell():New(oTrf,	"AF8_DESCRI"	,"AF8",/*Titulo*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,			{|| AF8_DESCRI })
TRCell():New(oTrf,	"AF9_EDTPAI"	,"AF9",STR0006/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,	{|| AF9_EDTPAI })
TRCell():New(oTrf,	"AJK_TAREFA"	,"AJK",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,			{|| AJK_TAREFA })
TRCell():New(oTrf,	"AF9_DESCRI"	,"AF9",/*Titulo*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,			{|| AF9_DESCRI })
TRCell():New(oTrf,	"AJK_HORAI"		,"AJK",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,			{|| AJK_HORAI })
TRCell():New(oTrf,	"AJK_HORAF"		,"AJK",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,			{|| AJK_HORAF })
TRCell():New(oTrf,	"AJK_HQUANT"	,"AJK",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,			{|| AJK_HQUANT })
TRCell():New(oTrf,	"cStatus"		,"AJK",STR0008 /*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,	{|| cStatus })

oTrf:Cell("AJK_PROJET"):SetLineBreak()
oTrf:Cell("AF8_DESCRI"):SetLineBreak()

oBrkEnd 	:= TRBreak():New( oProjeto, { || /*cArqTmp->(Eof())*/	}, OemToAnsi( STR0007 ) ) //"Total de Horas do Recurso -->"
oTotGer 	:= TRFunction():New( oTrf:Cell( "AJK_HQUANT" ),, "ONPRINT", oBrkEnd, /*Titulo*/, PesqPict( "AJK", "AJK_HQUANT" ),	{ || nTotHQuant },.F.,.F.,.F., oTrf )

Return(oReport)  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor �Totvs                 � Data �21/06/2010���
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
Local cQry			:= ""
Local cRecurso		:= ""
Local cOldRecurso	:= ""
Local cAlias	 	:= GetNextAlias()
Local oProjeto  	:= oReport:Section( 1 )
Local oTrf		  	:= oReport:Section( 1 ):Section( 1 )
Local lSkip			:= .F.

// Monta a query para emissao do relatorio
cQry += "SELECT AJK.AJK_DATA, "
cQry += " AJK.AJK_PROJET, "
cQry += " AJK.AJK_RECURS, "
cQry += " AE8.AE8_DESCRI, "
cQry += " AF8.AF8_DESCRI, "
cQry += " AF9.AF9_EDTPAI, "
cQry += " AJK.AJK_TAREFA, "
cQry += " AF9.AF9_DESCRI, "
cQry += " AF9.R_E_C_N_O_ AS AF9REC, "
cQry += " AJK.AJK_HORAI, "
cQry += " AJK.AJK_HORAF, "
cQry += " AJK.AJK_HQUANT, "
cQry += " AJK.AJK_SITUAC, "
cQry += " AJK.R_E_C_N_O_ AS AJKREC "
cQry += "FROM " + RetSqlName( "AJK" ) + " AJK "
cQry += "LEFT JOIN " + RetSqlName( "AF8" ) + " AF8 ON AF8_PROJET = AJK_PROJET AND AF8_REVISA = AJK_REVISA "
cQry += "LEFT JOIN " + RetSqlName( "AF9" ) + " AF9 ON AF9_PROJET = AJK_PROJET AND AF9_REVISA = AJK_REVISA AND AF9_TAREFA = AJK_TAREFA "
cQry += "LEFT JOIN " + RetSqlName( "AE8" ) + " AE8 ON AE8_RECURS = AJK_RECURS "
cQry += "WHERE AJK.D_E_L_E_T_ = '' "
cQry += "AND AF8.D_E_L_E_T_ = '' "
cQry += "AND AF9.D_E_L_E_T_ = '' "
cQry += "AND AE8.D_E_L_E_T_ = '' "
cQry += "AND AF9.AF9_FILIAL = '" + xFilial( "AF9" ) + "' "
cQry += "AND AF8.AF8_FILIAL = '" + xFilial( "AF8" ) + "' "
cQry += "AND AE8.AE8_FILIAL = '" + xFilial( "AE8" ) + "' "
cQry += "AND AJK.AJK_FILIAL = '" + xFilial( "AJK" ) + "' "
cQry += "AND AJK.AJK_RECURS >= '" + MV_PAR01 + "' "
cQry += "AND AJK.AJK_RECURS <= '" + MV_PAR02 + "' "
cQry += "AND AJK.AJK_PROJET >= '" + MV_PAR03 + "' "
cQry += "AND AJK.AJK_PROJET <= '" + MV_PAR04 + "' "
cQry += "AND AJK.AJK_DATA   >= '" + DtoS( MV_PAR05 ) + "' "
cQry += "AND AJK.AJK_DATA   <= '" + DtoS( MV_PAR06 ) + "' "
cQry += "ORDER BY AJK_RECURS, AJK_DATA, AJK_PROJET, AF9_EDTPAI, AJK_TAREFA "
cQry := ChangeQuery( cQry )
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ), cAlias, .T., .T. )

oReport:SetMeter( (cAlias)->( LastRec() ) )

// Zera o totalizador
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

	// Forca o posicionamento nas tabelas seguintes para caso o usuario 
	// queira personalizar as celulas do relatorio
	AF9->( DbGoTo( (cAlias)->AF9REC ) )
	AJK->( DbGoTo( (cAlias)->AJKREC ) )

	If MV_PAR07 <> 4
		lSkip := .F.
		If MV_PAR07 == 1 .AND. !Empty( (cAlias)->AJK_SITUAC ) .AND. (cAlias)->AJK_SITUAC <> "1"
			lSkip := .T.
		ElseIf MV_PAR07 == 2 .AND. (cAlias)->AJK_SITUAC <> "2"
			lSkip := .T.
		ElseIf MV_PAR07 == 3 .AND. (cAlias)->AJK_SITUAC <> "3"
			lSkip := .T.
		EndIf

		If lSkip
			(cAlias)->( DbSkip() )

			// Encerra a sessao para impressao do cabecalho quando for necessario a quebra
			If !Empty( cOldRecurso ) .AND. (cAlias)->AJK_RECURS <> cOldRecurso
				oReport:SkipLine()
				oTrf:Finish()
				oProjeto:Finish()
			EndIf

			Loop
		EndIf
	EndIf

	// Controla a quebra
	cRecurso := (cAlias)->AJK_RECURS
	If cRecurso <> cOldRecurso
		oProjeto:Init()
		oProjeto:PrintLine()

		cOldRecurso := cRecurso
		nTotHQuant	:= 0
	EndIf

	nTotHQuant	+= (cAlias)->AJK_HQUANT

	cStatus		:= STR0009 //"Pendente"
	If (cAlias)->AJK_SITUAC == "2" 
		cStatus		:= STR0010 //"Aprovado"
	ElseIf (cAlias)->AJK_SITUAC == "3"
		cStatus		:= STR0011 //"Rejeitado"
	EndIf

	oTrf:Init()
	oTrf:PrintLine()

	(cAlias)->( DbSkip() )

	// Encerra a sessao para impressao do cabecalho quando for necessario a quebra
	If (cAlias)->AJK_RECURS <> cOldRecurso
		oReport:SkipLine()
		oTrf:Finish()
		oProjeto:Finish()
	EndIf
End

oProjeto:Finish()

Return

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta fun��o deve utilizada somente ap�s 
    a inicializa��o das variaveis atravez da fun��o FATPDLoad.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, L�gico, Retorna se o campo ser� ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   



//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun��o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
