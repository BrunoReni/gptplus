#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA887.CH' 

PUBLISH MODEL REST NAME recibosTotvs  

/*/{Protheus.doc} FINA887
Fonte de cobros diversos (Padrão)
@author 	raul.medina
@since 		05/04/2021
@version	12.1.27 / Superior
/*/

Function FINA887()
Local oBrowse	:= Nil

	oBrowse := BrowseDef()
	
	
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author	 	raul.medina
@since 		05/04/2021
@version	12.1.27 / Superior
/*/

Static Function BrowseDef()
Local oBrowse	:= Nil

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('FJT')
oBrowse:SetDescription(STR0097)

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		05/04/2021
@version	12.1.27 / Superior
/*/

Static Function MenuDef()
Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0087 ACTION 'VIEWDEF.FINA887' OPERATION 1 ACCESS 0		// 'Buscar'
	ADD OPTION aRotina TITLE STR0088 ACTION 'VIEWDEF.FINA887' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0089 ACTION 'VIEWDEF.FINA887' OPERATION 3 ACCESS 0 	// 'Incluir'
	ADD OPTION aRotina TITLE STR0090 ACTION 'VIEWDEF.FINA887' OPERATION 4 ACCESS 0 	// 'Alterar'
	ADD OPTION aRotina TITLE STR0091 ACTION 'VIEWDEF.FINA887' OPERATION 6 ACCESS 0	// 'Imprimir'
	ADD OPTION aRotina TITLE STR0092 ACTION 'VIEWDEF.FINA887' OPERATION 7 ACCESS 0 	// 'Enviar'

	ADD OPTION aRotina TITLE STR0093 ACTION 'VIEWDEF.FINA887' OPERATION 8 ACCESS 0 //"Anular"
	ADD OPTION aRotina TITLE STR0094 ACTION 'VIEWDEF.FINA887' OPERATION 9 ACCESS 0 //"Borrar"
	IF cPaisloc == "MEX" 
		ADD OPTION aRotina TITLE STR0095 ACTION 'VIEWDEF.FINA887' OPERATION 10 ACCESS 0 //"Generar CFDI"
	ENDIF
	IF cPaisloc == "ARG" 
		ADD OPTION aRotina TITLE STR0096 ACTION 'VIEWDEF.FINA887' OPERATION 11 ACCESS 0 //"Modificar"
	ENDIF
	
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author 	raul.medina
@return		oModel objeto del Modelo
@since 		05/04/2021
@version	12.1.27 / Superior
/*/

Static Function ModelDef()
Local cCampSE1		:= "E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_SALDO,E1_DESCONT,E1_MULTA,E1_JUROS,E1_MOEDA,E1_CANCEL,E1_NATUREZ,E1_MOTIVO"
Local oStruFJT		:= FWFormStruct(1, 'FJT', , .F.)
Local oStruSEL		:= FWFormStruct(1, 'SEL', , .F.)
Local oStruSE1 		:= FWFormStruct(1, 'SE1', { | cCampo | AllTrim( cCampo ) $ cCampSE1  }, .F.)
Local oStruMOE		:= FWFormModelStruct():New()
Local oStruGEN		:= FWFormModelStruct():New()
Local oStruADM		:= FWFormModelStruct():New()
Local oStruFAC		:= FWFormModelStruct():New()

Local oModel		:= Nil 
Local oEvtTit		:= F887FIN():New()
Local oEvtCtb		:= F887CTB():New()
Local nPosTpDoc		:= 0
	
	oStruFJT:AddField("GERANCC","GERANCC","GERANCC",'C',1) 
	oStruFJT:AddField("DOCUMEN","DOCUMEN","DOCUMEN",'C',3) //Para generar saldo - Para México y Perú no es considerado el contenido informado.
	oStruFJT:AddField("ASIENTO","ASIENTO","ASIENTO",'N',1) //Muestra Asientos.
	oStruFJT:AddField("AGRUPA" ,"AGRUPA" ,"AGRUPA" ,'N',1) //Agrupa Asientos.
	oStruFJT:AddField("ONLINE" ,"ONLINE" ,"ONLINE" ,'N',1) //Agrupa Asientos.
	oStruFJT:AddField("RAGENER" ,"RAGENER" ,"RAGENER" ,'L',1) //Para controlar la generación de RA
	oStruFJT:AddField("IMPRIMIR","IMPRIMIR","IMPRIMIR","L",1)//Indica si se realiza la impresión
	oStruFJT:AddField("EMAIL","EMAIL","EMAIL","L",1) //Indica si se realiza el envio del recibo

	//Uso para Perú, sólo en sus eventos.
	oStruFJT:AddField("EMITCOM","EMITCOM","EMITCOM",'N',1)  //Emite comprobante
	oStruFJT:AddField("RUTCOM" ,"RUTCOM" ,"RUTCOM" ,'C',12) //Nombre rutina comprobante
	
	//Campos virtuales para busqueda de Bancos
	oStruSEL:AddField(STR0107,STR0108,"EL_BANCOS",'C', GetSx3Cache("EL_BANCO","X3_TAMANHO")+GetSx3Cache("EL_AGENCIA","X3_TAMANHO")+GetSx3Cache("EL_CONTA","X3_TAMANHO")+2) //STR0107  "Busc. Bancos"  STR0108 "Buscador de Bancos"
   
    aAux := CreateTrigger('EL_BANCOS','EL_AGENCIA', 'BancosRec(FwFldGet("EL_BANCOS"),"2")',"002")
    oStruSEL:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
    
    aAux := CreateTrigger('EL_BANCOS','EL_CONTA', 'BancosRec(FwFldGet("EL_BANCOS"),"3")',"003")
    oStruSEL:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )

 	aAux := CreateTrigger('EL_BANCOS','EL_BANCO', 'BancosRec(FwFldGet("EL_BANCOS"),"1")',"001")
    oStruSEL:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
    

	oStruSEL:AddField(STR0109,STR0110,"EL_BCOCHQS",'C',GetSx3Cache("EL_BCOCHQ","X3_TAMANHO")+GetSx3Cache("EL_AGECHQ","X3_TAMANHO")+GetSx3Cache("EL_CTACHQ","X3_TAMANHO")+2) //STR0109 "Busc. Bco Ch"  STR0110 "Buscador de Bancos Cheque"
    aAux := CreateTrigger('EL_BCOCHQS','EL_BCOCHQ', 'BancosRec(FwFldGet("EL_BCOCHQS"),"1")',"001")
    oStruSEL:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
    
    aAux := CreateTrigger('EL_BCOCHQS','EL_AGECHQ', 'BancosRec(FwFldGet("EL_BCOCHQS"),"2")',"002")
    oStruSEL:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
    
	aAux := CreateTrigger('EL_BCOCHQS','EL_CTACHQ', 'BancosRec(FwFldGet("EL_BCOCHQS"),"3")',"003")
    oStruSEL:AddTrigger(   aAux[1] ,    aAux[2] ,    aAux[3] ,  aAux[4] )
    
	oStruSE1:AddField("CHECK"		,"CHECK"					,"CHECK"		,"L",1)
	oStruSE1:AddField("BAIXAR       ","BAIXAR                   ","BAIXAR"	    ,'N',16,2,{||.T.},{||.T.},{},.F.,,.F.,.F.,.T.,)
	oStruSE1:AddField("RECNO        ","RECNO                    ","RECNO"	    ,'N',32 ,0,{||.T.},{||.T.},{},.F.,,.F.,.F.,.T.,)
	
	//Tabla de saldos y monedas
	oStruMOE:AddTable('' , { '' } , "SALDOMOEDA", {|| ''})
	oStruMOE:AddField('Moneda' 	, 'Moneda'	, 'MOEDA' 	, 'C' , 1)
	oStruMOE:AddField('Tasa' 	, 'Tasa' 	, 'TASA' 	, 'N' , 10, 2)
	oStruMOE:AddField('Recibido', 'Recibido', 'RECIBIDO', 'N' , 16, 2)
	oStruMOE:AddField('Saldo'	, 'Saldo'	, 'SALDO' 	, 'N' , 16, 2)

	//Tabla de datos generales
	oStruGEN:AddTable('' , { '' } , "GENERALES", {|| ''})
	oStruGEN:AddField('HourSave' 	, 'HourSave'	, 'HOURSAVERECEIPT' 	, 'C' , 8)

	//Tabla de administradoras financieras
	oStruADM:AddTable('', { '' }, "CAJAFINANCIERA",{|| ''})
	oStruADM:AddField('Codigo'		,'Codigo'		,'CODE'			,'C' ,6)
	oStruADM:AddField('Descripcion'	,'Descripcion'	,'DESCRIPTION'	,'C',30)

	//Tabla de factoraje
	oStruFAC:AddTable('', { '' }, "FACTORAJE",{|| ''})
	oStruFAC:AddField('Valor'		,'Valor'		,'VALUE'		,'N' ,16,2)
	oStruFAC:AddField('Valor'		,'Valor'		,'FACTOR'		,'C' ,1)
	
	oModel := MPFormModel():New( 'FINA887'/*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	
	oModel:addFields('FJT_MASTER',,oStruFJT)
	
	oModel:addGrid('SEL_DETAIL','FJT_MASTER',oStruSEL,,)
	
	oModel:AddGrid('SE1_DETAIL','FJT_MASTER',oStruSE1, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	
	oModel:addGrid('MOE_DETAIL','FJT_MASTER',oStruMOE,,)

	oModel:addGrid('GEN_DETAIL','FJT_MASTER',oStruGEN,,)

	oModel:addGrid('ADM_DETAIL','FJT_MASTER',oStruADM,,)

	oModel:addGrid('FAC_DETAIL','FJT_MASTER',oStruFAC,,)
	
	oModel:SetRelation('SEL_DETAIL', { { 'EL_FILIAL', 'FWxFilial("SEL")' }, { 'EL_SERIE', 'FJT_SERIE' }, { 'EL_RECIBO', 'FJT_RECIBO' } }, SEL->(IndexKey(1)) )
	
	oModel:SetRelation( 'SE1_DETAIL', { { 'E1_FILIAL', 'xFilial( "SE1" )' }, { 'E1_CLIENTE', 'FJT_CLIENT' }, { 'E1_LOJA', 'FJT_LOJA' },  { 'E1_RECIBO', 'FJT_RECIBO'} }, SE1->( IndexKey( 1 ) ) )


	oStruSEL:SetProperty( 'EL_TIPODOC'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "TB" })
	oStruSEL:SetProperty( 'EL_TIPO'		, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_TPCRED'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_ACREBAN'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_ENDOSSA'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_TERCEIR'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_PREREC'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_TRANSIT'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_SELDOC'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_RECIBO'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_EMISSAO'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_DTVCTO'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })

	//Retirada de validaciones con variables privadas	
	oStruSEL:SetProperty( 'EL_TIPODOC'	, 	MODEL_FIELD_VALID,	FWBuildFeature( STRUCT_FEATURE_VALID, 'Pertence("|TB|CH") .Or. ' + GetSx3Cache("EL_TIPODOC","X3_VALID") ))
	oStruSEL:SetProperty( 'EL_LOJA'		, 	MODEL_FIELD_VALID,	{|oModelGrid| F887LOJA(oModelGrid) } ) //ExistCPO
	oStruSEL:SetProperty( 'EL_LOJORIG'	, 	MODEL_FIELD_VALID,	{|oModelGrid| F887LOJORI(oModelGrid) } ) //ExistCPO
	oStruSEL:SetProperty( 'EL_TIPO'		, 	MODEL_FIELD_VALID,	{|oModelGrid| FA887VALTP(oModelGrid,.F.) } ) //FA840VALTP
	oStruSEL:SetProperty( 'EL_BCOCHQ'	, 	MODEL_FIELD_VALID,	{|oModelGrid| F887BCO("EL_BCOCHQ", .F.) } )
	oStruSEL:SetProperty( 'EL_MOEDA'	, 	MODEL_FIELD_VALID,	{|oModelGrid| F887MOE(oModelGrid) } )
	oStruSEL:SetProperty( 'EL_DIACTB'	, 	MODEL_FIELD_VALID,	{|oModelGrid| F887DIACTB(oModelGrid) } ) // Valida parametro SEGOFI
	
	oStruSE1:SetProperty( 'E1_TIPO'		, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) //Fa840Bco
	oStruSE1:SetProperty( 'E1_CLIENTE'	, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) //existcpo("SA1",M->E1_CLIENTE,,,,.F.) .and. fa040Num() .And. FA040Natur()
	oStruSE1:SetProperty( 'E1_LOJA'		, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) //existcpo("SA1",M->E1_CLIENTE+M->E1_LOJA) .And. Fa040Num() .And. FA040Natur()
	oStruSE1:SetProperty( 'E1_MOEDA'	, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) //Fa040moed().and.fa040Irf().And.FA040VALOR()                                                                                                                                                                                          
	oStruSE1:SetProperty( 'E1_NATUREZ'	, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) // 
	oStruSE1:SetProperty( 'E1_NUM'		, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) // 
	oStruSE1:SetProperty( 'E1_PARCELA'	, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) // 
	oStruSE1:SetProperty( 'E1_PREFIXO'	, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) // 

	
	
	oStruSEL:SetProperty( 'EL_PREFIXO'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| .T. } ) //A840WHEN
	oStruSEL:SetProperty( 'EL_TPCRED'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887aWhen("TPCRED") } ) //a087awhen("TPCRED")
 
	nPosTpDoc := aScan(oStruSEL:aFields, {|x| x[3] == "EL_TIPODOC"})
	If nPosTpDoc > 0
		AADD(oStruSEL:aFields[nPosTpDoc][MODEL_FIELD_VALUES], "TB=TB" )
	EndIf
	
	//limpiado de disparadores
	//oStruSEL:aTriggers := {}

	oStruSEL:SetProperty( '*' 			, 	MODEL_FIELD_OBRIGAT, .F.)
	oStruSE1:SetProperty( '*' 			, 	MODEL_FIELD_OBRIGAT, .F.)
	
	//Se retira inicializador, ya que cada vez que se consulta el model detona el inicializador
	oStruFJT:SetProperty(  'FJT_RECIBO'	, MODEL_FIELD_INIT,	{|| "" })
	oStruFJT:SetProperty(  'FJT_VERSAO' , MODEL_FIELD_INIT, {|| '00' })
	oStruFJT:SetProperty(  'FJT_VERATU' , MODEL_FIELD_INIT, {|| '1' })
	oStruFJT:SetProperty(  'ASIENTO' 	, MODEL_FIELD_INIT, {|| 2 })
	oStruFJT:SetProperty(  'AGRUPA' 	, MODEL_FIELD_INIT, {|| 2 })
	oStruFJT:SetProperty(  'ONLINE' 	, MODEL_FIELD_INIT, {|| 2 })
	oStruFJT:SetProperty(  'RAGENER' 	, MODEL_FIELD_INIT, {|| SuperGetMv("MV_RAGENER",.F.,.T.) })
	oStruFJT:SetProperty(  'IMPRIMIR' 	, MODEL_FIELD_INIT, {|| .F. })
	oStruFJT:SetProperty(  'EMAIL' 		, MODEL_FIELD_INIT, {|| .F. })

	// Indica que es opcional tener datos informados en el grid
	oModel:GetModel( 'SEL_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'SE1_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'MOE_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'GEN_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'ADM_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'FAC_DETAIL' ):SetOptional(.T.)

	//Define que el submodelo permitirá la edición de datos.

	//Indica No grabar datos de un componente del modelo de datos
	oModel:GetModel('SE1_DETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('MOE_DETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('GEN_DETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('ADM_DETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('FAC_DETAIL'):SetOnlyQuery(.T.)
	

	oModel:SetPrimaryKey({'FJT_RECIBO','FJT_SERIE'})
	
	//Evento de actualizaciones financieras
	oModel:InstallEvent("F887FIN"	,/*cOwner*/,oEvtTit)
	 //Evento de lanzamientos contables
	oModel:InstallEvent("F887CTB"	,/*cOwner*/,oEvtCtb)	

	//Descripciones - Se quedan comentadas para no generar errores sin la view en uso.
	//oModel:SetDescription(STR0098)
	//oModel:GetModel('FJT_MASTER'):SetDescription(STR0099)
	//oModel:GetModel('SE1_DETAIL'):SetDescription(STR0100)
	//oModel:GetModel('SEL_DETAIL'):SetDescription(STR0101)
	
