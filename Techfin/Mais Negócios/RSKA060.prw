#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RSKA060.CH"
#INCLUDE "RSKDEFS.CH"

Static aOrgSettings := {}
Static __nLenCodeAn := Nil
Static oBrowse      := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RSKA060
Concess�o de Credito Risk.
@type   Function
@param  nOpcAuto, number, Indica a a��o que ser� executada pela execauto
@param  uAR5Auto, array, Array com os dados da execauto
@param  lAutomato, boolean, Indica que a fun��o foi chamada por um script ADVPR
@author Squad NT / TechFin
@since  22/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Function RSKA060( nOpcAuto, uAR5Auto, lAutomato )
    Local aAuto     := {}
    Local oModel    := Nil 
 
    Private aRotina := MenuDef() 

    Default nOpcAuto    := 0
    Default uAR5Auto    := Nil
    Default lAutomato   := .F.

    Static lADVPR := lAutomato

    If uAR5Auto == Nil
        oBrowse := FWMBrowse():New() 
        oBrowse:SetAlias( "AR5" ) 
        oBrowse:SetDescription( STR0001 )   //'Concess�es Mais Neg�cios'
        oBrowse:SetMenuDef( "RSKA060" )
        oBrowse:AddLegend( "AR5->AR5_STATUS=='" + AR5_STT_AWAIT + "'", "BR_BRANCO"      , STR0036 )         // 0=Aguardando Envio
        oBrowse:AddLegend( "AR5->AR5_STATUS=='" + AR5_STT_ANALYSIS + "'", "BR_AMARELO"     , STR0002 )      // 1=Em an�lise
        oBrowse:AddLegend( "AR5->AR5_STATUS=='" + AR5_STT_APPROVED + "'", "BR_VERDE"       , STR0003 )      // 2=Aprovado
        oBrowse:AddLegend( "AR5->AR5_STATUS=='" + AR5_STT_REJECTED + "'", "BR_VIOLETA"     , STR0004 )      // 3=Rejeitado
        oBrowse:AddLegend( "AR5->AR5_STATUS=='" + AR5_STT_DENIED + "'", "BR_VERMELHO"    , STR0005 )        // 4=Negado
        oBrowse:AddLegend( "AR5->AR5_STATUS=='" + AR1_STT_CANCELED + "'", "BR_PRETO"       , STR0006 )      // 5=Cancelado
        oBrowse:AddLegend( "AR5->AR5_STATUS=='" + AR5_STT_PENDING + "'", "BR_LARANJA"     , STR0007 )       // 6=Pendente
        oBrowse:Activate()

        FreeObj( oBrowse )
    Else
        oModel  := FWLoadModel( "RSKA060" )
        aAuto   := { { "AR5MASTER", uAR5Auto } }
        FWMVCRotAuto( oModel, "AR5", nOpcAuto, aAuto, /*lSeek*/, .T. )
        FreeObj( oModel )
    EndIf

    FWFreeArray( aAuto ) 
    FWFreeArray( uAR5Auto )  
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da Concess�o de Cr�dito Mais Neg�cio.
@type   Static Function
@return objeto, modelo da concess�o de cr�dito
@author Squad NT TechFin
@since  02/09/2020
/*/
//-----------------------------------------------------------------------------
Static Function ModelDef() 
    Local oStructAR5    := FWFormStruct( 1, "AR5" )
    Local oModel        := Nil
    Local bPosValid     := {|oModel| RskPosValid( oModel ) }
    Local bCommit       := {|oModel| RskCmtModel( oModel ) }

    oModel := MPFormModel():New( "RSKA060", /*bPreValid*/, bPosValid, bCommit ) 
    oModel:AddFields( "AR5MASTER", /*cOwner*/, oStructAR5 )
Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Interface da Concess�o de Cr�dito Mais Neg�cio.
@type   Static Function
@return objeto, interface da tela de concess�o
@author Squad NT TechFin
@since  02/09/2020
/*/
//-----------------------------------------------------------------------------
Static Function ViewDef()
    Local oModel        := FWLoadModel( "RSKA060" )
    Local oStructAR5    := FWFormStruct( 2, "AR5" )
    Local oView         := Nil

    oStructAR5:RemoveField( "AR5_ENTIDA" )    
    oStructAR5:RemoveField( "AR5_FILENT" )
    oStructAR5:RemoveField( "AR5_DTAVAL" )     
    oStructAR5:RemoveField( "AR5_IDRSK" )
    oStructAR5:RemoveField( "AR5_DTSOLI" )
    oStructAR5:RemoveField( "AR5_RCOUNT" )
    oStructAR5:RemoveField( "AR5_STARSK" )

    oView := FWFormView():New()
    oView:SetModel( oModel )
    oView:AddField( "VIEW_AR5", oStructAR5, "AR5MASTER" )
    oView:CreateHorizontalBox( "SCREEN" , 100 )
    oView:SetOwnerView( "VIEW_AR5", "SCREEN" )
    oView:ShowInsertMsg( .F. ) 
    oView:SetUpdateMessage( STR0008, STR0009 ) //"Concess�o"##"Concess�o de cr�dito solicitada com sucesso."
Return oView


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu do Browse
@type   Static Function
@return array, vetor com as op��es da rotina
@author Squad NT TechFin
@since  17/09/2020
/*/
//-----------------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0010 ACTION 'Rsk020RBrw'         OPERATION 4 ACCESS 0    //'Atualizar'
    ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.RSKA060'    OPERATION 2 ACCESS 0    //'Visualizar'
