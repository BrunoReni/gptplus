#INCLUDE "GFEA013.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA013

Cadastro de Al�quotas de ICMS 

@author Jorge Matos Valcanaia
@since 21/10/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA013()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GUT")							// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA013")					// Nome do fonte onde esta a fun��o MenuDef
oBrowse:SetDescription("Configura��o de Tributa��o de ICMS")   	// Descri��o do browse //"Al�quotas de ICMS"
oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
//-------------------------------------------------------
// Adiciona bot�es do browse
//-------------------------------------------------------
ADD OPTION aRotina TITLE STR0001  ACTION STR0002        OPERATION 1 ACCESS 0 //"Pesquisar"###"AxPesqui"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA013" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004    ACTION "VIEWDEF.GFEA013" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.GFEA013" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.GFEA013" OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007     ACTION "VIEWDEF.GFEA013" OPERATION 9 ACCESS 0 //"Copiar"
ADD OPTION aRotina TITLE STR0008   ACTION "VIEWDEF.GFEA013" OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina

//-------------------------------------------------------
//Fun��o ModelDef
//-------------------------------------------------------

Static Function ModelDef()

Local oModel 
Local oStructGUT := FWFormStruct(1,"GUT")
Local oStructGUR := FWFormStruct(1,"GUR")


oStructGUR:RemoveField( "GUR_FILIAL" )
oStructGUR:RemoveField( "GUR_UF"     )


// cID     Identificador do modelo 
// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
// bPost   Code-Block de valida��o do formul�rio de edi��o
// bCommit Code-Block de persist�ncia do formul�rio de edi��o
// bCancel Code-Block de cancelamento do formul�rio de edi��o
oModel := MPFormModel():New("GFEA013", /*bPre*/,{|oX| GFEA13POS(oX)}, /*bPost*/, /*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
// bPost        Code-Block de valida��o do formul�rio de edi��o
// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
oModel:AddFields("GFEA013_GUT", Nil, oStructGUT,/*bPre*/,/*bPost*/,/*bLoad*/)
//oModel:SetPrimaryKey({"GUT_FILIAL", "GUT_UF"})  

oModel:AddGrid("GFEA013_GUR","GFEA013_GUT",oStructGUR,/*bLinePre*/,/*{ | oX | ValideItem( oX ) }*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("GFEA013_GUR",{{"GUR_FILIAL",'xFilial("GUR")'},{"GUR_UF","GUT_UF"}},"GUR_FILIAL+GUR_UF")
oModel:SetPrimaryKey({"GUT_FILIAL", "GUT_UF"})  
oModel:GetModel("GFEA013_GUR"):SetDelAllLine(.T.)

oModel:SetOptional("GFEA013_GUR", .T. )

oModel:GetModel("GFEA013_GUR"):SetUniqueLine({/*"GUR_UFORIG",*/"GUR_UFDEST","GUR_TPITEM","GUR_CDTPOP","GUR_TPCLFR","GUR_TRIBT","GUR_TRTRAN","GUR_TRIBR","GUR_TRREM","GUR_TRIBD","GUR_TRDEST","GUR_USO","GUR_CICMS"})
oModel:SetDescription("Tributa��o de ICMS")

Return oModel

//-------------------------------------------------------
//Fun��o viewDef
//-------------------------------------------------------

Static Function ViewDef()

Local oModel := FWLoadModel("GFEA013")
Local oView 
Local oStructGUR := FWFormStruct(2,"GUR")

oStructGUR:RemoveField( "GUR_FILIAL" )
oStructGUR:RemoveField( "GUR_UF"     )


oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField( "GFEA013_GUT" , FWFormStruct(2,"GUT") ) 
oView:AddGrid( "GFEA013_GUR" , oStructGUR )


oView:CreateHorizontalBox( "MASTER" , 22 )
oView:CreateHorizontalBox( "DETAIL" , 78 )

oView:CreateFolder("IDFOLDER","DETAIL")
oView:AddSheet("IDFOLDER","IDSHEET01",STR0009) //"Exce��es"


oView:CreateHorizontalBox( "DETAILEXE"  , 100,,,"IDFOLDER","IDSHEET01" )


oView:SetOwnerView( "GFEA013_GUT" , "MASTER" )
oView:SetOwnerView( "GFEA013_GUR" , "DETAILEXE" )


Return oView

//--------------------------------------------------
/*
{Protheus.doc} GFEA13RED

Fun��o para validar o campo de tipo de tributa��o do grid de Exce��es

@author Oct�vio Augusto Felippe de Macedo
@since 11/01/2011
@version 1.0
*/

Function GFEA13RED()

If FwFldGet("GUR_TPTRIB") != "5" .And. FwFldGet("GUR_PCREIC") > 0
	Help( ,, 'HELP',, STR0011, 1, 0)
	Return .F.                                                   
EndIf	
	
If FwFldGet("GUR_TPTRIB") == "5" .And. FwFldGet("GUR_PCREIC") == 0 .And. "GUR_PCREIC" $ ReadVar() 
	Help( ,, 'HELP',, STR0013, 1, 0)
	Return .F.
EndIf

Return .T.

//--------------------------------------------------
/*
{Protheus.doc} GFEA13POS

Fun��o para validar o model depois da confirma��o para verificar se n�o h� nenhum 
registro com % de Red. ICMS igual a zero enquanto o tipo de tributa��o � igual a 'reduzido'.

@author Oct�vio Augusto Felippe de Macedo
@since 11/01/2011
@version 1.0
*/

Static Function GFEA13POS(oModel)

Local oModelGUR := oModel:GetModel("GFEA013_GUR")
Local nAtuLn    := oModelGUR:GetLine()
Local nLine

For nLine := 1 To oModelGUR:GetQtdLine()
	oModelGUR:GoLine(nLine)
	If !oModelGUR:IsDeleted()
		If FwFldGet("GUR_TPTRIB",nLine) == "5" .And. FwFldGet("GUR_PCREIC",nLine) == 0
			Help( ,, 'HELP',, StrTran(STR0012,"[line]",AllTrim(Str(nLine))), 1, 0)
			Return .F.
		EndIf	
	EndIf	
Next nLine

oModelGUR:GoLine(nAtuLn)

Return .T. 