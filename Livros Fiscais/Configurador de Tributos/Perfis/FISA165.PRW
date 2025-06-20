#Include "FISA165.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

Static lF23Tipo := F23->(Fieldpos("F23_TIPOPF")) > 0
Static lF26Tipo := F26->(Fieldpos("F26_TIPOPF")) > 0
Static lCIOTipo := Iif(AliasIndic("CIO"),CIO->(Fieldpos("CIO_TIPOPF")) > 0, .F.)
Static lPassou  := .F.
Static lAutomato := IsBlind()

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA165()

Cadastro do perfil tribut�rio de opera��o - Gerador de Fundos.

@author joao.pellegrini
@since 19/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA165()

Local oBrowse := Nil

If AliasIndic("F20") .And. AliasIndic("F23")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F20")
    oBrowse:SetDescription(STR0001) //'Cadastro de Perfil Tribut�rio de Opera��o'
    oBrowse:SetFilterDefault("F20_FILIAL == " + ValToSql(xFilial("F20")) + " .And. " + "F20_TIPO == '03'")
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0)  //"Dicion�rio Desatualizado. Verifique as atualiza��es do motor de tributos."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author joao.pellegrini
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.FISA165' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.FISA165' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.FISA165' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.FISA165' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.FISA165' OPERATION 9 ACCESS 0 //'Copiar'

If FindFunction("FSA171WIZ")
    ADD OPTION aRotina TITLE 'Facilitador'  ACTION 'FSA171WIZ("1","03")' OPERATION 4 ACCESS 0 //'Facilitador'
EndIF

Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef

Funcao generica MVC do model

@author joao.pellegrini
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai corresponndente a tabela de Perfil Tribut�rio - F20
Local oCabecalho := FWFormStruct(1, "F20")

//Estrutura Filho correspondente a tabela de Perfil Tribut�rio de Opera��o - F23
Local oCFOP := FWFormStruct(1, "F23")

//Estrutura Filho correspondente a tabela de Tipo de Opera��o - F26
Local oTpOper := FWFormStruct(1, "F26")

//Estrutura Filho correspondente a tabela de C�digo de Servi�os - CIO
Local oCdServ := Nil
Local lAliasCIO := AliasInDic("CIO")

//Instanciando o modelo
oModel := MPFormModel():New('FISA165',{|oModel|CargaTpOper(oModel)})

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA165",, oCabecalho)

//Adiciona o Grid ao modelo
oModel:AddGrid('FISA165CFOP', 'FISA165', oCFOP)
//oModel:GetModel('FISA165CFOP'):SetUseOldGrid()

//Adiciona o grid do tipo de opera��o
oModel:AddGrid('FISA165TPOPER', 'FISA165', oTpOper,,,,{|oTpOper| ValidDel(oTpOper,1)})

//Adiciona o grid do c�digo de servi�os
If lAliasCIO
    oCdServ := FWFormStruct(1, "CIO")

    oModel:AddGrid('FISA165CDSERV', 'FISA165', oCdServ,,,,{|oCdServ| ValidDel(oCdServ,2)})
    
    //Torna o grid do c�digo de servi�o opicional.
    oModel:GetModel( 'FISA165CDSERV' ):SetOptional( .T. )

    //Define para n�o repetir o C�digo de Servi�o
    oModel:GetModel('FISA165CDSERV'):SetUniqueLine({'CIO_CODISS'})
    oModel:GetModel('FISA165CDSERV'):SetMaxLine(9999)

    IF lCIOTipo
        oCdServ:SetProperty('CIO_TIPOPF' , MODEL_FIELD_INIT ,{||"03"} )
    Endif

    //Relacionamento entre as tabelas F20 Perfil com CIO c�digo de servi�o
    oModel:SetRelation( 'FISA165CDSERV', { { 'CIO_FILIAL', 'xFilial("CIO")' }, { 'CIO_CODIGO', 'F20_CODIGO' }, {'03','F20_TIPO'} }, CIO->( IndexKey( 1 ) ) )
EndIf

//Grid n�o pode ser vazio...
oModel:GetModel('FISA165CFOP'):SetOptional(.F.)

//Inicializa o campo F20_TIPO com conte�do "03" que significa tipo de perfil de Opera��o.
oCabecalho:SetProperty('F20_TIPO', MODEL_FIELD_INIT , {||"03"})

IF lF23Tipo
    oCFOP:SetProperty('F23_TIPOPF' , MODEL_FIELD_INIT ,{||"03"} )
Endif

IF lF26Tipo
    oTpOper:SetProperty('F26_TIPOPF' , MODEL_FIELD_INIT ,{||"03"} )
Endif

//N�o permite alterar o conte�do do campo F20_CODIGO na edi��o
oCabecalho:SetProperty('F20_CODIGO', MODEL_FIELD_WHEN, {|| (oModel:GetOperation() == MODEL_OPERATION_INSERT)})

//Valida��o para n�o permitir informar c�digo de perfil + tipo de perfil duplicado
oCabecalho:SetProperty('F20_CODIGO' , MODEL_FIELD_VALID, {||( VldPerfil(oModel, 'FISA165', '03') )})

