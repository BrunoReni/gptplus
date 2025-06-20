#INCLUDE "PROTHEUS.CH"
#INCLUDE "CNTA060.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CNTA060  � Autor � Andre Lago            � Data �15.07.2010���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Manutencao de Tipos de Documentos                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CNTA060()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CNTA060(nPosArotina,lAutomato)

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������

PRIVATE cFiltraCN5	:= ""
PRIVATE aRotina		:= MenuDef()
PRIVATE cCadastro		:= OemToAnsi(STR0001)	//"Tipos de Documentos"

DEFAULT nPosArotina := 0
DEFAULT lAutomato   := .F.

If nModulo == 69
	cFiltraCN5 	:= "CN5_MODULO $ 'GCT|AMB'" //Pertence ao GCT e AMBOS
ElseIf nModulo == 6
	cFiltraCN5 	:= "CN5_MODULO $ 'FIN|AMB' .And. CN5_SEQ == '00'" //Pertence ao FIN e AMBOS
EndIf

dbSelectArea("CN5")
CN5->(dbSetFilter({|| &(cFiltraCN5)},cFiltraCN5))
If	nPosArotina > 0
	bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
	Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina,lAutomato)
Else
	mBrowse( 6, 1,22,75,"CN5")
EndIf
CN5->(dbClearFilter())


Return NIL

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CN060Man  � Autor � Andre Lago            � Data � 15/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de Manutencao Tipo documento                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Alias do cabecalho do Tipo documento                 ���
���          �ExpN2: Recno do cabecalho do Tipo documento                 ���
���          �ExpN3: Opcao do arotina                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � CN060Man()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CN060Man(cAlias,nReg,nOpc,lAutomato)

Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := MsAdvSize()

Local cSeek     := ""
Local cWhile    := ""

Local oDlg

Local lContinua := .T.
Local lInclui   := (nOpc == 3)
Local lAltera   := (nOpc == 4)

Local nX        := 0
Local nOpca     := 0
Local nSaveSx8  := GetSx8Len()
Local aCpoGDa   := {'CN5_SEQ','CN5_CODOPC','CN5_DESOPC'} // Vetor responsavel pela montagem da aHeader
Local cFilCN5	  := ""
Local bFilCN5
Local nRecno	  := 0
Local n1Cnt	  := 0


//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aCols     := {}
Private aHeader   := {}
Private aTELA[0][0],aGETS[0]
Private aYesFields := {}
Private aCampos	:= {}

DEFAULT lAutomato := .F.

dbSelectArea("CN5")
//Salva o filtro atual
cFilCN5 := cFiltraCN5
bFilCN5 := {|| &(cFilCN5)}

If nOpc > Len(aRotina)
	nOpc := 1
Endif

If nOpc == 5
	//Elimina o filtro criado pelo browse
	CN5->(dbClearFilter())

	lContinua := CN060DEL(CN5->CN5_CODIGO)

	//Filtra novamente os registros
	dbSetFilter(bFilCN5,cFilCN5)
Endif

If lContinua
	dbSelectArea("CN5")
	dbSetOrder(4)
	dbSeek(xFilial("CN5")+CN5->CN5_CODIGO+"00",.F.)

	If lInclui
		RegToMemory( "CN5", .T., .F. )
	Else
		If SoftLock("CN5")
			RegToMemory( "CN5", .F., .F. )
		Else
			lContinua := .F.
		EndIf
	EndIf

	dbSelectArea("CN5")
	dbSetOrder(4)

	If lContinua

		// Carrega aHeader
		DbSelectArea("SX3")
		SX3->(DbSetOrder(2)) // Campo
		For nX := 1 to Len(aCpoGDa)
			If SX3->(DbSeek(aCpoGDa[nX]))
				Aadd(aHeader,{ AllTrim(X3Titulo()),;
							GetSx3Cache(aCpoGDa[nX],'X3_CAMPO')		,;
							GetSx3Cache(aCpoGDa[nX],'X3_PICTURE')	,;
							GetSx3Cache(aCpoGDa[nX],'X3_TAMANHO')	,;
							GetSx3Cache(aCpoGDa[nX],'X3_DECIMAL')	,;
							GetSx3Cache(aCpoGDa[nX],'X3_VALID')		,;
							GetSx3Cache(aCpoGDa[nX],'X3_USADO')		,;
							GetSx3Cache(aCpoGDa[nX],'X3_TIPO')		,;
							GetSx3Cache(aCpoGDa[nX],'X3_F3')		,;
							GetSx3Cache(aCpoGDa[nX],'X3_CONTEXT')	,;
							GetSx3Cache(aCpoGDa[nX],'X3_CBOX')		,;
							GetSx3Cache(aCpoGDa[nX],'X3_RELACAO')})
			Endif
		Next nX

		If !lInclui
			cSeek  := xFilial("CN5")+M->CN5_CODIGO
			cWhile := "CN5->CN5_FILIAL+CN5->CN5_CODIGO"
	        nRecno := CN5->(Recno())
			// Carregue aqui a Montagem da sua aCol
			aAux := {}
			dbSelectArea("CN5")
			//Elimina o filtro criado pelo browse
			EndFilBrw("CN5")
			dbSetOrder(4)
			dbSeek(cSeek,.F.)
			While CN5->(!eof()) .and. cSeek == &cWhile
				aAux := {}
				If CN5->CN5_SEQ == "00"
					CN5->(dbSkip())
					Loop
				EndIf
				For nX := 1 to Len(aCpoGDa)
					dbSelectArea("SX3")
					SX3->(DbSetOrder(2)) // Campo
					If DbSeek(aCpoGDa[nX])
						If GetSx3Cache(aCpoGDa[nX],'X3_CONTEXT') == "V"
							nRecno := CN5->(recno())
							Aadd(aAux,Posicione("CN5",1,xFilial("CN5")+CN5->CN5_CODOPC+"00","CN5_DESCRI"))
							CN5->(dbGoTo(nRecno))
						Else
							Aadd(aAux,CN5->&(GetSx3Cache(aCpoGDa[nX],'X3_CAMPO')))
						EndIf
					EndIf
				Next nX
				Aadd(aAux,.F.)
				Aadd(aCols,aAux)
				dbSelectArea("CN5")
		   	dbSkip()
			Enddo
			//Filtra novamente os registros
		  	dbSetFilter(bFilCN5,cFilCN5)
         	dbGoTo(nRecno)
		Endif

		If Empty(aCols)
			aAux := {}
			For nX := 1 to Len(aCpoGDa)
				dbSelectArea("SX3")
				SX3->(DbSetOrder(2)) // Campo
				If DbSeek(aCpoGDa[nX])
					Aadd(aAux,CriaVar(AllTrim(GetSx3Cache(aCpoGDa[nX],'X3_CAMPO'))))
				Endif
			Next nX
			Aadd(aAux,.F.)
			Aadd(aCols,aAux)
			aCols[1][aScan(aHeader,{|x| Trim(x[2])=="CN5_SEQ"})] := StrZero(1,Len(CN5->CN5_SEQ))
		Endif
		If	lAutomato
			If	nOpc == 5
				nOpca := 1
			ElseIf	FindFunction("GetParAuto")
				aRetAuto := GetParAuto("CNTA060TESTCASE")
				M->CN5_CODIGO := aRetAuto[1,1,2]
				M->CN5_DESCRI := aRetAuto[1,2,2]
				M->CN5_IMPFIN := aRetAuto[1,3,2]
				M->CN5_MODULO := aRetAuto[1,4,2]
				M->CN5_EMAIL  := aRetAuto[1,5,2]
				If	Len(aRetAuto[2])>0
					aCols:={}
					For nX := 1 To Len(aRetAuto[2])
						AAdd(aCols,Array(Len(aHeader)+1))
						For n1Cnt := 1 To Len(aRetAuto[2,nX])

							nSeek := ASCan(aHeader,{|x| AllTrim(x[2])==aRetAuto[2,nX,n1Cnt,1]})

							aCols[Len(aCols),nSeek]:=aRetAuto[2,nX,n1Cnt,2]
						Next
						aCols[Len(aCols)][Len(aHeader)+1] := .F.
					Next
				EndIf
				nOpca := 1
			EndIf
		Else

			aObjects := {}
			AAdd( aObjects, { 100, 100, .t., .t. } )
			AAdd( aObjects, { 100, 100, .t., .t. } )

			aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
			aPosObj := MsObjSize( aInfo, aObjects )

			aCampos := { "CN5_CODIGO", "CN5_DESCRI", "CN5_IMPFIN", "CN5_MODULO", "CN5_EMAIL" }
			
			If CN5->(FieldPos('CN5_ASSINA') > 0)
				aAdd(aCampos, "CN5_ASSINA")
			EndIf
			
		 	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
				EnChoice( "CN5", nReg, nOpc,,,,aCampos,aPosObj[1], , 3, , , , , ,.F. )
				oGetD := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],IIF(!lInclui.And.!lAltera,0,GD_INSERT+GD_UPDATE+GD_DELETE),"CN060LinOk()","CN060TudOk()","+CN5_SEQ",/*alteraveis*/,/*freeze*/,4096,/*fieldok*/,/*superdel*/,/*delok*/,,aHeader,aCols)

			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,aCols:=oGetD:aCols,If(Obrigatorio(aGets,aTela) .And. oGetD:TudoOk(),oDlg:End(), nOpca :=  0 )},{|| nOpca := 2,oDlg:End()})
		EndIf

		If nOpca == 1
			EndFilBrw("CN5")
			Begin Transaction
				lGravou := CN060Grava(nOpc-2,aCols,aHeader)

				If ( lGravou )
					EvalTrigger()
					While (GetSx8Len() > nSaveSx8)
						ConfirmSx8()
					EndDo
				EndIf

			End Transaction

			dbSetFilter(bFilCN5,cFilCN5)

			While (GetSx8Len() > nSaveSx8)
				RollBackSx8()
			EndDo

			MsUnlockAll()
		Else
			While (GetSx8Len() > nSaveSx8)
				RollBackSx8()
			EndDo
		Endif
	Endif

