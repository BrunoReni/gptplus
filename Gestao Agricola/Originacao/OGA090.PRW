#INCLUDE "PROTHEUS.CH"
#INCLUDE "OGA090.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �OGA090   � Autor � Alvaro Camillo Neto   � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao do Cadastro de Cambio de Moedas Contabeis       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �SIGAFIN                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Generico                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function OGA090(aRotAuto,nOpcAuto)

	Local lRet := .T.                                                              
	
	PRIVATE aRotina    	:= MenuDef()  			// Array com opcoes do menu da mBrowse
	PRIVATE cCadastro 	:= OemtoAnsi(STR0001)	//"Atualizacao de Indice"
	PRIVATE lOGA090AUT 	:= .F. 					// Determina a execucao automatica da rotina quando .T.
	
	DEFAULT aRotAuto := {}
	DEFAULT nOpcAuto := 3
	     
	If Len(aRotAuto) > 0
		lOGA090AUT := .T.
	EndIf

	//�����������������������������Ŀ
	//� Endereca a funcao de BROWSE �
	//�������������������������������
	If AliasInDic("NK0") .And.  AliasInDic("NK1")
	
		If lOGA090AUT
			//��������������������������������������������������������������Ŀ
			//�Tratamento a ser considerado quando chamada pela MsExecAuto() �
			//����������������������������������������������������������������
	
			PRIVATE aAutoCab := Aclone(aRotAuto)
			
			MBrowseAuto(nOpcAuto,aAutoCab,"NK1")
			
		Else  
			//mBrowse( 6, 1,22,75,"NK1")

			//CRIA��O DA MBROWSE
			oBrowse := FWMBrowse():New() //Instanciando a Classe
			oBrowse:SetAlias("NK1") //Informando o Alias                                             `
			oBrowse:SetMenuDef("OGA090") //Nome do fonte do MenuDef
			oBrowse:SetDescription(STR0001) //"Atualizacao de Indice"
			oBrowse:SetAttach(.T.)
			oBrowse:Activate()

		EndIf
			
	Else
	
		If lOGA090AUT
	
			//�����������������������������������������������������������������Ŀ
			//�Quando chamada pela MsExecAuto() desvia Help para arquivo de log �
			//�������������������������������������������������������������������
			lSetHelp := HelpInDark(.T.)
	
		Endif	
	
		Help(" ",1,"FINNoTab") // "Dicion�rio n�o atualizado, por favor executar o atualizador"
		lRet := .F.
		
		HelpInDark(lSetHelp)
	
	EndIf	

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �OGA090Cal  � Autor � ALvaro Camillo Neto  � Data � 16/12/09���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe na tela o calendario e a getdados                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �OGA090cal(cAlias,nReg,nOpc)                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nil                                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � OGA090                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function OGA090Cal(cAlias,nReg,nOpc)

	Local aSaveArea	:= GetArea()
	Local aAltera		:= {"NK1_VALOR"} //,"NK1_BLOQ"}
	
	Local oDlg, oCalend
	Local oGet
	Local dData

	Private aTELA[0][0],aGETS[0],aHeader[0]
	Private aCols 		:= {}
	Private aColsAnt	:= {}
	Private nUsado 	:= 0
	Private nPosCodInd, nPosIndice, nPosBloq
	Private lInclui
	
	//NK0 - Indices de Mercado
	dbSelectArea("NK0")
	dbSetOrder(1)
	dbSeek(xFilial())
	If Eof() .Or. (xFilial("NK0") <> NK0->NK0_FILIAL)
		Help(" ",1,"FIN18NOIND") // N�o h� indices cadastrados
		Return
	EndIf	
	
	//NK1 - Cotacoes de Indices
	DbSelectArea("NK1")
	dbSetOrder(1)

	If NK1->(Bof()) .And. NK1->(Eof())
		dData := dDataBase
	Else
		dData := NK1->NK1_DATA
	EndIf
	
	//Gera matriz Aheader - para montagem posterior da acols
	OGA090Ahead()

	If !lOGA090AUT
		lInclui := OGA090Acols(dData)
		aColsAnt := Aclone(aCols)
	Endif	

	nOpca := 0

	If !lOGA090AUT	
		
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) FROM 9,0 TO 23,110 OF oMainWnd
	
		oCalend:=MsCalend():New(0,0,oDlg)
	
		oCalend:dDiaAtu	:= dData
		dData				:= oCalend:dDiaAtu
	
		oCalend:bChange := {|| AT430ChgDia(@oCalend,@oGet,@dData,@lInclui), oDlg:Refresh() }
			
		oGet := MSGetDados():New(00,140,66,420,nOpc,"AlwaysTrue","AlwaysTrue","",.F.,aAltera)
		oGet:oBrowse:bAdd := { || .F. }
		
		@ 080,320 BUTTON STR0017 SIZE 045,012 PIXEL OF oDlg ACTION Processa({|| (OGA090Copia(dData,lInclui,@oGet)) }, )   //"Copiar todos"
		DEFINE SBUTTON FROM 80, 380 TYPE 1 ACTION (OGA090OK(dData,lInclui),oDlg:End()) ENABLE Of oDlg

		@ 080,270 BUTTON STR0020 SIZE 045,012 PIXEL OF oDlg ACTION Processa({|| (OGA090CPD(dData,lInclui,@oGet)) }, )   //"Copiar Diarias"
		DEFINE SBUTTON FROM 80, 380 TYPE 1 ACTION (OGA090OK(dData,lInclui),oDlg:End()) ENABLE Of oDlg

		@ 080,220 BUTTON STR0021 SIZE 045,012 PIXEL OF oDlg ACTION Processa({|| (OGA090CPMA(dData,lInclui,@oGet)) }, )   //"Copiar Mais Atual"
		DEFINE SBUTTON FROM 80, 380 TYPE 1 ACTION (OGA090OK(dData,lInclui),oDlg:End()) ENABLE Of oDlg
	
		ACTIVATE DIALOG oDlg CENTERED
	
	Else
	
		//����������������������������������������������������������Ŀ
		//�Tratamento de inclusao considerado para rotina automatica �
		//������������������������������������������������������������
		AxInclui(cAlias,nReg,nOpc,,,,,,,,,aAutoCab)
	
	EndIf

	RestArea(aSaveArea)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �AT430chgdia� Autor � Pilar S Albaladejo   � Data � 17/07/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastrar cotacoes no dia escolhido                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �AT430ChgDia(oCalend,oGet,dData,lInclui)             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � OGA090                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto do Calendario                               ���
