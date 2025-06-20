#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA281.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA281
Rotina para manuten��o tabela GYF - Par�metros

@author MRW Solutions
@since 24/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GTPA281()

Local oGA281Brow

If ( !FindFunction("GTPHASACCESS") .Or.; 
	( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

	oGA281Brow := FWMBrowse():New()

	oGA281Brow:SetAlias("GYF")
	oGA281Brow:SetDescription(STR0001)	//"Par�metros do M�dulo"
	oGA281Brow:DisableDetails()
	oGA281Brow:SetMenuDef("GTPA281")
	oGA281Brow:Activate()

EndIf

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Fun��o para exibir o menu de op��es da rotina.

@sample	MenuDef()
 
@return	aRotina - Array
 
@author	Marcos Dias -  Inova��o
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.GTPA281' OPERATION 2 ACCESS 0	//'Visualizar'
ADD OPTION aRotina TITLE STR0003 ACTION 'GA281PRECD()' 	  OPERATION 4 ACCESS 0	//'Preenche Cont.'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.GTPA281' OPERATION 3 ACCESS 0	//'Incluir'
ADD OPTION aRotina TITLE "Reprocessa" ACTION 'GTP281REP()' OPERATION 3 ACCESS 0	//'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.GTPA281' OPERATION 5 ACCESS 0	//'Excluir'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.GTPA281' OPERATION 8 ACCESS 0	//'Imprimir'

Return aRotina

/*/{Protheus.doc} GTP281REP
(long_description)
@type  Function
@author user
@since 14/06/2022
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTP281REP()
	FwMsgRun( ,{||LoadParamRules()},,"Verificando parametros do Modulo...")
Return 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Fun��o para exibir o modelo de dados.
 
@sample	ModelDef()
 
@return	oModel - objeto model.
 
@author	Marcos Dias -  Inova��o
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
Local oModel 
Local oStruGYF := FWFormStruct( 1,'GYF')

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('GTPA281')

// habilita/desabilita inclus�o / altera��o nos campos
oStruGYF:SetProperty('GYF_PARAME' , MODEL_FIELD_WHEN, {|oSubMdl| oSubMdl:GetOperation() == MODEL_OPERATION_INSERT })
oStruGYF:SetProperty('GYF_TIPO'   , MODEL_FIELD_WHEN, {|oSubMdl| oSubMdl:GetOperation() == MODEL_OPERATION_INSERT })
oStruGYF:SetProperty('GYF_CPX3'   , MODEL_FIELD_WHEN, {|oSubMdl|oSubMdl:GetOperation() == MODEL_OPERATION_INSERT .AND. FwFldGet('GYF_TIPO')=='1'})
oStruGYF:SetProperty('GYF_DESCRI' , MODEL_FIELD_WHEN, {|oSubMdl|oSubMdl:GetOperation() == MODEL_OPERATION_INSERT})
oStruGYF:SetProperty('GYF_PICTUR' , MODEL_FIELD_WHEN, {|oSubMdl|oSubMdl:GetOperation() == MODEL_OPERATION_INSERT .And. FwFldGet('GYF_TIPO')$'1.2'})
If !IsInCallStack('GTPA019') .And. !IsInCallStack('GTPA026')
	oStruGYF:SetProperty('GYF_CONTEU' , MODEL_FIELD_WHEN, {|oSubMdl|oSubMdl:GetOperation() == MODEL_OPERATION_UPDATE})
EndIf
oStruGYF:SetProperty('GYF_GRUPO'  , MODEL_FIELD_WHEN, {|oSubMdl|oSubMdl:GetOperation() == MODEL_OPERATION_INSERT})

oStruGYF:SetProperty('GYF_PARAME' , MODEL_FIELD_VALID, {|oModel|GTPA281B(oModel)})
oStruGYF:SetProperty('GYF_CONTEU' , MODEL_FIELD_VALID, {|oModel|GTPA281C(oModel)})

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields( 'GYFMASTER', /*cOwner*/, oStruGYF, { |oMdlFld,cAction,cCampo,cConteudo| GA281SXB(oMdlFld,cAction,cCampo,cConteudo)} )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0007 )	//'Par�metros do M�dulo'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'GYFMASTER' ):SetDescription( 'GYF' )

