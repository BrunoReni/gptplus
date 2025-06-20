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
Function PLSA940PIN()

Local   cFilB08   := ""
Local   nOrdB05   := B05->(Recno())
Local cChvPad    := BR8->BR8_CODPAD
Local cChvPsa    := BR8->BR8_CODPSA

Private aRotina   := MenuDef()

cChvReg  := B05->B05_CODIGO 
cChvTipo := B05->B05_TIPO 

cFilB08  := "@B08_FILIAL = '"+xFilial("B08")+"' AND B08_CHVPAD = '"+cChvPad+"' AND B08_CHVPSA = '"+alltrim(cChvPsa)+"'"
cFilB08  += " AND B08_CHVREG = '"+cChvReg+"' AND D_E_L_E_T_ = ' '"

oBrowse := FWMBrowse():New()
oBrowse:setMainProc("PLSA940PIN")
oBrowse:SetAlias('B08')
oBrowse:SetDescription(PLSRetTit("B08")) 	//Documenta��o
oBrowse:SetMenuDef('PLSA940PIN')		//Define que este � o Browse que ser� utilizado na chamada da fun��o
oBrowse:SetFilterDefault(cFilB08) //Define o Filtro padr�o
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

aRotina     := {{ STR0001		, 'AxPesqui'    , 0 , K_Pesquisar  },; //"Pesquisar" //"Pesquisar"
                { STR0002	, 'AxVisual'    , 0 , K_Visualizar },; //"Visualizar"//"Visualizar"
                { STR0009	, 'PLSA940INC'	, 0 , K_Incluir    },; //"Incluir" //"Incluir"
				  { STR0010	, 'PLSA940INC' 	, 0 , K_Alterar    },; //"Alterar" //"Alterar"
 				  { STR0011	, 'AxDeleta'	, 0 , K_Excluir    }}  //"Excluir" //"Excluir"
 					     
Return aRotina