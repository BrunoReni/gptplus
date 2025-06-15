#Include "FISA160J.ch"
#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "FWEditPanel.CH"

//TODO - Gravação do histórico da tabela
//TODO - Exibir histórico
//TODO - Rever grupos para adicionar campos de fórmulas

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA160J()

Esta rotina tem objetivo de criar rtina para composição da regra
de escrituração do tributo. Esta regra será vinculada ao cadastro 

CJ2 - Cabeçalho

@author Erick Dias
@since 13/08/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Function FISA160J()
Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CJ2")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CJ2")    
    oBrowse:SetDescription(STR0001) //"Cadastro da Regra de Escrituração"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicionário desatualizado, verifique as atualizações do configurador de tributos"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick Dias
@since 13/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA160J' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA160J' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA160J' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.FISA160J' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.FISA160J' OPERATION 9 ACCESS 0 //'Copiar'
ADD OPTION aRotina TITLE STR0010 ACTION 'FSA160JHist'      OPERATION 4 ACCESS 0 //"Histórico de Alterações"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo da regra de escrituração

@author Erick Dias
@since 13/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel    := Nil

//Estrutura da tabela CJ2 com os campos do cabeçalho da regra
Local oCabecalho  := FWFormStruct(1, "CJ2" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA160J',,,{|oModel|FSA160JGrv(oModel)})

//Atribuindo cabeçalho para o modelo
oModel:AddFields("FISA160J",,oCabecalho)

//Não permite alterar o código da regra
oCabecalho:SetProperty('CJ2_CODIGO' , MODEL_FIELD_KEY,  .T. )
oCabecalho:SetProperty('CJ2_CODIGO' , MODEL_FIELD_VALID, {||( VldCod(oModel) )})

oCabecalho:SetProperty('CJ2_CST'    , MODEL_FIELD_VALID, {||( VldCST(oModel) )})
oCabecalho:SetProperty('CJ2_CSTDEV' , MODEL_FIELD_VALID, {||( VldCST(oModel) )})

oModel:SetPrimaryKey( {"CJ2_CODIGO","CJ2_ID"} )

//Adicionando descrição ao modelo
oModel:SetDescription(STR0003) //"Regras de Escrituração do Tributo"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Erick Dias
@since 13/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA160J" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho   := FWFormStruct(2, "CJ2")
Local oView      := Nil

oView:= FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField('VIEW_ESCRITURACAO', oCabecalho, 'FISA160J')

//Retira os campos da View
oCabecalho:RemoveField('CJ2_ID')
oCabecalho:RemoveField('CJ2_ALTERA')
oCabecalho:RemoveField('CJ2_HRALT')
oCabecalho:RemoveField('CJ2_DTALT')

oCabecalho:AddGroup( 'GRUPO_CABE'       , STR0011 , '' , 2 ) //"Definição da Regra de Escrituração"
oCabecalho:AddGroup( 'GRUPO_INCIDENCIA' , STR0012 , '' , 2 ) //"Incidência"
oCabecalho:AddGroup( 'GRUPO_CST'        , STR0013 , '' , 2 ) //"Código da Situação Tributária"

oCabecalho:SetProperty( 'CJ2_CODIGO'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CABE' )
oCabecalho:SetProperty( 'CJ2_DESCR'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CABE' )

oCabecalho:SetProperty( 'CJ2_INCIDE'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_INCIDENCIA' )
oCabecalho:SetProperty( 'CJ2_STOTNF'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_INCIDENCIA' )
oCabecalho:SetProperty( 'CJ2_PERDIF'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_INCIDENCIA' )
oCabecalho:SetProperty( 'CJ2_IREDBS'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_INCIDENCIA' )

oCabecalho:SetProperty( 'CJ2_CSTCAB'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CST' )
oCabecalho:SetProperty( 'CJ2_DCBCST'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CST' )
oCabecalho:SetProperty( 'CJ2_CST'      , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CST' )
oCabecalho:SetProperty( 'CJ2_DESCST'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CST' )
oCabecalho:SetProperty( 'CJ2_CSTDEV'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CST' )
oCabecalho:SetProperty( 'CJ2_DCSTDE'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CST' )

//Ordem dos campos
oCabecalho:SetProperty("CJ2_CODIGO"  , MVC_VIEW_ORDEM, "01")
oCabecalho:SetProperty("CJ2_DESCR"   , MVC_VIEW_ORDEM, "02")
oCabecalho:SetProperty("CJ2_INCIDE"  , MVC_VIEW_ORDEM, "03")
oCabecalho:SetProperty("CJ2_STOTNF"  , MVC_VIEW_ORDEM, "04")
oCabecalho:SetProperty("CJ2_PERDIF"  , MVC_VIEW_ORDEM, "05")
oCabecalho:SetProperty("CJ2_CSTCAB"  , MVC_VIEW_ORDEM, "06")
oCabecalho:SetProperty("CJ2_DCBCST"  , MVC_VIEW_ORDEM, "07")
oCabecalho:SetProperty("CJ2_CST"     , MVC_VIEW_ORDEM, "08")
oCabecalho:SetProperty("CJ2_DESCST"  , MVC_VIEW_ORDEM, "09")
oCabecalho:SetProperty("CJ2_CSTDEV"  , MVC_VIEW_ORDEM, "10")
oCabecalho:SetProperty("CJ2_DCSTDE"  , MVC_VIEW_ORDEM, "11")

//ALteração dos títulos de alguns campos:
oCabecalho:SetProperty("CJ2_STOTNF", MVC_VIEW_TITULO, STR0020) //"Total da Nota"
oCabecalho:SetProperty("CJ2_PERDIF", MVC_VIEW_TITULO, STR0021) //"Percentual de Diferimento"
oCabecalho:SetProperty("CJ2_CSTCAB", MVC_VIEW_TITULO, STR0022) //"Tabela CST"
oCabecalho:SetProperty("CJ2_IREDBS", MVC_VIEW_TITULO, "Incidencia Parcela Reduzida") //"Tabela CST"

//Seto o layout para que o campo memo fique um pouco maior, preenchendo mais tela    
oView:SetViewProperty( "VIEW_ESCRITURACAO", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCod
Função que valida se o código de regra  já existe

@author Erick Dias
@since 13/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function VldCod(oModel)

Local lRet      := .T.

dbSelectArea("CJ2")
dbSetOrder(1) 

//Verifico se na inclusão o código já foi utilizado
IF oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. CJ2->( MsSeek ( xFilial('CJ2') + oModel:GetValue ('FISA160J',"CJ2_CODIGO") ) )
    Help( ,, 'Help',,STR0004, 1, 0 ) //"Código da Regra de Escrituração já cadastrada"
    return .F.
EndIF

Return lRet

//------------------------------------------------------------
/*/{Protheus.doc} VldCST
Função de validação do CST

@author Erick Dias
@since 17/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function VldCST(oModel)

Local cCst      := oModel:GetValue ('FISA160J',"CJ2_CST")
Local cCstTab   := oModel:GetValue ('FISA160J',"CJ2_CSTCAB")
Local cCstDev   := oModel:GetValue ('FISA160J',"CJ2_CSTDEV")

dbSelectArea("CJ1")
dbSetOrder(2) 

IF (!Empty(cCst) .AND. !Empty(cCstTab) .AND. !CJ1->( MsSeek ( xFilial('CJ1') + cCstTab + cCst ) )) .Or. (!Empty(cCstDev) .AND. !Empty(cCstTab) .AND. !CJ1->( MsSeek ( xFilial('CJ1') + cCstTab + cCstDev ) ))
    //Código inválido
    Help( ,, 'Help',,STR0023, 1, 0 ) //"Código de CST inválido"
    return .F.

Elseif (!Empty(cCst) .AND. Empty(cCstTab)) .Or. (!Empty(cCstDev) .AND. Empty(cCstTab))
    //Informar tabela primeiro
    Help( ,, 'Help',,STR0024, 1, 0 ) //"Por favor, informe primeiro o código da tabela de CST"
    return .F.
EndIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160JGrv
Função que fará controle para gravação da tabela CJ2, com controle
de histórico

@author Erick Dias
@since 14/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA160JGrv(oModel)

Local nOperation 	:= oModel:GetOperation()
Local cCodigo       := oModel:GetValue ('FISA160J',"CJ2_CODIGO")   
Local cDescr        := oModel:GetValue ('FISA160J',"CJ2_DESCR")   
Local cIncide       := oModel:GetValue ('FISA160J',"CJ2_INCIDE")  
Local cStotNf       := oModel:GetValue ('FISA160J',"CJ2_STOTNF")  
Local nPerDif       := oModel:GetValue ('FISA160J',"CJ2_PERDIF")  
Local cCabCST       := oModel:GetValue ('FISA160J',"CJ2_CSTCAB")  
Local cCst          := oModel:GetValue ('FISA160J',"CJ2_CST")   
Local cCstDev       := oModel:GetValue ('FISA160J',"CJ2_CSTDEV")   
Local cIncRed       := oModel:GetValue ('FISA160J',"CJ2_IREDBS")   

If nOperation == MODEL_OPERATION_INSERT .Or.  nOperation == MODEL_OPERATION_UPDATE

    //Na edição preciso alterar o flag como alterado para manter o histórico de alterações
    If nOperation == MODEL_OPERATION_UPDATE
        
        //Chama função para alterar registro atual        
        GravaCJ2(2, cCodigo, cDescr, cIncide, cStotNf,nPerDif, cCst, cCabCST,cIncRed,cCstDev)

    EndIF

    //Agora chamo função para inserir novo registro, seja na operação de inclusão ou edição.
    GravaCJ2(1, cCodigo, cDescr, cIncide, cStotNf,nPerDif, cCst, cCabCST,cIncRed,cCstDev)
    
ElseIf nOperation == MODEL_OPERATION_DELETE

    //Faz exclusão do registro
    RecLock("CJ2",.F.)
	CJ2->(dbDelete())
	MsUnLock()

EndIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaCJ2
Função que fará a presistência na tabela CJ2

@author Erick Dias
@since 14/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function GravaCJ2(nOpc, cCodigo, cDescr, cIncide, cStotNf,nPerDif, cCst, cCabCST,cIncRed,cCstDev)

If nOpc == 1 //Inclusão
    
    RecLock("CJ2",.T.)
    CJ2->CJ2_FILIAL := xFilial("CJ2")    
    CJ2->CJ2_ID     := FWUUID("CJ2")
    CJ2->CJ2_CODIGO := cCodigo
    CJ2->CJ2_DESCR  := cDescr
    CJ2->CJ2_INCIDE := cIncide
    CJ2->CJ2_STOTNF := cStotNf
    CJ2->CJ2_PERDIF := nPerDif
    CJ2->CJ2_CSTCAB := cCabCST
    CJ2->CJ2_CST    := cCst
    CJ2->CJ2_CSTDEV := cCstDev
    CJ2->CJ2_IREDBS := cIncRed
    CJ2->CJ2_ALTERA := "2" //Indica sem alterações
    MsUnLock()

Elseif nOpc == 2
    
    RecLock("CJ2",.F.)
    CJ2->CJ2_ALTERA := "1" //Indica que sofreu alterações
    CJ2->CJ2_DTALT := Date()
    CJ2->CJ2_HRALT := Time()
    MsUnLock()

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160JHist
Função que exibirá Browse com o histórico de alteações da rotina

@author Erick Dias
@since 24/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA160JHist()
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
AADD(aColunas,{ STR0014, &("{ || IIf(CJ2->CJ2_ALTERA == '1','" + STR0015 + "','" + STR0016 + "') }"), "C", "", 1, 1, 0, .f.}) //"Status - ALterado - Nõo alterado"
AADD(aColunas,{ STR0017, &("{ || CJ2->CJ2_DTALT }"), "D", "", 1, 1, 0, .f.}) //"Data de Alteração"
AADD(aColunas,{ STR0018, &("{ || Alltrim(CJ2->CJ2_HRALT) }"), "C", "", 1, 1, 0, .f.}) //"Horário de Alteração"

//Atribuo o Alias para variavel pública 
c170AlsHist := "CJ2"

//Monto o filtro abaixo somente com linhas que foram alteradas e não estão mais vigentes
cFiltro :="CJ2_FILIAL == '" + xFilial("CJ2") + "'"
cFiltro	+= " .AND. CJ2_CODIGO == '" + CJ2->CJ2_CODIGO +  "'"

//Utilizo segundo índice para facilitar a visualização
CJ2->(DbSetOrder(4))

//Chamo a função auxiliar que montará o Browse com as regras alteradas.
FSA16XHist("CJ2", cFiltro, STR0019 , aColunas) //"Histórico de Alterações da Regra de Cálculo de Tributo"

//Retorno o Alias e filtro padrão
c170AlsHist := ""
CJ2->(DbSetOrder(1))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} 160JVTotDp
Função que irá retornar a lista do combo para o campo CJ2_STOTNF

@author Renato Rezende
@since 31/08/2020
@version P12.1.31
/*/
//-------------------------------------------------------------------
Function x160JTotDp()

Local cRet	:= ""

cRet+="1=Sem Ação;"
cRet+="2=Subtrai somente do total da nota;"
cRet+="3=Subtrai do total da nota e da duplicata;"
cRet+="4=Subtrai somente do total da duplicata;"
cRet+="5=Soma somente no total da nota;"
cRet+="6=Soma no total da nota e da duplicata;"
cRet+="7=Soma somente no total da duplicata;"
cRet+="8=Gross up no total da duplicata"

Return cRet