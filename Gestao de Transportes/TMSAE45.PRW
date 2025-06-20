#INCLUDE 'TMSAE45.CH'
#INCLUDE 'PROTHEUS.CH'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE45  � Autor � Eduardo de Souza      � Data � 29/11/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � EDI - Pre-Fatura Inportadas                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE45()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMS                                                    ���
�������������������������������������������������������������������������Ĵ��
���                  ATUALIZACOES - VIDE SOURCE SAFE                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE45()

If DEB->(ColumnPos("DEB_CGCDEV")) > 0 .And. DEB->(ColumnPos("DEB_FILDOC")) > 0
	TMSAE45A()
Else

	Private cCadastro := STR0001 // 'EDI - Pre-Fatura'
	Private aRotina   := MenuDef()
	
	DbSelectArea("DEB")
	DbSetOrder(1)
	DbGoTop()    
	
	mBrowse(6,1,22,75,"DEB")
	
	RetIndex("DEB")

EndIf

Return NIL

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSE45Mnt � Autor � Eduardo de Souza      � Data � 29/11/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Pre - Fatura                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSE45Mnt(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Alias do arquivo                                   ���
���          � ExpN1 - Numero do registro                                 ���
���          � ExpN2 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE45                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function TMSE45Mnt(cAlias,nReg,nOpcx)

Local oDlg
Local aSize     := {}
Local aInfo     := {}
Local aObjects  := {}
Local aPosObj   := {}
Local aAreas    := {DT6->(GetArea()),GetArea()}
Local lContinua := .T.

Private aTELA[0][0]
Private aGETS[0]

If (nOpcx == 4 .Or. nOpcx == 5) .And. DEB->(ColumnPos("DEB_FILDOC")) > 0 
	DT6->(DbSetOrder(1))
	If DT6->(MsSeek(xFilial("DT6")+DEB->(DEB_FILDOC+DEB_DOC+DEB_SERIE))) .And. !Empty(DT6->DT6_NUM)
		Help("",1,"TMSAE4501") //-- Documento j� Faturado
		lContinua := .F.
	EndIf
EndIf

If lContinua
	DbSelectArea("DEB")
	DbSetOrder(1)

	RegToMemory("DEB",nOpcx == 3)

	//-- Dimensoes padroes
	aSize   := MsAdvSize()
	AAdd( aObjects, { 100, 100, .T., .T. } )

	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

	oEnch:= MsMGet():New(cAlias,nReg,nOpcx,,,,,aPosObj[1],,3,,,,,,.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela) .And. TMSAE45TOk(),(TMSE45Grv(nOpcx),oDlg:End()),)},{|| oDlg:End()}) CENTERED

	DeleteObject( oDlg  )
	DeleteObject( oEnch )
EndIf

aEval(aAreas, {|xArea| RestArea(xArea) })
Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSE45Grv � Autor � Eduardo de Souza      � Data � 29/11/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Tabela de Registros                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSE45Grv(ExpN1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE45                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function TMSE45Grv(nOpcx)

Local ni
Local bCampo := { |nCpo| Field(nCpo) }

If nOpcx <> 2 // Se nao for visualizacao

	If nOpcx == 3 .Or. nOpcx == 4 // Incluir ou Alterar

		Begin Transaction
			RecLock("DEB",nOpcx==3)
			For nI := 1 TO FCount()
				If FieldName(nI) == 'DEB_FILIAL'
					FieldPut(nI,xFilial("DEB"))
				Else
					FieldPut(nI,M->&(Eval(bCampo,nI)))
				EndIf
			Next nI
			MsUnLock()      
		End Transaction
	
	ElseIf nOpcx == 5 // Excluir
		Begin Transaction
			RecLock("DEB",.F.,.T.)
			DEB->(DbDelete())
			MsUnLock()
			dbSkip()
		End Transaction
	EndIf
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE45Vld� Autor � Gilson da Silva       � Data � 25/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes da Pre Fatura                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE45Vld()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE45                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE45Vld()

Local cCampo := ReadVar()
Local lRet   := .T. 
Local cTipo  := ""   
Local cCgc   := ""

If cCampo $ 'M->DEB_CGCREM;M->DEB_CGCDES'
	cCgc := &(cCampo)
	//-- Posiciona no cadastro de Clientes para verificar se o A1_TIPO == "X" (Exportacao)
   If !Empty(cCgc)
   	cTipo := Posicione("SA1",3,xFilial("SA1")+cCgc,"A1_TIPO")
   EndIf

	If cPaisLoc == "BRA" .And. cTipo == "X"
		lRet := .T.
	Else
		lRet := CGC(cCgc)
	EndIf	
EndIf   

Return lRet      

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
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
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
     
Private aRotina := {{STR0002,"AxPesqui"	,0,1,0,.F.},; // "Pesquisar"
						  {STR0003,"TMSE45Mnt"	,0,2,0,NIL},; // "Visualizar"
						  {STR0004,"TMSE45Mnt"	,0,3,0,NIL},; // "Incluir"
						  {STR0005,"TMSE45Mnt"	,0,4,0,NIL},; // "Alterar"
						  {STR0006,"TMSE45Mnt"	,0,5,0,NIL}}  // "Excluir"

If ExistBlock("TME45MNU")
	ExecBlock("TME45MNU",.F.,.F.)
EndIf

Return(aRotina)

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMSAE45TOk� Autor � Raphael Zampieri      � Data �24/06/2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function TMSAE45TOk()

Local cConteudo := ""  
Local bCampo := { |nCpo| Field(nCpo) }
Local lRet := .T.

cConteudo := M->&(Eval(bCampo,DEB->(FieldPos("DEB_CGCREM"))))+M->&(Eval(bCampo,DEB->(FieldPos("DEB_DOC"))))+M->&(Eval(bCampo,DEB->(FieldPos("DEB_SERIE"))))

If !ExistChav("DEB",cConteudo,1)
	lRet := .F.
EndIf   

Return lRet