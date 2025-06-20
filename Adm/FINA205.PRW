#Include "PROTHEUS.CH"
#Include "AP5MAIL.CH"
#include "FINA205.ch"

#DEFINE SIGAFIN		6

Static __lDirPag	:= Nil
Static __lDirRec	:= Nil

/*/{Protheus.doc} FINA205
Retorno da comunica��o banc�ria via Job (Receber)
@type function
@version 12
@author totvs
@since 03/02/2023
@param aParam, array, par�metros
/*/
Function FINA205(aParam As Array)
	Local nCntFor    As Numeric
	Local lLicencUso As Logical

	// Executa apenas se for chamado pelo Schedule
	// a variavel abaixo e util para debug da rotina via execucao normal
	Private lExecJob  := .F.
	Private aMsgSch   := {}
	Private aFA205R   := {}
	Private cCadastro := STR0001 // "Retorno Bancario Automatico (Receber)"
 
	//Valida a licen�a do m�dulo
	lLicencUso := VldLicenca()

	If lLicencUso

		ConOut("*** INICIO >> "+cCadastro+Dtoc(Date())+" "+Time())

		if Valtype(aParam) <> "A" 
			ConOut("*** "+STR0002) // "Processo pode ser executado apenas via Schedule"
			Return Nil
		Endif

		// ao passar parametros considera que foi chamado pelo schedule
		lExecJob := .T.

		// manter posicionado pois o FINA200 vai utilizar estas informacoes
		if Valtype(aParam) == "A"
			RpcSetEnv(aParam[1], aParam[2], Nil, Nil, Nil, "FINA200")
		Endif

		If  LockByName( "FINA205", .T., .T. )

			BatchProcess(cCadastro, cCadastro , "FA205JOB" , { || FA205JOB() } , { || .F. } )

			// se o parametro nao esta definido, envia as mensagens para o console
			If Empty(GetMv("MV_RETMAIL",, "")) .and. Len(aMsgSch) > 0
				For nCntFor := 1 to Len(aMsgSch)
					ConOut(aMsgSch[nCntFor])
				Next
			EndIf
		Else
			ConOut(STR0030+cFilant+STR0031) //"Retorno de Recebimentos da Filial " ## " est� executando em outra thread "
		EndIf

		ConOut("*** "+STR0003+"   >> "+cCadastro+Dtoc(Date())+" "+Time()) // FIM

	EndIf

Return Nil



