#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"

#DEFINE READY       "2"
#DEFINE FINISHED    "4"

#define PDTE_RECIBO "1"
#DEFINE RECIBO_OK   "2"
#DEFINE TAM_RECIBO  12
#DEFINE RETIFICADO  "3"

Static _barra := iif(IsSrvUnix(),"/","\")
//M�tricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENMVCB2U

@author jose.paulo
@since 29/07/20
/*/
//--------------------------------------------------------------------------------------------------
Function CENMVCB2U(cFiltro,lAutom)
    Local cDescript := "DMED - Hist�rico de Arquivos"
    Local oPnl
    Local oBrowse
    Local cAlias	:= "B2U"

    Private oDlgB2U
    Private aRotina	:= {}

    Default cFiltro	:= 	" B2U_FILIAL = xFilial( 'B2U' ) .AND. " +;
        " B2U_CODOPE = B3D->B3D_CODOPE .AND. " +;
        " B2U_CODOBR = B3D->B3D_CDOBRI .AND. " +;
        " B2U_ANOCMP = B3D->B3D_ANO .AND. " +;
        " B2U_CDCOMP = B3D->B3D_CODIGO "

    (cAlias)->(dbSetOrder(1))

    oBrowse:= FWmBrowse():New()
    oBrowse:SetOwner( oPnl )
    oBrowse:SetFilterDefault( cFiltro )
    oBrowse:SetDescription( cDescript )
    oBrowse:SetAlias( cAlias )

    oBrowse:SetMenuDef( 'CENMVCB2U' )
    oBrowse:SetProfileID( 'CENMVCB2U' )
    oBrowse:ForceQuitButton()
    oBrowse:DisableDetails()
    oBrowse:SetWalkthru(.F.)
    oBrowse:SetAmbiente(.F.)
    oBrowse:AddLegend( "B2U_STATUS=='1'", "YELLOW"  , "Pendente Recibo" )
    oBrowse:AddLegend( "B2U_STATUS=='2'", "GREEN"   , "Concluido" )
    oBrowse:AddLegend( "B2U_STATUS=='3'", "RED"     , "Retificado" )

    if lHabMetric .and. lLibSupFw .and. lVrsAppSw
        FWMetrics():addMetrics("Hist�rico de Arquivos DMED", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
    endif

    If !lAutom
        oBrowse:Activate()
    EndIf

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author jose.paulo
@since 29/07/20
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
    Private aRotina	:= {}

    aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.CENMVCB2U'	, 0 , 2 , 0 , NIL } ) //Visualizar
    aAdd( aRotina, { 'Incluir Recibo'       , 'INCRECDMED'          , 0 , 4 , 0 , NIL } )
    aAdd( aRotina, { 'Excluir' 		        , 'DELARQDMED'          , 0 , 5 , 0 , NIL } )
    aAdd( aRotina, { 'Download' 	        , 'GETARQDMED'          , 0 , 2 , 0 , NIL } )

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author jose.paulo
@since 29/07/20
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oStruB2U 	:= FWFormStruct( 1, 'B2U', , )
    Local oModel		:= Nil

    oModel := MPFormModel():New( "DMED - Hist�rico de Arquivos", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

    oModel:AddFields( 'B2UMASTER', , oStruB2U )
    oModel:GetModel( 'B2UMASTER' ):SetDescription( "DMED - Hist�rico de Arquivos" )
    oModel:SetPrimaryKey({'B2U_FILIAL' , 'B2U_CODOPE','B2U_CODOBR','B2U_ANOCMP','B2U_CDCOMP','B2U_REFERE','B2U_ANOCAL','B2U_NOMARQ','B2U_STATUS'})

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author jose.paulo
@since 29/07/20
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
    Local oModel   := FWLoadModel( 'CENMVCB2U' )
    Local oStruB2U := FWFormStruct( 2, 'B2U' )
    Local oView    := FWFormView():New()

    oView:SetModel( oModel )
    oView:AddField( 'VIEW_B2U' , oStruB2U , 'B2UMASTER' )
    oView:CreateHorizontalBox( 'SUPERIOR', 100 )
    oView:EnableTitleView( 'VIEW_B2U', 'DMED - Hist�rico de Arquivos' )
    oStruB2U:RemoveField('B2U_USRDEL')
    oStruB2U:RemoveField('B2U_DTHDEL')

Return oView

Function IncRecDMed()
    Local oCenCltB2U    := CenCltB2U():New()
    Local cCodope       := B2U->B2U_CODOPE
    Local cCodobr       := B2U->B2U_CODOBR
    Local cAnocmp       := B2U->B2U_ANOCMP
    Local cCdcomp       := B2U->B2U_CDCOMP
    Local cRefere       := B2U->B2U_REFERE
    Local cAnocal       := B2U->B2U_ANOCAL
    Local cNomArq       := B2U->B2U_NOMARQ
    Local aPerg         := {}
    Local cRecibo       := Space(TAM_RECIBO)
    Local aParam        := {}

    If B2U->B2U_STATUS <> RETIFICADO

        If Empty(B2U->B2U_NUMREC)

            aAdd(aPerg, {1, "Recibo: ",  cRecibo,"@R 999999999999","","","",80,.T.})
            If ParamBox(aPerg, "Informe o n�mero do recibo: ",@aParam ,/*bOK*/,/*aButtons*/,/*lCentered*/.T.,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,/*lCanSave*/.F.,/*lUserSave*/.F. )
                If Len(cRecibo) == 12 .Or. Empty(cRecibo)
                    oCenCltB2U:setValue("healthInsurerCode" ,cCodope)
                    oCenCltB2U:setValue("requirementCode"   ,cCodobr)
                    oCenCltB2U:setValue("commitmentYear"    ,cAnocmp)
                    oCenCltB2U:setValue("commitmentCode"    ,cCdcomp)
                    oCenCltB2U:setValue("reference"         ,cRefere)
                    oCenCltB2U:setValue("calendarYear"      ,cAnocal)
                    oCenCltB2U:setValue("fileName"          ,cNomArq)
                    oCenCltB2U:setValue("status"            ,PDTE_RECIBO)

                    If oCenCltB2U:bscChaPrim()
                        oCenCltB2U:setValue("receiptNumber" ,AllTrim(aParam[1]))
                        oCenCltB2U:setValue("status"        ,RECIBO_OK)
                        If !oCenCltB2U:verNumDup(oCenCltB2U)
                            If oCenCltB2U:setNumRecibo()
                                PLCOMPMF(.F., "6")
                                MsgInfo("N�mero do recibo inclu�do com sucesso" , "Central de Obriga��es")
                            EndIf
                        Else
                            MsgInfo("N�mero do recibo j� existe" , "Central de Obriga��es")
                        EndIf
                    EndIf
                Else
                    MsgInfo("N�mero do recibo deve ter 12 d�gitos" , "Central de Obriga��es")
                EndIf
            EndIf
        Else
            If MsgYesNo("N�mero do recibo j� informado. Deseja alter�-lo?", "Central de Obriga��es")
                aAdd(aPerg, {1, "Recibo: ", ALLTRIM(B2U->B2U_NUMREC),"@R 999999999999","","","",80,.T.})
                If ParamBox(aPerg, "Informe o novo n�mero do recibo: ",@aParam ,/*bOK*/,/*aButtons*/,/*lCentered*/.T.,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,/*lCanSave*/.F.,/*lUserSave*/.F. )
                    If Len(cRecibo) == 12 .Or. Empty(cRecibo)

                        oCenCltB2U:setValue("healthInsurerCode" ,cCodope)
                        oCenCltB2U:setValue("requirementCode"   ,cCodobr)
                        oCenCltB2U:setValue("commitmentYear"    ,cAnocmp)
                        oCenCltB2U:setValue("commitmentCode"    ,cCdcomp)
                        oCenCltB2U:setValue("reference"         ,cRefere)
                        oCenCltB2U:setValue("calendarYear"      ,cAnocal)
                        oCenCltB2U:setValue("fileName"          ,cNomArq)
                        oCenCltB2U:setValue("status"            ,RECIBO_OK)

                        If oCenCltB2U:bscChaPrim()
                            oCenCltB2U:setValue("receiptNumber" ,AllTrim(aParam[1]))
                            oCenCltB2U:setValue("status"        ,RECIBO_OK)

                            If !oCenCltB2U:verNumDup(oCenCltB2U)
                                If oCenCltB2U:setNumRecibo()
                                    PLCOMPMF(.F., "6")
                                    MsgInfo("N�mero do recibo inclu�do com sucesso" , "Central de Obriga��es")
                                EndIf
                            Else
                                MsgInfo("N�mero do recibo j� existe" , "Central de Obriga��es")
                            EndIf
                        EndIf
                    Else
                        MsgInfo("N�mero do recibo deve ter 12 d�gitos" , "Central de Obriga��es")
                    EndIf
                EndIf
            EndIf
        EndIf
    Else
        MsgInfo("N�o � poss�vel alterar o Recibo do registro Retificado." , "Central de Obriga��es")
    EndIf
    oCenCltB2U:destroy()
    FreeObj(oCenCltB2U)
    oCenCltB2U := nil
