#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA181.CH"
#Include "FWEditPanel.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA181()

Esta rotina tem objetivo de realizar cadastro de regra de Lan�amento

Esta rotina estar� dispon�vel somente na vers�o 12.

@author Bruce Mello	
@since 01/02/2022
@version P12.1.37
/*/
//-------------------------------------------------------------------

Function FISA181()
Local   oBrowse := Nil
Private lObrig  := .F.

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CJ9") .AND. AliasIndic("CJA") 
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CJ9")
    oBrowse:SetDescription(STR0001) //"Cadastro Regra de Ajustes de Lan�amento"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicion�rio desatualizado, verifique as atualiza��es do motor tribut�rio fiscal."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Bruce Mello	
@since 01/02/2022
@version P12.1.37

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA181" )

//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do cadastro de regra de lan�amento
@author Bruce Mello	
@since 01/02/2022
@version P12.1.37

/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel     := Nil
Local oCabecalho := FWFormStruct(1, "CJ9" )
Local oItem      := FWFormStruct(1, "CJA" )

DEFAULT lObrig := .F.

    //Instanciando o modelo
    oModel  := MPFormModel():New('FISA181', ,{|oModel|VALIDACAO(oModel)})

    //Atribuindo cabe�alho para o modelo
    oModel:AddFields("MASTER",,oCabecalho)
    
    //Adiciona Grids
    oModel:AddGrid("GRID","MASTER",oItem)
    

    //==================================Propriedades dos campos=============================================

    //N�o permite alterar codigo quando altera��o
    oCabecalho:SetProperty('CJ9_CODREG' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation() == 3) })

    //Valida��o para n�o permitir informar um c�digo da regra que j� exista no sistema (legado)
    oCabecalho:SetProperty('CJ9_CODREG' , MODEL_FIELD_VALID, {||( VldCodigo(oModel) )})	
    
    //Valida��o para limpar campo CJA_CODLAN quando alterar o conteudo do campo CJA_CODTAB
    oItem:SetProperty('CJA_CODTAB' , MODEL_FIELD_VALID , {|| (Fsa181MCpo("CJA_CODLAN"))    })

    //Valida��o para limpar campo CJA_VALOR quando alterar o conteudo do campo CJA_REGCAL
    oItem:SetProperty('CJA_REGCAL' , MODEL_FIELD_VALID , {|| (Fsa181M2Cpo("CJA_VALOR"))    })

      //Valida��o para limpar campo CJA_VLOUTR quando alterar o conteudo do campo CJA_REGCAL
    oItem:SetProperty('CJA_REGCAL' , MODEL_FIELD_VALID , {|| (Fsa181M2Cpo("CJA_VLOUTR"))    })

    // Valida��o para n�o permitir adicionar conteudo diferente da consulta padr�o.
    oItem:SetProperty('CJA_GUIA' , MODEL_FIELD_VALID, {||Vazio() .Or. existcpo("CJ4") })
    oItem:SetProperty('CJA_TITULO' , MODEL_FIELD_VALID, {||Vazio() .Or. existcpo("FKK") })

    //Valida��o dos campos de mensagem
    oItem:SetProperty('CJA_CODCPL' , MODEL_FIELD_VALID, {||Vazio() .Or. ExistCpo("CJ8",FwFldGet("CJA_CODCPL"),1)})
    oItem:SetProperty('CJA_CODMSG' , MODEL_FIELD_VALID, {||Vazio() .Or. ExistCpo("CJ8",FwFldGet("CJA_CODMSG"),1)})
    oItem:SetProperty('CJA_TXTDSC' , MODEL_FIELD_VALID, {||Vazio() .Or. ExistCpo("CJ8",FwFldGet("CJA_TXTDSC"),1)})

    //==================================Defini��es do modelo ================================================

    //PrimaryKey
    oModel:SetPrimaryKey( {"CJ9_CODREG","CJ9_ID"} )

    //oModel:SetRelation("GRID",{{ 'CJA_FILIAL' , 'xFilial("CJA")' }, { 'CJA_CODREG','CJ9_CODREG'} /*, { 'CJA_ID_CAB','CJ9_ID'}*/},CJA->(IndexKey(1)))   
    oModel:SetRelation("GRID",{{ 'CJA_FILIAL' , 'xFilial("CJA")' }, { 'CJA_CODREG','CJ9_CODREG'} , { 'CJA_ID_CAB','CJ9_ID'}},CJA->(IndexKey(1)))            

    //Adicionando descri��o ao modelo
    oModel:SetDescription(STR0001) //"Cadastro da regra de Ajuste de Lan�amento"

    // Controle de campo obrigatorio. T - obrigaotorio F . n�o obrigatorio
    oItem:SetProperty( 'CJA_CODTAB'   , MODEL_FIELD_OBRIGAT,  .T. ) 
    oItem:SetProperty( 'CJA_CODLAN'   , MODEL_FIELD_OBRIGAT,  .T. ) 
    oItem:SetProperty( 'CJA_VIGINI'   , MODEL_FIELD_OBRIGAT,  .T. ) 
    oItem:SetProperty( 'CJA_VIGFIM'   , MODEL_FIELD_OBRIGAT,  .F. ) 
    oItem:SetProperty( 'CJA_REGCAL'   , MODEL_FIELD_OBRIGAT,  .T. ) 
    oItem:SetProperty( 'CJA_GUIA'     , MODEL_FIELD_OBRIGAT,  .F. ) 
    oItem:SetProperty( 'CJA_TITULO'   , MODEL_FIELD_OBRIGAT,  .F. ) 
    oItem:SetProperty( 'CJA_TITGUI'   , MODEL_FIELD_OBRIGAT,  .F. ) 
    oItem:SetProperty( 'CJA_GERMSG'   , MODEL_FIELD_OBRIGAT,  .F. ) 
    oItem:SetProperty( 'CJA_OPER'     , MODEL_FIELD_OBRIGAT,  .F. ) 
    oItem:SetProperty( 'CJA_NFBASE'   , MODEL_FIELD_OBRIGAT,  .T. ) 
    oItem:SetProperty( 'CJA_NFALIQ'   , MODEL_FIELD_OBRIGAT,  .T. ) 
    oItem:SetProperty( 'CJA_VALOR'    , MODEL_FIELD_OBRIGAT,  .F. ) 
    oItem:SetProperty( 'CJA_VLOUTR'   , MODEL_FIELD_OBRIGAT,  .F. ) 
        
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Bruce Mello	
@since 01/02/2022
@version P12.1.37

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel        := FWLoadModel("FISA181")
Local oView         := Nil
Local oCabecalho    := FWFormStruct(2, "CJ9" )
Local cCmpFolder    := ''
Local o181Lanc      := Nil
Local o181Msg       := Nil
Local o181Valr      := Nil
Local cCmpRelac     := ""

