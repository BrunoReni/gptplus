#Include "PROTHEUS.CH"
#INCLUDE "QNCA140.CH"
#INCLUDE "FiveWin.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QNCA140  � Autor � Leandro 				� Data � 14/02/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Tipos de Documentos    						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQNC                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function MenuDef()

Local aRotina := {{STR0001, "AxPesqui"	, 0, 1,,.F.},;	//"Pesquisar"
				 {STR0002, "QNCA140ATU"	, 0, 2 },;	    //"Visualizar"
				 {STR0003, "QNCA140ATU"	, 0, 3 },;	    //"Incluir"
				 {STR0004, "QNCA140ATU"	, 0, 4, 82 },;	//"Alterar"
				 {STR0005, "QNCA140ATU"	, 0, 5, 3 }} 	//"Excluir"

Return aRotina

Function QNCA140()
PRIVATE cCadastro := STR0006//"Cadastro de Tipos de Documento"
PRIVATE aRotina   := MenuDef()

If !QNCHECK()
	Return(NIL)
Endif	

DbSelectArea("QUU")
DbSetOrder(1)

mBrowse( 6, 1,22,75,"QUU")

DbSelectArea("QUU")
Set Filter To
DbSetOrder(1)

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QNCA140ATU� Autor � Leandro				� Data �14/02/08  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao do cadastro de Tipos de Documentos			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QNCA140ATU(cAlias,nReg,nOpc)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QNCA140ATU                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QNCA140ATU(cAlias,nReg,nOpc)
Local oDlg
Local bCampo  := { |nCPO| Field(nCPO) }
Local nI      := 0
Local aTela   := {}
Local aGets   := {}
Local lOk     := .F.
Local lDelete := .T.

DbSelectArea("QUU")
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
Else
   For nI := 1 To FCount()
       M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
   Next nI
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro)	FROM 005,000 TO 300,570 OF oMainWnd PIXEL
EnChoice("QUU",nReg,nOpc,,,,,{37,3,140,280},,)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := If(Obrigatorio(aGets,aTela) .And. QNC140Valid(nOpc),oDlg:End(),.F.)},	{||lOk := .F.,oDlg:End()})CENTERED

If (!lOk) .Or. nOpc == 2
	Return NIL
Endif
	
If nOpc == 5
	
	dbSelectArea("QUT")
   	While QUT->(!Eof())
		If QUT->QUT_TIPODC == M->QUU_TIPODC
			lDelete := .F.
			Exit
		Endif	
		QUT->(dbSkip())
    Enddo

	If lDelete
		RecLock("QUU", .F.)
		dbDelete()
		MsUnLock()
		dbSkip()
	ELSE
		Aviso(STR0010,STR0011, {"ok"})//"Atencao"##"Esse titulo esta associado a uma etapa"
	Endif	
Else
	If nOpc == 3 .Or. nOpc == 4
		If QNC140Valid()
			If nOpc == 3
				RecLock( "QUU", .T. )
			Else 
				RecLock( "QUU", .F. )
			Endif			
		Else
			Return ()
		Endif	
	EndIf
	For nI := 1 TO FCount()
		FieldPut(nI,M->&(Eval(bCampo,nI)))
		QUU->QUU_FILIAL := xFilial('QUU')
	Next nI
	MsUnlock()                  
	FKCOMMIT()
Endif	

Return NIL

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �QNC140Valid � Autor � Leandro              � Data �14/02/08  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica a existencia da habilidades cadastradas para uma   ���
���			 � mesma etapa          									   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � A130Valid                                            	   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function QNC140Valid(nOpc)
Local lRetorno  := .T.
Local aArea 	:= GetArea()

dbSelectArea("QUU")
dbSetOrder(1)
dbSeek( xFilial("QUU")+AllTrim(M->QUU_TIPODC))

If Empty(M->QUU_TIPODC)
	MsgAlert(STR0008)//"Codigo do documento nao foi preenchido!"
	lRetorno := .F.
Else
	If Empty(M->QUU_DESCDO)
		MsgAlert(STR0009)//"A descricao do documento nao foi informado"
		lRetorno := .F.
	Else
		If Found() .And. nOpc == 3  
			MSGAlert(STR0007)//"Tipo de documento jA cadastrado."
			lRetorno := .F.
		EndIf
	Endif
Endif		

RestaRea(aArea)

Return(lRetorno)
