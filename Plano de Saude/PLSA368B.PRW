#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author Oscar Zanin
@since 23/09/2021
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA368B()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B8P')
oBrowse:SetDescription('Eventos Relacionados')
oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author Oscar Zanin
@since 23/09/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title  'Visualizar' Action 'VIEWDEF.PLSA368B' Operation 2 Access 0
Add Option aRotina Title  'Incluir'    Action 'VIEWDEF.PLSA368B' Operation 3 Access 0
Add Option aRotina Title  'Alterar'    Action 'VIEWDEF.PLSA368B' Operation 4 Access 0
Add Option aRotina Title  'Excluir'    Action 'VIEWDEF.PLSA368B' Operation 5 Access 0
Add Option aRotina Title  'Imprimir'   Action 'VIEWDEF.PLSA368B' Operation 8 Access 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author Oscar Zanin
@since 23/09/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB8P:= FWFormStruct(1,'B8P')

oModel := MPFormModel():New( 'PLSA368B', , { |oModel| PLS368BBok(@oModel)} )		//Cria a estrutura do Modelo de dados e Define e a fun��o que ir� Validar no "OK"

oStrB8P:setProperty('B8P_CODINT', MODEL_FIELD_INIT, {|| B8O->B8O_CODINT })
oStrB8P:setProperty('B8P_CODRDA', MODEL_FIELD_INIT, {|| B8O->B8O_CODRDA })
oStrB8P:setProperty('B8P_IDCOPR', MODEL_FIELD_INIT, {|| B8O->B8O_IDCOPR })
oStrB8P:setProperty('B8P_CODPAD', MODEL_FIELD_VALID, {|| PLB8PPRO(2) })
oStrB8P:setProperty('B8P_CODPRO', MODEL_FIELD_VALID, {|| PLB8PPRO(1) })

oModel:addFields('MasterB8P',/*cOwner*/,oStrB8P)								//Adiciona ao modelo um componente de formul�rio
//oModel:getModel('MasterB8P')
oModel:SetDescription('Eventos Relacionados')												// Adiciona a descri��o do Modelo de Dados

