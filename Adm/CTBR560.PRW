#Include "ctbr560.ch"
#Include "protheus.ch"

//--------------------------------------------------------------------------------------------------
//Criar no CTB.PRW a criacao da consulta padrao (SXB) chamada SX5SL
//--------------------------------------------------------------------------------------------------
//SX5SL - 1 - 01 - RE - SELECAO SALDOS CTB - SELECAO SALDOS CTB - SELECAO SALDOS CTB - SX5
//SX5SL - 2 - 01 - 01 -                    -                    -                    - CTR560SX5(1)
//SX5SL - 5 - 01 -    -                    -                    -                    - cRetSX5SL
//--------------------------------------------------------------------------------------------------

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ�
���Fun��o	 � Ctbr560	� Autor � Felipe Aurelio de Melo � Data � 25.09.08 ��
��������������������������������������������������������������������������Ĵ�
���Descri��o � DEMONSTRACAO DO FLUXO DE CAIXA                              ��
��������������������������������������������������������������������������Ĵ�
���Retorno	 � Nenhum                                                      ��
��������������������������������������������������������������������������Ĵ�
���Parametros� Nenhum                                                      ��
���������������������������������������������������������������������������ٱ
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CtbR560()

Local lRet        := .T.
Private cRetSX5SL := ""
Private cPerg     := "CTR560"
Private NomeProg  := "CTBR560"
Private wnRel     := "CTBR560"
Private dFinal    := StoD("")
Private dFinalA   := StoD("")
Private aSetOfBook:= {}
Private aCtbMoeda := {}
Private aSelFil		:= {}
Private cTitulo   := STR0001 //"DEMONSTRACAO DO FLUXO DE CAIXA"

// verifica existencia da consulta padrao SX5SL
If SXB->(!DbSeek("SX5SL"))
	Help(" ",1,"HELP","",STR0002,3,1)
	lRet := .F.
EndIf

//chama a tela de perguntas
If lRet .And. !Pergunte(cPerg,.T.)
	lRet := .F.
Else
	aSetOfBook:= CTBSetOf(mv_par02)
	aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
EndIf

// Faz a validacao das filiais
If lRet .And. mv_par23 == 1 .And. Len( aSelFil ) <= 0 
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf 
EndIf 

//faz a validacao do livro
If lRet .And. !VdSetOfBook(mv_par02,.T.)
	lRet := .F.
EndIf

If lRet .And. Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
	lRet := .F.
Endif

//Se passou pelas perguntas e validacoes chama funcao de impressao do relatorio
If lRet
	CTBR560R3()
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR560R3 � Autor� Felipe Aurelio de Melo� Data � 25.09.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � DEMONSTRACAO DO FLUXO DE CAIXA - R4                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR560R3                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CTBR560R3()

Local cDescMoeda  := AllTrim(aCtbMoeda[3])
Local lMovPeriodo := mv_par13 == 1
local aArea       := GetArea()
Local cDesc       := ""
Private m_pag     := mv_par07 // numera��o da pagina

cDesc += OemToAnsi( STR0003 )  			//"Este programa ir� imprimir a Demonstra��o do fluxo de caixa, "
cDesc += OemToAnsi( STR0004 )			//"de acordo com os par�metros informados pelo usu�rio."
cTitulo := If(!Empty(aSetOfBook[10]),aSetOfBook[10],cTitulo)                        //"Titulo definido SetOfBook"

If (mv_par22 == 1)
	cTitulo := CTBNomeVis( aSetOfBook[5] )
EndIf

If mv_par09 == 1
	// SE DEVE CONSIDERAR TODO O CALENDARIO
	CTG->(DbSeek(xFilial("CTG")+mv_par01))
	dbSelectArea("CTG")
	dbSetOrder(1)
	MsSeek(xFilial("CTG")+mv_par01,.T.)
	
	If Empty(mv_par08)
		While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
			dFinal	:= CTG->CTG_DTFIM
			CTG->(DbSkip())
		EndDo
	Else
		dFinal	:= mv_par08
	EndIf
	dFinalA   	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))
	mv_par01    := dFinal