oTpOper:SetProperty('F26_CODIGO'  , MODEL_FIELD_OBRIGAT,  .F. )

//Torna o grid do tipo de opera��o opicional.
oModel:GetModel( 'FISA165TPOPER' ):SetOptional( .T. )

//Define para n�o repetir o CFOP
oModel:GetModel('FISA165CFOP'):SetUniqueLine({'F23_CFOP'})
oModel:GetModel('FISA165CFOP'):SetMaxLine(1500)

//Define o valor maximo de linhas do grid
oModel:GetModel('FISA165CFOP'):SetMaxLine(9999999)

//N�o permite repetir o tipo de opera��o
oModel:GetModel('FISA165TPOPER'):SetUniqueLine({'F26_TPOPER'})

//Define o valor maximo de linhas do grid
oModel:GetModel('FISA165TPOPER'):SetMaxLine(9999999)

//Relacionamento entre as tabelas F20 Perfil com F23 Perfil de opera��o
oModel:SetRelation('FISA165CFOP', {{'F23_FILIAL', 'xFilial("F23")'}, {'F23_CODIGO', 'F20_CODIGO'}, {'03', 'F20_TIPO'}}, F23->(IndexKey(1)))

//Relacionamento entre as tabelas F20 Perfil com F26 Tipo de opera��o
oModel:SetRelation( 'FISA165TPOPER', { { 'F26_FILIAL', 'xFilial("F26")' }, { 'F26_CODIGO', 'F20_CODIGO' }, {'03','F20_TIPO'} }, F26->( IndexKey( 1 ) ) )

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0001) //'Cadastro de Perfil Tribut�rio de Opera��o'

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@author joao.pellegrini
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel := FWLoadModel("FISA165")

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F20")
Local oCFOP      := FWFormStruct(2, "F23")
Local oTpOper    := FWFormStruct(2, "F26")
Local oCdServ    := Nil
Local oView      := Nil
Local lAliasCIO  := AliasInDic("CIO")

oView := FWFormView():New()
oView:SetModel(oModel)

//Atribuindo formul�rios para interface
oView:AddField('VIEW_PERFIL', oCabecalho, 'FISA165')
oView:AddGrid('VIEW_CFOP'   , oCFOP     , 'FISA165CFOP')
oView:AddGrid('VIEW_TPOPER' , oTpOper   , 'FISA165TPOPER')

//Habilitando op��es de filtros 
oView:SetViewProperty('VIEW_CFOP', "GRIDFILTER", {.T.})
oView:SetViewProperty('VIEW_CFOP', "GRIDSEEK", {.T.})
oView:SetViewProperty('VIEW_TPOPER', "GRIDFILTER", {.T.})
oView:SetViewProperty('VIEW_TPOPER', "GRIDSEEK", {.T.})

//Retira da view os campos de ID
oCabecalho:RemoveField('F20_TIPO')
oCFOP:RemoveField('F23_CODIGO')
oTpOper:RemoveField( 'F26_CODIGO')

IF lF23Tipo
    oCFOP:RemoveField('F23_TIPOPF')
Endif

IF lF26Tipo
    oTpOper:RemoveField('F26_TIPOPF')
Endif

If !lAliasCIO
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox('SUPERIOR', 20)
    oView:CreateHorizontalBox('MEDIO',    40)
    oView:CreateHorizontalBox('INFERIOR', 40)

    //O formul�rio da interface ser� colocado dentro do container
    oView:SetOwnerView('VIEW_PERFIL', 'SUPERIOR')
    oView:SetOwnerView('VIEW_CFOP', 'MEDIO')
    oView:SetOwnerView('VIEW_TPOPER', 'INFERIOR')

Else
    //Estrutura em Folder
    //Cria��o da estrutura de dados utilizada na interface do cadastro
    oCdServ    := FWFormStruct(2, "CIO")
    
    //Atribuindo formul�rios para interface
    oView:AddGrid('VIEW_CDSERV' , oCdServ   , 'FISA165CDSERV')
    
    //Habilitando op��es de filtros 
    oView:SetViewProperty('VIEW_CDSERV', "GRIDFILTER", {.T.})
    oView:SetViewProperty('VIEW_CDSERV', "GRIDSEEK", {.T.})
    
    //Retira da view os campos
    oCdServ:RemoveField( 'CIO_CODIGO')

    IF lCIOTipo
        oCdServ:RemoveField('CIO_TIPOPF')
    Endif

    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox('SUPERIOR', 20)
    oView:CreateHorizontalBox('MEDIO',    80)

    //Cria um folder
    oView:CreateFolder( 'FOLDER_GERAL', 'MEDIO' )

    //Cria dois Sheets no folder inferior
    oView:AddSheet( 'FOLDER_GERAL', 'ABA_CFOP'      , STR0004 ) //"CFOP'S"
    oView:AddSheet( 'FOLDER_GERAL', 'ABA_TPOPER'    , STR0056 ) //"Tipo de opera��o"
    oView:AddSheet( 'FOLDER_GERAL', 'ABA_CODSERV'   , STR0057 ) //"C�digo de Servi�o"

    //Cria box da aba de Principais
    oView:CreateHorizontalBox( 'PAINEL_CFOP'    , 100,,, 'FOLDER_GERAL', 'ABA_CFOP'     )
    oView:CreateHorizontalBox( 'PAINEL_TPOPER'  , 100,,, 'FOLDER_GERAL', 'ABA_TPOPER'   )
    oView:CreateHorizontalBox( 'PAINEL_CODSERV' , 100,,, 'FOLDER_GERAL', 'ABA_CODSERV'  )

    //Faz v�nculo do box com a view
    oView:SetOwnerView( 'VIEW_PERFIL'      , 'SUPERIOR'    )

    //Seta a View com seu respectivo Owner
    oView:SetOwnerView( 'VIEW_CFOP'      , 'PAINEL_CFOP'    )
    oView:SetOwnerView( 'VIEW_TPOPER'    , 'PAINEL_TPOPER'  )
    oView:SetOwnerView( 'VIEW_CDSERV'    , 'PAINEL_CODSERV' )

    oView:EnableTitleView('VIEW_CDSERV', STR0057) //"C�digo de Servi�o"
