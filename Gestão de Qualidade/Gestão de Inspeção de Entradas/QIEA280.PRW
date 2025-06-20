#INCLUDE "QIEA280.CH"
#include "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEA280  � Autor � Marcelo Pimentel      � Data � 27/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualiza��o do Indice de Qualidade (Informado) ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIE                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},;  // "Pesquisar"
                    {OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;  // "Visualizar"
                    {OemToAnsi(STR0003),"AxInclui"  , 0 , 3},;  // "Incluir"
                    {OemToAnsi(STR0004),"AxAltera"  , 0 , 4},;  // "Alterar"
                    {OemToAnsi(STR0005),"A280Del"  , 0 , 5, 3}} // "Excluir"
                    
Return aRotina

Function QIEA280
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0006)  //"Indice de Qualidade"

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
mBrowse( 6, 1,22,75,"QE0")

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A280Del  � Autor � Marcelo Pimentel      � Data � 27/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao do Indice de Qualidade - Dele��o   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A280Del(ExpC1,ExpN1,ExpN2)                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA280                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A280Del(cAlias,nReg,nOpc)

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

	IF nOpcA == 2
		
		Begin Transaction
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.,.t.)
			dbDelete()
			MsUnLock()
		End Transaction
	Else
		MsUnlock()
	EndIf
	Exit
	
EndDo

dbSelectArea(cAlias)
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A280Obrig� Autor � Marcelo Pimentel      � Data � 28/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o dos campos obrigat�rios                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QieA280                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A280Obrig(cInd)

LOCAL lBack:=.T.

dbSelectArea("QF1")
dbSetOrder(1)
If dbSeek(xFilial("QF1")+cInd)
	If QF1_CALC != "I"
		MessageDlg(OemToAnsi(STR0010),,1)	// "Indice n�o � do tipo Informado."
		Return .F.
	EndIf	
Else
	MessageDlg(OemToAnsi(STR0011),,1)	// "Indice n�o cadastrado."
	Return .F.
EndIf

If !Empty(M->QE0_ANO) .And. !Empty(M->QE0_MES) .And. !Empty(M->QE0_FORNEC);
	.And.	!Empty(M->QE0_PRODUT).And.!Empty(M->QE0_INDICE)
	
	dbSelectArea("QE0")
	dbSetOrder(1)
	If dbSeek(xFilial("QE0")+M->QE0_ANO+M->QE0_MES+M->QE0_FORNEC+M->QE0_PRODUT+;
		M->QE0_INDICE )
					
		Help( " ", 1, "JAGRAVADO" )
		lBack:= .F.
	EndIf
EndIf

Return(lBack)
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A280Descr� Autor � Marcelo Pimentel      � Data � 28/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Mostra as descri��es ( Produto / Fornecedor )              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QieA280                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A280Descr(cCod,cPF,lGatilho)
Local	cBack := Space(TamSX3("QE6_DESCPO")[1])
lGatilho := Iif(lGatilho == NIL,.t.,lGatilho)

If !Inclui .Or. lGatilho
	If !Empty(cCod)
		If cPF == "P"		//Produto
			QE6->(dbSetOrder(1))
			QE6->(dbSeek(xFilial("QE6")+cCod))
			cBack:= QE6->QE6_DESCPO
		Else					//Fornecedor
			SA2->(dbSetOrder(1))
			SA2->(dbSeek(xFilial("SA2")+cCod))
			cBack:= SA2->A2_NOME
		EndIf	
	EndIf	
EndIf

Return(cBack)
