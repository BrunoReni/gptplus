#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA160I.CH"
#Include "FWEditPanel.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA160I()

Esta rotina tem objetivo de realizar cadastro de classifica��o fiscal

Esta rotina estar� dispon�vel somente na vers�o 12.

@author Rafael Oliveira
@since 29/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Function FISA160I()
Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CJ0") .AND. AliasIndic("CJ1") 
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CJ0")
    oBrowse:SetDescription(STR0001) //"C�digo de situa��o tribut�ria"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicion�rio desatualizado, verifique as atualiza��es do motor tribut�rio fiscal."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Rafael Oliveira
@since 29/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA160I" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do cadastro de classifica��o fiscal

@author Rafael Oliveira
@since 29/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel      := Nil
Local oCabecalho  := FWFormStruct(1, "CJ0" )
Local oItens      := FWFormStruct(1, "CJ1" )
Local aRelCJ1     := {}

    //Instanciando o modelo
    oModel	:=	MPFormModel():New('FISA160I', , {|oModel|VALIDACAO(oModel) .AND. PosProces(oModel)} )

    //Atribuindo cabe�alho para o modelo
    oModel:AddFields("FISA160I",,oCabecalho)

    //Adicionando o grid das varia��es do tributo
    oModel:AddGrid( 'FISA160ICST','FISA160I',oItens)

    //==================================Propriedades dos campos=============================================

    //N�o permite alterar codigo quando altera��o
    oCabecalho:SetProperty('CJ0_CODIGO' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation() == MODEL_OPERATION_INSERT) })

    //Valida��o para n�o permitir informar um c�digo da regra que j� exista no sistema (legado)
    oCabecalho:SetProperty('CJ0_CODIGO' , MODEL_FIELD_VALID, {||( VldCodigo(oModel) )})	

      

    //==================================Defini��es do modelo ================================================


    //PrimaryKey
    oModel:SetPrimaryKey( {"CJ0_CODIGO","CJ0_ID"} )

    //Define o valor maximo de linhas do grid
    oModel:GetModel('FISA160ICST'):SetMaxLine(9999)

    //Define para n�o repetir o CST
    oModel:GetModel( 'FISA160ICST' ):SetUniqueLine( { 'CJ1_CST' } ) 

    //Grid n�o pode ser vazio
    oModel:GetModel('FISA160ICST'):SetOptional(.F.)

    //Adicionando descri��o ao modelo
    oModel:SetDescription(STR0003) //"Cadastro de c�digo de situa��o tribut�ria"

    //Relacionamento das tabelas.
    aAdd(aRelCJ1 ,{ "CJ1_FILIAL"	,"xFilial('CJ1')"} )
    aAdd(aRelCJ1 ,{ "CJ1_ID_CAB"	,"CJ0_ID"        } )
    aAdd(aRelCJ1 ,{ "CJ1_CODCAB"	,"CJ0_CODIGO"        } )
    oModel:SetRelation("FISA160ICST"	, aRelCJ1	, CJ1->( IndexKey(2) ))

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Rafael Oliveira
@since 30/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel    := FWLoadModel( "FISA160I" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oCabecalho   := FWFormStruct(2, "CJ0" )
Local oItens   := FWFormStruct(2, "CJ1" )
Local oView  := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formul�rios para interface
oView:AddField('VIEW_CAB' ,oCabecalho, 'FISA160I')
oView:AddGrid( 'VIEW_ITEM',oItens, 'FISA160ICST')

//Habilitando op��es de filtros 
oView:SetViewProperty('VIEW_ITEM', "GRIDFILTER" , {.T.})
oView:SetViewProperty('VIEW_ITEM', "GRIDSEEK"   , {.T.})

//Retira os campos da View
oCabecalho:RemoveField('CJ0_ID')

//Retira os campos da View
oItens:RemoveField('CJ1_ID')
oItens:RemoveField('CJ1_ID_CAB')
oItens:RemoveField('CJ1_CODCAB')


//Aqui � a defini��o de exibir dois campos por linha
oView:SetViewProperty( "VIEW_CAB", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

//Altera titulo
oCabecalho:SetProperty("CJ0_DESCTR", MVC_VIEW_TITULO, "Descri��o do Tributo")


//Cria box
//oView:CreateHorizontalBox( 'SUPERIOR'   , 250 , /*cIdOwner*/, .T./*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
//oView:CreateHorizontalBox( 'INFERIOR'   , 600 , /*cIdOwner*/, .T./*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )

oView:CreateHorizontalBox( 'SUPERIOR'   , 35 , /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
oView:CreateHorizontalBox( 'INFERIOR'   , 65 , /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )



//Faz v�nculo do box com a view
oView:SetOwnerView( 'VIEW_CAB'      , 'SUPERIOR'    )
oView:SetOwnerView( 'VIEW_ITEM'     , 'INFERIOR'    )

//Colocando t�tulo do formul�rio
oView:EnableTitleView('VIEW_CAB'    , STR0001) //"Cadastro de c�digo de situa��o tribut�ria"
oView:EnableTitleView('VIEW_ITEM'   , STR0004 ) //"CST"

//Desabilitando op��o de ordena��o
oView:SetViewProperty("*", "ENABLENEWGRID")
oView:SetViewProperty( "*", "GRIDNOORDER" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDACAO
Fun��o que realiza as valida��es do modelo
@param		oModel	    - Objeto  -  Objeto do modelo FISA160A
@Return     lRet       - Booleano - REtorno com valida��o, .T. pode gravar, .F. n�o poder� gravar.

    @author Rafael Oliveira
    @since 16/06/2020
    @version P12.1.27

/*/
//-------------------------------------------------------------------
Static Function VALIDACAO(oModel)

Local lRet          := .T.
Local cRegra        := oModel:GetValue ('FISA160I',"CJ0_CODIGO" ) 
Local dDtIni        := oModel:GetValue ('FISA160I',"CJ0_VIGINI" )
Local dDtFim        := oModel:GetValue ('FISA160I',"CJ0_VIGFIM" )
lOCAL cID           := oModel:GetValue ('FISA160I',"CJ0_ID" )
Local nOperation 	:= oModel:GetOperation()
Local lAtualiza     := nOperation == MODEL_OPERATION_UPDATE
Local lInclui       := nOperation == MODEL_OPERATION_INSERT


//Verifica se j� existe regra com mesmo c�digo e mesma vig�ncia j� gravados
IF lInclui .OR. lAtualiza

    IF VigIniFIm(cRegra, dDtIni, dDtFim, lAtualiza, cID)
        lRet:= .F.
        Help( ,, 'Help',, STR0005 , 1, 0 ) //'Regra j� cadastrada para a vig�ncia informada'
    EndIF
EndiF

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} VigIniFIm
Fun��o que verifica se data inicial e data final j� existem no cadastro de regras

@param     cRegra      - String - Sigla da Regra
@param     dDtIni      - Date - Data inicial de vig�ncia
@param     dDtFim      - Date - Data final de vig�ncia
@param     lEdit       - Booleano - indica se � uma opera��o de edi��o

@return    lRet        - Booleano - Indica se encontrou a regra com data final de vig�ncia vazio 

@author Erick G Dias
@since 09/07/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function VigIniFIm(cRegra, dDtIni, dDtFim, lEdit,cIdCJ0)

Local lRet      := .F.
Local cSelect	:= ""
Local cFrom	    := ""
Local cWhere	:= ""
Local cAliasQry	:= ""

//Query filtrando filial e regra
cSelect := "CJ0.CJ0_CODIGO"
cFrom   += RetSQLName("CJ0") + " CJ0 "
cWhere  += "CJ0.CJ0_FILIAL = " + ValToSQL(xFilial("CJ0")) + " AND "
cWhere  += "CJ0.CJ0_CODIGO = " + ValToSQL(cRegra) + " AND "
 

cWhere  += "( "

//Verifica se est� compreendido em cadastro somente com data inicial preenchida
cWhere  += "( " + ValToSQL(dDtIni) + " >= CJ0.CJ0_VIGINI  AND CJ0.CJ0_VIGFIM = ' ' ) OR"
//Verifica se a data inicial est� compreenchida em algum cadastro como data inicial e final informados
cWhere  += "( " + ValToSQL(dDtIni) + " >= CJ0.CJ0_VIGINI  AND " + ValToSQL(dDtIni) + " <= CJ0.CJ0_VIGFIM ) "

//Tratamento para data final
IF Empty(dDtFim)
    //Se no cadastro n�o foi informado a data final, ent�o verificar� se j� existe no cadastro alguma linha sem data final preenchida
    cWhere  += " OR ( CJ0.CJ0_VIGFIM = ' ' ) "
ElseIf !Empty(dDtFim)
    //Caso a data final seja informada ent�o verificaremos se est�comprendida em algum cadastro com data inicial e final preenchidos.
    cWhere  += " OR ( " + ValToSQL(dDtFim) + " >= CJ0.CJ0_VIGINI  AND " + ValToSQL(dDtFim) + " <= CJ0.CJ0_VIGFIM ) "
    cWhere  += " OR ( " + ValToSQL(dDtFim) + " >= CJ0.CJ0_VIGINI  AND CJ0.CJ0_VIGFIM = ' ') "
EndIF

cWhere  += " ) AND " 

If lEdit
    //Se for edi��o desconsiderarei a linha editada, para n�o entrar em conflito com ela mesma
    //Como temos consulta padr�o da CJ0, ela acaba desposicionando o tributo, e por este motivo antes de gravar eu retorno a CJ0 originalmente clicada no browse para edi��o
    DbSelectArea("CJ0")
    CJ0->(DbSetOrder(1))
    If CJ0->(MsSeek( xFilial("CJ0") + cIdCJ0 ))
        cWhere  += " CJ0.R_E_C_N_O_ <> " + ValtoSql(CJ0->(recno())) + " AND "    
    EndIF    
EndIF

cWhere  += "CJ0.D_E_L_E_T_ = ' '"		
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

    @author Rafael Oliveira
    @since 16/06/2020
    @version P12.1.27

/*/
//-------------------------------------------------------------------
Static Function VldCodigo(oModel)

Local cCodigo     := oModel:GetValue ('FISA160I', "CJ0_CODIGO")
Local lRet          := .T.

//N�o pode digitar operadores e () no c�digo
If "*" $ cCodigo .Or. ;
   "/" $ cCodigo .Or. ;
   "-" $ cCodigo .Or. ;
   "+" $ cCodigo .Or. ;
   "(" $ cCodigo .Or. ;
   ")" $ cCodigo
    Help( ,, 'Help',, STR0006 + ": '*', '/', '+', '-', '(' e ')'", 1, 0 ) //"C�digo n�o pode conter os caracteres."
    return .F.
EndIF

IF " " $ Alltrim(cCodigo)
    Help( ,, 'Help',, STR0007, 1, 0 ) //C�digo n�o pode conter espa�o.
    Return .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160DCIZ
Fun��o executada quando usu�rio entrada na rotina FISA170
Essa rotina faz carga inicial dos CST para os tributos

@author Renato Rezende
@since 12/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA160ICJ0()

Local cAlias    := GetNextAlias()
Local cTipoTrib := ""
Local cCodRegra := ""
Local cDescr    := ""
local lcargaIni := !ExisteCarga()
local aRet      := Nil
Local aTributos := {}

//Se n�o houver nenhuma rela��o Tributo/CST cadastrada, far� a carga das informa��es iniciais.
If lcargaIni

    //Query na SX5
    BeginSql Alias cAlias

        SELECT X5_TABELA, X5_CHAVE, X5_DESCRI
        FROM %TABLE:SX5% X5
        WHERE X5.X5_TABELA IN ('S2','S3','SG','S9','SX')
        AND X5.X5_FILIAL = %xFilial:SX5%
        AND X5.%NOTDEL%
        ORDER BY %Order:SX5%

    EndSql

    //Percorre o resultado da consulta
    Do While !(cAlias)->(Eof())
        If (cAlias)->X5_TABELA == 'S2'
            cTipoTrib:= "000021"//"ICMS"
            cDescr:= STR0009 //"CST DO ICMS"
            cCodRegra:= "000001"
        
        ElseIf (cAlias)->X5_TABELA $ 'SG'
            cTipoTrib:= "000021"//"ICMS"
            cDescr:= STR0010 //"CSOSN DO ICMS NO SIMPLES NACIONAL"
            cCodRegra:= "000002"

        ElseIf (cAlias)->X5_TABELA == 'S3'
            cTipoTrib:= "000022"//"IPI"
            cDescr:= STR0011 //"CST DO IPI"
            cCodRegra:= "000003"

        ElseIf (cAlias)->X5_TABELA == 'S9'
            cTipoTrib:= "000020"//"ISS"
            cDescr:= STR0012 //"CST DO ISS"
            cCodRegra:= "000004"

        ElseIf (cAlias)->X5_TABELA == 'SX'
            cTipoTrib:= "000015"//"PIS"
            cDescr:= STR0013 //"CST DO PIS"
            cCodRegra:= "000005"
            
            //Inclus�o do Cofins
            aAdd(aTributos,{"000006", "000016", STR0014, SubStr(Alltrim((cAlias)->X5_CHAVE),1,3), FwNoAccent(OEMToANSI((cAlias)->X5_DESCRI)) } ) //"CST DO COFINS"

        EndIf

        aAdd( aTributos,{ cCodRegra, cTipoTrib, cDescr, SubStr(Alltrim((cAlias)->X5_CHAVE),1,3), FwNoAccent(OEMToANSI((cAlias)->X5_DESCRI)) } )
        (cAlias)->(DbSkip())
    EndDo

    Begin Transaction
        //Grava��o da tabela CJ0 e CJ1
        LoadCJ0CJ1(aTributos)

    End Transaction
EndIF

If !lcargaIni 
    aRet := compTable() 
    If Len(aRet) > 0 // Se houver valores no array chama a function updtCJ1 para grava��o no CJ1.
        updtCJ1(aRet)
    EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExisteCarga
Fun��o que far� verifica��o se j� existe carga do CST criada nas
tabelas CJ0 e CJ1.
Se houver ent�o retornar� verdadeiro, caso contr�rio retornar� falso.

@Return lRet -  Boolean  - Retorna .T. caso exista ao menos 1 CST cadastrado.

@author Renato Rezende
@since 12/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ExisteCarga()

Local lRet      := .F.

dbSelectArea('CJ0')
CJ0->(dbSetOrder(1))

//Se houver ao menos uma linha criada na tabela CJ0, a rotina n�o far� a carga inicial.
lRet:= Iif(CJ0->( MsSeek ( xFilial('CJ0')) ),.T.,.F.)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCJ0CJ1
Fun��o que carregar� o model e incluir� os novos registros nas
tabelas C0J e CJ1

@author Renato Rezende
@since 12/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function LoadCJ0CJ1(aTributos)

Local oModel    := FWLoadModel('FISA160I')
Local nR        := 0
Local cCodRegra := ""

//Ordenar os tributos para a inclus�o
ASORT(aTributos, , , { | x,y | x[1]+x[4] < y[1]+y[4]} )

for nR:= 1 to len(aTributos)

    //Verificar se eh um novo imposto para ser gravado
    If cCodRegra <> aTributos[nR][1]
        cCodRegra:= aTributos[nR][1]

        //Quando mudar o Id da regra dever� commitar a inclus�o
        If nR <> 1
            If oModel:VldData()
                oModel:CommitData()
            Else		
                VarInfo("",oModel:GetErrorMessage())
                Exit
            EndIf

            oModel:DeActivate()
        
        EndIf
        
        oModel:SetOperation(MODEL_OPERATION_INSERT)
        oModel:Activate()

        //Para essa opera��o � preciso especificar qual o modelo que queremos inserir o valor
        oModel:SetValue("FISA160I","CJ0_CODIGO"     , aTributos[nR][1])
        oModel:SetValue("FISA160I","CJ0_DESCR"      , aTributos[nR][3])
        oModel:SetValue("FISA160I","CJ0_IDTRIB"     , aTributos[nR][2])
        oModel:SetValue("FISA160I","CJ0_VIGINI"     , cToD("01/01/1990"))
    EndIf

    //Adiciona uma nova linha no grid
    oModel:GetModel("FISA160ICST"):AddLine()

    oModel:SetValue("FISA160ICST","CJ1_CST"     , aTributos[nR][4])
    oModel:SetValue("FISA160ICST","CJ1_DESCR"   , aTributos[nR][5])

next nR


//Commit da inclus�o do �ltimo registro
If len(aTributos) > 0
    If oModel:VldData()
        oModel:CommitData()
    Else		
        VarInfo("",oModel:GetErrorMessage())
    EndIf

    oModel:DeActivate()
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PosProces
Fun��o que realiza altera��es que devem ocorrer no pre - procesamento 


    @author Rafael Oliveira
    @since 17/08/2020
    @version P12.1.27

/*/
//-------------------------------------------------------------------

Static Function PosProces(oModel)
Local nOperation 	:= oModel:GetOperation()
Local cIdCJ0        := ""
Local oItens        := nil
Local nTam          := 0
Local nX            := 0

IF nOperation == MODEL_OPERATION_INSERT
    //Atribui  novo ID
    cIdCJ0  := FWUUID("CJ0")
    oModel:SetValue( 'FISA160I', 'CJ0_ID', cIdCJ0)

    //-----------------------------------
    //Atribui o ID para o grid das faixas
    //-----------------------------------
    oItens := oModel:GetModel("FISA160ICST")
    nTam  := oItens:Length()

    //La�o no grid do tributo
    For nX := 1 to nTam 
        oItens:GoLine(nX)
        oItens:SetValue('CJ1_ID'    , FWUUID("CJ1"))  //Chave da CJ1
        oItens:SetValue('CJ1_ID_CAB' , cIdCJ0) //Chave estrangeira com CJ0
    Next nX

Endif

Return .T.


/*/{Protheus.doc} compTable
Verificar novos cadastros de c�digos de CST do ICMS na tabela generica S2 do SX5 para espelhar nos cadastros do Configurador de Tributos 
@type function
@version 12.1.33
@author edinei.pereira
@since 4/4/2023
@return variant, Retarona a difren�a da tabela generica S2 do SX5 comparado com CJ1, CST do ICMS
/*/
Static function compTable()
Local cAliasQry := GetNextAlias()
local aDiferen := {}

    BeginSQL Alias cAliasQry //Query no S2 do SX5 bucando c�digos de CST do ICMS para compara��o com CJ1.

        SELECT X5_TABELA, X5_CHAVE, X5_DESCRI, CJ1.CJ1_CODCAB
        FROM %TABLE:SX5% X5
        LEFT JOIN %TABLE:CJ1% CJ1 ON CJ1.CJ1_CODCAB = '000001'
        AND CJ1.D_E_L_E_T_ = '' 
        AND CJ1.CJ1_CST = X5.X5_CHAVE
        WHERE X5.X5_TABELA = 'S2'
        AND X5.X5_FILIAL = %xFilial:SX5%
        AND X5.%NOTDEL%
        ORDER BY %Order:SX5%

    EndSql

    While !(cAliasQry)->(Eof())
        if Empty((cAliasQry)->CJ1_CODCAB) 
            aAdd( aDiferen,{ SubStr(Alltrim((cAliasQry)->X5_CHAVE),1,3), FwNoAccent(OEMToANSI(ALLTRIM((cAliasQry)->X5_DESCRI))) } )
        endif
        (cAliasQry)->(DbSkip())
    ENDDO

Return aDiferen //Retorna diferen�a do comparado entre S2 do SX5 com CJ1.


/*/{Protheus.doc} updtCJ1
 Update dos cadastros de CST do ICMS nas tabelas do Configurador de Trinutos
@type function
@version 12.1.33
@author edinei.pereira
@since 4/4/2023
@param aDados, array, Diferen�a de novos c�digos de CST do ICMS verificados em compara��o na function compTable
@return variadic, Faz grava��o de novos c�digos de CST do ICMS na tabela CJ1 
/*/
Static function  updtCJ1(aDados)
local oModel := FWLoadModel('FISA160I')
local nX := 0

    oModel:SetOperation(MODEL_OPERATION_UPDATE)

    DBSELECTAREA( 'CJ0' )
    CJ0->(DBSETORDER( 2 ))

    if CJ0->(DBSEEK( xFilial("CJ0") + "000001"))
        oModel:Activate()

        for nX := 1 to len(aDados)
            //Adiciona uma nova linha no grid
            oModel:GetModel("FISA160ICST"):AddLine()

            oModel:SetValue("FISA160ICST","CJ1_CST"     , aDados[nX][1])
            oModel:SetValue("FISA160ICST","CJ1_DESCR"   , aDados[nX][2])
        Next

        If oModel:VldData()
            oModel:CommitData()
        Else
            VarInfo("",oModel:GetErrorMessage())
        EndIf

    endif

    oModel:DeActivate()

return
