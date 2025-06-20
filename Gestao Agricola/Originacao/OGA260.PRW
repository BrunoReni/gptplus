#INCLUDE "OGA260.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} OGA260
Rotina para cadastro de contratos de compra, venda e ou armazenagem

@param: 	Nil
@author: 	Equipe Agroindustria  
@since: 	01/01/2015 
@Uso: 		SIGAAGR - Origina��o de Gr�os
*/
Function OGA260( pcCodEnt, pcLojEnt )
	Local oMBrowse := Nil
	Local cFiltroDef := "NJR_TIPO='3'" + iIf(!Empty(pcCodEnt),".AND.NJR_CODENT='"+pcCodEnt+"'","") + iIf(!Empty(pcLojEnt),".AND.NJR_LOJENT='"+pcLojEnt+"'","")
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NJR" )
	oMBrowse:SetDescription( STR0001 ) //"Contratos de Deposito De 3"
	oMBrowse:SetFilterDefault( cFiltroDef )
	oMBrowse:SetMenuDef( "OGA260" ) 
	oMBrowse:AddLegend( "(NJR_MODELO=='1')"											, "WHITE"		, X3CboxDesc( "NJR_MODELO", "1" )	) //"Pr�-Contrato"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='P'"	, "BLUE"		, X3CboxDesc( "NJR_STATUS", "P" )	) //"Previsto"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='A'"	, "GREEN"		, X3CboxDesc( "NJR_STATUS", "A" )	) //"Aberto"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='I'"	, "YELLOW"		, X3CboxDesc( "NJR_STATUS", "I" )	) //"Iniciado"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='E'"	, "BR_CANCEL"	, X3CboxDesc( "NJR_STATUS", "E" )	) //"Cancelado"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='F'"	, "RED"			, X3CboxDesc( "NJR_STATUS", "F" )	) //"Finalizado"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()
Return( )

