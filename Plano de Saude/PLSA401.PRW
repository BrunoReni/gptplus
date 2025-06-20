
#include "PROTHEUS.CH"
#include "PLSA401.CH"
#include "PLSMGER.CH"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA401 � Autor � Geraldo Felix Junior   � Data � 15.03.03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Grupo de Quantidades...                                    ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSA401()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial.                              ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA401
//��������������������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                               �
//����������������������������������������������������������������������������
PRIVATE aRotina   := MenuDef()
PRIVATE cCadastro := Fundesc() //"Tabela de Precos"
//��������������������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                              �
//����������������������������������������������������������������������������
BW2->(DbSetOrder(1))
BW2->(DbGoTop())
BW2->(mBrowse(06,01,22,75,"BW2"))
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal                                                  �
//����������������������������������������������������������������������������
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PL401MOV � Autor � Geraldo Felix Junior  � Data � 15.03.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Movimentacao do Grupo de Quantidades                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PL401MOV(cAlias,nReg,nOpc)
Local I__f := 0
//��������������������������������������������������������������������������Ŀ
//� Define Variaveis...                                                      �
//����������������������������������������������������������������������������
LOCAL	aAC    := { STR0003 , STR0001  } 
LOCAL nOpca	   := 0
LOCAL oDlg
LOCAL bOk      := {|| nOpca := 1,If(Obrigatorio(aGets,aTela),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }

LOCAL aPosObj   := {}
LOCAL aObjects  := {}
LOCAL aSize     := {}
LOCAL aInfo     := {}
LOCAL aDifSize  := {,,,,35,3,,}
PRIVATE oEnchoice
PRIVATE oGetDados
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aHeader  := {}
PRIVATE n        := 1
PRIVATE aCols    := {}
PRIVATE aVetTrab := {}
PRIVATE aChave   := {}
PRIVATE nOpcx    := nOpc
PRIVATE oFolder
//��������������������������������������������������������������������������Ŀ
//� Monta aCols e aHeader da Co-participacao                                 �
//����������������������������������������������������������������������������
PRIVATE aCabCo   := {}
PRIVATE aDadCo   := {}
PRIVATE aTrbCo   := {}
PRIVATE oBrwCo
PRIVATE cCodPsa  := ""
PRIVATE cCodPad  := ""
PRIVATE cNomPsa  := ""
//��������������������������������������������������������������������������Ŀ
//� Monta aCols e aHeader...                                                 �
//����������������������������������������������������������������������������
Store Header "BW3" TO aHeader For SX3->X3_ORDEM > "02"
If nOpc == K_Incluir
	Copy "BW2" TO Memory Blank
	Store COLS Blank "BW3" TO aCols FROM aHeader
Else
	Copy "BW2" TO MEMORY

	BW3->(DbSetOrder(1))
	If BW3->(DbSeek(xFilial("BW3")+BW2->(BW2_CODINT+BW2_CODGRU)))
		Store COLS "BW3" TO aCols FROM aHeader VETTRAB aVetTrab While BW3->(BW3_FILIAL+BW3_CODINT+BW3_CODGRU) == BW2->(BW2_FILIAL+BW2_CODINT+BW2_CODGRU)
	Else
		Store COLS Blank "BW3" TO aCols FROM aHeader
	EndIf
EndIf

aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T. )

//��������������������������������������������������������������������������Ŀ
//� Define Dialogo...                                                        �
//����������������������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5]of oMainWnd PIXEL
//��������������������������������������������������������������������������Ŀ
//� Monta Enchoice...                                                        �
//����������������������������������������������������������������������������
oEnchoice := MSMGET():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.)
//��������������������������������������������������������������������������Ŀ
//� Monta GetDados ...                                                       �
//����������������������������������������������������������������������������
cCodPsa := GdFieldGet("BW3_CODPSA",1,nil,aHeader,aCols)
cCodPad := GdFieldGet("BW3_CODPAD",1,nil,aHeader,aCols)
cNomPsa := GdFieldGet("BW3_DESCRI",1,nil,aHeader,aCols)

If Val(GetVersao(.F.)) >= 12 // Caso a versao seja maior ou igual a 12
	oGetDados := TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil,oDlg,nil,,nil,nil,nil,.T.,nil,.T.,nil,aHeader,aCols,.F.,"BW3",nOpc,PLSRetTit("BW3"),nil,nil,nil,aVetTrab,nil,nil,NIL,,,,,,,,,,aDifSize)
