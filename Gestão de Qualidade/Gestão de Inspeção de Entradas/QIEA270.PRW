#INCLUDE "QIEA270.CH"
#include "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEA270  � Autor � Vera Lucia S. Simoes  � Data � 19/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao Tabela IA(K) e IQS(FC)                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Paulo Emidio�02/10/00�------�Alteracao no filtro para que o mesmo seja ���
���            �        �      �efetuado atraves da mBrowse().            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},;  // "Pesquisar" 
                    {OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;  // "Visualizar"
                    {OemToAnsi(STR0003),"A270ITab"  , 0 , 3},;  // "Incluir"   
                    {OemToAnsi(STR0004),"A270ITab"  , 0 , 4},;  // "Alterar"   
                    {OemToAnsi(STR0005),"A270DTab"  , 0 , 5, 3} }  // "Excluir"

Return aRotina

function QIEA270(nOpcao)

// nOpcao 1: Tabela IA
// nOpcao 2: Tabela IQS

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro
PRIVATE nTab
Private uCodTab

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

If nOpcao == nil
	nOpcao := 1
	cCadastro := OemtoAnsi(STR0006)  // "Fatores I.A."
  	uCodTab := "1"	// Consultar somente os dados CODTAB = 1 no QEJ: Fatores IA
Else
	cCadastro := OemtoAnsi(STR0007)  // "Fatores I.Q.S."
  	uCodTab := "2"	// Consultar somente os dados CODTAB = 2 no QEJ: Fatores IQS
EndIf
nTab := nOpcao

dbSelectArea("QEJ")

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse(06,01,22,75,"QEJ",,,,,,,"q270FilFat()","q270FilFat()")
Set Filter to

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A270DTab � Autor � Vera Lucia S. Simoes  � Data � 19/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Prog. Atualizacao Tabela IA(K) e IQS(FC) - Delecao         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A270DTab(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA270                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A270DTab(cAlias,nReg,nOpc)
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
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0012))  //"Quanto � exclus�o?" 
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
				// Recalcula os Fatores Inferiores QEJ
				A270CINF()

				// Se houver relat. Ind. Qual., apresenta mensagem p/ gera-lo novamente
				QEV->(dbSeek(xFilial("QEV")))
				If ! QEV->(Eof())
					MessageDlg(STR0013,,3)	// "Indices de Qualidade dever�o ser gerados novamente." 
				EndIf
			Endif
	
		End Transaction
	Else 
		MsUnLock()

   EndIf
	
   Exit
EndDo

dbSelectArea(cAlias)
dbSeek(xFilial("QEJ")+uCodTab)
return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A270ITab � Autor � Vera Lucia S. Simoes  � Data � 19/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Prog. Atualizacao Tabela IA(K) e IQS(FC) - Incl./Alteracao ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A270ITab(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA270                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A270ITab(cAlias,nReg,nOpc)
LOCAL nOpcA:=0
// private aEnch := { {QEJ_VLSUP}, {QEJ_FATOR} }

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

			If nOpcA == 1   // Confirmou a inclusao
				RecLock("QEJ",.F.)
				If nTab == 1
					QEJ->QEJ_CODTAB := '1' // Fatores IA
				Elseif nTab == 2
					QEJ->QEJ_CODTAB := '2' // Fatores IQS
				Endif
			Endif

		elseif nOpc == 4  // Alteracao
			nOpcA:=AxAltera( cAlias, nReg, nOpc)
		endif

		If nOpcA == 1 // Confirmou
			// Recalcula os Fatores Inferiores QEJ
			A270CINF()

			// Se houver relat. Ind. Qual., apresenta mensagem p/ gera-lo novamente
			QEV->(dbSeek(xFilial("QEV")))
			If ! QEV->(Eof())
				MessageDlg(STR0013,,3)	// "Indices de Qualidade dever�o ser gerados novamente." 
			EndIf
		EndIf
	
	End Transaction

   Exit
EndDo
dbSelectArea(cAlias)
dbSeek(xFilial("QEJ")+uCodTab)
return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEA271  � Autor � Vera Lucia S. Simoes  � Data � 19.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Executa funcao QIEA270 como Fator IQS                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA270                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QIEA271
QIEA270(2)	// Chamar o programa indicando Tabela IQS
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A270CInf � Autor � Vera Lucia S. Simoes  � Data � 20.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que calcula os Fatores Inferiores da Tabela         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A270CInf()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA270                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A270CInf()
Local nInf 

nInf := 0.00
DbSelectArea("QEJ")
QEJ->(Dbseek(xFilial("QEJ") + uCodTab))
While ! Eof() .and. QEJ_CODTAB == uCodTab .and. QEJ_FILIAL == xFilial("QEJ")
	RecLock("QEJ",.F.)
	QEJ->QEJ_VLINF := nInf
	nInf := QEJ->QEJ_VLSUP + 0.01
	DbSkip()
Enddo
Return nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A270VlFa � Autor � Vera Lucia S. Simoes  � Data � 02/02/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo Fator                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QieA270 - E' chamada no X3_VALID do cpo. QEJ_FATOR  - SX3  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A270VlFa()
Local lRet := .T.
Local cVar := M->QEJ_FATOR

//�����������������������������������������������������Ŀ
//� Verifica se o valor digitado e' um numero valido    �
//�������������������������������������������������������
If ! Positivo(val(cVar))
	lRet := .F.
EndIf

//�����������������������������������������������������Ŀ
//� Verifica se o valor digitado e' um numero valido    �
//�������������������������������������������������������
If lRet
	If ! QA_VerNum(@cVar)
		Help(" ",1,"QA_NUMINV")
		lRet := .F.
	EndIf
	M->QEJ_FATOR := cVar   // atualizacao p/ enchoice
EndIf

If lRet
	If QEJ->(dbSeek(xFilial("QEJ") + M->QEJ_CODTAB + M->QEJ_FATOR))
		Help(" ",1,"JAGRAVADO")
		lRet:= .F.
	EndIf
EndIf

Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q270FILFAT� Autor � Paulo Emidio de Barros� Data � 02/10/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retornao o filtro dos fatores IA(K) e IQS(FC) 			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA270                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function q270FilFat()
	Local cFiltro
	
	If nTab == 1
		//Para Fatores IA
		cFiltro := xFilial('QEJ')+'1'		
	ElseIf nTab == 2 
		//Para Fatores IQS
		cFiltro := xFilial('QEJ')+'2'
	Endif
Return(cFiltro)
