#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//--------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} GFEC078
Consultar Cota��es de Negocia��o de Frete
Generico

@sample
GFEC078()

@author Leandro Conradi Zmovirzynski    
@since 22/05/2018
@version 1.0                                                                                      
/*/
//------------------------------------------------------------------------------------------------

Function GFEC078()
    Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:setAlias("GXS")
	oBrowse:setMenuDef("GFEC078")
	oBrowse:setDescription("Consulta de Cota��es de Frete")
	oBrowse:Activate()
    
Return Nil  


//------------------------------------------------------------------------------
// Adiciona bot�es do browse
//------------------------------------------------------------------------------

Static Function MenuDef()
	Local aRotina := {}

	AAdd(aRotina, {"Pesquisar"            , 'AxPesqui'        , 0, 1 , 0, .T. /*Habilita Menu Funcional*/})//"Pesquisar"
	AAdd(aRotina, {"Visualizar"           , "VIEWDEF.GFEC078" , 0, 2 , 0, .T. /*Habilita Menu Funcional*/})//"Visualizar"
	AAdd(aRotina, {"Consultar Requisi��o" , "GFEC059CRQ()"    , 0, 2 , 0, .F. /*Habilita Menu Funcional*/})//"Consultar Requisi��o"
	AAdd(aRotina, {"Imprimir"             , "VIEWDEF.GFEC078" , 0, 8 , 0, .T. /*Habilita Menu Funcional*/})//"Imprimir"

Return aRotina

//------------------------------------------------------------------------------
// Fun��o ModelDef
//------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel   := MPFormModel():New('GFEC078', /*bPreValid*/ , /*pValid*/ , /*bComValid*/ ,/*bCancel*/ )
    Local oStruGXS := FWFormStruct(1,'GXS')

	oModel:AddFields('GFEC078_GXS', /*cOwner*/, oStruGXS)
	oModel:SetPrimaryKey({"GXS_FILIAL", "GXS_IDREQ"})  
	  
Return oModel

//------------------------------------------------------------------------------
// Fun��o ViewDef
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel('GFEC078')
	Local oView    := FWFormView():New()
	Local oStruGXS:= FWFormStruct(2,'GXS')
	
	oView:SetModel(oModel)
	oView:AddField('GFEC078_GXS', oStruGXS, /**/ )
	
Return oView

Function GFEC059CRQ()
	
	dbSelectArea("GWR")
	GXR->( dbSetOrder(1) )
	If GXR->( dbSeek(xFilial("GXS") + GXS->GXS_IDREQ ))
			FWExecView("Visualiza", "GFEC059", 1,,{|| .T.})		
	EndIf
	
Return
