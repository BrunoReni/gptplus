#Include	"Protheus.Ch"
#Include	"FWMVCDef.Ch"  
#Include	"topconn.Ch"
#Include 	"ApWizard.Ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSITBTU
@author Luciano
@since 24/03/2015
@version P11
/*/
Function PLSITBTU()

Local	oBrowse := Nil

Private	cCadastro	:= "Atalho Item Terminologia Protheus x TISS"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Instancia a Classe de Browse.											 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oBrowse := FWMBrowse():New()

// Definicao do MenuDef a ser utilizado.          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oBrowse:SetMenuDef("PLSITBTU")

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Definicao da tabela do Browse.											 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oBrowse:SetAlias("BTU")

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Definicao de Filtros.													 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cFiltroAux := " BTU->BTU_CODTAB == '"+BTP->BTP_CODTAB+"'"

oBrowse:SetFilterDefault(cFiltroAux)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Definicao do titulo do Browse.											 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oBrowse:SetDescription("Atalho Itens Terminologia Protheus x TISS")

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Desabilita a exibicao dos Detalhes.										 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oBrowse:DisableDetails()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Ativacao da Classe de Browse.											 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oBrowse:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define as opcoes do aRotina.

@author Luciano
@since 25/03/2015
@version P11
/*/
Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina Title 'Visualizar'	Action 'VIEWDEF.PLSITBTU' OPERATION 2 ACCESS 0 
	ADD OPTION aRotina Title 'Incluir' 		Action 'VIEWDEF.PLSITBTU' OPERATION 3 ACCESS 0 
	ADD OPTION aRotina Title 'Alterar' 		Action 'VIEWDEF.PLSITBTU' OPERATION 4 ACCESS 0 
	ADD OPTION aRotina Title 'Excluir' 		Action 'VIEWDEF.PLSITBTU' OPERATION 5 ACCESS 0 
Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o Modelo de Interface.

@author Luciano
@since 25/03/2015
@version P11
/*/
Static Function ModelDef()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Cria a estrutura a ser usada no Modelo de Dados.						 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Local oStruBTU 	:= FWFormStruct( 1, "BTU", /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel	:= Nil

oStruBTU:SetProperty( 'BTU_CODTAB', MODEL_FIELD_INIT, { || BTP->BTP_CODTAB } )
oStruBTU:SetProperty( 'BTU_ALIAS', MODEL_FIELD_INIT, { || BTP->BTP_ALIAS } )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Cria o objeto do Modelo de Dados.										 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oModel := MPFormModel():New("PLSITBTU", /*bPreValidacao*/, { | oMdl | PLIBTUVAL( oMdl ) }, /*bCommit*/, /*bCancel*/ )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Adiciona a descricao do Modelo de Dados.								 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oModel:SetDescription( "Modelo de Dados BTU" )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Adiciona ao modelo uma estrutura de formul�rio de edi豫o por campo.		 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oModel:AddFields( "BTUTESTE", /*cOwner*/, oStruBTU, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Adiciona a descricao do Componente do Modelo de Dados.					 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oModel:GetModel( "BTUTESTE" ):SetDescription( "Itens Terminologia Protheus x TISS" )

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o Modelo de Interface.

@author Luciano 
@since 25/03/2015
@version P11
/*/
Static Function ViewDef()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿎ria a estrutura a ser usada na View. 									 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Local oStruBTU 	:= FWFormStruct( 2, "BTU" )
Local oView		:= Nil

oStruBTU:SetProperty( 'BTU_CODTAB' , MVC_VIEW_CANCHANGE, .F. )  
oStruBTU:SetProperty( 'BTU_ALIAS'  , MVC_VIEW_CANCHANGE, .F. )
	
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿎ria o objeto de View.				 									 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oView := FWFormView():New()

//Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado.
oModel   	:= FWLoadModel( "PLSITBTU" )	

//Define qual o Modelo de dados ser� utilizado.							 
oView:SetModel( oModel )  

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿌diciona no nosso View um controle do tipo FormFields(antiga enchoice).	 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oView:AddField( "VIEW_TESTE", oStruBTU, "BTUTESTE" )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿎riar um "box" horizontal para receber algum elemento da view.			 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oView:CreateHorizontalBox( 'BOX0101' 	, 100 , , , , )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿝elaciona o ID da View com o "box" para exibicao.						 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oView:SetOwnerView( "VIEW_TESTE", "BOX0101" )    

Return(oView)  

//-------------------------------------------------------------------
Static Function PLIBTUVAL()
Local oModel     := FWModelActive()
Local nOperation := oModel:GetOperation()
Local aArea      := GetArea()
Local aAreaBTU   := BTU->( GetArea() ) 
Local lOk        := .T.

If nOperation == 3 // Inclusao
	BTU->( dbSetOrder( 2 ) ) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS
	cBTUChave := xFilial( 'BTU' ) + FwFldGet( 'BTU_CODTAB' ) + FwFldGet( 'BTU_ALIAS' )+ FwFldGet( 'BTU_VLRSIS' ) 
	cCodTermo := FwFldGet( 'BTU_CDTERM' )                                                                                                                     
	If BTU->( dbSeek(cBTUChave) )   
		While BTU->(!EOF()) .And. BTU->(BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS)== cBTUChave
			If BTU->BTU_CDTERM  == cCodTermo
				Help( ,, 'Help',, 'Valor BTU j� existe. Informa豫o Duplicada', 1, 0 )
				lOk := .F. 
			Endif
			BTU->(dbSkip())
		Enddo
	EndIf
Endif

RestArea( aAreaBTU )
RestArea( aArea )

Return lOk
