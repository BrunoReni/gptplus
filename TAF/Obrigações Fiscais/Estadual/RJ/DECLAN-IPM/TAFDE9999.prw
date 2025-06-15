#Include 'Protheus.ch'

Function TAFDE9999(aWizard, nValor, nCont)
Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )
Local cREG 		:= "9999"

Local cStrTxt 	:= ""

Begin Sequence

	cStrTxt := "9999"											//Tipo 							  	- Valor Fixo: 0200
	cStrTxt += StrTran(StrZero(nValor, 26, 2),".","")	//Somar todos os campos de valor
	cStrTxt += "00001"										//Número Seqüencial da Declaração	- Valor Fixo: 000000000000001
	
	nCont ++
	cStrTxt += StrZero(nCont,5) 							//Contador de linhas total			- Número da linha
	cStrTxt := Left(cStrTxt,40) + space(316)				//Filler 								- Preencher com espaços em branco
	cStrTxt += StrZero(nCont,5) 							//Número da linha						- Número da linha

	WrtStrTxt( nHandle, cStrTxt )
	GerTxtDERJ( nHandle, cTxtSys, cReg )
	
	Recover
	lFound := .F.
	
End Sequence

Return