#Include "plsa940.ch" 
#Include "PLSMGER.CH"
#Include "PROTHEUS.CH" 

/*/
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Funcao    � PLSA940PIN � Autor � Daher			   � Data � 13.09.08 ���
������������������������������������������������������������������������Ĵ��
���Descricao � Procedimentos Incompativeis			                     ���
������������������������������������������������������������������������Ĵ��
���Sintaxe   � 								                             ���
������������������������������������������������������������������������Ĵ��
��� Uso      � PLSA940                                                   ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Function PLSA940FIN()

Local cFilB87		:= ""
LOCAL nOrdB87      	:= B87->(Recno())
LOCAL cDenReg 		:= BYL->BYL_CODIGO
Local cChvPad    := BR8->BR8_CODPAD
Local cChvPsa    := BR8->BR8_CODPSA

PRIVATE cCodFace  	:= BYL->BYL_FACE
PRIVATE cDesFace  	:= BYL->BYL_DESFAC
PRIVATE aRotina    := MenuDef()

cFilB87 	   := "@B87_FILIAL = '"+xFilial("B87")+"' AND B87_CHVPAD = '"+cChvPad+"' AND B87_CHVPSA = '"+alltrim(cChvPsa)+"'"
cFilB87 	   += " AND B87_CHVREG = '"+cDenReg+"' AND B87_FACE = '"+cCodFace+"' AND D_E_L_E_T_ = ' ' " 

oBrowse := FWMBrowse():New()
oBrowse:setMainProc("PLSA940FIN")
oBrowse:SetAlias('B87')
oBrowse:SetDescription(PLSRetTit("B87")) 	//Documenta��o
oBrowse:SetMenuDef('PLSA940FIN')		//Define que este � o Browse que ser� utilizado na chamada da fun��o
oBrowse:SetFilterDefault(cFilB87) //Define o Filtro padr�o
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 08/04/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aRotina     := {  { STR0001		, 'AxPesqui'    , 0 , K_Pesquisar  },; //"Pesquisar" //"Pesquisar"
                  { STR0002		, 'AxVisual'    , 0 , K_Visualizar },; //"Visualizar"  //"Visualizar"
                  { STR0009		, 'PLSA940INC'	, 0 , K_Incluir    },; //"Incluir" //"Incluir"
				    { STR0010		, 'PLSA940INC' 	, 0 , K_Alterar    },; //"Alterar"                 //"Alterar"
 			        { STR0011		, 'AxDeleta'	, 0 , K_Excluir    }} //"Excluir" //"Excluir"		  
 					     
Return aRotina