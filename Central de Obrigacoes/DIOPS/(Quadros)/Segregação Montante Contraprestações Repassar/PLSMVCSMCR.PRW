#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'totvs.ch'
#INCLUDE "Fwlibversion.ch"
//M�tricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCSMCR

Manutencao de Segrega��o do Montante de Contrapresta��es a Repassar

@author Roger C
@since 05/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCSMCR()
	Local oBrowse	:= Nil
	Local lAuto     := Isblind()

	// Cria todos os registros, caso n�o existam.
	PLSCRISMCR(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_CODIGO,B3D->B3D_ANO)

	oBrowse:= FWmBrowse():New()
	oBrowse:SetAlias('BVS')
	oBrowse:SetDescription("DIOPS - Segrega��o do Montante de Contrapresta��es a Repassar")
	oBrowse:AddLegend( "BVS_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "BVS_STATUS=='2'", "GREEN",	"Valido" )
	oBrowse:AddLegend( "BVS_STATUS=='3'", "RED",	"Invalido" )
	oBrowse:SetFilterDefault( "BVS_FILIAL=B3D->B3D_FILIAL .And. BVS_CODOPE=B3D->B3D_CODOPE .And. BVS_CODOBR=B3D->B3D_CDOBRI .And. BVS_ANOCMP=B3D->B3D_ANO .And. BVS_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef( 'PLSMVCSMCR' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Segr. Mont. Contr. Repassar", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrowse:Activate()
	EndIf

Return( NIL )

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Definicao das opcoes do menu

@author Roger C
@since 05/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Private aRotina	:= {}
	aAdd( aRotina, { "Cr�ticas"        , 'PlCenFilCri("BVS", BVS->(Recno())) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Visualizar"	   , 'VIEWDEF.PLSMVCSMCR'	, 0 , 2 , 0 , NIL } ) //Visualizar c
	aAdd( aRotina, { "Alterar"		   , 'VIEWDEF.PLSMVCSMCR'	, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Imprimir Quadro" , 'PLSRDSMCR(.F.)'		, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Validar Quadro"  , 'CenVldQdMn("8")'		, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Pesquisar"	   , 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisarc
	aAdd( aRotina, { "Incluir"		   , 'VIEWDEF.PLSMVCSMCR'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Excluir"		   , 'VIEWDEF.PLSMVCSMCR'	, 0 , 5 , 0 , NIL } ) //Excluir

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela BVS
@return oModel	objeto model criado

@author Roger C
@since 05/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oStruBVS   := FWFormStruct( 1, 'BVS', , )
	Local oModel     := Nil
	Local bPosValida := { |oModel| preValidaDIOPS(oModel, 'BVSMASTER', 'BVS_CODOPE', 'BVS_CODOBR', 'BVS_CDCOMP', 'BVS_ANOCMP', 'BVS_REFERE', 'BVS_STATUS') }

	oModel := MPFormModel():New( "DIOPS - Segrega��o do Montante de Contrapresta��es a Repassar", /*bPreValidacao*/, bPosValida/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'BVSMASTER', , oStruBVS )
	oModel:GetModel( 'BVSMASTER' ):SetDescription( "DIOPS - Segrega��o do Montante de Contrapresta��es a Repassar" )

Return oModel

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela BVS

@return oView	objeto view criado

@author Roger C
@since 05/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FWLoadModel( 'PLSMVCSMCR' )
	Local oStruBVS := FWFormStruct( 2, 'BVS' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_BVS' , oStruBVS , 'BVSMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_BVS', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_BVS', 'DIOPS - Segrega��o do Montante de Contrapresta��es a Repassar' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRegSMCR

Retorna array de regras para validar o quadro Segrega��o do Montante de Contrapresta��es a Repassar

@author timoteo.bega
@since 05/03/2018
/*/
//--------------------------------------------------------------------------------------------------
function getRegSMCR()

	local aRegras := {}
	local aRegrasAll := {}
	local aRegrasBl := {}

	// Regras de Validacao Registro a Registro
	aAdd( aRegrasAll,{"SM01","   ","PLVLDMCR01()", "O codigo do tipo de D�bito de Opera��es de Administra��o de Benef�cios � inv�lido.", "Verifique o c�digo do tipo de D�bito de Opera��es de Administra��o de Benef�cios deste item.", ""} )

	// Compara Somat�rio dos registros com o total da Conta Cont�bil respectiva
	aAdd( aRegrasBl, {"SM02","   ","PLVLDMCR02()", "Somat�rio dos registros do trimestre n�o confere com o total das contas cont�beis.", "Verifique a somat�ria dos registros do trimestre e o valor contabilizado na conta 2136 - D�BITOS DE OPERA��ES DE ADMINISTRA��O DE BENEF�CIOS."," " } )

	aRegras := { getTabSMCR(), aRegrasAll, aRegrasBl }

Return aRegras

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabSMCR

Retorna tabela do quadro Segrega��o do Montante de Contrapresta��es a Repassar

@author Roger C
@since 05/03/2018
/*/
//--------------------------------------------------------------------------------------------------
function getTabSMCR()
return "BVS"