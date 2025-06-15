#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA028.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA028
Cadastro de Naturezas de Rendimentos,
para atender o EFD-REINF, na familia de eventos 4000.

@author		Vinicius do Prado
@since		21/02/2019
@version	1
@return		NIL
/*/
//-------------------------------------------------------------------

Function FINA028()

	Local oBrowse As Object

	If AliasInDic("FKX") .and. cPaisLoc=="BRA"
		DbSelectArea("FKX")
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('FKX')
		oBrowse:SetDescription(STR0001) //'Natureza de Rendimento'

		oBrowse:Activate()
	Else
		Help( , , "FINA028", , STR0006, 1, 0, , , , , , { STR0007 } )	// STR0006 "Aten��o! Tabela Natureza de Rendimento(FKX) n�o existe." STR0007 "Atualizar o Dicionario de Dados."
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta o menu de acordo com o array aRotina

@author		Vinicius do Prado
@since		21/02/2019
@version	1
@return		aRotina - Array contendo as op��es de menu
/*/
//-------------------------------------------------------------------

Static Function MenuDef() As Array 

	Local aRotina As Array

	aRotina := {}

	ADD OPTION aRotina Title STR0002	Action 'VIEWDEF.FINA028' OPERATION 2 ACCESS 0	//'Visualizar'
	ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.FINA028' OPERATION 3 ACCESS 0	//'Incluir'
	ADD OPTION aRotina Title STR0004	Action 'VIEWDEF.FINA028' OPERATION 4 ACCESS 0	//'Alterar'
	ADD OPTION aRotina Title STR0005	Action 'VIEWDEF.FINA028' OPERATION 5 ACCESS 0	//'Excluir'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Fun��o responsavel pela montagem do modelo de dados

@author		Vinicius do Prado
@since		21/02/2019
@version	1
@return		oModel - objeto do modelo de dados
/*/
//-------------------------------------------------------------------

Static Function ModelDef() As Object

	Local oStruFKX	As Object
	Local oStruFKZD	As Object
	Local oStruFKZI	As Object
	Local oModel	As Object
	Local aRltDed	As Array
	Local aRltIse	As Array
	Local aAux		As Array

	oStruFKX	:= FWFormStruct( 1, 'FKX' )
	oStruFKZD	:= FWFormStruct( 1, 'FKZ' )
	oStruFKZI	:= FWFormStruct( 1, 'FKZ' )
	aRltDed		:= {}
	aRltIse		:= {}
	aAux		:= {}

	oStruFKZD:AddField(	AllTrim(STR0009),;									// [01] C Titulo do campo //'Descri��o'
						AllTrim(STR0009),;									// [02] C ToolTip do campo //'Descri��o'
						'FKZ_DESCRD',;										// [03] C identificador (ID) do Field
						'C',;												// [04] C Tipo do campo
						240,;												// [05] N Tamanho do campo
						0,;													// [06] N Decimal do campo
						,;													// [07] B Code-block de valida��o do campo
						NIL,;												// [08] B Code-block de valida��o When do campo
						{},;												// [09] A Lista de valores permitido do campo
						NIL,;												// [10] L Indica se o campo tem preenchimento obrigat�rio
						,;													// [11] B Code-block de inicializacao do campo
						NIL,;												// [12] L Indica se trata de um campo chave
						NIL,;												// [13] L Indica se o campo pode receber valor em uma opera��o de update.
						.T. )												// [14] L Indica se o campo � virtual

	oStruFKZI:AddField(	AllTrim(STR0009),;									// [01] C Titulo do campo //'Descri��o'
						AllTrim(STR0009),;									// [02] C ToolTip do campo //'Descri��o'
						'FKZ_DESCRI',;										// [03] C identificador (ID) do Field
						'C',;												// [04] C Tipo do campo
						240,;												// [05] N Tamanho do campo
						0,;													// [06] N Decimal do campo
						,;													// [07] B Code-block de valida��o do campo
						NIL,;												// [08] B Code-block de valida��o When do campo
						{},;												// [09] A Lista de valores permitido do campo
						NIL,;												// [10] L Indica se o campo tem preenchimento obrigat�rio
						,;	// [11] B Code-block de inicializacao do campo
						NIL,;												// [12] L Indica se trata de um campo chave
						NIL,;												// [13] L Indica se o campo pode receber valor em uma opera��o de update.
						.T. )												// [14] L Indica se o campo � virtual

	oStruFKZD:SetProperty( 'FKZ_DESCRD', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'F028Des("D")' ) )
	oStruFKZI:SetProperty( 'FKZ_DESCRI', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'F028Des("I")' ) )
	oStruFKZD:SetProperty( 'FKZ_CODIGO', MODEL_FIELD_OBRIGAT, .F.)
	oStruFKZI:SetProperty( 'FKZ_CODIGO', MODEL_FIELD_OBRIGAT, .F.)
	oStruFKZD:SetProperty( 'FKZ_ISENCA', MODEL_FIELD_OBRIGAT, .F.)
	oStruFKZI:SetProperty( 'FKZ_DEDUCA', MODEL_FIELD_OBRIGAT, .F.)

	oStruFKZD:SetProperty( 'FKZ_DEDISE', MODEL_FIELD_OBRIGAT, .F.)
	oStruFKZI:SetProperty( 'FKZ_DEDISE', MODEL_FIELD_OBRIGAT, .F.)

	oStruFKZD:SetProperty( 'FKZ_DEDISE', MODEL_FIELD_INIT, { || "1" } )
	oStruFKZD:SetProperty( 'FKZ_ISENCA', MODEL_FIELD_INIT, { || "  " } )
	oStruFKZD:SetProperty( 'FKZ_DEDISE', MODEL_FIELD_WHEN, { || .F. } )

	oStruFKZI:SetProperty( 'FKZ_DEDISE', MODEL_FIELD_INIT, { || "2" } )
	oStruFKZI:SetProperty( 'FKZ_DEDUCA', MODEL_FIELD_INIT, { || "  " } )
	oStruFKZI:SetProperty( 'FKZ_DEDISE', MODEL_FIELD_WHEN, { || .F. } )

	aAux := FwStruTrigger("FKZ_DEDUCA" ,"FKZ_DESCRD" ,'Posicione("SX5",1,xFilial("SX5")+"0M"+M->FKZ_DEDUCA,"X5_DESCRI")',.F.,,,)
	oStruFKZD:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )

	aAux := {}
	aAux := FwStruTrigger("FKZ_ISENCA" ,"FKZ_DESCRI" ,'Posicione("SX5",1,xFilial("SX5")+"0K"+M->FKZ_ISENCA,"X5_DESCRI")',.F.,,,)
	oStruFKZI:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'FKXMODEL', /*bPreValidacao*/, /**/, /*bCommit*/, /*bCancel*/ )
	
	oModel:AddFields( 'FKXMASTER', /*cOwner*/, oStruFKX )

	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
	oModel:AddGrid( 'FKZDETAILD', 'FKXMASTER', oStruFKZD, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'FKZDETAILI', 'FKXMASTER', oStruFKZI, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0001 )//'Natureza de Rendimento'

	// Faz relaciomaneto entre os compomentes do model
	AAdd( aRltDed, { 'FKZ_FILIAL', 'xFilial( "FKZ" )' } )
	AAdd( aRltDed, { 'FKZ_CODIGO', 'FKX_CODIGO' } )
	AAdd( aRltDed, { 'FKZ_DEDISE', '"1"' } )

	AAdd( aRltIse, { 'FKZ_FILIAL', 'xFilial( "FKZ" )' } )
	AAdd( aRltIse, { 'FKZ_CODIGO', 'FKX_CODIGO' } )
	AAdd( aRltIse, { 'FKZ_DEDISE', '"2"' } )

	oModel:SetRelation( 'FKZDETAILD', aRltDed, FKZ->( IndexKey( 1 ) ) )	
	// Liga o controle de n�o repeti��o de linha
	oModel:GetModel( 'FKZDETAILD' ):SetUniqueLine( { 'FKZ_DEDUCA' } )

	oModel:SetRelation( 'FKZDETAILI', aRltIse, FKZ->( IndexKey( 1 ) ) )
	// Liga o controle de n�o repeti��o de linha
	oModel:GetModel( 'FKZDETAILI' ):SetUniqueLine( { 'FKZ_ISENCA' } )

	oModel:GetModel( 'FKZDETAILD' ):SetOptional( .T. )
	oModel:GetModel( 'FKZDETAILI' ):SetOptional( .T. )

	oModel:GetModel( 'FKXMASTER' ):SetDescription(STR0001)//'Natureza de Rendimento'
	oModel:GetModel( 'FKZDETAILD' ):SetDescription(STR0010)//'Dedu��es'
	oModel:GetModel( 'FKZDETAILI' ):SetDescription(STR0011)//'Isen��es'

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o responsavel pela montagem da View

@author		Vinicius do Prado
@since		21/02/2019
@version	1
@return		oView - objeto da View
/*/
//-------------------------------------------------------------------

Static Function ViewDef() As Object

	Local oStruFKX	As Object
	Local oStruFKZD	As Object
	Local oStruFKZI	As Object
	Local oModel	As Object
	Local oView		As Object

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	oStruFKX	:= FWFormStruct( 2, 'FKX' )
	oStruFKZD	:= FWFormStruct( 2, 'FKZ', { |x| !ALLTRIM(x) $ "FKZ_CODIGO,FKZ_ISENCA"} )
	oStruFKZI	:= FWFormStruct( 2, 'FKZ', { |x| !ALLTRIM(x) $ "FKZ_CODIGO,FKZ_DEDUCA"} )

	oStruFKZD:AddField(	'FKZ_DESCRD',;			// [01] C Nome do Campo
						'50',;					// [02] C Ordem
						AllTrim(STR0009),;		// [03] C Titulo do campo //'Descri��o'    
						AllTrim(STR0009),;		// [04] C Descri��o do campo //'Descri��o'    
						{STR0009},;				// [05] A Array com Help //'Descri��o'    
						'C',;					// [06] C Tipo do campo
						'@!',;					// [07] C Picture
						NIL,;					// [08] B Bloco de Picture Var
						'',;					// [09] C Consulta F3
						.F.,;					// [10] L Indica se o campo � edit�vel
						NIL,;					// [11] C Pasta do campo
						NIL,;					// [12] C Agrupamento do campo
						{},;					// [13] A Lista de valores permitido do campo (Combo)
						NIL,;					// [14] N Tamanho Maximo da maior op��o do combo
						NIL,;					// [15] C Inicializador de Browse
						.T.,;					// [16] L Indica se o campo � virtual
						NIL )					// [17] C Picture Vari�vel

	oStruFKZI:AddField(	'FKZ_DESCRI',;			// [01] C Nome do Campo
						'50',;					// [02] C Ordem
						AllTrim(STR0009),;		// [03] C Titulo do campo //'Descri��o'    
						AllTrim(STR0009),;		// [04] C Descri��o do campo //'Descri��o'    
						{STR0009},;				// [05] A Array com Help //'Descri��o'    
						'C',;					// [06] C Tipo do campo
						'@!',;					// [07] C Picture
						NIL,;					// [08] B Bloco de Picture Var
						'',;					// [09] C Consulta F3
						.F.,;					// [10] L Indica se o campo � edit�vel
						NIL,;					// [11] C Pasta do campo
						NIL,;					// [12] C Agrupamento do campo
						{},;					// [13] A Lista de valores permitido do campo (Combo)
						NIL,;					// [14] N Tamanho Maximo da maior op��o do combo
						NIL,;					// [15] C Inicializador de Browse
						.T.,;					// [16] L Indica se o campo � virtual
						NIL )					// [17] C Picture Vari�vel

	// Cria a estrutura a ser usada na View
	oModel   := FWLoadModel( 'FINA028' )

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados ser� utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_FKX', oStruFKX, 'FKXMASTER' )

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid(  'VIEW_FKZD', oStruFKZD, 'FKZDETAILD' )
	oView:AddGrid(  'VIEW_FKZI', oStruFKZI, 'FKZDETAILI' )

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'VIEWFKX' , 40 )
	oView:CreateHorizontalBox( 'VIEWFKZ' , 60 )

	//Criando a folder da grid (filhos)
	oView:CreateFolder('SHEET_DEDISE', 'VIEWFKZ')
	oView:AddSheet('SHEET_DEDISE', 'SHEET_DED', STR0010) //"Dedu��es"
	oView:AddSheet('SHEET_DEDISE', 'SHEET_ISE', STR0011) //"Isen��es"

	//Criando os vinculos onde ser�o mostrado os dados
	oView:CreateHorizontalBox('VIEWFKZD', 100,,, 'SHEET_DEDISE', 'SHEET_DED' )
	oView:CreateHorizontalBox('VIEWFKZI', 100,,, 'SHEET_DEDISE', 'SHEET_ISE' )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_FKX', 'VIEWFKX' )
	oView:SetOwnerView( 'VIEW_FKZD', 'VIEWFKZD' )
	oView:SetOwnerView( 'VIEW_FKZI', 'VIEWFKZI' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F028Des
Fun��o para gatilhar a descri��o da tabela 0J e 0K

@param cTipo	- Indica de qual aba � a chamada (deducao/isencao)
@return - Retorna a descri��o a ser exibida de acordo com a aba

@author		Rodrigo.Pirolo
@since		07/05/2019
@version	P12
/*/
//-------------------------------------------------------------------

