#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA312.CH"
#Include "Dbstruct.ch"

Static cPart := ""
Static lPart := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA312
Rotina que irá fazer o cadastro das informações para o registro 1601 do SPED FISCAL, com opção de importação de infos do financeiro.
@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210

/*/
//-------------------------------------------------------------------
Function FISA312()
Local oBrw		:= FWmBrowse():New()
Local cDescric	:= STR0001//"Opções com instrumentos de pagamentos eletrônicos para o registro 1601"

IF aliasindic("CJQ") .and. aliasindic("CJR")
	PRIVATE cAlias	:= "CJQ"

	oBrw:SetDescription(cDescric)
	oBrw:SetAlias( cAlias)
	oBrw:Activate()  
Else
	Help(" ",1,"Help","Help",STR0002,1,0)//'Dicionário desatualizado, favor verificar atualizações do Dicionário de dados'
EndIF

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   

Local aRotina	:= {}

	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA312' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA312' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA312' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA312' OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina TITLE STR0007 ACTION 'PERG312'	      OPERATION 3 ACCESS 0 // Processar valores baixados do financeiro

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruGener := Nil
Local oStruItem  := Nil
Local oModel

Default cAlias := "CJQ"

oStruGener := FWFormStruct( 1,cAlias)

//Estrutura do grid
oStruItem := FWFormStruct(1,"CJR")

oModel	:=	MPFormModel():New('FISA312MOD',,{ |oModel| ValidForm(oModel) })

AddCampos(@oStruGener,1)

oModel:AddFields( 'FISA312MOD' ,, oStruGener )

//Adicionando o grid  com o detalhamento dos pagtos
oModel:AddGrid( 'FISA312ITEM', 'FISA312MOD', oStruItem)
oModel:SetRelation( 'FISA312ITEM', { { 'CJR_FILIAL', 'xFilial( "CJR" )' }, { 'CJR_MANAUT', 'CJQ_MANAUT' }  },CJR->( IndexKey( 1 ) )  )
oModel:SetPrimaryKey( { "CJR_MANAUT","CJR_ITEM" } )
oModel:SetOptional("FISA312ITEM", .T.)

if cAlias == 'CJQ'
    oStruGener:SetProperty( 'CJQ_PERIOD' , MODEL_FIELD_WHEN  , { || (oModel:GetOperation()==3) })
    oStruGener:SetProperty( 'CJQ_TPPAR'  , MODEL_FIELD_WHEN  , { || (oModel:GetOperation()==3) })

    oStruGener:SetProperty( 'CJQ_CLIFOR' , MODEL_FIELD_WHEN  , { || oModel:GetOperation()==3 .and. A312CanEd("CJQ_CLIFOR",'FISA312MOD','VIEW_GEN') } )
    oStruGener:SetProperty( 'CJQ_LOJA'   , MODEL_FIELD_WHEN  , { || oModel:GetOperation()==3 .and. A312CanEd("CJQ_LOJA",'FISA312MOD','VIEW_GEN') } )

    oStruGener:SetProperty( 'CJQ_BANCO' , MODEL_FIELD_WHEN  , { || oModel:GetOperation()==3 .and. A312CanEd("CJQ_BANCO",'FISA312MOD','VIEW_GEN') } )
    oStruGener:SetProperty( 'CJQ_AGENC' , MODEL_FIELD_WHEN  , { || oModel:GetOperation()==3 .and. A312CanEd("CJQ_AGENC",'FISA312MOD','VIEW_GEN') } )
    oStruGener:SetProperty( 'CJQ_NUMCON', MODEL_FIELD_WHEN  , { || oModel:GetOperation()==3 .and. A312CanEd("CJQ_NUMCON",'FISA312MOD','VIEW_GEN') } )

    oStruGener:SetProperty('CJQ_CLIFOR', MODEL_FIELD_VALID , {|| ValidCpo('FISA312MOD','CJQ_CLIFOR') })
	oStruGener:SetProperty('CJQ_LOJA'  , MODEL_FIELD_VALID , {|| ValidCpo('FISA312MOD','CJQ_LOJA'  ) })
	oStruGener:SetProperty('CJQ_BANCO' , MODEL_FIELD_VALID , {|| ValidCpo('FISA312MOD','CJQ_BANCO' ) })
    oStruGener:SetProperty('CJQ_AGENC' , MODEL_FIELD_VALID , {|| ValidCpo('FISA312MOD','CJQ_AGENC' ) })
	oStruGener:SetProperty('CJQ_NUMCON', MODEL_FIELD_VALID , {|| ValidCpo('FISA312MOD','CJQ_NUMCON') })

    oStruGener:SetProperty('CJQ_PERIOD'  , MODEL_FIELD_VALID , {|| ValidRegex('FISA312MOD','CJQ_PERIOD'  ) })
endif


Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local	oModel 		:= 	FWLoadModel('FISA312')
Local	oStruGener 	:= 	Nil
Local	oView 		:= 	FWFormView():New() 


Default cAlias := "CJQ"

oView:SetModel(oModel)
oStruGener	:= 	FWFormStruct(2,cAlias)
oStruItem	:= 	FWFormStruct(2,"CJR")

AddCampos(@oStruGener,2)

oStruGener:AddGroup( 'GRUPO01', OemToAnsi(STR0017), '', 2 )//"Definição do período"
oStruGener:AddGroup( 'GRUPO02', OemToAnsi(STR0018), '', 2 )//"Definição do participante"
oStruGener:AddGroup( 'GRUPO03', OemToAnsi(STR0019), '', 2 )//"Definições de valores"


if F312USADO("CJQ_PERIOD")
    oStruGener:SetProperty( 'CJQ_PERIOD'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
endif
if F312USADO("CJQ_TPPAR")
    oStruGener:SetProperty( 'CJQ_TPPAR'     ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
endif
if F312USADO("CJQ_CLIFOR")
    oStruGener:SetProperty( 'CJQ_CLIFOR'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
endif
if F312USADO("CJQ_LOJA")
    oStruGener:SetProperty( 'CJQ_LOJA'      ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
endif
if F312USADO("CJQ_BANCO")
    oStruGener:SetProperty( 'CJQ_BANCO'     ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
endif
if F312USADO("CJQ_AGENC")
    oStruGener:SetProperty( 'CJQ_AGENC'     ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
endif
if F312USADO("CJQ_NUMCON")
    oStruGener:SetProperty( 'CJQ_NUMCON'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
endif
if F312USADO("CJQ_INTERM")
    oStruGener:SetProperty( 'CJQ_INTERM'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
endif
if F312USADO("CJQ_DESPAR")
    oStruGener:SetProperty( 'CJQ_DESPAR'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
endif
if F312USADO("CJQ_DESINT")
    oStruGener:SetProperty( 'CJQ_DESINT'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
endif
if F312USADO("CJQ_TOTVS")
    oStruGener:SetProperty( 'CJQ_TOTVS'     ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
endif
if F312USADO("CJQ_TOTISS")
    oStruGener:SetProperty( 'CJQ_TOTISS'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
endif
if F312USADO("CJQ_TOTOUT")
    oStruGener:SetProperty( 'CJQ_TOTOUT'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
endif

oView:AddField( 'VIEW_GEN'  , oStruGener, 'FISA312MOD' )
oView:AddGrid(  'VIEW_ITEM' , oStruItem , 'FISA312ITEM' )

oView:CreateHorizontalBox( 'SUPERIOR'  , 60 )
oView:CreateHorizontalBox( 'INFERIOR'  , 40 )


if F312USADO("CJQ_CLIFOR")
//Consulta F3
    oStruGener:SetProperty( 'CJQ_CLIFOR' , MVC_VIEW_LOOKUP  , { || A312ChgF3("CJQ_CLIFOR",'FISA312MOD') } )
endif
if F312USADO("CJQ_TPPAR")
    //Indica se o campo é editável
    oView:SetFieldAction( 'CJQ_TPPAR' , { || F312TpPar('FISA312MOD','VIEW_GEN') } )
endif
if F312USADO("CJQ_CLIFOR")
    oView:SetFieldAction( 'CJQ_CLIFOR', { || F312CODPAR('FISA312MOD','VIEW_GEN') } )
endif
if F312USADO("CJQ_LOJA")
    oView:SetFieldAction( 'CJQ_LOJA'  , { || F312CODPAR('FISA312MOD','VIEW_GEN') } )
endif
if F312USADO("CJQ_BANCO")
    oView:SetFieldAction( 'CJQ_BANCO' , { || F312CODPAR('FISA312MOD','VIEW_GEN') } )
endif
if F312USADO("CJQ_AGENC")
    oView:SetFieldAction( 'CJQ_AGENC' , { || F312CODPAR('FISA312MOD','VIEW_GEN') } )
endif
if F312USADO("CJQ_NUMCON")
    oView:SetFieldAction( 'CJQ_NUMCON', { || F312CODPAR('FISA312MOD','VIEW_GEN') } )
endif
                                                                                             
oStruGener:RemoveField( 'CJQ_CODPAR' )
oStruGener:RemoveField( 'CJQ_MANAUT' )
oStruItem:RemoveField( 'CJR_MANAUT' )

oView:SetViewProperty("VIEW_ITEM", "ONLYVIEW") //deixar somente visual o grid
oView:SetNoDeleteLine("VIEW_ITEM") //não pode receber exclusão de linha
oView:SetNoInsertLine("VIEW_ITEM") //não pode receber inserção de linha

oView:SetOwnerView( 'VIEW_GEN'   , 'SUPERIOR'   )
oView:SetOwnerView( 'VIEW_ITEM'  , 'INFERIOR'   )

oView:EnableTitleView('VIEW_ITEM'  , STR0020)//"Detalhamento das operações importadas pelo facilitador"

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} AddCampos
Funcao generica para adicionar campos no model e view


@author Matheus Massarotto
@since 02/05/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static function AddCampos(oStruGener,nOpc)
if nOpc==1
	oStruGener:AddField( ;                    // Ord. Tipo Desc.
                        STR0021                                                     , ;      // [01]  C   Titulo do campo //"Desc Part"
                        STR0022                                                     , ;      // [02]  C   ToolTip do campo //"Descrição Partici"
                        "CJQ_DESPAR"                                                , ;      // [03]  C   Id do Field
                        'C'                                                         , ;      // [04]  C   Tipo do campo
                        FWSX3Util():GetFieldStruct("A1_NOME")[3]                    , ;      // [05]  N   Tamanho do campo
                        0                                                           , ;      // [06]  N   Decimal do campo
                        NIL                                                         , ;      // [07]  B   Code-block de validação do campo
                        NIL                                                         , ;      // [08]  B   Code-block de validação When do campo
                        NIL                                                         , ;      // [09]  A   Lista de valores permitido do campo
                        NIL                                                         , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
                        &( ' { | oModel |  F312IniCpo(oModel,"CJQ_DESPAR") } ' )    , ;      // [11]  B   Code-block de inicializacao do campo
                        NIL                                                         , ;      // [12]  L   Indica se trata-se de um campo chave
                        NIL                                                         , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.                                                         )        // [14]  L   Indica se o campo é virtual

	oStruGener:AddField( ;                    // Ord. Tipo Desc.
                        STR0023                                                     , ;      // [01]  C   Titulo do campo //"Desc Interm"
                        STR0024                                                     , ;      // [02]  C   ToolTip do campo //"Descrição Intermediário"
                        "CJQ_DESINT"                                                , ;      // [03]  C   Id do Field
                        'C'                                                         , ;      // [04]  C   Tipo do campo
                        FWSX3Util():GetFieldStruct("A1U_NOME")[3]                   , ;      // [05]  N   Tamanho do campo
                        0                                                           , ;      // [06]  N   Decimal do campo
                        NIL                                                         , ;      // [07]  B   Code-block de validação do campo
                        NIL                                                         , ;      // [08]  B   Code-block de validação When do campo
                        NIL                                                         , ;      // [09]  A   Lista de valores permitido do campo
                        NIL                                                         , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
                        &( ' { | oModel |  F312IniCpo(oModel,"CJQ_DESINT") } ' )    , ;      // [11]  B   Code-block de inicializacao do campo
                        NIL                                                         , ;      // [12]  L   Indica se trata-se de um campo chave
                        NIL                                                         , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.                                                         )        // [14]  L   Indica se o campo é virtual


    oStruGener:AddTrigger( ;
                        "CJQ_INTERM", ;                                                         // [01] Id do campo de origem
                        "CJQ_DESINT" , ;                                                        // [02] Id do campo de destino
                        {|| .T. }   , ;                                                         // [03] Bloco de codigo de validação da execução do gatilho
                        &( ' { | oModel |  IIF(!empty(oModel:GetValue("CJQ_INTERM")),A1U->A1U_NOME,"") } ' ) )  // [04] Bloco de codigo de execução do gatilho

else
	oStruGener:AddField( ;                    // Ord. Tipo Desc.
                        "CJQ_DESPAR"        , ; // [01] C Nome do Campo
                        "10"                , ;	// [02] C Ordem
                        STR0021             , ;	// [03] C Titulo do campo  //"Desc Part"
                        STR0022             , ;	// [04] C Descrição do campo //"Descrição Partici"
                        {}                  , ; // [05] A Array com Help
                        "C"                 , ; // [06] C Tipo do campo
                        "@!"                , ; // [07] C Picture
                        NIL 			    , ;	// [08] B Bloco de Picture Var
                        ''                  , ; // [09] C Consulta F3
                        .F.	                , ; // [10] L Indica se o campo é evitável
                        nil				    , ; // [11] C Pasta do campo
                        NIL                 , ;	// [12] C Agrupamento do campo
                        {}                  , ; // [13] A Lista de valores permitido do campo
                        NIL                 , ;	// [14] N Tamanho Maximo da maior opção do combo
                        NIL                 , ; // [15] C Inicializador de Browse
                        .T.                 , ; // [16] L Indica se o campo é virtual
                        NIL )

    oStruGener:AddField( ;                    // Ord. Tipo Desc.
                        "CJQ_DESINT"        , ; // [01] C Nome do Campo
                        "12"                , ;	// [02] C Ordem
                        STR0023             , ;	// [03] C Titulo do campo //"Desc Interm"
                        STR0024             , ;	// [04] C Descrição do campo //"Descrição Intermediário"
                        {}                  , ; // [05] A Array com Help
                        "C"                 , ; // [06] C Tipo do campo
                        "@!"                , ; // [07] C Picture
                        NIL 			    , ;	// [08] B Bloco de Picture Var
                        ''                  , ; // [09] C Consulta F3
                        .F.	                , ; // [10] L Indica se o campo é evitável
                        nil				    , ; // [11] C Pasta do campo
                        NIL                 , ;	// [12] C Agrupamento do campo
                        {}                  , ; // [13] A Lista de valores permitido do campo
                        NIL                 , ;	// [14] N Tamanho Maximo da maior opção do combo
                        NIL                 , ; // [15] C Inicializador de Browse
                        .T.                 , ; // [16] L Indica se o campo é virtual
                        NIL )
endif

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} F312USADO
Função para verifica campo usado

@author Matheus Massarotto
@since 03/05/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static function F312USADO(cCampo) 
Local cX3Usado := GetSx3Cache(cCampo,"X3_USADO")
Local lRet     := .F.
if X3Uso(cX3Usado)
    lRet:=.T.
endif
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} F312IniCpo
Função para tratamento de inicialização de campos

@author Matheus Massarotto
@since 03/05/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function F312IniCpo(oModel,cCampo)
Local cRet      := ""
Local cTipoPar  := oModel:GetValue('CJQ_TPPAR')
Local cValor    := ""
Local aArea     := GetArea()

if !Inclui    
    if cCampo == "CJQ_DESPAR"
        
        cValor    := oModel:GetValue('CJQ_CODPAR')
        Do Case
                Case cTipoPar == "1"
                    cRet:= Posicione("SA2",1,xFilial("SA2")+cValor,"A2_NOME")
                Case cTipoPar == "2"
                    cRet:= Posicione("SA1",1,xFilial("SA1")+cValor,"A1_NOME")
                Case cTipoPar == "3"
                    cRet:= Posicione("SA6",1,xFilial("SA6")+cValor,"A6_NOME")
        End Case
    elseif cCampo == "CJQ_DESINT"
        cValor    := oModel:GetValue('CJQ_INTERM')
        cRet:= Posicione("A1U",1,xFilial("A1U")+cValor,"A1U_NOME")
    endif
endif

RestArea(aArea)
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA312
Função que pergunta para usuário e processa. 

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Function PERG312()
Local oProcess

if Pergunte("FISA312", .T.) //FISA312

    oProcess := FISProgress():New({|| PrImpSPED(@oProcess)},STR0008,.T.)//'Realizando Importação'
    oProcess:Activate()
	
endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrImpSPED
Função intermediária de processamento que chama a montagem a temporária do financeiro a montagem a query, a iserção/deleção nas tabelas auxiliares

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function PrImpSPED(oProcess)
Local aBind     := {}
Local cQuery    := ""
Local oFinR190Tb
Local cAliascTMP:= ""

oProcess:Inc1Progress(STR0009)//'Processando registros do Financeiro : '

//Chama função cópia do financeiro, baseado no fonte FINR190
oFinR190Tb:=CopFINR190()

if oFinR190Tb != Nil

    oProcess:Inc1Progress(STR0010)//'Concluído'
        
        cAliascTMP := getNextAlias()
  
        cQuery := MontQry(oFinR190Tb)

        dbUseArea(.T.,"TOPCONN",TcGenQry2(,,cQuery,aBind),cAliascTMP,.T.,.F.)
        
        if !(cAliascTMP)->(Eof())
            //Deleto Registros caso ja existam.
            DelCJQ(cAliascTMP,@oProcess)

            //Processo os registros para gravação na CJQ
            ProcCJQ(cAliascTMP,@oProcess)    
        else
            Alert(STR0011) //"Não há informações com os parâmetros informados."      
        endif

        (cAliascTMP)->(DbCloseArea())
        oFinR190Tb:Delete()
        oFinR190Tb := Nil

        oProcess:Inc2Progress(STR0010)//'Concluído'

endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MontQry
Função monta a query

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function MontQry(oFinR190Tb)
Local cSelect   := ""
Local cFrom     := ""
Local cFromF1   := ""
Local cFromF2   := ""
Local cWhere    := ""
Local cQuery    := ""
Local cQryAux   := ""
Local cEstorno  := STR0012 //"Estorno de tranferencia"

       If !Empty(MV_PAR24) .And. MV_PAR24 == 2
            cQryAux += " SE5.E5_RECPAG = '" + IIf(MV_PAR11 == 1, "R", "P") + "' AND "
        Else
            If MV_PAR11 == 1
                cQryAux += " SE5.E5_RECPAG = (CASE WHEN SE5.E5_TIPODOC = 'TR' AND  SE5.E5_HISTOR LIKE '%" + cEstorno + "%' THEN 'P' Else 'R' END ) AND"
            Else
                cQryAux += " SE5.E5_RECPAG = (CASE WHEN SE5.E5_TIPODOC = 'TR' AND  SE5.E5_HISTOR LIKE '%" + cEstorno + "%' THEN 'R' Else 'P' END ) AND"
            EndIf
        EndIf

        cSelect += " SELECT   
        cSelect += " CASE WHEN ISNULL(SFTISS.FT_TIPOMOV,' ')=' ' THEN SFTICMS.FT_TIPOMOV ELSE SFTISS.FT_TIPOMOV END AS FT_TIPOMOV,
        cSelect += " CASE WHEN ISNULL(SFTISS.FT_NFISCAL,' ')=' ' THEN SFTICMS.FT_NFISCAL ELSE SFTISS.FT_NFISCAL END AS FT_NFISCAL,
        cSelect += " CASE WHEN ISNULL(SFTISS.FT_SERIE,' ')=' ' THEN SFTICMS.FT_SERIE ELSE SFTISS.FT_SERIE END AS FT_SERIE,
        cSelect += " E5_FILIAL,E5_FILORIG,E5_DATA,
        cSelect += " CONCAT(SUBSTRING(E5_DATA,5,2),SUBSTRING(E5_DATA,1,4)) AS PERIODO, 
        cSelect += " E5_CLIFOR, E5_LOJA, E5_RECPAG,E5_BANCO,E5_AGENCIA,E5_CONTA,
        cSelect += " E5_PREFIXO,E5_NUMERO,E5_TIPO,E5_PARCELA,E5_VALOR,
        cSelect += " ISNULL(CASE 
        cSelect += "	WHEN ISNULL(VALISS,0)>0 AND ISNULL(VALICMS,0)>0 THEN E5_VALOR/QTD 
        cSelect += "	ELSE 
        cSelect += "	CASE WHEN ISNULL(VALICMS,0)>0 THEN E5_VALOR ELSE 0 END
        cSelect += " END,0) AS VLRICMS,
        cSelect += " ISNULL(CASE 
        cSelect += "	WHEN ISNULL(VALISS,0)>0 AND ISNULL(VALICMS,0)>0 THEN E5_VALOR/QTD 
        cSelect += "	ELSE 
        cSelect += "	CASE WHEN ISNULL(VALISS,0)>0 THEN E5_VALOR ELSE 0 END
        cSelect += " END,0) AS VLRISS,
        cSelect += " ISNULL(CASE 
        cSelect += "	WHEN ISNULL(VALISS,0)=0 AND ISNULL(VALICMS,0)=0 THEN E5_VALOR 
        cSelect += " END,0) AS VLROUT

        cFrom	+=	" FROM "+oFinR190Tb:GetRealName() +" SE5"
        
        if MV_PAR11 == 1 .OR. MV_PAR11 == 3
            cFromF2	+=	" LEFT JOIN "+RetSqlName("SF2")+" SF2 ON SF2.F2_FILIAL='"+xFilial("SF2")+"' AND SF2.F2_DUPL=SE5.E5_NUMERO AND SF2.F2_PREFIXO=SE5.E5_PREFIXO AND SF2.F2_CLIENT=SE5.E5_CLIFOR AND SF2.F2_LOJA=SE5.E5_LOJA AND "+cQryAux+" SF2.D_E_L_E_T_ = ' '  "
            cFromF2	+=	" LEFT JOIN (SELECT FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA,SUM(FT_VALICM+FT_OUTRICM+FT_ISENICM) VALISS FROM "+RetSqlName("SFT")
            cFromF2	+=	" WHERE FT_FILIAL='"+xFilial("SFT")+"' AND FT_TIPO='S' AND D_E_L_E_T_ = ' '
            cFromF2	+=	" GROUP BY FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA) SFTISS ON SFTISS.FT_SERIE=SF2.F2_SERIE AND SFTISS.FT_NFISCAL=SF2.F2_DUPL AND SFTISS.FT_CLIEFOR=SF2.F2_CLIENT AND SFTISS.FT_LOJA=SF2.F2_LOJA AND SFTISS.FT_TIPOMOV='S'  
            cFromF2	+=	" LEFT JOIN (SELECT FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA,SUM(FT_VALICM+FT_OUTRICM+FT_ISENICM) VALICMS FROM "+RetSqlName("SFT")
            cFromF2	+=	" WHERE FT_FILIAL='"+xFilial("SFT")+"' AND FT_TIPO<>'S' AND D_E_L_E_T_ = ' '
            cFromF2	+=	" GROUP BY FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA) SFTICMS ON SFTICMS.FT_SERIE=SF2.F2_SERIE AND SFTICMS.FT_NFISCAL=SF2.F2_DUPL AND SFTICMS.FT_CLIEFOR=SF2.F2_CLIENT AND SFTICMS.FT_LOJA=SF2.F2_LOJA AND SFTICMS.FT_TIPOMOV='S'
            cFromF2	+=	" LEFT JOIN (SELECT FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA,COUNT(FT_NFISCAL) QTD FROM "+RetSqlName("SFT")
            cFromF2	+=	" WHERE FT_FILIAL='"+xFilial("SFT")+"' AND D_E_L_E_T_ = ' '
            cFromF2	+=	" GROUP BY FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA) SFTQTD ON SFTQTD.FT_SERIE=SF2.F2_SERIE AND SFTQTD.FT_NFISCAL=SF2.F2_DUPL AND SFTQTD.FT_CLIEFOR=SF2.F2_CLIENT AND SFTQTD.FT_LOJA=SF2.F2_LOJA AND SFTQTD.FT_TIPOMOV='S'
        endif

        if MV_PAR11 == 2 .OR. MV_PAR11 == 3
            cFromF1	+=	" LEFT JOIN "+RetSqlName("SF1")+" SF1 ON SF1.F1_FILIAL='"+xFilial("SF1")+"' AND SF1.F1_DUPL=SE5.E5_NUMERO AND SF1.F1_PREFIXO=SE5.E5_PREFIXO AND SF1.F1_FORNECE=SE5.E5_CLIFOR AND SF1.F1_LOJA=SE5.E5_LOJA AND "+cQryAux+" SF1.D_E_L_E_T_ = ' '  "
            cFromF1	+=	" LEFT JOIN (SELECT FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA,SUM(FT_VALICM+FT_OUTRICM+FT_ISENICM) VALISS FROM "+RetSqlName("SFT")
            cFromF1	+=	" WHERE FT_FILIAL='"+xFilial("SFT")+"' AND FT_TIPO='S' AND D_E_L_E_T_ = ' '
            cFromF1	+=	" GROUP BY FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA) SFTISS ON SFTISS.FT_SERIE=SF1.F1_SERIE AND SFTISS.FT_NFISCAL=SF1.F1_DUPL AND SFTISS.FT_CLIEFOR=SF1.F1_FORNECE AND SFTISS.FT_LOJA=SF1.F1_LOJA AND SFTISS.FT_TIPOMOV='E'  
            cFromF1	+=	" LEFT JOIN (SELECT FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA,SUM(FT_VALICM+FT_OUTRICM+FT_ISENICM) VALICMS FROM "+RetSqlName("SFT")
            cFromF1	+=	" WHERE FT_FILIAL='"+xFilial("SFT")+"' AND FT_TIPO<>'S' AND D_E_L_E_T_ = ' '
            cFromF1	+=	" GROUP BY FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA) SFTICMS ON SFTICMS.FT_SERIE=SF1.F1_SERIE AND SFTICMS.FT_NFISCAL=SF1.F1_DUPL AND SFTICMS.FT_CLIEFOR=SF1.F1_FORNECE AND SFTICMS.FT_LOJA=SF1.F1_LOJA AND SFTICMS.FT_TIPOMOV='E' 
            cFromF1	+=	" LEFT JOIN (SELECT FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA,COUNT(FT_NFISCAL) QTD FROM "+RetSqlName("SFT")
            cFromF1	+=	" WHERE FT_FILIAL='"+xFilial("SFT")+"' AND D_E_L_E_T_ = ' '
            cFromF1	+=	" GROUP BY FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA) SFTQTD ON SFTQTD.FT_SERIE=SF1.F1_SERIE AND SFTQTD.FT_NFISCAL=SF1.F1_DUPL AND SFTQTD.FT_CLIEFOR=SF1.F1_FORNECE AND SFTQTD.FT_LOJA=SF1.F1_LOJA AND SFTQTD.FT_TIPOMOV='E' 
        endif

        cWhere  +=  " WHERE SE5.D_E_L_E_T_=' '

        /*if MV_PAR11 == 3 //Esta opção para futura imprementação da opção ambos
            cQuery := cSelect +  cFrom + cFromF2+  cWhere
            cQuery += " UNION ALL "
            cQuery += cSelect +  cFrom + cFromF1+  cWhere
        else*/
        if MV_PAR11 == 2
            cQuery := cSelect +  cFrom + cFromF1+  cWhere
        else
            cQuery := cSelect +  cFrom + cFromF2+  cWhere
        endif
        
        cQuery:= ChangeQuery(cQuery)
        
