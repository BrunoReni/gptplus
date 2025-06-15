#Include 'Protheus.ch'

Function TAFDE0100(aWizard)

Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   := MsFCreate( cTxtSys )
Local cREG 		:= "0100"
Local cStrTxt 	:= ""

//Variaveis da tabela C1E
Local cEmailC1E	:= ""
Local cNomeC1E	:= space(64)
Local cDddC1E	:= space(4)
Local cfoneC1E	:= space(8)

//Variaveis da tabela C2J
Local cNomC2J	:= space(64)
Local cDddC2J	:= space(4)
Local cFoneC2J	:= space(8)
Local cTipReg	:= ''
Local cRegAnt	:= ''

Begin Sequence
	cStrTxt := "0100"									 //Tipo 									- Valor Fixo: 0001
	cStrTxt += "000000000000001"						 //Número Seqüencial da Declaração 		- Valor Fixo: 0001
	cStrTxt += Substr(SM0->M0_INSC,1,8)					 //Inscrição Estadual					- M0_INSC ( SIGAMAT )
	cStrTxt += Substr(aWizard[2][1],1,4)				 //Ano de Referência (Wizard)			- Formato: AAAA (Ex.: 2009)
	cStrTxt += If(aWizard[2][2] == '0 - Não', "N", "S")	 //Declaração Retificadora (Wizard)		- S = Sim; N = Não

	//Regimes em que o Contribuinte esteve enquadrado durante o Ano-Base - T39: A = Ambos; N = Normal, Estimativa e Outros; S = Simples Nacional
	//cTipReg := POSICIONE("T39",2,xFilial("T39") + Substr(aWizard[2][1],1,4),"T39_TIPREG")
	cRegAnt := ''
	DbSelectArea("T39")
	DbSetOrder(2)
	If DbSeek(xFilial("T39") + Substr(aWizard[2][1],1,4))
		While !EOF() .AND. Substr(aWizard[2][1],1,4) == T39->T39_ANOREF .AND. xFilial("T39") == T39->T39_filial 
			cTipReg := T39_TIPREG
			If cRegAnt == '' 
				cRegAnt := T39_TIPREG 
			ElseIf cRegAnt != cTipReg
				cTipReg := '00'
				Exit
			EndIf
			DbSkip()
		EndDo
	
		If cTipReg == '01'
			cStrTxt += "N"		//N = Normal, Estimativa e Outros
		elseif cTipReg == '08'
			cStrTxt += "S"		// S = Simples Nacional
		else  
			cStrTxt += "A"		//A=Ambos
		endif
	EndIf

	//Tipo de Pessoa -	J = Jurídica, F = Física(Vide Regra)
	if len(AllTrim(SM0->M0_CGC)) == 11
		cStrTxt += "F"	//Física
	else
		cStrTxt += "J"	//Jurídica
	Endif 
	
	cStrTxt += PADR(SM0->M0_CGC,14, " ")		//CNPJ/CPF do Contribuinte	   - M0_CGC
	cStrTxt += PADR(SM0->M0_NOMECOM, 64, " ") 	//Razão Social do Contribuinte - M0_NOME

	//Leitura para buscar os campos relacionados a tabelas C1E
	DbSelectArea("C1E")
	DbSetOrder(3)
	If DbSeek(xFilial("C1E")+Alltrim(SM0->M0_CODFIL)+"1")
		cEmailC1E	:= C1E->C1E_EMAIL
		cNomeC1E	:= C1E->C1E_NOMCNT
		cDddC1E	    := C1E->C1E_DDDFON 
		cFoneC1E	:= C1E->C1E_FONCNT
		cDDDFaxC1E  := C1E->C1E_DDDFAX
		cFAXC1E  	:= C1E->C1E_FAXCNT 
	Endif

	cStrTxt += 	PADR(cEmailC1E, 40, " ") //Correio Eletrônico do Contribuinte - C1E_EMAIL
	cStrTxt += PADR(cDddC1E,4, " ")		 //DDD do Contribuinte 				  - (SIGAMAT)
	cStrTxt += PADR(cFoneC1E,8, " ")	 //Fone do Contribuinte				  - (SIGAMAT)
	cStrTxt += PADR(cDDDFaxC1E,4, " ")	 //DDD do FAX do Contribuinte		  - (SIGAMAT)
	cStrTxt += PADR(cFAXC1E,8, " ")   	 //Fone do FAX do Contribuinte		  - (SIGAMAT)

	cUf     := POSICIONE("C09",1,xFilial("C09")+ "RJ",  			   "C09_ID")
	cIdMun  := POSICIONE("C07",1,xFilial("C07")+ cUf+SM0->M0_CODMUN,"C07_ID")
	cStrTxt += PADR(POSICIONE("T2D",2,xFilial("T2D")+ cIdMun + "MUNRJ","T2D_CODMUN"),8,"")  //Código da localidade do Contribuinte

	cStrTxt += PADR(cNomeC1E,64," ")	//Nome do Representante Legal	 - C1E_NOMCNT
	cStrTxt += PADR(cDddC1E,4, " ")  	//DDD do Representante Legal	 - C1E_DDDFON
	cStrTxt += PADR(cFoneC1E,8, " ") 	//Telefone do Representante Legal- C1E_FONCNT

	DbSelectArea("C2J")
	DbSetOrder(5)
	If DbSeek(xFilial("C2J")+aWizard[2][3])
		cNomC2J	 := C2J_NOME  
		cDddC2J	 := C2J_DDD 
		cFoneC2J := C2J_FONE 
	Endif

	cStrTxt += PADR(cNomC2J, 64, " ")					//Nome do Contabilista		- C2J
	cStrTxt += PADR(cDddC2J,4, " ") 					//DDD do Contabilista		- C2J
	cStrTxt += PADR(cFoneC2J,8, " ") 					//Telefone do Contabilista	- C2J
	cStrTxt += If(aWizard[2][4] == '0 - Não', "N", "S")	//Declaração de baixa da inscrição (Wizard) - S = Sim; N = Não
	cStrTxt += PADR(DtoS( aWizard[2][5] ),14, ' ')		//Data de Encerramento das Atividades (Wizard)
	cStrTxt += If(aWizard[2][6] == '0 - Não', "N", "S")	//Estabelecimento Principal ou Único no Estado (Ficha "Receita Bruta Mensal") (Wizard) - S = Sim; N = Não
	cStrTxt += If(aWizard[2][7] == '0 - Não', "N", "S")	//Estabelecimento único em território nacional (Ficha "Receita Bruta Mensal") (Wizard) - S = Sim; N = Não
	cStrTxt += If(aWizard[2][8] == '0 - Não', "N", "S")	//Estabelecimento sem receita  no ano-base (Ficha "Receita Bruta Mensal") (Wizard) - S = Sim; N = Não
	cStrTxt += If(aWizard[2][9] == '0 - Não', "N", "S")	//Empresa sem receita no ano-base (Ficha "Receita Bruta Mensal") (Wizard) - S = Sim; N = Não
	cStrTxt := Left(cStrTxt,356) + "00002"				//Número da linha - Número da linha
 	cStrTxt += CRLF

	WrtStrTxt( nHandle, cStrTxt )
	GerTxtDERJ( nHandle, cTxtSys, cReg )

	Recover
	lFound := .F.
End Sequence

Return