Function F028Des( cTipo As Character ) As Character

	Local cRet		As Character
	Local oModel	As Object
	Local oModFKZ	As Object
	Local cModelId	As Character

	Default cTipo	:= ""

	If !Empty(cTipo)
		
		cRet	:= ""
		oModel	:= FwModelActive()
		
		If cTipo == "D"
			cModelId := "FKZDETAILD" 
		Else
			cModelId := "FKZDETAILI"
		EndIf
		
		If !INCLUI .and. oModel != NIL
			oModFKZ := oModel:GetModel(cModelId)
			
			If oModFKZ:length() == 0
				If cTipo == "D"
					cRet := Posicione("SX5",1,XFILIAL("SX5")+"0M"+FKZ->FKZ_DEDUCA,"X5_DESCRI")
				Else
					cRet := Posicione("SX5",1,XFILIAL("SX5")+"0K"+FKZ->FKZ_ISENCA,"X5_DESCRI")
				EndIf
			EndIf
		Endif
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa028Combo 
Fun��o para apresentar as op��es de tributo para o campo FKX_TRIBUT

@return cCombo - Indica qual tributo foi selecionado

@author		Douglas.Oliveira
@since		17/10/2022
@version	P12
/*/
//-------------------------------------------------------------------
Function Fa028Combo() as character

	Local cCombo as Character

	cCombo  := ""   

	cCombo	:= Alltrim(STR0008) //"1=IR;2=IR, PIS, COFINS, CSLL e Agreg;3=PIS e COFINS;4=IR e CSLL;5=IR, CSLL e Agreg;6=CSLL;7=PIS, COFINS e CSLL;8=PIS, COFINS, CSLL e Agreg"
																					
Return cCombo

//---------------------------------------------------------------------------------------------------------
/*/ {Protheus.doc} FinaAtuFKX()
Fun��o responsavel por popular a tabela FKX na inicializa��o do modulo SIGAFIN (auto-contida), 
atrav�s da chamada no FINXLOAD.

@sample FinaAtuFKX()
@author Vinicius do Prado
@since 20/02/19
@version 1.0