���          � ExpO2 = Objeto do Get		                                ���
���          � ExpD1 = Data           		                                ���
���          � ExpL1 = Define se eh inclusao ou nao		                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function AT430ChgDia(oCalend,oGet,dData,lInclui)

	Local lRet := .F.
	Local aSaveArea := GetArea()
	
	
	lRet := OGA090Comp(lInclui)
	
	If lRet
		BEGIN TRANSACTION
			OGA090Grava(dData)
		END TRANSACTION
	EndIf	
	
	dData := oCalend:dDiaAtu
	
	lInclui := OGA090Acols(dData)
	aColsAnt := Aclone(aCols)
	oGet:oBrowse:Refresh()
	
	RestArea(aSaveArea)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �OGA090AHEAD� Autor � Alvaro Camillo Neto  � Data � 16/12/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera matriz Aheader - para montagem posterior da acols     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �OGA090AHead                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � OGA090                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function OGA090Ahead()

	Local aSaveArea := GetArea()
	Local nI := 1
	Local cCampoFor := ""
	Local aCampos := {}	

	AADD(aCampos,{"NK1_INDICE", "NK0_DESCRI", "NK0_TPCOTA", "NK0_UM1PRO", "NK0_MOEDA", "NK1_VALOR"})
	For nI := 1 to Len(aCampos[1])
		cCampoFor := aCampos[1][nI]
		AADD(aHeader,{ TRIM(RetTitle(cCampoFor)), cCampoFor, X3Picture(cCampoFor),;
						 TamSX3(cCampoFor)[1], TamSX3(cCampoFor)[2], X3Valid(cCampoFor),;
						 GetSX3Cache(cCampoFor,"X3_USADO"), TamSX3(cCampoFor)[3], SubStr(cCampoFor,1,3) } )	
		nUsado++
	Next nI

	RestArea(aSaveArea)