Return(cQuery)

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCJQ
Função que percorre o alias montado (Financeiro + Fiscal) e chama a gravação da tabela CJQ e CJR 

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ProcCJQ(cAliascTMP,oProcess)
Local aRet          := {}
Local cItem         := STRZERO(0,TamSx3("CJR_ITEM")[1])
Local cCodMd5       := ""
Local cBkpItem      := cItem
Local cTipoPar      := ""
Local cCodPar       := ""
Local cCliefor      := "" 
Local cLoja         := ""    
Local cBanco        := ""   
Local cAgenc        := ""   
Local cNumConta     := ""
Local cIntermed     := ""
Local nTOT_VS       := 0 
Local nTOT_ISS      := 0
Local nTOT_OUT      := 0
Local oJsCJQ        := JsonObject():new() 

    (cAliascTMP)->(DbGoTop()) 

    Do While !(cAliascTMP)->(Eof()) 

        cTipoPar    := ""
        cCodPar     := ""
        cCliefor    := (cAliascTMP)->E5_CLIFOR
        cLoja       := (cAliascTMP)->E5_LOJA
        cBanco      := (cAliascTMP)->E5_BANCO
        cAgenc      := (cAliascTMP)->E5_AGENCIA
        cNumConta   := (cAliascTMP)->E5_CONTA
        cIntermed   := ""
        nTOT_VS     := (cAliascTMP)->VLRICMS
        nTOT_ISS    := (cAliascTMP)->VLRISS
        nTOT_OUT    := (cAliascTMP)->VLROUT

        aRet        := VerPart(cCliefor,cLoja,cBanco,cAgenc,cNumConta,(cAliascTMP)->E5_RECPAG)
        cTipoPar    := aRet[1]
        cCodPar     := aRet[2]
        cPeriod     := (cAliascTMP)->PERIODO
        cFil_       := xFilial("CJQ")
        cCodMd5     := MD5(cFil_+cPeriod+cTipoPar+cCodPar,2) //Hash hexadecimal
        
        if !empty(cTipoPar) .and. !empty(cCodMd5)
          
            oProcess:Inc2Progress(STR0013+cCodPar)//'Processando inclusão: '

            GrvCJQ(cFil_, cPeriod, cTipoPar, cCodPar, cCliefor, cLoja, cBanco, cAgenc, cNumConta, cIntermed, nTOT_VS, nTOT_ISS, nTOT_OUT,cCodMd5)

            cItem:=SOMAJS(@oJsCJQ,cCodMd5,cBkpItem)
            
            GrvCJR(cCodMd5,cItem,(cAliascTMP)->FT_TIPOMOV,(cAliascTMP)->FT_NFISCAL,(cAliascTMP)->FT_SERIE,(cAliascTMP)->E5_FILORIG,(cAliascTMP)->E5_PREFIXO,;
                    (cAliascTMP)->E5_NUMERO,(cAliascTMP)->E5_PARCELA,(cAliascTMP)->E5_TIPO,(cAliascTMP)->E5_RECPAG,(cAliascTMP)->E5_CLIFOR,(cAliascTMP)->E5_LOJA,;
                    (cAliascTMP)->E5_VALOR,nTOT_VS,nTOT_ISS,nTOT_OUT)
            
        endif

        (cAliascTMP)->(dbSkip())

    Enddo

