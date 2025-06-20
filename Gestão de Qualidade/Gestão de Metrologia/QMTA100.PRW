#INCLUDE "QMTA100.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QMTA100  � Autor � Wanderley Goncalves Jr� Data � 25/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Tabela de Corre��o              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTA100

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
Private aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1},;    // "Pesquisar"
{OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;    // "Visualizar"
{OemToAnsi(STR0003),"A100ITCor" , 0 , 3},;    // "Incluir"
{OemToAnsi(STR0004),"A100ITCor" , 0 , 4},;    // "Alterar"
{OemToAnsi(STR0005),"A100DTCor" , 0 , 5, 3} } // "Excluir"

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0006)  //"Tabela de Corre��o"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QMN")

Set Key VK_F12 To

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A100ITCor� Autor � Wanderley Goncalves Jr� Data � 17/12/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de cadastro de Tabela de Correcao - Inclusao      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A100ITCor(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTA100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A100ITCOR(cAlias,nReg,nOpc)
Local nOpcA //,nCntDele := 0 ,cCod ,aAC := { OemToAnsi(STR0007),OemToAnsi(STR0008) }  //"Abandona"###"Confirma"
Local nDEC

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aTELA[0][0],aGETS[0]


//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
Begin Transaction

if !QMN->(eof())
	nDec := QA_NUMDEC(QMN->QMN_ATE)
	nDecCor := QA_NUMDEC(QMN->QMN_CORR)
endif

if nOpc == 3  // Inclusao
	nOpcA:=AxInclui( cAlias, nReg, nOpc)
	
elseif nOpc == 4  // Alteracao
	nOpcA:=AxAltera( cAlias, nReg, nOpc)
endif

If nOpcA == 1 // Confirmou
	
	//��������������������������������������������Ŀ
	//� Recalcula os Fatores de Correcao           �
	//����������������������������������������������
	A100FACO()
	
EndIf

End Transaction


dbSelectArea(cAlias)

Return(Nil)


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A100DTCor� Autor � Wanderley Goncalves Jr� Data � 17/12/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Prog. Tabela de Correcao - Delecao                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A100DTCor(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTA100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A100DTCor(cAlias,nReg,nOpc)
Local nOpcA //,cCod ,aAC := { OemToAnsi(STR0010),OemToAnsi(STR0011) }  //"Abandona"###"Confirma"
Local oDlg

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
	nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009)) //"Quanto a exclus�o?"
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
			// Recalcula os Fatores de Correcao
			A100Faco()
		Endif
		
		End Transaction
	Else
		MsUnLock()
		
	EndIf
	
	Exit
EndDo

dbSelectArea(cAlias)

return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A100Faco � Autor � Wanderley Goncalves Jr� Data � 17/12/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializador Padrao - Sugestao para Campo "DE"            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A100Faco(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTA100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A100Faco(cAlias,nReg,nOpc)

Local nInf, nDec
Local nInic


DbSelectArea("QMN")
QMN->(Dbseek(xFilial()+"0",.t.))

nDec := QA_NUMDEC(QMN->QMN_ATE)

//�������������������������������������������������������������������Ŀ
//� Atualiza Campo "DE" (valor inicial do intervalo) de cada registro �
//���������������������������������������������������������������������

dbSelectArea("QMN")

nInf := 0

While ! Eof() .and. QMN_FILIAL == xFilial("QMN")
	RecLock("QMN",.F.)
	nInic := Val(Str(nInf,10,nDec))
	QMN->QMN_DE := StrTran(Str(nInic),".",",")
	nInf := SuperVal(QMN->QMN_ATE) + 10 ^ (-nDec)
	MsUnLock()
	DbSkip()
Enddo

//������������������������������������������Ŀ
//� Volta para o inicio (sem usar DBGOTOP)   �
//��������������������������������������������
QMN->(Dbseek(xFilial("QMN")+"0",.t.))

Return nil