/** {Protheus.doc} MenuDef
Fun��o que retorna os itens para constru��o do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since: 	01/01/2015
@Uso: 		OGA260 - Contratos
*/
Static Function MenuDef()
	Local aRotina  := {}
	Local aRotina1 := {} 

	aAdd( 	aRotina1, 	{ STR0060	, "OGA340(NJR->NJR_CODCTR)"			, 0, 4, 0, Nil } ) //"Autoriza��es"
	aAdd( 	aRotina1, 	{ STR0061	, "OGA335(NJR->NJR_CODCTR,NJR->NJR_FILIAL)"			, 0, 4, 0, Nil } ) //"Adic./Supres."
	aAdd( 	aRotina1, 	{ STR0062	, "OGA320(NJR->NJR_CODCTR,NJR->NJR_FILIAL)"			, 0, 4, 0, Nil } ) //"Status"
	aAdd( 	aRotina1, 	{ STR0063	, "OGC003(NJR->NJR_CODCTR)"			, 0, 4, 0, Nil } ) //"Romaneios"
	aAdd(   aRotina1,  	{ STR0067   , "OGR342(NJR->NJR_CODCTR, NJR->NJR_TIPO)" 	, 0, 4, 0, Nil } ) //"Imprimir Word"

	aAdd( 	aRotina, 	{ STR0008	, "PesqBrw"        			, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( 	aRotina, 	{ STR0009	, "ViewDef.OGA260"			, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( 	aRotina, 	{ STR0010	, "ViewDef.OGA260"			, 0, 3, 0, Nil } ) //"Incluir"
	aAdd( 	aRotina, 	{ STR0011	, "ViewDef.OGA260"			, 0, 4, 0, Nil } ) //"Alterar"
	aAdd(	aRotina,	{ STR0055	, "AGRCONHECIM('NJR')"			, 0, 4,  , .T. } ) //"Conhecimento"
	aAdd( 	aRotina, 	{ STR0012	, "OGA260C"				, 0, 4, 0, Nil } ) //"Confirmar"
	aAdd( 	aRotina, 	{ STR0013	, "OGA260E"				, 0, 4, 0, Nil } ) //"Cancelar"
	aAdd( 	aRotina, 	{ STR0014	, "OGA260F"				, 0, 4, 0, Nil } ) //"Finalizar"
	aAdd( 	aRotina, 	{ STR0015	, "OGA260R"				, 0, 4, 0, Nil } ) //"Reabrir"
	aAdd( 	aRotina, 	{ STR0016	, "ViewDef.OGA260"			, 0, 5, 0, Nil } ) //"Excluir"
	aAdd( 	aRotina, 	{ STR0017	, "ViewDef.OGA260"			, 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( 	aRotina, 	{ STR0070 	, "OGR340"				, 0, 8, 0, Nil } ) //"Imprimir Sint�tico"
	aAdd( 	aRotina, 	{ STR0019 	, "ViewDef.OGA260"			, 0, 9, 0, Nil } ) //"Copiar" 
	aAdd(	aRotina,  	{ STR0059	, "OGA260HIS"        			, 0, 7, 0, Nil } ) //"Hist�rico"
	aAdd(	aRotina,	{ STR0064	, aRotina1				, 0, 4, 0, Nil } ) //"Mais a��es..."
Return( aRotina )
	
	
/** {Protheus.doc} ModelDef
Fun��o que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since: 	01/01/2015
@Uso: 		OGA260 - Contratos
@type function
*/
Static Function ModelDef()
	Local oStruNJR 	:= FWFormStruct( 1, "NJR" )
	Local oStruNNY 	:= FWFormStruct( 1, "NNY" )
	Local oModel 	:= MPFormModel():New( "OGA260" , {| oModel | PreModelo( oModel ) }, {| oModel | PosModelo( oModel ) }, {| oModel | GrvModelo( oModel ) }  )
	
	oStruNJR:RemoveField( "NJR_CLASSP" )
	oStruNNY:RemoveField( "NNY_CODCTR" )	
	
	oStruNJR:SetProperty( "NJR_TABELA" , MODEL_FIELD_VALID	, FwBuildFeature( STRUCT_FEATURE_VALID,"OG260VDTB()") )

	//Tratamento TES inteligente.
	oStruNJR:AddTrigger( "NJR_OPEFIS", "NJR_TESEST", { || .T. }, { | x | AGRXTESINT() } ) 
	oStruNJR:AddTrigger( "NJR_CODENT", "NJR_TESEST", { || .T. }, { | x | AGRXTESINT() } ) 
	oStruNJR:AddTrigger( "NJR_LOJENT", "NJR_TESEST", { || .T. }, { | x | AGRXTESINT() } ) 
	oStruNJR:AddTrigger( "NJR_CODPRO", "NJR_TESEST", { || .T. }, { | x | AGRXTESINT() } )
	
	oStruNNY:SetProperty( "NNY_DATINI"	, MODEL_FIELD_VALID	, {| oField | ValNNYDATINI( oField ) } )

	oModel:SetDescription( STR0021 ) //"Contrato de Deposito De 3"

	oModel:AddFields( "NJRUNICO", /*cOwner*/, oStruNJR, {|oFieldModel, cAction, cIDField, xValue| PreValNJR(oFieldModel, cAction, cIDField, xValue)} , {| oField | AGRXPOSNJR( oField ) } /*bPost*/, /*bLoad */  )

	//--<< Campos que nao devem copiar no processo de copia >>--
	cFldsNCopy :=''
	cFldsNCopy += "NJR_CODCTR,NJR_ULTALT,NJR_DATA,NJR_CODRPC,NJR_AUTENT,NJR_AUTSAI,NJR_QTEFCO,NJR_QTEFIS,NJR_VLEFIS,"
	cFldsNCopy += "NJR_QTSEMB,NJR_QTSFCO,NJR_QTSFIS,NJR_VLSFIS,NJR_QSLEMB,NJR_QSLFCO,NJR_SLDFIS,NJR_SLDTO,NJR_QTDRES,"
	cFldsNCopy += "NJR_QTDQUE,NJR_VLRUNI,NJR_VLRTOT,NJR_TRANSF,NJR_MODELO,NJR_MODBAS,NJR_STSASS,NJR_STSFIS,NJR_STSFIN,"
	cFldsNCopy += "NJR_STSEST,NJR_STATUS,NJR_VLRBAS,NJR_QTDINI,NJR_QTDCTR,NJR_MODAL,NJR_INSCPO"
	aFldNCopy  := Separa(cFldsNCopy,',' )
	oModel:GetModel( "NJRUNICO" ):SetFldNoCopy( aFldNcopy ) // Na fun��o Copiar nao copia os campos de retornados em array

	oModel:GetModel( "NJRUNICO" ):SetDescription( STR0022 ) //"Dados do Contrato"

	oModel:AddGrid( "NNYUNICO", "NJRUNICO", oStruNNY,{|oModelGrid, nLine,cAction,cField,xVrNovo,xVrAnt|PreValNNY(oModelGrid, nLine, cAction, cField,xVrNovo,xVrAnt)} ,,, { | oGrid | AGRXPOSNNY( oGrid ) }, {|oGrid, lCopy| OGA260CpGr(oGrid, lCopy)})
	oModel:GetModel( "NNYUNICO" ):SetDescription( STR0023 ) //"Dados do Intervalo de Cad�ncia"
	oModel:GetModel( "NNYUNICO" ):SetUniqueLine( { "NNY_ITEM" } )

	oModel:GetModel( "NNYUNICO" ):SetOptional(.T.)

	oModel:GetModel( "NNYUNICO" ):SetFldNoCopy( Oga260NCopy( oModel:GetModel( "NNYUNICO" ) ) ) // Na fun��o Copiar nao copia os campos de retornados em array

	oModel:SetRelation( "NNYUNICO", { { "NNY_FILIAL", "xFilial( 'NNY' )" }, { "NNY_CODCTR", "NJR_CODCTR" } }, NNY->( IndexKey( 1 ) ) )

	oModel:SetVldActivate( { | oModel | IniModelo( oModel, oModel:GetOperation() ) } )
	oModel:SetActivate( 	{ | oMod   | ActivateMD( oMod,		oModel:GetOperation() ) } )

Return( oModel )

/*/{Protheus.doc} PreValNJR
	Pr� valida��o do modelo NJRUNICO
	@type  Static Function
	@author mauricio.joao
	@since 10/12/2019
	@version 1.0
/*/
Static Function PreValNJR(oFieldModel, cAction, cIDField, xValue)
	Local lRet := .T.

	//SETVALUE
	If cAction == "SETVALUE" .And. cIDField $ "NJR_VLRBAS|NJR_CODPRO|NJR_QTDINI"	
		//defino de onde buscar o valor base
		If cIDField == "NJR_VLRBAS"
			nValorBase := xValue
			oFieldModel:SetValue( "NJR_VLRUNI", xValue)
		Else 
		    nValorBase := oFieldModel:GetValue("NJR_VLRBAS")			
		EndIf
		//defino de onde buscar a quantidade inicial.
		If cIDField == "NJR_QTDINI"
			nQuantIni := xValue
		Else 
			nQuantIni := oFieldModel:GetValue("NJR_QTDINI")
		EndIf
		//valido o produto
		If cIDField == "NJR_CODPRO"
			//limpa o campo tabela.
			oFieldModel:LoadValue("NJR_TABELA",'')
	
			lRet := AGRXCODPRO(oFieldModel,xValue,oFieldModel:GetValue("NJR_TABELA"))
			Return lRet
		EndIf
		//busca o valor do convertido
		nValor := Round( nQuantIni * AGRX003( oFieldModel:GetValue("NJR_CODPRO"),;
																		oFieldModel:GetValue("NJR_UMPRC"),;
																		nValorBase,;
																		TamSX3('NJR_VLRBAS')[2]), TamSX3('NJR_VLRTOT')[2])
		//atribui o valor convertido
		oFieldModel:SetValue("NJR_VLRTOT", nValor)
	ElseIf cAction == "SETVALUE" .AND. cIDField $ "NJR_CODENT|NJR_LOJENT"
		If cIDField == "NJR_CODENT"
			lRet := AGRXVLFAV(oFieldModel,xValue,oFieldModel:GetValue("NJR_LOJENT"))
		Else
			lRet := AGRXVLFAV(oFieldModel,oFieldModel:GetValue("NJR_CODENT"),xValue)
		EndIf
		Return lRet	
	ElseIf cAction == "SETVALUE" .And. cIDField $ "NJR_CODTSE"
		//busca descri��o
		cDesc	:= Posicione( "NKP", 1, fWxFilial( "NKP" ) + xValue, "NKP_DESTSE" )	
		oFieldModel:SetValue("NJR_DESTSE", Alltrim(cDesc))
	EndIf

	//CANSETVALUE
	If cAction == "CANSETVALUE" .And. cIDField $ "NJR_CODTSE"
		//buca a descri��o do 
		cDesc	:= Posicione( "NKP", 1, fWxFilial( "NKP" ) + xValue, "NKP_DESTSE" )	
		oFieldModel:SetValue("NJR_DESTSE", Alltrim(cDesc))
	ElseIf cAction == "ISENABLE" .AND. cIDField $ "NJRUNICO" .AND. oFieldModel:GetOperation() == 3
		oFieldModel:SetValue("NJR_TIPO",'3')
		oFieldModel:SetValue("NJR_MODELO",'2')
	EndIf  

Return lRet

/*/{Protheus.doc} PreValNNY
pr� valida��o do modelo NNYUNICO
@type function
@version  12
@author mauricio.joao
@since 12/12/2019
@param oModelNNY, object, objeto de modelo do FormGrid NNY
@param nLinha, numeric, numero da linha atual da grid posicionada
@param cAcao, character, a��o que esta sendo realizado (UNDELETE|DELETE|SETVALUE|CANSETVALUE)
@param cCampo, character, ID do campo quando SETVALUE e CANSETVALUE
@param xVrNovo, variant, o valor que est� sendo atribu�do quando SETVALUE 
@param xVrAnt, variant, o valor que est� no campo quando SETVALUE
@return Logical, retorno logico verdadeiro(.T.) ou falso(.F.)
/*/
Static Function PreValNNY(oModelNNY, nLinha, cAcao, cCampo,xVrNovo,xVrAnt)
 	Local lRet		:= .T.
	
	lRet := AGRXPRVNNY(oModelNNY, nLinha, cAcao, cCampo,xVrNovo,xVrAnt)

Return lRet

/*/{Protheus.doc} ActivateMD
Fun��o executada logo apos ativar o modelo de dados
@type function
@version  P12
@author claudineia.reinert
@since 6/1/2023
@param oModel, object, objeto do modelo da rotina
@param nOperation, numeric, opera��o do modelo 
/*/
Static Function ActivateMD( oModel, nOperation )
	Local aArea		:= GetArea()
	Local lRet		:= .T.

  	lRet := AGRXACTMDC(oModel, nOperation)

	RestArea(aArea)
Return lRet

/** {Protheus.doc} ViewDef
Fun��o que retorna a view para o modelo padrao da rotina
Funcao AGRColPos no fonte AGRUTIL01 

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	01/01/2015
@Uso: 		OGA260 - Contratos
*/
Static Function ViewDef()
	Local oStruNJR	:= FWFormStruct( 2, "NJR" )
	Local oStruNNY	:= FWFormStruct( 2, "NNY" )
	Local oModel	:= FWLoadModel( "OGA260" )
	Local oView	    := FWFormView():New()
    Local nIt       := 0
    Local aFields   := {}   

	oStruNJR:RemoveField( "NJR_TIPO"   )
	oStruNJR:RemoveField( "NJR_CLASSP" )  
	oStruNJR:RemoveField( "NJR_CLASSQ" )
	oStruNJR:RemoveField( "NJR_CLASSF" )
	
	
	oStruNJR:RemoveField( "NJR_CONDPG" )
	oStruNJR:RemoveField( "NJR_DIASPG" )
	oStruNJR:RemoveField( "NJR_DESPG" )
	oStruNJR:RemoveField( "NJR_HVIUM" )
	oStruNJR:RemoveField( "NJR_TIPUM" )
	oStruNJR:RemoveField( "NJR_HVICAL" )
	oStruNJR:RemoveField( "NJR_OUTUM" )
	oStruNJR:RemoveField( "NJR_HVIFAT" )
	oStruNJR:RemoveField( "NJR_OUTCAL" )
	oStruNJR:RemoveField( "NJR_TIPCAL" )
	oStruNJR:RemoveField( "NJR_OUTFAT" )
	oStruNJR:RemoveField( "NJR_HVITOL" )
	oStruNJR:RemoveField( "NJR_QAPADR" )
	oStruNJR:RemoveField( "NJR_TIPACE" )
	oStruNJR:RemoveField( "NJR_TISEVO" )
	oStruNJR:RemoveField( "NJR_HVIREG" )
	oStruNJR:RemoveField( "NJR_TIPFAT" )
	oStruNJR:RemoveField( "NJR_TPSEVO" )
	oStruNJR:RemoveField( "NJR_CODNGC" )
	oStruNJR:RemoveField( "NJR_VERSAO" )
	oStruNJR:RemoveField( "NJR_BOLSA" )
	oStruNJR:RemoveField( "NJR_DBOLSA" )
	oStruNJR:RemoveField( "NJR_CODEMB" )
	oStruNJR:RemoveField( "NJR_DESEMB" )
	oStruNJR:RemoveField( "NJR_UM2PRO" )
	oStruNJR:RemoveField( "NJR_QTDUM2" )
	oStruNJR:RemoveField( "NJR_DESINC" )
	oStruNJR:RemoveField( "NJR_DESVIA" )
	oStruNJR:RemoveField( "NJR_DESCPA" )
	oStruNJR:RemoveField( "NJR_DESREM" )
	
	
	oStruNJR:RemoveField( "NJR_OPETRI" )
	oStruNJR:RemoveField( "NJR_OPEFUT" )
	oStruNJR:RemoveField( "NJR_TESFIN" )
	oStruNJR:RemoveField( "NJR_TIPFIX" )
	oStruNJR:RemoveField( "NJR_RESFIX" )
	oStruNJR:RemoveField( "NJR_CHKFIX" )
	oStruNJR:RemoveField( "NJR_DATREF" )

	oStruNJR:RemoveField( "NJR_CODFIN" )
	oStruNJR:RemoveField( "NJR_DESFIN" )
	
	//Campos referente a taxa de moeda estrangeira somente ser�o exibidos no OGA290
	oStruNJR:RemoveField( "NJR_MOEDAF" )
	oStruNJR:RemoveField( "NJR_DIASF" )
	oStruNJR:RemoveField( "NJR_MOEDAR" )
	oStruNJR:RemoveField( "NJR_DIASR" )
	oStruNJR:RemoveField( "NJR_OPERAC" )
	
	oStruNNY:RemoveField( "NNY_VMESAN" )
	oStruNNY:RemoveField( "NNY_MESANO" )
	oStruNNY:RemoveField( "NNY_IDXCTF" )
	oStruNNY:RemoveField( "NNY_MEMBAR" )
	oStruNNY:RemoveField( "NNY_IDXNEG" )

	oStruNJR:RemoveField( "NJR_TIPALG" )  
	oStruNJR:RemoveField( "NJR_TKPFIS" )
	oStruNJR:RemoveField( "NJR_TIPMER" )
	oStruNJR:RemoveField( "NJR_CONDPA" ) 
	oStruNJR:RemoveField( "NJR_DESCPA" )
	oStruNJR:RemoveField( "NJR_VIA" )
	oStruNJR:RemoveField( "NJR_DESVIA" )
	oStruNJR:RemoveField( "NJR_INCOTE" )
	oStruNJR:RemoveField( "NJR_DESINC" )
	oStruNJR:RemoveField( "NJR_CODREM" )
	oStruNJR:RemoveField( "NJR_DESREM" )
	oStruNNY:RemoveField( "NNY_MESBOL" )
	oStruNNY:RemoveField( "NNY_DTLFIX" )
	oStruNNY:RemoveField( "NNY_DTLTKP" )
	oStruNNY:RemoveField( "NNY_TKPQTD" )
	
	oStruNJR:RemoveField( "NJR_CODRPC" )


    AGRXSTPROP(oStruNJR, "NJR_VLRUNI" , MVC_VIEW_CANCHANGE , .F.) // Verifica se o campo existe na estrutura antes de adicionar a view
	
	oStruNJR:RemoveField( "NJR_DESMOR" )
	oStruNJR:RemoveField( "NJR_DESMOF" )
	oStruNJR:RemoveField( "NJR_GENMOD" )
	oStruNJR:RemoveField( "NJR_BCOPRV" )
	oStruNJR:RemoveField( "NJR_AGGPRV" )
	oStruNJR:RemoveField( "NJR_CTAPRV" )
	oStruNJR:RemoveField( "NJR_PERCRD" )
	oStruNJR:RemoveField( "NJR_TOTNN7" )
	oStruNJR:RemoveField( "NJR_TOTN9G" )
	oStruNJR:RemoveField( "NJR_TOTN9K" )
	oStruNJR:RemoveField( "NJR_TOTAFT" )
	oStruNJR:RemoveField( "NJR_TOTARB" )
	oStruNJR:RemoveField( "NJR_STSMIN" )
	oStruNJR:RemoveField( "NJR_PROMIN" )
	oStruNJR:SetProperty( "NJR_QTDINI" 	, MVC_VIEW_CANCHANGE, .F.)
	oStruNNY:RemoveField( "NNY_CODCTR" )
	oStruNNY:RemoveField( "NNY_CODCTR" )
	oStruNNY:RemoveField( "NNY_FILORG" )
	oStruNNY:RemoveField( "NNY_FILDES" )
	oStruNNY:RemoveField( "NNY_QTDCTR" )

	oView:SetModel( oModel )
	oView:AddField( "VIEW_NJR", oStruNJR, "NJRUNICO" )
	oView:AddGrid( "VIEW_NNY", oStruNNY, "NNYUNICO" )
	oView:AddIncrementField( "VIEW_NNY", "NNY_ITEM" )

	oView:CreateHorizontalBox( "SUPERIOR" , 60 )
	oView:CreateHorizontalBox( "INFERIOR" , 40 )

	oView:CreateFolder( "GRADES", "INFERIOR")
	oView:AddSheet( "GRADES", "PASTA01", STR0025) //"Cad�ncia"

	oView:CreateHorizontalBox( "PASTA_NNY", 100, , , "GRADES", "PASTA01" )

	oView:SetOwnerView( "VIEW_NJR", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_NNY", "PASTA_NNY" )

	oView:EnableTitleView( "VIEW_NJR" )
	oView:EnableTitleView( "VIEW_NNY" )

	//--    Adicionando Grupos na view       --//
	oStruNJR:AddGroup( 'GRUPOA', ''	    , '', 1 )
	oStruNJR:AddGroup( 'GRUPOB', Chr(09), '', 2 )
	oStruNJR:AddGroup( 'GRUPOC', Chr(09), '', 3 )
	oStruNJR:AddGroup( 'GRUPOD', Chr(09), '', 4 )
	oStruNJR:AddGroup( 'GRUPOE', ''     , '', 5 )

	//-- Atribuindo Todos os Campos ao Grupo D (campos que fica em outras abas) --//
    AGRXSTPROP(oStruNJR, "*" , MVC_VIEW_GROUP_NUMBER , 'GRUPOE') // Verifica se o campo existe na estrutura antes de adicionar a view

	//-- Atribuindo os campos ao Grupo A--//
    
    aFields := Separa("NJR_CODCTR;NJR_ULTALT;NJR_DESCRI;NJR_DATA;NJR_CODENT;NJR_LOJENT;NJR_NOMENT;NJR_NLJENT;NJR_CODTER;NJR_LOJTER;NJR_NOMTER;NJR_NLJTER", ";")
    For nIt := 1 To Len(aFields)
        AGRXSTPROP(oStruNJR, aFields[nIt] , MVC_VIEW_GROUP_NUMBER , 'GRUPOA') // Verifica se o campo existe na estrutura antes de adicionar a view
    Next nIt

	//-- Atribuindo os campos ao Grupo B --//
    aFields := Separa("NJR_CODSAF;NJR_TALHAO;NJR_CODPRO;NJR_DESPRO;NJR_TABELA", ";")
    For nIt := 1 To Len(aFields)
        AGRXSTPROP(oStruNJR, aFields[nIt] , MVC_VIEW_GROUP_NUMBER , 'GRUPOB')
    Next nIt

	//-- Atribuindo os campos ao Grupo C --//
    aFields := Separa("NJR_OPETRI;NJR_OPEFUT;NJR_CODOPE;NJR_CODRPC;NJR_OPEFIS;NJR_TESEST;NJR_TESFIN;NJR_TESQTE;NJR_TESRSI;NJR_TIPEMB;NJR_MSGNFS;NJR_OBSADT;NJR_ITVDAP;NJR_TRANSF", ";")
    For nIt := 1 To Len(aFields)
        AGRXSTPROP(oStruNJR, aFields[nIt] , MVC_VIEW_GROUP_NUMBER , 'GRUPOC')
    Next nIt
	
	AGRXSTPROP(oStruNJR, "NJR_TIPOCL" , MVC_VIEW_GROUP_NUMBER , 'GRUPOC')
    AGRXSTPROP(oStruNJR, "NJR_CLVL" , MVC_VIEW_GROUP_NUMBER , 'GRUPOC')
	
	//-- Atribuindo os campos ao Grupo D --//
    aFields := Separa("NJR_MODELO;NJR_MODBAS;NJR_STSASS;NJR_STSFIS;NJR_STSFIN;NJR_STSEST;NJR_STATUS", ";")
    For nIt := 1 To Len(aFields)
        AGRXSTPROP(oStruNJR, aFields[nIt] , MVC_VIEW_GROUP_NUMBER , 'GRUPOD')
    Next nIt
	
	oView:AddUserButton( STR0063 , '', {|| OGC003( oView:GetModel("NJRUNICO"):GetValue("NJR_CODCTR") ) } )  //"Romaneios"

	oView:SetCloseOnOk( {||.t.} )

Return( oView )

/** {Protheus.doc} OG260VDTB
Fun��o que valida o campo da tabela de descontos utilizada no contrato
Fun��o verifica se produto algod�o AGRTPALGOD() est� no fonte AGRXFUN1.PRW

@param: 	oFields - Field da tabela NJ0
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since: 	01/01/2015
@Uso: 		OGA260 - Contratos
*/
Function OG260VDTB()
	Local aAreaAtu 		:= GetArea()
	Local lRetorno 		:= .T.
	Local oModel        	:= FWModelActive()
	Local oModelNJR		:= oModel:GetModel("NJRUNICO")
	Local cTabela 		:= oModelNJR:GetValue( "NJR_TABELA" )
	Local cCodPro 		:= oModelNJR:GetValue( "NJR_CODPRO" )
	Local cGrupo		:= ""

	dbSelectArea( "NNI" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "NNI" ) + cTabela )	.AND. .NOT. AGRTPALGOD(cCodPro)
		//para o campo de cod. do produto preenchido
		If !Empty(NNI->( NNI_CODPRO ))
			If NNI->( NNI_CODPRO ) <> cCodPro
				If !Empty(cCodPro)
					Help( , , STR0026, , STR0027, 1, 0 ) //"AJUDA"###"Tabela nao cadastrada para este produto."
					lRetorno := .f.
				ElseIf Empty(cCodPro)
					Help( , , STR0026, , STR0066, 1, 0 ) //"AJUDA"###"Informar produto compat�vel com a tabela selecionada."
					lRetorno := .f.
					Return( lRetorno )
				EndIf
			Else
				If ( NNI->( NNI_DATINI ) > dDataBase .Or. NNI->( NNI_DATFIM ) < dDataBase )
					Help( , , STR0026, , STR0028, 1, 0 ) //"AJUDA"###"Tabela fora da validade."
					lRetorno := .f.
				EndIf
			EndIf
		//Para o campo de cod. do produto vazio
		ElseIf Empty(NNI->( NNI_CODPRO ))
			//verifica na tabela de produto pelo grupo se o grupo � existente
			//se grupo n�o existir apresenta mensagem para informar o grupo
			If AGRIFDBSEEK("SB1",cCodPro,1,.F.)
				cGrupo := SB1->( B1_GRUPO )
				If NNI->( NNI_PRODGR ) <> cGrupo
					Help( , , STR0026, , STR0065, 1, 0 ) //"Produto n�o faz parte do grupo da tabela selecionada. Informar produto compat�vel com a tabela selecionada."##"AJUDA"
					lRetorno := .F.
				ElseIf ( NNI->( NNI_DATINI ) > dDataBase .Or. NNI->( NNI_DATFIM ) < dDataBase )
					Help( , , STR0026, , STR0028, 1, 0 ) //"AJUDA"###"Tabela fora da validade."
					lRetorno := .f.
				EndIf
			Else
				//se produto for vazio, n�o permitir tabela
				If Empty(cCodPro)
					Help( , , STR0026, , STR0066, 1, 0 ) //"AJUDA"###"Informar produto compat�vel com a tabela selecionada."
					lRetorno := .f.
					Return( lRetorno )
				EndIf
			EndIf
		EndIf
	ElseIf .NOT. AGRTPALGOD(cCodPro)
		Help( , , STR0026, , STR0029, 1, 0 ) //"AJUDA"###"Tabela nao cadastrada."
		lRetorno := .f.
	EndIf

	RestArea (AAreaAtu )
Return( lRetorno )

/** {Protheus.doc} IniModelo
Fun��o que valida a inicializa��o do modelo de dados

@param: 	oModel - Modelo de dados
@param: 	nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since: 	01/01/2015
@Uso: 		OGA260 - Contratos
*/
Static Function IniModelo( oModel, nOperation )
	Local lRetorno 	:= .t.
	Local nQtdPre 	:= NJR->( NJR_AUTENT ) + NJR->( NJR_AUTSAI )

	// Valida��o de assinatura do ctrato
	IF nOperation == MODEL_OPERATION_UPDATE
		If NJR->NJR_STSASS == 'F'
			Help( ,, STR0026,, STR0056, 1, 0 )  //"AJUDA"###"N�o � possivel excluir este contrato, pois ja foi confirmado ou esta em execu��o. Este contrato somente pode ser -Finalizado- ou - Encerrado-."
			lRetorno := .f.
		EndIF
	EndIF

	If nOperation == MODEL_OPERATION_DELETE
		If NJR->( NJR_STATUS ) <> "P" .Or. nQtdPre > 0
			Help( ,, STR0026,, STR0031, 1, 0 ) //"AJUDA"###"N�o � possivel excluir este contrato, pois ja foi confirmado ou esta em execu��o. Este contrato somente pode ser -Finalizado- ou - Encerrado-."
			lRetorno := .f.
		EndIf
	EndIf

Return( lRetorno )


/** {Protheus.doc} PreModelo
Fun��o que valida o modelo de dados antes da confirma��o

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since: 	01/01/2015
@Uso: 		OGA260
*/
Static Function PreModelo( oModel )
	Local lRetorno		:= .t.
	Local nOperation	:= oModel:GetOperation()
	Local cStatus		:= oModel:GetValue( "NJRUNICO", "NJR_STATUS" )

	If nOperation == MODEL_OPERATION_UPDATE

		If cStatus $ "F|E"
			Help( , , STR0026, , STR0032, 1, 0 ) //"AJUDA"###"Contrato ja foi Finalizado ou Encerrado! n�o pode ser alterado."
			lRetorno := .f.
		EndIf

	EndIf

Return( lRetorno )


/** {Protheus.doc} PosModelo
Fun��o que valida o modelo de dados ap�s a confirma��o

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since: 	01/01/2015
@Uso: 		OGA260
*/
Static Function PosModelo( oModel )
	Local nOperation	:= oModel:GetOperation()
	Local cCodEnt		:= oModel:GetValue( "NJRUNICO", "NJR_CODENT" )
	Local cLojEnt		:= oModel:GetValue( "NJRUNICO", "NJR_LOJENT" )
	Local cTipo			:= oModel:GetValue( "NJRUNICO", "NJR_TIPO" )
	Local cSafra		:= oModel:GetValue( "NJRUNICO", "NJR_CODSAF" )
	Local cProd			:= oModel:GetValue( "NJRUNICO", "NJR_CODPRO" )
	Local oModelNNY 	:= oModel:GetModel('NNYUNICO')
	Local lContinua := .t.

    If nOperation == MODEL_OPERATION_INSERT
		//Fun��o para n�o permitir dois contratos com a mesma entidade e safra [OGA390]
		lContinua := OGA390B(xFilial("NJR"), cCodEnt, cLojEnt, cSafra, cProd, cTipo)
    EndIf

	If lContinua .AND. nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		//Fun��o para validar entidade
    	lContinua := AGRXVALENT("F", cCodEnt, cLojEnt)

   	If lContinua .And. !AGRXPOSNNY(oModelNNY)
			Return .F.
		EndIf
	EndIf
Return( lContinua )


/** {Protheus.doc} GrvModelo
Fun��o que grava o modelo de dados ap�s a confirma��o

@param: 	oModel - Modelo de dados
@return:	.t. - sempre verdadeiro
@author: 	Equipe Agroindustria
@since: 	01/01/2015
@Uso: 		OGA260 - Contratos
*/
Static Function GrvModelo( oModel )
	Local nOperation 	:= oModel:GetOperation()
	Local cModelo		:= oModel:GetValue( "NJRUNICO", "NJR_MODELO" )
	Local oModelNJR   :=oModel:GetModel( "NJRUNICO" )

	// Gravar Hist�rico Automaticamente
	If nOperation == MODEL_OPERATION_INSERT
		AGRGRAVAHIS(,,,,{"NJR",xFilial("NJR")+oModelNJR:Getvalue('NJR_CODCTR'),"3",STR0010}) //Incluir
	elseIf nOperation == MODEL_OPERATION_UPDATE
		AGRGRAVAHIS(,,,,{"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"4",STR0011}) //Alterar
	elseIf nOperation == MODEL_OPERATION_DELETE
		AGRGRAVAHIS(,,,,{"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"5",STR0016}) //Excluir
	Endif

	IF nOperation == MODEL_OPERATION_INSERT .Or. ( nOperation == MODEL_OPERATION_UPDATE .And. oModelNJR:Getvalue('NJR_STATUS')=='P' )

		oModelNJR:LOADVALUE('NJR_QSLFCO', (oModelNJR:Getvalue('NJR_QTEFCO') - oModelNJR:Getvalue('NJR_QTSFCO') ))
		oModelNJR:LOADVALUE('NJR_SLDFIS', (oModelNJR:Getvalue('NJR_QTEFIS') - oModelNJR:Getvalue('NJR_QTSFIS') ))

	EndIF

	If nOperation == MODEL_OPERATION_UPDATE
		If cModelo == "1"
			oModel:SetValue( "NJRUNICO", "NJR_MODELO", "2" )
		EndIf
		If cModelo == "2"
			oModel:SetValue( "NJRUNICO", "NJR_STATUS", "P" )
		EndIf
	EndIf

	FWFormCommit( oModel )

Return( .t. )

/** {Protheus.doc} ValNNYDATINI
Valida o campo NNY_DATINI e automaticamente preenche NNY_DATFIM

@param: 	oField
@return:	lRetorno - verdadeiro ou falso
@author: 	Marlon Richard Trettin
@since: 	18/11/2014
@Uso: 		OGA260
*/
Static Function ValNNYDATINI( oFldNNY )
	Local lRetorno 	:= .T.

	If Empty(oFldNNY:GetValue( "NNY_DATFIM" ))
		oFldNNY:SetValue( "NNY_DATFIM", oFldNNY:GetValue( "NNY_DATINI" ) )
	EndIf

Return( lRetorno )

/** {Protheus.doc} OGA260C
Rotina para que confirma��o do contrato para que o mesmo possa ser utilizado

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	01/01/2015
@Uso: 		SIGAAGR - Origina��o de Gr�os
*/
Function OGA260C( cAlias, nReg, nAcao )
	Local aAreaAtu		:= GetArea()
	Local lRetorno    := .T.

	If NJR->( NJR_MODELO ) = "1"
		Help( ,,STR0026,, STR0033, 1, 0 ) //"AJUDA"###"Pre-Contratos nao podem ser confirmados, altere para Contrato para depois confirmar."
	ElseIf .Not. AgrEntidOk( NJR->( NJR_CODENT ) , NJR->( NJR_LOJENT ) ) //Verifica se a Entidade Esta ok, Tipo For/cli n. Bloqueados
		lRetorno:= .f.
	Else

		If NJR->( NJR_MODELO ) $ "2|3" .And. NJR->( NJR_STATUS ) = "P"

			// N�o permite confirmar se houver outro contrato Confirmado ou Iniciado com a mesma Entidade e Safra e produto
			lRetorno := OGA390B(xFilial("NJR"), NJR->( NJR_CODENT ) , NJR->( NJR_LOJENT ) , NJR->( NJR_CODSAF ), NJR->( NJR_CODPRO ) , NJR->( NJR_TIPO ) )
			if lRetorno = .F.
				Return .F.
			endif

			BEGIN TRANSACTION
				//"Deseja realmente confirmar o contrato?"
				If AGRGRAVAHIS(STR0034,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"N") = 1
					// Atualiza as quantidades autorizadas do contrato
					OGX010QAut("A")
				Else
					lRetorno = .F.
				EndIf

			END TRANSACTION
			
			If lRetorno
				MsgInfo( STR0036, STR0037 ) //"Contrato Confirmado com Sucesso!!!"###"Confirma��o do Contrato"
			EndIf

		Else

			Help( ,,STR0026,, STR0038, 1, 0 ) //"AJUDA"###"Este contrato ja foi confirmado..."

		EndIf

	EndIf

	RestArea( aAreaAtu )
Return( Nil )

/** {Protheus.doc} OGA260E
Rotina para utilizada para encerrar o contrato para que o mesmo nao seja mais movimentado

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	01/01/2015
@Uso: 		SIGAAGR - Origina��o de Gr�os
*/
Function OGA260E( cAlias, nReg, nAcao )
	Local aAreaAtu	:= GetArea()

	//Se NJR_STATUS for A=aberto , I=iniciado ou P=previsto
	If NJR->( NJR_STATUS ) $ "A|I|P"
		If NJR->( NJR_STATUS) == "P"
			Help( ,,STR0026,, STR0071, 1, 0 ) //"Ajuda"###"Contrato com status 'Previsto' n�o pode ser cancelado. Somente � permitido a opera��o de 'Excluir'.
			Return ( Nil )
		EndIf
		If NJR->( NJR_QTEFIS ) = 0 .AND.  NJR->( NJR_QTSFIS )= 0

			//"Deseja realmente encerrar este contrato?"
			If AGRGRAVAHIS(STR0039,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"C") = 1

				If RecLock( "NJR", .f. )
					NJR->( NJR_QTDCTR ) := NJR->( NJR_QTEFCO )
					NJR->( NJR_AUTENT ) := NJR->( NJR_QTEFCO )
					NJR->( NJR_AUTSAI ) := NJR->( NJR_QTSFCO )
					NJR->( NJR_STATUS ) := "E"
					msUnLock()
				EndIf

				MsgInfo( STR0040, STR0041 ) //"Contrato Encerrado com Sucesso!!!"###"Encerramento do Contrato"
			EndIf

		Else
			Help( ,,STR0026,,"Contrato nao pode ser encerrado. Existe saldo de quantidades.", 1, 0 ) //"Ajuda"#### "Contrato nao pode ser encerrado. Existe saldo de quantidades."
			Return( Nil )

		EndIf

	Else

		Help( ,,STR0026,, STR0042, 1, 0 ) //"Ajuda"###"Este contrato n�o pode ser -Encerrado-, pois ja foi -Finalizado-..."
		Return( Nil )

	EndIf

	RestArea( aAreaAtu )
Return( Nil )


/** {Protheus.doc} OGA260F
Rotina para utilizada para finalizar o contrato para que o mesmo nao seja mais movimentado

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	01/01/2015
@Uso: 		SIGAAGR - Origina��o de Gr�os
*/
Function OGA260F( cAlias, nReg, nAcao )
	Local aAreaAtu	:= GetArea()
	Local aTpContrato := SuperGetMV("MV_AGRO001",.F., "") //tipo do contrato //1COMPRA 2 VENDA 3 ARM DE TERC 4 ARMA EM TERC
	Local nIt		  := 0
	Local lRet        := .T.

	If !Empty(aTpContrato) // Verifica o parametro de tipo do contrato
		aTpContrato := Separa(aTpContrato, ";")
		For nIt := 1 To Len(aTpContrato)
			If NJR->( NJR_TIPO )== AllTrim(aTpContrato[nIt]) // se o tipo n�o fizer parte do parametro valida normalmente
				lRet := .F.
				//"Deseja realmente finalizar este contrato?"
				If NJR->( NJR_STATUS ) $ "I" 
					If AGRGRAVAHIS(STR0054,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"F") = 1
						If RecLock( "NJR", .f. )
							NJR->( NJR_STATUS ) := "F"
							msUnLock()
						EndIf
						MsgInfo( STR0043, STR0044 ) //"Contrato Finalizado com Sucesso!!!"###"Finaliza��o do Contrato"
					EndIf
				Else
					Help( ,,STR0026,, STR0045, 1, 0 ) //"Ajuda"###"Este contrato n�o pode ser -Finalizado-, pois ainda n�o foi -Iniciado- ."
					Return( Nil )
				EndIf
			EndIf
		Next nIt
		If lRet
			If NJR->( NJR_STSEST ) = "F" .And. NJR->( NJR_STSFIS ) = "F" .And. NJR->( NJR_STATUS ) $ "I"
				//"Deseja realmente finalizar este contrato?"
				If AGRGRAVAHIS(STR0054,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"F") = 1
					If RecLock( "NJR", .f. )
						NJR->( NJR_STATUS ) := "F"
						msUnLock()
					EndIf
					MsgInfo( STR0043, STR0044 ) //"Contrato Finalizado com Sucesso!!!"###"Finaliza��o do Contrato"
				EndIf
			Else
				Help( ,,STR0026,, STR0072, 1, 0 ) //"Este contrato n�o pode ser -Finalizado-, verifique o status interno do contrato ."                                                                                                                                                                                                                                                                                                                                                                                                                                 
				Return( Nil )
			EndIf 

		EndIf
	Else
		If NJR->( NJR_STSEST ) = "F" .And. NJR->( NJR_STSFIS ) = "F" .And. NJR->( NJR_STATUS ) $ "I"
			//"Deseja realmente finalizar este contrato?"
			If AGRGRAVAHIS(STR0054,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"F") = 1
				If RecLock( "NJR", .f. )
					NJR->( NJR_STATUS ) := "F"
					msUnLock()
				EndIf
				MsgInfo( STR0043, STR0044 ) //"Contrato Finalizado com Sucesso!!!"###"Finaliza��o do Contrato"
			EndIf
		Else
			Help( ,,STR0026,, STR0072, 1, 0 ) //"Este contrato n�o pode ser -Finalizado-, verifique o status interno do contrato ."                                                                                         
			Return( Nil )
		EndIf
	EndIf
	RestArea( aAreaAtu )
Return( Nil )


/** {Protheus.doc} OGA260R
Rotina para utilizada para reabrir o contrato para que o mesmo seja movimentado

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	01/01/2015
@Uso: 		SIGAAGR - Origina��o de Gr�os
*/
Function OGA260R( cAlias, nReg, nAcao )
	Local aAreaAtu	:= GetArea()
	Local lRetorno    := .T.

	If NJR->( NJR_STATUS ) $ "F|E"

		// N�o permite reabrir se houver outro contrato Confirmado ou Iniciado com a mesma Entidade e Safra
		lRetorno := OGA390B(xFilial("NJR"), NJR->( NJR_CODENT ) , NJR->( NJR_LOJENT ) , NJR->( NJR_CODSAF ), NJR->( NJR_CODPRO ) , NJR->( NJR_TIPO ) )
		if lRetorno = .F.
			Return .F.
		endif

		BEGIN TRANSACTION

			//"Deseja realmente reabrir este contrato?"
			If AGRGRAVAHIS(STR0046,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"B") = 1

				//////////////////////////
				// Atualiza quantidades do contrato de acordo com as adita��es / supress�es
				//////////////////////////
				OGA335AtuQtd()

				//////////////////////////
				// Atualiza qtdes do contrato e saldos
				//////////////////////////
				OGX010QTDS()

				//////////////////////////
				// Atualiza autoriza��es
				//////////////////////////
				OGX010QAut("P")

				MsgInfo( STR0047, STR0048 ) //"Contrato Reaberto com Sucesso!!!"###"Reabertura do Contrato"

			EndIf

		END TRANSACTION

	Else

		Help( ,,STR0026,, STR0049, 1, 0 ) //"Ajuda"###"Este contrato n�o pode ser -Reaberto-, pois n�o esta -Fechado- ou -Encerrado-..."
		Return( Nil )

	EndIf

	RestArea( aAreaAtu )
Return( Nil )



/** {Protheus.doc} OGA260nCopy
Fun��o Que pega todos os campos do modelo e retorna-os em array unidimensional

@param: 	oModel		Objeto de Model do MVC
@return:	aFldNoCopy		:= {,} // Array Com os Campos do modelo de dados passado
@author: 	Emerson Coelho
@since: 	14/11/2014
@Uso: 		OGA260 - Contrato de compra
*/
Function OGA260nCopy( oModel )
	Local nX	:= 1
	Local aFieldsAux		:= oModel:GetStruct():aFields
	aFldNoCopy			:= {}
	for nX:=1 to len( aFieldsAux ) Step 1
		aAdd(aFldNoCopy , aFieldsAux [nX , 3] )
	nExt
Return aFldNoCopy

	
/** {Protheus.doc} OGA260CpGr
Fun��o para eliminar linhas do Grid na fun��o c�pia
@param:     oObj      - Grid do modelo de dados
            lCopia    - Informa se � fun��o C�pia 
@return:    aLoadGrid - Array com os valores do objeto
@author:    Niara Caetano
@since:     06/10/2018
@Uso: 		SIGAAGR - Origina��o de Gr�os
*/
Static Function OGA260CpGr(oObj,lCopia) 
	Local aLoadGrid := {}
	Local nLgTam	:= 0
   	Local nX 		:= 0
	
	If lCopia 
		aLoadGrid := FormLoadGrid(oObj, .T.) // faz a carga de dados 
		nLgTam := Len(aLoadGrid)  
		
		For nX := 1 To Len(aLoadGrid)
			If nX > 1               	     //se houver mais de uma linha na grid, elimina essas linhas				
				aDel(aLoadGrid, nLgTam) 	 //remove linha da grid
				aSize(aLoadGrid, --nLgTam)
			EndIf
		Next
	Else
		aLoadGrid := FormLoadGrid(oObj, .F.)
	EndIf
	
Return aLoadGrid

/** {Protheus.doc} OGA260HIS
Descri��o: Mostra em tela de Historico do contrato

@param: 	Nil
@author: 	Gilson Venturi
@since: 	26/03/2015
@Uso: 		OGA260
*/
Function OGA260HIS()
	Local cChaveI := "NJR->("+Alltrim(AGRSEEKDIC("SIX","NJR1",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))

	AGRHISTTABE("NJR",cChaveA)
Return

/*
+=================================================================================================+
| Fun��o    : OGA260CADEN                                                                         |
| Descri��o : Valida��o da cad�ncia do contrato em rele��o ao tipo e quantidades informadas       |
| Autor     : In�cio Luiz Kolling                                                                 |
| Data      : 05/07/2016                                                                          |
+=================================================================================================+                                                                           |
| Par�metros: oModel - Objeto do model                                                 Obrigat�rio|
+=================================================================================================+
|Refer�ncias: Pr�prio e OGA270,OGA280,OGA290                                                      |
+=================================================================================================+
*/
Function OGA260CADEN(oModel)
	Local nQtdTot := oModel:GetValue("NJRUNICO","NJR_QTDCTR")
	Local oGrdNNY := oModel:GetModel("NNYUNICO")
	Local nGrdNNY := AGRSOMACOLSM(oGrdNNY,{"NNY_QTDINT"})

	If oModel:GetValue("NJRUNICO","NJR_MODELO") <> "3" .And. Empty(nGrdNNY)
		Help( ,,"EMPTYFORM",,STR0073,1,0) //"O Formul�rio de Dados do Intervalo de Cad�ncia  (NNYUNICO) n�o foi preenchido."
		Return .F.
	ElseIf oModel:GetValue("NJRUNICO","NJR_MODELO") = "3" .And. !Empty(nGrdNNY) .And. nQtdTot <> nGrdNNY
		Help(,,STR0026,,STR0030,1,0) //"AJUDA"###"A soma da quantidade nos itens de Cad�ncia do Contrato esta divergente do Contrato!"
		Return .f.
	EndIf
Return .t.