oModel:SetPrimaryKey( {"B8P_FILIAL", "B8P_CODINT", "B8P_CODRDA", "B8P_IDCOPR", "B8P_CODPAD", "B8P_CODPRO"} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author Oscar Zanin.
@since 23/09/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrB8P:= FWFormStruct(2, 'B8P')

oView := FWFormView():New()										// Cria o objeto de View
oView:SetModel(oModel)											// Define qual Modelo de dados ser� utilizado
oView:AddField('FrmB8P' , oStrB8P,'MasterB8P' ) 				// Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)
oView:CreateHorizontalBox( 'BxB8P', 100)						// Cria o Box que ir� conter a View
oView:SetOwnerView('FrmB8P','BxB8P')							// Associa a View ao Box

Return oView

//Valid.
Function PLB8PPRO(nCampo)
Local lRet      := .T.
local oModel     := FWModelActive()
Local cChave := ""

If nCampo == 1
    BR8->(dbsetOrder(1))
    cChave := xFilial("BR8") + oModel:getModel("MasterB8P"):getValue("B8P_CODPAD") + oModel:getModel("MasterB8P"):getValue("B8P_CODPRO")
	If ! BR8->(MsSeek(cChave))
        lRet := .F.
        Help(nil, nil , "Aten��o", nil, "C�digo inv�lido", 1, 0, nil, nil, nil, nil, nil, {""} )
    else
        oModel:getModel("MasterB8P"):loadvalue("B8P_DESPRO", BR8->BR8_DESCRI)
	Endif
ElseIf nCampo == 2
	BR4->(dbsetOrder(1))
    cChave := xFilial("BR4") + oModel:getModel("MasterB8P"):getValue("B8P_CODPAD")
    If ! BR4->(MsSeek(cChave))
		lRet := .F.
        Help(nil, nil , "Aten��o", nil, "C�digo inv�lido", 1, 0, nil, nil, nil, nil, nil, {""} )
    endif
    oModel:getModel("MasterB8P"):loadvalue("B8P_CODPRO", '')
    oModel:getModel("MasterB8P"):loadvalue("B8P_DESPRO", '')
Endif

Return lRet

//Confirma��o da tela
function PLS368BBok(oModel)
Local lRet := .F.
Local cSql := ""
Local nOperation := oModel:getOperation()
Local nRecAtu := 0
Local aARea := B8P->(getArea())

if nOperation == 3 .OR. nOperation == 4

    if nOperation == 4
        nRecAtu := B8P->(Recno())
    endif

    cSql += " Select 1 from " + retSqlName("B8P")
    cSql += " Where "
    csql += " B8P_FILIAL = '" + xFilial("B8P") + "' AND "
    cSql += " B8P_CODINT = '" + oModel:getModel("MasterB8P"):getValue("B8P_CODINT") + "' AND "
    cSql += " B8P_CODRDA = '" + oModel:getModel("MasterB8P"):getValue("B8P_CODRDA") + "' AND "
    cSql += " B8P_IDCOPR = '" + oModel:getModel("MasterB8P"):getValue("B8P_IDCOPR") + "' AND "
    cSql += " B8P_CODPAD = '" + oModel:getModel("MasterB8P"):getValue("B8P_CODPAD") + "' AND "
    cSql += " B8P_CODPRO = '" + oModel:getModel("MasterB8P"):getValue("B8P_CODPRO") + "' AND "
    if B8P->(FieldPos("B8P_CODESP")) > 0
        cSql += " B8P_CODESP = '" + oModel:getModel("MasterB8P"):getValue("B8P_CODESP") + "' AND "
    endif
    if B8P->(FieldPos("B8P_TIPATE")) > 0
        cSql += " B8P_TIPATE = '" + oModel:getModel("MasterB8P"):getValue("B8P_TIPATE") + "' AND "
    endif
    if B8P->(FieldPos("B8P_REGATE")) > 0
        cSql += " B8P_REGATE = '" + oModel:getModel("MasterB8P"):getValue("B8P_REGATE") + "' AND "
    endif
    if nOperation == 4
        cSql += " R_E_C_N_O_ <> " + AllTrim(Str(nRecAtu)) + " AND "
    endif
    cSql += " D_E_L_E_T_ = ' ' "

    dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"B8PEXI",.f.,.t.)

    lret := B8PEXI->(EoF())

    B8PEXI->(dbclosearea())

    if !lRet
        Help(nil, nil , "Aten��o", nil, "Evento j� vinculado ao contrato", 1, 0, nil, nil, nil, nil, nil, {""} )
    endif
else
    lRet := .T.
endif

restarea(aARea)

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author Daniel Silva

Gera sequencial contrato x evento .

@since 10/11/2022
@version P12
/*/
//-------------------------------------------------------------------

function geraSequen(cCodInt, cCodRda, cIdCopr)

local cSql    := ""
local Sequen  := ""

cSql := " Select MAX(B8P_SEQUEN) SEQUEN from " + retSqlName("B8P")
cSql += " Where "
cSql += " B8P_FILIAL = '" + xFilial("B8P") + "' AND "
cSql += " B8P_CODINT = '" + cCodInt + "' AND "
cSql += " B8P_CODRDA = '" + cCodRda + "' AND "
cSql += " B8P_IDCOPR = '" + cIdCopr + "' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"cAlias",.f.,.t.)

Sequen := val(cAlias->SEQUEN) += 1
Sequen := Right("0000" + allTrim(cvaltochar(Sequen)), 4)
cAlias->(dbclosearea())

return Sequen

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author Daniel Silva

verifica se os campos foram criados - automa��o 

@since 10/11/2022
@version P12
/*/
//-------------------------------------------------------------------

static function vldCampos()

local lVldCampos := B8P->(FieldPos("B8P_TIPATE")) > 0 .and. B8P->(FieldPos("B8P_CODESP")) > 0 .and.B8P->(FieldPos("B8P_REGATE")) > 0 .and. B8P->(FieldPos("B8P_SEQUEN")) > 0

return lVldCampos



