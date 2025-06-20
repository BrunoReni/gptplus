#INCLUDE "GFEA091.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*-------------------------------------------------------------------
{Protheus.doc} GFEA091

Contas Cont�beis por Filial

@author Jorge Matos Valcanaia
@since 15/11/09
@version 1.0
-------------------------------------------------------------------*/

Function GFEA091()
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GUS")			// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA091")	// Nome do fonte onde esta a fun��o MenuDef
	oBrowse:SetDescription(STR0001)	// Descri��o do browse //"Contas Cont�beis por Filial"
	oBrowse:Activate()
Return Nil

//-------------------------------------------------------------------

Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA091" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA091" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA091" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA091" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA091" OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina

//-------------------------------------------------------------------

Static Function ModelDef()
	Local oModel
	Local oStructGUS := FWFormStruct(1,"GUS")
	
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost   Code-Block de valida��o do formul�rio de edi��o
	// bCommit Code-Block de persist�ncia do formul�rio de edi��o
	// bCancel Code-Block de cancelamento do formul�rio de edi��o
	oModel := MPFormModel():New("GFEA091", /*bPre*/, { |oX| GFEA091POS( oX ) }/*bPost*/, /*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost        Code-Block de valida��o do formul�rio de edi��o
	// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
	oModel:AddFields("GFEA091_GUS", Nil, oStructGUS,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GUS_FILIAL"},{"GUS_FILCTB"})
	oModel:SetVldActivate({ |oX| GFEA091DEL( oX ) }) 
	
Return oModel

//------------------------------------------------

Static Function ViewDef()
	Local oModel     := FWLoadModel("GFEA091")
	Local oStructGUS := FWFormStruct(2,"GUS")
	Local oView      := Nil
	
	oStructGUS:AddGroup("GrpFil", "Filial"    , "", 2) // "Identifica��o"
	oStructGUS:AddGroup("GrpPro", "Provis�o"  , "", 2) // "C�lculo de Frete"
	oStructGUS:AddGroup("GrpRlz", "Realiza��o", "", 2) // "Motoristas e Ve�culos"
	oStructGUS:AddGroup("GrpCst", "Custo", "", 2) // "Motoristas e Ve�culos"
	
	oStructGUS:SetProperty("GUS_FILCTB", MVC_VIEW_GROUP_NUMBER, "GrpFil")
	
	oStructGUS:SetProperty("GUS_CTTRIC", MVC_VIEW_GROUP_NUMBER, "GrpPro")
	oStructGUS:SetProperty("GUS_DSCTTI", MVC_VIEW_GROUP_NUMBER, "GrpPro")
	oStructGUS:SetProperty("GUS_CCTRIC", MVC_VIEW_GROUP_NUMBER, "GrpPro")
	oStructGUS:SetProperty("GUS_DCCTIC", MVC_VIEW_GROUP_NUMBER, "GrpPro")
	oStructGUS:SetProperty("GUS_CTTRPI", MVC_VIEW_GROUP_NUMBER, "GrpPro")
	oStructGUS:SetProperty("GUS_DSCTTP", MVC_VIEW_GROUP_NUMBER, "GrpPro")
	oStructGUS:SetProperty("GUS_CCTRPI", MVC_VIEW_GROUP_NUMBER, "GrpPro")
	oStructGUS:SetProperty("GUS_DCCTPI", MVC_VIEW_GROUP_NUMBER, "GrpPro")
	oStructGUS:SetProperty("GUS_CTTRCO", MVC_VIEW_GROUP_NUMBER, "GrpPro")
	oStructGUS:SetProperty("GUS_DSCTTC", MVC_VIEW_GROUP_NUMBER, "GrpPro")
	oStructGUS:SetProperty("GUS_CCTRCO", MVC_VIEW_GROUP_NUMBER, "GrpPro")
	oStructGUS:SetProperty("GUS_DCCTCO", MVC_VIEW_GROUP_NUMBER, "GrpPro")
	
	oStructGUS:SetProperty("GUS_CTICMS", MVC_VIEW_GROUP_NUMBER, "GrpRlz")
	oStructGUS:SetProperty("GUS_DSCTIC", MVC_VIEW_GROUP_NUMBER, "GrpRlz")
	oStructGUS:SetProperty("GUS_CCICMS", MVC_VIEW_GROUP_NUMBER, "GrpRlz")
	oStructGUS:SetProperty("GUS_DSCCIC", MVC_VIEW_GROUP_NUMBER, "GrpRlz")
	oStructGUS:SetProperty("GUS_CTPIS" , MVC_VIEW_GROUP_NUMBER, "GrpRlz")
	oStructGUS:SetProperty("GUS_DSCTPI", MVC_VIEW_GROUP_NUMBER, "GrpRlz")
	oStructGUS:SetProperty("GUS_CCPIS" , MVC_VIEW_GROUP_NUMBER, "GrpRlz")
	oStructGUS:SetProperty("GUS_DSCCPI", MVC_VIEW_GROUP_NUMBER, "GrpRlz")
	oStructGUS:SetProperty("GUS_CTCOFI", MVC_VIEW_GROUP_NUMBER, "GrpRlz")
	oStructGUS:SetProperty("GUS_DSCOFI", MVC_VIEW_GROUP_NUMBER, "GrpRlz")
	oStructGUS:SetProperty("GUS_CCCOFI", MVC_VIEW_GROUP_NUMBER, "GrpRlz")
	oStructGUS:SetProperty("GUS_DSCCCO", MVC_VIEW_GROUP_NUMBER, "GrpRlz")
	
	oStructGUS:SetProperty("GUS_CTFRET", MVC_VIEW_GROUP_NUMBER, "GrpCst")
	oStructGUS:SetProperty("GUS_DSCTFR", MVC_VIEW_GROUP_NUMBER, "GrpCst")
	oStructGUS:SetProperty("GUS_CCFRET", MVC_VIEW_GROUP_NUMBER, "GrpCst")
	oStructGUS:SetProperty("GUS_DSCCFR", MVC_VIEW_GROUP_NUMBER, "GrpCst")
	
	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,S� � necess�ri o caso estamos mundando o ID no View.
	oView:AddField( "GFEA091_GUS" , oStructGUS, /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA091_GUS" , "MASTER" )   

Return oView

/*-------------------------------------------------------------------
{Protheus.doc} GFEA091DEL

Valida se a conta contabil esta relacionada com uma Conta Contabil por Filial ou se ela esta sendo
usada em uma Conta Contabil por Grupo

@author Jorge Matos Valcanaia
@since 15/12/09
@version 1.0
-------------------------------------------------------------------*/

Function GFEA091DEL(oModel)
	Local lRet := .T.
	Local nOpc := (oModel:GetOperation())
	
	If nOpc == 5
		
		dbSelectArea("GWA")
		dbSetOrder(1)
		If dbSeek(GUS->GUS_FILCTB)
			Help( ,, 'HELP',, STR0008, 1, 0) //"Conta Cont�bil por Filial esta sendo utilizada por algum Movimento a mesma n�o pode ser exclu�da"
			lRet := .F.		
		EndIf
			
	EndIf  
                                                                                         
Return (lRet)   

/*-------------------------------------------------------------------
{Protheus.doc} GFEA091POS

Valida��o de P�s inclus�o 

@author Felipe Rafael Mendes
@since 24/04/10
@version 1.0
-------------------------------------------------------------------*/

Function GFEA091POS(oModel)
	Local lRet := .T.
	Local nOpc      := (oModel:GetOperation())
	
	If nOpc == MODEL_OPERATION_INSERT
		
	    DbSelectArea('GUS')	
		Chkfile( 'GUS',,'GUSBF')
	    DbSelectArea('GUSBF')
	    DbSetOrder(01)
	    If dbSeek(xFilial('GUS')+oModel:GetValue('GFEA091_GUS','GUS_FILCTB'))
	 		Help(,,'HELP',, STR0009,1,0) //"Filial de Contabiliza��o j� possui informa��es de contas cont�beis cadastradas"
			lRet:= .F.
		EndIf
		GUSBF->( dbCloseArea() )
	EndIf

Return lRet

//-------------------------------------------------------------------

Function GFEA91REL()
	Local cVar := ReadVar()
	Local cCmp := SubStr(cVar,4)
	Local cTp  := SubStr(cVar,8,2)
	Local cNm  := SubStr(cVar,10)
	
	If "GUS_CTPROV" $ cVar
		cNm := "CTPR"
	ElseIf "GUS_CCCTPR" $ cVAr
		cNm := "PROV"
	EndIf
	
	If Vazio()
		Return .T.
	EndIf
	
	If cTp == "CC"
		
		GUH->( dbSetOrder(1) )
		If GUH->( dbSeek(xFilial("GUH") + FwFldGet(cCmp)) )
			If GUH->GUH_SIT == "2"
				Help( ,, 'HELP',, "O Centro de Custo est� inativo.", 1, 0) //"O Centro de Custo est� inativo."
				Return .F.
			EndIf
		Else		 
			Help( ,, 'HELP',, STR0010, 1, 0) //"O Centro de Custo n�o existe."
			Return .F.
		EndIf
		
		If GFXCPUSO(cCmp) .And. !Empty(FwFldGet("GUS_CT"+cNm))	
			GUM->( dbSetOrder(1) )
			If !GUM->( dbSeek(xFilial("GUM") + FwFldGet(cCmp) + FwFldGet("GUS_CT"+cNm)) )
				Help( ,, 'HELP',, STR0011, 1, 0) //"O Centro de Custo n�o possui relacionamento com a Conta Cont�bil no cadastro de Centro de Custo."
				Return .F.
			EndIf
			
		EndIf
		
	Else
	

		GUE->( dbSetOrder(1) )
		If GUE->( dbSeek(xFilial("GUE") + FwFldGet(cCmp)) )
			If GUE->GUE_SIT == "2"
				Help( ,, 'HELP',, "A Conta Cont�bil est� inativa.", 1, 0) //"A Conta Cont�bil est� inativa."
				Return .F.
			EndIf
		Else
			Help( ,, 'HELP',, STR0012, 1, 0) //"A Conta Cont�bil n�o existe."
			Return .F.
		EndIf        
		

		If GFXCPUSO(cCmp) .And. !Empty(FwFldGet("GUS_CC"+cNm))
		
			GUM->( dbSetOrder(1) )
			If !GUM->( dbSeek(xFilial("GUM") + FwFldGet("GUS_CC"+cNm) + FwFldGet(cCmp)) )
				Help( ,, 'HELP',, STR0013, 1, 0) //"A Conta Cont�bil n�o est� relacionada ao Centro de Custo no cadastro de Centro de Custo."
				Return .F.
			EndIf
			
		EndIf
		
	EndIf

Return .T.
          
//-------------------------------------------------------------------

Function GFEA91FIL()

	dbSelectArea("SM0")
	SM0->( dbSetOrder(1) )
	SM0->( dbGoTop() )
	
	While !SM0->( Eof() )
		
		If AllTrim(SM0->M0_CODFIL) == AllTrim(FwFldGet("GUS_FILCTB"))
			Return .T.
		EndIf
		
		SM0->( dbSkip() )
	EndDo

	Help( ,, 'HELP',, STR0014, 1, 0) //"A Filial informada n�o existe."

Return .F.
