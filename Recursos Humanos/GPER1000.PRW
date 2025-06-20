#INCLUDE "Protheus.CH"
#INCLUDE "IMPRESG.CH"
#INCLUDE "MSOLE.CH"
#DEFINE   nColMax	2350
#DEFINE   nLinMax  2900

// VARIAVEIS UTILIZADAS PARA ARMAZENAR AS INFORMACOES DAS PERGUNTES:
//VARIAVEL					ORDEM
//nTipo				MV_PAR01  01	//	ZEBRADO/GRAFICO/PRE-IMPR/GRFC ZEBRADO/GRFC GRAFICA
//cFilialDe			MV_PAR02  02	//	FILIAL DE
//cFilialAte		MV_PAR03  03	//	FILIAL ATE
//cMatDe			MV_PAR04  04	//	MATRICULA DE
//cMatAte			MV_PAR05  05	//	MATRICULA ATE
//cCCDe				MV_PAR06  06	//	CENTRO DE CUSTO DE
//cCCAte			MV_PAR07  07	//	CENTRO DE CUSTO ATE
//cTipoRes			MV_PAR08  08	//	NORMAL OU COMPLEMENTAR
//cImprCGC			MV_PAR09  09	//	IMPRIME CGC  SIM OU NAO
//dDtDemDe			MV_PAR10  10	//	DATA DEMISSAO DE
//dDtDemAte			MV_PAR11  11	//	DATA DEMISSAO ATE
//dDtGerDe			MV_PAR12  12	//	DATA GERACAO DE
//dDtGerAte			MV_PAR13  13	//	DATA GERACAO ATE
//nImprDtHom		MV_PAR14  14	//	IMPRIME DATA DE HOMOLOGACAO
//nNumVias			MV_PAR15  15	//	N� DE VIAS
//cImprFerias		MV_PAR16  16	//	IMP. FERIAS    		 AVOS OU DIAS
//dDtHomDe			MV_PAR17  17	//	DATA DE HOMOLOGA�CAO DE
//dDtHomAte			MV_PAR18  18	//	DATA DE HOMOLOGA�CAO AT
//cContato			MV_PAR19  19	//	NOME PARA CONTATO
//					MV_PAR20  20	//	RODAPE DO RECIBO
//					MV_PAR21  21	//	COMP. VERB 50
//					MV_PAR22  22	//	RG
//					MV_PAR23  23	//	NOME DO EMPREGADOR
//					MV_PAR24  24	//	TIPO DO ORGAO HOMOLOGADOR
//					MV_PAR25  25	// CODIGO DO MINISTERIO
//dDtDissidio		MV_PAR26  26	//	DT PUBLIC.DISS/ACOR
//nTipSal			MV_PAR27  27	//	TIPO DO SALARIO?
//					MV_PAR28  28	//	IMPRIMIR INF. EXTRA?
//					MV_PAR29  29	//	GRUPO DE VERBAS QUE COMPOEM A REMUNERACAO
//					MV_PAR30  30	//	IMPRIME CABECALHO EM OUTRA PAGINA?
//					MV_PAR31  31	//	AJUSTA LINHAS EM BRANCO?
//cImpr13Sal		MV_PAR32  32	//	IMP. 13� SAL�RIO
//cTelefone			MV_PAR33  33	//	DDD/TELEFONE
//nSimples			MV_PAR34  34	//	OPTANTE DO SIMPLES
//dEntregaGRFC		MV_PAR35  35	//	DT. ENTREGA GRFC
//					MV_PAR36  36	//	TODAS RESCISOES COMPL?

