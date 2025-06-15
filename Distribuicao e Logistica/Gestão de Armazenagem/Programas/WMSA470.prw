#Include 'Protheus.ch'  
#INCLUDE "FWMVCDEF.CH"
#Include "APWIZARD.CH"
#Include "WMSA470.CH"

#DEFINE INCLUIR 1
#DEFINE ALTERAR 2
#DEFINE CRLF CHR(13)+CHR(10)

#DEFINE WMSA47001 "WMSA47001"
//-----------------------------------
/*/{Protheus.doc} WMSA470
Wizard de Gera��o do Sequ�ncia de abastecimento.

@author Felipe Machado de Oliveira
@version P12
@Since	28/01/14
/*/
//-----------------------------------
Function WMSA470()
Local nInd  	  := 0
Local aPaineis    := {}
Local cTitTabela  := ""
Local cDescFiltro := ""
Local nOpc		  := INCLUIR
Local cFil		  := ""
Local lFim		  := .F.
Local cTexto      := STR0001+CRLF+CRLF //"Rela��o de produtos processados."
Local lGerou      := .F.
Local aIndKey     := {}
Local cIndKey     := ""
Local aTxtApre    := ""
Local aSize       := {}
Local aNoFields   := {'DC3_CODPRO','DC3_DESPRO','DC3_LOCAL','DC3_REABAS','DC3_PRIEND'} // Nao aparecer na MSGetDados
Local nPos        := 0
Local oDlgFinal   := Nil
Local oDescFiltro := Nil
Local oFont       := Nil
Local oMemo       := Nil
Local aColsWiz   := {"DC3_LOCAL","DC3_REABAS","DC3_PRIEND"}