EndIf

//Colocando t�tulo do formul�rio
oView:EnableTitleView('VIEW_PERFIL', STR0003) //"Informa�oes das Faixas do Anexo"
oView:EnableTitleView('VIEW_CFOP'  , STR0004) //"Informa�oes das Faixas do Anexo"
oView:EnableTitleView('VIEW_TPOPER', STR0056) //"Tipo de opera��o"

//Picture do campo c�digo
oCabecalho:SetProperty('F20_CODIGO' , MVC_VIEW_PICT, "@!")

//Adiciona bot�o do Facilitador
If FindFunction("FSA171WIZ")
    oView:AddUserButton( 'Facilitador','', {|oView| FSA171WIZ("2","03")} )
EndIF

//Desabilitando op��o de ordena��o
oView:SetViewProperty("*", "ENABLENEWGRID")
oView:SetViewProperty( "*", "GRIDNOORDER" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCfop

Fun��o respons�vel por gravar o CFOP da carga inicial
@param cPerfil   - C�digo do perfil
@param cDescPerf - Descri��o do perfil
@param aCfop     - Lista de CFOP a ser inserido
@param lAddF20   - Indica se deve adicionar o cabe�alho do perfil na tabela F20

@author Erick.Dias
@since 24/07/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function GrvCfop(cPerfil, cDescPerf, aCfop)

Local nCont := 0
Local nX    := 0

//Cria o perfil
RecLock("F20",.T.)
F20->F20_FILIAL	    := xFilial("F20")
F20->F20_CODIGO		:= cPerfil
F20->F20_DESC  		:= cDescPerf
F20->F20_TIPO  		:= '03' //03 indica que � perfil de opera��o
MsUnLock()

//La�o criando os CFOPs para o perfil
For nX := 1 to Len(aCfop)

    For nCont:=1 to Len(aCfop[nX])

        RecLock("F23",.T.)
        F23->F23_FILIAL	    := xFilial("F23")
        F23->F23_CODIGO		:= cPerfil
        F23->F23_CFOP  		:= aCfop[nX, nCont]
        IF lF23Tipo
            F23->F23_TIPOPF	:= "03"
        Endif
        MsUnLock()

    Next nCont

Next nX

//Para todos os perfis de carga inicial autom�tica, ser� preenchido no tipo de opera��o a op��o todos
RecLock("F26",.T.)
F26->F26_FILIAL	    := xFilial("F26")
F26->F26_CODIGO		:= cPerfil
F26->F26_TPOPER		:= "TODOS"
IF lF26Tipo
    F26->F26_TIPOPF	:= "03"
Endif
MsUnLock()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA165CARG

Fun��o respons�vel por efetuar a carga dos perfis de opera��o

@author joao.pellegrini
@since 24/07/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA165CARG()

Local aEComuInt    := {"1301","1302","1303","1304","1305","1306"}
Local aEComuInter  := {"2301","2302","2303","2304","2305","2306"}
Local aEComuImp    := {"7301"}
Local aEEneInt     := {"1251","1252","1253","1254","1255","1256","1257"}
Local aEEneInter   := {"2251","2252","2253","2254","2255","2256","2257"}
Local aEEneImp     := {"3251"}
Local aETraInt     := {"1351","1352","1353","1354","1355","1356"}
Local aETraInter   := {"2351","2352","2353","2354","2355","2356"}
Local aETraImp     := {"3351","3352","3353","3354","3355","3356"}
Local aECombInt    := {"1651","1652","1653"}
Local aECombInter  := {"2651","2652","2653"}
Local aECombImp    := {"3651","3652","3653"}
Local aEComInt     := {"1102","1113","1117","1118","1121","1403"}
Local aEComInter   := {"2102","2113","2117","2118","2121","2403"}
Local aEComImp     := {"3102"}
Local aEIndInt     := {"1101","1111","1116","1120","1122","1401"}
Local aEIndInter   := {"2101","2111","2116","2120","2122","2401"}
Local aEIndImp     := {"3101","3127"}

Local aVenInt      := {"5101","5103","5105","5109","5111","5113","5118","5122","5124","5125","5401","5402","5922"}
Local aVenInter    := {"6101","6103","6105","6107","6109","6111","6113","6118","6122","6124","6125","6401","6402","6922"}
Local aVenExt      := {"7101","7105","7127"}
Local aRevInt     := {"5102","5104","5106","5110","5112","5114","5115","5119","5120","5123","5403","5405","5922"}
Local aRevInter   := {"6102","6104","6106","6108","6110","6112","6114","6115","6119","6120","6123","6403","6404","6405","6922"}
Local aRevExt     := {"7102","7501","7106"}
Local aCombInt    := {"5651","5652","5653","5654","5655","5656"}
Local aCombInter  := {"6651","6652","6653","6654","6655","6656"}
Local aCombExt    := {"7651","7654"}
Local aTranInt    := {"5351","5352","5353","5354","5355","5356","5357","5359","5360"}
Local aTranInter  := {"6351","6352","6353","6354","6355","6356","6357","6359","6360"}
Local aTranExt    := {"7358"}
Local aEnergInt   := {"5251","5252","5253","5254","5255","5256","5257","5258"}
Local aEnergInter := {"6251","6252","6253","6254","6255","6256","6257","6258"}
Local aEnergExt   := {"7250"}
Local aComInt     := {"5301","5302","5303","5304","5305","5306","5307"}
Local aComInter   := {"6301","6302","6303","6304","6305","6306","6307"}
Local aComExt     := {"7301"}
Local aCfopEnt    := {}
Local aCfopSai    := {}
Local aCfopAll    := {}

Local cCodPerf     := "000000"

dbSelectArea("F23")
F23->(dbSetOrder(1))
F23->(dbGoTop())

// S� faz a carga se n�o houver nenhum perfil na filial...
If !F23->(dbSeek(xFilial("F23")))
    
    //---------------------------------------------------
    //Carga de todos os CFOPs de entrada, sa�da, e todos 
    //---------------------------------------------------
    AllCfops(@aCfopEnt, @aCfopSai, @aCfopAll)

    //------------------------------------------
    //Carga dos CFOps de entradas de Comunica��o
    //------------------------------------------
    GrvCfop(IncCod(@cCodPerf), STR0005, {aEComuInt}) //"AQUISI��O DE SERVI�O DE COMUNICA��O - INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0006, {aEComuInter})//"AQUISI��O DE SERVI�O DE COMUNICA��O - INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0007, {aEComuImp})//"AQUISI��O DE SERVI�O DE COMUNICA��O - IMPORTA��O"
    GrvCfop(IncCod(@cCodPerf), STR0008, {aEComuInt, aEComuInter, aEComuImp})//"TODAS AS AQUISI��ES DE COMUNICA��O"
    
    //------------------------------------------------
    //Carga dos CFOps de entradas de Energia El�trica
    //------------------------------------------------
    GrvCfop(IncCod(@cCodPerf), STR0009, {aEEneInt})//"AQUISI��O DE SERVI�O DE ENERGIA EL�TRICA - INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0010, {aEEneInter})//"AQUISI��O DE SERVI�O DE ENERGIA EL�TRICA - INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0011, {aEEneImp})//"AQUISI��O DE SERVI�O DE ENERGIA EL�TRICA - IMPORTA��O"
    GrvCfop(IncCod(@cCodPerf), STR0012, {aEEneInt, aEEneInter, aEEneImp})//"TODAS AS AQUISI��ES DE ENERGIA EL�TRICA"

    //------------------------------------------
    //Carga dos CFOps de entradas de Transportes
    //------------------------------------------
    GrvCfop(IncCod(@cCodPerf), STR0013, {aETraInt})//"AQUISI��O DE SERVI�O DE TRANSPORTE - INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0014, {aETraInter})//"AQUISI��O DE SERVI�O DE TRANSPORTE - INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0015, {aETraImp})//"AQUISI��O DE SERVI�O DE TRANSPORTE - IMPORTA��O"
    GrvCfop(IncCod(@cCodPerf), STR0016, {aETraInt, aETraInter, aETraImp})//"TODAS AS AQUISI��ES DE TRANSPORTE"

    //------------------------------------------
    //Carga dos CFOps de entradas de Combust�vel
    //------------------------------------------
    GrvCfop(IncCod(@cCodPerf), STR0017, {aECombInt})//"AQUISI��O DE COMBUST�VEL - INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0018, {aECombInter})//"AQUISI��O DE COMBUST�VEL - INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0019, {aECombImp})//"AQUISI��O DE COMBUST�VEL - IMPORTA��O"
    GrvCfop(IncCod(@cCodPerf), STR0020, {aECombInt, aECombInter, aECombImp})    //"TODAS AS AQUISI��ES DE COMBUST�VEL"
    
    //-------------------------------------------------------------
    //Carga dos CFOps de entradas de Compras para Comercializa��o
    //-------------------------------------------------------------
    GrvCfop(IncCod(@cCodPerf), STR0021, {aEComInt})//"AQUISI��O PARA COMERCIALIZA��O - INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0022, {aEComInter})//"AQUISI��O PARA COMERCIALIZA��O - INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0023, {aEComImp})//"AQUISI��O PARA COMERCIALIZA��O - IMPORTA��O"
    GrvCfop(IncCod(@cCodPerf), STR0024, {aEComInt, aEComInter, aEComImp})    //"TODAS AS AQUISI��ES PARA COMERCIALIZA��O"

    //-------------------------------------------------------------
    //Carga dos CFOps de entradas de Compras para Industrializa��o
    //-------------------------------------------------------------
    GrvCfop(IncCod(@cCodPerf), STR0025, {aEIndInt})//"AQUISI��O PARA INDUSTRIALIZA��O - INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0026, {aEIndInter})//"AQUISI��O PARA INDUSTRIALIZA��O - INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0027, {aEIndImp})//"AQUISI��O PARA INDUSTRIALIZA��O - IMPORTA��O"
    GrvCfop(IncCod(@cCodPerf), STR0028, {aEIndInt, aEIndInter, aEIndImp})//"TODAS AS AQUISI��ES PARA INDUSTRIALIZA��O"

    //---------------------------------------------------------------
    // Adiciona as aquisi��es no perfil de geral de todas aquisi��es
    //---------------------------------------------------------------
    GrvCfop(IncCod(@cCodPerf), STR0029, {aCfopEnt})//"TODAS AS ENTRADAS"

    // VENDAS

    GrvCfop(IncCod(@cCodPerf), STR0030, {aVenInt})//"VENDA INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0031, {aVenInter})//"VENDA INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0032, {aVenExt})//"VENDA PARA O MERCADO EXTERNO"
    GrvCfop(IncCod(@cCodPerf), STR0033, {aVenInt,aVenInter,aVenExt})//"TODAS AS VENDAS"

    // REVENDAS    

    GrvCfop(IncCod(@cCodPerf), STR0034, {aRevInt})//"REVENDA INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0035, {aRevInter})//"REVENDA INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0036, {aRevExt})//"REVENDA PARA O MERCADO EXTERNO"
    GrvCfop(IncCod(@cCodPerf), STR0037, {aRevInt, aRevInter, aRevExt})//"TODAS AS REVENDAS"

    // VENDA DE COMBUSTIVEL

    GrvCfop(IncCod(@cCodPerf), STR0038, {aCombInt})//"VENDA DE COMBUST�VEL EM OPERA��O INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0039, {aCombInter})//"VENDA DE COMBUST�VEL EM OPERA��O INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0040, {aCombExt})//"VENDA DE COMBUST�VEL EM OPERA��O DE EXPORTA��O"
    GrvCfop(IncCod(@cCodPerf), STR0041, {aCombInt,aCombInter,aCombExt})//"TODAS AS VENDAS DE COMBUST�VEL"

    // TRANSPORTE

    GrvCfop(IncCod(@cCodPerf), STR0042, {aTranInt})//"PRESTA��O INTERNA DE SERVI�O DE TRANSPORTE"
    GrvCfop(IncCod(@cCodPerf), STR0043, {aTranInter})//"PRESTA��O INTERESTADUAL DE SERVI�O DE TRANSPORTE"
    GrvCfop(IncCod(@cCodPerf), STR0044, {aTranExt})//"PRESTA��O DE SERVI�O DE TRANSPORTE PARA O EXTERIOR"
    GrvCfop(IncCod(@cCodPerf), STR0045, {aTranInt,aTranInter,aTranExt})//"TODAS AS PRESTA��ES DE SERVI�O DE TRANSPORTE"

    // VENDA DE ENERGIA EL�TRICA

    GrvCfop(IncCod(@cCodPerf), STR0046, {aEnergInt})//"VENDA DE ENERGIA EL�TRICA EM OPERA��O INTERNA"
    GrvCfop(IncCod(@cCodPerf), STR0047, {aEnergInter})//"VENDA DE ENERGIA EL�TRICA EM OPERA��O INTERESTADUAL"
    GrvCfop(IncCod(@cCodPerf), STR0048, {aEnergExt})//"VENDA DE ENERGIA EL�TRICA EM OPERA��O DE EXPORTA��O"
    GrvCfop(IncCod(@cCodPerf), STR0049, {aEnergInt,aEnergInter,aEnergExt})//"TODAS AS VENDAS DE ENERGIA EL�TRICA"

    // COMUNICA��O

    GrvCfop(IncCod(@cCodPerf), STR0050, {aComInt})//"PRESTA��O INTERNA DE SERVI�O DE COMUNICA��O"
    GrvCfop(IncCod(@cCodPerf), STR0051, {aComInter})//"PRESTA��O INTERESTADUAL DE SERVI�O DE COMUNICA��O"
    GrvCfop(IncCod(@cCodPerf), STR0052, {aComExt})//"PRESTA��O DE SERVI�O DE COMUNICA��O PARA O EXTERIOR"
    GrvCfop(IncCod(@cCodPerf), STR0053, {aComInt,aComInter,aComExt})//"TODAS AS PRESTA��ES DE SERVI�O DE COMUNICA��O"

    // Adiciona as vendas no perfil geral de sa�das
    GrvCfop(IncCod(@cCodPerf), STR0054, {aCfopSai})//"TODAS AS SA�DAS"

    // Perfil de TODOS os CFOPS
    GrvCfop(IncCod(@cCodPerf), STR0055, {aCfopAll})//"TODOS OS CFOPs"

EndIf

//Limpo todos os arrays
aEComuInt    := Nil
aEComuInter  := Nil
aEComuImp    := Nil
aEEneInt     := Nil
aEEneInter   := Nil
aEEneImp     := Nil
aETraInt     := Nil
aETraInter   := Nil
aETraImp     := Nil
aECombInt    := Nil
aECombInter  := Nil
aECombImp    := Nil
aEComInt     := Nil
aEComInter   := Nil
aEComImp     := Nil
aEIndInt     := Nil
aEIndInter   := Nil
aEIndImp     := Nil
aVenInt      := Nil
aVenInter    := Nil
aVenExt      := Nil
aRevInt      := Nil
aRevInter    := Nil
aRevExt      := Nil
aCombInt     := Nil
aCombInter   := Nil
aCombExt     := Nil
aTranInt     := Nil
aTranInter   := Nil
aTranExt     := Nil
aEnergInt    := Nil
aEnergInter  := Nil
aEnergExt    := Nil
aComInt      := Nil
aComInter    := Nil
aComExt      := Nil
aCfopEnt     := Nil
aCfopSai     := Nil
aCfopAll     := Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IncCod

Fun��o que retornar� o c�digo do pr�ximo perfil de CFOP da caraga autom�tica

@author joao.pellegrini
@since 24/07/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function IncCod(cCodigo)
cCodigo := Soma1(cCodigo)
Return cCodigo

//-------------------------------------------------------------------
/*/{Protheus.doc} AllCfops
Fun��o que percorrer� todos os CFOPs da SX5 para realizar a carga autom�tica
@author Erick.Dias
@since 24/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function AllCfops(aCfopEnt, aCfopSai, aCfopAll)

Local cCfop     := ""
Local nX        := 0
Local aDadosSX5 := FWGetSX5( "13" )

//Posiciono na SX5 a tabela 13 de CFOPs
For nX := 1 to Len(aDadosSX5)
    cCfop   := Alltrim(aDadosSX5[nX][3])
    
    //Somente considera CFOPs com 4 d�gitos
    If Len(cCfop) == 4

        If left(cCfop,1) $ "1/2/3"
            //CFOP de entrada
            aAdd(aCfopEnt,cCfop)

        ElseIf left(cCfop,1) $ "5/6/7"
            //CFOP de sa�da
            aAdd(aCfopSai,cCfop)
        EndIF

        //Adiciona o CFOP no array que cont�m todos os CFOPs
        aAdd(aCfopAll,cCfop)

    EndIF        
Next


Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA165GF23
Fun��o para grava��o em lote da F23 CFOPs

@author Erick Dias
@since 26/09/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA165GF23(cCodPerfil, aCfop, cAcao, nQtdTot, nQtdProc, oSay)

Local cCfop         := ''
Local oModel        := NIL
Local oModelCfop    := NIL
Local lAchouF23     := .F.
Local lRet          := .F.
Local nCont         := 0

oModel := FWLoadModel("FISA165")
oModel:SetOperation(MODEL_OPERATION_UPDATE)

DbSelectArea("F20")
F20->(DbSetOrder(1))

If F20->(DbSeek(xFilial("F20") + cCodPerfil + "03"))

    oModel:Activate()

    oModelCfop := oModel:GetModel("FISA165CFOP")

    For nCont := 1 to Len(aCfop)
        
        nQtdTot     += 1
        cCfop       := padr(aCfop[nCont][1] ,4) 
        lAchouF23   := F23->( MsSeek ( xFilial('F23') + cCodPerfil + cCfop ) )
        
        oSay:cCaption := ("Processando perfil: " + cCodPerfil + " , CFOP: " + cCfop)
        ProcessMessages()        

        If cAcao == '1' .AND. !lAchouF23
            //A informa��o ainda n�o existe na tabela
            oModelCfop:AddLine()
            oModelCfop:SetValue("F23_CFOP" , cCfop)            
            IF lF22Tipo
                oModelCfop:SetValue("F23_TIPOPF"   , '03')
            Endif
            nQtdProc += 1
        
        ElseIF cAcao == '2' .AND. lAchouF23
            //Opera��o de exclus�o e a informa��o j� existe na tabela, ent�o ser� deletada
            RecLock("F23",.F.)
            F23->(dbDelete())
            MsUnLock()
            F23->(FkCommit())
            nQtdProc += 1

        EndIF

    Next nCont    

    If oModel:VldData()
        lRet := oModel:CommitData()
    Else
        aErros := oModel:GetErrorMessage()
    EndIf

EndIf

oModel:Deactivate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA165GF26
Fun��o para grava��o em lote da F26 Tipo de Opera��o

@author Erick Dias
@since 26/09/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA165GF26(cCodPerfil, aTpOper, cAcao, nQtdTot, nQtdProc, oSay)

Local oModel        := NIL
Local oModelOper    := NIL
Local lAchouF26     := .F.
Local lRet          := .F.
Local nCont         := 0

oModel := FWLoadModel("FISA165")
oModel:SetOperation(MODEL_OPERATION_UPDATE)

DbSelectArea("F20")
F20->(DbSetOrder(1))

If F20->(DbSeek(xFilial("F20") + cCodPerfil + "03"))

    oModel:Activate()

    oModelOper := oModel:GetModel("FISA165TPOPER")

    For nCont := 1 to Len(aTpOper)
        
        nQtdTot     += 1        
        lAchouF26   := F26->( MsSeek ( xFilial('F26') + cCodPerfil + aTpOper[nCont][1] ) )
        
        oSay:cCaption := ("Processando perfil: " + cCodPerfil + " , Tipo de Opera��o: " + aTpOper[nCont][1])
        ProcessMessages()        

        If cAcao == '1' .AND. !lAchouF26
            //A informa��o ainda n�o existe na tabela
            oModelOper:AddLine()
            oModelOper:SetValue("F26_TPOPER" , aTpOper[nCont][1])
            IF lF26Tipo
                oModelOper:SetValue("F26_TIPOPF"   , '03')
            Endif
            nQtdProc += 1
        
        ElseIF cAcao == '2' .AND. lAchouF26
            //Opera��o de exclus�o e a informa��o j� existe na tabela, ent�o ser� deletada
            RecLock("F26",.F.)
            F26->(dbDelete())
            MsUnLock()
            F26->(FkCommit())
            nQtdProc += 1

        EndIF

    Next nCont    

    If oModel:VldData()
        lRet := oModel:CommitData()
    Else
        aErros := oModel:GetErrorMessage()
    EndIf

EndIf

oModel:Deactivate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA165DOPE
Fun��o auxiliar para tratar o inicializador padr�o da descri��o do 
tipo de opera��o, pois o campo X3_RELACAO � limitado e n�o cabia 
toda a instru��o necess�ria.

@author Erick Dias
@since 11/10/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA165DOPE()

Local cDescr    := ""

If !INCLUI
    If Upper(Alltrim(F26->F26_TPOPER))=="TODOS"
        cDescr  := "TODOS OS TIPOS DE OPERACAO"
    Else
        cDescr  := POSICIONE("SX5",1,xFilial("SX5")+"DJ"+F26->F26_TPOPER,"X5DESCRI()")
    EndIF
EndIF

Return cDescr

//-------------------------------------------------------------------
/*/{Protheus.doc} CargaTpOper
Fun��o que faz a carga autom�tica do tipo de opera��o no Grid.
O objetivo � facilitar o cadastro do usu�rio.

@author Erick G Dias
@since 21/11/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function CargaTpOper(oModel)

Local oTipoOper		:= oModel:GetModel("FISA165TPOPER")

//A carga ser� realizada somente no momento da inclus�o do perfil
If oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. oTipoOper:Length() == 1        
    oTipoOper:LoadValue("F26_TPOPER" , "TODOS")
    oTipoOper:LoadValue("F26_DESCRI" , "TODOS OS TIPOS DE OPERACAO")
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA165GCIO
Fun��o para grava��o em lote da CIO C�digo de ISS.
Utilizado no fonte FISA171

@author Renato Rezende
@since 23/07/2020
@version 12.1.30

/*/
//-------------------------------------------------------------------
Function FSA165GCIO(cCodPerfil, aCodISS, cAcao, nQtdTot, nQtdProc, oSay)

Local oModel        := NIL
Local oModelOper    := NIL
Local lAchouCIO     := .F.
Local lRet          := .F.
Local nCont         := 0

oModel := FWLoadModel("FISA165")
oModel:SetOperation(MODEL_OPERATION_UPDATE)

DbSelectArea("F20")
F20->(DbSetOrder(1))

If F20->(DbSeek(xFilial("F20") + cCodPerfil + "03"))

    oModel:Activate()

    oModelOper := oModel:GetModel("FISA165CDSERV")

    For nCont := 1 to Len(aCodISS)
        
        nQtdTot     += 1        
        lAchouCIO   := CIO->( MsSeek ( xFilial('CIO') + cCodPerfil + aCodISS[nCont][1] ) )
        
        oSay:cCaption := ("Processando perfil: " + cCodPerfil + " , C�digo ISS: " + aCodISS[nCont][1])
        ProcessMessages()        

        If cAcao == '1' .AND. !lAchouCIO
            //A informa��o ainda n�o existe na tabela
            oModelOper:AddLine()
            oModelOper:SetValue("CIO_CODISS" , aCodISS[nCont][1])            
            IF lCIOTipo
                oModelOper:SetValue("CIO_TIPOPF" , '03')            
            Endif
            nQtdProc += 1
        
        ElseIF cAcao == '2' .AND. lAchouCIO
            //Opera��o de exclus�o e a informa��o j� existe na tabela, ent�o ser� deletada
            RecLock("CIO",.F.)
                CIO->(dbDelete())
            CIO->(MsUnLock())
            CIO->(FkCommit())
            nQtdProc += 1

        EndIF

    Next nCont    

    If oModel:VldData()
        lRet := oModel:CommitData()
    Else
        aErros := oModel:GetErrorMessage()
    EndIf

EndIf

oModel:Deactivate()

Return lRet

/*/{Protheus.doc} AtuTpPF03
    (Atualiza novos campos F25_TIPOPF e F24_TIPOPF)

@author Rafael S Oliveira
@since 01/03/2021
@version P12.1.30

    /*/
Function AtuTpPF03()

IF lF23Tipo
    cQuery := "UPDATE " +  RetSqlName('F23') + " SET F23_TIPOPF = '03' WHERE F23_FILIAL = " + ValToSql(xFilial('F23')) + " AND F23_TIPOPF = ' '
    TcSqlExec(cQuery)
Endif
IF lF26Tipo
    cQuery := "UPDATE " +  RetSqlName('F26') + " SET F26_TIPOPF = '03' WHERE F26_FILIAL = " + ValToSql(xFilial('F26')) + " AND F26_TIPOPF = ' '
    TcSqlExec(cQuery)
Endif
IF lCIOTipo
    cQuery := "UPDATE " +  RetSqlName('CIO') + " SET CIO_TIPOPF = '03' WHERE CIO_FILIAL = " + ValToSql(xFilial('CIO')) + " AND CIO_TIPOPF = ' '
    TcSqlExec(cQuery)
Endif

Return

/*/{Protheus.doc} VldTodos
    Valida a inclus�o do tipo TODOS

@author Yuri Gimenes
@since 08/04/2022
@version P12.1.33

    /*/
static Function ValidDel(oObjeto,nOpcao)

Local lRet      := .T.
Local lOperTd    := .F.
Local lOperAv    := .F.
Local lISSTd    := .F.
Local lISSAv    := .F.
Local nY
Local oModelGrid := oObjeto

/*
nOpcao == 1 -> Tipo de Opera��o
nOpcao == 2 -> C�digo de Servi�o
*/
oModelPad   := FwModelActive()

If nOpcao == 1

    For nY := 1 to oModelGrid:Length()

        oModelGrid:GoLine(nY)

        iF !oModelGrid:IsDeleted()

            cTpOper := AllTrim(oModelGrid:GetValue ("F26_TPOPER"))

            lOperTd := iif(lOperTd==.F.,iif(AllTrim(cTpOper)=="TODOS",.t.,.f.),.T.)
            lOperAv := iif(lOperAv==.F.,iif(AllTrim(cTpOper)<>"TODOS",.t.,.f.),.T.)

            If lOperTd .and. lOperAv
                exit
            ENDIF

        EndIf

    Next nY

    nY := 0

    If lOperTd .and. lOperAv

        If lAutomato .or. MsgYesNo(STR0058 + chr(13)+chr(10) +;    //"Existem tipos de opera��o e/ou c�digo de servi�o configurados como'TODOS' no Grid."
                    STR0059 + chr(13)+chr(10) +;    //"Os tipos de opera��o e/ou c�digo de servi�o diferente de TODOS ser�o exclu�dos"
                    STR0060, STR0003)            //"Deseja continuar?"

            For nY := 1 to oModelGrid:Length()

            oModelGrid:GoLine(nY)

                cTpOper := AllTrim(oModelGrid:GetValue ("F26_TPOPER"))

                if(!("TODOS" $ cTpOper) .and. lOperTd)
                    oModelGrid:DeleteLine()
                EndIf
            Next nY
            lPassou := .T.
        else
            lRet := .F.
            oModelPad:SetErrorMessage(,,,,,STR0063,STR0064)
        EndIf
    EndIF

Elseif nOpcao == 2

    For nY := 1 to oModelGrid:Length()

        oModelGrid:GoLine(nY)

        iF !oModelGrid:IsDeleted()

            cCodServ := AllTrim(oModelGrid:GetValue ("CIO_CODISS"))

            lISSTd := iif(lISSTd==.F.,iif(AllTrim(cCodServ)=="TODOS",.t.,.f.),.T.)
            lISSAv := iif(lISSAv==.F.,iif(AllTrim(cCodServ)<>"TODOS",.t.,.f.),.T.)

            If lISSTd .and. lISSAv
                exit
            ENDIF

        EndIf
    Next nY

    nY := 0

    If lISSTd .and. lISSAv

        If !lpassou

            lPassou :=  lAutomato .or. MsgYesNo(STR0061 + chr(13)+chr(10) +;   //"Existem c�digos de servi�o configurados como 'TODOS' no Grid."
                                 STR0062 + chr(13)+chr(10) +;   //"Os c�digos de servi�o diferente de TODOS ser�o exclu�dos"
                                 STR0060, "Aten��o!")           //"Deseja continuar?"
        ENDIF

        If lPassou

            For nY := 1 to oModelGrid:Length()

                oModelGrid:GoLine(nY)

                iF !oModelGrid:IsDeleted()

                    cCodServ := AllTrim(oModelGrid:GetValue ("CIO_CODISS"))

                    if(!("TODOS" $ cCodServ) .and. lISSTd)
                        oModelGrid:DeleteLine()
                    EndIf
                    
                EndIf

            Next nY
            lPassou := .F.
        else
            lRet := .F.
            oModelPad:SetErrorMessage(,,,,,STR0063,STR0064)
        EndIF
    EndIf
EndIF

Return lRet