/*/{Protheus.doc} IMPRESG
Impressao da Rescisao em modo Grafico
@author Microsiga
@since 11/04/2002
@history 07/02/2014, MOHANAD, M12RH01 197401 - UNIFICACAO DA FOLHA V12
/*/
Function GPER1000()

	Local nCont			:= 2
	Local Imprime		:= 1				// LINHA DE IMPRESSAO DO RELATORIO GRAFICO 
	Local n				:= 0 
	Local nPenunSal		:= 0
	
	//DEFINE VARIAVEIS PRIVATE UTILIZADAS PARA IMPRESSAO GRAFICA
	Private nPos		:= 0				// LINHA DE IMPRESSAO DO RELATORIO GRAFICO
	Private nTot		:= 0
	Private nNumMax		:= 18				// Numero maximo de verbas impressas no Detalhe da rescisao 
	Private nImprime	:= 1 				// Variavel Auxiliar 
	Private nImpre		:= 1 
	Private CONTFL		:= 1				// CONTA PAGINA
	Private cCodSaqIOB	:= ""
	Private lGPEM40B	:= .F.
	
	//OBJETOS PARA IMPRESSAO GRAFICA - DECLARACAO DAS FONTES UTILIZADAS
	Private oFont06,oFont08, oFont09, oFont09n 
	
	DbSelectArea("SX1")
	If IsInCallStack("GPEM040B") .And. SX1->(dbSeek("GPE140R2"))
		lGPEM40B	:= .T.
	EndIf
	
	oFont06	:= TFont():New("Courier New", 06, 06,, .F.,,,, .T., .F.)
	oFont08	:= TFont():New("Courier New", 08, 08,, .F.,,,, .T., .F.)
	oFont09	:= TFont():New("Courier New", 09, 09,, .F.,,,, .T., .F.)
	oFont09n:= TFont():New("Courier New", 09, 09,, .T.,,,, .T., .F.)	// Negrito
	
	nEpoca	:= SET(5, 1910)
	SET CENTURY ON 
	nTot	:= fCalnTot()
	
	fCabecalho()
	
	While Imprime <= nTot
		//IMPRESSAO DO RODAPE E QUEBRA DE PAGINA
		If nImpre > ( nNumMax )  .or.  nImprime > nNumMax
			fRodape() 
			oPrint:EndPage()
			oPrint:StartPage()
			ContFl++
			fCabecalho()
			nCont += 2
			nNumMax := ( nNumMax * nCont ) 
			nImpre	:= ( nImpre + n)
		Endif 
	
		If nImpre <= nNumMax .or. Imprime <= nNumMax 
			//COLUNA DE PROVENTOS
			If nImpre <= Len(aPdv) 
				//PRIMEIRA COLUNA DE PROVENTO
				oPrint:say(nPos, 200, Space(1) + Subs(aPdv[nImpre], 01, 21), oFont07)
				oPrint:say(nPos, 550, Space(1) + Subs(aPdv[nImpre], 22, 06), oFont07)
				oPrint:say(nPos, 650, Space(1) + Subs(aPdv[nImpre], 29, 13), oFont07)
				//SEGUNDA COLUNA PROVENTO
				If (nImpre + nNumMax ) <= Len( aPdv )
					oPrint:say(nPos, 0900, Space(1) + Subs(aPdv[nImpre + nNumMax ], 01, 21), oFont07)
					oPrint:say(nPos, 1250, Space(1) + Right(Subs(aPdv[nImpre + nNumMax ], 22, 6), 6), oFont07)
					oPrint:say(nPos, 1380, Space(1) + Right(Subs(aPdv[nImpre + nNumMax ], 29, 13), 13), oFont07)
					n ++
				Endif 
				nImpre	+= 1
			Endif
			//COLUNA DE DESCONTOS
			If nImprime <= Len(aPdd)  
				oPrint:say(nPos, 1620, Space(1) + Subs(aPdd[nImprime], 01, 21), oFont07)
				oPrint:say(nPos, 1970, Space(1) + Right(Subs(aPdd[nImprime], 22, 06), 6) , oFont07)
				oPrint:say(nPos, 2100, Space(1) + Right(Subs(aPdd[nImprime], 29, 13), 13), oFont07)
				nImprime	++
			Endif	
		Endif
		Imprime += 1
		nPos		+= 40
	Enddo
	fRodape()
	
	Set(5,nEpoca)
	If nTdata > 8
		SET CENTURY ON
	Else
		SET CENTURY OFF
	Endif
Return

