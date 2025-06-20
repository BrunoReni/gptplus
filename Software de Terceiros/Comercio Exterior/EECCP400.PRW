#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'eeccp400.ch'

/*/{Protheus.doc} EECCP400
    Rotina de cat�logo de produto para o m�dulo de exporta��o SIGAEEC

    @type  Function
    @author bruno akyo kubagawa
    @since 08/02/2023
    @version 1.0
    @param nil
    @return nil
/*/
function EECCP400()
    local aArea       := GetArea()
    local lProc       := .T.
    local cModoAcEK9  := FWModeAccess("EK9",3)
    local cModoAcEKA  := FWModeAccess("EKA",3)
    local cModoAcEKB  := FWModeAccess("EKB",3)
    local cModoAcEKD  := FWModeAccess("EKD",3)
    local cModoAcEKE  := FWModeAccess("EKE",3)
    local cModoAcEKF  := FWModeAccess("EKF",3)
    local cModoAcSB1  := FWModeAccess("SB1",3)
    local cModoAcSA2  := FWModeAccess("SA2",3)
    local oBrowse

    // privates do fonte EICCP400
    private aRotina      := {}
    private aAtrib       := {}
    private cNcm         := "          "
    private cModalEK9    := ""
    private cPrdRefEK9   := ""
    private cNcmAux      := ""
    private lRetAux      :=.T.
    private lMultiFil    := VerSenha(115) .And. cModoAcEK9 == "C" .And. cModoAcSB1 == "E" .And. cModoAcSA2 == "E"

    if( !(cModoAcEK9 == cModoAcEKD .And. cModoAcEK9==cModoAcEKA .and. cModoAcEK9 == cModoAcEKE .And. cModoAcEK9==cModoAcEKB .And. cModoAcEK9 == cModoAcEKF), ( lProc := .F. , EasyHelp(STR0001,STR0002)), nil ) // "Modo de compartilhamento est� diferente entre as tabelas. Verifique o modo das tabelas EK9, EKA, EKB,EKD, EKE e EKF." ### "Aten��o"

    if lProc
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("EK9")
        oBrowse:SetMenuDef("EECCP400")
        oBrowse:SetDescription(STR0003) // "Cat�logo de Produtos"
        oBrowse:AddFilter(STR0004,"@EK9_MODALI = '2'", .F., .T.) // "Modalidade de Cat�logo de Produtos"
        oBrowse:Activate()
    endif

    restArea(aArea)

return nil

/*/{Protheus.doc} ViewDef
    Fun��o para defini��o da Viewdef (EICCP400) 
    @type  Static Function
    @author bruno akyo kubagawa
    @since 08/02/2023
    @version 1.0
    @param nil
    @return oView, objeto, View do modelo de dados EICCP400
/*/
static function ViewDef()
    local oView := FWLoadView("EICCP400")
return oView

/*/{Protheus.doc} Menudef
    Fun��o para defini��o da Menudef
    @type  Static Function
    @author bruno akyo kubagawa
    @since 08/02/2023
    @version 1.0
    @param nil
    @return aRotina, vetor, op��es de manuten��o da rotina
/*/
static function Menudef()
    local aRotina := {}

    //Adiciona os bot�es na MBROWSE
    ADD OPTION aRotina TITLE STR0005 ACTION "AxPesqui"         OPERATION 1 ACCESS 0 // "Pesquisar"
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.EECCP400" OPERATION 2 ACCESS 0 // "Visualizar"
    ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.EECCP400" OPERATION 3 ACCESS 0 // "Incluir"
    ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.EECCP400" OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.EECCP400" OPERATION 5 ACCESS 0 // "Excluir"

return aRotina
