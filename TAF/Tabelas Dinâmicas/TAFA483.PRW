#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA483
Cadastro MVC de Obriga��es Fiscais

@author Jo�o Vitor Spieker
@since 28/09/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA483()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription("Obriga��es Fiscais")    //
oBrw:SetAlias( 'T85')
oBrw:SetMenuDef( 'TAFA483' )
T85->(DbSetOrder(2))
oBrw:Activate()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Jo�o Vitor Spieker
@since 28/09/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA483" ,,,,.T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC
@author Jo�o Vitor Spieker
@since 28/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT85  :=  FWFormStruct( 1, 'T85' )
Local oModel    :=  MPFormModel():New( 'TAFA483' )

oModel:AddFields('MODEL_T85', /*cOwner*/, oStruT85)
oModel:GetModel('MODEL_T85'):SetPrimaryKey({'T85_FILIAL','T85_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Jo�o Vitor Spieker
@since 28/09/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA483' )
Local   oStruT85    :=  FWFormStruct( 2, 'T85' )
Local   oView       :=  FWFormView():New()

oStruT85:RemoveField('T85_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_T85', oStruT85, 'MODEL_T85' )

oView:EnableTitleView( 'VIEW_T85', "Obriga��es Fiscais" )    //
oView:CreateHorizontalBox( 'FIELDST85', 100 )
oView:SetOwnerView( 'VIEW_T85', 'FIELDST85' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@author Jo�o Vitor Spieker
@since 28/09/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1019

If nVerEmp < nVerAtu
	aAdd( aHeader, "T85_FILIAL" )
	aAdd( aHeader, "T85_ID" )
	aAdd( aHeader, "T85_CODIGO" )
	aAdd( aHeader, "T85_CODSEC" )
	aAdd( aHeader, "T85_DESCRI" )
	
	aAdd( aBody, { "", "bf49eff7-2d2c-2173-99d1-b4486db919d0", "00", "2.0", "Cancelada" } )
	aAdd( aBody, { "", "d7084b7b-0deb-5630-c585-2fa23b2cec91", "01", "2.1", "Exig�vel" } )
	aAdd( aBody, { "", "0205bc5c-92c5-1f5a-2535-5b02d9441cd8", "02", "2.2", "Exporta��o" } )
	aAdd( aBody, { "", "9eee59ae-e374-b520-6135-06239bc5feb6", "03", "2.3", "Imunidade Tribut�ria" } )
	aAdd( aBody, { "", "5fced6a6-c074-ff60-600d-e022c2fe7f32", "04", "2.4", "Isenta do ISS em BH" } )
	aAdd( aBody, { "", "80c25533-fee8-34b1-bc95-5b300ea317dd", "05", "2.5", "Exigibilidade Suspensa por Decis�o Jucidial" } )
	aAdd( aBody, { "", "e06b46b6-dbba-a171-4ef0-3eb26899c79c", "06", "2.6", "N�o Incid�ncia" } )
	aAdd( aBody, { "", "fffd12fd-735b-1d98-91c4-7b335601e77e", "07", "2.7", "Vendas/Transporte Intermunicipal" } )


	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )

