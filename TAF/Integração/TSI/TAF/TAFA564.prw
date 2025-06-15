#include "protheus.ch"
#include "fwmvcdef.ch"
#include "TAFA564.ch"

/*-------------------------------------------------------------------
{Protheus.doc} TAFA564()
(Rotina para visualiza��o do log de erro gerado pelo TSI)
@author Carlos Eduardo
@since 30/06/2020
@return Nil, nulo, n�o tem retorno.
//-----------------------------------------------------------------*/
Function TAFA564() 
Local oBrowse := FWMBrowse():New()
	
oBrowse:SetDescription(STR0001)
oBrowse:SetAlias('V5R')
oBrowse:SetMenuDef('TAFA564')
oBrowse:Activate()

Return

/*-------------------------------------------------------------------
{Protheus.doc} MenuDef()
@author Carlos Eduardo
@since 30/06/2020
@return Nil, nulo, n�o tem retorno.
//-----------------------------------------------------------------*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.TAFA564' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE STR0010 ACTION 'TAFA564Clear(2)' OPERATION 3 ACCESS 0 //"Reprocessar NF atual"
ADD OPTION aRotina TITLE STR0004 ACTION 'TAFA564Clear(1)' OPERATION 4 ACCESS 0 //"Reprocessar todas NF"

Return aRotina

/*-------------------------------------------------------------------
{Protheus.doc} ModelDef()
@author Carlos Eduardo
@since 30/06/2020
@return Nil, nulo, n�o tem retorno.
//-----------------------------------------------------------------*/
Static Function ModelDef()
Local oStruV5R := FWFormStruct(1,'V5R')
Local oModel   := MPFormModel():New( "TAFA564")

oModel:AddFields('MODEL_V5R', /*cOwner*/, oStruV5R)
oModel:GetModel('MODEL_V5R'):SetPrimaryKey({'V5R_FILIAL', 'V5R_CODFIL', 'V5R_ALIAS', 'V5R_REGKEY' })

Return oModel

/*-------------------------------------------------------------------
{Protheus.doc} ViewDef()
@author Carlos Eduardo
@since 30/06/2020 
@return Nil, nulo, n�o tem retorno.
//-----------------------------------------------------------------*/
Static Function ViewDef()
Local oModel        := FwLoadModel('TAFA564')
Local oStrV5R       := FWFormStruct(2, 'V5R')
Local oView         := FWFormView():New() 

oView:SetModel(oModel)
oView:AddField('VIEW_V5R' ,oStrV5R,'MODEL_V5R')
oView:EnableTitleView( 'VIEW_V5R', STR0001 )
oView:CreateHorizontalBox( 'FIELDS_V5R', 100 )
oView:SetOwnerView( 'VIEW_V5R', 'FIELDS_V5R' )

Return oView

/*-------------------------------------------------------------------
{Protheus.doc} TAFA564Clear()

@author Denis Souza, Ricardo Lovre, Jose Felipe, Renan Gomes
@since 23/07/2020
@return Nil, nulo, n�o tem retorno.
//-----------------------------------------------------------------*/
Function TAFA564Clear(nOpc)

local lRet      as logical
local lManual   as logical
local oObjV5R   as Object
Local cNotaFis  as character
Local aErpKey   as character

lRet     := .F.
lManual  := .T.
oObjV5R  := Nil
cNotaFis := ""
aErpKey  := {}

If nOpc == 1
    if MsgYesNo(STR0005 + CRLF + STR0006 + cFilAnt + " ?" ) //"Deseja colocar em reprocessamento todas as notas inconsistentes "##"da filial "
        oObjV5R := TSIV5RC20():New( (cEmpAnt+cFilAnt), lManual ) //TAFA600.PRW Altera��o Fake C20
        lRet := oObjV5R:lExec
        if lRet ; MsgInfo(STR0007 + CRLF + STR0008) ; else; MsgAlert(STR0009); endif//"Lote inserido na fila de processamento "##" aguarde algun(s) minutos e consulte novamente." //"Falha ao inserir os registros na fila de reprocessamento."
    endif

ElseIf nOpc == 2
    if V5R->V5R_ALIAS <> 'C20'
        MsgAlert(STR0011) //"Somente movimentos fiscais podem ser reprocessados, os respectivos cadastros vinculados a esses movimentos ser�o integrados automaticamente"
    else
        cNotaFis := ""
        aErpKey  := StrTokArr( V5R->V5R_ERPKEY, "|" )
        cNotaFis := IIF(LEN(aErpKey) >= 4, aErpKey[4],"")

        if MsgYesNo(STR0012 + cNotaFis + "?" ) //"Deseja colocar em reprocessamento a Nota Fiscal "
            oObjV5R := TSIV5RC20():New( (cEmpAnt+cFilAnt), .F.,V5R->(RECNO()) )
            lRet := oObjV5R:lExec
            if lRet
                MsgInfo(STR0007 + CRLF + STR0008) //"Lote inserido na fila de processamento "##" aguarde algun(s) minutos e consulte novamente."
            else
                MsgAlert(STR0009) //"Falha ao inserir os registros na fila de reprocessamento."
            endif
        endif
    Endif
Endif

Return lRet
