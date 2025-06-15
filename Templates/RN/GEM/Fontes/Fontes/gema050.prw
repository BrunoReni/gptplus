#INCLUDE "PROTHEUS.CH"
#INCLUDE "GEMA050.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GEMA050   �Autor  �Telso Carneiro      � Data �  22/02/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de Modelos                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAGEM                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function GEMA050()

Local aArea := GetArea()

Private cCadastro:= OemToAnsi(STR0001)  //'Cadastro de Modelos'

Private aRotina := MenuDef()
// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

DbSelectArea("LIV")
LIV->(dbSetOrder(1)) // LIV_FILIAL+LIV_MODCON
DbGoTop()
mBrowse(006,001,022,075,"LIV")

RestArea(aArea)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GM050Telas� Autor � Telso Carneiro        � Data � 22/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela Cadastro de Modelos                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GM050TELAS(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Alias do arquivo                                   ���
���          � ExpN1 - Numero do registro                                 ���
���          � ExpN2 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGEM                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function GM050Telas(cAlias,nReg,nOpc)

Local oDlg
Local nI    := 0
Local nOpcao:= 0
Local aSize	:= MsAdvSize()
Local oGetCar  
Local aArea := GetArea()

Private bCampo:= {|nCPO| Field( nCPO ) }
Private aTELA[0][0]
Private aGETS[0]

DbSelectArea("LIV")
LIV->(dbSetOrder(1)) // LIV_FILIAL+LIV_MODCON

RegToMemory( "LIV", nOpc == 3 )

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL   //"Cadastro de Modelos"

oGetCar:=MsMGet():New("LIV",nReg,nOpc,,,,,{015,000,200,350},,,,,,oDlg)
oGetCar:oBox:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela),(nOpcao:= 1,oDlg:End()),)},{||nOpcao:= 2, oDlg:End()}) CENTERED

If nOpc <> 2 .AND. nOpcao == 1
	If nOpc == 3 .Or. nOpc == 4
		GMA050Gra(nOpc)
	ElseIf nOpc == 5
		GMA050Dele()
	EndIf
EndIf

If __lSX8
	If nOpcao == 1
		ConfirmSX8()
	Else
		RollBackSX8()
	Endif
Endif

RestArea(aArea)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GMA050Gra � Autor � Telso Carneiro        � Data � 22/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Modelos                                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GMA050Gra(ExpN1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Opcao do Browse                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGEM                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function GMA050Gra(nOpc)

Local lRecLock := .F.
Local nI       := 0
Local aArea    := GetArea()

If nOpc == 3
	lRecLock:= .T.
EndIf

DbSelectArea("LIV")
LIV->(dbSetOrder(1)) // LIV_FILIAL+LIV_MODCON

Begin Transaction
RecLock("LIV",lRecLock)
M->LIV_FILIAL:=XFILIAL("LIV")
For nI := 1 TO FCount()
	FieldPut(nI,M->&(Eval(bCampo,nI)))
Next nI
MsUnLock()
End Transaction

RestArea(aArea)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	  � GMA050Dele � Autor � Telso Carneiro     � Data � 22/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Exclusao de registros do Cadastro de Modelos              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � GMA050Dele()                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � SIGAGEM                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function GMA050Dele()

Local lReturn := .T.
Local cFil    := xFilial("LIV")
Local aArea   := GetArea()

//�������������������������������������������������Ŀ
//� Cria Indice Condicional nos arquivos utiLizados �
//���������������������������������������������������
Local cIndex1:= CriaTrab(Nil,.F.)
Local cKey   := LIQ->(IndexKey())
Local cFiltro

IF !EMPTY(cFil)
	cFiltro:= 'LIQ->LIQ_FILIAL == "'+cFil+'" .And. '
	cFiltro+= 'LIQ->LIQ_MODCON == "'+LIV->LIV_MODCON+'"'
Else
	cFiltro:= 'LIQ->LIQ_MODCON == "'+LIV->LIV_MODCON+'"'
Endif

IndRegua("LIQ",cIndex1,cKey,,cFiltro,OemToAnsi(STR0007))  //"Selecionando Registros.."

LIQ->(DbGotop())
IF !LIQ->(EOF())
	lReturn:= .F.
Endif

RetIndex("LIQ")
dbClearFilter() //Set Filter to

DbSelectARea("LIV")

If lReturn
	Begin Transaction
	RecLock("LIV",.F.)
	LIV->(DbDelete())
	MsUnlock()
	End Transaction
	LIV->(DbSkip())
Else
	Help("",1,"GEM_EMPEXT",,OemToAnsi(STR0008),1) 	 //"Existe Empreendimentos cadastrados associados a esta informacao."
EndIf         

RestArea(aArea)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GMA050Vld �Autor  �Telso Carneiro      � Data � 22/02/05    ���
�������������������������������������������������������������������������͹��
���Desc.     � Valid do campos LIV_MODCON                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SX3                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function GMA050Vld(cDOT)
Local lRet		:= .T.
Local aCTPath	:= T_ConPath()
Local cPathMode	:= aCTPath[2]

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

IF !Empty(cDot)
	IF !FILE(cPathMode+Alltrim(cDot))
		lRet:=.F.
		Help( " ", 1, "GM_DOTNEXT" )
	Endif
Endif

Return (lRet)

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �05/12/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
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
Local aRotina  := {{OemToAnsi(STR0002),"AxPesqui"  , 0, 1,,.F.},;  //'Pesquisar'
				   {OemToAnsi(STR0003),"GM050TELAS", 0, 2},;    //'Visualizar'
				   {OemToAnsi(STR0004),"GM050TELAS", 0, 3},;    //'Incluir'
				   {OemToAnsi(STR0005),"GM050TELAS", 0, 4},;    //'Alterar'
				   {OemToAnsi(STR0006),"GM050TELAS", 0, 5} }    //'Excluir'
Return(aRotina)
