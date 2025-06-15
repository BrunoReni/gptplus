#Include 'Protheus.ch'

Function TAFDE0400(aWizard, nValor, nCont)
Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )
Local cREG 		:= "0400"

Local cID39		:= ""
Local cStrTxt 	:= ""

Begin Sequence

	DbSelectArea("T39")
	DbSetOrder(2)
	If DbSeek(xFilial("T39") + Substr(aWizard[2][1],1,4))
		While !EOF() .AND. Substr(aWizard[2][1],1,4) == T39->T39_ANOREF .AND. xFilial("T39") == T39->T39_FILIAL
		
			DbSelectArea("T36")
			DbSetOrder(1)
			If DbSeek(xFilial("T36")+T39->T39_ID)
				while !EOF() .AND. T36_ID == T39->T39_ID .AND. xFilial("T36") == T36->T36_FILIAL
					cStrTxt := "0400"												//Tipo 							  	- Valor Fixo: 0200
					cStrTxt += "000000000000001"								//Número Seqüencial da Declaração	- Valor Fixo: 000000000000001
					
					//Regime do Registro	- N = Normal, Estimativa e Outros;S = Simples Nacional
					if T39->T39_TIPREG == '01'
						cStrTxt += "N"
					else
						cStrTxt += "S"
					end
					
					cStrTxt += StrZero(Val(POSICIONE("T37",1,xFilial("T37") + T36_IDCODI,"T37_CODDIS")),5)
					//cStrTxt += StrZero(Val(POSICIONE("C07",3,xFilial("C07") + T36_IDCODL,"C07_MUNDRJ")),8)	//Código da Localidade
					cStrTxt += StrZero(Val(POSICIONE("T2D",2,xFilial("T2D")+ T36_IDCODL + "MUNRJ","T2D_CODMUN")),8)	//Código da Localidade
									
					nValor  += T36_VLRDIS 									//Carrega parametro para contabilizar no registro 9999
					cStrTxt += StrTran(StrZero(T36_VLRDIS, 16, 2),".","")
					
					cStrTxt := Left(cStrTxt,48) + space(307)				//Filler 									- Preencher com espaços em branco
					
					nCont ++
					cStrTxt += StrZero(nCont,5) 							//Número da linha							- Número da linha
					cStrTxt += CRLF 											//Proxima Linha
					WrtStrTxt( nHandle, cStrTxt )
					T36->(DbSkip())
				EndDo
			EndIf
			T39->(DbSkip())
		EndDo
	EndIF
	GerTxtDERJ( nHandle, cTxtSys, cReg )
	
	Recover
	
	lFound := .F.
	
End Sequence

Return

