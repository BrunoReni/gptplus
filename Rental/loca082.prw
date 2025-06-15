#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "LOCA082.CH"

/*/{Protheus.doc} LOCA082.PRW
ITUP Business - TOTVS RENTAL
Pedido de Venda x Loca��o 

@type Function
@author Jos� Eul�lio
@since 16/08/2022
@version P12

/*/
Function LOCA082 
Local oBrowse

	aRotina := MenuDef() 					   
	oBrowse := FwmBrowse():NEW() 			   
	oBrowse:SetAlias("FPY")					   
	oBrowse:SetDescription(STR0001) //'Status do Equipamento x Contrato Rental'
	oBrowse:Activate() 						   

Return( NIL )
//---------------------------------------------------------------------------------------------

Static Function MenuDef()

Local aBotao := {}

ADD OPTION aBotao Title 'Visualizar' 	Action 'VIEWDEF.LOCA082' OPERATION 2 ACCESS 0
//ADD OPTION aBotao Title 'Incluir' 		Action 'VIEWDEF.LOCA081' OPERATION 3 ACCESS 0
//ADD OPTION aBotao Title 'Alterar' 	Action 'VIEWDEF.LOCA081' OPERATION 4 ACCESS 0
//ADD OPTION aBotao Title 'Excluir' 	Action 'VIEWDEF.LOCA081' OPERATION 5 ACCESS 0
ADD OPTION aBotao Title 'Imprimir' 		Action 'VIEWDEF.LOCA082' OPERATION 8 ACCESS 0
	
Return aBotao

// Prepara�ao do modelo de dados
Static Function ModelDef()
Local oModel
Local oModFPZ
Local oStrFPY:= FWFormStruct(1,'FPY')	
Local oStrFPZ:= FWFormStruct(1,'FPZ')	
oModel := MPFormModel():New('MODELFPY') 
oModel:addFields('FPYMASTER',,oStrFPY)    
oModel:addGrid('FPZDETAIL','FPYMASTER',oStrFPZ)
oModel:SetDescription(STR0001)  //'Status do Equipamento x Contrato Rental'
oModel:getModel('FPYMASTER'):SetDescription(STR0001) //'Status do Equipamento x Contrato Rental'	
oModFPZ := oModel:GetModel('FPZDETAIL')
//oModFPZ:SetNoInsertLine(.T.)
//oModFPZ:SetNoUpdateLine(.T.)
//oModFPZ:SetNoDeleteLine(.T.)
oModel:SetRelation('FPZDETAIL', { { 'FPZ_FILIAL', "xFilial('SC5')" }, { 'FPZ_PEDVEN', 'FPY_PEDVEN' }, { 'FPZ_PROJET', 'FPY_PROJET' } }, FPZ->(IndexKey(1)) )
oModel:SetPrimaryKey({ 'FPY_FILIAL','FPY_PEDVEN','FPY_PROJET' })
oModel:SetPrimaryKey({ 'FPZ_FILIAL','FPZ_PEDVEN','FPZ_PROJET','FPZ_ITEM' })
Return oModel

//-------------------------------------------------------------------
// Montagem da interface
Static Function ViewDef()
Local oView
Local oModel := ModelDef()		
Local oStrFPY:= FWFormStruct(2, 'FPY')    
Local oStrFPZ:= FWFormStruct(2, 'FPZ' , { |x| !(ALLTRIM(x) $ 'FPZ_PEDVEN|FPZ_PROJET') } )    
oView := FWFormView():New()		
oView:SetModel(oModel)			 
oView:AddField('VIEWFPY' , oStrFPY,'FPYMASTER' )  
oView:AddGrid('VIEWFPZ'  , oStrFPZ,'FPZDETAIL' )
oView:CreateHorizontalBox( 'TELA', 30)			
oView:CreateHorizontalBox( 'GRID', 70)			
oView:SetOwnerView('VIEWFPY','TELA')
oView:SetOwnerView('VIEWFPZ','GRID')
Return oView

/*/{Protheus.doc} LOCxPed
ITUP Business - TOTVS RENTAL
ExecView da Rotina

@type Function
@author Jos� Eul�lio
@since 09/08/2022
@version P12

/*/
Function LOCA0821(cNumPed)
Local cStatus	:= ""
Local nOperLoc	:= MODEL_OPERATION_VIEW
Local aAreaFPY	:= FPY->(GetArea())
Local aButtons	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.F.,Nil},{.T.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}} 

Default cNumPed	:= ""

If !Empty(cNumPed)
	FPY->(DbSetOrder(1)) //
	If FPY->(DbSeek(xFilial("FPY") + cNumPed))
		/*If ALTERA
			nOperLoc	:= MODEL_OPERATION_UPDATE
		EndIf*/
		FWExecView(STR0001,'LOCA082', nOperLoc	, , { || .T. }, ,70 ,aButtons ) 
	EndIf
EndIf

//restaura a �rea e limpa array
RestArea(aAreaFPY)
aSize(aAreaFPY,0)

Return cStatus

/*/{Protheus.doc} LOCxPed
ITUP Business - TOTVS RENTAL
Rotina autom�tica

@type Function
@author Jos� Eul�lio
@since 09/08/2022
@version P12

/*/
Function LOCA0822(aCab,aItens,nOperLoc)
Local nX		:= 0
Local nY		:= 0
Local oModel 	:= Nil
Local oModelFPZ	:= Nil

Default nOperLoc	:= MODEL_OPERATION_INSERT

Private lMsErroAuto := .F.

oModel := FwLoadModel ("LOCA082")
oModel:SetOperation(nOperLoc)
oModel:Activate()
oModelFPZ := oModel:GetModel("FPZDETAIL")

//prepara cabe�alho
For nX := 1 To Len(aCab)
	oModel:SetValue("FPYMASTER", aCab[nX][1] , aCab[nX][2])
Next nX

//prepara itens
For nX := 1 To Len(aItens)
	oModelFPZ:AddLine()
	For nY := 1 To Len(aItens[nX])
		xxx := oModelFPZ:SetValue(aItens[nX][ny][1] , aItens[nX][ny][2])
	Next nY
Next nX

//valida e grava modelo
If oModel:VldData()
	oModel:CommitData()
	//MsgInfo("Registro INCLUIDO!", "Aten��o")
Else
	VarInfo("",oModel:GetErrorMessage())
EndIf

oModel:DeActivate()
oModel:Destroy()
oModel := NIL

Return