aSize(aRet, 0)
FreeObj(oJsCJQ)
oJsCJQ:=Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SOMAJS
Função controla soma de itens no Json 

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function SOMAJS(oJson,cCodMd5,cItem)
Local cValor := ""

if oJson[cCodMd5]==Nil
    cValor:=SOMA1(cItem)
else
    cValor:=SOMA1(oJson[cCodMd5])
endif

oJson[cCodMd5]:=cValor

Return(cValor)

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCJQ
Função que grava a tabela CJQ

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function GrvCJQ(cFil_,cPeriod,cTipoPar,cCodPar,cCliefor,cLoja,cBanco,cAgenc,cNumConta,cIntermed,nTOT_VS,nTOT_ISS,nTOT_OUT,cCodMd5)
    //Code review, alterar para bulk na refatoração do componente do financeiro.
    //CJQ_FILIAL+CJQ_PERIOD+CJQ_TPPAR+CJQ_CODPAR
    If !CJQ->(dbSeek(cFil_+cPeriod+cTipoPar+cCodPar))
        RecLock("CJQ",.T.)
            CJQ->CJQ_FILIAL	:= cFil_
            CJQ->CJQ_PERIOD	:= cPeriod
            CJQ->CJQ_TPPAR	:= cTipoPar
            CJQ->CJQ_CODPAR	:= cCodPar
            CJQ->CJQ_CLIFOR	:= cCliefor
            CJQ->CJQ_LOJA	:= cLoja
            CJQ->CJQ_BANCO	:= cBanco
            CJQ->CJQ_AGENC	:= cAgenc
            CJQ->CJQ_NUMCON	:= cNumConta
            CJQ->CJQ_INTERM := cIntermed
            CJQ->CJQ_TOTVS	:= nTOT_VS
            CJQ->CJQ_TOTISS	:= nTOT_ISS
            CJQ->CJQ_TOTOUT	:= nTOT_OUT
            CJQ->CJQ_MANAUT := cCodMd5
        CJQ->(MsUnLock())
    Else

        if !(MV_PAR25==2 .and. empty(CJQ->CJQ_MANAUT))
            RecLock("CJQ",.F.)
                CJQ->CJQ_TOTVS	+= nTOT_VS
                CJQ->CJQ_TOTISS	+= nTOT_ISS
                CJQ->CJQ_TOTOUT	+= nTOT_OUT
            CJQ->(MsUnLock())
        endif

    Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DelCJQ