Private aBrWiz     := {}
Private aHeader    := {}
Private aHeaderRes := {}
Private aCols      := {}
Private n          := 1
Private lRefresh   := .T.
Private Inclui     := .T.
Private Altera     := .F.
Private aEstrutAnt := {}
Private oGetD      := Nil
Private oEncDC3    := Nil
Private oGetDRes   := Nil
Private oWizard    := Nil

	aSize := MsAdvSize(.F.)
	
	// Busca as informa��es da tabela a ser processada
	cTitTabela := FWX2Nome("DC3")
	cIndKey    := FWX2Unico("DC3")
	aIndKey := &("{'"+StrTran(AllTrim(cIndKey),"+","','")+"'}")
	aDel(aIndKey,1)
	aSize(aIndKey,Len(aIndKey)-1)
	
	FillGetDados(3,"DC3",1,,,,aNoFields,,,,,.T.)
	nPos := aScan(aHeader,{|x| Trim(x[2])=="DC3_ORDEM"})
	aCols[1][nPos] := StrZero(1,Len(DC3->DC3_ORDEM))
	
	nPos := aScan(aHeader,{|x| Trim(x[2])=="DC3_TPESTR"})
	If nPos > 0
		aHeader[nPos][6] := "ExistCpo('DC8')"
	EndIf
	
	nPos := aScan(aHeader,{|x| Trim(x[2])=="DC3_TIPREP"})
	If nPos > 0
		aHeader[nPos][6] := "StaticCall(WMSA470,ValidField)"
	EndIf
	
	nPos := aScan(aHeader,{|x| Trim(x[2])=="DC3_PERREP"})
	If nPos > 0
		aHeader[nPos][6] := "StaticCall(WMSA470,ValidField)"
	EndIf
	
	nPos := aScan(aHeader,{|x| Trim(x[2])=="DC3_PERAPM"})
	If nPos > 0
		aHeader[nPos][6] := "StaticCall(WMSA470,ValidField)"
	EndIf
	
	//Texto padrao caso n�o seja passado por par�metro.
	If aTxtApre == Nil .Or. Len(aTxtApre) <> 4
		aTxtApre :=	{}
		aAdd(aTxtApre, STR0002) //"Facilitador..."
		aAdd(aTxtApre, STR0003+" � "+AllTrim(cTitTabela)) //"Facilitador da tabela DC3"
		aAdd(aTxtApre, "")
		aAdd(aTxtApre, STR0004) //"Este facilitador tem como objetivo, possibilitar a cria��o simplificada das informa��es da Sequ�ncia de Abastecimento para atender de forma r�pida as necessidades da gest�o de armazenamento WMS. Partindo de crit�rios definidos na execu��o desse assistente."
	EndIf
	
	//Defini��o dos paineis de apresenta��o da rotina, estes paineis s�o padr�es, com textos padr�es                          
	
	aAdd(aPaineis,{STR0006, STR0007, STR0005}) //"Campos a serem alterados..."###"Neste passo devemos selecionar os campos que sofrer�o intera��o no respectivo cadastro."
	//STR0005 = "Ao informarmos os campos abaixo, estaremos indicando que os mesmos ser�o criados para todo o intervalo de produtos indicados no pr�ximo quadro deste assistente. Esta rotina destina-se a facilitar a gera��o do cadastro de sequ�ncia de abastecimento conforme filtro e conte�dos informados."
	 
	aAdd(aPaineis,{STR0009, STR0010, STR0008}) //"Filtro"###"Neste passo � poss�vel informar um filtro para restringir as altera��es no respectivo cadastro."
	//STR0008 = "Ao selecionarmos um filtro para o processamento da rotina, estaremos indicando que os registros que satisfizerem a condi��o definida abaixo, ser�o processados e atualizados conforme parametriza��es."
	
	aAdd(aPaineis,{STR0011, STR0012, ""}) //"Resumo"###"Neste passo podemos ou n�o confirmar as altera��es conforme o resumo apresentado a seguir."
	
	Define FONT oFont NAME "Arial" SIZE 0, -10
	Define FONT oFontB NAME "Arial" SIZE 0, -10 BOLD
	
	Define WIZARD oWizard;
		TITLE SubStr (aTxtApre[1], 1, 80);
		HEADER SubStr (aTxtApre[2], 1, 80);
		MESSAGE SubStr (aTxtApre[3], 1, 80);
		TEXT aTxtApre[4];
		NEXT {|| .T.};
		FINISH {|| .T.}
		
		For nInd := 1 To Len (aPaineis)
			CREATE PANEL oWizard;
			HEADER aPaineis[nInd][1];
			MESSAGE aPaineis[nInd][2];
			BACK {|| .T. }; 
			NEXT {|| ValPainel(oWizard,cFil)};
			FINISH {|| lFim := MSGYESNO(STR0013,STR0014)} //"Confirma inclus�o conforme apresentado no quadro de resumo?"###"Aten��o"
	
			Do Case
				Case nInd == 1
					//Informa��es
					TSay():New (05, 05, &("{||aPaineis["+AllTrim(Str(nInd))+"][3]}"), oWizard:oMPanel[nInd+1],,oFont,.F.,.F.,.F., .T., CLR_BLUE,, 275, 50, .F., .F., .F., .F., .F.)
	
					@29,05 TO 075,295 LABEL STR0015 OF oWizard:oMPanel[nInd+1] PIXEL //"Campos � serem considerados"
					@77,05 TO 135,295 LABEL "" OF oWizard:oMPanel[nInd+1] PIXEL
					
					RegToMemory("DC3", .T.,,.F.)
					oEncDC3 := MsmGet():New("DC3",,3,,,,aColsWiz,{40,10,72,290},,,,,,oWizard:oMPanel[nInd+1],.T.,.T.)
					
					oGetD := MsNewGetDados():New(080,010,132,290,GD_INSERT+GD_UPDATE+GD_DELETE,'AllWaysTrue','AllWaysTrue','+DC3_ORDEM',,,,,"AllwaysTrue","AllwaysTrue",oWizard:oMPanel[nInd+1],aHeader,aCols)
					oEncDC3:Refresh()
	
				Case nInd == 2
					//Filtro
					TSay ():New (05, 05, &("{||aPaineis["+AllTrim(Str(nInd))+"][3]}"), oWizard:oMPanel[nInd+1],,oFont,.F.,.F.,.F., .T., CLR_BLUE,, 275, 50, .F., .F., .F., .F., .F.)
	
					@40,05 TO 135,250 LABEL STR0009 OF oWizard:oMPanel[nInd+1] PIXEL //"Filtro"
					@50,10 GET oDescFiltro VAR cDescFiltro MEMO SIZE 235,74 OF oWizard:oMPanel[nInd+1] PIXEL READONLY
	
					DEFINE SBUTTON FROM 44,255  TYPE 17 ENABLE OF oWizard:oMPanel[nInd+1] ACTION (cFil  := BuildExpr("SB5",oWizard:oMPanel[3],cFil),;
						cDescFiltro := MontDescr("SB5",cFil),;
						oDescFiltro:Refresh()) WHEN (nOpc == INCLUIR .OR. nOpc == ALTERAR) //Monta o filtro
	
				Case nInd == 3
					//Resumo
					TSay ():New (05, 05, &("{||aPaineis["+AllTrim(Str(3))+"][3]}"), oWizard:oMPanel[nInd+1],,oFont,.F.,.F.,.F., .T., CLR_BLUE,, 275, 50, .F., .F., .F., .F., .F.)
	
					@02,05 TO 135,295 LABEL STR0011 OF oWizard:oMPanel[nInd+1] PIXEL //"Resumo"
					
			EndCase
		Next (nInd)
	
	Activate WIZARD oWizard Centered
	
	If lFim
		//Processamento dos dados informados
		Atualiza(@lGerou)
	
		If lGerou
			cTexto += CRLF
			cTexto += STR0016 //"Conclus�o: Foram criados as Sequ�ncias de Abastecimento dos produtos selecionados conforme o filtro."
		Else
			cTexto += STR0017 //"Nenhum"
			cTexto += CRLF+CRLF
			cTexto += STR0018 //"Status: Atualiza��o n�o efetuada, n�o foram encontrados dados para a inclus�o."
		EndIf
	
		DEFINE MSDIALOG oDlgFinal TITLE STR0019 From 3,0 to 340,417 PIXEL //"Atualizacao concluida."
		
			@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlgFinal PIXEL READONLY
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont := oFont
			DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlgFinal:End() ENABLE OF oDlgFinal PIXEL //Sair
	
		ACTIVATE MSDIALOG oDlgFinal CENTER
	EndIf

