#INCLUDE "GFEA080.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} FRTA080
Cadastro de Conversoes de Unidades de Medida
Uso Generico.

@sample
FRTA080()

@author Felipe Nathan Welter
@since 11/11/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA080()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GUV")						 // Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA080")				 // Nome do fonte onde esta a fun��o MenuDef
oBrowse:SetDescription("Configura��o de Convers�es entre Unidades de Medida")	 // Descri��o do browse //"Convers�es de Unidade de Medida"

oBrowse:Activate()

Return(Nil)
//---------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
// Adiciona bot�es do browse
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA080" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA080" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA080" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA080" OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA080" OPERATION 9 ACCESS 0 //"Copiar"
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEA080" OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina

//---------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
// bPost   Code-Block de valida��o do formul�rio de edi��o
// bCommit Code-Block de persist�ncia do formul�rio de edi��o
// bCancel Code-Block de cancelamento do formul�rio de edi��o
oModel := MPFormModel():New("GFEA080",/*bPre*/,/*bPos*/,/*bCommit*/, /*bCancel*/)

// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
// bPost        Code-Block de valida��o do formul�rio de edi��o
// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
oModel:AddFields("GFEA080_GUV", /*cOwner*/, FWFormStruct(1,"GUV"),/*bPre*/,/*bPost*/,/*bLoad*/)

//oModel:SetPrimaryKey({"GUV_FILIAL", "GVA_UNIDE", "GVA_UNIPAR"})

oModel:SetDescription( STR0009 ) //'Modelo de Dados de Convers�es de Unidade de Medida'
oModel:GetModel( 'GFEA080_GUV' ):SetDescription( STR0010 ) //'Dados de Convers�es de Unidade de Medida'
oModel:SetDescription("Convers�es entre Unidades de Medida")

Return oModel

//---------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel := FWLoadModel("GFEA080")
Local oView  := Nil

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,S� � necess�ri o caso estamos mundando o ID no View.
oView:AddField("GFEA080_GUV",FWFormStruct(2,"GUV"),"GFEA080_GUV")
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.

oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

// Associa um View a um box
oView:SetOwnerView( "GFEA080_GUV" , "MASTER" )

Return oView

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA080VL
Validacao dos campos do dicionario.
Uso GFEA080.

@param  cCampo        Campo para validacao, n�o obrigat�rio (default ReadVar())

@sample
GFEA080VL(cCampo)

@author Felipe Nathan Welter
@since 11/11/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA080VL(cCampo)

Local aArea := GetArea()
Local lRet := .T.

Default cCampo := ReadVar()

If "GUV_UNIDE" $ cCampo .Or. "GUV_UNIPAR" $ cCampo
	If M->GUV_UNIDE == M->GUV_UNIPAR
		Help(,,'HELP',,STR0011,1,0) //"Unidade de Medida DE deve ser diferente de unidade PARA."
		lRet := .F.
	EndIf
ElseIf "GUV_QTDDE" $ cCampo .Or. "GUV_QTDPAR" $ cCampo
	If M->GUV_QTDDE == M->GUV_QTDPAR
		Help(,,'HELP',,STR0012,1,0) //"Quantidade DE deve ser diferente de quantidade PARA."
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return lRet