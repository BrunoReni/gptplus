#INCLUDE "PLSa040.ch"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA040 � Autor � Tulio Cesar          � Data � 23.02.2001 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Cadastro de Acomodacoes                                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus 5.08                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLSA040

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Declaracao de variaveis...                                          �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	PRIVATE aRotina      := MenuDef()
	PRIVATE cCadastro 	:= fundesc() //"Tipos de Acomodacao"
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Chama funcao de Browse...                                           �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	BI4->(DbSetOrder(1))
	BI4->(dbGoTop())
	PLSAJU040()
	BI4->(mBrowse(06,01,22,75,"BI4"))
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Fim da Rotina Principal...                                          �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Return Nil
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � PL040MOV � Autor � Michele Tatagiba      � Data � 26.09.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Tipos de Acomodacao                                        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � PL040MOV(cAlias,nReg,nOpc)                                 潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PL040MOV(cAlias,nReg,nOpc)
	Local I__f := 0
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Uso na enchoice...                                                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	LOCAL nOpca := 0
	LOCAL cChave := BI4->BI4_CODACO
	Local lEspelhar := GetNewPar("MV_INTACOM",.F.) // Parametro Integracao das Tabelas de Acomoda鏾es PLS X GH
	Local LNovG07:=.T.
	Local lAchou	:=.F.
	Local aAreaBI4
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Dados da Enchoice...                                                �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	PRIVATE aTELA[0][0]
	PRIVATE aGETS[0]
	PRIVATE oEncBI4
	PRIVATE oDlg
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� GetDados das Redes de Atendimento Relacionadas...                   �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	PRIVATE aCabAco   := {}
	PRIVATE aDadAco   := {}
	PRIVATE aTrbAco   := {}
	PRIVATE oBrwAco
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Genericos...                                                        �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	PRIVATE nOpcx	    := nOpc
	PRIVATE nAlt := 020


	aSize := MsAdvSize(.T.)
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Monta Dialogo...                                                    �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If Val(GetVersao(.F.)) >= 12 //Valida vers鉶 12
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
		nAlt := 030
	Else
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault()
	EndIf
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Define folder...                                                    �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	@ nAlt,003 FOLDER oFolder SIZE 350,175 OF oDlg PIXEL PROMPTS  STR0005,;
		STR0007 //"Tipos de Acomodacao Relacionados"
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� ENCHOICE (BI4)                                                      �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If nOpcx == K_Incluir
		Copy "BI4" TO Memory Blank
	Else
		Copy "BI4" TO Memory
	Endif
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� MSMGET -> CONTRATO                                                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	cAlias:="BI4"
	nReg:=BI4->(RecNo())
	oEncBI4 := BI4->(MSMGet():New(cAlias,nReg,nOpcx,,,,,{005,005,156,343},,,,,,oFolder:aDialogs[1],,,.F.))
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� REDES DE ATENDIMENTO RELACIONADAS (BG2)                             �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	cChave := BI4->BI4_CODACO

	aAreaBI4 := FwGetArea()

	Store Header "BIR" TO aCabAco For .T.
	If nOpcx == K_Incluir
		Store COLS Blank "BIR" TO aDadAco FROM aCabAco
	Else
		BIR->(DbSetOrder(1))
		If ! BIR->(MsSeek(xFilial("BIR")+cChave))
			Store COLS Blank "BIR" TO aDadAco FROM aCabAco
		Else
			Store COLS "BIR" TO aDadAco FROM aCabAco VETTRAB aTrbAco While BIR->BIR_CODACO == cChave
		Endif
	Endif

	FwRestArea(aAreaBI4)
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� GETDADOS -> REDES DE ATENDIMENTO RELACIONADAS...                    �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If Val(GetVersao(.F.)) >= 12 // Caso a versao seja maior ou igual a 12
		aDifSize:= {,,,,35,3,,}
		oBrwAco := TPLSBrw():New(005,005,335,150,nil  ,oFolder:aDialogs[2],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabAco,aDadAco,.F.,"BIR",nOpcx,STR0006,nil,nil,nil,nil,nil,,,,,,,,,,,,aDifSize) //"Acomodacoes Relacionadas"
	Else
		oBrwAco := TPLSBrw():New(005,005,335,150,nil  ,oFolder:aDialogs[2],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabAco,aDadAco,.F.,"BIR",nOpcx,STR0006,nil,nil) //"Acomodacoes Relacionadas"
	EndIf
	oBrwAco:aVetTrab := aClone(aTrbAco)

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Ativa Dialog                                                        �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	ACTIVATE MSDIALOG oDlg ON INIT(A040Init(oDlg,{|| nOpca := 1,if(Obrigatorio(oEncBI4:aGets,oEncBI4:aTela) .And. PLSA040Del(nOpc), Eval({|| oDlg:End()}) ,(nOpca:=3,.F.))},{|| nOpca := 3,oDlg:End()}))
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Inicio da Rotina de Gravacao dos Dados...                           �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If nOpca == K_OK
		If nOpcx <> K_Visualizar
			BI4->(DbGoTo(nReg))

			If nOpc == K_Incluir
				If lEspelhar
					If  ! Empty(M->BI4_CODACO)
						DbSelectarea ("G07")
						G07->(DbSetOrder(1))
						lNovG07 := (G07->(MsSeek(xFilial("G07")+M->BI4_CODACO)))
					Else
						lNovG07 := .T.
					Endif
				Endif

				If  ! LNovG07
					DbSelectarea ("BBL")
					BBL->(DbSetOrder(2))
					If 	BBL->(MsSeek(xFilial("BBL")+"PLSA040   "+"BI4"+"G07"))
						RecLock("G07", .T.)
						G07->G07_FILIAL := xFilial("G07")
						PlsSinc("PLSA040   ","BI4","G07")
						MsUnlock()
					Else
						If GetNewPar("MV_PLSMSGS","1") == "1"
							MsgAlert(OemtoAnsi(STR0008)) //"Arquivo de sincronismo entre BI4 x G07 nao esta integro. Verifique!"
						Endif
					Endif
				Endif
			ElseIf nOpc == K_Alterar
				If lEspelhar
					DbSelectarea ("G07")
					G07->(DbSetOrder(1))
					If BI4->(FieldPos("BI4_REFIGH"))>0
						If !Empty(M->BI4_REFIGH) .and. G07->(MsSeek(xFilial("G07")+M->BI4_REFIGH))
							lAchou:=.T.
						Else
							lAchou:= G07->(MsSeek(xFilial("G07")+M->BI4_CODACO))
						Endif
						If lAchou
							DbSelectarea ("BBL")
							BBL->(DbSetOrder(2))
							If 	BBL->(MsSeek(xFilial("BBL")+"PLSA040   "+"BI4"+"G07"))
								RecLock("G07", .F.)
								PlsSinc("PLSA040   ","BI4","G07")
								MsUnlock()
							Else
								If GetNewPar("MV_PLSMSGS","1") == "1"
									MsgAlert(OemtoAnsi(STR0008)) //"Arquivo de sincronismo entre BAU x SA2 nao esta integro. Verifique!"
								Endif

							Endif
						Endif
					Endif
				Endif

			ElseIf nOpc == K_Excluir
				If lEspelhar
					DbSelectarea ("G07")
					G07->(DbSetOrder(1))
					If G07->(MsSeek(xFilial("G07")+M->BI4_CODACO))
						DbSelectarea ("BBL")
						BBL->(DbSetOrder(2))
						If BBL->(MsSeek(xFilial("BBL")+"PLSA040   "+"BI4"+"G07"))
							RecLock("G07", .F.)
							DbDelete()
							MsUnlock()
						Else
							If GetNewPar("MV_PLSMSGS","1") == "1"
								MsgAlert(OemtoAnsi(STR0008)) //"Arquivo de sincronismo entre BAU x SA2 nao esta integro. Verifique!"
							Endif
						Endif

					Endif
				Endif

			EndIf

			PLUPTENC("BI4",nOpcx)
			aChave := {}
			aadd(aChave,{"BIR_CODACO",M->BI4_CODACO})
			oBrwAco:Grava(aChave)
		Endif
	Endif
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Fim da Rotina Principal de Movimentacao                             �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Return
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � A040Init   � Autor � Michele Tatagiba    � Data � 26.09.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Barra de Ferramentas                                       潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function A040Init(oDlg,bOk,bCancel,lMessageDel)
	LOCAL aButtons    := {}

