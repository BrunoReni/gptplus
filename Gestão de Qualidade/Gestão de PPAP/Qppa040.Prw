#INCLUDE "QPPA040.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE NAOUSADO "���������������"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QPPA040  � Autor � Robson Ramiro A. Olive� Data � 08.09.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Equipe Multifuncional APQP                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPA040(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PPAP                                                       ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui",		0, 1,,.F.},;		//"Pesquisar"
					{ OemToAnsi(STR0002), "PPA040Roti",		0, 2},;		//"Visualizar"
					{ OemToAnsi(STR0003), "PPA040Roti",		0, 3},;		//"Incluir"
					{ OemToAnsi(STR0004), "PPA040Roti",		0, 4},;		//"Alterar"
					{ OemToAnsi(STR0005), "PPA040Roti",		0, 5},;		//"Excluir"
					{ OemToAnsi(STR0007), "QPPR040(.T.)", 	0, 6,,.F.} } 	//"Imprimir"

Return aRotina

Function QPPA040()

Private cFiltro

Private cCadastro := OemToAnsi(STR0006) //"Equipe Multifuncional APQP"

Private aRotina := MenuDef()

DbSelectArea("QKE")
DbSetOrder(1)

cFiltro := 'QKE_ITEM == "01"'

Set Filter To &cFiltro
mBrowse( 6, 1, 22, 75,"QKE",,,,,,)
Set Filter To

Return


/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �PPA040Roti  � Autor � Robson Ramiro A.Olivei� Data �08.09.03  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para Manutencao dos Dados                             ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void PPA040Incl(ExpC1,ExpN1,ExpN2)                           ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                     ���
���          � ExpN1 = Numero do registro                                   ���
���          � ExpN2 = Numero da opcao                                      ���
���������������������������������������������������������������������������Ĵ��
���Uso       � QPPA040                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PPA040Roti(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local lOk 			:= .F.
Local aCposVis		:= {}
Local aCposAlt		:= {}
Local aButtons		:= {}

Private aHeader		:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL

aCposVis := { "QKE_COD", "QKE_DESC", "QKE_DATAC", "QKE_DATAV" }

aCposAlt := aClone(aCposVis)

If nOpc == 2 .or. nOpc == 5
	aButtons := {{"BMPVISUAL",	{ || QPPR040() }, OemToAnsi(STR0008), OemToAnsi(STR0009) }} //"Visualizar/Imprimir" ### "Vis/Prn"
Endif

DbSelectArea(cAlias)

Set Filter To

RegToMemory("QKE",(nOpc == 3))

A040aHead(cAlias)
A040aCols(nOpc)


DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Equipe Multifuncional APQP"
						FROM 120,000 TO 516,780 OF oMainWnd PIXEL

oPanelMain       := TPanel():New(0,0,'',oDlg,, .T., .T., , ,001,001,.T.,.T. )
	oPanelMain:Align := CONTROL_ALIGN_ALLCLIENT
	oPanelTop        := TPanel():New(1,1,'',oPanelMain,, .T., .T., , ,74,64,.T.,.T. )
	oPanelTop:Align  := CONTROL_ALIGN_TOP
	oPanelBot        := TPanel():New(0,0,'',oPanelMain,, .T., .T., , ,010,010,.T.,.T. )
	oPanelBot:Align  := CONTROL_ALIGN_ALLCLIENT

Enchoice("QKE",nReg,nOpc, , , ,aCposVis ,{01,01,398,390}, aCposAlt, , , , , oPanelTop)

oGet := MSGetDados():New(01,01,398,390, nOpc,"PP040LinOk","PP040TudOk","+QKE_ITEM",.T.,,,,,,,,,oPanelBot)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP040TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,aButtons ) CENTERED

If lOk .and. (nOpc == 3 .or. nOpc == 4)
	PPA040Grav(nOpc)
Endif

If nOpc == 5 .and. lOk
	A040Dele()
Endif

Set Filter To &cFiltro