Return oModel

/*/{Protheus.doc} ViewDef
Interfce del modelo de datos de Cobros Diversos para localización padrón
@return		oView objeto del View
@author 	raul.medina
@since 		05/04/2021
@version	12.1.27 / Superior
/*/
Static Function ViewDef()
Local cCampSE1	:= "E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,E1_SALDO,E1_DESCONT,E1_MULTA,E1_JUROS,E1_MOEDA,E1_CANCEL,E1_NATUREZ,E1_MOTIVO"
Local cCampSEL	:= "EL_FILIAL,EL_RECIBO,EL_CLIORIG,EL_LOJORIG,EL_NATUREZ"
Local cCampFJT	:= "FJT_SERIE,FJT_RECIBO,FJT_EMISSA,FJT_CLIENT,FJT_LOJA,FJT_NOME,FJT_NATURE"
Local oStruFJT	:= FWFormStruct( 2, 'FJT', { | cCampo | AllTrim( cCampo ) $ cCampFJT }, .F.)
Local oStruSEL	:= FWFormStruct( 2, 'SEL', { | cCampo | !(AllTrim( cCampo ) $ cCampSEL) }, .F.)
Local oStruSE1 	:= FWFormStruct( 2, 'SE1', { | cCampo | AllTrim( cCampo ) $ cCampSE1  }, .F.)
Local oModel	:= FWLoadModel('FINA887')
Local oStruMOE	:= FWFormViewStruct():New()
Local oView		:= FWFormView():New()

	//Tabla de saldos y monedas
	oStruMOE:AddField('MOEDA' 	, '1',  STR0103	, STR0103	, NIL, 'GET', , , , .F.)
	oStruMOE:AddField('TASA' 	, '2',  STR0104	, STR0104	, NIL, 'GET', , , , .F.)
	oStruMOE:AddField('RECIBIDO', '3',  STR0105 , STR0105	, NIL, 'GET', , , , .F.)
	oStruMOE:AddField('SALDO' 	, '4',  STR0106	, STR0106	, NIL, 'GET', , , , .F.)

	oStruSE1:AddField('CHECK'	, '1',  ''	, '', NIL, 'CHECK')

	oStruSE1:SetProperty("CHECK", MVC_VIEW_ORDEM, "01")

	oStruFJT:SetProperty( '*', 	MVC_VIEW_FOLDER_NUMBER, '')
	oStruFJT:SetProperty( '*', 	MVC_VIEW_GROUP_NUMBER , '')

	oStruFJT:aFolders := {}
	oStruFJT:aGroups := {}
	
	oView:SetModel(oModel)

	//Define que a tela sera um formulario continuo
	//oView:SetContinuousForm(.T.)

	oView:AddField('oStruFJT' , oStruFJT, 'FJT_MASTER' )
	oView:AddGrid('oStruSEL'  , oStruSEL, 'SEL_DETAIL')
	oView:AddGrid('oStruSE1'  , oStruSE1, 'SE1_DETAIL')
	oView:AddGrid('oStruMOE'  , oStruMOE, 'MOE_DETAIL')
	
	//Divisiones horizontales
	oView:CreateHorizontalBox( 'CIMA' , 25)
	oView:CreateHorizontalBox( 'MEDIO', 30)
	oView:CreateHorizontalBox( 'BAIXO', 30)
	oView:CreateHorizontalBox( 'RODAPE', 15)
	
	oView:CreateVerticalBox( 'SALDO', 50 ,'RODAPE' )
	oView:CreateVerticalBox( 'CHECK', 50 ,'RODAPE' )

	oView:CreateVerticalBox( 'SAL', 100 ,'SALDO' )

	oView:AddOtherObject("CHECK_PANEL", {|oPanel| TCheckBox(oPanel) })
	oView:SetOwnerView('CHECK_PANEL','CHECK')
	
	oView:SetOwnerView('oStruFJT', 'CIMA')
	oView:SetOwnerView('oStruSE1', 'MEDIO')
	oView:SetOwnerView('oStruSEL', 'BAIXO')
	oView:SetOwnerView('oStruMOE', 'SAL')

	//Habilitando título
	oView:EnableTitleView('oStruFJT',STR0099)
	oView:EnableTitleView('oStruSE1',STR0100)
	oView:EnableTitleView('oStruSEL',STR0101)
	oView:EnableTitleView('oStruMOE',STR0102)

	oView:SetOnlyView('oStruFJT')
	oView:SetOnlyView('oStruSE1')
	oView:SetOnlyView('oStruSEL')
	oView:SetOnlyView('oStruMOE')
	
