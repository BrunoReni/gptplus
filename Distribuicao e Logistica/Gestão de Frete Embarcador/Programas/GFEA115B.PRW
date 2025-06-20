#INCLUDE "GFEA115A.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
     
/*-------------------------------------------------------------------
// GFEA115B - Importa��o ConEmb 5.0

000
 |-520 [] (max 200)
    |-521 [Transportadora] (max 5.000)
    |  |-522 [CTRC]
    |     |- 523 [Valores]
    |     |- 524 [Notas] (max 9.999)
    |	  |  ..
    |     |- 525 [Entrega Casada] (max 50)
    |     |  ..
    |     |- 527 [Consignat�rio]
    |-529 [Total CTRCs]
    
aEmitentes
	[1]	Transp - Cod Emitente    
	[2] Transp - CNPJ
	[3] Transp - Nome
	[4]	Emissor NF - Cod Emitente    
	[5] Emissor NF - CNPJ
	[6] Emissor NF - Nome
	[7]	Rem NF - Cod Emitente    
	[8] Rem NF - CNPJ
	[9] Rem NF - Nome
	[10] Dest NF - Cod Emitente    
	[11] Dest NF - CNPJ
	[12] Dest NF - Nome
	
	
aCTRC
	[38] Tipo Imposto [0: Nenhum, 1: ICMS, 2: ISS, 3: ICMS Subs. Tributaria]	
	[39] Tipo de Tributa��o
	[40] Tipo de Servi�o


aValores
	[31] Valor da Carga
	[32] Imposto Retido
	[33] % Imposto Retido

// @author Israel A. Possoli
// @since 03/11/2014
// @version 1.0
//-------------------------------------------------------------------
*/

Function GFEA115B()
	Private cErrosGeral					// Erros -> GFEResult
	Private cErrosCTRC					// Erros de cada Conhecimento
	Private cBuffer						// Conte�do da Linha 
	Private cRegID						// C�digo do registro atual
	Private cGXG_NRIMP
	Private cChaveCTRC 	:= ""			// Chave do Conhecimento do reg 522
	Private nCountNFImp := 0
	Private nCountNF	:= 0
	
	// Arrays com o conte�do dos registros
	Private aEmitentes[12]
	Private aCTRC[40]
	Private aValores[33]
	Private aNota[21]
	Private aNotasCTRC
	
	// Par�metros
	Private cTransIni := MV_PAR01
	Private cTransFim := MV_PAR02
	
	// Cache do tamanho de campos
	Private tGW1_NRDC  := TamSX3("GW1_NRDC")[1]
	Private tGW1_SERDC := TamSX3("GW1_SERDC")[1]
	Private cModoGXG
	Private cCNPJ
	
	cModoGXG := FWModeAccess("GXG",1)
	
	GFELog115:Add("Vers�o EDI: 5.0")
	GFELog115:NewLine()
	
	AddResult(UPPER(cNomeArq) + CHR(13) + CHR(10) + Replicate('-', 50), 0)
	
	While !GFEFile:FEof()
		cBuffer := GFEFile:Line()
		
		If Empty(cBuffer)
			GFEFile:FNext()
			Loop
		EndIf
		
		cRegID := GetStr(cBuffer, 1, 3)
		
		// Leitura da linha corrente
		ReadReg()
		
		GFEFile:FNext()
	EndDo
	
	If !Empty(cBuffer) .AND. lTranspVld
		CreateReg()
	EndIf
	
	PrintErros()
Return .T.


//--------------------------------------------------------------------
// ReadReg - Faz a leitura dos registros de acordo com o ID
//--------------------------------------------------------------------
Static Function ReadReg()

	// --- 521 [Dados Transportadora] -----------------
	If cRegID == "521"
		nCountNFImp := 0
		nCountNF	:= 0
		cErrosCTRC := ""
		cMsgPreVal := ""
		cChaveCTRC := ""

		Reg521()
	EndIf
		
	If lTranspVld
		// --- 522 [Conhecimento] -------------------------
		If cRegID == "522"
			// A cada novo Conhecimento, salva o anterior
			If cChaveCTRC != GetStr(cBuffer, 14, 25)
				If !Empty(cChaveCTRC)
					CreateReg()
				EndIf
				
				cChaveCTRC := GetStr(cBuffer, 14, 25)
			EndIf
		
			aNotasCTRC := {}
			aSize(aNotasCTRC, 0)
			aFill(aCTRC, "")
			aFill(aEmitentes, "")
			
			nCountNFImp	:= 0
			nCountNF  	:= 0
			cErrosCTRC 	:= ""
			cMsgPreVal 	:= ""
			
			Reg522()
			GFELog115:Save()
		EndIf
			
		// --- 523 [Valores do Conhecimento] --------------
		If cRegID == "523"
			Reg523()
		EndIf
		
			
		// --- 524 [Notas do Conhecimento] ----------------
		If cRegID == "524"
			nCountNF++
			Reg524()
			
			If nCountNFImp == 1
				DefCTRC()
			EndIf
		EndIf		
	EndIf
Return


//--------------------------------------------------------------------
// CreateReg - Faz a cria��o das tabela GXG e GXH
//--------------------------------------------------------------------
Static Function CreateReg()
	nCountImpor++
	cGXG_NRIMP := ""

	PreValidacao()
	GFELog115:Save()
	
	CreateGXG()
	CreateGXH()
Return


