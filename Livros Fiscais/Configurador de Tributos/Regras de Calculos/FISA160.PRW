#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA160.ch" 
#Include "FWEditPanel.CH"

//Verifica se possui funcionalidades de formula
STATIC lCIN   := AliasIndic("CIN") .And. FindFunction("xFisFormul") .and. F2B->(FieldPos("F2B_ALTERA")) > 0 .and. F2B->(FieldPos("F2B_DTALT")) > 0  .and. F2B->(FieldPos("F2B_HRALT")) > 0

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA160()

Esta rotina tem objetivo de realizar o cadastro das regras de cálculo dos tributos, 
considerando os perfis de produto, operação, origem/destino e participante,
bem como as regras de composição da base de cálculo, alíquota e regras financeiras.

Esta rotina estará disponível somente na versão 12.

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA160()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic('F2B')
    dbSelectArea("F2B")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F2B")    
    oBrowse:SetDescription(STR0001) // Cadastro de regras de cálculo
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) // Dicionário desatualizado, verifique as atualizações do motor tributário fiscal.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick G Dias
@since 21/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.FISA160' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0010 ACTION 'VIEWDEF.FISA160' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.FISA160' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0012 ACTION 'VIEWDEF.FISA160' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE STR0013 ACTION 'VIEWDEF.FISA160' OPERATION 9 ACCESS 0 //'Copiar'

//Somente adicionará  botão se o campo com informação de alterações existir no ambiente
If F2B->(FieldPos("F2B_ALTERA")) > 0
    ADD OPTION aRotina TITLE STR0014 ACTION 'FSA160Hist'      OPERATION 4 ACCESS 0 //"Histórico de Alterações"
EndIF

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo da rotina de cadastro de regras de cálculo

@author Erick G Dias
@since 21/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai correspondete a tabela da regra.
Local oCabecalho := FWFormStruct(1, "F2B" )
//Estrutura correspondete a formula
Local oFORMULCAL     := Iif(lCIN,FWFormStruct(1,"CIN"),nil) 
Local oFORMULISE     := Iif(lCIN,FWFormStruct(1,"CIN"),nil) 
Local oFORMULOUT     := Iif(lCIN,FWFormStruct(1,"CIN"),nil) 

//Instanciando o modelo
If lCIN
    oModel	:=	MPFormModel():New('FISA160',{|oModel|AtualizForm(oModel)},{|oModel|VALIDACAO(oModel) },{|oModel|FSA160Grava(oModel)})
Else
    oModel	:=	MPFormModel():New('FISA160',/*Pre-Validacao*/,{|oModel|VALIDACAO(oModel) })
Endif

//Atribuindo cabeçalho para o modelo
oModel:AddFields("FISA160",,oCabecalho)

//Verifico se tabela CIN existe
If lCIN
    //Atribuindo estruturas para o modelo
    oModel:AddFields("FORMULCAL","FISA160",oFORMULCAL)
    oModel:AddFields("FORMULCAL_ISENTO","FISA160",oFORMULISE)    
    oModel:AddFields("FORMULCAL_OUTROS","FISA160",oFORMULOUT)    
EndIF

//Não permite alterar a sigla da regra
oCabecalho:SetProperty('F2B_REGRA' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })


//Validação para não permitir informar um código da regra que já exista no sistema (legado)
oCabecalho:SetProperty('F2B_REGRA' , MODEL_FIELD_VALID, {||( VldCodigo(oModel) )})

If lCIN
    //Habilitar o campo apenas se o F2B_RBASES estiver preenchido
    oCabecalho:SetProperty('F2B_MAXMIN' , MODEL_FIELD_WHEN, {|| !Empty(oModel:GetValue('FISA160',"F2B_RBASES")) } )
  
    //Tributado
    oFORMULCAL:SetProperty('CIN_FORMUL' , MODEL_FIELD_WHEN, {|| .T. })
    oFORMULCAL:SetProperty('CIN_CONSUL' , MODEL_FIELD_WHEN, {|| Fsa160HFor("FORMULCAL") .And. oModel:GetValue('FORMULCAL',"CIN_FILTRO") <> "ZZ"})    
    oFORMULCAL:SetProperty('CIN_FILTRO' , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL") })
    oFORMULCAL:SetProperty('CIN_VAL'    , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL") .And. oModel:GetValue('FORMULCAL',"CIN_FILTRO") == "ZZ" })
    oFORMULCAL:SetProperty('CIN_TRIB'   , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL") .And. oModel:GetValue('FORMULCAL',"CIN_FILTRO") == "05" } )

    //Isento
    oFORMULISE:SetProperty('CIN_FORMUL' , MODEL_FIELD_WHEN, {|| .T. })
    oFORMULISE:SetProperty('CIN_CONSUL' , MODEL_FIELD_WHEN, {|| Fsa160HFor("FORMULCAL_ISENTO") .And. oModel:GetValue('FORMULCAL_ISENTO',"CIN_FILTRO") <> "ZZ"})    
    oFORMULISE:SetProperty('CIN_FILTRO' , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL_ISENTO") })
    oFORMULISE:SetProperty('CIN_VAL'    , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL_ISENTO") .And. oModel:GetValue('FORMULCAL_ISENTO',"CIN_FILTRO") == "ZZ" })
    oFORMULISE:SetProperty('CIN_TRIB'   , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL_ISENTO") .And. oModel:GetValue('FORMULCAL_ISENTO',"CIN_FILTRO") == "05" } )

    //Outros
    oFORMULOUT:SetProperty('CIN_FORMUL' , MODEL_FIELD_WHEN, {|| .T. })
    oFORMULOUT:SetProperty('CIN_CONSUL' , MODEL_FIELD_WHEN, {|| Fsa160HFor("FORMULCAL_OUTROS") .And. oModel:GetValue('FORMULCAL_OUTROS',"CIN_FILTRO") <> "ZZ"})    
    oFORMULOUT:SetProperty('CIN_FILTRO' , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL_OUTROS") })
    oFORMULOUT:SetProperty('CIN_VAL'    , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL_OUTROS") .And. oModel:GetValue('FORMULCAL_OUTROS',"CIN_FILTRO") == "ZZ" })
    oFORMULOUT:SetProperty('CIN_TRIB'   , MODEL_FIELD_WHEN, {||  Fsa160HFor("FORMULCAL_OUTROS") .And. oModel:GetValue('FORMULCAL_OUTROS',"CIN_FILTRO") == "05" } )    

    oCabecalho:SetProperty('F2B_RBASE' , MODEL_FIELD_VALID, {||(Fsa160Form("F2B_RBASE"))})
    oCabecalho:SetProperty('F2B_RBASES' , MODEL_FIELD_VALID, {||(Fsa160Form("F2B_RBASES"))})
    oCabecalho:SetProperty('F2B_RALIQ' , MODEL_FIELD_VALID, {||(Fsa160Form("F2B_RALIQ"))})
    oCabecalho:SetProperty('F2B_TRBMAJ' , MODEL_FIELD_VALID, {||(Fsa160Form("F2B_TRBMAJ"))})
    oCabecalho:SetProperty('F2B_DEDDEP' , MODEL_FIELD_VALID, {||(Fsa160Form("F2B_DEDDEP"))})
    oCabecalho:SetProperty('F2B_DEDPRO' , MODEL_FIELD_VALID, {||(Fsa160Form("F2B_DEDPRO"))})
    oCabecalho:SetProperty('F2B_MAXMIN' , MODEL_FIELD_VALID, {||(Fsa160Form("F2B_MAXMIN"))})
    oCabecalho:SetProperty('F2B_CODESC' , MODEL_FIELD_VALID, {||(Fsa160Form("F2B_CODESC"))})

    //Não permite alterar os campos de Valor minimo e Maximo a sigla da regra
    oCabecalho:SetProperty('F2B_VLRMIN' , MODEL_FIELD_WHEN, {||  AllTrim(oModel:GetValue('FISA160',"F2B_OPRMIN")) == 'O:VAL_MANUAL' })
    oCabecalho:SetProperty('F2B_VLRMAX' , MODEL_FIELD_WHEN, {||  AllTrim(oModel:GetValue('FISA160',"F2B_OPRMAX")) == 'O:VAL_MANUAL' })
   
    //Cria relacionamento entre a tabela F2B e CIN.
    oModel:SetRelation( 'FORMULCAL', {{'CIN_FILIAL', 'xFilial("CIN")'},{'CIN_IREGRA', 'F2B_ID'}, {'CIN_TREGRA', "'8 '"}}, CIN->( IndexKey(3)))
    oModel:SetRelation( 'FORMULCAL_ISENTO', {{'CIN_FILIAL', 'xFilial("CIN")'},{'CIN_IREGRA', 'F2B_ID'}, {'CIN_TREGRA', "'11'"}}, CIN->( IndexKey(3)))
    oModel:SetRelation( 'FORMULCAL_OUTROS', {{'CIN_FILIAL', 'xFilial("CIN")'},{'CIN_IREGRA', 'F2B_ID'}, {'CIN_TREGRA', "'12'"}}, CIN->( IndexKey(3)))

EndIF

oModel:SetPrimaryKey( {"F2B_FILIAL","F2B_ID","F2B_REGRA","DTOS(F2B_VIGINI)","DTOS(F2B_VIGFIM)"} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Erick G Dias
@since 21/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel    := FWLoadModel( "FISA160" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho:= FWFormStruct(2, "F2B")
Local oView     := Nil
Local cVersao 	:= GetVersao(.F.)
Local lF2BRND   := F2B->(FieldPos("F2B_RND")) > 0
//Somente adiciona na view da fórmula o campo CIN_FORMUL
Local oFormula  := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ "CIN_FORMUL"}), nil ) 
Local oFormulaI  := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ "CIN_FORMUL"}), nil ) 
Local oFormulaO  := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ "CIN_FORMUL"}), nil ) 
Local oRegra    := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ "CIN_CONSUL/CIN_FILTRO/CIN_VAL/CIN_TRIB"}), nil ) //Somente adiciona na view da regra o campo CIN_CONSUL
Local oRegraI    := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ "CIN_CONSUL/CIN_FILTRO/CIN_VAL/CIN_TRIB"}), nil ) //Somente adiciona na view da regra o campo CIN_CONSUL
Local oRegraO    := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ "CIN_CONSUL/CIN_FILTRO/CIN_VAL/CIN_TRIB"}), nil ) //Somente adiciona na view da regra o campo CIN_CONSUL

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_ABA' , oCabecalho , 'FISA160' )

//Retiro o ID da view
oCabecalho:RemoveField('F2B_ID')

