#INCLUDE "ESTA0001.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} ESTA0001
Cadastro Fator de Conversao Unidade de Medida (Modelo 2)

@since 01/08/2022
@version P12
@author Adriano Vieira
*/
//-------------------------------------------------------------------
Function ESTA0001()
Local oBrowse
Local aErrorMsg

aErrorMsg := ESTAD3Q()

If(Len(aErrorMsg) > 0)
    ESTADlg(aErrorMsg)
Else
	D3Q->(dbSetOrder(1))

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'D3Q' )
	oBrowse:SetDescription( STR0001 )
	oBrowse:Activate()
EndIf

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Monta opcoes de rotina do programa

@since 01/08/2022
@version P12
@author Adriano Vieira
*/
//-------------------------------------------------------------------
Static Function MenuDef() 

Private aRotina := {}

ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.ESTA0001" OPERATION MODEL_OPERATION_VIEW	ACCESS 0 //"Visualizar"	
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.ESTA0001" OPERATION MODEL_OPERATION_INSERT	ACCESS 0 //"Incluir"		
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.ESTA0001" OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 //"Alterar"		
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.ESTA0001" OPERATION MODEL_OPERATION_DELETE	ACCESS 3 //"Excluir"	

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados Fator de Conversao de Medida

@since 01/08/2022
@version P12
@author Adriano Vieira
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 	:= NIL
Local oStruD3Q	:= FWFormStruct(1,'D3Q',{|cCampo| AllTRim(cCampo) $ "D3Q_PROD"})
Local oStruGrid := FWFormStruct(1,'D3Q',{|cFields| AllTRim(cFields) $ "D3Q_ITEM|D3Q_UNICOM|D3Q_FATOR"})

oStruD3Q:AddField(   STR0010			,;	// 	[01]  C   Titulo do campo
					 STR0010			,;	// 	[02]  C   ToolTip do campo
					 "D3Q_DESCPR"		,;	// 	[03]  C   Id do Field
					 "C"				,;	// 	[04]  C   Tipo do campo
					 TamSX3("B1_DESC")[1],;	// 	[05]  N   Tamanho do campo
					 0					,;	// 	[06]  N   Decimal do campo
					 NIL                ,;	// 	[07]  B   Code-block de validacao do campo
					 NIL				,;	// 	[08]  B   Code-block de validacao When do campo
					 NIL				,;	//	[09]  A   Lista de valores permitido do campo
					 .F.				,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "IniPadProd()")	,;  // [11] BCode-block de inicializacao do campo
					 NIL				,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL				,;	//	[13]  L   Indica se o campo pode receber valor em uma operacao de update.
					 .T.				)	// 	[14]  L   Indica se o campo e virtual

aAux :=    FwStruTrigger("D3Q_PROD","D3Q_DESCPR","POSICIONE('SB1',1,xFilial('SB1')+FWFldGet('D3Q_PROD') ,'B1_DESC')")

oStruD3Q:AddTrigger(	aAux[1],; // [01] Id do campo de origem
                        aAux[2],; // [02] Id do campo de destino
                        aAux[3],; // [03] Bloco de codigo de validacao da execucao do gatilho
                        aAux[4])  // [04] Bloco de codigo de execucao do gatilho


oStruD3Q:AddField(   STR0008			,;	// 	[01]  C   Titulo do campo
					 STR0008			,;	// 	[02]  C   ToolTip do campo
					 "D3Q_UNIEST"		,;	// 	[03]  C   Id do Field
					 "C"				,;	// 	[04]  C   Tipo do campo
					 TamSX3("AH_UNIMED")[1],;//	[05]  N   Tamanho do campo
					 0					,;	// 	[06]  N   Decimal do campo
					 NIL                ,;	// 	[07]  B   Code-block de validacao do campo
					 NIL				,;	// 	[08]  B   Code-block de validacao When do campo
					 NIL				,;	//	[09]  A   Lista de valores permitido do campo
					 .F.				,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "IniPadUM()")	,;  // [11] BCode-block de inicializacao do campo
					 NIL				,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL				,;	//	[13]  L   Indica se o campo pode receber valor em uma operacao de update.
					 .T.				)	// 	[14]  L   Indica se o campo e virtual

