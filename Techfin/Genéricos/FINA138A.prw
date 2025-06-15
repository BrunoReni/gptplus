#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FINA138A.CH"

/*/
    {Protheus.doc} FINA138A
    Log de Integra��es Techfin.
    @type function
    @version 1.0 
    @author Claudio Yoshio Muramatsu
    @since 01/02/2023
    @param nOpcAuto, numeric, op��o da rotina para o execauto
    @param aAR7Auto, variant, dados para o execauto
/*///-------------------------------------------------------------------
Function FINA138A( nOpcAuto As Numeric, aAR7Auto As Array )
    Local aAuto      As Array
    Local lExistAR7  As Logical
    Local oBrowse    As Object
    Local oModel     As Object
    
    Private aRotina As Array

    Default nOpcAuto := 0
    Default aAR7Auto := {}

    aAuto     := {}
    lExistAR7 := FwAliasInDic( "AR7" )
    oBrowse   := Nil
    oModel    := Nil
    
    aRotina   := MenuDef() 

    If lExistAR7
        If Empty( aAR7Auto )
            oBrowse := FWMBrowse():New() 
            
            oBrowse:SetAlias( "AR7" ) 
            oBrowse:SetDescription( STR0001 )   //"Log de Integra��es Techfin"
            oBrowse:SetMenuDef( "FINA138A" )            
            oBrowse:AddLegend( "AR7->AR7_RESULT=='1'", "BR_VERDE"    , STR0002 )   //"Integra��o OK"
            oBrowse:AddLegend( "AR7->AR7_RESULT=='2'", "BR_VERMELHO" , STR0003 )   //"Erro na Integra��o"
            
            oBrowse:Activate()

            FreeObj( oBrowse )
        Else
            oModel  := FWLoadModel( "FINA138A" )
            aAuto   := { { "AR7MASTER", aAR7Auto } }
            FWMVCRotAuto( oModel, "AR7", nOpcAuto, aAuto, /*lSeek*/, .T. )
            FreeObj( oModel )
        EndIf    
    Else    
        Help("", 1, "HELP", "HELP", STR0004, 1,,,,,,, {}) //"A tabela de log AR7 n�o foi criada no dicion�rio. Por favor atualizar e tentar novamente."
    EndIf

    FWFreeArray( aAuto )
    FWFreeArray( aRotina )
Return

/*/
    {Protheus.doc} ModelDef
    Modelo de dados do log de Integra��es Techfin.
    @type function
    @version 1.0
    @author Claudio Yoshio Muramatsu
    @since 01/02/2023
    @return object, objeto do model
/*/
Static Function ModelDef() As Object
    Local oStructAR7 As Object
    Local oModel     As Object
    
    oStructAR7 := FWFormStruct( 1, "AR7" )
    oModel     := Nil

    oModel := MPFormModel():New( "FINA138A", /*bPreValid*/, /*bPosValid*/, /*bCommit*/ ) 
    oModel:AddFields( "AR7MASTER", /*cOwner*/, oStructAR7 )
Return oModel


/*/
    {Protheus.doc} ViewDef
    Formul�rio do log de Integra��es Techfin.
    @type function
    @version 1.0
    @author Claudio Yoshio Muramatsu
    @since 01/02/2023
    @return object, objeto da view
/*/
Static Function ViewDef() As Object
    Local oModel      As Object
    Local oStructAR7  As Object
    Local oView       As Object
    
    oModel      := FWLoadModel( "FINA138A" )
    oModel:SetDescription( STR0001 ) 
    oStructAR7  := FWFormStruct( 2, "AR7" )
    oView       := Nil

    oView := FWFormView():New()
    oView:SetModel( oModel )
    oView:AddField( "VIEW_AR7", oStructAR7, "AR7MASTER" )
Return oView


/*/
    {Protheus.doc} MenuDef
    Menu do log de Integra��es Techfin.
    @type function
    @version 1.0
    @author Claudio Yoshio Muramatsu
    @since 01/02/2023
    @return array, array com as op��es de menu
/*/
Static Function MenuDef() As Array
    Local aRotina := {}
    ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FINA138A' OPERATION 2 ACCESS 0   //"Visualizar"
Return aRotina


/*/
    {Protheus.doc} FIN138PROD
    Retorna a lista de op��es de produtos Techfin para o campo AR7_PRODUT.
    @type function
    @version 1.0
    @author Claudio Yoshio Muramatsu
    @since 01/02/2023
    @return object, objeto da view
/*/
Function FIN138APRD() As Character
    Local cListaProd As Character    
    cListaProd := STR0006 //"1=Antecipa;2=Mais Neg�cios;3=Mais Prazo"
Return cListaProd


/*/
    {Protheus.doc} TechFinLog
    Classe respons�vel por fazer a manuten��o dos registros do Log de Integra��es Techfin.
    @type  Class
    @author Claudio Yoshio Muramatsu
    @since 01/02/2023
    @version 1.0
/*/
Class TechFinLog from LongNameClass

    DATA cNomeUser   As Character
    DATA lExistAR7   As Logical
    DATA lIntegLog   As Logical
    
    Method New() CONSTRUCTOR
    Method InsertLog()
    Method DeleteLog()

EndClass

/*/
    {Protheus.doc} TechFinLog::New
    M�todo construtor da classe TechFinLog.
    @type method
    @author Claudio Yoshio Muramatsu
    @since 31/01/2023
/*/
Method New() Class TechFinLog

    ::lExistAR7   := FwAliasInDic( "AR7" )
    ::lIntegLog   := GetSrvProfString( "fw-tf-integration-log", "1" ) == "1"
    ::cNomeUser   := UsrRetName( RetCodUsr() )
 
Return self
 