Return


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA040Grav� Autor � Robson Ramiro A Olivei� Data � 08.09.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Gravacao Equipe Multifuncional APQP            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA040Grav(ExpC1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Exp1N = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA040Grav(nOpc)

Local nIt		:= 0
Local nNumItem	:= 0
Local nPosDel	:= Len(aHeader) + 1
Local lGraOk	:= .T.
Local nCont		:= 0
Local nCpo
Local bCampo	:= { |nCPO| Field(nCPO) }

DbSelectArea("QKE")
DbSetOrder(1)
	
Begin Transaction

nNumItem := 1  // Contador para os Itens
	
For nIt := 1 To Len(aCols)
	
	If ALTERA
		If DbSeek(xFilial("QKE") + M->QKE_COD + StrZero(nIt,Len(QKE->QKE_ITEM)))
			RecLock("QKE",.F.)
		Else
			RecLock("QKE",.T.)
		Endif
	Else	                   
		RecLock("QKE",.T.)
	Endif

	If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado
	
		//��������������������������������������������������������������Ŀ
		//� Dados da Enchoice                                            �
		//����������������������������������������������������������������
		For nCont := 1 To FCount()
			If "FILIAL"$Field(nCont)
				FieldPut(nCont,xFilial("QKE"))
			Else
				FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
			Endif	
		Next nCont

		//��������������������������������������������������������������Ŀ
		//� Dados da GetDados                                            �
		//����������������������������������������������������������������		
		For nCpo := 1 To Len(aHeader)
			If aHeader[nCpo, 10] <> "V"
  				QKE->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
			Endif
		Next nCpo
                                                                              
		//�������������������������������������������������������Ŀ
		//� Controle de itens do acols /  Filial dos responsaveis �
		//���������������������������������������������������������
		QKE->QKE_ITEM	:= StrZero(nNumItem,Len(QKE->QKE_ITEM))
		QKE->QKE_FILMAT	:= cFilAnt
						
		nNumItem++
	
		MsUnLock()
	Else
		If DbSeek(xFilial("QKE")+ M->QKE_COD + StrZero(nIt,Len(QKE->QKE_ITEM)))
			RecLock("QKE",.F.)
			QKE->(DbDelete())
		Endif
	Endif
	
Next nIt

End Transaction
				
DbSelectArea("QKE")
DbSetOrder(1)
		
Return lGraOk


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PP040LinOk� Autor � Robson Ramiro A. Olive� Data � 09.09.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para mudanca/inclusao de linhas               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP040LinOk                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QPPA040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function PP040LinOk

Local nPosDel	:= Len(aHeader) + 1
Local nPosNOME	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKE_NOME" })
Local nPosMAT	   := ascan(aHeader, { |x| AllTrim(x[2]) == "QKE_MAT"}) 
Local lRetorno	:= .T.
Local nCont		:= 0

//������������������������������������������������������Ŀ
//� verifica se ao menos 1 item foi preenchido           �
//��������������������������������������������������������

If Empty(aCols[n,nPosNOME]) .and. !aCols[n, nPosDel]
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

IF INCLUI .or. ALTERA
	For nCont := 1 to len(aCols)
		If aCols[nCont,2] == M->QKE_MAT .and. nCont <> n .and. !aCols[n, nPosDel] .and. !aCols[nCont, nPosDel] 
			lretorno := .F.
			Help(" ",1,"QPPA040MAT")
			Exit
		Endif
	Next nCont
EndiF

Return lRetorno


/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    �PP040TudOk � Autor � Robson Ramiro A. Olive� Data � 08.09.03 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para inclusao/alteracao geral                  ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP040TudOk                                                  ���
��������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                        ���
��������������������������������������������������������������������������Ĵ��
���Uso       � QPPA040                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PP040TudOk

Local nPosDel	:= Len(aHeader) + 1
Local nPosNOME	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKE_NOME" })
Local lRetorno	:= .T.
Local nIt		:= 0
Local nTot 		:= 0
Local nCont		:= 0

If INCLUI
	If !ExistChav("QKE",M->QKE_COD)
		lRetorno := .F.
	Endif
Endif

For nIt := 1 To Len(aCols)
	If aCols[nIt, nPosDel] .or. Empty(aCols[nIt,nPosNOME])
		nTot ++
	Endif
	If INCLUI .or. ALTERA
		For nCont := 1 to len(aCols)
			If aCols[nCont,2] == aCols[nIt,2] .and. nCont <> nIt .and. !aCols[nIt, nPosDel] .and. !aCols[nCont, nPosDel]
				lretorno := .F.
				Help(" ",1,"QPPA040MAT"+" Matr: "+M->QKE_MAT)
				exit
			Endif
		Next nCont
	Endif
	if !lretorno 
	   Exit
	EndIf
Next nIt

If nTot == Len(aCols) .or. Empty(M->QKE_DATAV)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

Return lRetorno


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A040Dele � Autor � Robson Ramiro A Olivei� Data � 08.09.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Fucao para exclusao                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A040Dele()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A040Dele()

DbSelectArea("QKE")
DbSeek(xFilial("QKE")+M->QKE_COD)

Begin Transaction

Do While xFilial("QKE")+M->QKE_COD == QKE->QKE_FILIAL+QKE->QKE_COD .and. !Eof()
	RecLock("QKE",.F.)
	DbDelete()
	MsUnlock()
	DbSkip()
Enddo
		
End Transaction

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A040Acols� Autor � Robson Ramiro A. Olive� Data � 09.08.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Carrega vetor aCols para a GetDados                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A150Acols()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A040Acols(nOpc)

Local nI
Local aArea  := GetArea()

//������������������������������������������������������Ŀ
//� Montagem do aCols               					 �
//��������������������������������������������������������

If nOpc == 3

	aCols := Array(1,nUsado+1)

	For nI := 1 To Len(aHeader)
		If aHeader[nI,8] == "C"
			aCols[1,nI] := Space(aHeader[nI,4])
		ElseIf aHeader[nI,8] == "N"
			aCols[1,nI] := 0
		ElseIf aHeader[nI,8] == "D"
			aCols[1,nI] := dDataBase
		ElseIf aHeader[nI,8] == "M"
			aCols[1,nI] := ""
		Else
			aCols[1,nI] := .F.
		EndIf
	Next nI

	nPos			:= aScan(aHeader,{ |x| AllTrim(x[2]) == "QKE_ITEM" })
	aCols[1,nPos]	:= StrZero(1,Len(aCols[1,nPos]))
	
	aCols[1,nUsado+1] := .F.
	
Else

	DbSelectArea("QKE")
	DbSetOrder(1)
	DbSeek(xFilial()+M->QKE_COD)

	Do While QKE->(!Eof()) .and. xFilial() == QKE->QKE_FILIAL .and.;
				QKE->QKE_COD == M->QKE_COD
			 	
		aAdd(aCols,Array(nUsado+1))
	
		For nI := 1 to nUsado
   	
			If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
				aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
			Else										// Campo Virtual
				cCpo := AllTrim(Upper(aHeader[nI,2]))
				aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
  			Endif
 			
			aCols[Len(aCols),nUsado+1] := .F.

		Next nI
		
		DbSkip()

	Enddo
		
Endif

RestArea(aArea)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A040Ahead� Autor � Robson Ramiro A. Olive� Data � 08.09.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Monta Ahead para aCols                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A040Ahead()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A040Ahead(cAlias)

Local aArea  := GetArea()
Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local nX

aHeader := {}
nUsado 	:= 0

For nX := 1 To Len(aStruAlias)
	//��������������������������������������������������
	//�Ignora campos que nao devem aparecer na getdados�
	//��������������������������������������������������
	If  Upper(AllTrim(aStruAlias[nX,1])) == "QKE_COD"	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKE_DESC"	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKE_DATAC"	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKE_DATAV"
		Loop
	Endif

	If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL")
		nUsado++
 		aAdd(aHeader,{ Trim(QAGetX3Tit(aStruAlias[nX,1])), ;
 						GetSx3Cache(aStruAlias[nX,1], "X3_CAMPO"),   ;
 						GetSx3Cache(aStruAlias[nX,1], "X3_PICTURE"), ;
						GetSx3Cache(aStruAlias[nX,1], "X3_TAMANHO"), ;
						GetSx3Cache(aStruAlias[nX,1], "X3_DECIMAL"), ;
						GetSx3Cache(aStruAlias[nX,1], "X3_VALID"),   ;
						GetSx3Cache(aStruAlias[nX,1], "X3_USADO"),   ;
						GetSx3Cache(aStruAlias[nX,1], "X3_TIPO"),    ;
						GetSx3Cache(aStruAlias[nX,1], "X3_ARQUIVO"), ;
						GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT") })
	Endif
Next nX

RestArea(aArea)

Return

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    �PP040DtOk  � Autor � Robson Ramiro A. Olive� Data � 09.09.03 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Consistencia para a data                                    ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP040DtOk                                                   ���
��������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                        ���
��������������������������������������������������������������������������Ĵ��
���Uso       � QPPA040                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PP040DtOk

Local lRetorno	:= .T.

If M->QKE_DATAV < M->QKE_DATAC
	Help("", 1, "QPPA040VAL") // "Data de Validade Invalida!"
	lRetorno := .F.
Endif

Return lRetorno

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    �PP040VlEq  � Autor � Robson Ramiro A. Olive� Data � 11.09.03 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Consistencia para a inclusao da equipe                      ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP040VlEq                                                   ���
��������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                        ���
��������������������������������������������������������������������������Ĵ��
���Uso       � QPPA010                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PP040VlEq(cCodEqu)

Local lReturn 	:= .T.
Local aArea		:= GetArea()

DbSelectArea("QKE")
DbSetOrder(1)
DbSeek(xFilial()+cCodEqu)

If QKE->QKE_DATAV < dDataBase
	Help(" ",1,"QPPA040VLE")  // Equipe com data de validade expirada.
	lReturn := .F.
Endif

RestArea(aArea)

Return lReturn