Return .T.
//-----------------------------------
/*/{Protheus.doc} ValPainel
Validacao das trocas de paineis do wizard. 

@author Felipe Machado de Oliveira
@version P12
@Since	30/01/14
/*/
//-----------------------------------
Static Function ValPainel(oWizard,cFil)
Local lRet      := .T.
Local lExistDC3 := .T.
Local lExistSB5 := .F.
Local aCods     := {}
Local nX        := 0
	
	If oWizard:NPANEL==2
		oGetD:ForceRefresh()
		aCols := oGetD:aCols
		lRet := !Empty(M->DC3_LOCAL)
		
	ElseIf oWizard:NPANEL == 3
		If Empty(cFil)
			Help(,,'HELP',,STR0020,1,0,) //"Filtro � obrigat�rio."
			lRet := .F.
		Else
			dbSelectArea("SB5")
			SB5->(dbSetOrder(1))
			SB5->(dbGoTop())
			While SB5->(!EOF())
				If &(cFil)
					lExistSB5 := .T.
					aAdd(aCods, SB5->B5_COD)
				EndIf
				SB5->(dbSkip())
			EndDo
			
			For nX := 1 To Len(aCods)
				dbSelectArea("DC3")
				DC3->(dbSetOrder(1))
				DC3->(dbSeek(xFilial("DC3")+aCods[nX]+M->DC3_LOCAL))
				If !(DC3->(!EOF()) .And. DC3->DC3_FILIAL == xFilial("DC3");
							   	   .And. AllTrim(DC3->DC3_CODPRO) == AllTrim(aCods[nX]);
							   	   .And. AllTrim(DC3->DC3_LOCAL) == AllTrim(M->DC3_LOCAL))
					lExistDC3 := .F.
					Exit
				EndIf
			Next (nX)
			
			If !lExistSB5
				Help(,,"HELP",,STR0021,1,0,) //"N�o foram encontrados produtos com o filtro informado!"
				lRet := .F.
			EndIf
			
			If lRet .And. lExistDC3
				Help(,,"HELP",,STR0022,1,0,) //"J� existe Sequ�ncia de Abastecimento cadastrada!"
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			Resumo(cFil)
		EndIf
	EndIf
