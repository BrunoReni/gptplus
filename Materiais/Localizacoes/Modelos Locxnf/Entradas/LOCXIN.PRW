#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} LOCXIN
Model para todos los documentos de campos de entradas
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Function LOCXIN()
Local oBrowse	:= Nil

	oBrowse := BrowseDef()
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Static Function BrowseDef()
Local oBrowse := FWMBrowse():New()

    oBrowse:SetAlias('SF1')

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Static Function MenuDef()
Local aRotina := {}
	
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.LOCXIN' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE 'Incluir' ACTION 'VIEWDEF.LOCXIN' OPERATION 3 ACCESS 0 // 'Incluir'
	ADD OPTION aRotina TITLE 'Alterar' ACTION 'VIEWDEF.LOCXIN' OPERATION 4 ACCESS 0 // 'Alterar'
	
Return aRotina


/*/{Protheus.doc} ModelDef
Definición de modelo de datos
@author 	raul.medina
@return		oModel objeto del Modelo
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Static Function ModelDef()
Local aCampSEV      := {"EV_NATUREZ", "EV_VALOR", "EV_PERC", "EV_RATEICC", "EV_PREFIXO", "EV_NUM", "EV_CLIFOR", "EV_LOJA", "EV_FILIAL"} 
Local oModel        := Nil
Local oStruSF1      := NIL
Local oStruSD1      := FWFormStruct(1, 'SD1', , .F.)
Local oStruDUP		:= FWFormModelStruct():New()
Local oStruSEV      := FWFormStruct(1, 'SEV', { | cCampo | FindString(AllTrim(cCampo), aCampSEV)}, .F.)
Local oInputFields	:= Nil
Local oEvtFinIn		:= LXINFIN():New()
Local oEvtFisIn		:= LXINFIS():New()
//Local oEvtEstIn     := LXINEST():New()
Local nTamDup       := 0

    oModel := MPFormModel():New( 'LOCXIN',/*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

    oInputFields := InputFieldsAll():New("", .T., .F., .F., .F., .F., .F.)
    oInputFields:AddModel()

    oStruSF1 := oInputFields:getModel()

    //Tabla de saldos y monedas
	oStruDUP:AddTable('' , { '' } , "DUPLICATAS", {|| ''})
    nTamDup := GetSx3Cache('E2_NUM', 'X3_TAMANHO') + GetSx3Cache('E2_PREFIXO', 'X3_TAMANHO') +  GetSx3Cache('E2_PARCELA', 'X3_TAMANHO') + GetSx3Cache('E2_VENCTO', 'X3_TAMANHO') +  GetSx3Cache('E2_VALOR', 'X3_TAMANHO') + 12
	oStruDUP:AddField('DUP' 	, 'DUP'	, 'DUP' 	, 'C' , nTamDup)
    

    //Campos obligatorios del encabezado de documentos de entrda.
    oStruSF1:SetProperty( '*'           , MODEL_FIELD_OBRIGAT , .F.)
    /*oStruSF1:SetProperty('F1_FORNECE'   , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF1:SetProperty('F1_LOJA'      , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF1:SetProperty('F1_DOC'       , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF1:SetProperty('F1_EMISSAO'   , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF1:SetProperty('F1_DTDIGIT'   , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF1:SetProperty('F1_MOEDA'     , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF1:SetProperty('F1_TXMOEDA'   , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF1:SetProperty('F1_TIPO'      , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF1:SetProperty('F1_FORMUL'    , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF1:SetProperty('F1_ESPECIE'   , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF1:SetProperty('F1_TIPODOC'   , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF1:SetProperty('F1_COND'      , MODEL_FIELD_OBRIGAT , .T.)*/
    oStruSF1:SetProperty( 'F1_GERAPED'  , MODEL_FIELD_VALUES  , {})

    //Campos obligatorios de los items de documentos de entrada.
    oStruSD1:SetProperty( '*'           , MODEL_FIELD_OBRIGAT , .F.)
    /*oStruSD1:SetProperty('D1_COD'       , MODEL_FIELD_OBRIGAT , .T.)
    oStruSD1:SetProperty('D1_UM'        , MODEL_FIELD_OBRIGAT , .T.)
    oStruSD1:SetProperty('D1_VUNIT'     , MODEL_FIELD_OBRIGAT , .T.)
    oStruSD1:SetProperty('D1_TOTAL'     , MODEL_FIELD_OBRIGAT , .T.)
    oStruSD1:SetProperty('D1_TES'       , MODEL_FIELD_OBRIGAT , .T.)
    oStruSD1:SetProperty('D1_LOCAL'     , MODEL_FIELD_OBRIGAT , .T.)
    oStruSD1:SetProperty('D1_CF'        , MODEL_FIELD_OBRIGAT , .T.)*/

    oStruSF1:AddField('', '',"BASEDUP","N",GetSX3Cache("F1_VALMERC", "X3_TAMANHO"),GetSX3Cache("F1_VALMERC", "X3_DECIMAL"),/*valid*/,,,,)

    oStruSEV:SetProperty('*'        , MODEL_FIELD_OBRIGAT , .F.)

    oModel:addFields('SF1_MASTER',,oStruSF1)
    oModel:addGrid('SD1_DETAIL','SF1_MASTER',oStruSD1,,)
    oModel:addGrid('DUP_DETAIL','SF1_MASTER',oStruDUP,,)
    oModel:addGrid('SEV_DETAIL','SF1_MASTER',oStruSEV,,)

    // Indica que es opcional tener datos informados en el grid
    oModel:GetModel( 'SD1_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DUP_DETAIL' ):SetOptional(.T.)
    oModel:GetModel( 'SEV_DETAIL' ):SetOptional(.T.)

    oModel:SetPrimaryKey({'F1_DOC','F1_SERIE','F1_FORNECE','F1_LOJA'}) //{'F1_FILIAL','F1_DOC','F1_SERIE','F1_FORNECE','F1_LOJA','F1_TIPO'}

    oModel:SetRelation('SD1_DETAIL',{ { 'D1_FILIAL', 'xFilial( "SD1" )' }, {'D1_DOC', 'F1_DOC'}, {'D1_SERIE', 'F1_SERIE'}, {'D1_FORNECE', 'F1_FORNECE'}, {'D1_LOJA', 'F1_LOJA'}}, SD1->(IndexKey(1)))

    //Indica No grabar datos de un componente del modelo de datos
	oModel:GetModel('DUP_DETAIL'):SetOnlyQuery(.T.)
    oModel:GetModel('SEV_DETAIL'):SetOnlyQuery(.T.)

    oModel:InstallEvent("LXINFIS"	,/*cOwner*/,oEvtFisIn) //Evento fiscal
    oModel:InstallEvent("LXINFIN"	,/*cOwner*/,oEvtFinIn) //Evento financiero
    //oModel:InstallEvent("LXINEST"	,/*cOwner*/,oEvtEstIN) //Evento Stock

Return oModel

/*/{Protheus.doc} ViewDef
Interface del modelo de datos
@return		oView objeto del View
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/
Static Function ViewDef()
Local oStruSF1      := Nil
Local oStruSD1      := FWFormStruct( 2, 'SD1', , .T. )
Local oView         := Nil
Local oInputFields	:= Nil
Local oModel	    := FWLoadModel('LOCXIN')

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:SetContinuousForm(.T.)

    oInputFields := InputFieldsAll():New("", .T., .F., .F., .F., .F., .F.)
    oInputFields:AddFields()
    oStruSF1 := oInputFields:GetView()

    oView:AddField('oStruSF1' , oStruSF1, 'SF1_MASTER' )
    oView:AddGrid('oStruSD1'  , oStruSD1, 'SD1_DETAIL')

    //Divisiones horizontales
	oView:CreateHorizontalBox( 'CIMA' , 35)
	oView:CreateHorizontalBox( 'MEDIO', 35)
	oView:CreateHorizontalBox( 'BAIXO', 30)

    oView:SetOwnerView('oStruSF1', 'CIMA')
	oView:SetOwnerView('oStruSD1', 'MEDIO')
	
Return oView