//--------------------------------------------------------------------
// CreateGXG - Faz a cria��o da tabela GXG de acordo com os dados coletados
//--------------------------------------------------------------------
Static Function CreateGXG()
Local cMarkBr := IIF(IsBlind(), "",oBrowse115:Mark())

	cGXG_NRIMP := SubStr(FWUUIDV4(),1,TamSx3("GXG_NRIMP")[1])
	RecLock("GXG", .T.)
		GXG->GXG_FILIAL := xFilial("GXG")
		GXG->GXG_MARKBR := cMarkBr 
		GXG->GXG_NRIMP  := cGXG_NRIMP
		GXG->GXG_ACAO   := aCTRC[28]
		GXG->GXG_EDINRL := aCTRC[35]
		GXG->GXG_EDILIN := ""
		GXG->GXG_EDIARQ := cNomeArq
		GXG->GXG_DTIMP  := DDATABASE
		GXG->GXG_ALTER  := "2"
		GXG->GXG_USUIMP := cUserName
		GXG->GXG_ORIGEM := "1"

		// GXG_EDISIT  => 1: Importado, 2: Importado com erro, 3: Rejeitado, 4: Processado

		GXG->GXG_FILDOC := aCTRC[1]
		GXG->GXG_CDESP  := aCTRC[36]
		GXG->GXG_EMISDF := aEmitentes[1]
		GXG->GXG_SERDF  := aCTRC[3]
		GXG->GXG_NRDF   := aCTRC[4]
		GXG->GXG_DTEMIS := aCTRC[5]

		GXG->GXG_CDREM  := aEmitentes[7]
		GXG->GXG_CDDEST := aEmitentes[10]
		GXG->GXG_TPDF   := aCTRC[37]
		GXG->GXG_DTENT  := DDATABASE
		GXG->GXG_CDCONS := ""
		GXG->GXG_ORISER := aCTRC[23]
		GXG->GXG_ORINR  := aCTRC[24]
		GXG->GXG_QTDCS  := nCountNFImp

		If aCTRC[38] == "1" 
			GU3->( dbSetOrder(1) )
			GU3->( dbSeek(xfilial("GU3") + aEmitentes[1]) )	
			If GU3->GU3_APUICM == "4" .And. aValores[21] == "1"
				// ICMS - Subst. Tribut�ria
				GXG->GXG_BASIMP := SetField(aValores[22], "GXG_BASIMP")
				GXG->GXG_PCIMP  := SetField(aValores[23], "GXG_PCIMP")
				GXG->GXG_VLIMP  := SetField(aValores[24], "GXG_VLIMP")
			Else 
				// ICMS
				GXG->GXG_BASIMP := SetField(aValores[18], "GXG_BASIMP")
				GXG->GXG_PCIMP  := SetField(aValores[19], "GXG_PCIMP")
				GXG->GXG_VLIMP  := SetField(aValores[20], "GXG_VLIMP")
			EndIf

		ElseIf aCTRC[38] == "2"
			// ISS
			GXG->GXG_BASIMP := SetField(aValores[25], "GXG_BASIMP")
			GXG->GXG_PCIMP  := SetField(aValores[26], "GXG_PCIMP")
			GXG->GXG_VLIMP  := SetField(aValores[27], "GXG_VLIMP")

		ElseIf aCTRC[38] == "3"
			// ICMS - Subst. Tribut�ria
			GXG->GXG_BASIMP := SetField(aValores[22], "GXG_BASIMP")
			GXG->GXG_PCIMP  := SetField(aValores[23], "GXG_PCIMP")
			GXG->GXG_VLIMP  := SetField(aValores[24], "GXG_VLIMP")
		EndIf

		GXG->GXG_TRBIMP := aCTRC[39]

		GXG->GXG_CTE    := aCTRC[19]

		If !Empty(aCTRC[19])
			GXG->GXG_TPCTE := '0'
		Else
			GXG->GXG_TPCTE := ' '
		EndIf

		GXG->GXG_QTVOL  := aValores[2]
		GXG->GXG_PESOR  := SetField(aValores[3], "GXG_PESOR")
		GXG->GXG_PESOC  := SetField(aValores[4], "GXG_PESOC")
		GXG->GXG_FRPESO := SetField(aValores[7], "GXG_FRPESO", .F.)
		GXG->GXG_FRVAL  := SetField(aValores[8], "GXG_FRVAL", .F.)
		GXG->GXG_VLDF   := SetField(aValores[6], "GXG_VLDF")
		GXG->GXG_VLCARG := SetField(aValores[31], "GXG_VLCARG")
		GXG->GXG_TAXAS  := SetField(aValores[10] + aValores[11] + aValores[12] + aValores[14] + aValores[15], "GXG_TAXAS")
		GXG->GXG_PEDAG  := aValores[13]
		GXG->GXG_IMPRET := aValores[32]
		GXG->GXG_PCRET  := aValores[33]

		CheckErros()

		If Empty(cMsgPreVal)
			GXG->GXG_EDISIT := "1"
		Else
			GXG->GXG_EDISIT := "2"
			GXG->GXG_EDIMSG := cMsgPreVal
		EndIf
		If GFXCP12117("GXG_CDTPSE") .And. GXG->GXG_TPDF == '7'
			GXG->GXG_CDTPSE := aCTRC[40]
		EndIf
	GXG->(MsUnlock())
	GFELog115:Add("> N�mero do registro importado: " + cValToChar(cGXG_NRIMP))
Return


//--------------------------------------------------------------------
// CreateGXH - Faz a cria��o da tabela GXH
//--------------------------------------------------------------------
Static Function CreateGXH()
	Local nI
	
	For nI := 1 To Len(aNotasCTRC)
		RecLock("GXH", .T.)
			GXH->GXH_FILIAL	:= xFilial("GXG")
			GXH->GXH_NRIMP	:= cGXG_NRIMP
			GXH->GXH_SEQ		:= StrZero(nI, 5)
			GXH->GXH_FILDC	:= aNotasCTRC[nI, 1]
			GXH->GXH_TPDC		:= aNotasCTRC[nI, 2]
			GXH->GXH_EMISDC	:= aNotasCTRC[nI, 3]
			GXH->GXH_SERDC	:= aNotasCTRC[nI, 4]
			GXH->GXH_NRDC		:= aNotasCTRC[nI, 5]
			GXH->GXH_DANFE	:= aNotasCTRC[nI, 6]
			GXH->GXH_CNPJEM	:= aNotasCTRC[nI, 7]
		MsUnlock()
	Next
Return