Return aRotina 


//------------------------------------------------------------------------------
/*/{Protheus.doc} Rsk060RBrw
Bot�o de atualiza��o do browse para o usu�rio.
@type   Function
@author Squad NT TechFin
@since  17/09/2020
/*/
//-----------------------------------------------------------------------------
Function Rsk060RBrw()
    If oBrowse := Nil 
        oBrowse:Refresh()
    EndIf 
Return Nil 

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskPosValid
Bloco de pos valida��o.
@type  Static Function
@param  oModel, object, modelo da tela de concess�o
@return boolean, indica se a valida��o ocorreu sem falhas ou n�o.
@author Squad NT TechFin
@since  15/10/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskPosValid(oModel As Object) As Logical
    Local lRet      	As Logical
    Local lColPOri  	As Logical 
    Local oMdlAR5   	As Object
    
    Default oModel := FwModelActive()

     If Type('lAutomato') == 'U' // Tratamento para execu��o via ADVPR.
        lAutomato := .F.
    EndIf

    lRet     := .T.
    lColPOri := AR5->( ColumnPos( "AR5_ORIGIN" ) ) > 0 
    oMdlAR5  := oModel:GetModel( "AR5MASTER" )

    If ( !lColPOri .Or. oMdlAR5:GetValue("AR5_ORIGIN") == PROTHEUS_CONCESSION )     // 2=Protheus
        lRet := RskVldCli( oModel, lAutomato )  

        If lRet .And. oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. !Empty(AR5->AR5_FILENT )
            lRet := RskVldPOrg( oModel, lADVPR ) 
        EndIf
    EndIf 
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskVldPOrg
Valida geracao da concess�o de credito com base nos parametros do
organization.
@type  Static Function
@param  oModel, object, modelo da tela de concess�o
@param  lAutomato, boolean, Indica que a fun��o foi chamada por um script ADVPR
@return l�gico, indica se n�o houve problemas na valida��o
@author Squad NT TechFin
@since  15/10/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskVldPOrg( oModel As Object, lAutomato As Logical) As Logical
    Local oMdlAR5       As Object
    Local aArea         As Array
    Local aAreaAR5      As Array
    Local aDtSol        As Array 
    Local lRet          As Logical
    Local cCodConR      As Character

    Default lAutomato := .F.

    oMdlAR5   := oModel:GetModel( "AR5MASTER" )
    aArea     := GetArea()
    aAreaAR5  := AR5->( GetArea() )
    aDtSol := {} 
    lRet      := .T.
    cCodConR  := ""

    //------------------------------------------------------------------------------
    // Atualiza os parametros se o CNPJ da SMO for alterado.
    //------------------------------------------------------------------------------
    If Empty( aOrgSettings ) .Or. aOrgSettings[1] != SM0->M0_CGC 
        aOrgSettings := RskGetSSettings( SM0->M0_CGC, lAutomato, CLIENTPOSITION, 'RSKA060', 'AR5', /*aParam*/ )
    EndIf 

    If !Empty( aOrgSettings )
        cCodConR := RskConcRecent( "SA1", oMdlAR5:GetValue( "AR5_FILENT" ), oMdlAR5:GetValue( "AR5_CODENT" ), oMdlAR5:GetValue( "AR5_LOJENT" ) )

        AR5->( DBSetOrder(1) )    //AR5_FILIAL+AR5_CODCON
        If !Empty( cCodConR ) .And. oModel:GetOperation() == MODEL_OPERATION_INSERT
            If AR5->( DBSeek( xFilial("AR5") + cCodConR ) )
                aDtSol := StrToArray( RskFmtTStamp( AR5->AR5_DTSOLI ), " " )  
                If AR5->AR5_STATUS $ "'" + AR5_STT_ANALYSIS + "|" + AR5_STT_PENDING + "'"       // 1=Em an�lise ### 6=Pendente
                	lRet := .F.
                   	Help( "", 1, "RSKA060",, STR0012, 1, 0,,,,,, { STR0013 } )     //"J� existe uma concess�o em andamento."###"Por favor, aguarde o parceiro atualizar o status da concess�o."
                EndIf
            EndIf
        EndIf
    Else
        lRet := .F.
        Help( "", 1, "RSKA060",, STR0017, 1, 0,,,,,, { STR0018 } )      //"N�o foi poss�vel consultar as configura��es para concess�o de cr�dito na plataforma."###"Por favor verifique se h� um emitente vinculado a essa Empresa/Filial  ou realize uma nova tentativa mais tarde!"
    EndIf

    RestArea( aArea )
    RestArea( aAreaAR5 )

    FWFreeArray( aArea )
    FWFreeArray( aAreaAR5 )
    FWFreeArray( aDtSol )
Return lRet 


