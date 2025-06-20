#INCLUDE 'TMSAE50.CH'
#INCLUDE 'PROTHEUS.CH'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE50  � Autor � Eduardo de Souza      � Data � 15/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Municipio x Regiao                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE50()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMS                                                    ���
�������������������������������������������������������������������������Ĵ��
���                  ATUALIZACOES - VIDE SOURCE SAFE                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE50()

Private cCadastro := STR0001 // 'Cadastro de Municipio x Regiao'
Private aRotina   := MenuDef()

DbSelectArea("DEA")
DbSetOrder(1)
DbGoTop()

mBrowse(6,1,22,75,"DEA")

RetIndex("DEA")

Return NIL

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSE50Mnt � Autor � Eduardo de Souza      � Data � 14/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Municipio x Regiao                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSE50Mnt(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Alias do arquivo                                   ���
���          � ExpN1 - Numero do registro                                 ���
���          � ExpN2 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE50                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function TMSE50Mnt(cAlias,nReg,nOpcx)

Local oDlg
Local aSize    := {}
Local aInfo    := {}
Local aObjects := {}
Local aPosObj  := {}

Private aTELA[0][0]
Private aGETS[0]

DbSelectArea("DEA")
DbSetOrder(1)

RegToMemory("DEA",nOpcx == 3)

//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

oEnch:= MsMGet():New(cAlias,nReg,nOpcx,,,,,aPosObj[1],,3,,,,,,.T.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela),(TMSE50Grv(nOpcx),oDlg:End()),)},{|| oDlg:End()}) CENTERED

DeleteObject( oDlg  )
DeleteObject( oEnch )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSE50Grv � Autor � Eduardo de Souza      � Data � 14/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Tabela de Registros                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSE50Grv(ExpN1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE50                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function TMSE50Grv(nOpcx)

Local ni
Local bCampo := { |nCpo| Field(nCpo) }

If nOpcx <> 2 // Se nao for visualizacao

	If nOpcx == 3 .Or. nOpcx == 4 // Incluir ou Alterar

		Begin Transaction
			RecLock("DEA",nOpcx==3)
			For nI := 1 TO FCount()
				FieldPut(nI,M->&(Eval(bCampo,nI)))
			Next nI
			MsUnLock()      
		End Transaction
	
	ElseIf nOpcx == 5 // Excluir
		Begin Transaction
			RecLock("DEA",.F.,.T.)
			DEA->(DbDelete())
			MsUnLock()
			dbSkip()
		End Transaction
	EndIf
EndIf

Return

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
     
Private aRotina	:=	{	{STR0002,"AxPesqui" ,0,1,0,.F.},; // "Pesquisar"
							  	{STR0003,"TMSE50Mnt",0,2,0,NIL},; // "Visualizar"
							  	{STR0004,"TMSE50Mnt",0,3,0,NIL},; // "Incluir"
							  	{STR0005,"TMSE50Mnt",0,4,0,NIL},; // "Alterar"
							  	{STR0006,"TMSE50Mnt",0,5,0,NIL}}  // "Excluir"


If ExistBlock("TME50MNU")
	ExecBlock("TME50MNU",.F.,.F.)
EndIf


Return(aRotina)