/*/
//---------------------------------------------------------------------------------------------------------
Function FinaAtuFKX()

	Local nI		As Numeric
	Local aAreaAtu	As Array
	Local aAreaFKX	As Array
	Local aAreaFKZ	As Array
	Local aFKX		As Array
	Local aFKZ		As Array
	Local cFilFKX	As Character

	nI		 := 0
	aAreaAtu := GetArea()
	aAreaFKX := FKX->(GetArea())
	aAreaFKZ := FKZ->(GetArea())
	aFKX	 := {}
	aFKZ	 := {}
	cFilFKX	 := xFilial("FKX")	

	/* Ordem dos elementos do array aFKX para gravacao da tabela FKX 
	Filial + Codigo + Descricao + FCI + 13 sal. + RRA + Ext. PF + Ext. PJ + Declarante + Tributo + Descr. Extendida */

	// - Grupo 10 - Rendimento do Trabalho e da Previd�ncia Social
	AAdd(aFKX,{cFilFKX,"10001",STR0012,"2","1","1","1","3","3","1",STR0012}) //"Rendimento decorrente do trabalho com v�nculo empregat�cio"
	AAdd(aFKX,{cFilFKX,"10002",STR0013,"2","2","1","1","3","3","1",STR0013}) //"Rendimento decorrente do trabalho sem v�nculo empregat�cio"
	AAdd(aFKX,{cFilFKX,"10003",STR0014,"2","1","1","1","3","3","1",STR0014}) //"Rendimento decorrente do trabalho pago a trabalhador avulso"
	AAdd(aFKX,{cFilFKX,"10004",STR0015,"2","2","1","1","3","2","1",STR0015}) //"Participa��o nos lucros ou resultados (PLR)"
	AAdd(aFKX,{cFilFKX,"10005",STR0016,"2","1","1","1","3","2","1",STR0016}) //"Benef�cio de Regime Pr�prio de Previd�ncia Social"
	AAdd(aFKX,{cFilFKX,"10006",STR0017,"2","1","1","1","3","2","1",STR0017}) //"Benef�cio do Regime Geral de Previd�ncia Social"
	AAdd(aFKX,{cFilFKX,"10007",STR0018,"2","2","2","2","3","2","1",STR0019}) //"Rendimentos relativos a presta��o de servi�os de Transporte"## "Rendimentos relativos a presta��o de servi�os de Transporte Rodovi�rio Internacional de Carga, Auferidos por Transportador Aut�nomo Pessoa F�sica, Residente na Rep�blica do Paraguai, considerado como Sociedade Unipessoal nesse Pa�s"
	AAdd(aFKX,{cFilFKX,"10008",STR0020,"2","2","1","1","3","2","1",STR0021}) //"Honor�rios advocat�cios de sucumb�ncia"## "Honor�rios advocat�cios de sucumb�ncia recebidos pelos advogados e procuradores p�blicos de que trata o art. 27 da Lei n� 13.327"
	AAdd(aFKX,{cFilFKX,"10009",STR0023,"2","2","2","1","3","2","1",STR0023}) //"Aux�lio moradia"
	AAdd(aFKX,{cFilFKX,"10010",STR0022,"2","1","1","1","3","3","",STR0022}) //"Bolsa ao m�dico residente"

	// - Grupo 11 - Rendimento decorrente de Decis�o Judicial
	AAdd(aFKX,{cFilFKX,"11001",STR0024,"2","1","1","1","1","3","1",STR0024}) //"Decorrente de Decis�o da Justi�a do Trabalho"
	AAdd(aFKX,{cFilFKX,"11002",STR0025,"2","1","1","1","1","2","1",STR0025}) //"Decorrente de Decis�o da Justi�a Federal"
	AAdd(aFKX,{cFilFKX,"11003",STR0026,"2","1","1","1","1","3","1",STR0027}) //"Decorrente de Decis�o da Justi�a dos Estados/Dist. Federal" ##"Decorrente de Decis�o da Justi�a dos Estados/Distrito Federal"
	AAdd(aFKX,{cFilFKX,"11004",STR0028,"2","1","1","1","1","3","1",STR0029}) //"Responsabilidade Civil - juros e indeniza��es" ## "Responsabilidade Civil - juros e indeniza��es por lucros cessantes, inclusive astreinte"
	AAdd(aFKX,{cFilFKX,"11005",STR0030,"2","1","1","1","1","3","1",STR0031}) //"Decis�o Judicial Import�ncias pagas por danos morais" ## "Decis�o Judicial Import�ncias pagas a t�tulo de indeniza��es por danos morais, decorrentes de senten�a judicial."

	// - Grupo 12 - Rendimento do Capital
	AAdd(aFKX,{cFilFKX,"12001",STR0032,"2","2","1","1","1","2","" ,STR0032}) //"Lucro e Dividendo"
	AAdd(aFKX,{cFilFKX,"12002",STR0033,"2","2","2","1","3","2","1",STR0034}) //"Resgate de Previd�ncia Complementar-Modalidade Contribui��o" ## "Resgate de Previd�ncia Complementar - Modalidade Contribui��o Definida/Vari�vel - N�o Optante pela Tributa��o Exclusiva"
	AAdd(aFKX,{cFilFKX,"12003",STR0035,"2","2","2","1","3","2","1",STR0036}) //"Resgate de Fundo de Aposentadoria Programada Individual" ## "Resgate de Fundo de Aposentadoria Programada Individual (Fapi)- N�o Optante pela Tributa��o Exclusiva"
	AAdd(aFKX,{cFilFKX,"12004",STR0037,"2","2","2","1","3","2","1",STR0038}) //"Resgate de Previd�ncia Complementar - Modalidade Benef�cio" ## "Resgate de Previd�ncia Complementar - Modalidade Benef�cio Definido - N�o Optante pela Tributa��o Exclusiva"
	AAdd(aFKX,{cFilFKX,"12005",STR0033,"2","2","2","1","3","2","1",STR0039}) //"Resgate de Previd�ncia Complementar-Modalidade Contribui��o" ## "Resgate de Previd�ncia Complementar - Modalidade Contribui��o Definida/Vari�vel - Optante pela Tributa��o Exclusiva"
	AAdd(aFKX,{cFilFKX,"12006",STR0035,"2","2","2","1","3","2","1",STR0040}) //"Resgate de Fundo de Aposentadoria Programada Individual" ## "Resgate de Fundo de Aposentadoria Programada Individual (Fapi)- Optante pela Tributa��o Exclusiva"
	AAdd(aFKX,{cFilFKX,"12007",STR0041,"2","2","2","1","3","2","1",STR0042}) //"Resgate de Planos de Seguro de Vida - Cl�usula de Cobertura" ## "Resgate de Planos de Seguro de Vida com Cl�usula de Cobertura por Sobreviv�ncia-Optante pela Tributa��o Exclusiva"
	AAdd(aFKX,{cFilFKX,"12008",STR0043,"2","2","2","1","3","2","1",STR0044}) //"Resgate de Planos de Seguro de Vida-Cl�usula Sobreviv�ncia" ## "Resgate de Planos de Seguro de Vida com Cl�usula de Cobertura por Sobreviv�ncia - N�o Optante pela Tributa��o Exclusiva"
	AAdd(aFKX,{cFilFKX,"12009",STR0045,"2","1","1","1","3","2","1",STR0046}) //"Benef�cio de Previd�ncia Complementar-Modalidade Contribui��o" ## "Benef�cio de Previd�ncia Complementar - Modalidade Contribui��o Definida/Vari�vel - N�o Optante pela Tributa��o Exclusiva"
	AAdd(aFKX,{cFilFKX,"12010",STR0047,"2","1","1","1","3","2","1",STR0048}) //"Benef�cio de Fundo de Aposentadoria Programada Individual" ## "Benef�cio de Fundo de Aposentadoria Programada Individual (Fapi)- N�o Optante pela Tributa��o Exclusiva"
	AAdd(aFKX,{cFilFKX,"12011",STR0049,"2","1","1","1","3","2","1",STR0050}) //"Benef�cio de Previd�ncia Complementar-Modalidade Benef�cio" ## "Benef�cio de Previd�ncia Complementar - Modalidade Benef�cio Definido - N�o Optante pela Tributa��o Exclusiva"
	AAdd(aFKX,{cFilFKX,"12012",STR0051,"2","1","1","1","3","2","1",STR0052}) //"Benef�cio de Previd�ncia Complementar - Mod. Contribui��o" ## "Benef�cio de Previd�ncia Complementar - Modalidade Contribui��o Definida/Vari�vel - Optante pela Tributa��o Exclusiva
	AAdd(aFKX,{cFilFKX,"12013",STR0047,"2","1","1","1","3","2","1",STR0053}) //"Benef�cio de Fundo de Aposentadoria Programada Individual" ## "Benef�cio de Fundo de Aposentadoria Programada Individual (Fapi)- Optante pela Tributa��o Exclusiva"
	AAdd(aFKX,{cFilFKX,"12014",STR0054,"2","1","2","1","3","2","1",STR0055}) //"Benef�cio de Planos de Seguro de Vida com sobreviv�ncia" ## "Benef�cio de Planos de Seguro de Vida com Cl�usula de Cobertura por Sobreviv�ncia- Optante pela Tributa��o Exclusiva"
	AAdd(aFKX,{cFilFKX,"12015",STR0054,"2","2","1","1","3","2","1",STR0056}) //"Benef�cio de Planos de Seguro de Vida com sobreviv�ncia" ## "Benef�cio de Planos de Seguro de Vida com Cl�usula de Cobertura por Sobreviv�ncia - N�o Optante pela Tributa��o Exclusiva"
	AAdd(aFKX,{cFilFKX,"12016",STR0057,"1","2","2","1","1","2","1",STR0056}) // "Juros sobre o Capital Pr�prio" ## "Benef�cio de Planos de Seguro de Vida com Cl�usula de Cobertura por Sobreviv�ncia - N�o Optante pela Tributa��o Exclusiva"
	AAdd(aFKX,{cFilFKX,"12017",STR0058,"2","2","2","1","1","2","1",STR0059}) //"Rendimento de Aplica��es Financeiras de Renda Fixa" ## "Rendimento de Aplica��es Financeiras de Renda Fixa, decorrentes de aliena��o, liquida��o (total ou parcial), resgate, cess�o ou repactua��o do t�tulo ou aplica��o"
	AAdd(aFKX,{cFilFKX,"12018",STR0060,"2","2","2","1","1","2","1",STR0061}) //"Rendimentos pela entrega de recursos � pessoa jur�dica" ## "Rendimentos auferidos pela entrega de recursos � pessoa jur�dica, sob qualquer forma e a qualquer t�tulo, independentemente de ser ou n�o a fonte pagadora institui��o autorizada a funcionar pelo Banco Central"
	AAdd(aFKX,{cFilFKX,"12019",STR0062,"2","2","2","1","1","2","1",STR0063}) //"Rendimentos predeterminados obtidos em opera��es conjugadas" ## "Rendimentos predeterminados obtidos em opera��es conjugadas realizadas: nos mercados de op��es de compra e venda em bolsas de valores, de mercadorias e de futuros (box); no mercado a termo nas bolsas de valores, de mercadorias e de futuros, em opera��es de venda coberta esem ajustes di�rios, e no mercado de balc�o."
	AAdd(aFKX,{cFilFKX,"12020",STR0064,"2","2","2","1","1","2","1",STR0065}) //"Rendimentos obtidos nas opera��es de transf. de d�vidas" ## "Rendimentos obtidos nas opera��es de transfer�ncia de d�vidas realizadas com institui��o financeira e outras institui��es autorizadas a funcionar pelo Banco Central do Brasil"
	AAdd(aFKX,{cFilFKX,"12021",STR0066,"2","2","2","1","1","2","1",STR0067}) //"Rendimentos peri�dicos produzidos por t�tulo ou aplica��o" ## "Rendimentos peri�dicos produzidos por t�tulo ou aplica��o, bem como qualquer remunera��o adicional aos rendimentos prefixados" 
	AAdd(aFKX,{cFilFKX,"12022",STR0068,"2","2","2","1","1","2","1",STR0069}) ///"Rendimentos nas opera��es de m�tuo de recursos financeiros" ## "Rendimentos auferidos nas opera��es de m�tuo de recursos financeiros entre pessoa f�sica e pessoa jur�dica e entre pessoas jur�dicas, inclusive controladoras, controladas, coligadas e interligadas"
	AAdd(aFKX,{cFilFKX,"12023",STR0070,"2","2","2","3","1","2","1",STR0071}) //"Rendimentos em opera��es de adiantamento sobre contr.c�mbio" ## "Rendimentos auferidos em opera��es de adiantamento sobre contratos de c�mbio de exporta��o, n�o sacado (trava de c�mbio), bem como opera��es com export notes, com deb�ntures, com dep�sitos volunt�rios para garantia de inst�ncia e com dep�sitos judiciais ou administrativos, quando seu levantamento se der em favor do depositante"
	AAdd(aFKX,{cFilFKX,"12024",STR0072,"2","2","2","1","1","2","1",STR0073}) //"Rendimentos nas opera��es de m�tuo e de compra vinculada" ## "Rendimentos obtidos nas opera��es de m�tuo e de compra vinculada � revenda tendo por objeto ouro, ativo financeiro"
	AAdd(aFKX,{cFilFKX,"12025",STR0074,"2","2","2","1","1","2","1",STR0074}) //"Rendimentos auferidos em contas de dep�sitos de poupan�a"
	AAdd(aFKX,{cFilFKX,"12026",STR0075,"2","2","2","1","1","2","1",STR0076}) //"Rendimentos sobre juros produzidos por letras hipotec�rias" ## "Rendimentos auferidos sobre juros produzidos por letras hipotec�rias"
	AAdd(aFKX,{cFilFKX,"12027",STR0077,"2","2","2","1","1","2","1",STR0078})//"Rendimentos ou ganhos decorrentes da negocia��o de t�tulos" ## "Rendimentos ou ganhos decorrentes da negocia��o de t�tulos ou valores mobili�rios de renda fixa em bolsas de valores, de mercadorias, de futuros e assemelhadas"
	AAdd(aFKX,{cFilFKX,"12028",STR0079,"2","2","2","1","1","2","1",STR0080}) //"Rendimentos aplic. finan. de renda fixa ou renda vari�vel" ## "Rendimentos auferidos em outras aplica��es financeiras de renda fixa ou de renda vari�vel"
	AAdd(aFKX,{cFilFKX,"12029",STR0081,"1","2","2","1","1","2","1",STR0081}) //"Rendimentos auferidos em Fundo de Investimento"
	AAdd(aFKX,{cFilFKX,"12030",STR0082,"1","2","2","1","1","2","1",STR0083}) //"Rendimentos auferidos em Fundos de investimento em quotas" ## "Rendimentos auferidos em Fundos de investimento em quotas de fundos de investimento"
	AAdd(aFKX,{cFilFKX,"12031",STR0084,"1","2","2","1","1","2","1",STR0085}) //"Rendimentos por aplic. em fundos de investimento em a��es" ## "Rendimentos produzidos por aplica��es em fundos de investimento em a��es"
	AAdd(aFKX,{cFilFKX,"12032",STR0086,"1","2","2","1","1","2","1",STR0087}) //"Rendimentos por aplic. em fundos de investimento em quotas" ## "Rendimentos produzidos por aplica��es em fundos de investimento em quotas defundos de investimento em a��es"
	AAdd(aFKX,{cFilFKX,"12033",STR0088,"1","2","2","1","1","2","1",STR0089}) //"Rendimentos por aplic. em Fundos M�tuos de Privatiza��o" ## "Rendimentos produzidos por aplica��es em Fundos M�tuos de Privatiza��o com recursos do Fundo de Garantia por Tempo de Servi�o (FGTS)
	AAdd(aFKX,{cFilFKX,"12034",STR0088,"1","2","2","1","1","2","1",STR0090}) //"Rendimentos por aplic. em Fundos M�tuos de Privatiza��o" ## "Rendimentos auferidos pela carteira dos Fundos de Investimento Imobili�rio"
	AAdd(aFKX,{cFilFKX,"12035",STR0091,"1","2","2","1","1","2","1",STR0092}) //"Rendimentos distr. pelo Fundo de Invest. Imob. aos cotistas" ##  "Rendimentos distribu�dos pelo Fundo de Investimento Imobili�rio aos seus cotistas"
	AAdd(aFKX,{cFilFKX,"12036",STR0093,"1","2","2","1","1","2","1",STR0094}) //"Rendimento no resgate de cotas na liq. do Fundo de Invest." ## "Rendimento auferido pelo cotista no resgate de cotas na liquida��o do Fundo de Investimento Imobili�rio"
	AAdd(aFKX,{cFilFKX,"12037",STR0095,"1","2","2","1","1","2","1",STR0096}) //"Rendimentos pela carteira dos Fundos de Invest. Imobili�rio" ## "Rendimentos auferidos pela carteira dos Fundos de Investimento Imobili�rio Distribui��o semestral"
	AAdd(aFKX,{cFilFKX,"12038",STR0097,"1","2","2","1","1","2","1",STR0098}) //"Rendimentos distribu�dos pelo Fundo de Invest. Imobili�rio" ## "Rendimentos distribu�dos pelo Fundo de Investimento Imobili�rio aos seus cotistas - Distribui��o semestral"
	AAdd(aFKX,{cFilFKX,"12039",STR0099,"1","2","2","1","1","2","1",STR0100}) //"Rendimento pelo cotista no resgate de cotas na liquida��o" ## "Rendimento auferido pelo cotista no resgate de cotas na liquida��o do Fundo de Investimento Imobili�rio Distribui��o semestral"
	AAdd(aFKX,{cFilFKX,"12040",STR0101,"1","2","2","1","1","3","1",STR0102}) //"Rendimentos e ganhos de capital distr. pelo Fundo Invest." ## "Rendimentos e ganhos de capital distribu�dos pelo Fundo de Investimento Cultural e Art�stico (Ficart)"
	AAdd(aFKX,{cFilFKX,"12041",STR0103,"1","2","2","1","1","3","1",STR0104}) //"Rendimentos e ganhos de capital distribu�dos (Funcines)" ## "Rendimentos e ganhos de capital distribu�dos pelo Fundo de Financiamento da Ind�stria Cinematogr�fica Nacional (Funcines)"
	AAdd(aFKX,{cFilFKX,"12042",STR0105,"1","2","2","2","2","2","1",STR0106}) //"Rendimentos no resgate de quotas de fundos de investimento" ## "Rendimentos auferidos no resgate de quotas de fundos de investimento mantidos com recursos provenientes de convers�o de d�bitos externos brasileiros, e de que participem, exclusivamente, residentes ou domiciliados no exterior"
	AAdd(aFKX,{cFilFKX,"12043",STR0107,"1","2","2","1","1","2","1",STR0108}) //"Ganho de capital decorrente da integraliza��o de cotas" ## "Ganho de capital decorrente da integraliza��o de cotas de fundos ou clubes de investimento por meio da entrega de ativos financeiros"
	AAdd(aFKX,{cFilFKX,"12044",STR0109,"1","2","2","1","1","2","1",STR0110}) //"Distribui��o de Juros sobre o Capital Pr�prio" ## "Distribui��o de Juros sobre o Capital Pr�prio pela companhia emissora de a��es objeto de empr�stimo"
	AAdd(aFKX,{cFilFKX,"12045",STR0111,"2","2","2","1","1","2","1",STR0111}) //"Rendimentos de Partes Benefici�rias ou de Fundador"
	AAdd(aFKX,{cFilFKX,"12046",STR0112,"2","2","2","1","1","2","1",STR0112}) //"Rendimentos auferidos em opera��es de swap"
	AAdd(aFKX,{cFilFKX,"12047",STR0113,"2","2","2","1","1","3","1",STR0114}) //"Rendimentos auferidos em opera��es day trade" ## "Rendimentos auferidos em opera��es day trade realizadas em bolsa de valores, de mercadorias, de futuros e assemelhadas"
	AAdd(aFKX,{cFilFKX,"12048",STR0115,"2","2","2","1","1","3","1",STR0116}) //"Rendimento decorrente de opera��o exceto day trade" ## "Rendimento decorrente de Opera��o realizada em bolsas de valores, de mercadorias, de futuros, e assemelhadas, exceto day trade"
	AAdd(aFKX,{cFilFKX,"12049",STR0117,"2","2","2","1","1","3","1",STR0118}) //"Rendimento decorrente de oper. realizada no merc. de balc�o" ## "Rendimento decorrente de Opera��o realizada no mercado de balc�o, com intermedia��o, tendo por objeto a��es, ouro ativo financeiro e outros valores mobili�rios negociados no mercado � vista"
	AAdd(aFKX,{cFilFKX,"12050",STR0119,"2","2","2","1","1","3","1",STR0120}) //"Rendimento decorrente de oper. realizada em merc. liquid." ## "Rendimento decorrente de Opera��o realizada em mercados de liquida��o futura fora de bolsa"
	AAdd(aFKX,{cFilFKX,"12051",STR0119,"1","2","2","4","4","2","1",STR0121}) //"Rendimento decorrente de oper. realizada em merc. liquid." ## "Rendimentos de deb�ntures emitidas por sociedade de prop�sito espec�fico conforme previsto no art. 2� da Lei n� 12.431 de 2011"
	AAdd(aFKX,{cFilFKX,"12052",STR0367,"1","2","2","1","1","2","1",STR0368}) //"Juros sobre o Capital Pr�prio cujos benefici�rios n�o esteja" ## "Juros sobre o Capital Pr�prio cujos benefici�rios n�o estejam identificados no momento do registro cont�bil"
	AAdd(aFKX,{cFilFKX,"12099",STR0122,"1","2","2","1","1","2","1",STR0122}) //"Demais rendimentos de Capital"

	// - Grupo 13 - Rendimento de Direitos (Royalties)
	AAdd(aFKX,{cFilFKX,"13001",STR0123,"2","2","1","1","2","3","1",STR0123}) //"Rendimentos de Aforamento"
	AAdd(aFKX,{cFilFKX,"13002",STR0124,"2","2","1","1","2","3","1",STR0124}) //"Rendimentos de Loca��o ou Subloca��o" 
	AAdd(aFKX,{cFilFKX,"13003",STR0125,"2","2","1","1","2","3","1",STR0125}) //"Rendimentos de Arrendamento ou Subarrendamento"
	AAdd(aFKX,{cFilFKX,"13004",STR0126,"2","2","1","1","2","3","1",STR0127}) //"Import�ncias pagas por terceiro por conta do locador do bem" ## "Import�ncias pagas por terceiros por conta do locador do bem (juros, comiss�es etc.)"
	AAdd(aFKX,{cFilFKX,"13005",STR0128,"2","2","1","1","2","3","1",STR0129}) //"Import�ncias pagas ao locador pelo contrato celebrado" ## "Import�ncias pagas ao locador pelo contrato celebrado (luvas, pr�mios etc.)"
	AAdd(aFKX,{cFilFKX,"13006",STR0130,"2","2","1","1","2","3","1",STR0131}) //"Benfeitorias e quaisquer melhoramentos feitos no bem locado" ## "Benfeitorias e quaisquer melhoramentos realizados no bem locado"
	AAdd(aFKX,{cFilFKX,"13007",STR0132,"2","2","1","1","2","3","1",STR0132}) //"Juros decorrente da aliena��o a prazo de bens"
	AAdd(aFKX,{cFilFKX,"13008",STR0133,"2","2","1","1","2","3","1",STR0134}) //"Rendimentos de Direito de Uso ou Passagem de Terrenos" ## "Rendimentos de Direito de Uso ou Passagem de Terrenos e de aproveitamento de �guas"
	AAdd(aFKX,{cFilFKX,"13009",STR0135,"2","2","1","1","2","3","1",STR0136}) //"Rendimentos de Direito de colher ou extrair rec. vegetais" ## "Rendimentos de Direito de colher ou extrair recursos vegetais, pesquisar e extrair recursos minerais"
	AAdd(aFKX,{cFilFKX,"13010",STR0137,"2","2","1","1","2","3","1",STR0137}) //"Rendimentos de Direito Autoral"
	AAdd(aFKX,{cFilFKX,"13011",STR0137,"2","2","1","1","2","3","1",STR0138}) //"Rendimentos de Direito Autoral" ## "Rendimentos de Direito Autoral (quando n�o percebidos pelo autor ou criador da obra)"
	AAdd(aFKX,{cFilFKX,"13012",STR0139,"2","2","1","1","2","3","1",STR0139}) //"Rendimentos de Direito de Imagem"
	AAdd(aFKX,{cFilFKX,"13013",STR0140,"2","2","1","1","2","3","1",STR0141}) //"Rendimentos de Direito sobre pel�culas cinematogr�ficas" ## "Rendimentos de Direito sobre pel�culas cinematogr�ficas, Obras Audiovisuais, e Videof�nicas"
	AAdd(aFKX,{cFilFKX,"13014",STR0142,"2","2","1","1","2","3","1",STR0143}) //"Rendimento de Direito relativo a radiodifus�o" ## "Rendimento de Direito relativo a radiodifus�o de sons e imagens e servi�o de comunica��o eletr�nica de massa por assinatura"
	AAdd(aFKX,{cFilFKX,"13015",STR0144,"2","2","1","1","2","3","1",STR0144}) //"Rendimentos de Direito de Conjuntos Industriais e Inven��es"
	AAdd(aFKX,{cFilFKX,"13016",STR0145,"2","2","1","1","2","3","1",STR0146}) //"Rendimento de Direito de marcas de ind�stria e com�rcio" ## "Rendimento de Direito de marcas de ind�stria e com�rcio, patentes de inven��o e processo ou f�rmulas de fabrica��o"
	AAdd(aFKX,{cFilFKX,"13017",STR0147,"2","2","1","1","2","3","1",STR0146}) // "Import�ncias pagas por terc. por conta cedente dos direitos" ## "Rendimento de Direito de marcas de ind�stria e com�rcio, patentes de inven��o e processo ou f�rmulas de fabrica��o"
	AAdd(aFKX,{cFilFKX,"13018",STR0148,"2","2","1","1","2","3","1",STR0149}) //"Import�ncias pagas cedente do direito, pelo contr.celebrado" ## "Import�ncias pagas ao cedente do direito, pelo contrato celebrado (luvas, pr�mios etc.)"
	AAdd(aFKX,{cFilFKX,"13019",STR0148,"2","2","1","1","2","3","1",STR0150}) //"Import�ncias pagas cedente do direito, pelo contr.celebrado" ## "Despesas para conserva��o dos direitos cedidos (quando compensadas pelo uso do bem ou direito)"
	AAdd(aFKX,{cFilFKX,"13020",STR0151,"2","2","1","1","2","3","1",STR0152}) //"Juros de mora e quaisquer outras comp.pelo atraso no pagto." ## "Juros de mora e quaisquer outras compensa��es pelo atraso no pagamento de royalties decorrente de presta��o de servi�o"
	AAdd(aFKX,{cFilFKX,"13021",STR0151,"2","2","1","1","2","3","1",STR0153}) //"Juros de mora e quaisquer outras comp.pelo atraso no pagto." ## "Juros de mora e quaisquer outras compensa��es pelo atraso no pagamento de royalties decorrente de aquisi��o de bens"
	AAdd(aFKX,{cFilFKX,"13022",STR0154,"2","2","1","1","2","3","1",STR0155}) //"Juros decorrente da aliena��o a prazo de direitos" ## "Juros decorrente da aliena��o a prazo de direitos decorrente de presta��o de servi�o"
	AAdd(aFKX,{cFilFKX,"13023",STR0154,"2","2","1","1","2","3","1",STR0156}) //"Juros decorrente da aliena��o a prazo de direitos" ## "Juros decorrente da aliena��o a prazo de direitos decorrente de aquisi��o de bens"
	AAdd(aFKX,{cFilFKX,"13024",STR0157,"2","2","2","3","2","2","1",STR0158}) //"Aliena��o de bens e direitos do ativo n�o circulante-Brasil" ## "Aliena��o de bens e direitos do ativo n�o circulante localizados no Brasil"
	AAdd(aFKX,{cFilFKX,"13025",STR0159,"2","2","1","1","2","3","1",STR0160}) //"Rendimento de transfer�ncia de atleta profissional" ## "Rendimento de Direito decorrente da transfer�ncia de atleta profissional"
	AAdd(aFKX,{cFilFKX,"13026",STR0161,"2","2","1","1","2","","1",STR0162}) //"Juros e comiss�es de parc. dos cr�ditos do inciso XI" ## "Juros e comiss�es correspondentes � parcela dos cr�ditos de que trata o inciso XI do art. 1� da Lei n� 9.481, de 1997, n�o aplicada no financiamento de exporta��es"
	AAdd(aFKX,{cFilFKX,"13098",STR0163,"2","2","1","1","2","3","1",STR0163}) //"Demais rendimentos de Direito"
	AAdd(aFKX,{cFilFKX,"13099",STR0164,"2","2","1","1","2","3","1",STR0164}) //"Demais rendimentos de Royalties"

	// - Grupo 14 - Pr�mios e demais rendimentos
	AAdd(aFKX,{cFilFKX,"14001",STR0165,"2","2","2","1","1","3","1",STR0166}) //"Pr�mios distribu�dos, sob a forma de bens e servi�os" ## "Pr�mios distribu�dos, sob a forma de bens e servi�os, mediante loterias, concursos e sorteios, exceto a distribui��o realizada por meio de vale-brinde"
	AAdd(aFKX,{cFilFKX,"14002",STR0167,"2","2","2","1","1","3","1",STR0168}) //"Pr�mios distribu�dos, sob a forma de dinheiro" ## "Pr�mios distribu�dos, sob a forma de dinheiro, mediante loterias, concursos e sorteios, exceto os de antecipa��o nos t�tulos de capitaliza��o e os de amortiza��o e resgate das a��es das sociedades an�nimas"
	AAdd(aFKX,{cFilFKX,"14003",STR0169,"2","2","2","1","1","3","1",STR0169}) //"Pr�mios de Propriet�rios e Criadores de Cavalos de Corrida"
	AAdd(aFKX,{cFilFKX,"14004",STR0170,"2","2","2","1","1","3","1",STR0171}) //"Benef�cios liq.mediante sorteio de t�tulos de capitaliza��o" ## "Benef�cios l�quidos mediante sorteio de t�tulos de capitaliza��o, sem amortiza��o antecipada"
	AAdd(aFKX,{cFilFKX,"14005",STR0172,"2","2","2","1","1","3","1",STR0173}) //"Benef�cios l�quidos resultantes da amortiza��o antecipada" ## "Benef�cios l�quidos resultantes da amortiza��o antecipada, mediante sorteio, dos t�tulos de capitaliza��o e benef�cios atribu�dos aos portadores de t�tulos de capitaliza��o nos lucros da empresa emitente"
	AAdd(aFKX,{cFilFKX,"14006",STR0165,"2","2","2","1","1","3","1",STR0174}) //"Pr�mios distribu�dos, sob a forma de bens e servi�os" ## "Pr�mios distribu�dos, sob a forma de bens e servi�os, mediante sorteios de jogos de bingo permanente ou eventual"
	AAdd(aFKX,{cFilFKX,"14007",STR0175,"2","2","2","1","1","3","1",STR0176}) //"Pr�mios distr.dinheiro, obtido mediante sort.de jogos bingo" ## "Pr�mios distribu�dos, em dinheiro, obtido mediante sorteios de jogos de bingo permanente ou eventual"
	AAdd(aFKX,{cFilFKX,"14008",STR0177,"2","2","2","1","1","3","1",STR0178}) //"Import�ncias de multas e qualquer outra vantagem" ## "Import�ncias correspondentes a multas e qualquer outra vantagem, ainda que a t�tulo de indeniza��o, em virtude de rescis�o de contrato"
	AAdd(aFKX,{cFilFKX,"14099",STR0179,"2","2","2","1","1","3","1",STR0180}) //"Demais Benef�cios Liq.decorrentes de t�tulo capitaliza��o" ## "Demais Benef�cios L�quidos decorrentes de t�tulo de capitaliza��o"

	// - Grupo 15 - Rendimento Pago/Creditado a Pessoa Jur�dica
	AAdd(aFKX,{cFilFKX,"15001",STR0181,"2","2","2","3","4","2","1",STR0182}) // "Import�ncias pagas ou creditadas a cooperativas de trabalho" ## "Import�ncias pagas ou creditadas a cooperativas de trabalho relativas a servi�os pessoais que lhes forem prestados por associados destas ou colocados � disposi��o"
	AAdd(aFKX,{cFilFKX,"15002",STR0181,"2","2","2","3","4","2","2",STR0183}) //"Import�ncias pagas ou creditadas a cooperativas de trabalho" ## "Import�ncias pagas ou creditadas a associa��es de profissionais ou assemelhadas, relativas a servi�os pessoais que lhes forem prestados por associados destas ou colocados � disposi��o"
	AAdd(aFKX,{cFilFKX,"15003",STR0184,"2","2","2","3","4","2","2",STR0185}) //"Remunera��o de Servi�os de adm.de bens ou neg�cios em geral" ## "Remunera��o de Servi�os de administra��o de bens ou neg�cios em geral, exceto cons�rcios ou fundos m�tuos para aquisi��o de bens"
	AAdd(aFKX,{cFilFKX,"15004",STR0186,"2","2","2","3","4","2","2",STR0186}) //"Remunera��o de Servi�os de advocacia"
	AAdd(aFKX,{cFilFKX,"15005",STR0187,"2","2","2","3","4","2","2",STR0187}) //"Remunera��o de Servi�os de an�lise cl�nica laboratorial"
	AAdd(aFKX,{cFilFKX,"15006",STR0188,"2","2","2","3","4","2","2",STR0188}) //"Remunera��o de Servi�os de an�lises t�cnicas"
	AAdd(aFKX,{cFilFKX,"15007",STR0189,"2","2","2","3","4","2","2",STR0189}) //"Remunera��o de Servi�os de arquitetura"
	AAdd(aFKX,{cFilFKX,"15008",STR0190,"2","2","2","3","4","2","2",STR0191}) //"Remunera��o de Servi�os de assessoria e consultoria t�cnica" ## "Remunera��o de Servi�os de assessoria e consultoria t�cnica, exceto servi�o de assist�ncia t�cnica prestado a terceiros e concernente a ramo de ind�stria ou com�rcio explorado pelo prestador do servi�o;"
	AAdd(aFKX,{cFilFKX,"15009",STR0192,"2","2","2","3","4","2","2",STR0192}) //"Remunera��o de Servi�os de assist�ncia social;"
	AAdd(aFKX,{cFilFKX,"15010",STR0193,"2","2","2","3","4","2","2",STR0193}) //"Remunera��o de Servi�os de auditoria;"
	AAdd(aFKX,{cFilFKX,"15011",STR0194,"2","2","2","3","4","2","2",STR0194}) //"Remunera��o de Servi�os de avalia��o e per�cia;"
	AAdd(aFKX,{cFilFKX,"15012",STR0195,"2","2","2","3","4","2","2",STR0195}) //"Remunera��o de Servi�os de biologia e biomedicina;"
	AAdd(aFKX,{cFilFKX,"15013",STR0196,"2","2","2","3","4","2","2",STR0196}) //"Remunera��o de Servi�os de c�lculo em geral"
	AAdd(aFKX,{cFilFKX,"15014",STR0197,"2","2","2","3","4","2","2",STR0197}) ///"Remunera��o de Servi�os de consultoria"
	AAdd(aFKX,{cFilFKX,"15015",STR0198,"2","2","2","3","4","2","2",STR0198}) //"Remunera��o de Servi�os de contabilidade"
	AAdd(aFKX,{cFilFKX,"15016",STR0199,"2","2","2","3","4","2","2",STR0199}) //"Remunera��o de Servi�os de desenho t�cnico"
	AAdd(aFKX,{cFilFKX,"15017",STR0200,"2","2","2","3","4","2","2",STR0200}) //"Remunera��o de Servi�os de economia"
	AAdd(aFKX,{cFilFKX,"15018",STR0201,"2","2","2","3","4","2","2",STR0201}) //"Remunera��o de Servi�os de elabora��o de projetos"
	AAdd(aFKX,{cFilFKX,"15019",STR0202,"2","2","2","3","4","2","2",STR0203}) //"Remunera��o de Servi�os de engenharia" ## "Remunera��o de Servi�os de engenharia, exceto constru��o de estradas, pontes, pr�dios e obras assemelhada"
	AAdd(aFKX,{cFilFKX,"15020",STR0204,"2","2","2","3","4","2","2",STR0204}) //"Remunera��o de Servi�os de ensino e treinamento"
	AAdd(aFKX,{cFilFKX,"15021",STR0205,"2","2","2","3","4","2","2",STR0205}) //"Remunera��o de Servi�os de estat�stica"
	AAdd(aFKX,{cFilFKX,"15022",STR0206,"2","2","2","3","4","2","2",STR0206}) //"Remunera��o de Servi�os de fisioterapia"
	AAdd(aFKX,{cFilFKX,"15023",STR0207,"2","2","2","3","4","2","2",STR0207}) //"Remunera��o de Servi�os de fonoaudiologia"
	AAdd(aFKX,{cFilFKX,"15024",STR0208,"2","2","2","3","4","2","2",STR0208}) //"Remunera��o de Servi�os de geologia"
	AAdd(aFKX,{cFilFKX,"15025",STR0209,"2","2","2","3","4","2","2",STR0209}) //"Remunera��o de Servi�os de leil�o"
	AAdd(aFKX,{cFilFKX,"15026",STR0210,"2","2","2","3","4","2","2",STR0211}) // "Remunera��o serv. med. exceto aquela prest.por ambulat�rio" ## "Remunera��o de Servi�os de medicina, exceto aquela prestada por ambulat�rio, banco de sangue, casa de sa�de, casa de recupera��o ou repouso sob orienta��o m�dica, hospital e pronto-socorro"
	AAdd(aFKX,{cFilFKX,"15027",STR0212,"2","2","2","3","4","2","2",STR0212}) //"Remunera��o de Servi�os de nutricionismo e diet�tica"
	AAdd(aFKX,{cFilFKX,"15028",STR0213,"2","2","2","3","4","2","2",STR0213}) //"Remunera��o de Servi�os de odontologia"
	AAdd(aFKX,{cFilFKX,"15029",STR0214,"2","2","2","3","4","2","2",STR0215}) //"Remunera��o de Servi�os de organiza��o de feiras amostras" ## "Remunera��o de Servi�os de organiza��o de feiras de amostras, congressos, semin�rios, simp�sios e cong�neres"
	AAdd(aFKX,{cFilFKX,"15030",STR0216,"2","2","2","3","4","2","2",STR0216}) //"Remunera��o de Servi�os de pesquisa em geral"
	AAdd(aFKX,{cFilFKX,"15031",STR0217,"2","2","2","3","4","2","2",STR0217}) //"Remunera��o de Servi�os de planejamento"
	AAdd(aFKX,{cFilFKX,"15032",STR0218,"2","2","2","3","4","2","2",STR0218}) //"Remunera��o de Servi�os de programa��o"
	AAdd(aFKX,{cFilFKX,"15033",STR0219,"2","2","2","3","4","2","2",STR0219}) //"Remunera��o de Servi�os de pr�tese"
	AAdd(aFKX,{cFilFKX,"15034",STR0220,"2","2","2","3","4","2","2",STR0220}) //"Remunera��o de Servi�os de psicologia e psican�lise"
	AAdd(aFKX,{cFilFKX,"15035",STR0221,"2","2","2","3","4","2","2",STR0221}) //"Remunera��o de Servi�os de qu�mica"
	AAdd(aFKX,{cFilFKX,"15036",STR0222,"2","2","2","3","4","2","2",STR0222}) //"Remunera��o de Servi�os de radiologia e radioterapia"
	AAdd(aFKX,{cFilFKX,"15037",STR0223,"2","2","2","3","4","2","2",STR0223}) //"Remunera��o de Servi�os de rela��es p�blicas"
	AAdd(aFKX,{cFilFKX,"15038",STR0224,"2","2","2","3","4","2","2",STR0224}) //"Remunera��o de Servi�os de servi�o de despachante"
	AAdd(aFKX,{cFilFKX,"15039",STR0225,"2","2","2","3","4","2","2",STR0225}) //"Remunera��o de Servi�os de terap�utica ocupacional"
	AAdd(aFKX,{cFilFKX,"15040",STR0226,"2","2","2","3","4","2","2",STR0227}) //"Remunera��o de Servi�os de trad. ou interpreta��o comercial" ##  "Remunera��o de Servi�os de tradu��o ou interpreta��o comercial"
	AAdd(aFKX,{cFilFKX,"15041",STR0228,"2","2","2","3","4","2","2",STR0228}) //"Remunera��o de Servi�os de urbanismo"
	AAdd(aFKX,{cFilFKX,"15042",STR0229,"2","2","2","3","4","2","2",STR0229}) //"Remunera��o de Servi�os de veterin�ria"
	AAdd(aFKX,{cFilFKX,"15043",STR0230,"2","2","2","3","4","2","2",STR0230}) //"Remunera��o de Servi�os de Limpeza"
	AAdd(aFKX,{cFilFKX,"15044",STR0231,"2","2","2","3","4","2","2",STR0232}) //"Remunera��o de Servi�os de Conserva��o e Manuten��o" ## "Remunera��o de Servi�os de Conserva��o e Manuten��o, exceto reformas e obras assemelhadas"
	AAdd(aFKX,{cFilFKX,"15045",STR0233,"2","2","2","3","4","2","2",STR0234}) //"Remunera��o de Servi�os de Seg, Vig. e Transp. de valores" ## "Remunera��o de Servi�os de Seguran�a, Vigil�ncia e Transporte de valores"
	AAdd(aFKX,{cFilFKX,"15046",STR0235,"2","2","2","3","4","2","2",STR0235}) //"Remunera��o de Servi�os Loca��o de M�o de obra"
	AAdd(aFKX,{cFilFKX,"15047",STR0236,"2","2","2","3","4","2","2",STR0237}) //"Remunera��o de Servi�os de Assessoria Credit�cia"  ## "Remunera��o de Servi�os de Assessoria Credit�cia, Mercadol�gica, Gest�o de Cr�dito, Sele��o e Riscos e Administra��o de Contas a Pagar e a Receber"
	AAdd(aFKX,{cFilFKX,"15048",STR0238,"2","2","2","3","4","2","3",STR0238}) //"Pagamentos Referentes � Aquisi��o de Autope�as"
	AAdd(aFKX,{cFilFKX,"15049",STR0239,"2","2","2","3","4","2","",STR0239}) //"Pagamentos a entidades imunes ou isentas IN RFB 1.234/2012"
	AAdd(aFKX,{cFilFKX,"15050",STR0240,"2","2","2","3","4","2","4",STR0241}) //"Pagamento a t�tulo de transporte internacional" ## "Pagamento a t�tulo de transporte internacional de valores efetuado por empresas nacionais estaleiros navais brasileiros nas atividades de conserva��o, moderniza��o, convers�o e reparo de embarca��es pr�-registradas ou registradas no Registro Especial Brasileiro (REB)"
	AAdd(aFKX,{cFilFKX,"15051",STR0242,"2","2","2","3","4","2","1",STR0243}) //"Pagamento efetuado a empresas estrangeiras transp.valores" ## "Pagamento efetuado a empresas estrangeiras de transporte de valores"
	AAdd(aFKX,{cFilFKX,"15052",STR0369,"2","2","2","3","4","2","1",STR0370}) //"Demais comiss�es, corretagens, ou qualquer outra import�ncia" ## "Demais comiss�es, corretagens, ou qualquer outra import�ncia paga/creditada pela representa��o comercial ou pela media��o na realiza��o de neg�cios civis e comerciais, que n�o se enquadrem nas situa��es listadas nos c�digos do grupo 20" 
	AAdd(aFKX,{cFilFKX,"15099",STR0244,"2","2","2","3","4","2","2",STR0245}) //"Demais Rendimentos de servi�os t�cnicos" ## "Demais Rendimentos de servi�os t�cnicos, de assist�ncia t�cnica, de assist�ncia administrativa e semelhantes"
    
	// - Grupo 16 - Demais Rendimentos de Residentes ou domiciliados no Exterior
	AAdd(aFKX,{cFilFKX,"16001",STR0246,"2","2","2","2","2","3","1",STR0247}) //"Rendimentos de servi�os t�cnicos" ## "Rendimentos de servi�os t�cnicos, de assist�ncia t�cnica, de assist�ncia administrativa e semelhantes"
	AAdd(aFKX,{cFilFKX,"16002",STR0248,"2","2","2","2","2","3","1",STR0248}) //"Demais Rendimentos de juros e comiss�es"
	AAdd(aFKX,{cFilFKX,"16003",STR0249,"2","2","2","3","2","3","1",STR0249}) //"Rendimento pago a companhia de navega��o a�rea e mar�tima"
	AAdd(aFKX,{cFilFKX,"16004",STR0250,"2","2","2","2","2","3","1",STR0251}) //"Rendimento de Direito relativo a explora��o de obras" ## "Rendimento de Direito relativo a explora��o de obras audiovisuais estrangeiras, radiodifus�o de sons e imagens e servi�o de comunica��o eletr�nica de massa por assinatura"
	AAdd(aFKX,{cFilFKX,"16005",STR0252,"2","2","2","2","2","3","1",STR0252}) //"Demais Rendimentos de qualquer natureza"
	AAdd(aFKX,{cFilFKX,"16006",STR0253,"2","2","2","2","2","3","" ,STR0253}) //"Demais Rendimentos sujeitos � Al�quota Zero"

	// - Grupo 17 - Rendimentos pagos/creditados EXCLUSIVAMENTE por �rg�os da administra��o federal direta, autarquias e
	//              funda��es federais, empresas p�blicas, sociedades de economia mista e demais entidades em que a Uni�o, direta
	//				ou indiretamente detenha a maioria do capital social sujeito a voto, e que recebam recursos do Tesouro Nacional
	AAdd(aFKX,{cFilFKX,"17001",STR0254,"2","2","","3","4","2","2",STR0254}) //"Alimenta��o"
	AAdd(aFKX,{cFilFKX,"17002",STR0255,"2","2","","3","4","2","2",STR0255}) //"Energia el�trica"
	AAdd(aFKX,{cFilFKX,"17003",STR0256,"2","2","","3","4","2","2",STR0256}) //"Servi�os prestados com emprego de materiais"
	AAdd(aFKX,{cFilFKX,"17004",STR0257,"2","2","","3","4","2","2",STR0257}) //"Constru��o Civil por empreitada com emprego de materiais"
	AAdd(aFKX,{cFilFKX,"17005",STR0258,"2","2","","3","4","2","2",STR0259}) //"Servi�os hospitalares de que trata o art. 30" ## "Servi�os hospitalares de que trata o art. 30 da Instru��o Normativa RFB n� 1.234, de 11 de janeiro de 2012"
	AAdd(aFKX,{cFilFKX,"17006",STR0260,"2","2","","3","4","2","2",STR0261}) //"Transporte de cargas, exceto da natureza de rend. 17017" ## "Transporte de cargas, exceto os relacionados na natureza de rendimento 17017"
	AAdd(aFKX,{cFilFKX,"17007",STR0262,"2","2","","3","4","2","2",STR0263}) //"Servi�os de aux�lio diagn�stico e terapia" ## "Servi�os de aux�lio diagn�stico e terapia, patologia cl�nica, imagenologia, anatomia patol�gica e citopatol�gica, medicina nuclear e an�lises e patologias cl�nicas, exames por m�todos gr�ficos, procedimentos endosc�picos, radioterapia, quimioterapia, di�lise e oxigenoterapia hiperb�rica de que trata o art. 31 e par�grafo �nico da Instru��o Normativa RFB n� 1.234, de 2012"
	AAdd(aFKX,{cFilFKX,"17008",STR0264,"2","2","","3","4","2","2",STR0265}) //"Produtos farm, de perf, de toucador ou de higiene pessoal" ## "Produtos farmac�uticos, de perfumaria, de toucador ou de higiene pessoal adquiridos de produtor, importador, distribuidor ou varejista, exceto os relacionados nas naturezas de rendimento de 17019 a 17022"
	AAdd(aFKX,{cFilFKX,"17009",STR0266,"2","2","","3","4","2","2",STR0266}) //"Mercadorias e bens em geral"
	AAdd(aFKX,{cFilFKX,"17010",STR0267,"2","2","","3","4","2","2",STR0268}) //"Gasolina, inclusive de avia��o, �leo diesel, g�s liquefeito" ## "Gasolina, inclusive de avia��o, �leo diesel, g�s liquefeito de petr�leo (GLP), combust�veis derivados de petr�leo ou de g�s natural, querosene de avia��o (QAV), e demais produtos derivados de petr�leo, adquiridos de refinarias de petr�leo, de demais produtores, de importadores, de distribuidor ou varejista"
	AAdd(aFKX,{cFilFKX,"17011",STR0269,"2","2","","3","4","2","2",STR0270}) //"�lcool et�lico hidratado, inclusive para fins carburantes"  ## "�lcool et�lico hidratado, inclusive para fins carburantes, adquirido diretamente de produtor, importador ou do distribuidor"
	AAdd(aFKX,{cFilFKX,"17012",STR0271,"2","2","","3","4","2","2",STR0271}) //"Biodiesel adquirido de produtor ou importador"
	AAdd(aFKX,{cFilFKX,"17013",STR0272,"2","2","","3","4","2","5",STR0273}) //"Gasolina, exceto gasolina de avia��o,�leo diesel e g�s liq." ## "Gasolina, exceto gasolina de avia��o, �leo diesel e g�s liquefeito de petr�leo (GLP), derivados de petr�leo ou de g�s natural e querosene de avia��o adquiridos de distribuidores e comerciantes varejistas"
	AAdd(aFKX,{cFilFKX,"17014",STR0274,"2","2","","3","4","2","5",STR0275}) //"�lcool et�lico hidratado nacional" ## "�lcool et�lico hidratado nacional, inclusive para fins carburantes adquirido de comerciante varejista"
	AAdd(aFKX,{cFilFKX,"17015",STR0276,"2","2","","3","4","2","5",STR0277}) //"Biodiesel adquirido de distrib. e comerciantes varejistas" ## "Biodiesel adquirido de distribuidores e comerciantes varejistas"
	AAdd(aFKX,{cFilFKX,"17016",STR0278,"2","2","","3","4","2","5",STR0279}) //"Biodiesel adq. prod.detentor reg. selo Combust�vel Social" ## "Biodiesel adquirido de produtor detentor regular do selo Combust�vel Social, fabricado a partir de mamona ou fruto, caro�o ou am�ndoa de palma produzidos nas regi�es norte e nordeste e no semi�rido, por agricultor familiar enquadrado noPrograma Nacional de Fortalecimento da Agricultura Familiar (Pronaf)"
	AAdd(aFKX,{cFilFKX,"17017",STR0280,"2","2","","3","4","2","5",STR0281}) //"Transporte inter. de cargas efetuado por empresas nacionais" ## "Transporte internacional de cargas efetuado por empresas nacionais"
	AAdd(aFKX,{cFilFKX,"17018",STR0282,"2","2","","3","4","2","5",STR0283}) //"Estaleiros navais brasileiros nas atividades de Constru��o" ## "Estaleiros navais brasileiros nas atividades de Constru��o, conserva��o, moderniza��o, convers�o e reparo de embarca��es pr�registradas ou registradas no REB"
	AAdd(aFKX,{cFilFKX,"17019",STR0284,"2","2","","3","4","2","5",STR0285}) //"Produtos de perfumaria, de toucador e de higiene pessoal" ## "Produtos de perfumaria, de toucador e de higiene pessoal a que se refere o � 1� do art. 22 da Instru��o Normativa RFB n� 1.234, de 2012, adquiridos de distribuidores e de comerciantes varejistas"
	AAdd(aFKX,{cFilFKX,"17020",STR0286,"2","2","","3","4","2","5",STR0287}) //"Produtos a que se refere o � 2� do art. 22" ## "Produtos a que se refere o � 2� do art. 22 da Instru��o Normativa RFB n� 1.234, de 2012"
	AAdd(aFKX,{cFilFKX,"17021",STR0288,"2","2","","3","4","2","5",STR0289}) //"Produtos de que tratam as al�neas c a k" ## "Produtos de que tratam as al�neas c a k do inciso I do art. 5� da Instru��o Normativa RFB n� 1.234, de 2012"
	AAdd(aFKX,{cFilFKX,"17022",STR0290,"2","2","","3","4","2","5",STR0291}) //"Outros produtos ou servi�os beneficiados com isen��o" ## "Outros produtos ou servi�os beneficiados com isen��o, n�o incid�ncia ou al�quotas zero da Cofins e da Contribui��o para o PIS/Pasep, observado o disposto no � 5� do art. 2� da Instru��o Normativa RFB n� 1.234, de 2012"
	AAdd(aFKX,{cFilFKX,"17023",STR0292,"2","2","","3","4","2","2",STR0293}) //"Passagens a�reas, rodov. e demais serv. transp. passageiros" ## "Passagens a�reas, rodovi�rias e demais servi�os de transporte de passageiros, inclusive, tarifa de embarque, exceto transporte internacional de passageiros, efetuado por empresas nacionais"
	AAdd(aFKX,{cFilFKX,"17024",STR0294,"2","2","","3","4","2","5",STR0295}) //"Transporte intern. passageiros efetuado por empr. nacionais" ## "Transporte internacional de passageiros efetuado por empresas nacionais"
	AAdd(aFKX,{cFilFKX,"17025",STR0296,"2","2","","3","4","2","2",STR0297}) //"Servi�os prestados por associa��es profissionais" ## "Servi�os prestados por associa��es profissionais ou assemelhadas e cooperativas"
	AAdd(aFKX,{cFilFKX,"17026",STR0298,"2","2","","3","4","2","2",STR0299}) //"Servi�os prestados por bancos comerciais" ## "Servi�os prestados por bancos comerciais, bancos de investimento, bancos de desenvolvimento, caixas econ�micas, sociedades de cr�dito, financiamento e investimento, sociedades de cr�dito imobili�rio, e c�mbio, distribuidoras de t�tulos e valores mobili�rios, empresas de arrendamento mercantil, cooperativas de cr�dito, empresas de seguros privados e de capitaliza��o e entidades abertas de previd�ncia complementar"
	AAdd(aFKX,{cFilFKX,"17027",STR0300,"2","2","","3","4","2","2",STR0300}) //"Seguro Sa�de"
	AAdd(aFKX,{cFilFKX,"17028",STR0301,"2","2","","3","4","2","2",STR0301}) //"Servi�os de abastecimento de �gua"
	AAdd(aFKX,{cFilFKX,"17029",STR0302,"2","2","","3","4","2","2",STR0302}) //"Telefone"
	AAdd(aFKX,{cFilFKX,"17030",STR0303,"2","2","","3","4","2","2",STR0303}) //"Correio e tel�grafos"
	AAdd(aFKX,{cFilFKX,"17031",STR0304,"2","2","","3","4","2","2",STR0304}) //"Vigil�ncia"
	AAdd(aFKX,{cFilFKX,"17032",STR0305,"2","2","","3","4","2","2",STR0305}) //"Limpeza"
	AAdd(aFKX,{cFilFKX,"17033",STR0306,"2","2","","3","4","2","2",STR0306}) //"Loca��o de m�o de obra"
	AAdd(aFKX,{cFilFKX,"17034",STR0307,"2","2","","3","4","2","2",STR0307}) //"Intermedia��o de neg�cios"
	AAdd(aFKX,{cFilFKX,"17035",STR0308,"2","2","","3","4","2","2",STR0309}) //"Administra��o, loca��o ou cess�o de bens im�veis" ## "Administra��o, loca��o ou cess�o de bens im�veis, m�veis e direitos de qualquer natureza"
	AAdd(aFKX,{cFilFKX,"17036",STR0310,"2","2","","3","4","2","2",STR0310}) //"Factoring"
	AAdd(aFKX,{cFilFKX,"17037",STR0311,"2","2","","3","4","2","2",STR0312}) //"Plano de sa�de humano, veterin�rio ou odontol�gico" ## "Plano de sa�de humano, veterin�rio ou odontol�gico com valores fixos por servidor, por empregado ou por animal"
	AAdd(aFKX,{cFilFKX,"17038",STR0313,"2","2","","3","4","2","8",STR0314}) //"Pagamento efetuado a soc.cooperativa pelo forn. de bens" ## "Pagamento efetuado a sociedade cooperativa pelo fornecimento de bens, conforme art. 24, da IN 1234/12."
	AAdd(aFKX,{cFilFKX,"17039",STR0315,"2","2","","3","4","2","" ,STR0316}) //"Pagamento a Cooperativa de produ��o" ## "Pagamento a Cooperativa de produ��o, em rela��o aos atos decorrentes da comercializa��o ou da industrializa��o de produtos de seus associados, excetuado o previsto no �� 1� e 2� do art. 25 da IN 1.234/12"
	AAdd(aFKX,{cFilFKX,"17040",STR0296,"2","2","","3","4","2","2",STR0317}) //"Servi�os prestados por associa��es profissionais" ## "Servi�os prestados por associa��es profissionais ou assemelhadas e cooperativas que envolver parcela de servi�os fornecidos por terceiros n�o cooperados ou n�o associados, contratados ou conveniados, para cumprimento de contratos Servi�os prestados com emprego de materiais, inclusive o de que trata a al�nea C do Inciso II do art. 27 da IN 1.1234."
	AAdd(aFKX,{cFilFKX,"17041",STR0296,"2","2","","3","4","2","2",STR0318}) //"Servi�os prestados por associa��es profissionais" ## "Servi�os prestados por associa��es profissionais ou assemelhadas e cooperativas que envolver parcela de servi�os fornecidos por terceiros n�o cooperados ou n�o associados, contratados ou conveniados, para cumprimento de contratos - Demais servi�os"
	AAdd(aFKX,{cFilFKX,"17042",STR0319,"2","2","","3","4","2","2",STR0320}) //"Pagamentos efetuados �s associa��es e �s cooperativas" ## "Pagamentos efetuados �s associa��es e �s cooperativas de m�dicos e de odont�logos, relativamente �s import�ncias recebidas a t�tulo de comiss�o, taxa de administra��o ou de ades�o ao plano"
	AAdd(aFKX,{cFilFKX,"17043",STR0321,"2","2","","3","4","2","2",STR0322}) //"Pagamento efetuado a sociedade cooperativa de produ��o" ## "Pagamento efetuado a sociedade cooperativa de produ��o, em rela��o aos atos decorrentes da comercializa��o ou de industrializa��o, pelas cooperativas agropecu�rias e de pesca, de produtos adquiridos de n�o associados, agricultores, pecuaristas ou pescadores, para completar lotes destinados aoa cumprimento de contratos ou para suprir capacidade ociosa de suas instala��es industriais, conforme � 1� do art. 25, da IN 1234/12."
	AAdd(aFKX,{cFilFKX,"17044",STR0323,"2","2","","3","4","2","7",STR0324}) //"Pagamento referente a aluguel de im�vel" ## "Pagamento referente a aluguel de im�vel quando efetuado � entidade aberta de previd�ncia complementar sem fins lucrativos, de que trata o art 34, � 2� da IN 1.234/2012."
	AAdd(aFKX,{cFilFKX,"17045",STR0325,"2","2","","3","4","2","4",STR0326}) //"Servi�os prestados por cooperativas de radiotaxi" ##  "Servi�os prestados por cooperativas de radiotaxi, bem como �quelas cujos cooperados se dediquem a servi�os relacionados a atividades culturais e demais cooperativas de servi�os, conforme art. 5� A, da IN RFB 1.234/2012."
	AAdd(aFKX,{cFilFKX,"17046",STR0327,"2","2","","3","4","2","2",STR0328}) // "Pagamento efetuado na aquisi��o de bem im�vel" ## "Pagamento efetuado na aquisi��o de bem im�vel, quando o vendedor for pessoa jur�dica que exerce a atividade de compra e venda de im�veis, ou quando se tratar de im�veis adquiridos de entidades abertas de previd�ncia complementar com fins lucrativos, conforme art. 23, inc I, da IN RFB 1234/2012."
	AAdd(aFKX,{cFilFKX,"17047",STR0327,"2","2","","3","4","2","5",STR0329}) //"Pagamento efetuado na aquisi��o de bem im�vel" ## "Pagamento efetuado na aquisi��o de bem im�vel adquirido pertencente ao ativo n�o circulante da empresa vendedora, conforme art. 23, inc II da IN RFB 1234/2012."
	AAdd(aFKX,{cFilFKX,"17048",STR0327,"2","2","","3","4","2","7",STR0330}) //"Pagamento efetuado na aquisi��o de bem im�vel" ## "Pagamento efetuado na aquisi��o de bem im�vel adquirido de entidade aberta de previd�ncia complementar sem fins lucrativos, conforme art. 23, inc III, da IN RFB 1234/2012."
	AAdd(aFKX,{cFilFKX,"17049",STR0331,"2","2","","3","4","2","2",STR0332}) //"Propaganda e Publ. em desconformidade ao art 16 da IN RFB" ## "Propaganda e Publicidade, em desconformidade ao art 16 da IN RFB 1234/2012, referente ao � 4� do citado artigo."
	AAdd(aFKX,{cFilFKX,"17050",STR0333,"2","2","","3","4","2","8",STR0334}) //"Propaganda e Publ. em conformidade ao art 16 da IN RFB" ## "Propaganda e Publicidade, em conformidade ao art 16 da IN RFB 1234/2012, referente ao � 4� do citado artigo."
	AAdd(aFKX,{cFilFKX,"17099",STR0335,"2","2","","3","4","2","2",STR0335}) //"Demais servi�os"

	// - Grupo 18 - Rendimentos pagos/creditados EXCLUSIVAMENTE por �rg�os, autarquias e funda��es dos estados, do Distrito Federal e dos munic�pios
	AAdd(aFKX,{cFilFKX,"18001",STR0336,"2","2","","3","4","2","8",STR0337}) //"Fornecimento de bens, nos termos do art.33 da Lei n� 10.833" ## "Fornecimento de bens, nos termos do art.33 da Lei n� 10.833, de 2003"
	AAdd(aFKX,{cFilFKX,"18002",STR0338,"2","2","","3","4","2","8",STR0339}) //"Presta��o de servi�os em geral, nos termos do art. 33" ## "Presta��o de servi�os em geral, nos termos do art. 33 da Lei n� 10.833, de 2003"
	AAdd(aFKX,{cFilFKX,"18003",STR0340,"2","2","","3","4","2","6",STR0341}) //"Transporte internacional de cargas ou de passageiros" ## "Transporte internacional de cargas ou de passageiros efetuados por empresas nacionais, aos estaleiros navais brasileiros e na aquisi��o de produtos isentos ou com Al�quota zero da Cofins e Pis/Pasep, conforme art. 4�, da IN SRF n� 475 de 2004."
	AAdd(aFKX,{cFilFKX,"18004",STR0342,"2","2","","3","4","2","3",STR0343}) //"Pagamentos efetuados �s cooperativas" ## "Pagamentos efetuados �s cooperativas, em rela��o aos atos cooperativos, conforme art. 5�, da IN SRF n� 475 de 2004."
	AAdd(aFKX,{cFilFKX,"18005",STR0344,"2","2","","3","4","2","6",STR0345}) //"Aquisi��o de im�vel pertencente a ativo permanente" ## "Aquisi��o de im�vel pertencente a ativo permanente da empresa vendedora, conforme art. 19, II, da IN SRF n� 475 de 2004."
	AAdd(aFKX,{cFilFKX,"18006",STR0346,"2","2","","3","4","2","3",STR0347}) //"Pagamentos efetuados �s sociedades cooperativas" ## "Pagamentos efetuados �s sociedades cooperativas, pelo fornecimento de bens ou servi�os, conforme art. 24, II, da IN SRF n� 475 de 2004."
	AAdd(aFKX,{cFilFKX,"18007",STR0348,"2","2","","3","4","2","" ,STR0349}) //"Pagamentos efetuados � sociedade cooperativa de produ��o" ## "Pagamentos efetuados � sociedade cooperativa de produ��o, em rela��o aos atos decorrentes da comercializa��o ou industrializa��o de produtos de seus associados, conforme art. 25, da IN SRF n� 475 de 2004."
	AAdd(aFKX,{cFilFKX,"18008",STR0350,"2","2","","3","4","2","8",STR0351}) //"Pagamentos efetuados �s cooperativas de trabalho" ## "Pagamentos efetuados �s cooperativas de trabalho, pela presta��o de servi�os pessoais prestados pelos cooperados, nos termos do art. 26, da IN SRF n� 475 de 2004."

	// - Grupo 19 - Pagamento a Benefici�rio n�o Identificado Uso exclusivo para o evento R-4040
	AAdd(aFKX,{cFilFKX,"19001",STR0352,"2","2","","4","3","2","1",STR0353}) //"Pagamento de remunera��o indireta a Benef. n�o identificado" ## "Pagamento de remunera��o indireta a Benefici�rio n�o identificado"
	AAdd(aFKX,{cFilFKX,"19009",STR0354,"2","2","","4","3","2","1",STR0354}) //"Pagamento a Benefici�rio n�o identificado"

	// - Grupo 20 - Rendimentos a Pessoa Jur�dica Reten��o no recebimento
	AAdd(aFKX,{cFilFKX,"20001",STR0355,"2","2","2","3","4","2","1",STR0355}) //"Rendimento de Servi�os de propaganda e publicidade"
	AAdd(aFKX,{cFilFKX,"20002",STR0356,"2","2","2","3","4","2","1",STR0357}) //"Import�ncias a t�tulo de comiss�es e corretagens relativas" ## "Import�ncias a t�tulo de comiss�es e corretagens relativas a coloca��o ou negocia��o de t�tulos de renda fixa"
	AAdd(aFKX,{cFilFKX,"20003",STR0356,"2","2","2","3","4","2","1",STR0358}) //"Import�ncias a t�tulo de comiss�es e corretagens relativas" ## "Import�ncias a t�tulo de comiss�es e corretagens relativas a opera��es realizadas em Bolsas de Valores e em Bolsas de Mercadorias"
	AAdd(aFKX,{cFilFKX,"20004",STR0356,"2","2","2","3","4","2","1",STR0359}) //"Import�ncias a t�tulo de comiss�es e corretagens relativas" ## "Import�ncias a t�tulo de comiss�es e corretagens relativas a distribui��o de emiss�o de valores mobili�rios, quando a pessoa jur�dica atuar como agente da companhia emissora"
	AAdd(aFKX,{cFilFKX,"20005",STR0356,"2","2","2","3","4","2","1",STR0360}) //"Import�ncias a t�tulo de comiss�es e corretagens relativas" ## "Import�ncias a t�tulo de comiss�es e corretagens relativas a opera��es de c�mbio"
	AAdd(aFKX,{cFilFKX,"20006",STR0356,"2","2","2","3","4","2","1",STR0361}) //"Import�ncias a t�tulo de comiss�es e corretagens relativas" ## "Import�ncias a t�tulo de comiss�es e corretagens relativas a vendas de passagens, excurs�es ou viagens"
	AAdd(aFKX,{cFilFKX,"20007",STR0356,"2","2","2","3","4","2","1",STR0362}) //"Import�ncias a t�tulo de comiss�es e corretagens relativas" ## "Import�ncias a t�tulo de comiss�es e corretagens relativas a administra��o de cart�es de cr�dito"
	AAdd(aFKX,{cFilFKX,"20008",STR0356,"2","2","2","3","4","2","1",STR0363}) //"Import�ncias a t�tulo de comiss�es e corretagens relativas" ## "Import�ncias a t�tulo de comiss�es e corretagens relativas a presta��o de servi�os de distribui��o de refei��es pelo sistema de refei��es-conv�nio"
	AAdd(aFKX,{cFilFKX,"20009",STR0356,"2","2","2","3","4","2","1",STR0364}) //"Import�ncias a t�tulo de comiss�es e corretagens relativas" ## "Import�ncias a t�tulo de comiss�es e corretagens relativas a presta��o de servi�o de administra��o de conv�nios"
	AAdd(aFKX,{cFilFKX,"20010",STR0365,"2","2","2","3","4","2","1",STR0366}) //"Demais Import�ncias a t�tulo de comiss�es, corretagens" ## "Demais Import�ncias a t�tulo de comiss�es, corretagens, ou qualquer outra import�ncia paga/creditada pela representa��o comercial ou pela media��o na realiza��o de neg�cios civis e comerciais"

	// Dedu��o Grupo 10 - Rendimento do Trabalho e da Previd�ncia Social
	AAdd(aFKZ,{cFilFKX,"10001","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"10001","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"10001","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"10001","1","4 ","  "})
	AAdd(aFKZ,{cFilFKX,"10001","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"10001","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"10002","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"10002","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"10002","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"10002","1","4 ","  "})
	AAdd(aFKZ,{cFilFKX,"10002","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"10002","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"10003","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"10003","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"10003","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"10003","1","4 ","  "})
	AAdd(aFKZ,{cFilFKX,"10003","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"10003","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"10004","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"10004","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"10004","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"10004","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"10004","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"10005","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"10005","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"10005","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"10005","1","5 ","  "})

	AAdd(aFKZ,{cFilFKX,"10006","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"10006","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"10006","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"10006","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"10006","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"10008","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"10008","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"10008","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"10008","1","4 ","  "})
	AAdd(aFKZ,{cFilFKX,"10008","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"10008","1","7 ","  "})

	// Dedu��o Grupo 11 - Rendimento decorrente de Decis�o Judicial
	AAdd(aFKZ,{cFilFKX,"11001","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"11001","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"11001","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"11002","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"11002","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"11002","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"11002","1","4 ","  "})
	AAdd(aFKZ,{cFilFKX,"11002","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"11002","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"11003","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"11003","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"11003","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"11003","1","4 ","  "})
	AAdd(aFKZ,{cFilFKX,"11003","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"11003","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"11004","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"11004","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"11004","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"11004","1","4 ","  "})
	AAdd(aFKZ,{cFilFKX,"11004","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"11004","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"11005","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"11005","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"11005","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"11005","1","4 ","  "})
	AAdd(aFKZ,{cFilFKX,"11005","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"11005","1","7 ","  "})

	// Dedu��o Grupo 12 - Rendimento do Capital
	AAdd(aFKZ,{cFilFKX,"12009","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"12009","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"12009","1","4 ","  "})
	AAdd(aFKZ,{cFilFKX,"12009","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"12009","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"12010","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"12010","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"12010","1","4 ","  "})
	AAdd(aFKZ,{cFilFKX,"12010","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"12010","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"12011","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"12011","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"12011","1","4 ","  "})
	AAdd(aFKZ,{cFilFKX,"12011","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"12011","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"12045","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"12045","1","5 ","  "})

	// Dedu��o Grupo 13 - Rendimento de Direitos (Royalties)
	AAdd(aFKZ,{cFilFKX,"13001","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13001","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13001","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13002","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13002","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13002","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13003","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13003","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13003","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13004","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13004","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13004","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13005","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13005","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13005","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13006","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13006","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13006","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13007","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13007","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13007","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13008","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13008","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13008","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13009","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13009","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13009","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13010","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13010","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13010","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13011","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13011","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13011","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13012","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13012","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13012","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13013","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13013","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13013","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13014","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13014","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13014","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13015","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13015","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13015","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13016","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13016","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13016","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13017","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13017","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13017","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13018","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13018","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13018","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13019","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13019","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13019","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13020","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13020","1","5 ","  "})

	AAdd(aFKZ,{cFilFKX,"13021","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13021","1","5 ","  "})

	AAdd(aFKZ,{cFilFKX,"13022","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13022","1","5 ","  "})

	AAdd(aFKZ,{cFilFKX,"13023","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13023","1","5 ","  "})

	AAdd(aFKZ,{cFilFKX,"13025","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13025","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13025","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13026","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13026","1","5 ","  "})

	AAdd(aFKZ,{cFilFKX,"13098","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13098","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13098","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13099","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13099","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13099","1","7 ","  "})


	// Isen��o Grupo 10 - Rendimento do Trabalho e da Previd�ncia Social
	AAdd(aFKZ,{cFilFKX,"10001","2","  ","2 "})
	AAdd(aFKZ,{cFilFKX,"10001","2","  ","3 "})
	AAdd(aFKZ,{cFilFKX,"10001","2","  ","4 "})
	AAdd(aFKZ,{cFilFKX,"10001","2","  ","5 "})
	AAdd(aFKZ,{cFilFKX,"10001","2","  ","8 "})
	AAdd(aFKZ,{cFilFKX,"10001","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"10002","2","  ","2 "})
	AAdd(aFKZ,{cFilFKX,"10002","2","  ","3 "})
	AAdd(aFKZ,{cFilFKX,"10002","2","  ","4 "})
	AAdd(aFKZ,{cFilFKX,"10002","2","  ","5 "})
	AAdd(aFKZ,{cFilFKX,"10002","2","  ","8 "})
	AAdd(aFKZ,{cFilFKX,"10002","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"10003","2","  ","2 "})
	AAdd(aFKZ,{cFilFKX,"10003","2","  ","3 "})
	AAdd(aFKZ,{cFilFKX,"10003","2","  ","4 "})
	AAdd(aFKZ,{cFilFKX,"10003","2","  ","5 "})
	AAdd(aFKZ,{cFilFKX,"10003","2","  ","8 "})
	AAdd(aFKZ,{cFilFKX,"10003","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"10005","2","  ","1 "})
	AAdd(aFKZ,{cFilFKX,"10005","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"10005","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"10006","2","  ","1 "})
	AAdd(aFKZ,{cFilFKX,"10006","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"10006","2","  ","99"})

	// Isen��o Grupo 11 - Rendimento decorrente de Decis�o Judicial
	AAdd(aFKZ,{cFilFKX,"11001","2","  ","2 "})
	AAdd(aFKZ,{cFilFKX,"11001","2","  ","3 "})
	AAdd(aFKZ,{cFilFKX,"11001","2","  ","4 "})
	AAdd(aFKZ,{cFilFKX,"11001","2","  ","5 "})
	AAdd(aFKZ,{cFilFKX,"11001","2","  ","7 "})
	AAdd(aFKZ,{cFilFKX,"11001","2","  ","8 "})
	AAdd(aFKZ,{cFilFKX,"11001","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"11002","2","  ","1 "})
	AAdd(aFKZ,{cFilFKX,"11002","2","  ","2 "})
	AAdd(aFKZ,{cFilFKX,"11002","2","  ","3 "})
	AAdd(aFKZ,{cFilFKX,"11002","2","  ","4 "})
	AAdd(aFKZ,{cFilFKX,"11002","2","  ","5 "})
	AAdd(aFKZ,{cFilFKX,"11002","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"11002","2","  ","7 "})
	AAdd(aFKZ,{cFilFKX,"11002","2","  ","8 "})
	AAdd(aFKZ,{cFilFKX,"11002","2","  ","9 "})
	AAdd(aFKZ,{cFilFKX,"11002","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"11003","2","  ","1 "})
	AAdd(aFKZ,{cFilFKX,"11003","2","  ","2 "})
	AAdd(aFKZ,{cFilFKX,"11003","2","  ","3 "})
	AAdd(aFKZ,{cFilFKX,"11003","2","  ","4 "})
	AAdd(aFKZ,{cFilFKX,"11003","2","  ","5 "})
	AAdd(aFKZ,{cFilFKX,"11003","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"11003","2","  ","7 "})
	AAdd(aFKZ,{cFilFKX,"11003","2","  ","8 "})
	AAdd(aFKZ,{cFilFKX,"11003","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"11004","2","  ","1 "})
	AAdd(aFKZ,{cFilFKX,"11004","2","  ","2 "})
	AAdd(aFKZ,{cFilFKX,"11004","2","  ","3 "})
	AAdd(aFKZ,{cFilFKX,"11004","2","  ","4 "})
	AAdd(aFKZ,{cFilFKX,"11004","2","  ","5 "})
	AAdd(aFKZ,{cFilFKX,"11004","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"11004","2","  ","7 "})
	AAdd(aFKZ,{cFilFKX,"11004","2","  ","8 "})
	AAdd(aFKZ,{cFilFKX,"11004","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"11005","2","  ","1 "})
	AAdd(aFKZ,{cFilFKX,"11005","2","  ","2 "})
	AAdd(aFKZ,{cFilFKX,"11005","2","  ","3 "})
	AAdd(aFKZ,{cFilFKX,"11005","2","  ","4 "})
	AAdd(aFKZ,{cFilFKX,"11005","2","  ","5 "})
	AAdd(aFKZ,{cFilFKX,"11005","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"11005","2","  ","7 "})
	AAdd(aFKZ,{cFilFKX,"11005","2","  ","8 "})
	AAdd(aFKZ,{cFilFKX,"11005","2","  ","99"})

	// Isen��o Grupo 12 - Rendimento do Capital
	AAdd(aFKZ,{cFilFKX,"12002","2","  ","7 "})

	AAdd(aFKZ,{cFilFKX,"12003","2","  ","7 "})

	AAdd(aFKZ,{cFilFKX,"12004","2","  ","7 "})

	AAdd(aFKZ,{cFilFKX,"12005","2","  ","7 "})

	AAdd(aFKZ,{cFilFKX,"12006","2","  ","7 "})

	AAdd(aFKZ,{cFilFKX,"12009","2","  ","1 "})
	AAdd(aFKZ,{cFilFKX,"12009","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"12009","2","  ","7 "})
	AAdd(aFKZ,{cFilFKX,"12009","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"12010","2","  ","1 "})
	AAdd(aFKZ,{cFilFKX,"12010","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"12010","2","  ","7 "})
	AAdd(aFKZ,{cFilFKX,"12010","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"12011","2","  ","1 "})
	AAdd(aFKZ,{cFilFKX,"12011","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"12011","2","  ","7 "})
	AAdd(aFKZ,{cFilFKX,"12011","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"12012","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"12012","2","  ","7 "})

	AAdd(aFKZ,{cFilFKX,"12013","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"12013","2","  ","7 "})

	DbSelectArea("FKX")
	FKX->(DbSetOrder(1)) //FKX_FILIAL + FKX_CODIGO
	FKX->(DbGoTop())

	For nI := 1 To Len(aFKX)
		If !FKX->(DbSeek(aFKX[nI,1] + aFKX[nI,2]))
			FKX->(RecLock("FKX",.T.))
				FKX->FKX_FILIAL := aFKX[nI,1]
				FKX->FKX_CODIGO	:= aFKX[nI,2]
				FKX->FKX_DESCR	:= aFKX[nI,3]
				FKX->FKX_FCI	:= aFKX[nI,4]
				FKX->FKX_DECSAL	:= aFKX[nI,5]
				FKX->FKX_RRA	:= aFKX[nI,6]
				FKX->FKX_EXTPF 	:= aFKX[nI,7]
				FKX->FKX_EXTPJ 	:= aFKX[nI,8]
				FKX->FKX_TPDECL	:= aFKX[nI,9]			
				FKX->FKX_TRIBUT	:= aFKX[nI,10]
				FKX->FKX_DESEXT	:= aFKX[nI,11]
			FKX->(MsUnlock())
		EndIf
	Next nI

	DbSelectArea("FKZ")
	FKZ->(DbSetOrder(1)) //FKZ_FILIAL + FKZ_CODIGO + FKZ_DEDISE + FKZ_DEDUCA + FKZ_ISENCA
	FKZ->(DbGoTop())

	For nI := 1 To Len(aFKZ)
		If !FKZ->( DbSeek( aFKZ[nI,1] + aFKZ[nI,2] + aFKZ[nI,3] + aFKZ[nI,4] + aFKZ[nI,5] ) )
			FKZ->( RecLock("FKZ",.T.) )
				FKZ->FKZ_FILIAL	:= aFKZ[nI,1]
				FKZ->FKZ_CODIGO	:= aFKZ[nI,2]
				FKZ->FKZ_DEDISE	:= aFKZ[nI,3]
				FKZ->FKZ_DEDUCA	:= aFKZ[nI,4]
				FKZ->FKZ_ISENCA	:= aFKZ[nI,5]
			FKZ->( MsUnlock() )
		EndIf
	Next nI

	RestArea(aAreaFKZ)
	RestArea(aAreaFKX)
	RestArea(aAreaAtu)

Return()