/*/{Protheus.doc} fCabecalho
Impress�o do cabe�alho modo gr�fico
@author Recursos Humanos
@since 04/11/2002
/*/
Static Function fCabecalho()

	Local cCateg	:= fCateg(0)
	Local aString	:= {} 
	Local cMunicip	:= ""
	Local cEstado 	:= "" 
	Local cBairro	:= ""
	
	If cPaisloc == "PER"
		cBairro	 := AllTrim( fDescRCC("S022", SRA->RA_CEP, 1, 6, 7, 20))
		cMunicip := AllTrim( fDescRCC("S021", SUBSTR(SRA->RA_CEP, 1, 4), 1, 4, 5, 20))
		cEstado	 := AllTrim( fDescRCC("S020", SUBSTR(SRA->RA_CEP, 1, 2), 1, 2, 3, 20))
	ElseIf cPaisloc == "EQU"
		cBairro  := SRA->RA_BAIRRO
		cMunicip := Posicione( "SX5", 1, xFilial("SX5") + "12" + SRA->RA_ESTADO, "X5_DESCRI")
		cEstado	 := fDesc( "CC2", SRA->RA_MUNICIP, "CC2_MUN",,, 3)
	Else
		cBairro  := SRA->RA_BAIRRO
		cMunicip := SRA->RA_MUNICIP 
		cEstado  := SRA->RA_ESTADO
	EndIf
	
	oPrint:StartPage()	//INICIA UMA NOVA PAGINA
	
	//TERMO DE RESCISAO DO CONTRATO DE TRABALHO
	oPrint:line( 020, 035, 020, nColMax) 					 	  					//Linha Horizontal
	
	If ! Empty(SRA->RA_CHIDENT) 
		oPrint:say (040, 0050, If(lGPEM40B, If(MV_PAR02 == 1, STR0002, STR0003), If(MV_PAR08 == 1, STR0002, STR0003)), oFont10n)		//"TERMO DE RESCISAO DO CONTRATO DE TRABALHO"
		oPrint:say (040, 1400, STR0058 + SRA->RA_CHIDENT, oFont09n)					// Chave Identif.: 
	Else 
		oPrint:say (040, 760, If(lGPEM40B, If(MV_PAR02 == 1, STR0002, STR0003), If(MV_PAR08 == 1, STR0002, STR0003)), oFont10n)		//"TERMO DE RESCISAO DO CONTRATO DE TRABALHO"
	Endif 
	
	oPrint:line(020, 035, 080, 035) 												//Linha Vertical
	oPrint:line(020, nColMax, 080, nColMax)											//Linha Vertical
	
	//IDENTIFICACAO DO EMPREGADOR
	oPrint:Box( 0080, 0035, 0475, nColMax )											//-- Box Identificacao do Trabalhador
	
	cString := UPPER(OemToAnsi(STR0061)) 											//-- "Identifica��o do Empregador" 
	
	//AJUSTA A STRING PARA SEREM  IMPRESSAS VERTICALMENTE
	cString1 := SUBSTR(cString, 1, at(" ", cString ))
	cString  := Right(cString, len(cString) - len(cString1))
	cString2 := SUBSTR(cString, 1, at(" ", cString ))
	cString3 := Right(cString, len(cString) - len(cString2))
	AADD(aString, alltrim(cString1))
	AADD(aString, alltrim(cString2))
	AADD(aString, alltrim(cString3))
	
	//EFETUA A IMPRESSAO DO TEXTO NA VERTICAL
	fImpVertical(aString, 90 ,50, 13)
	
	oPrint:line(210, 170, 210, nColMax) 												//Linha Horizontal
	oPrint:line(080, 900, 210, 900 )													//Linha Vertical Meio
	oPrint:line(080, 1900, 210, 1900)													//Linha Vertical Meio
	oPrint:say (0090, 0220, STR0056, oFont09)											//"|01- CNPJ: 	
	oPrint:say (0090, 0920, STR0001, oFont09)											//"##|02- Razao Social / Nome:"
	oPrint:say (0090, 1950, STR0055, oFont09) 											//"##" Filial: "	
	
	
	oPrint:say (170, 235, SUBSTR(If( Len(aInfo) >= 27 .And. !Empty( aInfo[27] )  .And. aInfo[28] == 1, aInfo[27], aInfo[8] ) + Space(20), 1, 20), oFont10 ) 				//"|01- CNPJ: 
	oPrint:say (170, 935, aInfo[3], oFont10 )						   					//"##|02- Razao Social / Nome:"
	oPrint:say (170, 2000, SRA->RA_Filial, oFont10 ) 									//"##" Filial: "	
	
	oPrint:line(340, 850 , 475, 850 )													//Linha Vertical Meio
	oPrint:line(340, 1150, 475, 1150)													//Linha Vertical Meio
	oPrint:line(340, 1500, 475, 1500)													//Linha Vertical Meio	
	oPrint:line(340, 1750, 475, 1750)													//Linha Vertical Meio
	oPrint:line(080, 170, 475, 0170)													//Linha Vertical Meio
	
	oPrint:say (230, 220, "03 " + STR0011, oFont09)  									//"|03 Endereco   : "
	oPrint:say (230, 1820, "04 " + STR0014, oFont09)	  						 		//"|04 Bairro : "
	
	oPrint:say (300,235 ,aInfo[4], oFont09)				 	  							//"|03 Endereco   : "
	oPrint:say (300,920 ,aInfo[14], oFont09)				   	   						//"|03 Complemento
	oPrint:say (300,1835,aInfo[13], oFont09)	   										//"|04 Bairro : "
	
	oPrint:line(340,170 ,340,nColMax) 					 	  				 			//Linha Horizontal
	oPrint:line(210,1805,340,1805)														//Linha Vertical Meio	
	
	oPrint:say (360,220 ,"05 "+STR0015, oFont09)										//"|05 Munic.: "
	oPrint:say (360,870 ,"06 "+STR0016, oFont09)										//"|06 UF : "
	oPrint:say (360,1170,"07 "+STR0013, oFont09)								   		//"|07 Cep: "
	oPrint:say (360,1520,"08 "+STR0017, oFont09)										//"|08 CNAE " 
	oPrint:say (360,1770,"09 "+STR0004, oFont09)										//"|09 CNPJ/CEI Tomador/Obra: "
	
	oPrint:say (430,230 ,aInfo[5] , oFont09)									   		//"|05 Munic.: "
	oPrint:say (430,885 ,aInfo[6] , oFont09)									   		//"|06 UF : "
	oPrint:say (430,1185,aInfo[7] , oFont09)									  		//"|07 Cep: "
	oPrint:say (430,1535,aInfo[16], oFont09)									  		//"|08 CNAE"
	oPrint:say (430,1785,Substr(fDesc("SI3",SRA->RA_CC,"I3_CEI")+Space(5),1,15), oFont09)//"|09 CNPJ/CEI Tomador/Obra: "
	
	//IDENTIFICACAO DO TRABALHADOR
	
	oPrint:Box(480, 035,890, nColMax ) 													//Box Identificacao do Trabalhador 
	
	cString := UPPER(OemToAnsi(STR0062)) 						   						//"Identifica��o do TRABALHADOR" 
	
	//AJUSTA A STRING PARA SEREM IMPRESSAS VERTICALMENTE
	aString	 := {}
	cString1 := SUBSTR(cString,1,at(" ",cString ))
	cString  := Right(cString, len(cString) - len(cString1) ) 
	cString2 := SUBSTR(cString,1,at(" ",cString ))
	cString3 := Right(cString, len(cString) - len(cString2) ) 
	AADD(aString,alltrim(cString1) ) 
	AADD(aString,alltrim(cString2) )
	AADD(aString,alltrim(cString3) ) 
	
	//EFETUA A IMPRESSAO DO TEXTO NA VERTICAL
	fImpVertical(aString, 495 ,50, 13)
	
	oPrint:line(790,0770,890,0770)											//Linha Vertical Meio	
	oPrint:line(790,1390,890,1390)											//Linha Vertical Meio	
	oPrint:line(480,0170,890,0170)				   							//Linha Vertical Meio	
	
	oPrint:say (480,220 ,STR0025, oFont09) 		 							//"10 PIS/PASEP:" 
	oPrint:say (480,525 ,STR0023, oFont09)								   	//"11 NOME:"
	oPrint:say (480,1880,"Matricula", oFont09)								//"MATRICULA:"
	
	oPrint:say (550,235 ,SRA->RA_PIS,oFont10) 								//PIS
	
	If !Empty(SRA->RA_NOMECMP)
		oPrint:say (550,525 ,Subs(SRA->RA_NOMECMP+Space(60),1,60),oFont10)	//NOME
	Else
		oPrint:say (550,525 ,Subs(SRA->RA_NOME+Space(30),1,30),oFont10) 	//NOME
	EndIf	
	
	oPrint:say (550,1880,SRA->RA_MAT,oFont10)								//MATRICULA
	
	oPrint:line(590 ,170 ,590,nColMax) 					 	  				//Linha Horizontal
	oPrint:line(480,505 ,590,505 )											//Linha Vertical Meio	
	oPrint:line(480,1855,590,1855)											//Linha Vertical Meio	
	
	oPrint:say (605,220 ,"12 "+STR0011, oFont09)  							//"|03 Endereco   : "
	oPrint:say (605,1820,"13 "+STR0014, oFont09)	  						 	//"|04 Bairro : "
	
	If !Empty(SRA->RA_NUMENDE)
		oPrint:say (650,235 ,Alltrim(SRA->RA_ENDEREC)+', '+SRA->RA_NUMENDE, oFont09) // "|03 Endereco + N. Endere�o   : "
	Else
		oPrint:say (650,235 ,SRA->RA_ENDEREC, oFont09)				 	  		//"|03 Endereco   : "
	EndIf
	
	If cPaisLoc <> "EQU"
		oPrint:say (650,920 ,SRA->RA_COMPLEM, oFont09)				   	 	//"|03 Complemento
	Endif
	oPrint:say (650,1835,SRA->RA_BAIRRO, oFont09)	   						//"|04 Bairro : "
	
	oPrint:line(690 ,170 ,690,nColMax) 					 	  				//Linha Horizontal
	oPrint:line(590,1805,690,1805)											//Linha Vertical Meio	
	
	oPrint:say (690,220 ,"14 "+STR0015, oFont09)								//"|05 Munic.: "
	oPrint:say (690,870 ,"15 "+STR0016, oFont09)								//"|06 UF : "
	oPrint:say (690,1170,"16 "+STR0013, oFont09)								//"|07 Cep: "
	oPrint:say (690,1520,"17 "+STR0024, oFont09)								//"|08 CNAE"
	
	oPrint:say (750,230 ,SRA->RA_MUNICIP, oFont09)							//"|05 Munic.: " 
	oPrint:say (750,890 ,SRA->RA_ESTADO , oFont09)							//"|06 UF : "
	oPrint:say (750,1185,SRA->RA_CEP , oFont09)								//"|07 Cep: "
	oPrint:say (750,1535,SRA->RA_NUMCP+"- "+SRA->RA_SERCP+"/"+SRA->RA_UFCP, oFont09)									  		//"|08 CNAE"
	
	oPrint:line(790,170 ,790,nColMax) 					 	  				//Linha Horizontal 
	oPrint:line(690,850 ,790,850 )											//Linha Vertical Meio	
	oPrint:line(690,1150,790,1150)											//Linha Vertical Meio	
	oPrint:line(690,1500,790,1500)											//Linha Vertical Meio	
	
	oPrint:say (805,230 , STR0012, oFont09)	   						 		//18 CPF:"
	oPrint:say (805,780 , STR0027, oFont09)	   	   					  		//19 Nasc.:"
	oPrint:say (805,1400, STR0007, oFont09)							  		//20 Nome da Mae"
	
	oPrint:say (850,250 , SRA->RA_CIC, oFont09)		 				 	 	//18 CPF:"
	oPrint:say (850,880 , DtoC(SRA->RA_NASC), oFont09)				   		//19 Nasc.:"
	oPrint:say (850,1420, SUBSTR(SRA->RA_MAE+Space(30),1,40), oFont09)		//20 Nome da Mae"  
	
	//DADOS DO CONTRATO
	oPrint:Box(895,035,1165,nColMax) 					 					//Linha Horizontal
	oPrint:line(0895,170 ,1165,0170)										//Linha Vertical Meio
	oPrint:line(900,0790 ,1030,790 )										//Linha Vertical Meio	
	oPrint:line(900,1300,1030,1300)											//Linha Vertical Meio	
	oPrint:line(900,1800,1030,1800)											//Linha Vertical Meio
	
	cString := UPPER(OemToAnsi(STR0063))						   			//DADOS DO CONTRATO
	
	//AJUSTA A STRING PARA SEREM  IMPRESSAS VERTICALMENTE
	aString	 := {}
	cString1 := SUBSTR(cString,1,at(" ",cString ))
	cString  := Right(cString, len(cString) - len(cString1) ) 
	cString2 := SUBSTR(cString,1,at(" ",cString ))
	cString3 := Right(cString, len(cString) - len(cString2) ) 
	AADD(aString,alltrim(cString1 ) )
	AADD(aString,alltrim(cString2 ) ) 
	AADD(aString,alltrim(cString3 ) ) 
	
	//EFETUA A IMPRESSAO DO TEXTO NA VERTICAL
	fImpVertical(aString, 900 ,50, 09)
	
	oPrint:say (910,220 , STR0009, oFont09)									//21 Remuneracao p/ fins rescisorios
	oPrint:say (910,800 , STR0010, oFont09)		  							//22 Admis:"
	oPrint:say (910,1350, STR0018, oFont09)		   							//23 Data do Aviso Previo"
	oPrint:say (910,1850, STR0030, oFont09)		 							//24 Data do afastamento:
	
	If nTipSal == 1 // Sal�rio incorporado
		nPenunSal := PenunSal(SRA->RA_ADMISSA, SRG->RG_DATADEM, cVerbas_Aux, acodfol[318, 1])
		nPenunSal := If(Empty(nPenunSal), SRG->RG_SALMES, nPenunSal)
	Else
		nPenunSal := SRG->RG_SALMES
	EndIF
	
	oPrint:say (990,250 , Transform(nPenunSal, "@E 999,999,999.99"), oFont09)		//21 Remuneracao p/ fins rescisorios
	
	oPrint:say (995,950 , DtoC(SRA->RA_ADMISSA), oFont09)			   		//22 Admis:"
	oPrint:say (995,1450, DtoC(SRG->RG_DTAVISO), oFont09)			   		//23 Data do Aviso Previo"
	oPrint:say (995,1950, DtoC(SRG->RG_DATADEM), oFont09)			   		//24 Data do afastamento: 
	
	oPrint:line(1030,170 ,1030,2350) 										//Linha Horizontal
	oPrint:line(1030,950 ,1165,0950)										//Linha Vertical Meio
	oPrint:line(1030,1400,1165,1400)										//Linha Vertical Meio	
	oPrint:line(1030,1730,1165,1730)										//Linha Vertical Meio	
	
	oPrint:say (1045,0220, STR0034, oFont09)	  				   	 		//25 Causa do Afastamento :"    
	oPrint:say (1045,1000, STR0035, oFont09)						 		//26 Cod. afastamento:"		
	oPrint:say (1045,1450, STR0033, oFont09)			   	   		 		//27 Pens.Alim.:"
	oPrint:say (1045,1750, STR0036, oFont09)			 			   		//28 Categoria do trabalhador"
	
	oPrint:say (1100,230 , cCodR+" - "+ SubStr(cCausa+Space(30),1,30), oFont09)	  		//25 Causa do Afastamento :"   
	
	//CODIGOS DE SAQUE VALIDOS SEGUNDO O CALENDARIO DE OBRIGACOES E TABELAS PRATICAS DO IOB DE OUT/99 PAGINAS 62 A 68
	cCodSaqIOB := "01_02_03_04_05_06_07_10_23_26_27_50_70_80_81_82_86_87_88_91_92_93_94_95" 
	//SE O CODIGO NAO FOR VALIDO NAO IMPRIME A GUIA DE RESCISAO
	IF !(StrZero(Val(cCodSaq),2) $ cCodSaqIOB)  //IMPRIME NAO SE CODIGO NAO FOR DE SAQUE
		cCodSaq := "NAO"
	EndIF
	
	oPrint:say (1100,1050, cCodSaq, oFont09)						  		//--26 Cod. afastamento:"		
	oPrint:say (1100,1500, Transform(nPerPensa,"999.99"), oFont09)  		//--27 Pens.Alim.:"
	oPrint:say (1100,2000, cCateg , oFont09)					   			//--28 Categoria do trabalhador"
	
	//DISCRIMINACAO DAS VERBAS RESCISORIAS
	oPrint:Box(1175, 035, 2090, nColMax )
	
	oPrint:say (1190,0800,oemtoansi(STR0059), oFont09n)			//-- Proventos
	oPrint:say (1190,1620,oemtoansi(STR0060), oFont09n)			//-- Descontos 
	oPrint:line(1230,0170,1230,nColMax) 						//-- Linha Horizontal Proventos/Descontos
	oPrint:line(1175,0170,2000,170)								//-- Linha Vertical Meio 
	oPrint:line(1230,0880,2000,880) 							//-- Linha Vertical Meio 
	oPrint:line(1175,1600,2000,1600)							//-- Linha Vertical Meio 
	
	cString := UPPER(OemToAnsi(STR0064)) 						//--DISCRIMINACAO DAS VERBAS RESCISORIAS
	
	//AJUSTA A STRING PARA SEREM  IMPRESSAS VERTICALMENTE
	aString	 := {}
	cString1 := SUBSTR(cString,1,at(" ",cString ))
	cString  := Right(cString, len(cString) - len(cString1) ) 
	cString2 := SUBSTR(cString,1,at(" ",cString ))
	cString1 += cString2 
	cString2 := Right(cString, len(cString) - len(cString2) )
	
	AADD(aString,alltrim(cString1 ) )
	AADD(aString,alltrim(cString2 ) ) 
	
	//EFETUA A IMPRESSAO DO TEXTO NA VERTICAL
	fImpVertical(aString, 1200 ,50, 25)
	
	nPos	:= 1260

