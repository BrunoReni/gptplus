#INCLUDE "GEMA020.ch"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GEMA020   �Autor  �Telso Carneiro      � Data �  31/01/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de Cartorios                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAGEM                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function GEMA020()
Local aArea := GetArea()

Private cCadastro:= OemToAnsi(STR0001) //'Cadastro de Cartorios'

Private aRotina := MenuDef()                
// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

DbSelectArea("LEJ")
LEJ->(dbSetOrder(1)) // LJE_FILIAL+LJE_NCONTR+LJE_REVISA
DbGoTop()
mBrowse(006,001,022,075,"LEJ")

RestArea(aArea)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GM020Telas� Autor � Telso Carneiro        � Data � 31/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela Cadastro de Cartorios		                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GM020TELAS(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Alias do arquivo                                   ���
���          � ExpN1 - Numero do registro                                 ���
���          � ExpN2 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGEM                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function GM020Telas(cAlias,nReg,nOpc)

Local oDlg
Local nI    := 0
Local nOpcao:= 0          
Local aSize	:= MsAdvSize()
Local oGetCar 
Local aArea := GetArea()

Private bCampo:= {|nCPO| Field( nCPO ) }
Private aTELA[0][0]
Private aGETS[0]

DbSelectArea("LEJ")
LEJ->(dbSetOrder(1)) // LJE_FILIAL+LJE_NCONTR+LJE_REVISA

RegToMemory( "LEJ", nOpc == 3 )

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL  //"Cadastro de Cartorios"

oGetCar:=MsMGet():New("LEJ",nReg,nOpc,,,,,{015,000,200,350},,,,,,oDlg)
oGetCar:oBox:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela),(nOpcao:= 1,oDlg:End()),)},{||nOpcao:= 2, oDlg:End()}) CENTERED

If nOpc <> 2 .AND. nOpcao == 1
	If nOpc == 3 .Or. nOpc == 4
		GMA020Gra(nOpc)
	ElseIf nOpc == 5
		GMA020Dele()
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
���Fun��o    �GMA020Gra � Autor � Telso Carneiro        � Data � 31/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Cartorios                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GMA020Gra(ExpN1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Opcao do Browse                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGEM                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function GMA020Gra(nOpc)

Local lRecLock := .F.
Local nI       := 0
Local aArea    := GetArea()

If nOpc == 3
	lRecLock:= .T.
EndIf

DbSelectArea("LEJ")
LEJ->(dbSetOrder(1)) // LJE_FILIAL+LJE_NCONTR+LJE_REVISA

Begin Transaction
	RecLock("LEJ",lRecLock)
	M->LEJ_FILIAL:=XFILIAL("LEJ")
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
���Fun�ao	  � GMA020Dele � Autor � Telso Carneiro     � Data � 31/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Exclusao de registros do Cadastro de Cartorio             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � GMA010Dele()                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � SIGAGEM                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function GMA020Dele()

Local lReturn := .T.
Local cFil    := xFilial("LEJ")
Local aArea   := GetArea()

//�������������������������������������������������Ŀ
//� Cria Indice Condicional nos arquivos utiLizados �
//���������������������������������������������������
Local cIndex1:= CriaTrab(Nil,.F.)
Local cKey   := LIQ->(IndexKey())	
Local cFiltro

IF !EMPTY(cFil)
	cFiltro:= 'LIQ->LIQ_FILIAL == "'+cFil+'" .And. '    
	cFiltro+= 'LIQ->LIQ_CARTOR == "'+LEJ->LEJ_CODIGO+'"'            
Else
	cFiltro:= 'LIQ->LIQ_CARTOR == "'+LEJ->LEJ_CODIGO+'"'
Endif

IndRegua("LIQ",cIndex1,cKey,,cFiltro,OemToAnsi(STR0007)) //"Selecionando Registros.."

LIQ->(DbGotop())
IF !LIQ->(EOF())
	lReturn:= .F. 
Endif	

RetIndex("LIQ")
dbClearFilter() //Set Filter to

DbSelectARea("LEJ")

If lReturn
	Begin Transaction
		RecLock("LEJ",.F.)
		LEJ->(DbDelete())
		MsUnlock()			
	End Transaction   
	LEJ->(DbSkip())
Else      
	Help("",1,"GEM_EMPEXT",,OemToAnsi(STR0008),1) //"Existe Empreendimentos cadastrados associados a esta informacao."
EndIf

RestArea(aArea)

Return

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
Local aRotina  := {{OemToAnsi(STR0002),"AxPesqui"   ,0 ,1,,.F.},;  //'Pesquisar'
                   {OemToAnsi(STR0003),"GM020TELAS" ,0 ,2},;  //'Visualizar'
				   {OemToAnsi(STR0004),"GM020TELAS" ,0 ,3},;  //'Incluir'
				   {OemToAnsi(STR0005),"GM020TELAS" ,0 ,4},;  //'Alterar'
				   {OemToAnsi(STR0006),"GM020TELAS" ,0 ,5} }  //'Excluir'
Return(aRotina)