Return oView

/*/{Protheus.doc} F887LOJA
Función para validación de Loja
@param		oModel - Objeto del modelo
@return		lRet -  Resultado de la validación
@author 	raul.medina
@version	12.1.27 / Superior
@since 		07/04/2027
/*/
Static Function F887LOJA(oModel)
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local cCliente	:= oModelSEL:GetValue("EL_CLIENTE")
Local cLoja		:= oModelSEL:GetValue("EL_LOJA")

	lRet := ExistCpo("SA1",cCliente+cLoja,1)
	
Return lRet 

/*/{Protheus.doc} F887LOJORI
Función para validación de Loja
@param		oModel - Objeto del modelo
@return		lRet -  Resultado de la validación
@author 	raul.medina
@version	12.1.27 / Superior
@since 		07/04/2027
/*/
Static Function F887LOJORI(oModel)
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local cCliente	:= oModelSEL:GetValue("EL_CLIORIG")
Local cLoja		:= oModelSEL:GetValue("EL_LOJORIG")

	lRet := ExistCpo("SA1",cCliente+cLoja,1)
	
Return lRet


/*/{Protheus.doc} FA887VALTP
Función para validación de uso de tipo de documento
@param		oModel - Objeto del modelo
@return		lRet -  Resultado de la validación
@author 	raul.medina
@version	12.1.27 / Superior
@since 		07/04/2027
/*/
Function FA887VALTP(oModel, lValid)
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local aArea		:= {}
Local cConteudo	:= ""
Local aCheque	:= {}
	