Return Nil

/*/{Protheus.doc} fRodape
Impress�o do Rodap� da Rescis�o (Gr�fico)
@author Microsiga
@since 04/11/2002
/*/
Static Function fRodape()

	Local cOrgao	:=	space(155)
	Local cLinha1	:=	space(24)
	Local cLinha2	:=	space(63)
	Local cLinha3	:=	space(63)
	
	//TOTAIS DAS VERBAS RESCISORIAS
	oPrint:Line(2000, 0035 , 2000 , nColMax)						//Linha Horizontal dos Totais das Verbas
	If Len(aPdd) > Len(aPdv) 
		If nImprime < nTot											//Descontos 
			oPrint:say(2040, 1900, oemtoAnsi(STR0057), oFont09n ) 	//" Continua ... "
		Else
			oPrint:say (2040, 0150, STR0038, oFont09n)											//"|30-TOTAL BRUTO"
	        oPrint:say (2040, 0550, Transform(nProv, "@E 999,999,999.99"), oFont09n)
			oPrint:say (2040, 0900, STR0039, oFont09n)											//"|TOTAL DESCONTOS "
			oPrint:say (2040, 1300, Transform(nDesc, "@E 999,999,999.99"), oFont09n)	
			oPrint:say (2040, 1620, STR0040, oFont09n)											//"|LIQUIDO A RECEBER "
			oPrint:say (2040, 2050, Transform(nProv - nDesc, "@E 999,999,999.99"), oFont09n)
		Endif
	Else
		If ( nImpre < nTot )											//Proventos 
			oPrint:say(2040, 1900, oemtoAnsi(STR0057), oFont09n ) 		//" Continua ... "
		Else
			oPrint:say(2040, 0150, STR0038, oFont09n)											//"|30-TOTAL BRUTO"
			oPrint:say(2040, 0550, Transform(nProv, "@E 999,999,999.99"), oFont09n)
			oPrint:say(2040, 0900, STR0039, oFont09n)											//"|TOTAL DESCONTOS "
			oPrint:say(2040, 1300, Transform(nDesc, "@E 999,999,999.99"), oFont09n)	
			oPrint:say(2040, 1620, STR0040, oFont09n)											//"|LIQUIDO A RECEBER "
			oPrint:say(2040, 2050, Transform(nProv - nDesc, "@E 999,999,999.99"), oFont09n)
		Endif	
	Endif 
	
	//FORMALIZACAO DA RESCISAO
	oPrint:Box(2100, 035, nLinMax, nColMax )					//-- Box Formalizacao da Rescisao 
	
	cString := UPPER(OemToAnsi(STR0065)) 						   		//--DISCRIMINACAO DAS VERBAS RESCISORIAS
	
	//AJUSTA A STRING PARA SEREM IMPRESSAS VERTICALMENTE
	aString	 := {}
	cString1 := SUBSTR(cString, 1, at(" ", cString ))
	cString  := Right(cString, len(cString) - len(cString1) ) 
	cString2 := SUBSTR(cString, 1, at(" ", cString ))
	cString1 += cString2 
	cString2 := Right(cString, len(cString) - len(cString2) )
	
	AADD(aString, alltrim(cString1 ) )
	AADD(aString, alltrim(cString2 ) ) 
	
	//EFETUA A IMPRESSAO DO TEXTO NA VERTICAL
	fImpVertical(aString, 2140,50, 25)
	
	oPrint:say (2120, 190, STR0042, oFont08)	  										//"56 Local e data do Recebimento"
	
	oPrint:say (2120, 1405, STR0044, oFont08)											//"57 Carimbo e assinatura do empregador ou preposto"
	
	If (lGPEM40B .And. ! Empty(MV_PAR16 + MV_PAR17)) .Or. ( ! lGPEM40B .And. ! Empty(MV_PAR22 + MV_PAR23))
		If lGPEM40B
			oPrint:say(2163, 1405, "R.G.: " + MV_PAR16 + " - " + MV_PAR17, oFont08)			//"RG - Nome do empregador
		Else
			oPrint:say(2163, 1405, "R.G.: " + MV_PAR22 + " - " + MV_PAR23, oFont08)			//"RG - Nome do empregador
		EndIf
	Endif
	
	oPrint:line(2220, 170, 2220, nColMax) 												//Linha Horizontal
	
	oPrint:say (2230, 190, STR0043, oFont08)	  										//"58 Assinatura do trabalhador"
	oPrint:say (2230, 1405, STR0045, oFont08) 											//"59 Assinatura Responsavel legal"
	oPrint:line(2330, 170, 2330, 2350) 													//Linha Horizontal
	
	oPrint:say (2340, 190 , STR0046, oFont08)	   										//"60 HOMOLOGACAO"
	oPrint:say (2340, 1405, STR0047, oFont08)	 										//"61 Digital do trabalhador  
	oPrint:say (2340, 1905, STR0048, oFont08)	   										//"62 Digital do responsavel"	
	oPrint:say (2370, 1905, STR0049, oFont08)	   										//"legal"	
	oPrint:say (2370, 190, STR0050, oFont08)	  										//"Foi prestada, gratuitamente, assistencia ao trabalhador, nos   "
	oPrint:say (2400, 190, STR0051, oFont08)	   										//"termos do art. 477,Inc.1. da CLT, sendo comprovado, neste ato  "
	oPrint:say (2430, 190, STR0052, oFont08)	   										//"o efetivo pagamento das verbas rescisorias acima especificadas."
	oPrint:say (2530, 190, STR0031, oFont09)	   										//__________________________________
	If nImprDtHom == 1
		oPrint:say (2560, 190, Rtrim(aInfo[5]) + " - "+ Dtoc(SRG->RG_DATAHOM), oFont09)
	Else 
		oPrint:say (2560, 190 , STR0029, oFont08)	   										//Local e Data	
	Endif
	oPrint:say (2630, 190 , STR0031, oFont09)	   										//__________________________________
	oPrint:say (2660, 190 , STR0028, oFont08)	   										//Carimbo e assinatura do assistente
	oPrint:say (2660, 1405, STR0053, oFont08)	   										//64 Recepcao pelo Banco( data e carimbo)
	oPrint:line(2100, 170 , nLinMax, 170)												//Linha Vertical Inicial 
	oPrint:line(2100, 1390, nLinMax, 1390)												//Linha Vertical Meio
	oPrint:line(2330, 1895, 2660, 1895)													//Linha Vertical Meio	
	oPrint:line(2660, 1390, 2660, 2350) 												//Meia Linha Horizontal
	oPrint:line(2700, 170, 2700, 1390) 													//Meia Linha Horizontal
	oPrint:say (2700, 190, STR0054, oFont08)	   										//63 Identificacao d
	
	
	If (lGPEM40B .And. MV_PAR18 == 1) .Or. (! lGPEM40B .And. MV_PAR24 == 1)
		cOrgao	:=	fGetOrgao(SRA->RA_SINDICA, xFilial("RCE"))
	ElseIf (lGPEM40B .And. MV_PAR18 == 2) .Or. (! lGPEM40B .And. MV_PAR24 == 2)
		cOrgao	:=	fGetOrgao(If(lGPEM040B, MV_PAR19, MV_PAR25), xFilial("RCE"))
	Else
		cOrgao	:=	""
	EndIf
	cLinha1		:=	Memoline(cOrgao, 70, 1, , .T.)
	cOrgao		:=	right(cOrgao, len(cOrgao)-len(AllTrim(cLinha1)))
	cLinha2		:=	Memoline(AllTrim(cOrgao), 70, 1, , .T.)
	cLinha3		:=	Memoline(AllTrim(cOrgao), 70, 2, , .T.)
	
	oPrint:say (2730, 0190, cLinha1, oFont08)
	oPrint:say (2760, 0190, cLinha2, oFont08)
	oPrint:say (2790, 0190, cLinha3, oFont08)
	
	oPrint:say (2940, 760 ,STR0019, oFont09)											//" A ASSISTENCIA NO ATO DE RESCISAO CONTRATUAL E GRATUITA" #  (LINHA 63)
	
	
	If lImpInfExt  // Exibe a impressao da funcao / centro de custo e banco/agencia/conta do ex.funcionario.
	
		cMsgRoda	:=  STR0066 + SRA->RA_CODFUNC + "-" + fDesc("SRJ", SRA->RA_CODFUNC, "RJ_DESC") + " | " + STR0067 + " " + SRA->RA_CC + "-" + ;
						fDesc("SI3", SRA->RA_CC, "I3_DESC", , SRA->RA_FILIAL) + " | " + STR0068 + " " + SRA->RA_BCDEPSA + " " + STR0069 + SRA->RA_CTDEPSA
	
		oPrint:say (3015, 0190, cMsgRoda, oFont07)												//" A ASSISTENCIA NO ATO DE RESCISAO CONTRATUAL E GRATUITA" #  (LINHA 63)
	EndIf
	
	//FIM DO RELATORIO
	oPrint:EndPage()
	CONTFL := 1

