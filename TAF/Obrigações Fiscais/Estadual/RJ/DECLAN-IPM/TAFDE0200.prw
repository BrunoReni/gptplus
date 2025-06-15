#Include 'Protheus.ch'

Function TAFDE0200(aWizard, nValor, nCont)

Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   := MsFCreate( cTxtSys )
Local cREG 		:= "0200"
Local DtIncial	:= ""
Local cCodCfop 	:= ""

//CFOP - Entrada
Local VlrEntEstado 		:= 0
Local VlrEntOutEstado 	:= 0
Local VlrEntExterior	:= 0
Local VlrEntAnoBase		:= 0

//Saída
Local VlrSaiEstado 		:= 0
Local VlrSaiOutEstado 	:= 0
Local VlrSaiExterior	:= 0
Local VlrSaiAnoBase		:= 0
Local cStrTxt := ""

nCont := 2

Begin Sequence
	DbSelectArea("T39")
	DbSelectArea("C2S")
	DbSelectArea("C6Z")
	DbSelectArea("C2N")
	DbSelectArea("C2P")

	T39->(DbSetOrder(2))
	If T39->(DbSeek(xFilial("T39") + Substr(aWizard[2][1],1,4)))
		While T39->(!EOF()) .AND. Substr(aWizard[2][1],1,4) == T39->T39_ANOREF .AND. xFilial("T39") == T39->T39_FILIAL
			cStrTxt := "0200"			 //Tipo - Valor Fixo: 0200
			cStrTxt += "000000000000001" //Número Seqüencial da Declaração	- Valor Fixo: 000000000000001

			//Regime do Registro	- N = Normal, Estimativa e Outros;S = Simples Nacional
			if T39->T39_TIPREG == '01'
				cStrTxt += "N"
			else
				cStrTxt += "S"
			endif

			cStrTxt += If(aWizard[3][1] == '0 - Não', "N", "S")
			cStrTxt += If(aWizard[3][2] == '0 - Não', "N", "S")
			cStrTxt += If(aWizard[3][3] == '0 - Não', "N", "S")
			cStrTxt += If(aWizard[3][4] == '0 - Não', "N", "S")
			cStrTxt += If(aWizard[3][5] == '0 - Não', "N", "S")
			cStrTxt += If(aWizard[3][6] == '0 - Não', "N", "S")
			cStrTxt += If(aWizard[3][7] == '0 - Não', "N", "S")

			DtIncial := aWizard[2][1]

			C2S->(DbSetOrder(1))
			If C2S->(DbSeek(xFilial("C2S")+ '0'))
				While C2S->(!EOF()) .AND. xFilial("C2S") == C2S->C2S_FILIAL
					If Substr(DTOS(C2S->C2S_DTINI),1,4) = DtIncial
						C6Z->(DbSetOrder(1))
						IF C6Z->(DbSeek(xFilial("C6Z")+C2S->C2S_ID))
							While C6Z->(!EOF()) .AND. C6Z->C6Z_ID == C2S->C2S_ID .AND. C2S->C2S_FILIAL == xFilial("C2S")
								cCodCfop := SubString (POSICIONE("C0Y",3,xFilial("C0Y")+C6Z->C6Z_CFOP,"C0Y_CODIGO"),1,1)
								Do Case
									//Soma Entradas no Ano-Base - Estado (Ficha "Resumo Geral")
									Case cCodCfop == '1'
										VlrEntEstado += C6Z->C6Z_VLCONT
									Case cCodCfop == '2'
										VlrEntOutEstado += C6Z->C6Z_VLCONT
									Case cCodCfop == '3'
										VlrEntExterior += C6Z->C6Z_VLCONT
									//Soma Saídas no Ano-Base - Estado (Ficha "Resumo Geral")
								    Case cCodCfop == '5'
										VlrSaiEstado += C6Z->C6Z_VLCONT
									Case cCodCfop == '6'
										VlrSaiOutEstado += C6Z->C6Z_VLCONT
									Case cCodCfop == '7'
										VlrSaiExterior += C6Z->C6Z_VLCONT
								EndCase
								C6Z->(dbskip())
							EndDo
						EndIf
					EndIf
					C2S->(dbskip())
				EndDo
			EndIf
			VlrEntAnoBase := VlrEntEstado + VlrEntOutEstado + VlrEntExterior //Total
			VlrSaiAnoBase := VlrSaiEstado + VlrSaiOutEstado + VlrSaiExterior //Total

			nValor := VlrEntEstado + VlrEntOutEstado + VlrEntExterior + VlrEntAnoBase + VlrSaiEstado + VlrSaiOutEstado +  VlrSaiExterior + VlrSaiAnoBase

			cStrTxt += StrTran(StrZero(VlrEntEstado	  , 16, 2),".","")
			cStrTxt += StrTran(StrZero(VlrEntOutEstado, 16, 2),".","")
			cStrTxt += StrTran(StrZero(VlrEntExterior , 16, 2),".","")
			cStrTxt += StrTran(StrZero(VlrEntAnoBase  , 16, 2),".","")
			cStrTxt += StrTran(StrZero(VlrSaiEstado	  , 16, 2),".","")
			cStrTxt += StrTran(StrZero(VlrSaiOutEstado, 16, 2),".","")
			cStrTxt += StrTran(StrZero(VlrSaiExterior , 16, 2),".","")
			cStrTxt += StrTran(StrZero(VlrSaiAnoBase  , 16, 2),".","")

			VlrEntEstado    := 0
            VlrEntOutEstado := 0
            VlrEntExterior  := 0
            VlrEntAnoBase   := 0
            VlrSaiEstado    := 0
            VlrSaiOutEstado := 0
            VlrSaiExterior  := 0
            VlrSaiAnoBase   := 0

			If aWizard[3][1] == '1 - Sim' .And. aWizard[3][3] == '1 - Sim' .And. aWizard[3][4] == '1 - Sim'
				C2N->(DbSetOrder(1))
				If C2N->(DbSeek(xFilial("C2N") + '0'))
					While C2N->(!EOF()) .AND. xFilial("C2N") == C2N->C2N_FILIAL
						If Substr(DTOS(C2N->C2N_DTINI),1,4) = DtIncial
							C2P->(DbSetOrder(1))
							If C2P->(DbSeek(xFilial("C2P")+C2N->C2N_ID))
								While C2P->(!EOF()) .AND. C2P->C2P_ID == C2N->C2N_ID .AND. C2P->C2P_FILIAL == xFilial("C2P")
									cCodCfop := SubString (POSICIONE("C0Y",3,xFilial("C0Y")+C2P->C2P_CFOP,"C0Y_CODIGO"),1,1)
									Do Case
										//Soma Entradas no Ano-Base - Estado (Ficha "Resumo Geral")
										Case cCodCfop == '1'
											VlrEntEstado -= C2P->C2P_VLIPI
										Case cCodCfop == '2'
											VlrEntOutEstado -= C2P->C2P_VLIPI
										Case cCodCfop == '3'
											VlrEntExterior -= C2P->C2P_VLIPI
										//Soma Saídas no Ano-Base - Estado (Ficha "Resumo Geral")
										Case cCodCfop == '5'
											VlrSaiEstado -= C2P->C2P_VLIPI
										Case cCodCfop == '6'
											VlrSaiOutEstado -= C2P->C2P_VLIPI
										Case cCodCfop == '7'
											VlrSaiExterior -= C2P->C2P_VLIPI
									EndCase
									C2P->(dbskip())
								EndDo
							EndIf
						EndIf
						C2N->(dbskip())
					EndDo
				EndIf
				VlrEntAnoBase := VlrEntEstado + VlrEntOutEstado + VlrEntExterior //Total
				VlrSaiAnoBase := VlrSaiEstado + VlrSaiOutEstado + VlrSaiExterior //Total
				nValor += VlrEntAnoBase + VlrSaiAnoBase
			EndIf

			cStrTxt += StrTran(StrZero(VlrEntEstado   , 16, 2),".","")
			cStrTxt += StrTran(StrZero(VlrEntOutEstado, 16, 2),".","")
			cStrTxt += StrTran(StrZero(VlrEntExterior , 16, 2),".","")
			cStrTxt += StrTran(StrZero(VlrEntAnoBase  , 16, 2),".","")
			cStrTxt += StrTran(StrZero(VlrSaiEstado   , 16, 2),".","")
			cStrTxt += StrTran(StrZero(VlrSaiOutEstado, 16, 2),".","")
			cStrTxt += StrTran(StrZero(VlrSaiExterior , 16, 2),".","")
			cStrTxt += StrTran(StrZero(VlrSaiAnoBase  , 16, 2),".","")

			cStrTxt := Left(cStrTxt,268) + space(88) //Filler - Preencher com espaços em branco

			nCont ++
			cStrTxt += StrZero(nCont,5) //Número da linha - Número da linha
		 	cStrTxt += CRLF
			WrtStrTxt( nHandle, cStrTxt )
	
			T39->(dbskip())
		EndDo
	EndIf
	GerTxtDERJ( nHandle, cTxtSys, cReg )
	Recover
	lFound := .F.
End Sequence

Return
