#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA986.CH'
#INCLUDE "FWMBROWSE.CH"
#Include "FWEditPanel.CH"
#Include "FwLibVersion.ch"

Static __cXml986     := ""
Static __cAlias986   := ""
Static __nOPER       := 0
Static __lFKG_CALCUL := .F.
Static __lFKF_ORIINS := .F.
Static __lFKF_CEDENT := .F.
Static __lFKF_PAGPIX := .F.
Static __lFKF_RECPIX := .F.
Static __lSF2_CNO    := .F.
Static __lA2_CPRB    := .F.
Static __lBrowse     := .F.
Static __aDadosTit   := {}
Static __oSttFKG     := NIL
Static __lFinQRCode
Static __TableF71    := .F.
Static __lFina890    := .F.
Static __lTableFKF   := .F. 
Static __lFKFEspec   := .F. 
Static __lF040Espec  := .F.
Static __lTableFOF   := .F.
Static __oPJob       := NIL
Static __oPJob2      := NIL
Static __lGeraPix    := .T.
Static __lExcImpo    As Logical
Static __lMultPIX    As Logical
Static __lPEMlPIX    As Logical
Static __lFNATREN    As Logical
Static __lFCODDEP    As Logical
Static __oFKGBase    As Object
Static __lAltImp     As Logical
Static __lFCGCSCP    As Logical
Static __cNATRSCP    As Char 
Static __lEmpPub     As Logical
Static __lPCCBx      As Logical
Static __nVlMPub     As Numeric
Static __nFINPIX9    As Numeric
Static __lTPIConf    As Logical
Static __lTemDic     As Logical
Static __lEDNTREN    As Logical
Static __oSeqF71     As Object
Static __lINSPRE     As Logical
Static __lErase      As Logical
Static __lGerF71     As Logical
Static __nCasDec     As Numeric

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA986
Cadastro dos complemento do titulo. Tabelas FKF e FKG

@author Karen Honda
@since 28/07/2016
@Param	cAliasC - variavel string contendo a tabela posicionada no momento (SE1 ou SE2)
@Param	lPosBrw	- variavel logica indicando o momento da chamada, se � no Browse ou na tela de cadastro do titulo
@version P11
/*/
//-------------------------------------------------------------------
Function FINA986(cAliasC As Character, lPosBrw As Logical)

Local cIdDoc         := ""
Local cChave         := ""
Local oModel
Local nOpc           := 3
Local cAliasTab      := ""
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
Local cTipos		 :=	MVABATIM + "/" + MV_CRNEG + "/" + MVTXA + "/" + MV_CPNEG + "/" + MVPROVIS + "/" + MVCSABT + "/" + MVCFABT + "/" + MVPIABT

//Recriando as vari�veis no escopo da fun��o
Private INCLUI := IIf(Type('INCLUI') == 'L', INCLUI, .F.)
Private ALTERA := IIf(Type('ALTERA') == 'L', ALTERA, .F.)

Default lPosBrw := .F.

//inicializa as variaveis estaticas.
F986IniVar(cAliasC,lPosBrw)

__lErase    := __lBrowse

cAliasTab  := If(lPosBrw, cAliasC+"->" , "M->")

//Valida se o complemento esta disponivel para o tipo de titulo posicionado
If &( cAliasTab + Right(cAliasC, 2) + "_TIPO" ) $ cTipos 
    Help( ,,"FKFNAOPERM",,STR0025, 1, 0 )	// "Tipo do titulo nao permitido para o complemento de imposto.""
    Return .F.
Endif	

If cAliasC == "SE1" // se veio do contas a receber

    If __lBrowse
        cChave := SE1->E1_FILIAL + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
    Else
        cChave := M->E1_FILIAL + "|" +  M->E1_PREFIXO + "|" + M->E1_NUM + "|" + M->E1_PARCELA + "|" + M->E1_TIPO + "|" + M->E1_CLIENTE + "|" + M->E1_LOJA
    Endif

    If !INCLUI
        cIdDoc := FINGRVFK7(cAliasC, cChave)
        FKF->(DBSetOrder(1))
        If FKF->(DBSeek(xFilial("FKF") + cIdDoc ))
            If ALTERA
                nOpc := MODEL_OPERATION_UPDATE
            Else
                nOpc := MODEL_OPERATION_VIEW
            EndIf
        EndIf
    EndIf

ElseIf  cAliasC == "SE2" // se veio do contas a pagar

    If __lBrowse
        cChave := SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE+ "|" + SE2->E2_LOJA
    Else
        cChave := M->E2_FILIAL + "|" +  M->E2_PREFIXO + "|" + M->E2_NUM + "|" + M->E2_PARCELA + "|" + M->E2_TIPO + "|" + M->E2_FORNECE+ "|" + M->E2_LOJA
    Endif

    If !INCLUI
        cIdDoc := FINGRVFK7(cAliasC, cChave)
        FKF->(DBSetOrder(1))
        If FKF->(DBSeek(xFilial("FKF") + cIdDoc ))
            If ALTERA
                nOpc := MODEL_OPERATION_UPDATE
            Else
                nOpc := MODEL_OPERATION_VIEW
            EndIf
        EndIf
    EndIf
EndIf

__nOPER:= nOpc

If Valtype(__cXml986) == "C"  .and. !Empty(__cXml986)
    oModel := FwLoadModel("FINA986")
    oModel:LoadXMLData(__cXml986)
    FWExecView( STR0001,"FINA986", nOpc,/**/,{||.T.}/*bCloseOnOk*/,/*{||Fakeok()}*/,,aEnableButtons,/*bCancel*/,/**/,/*cToolBar*/, oModel )//'Complemento titulo'
    oModel:Deactivate()
    oModel:Destroy()
    oModel:= Nil
Else
    FWExecView( STR0001,"FINA986", nOpc,/**/,{||.T.}/*bCloseOnOk*/,/*{||Fakeok()}*/,,aEnableButtons,/*bCancel*/,/**/,/*cToolBar*/,  )//'Complemento titulo'STR0001
EndIf

Return

//-------------------------------------------------------------------