Return(EnchoiceBar(oDlg,bOk,bCancel,.F.,aButtons))

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � PLSA040Del � Autor � Wagner Mobile Costa � Data � 03.10.03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Validacao de delecao do cadastro de acomodacoes            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLSA040Del(nOpc)

	LOCAL lRet		:= .T.
	LOCAL aChaves 	:= {}

	If nOpc # K_Excluir
		Return .T.
	Endif

	aadd(aChaves,{"BI3","BI3_CODACO",BI4->(BI4_CODACO)}) //Produto
	aadd(aChaves,{"BE4","BE4_PADINT",BI4->(BI4_CODACO)}) //Internacoes
	aadd(aChaves,{"BP9","BP9_CODACO",BI4->(BI4_CODACO)}) //Diarias
	aadd(aChaves,{"BT6","BT6_CODACO",BI4->(BI4_CODACO)}) //SubContrato X Produto

	lRet := PLSCHKDEL(aChaves)


Return(lRet)

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Darcio R. Sporl       � Data �22/12/2006潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Utilizacao de menu Funcional                               潮�
北�          �                                                            潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矨rray com opcoes da rotina.                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砅arametros do array a Rotina:                               潮�
北�          �1. Nome a aparecer no cabecalho                             潮�
北�          �2. Nome da Rotina associada                                 潮�
北�          �3. Reservado                                                潮�
北�          �4. Tipo de Transa噭o a ser efetuada:                        潮�
北�          �		1 - Pesquisa e Posiciona em um Banco de Dados           潮�
北�          �    2 - Simplesmente Mostra os Campos                       潮�
北�          �    3 - Inclui registros no Bancos de Dados                 潮�
北�          �    4 - Altera o registro corrente                          潮�
北�          �    5 - Remove o registro corrente do Banco de Dados        潮�
北�          �5. Nivel de acesso                                          潮�
北�          �6. Habilita Menu Funcional                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function MenuDef()

	Private aRotina := {	{ STRPL01		,'AxPesqui' , 0 ,K_Pesquisar		,0 ,.F.},; // Pesquisar
		{ STR0001 	,'pl040Mov' , 0 ,K_Visualizar		,0 ,Nil},; //"Visualizar"
		{ STR0002		,'pl040Mov' , 0 ,K_Incluir			,0 ,Nil},; //"Incluir"
		{ STR0003		,'pl040Mov' , 0 ,K_Alterar			,0 ,Nil},; //"Alterar"
		{ STR0004		,'pl040Mov' , 0 ,K_Excluir			,0 ,Nil} } //"Excluir"




	aadd(aRotina, {"Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('BI4',BI4->BI4_CODACO, 1)})", 0 ,K_Visualizar})
	aadd(aRotina, {"Excluir Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('BI4',BI4->BI4_CODACO, 0)})", 0 ,K_Visualizar})



