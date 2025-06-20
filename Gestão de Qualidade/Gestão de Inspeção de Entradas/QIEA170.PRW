#INCLUDE "QIEA170.CH"
#include "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEA170  � Autor � Vera Lucia S. Simoes  � Data � 23/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao Criterios Skip-Lote                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0004),"AxPesqui"  , 0 , 1,,.F.},;  // "Pesquisar" 
                     {OemToAnsi(STR0005),"A170VTab"  , 0 , 2},;  // "Visualizar"
                     {OemToAnsi(STR0006),"A170ITab"  , 0 , 3},;  // "Incluir"   
                     {OemToAnsi(STR0007),"A170ITab"  , 0 , 4},;  // "Alterar"   
                     {OemToAnsi(STR0008),"A170DTab"  , 0 , 5, 3} }  // "Excluir"
                     
Return aRotina

function QIEA170

Private aCRA := { OemToAnsi(STR0001), OemToAnsi(STR0002), OemToAnsi(STR0003) }  //"Confirma" ### "Redigita" ### "Abandona"

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro
cCadastro := OemtoAnsi(STR0009)  // "Crit�rios Skip-Lote"

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
PRIVATE aRotina := MenuDef()

dbSelectArea("QEX")

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QEX")

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A170DTab � Autor � Vera Lucia S. Simoes  � Data � 23/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao Criterios Skip-Lote - Delecao         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A170DTab(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA170                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A170DTab(cAlias,nReg,nOpc)
LOCAL nOpcA  
LOCAL oDlg

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
			MsUnLock()

			If nOpcA == 2 // Confirmou
				// Recalcula os Fatores Inferiores QEX
				A170CINF()
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
���Fun��o    � A170ITab � Autor � Vera Lucia S. Simoes  � Data � 23/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao Criterios Skip-Lote - Incl./Alteracao ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A170ITab(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA170                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A170ITab(cAlias,nReg,nOpc)
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
			// Recalcula os Fatores Inferiores QEX
			A170CINF()
		EndIf
	
	End Transaction

   Exit
EndDo
return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A170VTab � Autor � Vera Lucia S. Simoes  � Data � 23.01.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao Criterios Skip-Lote - Visualizacao    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A170VTab(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA170                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A170VTab(cAlias, nReg, nOpc)

Local bCampo 
Local i

Private aTELA[0][0],aGETS[0]

bCampo := {|nCPO| Field(nCPO) }
FOR i := 1 TO FCount()
	M->&(EVAL(bCampo,i)) := FieldGet(i)
NEXT i

QEF->(dbSetOrder(1))
QEF->(dbSeek(xFilial("QEF") + QEX->QEX_SKPLOT))
M->QEX_DESSKL := QEF->QEF_DESCRI
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
���Fun��o    � A170CInf � Autor � Vera Lucia S. Simoes  � Data � 20.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que calcula os Fatores Inferiores da Tabela         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A170CInf()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA170                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A170CInf()
Local nInf

nInf := 0.00
DbSelectArea("QEX")
QEX->(dbSetOrder(1))
QEX->(Dbseek(xFilial("QEX")))
While ! Eof() .and. QEX_FILIAL == xFilial("QEX")
	RecLock("QEX",.F.)
	QEX->QEX_VLINF := nInf
	nInf := QEX->QEX_VLSUP + 0.01
	MsUnLock()
	DbSkip()
Enddo
Return nil