Função que deleta itens marcando com D_E_L_E_T_='*' da tabela CJQ

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function DelCJQ(cAliascTMP,oProcess)
Local aRet      := {}
Local cCliefor  := ""
Local cLoja     := ""
Local cBanco    := ""
Local cAgenc    := ""
Local cNumConta := ""
Local cTipoPar  := ""
Local cCodPar   := ""
Local cPeriod   := ""
Local cFil_     := ""
Local cCodMd5   := ""

    (cAliascTMP)->(DbGoTop()) 
    
    Do While !(cAliascTMP)->(Eof()) 

        cCliefor    := (cAliascTMP)->E5_CLIFOR
        cLoja       := (cAliascTMP)->E5_LOJA
        cBanco      := (cAliascTMP)->E5_BANCO
        cAgenc      := (cAliascTMP)->E5_AGENCIA
        cNumConta   := (cAliascTMP)->E5_CONTA

        aRet        := VerPart(cCliefor,cLoja,cBanco,cAgenc,cNumConta,(cAliascTMP)->E5_RECPAG)

        cTipoPar    := aRet[1]
        cCodPar     := aRet[2]
        cPeriod     := (cAliascTMP)->PERIODO
        cFil_       := xFilial("CJQ")
        cCodMd5     := MD5(cFil_+cPeriod+cTipoPar+cCodPar,2) //Hash hexadecimal
        
        if CJQ->(dbSeek(cFil_+cPeriod+cTipoPar+cCodPar)) .and. !(MV_PAR25==2 .and. empty(CJQ->CJQ_MANAUT))
            oProcess:Inc2Progress(STR0014+cCodPar)//Processando exclusão: 
            
            RecLock("CJQ",.F.)
                CJQ->(DbDelete())
            CJQ->(MsUnLock())
            
            DelCJR(cCodMd5)

        endif

        (cAliascTMP)->(DbSkip())
    Enddo