//--------------------------------------------------------------------
// PreValidacao - Faz a cria��o das tabela GXG e GXH
//--------------------------------------------------------------------
Static Function PreValidacao()
	// Fecha a se��o de notas ficais
	GFELog115:Add(Replicate(".", 75), 1)
	If Empty(aCTRC[28])
		AddPreValid("A��o do documento EDI n�o foi definida. Verificar registro 522, posi��o 322.", 0)
	Else
		GFELog115:Add("> A��o do EDI.: " + aCTRC[28] + " (I: Incluir, E: Excluir)", 1)
	EndIf
	
	If Empty(aCTRC[5])
		AddPreValid("Data de emiss�o inv�lida.")
	EndIf
	
	If nCountNF == 0
		AddPreValid("Nenhuma nota fiscal encontrada no arquivo EDI para este conhecimento.")
	EndIf
	
	If nCountNFImp == 0
		AddPreValid("Nenhuma nota fiscal foi importada para este conhecimento.")
	EndIf
	
	If Empty(aCTRC[36]) .OR. Empty(aCTRC[38])
		AddPreValid("Esp�cie do conhecimento n�o foi definida. Verifique os par�metros de esp�cie na aba 'Integra��es EDI' nos par�metros do m�dulo.")
	Else
		GFELog115:Add("> Esp�cie.....: " + aCTRC[36], 1)
		GFELog115:Add("> Tipo Imposto: " + aCTRC[38] + " (1: ICMS, 2: ISS, 3: ICMS Subst. Tribut�ria)", 1)
		
		
		// Base ICMS
		If aCTRC[38] == "1"  .and. aCTRC[39] != "2"
			If Empty(aValores[18]) .OR. (Empty(aValores[20]) .AND. aCTRC[39] != "6")  //Outros 
				AddPreValid("Base e/ou valor do ICMS n�o informado no arquivo EDI.")
			Else
				GFELog115:Add("> Base ICMS...: " + cValToChar(aValores[18]), 1)
				GFELog115:Add(">    % ICMS...: " + cValToChar(aValores[19]), 1)
				GFELog115:Add("> Valor ICMS..: " + cValToChar(aValores[20]), 1)
			EndIf
		EndIf
		
		// Base ISS
		If aCTRC[38] == "2"
			If Empty(aValores[25]) .OR. Empty(aValores[27])
				AddPreValid("Base e/ou valor do ISS n�o informada no arquivo EDI.")
			Else
				GFELog115:Add("> Base ISS....: " + cValToChar(aValores[25]), 1)
				GFELog115:Add(">    % ISS....: " + cValToChar(aValores[26]), 1)
				GFELog115:Add("> Valor ISS...: " + cValToChar(aValores[27]), 1)
			EndIf
		EndIf
		
		// Base ICMS Subst. Tribut�ria
		If aCTRC[38] == "3"
			If Empty(aValores[22]) .OR. Empty(aValores[24])
				AddPreValid("Base e/ou valor do ICMS de Subs. Tributaria n�o informado no arquivo EDI.")
			Else
				GFELog115:Add("> Base ICMS ST: " + cValToChar(aValores[22]), 1)
				GFELog115:Add(">    % ICMS ST: " + cValToChar(aValores[23]), 1)
				GFELog115:Add("> Val. ICMS ST: " + cValToChar(aValores[24]), 1)
			EndIf
		EndIf
		
		// CT-e
		GVT->( dbSetOrder(1) )
		If GVT->( dbSeek(xFilial("GVT") + aCTRC[36]) )
			If GVT->GVT_CHVCTE == "3" .And. !Empty(aCTRC[19])
				AddPreValid("Esp�cie do conhecimento parametrizada para n�o informar a chave do CT-e.", 0)
			EndIf
		EndIf
	EndIf
	
	If Empty(aCTRC[37])
		AddPreValid("Tipo do Documento de Frete n�o foi definido.", 1)
		GFELog115:Add("> Tipo do Conhecimento no arquivo EDI: " + aCTRC[26], 1)
	Else
		GFELog115:Add("> Tipo Doc.Frt: " + aCTRC[37], 1)
	EndIf
	
	If Empty(aCTRC[39])
		AddPreValid("Tipo de Tributa��o n�o definida.", 1)
	Else
		GFELog115:Add("> Tipo Tribut.: " + aCTRC[39], 1)
	EndIf

Return