aAux :=    FwStruTrigger("D3Q_PROD","D3Q_UNIEST","POSICIONE('SB1',1,xFilial('SB1')+FWFldGet('D3Q_PROD') ,'B1_UM')")

oStruD3Q:AddTrigger(	aAux[1],; // [01] Id do campo de origem
                        aAux[2],; // [02] Id do campo de destino
                        aAux[3],; // [03] Bloco de codigo de validacao da execucao do gatilho
                        aAux[4])  // [04] Bloco de codigo de execucao do gatilho

oModel := MPFormModel():New('ESTA0001', /*bPreValidacao*/,{|oModel|AESTVldGrv(oModel)}/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
oModel:SetDescription(STR0002)

oModel:AddFields('D3QMASTER',/*cOwner*/,oStruD3Q,{|a,b,c,d| PreVldField(a,b,c,d)})
oModel:AddGrid('D3QDETAILS','D3QMASTER',oStruGrid,/*{|a,b,c,d,e,f| PreVldGrid(a,b,c,d,e,f)}*/)

oModel:GetModel("D3QDETAILS"):SetUseOldGrid()
oModel:SetPrimaryKey({"D3Q_PROD"})

oModel:SetRelation('D3QDETAILS',{{'D3Q_FILIAL','xFilial("D3Q")'},{"D3Q_PROD","D3Q_PROD"}},D3Q->(IndexKey(1)))
oModel:GetModel("D3QDETAILS"):SetDelAllLine(.T.)

oModel:GetModel("D3QDETAILS"):SetUniqueLine({"D3Q_UNICOM"})

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'D3QMASTER' ):SetDescription( STR0003 )
oModel:GetModel( 'D3QDETAILS'):SetDescription( STR0009 )

Return oModel

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Interface do modelo de dados Fator Conversao de Medida

@since 01/08/2022
@version P12
@author Adriano Vieira
*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView		:= NIL
Local oModel	:= FWLoadModel('ESTA0001')
Local oStruD3Q  := FWFormStruct(2,"D3Q", {|cCampo| AllTRim(cCampo) $ "D3Q_PROD"})
Local oStruGRID := FWFormStruct(2,"D3Q", {|cFields| AllTRim(cFields) $ "D3Q_ITEM|D3Q_UNICOM|D3Q_FATOR"})

oView:= FWFormView():New() 
oView:SetModel(oModel)

oStruD3Q:AddField(  "D3Q_DESCPR"		,;	// [01]  C   Nome do Campo
					"02"				,;	// [02]  C   Ordem
					STR0010				,;	// [03]  C   Titulo do campo//"Descricao"
					STR0010				,;	// [04]  C   Descricao do campo//"Descricao"
					NIL					,;	// [05]  A   Array com Help
					"C"					,;	// [06]  C   Tipo do campo
					"@!"				,;	// [07]  C   Picture
					NIL					,;	// [08]  B   Bloco de Picture Var
					NIL					,;	// [09]  C   Consulta F3
					.F.					,;	// [10]  L   Indica se o campo e alteravel
					NIL					,;	// [11]  C   Pasta do campo
					NIL					,;	// [12]  C   Agrupamento do campo
					NIL					,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL					,;	// [14]  N   Tamanho maximo da maior opcao do combo
					NIL					,;	// [15]  C   Inicializador de Browse
					.T.					,;	// [16]  L   Indica se o campo e virtual
					NIL					,;	// [17]  C   Picture Variavel
					NIL					)	// [18]  L   Indica pulo de linha após o campo

