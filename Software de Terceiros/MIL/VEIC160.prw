#Include "TOTVS.ch"
#Include "FWMVCDef.ch"
#Include "VEIC160.ch"
 
/*/
{Protheus.doc} VEIC160
Rotina MVC para VVF e VVG
@type   Function
@author Jose L. S. Filho
@since  27/03/2023
@param  nil
@return nil
/*/
Function VEIC160(cFilVVF , cTracpa)

Local oBrowse 
Local oExecView
Local aArea

Default cFilVVF := ""
Default cTracpa := ""

If Empty( cFilVVF + cTracpa )
    aArea := VVF->(GetArea())
    DbSelectArea("VVF")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("VVF")
    oBrowse:SetDescription(STR0001)	// Consulta Movimenta��es de Entrada
    oBrowse:Activate()
    oBrowse:SetInsert(.f.)
    RestArea(aArea)
Else
    DbSelectArea("VVF")
    DbSetOrder(1)
    If DbSeek( cFilVVF + cTracpa )
        oExecView := FWViewExec():New()
        oExecView:SetTitle(STR0001) // Consulta Movimenta��es de Entrada        
        oExecView:SetSource("VEIC160")
        oExecView:SetOperation(MODEL_OPERATION_VIEW)
        oExecView:OpenView(.T.)
    Endif
Endif

Return Nil
 
/*/
{Protheus.doc} MenuDef
Fun��o padr�o do MVC respons�vel pela defini��o das op��es de menu do Browse do fonte VEIC160 que estar�o dispon�veis ao usu�rio.
@type   Static Function
@author Jose L. S. Filho
@since  27/03/2023
@param  nil
@return aRot,   Matriz, Matriz que cont�m as op��es de menu a serem utilizadas pelo usu�rio.
/*/
Static Function MenuDef()
    
Local aRot
    
aRot := {}
ADD OPTION aRot TITLE STR0004 ACTION 'VIEWDEF.VEIC160' OPERATION 2 ACCESS 0 // Visualizar

Return aRot

/*/
{Protheus.doc} ModelDef
Fun��o padr�o do MVC respons�vel pela cria��o do modelo de dados (regras de neg�cio) para a rotina VEIC160.
@type   Static Function
@author Jose L. S. Filho
@since  28/03/2023
@param  nil
@return oModel, Objeto, Objeto que cont�m o modeldef.
/*/
Static Function ModelDef()

Local oModel
Local oStPaiVVF
Local oStFilhoVVG
local aVVGRel := {}

oModel              := Nil
oStPaiVVF           := FWFormStruct(1, "VVF")
oStFilhoVVG         := FWFormStruct(1, "VVG")

//Criando o modelo e os relacionamentos
oModel := MPFormModel():New("VEIC160")
oModel:AddFields("VVFMASTER",/*cOwner*/,oStPaiVVF)
oModel:AddGrid("VVGDETAIL","VVFMASTER",oStFilhoVVG,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner � para quem pertence
//Fazendo o relacionamento entre o Pai e Filho
aAdd(aVVGRel, {"VVG_FILIAL","VVF_FILIAL"} )
aAdd(aVVGRel, {"VVG_TRACPA","VVF_TRACPA"} )
 
oModel:SetRelation("VVGDETAIL", aVVGRel, VVG->(IndexKey(1))) //IndexKey -> quero a ordena��o e depois filtrado
 
//Setando as descri��es
oModel:SetDescription(STR0001)	// Consulta Movimenta��es de Entrada
oModel:GetModel("VVFMASTER"):SetDescription(STR0002)	// Cabe�alho das Movimenta��es de Entrada
oModel:GetModel("VVGDETAIL"):SetDescription(STR0003)	// Itens da Entrada

Return oModel

/*/
{Protheus.doc} ViewDef
Fun��o padr�o do MVC respons�vel pela cria��o da vis�o de dados (intera��o do usu�rio) para a rotina VEIC160.
@type   Static Function
@author Jose L. S. Filho
@since  27/03/2023
@param  nil
@return oView, Objeto, Objeto que cont�m o viewdef.
/*/
Static Function ViewDef()

Local oView
Local oModel
Local oStPaiVVF
Local oStFilhoVVG

oView       := Nil
oModel      := FWLoadModel("VEIC160")
oStPaiVVF   := FWFormStruct(2, "VVF")
oStFilhoVVG := FWFormStruct(2, "VVG")

//Criando a View
oView := FWFormView():New()
oView:SetModel(oModel)

//Adicionando os campos do cabe�alho e o grid dos filhos
oView:AddField('VIEW_VVF'   ,oStPaiVVF  ,'VVFMASTER')
oView:AddGrid('VIEW_VVG'    ,oStFilhoVVG,'VVGDETAIL')

//Setando o dimensionamento de tamanho das box
oView:CreateHorizontalBox('CABEC',60)
oView:CreateHorizontalBox('GRID',40)

//Amarrando a view com as box
oView:SetOwnerView('VIEW_VVF','CABEC')
oView:SetOwnerView('VIEW_VVG','GRID')

//Habilitando t�tulo
oView:EnableTitleView('VIEW_VVF',STR0002)	// Cabe�alho das Movimenta��es de Entrada
oView:EnableTitleView('VIEW_VVG',STR0003)	// Itens da Entrada

//Incremento
oView:AddIncrementField("VIEW_VVG", "VVG_CODSEQ")

//For�a o fechamento da janela na confirma��o
oView:SetCloseOnOk({||.T.})
         
Return oView