Return lRet
//-----------------------------------
/*/{Protheus.doc} Resumo
Resumo da inclus�o dos dados.

@author Felipe Machado de Oliveira
@version P12
@Since	31/01/13
/*/
//-----------------------------------
Static Function Resumo(cFil)
Local aColsLoc := oGetD:aCols
Local aColsAux := {}

	FillGetDados(1,"DC3",1,,,,,,,,,.F.,aHeaderRes,aColsAux)
	aColsAux := WMSA470RES(cFil,aColsLoc)
	oGetDRes := MsNewGetDados():New(010,010,132,290,0,'AllWaysTrue','AllWaysTrue',,,,,,"AllwaysTrue","AllwaysTrue",oWizard:oMPanel[4],aHeaderRes,aColsAux)
Return Nil
//-----------------------------------
/*/{Protheus.doc} WMSA470RES
Cria o aCols da grid de resumo

@author Felipe Machado de Oliveira
@version P12
@Since	31/01/13
/*/
//-----------------------------------
Function WMSA470RES(cFil,aColsPar)
Local cArmazem   := M->DC3_LOCAL
Local cReabas    := M->DC3_REABAS
Local cPriEnd    := M->DC3_PRIEND
Local aResCols   := {}
Local aOrdem     := {}
Local nX         := 0
Local nY         := 0
Local nZ         := 0
Local nPos       := 0
Local nPosFilial := aScan(aHeader,{|x| Trim(x[2])=="DC3_FILIAL"})
Local nPosLocal  := aScan(aHeader,{|x| Trim(x[2])=="DC3_LOCAL"})
Local nPosCodPro := aScan(aHeader,{|x| Trim(x[2])=="DC3_CODPRO"})
Local nPosDesPro := aScan(aHeader,{|x| Trim(x[2])=="DC3_DESPRO"})
Local nPosReabas := aScan(aHeader,{|x| Trim(x[2])=="DC3_REABAS"})
Local nPosPriend := aScan(aHeader,{|x| Trim(x[2])=="DC3_PRIEND"})
Local nPosOrdem  := aScan(aHeader,{|x| Trim(x[2])=="DC3_ORDEM"})

	dbSelectArea("SB5")
	SB5->(dbSetOrder(1))
	SB5->(dbGoTop())
	While SB5->(!EOF())
	
		If &(cFil)
			// Desconsidera produtos que j� possuem sequencia de abastecimento
			If !ProdInDc3(SB5->B5_COD,cArmazem)
				For nX := 1 To Len(aColsPar)
					// Desconsidera os itens deletados
					If !aColsPar[nX][Len(aColsPar[nX])]
						aAdd(aResCols,Array(Len(aHeaderRes)+1))

						nZ := 2
						// Como a mesma tabela possue mestre detalhe, precisa considerar os campos do mestre na grid para apresentar no resumo.
						// Todos os campos do mestre devem ser setados por posi��o correspondente do aHeader,
						// exceto o campo Ordem que faz parte da grid, que neste contexto est� for�ando a ordem correta,
						// para casos em que � exclu�da uma linha no momento da inclus�o.
						// Os demais campos j� estar�o na ordem correta.
						For nY := 1 To Len(aHeaderRes)+1
							If nY == nPosFilial //"DC3_FILIAL"
								aResCols[Len(aResCols)][nY] := xFilial('DC3')
							ElseIf nY == nPosLocal //"DC3_LOCAL"
								aResCols[Len(aResCols)][nY] := cArmazem
							ElseIf nY == nPosCodPro //"DC3_CODPRO"
								aResCols[Len(aResCols)][nY] := SB5->B5_COD
							ElseIf nY == nPosDesPro //"DC3_DESPRO"
								aResCols[Len(aResCols)][nY] := SB5->B5_CEME
							ElseIf nY == nPosReabas //"DC3_REABAS"
								aResCols[Len(aResCols)][nY] := cReabas
							ElseIf nY == nPosPriend //"DC3_PRIEND"
								aResCols[Len(aResCols)][nY] := cPriEnd
							ElseIf nY == nPosOrdem//"DC3_ORDEM" <- For�a a orderm correta do campo
								nPos := aScan(aOrdem,{|x| x[1] == SB5->B5_COD})
								If nPos > 0
									aOrdem[nPos][2] := Soma1(aOrdem[nPos][2])
								Else
									aAdd(aOrdem, {SB5->B5_COD, "01"})
									nPos := Len(aOrdem)
								EndIf
								aResCols[Len(aResCols)][nY] :=  aOrdem[nPos][2]
							Else // Demais campos do grid
								aResCols[Len(aResCols)][nY] := aColsPar[nX][nZ++]
							EndIf
						Next nY
						
					EndIf
				Next nX
			EndIf
		EndIf
		
		SB5->(dbSkip())
	EndDo
