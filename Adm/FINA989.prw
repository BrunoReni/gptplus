#Include "Protheus.ch"
#Include "FINA989.ch"
#Include "FwLibVersion.ch"

Static nTamFil    	:= nil
Static nTamE2Pref 	:= nil
Static nTamE2Num  	:= nil
Static nTamE2Par  	:= nil
Static nTamE2Tipo 	:= nil
Static nTamE2For  	:= nil
Static nTamE2Lj   	:= nil

Static nTamE1Pref 	:= nil
Static nTamE1Num  	:= nil
Static nTamE1Par  	:= nil
Static nTamE1Tipo 	:= nil
Static nTamE1Cli  	:= nil
Static nTamE1Lj   	:= nil

Static nTamFTDoc  	:= nil
Static nTamFTSer  	:= nil
Static nTamF2Tip  	:= nil
Static __nBx2030	:= 1
Static __nBx2040	:= 1

Static nTamNumPro 	:= nil
Static nTamDescr  	:= nil
Static nTamIDSEJU 	:= nil
Static nTamVara   	:= nil
Static nTamCodC18 	:= nil
Static cBDname	  	:= nil
Static cSrvType   	:= nil
Static _lPCCBaixa 	:= nil
Static lAI0_INDPAA 	:= nil

Static __oBxFinCR 	:= Nil
Static __oBxFinCP 	:= Nil
Static lPagQry	  	:= .F.
Static lRecQry	  	:= .F.
Static cFilFiscal 	:= nil	
Static cSubstSQL 	:= ""
Static cIsNullSQL 	:= ""
Static cAliasRQry 	:= ""
Static cAliasPQry 	:= ""
Static cAliaSE1   	:= ""
Static cAliaSE2   	:= ""
Static cConcat    	:= ""
Static __cBxFinCR	:= ""
Static __cBxFinCP	:= ""
Static nTamCCFNum 	:= nil
Static aT157Env	  	:= {}
Static aT001ABEnv 	:= {}
Static lGerou	  	:= .F.
Static __lGer154 	:= .F.
Static __lBxFin
Static lAutomato  	:= .F.

// REINF - Bloco 40
Static __cAlsNxt	As Character
Static __cNatSCP  	As Character
Static __aFK7Id	  	As Array
Static __aFK2Id	  	As Array
Static __aFKHId	  	As Array
Static __aT159Env 	As Array
Static __aCodA1		As Array
Static __lDicAtu  	As Logical
Static __oSttFKH  	As Object
Static __oSttFOD  	As Object
Static __oQryBx1  	As Object
Static __oQryBx2  	As Object
Static __oQryBx3  	As Object
Static __oQryFTR  	As Object
Static __oQryPA	  	As Object
Static __oQryFKH  	As Object
Static __oQry158a 	As Object
Static __oQry158b 	As Object
Static __oQryFKW  	As Object
Static __oQryFKW2 	As Object
Static __oQryFK7  	As Object
Static __oQryFKJ  	As Object
Static __oHashDed	As Object
Static __oQryDed	As Object
Static __nFkwImp  	As Numeric
Static __nFkgImp  	As Numeric
Static __lFK7Cpos 	As Logical
Static __lDedIns  	As Logical
Static __lVerFlag 	As Logical
Static __lTemDKE  	As Logical
Static __lCachQry 	As Logical
Static __lRatIrf  	As Logical
Static __lGer158  	As Logical
Static __lGer159  	As Logical
Static __lGer162  	As Logical
Static __lTemFKJ    As Logical
Static __oQryDHT    As Logical

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA989 
Realiza a gera��o da TAFST2 dos t�tulos a pagar e receber

@param aFils Array das filiais selecionadas
@param aResWiz2 Array das resposta do wizard 2
@param aResWiz3 Array das resposta do wizard 3
@param aResWiz4 Array das resposta do wizard 4
@param aResWiz5 Array das resposta do wizard 5
@param oProcess objeto de regua de processamento (descontinuado)
@param lEnd recebido como referencia do MsNewProcess
@param aResAut Array p/ determinar se o R-2030/R-2040 ger� pela baixa

@return lEnd Retorna .T. para indicar o fim de processamento

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------

Function FINA989(aFils,aResWiz2,aResWiz3,aResWiz4,aResWiz5,oProcess, lEnd, aResAut)
Local lJob       := .F.

Default aFils 	:= {}
Default aResWiz2 := {}
Default aResWiz3 := {}
Default aResWiz4 := {}
Default aResWiz5 := Array(11)
Default oProcess := Nil
Default lEnd 	:= .T.
Default aResAut	:= {1,1}

/*------------------------------------------------------------------|
| Quando for chamado via JOB ou automa��o, as informacoes do WIZARD |
| serao passadas como pergunte ou via os parametros da fun��o		|
-------------------------------------------------------------------*/
If ( lJob := IsBlind() )
	Aadd(aFils,cFilAnt )
	
	Pergunte("FINTAF",.F.)
	
	// alimenta array das respostas da tela de Wizard 2
	aResWiz2		:= Array(10)
	aResWiz3		:= Array(12)
	aResWiz4		:= Array(3)

	// alimenta array das respostas da tela de Wizard 2
	aResWiz2[1]	:= MV_PAR01 // Considera data 1-Emiss�o Digita. (EMIS1) 2-Emiss�o Real (EMISSAO)
	aResWiz2[2]	:= MV_PAR02 // Data de 
	aResWiz2[3]	:= MV_PAR03 // Data Ate
	aResWiz2[4]	:= MV_PAR04 //1-Pessoa F�sica","2 -Pessoa Jur�dica","3-Estrangeiro","4-Todas"
	aResWiz2[5]	:= MV_PAR05 // Cliente De 
	aResWiz2[6]	:= MV_PAR06	// Cliente Ate				
	aResWiz2[7]	:= MV_PAR07 // Loja De
	aResWiz2[8]	:= MV_PAR08	// Loja Ate		
	
	// alimenta array das respostas da tela de Wizard 3
	aResWiz3[1]	:= MV_PAR09	//// Considera data 1-Emiss�o Digita. (EMIS1) 2-Emiss�o Real (EMISSAO)
	aResWiz3[2]	:= MV_PAR10 //"Considera Data Pagamento "1-Data Vencto Real (VENCREA)", "2-Data Vencto (VENCTO)", "3-Data baixa (BAIXA)"
	aResWiz3[3]	:= MV_PAR11  // Data de 
	aResWiz3[4]	:= MV_PAR12 // Data Ate
	aResWiz3[5]	:= MV_PAR13 //1-Pessoa F�sica","2 -Pessoa Jur�dica","3-Estrangeiro","4-Todas"
	aResWiz3[6]	:= MV_PAR14 // Fornecedor de 
	aResWiz3[7]	:= MV_PAR15	// Fornecedor ate 				
	aResWiz3[8]	:= MV_PAR16 // Loja de 
	aResWiz3[9]	:= MV_PAR17	// Loja ate		

	aResWiz4[1]	:= MV_PAR18 //Tipo de sa�da "1-Arquivo TXT", "2-Banco a Banco"
	aResWiz4[2]	:= MV_PAR19 // Diret�rio Arquivo Destino
	aResWiz4[3]	:= MV_PAR20 //Nome do arquivo destino RetFileName(MV_PAR24)
	
	aResWiz5[1] := If(MV_PAR21 == 1, .T., .F.) // EXPORTAR T001AB-PROCESSOS REFERENCIADOS
	aResWiz5[2] := If(MV_PAR22 == 1, .T., .F.) // EXPORTAR T003-PARTICIPANTES
	aResWiz5[3] := If(MV_PAR23 == 1, .T., .F.) // EXPORTAR T154-CADASTRO DE TITULOS A RECEBER
	aResWiz5[4] := If(MV_PAR24 == 1, .T., .F.) // EXPORTAR T154-CADASTRO DE TITULOS A PAGAR
	aResWiz5[5] := If(MV_PAR25 == 1, .T., .F.) // EXPORTAR T154AA-TIPOS DE SERVICOS

	lAutomato := .T.

	__nBx2030	:= aResAut[1]
	__nBx2040	:= aResAut[2]
EndIf

If _lPCCBaixa == nil
	IniVarStat()
EndIf	

If Type("lBuild") <> "L"
	Private lBuild := .F.
EndIf
	 
lEnd := FinExpTAF(,,aFils,aResWiz2,aResWiz3,aResWiz4,aResWiz5)
Return lEnd
		  
//-------------------------------------------------------------------
/*/{Protheus.doc} FinExpTAF 
Fun��o para ser chamada tanto pela rotina do Wizard (FINA988) como pelas rotinas de inclusao/baixas do contas a pagar e receber 
para fazer a migra��o online.

@param nRecno Deve ser enviado o recno do registro da SE1 ou SE2, caso nao esteja processando pelo Wizard.
@param nCarteira  Deve ser enviado 1 para SE2 ou 2 para SE1, caso nao esteja processando pelo Wizard.
@param aFils Array das filiais selecionadas do Wizard
@param aResWiz2 Array das resposta do wizard 2
@param aResWiz3 Array das resposta do wizard 3
@param aResWiz4 Array das resposta do wizard 4
@param aResWiz5 Array das resposta do wizard 5
@param oProcess objeto de regua de processamento do Wizard (descontinuado)
@param aParticip, array, lista de participantes
@param lExtReinf, logical, obsoleto (mantido por compartibilidade)
@param lFiltReinf, logical, filtra s� dados do REINF
@param cFiltInt, caracter, exporta 1=Cadastros;2=Movimentos;3=Ambos

@return lEnd Retorna .T. para indicar o fim de processamento

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
		  
Function FinExpTAF(nRecno,nCarteira,aFils,aResWiz2,aResWiz3,aResWiz4,aResWiz5,oProcess,aParticip, lExtReinf, lFiltReinf, cFiltInt, aLstT013 )

Local lRet		 As Logical
Local nFil       As Numeric
Local cFilBkp 	 As Character
Local nCart 	 As Numeric
Local lProcessa  As Logical
Local cCtrlT154  As Character
Local cNumNF	 As Character
Local cCodLojAnt As Character
Local nI		 As Numeric
Local nLenFK	 As Numeric
Local aRegT159A	 As Array
Local lGeraPA    As Logical
Local nRecMovPa  As Numeric
Local dDtTit	 As Date
Local cOldId     As Character
Local cOldCPF	 As Character
Local lTitPA     As Logical
Local lGerT158   As Logical
Local lGerT159   As Logical
Local lGerT162   As Logical

// para integra��o do taf
Private cTpSaida := "2"	// "1-TXT MILE","2-Banco-a-banco","3-Nativo"
Private cInc := "000001" // utilizado pela funcao do taf
Private cDirSystem := ""
Private cNomeArq	 := "" 	
Private nHdlTxt	  := 0
Private lGeraST2TAF := .F.

//respostas dos perguntes do wizard contas a receber
Private nTpEmData := 1
Private dDataEmDe  := CTOD("  /  /    ")
Private dDataEmAte := CTOD("  /  /    ")
Private nTpEmPessoa:= 1
Private cCliDe     := ""
Private cCliAte    := ""
Private cLojaCliDe  := ""
Private cLojaCliAte := ""

//respostas dos perguntes do wizard contas a receber
Private nTpPgEmis := 1
Private dDataPgDe  := CTOD("  /  /    ")
Private dDataPgAte := CTOD("  /  /    ")
Private nTpPgData := 1
Private nTpPgPessoa := 1
Private cForDe		:= ""
Private cForAte		:= ""
Private cLojaForDe	:= ""
Private cLojaForAte	:= ""

Private lIntTAF    := FindFunction("TAFExstInt") .AND. TAFExstInt() // Verifica Intergacao NATIVA Protheus x TAF
Private lGerT001AB := .T.
Private lGerT003   := .T.
Private lGerT154AA := .T.
Private lGerT154CR := .T.
Private lGerT154CP := .T.
Private lGerT157   := .T.
Private cAliasQry  := "" // alias da query do titulos

Default nRecno   := 0
Default nCarteira:= 3 
Default aFils    := {}
Default aResWiz2 := {} 
Default aResWiz3 := {}
Default aResWiz4 := {}
Default aLstT013 := {}

Default aResWiz5 := Array(8)
Default oProcess := Nil
Default aParticip := {}
Default lExtReinf := .f.
Default lFiltReinf := .F.
Default cFiltInt := "3"

If __lBxFin == Nil
	__lBxFin := .T.
EndIf

If _lPCCBaixa == nil
	IniVarStat()
EndIf	

If Len(aResWiz4) > 1
	cTpSaida := Alltrim(Str(aResWiz4[1]))
	cDirSystem := Alltrim(aResWiz4[2])
	cNomeArq :=  Alltrim(aResWiz4[3])
	If Len(aResWiz4) >  3
		nHdlTxt := aResWiz4[4]
	EndIf	 
EndIf

//Verifica se os flags de integra��o ser�o gravados (grava apenas quando integra��o for banco-a-banco)
__lVerFlag := __lDicAtu .and. cTpSaida == "2" .and. !lAutomato

If Len(aResWiz2) > 1 // Parametros do titulo a receber
	nTpEmData 	:= aResWiz2[1]	//Considera Data 1 - Data de Contabiliza��o (EMIS1) 2-Data de Emiss�o (EMISSAO)
	dDataEmDe 	:= aResWiz2[2]	//Data de
	dDataEmAte	:= aResWiz2[3]	//Data at�
	nTpEmPessoa:= aResWiz2[4]	//Tipo de Pessoa	"1-Pessoa F�sica","2-Pessoa Jur�dica","3-Todas"
	cCliDe     := aResWiz2[5]	//Cliente De
	cCliAte    := aResWiz2[6]	//Cliente Ate
	cLojaCliDe	:= aResWiz2[7]	//Loja De
	cLojaCliAte	:= aResWiz2[8]	//Loja Ate
	
EndIf

If Len(aResWiz3) > 1 // Parametros do titulo a pagar e baixas 

	nTpPgEmis	:= aResWiz3[1]	//Considera Data 1 - Emiss�o Digita. (EMIS1) 2-Emiss�o Real (EMISSAO)
	nTpPgData 	:= aResWiz3[2]	//Considera Data "1-Data Vencto Real (VENCREA)", "2-Data Vencto (VENCTO)", "3-Data baixa (BAIXA)"
	dDataPgDe 	:= aResWiz3[3]	//Data de
	dDataPgAte	:= aResWiz3[4]	//Data at�
	nTpPgPessoa:= aResWiz3[5]	//Tipo de Pessoa	"1-Pessoa F�sica","2-Pessoa Jur�dica","3-Todas"
	cForDe     := aResWiz3[6]	//Cliente De
	cForAte    := aResWiz3[7]	//Cliente Ate
	cLojaForDe	:= aResWiz3[8]	//Loja De
	cLojaForAte	:= aResWiz3[9]	//Loja Ate
	
EndIf

If Empty(aFils)
	Aadd(aFils,cFilAnt)
EndIf

If cTpSaida == "1" .and. nHdlTxt == 0
	//Cria arquivo
	nHdlTxt := FinCriaArq(cDirSystem,cNomeArq)
	If nHdlTxt <= 0 
		Return .F.
	EndIf	
	
EndIf

// se passar o recno, define os layouts que devem ser enviados
If nRecno > 0
	aResWiz5[1] := .T.
	aResWiz5[2] := .T.
	If nCarteira == 2 // Receber
		aResWiz5[3] := .T.
		aResWiz5[4] := .F.
		aResWiz5[5] := .T.
	ElseIf nCarteira == 1 // Pagar
		aResWiz5[3] := .F.
		aResWiz5[4] := .T.
		aResWiz5[5] := .T.
	EndIf
EndIf

nCarteira := 3 // todas

If aResWiz5[3] .and. !aResWiz5[4]
	nCarteira := 2 // receber
ElseIf	 aResWiz5[4] .and. !aResWiz5[3]
	nCarteira := 1 // pagar
EndIf

lGerT001AB := aResWiz5[1]
lGerT003   := aResWiz5[2]
lGerT154CR := aResWiz5[3]
lGerT154CP := aResWiz5[4]
lGerT154AA := aResWiz5[5]

If Len(aResWiz5) > 7
	lGerT157 := aResWiz5[8]
EndIf	

If Len(aResWiz5) > 8 .and. __lDicAtu
	lGerT158   := aResWiz5[9]
	lGerT159   := aResWiz5[10]
	lGerT162   := aResWiz5[11]
EndIf	

lRet	   	:= .T.
nFil 	   	:= 1  
cFilBkp    	:= cFilAnt
nCart 	   	:= 1
lProcessa  	:= .F.
cCtrlT154  	:= "0"
cNumNF	   	:= ""
cCodLojAnt 	:= ""
nI		   	:= 0
nLenFK	   	:= 0
aRegT159A  	:= {}
lGeraPA    	:= .F.
nRecMovPa  	:= 0
dDtTit	   	:= CTOD("  /  /    ")
cOldId     	:= ""
cOldCPF		:= ""
lTitPA     	:= .F.

For nFil := 1 To Len( aFils )
		
	cFilAnt := aFils[ nFil ]
	
	If lAutomato
		lRet := FExpT001()
	EndIf	
	
	For nCart := 1 To 2
		
		lProcessa := .F.
				
		//Cria query dos titulos a pagar
		If nCart == 1 .and.  (nCarteira == 1 .OR. nCarteira == 3)
		 	If Empty(cAliasPQry)
		 		cAliasPQry := GetNextAlias()
		 		MntQryPag(nRecno,@cAliasPQry, lExtReinf, lFiltReinf)
		 		FI8->(DbSetOrder(1))// FI8_FILIAL, FI8_PRFORI, FI8_NUMORI, FI8_PARORI, FI8_TIPORI, FI8_FORORI, FI8_LOJORI
			EndIf
			lProcessa := .T.
			cAliasQry := cAliasPQry
		EndIf 
		
		//Cria query dos titulos a receber
		If nCart == 2 .and. (nCarteira == 2 .OR. nCarteira == 3)
			If Empty(cAliasRQry)
				cAliasRQry := GetNextAlias()
				MntQryRec(nRecno,@cAliasRQry, lExtReinf)
				FI7->(DbSetOrder(1))// FI7_FILIAL, FI7_PRFORI, FI7_NUMORI, FI7_PARORI, FI7_TIPORI, FI7_CLIORI, FI7_LOJORI
			EndIf	
			lProcessa := .T.
			cAliasQry := cAliasRQry
		EndIf	
		
		cCodLojAnt := ""
		
		If lProcessa
			(cAliasQry)->(DbGotop())
			While (cAliasQry)->(!Eof())
				
				//Desconsidera titulo originador de desdobramento a pagar
				If nCart == 1 .and. (cAliasQry)->DESDOBR == "S" .and. FI8->(MsSeek(xFilial("FI8")+(cAliasQry)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+COD+LOJA)))
					(cAliasQry)->(DBSkip())
					Loop
				EndIf

				//Desconsidera titulo de adiantamento a pagar (PA) quando o mesmo ainda nao gerou movimento bancario
				If nCart == 1 .AND. (cAliasQry)->E2_TIPO $ MVPAGANT
					lTitPA := .T. //Identifica que � PA para enviar somente nas tabelas T158
					nRecMovPa := F080MovPA(.T.,(cAliasQry)->E2_PREFIXO,(cAliasQry)->E2_NUM,(cAliasQry)->E2_PARCELA,(cAliasQry)->E2_TIPO,(cAliasQry)->COD,(cAliasQry)->LOJA) 
					lGeraPA := nRecMovPa > 0
					If !lGeraPA
						(cAliasQry)->(DBSkip())
						Loop
					Endif
				EndIf

				//Desconsidera titulo a pagar repetido na query da MntQryPag (UNION), se incluso e baixado no mesmo dia
				IF __lTemFKJ
					If nCart == 1 .and. ( Alltrim((cAliasQry)->FK7_IDDOC) == Alltrim(cOldId) .And. ( Empty((cAliasQry)->FKJ_CPF) .Or. ( !Empty((cAliasQry)->FKJ_CPF) .And. (cAliasQry)->FKJ_CPF == cOldCPF)) )
						(cAliasQry)->(DBSkip())
						Loop
					EndIf	
				Else		
					If nCart == 1 .and. Alltrim((cAliasQry)->FK7_IDDOC) == Alltrim(cOldId) 
						(cAliasQry)->(DBSkip())
						Loop
					EndIf	
				EndIf

				//Desconsidera titulo originador de desdobramento a receber	
				If nCart == 2 .and. (cAliasQry)->DESDOBR == "1" .and. FI7->(MsSeek(xFilial("FI7")+(cAliasQry)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+COD+LOJA)))
					(cAliasQry)->(DBSkip())
					Loop
				EndIf
				
				//gera sempre o cadastro de obras se houver
				If lGerT157
					//Gera registro T157-Cadastro de obras
					lRet := FFinT157(nCart,cAliasQry)
				EndIf		
					
				If lGerT001AB
					//Gera registro T001AB-Processos judiciais
					lRet := FFinT001AB(nRecno,nCart,(cAliasQry)->FK7_IDDOC)
				EndIf
				
				If lGerT003
					//Gera registro T003-Participantes
					If cCodLojAnt <> (cAliasQry)->COD + (cAliasQry)->LOJA
						lRet := FFinT003(nRecno,nCart, cAliasQry, @aParticip, lFiltReinf, cFiltInt, aLstT013 )
						cCodLojAnt := (cAliasQry)->COD + (cAliasQry)->LOJA
					EndIf
					If cTpSaida == "1"
						/*-----------------------------------------------------------------------------------------------|
						| Envia clientes e fornecedores para atender os eventos R-2030 e R-2040, quando selecionado      |
						| no Wizard que esses eventos ser�o enviados pela 'data da baixa' ou 'data da disponibilizade'.  |
						------------------------------------------------------------------------------------------------*/	
						If nCart == 1 .And. ( __nBx2040 > 1 .And. Select(__cBxFinCP) > 0 )
							(__cBxFinCP)->(DbGoTop())
							While !((__cBxFinCP)->(Eof()))
								dDtTit := StoD(Iif(nTpPgEmis == 1, (__cBxFinCP)->E2_EMIS1,(__cBxFinCP)->E2_EMISSAO ))
								If ( dDtTit < dDataPgDe .Or. dDtTit > dDataPgAte )
									FFinT003(nRecno,nCart, __cBxFinCP, @aParticip, lFiltReinf, cFiltInt, aLstT013 )
								EndIf

								(__cBxFinCP)->(DbSkip())
							EndDo
						ElseIf ( __nBx2030 > 1 .And. Select(__cBxFinCR) > 0 )
							(__cBxFinCR)->(DbGoTop())
							While !((__cBxFinCR)->(Eof()))
								dDtTit := StoD(Iif(nTpEmData == 1, (__cBxFinCR)->E1_EMIS1,(__cBxFinCR)->E1_EMISSAO ))
								If ( dDtTit < dDataEmDe .Or. dDtTit > dDataEmAte )
									FFinT003(nRecno,nCart, __cBxFinCR, @aParticip, lFiltReinf, cFiltInt, aLstT013 )
								EndIf
								(__cBxFinCR)->(DbSkip())
							EndDo
						EndIf	
					EndIf				
				EndIf

				If lGerT159 .AND.  nCart == 1
					//Gera T159- Cadastro Sociedade em Conta de Participa��o
					lRet := FFinT159(nCart,cAliasQry, aRegT159A)
					lGerT159 := .F.
				EndIf

				If lGerT154CR .and. nCart == 2 .and. (cAliasQry)->TABELA == "T154"
					//Gera registro T154-Titulos a receber (Eventos R-2010 e R-2030)
					lRet := FFinT154(nRecno, nCart, cAliasQry, oProcess, @cCtrlT154, @cNumNF, __cBxFinCR, (cAliasQry)->FK7_IDDOC)
				EndIf

				If lGerT162 .and. nCart == 2 .and. (cAliasQry)->TABELA == "T162"
					//Gera registro T162-IRRF de auto-reten��o de t�tulos a receber (Evento R-4080)
					lRet := FFinT162(cAliasQry)
				Endif
				
				If lGerT154CP .and.  nCart == 1 .and. !lTitPA
					cOldId 	:= (cAliasQry)->FK7_IDDOC
					If __lTemFKJ
						cOldCPF	:= (cAliasQry)->FKJ_CPF
					EndIf
					//Gera registro T154 exportando INSS e IRRF do contas a pagar (eventos 2020-2040-4010-4020)
					lRet := FFinT154(nRecno, nCart, cAliasQry, oProcess, @cCtrlT154, @cNumNF, __cBxFinCP, (cAliasQry)->FK7_IDDOC)
				EndIf

				If lGerT158 .and.  nCart == 1
					//Gera registro T158 para as baixas a pagar c/ naturezas de rendimento (eventos 4010-4020)
					lRet := FFinT158( nRecno, nCart, cAliasQry )
				EndIf

				lTitPA := .F.
				
				(cAliasQry)->(DBSkip())		

				// Verifica se � outro documento e atualiza controle de criacao do Reg T154
				If 	(nCart == 1 .and. lGerT154CP .and. (cAliasQry)->E2_NUM+(cAliasQry)->E2_PREFIXO <> cNumNF) .or. ;
					(nCart == 2 .and. lGerT154CR .and. (cAliasQry)->E1_NUM+(cAliasQry)->E1_PREFIXO <> cNumNF) 
					cCtrlT154 := '0'
					If cTpSaida == "2" .AND. Len(aDadosST1) > 0 //Grava o registro na TABELA TAFST2 e limpa o array aDadosST1.
						FConcST1()
					EndIf	
				EndIf		

			EndDo
			
			//Integra o bloco T159 - Cadastro de SCP
			If Len(aRegT159A) > 0 .AND. nCart == 1
				FConcTxt( aRegT159A, nHdlTxt )

				FWFreeArray(aRegT159A)
				aRegT159A := {}
				__lGer159 := .T.

				// Grava o registro na TABELA TAFST2 e limpa o array aDadosST1.
				If cTpSaida == "2" 
					FConcST1()
				EndIf
			Endif

		EndIf

		/*------------------------------------------------------------------------------------|
		| Gera dados para a tabela T999, que deve ser alimentada para excluir no TAF as 	  |
		| movimenta��es j� integradas e que foram exclu�das no ERP.  			              |
		| Obs: Foi disponibilizado apenas na op��o "banco-a-banco" (cTpSaida="2") pois a      | 
		| gera��o da T999 n�o entra no filtro do range de datas definido no Wizard, ent�o 	  |    
		| como a integra��o via TXT n�o grava a flag de integra��o, acabaria sempre enviando. |
		-------------------------------------------------------------------------------------*/	
		If (lGerT154CR .or. lGerT154CP) .AND. cTpSaida == "2" .AND. F989FKH(cFilAnt, nCart) 
			F989EnvFKH( cFilAnt, nCart )
		EndIf

	Next nCart

	FWFreeArray(aT157Env)
	FWFreeArray(__aT159Env)
	FWFreeArray(aT001ABEnv)
	aT157Env	:= {}
	__aT159Env	:= {}	
	aT001ABEnv	:= {}

Next nFil

/*--------------------------------------------------------------------------------------------------|
| Envia as baixas a receber (para atender o R-2030) e/ou as baixas a pagar (para atender o R-2040),	|
| se selecionado no Wizard que ser�o enviados pela 'data da baixa' ou data da disponibilizade'. 	|
| Obs: Caso o t�tulo j� tenha sido integrado em uma chamada anterior da FFinT154(), o mesmo ser�    |
| desconsiderado do processamento abaixo (controle atrav�s do campo IMPRES).						|
---------------------------------------------------------------------------------------------------*/	
If __lBxFin .And. lGerT003
	For nCart := 1 To 2
		cCodLojAnt := ""
		If nCart == 1 .And. ( __nBx2040 > 1 .And. Select(__cBxFinCP) > 0 )
			(__cBxFinCP)->(DbGoTop())
			While !((__cBxFinCP)->(Eof()))
				dDtTit := StoD(Iif(nTpPgEmis == 1, (__cBxFinCP)->E2_EMIS1,(__cBxFinCP)->E2_EMISSAO ))

				If cCodLojAnt <> (__cBxFinCP)->COD + (__cBxFinCP)->LOJA
					lRet := FFinT003(nRecno,nCart, __cBxFinCP, @aParticip, lFiltReinf, cFiltInt, aLstT013 )
					cCodLojAnt := (cAliasQry)->COD + (cAliasQry)->LOJA
				EndIf

				If Empty((__cBxFinCP)->IMPRES) .And. ( dDtTit < dDataPgDe .Or. dDtTit > dDataPgAte )
					FFinT154(nRecno, nCart, __cBxFinCP, oProcess, @cCtrlT154, @cNumNF, __cBxFinCP, (__cBxFinCP)->FK7_IDDOC)
				Else
					(__cBxFinCP)->(DbSkip())
				EndIf

				// Verifica se � outro documento e atualiza controle de criacao do Reg 154
				If 	(__cBxFinCP)->(E2_NUM+E2_PREFIXO) <> cNumNF
					cCtrlT154 := '0'
					If cTpSaida == "2" .AND. Len(aDadosST1) > 0
						FConcST1()
					EndIf
					
				EndIf
			EndDo
		ElseIf ( __nBx2030 > 1 .And. Select(__cBxFinCR) > 0 )
			(__cBxFinCR)->(DbGoTop())
			While !((__cBxFinCR)->(Eof()))
				dDtTit := StoD(Iif(nTpEmData == 1, (__cBxFinCR)->E1_EMIS1,(__cBxFinCR)->E1_EMISSAO ))
				If cCodLojAnt <> (__cBxFinCR)->COD + (__cBxFinCR)->LOJA
					lRet := FFinT003(nRecno,nCart, __cBxFinCR, @aParticip, lFiltReinf, cFiltInt, aLstT013 )
					cCodLojAnt := (cAliasQry)->COD + (cAliasQry)->LOJA
				EndIf

				If Empty((__cBxFinCR)->IMPRES) .And. ( dDtTit < dDataEmDe .Or. dDtTit > dDataEmAte )
					FFinT154(nRecno, nCart, __cBxFinCR, oProcess, @cCtrlT154, @cNumNF, __cBxFinCR, (__cBxFinCR)->FK7_IDDOC)
				Else
					(__cBxFinCR)->(DbSkip())
				EndIf

				If (__cBxFinCR)->(E1_NUM+E1_PREFIXO) <> cNumNF
					cCtrlT154 := '0'
					If cTpSaida == "2" .AND. Len(aDadosST1) > 0
						FConcST1()
					EndIf
					
				EndIf				
			EndDo
		EndIf

	Next
	__lBxFin	:= .F.
EndIf

//Fecha os alias temporarios quando for execu��o dos testes automatizados
If lAutomato
	If !Empty(cAliasPQry)
		(cAliasPQry)->(DBCloseArea())
		cAliasPQry := nil
	EndIf	
	If !Empty(cAliasRQry)
		(cAliasRQry)->(DBCloseArea())
		cAliasRQry := nil
	Endif			
EndIf

If cTpSaida == '1' .and. lAutomato
	FClose(nHdlTxt)
Endif	

cFilAnt := cFilBkp
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FinCriaArq 
Valida��o e cria��o do arquivo TXT 

@param cDirSystem Diretorio onde dever� ser criado o arquivo
@param cNomeArq
@return nHdl numero do Handle da cria��o do arquivo 

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function FinCriaArq(cDirSystem,cNomeArq)
Local nHdl := 0
Local cNomeDir
Local nRetDir := 0

If Right(cDirSystem,1) <> "\"
	cDirSystem := cDirSystem + "\"
EndIf
If Lower( Right( Alltrim( cNomeArq ), 4 ) ) <> ".txt"
	cNomeArq := ( cNomeArq + ".txt" )
EndIf
	
cNomeDir := cDirSystem + cNomeArq
If !File( cNomeDir )	
	
	If !ExistDir(cDirSystem)
		nRetDir := MakeDir( cDirSystem )
	EndIf
	If nRetDir != 0
		cNomeDir := ""
		Help( ,,"CRIADIR",,  STR0009 + cValToChar( FError() ) , 1, 0 ) //"N�o foi poss�vel criar o diret�rio. Erro: "
	EndIf
Else
	If lAutomato .Or. ( !lAutomato .And. MsgYesNo(STR0010) ) //"J� existe um arquivo de mesmo nome, deseja substituir?"
		nRetDir := FErase(cNomeDir)
		
		If nRetDir != 0
			cNomeDir := ""
			Help( ,,"DELARQ",,  STR0011 + cValToChar( FError() ) , 1, 0 )//"N�o foi poss�vel recriar o arquivo. Erro: "
		EndIf
	Else	
		cNomeDir := ""
	EndIf		
EndIf

If !Empty( cNomeDir )
	nHdl :=  MsFCreate( cNomeDir )
	
	If nHdl < 0
		Help( ,,"CRIAARQ",, STR0012 + cValToChar( FError() ) , 1, 0 ) //"N�o foi poss�vel criar o arquivo. Erro: "
	EndIf	
	
EndIf
Return nHdl

//-------------------------------------------------------------------
/*/{Protheus.doc} FExpT001 
Gera os registros do Layout T001 - Filial 

@return lRet Retorna .t. para final de execu��o

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function FExpT001()
Local lRet := .T.
Local aRegs    := {}
Local cReg     := "T001" // c�digo do registro no TAF
	
		aRegs := {}
		( Aadd( aRegs, {  ;
		cReg,; // 1 Registro T001-Cadastro de empresas
		cEmpAnt+cFilAnt,;// 2 FILIAL
		"",;// 3	EMAIL
		"",;// 4	C�DIGO FEBRABAN
		"",;// 5	CRT
		"",;// 6	MATRIZ
		"",;// 7	DESC_RZ_SOCIAL
		"",;// 8	INSTAL_ANP
		"",;// 9	SEGMENTO
		"",;// 10	IND_ESCRITURACAO
		"",;// 11	CLASSTRIB
		"",;// 12	IND_ACORDO
		"",;// 13	NMCTT
		"",;// 14	CPFCTT
		"",;// 15	FONEFIXO
		"",;// 16	FONECEL
		"",;// 17	IDEEFR
		"",;// 18	CNPJEFR
		"",;// 19	IND_DESONERACAO
		"",;// 20	IND_SIT_PJ
		"",;// 21	INI_PER
		"",;// 22	FIM_PER
		"",;// 23	IND_ASSOC_DESPORT
		"",;// 24	IND_PROD_RURAL
		"" }))// 25 	EXECPAA
		
		
		FConcTxt( aRegs,nHdlTxt )
		
		//Grava o registro na TABELA TAFST2 e limpa o array aDadosST1
		If cTpSaida == "2" 
			FConcST1()
		EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FFinT001AB 
Gera os registros do Layout T001AB - Processos 

@param nRecno, Recno do titulo, caso seja somente para mandar s� ele
@param nCarteira, Tipo de Carteira (1=Pagar/2=Receber)
@param cIdDoc, ID do titulo (ref. FK7_IDDOC)

@return lRet Retorna .t. para final de execu��o

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function FFinT001AB(nRecno As Numeric, nCarteira As Numeric, cIdDoc As Char) As Logical

Local lRet 		 As Logical
Local aRegs      As Array
Local cReg       As Character
Local cFilialTAF As Character
Local lGeraT1AB  As Logical
Local cDataIni	 As Character
Local cDataFin	 As Character
Local cTpImp	 As Character

Default nRecno := 0
Default nCarteira := 3
Default cIdDoc := ""

DBSelectArea("CCF")
CCF->(DBSetOrder(1)) // CCF_FILIAL, CCF_NUMERO, CCF_TIPO

DBSelectArea("FKG")
FKG->(DBSetOrder(2)) //FKG_FILIAL, FKG_IDDOC, FKG_TPIMP
FKG->(MsSeek(xFilial("FKG") + cIdDoc ) )

lRet 	   := .T.
aRegs      := {}
cReg       := "T001AB" // c�digo do registro no TAF
cFilialTAF := ""
lGeraT1AB  := .T.
cDataIni   := ""
cDataFin   := ""
cTpImp	   := "INSS|IRF|PIS|COF|CSL"

While FKG->(!Eof()) .and. Alltrim(FKG->(FKG_FILIAL+FKG_IDDOC)) == Alltrim(xFilial("FKG") + cIdDoc)
	
	If AllTrim( FKG->FKG_TPIMP ) $ cTpImp .And. Alltrim(FKG->FKG_TPATRB) == '004' // Processo judicial
		If AScan(aT001ABEnv,{ |x| x[1] == Alltrim(FKG->FKG_NUMPRO) }) == 0 .and. CCF->(MsSeek(xFilial("CCF") + padr(FKG->FKG_NUMPRO, nTamCCFNum) +  FKG->FKG_TPPROC)) 
			Aadd(aT001ABEnv,{ Alltrim(FKG->FKG_NUMPRO) })
			lGeraT1AB := .T.
			If !Empty(CCF->CCF_DTINI)
				cDataIni := STRZERO(MONTH(CCF->CCF_DTINI),2)+STRZERO(YEAR(CCF->CCF_DTINI),4) 
			EndIf

			If !Empty(CCF->CCF_DTFIN)
				cDataFin := STRZERO(MONTH(CCF->CCF_DTFIN),2)+STRZERO(YEAR(CCF->CCF_DTFIN),4) 
			EndIf
			
			If lIntTAF
				cFilialTAF:= FTafGetFil( allTrim( cEmpAnt ) + allTrim( cFilAnt ) , {} , "C1G" )
				
				//Verifica se no TAF o registro existe e n�o ha alteracoes.
				//Caso exista e nao haja alteracoes nos campos,NAO geramos
				//o registro na TAFST2 para a integracao.
				If C1G->( MsSeek( cFilialTAF + PadR( CCF->CCF_NUMERO , nTamNumPro ) + CCF->CCF_TIPO ))
					
					If C1G->C1G_DESCRI  == PadR(CCF->CCF_DESCJU, nTamDescr).And. ;
						Substr(C1G->C1G_SECJUD,1,nTamIDSEJU) == CCF->CCF_IDSEJU .And. ;
						C1G->C1G_VARA   == PadR(CCF->CCF_IDVARA, nTamVara)  .And. ;
						C1G->C1G_DTSENT == SToD(CCF->CCF_DTSENT).And. ;
						C1G->C1G_DTADM  == SToD(CCF->CCF_DTADM) 
						
						If !Empty(CCF->CCF_NATJU)
							If C18->( MsSeek( xFilial("C18") + C1G->C1G_ACAJUD ) )
								If C18->C18_CODIGO == PadR( CCF->CCF_NATJU , nTamCodC18)
									lGeraT1AB := .F.
								EndIf
							EndIf
						Else
							lGeraT1AB := .F.
						EndIf
						
						If !Empty(CCF->CCF_NATAC )
							If C19->( MsSeek( xFilial("C19") + C1G->C1G_INRCFE ) )
								If C19->C19_CODIGO == PadR(CCF->CCF_NATAC , nTamCodC18)
									lGeraT1AB := .F.
								EndIf
							EndIf
						Else
							lGeraT1AB := .F.
						EndIf
						
					Endif
					
				EndIf
				
			EndIf
			
			If lGeraT1AB
				lGerou := .T.
				
				aRegs := {}
				CCF->( Aadd( aRegs, {  cReg,; //001-REGISTRO):
				CCF_NUMERO,; //002-NUM_PROC
				CCF_TIPO,; //003-IND_PROC
				CCF_DESCJU,; //004-DESCRI_RESUMIDA
				CCF_IDSEJU,; //005-ID_SEC_JUD
				CCF_IDVARA,; //006-ID_VARA
				CCF_NATJU,;  //007-IND_NAT_ACAO_JUSTICA
				CCF_DESCJU,; //008-DESC_DEC_JUD
				CCF_DTSENT,; //009-DT_SENT_JUD
				CCF_NATAC,;  //010-IND_NAT_ACAO_RECEITA
				CCF_DTADM,;  //011-DT_DEC_ADM
				CCF_TPCOMP,; //012-TP_PROC 1-Judicial 2 - Administrativo
				CCF_INDAUT,; // 015-IND_AUTORIA
				CCF_UF,; 	 // 013-UF_VARA
				CCF_CODMUN,; //014-COD_MUN_VARA
				cDataIni,; //016-DT_INI_VAL FORMATO MMAAAA
				cDataFin;  //017-DT_FIN_VAL FORMATO MMAAAA
				 } ) )

				FConcTxt( aRegs,nHdlTxt )
				
			EndIf
						
			//GERAR O BLOCO T001AO
			
			While CCF->(!Eof()) .and. CCF->(CCF_FILIAL + CCF_NUMERO + CCF_TIPO) == xFilial("CCF") + padr(FKG->FKG_NUMPRO, nTamCCFNum) + FKG->FKG_TPPROC
			
				cReg := "T001AO" 
				aRegs := {}
				CCF->( Aadd( aRegs, {  cReg,; //REGISTRO):
				CCF_INDSUS,; //COD_SUSP
				CCF_SUSEXI,; //IND_SUSPENS
				CCF_DTADM,; //DT_DEC_ADM
				IIf(CCF_MONINT == "1", "S", "N"); //IND_DEPOSITO
				 } ) )
				
				FConcTxt( aRegs,nHdlTxt )
				
				CCF->(DBSkip())
				
			EndDo
	
			//Grava o registro na TABELA TAFST2 e limpa o array aDadosST1				
			If cTpSaida == "2" 
				FConcST1()
			EndIf	
			
		EndIf
	EndIf
	
	FKG->(DBSkip())
		
EndDo

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FFinT003 
Gera os registros do Layout FExpT003 - Participantes (Fornecedores e Clientes) 

@return lRet Retorna .t. para final de execu��o

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function FFinT003(nRecno,nCart, cAliasQry, aParticip, lFiltReinf, cFiltInt, _aListT003  )

Local cCodPart 		As Character
Local cCgc       	As Character
Local cTpPessoa  	As Character
Local cCodMun    	As Character
Local cEndereco  	As Character
Local cNum       	As Character
Local cComplem   	As Character
Local cBairro    	As Character
Local cUF        	As Character
Local cCEP       	As Character
Local cTel       	As Character
Local cPais      	As Character
Local cNome		 	As Character
Local cDDD		 	As Character
Local cFax		 	As Character
Local cEmail	 	As Character
Local cInscr	 	As Character
Local cSuframa	 	As Character
Local cIndNif    	As Character
Local cNif		 	As Character
Local cPaisEX	 	As Character
Local cEndEX	 	As Character
Local cNumEx	 	As Character
Local cComplEX	 	As Character
Local cBaiEX	 	As Character
Local cMunEX	 	As Character
Local cCepEX	 	As Character
Local cRelFont   	As Character
Local cRamoAtv	 	As Character
Local cDt		 	As Character
Local cContrib	 	As Character
Local cIndCP	 	As Character
Local cIseImun	 	As Character
Local cEstex	 	As Character
Local cTelre	 	As Character
Local cMotNif	 	As Character
Local cNifex	 	As Character
Local cTrBex	 	As Character
Local cReg       	As Character
Local cFilialTAF	As Character
Local cINDCPRB		As Character
Local cExecPAA		As Character
Local cDesport		As Character
Local nPOsicao	 	As Numeric
Local aGetEnd    	As Array
Local aRegs      	As Array
Local lRet			As Logical
Local lGeraT003		As Logical

//Bloco 40
Local cEstExt 		As Character
Local cTelExt 		As Character
Local cFormTrib 	As Character
Local cTpPeEx	 	As Character
Local aT003AB		As Array
Local nCont			As Numeric

Default nRecno 		:= 0
Default nCart 		:= 1
Default aParticip  	:= {}
Default _aListT003 	:= {}
Default lFiltReinf 	:= .F.
Default cFiltInt   	:= "3"

cCodPart  	:= ""
cCpf      	:= ""
cCgc     	:= ""
cTpPessoa 	:= ""
cCodMun   	:= ""
cEndereco 	:= ""
cNum       	:= ""
cComplem   	:= ""
cBairro    	:= ""
cUF        	:= ""
cCEP       	:= ""
cTel       	:= ""
cPais      	:= ""
cNome		:= ""
cDDD		:= ""
cFax		:= ""
cEmail	 	:= ""
cInscr	 	:= ""
cSuframa	:= ""
cIndNif    	:= ""
cNif		:= ""
cPaisEX	 	:= ""
cEndEX	 	:= ""
cNumEx	 	:= ""
cComplEX	:= ""
cBaiEX	 	:= ""
cMunEX	 	:= ""
cCepEX	 	:= ""
cRelFont   	:= ""
cRamoAtv	:= ""
cDt		 	:= ""
cContrib	:= ""
cIndCP	 	:= ""
cIseImun	:= ""
cEstex	 	:= ""
cTelre	 	:= ""
cMotNif	 	:= ""
cNifex	 	:= ""
cTrBex		:= ""
cReg       	:= "T003"
cFilialTAF	:= ""
cINDCPRB	:= ""
cExecPAA	:= ""
cDesport	:= ""
nPOsicao	:= 0
aRegs      	:= {}
lRet		:= .T.
lGeraT003	:= .T.
aGetEnd	  	:= {}

//Bloco 40
cEstExt	  	:= ""
cTelExt	  	:= ""
cFormTrib 	:= ""
cTpPeEx		:= ""
aT003AB		:= {}

If lFiltReinf .And. (cFiltInt $ "1|3" .Or. empty(cFiltInt))
	If nCart == 1 // A PAGAR
		DbSelectArea("SA2")
		DBSetOrder(1) //A2_FILIAL, A2_COD, A2_LOJA
		If SA2->(MsSeek( xFilial("SA2") +  (cAliasQry)->COD + (cAliasQry)->LOJA))
			cCodPart := (cAliasQry)->COD + (cAliasQry)->LOJA

			If lBuild
				nPosicao   := FindHash(oHashT003, cCodPart, .T.)
			Else
				nPosicao := aScan(__aCodA1,{|aX| aX[2]==cCodPart})
			EndIf	

			If nPosicao == 0

				If lBuild
					AddHash(oHashT003, cCodPart, nPosicao)
				Else
					aAdd(__aCodA1, {'', cCodPart})
				EndIf

				RegT003Pos("SA2", @aParticip )

				//Verifica se possui rateio entre CPF's (IR aluguel)
				If __lTemFKJ .And. (cAliasQry)->A2_IRPROG == '1'
					FForIrProg(@aParticip[1], cCodPart, Len(aParticip[1]))
				EndIf
			EndIf
		EndIf
	Else
		DbSelectArea("SA1")
		DBSetOrder(1) //A1_FILIAL, A1_COD, A1_LOJA
		If SA1->(MsSeek( xFilial("SA1") +  (cAliasQry)->COD + (cAliasQry)->LOJA))
			cCodPart := (cAliasQry)->COD + (cAliasQry)->LOJA

			IF lBuild
				nPosicao   := FindHash(oHashT003, cCodPart)
			Else
				nPosicao := aScan(aParticip,{|aX| aX[2]==cCodPart})
			EndIf	

			If nPosicao == 0

				If lBuild
					AddHash(oHashT003, cCodPart, nPosicao)
				EndIf
				
				RegT003Pos("SA1", @aParticip )
			EndIf
		EndIf
	EndIf
Else
	If nCart == 1 // A PAGAR
		DbSelectArea("SA2")
		DBSetOrder(1) //A2_FILIAL, A2_COD, A2_LOJA
		If SA2->(MsSeek( xFilial("SA2") +  (cAliasQry)->COD + (cAliasQry)->LOJA))
			cCodPart := RetPartTAF("FOR", (cAliasQry)->COD, (cAliasQry)->LOJA)
			
			If SA2->A2_TIPO == "F" //Pesssoa F�sica
				cCpf := SA2->A2_CGC 
				cTpPessoa := "1"
			ElseIf SA2->A2_TIPO == "J" .And. SA2->A2_IRPROG == "1" //PJ com IR prog considera como PF
				cCpf := SA2->A2_CPFIRP 
				cTpPessoa := "1"			
			ElseIf SA2->A2_TIPO == "J"  //Juridica
				cCgc := SA2->A2_CGC
				cTpPessoa := "2"
			Else //estrangeiro
				cCpf := ""
				cCGC := ""
				If Len(AllTrim(SA2->A2_CGC)) == 11
					cTpPessoa := "1"
				ElseIf Len(AllTrim(SA2->A2_CGC)) == 14
					cTpPessoa := "2"
				EndIf

				//Indicativo do N�mero de IdentIfica��o Fiscal:
				//	1 - Benefici�rio com NIf;
				//	2 - Benefici�rio dispensado do NIf;
				//	3 - Pa�s N�o exige NIf.

				cIndNif	:= IIf(!Empty(SA2->A2_NIFEX),"1", IIf( SA2->A2_MOTNIF == "1", "2", "3")  )
				cNif	:= SA2->A2_NIFEX
				cRelFont:= SA2->A2_BREEX
				cPaisEX := SA2->A2_PAISEX
				aGetEnd := FisGetEnd( SA2->A2_LOGEX, SA2->A2_EST )
				cEndEX 	:= aGetEnd[1]
				cNumEx 	:= Iif( !Empty( aGetEnd[2]) , aGetEnd[3], "SN" )
				cComplEX := SA2->A2_COMPLR
				cBaiEX 	:= SA2->A2_BAIEX
				cMunEX 	:= SA2->A2_CIDEX
				cCepEX 	:= SA2->A2_POSEX
				//Bloco 40
				cFormTrib:= SA2->A2_TRBEX
				cEstExt	:= SA2->A2_ESTEX
				cTelExt	:= SA2->A2_TELRE
			EndIf
			
			aGetEnd 	:= FisGetEnd( SA2->A2_END, SA2->A2_EST ) // fun��o do fiscal q separa o endere�o
			cEndereco	:= aGetEnd[1] 
			cNum 		:= Iif( !Empty( aGetEnd[2]) , aGetEnd[3], "SN" )
			cComplem	:= SA2->A2_COMPLEM
			cBairro		:= SA2->A2_BAIRRO
			cUF 		:= SA2->A2_EST
			cCEP 		:= SA2->A2_CEP
			cTel 		:= SA2->A2_TEL
			cNome		:= SA2->A2_NOME
			cDDD		:= SA2->A2_DDD
			cFax		:= SA2->A2_FAX
			cEmail		:= SA2->A2_EMAIL
			cInscr		:= SA2->A2_INSCR
			cDt			:= ""
			cContrib 	:= SA2->A2_CONTRIB
			cSuframa	:= ""
			cDesport	:= Iif(SA2->A2_DESPORT == "1", "1","2")
			cINDCPRB	:= Iif(SA2->A2_CPRB == "2" .or. Empty(SA2->A2_CPRB), "0", "1")  
			cExecPAA	:= ""
			cRamoAtv	:= IIf(!Empty(SA2->A2_TIPORUR),"4","")
			
			If SA2->A2_EST == "EX"
				cCodMun := "99999"
			Else
				cCodMun := SA2->A2_COD_MUN
			EndIf
			
			If Empty(SA2->A2_CODPAIS)
				cPais := ""
			Else
				cPais := padl(Alltrim(SA2->A2_CODPAIS),5,"0")
			EndIf

			If SA2->(FieldPos("A2_INDCP")) > 0
				cIndCP	 := SA2->A2_INDCP 
			EndIf	

			If SA2->(FieldPos("A2_ESTEX")) > 0
				cEstex	 := SA2->A2_ESTEX
			EndIf

			If  SA2->(FieldPos("A2_TELRE")) > 0
				cTelre 	:= SA2->A2_TELRE
			EndIf

			If  SA2->(FieldPos("A2_NIFEX")) > 0 .and. SA2->(FieldPos("A2_MOTNIF")) > 0
				cMotNif := IIf(!Empty(SA2->A2_NIFEX),"1",IIf(SA2->A2_MOTNIF=='1','2',IIf(SA2->A2_MOTNIF=='2','3',SA2->A2_MOTNIF)))
			EndIf

			If  SA2->(FieldPos("A2_NIFEX")) > 0
				cNifex := SA2->A2_NIFEX
			EndIf

			If SA2->(FieldPos("A2_TRBEX")) > 0
				cTrBex := SA2->A2_TRBEX
			EndIf

			If __lTemDKE //DKE: Tabela complementar da SA2	
				DbSelectArea("DKE") 
				DKE->(DBSetOrder(1)) //DKE_FILIAL+DKE_COD+DKE_LOJA
				If DKE->(MsSeek( SA2->(A2_FILIAL + A2_COD + A2_LOJA) ))
					cIseImun  := DKE->DKE_ISEIMU //1=Nao isenta;2=Inst.Educacional;3=Inst.Filantropica
					cTpPeEx   := DKE->DKE_PEEXTE //Tipo de Pessoa Exterior (1=Pessoa Fisica;2=Pessoa Juridica)
					cTpPessoa := cTpPeEx
				Endif
				If Empty(cIseImun)
					cIseImun := "1" //Entidade n�o isenta (Tributa��o normal);
				EndIf
			EndIf

		EndIf			
	Else // A Receber
		DbSelectArea("SA1")
		SA1->(DBSetOrder(1)) //A1_FILIAL, A1_COD, A1_LOJA
		If SA1->(MsSeek( xFilial("SA1") +  (cAliasQry)->COD + (cAliasQry)->LOJA))
			cCodPart := RetPartTAF("CLI", (cAliasQry)->COD, (cAliasQry)->LOJA)
			If SA1->A1_PESSOA == "F"
				cCpf := SA1->A1_CGC 
				cTpPessoa := "1"
			ElseIf SA1->A1_PESSOA == "J" 
				cCgc := SA1->A1_CGC
				cTpPessoa := "2"
			EndIf	
			
			aGetEnd 	:= FisGetEnd( SA1->A1_END, SA1->A1_EST ) // fun��o do fiscal q separa o endere�o
			cPais 		:= SA1->A1_PAIS
			cEndereco	:= aGetEnd[1] 
			cNum 		:= Iif( !Empty( aGetEnd[2]) , aGetEnd[3], "SN" )
			cComplem	:= SA1->A1_COMPLEM
			cBairro		:= SA1->A1_BAIRRO
			cUF 		:= SA1->A1_EST
			cCEP 		:= SA1->A1_CEP
			cTel 		:= SA1->A1_TEL
			cNome		:= SA1->A1_NOME
			cDDD		:= SA1->A1_DDD
			cFax		:= SA1->A1_FAX
			cEmail		:= SA1->A1_EMAIL
			cInscr		:= SA1->A1_INSCR
			cDt			:= SA1->A1_DTCAD
			cSuframa	:= SA1->A1_SUFRAMA
			cDesport	:= ""
			cContrib	:= ""
			cIndCP	 	:= ""
			cIseImun	:= ""
			cEstex	 	:= ""
			cTelre	 	:= ""
			cMotNif		:= ""
			cNifex	 	:= ""
			cTrBex	 	:= ""
			cTpPeEx		:= ""
			If SA1->A1_EST == "EX"
				cCodMun := "99999"
			Else
				cCodMun := SA1->A1_COD_MUN
			EndIf		

			If Empty(SA1->A1_CODPAIS)
				cPais := ""
			Else
				cPais := padl(Alltrim(SA1->A1_CODPAIS),5,"0")
			EndIf
			cINDCPRB := ""
			If lAI0_INDPAA
				cExecPAA := Posicione("AI0",1, SA1->(A1_FILIAL + A1_COD + A1_LOJA), "AI0_INDPAA")
			EndIf	
			cExecPAA := Iif(cExecPAA == "1", "1", "0")
			cRamoAtv	:= ""
			
		EndIf

	EndIf
		
	lGeraT003 := .T.
	If lIntTAF
	
		DbSelectArea("C1H")   
		C1H->(DbSetOrder(1)) //C1H_FILIAL, C1H_CODPAR
		
		DbSelectArea("C07")   
		C07->(DbSetOrder(3)) //C07_FILIAL, C07_ID
		
		DbSelectArea("C08")   
		C08->(DbSetOrder(3)) //C08_FILIAL, C08_ID
		
		DbSelectArea("C09")   
		C09->(DbSetOrder(3)) //C09_FILIAL, C09_ID
		
		DbSelectArea("AIF")	
		cFilialTAF:= FTafGetFil( allTrim( cEmpAnt ) + allTrim( cFilAnt ) , {} , "C1H" )
		dbSelectArea(cAliasQry)
		
		//Verifica se no TAF o registro existe e n�o ha alteracoes.
		//Caso exista e nao haja alteracoes nos campos,NAO geramos
		//o registro na TAFST2 para a integracao.
		If C1H->( MsSeek( cFilialTAF + PadR( cCodPart , TAMSX3("C1H_CODPAR")[1] ) ) )

			If  Alltrim(C1H->C1H_PPES)   == Alltrim(cTpPessoa)  .And. ;
				Alltrim(C1H->C1H_NOME)   == Alltrim(cNome)  .And. ;
				Alltrim(C1H->C1H_END)    == Alltrim(cEndereco)   .And. ;
				Alltrim(C1H->C1H_NUM)    == Alltrim(cNum)   .And. ;
				Alltrim(C1H->C1H_COMPL)  == Alltrim(cComplem) .And. ;
				Alltrim(C1H->C1H_BAIRRO) == Alltrim(cBairro).And. ;
				Alltrim(C1H->C1H_CEP)    == Alltrim(cCEP)   .And. ;
				Alltrim(C1H->C1H_DDD)    == Alltrim(cDDD)   .And. ;
				Alltrim(C1H->C1H_FONE)   == Alltrim(cTel)  .And. ;
				Alltrim(C1H->C1H_FAX)    == Alltrim(cFax)   .And. ;
				Alltrim(C1H->C1H_EMAIL)  == Alltrim(cEmail) .And. ;
				Alltrim(C1H->C1H_CNPJ)   == Alltrim(cCGC)  .And. ;
				Alltrim(C1H->C1H_CPF)    == Alltrim(cCPF)   .And. ;
				Alltrim(C1H->C1H_IE)     == Alltrim(cInscr)    .And. ;
				Alltrim(C1H->C1H_SUFRAM) == Alltrim(cSuframa) 
				
				If !Empty(cCodMun) .and. !Empty(C1H->C1H_CODMUN)
					If C07->( MsSeek( xFilial("C07") + C1H->C1H_CODMUN ) )
						If Alltrim(C07->C07_CODIGO) == Alltrim(cCodMun)
							lGeraT003 := .F.
						Else	
							lGeraT003 := .T.
						EndIf
					EndIf
				Else
					lGeraT003 := .T.
				EndIf
				
				If !lGeraT003 .and. !Empty(cPais) .and. !Empty(C1H->C1H_CODPAI)
					If C08->( MsSeek( xFilial("C08") + C1H->C1H_CODPAI ) )
						If Alltrim(C08->C08_CODIGO) == Alltrim( cPais )
							lGeraT003 := .F.
						EndIf
					EndIf
				Else
					lGeraT003 := .T.
				EndIf

				If !lGeraT003 .and. !Empty(cUF) .and. !Empty(C1H->C1H_UF)
					If C09->( MsSeek( xFilial("C09") + C1H->C1H_UF ) )
						If C09->C09_UF == cUF
							lGeraT003 := .F.
						EndIf
					EndIf
				Else
					lGeraT003 := .T.
				EndIf
				
				If !lGeraT003 .and. ( Alltrim(C1H->C1H_PAISEX) == Alltrim(cPaisEX) .AND. ;
					Alltrim(C1H->C1H_LOGEXT) == Alltrim(cEndEX)  .AND. ;
					Alltrim(C1H->C1H_NUMEXT) == Alltrim(cNumEx)  .AND. ;
					Alltrim(C1H->C1H_COMEXT) == Alltrim(cComplEX)  .AND. ;
					Alltrim(C1H->C1H_BAIEXT) == Alltrim(cBaiEX)  .AND. ;
					Alltrim(C1H->C1H_NMCEXT) == Alltrim(cMunEX)  .AND. ;
					Alltrim(C1H->C1H_CDPOSE) == Alltrim(cCepEX)  .AND. ;
					Alltrim(C1H->C1H_RELFON) == Alltrim(cRelFont) )
					lGeraT003 := .F.
				Else 
					lGeraT003 := .T.
				EndIf
				

			EndIf

		EndIf
		
	EndIf

	If lBuild
		nPosicao   := FindHash(oHashT003, cCodPart)
		If nPosicao == 0
			nPosicao := aScan(_aListT003,{|aX| AllTrim(aX[1])==AllTrim(cCodPart)})
		EndIf
	Else
		If nCart == 1
			nPosicao := aScan(__aCodA1,{|aX| aX[2]==cCodPart})
		Else
			nPosicao := aScan(aParticip,{|aX| aX[2]==cCodPart})
		EndIf
	EndIf

	If nPosicao == 0
		If lBuild
			AddHash(oHashT003, cCodPart, nPosicao)
		ElseIf nCart == 1
			aAdd(__aCodA1, {'', cCodPart})
		EndIf

		If lGeraT003
			lGerou := .T.

			aRegs := {}

			If __lDicAtu
				(cAliasQry)->( Aadd( aRegs, {  ;
				cReg,; 		// 001-TIPO REGISTRO
				cCodPart,;	// 002-CODIGO PARTIPANTE
				cNome,;		// 003-NOME
				cPais,;		// 004-COD_PAIS
				cCgc,;		// 005-CNPJ
				cCpf,;		// 006-CPF
				cInscr,;	// 007-IE
				cCodMun,;	// 008-COD_MUN
				cSuframa,;	// 009-SUFRAMA
				"",;		// 010-TP_LOGRA
				cEndereco,; // 011-ENDERECO
				cNum,; 		// 012-NUM
				cComplem,;	// 013-COMPLEM_END
				"",;		// 014-TP_BAIRRO
				cBairro,;	// 015-BAIRRO	
				cUF,;		// 016-UF
				cCEP,;		// 017-CEP
				cDDD,;		// 018-DDD
				cTel,;		// 019-FONE
				cDDD,;		// 020-DDD
				cFax,;		// 021-FAX
				cEmail,;	// 022-EMAIL
				cDt,; 		// 023-DT_INCLUSAO
				cTpPessoa,;	// 024-TP_PESSOA
				"",;		// 025-RAMO_ATIV
				"",;		// 026-COD_INST_ANP
				"",;		// 027-COD_ATIV
				cPaisEX,;	// 28-COD_PAIS_EXT
				cEndEX,;	// 29-LOGRAD_EXT
				cNumEx,;	// 30-NR_LOGRAD_EXT
				cComplEX,;	// 31-COMPLEM_EXT
				cBaiEX,;	// 32-BAIRRO_EXT
				cMunEX,;	// 33-NOME_CIDADE_EXT
				cCepEX,;	// 34-COD_POSTAL_EXT
				"",;		// 35-DT_LAUDO_MOLEST_GRAVE
				cRelFont,;	// 36-REL_FONTE_PAG_RESID_EXTERIOR
				"",;		// 37-INSCR_MUNICIPAL 
				"",;		// 38-SIMPLES_NACIONAL
				"",; 		//39-ENQUADRAMENTO
				"",; 		//40-OBSOLETO
				cINDCPRB,; 	//41-INDCPRB
				"",; 		//42-CODTRI
				cExecPAA,; 	//43-EXECPAA
				cDesport,;	//44-IND_ASSOC_DESPORT
				cContrib,;	//45-CONTRIBUINTE
				cIndCP,;	//46-INDOPCCP
				cIseImun,;	//47-ISENCAO_IMUNIDADE 
				cEstex,;	//48-ESTADO_EXT
				cTelre,; 	//49-TELEFONE_EXT
				cMotNif,;	//50-INDICATIVO_NIF
				cNifex,;	//51-NIF
				cTrBex,;    //52-FORMA_TRIBUTACAO
				cTpPeEx })) //53-TIPO_PESSOA_EXT
			Else
				(cAliasQry)->( Aadd( aRegs, {  ;
				cReg,; 		// 001-TIPO REGISTRO
				cCodPart,;	// 002-CODIGO PARTIPANTE
				cNome,;		// 003-NOME
				cPais,;		// 004-COD_PAIS
				cCgc,;		// 005-CNPJ
				cCpf,;		// 006-CPF
				cInscr,;	// 007-IE
				cCodMun,;	// 008-COD_MUN
				cSuframa,;	// 009-SUFRAMA
				"",;		// 010-TP_LOGRA
				cEndereco,; // 011-ENDERECO
				cNum,; 		// 012-NUM
				cComplem,;	// 013-COMPLEM_END
				"",;		// 014-TP_BAIRRO
				cBairro,;	// 015-BAIRRO	
				cUF,;		// 016-UF
				cCEP,;		// 017-CEP
				cDDD,;		// 018-DDD
				cTel,;		// 019-FONE
				cDDD,;		// 020-DDD
				cFax,;		// 021-FAX
				cEmail,;	// 022-EMAIL
				cDt,; 		// 023-DT_INCLUSAO
				cTpPessoa,;	// 024-TP_PESSOA
				"",;		// 025-RAMO_ATIV
				"",;		// 026-COD_INST_ANP
				"",;		// 027-COD_ATIV
				cPaisEX,;	// 28-COD_PAIS_EXT
				cEndEX,;	// 29-LOGRAD_EXT
				cNumEx,;	// 30-NR_LOGRAD_EXT
				cComplEX,;	// 31-COMPLEM_EXT
				cBaiEX,;	// 32-BAIRRO_EXT
				cMunEX,;	// 33-NOME_CIDADE_EXT
				cCepEX,;	// 34-COD_POSTAL_EXT
				"",;		// 35-DT_LAUDO_MOLEST_GRAVE
				cRelFont,;	// 36-REL_FONTE_PAG_RESID_EXTERIOR
				"",;		// 37-INSCR_MUNICIPAL 
				"",;		// 38-SIMPLES_NACIONAL
				"",; 		//39-ENQUADRAMENTO
				"",; 		//40-OBSOLETO
				cINDCPRB,; 	//41-INDCPRB
				"",; 		//42-CODTRI
				cExecPAA,; 	//43-EXECPAA
				cDesport,;	//44-IND_ASSOC_DESPORT
				cContrib,;	//45-CONTRIBUINTE
				cIndCP,;	//46-INDOPCCP
				cIseImun,;	//47-ISENCAO_IMUNIDADE 
				cEstex,;	//48-ESTADO_EXT
				cTelre,; 	//49-TELEFONE_EXT
				cMotNif,;	//50-INDICATIVO_NIF
				cNifex,;	//51-NIF
				cTrBex } ) ) //52-FORMA_TRIBUTACAO
			EndIf

			//Verifica se possui rateio entre CPF's (IR aluguel)
			If __lTemFKJ .And. nCart == 1 .And. (cAliasQry)->A2_IRPROG == '1'
				FForIrProg(@aRegs, Right(cCodPart, nTamE2For + nTamE2Lj), Len(aRegs))
			EndIf

			FConcTxt( aRegs, nHdlTxt )
			
			//Gera T003AB (dependentes)
			If nCart == 1 .And. __lDicAtu //Carteira a pagar
				//Verifica se o fornecedor possui dependentes vinculados (tabela DHT)
				DbSelectArea("DHT") 
				DHT->(DBSetOrder(1)) //DHT_FILIAL, DHT_FORN, DHT_LOJA, DHT_CPF
				IF DHT->(MsSeek( xFilial("DHT")+SA2->(A2_COD+A2_LOJA)) )
					While DHT->(!Eof()) .and. DHT->(DHT_FILIAL+DHT_FORN+DHT_LOJA) == SA2->(A2_FILIAL+A2_COD+A2_LOJA)
						Aadd(aT003AB,{})
						nCont := Len(aT003AB)

						Aadd(aT003AB[nCont],{"T003AB", DHT->DHT_COD,DHT->DHT_CPF,DHT->DHT_NOME,DHT->DHT_RELACA})
						FConcTxt(aT003AB[nCont],nHdlTxt)	
							
						DHT->(DbSkip())
					EndDo
				EndIF
				DHT->(DbCloseArea())
			Endif

			//Grava o registro na TABELA TAFST2 e limpa o array aDadosST1
			If cTpSaida == "2"
				FConcST1()
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FFinT154
Gera os registros do Layout FExpT154 (fatura/recibo) de:
	- Titulos a receber com INSS
	- Titulos a pagar com INSS
	- Titulos a receber com auto-retencao do IRRF (bloco 40)
	- Titulos a pagar com IRRF (bloco 40)
	- Titulos a pagar com PIS, COFINS e CSLL (bloco 40)

@param nRecno - Caso queira exportar somente um recno em especifico
@return lRet Retorna .T. para final de execu��o

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function FFinT154(nRecno, nCart, cAliasQry, oProcess, cCtrlT154, cRefNF, cBxFin, cIdDoc )

Local dDataEmis	 As Date
Local lRet 		 As Logical
Local lGera154	 As Logical
Local lCalcIssBx As Logical
Local lOrigNF    As Logical
Local aRegs		 As Array
Local aAreaSF2	 As Array
Local aProcJud	 As Array
Local cReg		 As Character
Local cNumTit	 As Character
Local cNumNF	 As Character
Local cPrefixo	 As Character
Local cSerie	 As Character
Local cTipoNF	 As Character
Local cParcela	 As Character
Local cContaAnlt As Character
Local cTpRepasse As Character
Local cTpServico As Character
Local cCodPart	 As Character
Local cHist		 As Character
Local cEspecie	 As Character
Local cCNO		 As Character
Local cTpInsc	 As Character
Local cTpProc	 As Character
Local cIndProc	 As Character
Local nI		 As Numeric
Local nVlrBruto	 As Numeric
Local nVlrParc	 As Numeric
Local nVlrMat	 As Numeric
Local nVlrAlim	 As Numeric
Local nVlrTrans	 As Numeric
Local nVlrSub	 As Numeric
Local nVlrDedPr	 As Numeric
Local nVlrAdiPr	 As Numeric
Local nVlrBaseIN As Numeric
Local nVlrCP	 As Numeric
Local nVlrGilrat As Numeric
Local nVlrSenar	 As Numeric
Local nVlrRetenc As Numeric
Local nAPos15	 As Numeric
Local nAPos20	 As Numeric
Local nAPos25	 As Numeric
Local nVlrAdic 	 As Numeric

// Bloco 40
Local cCNPJSCP	 As Character
Local cImpINS	 As Character
Local cImpIR	 As Character
Local cNatPagRec As Character
Local cIndScp    As Character
Local cOldNatRen As Character
Local cTpAtrb    As Character
Local aDetDed	 As Array
Local aDetIse	 As Array
Local aT154AF    As Array
Local aT154AL    As Array
Local aT154TRB   As Array
Local nX         As Numeric
Local nW         As Numeric
Local nY         As Numeric
Local nZ         As Numeric
Local lFlagFKF	 As Logical
Local lBlc20	 As Logical
Local lIrBaixa   As Logical
Local lFornPF    As Logical
Local lTemFkw    As Logical
Local lIsento    As Logical
Local lSuspFKW   As Logical
Local lTribFKW   As Logical

Default nRecno 		:= 0
Default oProcess	:= Nil
Default cCtrlT154 	:= '0'
Default cRefNF		:= ""
Default nCart		:= 1
Default cAliasQry	:= ""
Default cBxFin		:= ""
Default cIdDoc		:= ""

DbSelectArea("FKG")
FKG->(DBSetOrder(2)) //FKG_FILIAL+FKG_IDDOC+FKG_TPIMP

DbSelectArea("SFT")
SFT->(DBSetOrder(1)) //FT_FILIAL, FT_TIPOMOV, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA, FT_ITEM, FT_PRODUTO

DbSelectArea("CCF")
CCF->(DBSetOrder(1)) // CCF_FILIAL, CCF_NUMERO, CCF_TIPO

cReg	   := "T154"
dDataEmis  := CTOD("  /  /    ")
lRet       := .T.
lGera154   := .T.
lCalcIssBx := IsIssBx("P")
aRegs	   := {}
aAreaSF2   := SF2->( GetArea() )
aProcJud   := {}
aT154AF    := {}
aT154AL    := {}
cCNO	   := ""
cTpInsc	   := ""
nVlrBruto  := 0
nVlrParc   := 0
nVlrRetenc := 0
cNumTit    := ""
cNumNF     := ""
cSerie     := ""
cTipoNF    := "" 	
nVlrBaseIN := 0	
nVlrCP     := 0
nVlrGilrat := 0
nVlrSenar  := 0
cEspecie   := ""
nVlrMat	   := 0
nVlrAlim   := 0
nVlrTrans  := 0
nVlrDedPr  := 0
nVlrAdiPr  := 0
nVlrSub	   := 0
nVlrAdic   := 0
nAPos15    := 0
nAPos20    := 0
nAPos25    := 0 
lIrBaixa   := .F.
cIndScp    := ""
lFornPF	   := .F.
lTemFkw    := .F.
cCNPJSCP   := ""
aDetDed	   := {}
aDetIse	   := {}
aT154TRB   := {}
lIsento    := .F.
cImpINS	   := PadR( 'INSS', __nFkgImp )
cImpIR	   := PadR( 'IRF', __nFkgImp )
cNatPagRec := ""
cOldNatRen := ""
lOrigNF    := .F.
lFlagFKF   := .T.

/*-------------------------------------------------------------------------------------------|
| Tratamento p/ os eventos R-2030/R-2040 quanto optado para gerar pela baixa, e o t�tulo j�  |
| esteja integrado (FKF_REINF=1). Deve garantir que a tabelas T154 (pai) seja enviada para o |
| TAF quando ocorrer as baixas, pois ser� gerada a tabela T154AC (filha).					 |
--------------------------------------------------------------------------------------------*/
If !Empty(cBxFin) .And. Select(cBxFin) > 0
	lBlc20 := .T.
Else
	lBlc20 := .F.
EndIf

If __lVerFlag .And. !lBlc20
	lFlagFKF   := (cAliasQry)->FKF_REINF <> '1' //Verifica o flag de integra��o dos t�tulos
Endif

If nCart == 1
	lIrBaixa   := (cAliasQry)->A2_CALCIRF == "2"
	lFornPF    := (cAliasQry)->A2_TIPO == "F" .Or. ((cAliasQry)->A2_TIPO == "J" .And. (cAliasQry)->A2_IRPROG == "1")//PJ c/ IR Progressivo, ser� tratado como Pessoa F�sica.
EndIf

//Verifica se o titulo tem complemento de imposto na tabela FKG para o INSS (legado)
If FKG->( MsSeek( xFilial("FKG") + cIdDoc ) )

	While FKG->( !Eof() ) .And. Alltrim( FKG->( FKG_FILIAL + FKG_IDDOC ) ) == Alltrim( xFilial("FKG") + cIdDoc )

		cTpAtrb := AllTrim( FKG->FKG_TPATRB )

		If FKG->FKG_TPIMP == cImpINS
			// APLICA 1 - BASE e DEDU��O
			If FKG->FKG_APLICA == '1' .and. FKG->FKG_DEDACR == '1'
				If cTpAtrb == '001' // MATERIAL
					nVlrMat += FKG->FKG_VALOR
				ElseIf cTpAtrb == '002' // ALIMENTA�AO
					nVlrAlim += FKG->FKG_VALOR
				ElseIf cTpAtrb == '003' // TRANSPORTE
					nVlrTrans += FKG->FKG_VALOR
				EndIf

			ElseIf FKG->FKG_APLICA == '2' .and. FKG->FKG_DEDACR == '1'		//APLICA 2 - VALOR E DEDUCAO
					
				If cTpAtrb == '004' // Processo Judicial
				
					If CCF->(MsSeek(xFilial("CCF") + padr(FKG->FKG_NUMPRO, nTamCCFNum) +  FKG->FKG_TPPROC)) 
						
						While CCF->(!Eof()) .and. CCF->(CCF_FILIAL + CCF_NUMERO + CCF_TIPO ) == xFilial("CCF") + padr(FKG->FKG_NUMPRO, nTamCCFNum) +  FKG->FKG_TPPROC
							If Empty(FKG->FKG_CODSUS) .or. Alltrim(CCF->CCF_INDSUS) == Alltrim(FKG->FKG_CODSUS) 
								If CCF->CCF_TRIB == '1' // Colocar tratamento para apsentadoria normal
								
									cTpProc := "1"
									cIndProc   := CCF->CCF_TIPO
							
									nVlrDedPr += FKG->FKG_VALOR
								
									AAdd(aProcJud,{cTpProc,cIndProc, FKG->FKG_VALOR, FKG->FKG_NUMPRO,'13', FKG->FKG_CODSUS}) // depois q decidir sobre o cod_SUSP incluir no array 
								ElseIf CCF->CCF_TRIB == '2' // Colocar tratamento para apsentadoria especial
								
									cTpProc := "2" 
									cIndProc   := 	CCF->CCF_TIPO
									
									nVlrAdiPr += 	FKG->FKG_VALOR
								
									AAdd(aProcJud,{cTpProc,cIndProc, FKG->FKG_VALOR,FKG->FKG_NUMPRO,'13', FKG->FKG_CODSUS}) // depois q decidir sobre o cod_SUSP incluir no array
								EndIf
							EndIf	
							CCF->(DBskip())
						EndDo	
						
					EndIf	
					
				ElseIf cTpAtrb == '005' // Subcontratada
					nVlrSub += FKG->FKG_VALOR	
				EndIf
			EndIf
		
			If FKG->FKG_APLICA == '2' .and. FKG->FKG_DEDACR != '1' // Aplicacao por Valor e Acrescimo
				If cTpAtrb == '007' //APOSENTADORIA ESPECIAL 15 ANOS                     
					If FKG->FKG_APLICA == '2'
						nAPos15 += FKG->FKG_BASECA
						nVlrAdic += FKG->FKG_VALOR
					EndIf
				ElseIf cTpAtrb == '008' //APOSENTADORIA ESPECIAL 20 ANOS
					If FKG->FKG_APLICA == '2'
						nAPos20 += FKG->FKG_BASECA
						nVlrAdic += FKG->FKG_VALOR
					EndIf
				ElseIf cTpAtrb == '009' //APOSENTADORIA ESPECIAL 25 ANOS                         
					If FKG->FKG_APLICA == '2'
						nAPos25 += FKG->FKG_BASECA
						nVlrAdic += FKG->FKG_VALOR
					EndIF 
				EndIf
			EndIf
		EndIf		
		
		FKG->( DBSkip() )
	EndDo
Endif

If nCart == 1  // A PAGAR

	cPrefixo   := (cAliasQry)->E2_PREFIXO	
	cParcela   := padr(Alltrim((cAliasQry)->E2_PARCELA), nTamE2Par)
	cCodPart   := RetPartTAF("FOR", (cAliasQry)->COD, (cAliasQry)->LOJA)
	cHist	   := (cAliasQry)->E2_HIST
	cContaAnlt := (cAliasQry)->E2_CONTAD
	cTpRepasse := (cAliasQry)->FKF_TPREPA
	cTpServico := ""
	cTipoFat   := "3" // 3-Titulo Avulso	2 - Desdobramento
	nVlrBruto  := 0 

	If nTpEmData == 1
		dDataEmis := STOD((cAliasQry)->E2_EMIS1)
	Else
		dDataEmis := STOD((cAliasQry)->E2_EMISSAO)
	Endif

	If !Empty((cAliasQry)->FKF_TPSERV)
		cTpServico := "1" + padl((cAliasQry)->FKF_TPSERV, 8 ,"0")
	Endif

	If __lDicAtu .and. !Empty(cIdDoc)
		lTemFkw := FTemFKW(cIdDoc) 	//Retorna se o titulo possui natureza de rendimento
	EndIf

	If Alltrim((cAliasQry)->E2_ORIGEM) $ "MATA461|MATA460|MATA103|MATA100"

		cNumNF	:= padr(Alltrim((cAliasQry)->E2_NUM), nTamFTDoc)
		cSerie	:= padr(Alltrim((cAliasQry)->E2_PREFIXO), nTamFTSer)

		If SFT->(MsSeek(xFilial("SFT") + "E" +  cSerie + cNumNF + (cAliasQry)->COD + (cAliasQry)->LOJA ) )
			cEspecie := AModNot( SFT->FT_ESPECIE )
                
			//Tratamento para NFS
            If Empty(cEspecie)
            	cEspecie := "01"
            EndIf
			
			cTipoFat := "1" // Titulo oriundo de nota
			cNumNF 	:= padr(Alltrim(cNumNF), nTamE1Num)
			dDataEmis := SFT->FT_EMISSAO
			
			If cRefNF <> cNumNF+cSerie 
				cRefNF := cNumNF+cSerie
				cCtrlT154 := '0'
				lOrigNF   := .T.
			EndIf
			
			cCtrlT154 := IF(cCtrlT154 == '0','1',cCtrlT154)
			cNumTit   := Alltrim((cAliasQry)->E2_NUM)
			nVlrBruto := 0

			While SFT->(!Eof()) .and. SFT->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA) ==  (xFilial("SFT") + "E" +  cSerie + cNumNF + (cAliasQry)->COD + (cAliasQry)->LOJA)
				nVlrBruto += SFT->FT_VALCONT
				SFT->(DBSkip())
			EndDo

		ElseIf !lTemFkw
			//Se nao tem FKW, so gera T154 para o legado (INSS - tipo de servi�o/repasse)
			If EMPTY(cTpServico) .AND. EMPTY(cTpRepasse)
				lGera154 := .F.
			EndIf
			cNumNF    := ""
			cSerie    := ""		
			cEspecie  := "" 
			cCtrlT154 := '0'
			If !Empty(cParcela)
				cNumTit  := Alltrim((cAliasQry)->E2_NUM) + "-" + cParcela
			Else
				cNumTit  := Alltrim((cAliasQry)->E2_NUM) 
			Endif			
		Else 
			//Titulo de nota fiscal que n�o gerou livro fiscal (SF3/SFT)
			cCtrlT154	:= '1'
			cRefNF		:= ''
			If !Empty(cParcela)
				cNumTit  := Alltrim((cAliasQry)->E2_NUM) + "-" + cParcela
			Else
				cNumTit  := Alltrim((cAliasQry)->E2_NUM) 
			Endif		
		EndIf
	Else 
		//Titulo avulso
		cCtrlT154 := '1'
		cRefNF := ''
		If !Empty(cParcela)
			cNumTit  := Alltrim((cAliasQry)->E2_NUM) + "-" + cParcela
		Else
			cNumTit  := Alltrim((cAliasQry)->E2_NUM) 
		Endif		
	EndIf	
	
	nVlrBaseIN := (cAliasQry)->E2_BASEINS - nVlrMat - nVlrAlim - nVlrTrans
	
	nVlrParc := (cAliasQry)->(E2_VLCRUZ + E2_INSS + (If( (cAliasQry)->A2_CALCIRF == "2" ,0,E2_IRRF))+;
				If(!lCalcIssBx,E2_ISS,0) + E2_SEST + If(_lPCCBaixa,0,E2_PIS+E2_COFINS+E2_CSLL))
	
	If Empty(cNumNF)
		nVlrBruto := nVlrParc
	EndIf

	If (cAliasQry)->ED_CALCINS == "S" .and. (cAliasQry)->A2_RECINSS == "S"
		If nVlrMat + nVlrTrans + nVlrAlim > 0 
			nVlrRetenc := (cAliasQry)->E2_INSS
		Else
			nVlrRetenc := (cAliasQry)->FKF_ORIINS
		Endif
	Else	
		nVlrRetenc := (cAliasQry)->E2_INSS
	EndIf
	
	//Indica se � um t�tulo relacionado a uma SCP (sociedade em conta de participa��o)
	If __lDicAtu .And. !Empty((cAliasQry)->FKF_CGCSCP) .and. lTemFkw
		cIndScp  := "2"
	Endif

Else // A RECEBER

	cPrefixo   := (cAliasQry)->E1_PREFIXO	
	cParcela   := padr(Alltrim((cAliasQry)->E1_PARCELA), nTamE1Par)
	cCodPart   := RetPartTAF("CLI", (cAliasQry)->COD, (cAliasQry)->LOJA)
	cHist	   := (cAliasQry)->E1_HIST
	cContaAnlt := (cAliasQry)->E1_CONTA
	cTpRepasse := (cAliasQry)->FKF_TPREPA
	cTpServico := ""
	cTipoFat   := "3" // 3-Titulo Avulso	2 - Desdobramento
	nVlrBruto  := 0 

	If nTpEmData == 1
		dDataEmis := (cAliasQry)->E1_EMIS1
	Else
		dDataEmis := (cAliasQry)->E1_EMISSAO
	Endif

	If !Empty((cAliasQry)->FKF_TPSERV)
		cTpServico := "1" + padl((cAliasQry)->FKF_TPSERV, 8 ,"0")
	Endif

	If alltrim((cAliasQry)->E1_ORIGEM) $ "MATA461|MATA460|MATA103|MATA100"
		cNumNF	:= padr(Alltrim((cAliasQry)->E1_NUM), nTamFTDoc)
		cSerie	:= padr(Alltrim((cAliasQry)->E1_SERIE), nTamFTSer)
		If SFT->(MsSeek(xFilial("SFT") + "S" +  cSerie + cNumNF + (cAliasQry)->COD + (cAliasQry)->LOJA ) )

			cEspecie := AModNot( SFT->FT_ESPECIE )
                
			//Tratamento para NFS
            If Empty(cEspecie)
            	cEspecie := "01"
            EndIf

			cTipoFat := "1" // Titulo oriundo de nota
			cNumNF 	:= padr(Alltrim(cNumNF), nTamE1Num)
			dDataEmis := SFT->FT_EMISSAO
			
			If cRefNF <> cNumNF+cSerie 
				cRefNF := cNumNF+cSerie
				cCtrlT154 := '0'
			EndIf
			
			cCtrlT154 := IF(cCtrlT154 == '0','1',cCtrlT154)
			cNumTit  := Alltrim((cAliasQry)->E1_NUM)
			nVlrBruto := 0
			
			While SFT->(!Eof()) .and. SFT->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA) ==  (xFilial("SFT") + "S" +  cSerie + cNumNF + (cAliasQry)->COD + (cAliasQry)->LOJA)
				nVlrBruto += SFT->FT_VALCONT
				SFT->(DBSkip())
			EndDo
			
		Else
			//Trata titulos de nota fiscal que n�o gerou livro fiscal (SF3/SFT)
			If EMPTY(cTpServico) .AND. EMPTY(cTpRepasse)
				lGera154 := .F.
			EndIf
			cNumNF := ""
			cSerie  := ""		
			cEspecie := "" 
			cCtrlT154 := '0'
			If !Empty(cParcela)
				cNumTit  := Alltrim((cAliasQry)->E1_NUM) + "-" + cParcela
			Else
				cNumTit  := Alltrim((cAliasQry)->E1_NUM) 
			Endif	
		EndIf
	Else
		//Titulo avulso
		cCtrlT154 := '1'
		cRefNF := ''
		If !Empty(cParcela)
			cNumTit  := Alltrim((cAliasQry)->E1_NUM) + "-" + cParcela
		Else
			cNumTit  := Alltrim((cAliasQry)->E1_NUM) 
		Endif	
	EndIf	
	
	nVlrBaseIN := (cAliasQry)->E1_BASEINS - nVlrMat - nVlrAlim - nVlrTrans
	
	nVlrParc := (cAliasQry)->E1_VLCRUZ
	If Empty(cNumNF)
		nVlrBruto := nVlrParc
	EndIf
	
	If (cAliasQry)->ED_CALCINS == "S" .and. (cAliasQry)->A1_RECINSS == "S"
		IF nVlrMat + nVlrTrans + nVlrAlim > 0 
			nVlrRetenc := (cAliasQry)->E1_INSS			
		Else
			nVlrRetenc := (cAliasQry)->FKF_ORIINS
		ENDIF
	Else	
		nVlrRetenc := (cAliasQry)->E1_INSS
	EndIf
EndIf

If !Empty((cAliasQry)->FKF_CNO)
	DbSelectArea("SON")
	SON->(DBSetOrder(1)) //ON_FILIAL, ON_CODIGO
	If SON->(MsSeek(xFilial("SON") + (cAliasQry)->FKF_CNO ))
		cCNO := Alltrim(SON->ON_CNO)
		cTpInsc := Alltrim(SON->ON_TPINSCR)
	EndIf
EndIf

If lGera154 .AND. cCtrlT154 == '1' .AND. lFlagFKF
	__lGer154:= lGerou := .T.

	FWFreeArray(aRegs)
	aRegs 		:= {}
	cReg    	:= "T154" //Cadastro de fatura/recibo

	If nCart==1
		cNatPagRec  := "0"
	Else
		cNatPagRec  := "1"		
	EndIf

	//Para rateio de CPF's no IR aluguel, obtem o cod. participante e o vlr bruto
	If nCart == 1 .And. AllTrim(cAliasQry) != 'BXFINCP' .And. __lTemFKJ .And. !Empty((cAliasQry)->FKJ_CPF)
		cCodPart	:= FBlcIrProg(cAliasQry, @nVlrBruto)
		nVlrParc	:= nVlrBruto
	EndIf

	If __lDicAtu //Monta o registro T154 com as adequacoes para o layout do TAF 2.1.1
		Aadd( aRegs, {  ;
		cReg,; 					//01-TIPO REGISTRO
		cNumTit,;				//02-NUMERO
		cPrefixo,; 				//03-SERIE
		cCodPart ,; 			//04-COD_PARTICIPANTE
		dDataEmis,; 			//05-EMISSAO
		cNatPagRec,;			//06-NATUREZ 0-PAGAR 1-RECEBER
		cHist,; 				//07-OBSERVACAO
		cEspecie,;				//08-CODMOD_DOC
		cNumNF,; 				//09-NUM_DOC
		cSerie,; 				//10-SER_DOC
		"",;					//11-SUBSER_DOC
		nVlrBruto,	;			//12-VLR_BRUTO
		"",;					//13-TP_PROC_RET_PRIN_N_EFET_INSS-obsoleto
		"",;					//14-NR_PROC_RET_PRIN_N_EFET_INSS-obsoleto
		"",;					//15-TP_PROC_RET_ADC_N_EFET_INSS-obsoleto
		"",;					//16-NR_PROC_RET_ADC_N_EFET_INSS-obsoleto
		"",;					//17-COD_CONT_ANAL-obsoleto
		"",;					//18-TP_REPASSE-obsoleto
		"",;					//19-TP_PROC_COMERC_RURAL-obsoleto
		"",;					//20-NR_PROC_COMERC_RURAL-obsoleto
		0,;						//21-VLR_CP-obsoleto
		0,;						//22-VLR_GILRAT-obsoleto
		0,;						//23-VLR_SENAR-obsoleto
		0,;						//24-VLR_CP_SUSP-obsoleto
		0,;						//25-VLR_RAT_SUSP-obsoleto
		0,;						//26-VLR_SENAR_SUSP-obsoleto
		0,;						//27-VLR_PREV_PRIVADA-obsoleto
		0,;						//28-VLR_FAPI-obsoleto
		0,;						//29-VLR_FUNPRESP-obsoleto
		0,;						//30-VLR_PENSAO_ALI-obsoleto
		"",;					//31-TP_PROC_RRA-obsoleto
		"",;					//32-NUM_PROC_RRA-obsoleto
		"",;					//33-NAT_RRA-obsoleto
		0,;						//34-QTD_MESES_RRA-obsoleto
		"",;					//35-NUM_PROC_DM-obsoleto
		"",;					//36-IND_ORIG_REC-obsoleto
		"",;					//37-CNPJ_ORI_REC_DM-obsoleto
		cTipoFat,;				//38-TIPO_RECIBO_FATURA
		"",;					//39-COD_SERV_MUN - 
		"",;					//40-LOC_PRESTACAO 
		"",;					//41-OBSOLETO
		"",;					//42-OBSOLETO
		"",;					//43-TIPDOC	
		cCNO,;					//44-NR_INSC_ESTAB
		cTpInsc,;				//45-TP_INSCRICAO		
		"",; 					//46-UNQ_INT - ID de integra��o �nica
		"",; 					//47-INDISE
		0,; 					//48-VLRCP
		0,; 					//49-VLRGIL
		0,; 					//50-VLRSEN
		"",;					//51-INDJUD
		cIndScp })				//52-INDFCISCP
	Else
		//Monta o registro T154 com o layout anterior do TAF (1.5.1)
		Aadd( aRegs, {  ;
		cReg,; 					//01-TIPO REGISTRO
		cNumTit,;				//02-NUMERO
		cPrefixo,; 				//03-SERIE
		cCodPart ,; 			//04-COD_PARTICIPANTE
		dDataEmis,; 			//05-EMISSAO
		cNatPagRec,;			//06-NATUREZ 0-PAGAR 1-RECEBER
		cHist,; 				//07-OBSERVACAO
		cEspecie,;				//08-CODMOD_DOC
		cNumNF,; 				//09-NUM_DOC
		cSerie,; 				//10-SER_DOC
		"",;					//11-SUBSER_DOC
		nVlrBruto,	;			//12-VLR_BRUTO
		"",;					//13-TP_PROC_RET_PRIN_N_EFET_INSS-obsoleto
		"",;					//14-NR_PROC_RET_PRIN_N_EFET_INSS-obsoleto
		"",;					//15-TP_PROC_RET_ADC_N_EFET_INSS-obsoleto
		"",;					//16-NR_PROC_RET_ADC_N_EFET_INSS-obsoleto
		"",;					//17-COD_CONT_ANAL-obsoleto
		"",;					//18-TP_REPASSE-obsoleto
		"",;					//19-TP_PROC_COMERC_RURAL-obsoleto
		"",;					//20-NR_PROC_COMERC_RURAL-obsoleto
		0,;						//21-VLR_CP-obsoleto
		0,;						//22-VLR_GILRAT-obsoleto
		0,;						//23-VLR_SENAR-obsoleto
		0,;						//24-VLR_CP_SUSP-obsoleto
		0,;						//25-VLR_RAT_SUSP-obsoleto
		0,;						//26-VLR_SENAR_SUSP-obsoleto
		0,;						//27-VLR_PREV_PRIVADA-obsoleto
		0,;						//28-VLR_FAPI-obsoleto
		0,;						//29-VLR_FUNPRESP-obsoleto
		0,;						//30-VLR_PENSAO_ALI-obsoleto
		"",;					//31-TP_PROC_RRA-obsoleto
		"",;					//32-NUM_PROC_RRA-obsoleto
		"",;					//33-NAT_RRA-obsoleto
		0,;						//34-QTD_MESES_RRA-obsoleto
		"",;					//35-NUM_PROC_DM-obsoleto
		"",;					//36-IND_ORIG_REC-obsoleto
		"",;					//37-CNPJ_ORI_REC_DM-obsoleto
		cTipoFat,;				//38-TIPO_RECIBO_FATURA
		"",;					//39-COD_SERV_MUN - 
		"",;					//40-LOC_PRESTACAO 
		"",;					//41-OBSOLETO
		"",;					//42-OBSOLETO
		"",;					//43-TIPDOC	
		cCNO,;					//44-NR_INSC_ESTAB
		cTpInsc})				//45-TP_INSCRICAO		
	Endif
	
	FConcTxt( aRegs, nHdlTxt)
	cCtrlT154 := '2'

	If (!EMPTY(cTpServico) .OR. !EMPTY(cTpRepasse))  .AND. lGerT154AA
	
		FWFreeArray(aRegs)
		aRegs := {}
		cReg  := "T154AA" //Tipo de Servi�o	

		Aadd( aRegs, {  ;
		cReg,; 					//01-TIPO REGISTRO
		cTpServico,;			//02-TIP_SERV
		nVlrBaseIN,; 			//03-VLR_BASE_CALCULO_INSS
		nVlrRetenc, ; 			//04-VALOR_TRIBUTO_INSS
		nVlrSub,; 				//05-VLR_RET_SERV_SUBCONTRAT_INSS
		nVlrDedPr,;				//06-VLR_RET_PRIN_N_EFET_INSS
		nAPos15,; 				//07-VLR_SER_15_ANOS
		nAPos20,;				//08-VLR_SER_20_ANOS
		nAPos25,; 				//09-VLR_SER_25_ANOS
		nVlrAdic,; 				//10-VLR_ADICIONAL
		nVlrAdiPr,;				//11-VLR_RET_ADV_N_EFET_INSS
		cTpRepasse,	;			//12-TPREPASSE
		IIf(!Empty(cTpRepasse), Posicione("SX5",1,xFilial("SX5") + "0G" + cTpRepasse, "X5_DESCRI"),""),; //13-DESCRECURSO
		IIf(!Empty(cTpRepasse),nVlrBruto,0),;	//14-VLRBRUTO
		IIf(!Empty(cTpRepasse),nVlrRetenc,0);	//15-VLRRETAPUR
		})
			
		FConcTxt( aRegs, nHdlTxt)

	EndIf

	/*---------------------------------------|
	| C�digos de tributos no layout do TAF:	 | 
	| 10=PIS;								 |
	| 11=Cofins;							 |
	| 12=IR emiss�o;					 	 |
	| 13=INSS;								 |
	| 18=CSLL;								 |	
	| 28=IR baixa 							 |
	----------------------------------------*/		

	//Monta o registro TT154AF para INSS (suspen��o de tributos)
	For nI := 1 to Len(aProcJud)

		FWFreeArray(aRegs)
		aRegs := {}
		cReg         := "T154AF" // Indicativo de Suspens�o por processo judicial/administrativo

		If __lDicAtu //Monta o registro T154AF para o INSS com as adequacoes para o layout do TAF 2.1.1
			If aProcJud[nI][5] $ "13" //Se for INSS
				AAdd( aRegs, {	cReg,;				//01 - REGISTRO - Tipo de Registro
								aProcJud[nI][1],;	//02 - TP_PROC - Tipo de processo
								aProcJud[nI][4],;	//03 - NUM_PROC - Identifica��o do processo ou ato concess�rio
								aProcJud[nI][2],;	//04 - IND_PROC - Indicador da origem do processo (0 - SEFAZ; 1 - Justi�a Federal; 2 - Justi�a Estadual; 3 � Secretaria da Receita Federal do Brasil; 9 � Outros)
								aProcJud[nI][6],;	//05 - COD_SUS - C�digo do Indicativo da Suspens�o
								aProcJud[nI][3],;	//06 - VAL_SUS - Valor da reten��o de contribui��o previdenci�ria principal que deixou de ser efetuada em fun��o de processo administrativo ou judicial
								aProcJud[nI][5],;	//07 - COD_TRIB - Informar o codigo que corresponde ao tributo
								""			   ,;	//08 - NATUREZA_RENDIMENTO - C�digo da natureza de rendimento
								0			   ,;	//09 - BASE_SUSPENSA - Valor da base de c�lculo do tributo com exigibilidade suspensa
								0              ,;	//10 - VLR_COMP_ANO_CALENDARIO - Compensa��o Judicial relativa ao ano calend�rio
								0              })	//11 - VLR_COMP_ANO_ANT - Compensa��o Judicial relativa a anos anteriores ao ano calend�rio.
				FConcTxt( aRegs, nHdlTxt)
			Endif
		Else
			//Monta o registro TT154AF com o layout anterior do TAF (1.5.1)
			Aadd( aRegs, {  ;
				cReg,; 						//01-TIPO REGISTRO
				aProcJud[ni][1] ,;			//02-TP_PROC
				aProcJud[ni][4],; 			//03-NUM_PROC
				aProcJud[ni][2],; 			//04-IND_PROC
				aProcJud[ni][6],; 			//05-COD_SUS
				aProcJud[ni][3],;			//06-VAL_SUS
				aProcJud[ni][5]; 			//07-COD_TRIB
			})					

			FConcTxt( aRegs, nHdlTxt)
		Endif
			
	Next nI

	/* Inicio da gera��o das novas tabelas do TAF para atender o bloco 40 (REINF 2.1.1) */
	If __lDicAtu .AND. nCart == 1 .and. lTemFkw .and. !lIrBaixa

		//Verifica se ha suspencao da retencao do IR na emissao e carraga o array aT154AF
		lSuspFKW := FKWSusp( cIdDoc, @aT154AF )

		If lSuspFKW .and. Len(aT154AF) > 0
			aRegs := {}
			cReg  := "T154AF" // Indicativo de Suspens�o por processo judicial/administrativo

			//Monta o registro TT154AF para o IR (suspen��o de tributos)
			For nI := 1 to Len(aT154AF)
				If aT154AF[nI][1] $ "12" //Se for IRRF
					AAdd( aRegs, {	cReg,;				//01 - REGISTRO - Tipo de Registro
									"",;				//02 - TP_PROC - Tipo de processo
									aT154AF[nI][2],;	//03 - NUM_PROC - Identifica��o do processo ou ato concess�rio
									aT154AF[nI][3],;	//04 - IND_PROC - Indicador da origem do processo (0 - SEFAZ; 1 - Justi�a Federal; 2 - Justi�a Estadual; 3 � Secretaria da Receita Federal do Brasil; 9 � Outros)
									aT154AF[nI][4],;	//05 - COD_SUS - C�digo do Indicativo da Suspens�o
									aT154AF[nI][5],;	//06 - VAL_SUS - Valor da reten��o que deixou de ser efetuada em fun��o de processo adm/judicial
									aT154AF[nI][1],;	//07 - COD_TRIB - Informar o codigo que corresponde ao tributo
									aT154AF[nI][6],;	//08 - NATUREZA_RENDIMENTO - C�digo da natureza de rendimento
									aT154AF[nI][7],;	//09 - BASE_SUSPENSA - Valor da base de c�lculo do tributo com exigibilidade suspensa
									0,;					//10 - VLR_COMP_ANO_CALENDARIO - Compensa��o Judicial relativa ao ano calend�rio
									0 } )				//11 - VLR_COMP_ANO_ANT - Compensa��o Judicial relativa a anos anteriores ao ano calend�rio.

					FConcTxt( aRegs, nHdlTxt)
				Endif
			Next nI

			//Alimenta o array "aT154AL" com as dedu��es do IRPF que foi suspenso
			FDedIse(cIdDoc, @aT154AL,,, cAliasQry, dDataEmis, (cAliasQry)->E2_IRRF, lSuspFKW)

			If Len(aT154AL) > 0
				//Monta o registro TT154AL com as dedu��es do IRPF que foi suspenso
				For nZ := 1 to Len(aT154AL)
					aRegs := {}
					cReg  := "T154AL" // Detalhamento das dedu��es com exigibilidade suspensa

					AAdd( aRegs, {	cReg,;			  //01 - REGISTRO - Tipo de Registro
									aT154AL[nZ][1],;  //02 - IND_TP_DEDUCAO - Indicativo do tipo de dedu��o
									aT154AL[nZ][3]} ) //03 - VAL_DEDUCAO - Valor da dedu��o com exigibilidade suspensa

					FConcTxt( aRegs, nHdlTxt)

					If Len(aT154AL[nZ][5]) > 0 //Verifica se a dedu��o possui dependentes (DHT)
						//Monta o registro T154AM com os valores das dedu��es por dependente
						For nW := 1 to Len(aT154AL[nZ][5])
							aRegs := {}
							cReg  := "T154AM" // Informa��o das dedu��es suspensas por dependentes ou pens�o

							AAdd( aRegs, {	cReg,;			  		 //01 - REGISTRO - Tipo de Registro
											aT154AL[nZ][5][nW][2],;  //02 - CPF - N�mero de Inscri��o no CPF.
											aT154AL[nZ][5][nW][3]} ) //03 - VAL_DEDUCAO_SUSPENSO - Valor da dedu��o relativa a dependentes/pens�o aliment�cia.

							FConcTxt( aRegs, nHdlTxt)
						Next nW
					Endif

				Next nZ
			Endif
			aT154AL  := {}
		Endif

		/*----------------------------------------------------------------|
		| Quando for t�tulo de fornecedor PF, verifica se ha dedu��es ou  |
		| isen��es para o IR no complemento do t�tulo (tabela FKG).       |
		| Obs: a fun��o FDedIse() carregar� os arrays aDetDed (dedu��es)  |
		| e aDetIse (isen��es), e a variavel lIsento.					  |
		-----------------------------------------------------------------*/	
		If __lDicAtu .and. lFornPF .and. !lIRBaixa .and. lTemFkw .And. !lSuspFKW
			FDedIse(cIdDoc, @aDetDed, @aDetIse, @lIsento, cAliasQry, dDataEmis, (cAliasQry)->E2_IRRF)
		Endif

		//Verifica se ha retencao/isencao do IR na emissao e carraga o array aT154Trb
		lTribFKW := FIrrfFKW( cAliasQry, @aT154Trb, lFornPF, dDataEmis, lIsento, lOrigNF, lSuspFKW )
		
		If lTribFKW .and. Len(aT154Trb) > 0

			/* Composi��o do array aT154Trb
			aT154Trb[nI][1] - Codigo que corresponde o tributo no layout TAF
			aT154Trb[nI][2] - C�digo da natureza de rendimento
			aT154Trb[nI][3] - Rendimento bruto
			aT154Trb[nI][4] - Rendimento tributavel ou isento
			aT154Trb[nI][5] - Valor do tributo retido ou isento
			*/

			For nI := 1 To Len(aT154Trb)

				If aT154Trb[nI][1] == "12" //Gera T154AG e tabelas filhas somente para IR na emiss�o

					//Verifica se � opera��o de uma SCP para enviar o CNPJ da SCP do pagamento
					If __lDicAtu .And. aT154Trb[nI][1] $ __cNatSCP .and. !Empty((cAliasQry)->FKF_CGCSCP)
						cCNPJSCP := (cAliasQry)->FKF_CGCSCP 
					Endif

					If aT154Trb[nI][2] <> cOldNatRen //Gera T154AG s� se for uma natureza de rendimento diferente
						aRegs := {}
						cReg  := "T154AG" //Natureza de Rendimento

						AAdd( aRegs, {	cReg,;						//01 - REGISTRO - Tipo de Registro
										aT154Trb[nI][2],;			//02 - NATUREZA_RENDIMENTO - C�digo da natureza de rendimento
										(cAliasQry)->FKF_INDDEC,;	//03 - IND_DEC_TERC - Indicativo de 13� sal�rio (1=Sim; 2=N�o)
										aT154Trb[nI][3],;			//04 - VLR_PGTO - Valor do pagamento por natureza de rendimento
										cCNPJSCP,;					//05 - NR_INSC_FCI_SCP - CNPJ da FCI ou SCP (sociedade em conta da participa��o)
										"" ,;						//06 - INDRRA - Indicativo de Rendimento Recebido Acumuladamente - RRA (0 - N�o; 1 - Sim)
										"" ,;					    //07 - TPPROCRRA - Tipo de processo (1 - Administrativo; 2 - Judicial)
										"" ,;						//08 - NRPROC - N�mero do processo/requerimento administrativo/judicial
										"" } )						//09 - COMPFP - Compet�ncia do Rendimento do trabalho
						
						FConcTxt( aRegs, nHdlTxt )
					EndIf

					cOldNatRen := aT154Trb[nI][2]

					aRegs := {}
					cReg  := "T154AH" //Tributos do Pagamento

					AAdd( aRegs, {	cReg,;				//01 - REGISTRO - Tipo de Registro
									aT154Trb[nI][1],;	//02 - TRIBUTO - Informar o codigo que corresponde ao tributo
									aT154Trb[nI][4],;	//03 - BASE_CALCULO - Base de calculo do tributo
									aT154Trb[nI][5],;	//04 - VLR_TRIBUTO - Valor calculado do tributo
									0 } )				//05 - ALIQUOTA - Valor calculado do tributo
		
					FConcTxt( aRegs, nHdlTxt )

					//Gera a tabela T154AI com as dedu��es de IR pessoa fisica
					For nY := 1 To Len( aDetDed )
						aRegs := {}
						cReg  := "T154AI" // Detalhamento das Dedu��es
						
						/*  Tipos de Dedu��o (02 - TIPO_DEDUCAO): 
							1 - Previdencia Oficial/INSS
							2 - Previdencia Privada
							3 - Fapi
							4 - Funpresp
							5 - Pens�o Aliment�cia
							6 - Contribui��o do ente p�blico patrocinador
							7 - Dependentes */

						AAdd( aRegs, {	cReg,;				//01 - REGISTRO - Tipo de Registro
										aDetDed[nY][1],;	//02 - TIPO_DEDUCAO - Indicativo do Tipo de Dedu��o
										aDetDed[nY][2],;	//03 - VAL_DEDUCAO - Preencher com o valor da Dedu��o da base de c�lculo
										aDetDed[nY][3],;	//04 - VAL_DEDUCAO_SUSP - Valor da Dedu��o da base de c�lculo do Imposto de Renda, com exigibilidade suspensa
										aDetDed[nY][4],;	//05 - NUM_PREVIDENCIA - N�mero de Inscri��o da entidade de Previdencia complementar
										aDetDed[nY][6] } )	//06 - INFO_ENTIDADE - Possui informa��es da entidade de previd�ncia complementar? 0 - N�o;1 - Sim;

						FConcTxt( aRegs, nHdlTxt )

						If Len(aDetDed[nY][5]) > 0 //Verifica se a dedu��o possui dependentes (DHT)
							//Monta o registro T154AK com os dependentes da dedu��o
							For nW := 1 to Len(aDetDed[nY][5])
								aRegs := {}
								cReg  := "T154AK" // Informa��o das dedu��es por dependentes ou pens�o

								AAdd( aRegs, {	cReg,;			  		 //01 - REGISTRO - Tipo de Registro
												aDetDed[nY][5][nW][2],;  //02 - CPF - N�mero de Inscri��o no CPF.
												aDetDed[nY][5][nW][3]} ) //03 - VAL_DEDUCAO - Valor da dedu��o do dependentes/pens�o aliment�cia.

								FConcTxt( aRegs, nHdlTxt)
							Next nW
						EndIf

					Next nY
					
					//Gera a tabela T154AJ com as isen��es de IR pessoa fisica
					For nX := 1 To Len( aDetIse )
						aRegs := {}
						cReg  := "T154AJ" // Detalhamento das isen��es
						
						/*  Tipos de isen��o (02 - TIPO_ISENCAO): 
							1 - Parcela Isenta 65 anos; 
							2 - Di�ria de viagem; 
							3 - Indeniza��o e rescis�o de contrato, inclusive a t�tulo de PDV; 
							4 - Abono pecuni�rio; 
							5 - Valores pagos a titular ou s�cio de microempresa ou empresa de pequeno porte, exceto pr�-labore e alugueis; 
							6 - Pens�o, aposentadoria ou reforma por molestia grave ou acidente em servi�o; 
							7 - Complementa��o de aposentadoria, correspondente �s contribui��es efetuadas no per�odo de 01/01/1989 a 31/12/1995; 
							8 - Ajuda de custo; 
							99 - Outros (especIficar).
						*/

						AAdd( aRegs, {	cReg,;				//01 - REGISTRO - Tipo de Registro
										aDetIse[nX][1],;	//02 - TIPO_ISENCAO - Tipo de isen��o
										aDetIse[nX][2],;	//03 - VAL_ISENTO - Valor da parcela isenta
										aDetIse[nX][3] } )	//04 - DESC_RENDIMENTO - Informar somente quando o tipo for "99" (outros)

						FConcTxt( aRegs, nHdlTxt )

					Next nX	//Fim tabela T154AI
				Endif
			Next nI	
		Endif
		aT154Trb := {}
		aT154AF  := {}
		cOldNatRen := ""
	EndIf /* Fim da gera��o das novas tabelas do TAF para atender o bloco 40 (REINF 2.1.1) */

EndIf	// lGera154 

If cCtrlT154 <> '0'
	If lFlagFKF
		// Gera o registro T154AB: Parcelas da fatura/recibo - 
		// Para titulo avulso ser� 1 para 1

		FWFreeArray(aRegs)
		aRegs		:= {}
		cReg		:= "T154AB"
		If Empty(cParcela)
			cParcela := "1"
		Else
			cParcela := cParcela
		Endif	
			
		Aadd( aRegs, {  ;
		cReg,; 					//01-TIPO REGISTRO
		cParcela,;				//02-NUM_PARC
		nVlrParc}) 				//03-VLR_PARC

		FConcTxt( aRegs, nHdlTxt)
	
		If lBlc20
			(cBxFin)->(DbGoTop())
			If (cBxFin)->(MsSeek(cIdDoc))
				While (cBxFin)->FK7_IDDOC == cIdDoc
					If Empty((cBxFin)->IMPRES)
						aRegs 	:= {}
						cReg 	:= "T154AC" // Indicativo de Suspens�o por processo judicial/administrativo
						Aadd( aRegs, {  ;
							cReg,; 						//01-TIPO REGISTRO
							(cBxFin)->DTBXFIN ,;		//02-DATA DA BAIXA
							(cBxFin)->VLBXFIN;			//03-VALOR DA BAIXA
						})
						
						FConcTxt( aRegs, nHdlTxt)
						RecLock(cBxFin)
							(cBxFin)->IMPRES := 'X'
						MsUnLock()
					EndIf
					(cBxFin)->(DbSkip())
				EndDo
			Else
				(cBxFin)->(DbSkip())
			EndIf
		EndIf
	EndIf
EndIf

If __lVerFlag
	//Grava o flag de envio ao TAF quando a integracao for banco-a-banco
	AAdd( __aFK7Id, { (cAliasQry)->FKF_FILIAL, (cAliasQry)->FK7_IDDOC } )		
Endif
	
RestArea(aAreaSF2)
FwFreeArray(aAreaSF2)
FwFreeArray(aRegs)
FwFreeArray(aDetIse)
FwFreeArray(aDetDed)
FwFreeArray(aT154Trb)
FwFreeArray(aT154AF)
FwFreeArray(aT154AL)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetPartTaf        

Fun��o que retorna o codigo do participante conforme cadastro de cliente/fornecedor

@Param cCliFor    -> CLI - para clientes, FOR - Fornecedor, TRA - Transportadora
@Param cCodigo    -> c�digo do cliente/fornecedor
@Param cLoja      -> Loja
 
@Return ( Nil ) 

@author Karen Honda
@since  19/08/2016
@version 1.0

/*/                                 
//-------------------------------------------------------------------
Static Function RetPartTAF(cCliFor, cCodigo, cLoja)

Local cRet := ""
Local cSigla := ""

cCliFor := Alltrim(cCliFor)

If cCliFor == "CLI"
	cSigla := "C"
ElseIf cCliFor == "TRA"
	cSigla := "T"
Else
	cSigla := "F"
EndIf

cRet := cSigla + cCodigo + cLoja

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MntQryRec        

Fun��o que monta a query dos titulos a receber para envio ao TAF

@Param nRecno    -> Passar o RECNO do SE1 (mantido por compatibilidade)
@Param cAliasSE1 -> Alias para receber o resultado da query 
@param lExtReinf -> Obsoleto (mantido por compatibilidade) 

@Return ( Nil ) 

@author Karen Honda
@since  19/08/2016
@version 1.0

/*/                                 
//-------------------------------------------------------------------

Static Function MntQryRec(nRecno, cAliasSE1, lExtReinf)
	
	Local aCpoNum 		As Array
	Local aStru			As Array
	Local aTamSX3Cpo 	As Array
	Local nLoop 		As Numeric
	Local nTcSql        As Numeric
	Local cQuery 		As Character
	Local cQry			As Character
	Local cCond			As Character
	Local cFields		As Character
	Local cFldQry		As Character
	Local cCampos1      As Character
	Local cCampos2		As Character
	Local cOrdem        As Character

	Default lExtReinf	:= 	.f.

	aStru		:= {}
	aTamSX3Cpo 	:= {}
	nLoop 		:= 1
	nTcSql      := 0
	cQuery 		:= ""
	cQry		:= ""
	cCond		:= ""
	cFields		:= ""
	cFldQry		:= ""
	cCpoAux     := ""
	cCampos1    := ""
	cCampos2    := ""
	cOrdem  	:= ""

	cCpoAux := "SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_CLIENTE, "
	cCpoAux += "SE1.E1_LOJA, SE1.E1_EMIS1,SE1.E1_EMISSAO, SE1.E1_VENCTO, SE1.E1_VENCREA, SE1.E1_NATUREZ, "
	cCpoAux += "SE1.E1_HIST, SE1.R_E_C_N_O_, SE1.E1_VALOR, SE1.E1_VLCRUZ, SE1.E1_IRRF, SE1.E1_INSS, "
	cCpoAux += "SE1.E1_PIS, SE1.E1_COFINS, SE1.E1_CSLL, SE1.E1_ISS, SE1.E1_BASEINS, SE1.E1_ORIGEM, "
	cCpoAux += "SE1.E1_CONTA,SE1.E1_SERIE,SE1.E1_DESDOBR DESDOBR, "   
	cCpoAux += "SA1.A1_CGC, SA1.A1_NOME, SA1.A1_END, SA1.A1_BAIRRO, SA1.A1_MUN, SA1.A1_EST, SA1.A1_CEP, "
	cCpoAux += "SA1.A1_RECINSS, SA1.R_E_C_N_O_ A1_RECNO, SED.ED_CODIGO, SED.ED_CALCINS, "
	cCpoAux += "' ' TPREX, ' ' TRBEX, SED.ED_PERCINS, SA1.A1_COD COD, SA1.A1_LOJA LOJA, " 
	cCpoAux += "FKF.FKF_FILIAL  FKF_FILIAL, "
	cCpoAux += cIsNullSQL + "(FK7.FK7_IDDOC,' ') FK7_IDDOC, "
	cCpoAux += cIsNullSQL + "(FKF.FKF_CPRB,' ')  FKF_CPRB, "
	cCpoAux += cIsNullSQL + "(FKF.FKF_CNAE,' ')  FKF_CNAE, "
	cCpoAux += cIsNullSQL + "(FKF.FKF_TPREPA,' ') FKF_TPREPA, "
	cCpoAux += cIsNullSQL + "(FKF.FKF_INDSUS,' ') FKF_INDSUS, "
	cCpoAux += cIsNullSQL + "(FKF.FKF_INDDEC,' ') FKF_INDDEC, "
	cCpoAux += cIsNullSQL + "(FKF.FKF_TPSERV,' ') FKF_TPSERV, "
	cCpoAux += cIsNullSQL + "(FKF.FKF_CNO,' ') FKF_CNO, "
	cCpoAux += cIsNullSQL + "(FKF.FKF_ORIINS,0) FKF_ORIINS "
	If __lDicAtu
		cCpoAux += ", "
		cCpoAux += cIsNullSQL + "(FKF.FKF_REINF,'2') FKF_REINF, "
		cCpoAux += cIsNullSQL + "(FKF.FKF_NATREN,' ') FKF_NATREN "
	EndIf

	cCampos1 := cCpoAux + ", 'T154' TABELA" //Campos da query antes do UNION
	cCampos2 := cCpoAux + ", 'T162' TABELA" //Campos da query ap�s o UNION
	cOrdem  := " ORDER BY E1_FILIAL,COD,LOJA,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO"

	//Monta query principal que obtem os t�tulos a receber
	cQuery := F989QryRec(cCampos1, cCampos2, cOrdem, @cCond)

 	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSE1,.F.,.T.)

	aCpoNum 	:= {'E1_VALOR','E1_VLCRUZ','E1_IRRF','E1_INSS','E1_PIS','E1_COFINS','E1_CSLL','E1_ISS','E1_BASEINS','FKF_ORIINS'}

	For nLoop := 1 To Len( aCpoNum )
		aTamSX3Cpo := TamSX3(aCpoNum[nLoop])
		TcSetField( cAliasSE1, aCpoNum[nLoop], "N",aTamSX3Cpo[1],aTamSX3Cpo[2])
	Next nLoop

	//Monta a tabela temporaria (FwTemporaryTable) para obter as baixas a receber
	//para atender os eventos R-2030 (recebimentos de Associa��o Desportiva)
	If __nBx2030 > 1

		__cBxFinCR	:= 'BXFINCR'

		aStru := {{ 'E1_FILIAL', "C",TAMSX3("E1_FILIAL")[1],0}, ;
			{ 'E1_PREFIXO', "C",TAMSX3("E1_PREFIXO")[1],0}, ;
			{ 'E1_NUM', "C",TAMSX3("E1_NUM")[1],0}, ;
			{ 'E1_PARCELA', "C",TAMSX3("E1_PARCELA")[1],0}, ;
			{ 'E1_TIPO', "C",TAMSX3("E1_TIPO")[1],0}, ;
			{ 'E1_CLIENTE', "C",TAMSX3("E1_CLIENTE")[1],0}, ;
			{ 'E1_LOJA', "C",TAMSX3("E1_LOJA")[1],0}, ;
			{ 'E1_EMIS1', "C",TAMSX3("E1_EMIS1")[1],0}, ;
			{ 'E1_EMISSAO',"C",TAMSX3("E1_EMISSAO")[1],0}, ;
			{ 'E1_VENCTO', "C",TAMSX3("E1_VENCTO")[1],0}, ;
			{ 'E1_VENCREA', "C",TAMSX3("E1_VENCREA")[1],0}, ;
			{ 'E1_NATUREZ', "C",TAMSX3("E1_NATUREZ")[1],0}, ;
			{ 'E1_HIST', "C",TAMSX3("E1_HIST")[1],0}, ;
			{ 'RECSE1', "N", 10, 0 }, ;
			{ 'E1_VALOR', "N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]}, ;
			{ 'E1_VLCRUZ', "N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]}, ;
			{ 'E1_IRRF', "N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]}, ;
			{ 'E1_INSS',"N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]}, ;
			{ 'E1_PIS', "N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]}, ;
			{ 'E1_COFINS', "N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]}, ;
			{ 'E1_CSLL', "N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]}, ;
			{ 'E1_ISS', "N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]}, ;
			{ 'E1_BASEINS', "N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]}, ;
			{ 'E1_ORIGEM', "C",TAMSX3("E1_ORIGEM")[1],0}, ;
			{ 'E1_CONTA', "C",TAMSX3("E1_CONTA")[1],0}, ;
			{ 'E1_SERIE', "C",TAMSX3("E1_SERIE")[1],0}, ;
			{ 'DESDOBR', "C",TAMSX3("E1_DESDOBR")[1],0}, ;
			{ 'A1_CGC', "C",TAMSX3("A1_CGC")[1],0}, ;
			{ 'A1_NOME', "C",TAMSX3("A1_NOME")[1],0}, ;
			{ 'A1_END', "C",TAMSX3("A1_END")[1],0}, ;
			{ 'A1_BAIRRO', "C",TAMSX3("A1_BAIRRO")[1],0}, ;
			{ 'A1_MUN', "C",TAMSX3("A1_MUN")[1],0}, ;
			{ 'A1_EST', "C",TAMSX3("A1_EST")[1],0}, ;
			{ 'A1_CEP', "C",TAMSX3("A1_CEP")[1],0}, ;
			{ 'A1_RECINSS', "C",TAMSX3("A1_RECINSS")[1],0}, ;
			{ 'A1_RECNO', "N", 10, 0 }, ;
			{ 'ED_CODIGO', "C",TAMSX3("ED_CODIGO")[1],0}, ;
			{ 'ED_CALCINS', "C",TAMSX3("ED_CALCINS")[1],0}, ;
			{ 'TPREX', "C", TAMSX3("A2_TPREX")[1], 0 }, ;
			{ 'TRBEX', "C", TAMSX3("A2_TRBEX")[1], 0 }, ;
			{ 'ED_PERCINS', "N",TAMSX3("ED_PERCINS")[1], TAMSX3("ED_PERCINS")[2]}, ;
			{ 'COD', "C",TAMSX3("A1_COD")[1],0}, ;
			{ 'LOJA', "C",TAMSX3("A1_LOJA")[1],0}, ;
			{ 'FK7_IDDOC', "C", TAMSX3("FK7_IDDOC")[1], 0 }, ;
			{ 'FKF_FILIAL', "C", TAMSX3("FKF_FILIAL")[1], 0 }, ;
			{ 'FKF_CPRB', "C",TAMSX3("FKF_CPRB")[1],0}, ;
			{ 'FKF_CNAE', "C",TAMSX3("FKF_CNAE")[1],0}, ;
			{ 'FKF_TPREPA', "C",TAMSX3("FKF_TPREPA")[1],0}, ;
			{ 'FKF_INDSUS', "C",TAMSX3("FKF_INDSUS")[1],0}, ;
			{ 'FKF_INDDEC', "C",TAMSX3("FKF_INDDEC")[1],0}, ;
			{ 'FKF_TPSERV', "C",TAMSX3("FKF_TPSERV")[1],0}, ;
			{ 'FKF_CNO', "C",TAMSX3("FKF_CNO")[1],0}, ;
			{ 'FKF_ORIINS', "N",TAMSX3("FKF_ORIINS")[1],TAMSX3("FKF_ORIINS")[2]}, ;
			{ 'IMPRES', "C",1,0}, ;
			{ 'FKF_REINF', "C", 1, 0}, ;
			{ 'FKF_NATREN', "C", 6, 0}, ;
			{ 'DTBXFIN', "C",TAMSX3("FK1_DATA")[1],0}, ;
			{ 'VLBXFIN', "N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]} }

		For nLoop := 1 to Len(aStru)
			cFields += aStru[nLoop][1] + ","//Nome do campo
			Do Case
				Case aStru[nLoop][1] == 'RECSE1'
					cFldQry += "SE1.R_E_C_N_O_, "
				Case aStru[nLoop][1] == 'DESDOBR'
					cFldQry += "E1_DESDOBR, "
				Case aStru[nLoop][1] == 'A1_RECNO'
					cFldQry += "SA1.R_E_C_N_O_, "
				Case aStru[nLoop][1] == 'TPREX'
					cFldQry += "' ' TPREX, "
				Case aStru[nLoop][1] == 'TRBEX'
					cFldQry += "' ' TRBEX, "
				Case aStru[nLoop][1] == 'COD'
					cFldQry += "A1_COD, "
				Case aStru[nLoop][1] == 'LOJA'
					cFldQry += "A1_LOJA, "
				Case aStru[nLoop][1] == 'IMPRES'
					cFldQry += "' ' IMPRES, "	
				OtherWise
					If !( aStru[nLoop][1] $ "DTBXFIN|VLBXFIN|FKF_REINF|FKF_NATREN" )
						cFldQry += aStru[nLoop][1] + ","//Nome do campo
					EndIf
			EndCase
		Next
		cFields := Left(cFields, Len(cFields) -1) //Remover a ultima v�rgula
		cFldQry := Left(AllTrim(cFldQry), Len(AllTrim(cFldQry)) -1) //Remover a ultima v�rgula

		cQry 	+= "Select " + cFldQry

		If __lDicAtu
			cQry += ", "
			cQry += cIsNullSQL + "(FKF.FKF_REINF,'2') FKF_REINF, "
			cQry += cIsNullSQL + "(FKF.FKF_NATREN,' ') FKF_NATREN "
		Else
			cQry += ", "
			cQry += " ' ' FKF_REINF, "
			cQry += " ' ' FKF_NATREN "
		EndIf
			
		If __nBx2030 == 2
			cQry	+= " , FK1_DATA DTBXFIN "
		ElseIf __nBx2030 == 3
			cQry	+= " , FK1_DTDISP DTBXFIN "
		EndIf

		cQry	+= " , ( E5_VALOR + ( CASE WHEN E5_SEQ = (Select Max(E5MX.E5_SEQ) "
		cQry	+= " FROM " + RetSqlName("SE5") + " E5MX "
		cQry	+= " Where E1_SALDO = 0 AND E5MX.E5_FILIAL = '" + xFilial("SE5") + "' "
		cQry	+= " AND E5MX.E5_PREFIXO = SE1.E1_PREFIXO AND E5MX.E5_NUMERO = SE1.E1_NUM "
		cQry	+= " AND E5MX.E5_PARCELA = SE1.E1_PARCELA AND E5MX.E5_TIPO = SE1.E1_TIPO "
		cQry	+= " AND E5MX.E5_CLIFOR = SE1.E1_CLIENTE AND E5MX.E5_LOJA = SE1.E1_LOJA "
		cQry	+= " AND SE1.D_E_L_E_T_ = ' ' "
		cQry	+= " AND E5MX.D_E_L_E_T_ = ' ' "
		cQry	+= " AND E5MX.E5_TIPODOC != 'ES' AND E5MX.D_E_L_E_T_ = ' ' ) "

		cQry	+= " THEN (E1_INSS + E1_COFINS + E1_CSLL + E1_PIS + "
		cQry	+= " (CASE WHEN E5_PRETIRF != '1' THEN E1_IRRF ELSE 0 END ) + E1_ISS + E1_DECRESC - E1_ACRESC - E1_JUROS - E1_MULTA ) ELSE 0 END ) ) AS VLBXFIN "
		
		cQry	+= cCond

		cQry += " JOIN " + RetSqlName("FK1") + " FK1 "
		cQry += " On FK1.FK1_FILIAL = '" + xFilial("FK1") + "'"
		cQry += " AND NOT EXISTS( "
		cQry += " 	SELECT FK1EST.FK1_IDDOC FROM " + RetSqlName("FK1") +" FK1EST"
		cQry += " 	WHERE FK1EST.FK1_FILIAL = FK1.FK1_FILIAL"
		cQry += " 	AND FK1EST.FK1_IDDOC = FK1.FK1_IDDOC "
		cQry += " 	AND FK1EST.FK1_SEQ = FK1.FK1_SEQ "
		cQry += " 	AND FK1EST.FK1_TPDOC = 'ES' "
		cQry += " 	AND FK1EST.D_E_L_E_T_ = ' ') "
		cQry += " AND FK1.D_E_L_E_T_ = ' ' "
		cQry += " AND FK1.FK1_IDDOC = FK7.FK7_IDDOC "

		If !Empty(dDataEmDe) .AND. !Empty(dDataEmAte) 
			If __nBx2030 == 2 // baixa
				cQry += "AND FK1.FK1_DATA >= '" + Dtos(dDataEmDe ) + "' AND FK1.FK1_DATA <= '" + Dtos(dDataEmAte) + "' "
			Else
				cQry += "AND FK1.FK1_DTDISP >= '" + Dtos(dDataEmDe ) + "' AND FK1.FK1_DTDISP <= '" + Dtos(dDataEmAte) + "' "
			EndIf	
		EndIf
		cQry += " AND FK7.D_E_L_E_T_ = ' ' "
		
		cQry += " LEFT JOIN " + RetSqlName("SE5") + " SE5 "
		cQry += " On SE5.E5_FILIAL = '" + xFilial("SE5") + "'"
		cQry += " AND SE5.E5_TABORI = 'FK1' "
		cQry += " AND SE5.E5_IDORIG = FK1.FK1_IDFK1 "
		cQry += " AND SE5.E5_RECPAG = 'R' "
		cQry += " AND SE5.E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE','E2','CH','ES') "
		cQry += " AND SE5.E5_MOTBX NOT IN ('FAT','LIQ','DEV', 'CMP') "
		cQry += " AND SE5.D_E_L_E_T_ = ' ' "

		cQry +=	" WHERE E1_FILIAL = '" + xFilial("SE1") + "' "
		
		cQry += " AND SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM+"|"+MV_CRNEG +"|" +MVPROVIS+"|"+MVRECANT+"|"+MV_CPNEG+ "|"+ MVTAXA+"|"+MVTXA+"|"+MVINSS+"|"+"SES","|")  + " "
		cQry += " AND SE1.E1_FILORIG = '" + cFilAnt + "' "
		cQry += " AND SE1.E1_FATURA NOT IN ('NOTFAT') " // desconsidera titulos fatura
		cQry += " AND SE1.E1_NUMLIQ = ' ' " // desconsidera titulos liquidados
	
		cQry += " AND (FKF.FKF_TPSERV != ' ' OR FKF.FKF_TPREPA != ' ' "
	
		cQry += " ) AND SE1.D_E_L_E_T_ = ' ' "
		cQry += " AND ((SA1.A1_RECINSS = 'S' AND SED.ED_CALCINS = 'S') OR SE1.E1_INSS > 0)  " // se recolhe INSS

		cQry += " AND EXISTS (SELECT FK1.FK1_IDFK1 FROM " + RetSqlName("FK1") + " FK1 "
		cQry += " WHERE "
		cQry += 		" FK1.FK1_IDDOC = FK7.FK7_IDDOC "
		
		cQry += 		" AND FK1.FK1_RECPAG = 'R' "
		cQry += 		" AND FK1.FK1_TPDOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE','E2','CH','ES') "
		cQry += 		" AND FK1.FK1_MOTBX NOT IN ('FAT','LIQ','DEV', 'CMP') "
		
		cQry += " AND FK1.D_E_L_E_T_ = ' ' "
		cQry += " ) "
		cQry += " AND SE1.D_E_L_E_T_ = ' ' "

		cQry	:= ChangeQuery(cQry)

		If __oBxFinCR <> Nil
			//-- Limpa registros para nova execu��o
			nTcSql := TcSQLExec("DELETE FROM " + __oBxFinCR:GetRealName() )
			If nTcSql < 0
				//-- Se ocorrer algum problema refaz a temporaria
				__oBxFinCR:Delete()
				__oBxFinCR := Nil
			Else // Necess�ria para atualiza��o do Alias ap�s dele��o dos dados 
				(__cBxFinCR)->(dbGoTo(1))
			EndIf
		EndIf

		If __oBxFinCR == Nil
			__oBxFinCR := FwTemporaryTable():New( __cBxFinCR )
			__oBxFinCR:SetFields(aStru)
			__oBxFinCR:AddIndex('1', {'FK7_IDDOC','DTBXFIN'})
			__oBxFinCR:Create()
		EndIf

		TcSQLExec("Insert Into " + __oBxFinCR:GetRealName() ;
			+ " (" + cFields + ") (" + cQry + ") " )

	EndIf

 	lRecQry	  := .T.
 	
 	cFilFiscal	  := cFilAnt

Return __cBxFinCR

//-------------------------------------------------------------------
/*/{Protheus.doc} MntQryPag        

Fun��o que monta a query dos titulos a pagar para envio ao TAF

@Param nRecno     -> Passar o RECNO do SE2 (mantido por compatibilidade)
@Param cAliasSE2  -> Alias para pagar o resultado da query 
@Param lExtReinf  -> Obsoleto (mantido por compatibilidade) 
@Param lFiltReinf -> Filtra s� dados do REINF
 
@Return ( Nil ) 

@author Karen Honda
@since  19/08/2016
@version 1.0

/*/                                 
//-------------------------------------------------------------------

Static Function MntQryPag(nRecno, cAliasSE2, lExtReinf, lFiltReinf)
	Local aCpoNum 		As Array
	Local aTamSX3Cpo 	As Array
	Local aStru			As Array
	Local nLoop 		As Numeric
	Local nTcSql 		As Numeric
	Local cQuery 		As Character
	Local cCampos 		As Character
	Local cCamposFim 	As Character
	Local cQry			As Character
	Local cCond			As Character
	Local cFields		As Character
	Local cFldQry		As Character

	Default nRecno := 0
	Default lExtReinf	:=	.f.
	Default lFiltReinf	:=	.f.

	aTamSX3Cpo 	:= {}
	aStru		:= {}
	nLoop 		:= 1
	nTcSql      := 0
	cQuery 		:= ""
	cCampos 	:= ""
	cCamposFim 	:= ""
	cQry		:= ""
	cCond		:= ""
	cFields		:= ""
	cFldQry		:= ""

	//Colunas que ir�o compor a query principal do contas a pagar
	cCampos := "SE2.E2_FILIAL,SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA, SE2.E2_TIPO, SE2.E2_FORNECE COD, SE2.E2_LOJA LOJA, SE2.E2_EMIS1,SE2.E2_EMISSAO,"
	cCampos += "SE2.E2_VENCTO, SE2.E2_VENCREA, SE2.E2_NATUREZ, SE2.E2_HIST, SE2.R_E_C_N_O_ RECNO, "
	cCampos += "SE2.E2_VALOR, SE2.E2_VLCRUZ, SE2.E2_IRRF, SE2.E2_INSS, SE2.E2_PIS, SE2.E2_COFINS, SE2.E2_CSLL, SE2.E2_ISS, SE2.E2_DESDOBR DESDOBR,"
	cCampos += "SE2.E2_SEST, SE2.E2_BASEINS, SE2.E2_ORIGEM, SE2.E2_CONTAD, SE2.E2_CODRET,SE2.E2_VRETPIS,SE2.E2_VRETCOF,SE2.E2_VRETCSL, SE2.E2_SALDO,SE2.E2_BASEPIS, SE2.E2_BASECOF, SE2.E2_BASECSL, SE2.E2_BASEIRF,"
	cCampos += "SA2.A2_CGC, SA2.A2_NOME, SA2.A2_END, SA2.A2_BAIRRO, SA2.A2_MUN, SA2.A2_EST, SA2.A2_CEP, SA2.A2_NUMDEP, SA2.A2_CALCIRF,SA2.A2_RECINSS, SA2.R_E_C_N_O_ A2_RECNO,"
	cCampos += "SA2.A2_TPREX TPREX, SA2.A2_TRBEX TRBEX, SA2.A2_TIPO, SA2.A2_IRPROG,"	
	cCampos += " SED.ED_CODIGO, SED.ED_CALCIRF, SED.ED_PERCIRF, SED.ED_CALCPIS, SED.ED_PERCPIS, SED.ED_CALCCOF, SED.ED_PERCCOF, SED.ED_CALCCSL, SED.ED_PERCCSL, "
	cCampos += " SED.ED_PERCINS, SED.ED_CALCINS,"
	cCampos += cIsNullSQL + "(FK7.FK7_IDDOC,' ') FK7_IDDOC, "
	cCampos += "FKF.FKF_FILIAL, "
	cCampos += cIsNullSQL + "(FKF.FKF_CPRB,' ')  FKF_CPRB, "
	cCampos += cIsNullSQL + "(FKF.FKF_CNAE,' ')  FKF_CNAE, "
	cCampos += cIsNullSQL + "(FKF.FKF_TPREPA,' ') FKF_TPREPA, "
	cCampos += cIsNullSQL + "(FKF.FKF_INDSUS,' ') FKF_INDSUS, "
	cCampos += cIsNullSQL + "(FKF.FKF_INDDEC,' ') FKF_INDDEC, "
	cCampos += cIsNullSQL + "(FKF.FKF_TPSERV,' ') FKF_TPSERV, "
	cCampos += cIsNullSQL + "(FKF.FKF_CNO,' ') FKF_CNO, "
	cCampos += cIsNullSQL + "(FKF.FKF_ORIINS,0) FKF_ORIINS "

	If __lDicAtu
		cCampos += ", "
		cCampos += cIsNullSQL + "(FKF.FKF_REINF,'2') FKF_REINF, "
		cCampos += cIsNullSQL + "(FKF.FKF_NATREN,' ') FKF_NATREN, "
		cCampos += cIsNullSQL + "(FKF.FKF_CGCSCP,' ') FKF_CGCSCP "
	Endif

	If __lTemFKJ
		cCampos += ", "
		cCampos += cIsNullSQL + "(FKJ.FKJ_CPF,' ') FKJ_CPF, "
		cCampos += cIsNullSQL + "(FKJ.FKJ_PERCEN,1) FKJ_PERCEN "
	EndIf

	cOrdem  := " ORDER BY E2_FILIAL,COD,LOJA,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO"

	//Monta query principal que obtem os t�tulos a pagar
	cQuery := F989QryPag(cCampos, cOrdem, lFiltReinf, @cCond, @cCamposFim)

	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSE2,.F.,.T.)

	aCpoNum := {'E2_VALOR','E2_VLCRUZ','E2_IRRF','E2_INSS','E2_PIS','E2_COFINS','E2_CSLL','E2_ISS','E2_SEST','E2_BASEINS','E2_VRETPIS','E2_VRETCOF','E2_VRETCSL','E2_SALDO','FKF_ORIINS'}
	For nLoop := 1 To Len( aCpoNum )
		aTamSX3Cpo := TamSX3(aCpoNum[nLoop])
		TcSetField( cAliasSE2, aCpoNum[nLoop], "N",aTamSX3Cpo[1],aTamSX3Cpo[2])
	Next nLoop 	

	/*---------------------------------------------------------------------------|
	| Monta a tabela temporaria (FwTemporaryTable) para obter as baixas a pagar	 |
	| para atender o evento R-2040 (pagamentos para Associa��o Desportiva).      |
	----------------------------------------------------------------------------*/
	If __nBx2040 > 1
	
		__cBxFinCP	:= 'BXFINCP'
	
		aStru := {{ 'E2_FILIAL', "C",TAMSX3("E2_FILIAL")[1],0}, ;
			{ 'E2_PREFIXO', "C",TAMSX3("E2_PREFIXO")[1],0}, ;
			{ 'E2_NUM', "C",TAMSX3("E2_NUM")[1],0}, ;
			{ 'E2_PARCELA', "C",TAMSX3("E2_PARCELA")[1],0}, ;
			{ 'E2_TIPO', "C",TAMSX3("E2_TIPO")[1],0}, ;
			{ 'COD', "C",TAMSX3("E2_FORNECE")[1],0}, ;
			{ 'LOJA', "C",TAMSX3("E2_LOJA")[1],0}, ;
			{ 'E2_EMIS1', "C",TAMSX3("E2_EMIS1")[1],0}, ;
			{ 'E2_EMISSAO',"C",TAMSX3("E2_EMISSAO")[1],0}, ;
			{ 'E2_VENCTO', "C",TAMSX3("E2_VENCTO")[1],0}, ;
			{ 'E2_VENCREA', "C",TAMSX3("E2_VENCREA")[1],0}, ;
			{ 'E2_NATUREZ', "C",TAMSX3("E2_NATUREZ")[1],0}, ;
			{ 'E2_HIST', "C",TAMSX3("E2_HIST")[1],0}, ;
			{ 'RECSE2', "N", 10, 0 }, ;
			{ 'E2_VALOR', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
			{ 'E2_VLCRUZ', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
			{ 'E2_IRRF', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
			{ 'E2_INSS',"N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
			{ 'E2_PIS', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
			{ 'E2_COFINS', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
			{ 'E2_CSLL', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
			{ 'E2_ISS', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
			{ 'DESDOBR', "C",TAMSX3("E2_DESDOBR")[1],0}, ;
			{ 'E2_SEST', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
			{ 'E2_BASEINS', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
			{ 'E2_ORIGEM', "C",TAMSX3("E2_ORIGEM")[1],0}, ;
			{ 'E2_CONTAD', "C",TAMSX3("E2_CONTAD")[1],0}, ;
			{ 'E2_CODRET', "C",TAMSX3("E2_CODRET")[1],0}, ;
			{ 'E2_VRETPIS', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
			{ 'E2_VRETCOF', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
			{ 'E2_VRETCSL', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
			{ 'E2_SALDO', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
			{ 'A2_CGC', "C",TAMSX3("A2_CGC")[1],0}, ;
			{ 'A2_NOME', "C",TAMSX3("A2_NOME")[1],0}, ;
			{ 'A2_END', "C",TAMSX3("A2_END")[1],0}, ;
			{ 'A2_BAIRRO', "C",TAMSX3("A2_BAIRRO")[1],0}, ;
			{ 'A2_MUN', "C",TAMSX3("A2_MUN")[1],0}, ;
			{ 'A2_EST', "C",TAMSX3("A2_EST")[1],0}, ;
			{ 'A2_CEP', "C",TAMSX3("A2_CEP")[1],0}, ;
			{ 'A2_NUMDEP', "C",TAMSX3("A2_NUMDEP")[1],0}, ;
			{ 'A2_CALCIRF', "C",TAMSX3("A2_CALCIRF")[1],0}, ;
			{ 'A2_TIPO', "C",TAMSX3("A2_TIPO")[1],0}, ;
			{ 'A2_IRPROG', "C",TAMSX3("A2_IRPROG")[1],0}, ;
			{ 'A2_RECINSS', "C",TAMSX3("A2_RECINSS")[1],0}, ;
			{ 'A2_RECNO', "N", 10, 0 }, ;
			{ 'ED_CODIGO', "C",TAMSX3("ED_CODIGO")[1],0}, ;
			{ 'ED_CALCINS', "C",TAMSX3("ED_CALCINS")[1],0}, ;
			{ 'TPREX', "C", TAMSX3("A2_TPREX")[1], 0 }, ;
			{ 'TRBEX', "C", TAMSX3("A2_TRBEX")[1], 0 }, ;
			{ 'ED_PERCINS', "N",TAMSX3("ED_PERCINS")[1], TAMSX3("ED_PERCINS")[2]}, ;
			{ 'FK7_IDDOC', "C", TAMSX3("FK7_IDDOC")[1], 0 }, ;
			{ 'FKF_FILIAL', "C",TAMSX3("FKF_FILIAL")[1],0}, ;
			{ 'FKF_CPRB', "C",TAMSX3("FKF_CPRB")[1],0}, ;
			{ 'FKF_CNAE', "C",TAMSX3("FKF_CNAE")[1],0}, ;
			{ 'FKF_TPREPA', "C",TAMSX3("FKF_TPREPA")[1],0}, ;
			{ 'FKF_INDSUS', "C",TAMSX3("FKF_INDSUS")[1],0}, ;
			{ 'FKF_INDDEC', "C",TAMSX3("FKF_INDDEC")[1],0}, ;
			{ 'FKF_TPSERV', "C",TAMSX3("FKF_TPSERV")[1],0}, ;
			{ 'FKF_CNO', "C",TAMSX3("FKF_CNO")[1],0}, ;
			{ 'FKF_ORIINS', "N",TAMSX3("FKF_ORIINS")[1],TAMSX3("FKF_ORIINS")[2]}, ;
			{ 'IMPRES', "C",1,0}, ;
			{ 'FKF_REINF', "C", 1, 0}, ;
			{ 'FKF_NATREN', "C", 6, 0}, ;
			{ 'FKF_CGCSCP', "C", 14, 0}, ;
			{ 'DTBXFIN', "C",TAMSX3("FK2_DATA")[1],0}, ;
			{ 'VLBXFIN', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]} }

		For nLoop := 1 to Len(aStru)
			cFields += aStru[nLoop][1] + ","//Nome do campo
			Do Case
				Case aStru[nLoop][1] == 'COD'
					cFldQry += "E2_FORNECE, "
				Case aStru[nLoop][1] == 'LOJA'
					cFldQry += "E2_LOJA, "
				Case aStru[nLoop][1] == 'RECSE2'
					cFldQry += "SE2.R_E_C_N_O_, "
				Case aStru[nLoop][1] == 'DESDOBR'
					cFldQry += "E2_DESDOBR, "
				Case aStru[nLoop][1] == 'A2_RECNO'
					cFldQry += "SA2.R_E_C_N_O_, "
				Case aStru[nLoop][1] == 'TPREX'
					cFldQry += "A2_TPREX, "
				Case aStru[nLoop][1] == 'TRBEX'
					cFldQry += "A2_TRBEX, "
				Case aStru[nLoop][1] == 'IMPRES'
					cFldQry += "' ' IMPRES, "
				OtherWise
					If !( aStru[nLoop][1] $ "DTBXFIN|VLBXFIN|FKF_REINF|FKF_NATREN|FKF_CGCSCP" )
						cFldQry += aStru[nLoop][1] + ","//Nome do campo
					EndIf
			EndCase
		Next
		cFields := Left(cFields, Len(cFields) -1) //Remover a ultima v�rgula
		cFldQry := Left(AllTrim(cFldQry), Len(AllTrim(cFldQry)) -1) //Remover a ultima v�rgula
		
		cQry 	:= "Select " + cFldQry
		
		If __lDicAtu
			cQry += ", "
			cQry += cIsNullSQL + "(FKF.FKF_REINF,'2') FKF_REINF, "
			cQry += cIsNullSQL + "(FKF.FKF_NATREN,' ') FKF_NATREN, "
			cQry += cIsNullSQL + "(FKF.FKF_CGCSCP,' ') FKF_CGCSCP "
		Else
			cQry += ", "
			cQry += "' ' FKF_REINF, "
			cQry += "' ' FKF_NATREN, "
			cQry += "' ' FKF_CGCSCP "
		EndIf

		If __nBx2040 == 2
			cQry	+= " , FK2_DATA DTBXFIN "
		ElseIf __nBx2040 == 3
			cQry	+= " , FK2_DTDISP DTBXFIN "
		EndIf
		cQry	+= " , ( E5_VALOR + ( CASE WHEN E5_SEQ = (Select Max(E5MX.E5_SEQ) "
		cQry	+= " FROM " + RetSqlName("SE5") + " E5MX "
		cQry	+= " Where E2_SALDO = 0 AND E5MX.E5_FILIAL = '" + xFilial("SE5") + "' "
		cQry	+= " AND E5MX.E5_PREFIXO = SE2.E2_PREFIXO AND E5MX.E5_NUMERO = SE2.E2_NUM "
		cQry	+= " AND E5MX.E5_PARCELA = SE2.E2_PARCELA AND E5MX.E5_TIPO = SE2.E2_TIPO "
		cQry	+= " AND E5MX.E5_CLIFOR = SE2.E2_FORNECE AND E5MX.E5_LOJA = SE2.E2_LOJA "
		cQry	+= " AND SE2.D_E_L_E_T_ = ' ' "
		cQry	+= " AND E5MX.D_E_L_E_T_ = ' ' "
		cQry	+= " AND E5MX.E5_TIPODOC != 'ES' AND E5MX.D_E_L_E_T_ = ' ' ) "

		cQry	+= " THEN (E2_INSS + E2_COFINS + E2_CSLL + E2_PIS + "
		cQry	+= " (CASE WHEN E5_PRETIRF != '1' THEN E2_IRRF ELSE 0 END ) + E2_ISS + E2_DECRESC - E2_JUROS - E2_ACRESC - E2_MULTA ) ELSE 0 END ) ) AS VLBXFIN "
		
		cQry	+= cCond
		cQry += " JOIN " + RetSqlName("FK2") + " FK2 "
		cQry += " On FK2.FK2_FILIAL = '" + xFilial("FK2") + "'"
		cQry += " AND NOT EXISTS( "
		cQry += " 	SELECT FK2EST.FK2_IDDOC FROM " + RetSqlName("FK2") +" FK2EST"
		cQry += " 	WHERE FK2EST.FK2_FILIAL = FK2.FK2_FILIAL"
		cQry += " 	AND FK2EST.FK2_IDDOC = FK2.FK2_IDDOC "
		cQry += " 	AND FK2EST.FK2_SEQ = FK2.FK2_SEQ "
		cQry += " 	AND FK2EST.FK2_TPDOC = 'ES' "
		cQry += " 	AND FK2EST.D_E_L_E_T_ = ' ') "
		cQry += " AND FK2.D_E_L_E_T_ = ' ' "
		cQry += " AND FK2.FK2_IDDOC = FK7.FK7_IDDOC "

		If __lDicAtu .and. __lVerFlag
			cQry +=	" AND FK2.FK2_REINF IN ('2',' ') "
		EndIf

		If !Empty(dDataPgDe) .AND. !Empty(dDataPgAte) 
			If __nBx2040 == 2 // baixa
				cQry += "AND FK2.FK2_DATA >= '" + Dtos(dDataPgDe ) + "' AND FK2.FK2_DATA <= '" + Dtos(dDataPgAte) + "' "
			Else
				cQry += "AND FK2.FK2_DTDISP >= '" + Dtos(dDataPgDe ) + "' AND FK2.FK2_DTDISP <= '" + Dtos(dDataPgAte) + "' "
			EndIf
		EndIf
		cQry += " AND FK7.D_E_L_E_T_ = ' ' "
		
		cQry += " LEFT JOIN " + RetSqlName("SE5") + " SE5 "
		cQry += " On SE5.E5_FILIAL = '" + xFilial("SE5") + "'"
		cQry += " AND SE5.E5_TABORI = 'FK2' "
		cQry += " AND SE5.E5_IDORIG = FK2.FK2_IDFK2 "
		cQry += " AND SE5.E5_RECPAG = 'P' "
		cQry += " AND SE5.E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE','E2','CH','ES') "
		cQry += " AND SE5.E5_MOTBX NOT IN ('FAT','LIQ','DEV', 'CMP') "
		cQry += " AND SE5.D_E_L_E_T_ = ' ' "
		
		cQry	+= " WHERE E2_FILIAL = '" + xFilial("SE2") + "' " + cCamposFim

		cQry += " AND ((SA2.A2_RECINSS = 'S' AND SED.ED_CALCINS = 'S') AND SE2.E2_INSS > 0 ) "
		If lFiltReinf
			cQry += "AND SA2.A2_TIPO <> 'F' " 
		EndIf
		cQry += " AND (FKF.FKF_TPSERV != ' ' OR FKF.FKF_TPREPA != ' ' "			
		cQry += " ) AND SE2.D_E_L_E_T_ = ' ' "

		cQry += " AND EXISTS (SELECT FK2.FK2_IDFK2 FROM " + RetSqlName("FK2") + " FK2 "
		cQry += " WHERE "
		cQry += 		" FK2.FK2_IDDOC = FK7.FK7_IDDOC "
		
		cQry += 		" AND FK2.FK2_RECPAG = 'P' "
		cQry += 		" AND FK2.FK2_TPDOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE','E2','CH','ES') "
		cQry += 		" AND FK2.FK2_MOTBX NOT IN ('FAT','LIQ','DEV', 'CMP') "
		
		If !Empty(dDataPgDe) .AND. !Empty(dDataPgAte) 
			If __nBx2040 == 2 // baixa
				cQry += "AND FK2.FK2_DATA >= '" + Dtos(dDataPgDe ) + "' AND FK2.FK2_DATA <= '" + Dtos(dDataPgAte) + "' "
			Else
				cQry += "AND FK2.FK2_DTDISP >= '" + Dtos(dDataPgDe ) + "' AND FK2.FK2_DTDISP <= '" + Dtos(dDataPgAte) + "' "
			EndIf	
		EndIf
		cQry += " AND FK2.D_E_L_E_T_ = ' ' "
		cQry += " ) "
		cQry += " AND SE2.D_E_L_E_T_ = ' ' "
		
		cQry	:= ChangeQuery(cQry)

		If __oBxFinCP <> Nil
			//-- Limpa registros para nova execu��o
			nTcSql := TcSQLExec("DELETE FROM " + __oBxFinCP:GetRealName() )
			If nTcSql < 0
				//-- Se ocorrer algum problema refaz a temporaria
				__oBxFinCP:Delete()
				__oBxFinCP := Nil
			Else // Necess�ria para atualiza��o do Alias ap�s dele��o dos dados 
				(__cBxFinCP)->(dbGoTo(1))
			EndIf
		EndIf

		If __oBxFinCP == Nil
			__oBxFinCP := FwTemporaryTable():New( __cBxFinCP )
			__oBxFinCP:SetFields(aStru)
			__oBxFinCP:AddIndex('1', {'FK7_IDDOC','DTBXFIN'})		
			__oBxFinCP:Create()
		EndIf

		TcSQLExec("Insert Into " + __oBxFinCP:GetRealName() ;
			+ " (" + cFields + ") (" + cQry + ") " )
	EndIf

 	lPagQry	  := .T.
 	
 	cFilFiscal := cFilAnt	

Return __cBxFinCP

//-------------------------------------------------------------------
/*/{Protheus.doc} IniVarStat        

Inicializa as variaveis statics

@Return nil 

@author Karen Honda
@since  10/10/2017
@version 1.0

/*/                                 
//-------------------------------------------------------------------

Static Function IniVarStat()

	nTamFil    := TamSx3( "E2_FILIAL" )[1]
	nTamE2Pref := TamSx3( "E2_PREFIXO" )[1]
	nTamE2Num  := TamSx3( "E2_NUM" )[1]
	nTamE2Par  := TamSx3( "E2_PARCELA" )[1]
	nTamE2Tipo := TamSx3( "E2_TIPO" )[1]
	nTamE2For  := TamSx3("E2_FORNECE")[1]
	nTamE2Lj   := TamSx3("E2_LOJA")[1]

	nTamE1Pref := TamSx3( "E1_PREFIXO" )[1]
	nTamE1Num  := TamSx3( "E1_NUM" )[1]
	nTamE1Par  := TamSx3( "E1_PARCELA" )[1]
	nTamE1Tipo := TamSx3( "E1_TIPO" )[1]
	nTamE1Cli  := TamSx3("E1_CLIENTE")[1]
	nTamE1Lj   := TamSx3("E1_LOJA")[1]

	nTamFTDoc  := TamSx3( "FT_NFISCAL" )[1]
	nTamFTSer  := TamSx3( "FT_SERIE" )[1]
	nTamF2Tip  := TamSx3( "F2_TIPO" )[1]

	nTamNumPro := TAMSX3("C1G_NUMPRO")[1]
	nTamDescr  := TAMSX3("C1G_DESCRI")[1]
	nTamIDSEJU := TAMSX3("CCF_IDSEJU")[1]
	nTamVara   := TAMSX3("C1G_VARA")[1]
	nTamCodC18 := TAMSX3("C18_CODIGO")[1]

	nTamCCFNum := TAMSX3("CCF_NUMERO")[1]
	__nFkgImp  := TAMSX3("FKG_TPIMP")[1]

	cBDname	   := Upper( TCGetDB() )
	cSrvType   := TcSrvType()

	_lPCCBaixa := SuperGetMv("MV_BX10925",.F.,"2") == "1"
	__lDedIns  := SuperGetMv("MV_INSIRF",.F.,"2") == "1"
	__lRatIrf  := SuperGetMv("MV_RATIRRF",.F.,.T.)

	__lDicAtu  := FFinExtOK()
	__lTemDKE  := TableInDic('DKE')
	__lTemFKJ  := TableInDic('FKJ') .And. __lDicAtu
	__aFK7Id   := {}
	__aFK2Id   := {}
	__aFKHId   := {}
	__aT159Env := {}
	__aCodA1   := {}
	__oSttFKH  := Nil
	__oSttFOD  := Nil
	__oQryBx1  := NIL
	__oQryBx2  := NIL
	__oQryBx3  := NIL
	__oQryFTR  := NIL
	__oQryPA   := NIL
	__oQryFKH  := NIL
	__oQry158a := NIL
	__oQry158b := NIL
	__oHashDed := NIL
	__oQryDed  := NIL
	__nFkwImp  := NIL
	__cNatSCP  := NIL
	__cAlsNxt  := ''
	__lVerFlag := NIL
	__oQryFKW  := NIL
	__oQryFKW2 := NIL
	__oQryFK7  := NIL
	__oQryFKJ  := NIL
	__lCachQry := FwLibVersion() >= "20211116"
	__lGer158  := .F.
	__lGer159  := .F.
	__lGer162  := .F.
	__oQryDHT  := NIL

	If __lDicAtu
		__nFkwImp	:= TAMSX3("FKW_TPIMP")[1]
		__cNatSCP	:= SuperGetMv( "MV_NATRSCP" , .F., '12001' )
	EndIf

	If "MSSQL" $ cBDname 
		cConcat := "+"
	ElseIf cBDname $ "MYSQL|POSTGRES"
		cConcat := ","
	Else
		cConcat := "||"
	EndIf

	If cBDname $ "ORACLE|DB2|POSTGRES|INFORMIX" 
		cSubstSQL := "SUBSTR"
	Else
		cSubstSQL := "SUBSTRING"
	EndIf

	If cBDname $ "INFORMIX*ORACLE"
		cIsNullSQL := "NVL"
	ElseIf  cBDname $ "DB2*POSTGRES"  .OR. ( cBDname == "DB2/400" .And. Upper(cSrvType) == "ISERIES" )  
		cIsNullSQL := "COALESCE" 
	Else
		cIsNullSQL := "ISNULL"
	EndIf

	If lAI0_INDPAA == nil
		DBSelectArea("AI0")
		lAI0_INDPAA := AI0->(FieldPos("AI0_INDPAA")) > 0
	EndIf

	If __lFK7Cpos == Nil
		DBSelectArea("FK7")
		__lFK7Cpos	:= FK7->(ColumnPos("FK7_CLIFOR")) > 0 .And. FindFunction("FinFK7Cpos") .And. FExecFixN("2")
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FFinT157 
Exporta o cadastro de obras
@param cAliasQry, caracter, Alias da query 

@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function FFinT157(nCart,cAliasQry)
	Local lRet := .T.
	Local aRegs    := {}
	Local cReg     := "T157" // c�digo do registro no TAF
	Local cFilialTAF:= ""

	Local lGeraT157 := .T. 


	DbSelectArea("SON")
	SON->(DBSetOrder(1))  //ON_FILIAL, ON_CODIGO
	If SON->(MsSeek( xFilial("SON") + (cAliasQry)->FKF_CNO )) .and. aScan(aT157Env,{ |x| x[1] + x[2] == xFilial("SON") + SON->ON_CNO }) == 0


		If lIntTAF
			
			cFilialTAF:= FTafGetFil( allTrim( cEmpAnt ) + allTrim( cFilAnt ) , {} , "T9C" )
					
			//Verifica se no TAF o registro existe e n�o ha alteracoes.
			//Caso exista e nao haja alteracoes nos campos, N�o geramos
			//o registro na TAFST2 para a integracao. 
			DbSelectArea("T9C")
			T9C->(DBSetOrder(3))		
			If T9C->( MsSeek( cFilialTAF +  SON->ON_TPINSCR + SON->ON_CNO))
					
				If  Alltrim(T9C->T9C_TPINSC)   == SON->ON_TPINSCR  .And. ;
					Alltrim(T9C->T9C_NRINSC)   == Alltrim(SON->ON_CNO)  .And. ;
					Alltrim(T9C->T9C_INDOBR)   == Alltrim(SON->ON_IDOBRA)  .And. ;
					Alltrim(T9C->T9C_DSCOBR)   == Alltrim(SON->ON_DESC)  //.And. ;
					//Alltrim(T9C->T9C_INDTER)   == Alltrim(SON->ON_CNO)  		
					
					lGeraT157 := .F.
				EndIf
			EndIf
						
		EndIf
		
		If lGeraT157
		
			//Gera T157 - Cadastro de Obras
			cReg     := "T157"
			Aadd( aRegs, {  ;
			cReg,; 			// 1 Registro T157-Cadastro de Obras
			SON->ON_TPINSCR,;		// 2 TP_INSCRICAO
			SON->ON_CNO,;	// 3	NR_INSC_ESTAB
			SON->ON_IDOBRA,;// 4	IND_OBRA
			Iif(SON->ON_TPOBRA == "2","1","2"),;// 5	IND_TERCEIRO
			Substr(SON->ON_DESC,1,30);// 6	DESCRICAO
			})
			
			FConcTxt( aRegs, nHdlTxt )
			
			//Grava o registro na TABELA TAFST2 e limpa o array aDadosST1.
			If cTpSaida == "2"
				FConcST1()
			EndIf
		
			aAdd(aT157Env, {xFilial("SON"), SON->ON_CNO})
		EndIf
	EndIF

Return lRet

/*/{Protheus.doc} AddHash
@author Bruno Cremaschi
@since 25.02.2019
/*/
//-------------------------------------------------------------------

Static Function AddHash(oHash,cChave,nPos)
	Local cSet  As Character
	Local aList	As Array

	HMList(oHash, @aList)

	nPos := Len(aList) + 1

	cSet  := "HMSet"
	&cSet.(oHash, cChave, nPos)

Return

//-------------------------------------------------------------------
/*/
{Protheus.doc} FindHash
@author Bruno Cremaschi
@since 25.02.2019

/*/
//-------------------------------------------------------------------
Static Function FindHash(oHash, cChave, lFornec)
	Local nPosRet As Numeric
	Local cGet As Character

	Default lFornec	:= .F.

	nPosRet	:= 0
	cGet    := "HMGet"
	&cGet.( oHash , cChave  , @nPosRet )
	If lFornec .And. nPosRet == 0
		&cGet.( oHash , "F" + cChave  , @nPosRet )
	EndIf

Return nPosRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FEXPT003 
Chamada pelo extrator fiscal para exporta��o do T003 do financeiro
@param cFilQry, caracter, filial em execu��o
@param cTipoSaida, caracter, "1-Arquivo TXT", "2-Banco a Banco"
@param nHandle, num�rico, numero do handle, se for arquivo TXT
@param aWizard, array, informa��es do wizard do extrator fiscal

@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------

Function FEXPT003(cFilQry, cTipoSaida, nHandle, aWizard, lExtReinf, lFiltReinf, cFiltInt, _aListT003 )

Local aFils := {}
Local aResWiz2 := Array(10)
Local aResWiz3 := Array(11)
Local aResWiz4 := Array(4)
Local aResWiz5 := Array(8)

Default lExtReinf	:= .f.
Default lFiltReinf 	:= .f.
Default cFiltInt	:= "3"
Default _aListT003  := {}

lGerou := .F.

FFinIniVar(cFilQry, cTipoSaida, nHandle, aWizard, @aFils, @aResWiz2, @aResWiz3, @aResWiz4, @aResWiz5, "T003", lFiltReinf, cFiltInt)

FinExpTAF(/*1*/,/*2*/,aFils,aResWiz2,aResWiz3,aResWiz4,aResWiz5,/*8*/,/*9*/,lExtReinf,lFiltReinf,cFiltInt,@_aListT003 )

Return lGerou
		
//-------------------------------------------------------------------
/*/{Protheus.doc} FExpT001AB 
Chamada pelo extrator fiscal para exporta��o do T001AB do financeiro
@param cFilQry, caracter, filial em execu��o
@param cTipoSaida, caracter, "1-Arquivo TXT", "2-Banco a Banco"
@param nHandle, num�rico, numero do handle, se for arquivo TXT
@param aWizard, array, informa��es do wizard do extrator fiscal

@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------		
Function FExpT001AB(cFilQry, cTipoSaida, nHandle, aWizard, lExtReinf, lFiltReinf, cFiltInt)

Local aFils := {}
Local aResWiz2 := Array(10)
Local aResWiz3 := Array(11)
Local aResWiz4 := Array(4)
Local aResWiz5 := Array(8)

Default lExtReinf := .f.
Default lFiltReinf 	:= .f.
Default cFiltInt	:= "3"

lGerou := .F.

FFinIniVar(cFilQry, cTipoSaida, nHandle, aWizard, @aFils, @aResWiz2, @aResWiz3, @aResWiz4, @aResWiz5, "T001AB", lFiltReinf, cFiltInt)

FinExpTAF(,,aFils,aResWiz2,aResWiz3,aResWiz4,aResWiz5,,,lExtReinf, lFiltReinf, cFiltInt)

Return lGerou

//-------------------------------------------------------------------
/*/{Protheus.doc} FExpT157 
Chamada pelo extrator fiscal para exporta��o do T157 do financeiro
@param cFilQry, caracter, filial em execu��o
@param cTipoSaida, caracter, "1-Arquivo TXT", "2-Banco a Banco"
@param nHandle, num�rico, numero do handle, se for arquivo TXT
@param aWizard, array, informa��es do wizard do extrator fiscal

@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------		
Function FExpT157(cFilQry, cTipoSaida, nHandle, aWizard, lExtReinf)

Local aFils := {}
Local aResWiz2 := Array(10)
Local aResWiz3 := Array(11)
Local aResWiz4 := Array(4)
Local aResWiz5 := Array(8)

Default lExtReinf := .f.
Default lFiltReinf 	:= .f.
Default cFiltInt	:= "3"

FFinIniVar(cFilQry, cTipoSaida, nHandle, aWizard, @aFils, @aResWiz2, @aResWiz3, @aResWiz4, @aResWiz5, "T157")

FinExpTAF(,,aFils,aResWiz2,aResWiz3,aResWiz4,aResWiz5,,,lExtReinf)

Return	

//-------------------------------------------------------------------
/*/{Protheus.doc} FExpT154 
Chamada pelo extrator fiscal para exporta��o do T154 do financeiro
@param cFilQry, caracter, filial em execu��o
@param cTipoSaida, caracter, "1-Arquivo TXT", "2-Banco a Banco"
@param nHandle, num�rico, numero do handle, se for arquivo TXT
@param aWizard, array, informa��es do wizard do extrator fiscal
@param aParticip, array, lista de participantes
@param lExtReinf, logical, obsoleto (mantido por compartibilidade)
@param lFiltReinf, logical, filtra s� dados do REINF
@param cFiltInt, caracter, exporta 1=Cadastros;2=Movimentos;3=Ambos

@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------	
Function FExpT154(cFilQry, cTipoSaida, nHandle, aWizard, aParticip, lExtReinf, lFiltReinf, cFiltInt)

Local aFils := {}
Local aResWiz2 := Array(10)
Local aResWiz3 := Array(11)
Local aResWiz4 := Array(4)
Local aResWiz5 := Array(8)

Default aParticip := {}
Default lExtReinf := .f.
Default lFiltReinf 	:= .f.
Default cFiltInt	:= "3"

lGerou := .F.

FFinIniVar(cFilQry, cTipoSaida, nHandle, aWizard, @aFils, @aResWiz2, @aResWiz3, @aResWiz4, @aResWiz5, "T154", lFiltReinf, cFiltInt)

FinExpTAF(,,aFils,aResWiz2,aResWiz3,aResWiz4,aResWiz5,,@aParticip,lExtReinf, lFiltReinf, cFiltInt)

Return __lGer154

//-------------------------------------------------------------------
/*/{Protheus.doc} FExpT158 
Chamada pelo extrator fiscal para exporta��o do T158 do financeiro
@param cFilQry, caracter, filial em execu��o
@param cTipoSaida, caracter, "1-Arquivo TXT", "2-Banco a Banco"
@param nHandle, num�rico, numero do handle, se for arquivo TXT
@param aWizard, array, informa��es do wizard do extrator fiscal

@author Fabio Casagrande Lima
@since 11/01/2023
@version P12
/*/
//-------------------------------------------------------------------	
Function FExpT158(cFilQry, cTipoSaida, nHandle, aWizard, aParticip, lExtReinf, lFiltReinf, cFiltInt)

	Local aFils As Array
	Local aResWiz2 As Array
	Local aResWiz3 As Array
	Local aResWiz4 As Array
	Local aResWiz5 As Array

	Default cFilQry	:= ""
	Default cTipoSaida := ""
	Default nHandle := 0
	Default aWizard := {}
	Default aParticip := {}
	Default lExtReinf := .f.
	Default lFiltReinf 	:= .f.
	Default cFiltInt	:= "3"

	aFils    := {}
	aResWiz2 := Array(10)
	aResWiz3 := Array(11)
	aResWiz4 := Array(4)
	aResWiz5 := Array(11)

	FFinIniVar(cFilQry, cTipoSaida, nHandle, aWizard, @aFils, @aResWiz2, @aResWiz3, @aResWiz4, @aResWiz5, "T158", lFiltReinf, cFiltInt)

	FinExpTAF(,,aFils,aResWiz2,aResWiz3,aResWiz4,aResWiz5,,@aParticip,lExtReinf, lFiltReinf, cFiltInt)

Return __lGer158

//-------------------------------------------------------------------
/*/{Protheus.doc} FExpT159 
Chamada pelo extrator fiscal para exporta��o do T159 do financeiro
@param cFilQry, caracter, filial em execu��o
@param cTipoSaida, caracter, "1-Arquivo TXT", "2-Banco a Banco"
@param nHandle, num�rico, numero do handle, se for arquivo TXT
@param aWizard, array, informa��es do wizard do extrator fiscal

@author Fabio Casagrande Lima
@since 11/01/2023
@version P12
/*/
//-------------------------------------------------------------------		
Function FExpT159(cFilQry, cTipoSaida, nHandle, aWizard, lExtReinf)

	Local aFils As Array
	Local aResWiz2 As Array
	Local aResWiz3 As Array
	Local aResWiz4 As Array
	Local aResWiz5 As Array

	Default cFilQry	:= ""
	Default cTipoSaida := ""
	Default nHandle := 0
	Default aWizard := {}
	Default lExtReinf := .f.

	aFils := {}
	aResWiz2 := Array(10)
	aResWiz3 := Array(11)
	aResWiz4 := Array(4)
	aResWiz5 := Array(11)

	FFinIniVar(cFilQry, cTipoSaida, nHandle, aWizard, @aFils, @aResWiz2, @aResWiz3, @aResWiz4, @aResWiz5, "T159")

	FinExpTAF(,,aFils,aResWiz2,aResWiz3,aResWiz4,aResWiz5,,,lExtReinf)

Return __lGer159	

//-------------------------------------------------------------------
/*/{Protheus.doc} FExpT162 
Chamada pelo extrator fiscal para exporta��o do T162 do financeiro
@param cFilQry, caracter, filial em execu��o
@param cTipoSaida, caracter, "1-Arquivo TXT", "2-Banco a Banco"
@param nHandle, num�rico, numero do handle, se for arquivo TXT
@param aWizard, array, informa��es do wizard do extrator fiscal

@author Fabio Casagrande Lima
@since 11/01/2023
@version P12
/*/
//-------------------------------------------------------------------	
Function FExpT162(cFilQry, cTipoSaida, nHandle, aWizard, aParticip, lExtReinf, lFiltReinf, cFiltInt)

	Local aFils As Array
	Local aResWiz2 As Array
	Local aResWiz3 As Array
	Local aResWiz4 As Array
	Local aResWiz5 As Array

	Default cFilQry	:= ""
	Default cTipoSaida := ""
	Default nHandle := 0
	Default aWizard := {}
	Default aParticip := {}
	Default lExtReinf := .f.
	Default lFiltReinf 	:= .f.
	Default cFiltInt	:= "3"

	aFils := {}
	aResWiz2 := Array(10)
	aResWiz3 := Array(11)
	aResWiz4 := Array(4)
	aResWiz5 := Array(11)

	FFinIniVar(cFilQry, cTipoSaida, nHandle, aWizard, @aFils, @aResWiz2, @aResWiz3, @aResWiz4, @aResWiz5, "T162", lFiltReinf, cFiltInt)

	FinExpTAF(,,aFils,aResWiz2,aResWiz3,aResWiz4,aResWiz5,,@aParticip,lExtReinf, lFiltReinf, cFiltInt)

Return __lGer162

//-------------------------------------------------------------------
/*/{Protheus.doc} FFinIniVar 
Inicializa os array com as informa��es do wizard fiscal

@param cFilQry, caracter, filial em execu��o
@param cTipoSaida, caracter, "1-Arquivo TXT", "2-Banco a Banco"
@param nHandle, num�rico, numero do handle, se for arquivo TXT
@param aWizard, array, informa��es do wizard do extrator fiscal
@param aFils, array, filial a ser executada
@param aResWiz2, array, Parametros do titulo a receber
@param aResWiz3, array, Parametros do titulo a pagar e baixas 
@param aResWiz4, array, Parametros tipo de saida
@param aResWiz5, array, Parametros layout
@param cLayout, caracter, layout que ser� exportado

@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------	
Function FFinIniVar(cFilQry, cTipoSaida, nHandle, aWizard, aFils, aResWiz2, aResWiz3, aResWiz4, aResWiz5, cLayout, lFiltReinf, cFiltInt)

Default lFiltReinf := .F.
Default cFiltInt := "3"

//Seta static que a execu��o est� sendo chamada pelo extrator fiscal

aFils := {}
Aadd(aFils,cFilQry )

//Se mudar de filial, refaz a query dos titulos 
If cFilFiscal != cFilAnt
	lPagQry := .F.
	lRecQry := .F.
EndIf

// Parametros do titulo a receber
aResWiz2[1]	 := Val(aWizard[1][1]) //Considera Data 1 - Data de Contabiliza��o (EMIS1) 2-Data de Emiss�o (EMISSAO)
aResWiz2[2]	 := aWizard[1][2] //Data de
aResWiz2[3]	 := aWizard[1][3] //Data at�
aResWiz2[4]  := 4	//Tipo de Pessoa	"1-Pessoa F�sica","2-Pessoa Jur�dica","3-Todas"
aResWiz2[5]	 := ""//Cliente De
aResWiz2[6]	 := ""//Cliente Ate
aResWiz2[7]	 := ""//Loja De
aResWiz2[8]	 := ""//Loja Ate
aResWiz2[9]	 := aWizard[1][4] // Nota fiscal de
aResWiz2[10] := aWizard[1][5] // Nota fiscal Ate	

// Parametros do titulo a pagar e baixas 
aResWiz3[1]	:= Val(aWizard[2][1]) //Considera Data 1 - Emiss�o Digita. (EMIS1) 2-Emiss�o Real (EMISSAO)
aResWiz3[2]	:= 3 //Considera Data "1-Data Vencto Real (VENCREA)", "2-Data Vencto (VENCTO)", "3-Data baixa (BAIXA)"
aResWiz3[3]	:= aWizard[2][2]//Data de
aResWiz3[4]	:= aWizard[2][3]//Data at�
aResWiz3[5]	:= 4
aResWiz3[6]	:= ""
aResWiz3[7]	:= ""
aResWiz3[8]	:= ""
aResWiz3[9]	:= ""
aResWiz3[10]:= aWizard[1][4] // Nota fiscal de
aResWiz3[11]:= aWizard[1][5] // Nota fiscal Ate

//Parametros tipo de saida	
aResWiz4[1] := Val(cTipoSaida)
aResWiz4[2] := ""
aResWiz4[3] := ""
aResWiz4[4] := If(Empty(nHandle), 0, nHandle)

// Parametros layout
aResWiz5 := {.F., .F., .F., .F., .F., .F., .F., .F., .F., .F., .F. }

__nBx2030	:= Val(aWizard[3][1]) //Gera baixas a receber para o R-2030 ? 1 - N�o; 2 - Data da Baixa; 3 - Data do Cr�dito
__nBx2040	:= Val(aWizard[4][1]) //Gera baixas a pagar para o R-2040 ? 1 - N�o; 2 - Data da Baixa; 3 - Data do Pagto

If  cLayout == "T001AB"
	aResWiz5[1] := .T. // T001AB
ElseIf	cLayout == "T003"	
	aResWiz5[2] := .T. // T003
ElseIf cLayout == "T154"
	If lFiltReinf  .And. (cFiltInt $ "1|3" .Or. empty(cFiltInt))
		aResWiz5[2] := .T. // T003
	EndIf
	aResWiz5[3] := .T. // T154CR
	aResWiz5[4] := .T. // T154CP
	aResWiz5[5] := .T. // T154AA
ElseIf cLayout == "T157"
	aResWiz5[8] := .T.	// T157
ElseIf cLayout == "T158"
	If lFiltReinf  .And. (cFiltInt $ "1|3" .Or. empty(cFiltInt))
		aResWiz5[2] := .T. // T003
	EndIf
	aResWiz5[9] := .T. // T158
ElseIf cLayout == "T159"
	aResWiz5[10] := .T.	// T159
ElseIf cLayout == "T162"
	If lFiltReinf  .And. (cFiltInt $ "1|3" .Or. empty(cFiltInt))
		aResWiz5[2] := .T. // T003
	EndIf
	aResWiz5[11] := .T. // T162
EndIf

Return	

//-------------------------------------------------------------------
/*/{Protheus.doc} FFinExtFim 
Chamada pelo extrator fiscal para finalizar a extra��o e fechar as tabelas do fin
@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Function FFinExtFim()

	If !Empty(cAliasRQry)
		(cAliasRQry)->(DBCloseArea())
		cAliasRQry := nil
	Endif	
		
	If !Empty(cAliasPQry)
		(cAliasPQry)->(DBCloseArea())
		cAliasPQry := nil
	EndIf	
		
	aSize(aT157Env,0)
	aT157Env := {}

	aSize(aT001ABEnv,0)
	aT001ABEnv := {}

	//Grava os flags de integra��o do REINF para o financeiro
	F989Flag()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FFinExtOK
Verifica se o SIGAFIN est� atualizado para o REINF 2.1.1 (bloco 40).
Obs: � chamado no ExtFisxTaF.Prw antes das chamadas das fun��es do FINA989

@author fabio.casagrande
@since 16/01/2023
@version P12
/*/
//-------------------------------------------------------------------
Function FFinExtOK()

	Local lRet := .F.

	If TableInDic('FKW')
		lRet := .T. 
	EndIf 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FatuCrT003
Faturas Contas a Receber, chamada pelo extrator fiscal para listar de 
forma distinta todos os clientes, quando reinf = 'sim' e 
fitra = 'apenas cadastros', � necess�rio rodar as movimenta��es para 
identificar os participantes para o reinf.

@author Denis Souza
@since 15/05/2019
@version P12
/*/
//-------------------------------------------------------------------
Function FatuCrT003( aRegT003, oWizard )

	Local cQuery As Character
	Local cOrdem As Character
	Local cCond  As Character

	Default aRegT003 := {}
	Default oWizard  := Nil

	cQuery 	   := ""
	dDataEmDe  := CtoD('  /  /    ')
	dDataEmAte := CtoD('  /  /    ')
	nTpEmData  := 2

	If Type("oWizard") == "O"
		dDataEmDe	:= oWizard:GetDataDe()
		dDataEmAte	:= oWizard:GetDataAte()
		nTpEmData	:= Val( oWizard:GetTituReceber() )

		If Type("cLojaCliAte") == "U"
			nTpEmPessoa := 1
			cCliDe		:= ""
			cCliAte		:= ""
			cLojaCliDe	:= ""
			cLojaCliAte	:= ""
		EndIf
		If Empty( cAliaSE1 )
			cAliaSE1 := GetNextAlias()
		EndIf

		cCampos1 := " SA1.R_E_C_N_O_ A1_RECNO "
		cCampos2 := cCampos1
		cOrdem := " ORDER BY A1_RECNO "
		cCond  := ""

		//Monta query principal que obtem os t�tulos a receber
		cQuery := F989QryRec(cCampos1, cCampos2, cOrdem, @cCond)

		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliaSE1,.F.,.T.)

		(cAliaSE1)->(DbGotop())
		While (cAliaSE1)->(!Eof())
			("SA1")->( DbGoTo( (cAliaSE1)->A1_RECNO ) )		
			RegT003Pos( "SA1" , @aRegT003 )
			(cAliaSE1)->(DBSkip())
		EndDo

		If !Empty(cAliaSE1)
			(cAliaSE1)->(DBCloseArea())
			cAliaSE1 := nil
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FatuCpT003
Faturas Contas a Pagar, chamada pelo extrator fiscal para listar de forma 
distinta todos os fornecedores, quando reinf = 'sim' e fitra = 'apenas cadastros', 
� necess�rio rodar as movimenta��es para identificar os participantes para o reinf.

@author Denis Souza
@since 15/05/2019
@version P12
/*/
//-------------------------------------------------------------------
Function FatuCpT003( aRegT003, oWizard )

	Local cQuery As Character
	Local cCampos As Character
	Local cOrdem As Character
	Local nI As Numeric

	nI	:= 1

	If Type("oWizard") == "O"
		dDataPgDe	:= oWizard:GetDataDe()
		dDataPgAte	:= oWizard:GetDataAte()
		nTpPgEmis	:= Val( oWizard:GetTituReceber() )

		If Type("cLojaForAte") == "U"
			nTpPgPessoa := 1
			cForDe		:= ""
			cForAte		:= ""
			cLojaForDe	:= ""
			cLojaForAte	:= ""
		EndIf
		If Empty( cAliaSE2 )
			cAliaSE2 := GetNextAlias()
		EndIf

		cCampos := " SA2.R_E_C_N_O_ A2_RECNO, A2_IRPROG, A2_COD, A2_LOJA, A2_IRPROG "
		cOrdem := " ORDER BY A2_RECNO "

		//Monta query
		cQuery := F989QryPag(cCampos, cOrdem, .T.)

		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliaSE2,.F.,.T.)

		(cAliaSE2)->(DbGotop())
		While (cAliaSE2)->(!Eof())
			("SA2")->( DbGoTo( (cAliaSE2)->A2_RECNO ) )		
			RegT003Pos( "SA2" , @aRegT003 )
			//Verifica se possui rateio entre CPF's (IR aluguel)
			If __lTemFKJ .And. (cAliaSE2)->A2_IRPROG == '1'
				FForIrProg(@aRegT003[nI], (cAliaSE2)->A2_COD + (cAliaSE2)->A2_LOJA, Len(aRegT003[nI]))
			EndIf
			nI++
			(cAliaSE2)->(DBSkip())
		EndDo

		If !Empty(cAliaSE2)
			(cAliaSE2)->(DBCloseArea())
			cAliaSE2 := nil
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FFinT158
Gera os registros do Layout FFinT158 de baixas a pagar com IR e PCC - Pagamentos

@param	nRecno		- Caso queira exportar somente um recno em especIfico
		nCart		- Tipo de Carteira
		cAliasQry	- Variavel contendo o Alias da Tabela Temporaria
		
@return	lRet	- Retorna .t. para final de execu��o

@author Rodrigo Pirolo
@since 28/07/2016
@version P12
/*/
//-------------------------------------------------------------------
Function FFinT158( nRecno As Numeric, nCart As Numeric, cAliasQry As Character)

	Local aDetDed As Array
	Local aDetIse As Array
	Local aRegs As Array
	Local aT158Trb As Array
	Local aT158AG As Array
	Local lRet As Logical
	Local lTitPA As Logical	
	Local lIRBaixa As Logical
	Local lTemNatR As Logical
	Local lNatRenBx As Logical
	Local lFornPF As Logical
	Local lIsento As Logical
	Local lSuspFKW As Logical
	Local cAliasBx As Character
	Local cImpIR As Character
	Local cImpPis As Character
	Local cImpCof As Character
	Local cImpCSL As Character
	Local cNatRen As Character
	Local cNrProc As Character
	Local cCNPJSCP As Character
	Local cIndScp As Character
	Local cIdDoc As Character
	Local cOldNatRen As Character
	Local cCodPart As Character
	Local dDataPg As Date
	Local nI As Numeric
	Local nY As Numeric
	Local nX As Numeric
	Local nW As Numeric
	Local nZ As Numeric

	Default nRecno		:= 0
	Default nCart		:= 0
	Default cAliasQry	:= ""

	lRet	  	:= .T.
	cAliasBx  	:= GetNextAlias()
	aT158Trb  	:= {}
	aDetDed	  	:= {}
	aDetIse	  	:= {}
	aRegs	  	:= {}
	aT158AG		:= {}
	cImpIR	  	:= PadR( 'IRF', __nFkgImp )
	cImpPis	  	:= PadR( 'PIS', __nFkgImp )
	cImpCof	  	:= PadR( 'COF', __nFkgImp )
	cImpCSL	  	:= PadR( 'CSL', __nFkgImp )
	dDataPg   	:= CTOD("  /  /    ")
	cNrProc	  	:= ""
	cCNPJSCP  	:= ""
	cIndScp   	:= ""
	cOldNatRen	:= ""
	lTitPA    	:= (cAliasQry)->E2_TIPO $ MVPAGANT
	cNatRen	  	:= (cAliasQry)->FKF_NATREN
	cIdDoc    	:= (cAliasQry)->FK7_IDDOC
	cCodPart  	:= (cAliasQry)->COD + (cAliasQry)->LOJA
	lIRBaixa  	:= (cAliasQry)->A2_CALCIRF == "2"
	lTemNatR  	:= .F.
	lNatRenBx 	:= .F.
	lIsento   	:= .F.
	lFornPF   	:= (cAliasQry)->A2_TIPO == "F" .Or. ((cAliasQry)->A2_TIPO == "J" .And. (cAliasQry)->A2_IRPROG == "1") //PJ c/ IR Progressivo, ser� tratado como Pessoa F�sica.
	lSuspFKW	:= .F.

	If !_lPCCBaixa .or. lTitPA
		lTemNatR := FTemFKW(cIdDoc)	//Verifica��o via FKW quando ambiente for de "PCC na emissao" ou o titulo for PA (n�o h� FKY nesses casos)
	Else
		lTemNatR := FTemFKY(cIdDoc)	//Verifica��o via FKY para as demais situa��es	
	Endif

	If lTemNatR //Verifica se o titulo possui vinculo com naturezas de rendimento 

		//Monta tabela temporaria (alias cAliasBx) com os pagamentos do periodo de extra��o selecionado 
		IF lTitPA
			MntQryAdt(@cAliasBx) //Busca dados do titulo de adiantamento considerando SE2/FK7/FKF/SE5
		Elseif !_lPCCBaixa
			MntQry158a(@cAliasBx) //Busca dados das baixas quando o PCC na emissao (MV_BX10925=2), com o PCC proporcionalizado pelo valor da baixa			
		Else
			MntQry158b(@cAliasBx) //Verifica se o titulo possui baixa no periodo e retorna os dados
		Endif

		While (cAliasBx)->(!Eof())

			dDataPg := STOD((cAliasBx)->DATAFG)

			//Indica se � um pagamento relacionado a uma SCP (sociedade em conta de participa��o)
			If !Empty((cAliasQry)->FKF_CGCSCP)
				cIndScp  := "2"
			Endif

			If lFornPF
				If __lTemFKJ //Tratamento para Rateio IR Aluguel
					If (!Empty((cAliasQry)->FKJ_CPF) .And. !Empty((cAliasBx)->CPF) ) .And. AllTrim((cAliasQry)->FKJ_CPF) != AllTrim((cAliasBx)->CPF)
						(cAliasBx)->(DbSkip())
						Loop
					EndIf
					If !Empty((cAliasBx)->CPF) .And. (cAliasQry)->A2_IRPROG == '1'
						cCodPart := (cAliasBx)->CPF
					EndIf
				EndIf
				If lIRBaixa
					//Verifica se ha dedu��es ou isen��es para o IR no complemento do t�tulo (tabela FKG) 
					//quando for t�tulo de fornecedor PF (REINF 2.1.1). Carrega os arrays aDetDed (dedu��es) e aDetIse (isen��es)
					FDedIse(cIdDoc, @aDetDed, @aDetIse, @lIsento, cAliasQry, dDataPg, (cAliasBx)->VALIRF)
				EndIf
			EndIf

			/*---------------------------------------|
			| C�digos de tributos no layout do TAF:	 | 
			| 10=PIS;								 |
			| 11=Cofins;							 |
			| 12=IR emiss�o;					 	 |
			| 13=INSS;								 |
			| 18=CSLL;								 |	
			| 28=IR baixa 							 |
			----------------------------------------*/		

			FWFreeArray(aRegs)
			aRegs := {}
			cReg  := "T158" //Pagamentos das parcelas da fatura/recibo
			
			AAdd( aRegs, { cReg,;								   //01 - REGISTRO - Tipo de Registro
						(cAliasQry)->E2_NUM,;				       //02 - NUMERO - N�mero da fatura/recibo
						(cAliasQry)->E2_PREFIXO,;			       //03 - SERIE - S�rie da fatura/recibo
						"F" + cCodPart,; 						   //04 - COD_PARTICIPANTE - Participante da fatura/recibo
						(cAliasQry)->E2_EMISSAO,;			  	   //05 - EMISSAO - Data de Emiss�o da fatura/recibo
						"0",;		      						   //06 - NATUREZ - Natureza da fatura/recibo (0-PAGAR; 1-RECEBER)
						(cAliasQry)->E2_PARCELA,;			       //07 - NUM_PARC - Natureza da fatura/recibo
						dDataPg,;							       //08 - DT_PGTO - Data que foi realizado o pagamento da parcela
						(cAliasBx)->SEQ,;					       //09 - SEQUENCIAL - Sequencial para idenfica��o do pagamento efetuado
						cIndScp } )					  		       //10 - INDFCISCP - Indicativo de opera��o com FCI ou SCP

			FConcTxt( aRegs, nHdlTxt )
	
			//Verifica se h� pagamentos vinculados a natureza(s) de rendimento, retornando dados de retencao, isen��o e suspen��o.
			IF lTitPA
				//Titulo de adiantamento - Busca os dados na inclus�o do titulo (FKW)
				lNatRenBx := NatRenPA(cAliasBx, cAliasQry, @aT158Trb, lFornPF, dDataPg, lIsento)
			Elseif !_lPCCBaixa
				//Quando o PCC estiver na emissao (MV_BX10925=2), proporcionaliza o PCC conforme o valor baixado (via FKW). 
				//Para o IR na baixa ser� considerado a FKY.
				lNatRenBx := NatPropBX(cAliasBx, cAliasQry, @aT158Trb, lFornPF, dDataPg, lIsento)
			Else
				//Busca os pagamentos com IR, PIS, COFINS e CSLL com fato gerador na baixa
				lNatRenBx := NatRenFKY(cAliasBx, cAliasQry, @aT158Trb, lFornPF, dDataPg, lIsento)
			Endif

			If lNatRenBx .and. Len(aT158Trb) > 0

				/*--------------------------------------------------------------------------------------------|
				| Composi��o do array aT158Trb:	 															  | 
				| aT158Trb[nI][1]  - Codigo do tributo no layout TAF										  |
				| aT158Trb[nI][2]  - C�digo da natureza de rendimento										  |
				| aT158Trb[nI][3]  - Rendimento bruto														  |
				| aT158Trb[nI][4]  - Rendimento tributavel ou isento										  |
				| aT158Trb[nI][5]  - Valor do tributo retido ou isento 										  |
				| aT158Trb[nI][6]  - Identifica��o do processo judicial/administrativo ou ato concess�rio     |
				| aT158Trb[nI][7]  - Indicador da origem do processo 										  |
				| aT158Trb[nI][8]  - C�digo do Indicativo da Suspens�o										  |	
				| aT158Trb[nI][09] - Valor da reten��o que deixou de ser efetuada por um processo adm/judicial|
				| aT158Trb[nI][10] - Valor da base de c�lculo com exigibilidade suspensa ou isen��o			  |
				----------------------------------------------------------------------------------------------*/		
				
				For nI := 1 To Len(aT158Trb)

					//Verifica se � opera��o de uma SCP para enviar o CNPJ da SCP do pagamento
					If aT158Trb[nI][2] $ __cNatSCP .and. !Empty((cAliasQry)->FKF_CGCSCP)
						cCNPJSCP := (cAliasQry)->FKF_CGCSCP 
					Endif

					If aT158Trb[nI][2] <> cOldNatRen //Gera T158AA s� se for uma natureza de rendimento diferente
						aRegs := {}
						cReg  := "T158AA" //Natureza de Rendimento

						AAdd( aRegs, {	cReg,;						//01 - REGISTRO - Tipo de Registro
										aT158Trb[nI][2],;			//02 - NATUREZA_RENDIMENTO - C�digo da natureza de rendimento
										aT158Trb[nI][3],;			//03 - VLR_PGTO - Valor do pagamento por natureza de rendimento
										(cAliasQry)->FKF_INDDEC,;	//04 - IND_DEC_TERC - Indicativo de 13� sal�rio (1=Sim; 2=N�o)
										cCNPJSCP,;					//05 - NR_INSC_FCI_SCP - CNPJ da FCI ou SCP (sociedade em conta da participa��o)
										"" ,;						//06 - INDRRA - Indicativo de Rendimento Recebido Acumuladamente - RRA (0 - N�o; 1 - Sim)
										"" ,;					    //07 - TPPROCRRA - Tipo de processo (1 - Administrativo; 2 - Judicial)
										cNrProc ,;					//08 - NRPROC - N�mero do processo/requerimento administrativo/judicial
										"" } )						//09 - COMPFP - Compet�ncia do Rendimento do trabalho
						
						FConcTxt( aRegs, nHdlTxt )
					EndIf

					cOldNatRen := aT158Trb[nI][2]

					If Alltrim(aT158Trb[nI][1]) $ "10|11|18|28" //Tributos validos no T158AA/T158AB
						aRegs := {}
						cReg  := "T158AB" //Tributos do Pagamento

						AAdd( aRegs, {	cReg,;				//01 - REGISTRO - Tipo de Registro
										aT158Trb[nI][1],;	//02 - TRIBUTO - Informar o codigo que corresponde ao tributo
										aT158Trb[nI][4],;	//03 - BASE_CALCULO - Base de calculo do tributo
										aT158Trb[nI][5],;	//04 - VLR_TRIBUTO - Valor calculado do tributo
										0 } )				//05 - ALIQUOTA - Valor calculado do tributo
			
						FConcTxt( aRegs, nHdlTxt )

						If !Empty(aT158Trb[nI][6]) //Verifica se h� suspens�o de exigibilidade de tributos
							aRegs := {}
							cReg  := "T158AC" //Suspens�o de exigibilidade de tributo

							AAdd( aRegs, {	cReg,;				//01 - REGISTRO - Tipo de Registro
											aT158Trb[nI][6],;	//02 - NUM_PROC - Identifica��o do processo ou ato concess�rio
											aT158Trb[nI][7],;	//03 - IND_PROC - Indicador da origem do processo (0 - SEFAZ; 1 - Justi�a Federal; 2 - Justi�a Estadual; 3 � Secretaria da Receita Federal do Brasil; 9 � Outros)
											aT158Trb[nI][8],;	//04 - COD_SUS - C�digo do Indicativo da Suspens�o
											aT158Trb[nI][1],;	//05 - COD_TRIB - Informar o codigo que corresponde ao tributo
											aT158Trb[nI][09],;	//06 - VAL_SUS - Valor da reten��o de que deixou de ser efetuada em fun��o de processo administrativo ou judicial
											aT158Trb[nI][10],;	//07 - BASE_SUSPENSA - Valor da base de c�lculo do tributo com exigibilidade suspensa
											0 ,;				//08 - VLR_COMP_ANO_CALENDARIO - Compensa��o Judicial relativa ao ano calend�rio
											0 } )				//09 - VLR_COMP_ANO_ANT - Compensa��o Judicial relativa a anos anteriores ao ano calend�rio.

							FConcTxt( aRegs, nHdlTxt)
							
							//Envia dedu��es que seriam feitas se o IRPF n�o estivesse suspenso
							If (cAliasBx)->SEQ == (cAliasBx)->SEQMAX .AND. (cAliasQry)->E2_SALDO == 0 //Envia as dedu��es s� quando for baixa total ou a baixa do residual

								//Verifica se ha suspencao da retencao do IR na emissao e carraga o array aT154AF
								lSuspFKW := FKWSusp( cIdDoc )

								//Alimenta o array "aT158AG" com as dedu��es do IRPF que foi suspenso
								FDedIse(cIdDoc, @aT158AG,,, cAliasQry, dDataPg, (cAliasBx)->VALIRF, lSuspFKW)

								If Len(aT158AG) > 0
									//Monta o registro T158AG com as dedu��es do IRPF que foi suspenso
									For nZ := 1 to Len(aT158AG)
										aRegs := {}
										cReg  := "T158AG" // Detalhamento das dedu��es com exigibilidade suspensa

										AAdd( aRegs, {	cReg,;			  //01 - REGISTRO - Tipo de Registro
														aT158AG[nZ][1],;  //02 - IND_TP_DEDUCAO - Indicativo do tipo de dedu��o
														aT158AG[nZ][3]} ) //03 - VAL_DEDUCAO - Valor da dedu��o com exigibilidade suspensa

										FConcTxt( aRegs, nHdlTxt)

										If Len(aT158AG[nZ][5]) > 0 //Verifica se a dedu��o possui dependentes (DHT)
											//Monta o registro T158AH com os valores das dedu��es por dependente
											For nW := 1 to Len(aT158AG[nZ][5])
												aRegs := {}
												cReg  := "T158AH" // Informa��o das dedu��es suspensas por dependentes ou pens�o

												AAdd( aRegs, {	cReg,;			  		 //01 - REGISTRO - Tipo de Registro
																aT158AG[nZ][5][nW][2],;  //02 - CPF - N�mero de Inscri��o no CPF.
																aT158AG[nZ][5][nW][3]} ) //03 - VAL_DEDUCAO_SUSPENSO - Valor da dedu��o relativa a dependentes/pens�o aliment�cia.

												FConcTxt( aRegs, nHdlTxt)
											Next nW
										EndIf

									Next nZ
								EndIf
								aT158AG  := {}
							EndIf
						EndIf

						//Gera a tabela T158AD com as dedu��es de IR pessoa fisica
						If (cAliasBx)->SEQ == (cAliasBx)->SEQMAX .AND. (cAliasQry)->E2_SALDO == 0 //Envia as dedu��es s� quando for baixa total ou a baixa do residual
							For nY := 1 To Len( aDetDed )
								aRegs := {}
								cReg  := "T158AD" // Detalhamento das Dedu��es
								
								/*------------------------------------------------|
								| Tipos de Dedu��o (02 - TIPO_DEDUCAO): 		  | 
								| 1 - Previdencia Oficial/INSS					  |
								| 2 - Previdencia Privada						  |
								| 3 - Fapi										  |
								| 4 - Funpresp									  |
								| 5 - Pens�o Aliment�cia						  |
								| 6 - Contribui��o do ente p�blico patrocinador   |
								| 7 - Dependentes								  |
								-------------------------------------------------*/	

								AAdd( aRegs, {	cReg,;				//01 - REGISTRO - Tipo de Registro
												aDetDed[nY][1],;	//02 - TIPO_DEDUCAO - Indicativo do Tipo de Dedu��o
												aDetDed[nY][2],;	//03 - VAL_DEDUCAO - Preencher com o valor da Dedu��o da base de c�lculo
												aDetDed[nY][3],;	//04 - VAL_DEDUCAO_SUSP - Valor da Dedu��o da base de c�lculo do Imposto de Renda, com exigibilidade suspensa
												aDetDed[nY][4],;	//05 - NUM_PREVIDENCIA - N�mero de Inscri��o da entidade de Previdencia complementar
												aDetDed[nY][6] } )	//06 - INFO_ENTIDADE - Possui informa��es da entidade de previd�ncia complementar? 0 - N�o;1 - Sim;

								FConcTxt( aRegs, nHdlTxt )
								If Len(aDetDed[nY][5]) > 0 //Verifica se a dedu��o possui dependentes (DHT)
									//Monta o registro T158AF com os dependentes da dedu��o
									For nW := 1 to Len(aDetDed[nY][5])
										aRegs := {}
										cReg  := "T158AF" // Informa��o das dedu��es por dependentes ou pens�o

										AAdd( aRegs, {	cReg,;			  		 //01 - REGISTRO - Tipo de Registro
														aDetDed[nY][5][nW][2],;  //02 - CPF - N�mero de Inscri��o no CPF.
														aDetDed[nY][5][nW][3]} ) //03 - VAL_DEDUCAO - Valor da dedu��o do dependentes/pens�o aliment�cia.

										FConcTxt( aRegs, nHdlTxt)
									Next nW
								EndIf
							Next nY //Fim da verifica��o da T158AD
						Endif

						//Gera a tabela T158AE com as isen��es de IR an baixa de fornecedores pessoa fisica
						For nX := 1 To Len( aDetIse )
							aRegs := {}
							cReg  := "T158AE" // Detalhamento das isen��es
							
							/*-----------------------------------------------------------|
							| Tipos de isen��o (02 - TIPO_ISENCAO):  		  			 | 
							| 1 - Parcela Isenta 65 anos;                                |
							| 2 - Di�ria de viagem;                                      |
							| 3 - Indeniza��o e rescis�o de contrato, inclusive a...     |
							| 4 - Abono pecuni�rio;                                      |
							| 5 - Valores pagos a titular ou s�cio de microempresa...    |
							| 6 - Pens�o, aposentadoria ou reforma por molestia grave... |
							| 7 - Complementa��o de aposentadoria, correspondente �s...  |
							| 8 - Ajuda de custo;                                        |
							| 99 - Outros (especIficar).					             |
							------------------------------------------------------------*/	

							AAdd( aRegs, {	cReg,;					 //01 - REGISTRO - Tipo de Registro
											aDetIse[nX][1],;	 	 //02 - TIPO_ISENCAO - Tipo de isen��o
											aT158Trb[nI][10],; 		 //03 - VAL_ISENTO - Valor da parcela isenta
											aDetIse[nX][3] } )		 //04 - DESC_RENDIMENTO - Informar somente quando o tipo for "99" (outros)

							FConcTxt( aRegs, nHdlTxt )

						Next nX	//Fim da verifica��o da T158AE
					Endif
				Next nI	//Fim da verifica��o do array aT158Trb
			Endif

			aT158Trb := {}
			aDetDed := {}
			aDetIse := {} 
			lIsento := .F.
			cOldNatRen := ""

			//Grava o flag de envio ao TAF quando a integracao for banco-a-banco
			If __lVerFlag 
				//Grava flag dos dados de pagamentos T158 (FK2_REINF)
				If lTitPA
					AAdd( __aFK7Id, { (cAliasQry)->FKF_FILIAL, (cAliasQry)->FK7_IDDOC } ) // Adiciona o IDDOC da FK7 para posteriormente realizar a grava��o do FLAG
				Else
					AAdd( __aFK2Id, { (cAliasBx)->FILIAL, (cAliasBx)->IDMOV } ) //Grava IDFK2 para controle posterior de gravacao da flag (FK2_REINF)
				EndIf
			EndIf

			//Grava o registro na TABELA TAFST2 e limpa o array aDadosST1.
			If cTpSaida == "2" .AND. Len(aDadosST1) > 0
				FConcST1()
			EndIf	

			__lGer158 := .T.

			(cAliasBx)->( DbSkip() )

		EndDo

		If Select(cAliasBx) > 0
			(cAliasBx)->(DbCloseArea())
		EndIf
	EndIf

	FwFreeArray(aT158Trb)
	FwFreeArray(aDetDed)
	FwFreeArray(aDetIse)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F989FKH
Fun��o para verificar se existem dados na tabela FKH para realizar 
a integra��o.

@param	cFilAnt	- Filial logada
@param	nCart	- Indica qual a carteira 1(pagar) 2(receber)
@return lRet	- Retorna .T. para final de execu��o

@author Rodrigo Pirolo
@since 19/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function F989FKH(cFilAnt As Char, nCart As Numeric) As Logical

	Local cQuery	As Character
	Local lTemExc	As Logical

	Default cFilAnt	:= ""
	Default nCart	:= 1

	cQuery	:= ""
	lTemExc	:= .F.

	If __oSttFKH == NIL
		cQuery	:= " SELECT ISNULL(Count(FKH_REINF), 0) FKH_REINF "
		cQuery	+= " FROM " + RetSQLName("FKH") + " FKH "
		cQuery	+= " WHERE FKH.FKH_FILIAL = ? "
		cQuery	+= 			" AND FKH.FKH_REINF IN (' ', '2') "
		cQuery	+= 			" AND FKH.FKH_TABORI IN ( ? ) "
		cQuery	+= 			" AND FKH.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery( cQuery )
		__oSttFKH := FWPreparedStatement():New( cQuery )
	EndIf

	__oSttFKH:SetString( 1, cFilAnt	)

	If nCart == 1
		__oSttFKH:SetIn( 2, {"SE2","FK2"} )
	ElseIf nCart == 2
		__oSttFKH:SetIn( 2, {"SE1"} )
	EndIf

	cQuery := __oSttFKH:GetFixQuery()

	lTemExc := MpSysExecScalar( cQuery, "FKH_REINF" ) > 0

Return lTemExc

//-------------------------------------------------------------------
/*/{Protheus.doc} F989EnvFKH
Fun��o para armazenar os dados da FKH para enviar ao TAF a 
tabela T999 (FKH_LAYOUT).

Os registros da FKH sao para a exclusao de registro pai no TAF,
e serao gravados nas seguintes situacoes:
	- Exclusao do titulo a pagar/receber ja integrado ao TAF (FKF_REINF=1).
	- Exclusao/cancelamento de baixas a pagar ja integradas ao TAF (FK2_REINF=1)

@param	cFilAnt	- Filial logada
@param	nCart	- Indica qual a carteira 1(pagar) 2(receber)
@return lRet	- Retorna .T. para final de execu��o

@author Rodrigo Pirolo
@since 19/08/2019
@version P12
/*/
//-------------------------------------------------------------------

Static Function F989EnvFKH(cFilAnt As Char, nCart As Numeric) As Logical

	Local lRet		As Logical
	Local cQuery	As Character
	Local cAliasFKH	As Character
	Local aRegs		As Array

	Default cFilAnt	:= xFilial("FKH")
	Default nCart	:= 0
	
	lRet	  := .T.
	cQuery	  := ""
	cAliasFKH := GetNextAlias()
	aRegs	  := {}

	If __oQryFKH == Nil	
		cQuery	:= " SELECT FKH.FKH_FILIAL, FKH.FKH_LAYOUT, FKH.FKH_ID, FKH.FKH_REVISA, "
		If cBDname $ "ORACLE"
			cQuery	+=		" CAST( FKH.FKH_MSGTAF AS VARCHAR2(100) ) FKHMSGTAF, "
		ElseIf cBDname $ "DB2|POSTGRES|INFORMIX"
			cQuery	+=		" CAST( FKH.FKH_MSGTAF AS VARCHAR(100) ) FKHMSGTAF, "
		Else
			cQuery	+=		" CONVERT(VARCHAR(100), FKH.FKH_MSGTAF) FKHMSGTAF, "
		EndIf
		cQuery	+=			" FKH.R_E_C_N_O_ RECNO "
		cQuery	+= " FROM " + RetSQLName("FKH") + " FKH "
		cQuery	+= " WHERE FKH.FKH_FILIAL = ? "
		cQuery	+= 			" AND FKH.FKH_REINF IN ('2',' ') "
		
		If nCart == 1
			cQuery	+= 			" AND FKH.FKH_TABORI IN ( 'SE2','FK2' ) "
		ElseIf nCart == 2
			cQuery	+= 			" AND FKH.FKH_TABORI = 'SE1' "
		EndIf	
		
		cQuery	+= 			" AND FKH.D_E_L_E_T_ = ' ' "
		cQuery	+= " ORDER BY FKH.FKH_FILIAL, FKH.FKH_LAYOUT"

		If cBDname $ "ORACLE|DB2|POSTGRES|INFORMIX
			cQuery	+= ", FKHMSGTAF "
		Else
			cQuery	+= ", FKH.FKH_MSGTAF "
		EndIf

		cQuery := ChangeQuery( cQuery )
        If __lCachQry
            __oQryFKH := FwExecStatement():New(cQuery)
        Else
            __oQryFKH := FWPreparedStatement():New(cQuery)
        EndIf 
	Endif

	__oQryFKH:SetString(1, cFilAnt)
	cQuery 	 := __oQryFKH:GetFixQuery()
	DbUseArea( .T., "TOPCONN", TCGENQRY( , , cQuery ), cAliasFKH, .F., .T. )

	While (cAliasFKH)->( !EOF() )

		AAdd( aRegs, {	(cAliasFKH)->FKH_LAYOUT,;	//01-TIPO REGISTRO
						(cAliasFKH)->FKHMSGTAF	} )	//02-CHAVE

		FConcTxt( aRegs, nHdlTxt )

		If cTpSaida == "2" .AND. Len(aDadosST1) > 0
			FConcST1()
		EndIf

		FWFreeArray(aRegs)
		aRegs	:= {}

		//Grava flag dos dados de reenvio T999 (FKH_REINF)
		AAdd( __aFKHId, { (cAliasFKH)->FKH_FILIAL, (cAliasFKH)->FKH_LAYOUT, (cAliasFKH)->FKH_ID, (cAliasFKH)->FKH_REVISA } )

		(cAliasFKH)->( DbSkip() )
	EndDo

	If Select(cAliasFKH) > 0
		(cAliasFKH)->(dbCloseArea())
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FFinT159 
Exporta cadastro Sociedade em conta de participa��o (SCP)

@param nCart	- Indica qual a carteira 1(pagar) 2(receber)
@param cAliasQry - Alias da query 
@param aRegT159A - Array com os dados das SCP

@author Pequim
@since 18/09/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function FFinT159(nCart As Numeric, cAliasQry As Character, aRegT159A As Array) As Logical

	Local lRet		As Logical
	Local cQuery	As Character
	Local cAliasFOD	As Character
	Local cChaveSCP As Character
	Local cFilSCP	As Character
	Local cDtIni    As Character
	Local cDtFim    As Character

	Default cFilAnt	:= xFilial("FOD")
	Default nCart	:= 0
	Default aRegT159A := {}

	lRet		:= .T.
	cQuery		:= ""
	cAliasFOD	:= ""
	cChaveSCP	:= ""	
	cFilSCP		:= ""
	cDtIni      := ""
	cDtFim      := ""

	If (cAliasQry)->FKF_NATREN $ __cNatSCP .and. !Empty( (cAliasQry)->A2_CGC )
		FOD->(dbSetOrder(3))		//FOD_FILIAL+FOD_CGCCPF
		If FOD->( MsSeek(xFilial("FOD") + (cAliasQry)->A2_CGC ) )
			cChaveFOD := xFilial("FOD") + (cAliasQry)->A2_CGC
			//Pego todas as filials SCP do qual o s�cio participa
			While !(FOD->(EOF())) .AND. xFilial("FOD") + FOD->FOD_CGCCPF == cChaveFOD
				If aScan(__aT159Env,{ |x| x[1] + x[2] == xFilial("FOD") + FOD->FOD_FILSCP }) == 0
					cChaveSCP += FOD->FOD_FILSCP + "|"
				Endif
				FOD->(DBSkip())
			EndDo	
		Endif

		If !Empty(cChaveSCP)

			aFilSCP := StrtoKarr2( cChaveSCP, "|", .F.)
			cChaveSCP := ""

			If __oSttFOD == NIL
				cQuery	:= " SELECT FOD.FOD_FILIAL, FOD.FOD_FILSCP, FOD.FOD_FILSOC, FOD.FOD_CGCSCP, "
				cQuery	+= " FOD.FOD_CGCCPF, FOD.FOD_PERCEN, FOD.FOD_INIVIG, FOD_FIMVIG, "
				cQuery	+= " SA2.A2_FILIAL, SA2.A2_COD, SA2.A2_LOJA, SA2.A2_CGC "
				cQuery	+= " FROM " + RetSQLName("FOD") + " FOD " 

				cQuery += " INNER JOIN "+ RetSqlName("SA2") + " SA2 "
				cQuery += " ON (SA2.A2_FILIAL = ? "		
				cQuery += " AND SA2.A2_CGC = FOD.FOD_CGCCPF "
				cQuery += " AND SA2.D_E_L_E_T_ = ' ' )"

				cQuery	+= " WHERE FOD.FOD_FILIAL = '" + xFilial("FOD", cFilAnt) + "' "
				cQuery	+= 			" AND FOD.FOD_FILSCP IN ( ? ) "
				cQuery	+= 			" AND FOD.FOD_INIVIG <> ' ' "
				cQuery	+= 			" AND FOD.D_E_L_E_T_ = ' ' "
				cQuery	+= " ORDER BY FOD.FOD_FILIAL, FOD.FOD_FILSCP, FOD.FOD_FILSOC "

				cQuery := ChangeQuery( cQuery )
				__oSttFOD := FWPreparedStatement():New( cQuery )
			EndIf

			__oSttFOD:SetString( 1, xFilial("SA2", cFilAnt)	)
			__oSttFOD:SetIn( 2, aFilSCP )

			cQuery := __oSttFOD:GetFixQuery()
			cAliasFOD := MpSysOpenQuery(cQuery)

			While (cAliasFOD)->( !EOF() )

				If cFilSCP != (cAliasFOD)->(FOD_FILIAL + FOD_FILSCP)
					cFilSCP := (cAliasFOD)->(FOD_FILIAL + FOD_FILSCP)
					cDtIni  := (cAliasFOD)->FOD_INIVIG //formato mm/aaaa
					cDtIni  := Substr(cDtIni,4,4)+Substr(cDtIni,1,2) //conv formato AAAA-MM
					IF !Empty((cAliasFOD)->FOD_FIMVIG)
						cDtFim  := (cAliasFOD)->FOD_FIMVIG //formato mm/aaaa
						cDtFim  := Substr(cDtFim,4,4)+Substr(cDtFim,1,2) //conv formato AAAA-MM
					Endif
					//Gera T159 - Cadastro da SCP
					Aadd( aRegT159A, {  "T159",; 				// 1- REGISTRO - Registro T159
									(cAliasFOD)->FOD_CGCSCP,;	// 2- CNPJ - CNPJ da Sociedade em Conta de Participa��o
									"",;						// 3- NOME - Nome da Sociedade em Conta de Participa��o
									cDtIni,;					// 4- INIVALID - Data Inicio entidade ligada (formato AAAA-MM)
									cDtFim,;					// 5- FIMVALID - Data Fim entidade ligada (formato AAAA-MM)
									"4" })						// 6- TPENTLIG - Classifica��o da entidade ligada

					aAdd(__aT159Env, {xFilial("FOD"), FOD->FOD_FILSCP})
					
				Endif

				//T159AA - Bloco dos participantes da SCP
				While (cAliasFOD)->( !EOF() ) .and. cFilSCP == (cAliasFOD)->(FOD_FILIAL + FOD_FILSCP)

					Aadd( aRegT159A, {  "T159AA",; 					// 1 Registro T159
										RetPartTAF("FOR", (cAliasFOD)->A2_COD, (cAliasFOD)->A2_LOJA),;	// 2 C�digo do participante
										(cAliasFOD)->FOD_PERCEN })		// 3 % Participa��o

					(cAliasFOD)->(dbSkip())
				EndDo
			EndDo
			If Select(cAliasFOD) > 0
				(cAliasFOD)->(dbCloseArea() )
			Endif
		EndIf
	EndIf

Return lRet

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TrataAcao
Fun��o para tratar o c�digo de tipo de a��o do Protheus e devolver o c�digo de tipo de a��o da REINF 

@author pedro.alencar
@since 18/10/2019
@version 1.0
@type function

@param cTpAtrb, Char, Tipo de a��o no Protheus 
@param cFiltro, char, Filtro para o qual as a��es ser�o verificadas ("DEDUCAO" ou "ISENCAO")
@return cRet, Indica o tipo de a��o para dedu��o ou isen��o, conforme o esperado pela REINF
/*/
//-----------------------------------------------------------------------------------------------
Static Function TrataAcao( cTpAtrb As Char, cFiltro As Char ) As Char

	Local cRet As Char

	Default cTpAtrb := ""
	Default cFiltro := ""
	
	cRet := ""
	
	If cFiltro == "DEDUCAO"
	
		If cTpAtrb == "010" //PREVID�NCIA PRIVADA
			cRet := "2"
		ElseIf cTpAtrb == "011" //FAPI
			cRet := "3"
		ElseIf cTpAtrb == "012" //FUNPRESP
			cRet := "4"
		ElseIf cTpAtrb == "013" //PENS�O ALIMENT�CIA
			cRet := "5"
		ElseIf cTpAtrb == "024" //DEPENDENTES
			cRet := "7"
		EndIf
	
	ElseIf cFiltro == "ISENCAO"
	
		If cTpAtrb == "006" //OUTROS
			cRet := "99"
		ElseIf cTpAtrb == "015" //PARCELA ISENTA 65 ANOS
			cRet := "1"
		ElseIf cTpAtrb == "016" //DI�RIA DE VIAGEM
			cRet := "2"
		ElseIf cTpAtrb == "017" //INDENIZA��O E RESCIS�O DE CONTRATO, INCLUSIVE A T�TULO
			cRet := "3"
		ElseIf cTpAtrb == "018" //ABONO PECUNI�RIO
			cRet := "4"
		ElseIf cTpAtrb == "019" //VALORES PAGOS A TITULAR OU S�CIO DE MICROEMPRESA OU EMP
			cRet := "5"
		ElseIf cTpAtrb == "020" //PENS�O, APOSENTADORIA OU REFORMA POR MOL�STIA GRAVE OU
			cRet := "6"
		ElseIf cTpAtrb == "021" //COMPLEMENTA��O DE APOSENTADORIA, CORRESPONDENTE �S CONT 
			cRet := "7"
		ElseIf cTpAtrb == "022" //AJUDA DE CUSTO
			cRet := "8"
		ElseIf cTpAtrb == "023" //RENDIMENTOS PAGOS S/ RETEN��O DO IR - LEI 10.833/2003  
			cRet := "9"
		EndIf
	
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MntQryAdt
Fun��o para verificar se o PA deve ser considerado na extra��o, nas
seguintes situa��es:
	- PA possui TX gerado para o imposto
	- PA possui suspencao judicial para o imposto

@param	cAliasBx - Alias da tabela temporaria
@return nil

@author Fabio Casagrande Lima
@since 15/10/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function MntQryAdt(cAliasBx As Character)

	Local aCpoNum    As Array
	Local aTamSX3Cpo As Array
	Local cQuery     As Character
	Local nLoop      As Numeric

	Default cAliasBx := GetNextAlias()
	
	nLoop	   := 1
	aTamSX3Cpo := {}
	aCpoNum	   := {{'VALOR',"E2_VLCRUZ"},{'VALIRF',"E2_IRRF"},{'BASIRF',"E2_BASEIRF"}}

	//Busca a movimenta��o para o titulo PA
	If __oQryPA == Nil	
		cQuery := " SELECT SE2.E2_FILIAL FILIAL,FK7.FK7_IDDOC IDMOV, FK7.FK7_IDDOC IDDOC, SE5.E5_DATA DATAFG, 
		cQuery += " 0 SEQ, SE2.E2_VLCRUZ VALOR, ISNULL(SE2.E2_IRRF,0) VALIRF, ISNULL(SE2.E2_BASEIRF,0) BASIRF, "
		cQuery += 			" ' ' AS CPF, 0 SEQMAX " 	
		//Obs: Caso mudar alguma coluna da estrutura do SELECT acima, replicar tamb�m nas querys das fun��es MntQry158a e MntQry158b
		
		cQuery += " FROM " + RetSqlName("SE2") + " SE2 "
		cQuery += " INNER JOIN "
		cQuery += "   " + RetSqlName("SA2") + " SA2 "
		cQuery += "   ON (SA2.A2_FILIAL = '" + xFilial("SA2") + "'" 
		cQuery += "   AND SA2.A2_COD = SE2.E2_FORNECE "
		cQuery += "   AND SA2.A2_LOJA = SE2.E2_LOJA "
		cQuery += "   AND SA2.D_E_L_E_T_ = ' ' ) "
		cQuery += " INNER JOIN "
		cQuery += "   " + RetSqlName("SED") + " SED "
		cQuery += "   ON ( SED.ED_FILIAL = '" + xFilial("SED") + "'" 
		cQuery += "   AND SED.ED_CODIGO = SE2.E2_NATUREZ "
		cQuery += "   AND SED.D_E_L_E_T_ = ' ' ) "
		cQuery += " INNER JOIN "
		cQuery += "   " + RetSqlName("FK7") + " FK7 "
		cQuery += "   ON ( FK7.FK7_FILIAL = '" + xFilial("FK7") + "'"
		cQuery += "   AND FK7.FK7_ALIAS = 'SE2' AND "

		If __lFK7Cpos
			cQuery += " FK7.FK7_FILTIT = SE2.E2_FILIAL "
			cQuery += " AND FK7.FK7_PREFIX = SE2.E2_PREFIXO "
			cQuery += " AND FK7.FK7_NUM = SE2.E2_NUM "	 		
			cQuery += " AND FK7.FK7_PARCEL = SE2.E2_PARCELA "	
			cQuery += " AND FK7.FK7_TIPO = SE2.E2_TIPO "		
			cQuery += " AND FK7.FK7_CLIFOR = SE2.E2_FORNECE "	
			cQuery += " AND FK7.FK7_LOJA = SE2.E2_LOJA "			
		Else
			cQuery += "   FK7.FK7_CHAVE = "
			If cBDname $ "MYSQL|POSTGRES"
				cQuery += "CONCAT( "
			EndIf
			cQuery += " SE2.E2_FILIAL "  + cConcat + " '|' " + cConcat
			cQuery += " SE2.E2_PREFIXO " + cConcat + " '|' " + cConcat
			cQuery += " SE2.E2_NUM "	  + cConcat + " '|' " + cConcat
			cQuery += " SE2.E2_PARCELA " + cConcat + " '|' " + cConcat
			cQuery += " SE2.E2_TIPO "	  + cConcat + " '|' " + cConcat
			cQuery += " SE2.E2_FORNECE " + cConcat + " '|' " + cConcat
			cQuery += " SE2.E2_LOJA "
			If cBDname $ "MYSQL|POSTGRES"
				cQuery += ") "
			EndIf
		Endif

		cQuery += "   AND FK7.FK7_IDDOC = ? "
		cQuery += "   AND FK7.D_E_L_E_T_ = ' ' )"
		cQuery += " INNER JOIN "
		cQuery += "   " + RetSqlName("FKF") + " FKF "
		cQuery += "   ON ( FKF.FKF_FILIAL = ? " 
		cQuery += "   AND FKF.FKF_IDDOC = FK7.FK7_IDDOC "
		cQuery += "   AND FKF.D_E_L_E_T_ = ' ' ) "
		cQuery += " INNER JOIN "
		cQuery += "   " + RetSqlName("SE5") + " SE5 "
		cQuery += "   ON E5_FILIAL = ? AND E2_PREFIXO = E5_PREFIXO AND E2_NUM = E5_NUMERO AND E2_PARCELA = E5_PARCELA "
		cQuery += "	  AND E2_TIPO = E5_TIPO AND E2_FORNECE = E5_FORNECE AND E2_LOJA = E5_LOJA AND SE5.D_E_L_E_T_ = ' ' "
		cQuery += "	  AND E5_RECPAG = 'P' AND E5_MOTBX NOT IN ('CMP') AND E5_SITUACA NOT IN ('C','E','X') "
		cQuery += "	  AND E5_DATA >= ? AND E5_DATA <= ? "
		cQuery += " WHERE SE2.D_E_L_E_T_ = ' ' AND SE2.E2_TIPO = 'PA' "
		cQuery += "   AND SE2.E2_FILORIG = ? "	
		If __lVerFlag
			cQuery += "   AND FKF.FKF_REINF IN ('2',' ') "
		Endif
		cQuery += "   AND FKF.FKF_NATREN != ' ' "

		cQuery := ChangeQuery( cQuery )
        If __lCachQry
            __oQryPA := FwExecStatement():New(cQuery)
        Else
            __oQryPA := FWPreparedStatement():New(cQuery)
        EndIf   
	Endif

	__oQryPA:SetString(1, (cAliasQry)->FK7_IDDOC)
	__oQryPA:SetString(2, xFilial("FKF"))
	__oQryPA:SetString(3, xFilial("SE5"))
	__oQryPA:SetString(4, Dtos(dDataPgDe))
	__oQryPA:SetString(5, Dtos(dDataPgAte))
	__oQryPA:SetString(6, cFilAnt)

	cQuery 	 := __oQryPA:GetFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasBx,.F.,.F.)

	For nLoop := 1 To Len( aCpoNum )
		aTamSX3Cpo := TamSX3(aCpoNum[nLoop][2])
		TcSetField( cAliasBx, aCpoNum[nLoop][1], "N",aTamSX3Cpo[1],aTamSX3Cpo[2])
	Next nLoop 	

	FwFreeArray(aCpoNum)
	FwFreeArray(aTamSX3Cpo)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MntQry158a
Busca dados das baixas quando o PCC na emissao (MV_BX10925=2)		

@param	cAliasBx - Alias da tabela temporaria
@return nil

@author Fabio Casagrande Lima
@since 15/10/2019
@version P12
/*/
//-------------------------------------------------------------------

Static Function MntQry158a(cAliasBx As Character)

	Local aCpoNum    As Array
	Local aTamSX3Cpo As Array
	Local cQuery     As Character
	Local nLoop      As Numeric

	Default cAliasBx := GetNextAlias()

	nLoop	   := 1
	aTamSX3Cpo := {}
	aCpoNum	   := {{'VALOR',"FK2_VALOR"},{'VALIRF',"FK4_VALOR"},{'BASIRF',"FK4_BASIMP"}}

	//Busca os pagamentos dos titulo
	If __oQry158a == Nil	
		cQuery := " SELECT	FK2.FK2_FILIAL FILIAL, FK2.FK2_IDFK2 IDMOV, FK2.FK2_IDDOC IDDOC, FK2.FK2_DATA DATAFG, FK2.FK2_SEQ SEQ, FK2.FK2_VALOR VALOR, "
		//Obs: Caso mudar alguma coluna da estrutura do SELECT acima, replicar tamb�m nas querys das fun��es MntQry158b e MntQryAdt

		cQuery += 			" (	SELECT	ISNULL(SUM(FK4IRF.FK4_VALOR), 0) FK4_VALOR "
		cQuery += 				" FROM	" + RetSqlName("FK4") + " FK4IRF "
		cQuery += 				" WHERE	FK4IRF.FK4_FILIAL = FK2.FK2_FILIAL "
		cQuery += 					" AND FK4IRF.FK4_IDORIG = FK2.FK2_IDFK2 "
		cQuery += 					" AND FK4IRF.FK4_RECPAG = 'P' "
		cQuery += 					" AND FK4IRF.FK4_IMPOS = 'IRF' "
		cQuery += 					" AND FK4IRF.D_E_L_E_T_ = ' ' ) VALIRF, "

		cQuery += 			" 0 BASIRF, "
		
		If __lTemFKJ
			cQuery += 			" ISNULL(FKJ.FKJ_CPF,' ') CPF, "
		Else
			cQuery += 			" ' ' CPF, "
		EndIf

		cQuery += 			" (	SELECT	MAX(A.FK2_SEQ) SEQMAX "
		cQuery += 				" FROM	" + RetSqlName("FK2") + " A "
		cQuery += 				" WHERE	A.FK2_FILIAL = FK2.FK2_FILIAL "
		cQuery += 						" AND A.FK2_RECPAG = 'P' "
		cQuery += 						" AND A.FK2_IDDOC = FK2.FK2_IDDOC "
		cQuery += 						" AND A.D_E_L_E_T_ = ' '  ) SEQMAX "

		cQuery += " FROM " + RetSqlName("FK2") + " FK2 "

		If __lTemFKJ
			cQuery += " LEFT JOIN " + RetSqlName("FKJ") + " FKJ ON "
			cQuery += 		" ( FKJ.FKJ_FILIAL = '" + xFilial("FKJ") + "' "
			cQuery += 		" AND FKJ.FKJ_COD = '" + (cAliasQry)->COD + "' "
			cQuery += 		" AND FKJ.FKJ_LOJA = '" + (cAliasQry)->LOJA + "' "
			cQuery += 		" AND FKJ.D_E_L_E_T_ = ' ' ) "
		EndIf

		cQuery += " WHERE FK2.FK2_FILIAL = ? "
		cQuery += 			" AND FK2.FK2_FILORI = ? " 
		cQuery += 			" AND FK2.FK2_DATA >= ? AND FK2.FK2_DATA <= ? "
		cQuery += 			" AND FK2.FK2_RECPAG = 'P' "
		cQuery += 			" AND FK2.FK2_TPDOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE','E2','CH','ES') "
		cQuery += 			" AND FK2.FK2_IDDOC = ? "
		If __lVerFlag
			cQuery +=			" AND FK2.FK2_REINF IN ('2',' ') "
		Endif
		cQuery += 			" AND NOT EXISTS (	SELECT A.FK2_IDDOC "
		cQuery += 								" FROM	" + RetSqlName("FK2") + " A "
		cQuery += 								" WHERE	A.FK2_FILIAL = FK2.FK2_FILIAL AND "
		cQuery += 								" A.FK2_IDDOC = FK2.FK2_IDDOC AND "
		cQuery += 								" A.FK2_SEQ = FK2.FK2_SEQ AND "
		cQuery += 								" A.FK2_TPDOC = 'ES' ) "
		cQuery += 			" AND FK2.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery( cQuery )

        If __lCachQry
            __oQry158a := FwExecStatement():New(cQuery)
        Else
            __oQry158a := FWPreparedStatement():New(cQuery)
        EndIf     
	EndIf

	__oQry158a:SetString(1, xFilial("FK2"))
	__oQry158a:SetString(2, cFilAnt)
	__oQry158a:SetString(3, Dtos(dDataPgDe))
	__oQry158a:SetString(4, Dtos(dDataPgAte))
	__oQry158a:SetString(5, (cAliasQry)->FK7_IDDOC)

	cQuery := __oQry158a:GetFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasBx,.F.,.F.)

	For nLoop := 1 To Len( aCpoNum )
		aTamSX3Cpo := TamSX3(aCpoNum[nLoop][2])
		TcSetField( cAliasBx, aCpoNum[nLoop][1], "N",aTamSX3Cpo[1],aTamSX3Cpo[2])
	Next nLoop 	

	FwFreeArray(aCpoNum)
	FwFreeArray(aTamSX3Cpo)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MntQry158b
Busca dados das baixas dos titulos a pagar

@param	cAliasBx - Alias da tabela temporaria
@return Nil	- Retorna .T. para final de execu��o

@author Fabio Casagrande Lima
@since 15/10/2019
@version P12
/*/
//-------------------------------------------------------------------

Static Function MntQry158b(cAliasBx As Character)

	Local aCpoNum    As Array
	Local aTamSX3Cpo As Array
	Local cQuery     As Character
	Local nLoop      As Numeric

	Default cAliasBx := GetNextAlias()

	nLoop	   := 1
	aTamSX3Cpo := {}
	aCpoNum	   := {{'VALOR',"FK2_VALOR"},{'VALIRF',"FK4_VALOR"},{'BASIRF',"FK4_BASIMP"}}

	//Busca os pagamentos dos titulo
	If __oQry158b == Nil	
		cQuery := " SELECT	FK2.FK2_FILIAL FILIAL, FK2.FK2_IDFK2 IDMOV, FK2.FK2_IDDOC IDDOC, FK2.FK2_DATA DATAFG, FK2.FK2_SEQ SEQ, FK2.FK2_VALOR VALOR, "
		cQuery += 			" ISNULL(FK4IRF.FK4_VALOR,0) VALIRF, ISNULL(FK4IRF.FK4_BASIMP,0) BASIRF, "
		cQuery += 			" ISNULL(FK4IRF.FK4_CGC,' ') CPF, "
		cQuery += 			" (	SELECT	MAX(A.FK2_SEQ) SEQMAX "
		cQuery += 				" FROM	" + RetSqlName("FK2") + " A "
		cQuery += 				" WHERE	A.FK2_FILIAL = FK2.FK2_FILIAL "
		cQuery += 						" AND A.FK2_RECPAG = 'P' "
		cQuery += 						" AND A.FK2_IDDOC = FK2.FK2_IDDOC "
		cQuery += 						" AND A.D_E_L_E_T_ = ' '  ) SEQMAX "
		//Obs: Caso mudar alguma coluna da estrutura do SELECT acima, replicar tamb�m nas querys das fun��es MntQry158a e MntQryAdt

		cQuery += " FROM " + RetSqlName("FK2") + " FK2 "
		cQuery += " LEFT JOIN " + RetSqlName("FK4") + " FK4IRF ON ( FK4IRF.FK4_FILIAL = FK2.FK2_FILIAL "
		cQuery += 													" AND FK4IRF.FK4_IDORIG = FK2.FK2_IDFK2 "
		cQuery += 													" AND FK4IRF.FK4_RECPAG = 'P' "
		cQuery += 													" AND FK4IRF.FK4_IMPOS = 'IRF' "
		cQuery += 													" AND FK4IRF.D_E_L_E_T_ = ' ' ) "

		cQuery += " WHERE FK2.FK2_FILIAL = ? "
		cQuery += 			" AND FK2.FK2_FILORI = ? " 
		cQuery += 			" AND FK2.FK2_DATA >= ? AND FK2.FK2_DATA <= ? "
		cQuery += 			" AND FK2.FK2_RECPAG = 'P' "
		cQuery += 			" AND FK2.FK2_TPDOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE','E2','CH','ES') "
		cQuery += 			" AND FK2.FK2_IDDOC = ? "
		If __lVerFlag
			cQuery +=			" AND FK2.FK2_REINF IN ('2',' ') "
		Endif
		cQuery += 			" AND FK2.FK2_MOTBX NOT IN ( 'FAT', 'LIQ', 'DEV' ) "
		cQuery += 			" AND NOT EXISTS (	SELECT A.FK2_IDDOC "
		cQuery += 								" FROM	" + RetSqlName("FK2") + " A "
		cQuery += 								" WHERE	A.FK2_FILIAL = FK2.FK2_FILIAL AND "
		cQuery += 								" A.FK2_IDDOC = FK2.FK2_IDDOC AND "
		cQuery += 								" A.FK2_SEQ = FK2.FK2_SEQ AND "
		cQuery += 								" A.FK2_TPDOC = 'ES' ) "
		cQuery += 			" AND FK2.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery( cQuery )

        If __lCachQry
            __oQry158b := FwExecStatement():New(cQuery)
        Else
            __oQry158b := FWPreparedStatement():New(cQuery)
        EndIf   
	EndIf

	__oQry158b:SetString(1, xFilial("FK2"))
	__oQry158b:SetString(2, cFilAnt)
	__oQry158b:SetString(3, Dtos(dDataPgDe))
	__oQry158b:SetString(4, Dtos(dDataPgAte))
	__oQry158b:SetString(5, (cAliasQry)->FK7_IDDOC)

	cQuery := __oQry158b:GetFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasBx,.F.,.F.)

	For nLoop := 1 To Len( aCpoNum )
		aTamSX3Cpo := TamSX3(aCpoNum[nLoop][2])
		TcSetField( cAliasBx, aCpoNum[nLoop][1], "N",aTamSX3Cpo[1],aTamSX3Cpo[2])
	Next nLoop 	

	FwFreeArray(aCpoNum)
	FwFreeArray(aTamSX3Cpo)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FFinT162
Gera os registros para o layout do TAF T162 e T162AA para atender o evento R-4080.
Envia:
	- T162: Titulos a receber com auto-retencao de IRRF
	- T162AA: Processos relacionados a nao retencao da auto-retencao de IRRF

@param cAliasQry, caracter, Alias da tabela temporaria contendo os titulos a receber j� filtrados

@return lRet Retorna .T. para final de execu��o

@author Fabio Casagrande Lima
@since 20/12/2022
/*/
//-------------------------------------------------------------------
Function FFinT162(cAliasQry As Character) As Logical

	Local cPrefixo  As Character
	Local cParcela  As Character
	Local cNumTit   As Character
	Local cCodPart  As Character
	Local cHist     As Character
	Local cReg 		As Character
	Local dDtEmis   As Date
	Local nVlSusp   As Numeric
	Local nVlDepos  As Numeric
	Local nVlBruto  As Numeric
	Local nRenTrib  As Numeric
	Local nValTrib  As Numeric
	Local lRet 		As Logical
	Local aRegs 	As Array

	cPrefixo := (cAliasQry)->E1_PREFIXO
	cParcela := padr(Alltrim((cAliasQry)->E1_PARCELA), nTamE1Par)
	cCodPart := RetPartTAF("CLI", (cAliasQry)->COD, (cAliasQry)->LOJA)
	cHist	 := (cAliasQry)->E1_HIST
	lRet 	 := .T.
	aRegs    := {}
	cReg     := ""
	nVlSusp  := 0
	nVlDepos := 0

	If !Empty(cParcela)
		cNumTit  := Alltrim((cAliasQry)->E1_NUM) + "-" + cParcela
	Else
		cNumTit  := Alltrim((cAliasQry)->E1_NUM)
	Endif
	
	If nTpEmData == 1
		dDtEmis  := (cAliasQry)->E1_EMIS1
	Else 
		dDtEmis  := (cAliasQry)->E1_EMISSAO
	Endif

	FKW->( DBSetOrder(2) ) //FKW_FILIAL + FKW_IDDOC + FKW_TPIMP + FKW_NATREN
	FKW->(DbGotop())	
	If FKW->( MsSeek( xFilial("FKW") + (cAliasQry)->FK7_IDDOC + "2" ) )
		While FKW->(!Eof()) .and. Alltrim(FKW->(FKW_FILIAL+FKW_IDDOC+FKW_CARTEI)) == Alltrim(xFilial("FKW") + (cAliasQry)->FK7_IDDOC + "2" )	

			FWFreeArray(aRegs)
			aRegs 	 := {}
			cReg     := "T162"
			nVlBruto := FKW->(FKW_BASETR+FKW->FKW_BASENR)
			nRenTrib := nVlBruto
			nValTrib := FKW->(FKW_VLIMP+FKW->FKW_VLIMPN)

			Aadd( aRegs, {  ;
				cReg,; 					//01-TIPO REGISTRO
				cPrefixo+cNumTit,;		//02-C�DIGO_DOCUMENTO
				FKW->FKW_NATREN,; 		//03-NATUREZA_DO_RENDIMENTO
				dDtEmis ,; 				//04-DT_PAGAMENTO
				0,; 					//05-VLR_LIQ
				nVlBruto,;				//06-VLR_REAJUSTADO
				nValTrib,; 				//07-VLR_IR
				Alltrim(cHist),;		//08-DESCRI��O
				nRenTrib,; 				//09-BASE_IR
				"1",; 					//10-NATUREZ
				cCodPart })				//11-COD_PARTICIPANTE
			
			FConcTxt( aRegs, nHdlTxt)

			If !Empty(FKW->FKW_NUMPRO) //Verifica se ha processo de suspensao da retencao

				FWFreeArray(aRegs)
				aRegs 	 := {}
				cReg  	 := "T162AA" //Processos relacionados a n�o reten��o de tributos
				nVlSusp  := FKW->FKW_VLIMPN
				nVlDepos := 0

				//Verifica no cadastro do processos referenciado foi indicado o deposito judicial
				DBSelectArea("CCF")
				CCF->(DBSetOrder(1)) // CCF_FILIAL, CCF_NUMERO, CCF_TIPO	
				CCF->( MsSeek( xFilial("CCF") + PadR( FKW->FKW_NUMPRO, nTamCCFNum ) +  FKW->FKW_TPPROC ) )
				While CCF->( !Eof() ) .AND. CCF->( CCF_FILIAL + CCF_NUMERO + CCF_TIPO ) == xFilial("FKW") + FKW->( FKW_NUMPRO + FKW_TPPROC )					
					If CCF->CCF_TRIB == '9' // Verifica se eh IRRF		
						If CCF->CCF_MONINT == "1" 
							nVlSusp  := 0
							nVlDepos := FKW->FKW_VLIMPN
						Endif
					Endif
					CCF->( DbSkip() )
				EndDo
		
				Aadd( aRegs, {  ;
				cReg,; 					//01-TIPO REGISTRO
				FKW->FKW_TPPROC,;		//02-TP_PROC
				FKW->FKW_NUMPRO,; 		//03-NUM_PROC
				FKW->FKW_CODSUS, ; 		//04-COD_SUS
				FKW->FKW_BASENR,; 		//05-BASE_SUSPENSA
				nVlSusp,;				//06-VAL_SUS
				nVlDepos,; 				//07-VAL_DEPOSITO_IR
				})
				
				FConcTxt( aRegs, nHdlTxt)
			EndIf
			
			__lGer162 := .T.

			FKW->( DbSkip() )
		EndDo
		//Grava o flag de envio ao TAF quando a integracao for banco-a-banco
		IF __lVerFlag
			//Grava flag dos dados de recebimentos com IR auto retido T162 (FKF_REINF)
			AAdd( __aFK7Id, { (cAliasQry)->FKF_FILIAL, (cAliasQry)->FK7_IDDOC } )
		EndIf
	EndIf

	If cTpSaida == "2" .AND. Len(aDadosST1) > 0 //Grava o registro na TABELA TAFST2 e limpa o array aDadosST1.
		FConcST1()
	EndIf	

	FWFreeArray(aRegs)

Return lRet

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} VlDedDep
Fun��o para retornar o valor da deducao da base do IRPF pelo numero total de dependentes

@param dData  , Date, Data do fato gerador do IRPF
@param nQtdDep, Numeric, Quantidade de depenentes do fornecedor (A2_NUMDEP)
@param cFornec, Character, C�digo + Loja do fornecedor posicionado
@param lDetDed, Logical, .T. para qdo a verifica��o � do registro
	de detalh. dependentes
@param cIdDoc, Character, ID do t�tulo

@return nVrRet, Numeric, valor da deducao de dependentes da base do IRPF 

@author fabio.casagrande
@since 27/12/2022
/*/
//-----------------------------------------------------------------------------------------------
Static Function VlDedDep(dData As Date, nQtdDep As Numeric, cFornec As Char, lDetDed As Logical, cIdDoc As Char) As Numeric

	Local nVrRet As Numeric
	Local nVrDep As Numeric 
	Local cMes	 As Character
	Local cAno	 As Character

	Default dData 	:= CTOD("  /  /    ")
	Default nQtdDep := 0
	Default cFornec	:= ""
	Default lDetDed	:= .F.
	Default cIdDoc	:= ""
	
	If !Empty(dData)
		cMes := STRZERO(MONTH(dData),2)
		cAno := STRZERO(YEAR(dData),4)
	EndIf

	nVrDep := F992RetVal(cMes, cAno) //Retorna valor de deducao por depende (via tabela FKI ou MV_TMSVDEP)
	nVrRet := 0

	If nVrDep > 0 .And. FFrstTime(cFornec, dData, lDetDed, cIdDoc)
		nVrRet := nVrDep * nQtdDep
	EndIf

Return nVrRet

//-------------------------------------------------------------------------
/*/{Protheus.doc} FTemFKW
Verifica se o titulo possui registro(s) na tabela FKW, que � pr�-condi��o 
para enviar os dados da emissao do titulo para o TAF (REINF 2.1.1)

@param cIdTit, Character, Chave do titulo (FK7_IDDOC)

@return lRet, logical, retorna .T. se encontrar registros do titulo na FKW

@author Fabio Casagrande Lima
@since  29/12/2022
/*/
//-------------------------------------------------------------------------
Static Function FTemFKW(cIdTit) As Logical
    Local lRet      As Logical
    Local cQuery    As Character
    Local cIdFkw    As Character

    Default cIdTit := ""

    lRet    := .F.
    cQuery  := ""

    If __oQryFKW == NIL
        cQuery := "SELECT FKW_IDFKW IDFKW "
        cQuery += "FROM "+RetSqlName("FKW")+" "
        cQuery += "WHERE FKW_IDDOC = ? "
        cQuery += "AND D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)

        If __lCachQry
            __oQryFKW := FwExecStatement():New(cQuery)
        Else
            __oQryFKW := FWPreparedStatement():New(cQuery)
        EndIf   
    Endif
    
    __oQryFKW:SetString(1, cIdTit)
    cQuery := __oQryFKW:GetFixQuery()

    cIdFkw := MpSysExecScalar(cQuery,"IDFKW")

    If !Empty(cIdFkw)
        lRet := .T.
    Endif

Return lRet

//-------------------------------------------------------------------------
/*/{Protheus.doc} FTemFKY
Verifica se o titulo possui registro(s) na tabela FKY, que � pr�-condi��o 
para enviar os dados da baixa do titulo para o TAF (REINF 2.1.1)

@param cIdTit, Character, Chave do titulo (FK7_IDDOC)

@return lRet, logical, retorna .T. se encontrar registros do titulo na FKY

@author Fabio Casagrande Lima
@since  05/01/2023
/*/
//-------------------------------------------------------------------------
Static Function FTemFKY(cIdTit) As Logical
    Local lRet      As Logical
    Local cQuery    As Character
    Local cIdFky    As Character

    Default cIdTit := ""

    lRet    := .F.
    cQuery  := ""

    If __oQryBx3 == NIL
        cQuery := "SELECT FKY_IDFKY IDFKY "
        cQuery += "FROM "+RetSqlName("FKY")+" "
        cQuery += "WHERE FKY_IDDOC = ? "
        cQuery += "AND D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)

        If __lCachQry
            __oQryBx3 := FwExecStatement():New(cQuery)
        Else
            __oQryBx3 := FWPreparedStatement():New(cQuery)
        EndIf   
    Endif
    
    __oQryBx3:SetString(1, cIdTit)
    cQuery := __oQryBx3:GetFixQuery()

    cIdFky := MpSysExecScalar(cQuery,"IDFKY")

    If !Empty(cIdFky)
        lRet := .T.
    Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FKWSusp
Fun��o para verificar se h� suspen��o da reten��o por processo 
judicial/administrativo para o tributo com natureza(s) de rendimento
e com fato gerador na emiss�o.

@param cIdDoc	- ID do titulo (ref. FK7_IDDOC)
@param aT154AF	- Array com os dados de suspensao da retencao

@return lRet    - Retorna .T. se encontrou suspencoes

@author fabio.casagrande
@since 29/12/2022
/*/
//-------------------------------------------------------------------
Static Function FKWSusp(cIdDoc As Char, aT154AF As Array) As Logical

	Local cImpIR  As Character
	Local lRet	  As Logical

	Default cIdDoc		:= ""
	Default aT154AF 	:= {}

	cImpIR	:= PadR( 'IRF', __nFkwImp )
	lRet	:= .F.

	DbSelectArea("FKW")
	FKW->(DBSetOrder(2)) //FKW_FILIAL, FKW_IDDOC, FKW_CARTEI, FKW_NATREN, FKW_TPIMP
	FKW->(DbGotop())	
	FKW->(MsSeek( xFilial("FKW") + cIdDoc + "1"))

	While FKW->( !Eof() ) .and. FKW->FKW_IDDOC == cIdDoc .and. FKW->FKW_CARTEI == "1"
				
		//Verifica se tem suspens�o por processo judicial/administrativo
		If FKW->FKW_TPIMP == cImpIR .and. !Empty(FKW->FKW_NUMPRO)
			lRet := .T.
			AAdd( aT154AF, {	'12',;  			//01 - TRIBUTO - codigo que corresponde o tributo no layout TAF
								FKW->FKW_NUMPRO,;	//02 - NUM_PROC - Identifica��o do processo ou ato concess�rio
								FKW->FKW_TPPROC,;	//03 - IND_PROC - Indicador da origem do processo (0 - SEFAZ; 1 - Justi�a Federal; 2 - Justi�a Estadual; 3 � Secretaria da Receita Federal do Brasil; 9 � Outros)
								FKW->FKW_CODSUS,;	//04 - COD_SUS - C�digo do Indicativo da Suspens�o
								FKW->FKW_VLIMPN,;	//05 - VAL_SUS - Valor da reten��o que deixou de ser efetuada em fun��o de processo adm/judicial
								FKW->FKW_NATREN,;	//06 - NATUREZA_RENDIMENTO - C�digo da natureza de rendimento
								FKW->FKW_BASENR })	//07 - BASE_SUSPENSA - Valor da base de c�lculo do tributo com exigibilidade suspensa
		Endif

		FKW->( DbSkip() )
	EndDo

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FIrrfFKW
Verifica se h� reten��o/suspen��o/isen��o/dedu��o para o IRF com o 
fato gerador na emiss�o e vinculado com natureza(s) de rendimento.
Atribui dados para o array "aT154Tbb", responsavel por gerar os dados
para os registros T154AG e T154AH.

@param	cAliasQry - Alias do titulo
@param	aT154Trb  - Array com os dados do IRRF
@param	lFornPF   - Informa .T. se o fornecedor do titulo � pessoa fisica
@param	dDtEmis   - Data emissao do titulo
@param  lIsento   - Informa .T. se o titulo tem isencao de IRPF
@param  lOrigNF   - Informa .T. se o titulo � de Documento de Entrada
@param  lSusp     - Informa .T. se o t�tulo tem suspen��o de IR

@return lRet - Retorna .T. se encontrou reten��es

@author fabio.casagrande
@since 13/01/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function FIrrfFKW(cAliasQry, aT154Trb, lFornPF, dDtEmis, lIsento, lOrigNF, lSusp) 

	Local cAliasNF As Character
	Local cAlsFkw  As Character
	Local cQry1    As Character
	Local cQry2    As Character
	Local lRet	   As Logical
	Local nDedDep  As Numeric
	Local nRenBrut As Numeric
	Local nRenTrib As Numeric
	Local nValTrib As Numeric
	Local nQtdDep  As Numeric
	Local aIdDoc   As Array

	Default cAliasQry := ""
	Default aT154Trb  := {}
	Default lFornPF   := .F.
	Default dDtEmis   := CTOD("  /  /    ")
	Default lIsento   := .F.
	Default lOrigNF   := .F.
	Default lSusp     := .F.

	lRet	 := .F.
	nDedDep  := 0
	nRenBrut := 0
	nRenTrib := 0
	nValTrib := 0
	cAliasNF := ""
	cQry1    := ""    
	cQry2    := ""   
	aIdDoc   := { (cAliasQry)->FK7_IDDOC }

	If __lRatIrf .and. lOrigNF
		/*--------------------------------------------------------------------------------------------|
		| Se o titulo � de Doc. Entrada e gerou livro fiscal (SFT), o extrator gera um unico T154 p/  |
		| a NF, independente da quantidade de parcelas. Com isso, se a NF possui o IR rateado entre   |
		| as parcelas (MV_RATIRRF=T), o trecho abaixo ir� aglutinar/somaro IR para gerar corretamente |
		---------------------------------------------------------------------------------------------*/	
		aIdDoc := {}
		If __oQryFK7 == Nil 
			cQry1 := "SELECT ISNULL(FK7_IDDOC, '') FK7_IDDOC "
			cQry1 += "FROM " + RetSqlName("FK7") + " FK7 "
			cQry1 += "WHERE FK7.D_E_L_E_T_ = ' ' AND  "
			cQry1 += 		"FK7_FILIAL = ? AND "
			cQry1 += 		"FK7_ALIAS = ? AND "
			cQry1 += 		"FK7_CLIFOR = ? AND "
			cQry1 += 		"FK7_LOJA = ? AND "
			cQry1 += 		"FK7_PREFIX = ? AND "		
			cQry1 += 		"FK7_NUM = ? AND "	
			cQry1 += 		"FK7_TIPO = ? "	
			cQry1 := ChangeQuery(cQry1)
			If __lCachQry
				__oQryFK7 := FwExecStatement():New(cQry1)
			Else
				__oQryFK7 := FWPreparedStatement():New(cQry1)
			EndIf   
		Endif
		__oQryFK7:SetString(1, xFilial("FK7") ) //FK7_FILIAL
		__oQryFK7:SetString(2, "SE2") //FK7_ALIAS
		__oQryFK7:SetString(3, (cAliasQry)->COD) //FK7_CLIFOR
		__oQryFK7:SetString(4, (cAliasQry)->LOJA) //FK7_LOJA
		__oQryFK7:SetString(5, (cAliasQry)->E2_PREFIXO) //FK7_PREFIX
		__oQryFK7:SetString(6, (cAliasQry)->E2_NUM) //FK7_NUM
		__oQryFK7:SetString(7, (cAliasQry)->E2_TIPO) //FK7_TIPO
		cQry1 := __oQryFK7:GetFixQuery()
		cAliasNF := MpSysOpenQuery(cQry1)

		//Armazena os IDDOC's das parcelas da NF para somar os valores do IR na proxima query
		While (cAliasNF)->( !EOF() )
			Aadd(aIdDoc, (cAliasNF)->FK7_IDDOC )
			(cAliasNF)->( DbSkip() )
		EndDo

		If Select(cAliasNF) > 0
			(cAliasNF)->(dbCloseArea())
		Endif
	Endif

	If __oQryFKW2 == Nil 
		cQry2 := "SELECT FKW_NATREN, FKW_CGC CPF, "
		cQry2 += "ISNULL(SUM(FKW_BASETR),0) FKW_BASETR, "
		cQry2 += "ISNULL(SUM(FKW_VLIMP),0) FKW_VLIMP, "
		cQry2 += "ISNULL(SUM(FKW_BASENR),0) FKW_BASENR, "
		cQry2 += "ISNULL(SUM(FKW_VLIMPN),0) FKW_VLIMPN "  
		cQry2 += "FROM " + RetSqlName("FKW") + " FKW "
		cQry2 += "WHERE FKW.D_E_L_E_T_ = ' ' AND  "
		cQry2 += 		"FKW_FILIAL = ? AND "
		cQry2 += 		"FKW_TPIMP = ? AND "
		cQry2 += 		"FKW_CARTEI = ? AND "
		cQry2 += 		"FKW_IDDOC IN ( ? ) "
		cQry2 += "GROUP BY FKW_NATREN, FKW_CGC "
		cQry2 := ChangeQuery(cQry2)
		If __lCachQry
			__oQryFKW2 := FwExecStatement():New(cQry2)
		Else
			__oQryFKW2 := FWPreparedStatement():New(cQry2)
		EndIf   
	Endif
	__oQryFKW2:SetString(1, xFilial("FKW") ) //FKW_FILIAL
	__oQryFKW2:SetString(2, "IRF") //FKW_TPIMP
	__oQryFKW2:SetString(3, "1") //FKW_CARTEI
	__oQryFKW2:SetIn(4, aIdDoc ) //FKW_IDDOC

	cQry2 := __oQryFKW2:GetFixQuery()
	cAlsFkw := MpSysOpenQuery(cQry2)

	While (cAlsFkw)->( !EOF() )

		If __lTemFKJ //Tratamento para Rateio de CPF's do IR sobre Aluguel
			If ( !Empty((cAlsFkw)->CPF) .And. !Empty((cAliasQry)->FKJ_CPF) ) .And. AllTrim((cAliasQry)->FKJ_CPF) != AllTrim((cAlsFkw)->CPF)
				(cAlsFkw)->( DbSkip())
				Loop
			EndIf
		EndIf

		lRet := .T.
		nRenBrut := (cAlsFkw)->FKW_BASETR+(cAlsFkw)->FKW_BASENR  //Rendimento bruto
		nRenTrib := (cAlsFkw)->FKW_BASETR //Rendimento tributavel
		nValTrib := (cAlsFkw)->FKW_VLIMP //Valor do tributo 

		If lSusp
			nRenTrib := nRenBrut
			nValTrib := (cAlsFkw)->FKW_VLIMP+(cAlsFkw)->FKW_VLIMPN
		Endif

		If lFornPF .and. !lSusp //Fornecedor pessoa fisica (R-4010)
			/*-------------------------------------------------------------------------------------|
			| Aqui subtraimos as dedu��es da base tributavel p/ uma melhor conferencia no TAF.     | 
			| No envio do TAF para a RFB, o TAF manda o valor cheio (s/ deduzir) baseado no T154AI.|
			--------------------------------------------------------------------------------------*/	
			nQtdDep  := (cAliasQry)->A2_NUMDEP
			nDedDep  := VlDedDep(dDtEmis, nQtdDep, (cAliasQry)->COD + (cAliasQry)->LOJA,, (cAliasQry)->FK7_IDDOC)
			nRenTrib -= nDedDep 
		EndIf

		If nRenBrut > 0 
			AAdd( aT154Trb,{'12',;  			    //01 - Codigo que corresponde o tributo no layout TAF
							(cAlsFkw)->FKW_NATREN,;	//02 - C�digo da natureza de rendimento
							nRenBrut,; 			    //03 - Rendimento bruto
							nRenTrib,;			    //04 - Rendimento tributavel
							nValTrib })			    //05 - Valor do tributo
		EndIf

		(cAlsFkw)->( DbSkip() )
	EndDo

	If Select(cAlsFkw) > 0
		(cAlsFkw)->(dbCloseArea())
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FDedIse
Verifica se h� dedu��o ou isen��o para o tributo IR pessoa fisica:
- No "complemento de t�tulo x imposto" (tabela FKG), para dedu��o e isen��o;
- No legado para as dedu��es INSS e dependentes;

@param cIdDoc  - ID do titulo (FK7)
@param aDetDed - Array que armazenara as dedu��es
		[1] Tipo da dedu��o
		[2] Valor da dedu��o de base
		[3] Valor da dedu��o de base suspensa
		[4] Nr de inscri��o do plano de previdencia
		[5]	Array contendo os dependentes da dedu��o	
@param aDetIse - Informa .T. se o fornecedor do titulo � pessoa fisica
@param lIsento - Informa .T. se o titulo tem isencao de IRPF
@param cAliasQry - Alias da query principal (MntQryPag/MntQryRec)
@param dData   - Data do fato gerador do IR
@param nVrIrf  - Valor retido do IR

@return nil

@author fabio.casagrande
@since 05/01/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function FDedIse(cIdDoc, aDetDed, aDetIse, lIsento, cAliasQry, dData, nVrIrf, lSusp)

	Local cTpAtrb  As Character
	Local cDedu As Character
	Local cInsPre As Character
	Local cIsen As Character
	Local cDesRen As Character
	Local cFornec As Character
	Local cLoja As Character
	Local cTemInPre As Character
	Local cRet As Char
	Local nVlDedBs As Numeric
	Local nVlDBsSus As Numeric
	Local nValIsen As Numeric
	Local nDedPen As Numeric
	Local nDedSusPen As Numeric
	Local nVrInss As Numeric
	Local nQtdDep As Numeric
	Local aDepPen As Array
	Local lDedPen As Logical

	Default cIdDoc  := ""
	Default aDetDed := {}
	Default aDetIse := {}
	Default lIsento := .F.
	Default dData   := CTOD("  /  /    ")
	Default nVrIrf  := 0
	Default lSusp   := .F.

	aDepPen := {}
	nDedPen := 0
	nDedSusPen := 0
	nVlDedBs := 0
	nVlDBsSus := 0
	lDedPen := .F.
	nVrInss := (cAliasQry)->E2_INSS
	nQtdDep := (cAliasQry)->A2_NUMDEP
	cFornec := (cAliasQry)->COD
	cLoja   := (cAliasQry)->LOJA
	cRet	:= ""

	DbSelectArea("FKG")
	FKG->(DBSetOrder(2)) //FKG_FILIAL+FKG_IDDOC+FKG_TPIMP

	//Verifica se o titulo tem complemento de imposto na tabela FKG
	If FKG->( MsSeek( xFilial("FKG") + cIdDoc ) )

		While FKG->( !Eof() ) .And. Alltrim( FKG->( FKG_FILIAL + FKG_IDDOC ) ) == Alltrim( xFilial("FKG") + cIdDoc )

			cTpAtrb := AllTrim( FKG->FKG_TPATRB )

			If cTpAtrb $ "010|011|012" // Dedu��o por Prev. Privada, Fapi ou Funpresp	
				cDedu 		:= TrataAcao( cTpAtrb, "DEDUCAO" )
				cInsPre 	:= FKG->FKG_INSPRE
				cTemInPre	:= If(Empty(cInsPre), "2", "1" )
				If lSusp
					nVlDBsSus := FKG->FKG_VALOR
				Else
					nVlDedBs:= FKG->FKG_VALOR
				EndIf
				AAdd( aDetDed, { cDedu, nVlDedBs, nVlDBsSus, cInsPre, {}, cTemInPre } )
			ElseIf cTpAtrb $ "013" // Dedu��o por Pens�o Alimenticia 
				//Soma as dedu��es de todos os dependentes para enviar aglutinado
				If lSusp
					nDedSusPen += FKG->FKG_VALOR 
				Else
					nDedPen += FKG->FKG_VALOR	
				EndIf
				lDedPen := .T.				
			ElseIf cTpAtrb $ "006|015|016|017|018|019|020|021|022|023" //Isen��o
				nValIsen	:= FKG->FKG_VALOR					
				cIsen := TrataAcao( cTpAtrb, "ISENCAO" )
				If cIsen == "99"
					cDesRen	:= FKG->FKG_DESCR
				EndIf
				
				AAdd( aDetIse, { cIsen, nValIsen, cDesRen } )
				lIsento     := .T.

			EndIf

			cDedu		:= ""
			nVlDedBs	:= 0
			nVlDBsSus	:= 0
			cInsPre		:= ""
			cIsen		:= ""
			nValIsen	:= 0
			cDesRen		:= ""

			FKG->( DBSkip() )
		EndDo
	EndIf

	If lDedPen // Dedu��o por Pens�o Alimenticia	
		cDedu := TrataAcao( "013", "DEDUCAO" )
		F989DepPen(@aDepPen, cIdDoc, cFornec, cLoja, "1", lSusp) //Carrega o array aDepPen
		AAdd( aDetDed, { cDedu, nDedPen, nDedSusPen, "", aClone(aDepPen), "" } )
		FWFreeArray(aDepPen)
		aDepPen	:= {}
	EndIf

	//Verifica as dedu��es do IRPF do legado (INSS e/ou dependentes)
	If nVrIrf > 0 .or. lSusp
		If nVrInss > 0 .and. __lDedIns // Previdencia Oficial (INSS)
			cDedu := "1"
			If lSusp
				nVlDBsSus := nVrInss //Dedu��o com a exigibilidade suspensa
			Else
				nVlDedBs := nVrInss
			EndIf
			AAdd( aDetDed, { cDedu, nVlDedBs, nVlDBsSus, "", {}, "" } ) // Previdencia Oficial (INSS)
		EndIf

		If nQtdDep > 0 // Dependentes
			nVrDep := VlDedDep(dData, nQtdDep, cFornec + cLoja, .T.)
			If nVrDep > 0
				If HMGet(__oHashDed, cFornec + cLoja, @cRet)
					__oHashDed:Set( cFornec + cLoja, cRet := cIdDoc)
				EndIf
				cDedu := "7"
				If lSusp
					nVlDBsSus := nVrDep //Dedu��o com a exigibilidade suspensa
				Else
					nVlDedBs := nVrDep
				EndIf
				F989DepPen(@aDepPen, cIdDoc, cFornec, cLoja, "2", lSusp) //Carrega o array aDepPen
				AAdd( aDetDed, { cDedu, nVlDedBs, nVlDBsSus, "", aDepPen, "" } ) // Previdencia Oficial (INSS)
			EndIf
		EndIf
	EndIf

	aDepPen := {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} NatRenFKY
Verifica se h� reten��o, suspen��o ou isen��o para o tributo com natureza(s) 
de rendimento e com o fato gerador na baixa.

@param cAliasBx  - Alias da baixa
@param cAliasQry - Alias do titulo
@param aT158Trb  - Array com os dados de retencao
@param lFornPF   - Informa .T. se o fornecedor do titulo � pessoa fisica
@param dDtEmis   - Data emissao do titulo
@param lIsento   - Informa .T. se o titulo tem isencao de IRPF

@return lRet - Retorna .T. se encontrou reten��es

@author fabio.casagrande
@since 29/12/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function NatRenFKY(cAliasBx As Char, cAliasQry As Char, aT158Trb As Array, lFornPF As Logical, dDataPg As Date, lIsento As Logical) As Logical

	Local cImpIR   As Character
	Local cImpPis  As Character
	Local cImpCof  As Character
	Local cImpCSL  As Character
	Local cSemImp  As Character
	Local cIdMov   As Character
	Local cTrib	   As Character
	Local lRet	   As Logical
	Local lSusp	   As Logical
	Local nDedDep  As Numeric
	Local nRenBrut As Numeric
	Local nRenTrib As Numeric
	Local nValTrib As Numeric
	Local cNumPro  As Character
	Local cTpProc  As Character
	Local cCodSus  As Character
	Local nVlImpNR As Numeric
	Local nBaseNR  As Numeric
	Local nQtdDep  As Numeric

	Default cAliasBx  := ""
	Default cAliasQry := ""
	Default aT158Trb  := {}
	Default lFornPF   := .F.
	Default dDataPg   := CTOD("  /  /    ")
	Default lIsento   := .F.

	cImpIR	 := PadR( 'IRF', __nFkwImp )
	cImpPis	 := PadR( 'PIS', __nFkwImp )
	cImpCof	 := PadR( 'COF', __nFkwImp )
	cImpCSL	 := PadR( 'CSL', __nFkwImp )
	cSemImp	 := PadR( 'SEMIMP', __nFkwImp )
	cIdMov   := (cAliasBx)->IDMOV
	cTrib    := ""
	lRet	 := .F.
	lSusp	 := .F.
	nDedDep  := 0
	nRenBrut := 0
	nRenTrib := 0
	nValTrib := 0
	cNumPro  := ""
	cTpProc  := ""
	cCodSus  := ""
	nVlImpNR := 0
	nBaseNR  := 0

	DbSelectArea("FKY")
	FKY->(DBSetOrder(3)) //FKY_FILIAL, FKY_IDFK2, FKY_NATREN, FKY_TPIMP
	FKY->(DbGotop())	
	FKY->(MsSeek( xFilial("FKY") + cIdMov ))

	While FKY->( !Eof() ) .and. FKY->FKY_IDFK2 == cIdMov

		//Tratamento para Rateio de CPF's do IR sobre Aluguel
		If !Empty((cAliasBx)->CPF) .And. !FNewCpf(cAliasBx)
			FKY->( DbSkip())
			Loop
		EndIf

		/*---------------------------------------|
		| C�digos de tributos no layout do TAF:	 | 
		| 10=PIS;								 |
		| 11=Cofins;							 |
		| 12=IR emiss�o;					 	 |
		| 13=INSS;								 |
		| 18=CSLL;								 |	
		| 28=IR baixa 							 |
		----------------------------------------*/		
		If FKY->FKY_TPIMP == cImpIR 
			cTrib := "28"
		Elseif FKY->FKY_TPIMP == cImpPis 
			cTrib := "10"
		Elseif FKY->FKY_TPIMP == cImpCof 
			cTrib := "11"
		Elseif FKY->FKY_TPIMP == cImpCSL 
			cTrib := "18"
		Elseif FKY->FKY_TPIMP == cSemImp 
			cTrib := "SEMIMP" //Pagamentos com nat. rendimento e sem tributos
		Endif
				
		lRet := .T.
		nRenBrut := FKY->FKY_BASETR+FKY->FKY_BASENR //Rendimento bruto
		nRenTrib := FKY->FKY_BASETR //Rendimento tributavel
		nValTrib := FKY->FKY_VLIMP  //Valor do tributo 

		//Verifica se houve reten��o que deixou de ser efetuada em fun��o de um processo adm/jud
		If !Empty(FKY->FKY_NUMPRO) 
			lSusp    := .T.
			nRenTrib := nRenBrut
			nValTrib := FKY->FKY_VLIMP+FKY->FKY_VLIMPN
			cNumPro  := FKY->FKY_NUMPRO
			cTpProc  := FKY->FKY_TPPROC
			cCodSus  := FKY->FKY_CODSUS
			nVlImpNR := FKY->FKY_VLIMPN
			nBaseNR  := FKY->FKY_BASENR
		Endif

		If lFornPF //Fornecedor pessoa fisica (R-4010)
			If lIsento
				nBaseNR := FKY->FKY_BASENR //Base Isenta
			ElseIf !lSusp
				/*-------------------------------------------------------------------------------------|
				| Aqui subtraimos as dedu��es da base tributavel p/ uma melhor conferencia no TAF.     | 
				| No envio do TAF para a RFB, o TAF manda o valor cheio (s/ deduzir) baseado no T158AD.|
				--------------------------------------------------------------------------------------*/	
				nQtdDep  := (cAliasQry)->A2_NUMDEP
				nDedDep  := VlDedDep(dDataPg, nQtdDep, (cAliasQry)->COD + (cAliasQry)->LOJA,, (cAliasQry)->FK7_IDDOC)
				nRenTrib -= nDedDep 
			EndIf
		EndIf

		If nRenBrut > 0 
			AAdd( aT158Trb,{cTrib ,;  			//01 - Codigo que corresponde o tributo no layout TAF
							FKY->FKY_NATREN,;	//02 - C�digo da natureza de rendimento
							nRenBrut,; 			//03 - Rendimento bruto
							nRenTrib,;			//04 - Rendimento tributavel
							nValTrib,;			//05 - Valor do tributo
							cNumPro,;		 	//06 - Identifica��o do processo judicial/administrativo ou ato concess�rio
							cTpProc,;			//07 - Indicador da origem do processo
							cCodSus,;			//08 - C�digo do Indicativo da Suspens�o												
							nVlImpNR,;			//09 - Valor da reten��o que deixou de ser efetuada em fun��o de processo adm/judicial
							nBaseNR })			//10 - Valor da base de c�lculo do tributo com exigibilidade suspensa ou isenta
		Endif

		FKY->( DbSkip() )
	EndDo

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NatPropBX
Busca dados das baixas quando o PCC estiver na emissao (MV_BX10925=2), 
proporcionalizado o PCC de acordo com o valor da baixa (referencia tabela FKW).
Para o IR na baixa considera os dados da tabela FKY.

@param cAliasBx  - Alias do pagamento
@param cAliasQry - Alias do titulo
@param aT158Trb  - Array com os dados de retencao
@param lFornPF   - Informa .T. se o fornecedor do titulo � pessoa fisica
@param dDtEmis   - Data emissao do titulo
@param lIsento   - Informa .T. se o titulo tem isencao de IRPF
@param cAliasQry - Alias do titulo 

@return lRet - Retorna .T. se encontrou reten��es

@author rodrigo.alexandre/fabio.casagrande
@since 23/12/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function NatPropBX(cAliasBx As Char, cAliasQry As Char, aT158Trb As Array, lFornPF As Logical, dDataPg As Date, lIsento As Logical) As Logical

	Local aImpProp As Array
	Local cQry1	As Character
	Local cQry2	As Character
	Local cQry3	As Character
	Local cAliasPCC As Character
	Local cAliasIR As Character
	Local cFator As Character
	Local cAlsFator	As Character
	Local cImpProp  As Character
	Local cNumPro As Character
	Local cTpProc As Character
	Local cCodSus As Character
	Local cImpIR As Character
	Local cImpPis As Character
	Local cImpCof As Character
	Local cImpCSL As Character
	Local cSemImp As Character
	Local cFilFk2 As Character
	Local cIdFK7 As Character
	Local cIdFK2 As Character
	Local cTrib As Character
	Local lRet As Logical
	Local lSusp As Logical
	Local nDedDep As Numeric
	Local nRenBrut As Numeric
	Local nRenTrib As Numeric
	Local nValTrib As Numeric
	Local nVlImpNR As Numeric
	Local nBaseNR As Numeric
	Local nQtdDep As Numeric

	Default cAliasBx  := ""
	Default cAliasQry := ""
	Default aT158Trb  := {}
	Default lFornPF   := .F.
	Default dDataPg   := CTOD("  /  /    ")
	Default lIsento   := .F.

	cQry1	   := ""
	cQry2	   := ""
	cQry3	   := ""
	cImpIR	   := PadR( 'IRF', __nFkwImp )
	cImpPis	   := PadR( 'PIS', __nFkwImp )
	cImpCof	   := PadR( 'COF', __nFkwImp )
	cImpCSL	   := PadR( 'CSL', __nFkwImp )
	cSemImp	   := PadR( 'SEMIMP', __nFkwImp )
	cTrib      := ""
	lRet	   := .F.
	lSusp	   := .F.
	nDedDep    := 0
	nRenBrut   := 0
	nRenTrib   := 0
	nValTrib   := 0
	cNumPro    := ""
	cTpProc    := ""
	cCodSus    := ""
	nVlImpNR   := 0
	nBaseNR    := 0
	cAliasPCC := ""
	cAliasIR   := ""
	cFilFk2    := (cAliasBx)->FILIAL
	cIdFK7     := (cAliasQry)->FK7_IDDOC
	cIdFK2     := (cAliasBx)->IDMOV
	cImpProp   := cImpPis + "|" + cImpCof + "|" + cImpCSL
	aImpProp   := StrtoKarr2( cImpProp, "|", .F.)

	/*----------------------------------------------------------------|
	| Inicio do tratamento para PCC na emissao (MV_BX10925=2):        | 
	| Encontra o fator de calculo para considerar o PCC proporcional  |
	| ao valor da baixa (no casos de baixas parciais) 				  |
	-----------------------------------------------------------------*/	
	If __oQryFTR == Nil
		cQry1 	:= "SELECT DISTINCT FKW_NATREN NATREN, "
		cQry1 	+= 		" CASE WHEN E2_SALDO > 0 THEN FK2_VALOR / FKW_BASETR "
		cQry1 	+= 			" WHEN ISNULL((SELECT SUM(FK2_VALOR) FROM " + RetSqlName("FK2") + " FK2 WHERE FK2_IDDOC = ? AND FK2_IDFK2 != ? "
		cQry1 	+= 				" AND NOT EXISTS( SELECT FK2EST.FK2_IDDOC FROM " + RetSqlName("FK2") + " FK2EST"
		cQry1 	+= 				" WHERE FK2EST.FK2_FILIAL = FK2.FK2_FILIAL"
		cQry1 	+= 				" AND FK2EST.FK2_IDDOC = FK2.FK2_IDDOC "
		cQry1 	+= 				" AND FK2EST.FK2_SEQ = FK2.FK2_SEQ "
		cQry1 	+= 				" AND FK2EST.FK2_TPDOC = 'ES' "
		cQry1 	+= 				" AND FK2EST.D_E_L_E_T_ = ' ') "
		cQry1 	+= 				" AND FK2.D_E_L_E_T_ = ' '),0) = 0 THEN 1 " // T�tulo com 1 �nica baixa total

		cQry1 	+= 			" WHEN FK2_SEQ != ( SELECT MAX(A.FK2_SEQ) SEQMAX "
		cQry1 	+= 				" FROM " + RetSqlName("FK2") + " A "
		cQry1 	+= 				" WHERE	A.FK2_FILIAL = FK2.FK2_FILIAL "
		cQry1 	+= 				" AND A.FK2_RECPAG = 'P' "
		cQry1 	+= 				" AND A.FK2_IDDOC = FK2.FK2_IDDOC "
		
		cQry1 	+= 				" AND NOT EXISTS( SELECT FK2EST.FK2_IDDOC FROM " + RetSqlName("FK2") + " FK2EST"
		cQry1 	+= 				" WHERE FK2EST.FK2_FILIAL = A.FK2_FILIAL"
		cQry1 	+= 				" AND FK2EST.FK2_IDDOC = A.FK2_IDDOC "
		cQry1 	+= 				" AND FK2EST.FK2_SEQ = A.FK2_SEQ "
		cQry1 	+= 				" AND FK2EST.FK2_TPDOC = 'ES' "
		cQry1 	+= 				" AND FK2EST.D_E_L_E_T_ = ' ') "
		cQry1 	+= 				" AND A.D_E_L_E_T_ = ' ' ) THEN FK2_VALOR / FKW_BASETR "

		cQry1 	+= 			" ELSE ( ( FKW_BASETR - ( (SELECT SUM(FK2_VALOR) FROM " + RetSqlName("FK2") + " FK2 "
		cQry1 	+= 				" WHERE FK2_IDDOC = ? AND FK2_IDFK2 != ? "
		cQry1 	+= 				" AND NOT EXISTS( SELECT FK2EST.FK2_IDDOC FROM " + RetSqlName("FK2") + " FK2EST"
		cQry1 	+= 				" WHERE FK2EST.FK2_FILIAL = FK2.FK2_FILIAL"
		cQry1 	+= 				" AND FK2EST.FK2_IDDOC = FK2.FK2_IDDOC "
		cQry1 	+= 				" AND FK2EST.FK2_SEQ = FK2.FK2_SEQ "
		cQry1 	+= 				" AND FK2EST.FK2_TPDOC = 'ES' "
		cQry1 	+= 				" AND FK2EST.D_E_L_E_T_ = ' ') "
		cQry1 	+= 				" AND FK2.D_E_L_E_T_ = ' ') * FKW_PERC / 100 ) ) / ( FKW_PERC / 100) ) / FKW_BASETR " // T�tulo total baixado com pagamentos parciais
		cQry1 	+= 		" END FATOR "

		cQry1 	+= 		" FROM " + RetSqlName("FK2") + " FK2 "
		cQry1 	+= 			" INNER JOIN " + RetSqlName("FKW") + " FKW ON FKW_FILIAL = ? AND FKW_IDDOC = FK2_IDDOC AND FKW_TPIMP IN ( ? ) AND FKW.D_E_L_E_T_ = ' ' AND FKW_CARTEI = '1' "
		cQry1 	+= 			" INNER JOIN " + RetSqlName("FK7") + " FK7 ON FK7_FILTIT = ? AND FK7_IDDOC = FK2_IDDOC AND FK7.D_E_L_E_T_ = ' ' "
		cQry1 	+= 			" INNER JOIN " + RetSqlName("SE2") + " SE2 ON E2_FILIAL = FK7_FILTIT AND E2_PREFIXO = FK7_PREFIX AND E2_NUM = FK7_NUM AND E2_PARCELA = FK7_PARCEL AND E2_TIPO = FK7_TIPO AND SE2.D_E_L_E_T_ = ' ' "
		cQry1 	+= 		" WHERE FK2_FILIAL = ? AND FK2_IDFK2 = ? AND FK2_IDDOC = ? AND FK2.D_E_L_E_T_ = ' ' "

		cQry1 	:= ChangeQuery(cQry1)
        If __lCachQry
            __oQryFTR := FwExecStatement():New(cQry1)
        Else
            __oQryFTR := FWPreparedStatement():New(cQry1)
        EndIf   
	EndIf

	__oQryFTR:SetString(1, cIdFK7)
	__oQryFTR:SetString(2, cIdFK2)
	__oQryFTR:SetString(3, cIdFK7)
	__oQryFTR:SetString(4, cIdFK2)
	__oQryFTR:SetString(5, cFilFK2)
	__oQryFTR:SetIn(6, aImpProp)
	__oQryFTR:SetString(7, cFilFK2)
	__oQryFTR:SetString(8, cFilFK2)
	__oQryFTR:SetString(9, cIdFK2)
	__oQryFTR:SetString(10, cIdFK7)
									
	cQry1 		:= __oQryFTR:GetFixQuery()
    cAlsFator  	:= MpSysOpenQuery(cQry1)
	
	While !(cAlsFator)->(Eof())
		cFator		:= AllTrim(STR((cAlsFator)->FATOR))
		If __oQryBx1 == Nil 
			cQry2 := " SELECT FKW_NATREN NATREN, FKW_TPIMP TPIMP, FKW_PERC PERC, "
			cQry2 += " ( ROUND(FKW_BASETR * ?, 2) * FKW_PERC ) / 100 BASETR, ( ROUND(FKW_VLIMP * ?, 2) * FKW_PERC ) / 100 VLIMP, "
			cQry2 += " ( ROUND(FKW_BASENR * ?, 2) * FKW_PERCNR ) / 100 BASENR, ( ROUND(FKW_VLIMPN * ?, 2) * FKW_PERCNR ) / 100 VLIMPN, "
			cQry2 += " FKW_NUMPRO NUMPRO, FKW_TPPROC TPPROC, FKW_CODSUS CODSUS "
			cQry2 += " FROM " + RetSqlName("FKW") + " PROPFKW "
			cQry2 += " WHERE	FKW_FILIAL = ? AND "
			cQry2 += 		"FKW_IDDOC = ? AND "
			cQry2 += 		"FKW_TPIMP IN ( ? ) AND "
			cQry2 += 		"FKW_CARTEI = '1' AND "
			cQry2 += 		"FKW_NATREN = ? AND "
			cQry2 += 		"D_E_L_E_T_ = ' ' "		
			cQry2 += " ORDER BY FKW_FILIAL, FKW_IDDOC, FKW_CARTEI, FKW_NATREN, FKW_TPIMP, R_E_C_N_O_ " //Indice 2 da FKW
			cQry2 := ChangeQuery(cQry2)
			If __lCachQry
				__oQryBx1 := FwExecStatement():New(cQry2)
			Else
				__oQryBx1 := FWPreparedStatement():New(cQry2)
			EndIf   
		EndIf
		__oQryBx1:SetNumeric(1,cFator)
		__oQryBx1:SetNumeric(2,cFator)
		__oQryBx1:SetNumeric(3,cFator)
		__oQryBx1:SetNumeric(4,cFator)
		__oQryBx1:SetString(5,cFilFK2)
		__oQryBx1:SetString(6,cIdFK7)
		__oQryBx1:SetIn( 7, aImpProp)
		__oQryBx1:SetString(8,(cAlsFator)->NATREN)
		cQry2 := __oQryBx1:GetFixQuery()
		cAliasPCC := MpSysOpenQuery(cQry2)
	
		While (cAliasPCC)->( !EOF() )

			/*---------------------------------------------|
			| C�digos de tributos do PCC no layout do TAF: | 
			| 10=PIS;  									   |
			| 11=Cofins;		  						   |
			| 18=CSLL; 								       |
			----------------------------------------------*/	
			If (cAliasPCC)->TPIMP == cImpPis 
				cTrib := "10"
			Elseif (cAliasPCC)->TPIMP == cImpCof 
				cTrib := "11"
			Elseif (cAliasPCC)->TPIMP == cImpCSL 
				cTrib := "18"
			Endif
					
			lRet := .T.
			nRenBrut := (cAliasPCC)->BASETR+(cAliasPCC)->BASENR //Rendimento Bruto
			nRenTrib := (cAliasPCC)->BASETR //Base tributavel
			nValTrib := NoRound((cAliasPCC)->VLIMP,2)  //Valor Tributo

			If !Empty((cAliasPCC)->NUMPRO) //Verifica se houve reten��o que deixou de ser efetuada em fun��o de um processo adm/jud
				nRenTrib := nRenBrut
				nValTrib := NoRound((cAliasPCC)->VLIMP,2)+NoRound((cAliasPCC)->VLIMPN,2)
				cNumPro  := (cAliasPCC)->NUMPRO
				cTpProc  := (cAliasPCC)->TPPROC
				cCodSus  := (cAliasPCC)->CODSUS
				nVlImpNR := NoRound((cAliasPCC)->VLIMPN,2)
				nBaseNR  := (cAliasPCC)->BASENR
			Endif

			AAdd( aT158Trb,{cTrib ,;  			    //01 - Codigo que corresponde o tributo no layout TAF
							(cAliasPCC)->NATREN,;   //02 - C�digo da natureza de rendimento
							nRenBrut,; 				//03 - Rendimento bruto
							nRenTrib,;				//04 - Rendimento tributavel
							nValTrib,;				//05 - Valor do tributo
							cNumPro,;		 		//06 - Identifica��o do processo judicial/administrativo ou ato concess�rio
							cTpProc,;				//07 - Indicador da origem do processo
							cCodSus,;				//08 - C�digo do Indicativo da Suspens�o												
							nVlImpNR,;				//09 - Valor da reten��o que deixou de ser efetuada em fun��o de processo adm/judicial
							nBaseNR })				//10 - Valor da base de c�lculo do tributo com exigibilidade suspensa

			(cAliasPCC)->( dbSkip() )
		EndDo
	
		If Select(cAliasPCC) > 0
			(cAliasPCC)->(dbCloseArea())
		EndIf

		(cAlsFator)->(DbSkip())
	EndDo

	If Select(cAlsFator) > 0
		(cAlsFator)->(dbCloseArea())
	EndIf
	//Fim do tratamento para PCC na emissao (MV_BX10925=2)

	//Inicio do tratamento para pagamentos com IR na baixa ou naturezas de rendimentos sem tributos
	If __oQryBx2 == Nil
		cQry3 := " SELECT FKY_TPIMP TPIMP, FKY_NATREN NATREN, FKY_BASETR BASETR, FKY_VLIMP VLIMP, FKY_BASENR BASENR, "
		cQry3 += " FKY_VLIMPN VLIMPN, FKY_NUMPRO NUMPRO, FKY_TPPROC TPPROC, FKY_CODSUS CODSUS, FKY_IDORIG, FKY_TABORI "
		cQry3 += " FROM " + RetSqlName("FKY") + " "
		cQry3 += " WHERE	FKY_FILIAL = ? AND "
		cQry3 += 		"FKY_IDDOC = ? AND "
		cQry3 += 		"FKY_IDFK2 = ? AND "
		cQry3 += 		"FKY_TPIMP IN (?) AND "
		cQry3 += 		"D_E_L_E_T_ = ' ' "
		cQry3 += " ORDER BY FKY_FILIAL, FKY_IDFK2, FKY_NATREN, FKY_TPIMP, R_E_C_N_O_ " //Indice 3 da FKY
		cQry3 	:= ChangeQuery(cQry3)
		If __lCachQry
			__oQryBx2 := FwExecStatement():New(cQry3)
		Else
			__oQryBx2 := FWPreparedStatement():New(cQry3)
		EndIf   
	Endif
	__oQryBx2:SetString(1,cFilFK2)
	__oQryBx2:SetString(2,cIdFK7)
	__oQryBx2:SetString(3,cIdFK2)
	__oQryBx2:SetIn( 4, {cImpIR,cSemImp} )
	cQry3 	 := __oQryBx2:GetFixQuery()
	cAliasIR := MpSysOpenQuery(cQry3)

	While (cAliasIR)->( !EOF() )

		//Tratamento para Rateio de CPF's do IR sobre Aluguel
		If !Empty((cAliasBx)->CPF) .And. !FNewCpf(cAliasBx, (cAliasIR)->FKY_IDORIG, (cAliasIR)->FKY_TABORI)
			(cAliasIR)->( DbSkip())
			Loop
		EndIf

		If (cAliasIR)->TPIMP == cImpIR
			cTrib := "28"
		Elseif (cAliasIR)->TPIMP == cSemImp 
			cTrib := "SEMIMP" //Pagamentos com nat. rendimento e sem tributos
		Endif

		lRet := .T.
		nRenBrut := (cAliasIR)->BASETR+(cAliasIR)->BASENR //Rendimento Bruto
		nRenTrib := (cAliasIR)->BASETR //Base tributavel
		nValTrib := (cAliasIR)->VLIMP  //Valor Tributo 

		If !Empty((cAliasIR)->NUMPRO) //Verifica se houve reten��o que deixou de ser efetuada em fun��o de um processo adm/jud
			lSusp    := .T.
			nRenTrib := nRenBrut
			nValTrib := (cAliasIR)->VLIMP+(cAliasIR)->VLIMPN
			cNumPro  := (cAliasIR)->NUMPRO
			cTpProc  := (cAliasIR)->TPPROC
			cCodSus  := (cAliasIR)->CODSUS
			nVlImpNR := (cAliasIR)->VLIMPN
			nBaseNR  := (cAliasIR)->BASENR
		Endif

		If lFornPF //Fornecedor pessoa fisica (R-4010)
			If lIsento
				nBaseNR := (cAliasIR)->BASENR //Base Isenta
			ElseIf !lSusp
				/*-------------------------------------------------------------------------------------|
				| Aqui subtraimos as dedu��es da base tributavel p/ uma melhor conferencia no TAF.     | 
				| No envio do TAF para a RFB, o TAF manda o valor cheio (s/ deduzir) baseado no T158AD.|
				--------------------------------------------------------------------------------------*/	
				nQtdDep  := (cAliasQry)->A2_NUMDEP
				nDedDep  := VlDedDep(dDataPg, nQtdDep, (cAliasQry)->COD + (cAliasQry)->LOJA,, (cAliasQry)->FK7_IDDOC)
				nRenTrib -= nDedDep 
			Endif
		Endif

		If nRenBrut > 0
			AAdd( aT158Trb,{ cTrib ,;  			 //01 - Codigo que corresponde o tributo no layout TAF
							(cAliasIR)->NATREN,; //02 - C�digo da natureza de rendimento
							nRenBrut,; 			 //03 - Rendimento bruto
							nRenTrib,;			 //04 - Rendimento tributavel
							nValTrib,;			 //05 - Valor do tributo
							cNumPro,;		 	 //06 - Identifica��o do processo judicial/administrativo ou ato concess�rio
							cTpProc,;			 //07 - Indicador da origem do processo
							cCodSus,;			 //08 - C�digo do Indicativo da Suspens�o												
							nVlImpNR,;			 //09 - Valor da reten��o que deixou de ser efetuada em fun��o de processo adm/judicial
							nBaseNR })			 //10 - Valor da base de c�lculo do tributo com exigibilidade suspensa
		Endif

		(cAliasIR)->( dbSkip() )
	EndDo

	If Select(cAliasIR) > 0
		(cAliasIR)->(dbCloseArea())
	Endif
	//Fim do tratamento para os pagamentos com IR na baixa ou naturezas de rendimentos sem tributos

	FwFreeArray(aImpProp)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NatRenPA
Verifica se h� reten��o, suspencao ou isen��o para o tributo com natureza(s) 
de rendimento no t�tulo de adiantamento a pagar (tipo PA)

@param cAliasBx  - Alias do pagamento
@param cAliasQry - Alias do titulo
@param aT158Trb  - Array com os dados de retencao
@param lFornPF   - Informa .T. se o fornecedor do titulo � pessoa fisica
@param dDataPg   - Data do pagamento do titulo
@param lIsento   - Informa .T. se o titulo tem isencao de IRPF

@return lRet - Retorna .T. se encontrou reten��es

@author fabio.casagrande
@since 07/01/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function NatRenPA(cAliasBx As Char, cAliasQry As Char, aT158Trb As Array, lFornPF As Logical, dDataPg As Date, lIsento As Logical) As Logical

	Local cImpIR   As Character
	Local cImpPis  As Character
	Local cImpCof  As Character
	Local cImpCSL  As Character
	Local cSemImp  As Character
	Local cIdDoc   As Character
	Local cTrib    As Character
	Local cNumPro  As Character
	Local cTpProc  As Character
	Local cCodSus  As Character
	Local lRet	   As Logical
	Local lSusp    As Logical
	Local nDedDep  As Numeric
	Local nRenBrut As Numeric
	Local nRenTrib As Numeric
	Local nValTrib As Numeric
	Local nQtdDep  As Numeric
	Local nVlImpNR As Numeric
	Local nBaseNR  As Numeric

	Default cAliasBx  := ""
	Default cAliasQry := ""
	Default aT158Trb  := {}
	Default lFornPF   := .F.
	Default dDataPg   := CTOD("  /  /    ")
	Default lIsento   := .F.

	cImpIR	 := PadR( 'IRF', __nFkwImp )
	cImpPis	 := PadR( 'PIS', __nFkwImp )
	cImpCof	 := PadR( 'COF', __nFkwImp )
	cImpCSL	 := PadR( 'CSL', __nFkwImp )
	cSemImp	 := PadR( 'SEMIMP', __nFkwImp )
	cIdDoc   := (cAliasQry)->FK7_IDDOC
	cTrib    := ""
  	lRet	 := .F.
	lSusp	 := .F.
	nDedDep  := 0
	nRenBrut := 0
	nRenTrib := 0
	nValTrib := 0
	cNumPro  := ""
	cTpProc  := ""
	cCodSus  := ""
	nVlImpNR := 0
	nBaseNR  := 0

	DbSelectArea("FKW")
	FKW->(DBSetOrder(2)) //FKW_FILIAL, FKW_IDDOC, FKW_CARTEI, FKW_NATREN, FKW_TPIMP
	FKW->(DbGotop())	
	FKW->(MsSeek( xFilial("FKW") + cIdDoc + "1" ))

	While FKW->( !Eof() ) .and. FKW->FKW_IDDOC == cIdDoc .and. FKW->FKW_CARTEI == "1"
				
		/*---------------------------------------|
		| C�digos de tributos no layout do TAF:	 | 
		| 10=PIS;								 |
		| 11=Cofins;							 |
		| 12=IR emiss�o;					 	 |
		| 13=INSS;								 |
		| 18=CSLL;								 |	
		| 28=IR baixa 							 |
		----------------------------------------*/		
		If FKW->FKW_TPIMP == cImpIR 
			cTrib := "28"
		Elseif FKW->FKW_TPIMP == cImpPis 
			cTrib := "10"
		Elseif FKW->FKW_TPIMP == cImpCof 
			cTrib := "11"
		Elseif FKW->FKW_TPIMP == cImpCSL 
			cTrib := "18"
		Elseif FKW->FKW_TPIMP == cSemImp 
			cTrib := "SEMIMP" //Pagamentos com nat. rendimento e sem tributos
		Endif

		lRet := .T.
		nRenBrut := FKW->FKW_BASETR+FKW->FKW_BASENR //Rendimento bruto
		nRenTrib := FKW->FKW_BASETR //Rendimento tributavel
		nValTrib := FKW->FKW_VLIMP  //Valor do tributo 

		If !Empty(FKW->FKW_NUMPRO) //Verifica se houve reten��o que deixou de ser efetuada em fun��o de um processo adm/jud
			lSusp    := .T.
			nRenTrib := nRenBrut
			nValTrib := FKW->FKW_VLIMP+FKW->FKW_VLIMPN
			cNumPro  := FKW->FKW_NUMPRO
			cTpProc  := FKW->FKW_TPPROC
			cCodSus  := FKW->FKW_CODSUS
			nVlImpNR := FKW->FKW_VLIMPN
			nBaseNR  := FKW->FKW_BASENR
		Endif

		If lFornPF //Fornecedor pessoa fisica (R-4010)
			If lIsento
				nBaseNR := FKW->FKW_BASENR //Base Isenta
			ElseIf !lSusp
				/*-------------------------------------------------------------------------------------|
				| Aqui subtraimos as dedu��es da base tributavel p/ uma melhor conferencia no TAF.     | 
				| No envio do TAF para a RFB, o TAF manda o valor cheio (s/ deduzir) baseado no T158AD.|
				--------------------------------------------------------------------------------------*/	
				nQtdDep  := (cAliasQry)->A2_NUMDEP
				nDedDep  := VlDedDep(dDataPg, nQtdDep, (cAliasQry)->COD + (cAliasQry)->LOJA,, (cAliasQry)->FK7_IDDOC)
				nRenTrib -= nDedDep 
			Endif
		Endif

		If nRenBrut > 0 
			AAdd( aT158Trb,{cTrib ,;  			//01 - Codigo que corresponde o tributo no layout TAF
							FKW->FKW_NATREN,;	//02 - C�digo da natureza de rendimento
							nRenBrut,; 			//03 - Rendimento bruto
							nRenTrib,;			//04 - Rendimento tributavel
							nValTrib,;			//05 - Valor do tributo
							cNumPro,;		 	//06 - Identifica��o do processo judicial/administrativo ou ato concess�rio
							cTpProc,;			//07 - Indicador da origem do processo
							cCodSus,;			//08 - C�digo do Indicativo da Suspens�o												
							nVlImpNR,;			//09 - Valor da reten��o que deixou de ser efetuada em fun��o de processo adm/judicial
							nBaseNR })			//10 - Valor da base de c�lculo do tributo com exigibilidade suspensa
		Endif

		FKW->( DbSkip() )
	EndDo

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F989Flag
Grava os flags de integra��o dos t�tulos e baixas (FKF_REINF/FK2_REINF),
e tamb�m o flag de reenvio de dados (FKH_REINF), para quando
a integra��o for banco-a-banco.

@return nil

@author fabio.casagrande
@since 07/01/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function F989Flag()

	Local nLenFK 	As Numeric
	Local nI 		As Numeric

	nLenFK 	:= 0
	nI 		:= 0

	//Grava o flag de envio ao TAF quando a integracao for banco-a-banco
	If __lVerFlag
		//Grava flag dos dados da fatura T154 (FKF_REINF)
		nLenFK := Len(__aFK7Id)
		If nLenFK > 0

			FKF->( DbSetOrder(1) ) //FKF_FILIAL, FKF_IDDOC

			For nI := 1 To nLenFK
				If FKF->( MsSeek( __aFK7Id[nI][1] + __aFK7Id[nI][2] ) )
					Reclock( "FKF", .F. )
						FKF->FKF_REINF	:= "1"
					FKF->( MsUnlock() )
				EndIf
			Next nI
			FWFreeArray(__aFK7Id)
			__aFK7Id := {}
		EndIf

		//Grava flag dos dados de pagamento T158 (FK2_REINF)
		nLenFK := Len(__aFK2Id)
		If nLenFK > 0

			FK2->( DbSetOrder(1) ) //FK2_FILIAL, FK2_IDFK2

			For nI := 1 To nLenFK
				If FK2->( MsSeek( __aFK2Id[nI][1] + __aFK2Id[nI][2] ) )
					Reclock( "FK2", .F. )
						FK2->FK2_REINF	:= "1"
					FK2->( MsUnlock() )
				EndIf
			Next nI
			FWFreeArray(__aFK2Id)
			__aFK2Id := {}
		EndIf
	EndIf

	//Grava flag dos dados de reenvio (FKH_REINF)
	nLenFK := Len(__aFKHId)
	If nLenFK > 0

		FKH->( DbSetOrder(1) ) //FKH_FILIAL, FKH_LAYOUT, FKH_ID, FKH_REVISA

		For nI := 1 To nLenFK
			If FKH->( MsSeek( __aFKHId[nI][1] + __aFKHId[nI][2] + __aFKHId[nI][3] + __aFKHId[nI][4] ) )
				Reclock( "FKH", .F. )
					FKH->FKH_REINF	:= "1"
				FKH->( MsUnlock() )
			EndIf
		Next nI
		FWFreeArray(__aFKHId)
		__aFKHId := {}
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FForIrProg
Verifica se o fornecedor possui rateio entre CPFs (IR Aluguel),
e se sim, adiciona-os ao array "aParticip" para gerar o "T003".

@param aParticip - Array c/ os dados do fornecedor
@param cCodPart  - C�digo do fornecedor
@param nTamArr   - Tamanho do array a ser manipulado (aParticip)

@return nil

@author Rodrigo Oliveira
@since 30/01/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function FForIrProg(aParticip As Array, cCodPart As Character, nTamArr As Numeric)
	Local cQuery	As Character
	Local nI		As Numeric
	Local nTotCpf	As Numeric

	Default aParticip := {}
	Default cCodPart  := ""	
	Default nTamArr   := 0	

	nI		:= 0
	nTotCpf	:= 0

	If __oQryFKJ == Nil
		__cAlsNxt	:= GetNextAlias()

		DbSelectArea("FKJ")
		DbSetOrder(1)

		cQuery := " Select FKJ_NOME, FKJ_CPF, 1 QTDE "
		cQuery += " From ? FKJ "
		cQuery += " Where FKJ_FILIAL = ? "
		cQuery += " 	And FKJ_COD = ? "
		cQuery += " 	And FKJ_LOJA = ? "
		cQuery += " 	And D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
 		__oQryFKJ := FWPreparedStatement():New(cQuery)
	EndIf

	FKJ->(DbSeek(xFilial("FKJ") + cCodPart) )

	__oQryFKJ:SetNumeric(1, RetSqlName("FKJ") )
	__oQryFKJ:SetString(2, xFilial("FKJ") )
	__oQryFKJ:SetString(3, FKJ->FKJ_COD )
	__oQryFKJ:SetString(4, FKJ->FKJ_LOJA )
	cQuery 	 := __oQryFKJ:GetFixQuery()

	__cAlsNxt	:= MpSysOpenQuery(cQuery, __cAlsNxt)
	nTotCpf		:= MpSysExecScalar( "Select SUM(QTDE) TOT From (" + cQuery + ") A ", "TOT")

	For nI := 1 to nTotCpf
		aParticip[nTamArr][2] := "F" + (__cAlsNxt)->FKJ_CPF
		aParticip[nTamArr][3] := (__cAlsNxt)->FKJ_NOME
		aParticip[nTamArr][5] := ''
		aParticip[nTamArr][6] := (__cAlsNxt)->FKJ_CPF

		If nI < nTotCpf
			aAdd(aParticip, aClone(aParticip[nTamArr]))
			nTamArr++
		EndIf

		(__cAlsNxt)->(DbSkip())
	Next

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FBlcIrProg
Ajustar os dados de c�digo de participante e valor bruto
quando o titulo possui rateio entre CPF's (IR aluguel)

@return cCodPart - retorna o CPF para o codigo do participante

@author Rodrigo Oliveira
@since 30/01/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function FBlcIrProg(cAliasQry As Character, nVlrBruto As Numeric) As Character
	Local cCodPart	As Character

	Default cAliasQry := ""
	Default nVlrBruto := 0

	cCodPart	:= "F" + (cAliasQry)->FKJ_CPF
	nVlrBruto	:= ( nVlrBruto * (cAliasQry)->FKJ_PERCEN / 100 )

Return cCodPart

//-------------------------------------------------------------------
/*/{Protheus.doc} FNewCpf
Verifica se a reten��o do IR � de um CPF diferente do j� tratado

@return lRet - retorna se o CPF � de outro participante

@author Rodrigo Oliveira
@since 31/01/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function FNewCpf(cAliasBx As Character, cIdOrig As Character, cTabOri As Character) As Logical
	Local lRet 	As Logical
	Local cCpf	As Character
	Local aArea	As Array

	Default cAliasBx := ""
	Default cIdOrig	 := FKY->FKY_IDORIG
	Default cTabOri	 := FKY->FKY_TABORI
	
	lRet	:= .F.
	aArea	:= FK4->(GetArea())

	If cTabOri == "FK4"
		cCpf	:= AllTrim(GetAdvFVal("FK4", "FK4_CGC", xFilial("FK4") + cIdOrig, 1))
	EndIf

	lRet	:= ( !Empty(AllTrim(cCpf)) .And. !Empty(AllTrim((cAliasBx)->CPF)) .And. cCpf == AllTrim((cAliasBx)->CPF) )

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F989QryPag
Componente que faz a montagem da estrutura da query de t�tulos a pagar,
com base nos par�metros informados.

@param cCampos - Colunas a serem retornadas na query
@param cOrdem - Colunas que ir�o compor a clausula ORDER BY
@param lFiltReinf - True caso no Wizard tenha sido optado s� por dados do REINF
@param @cCond - N�o passar. Retornar� por referencia o conteudo do FROM e JOIN's
@param @cCamposFim - N�o passar. Retornar� por referencia filtros p/ o R-2040

@return Nil

@author Fabio Casagrande Lima
@since 10/02/2023
/*/
//-------------------------------------------------------------------
Static Function F989QryPag(cCampos As Char, cOrdem As Char, lFiltReinf As Logical, cCond As Char, cCamposFim As Char) As Char
	Local cUnion As Character
	Local cQuery As Character
	Local cCpoFlag As Character

	Default cCampos := ""
	Default cOrdem := ""
	Default lFiltReinf := .F.
	Default cCond := ""
	Default cCamposFim := ""

	cCpoFlag := ""
	cUnion   := ""

	cQuery := "SELECT DISTINCT " //Agrupa p/ trazer apenas 1 registro se houver duplicidade
	cQuery += cCampos
	cCond := " FROM " + RetSqlName("SE2") + " SE2 "
	cCond += " INNER JOIN "+ RetSqlName("SA2") + " SA2 "
	cCond += " ON (SA2.A2_FILIAL = '" + xFilial("SA2") + "'"
	cCond += " AND SA2.A2_COD = SE2.E2_FORNECE"
	cCond += " AND SA2.A2_LOJA = SE2.E2_LOJA " 

	If nTpPgPessoa = 1 // Pessoa f�sica
		cCond += "AND SA2.A2_TIPO = 'F' "
	ElseIf nTpPgPessoa = 2 // Pessoa Juridica
		cCond += "AND SA2.A2_TIPO = 'J'  "
	ElseIf nTpPgPessoa = 3 // Pessoa Exterior
		cCond += "AND SA2.A2_TIPO = 'X'  "
	EndIf
	cCond += " AND SA2.D_E_L_E_T_ = ' ' )"

	cCond += " INNER JOIN "+ RetSqlName("SED") + " SED "
	cCond += " ON ( SED.ED_FILIAL = '" + xFilial("SED") + "'"
	cCond += " AND SED.ED_CODIGO = SE2.E2_NATUREZ "
	cCond += " AND SED.D_E_L_E_T_ = ' ' )"

	cCond += " LEFT JOIN " + RetSqlName("FK7") + " FK7 "
	cCond += " ON ( FK7.FK7_FILIAL = '" + xFilial("FK7") + "' AND"
	cCond += " FK7.FK7_ALIAS = 'SE2' AND "

	If __lFK7Cpos
		cCond += " FK7.FK7_FILTIT = SE2.E2_FILIAL "
		cCond += " AND FK7.FK7_PREFIX = SE2.E2_PREFIXO"
		cCond += " AND FK7.FK7_NUM = SE2.E2_NUM "	 		
		cCond += " AND FK7.FK7_PARCEL = SE2.E2_PARCELA "	
		cCond += " AND FK7.FK7_TIPO = SE2.E2_TIPO "		
		cCond += " AND FK7.FK7_CLIFOR = SE2.E2_FORNECE "	
		cCond += " AND FK7.FK7_LOJA = SE2.E2_LOJA "			
	Else
		cCond += " FK7.FK7_CHAVE = "	
		If cBDname $ "MYSQL|POSTGRES"
			cCond += "CONCAT( "
		EndIf
		cCond += " SE2.E2_FILIAL "+ cConcat + " '|' " + cConcat
		cCond += " SE2.E2_PREFIXO "+ cConcat + " '|' " + cConcat
		cCond += " SE2.E2_NUM "+ cConcat + " '|' " + cConcat
		cCond += " SE2.E2_PARCELA "+ cConcat + " '|' " + cConcat
		cCond += " SE2.E2_TIPO "+ cConcat + " '|' " + cConcat
		cCond += " SE2.E2_FORNECE "+ cConcat + " '|' " + cConcat
		cCond += " SE2.E2_LOJA "
		If cBDname $ "MYSQL|POSTGRES"
			cCond += ") "
		EndIf
	Endif

	cCond += " AND FK7.D_E_L_E_T_ = ' ' "
	cCond += ") "

	cCond += " LEFT JOIN " + RetSqlName("FKF") + " FKF "
	cCond += " ON ( FKF.FKF_FILIAL = '" + xFilial("FKF") + "'"
	cCond += " AND  FKF.FKF_IDDOC = FK7.FK7_IDDOC AND FKF.D_E_L_E_T_ = ' ' ) "
	
	If __lTemFKJ
		cCond += " LEFT JOIN " + RetSqlName("FKJ") + " FKJ "
		cCond += " ON ( FKJ.FKJ_FILIAL = '" + xFilial("FKJ") + "'"
		cCond += " AND  FKJ.FKJ_COD = A2_COD AND FKJ_LOJA = A2_LOJA AND FKJ.D_E_L_E_T_ = ' ' ) "
	EndIf
	
	cQuery += cCond
	cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
	cQuery += "	AND SE2.D_E_L_E_T_ = ' ' "

	// Abaixo as vezes atualizo apenas a cQuery porque a vari�vel cCampos ser� utilizada no UNION e nem todas as condi��es devem ser aplicadas nesse caso.
	If !Empty(dDataPgDe) .And. !Empty(dDataPgAte)
		
		If nTpPgEmis == 1
			cQuery += "AND ( SE2.E2_EMIS1 >= '" + Dtos(dDataPgDe ) + "' AND SE2.E2_EMIS1 <= '" + Dtos(dDataPgAte) + "')  "
		ElseIf nTpPgEmis == 2
			cQuery += "AND ( SE2.E2_EMISSAO >= '" + Dtos(dDataPgDe) + "' AND SE2.E2_EMISSAO <= '" + Dtos(dDataPgAte) + "')   "
		EndIf	
	EndIf

	cCamposFim := " AND SE2.E2_TIPO NOT IN " + FormatIn(MVABATIM+"|"+MVPROVIS+"|"+MV_CPNEG+"|"+MVIRABT+"|"+MVCSABT+"|"+MVCFABT+"|"+MVPIABT+"|"+MVISS+"|"+ MVTAXA+"|"+MVTXA+"|"+MVINSS+"|"+"SES","|")  + "  "	
	cCamposFim += " AND SE2.E2_FILORIG = '" + cFilAnt + "' "	

	cQuery  += cCamposFim

	If __lDicAtu .and. __lVerFlag
		cQuery += "AND FKF.FKF_REINF IN ('2',' ') " //Flag de integracao com o TAF
	Endif

	If !Empty(cForDe)
		cQuery += "AND SE2.E2_FORNECE >= '" + cForDe + "' "	
	EndIf

	If !Empty(cForAte)
		cQuery += "AND SE2.E2_FORNECE <= '" + cForAte + "' "	
	EndIf

	If !Empty(cLojaForDe)
		cQuery += "AND SE2.E2_LOJA >= '" + cLojaForDe + "' "	
	EndIf

	If !Empty(cLojaForAte)
		cQuery += "AND SE2.E2_LOJA <= '" + cLojaForAte + "' "	
	EndIf
	
	cQuery += " AND ( "

	//Inicio do filtro dos titulos do legado 1.5 (INSS)
	cQuery += " ( " 	
	If lFiltReinf 
		cQuery += "SA2.A2_TIPO <> 'F' AND" 
	EndIf
	cQuery += " (FKF.FKF_TPSERV != ' ' OR FKF.FKF_TPREPA != ' ' " 	
	cQuery += " OR SE2.E2_ORIGEM IN ('MATA103','MATA100') "		
	cQuery += " ) " 	
	cQuery += " AND SA2.A2_RECINSS = 'S' AND SED.ED_CALCINS = 'S' AND FKF.FKF_ORIINS > 0  "

	/*--------------------------------------------------------------|
	| PE permite regra customizada para o retorno de titulos		|
	| para a REINF, podendo por exemplo trazer titulos com valor	|
	| de INSS zerado.												|
	| Caso contrario segue a regra padrao, de descartar os que		|
	| nao sofreram retencao de INSS									|
	---------------------------------------------------------------*/
	If ExistBlock("F989CPIN")                        			
		cQuery += ExecBlock("F989CPIN",.F.,.F.,{cQuery})
	EndIf	

	cQuery += " ) " 
	//Fim do filtro dos titulos do legado 1.5 (INSS)

	//Inicio do filtro dos titulos do bloco 40 (Reinf 2.1.1) - Verifica se o titulo tem registros na FKW
	If __lDicAtu
		cQuery += " OR ( "
		cQuery += " EXISTS( "
		cQuery += " SELECT FKW_NATREN FROM " + RetSqlName("FKW") + " FKW "
		cQuery += " WHERE FKW.FKW_FILIAL = FK7.FK7_FILTIT "
		cQuery += " AND FKW.FKW_IDDOC = FK7.FK7_IDDOC "
		cQuery += " AND FKW.FKW_CARTEI = '1' "
		cQuery += " AND FKW.D_E_L_E_T_ = ' ')  "
		cQuery += " ) "
	EndIf
	//Fim do filtro dos titulos do bloco 40 (Reinf 2.1.1)

	cQuery += " ) " 

	/*--------------------------------------------------------------|
	| Adiciona o operador UNION na query acima em busca de t�tulos 	|
	| que foram inclusos em outros periodos, mas que tiveram baixas |
	| durante o intervalo selecionado para extracao.				|
	| Retorna apenas titulos para atender o bloco 40 (REINF 2.1.1)	|
	---------------------------------------------------------------*/
	If __lDicAtu
		cUnion += "UNION "
		cUnion += "SELECT DISTINCT " //Agrupa p/ trazer apenas 1 registro por titulo quando houver mais de uma baixa no periodo
		cUnion += cCampos + cCond
		cUnion += " JOIN " + RetSqlName("FK2") + " FK2 "
		cUnion += " ON FK2.FK2_FILIAL = '" + xFilial("FK2") + "'"
		cUnion += " AND FK2.D_E_L_E_T_ = ' ' "
		cUnion += " AND FK2.FK2_IDDOC = FK7.FK7_IDDOC "
		If __lVerFlag
			cUnion += " AND FK2.FK2_REINF IN ('2',' ') " //Flag de integracao com o TAF
		Endif
		cUnion += " AND FK2.FK2_RECPAG = 'P' "
		cUnion += " AND FK2.FK2_TPDOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE','E2','CH','ES','PA') " 
		cUnion += " AND FK2.FK2_MOTBX NOT IN ('FAT','LIQ','DEV') "
		If !Empty(dDataPgDe) .And. !Empty(dDataPgAte) 
			cUnion += "AND FK2.FK2_DATA >= '" + Dtos(dDataPgDe ) + "' "
			cUnion += "AND FK2.FK2_DATA <= '" + Dtos(dDataPgAte) + "' "
		EndIf
		cUnion += " AND NOT EXISTS( "
		cUnion += " 	SELECT FK2EST.FK2_IDDOC FROM " + RetSqlName("FK2") +" FK2EST"
		cUnion += " 	WHERE FK2EST.FK2_FILIAL = FK2.FK2_FILIAL"
		cUnion += " 	AND FK2EST.FK2_IDDOC = FK2.FK2_IDDOC "
		cUnion += " 	AND FK2EST.FK2_SEQ = FK2.FK2_SEQ "
		cUnion += " 	AND FK2EST.FK2_TPDOC = 'ES' "
		cUnion += " 	AND FK2EST.D_E_L_E_T_ = ' ') "

		cUnion += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
		cUnion += cCamposFim //+ cCondFim

		If !Empty(cForDe)
			cUnion += "AND SE2.E2_FORNECE >= '" + cForDe + "' "	
		EndIf

		If !Empty(cForAte)
			cUnion += "AND SE2.E2_FORNECE <= '" + cForAte + "' "	
		EndIf

		If !Empty(cLojaForDe)
			cUnion += "AND SE2.E2_LOJA >= '" + cLojaForDe + "' "	
		EndIf
		
		If !Empty(cLojaForAte)
			cUnion += "AND SE2.E2_LOJA <= '" + cLojaForAte + "' "	
		EndIf

		cUnion += " AND SE2.D_E_L_E_T_ = ' ' "			

		//Busca na FKW os titulos que possuem vinculo com a natureza de rendimento
		cUnion += " AND EXISTS( "
		cUnion += " SELECT FKW_NATREN from " + RetSqlName("FKW") + " FKW "
		cUnion += " WHERE FKW.FKW_FILIAL = FK7.FK7_FILTIT "
		cUnion += " AND FKW.FKW_IDDOC = FK7.FK7_IDDOC "
		cUnion += " AND FKW.FKW_CARTEI = '1' "
		cUnion += " AND FKW.D_E_L_E_T_ = ' ' )  "

		//Filtra apenas titulos que foram inclusos antes do intervalo de extra��o  
		If !Empty(dDataPgDe)		
			If nTpPgEmis == 1
				cUnion += "AND SE2.E2_EMIS1 < '" + Dtos(dDataPgDe) + "' "
			ElseIf nTpPgEmis == 2
				cUnion += "AND SE2.E2_EMISSAO < '" + Dtos(dDataPgDe) + "' "
			EndIf	
		EndIf
	
		cQuery += cUnion
	
	EndIf

	/*------------------------------------------------------------------|
	| PE recebe a query padrao completa da carteira a pagar, permitindo	|
	| modificacoes nas regras de filtro. Substitui a query padrao		|
	--------------------------------------------------------------------*/
	If ExistBlock("F989CPQY")                        			
		cQuery := ExecBlock("F989CPQY",.F.,.F.,{cQuery})
	EndIf	

	cQuery += cOrdem

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} F989QryRec
Componente que faz a montagem da estrutura da query de t�tulos a pagar,
com base nos par�metros informados.

@param cCampos1 - Colunas da query antes do UNION
@param cCampos2 - Colunas da query ap�s o UNION
@param cOrdem - Colunas que ir�o compor a clausula ORDER BY
@param @cCond - N�o passar. Retornar� por referencia o conteudo do FROM e JOIN's

@return Nil

@author Fabio Casagrande Lima
@since 10/02/2023
/*/
//-------------------------------------------------------------------
Static Function F989QryRec(cCampos1, cCampos2, cOrdem, cCond)

	Local cQuery As Character
	Local cCondIns As Character
	Local cCondAux As Character
	Local cCondIrf As Character

	Default cCampos1 := ""
	Default cCampos2 := ""
	Default cOrdem := ""
	Default cCond := ""

	cCondAux := ""
	cCondIns := ""
	cCondIrf := ""

	cQuery := "SELECT DISTINCT " //Agrupa p/ trazer apenas 1 registro se houver duplicidade
	cQuery += cCampos1

	//Inicio do filtro para obter os titulos a receber do legado REINF 1.5 (INSS)
	cCond := " FROM " + RetSqlName("SE1") + " SE1 "
	cCond += " INNER JOIN "+ RetSqlName("SA1") + " SA1 "
	cCond += " ON (SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
	cCond += " AND SA1.A1_COD = SE1.E1_CLIENTE"
	cCond += " AND SA1.A1_LOJA = SE1.E1_LOJA "
	If nTpEmPessoa = 1 // Pessoa f�sica
		cCond += "AND SA1.A1_PESSOA = 'F'  "
	ElseIf nTpEmPessoa = 2 // Pessoa Juridica
		cCond += "AND SA1.A1_PESSOA = 'J'  "
	ElseIf nTpEmPessoa = 3 // Estrangeiro
		cCond += "AND SA1.A1_PESSOA = 'X'  "
	Else
		cCond += "AND SA1.A1_PESSOA IN ('J', 'F', 'X')  "
	EndIf
	cCond += " AND SA1.D_E_L_E_T_ = ' ' )"

	cCond += " INNER JOIN "+ RetSqlName("SED") + " SED "
	cCond += " ON ( SED.ED_FILIAL = '" + xFilial("SED") + "'"
	cCond += " AND SED.ED_CODIGO = SE1.E1_NATUREZ "
	cCond += " AND SED.D_E_L_E_T_ = ' ' )"

	cCond += " LEFT JOIN " + RetSqlName("FK7") + " FK7 ON ( FK7.FK7_FILIAL = '"+ xFilial("FK7") +"' AND FK7.FK7_ALIAS = 'SE1' AND "
	
	If __lFK7Cpos
		cCond += " FK7.FK7_FILTIT = SE1.E1_FILIAL "
		cCond += " AND FK7.FK7_PREFIX = SE1.E1_PREFIXO"
		cCond += " AND FK7.FK7_NUM = SE1.E1_NUM "	 		
		cCond += " AND FK7.FK7_PARCEL = SE1.E1_PARCELA "	
		cCond += " AND FK7.FK7_TIPO = SE1.E1_TIPO "		
		cCond += " AND FK7.FK7_CLIFOR = SE1.E1_CLIENTE "	
		cCond += " AND FK7.FK7_LOJA = SE1.E1_LOJA "			
	Else
		cCond += " FK7.FK7_CHAVE = "
		If cBDname $ "MYSQL|POSTGRES"
			cCond += "CONCAT( "
		EndIf
		cCond += " SE1.E1_FILIAL "+ cConcat + " '|' " + cConcat
		cCond += " SE1.E1_PREFIXO "+ cConcat + " '|' " + cConcat
		cCond += " SE1.E1_NUM "+ cConcat + " '|' " + cConcat
		cCond += " SE1.E1_PARCELA "+ cConcat + " '|' " + cConcat
		cCond += " SE1.E1_TIPO "+ cConcat + " '|' " + cConcat
		cCond += " SE1.E1_CLIENTE "+ cConcat + " '|' " + cConcat
		cCond += " SE1.E1_LOJA "
		If cBDname $ "MYSQL|POSTGRES"
			cCond += ") "
		EndIf
	Endif

	cCond += " AND FK7.D_E_L_E_T_ = ' ') "
	cCond += " LEFT JOIN " + RetSqlName("FKF") + " FKF "
	cCond += " ON ( FKF.FKF_FILIAL = '" + xFilial("FKF") + "' AND"
	cCond += " FKF.FKF_IDDOC = FK7.FK7_IDDOC AND FKF.D_E_L_E_T_ = ' ' ) "
	
	If !Empty(dDataEmDe) .And. !Empty(dDataEmAte)
		If nTpEmData == 1
			cCondAux += "AND  ( SE1.E1_EMIS1 >= '" + Dtos(dDataEmDe) + "' AND SE1.E1_EMIS1 <= '" + Dtos(dDataEmAte) + "') "
		ElseIf nTpEmData == 2
			cCondAux += "AND  ( SE1.E1_EMISSAO >= '" + Dtos(dDataEmDe) + "' AND SE1.E1_EMISSAO <= '" + Dtos(dDataEmAte) + "') "
		EndIf
	EndIf
	cCondAux += " AND SE1.D_E_L_E_T_ = ' ' "
	If __lDicAtu .and. __lVerFlag
		cCondAux += " AND FKF.FKF_REINF IN ('2',' ') " //Flag de integracao com o TAF
	Endif		
	cCondAux += " AND SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM+"|"+MV_CRNEG +"|" +MVPROVIS+"|"+MVRECANT+"|"+MV_CPNEG+ "|"+ MVTAXA+"|"+MVTXA+"|"+MVINSS+"|"+"SES","|")  + " "
	cCondAux += " AND SE1.E1_FILORIG = '" + cFilAnt + "' "
	cCondAux += " AND SE1.E1_FATURA NOT IN ('NOTFAT') " // desconsidera titulos fatura
	cCondAux += " AND SE1.E1_NUMLIQ = ' ' " // desconsidera titulos liquidados
	
	If !Empty(cCliDe)
		cCondAux += "AND SE1.E1_CLIENTE >= '" + cCliDe + "' "	
	EndIf
	If !Empty(cCliAte)
		cCondAux += "AND SE1.E1_CLIENTE <= '" + cCliAte + "' "	
	EndIf

	If !Empty(cLojaCliDe)
		cCondAux += "AND SE1.E1_LOJA >= '" + cLojaCliDe + "' "	
	EndIf
	If !Empty(cLojaCliAte)
		cCondAux += "AND SE1.E1_LOJA <= '" + cLojaCliAte + "' "	
	EndIf
	
	cCondIns += " AND ( "
	cCondIns += " (FKF.FKF_TPSERV != ' ' OR FKF.FKF_TPREPA != ' ' "
	cCondIns += " OR SE1.E1_ORIGEM IN ('MATA461','MATA460','MATA103','MATA100') "
	cCondIns += " ) "
		
	cQuery += cCond + " WHERE E1_FILIAL = '" + xFilial("SE1") + "' " + cCondAux

	/*--------------------------------------------------------------|
	| PE permite regra customizada para o retorno de titulos		|
	| para a REINF, podendo por exemplo trazer titulos com valor	|
	| de INSS zerado.												|
	| Caso contrario segue a regra padrao, de descartar os que		|
	| nao sofreram retencao de INSS									|
	---------------------------------------------------------------*/	                           
	If ExistBlock("F989CRIN")                        			
	 	cCondIns += ExecBlock("F989CRIN",.F.,.F., {cQuery})
	Else
		cCondIns += "AND ((SA1.A1_RECINSS = 'S' AND SED.ED_CALCINS = 'S') OR SE1.E1_INSS > 0)  " // se recolhe INSS
	EndIf

	cCondIns += ") "

	cQuery += cCondIns
	//Fim do filtro dos titulos do legado REINF 1.5 (INSS)	
	
	If __lDicAtu
		//Inicio da query (union) para obter os titulos do evento 4080 (Reinf 2.1.1)
		cCondIrf += " UNION "
		cCondIrf += " SELECT DISTINCT " //Agrupa p/ trazer apenas 1 registro se houver duplicidade
		cCondIrf += cCampos2 + cCond + " WHERE E1_FILIAL = '" + xFilial("SE1") + "' " + cCondAux
		cCondIrf += " AND EXISTS( "
		cCondIrf += " SELECT FKW_NATREN FROM " + RetSqlName("FKW") + " FKW "
		cCondIrf += " WHERE FKW.FKW_FILIAL = FK7.FK7_FILTIT "
		cCondIrf += " AND FKW.FKW_IDDOC = FK7.FK7_IDDOC "
		cCondIrf += " AND FKW.FKW_CARTEI = '2' "
		cCondIrf += " AND FKW.D_E_L_E_T_ = ' ') "
		cQuery += cCondIrf
		//Fim do filtro dos titulos do bloco 40 (Reinf 2.1.1)
	EndIf

	/*----------------------------------------------------------|
	| PE recebe a query padrao completa da carteira a receber, 	|
	| permitindo modificacoes nas regras de filtro. 			|
	| Substitui a query padrao.									|		
	-----------------------------------------------------------*/
	If ExistBlock("F989CRQY")                        			
		cQuery := ExecBlock("F989CRQY",.F.,.F.,{cQuery})
	EndIf	

	cQuery += cOrdem

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} F989DepPen
Quando houver dedu��o do IRPF por dependentes ou pens�o alimenticia,
essa fun��o retornar� o detalhamento das dedu��es para cada dependente

@param aDepPen - Array com os dados dos dependentes e valor da dedu��o
@param cIdDoc  - ID do titulo (FK7)
@param cForn   - Codigo do fornecedor
@param cLoja   - Codigo da loja do fornecedor
@param cTipDed - Tipo da dedu��o: 1=Pens�o Alimenticia / 2=Dependente
@param lSusp   - Indentifica se dedu��o foi suspensa por um processo adm/juridico

@return Nil

@author fabio.casagrande
@since 15/03/2023
/*/
//-------------------------------------------------------------------
Static Function F989DepPen(aDepPen As Array, cIdDoc As Char, cForn As Char, cLoja As Char, cTipDed As Char, lSusp As Logical)

	Local aAreaFKG As Array
	Local cQuery As Char
	Local cDepCPF As Char
	Local cLayout As Char

	Default aDepPen := {}
	Default cIdDoc := "" 
	Default cForn := "" 
	Default cLoja := "" 
	Default cTipDed	:= "1"
	Default lSusp := .F.

	If lSusp
		cLayout := "T154AM"
	Else
		cLayout := "T154AK"
	Endif

	aAreaFKG := FKG->( GetArea() )

	DbSelectArea("FKG")
	FKG->(DBSetOrder(2)) //FKG_FILIAL+FKG_IDDOC+FKG_TPIMP

	//Verifica se o titulo tem complemento de imposto na tabela FKG
	If FKG->( MsSeek( xFilial("FKG") + cIdDoc ) )
		While FKG->( !Eof() ) .And. Alltrim( FKG->( FKG_FILIAL + FKG_IDDOC ) ) == Alltrim( xFilial("FKG") + cIdDoc )
			If !Empty(FKG->FKG_CODDEP) .And. ((cTipDed == "1" .And. FKG->FKG_TPATRB $ "013   ") .Or. (cTipDed == "2" .And. FKG->FKG_TPATRB $ "024   "))
				
				If __oQryDHT == NIL
					cQuery	:= " SELECT DHT_CPF "
					cQuery	+= " FROM " + RetSQLName("DHT") + " DHT "
					cQuery	+= " WHERE DHT.DHT_FILIAL = ? "
					cQuery	+= " AND DHT.DHT_FORN = ? "
					cQuery	+= " AND DHT.DHT_LOJA = ? "
					cQuery	+= " AND DHT.DHT_COD = ? "
					cQuery	+= " AND DHT.D_E_L_E_T_ = ' ' "

					cQuery := ChangeQuery( cQuery )
					__oQryDHT := FWPreparedStatement():New( cQuery )
				EndIf

				__oQryDHT:SetString( 1, xFilial("DHT", cFilAnt))
				__oQryDHT:SetString( 2, cForn)
				__oQryDHT:SetString( 3, cLoja)
				__oQryDHT:SetString( 4, FKG->FKG_CODDEP )
				cQuery := __oQryDHT:GetFixQuery()

				cDepCPF := MpSysExecScalar( cQuery, "DHT_CPF" )

				If !Empty(cDepCPF)
					AAdd( aDepPen, { cLayout, cDepCPF, FKG->FKG_VALOR } )	
				Endif
			Endif
			FKG->( DbSkip() )
		EndDo
	Endif

	RestArea(aAreaFKG)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FFrstTime
Verifica se a Dedu��o do fornecedor � a primeira do per�odo

@param cFornec, Character, C�digo + Loja do fornecedor posicionado
@param dData  , Date, Data do fato gerador do IRPF
@param lDetDed, Logical, .T. para qdo a verifica��o � do registro
	de detalh. dependentes
@param cIdDoc, Character, ID do t�tulo

@return lRet - retorna .T. se o CPF � de outro participante

@author Rodrigo Oliveira
@since 31/01/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function FFrstTime(cFornec As Char, dData As Date, lDetDed As Logical, cIdDoc As Char) As Logical
	Local lRet		As Logical
	Local cQry		As Char
	Local cQryAux	As Char
	Local cQryU		As Char
	Local cAlsDed	As Char

	Private cRet	As Char
	
	Default cFornec := ""
	Default dData	:= CTOD("  /  /  ")
	Default lDetDed	:= .F.
	Default cIdDoc	:= ""

	cAlsDed		:= ""
	cRet		:= ""

	lRet	:= .F.

	If __oHashDed == Nil
		__oHashDed	:= tHashMap():New()
	EndIf

	If !Empty(cFornec) .And. !Empty(dData)
		If !HMGet(__oHashDed,cFornec,@cRet)
			
			cAlsDed	:= GetNextAlias()
			
			If __oQryDed == Nil
				cQry := " Select E2_NUM NUM"
				cQry += " From " + RetSqlName("SE2") + " SE2"
				cQry += " Inner Join " + RetSqlName("SA2") + " SA2"
				cQry += " On A2_FILIAL = ?"
				cQry += " And E2_FORNECE = A2_COD"
				cQry += " And E2_LOJA = A2_LOJA"
				cQry += " And ( ( ( A2_CALCIRF = '1' AND E2_IRRF > 0 ) OR ( A2_CALCIRF = '2') ) AND"

				cQryU	:= cQry
				If nTpEmData == 1
					cQry	+= " E2_EMIS1 < ? AND"
					cQryAux	:= " SUBSTRING(E2_EMIS1,1,6) = ? )"
				Else
					cQry 	+= " E2_EMISSAO < ? AND"
					cQryAux := " SUBSTRING(E2_EMISSAO,1,6) = ? )"
				EndIf
				cQryAux += " And SA2.D_E_L_E_T_ = ' '"
				cCnd	:= " INNER JOIN " + RetSqlName("SED") + " SED"
				cCnd 	+= " ON ED_FILIAL = ? AND ED_CODIGO = E2_NATUREZ AND ED_CALCIRF = 'S' AND ED_PERCIRF > 0 AND"
				cCnd 	+= " SED.D_E_L_E_T_ = ' '"
				cCnd 	+= " Where E2_FILIAL = ?"
				cCnd 	+= " And E2_FORNECE = ?"
				cCnd 	+= " And E2_LOJA = ?"
				cCnd 	+= " And SE2.D_E_L_E_T_ = ' '"

				cQry	+= cQryAux + cCnd
				cQry	+= " UNION"
				cQry	+= cQryU + cQryAux
				cQry 	+= " INNER JOIN " + RetSqlName("FK7") + " FK7 "
				cQry 	+= "   ON ( FK7.FK7_FILIAL = ?"
				cQry 	+= "   AND FK7.FK7_ALIAS = 'SE2' AND "

				If __lFK7Cpos
					cQry += " FK7.FK7_FILTIT = SE2.E2_FILIAL "
					cQry += " AND FK7.FK7_PREFIX = SE2.E2_PREFIXO "
					cQry += " AND FK7.FK7_NUM = SE2.E2_NUM "	 		
					cQry += " AND FK7.FK7_PARCEL = SE2.E2_PARCELA "	
					cQry += " AND FK7.FK7_TIPO = SE2.E2_TIPO "		
					cQry += " AND FK7.FK7_CLIFOR = SE2.E2_FORNECE "	
					cQry += " AND FK7.FK7_LOJA = SE2.E2_LOJA "			
				Else
					cQry += "   FK7.FK7_CHAVE = "
					If cBDname $ "MYSQL|POSTGRES"
						cQry += "CONCAT( "
					EndIf
					cQry += " SE2.E2_FILIAL "  + cConcat + " '|' " + cConcat
					cQry += " SE2.E2_PREFIXO " + cConcat + " '|' " + cConcat
					cQry += " SE2.E2_NUM "	  + cConcat + " '|' " + cConcat
					cQry += " SE2.E2_PARCELA " + cConcat + " '|' " + cConcat
					cQry += " SE2.E2_TIPO "	  + cConcat + " '|' " + cConcat
					cQry += " SE2.E2_FORNECE " + cConcat + " '|' " + cConcat
					cQry += " SE2.E2_LOJA "
					If cBDname $ "MYSQL|POSTGRES"
						cQry += ") "
					EndIf
				EndIf

				cQry 	+= "   AND FK7.D_E_L_E_T_ = ' ' )"
				cQry 	+= " Right Join " + RetSqlName("FKF") + " FKF"
				cQry 	+= " On FKF_IDDOC = FK7_IDDOC AND"
				cQry 	+= " FKF_REINF = '1' AND"
				cQry 	+= " FKF.D_E_L_E_T_ = ' '"
					
				cQry	+= cCnd

				cQry := ChangeQuery( cQry )

				If __lCachQry
					__oQryDed	:= FwExecStatement():New(cQry)
				Else
					__oQryDed	:= FWPreparedStatement():New(cQry)
				EndIf

			EndIf
				
			__oQryDed:SetString(1, xFilial("SA2"))
			__oQryDed:SetString(2, Dtos(dData))
			__oQryDed:SetString(3, SubStr(Dtos(dData), 1, 6))
			__oQryDed:SetString(4, xFilial("SED"))
			__oQryDed:SetString(5, xFilial("SE2"))
			__oQryDed:SetString(6, Left(cFornec, nTamE2For) )
			__oQryDed:SetString(7, Right(cFornec, nTamE2Lj) )
			__oQryDed:SetString(8, xFilial("SA2"))
			__oQryDed:SetString(9, SubStr(Dtos(dData), 1, 6))
			__oQryDed:SetString(10, xFilial("FK7"))
			__oQryDed:SetString(11, xFilial("SED"))
			__oQryDed:SetString(12, xFilial("SE2"))
			__oQryDed:SetString(13, Left(cFornec, nTamE2For) )
			__oQryDed:SetString(14, Right(cFornec, nTamE2Lj) )
				
			cQry 	:= __oQryDed:GetFixQuery()
			cAlsDed := MpSysOpenQuery(cQry)

			__oHashDed:Set( cFornec, cRet := "")
			
			If Empty((cAlsDed)->NUM)
				lRet	:= .T.
			EndIf
			(cAlsDed)->(DbCloseArea())
		Else
			If !lDetDed
				If !Empty(cRet) .And. cRet == cIdDoc
					lRet := .T.
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet
