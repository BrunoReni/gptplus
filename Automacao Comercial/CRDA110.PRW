#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRDA110.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CRDA110   � Autor � Fernando Salvatori � Data � 14/08/2003  ���
�������������������������������������������������������������������������͹��
���Descricao � Estorno de contrato.                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.           ���
�������������������������������������������������������������������������͹��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������͹��
���              �        �      �                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRDA110
Local oDlgEst             				//Objeto da tela de Estorno
Local oNumCon, cNumCon := Space(10) 	//Numero do contrato
Local oNumCup, cNumCup := Space(06) 	//Numero do cupom fiscal

dbSelectArea("SL1")
dbSetOrder(1)

//�������������������������������������������������������������������������Ŀ
//� A tela funciona integrada com o arquivo de orcamentos.                  �
//���������������������������������������������������������������������������
//�������������������������������������������������������������������������Ŀ
//� Montagem do Dialog.                                                     �
//���������������������������������������������������������������������������
DEFINE MSDIALOG oDlgEst TITLE STR0002 FROM 0,0 TO 200,370 PIXEL //"Estorno de contrato"

@ 05,05 TO 075,179 LABEL STR0003 PIXEL OF oDlgEst //"Dados para Estorno"

@ 25,40 SAY STR0004 SIZE 80,10 PIXEL 	//"N�mero do Contrato: "
@ 25,100 MSGET oNumCon VAR cNumCon SIZE 40,10 PIXEL

@ 40,40 SAY STR0005 SIZE 80,10 PIXEL	//"Numero do Cupom: "
@ 40,100 MSGET oNumCup VAR cNumCup SIZE 30,10 PIXEL

DEFINE SBUTTON FROM 80, 120 TYPE 1 ACTION (IIf(CRDA110Vld(oNumCon,cNumCon,oNumCup,cNumCup),lOk := .T.,lOk := .F.),IIf(lOk,oDlgEst:End(),NIL)) ENABLE PIXEL OF oDlgEst
DEFINE SBUTTON FROM 80, 150 TYPE 2 ACTION (lOk := .F.,oDlgEst:End()) ENABLE PIXEL OF oDlgEst

ACTIVATE MSDIALOG oDlgEst CENTERED

//�������������������������������������������������������������������������Ŀ
//� Caso seja confirmada a operacao, realiza-se o estorno.                  �
//���������������������������������������������������������������������������
If lOK
	CRDA110Estorno()
EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRDA110Vld�Autor  �Fernando Salvatori  � Data �  08/14/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao do Numero do contrato e numero do cupom          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CRDA110                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRDA110Vld(oNumCon,cNumCon,oNumCup,cNumCup)
Local lRet := .T.     //Retorno da funcao

dbSelectArea( "SL1" )
dbSetOrder( 10 )	// Filial + Contra

dbSelectArea( "MAH" )
dbSetOrder( 1 )		// Filial + Contra

//�������������������������������������������������������������������������Ŀ
//� Verifica se o contrato esta amarrado a um orcamento e cadastrado no MAH �
//���������������������������������������������������������������������������
If !SL1->( dbSeek( xFilial( "SL1" ) + cNumCon ) ) .Or. !MAH->( dbSeek( xFilial( "MAH" ) + cNumCon ) )
	MsgStop( STR0006, STR0007 )	//"N�mero do contrato inv�lido."###"Aten��o"
	lRet := .F.
EndIf

//�������������������������������������������������������������������������Ŀ
//� Verifica se o numero do cupom fiscal coicide com o numero do contrato.  �
//���������������������������������������������������������������������������
If lRet .And. SL1->L1_DOC <> cNumCup
	MsgStop( STR0008, STR0007 )	//"N�mero de cupom fiscal inv�lido."###"Aten��o"
	lRet := .F.
EndIf

//�������������������������������������������������������������������������Ŀ
//� Verifica se o contrato selecionado jah se encontra cancelado.           �
//���������������������������������������������������������������������������
If lRet .And. MAH->MAH_CANCEL == "1"
	MsgStop( STR0009, STR0007  )	//"Este contrato j� foi cancelado."###"Aten��o"
	lRet := .F.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRDA110Est�Autor  �Fernando Salvatori  � Data � 14/08/2003  ���
�������������������������������������������������������������������������͹��
���Desc.     � Manutencao do Estorno.                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CRDA110                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function CRDA110Estorno()
Local aSize       := MsAdvSize()      //Size da tela.
Local aObjects    := {}               //Objetos da tela
Local aPosObj     := {}               //Posicoes do objeto
Local aInfo       := {}               //Posicoes do objeto
Local oEnchoice                       //Enchoice Principal
Local oGetDados                       //GetDados principal
Local oDlg                            //Dialogo principal
Local lOk         := .F.              //Confirmacao da alteracao
Private aCols     := {}               //Var. para GetDados
Private aHeader   := {}               //Var. para GetDados
Private aTela[0][0],aGets[0]          // Variaveis para validacao da enchoice

//�������������������������������������������������������������������������Ŀ
//� aRotina utilizado no metodo MSGETDADOS.                                 �
//���������������������������������������������������������������������������
Private aRotina := MenuDef()

//�������������������������������������������������������������������������Ŀ
//� Define as posicoes da GetDados e Paineis.                               �
//���������������������������������������������������������������������������
AAdd( aObjects, {  100, 060, .T., .T. } ) //Enchoice
AAdd( aObjects, {  100, 100, .T., .T. } ) //MsGetDados

aInfo 	 := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
aPosObj  := MsObjSize( aInfo, aObjects, .T. , .F. )

//�������������������������������������������������������������������������Ŀ
//� Carrego as variaveis de memoria para o MAH para serem carregadas na Ench�
//���������������������������������������������������������������������������
RegToMemory( "MAH", .F. )

//�������������������������������������������������������������������������Ŀ
//� Carrego variaveis aHeader e aCols para o sistema.                       �
//���������������������������������������������������������������������������
aHeader := aClone( a610CriaHeader("MAL") )
aCols   := aClone( a610CriaCols("MAL",aHeader,xFilial( "MAH" ) + SL1->L1_CONTRA, {|| xFilial( "MAH" ) + SL1->L1_CONTRA == MAL->MAL_FILIAL + MAL->MAL_CONTRA })[1] )

//�������������������������������������������������������������������������Ŀ
//� Dialogo do Sistema.                                                     �
//���������������������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE STR0002 FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL //"Estorno de contrato"

//�������������������������������������������������������������������������Ŀ
//� Enchoice para a tabela MA1 (visualizacao apenas)                        �
//���������������������������������������������������������������������������
oEnchoice := Enchoice( "MAH",MAH->(Recno()),2,,,,,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.T.)

//�������������������������������������������������������������������������Ŀ
//� MsGetDados.                                                             �
//���������������������������������������������������������������������������
oGetDados := MsGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],2,,,,.T.,,,.T.,,,,,,,oDlg)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| lOk := .T.,oDlg:End()} , {|| lOk := .F.,oDlg:End() }) CENTERED

//�������������������������������������������������������������������������Ŀ
//� Caso seja confirmada, efetua o estorno.                                 �
//���������������������������������������������������������������������������
If lOk
	LjMsgRun( STR0014,,{|| WSCrd011( M->MAH_CONTRA ) } )	//"Aguarde...efetuando o estorno do cr�dito."
EndIf

CRDA110()//Chamada da tela principal de estorno

Return NIL

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Conrado Q. Gomes      � Data � 13.12.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CRDA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
	Local aRotina := {	{STR0010	,"AxPesqui"	,0	,1	,0	,.F.	}	,;		//"Pesquisar"
						{STR0011	,"AxVisual"	,0	,2	,0	,.T.	}	,;		//"Visualizar"
						{STR0012	,"AxInclui"	,0	,3	,0	,.T.	}	,;		//"Incluir"
						{STR0013	,"AxAltera"	,0	,4	,0	,.T.	}	,;		//"Alterar"
						{STR0014	,"AxDeleta"	,0	,5	,0	,.T.	}	}		//"Excluir"
Return(aRotina)                               	