aSize(aRet, 0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCJR
Função que grava a tabela CJR

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function GrvCJR(cCodMd5,cItem,cTpMov,cDoc,cSerie,cFilOri,cPrefix,cNumtit,cParc,cTipo,cRecpag,cCliefor,cLoja,nValor,nTOT_VS,nTOT_ISS,nTOT_OUT)
    //Code review, alterar para bulk na refatoração do componente do financeiro.
    //CJR_FILIAL+CJR_MANAUT+CJR_ITEM
    If !CJR->(dbSeek(cFil_+cCodMd5+cItem))
        RecLock("CJR",.T.)
            CJR->CJR_FILIAL	:= xFilial("CJR")
            CJR->CJR_MANAUT := cCodMd5
            CJR->CJR_ITEM   := cItem
            CJR->CJR_TPMOV  := cTpMov
            CJR->CJR_DOC    := cDoc
            CJR->CJR_SERIE  := cSerie
            CJR->CJR_FILORI := cFilOri
            CJR->CJR_PREFIX := cPrefix
            CJR->CJR_NUMTIT := cNumtit
            CJR->CJR_PARCELA:= cParc
            CJR->CJR_TIPO   := cTipo
            CJR->CJR_RECPAG := cRecpag
            CJR->CJR_CLIFOR := cCliefor
            CJR->CJR_LOJA   := cLoja
            CJR->CJR_VALOR  := nValor
            CJR->CJR_VLRICMS:= nTOT_VS
            CJR->CJR_VLRISS := nTOT_ISS
            CJR->CJR_VLROUT := nTOT_OUT
        CJR->(MsUnLock())
    Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCJR
Função que deleta, removendo do banco itens  da tabela CJR

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function DelCJR(cCodMd5)

    TCSqlExec("DELETE FROM " + RetSqlName("CJR") + " WHERE D_E_L_E_T_ = ' ' AND CJR_MANAUT = '" + cCodMd5 + "'")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VerPart
Função que verifica o tipo do participante e devolve o tipo e o código pronto

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static function VerPart(cCliefor,cLoja,cBanco,cAgenc,cNumConta,cRegPag)

Local cTipoPar := ""
Local cCodPar  := ""

    if !empty(cCliefor) .and. !empty(cLoja)
        if cRegPag == "R"
            cTipoPar := "2"
        else
            cTipoPar := "1"
        endif
        cCodPar:= cCliefor+cLoja
    elseif !empty(cBanco) .and. !empty(cAgenc) .and. !empty(cNumConta)
        cTipoPar := "3"
        cCodPar:=cBanco+cAgenc+cNumConta
    endif

Return{cTipoPar,cCodPar}

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Validação das informações digitadas no form.

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

Local lRet		:=	.T.

Local nOp		:=	oModel:GetOperation()
Local cPeriodo  :=  oModel:GetValue('FISA312MOD','CJQ_PERIOD')
Local cTipoPar  :=  oModel:GetValue('FISA312MOD','CJQ_TPPAR')
Local cCodPArt  :=  oModel:GetValue('FISA312MOD','CJQ_CODPAR')


//CJQ_FILIAL+CJQ_PERIOD+CJQ_TPPAR+CJQ_CODPAR
If nOp == 3   //Inclusão
	DbSelectArea ("CJQ")  
	CJQ->(DbSetOrder (1))
	If CJQ->(DbSeek(xFilial("CJQ")+cPeriodo+cTipoPar+cCodPArt))
		Help(" ",1,"Help","Help",STR0015,1,0)//Registro já cadastrado
		lRet:= .F.
	EndIF
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A312ChgF3
Funcao utilizada para trocar a consulta F3 em momento de execucao dependendo
da opcao informada

@param 	cCmpF3 - Nomde do campo para fazer a validacao, o conteudo eh retornado pela classe GetValue( cModel , cCmpF3 )
		cModel - Id do modelo para passar na funcao GetValue( cModel , cCmpF3 )
		
@return cF3 - Retorna o nome da consulta F3 a ser utilizada
			
@author Matheus Massarotto
@since 17/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A312ChgF3 (cCmpF3,cModel)
Local	oModel	:= 	FWModelActive()
Local	cF3		:=	""
Local   cPart	:= ""


lPart:= TemCamp()

If lPart
	cPart:=oModel:GetValue(cModel,'CJQ_TPPAR')
EndiF 

If lPart .AND. !Empty(cPart)
	IF cPart == "2"
		cF3			:=	"SA1"	
	ElseIF cpart == "1"
		cF3			:=	"SA2A"	
	EndIF	
Else
	cF3			:=	"SA2A"
EndIF 
Limpa(oModel)

Return cF3

//-------------------------------------------------------------------
/*/{Protheus.doc} A312CanEd
Funcao determina os campos não editáveis

@param 	cCmpF3 - Nomde do campo para fazer a validacao, o conteudo eh retornado pela classe GetValue( cModel , cCmpF3, cView )
		cModel - Id do modelo para passar na funcao GetValue( cModel , cCmpF3, cView ) 
		cView  - Id do view para passar na funcao GetValue( cModel , cCmpF3, cView )

@return lRet - Retorna .T. ou .F. se pode editar
			
@author Matheus Massarotto
@since 17/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A312CanEd(cCmpF3,cModel,cView)
Local	oModel	:= 	FWModelActive()
Local	lRet	:=	.F.
Local   cPart	:= ""

lPart   := TemCamp()

if lPart
	cPart:=oModel:GetValue(cModel,'CJQ_TPPAR')
 

    if cCmpF3 $ "CJQ_CLIFOR/CJQ_LOJA" .and. cPart $ "1/2"
        lRet:=.T.
        
     elseif cCmpF3 $ "CJQ_BANCO/CJQ_AGENC/CJQ_NUMCON" .and. cPart == "3"
         lRet:=.T.

    EndIF 

endif
Limpa(oModel)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F312CODPAR
Funcao que adiciona o valor no campo CJQ_CODPAR, código do participante

@param 	cModel - Id do modelo para passar na funcao GetValue( cModel , cView ) 
		cView  - Id do view para passar na funcao GetValue( cModel , cView )

@return lRet - .T.
			
@author Matheus Massarotto
@since 17/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F312CODPAR(cModel,cView)
Local	lRet	:=	.T.

Local	oModel	:= 	FWModelActive()
Local   oView   :=  FWViewActive()
Local   cCliefor:=  oModel:GetValue(cModel,'CJQ_CLIFOR')
Local   cLoja   :=  oModel:GetValue(cModel,'CJQ_LOJA')
Local   cBanco  :=  oModel:GetValue(cModel,'CJQ_BANCO')
Local   cAgenc  :=  oModel:GetValue(cModel,'CJQ_AGENC')
Local   cConta  :=  oModel:GetValue(cModel,'CJQ_NUMCON')
Local   cPart   :=  oModel:GetValue(cModel,'CJQ_TPPAR')

if cPart $ "1/2"
    oModel:SetValue(cModel,'CJQ_CODPAR',cCliefor+cLoja)
elseif cPart == "3"
     oModel:SetValue(cModel,'CJQ_CODPAR',cBanco+cAgenc+cConta)
endif

oView:Refresh(cView)
Limpa(oModel,oView)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Limpa
Funcao limpa os objetos model e view

@param 	cModel - Id do modelo para passar na funcao GetValue( cModel , cView ) 
		cView  - Id do view para passar na funcao GetValue( cModel , cView )

@author Matheus Massarotto
@since 17/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Limpa(oModel,oView)
    oModel:=Nil
    oView:=Nil
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TemCamp
Funcao que verifica se existem os campos para a rotina

@author Matheus Massarotto
@since 17/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TemCamp()

if lPart==Nil
    lPart	:= CJQ->(FieldPos("CJQ_TPPAR")) > 0 .and. CJQ->(FieldPos("CJQ_CLIFOR")) > 0 .and. ;
               CJQ->(FieldPos("CJQ_LOJA")) > 0 .and. CJQ->(FieldPos("CJQ_BANCO")) > 0 .and.;
               CJQ->(FieldPos("CJQ_AGENC")) > 0 .and. CJQ->(FieldPos("CJQ_NUMCON")) > 0 .and.;
               CJQ->(FieldPos("CJQ_CODPAR")) > 0 .and. CJQ->(FieldPos("CJQ_MANAUT")) > 0
endif

Return(lPart)

//-------------------------------------------------------------------
/*/{Protheus.doc} F312TpPar
Funcao para limpar os campos pertinentes ao código do participante qd mudar o tipo do participante.

@author Matheus Massarotto
@since 17/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F312TpPar(cModel,cView)
Local	oModel	:= 	FWModelActive()
Local   oView   :=  FWViewActive()

lPart   :=  TemCamp()

if lPart .and. cPart <> oModel:GetValue(cModel,'CJQ_TPPAR')

    oModel:ClearField(cModel,'CJQ_CLIFOR')
    oModel:ClearField(cModel,'CJQ_LOJA')
    oModel:ClearField(cModel,'CJQ_CODPAR')
    oModel:ClearField(cModel,'CJQ_BANCO')
    oModel:ClearField(cModel,'CJQ_AGENC')
    oModel:ClearField(cModel,'CJQ_NUMCON')
    oModel:ClearField(cModel,'CJQ_DESPAR')

    oView:Refresh(cView)

endif

cPart:=oModel:GetValue(cModel,'CJQ_TPPAR')

Limpa(oModel,oView)

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidCpo
Validação de campos.

@author Matheus Massarotto
@since 19/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ValidCpo(cModel,cCampo)

	Local aArea   := GetArea()
	Local lRet    := .T.
	Local oModel  := FWModelActive()
	Local oItens  := oModel:GetModel(cModel)
	Local cPart   := oModel:GetValue(cModel,'CJQ_TPPAR')
	Local cCliFor := ""
	Local cLoja   := ""
    Local cBanco  := ""
    Local cAgenc  := ""
    Local cConta  := ""

    cCliFor := oModel:GetValue(cModel, "CJQ_CLIFOR")
	cLoja   := oModel:GetValue(cModel, "CJQ_LOJA"  )
    cBanco  := oModel:GetValue(cModel, "CJQ_BANCO" )
    cAgenc  := oModel:GetValue(cModel, "CJQ_AGENC" )
    cConta  := oModel:GetValue(cModel, "CJQ_NUMCON" )

	Do Case
	Case cCampo $ "CJQ_CLIFOR"

		If cPart $ "1/2"

			If cPart == "1" .And. !Empty(cCliFor)
				If !Empty(cLoja)
					cCliFor += cLoja
				EndIf
				SA2->(DbSetOrder(1))
				lRet := SA2->(DbSeek(xFilial("SA2") + cCliFor ))
				If lRet .And. Empty(cLoja)
					oItens:LoadValue('CJQ_LOJA', SA2->A2_LOJA )
				EndIf

                if lRet
                    oItens:LoadValue('CJQ_DESPAR', SA2->A2_NOME ) 
                endif

			ElseIf cPart == "2" .And. !Empty(cCliFor)
				If !Empty(cLoja)
					cCliFor += cLoja
				EndIf
				SA1->(DbSetOrder(1))
				lRet := SA1->(DbSeek(xFilial("SA1") + cCliFor))
				If lRet .And. Empty(cLoja)
					oItens:LoadValue('CJQ_LOJA', SA1->A1_LOJA )
				EndIf

                if lRet
                    oItens:LoadValue('CJQ_DESPAR', SA1->A1_NOME ) 
                endif
			ElseIf Empty(cCliFor)
                lRet:=.F.
            EndIf
		EndIf

	Case cCampo $ "CJQ_LOJA"

		If cPart $ "1/2"

			If cPart == "1" .And. !Empty(cLoja)
				SA2->(DbSetOrder(1))
				lRet := SA2->(DbSeek(xFilial("SA2") + cCliFor + cLoja))
                if lRet
                    oItens:LoadValue('CJQ_DESPAR', SA2->A2_NOME ) 
                endif
			ElseIf cPart == "2" .And. !Empty(cLoja)
				SA1->(DbSetOrder(1))
				lRet := SA1->(DbSeek(xFilial("SA1") + cCliFor + cLoja))
                if lRet
                    oItens:LoadValue('CJQ_DESPAR', SA1->A1_NOME ) 
                endif
            ElseIf Empty(cLoja)
                lRet:=.F.			
            EndIf
		EndIf
    
    Case cCampo $ "CJQ_BANCO/CJQ_AGENC/CJQ_NUMCON"
     
        if cPart $ "3"

            if !empty(cBanco) .and. empty(cAgenc) .and. empty(cConta) .and. !cCampo $ "CJQ_AGENC/CJQ_NUMCON"
                lRet := SA6->(DbSeek(xFilial("SA6") + cBanco))
                If lRet 
                    if empty(cAgenc)
					    oItens:LoadValue('CJQ_AGENC', SA6->A6_AGENCIA )
                    endif
                    if empty(cConta)
                        oItens:LoadValue('CJQ_NUMCON', SA6->A6_NUMCON )
                    endif
				EndIf
            elseif !empty(cBanco) .and. !empty(cAgenc) .and. empty(cConta) .and. !cCampo $ "CJQ_NUMCON"
                lRet := SA6->(DbSeek(xFilial("SA6") + cBanco + cAgenc))
            elseif !empty(cBanco) .and. !empty(cAgenc) .and. !empty(cConta)
                lRet := SA6->(DbSeek(xFilial("SA6") + cBanco + cAgenc + cConta))
            else
                lRet:=.F.
            endif

            if lRet
                oItens:LoadValue('CJQ_DESPAR', SA6->A6_NOME ) 
            endif
        endif

	EndCase

	RestArea(aArea)

    Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidRegex
Validação de campos.

@author Matheus Massarotto
@since 19/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ValidRegex(cModel,cCampo)

	Local lRet    := .T.
	Local oModel  := FWModelActive()
	Local cPeriod := ""
    Local oRegex
    
    // Inicializa objeto com Pattern de mes e ano
    oRegex := tRegex():new('^("?0[1-9]|1[012])(20)(\d{2}"?)$') //mês aceita de 1 a 12, ano aceita de 19,20 com 2 digitos finais de 0-9

    if  ValType(oRegex) == "O"   
        cPeriod := oModel:GetValue(cModel, "CJQ_PERIOD")

        // Valida o valor do campo data.
        lRet := oRegex:Search(cPeriod)
    endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CopFINR190
Funcao cópia da query do relatório FINR190 função FA190ImpR4

@author Matheus Massarotto
@since 17/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CopFINR190()
Local oFinR190Tb
Local aStru       := SE5->(DbStruct())
Local cEstorno    := STR0012 //"Estorno de tranferencia"
Local cSitCartei  := FN022LSTCB(1) + Space(TamSX3("E5_SITCOB")[1])  
Local cSGBD       := Upper(TCGetDB())
Local lOracle     := "ORACLE" $ cSGBD
Local cTable      := ""
Local cCampos     := ""
Local cValues     := ""
Local cInsert     := ""

    F190InitTb(@oFinR190Tb)
    oFinR190Tb:Create()

    DbSelectArea("SE5")

    cTable  := oFinR190Tb:GetRealName()
    cCampos := ""

    // Preenche todos os campos do arquivo temporario.
    AEval(aStru, {|Estrutura| If( Estrutura[DBS_TYPE] <> "M", cCampos += "," + AllTrim(Estrutura[DBS_NAME]), Nil)})

    cValues := SubStr(cCampos, 2)

    cInsert := " INSERT "

    If lOracle
         cInsert += " /*+ APPEND */ "
    EndIf

    cInsert += " INTO " + cTable  + " ( " + cValues  + " , SE5RECNO, SE5MAXSEQ, SE5VA, SE5MANUAL, SE5CARTEIR, SE5VERABAT) "
    cInsert += " SELECT " + cValues + " , SE5.R_E_C_N_O_ SE5RECNO, '" + Space(GetSX3Cache("E5_SEQ", "X3_TAMANHO")) + "' SE5MAXSEQ, 0 SE5VA, 0 SE5MANUAL, 'P' SE5CARTEIR, 'N' SE5VERABAT"
    cInsert += " FROM " + RetSQLName("SE5") + " SE5 "

    If !Empty(MV_PAR24) .And. MV_PAR24 == 2
        cInsert += "WHERE E5_RECPAG = '" + IIf(MV_PAR11 == 1, "R", "P") + "' AND "
    Else
        If MV_PAR11 == 1
            cInsert += "WHERE E5_RECPAG = (CASE WHEN E5_TIPODOC = 'TR' AND  E5_HISTOR LIKE '%" + cEstorno + "%' THEN 'P' Else 'R' END ) AND"
        Else
            cInsert += "WHERE E5_RECPAG = (CASE WHEN E5_TIPODOC = 'TR' AND  E5_HISTOR LIKE '%" + cEstorno + "%' THEN 'R' Else 'P' END ) AND"
        EndIf
    EndIf

    cInsert += " E5_DATA    BETWEEN '" + DToS(MV_PAR01) + "' AND '" + DToS(MV_PAR02) + "' AND "
    cInsert += " E5_DATA    <= '" + DToS(dDataBase) + "' AND "

    cInsert += " E5_MOTBX <> 'DSD' AND " //Retirado da função FR190TstCond

    cInsert += " E5_BANCO   BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND "
    
    If MV_PAR21 == 2 //Retirado da função FR190TstCond
        cInsert += "E5_TIPODOC NOT IN ('RA','PA') AND "
    EndIf
    
    // Realiza filtragem pela natureza principal
    If MV_PAR23 == 2
        cInsert +=  " E5_NATUREZ BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' AND "
    Else
        cInsert += "(E5_NATUREZ BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' OR "
        cInsert += "EXISTS (SELECT EV_FILIAL, EV_PREFIXO, EV_NUM, EV_PARCELA, EV_CLIFOR, EV_LOJA "
        cInsert += "FROM " + RetSQLName("SEV") + " SEV "
        cInsert += "WHERE E5_FILIAL  = EV_FILIAL AND "
        cInsert += "E5_PREFIXO = EV_PREFIXO AND "
        cInsert += "E5_NUMERO  = EV_NUM AND "
        cInsert += "E5_PARCELA = EV_PARCELA AND "
        cInsert += "E5_TIPO    = EV_TIPO AND "
        cInsert += "E5_CLIFOR  = EV_CLIFOR AND "
        cInsert += "E5_LOJA    = EV_LOJA AND "
        cInsert += "EV_NATUREZ BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' AND "
        cInsert += "SEV.D_E_L_E_T_ = ' ')) AND "
    EndIf
    
    cInsert += "E5_CLIFOR  BETWEEN '" + MV_PAR07       + "' AND '" + MV_PAR08       + "' AND "
    cInsert += "E5_DTDIGIT BETWEEN '" + DToS(MV_PAR09) + "' AND '" + DToS(MV_PAR10) + "' AND "
    cInsert += "E5_LOTE    BETWEEN '" + MV_PAR13       + "' AND '" + MV_PAR14       + "' AND "
    cInsert += "E5_LOJA    BETWEEN '" + MV_PAR15       + "' AND '" + MV_PAR16       + "' AND "
    cInsert += "E5_PREFIXO BETWEEN '" + MV_PAR17       + "' AND '" + MV_PAR18       + "' AND "
    cInsert += "E5_MOVCX <> 'S' AND "
    cInsert += "SE5.D_E_L_E_T_ = ' '  AND "
    cInsert += "E5_SITUACA NOT IN ('C','E','X') AND NOT EXISTS ("
    cInsert += "SELECT SE5ES.E5_NUMERO "
    cInsert += "FROM " + RetSQLName("SE5") + " SE5ES "
    cInsert += "WHERE SE5ES.E5_FILIAL  = SE5.E5_FILIAL "
    cInsert += "AND SE5ES.E5_PREFIXO = SE5.E5_PREFIXO "
    cInsert += "AND SE5ES.E5_NUMERO  = SE5.E5_NUMERO "
    cInsert += "AND SE5ES.E5_PARCELA = SE5.E5_PARCELA "
    cInsert += "AND SE5ES.E5_TIPO    = SE5.E5_TIPO "
    cInsert += "AND SE5ES.E5_CLIFOR  = SE5.E5_CLIFOR "
    cInsert += "AND SE5ES.E5_LOJA    = SE5.E5_LOJA "
    cInsert += "AND SE5ES.E5_SEQ     = SE5.E5_SEQ "
    cInsert += "AND SE5ES.E5_BANCO   = SE5.E5_BANCO "
    cInsert += "AND SE5ES.E5_AGENCIA = SE5.E5_AGENCIA "
    cInsert += "AND SE5ES.E5_CONTA   = SE5.E5_CONTA "
    cInsert += "AND SE5ES.E5_MOVCX   = SE5.E5_MOVCX "
    cInsert += "AND SE5ES.E5_NUMCHEQ = SE5.E5_NUMCHEQ "
    cInsert += "AND SE5ES.E5_ORIGEM  = SE5.E5_ORIGEM "
    cInsert += "AND SE5ES.E5_TIPODOC = 'ES' "
    cInsert += "AND SE5ES.E5_ORIGEM <> 'FINA100 ' "
    cInsert += "AND (SE5ES.E5_KEY NOT LIKE '%PA%' OR "
    cInsert += "SE5ES.E5_KEY LIKE '%PA%' AND "
    cInsert += "SE5ES.E5_NUMERO = '" + Space(Len(E5_NUMERO)) + "') "
    cInsert += "AND SE5ES.D_E_L_E_T_ = ' ') "
    cInsert += "AND ((E5_TIPODOC = 'CD' AND E5_VENCTO <= E5_DATA) OR (E5_TIPODOC <> 'CD')) "
    cInsert += "AND E5_HISTOR NOT LIKE '%" + "Baixa Automatica / Lote" + "%'"
    cInsert += "AND E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','ES'  "
    
    If !Empty(MV_PAR24) .And. MV_PAR24 == 2 // Cons. Baixa por Mov. Bancário //retira a impressão do TR e seus estornos
        cInsert += "        ,'TR'"
        If MV_PAR11 == 2
            cInsert += " , 'E2'"
        Else
            cInsert += " , 'E2', 'CB'"
        EndIf
    EndIf
    
    If MV_PAR12 == 2
        cInsert += " ,' '"
        cInsert += " ,'CH'"
        cInsert += " ,'TE'"
        cInsert += " ,'TR'"
    EndIf
    cInsert += " )"

    If !Empty(MV_PAR24) .And. MV_PAR24 == 2
        cInsert += " AND E5_ORIGEM <> 'FINA100' "
        cInsert += " AND E5_NUMERO  <> '" + Space(Len(E5_NUMERO)) + "'"
    EndIf

    If MV_PAR12 == 2
        cInsert += " AND E5_NUMERO  <> '" + Space(Len(E5_NUMERO)) + "'"
        cInsert += " AND E5_TIPO  <> '" + Space(Len(E5_TIPODOC)) + "'"
    EndIf

    If !Empty(MV_PAR19) // Deseja imprimir apenas os tipos do parametro 28
        cInsert += " AND E5_TIPO IN " + FormatIn(MV_PAR19, ";")
    ElseIf !Empty(MV_PAR20) // Deseja excluir os tipos do parametro 29
        cInsert += " AND E5_TIPO NOT IN " + FormatIn(MV_PAR20, ";")
    EndIf

    If MV_PAR11 == 1 .And. MV_PAR22 == 2 .And. !Empty(cSitCartei) // Nao imprime titulos em carteira
        cInsert += " AND E5_SITCOB NOT IN " + FormatIn(cSitCartei, "|")
    EndIf

    cInsert += " AND E5_FILIAL = '" + FwxFilial("SE5") + "'"

    If TCSQLExec(cInsert) < 0
        Help(" ",1,"Help","Help",STR0016,1,0)//Ocorreram inconsistências na utilização de comandos no banco de dados
        Return Nil
    EndIf

Return(oFinR190Tb)

//-------------------------------------------------------------------
/*/{Protheus.doc} CopFINR190
Funcao cópia da query do relatório FINR190 função F190InitTb

@author Matheus Massarotto
@since 17/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F190InitTb(oFinR190Tb)

    Local aFields   As Array

    Local cAliasTMP As Character

    aFields   := {}
    cAliasTMP := "NEWSE5"
    
    if select(cAliasTMP)>0
        (cAliasTMP)->(DbCloseArea())
    endif

    aFields := F190Fields()

    oFinR190Tb := FwTemporaryTable():New(cAliasTMP)
    oFinR190Tb:SetFields(aFields)

    FwFreeArray(aFields)

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} CopFINR190
Funcao cópia da query do relatório FINR190 função F190Fields

@author Matheus Massarotto
@since 17/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F190Fields()

    Local aFields   As Array
    Local aStruct   As Array

    aFields := {}
    aStruct := SE5->(DbStruct())
    AEval(aStruct, {|campo| campo[DBS_TYPE] <> "M", AAdd(aFields, AClone(campo)), Nil})

    AAdd(aFields, {"SE5RECNO", "N", 8, 0})
    AAdd(aFields, {"SE5MAXSEQ", GetSX3Cache("E5_SEQ", "X3_TIPO"), GetSX3Cache("E5_SEQ", "X3_TAMANHO"), GetSX3Cache("E5_SEQ", "X3_DECIMAL")})
    AAdd(aFields, {"SE5VA", GetSX3Cache("FK6_VALMOV", "X3_TIPO"), GetSX3Cache("FK6_VALMOV", "X3_TAMANHO"), GetSX3Cache("FK6_VALMOV", "X3_DECIMAL")})
    AAdd(aFields, {"SE5MANUAL", "N", 1, 0})
    AAdd(aFields, {"SE5CARTEIR", "C", 1, 0})
    AAdd(aFields, {"SE5VERABAT", "C", 1, 0})

    FwFreeArray(aStruct)

Return aFields