Return aResCols
//-----------------------------------
/*/{Protheus.doc} ProdInDc3
Verifica se o produto selecionado no filtro ja possue 
sequencia de abastecimento para desconsidera-lo

@author Felipe Machado de Oliveira
@version P12
@Since	31/01/13
/*/
//-----------------------------------
Static Function ProdInDc3(cProd,cArm)
Local aAreaAnt := GetArea()
Local lRet     := .F.
	lRet := !Empty(Posicione("DC3",1,xFilial("DC3")+cProd+cArm+"01","DC3_CODPRO"))
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
/*/{Protheus.doc} Atualiza
Funcao de atualizacao da tabela envolvida.

@author Felipe Machado de Oliveira
@version P12
@Since	31/01/14
/*/
//-----------------------------------
Static Function Atualiza(lGerou)
Local nX      := 0
Local nY      := 0
Local aDados  := oGetDRes:aCols
Local nLinhas := Len(aDados)

	lGerou := .T.
	
	If nLinhas > 0
		Begin Transaction
		For nX := 1 To nLinhas
		
			dbSelectArea("DC3")
			DC3->( dbSetOrder(1) ) // DC3_FILIAL+DC3_CODPRO+DC3_LOCAL+DC3_ORDEM
			If !(DC3->( dbSeek(xFilial("DC3")+aDados[nX][2]+aDados[nX][1]+aDados[nX][5])))
				RecLock("DC3",.T.)
				DC3->DC3_FILIAL := xFilial("DC3")
				For nY := 1 To Len(aHeaderRes)
					If aHeaderRes[nY][10] != "V"
						Eval(&("{|| DC3->"+aHeaderRes[nY][2]+" := aDados[nX][nY] }"))
					EndIf
				Next nY
				DC3->(MsUnlock())
			EndIf
	
		Next nX
		End Transaction
	Else
		lGerou := .F.
	EndIf
Return

Static Function ValidField()
Local cTpEstr := M->DC3_TPESTR
Local oModelDC3 := FwLoadModel("WMSA030")
Local lRet := .T.
Local cField := SubStr(ReadVar(),4)
Local xValor := &(ReadVar())
Local cModel := Iif(cField == "DC3_REABAS","MdFieldCDC3","MdGridIDC3")

	oModelDC3:SetOperation( MODEL_OPERATION_INSERT )
	oModelDC3:Activate()
	
	If cField $ "DC3_TIPREP|DC3_PERREP|DC3_PERAPM"
		oModelDC3:LoadValue(cModel,"DC3_TPESTR",cTpEstr)
	EndIf

	If !oModelDC3:SetValue(cModel,cField,xValor)
		WmsMessage(oModelDC3:GetErrorMessage()[6],WMSA47001,5 /*MSG_HELP*/)
		lRet := .F.
	EndIf
	oModelDC3:Deactivate()
Return lRet