/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � FA205JOB � Autor � Aldo Barbosa dos Santos� Data � 15/05/11 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Retorno da comunica��o banc�ria via Job                     ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � FA205JOB()                                                  ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                    ���
��������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS                                          ���
��������������������������������������������������������������������������Ĵ��
���           	�  /  /  �      �                                           ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function FA205JOB()
	Local cPerg	    := Padr("AFI200", Len(SX1->X1_GRUPO))
	Local cQuery    := "" // query de bancos que serao executados automaticamente
	Local cAliasSEE := "" // alias temporario dos banco que serao executados
	Local nA        := 0
	Local nC        := 0
	Local aVetArqs 	:= {}
	Local aArq		:= {}
	Local cDirInc 	:= ""
	Local cLocRec 	:= SuperGetMV( "MV_LOCREC" , .F. , " " )
	Local lBarra    := isSrvUnix()
	Local nArquivo  := 0
	Local cRetorno  := ""
	Local aParam650 := {}
	Local aParam200 := {}
	
	DbSelectArea("SA6")
	DbSelectArea("SEE")
	SA6->( Dbsetorder(1))
	SEE->( Dbsetorder(1))

	If __lDirPag == Nil
		__lDirPag	:= SEE->(ColumnPos("EE_INCPAG")) > 0
	EndIf

	If __lDirRec == Nil
		__lDirRec	:= SEE->(ColumnPos("EE_INCREC")) > 0
	EndIf
	
	//le as perguntas do FINA200 que serao modificadas de acordo com os novos campos da tabela de bancos
	//Pergunte(cPergunta,lAsk,cTitle,lOnlyView,oDlg,lUseProf,aPerg,lBreakLine,lHasHelp)
	Pergunte(cPerg,    .F., Nil,    Nil,     Nil, .F.)
	
	//Contas programadas para recebimento automatico ou ambos
	cQuery := "SELECT R_E_C_N_O_ REGSEE FROM " + RetSqlName("SEE") + " SEE "
	cQuery += "WHERE EE_FILIAL = '" + xFilial("SEE") + "' "
	cQuery += "AND EE_RETAUT IN ('1','3') AND SEE.D_E_L_E_T_ = ' ' ORDER BY EE_DIRREC "
	
	cAliasSEE := GetNextAlias()
	DbUseArea(.T., 'TOPCONN', TCGENQRY(Nil, Nil, cQuery), cAliasSEE, .T.,.T.)
	
	Do While (cAliasSEE)->(!Eof())
		Aadd(aVetArqs, (cAliasSEE)->REGSEE )
		(cAliasSEE)->( Dbskip())
	Enddo
	
	(cAliasSEE)->(DbcloseArea())
	
	For nC := 1 to Len(aVetArqs)
		SEE->(Dbgoto(aVetArqs[nC]))		
		
		//verifica se todos os parametros necessarios foram preechindos e grava no log
		If (!SEE->EE_RETAUT $ "123" .Or. FA205ERRO())
			Loop
		Endif
		
		//L� os arquivos do diretorio configurado
		If lBarra
			cDirArq := StrTran(Alltrim(SEE->EE_DIRREC), "\", "/")
			cDirBk  := StrTran(Alltrim(SEE->EE_BKPREC), "\", "/")
			cLocRec := StrTran(cLocRec, "\", "/")
		Else
			cDirArq := StrTran(Alltrim(SEE->EE_DIRREC), "/", "\")
			cDirBk  := StrTran(Alltrim(SEE->EE_BKPREC), "/", "\")
			cLocRec := StrTran(cLocRec, "/", "\")
		Endif
		
		If __lDirRec
			cDirInc := Alltrim(SEE->EE_INCREC)
		Endif
		
		If (Empty(cLocRec) .And. !Empty(cDirArq)) .Or. (!Empty(cLocRec) .And. !Empty(cDirArq))
			aArq := Directory(cDirArq + "*." + SEE->EE_EXTEN)
		ElseIf Empty(cLocRec)
			aArq := Directory("*." + SEE->EE_EXTEN, "S")
		Else
			aArq := Directory(cLocRec + "*." + SEE->EE_EXTEN, "S")
		EndIf
		
		If (nArquivo := Len(aArq)) > 0			
			For nA := 1 to nArquivo
				//Armazena o nome do arquivo nos parametros
				cRetorno := cDirArq+aArq[nA,1]
				
				//Perguntes F12 do FINR650 conforme os dados do arquivo de bancos
				aParam650 := {;
				{"mv_par01", cRetorno},;           //01 = Arquivo de Entrada ?
				{"mv_par02", SEE->EE_CFGREC},;     //02 = Arquivo de Config ?
				{"mv_par03", SEE->EE_CODIGO},;     //03 = Codigo do Banco ?
				{"mv_par04", SEE->EE_AGENCIA},;    //04 = Codigo da Agencia ?
				{"mv_par05", SEE->EE_CONTA},;      //05 = Codigo da Conta ?
				{"mv_par06", SEE->EE_SUBCTA},;     //06 = Codigo da SubConta ?
				{"mv_par07", 1},;                  //07 = Carteira ?  1=Receber;2=Pagar
				{"mv_par08", Val(SEE->EE_CNABRC)}} //08 = Configuracao CNAB ?				
				
				//Controle de mensagens de erro
				aMsgSch := {}
				
				//controle de titulos baixados
				aFA205R := {}
				ProcLogAtu("INICIO",STR0001+" - "+STR0004+cRetorno) // "Retorno Bancario Automatico (Receber)" # "Arquivo:"
				SaveInter()
				
				//Executa a consistencia antes de executar o recebimento
				FINR650(aParam650)
				
				//Pergunte do FINA200 de acordo com a tabela de bancos valor atual valor novo
				aParam200 := {;
				{"mv_par01", 2},;                   //01 = Mostra Lanc Contab ?
				{"mv_par02", Val(SEE->EE_AGLCTB)},; //02 = Aglut Lancamentos ?
				{"mv_par03", SEE->EE_ATUMOE},;      //03 = Atualiza Moedas por ?
				{"mv_par04", cRetorno},;            //04 = Arquivo de Entrada ?
				{"mv_par05", SEE->EE_CFGREC},;      //05 = Arquivo de Config ?
				{"mv_par06", SEE->EE_CODIGO},;      //06 = Codigo do Banco ?
				{"mv_par07", SEE->EE_AGENCIA},;     //07 = Codigo da Agencia ?
				{"mv_par08", SEE->EE_CONTA},;       //08 = Codigo da Conta ?
				{"mv_par09", SEE->EE_SUBCTA},;      //09 = Codigo da Sub-Conta ?
				{"mv_par10", Val(SEE->EE_DESCOM)},; //10 = Abate Desc Comissao ?
				{"mv_par11", 2},;                   //11 = Contabiliza On Line ?
				{"mv_par12", Val(SEE->EE_CNABRC)},; //12 = Configuracao CNAB ?
				{"mv_par13", Val(SEE->EE_PROCFL)},; //13 = Processa Filial?
				{"mv_par14", Val(SEE->EE_CTBTRF)},; //14 = Contabiliza Transferencia ?
				{"mv_par15", Val(SEE->EE_RETBCO)}}  //15 = Considera Dias de Retencao ?
				
				//Executa a rotina de recebimento
				FINA200(Nil, aParam200)
				
				FA205MAIL(STR0001, cRetorno, aMsgSch) //Retorno Bancario Automatico (Receber)
				RestInter()
				
				If Len(aMsgSch) == 0 .OR. Substr(aMsgSch[1],1,46) == STR0027
					cArq := aArq[nA,1]
					
					If !_CopyFile(cRetorno, cDirBk+cArq) //copia o arquivo para o diretorio de backup
						Aadd(aMsgSch, STR0021+cRetorno+STR0022+cDirBk+STR0023)
					Else
						Ferase(cRetorno)
						if File(cRetorno)
							Aadd(aMsgSch,STR0024+cRetorno+STR0025+cDirBk)
						Endif
					Endif
				ElseIf __lDirRec					
					cArq := aArq[nA,1]
					
					If !_CopyFile(cRetorno, cDirInc+cArq) //copia o arquivo para o diretorio de Inconsistencia.
						Aadd(aMsgSch, STR0021+cRetorno+STR0022+cDirInc+STR0023)
					Else
						Aadd(aMsgSch, STR0004+cRetorno+STR0028+cDirInc+STR0029)
						Ferase(cRetorno)
						
						If File(cRetorno)
							Aadd(aMsgSch,STR0024+cRetorno+STR0025+cDirInc)
						Endif
					Endif	
				Endif
				
				ProcLogAtu("FIM",STR0001+" - "+STR0004+cRetorno) //Retorno Bancario Automatico (Receber) # "Arquivo:"
				Sleep(3000)
			Next nArquivo
		EndIf
	Next
	
	FwFreeArray(aVetArqs)
	FwFreeArray(aArq)
	FwFreeArray(aParam650)
	FwFreeArray(aParam200)
Return

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �FA205VLD  �Autor  � Aldo Barbosa dos Santos � Data � 06/06/11 ���
���������������������������������������������������������������������������͹��
���Desc.     � Valida os campos relativos ao processo automatico via Job    ���
���������������������������������������������������������������������������͹��
���Uso       � FINA200/FINA205                                              ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function FA205VLD(cCampo, cDado, lMsg)
Local lRet   		:= .T.
Local cMsg   		:= ""
Local cIncPag		:= Alltrim(M->EE_INCPAG)
Local cIncRec		:= Alltrim(M->EE_INCREC)

Default lMsg := .T.


If __lDirPag == Nil		
	__lDirPag	:= SEE->(ColumnPos("EE_INCPAG")) > 0
EndIf

If __lDirRec == Nil		
	__lDirRec	:= SEE->(ColumnPos("EE_INCREC")) > 0
EndIf

If cCampo == "EE_RETAUT"
	If cDado $ '0123'
		If cDado $ '01'
			M->EE_DIRPAG := Space(Len(M->EE_DIRPAG))
			M->EE_CFGPAG := Space(Len(M->EE_CFGPAG))
			M->EE_BKPPAG := Space(Len(M->EE_BKPPAG))
			M->EE_CNABPG := Space(Len(M->EE_CNABPG))
			If __lDirPag
				M->EE_INCPAG :=	Space(Len(M->EE_INCPAG))
			EndIf
   		EndIf

		If cDado $ '02'
			M->EE_ATUMOE := Space(Len(M->EE_ATUMOE))
			M->EE_DIRREC := Space(Len(M->EE_DIRREC))
			M->EE_CFGREC := Space(Len(M->EE_CFGREC))
			M->EE_BKPREC := Space(Len(M->EE_BKPREC))
			M->EE_CNABRC := Space(Len(M->EE_CNABRC))
			M->EE_PROCFL := Space(Len(M->EE_PROCFL))
			If __lDirRec
				M->EE_INCREC :=	Space(Len(M->EE_INCREC))
			EndIf
   		EndIf
	EndIf

Elseif cCampo == "EE_AGLCTB"
	if M->EE_RETAUT $ "1;2;3" .and. ! cDado $ '0123'
		cMsg := STR0005 // "Quando o retorno automatico de Recebimento, Pagamento ou Ambos for selecionado, este campo e obrigatorio"
		lRet := .F.
	Endif
Elseif cCampo == "EE_ATUMOE"
	if M->EE_RETAUT $ "1;3" .and. ! cDado $ '123'
		cMsg := STR0006 // "Quando o retorno automatico de Recebimento ou Ambos for selecionado, este campo e obrigatorio"
		lRet := .F.
	Endif
Elseif cCampo == "EE_DIRPAG"
	if M->EE_RETAUT $ "2;3"
		if Empty(cDado)
			cMsg := STR0007 // "Quando o retorno automatico de Pagamento ou Ambos for selecionado, este campo e obrigatorio"
			lRet := .F.
		Else
			M->EE_DIRPAG := Padr(Alltrim(M->EE_DIRPAG)+if(Right(Alltrim(M->EE_DIRPAG),1)=="\","","\"),Len(SEE->EE_DIRPAG))
			if Len(Directory(Alltrim(M->EE_DIRPAG)+"*.*","D")) <= 0 .And. !VldPFSDir("EE_DIRPAG", M->EE_DIRPAG)
				cMsg := STR0008 // "Diretorio de retorno automatico de Pagamento nao encontrado. Especifique um diretorio existente e tente novamente."
				lRet := .F.
			Else
				if ! ChkDiret("EE_DIRPAG", M->EE_DIRPAG)
					cMsg := 	STR0018 // "Todos os diretorios utilizados devem ser diferentes."
					lRet := .F.
				Else				
					if ! FA205DIR('EE_DIRPAG',M->EE_DIRPAG)
						cMsg := STR0009 // "O diretorio especificado ja esta em uso em outro banco. Especifique um diretorio ainda nao usado e tente novamente."
						lRet := .F.
					Endif
				Endif	
			Endif
		Endif
	Endif
Elseif cCampo == "EE_DIRREC"
	if M->EE_RETAUT $ "1;3"
		if Empty(cDado)
			cMsg := STR0006 // "Quando o retorno automatico de Recebimento ou Ambos for selecionado, este campo � obrigatorio"
			lRet := .F.
		Else
			M->EE_DIRREC := Padr(Alltrim(M->EE_DIRREC)+if(Right(Alltrim(M->EE_DIRREC),1)=="\","","\"),Len(SEE->EE_DIRREC))
			if Len(Directory(Alltrim(M->EE_DIRREC)+"*.*","D")) <= 0 .And. !VldPFSDir("EE_DIRREC", M->EE_DIRREC)
				cMsg := STR0011 // "Diretorio de retorno automatico de Recebimento nao encontrado. Especifique um diretorio existente e tente novamente."
				lRet := .F.
			Else
				if ! ChkDiret("EE_DIRREC", M->EE_DIRREC)
					cMsg := 	STR0018 // "Todos os diretorios utilizados devem ser diferentes."
					lRet := .F.
				Else	
					if ! FA205DIR('EE_DIRREC',M->EE_DIRREC)
						cMsg := STR0009 // "O diretorio especificado j� est� em uso em outro banco. Especifique um diretorio ainda nao usado e tente novamente."
						lRet := .F.
					Endif
				Endif
			EndIf
		Endif
	Endif
Elseif cCampo == "EE_CFGPAG"
	if M->EE_RETAUT $ "2;3" .and. Empty(cDado)
		cMsg := STR0007 // "Quando o retorno automatico de Pagamento ou Ambos for selecionado, este campo � obrigatorio"
		lRet := .F.
	Endif
Elseif cCampo == "EE_CFGREC"
	if M->EE_RETAUT $ "1;3" .and. Empty(cDado)
		cMsg := STR0006 // "Quando o retorno automatico de Recebimento ou Ambos for selecionado, este campo � obrigatorio"
		lRet := .F.
	Endif
Elseif cCampo == "EE_BKPPAG"
	if M->EE_RETAUT $ "2;3" .and. Empty(cDado)
		cMsg := STR0007 // "Quando o retorno automatico de Pagamento ou Ambos for selecionado, este campo � obrigatorio"
		lRet := .F.
	Else
		M->EE_BKPPAG := Padr(Alltrim(M->EE_BKPPAG)+if(Right(Alltrim(M->EE_BKPPAG),1)=="\","","\"),Len(SEE->EE_BKPPAG))
		if ! ChkDiret("EE_BKPPAG", M->EE_BKPPAG)
			cMsg := 	STR0018 // "Todos os diretorios utilizados devem ser diferentes."
			lRet := .F.
		Else	
			if Len(Directory(Alltrim(M->EE_BKPPAG)+"\*.*","D")) <= 0 .And. !VldPFSDir("EE_BKPPAG", M->EE_BKPPAG)
				cMsg := STR0012 // "Diretorio de backup nao encontrado. Especifique um diretorio existente e tente novamente."
				lRet := .F.
			Endif
		EndIf
   Endif
ElseIf cCampo == "EE_INCPAG"
	If M->EE_RETAUT $ "2;3" .AND. Empty(cDado)
		cMsg := STR0007 
		lRet := .F.
	Else
		M->EE_INCPAG := Padr(cIncPag + Iif(Right(cIncPag,1) == "\","","\"), Len(cIncPag))
		If !ChkDiret("EE_INCPAG", cIncPag)
			cMsg := 	STR0018 
			lRet := .F.
		Else	
			If Len(Directory(cIncPag + "\*.*", "D")) <= 0
				cMsg := STR0012 
				lRet := .F.
			EndIf
		EndIf	
   EndIf
Elseif cCampo == "EE_BKPREC"
	if M->EE_RETAUT $ "1;3" .and. Empty(cDado)
		cMsg := STR0006 // "Quando o retorno automatico de Recebimento ou Ambos for selecionado, este campo � obrigatorio"
		lRet := .F.
	Else
		M->EE_BKPREC := Padr(Alltrim(M->EE_BKPREC)+if(Right(Alltrim(M->EE_BKPREC),1)=="\","","\"),Len(SEE->EE_BKPREC))
		if ! ChkDiret("EE_BKPREC", M->EE_BKPREC)
			cMsg := 	STR0018 // "Todos os diretorios utilizados devem ser diferentes."
			lRet := .F.
		Else
			if Len(Directory(Alltrim(M->EE_BKPREC)+"\*.*","D")) <= 0 .And. !VldPFSDir("EE_BKPREC", M->EE_BKPREC)
				cMsg := STR0012 // "Diretorio de backup nao encontrado. Especifique um diretorio existente e tente novamente."
				lRet := .F.
			Endif
		Endif
   Endif
ElseIf cCampo == "EE_INCREC"
	If M->EE_RETAUT $ "1;3" .AND. Empty(cDado)
		cMsg := STR0006 
		lRet := .F.
	Else
		M->EE_INCREC := Padr(cIncRec + Iif(Right(cIncRec,1) == "\","","\"), Len(cIncRec))
		If !ChkDiret("EE_INCREC", cIncRec)
			cMsg := 	STR0018 
			lRet := .F.
		Else
			If Len(Directory(cIncRec + "\*.*","D")) <= 0
				cMsg := STR0012 
				lRet := .F.
			EndIf
		EndIf
   EndIf
Elseif cCampo == "EE_DESCOM"
	if M->EE_RETAUT $ "1;3" .and. Empty(cDado)
		cMsg := STR0006 // "Quando o retorno automatico de Recebimento ou Ambos for selecionado, este campo � obrigatorio"
		lRet := .F.
	Endif
Elseif cCampo == "EE_CNABPG"
	if M->EE_RETAUT $ "2;3" .and. Empty(cDado)
		cMsg := STR0006 // "Quando o retorno automatico de Pagamento ou Ambos for selecionado, este campo � obrigatorio"
		lRet := .F.
	Endif
Elseif cCampo == "EE_CNABRC"
	if M->EE_RETAUT $ "1;3" .and. Empty(cDado)
		cMsg := STR0006 // "Quando o retorno automatico de Recebimento ou Ambos for selecionado, este campo � obrigatorio"
		lRet := .F.
	Endif
Elseif cCampo == "EE_PROCFL"
	if M->EE_RETAUT $ "1;2;3" .and. Empty(cDado)
		cMsg := STR0005 // "Quando o retorno automatico de Recebimento, Pagamento ou Ambos for selecionado, este campo � obrigatorio"
		lRet := .F.
	Endif
Elseif cCampo == "EE_MULTNT"
	if M->EE_RETAUT $ "2;3" .and. Empty(cDado)
		cMsg := STR0007 // "Quando o retorno automatico de Pagamento ou Ambos for selecionado, este campo � obrigatorio"
		lRet := .F.
	Endif
Endif

if lMsg .and. ! lRet .and. ! Empty(cMsg)
	Aviso("ATENCAO",cMsg,{"Ok"})
Endif

Return( lRet )


/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �ChkDiret  �Autor  � Aldo Barbosa dos Santos � Data � 28/10/11 ���
���������������������������������������������������������������������������͹��
���Desc.     � Valida se todos os diretorios informados sao diferentes      ���
���������������������������������������������������������������������������͹��
���Uso       � FINA200/FINA205                                              ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function ChkDiret(cCampo, cConteudo)
Local aCpo := 	{{"EE_DIRPAG",Alltrim(Upper(M->EE_DIRPAG))},;
		         {"EE_DIRREC",Alltrim(Upper(M->EE_DIRREC))},;
		         {"EE_BKPPAG",Alltrim(Upper(M->EE_BKPPAG))},;
		         {"EE_BKPREC",Alltrim(Upper(M->EE_BKPREC))}}
Local lRet := .T.
Local nElem, nA

If __lDirPag == Nil		
	__lDirPag	:= SEE->(ColumnPos("EE_INCPAG")) > 0
EndIf

If __lDirRec == Nil		
	__lDirRec	:= SEE->(ColumnPos("EE_INCREC")) > 0
EndIf

If __lDirPag
	Aadd(aCpo, {"EE_INCPAG",Alltrim(Upper(M->EE_INCPAG))})
EndIf

If __lDirRec
	Aadd(aCpo, {"EE_INCREC",Alltrim(Upper(M->EE_INCREC))})
EndIf

cConteudo := Alltrim(Upper(cConteudo))

nElem := Ascan(aCpo,{|e| e[1] == cCampo})

For nA := 1 to Len(aCpo)
	if nA <> nElem
		if ! Empty(aCpo[nA,2]) .and. cConteudo == aCpo[nA,2]
			lRet := .F.
			Exit
		Endif
	Endif
Next

FwFreeArray(aCpo)

Return( lRet )		   

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �FA205DIR  �Autor  � Aldo Barbosa dos Santos � Data � 06/06/11 ���
���������������������������������������������������������������������������͹��
���Desc.     � Valida os campos relativos ao processo automatico via Job    ���
���������������������������������������������������������������������������͹��
���Uso       � FINA200/FINA205                                              ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function FA205DIR(cCampo, cDado, cRecno) As Logical
	Local cQuery 	As Character 
	Local cAlias  	As Character 
	Local lRet   	As Logical

	cAlias	:= "" // alias temporario dos banco que serao executados
	cQuery 	:= "" // query de bancos que serao executados automaticamente
	lRet   	:= .T.

	if cCampo == "EE_DIRPAG" .or. cCampo == "EE_DIRREC"
		// seleciona todas as contas que estao programadas para recebimento automatico
		cQuery := "SELECT R_E_C_N_O_ AS RECNO "
		cQuery += " FROM "+RetSqlName("SEE")+ " SEE "
		cQuery += "WHERE EE_FILIAL ='"+xFilial("SEE")+"'"
		cQuery += "  AND ( UPPER(EE_DIRREC) = UPPER('"+Alltrim(cDado)+"') "
		cQuery += "  OR UPPER(EE_DIRPAG) = UPPER('"+Alltrim(cDado)+"')) "
		cQuery += "  AND SEE.D_E_L_E_T_ = ' '"
		cAlias := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.T.,.T.)

		lRet := (cAlias)->(EOF())

		If ALTERA .And. !lRet
			lRet := SEE->(Recno()) == (cAlias)->RECNO
		EndIf

		(cAlias)->( DbcloseArea())
	Endif

Return( lRet )



/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �FA205WHN  �Autor  � Aldo Barbosa dos Santos � Data � 06/06/11 ���
���������������������������������������������������������������������������͹��
���Desc.     � Valida os campos relativos ao processo automatico via Job    ���
���������������������������������������������������������������������������͹��
���Uso       � FINA200/FINA205                                              ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function FA205WHN(cCampo, cDado)
Local lRet   := .T.

If cCampo == "EE_AGLCTB"
	lRet := (M->EE_RETAUT$'123')
ElseIf cCampo == "EE_ATUMOE"
	lRet := (M->EE_RETAUT$'13')
ElseIf cCampo == "EE_DIRPAG"
	lRet := (M->EE_RETAUT$'23')
ElseIf cCampo == "EE_DIRREC"
	lRet := (M->EE_RETAUT$'13')
ElseIf cCampo == "EE_CFGPAG"
	lRet := (M->EE_RETAUT$'23')
ElseIf cCampo == "EE_CFGREC"
	lRet := (M->EE_RETAUT$'13')
ElseIf cCampo == "EE_BKPPAG"
	lRet := (M->EE_RETAUT$'23')
ElseIf cCampo == "EE_BKPREC"
	lRet := (M->EE_RETAUT$'13')
ElseIf cCampo == "EE_INCPAG"
	lRet := (M->EE_RETAUT$'23')
ElseIf cCampo == "EE_INCREC"
	lRet := (M->EE_RETAUT$'13')
ElseIf cCampo == "EE_DESCOM"
	lRet := (M->EE_RETAUT$'13')
ElseIf cCampo == "EE_CNABPG"
	lRet := (M->EE_RETAUT$'23'	)
ElseIf cCampo == "EE_CNABRC"
	lRet := (M->EE_RETAUT$'13')
ElseIf cCampo == "EE_PROCFL"
	lRet := (M->EE_RETAUT$'123')
ElseIf cCampo == "EE_CTBTRF"
	lRet := (M->EE_RETAUT$'23')
ElseIf cCampo == "EE_RETBCO"
	lRet := (M->EE_RETAUT$'23')
EndIf

Return( lRet )

/*/{Protheus.doc} FA205MAIL
Prepara os dados para envio de email
@type function
@version 12
@author totvs
@since 03/02/2023
@param cTitulo, character, Titulo
@param cArq, character, Arquivo
@param aMsgSch, array, Mensagens
@param lEnvAtch, logical, Envia anexo
/*/
Function FA205MAIL(cTitulo As Character, cArq As Character, aMsgSch As Array, lEnvAtch As Logical)
	Local aArea      As Array
	Local lSendMail  As Logical
	Local nAux       As Numeric
	Local cSubject   As Character
	Local cBody      As Character
	Local cMsgErr    As Character
	Local aDestE     As Array
	Local cDestE     As Character
	Local lFA205MAIL As Logical
	Local aFA205MAIL As Array
	Local cAttach    As Character
	Local cFile      As Character
	Local cBarra     As Character

	aArea      := GetArea()
	lSendMail  := .F.
	nAux       := 0
	cSubject   := ""
	cBody      := ""
	cMsgErr    := ""
	aDestE     := {}
	cDestE     := GetMv("MV_RETMAIL",, "") // destinatarios do email de retorno automatico via schedule
	lFA205MAIL := ExistBlock( 'FA205MAIL' ) // ponto de entrada que permite ajustar envio de email
	aFA205MAIL := {}
	cAttach    := ""
	cFile      := ""
	cBarra     := If(isSrvUnix(),"/","\")

	Default cTitulo := "Retorno Bancario Automatico"
	Default cArq    := "ARQ.NAO.INFORMADO"
	Default lEnvAtch:= .T.  // envia ou nao o arquivo como attach

	// se o parametro de destinatarios de envio de email estiver vazio ignora o envio
	If ValType(cDestE) <> "C" .or. Empty(cDestE)
		Return Nil
	EndIf

	aDestE := StrTokArr(cDestE,";")
	If Len(aDestE) == 0
		Return Nil
	EndIf

	cSubject	:= cTitulo + ' - Arquivo: '+cArq + '  Processamento: ' +Dtoc(dDataBase) + ' - ' + Time()

	// corpo principal do email com o resumo do emvio
	cBody	:= '<HTML>'
	cBody	+= ' <HEAD>'
	cBody	+= '  <TITLE>'+cTitulo+' - Arquivo: '+cArq+'</TITLE>'
	cBody	+= ' </HEAD>'
	cBody	+= ' <BODY>'
	cBody	+= '  <H1>'
	cBody	+= '   <FONT SIZE="4" COLOR="#000099">'
	cBody	+= '    <B>'+cTitulo+'</B>'
	cBody	+= '   </FONT>'
	cBody	+= '  </H1>'
	cBody += '  <BR>
	cBody	+= '   <FONT SIZE="3" COLOR="#000099">'
	cBody	+= '    <B>Arquivo: '+cArq+'</B>'
	cBody	+= '   </FONT>'
	cBody	+= '  <H1><HR></H1>'

	// adiciona as mensagens contidas no vetor
	If Len(aMsgSch) >= 0
		cBody	+= '  <H1>'
		cBody	+= '   <FONT SIZE="3" COLOR="#000000">'
		cBody	+= '    Mensagens do Processamento : '
		cBody	+= '   </FONT>'
		cBody	+= '  </H1>'

		//������������������Ŀ
		//�MONTAGEM DO E-MAIL�
		//��������������������
		if Len(aMsgSch) == 0
			cBody += '<BR>&nbsp;&nbsp;-&nbsp;Processamento sem inconsistencias'
		Else
			For nAux := 1 To Len(aMsgSch)
				cBody += '<BR>&nbsp;&nbsp;-&nbsp;' + aMsgSch[nAux]
			Next
		Endif	
		cBody	+= '  <H1><HR></H1>'
	EndIf

	cBody	+= '  <H1>'
	cBody	+= '   <FONT SIZE="2" COLOR="#FF0000">'
	cBody	+= '    '+cSubject
	cBody	+= '   </FONT>'
	cBody	+= '  </H1>'
	cBody	+= ' </BODY>'
	cBody	+= '</HTML>'

	//���������������������������������������������������Ŀ
	//�PONTO DE ENTRADA PARA MANIPULAR A MENSAGEM         �
	//�����������������������������������������������������
	if lFA205MAIL
		aFA205MAIL := ExecBlock('FA205MAIL',.F.,.F.,{cSubject,cBody,aDestE,aMsgSch})
		If ValType(aFA205MAIL ) == 'A'
			If ValType(aFA205MAIL[1]) == 'C'
				cSubject := aFA205MAIL[1]  			// assunto
			EndIf
			If ValType(aFA205MAIL[2]) == 'C'
				cBody  	:= aFA205MAIL[2]  			// corpo do email
			EndIf
			If ValType(aFA205MAIL[3]) == 'A'
				aDestE	:= aClone(aFA205MAIL[3])  // destinatarios
			EndIf
			If ValType(aFA205MAIL[4]) == 'A'
				aMsgSch := aClone(aFA205MAIL[4])		// mensagens de erro
			EndIf
		EndIf
	Endif

	// processa o relatorio de processamento e grava fisicamente no disco retornando o nome com o caminho
	if lEnvAtch
		cPath		:=ALLTRIM(GETMV('MV_RELT'))
		cFile	 	:= Substr(cArq,rat(cBarra,cArq)+1,len(cArq))          
		cFile		:= Substr(cFile,1, rat(".",cFile)-1)
		if File(cPath+cFile+".PDF")
			cAttach := cPath+cFile+".PDF"
		Endif	
	Endif

	// se nao tem assunto, ou corpo, ou destinatario - nao envia email para nao dar erro
	If ! Empty(cSubject) .and. !Empty(cBody) .and. !Empty(aDestE)
		lSendMail 	:= FA205SENDMAIL(aDestE, cSubject, cBody, cAttach)

		If !lSendMail .And. !Empty(cMsgErr)
			ConOut(cMsgErr)  //-- Ocorreu um problema no envio do e-mail:
		EndIf
	EndIf

	RestArea(aArea)

Return Nil



/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FA205Erro � Autor � Aldo Barbosa dos Santos        �09/06/11���
�������������������������������������������������������������������������Ĵ��
���Descricao �le os dados do pergunte												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function FA205ERRO()
Local aCpoVld := {}		// vetor com as validacoes dos campos necess�rios para o processamento
Local lErrVld := .F.		// controle de mensagem de alerta na validacao dos campos
Local nA

If __lDirPag == Nil
	__lDirPag	:= SEE->(ColumnPos("EE_INCPAG")) > 0
EndIf

If __lDirRec == Nil
	__lDirRec	:= SEE->(ColumnPos("EE_INCREC")) > 0
EndIf

// validacao dos campos necessarios para o processamento automatico
if SEE->EE_RETAUT $ '1|3' // receber ou ambos
	AAdd(aCpoVld,{'EE_ATUMOE',	{|| SEE->EE_ATUMOE <> ' ' }	,.F.})	// Atualiza Moeda
	AAdd(aCpoVld,{'EE_DIRREC',	{|| SEE->EE_DIRREC <> ' ' }	,.F.})	// Diretorio de Importacao Recebimento
	AAdd(aCpoVld,{'EE_CFGREC',	{|| SEE->EE_CFGREC <> ' ' }	,.F.})	// Diretorio de Configuracao Recebimento
	AAdd(aCpoVld,{'EE_BKPREC',	{|| SEE->EE_BKPREC <> ' ' }	,.F.})	// Diretorio de Backup Recebimento
	AAdd(aCpoVld,{'EE_DESCOM',	{|| SEE->EE_DESCOM <> ' ' }	,.F.})	// Abate desconto da Comissao
	AAdd(aCpoVld,{'EE_CNABRC',	{|| SEE->EE_CNABRC <> ' ' }	,.F.})	// Configuracao CNAB Recebimento
	AAdd(aCpoVld,{'EE_PROCFL',	{|| SEE->EE_PROCFL <> ' ' }	,.F.})	// Processa Filial

	If __lDirRec
		AAdd(aCpoVld,{'EE_INCREC',	{|| SEE->EE_INCREC <> ' ' }	,.F.})	// Diretorio de Arquivo Inconsistente
	EndIf

Endif	
if SEE->EE_RETAUT $ '2|3'  // pagar ou ambos
	AAdd(aCpoVld,{'EE_DIRPAG',	{|| SEE->EE_DIRPAG <> ' ' }	,.F.})	// Diretorio de Importacao Recebimento
	AAdd(aCpoVld,{'EE_CFGPAG',	{|| SEE->EE_CFGPAG <> ' ' }	,.F.})	// Diretorio de Configuracao Recebimento
	AAdd(aCpoVld,{'EE_BKPPAG',	{|| SEE->EE_BKPPAG <> ' ' }	,.F.})	// Diretorio de Backup Recebimento
	AAdd(aCpoVld,{'EE_CNABPG',	{|| SEE->EE_CNABPG <> ' ' }	,.F.})	// Configuracao CNAB Recebimento

	If __lDirPag
		AAdd(aCpoVld,{'EE_INCPAG',	{|| SEE->EE_INCPAG <> ' ' }	,.F.})	// Diretorio de Arquivo Inconsistente
	EndIf

Endif
if SEE->EE_RETAUT == '3'  //  ambos
	AAdd(aCpoVld,{'EE_AGLCTB',	{|| SEE->EE_AGLCTB <> ' ' }	,.F.})	// Aglutina lancamento contabil
	AAdd(aCpoVld,{'EE_MULTNT',	{|| SEE->EE_MULTNT <> ' ' }	,.F.})	// Considera Multiplas naturezas
Endif

lErrVld := .F.
For nA := 1 to Len(aCpoVld)
	if ! Eval(aCpoVld[nA,2])
		aCpoVld[nA,3] := .T.  // marca o campo com erro
		lErrVld := .T.
	Endif
Next

// se existe campos que nao atendam a validacao deve gravar o problema no log
if lErrVld
	ProcLogAtu("INICIO",STR0001+" - "+STR0010+SEE->EE_CODIGO+" "+SEE->EE_AGENCIA+" "+SEE->EE_CONTA+" "+SEE->EE_SUBCTA) // "Retorno Bancario Automatico (Receber) # "Parametros de Bancos - Banco:"
	For nA := 1 to Len(aCpoVld)
		if aCpoVld[nA,3]
			ProcLogAtu("ALERTA",STR0013+aCpoVld[nA,1]+STR0014) // "Campo:" # " com conteudo invalido ou nao informado."
		Endif
	Next
	ProcLogAtu("FIM",STR0001+" - "+STR0010+SEE->EE_CODIGO+" "+SEE->EE_AGENCIA+" "+SEE->EE_CONTA+" "+SEE->EE_SUBCTA) // "Retorno Bancario Automatico (Receber) # "Parametros de Bancos - Banco:"
Endif		

Return( lErrVld )




/*�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������ͻ��
���Programa  �FA205SENDMAIL �Autor  � Aldo Barbosa dos Santos  � Data � 10/06/2011  ���
�����������������������������������������������������������������������������������͹��
���Desc.     �Rotina de envio de e-mail                                             ���
���          �                                                                      ���
�����������������������������������������������������������������������������������͹��
���Uso       � FINA205                                                              ���
�����������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/
Static Function FA205SendMail( aDest, cAssunto, cMensagem, cAttach )

Local aArea     := GetArea()
Local cEmailTo  := ""								// E-mail de destino
Local cEmailBcc := ""								// E-mail de copia
Local lResult   := .F.								// Se a conexao com o SMPT esta ok
Local cError    := ""								// String de erro
Local lRet	    := .F.								// Se tem autorizacao para o envio de e-mail
Local cServer   := Trim(GetMV('MV_RELSERV')) 		// Nome do servidor de envio de e-mail - Ex.: smtp.ig.com.br ou 200.181.100.51
Local cConta    := Trim(GetMV('MV_RELACNT')) 		// Conta a ser utilizada no envio de e-mail - Ex.: fuladetal@fulano.com.br
Local cPsw      := Trim(GetMV('MV_RELPSW')) 		// Senha da conta de e-mail;
Local lRelauth  := SuperGetMv("MV_RELAUTH",, .F.)	// Determina se o servidor exige autentica��o
Local cCtaAut   := Trim(GetMV('MV_RELAUSR')) 		// Usu�rio para autentica��o no servidor de e-mail (caso servidor assim exigir);
Local cApsw     := Trim(GetMV('MV_RELAPSW')) 		// Senha para autentica��o no servidor de e-mail (caso servidor assim exigir).
Local cFrom	    := Trim(GetMV('MV_RELFROM')) 		// E-mail utilizado no campo FROM no envio do e-mail;
Local nCntFor

Default cAttach := ""  

// remonta os destinatarios utilizando o vetor
cEmail := ""
For nCntFor := 1 To Len(aDest)
	If !Empty(cEmail)
		cEmail += ';'
	EndIf
	cEmail += aDest[nCntFor]
Next

//�����������������������������������������������������������������������������Ŀ
//�Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense�
//�que somente ela recebeu aquele email, tornando o email mais personalizado.   �
//�������������������������������������������������������������������������������
cEmailTo := cEmail
//If At( ";", cEmail ) > 0 // existe um segundo e-mail.
//	cEmailBcc := SubStr( cEmail, At( ";", cEmail ) + 1, Len( cEmail ) )
//Endif

CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cPsw RESULT lResult

// Se a conexao com o SMPT esta ok
If lResult
	
	// Se existe autenticacao para envio valida pela funcao MAILAUTH
	If lRelauth
		lRet := Mailauth( cCtaAut, cApsw )
	Else
		lRet := .T.
	Endif
	
	If lRet
		SEND MAIL; 
		FROM 		cFrom;
		TO      	cEmailTo;
		BCC     	cEmailBcc;
		SUBJECT 	cAssunto;
		BODY    	cMensagem;
		ATTACHMENT  cAttach  ;
		RESULT 		lResult
		
		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError
			If !IsBlind()
				Help( " ", 1, "01 - " + "ATENCAO", , cError + " " + cEmailTo, 4, 5 )
			Else
				ApMsgInfo( "01 - " + "ATENCAO" + " " + cError + " " + cEmailTo )
			EndIf
		Endif
		
	Else
		GET MAIL ERROR cError
		If !IsBlind()
			Help( " ", 1, "02 - " + STR0015, , cError, 4, 5 ) // "Autenticacao"
		Else
			ApMsgInfo("02 - " + STR0016+" "+STR0017 )
		EndIf
	Endif
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	If !IsBlind()
		Help( " ", 1, "03 - " + "ATENCAO", , cError, 4, 5 )
	Else
		ApMsgInfo( "03 - " + "ATENCAO" + " " + cError )
	EndIf
Endif
 
RestArea( aArea )

Return( lResult )

/*/{Protheus.doc} VldLicenca
Verifica se a rotina selecionada est� sendo chamada com licen�a de uso para o m�dulo de origem 
@type function
@version 12 
@author gabriel.asantos
@since 03/02/2023
@return logical, Se retorno verdadeiro ent�o possui licen�a, caso contr�rio n�o possui licen�a
/*/
Static Function VldLicenca()
	Local lRet       As Logical

	FwBlkUserFunction(.T.)
	lRet := AmIIn(SIGAFIN)
	FwBlkUserFunction(.F.)
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPFSDir
Valida integra��o com m�dulo jur�dico SIGAPFS e chama fun��o
para criar diret�rio a ser utilizado no retorno do CNAB a Pagar
e a Receber

@param cCampo, Campo para o qual ser� validado o diret�rio
@param cDir  , Diret�rio do arquivo de pagamento a ser validado

@return lRet, Se verdadeiro o diret�rio foi criado com sucesso

@author reginaldo.rorges
@since  11/05/2023
/*/
//-------------------------------------------------------------------
Static Function VldPFSDir(cCampo As Character, cDir as Character)
Local lCriaDir As Logical
Local lIntPFS  := SuperGetMV("MV_JURXFIN",, .F.) // Integra��o SIGAPFS x SIGAFIN

Default cCampo := ""
Default cDir   := ""

	lCriaDir := .T.
	lCriaDir := lIntPFS .And. FindFunction("JurCriaDir") .And. JurCriaDir(cCampo, cDir)

Return lCriaDir
