#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA090.CH"

#DEFINE WMSA09001 'WMSA09001'

//---------------------------------------------------------------------------
/*/{Protheus.doc} WMSA090
Cadastro de complementos de produto para WMS

@author Wander Horongoso
@since 16/10/2020
@version 1.0
@obs  A tabela de complementos de produto (SB5) estourou a quantidade m�xima de campos (255).
Por este motivo, foi necess�rio criar uma tabela nova e um programa espec�fico para manipul�-la.
/*/
//---------------------------------------------------------------------------
Function WMSA090()
Local oBrowse    := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("D1A")         // Alias da tabela utilizada
	oBrowse:SetMenuDef("WMSA090")   // Nome do fonte onde esta a fun��o MenuDef
	oBrowse:SetDescription(STR0001) // Descri��o do browse "Complementos de Produto WMS"
	oBrowse:SetAmbiente(.F.)        // Desabilita op��o Ambiente do menu A��es Relacionadas
	oBrowse:SetWalkThru(.F.)        // Desabilita op��o WalkThru do menu A��es Relacionadas
	oBrowse:Activate()

Return NIL

/*---------------------------------------------------------------------------
---MenuDef
---MenuDef com as rotinas do Browse
---Wander Horongoso 16/10/2020
---------------------------------------------------------------------------*/
Static Function MenuDef()
Private aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002    ACTION "PesqBrw"         OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0003    ACTION "VIEWDEF.WMSA090" OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0004    ACTION "VIEWDEF.WMSA090" OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.WMSA090" OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.WMSA090" OPERATION 5 ACCESS 0 // Excluir
		
Return (aRotina)


/*---------------------------------------------------------------------------
---ModelDef
---Modelo de dados
---Wander Horongoso 16/10/2020
---------------------------------------------------------------------------*/
Static Function ModelDef()
Local oModel := Nil
Local oStruD1A := FwFormStruct( 1, "D1A" )
Local bPosValid := { |oModel| PosVldMdl(oModel) }

	oModel:= MpFormModel():New("WMSA090", , { |oModel| PosVldMdl(oModel) })
	oModel:SetDescription(STR0001) // Complemento de Produto WMS

	oModel:AddFields("D1AMASTER",Nil,oStruD1A)
	oModel:SetPrimaryKey({"D1A_FILIAL","D1A_COD"})
	
Return oModel

/*---------------------------------------------------------------------------
---ViewDef
---Exibe browse de acordo com a estrutura
---Wander Horongoso 16/10/2020
---------------------------------------------------------------------------*/
Static Function ViewDef()
Local oModel := FwLoadModel("WMSA090")
Local oStruD1A := FwFormStruct (2, "D1A")
Local oView := Nil

	oView := FwFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VwFieldD1A', oStruD1A, 'D1AMASTER')

Return oView

Static Function PosVldMdl(oModel)
Local lRet := .T.
Local oModelD1A := oModel:GetModel("D1AMASTER")
	
	If Empty(oModelD1A:GetValue('D1A_SEREPR')) .And. Empty(oModelD1A:GetValue('D1A_ENDEPR'))
		oModel:SetErrorMessage('D1AMASTER',,,,WMSA09001, STR0007, STR0008) //'Servi�o de entrada de produ��o e endere�o de entrada de produ��o n�o informados.' //'Deve-se informar servi�o de entrada de produ��o, endere�o de produ��o ou ambos.' 
		lRet := .F.
	EndIf

Return lRet