Else
	// SE DEVE CONSIDERAR O PERIODO CONTABIL
	If Empty(mv_par08)
		MsgInfo( STR0005, STR0006 )//"� necess�rio informar a data de refer�ncia !"#"Parametro Considera igual a Periodo."
		Return .F.
	Endif
	dFinal := mv_par08
	
	CTG->(dbSetOrder(1))
	CTG->(DbSeek(xFilial("CTG")+mv_par01))
	While CTG->CTG_FILIAL == xFilial("CTG") .And. CTG->CTG_CALEND == mv_par01
		If dFinal >= CTG->CTG_DTINI .and. dFinal <= CTG->CTG_DTFIM
			dFinalA		:= CTG->CTG_DTINI
			If lMovPeriodo
				dFinalA		:= dFinalA - 1
			EndIf
			Exit
		Endif
		CTG->(DbSkip())
	EndDo
	
	If Empty(dFinalA)
		MsgInfo( STR0007, STR0008 )//"Data fora do calend�rio !"#"Data de refer�ncia."
		Return .F.
	Endif
EndIf

If lMovPeriodo
	dPeriodo0 := CtoD("01/01/"+Alltrim(Str(Year(dFinalA))))
EndIf

MsgRun(	STR0009,"",{|| CursorWait(), Ctr500Cfg(@cTitulo, "Ctr560Det", STR0001, .F.) ,CursorArrow()}) //"Gerando relatorio, aguarde..."##"DEMONSTRACAO DO FLUXO DE CAIXA"

//Limpa os arquivos tempor�rios 
CTBGerClean()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ctr560Det � Autor � Felipe Aurelio de Melo� Data � 25.09.08 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Detalhe do Relatorio                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctr560Det(ExpO1,ExpN1)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpN1 = Contador de paginas                                ���
���          � ParC1 = Titulo do relatorio                                ���
���          � ParC2 = Titulo da caixa do processo                        ���
���          � ParL1 = Indica se imprime em Paisagem (.T.) ou Retrato .F. ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctr560Det(oPrint,i,cTitulo,cProcesso,lLandScape)

Local cArqTmp
Local nTraco      	:= 0
Local nColuna     	:= 0
Local cCodVis     	:= Posicione("CTN",1, xFilial("CTN")+MV_PAR02,"CTN_PLAGER")
Local cDescCont   	:= ""
Local nBegin		:= 0
Local nLinha		:= 0
Local nPosCol		:= 0
Local lFirstPage	:= .T.
Local lin 			:= 3001
Local nTamLin		:= 2349
Local lMovPeriodo 	:= mv_par13 == 1
Local cTpValor		:= GetMV("MV_TPVALOR")
Local cDescMoeda  	:= AllTrim(aCtbMoeda[3])
Local lImpTrmAux	:= Iif(mv_par10 == 1,.T.,.F.)
Local nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)
Local cMoedaDesc  	:= IIf( Empty(mv_par14),mv_par03,mv_par14)
Local cPicture 		:= IIf(!Empty(aSetOfBook[4]) .And. Len(Trans(0, aSetOfBook[4])) > 17,"",aSetOfBook[4])
Local aPosCol		:= IIf(MV_PAR06 == 1,{ 1120, 1500, 1900 },{ 1500, 1900 })
Local lVlrZerado  	:= IIf(mv_par12==1,.T.,.F.)
Local cSaldos     	:= fTrataSlds()
Local aPosInd		:= {}
Local nSaldoAnt		:= 0
Local nSaldoAtu		:= 0
Local nSaldoVar		:= 0
Local nX			:= 0
Local cFiliais		:= ""
Local aDemJson		:= {}
Local lRelato 		:= .T.
Local lJson 		:= .F.
Local lPrimeiro		:= .T.
Local lIndividual	:= .T.
Local cContas		:= ""
Local cCtbJson		:= ""		
Local nDivide		:= 1
Local lMVPAR24		:= .F.
Local cFindSX1 		:= Padr("CTR560", Len(SX1->X1_GRUPO), " ")

SX1->(dbSetOrder(1))
lMVPAR24 := SX1->(dbSeek(cFindSX1+"24"))

If lMVPAR24 .And. ValType(mv_par24) == "N"
	nDivide := mv_par24
Endif

//para verificar por quanto sera dividido e adicionar ao o titulo da moeda.
If nDivide == 2			// Divide por cem
	nDivide := 100
ElseIf nDivide == 3		// Divide por mil
	nDivide := 1000