//Aqui é a definição de exibir dois campos por linha
oView:SetViewProperty( "VIEW_ABA", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

//Cria os grupos
oCabecalho:AddGroup( 'GRUPO_DEF'          , STR0005 , '' , 2 )    //"Definição da Regra"
oCabecalho:AddGroup( 'GRUPO_REGRAS'       , "Regras de Cálculo" , '' , 2 )    //"Definição das Regras"
oCabecalho:AddGroup( 'GRUPO_REGRAS_LIMITE', "Regras de Limitações do Tributo" , '' , 2 )    //"Definição dos Perfis"
oCabecalho:AddGroup( 'GRUPO_ESCRITURACAO' , "Regras de Escrituração" , '' , 2 )    //"Definição dos Perfis"
oCabecalho:AddGroup( 'GRUPO_REGRAS_COMPL' , "Regras Complementares" , '' , 2 )    //"Definição das Regras"
oCabecalho:AddGroup( 'GRUPO_PERFIS'       , STR0007 , '' , 2 )    //"Definição dos Perfis"

//Campos que fazem parte do grupo do tributo
oCabecalho:SetProperty( 'F2B_REGRA'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_DEF' )
oCabecalho:SetProperty( 'F2B_DESC'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_DEF' )
oCabecalho:SetProperty( 'F2B_VIGINI'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_DEF' )
oCabecalho:SetProperty( 'F2B_VIGFIM'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_DEF' )
oCabecalho:SetProperty( 'F2B_TRIB'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_DEF' )
oCabecalho:SetProperty( 'F2B_DTRIB'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_DEF' )

//Campos que fazem parte do grupo de regras do tributo
oCabecalho:SetProperty( 'F2B_RBASE' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS' )
oCabecalho:SetProperty( 'F2B_DBASE' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS' )
oCabecalho:SetProperty( 'F2B_RALIQ' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS' )
oCabecalho:SetProperty( 'F2B_DALIQ' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS' )
oCabecalho:SetProperty( 'F2B_RFIN'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS' )
oCabecalho:SetProperty( 'F2B_DFIN'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS' )


If lCIN
    //Adiciona os campos no grupo
    oCabecalho:SetProperty( 'F2B_RBASES' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_DBASES' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_TRBMAJ' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_DETMAJ' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_DEDDEP' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_DETDEP' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_RGGUIA' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_DRGUIA' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_DEDPRO' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_DETPRO' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    oCabecalho:SetProperty( 'F2B_MAXMIN' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_COMPL' )
    
    // Campos que fazem parte da regra de limitação do tributo
    oCabecalho:SetProperty( 'F2B_OPRMIN', MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_LIMITE' )
    oCabecalho:SetProperty( 'F2B_VLRMIN', MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_LIMITE' )
    oCabecalho:SetProperty( 'F2B_OPRMAX', MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_LIMITE' )
    oCabecalho:SetProperty( 'F2B_VLRMAX', MVC_VIEW_GROUP_NUMBER, 'GRUPO_REGRAS_LIMITE' )
EndIF

oCabecalho:SetProperty("F2B_RBASE" , MVC_VIEW_ORDEM  , "01")
oCabecalho:SetProperty("F2B_DBASE" , MVC_VIEW_ORDEM  , "02")
oCabecalho:SetProperty("F2B_RALIQ" , MVC_VIEW_ORDEM  , "03")
oCabecalho:SetProperty("F2B_DALIQ" , MVC_VIEW_ORDEM  , "04")

If lCIN
    oCabecalho:SetProperty("F2B_TRBMAJ" , MVC_VIEW_ORDEM , "05")
    oCabecalho:SetProperty("F2B_DETMAJ" , MVC_VIEW_ORDEM , "06")
    oCabecalho:SetProperty("F2B_DEDDEP" , MVC_VIEW_ORDEM , "07")
    oCabecalho:SetProperty("F2B_DETDEP" , MVC_VIEW_ORDEM , "08")
    oCabecalho:SetProperty("F2B_DEDPRO" , MVC_VIEW_ORDEM , "09")
    oCabecalho:SetProperty("F2B_DETPRO" , MVC_VIEW_ORDEM , "10")
    oCabecalho:SetProperty("F2B_RGGUIA" , MVC_VIEW_ORDEM , "11")
    oCabecalho:SetProperty("F2B_DRGUIA" , MVC_VIEW_ORDEM , "12")
    oCabecalho:SetProperty("F2B_RBASES" , MVC_VIEW_ORDEM , "13")
    oCabecalho:SetProperty("F2B_DBASES" , MVC_VIEW_ORDEM , "14")
    oCabecalho:SetProperty("F2B_MAXMIN" , MVC_VIEW_ORDEM , "15")
EndIF

oCabecalho:SetProperty("F2B_RFIN" , MVC_VIEW_ORDEM   , "16")
oCabecalho:SetProperty("F2B_DFIN" , MVC_VIEW_ORDEM   , "17")
oCabecalho:SetProperty("F2B_RAPUR" , MVC_VIEW_ORDEM  , "18")
oCabecalho:SetProperty("F2B_DAPUR" , MVC_VIEW_ORDEM  , "19")

If lF2BRND
    oCabecalho:SetProperty("F2B_RND" , MVC_VIEW_ORDEM    , "45")
EndIF

oCabecalho:SetProperty("F2B_PEROD" , MVC_VIEW_ORDEM  , "21")
oCabecalho:SetProperty("F2B_DOD" , MVC_VIEW_ORDEM    , "22")
oCabecalho:SetProperty("F2B_PERFPA" , MVC_VIEW_ORDEM , "23")
oCabecalho:SetProperty("F2B_DPA" , MVC_VIEW_ORDEM    , "24")
oCabecalho:SetProperty("F2B_PERFOP" , MVC_VIEW_ORDEM , "25")
oCabecalho:SetProperty("F2B_DOP" , MVC_VIEW_ORDEM    , "26")
oCabecalho:SetProperty("F2B_PERFPR" , MVC_VIEW_ORDEM , "27")
oCabecalho:SetProperty("F2B_DPR" , MVC_VIEW_ORDEM    , "28")

//Verifica se o campo de controle de arredondamento existe antes de adicionar no grupa das regras complementares
If lF2BRND
    oCabecalho:SetProperty( 'F2B_RND' , MVC_VIEW_GROUP_NUMBER,  'GRUPO_REGRAS' )    
EndIf

//Campos que fazem parte do grupo de perfis
oCabecalho:SetProperty( 'F2B_PEROD'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_PERFIS' )
oCabecalho:SetProperty( 'F2B_DOD'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_PERFIS' )
oCabecalho:SetProperty( 'F2B_PERFPA' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_PERFIS' )
oCabecalho:SetProperty( 'F2B_DPA'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_PERFIS' )
oCabecalho:SetProperty( 'F2B_PERFOP' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_PERFIS' )
oCabecalho:SetProperty( 'F2B_DOP'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_PERFIS' )
oCabecalho:SetProperty( 'F2B_PERFPR' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_PERFIS' )
oCabecalho:SetProperty( 'F2B_DPR'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_PERFIS' )

//Atribui os campos para grupo de escrituração
If lCIN
    
    oCabecalho:SetProperty( 'F2B_RAPUR' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ESCRITURACAO' )
    oCabecalho:SetProperty( 'F2B_DAPUR' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ESCRITURACAO' )
    
    oCabecalho:SetProperty( 'F2B_CODESC'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ESCRITURACAO' )
    oCabecalho:SetProperty( 'F2B_DESESC'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ESCRITURACAO' )

    oCabecalho:SetProperty("F2B_OPRMIN" , MVC_VIEW_ORDEM , "40")
    oCabecalho:SetProperty("F2B_VLRMIN" , MVC_VIEW_ORDEM , "41")
    oCabecalho:SetProperty("F2B_OPRMAX" , MVC_VIEW_ORDEM , "42")
    oCabecalho:SetProperty("F2B_VLRMAX" , MVC_VIEW_ORDEM , "43")
EndIf

//Picture do campo código
oCabecalho:SetProperty('F2B_TRIB' , MVC_VIEW_PICT, "@!")

//Retira da view os campos de ID
oCabecalho:RemoveField('F2B_FKKID')

IF cVersao == '12'
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty( "*", "GRIDNOORDER" )
EndIF

// //Se a tabela CIN existir então dividirei a tela em duas partes, uma para dados cadastrais da regr e outra com detalhamento da fórmula
If lCIN
    oCabecalho:SetProperty("F2B_MAXMIN", MVC_VIEW_TITULO, "Valor maior ou menor entre bases")
    oCabecalho:SetProperty("F2B_RBASES", MVC_VIEW_TITULO, "Base de Cálculo Auxiliar")
    oCabecalho:SetProperty("F2B_TRBMAJ", MVC_VIEW_TITULO, "Tributo para Majoração")
    oCabecalho:SetProperty("F2B_DEDDEP", MVC_VIEW_TITULO, "Dedução por Dependentes")
    oCabecalho:SetProperty("F2B_DEDPRO", MVC_VIEW_TITULO, "Tabela Progressiva")
    oCabecalho:SetProperty("F2B_RAPUR", MVC_VIEW_TITULO, "Regra de Apuração")
    oCabecalho:SetProperty("F2B_RFIN", MVC_VIEW_TITULO, "Regra Financeira")
    oCabecalho:SetProperty("F2B_RND", MVC_VIEW_TITULO, "Configuração de Arredondamento")

    oCabecalho:SetProperty("F2B_DETPRO", MVC_VIEW_TITULO, "Descrição")
    oCabecalho:SetProperty("F2B_DETDEP", MVC_VIEW_TITULO, "Descrição")
    oCabecalho:SetProperty("F2B_DETMAJ", MVC_VIEW_TITULO, "Descrição")

    oCabecalho:SetProperty("F2B_CODESC", MVC_VIEW_TITULO, "Escrituração")

    oCabecalho:SetProperty("F2B_PEROD", MVC_VIEW_TITULO, "Origem/Destino")
    oCabecalho:SetProperty("F2B_PERFPA", MVC_VIEW_TITULO, "Participante")
    oCabecalho:SetProperty("F2B_PERFOP", MVC_VIEW_TITULO, "Operação")
    oCabecalho:SetProperty("F2B_PERFPR", MVC_VIEW_TITULO, "Produto")

    // Campos que fazem parte da regra de limitação do tributo
    oCabecalho:SetProperty( 'F2B_OPRMIN', MVC_VIEW_TITULO, 'Oper. Min. de limitação do Tributo' )
    oCabecalho:SetProperty( 'F2B_VLRMIN', MVC_VIEW_TITULO, 'Valor Min. Manual' )
    oCabecalho:SetProperty( 'F2B_OPRMAX', MVC_VIEW_TITULO, 'Oper. Max. de limitação do Tributo' )
    oCabecalho:SetProperty( 'F2B_VLRMAX', MVC_VIEW_TITULO, 'Valor Max. Manual' )

    // //Cria as views do operando e da fórmula    
     oView:AddField( 'VIEW_FORMULA' , oFormula, 'FORMULCAL')
     oView:AddField( 'VIEW_FORMULA_ISENTO' , oFormulaI, 'FORMULCAL_ISENTO')
     oView:AddField( 'VIEW_FORMULA_OUTROS' , oFormulaO, 'FORMULCAL_OUTROS')

    // //Cria as view do campo regra
     oView:AddField( 'VIEW_REGRA' , oRegra, 'FORMULCAL')
     oView:AddField( 'VIEW_REGRA_ISENTO' , oRegraI, 'FORMULCAL_ISENTO')
     oView:AddField( 'VIEW_REGRA_OUTROS' , oRegraO, 'FORMULCAL_OUTROS')

    // //Ajuste dos títulos dos campos de filtros de fórmula
    oRegra:SetProperty("CIN_CONSUL", MVC_VIEW_TITULO, "Consulta de Regras")
    oRegra:SetProperty("CIN_FILTRO", MVC_VIEW_TITULO, "Tipo da Regra a ser consultada")
    oRegra:SetProperty("CIN_VAL", MVC_VIEW_TITULO, "Valor a ser adicionado na fórmula")
    oRegra:SetProperty("CIN_TRIB", MVC_VIEW_TITULO, "Tributo para filtrar a consulta")

    oRegraI:SetProperty("CIN_CONSUL", MVC_VIEW_TITULO, "Consulta de Regras")
    oRegraI:SetProperty("CIN_FILTRO", MVC_VIEW_TITULO, "Tipo da Regra a ser consultada")
    oRegraI:SetProperty("CIN_VAL", MVC_VIEW_TITULO, "Valor a ser adicionado na fórmula")
    oRegraI:SetProperty("CIN_TRIB", MVC_VIEW_TITULO, "Tributo para filtrar a consulta")

    oRegraO:SetProperty("CIN_CONSUL", MVC_VIEW_TITULO, "Consulta de Regras")
    oRegraO:SetProperty("CIN_FILTRO", MVC_VIEW_TITULO, "Tipo da Regra a ser consultada")
    oRegraO:SetProperty("CIN_VAL", MVC_VIEW_TITULO, "Valor a ser adicionado na fórmula")
    oRegraO:SetProperty("CIN_TRIB", MVC_VIEW_TITULO, "Tributo para filtrar a consulta")

    // //Ordem dos campos da CIN para realizarem filtros nas fórmulas
    oRegra:SetProperty("CIN_FILTRO" ,   MVC_VIEW_ORDEM, "01")
    oRegra:SetProperty("CIN_TRIB"   ,   MVC_VIEW_ORDEM, "02")
    oRegra:SetProperty("CIN_CONSUL" ,   MVC_VIEW_ORDEM, "03")
    oRegra:SetProperty("CIN_VAL"    ,   MVC_VIEW_ORDEM, "04")   

    oRegraI:SetProperty("CIN_FILTRO" ,  MVC_VIEW_ORDEM, "01")
    oRegraI:SetProperty("CIN_TRIB"   ,  MVC_VIEW_ORDEM, "02")
    oRegraI:SetProperty("CIN_CONSUL" ,  MVC_VIEW_ORDEM, "03")
    oRegraI:SetProperty("CIN_VAL"    ,  MVC_VIEW_ORDEM, "04")    

    oRegraO:SetProperty("CIN_FILTRO" ,  MVC_VIEW_ORDEM, "01")
    oRegraO:SetProperty("CIN_TRIB"   ,  MVC_VIEW_ORDEM, "02")
    oRegraO:SetProperty("CIN_CONSUL" ,  MVC_VIEW_ORDEM, "03")
    oRegraO:SetProperty("CIN_VAL"    ,  MVC_VIEW_ORDEM, "04")    

    oFormula:SetProperty("CIN_FORMUL"  , MVC_VIEW_CANCHANGE, .F.)
    oFormulaI:SetProperty("CIN_FORMUL" , MVC_VIEW_CANCHANGE, .F.)
    oFormulaO:SetProperty("CIN_FORMUL" , MVC_VIEW_CANCHANGE, .F.)

     //Divide a tela em duas pastas
     oView:CreateFolder( 'PASTAS' )
     oView:AddSheet( 'PASTAS', 'ABA01', "Definição da regra de cálculo do tributo"       )
     oView:AddSheet( 'PASTAS', 'ABA02', "Detalhamento da Fórmula de Cálculo" )
    
    //Aba da esquerda cheia
     oView:CreateHorizontalBox( 'ESQUERDA', 100,,, 'PASTAS', 'ABA01' ) //Aqui ficarão todos os componentes de tela que já estavam na onda 1
     oView:CreateHorizontalBox( 'DIREITA', 100,,, 'PASTAS', 'ABA02' ) //Aqui ficarão todos os componentes de tela que já estavam na onda 1
    
     oView:CreateFolder( 'SUBPASTAS','DIREITA' )
     oView:AddSheet( 'SUBPASTAS', 'TRIBUTADO', "Tributado")
     oView:AddSheet( 'SUBPASTAS', 'ISENTO', "Isento" )
     oView:AddSheet( 'SUBPASTAS', 'OUTROS', "Outros" )

    //--------------------------------
    //Botões da fórmula aba tributado
    //--------------------------------
    //Aba da direita dividida em duas partes horizontais
    oView:CreateHorizontalBox( 'TITULO'              , 30,,.T., 'SUBPASTAS', 'TRIBUTADO') //Aqui crio um objeto vazio somente para colocar o título
    oView:CreateHorizontalBox( 'BOX_SUPERIOR'        , 140,,.T., 'SUBPASTAS', 'TRIBUTADO') 
    oView:CreateVerticalBox( 'BOX_SUPERIOR_ESQUERDO' , 600,'BOX_SUPERIOR',.T., 'SUBPASTAS', 'TRIBUTADO') //Aqui ficarão os campos para seleção das regras a serem adicionadas na fórmula
    oView:CreateHorizontalBox( 'BOX_INTERMEDIARIO'   , 80,,.T., 'SUBPASTAS', 'TRIBUTADO') //Aqui ficarão os botões de adicionar, limpar dos operadores etc
    oView:CreateHorizontalBox( 'BOX_INFERIOR'        , 230,,.T., 'SUBPASTAS', 'TRIBUTADO') //Aqui ficará o campo memo de fórmula
     
    //Painel com os botões
    // //Adiciono componente da fórmula, que está definido por meio da função xFisFormul().    
    oView:AddOtherObject("BOTOES", {|oPanel| xFisFormul(oPanel, "FORMULCAL","VIEW_FORMULA", "8", "F2B_REGRA", "FISA160", "CIN_CONSUL", "VIEW_REGRA")})

    // //Painel vazio para ter o título da tela
    oView:AddOtherObject("LABEL", {|oPanel| xFisLabel(oPanel)}) 

    //--------------------------------
    //Botões da fórmula aba Isento
    //--------------------------------
    oView:CreateHorizontalBox( 'ITITULO'              , 30,,.T., 'SUBPASTAS', 'ISENTO') //Aqui crio um objeto vazio somente para colocar o título
    oView:CreateHorizontalBox( 'IBOX_SUPERIOR'        , 140,,.T., 'SUBPASTAS', 'ISENTO') 
    oView:CreateVerticalBox( 'IBOX_SUPERIOR_ESQUERDO' , 600,'IBOX_SUPERIOR',.T., 'SUBPASTAS', 'ISENTO') //Aqui ficarão os campos para seleção das regras a serem adicionadas na fórmula
    oView:CreateHorizontalBox( 'IBOX_INTERMEDIARIO'   , 80,,.T., 'SUBPASTAS', 'ISENTO') //Aqui ficarão os botões de adicionar, limpar dos operadores etc
    oView:CreateHorizontalBox( 'IBOX_INFERIOR'        , 230,,.T., 'SUBPASTAS', 'ISENTO') //Aqui ficará o campo memo de fórmula

    oView:AddOtherObject("BOTOES_ISENTO", {|oPanel| xFisFormul(oPanel, "FORMULCAL_ISENTO","VIEW_FORMULA_ISENTO", "8", "F2B_REGRA", "FISA160", "CIN_CONSUL", "VIEW_REGRA_ISENTO")})

    // //Painel vazio para ter o título da tela
    oView:AddOtherObject("LABEL_ISENTO", {|oPanel| xFisLabel(oPanel)}) 

    //--------------------------------
    //Botões da fórmula aba Outros
    //--------------------------------
    oView:CreateHorizontalBox( 'OTITULO'              , 30,,.T., 'SUBPASTAS', 'OUTROS') //Aqui crio um objeto vazio somente para colocar o título
    oView:CreateHorizontalBox( 'OBOX_SUPERIOR'        , 140,,.T., 'SUBPASTAS', 'OUTROS') 
    oView:CreateVerticalBox( 'OBOX_SUPERIOR_ESQUERDO' , 600,'OBOX_SUPERIOR',.T., 'SUBPASTAS', 'OUTROS') //Aqui ficarão os campos para seleção das regras a serem adicionadas na fórmula
    oView:CreateHorizontalBox( 'OBOX_INTERMEDIARIO'   , 80,,.T., 'SUBPASTAS', 'OUTROS') //Aqui ficarão os botões de adicionar, limpar dos operadores etc
    oView:CreateHorizontalBox( 'OBOX_INFERIOR'        , 230,,.T., 'SUBPASTAS', 'OUTROS') //Aqui ficará o campo memo de fórmula

    oView:AddOtherObject("BOTOES_OUTROS", {|oPanel| xFisFormul(oPanel, "FORMULCAL_OUTROS","VIEW_FORMULA_OUTROS", "8", "F2B_REGRA", "FISA160", "CIN_CONSUL", "VIEW_REGRA_OUTROS")})

    // //Painel vazio para ter o título da tela
    oView:AddOtherObject("LABEL_OUTROS", {|oPanel| xFisLabel(oPanel)}) 

    //Atribuição de Owner
    //Aba da esquerda
    oView:SetOwnerView( 'VIEW_ABA', 'ESQUERDA')   
    
    // //Título
    oView:SetOwnerView( 'LABEL'        , 'TITULO')       

    //Campos de filtros
    oView:SetOwnerView( 'VIEW_REGRA'    , 'BOX_SUPERIOR_ESQUERDO')
    
    //Botões para manipular fórmula
    oView:SetOwnerView( 'BOTOES'        , 'BOX_INTERMEDIARIO')       
    
    //Fórmula
    oView:SetOwnerView( 'VIEW_FORMULA'  , 'BOX_INFERIOR')
    
    //Seto o layout para que o campo memo fique um pouco maior, preenchendo mais tela    
    oView:SetViewProperty( "VIEW_FORMULA", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 4 } )

    //Atribuo um título para a segunda aba.
    oView:EnableTitleView('LABEL'  , "Composição da Fórmula (Tributado)")     

    //----------
    //Aba Isento
    //----------

    // //Título
    oView:SetOwnerView( 'LABEL_ISENTO'        , 'ITITULO')       

    //Campos de filtros
    oView:SetOwnerView( 'VIEW_REGRA_ISENTO'    , 'IBOX_SUPERIOR_ESQUERDO')
    
    //Botões para manipular fórmula
    oView:SetOwnerView( 'BOTOES_ISENTO'        , 'IBOX_INTERMEDIARIO')       
    
    //Fórmula
    oView:SetOwnerView( 'VIEW_FORMULA_ISENTO'  , 'IBOX_INFERIOR')
    
    //Seto o layout para que o campo memo fique um pouco maior, preenchendo mais tela    
    oView:SetViewProperty( "VIEW_FORMULA_ISENTO", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 4 } )

    //Atribuo um título para a segunda aba.
    oView:EnableTitleView('LABEL_ISENTO'  , "Composição da Fórmula (Isento)")         

    //----------
    //Aba Outros
    //----------

    // //Título
    oView:SetOwnerView( 'LABEL_OUTROS'        , 'OTITULO')       

    //Campos de filtros
    oView:SetOwnerView( 'VIEW_REGRA_OUTROS'    , 'OBOX_SUPERIOR_ESQUERDO')
    
    //Botões para manipular fórmula
    oView:SetOwnerView( 'BOTOES_OUTROS'        , 'OBOX_INTERMEDIARIO')       
    
    //Fórmula
    oView:SetOwnerView( 'VIEW_FORMULA_OUTROS'  , 'OBOX_INFERIOR')
    
    //Seto o layout para que o campo memo fique um pouco maior, preenchendo mais tela    
    oView:SetViewProperty( "VIEW_FORMULA_OUTROS", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 4 } )

    //Atribuo um título para a segunda aba.
    oView:EnableTitleView('LABEL_OUTROS'  , "Composição da Fórmula (Outros)") 

EndIF

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDACAO
Função que realiza as validações do modelo
@param		oModel	    - Objeto  -  Objeto do modelo FISA150
@Return     lRet       - Booleano - REtorno com validação, .T. pode gravar, .F. não poderá gravar.
@author Erick G Dias
@since 09/07/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function VALIDACAO(oModel)

Local lRet          := .T.
Local dDtIni        := oModel:GetValue ('FISA160',"F2B_VIGINI" )
Local dDtFim        := oModel:GetValue ('FISA160',"F2B_VIGFIM" )
Local cRegra        := oModel:GetValue ('FISA160',"F2B_REGRA" ) 
Local nOperation 	:= oModel:GetOperation()
Local cErrForml     := ""

//Verifica se já existe regra com mesmo código e mesma vigência já gravados
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    IF VigIniFIm(cRegra, dDtIni, dDtFim, nOperation == MODEL_OPERATION_UPDATE, oModel:GetValue ('FISA160',"F2B_ID" ))
        lRet:= .F.
        Help( ,, 'Help',, STR0008 , 1, 0 ) //'Regra já cadastrada para a vigência informada'
    EndIF

    //Se a tabela CIN existe então será verificada a sintaxe da fórmula antes de gravar
    If lRet .AND. lCIN .And. !xForCheck("FORMULCAL", @cErrForml, .F., "8", "F2B_REGRA", "FISA160"  )       
        lRet:= .F.
        Help( ,, 'Help',, "Erro de sintaxe da Fórmula: -" + CRLF + CRLF + cErrForml, 1, 0 ) // 'Erro na fórmula, por favor verifique
    EndIF

    //Validação nos campos obrigatorios
    If lRet .And. lCIN
        lRet:= FuncObrig(oModel)
    EndIf
    
    //Se a tabela CIN existe então será verificada a sintaxe da fórmula antes de gravar
    If lRet .AND. lCIN .And. !xForCheck("FORMULCAL_ISENTO", @cErrForml, .F., "11", "F2B_REGRA", "FISA160", .T., xFisTpForm("6")+cRegra  )     
        lRet:= .F.
        Help( ,, 'Help',, "Erro de sintaxe da Fórmula(Isento): -" + CRLF + CRLF + cErrForml, 1, 0 ) // 'Erro na fórmula, por favor verifique
    EndIF

    //Se a tabela CIN existe então será verificada a sintaxe da fórmula antes de gravar
    If lRet .AND. lCIN .And. !xForCheck("FORMULCAL_OUTROS", @cErrForml, .F., "12", "F2B_REGRA", "FISA160", .T., xFisTpForm("6")+cRegra  )
        lRet:= .F.
        Help( ,, 'Help',, "Erro de sintaxe da Fórmula(Outros): -" + CRLF + CRLF + cErrForml, 1, 0 ) // 'Erro na fórmula, por favor verifique
    EndIF    

EndiF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VigIniFIm
Função que verifica se data inicial e data final já existem no cadastro de regras

@param     cRegra      - String - Sigla da Regra
@param     dDtIni      - Date - Data inicial de vigência
@param     dDtFim      - Date - Data final de vigência
@param     lEdit       - Booleano - indica se é uma operação de edição

@return    lRet        - Booleano - Indica se encontrou a regra com data final de vigência vazio 

@author Erick G Dias
@since 09/07/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function VigIniFIm(cRegra, dDtIni, dDtFim, lEdit,cIdF2B)

Local lRet      := .F.
Local cSelect	:= ""
Local cFrom	    := ""
Local cWhere	:= ""
Local cAliasQry	:= ""

//Query filtrando filial e regra
cSelect := "F2B.F2B_REGRA"
cFrom   += RetSQLName("F2B") + " F2B "
cWhere  += "F2B.F2B_FILIAL = " + ValToSQL(xFilial("F2B")) + " AND "
cWhere  += "F2B.F2B_REGRA = " + ValToSQL(cRegra) + " AND "
IF lCIN
    cWhere  += "(F2B.F2B_ALTERA =  ' ' OR F2B.F2B_ALTERA =  '2' ) AND "
Endif   

cWhere  += "( "

//Verifica se está compreendido em cadastro somente com data inicial preenchida
cWhere  += "( " + ValToSQL(dDtIni) + " >= F2B.F2B_VIGINI  AND F2B.F2B_VIGFIM = ' ' ) OR"
//Verifica se a data inicial está compreenchida em algum cadastro como data inicial e final informados
cWhere  += "( " + ValToSQL(dDtIni) + " >= F2B.F2B_VIGINI  AND " + ValToSQL(dDtIni) + " <= F2B.F2B_VIGFIM ) "

//Tratamento para data final
IF Empty(dDtFim)
    //Se no cadastro não foi informado a data final, então verificará se já existe no cadastro alguma linha sem data final preenchida
    cWhere  += " OR ( F2B.F2B_VIGFIM = ' ' ) "
ElseIf !Empty(dDtFim)
    //Caso a data final seja informada então verificaremos se está´comprendida em algum cadastro com data inicial e final preenchidos.
    cWhere  += " OR ( " + ValToSQL(dDtFim) + " >= F2B.F2B_VIGINI  AND " + ValToSQL(dDtFim) + " <= F2B.F2B_VIGFIM ) "
    cWhere  += " OR ( " + ValToSQL(dDtFim) + " >= F2B.F2B_VIGINI  AND F2B.F2B_VIGFIM = ' ') "
EndIF

cWhere  += " ) AND " 

If lEdit
    //Se for edição desconsiderarei a linha editada, para não entrar em conflito com ela mesma
    //Como temos consulta padrão da F2B, ela acaba desposicionando o tributo, e por este motivo antes de gravar eu retorno a F2B originalmente clicada no browse para edição
    DbSelectArea("F2B")
    F2B->(DbSetOrder(3))
    If F2B->(MsSeek( xFilial("F2B") + cIdF2B ))
        cWhere  += " F2B.R_E_C_N_O_ <> " + ValtoSql(F2B->(recno())) + " AND "    
    EndIF
    F2B->(DbSetOrder(1))
EndIF

cWhere  += "F2B.D_E_L_E_T_ = ' '"		
cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"

cAliasQry := GetNextAlias()

BeginSQL Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%

EndSQL

IF !(cAliasQry)->(Eof())
    //já existe regra cadastrada para esta vigência
    lRet    := .T.
EndIF

dbSelectArea(cAliasQry)
dbCloseArea()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCodigo
Função que valida se o código da regra já não está cadastrado ou
já não é utilizado pelo MATXFIS nos tributos legados.

@author joao.pellegrini
@since 19/07/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function VldCodigo(oModel)

Local cCodigo     := oModel:GetValue ('FISA160', "F2B_REGRA")
Local lRet          := .T.
Local cTrMtxfis3  := "ICM|CPM|IPI|ICR|CMP|DIF|ICC|ISS|IRR|INS|PIS|COF|CSL|PS2|CF2|PS3|CF3|CPB|ZFI|ZFP|ZFC|FCP|FCM|FST|INP|PTG"

// Não permito cadastrar se utilizar um código já utilizado pelo MATXFIS nos tributos legados.
If (Len(Alltrim(cCodigo)) == 3 .AND. AllTrim(cCodigo) $ cTrMtxfis3 )
    lRet := .F.
EndIf

//Não pode digitar operadores e () no código
If "*" $ cCodigo .Or. ;
   "/" $ cCodigo .Or. ;
   "-" $ cCodigo .Or. ;
   "+" $ cCodigo .Or. ;
   "(" $ cCodigo .Or. ;
   ")" $ cCodigo
    Help( ,, 'Help',, "Código não pode conter os caracteres '*', '/', '+', '-', '(' e ')'", 1, 0 ) 
    return .F.
EndIF

IF " " $ Alltrim(cCodigo)
    Help( ,, 'Help',, "Código não pode conter espaço.", 1, 0 ) 
    Return .F.
EndIf

If lCIN
    //Primeiro limpa a fórmula
    xForClear("FORMULCAL_ISENTO", .F., "VIEW_FORMULA_ISENTO", .F.)

    //Primeiro limpa a fórmula
    xForClear("FORMULCAL_OUTROS", .F., "VIEW_FORMULA_OUTROS", .F.)

    //Se o código estiver preenchido, então atualizarei o padrão da regra de isento e outros
    If !Empty(cCodigo)
        xForBtnAct(xFisTpForm("6")+cCodigo, "FORMULCAL_ISENTO", .F., "VIEW_FORMULA_ISENTO")
        xForBtnAct(xFisTpForm("6")+cCodigo, "FORMULCAL_OUTROS", .F., "VIEW_FORMULA_OUTROS")  
    EndIF    
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160Grava
Função responsável por realizar a gravação da regra de base de alíquota
Aqui faremos o tratamento do histórico de alterações

@author Rafael.Soliveira
@since 04/02/2020
@version P12.1.20

/*/
//-------------------------------------------------------------------
Function FSA160Grava(oModel)
Local nOperation 	:= oModel:GetOperation()
Local cFormula     	:= ""
Local cFormulaI    	:= ""
Local cFormulaO    	:= ""
Local cIdRegra      := "" //oModel:GetValue ('FISA160','F2B_ID')
Local cCodigo       := oModel:GetValue ('FISA160',"F2B_REGRA")   // Código Regra
Local cDescri       := oModel:GetValue ('FISA160',"F2B_DESC")    // Descrição   
Local cTrib         := oModel:GetValue ('FISA160',"F2B_TRIB")    // Tributo     
Local dDataIni      := oModel:GetValue ('FISA160',"F2B_VIGINI")  //	Data Início 
Local dDataFin      := oModel:GetValue ('FISA160',"F2B_VIGFIM")  //	Data Final  
Local cBase         := oModel:GetValue ('FISA160',"F2B_RBASE")   // Base Cálculo
Local cAliq         := oModel:GetValue ('FISA160',"F2B_RALIQ")   // Alíquota    
Local cOrigDest     := oModel:GetValue ('FISA160',"F2B_PEROD")   // Perf.Ori/Des
Local cPart         := oModel:GetValue ('FISA160',"F2B_PERFPA")  //	Perf. Part. 
Local cOper         := oModel:GetValue ('FISA160',"F2B_PERFOP")  //	Perf. Oper. 
Local cProd         := oModel:GetValue ('FISA160',"F2B_PERFPR")  //	Perf. Prod. 
Local cFin          := oModel:GetValue ('FISA160',"F2B_RFIN")    // Financeira  
Local cApur         := oModel:GetValue ('FISA160',"F2B_RAPUR")   // Regra Apur. 
Local cAltera       := ""
Local cArred        := oModel:GetValue ('FISA160',"F2B_RND")     // Config Arred  
Local cBaseSec      := oModel:GetValue ('FISA160',"F2B_RBASES")  // Código da base secundária
Local cTribMaj      := oModel:GetValue ('FISA160',"F2B_TRBMAJ")  // Código do tributo que fará majoração
Local cDedDep       := oModel:GetValue ('FISA160',"F2B_DEDDEP")  // Código código da regra de dependentes
Local cDedPro       := oModel:GetValue ('FISA160',"F2B_DEDPRO")  // Código código da regra de dedução da tabela progressiva
Local cCodesc       := oModel:GetValue ('FISA160',"F2B_CODESC")  // Código da escrituração   
Local cMaxMin       := oModel:GetValue ('FISA160',"F2B_MAXMIN")  // Tratamento para valor maior ou menor entre bases
Local nVlrMin       := oModel:GetValue ('FISA160',"F2B_VLRMIN")  // Valor maximo do Tributo
Local nVlrMax       := oModel:GetValue ('FISA160',"F2B_VLRMAX")  // Valor minimo do Tributo
Local cLimMin       := oModel:GetValue ('FISA160',"F2B_OPRMIN")  // Operador Limite Minimo
Local cLimMax       := oModel:GetValue ('FISA160',"F2B_OPRMAX")  // Operador Limite Maximo
Local cCodRGuia     := oModel:GetValue ('FISA160',"F2B_RGGUIA")  // Regra para geração da guia de recolhimento
Local cOldIdReg     := ""
Local aCampos       := oModel:GetModel("FISA160"):GetStruct():GetFields()
Local nX            := 0
Local cFormulaD     := "0"

Local lUpBase       := .T.
Local lUpAliq       := .T.
Local lUpMaj        := .T.
Local lGrvCIN       := oModel:GetModel("FORMULCAL"):IsFieldUpdated("CIN_FORMUL") .Or. oModel:GetModel("FORMULCAL_ISENTO"):IsFieldUpdated("CIN_FORMUL") .Or. oModel:GetModel("FORMULCAL_OUTROS"):IsFieldUpdated("CIN_FORMUL")

If !lGrvCIN
    // Caso somente o campo de Descrição seja alterado, não serão gerados novos registros das tabela F2B e CIN
    If nOperation == MODEL_OPERATION_UPDATE .And. oModel:GetModel("FISA160"):IsFieldUpdated("F2B_DESC")
        For nX := 1 To Len(aCampos)
            If aCampos[nX,3] <> "F2B_DESC" .And. oModel:GetModel("FISA160"):IsFieldUpdated(aCampos[nX,3])
                lGrvCIN := .T.
                Exit
            EndIf
        Next nX
    Else
        lGrvCIN := .T.
    EndIf
EndIf

If lGrvCIN
    Begin Transaction

        If nOperation == MODEL_OPERATION_INSERT .Or.  nOperation == MODEL_OPERATION_UPDATE

            //Na edição preciso alterar o flag como alterado para manter o histórico de alterações
            If nOperation == MODEL_OPERATION_UPDATE

                lUpBase       := oModel:GetModel("FISA160"):IsFieldUpdated("F2B_RBASE") .Or. oModel:GetModel("FISA160"):IsFieldUpdated("F2B_RBASES")
                lUpAliq       := oModel:GetModel("FISA160"):IsFieldUpdated("F2B_RALIQ")
                lUpMaj        :=  oModel:GetModel("FISA160"):IsFieldUpdated("F2B_TRBMAJ")

                //Chama função para alterar registro atual
                cOldIdReg := GravaF2B(2)   
                
                //Chama função para editar a regra CIN
                If lUpBase
                    GravaCIN("2", "6",, cOldIdReg) //Atualiza registro referente à base de cálculo
                EndIf

                If lUpAliq .OR. lUpMaj
                    GravaCIN("2", "7",, cOldIdReg) //Atualiza registro referente à aliquota
                EndIf
                
                GravaCIN("2", "8",, cOldIdReg) //Atualiza registro referente ao valor
                GravaCIN("2","11",, cOldIdReg)
                GravaCIN("2","12",, cOldIdReg)
                GravaCIN("2","13",, cOldIdReg)
                
            EndIF

            //Agora chamo função para inserir novo registro, seja na operação de inclusão ou edição.
            cIdRegra    := GravaF2B(1, cCodigo, cDescri, cTrib, dDataIni, dDataFin, cBase, cAliq, cOrigDest, cPart, cOper, cProd,;
                                    cFin, cApur, cArred, cBaseSec, cTribMaj, cDedDep, cDedPro, cCodesc, cMaxMin, cCodRGuia, nVlrMax, nVlrMin, cLimMin, cLimMax)
            
            //Chama função para gravar nova linha na CIN
            cFormula    := oModel:GetValue ('FORMULCAL',"CIN_FORMUL")
            cFormulaI   := oModel:GetValue ('FORMULCAL_ISENTO',"CIN_FORMUL")
            cFormulaO   := oModel:GetValue ('FORMULCAL_OUTROS',"CIN_FORMUL")

            If RetPercDif(cCodesc) > 0
                cFormulaD   := xFisTpForm("9") + "PERC_DIFERIMENTO"
            EndIf

            If !lUpBase
                cBase := ""
            EndIf

            If !lUpAliq .and. !lUpMaj
                cAliq := ""
            EndIf

            cAltera     := "0"
            //Grava CIN da base
            
            //Realiza tratamento e gravação da CIN
            PreGrvCIN(cFormula, cBase, cBaseSec, cCodigo, cIdRegra, cDescri, cTribMaj, cAliq, cAltera, cDedDep, cDedPro, cFormulaI, cFormulaO, cMaxMin, cOldIdReg, cFormulaD)
                
        ElseIf nOperation == MODEL_OPERATION_DELETE
            
            //Chama função para excluir a regra CIN antes de excluir a F2B
            GravaCIN("3","6",, F2B->F2B_ID)
            GravaCIN("3","7",, F2B->F2B_ID)
            GravaCIN("3","8",, F2B->F2B_ID)
            GravaCIN("3","11",, F2B->F2B_ID)
            GravaCIN("3","12",, F2B->F2B_ID)    
            GravaCIN("3","13",, F2B->F2B_ID)  
            
            //Faz exclusão do registro
            RecLock("F2B",.F.)
            F2B->(dbDelete())
            MsUnLock()

        EndIF
    End Transaction
Else
    FwFormCommit( oModel )
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaF2B
Função que faz gravação e edição da tabela F2B

@author Rafael S Oliveira
@since 05/02/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function GravaF2B(nOp, cCodigo, cDescri, cTrib, dDataIni, dDataFin, cBase, cAliq, cOrigDest, cPart,;
                         cOper, cProd, cFin, cApur, cArred, cBaseSec, cTribMaj, cDedDep, cDedPro, cCodesc, cMaxMin, cCodRGuia,nVlrMax, nVlrMin, cLimMin, cLimMax)
Local cId       := ""

If nOp == 1 //Incluiu
    RecLock("F2B",.T.)
    F2B->F2B_FILIAL	 := xFilial("F2B")
    F2B->F2B_ID		 := FWUUID("F2B")
    F2B->F2B_REGRA   := cCodigo   // Código Regra
    F2B->F2B_DESC    := cDescri   // Descrição   
    F2B->F2B_TRIB    := cTrib     // Tributo     
    F2B->F2B_VIGINI  := dDataIni  // Data Início 
    F2B->F2B_VIGFIM  := dDataFin  // Data Final  
    F2B->F2B_RBASE   := cBase     // Base Cálculo
    F2B->F2B_RALIQ   := cAliq     // Alíquota    
    F2B->F2B_PEROD   := cOrigDest // Perf.Ori/Des
    F2B->F2B_PERFPA  := cPart     // Perf. Part. 
    F2B->F2B_PERFOP  := cOper     // Perf. Oper. 
    F2B->F2B_PERFPR  := cProd     // Perf. Prod. 
    F2B->F2B_RFIN    := cFin      // Financeira  
    F2B->F2B_RAPUR   := cApur     // Regra Apur. 
    F2B->F2B_RND     := cArred    // Config Arred    
    F2B->F2B_RBASES  := cBaseSec  // Regra de Base secundária
    F2B->F2B_TRBMAJ  := cTribMaj  // Tributo que fará majoração
    F2B->F2B_DEDDEP  := cDedDep  // Tributo que fará majoração    
    F2B->F2B_DEDPRO  := cDedPro  // Tributo que que terá dedução da tabela progressiva
    F2B->F2B_CODESC  := cCodesc  //Código do cadastro de escrituração
    F2B->F2B_MAXMIN  := cMaxMin   // Tratamento para valor maior ou menor entre bases
    F2B->F2B_RGGUIA  := cCodRGuia // Regra para geração da guia de recolhimento
    F2B->F2B_VLRMAX  := nVlrMax // Valor maximo do Tributo
    F2B->F2B_VLRMIN  := nVlrMin // Valor minimo do tributo
    F2B->F2B_OPRMIN  := cLimMin // tipo limite valor minimo
    F2B->F2B_OPRMAX  := cLimMax // tipo limite valor minimo

    F2B->F2B_ALTERA	 := "2"       // Indica que não foi alterado        
    MsUnLock()

ElseIf nOp ==2  //Alteração    
    RecLock("F2B",.F.)
    F2B->F2B_ALTERA := "1"//Indica que sofreu alterações
    F2B->F2B_DTALT  := Date()
    F2B->F2B_HRALT  := Time()
    MsUnLock()

EndIf

Return cId := F2B->F2B_ID

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa160Form
Função que atualiza a fórmula da regra de base de cálculo.
Ao alterar algum operando do modo básico da regra, a fórmula 
será atualizada.

@return - .T.

@author Rafael S Oliveira 
@since 04/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa160Form(cCampo,cFormula,cFormulI,cFormulO)

Local oModel        := FWModelActive()
Local cValBase 		:= oModel:GetValue ('FISA160',"F2B_RBASE")
Local cCodRegra		:= oModel:GetValue ('FISA160',"F2B_REGRA")
Local cValBaseS 	:= ""
Local cTrbMaj   	:= ""
Local cDedDep   	:= ""
Local cDedPro   	:= ""
Local cValAliq 		:= oModel:GetValue ('FISA160',"F2B_RALIQ")
Local cPrefixo      := ""
Local oCabecalho	:= oModel:GetModel("FISA160")
Local cEscrit       := ""

Default cCampo      := ""
Default cFormula    := ""
Default cFormulI    := ""
Default cFormulO    := ""

IF !Empty(cFormula)

    //Primeiro limpa a fórmula
    xForClear("FORMULCAL", .F., "VIEW_FORMULA", .F.)

    //Abrir parentes 
    xForBtnAct(cFormula, "FORMULCAL", .F., "VIEW_FORMULA")

    //Indica que o botão de edição de fórmula ficará habilitado
    lclicked := .T.


Endif

IF !Empty(cFormulI)

    //Primeiro limpa a fórmula
    xForClear("FORMULCAL_ISENTO", .F., "VIEW_FORMULA_ISENTO", .F.)

    //Abrir parentes 
    xForBtnAct(cFormulI, "FORMULCAL_ISENTO", .F., "VIEW_FORMULA_ISENTO")

    //Indica que o botão de edição de fórmula ficará habilitado
    lclicked := .T.

Endif

IF !Empty(cFormulO)

    //Primeiro limpa a fórmula
    xForClear("FORMULCAL_OUTROS", .F., "VIEW_FORMULA_OUTROS", .F.)

    //Abrir parentes 
    xForBtnAct(cFormulO, "FORMULCAL_OUTROS", .F., "VIEW_FORMULA_OUTROS")

    //Indica que o botão de edição de fórmula ficará habilitado
    lclicked := .T.

Endif

If !Empty(cFormula) .Or. !Empty(cFormulI) .Or. !Empty(cFormulO)
    Return .T.
EndIf

If lCIN
    cValBaseS 	:= oModel:GetValue ('FISA160',"F2B_RBASES")
    cTrbMaj     := oModel:GetValue ('FISA160',"F2B_TRBMAJ")
    cDedDep     := oModel:GetValue ('FISA160',"F2B_DEDDEP")
    cDedPro     := oModel:GetValue ('FISA160',"F2B_DEDPRO")
    cMaxMin     := oModel:GetValue ('FISA160','F2B_MAXMIN')
    cEscrit     := oModel:GetValue ('FISA160','F2B_CODESC')
EndIF

//Aqui preciso validar se o código da regra de base e de alíquota existem no cadastro
If !Empty(cCampo)
    
    If cCampo == "F2B_RBASE" .And. !Empty(cValBase)
         //Verifcica cadastro de base
        
        //As bases não podem ser iguais
        If !Empty(cValBaseS) .And. cValBase == cValBaseS
            Return .F.
        EndIf

        DbSelectArea("F27")
        F27->(DbSetOrder(1))
        If !F27->(MsSeek( xFilial("F27") + cValBase + "2"))
            Return .F.
        EndIF        
    ElseIf cCampo == "F2B_RBASES"
        If !Empty(cValBaseS)
            //Verifcica cadastro de base
            //As bases não podem ser iguais
            If !Empty(cValBase) .And. cValBaseS == cValBase
                Return .F.
            EndIf

            DbSelectArea("F27")
            F27->(DbSetOrder(1))
            If !F27->(MsSeek( xFilial("F27") + cValBaseS + "2"))
                Return .F.
            EndIF
        Else
            //Limpa o conteúdo do campo F2B_MAXMIN
            oCabecalho:LoadValue('F2B_MAXMIN', Criavar("F2B_MAXMIN") )
        EndIf

    ElseIf cCampo == "F2B_TRBMAJ" .And. !Empty(cTrbMaj)
        //Verifcica cadastro de base
        //As bases não podem ser iguais
        If !Empty(cCodRegra) .And. cCodRegra == cTrbMaj
            Return .F.
        EndIf       
        
        //seek F2B
        DbSelectArea("F2B")
        F2B->(DbSetOrder(7))
        If !F2B->(MsSeek( xFilial("F2B") + cTrbMaj + "2"))
            Return .F.
        EndIF       
        
    //Validação dependentes
    ElseIf cCampo == "F2B_DEDDEP" .And. !Empty(cDedDep)
        
        DbSelectArea("CIV")
        CIV->(DbSetOrder(4))
        If !CIV->(MsSeek( xFilial("CIV") +cDedDep+"2"))
            Return .F.
        EndIF        

    //Validação tabela progressiva        
    ElseIf cCampo == "F2B_DEDPRO" .And. !Empty(cDedPro)
        
        DbSelectArea("CIQ")
        CIQ->(DbSetOrder(1))
        If !CIQ->(MsSeek( xFilial("CIQ") +cDedPro))
            Return .F.
        EndIF        

    ElseIf cCampo == "F2B_RALIQ" .And. !Empty(cValAliq)
        //Verifcica cadastro de alíquota
        DbSelectArea("F28")
        F28->(DbSetOrder(1))
        If !F28->(MsSeek( xFilial("F28") + cValAliq + "2"))
            Return .F.
        EndIF

     ElseIf cCampo == "F2B_CODESC" .And. !Empty(cEscrit)
        //Verifcica cadastro de Regra Escrituração
        DbSelectArea("CJ2")
        CJ2->(DbSetOrder(1))
        If !CJ2->(MsSeek( xFilial("CJ2") + cEscrit + "2"))
            Return .F.
        EndIF           
    EndIF

EndIf

//Primeiro limpa a fórmula
xForClear("FORMULCAL", .F., "VIEW_FORMULA", .F.)

//Indica que o botão de edição de fórmula ficará habilitado
lclicked := .T.

//Se operador estiver vazio então a fórmula não será montada!
If !Empty(cValBase) .and. !Empty(cValAliq)
    
    //Regra de Diferimento
    If !Empty(cEscrit) .And. RetPercDif(cEscrit) > 0
        xForBtnAct("(", "FORMULCAL", .F., "VIEW_FORMULA") 
    EndIf

    //Abrir parentes
    xForBtnAct("(", "FORMULCAL", .F., "VIEW_FORMULA")

    //Adiciona o operador de origem/início na fórmula
    
    cPrefixo:= xFisTpForm("1") //Base de cálculo
    IF !Empty(cMaxMin) .And. !Empty(cValBases)
        //Se as duas bases estiverem preenchidas, então utilizarei o MAIOR()
        If cMaxMin == "1"
            xForBtnAct( xFisTpForm("10") + "( " + cPrefixo+cValBase + " , " + cPrefixo+cValBases + " )", "FORMULCAL", .F., "VIEW_FORMULA")
        Else
            xForBtnAct( xFisTpForm("14") + "( " + cPrefixo+cValBase + " , " + cPrefixo+cValBases + " )", "FORMULCAL", .F., "VIEW_FORMULA")
        EndIf
    Else        
        //Se somente houver a base de cálculo preenche sem MAIOR
        xForBtnAct(cPrefixo+cValBase, "FORMULCAL", .F., "VIEW_FORMULA")        
    EndIF

    //Adiciona o operador de multiplicação
    xForBtnAct("*", "FORMULCAL", .F., "VIEW_FORMULA")

    If Empty(cTrbMaj)
        //Adiciona o operador de origem/início na fórmula
        cPrefixo:= xFisTpForm("2") //Alíquota
        xForBtnAct(cPrefixo+cValAliq, "FORMULCAL", .F., "VIEW_FORMULA")
    Else
        xForBtnAct("(", "FORMULCAL", .F., "VIEW_FORMULA")
        
        //Adiciona o operador de origem/início na fórmula
        cPrefixo:= xFisTpForm("2") //Alíquota
        xForBtnAct(cPrefixo+cValAliq, "FORMULCAL", .F., "VIEW_FORMULA")

        //Adiciona o operador de multiplicação
        xForBtnAct("+", "FORMULCAL", .F., "VIEW_FORMULA")

        //Adiciona o operador de origem/início na fórmula
        cPrefixo:= xFisTpForm("7") //Alíquota
        xForBtnAct(cPrefixo+cTrbMaj, "FORMULCAL", .F., "VIEW_FORMULA")
    
        //Fecha o parentes
        xForBtnAct(")", "FORMULCAL", .F., "VIEW_FORMULA")

    EndIf
    
    //Fecha o parentes
    xForBtnAct(")", "FORMULCAL", .F., "VIEW_FORMULA")

    //Regra de Diferimento
    If !Empty(cEscrit) .And. RetPercDif(cEscrit) > 0
        xForBtnAct(" * "+xFisTpForm("9") + "PERC_DIFERIMENTO )", "FORMULCAL", .F., "VIEW_FORMULA")
    EndIf

    //Regra de Tabela Progressiva
    If !Empty(cDedPro)
        xForBtnAct(" - ", "FORMULCAL", .F., "VIEW_FORMULA")
        xForBtnAct(xFisTpForm("9") + "DED_TAB_PROGRESSIVA", "FORMULCAL", .F., "VIEW_FORMULA")
    EndIF
EndiF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa160HBtn
Esta função indica se o botão que habilita a edição da fórmula deverá estar
ou não habilitado.

Por padrão em um novo cadastro o botão estará habilitado.

@return bool - Retorna verdadeiro quando não informado base e aliquota

@author Rafael S Oliveira
@since 05/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa160HBtn(cModelo)

If cModelo == "FORMULCAL"
    Return lclicked
EndIf

If cModelo == "FORMULCAL_ISENTO"
    Return lclickedI
EndIf

If cModelo == "FORMULCAL_OUTROS"
    Return lclickedO
EndIf

Return .F.


//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa160HFor
Função que indica se o campo de fórmula deverá ou não estar habilitado,
e ter o seu conteúdo alterado.

@return - bool - Retorna verdadeiro se foi informado base e aliquota

@author Rafael S Oliveira
@since 04/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa160HFor(cModelo)

If cModelo == "FORMULCAL"
    Return !lclicked
EndIf

If cModelo == "FORMULCAL_ISENTO"
    Return !lclickedI
EndIf

If cModelo == "FORMULCAL_OUTROS"
    Return !lclickedO
EndIf

Return !lclicked

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa160AFor
Função executada quando usuário Limpar a formula
Esta ação limpara tambem campos de base e aliuqota na aba direita

@author Rafael S Oliveira
@since 06/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa160AFor(cChamada)
Local oModel    := FWModelActive()
Local oFormul   := oModel:GetModel("FISA160")
Local oView 	:= 	FWViewActive()
Default cChamada:= ""

If Empty(cChamada)
    //Aqui retornarei todos os campos para estado inicial
    oFormul:SetValue('F2B_RBASE', Criavar("F2B_RBASE"))       
    oFormul:SetValue('F2B_RALIQ', Criavar("F2B_RALIQ"))
    If lCIN
        oFormul:SetValue('F2B_RBASES', Criavar("F2B_RBASES"))
        oFormul:SetValue('F2B_MAXMIN', Criavar("F2B_MAXMIN"))
    EndIF
EndIf

//Atualizo a view
oview:Refresh( 'VIEW_ABA')
oview:Refresh( 'VIEW_FORMULA')
oview:Refresh( 'VIEW_REGRA')
oview:Refresh( 'BOTOES')

oview:Refresh( 'VIEW_FORMULA_ISENTO')
oview:Refresh( 'VIEW_REGRA_ISENTO')
oview:Refresh( 'BOTOES_ISENTO')

oview:Refresh( 'VIEW_FORMULA_OUTROS')
oview:Refresh( 'VIEW_REGRA_OUTROS')
oview:Refresh( 'BOTOES_OUTROS')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160F2B
Função executada quando usuário entrada na rotina FISA170
Esta rotina faz carga na tabela CIN conforme as regras definidas 
Esta rotina deve ser executada epenas quando existir regras cadastradas antes da existencia de formulas

@author Rafael S Oliveira
@since 07/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA160F2B()
Local oModel    := nil
Local cCodigo   := ""
Local cDescri   := ""
Local cFormula  := ""
Local cIdRegra  := ""
Local cAlias    := ""
Local cAltera   := ""
Local cBase     := ""
Local cAliq     := ""
Local cBaseSec  := ""
Local cTribMaj  := ""
Local cDedDep   := ""
Local cDedPro   := ""
Local cMaxMin   := ""
Local cFormulaD := "0"
Local cCodesc   := ""
//Realiza pesquisa pela relação da F2B com CIN
cAlias := PesqCIN("F2B")

DbSelectArea(cAlias)

//Caso não encontre diferenças finaliza processo
If ((cAlias)->(Eof()))
    (cAlias)->(dbCloseArea())
    return
Endif

//Model da rotina FISA160
oModel    := FWLoadModel('FISA160')

DbSelectArea("F2B")
F2B->(DbSetOrder(3)) // F2B_FILIAL+F2B_ID

While (!(cAlias)->(Eof()))
    F2B->(DbSetOrder(3)) // F2B_FILIAL+F2B_ID
    If F2B->(MsSeek(xFilial("F2B") + (cAlias)->F2B_ID))

        cAltera   := Iif(F2B->F2B_ALTERA $ ' |2',"0","1")
        cFormulaD := "0"
        
        oModel:Activate()

        cCodigo   := oModel:GetValue ('FISA160',"F2B_REGRA")   // Código Regra
        cDescri   := oModel:GetValue ('FISA160',"F2B_DESC")    // Descrição   
        cIdRegra  := oModel:GetValue ('FISA160','F2B_ID')
        cBase     := oModel:GetValue ('FISA160','F2B_RBASE')
        cAliq     := oModel:GetValue ('FISA160','F2B_RALIQ')

        //Função que atualiza a fórmula da regra de cálculo.
        Fsa160Form()

        cFormula    := oModel:GetValue ('FORMULCAL',"CIN_FORMUL")       

        //Grava CIN da base        
        cBaseSec      := oModel:GetValue ('FISA160',"F2B_RBASES")  // Código da base secundária
        cTribMaj      := oModel:GetValue ('FISA160',"F2B_TRBMAJ")  // Código do tributo que fará majoração
        cDedDep       := oModel:GetValue ('FISA160',"F2B_DEDDEP")  // Regra de depdentes
        cDedPro       := oModel:GetValue ('FISA160',"F2B_DEDPRO")  // Regra de dedução tabela progressiva
        cMaxMin       := oModel:GetValue ('FISA160',"F2B_MAXMIN")  // Tratamento para valor maior ou menor entre bases
        cCodesc       := oModel:GetValue ('FISA160',"F2B_CODESC")  // Código da escrituração   

        If RetPercDif(cCodesc) > 0
            cFormulaD := xFisTpForm("9") + "PERC_DIFERIMENTO"
        EndIf
        
        //Realiza tratamento e gravação da CIN
        PreGrvCIN(cFormula, cBase, cBaseSec, cCodigo, cIdRegra, cDescri, cTribMaj, cAliq, cAltera, cDedDep, cDedPro, xFisTpForm("6")+cCodigo , xFisTpForm("6")+cCodigo, cMaxMin, , cFormulaD)

        oModel:DeActivate()
    Endif
    (cAlias)->(dbSkip())
End

oModel:Destroy()
F2B->(DbCloseArea())
(cAlias)->(dbCloseArea())

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa160Prefix
Função que retorna o prefixo da regra do tributo

@return string com o prefixo da fórmula considerando as regra de base e de
alíqutoa selecionadas

@author Erick Dias
@since 11/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa160Prefix()
Local oModel     := FWModelActive()

//TODO regra de prefixo da fórmula, será muito difícil prever todas variações, pode ter somente pautam somente alíquota, ou os dois.

// //Verifico se a base secundária está preenchida ou não para montar a fórmula da base de cálculo
// If Empty(oModel:GetValue ('FISA160',"F2B_RBASES"))
//     //(B:BASE*A:ALIQ)
//     Return "(" + xFisTpForm("1") + Alltrim(oModel:GetValue ('FISA160',"F2B_RBASE")) + "*" + xFisTpForm("2") + Alltrim(oModel:GetValue ('FISA160',"F2B_RALIQ")) + ")"
// Else
//     //(MAIOR( B:BASE1 , B:BASE2 ) * A:ALIQ)
//     return "(" + xFisTpForm("10") + "(" + xFisTpForm("1") + Alltrim(oModel:GetValue ('FISA160',"F2B_RBASE")) + "," + xFisTpForm("1") + Alltrim(oModel:GetValue ('FISA160',"F2B_RBASES")) + ")*" + xFisTpForm("2") +  Alltrim(oModel:GetValue ('FISA160',"F2B_RALIQ")) + ")"
// EndIF

Return ""

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa160ETrb
Função que verifica se os campos de base e alíquota estão prenchidos.

@return - .T. se os campos está preenchidos.

@author Erick Dias
@since 11/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa160ETrb()

Local oModel        := FWModelActive()
Return !Empty(oModel:GetValue ('FISA160',"F2B_RBASE")) .And. !Empty(oModel:GetValue ('FISA160',"F2B_RALIQ"))


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160Hist
Função que exibirá Browse com o histórico de alteações da rotina

@author Erick Dias
@since 24/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA160Hist()
Local cFiltro   := ""
Local aColunas  := {}

//Adicionando as colunas de Data e horario de alteração, pois o UPDDISTR não altera o X3_BROWSE, por isso estou adicionado a coluna manualmente.
/* Posições dos arrays
1 - Título
2 - Codeblock para carregra a ~informação
3 - Tipo
4 - Alinhamento (1 alinhado a esquera)
5 - Tamanho
6 - Decimal
7 - Indica se permite alteração
*/
AADD(aColunas,{ STR0018, &("{ || IIf(F2B->F2B_ALTERA == '1','" + STR0019 + "','" + STR0020 + "') }"), "C", "", 1, 1, 0, .f.}) //"Status - ALterado - Nõo alterado"
AADD(aColunas,{ STR0016, &("{ || F2B->F2B_DTALT }"), "D", "", 1, 1, 0, .f.}) //"Data de Alteração"
AADD(aColunas,{ STR0017, &("{ || Alltrim(F2B->F2B_HRALT) }"), "C", "", 1, 1, 0, .f.}) //"Horário de Alteração"

//Atribuo o Alias para variavel pública 
c170AlsHist := "F2B"

//Monto o filtro abaixo somente com linhas que foram alteradas e não estão mais vigentes
cFiltro :="F2B_FILIAL == '" + xFilial("F2B") + "'"
cFiltro	+= " .AND. F2B_REGRA == '" + F2B->F2B_REGRA +  "'"

//Utilizo segundo índice para facilitar a visualização
F2B->(DbSetOrder(6))

//Chamo a função auxiliar que montará o Browse com as regras alteradas.
FSA16XHist("F2B", cFiltro, STR0015 , aColunas) //"Histórico de Alterações da Regra de Cálculo de Tributo"

//Retorno o Alias e filtro padrão
c170AlsHist := ""
F2B->(DbSetOrder(1))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFormval

Função auxiliar que monta a fórmula do valor do tributo, subtituindo
os dois primeiros operadores por base e alíquota, mantendo o resto da
fórmula

@param cFormTemp  - Fórmula temporária sem os operadores com sufixo _BAS e _ALQ
@param cTributo   - Tributo a qual este operando pertence

@return -cRet Fórmula substituída

@author Erick Dias
@since 28/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function GetFormval(cFormTemp, cTributo, cTribMaj, cBaseSec, cDedDep, lTribDif)

Local nX		:= 0
Local aFormTemp	:= {}
Local cRet		:= "(" + xFisTpForm("6") + cTributo + " * " + xFisTpForm("7") + cTributo + ")"
Local lMaj      := .F.
Local lMaior    := .F.
Local nXIni     := 0

Default lTribDif:= .F.

//Para facilitar o cálculo irei substituir o primeiro e segundo operandos pelos respectivos códigos de base e aliquota
aFormTemp	:= StrTokArr(alltrim(cFormTemp)," ")

//Caso tenha diferimento é preciso colocar um parenteses, pois será fechado ao longo da fórmula
If lTribDif
    cRet := "(" + cRet
EndIf

If !Empty(cBaseSec)
    //Possui base com operador MAIOR 
    lMaior  := .T.
EndIF

If !Empty(cTribMaj)
    //Possui soma na alíquota para majoração        
    lMaj    := .T.
EndIf

If lMaj .AND. lMaior .And. lTribDif
    nXIni   := 15
ElseIf lMaj .AND. lMaior .And. !lTribDif
    nXIni   := 14    
ElseIf (lMaj .Or. lMaior) .And. lTribDif
    nXIni   := 11
ElseIf lMaj .Or. lMaior
    nXIni   := 10
ElseIf lTribDif 
    nXIni   := 7
Else
    nXIni   := 6
EndIF

//Somente majorada, montar a fórmula : (BAS:TRIBUTO * ALQ:TRIBUTO ) e  o restante da fórmulase houver, após 9 posição
//Somente MAIOR, montar a fórmula : (BAS:TRIBUTO * ALQ:TRIBUTO ) e  o restante da fórmulase houver, após 9 posição
//Se houver MAIOR e majorada, montar a fórmula: (BAS:TRIBUTO * ALQ:TRIBUTO ) e  o restante da fórmulase houver, após 13 posição

For nX := nXIni  to len(aFormTemp)		
	cRet +=  " "
    cRet += Alltrim(aFormTemp[nX])	
Next nX

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PreGrvCIN

Função que trata a gravação das fórmulas da tabela CIN, tanto na gravação 
da regra quando nas cargas automáticas.

@author Erick Dias
@since 10/07/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function PreGrvCIN(cFormula, cBase, cBaseSec, cCodigo, cIdRegra, cDescri, cTribMaj, cAliq, cAltera, cDedDep,; 
                          cDedPro, cFormulaI, cFormulaO, cMaxMin, cOldIdReg, cFormulaD)
Local cTribVal    := ""
Local cFrmTotDif  := ""
Local lDiferido   := .F.

Default cBase     := ""
Default cAliq     := ""
Default cOldIdReg := ""
Default cFormulaD := ""

//Quando possui escrituração na regra mas não possui diferimento o cFormulaD vem com string 0, por isso é diferente de branco e de 0
lDiferido   := !Empty(cFormulaD)  .And. cFormulaD <> "0"

// Caso a formula não tenha sido alterada, indica que os registros de Base, Aliquota e Valor não sofreram qualquer alteração.
If !Empty(cBase)
    //Grava CIN da base
    If !Empty(cBaseSec) .And. !Empty(cMaxMin)
        //Maior
        If cMaxMin == "1"
            GravaCIN("1","6", cCodigo, cIdRegra, "(Base) | "     + cDescri, xFisTpForm("10") + "( " + xFisTpForm("1")  + cBase + " , " + xFisTpForm("1") + cBaseSec + " )" , cAltera)    
        //Menor
        Else
            GravaCIN("1","6", cCodigo, cIdRegra, "(Base) | "     + cDescri, xFisTpForm("14") + "( " + xFisTpForm("1")  + cBase + " , " + xFisTpForm("1") + cBaseSec + " )" , cAltera)    
        EndIf
    Else
        GravaCIN("1","6", cCodigo, cIdRegra, "(Base) | "     + cDescri, xFisTpForm("1") +cBase , cAltera)
    EndIF
ElseIf !Empty(cOldIdReg)
    GravaCIN("2", "6",,cIdRegra,,,,,cOldIdReg)
EndIf

If !Empty(cAliq)
    //Grava CIN da alíquota
    IF Empty(cTribMaj)
        GravaCIN("1","7", cCodigo, cIdRegra, "(Alíquota) | " + cDescri, xFisTpForm("2")+cAliq , cAltera)
    Else            
        GravaCIN("1","7", cCodigo, cIdRegra, "(Alíquota) | " + cDescri, "( "  + xFisTpForm("2")+cAliq + " + " + xFisTpForm("7") + cTribMaj + ")", cAltera)
    EndIF
ElseIf !Empty(cOldIdReg)
    GravaCIN("2", "7",,cIdRegra,,,,,cOldIdReg)
EndIf

If !Empty(cFormula) 
    //Grava CIN do valor        
    GravaCIN("1","8", cCodigo, cIdRegra, "(Valor) | "    + cDescri, GetFormval(cFormula, cCodigo, cTribMaj, cBaseSec, cDedDep, lDiferido),cAltera,cFormula)
ElseIf !Empty(cOldIdReg)
    GravaCIN("2", "8",,cIdRegra,,,,,cOldIdReg)
EndIf

If !Empty(cFormulaI)
    //Grava CIN do valor de Isento
    GravaCIN("1","11", cCodigo, cIdRegra, "(Isento) | "    + cDescri, cFormulaI ,cAltera)
EndIf

If !Empty(cFormulaO)
    //Grava CIN do valor de Outros 
    GravaCIN("1","12", cCodigo, cIdRegra, "(Outros) | "    + cDescri, cFormulaO ,cAltera)
EndIf

//Grava CIN do valor Diferido
//Verifico se o tributo contem diferimento maior que zero.
If lDiferido
    cTribVal    := "(" + GetFormval(cFormula, cCodigo, cTribMaj, cBaseSec, cDedDep, lDiferido) + ")"
    cFrmTotDif  := "(" + cTribVal +" / "+ cFormulaD+ ")" + " - " + cTribVal
    GravaCIN("1","13", cCodigo, cIdRegra, "(Diferido) | "    + cDescri, cFrmTotDif, cAltera)
Else
    GravaCIN("1","13", cCodigo, cIdRegra, "(Diferido) | "    + cDescri, "0", cAltera)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FuncObrig
Função para validar de campos obrigatórios

@author Renato Rezende
@since 14/09/2020
@version P12.1.31
/*/
//-------------------------------------------------------------------
Static Function FuncObrig(oModel)
Local lRet      := .T.
Local cValBaseS := oModel:GetValue ('FISA160',"F2B_RBASES")
Local cMaxMin   := oModel:GetValue ('FISA160','F2B_MAXMIN')

//Campo do maior ou menor preenchido e o campo da base secundária não preenchido
If !Empty(cMaxMin) .And. Empty(cValBaseS)
    lRet:= .F.
    Help( ,, 'Help',, "Campo obrigatório não preenchido: Base de Cálculo Auxiliar (F2B_RBASES)", 1, 0 )

//Campo da base secundária preenchido e o campo de maior ou menor não preenchido
ElseIf !Empty(cValBaseS) .And. Empty(cMaxMin)
    lRet:= .F.
    Help( ,, 'Help',, "Campo obrigatório não preenchido: Valor maior ou menor entre bases (F2B_MAXMIN)", 1, 0 )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160POS
Função auxiliar para tratar o inicializador padrão da descrição do 
do Produto, pois o campo X3_RELACAO é limitado e não cabia 
toda a instrução necessária.

Devido POSICIONE ser na propria tabela sera nescessario retornar a area original

@author Rafael Oliveira
@since 24/09/2020
@version 12.1.31

/*/
//-------------------------------------------------------------------

Function FSA160POS()
Local aArea      := GetArea()
Local cDescr    := ""

If !INCLUI     
    cDescr  := POSICIONE("F2B",7,xFilial("F2B")+F2B->F2B_TRBMAJ+"2","F2B_DESC")
EndIF

//Retorna para registro de Origem da F2B
Restarea(aArea)

Return cDescr

//-------------------------------------------------------------------
/*/{Protheus.doc} AtualizForm
Função responsavel por atualizar a formula quando realizada copia a regra de calculo


@author Rafael Oliveira
@since 24/09/2020
@version 12.1.31

/*/
//-------------------------------------------------------------------
Static Function AtualizForm(oModel)
Local cBase    := ""
Local cBases   := ""
Local cAliq    := ""
Local cTribmj  := ""
Local cDep     := ""
Local cDeppro  := ""
Local cMaxmin  := ""
Local nOperation    := oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT
    cBase    := oModel:GetValue ('FISA160',"F2B_RBASE")   // Base Cálculo
    cBases   := oModel:GetValue ('FISA160',"F2B_RBASES")  // Base Cálculo secundaria
    cAliq    := oModel:GetValue ('FISA160',"F2B_RALIQ")   // Alíquota    
    cTribmj  := oModel:GetValue ('FISA160',"F2B_TRBMAJ")  // Trib Majorado
    cDep     := oModel:GetValue ('FISA160',"F2B_DEDDEP")  // Dependencia
    cDeppro  := oModel:GetValue ('FISA160',"F2B_DEDPRO")  // Dependencia
    cMaxmin  := oModel:GetValue ('FISA160',"F2B_MAXMIN")  // Min e Max

    IF !Empty(Alltrim(cBase))
        Fsa160Form("F2B_RBASE")
    Endif
    IF !Empty(Alltrim(cBases))
        Fsa160Form("F2B_RBASES")
    Endif
    IF !Empty(Alltrim(cAliq))
        Fsa160Form("F2B_RALIQ")
    Endif
    IF !Empty(Alltrim(cTribmj))
        Fsa160Form("F2B_TRBMAJ")
    Endif
    IF !Empty(Alltrim(cDep))
        Fsa160Form("F2B_DEDDEP")
    Endif
    IF !Empty(Alltrim(cDeppro))
        Fsa160Form("F2B_DEDPRO")
    Endif
    IF !Empty(Alltrim(cMaxmin))
        Fsa160Form("F2B_MAXMIN")
    Endif 
Endif
    
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} RetPercDif
Função responsavel por retornar o % de diferimento da escrituração

@author Renato Rezende
@since 29/03/2021
@version 12.1.22
/*/
//-------------------------------------------------------------------
Static Function RetPercDif(cEscrit)
Local nRet := 0

//Verifcica cadastro de Regra Escrituração
If !Empty(cEscrit)

    DbSelectArea("CJ2")
    CJ2->(DbSetOrder(1))
    If CJ2->(MsSeek( xFilial("CJ2") + cEscrit + "2"))
        nRet := CJ2->CJ2_PERDIF
    EndIf

EndIf

Return nRet


/*/{Protheus.doc} FSA160OPR
    Fun~c"ao de filtro da consulta padrão CINOPR
    @type  Function
    @author Erich Buttner
    @since 28/04/2021
    @version version
    @param param, param_type, param_descr
    @return Codigo
    @example
    (examples)
    @see (links_or_references)
    /*/

Function FSA160OPR ()

cRet := "CIN_CODIGO == 'O:VAL_MERCADORIA' .OR. CIN_CODIGO == 'O:VAL_ICMS'
cRet += " .OR. CIN_CODIGO == 'O:FRETE' .OR. CIN_CODIGO == 'O:DESCONTO'
cRet += " .OR. CIN_CODIGO == 'O:SEGURO' .OR. CIN_CODIGO == 'O:DESPESAS'
cRet += " .OR. CIN_CODIGO == 'O:VAL_MANUAL'


Return cRet
