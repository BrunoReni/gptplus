#INCLUDE "GFEA098.ch"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA098
Envio de Contratos por Lote
Generico.

@sample
GFER098()

@author Israel Possoli
@since 08/04/2010
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA098()
	Local oReport                   //objeto que contem o relatorio
	
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
	
Return      

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA098
Envio de Contratos por Lote
Generico.

@sample
ReportDef()

@author Israel Possoli
@since 08/04/2010
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function ReportDef()
	Local oReport, oSection1
	Local aOrdem    := {}
	
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
	oReport:= TReport():New("GFEA098",STR0001,"GFEA098", {|oReport| ReportPrint(oReport)},STR0001)  //"Envio de Contratos por Lote"###"Envio de Contratos por Lote."
	oReport:SetLandscape()   // define se o relatorio saira deitado
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
	oReport:SetTotalInLine(.F.)
	oReport:nFontBody	:= 10 // Define o tamanho da fonte.
	oReport:nLineHeight	:= 50 // Define a altura da linha.
	
	If !IsBlind()
		Pergunte("GFEA098",.F.)
	EndIf	
	
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
	//�                                                                        �
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
	//�                                                                        �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

	
	//Aadd( aOrdem, "Codigo" ) // "Sequ�ncia"
	  
	oSection1 := TRSection():New(oReport,STR0002,{"GW2"},aOrdem)  //"Contratos"
	oSection1:SetLineStyle() //Define a impressao da secao em linha
	oSection1:SetTotalInLine(.F.)
	TRCell():New(oSection1,"GW2->GW2_NRCONT", "GW2", STR0003 , /**/, 8, /*lPixel*/, /*{|| code-block de impressao }*/) //"Contrato"
	
	/*************************************************************************/ 

Return(oReport)
/*************************************************************************************************************************************/   


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA098
Envio de Contratos por Lote
Generico.

@sample
ReportPrint(oReport,cAliasQry)

@author Israel Alcantara Possoli
@since 08/04/09                              
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local cAcao     := AllTrim(Str(MV_PAR11))
	Local dDtTrans  := MV_PAR10
	Local aRet
	Local s_DTULFE := SuperGetMv("MV_DTULFE",,"20000101")
	
	If MV_PAR09 != 3
	
		If Empty(dDtTrans)
			dDtTrans := Date()
		EndIf
		
		If dDtTrans < s_DTULFE
			Help( ,, 'Help',, STR0004 + DTOC(s_DTULFE) + STR0005, 1, 0 ) //"Data de transa豫o deve ser posterior a data do �ltimo fechamento: " //" (Par�metro MV_DTULFE)"
			Return .F.
		EndIf
		
	EndIf
	
	dbSelectArea("GW2")
	GW2->( dbSetOrder(1) )
	GW2->( dbSeek(MV_PAR01, .T.) )
	
	oSection1:Init()
	
	While !GW2->( Eof() ) .And. GW2->GW2_FILIAL  >= MV_PAR01 .And. GW2->GW2_FILIAL <= MV_PAR02
		
		If (GW2->GW2_CDPROP  >= MV_PAR03 .Or. Empty(MV_PAR03)) .And. GW2->GW2_CDPROP <= MV_PAR04 .And. ;
		   (GW2->GW2_NRCONT  >= MV_PAR05 .Or. Empty(MV_PAR05)) .And. GW2->GW2_NRCONT <= MV_PAR06 .And. ;
		   (GW2->GW2_DTCRIA  >= MV_PAR07 .Or. Empty(MV_PAR07)) .And. GW2->GW2_DTCRIA <= MV_PAR08 .And. ;
		   GW2->GW2_SITCON == "3"
		   
		    // Financeiro
			If cAcao == "1" 
		   
				If (MV_PAR09 != 3 .And. dDtTrans < GW2->GW2_DTCRIA) .Or. (MV_PAR09 == 3 .And. !Empty(GW2->GW2_DTFIN) .And. GW2->GW2_DTFIN <= s_DTULFE)
					GW2->( dbSkip() )
					Loop
				EndIf
				
				If (MV_PAR09 == 1 .AND. GW2->GW2_SITFIN != "1").Or.; // Atualizar
				   (MV_PAR09 == 2 .AND. GW2->GW2_SITFIN != "3").Or.; // Atu Rejeitado
				   (MV_PAR09 == 3 .AND. GW2->GW2_SITFIN != "4") //Desatualizar
				    
				    GW2->( dbSkip() )
					Loop
				   
				EndIf
			
			ElseIf cAcao == "2"
		        
        		If (GW2->GW2_SITFIN != "4" .And. MV_PAR09 != 3) .Or. (MV_PAR09 == 3 .And. !Empty(GW2->GW2_DTRH) .And. GW2->GW2_DTRH <= s_DTULFE)
        			GW2->( dbSkip() )
		 			Loop
		        EndIf
		        
				If (MV_PAR09 == 1 .AND. GW2->GW2_SITRH != "1") .Or. ; // Atualizar
				   (MV_PAR09 == 2 .AND. GW2->GW2_SITRH != "3") .Or. ; // Atu Rejeitado
				   (MV_PAR09 == 3 .AND. GW2->GW2_SITRH != "4") //Desatualizar
				   
					GW2->( dbSkip() )
				    Loop
				   
				EndIf
				
		    ElseIf cAcao == "3"
		    	
		    	If MV_PAR09 == 3 .And. !Empty(GW2->GW2_DTREC) .And. GW2->GW2_DTREC <= s_DTULFE
		    		
		    		GW2->( dbSkip() )
				    Loop
		    		
		    	EndIf
		    	
		    	If (MV_PAR09 == 1 .AND. GW2->GW2_SITREC != "1") .Or. ; // Atualizar
				   (MV_PAR09 == 2 .AND. GW2->GW2_SITREC != "3") .Or. ; // Atu Rejeitado
				   (MV_PAR09 == 3 .AND. GW2->GW2_SITREC != "4") //Desatualizar
				   
					GW2->( dbSkip() )
				    Loop
				   
				EndIf
		    	
		    EndIf
  			
  			If MV_PAR09 == 3
	           	aRet := GFEA100In("5", , cAcao)
	    	Else
	    		aRet := GFEA100In("2", dDtTrans, cAcao)
	    	EndIf
	    	
	    	If aRet[1]
           		oSection1:PrintLine()
           	EndIf
			
		EndIf
		
		GW2->( dbSkip() )
		
	EndDo
	
	oSection1:Finish()
	
Return

