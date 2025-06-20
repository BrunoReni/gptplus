#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEA510.CH"

//-------------------------------------------------------------------
//Inclus�o P�tios 12.1.4
/*/{Protheus.doc} GFEA510
Rotina para cadastro de opera��es
Uso Geral.

@param 	oModel	    Recebe o oModel principal

@author Israel Alcantara Possoli
@since 06/09/2010
@version 1.0
/*/
//-------------------------------------------------------------------
//-------------------------------------------------------------------
Function GFEA510()
	Local oBrowse
	Private lCopy := .F.

	If !GFECheckGX4()
		Return .F.
	EndIF
	
	If !GFEA510COMP()
		MsgStop( "Necess�rio aplicar o update U_GFE11I20 para utilizar o processo de p�tios e portarias." )
		Return .F.
	EndIf
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GVC")				//Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA510")		//Nome do fonte onde esta a fun��o MenuDef
	oBrowse:SetDescription(STR0001) //"Opera��es"
	oBrowse:Activate()
Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona bot�es do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA510" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA510" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA510" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA510" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0007 ACTION "GFEA510CPY()"    OPERATION 6 ACCESS 0 //"Copiar"
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEA510" OPERATION 8 ACCESS 0 //"Imprimir"
	
Return aRotina

//-------------------------------------------------------------------

Static Function ModelDef()
	Local oModel
	Local oStructGVC := FWFormStruct(1,"GVC")
	
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost   Code-Block de valida��o do formul�rio de edi��o
	// bCommit Code-Block de persist�ncia do formul�rio de edi��o
	// bCancel Code-Block de cancelamento do formul�rio de edi��o
	oModel := MPFormModel():New("GFEA510", /*bPre*/, {|oModel| GFEA510POS(oModel)}/*bPost*/, /*bCommit*/, /*bCancel*/)
	
	oStructGVC:setProperty("GVC_CDOPER",MODEL_FIELD_WHEN,{||INCLUI})		
	
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost        Code-Block de valida��o do formul�rio de edi��o
	// bLoad        Code-Block de carga dos dados do formul�rio de edi��o	
	oModel:AddFields("GFEA510_GVC", Nil, oStructGVC,/*bPre*/,/*bPost*/,/*bLoad*/)	
	oModel:SetPrimaryKey({"GVC_FILIAL", "GVC_CDOPER"})
			
	oModel:SetActivate( {|oMod| GFEA510ACT(oMod)} )
	
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA510")
	Local oView  := Nil
	Local oStruct := FWFormStruct(2,"GVC")


	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,S� � necess�ri o caso estamos mundando o ID no View.
	oView:AddField( "GFEA510_GVC" , oStruct, /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 100, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA510_GVC" , "MASTER" )
	
Return oView

//--------------------------------------------------------------------- 
  
Function GFEA510ACT(oModel)
Local nI
Local oModelGVC  := oModel:GetModel("GFEA510_GVC")
Local aFieldsGVC := oModelGVC:GetStruct():aFields
Local aCmp       := {"GVC_SENTID","GVC_VINCPC","GVC_OBS"}

If IsInCallStack("GFEA510") .And. lCopy

	For nI := 1 To Len(aFieldsGVC)
		If aFieldsGVC[nI][14]
			Loop
		ElseIf aScan( aCmp, { |x| x == aFieldsGVC[nI][3] } ) > 0 .And. !Empty(&("GVC->"+aFieldsGVC[nI][3]))
			oModelGVC:SetValue(aFieldsGVC[nI][3], &("GVC->"+aFieldsGVC[nI][3]))
		Else
			oModel:ClearField("GFEA510_GVC",aFieldsGVC[nI][3])
		EndIf
	Next nI     
	
	lCopy := .F.

EndIf

Return

//---------------------------------------------------------------------

Function GFEA510CPY()

	lCopy := .T.

	FWExecView(STR0009,"GFEA510",3,,{|| .T.}) //"C�pia"

Return

Function GFEA510COMP() 
Return .T.
 
Function GFEA510POS(oModel)

	Local nOpc    := (oModel:GetOperation())
	Local cVincPC := FwFldGet("GVC_VINCPC")
	Local cGVC_CDOPER := FwFldGet("GVC_CDOPER")

	
	
	If nOpc == MODEL_OPERATION_UPDATE
		If cVincPC == "2"
		
			dbSelectArea("GVJ")
			GVJ->( dbSetOrder(1) )
			If GVJ->( dbSeek(GVI->(xFilial("GVJ")+cGVC_CDOPER)) )
				Help( ,, 'HELP',,"N�o � poss�vel o v�nculo de ponto de controle para N�o. Existem configura��es desta opera��o com pontos de controle cadastrados.", 1, 0)
				Return .F.
			EndIf
	
		EndIf
	EndIf
	
	If nOpc == MODEL_OPERATION_DELETE
	
		dbSelectArea("GVI")
		GVI->( dbSetOrder(1) ) 
		If GVI->( dbSeek(xFilial("GVI")+cGVC_CDOPER) )
			Help( ,, 'HELP',,"N�o � poss�vel realizar a exclus�o pois existe configura��o de opera��o cadastrado com esta opera��o.", 1, 0)
			Return .F.
		EndIf
	
	EndIf

Return .T.