oStruD3Q:AddField(  "D3Q_UNIEST"		,;	// [01]  C   Nome do Campo
					"03"				,;	// [02]  C   Ordem
					STR0008				,;	// [03]  C   Titulo do campo//"Descricao"
					STR0008				,;	// [04]  C   Descricao do campo//"Descricao"
					NIL					,;	// [05]  A   Array com Help
					"C"					,;	// [06]  C   Tipo do campo
					NIL					,;	// [07]  C   Picture
					NIL					,;	// [08]  B   Bloco de Picture Var
					NIL					,;	// [09]  C   Consulta F3
					.F.					,;	// [10]  L   Indica se o campo e alteravel
					NIL					,;	// [11]  C   Pasta do campo
					NIL					,;	// [12]  C   Agrupamento do campo
					NIL					,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL					,;	// [14]  N   Tamanho maximo da maior opcao do combo
					NIL					,;	// [15]  C   Inicializador de Browse
					.T.					,;	// [16]  L   Indica se o campo e virtual
					NIL					,;	// [17]  C   Picture Variavel
					NIL					)	// [18]  L   Indica pulo de linha após o campo

oView:showUpdateMsg(.F.)
oView:showInsertMsg(.F.)

oStruD3Q:SetProperty('D3Q_PROD', MVC_VIEW_ORDEM, '01')

oView:AddField('VIEW_D3Q', oStruD3Q, 'D3QMASTER')
oView:CreateHorizontalBox("MAIN",25)
oView:SetOwnerView('VIEW_D3Q','MAIN')

oView:AddGrid('GRID_D3Q', oStruGRID, 'D3QDETAILS' )
oView:CreateHorizontalBox("GRID",75)
oView:SetOwnerView('GRID_D3Q','GRID')

oView:EnableTitleView('VIEW_D3Q',"Cabecalho")
oView:EnableTitleView('GRID_D3Q',"Grid") 

oView:AddIncrementField( 'GRID_D3Q', 'D3Q_ITEM' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} aESTVldGrv
Validacao de linhas ativas no grid

@since 01/08/2022;
@version P12
@author Adriano Vieira
/*/
//-------------------------------------------------------------------
Static Function AESTVldGrv(oModel)

Local lRet	 	 := .T.
Local nCount 	 := 0
Local nI		 := 0
Local oModelGRID := oModel:GetModel('D3QDETAILS')

If lRet  
	For nI := 1 To oModelGRID:Length() 
		oModelGRID:GoLine(nI) 
		If oModelGRID:IsDeleted()
			nCount := (nCount+1)
		EndIf
	Next nI 

	If oModelGRID:length()==nCount
		lRet :=.F.
		Help(" ",1,STR0011,,STR0012,1,4, NIL, NIL, NIL, NIL, NIL, {STR0013})	
	EndIf
Endif

Return lRet

/*/{Protheus.doc} IniPadProd()
Inicializador padrao do campo descricao do produto
@author Adriano Vieira
@since 01/08/2022
@version 1.0
@return cDescri
/*/
Function IniPadProd()

Local oModel    := FWModelActive()
Local lInclui   := oModel:GetOperation() == MODEL_OPERATION_INSERT
Local aArea     := {}
Local cDescri   := ""

If !lInclui
    aArea := GetArea()
    SB1->(dbSetOrder(1))

    If SB1->(dbSeek( xFilial("SB1")+D3Q->D3Q_PROD))
        cDescri := Alltrim(SB1->B1_DESC)
    EndIf

    RestArea(aArea)
EndIf

Return cDescri

/*/{Protheus.doc} IniPadProd()
Inicializador padrao do campo Unidade de Estoque do produto
@author Adriano Vieira
@since 01/08/2022
@version 1.0
@return cDescri
/*/
Function IniPadUM()

Local oModel    := FWModelActive()
Local lInclui   := oModel:GetOperation() == MODEL_OPERATION_INSERT
Local aArea     := {}
Local cUm       := ""

If !lInclui
    aArea := GetArea()
    SB1->(dbSetOrder(1))

    If SB1->(dbSeek( xFilial("SB1")+D3Q->D3Q_PROD))
        cUM := Alltrim(SB1->B1_UM)
    EndIf
    RestArea(aArea)
EndIf

Return cUM


/*/{Protheus.doc} EstConvUM
//Componente que realizar o calculo do Fator de Conversao da UM
@author Adriano Vieira
@since 01/08/2022
@version 1.0
@return ${nFator}