//Local oItens        := FWFormStruct(2, "CJA" )

//Criando a View
oView := FWFormView():New()
oView:SetModel(oModel)

//Campos para a Aba de Codigo Lan�amento:
cCmpFolder	:=	cCmpRelac + "CJA_CODTAB|CJA_CODLAN|CJA_VIGINI|CJA_VIGFIM|CJA_REGCAL|CJA_GUIA|CJA_TITULO|CJA_TITGUI|CJA_GERMSG|CJA_OPER|CJA_CNTRL|"
//cCmpFolder	:=	cCmpRelac + "CJA_CODTAB|CJA_CODLAN|CJA_VIGINI|CJA_VIGFIM|CJA_REGCAL|CJA_GUIA|CJA_TITULO|CJA_GERMSG|"0
o181Lanc	:=	FwFormStruct( 2, 'CJA', {|x| AllTrim( x ) + "|" $ cCmpFolder } )

//Campos para a Aba de Pauta:
cCmpFolder	:=	cCmpRelac + "CJA_CODLAN|CJA_NFBASE|CJA_NFALIQ|CJA_VALOR|CJA_VLOUTR|"
o181Valr	:=	FwFormStruct( 2, 'CJA', {|x| AllTrim( x ) + "|" $ cCmpFolder } )   

//Campos para a Aba de Mensagem:
cCmpFolder	:=	cCmpRelac + "CJA_CODLAN|CJA_CODMSG|CJA_CODCPL|CJA_TXTDSC|"
o181Msg		:=	FwFormStruct( 2, 'CJA', {|x| AllTrim( x ) + "|" $ cCmpFolder } )