oModel:SetPrimaryKey( {} )

Return(oModel)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Fun��o para exibir a view de dados.
 
@sample	ViewDef()
 
@return	oView - objeto view.
 
@author	Marcos Dias -  Inova��o
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := ModelDef()
Local oView := Nil
Local oStruGYF := FWFormStruct( 2, 'GYF' )
Local _aSXB := SeleF3()

// Seta proriedade ComboBox
oStruGYF:SetProperty("GYF_CPX3",MVC_VIEW_COMBOBOX,_aSXB)

oStruGYF:SetProperty("GYF_CONTEU", MVC_VIEW_ORDEM,'08')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_GYF', oStruGYF, 'GYFMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_GYF', 'TELA' )

Return(oView)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA281PRECD()
Fun��o para execu��o da fun��o de preenchimento da consuta padr�o.

Programa de cancelamento de bilhetes.
 
@sample	GA281PRECD()

@return	lRet - l�gico.
 
@author	Marcos Dias -  Inova��o
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GA281PRECD()
	Local lRet := .F.
	lRet := FwExecView("PREENCTD","GTPA281A",MODEL_OPERATION_UPDATE)
Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA281SXB()
Fun��o para carregar o c�digo da consulta padr�o sem a descri��o da mesma.
 
@sample	GA281SXB()

@return	lRet - l�gico.
 
@author	Marcos Dias -  Inova��o
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GA281SXB(oMdlFld,cAction,cCampo,cConteudo)

	If AllTrim(cCampo) == "GYF_CPX3" .And. Upper(cAction) == "SETVALUE" .and. !Empty(cConteudo)
		
		oMdlFld:LoadValue("GYF_CPX3",Left(cConteudo,6))
		
	EndIf

Return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA281B()
Fun��o para verificar se o par�metro j� n�o est� cadastrado

@sample	GTPA281B()

@return	lRet - l�gico.
 
@author	Marcos Dias -  Inova��o
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GTPA281B(oModel)

LOCAL lRet := .T.

Local nOperation := oModel:GetOperation()

// Valida se pode ou n�o apagar uma linha do Grid
If nOperation == MODEL_OPERATION_INSERT

	If GYF->(DbSeek(xFilial("GYF")+FwFldGet('GYF_PARAME')))
		Help( ,, 'Help',, STR0008, 1, 0 )	//"Par�metro j� cadastrado!"
		lRet := .F.
	EndIf  
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA281C()
Fun��o para validar o dado tipo booleano

@sample	GTPA281C()

@return	lRet - l�gico.
 
@author	Marcos Dias -  Inova��o
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GTPA281C(oModel)

LOCAL lRet := .T.

If oModel:GetValue('GYF_TIPO') == '3' // Boolean 

	If Len(Upper(AllTrim(oModel:GetValue('GYF_CONTEU')))) # 3
		Help( ,, 'Help',, STR0009, 1, 0 )	//"Valor inv�lido! Digite .T. ou .F. !"
		lRet := .F.
	ElseIf Upper(AllTrim(oModel:GetValue('GYF_CONTEU'))) <> ".T."
		If Upper(AllTrim(oModel:GetValue('GYF_CONTEU'))) <> ".F."
			Help( ,, 'Help',, STR0009, 1, 0 )	//"Valor inv�lido! Digite .T. ou .F. !"
			lRet := .F.
		EndIf
	EndIf
	
ElseIf oModel:GetValue('GYF_TIPO') == '2' // Caractere
	If Type(AllTrim(oModel:GetValue('GYF_CONTEU'))) <> "N" 
			Help( ,, 'Help',, STR0010, 1, 0 )	//"Valor inv�lido! Digite apenas valores num�ricos."
			lRet := .F.
	EndIf
EndIf

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GPA281PAR()
Fun��o para retornar o conte�do de um par�metro

@sample	GTPA281C()

@return	lRet - l�gico.
 
@author	Marcos Dias -  Inova��o
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GPA281PAR(cParamGYF)

LOCAL cCont := ""

GYF->(dbSetOrder(1))
If GYF->( DbSeek( xFilial("GYF")+PadR( cParamGYF,TamSX3("GYF_PARAME")[1])))
	cCont := GYF->GYF_CONTEU
EndIf

Return(AllTrim(cCont))