#INCLUDE "QIEA250.CH"
#include "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEA250  � Autor � Vera Lucia S. Simoes  � Data � 19/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Fatores do IQS                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},;  // "Pesquisar" 
                    {OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;  // "Visualizar"
                    {OemToAnsi(STR0003),"A250IFIS"  , 0 , 3},;  // "Incluir"   
                    {OemToAnsi(STR0004),"A250IFIS"  , 0 , 4},;  // "Alterar"   
                    {OemToAnsi(STR0005),"A250DFIS"  , 0 , 5, 3} }  // "Excluir"

Return aRotina

Function QIEA250
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0006)  //"Fatores IQS"

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
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

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QA8")

Set Key VK_F12 To	
Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A250DFIS � Autor � Vera Lucia S. Simoes  � Data � 19/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Fatores IQS - Delecao           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A250DFIS(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA250                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A250DFIS(cAlias,nReg,nOpc)
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
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009))  //"Quanto � exclus�o?" 
		nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

	dbSelectArea(cAlias)

	IF nOpcA == 2

		Begin Transaction

			//����������������������Ŀ
			//� Deleta o registro    �
			//������������������������
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.,.T.)
			dbDelete()
			MsUnLock()
	
			//  Recalcula os Fatores Inferiores de todos os registros do QA8
			dbSelectArea(cAlias)
			dbGoto(nReg)
			If nOpcA==2 // Confirmou
				A250CFAI()			
			Endif

		End Transaction
	Else 
		MsUnLock()

   EndIf
	
   Exit
EndDo

dbSelectArea(cAlias)
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A250IFIS � Autor � Vera Lucia S. Simoes  � Data � 19/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Fatores IQS-Inclusao/Alteracao  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A250IFIS(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA250                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A250IFIS(cAlias,nReg,nOpc)
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

		//  Calcula os Fatores Inferiores de todos os registros do QA8
		dbGoto(nReg)
		If nOpcA == 1
			A250CFAI()			
		Endif

	End Transaction

   Exit
EndDo
dbSelectArea(cAlias)
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A250CFAI � Autor � Vera Lucia S. Simoes  � Data � 19.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que calcula os Fatores Inferiores Avaliacao Fornec. ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A250CFAI()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA250                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A250CFAI()
Local nFat_Inf

nFat_Inf := 0.00
DbSelectArea("QA8")
DbSetOrder(2)  // Chave: Fator Superior
DbSeek(xFilial("QA8"))
While QA8_FILIAL == xFilial("QA8") .and. ! Eof()
	RecLock("QA8",.F.)
	QA8->QA8_FATINF := nFat_Inf
	nFat_Inf := QA8->QA8_FATSUP + 0.01
	MsUnLock()
	dbSkip()
Enddo
DbSetOrder(1)
Return nil