IF lValid
	If AliasInDic("FJS")
		cConteudo	:= oModelSEL:GetValue("EL_TIPO")
		aArea := FJS->(GetArea())
		DbSelectArea("FJS")
		FJS->(DbSetOrder(1)) //FJS_FILIAL+FJS_TIPO
		If FJS->(DbSeek(xFilial("FJS")+PadR(cConteudo,GetSx3Cache("FJS_TIPO","X3_TAMANHO"))))  
			If !((ALLTRIM(FJS->FJS_BLOQ) == "2") .and. (ALLTRIM(FJS->FJS_CARTE) $ "1|3")) 
				lRet := .F.
				Help( " ", 1, "FANOTOPODOC",,STR0043,1,0)//"Não é possível utilizar este tipo de documento"
			EndIf
		Else
			lRet := .F.
			Help( " ", 1, "FANOTOPODOC",,STR0043,1,0)//"Não é possível utilizar este tipo de documento"	
		EndIf
		If lRet
			If aScan(oModelSEL:aHeader, {|cpo| AllTrim(cpo[2]) == "EL_ENDOSSA"}) > 0
				If FJS->FJS_CARTE $ "13" .AND. !SEL->(ColumnPos("EL_DOCPOS")) >0 
					oModelSEL:SetValue("EL_ENDOSSA","2")
				EndIf
			EndIf
			If aScan(oModelSEL:aHeader, {|cpo| AllTrim(cpo[2]) == "EL_TERCEIR"}) > 0
				If FJS->FJS_CARTE $ "13" .AND. !SEL->(ColumnPos("EL_DOCPOS")) >0 
					oModelSEL:SetValue("EL_TERCEIR","1")
				EndIf
			EndIf
			If aScan(oModelSEL:aHeader, {|cpo| AllTrim(cpo[2]) == "EL_TRANSIT"}) > 0
				oModelSEL:SetValue("EL_TRANSIT",FJS->FJS_TRANS)
			EndIf
		EndIf
		FJS->(RestArea(aArea))
	EndIf
