#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA174   � Autor �Geraldo Felix Junior� Data �  21/05/03   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Familias/Usuarios                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PLSA174(nPessoa,lAutoma,nAutoma)

PRIVATE lJuridico 	:= .F.
PRIVATE lAmbos		:= .F.
DEFAULT lAutoma		:= .F.
DEFAULT nAutoma		:= 0

//���������������������������������������������������������������������Ŀ
//� Pergunta o tipo de empresa                                          �
//�����������������������������������������������������������������������
If nPessoa == Nil
	If !Pergunte("PLS174", .T.)
		Return()
	Endif
Else
	Iif(!lAutoma,Pergunte("PLS174", .F.),"")
	Mv_Par01 := nPessoa
Endif

If mv_par01 == 1
	//���������������������������������������������������������������������Ŀ
	//� Cadastra pessoa juridica...                                         �
	//�����������������������������������������������������������������������
	lJuridico := .T.
	Plsa174Juri()
Elseif mv_par01 == 2
	//���������������������������������������������������������������������Ŀ
	//� Cadastra pessoa fisica...                                           �
	//�����������������������������������������������������������������������
	lJuridico := .F.
	plsa174Fisi()

Else
	lAmbos := .T.
	PLSA260(lAutoma,nAutoma)
Endif

BA1->( dbClearFilter() )
BQC->( dbClearFilter() )
BA3->( dbClearFilter() )

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA174juri Autor �Geraldo Felix Junior� Data �  18/06/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de pessoa juridico...                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA174juri()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cFiltro
Local aRotUsr := {}
Local nRotUsr := 0
PRIVATE lPermAbr  := .T.
Private cCadastro := Fundesc() //"Cadastro de Familias - Pessoa Juridica"

//���������������������������������������������������������������������Ŀ
//� Monta um aRotina proprio                                            �
//�����������������������������������������������������������������������

Private aRotina := MenuDef()

PRIVATE aCdCores := { ;
	{ 'BR_VERDE'   ,'Subcontrato Ativo' },;
	{ 'BR_VERMELHO', 'Subcontrato Bloqueado' }}

Private cString := "BQC"

If ExistBlock("PL174JBT")
	aRotUsr := ExecBlock( "PL174JBT",.F.,.F.,{aRotina} )
	For nRotUsr := 1 To Len(aRotUsr)
		aAdd(aRotina,aRotUsr[nRotUsr])
	Next
EndIf
dbSelectArea("BQC")
dbSetOrder(3)

dbSelectArea(cString)

cFiltro := "BQC_FILIAL = '"+xFilial("BQC")+"' AND D_E_L_E_T_ = ' '"
DbSelectArea("BQC")

BQC->(DbSeek(xFilial("BQC")))

BQC->(mBrowse( 6,1,22,75,cString,,"BQC->BQC_CODBLO<>Space(03)",,,,,,,,,,,,cFiltro ))


Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA174FISi Autor �Geraldo Felix Junior� Data �  18/06/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de pessoa fisica...                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA174FISI()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cFiltro
Local aCores := { ;
	{"(nOk := Plsa660Blq()) = 4", 'BR_PRETO'},;
	{"nOk = 3", 'BR_AMARELO'},;
	{".T.", 'BR_VERDE'}}

Private cString := "BG9"
Private cCadastro := "Cadastro de Familias - Pessoa Fisica"
Private aRotina := MenuDef()
PRIVATE aCdCores := { ;
	{'BR_VERDE'  ,'Empresa OK'},;
	{'BR_AMARELO','Familia(s) Bloqueada(s) Parcial(s)'},;
	{'BR_PRETO'  ,'Familia(s) Bloqueada(s)'}}

(cString)->(dbSetOrder(1))
cFiltro := "BG9_FILIAL = '"+xFilial("BG9")+"' AND BG9_TIPO = '1' AND D_E_L_E_T_ = ' '"
(cString)->(DbSeek(xFilial()))

//���������������������������������������������������������������������Ŀ
//� Coloca o subcontrato em EOF() por causa dos inicializadores padroes �
//�����������������������������������������������������������������������
BQC->(dbGoto(LastRec()+1))
mBrowse(6, 1, 22, 75, cString,,,,,, aCores,,,,,,,, cFiltro)

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
 	{"Selecionar","PLSA260"   	,0, 3		, 0, Nil} ,;
  {"Legenda"   ,"PLSA660LEG",0, K_Incluir, 0, .F.}}
Return(aRotina)