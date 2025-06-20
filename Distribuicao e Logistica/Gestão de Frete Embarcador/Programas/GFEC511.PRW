#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
//-------------------------------------------------------------------
//Inclus�o P�tios 12.1.4
/*/{Protheus.doc} GFEC511
Painel de Ve�culos
Generico

@sample
GFEC511()

@author Helder Fuckner dos Santos
@since 01/04/14
@version 1.0                                                                                      
/*/
//------------------------------------------------------------------------------------------------
Function GFEC511()                                                                                                       
	Private oBrowse511

	oBrowse511 := FWMBrowse():New()
	oBrowse511:SetAlias("GU8")							// Alias da tabela utilizada
	oBrowse511:SetMenuDef("GFEC511")			      	// Nome do fonte onde esta a fun��o MenuDef
	oBrowse511:SetDescription("Painel de Ve�culos") 	// Descri��o do browse   
	oBrowse511:SetWalkthru(.F.)
	oBrowse511:SetAmbiente(.F.)
	oBrowse511:DisableDetails()
	oBrowse511:Activate()
Return Nil

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Par�metros"    		ACTION "InfParC511()"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Movimenta��o"    	ACTION "GFEC511OPC()"	OPERATION 4 ACCESS 0 
	ADD OPTION aRotina TITLE "Consultar Ve�culo" 	ACTION "VIEWDEF.GFEA046"	OPERATION 2 ACCESS 0 //"Consultar Ve�culo"
Return aRotina

Function InfParC511()
	If Pergunte('GFEC511')
		If AllTrim(MV_PAR06) == ""
			oBrowse511:SetFilterDefault("")
		Else
			oBrowse511:SetFilterDefault("GU8->GU8_CDVEIC == MV_PAR06")
		EndIf
		
		oBrowse511:Refresh()
	EndIf
Return 

//Op��es das A��es Relacionadas
Function GFEC511OPC()
	Local aParam := {}
	Private dDataNeg := Date()
	
	Pergunte('GFEC511',.F.)
	
	aADD(aParam,MV_PAR01)	// Filial de
	aADD(aParam,MV_PAR02)	// Filial ate
	aADD(aParam,MV_PAR03)	// Data de
	aADD(aParam,MV_PAR04)	// Data ate
	aADD(aParam,MV_PAR05)	// Emitente (Transportador) TAMANHO = 14

	GFEC511A(aParam)

Return