//Atribuindo formul�rios para interface
// Por ser 3 abas estamos dividindo no GRID em 3 view
oView:AddField('VIEW_CAB'        ,oCabecalho     , 'MASTER')
oView:AddGrid( 'VIEW_LANC'       ,o181Lanc       , 'GRID'  )
oView:AddGrid( 'VIEW_VLR'        ,o181Valr       , 'GRID'  )
oView:AddGrid( 'VIEW_MSG'        ,o181Msg        , 'GRID'  )


oView:SetViewProperty( 'VIEW_LANC', "CHANGELINE", {{ |oView | ChangeLine(oView, oModel) }} )
oView:SetViewProperty( 'VIEW_VLR' , "CHANGELINE", {{ |oView | ChangeLine(oView, oModel) }} )
oView:SetViewProperty( 'VIEW_MSG' , "CHANGELINE", {{ |oView | ChangeLine(oView, oModel) }} )


//Habilitando op��es de filtros 
oView:SetViewProperty('VIEW_LANC', "GRIDFILTER" , {.T.})
oView:SetViewProperty('VIEW_LANC', "GRIDSEEK"   , {.T.})

oView:SetViewProperty('VIEW_MSG', "GRIDFILTER" , {.T.})
oView:SetViewProperty('VIEW_MSG', "GRIDSEEK"   , {.T.})

oView:SetViewProperty('VIEW_VLR', "GRIDFILTER" , {.T.})
oView:SetViewProperty('VIEW_VLR', "GRIDSEEK"   , {.T.})

//Retira os campos da View
oCabecalho:RemoveField('CJ9_ID')

//Cria tr�s box
oView:CreateHorizontalBox( 'SUPERIOR'   , 20 )
//oView:CreateHorizontalBox( 'MEIO'       , 19 )
oView:CreateHorizontalBox( 'INFERIOR'   , 80 )

//Cria o Folder Principal
oView:CreateFolder( 'Folder_CJA', 'INFERIOR' )

//Cria as Abas Principais
oView:AddSheet( 'Folder_CJA', 'ABA_LANC', "Lan�amentos" ) //"Lan�amentos"
oView:AddSheet( 'Folder_CJA', 'ABA_VLR'	, "Valores" ) //"Valores"
oView:AddSheet( 'Folder_CJA', 'ABA_MSG'	, "Mensagens" ) //"Mensagens"


//Cria box da aba de Principais
oView:CreateHorizontalBox( 'PAINEL_LANC' , 100,,, 'Folder_CJA', 'ABA_LANC'     )
oView:CreateHorizontalBox( 'PAINEL_VLR'  , 100,,, 'Folder_CJA', 'ABA_VLR'      )
oView:CreateHorizontalBox( 'PAINEL_MSG'  , 100,,, 'Folder_CJA', 'ABA_MSG'      )

//Faz v�nculo do box com a view
oView:SetOwnerView( 'VIEW_CAB'  , 'SUPERIOR'    )
oView:SetOwnerView( 'VIEW_LANC' , 'PAINEL_LANC'     )
oView:SetOwnerView( 'VIEW_VLR'  , 'PAINEL_VLR'      )
oView:SetOwnerView( 'VIEW_MSG'  , 'PAINEL_MSG'      )


//Colocando t�tulo do formul�rio
oView:EnableTitleView('VIEW_CAB'  , "Cadastro Regra de Ajuste Lan�amento" ) //'NCM'
oView:EnableTitleView('VIEW_LANC' , "Codigos de Lan�amento" ) //'Tributos'
oView:EnableTitleView('VIEW_VLR'  , "Inf. Valores dos Lan�amentos" ) //'Valores Auxiliares por Tributos( MVA )'
oView:EnableTitleView('VIEW_MSG'  , "Cadastro de Mensagem" ) //'Valores Auxiliares por Tributos( MVA )'