ElseIf nDivide == 4		// Divide por milhao
	nDivide := 1000000
EndIf

aSetOfBook[9] := nDivide
aCtbMoeda     := CtbMoeda(mv_par03, aSetOfBook[9])

aDemJson := CTBDEMJSON()

If Len(aDemJson)>0
	If aDemJson[1] == 2
		lJson := .T.
		lRelato := .F.
	ElseIf aDemJson[1] == 3
		lJson := .T.
	EndIf
	If aDemJson[5] == 2
		lIndividual := .F.
	EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao                      �
//����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	/*01*/oMeter,;
							/*02*/oText,;
							/*03*/oDlg,;
							/*04*/@lEnd,;
							/*05*/@cArqTmp,;
							/*06*/dFinalA+1,;
							/*07*/dFinal,;
							/*08*/"",;
							/*09*/"",;
							/*10*/"",;
							/*11*/Repl("Z", TamSx3("CT1_CONTA")[1]),;
							/*12*/"",;
							/*13*/Repl("Z", TamSx3("CTT_CUSTO")[1]),;
							/*14*/"",;
							/*15*/Repl("Z", TamSx3("CTD_ITEM")[1]),;
							/*16*/"",;
							/*17*/Repl("Z", TamSx3("CTH_CLVL")[1]),;
							/*18*/mv_par03,;
							/*19*/cSaldos,;
							/*20*/aSetOfBook,;
							/*21*/,;
							/*22*/"",;
							/*23*/Repl("Z", 20),;
							/*24*/,;
							/*25*/,;
							/*26*/,;
							/*27*/,;
							/*28*/,;
							/*29*/mv_par04=1,;
							/*30*/mv_par05,;
							/*31*/nDivide,;
							/*32*/lVlrZerado,;
							/*33*/,;
							/*34*/,;
							/*35*/,;
							/*36*/,;
							/*37*/,;
							/*38*/,;
							/*39*/,;
							/*40*/,;
							/*41*/,;
							/*42*/,;
							/*43*/,;
							/*44*/,;
							/*45*/,;
							/*46*/,;
							/*47*/,;
							/*48*/,;
							/*49*/,;
							/*50*/,;
							/*51*/,;
							/*52*/,;
							/*53*/,;
							/*54*/,;
							/*55*/,;
							/*56*/,;
							/*57*/cMoedaDesc,;
							/*58*/lMovPeriodo,;
							/*59*/aSelFil,;
							/*60*/,;
							/*61*/.T.,;
							/*62*/mv_par15=1);
			},STR0010,cProcesso) //"Criando Arquivo Temporario..."

dbSelectArea( "cArqTmp" )
dbGoTop()


//Limitado a exibi��o do titulo em 85 caracteres para que n�o estoure na exibi��o das filiais
If Len(aSelFil) > 0            
	For nX := 1 to Len(aSelFil)
		cFiliais += aSelFil[nX] + ","


	Next nX
	
	cFiliais := Left(cFiliais,Len(cFiliais)-1)
	
	//N�o exibe as filiais caso nao haja espaco suficiente.
	If Len(cTitulo + STR0019 + cFiliais) <= 85
		cTitulo += STR0019 + cFiliais
	EndIf	
EndIf
	
