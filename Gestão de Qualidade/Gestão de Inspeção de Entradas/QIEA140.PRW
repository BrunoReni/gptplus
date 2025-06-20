#INCLUDE "QIEA140.CH"
#include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEA140  � Autor � Wanderley Goncalves Jr� Data � 19/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Manutencao de Departamentos                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0003),"AxPesqui"  , 0 , 1,,.F.},;  		// "Pesquisar"
                    {OemToAnsi(STR0004),"AxVisual"  , 0 , 2},;  		// "Visualizar"
                    {OemToAnsi(STR0005),"Q140Manu"  , 0 , 3},;  		// "Incluir"
                    {OemToAnsi(STR0006),"Q140Manu"  , 0 , 4},;  		// "Alterar"
                    {OemToAnsi(STR0007),"QIE140Del"  , 0 , 5, 3} }	// "Excluir"                 
Return aRotina

Function QIEA140()
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0008)  //"Departamentos"

PRIVATE cDelFunc // Utilizada pela axdeleta

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
mBrowse( 6, 1,22,75,"QAD")

Set Key VK_F12 To	
Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q140Manu  � Autor � Marcelo Pimentel      � Data �15/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inclui / Altera - Departamentos						      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Alias posicionado                                   ���
���          � ExpN1: Numero do registro posicionado                      ���
���          � ExpN2: Opcao do menu selecionada                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QUALITY                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q140Manu(cAlias,nReg,nOpc)
Local nOpca := 0
If nOpc = 3                       
	nOpca := AxInclui(cAlias,nReg,nOpc,,,,"Qie140TOk()")
Else   
	nOpca := AxAltera(cAlias,nReg,nOpc)
EndIf

//��������������������������������������������������������������Ŀ
//� Grava registro no Arquivo SI3, UTILIZADO no Modulo Processos �
//����������������������������������������������������������������
If nOpca == 1
	RecLock("SI3",.T.)
	SI3->I3_FILIAL  := xFilial("SI3")
	SI3->I3_CUSTO   := QAD->QAD_CUSTO
	SI3->I3_DESC    := QAD->QAD_DESC
	MsUnLock()	
EndIf
dbSelectArea(cAlias)
Return(.T.)
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIE140Del � Autor � Marcelo Pimentel      � Data �15/07/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exclusao - Departamentos                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void QIE140Del(ExpC1,ExpN1)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2: Opcao do menu selecionada                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QUALITY                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QIE140Del(cAlias,nReg,nOpc)
Local oDlg
Local nOpcA		:= 0

While .T.
	nOpcA:=0
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
	nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009)) //"Quanto � exclus�o?"
	nOpc := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

	If nOpcA == 2
		//�������������������������������������������������������������������Ŀ
		//� Exclui o registro no ARQUIVO SI3                                  �
		//���������������������������������������������������������������������
		SI3->(dbSetOrder(1))
		If SI3->(dbSeek(xFilial("SI3")+QAD->QAD_CUSTO))
			Reclock("SI3",.F.)
			dbDelete()
			MsUnlock()
		EndIf

		RecLock(cAlias,.F.,.T.)
		dbDelete()
		MsUnLock()
		
	Else
		MsUnLock()
	EndIf
	Exit
EndDo
dbSelectArea(cAlias)
Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � Qie140TOk  � Autor � Marcelo Pimentel    � Data � 15/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se existe o Departamento no arquivo SI3			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QUALITY                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Qie140TOk()
Local lRet  := .T.
Local aArea := GetArea()

dbSelectArea("SI3")
dbSetOrder(1)
If dbSeek(xFilial("SI3")+M->QAD_CUSTO)
	Help(" ",1,"Q140ExisCC")
	lRet := .F.
EndIf
RestArea(aArea)
Return lRet