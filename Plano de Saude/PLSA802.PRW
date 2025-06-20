#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSA802.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA802
Funcao para abrir cadastro de Canais de Comunica��o
@author Oscar Zanin
@since 09/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA802()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B9M')
oBrowse:SetDescription(FunDesc())
oBrowse:Activate()

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 09/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title STR0002 /*'Visualizar' */Action 'VIEWDEF.PLSA802' Operation 2 Access 0
Add Option aRotina Title STR0003 /*'Incluir'    */Action 'VIEWDEF.PLSA802' Operation 3 Access 0
Add Option aRotina Title STR0004 /*'Alterar'    */Action 'VIEWDEF.PLSA802' Operation 4 Access 0
Add Option aRotina Title STR0005 /*'Excluir'    */Action 'VIEWDEF.PLSA802' Operation 5 Access 0
Add Option aRotina Title STR0006 /*'Imprimir'   */Action 'VIEWDEF.PLSA802' Operation 8 Access 0
Add Option aRotina Title STR0007 /*'Copiar'     */Action 'VIEWDEF.PLSA802' Operation 9 Access 0

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados
@author Oscar Zanin
@since 08/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB9M:= FWFormStruct(1,'B9M')

oModel := MPFormModel():New( 'PLSA802', , {|| PLSA802OK(oModel) } )//Cria a estrutura do Modelo de dados e Define e a fun��o que ir� Validar no "OK"
oModel:addFields('MasterB9M',/*cOwner*/,oStrB9M)						//Adiciona ao modelo um componente de formul�rio
oModel:getModel('MasterB9M')
oModel:SetDescription(FunDesc())										// Adiciona a descri��o do Modelo de Dados

oModel:SetPrimaryKey( {"B9M_FILIAL", "B9M_CODINT", "B9M_CODCAN"} ) 

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do interface
@author Oscar Zanin
@since 09/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrB9M:= FWFormStruct(2, 'B9M', { |cCampo| PLSA802CMP(cCampo) })

oView := FWFormView():New()								// Cria o objeto de View
oView:SetModel(oModel)									// Define qual Modelo de dados ser� utilizado
oView:AddField('FrmB9M' , oStrB9M,'MasterB9M' ) 		// Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)
oView:CreateHorizontalBox( 'BxB9M', 100)				// Cria o Box que ir� conter a View
oView:SetOwnerView('FrmB9M','BxB9M')					// Associa a View ao Box

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA802OK
Validar bot�o confirmar
@author Oscar Zanin
@since 09/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA802OK(oModel)
LOCAL lRet     		:= .T.
LOCAL cMsg     		:= ""
LOCAL oModelDetail	:= oModel:GetModel( 'MasterB9M' )
LOCAL cDescri  		:= ""
LOCAL cCodINt			:= ""
LOCAL nOpc				:= oModel:GetOperation()

If (nOpc <> 5) //N�o para "Excluir"
	cDescri := oModelDetail:GetValue('B9M_DESCAN')
	cCodInt := PLSINTPAD()

	B9M->(DbSelectArea("B9M"))
	B9M->(DbSetOrder(3)) // B9M_FILIAL + B9M_DESCAN
	
	//Busca se a Descri��o j� foi cadastrada
	If (B9M->(MsSeek(XFilial("B9M") + cCodInt + cDescri)))
   		cMsg := STR0001 //"Canal de Comunica��o j� cadastrado!"
   		Help( ,, 'HELP',, cMsg, 1, 0)
   		lRet := .F.
	EndIf

	B9M->(DbCloseArea())
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA802CMP
Tratamento para campos que n�o devem ir na View
@author Oscar Zanin
@since 19/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA802CMP(cCampo)

Local lRet	:= .T.

If cCampo == "B9M_CODINT"
	lRet := .F.
EndIf

If cCampo == "B9M_DESINT"
	lRet := .F.
EndIf

Return lRet