While cArqTmp->(!Eof())
	If lRelato
		If lin > 3000
			If !lFirstPage
				oPrint:Line( ntraco,150,ntraco,nTamLin )//Horizontal
			EndIf
			i++
			oPrint:EndPage()//Finaliza a pagina
			
			CtbCbcDem(oPrint,cTitulo,lLandScape,aSelFil)//Funcao que monta o cabecalho padrao

			lin := 270
			If MV_PAR18 == 2
				Ctr560Ind( oPrint, @lin, nTamLin )
			EndIf

			Ctr560Esp(oPrint,cDescMoeda,aPosCol,nTamLin, lin)
			lin += 50
			lFirstPage := .F.
		EndIf

		//������������������������������������������������������������Ŀ
		//�indica se a entidade gerencial sera impressa/visualizada em �
		//�um relatorio ou consulta apos o processamento da visao      �
		//��������������������������������������������������������������
		If cArqTmp->VISENT == "2"
			cArqTmp->( DbSkip() )
			Loop
		EndIf
		
		If AllTrim(cArqTmp->DESCCTA ) == "-"
			// Linha horizontal
			oPrint:Line(lin,150,lin,nTamLin)
		Else
			//Linha vertical
			oPrint:Line( lin,150,lin+50,150)
			
			//Negrito caso Sub-Total/Total/Separador (caso tenha descricao) e Igual (Totalizador)
			nColuna := 180+(15*cArqTmp->COLUNA )
			cDescCont := Posicione("CTS",2,xFilial("CTS")+cCodVis+cArqTmp->CONTA,"CTS_DETHCG")
			cDescCont := AllTrim(cArqTmp->DESCCTA)+Rtrim(cDescCont)
			nLinha:= MLCount(cDescCont,74)

			oPrint:Say(lin+15,nColuna,MemoLine(cDescCont,74,1), If(cArqTmp->IDENTIFI $ "3469", oCouNew08N, oFont08))
			//oPrint:Say(lin+15,nColuna,cArqTmp->(DESCCTA), If(cArqTmp->(IDENTIFI) $ "3469", oCouNew08N, oFont08))

			For nPosCol := 1 To Len(aPosCol)
				oPrint:Line(lin,aPosCol[nPosCol],lin+50,aPosCol[nPosCol])	// Separador vertical
				Do Case
					Case nPosCol = 1
						If ! lMovPeriodo
							nSaldo		:= cArqTmp->SALDOATU
						Else
							nSaldo		:= cArqTmp->MOVIMENTO
						EndIf

						If cArqTmp->TIPOCONTA == "1" .AND. Empty( cArqTmp->SUPERIOR ) .AND. cArqTmp->TOTVIS == "1"
							nSaldoAtu 	+= nSaldo
						EndIf
					Case nPosCol = 2
						If ! lMovPeriodo
							nSaldo		:= cArqTmp->SALDOANT
						Else
							nSaldo		:= cArqTmp->MOVPERANT
						EndIf

						If cArqTmp->TIPOCONTA == "1" .AND. Empty( cArqTmp->SUPERIOR ) .AND. cArqTmp->TOTVIS == "1"
							nSaldoAnt 	+= nSaldo
						EndIf
					Case nPosCol = 3
						If ! lMovPeriodo
							nSaldo		:= GetVarEnt(cArqTmp->CONTA,cCodVis,cArqTmp->ORDEM)//cArqTmp->(SALDOATU-SALDOANT)
						Else
							nSaldo		:= cArqTmp->(MOVIMENTO-MOVPERANT)
						EndIf

						If cArqTmp->TIPOCONTA == "1" .AND. Empty( cArqTmp->SUPERIOR ) .AND. cArqTmp->TOTVIS == "1"
							nSaldoVar 	+= nSaldo
						EndIf
				EndCase

				If cArqTmp->IDENTIFI < "5"
					ValorCTB(nSaldo,lin+15,aPosCol[nPosCol],IIf(cTpValor $ "D",20,23),nDecimais,.T.,cPicture,cArqTmp->NORMAL,cArqTmp->CONTA,.T.,oPrint,cTpValor,IIf(cArqTmp->IDENTIFI $ "4","1",cArqTmp->IDENTIFI))
				EndIf
			Next

			//Separador vertical
			oPrint:Line(lin,nTamLin,lin+50,nTamLin)
			
			//Impress�o da continuacao da descricao caso exista
			For nBegin := 2 To nLinha
				lin +=47
				oPrint:Line( lin,150,lin+50,150)	// Separador vertical
				oPrint:Say(lin+15,nColuna,MemoLine(cDescCont,74,nBegin), If(cArqTmp->IDENTIFI $ "3469", oCouNew08N, oFont08))
				For nPosCol := 1 To Len(aPosCol)
					oPrint:Line(lin,aPosCol[nPosCol],lin+50,aPosCol[nPosCol])	// Separador vertical
				Next nPosCol
				oPrint:Line(lin,nTamLin,lin+50,nTamLin) ////Separador vertical
			Next nBegin
			
			lin +=47
		Endif		
		nTraco := lin + 1
	EndIf

	If lJson
		If cArqTmp->VISENT == "2"
			cArqTmp->( DbSkip() )
			Loop
		EndIf


		If !lPrimeiro
			cContas	+= ","
		EndIf
		lPrimeiro := .F.

		cDescCont := Posicione("CTS",2,xFilial("CTS")+cCodVis+cArqTmp->CONTA,"CTS_DETHCG")
		cDescCont := AllTrim(cArqTmp->DESCCTA)+Rtrim(cDescCont)
	
		If cArqTmp->TIPOCONTA == "1" .AND. Empty( cArqTmp->SUPERIOR ) .AND. cArqTmp->TOTVIS == "1"
			nSaldoAtu 	+= nSaldo
		EndIf
	
		If cArqTmp->TIPOCONTA == "1" .AND. Empty( cArqTmp->SUPERIOR ) .AND. cArqTmp->TOTVIS == "1"
			nSaldoAnt 	+= nSaldo
		EndIf

		//O usu�rio dever� selecionar saldo zerado ="n�o"
		//N�o posso tratar valores zerados no fonte, pois o c�lculo de n�vel ficaria incorreto

		cContas += '{"@id": "'+AllTrim(cArqTmp->CONTA)+'",'+;
        			'"@nivel": "'+AllTrim(cArqTmp->NIVJSON)+'",'+;
        			'"@descricao": "'+AllTrim(cDescCont)+'",'+;
        			'"@contapai": "'+AllTrim(cArqTmp->SUPERIOR)+'",'
					
		If lIndividual
			cContas += '"valoresIndividualizados": '
		Else
			cContas += '"valoresConsolidados": '
		EndIf

		cContas += '[{"@dtBase": "CTBR560DT1","@valor": "'+cValToChar(IIf(lMovPeriodo,cArqTmp->MOVIMENTO,cArqTmp->SALDOATU))+'"}'+;					
				   ',{"@dtBase": "CTBR560DT2","@valor": "'+cValToChar(IIf(lMovPeriodo,cArqTmp->MOVPERANT,cArqTmp->SALDOANT))+'"}]}'
		
	EndIf
	cArqTmp->(DbSkip())