Return .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �OGA090Acols� Autor � Alvaro Camillo Neto  � Data � 17/07/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera matriz Acols para preenchimento das cotacoes          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �OGA090Acols(dData,oGet)                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T./.F.                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � OGA090                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpD1=Data				                                      ���
���          � ExpO1=Objeto do Get		                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function OGA090Acols(dData,oGet)

	Local aSaveArea:= GetArea()
	Local lInclui	:= .F.	
	Local nCont 	:= 1
	Local cCodInd, nTaxa
	Local cAlias, nRecno
	Local nPos_ALI_WT, nPos_REC_WT
	
	nPosDesc	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "NK0_DESCRI"})
	nPostipo	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "NK0_TPCOTA"})
	nPosCodInd	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "NK1_INDICE"})
	nPosUm1Pro	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "NK0_UM1PRO"})
	nPosMoeda	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "NK0_MOEDA"})
	nPosIndice	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "NK1_VALOR"})
	
	nPos_ALI_WT := AScan(aHeader,{|x| Upper(AllTrim(x[2])) == "NK1_ALI_WT"})
	nPos_REC_WT := AScan(aHeader,{|x| Upper(AllTrim(x[2])) == "NK1_REC_WT"})
	
	aCols := {}
	
	NK0->(dbSetOrder(1))
	NK1->(dbSetOrder(1))
	
	NK0->(dbSeek(xFilial()))
	While NK0->(!Eof()) .And. xFilial("NK0") == NK0->NK0_FILIAL

		If ! fValPerUsu(NK0->NK0_FILIAL, NK0->NK0_INDICE)
			NK0->(dbSkip())
			LOOP
		EndIf
		
		/*N�o se deve atualizar os indices que possuem tipo formula*/
		if NK0->NK0_TPCOTA = 'F' .OR. NK0->NK0_TPCOTA = 'T'
			NK0->(dbSkip())
		else			
			If NK1->(!MsSeek( xFilial("NK1") + Dtos(dData) + NK0->NK0_INDICE))
				lInclui	:= .T.
				cCodInd	:= NK0->NK0_INDICE
				nTaxa		:= CriaVar("NK1_VALOR",.T.)
		//		cBloq		:= CriaVar("NK1_BLOQ",.T.)
				cAlias  	:= "NK1"
				nRecno	:= 0
			Else		
				lInclui	:= .F.
				cCodInd	:= NK1->NK1_INDICE
				nTaxa		:= NK1->NK1_VALOR
			//	cBloq		:= NK1->NK1_BLOQ
				cAlias  := "NK1"
				nRecno	:= NK1->(Recno())
			EndIf	
		
			AADD(aCols,Array(nUsado+1))     
			aCols[nCont][nPosCodInd]	:= cCodInd
			aCols[nCont][nPosIndice]	:= nTaxa
		//	aCols[nCont][nPosBloq]		:= cBloq			
			aCols[nCont][nPosDesc]		:= NK0->NK0_DESCRI
			aCols[nCont][nPosTipo]		:= NK0->NK0_TPCOTA		
			aCols[nCont][nPosUm1Pro]		:= NK0->NK0_UM1PRO
			aCols[nCont][nPosMoeda]		:= NK0->NK0_MOEDA
			aCols[nCont][nUsado+1]		:= .F.
		
			//	If nPos_ALI_WT > 0
			//		aCols[nCont][nPos_ALI_WT] := cAlias
			//	EndIf
			
			//	If nPos_REC_WT > 0
			//		aCols[nCont][nPos_REC_WT] := nRecno
			//	EndIf
				
			nCont++	
			NK0->(dbSkip())
		endif
	EndDo	
	
	RestArea(aSaveArea)
	