Return(aRotina)


Function PLSAJU040()
	Local cSql     := ""
	Local nQuant   := 0
	Local lRetorno := .F.

	cSql := "SELECT COUNT(BI4_CODEDI) CONTADOR FROM " + RetSQLName("BI4") + " "
	cSql += " WHERE BI4_FILIAL = '" + xFilial("BI4") + "'"
	cSql += "   AND BI4_CODEDI NOT IN ('A','B','C',' ') "
	cSql += "   AND D_E_L_E_T_ = ' ' "

	nQuant := MPSysExecScalar(cSql, "CONTADOR")

	lRetorno := IIF(nQuant > 0, .T., .F.)

	If lRetorno
		PLSCORBI4()
	EndIf

Return

Function PLSCORBI4()
	Local cSql     := ""

	cSql := "SELECT BI4_CODEDI,R_E_C_N_O_ REC FROM " + RetSQLName("BI4") + " "
	cSql += " WHERE BI4_FILIAL = '" + xFilial("BI4") + "'"
	cSql += "   AND BI4_CODEDI NOT IN ('A','B','C',' ') "
	cSql += "   AND D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBI4",.F.,.T.)

	While TRBBI4->(!Eof())

		BI4->(DBGoTo(TRBBI4->REC))
		BI4->( RecLock("BI4", .F.) )

		If TRBBI4->BI4_CODEDI == "1"
			BI4->BI4_CODEDI:= "B"
		ElseIf TRBBI4->BI4_CODEDI == "2"
			BI4->BI4_CODEDI:= "A"
		Else
			BI4->BI4_CODEDI:= "C"
		EndIf
		BI4->( MsUnLock() )
		TRBBI4->(DBSkip())

	EndDo

	TRBBI4->(dbCloseArea())

Return