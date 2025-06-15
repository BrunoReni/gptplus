#Include 'Protheus.ch'

Function TAFDE0500(aWizard, nValor, nCont)
Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )
Local cREG 		:= "0500"

Local cID39		:= ""
Local cStrTxt 	:= ""

Begin Sequence

	DbSelectArea("T39")
	DbSetOrder(2)
	If DbSeek(xFilial("T39") + Substr(aWizard[2][1],1,4))
		While !EOF() .AND. Substr(aWizard[2][1],1,4) == T39->T39_ANOREF .AND. xFilial("T39") == T39->T39_FILIAL
		
			DbSelectArea("T38")
			DbSetOrder(1)
			If DbSeek(xFilial("T38")+T39->T39_ID) 
				while !EOF() .AND. T38_ID == T39->T39_ID .AND. T38->T38_FILIAL == xFilial("T38")
					cStrTxt := "0500"												//Tipo 							  	- Valor Fixo: 0200
					cStrTxt += "000000000000001"								//Número Seqüencial da Declaração	- Valor Fixo: 000000000000001
					cStrTxt += T38_MES
		
					if T39->T39_TIPREG == '01'
						cStrTxt += "N"
					else
						cStrTxt += "S"
					end
					
					nValor  += T38_RECBRU //Carrega parametro para contabilizar no registro 9999
					cStrTxt += StrTran(StrZero(T38_RECBRU, 16, 2),".","")	//Valor da Receita Bruta do Estabelecimento
					
					nValor  += T38_RECEMP //Carrega parametro para contabilizar no registro 9999
					cStrTxt += StrTran(StrZero(T38_RECEMP, 16, 2),".","")	//Valor da Receita Bruta da Empresa
					
					cStrTxt += "000000000000000"								//Valor da Receita Bruta de Substituição Tributária do Estabelecimento	- Valor Fixo: 000000000000000
					cStrTxt += "000000000000000"								//Valor da Receita Bruta de Substituição Tributária do Estabelecimento	- Valor Fixo: 000000000000000
					cStrTxt := Left(cStrTxt,83) + space(273	)				//Filler 									- Preencher com espaços em branco
					
					nCont ++
					cStrTxt += StrZero(nCont,5)									//Número da linha							- Número da linha
					cStrTxt += CRLF 												//Proxima Linha
					WrtStrTxt( nHandle, cStrTxt )
					T38->(DbSkip())
				EndDo
			EndIf
			T39->(DbSkip())
		EndDo
	EndIf
	GerTxtDERJ( nHandle, cTxtSys, cReg )
	
	Recover
	
	lFound := .F.
	
End Sequence

Return