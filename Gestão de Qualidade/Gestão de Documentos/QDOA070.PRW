#INCLUDE "QDOA070.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QDOA070  � Autor � Aldo Marini Junior    � Data � 21/05/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Localizadores-Palavra Chave	                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QDOA070()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQDO                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���  Data  � BOPS �Programador�Alteracao                                  ���
�������������������������������������������������������������������������Ĵ��
���26/12/01�012341� Eduardo S.� Acerto para gravar corretamente a Filial  ���
���15/03/02� META � Eduardo S.� Refeita a rotina utilizando Enchoice.     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function MenuDef()

Local aRotina  := {{OemToAnsi(STR0001),"AxPesqui"  , 0, 1,,.F.},;	//"Pesquisar"
					{OemToAnsi(STR0002),"QD070Telas", 0, 2},;	//"Visualizar"
					{OemToAnsi(STR0003),"QD070Telas", 0, 3},;	//"Incluir"
					{OemToAnsi(STR0004),"QD070Telas", 0, 4},;	//"Alterar"
					{OemToAnsi(STR0005),"QD070Telas", 0, 5}}	//"Excluir"

Return aRotina

Function QDOA070()

Private cCadastro:= OemToAnsi(STR0006) // "Cadastro de Localizadores - Palavra Chave"
Private cEspecie := "QDOA070 "	// Para gravacao de textos
Private aRotina  := MenuDef()

DbSelectArea("QDK")
DbSetOrder(1)
DbGoTop()
mBrowse(006,001,022,075,"QDK")

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QD070Telas� Autor � Eduardo de Souza      � Data � 15/03/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela Centro de Custos                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QD070Telas(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Alias do arquivo                                   ���
���          � ExpN1 - Numero do registro                                 ���
���          � ExpN2 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQDO                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QD070Telas(cAlias,nReg,nOpc)

Local oDlg
Local nI    := 0
Local nOpcao:= 0

Private bCampo:= {|nCPO| Field( nCPO ) }
Private aTELA[0][0]
Private aGETS[0]

DbSelectArea("QDK")
DbSetOrder(1)

If nOpc == 3 
   For nI := 1 To FCount()
       cCampo := Eval( bCampo, nI )
       lInit  := .F.
       If ExistIni( cCampo )
          lInit := .T.
          M->&( cCampo ) := InitPad( GetSx3Cache(cCampo,"X3_RELACAO") )
	      If ValType( M->&( cCampo ) ) = "C"
	      	 M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo,"X3_TAMANHO") )
          EndIf
          If M->&( cCampo ) == Nil
             lInit := .F.
          EndIf
       EndIf
       If !lInit
          M->&( cCampo ) := FieldGet( nI )
          If ValType( M->&( cCampo ) ) = "C"
             M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
          ElseIf ValType( M->&( cCampo ) ) = "N"
             M->&( cCampo ) := 0
          ElseIf ValType( M->&( cCampo ) ) = "D"
             M->&( cCampo ) := CtoD( "  /  /  " )
          ElseIf ValType( M->&( cCampo ) ) = "L"
             M->&( cCampo ) := .f.
          EndIf
       EndIf
   Next nI
	M->QDK_FILIAL:= xFilial("QDK")
Else
   For nI := 1 To FCount()
       M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
   Next nI
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) FROM 000,000 TO 385,625 OF oMainWnd PIXEL //"Cadastro de Localizadores - Palavra Chave"

Enchoice("QDK",nReg,nOpc,,,,,{032,002,190,312})

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela) .And.;
							        If(nOpc == 4 .Or. nOpc == 5,QD070VdAlt(nOpc),.T.),;
							        (nOpcao:= 1,oDlg:End()),)},{|| oDlg:End()}) CENTERED

If nOpc <> 2 .And. nOpcao == 1
	If nOpc == 3 .Or. nOpc == 4
		QDA070GrCh(nOpc)	
	ElseIf nOpc == 5
		QDA070Dele(nOpc)
	EndIf
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QDA070GrCh� Autor � Eduardo de Souza      � Data � 15/03/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Palavra Chave / Localizadores                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QDA070GrCh(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Opcao do Browse                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQDO                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QDA070GrCh(nOpc)

Local lRecLock:= .F.
Local nI      := 0
Local lRet    := .F.

If nOpc == 3
	lRecLock:= .T.
EndIf

If RecLock("QDK",lRecLock)
	For nI := 1 TO FCount()
		FieldPut(nI,M->&(Eval(bCampo,nI)))
	Next nI
	MsUnLock()      
	lRet:= .T.
EndIf
	
Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QDA070Dele� Autor � Aldo Marini Junior    � Data � 21/05/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de exclusao de Palavras Chave / Localizadores     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QDA070Dele(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Opcao do Browse                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQDO                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QDA070Dele(nOpc)

Begin Transaction
	RecLock("QDK",.F.)
	QDK->(DbDelete())
	MsUnlock()
	QDK->(DbSkip())
End Transaction

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QD070VdAlt� Autor � Eduardo de Souza      � Data � 15/03/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida Alteracao de Assuntos                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QD070VdAlt(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Opcao do Browse                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQDO                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QD070VdAlt(nOpc)

QD6->(dbGoTop())
While QD6->(!Eof())
	If QD6->QD6_CHAVE == QDK->QDK_CHAVE
		If nOpc == 4
			Help(" ",1,"QD070NALT")	// Existem lactos de Palavras-Chave X Docto. Impossivel Alteracao
		ElseIf nOpc == 5
			Help(" ",1,"QD070NDEL")   // Exclusao nao permitida, pois ja existe uma referencia deste registro.
		EndIf
		Return .F.
	Endif
	QD6->(DbSkip())
Enddo
          
Return .T.