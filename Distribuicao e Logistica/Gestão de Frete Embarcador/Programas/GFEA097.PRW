#INCLUDE "GFEA097.ch"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA097
Envio de Faturas por Lote
Generico.

@sample
GFER097()

@author Israel Possoli
@since 08/04/2010
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA097()
	Local oReport                   //objeto que contem o relatorio
	
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
	
Return      

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA097
Envio de Faturas por Lote
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
	oReport:= TReport():New("GFEA097",STR0001,"GFEA097", {|oReport| ReportPrint(oReport)},STR0002)  //"Envio de Faturas por Lote"###"Envio de Faturas por Lote."
	oReport:SetLandscape()   // define se o relatorio saira deitado
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
	oReport:SetTotalInLine(.F.)
	oReport:nFontBody	:= 10 // Define o tamanho da fonte.
	oReport:nLineHeight	:= 50 // Define a altura da linha.
	If !IsBlind()
		Pergunte("GFEA097",.F.)
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
	  
	oSection1 := TRSection():New(oReport,STR0003,{"GW6"},aOrdem)  //"Faturas"
	oSection1:SetLineStyle() //Define a impressao da secao em linha
	oSection1:SetTotalInLine(.F.)
	TRCell():New(oSection1,"GW6->GW6_NRFAT", "GW6", STR0004 , /**/, 16, /*lPixel*/, /*{|| code-block de impressao }*/) //"Fatura"
	
	
Return oReport

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA097
Envio de Faturas por Lote
Generico.

@sample
ReportPrint(oReport,cAliasQry)

@author Israel Alcantara Possoli
@since 08/04/09                              
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local dDtTrans  := MV_PAR12
	Local lDtEmpty  := .F.
	Local aRet
	Local s_FTMLA  := SuperGetMV("MV_FTMLA", .F., "1")
	Local s_DTULFE := SuperGetMv("MV_DTULFE",,"20000101")
	Local cIntFisc  := SuperGetMv("MV_GFEI23",.F.,"2")
	local lSelecaoDF := .T.
	local cFiscRec  :=  SuperGetMv("MV_ATUCTRC",.F.,"1")
	local cERPGFE   :=  SuperGetMv("MV_ERPGFE",.F.,"1")
	
	If MV_PAR11 != 3
	
		If !Empty(dDtTrans) .And. dDtTrans <= s_DTULFE
			Help( ,, 'Help',, STR0005 + DTOC(s_DTULFE) + STR0006, 1, 0 ) //"Data de transa豫o deve ser posterior a data do �ltimo fechamento: " //" (Par�metro MV_DTULFE)"
			Return .F.
		ElseIf Empty(dDtTrans)
			lDtEmpty := .T.
		EndIf
	
	EndIf
		
	dbSelectArea("GW6")
	GW6->( dbSetOrder(1) )
	GW6->( dbSeek(MV_PAR01, .T.) )
	
	oSection1:Init()
	
	While !GW6->( Eof() ) .And. GW6->GW6_FILIAL >= MV_PAR01 .And. GW6->GW6_FILIAL <= MV_PAR02

		If GW6->GW6_EMIFAT >= MV_PAR03 .And. GW6->GW6_EMIFAT <= MV_PAR04 .And. ;
		   GW6->GW6_NRFAT  >= MV_PAR05 .And. GW6->GW6_NRFAT  <= MV_PAR06 .And. ;
		   GW6->GW6_SERFAT >= MV_PAR07 .And. GW6->GW6_SERFAT <= MV_PAR08 .And. ;
		   GW6->GW6_DTEMIS >= MV_PAR09 .And. GW6->GW6_DTEMIS <= MV_PAR10 .And. ;
		   IIf(MV_PAR11 == 3, Empty(GW6->GW6_DTFIN) .Or. GW6->GW6_DTFIN > s_DTULFE, IIf(!lDtEmpty, dDtTrans >= GW6->GW6_DTEMIS, .T.))
		   
		   IF s_FTMLA == "4" .And. GW6->GW6_SITMLA <> "4"
		      GW6->( dbSkip() )
	          Loop
		   EndIf
		   		   
		   	If lDtEmpty
				If GW6->GW6_DTCRIA < s_DTULFE
	           		GW6->( dbSkip() )
	           		Loop
	           	Else
	           		dDtTrans := GW6->GW6_DTCRIA
	           	EndIf
	   		EndIf
		   	
		   	/*Valida integra豫o fiscal*/
		   	If cIntFisc == "1"					
				GW3->(dbSetOrder(8))
				If GW3->(dbSeek( GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS )))
					lSelecaoDF := .T.
				    While !GW3->( Eof() ) .AND. ;
				    	   GW3->GW3_FILFAT == GW6->GW6_FILIAL 		.AND. ;
				    	   GW3->GW3_EMIFAT == GW6->GW6_EMIFAT 		.AND. ;
				    	   GW3->GW3_SERFAT == GW6->GW6_SERFAT 		.AND. ;
				    	   GW3->GW3_NRFAT  == GW6->GW6_NRFAT  		.AND. ;
				    	   GW3->GW3_DTEMFA == GW6->GW6_DTEMIS 												
	
						// Verifica a situa豫o da integra豫o Fiscal								
						If (GW3->GW3_SITFIS != "4" .AND. GW3->GW3_SITFIS != "6" .AND. GW3->GW3_SITREC == "6") .OR.; //SIT. REC == 6 GARANTE QUE N홒 � DOC. FRETE SOBRE ENTRADAS
						   (cERPGFE == "1" .AND. cFiscRec == "2" .AND. GW3->GW3_SITREC != "4" .AND. GW3->GW3_SITREC != "6")  //ERP=DATASUL E ATUALIZA FISCAL VIA RECEBIMENTO E A SITUACAO REC <> ATUALIZADA OU <> N홒 SE APLICA		      

						   lSelecaoDF := .F.
						   Exit				  

						EndIF	
						
						GW3->( dbSkip() )					
					EndDo
					
					If lSelecaoDF == .F.
					   GW6->( dbSkip() )
	           		   Loop
	           		EndIf
	           							
				EndIF				
			EndIf
			/* */
		   	
		   	
			If (GW6->GW6_SITFIN == "1" .Or. GW6->GW6_SITFIN == "3" .Or. GW6->GW6_SITFIN == "4") .And. ;
			   (GW6->GW6_SITAPR == "3" .Or. GW6->GW6_SITAPR == "4")
			
				If (MV_PAR11 == 1 .And. GW6->GW6_SITFIN == "1") .Or. ; // Atualizar
		           (MV_PAR11 == 2 .And. GW6->GW6_SITFIN == "3") .Or. ; // Atu Rejeitado
		           (MV_PAR11 == 3 .And. GW6->GW6_SITFIN == "4") //Desatualizar
					
		           	If MV_PAR11 == 3
		           		aRet := GFEA070In("5")
		           	Else
		           		aRet := GFEA070In("2", dDtTrans)
		           	EndIf
		           	
		           	If aRet[1]
	           			oSection1:PrintLine()
	           		EndIf
		           	
				EndIf
				
			EndIf
			
		EndIf
		
		GW6->( dbSkip() )
		
	EndDo
	
	oSection1:Finish()
Return

