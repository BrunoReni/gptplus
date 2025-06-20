#Include "plsa940.ch" 
#Include "PLSMGER.CH"
#Include "PROTHEUS.CH" 

/*/
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Funcao    � PLSA940SDE � Autor � Daher			   � Data � 13.09.08 ���
������������������������������������������������������������������������Ĵ��
���Descricao � Sistema Dent�rio						                     ���
������������������������������������������������������������������������Ĵ��
���Sintaxe   � PLSA940Mov(cAlias,nReg,nOpc)                              ���
������������������������������������������������������������������������Ĵ��
��� Uso      � PLSA940                                                   ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Function PLSA940SDE()

Local   cFilB05 	:= ""
Local   __aNiveis   := PLSESPNIV(BR8->BR8_CODPAD)
Local   nNiveis     := (__aNiveis[1]+1)
Local   nRecBR8 	:= BR8->(Recno())

Private aRotina     := MenuDef()

If BR8->BR8_ODONTO == '1'
		
	If nNiveis <> val(BR8->BR8_NIVEL)
		Help("",1,"PLSA940001")
		Return
	EndIf
		
	cChvPad    := BR8->BR8_CODPAD
	cChvPsa    := BR8->BR8_CODPSA 
	
	cFilB05    := "@B05_FILIAL = '"+xFilial("B05")+"' AND B05_CODPAD = '"+cChvPad+"' AND B05_CODPSA = '"+cChvPsa+"' AND D_E_L_E_T_ = ' '"
	
//	BR8->(DbGoTo(nRecBR8))
	
	oBrowse := FWMBrowse():New()
	oBrowse:setMainProc("PLSA940SDE")
	oBrowse:SetAlias('B05')
	oBrowse:SetDescription(PLSRetTit("B05")) 	//Documenta��o
	oBrowse:SetMenuDef('PLSA940SDE')		//Define que este � o Browse que ser� utilizado na chamada da fun��o
	oBrowse:SetFilterDefault(cFilB05) //Define o Filtro padr�o
	oBrowse:Activate()
	
	Return
Else

	Help("",1,"PLSA94DENT")
	
	Return
Endif

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
Local aPtoEntrada := {}

aRotina     := {{ STR0001		, 'AxPesqui'    , 0 , K_Pesquisar  },; //"Pesquisar" //"Pesquisar"
                         { STR0002		, 'AxVisual'    , 0 , K_Visualizar },; //"Visualizar"  //"Visualizar"
                         { STR0009		, 'AxInclui'	, 0 , K_Incluir    },; //"Incluir" //"Incluir"
				         { STR0010		, 'AxAltera' 	, 0 , K_Alterar    },; //"Alterar" //"Alterar"
 					     { STR0011		, 'PLSA940Exc()', 0 , K_Excluir    },; //"Excluir" //"Excluir"
				         { STR0033	 	, 'PLSA940PIN'	, 0 , K_Visualizar },; //"Proc. Incomp." //"Proc. Incomp."
				         { STR0034		, 'PLSA940FAC'  , 0 , K_Visualizar }}  //"Faces"

aadd(aRotina,{ OemtoAnsi(STR0051)	,'PlVigDifId("B05","B05->(B05_FILIAL+B05_CODPAD+B05_CODPSA+B05_CODIGO+B05_TIPO)",B05->B05_DIFIDA)',0,K_Alterar})		//"Period. Dif. Idade"

aadd(aRotina,{'Pre-Requis','PLSA940PRE',0,K_Incluir})

If Existblock("PLS940M2")
	aPtoEntrada := Execblock("PLS940M2",.f.,.f.)
	aadd(aRotina,{aPtoEntrada[1],aPtoEntrada[2],0,K_Incluir})
EndIf

Return aRotina