//Aqui � a defini��o de exibir dois campos por linha
oView:SetViewProperty( "VIEW_CAB", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

//Altera titulo CJ9 - Cabe�alho da Regra
oCabecalho:SetProperty("CJ9_CODREG", MVC_VIEW_TITULO, "C�digo da Regra de Ajuste")
oCabecalho:SetProperty("CJ9_DESCR", MVC_VIEW_TITULO, "Descri��o da Regra de Ajuste de Lan�amento")
oCabecalho:SetProperty("CJ9_VIGINI", MVC_VIEW_TITULO, "Data Inicio da Vigencia da Regra")
oCabecalho:SetProperty("CJ9_VIGFIM", MVC_VIEW_TITULO, "Data Fim da Vigencia da Regra")


//Altera titulo CJA - Itens do Cadastro de Regra de Lan�amento
o181Lanc:SetProperty("CJA_REGCAL", MVC_VIEW_TITULO, "Regra Tribut�ria")
o181Lanc:SetProperty("CJA_CODTAB", MVC_VIEW_TITULO, "Tabela de Lan�amento")
o181Lanc:SetProperty("CJA_CODLAN", MVC_VIEW_TITULO, "C�digo de Lan�amento")
o181Lanc:SetProperty("CJA_VIGINI", MVC_VIEW_TITULO, "In�cio Vig�ncia Lan�amento")
o181Lanc:SetProperty("CJA_VIGFIM", MVC_VIEW_TITULO, "Fim Vig�ncia Lan�amento")
o181Lanc:SetProperty("CJA_GUIA"  , MVC_VIEW_TITULO, "Gera Guia")
o181Lanc:SetProperty("CJA_TITULO", MVC_VIEW_TITULO, "Gera Titulo")
o181Lanc:SetProperty("CJA_TITGUI", MVC_VIEW_TITULO, "Modo Agrp. Guia e Titulo")
o181Lanc:SetProperty("CJA_GERMSG", MVC_VIEW_TITULO, "Tipo de Mensagem")
o181Lanc:SetProperty("CJA_OPER"  , MVC_VIEW_TITULO, "Opera��o") 
o181Lanc:SetProperty("CJA_CNTRL" , MVC_VIEW_TITULO, "UF da Opera��o")

o181Valr:SetProperty("CJA_CODLAN", MVC_VIEW_TITULO, "C�digo de Lan�amento")
o181Valr:SetProperty("CJA_NFBASE", MVC_VIEW_TITULO, "Imprime Base")
o181Valr:SetProperty("CJA_NFALIQ", MVC_VIEW_TITULO, "Imprime Aliquota")
o181Valr:SetProperty("CJA_VALOR" , MVC_VIEW_TITULO, "Considera Valor")
o181Valr:SetProperty("CJA_VLOUTR", MVC_VIEW_TITULO, "Considera Valor Outros")

o181Msg:SetProperty("CJA_CODLAN", MVC_VIEW_TITULO, "C�digo de Lan�amento")
o181Msg:SetProperty("CJA_CODMSG", MVC_VIEW_TITULO, "C�d Msg. Lan�amento")
o181Msg:SetProperty("CJA_CODCPL", MVC_VIEW_TITULO, "C�d Msg.de Complemento")
o181Msg:SetProperty("CJA_TXTDSC", MVC_VIEW_TITULO, "C�d Msg Descri��o")

//Ordem dos campos para realizarem filtros nas f�rmulas
o181Lanc:SetProperty("CJA_CODTAB" , MVC_VIEW_ORDEM, "01")
o181Lanc:SetProperty("CJA_CODLAN" , MVC_VIEW_ORDEM, "02")
o181Lanc:SetProperty("CJA_VIGINI" , MVC_VIEW_ORDEM, "03")
o181Lanc:SetProperty("CJA_VIGFIM" , MVC_VIEW_ORDEM, "04")
o181Lanc:SetProperty("CJA_REGCAL" , MVC_VIEW_ORDEM, "05")
o181Lanc:SetProperty("CJA_GUIA"   , MVC_VIEW_ORDEM, "06")
o181Lanc:SetProperty("CJA_TITULO" , MVC_VIEW_ORDEM, "07")
o181Lanc:SetProperty("CJA_TITGUI" , MVC_VIEW_ORDEM, "08")
o181Lanc:SetProperty("CJA_GERMSG" , MVC_VIEW_ORDEM, "09")
o181Lanc:SetProperty("CJA_OPER"   , MVC_VIEW_ORDEM, "10")
o181Lanc:SetProperty("CJA_CNTRL"  , MVC_VIEW_ORDEM, "11")

//
o181Valr:SetProperty("CJA_CODLAN",  MVC_VIEW_ORDEM, "01")
o181Valr:SetProperty("CJA_NFBASE" , MVC_VIEW_ORDEM, "02")
o181Valr:SetProperty("CJA_NFALIQ" , MVC_VIEW_ORDEM, "03")
o181Valr:SetProperty("CJA_VALOR"  , MVC_VIEW_ORDEM, "04")
o181Valr:SetProperty("CJA_VLOUTR" , MVC_VIEW_ORDEM, "05")

o181Msg:SetProperty("CJA_CODLAN",  MVC_VIEW_ORDEM, "01")
o181Msg:SetProperty("CJA_CODCPL" , MVC_VIEW_ORDEM, "02")
o181Msg:SetProperty("CJA_CODMSG" , MVC_VIEW_ORDEM, "03")
o181Msg:SetProperty("CJA_TXTDSC" , MVC_VIEW_ORDEM, "04")

//Altero a consulta padr�o do campo
o181Lanc:SetProperty("CJA_CODLAN",MVC_VIEW_LOOKUP,{ || X181ChgF3(oModel) })

//Desabilitando op��o de ordena��o
oView:SetViewProperty("*", "ENABLENEWGRID")
oView:SetViewProperty( "*", "GRIDNOORDER" )

oView:SetFieldAction('CJA_CODLAN' , {|oView| AtuGrid(oView,oModel) })
oView:SetFieldAction('CJA_REGCAL' , {|oView| AtuGrid(oView,oModel) })
oView:SetFieldAction('CJA_VLOUTR' , {|oView| AtuGrid(oView,oModel) })
oView:SetFieldAction('CJA_VALOR'  , {|oView| AtuGrid(oView,oModel) })
oView:SetFieldAction('CJA_CODMSG' , {|oView| AtuGrid(oView,oModel) })
oView:SetFieldAction('CJA_CODCPL' , {|oView| AtuGrid(oView,oModel) })
oView:SetFieldAction('CJA_TXTDSC' , {|oView| AtuGrid(oView,oModel) })  

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDACAO
Fun��o que realiza as valida��es do modelo
@param		oModel	    - Objeto  -  Objeto do modelo FISA18
@Return     lRet       - Booleano - REtorno com valida��o, .T. pode gravar, .F. n�o poder� gravar.

   @author Bruce Mello	
    @since 01/02/2022
    version P12.1.37

/*/
//-------------------------------------------------------------------
Static Function VALIDACAO(oModel)

Local lRet          := .T.
Local cRegra        := oModel:GetValue ('MASTER',"CJ9_CODREG" ) 
Local dDtIni        := oModel:GetValue ('MASTER',"CJ9_VIGINI" )
Local dDtFim        := oModel:GetValue ('MASTER',"CJ9_VIGFIM" )
lOCAL cID           := oModel:GetValue ('MASTER',"CJ9_ID" )
Local nOperation 	:= oModel:GetOperation()
Local lAtualiza     := nOperation == MODEL_OPERATION_UPDATE
Local lInclui       := nOperation == MODEL_OPERATION_INSERT


//Verifica se j� existe regra com mesmo c�digo e mesma vig�ncia j� gravados
IF lInclui .OR. lAtualiza

    IF VigIniFIm(cRegra, dDtIni, dDtFim, lAtualiza, cID)
        lRet:= .F.
        Help( ,, 'Help',, STR0003 , 1, 0 ) //'Regra j� cadastrada para a vig�ncia informada'
    EndIF

Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VigIniFIm
Fun��o que verifica se data inicial e data final j� existem no cadastro de regras

@param     cRegra      - String - Sigla da Regra
@param     dDtIni      - Date - Data inicial de vig�ncia
@param     dDtFim      - Date - Data final de vig�ncia
@param     lEdit       - Booleano - indica se � uma opera��o de edi��o

@return    lRet        - Booleano - Indica se encontrou a regra com data final de vig�ncia vazio 
   @author Bruce Mello	
    @since 01/02/2022
    version P12.1.37
/*/
//-------------------------------------------------------------------
Static Function VigIniFIm(cRegra, dDtIni, dDtFim, lEdit,cIdCJ9)

Local lRet      := .F.
Local cSelect	:= ""
Local cFrom	    := ""
Local cWhere	:= ""
Local cAliasQry	:= ""

//Query filtrando filial e regra
cSelect := "CJ9.CJ9_CODREG"
cFrom   += RetSQLName("CJ9") + " CJ9 "
cWhere  += "CJ9.CJ9_FILIAL = " + ValToSQL(xFilial("CJ9")) + " AND "
cWhere  += "CJ9.CJ9_CODREG = " + ValToSQL(cRegra) + " AND "
 

cWhere  += "( "

//Verifica se est� compreendido em cadastro somente com data inicial preenchida
cWhere  += "( " + ValToSQL(dDtIni) + " >= CJ9.CJ9_VIGINI  AND CJ9.CJ9_VIGFIM = ' ' ) OR"
//Verifica se a data inicial est� compreenchida em algum cadastro como data inicial e final informados
cWhere  += "( " + ValToSQL(dDtIni) + " >= CJ9.CJ9_VIGINI  AND " + ValToSQL(dDtIni) + " <= CJ9.CJ9_VIGFIM ) "

//Tratamento para data final
IF Empty(dDtFim)
    //Se no cadastro n�o foi informado a data final, ent�o verificar� se j� existe no cadastro alguma linha sem data final preenchida
    cWhere  += " OR ( CJ9.CJ9_VIGFIM = ' ' ) "
ElseIf !Empty(dDtFim)
    //Caso a data final seja informada ent�o verificaremos se est�comprendida em algum cadastro com data inicial e final preenchidos.
    cWhere  += " OR ( " + ValToSQL(dDtFim) + " >= CJ9.CJ9_VIGINI  AND " + ValToSQL(dDtFim) + " <= CJ9.CJ9_VIGFIM ) "
    cWhere  += " OR ( " + ValToSQL(dDtFim) + " >= CJ9.CJ9_VIGINI  AND CJ9.CJ9_VIGFIM = ' ') "
EndIF

cWhere  += " ) AND " 

If lEdit
    //Se for edi��o desconsiderarei a linha editada, para n�o entrar em conflito com ela mesma
    //Como temos consulta padr�o da CJ9, ela acaba desposicionando o tributo, e por este motivo antes de gravar eu retorno a CJ9 originalmente clicada no browse para edi��o
    DbSelectArea("CJ9")
    CJ9->(DbSetOrder(1))
    If CJ9->(MsSeek( xFilial("CJ9") + cIdCJ9 ))
        cWhere  += " CJ9.R_E_C_N_O_ <> " + ValtoSql(CJ9->(recno())) + " AND "    
    EndIF    
EndIF

cWhere  += "CJ9.D_E_L_E_T_ = ' '"		
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
    //j� existe regra cadastrada para esta vig�ncia
    lRet    := .T.
EndIF

dbSelectArea(cAliasQry)
dbCloseArea()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCodigo
Valida��o do c�digo da regra

   @author Bruce Mello	
    @since 01/02/2022
    version P12.1.37
/*/
//-------------------------------------------------------------------
Static Function VldCodigo(oModel)

Local cCodigo     := oModel:GetValue ('MASTER', "CJ9_CODREG")
Local lRet          := .T.

//Verifico se o perfil j� existe.
//Procura se j� existe regra de al�quota com o mesmo c�digo e ativa
CJ9->(DbSetOrder(2))

If CJ9->( MsSeek ( xFilial('CJ9') + cCodigo  ) )
    Help( ,, 'Help',, STR0007, 1, 0 ) 
    return .F.
EndIF

//N�o pode digitar operadores e () no c�digo
If "*" $ cCodigo .Or. ;
   "/" $ cCodigo .Or. ;
   "-" $ cCodigo .Or. ;
   "+" $ cCodigo .Or. ;
   "(" $ cCodigo .Or. ;
   ")" $ cCodigo
    Help( ,, 'Help',, STR0004    + STR0006, 1, 0 ) //"C�digo n�o pode conter os caracteres."
    return .F.
EndIF

IF " " $ Alltrim(cCodigo)
    Help( ,, 'Help',, STR0005, 1, 0 ) //C�digo n�o pode conter espa�o.
    Return .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XTabelaLanc
Fun��o para Retornar conteudo para combo do campo CJA_CODTAB

@author Bruce Mello
@since 18/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function XTabelaLanc()                                                                                                              
Local cRet := ""

    cRet+="01=Tabela 5.1.1;"
    cRet+="02=Tabela 5.2;"
    cRet+="03=Tabela 5.3;"
    cRet+="04=Tabela IPI 4.5.4"
    
RETURN cRet     

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA181Cpo
Fun��o para alterar a consulta padr�o do tributo.

@author Bruce Egnor  
@since 03/02/2022
@version P12.1.37

/*/
//-------------------------------------------------------------------
Static Function X181ChgF3(oModel)

Local cTbLan	:= Alltrim(oModel:GetValue ('GRID',"CJA_CODTAB"))
Local cRet      := ""

//Verifico o Tipo do Participante para Setar a consulta de Campo.
If cTbLan == '01'
    cRet    := "CDO"
ElseIf cTbLan == '02'
    cRet    := "CDY"
ElseIf cTbLan == '03'
    cRet    := "CC6"
ElseIf cTbLan == '04'
    cRet    := "AJCCK"
Endif
Return cRet

//-------------------------------------------------------------------
//-------------------------------------------------------------------
Static Function AtuGrid(oView,oModel)

//Atualizo a view
oview:Refresh( 'VIEW_LANC')
oview:Refresh( 'VIEW_VLR')
oview:Refresh( 'VIEW_MSG')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xRegCal181
Fun��o auxiliar que retorna o tributo selecionado pelo usu�rio
para poder filtrar a consulta das regras

@author Bruce Mello
@since 16/02/2022
@version P12.1.37
/*/
//-------------------------------------------------------------------
Function xRegCal181()
Local oModel      := FWModelActive()
Local cCalReg	:= Alltrim(oModel:GetValue ('GRID',"CJA_REGCAL"))

Return cCalReg

//-------------------------------------------------------------------
/*/{Protheus.doc} X178TPREG
Fun��o para Retornar conteudo para combo do campo CJA_GERMSG

@author Bruce Mello
@since 17/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function CboxTpMsg()
Local cRet := ""

    cRet := '01=C�d. Lanc. Periodo;02=C�d. Lanc por Nota;03=C�d. Lanc por Item'                                                                                                                                                              
RETURN cRet     

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa181MCpo
Fun��o que valida os campos, quando alterar o conteudo do CJA_CODTAB, limpar os campos
De CODLAN,e Data de Vigencia.

@author Bruce Mello  
@since 22/02/2022
@version P12.1.37

/*/
//-------------------------------------------------------------------
Function Fsa181MCpo(cCampo)

Local oModel        := FWModelActive()
Local oItens	    := oModel:GetModel("GRID")

If !Empty(cCampo)
     //grupo de regras de titulos
      oItens:LoadValue('CJA_CODLAN' , Criavar("CJA_CODLAN") )
      oItens:LoadValue('CJA_VIGINI' , Criavar("CJA_VIGINI") )
      oItens:LoadValue('CJA_VIGFIM' , Criavar("CJA_VIGFIM") )
EndIf

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} ChangeLine()
Propriedade da View executada na mudan�a de linhas dos grids.
@author  Bruce Mello
@since   23/02/2022
@version 12.1.37
/*/
//-----------------------------------------------------------------------

Static Function ChangeLine(oView, oModel)

Local nLnAtual      := 0
Local oGrid         := nil

oGrid := oModel:GetModel("GRID")
nLnAtual:= oGrid:Getline()

//Restauro a linha inicial do grid antes de sa�r da fun��o
oGrid:GoLine(nLnAtual)

oView:Refresh( 'VIEW_LANC')
oView:Refresh( 'VIEW_VLR')
oView:Refresh( 'VIEW_MSG')

Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa181M2Cpo
Fun��o que valida os campos, quando alterar o conteudo do CJA_REGCAL, limpar os campos
De CJA_VALOR e CJA_VLOUTR.

@author Bruce Mello  
@since 22/02/2022
@version P12.1.37

/*/
//-------------------------------------------------------------------
Function Fsa181M2Cpo(cCampo)

Local oModel        := FWModelActive()
Local oItens	    := oModel:GetModel("GRID")

If !Empty(cCampo)
     //grupo de regras de titulos
      oItens:LoadValue('CJA_VALOR' , Criavar("CJA_VALOR") )
      oItens:LoadValue('CJA_VLOUTR' , Criavar("CJA_VLOUTR") )
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CboxCntrl
Fun��o para Retornar conteudo para combo do campo CJA_OPER
fisa
@author Adilson Roberto
@since 06/05/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function CboxOper()
Local cRet := ""

cRet :=  '01=Entrada;02=Sa�da;03=Devolu��o;'

RETURN cRet  

//-------------------------------------------------------------------
/*/{Protheus.doc} CboxCntrl
Fun��o para Retornar conteudo para combo do campo CJA_CNTRL   

@author Adilson Roberto
@since 16/05/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function CboxUF()

Local cRet := ""

cRet := '01=UF Origem;02=UF Destino;'

RETURN cRet  
//-------------------------------------------------------------------