//------------------------------------------------------------------------------
/*/{Protheus.doc} RskConcRecent
Retorna a concessao de credito mais recente.
@type   Static Function
@param  cEntity, caracter, entidade da concess�o
@param  cFilEnt, caracter, filial
@param  cCodEnt, caracter, c�digo do cliente
@param  cLojEnt, caracter, loja do cliente
@param  cStatus, caracter, status da concess�o

@return caracter, c�digo da concess�o relacionado aos dados de pesquisa
@author Squad NT TechFin
@since  15/10/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskConcRecent( cEntity, cFilEnt, cCodEnt, cLojEnt, cStatus )
    Local aArea     := GetArea()
    Local cCodCon   := ""   
    Local cQuery    := ""
    Local cTempAR5  := GetNextAlias() 
    Local cTypeDB	:= TCGetDB()

    Default cEntity := ""
    Default cFilEnt := "" 
    Default cCodEnt := ""
    Default cLojEnt := ""
    Default cStatus := ""
    
    cQuery  := " SELECT "
    
    If cTypeDB = "MSSQL"
        cQuery += " TOP 1 "
    EndIf

    cQuery  += " AR5_CODCON "  
    cQuery  += " FROM " + RetSqlName( "AR5" )
    cQuery  += " WHERE AR5_FILIAL = '" + xFilial( "AR5" ) + "' " 
    cQuery  += " AND AR5_ENTIDA = '" + cEntity + "' "  
    cQuery  += " AND AR5_FILENT = '" + cFilEnt + "' "  
    cQuery  += " AND AR5_CODENT = '" + cCodEnt + "' "  
    cQuery  += " AND AR5_LOJENT = '" + cLojEnt + "' "  
    If !Empty( cStatus )
        cQuery  += " AND AR5_STATUS = '" + cStatus + "' "
    EndIf
    cQuery  += " AND D_E_L_E_T_ = ' ' "   
    
    If cTypeDB = "ORACLE"
        cQuery += " AND ROWNUM = 1 "
    EndIf

    cQuery  += " ORDER BY AR5_CODCON DESC "  
    
    If cTypeDB $ "MYSQL|POSTGRES"
        cQuery += " LIMIT 1 " 
    EndIf 

    cQuery  := ChangeQuery( cQuery ) 
    DbUseArea( .T., "TOPCONN", TCGenQry( , , cQuery ), cTempAR5, .F., .T. )

    If ( cTempAR5 )->( !Eof() ) 
        cCodCon := ( cTempAR5 )->AR5_CODCON
    EndIf
    ( cTempAR5 )->( DBCloseArea() )

    RestArea( aArea )

    FWFreeArray( aArea )
Return cCodCon


//------------------------------------------------------------------------------
/*/{Protheus.doc} RskCmtModel
Fun��o que faz grava��o do modelo de dados 
@type  Static Function
@param  oModel, objeto, modelo de dados
@return lRet, logico, Grava��o realizada com sucesso.
@author Squad NT TechFin
@since  03/09/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskCmtModel( oModel )
    Local lRet      := .T.
    Local oMdlAR5   := oModel:GetModel( "AR5MASTER" )
    Local lColPOri  := AR5->( ColumnPos( "AR5_ORIGIN" ) ) > 0 

    If oModel:GetOperation() == MODEL_OPERATION_INSERT
        oMdlAR5:LoadValue( "AR5_ENTIDA", Upper( oMdlAR5:GetValue("AR5_ENTIDA") ) )
        oMdlAR5:LoadValue( "AR5_DTSOLI", FWTimeStamp( 1, Date(), Time() ) )
        If ( !lColPOri .Or. oMdlAR5:GetValue("AR5_ORIGIN") == PROTHEUS_CONCESSION )     // 2=Protheus
            oMdlAR5:LoadValue( "AR5_STATUS", AR5_STT_AWAIT )    // 0=Aguardando Envio
            oMdlAR5:LoadValue( "AR5_STARSK", STARSK_SUBMIT )    // 1=Enviar
        EndIf
    EndIf 
    lRet := FWFormCommit( oModel )
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskVldCli
Fun��o que valida o cadastro de cliente para fazer uma concess�o de cr�dito
Mais Neg�cios.
@type   Static Function
@param  oModel, objeto, modelo de dados
@param  lAutomato, boolean, Indica que a fun��o foi chamada por um script ADVPR
@return lRet, logico, Retorna se o cliente est� apto para realizar uma
concess�o de credito Mais Neg�cio.
@author Squad NT TechFin
@since  03/09/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskVldCli( oModel As Object, lAutomato As Logical ) As Logical
    Local aArea    As Array
    Local aAreaSA1 As Array
    Local aAreaAR3 As Array
    Local oMdlAR5  As Object
    Local lRet     As Logical

    Default lAutomato := .F.

    aArea    := GetArea()
    aAreaSA1 := SA1->( GetArea() )
    aAreaAR3 := AR3->( GetArea() )
    oMdlAR5  := oModel:GetModel( "AR5MASTER" )
    lRet     := .T.

    If oModel:GetOperation() == MODEL_OPERATION_INSERT
        SA1->( DBSetOrder(1) )    //A1_FILIAL+A1_COD+A1_LOJA
        AR3->( DBSetOrder(1) )    //AR3_FILIAL+AR3_CODCLI+AR3_LOJCLI
        
        If Upper( oMdlAR5:GetValue( "AR5_ENTIDA" ) ) == "SA1"
            If SA1->( MSSeek( oMdlAR5:GetValue( "AR5_FILENT" ) + oMdlAR5:GetValue( "AR5_CODENT" ) + oMdlAR5:GetValue( "AR5_LOJENT" ) ) )           
                If lRet 
                    //------------------------------------------------------------------------------
                    // Validacao no cadastro do cliente
                    //------------------------------------------------------------------------------
                    If Empty( SA1->A1_CEP ) .Or. Empty( SA1->A1_BAIRRO )
                        lRet := .F.
                        Help( "", 1, "RSKA060",, STR0021, 1, 0,,,,,, { STR0022 } )      //"O campo CEP ou bairro do cliente n�o foi preenchido."###"Preencha o campo para realizar uma concess�o de cr�dito."
                    ElseIf Empty( SA1->A1_CGC )
                        lRet := .F.
                        Help( "", 1, "RSKA060",, STR0023, 1, 0,,,,,, { STR0022 } )      //"O campo CNPJ/CPF do cliente n�o foi preenchido."###"Preencha o campo para realizar uma concess�o de cr�dito."
                    ElseIf SA1->A1_MSBLQL == '1'
                        lRet := .F.
                        Help( "", 1, "RSKA060",, STR0037, 1, 0,,,,,, { STR0038 } )      //"O cliente est� inativo."###"."N�o � possivel pedir uma concess�o para um cliente bloqueado."
                    EndIf   
                EndIf

                If lRet .and. !FwIsInCallStack( "RskCliPosition" )
                    //------------------------------------------------------------------------------
                    // Atualiza\verifica a posi��o do cliente.
                    //------------------------------------------------------------------------------
                    RskGetCliPosition( SA1->A1_CGC, NIL, NIL, lAutomato, CONCESSION, 'RSKA060', 'AR5', /*aParam*/ )

                    If AR3->( MSSeek( xFilial( "AR3" ) + SA1->A1_COD + SA1->A1_LOJA ) ) .And. AR3->AR3_CREDIT == CREDIT_YES     // 1=Sim
                        If oMdlAR5:GetValue( "AR5_LIMDEJ" ) < 0 .Or. oMdlAR5:GetValue( "AR5_LIMDEJ" ) == AR3->AR3_LIMITE
                            lRet := .F.
                            Help( "", 1, "RskVldCli",, STR0019, 1, 0,,,,,, { STR0020 } )    //"Limite desejado inv�lido."###"Verifique se o limite desejado est� negativo ou igual ao limite atual"
                        EndIf
                    EndIf
                EndIf
            Else
                lRet := .F.
                Help( "", 1, "RSKA060",, STR0028, 1, 0,,,,,, { STR0029 } )     //"Dados do cliente n�o localizado."###"Verifique o cadastro de clientes."
            EndIf
        Else
            lRet := .F.
            Help( "", 1, "RSKA060",, STR0030, 1, 0,,,,,, { STR0031 } )    //"Entidade inv�lida para concess�o."###"Informe SA1 no campo Entidade."
        EndIf  
    EndIf    

    RestArea( aAreaSA1 )
    RestArea( aAreaAR3 )
    RestArea( aArea )

    FWFreeArray( aAreaSA1 )
    FWFreeArray( aAreaAR3 )
    FWFreeArray( aArea )
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} RskPostConcession
Funcao que envia as concess�es de credito diretamente para plataforma risk.
@type Function
@param cEndPoint, caracter, endpoint utilizado na integra��o.
@param lAutomato, boolean, Indica que a fun��o foi chamada por um script ADVPR
@param aParam, vetor, possui os dados do agendamento (schedule), empresa, filial e usu�rio
@author Squad NT TechFin
@since  02/09/2020
/*/
//-----------------------------------------------------------------------------
Function RskPostConcession( cEndPoint As Character, lAutomato As Logical, aParam As Array )
    Local aArea         As Array
    Local aJItems       As Array
    Local aErpIds       As Array
    Local aErrorMd      As Array
    Local cHost         As Character
    Local cErpId        As Character
    Local cBody         As Character
    Local cDescription  As Character
    Local cTmpCons      As Character
    Local nCount        As Numeric
    Local nRecProc      As Numeric
    Local nLimit        As Numeric
    Local nRetryCount   As Numeric
    Local nX            As Numeric
    Local nPosErpId     As Numeric
    Local oJResult      As Object
    Local oJItem        As Object
    Local oRest         As Object
    Local oModel        As Object
    Local oMdlAR5       As Object
    Local lLockByFil	As Logical
    Local lNotReanalise As Logical

    Default lAutomato := .F.
    Default aParam    := {}

    aArea         := GetArea() 
    aJItems       := {}
    aErpIds       := {}  
    aErrorMd      := {}
    cHost         := GetRSKPlatform( .F. )
    cErpId        := "" 
    cBody         := "" 
    cDescription  := ""
    cTmpCons      := ""
    nCount        := 0
    nRecProc      := 0
    nLimit        := 10
    nRetryCount   := 99 
    nX            := 0
    nPosErpId     := 0 
    oJResult      := Nil    
    oJItem        := Nil
    oRest         := Nil
    oModel        := Nil
    oMdlAR5       := Nil
    lLockByFil	  := !Empty(xFilial("AR5"))
    lNotReanalise := .F.  
    
    If LockByName("RskPostConcession", .T., lLockByFil )

        If lAutomato .Or. ( !Empty( cHost ) .Or. !Empty( cEndPoint ) )
            cQuery  := " SELECT AR5.AR5_FILIAL, AR5.AR5_CODCON, AR5.AR5_FILENT, AR5.AR5_CODENT, AR5.AR5_LOJENT, " + ;
                        " AR5.AR5_LIMDEJ , AR5.AR5_LIMAPR, AR5.AR5_DTSOLI, AR5.AR5_DTAVAL, AR5.AR5_STATUS, " + ;
                        " AR5.AR5_RCOUNT, SA1.A1_LC, AR5.R_E_C_N_O_ RECNO " + ;  
                    " FROM " + RetSqlName( "AR5" ) + " AR5 " + ; 
                    " INNER JOIN " + RetSqlName( "SA1" ) + " SA1 " + ;
                        " ON SA1.A1_FILIAL = AR5.AR5_FILENT " + ;
                        " AND SA1.A1_COD = AR5.AR5_CODENT " + ;
                        " AND SA1.A1_LOJA = AR5.AR5_LOJENT " + ;  
                        " AND SA1.D_E_L_E_T_ = ' ' " + ; 
                    " WHERE AR5.AR5_FILIAL = '" + xFilial( "AR5" ) + "' " + ;
                        " AND AR5.AR5_STARSK = '" + STARSK_SUBMIT + "' " + ;    // 1=Enviar
                        " AND AR5.AR5_ENTIDA = 'SA1' " + ;    
                        " AND AR5.D_E_L_E_T_ = ' ' " + ;   
                    " ORDER BY " + SqlOrder( AR5->( IndexKey( 1 ) ) )   //AR5_FILIAL+AR5_CODCON
            
            cQuery  := ChangeQuery( cQuery )    
            cTmpCons  := MPSysOpenQuery( cQuery )   

            DbSelectArea( cTmpCons )
            If ( cTmpCons )->( !Eof() )  
                //-----------------------------------------------------------------------------------
                // Identifica a quantidade de registro no alias tempor�rio para processamento.
                //-----------------------------------------------------------------------------------
                COUNT TO nRecProc

                //-------------------------------------------------------------------
                // Posiciona no primeiro registro.
                //-------------------------------------------------------------------
                ( cTmpCons )->( DBGoTop() )    

                //------------------------------------------------------------------
                // Ajusta o pagesize, caso o numero de registros de envio for menor.
                //------------------------------------------------------------------
                If nLimit > nRecProc
                    nLimit := nRecProc
                EndIf 

                oModel  := FWLoadModel( "RSKA060" )

                While ( cTmpCons )->( !Eof() ) 
                    cErpId  := AllTrim( cEmpAnt ) + "|" + AllTrim( ( cTmpCons )->AR5_FILIAL ) + "|" + AllTrim( ( cTmpCons )->AR5_CODCON )
                    nCount  += 1
                        
                    aAdd( aErpIds, { cErpId, ( cTmpCons )->RECNO } )
                    
                    oJItem                      := JsonObject():New()
                    oJItem["erpId"]             := cErpId
                    oJItem["customerErpId"]     := AllTrim( cEmpAnt ) + "|" + AllTrim( ( cTmpCons )->AR5_FILENT ) + "|" + AllTrim( ( cTmpCons )->AR5_CODENT ) + "|" + AllTrim( ( cTmpCons )->AR5_LOJENT )    
                    oJItem["currentLimit"]      := ( cTmpCons )->A1_LC
                    oJItem["desiredLimit"]      := ( cTmpCons )->AR5_LIMDEJ 
                    oJItem["requestDate"]       := RskDTimeUTC( ( cTmpCons )->AR5_DTSOLI )
                    oJItem["status"]            := AR5_STT_ANALYSIS  // 1=Em An�lise
                    oJItem["retryCount"]        := ( cTmpCons )->AR5_RCOUNT
                    oJItem["deleted"]           := 'false'        
                
                    aAdd( aJItems, oJItem )    

                    If nCount == nLimit
                        IF !lAutomato
                            cBody := RSKRestExec( RSKPOST, cEndPoint, @oRest, aJItems, RISK, SERVICE, .F., .F., CONCESSION, 'AR5', 'RSKA060', aParam )   // POST ### 1=Risk ### 2=URL de autentica��o de servi�os
                        ELSE
                            cBody := RskADVPRData( 'RSKA060' )
                        EndIf

                        If !Empty( cBody ) 
                            oJResult    := JSONObject():New()
                            oJResult:FromJSON( cBody )
                            
                            For nX := 1 To Len( oJResult )
                                oJItem      	:= oJResult[nX]
                                nPosErpId   	:= aScan( aErpIds, {|x| x[1] == oJItem["erpId"] } )
                                lNotReanalise   := .F.

                                If nPosErpId > 0
                                    AR5->( DBGoTo( aErpIds[nX][2] ) )
                                    BEGIN TRANSACTION
                                        oModel:SetOperation( MODEL_OPERATION_UPDATE )
                                        oModel:Activate()   

                                        If oModel:IsActive()  
                                            oMdlAR5 := oModel:GetModel( "AR5MASTER" )  
                                            
                                            oMdlAR5:SetValue( "AR5_RCOUNT", oJItem["retryCount"] )
                                            
                                            If oJItem["statusProcess"] == 1
                                                oMdlAR5:SetValue( "AR5_STATUS", AR5_STT_ANALYSIS )  // 1=Em An�lise
                                                oMdlAR5:SetValue( "AR5_STARSK", STARSK_SENT )       // 2=Enviado
                                                cDescription := " " 
                                            Else
                                                cDescription  := DecodeUTF8( oJItem["description"] ) + Chr(10)
                                                
                                                //------------------------------------------------------------------------------
                                                // N�o traduzir o texto do AT, pois ele vem da plataforma
                                                //------------------------------------------------------------------------------
                                                lNotReanalise := AT( "A permiss�o para rean�lise estar�", cDescription ) > 0
                                                If oJItem["retryCount"] >= nRetryCount .Or. lNotReanalise
                                                    oMdlAR5:SetValue( "AR5_STARSK", STARSK_CANCELED )   // 5=Cancelado
                                                    
                                                    If lNotReanalise
                                                        oMdlAR5:SetValue( "AR5_STATUS", AR5_STT_REJECTED )  // 3=Rejeitado
                                                    Else
                                                        oMdlAR5:SetValue( "AR5_STATUS", AR1_STT_CANCELED )  // 5=Cancelado
                                                    EndIf  

                                                    oMdlAR5:SetValue( "AR5_DTAVAL", FWTimeStamp( 1, Date(), Time() ) ) // Data da avalia��o da concess�o de credito pela plataforma 
                                                    If !lNotReanalise 
                                                        cDescription += STR0032 + Chr(10) + STR0033     //"Concess�o de cr�dito n�o enviada para plataforma Risk."###"Verifique os cadastros e tente uma nova concess�o de cr�dito."
                                                    EndIf
                                                Else
                                                    cDescription += STR0032 + Chr(10) + STR0034    //"Concess�o de cr�dito n�o enviada para plataforma Risk."###"Ser� realizado uma nova tentativa dentro de instantes."
                                                EndIf
                                            EndIf

                                            oMdlAR5:SetValue( "AR5_OBSRSK", cDescription )      

                                            If oModel:VldData()
                                                oModel:CommitData()   
                                            Else
                                                aErrorMd := oModel:GetErrorMessage()
                                                LogMsg( "RskPostCredit", 23, 6, 1, "", "", "RskPostCredit -> " + aErrorMd[6] )      
                                            EndIf
                                        EndIf

                                        oModel:DeActivate()
                                    END TRANSACTION
                                EndIf
                            Next nX 
                        Else 
                            If !lAutomato
                                LogMsg( "RskPostConcession", 23, 6, 1, "", "", "RskPostConcession -> " + oRest:GetLastError() + " " + IIF( oRest:GetResult() != Nil, oRest:GetResult(), "" ) )    
                            EndIf
                        EndIf 

                        aJItems     := {}
                        aErpIds     := {}  
                        nCount      := 0 
                        nRecProc    -= nLimit

                        //------------------------------------------------------------------
                        // Ajusta o pagesize para enviar os registros restantes.
                        //------------------------------------------------------------------
                        If nLimit > nRecProc
                            nLimit := nRecProc
                        EndIf 
                    EndIf
                    ( cTmpCons )->( DBSkip() )
                End
            EndIf

            ( cTmpCons )->( DBCloseArea() )
        Else
            LogMsg( "RskPostConcession", 23, 6, 1, "", "", "RskPostConcession -> " + STR0035 )  //"Host da plataforma RISK n�o informado."
        EndIf

        If oModel != Nil
            oModel:Destroy()
        EndIf
         
        UnLockByName( "RskPostConcession", .T., lLockByFil ) 
    Else
        LogMsg( "RskPostConcession", 23, 6, 1, "", "", "RskPostConcession -> " + STR0039 )  //"Existe um processamento de envio Concess�o Mais Neg�cios em outra instancia..." 
    EndIf

    RestArea( aArea ) 

    FWFreeArray( aArea ) 
    FWFreeArray( aJItems ) 
    FreeObj( oJResult )     
    FreeObj( oJItem )
    FreeObj( oRest )        
    FreeObj( oModel )        
    FreeObj( oMdlAR5 )
Return Nil 

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskUpdConcession
Atualiza��o a concess�o de credito realizada na plataforma para o Protheus.
@type       Function
@param 		aRecords: 	Array de concess�es com a seguinte estrutura
						[1] = Filial da Concess�o
                        [2] = Id da Concess�o
                        [3] = Id da Concess�o Risk
                        [4] = Filial do cliente
                        [5] = Codigo do cliente
                        [6] = Loja do cliente
                        [7] = Limite Desejado  
                        [8] = Limite Aprovado
                        [9] = Data da Requisi��o
                        [10] = Data da Avalia��o
                        [11] = Status
                        [12] = Observa��es
                        [13] = Origem (1=Plataforma ou 2=Protheus)
@param  lAutomato, boolean, Indica que a fun��o foi chamada por um script ADVPR

@author Squad NT TechFin
@since  15/10/2020
/*/
//-----------------------------------------------------------------------------
Function RskUpdConcession( aRecords as Array, lAutomato as Logical)  
    Local aSvAlias      as  Array
    Local aAreaSA1      as  Array
    Local aAreaAR5      as  Array
    Local aErrorMd      as  Array
    Local oModel        as  Object
    Local oMdlAR5       as  Object
    Local cStatus       as  Character   
    Local cObs          as  Character      
    Local nLimAprov     as  Numeric 
    Local nLimitDesej   as  Numeric
    Local nX            as  Numeric
    Local nRecords      as  Numeric
    Local nLenCustID    as  Numeric
    Local nLenCustUnit  as  Numeric

    Default aRecords := {}
    Default lAutomato := .F.

    aSvAlias        := GetArea()
    aAreaSA1        := SA1->( GetArea() )
    aAreaAR5        := AR5->( GetArea() )
    aErrorMd        := {}
    oModel          := FWLoadModel( "RSKA060" )  
    oMdlAR5         := Nil
    nX              := 0      
    nRecords        := 0   
    nLenCustID      := TamSX3("A1_COD")[1]   
    nLenCustUnit    := TamSX3("A1_LOJA")[1]

    AR5->( DBSetOrder(1) )      //AR5_FILIAL+AR5_CODCON
    SA1->( DBSetOrder(1) )      //A1_FILIAL+A1_COD+A1_LOJA
    
    If __nLenCodeAn == Nil
        __nLenCodeAn := IF( AR5->( ColumnPos( "AR5_CODEAN" ) ) > 0 , TamSX3("AR5_CODEAN")[1] , 0 )
    EndIf

    nRecords := Len( aRecords )    

    For nX := 1 To nRecords             
        cBranchSA1  := Padr( aRecords[ nX ][ CONCESSION_CUSTBRANCH ], FwSizeFilial() )      // [4]-Filial do cliente
        cCustID     := Padr( aRecords[ nX ][ CONCESSION_CUSTID ]    , nLenCustID )          // [5]-Codigo do cliente
        cCustUnit   := Padr( aRecords[ nX ][ CONCESSION_CUSTUNIT ]  , nLenCustUnit )        // [6]-Loja do cliente

        If SA1->( DBSeek( cBranchSA1 + cCustID + cCustUnit ) ) 
            If AR5->( DBSeek( aRecords[ nX ][ CONCESSION_BRANCH ] + aRecords[ nX ][ CONCESSION_ID ] ) )     // [1]-Filial da concess�o ### [2]-ID da concess�o
                oModel:SetOperation( MODEL_OPERATION_UPDATE )
            Else
                oModel:SetOperation( MODEL_OPERATION_INSERT )
            EndIf
                
            oModel:Activate()  

            If oModel:IsActive() 
                oMdlAR5 := oModel:GetModel( "AR5MASTER" )  
                
                nLimitDesej     := Val( aRecords[ nX ][ CONCESSION_DESIREDLIMIT ] )  // [7]-Limite Desejado
                nLimAprov       := Val( aRecords[ nX ][ CONCESSION_APPROVEDCREDLIMIT ] )  // [8]-Limite Aprovado
                cStatus         := aRecords[ nX ][ CONCESSION_STATUS ]   // [11]-Status
                cObs            := ""

                If len(cValToChar(nLimitDesej)) > TamSx3("AR5_LIMDEJ")[1] .OR. len(cValToChar(nLimAprov)) > TamSx3("AR5_LIMAPR")[1] 
                    nLimitDesej := 0.01
                    nLimAprov   := 0
                    cStatus     := AR5_STT_CANCELED  // 5 - Cancelado
                    cObs        := CRLF + STR0043 + transform(cValToChar(Val( aRecords[ nX ][ CONCESSION_DESIREDLIMIT ] )), X3Picture('AR5_LIMDEJ'))  // Valor solicitado: 
                Endif

                If oModel:GetOperation() == MODEL_OPERATION_INSERT
                    oMdlAR5:SetValue( "AR5_ENTIDA", "SA1" )
                    oMdlAR5:SetValue( "AR5_FILENT", SA1->A1_FILIAL )
                    oMdlAR5:SetValue( "AR5_CODENT", SA1->A1_COD )
                    oMdlAR5:SetValue( "AR5_LOJENT", SA1->A1_LOJA )
                    oMdlAR5:SetValue( "AR5_LIMDEJ", nLimitDesej )   // Limite Desejado                 
                    oMdlAR5:SetValue( "AR5_ORIGIN", aRecords[ nX ][ CONCESSION_ORIGIN ] )       // [13]-Origem (1=Plataforma ou 2=Protheus)
                    oMdlAR5:SetValue( "AR5_DTSOLI", RskDTToLocal( aRecords[ nX ][ CONCESSION_REQUESTDATE ], .F. ) )     // [9]-Data da Requisi��o
                EndIf

                If aRecords[ nX ][ CONCESSION_STATUS ] == AR5_STT_APPROVED // [11]-Status ### 2=Aprovado
                    oMdlAR5:SetValue( "AR5_LIMAPR", nLimAprov)     // Limite Aprovado            
                EndIf
                
                oMdlAR5:SetValue( "AR5_DTAVAL", RskDTToLocal( aRecords[ nX ][ CONCESSION_EVALUATIONDATE ], .F. ) )   // [10]-Data da Avalia��o
                oMdlAR5:SetValue( "AR5_STATUS",  cStatus )  // Status

                If !Empty( aRecords[ nX ][ CONCESSION_OBSREASON ] )     // [12]-Observa��es  
                    oMdlAR5:SetValue( "AR5_OBSRSK", aRecords[ nX ][ CONCESSION_OBSREASON ] + cObs )    // [12]-Observa��es
                EndIf

                If __nLenCodeAn > 0
                    oMdlAR5:SetValue( "AR5_CODEAN", Left( aRecords[ nX ][ CONCESSION_CODEANALYZE ] , __nLenCodeAn ) )    // [14]-C�digo de an�lise da concess�o
                EndIf
                oMdlAR5:SetValue( "AR5_STARSK", STARSK_RECEIVED )       // 3=Recebido 
                oMdlAR5:SetValue( "AR5_IDRSK", aRecords[ nX ][ CONCESSION_RSKID ] )     // [3]-Id da Concess�o Risk
                
                If oModel:VldData() 
                    oModel:CommitData()   
                    If oModel:GetOperation() == MODEL_OPERATION_INSERT
                        aRecords[ nX ][ CONCESSION_BRANCH ] := xFilial( "AR5" )     // [1]-Filial da concess�o  
                        aRecords[ nX ][ CONCESSION_ID ]     := oMdlAR5:GetValue( "AR5_CODCON" )     // [2]-ID da concess�o
                    EndIf
                Else  
                    aErrorMd := oModel:GetErrorMessage()  
                    LogMsg( "RskUpdConcession", 23, 6, 1, "", "", "RskUpdConcession -> " + aErrorMd[6] )      
                EndIf     
            EndIf
 
            oModel:DeActivate() 
        EndIf
    Next nX 

    If oModel != Nil 
        oModel:Destroy() 
    EndIf 

    RestArea( aSvAlias )
    RestArea( aAreaSA1 )
    RestArea( aAreaAR5 )

    FWFreeArray( aSvAlias )
    FWFreeArray( aAreaSA1 )
    FWFreeArray( aAreaAR5 )
    FWFreeArray( aErrorMd )
    FreeObj( oModel )  
    FreeObj( oMdlAR5 )  
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} Rsk060NEnt
Retorna o nome da entidade para a montagem da tela
@type   Function
@param  nType, number, Identifica onde a fun��o est� sendo chamada, onde:
    1=X3_RELACAO
    2=X3_INIBRW

