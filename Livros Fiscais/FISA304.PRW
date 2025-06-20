#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA304.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} FISA304
Cadastro MVC para atender o cadastro de codigos de enquadramentos de IPI

@author Erich Buttner
@since 27.05.2020
@version P11

/*/
//-------------------------------------------------------------------
Function FISA304()

	Local   oBrowse := Nil
	Local 	 aArea   := GetArea()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("F08")
    oBrowse:SetDescription(STR0007)
	oBrowse:Activate()
			
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Erich Buttner
@since 27.05.2020
@version P11

/*/
//-------------------------------------------------------------------                                                                                            

Static Function MenuDef()

	Local aRotina := {}
	
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.FISA304' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA304' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA304' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA304' OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA304' OPERATION 9 ACCESS 0 //'Copiar'
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Erich Buttner
@since 27.05.2020
@version P11

/*/
//-------------------------------------------------------------------

Static Function ModelDef()
	//Cria��o do objeto do modelo de dados
	Local oModel	:= Nil
	
	//Cria��o da estrutura de dados utilizada na interface
	
	Local oStructF08 := FWFormStruct(1, "F08")
	
	//Instanciando o modelo
	oModel	:=	MPFormModel():New('FISA304MOD',/*Pre-Validacao*/,{ |oModel| ValidForm(oModel) }/*Pos-Validacao*/, {|oModel| GravaSYP(oModel) }/*Commit*/,/*Cancel*/ )	
	
	//Tornando o campo c�digo da CEST para obrigatorio na inclus�o
	oStructF08:SetProperty('F08_CODIGO' , MODEL_FIELD_OBRIGAT, .T. )
	
	//Bloqueando o c�digo da CEST para edi��o
	oStructF08:SetProperty('F08_CODIGO' , MODEL_FIELD_WHEN,  {|| (oModel:GetOperation()==3) } )
	
	//Atribuindo formul�rios para o modelo
	oModel:AddFields('FISA304MOD' ,, oStructF08 )	

	//Setando a chave prim�ria da rotina
	oModel:SetPrimaryKey({"F08_FILIAL"},{"F08_CODIGO"},{"F08_DESCRV"},{"F08_DESCR2"})	
	
	//Adicionando descri��o ao modelo
	oModel:SetDescription(STR0007) //CEST - C�digo Especificador da Substitui��o Tribut�ria
	
	//Setando a descri��o do formul�rio
	oModel:GetModel('FISA304MOD'):SetDescription(STR0009)
		
Return oModel 


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Erich Buttner
@since 27.05.2020
@version P11

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	//Cria��o do objeto do modelo de dados da Interface do Cadastro
	Local oModel     := FWLoadModel( "FISA304" )
	
	//Cria��o da estrutura de dados utilizada na interface do cadastro
	
	Local oStructF08 := FWFormStruct(2, "F08")
	
	//Criando oView como nulo
	Local oView := Nil
	
	//Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	//Atribuindo formul�rios para interface
	oView:AddField( "VIEW" , oStructF08 , 'FISA304MOD')
	
	//Remove os campos que n�o ir�o aparecer	
	oStructF08:RemoveField( 'F08_DESCRI' )
	oStructF08:RemoveField( 'F08_DESCR2' )
	
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox( "TELA" , 100 )
	
	//Colocando t�tulo do formul�rio
    oView:EnableTitleView('VIEW', 'Dados do CEST' )
    
    //For�a o fechamento da janela na confirma��o
    oView:SetCloseOnOk({||.T.})
     
    //O formul�rio da interface ser� colocado dentro do container
    oView:SetOwnerView("VIEW","TELA")	
	
Return oView


//-------------------------------------------------------------------

/*/{Protheus.doc} ValidForm
Valida��o das informa��es digitadas no form.

@author Erich Buttner
@since 27.05.2020
@version P11

/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

	Local lRet			:=	.T.
	Local cCod			:=	oModel:GetValue ('FISA304MOD','F08_CODIGO')	
	Local nOper 	:=	oModel:GetOperation()
	Local aArea    := GetArea()
	Local nTam 	:= TamSX3("F08_DESCRI")
	
	If nOper == 3 
		F08->(DbSetOrder (1))
		If F08->(DbSeek(xFilial("F08")+cCod))						
			Help("",1,"Help","Help",STR0008,1,0) //J� existe registro com esses dados
			lRet := .F.
		EndIF		
		
		RestArea(aArea)
				
		// Fun��o MSMM, para gravar o campo memo na tabela SYP
		If	lRet			
			oModel:SetValue ('FISA304MOD','F08_DESCRI', SubStr( oModel:GetValue ('FISA304MOD','F08_DESCRV'), 1, nTam[1] ) )
			FWFormCommit( oModel )
		EndIf		
	ElseIf nOper == 4	
			MSMM(F08->F08_DESCR2,,,oModel:GetValue ('FISA304MOD','F08_DESCRV'),1,,,"F08","F08_DESCR2")
			oModel:SetValue ('FISA304MOD','F08_DESCRI', SubStr( oModel:GetValue ('FISA304MOD','F08_DESCRV'), 1, nTam[1] ) )
			FWFormCommit( oModel )				
	ElseIf nOper == 5
			MSMM(F08->F08_DESCR2,,,oModel:GetValue ('FISA304MOD','F08_DESCRV'),2,,,"F08","F08_DESCR2")
			FWFormCommit( oModel )				
	EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaSYP
Fun��o para fazer a grava��o do campo MEMO do formul�rio

@author Erich Buttner
@since 27.05.2020
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function GravaSYP(oModel)

Local lRet			:=	.T.
Local nOperation 	:=	oModel:GetOperation()

IF	nOperation == 3 // Inclus�o 
	MSMM(,,,oModel:GetValue ('FISA304MOD','F08_DESCRV'),1,,,"F08","F08_DESCR2")	
EndIF

Return lRet  
