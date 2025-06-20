#INCLUDE "TMSAE10.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE10  � Autor � Eduardo de Souza      � Data � 07/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Registros - EDI                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE10                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMS                                                    ���
�������������������������������������������������������������������������Ĵ��
���                  ATUALIZACOES - VIDE SOURCE SAFE                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE10()

Private cCadastro := STR0006 // "Tabela de Registros"
Private aRotina   := MenuDef()

DbSelectArea("DE3")
DbSetOrder(1)
DbGoTop()

mBrowse(6,1,22,75,"DE3")

RetIndex("DE3")

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSE10Mnt � Autor � Eduardo de Souza      � Data � 07/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela Tabela de Registros                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSE10Mnt(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Alias do arquivo                                   ���
���          � ExpN1 - Numero do registro                                 ���
���          � ExpN2 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE10                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function TMSE10Mnt(cAlias,nReg,nOpc)

Local oDlg
Local aSize    := {}
Local aInfo    := {}
Local aObjects := {}
Local aPosObj  := {}

Private aTELA[0][0]
Private aGETS[0]

DbSelectArea("DE3")
DbSetOrder(1)

RegToMemory("DE3",nOpc == 3)

//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

oEnch:= MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,3,,,,,,.T.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela),(TMSE10Grv(nOpc),oDlg:End()),)},{|| oDlg:End()}) CENTERED

DeleteObject( oDlg  )
DeleteObject( oEnch )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSE10Grv � Autor � Eduardo de Souza      � Data � 07/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Tabela de Registros                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSE10Grv(ExpN1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE10                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function TMSE10Grv(nOpc)

Local ni
Local bCampo := { |nCpo| Field(nCpo) }

If nOpc <> 2 // Se nao for visualizacao

	If nOpc == 3 .Or. nOpc == 4 // Incluir ou Alterar

		Begin Transaction
			RecLock("DE3",nOpc==3)
			For nI := 1 TO FCount()
				If FieldName(nI) == 'DE3_FILIAL'
					FieldPut(nI,xFilial("DE3"))
				Else
					FieldPut(nI,M->&(Eval(bCampo,nI)))
				EndIf
			Next nI
			MsUnLock()      
		End Transaction
	
	ElseIf nOpc == 5 // Excluir
		//������������������������������������������������������������������Ŀ
		//�Verifica amarracao no configurador de Layout e Composicao do Reg. �
		//��������������������������������������������������������������������
		If TMSAE10Del()
			Begin Transaction
				RecLock("DE3",.F.,.T.)
				DE3->(DbDelete())
				MsUnLock()
				dbSkip()
			End Transaction
		EndIf
	EndIf
EndIf

Return

/*����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE10Del � Autor � Eduardo de Souza    � Data � 07/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da Exclusao do Registro                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE10Del()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE10                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE10Del()

Local lRet  := .T.
Local aArea := GetArea()

//������������������������������������������������������
//�Verifica Amarracao Configurador de Layout.          �
//������������������������������������������������������
DbSelectArea("DE0")
DbSetOrder(3)
If MSSeek(xFilial("DE0")+DE3->DE3_CODREG)
	Help(" ",1,"TMSAE1001") //"Registro utilizado no arquivo de configuracao de layout, nao podera ser excluido"
	lRet := .F.
EndIf

RestArea(aArea)

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
     
Private aRotina	:= {	{STR0001,"AxPesqui"	,	0, 1,0,.F.},; // "Pesquisar"
					  			{STR0002,"TMSE10Mnt"	,	0, 2,0,NIL},; // "Visualizar"
							  {STR0003,"TMSE10Mnt"	,	0, 3,0,NIL},; // "Incluir"
							  {STR0004,"TMSE10Mnt"	,	0, 4,0,NIL},; // "Alterar"
							  {STR0005,"TMSE10Mnt"	,	0, 5,0,NIL}}  // "Excluir"


If ExistBlock("TME10MNU")
	ExecBlock("TME10MNU",.F.,.F.)
EndIf

Return(aRotina)