Return

Function DelArqDMed()
    Local oCenCltB2U    := CenCltB2U():New()
    Local oCenCltB2W    := CenCltB2W():New()
    Local cNomarq       := B2U->B2U_NOMARQ
    Local cCodope       := B2U->B2U_CODOPE
    Local cCodobr       := B2U->B2U_CODOBR
    Local cAnocmp       := B2U->B2U_ANOCMP
    Local cCdcomp       := B2U->B2U_CDCOMP
    Local cRefere       := B2U->B2U_REFERE
    Local cAnocal       := B2U->B2U_ANOCAL
    Local cStatus       := B2U->B2U_STATUS

    If cStatus <> "3"
        If cStatus <> "2"

            If isBlind() .OR. ApMsgNoYes("Este processo n�o pode ser desfeito, deseja realmente excluir este arquivo?" ,"Central de Obriga��es")
                If FErase(_barra + "dmed" + _barra + cNomarq,,.T.) == 0
                    oCenCltB2U:setValue("healthInsurerCode"     ,cCodope)
                    oCenCltB2U:setValue("requirementCode"       ,cCodobr)
                    oCenCltB2U:setValue("commitmentYear"        ,cAnocmp)
                    oCenCltB2U:setValue("commitmentCode"        ,cCdcomp)
                    oCenCltB2U:setValue("reference"             ,cRefere)
                    oCenCltB2U:setValue("calendarYear"          ,cAnocal)
                    oCenCltB2U:setValue("fileName"              ,cNomarq)
                    oCenCltB2U:setValue("status"                ,cStatus)
                    oCenCltB2U:setValue("correctedReceiptNumber",B2U->B2U_RECRET)
                    oCenCltB2U:delete()

                    grvUsrCanc("B2U", "B2U_USRDEL", "B2U_DTHDEL")

                    If cStatus == "1" .And. Empty(B2U->B2U_RECRET)

                        oCenCltB2W:setValue("healthInsurerCode" , cCodope)
                        oCenCltB2W:setValue("requirementCode"   , cCodobr)
                        oCenCltB2W:setValue("referenceYear"     , cAnocmp)
                        oCenCltB2W:setValue("commitmentCode"    , cCdcomp)
                        oCenCltB2W:setValue("status"            , FINISHED)

                        If oCenCltB2U:getValue("status") <> '3'
                            oCenCltB2W:updateStatus(READY)
                        EndIf
                    Else
                        oCenCltB2U:atuStaArq(oCenCltB2U) // atualizo o status da movimenta��o anterior, caso contr�rio o processo seria travado.
                    EndIf

                    MsgInfo("Arquivo exclu�do com sucesso" , "Central de Obriga��es")

                Else
                    MsgStop("Este arquivo n�o p�de ser exclu�do" + CRLF + cValToChar(FError()))
                EndIf
            EndIf
        Else
            MsgStop("Este arquivo n�o p�de ser exclu�do, pois j� foi enviado � Receita federal." , "Central de Obriga��es")
        EndIf
    Else
        MsgStop("N�o � poss�vel excluir um registro retificado. ","Central de Obriga��es")
    EndIf
    oCenCltB2U:destroy()
    FreeObj(oCenCltB2U)
    oCenCltB2U := nil
    oCenCltB2W:destroy()
    FreeObj(oCenCltB2W)
    oCenCltB2W := nil
Return

Function GetArqDMed()
    local cFolder       := SelArq()
    Local cFilename     := B2U->B2U_NOMARQ
    If !Empty(cFolder)
        If CpyS2T( _barra + "dmed" + _barra + B2U->B2U_NOMARQ, cFolder , .F.)
            MsgInfo("Arquivo " + cFilename + CRLF + " copiado com sucesso em " + cFolder, "Central de Obriga��es")
        Else
            MsgStop("Ocorreu um erro ao copiar o arquivo" + CRLF + cValToChar(FError()))
        EndIf
    EndIf
Return

Static Function SelArq()
    local _cExtens   := "Diret�rio"//"Arquivo Texto ( *.TXT ) |*.TXT|"
    _cRet := cGetFile( _cExtens, "Selecione o Diret�rio",,, .F., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY , .F.)
    _cRet := ALLTRIM( _cRet )
Return( _cRet )