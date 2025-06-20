#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"

Function GFEX062(cTpCot,cCodCot)
	Local oBrw := Nil
	Local cFunBkp := FunName()

	Default cTpCot := "1"
	Default cCodCot := ""

	// Workaround para executar o MenuDef() correto.
	// Assim considera os privil�gios espec�ficos setados no SIGACFG.
	SetFunName("GFEX062")

	oBrw := FWMBrowse():New()
	oBrw:SetAlias("GVQ")
	oBrw:SetDescription("Cota��o de frete")
	oBrw:SetMenuDef("GFEX062")
	oBrw:AddLegend("GVQ_ENVCOP == '1'","GREEN" ,"Enviada") // "Enviada"
	oBrw:AddLegend("GVQ_ENVCOP == '2'","ORANGE","N�o Enviada") // "N�o Enviada"
	oBrw:SetFilterDefault("@ GVQ_TPCOT = '"+cTpCot+"' AND GVQ_CODCOT = '"+cCodCot+"'")
	oBrw:Activate()

	SetFunName(cFunBkp)

Return Nil

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"  ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 DISABLE MENU // Pesquisar
	ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.GFEX062' OPERATION 2 ACCESS 0 DISABLE MENU // Visualizar
	
Return aRotina

Static Function ModelDef()
	Local oModel := Nil
	Local oStrGVQ := FWFormStruct(1,'GVQ')
	
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost   Code-Block de valida��o do formul�rio de edi��o
	// bCommit Code-Block de persist�ncia do formul�rio de edi��o
	// bCancel Code-Block de cancelamento do formul�rio de edi��o
	oModel := MPFormModel():New('GFEX062', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost        Code-Block de valida��o do formul�rio de edi��o
	// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
	oModel:AddFields('GFEX062_GVQ', Nil, oStrGVQ,/*bPre*/,/*bPost*/,/*bLoad*/)

Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel('GFEX062')
	Local oStrGVQ := FWFormStruct(2,'GVQ')
	Local oView := Nil
		
	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	
	// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,S� � necess�rio caso estamos mundando o ID no View.
	oView:AddField('GFEX062_GVQ' ,oStrGVQ, /*cLinkID*/)
	
Return oView