@return caracter, Nome do cliente
@author Squad NT TechFin
@since  15/10/2020
/*/
//-----------------------------------------------------------------------------
Function Rsk060NEnt( nType )
    Local cName     := ""
    Local oModel    := FwModelActive()
    Local oMdlAR5   := Nil

    Default nType := 1

    If nType == 1
        If oModel:GetOperation() != MODEL_OPERATION_INSERT
            oMdlAR5 := oModel:GetModel( "AR5MASTER" )
            cName := AllTrim( Posicione( oMdlAR5:GetValue( "AR5_ENTIDA" ), 1, oMdlAR5:GetValue( "AR5_FILENT" ) + ;
                    oMdlAR5:GetValue( "AR5_CODENT" ) + oMdlAR5:GetValue( "AR5_LOJENT" ), "A1_NOME" ) )
        EndIf
    Else
        cName := AllTrim( Posicione( AR5->AR5_ENTIDA, 1, AR5->AR5_FILENT + AR5->AR5_CODENT + AR5->AR5_LOJENT, "A1_NOME" ) )
    EndIf
Return cName

 
//------------------------------------------------------------------------------
/*/{Protheus.doc} MyRSKA020
Exemplo de rotina automatica para concess�o de cr�dito.
@type   Function
@param  Nenhum
@return Nenhum
@author Squad NT TechFin
@since  06/10/2020
/*/
//-----------------------------------------------------------------------------
/*
User Function MyRSKA060()

    Local aArea     := {} 
    Local aAreaSA1  := {}
    Local aAR5Auto  := {}
    Local lRet      := .T. 
    Local cCodCli   := ""  
    Local cLojCli   := ""
    Local nLimDej   := 0                                                                                                
 
    Private lMsErroAuto := .F.

    //RpcSetEnv("MyCompany","MyBranch")  

    RpcSetEnv("T1","M SP 01 ") 

    cCodCli     := "028928"
    cLojCli     := "01"
    nLimDej     := 70000
    aArea       := GetArea()
    aAreaSA1    := SA1->(GetArea())
    
    DBSelectArea("SA1")
    DBSetOrder(1)
 
    If DBSeek(xFilial("SA1") + cCodCli + cLojCli )     

        aAdd(aAR5Auto,{"AR5_ENTIDA" ,"SA1"          ,Nil})  //Entidade
        aAdd(aAR5Auto,{"AR5_FILENT"	,SA1->A1_FILIAL ,Nil})  //Filial da Entidade
        aAdd(aAR5Auto,{"AR5_CODENT"	,SA1->A1_COD    ,Nil})  //Codigo da Entidade
        aAdd(aAR5Auto,{"AR5_LOJENT"	,SA1->A1_LOJA   ,Nil})  //Loja da Entidade
        aAdd(aAR5Auto,{"AR5_LIMDEJ"	,600          ,Nil})  //Limite desejado.
    
        //Inclus�o da concess�o de credito.
        MSExecAuto({|x,y| RSKA060(x,y)},3,aAR5Auto) 
        
        If lMsErroAuto 
            MostraErro() 
            lRet := .F. 
        EndIf
       
    EndIf

    RpcClearEnv()

    RestArea(aAreaSA1)    
    RestArea(aArea)
    FWFreeArray(aAreaSA1)
    FWFreeArray(aArea)

Return Nil*/ 