EndDo



If lJson     
	Pergunte(cFindSX1,.F.)
	If DateDiffMonth(dFinalA,dFinal) == 6 		
		cDt1 := "S"+Month2Str(dFinal)+Year2Str(dFinal)
		cDt2 := "S"+Month2Str(dFinalA)+Year2Str(dFinalA)
	Else
		cDt1 := "A"+Month2Str(dFinal)+Year2Str(dFinal)
		cDt2 := "A"+Month2Str(dFinalA)+Year2Str(dFinalA)
	EndIf

	cCtbJson  += '{"PergunteRel": { "CTBR560": ['+CtLstPerg(Alltrim(cFindSX1))+'] }, '+;
  				 '"ParametrosJson": {'+;
				 '"PergunteJson": ['+CtLstPerg("CTBJSON", aDemJson )+'],'+;
    			 '"DatasJson": [{"CTBR560DT1":"'+cDt1+'","CTBR560DT2":"'+cDt2+'"}]},'
	
	If lIndividual
		cCtbJson  += '"DemonstracaoDosFluxosDeCaixa": {"contas": ['+cContas+']}}'
	Else
		cCtbJson  += '"DemonstracaoDosFluxosDeCaixaConsolidada": {"contas": ['+cContas+']}}'
	EndIf

	MemoWrite(aDemJson[4], cCtbJson)
EndIf