//--------------------------------------------------------------------
// DefCTRC - Define informa��es do Conhecimento
// Requerimentos: os Arrays aCTRC, aValores e aNotas preenchidos
//		 Pelo menos uma nota fiscal processada (reg 524) 
//--------------------------------------------------------------------
Static Function DefCTRC()
	Local cOrigem
	Local cDestin
	Local nICMS
	Local nIss
	Local cESPDF
	local aDados 	:= {}
	lOCAL nISX5 	:= 0	
	
	GW1->( dbSetOrder(1) ) // GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC
	If GW1->( dbSeek(aNotasCTRC[1, 1] + aNotasCTRC[1, 2] + aNotasCTRC[1, 3] + aNotasCTRC[1, 4] + aNotasCTRC[1, 5]) )
	
		If !Empty(aEmitentes[10]) .and. aEmitentes[10] != GW1->GW1_CDDEST 
			GFELog115:Add(" * Destinat�rio do CTRC diferente da Nota Fiscal. CTRC: " + aEmitentes[10] + ", Nota Fiscal: " + GW1->GW1_CDDEST)
		EndIf
	
		aEmitentes[7]  := GW1->GW1_CDREM
		aEmitentes[9]  := POSICIONE("GU3", 1, xFilial("GU3") + GW1->GW1_CDREM, "GU3_NMEMIT")
		aEmitentes[10] := GW1->GW1_CDDEST
		aEmitentes[12] := POSICIONE("GU3", 1, xFilial("GU3") + GW1->GW1_CDDEST, "GU3_NMEMIT")
		
		cOrigem := Posicione("GU3", 1, xFilial("GU3") + GW1->GW1_CDREM, "GU3_NRCID")
		cDestin := Posicione("GU3", 1, xFilial("GU3") + GW1->GW1_CDDEST, "GU3_NRCID")
		
		nICMS := aValores[20]
		nIss  := aValores[25]   //base de Iss informada no arquivo

		If nICMS == 0
			nICMS := aValores[24]
		EndIf
		
		//-----------------------------------------------
		// Tipo Imposto e Esp�cie
        If nIss > 0 .OR. cOrigem == cDestin 
        	aCTRC[38] := "2"	
			cESPDF := SuperGetMv("MV_ESPDF2",,"")	// ISS			
		Else
			If aValores[21] == "1"    //Indica que � ICMS ST 
				GU3->( dbSetOrder(1) )
				GU3->( dbSeek(xfilial("GU3") + aEmitentes[1]) )	
				If GU3->GU3_APUICM == "4"
					aCTRC[38] := "1"
					cESPDF := SuperGetMv("MV_ESPDF1",,"")	// ICMS
				Else 
					aCTRC[38] := "3" // ICMS Subs. Tribut�ria 	
					cESPDF := SuperGetMv("MV_ESPDF1",,"")	// ICMS
				EndIf		
			Else
				aCTRC[38] := "1" // ICMS
				cESPDF := SuperGetMv("MV_ESPDF1",,"")	// ICMS				
			EndIf
			If !Empty(aCTRC[19])     //tem chave de CTE
				cESPDF := SuperGetMv("MV_ESPDF3",,"")	// ICMS CT-e				
			EndIf
		EndIf
		
		aCTRC[36] := cESPDF
		//-----------------------------------------------
		
		//-----------------------------------------------
		// ICMS	Retido
		If aValores[21] == "1"	// Substitui��o Tribut�ria
			GW8->( dbSetOrder(1) )
			If GW8->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )		
				aIcms := GFEFnIcms(aEmitentes[1], GW1->GW1_CDREM, GW1->GW1_CDDEST, cOrigem, cDestin, GW1->GW1_USO, GW8->GW8_TPITEM, GW8->GW8_CDCLFR, GW1->GW1_ICMSDC, Posicione("GWN", 1, GW1->GW1_FILIAL + GW1->GW1_NRROM, "GWN_CDTPOP"))
			
				If aIcms[2] == "7" .And. Empty(aValores[24]) .Or. aCTRC[38] == "1" .And. GU3->GU3_APUICM == "4"	// Presumido
					aValores[32] := aValores[20] * (1 - (aIcms[4] / 100))
					aValores[33]  := aIcms[4]
				ElseIf aIcms[2] == "7"
				    aValores[32] := aValores[24]
				    aValores[33]  := aIcms[4]				
				ElseIf aIcms[2] == "3"		// Subs-tribut�ria
					aValores[32] := aValores[24]
					aValores[33] := 0
					
				EndIf
			EndIf
		EndIf
		//-----------------------------------------------
			
	Else
		AddPreValid("Erro ao buscar Documento de Carga. Filial: " + aNotasCTRC[1, 1] + ", Tipo: " + aNotasCTRC[1, 2] + ", Emissor: " + aNotasCTRC[1, 3] + ", S�rie: " + aNotasCTRC[1, 4] + ", N�mero: " + aNotasCTRC[1, 5])
		Return
	EndIf
	
	//-----------------------------------------------
	// Tipo Conhecimento
	// GW3_TPDF	=>	1: Normal, 2: Complementar Valor, 3: Complementar Imposto, 4: Reentrega, 5: Devolucao, 6: Redespacho, 7: Servico
	If aCTRC[26] $ "N,E,S,T"
		aCTRC[37] := "1"
		
		GWU->( DbSetOrder(1) )
		GWU->( DbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )

		While !GWU->( Eof() ) .AND. ;
			   GWU->GWU_FILIAL == GW1->GW1_FILIAL .AND. ;
			   GWU->GWU_CDTPDC == GW1->GW1_CDTPDC .And. ;
			   GWU->GWU_EMISDC == GW1->GW1_EMISDC .And. GWU->GWU_SERDC == GW1->GW1_SERDC .And. ;
			   GWU->GWU_NRDC   == GW1->GW1_NRDC

			If AllTrim(GWU->GWU_CDTRP) == AllTrim(aEmitentes[1])
				If GWU->GWU_SEQ != "01"
   					aCTRC[37] := "6"
   				EndIf
   				Exit
			EndIf
			
	   		GWU->( DbSkip() )
		EndDo			
	ElseIf aCTRC[26] $ "R"
		aCTRC[37] := "4"
		
	ElseIf aCTRC[26] $ "D,O"
		aCTRC[37] := "5"
		
	ElseIf aCTRC[26] $ "C,W,X,Y,Z"
		If aValores[6] != 0
			aCTRC[37] := "2"
		Else
			aCTRC[37] := "3"
		EndIf
		
	EndIf

	If Alltrim(aCTRC[26]) $ "M;P" // Atribui diretamente o tipo 7 para os dados de tipo de documento de frete P ou M para nao depender de existencia de SX5 com tabela GU
		aCTRC[37] := "7"
	EndIf

	aDados:= FWGetSX5("GU")	
	For nISX5 := 1 To Len(aDados)		
		If Alltrim(aDados[nISX5][3]) == Alltrim(aCTRC[26])//S� dever� encontrar o registro se cTpDf = "M" ou "P"
			aCTRC[37] := "7"
			aCTRC[40] := aDados[nISX5][4]
			Exit	
		EndIf	
	Next nISX5	
	//-----------------------------------------------
	
	
	//-----------------------------------------------
	// Tipo de Tributa��o
	// 1: Tributado, 2: Isento/N�o-tributado, 3: Subs Tribut�ria, 4: Diferido, 5: Reduzido, 6: Outros, 7: Presumido
	If aCTRC[38] == "2"			// ISS
		If aValores[27] > 0
			aCTRC[39] := "6"
		Else
			aCTRC[39] := "2"
		EndIf
	ElseIf aCTRC[38] == "3"		// ICMS Subst. Tribut�ria
		aCTRC[39] := "3"
	Else
		GU3->( dbSetOrder(1) )
		If GU3->( dbSeek(xfilial("GU3") + aEmitentes[1]) )
			If aValores[20] > 0		// Valor Imposto
				If GU3->GU3_APUICM == "1"
					aCTRC[39] := "1"
					
				ElseIf GU3->GU3_APUICM == "2"
					aCTRC[39] := "3"
					
				ElseIf GU3->GU3_APUICM == "3"
					aCTRC[39] := "4"
					
				ElseIf GU3->GU3_APUICM == "4"
					aCTRC[39] := "7"
					
				EndIf
			ElseIf aValores[18] > 0	// Base Imposto
				aCTRC[39] := "6"
			ElseIf aValores[18] == 0 .AND. GU3->GU3_TPTRIB == "2"  //Simples Nacional	
				aCTRC[39]    := "6"
				aValores[18] := aValores[6]					   	   	    
			Else
				aCTRC[39] := "2"
			EndIf
		EndIf
	EndIf
	//-----------------------------------------------
Return


//--------------------------------------------------------------------
// Reg521 - Dados da Transportadora
//--------------------------------------------------------------------
Static Function Reg521()
	cErrosGeral	:= ""
	lTranspVld 	:= .T.
	cCNPJ 	    := GetStr(cBuffer, 4, 14)		// 2. CNPJ da Transportadora que emite a fatura/recebe o frete

	GU3->( dbSetOrder(11) )
	If GU3->( dbSeek(xFilial("GU3") + cCNPJ) )
		GFELog115:Add("> Transportador Faturamento: " + AllTrim(GU3->GU3_CDEMIT) + " - " + AllTrim(GU3->GU3_NMEMIT))

		If GU3->GU3_CDEMIT < cTransIni .OR. GU3->GU3_CDEMIT > cTransFim
			lTranspVld := .F.
		EndIf
		
	Else
		AddPreValid("Transportador n�o encontrado com o CNPJ: " + cCNPJ + ".")
		lTranspVld := .F.
	EndIf
	
Return