Return lInclui

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �OGA090Copia� Autor � Marlon R. Trettin   � Data � 18/06/14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Copia cotacoes da data anterior para a data atual          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � OGA090Copia(dData,lInclui)                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � OGA090                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpD1 = Data                                               ���
���          � ExpL1 = Se eh inlusao ou nao.                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function OGA090Copia(dData, lInclui, oGet)

	Local nCont
	Local dDataAux 
	Local aSaveArea	:= GetArea()
	
	If !lInclui	
		Help(, , STR0003, , STR0018, 1, 0 ) //"Aten��o"###"Opera��o permitida apenas na inclusao de dados!"
		Return .F.
	EndIf
	
	If !MsgYesNo(OemToAnsi(STR0019),OemToAnsi(STR0003)) // "Copiar cota��es da data anterior � atual?"##"Aten��o"
		Return .F.
	EndIf
	
	ProcRegua(Len(aCols))
	
	NK1->(dbSetOrder(1))
	For nCont := 1 to Len(aCols)
	
		IncProc()
		dDataAux := dData
		While .T.
			dDataAux := dDataAux - 1 // Decrementa um dia na data
			
			// Verifica se existe cota��o para o �ndice cadastrado no primeiro dia anterior � data atual
			If NK1->(MsSeek( xFilial("NK1") + Dtos(dDataAux) + aCols[nCont][nPosCodInd]))
				aCols[nCont][nPosIndice] := NK1->NK1_VALOR
				Exit
			EndIf  
			If dData - dDataAux > 30
				Exit
			EndIf
		EndDo
		
	Next nCont
	
	oGet:oBrowse:Refresh()
	
	RestArea(aSaveArea)
	
Return .T.

Function OGA090CPD(dData, lInclui, oGet)

	Local nCont
	Local dDataAux 
	Local aSaveArea	:= GetArea()
	
	If !lInclui	
		Help(, , STR0003, , STR0018, 1, 0 ) //"Aten��o"###"Opera��o permitida apenas na inclusao de dados!"
		Return .F.
	EndIf
	
	If !MsgYesNo(OemToAnsi(STR0019),OemToAnsi(STR0003)) // "Copiar cota��es da data anterior � atual?"##"Aten��o"
		Return .F.
	EndIf
	
	ProcRegua(Len(aCols))
	
	NK1->(dbSetOrder(1))
	For nCont := 1 to Len(aCols)
	
		IncProc()
		dDataAux := dData
		While .T.
			dDataAux := dDataAux - 1 // Decrementa um dia na data
			
			// Verifica se existe cota��o para o �ndice cadastrado no primeiro dia anterior � data atual
			If NK1->(MsSeek( xFilial("NK1") + Dtos(dDataAux) + aCols[nCont][nPosCodInd]))
				dbSelectArea("NK0")
				NK0->(dbSetOrder(1))
			// Verifica se existe cota��o Di�ria a ser copiada				
				If NK0-> (MsSeek( xFilial("NK0") + aCols[nCont][nPosCodInd])) .AND. NK0->NK0_TPCOTA='D'
				restarea(aSaveArea)
				aCols[nCont][nPosIndice] := NK1->NK1_VALOR
				Exit
				Endif
			EndIf  
			If dData - dDataAux > 30
				Exit
			EndIf
		EndDo
		
	Next nCont
	
	oGet:oBrowse:Refresh()
	
	RestArea(aSaveArea)
	
Return .T.

