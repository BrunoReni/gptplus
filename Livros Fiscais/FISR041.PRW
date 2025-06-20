#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISR041.CH"
#INCLUDE "REPORT.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISR041

Relatorio de conferencia - Invest (incentivo fiscal)

@return	Nil

@author Luccas Curcio
@since 02/06/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function FISR041()
Local oReport
Private	cArqInd		:=	""
Private	cArqTemp	:=	""
Private	aWizard		:=	{}
    
If TRepInUse()		//	verifica se relatorios personalizaveis esta disponivel	
    //旼컴컴컴컴컴컴컴컴컴컴컴�
	//쿔nterface de impressao �
	//읕컴컴컴컴컴컴컴컴컴컴컴�
	If R041IniRot()
	
		oReport	:= ReportDef()
		oReport:PrintDialog()
		
		If Select("IVS") > 0
			IVS->(DbCloseArea())
		Endif
		FErase(cArqTemp+GetDBExtension())
		FErase(cArqTemp+OrdBagExt())
		FErase(cArqInd+OrdBagExt())
		
	Endif
Else
	Alert( STR0001 )
Endif    

Return    

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Impressao do relatorio

@return Nil

@author Luccas Curcio
@since 16/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local	oReport
Local	oRelat
Local	cCmpValIcm	:=	Iif( Substr(aWizard[1][1] , 1 , 1 ) == "1" , "Valor do ICMS ST" , "Valor do ICMS" )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿎riacao do componente de impressao                                      �
//�                                                                        �
//쿟Report():New                                                           �
//쿐xpC1 : Nome do relatorio                                               �
//쿐xpC2 : Titulo                                                          �
//쿐xpC3 : Pergunte                                                        �
//쿐xpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//쿐xpC5 : Descricao                                                       �
//�                                                                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oReport := TReport():New("FISR041","INVEST - ES","FISR041", {|oReport| ReportPrint(oReport)},"INVEST - ES")
oReport:SetTotalInLine(.F.)

Pergunte("FISR041",.F.) 
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿎riacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//쿟RSection():New                                                         �
//쿐xpO1 : Objeto TReport que a secao pertence                             �
//쿐xpC2 : Descricao da se�ao                                              �
//쿐xpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se豫o.                   �
//쿐xpA4 : Array com as Ordens do relat�rio                                �
//쿐xpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//쿐xpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿎riacao da celulas da secao do relatorio                                �
//�                                                                        �
//쿟RCell():New                                                            �
//쿐xpO1 : Objeto TSection que a secao pertence                            �
//쿐xpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//쿐xpC3 : Nome da tabela de referencia da celula                          �
//쿐xpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//쿐xpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//쿐xpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//쿐xpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//쿐xpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸  
   
//Secao Relatorio                 
oRelat:=TRSection():New(oReport,"INVEST",{"IVS"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)    //M�todo construtor da classe TRSection
oRelat:SetPageBreak(.T.)  //Define se salta a p�gina na quebra de se豫o         

//旼컴컴컴컴컴컴컴컴컴컴컴�
//쿌penas se Analitico	  �
//읕컴컴컴컴컴컴컴컴컴컴컴�
TRCell():New(oRelat,"ID"		,"IVS","ID"					,/*cPicture*/		,1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"DOC"		,"IVS","Documento"			,/*cPicture*/		,25,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"SERIE"		,"IVS","S�rie"				,/*cPicture*/		,15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"CLIFOR"	,"IVS","C�digo Clie/For"	,/*cPicture*/		,20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"LOJA"		,"IVS","Loja"				,/*cPicture*/		,15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"VALICM"	,"IVS",cCmpValIcm			,"@E 999,999,999.99",25,/*lPixel*/,/*{|| code-block de impressao }*/)

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Impressao do relatorio

@return Nil

@author Luccas Curcio
@since 16/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)
Local oRelat	:= oReport:Section(1) 

R041GetQry()                     
oReport:SkipLine(10) 

oReport:Section(1):Cell("ID"):Hide()

