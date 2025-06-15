#Include 'Protheus.ch'

Function TAFDE0001(aWizard)

Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )
Local cREG 		:= "0001"
Local cStrTxt 	:= ""

Begin Sequence
//Marcos.Vecki
	cStrTxt := "0001" 										//Tipo 									- Valor Fixo: 0001
	cStrTxt += DtoS( Date() ) + StrTran(Time(),":","")	//Data da Geração do Arquivo 			- Formato: AAAAMMDDHHMMSS (Ex.: 20091231215530)
	cStrTxt += "N"											//Arquivo Gerado pelo Sistema da SEFAZ	- Valor Fixo: N
	cStrTxt := Left(cStrTxt,20) + (aWizard[1][3])			//Versão da DECLAN-IPM (Wizard)			- Formato: 9.9.9.9 (Ex.: 2.0.0.0)
	cStrTxt := Left(cStrTxt,30) + space(325)				//Filler 									- Preencher com espaços em branco
	cStrTxt := Left(cStrTxt,356) + "00001"					//Número da linha							- Número da linha
	cStrTxt += CRLF
	
	WrtStrTxt( nHandle, cStrTxt )
	
	GerTxtDERJ( nHandle, cTxtSys, cReg )
	
	Recover
	
	lFound := .F.

End Sequence


Return