//--------------------------------------------------------------------
// Reg522 - Conhecimentos Embarcados
// aCTRC
//		 1: Filial do CTRC
//		 2: Entrega/Devolu��o [S: Sa�da, E: Entrada, D: Devolu��o]
//	 	..
//		35: Linha atual
//		36: Esp�cie
//		37: Tipo Doc. Frete
//		38: Tipo Imposto [0: Nenhum, 1: ICMS, 2: ISS, 3: ICMS Subs. Tributaria]
//
// aEmitentes
//	 [1] Transp - Cod Emitente    
//	 [2] Transp - CNPJ
//	 [3] Transp - Nome
//	 [4] Emissor NF - Cod Emitente    
//	 [5] Emissor NF - CNPJ
//	 [6] Emissor NF - Nime
//	 [7] Rem NF - Cod Emitente    
//	 [8] Rem NF - CNPJ
//	 [9] Rem NF - Nime
//	 [10] Dest NF - Cod Emitente    
//	 [11] Dest NF - CNPJ
//	 [12] Dest NF - Nime
//--------------------------------------------------------------------
Static Function Reg522()
	//Se for exclusivo, deve-se usar a filial escolhida em tela
	If cModoGXG == "E"
		aCTRC[1] := cFilAnt
	Else
		aCTRC[1] := ""
	EndIf			

	aCTRC[2]	:= "0"							// [0: Indefinido, E: Entrega, D: Devolu��o]
	
	aCTRC[3]	:= GetStr(cBuffer,  14,  5)		//  3. S�rie do Conhecimento
	aCTRC[4]	:= GetStr(cBuffer,  19, 12)		//  4. N�mero do Conhecimento
	aCTRC[5]	:= GetDate(cBuffer,  31,  8)	//  5. Data de Emiss�o do Conhecimento
	aCTRC[6]	:= GetStr(cBuffer,  39,  1)		//  6. Condi��o de Frete
	aCTRC[7]	:= GetStr(cBuffer,  40, 14)		//  7. CNPJ do Local/Filial emissora do Conhecimento
	aCTRC[8]	:= GetStr(cBuffer,  54, 14)		//  8. CNPJ do Emissor da Nota Fiscal [Entrega: Embarcador, Devolu��o: Destinat�rio]
	aCTRC[9]	:= GetStr(cBuffer,  68, 14)		//  9. CNPJ do Destino do Conhecimento de Devolu��o
	aCTRC[10]	:= GetStr(cBuffer,  82, 14)		// 10. CNPJ do Destinat�rio das notas do Conhecimento (Sa�da)
	aCTRC[11]	:= GetStr(cBuffer,  96, 14)		// 11. CNPJ do Consignat�rio
	aCTRC[12]	:= GetStr(cBuffer, 110,  5)		// 12. C�digo Fiscal da Natureza da Opera��o (CFOP)
	aCTRC[13]	:= GetStr(cBuffer, 115,  9)		// 13. Placa do Ve�culo
	aCTRC[14]	:= GetStr(cBuffer, 124, 20)		// 14. N�mero do Romaneio
	aCTRC[15]	:= GetStr(cBuffer, 144, 20)		// 15. N�mero SAP
	aCTRC[16]	:= GetStr(cBuffer, 164, 20)		// 16. Outro Nr SAP
	aCTRC[17]	:= GetStr(cBuffer, 184, 20)		// 17. Outro Nr SAP
	aCTRC[18]	:= GetStr(cBuffer, 204, 15)		// 18. Identifica��o do Documento de autoriza��o de carregamento e transporte da transportadora
	aCTRC[19]	:= GetStr(cBuffer, 219, 45)		// 19. CTE - Chave de Consulta com DV
	aCTRC[20]	:= GetStr(cBuffer, 264, 15)		// 20. Protocolo do CTRC na SEFAZ (se NF-e)
	aCTRC[21]	:= GetStr(cBuffer, 279,  9)		// 21. C�digo num�rico da chave de acesso na SEFAZ (se NF-e)
	aCTRC[22]	:= GetStr(cBuffer, 288, 10)		// 22. Filial emissora do Conhecimento originador do CTRC - Transportadora Contratante
	aCTRC[23]	:= GetStr(cBuffer, 298,  5)		// 23. S�rie do Conhecimento originador do CTRC - Transportadora Contratante
	aCTRC[24]	:= GetStr(cBuffer, 303, 12)		// 24. N�mero do Conhecimento originador do CTRC - Transportadora Contratante
	aCTRC[25]	:= GetStr(cBuffer, 315,  5)		// 25. Tipo do meio de transporte
	aCTRC[26]	:= GetStr(cBuffer, 320,  1)		// 26. Tipo do Conhecimento
	aCTRC[27]	:= GetStr(cBuffer, 321,  1)		// 27. Tipo de Frete (1: Normal, 2: Exporta��o, 3: Importa��o)
	aCTRC[28]	:= GetStr(cBuffer, 322,  1)		// 28. A��o do Documento (I: Incluir, E: Excluir)
	aCTRC[29]	:= GetStr(cBuffer, 323,  1)		// 29. C�lculo de Frete diferenciado (S: Sim, N: N�o)
	aCTRC[30]	:= GetStr(cBuffer, 324, 10)		// 30. Tabela de Frete
	aCTRC[31]	:= GetStr(cBuffer, 334,  1)		// 31. Plano de Carga R�pida (S: Sim, N: N�o)
	aCTRC[32]	:= GetStr(cBuffer, 335,  2)		// 32. UF do Embarcador - Local de Coleta
	aCTRC[33]	:= GetStr(cBuffer, 337,  2)		// 33. UF do unidade emissora do conhecimento
	aCTRC[34]	:= GetStr(cBuffer, 339,  2)		// 34. UF do destinat�rio/local de entrega da mercadoria/nota fiscal
	
	aCTRC[35]	:= GFEFile:nLinAtual			// Linha atual
	aCTRC[38]	:= "0"
	
	GFELog115:NewLine()
	GFELog115:Add("S�rie: " + aCTRC[3] + ", N�mero: " + aCTRC[4], 0)
	

	//--------------------------------------------------------
	// CNPJ x Emitentes
	
	// Transportador
	If !Empty(GetEmitCNPJ(aCTRC[7], .T.))
		aEmitentes[1] := AllTrim(GU3->GU3_CDEMIT)
		aEmitentes[2] := aCTRC[7]
		aEmitentes[3] := AllTrim(GU3->GU3_NMEMIT)	
		
		GFELog115:Add("> Transportador............: " + AllTrim(GU3->GU3_CDEMIT) + " - " + AllTrim(GU3->GU3_NMEMIT))
	Else
		AddPreValid("Emitente n�o encontrado com o CNPJ do emissor do conhecimento: " + aCTRC[7] + ".", 1)
	EndIf
	
	// Destinat�rio
	If !Empty(GetEmitCNPJ(aCTRC[10]))
		aEmitentes[10] := GU3->GU3_CDEMIT
		aEmitentes[11] := aCTRC[10]
		aEmitentes[12] := GU3->GU3_NMEMIT
			
		If GU3->GU3_EMFIL == "1"
			GFELog115:Add("> Destinat�rio Nota Fiscal.: " + AllTrim(GU3->GU3_CDEMIT) + " - " + AllTrim(GU3->GU3_NMEMIT) + " [FILIAL]")
		Else
			GFELog115:Add("> Destinat�rio Nota Fiscal.: " + AllTrim(GU3->GU3_CDEMIT) + " - " + AllTrim(GU3->GU3_NMEMIT) + " [CLIENTE/FORNECEDOR]")
		EndIf
	EndIf
	//--------------------------------------------------------
	
	AddResult("> S�rie: " + aCTRC[3] + ", N�mero: " + aCTRC[4], 0)
	