Else
	oGetDados := TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil,oDlg,nil,,nil,nil,nil,.T.,nil,.T.,nil,aHeader,aCols,.F.,"BW3",nOpc,PLSRetTit("BW3"),nil,nil,nil,aVetTrab,nil,nil,NIL)
EndIf

oGetDados:bLostFocus := {|| cCodPsa := oGetDados:aCols[oGetDados:Linha(),oGetDados:PlRetPos("BW3_CODPSA",aHeader)], cCodPad := oGetDados:aCols[oGetDados:Linha(),oGetDados:PlRetPos("BW3_CODPAD",aHeader)], cNomPsa := oGetDados:aCols[oGetDados:Linha(),oGetDados:PlRetPos("BW3_DESCRI",aHeader)]}
oGetDados:bChange    := {|| cCodPsa := oGetDados:aCols[oGetDados:Linha(),oGetDados:PlRetPos("BW3_CODPSA",aHeader)], cCodPad := oGetDados:aCols[oGetDados:Linha(),oGetDados:PlRetPos("BW3_CODPAD",aHeader)], cNomPsa := oGetDados:aCols[oGetDados:Linha(),oGetDados:PlRetPos("BW3_DESCRI",aHeader)]}

aCols   := aClone(oGetDados:aCols)
aHeader := aClone(oGetDados:aHeader)

ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,bOk,{||oDlg:End()},.F.,{}) })
//��������������������������������������������������������������������������Ŀ
//� Rotina de gravacao dos dados...                                          �
//����������������������������������������������������������������������������
If nOpca == K_OK
   BG7->(DbGoTo(nReg))
   
   PLUPTENC("BW2",nOpc)
   
   aChave := { {"BW3_CODINT",M->BW2_CODINT},{"BW3_CODGRU",M->BW2_CODGRU} }
   oGetDados:Grava(aChave)
   BW3->(DbSetOrder(1))
   If BW3->(MsSeek(xFilial("BW3")+BW2->(BW2_CODINT+BW2_CODGRU)))
   		While !BW3->(Eof()) .and. xFilial("BW3")+BW2->(BW2_CODINT+BW2_CODGRU) == BW3->(BW3_FILIAL+BW3_CODINT+BW3_CODGRU)
   			      
   			BW3->(Reclock("BW3",.F.))
   			PLSGatNiv(BW3->BW3_CODPAD,BW3->BW3_CODPSA,"BW3",.T.)
   			BW3->(MsUnlock())
   			
   			BW3->(DbSkip())
   		Enddo
   Endif 
EndIf
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina...                                                         �
//����������������������������������������������������������������������������
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PL401COD � Autor � Geraldo Felix Junior  � Data � 15.03.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta novo codigo...                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PL401COD(cCodInt)
LOCAL nOrdBW2 := BW2->(IndexOrd())
LOCAL nRecBW2 := BW2->(Recno())
LOCAL nRet

BW2->(DbSeek(xFilial("BW2")+cCodInt+"999",.T.))
BW2->(DbSkip(-1))

If BW2->(BW2_FILIAL+BW2_CODINT) <> xFilial("BW2")+cCodInt
   nRet := StrZero(1,3)
Else
   nRet := StrZero(Val(BW2->BW2_CODGRU)+1,3)
Endif

BW2->(DbSetOrder(nOrdBW2))
BW2->(DbGoTo(nRecBW2))


Return(nRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �04/01/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Private aRotina := {	{ STR0004 , 'AxPesqui' , 0 , K_Pesquisar  , 0, .F.},; //'Pesquisar'
               	       	{ STR0005 , 'PL401MOV' , 0 , K_Visualizar , 0, Nil},; //'Visualizar'
                	   	{ STR0006 , 'PL401MOV' , 0 , K_Incluir    , 0, Nil},; //'Incluir'
                      	{ STR0007 , 'PL401MOV' , 0 , K_Alterar    , 0, Nil},; //'Alterar'
                      	{ STR0008 , 'PL401MOV' , 0 , K_Excluir    , 0, Nil} } //'Excluir'
Return(aRotina)
