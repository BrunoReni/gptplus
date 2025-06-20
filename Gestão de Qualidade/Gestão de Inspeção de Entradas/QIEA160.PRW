#INCLUDE "QIEA160.CH"
#include "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEA160  � Autor � Vera Lucia S. Simoes  � Data � 06/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao de Classes de NC                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},;  // "Pesquisar" 
                     {OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;  // "Visualizar"
                     {OemToAnsi(STR0003),"A160ICNC"  , 0 , 3},;  // "Incluir"   
                     {OemToAnsi(STR0004),"A160ICNC"  , 0 , 4},;  // "Alterar"   
                     {OemToAnsi(STR0005),"A160DCNC"  , 0 , 5, 3} }  // "Excluir"
                     
Return aRotina

// Function QIEA160(uFator)
Function QIEA160()

// uFator .t.: Fatores IQP
// uFator .f.: Classes de NC

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemToAnsi(STR0006)	// "Classes de NC"

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

dbSelectArea("QEE")

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QEE")

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A160DCNC � Autor � Vera Lucia S. Simoes  � Data � 06/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao Classes NC - Delecao                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A160DCNC(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA160                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A160DCNC(cAlias,nReg,nOpc)
LOCAL nOpcA ,cCod 
LOCAL oDlg, lAchou

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

		cCod := QEE->QEE_CLASSE

		If nModulo == 21	// SIGAQIE
			//��������������������������������������������������������Ŀ
			//� Antes de deletar verif. se e' util. em NCs dos Ensaios �
			//����������������������������������������������������������
			dbSelectArea('QE2')
			dbSetOrder(1)
			dbSeek(xFilial("QE2"))
			lAchou := .f.
			While QE2_FILIAL == xFilial("QE2") .and. ! eof()
				if QE2_CLASSE == cCod
					lAchou := .t.
					Exit
				endif
				dbSkip()
			Enddo
			if lAchou
				HELP(" ",1,"A160DCLENS",,QE2->QE2_ENSAIO,3,1)
				dbSelectArea(cAlias)
				Exit
			EndIf

			//���������������������������������������������������������Ŀ
			//� Antes de deletar verif. se e' util. em NCs dos Produtos �
			//�����������������������������������������������������������
			dbSelectArea('QE9') 
			dbSetOrder(1)
			dbSeek(xFilial("QE9"))
			lAchou := .f.
			While QE9_FILIAL == xFilial("QE9") .and. ! eof()
				if QE9_CLASSE == cCod
					lAchou := .t.
					Exit
				endif
				dbSkip()
			Enddo
			if lAchou
				HELP(" ",1,"A160DCLPRO",,QE9->QE9_PRODUT+'-'+;
					QE9->QE9_REVI+'-'+QE9->QE9_ENSAIO,3,1)
				dbSelectArea(cAlias)
				Exit
			EndIf
	
			//�����������������������������������������������������������Ŀ
			//� Antes de deletar verif. se e' util. em NCs dos Resultados �
			//�������������������������������������������������������������
			dbSelectArea('QEU') 
			dbSetOrder(1)
			dbSeek(xFilial("QEU"))
			lAchou := .f.
			While QEU_FILIAL == xFilial("QEU") .and. ! eof()
				if QEU_CLASSE == cCod
					lAchou := .t.
					Exit
				endif
				dbSkip()
			Enddo
			if lAchou
				HELP(" ",1,"A160DCLRES")
				dbSelectArea(cAlias)
				Exit
			EndIf
		EndIf

		//��������������������������������������������������������Ŀ
		//� Antes de deletar verif. se e' util. em cadastro de NCs �
		//����������������������������������������������������������
		dbSelectArea('SAG') 
		dbSetOrder(1)
		dbSeek(xFilial("SAG"))
		lAchou := .f.
		While AG_FILIAL == xFilial("SAG") .and. ! eof()
			if AG_CLASSE == cCod
				lAchou := .t.
				Exit
			endif
			dbSkip()
		Enddo
		if lAchou
			HELP(" ",1,"A160DCLNCS",,SAG->AG_NAOCON,3,1)
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
			MsUnLock()
	
		End Transaction
	Else 
		MsUnLock()

   EndIf
	
   Exit
EndDo

dbSelectArea(cAlias)
//dbSeek(uCodTab)
return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A160ICNC � Autor � Vera Lucia S. Simoes  � Data � 06/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao Classes NC - Inclusao/Alteracao       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A160ICNC(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA160                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A160ICNC(cAlias,nReg,nOpc)
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
	
	End Transaction

   Exit
EndDo
dbSelectArea(cAlias)
return
