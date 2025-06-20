#INCLUDE "ctbr580.ch"
#Include "PROTHEUS.Ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ�
���Fun��o	 � Ctbr580	� Autor � Jos� Lucas	 		 � Data � 16.02.10 ��
��������������������������������������������������������������������������Ĵ�
���Descri��o � Demonstracao de Resultados                 			  	   ��
��������������������������������������������������������������������������Ĵ�
���Retorno	 � Nenhum       											   ��
��������������������������������������������������������������������������Ĵ�
���Parametros� Nenhum													   ��
���������������������������������������������������������������������������ٱ
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CtbR580()          

Private dFinalA
Private dFinal
Private nomeprog	:= "CTBR580"    
Private dPeriodo0

If TRepInUse() 
	CTBR580R4()
Else
	Help(" ",1,"CTBR580",,STR0020,1,0,,,,,,{STR0021}) //"Relat�rio dispon�vel apenas em TReport."###"Confira o par�mentro MV_TREPORT."
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR580R4  Autor � Jos� Lucas	 		 � Data � 16.02.10 ��
�������������������������������������������������������������������������Ĵ��
���Descri��o � Demostrativo de balancos patrimoniais - R4		          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR115R4												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR580R4()                           

PRIVATE cPerg := "CTR580"        

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������            
Pergunte( cPerg, .T. )

// faz a valida��o do livro
If ! VdSetOfBook( mv_par06 , .T. )
   //Return .F.
Endif

oReport := ReportDef()      

If VALTYPE( oReport ) == "O"
	oReport :PrintDialog()      
EndIf

oReport := nil

