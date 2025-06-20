#Include "FISA160C.ch"
#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA160C()

Esta rotina tem objetivo de realizar cadastro de regras 
por dependentes

@author Renato Rezende
@since 24/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Function FISA160C()
Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CIV")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CIV")
    oBrowse:SetFilterDefault("CIV_ALTERA == '2'")
    oBrowse:SetDescription(STR0001) //"Cadastro de Regra por Dependentes"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicion�rio desatualizado, verifique as atualiza��es do motor tribut�rio fiscal."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Renato Rezende
@since 24/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.FISA160C' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0012 ACTION 'VIEWDEF.FISA160C' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0013 ACTION 'VIEWDEF.FISA160C' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0014 ACTION 'VIEWDEF.FISA160C' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE STR0015 ACTION 'VIEWDEF.FISA160C' OPERATION 9 ACCESS 0 //'Copiar'
ADD OPTION aRotina TITLE STR0016 ACTION 'FSA160CHist'      OPERATION 4 ACCESS 0 //'Hist�rico de Altera��es'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do cadastro de Regra por Dependentes

@author Renato Rezende
@since 24/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel    := Nil

//Estrutura da tabela CIV com os campos da Regrade pro Dependentes
Local oRegraDP  := FWFormStruct(1, "CIV" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA160C',/*Pre-Validacao*/,,{|oModel|FSA160CGrv(oModel)})

//Atribuindo cabe�alho para o modelo
oModel:AddFields("FISA160C",,oRegraDP)

//N�o permite alterar o c�digo da regra
oRegraDP:SetProperty('CIV_CODDEP' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) }) 

oRegraDP:SetProperty('CIV_CODDEP' , MODEL_FIELD_KEY,  .T. )
oRegraDP:SetProperty('CIV_CODDEP' , MODEL_FIELD_VALID, {||( VldCod(oModel) )})

oModel:SetPrimaryKey( {"CIV_FILIAL","CIV_CODDEP","CIV_ID"} )

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0001) //"Cadastro de Regra por Dependentes"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Renato Rezende
@since 24/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA160C" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oRegraDP   := FWFormStruct(2, "CIV")
Local oView      := Nil

oRegraDP:AddGroup( 'GRUPO01', OemToAnsi(STR0003), '', 2 ) //"Informe o C�digo da Regra"
oRegraDP:AddGroup( 'GRUPO02', OemToAnsi(STR0004), '', 2 ) //"Configura��o da Regra"
oRegraDP:AddGroup( 'GRUPO03', "", '', 2 )

oRegraDP:SetProperty( 'CIV_CODDEP'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
oRegraDP:SetProperty( 'CIV_DESCR'     ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
oRegraDP:SetProperty( 'CIV_VALDEP'    ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oRegraDP:SetProperty( 'CIV_TPDATA'    ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )

oView:= FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formul�rios para interface
oView:AddField('VIEW_DEPENDENTE', oRegraDP, 'FISA160C')

//Retira os campos da View
oRegraDP:RemoveField('CIV_ID')

//Alterando a descri��o de algns campos
oRegraDP:SetProperty("CIV_CODDEP", MVC_VIEW_TITULO, STR0005) //"C�digo da Regra"
oRegraDP:SetProperty("CIV_VALDEP", MVC_VIEW_TITULO, STR0006) //"Valor por dependente"
oRegraDP:SetProperty("CIV_TPDATA", MVC_VIEW_TITULO, "Data a ser considerada na busca de saldo por dependentes")


Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160CGrv
Fun��o respons�vel por realizar a grava��o da regra por dependentes.
Aqui faremos o tratamento do hist�rico de altera��es

@author Renato Rezende
@since 25/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA160CGrv(oModel)
Local nOperation 	:= oModel:GetOperation()
Local cCodigo 		:= oModel:GetValue ('FISA160C',"CIV_CODDEP")
Local cDescri 		:= oModel:GetValue ('FISA160C',"CIV_DESCR")
Local nValDep 		:= oModel:GetValue ('FISA160C',"CIV_VALDEP")
Local cTpData       := oModel:GetValue ('FISA160C',"CIV_TPDATA")
Local cIdRegra      := ""

If nOperation == MODEL_OPERATION_INSERT 
    //Chama fun��o para gravar nova informa��o na tabela CIV
    cIdRegra:= GravaCIV(1, cCodigo, cDescri, nValDep, cTpData)

    //Gravo regra na tabela CIN
    GravaCIN("1","9", cCodigo, cIdRegra, "(Dedu��o por Dependentes) | "     + cCodigo, xFisTpForm("9") + cCodigo)
 
ElseIF  nOperation == MODEL_OPERATION_UPDATE
    
    //Chama fun��o para alterar registro atual
    cIdRegra:= GravaCIV(2)

    //Altera regra da CIN
    GravaCIN("2",xFisTpForm("9"),, cIdRegra)

    //Agora chamo fun��o para inserir novo registro
    cIdRegra := GravaCIV(1, cCodigo, cDescri, nValDep, cTpData)
    
    //Grava nova regra na CIN
    GravaCIN("1","9", cCodigo, cIdRegra, "(Dedu��o por Dependentes) | "     + cCodigo, xFisTpForm("9") + cCodigo)

ElseIf nOperation == MODEL_OPERATION_DELETE
 
    //Deleto regra da CIN
    GravaCIN("3","9",, CIV->CIV_ID)
    
    //Faz exclus�o do registro
    RecLock("CIV",.F.)
	CIV->(dbDelete())
	MsUnLock()

EndIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaCIV
Fun��o que faz grava��o e edi��o da tabela CIV

@author Renato Rezende
@since 25/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function GravaCIV(nOp, cCodigo, cDescri, nValDep, cTpData)
Local cID := ""
If nOp == 1 //Incluiu

    RecLock("CIV",.T.)
    CIV->CIV_FILIAL	    := xFilial("CIV")
    CIV->CIV_ID		    := FWUUID("CIV")    
    CIV->CIV_CODDEP		:= cCodigo
    CIV->CIV_DESCR  	:= cDescri
    CIV->CIV_VALDEP		:= nValDep    
    CIV->CIV_ALTERA		:= "2" //Indica que n�o foi alterado
    CIV->CIV_TPDATA     := cTpData
    CIV->(MsUnLock())

ElseIf nOp ==2 //Altera��o    
    RecLock("CIV",.F.)
    CIV->CIV_ALTERA 		:= "1"//Indica que sofreu altera��es
    CIV->CIV_DTALT  		:= Date()
    CIV->CIV_HRALT  		:= Time()
    CIV->(MsUnLock())
EndIf

Return cId := CIV->CIV_ID

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCod
Fun��o que valida se o c�digo de regra por dependentes j� existe

@author Renato Rezende
@since 25/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function VldCod(oModel)

Local cCodigo 	:= oModel:GetValue ('FISA160C',"CIV_CODDEP")
Local lRet      := .T.

//Procura se j� existe regra com o mesmo c�digo
CIV->(DbSetOrder(4))
If CIV->( MsSeek ( xFilial('CIV') + cCodigo + '2' ) )
    Help( ,, 'Help',, STR0008, 1, 0 )  //"C�digo j� cadastrado!"
    return .F.    
EndIF

//N�o pode digitar operadores e () no c�digo
If "*" $ cCodigo .Or. ;
   "/" $ cCodigo .Or. ;
   "-" $ cCodigo .Or. ;
   "+" $ cCodigo .Or. ;
   "(" $ cCodigo .Or. ;
   ")" $ cCodigo
    Help( ,, 'Help',, STR0009, 1, 0 )  //"C�digo da regra n�o pode conter os caracteres '*', '/', '+', '-', '(' e ')'"
    return .F.
EndIF

IF " " $ Alltrim(cCodigo)
    Help( ,, 'Help',, STR0010, 1, 0 )  //"C�digo n�o pode conter espa�o."
    Return .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA162Hist
Fun��o que exibir� Browse com o hist�rico de altea��es da rotina

@author Erick Dias
@since 24/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA160CHist()
Local cFiltro   := ""
Local aColunas  := {}

//Adicionando as colunas de Data e horario de altera��o, pois o UPDDISTR n�o altera o X3_BROWSE, por isso estou adicionado a coluna manualmente.
/* Posi��es dos arrays
1 - T�tulo
2 - Codeblock para carregra a ~informa��o
3 - Tipo
4 - Alinhamento (1 alinhado a esquera)
5 - Tamanho
6 - Decimal
7 - Indica se permite altera��o
*/
AADD(aColunas,{ STR0020, &("{ || IIf(CIV->CIV_ALTERA == '1','" + STR0021 + "','" + STR0022 + "') }"), "C", "", 1, 1, 0, .f.}) //"Status - ALterado - N�o alterado"
AADD(aColunas,{ STR0018, &("{ || CIV->CIV_DTALT }"), "D", "", 1, 8, 0, .f.}) //"Data de Altera��o"
AADD(aColunas,{ STR0019, &("{ || CIV->CIV_HRALT }"), "C", "", 1, 8, 0, .f.}) //"Hor�rio de Altera��o"

//Atribuo o Alias para variavel p�blica 
c170AlsHist := "CIV"

//Monto o filtro abaixo somente com linhas que foram alteradas e n�o est�o mais vigentes
cFiltro :="CIV_FILIAL == '" + xFilial("CIV") + "'"
cFiltro	+= " .AND. CIV_CODDEP == '" + CIV->CIV_CODDEP +  "'"

//Utilizo segundo �ndice para facilitar a visualiza��o
CIV->(DbSetOrder(2))

//Chamo a fun��o auxiliar que montar� o Browse com as regras alteradas.
FSA16XHist("CIV", cFiltro, STR0017, aColunas) //Hist�rico de altera��es da Regra de Dependentes"

//Retorno o Alias e filtro padr�o
c170AlsHist := ""
CIV->(DbSetOrder(1))

Return