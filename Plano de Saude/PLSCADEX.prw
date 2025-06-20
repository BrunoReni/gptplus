#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "plscadex.ch"
 
/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪目北
北矲un噭o�	 PLSCADEX 	 矨utor � Hugo Vieira   � Data �24/03/15   潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪拇北
北�          矯adastrar as exce珲es para auditoria de procedimentos.
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
Function PLSCADEX()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'B1O' )
oBrowse:SetDescription(STR0006) //"Exce玢o para Auditoria"
oBrowse:Activate()

Return (nil)

//-------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := {}

aAdd( aRotina, { STR0001/*'Pesquisar'*/ , 				'PesqBrw'        , 0, 1, 0, .T. } )
aAdd( aRotina, { STR0002/*'Visualizar'*/, 				'VIEWDEF.PLSCADEX', 0, 2, 0, NIL } )
aAdd( aRotina, { STR0003/*'Incluir'*/   , 				'VIEWDEF.PLSCADEX', 0, 3, 0, NIL } )
aAdd( aRotina, { STR0004/*'Alterar'*/   , 				'VIEWDEF.PLSCADEX', 0, 4, 0, NIL } )
aAdd( aRotina, { STR0005/*'Excluir'*/   , 				'VIEWDEF.PLSCADEX', 0, 5, 0, NIL } )
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados

LOCAL oModelObj

// Cria o objeto do Modelo de Dados

Local oStrB1O:= FWFormStruct(1,'B1O')

oModelObj := MPFormModel():New( STR0006/*"Exce珲es para Auditoria de Procedimentos"*/, /*bPreValidacao*/,/* {|oMdl|PLSVLDCADEX(oMdl)}*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul醨io de edi玢o por campo
oModelObj:AddFields( 'B1OMASTER', NIL, oStrB1O )
oModelObj:SetPrimaryKey( { "B1O_FILIAL", "B1O_FILIAL,B1O_CODREG,B1O_CODPRO,B1O_TPGUIA"} )

// Adiciona a descricao do Modelo de Dados
oModelObj:SetDescription(STR0001) //'Calend醨io de Pagamento de Benefici醨io'

// Adiciona a descricao do Componente do Modelo de Dados
oModelObj:GetModel( 'B1OMASTER' ):SetDescription( STR0006 ) //"Exce珲es para Auditoria de Procedimentos"

Return oModelObj

//-------------------------------------------------------------------
Static Function ViewDef()

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSCADEX' )
Local oStruB1O := FWFormStruct(2, 'B1O')
Local oView    := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado

oView:SetModel( oModel )
oView:AddField('B1O' , oStruB1O,'B1OMASTER' )

oView:SetViewAction( 'BUTTONOK', { |oView| } )

oView:CreateHorizontalBox( 'BOX1', 50)
oView:CreateVerticalBox( 'FORMB1O', 100, 'BOX1')

oView:SetOwnerView('B1O','FORMB1O')

Return oView

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪目北
北矲un噭o�	 PLSVLDEXAUDITORIA 	 矨utor � Hugo Vieira   � Data �24/03/15   � 北
北媚哪哪哪饶哪拍哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪幢�
北�          砎erifica se existe exce玢o para auditoria.					   北
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
Function PLSVLDEX(cChave,nIdade,nQtdPro)

LOCAL lRet := .F.

//Order(2)->  B1O_FILIAL+B1O_CODPRO+B1O_TPGUIA
B1O->(dbSetOrder(2))
If B1O->(dbSeek(xFilial("B1O") + cChave))
	IF B1O->B1O_QTDPRO >= nQtdPro
		If EMPTY(B1O->B1O_IDADE) .OR. val(B1O->B1O_IDADE) <= Calc_Idade(dDataBase,nIdade)
			lRet := .T.
		EndIF
	ENDIF
EndIf

If ExistBlock("PLCADEXC")
	lRet := execblock("PLCADEXC",.F.,.F.,{cChave,nIdade,nQtdPro,lRet}) 
Endif

return (lRet)