Function OGA090CPMA(dData, lInclui, oGet)

	Local nCont
	Local dDataAux 
	Local aSaveArea	:= GetArea()
	
	If !lInclui	
		Help(, , STR0003, , STR0018, 1, 0 ) //"Aten��o"###"Opera��o permitida apenas na inclusao de dados!"
		Return .F.
	EndIf
	
	If !MsgYesNo(OemToAnsi(STR0019),OemToAnsi(STR0003)) // "Copiar cota��es da data anterior � atual?"##"Aten��o"
		Return .F.
	EndIf
	
	ProcRegua(Len(aCols))
	
	NK1->(dbSetOrder(1))
	For nCont := 1 to Len(aCols)
	
		IncProc()
		dDataAux := dData
		While .T.
			dDataAux := dDataAux - 1 // Decrementa um dia na data
			
			// Verifica se existe cota��o para o �ndice cadastrado no primeiro dia anterior � data atual
			If NK1->(MsSeek( xFilial("NK1") + Dtos(dDataAux) + aCols[nCont][nPosCodInd]))
				dbSelectArea("NK0")
				NK0->(dbSetOrder(1))
			// Verifica se existe cota��o Mais Atual a ser copiada				
				If NK0-> (MsSeek( xFilial("NK0") + aCols[nCont][nPosCodInd])) .AND. NK0->NK0_TPCOTA='A'
				restarea(aSaveArea)
				aCols[nCont][nPosIndice] := NK1->NK1_VALOR
				Exit
				Endif
			EndIf  
			If dData - dDataAux > 30
				Exit
			EndIf
		EndDo
		
	Next nCont
	
	oGet:oBrowse:Refresh()
	
	RestArea(aSaveArea)
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �OGA090Grava� Autor � Alvaro Camillo Neto  � Data � 16/12/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava ou exclui as cotacoes digitadas na GetDados          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � OGA090Grava(dData)                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � OGA090                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpD1 = Data                                               ���
���          � ExpL1 = Se eh exclusao ou nao. 	                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function OGA090Grava(dData)

	Local nCont
	Local aSaveArea	:= GetArea()
	
	NK0->(dbSetOrder(1))
	NK1->(dbSetOrder(1))
	
	For nCont := 1 To Len(aCols)
		If aCols[nCont][nPosIndice] >= 0
			If NK1->(!DbSeek(xFilial("NK1") + Dtos(dData) + aCols[nCont][nPosCodInd]))	
				If NK0->(dbSeek(xFilial("NK0") + aCols[nCont][nPosCodInd]))
					dbSelectArea("NK1")
					RecLock("NK1",.T.)
					NK1->NK1_FILIAL	:= xFilial("NK1")
					NK1->NK1_DATA 	:= dData
					NK1->NK1_INDICE	:= aCols[nCont][nPosCodInd]
					NK1->NK1_VALOR 	:= aCols[nCont][nPosIndice]
				//	NK1->NK1_BLOQ  	:= aCols[nCont][nPosBloq]
			  		NK1->(MsUnlock())
				EndIf
			Else
				RecLock("NK1",.F.)
				NK1->NK1_VALOR := aCols[nCont][nPosIndice]
			//	NK1->NK1_BLOQ   := aCols[nCont][nPosBloq]
				NK1->(MsUnlock())
			EndIf				
		EndIf
	Next nCont
	
	RestArea(aSaveArea)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �OGA090Comp � Autor � Pilar S Albaladejo   � Data � 17/07/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Compara matriz aCols e aColsAnt                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �OGA090Comp(lInclui)                                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T./.F.                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � OGA090                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpL1 = Se eh inclusao ou nao.                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function OGA090Comp(lInclui)

	Local nCont, nCont1
	Local lRet 		:= .F.
	Local aSaveAREA := GetArea()               
	Local lEntrei := .F.
	
	For nCont := 1 To Len(aCols)
		For nCont1 := 1 To nUsado
			If lInclui .Or. (aCols[nCont][nCont1]!= aColsAnt[nCont][nCont1])
				lRet := MsgYesNo(OemToAnsi(STR0002),OemToAnsi(STR0003)) // "Gravar Dados?"##"Aten��o"?
				lEntrei := .T.
				Exit
			EndIf			
		Next nCont1 
		If lEntrei
			Exit
		EndIf		
	Next nCont
	
	RestArea(aSaveArea)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �OGA090Ok   � Autor � Alvaro Camillo Neto  � Data � 16/12/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do botao OK                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �OGA090Ok(dData,lInclui)                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T./.F.                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � OGA090                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpD1 = Data                                                ���
