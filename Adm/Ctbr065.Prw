#INCLUDE "CTBR065.CH"
#Include "PROTHEUS.CH"

// 17/08/2009 -- Filial com mais de 2 caracteres

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    � CTBR065    � Autor � Wagner Mobile Costa   � Data � 21.07.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Relatorio do Cadastro de Plano Gerencial                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � SIGACTB                                                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Function Ctbr065()

CTBR065R4()

Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o	 � CTBR065R4 � Autor� Daniel Sakavicius		� Data � 26/07/06 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Relatorio do Cadastro de Plano Gerencial - R4   			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe	 � CTBR065R4												  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � SIGACTB                                    				  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function CTBR065R4()         

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矷nterface de impressao                                                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oReport := ReportDef()      

If valtype( oReport ) == 'O'

	If ! Empty( oReport:uParam )
		Pergunte( oReport:uParam, .F. )
	EndIf	

	oReport:PrintDialog()      
Endif

oReport := nil

Return                                

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  砇eportDef � Autor � Daniel Sakavicius		� Data � 26/07/06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矱sta funcao tem como objetivo definir as secoes, celulas,   潮�
北�          硉otalizadores do relatorio que poderao ser configurados     潮�
北�          硃elo relatorio.                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � SIGACTB                                    				  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function ReportDef() 
Local oReport   
Local cReport		:= "CTR065"
Local cTitulo		:= STR0003				   			// "Listagem da Vis鋙 Gerencial"
Local cDesc			:= STR0001					  		// "Este programa ira emitir o Cadastro de Plano Gerencial."
Local cPerg	   		:= "CTR065"			  
Local cDescE		:= "cDescE"
Local nQtEnt		:= CtbQtdEntd()
Local nX
			
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矯riacao do componente de impressao                                      �
//砊Report():New                                                           �
//矱xpC1 : Nome do relatorio                                               �
//矱xpC2 : Titulo                                                          �
//矱xpC3 : Pergunte                                                        �
//矱xpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//矱xpC5 : Descricao                                                       �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

//"Este programa tem o objetivo de emitir o Cadastro de Itens Classe de Valor "
//"Sera impresso de acordo com os parametros solicitados pelo"
//"usuario"
oReport	:= TReport():New( cReport,cTitulo,cPerg, { |oReport| ReportPrint( oReport ) }, cDesc ) 

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矯riacao da secao utilizada pelo relatorio                               �
//砊RSection():New                                                         �
//矱xpO1 : Objeto TReport que a secao pertence                             �
//矱xpC2 : Descricao da se鏰o                                              �
//矱xpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se玢o.                   �
//矱xpA4 : Array com as Ordens do relat髍io                                �
//矱xpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//矱xpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oSection1  := TRSection():New( oReport, cTitulo, {"CTS"},, .F., .F. )        