ENDIF

Return lRet

/*/{Protheus.doc} F887BCO
Función para validación de uso de tipo de documento
@param		oModel - Objeto del modelo
			lNoValid - Indica si debe realizar la validación (Uso para Argentina)
@return		lRet -  Resultado de la validación
@author 	raul.medina
@version	12.1.27 / Superior
@since 		07/04/2027
/*/

Function F887BCO(cCampo, lNoValid)
Local oModel 		:= FWModelActive()
Local oModelSEL 	:= oModel:GetModel( 'SEL_DETAIL' )
//--- Retorno
Local lRet := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 29/08/2012 : O campo Banco cheque eh comum para 2 rotinas, ³
	//³                                                            ³
	//³ Fina087a -> NAO deve efetuar a validacao chamado a tabela  ³
	//³             de Entidades bancarias                         ³
	//³ Fina840 -> sim, deve chamar a tabela Entidades bancarias   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	
Local xConten := oModelSEL:GetValue(cCampo)
	
Default lNoValid := .F.
	
	If lNoValid
		//--- Se existir conteudo informado manualmente no campo EL_BCOCHQ
		If !Empty( xConten )
			aArea:=GetArea()       
       		If Empty( oModelSEL:GetValue("EL_AGECHQ") ) .OR. Empty( oModelSEL:GetValue("EL_POSTAL") ) .OR. oModelSEL:GetValue("EL_AGECHQ") <> FJN->FJN_AGENCI .OR. oModelSEL:GetValue("EL_POSTAL")  <> FJN->FJN_POSTAL
        		lRet := .F.
				oModel:SetErrorMessage('', '' , '' , '' , '', '', OemToAnsi( STR0047 )) // "Por favor, use a consulta padrão, de forma a preencher os campos de <Agencia> e <Codigo Postal>."  
			EndIf
		RestArea(aArea)
		EndIf
	EndIf 