Endif

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CN060Grava� Autor � Andre Lago            � Data � 15/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de Gravacao                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Alias do cabecalho do Tipo de Documento              ���
���          �ExpN2: Recno do cabecalho do Tipo de Documento              ���
���          �ExpN3: Opcao do arotina                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � CN060Grava()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CN060Grava(nOpcao,aCols,aHeader)

Local aArea     := GetArea()
Local bCampo 	:= {|nCPO| Field(nCPO) }
Local lGravou   := .F.
Local lOk		:= .T.
Local ni        := 0
Local nX        := 0
Local nY        := 0
Local lContinua := .F.
Local nPosOpc	:= ASCAN(aHeader,{|x| AllTrim(x[2])=="CN5_CODOPC"})
Local nPosSeq	:= ASCAN(aHeader,{|x| AllTrim(x[2])=="CN5_SEQ"})

Do Case
Case nOpcao <> 3

	//��������������������������������������������������������������Ŀ
	//�Grava o Cabecalho                                             �
	//����������������������������������������������������������������
	dbSelectArea("CN5")
	dbSetOrder(4)		//CN5_FILIAL+CN5_CODIGO+CN5_SEQ
	If MsSeek(xFilial("CN5")+M->CN5_CODIGO)
		RecLock("CN5",.F.)
	Else
		RecLock("CN5",.T.)
	EndIf
	For nX := 1 TO FCount()
		FieldPut(nX,M->&(EVAL(bCampo,nX)))
	Next nX
	CN5->CN5_FILIAL := xFilial("CN5")
	CN5->CN5_CODOPC := ""
	CN5->CN5_SEQ    := "00"

	CN5->(FkCommit())

	lContinua := .F.
	For nX := 1 To Len(aCols)
		If !Empty(aCols[nX][nPosOpc])
			lContinua := .T.
		Endif
	Next nX

	If lContinua

		dbSelectArea("CN5")

		For nX := 1 To Len(aCols)

			If !aCols[nX,Len(aCols[nX])]

				If !Empty(aCols[nX][nPosOpc])
					If CN5->(dbSeek(xFilial("CN5")+M->CN5_CODIGO+aCols[nX][nPosSeq]))
						RecLock("CN5",.F.)
					Else
						RecLock("CN5",.T.)
					EndIf
				Endif

				For ni := 1 TO FCount()
					FieldPut(ni,M->&(EVAL(bCampo,ni)))
				Next ni

				For nY := 1 To Len(aHeader)
					If ( aHeader[nY][10] != "V" )
						CN5->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
					EndIf
				Next nY
				CN5->CN5_FILIAL := xFilial("CN5")
				MsUnLock()

			Else

				dbSelectArea("CN5")
				If !Empty(aCols[nX][nPosOpc])
					If CN5->(dbSeek(xFilial("CN5")+M->CN5_CODIGO+aCols[nX][nPosSeq]))
						RecLock("CN5")
						dbDelete()
						MsUnlock()
					Endif
				EndIf

			Endif

		Next nX

	Endif

	lGravou := .T.

OtherWise

	If lOk

		lContinua := .F.
		For nX := 1 To Len(aCols)
			If !Empty(aCols[nX][nPosOpc])
				lContinua := .T.
			Endif
		Next nX

		If lContinua

			dbSelectArea("CN5")
			For nX := 1 To Len(aCols)
				If !Empty(aCols[nX][nPosOpc])
					If CN5->(dbSeek(xFilial("CN5")+M->CN5_CODIGO+aCols[nX][nPosSeq]))
						RecLock("CN5")
						dbDelete()
						MsUnlock()
					EndIf
				Endif
			Next nX

	    Endif

		If CN5->(dbSeek(xFilial("CN5")+M->CN5_CODIGO+"00"))
			RecLock("CN5",.F.)
			dbDelete()
			MsUnlock()
		EndIf

		lGravou := .T.
	EndIf