Return .T.


//--------------------------------------------------------------------
// Reg523 -  Valores do Conhecimento
//--------------------------------------------------------------------
Static Function Reg523()
	aFill(aValores, 0)
	
	aValores[2]		:= GetInt(cBuffer,   4,  6, 2)		//  2. Quantidade total de Volumes/Embalagens
	aValores[3]		:= GetInt(cBuffer,  12,  6, 3)		//  3. Peso Total Transportado (Peso Bruto)
	aValores[4]		:= GetInt(cBuffer,  21,  6, 4)		//  4. Peso Total Cubado
	aValores[5]		:= GetInt(cBuffer,  31,  6, 4)		//  5. Peso Densidade
	aValores[6]		:= GetInt(cBuffer,  41, 13, 2)		//  6. Valor total do frete
	aValores[7]		:= GetInt(cBuffer,  56, 13, 2)		//  7. Valor do Frete por Peso/Volume
	aValores[8]		:= GetInt(cBuffer,  71, 13, 2)		//  8. Frete Valor
	aValores[9]		:= GetInt(cBuffer,  86, 13, 2)		//  9. Frete Ad Valorem
	aValores[10]	:= GetInt(cBuffer, 101, 13, 2)		// 10. Valor SEC/CAT
	aValores[11]	:= GetInt(cBuffer, 116, 13, 2)		// 11. Valor ITR
	aValores[12]	:= GetInt(cBuffer, 131, 13, 2)		// 12. Valor do Despacho
	aValores[13]	:= GetInt(cBuffer, 146, 13, 2)		// 13. Valor do Ped�gio
	aValores[14]	:= GetInt(cBuffer, 161, 13, 2)		// 14. Valor ADEME/GRIS
	aValores[15]	:= GetInt(cBuffer, 176, 13, 2)		// 15. Valor Total de Despesas Extras/Adicionais
	aValores[16]	:= GetInt(cBuffer, 191, 13, 2)		// 16. Valor do Desconto ou Acr�scimo
	aValores[17]	:= GetStr(cBuffer, 206, 1)			// 17. Indicador de desconto/Acr�scimo [A: Acr�scimo, D: Desconto, N: Normal]
	
	// ICMS
	aValores[18]	:= GetInt(cBuffer, 207, 13, 2)		// 18. Base ICMS
	aValores[19]	:= GetInt(cBuffer, 222,  3, 2)		// 19. % ICMS
	aValores[20]	:= GetInt(cBuffer, 227, 13, 2)		// 20. Valor ICMS
	
	// ICMS - Subst. Tribut�ria
	aValores[21]	:= GetStr(cBuffer, 242, 1)			// 21. Substitui��o Tribut�ria? [1: Sim, 2: N�o, 3: Isento]
	aValores[22]	:= GetInt(cBuffer, 243, 13, 2)		// 22. Base ICMS - Subst. Tribut�ria
	aValores[23]	:= GetInt(cBuffer, 258,  3, 2)		// 23. % ICMS - Subst. Tribut�ria
	aValores[24]	:= GetInt(cBuffer, 263, 13, 2)		// 24. Valor ICMS - Subst. Tribut�ria
	
	// ISS
	aValores[25]	:= GetInt(cBuffer, 278, 13, 2)		// 25. Base ISS
	aValores[26]	:= GetInt(cBuffer, 293,  3, 2)		// 26. % ISS
	aValores[27]	:= GetInt(cBuffer, 298, 13, 2)		// 27. Valor ISS
	
	aValores[28]	:= GetInt(cBuffer, 313, 13, 2)		// 28. Valor do IR
	aValores[29]	:= GetInt(cBuffer, 328, 3)			// 29. Direito Fiscal  [IC3 : Exporta��o, Z23 : Com Subst. Tribut�ria, IC0 : Sem Subst. Tribut�ria]
	aValores[30]	:= GetInt(cBuffer, 331, 4)			// 30. Tipo de Imposto [ICM3: Exporta��o, ICM3: Com Subst. Tribut�ria, ICM1: Sem Subst. Tribut�ria]

Return .T.


//--------------------------------------------------------------------
// Reg524 - Nota Fiscal
//--------------------------------------------------------------------
Static Function Reg524()
	aFill(aNota, "")
	
	
	aNota[2]	:= GetStr(cBuffer,  4, 14)			// 2. CNPJ do Emissor
	aNota[3]	:= GetStr(cBuffer,  18, 9)			// 3. N�mero da NF
	aNota[4]	:= GetStr(cBuffer,  27, 3)			// 4. S�rie da NF
	aNota[5]	:= GetDate(cBuffer, 30, 8)			// 5. Data de Emiss�o
	
	aValores[31] += GetInt(cBuffer, 38, 13, 2)		// 6. Valor da Nota Fiscal
	
	AddNota()

Return .T.


//--------------------------------------------------------------------
// AddNota - Adiciona a nota atual no Array de notas
// Realiza pr�-valida��es
//--------------------------------------------------------------------
Static Function AddNota()
	Local cCdEmissor
	Local cNrDocCarga
	Local nNrNF
	Local aRetDocTrechoPago[2]
	Local lFindGW1 := .F.
	Local nI
	Local cDsFilial := ''
	
	nNrNF  := Str(Val(aNota[3]))

	//TWDTH4 - Localiza o Documento de Carga, altera��o para localizar documentos quando 
	//existem filiais com o mesmo CNPJ.

	GFELog115:Add("- NOTAS FISCAIS" + Replicate(".", 60), 1)

	GU3->( dbSetOrder(11) )
	If GU3->( dbSeek(xFilial("GU3") + aNota[2]) )
		While !GU3->(Eof()) .And. GU3->GU3_FILIAL == xFilial("GU3") .And. AllTrim(GU3->GU3_IDFED) ==  AllTrim(aNota[2])
			If GU3->GU3_SIT == "1"
				cNrDocCarga := AllTrim(cValToChar(nNrNF))
				For nI := Len(cNrDocCarga) To 9
					aRetDocTrechoPago := BuscaDocTrechoPago(GU3->GU3_CDEMIT, aNota[4], GetNrDc(cNrDocCarga, nI), If( xFilial("GXG") != "", xFilial("GXG"), "" ))
					If aRetDocTrechoPago[1]
						lFindGW1 := .T.
						cCdEmissor := GU3->GU3_CDEMIT
						aCTRC[1] := aRetDocTrechoPago[2]
						Exit			
					EndIf	

					If lFindGW1
						GFELog115:AddDebug("# Tamanho: " + cValToChar(nI) + cDsFilial + ", N�mero: " + GetNrDc(cNrDocCarga, nI) + " [Encontrado]", 5)
					Else
						GFELog115:AddDebug("# Tamanho: " + cValToChar(nI) + cDsFilial + ", N�mero: " + GetNrDc(cNrDocCarga, nI), 5)
					EndIf
				Next
			EndIf
		   GU3->(dbSkip())
		EndDo

		// Emissor Nota

		//Se achar a nota via buscadotrechopago, usa as informa��es do emitente para definir aCTRC[2]
		//Se n�o achar a nota, l� e usa as informa��es do primeiro emitente buscando por CNPJ  
		If !lFindGW1   
		   GetEmitCNPJ(aCTRC[8])	
    	EndIf
       
    	If GU3->GU3_EMFIL == "1"
			aCTRC[2] := "E"
		    GFELog115:Add("> Emissor Nota Fiscal......: " + AllTrim(GU3->GU3_CDEMIT) + " - " + AllTrim(GU3->GU3_NMEMIT) + " [FILIAL]")
		Else
			aCTRC[2] := "D"
			GFELog115:Add("> Emissor Nota Fiscal......: " + AllTrim(GU3->GU3_CDEMIT) + " - " + AllTrim(GU3->GU3_NMEMIT) + " [CLIENTE/FORNECEDOR]")
        EndIf
		    
	    // Filial do Conhecimento
	    If Empty(aCTRC[1])
	           aCTRC[1] := GFEA115BF(aCTRC[8], .F.)
	           If !Empty(aCTRC[1])
	                  aCTRC[2] := "S"
	                  GFELog115:Add("> Filial.......: " + aCTRC[1] + " [CNPJ do Emissor]", 1)
	                  GFELog115:Add("> CNPJ Filial..: " + aCTRC[8], 1)
	           EndIf
	    EndIf
	    If Empty(aCTRC[1])
	           aCTRC[1] := GFEA115BF(aCTRC[10], .T.)
	           If !Empty(aCTRC[1])
	                  aCTRC[2] := "E"
	                  GFELog115:Add("> Filial.......: " + aCTRC[1] + " [CNPJ do Destinat�rio]", 1)
	                  GFELog115:Add("> CNPJ Filial..: " + aCTRC[10], 1)
	           EndIf
	    EndIf
	    
	    If Empty(aCTRC[1])
	           aCTRC[1] := GFEA115BF(aCTRC[9], .T.)
	           If !Empty(aCTRC[1])
	                  aCTRC[2] := "D"
	                  GFELog115:Add("> Filial.......: " + aCTRC[1] + " [CNPJ do Destinat�rio de devolu��o]", 1)
	                  GFELog115:Add("> CNPJ Filial..: " + aCTRC[9], 1)
	           EndIf
	   EndIf
	EndIf
	
	If lFindGW1
		nCountNFImp++
		GFELog115:Add(">" + cDsFilial + ", CNPJ Emissor: " + GW1->GW1_EMISDC + ", S�rie: " + GW1->GW1_SERDC + ", N�mero: " + GW1->GW1_NRDC, 3)
		aADD(aNotasCTRC, {GW1->GW1_FILIAL, GW1->GW1_CDTPDC, GW1->GW1_EMISDC, GW1->GW1_SERDC, GW1->GW1_NRDC, GW1->GW1_DANFE, aNota[2]})
	Else
		AddPreValid("Documento de carga n�o encontrado ou n�o possui trecho pago com transportador informado." + cDsFilial + ", Emissor: " + AllTrim(cCdEmissor) + ", S�rie: " + aNota[4] + ", N�mero: " + aNota[3], 3)
		aADD(aNotasCTRC, {xFilial("GXH"), "", "", aNota[4], aNota[3], "", aNota[2]})
	EndIf
	//--------------------------------------------------------
	
Return



//--------------------------------------------------------------------
// GetEmitCNPJ - Retorna o c�digo do emitente pelo CNPJ
//--------------------------------------------------------------------
Static Function GetEmitCNPJ(cCNPJ, lEmit)
	Local cRet 	    := ""
	Local cAliasGU3 := Nil
	Local cSplitCGC := SubStr(cCNPJ, 4, 11)

	Default lEmit := .F.

	// Procura por CNPJ ou suprime os 3 primeiros d�gitos para os casos de CPF com 0 � esquerda.
	If !Empty(cCNPJ)
		If lEmit
			cAliasGU3 := GetNextAlias()
			BeginSQL Alias cAliasGU3
				SELECT GU3.R_E_C_N_O_ AS RECNOGU3
				FROM %Table:GU3% GU3
				WHERE GU3.GU3_FILIAL = %xFilial:GU3%
				AND ( GU3.GU3_IDFED = %Exp:cCNPJ% OR GU3.GU3_IDFED = %Exp:cSplitCGC% )
				AND GU3.GU3_TRANSP = '1'
				AND GU3.%NotDel%
			EndSQL
			If (cAliasGU3)->(!Eof())
				GU3->(DbGoTo((cAliasGU3)->RECNOGU3))
				cRet := GU3->GU3_CDEMIT
			EndIf
			(cAliasGU3)->(dbCloseArea())
		Else
			GU3->( dbSetOrder(11) )
			If GU3->( dbSeek(xFilial("GU3") + cCNPJ) ) .Or. GU3->( dbSeek(xFilial("GU3") + SubStr(cCNPJ, 4, 11)) )	
				cRet := GU3->GU3_CDEMIT
			EndIf
		EndIf
	EndIf

Return cRet


//--------------------------------------------------------------------
// CheckErros - Verifica os erros encontrados para o CTRC atual
//--------------------------------------------------------------------
Static Function CheckErros()
	Local cCab := ""
	If !Empty(cErrosCTRC)
		If !Empty(aEmitentes[1])
			cCab := "Transp: " + aEmitentes[1] + " - " + aEmitentes[3]
		EndIf
		
		If !Empty(aCTRC[4])
			If !Empty(cCab)
				cCab += ", "
			EndIf
			cCab += "S�rie: " + aCTRC[3] + ", N�mero: " + aCTRC[4]
		EndIf
		
		If !Empty(cCab)
			cErrosCTRC = cCab + CHR(13) + CHR(10) + cErrosCTRC + CHR(13) + CHR(10)
		EndIf
		
		cErrosGeral += cErrosCTRC
		cErrosCTRC := ""
	EndIf
Return


//--------------------------------------------------------------------
// PrintErros - Adiciona os erros encontrados na tela de resultado final
//--------------------------------------------------------------------
Static Function PrintErros()
	If !Empty(cErrosGeral)
		cErrosGeral = "ARQUIVO: " + UPPER(cNomeArq) + CHR(13) + CHR(10) + ;
					   Replicate('-', 50) + CHR(13) + CHR(10) + ;
					   cErrosGeral
		// GFEResult:AddPreValid("> Filial: " + AllTrim((cAliasSQL)->GWU_FILIAL) + ", Tipo Doc: " + AllTrim((cAliasSQL)->GWU_CDTPDC) + ", Emissor: " + AllTrim((cAliasSQL)->GWU_EMISDC) + ", S�rie: " + AllTrim((cAliasSQL)->GWU_SERDC) + ", N�mero: " + AllTrim((cAliasSQL)->GWU_NRDC))
		GFEResult:AddErro(cErrosGeral)
		cErrosGeral := ""
	Else
		If !Empty(cErrosCTRC)
			// Retira espa�os das mensagens
			cErrosCTRC := AllTrim(cErrosCTRC)
			cErrosCTRC := StrTran(cErrosCTRC, CHR(13) + CHR(10) + " ", CHR(13) + CHR(10))
			cErrosCTRC := StrTran(cErrosCTRC, CHR(13) + CHR(10) + " ", CHR(13) + CHR(10))
			
			GFEResult:AddErro(cErrosCTRC)
		EndIf
	EndIf
Return


//--------------------------------------------------------------------
// AddResult - Adiciona informa��es na tela de resultados
//--------------------------------------------------------------------
Static Function AddResult(cMsg, nIdent, lAddLog)
	Default nIdent := 4
	Default lAddLog := .F.
	
	GFEResult:Add(cMsg, nIdent)
	
	If lAddLog
		GFELog115:Add(cMsg, nIdent)
	EndIf
Return


//--------------------------------------------------------------------
// AddPreValid - Inclui erros de pr�-valida��o no registro GXG
//				 Valida��es que n�o impedem a importa��o
//		Exemplo: Data de emiss�o n�o informada
//--------------------------------------------------------------------
Static Function AddPreValid(cMsg, nIdent)
	Default nIdent := 1
	
	cMsgPreVal += "- " + cMsg + CHR(13) + CHR(10)
	
	cErrosCTRC += "  ** " + cMsg + CHR(13) + CHR(10)
	
	GFELog115:Add("** " + cMsg, nIdent)
Return

//--------------------------------------------------------------------
// SetField - Formata um campo de acordo com sua Picture
//--------------------------------------------------------------------
Static Function SetField(nValor, cCampo, lValid)
	Local cValor
	Local nRet
	Local aTamSX3 := TamSX3(cCampo)
	Default lValid := .T.
	
	cValor := cValToChar(Round(nValor, 0))
	cValor := StrTran(cValor, ".", "")
	cValor := StrTran(cValor, ",", "")
	
	If aTamSX3[2] > 0
		cValor := AllTrim(Transform(nValor, Replicate("9", aTamSX3[1]) + "." + Replicate("9", aTamSX3[2])))
	Else
		cValor := AllTrim(Transform(nValor, Replicate("9", aTamSX3[1])))
	EndIf
	
	If Len(cValor) > aTamSX3[1]
		If lValid
			AddPreValid("Erro no campo: " + cCampo + ". Valor '" + cValToChar(nValor) + "' com formato inv�lido ou n�o suportado.")
		EndIf
		GFELog115:Add("# Campo: " + cCampo + ", Tamanho: " + cValToChar(aTamSX3[1]) + "." + cValToChar(aTamSX3[2]) + ", Valor: " + cValToChar(nValor), 1)
		
		Return(0)
	EndIf	
	
	nRet   := Val(cValor)
Return(nRet)

//--------------------------------------------------------------------
// GetNrDc - Retorna o N�mero do Documento de carga formatado
//--------------------------------------------------------------------
Static Function GetNrDc(cNrDc, nTamanho)
	Local cRet
	
	cRet := AllTrim(cNrDc)
	
	If nTamanho - Len(cRet) > 0
		cRet := Replicate("0", nTamanho - Len(cRet)) + cRet
	EndIf
	
	cRet := PadR(cRet, tGW1_NRDC)

Return(cRet)


//--------------------------------------------------------------------
// GetStr - Extrai parte de uma String
//--------------------------------------------------------------------
Static Function GetStr(cBuffer, nPos, nTamanho)
	Local cRet := ""
	
	If nPos + nTamanho > Len(cBuffer)
		cRet := SubStr(cBuffer, nPos)
	Else
		cRet := SubStr(cBuffer, nPos, nTamanho)
	EndIf
	
	cRet := AllTrim(Upper(cRet))

Return(cRet)


//--------------------------------------------------------------------
// GetInt - Extrai parte de uma String convertendo para Inteiro
//--------------------------------------------------------------------
Static Function GetInt(cBuffer, nPos, nTamanho, nDec)
	Local nRet
	Local cStr
	Default nDec := 0
	
	cStr := GetStr(cBuffer, nPos, nTamanho)
	
	If nDec > 0
		cStr += "." + GetStr(cBuffer, nPos + nTamanho, nDec)
	EndIf
	
	nRet := Val(cStr)
Return(nRet)


//--------------------------------------------------------------------
// GetDate - Extrai parte de uma String convertendo para Data
//--------------------------------------------------------------------
Static Function GetDate(cBuffer, nPos, nTamanho)
	Local dRet	
	Local cStr
	
	If nTamanho == 8
		cStr := GetStr(cBuffer, nPos + 4, 4) + GetStr(cBuffer, nPos + 2, 2) + GetStr(cBuffer, nPos, 2)
	EndIf
	
	dRet := SToD(cStr)
	
Return(dRet)
