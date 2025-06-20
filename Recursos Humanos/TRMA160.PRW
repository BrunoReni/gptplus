#include "TRMA160.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TRMA160  � Autor � Emerson Grassi Rocha  � Data � 03/04/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Materiais de Treinamento                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TRMA160                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Avoid                                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA160                                                    ���
�������������������������������������������������������������������������Ĵ��
���Cecilia C.�21.07.14�TPZSOX�Incluido o fonte da 11 para a 12 e efetuada ���
���          �        �      �a limpeza.                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TRMA160

LOCAL cFiltra			//Variavel para filtro
LOCAL aIndFil	:= {}	//Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Private	aAC := { STR0001, STR0002 }	//'Abandona'###'Confirma'

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

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0008)	//"Cadastro de Materiais"

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
dbSelectArea("RAG")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"RAG","1")
bFiltraBrw 	:= {|| FilBrowse("RAG",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("RAG")
dbGoTop()

mBrowse(6, 1, 22, 75, "RAG")

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("RAG",aIndFil)

dbSelectArea("RAH")
dbSetOrder(1)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tr160Del � Autor � Emerson Grassi Rocha  � Data � 03/04/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Trata a delecao de Materiais                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tr160Del(cExpC1,nExpN1,nExpN2)                             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA160                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tr160Del(cAlias,nReg,nOpc)
	Local bCampo
	Local oDlg
	Local nOpca:=0
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjCoords	:= {}
	Local aObjSize		:= {}
	
	//��������������������������������������������������������������Ŀ
	//� Monta a entrada de dados do arquivo                          �
	//����������������������������������������������������������������
	Private aTELA[0][0],aGETS[0]
	bCampo := {|nCPO| Field(nCPO) }
	
	nOpcA:=0

	/**************************************************************
	Monta as Dimensoes dos Objetos
	**************************************************************/
	aAdvSize		:= MsAdvSize()		
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
    
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
	  	nOpcA:=EnChoice( cAlias, nReg, nOpc, aAC,"AC",OemToAnsi(STR0009))		//"Quanto a exclus�o?"
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=2,oDlg:End()},{|| nOpca:=1,oDlg:End()})
	
	dbSelectArea(cAlias)
	
	If nOpcA == 2
		// Lista de Materiais
		dbSelectArea("RAH")
		dbSetOrder(2)
		If dbSeek(xFilial("RAH")+RAG->RAG_MATER)
			Help("",1,"Tr160NAO")
			dbSelectArea(cAlias)
			Return .F.				
		EndIf
		
		dbSelectArea(cAlias)
		RecLock(cAlias,.F.,.T.)
			dbDelete()
		MsUnlock()
	EndIf
	
	dbSelectArea(cAlias)

Return .T.


/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �26/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �TRMA160                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()

 Local aRotina := { 	{ STR0003, 'PesqBrw', 0, 1,,.F.}, ;	//'Pesquisar'
						{ STR0004, 'AxVisual', 0, 2}, ;	//'Visualizar'
						{ STR0005, 'AxInclui', 0, 3}, ;	//'Incluir'
						{ STR0006, 'AxAltera', 0, 4}, ;	//'Alterar'
						{ STR0007, 'Tr160Del', 0, 5,3} }	//'Excluir'


Return aRotina