���          �ExpL1 = Se eh inclusao ou nao. 	                          ���
���          �ExpL2 = Se eh exclusao ou nao. 	                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function OGA090Ok(dData,lInclui)

	Local lRet 		:= .T.
	Local aSaveArea := GetArea()
	
	IF lRet
		lRet := Iif(lOGA090AUT,.t.,OGA090Comp(lInclui))
		If lRet 
			OGA090Grava(dData)
		EndIf	
	Endif
	
	RestArea(aSaveArea)

Return lRet

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Alvaro Camillo Neto   � Data � 16/12/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

	Local aRotina := {{ STR0004	, "AxPesqui"		, 0 , 1,,.F.},;		//"Pesquisar"
	                 	{ STR0005	, "AxVisual"	, 0 , 2},;			//"Visualizar"
	                 	{ STR0006	, "OGA090Cal"	, 0 , 3},;   		//"Atual. de Indices"
	                 	{ STR0007	, "AxDeleta"	, 0 , 5},;			//"Excluir"
						{ STR0008	, "OGA090Imp"	, 0 , 3},;			//"Importar"
						{ STR0009	, "OGA090Exp"	, 0 , 6}}			//"Exportar"
	//					{ STR0017	, "OGA090Cal"	, 0 , 4},;			//"Copiar"

Return(aRotina)

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun�ao    �OGA090Exp � Autor � Marco Aurelio - Mano    � Data �19/07/10  ���
����������������������������������������������������������������������������Ĵ��
���Descri�ao �Exporta indices financeiros para arquivo CSV                   ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �OGA090Exp()                                                   ���
����������������������������������������������������������������������������Ĵ��
���Parametros�                                                               ���
����������������������������������������������������������������������������Ĵ��
���Uso       � SIGAFIN                                                       ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/             
Function OGA090Exp()
	Local aRet      := {}				// Conteudo de retorno da ParamBox
	Local lRet      := .t.				// Conteudo de retorno da funcao
	Local aPerg     := {}				// Array de parametros a serem passados para a ParamBox
	Local cDescPar  := STR0012			// Descricao do parametro (###"Nome do arquivo exporta��o")
	Local cIniPar   := PadR("",150) 	// Conteudo inicial do parametro
	Local cPictPar  := ""				// Mascara de edicao do parametro
	Local cValidPar := ""				// Validacao posterio do parametro
	Local cWhenPar  := ""				// Validacao anterior do parametro
	Local nTamPar   := 90				// Tamanho da MsGet do parametro
	Local lObrigat  := .t.				// Determina se o parametro e obrigatorio
	Local cTipArq   := STR0013		 	// Texto referente aos tipos de arquivos a serem exibidos(### "Arquivo .CSV |*.CSV" )
	Local cDirIni   := ""			 	// Diretorio inicial do cGetFile
	Local cParGetF  := ""			 	// Parametros da cGetFile
	Local cTitulo   := STR0014		 	// Titulo da tela de parametros(###"Exportar �ndices Financeiros - CSV")
	
	If !FindFunction("CTBExpCSV")
	   
		Aviso(STR0009,STR0010,{STR0011}) //"Exportar"###"Funcao nao disponivel"###"Fechar"
	
		lRet := .F.
	
	Else
	
		SaveInter()
	
		cParGetF := GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE  
	
		//�������������������������������������������������Ŀ
		//�Array a ser passado para ParamBox quando tipo(6) �
		//���������������������������������������������������
		aAdd( aPerg,{6,cDescPar,cIniPar,cPictPar,cValidPar,cWhenPar,nTamPar,lObrigat,cTipArq,cDirIni,cParGetF})
	
		//�������������������������������������������������������������������Ŀ
		//�Caso confirme a tela de parametros processa a rotina de exportacao �
		//���������������������������������������������������������������������
		If ParamBox(aPerg,cTitulo,@aRet) 
		
			oProcess:= MsNewProcess():New( {|lEnd| CTBExpCSV( lEnd, oProcess, aRet[1], { {"NK1",1} } )} )
			oProcess:Activate()
		
		EndIf
		
		RestInter()
		
	EndIf