EndCase

RestArea(aArea)

Return(lGravou)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �CN060LinOk� Autor �Andre Lago             � Data �15/07/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da Linha Ok da Getdados do desmembramento do      ���
���          �Tipo de Documento                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica se a linha e valida                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo efetuar a validacao da linhaOk���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Observacao�                                                            ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CN060LinOk()

Local lRet     := .T.

If M->CN5_CODIGO == aCols[n][aScan(aHeader,{|x| Trim(x[2])=="CN5_CODOPC"})]
	Help(" ",1,"CA060DOC1")		//"Tipo de Documento n�o pode ser opcional dele mesmo!"##"Informe outro c�digo como opcional."
	lRet := .F.
EndIf
//reset na variavel para nao duplicar na browse
IIf(!Empty(M->CN5_CODOPC),M->CN5_CODOPC := "",.F.)

Return(lRet)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �CN060TudOk� Autor �Andre Lago             � Data �15/07/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da TudoOk da Getdados do desmembramento do tipo de���
���          �documento                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica se todos os itens sao validos                 ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo efetuar a validacao da TudoOk ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Observacao�                                                            ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CN060TudOk()

Local lRet     := .T.
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CN060DEL � Autor � Marcelo Custodio      � Data �06.12.2005���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao da exclusao do tipo de documento                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN060DEL()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN060DEL()

Local lRet := .T.
Local nRecno 	:= Recno()
Local aArea    := GetArea()

//�������������������������������������������������������������������������Ŀ
//�Valida a existencia do registro na amarracao                             �
//�Tipo de Documento X Tipo de Contrato X Situacao                          �
//���������������������������������������������������������������������������
dbSelectArea("CNJ")
dbSetOrder(3)//Tipo de Documento

lRet := !(MsSeek(xFilial('CNJ')+CN5->CN5_CODIGO, .F.))


//�������������������������������������������������������������������������Ŀ
//�Valida a existencia do registro no cadastro de documentos                �
//���������������������������������������������������������������������������
if lRet
	dbSelectArea("CNK")
	dbSetOrder(2)//Tipo de Documento
	lRet := !(MsSeek(xFilial('CNK')+CN5->CN5_CODIGO, .F.))
EndIf

If lRet
	dbSelectArea("CN5")
	dbSetOrder(3)		//CN5_FILIAL+CN5_CODOPC
	lRet := !(MsSeek(xFilial('CN5')+CN5->CN5_CODIGO, .F.))
	dbGoTo(nRecno)
EndIf

//�����������������������������������������������������������������������������Ŀ
//�Valida a existencia do registro no cadastro de amarra��o entre doc x evento	�
//�������������������������������������������������������������������������������
If lRet
	dbSelectArea("FR9")
	dbSetOrder(2)		//FR9_FILIAL+FR9_DOCUM+FR9_EVENTO
	lRet := !(MsSeek(xFilial('FR9')+CN5->CN5_CODIGO, .F.))
EndIf

//�������������������������������������������������������������������������Ŀ
//�Valida a existencia de titulos a pagar vinculados ao tipo de documento   �
//���������������������������������������������������������������������������
If lRet
	dbSelectArea("FRD")
	dbSetOrder(2)
	lRet := !(MsSeek(xFilial('FRD')+CN5->CN5_CODIGO, .F.))
EndIf

If !lRet
	Help( " ", 1, "CNTA060_01" )
Endif

RestArea(aArea)

return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabio Alves Silva     � Data �05/10/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     		  ���
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

Private aRotina	:= {}

Aadd( aRotina, {STR0004	,"AxPesqui" , 0 , 1,0,.F.  } )	//"Pesquisar"
Aadd( aRotina, {STR0005	,"CN060Man" , 0 , 2,0,nil  } )	//"Visualizar"
Aadd( aRotina, {STR0006	,"CN060Man" , 0 , 3,0,nil  } )	//"Incluir"
Aadd( aRotina, {STR0007	,"CN060Man" , 0 , 4,0,nil  } )	//"Alterar"
Aadd( aRotina, {STR0008	,"CN060Man" , 0 , 5,3,nil  } )	//"Excluir"

Return (aRotina)

/*/{Protheus.doc} CN060F3
//Defini��o de campos que ser�o exibidos na op��o visualizar da consulta padr�o CN5
@author juan.felipe
@since 23/10/2019
@version 1.0
@return return, Nil
@type function
/*/
Function CN060F3() 
	Local aCampos := {"CN5_CODIGO","CN5_DESCRI","CN5_IMPFIN","CN5_MODULO","CN5_EMAIL"} //campos que ser�o exibidos
	AxVisual("CN5", CN5->(RECNO()), 2, aCampos,,,,,.F.)
Return
