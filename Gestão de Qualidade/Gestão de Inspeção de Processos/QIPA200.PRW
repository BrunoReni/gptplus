#INCLUDE "QIPA200.CH"
#include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPA200  � Autor � Vera Lucia S. Simoes  � Data � 11/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Classes de Situacao             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},;  // "Pesquisar" 
                     {OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;  // "Visualizar"
                     {OemToAnsi(STR0003),"A200ISit"  , 0 , 3},;  // "Incluir"   
                     {OemToAnsi(STR0004),"A200ISit"  , 0 , 4},;  // "Alterar"   
                     {OemToAnsi(STR0005),"A200DeSi"  , 0 , 5, 3} }  // "Excluir"
                     
Return aRotina

Function QIPA200
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0006)  //"Situa��o"

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
mBrowse( 6, 1,22,75,"QPG")
Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A200DeSi � Autor � Vera Lucia S. Simoes  � Data � 11/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Situacao - Delecao              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A200DeSi(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A200DeSi(cAlias,nReg,nOpc)
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
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009))  //"Quanto � exclus�o?" 
		nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})
	dbSelectArea(cAlias)
	IF nOpcA == 2
		cCod := QPG->QPG_SITU
		Begin Transaction
			//��������������������������������������������������������������Ŀ
			//� Apos passar por todas as verificacoes , deleta o registro    �
			//����������������������������������������������������������������
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.,.T.)
			dbDelete()
			//  Recalcula os IQI Inferiores de todos os registros do QPG
			dbSelectArea(cAlias)
			dbGoto(nReg)
			If nOpcA==2 // Confirmou
				A200CIQI()			
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
���Fun��o    � A200ISit � Autor � Vera Lucia S. Simoes  � Data � 11/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Situacao - Inclusao/Alteracao   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A200ISit(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A200ISit(cAlias,nReg,nOpc)
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
		//  Calcula os IQI Inferiores de todos os registros do QPG
		dbGoto(nReg)
		If nOpcA==1
			A200CIQI()			
		Endif
	End Transaction
   Exit
EndDo
dbSelectArea(cAlias)
Return
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A200CIQI � Autor � Vera Lucia S. Simoes  � Data � 11.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que calcula o IQI Inferior p/ Classe da Situacao    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A200CIQI()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A200CIQI()
Local nIqi_Inf := 0.00

DbSelectArea("QPG")
DbSetOrder(2)  // Chave: IQI Superior
DbSeek(xFilial("QPG"))
While QPG_FILIAL == xFilial("QPG") .and. ! Eof()
	RecLock("QPG",.F.)
	QPG->QPG_IQP_I := nIqi_Inf
	nIqi_Inf := QPG->QPG_IQP_S + 0.01
	DbSkip()
Enddo
DbSetOrder(1)
Return nil                      

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A200VlIS � Autor � Vera Lucia S. Simoes  � Data � 09.01.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se IQI Superior ja' existe para outra Classe        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A200VlIS()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A200VlIS()
Local nRec := QPG->(Recno()), lRetu := .t.
DbSelectArea("QPG")
DbSetOrder(2)  // Chave: IQI Superior
DbSeek(xFilial("QPG") + str(M->QPG_IQP_S,6,2))
If Found() .and. QPG_SITU <> M->QPG_SITU
  	HELP(" ",1,"A110IQSEXI",,QPG_SITU,2,1)
   lRetu := .f.
EndIf
DbSetOrder(1)
QPG->(DbGoTo(nRec))
Return(lRetu)