#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA554
@type Function
@description Cadastro MVC Cadastro de Tipo de Valor de Apura��o

@author Ricardo Lovrenovic
@since 04/02/2020
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA554()
Local oBrw as object

oBrw	:= FWmBrowse():New()

oBrw:SetDescription( "Tipo de Valor Apura��o da Contribui��o Devida" )  
oBrw:SetAlias( 'V5L')
oBrw:SetMenuDef( 'TAFA554' )
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
@type Static function
@description Funcao generica MVC com as opcoes de menu

@author Ricardo Lovrenovic
@since 04/02/2020
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA554" )                                                                          

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
@type Static function
@description Funcao generica MVC do model

@author Ricardo Lovrenovic
@since 04/02/2020
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruV5L  as object 
Local oModel    as object

oStruV5L := FWFormStruct( 1, 'V5L' )// Cria a estrutura a ser usada no Modelo de Dados
oModel   := MPFormModel():New('TAFA554' )

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields( 'MODEL_V5L', /*cOwner*/, oStruV5L)
oModel:GetModel( 'MODEL_V5L' ):SetPrimaryKey( { 'V5L_FILIAL' , 'V5L_ID' } )

Return oModel             


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type Static Function
@description Funcao generica MVC do View

@author Ricardo Lovrenovic
@since 04/02/2020
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel	as object
Local oStruV5L	as object
Local oView		as object

oModel		:= FWLoadModel( 'TAFA554' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
oStruV5L	:= FWFormStruct( 2, 'V5L' )// Cria a estrutura a ser usada na View
oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_V5L', oStruV5L, 'MODEL_V5L' )

oView:EnableTitleView( 'VIEW_V5L',  "Tipo de Valor Apura��o da Contribui��o Devida" ) //Cadastro de C�digos da Receita

oView:CreateHorizontalBox( 'FIELDSV5L', 100 )

oView:SetOwnerView( 'VIEW_V5L', 'FIELDSV5L' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

@type Static Function
@description Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@Author	Ricardo Lovrenovic Bueno
@Since		04/02/2020
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp as numeric, nVerAtu as numeric)
Local aHeader as array
Local aBody	  as array
Local aRet	  as array

aHeader	:=	{}
aBody	:=	{}
aRet	:=	{}

nVerAtu := 1030.00

If nVerEmp < nVerAtu
	aAdd( aHeader, "V5L_FILIAL" )
	aAdd( aHeader, "V5L_ID" )
	aAdd( aHeader, "V5L_CODIGO" )
	aAdd( aHeader, "V5L_DESCRI" )
	aAdd( aHeader, "V5L_VALIDA" )

	aAdd( aBody, { "", "000001", "11", "BASE DE C�LCULO DA CONTRIBUI��O PREVIDENCI�RIA NORMAL", "" } )
	aAdd( aBody, { "", "000002", "12", "BASE DE C�LCULO DA CONTRIBUI��O PREVIDENCI�RIA ADICIONAL PARA O FINANCIAMENTO DOS BENEF�CIOS DE APOSENTADORIA ESPECIAL AP�S 15 ANOS DE CONTRIBUI��O", "" } )
	aAdd( aBody, { "", "000003", "13", "BASE DE C�LCULO DA CONTRIBUI��O PREVIDENCI�RIA ADICIONAL PARA O FINANCIAMENTO DOS BENEF�CIOS DE APOSENTADORIA ESPECIAL AP�S 20 ANOS DE CONTRIBUI��O", "" } )
	aAdd( aBody, { "", "000004", "14", "BASE DE C�LCULO DA CONTRIBUI��O PREVIDENCI�RIA ADICIONAL PARA O FINANCIAMENTO DOS BENEF�CIOS DE APOSENTADORIA ESPECIAL AP�S 25 ANOS DE CONTRIBUI��O", "" } )
	aAdd( aBody, { "", "000005", "15", "BASE DE C�LCULO DA CONTRIBUI��O PREVIDENCI�RIA EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000006", "16", "BASE DE C�LCULO DA CONTRIBUI��O PREVIDENCI�RIA ADICIONAL PARA O FINANCIAMENTO DOS BENEF�CIOS DE APOSENTADORIA ESPECIAL AP�S 15 ANOS DE CONTRIBUI��O - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000007", "17", "BASE DE C�LCULO DA CONTRIBUI��O PREVIDENCI�RIA ADICIONAL PARA O FINANCIAMENTO DOS BENEF�CIOS DE APOSENTADORIA ESPECIAL AP�S 20 ANOS DE CONTRIBUI��O - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000008", "18", "BASE DE C�LCULO DA CONTRIBUI��O PREVIDENCI�RIA ADICIONAL PARA O FINANCIAMENTO DOS BENEF�CIOS DE APOSENTADORIA ESPECIAL AP�S 25 ANOS DE CONTRIBUI��O - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000009", "19", "BASE DE C�LCULO DA CONTRIBUI��O PREVIDENCI�RIA EXCLUSIVA DO EMPREGADO", "" } )
	aAdd( aBody, { "", "000010", "21", "VALOR TOTAL DESCONTADO DO TRABALHADOR PARA RECOLHIMENTO � PREVID�NCIA SOCIAL", "" } )
	aAdd( aBody, { "", "000011", "22", "VALOR DESCONTADO DO TRABALHADOR PARA RECOLHIMENTO AO SEST", "" } )
	aAdd( aBody, { "", "000012", "23", "VALOR DESCONTADO DO TRABALHADOR PARA RECOLHIMENTO AO SENAT", "" } )
	aAdd( aBody, { "", "000013", "31", "VALOR PAGO AO TRABALHADOR A T�TULO DE SAL�RIO-FAM�LIA", "" } )
	aAdd( aBody, { "", "000014", "32", "VALOR PAGO AO TRABALHADOR A T�TULO DE SAL�RIO-MATERNIDADE", "" } )

	aAdd( aRet, { aHeader, aBody } )
	

EndIf



Return( aRet )