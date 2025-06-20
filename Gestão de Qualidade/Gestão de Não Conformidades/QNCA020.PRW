#Include "PROTHEUS.CH"
#INCLUDE "QNCA020.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QNCA020  � Autor � Aldo Marini Junior    � Data � 27/12/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Disposicoes                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QNCA020()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Aldo        �20/08/01� ---- � Inclusao validacao na exclusao.          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function MenuDef()

Local aRotina := { { STR0001 ,"AxPesqui" , 0, 1,,.F.},;  //"Pesquisar"
					  { STR0002 ,"AxVisual" , 0, 2},;  //"Visualizar"
					  { STR0003 ,"AxInclui" , 0, 3},;  //"Incluir"  
					  { STR0004 ,"AxAltera" , 0, 4},;  //"Alterar"  
					  { STR0005 ,"Qnc020Del", 0, 5} }  //"Excluir"

Return aRotina

Function QNCA020
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemToAnsi(STR0006)  //"Cadastro de Disposicoes"

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
Private aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QI1")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Qnc020Del� Autor � Aldo Marini Junior    � Data � 27/12/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de exclusao Disposicoes                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Qnc020del(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QNCA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Qnc020Del(cAlias,nReg,nOpc)
Local nOpcA:=1
Local aAC := { STR0007 , STR0008 }  //"Abandona"###"Confirma"
Local lAchou    := .F.

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aTELA[0][0],aGETS[0]

dbSelectArea(cAlias)
dbSetOrder(1)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
nOpcA:=EnChoice( cAlias, nReg, nOpc, aAC,"AC",STR0009 )  //"Quanto � exclus�o?"
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

If nOpcA == 2
	//��������������������������������������������������������������Ŀ
	//� Envia mensagem sobre a verificacao nos arquivos              �
	//����������������������������������������������������������������
	If MsgYesNo(OemToAnsi(STR0010 + CHR(013) + ;  		//"Esta rotina verifica a exist�ncia de Lacamentos das"
						STR0011 + CHR(013) + ;  		//"Tabelas a serem excluidos nos diversos arquivos  do"
						STR0012 + CHR(013) + ;			//"m�dulo. A verifica��o pode ser demorada !!         "
						STR0013),OemToAnsi(STR0014)) 	//"Confirma a exclus�o ?                              "###"Aten��o"
			
		dbSelectArea("QI2") // Ficha de Ocorrencia/Nao-Conformidades
		dbGoTop()
		While !Eof()
			If QI1->QI1_CODIGO == QI2->QI2_CODDIS
				lAchou := .T.
				Exit
			Endif
			dbSkip()
		Enddo

		//��������������������������������������������������������������Ŀ
		//� Se nao Achou pode Deletar                                    �
		//����������������������������������������������������������������
		Begin Transaction
			If lAchou == .F.
				dbSelectArea( cAlias )
				RecLock(cAlias,.F.,.T.)
				dbDelete()
				MsUnlock()
				WRITESX2(cAlias,1)
				dbSkip()
			Else
				MsgStop(OemToAnsi(STR0015 + CHR(013) +;  				//"O Lancamento a ser excluido est� presente nos"
									STR0016 + CHR(013) +; 				//"Lancamentos  das  Fichas/Planos, o registro"
									STR0017),OemToAnsi(STR0018))  		//"nao sera excluido.                           "###"Aten��o"
			Endif
		End Transaction
	EndIf
EndIf

Return