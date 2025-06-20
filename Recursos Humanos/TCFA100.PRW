#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCFA100.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TCFA100  � Autor � Cristina Ogura        � Data � 10.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro dos Niveis Hierarquicos                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TCFA100                                                    ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador  �BOPS   �Manutencao Efetuada                  ���
�������������������������������������������������������������������������Ĵ��
���24/07/2014�Cecilia Carv. �TQEA22 �Incluido o fonte da 11 para a 12 e   ���
���          �              �       �efetuada  a limpeza.                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TCFA100
Local cFiltra			// Variavel para filtro
Local aIndFil:= {}		// Variavel Para Filtro

Return( NIL )
Private bFiltraBrw := {|| Nil}		// Variavel para Filtro
Private	aAC := {STR0001,STR0002}	// "Abandona"###"Confirma"

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
Private aRotina := { 	{ STR0003, 'PesqBrw' , 0, 1}, ;	//'Pesquisar'
						{ STR0004, 'AxVisual', 0, 2}, ;	//'Visualizar'
						{ STR0005, 'AxInclui', 0, 3}, ;	//'Incluir'
						{ STR0006, 'AxAltera', 0, 4}, ;	//'Alterar'
						{ STR0007, 'Tc100Del', 0, 5} }	//'Excluir'

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0008)	//"Cadastro dos Niveis Hierarquicos"

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
dbSelectArea("RB9")
dbSetOrder(1)
 
cFiltra 	:= CHKRH(FunName(),"RB9","1")
bFiltraBrw 	:= {|| FilBrowse("RB9",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

dbSelectArea("RB9")
dbGotop()

mBrowse(6, 1, 22, 75, "RB9")   

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("RB9",aIndFil)

dbSelectArea("RB9")
dbSetOrder(1)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tc100Del � Autor � Cristina Ogura        � Data � 10.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Trata a delecao dos Niveis hierarquicos                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tf100Del(cExpC1,nExpN1,nExpN2)                             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TCFA100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tc100Del(cAlias,nReg,nOpc)
Local bCampo
Local oDlg
Local nOpca:=0
Local cCadastro:= "Excluir"
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aObjSize		:= {}

Private aTELA[0][0],aGETS[0]
bCampo := {|nCPO| Field(nCPO) }

nOpca:=0
dbSelectArea(cAlias)

/**************************************************************
Monta as Dimensoes dos Objetos
**************************************************************/
aAdvSize		:= MsAdvSize()		
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
	
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL OF oMainWnd		
  	nOpca:=EnChoice( cAlias, nReg, nOpc, aAC,"AC",OemToAnsi(STR0009),,,,,,,,,,,)	//"Quanto a exclus�o?"
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=2,oDlg:End()},{|| nOpca:=1,oDlg:End()})

dbSelectArea(cAlias)

If nOpca == 2
	// Verifica se existem responsabilidades (RBB) para este nivel antes de excluir
	dbSelectArea("RBB")
	dbSetOrder(2)
	dbSeek(xFilial("RBB")+RB9->RB9_NIVEL)
	
	If 	RBB->RBB_NIVEL = RB9->RB9_NIVEL
		Help("",1,"Tc100NPODE")		// Nao posso excluir este nivel pois existem Responsabilidades cadastradas.
		Return .F.
	EndIf

	// Verifica se existem menus do terminal (RBC) para este nivel antes de excluir		
	dbSelectArea("RBC")
	dbSetOrder(2)
	dbSeek(xFilial("RBC")+RB9->RB9_NIVEL)
	
	If	RBC->RBC_NIVEL = RB9->RB9_NIVEL
		Help("",1,"Tf100NPODE")		// Nao posso excluir este participante pois existem Pesquisa salarial para este participante
		Return .F.
	EndIf

	Begin Transaction	
		dbSelectArea(cAlias)
		RecLock(cAlias,.F.,.T.)
			dbDelete()
		MsUnlock()		
	End Transaction
EndIf

dbSelectArea("RBB")
dbSetOrder(1)

dbSelectArea("RBC")
dbSetOrder(1)

dbSelectArea(cAlias)
dbSetOrder(1)

Return .T.