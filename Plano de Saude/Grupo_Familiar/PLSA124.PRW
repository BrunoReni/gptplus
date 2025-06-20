#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA124   � Autor �Geraldo Felix Junior� Data �  21/05/03   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Familias/Usuarios                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PLSA124(nPessoa,lAutomato)

PRIVATE lJuridico 	:= .F.
PRIVATE lAmbos		:= .F.

Default lAutomato := .F.

//���������������������������������������������������������������������Ŀ
//� Pergunta o tipo de empresa                                          �
//�����������������������������������������������������������������������
If nPessoa == Nil 
	If !Pergunte("PLS174", If(!lAutomato,.T.,.F.))
		Return()
	Endif
Else
	Pergunte("PLS174", .F.)
	Mv_Par01 := nPessoa
Endif

If mv_par01 == 1
	//���������������������������������������������������������������������Ŀ
	//� Cadastra pessoa juridica...                                         �
	//�����������������������������������������������������������������������
	lJuridico := .T.
	PLSA124Juri(lAutomato)
Elseif mv_par01 == 2
	//���������������������������������������������������������������������Ŀ
	//� Cadastra pessoa fisica...                                           �
	//�����������������������������������������������������������������������
	lJuridico := .F.
	PLSA124Fisi(lAutomato)

Else
	lAmbos := .T.
	If(!lAutomato,PLSA260MVC(),)
Endif

BA1->( dbClearFilter() )
BQC->( dbClearFilter() )
BA3->( dbClearFilter() )

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA124juri Autor �Geraldo Felix Junior� Data �  18/06/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de pessoa juridico...                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA124juri(lAutomato)

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cFiltro
Local aRotUsr := {}
Local nRotUsr := 0
PRIVATE lPermAbr  := .T.
Private cCadastro := Fundesc() //"Cadastro de Familias - Pessoa Juridica"
Default lAutomato	:= .F.

//���������������������������������������������������������������������Ŀ
//� Monta um aRotina proprio                                            �
//�����������������������������������������������������������������������

private aRotina := MenuDef()
private aCdCores := { ;
	{ 'BR_VERDE'   ,'Subcontrato Ativo' },;
	{ 'BR_VERMELHO', 'Subcontrato Bloqueado' }}
private aCores   := {{"BQC->BQC_CODBLO <> Space(03)","BR_VERMELHO"} , {"BQC->BQC_CODBLO == Space(03)","BR_VERDE"}}  

If ExistBlock("PL174JBT")
	aRotUsr := ExecBlock( "PL174JBT",.F.,.F.,{aRotina} )
	For nRotUsr := 1 To Len(aRotUsr)
		aAdd(aRotina,aRotUsr[nRotUsr])
	Next
EndIf
dbSelectArea("BQC")
dbSetOrder(3)

cFiltro := "BQC_FILIAL = '"+xFilial("BQC")+"' AND D_E_L_E_T_ = ' '"
DbSelectArea("BQC")

BQC->(DbSeek(xFilial("BQC")))

If(!lAutomato,BQC->(mBrowse( 6,1,22,75,"BQC",,,,,,aCores,,,,,,,,cFiltro )),)

Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA124FISi Autor �Geraldo Felix Junior� Data �  18/06/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de pessoa fisica...                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA124FISI(lAutomato)
local cFiltro
private cString := "BG9"
private cCadastro := "Cadastro de Familias - Pessoa Fisica"
private aRotina := MenuDef()
private aCdCores := { ;
	{ 'BR_VERDE'   ,'Subcontrato Ativo' },;
	{ 'BR_VERMELHO', 'Subcontrato Bloqueado' }}

private aCores := { ;
	{"(nOk := Plsa660Blq()) = 4", 'BR_PRETO'},;
	{"nOk = 3", 'BR_AMARELO'},;
	{".T.", 'BR_VERDE'}}

default lAutomato = .F.

(cString)->(dbSetOrder(1))
cFiltro := "BG9_FILIAL = '"+xFilial("BG9")+"' AND BG9_TIPO = '1' AND D_E_L_E_T_ = ' '"
(cString)->(DbSeek(xFilial()))

//Coloca o subcontrato em EOF() por causa dos inicializadores padroes
If(!lAutomato,(cString)->(mBrowse(6, 1, 22, 75, cString,,,,,,aCores,,,,,,,, cFiltro)),)

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �27/12/2006���
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
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
Private aRotina := { ;
	 {STRPL01     ,"AxPesqui"  ,0, 1		, 0, .F.} ,;
  	 {STRPL02     ,"AxVisual"  ,0, 2		, 0, Nil} ,;
 	 {"Selecionar","PLSA260MVC(.F.)"   	,0, 3		, 0, Nil} ,;	
 	 {"Legenda"   ,"PLSA660LEG",0, K_Incluir, 0, .F.}}
Return(aRotina)