If lRelato

	//Linha horizontal
	oPrint:Line(lin,150,lin,nTamLin)

	//������������������������������������������������������Ŀ
	//�preenche o saldo dos exercicios na caixa de atividades�
	//�operacionais usado com o metodo indireto              �
	//��������������������������������������������������������
	If MV_PAR18 == 2
		If MV_PAR19 == 2
			nSaldoAtu := MV_PAR20
			nSaldoAnt := MV_PAR21
			nSaldoVar := nSaldoAtu - nSaldoAnt
		EndIf

		If MV_PAR06 == 1
			ValorCTB(nSaldoAnt, 379,  770,IIf(cTpValor $ "D",20,IIF(cTpValor $ "P", 23, 21)),nDecimais,.T.,cPicture,,,.T.,oPrint,cTpValor,"1")
			ValorCTB(nSaldoAtu, 379, 1350,IIf(cTpValor $ "D",20,IIF(cTpValor $ "P", 23, 21)),nDecimais,.T.,cPicture,,,.T.,oPrint,cTpValor,"1")
			ValorCTB(nSaldoVar, 379, 1918,IIf(cTpValor $ "D",22,23),nDecimais,.T.,cPicture,,,.T.,oPrint,cTpValor,"1")
		Else
			ValorCTB(nSaldoAnt, 379, 1350,IIf(cTpValor $ "D",20,IIF(cTpValor $ "P", 23, 21)),nDecimais,.T.,cPicture,,,.T.,oPrint,cTpValor,"1")
			ValorCTB(nSaldoAtu, 379, 1918,IIf(cTpValor $ "D",20,IIF(cTpValor $ "P", 23, 21)),nDecimais,.T.,cPicture,,,.T.,oPrint,cTpValor,"1")
		EndIf
	EndIf

	lin += 10             

	If lImpTrmAux
		If lin > 3000
			If !lFirstPage
				oPrint:Line( ntraco,150,ntraco,nTamLin )   	// horizontal
			EndIf
			i++
			oPrint:EndPage() 	 								// Finaliza a pagina
			CtbCbcDem(oPrint,cTitulo,lLandScape)					// Funcao que monta o cabecalho padrao
			Ctr560Esp(oPrint,cDescMoeda,aPosCol,nTamLin,lin)
			lin := 304
			lFirstPage := .F.
		Endif

		cArqTRM 	   := mv_par11
		aVariaveis  := {}

		// Buscando os par�metros do relatorio (a partir do SX1) para serem impressaos do Termo (arquivos *.TRM)
		SX1->(DbSeek(cPerg+"01"))
		While AllTrim(SX1->X1_GRUPO) == cPerg
			AADD(aVariaveis,{AllTrim(Upper(SX1->X1_VAR01)),&(SX1->X1_VAR01)})
			SX1->(DbSkip())
		End

		If !File(cArqTRM)
			aSavSet:=__SetSets()
			cArqTRM := CFGX024( cArqTRM, STR0011 ) // "Respons�veis..."
			__SetSets(aSavSet)
			Set(24,Set(24),.t.)
		Endif

		If cArqTRM#NIL
			ImpTerm(cArqTRM,aVariaveis,"",.T.,{oPrint,oFont08,Lin})
		Endif
	Endif
EndIf

DbSelectArea( "cArqTmp" )
Set Filter To
dbCloseArea()
 
If Select( "cArqTmp" ) == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	

Return lRelato

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �CTR560ESP � Autor �Felipe Aurelio de Melo � Data � 25.09.08 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Cabecalho Especifico do relatorio CTBR041.                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CTR560ESP(ParO1,ParC1)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpC1 = Descricao da moeda sendo impressa                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTR560Esp(oPrint,cDescMoeda,aPosCol,nTamLin, lin )

Local nPosCol

// Linhas horizontal
oPrint:Line(lin,150,lin,nTamLin)

// Linhas verticais
oPrint:Line(lin,150,lin+50,150)
oPrint:Line(lin,nTamLin,lin+50,nTamLin)
lin += 10

//Primeira coluna
oPrint:Say(lin,195,"(Em " + cDescMoeda + ")",oArial10)

For nPosCol := 1 To Len(aPosCol)
	Do Case
		//Segunda coluna
		Case nPosCol = 1
			oPrint:Say(lin,aPosCol[nPosCol] ,Padl(DtoC(dFinal),23),oArial10)

		//Terceira coluna
		Case nPosCol = 2
			oPrint:Say(lin,aPosCol[nPosCol] ,Padl(DtoC(dFinalA),23),oArial10)

		//Quarta coluna
		Case nPosCol = 3
			oPrint:Say(lin,aPosCol[nPosCol] ,Padl( STR0012, 21 ),oArial10)
	EndCase
Next

// Linha horizontal
lin += 40
oPrint:Line(lin,150,lin,nTamLin)
lin += 47

Return Nil

