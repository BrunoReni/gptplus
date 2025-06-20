#Include "PROTHEUS.CH"
#INCLUDE "QNCA150.CH"
#INCLUDE "FiveWin.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QNCA150  � Autor � Leandro 				� Data � 15/02/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Tipos de Documento x Etapa					  ���
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
				 {STR0002, "QNCA150ATU"	, 0, 2 },;	    //"Visualizar"
				 {STR0003, "QNCA150ATU"	, 0, 3 },;	    //"Incluir"
				 {STR0004, "QNCA150ATU"	, 0, 4, 82 },;	//"Alterar"
				 {STR0005, "QNCA150ATU"	, 0, 5, 3 }} 	//"Excluir"

Return aRotina

Function QNCA150()
PRIVATE cCadastro := STR0006//"Cadastro de Tipos de Documento x Etapa"
PRIVATE aRotina   := MenuDef()

DbSelectArea("QUT")
DbSetOrder(1)

If !QNCHECK()
	Return(NIL)
Endif	

mBrowse( 6, 1,22,75,"QUT")

DbSelectArea("QUT")
Set Filter To
DbSetOrder(1)

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QNCA150ATU� Autor � Leandro				� Data �15/02/08  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao do cadastro de Tipos de Documentos X Etapa      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QNCA150ATU(cAlias,nReg,nOpc)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QNCA150ATU                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QNCA150ATU(cAlias,nReg,nOpc)
Local oDlg
Local bCampo := { |nCPO| Field(nCPO) }
Local nI     := 0
Local aTela  := {}
Local aGets  := {}
Local lOk    := .F.

DbSelectArea("QUT")
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
	M->QUT_FILIAL:= xFilial("QUT") 
Else
   For nI := 1 To FCount()
       M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
   Next nI
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro)	FROM 050,000 TO 210,610 OF oMainWnd PIXEL
EnChoice("QUT",nReg,nOpc,,,,,{015,2,075,300},,)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := If(Obrigatorio(aGets,aTela),oDlg:End(),.F.)},	{||lOk := .F.,oDlg:End()})CENTERED

If (!lOk) .Or. nOpc == 2
	Return NIL
Endif
	
If nOpc == 5
	RecLock("QUT", .F.)
	dbDelete()
	MsUnLock()
	dbSkip()
Else
	If nOpc == 3
		If QNC150Valid()
			RecLock( "QUT", .T. )
		Else
			Return()
		Endif	
	Else
		RecLock( "QUT", .F. )
	EndIf
	For nI := 1 TO FCount()
		FieldPut(nI,M->&(Eval(bCampo,nI)))
	Next nI
	MsUnlock()                  
	FKCOMMIT()
Endif	

Return NIL

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �QNC150Valid � Autor � Leandro              � Data �15/02/08  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica a existencia de documentos cadastradas para uma    ���
���			 � mesma etapa          									   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � A150Valid                                            	   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function QNC150Valid()
Local lRetorno  := .T.
Local aArea 	:= GetArea()

dbSelectArea("QUT")
dbSetOrder(1)
dbSeek( xFilial("QUT")+AllTrim(M->QUT_ETAPA)+AllTrim(M->QUT_TIPODC))

If Empty(M->QUT_ETAPA)
	MSGAlert(STR0008)//"Campo Etapa nao foi informado."
	lRetorno := .F.
Else
	If Empty(M->QUT_TIPODC)
		MSGAlert(STR0009)//"Campo Tipo de documento nao foi informado"
		lRetorno := .F.
	Else
		If Found() 
			MSGAlert(STR0007)//"Tipo de documento jA cadastrado para essa etapa."
			lRetorno := .F.
		Endif
	Endif		
EndIf

RestaRea(aArea)

Return(lRetorno)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �QNC150IniEtapa� Autor � Leandro            � Data �15/02/08  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a descrica da etapa								   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � QNC150IniEtapa                                          	   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � X3_RELACAO do campo QUT_DESETA                              ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function Q150IniEtapa(cEtapa)
Local cDesc := ""
Local aArea := GetArea()

dbSelectArea("QID")
dbSetOrder(1)
dbSeek( xFilial("QID")+AllTrim(cEtapa))

If Found() 
	cDesc := QID->QID_DESCTP
EndIf

RestaRea(aArea)

Return(cDesc)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �QNC150IniDoc  � Autor � Leandro            � Data �15/02/08  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a descrica da documento  						   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � QNC150IniDoc                                          	   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � X3_RELACAO do campo QUT_DESDOC                              ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function Q150IniDoc(cDOC)
Local cDesc := ""
Local aArea := GetArea()

dbSelectArea("QUU")
dbSetOrder(1)
dbSeek( xFilial("QUU")+AllTrim(cDOC))

If Found() 
	cDesc := QUU->QUU_DESCDO
EndIf

RestaRea(aArea)

Return(cDesc)