Static Function ModelDef()
    // Cria a estrutura a ser usada no Modelo de Dados
    Local oStruFKF   As Object
    Local oStruFKG   As Object
    Local oModel     As Object
    Local cAliasTab  As Character
    Local cCampo	 As Character
    Local bLinePost  As block
    Local bWhenValor As block
    Local cAcao      As Character

    oStruFKF    := FWFormStruct( 1, 'FKF', /*bAvalCampo*/, /*lViewUsado*/ )
    oStruFKG    := FWFormStruct( 1, 'FKG', /*bAvalCampo*/, /*lViewUsado*/ )
    oModel      := NIL
    cAliasTab   := ""
    cCampo	    := ""
    bLinePost   := {|| F986LINE(oModel) }
    bWhenValor  := {||}
    cAcao       := "M->FKG_DEDACR"

    If __lEDNTREN == Nil
        __lEDNTREN := cPaisLoc == "BRA" .And. SED->(ColumnPos("ED_NATREN")) > 0
    EndIf

    __cAlias986 := IF(ValType(__cAlias986)=="U", "SE2", __cAlias986)
    cAliasTab  := If(__lBrowse, __cAlias986+"->" , "M->")
    cCampo	   := cAliasTab + Right(__cAlias986, 2) + "_LA"

    If __cAlias986 == 'SE1' 
        __nCasDec := TamSx3("E1_TXMOEDA")[2]
    Else
        __nCasDec := TamSx3("E2_TXMOEDA")[2]
    Endif
    
    oStruFKF:AddField(			  ;
    STR0026					, ;	// [01] Titulo do campo		//'Descri��o do CNAE'
    STR0026					, ;	// [02] ToolTip do campo 	//'Descri��o do CNAE'
    "FKF_DSCNAE"			, ;	// [03] Id do Field
    "C"						, ;	// [04] Tipo do campo
    200						, ;	// [05] Tamanho do campo
    0						, ;	// [06] Decimal do campo
    { || .T. }				, ;	// [07] Code-block de valida��o do campo
    { || .F. }				, ;	// [08] Code-block de valida��o When do campo
                            , ;	// [09] Lista de valores permitido do campo
    .F.						, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
    FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,Posicione('CG1',1,xFilial('CG1')+FKF->FKF_CNAE,'CG1_DESCRI'),'')") ,,,;// [11] Inicializador Padr�o do campo
    .T.)						// [14] Virtual


    oStruFKF:AddField(			  ;
    STR0027					, ;	// [01] Titulo do campo		//"Descri��o do Tipo de Repasse"
    STR0027					, ;	// [02] ToolTip do campo 	//"Descri��o do Tipo de Repasse"
    "FKF_DSCTRP"			, ;	// [03] Id do Field
    "C"						, ;	// [04] Tipo do campo
    200						, ;	// [05] Tamanho do campo
    0						, ;	// [06] Decimal do campo
    { || .T. }				, ;	// [07] Code-block de valida��o do campo
    { || .F. }				, ;	// [08] Code-block de valida��o When do campo
                            , ;	// [09] Lista de valores permitido do campo
    .F.						, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
    FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,Posicione('SX5',1,xFilial('SX5')+'0G'+FKF->FKF_TPREPA,'X5_DESCRI'),'')") ,,,;// [11] Inicializador Padr�o do campo
    .T.)						// [14] Virtual

    oStruFKF:AddField(			  ;
    STR0028					, ;	// [01] Titulo do campo		//"Descri��o do Tipo de Servi�o"
    STR0028					, ;	// [02] ToolTip do campo 	//"Descri��o do Tipo de Servi�o"
    "FKF_DSCTSR"			, ;	// [03] Id do Field
    "C"						, ;	// [04] Tipo do campo
    200						, ;	// [05] Tamanho do campo
    0						, ;	// [06] Decimal do campo
    { || .T. }				, ;	// [07] Code-block de valida��o do campo
    { || .F. }				, ;	// [08] Code-block de valida��o When do campo
                            , ;	// [09] Lista de valores permitido do campo
    .F.						, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
    FWBuildFeature( STRUCT_FEATURE_INIPAD,"IIF(!INCLUI,Posicione('SX5',1,xFilial('SX5')+'DZ'+FKF->FKF_TPSERV,'X5_DESCRI'),'')" ) ,,,;// [11] Inicializador Padr�o do campo
    .T.)						// [14] Virtual


    oStruFKF:AddField(			  ;
    STR0029					, ;	// [01] Titulo do campo		//"Descri��o do CNO"
    STR0029					, ;	// [02] ToolTip do campo 	//"Descri��o do CNO"
    "FKF_DSCCNO"			, ;	// [03] Id do Field
    "C"						, ;	// [04] Tipo do campo
    200						, ;	// [05] Tamanho do campo
    0						, ;	// [06] Decimal do campo
    { || .T. }				, ;	// [07] Code-block de valida��o do campo
    { || .F. }				, ;	// [08] Code-block de valida��o When do campo
                            , ;	// [09] Lista de valores permitido do campo
    .F.						, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
    FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,Posicione('SON',1,xFilial('SON')+FKF->FKF_CNO,'ON_DESC'),'')") ,,,;// [11] Inicializador Padr�o do campo
    .T.)						// [14] Virtual


    oStruFKF:AddField(			  ;
    STR0030					, ;	// [01] Titulo do campo		//"Descri��o do Bem"
    STR0030					, ;	// [02] ToolTip do campo 	//"Descri��o do Bem"
    "FKF_DSCBEM"			, ;	// [03] Id do Field
    "C"						, ;	// [04] Tipo do campo
    200						, ;	// [05] Tamanho do campo
    0						, ;	// [06] Decimal do campo
    { || .T. }				, ;	// [07] Code-block de valida��o do campo
    { || .F. }				, ;	// [08] Code-block de valida��o When do campo
                            , ;	// [09] Lista de valores permitido do campo
    .F.						, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
    FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,Posicione('SX5',1,xFilial('SX5')+'0I'+FKF->FKF_CODBEM,'X5_DESCRI'),'')") ,,,;// [11] Inicializador Padr�o do campo
    .T.)						// [14] Virtual


    oStruFKF:AddField(			  ;
    STR0031					, ;	// [01] Titulo do campo		//"Descri��o do Servi�o"
    STR0031					, ;	// [02] ToolTip do campo 	//"Descri��o do Servi�o"
    "FKF_DSCSRV"			, ;	// [03] Id do Field
    "C"						, ;	// [04] Tipo do campo
    200						, ;	// [05] Tamanho do campo
    0						, ;	// [06] Decimal do campo
    { || .T. }				, ;	// [07] Code-block de valida��o do campo
    { || .F. }				, ;	// [08] Code-block de valida��o When do campo
                            , ;	// [09] Lista de valores permitido do campo
    .F.						, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
    FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,Posicione('SX5',1,xFilial('SX5')+'0H'+FKF->FKF_CODSER,'X5_DESCRI'),'')") ,,,;// [11] Inicializador Padr�o do campo
    .T.)						// [14] Virtual

	If __lFNATREN	//Adiciona campo p/ descricao da Natureza de Rendimento
		oStruFKF:AddField(			  ;
		STR0032					, ;	// [01] Titulo do campo		//"Descri��o da Natureza de Rendimento"
		STR0032					, ;	// [02] ToolTip do campo 	//"Descri��o da Natureza de Rendimento"
		"FKF_DSCNRN"			, ;	// [03] Id do Field
		"C"						, ;	// [04] Tipo do campo
		200						, ;	// [05] Tamanho do campo�
		0						, ;	// [06] Decimal do campo
		{ || .T. }				, ;	// [07] Code-block de valida��o do campo
		{ || .F. }				, ;	// [08] Code-block de valida��o When do campo
								, ;	// [09] Lista de valores permitido do campo
		.F.						, ;	// [10] Indica se o campo tem preenchimento obrigat�rio
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,Posicione('FKX',1,xFilial('FKX')+FKF->FKF_NATREN,'FKX_DESCR'),'')") ,,,;// [11] Inicializador Padr�o do campo
		.T.)						// [14] Virtual
	EndIf

    oStruFKF:AddField(' ','FKF_ALIAS' ,'FKF_ALIAS'	,'C',3,0,/*bValid*/, /*bWhen*/,,.F.,)

    oStruFKF:SetProperty( 'FKF_IDDOC'         , MODEL_FIELD_OBRIGAT, .F.)
    oStruFKF:SetProperty( 'FKF_CPRB'		  , MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD,'F986CPRBIni()'))

    //inicializa o campo com sim
    If __cAlias986 == 'SE1' .and. __lFKF_RECPIX
        oStruFKF:SetProperty('FKF_RECPIX', MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD,'F986PixIni()'))
        oStruFKF:SetProperty("FKF_RECPIX", MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN , 'F986PixVal()'))
        oStruFKF:SetProperty("FKF_RECPIX", MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,'F986PixVld()'))
    EndIf
    //valid para qr code
    If __cAlias986 == 'SE2' .and. __lFKF_PAGPIX .and. !FwIsInCallStack("Fa986grava")
        oStruFKF:SetProperty( 'FKF_PAGPIX', MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"F986QRCode()"))
    EndIf

    If __lFKF_CEDENT	// Cedente
        oStruFKF:SetProperty( 'FKF_CEDNOM'	  , MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD,"F986IniCed()"))
    EndIf
    oStruFKG:SetProperty( 'FKG_IDDOC'         , MODEL_FIELD_OBRIGAT, .F.)
    oStruFKG:SetProperty( 'FKG_IDFKE'         , MODEL_FIELD_WHEN, {||&cCampo<>'S'} )
    oStruFKG:SetProperty( 'FKG_DESATR'		  , MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD,'F986DesIn()'))
    oStruFKG:SetProperty( 'FKG_TPPROC'		  , MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD,'F986IniNu()'))
    oStruFKG:SetProperty( 'FKG_NUMPRO'		  , MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,'F986VldNP()'))

    If __lINSPRE
        oStruFKG:SetProperty( 'FKG_INSPRE'        , MODEL_FIELD_WHEN, {||F986WhnFKG()} )
    EndIf    
    
    oStruFKF:SetProperty( "FKF_CPRB"  , MODEL_FIELD_WHEN, {||Fa986When()} )
    oStruFKF:SetProperty( "FKF_CNAE"  , MODEL_FIELD_WHEN, {||Fa986When()} )
    oStruFKF:SetProperty( "FKF_TPREPA", MODEL_FIELD_WHEN, {||Fa986When()} )
    oStruFKF:SetProperty( "FKF_TPSERV", MODEL_FIELD_WHEN, {||Fa986When()} )
    oStruFKF:SetProperty( "FKF_CNO"   , MODEL_FIELD_WHEN, {||Fa986When()} )
    oStruFKF:SetProperty( "FKF_INDSUS", MODEL_FIELD_WHEN, {||Fa986When()} )
    oStruFKF:SetProperty( "FKF_INDDEC", MODEL_FIELD_WHEN, {||Fa986When()} )
    oStruFKF:SetProperty( "FKF_CODBEM", MODEL_FIELD_WHEN, {||Fa986When()} )
    oStruFKF:SetProperty( "FKF_CODSER", MODEL_FIELD_WHEN, {||Fa986When()} )
    
    //Quando acionado via browse e exibir a aba de edicao da FKG, nao permitir incluir na grid quando a acao nao for 'Informativo'
    If !__lBrowse
        bWhenValor := {|| &cCampo <> 'S' }
    Else
        bWhenValor := {|| &cCampo <> 'S' .And. &cAcao <> '3' }
    Endif
    oStruFKG:SetProperty( 'FKG_VALOR', MODEL_FIELD_WHEN, bWhenValor )

    //Gatilhos
    oStruFKF:AddTrigger( "FKF_CNAE"	 , "FKF_DSCNAE", { || .T.}, { |oModel| F986Gatil(oModel, "FKF_CNAE") } )
    oStruFKF:AddTrigger( "FKF_TPREPA", "FKF_DSCTRP", { || .T.}, { |oModel| F986Gatil(oModel, "FKF_TPREPA") } )
    oStruFKF:AddTrigger( "FKF_TPSERV", "FKF_DSCTSR", { || .T.}, { |oModel| F986Gatil(oModel, "FKF_TPSERV") } )
    oStruFKF:AddTrigger( "FKF_CNO"	 , "FKF_DSCCNO", { || .T.}, { |oModel| F986Gatil(oModel, "FKF_CNO") } )
    oStruFKF:AddTrigger( "FKF_CODBEM", "FKF_DSCBEM", { || .T.}, { |oModel| F986Gatil(oModel, "FKF_CODBEM") } )
    oStruFKF:AddTrigger( "FKF_CODSER", "FKF_DSCSRV", { || .T.}, { |oModel| F986Gatil(oModel, "FKF_CODSER") } )	

    oStruFKG:AddTrigger( "FKG_IDFKE","FKG_IDFKE", {|| .T. }  , {|| F986FkeGt() }  )
    oStruFKG:AddTrigger( "FKG_NUMPRO","FKG_NUMPRO", {|| .T. }  , {|| F986CcfGt() }  )
    If __lFKG_CALCUL
        oStruFKG:AddTrigger( "FKG_BASECA","FKG_VALOR", {|| .T. }  , {|| F986BaseCa() }  )
    EndIf

    If __lFNATREN //Natureza de Rendimento
        oStruFKF:AddTrigger("FKF_NATREN", "FKF_DSCNRN", { || .T. }, { |oModel| F986Gatil(oModel, "FKF_NATREN", "FKF_DSCNRN") } )
        oStruFKF:AddTrigger("FKF_NATREN", "FKF_INDDEC", { || .T. }, { |oModel| F986Gatil(oModel, "FKF_NATREN", "FKF_INDDEC") } )
        If __lFCGCSCP
             oStruFKF:AddTrigger("FKF_NATREN", "FKF_CGCSCP", { || .T. }, { |oModel| F986Gatil(oModel, "FKF_NATREN", "FKF_CGCSCP") } )
        EndIf
        If __lFCODDEP
            oStruFKG:SetProperty("FKG_CODDEP", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, 'Vazio() .Or. F986VlDep()'))
            oStruFKG:SetProperty("FKG_CODDEP", MODEL_FIELD_WHEN, {||F986VlDep(FwFldGet("FKG_IDFKE"))} )
        EndIf
        oStruFKF:SetProperty("FKF_NATREN", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, 'F986IniNat()'))
        oStruFKF:SetProperty("FKF_NATREN", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, 'Vazio() .Or. (ExistCpo("FKX") .and. F986VlNat())'))
        oStruFKF:SetProperty("FKF_NATREN", MODEL_FIELD_WHEN, {||Fa986When('FKF_NATREN')} )
    EndIf

    If __lFCGCSCP 
        oStruFKF:SetProperty( "FKF_CGCSCP", MODEL_FIELD_WHEN, {||Alltrim(FwFldGet("FKF_NATREN")) $ Alltrim(__cNATRSCP)} )
    EndIf
    
    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New("FINA986", /*PreValidacao*/ , {|oModel| Fa986Pos(oModel)} /*PosValidacao*/, {|oModel|Fa986Conf()} /*bCommit*/)

    // Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
    oModel:AddFields( 'FKFMASTER', , oStruFKF )

    // Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
    oModel:AddGrid( 'FKGDETAIL', 'FKFMASTER', oStruFKG, /*bLinePre*/, bLinePost, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

    If __nOPER==MODEL_OPERATION_UPDATE .and. &cCampo == 'S'
        oModel:GetModel( 'FKGDETAIL' ):SetNoInsertLine( .T. )
        oModel:GetModel( 'FKGDETAIL' ):SetNoDeleteLine( .T. )
    Elseif __nOPER==MODEL_OPERATION_UPDATE .and. __lBrowse
        oModel:GetModel( 'FKGDETAIL' ):SetNoDeleteLine( .T. )
    EndIf

    oModel:SetPrimaryKey({'FKF_FILIAL','FKF_IDDOC'})

    // Faz relaciomaneto entre os compomentes do model
    oModel:SetRelation( 'FKGDETAIL', { { 'FKG_FILIAL', 'xFilial( "FKG" )' }, { 'FKG_IDDOC', 'FKF_IDDOC' } }, FKG->( IndexKey( 1 ) ) )

    // Liga o controle de nao repeticao de linha
    oModel:GetModel( 'FKGDETAIL' ):SetUniqueLine( { 'FKG_ITEM' } )

    // Indica que � opcional ter dados informados na Grid
    oModel:GetModel( 'FKGDETAIL' ):SetOptional(.T.)

    // Adiciona a descricao do Modelo de Dados
    oModel:SetDescription(STR0010)//"Cadastro"

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel( 'FKFMASTER' ):SetDescription( STR0002 )//'Obriga��es do t�tulo'
    oModel:GetModel( 'FKGDETAIL' ):SetDescription( STR0003 ) //'Impostos X Atributos'

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado sem exibir o campo IDDOC
    Local oStruFKF	As Object
    Local oStruFKG	As Object

    // Cria a estrutura a ser usada na View
    Local oModel    As Object
    Local oView     As Object


    oStruFKF	:= FWFormStruct(2,'FKF', { |x| !ALLTRIM(x) $ "FKF_IDDOC , FKF_ESPEC"})
    oStruFKG	:= FWFormStruct( 2, 'FKG', { |x| !ALLTRIM(x) $ "FKG_IDDOC"} )
    oModel      := FWLoadModel("FINA986")
    oView       := Nil

    oStruFKF:SetProperty( 'FKF_TPREPA' , MVC_VIEW_COMBOBOX,  )

    oStruFKF:SetProperty( 'FKF_CPRB'   , MVC_VIEW_ORDEM, '01' )
    oStruFKF:SetProperty( 'FKF_INDSUS' , MVC_VIEW_ORDEM, '02' )
    oStruFKF:SetProperty( 'FKF_INDDEC' , MVC_VIEW_ORDEM, '03' )

    oStruFKF:AddField("FKF_DSCNAE" , "05", STR0026, STR0026 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//'Descri��o do CNAE'
    oStruFKF:AddField("FKF_DSCTRP" , "07", STR0027, STR0027 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descri��o do Tipo de Repasse"
    oStruFKF:AddField("FKF_DSCTSR" , "09", STR0027, STR0027 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descri��o do Tipo de Servi�o"
    oStruFKF:AddField("FKF_DSCCNO" , "11", STR0029, STR0029 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descri��o do CNO"
    oStruFKF:AddField("FKF_DSCBEM" , "13", STR0030, STR0030 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"2"/*cFolder*/)//"Descri��o do Bem"
    oStruFKF:AddField("FKF_DSCSRV" , "15", STR0031, STR0031 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"2"/*cFolder*/)//"Descri��o do Servi�o"

	If __lFNATREN	//Natureza de Rendimento
		oStruFKF:AddField("FKF_DSCNRN" , "17", STR0032, STR0032 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descri��o da Natureza do Rendimento"
	EndIf

    oStruFKF:SetProperty( 'FKF_CNAE'   , MVC_VIEW_ORDEM, '04' )
    oStruFKF:SetProperty( 'FKF_TPREPA' , MVC_VIEW_ORDEM, '06' )
    oStruFKF:SetProperty( 'FKF_TPSERV' , MVC_VIEW_ORDEM, '08' )
    oStruFKF:SetProperty( 'FKF_CNO'	   , MVC_VIEW_ORDEM, '10' )
    oStruFKF:SetProperty( 'FKF_CODBEM' , MVC_VIEW_ORDEM, '12' )
    oStruFKF:SetProperty( 'FKF_CODSER' , MVC_VIEW_ORDEM, '14' )

	If __lFNATREN	//Natureza de Rendimento
		oStruFKF:SetProperty( 'FKF_NATREN' , MVC_VIEW_ORDEM, '16' )
	EndIf

    oStruFKG:SetProperty( 'FKG_IDFKE'  , MVC_VIEW_ORDEM, '04' )
    oStruFKG:SetProperty( 'FKG_TPIMP'  , MVC_VIEW_ORDEM, '05' )
    oStruFKG:SetProperty( 'FKG_DEDACR' , MVC_VIEW_ORDEM, '06' )
    oStruFKG:SetProperty( 'FKG_APLICA' , MVC_VIEW_ORDEM, '07' )
    oStruFKG:SetProperty( 'FKG_TPATRB' , MVC_VIEW_ORDEM, '10' )
    oStruFKG:SetProperty( 'FKG_DESATR' , MVC_VIEW_ORDEM, '11' )
    oStruFKG:SetProperty( 'FKG_DESCR'  , MVC_VIEW_ORDEM, '12' )
    oStruFKG:SetProperty( 'FKG_VALOR'  , MVC_VIEW_ORDEM, '14' )
    oStruFKG:SetProperty( 'FKG_NUMPRO' , MVC_VIEW_ORDEM, '15' )
    oStruFKG:SetProperty( 'FKG_TPPROC' , MVC_VIEW_ORDEM, '16' )

    If __lINSPRE
        oStruFKG:SetProperty( 'FKG_INSPRE' , MVC_VIEW_ORDEM, '20' )
    EndIf    
    
    If __lFKG_CALCUL
        oStruFKG:SetProperty( 'FKG_CALCUL' , MVC_VIEW_ORDEM, '08' )
        oStruFKG:SetProperty( 'FKG_PERCEN' , MVC_VIEW_ORDEM, '09' )
        oStruFKG:SetProperty( 'FKG_BASECA' , MVC_VIEW_ORDEM, '13' )
    EndIf

    If __lFCGCSCP
        If __cAlias986 == 'SE1' 
            oStruFKF:RemoveField("FKF_CGCSCP")
        Else
            oStruFKF:SetProperty( 'FKF_CGCSCP', MVC_VIEW_PICT   , "@R 99.999.999/9999-99" ) 
	        oStruFKF:SetProperty( 'FKF_CGCSCP', MVC_VIEW_PICTVAR, "F986PcCgc('FKF_CGCSCP')" )
        EndIf 
    EndIf

    // Cria o objeto de View
    oView := FWFormView():New( )

    // Define qual o Modelo de dados ser� utilizado
    oView:SetModel( oModel )

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField( 'VIEW_FKF', oStruFKF, 'FKFMASTER' )

    //Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
    oView:AddGrid(  'VIEW_FKG', oStruFKG, 'FKGDETAIL' )
    oStruFKG:RemoveField( 'FKG_TITINS' )
    oStruFKG:RemoveField( 'FKG_APURIN' )
    If __lFKF_ORIINS
        oStruFKF:RemoveField( 'FKF_ORIINS' )
    EndIf
    
    //Remover campo FKF_PAGPIX no Contas a receber
    If __cAlias986 == 'SE1' .and. __lFKF_PAGPIX
        oStruFKF:RemoveField( 'FKF_PAGPIX' )
    EndIf

    //Remover campo FKF_RECPIX no Contas a Pagar
    If __lFKF_RECPIX .And. (__cAlias986 == 'SE2' .Or. !__TableF71 .Or. !__lFina890)
        oStruFKF:RemoveField( 'FKF_RECPIX' )
    EndIf

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox( 'SUPERIOR', 100 )

    oView:CreateFolder( 'FOLDER', 'SUPERIOR')
    oView:AddSheet('FOLDER','ABA_COMPL',STR0001)
    oView:AddSheet('FOLDER','ABA_REGRAS',STR0004)//'Complemento do Imposto X T�tulos'
    oView:CreateHorizontalBox( 'SUPERIOR1', 100, , , 'FOLDER', 'ABA_COMPL')
    oView:CreateHorizontalBox( 'SUPERIOR2', 100, , , 'FOLDER', 'ABA_REGRAS')

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView( 'VIEW_FKF', 'SUPERIOR1' )
    oView:SetOwnerView( 'VIEW_FKG', 'SUPERIOR2' )

    // Define campos que terao Auto Incremento
    oView:AddIncrementField( 'VIEW_FKG', 'FKG_ITEM' )

    // Liga a identificacao do componente
    oView:EnableTitleView('VIEW_FKG',STR0005)//'Complemento do Imposto'

    //Aqui � a defini��o de exibir dois campos por linha
    oView:SetViewProperty( "VIEW_FKF", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

    //adicionar botao Na tela ler pix
    If !isBlind()
        If __cAlias986 == 'SE2' .and. __lFKF_PAGPIX .and. (INCLUI .or. ALTERA)
            oView:AddUserButton(STR0052, 'CLIPS', {|oView| readBarcode()}, , ,)
        EndIf
    EndIf
    oView:EnableControlBar(.F.)

    //Habilita ou n�o a edi��o da Grid de Complemento de impostos (FKG)
    Fa986Fld(oView)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986Fld
N�o permite visualizar a folder FKG para titulos que nao seja o principal

@param oView - objeto View ativo

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------

Static Function Fa986Fld(oView)

    If !Fa986Folder("2") //Determina se aba deve ser exibida
        oView:SetOnlyView( 'VIEW_FKG' )   
    EndIf
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986Pos
P�s validacao do modelo 

@param oModel - objeto do model ativo

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static function Fa986Pos(oModel As Object) As Logical
    Local lRet          As Logical
    Local aSaveLine     As Array 
    Local aLnFKG        As Array
    Local oFKG          As Object
    Local nX            As Numeric
    Local nPos          As Numeric
    
    lRet        := .T.
    aSaveLine   := FWSaveRows()
    aLnFKG      := {}
    oFKG        := oModel:GetModel('FKGDETAIL')
    nX          := 0
    nPos        := 0

    //setar um valor no model, para nao ocorrer error log ao mudar somente a grid sem mudar o field
    If oModel:GetOperation() <> MODEL_OPERATION_DELETE .and.  oModel:GetOperation() <> MODEL_OPERATION_VIEW
        oModel:Setvalue("FKFMASTER","FKF_ALIAS",__cAlias986)
    EndIf

    //Valida��o do Inscri��o da Previd�ncia (FKG_INSPRE) em rela��o ao tipo de a��o informado (FKG_TPATRB)
    If __lINSPRE .and. lRet 
        For nX := 1 To oFKG:Length()
            oFKG:GoLine(nX)
            If !Empty(oFKG:GetValue('FKG_INSPRE')) .And. (Alltrim(oFKG:GetValue('FKG_TPATRB')) =="010" .or. ;
                Alltrim(oFKG:GetValue('FKG_TPATRB')) =="011" .or. ;
                Alltrim(oFKG:GetValue('FKG_TPATRB')) =="012")
                
                nPos:= ASCAN( aLnFKG, {|x|x == Alltrim(oFKG:GetValue('FKG_TPATRB')+oFKG:GetValue('FKG_INSPRE'))})
                
                If nPos > 0 
                    Help(,,"F986FKGDUPL",,STR0065,1,0,,,,,,{STR0066 +str(nX)+ STR0067})
                    lRet := .F.
                Else 
                    AADD( aLnFKG, Alltrim(oFKG:GetValue('FKG_TPATRB')+oFKG:GetValue('FKG_INSPRE')))            
                EndIf
            EndIf
        Next
    EndIf

    FWRestRows(aSaveLine)         

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986Conf
Bot�o confirma��o, para atualizar os valores dos impostos sem gravar os dados na tabela
pois estes dever�o ser gravados na confirma��o do titulo

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function Fa986Conf() As Logical
    Local oView 	    As Object
    Local oModel	    As Object
    Local lDel		    As Logical
    Local lRecalc       As Logical
    Local lYoN		    As Logical
    Local lCommit       As Logical
    Local lExecAuto     As Logical
    Local lBlind	    As Logical
    Local oHashREINF    As Object

    oView 	    := FwViewActive()
    oModel	    := FwModelActive()
    lDel	    := (__nOPER == MODEL_OPERATION_UPDATE)
    lRecalc     := .F.
    lYoN		:= .F.
    lCommit     := .F.
    lExecAuto   := FwIsInCallStack("F986ExAut")
    lBlind	    := IsBlind()
    oHashREINF  :=  Nil
   
    If __lFNATREN
        If Empty(oModel:GetValue("FKFMASTER", "FKF_NATREN")) .And. ( !Empty(FKF->FKF_NATREN) .Or. INCLUI )
            __lErase    := .T.
        EndIf
    EndIf
    
    IF FindFunction('FGetHashR')
        oHashREINF := FGetHashR()
    EndIf

    If (oView == NIL .or. oView:oModel:cId <> "FINA986") .and. (!lExecAuto .Or. FwIsInCallStack("J203UpdPix"))
        lCommit := .T.  // Commit do model por rotinas externas ( != de FINA040 e FINA050)
    Else
        lRecalc := lBlind .or. F986Recalc(oModel) //Verifica se deve haver o recalculo dos impostos ap�s manipilar a FKG
    EndIf

    If lRecalc
        If lBlind
            lYoN := .T.
        Else
            lYoN := MsgYesNo( STR0007, STR0008 ) //"Ao confirmar, caso tenha cadastrado alguma regra de impostos, o imposto ser� recalculado. Confirma?"//"Aten�?o"
        EndIf
        //No realiza a gravacao, s� guardo o model
        If lYoN
			If !FwIsInCallStack("F986ExAut")
				_cXml986 := oModel:GetXMLData( , , , , lDel, .T. )
			Endif

			// Alimenta lista HashMap com informa��es do t�tulo referentes ao EFD REINF
			If ValType(oHashREINF) == 'O'
				oHashREINF:Set("_ALTCOMPL",.T.) // Houve altera��o do Modelo
			EndIf

            If !lExecAuto
                __cXml986 := oModel:GetXMLData( , , , , lDel, .T. )
            Endif
            //atualiza a tela com os valores
            If __cAlias986 == "SE1"
                If M->E1_VALOR > 0
                    SA1->(dbSetOrder(1))
                    SA1->(msSeek(xFilial('SA1')+M->E1_CLIENTE+M->E1_LOJA))
                    fa040natur()
                EndIf
            ElseIf __cAlias986 == "SE2"
                If M->E2_VALOR > 0
                    SA2->(dbSetOrder(1))
                    SA2->(msSeek(xFilial('SA2')+M->E2_FORNECE+M->E2_LOJA))
                    FA050Natur()
                    __lAltImp := .T.
                EndIf
            EndIf
        EndIf
    ElseIf __lBrowse .or. lCommit
        If  __nOPER == MODEL_OPERATION_INSERT
            If __cAlias986 == "SE1"
                Fa986grava("SE1","FINA040")
            ElseIf __cAlias986 == "SE2"
                Fa986grava("SE2","FINA050")
            EndIf
        Else
            If oModel:VldData()
                If __lFKF_PAGPIX .and. __cAlias986 == "SE2" 
                    F986FPag()
                Endif

                FwFormCommit(oModel)
                If __lFKF_RECPIX .and. __cAlias986 == "SE1" .and. __TableF71 .and. __lFina890 
                    F986PJob()
                    __lGerF71   := .T.
                EndIf
                If __nOPER == MODEL_OPERATION_UPDATE 
                    If __cAlias986 == "SE2"
                        Fa986grava("SE2","FINA050")
                    ElseIf __cAlias986 == "SE1"
                        Fa986grava("SE1","FINA040")
                    EndIf          
                EndIf 
            Else
                cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[6])
                Help( ,,"FINA986GRV",,cLog, 1, 0 )
            Endif
            
            oModel:Deactivate()
            oModel:Destroy()
            oModel:= Nil
            oSubFKG := nil
        EndIf
    ElseIf !lExecAuto
        __cXml986 := oModel:GetXMLData( , , , , lDel, .T. )
    EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F986LimpaVar
Limpa as variaveis estaticas ao fim do processo de grava��o para criar um novo model

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------

Function F986LimpaVar()
    __cXml986 := ""
    __cAlias986 := ""
    __nOPER := 0
    If __oFKGBase != Nil
        __oFKGBase:Destroy()
        __oFKGBase := Nil
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986grava
Fun��o de grava��o do model chamada pelas rotinas de cadastro dos titulos a pagar/receber
@param cAliasC Informar SE1 para contas a receber e SE2 para contas a pagar
@param cOrigem Informar a rotina de origem do titulo

@return retorna .T. se grava��o estiver ok nas tabelas FKF e FKG
@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------

Function Fa986grava(cAliasC As Character, cOrigem As Character, lGeraPix As Logical) As Logical
    Local lRet          As Logical
    Local oModel        As Object
    Local oSubFKG       As Object
    Local nI            As Numeric
    Local cLog          As Character
    //para armazenar o valor do INSS calculado original
    Local nINSSTot 	    As Numeric
    Local nValInss	    As Numeric
	Local lCalcProc	    As Logical
    Local aArea		    As Array 
    Local lEspecie	    As Logical
    Local lMata103	    As Logical
    Local lMata461	    As Logical
    Local lExterno      As Logical
    Local cTipo         As Character
    Local cDocTEF       As Character
   	Local lFlagREINF    As Logical
    Local aListREINF    As Array 
	Local lFlagFKF	    As Logical
	Local oHashREINF    As Object
    Local lIRPFBaixa    As Logical
    //Grava��o Tabela FKW
    Local aDdoFKW       As Array
    Local aDadosFKW     As Array
    Local nValIrrf	    As Numeric    
    Local cChave        As Character
    Local cIdDoc        As Character
    Local cTpImp        As Character
    Local cNatRen       As Character
    Local nOperFkw      As Numeric
    Local lNatSImp      As Logical
    Local aPCC          As Array
    Local lIrfRetAnt    As Logical
    Local l460ACOMIT    As Logical   
    
    //Recriando as vari�veis no escopo da fun��o
    Private INCLUI := IIf(Type('INCLUI') == 'L', INCLUI, .F.)
    Private ALTERA := IIf(Type('ALTERA') == 'L', ALTERA, .F.)

    Default cOrigem  := "FINA050"
    Default lGeraPix := .T.

    lRet        := .T.
    oModel      := NIL
    oSubFKG     := NIL
    nI          := 0
    cLog        := ""
    nINSSTot 	:= 0
    nValInss	:= 0
	lCalcProc	:= .T.
    aArea		:= GetArea()
    lEspecie	:= .F.
    lMata103	:= .F.
    lMata461	:= .F.
    lExterno    := .F.
   	lFlagREINF  := .F.
    aListREINF  := {}
	lFlagFKF	:= FKF->(ColumnPos("FKF_REINF")) > 0
	oHashREINF  :=  Nil

    //Grava��o Tabela FKW
    aDdoFKW      := {}
    aDadosFKW    := {}
    nValIrrf	 := 0    
    cChave       := xFilial("SE2") + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
    cIdDoc       := FINGRVFK7('SE2', cChave) //-->FAZER O cChave
    cTpImp       := ""
    cNatRen      := ""
    nOperFkw     := 0
    lIRPFBaixa   := (SA2->A2_TIPO == 'F' .OR. (SA2->A2_TIPO == "J" .AND. SA2->A2_IRPROG == "1")) .AND. SA2->A2_CALCIRF == "2"
    lNatSImp     := Fa986GerI( SE2->E2_NATUREZ, SE2->E2_FORNECE, SE2->E2_LOJA)
    aPCC         := Array(5)
    lIrfRetAnt   := .F.
    l460ACOMIT   := FwIsInCallStack("F460ACOMMIT")
    
    If INCLUI
        nOperFkw := 3
    ElseIf ALTERA
        nOperFkw := 4
    EndIf

    __lGeraPix := lGeraPix 
    
    if !IsInCallStack("Fa986Conf")      
        F986IniVar(cAliasC,.F.)
    endif
    IF FindFunction('FGetHashR')
        oHashREINF := FGetHashR()
    EndIf

    lMata103	:= alltrim(cOrigem) $ "MATA103|MATA100|"
    lMata461	:= alltrim(cOrigem) $ "MATA461|MATA460"
    lExterno    := Iif(M->E1_TIPO <> Nil .Or. M->E2_TIPO <> Nil, .F.,.T.)
    __lBrowse   := IIf(lExterno, .T., __lBrowse)
    
    DbSelectArea("CCF")
    __cAlias986 := cAliasC

    If cAliasC == "SE2"
        cChave := SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" +;
        SE2->E2_FORNECE+ "|" + SE2->E2_LOJA

    ElseIf cAliasC == "SE1"
        cChave := SE1->E1_FILIAL + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" +;
        SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
    EndIf

    cIdDoc := FINGRVFK7(cAliasC, cChave)

    If Valtype(__cXml986) == "C"  .and. !Empty(__cXml986)

        oModel := FwLoadModel("FINA986")
        oModel:LoadXMLData(__cXml986)

        oModel:SetValue("FKFMASTER","FKF_IDDOC",cIdDoc)
        oSubFKG:= oModel:GetModel("FKGDETAIL")

        For nI := 1 To oSubFKG:Length()
            oSubFKG:GoLine(nI)
            lCalcProc := .T.
            If oSubFKG:GetValue("FKG_TPIMP") == 'INS'
                If !oSubFKG:IsDeleted( nI ) .and. (oSubFKG:IsUpdated() .or.  (oSubFKG:IsInserted() .and. !Empty(oSubFKG:GetValue("FKG_IDFKE")) ))
                    oSubFKG:SetValue("FKG_IDDOC",cIdDoc)
                    If !Empty(oSubFKG:GetValue("FKG_NUMPRO")) .and. CCF->(DBSeek(xFilial("CCF") + oSubFKG:GetValue("FKG_NUMPRO")))
                        lCalcProc := CCF->CCF_RESACA<>"3"
                    Endif
                    If !lCalcProc
                        oSubFKG:LoadValue("FKG_APURIN", "2")
                    Else
                        oSubFKG:LoadValue("FKG_APURIN", "1")
                    EndIf
                EndIf
            EndIf
        Next nI
    Else//grava valores padrao da FKF caso o usuario nao entrou na tela de complemento do titulo
        FKF->(DBSetOrder(1))
        If FKF->(DBSeek(xFilial("FKF") + cIdDoc ))
            nOpc := MODEL_OPERATION_UPDATE
        Else
            nOpc := MODEL_OPERATION_INSERT
        EndIf
        oModel := FwLoadModel("FINA986")
        oModel:SetOperation(nOpc)
        oModel:Activate()
        If !__lBrowse
            __lGeraPix := .T.
        EndIf
        
        oModel:SetValue("FKFMASTER","FKF_IDDOC",cIdDoc)
        
        If l460ACOMIT .And. nOpc == MODEL_OPERATION_INSERT
            __nFINPIX9 := SuperGetMV("MV_FINPIX9", .F., 1)
            
            If __lTPIConf == Nil
                __lTPIConf := FindFunction("APIPIXOn") .And. APIPIXOn()
            EndIf        
            
            If !__lTPIConf .And. __nFINPIX9 == 2
                oModel:SetValue("FKFMASTER","FKF_RECPIX", "2")
            EndIf
        EndIf
        
        If lMata103			//NF Entrada
            //aguardano MAT informar os campos da nota de entrada

        ElseIf lMata461		//NF Saida
            If __lSF2_CNO
                oModel:SetValue("FKFMASTER","FKF_CNO",SF2->F2_CNO)
            EndIf
        EndIf

    EndIf

	//gravacao do valor original dos impostos sem a alteracao do complemento (essa informacao sera enviada ao REINF)
	If !lMata103 .and. !lMata461 
        If cAliasC == "SE2" .AND. !(alltrim(SE2->E2_ORIGEM) $ "MATA103|MATA100|")
            SA2->(DBSetOrder(1))
            SA2->(DBSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA ))

            //INSS
            If SA2->A2_TIPO == "F" //Para pessoa fisica verifico o limite de deducao no mes
                nValInss := FCalcInsPF(SE2->E2_BASEINS, ,@nINSSTot,.F.,0,.T.,SE2->E2_EMISSAO,SE2->E2_VENCREA)
            Else
                nValInss := FCalcInsPJ(SE2->E2_BASEINS, ,@nINSSTot,.F.)
            Endif
            oModel:SetValue("FKFMASTER","FKF_ORIINS",nValInss)

            If __lFNATREN 
                cNatRen:= oModel:GetValue("FKFMASTER","FKF_NATREN")
                //Grava��o Tabela FKW para t�tulos avulsos.
                If !Empty(cNatRen)
                    // Grava��o da Base n�o retida do IR
                    // Preciso saber o valor de imposto n�o retido
                    // Para depois calcular a Base N�O Retida
                    
                    If lNatSImp
                        If !lIRPFBaixa
                            nValIrrf := Fa986IrOri(@lIrfRetAnt)
                        EndIf
                        //PIS, COFINS E CSLL
                        If !__lEmpPub
                            aPCC := NewMinPcc(SE2->E2_EMISSAO, xMoeda( SE2->E2_BASEPIS, SE2->E2_MOEDA, 1, SE2->E2_EMISSAO, 3, SE2->E2_TXMOEDA ), SE2->E2_NATUREZ, "P", SE2->(E2_FORNECE + E2_LOJA),,,,,,,,,,,,.F.)
                        Else
                            aPCC := F986PccPub(SE2->E2_BASEPIS,SE2->E2_BASECOF,SE2->E2_BASECSL,lIrfRetAnt,@nValIrrf)
                        EndIf

                        If Fa986GerI( SE2->E2_NATUREZ, SE2->E2_FORNECE, SE2->E2_LOJA, "IRF" )
                            Fa986FKW(cIdDoc, "IRF", cNatRen, nValIrrf,SE2->E2_IRRF, SE2->E2_BASEIRF, oModel, oSubFKG, @aDadosFKW, "1")
                        EndIf   

                        
                        If Len(aPCC) > 0
                            // Grava��o da Base n�o retida do PCC
                            // Preciso saber o valor de imposto n�o retido
                            // Para depois calcular a Base N�O Retida
                            // Grava��o para a suspens�o total ou parcial do imposto                 
                            If Fa986GerI( SE2->E2_NATUREZ, SE2->E2_FORNECE, SE2->E2_LOJA, "PIS" ) 
                                Fa986FKW(cIdDoc, "PIS", cNatRen, aPCC[2],SE2->E2_PIS, SE2->E2_BASEPIS, oModel, oSubFKG, @aDadosFKW, "1")
                            EndIf
                            If Fa986GerI( SE2->E2_NATUREZ, SE2->E2_FORNECE, SE2->E2_LOJA, "COF" )
                                Fa986FKW(cIdDoc, "COF", cNatRen, aPCC[3],SE2->E2_COFINS, SE2->E2_BASECOF, oModel, oSubFKG, @aDadosFKW, "1")
                            EndIf
                            If Fa986GerI( SE2->E2_NATUREZ, SE2->E2_FORNECE, SE2->E2_LOJA, "CSL" )
                                Fa986FKW(cIdDoc, "CSL", cNatRen, aPCC[4],SE2->E2_CSLL, SE2->E2_BASECSL, oModel, oSubFKG, @aDadosFKW, "1")
                            EndIf
                        Endif
                    Else
                        Fa986FKW(cIdDoc, "SEMIMP", cNatRen, 0,0, SE2->E2_VALOR, oModel, oSubFKG, @aDadosFKW, "1")
                    EndIf

                    If FindFunction("F070Grv") .And. nOperFkw>0
                        F070Grv(aDadosFKW,nOperFkw,"1")
                    EndIf
                Else 
                    //Tratamento para os t�tulos que tem FKW, mas tiveram a natureza alterada para uma que n�o retem impostos.
                    If ALTERA
                        If __lEDNTREN
                            cNatRen := GetAdvFVal("SED","ED_NATREN",xFilial("SED") + SE2->E2_NATUREZ )
                            If !Empty(cNatRen) .And. F986NatRen("SE2", .T.,, .F.)
                                oModel:LoadValue("FKFMASTER","FKF_NATREN",cNatRen)
                            EndIf
                        EndIf
                        If FindFunction("F070Grv")
                            DbSelectArea("FKW")
                            FKW->(DbSetOrder(2)) //FKW_FILIAL+FKW_IDDOC+FKW_CARTEI+FKW_TPIMP+FKW_NATREN
                            If FKW->(DBSeek(xFilial("FKW")+cIdDoc+"1"))  
                                aAdd(aDdoFKW,{xFilial("FKW"),cIdDoc})        
                                F070Grv(aDdoFKW,5,"1")
                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf            
        ElseIf cAliasC == "SE1"
            If !__lBrowse
                SED->(DBSetOrder(1))
                If SED->(DBSeek(xFilial("SED") + SE1->E1_NATUREZ  ))
                    nValInss := CalcINSS(SE1->E1_BASEINS, .F.)
                EndIf
                oModel:SetValue("FKFMASTER","FKF_ORIINS",nValInss)
            EndIf
            If !(alltrim(SE1->E1_ORIGEM) $ "MATA460") .And. __lFNATREN 
                cNatRen:= oModel:GetValue("FKFMASTER","FKF_NATREN")
                //Grava��o Tabela FKW para t�tulos avulsos.
                If !Empty(cNatRen)
                    If Fa986GerI( SE1->E1_NATUREZ, SE1->E1_CLIENTE, SE1->E1_LOJA, "IRF" )
                        If __lBrowse
                            RegToMemory("SE1",.F.,.F.)
                        EndIf
                        nValIrrf := F040CalcIr(SE1->E1_BASEIRF,,.T.,,,,,, .F.)
                        Fa986FKW(cIdDoc, "IRF", cNatRen, nValIrrf,SE1->E1_IRRF, SE1->E1_BASEIRF, oModel, oSubFKG, @aDadosFKW, "2")
                    EndIf

                    If FindFunction("F070Grv") .And. nOperFkw>0
                        F070Grv(aDadosFKW,nOperFkw,"2")
                    EndIf
                Else 
                    //Tratamento para os t�tulos que tem FKW, mas tiveram a natureza alterada para uma que n�o retem impostos.
                    If ALTERA
                        If __lEDNTREN
                            cNatRen := GetAdvFVal("SED","ED_NATREN",xFilial("SED") + SE1->E1_NATUREZ )
                            If !Empty(cNatRen) .And. F986NatRen("SE1", .T.,, .F.)
                                oModel:LoadValue("FKFMASTER","FKF_NATREN",cNatRen)
                            EndIf
                        EndIf 
                        If FindFunction("F070Grv")
                            DbSelectArea("FKW")
                            FKW->(DbSetOrder(2)) //FKW_FILIAL+FKW_IDDOC+FKW_CARTEI+FKW_TPIMP+FKW_NATREN
                            If FKW->(DBSeek(xFilial("FKW")+cIdDoc+"2"))  
                                aAdd(aDdoFKW,{xFilial("FKW"),cIdDoc})        
                                F070Grv(aDdoFKW,5,"2")
                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf

    If __lFKFEspec .and. __lF040Espec .and. !__lBrowse
        lEspecie := F040Espec()
        oModel:SetValue("FKFMASTER","FKF_ESPEC",IIF(lEspecie,"S","N"))
    EndIf

    // Lista HashMap com Informa��es referentes ao REINF
    If lFlagFKF .And. ValType(oHashREINF) == 'O' .And. oHashREINF:List(aListREINF) .And. oModel:GetValue("FKFMASTER","FKF_REINF")=="1"
        
		/* As regras abaixo definem as situacoes onde o t�tulo necessite ser reenviado ao TAF:
			1) Para t�tulos cujo seu valor financeiro (E2_VALOR) foi alterado;
			2) Para titulos cuja sua natureza financeira (E2_NATUREZA) foi alterada;
			3) Quando houver qualquer altera��o na aba 'Complemento do Imposto x Titulos' for�ando o recalculo dos impostos informados;
        */
		nI := 1
        While !lFlagREINF .And. nI <= Len(aListREINF)
            If aListREINF[nI,1] == "_VALTIT"
                lFlagREINF := aListREINF[nI,2] != SE2->E2_VALOR // Valor do T�tulo
            ElseIf aListREINF[nI,1] == "_NATFIN"
                lFlagREINF := aListREINF[nI,2] != SE2->E2_NATUREZ // Natureza Financeira
            ElseIf aListREINF[nI,1] == "_ALTCOMPL"
                lFlagREINF := aListREINF[nI,2] // Complemento de Imposto
            EndIf
            nI++
        EndDo

        // Limpa FLAG de Exporta��o M�dulo TAF
        If lFlagREINF
			oModel:SetValue("FKFMASTER","FKF_REINF", "2")
        EndIf

    EndIf

    If oModel:VldData()
        lRet	 := .T.
        
        If __lFKF_PAGPIX .and. __cAlias986 == "SE2" .And. !__lBrowse
            F986FPag()
        Endif
        
        FwFormCommit(oModel)

        If lFlagREINF .and. !IsBlind()
			Aviso(STR0035,STR0036,{ "Ok" }) // "O status de integra��o (flag) foi ajustado para que o titulo possa ser reenvidado ao TAF"
        EndIf

        cTipo   := IIf(__lBrowse, SE1->E1_TIPO,     M->E1_TIPO)
        cDocTEF := IIf(__lBrowse, SE1->E1_DOCTEF,   M->E1_DOCTEF)
        
        If __lFKF_RECPIX .and. __cAlias986 == "SE1" .and. __TableF71 .and. __lFina890 .And. !F986PIXLj(cTipo, cDocTEF)
            F986PJob()
        Endif
    Else
        lRet := .F.
        cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
        cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
        cLog += cValToChar(oModel:GetErrorMessage()[6])
        Help( ,,"FINA986GRV",,cLog, 1, 0 )
    Endif

    oModel:Deactivate()
    oModel:Destroy()
    oModel:= Nil
    oSubFKG := nil

    F986LimpaVar()

    RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986excl
Fun��o de exclusao do model tabelas FKF e FKG chamada pelas rotinas de cadastro dos titulos a pagar/receber
Deve estar posicionado no titulo.
@param cAliasC Informar SE1 para contas a receber e SE2 para contas a pagar

@return retorna .T. se exclus�o estiver ok nas tabelas FKF e FKG

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------

Function Fa986excl(cAliasC As Character) As Logical
    Local lRet As Logical
    Local oModel As Object
    Local cIdDoc As Character
    Local cLog As Character
    Local aDdFKW As Array
    Local cCartei As Character

    Default cAliasC := ""

    lRet := .T.
    oModel := NIL
    cIdDoc = ""
    cLog := ""
    aDdFKW := {} 
    cCartei := "1" 

    //Recriando as vari�veis no escopo da fun��o
    Private INCLUI := IIf(Type('INCLUI') == 'L', INCLUI, .F.)
    Private ALTERA := IIf(Type('ALTERA') == 'L', ALTERA, .F.)

    If !IsInCallStack("Fa986Conf")  .And. !IsInCallStack("MATA521A")      
        F986IniVar(cAliasC,.F.)
    EndIf

    If cAliasC == "SE2"
        cChave := SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" +;
        SE2->E2_FORNECE+ "|" + SE2->E2_LOJA
        cCartei := "1"
    ElseIf cAliasC == "SE1"
        cChave := SE1->E1_FILIAL + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" +;
        SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
        cCartei := "2"
    EndIf

    cIdDoc := FINGRVFK7(cAliasC, cChave)
    FKF->(DBSetOrder(1))
    If FKF->(DBSeek(xFilial("FKF") + cIdDoc ))

        //Exclui os registros da FKW antes da FKF (FKW filha da FKF)
        If __lFNATREN .and. FindFunction("F070Grv")
            DbSelectArea("FKW")
            FKW->(DbSetOrder(2)) //FKW_FILIAL+FKW_IDDOC+FKW_CARTEI+FKW_TPIMP+FKW_NATREN
            If FKW->(DBSeek(xFilial("FKW")+cIdDoc+cCartei)) 
                AAdd(aDdFKW,{xFilial("FKW"),cIdDoc})
                F070Grv(aDdFKW,5,cCartei)       
            EndIf
        Endif

        oModel := FwLoadModel("FINA986")
        oModel:SetOperation(MODEL_OPERATION_DELETE)
        oModel:Activate()
        If oModel:VldData()
            lRet	 := .T.
            FwFormCommit(oModel)
        Else
            lRet := .F.
            cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
            cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
            cLog += cValToChar(oModel:GetErrorMessage()[6])
            Help( ,,"FINA986DEL",,cLog, 1, 0 )
        Endif

        oModel:Deactivate()
        oModel:Destroy()
        oModel:= Nil
        F986LimpaVar()
    EndIf
    
    FwFreeArray(aDdFKW)    

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986regra
Retorna o valor a ser deduzido/acrescentado ao imposto/base.
Chamado pelas rotinas de calculo de impostos

@param cAliasC Informar SE1 para contas a receber e SE2 para contas a pagar
@param cImposto Informar o c�digo do imposto. Atualmente ser� implementado somente para o INSS
@param cTpDed Informar "1" para buscar as regras na base, "2" para buscar as regras no valor

@return nValImp retorna o valor calculado a ser deduzido/acrescido da base ou valor do imposto

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------

Function Fa986regra(cAliasC As Character, cImposto As Character, cTpDed As Character) As Numeric

Local oModel    As Object
Local oSubFKG   As Object
Local cIdDoc    As Character
Local nValImp   As Numeric
Local nI        As Numeric
Local cChave    As Character
Local nLin      As Numeric
Local lRet      As Logical
Local lCalcProc As Logical
Local aArea     As Array
Local aAreaSE2	As Array
Local aAreaSA2	As Array
Local cQuery	As Character
Local cFilFKG	As Character
Local lFinaBx	As Logical

// Recriando as vari�veis no escopo da fun��o
// N�o posso efetuar a tipagem aqui, sen�o inicializam com valor default False
Private INCLUI := IIf(Type('INCLUI') == 'L', INCLUI, .F.)
Private ALTERA := IIf(Type('ALTERA') == 'L', ALTERA, .F.)

cIdDoc      := ""
nValImp     := 0
nI          := 0
cChave      := ""
nLin        := 1
lRet        := .T.
lCalcProc   := .T.
aArea       := GetArea()
aAreaSE2	:= SE2->(GetArea())
aAreaSA2	:= SA2->(GetArea())
cQuery	    := ""
cFilFKG	    := ""
lFinaBx	    := FwIsInCallStack("FINA080") .OR. FwIsInCallStack("FINA241") .OR. FwIsInCallStack("FINA090") .OR. FwIsInCallStack("FINA091") .OR. ;
               FwIsInCallStack("FINA430") .OR. FwIsInCallStack("FINA590") .OR. FwIsInCallStack("FINA300") .OR. FwIsInCallStack("FINA340") .OR. ;
               FwIsInCallStack("FINA450") 

DEFAULT cAliasC := ""
DEFAULT cImposto := ""
DEFAULT cTpDed := ""

DbSelectArea("CCF")
// Se for inclusao e tem model, se for alteracao ou rotinas de baixa
If ( (INCLUI .and. !Empty(__cXml986)) .or. ALTERA ) .OR. lFinaBx

    If Valtype(__cXml986) == "C"  .and. !Empty(__cXml986)
        oModel := FwLoadModel("FINA986")
        oModel:LoadXMLData(__cXml986)
    Else
        If cAliasC == "SE2"
            cChave := SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" +;
            SE2->E2_FORNECE+ "|" + SE2->E2_LOJA

        ElseIf cAliasC == "SE1"
            cChave := SE1->E1_FILIAL + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" +;
            SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
        EndIf
        cIdDoc := FINGRVFK7(cAliasC, cChave)
        FKF->(DBSetOrder(1))
        If !lFinaBx .and. FKF->(DBSeek(xFilial("FKF") + cIdDoc ))
            oModel := FwLoadModel("FINA986")
            oModel:SetOperation( MODEL_OPERATION_VIEW ) //visualizacao
            oModel:Activate()
        Else
            lRet:= .F.
        EndIf

        If lFinaBx
                
            lRet	:= .F.
            cQuery	:= ""
            cFilFKG	:= xFilial("FKF")

            If __oSttFKG == NIL

                cQuery := " SELECT ( ACRES.FKG_VALOR - DEDUZ.FKG_VALOR ) VALOR "
                cQuery += " FROM ( SELECT ISNULL( SUM(FKG_VALOR),0) FKG_VALOR "
                cQuery += 		 " FROM " + RetSQLName("FKG") + " FKG "
                cQuery += 		 " WHERE FKG.FKG_FILIAL = ? "
                cQuery +=				" AND FKG.FKG_IDDOC = ? "
                cQuery +=				" AND FKG.FKG_APURIN <> '2' "
                cQuery +=				" AND FKG.FKG_TPIMP = ? "
                cQuery +=				" AND FKG.FKG_APLICA = ? "
                cQuery +=				" AND FKG_DEDACR = '2' " // soma
                cQuery +=				" AND FKG.D_E_L_E_T_ = ' ' ) ACRES, "
                cQuery +=		  " ( SELECT ISNULL( SUM(FKG_VALOR),0) FKG_VALOR "
                cQuery +=			" FROM " + RetSQLName("FKG") + " FKG "
                cQuery +=			" WHERE	FKG.FKG_FILIAL = ? "
                cQuery +=					" AND FKG.FKG_IDDOC = ? "
                cQuery +=					" AND FKG.FKG_APURIN <> '2' "
                cQuery +=					" AND FKG.FKG_TPIMP = ? "
                cQuery +=					" AND FKG.FKG_APLICA = ? "
                cQuery +=					" AND FKG_DEDACR = '1' " // subtra��o
                cQuery +=					" AND FKG.D_E_L_E_T_ = ' ' ) DEDUZ "
                
                cQuery := ChangeQuery(cQuery)
                __oSttFKG := FWPreparedStatement():New(cQuery)
            EndIf
            
            __oSttFKG:SetString( 1, cFilFKG	)
            __oSttFKG:SetString( 2, cIdDoc	)
            __oSttFKG:SetString( 3, cImposto)
            __oSttFKG:SetString( 4, cTpDed	)
            __oSttFKG:SetString( 5, cFilFKG	)
            __oSttFKG:SetString( 6, cIdDoc	)
            __oSttFKG:SetString( 7, cImposto)
            __oSttFKG:SetString( 8, cTpDed	)

            cQuery := __oSttFKG:GetFixQuery()

            nValImp := MpSysExecScalar( cQuery,"VALOR" )
        Else
			FKF->( DBSetOrder(1) )
			If FKF->( DBSeek( xFilial("FKF") + cIdDoc ) )
				oModel := FwLoadModel("FINA986")
				oModel:SetOperation( MODEL_OPERATION_VIEW ) //visualizacao
				oModel:Activate()
			Else
				lRet:= .F.
			EndIf            
        EndIf
    EndIf
    If lRet
        oSubFKG:= oModel:GetModel("FKGDETAIL")
        nLin := oSubFKG:GetLine()
        For nI := 1 To oSubFKG:Length()
            oSubFKG:GoLine(nI)
            //se for processo, nao influenciar no calculo do imposto
            If !Empty(oSubFKG:GetValue("FKG_NUMPRO")) .and. CCF->(DbSeek(xFilial("CCF") + oSubFKG:GetValue("FKG_NUMPRO")))
                If INCLUI
                    lCalcProc := CCF->CCF_RESACA<>"3"
                Else
                    lCalcProc := oSubFKG:GetValue("FKG_APURIN")<>"2"
                EndIf
            Else
                lCalcProc := .T.
            EndIf
            If lCalcProc .AND. !oSubFKG:IsDeleted( nI ) .and. Alltrim(oSubFKG:GetValue("FKG_TPIMP")) == cImposto .and. oSubFKG:GetValue("FKG_APLICA") == cTpDed
                If oSubFKG:GetValue("FKG_DEDACR") == "2" //Acrescimo
                    nValImp += oSubFKG:GetValue("FKG_VALOR")
                ElseIf oSubFKG:GetValue("FKG_DEDACR") == "1"	//Deduz
                    nValImp -= oSubFKG:GetValue("FKG_VALOR")
                EndIf
            EndIf

        Next nI

    EndIf
EndIf

If oModel != NIL
    oModel:Deactivate()
    oModel:Destroy()
    oModel:= Nil
    oSubFKG:= Nil
Endif

RestArea(aAreaSA2)
RestArea(aAreaSE2)
RestArea(aArea)
FwFreeArray(aAreaSA2)
FwFreeArray(aAreaSE2)
FwFreeArray(aArea)

Return nValImp

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986Numpr
Fun��o utilizada no X3_WHEN do campo  FKG_NUMPRO para habilitar este campo somente
se a regra escolhida for de processo judicial

@return lRet Retorna .T. se campo pode ser liberado para edi��o

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function Fa986Numpr() As Logical
Local lRet := .T.
Local oModel := FWModelActive()
Local oSubFKG:= oModel:GetModel("FKGDETAIL")

If Alltrim(oSubFKG:GetValue("FKG_TPATRB")) != "004"
    lRet := .F.
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986FilFKE
Filtro da consulta padr�o FKE para retornar as regras somente da carteira a pagar ou receber ou todas

@return cFiltro Retorna o filtro SQL

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function F986FilFKE() As Character
Local cFiltro := ""
If __cAlias986 == "SE2"
    cFiltro := "@FKE_CARTEI IN ('1','3')"
Else
    cFiltro := "@FKE_CARTEI IN ('2','3')"
EndIf
Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} F986VlFke
X3_valid do campo FKG_IDFKE para validar se a regra de imposto escolhida � v�lida para a carteira

@return lRet Retorna .T. se permite selecionar esta regra para a carteira

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
//X3_valid do campo FKG_IDFKE
Function F986VlFke() As Logical
Local lRet := .F.
Local aArea := GetArea()

dbSelectArea("FKE")
FKE->(dbSetOrder(1))
If dbSeek(xFilial("FKE")+ M->FKG_IDFKE)
    If __cAlias986 == "SE2"
        lRet := FKE->FKE_CARTEI $ '1|3'
    Else
        lRet := FKE->FKE_CARTEI $ '2|3'
    EndIf
EndIf

If !lRet
    Alert(STR0009)//"Complemento do imposto n�o v�lido para esta carteira."
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986VlVal
X3_VALID do campo FKG_VALOR para n�o permitir incluir nas regras, um valor que seja maior a base ou valor calculado

@return lRet Retorna .T. se permite selecionar esta regra para a carteira

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
//X3_VALID do campo FKG_VALOR
Function F986VlVal() As Logical
Local lRet := .T.

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986IniNu
Funcao para inicializar o valor do campo FKG_NUMPRO para o FKG_TPPROC

@since  31/05/2017
@version P11
/*/
//-------------------------------------------------------------------
Function F986IniNu() As Character
Local cRet := ""
Local oModel := FwModelActive()
Local oModFKG

If !INCLUI .and. oModel != NIL
    oModFKG := oModel:GetModel("FKGDETAIL")
    If oModFKG:length()== 0
        DbSelectArea("CCF")
        CCF->(DbSetorder(1))
        If CCF->(DBSeek(xFilial("CCF") + FKG->FKG_NUMPRO))
            cRet:= CCF->CCF_TIPO
        Endif
    EndIf
Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986IniCed
Funcao para inicializar o valor do campo FKF_CEDNOM

@since  31/05/2017
@version P12
/*/
//-------------------------------------------------------------------
Function F986IniCed() As Character

    Local aAreaSA2 := {}
    Local cRet := ""
    Local oModel := FwModelActive()
    Local oModFKF

    If !INCLUI .and. oModel != NIL
        oModFKF := oModel:GetModel("FKFMASTER")
        If !Empty(oModFKF:GetValue('FKF_CEDENT')) .And. !Empty(oModFKF:GetValue('FKF_LOJACE'))
            aAreaSA2 := SA2->(GetArea())
            SA2->(DbSetorder(1))
            If SA2->(DBSeek(xFilial("SA2") + M->(FKF_CEDENT+FKF_LOJACE) ) )
                cRet:= SA2->A2_NOME
            Endif
            SA2->(RestArea(aAreaSA2))
        EndIf
    Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986DesIn
Funcao para inicializar a descri��o complementar do cadastro do complemento

@since  31/05/2017
@version P11
/*/
//-------------------------------------------------------------------
Function F986DesIn() As Character

Local cRet := ""
Local oModel := FwModelActive()
Local oModFKG

If !INCLUI .and. oModel != NIL
    oModFKG := oModel:GetModel("FKGDETAIL")
    If oModFKG:length()== 0
        cRet:=POSICIONE("SX5",1,XFILIAL("SX5")+"0D"+FKG->FKG_TPATRB,"X5_DESCRI")
    EndIf
Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986FkeGt
Funcao gatilhar dados do complemento de imposto

@since  31/05/2017
@version P11
/*/
//-------------------------------------------------------------------
Function F986FkeGt() As Character

    Local oModel    As Object
    Local oSubFKG   As Object
    Local cRet 	    As Character
    Local nBaseDep  As Numeric
    Local nBasTit   As Numeric

    oModel   := FwModelActive()
    oSubFKG  := oModel:GetModel("FKGDETAIL")
    cRet 	 := ""
    nBaseDep := GetMV("MV_TMSVDEP",,0)
    nBasTit  := 0

    DbSelectArea("FKE")
    FKE->(DbSetorder(1))

    If FKE->(DBSeek(xFilial("FKE") + oSubFKG:GetValue("FKG_IDFKE")))
        oSubFKG:SetValue("FKG_TPIMP",FKE->FKE_TPIMP  )
        oSubFKG:SetValue("FKG_DEDACR",FKE->FKE_DEDACR )
        oSubFKG:SetValue("FKG_APLICA",FKE->FKE_APLICA )
        oSubFKG:SetValue("FKG_TPATRB",FKE->FKE_TPATRB )
        
        If __lFKG_CALCUL
            oSubFKG:SetValue("FKG_CALCUL",FKE->FKE_CALCUL )
            oSubFKG:SetValue("FKG_PERCEN",FKE->FKE_PERCEN )
            oSubFKG:LoadValue("FKG_BASECA",0)
        EndIf
        
        oSubFKG:SetValue("FKG_DESATR",POSICIONE("SX5",1,XFILIAL("SX5")+"0D"+FKE->FKE_TPATRB,"X5_DESCRI")  )
        
        If AllTrim(FKE->FKE_TPATRB) == '024'
            oSubFKG:SetValue("FKG_VALOR",nBaseDep)
        Else
            oSubFKG:SetValue("FKG_VALOR",0)
        EndIf
        
        oSubFKG:LoadValue("FKG_NUMPRO",SPACE(TAMSX3("FKG_NUMPRO")[1]))
        oSubFKG:LoadValue("FKG_TPPROC",SPACE(TAMSX3("FKG_TPPROC")[1]))
        
        If __lFCODDEP //Verifica se tem o dicion�rio do REINF Bloco 40
            oSubFKG:LoadValue("FKG_CODDEP",SPACE(TAMSX3("FKG_CODDEP")[1]))
            If !("INSS" $ oSubFKG:GetValue("FKG_TPIMP"))

                //Contas a Pagar
                If FKE->FKE_CARTEI == '1' .And. ( !("IRF" $ oSubFKG:GetValue("FKG_TPIMP")) .Or.;
                    (("IRF" $ oSubFKG:GetValue("FKG_TPIMP")) .And. FKE->FKE_CLASSI != '2') )
                    
                    Do Case
                        Case ("IRF" $ oSubFKG:GetValue("FKG_TPIMP"))
                            nBasTit := M->E2_BASEIRF
                        Case ("COF" $ oSubFKG:GetValue("FKG_TPIMP"))
                            nBasTit := M->E2_BASECOF
                        Case ("CSL" $ oSubFKG:GetValue("FKG_TPIMP"))
                            nBasTit := M->E2_BASECSL
                        OtherWise
                            nBasTit := M->E2_BASEPIS
                    EndCase
                    
                    nBasTit := Round(NoRound(xMoeda(nBasTit,M->E2_MOEDA,1,M->E2_EMISSAO,__nCasDec,M->E2_TXMOEDA),,__nCasDec+1),2)
                    oSubFKG:SetValue("FKG_VALOR", nBasTit)

                //Contas a Receber
                ElseIf FKE->FKE_CARTEI == '2' .And. "IRF" $ oSubFKG:GetValue("FKG_TPIMP") .And. FKE->FKE_CLASSI == '3'
                    nBasTit := Round(NoRound(xMoeda(M->E1_BASEIRF,M->E1_MOEDA,1,M->E1_EMISSAO,__nCasDec,M->E1_TXMOEDA),,__nCasDec+1),2)
                    oSubFKG:SetValue("FKG_VALOR", nBasTit)
                EndIf
            EndIf
        EndIf
    Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986CcfGt
Funcao gatilhar descri��o do tipo de processo

@since  31/05/2017
@version P11
/*/
//-------------------------------------------------------------------
Function F986CcfGt() As Character

    Local oModel    As Object
    Local oSubFKG   As Object
    Local cNumPro   As Character
    Local cTipoImp  As Character
    Local lRet 	    As Logical
    Local cRet 	    As Character

    oModel := FwModelActive()
    oSubFKG := oModel:GetModel("FKGDETAIL")
    cNumPro := oSubFKG:GetValue("FKG_NUMPRO")
    cTipoImp := Alltrim( oSubFKG:GetValue("FKG_TPIMP") )
    lRet 	:= .F.
    cRet 	:= ""

    DbSelectArea("CCF")
    CCF->(DbSetorder(1))

    If CCF->(DBSeek(xFilial("CCF")+cNumPro))
        
        oSubFKG:SetValue( "FKG_TPPROC",CCF->CCF_TIPO )
        
        While !lRet .And. xFilial("CCF")+cNumPro == CCF->(CCF_FILIAL+CCF_NUMERO)
            
            If cTipoImp == "INSS" .And. CCF->CCF_TRIB $ "1|2"
                lRet := .T.
            Elseif cTipoImp == "PIS" .And. CCF->CCF_TRIB == "7"
				lRet := .T.
			Elseif cTipoImp == "COF" .And. CCF->CCF_TRIB == "8"
				lRet := .T.		
			Elseif cTipoImp == "IRF" .And. CCF->CCF_TRIB == "9"
				lRet := .T.
			Elseif cTipoImp == "CSL" .And. CCF->CCF_TRIB == "A"
				lRet := .T.
			EndIf

            If lRet
                oSubFKG:SetValue("FKG_CODSUS",CCF->CCF_INDSUS)
            EndIf

            CCF->(DbSkip())
        EndDo
    Else
        oSubFKG:SetValue( "FKG_TPPROC",CriaVar("FKG_TPPROC") )
        oSubFKG:SetValue( "FKG_CODSUS",CriaVar("FKG_CODSUS") )
    Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986VldNP()
Fun��o para validar o n�mero do processo

@since  31/05/2019
@version P11
/*/
//-------------------------------------------------------------------
Function F986VldNP() As Logical

    Local oModel    As Object
    Local lRet 	    As Logical
    Local cNumPro   As Character
    Local cTipoImp  As Character

    oModel := FwModelActive()
    lRet 	:= .F.
    cNumPro := oModel:GetValue("FKGDETAIL","FKG_NUMPRO")
    cTipoImp := ""

    CCF->(DbSetorder(1))
    
    If !Empty(cNumPro)
        If CCF->( DBSeek(xFilial("CCF")+cNumPro) )

            cTipoImp := Alltrim( oModel:GetValue("FKGDETAIL","FKG_TPIMP") )

            While !lRet .And. CCF->(CCF_FILIAL+CCF_NUMERO) == xFilial("CCF")+cNumPro

                If cTipoImp == "INSS" .And. CCF->CCF_TRIB $ "1|2"
                    lRet := .T.
                Elseif cTipoImp == "PIS" .And. CCF->CCF_TRIB == "7"
					lRet := .T.
				Elseif cTipoImp == "COF" .And. CCF->CCF_TRIB == "8"
					lRet := .T.		
				Elseif cTipoImp == "IRF" .And. CCF->CCF_TRIB == "9"
					lRet := .T.
				Elseif cTipoImp == "CSL" .And. CCF->CCF_TRIB == "A"
					lRet := .T.
				EndIf

                CCF->(DbSkip())
            EndDo

            If !lRet
                Help( ,,"FKGTPIMP1",,STR0039, 1, 0,,,,,,{STR0040} ) //"O C�digo do complemento de imposto e o processo judicial n�o se referem ao mesmo tipo de imposto."###"Por favor, verifique os campos C�digo e Processo Jud. ou utilize a consulta F3 para obter os processos judiciais referentes ao tipo de imposto."
            Endif

        Else
            Help( ,,"FKGTPIMP2",,STR0041, 1, 0,,,,,,{STR0042} ) //"O c�digo do processo judicial informado � inv�lido"###"Por favor, verifique se o processo judicial informado se encontra cadastrado ou utilize a consulta F3 para obter os processos judiciais referentes ao tipo de imposto."
        Endif
    Else 
        lRet := .T.
    Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986ExAut
Funcao para carregar o model quando a inclus�o do t�tulo for via execauto

@since  12/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Function F986ExAut(cAliasC As Character, aFKF As Array, aFKG As Array, nOpca As Numeric, aExecAut As Array) As Logical

    Local cIdDoc 	:= ""
    Local cChave 	:= ""
    Local oModel	:= NIL
    Local oSubFKG	:= NIL
    Local nPos		:= 1
    Local nPosFKG	:= 1
    Local nTotFKG	:= Len(aFKG)
    Local nChaveFKG	:= 0
    Local lRet		:= .T.
    Local lAlt		:= nOpca==MODEL_OPERATION_UPDATE
    Local lNewLin	:= .F.
    Local nFKGDel	:= 0

    //Recriando as vari�veis no escopo da fun��o
    Private INCLUI := IIf(Type('INCLUI') == 'L', INCLUI, .F.)
    Private ALTERA := IIf(Type('ALTERA') == 'L', ALTERA, .F.)

    Default aExecAut := {}
    
    //Inicializa vari�veis est�ticas
    if !IsInCallStack("Fa986Conf")        
        F986IniVar(cAliasC,.F.)
    endif

    __cAlias986 := cAliasC
    __aDadosTit := AClone(aExecAut) //Armazena dados do t�tulo em array quando for ExecAuto

    If nOpca <>  MODEL_OPERATION_VIEW
        If nOpca == MODEL_OPERATION_UPDATE
            If cAliasC == "SE1" // se veio do contas a receber
                cChave := SE1->E1_FILIAL + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" +;
                SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
            ElseIf  cAliasC == "SE2" // se veio do contas a pagar
                cChave := SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" +;
                SE2->E2_FORNECE+ "|" + SE2->E2_LOJA
                cIdDoc := FINGRVFK7(cAliasC, cChave)
            EndIf

            cIdDoc := FINGRVFK7(cAliasC, cChave)
            FKF->(DBSetOrder(1))
            lRet := FKF->(DBSeek(xFilial("FKF") + cIdDoc ))
        Endif
        If lRet
            oModel := FwLoadModel("FINA986")
            oModel:SetOperation( nOpca )
            oModel:Activate()

            oSubFKG:= oModel:GetModel("FKGDETAIL")

            If nOpca <> MODEL_OPERATION_DELETE
                For nPos := 1 to Len(aFKF)
                    If !(aFKF[nPos][1] $ "FKF_IDDOC")
                        oModel:SetValue("FKFMASTER",aFKF[nPos][1],aFKF[nPos][2])
                    Endif
                Next
                If nOpca == MODEL_OPERATION_INSERT
                    For nPos := 1 to nTotFKG
                        For nPosFKG:= 1 to Len(aFKG[nPos])
                            oSubFKG:SetValue(aFKG[nPos][nPosFKG][1],aFKG[nPos][nPosFKG][2])
                        Next
                        If nPos < nTotFKG
                            oSubFKG:AddLine()
                        Endif
                    Next
                Else
                    For nPos := 1 to nTotFKG
                        nChaveFKG := aScan(aFKG[nPos],{|x| x[1]="FKG_ITEM"})
                        lNewLin := .F.
                        If nChaveFKG > 0
                            If !oSubFKG:SeekLine({{aFKG[nPos][nChaveFKG][1],aFKG[nPos][nChaveFKG][2]}})//Caso n�o consiga posicionar, adiciona a linha
                                oSubFKG:AddLine()
                                lNewLin := .T.
                            Else
                                nFKGDel := aScan( aFKG[nPos], { |x| x[1] = "FKGDELETE"})
                                If nFKGDel > 0 .AND. aFKG[nPos][nFKGDel][2]
                                    oSubFKG:DeleteLine()
                                EndIf
                            Endif
                            For nPosFKG:= 1 to Len(aFKG[nPos])
                                If !(aFKG[nPos][nPosFKG][1] $ "FKG_ITEM|FKG_IDDOC|FKGDELETE").or. lNewLin
                                    oSubFKG:SetValue(aFKG[nPos][nPosFKG][1],aFKG[nPos][nPosFKG][2])
                                Endif
                            Next
                        Else
                            Help( ,,"FKGSEMCHV",,STR0011, 1, 0 )//"Informe o FKG_ITEM do complemento de imposto para altera��o"
                            lRet:= .F.
                            Exit
                        Endif
                    Next
                Endif//nOpca == MODEL_OPERATION_INSERT
            Endif// nOpca <> MODEL_OPERATION_DELETE
            If lRet
                __cXml986 := oModel:GetXMLData(,,,,lAlt,.T.)

                Fa986Conf()
            EndIf
            oModel:Deactivate()
            oModel:Destroy()
            oModel:= Nil
        Endif//lRet

    Endif//nOpca <>  MODEL_OPERATION_VIEW

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986CNOIni
Funcao para carregar o campo FKF_CNO quando o titulo a pagar for de uma filial de obra

@since  12/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Function F986CNOIni() As Character
Local cCNO := ""

If INCLUI .and. __cAlias986 == "SE2" .and. __lTableFOF
    If Empty(FwFldGet("FKF_CNO"))
        DbSelectArea("F0F")
        DbSetOrder(1)
        If F0F->(DbSeek(xFilial("F0F") + cFilAnt))
            cCNO := F0F->F0F_OBRA
        EndIf
    EndIf
EndIf

DbSelectArea("FKF")
Return cCNO

//-------------------------------------------------------------------
/*/{Protheus.doc} F986CPRBIni
Funcao para carregar o campo FKF_CPRB quando o titulo a pagar e o prestador for regime CPRB

@since  12/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Function F986CPRBIni() As Character
Local cCPRB := "2"

If INCLUI .and. __cAlias986 == "SE2" .and. __lA2_CPRB
    If Empty(FwFldGet("FKF_CPRB")) .and. !Empty(SA2->A2_CPRB)
        cCPRB := SA2->A2_CPRB
    EndIf
EndIf

DbSelectArea("FKF")
Return cCPRB

//-------------------------------------------------------------------
/*/{Protheus.doc} F986BaseCa
Calcula o valor conforme o percentual do cadastro do complemento e a base de calculo informada

@since  12/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Function F986BaseCa() As Numeric

    Local nValorCalc As Numeric
    
    nValorCalc := 0

    If __lFKG_CALCUL
        If FwFldGet("FKG_CALCUL") == "2" //2-Percentual
            If Alltrim(FwFldGet("FKG_TPIMP")) $ "INSS|IRF|PIS|COF|CSL"
                nValorCalc := FwFldGet("FKG_BASECA")
            EndIf
            nValorCalc := (nValorCalc * FwFldGet("FKG_PERCEN")) / 100
        EndIf
    EndIf

Return nValorCalc

//-------------------------------------------------------------------
/*/{Protheus.doc} F986TRIB
Retorna o filtro da CCF para exibir na consulta padr�o conforme o tipo de imposto selecionado do complemento

    1=Contribui��o previdenci�ria (INSS)
    2=Contribui��o previdenci�ria especial (INSS)
    3=FUNRURAL
    4=SENAR
    5=CPRB
    6=ICMS
    7=PIS
    8=COFINS

@since  12/06/2017
@version P12
/*/
//-------------------------------------------------------------------

Function F986TRIB() As Character
    Local cRet      As Character
    Local cTipoImp  As Character
    Local cFiltro   As Character

    cRet := ""
    cTipoImp := ""
    cFiltro := ""

    cTipoImp := Alltrim( FwFldGet("FKG_TPIMP") )
    
    If cTipoImp == "INSS"
        cFiltro := "1|2"		
	Elseif cTipoImp == "PIS"
		cFiltro := "7"
	Elseif cTipoImp == "COF"
		cFiltro := "8"
	Elseif cTipoImp == "IRF"
		cFiltro := "9"
	Elseif cTipoImp == "CSL"
		cFiltro := "A"				
	EndIf
    
    If !Empty(cFiltro)
        cRet := "CCF->CCF_TRIB $ '" + cFiltro + "'"
    EndIf
Return cRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} Fa986GerI
Retorna se o cliente/fornecedor e natureza est�o configurados para reter
algum dos impostos liberados para serem utilizados no bloco 40 (EFD REINF).

@since  28/09/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function Fa986GerI( cNatu As Character, cForCli As Character, cLoja As Character, cImpos As Character ) As Logical

    Local lRet   	:= .F.
    Local lSeekED   := .F.
    Local lCliFor   := .F.
    Local AliClFor  := If(__cAlias986=='SE1','SA1','SA2')

    Default cNatu	:= ""
    Default cForCli	:= ""
    Default cLoja	:= ""
    Default cImpos  := ""

    //Posiciona na Natureza
    SED->( DBSetOrder(1) )
    lSeekED := SED->( DBSeek(xFilial('SED') + cNatu  ) )

    //Posiciona no cliente ou fornecedor de acordo com a carteira (pagar/receber)
    (AliClFor)->( DBSetOrder(1) )
    lCliFor := If(__cAlias986=='SE1',SA1->(DBSeek(xFilial('SA1')+cForCli+cLoja)), SA2->(DBSeek(xFilial('SA2')+cForCli+cLoja)))


    If lSeekED .and. lCliFor
        If __cAlias986=="SE1" //Carteira a Receber
            SA1->( DBSetOrder(1) )
            If SA1->( DBSeek( xFilial("SA1") + cForCli + cLoja ) )
                If cImpos =='IRF'
                    lRet := SED->ED_CALCIRF == "S" .And. SED->ED_RECIRRF == "2" .Or. (SA1->A1_RECIRRF == "2" .And. SED->ED_RECIRRF <> "1")
                Else
                    lSAInss := SA1->A1_RECINSS == 'S'
                EndIf
            EndIf
        Else //Carteira a Pagar

            Do Case
                Case cImpos =='IRF'
                    lRet := SED->ED_CALCIRF == 'S' .and. SA2->A2_CALCIRF $ "1|2"
                    If lRet .And. SE2->E2_TIPO == MVPAGANT
                        lRet := SA2->A2_CALCIRF == "2" 
                    EndIf
                Case cImpos =='PIS'
                    lRet := SED->ED_CALCPIS == 'S' .And.  SA2->A2_RECPIS == '2' .And. SA2->A2_TIPO <> "F"
                    If lRet .And. !__lPCCBx
                        lRet := SE2->E2_TIPO <> MVPAGANT
                    EndIf
                Case cImpos =='COF'
                    lRet := SED->ED_CALCCOF == 'S' .And. SA2->A2_RECCOFI == '2' .And. SA2->A2_TIPO <> "F"
                    If lRet .And. !__lPCCBx
                        lRet := SE2->E2_TIPO <> MVPAGANT
                    EndIf
                Case cImpos =='CSL'
                    lRet := SED->ED_CALCCSL == 'S' .And. SA2->A2_RECCSLL == '2' .And. SA2->A2_TIPO <> "F"
                    If lRet .And. !__lPCCBx
                        lRet := SE2->E2_TIPO <> MVPAGANT
                    EndIf
                OtherWise
                    If (SED->ED_CALCIRF == 'S' ) .or. (SED->ED_CALCPIS == 'S' .and.  SA2->A2_RECPIS == '2') .or. ;
                        (SED->ED_CALCCOF == 'S' .and. SA2->A2_RECCOFI == '2') .or. (SED->ED_CALCCSL == 'S' .and. SA2->A2_RECCSLL == '2')
                        lRet := .T.
                    Endif
            EndCase
        Endif
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986Folder
Regras para exibir ou n�o as abas na View

@author Fabio Casagrande Lima
@since 14/05/2019
/*/
//-------------------------------------------------------------------
Static Function Fa986Folder(cFolder As Character) As Logical
    
    Local lRet      As Logical
    Local cAliasTab As Character
    Local cRotinas	As Character
    Local cCampo	As Character
    Local cTipos	As Character

    Default cFolder := "2"

    If __lBrowse
        cAliasTab:= __cAlias986 +"->"
    Else 
        cAliasTab:= "M->"
    EndIf

    lRet        := .T.
    cRotinas    := "MATA103|MATA100|MATA461|MATA460"
    cCampo	    := cAliasTab + Right(__cAlias986, 2) + "_LA"
    cTipos	    :=	MVABATIM + "/" + MV_CRNEG + "/" + MVRECANT + "/" + MVTXA + "/" +;
                    MVTAXA + "/" + MV_CPNEG + "/" + MVINSS + "/" + ;
                    MVISS + "/" + MVCSABT + "/" + MVCFABT + "/" + MVPIABT + "SES/CID/INA/PIS/CSL/COF"
    
    /* cFolder:
    Aba 1 - Complemento do titulo
    Aba 2 - Complemento do Imposto X T�tulos 
    */

    If cFolder == "2" .and. (INCLUI .or. ALTERA)
        /* As regras abaixo definem as situacoes onde a aba 'Complemento do Imposto x Titulos' nao sera exibida ao acionar o botao Complemento de Titulo:
            1) Para os tipos de titulo (E2_TIPO) contidos na variavel 'cTipos';
            2) Para os titulos cuja origem esteja contido na variavel 'cRotinas';
            3) Quando o botao for acionado de fora do titulo (browse)
            4) Para titulos j� contabilizados (_LA = S)  */
        If &( cAliasTab + Right(__cAlias986, 2) + "_TIPO" ) $ cTipos .OR. ;
                (Alltrim( &( cAliasTab + Right(__cAlias986, 2) + "_ORIGEM" ) ) $ cRotinas ) .OR.;
                __lBrowse .OR. ;
                &cCampo == 'S'
            lRet := .F.
        Endif
    Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986Gatil()
Gatilho disparado de diversos campos para preenchimento dos campos 
de descri��o do mesmo

@param		cCampo	- Campo origem
            cTarget - Campo alvo
@return		cDescri - conteudo do a ser gatilhado
@author		Pequim
@since		22/08/2019
@version	P12.1.25
/*/
//-------------------------------------------------------------------
Function F986Gatil(oModel As Object, cCampo As Char, cTarget As Char ) As Char

    Local cCpoGat	As Char
    Local cDescri	As Char

    Default oModel	:= Nil
    Default cCampo	:= ""
    Default cTarget	:= ""
        
    cDescri	:= ""

    If !Empty(cCampo)

        cCpoGat := oModel:GetValue(cCampo)
    
        If cCampo == "FKF_CNAE"
            cDescri := Posicione('CG1',1,xFilial('CG1')+cCpoGat,'CG1_DESCRI')
        ElseIf cCampo == "FKF_TPREPA"
            cDescri := Posicione('SX5',1,xFilial('SX5')+'0G'+cCpoGat,'X5_DESCRI')
        ElseIf cCampo == "FKF_TPSERV"
            cDescri := Posicione('SX5',1,xFilial('SX5')+'DZ'+cCpoGat,'X5_DESCRI')
        ElseIf cCampo == "FKF_CNO"
            cDescri := Posicione('SON',1,xFilial('SON')+cCpoGat,'ON_DESC')
        ElseIf cCampo == "FKF_CODBEM"
            cDescri := Posicione('SX5',1,xFilial('SX5')+'0I'+cCpoGat,'X5_DESCRI')
        ElseIf cCampo == "FKF_CODSER"
            cDescri := Posicione('SX5',1,xFilial('SX5')+'0H'+cCpoGat,'X5_DESCRI')
        ElseIf cCampo == "FKF_NATREN" .and. cTarget == "FKF_DSCNRN"
            cDescri := Posicione('FKX',1,xFilial('FKX')+cCpoGat,'FKX_DESCR')
        ElseIf cCampo == "FKF_NATREN" .and. cTarget == "FKF_CGCSCP"
            cDescri := ""
        ElseIf cCampo == "FKF_NATREN" .and. cTarget == "FKF_INDDEC"
            cDescri := Posicione('FKX',1,xFilial('FKX')+cCpoGat,'FKX_DECSAL')
		EndIf
	EndIf
Return cDescri

//-------------------------------------------------------------------
/*/{Protheus.doc} F986LINE
Valida��o de linha OK

@author Fabio Casagrande Lima
@since	05/04/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function F986LINE(oModel) as Logical

    Local lRet      As Logical
    Local cAcao     As Character
    Local cTpAcao   As Character
    Local cNumProc  As Character
    Local cAliasTab As Character
    Local cNatu		As Character
    Local cForCli	As Character
    Local cLoja		As Character
    Local cTpImp	As Character
    Local cCmpVld	As Character
    Local lApliBase	As Logical
    Local cCodDep   As Character
    Local nValOri   As Numeric
    Local lTpaTRB   As Logical
    Local cINSPRE   As Character
    Local nMoedaT   As Numeric
    Local dDtEmis   As Date
    Local nTxMoed   As Numeric
    Local nBasTit   As Numeric

    lRet        := .T.
    cAcao       := ""
    cTpAcao     := ""
    cNumProc    := ""
    cAliasTab   := ""
    cNatu	    := ""
    cForCli	    := ""
    cLoja		:= ""
    cTpImp	    := ""
    cCmpVld	    := ""
    lApliBase	:= .F.
    cCodDep     := ""
    cTpaTRB     := ""
    cINSPRE     := ""
    nBasTit     := 0

    //N�o valida as linhas de FKG se a valida��o estiver sendo chamada pelo LoadXMLData.
    If !FwIsInCallStack("LoadXMLData")
        cAcao		:= oModel:GetValue("FKGDETAIL", "FKG_DEDACR")// 1 == Subtra��o se 2 == Soma
        cTpAcao		:= oModel:GetValue("FKGDETAIL", "FKG_TPATRB")
        cNumProc	:= oModel:GetValue("FKGDETAIL", "FKG_NUMPRO")
        lApliBase	:= oModel:GetValue("FKGDETAIL", "FKG_APLICA") == '1'// 1 == Base se 2 == Valor Imp
        If __lINSPRE
            cINSPRE     := oModel:GetValue("FKGDETAIL", "FKG_INSPRE")
        EndIf
                
        cAliasTab := If(__lBrowse, __cAlias986+"->", "M->")

        lTpaTRB   := (Alltrim(cTpAcao) =="010" .or. Alltrim(cTpAcao) =="011" .or. Alltrim(cTpAcao) =="012")

        If __lFCODDEP
            cCodDep	    := oModel:GetValue("FKGDETAIL", "FKG_CODDEP")
        Endif
          
        If Len(__aDadosTit) > 0 //Recebe dados do t�tulo quando for ExecAuto
            cNatu	:= __aDadosTit[AScan(__aDadosTit,{|x|AllTrim(x[1])==Right(__cAlias986, 2)+"_NATUREZ"})][2]
            cForCli	:= __aDadosTit[AScan(__aDadosTit,{|x|AllTrim(x[1])==Iif(__cAlias986=="SE2","E2_FORNECE", "E1_CLIENTE")})][2]
            cLoja	:= __aDadosTit[AScan(__aDadosTit,{|x|AllTrim(x[1])==Right(__cAlias986, 2)+"_LOJA"})][2]
        Else
            cNatu	:= &( cAliasTab + Right(__cAlias986, 2) + "_NATUREZ" )
            cForCli	:= &( cAliasTab + Right(__cAlias986, 2) + Iif(__cAlias986 == "SE2","_FORNECE", "_CLIENTE" ) )
            cLoja	:= &( cAliasTab + Right(__cAlias986, 2) + "_LOJA" )
        Endif
        
        If cAcao == "1"
        
            cTpImp	:= AllTrim( oModel:GetValue("FKGDETAIL", "FKG_TPIMP" ) )
            
            If lApliBase 
                cCmpVld	:=	cAliasTab + Right(__cAlias986, 2) + "_BASE" + cTpImp
                nBasTit := &(cCmpVld)
                nMoedaT := &(cAliasTab + Right(__cAlias986, 2) + "_MOEDA")
                If nMoedaT > 1 
                    //Devido a base do tributo ser gravada na SE1/SE2 na moeda do t�tulo, converte para moeda forte antes de validar
                    dDtEmis := &(cAliasTab + Right(__cAlias986, 2) + "_EMISSAO")
                    nTxMoed := &(cAliasTab + Right(__cAlias986, 2) + "_TXMOEDA")
                    nBasTit := Round(NoRound(xMoeda(nBasTit,nMoedaT,1,dDtEmis,__nCasDec,nTxMoed),,__nCasDec+1),2)
                Endif
                If __cAlias986 == "SE2" .And. oModel:GetValue("FKGDETAIL", "FKG_VALOR") > nBasTit
                    lRet := .F.
                    HELP(' ',1,"F986LINE3" ,,STR0043,2,0,,,,,, {STR0044})	//"O Conte�do do campo 'Valor' � maior que o campo Base do imposto do T�tulo. #O conteudo do campo 'Valor' precisa ser menor ou igual ao campo Base do imposto.
                EndIf
            Else    
                If cTpImp == "IRF"
                    cTpImp	:=	"_IRRF"
                ElseIf cTpImp == "COF"
                    cTpImp	:=	"_COFINS"
                ElseIf cTpImp == "CSL"
                    cTpImp	:=	"_CSLL"
                Else
                    cTpImp	:=	"_" + cTpImp
                EndIf	
                
                cCmpVld	:=	cAliasTab + Right(__cAlias986, 2) + cTpImp
                nValOri := &( cCmpVld ) 
                //Quando valida��o do INSS nao ocorrer pelo Form, preciso olhar o valor original e nao mais o M->_INSS, pois ele ja foi atualizado.
                If FwViewActive() == Nil .And. "INSS"$cCmpVld
                    nValOri := oModel:Getvalue("FKFMASTER","FKF_ORIINS")
                EndIF       

                If oModel:GetValue("FKGDETAIL", "FKG_VALOR") > nValOri
                    lRet := .F.
                    HELP(' ',1,"F986LINE4" ,,STR0045,2,0,,,,,, {STR0046})	//"O Conte�do do campo 'Valor' � maior que o campo Valor do imposto do T�tulo. #O conteudo do campo 'Valor' precisa ser menor ou igual ao campo Valor do imposto do Titulo.
                EndIf
            EndIf
        EndIf
        
        If lRet        
            If !F986CalImp() .and. cAcao <> "3"
                lRet := .F.
                HELP(' ',1,"F986LINE1" ,,STR0020,2,0,,,,,, {STR0021})	//"Conte�do do campo 'A��o' n�o permitido para t�tulos sem c�lculo de impostos. #Selecione um complemento de imposto em que a a��o esteja definida como 'Informativo'.
            ElseIf Alltrim(cTpAcao) =="004" .and. Empty(cNumProc)
                lRet := .F.
                HELP(' ',1,"F986LINE2" ,,STR0022,2,0,,,,,, {STR0038})   //"O preenchimento do n�mero do processo judicial/administrativo � obrigat�rio para o Tipo de A��o selecionado (004). #"Preencha o campo 'Processo Jud' (FKG_NUMPRO) ou altere para outro Complemento de Imposto que possua um 'Tipo de A��o' diferente."             
            ElseIf !Empty(cCodDep) .and. !(Alltrim(cTpAcao) $"013|024")
                lRet := .F.
                HELP(' ',1,"F986LINE5" ,,STR0055,2,0,,,,,, {STR0056})   //"O campo Dependente n�o deve ser preenchido para o complemento de imposto selecionado" ## "Selecione um complemento de imposto que seja IRF com dedu��o de pens�o aliment�cia ou dependentes."    
            ElseIf Empty(cCodDep).and. (Alltrim(cTpAcao) == "024")
                lRet := .F.
                HELP(' ',1,"F986LINE6" ,,STR0057,2,0,,,,,, {STR0058})   //"O campo Dependente deve ser preenchido para o complemento de imposto selecionado" ## "Informe o dependente"                        
            EndIf                
        EndIf
    EndIf
    
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986IniVar
Inicializa as variaveis estaticas

@author Fabio Casagrande Lima
@since 24/04/2019
/*/
//-------------------------------------------------------------------
Static Function F986IniVar(cAliasC As Character, lPosBrw As Logical)

    Default lPosBrw := .F.

    __nOPER       := 0
    __cAlias986   := cAliasC
    __lBrowse     := lPosBrw
    __TableF71    := AliasIndic('F71')
    __lFina890    := FindFunction('FINA890')
    __lF040Espec  := ExistFunc("F040Espec")
    __lFKFEspec   := FKF->(ColumnPos("FKF_ESPEC")) > 0 
    __lFKF_ORIINS := FKF->(ColumnPos("FKF_ORIINS")) > 0
    __lFKF_CEDENT := FKF->(ColumnPos("FKF_CEDENT")) > 0
    __lFKF_PAGPIX := FKF->(ColumnPos("FKF_PAGPIX")) > 0
    __lFKF_RECPIX := FKF->(ColumnPos("FKF_RECPIX")) > 0
    __lFKG_CALCUL := FKG->(ColumnPos("FKG_CALCUL")) > 0
    __lSF2_CNO    := SF2->(ColumnPos("F2_CNO")) > 0 .and. FKF->(ColumnPos("FKF_CNO")) > 0
    __lA2_CPRB    := SA2->(ColumnPos("A2_CPRB")) > 0
    __lTableFOF   := AliasInDic("F0F")
    __lFNATREN    := FKF->(ColumnPos("FKF_NATREN")) > 0
    __lEDNTREN    := cPaisLoc == "BRA" .And. SED->(ColumnPos("ED_NATREN")) > 0
    __lFCODDEP    := FKG->(ColumnPos("FKG_CODDEP")) > 0
    __lINSPRE     := FKG->(ColumnPos("FKG_INSPRE")) > 0  
    __lAltImp     := .F.
    __lFCGCSCP    := FKF->(ColumnPos("FKF_CGCSCP")) > 0 
    __cNATRSCP    := SuperGetMv("MV_NATRSCP",.F.,"")
    __lEmpPub     := IsEmpPub()
    __lPCCBx      := SuperGetMv("MV_BX10925",.T.,"2") == "1"
    __nVlMPub     := SuperGetMv("MV_VLMPUB"�,.T.,10)
    __lGerF71     := .F.
    __nCasDec     := 0

Return Nil

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} F986ExcFKG
Fun��o para limpar os complementos de impostos do t�tulo, ao alterar a natureza do mesmo

@author pedro.alencar
@since 27/08/2019
@version 12.1.27
@type Function

@param cAliasTit, char, Alias do t�tulo (SE1 ou SE2)
@return lRet, boolean, Indica se as linhas de complemento de imposto foram exclu�das
/*/
//---------------------------------------------------------------------------------------------
Function F986ExcFKG( cAliasTit As Char ) As Logical
    Local lRet As Logical
    Local lcXml986 As Logical
    Local lTemFKG As Logical
    Local oModel As Object
    Local oModelFKG As Object
    Local cChaveTit As Char
    Local cNewNatRen As Char
    Local cNatur As Char
    Local cIdDoc As Char
    Local nI As Numeric
    Local aArea As Array
    Default cAliasTit := ""
    
    lRet := .T.
    lTemFKG := .F.
    oModel := Nil
    oModelFKG := Nil
    cChaveTit := ""
    cNewNatRen := ""
    cNatur := ""
    cIdDoc := ""
    nI := 0
    aArea := GetArea()
    lcXml986 := !Empty(__cXml986)

    If __lEDNTREN == Nil
        __lEDNTREN := cPaisLoc == "BRA" .And. SED->(ColumnPos("ED_NATREN")) > 0
    EndIf
    
    If !lcXml986
        If cAliasTit == "SE2"
            cChaveTit := Iif(Empty(M->E2_FILIAL),xFilial('SE2'),M->E2_FILIAL) + "|" + M->E2_PREFIXO + "|" + M->E2_NUM + "|" +;
                                                                M->E2_PARCELA + "|" + M->E2_TIPO    + "|" + M->E2_FORNECE + "|" + M->E2_LOJA
            cNatur := M->E2_NATUREZ
        ElseIf cAliasTit == "SE1"
            cChaveTit := M->E1_FILIAL + "|" +  M->E1_PREFIXO + "|" + M->E1_NUM + "|" + M->E1_PARCELA + "|" + M->E1_TIPO + "|" + M->E1_CLIENTE + "|" + M->E1_LOJA
            cNatur := M->E1_NATUREZ
        EndIf

        cIdDoc := FINGRVFK7(cAliasTit, cChaveTit)
    
        FKF->( dbSetOrder(1) ) //FKF_FILIAL+FKF_IDDOC
        lRet := FKF->( msSeek( FWxFilial("FKF") + cIdDoc ) )

        If lRet .And. __lEDNTREN
            cNewNatRen    := GetAdvFVal("SED","ED_NATREN",xFilial("SED") + cNatur )
            If !Empty(cNewNatRen)
                If !Empty(FKF->FKF_NATREN)
                    If FKF->FKF_NATREN != cNewNatRen
                        Help( ,, "FAltNatRen",, STR0064, 1, 0,,,,,, {} ) //"Devido a altera��o de natureza financeira, a natureza de rendimento no complemento de t�tulo dever� ser revisitada caso necessite acompanhar a da natureza financeira (SED)."
                    EndIf
                Else
                    If F986NatRen(cAliasTit,, cNatur, .F.)
                        RecLock("FKF", .F.)
                            FKF->FKF_NATREN := cNewNatRen
                        MsUnLock()
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
    
    If lRet
        oModel := FwLoadModel("FINA986")
        oModelFKG := oModel:GetModel("FKGDETAIL")
        
        If lcXml986
            oModel:LoadXMLData(__cXml986, .T.)
        Else
            oModel:SetOperation(MODEL_OPERATION_UPDATE)
            oModel:Activate()
        EndIf
        
        If oModelFKG:Length() > 0
            For nI := 1 To oModelFKG:Length()
                If ! oModelFKG:IsDeleted(nI) .And. ! oModelFKG:IsEmpty(nI)
                    lTemFKG := .T.
                    oModelFKG:GoLine(nI)
                    
                    If ! oModelFKG:DeleteLine()
                        lRet := .F.
                        Exit
                    EndIf
                EndIf
            Next nI
            
            If lTemFKG
                If lRet
                    __cXml986 := oModel:GetXMLData(,,,, .T., .T.)
                    
                    Help( ,, "F986ExcFKG",, STR0033, 1, 0,,,,,, {} ) //"Devido a altera��o de natureza, os complementos de impostos (FKG) ser�o exclu�dos para esse t�tulo. Caso necess�rio, inclua-os novamente clicando em 'Outras A��es > Complemento do t�tulo'."
                Else
                    Help( ,, "F986NoExcFKG",, STR0034, 1, 0,,,,,, {} ) //"A natureza foi alterada, por�m n�o foi poss�vel excluir os complementos de impostos (FKG). Acesse 'Outras A��es > Complemento do t�tulo' e revise os complementos informados."
                EndIf
            EndIf
        EndIf
        
        oModel:Deactivate()
        oModel:Destroy()
        FWFreeObj(oModelFKG)
        FWFreeObj(oModel)
    EndIf
    
    RestArea(aArea)
Return lRet

/*/{Protheus.doc} readBarcode
Executa o aplicativo caso ele nao exista avisa o usuario

@author pedro castro
@since 19/10/2020
@version 12.1.27
@type Function
 
/*/
Static Function readBarcode()
    Local cDir As Character

    cDir := iif(GetOS()=="UNIX", Subs(getClientDir(),3), getClientDir()) 

    If GetOS() =="WINDOWS"
        If WaitRun(cDir + "barcode_scan.exe", 1 ) != 0
            MsgInfo(STR0050)// Verifique se o executavel barcode_scan existe na pasta do smartclient
            Return
        Endif
        MsgInfo(STR0051)//De um Ctrl+V no campo QR CODE
    Else
        If WaitRun(cDir + "barcode_scan", 1 ) != 0
            MsgInfo(STR0050)// Verifique se o executavel barcode_scan existe na pasta do smartclient
            Return
        Endif   
        MsgInfo(STR0051)//De um Ctrl+V no campo QR CODE
    Endif

Return

/*/{Protheus.doc} GetOS
Avalia e retorna o sistema operacional

@author pedro castro
@since 19/10/2020
@version 12.1.27
@type Function
 
/*/
Static Function GetOS() As Character
    Local cStringOS As Character
    Local cRet      As Character

    cStringOS := Upper(GetRmtInfo()[2])
    cRet      := ""

    If GetRemoteType() == 0 .or. GetRemoteType() == 1
        cRet := "WINDOWS"
    ElseIf GetRemoteType() == 2 
        cRet := "UNIX" // Linux ou MacOS		
    ElseIf GetRemoteType() == 5 
        cRet := "HTML" // Smartclient HTML		
    ElseIf ("ANDROID" $ stringOS)
        cRet := "ANDROID" 
    ElseIf ("IPHONEOS" $ stringOS)
        cRet := "IPHONEOS"
    EndIf
return cRet

/*/{Protheus.doc} F986PixIni
Caso o cliente utilize pix altera o campo FKF_RECPIX para sim
@author pedro castro
@since  20/10/2020
@version P12
/*/
Function F986PixIni() As Character    
    Local lDesdobra As Logical
    Local cRet 		As Char
    Local cChavAI0 	As Char   
    Local cParcela  As Char
    Local cTipo     As Char
    Local dVencto   As Date
    Local aAreaAI0 	As Array	
    
    //Inicializa vari�veis
    lDesdobra := .F.
    cTipo     := IIf(__lBrowse, SE1->E1_TIPO, M->E1_TIPO)    	
    cDocTEF   := IIf(__lBrowse, SE1->E1_DOCTEF, M->E1_DOCTEF)
    cRet      := "2"
    cChavAI0  := ""
    cParcela  := ""
    aAreaAI0  := {}
    
    If !(F986PIXLj(cTipo, cDocTEF)) .And. GeraPix(cTipo) .And. AI0->(FieldPos("AI0_RECPIX")) > 0
        aAreaAI0 := AI0->(GetArea())
        AI0->(DbSetOrder(1))
        
        If __lBrowse
            cChavAI0 :=  SE1->E1_CLIENTE + SE1->E1_LOJA
            dVencto  := SE1->E1_VENCREA
        Else
            cChavAI0 := M->E1_CLIENTE + M->E1_LOJA
            dVencto  := M->E1_VENCREA
        Endif
        
        lDesdobra:= IIF(__lBrowse, SE1->E1_DESDOBR == "1", M->E1_DESDOBR == "1")
        cParcela := IIF((__lBrowse .Or. lDesdobra), SE1->E1_PARCELA, M->E1_PARCELA)
        
        If __lGeraPix .And. !(lDesdobra .And. Empty(Alltrim(cParcela)))
            If AI0->(DbSeek(xFilial("AI0")+cChavAI0)) .And. Alltrim(AI0->AI0_RECPIX) $ "1|2" .And. (dVencto >= dDataBase);
               .And. (!FindFunction("JurGetPix") .Or. !SuperGetMV("MV_JURXFIN",, .F.) .Or. JurGetPix()) // Integra��o SIGAPFS
                cRet := '1'
            EndIf
        EndIf
        
        RestArea(aAreaAI0)
        FwFreeArray(aAreaAI0)
    EndIf
    
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986PixVal
Verifica se o t�tulo pode ser PIX

@author pedro castro
@since  20/10/2020
@since  12/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Function F986PixVal() As Logical
    Local cDocTEF   As Char
    Local cTipo     As Char
    Local lRet      As Logical
    
    cTipo  := IIf(__lBrowse, SE1->E1_TIPO,M->E1_TIPO)
    cDocTEF := IIf(__lBrowse, SE1->E1_DOCTEF,   M->E1_DOCTEF)
    lRet    := !(F986PIxLj(cTipo, cDocTEF)) .And. GeraPix(cTipo)
    
    If lRet
        lRet := !(ALTERA .And. SE1->E1_SALDO <= 0)
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986PixVld
    Verifica o vencimento do titulo para inclui-lo em PIX ou n�o.

    @author Victor Azevedo
    @since  21/12/2022
    @since  21/12/2022
    @version P12
/*/
//-------------------------------------------------------------------
Function F986PixVld() As Logical
    
    Local dVencto   As Date
    Local lRet      As Logical

    //inicializa variaveis
    lRet     := .T.
    
    If __lBrowse
        dVencto := SE1->E1_VENCREA
    Else
        dVencto := M->E1_VENCREA
    EndIf
    
    lRet    := (dVencto >= dDataBase)

    If !lRet 
        If M->FKF_RECPIX == "1"
            Help(,,"F986VENC",,STR0062, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0063})
        Else
            lRet    := .T.
        EndIf
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986PJob
criar ou altera um registo na tabela F71 de acordo com o campo FKF_RECPIX

@author pedro castro
@since  21/10/2020
@version P12
/*/
//-------------------------------------------------------------------

Function F986PJob()
    Local aArea      As Array
    Local aAreaSA6   As Array
    Local aDadoTit   As Array
    Local cQuery     As Character
    Local cSeq       As Character
    Local cTempAlias As Character
    Local cIdTran    As Character
    Local lDesdobra  As Logical
    Local cParcela   As Character
    Local cFilBco    As Character
    Local cBanco     As Character
    Local cAgenci    As Character
    Local cConta     As Character
    Local cTpChave   As Character
    Local cChavePix  As Character
    Local nRegF70    As Numeric
    Local nBcoPix    As Numeric
    Local nDiasExp   As Numeric
    Local nMultaPIX  As Numeric
    Local cFilFwFt   As Character
    Local oConfig    As Object
    Local cChaveConf As Char
    Local l460ACOMIT As Logical
    Local cChaveTit  As Char
    Local cFilSA6    As Char
    
    //Inicializa vari�veis
    cQuery      := ""
    cQuery1     := ""
    cSeq        := ""
    aDadoTit    := {}
    lDesdobra   := .f.
    cParcela    := ""
    cIdTran     := ""    
    cFilBco     := ""
    cBanco      := ""
    cAgenci     := ""
    cConta      := ""
    cTpChave    := ""
    cChavePix   := ""
    nRegF70     := 0
    nBcoPix     := SuperGetMV("MV_BCOPIX", .F., 3)
    aArea       := GetArea()
    aAreaSA6    := SA6->(GetArea())
    nDiasExp    := 0
    nMultaPIX   := 0
    cFilFwFt    := ""
    cTempAlias  := GetNextAlias()
    __lMultPIX  := IIf(__lMultPIX == Nil, SA6->(FieldPos("A6_PIXMULT")) > 0 .And. SA6->(FieldPos("A6_DIASEXP")) > 0, __lMultPIX)
    __lPEMlPIX  := IIf(__lPEMlPIX == Nil, ExistBlock("FINMULTPIX"), __lPEMlPIX)
    l460ACOMIT  := FwIsInCallStack("F460ACOMMIT")
    cChaveTit   := ""
    cFilSA6     := xFilial("SA6")
    
    __nFINPIX9  := SuperGetMV("MV_FINPIX9", .F., 1)
    
    If __lTPIConf == Nil
	    __lTPIConf := FindFunction("APIPIXOn") .And. APIPIXOn()
    EndIf

    If M->FKF_RECPIX == "2"
        If __oPJob == NIL
            cQuery := "SELECT R_E_C_N_O_, F71_FILIAL, F71_PREFIX, F71_NUM, F71_PARCEL, F71_TIPO, F71_CODCLI, F71_LOJCLI, F71_SOLCAN, "
            cQuery += "F71_VALOR, F71_EMISSA, F71_VENCTO, F71_CHVPIX, F71_STATUS, F71_SOLCAN, F71_SEQ, F71_IDDOC, "
            cQuery += "F71_IDTRAN, F71_FILBCO, F71_CODBAN, F71_AGENCI, F71_NUMCON, F71_TPCHV, F71_CHVPIX "
            cQuery += "FROM " + RetSQLName("F71") + " "
            cQuery += "WHERE F71_FILIAL = ? AND F71_IDDOC = ? "
            cQuery += "AND F71_STATUS IN ('1','2','3','4')"
            cQuery += "AND F71_SOLCAN = '2' AND D_E_L_E_T_ = ' '"
            __oPJob := FWPreparedStatement():New(cQuery)          
        EndIf
        
        __oPJob:SetString(1,xFilial('F71'))
        __oPJob:SetString(2,FKF->FKF_IDDOC)
        
        cQuery := __oPJob:GetFixQuery()
        MPSysOpenQuery(cQuery,cTempAlias)

        (cTempAlias)->(DbGoTop())

        Do While (cTempAlias)->(!EOF())
            aDadoTit := {}
            AAdd(aDadoTit,  {"F71_SOLCAN",  "1"})
            AAdd(aDadoTit,  {"F71_STATUS",  IIf((cTempAlias)->F71_STATUS == "1", "7", (cTempAlias)->F71_STATUS)})
            
            F986PixE(aDadoTit, "2", (cTempAlias)->R_E_C_N_O_)
            (cTempAlias)->(DbSkip()) 
        Enddo
        
        (cTempAlias)->(DbCloseArea())
    ElseIf M->FKF_RECPIX == "1"
        If __nFINPIX9 == 2 .And. !__lTPIConf
            cChaveTit := (SE1->E1_FILIAL+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA)
            F986AltPix(cChaveTit, SE1->E1_FILORIG, .T.)
        EndIf
        
        If ((__nFINPIX9 == 1 .Or. __lTPIConf) .Or. (__nFINPIX9 == 2 .And. !__lTPIConf .And. !l460ACOMIT))
            If __oPJob2 == NIL 
                cQuery := "SELECT COUNT(*) AS NTOTREG "
                cQuery += "FROM "+ RetSQLName("F71") + " "
                cQuery += "WHERE F71_FILIAL = ? "
                cQuery += "AND F71_IDDOC = ? "
                cQuery += "AND F71_SOLCAN = '2' AND F71_STATUS NOT IN ('5', '7', '8') "
                cQuery += "AND D_E_L_E_T_ = ' '"            
                __oPJob2 := FWPreparedStatement():New(cQuery)         
            EndIf        
            
            __oPJob2:SetString(1,xFilial('F71'))
            __oPJob2:SetString(2,FKF->FKF_IDDOC)
            
            cQuery := __oPJob2:GetFixQuery()  
            MPSysOpenQuery(cQuery,cTempAlias)
            (cTempAlias)->(DbGoTop())
            
            lDesdobra   := IIf(__lBrowse, SE1->E1_DESDOBR == "1", M->E1_DESDOBR == "1")
            cParcela    := IIf(__lBrowse .Or. lDesdobra, SE1->E1_PARCELA, M->E1_PARCELA)
            
            If !(lDesdobra .And. Empty(AllTrim(cParcela))) .And. (cTempAlias)->(NTOTREG) == 0
                cSeq        := F986RetSeq()
                aDadoTit    := {}
                
                If nBcoPix != 3 .And. __nFINPIX9 == 2
                    cChaveConf := cEmpAnt + "|" + AllTrim(FwXFilial("SA6"))
                    oConfig    := FwTFConfig()
                    cFilBco    := cFilAnt

                    // Recupera Banco TOTVS PIX
                    If ValType(cBanco := oConfig[ "fin_banco_PagamentosDigitais_" + cChaveConf]) == "U"
                        cBanco := ""
                    EndIf

                    // Recupera Ag�ncia TOTVS PIX
                    If ValType(cAgenci := oConfig[ "fin_agencia_PagamentosDigitais_" + cChaveConf]) == "U"
                        cAgenci := ""
                    EndIf

                    // Recupera Conta TOTVS PIX
                    If ValType(cConta := oConfig[ "fin_conta_PagamentosDigitais_" + cChaveConf]) == "U"
                        cConta := ""
                    EndIf

                    FwFreeObj(oConfig)
                    
                    cTempF70 := GetNextAlias()                    
                    
                    cQuery := "SELECT F70_FILIAL, F70_COD, F70_AGENCI, F70_NUMCON, F70_TPCHV, F70_CHVPIX "
                    cQuery += "FROM " + RetSQLName("F70") + " F70 "
                    cQuery += "JOIN " + RetSQLName("SA6") + " SA6 "
                    cQuery += "ON (SA6.A6_FILIAL = '" + cFilSA6 + "' "		
                    cQuery += "AND F70.F70_COD = SA6.A6_COD "
                    cQuery += "AND F70.F70_AGENCI = SA6.A6_AGENCIA "
                    cQuery += "AND F70.F70_DVAGE = SA6.A6_DVAGE "
                    cQuery += "AND F70.F70_NUMCON = SA6.A6_NUMCON "
                    cQuery += "AND F70.F70_DVCTA = SA6.A6_DVCTA "
                    cQuery += "AND F70.D_E_L_E_T_ = SA6.D_E_L_E_T_) "				
                    cQuery += "WHERE SA6.A6_FILIAL = '" + cFilSA6 + "' "
                    
                    If !Empty(cFilBco) .And. !Empty(cBanco) .And. !Empty(cAgenci) .And. !Empty(cConta) .And. nBcoPix == 2
                        cQuery += "AND F70_COD = '"      + cBanco    + "' "
                        cQuery += "AND F70_AGENCI = '"   + cAgenci   + "' "
                        cQuery += "AND F70_NUMCON = '"   + cConta    + "' "
                    EndIf
                    
                    cQuery += "AND F70.F70_ACTIVE = '1' AND F70.D_E_L_E_T_ = ' ' "
                    cQuery := ChangeQuery(cQuery)
                    MPSysOpenQuery(cQuery, cTempF70)
                    
                    While (cTempF70)->(!EOF())
                        nRegF70 += 1
                        
                        If nRegF70 > 1
                            cFilBco     := ""
                            cBanco      := ""
                            cAgenci     := ""
                            cConta      := ""
                            cTpChave    := ""
                            cChavePix   := ""                            
                            Exit
                        EndIf
                        
                        cBanco      := (cTempF70)->F70_COD
                        cAgenci     := (cTempF70)->F70_AGENCI
                        cConta      := (cTempF70)->F70_NUMCON
                        cTpChave    := (cTempF70)->F70_TPCHV
                        cChavePix   := (cTempF70)->F70_CHVPIX
                        (cTempF70)->(DbSkip())
                    EndDo
                    
                    If nRegF70 == 1 .And. __lMultPIX
                        SA6->(DbSetOrder(1))
                        If SA6->(DbSeek(FwXFilial("SA6") + cBanco + cAgenci + cConta))
                            nDiasExp    := SA6->A6_DIASEXP
                            nMultaPIX   := SA6->A6_PIXMULT
                        EndIf
                    EndIf
                    
                    (cTempF70)->(DbCloseArea())
                EndIf
                
                AAdd(aDadoTit, {"F71_PREFIX",   IIf(__lBrowse .Or. lDesdobra, SE1->E1_PREFIXO,  M->E1_PREFIXO)})
                AAdd(aDadoTit, {"F71_NUM",      IIf(__lBrowse .Or. lDesdobra, SE1->E1_NUM,      M->E1_NUM)})
                AAdd(aDadoTit, {"F71_TIPO",     IIf(__lBrowse .Or. lDesdobra, SE1->E1_TIPO,     M->E1_TIPO)})
                AAdd(aDadoTit, {"F71_PARCEL",   IIf(__lBrowse .Or. lDesdobra, SE1->E1_PARCELA,  M->E1_PARCELA)})
                AAdd(aDadoTit, {"F71_CODCLI",   IIf(__lBrowse .Or. lDesdobra, SE1->E1_CLIENTE,  M->E1_CLIENTE)})
                AAdd(aDadoTit, {"F71_LOJCLI",   IIf(__lBrowse .Or. lDesdobra, SE1->E1_LOJA,     M->E1_LOJA)})
                AAdd(aDadoTit, {"F71_IDDOC" ,   FKF->FKF_IDDOC})
                AAdd(aDadoTit, {"F71_SEQ",      Soma1(cSeq)})
                AAdd(aDadoTit, {"F71_VALOR",    IIf(__lBrowse .Or. lDesdobra, SE1->E1_VALOR,    M->E1_VALOR)})
                AAdd(aDadoTit, {"F71_EMISSA",   IIf(__lBrowse .Or. lDesdobra, SE1->E1_EMISSAO,  M->E1_EMISSAO)})
                AAdd(aDadoTit, {"F71_VENCTO",   IIf(__lBrowse .Or. lDesdobra, SE1->E1_VENCREA,  M->E1_VENCREA)})
                AAdd(aDadoTit, {"F71_SOLCAN",   "2"})
                AAdd(aDadoTit, {"F71_STATUS",   "1"})
                AAdd(aDadoTit, {"F71_IDTRAN",   F986IDTran()})
                AAdd(aDadoTit, {"F71_FILBCO",   cFilBco})
                AAdd(aDadoTit, {"F71_CODBAN",   cBanco})
                AAdd(aDadoTit, {"F71_AGENCI",   cAgenci})
                AAdd(aDadoTit, {"F71_NUMCON",   cConta})
                AAdd(aDadoTit, {"F71_TPCHV",    cTpChave})
                AAdd(aDadoTit, {"F71_CHVPIX",   cChavePix})
                
                If __lMultPIX
                    nMultaPIX := IIf(__lPEMlPIX, ExecBlock("FINMULTPIX", .F., .F., nMultaPIX), nMultaPIX)
                    AAdd(aDadoTit, {"F71_MULTA",    nMultaPIX})
                    AAdd(aDadoTit, {"F71_DIAEXP",   nDiasExp})
                EndIf
                
                F986PixE(aDadoTit, "1")
            EndIf
            
            (cTempAlias)->(DbCloseArea())
        EndIf
    EndIf
Return

/*/{Protheus.doc} F986PixE
    Fun��o respons�vel por efetivar as opera��es de inclus�o 
    e altera��o de um registro no monitor pix (F71)

    @param aDadosTit, Array, vetor com os dados do t�tulo
    @param cOperacao, Char, Caracter com a opera��o a ser executada no monitor pix
    
    @author pedro castro
    @since  23/10/2020
    @version P12
/*/
Function F986PixE(aDadosTit As Array, cOperacao As Character, nF71Recno As Numeric)
    Local lTudoOk    As Logical
    Local nOperacao  As Numeric
    Local aAreaAtual As Array
    Local aAreaF71   As Array
    Local oModel     As Object
    Local oF71Model  As Object
    Local nCampo     As Numeric
    Local nQtdCmp    As Numeric
    Local nPosCampo  As Numeric
    Local nPosValor  As Numeric
    
    Default aDadosTit := {}
    Default cOperacao := "1"
    Default nF71Recno := 0
    
    //Inicializa vari�veis
    lTudoOk    := .T.
    nOperacao  := 0
    oModel     := Nil
    oF71Model  := Nil
    aAreaAtual := GetArea()
    aAreaF71   := F71->(GetArea())
    __lExcImpo := IIf(__lExcImpo == Nil, FindFunction("ExcluiImpo"), __lExcImpo) 
    nQtdCmp    := Len(aDadosTit)
    nPosCampo  := 1
    nPosValor  := 2
    
    If cOperacao $ "1|2"        
        nOperacao  := MODEL_OPERATION_INSERT
        
        If cOperacao == "2"
            nOperacao := MODEL_OPERATION_UPDATE 
            DbSelectArea("F71")
            F71->(DbGoTo(nF71Recno))
        EndIf
        
        oModel := FwLoadModel("FINA890")
        oModel:SetOperation(nOperacao)
        oModel:Activate()
    EndIf
    
    oF71Model := oModel:GetModel("FORMF71")
    
    For nCampo := 1 To nQtdCmp
        If !(oF71Model:SetValue(aDadosTit[nCampo][nPosCampo], aDadosTit[nCampo][nPosValor]))
            Exit
        EndIf
    Next nCampo
    
    If (lTudoOk := oModel:VldData())
        lTudoOk := oModel:CommitData()
    EndIf
    
    If !lTudoOk
        VarInfo("",oModel:GetErrorMessage())
    EndIf
    
    oModel:DeActivate()
    oModel:Destroy()    
    oModel := Nil
    
    If __lExcImpo .And. lTudoOk .And. cOperacao == "2" .And. F71->F71_STATUS $ "2|3|4"
        ExcluiImpo(F71->F71_FILIAL, F71->F71_PREFIX, F71->F71_NUM, F71->F71_PARCEL, F71->F71_TIPO, F71->F71_CODCLI, F71->F71_LOJCLI, nF71Recno)
    EndIf
    
    RestArea(aAreaF71)
    RestArea(aAreaAtual)
    FwFreeArray(aAreaF71)
    FwFreeArray(aAreaAtual)
Return Nil

/*/{Protheus.doc} F986FPag
Altera o campo E2_FORMPAG para 47 caso o campo FKF_PAGPIX foi preenchido com um QR code

@author pedro castro
@since  26/10/2020
@version P12
/*/

Static Function F986FPag()

    Local cCampo    as Character
    Local cSX3Campo as Character
    Local cValor    as Character

    Local lRet      as Logical

    Local oModel    as Object
    Local oModFKF   as Object

    cCampo    := "X3_RELACAO"
    cSX3Campo := "FKF_PAGPIX"

    lRet      := .F.

    cValor := InitPad(GetSX3Cache(cSX3Campo, cCampo))

    oModel := FwLoadModel("FINA986")
    oModel:Activate()
    oModFKF := oModel:GetModel("FKFMASTER")

    cFKFPAGPIX := oModFKF:GetValue('FKF_PAGPIX')

    IF !Empty(cFKFPAGPIX) .and. Alltrim(cFKFPAGPIX) <> Alltrim(cValor)
        If SE2->(RLock())
            SE2->E2_FORMPAG := '47'
        EndIf 
    Endif

Return
/*
{Protheus.doc} F986RetSeq
    Retorna maior sequencia das dos registro da F71
    
    @author pedro castro    
    @since  29/10/2020
    
    @param cIdDocF71, Char, Identificador do registro no monitor pix
    registro no monitor pix.
    @return cSeq, Char, Maior sequ�ncia do registro no monitor pix.
*/
Static function F986RetSeq(cIdDocF71 As Character) As Character
    Local cQuery As Character
    Local cSeq   As Character
    Local cTotal As Character
    
    //Par�metros de entrada.
    Default cIdDocF71 := FKF->FKF_IDDOC
    
    //Inicializa vari�veis
    cQuery := ""
    cSeq   := "00"
    cTotal := ""
    
    If __oSeqF71 == Nil
        cQuery := "SELECT MAX(F71_SEQ) NSEQF71 FROM ? "
        cQuery += "WHERE F71_FILIAL = ? "
        cQuery += "AND F71_IDDOC = ? AND D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)
        __oSeqF71 := FWPreparedStatement():New(cQuery)
    EndIf
    
    __oSeqF71:SetNumeric(1, RetSQLName("F71"))    
    __oSeqF71:SetString(2, xFilial("F71"))
    __oSeqF71:SetString(3, cIdDocF71)
    cQuery := __oSeqF71:GetFixQuery()
    cTotal := MpSysExecScalar(cQuery, "NSEQF71")
    
    If !Empty(cTotal)
        cSeq := IIf(cTotal <> cSeq, cTotal, cSeq)
    EndIf
Return cSeq

/*
{Protheus.doc} F986QRCode
Fun��o para proteger a existencia da FinQRCode

@author pedro castro
@return lRet
@since  29/10/2020
@version P12
*/
Function F986QRCode() As Logical

    Local lRet As Logical
    lRet := .T. 

    If __lFinQRCode == Nil
        __lFinQRCode := FindFunction('FinQRCode')
    EndIf 

    If __lFinQRCode
        FinQRCode(M->FKF_PAGPIX,.T.,.F.)
    EndIf 

    If !Empty(Alltrim(M->FKF_PAGPIX)) .AND. SubStr(M->FKF_PAGPIX,1,6) != '000201'
        Help(" ", 1, "QRCODEPIX", Nil, STR0053, 2, 0,,,,,,{STR0054}) //"N�o identificamos no conte�do do campo, um formato de c�digo de QR Code v�lido." // "Verifique o QR Code utilizado!"
        lRet:= .F.
    Endif

Return lRet

/*
{Protheus.doc} F986IDTran
Fun��o para gerar o IDTran para a tabela F71

@author Edson Melo
@return cIdTran
@since  18/11/2020
@version P12
*/
Function F986IDTran() As Character
    Local cIdTran  As Character
    Local nIndice  As Numeric
    Local aArea    As Array
    Local aAreaF71 As Array    
    
    //Inicializa vari�veis        
    cIdTran  := ""    
    nIndice  := 3
    aArea    := GetArea()
    aAreaF71 := {}
    
    DbSelectArea("F71")
    aAreaF71 := F71->(GetArea())            
    cIdTran  := GetSXENum("F71", "F71_IDTRAN", "F71_IDTRAN" + CEMPANT, nIndice)
    
    F71->(DbSetOrder(nIndice))
    While F71->(MsSeek(cIdTran))
        cIdTran  := GetSXENum("F71", "F71_IDTRAN", "F71_IDTRAN" + CEMPANT, nIndice) 
    EndDo
    
    ConfirmSX8()
    RestArea(aAreaF71)
    RestArea(aArea)
    FwFreeArray(aAreaF71)
    FwFreeArray(aArea)
Return cIdTran

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986When
Fun��o para tratar os campos das abas do complemento de impostos

@author Douglas de Oliveira
@since 11/06/2021
@version P12
/*/
//-------------------------------------------------------------------
Static function Fa986When(cCampo As Character) as Logical
    
    Local lRet      as Logical     
    Local cTipos    as Character	 
    Local cTpTab    as Character   
    Local cAliasTab as Character
    Local cRotinas  as Character

    Default cCampo := ""

    lRet        := .T.
    cTipos	    := MVTAXA + "/" + MVINSS + "/" + MVISS + "/" + MVIRF + "/" + "SES/CID/INA/PIS/CSL/COF"
    cTpTab      := ""
    cAliasTab   := ""
    cRotinas    := "MATA103|MATA100|MATA461|MATA460|FINA290|FINA290M|FINA565"
         
    __cAlias986 := IF(ValType(__cAlias986)=="U", "SE2", __cAlias986)
    cAliasTab   := If(__lBrowse, __cAlias986+"->" , "M->")
    cTpTab      := cAliasTab + Right(__cAlias986, 2) + "_TIPO"

    If &cTpTab $ cTipos
         lRet := .F.
    EndIf

    If cCampo == 'FKF_NATREN'
        If (!INCLUI .OR. __lBrowse) .AND. !Empty( &(cAliasTab + Right(__cAlias986, 2) + "_VALOR") <> &(cAliasTab + Right(__cAlias986, 2) + "_SALDO") )
            lRet := .F.
        EndIf
        If lRet .AND. ( AllTrim( &(cAliasTab + Right(__cAlias986, 2) + "_ORIGEM") ) $ cRotinas )
            lRet := .F.
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} GeraPix
    Valida se um determinado tipo de t�tulo
    pode gerar registro no monitor pix

    @author Sivaldo Oliveira
    @since 13/04/2022
    @return lRet, Logical, retorna verdadeiro (.T.) ou falso (.F.),
    (.T.) = Pode gerar registro no monitor pix
    (.F.) = N�o pode gerar no monitor pix
/*/    
Static Function GeraPix(cTipoTit As Char) As Logical
    Local lRet      As Logical
    Local cLista    As Char
    Local dVencto   As Date
    
    Default cTipoTit := ""

    If __lBrowse
        dVencto := SE1->E1_VENCREA
    Else
        dVencto := M->E1_VENCREA
    EndIf
    
    If (lRet   := !Empty(cTipoTit))
        cLista := MVABATIM+"|"+MV_CRNEG+"|"+MVTXA+"|"+MV_CPNEG+"|"+MVPROVIS+"|"+MVINSS
        cLista += "|"+MVISS+"|"+MVIRF+"|"+MVRECANT+"|TX |SES|CID|INA|PIS|CSL|COF"
        
        lRet := !cTipoTit $ cLista
    EndIf 

Return lRet

/*/{Protheus.doc} F986PIXLj
Verifica se o t�tulo PIX originado no Loja.

@author Rafael Riego
@since  19/04/2022
@param  cTipo, character, tipo do t�tulo
@param  cDocTEF, character, preenchido caso seja originado no PDV Loja
@return logical, verdadeiro caso seja PIX originado no PDV loja
/*/   
Static Function F986PIXLj(cTipo As Character, cDocTEF As Character) As Logical

    Local lLoja As Logical

    Default cTipo   := ""
    Default cDocTEF := ""

    lLoja := cTipo $ "PX |PD " .And. !(Empty(cDocTEF))

Return lLoja
//-------------------------------------------------------------------
/*/{Protheus.doc} F986VlNat
Verifica se a natureza de rendimento � valida, a fim de evitar 
problemas na valida��o do EFD-REINF (bloco 40).

@return lRet Retorna .T. se permite selecionar esta natureza

@author Fabio Casagrande Lima
@since 18/10/2022
@version P12
/*/
//-------------------------------------------------------------------
Function F986VlNat() As Logical

    Local lRet      As Logical
    Local cCart     As Character
    Local cForCli   As Character
    Local cLoja     As Character
    Local cNatRen   As Character
    Local cAliasTab As Character
    Local cNatTit   As Character

	lRet 	:= .T.

    If __lBrowse 
        cAliasTab := __cAlias986+"->" 
    Else
        cAliasTab := "M->"
    Endif
    If __cAlias986 == "SE2"
        cCart   := "1"
    Else
        cCart   :="2" 
    EndIf
   
    If __cAlias986 == "SE2"
        cForCli := &( cAliasTab + Right(__cAlias986, 2) + "_FORNECE") 
    Else 
        cForCli := &( cAliasTab + Right(__cAlias986, 2) + "_CLIENTE" ) 
    EndIf
    cLoja   := &( cAliasTab + Right(__cAlias986, 2) + "_LOJA" )
    cNatRen := M->FKF_NATREN
    cNatTit := &( cAliasTab + Right(__cAlias986, 2) + "_NATUREZ" )

    If FindFunction('VldNatRen') //Fun��o do FINXINC
        lRet := VldNatRen(cNatRen, cCart, cForCli, cLoja, cNatTit)
    Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986IrOri
Responsavel por acionar as funcoes de calculo de IR

@author Fabio Casagrande Lima
@since	12/04/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function Fa986IrOri(lIrfRetAnt As Logical) As Numeric

    Local nValIr    As Numeric
    Local lAplTabPr As Logical
	Local cA2IrProg As Char
	Local lSimples	As Logical
    Local lSRefSE2  As Logical

    DEFAULT lIrfRetAnt := .F.

    nValIr    := 0
    lAplTabPr := .T.

	If!Empty(SA2->A2_IRPROG)
        cA2IrProg := SA2->A2_IRPROG
    Else
        cA2IrProg := "2"
    EndIf

	lSimples  := SA2->A2_CALCIRF == "3"
    lSRefSE2 := SED->ED_JURCAP <> "1"

    DbSelectArea("SED")
	SED->(DBSetOrder(1))
    SED->(DBSeek(xFilial("SED") + SE2->E2_NATUREZ))
        
    If ExistBlock("F050ATP")
		lAplTabPr := ExecBlock("F050ATP",.F.,.F.)
	Endif

    If  SED->ED_CALCIRF == "S"
        IF (SA2->A2_TIPO == "F" .OR. (SA2->A2_TIPO == "J" .AND. SA2->A2_IRPROG == "1")) .AND. lAplTabPr 
            nValIr := FCalcIr(SE2->E2_BASEIRF,"F",.T.,@lIrfRetAnt,SED->ED_JURCAP <> "1",,.F.)

        Elseif !lSimples 
            nValIr := FCalcIr(SE2->E2_BASEIRF,"J",.T.,@lIrfRetAnt,,,.F.)
        Endif
    Endif    

	IF ExistBlock("F050CIRF")
		nValIr := ExecBlock("F050CIRF",.f.,.f.,M->E2_BASEIRF)
	Endif

Return nValIr

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986FKG
Fun��o para obter as informa��es dos campos FKG_NUMPRO, FKG_TPPROC e FKG_CODSUS
de acordo com o tipo de imposto da tabela FKG

@author Douglas de Oliveira
@since	07/11/2022
@version 12
/*/
//-------------------------------------------------------------------

Static Function Fa986FKG(oModel As Object,oSubFKG As Object,cTpImp As Character) As Array

Local nI        As Numeric
Local aDadosFKG As Array
Local cNumpro   As Character
Local cTpproc   As Character
Local cCodsus   As Character

Default oModel	:= FWModelActive()
Default oSubFKG := Nil
Default cTpImp  := ""

nI        := 0
aDadosFKG :={}
cNumpro   := ""  
cTpproc   := "" 
cCodsus   := "" 

If oSubFKG == Nil
    oSubFKG:= oModel:GetModel("FKGDETAIL")
EndIf

For nI := 1 To oSubFKG:Length()
    oSubFKG:GoLine(nI)

    If Alltrim(oSubFKG:GetValue("FKG_TPATRB")) == "004" .And. Alltrim(oSubFKG:GetValue("FKG_TPIMP")) == cTpImp
        cNumpro:= oSubFKG:GetValue("FKG_NUMPRO")
        cTpproc:= oSubFKG:GetValue("FKG_TPPROC")
        cCodsus:= oSubFKG:GetValue("FKG_CODSUS")
    Endif

Next nI   

Return {cNumpro,cTpproc,cCodsus}

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986FKW
Fun��o para centralizar a prepa��o da grava��o da FKW

@param cIdDoc, caractere, chave de identifica��o do t�tulo (FK7_IDDOC)
@param cImpos, caractere, identifi��o do imposto "IRF"/"PIS"/"COF"/"CSL"
@param cNatRen, caractere, Natureza de rendimento (FKF_NATREN)
@param nImpCalc, Numeric, Imposto calculado antes da DEDU��O/SUSPENS�O/ISEN��O
@param nVlrImp, Numeric, Imposto que dever� ser retido
@param nBaseBRT, Numeric, Base do imposto bruto, antes da DEDU��O/SUSPENS�O/ISEN��O
@param oModel, Object, Modelo principal de grava��o FKF/FKG
@param oSubFKG, Object, Submodelo de grava��o da FKG
@param aDadosFKW, Array, Array que contem os dados para grava��o da FKW
@param cCartei, caractere, Indica se � contas a 1=pagar ou 2=receber

@author P�mela Bernardo
@since	14/11/2022
@version 12
/*/
//-------------------------------------------------------------------

Static Function Fa986FKW(cIdDoc As Character, cImpos As Character, cNatRen As Character, nImpCalc As Numeric, nVlrImp As Numeric, nBaseBRT As Numeric, oModel As Object, oSubFKG As Object, aDadosFKW As Array, cCartei As Character) As Logical
    Local nPerc         As Numeric
    Local nBasRET       As Numeric
    Local nImpRet       As Numeric
    Local nBasNRet      As Numeric
    Local nImpNRet      As Numeric
    Local cCodProc      As Character
	Local cTpProc       As Character
    Local cIndSusp      As Character
    Local nPercNRet     As Numeric
    Local cFilFKW       As Character
    Local aDadosFKG     As Array
    Local nMoedaTit     As Numeric
    Local nTxMoeda      As Numeric
    Local dDtEmiss      As Date
    
    nPerc        := 0
    nBasRET      := 0
    nImpRet      := 0
    nBasNRet     := 0
	nImpNRet     := 0
    cCodProc     := ""
	cTpProc      := ""
    cIndSusp     := ""
    nPercNRet    := 0
    cFilFKW      := xFilial("FKW")
    aDadosFKG    := {}

    If cCartei == "1"
        nMoedaTit := SE2->E2_MOEDA
        dDtEmiss  := SE2->E2_EMISSAO
        nTxMoeda  := SE2->E2_TXMOEDA
    Else 
        nMoedaTit := SE1->E1_MOEDA
        dDtEmiss  := SE1->E1_EMISSAO
        nTxMoeda  := SE1->E1_TXMOEDA
    EndIf
    
    If nImpCalc > nVlrImp
        nImpNRet := nImpCalc - nVlrImp
    Else
        nImpRet := nVlrImp
    EndIf
    nBasNRet := Round( F986DBase(oModel,oSubFKG,cImpos,cCartei), 2 )
    If nBasNRet > 0
        nPercNRet := 100
    EndIf

    aDadosFKG:= Fa986FKG(oModel,oSubFKG,cImpos)

    If Len(aDadosFKG) > 0 .And. !Empty(aDadosFKG[1])    
        cCodProc  := aDadosFKG[1]
        cTpProc   := aDadosFKG[2]
        cIndSusp  := aDadosFKG[3]
    EndIf
    
    nImpRet   := nVlrImp

    //Converte a base do tributo em moeda forte
    nBasRET   := Round(NoRound(xMoeda(nBaseBRT,nMoedaTit,1,dDtEmiss,__nCasDec,nTxMoeda),,__nCasDec+1),2)
    nBasRET   -= nBasNRet

    If nBasRET > 0
        nPerc := 100
    EndIf  
    
    aAdd(aDadosFKW,{cFilFKW, cIdDoc, cImpos, cNatRen, nPerc, nBasRET, nImpRet, nBasNRet, nImpNRet, cCodProc, cTpProc, cIndSusp, nPercNRet})					
    
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F986DBase
Fun��o para retornar a base n�o retida para os impostos inclusos

@param oModel, Object, Modelo principal de grava��o FKF/FKG
@param oSubFKG, Object, Submodelo de grava��o da FKG
@param cImpos, Char, identifi��o do imposto "IRF"/"PIS"/"COF"/"CSL"
@param cCartei, Char, Indica se � contas a 1=pagar ou 2=receber


@author P�mela Bernardo
@since	16/11/2022
@version 12
/*/
//-------------------------------------------------------------------
Static Function F986DBase(oModel As Object,oSubFKG As Object, cTpImp As Char, cCartei As Char) As Numeric
    Local nBaseDed  As Numeric
    Local nx        As Numeric
    Local lDedINS   As Logical
    Local lSusp     As Logical

    Default oModel	:= FWModelActive()
    Default oSubFKG := Nil
    Default cTpImp  := ""
    Default cCartei := ""
    
    nBaseDed := 0
    nx  := 0
    
    If oSubFKG == Nil
      oSubFKG:= oModel:GetModel("FKGDETAIL")
    EndIf

    For nx := 1 To oSubFKG:Length()
        oSubFKG:GoLine(nx)
        If (Alltrim(oSubFKG:GetValue("FKG_DEDACR")) == "1" .And. Alltrim(oSubFKG:GetValue("FKG_APLICA")) == "1" .And. Alltrim(oSubFKG:GetValue("FKG_TPIMP")) == cTpImp)
            nBaseDed+= oSubFKG:GetValue("FKG_VALOR")
        Endif
    Next nx   

    lSusp := Alltrim(oSubFKG:GetValue("FKG_TPATRB")) == "004" //PROCESSO JUDICIAL/ADM

    If cCartei == "1" .and. !lSusp //Contas a Pagar 
        lDedINS	:=(SuperGetMv("MV_INSIRF",.F.,"2") == "1" .And. (SA2->A2_TIPO == "F" .OR. (SA2->A2_TIPO == "J" .AND. SA2->A2_IRPROG == "1")))
        If lDedINS .and. cTpImp = "IRF"
            nBaseDed += SE2->E2_INSS
        EndIf 
    EndIf

Return nBaseDed

//-------------------------------------------------------------------
/*/{Protheus.doc} F986Deduz
Fun��o para retornar a dedu��o de base dos impostos, gravados na FKG

@param cIdDoc, caractere, chave de identifica��o do t�tulo (FK7_IDDOC)
@param cImpos, caractere, identifi��o do imposto "IRF"/"PIS"/"COF"/"CSL"

@author P�mela Bernardo
@since	17/11/2022
@version 12
/*/
//-------------------------------------------------------------------

Function F986Deduz(cIddoc As Character, cTpImp As Character) As Numeric
    Local nBaseDed  As Numeric
    Local nx        As Numeric
    Local cQuery    As Character

    Default cIddoc  := ""
    Default cTpImp  := ""
    
    nBaseDed    := 0
    nx          := 0
    cQuery      := ""

    If __oFKGBase == NIL

        cQuery := "SELECT SUM(FKG_VALOR) VALOR "
        cQuery += "FROM " + RetSqlName("FKG") + " FKG "
        cQuery += "WHERE  FKG_FILIAL = '"+xFilial("FKG")+"' "
        cQuery += "AND FKG_IDDOC =  ? "
        cQuery += "AND FKG_TPIMP =  ? "
        cQuery += "AND FKG_DEDACR ='1' "
        cQuery += "AND FKG_APLICA = '1' "
        cQuery += "AND FKG.D_E_L_E_T_ = ' ' "
        __oFKGBase := FWPreparedStatement():New(cQuery)   

    EndIf

    __oFKGBase:SetString(1,  cIddoc)
    __oFKGBase:SetString(2,  cTpImp)

    cQuery := __oFKGBase:GetFixQuery()

    nBaseDed := MpSysExecScalar(cQuery,"VALOR")

Return nBaseDed

//-------------------------------------------------------------------
/*/{Protheus.doc} F986RImp
Fun��o para se houve recalculo de impostos

@author P�mela Bernardo
@since	21/11/2022
@version 12
/*/
//-------------------------------------------------------------------

Function F986RImp() 
Return __lAltImp

//-------------------------------------------------------------------
/*/{Protheus.doc} F986PcCgc(cCampo)
Retorna a Picture vari�vel para os campos de CNPJ/CPF

@param cCampo Campo o qual est� sendo validado para obter a picture

@return  cRet - Picture para o campo

@author P�mela Bernardo
@since 25/11/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function F986PcCgc(cCampo As Character) As Character

	Local oModel as Object
	Local cRet   as Char
	Local cCnpj  as Char

	DEFAULT cCampo := "FKF_CGCSCP"

	oModel := FWModelActive()
	cRet   := ""
	cCnpj  := ""	

	cCnpj := Alltrim(oModel:GetValue("FKFMASTER", cCampo))

	cRet := PICPES(If(Len(cCnpj) > 11 , "J", "F"))

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986VlCgc()
Fun��o para vali��o do campo FKF_CGCSCP, usado diretamente no SX3 do campo

@author P�mela Bernardo
@since 28/11/2022
@version P12
/*/
//-------------------------------------------------------------------
Function F986VlCgc() As Logical

	Local lRet   as Logical
	Local cCnpj  as Char

	cCnpj := FwFldGet("FKF_CGCSCP")
    lRet   := Cgc(cCnpj)
    
    DbSelectArea("FOD")
    FOD->(DbSetOrder(4)) //FOD_FILIAL+FOD_CGCSCP
    
    If lRet .And. !(FOD->(MsSeek(xFilial("FOD")+cCnpj)))
        Help( ,,"CGCSCP",,STR0059, 1, 0,,,,,,{STR0060})  //"Campo o CNPJ SCP inv�lido" ## "Informe um CNPJ/CPF que exista no cadastro de SCP"
        lRet := .F.
    EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986PccPub
Fun��o para calcular o PCC de empresa publica.

@author P�mela Bernardo
@since	02/12/2022
@version 12
/*/
//-------------------------------------------------------------------
Static Function F986PccPub(nBasePis As Numeric, nBaseCof As Numeric, nBaseCsl As Numeric, lIrfRetAnt as Logical, nValIrrf As Numeric) As Array

    Local aRetPcc    As Array

    Default nBasePis := SE2->E2_BASEPIS
    Default nBaseCof := SE2->E2_BASECOF
    Default nBaseCsl := SE2->E2_BASECSL
    Default lIrfRetAnt := .F.
    Default nValIrrf := 0
    aRetPcc := Array(5)

    If Type("aDadosRet") != "A"
        aDadosRet   := Array(5)
    EndIf

    aRetPcc := CalcEmpP(nBasePis,nBaseCof,nBaseCsl)
    If !__lPCCBx
        If __lBrowse
            RegToMemory("SE2",.F.,.F.)
            Afill(aDadosRet,0)
        EndIf
        FVerMinImp(nBasePis, .T.,lIrfRetAnt)
        aRetPcc[2] += aDadosRet[2]
        aRetPcc[3] += aDadosRet[3]
        aRetPcc[4] += aDadosRet[4]

        If SA2->A2_MINPUB == "2" .And. aRetPcc[2]+aRetPcc[3]+aRetPcc[4]+nValIrrf < __nVlMPub .And. !lIrfRetAnt;
            .Or. (__lBrowse .and. SE2->E2_PIS+SE2->E2_COFINS+SE2->E2_CSLL+SE2->E2_IRRF < __nVlMPub)
            aRetPcc[2] := 0
            aRetPcc[3] := 0
            aRetPcc[4] := 0
            nValIrrf   := 0
        EndIf
    EndIf 

Return aRetPcc

/*/{Protheus.doc} F986AltPix
    Modifica o status do registro na tabela F71 para 
    altera��o solicitada (9), e cria nova sequ�ncia do
    registro com status de aguardando integra��o (1) 
    
    @author Victor Azevedo
    @since  08/12/2022
    @version P12
/*/
Function F986AltPix(cChaveTit As Character, cFilOrig As Character, lGeraF71 As Logical)
    Local lRet       As Logical   
    Local cIdDocF71  As Character
    Local cFilF71    As Character
    Local cIdTran    As Character
    Local nValorF71  As Numeric
    Local nRecnoF71  As Numeric
    Local dDataVenc  As Date
    Local aAreaAtual As Array
    Local aAreaF71   As Array
    Local aAreaFKF   As Array
    Local aDadoTit   As Array
    
    //Par�metros de entrada
    Default cChaveTit := ""
    Default cFilOrig  := cFilAnt
    Default lGeraF71  := .T.
    
    //Inicializa vari�veis.    
    lRet       := .T.
    cIdDocF71  := ""    
    cFilF71    := ""
    cIdTran    := ""
    nValorF71  := 0
    nRecnoF71  := 0
    dDataVenc  := dDataBase
    aAreaAtual := Nil
    aAreaF71   := Nil
    aAreaFKF   := Nil
    aDadoTit   := Nil
    
    If cPaisLoc == "BRA" .And. !Empty(cChaveTit)
        cIdDocF71 := FINBuscaFK7(cChaveTit, "SE1", cFilOrig)
        
        If !Empty(cIdDocF71)
            cFilF71    := xFilial("F71", cFilOrig)
            aAreaAtual := GetArea()
            aAreaF71   := F71->(GetArea())
            aAreaFKF   := FKF->(GetArea())
            
            DbSelectArea("FKF")
            DbSelectArea("F71")    
            FKF->(DbSetOrder(1))
            F71->(DbSetOrder(1))
            
            If F71->(DbSeek(cFilF71+cIdDocF71))
                While !F71->(Eof()) .And. F71->(F71->F71_FILIAL+F71_IDDOC) == (cFilF71+cIdDocF71)
                    If F71->F71_STATUS == "1"
                        nRecnoF71 := 0
                        
                        If lGeraF71 .And. !FwIsInCallStack("Fa986Conf")
                            nRecnoF71 := F71->(Recno())
                        EndIf
                        
                        Exit                    
                    ElseIf F71->F71_STATUS $ "2|5|6|7|8|A|9"
                        If M->FKF_RECPIX == "1" .And. F71->F71_STATUS == "7" .And. !__lGerF71
                            nRecnoF71 := F71->(Recno())
                            Exit
                        EndIf
                        
                        F71->(DbSkip())
                        Loop
                    ElseIf F71->F71_SOLCAN != "2"
                        nRecnoF71 := F71->(Recno())
                        F71->(DbSkip())
                        Loop
                    EndIf
                    
                    nRecnoF71 := F71->(Recno())
                    Exit
                EndDo
                
                If nRecnoF71 > 0
                    If __lTemDic == Nil
                        __lTemDic := F71->(FieldPos("F71_DIAEXP")) > 0 .And. F71->(FieldPos("F71_MULTA")) > 0
                    EndIf
                    
                    F71->(DbGoto(nRecnoF71))
                    nValorF71 := F71->F71_VALOR 
                    dDataVenc := F71->F71_VENCTO
                    
                    If ((M->E1_VALOR != Nil .And. !Empty(M->E1_VALOR)) .Or. (SE1->E1_VALOR != Nil .And. !Empty(SE1->E1_VALOR)))
                        nValorF71 := SE1->E1_VALOR
                    EndIf
                    
                    If ((M->E1_VENCREA != Nil .And. !Empty(M->E1_VENCREA)) .Or. (SE1->E1_VENCREA != Nil .And. !Empty(SE1->E1_VENCREA)))
                        dDataVenc := SE1->E1_VENCREA
                    EndIf                    
                    
                    If ((lGeraF71 .And. F71->F71_STATUS != "1") .Or. (F71->F71_STATUS $ "3|4")) .And. F71->F71_SOLCAN == "2"
                        RecLock("F71")
                        F71->F71_STATUS := "9"
                        F71->(MsUnlock())
                    EndIf                    
                    
                    aDadoTit := {}
                    AAdd(aDadoTit, {"F71_PREFIX", F71->F71_PREFIX})
                    AAdd(aDadoTit, {"F71_NUM",    F71->F71_NUM})
                    AAdd(aDadoTit, {"F71_TIPO",   F71->F71_TIPO})
                    AAdd(aDadoTit, {"F71_PARCEL", F71->F71_PARCEL})
                    AAdd(aDadoTit, {"F71_CODCLI", F71->F71_CODCLI})
                    AAdd(aDadoTit, {"F71_LOJCLI", F71->F71_LOJCLI})
                    AAdd(aDadoTit, {"F71_IDDOC",  F71->F71_IDDOC})
                    AAdd(aDadoTit, {"F71_EMISSA", F71->F71_EMISSA})                    
                    AAdd(aDadoTit, {"F71_VENCTO", dDataVenc})
                    AAdd(aDadoTit, {"F71_VALOR",  nValorF71})                    
                    AAdd(aDadoTit, {"F71_SEQ", Soma1(F986RetSeq(cIdDocF71))})
                    AAdd(aDadoTit, {"F71_SOLCAN", "2"})
                    AAdd(aDadoTit, {"F71_STATUS", "1"})
                    
                    If F71->F71_SOLCAN == "2"
                        AAdd(aDadoTit, {"F71_IDTRAN", F71->F71_IDTRAN})
                    Else
                        AAdd(aDadoTit, {"F71_IDTRAN", F986IDTran()})
                        
                        If FKF->(DbSeek(xFilial("FKF")+cIdDocF71)) .And. FKF->FKF_RECPIX != "1" 
                            RecLock("FKF")
                            FKF->FKF_RECPIX	:= "1"
                            FKF->(MsUnlock())
                        EndIf                    
                    EndIf
                    
                    AAdd(aDadoTit, {"F71_FILBCO", F71->F71_FILBCO})
                    AAdd(aDadoTit, {"F71_CODBAN", F71->F71_CODBAN})
                    AAdd(aDadoTit, {"F71_AGENCI", F71->F71_AGENCI})
                    AAdd(aDadoTit, {"F71_NUMCON", F71->F71_NUMCON})
                    AAdd(aDadoTit, {"F71_TPCHV",  F71->F71_TPCHV })
                    AAdd(aDadoTit, {"F71_CHVPIX", F71->F71_CHVPIX})
                    
                    If __lTemDic
                        AAdd(aDadoTit, {"F71_MULTA",  F71->F71_MULTA })
                        AAdd(aDadoTit, {"F71_DIAEXP", F71->F71_DIAEXP})
                    EndIf
                    
                    If lGeraF71 .And. F71->F71_STATUS == "1"
                        F982MntPIX(aDadoTit, "2", nRecnoF71, Nil)
                    Else
                        F986PixE(aDadoTit, "1")                    
                    EndIf
                    
                    FwFreeArray(aDadoTit)
                EndIf
            EndIf
            
            RestArea(aAreaF71)
            RestArea(aAreaFKF)
            RestArea(aAreaAtual)
            FwFreeArray(aAreaF71)
            FwFreeArray(aAreaFKF)
            FwFreeArray(aAreaAtual)
        EndIf
    EndIf
Return Nil   

/*/{Protheus.doc} F986IniNat
    Inicializa o campo de natureza de rendimento de acordo
    com o informado na natureza financeira
    
    @author rodrigo.oliveira
    @since  22/02/2023
    @version P12
/*/

Function F986IniNat() As Char
    Local cRet      As Char
    Local aArea     As Array
    Local cAliasTab As Character
    
	lRet 	:= .T.

    If __lBrowse 
        cAliasTab := __cAlias986+"->" 
    Else
        cAliasTab := "M->"
    EndIf
        
    cRet     := ""
        
    If __lEDNTREN
        aArea   := SED->(GetArea())

            If __cAlias986 == "SE2" 
                If !Alltrim(&(cAliasTab + "E2_ORIGEM")) $ "MATA103|MATA100|FINA290|FINA290M|FINA565"
                    cRet    := GetAdvFVal("SED","ED_NATREN",xFilial("SED") + &(cAliasTab + "E2_NATUREZ") )
                    If !VldNatRen( cRet, "1", &(cAliasTab + "E2_FORNECE"), &(cAliasTab + "E2_LOJA"), &(cAliasTab + "E2_NATUREZ") )
                        cRet    := ''
                    EndIf
                EndIf    

            ElseIf !Alltrim(&(cAliasTab + "E1_ORIGEM")) $ "MATA460|MATA461|FINA460"
                cRet    := GetAdvFVal("SED","ED_NATREN",xFilial("SED") + &(cAliasTab + "E1_NATUREZ") )
                If !VldNatRen( cRet, "2", &(cAliasTab + "E1_CLIENTE"), &(cAliasTab + "E1_LOJA"), &(cAliasTab + "E1_NATUREZ") )
                    cRet    := ''
                EndIf
            EndIf

        RestArea(aArea)
    EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986WhnFKG
Fun��o para tratar a edi��o do campo FKG_INSPRE

@author Douglas de Oliveira
@since 27/02/2023
@version P12
/*/
//-------------------------------------------------------------------
Static function F986WhnFKG() As Logical
    
    Local lRet    As Logical
    Local lTpaTRB As Logical
    Local oModel  As Object
    Local oSubFKG As Object

    lRet    := .T.
    oModel  := FWModelActive()
    oSubFKG := oModel:GetModel("FKGDETAIL")
    lTpaTRB := Alltrim(oSubFKG:GetValue("FKG_TPATRB")) == "010" .Or. Alltrim(oSubFKG:GetValue("FKG_TPATRB")) == "011" .Or. Alltrim(oSubFKG:GetValue("FKG_TPATRB")) == "012" 

    If !lTpaTRB
        lRet := .F.
    EndIf

Return lRet

/*/{Protheus.doc} F986NatRen
    Valida se a natureza de rendimento
    informada � uma natureza v�lida
    
    @author rodrigo.oliveira
    @since  27/02/2023
    @version P12
/*/
Function F986NatRen(cAls As Char, lLoad As Logical, cNatur As Char, lHelp) As Logical
    Local lRet      As Logical
    Local cNatRen   As Char
    Local cAliasTab As Char
    Local aArea     As Array

    Default cAls    := "SE2"
    Default lLoad   := .F.
    Default cNatur  := ""
    Default lHelp   := .T.

    lRet        := .T.
    cNatRen     := ''
    cAliasTab   := If(__lBrowse, cAls+"->" , "M->")

    If __lErase
        If lLoad
            Return .F.
        Else
            Return .T.
        EndIf
    EndIf

    If __lEDNTREN == Nil
        __lEDNTREN := cPaisLoc == "BRA" .And. SED->(ColumnPos("ED_NATREN")) > 0
    EndIf

    If __lEDNTREN
        aArea   := SED->(GetArea())

        If cAls == "SE2"
            cNatur  := If(Empty(cNatur), &(cAliasTab + "E2_NATUREZ"), cNatur)
            cNatRen := GetAdvFVal("SED","ED_NATREN",xFilial("SED") + cNatur )
            lRet    := VldNatRen( cNatRen, "1", &(cAliasTab + "E2_FORNECE"), &(cAliasTab + "E2_LOJA"), cNatur, lHelp )
        Else
            cNatur  := If(Empty(cNatur), &(cAliasTab + "E1_NATUREZ"), cNatur)
            cNatRen := GetAdvFVal("SED","ED_NATREN",xFilial("SED") + cNatur )
            lRet    := VldNatRen( cNatRen, "2", &(cAliasTab + "E1_CLIENTE"), &(cAliasTab + "E1_LOJA"), cNatur, lHelp )
        EndIf

        If !lRet
            If lHelp
                If !IsBlind()
                    lRet    := MsgYesNo(STR0069) // "Deseja prosseguir com a inclus�o / altera��o do t�tulo assim mesmo?"
                Else
                    lRet    := .T.
                EndIf
                If lRet
                    Help( ,,"FKFNONATREN",, STR0070, 1, 0 )	// "O t�tulo ser� cadastrado / alterado sem (altera��o na) natureza de rendimento. (EFD-Reinf)"
                EndIf
            EndIf
        EndIf

        RestArea(aArea)
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986VlDep
Fun��o para validar a existencia do dependente do fornecedor (DHT)

@author Rodrigo Oliveira
@since 13/03/2023
@version P12
/*/
//-------------------------------------------------------------------
Function F986VlDep(cIdFke As Char) As Logical
    
    Local lRet      As Logical
    Local aArea     As Array
    Local cCodDep   As Char
    Local cCodForn  As Char
    Local cFil      As Char
    
    Default cIdFke  := FwFldGet("FKG_IDFKE")

    cFil    := FwxFilial("DHT")
    
    If __lBrowse 
        cAliasTab := __cAlias986+"->" 
    Else
        cAliasTab := "M->"
    EndIf
    
    lRet        := .F.
    
    If __cAlias986 == "SE2" .And. GetAdvFVal("FKE","FKE_CARTEI",xFilial("FKE") + cIdFke ) $ '1|3'
        
        If Empty(FwFldGet("FKG_CODDEP"))
            lRet    := .T.
        Else
            aArea       := DHT->(GetArea())
            cCodDep     := FwFldGet("FKG_CODDEP")
            cCodForn    := ""
            
            cCodForn    := &(cAliasTab + "E2_FORNECE") + &(cAliasTab + "E2_LOJA")
            If DHT->(DbSeek(xFilial("DHT") + cCodForn) )
                While !lRet .And. DHT->DHT_FILIAL == cFil .And. DHT->DHT_FORN + DHT->DHT_LOJA == cCodForn
                    If cCodDep == DHT->DHT_COD
                        lRet    := .T.
                        Exit
                    EndIf
                    DHT->(DbSkip())
                EndDo
            EndIf
            
            RestArea(aArea)
        EndIf
    EndIf

Return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} F986Recalc
Verifica se deve haver o recalculo dos impostos ao confirmar a tela de 
complemento de t�tulos (FINA986).

@author fabio.casagrande
@since  15/03/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function F986Recalc(oModel As Object) As Logical

    Local lRet As Logical
    Local lContinua As Logical
    Local oSubFKG As Object
    Local nX As Numeric

    Default oModel := FWModelActive()

    lRet := .F.

    lContinua := Fa986Folder("2") //Se a aba 'Titulos x Impostos' nao for exibida, nao deve recalcular os impostos

    If lContinua 
        lContinua := F986CalImp() //Verifica se o t�tulo possui IR, PCC ou INSS
        If lContinua
            oSubFKG:= oModel:GetModel("FKGDETAIL")
            For nX := 1 To oSubFKG:Length()
                oSubFKG:GoLine( nX )
                If !oSubFKG:IsDeleted() .And. !Empty(oSubFKG:GetValue("FKG_IDFKE"))
                    lRet := .T.
                    Exit
                EndIf
            Next   
        EndIf
    EndIf

Return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} F986CalImp
Retorna se o cliente/fornecedor e natureza est�o configurados para reter
algum dos impostos liberados para serem utilizados no EFD-REINF (IR, PCC ou INSS)

@author fabio.casagrande
@since  15/03/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function F986CalImp() As Logical

    Local lRet   	As Logical
    Local lSeekED   As Logical
    Local lCliFor   As Logical
    Local cAliasTab As Character
    Local cNatu     As Character
    Local cForCli   As Character
    Local cLoja     As Character

    lRet   	:= .F.
    lSeekED := .F.
    lCliFor := .F.

    If __lBrowse
        cAliasTab:= __cAlias986 +"->"
    Else 
        cAliasTab:= "M->"
    EndIf

    If __cAlias986=="SE1"
        cNatu   := &(cAliasTab + Right(__cAlias986, 2) + "_NATUREZ")
        cForCli	:= &(cAliasTab + Right(__cAlias986, 2) + "_CLIENTE")
        cLoja   := &(cAliasTab + Right(__cAlias986, 2) + "_LOJA")

        SA1->(DBSetOrder(1))
        lCliFor := SA1->(DBSeek(xFilial('SA1')+cForCli+cLoja))
    Else
        cNatu   := &(cAliasTab + Right(__cAlias986, 2) + "_NATUREZ")
        cForCli	:= &(cAliasTab + Right(__cAlias986, 2) + "_FORNECE")
        cLoja   := &(cAliasTab + Right(__cAlias986, 2) + "_LOJA")

        SA2->(DBSetOrder(1))
        lCliFor := SA2->(DBSeek(xFilial('SA2')+cForCli+cLoja))
    EndIf

    //Posiciona na Natureza
    SED->( DBSetOrder(1) )
    lSeekED := SED->( DBSeek(xFilial('SED') + cNatu  ) )

    If lSeekED .and. lCliFor
        If __cAlias986=="SE1" //Carteira a Receber
                lRet := (SED->ED_CALCIRF == "S" .And. SED->ED_RECIRRF == "2" .Or. ; 
                        (SA1->A1_RECIRRF == "2" .And. SED->ED_RECIRRF <> "1")) .Or. ;
                        (SA1->A1_RECINSS == 'S')
        Else //Carteira a Pagar
                lRet := (SED->ED_CALCINS == 'S' .and. SA2->A2_RECINSS == 'S') .Or.;
                        (SED->ED_CALCIRF == 'S' ) .Or.;
                        (SED->ED_CALCPIS == 'S' .and. SA2->A2_RECPIS  == '2') .Or.;
                        (SED->ED_CALCCOF == 'S' .and. SA2->A2_RECCOFI == '2') .Or.;
                        (SED->ED_CALCCSL == 'S' .and. SA2->A2_RECCSLL == '2') 
        EndIf
    EndIf

Return lRet