Return( lRet )

/*/{Protheus.doc} F887AWHEN
Validaciones correspondientes a campos

@type 		Method


@author 	raul.medina
@version	12.1.27 / Superior
@since		23/05/2021 
/*/
Function F887aWhen(cCampo)
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
Local cTipoCr	:= oModelSEL:GetValue("EL_TPCRED")
Local cCredInm	:= GetSESTipos({|| ES_RCOPGER == "1"},"1")

	cCredInm	:= IIf(Empty(cCredInm),"TF /EF /CC /CD ",cCredInm)
	
If cCampo == "TPCRED"
	If cTipoDoc $ cCredInm
		//Inmediato
		oModelSEL:LoadValue("EL_TPCRED","1")
	Else
		If cTipoDoc == "CHF"
			//Acreditación
			oModelSEL:LoadValue("EL_TPCRED","3")
		ELSEIF cTipoDoc == "DC"
			oModelSEL:LoadValue("EL_TPCRED","")
		ELSE
			//Fiscal
			oModelSEL:LoadValue("EL_TPCRED","4")
		EndIf
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} F887MOE
Validaciones de moneda (EL_MOEDA) al agregar una forma de pago
@type function
@version  1
@author luis.aboytes
@since 1/11/2022
/*/
Function F887MOE(oModel)
	Local oModel 		:= FWModelActive()
	Local lValid 		:= .T. 	As Logical 
	Local nLine			:= 0 	As Numeric
	Local aMoedas		:= {}	As Array
	local nMoeda 		:= 0
	Local nline2		:= 0
	Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
	Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')

    For nLine := 1 To oModelMOE:Length()
        AADD(aMoedas,{oModelMOE:GetValue('MOEDA',nLine), oModelMOE:GetValue('TASA',nLine)})
	Next nLine	
	 
		For nline2 := 1 To oModelSEL:Length()
		IF lValid
			nMoeda := AScan(aMoedas,{|x|x[1] == ALLTRIM(oModelSEL:GetValue('EL_MOEDA',nline2))})
			IF nMoeda == 0 .OR. !(aMoedas[nMoeda][2] > 0) 
			oModel:SetErrorMessage('SEL_DETAIL', '' , 'MOE_DETAIL' , '' , STR0050, '', STR0016) //Informe todas las tasas de las monedas que se utilizaron en los documentos.			
			lValid := .F.
			EndIF
		EndIf
	Next nline2
    
Return lValid

/*/{Protheus.doc} F887DIACTB
Función para validación del uso del campo Codigo Diario. 
@param		oModel - Objeto del modelo
@return		lRet -  Resultado de la validación
@author 	Luis Gerardo Cabrera Mata
@version	12.1.27 / Superior
@since 		08/12/2022
/*/
Static Function F887DIACTB(oModel)
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local cCodDia	:= oModelSEL:GetValue("EL_DIACTB")
Local cSegOfi   := SuperGetMv("MV_SEGOFI",.T.,0)

	IF ( cSegOfi$("5|8")  ) .Or. (cSegOfi == "7" .And. cPaisloc == "PER" ) 
		oModelSEL:LoadValue("EL_DIACTB",cCodDia)
	End
		
Return lRet

/*/{Protheus.doc} TCheckBox
Creación de opciones para grabado del recibo.
@param		oPanel - Objeto para los checkbox
@return		
@author 	Raul Ortiz
@version	12.1.2210 / Superior
@since 		25/01/2023
/*/
Static Function TCheckBox(oPanel)
Local oCheckEnv	As Object
Local oCheckImp	As Object
Local oFont		As Object
Local lCheckEnv As logical
Local lCheckImp As logical

	oFont := TFont():New( 'Courier New', , -18, .T., .T.)
	
	lCheckEnv := .F.
	lCheckImp := .F.
	@020, 025 CHECKBOX oCheckEnv VAR lCheckEnv Size 100, 050 FONT oFont PROMPT STR0092 	ON Change(F887ChkEnv(lCheckEnv)) Of oPanel	//"Enviar"
	@040, 025 CHECKBOX oCheckImp VAR lCheckImp Size 100, 050 FONT oFont PROMPT STR0091	ON Change(F887ChkImp(lCheckImp)) Of oPanel	//"Imprimir"

Return

/*/{Protheus.doc} TCheckBox
Creación de opciones para grabado del recibo.
@param		lCheckEnv - Indica si está marcado el checkbox de envio del recibo
@return		
@author 	Raul Ortiz
@version	12.1.2210 / Superior
@since 		25/01/2023
/*/
static function F887ChkEnv(lCheckEnv)

Return

/*/{Protheus.doc} TCheckBox
Creación de opciones para grabado del recibo.
@param		lCheckImp - Indica si está marcado el checkbox de impresion del recibo
@return		
@author 	Raul Ortiz
@version	12.1.2210 / Superior
@since 		25/01/2023
/*/
static function F887ChkImp(lCheckImp)

Return

/*/{Protheus.doc} CreateTrigger
función para la creación de triggers generica
@param		cdom 	- Indica el campo dominio
@param		ccontr 	- Indica el campo Contradominio
@param		cregla 	- Indica la relga del disparador
@param		cseq  	- Indica la secuencia
@return		
@author 	José González
@version	12.1.2210 / Superior
@since 		02/02/2023
/*/
Static Function CreateTrigger(cdom,ccontr,cregla,cseq)
Local aAux :=  {}
default cdom := ""
default ccontr := ""
default cregla := ""
default cseq := ""

aAux := FwStruTrigger(;
	cdom ,; // Campo Dominio
	ccontr ,; // Campo de Contradominio
	cregla,; // Regra de Preenchimento
	.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
	"" ,; // Alias da tabela a ser posicionada
	0 ,; // Ordem da tabela a ser posicionada
	"" ,; // Chave de busca da tabela a ser posicionada
	NIL ,; // Condicao para execucao do gatilho
	cseq ) // Sequencia do gatilho (usado para identificacao no caso de erro)

Return aAux