Return                                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef    Autor � Jos� Lucas	 		 � Data � 16.02.10 ��
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta funcao tem como objetivo definir as secoes, celulas,   ���
���          �totalizadores do relatorio que poderao ser configurados     ���
���          �pelo relatorio.                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������    
/*/          
Static Function ReportDef()     

Local aSetOfBook	:= CTBSetOf(mv_par06)
Local aCtbMoeda	:= {}
Local cDescMoeda 	:= ""
local aArea	   	:= GetArea()   
Local CREPORT		:= "CTBR580"
Local CTITULO		:= STR0001				// DEMONSTRATIVO DE GRUPO CONTABIL x CONTA
Local CDESC			:= OemToAnsi(STR0014) + ; 			//"Este programa ir� imprimir a Demonstra��o de Resultados, "
	   				   OemToAnsi(STR0015) 				//"de acordo com os par�metros informados pelo usu�rio."
Local aTamCta       := {30}	//TamSX3("CT1_CONTA")
Local aTamDesc      := TamSX3("CT1_DESC01")
Local aTamCCusto    := TamSX3("CTT_CUSTO")
Local aTamItem 	    := TamSX3("CTD_ITEM") 
Local aTamCLVL		:= TamSX3("CTH_CLVL")  
Local aTamVal		:= TamSX3("CT2_VALOR")
                 
aCtbMoeda := CtbMoeda(mv_par07, aSetOfBook[9])
cDescMoeda 	:= AllTrim(aCtbMoeda[3])

If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)	  	     �
//����������������������������������������������������������������
If !Empty(mv_par06)
	If !Ct040Valid(mv_par06)
		Return
	EndIf
EndIf		

If !Empty(aSetOfBook[10]) .And. Valtype(mv_par14)=="N" .And. mv_par14 == 1
	CTITULO := CTBNomeVis( aSetOfBook[5] )
EndIf


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
oReport	:= TReport():New( CREPORT,CTITULO,CPERG, { |oReport| ReportPrint( oReport ) }, CDESC ) 
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,ctitulo,,,,,oReport) } )                                        
oReport:ParamReadOnly()

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
                                                                      
If Empty(mv_par06)
	oSection1 := TRSection():New( oReport, STR0012, {"cArqTmp"},, .F., .F. )        //"Contas/Saldos"
	TRCell():New( oSection1, "CONTA"	,"",						/*Titulo*/,/*Picture*/,aTamCta[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	
	TRCell():New( oSection1, "DESCRICAO","",						/*Titulo*/,/*Picture*/,aTamDesc[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	
	TRCell():New( oSection1, "CUSTO"	,"",						/*Titulo*/,/*Picture*/,aTamCCusto[1]	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	
	TRCell():New( oSection1, "ITEM"		,"",						/*Titulo*/,/*Picture*/,aTamItem[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	
	TRCell():New( oSection1, "CLVL"		,"",						/*Titulo*/,/*Picture*/,aTamCLVL[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	
	TRCell():New( oSection1, "SALDOATU"	,"",						/*Titulo*/,/*Picture*/,aTamVal[1]+2		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
	TRCell():New( oSection1, "SALDOANT"	,"",						/*Titulo*/,/*Picture*/,aTamVal[1]+2		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
	oSection1:SetHeaderPage()
	oSection1:SetTotalInLine(.F.) 
Else
	oSection1 := TRSection():New( oReport, STR0012, {"cArqTmp"},, .F., .F. )        //"Contas/Saldos"
	TRCell():New( oSection1, "DESCRICAO","",						/*Titulo*/,/*Picture*/,aTamDesc[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	
	TRCell():New( oSection1, "SALDOATU"	,"",						/*Titulo*/,/*Picture*/,aTamVal[1]+2		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
	TRCell():New( oSection1, "SALDOANT"	,"",						/*Titulo*/,/*Picture*/,aTamVal[1]+2		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
	oSection1:SetTotalInLine(.F.) 
EndIf

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint Autor � Jos� Lucas	 		 � Data � 16.02.10 ��
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime o relatorio definido pelo usuario de acordo com as  ���
���          �secoes/celulas criadas na funcao ReportDef definida acima.  ���
���          �Nesta funcao deve ser criada a query das secoes se SQL ou   ���
���          �definido o relacionamento e filtros das tabelas em CodeBase.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportPrint(oReport)                                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPO1: Objeto do relat�rio                                  ���
��������������������������������������������������������������������������ٱ�            

�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport )    

Local oSection1 	:= oReport:Section(1) 
Local aSetOfBook	:= CTBSetOf(mv_par06)
Local aCtbMoeda	:= {}
Local lin 			:= 3001
Local cArqTmp
Local cTpValor		:= GetMV("MV_TPVALOR")
Local cPicture
Local cDescMoeda
Local lFirstPage	:= .T.               
Local nTraco		:= 0
Local nSaldo        := 0
Local nTamLin		:= 2350
Local aPosCol		:= { 1740, 2045 }
Local nPosCol		:= 0
Local cArqTrm		:= ""
Local lVlrZerado	:= If(MV_PAR11 == 1,.T.,.F.)
Local lMovPeriodo   := If(MV_PAR12 == 1,.T.,.F.)
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local cMoedaDesc	:= MV_PAR13
Local lPeriodoAnt 	:= (mv_par08 == 1)
Local cContaIni     := mv_par02
Local cContaFim     := mv_par03
Local cCCustoIni    := Space(TamSX3("CTT_CUSTO")[1])
Local cCCustoFim    := Repl("Z",TamSX3("CTT_CUSTO")[1])
Local cItemIni   	:= Space(TamSX3("CTD_ITEM")[1])
Local cItemFim    	:= Repl("Z",TamSX3("CTD_ITEM")[1])
Local cClVlIni      := Space(TamSX3("CTH_CLVL")[1])
Local cClVlFim	    := Repl("Z",TamSX3("CTH_CLVL")[1])
Local nSaldoAtu 	:= 0.00
Local nSaldoAnt 	:= 0.00                             
Local nTotGrpAtu 	:= 0.00              
Local nTotGrpAnt 	:= 0.00
Local nTGeGrpAtu 	:= 0.00         
Local nTGeGrpAnt 	:= 0.00
Local lTotGrupo     := .T.
Local lTotGeral     := .F.             
Local cAliasCTR     := "CTR"
	
aCtbMoeda := CtbMoeda(mv_par07, aSetOfBook[9])
If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

cDescMoeda 	:= AllTrim(aCtbMoeda[3])
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par07)
cPicture 	:= aSetOfBook[4]

If ! Empty(cPicture) .And. Len(Trans(0, cPicture)) > 17
	cPicture := ""
Endif

dFinal		:= mv_par01
dFinalA		:= dFinal
nDivide     := 1

//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao					     �
//����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	oMeter,;
						oText,;
						oDlg,;
						@lEnd,;
						@cArqTmp,;
						dFinalA+1,;
						dFinal,;
						"CT7",;
						"",;
						cContaIni,; 
						cContaFim,;
						cCCustoIni,;
						cCCustoFim,;
						cItemIni,; 
						cItemFim,;
						cClVlIni,;
						cClVlFim,;
						mv_par07,;
						MV_PAR09,; 
						aSetOfBook,; 
						Space(2),;  
						Space(20),; 
						Repl("Z", 20),; 
						Space(30) ,,,,,;
						.F.,,;
						nDivide,;                                                                                        						
						lVlrZerado,,,,,,,,,,,,,,,,,,,,,,,,,;                                 						
						cMoedaDesc,;
						lMovPeriodo)},STR0006, STR0001) //"Criando Arquivo Temporario..."###"DEMONSTRATIVO DE GRUPO CONTABIL X CONTA"
						
dbSelectArea("cArqTmp")       

If Empty(mv_par06)	//Imprime relat�rio independente da Vis�o

	cFiltroTmp1 := 'TIPOCONTA == "2" '
	cFiltroTmp1 += ' .And. GRUPO >= "'+mv_par04+'" .And. GRUPO <= "'+mv_par05+'"'

	cArqTmp1 := CriaTrab(, .F.)
	IndRegua("cArqTmp",cArqTmp1,"GRUPO+CONTA+CUSTO+ITEM+CLVL",,cFiltroTmp1,STR0022)  //"Selecionando Registros..."
                     
	nIndex := RetIndex("cArqTmp")
	dbSelectArea("cArqTmp")
	dbSetOrder(nIndex+1)
	dbGoTop()

	oReport:SetMeter( RecCount() )

	oReport:SetPageNumber(mv_par10) //mv_par07 - Pagina Inicial
                                      
	Do While !Eof() .And. !oReport:Cancel() //.And. Eval(bCond)
         
		If oReport:Cancel()
			Exit
		EndIf	
                                     
		If Empty(cArqTmp->GRUPO) .OR. cArqTmp->TIPOCONTA == "1"
			cArqTmp->(DbSkip())
			Loop
		EndIf
  
		(cAliasCTR)->(dbSetOrder(1))
		(cAliasCTR)->(dbSeek(xFilial("CTR")+cArqTmp->GRUPO))
				
    	oReport:IncMeter() 
    
		TRPosition():New(oSection1,"CT1",1,{|| xFilial("CT1") + cArqTmp->CONTA })   
		TRPosition():New(oSection1,"CTT",1,{|| xFilial("CTT") + cArqTmp->CUSTO})
		TRPosition():New(oSection1,"CTD",1,{|| xFilial("CTD") + cArqTmp->ITEM})
		TRPosition():New(oSection1,"CTR",1,{|| xFilial("CTR") + cArqTmp->GRUPO})

		oSection1:Cell("CONTA"    ):SetBlock( { || cArqTmp->GRUPO } )		
		oSection1:Cell("DESCRICAO"):SetBlock( { || (cAliasCTR)->CTR_DESC } )
		oSection1:Cell("SALDOATU" ):SetBlock( { || Space(aTamVal[1]) } )	  
		oSection1:Cell("SALDOANT" ):SetBlock( { || Space(aTamVal[1]) } )

		oSection1:Init()
		oSection1:PrintLine()
		oSection1:Finish()

		cGrupo := cArqTmp->GRUPO
	
		Do While !Eof() .And. !oReport:Cancel() .And. cArqTmp->GRUPO == cGrupo

			oReport:IncMeter()

			If oReport:Cancel()
				Exit
			EndIf
		
			oSection1:Cell("CONTA"    ):SetBlock( { || cArqTmp->CONTA } )		
			oSection1:Cell("DESCRICAO"):SetBlock( { || Iif(cArqTmp->COLUNA<2,Iif(cArqTmp->TIPOCONTA="2",cArqTmp->DESCCTA,cArqTmp->DESCCTA),"") } )				
			oSection1:Cell("CUSTO"    ):SetBlock( { || cArqTmp->CUSTO } )
			oSection1:Cell("ITEM"     ):SetBlock( { || cArqTmp->ITEM } )
			oSection1:Cell("CLVL"     ):SetBlock( { || cArqTmp->CLVL } ) 
			oSection1:Cell("SALDOATU" ):SetBlock( { || ValorCTB( If(lMovPeriodo,cArqTmp->(SALDOATU-SALDOANT),cArqTmp->SALDOATU),,,aTamVal[1],nDecimais,.T.,cPicture,;
  	                                                 cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F. ) } )
			If lPeriodoAnt
				oSection1:Cell("SALDOANT" ):SetBlock( { || ValorCTB( If(lMovPeriodo,cArqTmp->MOVPERANT,cArqTmp->SALDOANT),,,aTamVal[1],nDecimais,.T.,cPicture,;
													 cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F. ) } )
			EndIf

			oSection1:Init()
			oSection1:PrintLine()
			oSection1:Finish()
		
	    	nSaldoAtu := R580Soma("1")      
    		nSaldoAnt := R580Soma("2")
                             
			nTotGrpAtu += nSaldoAtu	                                
			nTotGrpAnt += nSaldoAnt

			nTGeGrpAtu += nSaldoAtu              
			nTGeGrpAnt += nSaldoAnt
	
			cArqTmp->( dbskip()  )  
 		EndDo
 		
		// TOTALIZA O GRUPO	
		If lTotGrupo
			If ( cGrupo <> cArqTmp->GRUPO )

				oSection1:Cell("CONTA"):SetBlock( { || STR0018+" ("+AllTrim(cGrupo)+") " } ) //"TOTAL POR GRUPO"									
				oSection1:Cell("DESCRICAO"):SetBlock( { || Space(Len(cArqTmp->DESCCTA)) } )				
 				oSection1:Cell("SALDOATU" ):SetBlock( { || ValorCTB(nTotGrpAtu,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F. ) } )
				If lPeriodoAnt
					oSection1:Cell("SALDOANT"):SetBlock( { || ValorCTB(nTotGrpAnt,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F. ) } )
				EndIf
			
				oSection1:Init()
				oSection1:Printline()
				oSection1:Finish()
							
				nTotGrpAtu := 0	
				nTotGrpAnt := 0					
	   		EndIf		
		EndIf		   
	EndDo
            
Else				//Imprime relat�rio considerando a Vis�o selecionada.

	oReport:SetPageNumber(mv_par10) //mv_par07 - Pagina Inicial

	oSection1:Cell("SALDOATU" ):SetTitle(Dtoc(dFinal))
	If lPeriodoAnt
		oSection1:Cell("SALDOANT" ):SetTitle(Dtoc(dFinalA))
	Else
		oSection1:Cell("SALDOANT" ):Disable()
	EndIf

	oSection1:Cell("DESCRICAO"):SetBlock( { || Iif(cArqTmp->COLUNA<2,Iif(cArqTmp->TIPOCONTA="2",cArqTmp->DESCCTA,cArqTmp->DESCCTA),"") } )		

	If cArqTmp->IDENTIFI < "5"
		oSection1:Cell("SALDOATU" ):SetBlock( { || ValorCTB( If(lMovPeriodo,cArqTmp->(SALDOATU-SALDOANT),cArqTmp->SALDOATU),,,aTamVal[1],nDecimais,.T.,cPicture,;
    	                                                 cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F. ) } )

		If lPeriodoAnt
			oSection1:Cell("SALDOANT" ):SetBlock( { || ValorCTB( If(lMovPeriodo,cArqTmp->MOVPERANT,cArqTmp->SALDOANT),,,aTamVal[1],nDecimais,.T.,cPicture,;
															 cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F. ) } )
		EndIf
	EndIf

	oSection1:Print()

EndIf	   
DbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	

Return(.T.)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �CTR500ESP � Autor � Jos� Lucas	 		 � Data � 16.02.10 ��
�������������������������������������������������������������������������Ĵ��
���Descricao �Cabecalho Especifico do relatorio CTBR041.                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CTR500ESP(ParO1,ParC1)			                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpC1 = Descricao da moeda sendo impressa                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTR580Esp(oPrint,cDescMoeda,aPosCol,nTamLin)

Local cColuna  		:= "(Em " + cDescMoeda + ")"
Local aCabecalho    := { Dtoc(dFinal, "ddmmyyyy"), Dtoc(dFinalA, "ddmmyyyy") }
Local nPosCol

oPrint:Line(250,150,300,150)   	// vertical

oPrint:Say(260,195,cColuna,oArial10)

For nPosCol := 1 To Len(aCabecalho)
	oPrint:Say(260,aPosCol[nPosCol] + 30,aCabecalho[nPosCol],oArial10)
Next

oPrint:Line(250,nTamLin,300,nTamLin)   	// vertical

oPrint:Line(300,150,300,nTamLin)   	// horizontal

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �CTR580ATU � Autor � Jos� Lucas	 		� Data � 16.02.10 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Cabecalho para impressao apenas da coluna de Saldo Atual.   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CTR580ESP(ParO1,ParC1)			                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpC1 = Descricao da moeda sendo impressa                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTR580ATU(oPrint,cDescMoeda,aPosCol,nTamLin)

Local cColuna  		:= "(Em " + cDescMoeda + ")"
Local aCabecalho    := { Dtoc(dFinal, "ddmmyyyy") }
Local nPosCol       := 1

oPrint:Line(250,150,300,150)   	// vertical

oPrint:Say(260,195,cColuna,oArial10)

oPrint:Say(260,aPosCol[nPosCol+1] + 30,aCabecalho[nPosCol],oArial10)


oPrint:Line(250,nTamLin,300,nTamLin)   	// vertical

oPrint:Line(300,150,300,nTamLin)   	// horizontal

Return Nil  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �R580Soma	� Autor � Jos� Lucas	 		 � Data � 16.02.10 ��
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTBR580                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function R580Soma(cTipoSaldo)
Local nRetValor := 0               
If cTipoSaldo == "1"
	nRetValor := cArqTmp->SALDOATU
Else	                          
	nRetValor := cArqTmp->SALDOANT
EndIf	
Return nRetValor                                                                         