Return(lRet)

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun�ao    �OGA090Imp � Autor � Marco Aurelio - Mano    � Data �19/07/10  ���
����������������������������������������������������������������������������Ĵ��
���Descri�ao �Importa indices financeiros para arquivo CSV                   ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �OGA090Imp()                                                   ���
����������������������������������������������������������������������������Ĵ��
���Parametros�                                                               ���
����������������������������������������������������������������������������Ĵ��
���Uso       � SIGAFIN                                                       ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/             
Function OGA090Imp()

	Local aRet      := {}				// Conteudo de retorno da ParamBox
	Local aPerg     := {}				// Array de parametros a serem passados para a ParamBox
	Local cDescPar  := STR0016			// Descricao do parametro (###"Nome do arquivo para importa��o")
	Local cIniPar   := PadR("",150) 	// Conteudo inicial do parametro
	Local cPictPar  := ""				// Mascara de edicao do parametro
	Local cValidPar := ""				// Validacao posterio do parametro
	Local cWhenPar  := ""				// Validacao anterior do parametro
	Local nTamPar   := 90				// Tamanho da MsGet do parametro
	Local lObrigat  := .t.				// Determina se o parametro e obrigatorio
	Local cTipArq   := STR0013		 	// Texto referente aos tipos de arquivos a serem exibidos(### "Arquivo .CSV |*.CSV" )
	Local cDirIni   := ""			 	// Diretorio inicial do cGetFile
	Local cParGetF  := ""			 	// Parametros da cGetFile
	Local cTitulo   := STR0015		 	// Titulo da tela de parametros(### "Importar �ndices Financeiros - CSV")
	Local aCposNK1  := {}			 	// Campos a serem atualizados na tabela NK1
	Local aCfgImp   := {}			 	// Array de configuracoes a serem passadas para a CTBImpCSV
	
	aCposNK1 := { 	{"NK1_DATA"  ,"D",TamSX3("NK1_DATA")[1]  ,TamSX3("NK1_DATA")[2]		},;
					{"NK1_INDICE","C",TamSX3("NK1_INDICE")[1],TamSX3("NK1_INDICE")[2]	},;
					{"NK1_VALOR","N",TamSX3("NK1_VALOR")[1],TamSX3("NK1_VALOR")[2]	}}
				//	,;
				//	{"NK1_BLOQ"  ,"C",TamSX3("NK1_BLOQ")[1]  ,TamSX3("NK1_BLOQ")[2]		}}     
	
	aCfgImp  := { { "NK1", aCposNK1, {||MSExecAuto({|x,y| OGA090(x,y)},xAutoCab,3)}} }
	cParGetF := GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE  
	
	//�������������������������������������������������Ŀ
	//�Array a ser passado para ParamBox quando tipo(6) �
	//���������������������������������������������������
	aAdd( aPerg,{6,cDescPar,cIniPar,cPictPar,cValidPar,cWhenPar,nTamPar,lObrigat,cTipArq,cDirIni,cParGetF})
	
	//�������������������������������������������������������������������Ŀ
	//�Caso confirme a tela de parametros processa a rotina de exportacao �
	//���������������������������������������������������������������������
	If ParamBox(aPerg,cTitulo,@aRet) 
	
		oProcess:= MsNewProcess():New( {|lEnd| CTBImpCSV( lEnd, oProcess, aRet[1], aCfgImp )} )
		oProcess:Activate()
	
	EndIf

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MyOGA090 � Autor � Marco Aurelio - Mano  � Data � 15/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Exemplo de chamada do OGA090 pela MSExecAuto() para        ���
���          �atualizacao automatica das taxas dos indices financeiros    ���
�������������������������������������������������������������������������Ĵ��
���Uso       �SIGAFIN                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MyOGA090()

	Local aDadosAuto := {}		// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica 
	
	Private lMsHelpAuto := .f.	// Determina se as mensagens de help devem ser direcionadas para o arq. de log
	Private lMsErroAuto := .f.	// Determina se houve alguma inconsistencia na execucao da rotina em relacao aos
	
	aDadosAuto:= {	{'NK1_INDICE' , "02"			, Nil},;	// Data de referencia para atualizacao dos indices
					{'NK1_DATA'   , CTOD("22/07/10"), Nil},;	// Data de referencia para atualizacao dos indices
				 	{'NK1_VALOR' , 0.22222      	, Nil}}
				 	//,;   	// Dados para atualizacao do aCols 
				 //	{'NK1_BLOQ'   , "2"		     	, Nil}}   	// Dados para atualizacao do aCols 
	
	MSExecAuto({|x,y| OGA090(x,y)},aDadosAuto,3)
	
	If lMsErroAuto 
		lRetorno := .F.
		MostraErro()
	Else
		lRetorno:=.T.
	EndIf   