Return

/*/{Protheus.doc} fCalnTot
fCalnTot
@author Microsiga
@since 04/11/2002
/*/
Static Function  fCalnTot()

	Local nTotal	:= Max( Len(aPdv), Len(aPdd) )
	Local nAuxTot	:= 0 
	
	If (nTotal <= ( 2 * nNumMax ) .and. nTotal <> Len(aPdd))
		nAuxTot	:= nNumMax
		IF nAuxTot < Len(aPdd)
			nAuxTot	:=	Len(aPdd)
		Endif
	Elseif nTotal = Len(aPdv) .and. nTotal > ( 2 * nNumMax )
		nAuxTot := ( 2 * nNumMax ) 
	ElseIf nTotal = Len(aPdd) 
		nAuxTot := nTotal 
	Endif 

Return(If( nTotal < nAuxTot, nTotal, nAuxTot ))

/*/{Protheus.doc} fImpVertical
Efetua a impressao das colunas verticais
@author Microsiga
@since 10/03/2006
@version 1.0
/*/
Static Function fImpVertical( aString, nLinIni, nColIni, nMax)
	
	Local nX			:= 0 
	Local nY			:= 0 
	Local nColVert 		:= 0 										//-- Identifica coluna impressa 
	Local nTam			:= nLinIni + (nMax * 30 )					//-- Tamanho da Coluna em pixel 
	Local nLinI			:= nLinIni 
	Local nTamTexto		:= 0 										//-- Tamanho do Texto em  caracter
	Local nTamString	:= 0 										//-- Tamanho do Texto em  Pixel
	
	For Nx:= 1 to Len(aString) 
		nTamTexto	:= Min(Len(aString[nX]),nMax)					//-- n�o permite a impressao de textos maiores que o tamanho disponivel
		nTamString	:= (len(aString[nX]) * 30) 
		nColVert++
		nLinI		:= nLinIni 		
		For nY:= 1 to nTamTexto
			nColIni 	:= If(nColVert=1, 50, If(nColVert = 2, 90, 130 ))			//-- coluna a ser impressa 
			If nY = 1
				nLinI	:= nLinI + Max( ( (nTam - nLinIni)- nTamString ) / 2 ,0) 
			Endif		
			oPrint:say (nLinI, nColIni, substr(aString[nX],nY,1) , oFont06)
			nLinI	+= 30
		Next nY 
	Next nX

