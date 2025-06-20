#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA032.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA032
Cadastro de Modalidades de Frete

@author Marcio Nunes
@since 12/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA032()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Modalidades de Frete
oBrw:SetAlias( 'C0X')
oBrw:SetMenuDef( 'TAFA032' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcio Nunes
@since 05/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA032" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 11/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC0X 	:= 	FWFormStruct( 1, 'C0X' )
Local oModel 	:= 	MPFormModel():New( 'TAFA032' )

oModel:AddFields('MODEL_C0X', /*cOwner*/, oStruC0X)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcio Nunes
@since 11/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA032' )
Local 	oStruC0X 	:= 	FWFormStruct( 2, 'C0X' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0X', oStruC0X, 'MODEL_C0X' )

oView:EnableTitleView( 'VIEW_C0X', STR0001 ) //Cadastro de Modalidades de Frete
oView:CreateHorizontalBox( 'FIELDSC0X', 100 )
oView:SetOwnerView( 'VIEW_C0X', 'FIELDSC0X' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1019

If nVerEmp < nVerAtu
	aAdd( aHeader, "C0X_FILIAL" )
	aAdd( aHeader, "C0X_ID" )
	aAdd( aHeader, "C0X_CODIGO" )
	aAdd( aHeader, "C0X_DESCRI" )
	aAdd( aHeader, "C0X_VALIDA" )

	aAdd( aBody, { "", "000001", "0", "CONTRATA��O DO FRETE POR CONTA DO REMETENTE", "" } )
	aAdd( aBody, { "", "000002", "1", "CONTRATA��O DO FRETE POR CONTA DO DESTINAT�RIO", "" } )
	aAdd( aBody, { "", "000003", "2", "CONTRATA��O DO FRETE POR CONTA DE TERCEIROS", "" } )
	aAdd( aBody, { "", "000005", "3", "TRANSPORTE PR�PRIO POR CONTA DO REMETENTE", "" } )
	aAdd( aBody, { "", "000006", "4", "TRANSPORTE PR�PRIO POR CONTA DO DESTINAT�RIO", "" } )
	aAdd( aBody, { "", "000004", "9", "SEM OCORR�NCIA DE TRANSPORTE", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )