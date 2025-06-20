#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA161()

Esta rotina � apenas para montar a Tela com base nas informa��es
da tabela CIN (Cabe�alho Regra Conf Tributos)

Esta rotina estar� dispon�vel somente na vers�o 12.

@author Renato Rezende
@since 07/02/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Function FISA177()

Local   oBrowse := Nil
//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CIN")
    dbSelectArea("CIN")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CIN")
    oBrowse:SetDescription("Cabe�alho Regra Conf Tributos")
    oBrowse:Activate()
Else
    Help("",1,"Help","Help","Dicion�rio desatualizado, verifique as atualiza��es do motor tribut�rio fiscal.",1,0)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Renato Rezende
@since 07/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

//Habilitar no menu apenas visualiza��o, essa tabela � manipulada apenas pelo sistema
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.FISA177" OPERATION 2 ACCESS 0 //"Visualizar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo

@author Renato Rezende
@since 07/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel := Nil

//Estrutura da tabela CIN com os campos da Regra Conf Tributos
Local oCabecalho := FWFormStruct(1, "CIN" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA177')

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA177",,oCabecalho)

//Chave do Modelo
oModel:SetPrimaryKey( {"CIN_FILIAL","CIN_CODIGO","CIN_ALTERA","CIN_ID"} )

//Adicionando descri��o ao modelo
oModel:SetDescription("Cabe�alho Regra Conf Tributos")

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Renato Rezende
@since 07/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados
Local oModel        := FWLoadModel( "FISA177" )
Local oCabecalho    := FWFormStruct(2, "CIN")
Local oView         := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formul�rios para interface
oView:AddField( 'VIEW_FSA177' , oCabecalho  , 'FISA177'   )

//Retirando os campos do View
oCabecalho:RemoveField("CIN_ID")
oCabecalho:RemoveField("CIN_IREGRA")
oCabecalho:RemoveField("CIN_FNPI")
oCabecalho:RemoveField("CIN_ALTERA")
oCabecalho:RemoveField("CIN_CONSUL")

Return oView



//-------------------------------------------------------------------
/*/{Protheus.doc} X177TIPO
Fun��o para Retornar conteudo para combo do campo CIN_TPREGRA

@parametros
cStr - String que ser� trabalhada
cCampo - Campo que verificaremos o tamanho
cOper - Operador utilizado para saber onde sera adicionado o espa�o em branco

@author Matheus Massarotto
@since 12/02/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function X177TIPO()
Local cRet := ""

    cRet := '0=Valor Origem;1=Regra Base de C�lculo;2=Regra Al�quota;4=URF;6=Base do Tributo;7=Al�quota do Tributo;8=Valor do Tributo;9=�ndices de C�lculo;11=Al�quota da Tabela Progressiva;12=Dedu��o da Tabela Progressiva'

Return cRet