oBreakFil := TRBreak():New(oRelat,oRelat:Cell("ID"),"Total de ICMS",.F.) // "Total Fornecedor   
TRFunction():New(oRelat:Cell("VALICM"),Nil,"SUM",oBreakFil,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.,.F.)       


oRelat:Print()

Return         

//-------------------------------------------------------------------
/*/{Protheus.doc} R040GetQry

Cria arquivos da rotina (TRB, indices) e executa query

@return	Nil

@author Luccas Curcio
@since 16/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function R041GetQry()    
Local	aTRB		:=	{}
Local	aCfop		:=	xApCfopDef("SAI_IE",.T.)
Local	cAliasQry	:=	GetNextAlias()
Local	cWhere		:=	""
Local	cGroup		:=	""
Local	cOrder		:=	""
Local	dDtIni		:=	Ctod('01/'+StrZero(mv_par01,2)+'/'+Substr(StrZero(mv_par02,4),3,2))
Local	dDtFim		:=	UltimoDia(dDtIni)

aTRB := R041CriaTrb()

cArqTemp := CriaTrab(aTRB)
dbUseArea(.T.,,cArqTemp,"IVS",.T.,.F.)

cArqInd  := CriaTrab(NIL,.F.)
IndRegua("IVS",cArqInd,"DOC+SERIE+CLIFOR+LOJA")    
dbClearIndex()
dbSelectArea("IVS")
dbSetIndex(cArqInd+OrdBagExt())
dbSetOrder(1)

aAdd(aTRB,{cArqTemp,"IVS"})

// ------------------
// Credito Presumido
// ------------------
If Substr(aWizard[1][1] , 1 , 1 ) == "1"

	cWhere	+=	"%SFT.FT_FILIAL = '" + xFilial( "SFT" ) + "' AND "
	cWhere	+=	"SFT.FT_ENTRADA >= '" + DToS( dDtIni ) + "' AND "
	cWhere	+=	"SFT.FT_ENTRADA <= '" + DToS( dDtFim ) + "' AND "
	cWhere	+=	"SFT.FT_CFOP IN "+aCfop[1]+" AND "
	cWhere	+=	"SFT.D_E_L_E_T_=' ' "
	
	cGroup	:=	"GROUP BY SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA "
	cOrder	:=	"ORDER BY SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA%"

	BeginSql Alias cAliasQry
	                
	    SELECT
			SFT.FT_NFISCAL NFISCAL, SFT.FT_SERIE SERIE, SFT.FT_CLIEFOR CLIEFOR, SFT.FT_LOJA LOJA, SUM(SFT.FT_VALICM) VALICM
	    FROM 
	        %Table:SFT% SFT
		WHERE
			%Exp:cWhere+cGroup+cOrder%
	EndSql	 

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	
	While (cAliasQry)->(!Eof())
			
		DbSelectArea ("IVS")
		IVS->(dbSetOrder(1))
		IF !IVS->(MsSeek( (cAliasQry)->(NFISCAL+SERIE+CLIEFOR+LOJA) ) )
			Reclock("IVS",.T.)                  
			IVS->DOC		:= (cAliasQry)->NFISCAL
			IVS->SERIE		:= (cAliasQry)->SERIE
			IVS->CLIFOR		:= (cAliasQry)->CLIEFOR
			IVS->LOJA		:= (cAliasQry)->LOJA
			IVS->VALICM		:= (cAliasQry)->VALICM
			MsUnLock()	
		EndIf		
		(cAliasQry)->(dbSkip()) 
	End
	 	
 	(cAliasQry)->(DbCloseArea())

// --------------------
// Estorno de Credito
// --------------------
Else

	cTes	:=	xApGetIncent( "INV" , , , { 4 , &(GetNewPar("MV_INVETES","{}") ) , .T. } )[1]

	cWhere	+=	"%SFT.FT_FILIAL = '" + xFilial( "SFT" ) + "' AND "
	cWhere	+=	"SFT.FT_ENTRADA >= '" + DToS( dDtIni ) + "' AND "
	cWhere	+=	"SFT.FT_ENTRADA <= '" + DToS( dDtFim ) + "' AND "
	cWhere	+=	"SFT.D_E_L_E_T_=' ' "
	
	cGroup	:=	"GROUP BY SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA "
	cOrder	:=	"ORDER BY SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA%"

	BeginSql Alias cAliasQry
	                
	    SELECT
			SFT.FT_NFISCAL NFISCAL, SFT.FT_SERIE SERIE, SFT.FT_CLIEFOR CLIEFOR, SFT.FT_LOJA LOJA, SUM(SFT.FT_VALICM) VALICM
	    FROM 
	        %Table:SFT% SFT
	    JOIN
	    	%Table:SD2% SD2 ON SFT.FT_FILIAL = SD2.D2_FILIAL AND SFT.FT_NFISCAL = SD2.D2_DOC AND SFT.FT_SERIE = SD2.D2_SERIE AND SFT.FT_CLIEFOR = SD2.D2_CLIENTE AND SFT.FT_LOJA = SD2.D2_LOJA AND SFT.FT_ITEM = SD2.D2_ITEM AND SD2.%NotDel% AND SD2.D2_TES IN ( %Exp:cTes% )
		WHERE
			%Exp:cWhere+cGroup+cOrder%
	EndSql	 

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	
 	While (cAliasQry)->(!Eof())
			
		DbSelectArea ("IVS")
		IVS->(dbSetOrder(1))
		IF !IVS->(MsSeek( (cAliasQry)->(NFISCAL+SERIE+CLIEFOR+LOJA) ) )
			Reclock("IVS",.T.)                  
			IVS->DOC		:= (cAliasQry)->NFISCAL
			IVS->SERIE		:= (cAliasQry)->SERIE
			IVS->CLIFOR		:= (cAliasQry)->CLIEFOR
			IVS->LOJA		:= (cAliasQry)->LOJA
			IVS->VALICM		:= (cAliasQry)->VALICM
			MsUnLock()	
		EndIf		
		(cAliasQry)->(dbSkip()) 
	End
	 	
 	(cAliasQry)->(DbCloseArea())
 	
 Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} R040CriaTrb

Retorna arquivo de trabalho - TRB

@return	aCampos

@author Luccas Curcio
@since 16/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function R041CriaTrb()
Local	aCampos	:=	{}

aCampos:={	{"DOC"		,"C",09,0},;
			{"SERIE"	,"C",03,0},;
			{"CLIFOR"	,"C",06,0},;
			{"LOJA"		,"C",02,0},;
			{"VALICM"	,"N",14,2} }

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} R041IniRot

inicializa rotina

@return	

@author Luccas Curcio
@since 16/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function R041IniRot()
Local	aFirstTxt	:=	{}
Local	aGetParam	:=	{}
Local	cNameWiz	:=	"FSR041" + FWGETCODFILIAL

aAdd (aFirstTxt, "Relat�rio de Confer�ncia do Incentivo Fiscal Desenvolve - BA")
aAdd (aFirstTxt, "")	
aAdd (aFirstTxt, "Preencha corretamente as perguntas para processamento da rotina.")
aAdd (aFirstTxt, "Informa寤es necess�rias para o Relat�rio de Confer�ncia - Desenvolve - BA")

aAdd (aGetParam, {})
aAdd (aGetParam[1], "Preencha corretamente as informa寤es solicitadas.")
aAdd (aGetParam[1], "Par�metros para Processamento")
aAdd (aGetParam[1], {})

aAdd (aGetParam[1][3], {1,"Objetivo da Listagem",,,,,,})
aAdd (aGetParam[1][3], {3,,,,,{"1 - Cr�dito Presumido" , "2 - Estorno de Cr�dito" },,})

If xMagWizard (aFirstTxt, aGetParam, cNameWiz)
	xMagLeWiz(cNameWiz,@aWizard,.T.)
Endif

Return Len( aWizard ) > 0