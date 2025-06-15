#Include "TOTVS.ch"
#Include "FWMVCDef.ch"
#Include "VEIC170.ch"
 
/*/
{Protheus.doc} VEIC170
Rotina MVC para VV0 e VVA
@type   Function
@author Jose L. S. Filho
@since  27/03/2023
@param  nil
@return nil
/*/
Function VEIC170(cFilVV0 , cNumtra)

Local oBrowse 
Local oExecView
Local aArea

Default cFilVV0 := ""
Default cNumtra := ""

If Empty( cFilVV0 + cNumtra )
    aArea := VV0->(GetArea())
    DbSelectArea("VV0")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("VV0")
    oBrowse:SetDescription(STR0001)	// Consulta Movimenta��es de Saida
    oBrowse:Activate()
    oBrowse:SetInsert(.f.)
    RestArea(aArea)
Else
    DbSelectArea("VV0")
    DbSetOrder(1)
    If DbSeek( cFilVV0 + cNumtra )
        oExecView := FWViewExec():New()
        oExecView:SetTitle(STR0001) // Consulta Movimenta��es de Saida
        oExecView:SetSource("VEIC170")
        oExecView:SetOperation(MODEL_OPERATION_VIEW)
        oExecView:OpenView(.T.)
    Endif
Endif

Return Nil 
/*/
{Protheus.doc} MenuDef
Fun��o padr�o do MVC respons�vel pela defini��o das op��es de menu do Browse do fonte VEIC170 que estar�o dispon�veis ao usu�rio.
@type   Static Function
@author Jose L. S. Filho
@since  27/03/2023
@param  nil
@return aRot,   Matriz, Matriz que cont�m as op��es de menu a serem utilizadas pelo usu�rio.
/*/
Static Function MenuDef()
    
Local aRot
    
aRot := {}
ADD OPTION aRot TITLE STR0004 ACTION 'VIEWDEF.VEIC170' OPERATION 2 ACCESS 0 // Visualizar
 
Return aRot

/*/
{Protheus.doc} ModelDef
Fun��o padr�o do MVC respons�vel pela cria��o do modelo de dados (regras de neg�cio) para a rotina VEIC170.
@type   Static Function
@author Jose L. S. Filho
@since  27/03/2023
@param  nil
@return oModel, Objeto, Objeto que cont�m o modeldef.
/*/
Static Function ModelDef()
Local oModel
Local oStPaiVV0
Local oStFilhoVVA
local aVVARel := {}

oModel              := Nil
oStPaiVV0           := FWFormStruct(1, "VV0")
oStFilhoVVA         := FWFormStruct(1, "VVA")

//Criando o modelo e os relacionamentos
oModel := MPFormModel():New("VEIC170")
oModel:AddFields("VV0MASTER",/*cOwner*/,oStPaiVV0)
oModel:AddGrid("VVADETAIL","VV0MASTER",oStFilhoVVA,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner � para quem pertence

//Fazendo o relacionamento entre o Pai e Filho
aAdd(aVVARel, {"VVA_FILIAL","VV0_FILIAL"} )
aAdd(aVVARel, {"VVA_NUMTRA","VV0_NUMTRA"} )
 
oModel:SetRelation("VVADETAIL", aVVARel, VVA->(IndexKey(1))) //IndexKey -> quero a ordena��o e depois filtrado
 
//Setando as descri��es
oModel:SetDescription(STR0001)	// Consulta Movimenta��es de Saida
oModel:GetModel("VV0MASTER"):SetDescription(STR0002)	// Cabe�alho das Movimenta��es de Saida
oModel:GetModel("VVADETAIL"):SetDescription(STR0003)	// Itens da Saida

oStFilhoVVA:RemoveField("VVA_OBSERV") 
oStFilhoVVA:RemoveField("VVA_OBSMEM") 

Return oModel

/*/
{Protheus.doc} 
ViewDef
Fun��o padr�o do MVC respons�vel pela cria��o da vis�o de dados (intera��o do usu�rio) para a rotina VEIC170.
@type   Static Function
@author Jose L. S. Filho
@since  27/03/2023
@param  nil
@return oView, Objeto, Objeto que cont�m o viewdef.
/*/
Static Function ViewDef()
Local oView
Local oModel
Local oStPaiVV0
Local oStFilhoVVA

oView       := Nil
oModel      := FWLoadModel("VEIC170")
oStPaiVV0   := FWFormStruct(2, "VV0")
oStFilhoVVA := FWFormStruct(2, "VVA")

//Criando a View
oView := FWFormView():New()
oView:SetModel(oModel)
 
//Adicionando os campos do cabe�alho e o grid dos filhos
oView:AddField('VIEW_VV0'   ,oStPaiVV0  ,'VV0MASTER')
oView:AddGrid('VIEW_VVA'    ,oStFilhoVVA,'VVADETAIL')
 
//Setando o dimensionamento de tamanho das box
oView:CreateHorizontalBox('CABEC',60)
oView:CreateHorizontalBox('GRID',40)
 
//Amarrando a view com as box
oView:SetOwnerView('VIEW_VV0','CABEC')
oView:SetOwnerView('VIEW_VVA','GRID')
 
//Habilitando t�tulo
oView:EnableTitleView('VIEW_VV0',STR0002)	// Cabe�alho das Movimenta��es de Saida
oView:EnableTitleView('VIEW_VVA',STR0003)	// Itens da Saida

//Incremento
oView:AddIncrementField("VIEW_VVA", "VVA_CODSEQ")
oStFilhoVVA:RemoveField("VVA_OBSERV")
oStFilhoVVA:RemoveField("VVA_OBSMEM")

//For�a o fechamento da janela na confirma��o
oView:SetCloseOnOk({||.T.})
         
Return oView