/*/
    {Protheus.doc} TechFinLog::InsertLog
    M�todo respons�vel pela inclus�o de registros na tabela de log.
    @type Method
    @author Claudio Yoshio Muramatsu
    @since 31/01/2023    
    @param aRecords, array, dados para gera��o do log
        [1] Id do Log
        [2] Produto Origem
        [3] Origem do Log
        [4] Acao
        [5] Endpoint
        [6] JSON
        [7] Observa��o
        [8] Resultado
        [9] Tabela Origem
        [10] Chave do Registro (X2_UNICO)
/*/
Method InsertLog( aRecords As Array ) Class TechFinLog
    
    Local aArea      As Array
    Local aErroAuto  As Array
    Local aAR7Auto   As Array
    Local cError     As Character
    Local cIdLog     As Character
    Local nItem      As Numeric
    Local nErro      As Numeric
    Local nTamOrigem As Numeric
    Local nTamEndpo  As Numeric

	Private lMsErroAuto		:= .F. 
	Private lAutoErrNoFile	:= .T.
	Private lMsHelpAuto   	:= .T.

    aArea      := GetArea()
    aErroAuto  := {}
    aAR7Auto   := {}
    cError     := ""
    cIdLog     := ""

    If ::lExistAR7 .And. ::lIntegLog
        nTamOrigem := TamSX3("AR7_ORIGEM")[1]
        nTamEndpo  := TamSX3("AR7_ENDPO")[1]

        For nItem := 1 to Len( aRecords )
            lMsErroAuto := .F.
            aAR7Auto    := {}
            aErroAuto   := {}
            cError      := ""
            cIdLog      := If( Empty( aRecords[ nItem, 1 ] ), FWUUIDV4(), aRecords[ nItem, 1 ])

            aAdd( aAR7Auto, { "AR7_FILIAL"    , xFilial( "AR7" )                         , Nil } )
            aAdd( aAR7Auto, { "AR7_IDLOG"     , cIdLog                                   , Nil } )
            aAdd( aAR7Auto, { "AR7_PRODUT"    , aRecords[ nItem, 2 ]                     , Nil } )
            aAdd( aAR7Auto, { "AR7_ORIGEM"    , Left( aRecords[ nItem, 3 ], nTamOrigem ) , Nil } )
            aAdd( aAR7Auto, { "AR7_ACAO"      , aRecords[ nItem, 4 ]                     , Nil } )
            aAdd( aAR7Auto, { "AR7_ENDPO"     , Left( aRecords[ nItem, 5 ], nTamEndpo )  , Nil } )
            aAdd( aAR7Auto, { "AR7_JSON"      , aRecords[ nItem, 6 ]                     , Nil } )
            aAdd( aAR7Auto, { "AR7_OBS"       , aRecords[ nItem, 7 ]                     , Nil } )
            aAdd( aAR7Auto, { "AR7_RESULT"    , aRecords[ nItem, 8 ]                     , Nil } )            
            aAdd( aAR7Auto, { "AR7_TABORI"    , aRecords[ nItem, 9 ]                     , Nil } )
            aAdd( aAR7Auto, { "AR7_CHAVE"     , aRecords[ nItem, 10 ]                    , Nil } )
            aAdd( aAR7Auto, { "AR7_NOMUSR"    , ::cNomeUser                              , Nil } )
            aAdd( aAR7Auto, { "AR7_DATA"      , Date()                                   , Nil } )
            aAdd( aAR7Auto, { "AR7_HORA"      , Time()                                   , Nil } )

            MSExecAuto( {| x, y | FINA138A( x, y ) }, 3, aAR7Auto )
            If lMsErroAuto
                aErroAuto := GetAutoGRLog()
                For nErro := 1 To Len( aErroAuto ) 
                    cError += aErroAuto [ nErro ]
                Next
                LogMsg( "RskInsertLog", 23, 6, 1, "", "", STR0008 + cError ) //"RskInsertLog -> "
            EndIf
        Next
    EndIf
    
    RestArea( aArea )

    FwFreeArray( aArea )
    FwFreeArray( aErroAuto )
    FwFreeArray( aAR7Auto )

Return


/*/
    {Protheus.doc} TechFinLog::DeleteLog
    M�todo respons�vel pela exclus�o de registros na tabela de log.
    @type Method
    @author Claudio Yoshio Muramatsu
    @since 31/01/2023
    @param nDias, numeric, n�mero de dias de log que ser�o mantidos
/*/
Method DeleteLog(nDias As Numeric ) Class TechFinLog
    
    Local aArea      As Array
    Local cString    As Character
    Local dDataDel   As Date
    Local oDeleteLog As Object

    Default nDias     := 45

    aArea := GetArea()

    If ::lExistAR7 .And. ::lIntegLog
        cString  := "DELETE FROM ? WHERE AR7_DATA < ?"
        dDataDel := Date() - nDias

        oDeleteLog := FWPreparedStatement():New()        
        oDeleteLog:SetQuery( cString )
        oDeleteLog:SetUnsafe( 1, RetSqlName("AR7") )
        oDeleteLog:SetString( 2, DToS( dDataDel ) )

        If TCSqlExec( oDeleteLog:GetFixQuery() ) < 0
            FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", STR0007 + CRLF + TCSQLError(), 0, 0, {}) //DeleteLog -> Erro na limpeza da tabela de log de integra��es Techfin.
        Else
            FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", I18N( STR0009, { DToC( dDataDel ) } ) + CRLF + TCSQLError(), 0, 0, {}) //"DeleteLog -> Exclus�o de registros de log anteriores a #1 realizada com sucesso."
        EndIf
    EndIf

    RestArea( aArea )

    FwFreeArray( aArea )
    FwFreeObj( oDeleteLog )

Return