TRCell():New( oSection1, "CTS_CODPLA"  , "CTS",Substr(STR0004,1,5)/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_ORDEM"   , "CTS",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_LINHA"   , "CTS",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_CONTAG"  , "CTS",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_CTASUP"  , "CTS",Substr(STR0004,45,18)/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_DESCCG"  , "CTS",Substr(STR0004,66,10)/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_NORMAL"  , "CTS",Substr(STR0004,87,6)/*Titulo*/,/*Picture*/,7/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_CLASSE"  , "CTS",Substr(STR0004,94,6)/*Titulo*/,/*Picture*/,9/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_CT1INI"  , "CTS",/*Titulo*/,/*Picture*/,TamSx3("CTS_CT1INI")[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_CT1FIM"  , "CTS",/*Titulo*/,/*Picture*/,TamSx3("CTS_CT1FIM")[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_CTTINI"  , "CTS",/*Titulo*/,/*Picture*/,TamSx3("CTS_CTTINI")[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_CTTFIM"  , "CTS",/*Titulo*/,/*Picture*/,TamSx3("CTS_CTTFIM")[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_IDENT"   , "CTS",/*Titulo*/,/*Picture*/,7/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_CTDINI"  , "CTS",/*Titulo*/,/*Picture*/,TamSx3("CTS_CTDINI")[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_CTDFIM"  , "CTS",/*Titulo*/,/*Picture*/,TamSx3("CTS_CTDFIM")[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_CTHINI"  , "CTS",/*Titulo*/,/*Picture*/,TamSx3("CTS_CTHINI")[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_CTHFIM"  , "CTS",/*Titulo*/,/*Picture*/,TamSx3("CTS_CTHFIM")[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)

TRCell():New( oSection1, "CTS_E05INI"  , "CTS",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_E05FIM"  , "CTS",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_E06INI"  , "CTS",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_E06FIM"  , "CTS",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_E07INI"  , "CTS",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_E07FIM"  , "CTS",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_E08INI"  , "CTS",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_E08FIM"  , "CTS",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_E09INI"  , "CTS",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_E09FIM"  , "CTS",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)

TRCell():New( oSection1, "CTS_TPSALD"  , "CTS",Substr(STR0004,204,4)/*Titulo*/,/*Picture*/,4/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CTS_FORMUL"  , "CTS",/*Titulo*/,/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)

oReport:SetLandScape(.T.)
oReport:DisableOrientation()

For nX := 5 to 9
	If nQtEnt<nX
		oSection1:Cell("CTS_E"+StrZero(nX,2)+"INI"):Disable()
		oSection1:Cell("CTS_E"+StrZero(nX,2)+"FIM"):Disable()
	EndIf
Next nX

//oSection2  := TRSection():New( oSection1, cTitulo, {"CTS"},, .F., .F. )        
//TRCell():New( oSection2, "CTS_CODPLA"  , "CTS",Substr(STR0004,1,5)/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
//TRCell():New( oSection2, "CTS_ORDEM"  , "CTS",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
//TRCell():New( oSection2, "CTS_LINHA"  , "CTS",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
//TRCell():New( oSection2, "CTS_CONTAG"  , "CTS",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
//TRCell():New( oSection2, "CTS_CTASUP"  , "CTS",Substr(STR0004,45,18)/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
//TRCell():New( oSection2, "CTS_DESCCG"  , "CTS",Substr(STR0004,66,10)/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
//TRCell():New( oSection2, "CTS_NORMAL"  , "CTS",Substr(STR0004,87,6)/*Titulo*/,/*Picture*/,8/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
//TRCell():New( oSection2, "CTS_CLASSE"  , "CTS",Substr(STR0004,94,6)/*Titulo*/,/*Picture*/,10/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)

//Plano      Ordem Linha Entidade Gerencial   Entidade Superior    Descricao            Normal Classe    Conta Inicial        Conta Final                                                    Identificador   Sld. Formula

Return(oReport)

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  砇eportPrint� Autor � Daniel Sakavicius	� Data � 26/07/06 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矷mprime o relatorio definido pelo usuario de acordo com as  潮�
北�          硈ecoes/celulas criadas na funcao ReportDef definida acima.  潮�
北�          砃esta funcao deve ser criada a query das secoes se SQL ou   潮�
北�          砫efinido o relacionamento e filtros das tabelas em CodeBase.潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � ReportPrint(oReport)                                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矱XPO1: Objeto do relat髍io                                  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function ReportPrint( oReport )  
Local oSection1 	:= oReport:Section(1) 
Local cFilter	:= ""
Local cCampoC	:= ""
Local cWhere	:= ""
Local cChave 	:= ""
Local cQuery	:= "CTS"     
  
dbSelectArea("CTS")
dbSetOrder(1)

cChave := CTS->(IndexKey())

cQuery	:= " SELECT * "
cQuery	+= " FROM " + RetSqlName( "CTS" )
cQuery	+= " WHERE CTS_FILIAL = '" + xFilial("CTS") + "' AND "
cQuery	+= " CTS_CODPLA >= '" + mv_par01 + "' AND "
cQuery	+= " CTS_CODPLA <= '" + mv_par02 + "' AND "		
cQuery	+= " CTS_ORDEM  >= '" + mv_par03 + "' AND " 
cQuery	+= " CTS_ORDEM  <= '" + mv_par04 + "' AND " 
cQuery	+= " CTS_CONTAG >= '" + mv_par05 + "' AND "
cQuery	+= " CTS_CONTAG <= '" + mv_par06 + "' AND "

If mv_par07 == 1 
	cQuery += " CTS_CLASSE = '1' AND "
ElseIf mv_par07 == 2 
	cQuery	+= " CTS_CLASSE = '2' AND " 
EndIf

cQuery	+= " D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)		   
		
If ( Select ( "CTS" ) <> 0 )
	dbSelectArea ( "CTS" )
	dbCloseArea()
Endif

dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , 'CTS' , .T. , .F. )		
  		
dbSelectArea( "CTS" )
dbGotop()

oSection1:SetTotalInLine(.F.)
oSection1:SetLineBreak(.T.)
oSection1:Print()

oReport:SetMeter( RecCount() )

dbCloseArea("CTS")

Return