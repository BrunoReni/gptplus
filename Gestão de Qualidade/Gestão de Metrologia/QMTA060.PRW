#INCLUDE "QMTA060.CH"
#INCLUDE "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QMTA060  � Autor � Wanderley Goncalves Jr� Data � 28/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Procedimentos                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTA060
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
Private aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1},;  // "Pesquisar" 
                     {OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;  // "Visualizar"
                     {OemToAnsi(STR0003),"A060IPro"  , 0 , 3},;  // "Incluir"   
                     {OemToAnsi(STR0004),"A060IPro"  , 0 , 4},;  // "Alterar"   
                     {OemToAnsi(STR0005),"A060DPro"  , 0 , 5, 3} }  // "Excluir"   

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0006)  //"Procedimentos"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QA5")

Set Key VK_F12 To	

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A060DPro � Autor � Wanderley Goncalves Jr� Data � 28/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Procedimentos - Delecao         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A060DPro(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTA060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A060DPro(cAlias,nReg,nOpc)
Local  nOpcA ,cCod 
Local  oDlg

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aTELA[0][0],aGETS[0]

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

		//�������������������������������������������������������Ŀ
		//� Antes de deletar verifica se e' utilizado em Produtos �
		//���������������������������������������������������������
		cCod := QA5->QA5_NORMA

		dbSelectArea('QM1')  // Tipos de Instrumento
        dbSetOrder(2)
		dbSeek( xFilial()+cCod)
		dbSetOrder(1)
		if Found()
			HELP(" ",1,"A060DNORMA",,QM1->QM1_TIPO+' - '+QM1->QM1_REVTIP)

			dbSelectArea(cAlias)
			Exit
		EndIf

		Begin Transaction

			//��������������������������������������������������������������Ŀ
			//� Apos passar por todas as verificacoes , deleta o registro    �
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

Return(Nil)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A060IPro � Autor � Wanderley Gonalves Jr � Data � 28/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Procedimentos - Inc/Alt         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A060IPro(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A060IPro(cAlias,nReg,nOpc)
Local  nOpcA:=0

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aTELA[0][0],aGETS[0]

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


	End Transaction

   Exit
EndDo
dbSelectArea(cAlias)
return

