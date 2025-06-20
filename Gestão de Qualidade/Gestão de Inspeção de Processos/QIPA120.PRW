#INCLUDE "QIPA120.CH"
#include "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPA120  � Autor � Vera Lucia S. Simoes  � Data � 23/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao Criterios Skip-Lote                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
function QIPA120
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
PRIVATE aRotina := { {OemToAnsi(STR0004),"AxPesqui"  , 0 , 1},;  // "Pesquisar" 
                     {OemToAnsi(STR0005),"A120VTab"  , 0 , 2},;  // "Visualizar"
                     {OemToAnsi(STR0006),"A120ITab"  , 0 , 3},;  // "Incluir"   
                     {OemToAnsi(STR0007),"A120ITab"  , 0 , 4},;  // "Alterar"   
                     {OemToAnsi(STR0008),"A120DTab"  , 0 , 5, 3} }//"Excluir"

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro
cCadastro := OemtoAnsi(STR0009)  // "Crit�rios Skip-Lote"

dbSelectArea("QPX")
//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QPX")

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A120DTab � Autor � Vera Lucia S. Simoes  � Data � 23/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao Criterios Skip-Lote - Delecao         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A120DTab(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A120DTab(cAlias,nReg,nOpc)
LOCAL nOpcA
//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0]

While .T.
	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA:=0
	dbSelectArea(cAlias)
	RecLock(cAlias,.F.)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0010))  //"Quanto � exclus�o?" 
		nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})
	dbSelectArea(cAlias)
	IF nOpcA == 2

		Begin Transaction

			//��������������������������������������������������������������Ŀ
			//� Apos passar por todas as verificacoes , deleta o registro    �
			//����������������������������������������������������������������
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.,.T.)
			dbDelete()

			If nOpcA == 2 // Confirmou
				// Recalcula os Fatores Inferiores QPX
				A120CINF()
			Endif
	
		End Transaction
	Else 
		MsUnLock()

   EndIf
	
   Exit
EndDo
return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A120ITab � Autor � Vera Lucia S. Simoes  � Data � 23/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao Criterios Skip-Lote - Incl./Alteracao ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A120ITab(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A120ITab(cAlias,nReg,nOpc)
LOCAL nOpcA:=0

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0]

While .T.

	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA:=0

	Begin Transaction

		if nOpc == 3  // Inclusao
			nOpcA:=AxInclui( cAlias, nReg, nOpc)

		elseif nOpc == 4  // Alteracao
			nOpcA:=AxAltera( cAlias, nReg, nOpc)
		endif

		If nOpcA == 1 // Confirmou
			// Recalcula os Fatores Inferiores QPX
			A120CINF()
		EndIf
	
	End Transaction

   Exit
EndDo
return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A120VTab � Autor � Vera Lucia S. Simoes  � Data � 23.01.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao Criterios Skip-Lote - Visualizacao    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A120VTab(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A120VTab(cAlias, nReg, nOpc)
Local bCampo
Local i

Private aTELA[0][0],aGETS[0]

bCampo := {|nCPO| Field(nCPO) }
FOR i := 1 TO FCount()
	M->&(EVAL(bCampo,i)) := FieldGet(i)
NEXT i

QPF->(dbSeek(xFilial("QPF") + QPX->QPX_SKPLOT))
M->QPX_DESSKL := QPF->QPF_DESCRI
nReg := Recno()
DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
	EnChoice( cAlias, nReg, nOpc )   
	LVAR01 := 0
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| LVar01 := 1,oDlg:End()},{|| LVar01 := 2,oDlg:End()})

dbSelectArea(cAlias)
Return LVar01

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A120CInf � Autor � Vera Lucia S. Simoes  � Data � 20.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que calcula os Fatores Inferiores da Tabela         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A120CInf()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A120CInf()
Local nInf

nInf := 0.00
DbSelectArea("QPX")
QPX->(Dbseek(xFilial("QPX")))
While ! Eof() .and. QPX_FILIAL == xFilial("QPX")
	RecLock("QPX",.F.)
	QPX->QPX_VLINF := nInf
	nInf := QPX->QPX_VLSUP + 0.01
	DbSkip()
Enddo
Return nil

