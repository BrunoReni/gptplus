#include "QIPA050.CH"
#include "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPA050  � Autor � Marcelo Pimentel      � Data � 29/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Fluxograma Geral                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIP                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QIPA050


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
Private aRotina := { { STR0001 , 'AxPesqui'  , 0 , 1},; //"Pesquisar"
							{ STR0002 , 'AxVisual'  , 0 , 2},; //"Visualizar"
							{ STR0003 , 'AxInclui'  , 0 , 3},; //"Incluir"
							{ STR0004 , 'AxAltera'  , 0 , 4},; //"Alterar"
							{ STR0005 , 'A050FlDel' , 0 , 5} } //"Excluir"
							
Private cCadastro := STR0006	//"Fluxograma Geral"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QQ3")

Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A050FlDel� Autor � Marcelo Pimentel      � Data � 29/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Fluxograma Geral - Delecao      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � a050FlDel(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION a050FlDel(cAlias,nReg,nOpc)
LOCAL nOpcA
LOCAL cCod
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
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0007))  //"Quanto � exclus�o?"
		nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

	dbSelectArea(cAlias)

	IF nOpcA == 2	// Confirma

		cCod := QQ3->QQ3_CODIGO

		Begin Transaction

			//��������������������������������������������������������������Ŀ
			//� Deleta o registro                                            �
			//����������������������������������������������������������������
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.,.T.)
			dbDelete()
	
		End Transaction
	Else 
		MsUnLock()

   EndIf
	
   Exit
EndDo

dbSelectArea(cAlias)
Return