/*/
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � CTR560SX5    � Autor � Felipe Aurelio de Melo� Data � 29.09.08 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Cria lista de opcoes para escolha em parametro                 ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � Siga                                                           ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/

Function CTR560SX5(nModelo)

Local i := 0
Private nTam      := 0
Private aCat      := {}
Private MvRet     := Alltrim(ReadVar())
Private MvPar     := ""
Private cTitulo   := ""
Private MvParDef  := ""

#IFDEF WINDOWS
	oWnd := GetWndDefault()
#ENDIF

//Tratamento para carregar variaveis da lista de opcoes
Do Case 
	Case nModelo = 1
		nTam:=1
		cTitulo := STR0013
		SX5->(DbSetOrder(1))
		SX5->(DbSeek(XFilial("SX5")+"SL"))
		While SX5->(!Eof()) .And. AllTrim(SX5->X5_TABELA) == "SL"
			MvParDef += AllTrim(SX5->X5_CHAVE)
			aAdd(aCat,AllTrim(SX5->X5_CHAVE)+" - "+AllTrim(SX5->(X5Descri())))			 
			SX5->(DbSkip())
		End
		 MvPar:= PadR(AllTrim(StrTran(&MvRet,";","")),Len(aCat))
		&MvRet:= PadR(AllTrim(StrTran(&MvRet,";","")),Len(aCat))
EndCase

//Executa funcao que monta tela de opcoes
f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,.F.,nTam)

//Tratamento para separar retorno com barra "/"
&MvRet := ""
For i:=1 to Len(MvPar)
	If !(SubStr(MvPar,i,1) $ " |*")
		&MvRet  += SubStr(MvPar,i,1) + ";"
	EndIf
Next	

//Trata para tirar o ultimo caracter
&MvRet := SubStr(&MvRet,1,Len(&MvRet)-1)

//Guarda numa variavel private o retorno da fun��o
cRetSX5SL := &MvRet

Return(.T.)



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � fTrataSlds� Autor� Felipe Aurelio de Melo� Data � 14.10.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tratamento do retorno do parametro                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR560R4                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function fTrataSlds()

Local cRet := ""

If MV_PAR15 = 1
	cRet := MV_PAR16
Else
	cRet := MV_PAR17
EndIf

Return(cRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � Ctr560Ind � Autor� Totvs                 � Data � 11/02/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � apresenta o quadro de atividades operacionais quando usar  ���
���          � metodo indireto.                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR560R4                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Ctr560Ind( oPrint, lin, nTamLin )
	Local aPosInd	:= IIf( MV_PAR06 == 1, { 625, 1190, 1730 }, { 1190, 1730 } )
	Local nCol		:= 0

	// Cabecalho
	oPrint:Line(lin,150,lin,nTamLin)
	oPrint:Line(lin,150,lin+50,150)

	If MV_PAR06 == 1
		oPrint:Say(lin+15,  860, STR0014, 	oCouNew08N )
		oPrint:Say(lin+15, 1440, STR0015, 	oCouNew08N )
		oPrint:Say(lin+15, 2005, STR0016,	oCouNew08N )
	Else
		oPrint:Say(lin+15, 1410, STR0014, 	oCouNew08N )
		oPrint:Say(lin+15, 2025, STR0015, 	oCouNew08N )
	EndIf

	// Separador vertical
	For nCol := 1 To Len( aPosInd )
		oPrint:Line( lin, aPosInd[nCol], lin+50, aPosInd[nCol] )
	Next

	oPrint:Line( lin, nTamLin, lin+50, nTamLin )
	lin += 47
	

// ORIZIO criar arquivo .CH com os textos usados no relatorio

	// Linha 1
	oPrint:Line(lin,150,lin,nTamLin)
	oPrint:Line(lin,150,lin+50,150)
	oPrint:Say(lin+15,  180, STR0017, oCouNew08N )

	// Separador vertical
	For nCol := 1 To Len( aPosInd )
		oPrint:Line( lin, aPosInd[nCol], lin+50, aPosInd[nCol] )
	Next

	oPrint:Line(lin,nTamLin,lin+50,nTamLin)
	lin += 47

	// Linha 2
	oPrint:Line(lin,150,lin,nTamLin)
	oPrint:Line(lin,150,lin+50,150)
	oPrint:Say(lin+15,  180, STR0018, oCouNew08N )
                                 
	// Separador vertical
	For nCol := 1 To Len( aPosInd )
		oPrint:Line( lin, aPosInd[nCol], lin+50, aPosInd[nCol] )
	Next

	oPrint:Line(lin,nTamLin,lin+50,nTamLin)
	lin += 47

	oPrint:Line(lin,150,lin,nTamLin)
	lin += 20

Return