Return

/** {Protheus.doc} OGA090VLID
Valida o indice para que o mesmo n�o seja do tipo formula
Valida��o do SX3 - X3_VALID da tabela NK1 campo NK1_INDICE.

@param: 	cIndice - C�digo do Indice
@return:	lRet	- Retorno .T. ou .F.
@author: 	Jean Carlos Pontes Schulze
@since: 	03/03/2017
@Uso: 		OGA090 - Cota��o de Indice
*/
Function OGA090VLID(cIndice)
	Local lRet     := .t.
	Local aGetArea := GetArea()
	
	dbSelectArea("NK0")
	dbSetOrder(1)
	If NK0->(DbSeek(xfilial('NK0') + cIndice))
		if NK0->NK0_TPCOTA = 'F'
			Help(, , STR0003, , STR0022, 1, 0 ) //"Aten��o"###"Opera��o permitida apenas na inclusao de dados!"
			lRet := .f.
		endif
	endif
	
	RestArea(aGetArea)
Return lRet

/*/{Protheus.doc} fValPerUsu(cFilNK0, cIndice)
(long_description)
@type  Static Function
@author user
@since date
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function fValPerUsu(cFilNK0, cIndice)
	Local aGrpUsuLog := UsrRetGrp(cUserName, RetCodUsr()) //Retorna um array contendo todos os c�digos dos Grupos de Usu�rio em que o Usu�rio, passado na fun��o, pertence.
	Local cCodUsu    := IIF( NK0->(ColumnPos('NK0_CODUSU') ) > 0 , POSICIONE("NK0", 1, cFilNK0+cIndice, "NK0_CODUSU") , "" )  
	Local cCodGru    := IIF( NK0->(ColumnPos('NK0_GRPUSU') ) > 0 , POSICIONE("NK0", 1, cFilNK0+cIndice, "NK0_GRPUSU") , "" )  
	Local cCodBls    := IIF( NK0->(ColumnPos('NK0_CODBOL') ) > 0 , POSICIONE("NK0", 1, cFilNK0+cIndice, "NK0_CODBOL") , "" )  
	Local lUsuario   := .F.
	Local lGrupo     := .F.

	Do Case
		Case !Empty(cCodUsu) //Se restri��o por usu�rio.
			lUsuario := .T.
		Case !Empty(cCodGru) //Se restri��o por grupo de usu�rios.
			lGrupo := .T.
		Case !Empty(cCodBls) //se n�o tiver restri��o por usu�rio ou grupo verigica se na bolsa vinculada tem alguma restri��o.
			cCodUsu := POSICIONE("N8C", 1, FwxFilial("N8C")+cCodBls, "N8C_CODUSU")
			cCodGru := POSICIONE("N8C", 1, FwxFilial("N8C")+cCodBls, "N8C_GRPUSU")
			If !Empty(cCodUsu) //Se restri��o por usu�rio.
				lUsuario := .T.
			ElseIf !Empty(cCodGru) //Se restri��o por grupo de usu�rios.
				lGrupo := .T.
			EndIf
	End Case

	If lUsuario
		If cCodUsu <> RetCodUsr() //Retorna o c�digo do usu�rio corrente.
			Return .F.
		EndIf
	ElseIf lGrupo
		nPos := aScan(aGrpUsuLog, cCodGru)
		//Se n�o encontrou o grupo nos grupos em que o usu�rio logado est� contido ent�o retorna falso.
		If nPos == 0
			Return .F.
		EndIf
	EndIf

Return .T.