@type function
/*/
Function EstConvUM(cProd,cUniCom,nQuant) 
    Local nFator := 0
    Local aArea := {}
	Local lD3QExist := AliasIndic('D3Q')
    
    Default cProd   := ""
    Default cUniCom	:= ""
    Default nQuant  := 0

    If !Empty(cProd) .AND. !Empty(cUniCom)
		IF lD3QExist
			aArea := GetArea()

			DbSelectArea('D3Q')
			D3Q->(dbSetOrder(1))
			
			If D3Q->(dbSeek( xFilial("D3Q")+PadR(cProd,TamSX3("D3Q_PROD")[1])+cUniCom))
	
				nFator := nQuant * D3Q->D3Q_FATOR

			EndIf

			RestArea(aArea)	
		EndIf
    EndIf
    
Return nFator

/*/{Protheus.doc} PreVldField
Valida edição de campo no Cabelhaco

@author Adriano Vieira
@since 01/08/2022
@version 1.0
/*/
Function PreVldField(oModel,cAction,cIdField,cProd)

Local lInclui   := oModel:GetOperation() == MODEL_OPERATION_INSERT
Local lAltera   := oModel:GetOperation() == MODEL_OPERATION_UPDATE
Local aArea 	:= {}
Local lRet  	:= .T.

If lInclui .OR. lAltera
	If cIdField == "D3Q_PROD" .AND. cAction == "SETVALUE"
		aArea := GetArea()
		D3Q->(dbSetOrder(1))

		If D3Q->(dbSeek( xFilial("D3Q")+cProd))
			lRet := .F.
			Help(" ",1,STR0014,,STR0015, 1, 0,,,,,,{STR0016})
		EndIf
		RestArea(aArea)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} ESTAD3Q
Metodo responsavel por verificar se as condições para iniciar a aplicação são validas

@since 01/08/2022
@version P12
@author Squad Entradas
*/
//-------------------------------------------------------------------
Function ESTAD3Q()
Local lD3QExist := AliasIndic('D3Q')
Local lRet		:= .F.
Local aError := {}

IF lD3QExist
	lRet := .T.
	If !TcCanOpen("D3Q")
		dbSelectArea("D3Q")
  	EndIf
Else
	AADD(aError, STR0017)
	lRet := .F.
EndIf

Return aError

//-----------------------------------------------------------
/*{Protheus.doc} ESTADlg 
Metodo responsavel por verificar se as condições para iniciar a aplicação são validas

@since 01/08/2022
@version P12
@author Squad Entradas
*/
//-------------------------------------------------------------------
Function ESTADlg(aErrorMsg)

Local nOpc := 0
Local cLink := "https://tdn.totvs.com/pages/viewpage.action?pageId=701678746"

nOpc := Aviso(STR0018, ESTAStr(aErrorMsg), { STR0019, STR0020 }, 3, "",, , .F.)

If nOpc == 1
    Return .F.
ElseIf nOpc == 2
    ShellExecute("open",cLink  ,"","",1)
Endif

Return

//-----------------------------------------------------------
/*{Protheus.doc} ESTAStr
Metodo responsavel por verificar se as condições para iniciar a aplicação são validas

@since 01/08/2022
@version P12
@author Squad Entradas
*/
//-------------------------------------------------------------------
Static Function ESTAStr(aErrorMsg)

Local nX := 1
Local cString := ''

For nX := 1 to Len(aErrorMsg)
    cString += aErrorMsg[nX] + CRLF
    cString += CRLF
Next nX

return cString