Return

/*/{Protheus.doc} PenunSal
Obtem o penultimo salario do funcionario antes da demissao.
@author Mauricio MR
@since 16/02/11
@param cVerbSal, characters, C�digo da verba de sal�rio
/*/
Static Function PenunSal(dAdmissao, dDemissao, cVerbas, cVerbSal)
	
	Local nEpoch		:= Set(_SET_EPOCH)	//OBTEM A CONFIGURACAO DE SECULO CORRENTE
	Local aArea			:= GetArea()
	Local aSRCArea		:= SRC->(GetArea())
	Local aPerAtual		:= {}
	//DATA DO PENULTIMO SALARIO
	Local dDTPenSal 
	Local dDataDe
	Local dDataAte
	Local nValPenSal
	Local cFilMat		:= SRA->(RA_FILIAL+RA_MAT)
	
	DEFAULT dAdmissao	:= SRA->RA_ADMISSA	
	DEFAULT dDemissao	:= SRG->RG_DATADEM  
	DEFAULT cVerbas		:= ''  
	DEFAULT cVerbSal	:= acodfol[318, 1]
	
	fGetPerAtual(@aPerAtual, xFilial("RCH", SRA->RA_FILIAL), SRA->RA_PROCES, fGetCalcRot('1'))
	If ! Empty(aPerAtual)
		dDataDe  := aPerAtual[1, 6]
		dDataAte := aPerAtual[1, 7]
	EndIf
	
	Set(_SET_EPOCH, 1920)	//ALTERA O SET EPOCH PARA 1920
	
	dDTPenSal := If(Month(dDemissao) - 1 != 0, CtoD( '01/' + StrZero(Month(dDemissao) - 1, 2) + '/' + Right(StrZero(Year(dDemissao), 4), 2)), CtoD('01/12/' + Right(StrZero(Year(dDemissao) - 1, 4), 2)) )
	
	If MesAno(dDtPenSal) < MesAno(dAdmissao)
		dDTPenSal 	:= CTOD("  /  /  ")
		nValPenSal 	:= 0.00
	Endif
	//PENULTIMO
	If ! Empty(dDTPenSal)
		nValPenSal := fBuscaAcm(cVerbas + cVerbSal, , dDTPenSal, dDTPenSal, "V")	//SALARIO DO MES + VERBAS QUE INCORPORARAM  AO SALARIO
		//PESQUISA NO MOVIMENTO MENSAL QUANDO O MES CORRENTE ESTIVER ABERTO
		//E NAO ENCONTRAR SALARIO NOS ACUMULADOS ANUAIS
		If nValPenSal == 0 .AND. MesAno(dDTPenSal) == MesAno(dDataDe)
			If SRC->(Dbseek(cFilMat))
				While ! SRC->(Eof()) .And. cFilMat == SRC->(RC_FILIAL + RC_MAT)
					If SRC->RC_PD $ cVerbas + cVerbSal
						nValPenSal += SRC->RC_VALOR
					Endif
					SRC->(dbskip())
				Enddo
			Endif
		Endif
	Endif
	
	//RESTAURA O SET EPOCH PADRAO
	Set(_SET_EPOCH, nEpoch)
	
	RestArea(aSRCArea)
	RestArea(aArea)

Return(nValPenSal)
