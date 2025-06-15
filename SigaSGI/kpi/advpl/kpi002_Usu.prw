#INCLUDE "kpi002_Usu.ch"
#INCLUDE "BIDefs.ch"
#INCLUDE "KPIDefs.ch"

#define TAG_ENTITY	"USUARIO"
#define TAG_GROUP	"USUARIOS"
#define TEXT_ENTITY STR0001/*//"Usuário"*/ //"Usuario"
#define TEXT_GROUP  STR0002/*//"Usuários"*/ //"Usuarios"
#define P_VISUAL 	"VISUALIZACAO"
#define P_MANUTE 	"MANUTENCAO"     
#define P_INCLUI 	"INCLUSAO"   
#define P_ALTERACAO	"ALTERACAO"
#define P_EXCLUI 	"EXCLUSAO"
#define COL_ANALISE	6

// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI002_Usu.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// 22.08.05 | 1776 Alexandre Alves da Silva - Importado para uso no KPI
// --------------------------------------------------------------------------------------


/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->TKPI002
@entity Usuario
Usuarios do sistema KPI.
--------------------------------------------------------------------------------------*/
Function TKPI002()

Return

class TKPI002 from TBITable

	data faRegra

	method New() constructor
	method NewKPI002() 
	method oArvore()
	method oToXMLList()
	method oToXMLRecList()
	method oToXMLNode()
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(cID)	
	method nSqlCount()
	method nExecute(nID, cExecCMD)	
	method oGetSco(cID,lAdmin) 	
	method oGetChildSco(cUserID)
	method oRecursiveGetChild(cUserID,cEnabled,cSelected) 
	method oSimpleGetChild(cUserID)
	method getFaRegra()
	method oAllUsers()
	
endclass
	
method New() class TKPI002
	::NewKPI002()
return

method NewKPI002() class TKPI002
	// Table
	::NewTable("SGI002")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID", 		"C",	10))
	::addField(TBIField():New("NOME", 		"C", 	25))
	::addField(TBIField():New("SENHA", 		"C", 	40))
	::addField(TBIField():New("COMPNOME",	"C",	60))
	::addField(TBIField():New("CARGO",		"C",	40))
	::addField(TBIField():New("FONE",		"C",	20))
	::addField(TBIField():New("RAMAL",		"C",	10))
	::addField(TBIField():New("EMAIL",		"C",	80))
	::addField(TBIField():New("ADMIN",		"C",	01))
	::addField(TBIField():New("AUTENTIC",	"N"))
	::addField(TBIField():New("USERPROT",	"C",	01))
	::addField(TBIField():New("USERKPI"	,	"C",	01))//Indica se o usuario pode acessar ao sistema.

	// Indexes
	::addIndex(TBIIndex():New("SGI002I01",	{"ID"},	.t.))
	::addIndex(TBIIndex():New("SGI002I02",	{"NOME"}, .t.))
	::addIndex(TBIIndex():New("SGI002I03",	{"COMPNOME"}, .f.))

	//Item Principal, Regra, ID da Seguranca, texto para exibicao,valor da permissao
	// Array com Regras de Segurança
	::faRegra := {}
	aAdd(::faRegra,{"SCORECARDS"		,STR0036	 	,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 },{P_VISUAL, KPI_SEC_VISUALIZACAO, STR0005	}}	,"SCORECARD"	,"0",	ANALISE_PDCA})	//Scorecards
	aAdd(::faRegra,{"UNIDADES"			,STR0025		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 },{P_VISUAL, KPI_SEC_VISUALIZACAO, STR0005 	}}	,"UNIDADE"		,"0",	""})	//Un. Medida								  				
	aAdd(::faRegra,{"ORGANIZACOES"		,STR0037		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 },{P_VISUAL, KPI_SEC_VISUALIZACAO, STR0005 	}}	,"ORGANIZACAO"	,"0",	ANALISE_BSC})	//Organização
	aAdd(::faRegra,{"ESTRATEGIAS"		,STR0038		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 },{P_VISUAL, KPI_SEC_VISUALIZACAO, STR0005 	}}	,"ESTRATEGIA"	,"0",	ANALISE_BSC})	//Estrategia
	aAdd(::faRegra,{"PERSPECTIVAS"		,STR0039		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 },{P_VISUAL, KPI_SEC_VISUALIZACAO, STR0005 	}}	,"PERSPECTIVA"	,"0",	ANALISE_BSC})	//Perspectiva
	aAdd(::faRegra,{"OBJETIVOS"			,STR0040		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 },{P_VISUAL, KPI_SEC_VISUALIZACAO, STR0005 	}}	,"OBJETIVO"		,"0",	ANALISE_BSC})	//Objetivo
	aAdd(::faRegra,{"GRUPO_INDS"		,STR0012		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 },{P_VISUAL, KPI_SEC_VISUALIZACAO, STR0005 	}}	,"GRUPO_IND"	,"0",	""})	//"Grupo de Ind."
	aAdd(::faRegra,{"INDICADORES"		,STR0006		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 },{P_VISUAL, KPI_SEC_VISUALIZACAO, STR0005 	}}	,"INDICADOR"	,"0",	""})	//"Indicadores"
	aAdd(::faRegra,{"METAFORMULAS"		,STR0010		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 },{P_VISUAL, KPI_SEC_VISUALIZACAO, STR0005 	}}	,"METAFORMULA"	,"0",	""})	//"Meta Formula"
	aAdd(::faRegra,{"PLANILHAS"			,STR0007		,{{P_VISUAL, KPI_SEC_VISUALIZACAO	, STR0005 },{P_INCLUI, KPI_SEC_INCLUSAO	   , STR0044 	},{P_ALTERACAO, KPI_SEC_ALTERACAO  , STR0045	},{P_EXCLUI, KPI_SEC_EXCLUSAO, STR0046}}	,"PLANILHA"		,"0",	""})	//"Planilhas"
	aAdd(::faRegra,{"IND_FORMULA"		,STR0033		,{{P_VISUAL, KPI_SEC_VISUALIZACAO	, STR0005 }},"IND_FORMULA"	,"1",	""})													//"Insp. de Formula"
	aAdd(::faRegra,{"GRUPO_ACAO"		,STR0030		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 },{P_VISUAL, KPI_SEC_VISUALIZACAO, STR0005 	}}	,"GRUPO_ACAO"	,"0",	""})	//"Plano de Acao"
	aAdd(::faRegra,{"PLANOSACAO"		,STR0008		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 },{P_VISUAL, KPI_SEC_VISUALIZACAO, STR0005 	}}	,"PLANOACAO"	,"1",	""})	//"Acao"	 		
	aAdd(::faRegra,{"PROJETOS"			,STR0009		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 },{P_VISUAL, KPI_SEC_VISUALIZACAO, STR0005 	}}	,"PROJETO"		,"1",	""})	//"Projetos"		
	aAdd(::faRegra,{"PACOTES"			,STR0034		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 },{P_VISUAL, KPI_SEC_VISUALIZACAO, STR0005 	}}	,"PACOTE"		,"0",	""})	//"Pacotes"						  				
	aAdd(::faRegra,{"ESP_PEIXE"			,STR0032		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 },{P_VISUAL, KPI_SEC_VISUALIZACAO, STR0005 	}}	,"ESP_PEIXE"	,"0",	""})	//"Espinha de peixe"  
	aAdd(::faRegra,{"SCORECARDING"		,STR0011		,{{P_VISUAL, KPI_SEC_VISUALIZACAO	, STR0005 }},"SCORECARDING"	,"1",	""})													//"Scorecarding"	
	aAdd(::faRegra,{"PAINEIS"			,STR0017		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 }},"PAINEL"		,"0",	""})													//"Painesis		
	aAdd(::faRegra,{"PAINEISCOMP"		,STR0031		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 }},"PAINELCOMP"	,"0",	""})													//"Paineis Comp."	
	aAdd(::faRegra,{"RELAPRS"			,STR0028		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 },{P_VISUAL, KPI_SEC_VISUALIZACAO	, STR0005 	}}	,"RELAPR"		,"0",	""})	//"Apresentações"	  
	aAdd(::faRegra,{"RELATORIOS"		,STR0013		,{{P_VISUAL, KPI_SEC_VISUALIZACAO	, STR0005 }},"RELATORIO"	,"1",	""})													//"Relatorios"		
	aAdd(::faRegra,{"USU_CONFIGS"		,STR0016		,{{P_VISUAL, KPI_SEC_VISUALIZACAO	, STR0005 }},"USU_CONFIG"	,"0",	""}) 
	aAdd(::faRegra,{"MAPAESTRATEGICO"	,STR0041		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 },{P_VISUAL, KPI_SEC_VISUALIZACAO, STR0005 	}}, "MAPAESTRATEGICO"	,"0", ANALISE_BSC})
	aAdd(::faRegra,{"TEMAESTRATEGICO"	,STR0042		,{{P_MANUTE, KPI_SEC_MANUTENCAO		, STR0004 },{P_VISUAL, KPI_SEC_VISUALIZACAO, STR0005 	}}, "TEMAESTRATEGICO"	,"0", ANALISE_BSC})

return .T.
            
// Arvore
method oArvore() class TKPI002
	local oNode, oAttrib

	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", "1")
	oAttrib:lSet("TIPO", "USUARIOS")
	oAttrib:lSet("NOME", STR0015) //"Usuários"
	oNode := TBIXMLNode():New("USUARIOS","",oAttrib)

	//Verifica quem esta solicitando a arvore.
	if(::oOWner():foSecurity:lHasAccess("USUARIO", "", "CARREGAR"))
		::SetOrder(3) // Alfabetica por nomes (COMPNOME)
		::_First()
		while(!::lEof())
			if(!(alltrim(::cValue("ID"))=="0"))
				oAttrib := TBIXMLAttrib():New()
				oAttrib:lSet("ID", ::cValue("ID"))
				oAttrib:lSet("NOME", alltrim(::cValue("COMPNOME")))
				oNode:oAddChild(TBIXMLNode():New("USUARIO", "", oAttrib))
			endif	
			::_Next()
		end
	else
		if(!(alltrim(::cValue("ID"))=="0"))
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", ::cValue("ID"))
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
			oNode:oAddChild(TBIXMLNode():New("USUARIO", "", oAttrib))
		endif	
	endif		
	
return oNode
    
// Arvore para responsavel do indicador
method oAllUsers(cFixo) class TKPI002
	Local oNode    	:= Nil 
	Local oAttrib  	:= Nil 
	Local nOrdem 	:= 1
	                      
	Default cFixo := ""                      
                      
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", "0")
	oAttrib:lSet("TIPO", TAG_GROUP)
	oAttrib:lSet("NOME", STR0015) //"Usuários"  
	oAttrib:lSet("IMAGE", KPI_IMG_DIRUSUARIO)
	oNode := TBIXMLNode():New(TAG_GROUP,"",oAttrib)
    
	//---------------------------------------------------
	// Alfabetica por nomes (COMPNOME).
	//---------------------------------------------------
	::SetOrder(3)
	::_First()
	
	While(!::lEof()) 
		If( ! ( Alltrim( ::cValue("ID") ) == "0" ) )
			oAttrib := TBIXMLAttrib():New()
			
			oAttrib:lSet("ID", cFixo+::cValue("ID"))
			oAttrib:lSet("NOME", alltrim(::cValue("COMPNOME")))
			oAttrib:lSet("TIPO", TAG_ENTITY)      
			oAttrib:lSet("IMAGE", KPI_IMG_USUARIO) 
			
			//---------------------------------------------------
			// A estrutura da árvore é montada em ordem alfabética para corrigir problema no parser.
			//---------------------------------------------------
			oNode:oAddChild(TBIXMLNode():New(TAG_ENTITY + "." + StrZero( nOrdem ++ , 4) + "." +::cValue("ID"), "", oAttrib))
		Endif	
		
		::_Next()
	End
return oNode

method oToXMLRecList( cCMDSQL, cTipo ) class TKPI002
	local oXMLNodeLista	 := TBIXMLNode():New("LISTA")
	oXMLNodeLista:oAddChild(::oToXMLList())
	
return oXMLNodeLista

// Lista XML para anexar ao pai
method oToXMLList(lUserFilter) class TKPI002
	local oNode, oAttrib, oXMLNode, nInd
	local oUser	:= ::oOwner():foSecurity:oLoggedUser()
	Default lUserFilter := .f. //Falso: lista todos os usuários - Verdedeiro: Lista somente o usuário corrente
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", KPI_STRING)

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
    
	if(lUserFilter .and. !oUser:lValue("ADMIN"))
		::cSQLFilter("ID='"+oUser:cValue("ID")+"'")
		::lFiltered(.t.)
		::_First()
	endif

	// Gera recheio
	::SetOrder(3) // Alfabetica por nomes (COMPNOME)
	::_First()
	while(!::lEof())
		if ! (alltrim(::cValue("ID"))== "0")
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"CONTEXTID","DESCRICAO","SENHA","FONE","RAMAL","EMAIL","AUTENTIC", "NOME", "ADMIN", "CARGO", "USERKPI", "USERPROT" })
			for nInd := 1 to len(aFields)
				if (aFields[nInd][1] == "COMPNOME")
					oNode:oAddChild(TBIXMLNode():New("NOME", aFields[nInd][2]))
				else
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
				endif
			next
		endif	
		::_Next()
	end
	::cSQLFilter("")
return oXMLNode

// Carregar
method oToXMLNode() class TKPI002
	local cID, aFields, nInd//, oNode  
	local lAdmin		:= .f.
	local oXMLNode 		:= TBIXMLNode():New(TAG_ENTITY)
	local oTabRegra 	:= ::oOWner():oGetTable("REGRA")
	local oUserConfig	:= ::oOWner():oGetTable("USU_CONFIG")

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		endif	
		
		if(aFields[nInd][1] == "ADMIN")
			lAdmin := iif(aFields[nInd][2]=="T",.t.,.f.)
		endif	
	next

	//No com a arvore.
	oXMLNode:oAddChild(oTabRegra:oArvoreSeg())
	//Regra do usuario.
	oXMLNode:oAddChild(oTabRegra:RegraNode(::cValue("ID"),"U"))
	//Indica se o usuario logado e administrador.
	oXMLNode:oAddChild(TBIXMLNode():New("USUA_ISADMIN", ::oOwner():foSecurity:oLoggedUser():lValue("ADMIN")))
    //Preferêncas
	oUserConfig:lPutUserConfig(cID,@oXMLNode)
	//Scorecads
	oXMLNode:oAddChild(::oGetSco(cID,lAdmin))
	
return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TKPI002
	Local aFields
	Local nInd
	Local cNome
	Local nParentID
	Local nStatus 		:= KPI_ST_OK
	Local cID			:= "" 

	Private oXMLInput 	:= oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	For nInd := 1 to len(aFields) 
	
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		
		if(aFields[nInd][1] == "SENHA")
			aFields[nInd][2] := cBIStr2Hex(pswencript(aFields[nInd][2]))
		endif
		
			
	next

	cID	:= ::cMakeID()
	aAdd( aFields, {"ID",cID } )                 
	

	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	else
		nStatus := ::oOWner():oGetTable("REGRA"):nUpdFromXML(oXML, cPath + ":_REGRAS", ::cValue("ID"), "U", 0)//0 - insercao / 1 - update
	endif	
	
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPI002
	local nInd			:= 0   
	local nQtdReg		:= 0 
	local nStatus 		:= KPI_ST_OK, cID                    
	local cPerm			:= ""   
	local aParms		:= {}   
	local aUsuario 		:= {}
	local aRegNode		:= nil
	local oUserConfig	:= ::oOWner():oGetTable("USU_CONFIG")
	local oUserSco		:= ::oOWner():oGetTable("SCOR_X_USER") 
	
	private oXMLInput 	:= oXML
   
		aFields := ::xRecord(RF_ARRAY)

	for nInd := 1 to len(aFields)  
	
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))  
		
		if(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]   
			
		elseif(aFields[nInd][1] == "SENHA")
			if(!empty(aFields[nInd][2]))
				aFields[nInd][2] := cBIStr2Hex(pswencript(aFields[nInd][2]))
			else
				aFields[nInd] := NIL
			endif
		endif	
	next

	aFields := aBIPackArray(aFields)

	// Verifica condições de gravação (append ou update)
	if(!::lSeek(1, {cID}))
		nStatus := KPI_ST_BADID
	else
		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		else                                                                                                 
			nStatus := ::oOWner():oGetTable("REGRA"):nUpdFromXML(oXML, cPath + ":_REGRAS", cID, "U", 1)//0 - insercao / 1 - update
		endif
	endif    
   

	//Atualização das personalização dos usuarios.
	if(nStatus == KPI_ST_OK)
		nStatus := oUserConfig:nUpdFromXML(oXML,cPath,cID)
	endif		
	
	
	//Gravando a permissão de acesso aos departamentos 
	if !(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_SCOS"), "_SCO"))=="U")
		aRegNode := &("oXMLInput:"+cPath+":_SCOS")  
				
		//Atualização de mais de um objeto
		if(valtype(aRegNode:_SCO)=="A")
			for nQtdReg := 1 to len(aRegNode:_SCO)
				if alltrim(aRegNode:_SCO[nQtdReg]:_SELECTED:TEXT) == "T"
					aadd(aUsuario,aRegNode:_SCO[nQtdReg]:_ID:TEXT)
				endif
			next nQtdReg 
		
		//Apenas um objeto sendo atualizado
		elseif(valtype(aRegNode:_SCO)=="O")       
			if alltrim(aRegNode:_SCO:_SELECTED:TEXT) == "T"
				aadd(aUsuario,aRegNode:_SCO:_ID:TEXT)
			endif		
		endif
	endif   
	
	nStatus := oUserSco:nDelFromXML(cID) 
	
	if(len(aUsuario) > 0 .and. nStatus == KPI_ST_OK)
		oUserSco:nInsFromXML(cID,aUsuario)
	endif	
		
return nStatus

// Exclui entidade
method nDelFromXML(cID) class TKPI002
	local nStatus		:= KPI_ST_OK
	local oScorecard	:= nil
	local oProjeto		:= nil
	local oIndicador	:= nil
	local oPlano 		:= nil
	local oGrpAcao		:= nil
	local oKpiCore		:= ::oOwner()
	local oUserConfig	:= oKpiCore:oGetTable("USU_CONFIG")	
	local oGraph		:= oKpiCore:oGetTable("GRAPH_IND")	   
	local oJustific		:= oKpiCore:oGetTable("ALTERACAOMETA")
	Local cTextScor	:= alltrim( getJobProfString("ScoreCardName", "ScoreCard") )	
	
	::oOwner():oOltpController():lBeginTransaction()
	
	if !(alltrim(cID)=="1")
		// Deleta o elemento
		nStatus := oUserConfig:nDelFromXML(cID)
		if(nStatus == KPI_ST_OK .and. ::lSeek(1, {cID}))
			
			//Verificar se o registro possui relacionamento com outras tabelas
			//KPI010: Scorecard
			oScorecard := oKpiCore:oGetTable("SCORECARD")
			if(oScorecard:lSeek(3,{cID}))
				::fcMsg	:= STR0018 + STR0048 + cTextScor + " " + "'" + alltrim(oScorecard:cValue("NOME")) + "'!" //"Não é possível deletar este registro, pois este usuário é "###"responsável pelo " 
				::oOwner():oOltpController():lRollback()
				return KPI_ST_VALIDATION
			else
				::fcMsg := ""
			endif
			
			//KPI014: Projeto - OWNER
			oProjeto := oKpiCore:oGetTable("PROJETO")
			if(oProjeto:lSeek(4,{cID}))
				::fcMsg := STR0018 + STR0020 + "'" + alltrim(oProjeto:cValue("NOME")) + "'!"
				::oOwner():oOltpController():lRollback()
				return KPI_ST_VALIDATION
			else
				::fcMsg := ""
			endif
			
			//KPI014: Projeto - Responsavel pelo projeto
			oProjeto := oKpiCore:oGetTable("PROJETO")
			if(oProjeto:lSeek(5,{cID}))
				::fcMsg := STR0018 + STR0029 + "'" + alltrim(oProjeto:cValue("NOME")) + "'!"
				::oOwner():oOltpController():lRollback()
				return KPI_ST_VALIDATION
			else
				::fcMsg := ""
			endif
			
			//KPI015: Indicador - Responsável pela coleta
			oIndicador := oKpiCore:oGetTable("INDICADOR") 
			if(oIndicador:lSeek(7,{cID,TIPO_USUARIO}))
				::fcMsg := STR0018 + STR0021 + "'" + alltrim(oIndicador:cValue("NOME")) + "'!"
				::oOwner():oOltpController():lRollback()
				return KPI_ST_VALIDATION
			else
				::fcMsg := ""
			endif
			
			oIndicador := oKpiCore:oGetTable("INDICADOR") 
			if(oIndicador:lSeek(7,{cID,""}))
				::fcMsg := STR0018 + STR0021 + "'" + alltrim(oIndicador:cValue("NOME")) + "'!"
				::oOwner():oOltpController():lRollback()
				return KPI_ST_VALIDATION
			else
				::fcMsg := ""
			endif			

			//KPI015: Indicador - Responsável pelo indicador
			if(oIndicador:lSeek(8,{cID, TIPO_USUARIO}))
				::fcMsg := STR0018 + STR0022 + "'" + alltrim(oIndicador:cValue("NOME")) + "'!"
				::oOwner():oOltpController():lRollback()
				return KPI_ST_VALIDATION
			else
				::fcMsg := ""
			endif

			if(oIndicador:lSeek(8,{cID, ""}))
				::fcMsg := STR0018 + STR0022 + "'" + alltrim(oIndicador:cValue("NOME")) + "'!"
				::oOwner():oOltpController():lRollback()
				return KPI_ST_VALIDATION
			else
				::fcMsg := ""
			endif

			//KPI016: Plano - Owner
			oPlano := oKpiCore:oGetTable("PLANOACAO")
			if(oPlano:lSeek(5,{cID}))
				::fcMsg := STR0018 + STR0023 + "'" + alltrim(oPlano:cValue("NOME")) + "'!"
				::oOwner():oOltpController():lRollback()
				return KPI_ST_VALIDATION
			else
				::fcMsg := ""
			endif

			//KPI016: Plano - Responsável
			if(oPlano:lSeek(7,{cID,TIPO_USUARIO}))
				::fcMsg	:= STR0018 + STR0047 + "'" + alltrim(oPlano:cValue("NOME")) + "'!"
				::oOwner():oOltpController():lRollback()
				return KPI_ST_VALIDATION
			else
				::fcMsg := ""
			endif

			if(oPlano:lSeek(7,{cID,""}))
				::fcMsg	:= STR0018 + STR0047 + "'" + alltrim(oPlano:cValue("NOME")) + "'!"
				::oOwner():oOltpController():lRollback()
				return KPI_ST_VALIDATION
			else
				::fcMsg := ""
			endif

			//KPI018: Grupo de Ação - Responsável 
			oGrpAcao := oKpiCore:oGetTable("GRUPO_ACAO")
			if(oGrpAcao:lSeek(3,{cID,TIPO_USUARIO}))
				::fcMsg	:= STR0018 + STR0024 + "'" + alltrim(oGrpAcao:cValue("NOME")) + "'!"
				::oOwner():oOltpController():lRollback()
				return KPI_ST_VALIDATION
			else
				::fcMsg := ""
			endif

			if(oGrpAcao:lSeek(3,{cID,""}))
				::fcMsg	:= STR0018 + STR0024 + "'" + alltrim(oGrpAcao:cValue("NOME")) + "'!"
				::oOwner():oOltpController():lRollback()
				return KPI_ST_VALIDATION
			else
				::fcMsg := ""
			endif


			//KPI015G: Alteracao de Meta
			If (oJustific:lSeek(3,{cID}))
				::fcMsg	:= STR0043
				::oOwner():oOltpController():lRollback()
				return KPI_ST_VALIDATION				     
			else
				::fcMsg := ""
			EndIf

			//Exclui as opcoes de personalizacao do grafico
			oGraph:SetOrder(1) // Por ordem de id
			oGraph:cSQLFilter("USUARIO = '" + cID + "'") 
			oGraph:lFiltered(.t.)
			oGraph:_First()
		
			while(!oGraph:lEof())
				if(!oGraph:lDelete())
					nStatus := KPI_ST_INUSE
				endif
				oGraph:_Next()
			enddo
			
			oGraph:cSQLFilter("")	
						
			if(!::lDelete())
				nStatus := KPI_ST_INUSE
			else
				nStatus		:= oKpiCore:oGetTable("REGRA"):nDelFromXML(cID,"U")
				if(nStatus != KPI_ST_OK)
					::oOwner():oOltpController():lRollback()
					return nStatus
				endif
				nStatus		:= oKpiCore:oGetTable("GRPUSUARIO"):nDelFromXML(cID, "U")
				if(nStatus != KPI_ST_OK)
					::oOwner():oOltpController():lRollback()
					return nStatus
				endif
				nStatus		:= oKpiCore:oGetTable("SCOR_X_USER"):nDelFromXML(cID, "U")
				if(nStatus != KPI_ST_OK)
					::oOwner():oOltpController():lRollback()
					return nStatus
				endif
				nStatus		:= oKpiCore:oGetTable("PERM_PROJETO"):nDelFromXML(cID, "U")
				if(nStatus != KPI_ST_OK)
					::oOwner():oOltpController():lRollback()
					return nStatus
				endif
				nStatus		:= oKpiCore:oGetTable("USU_CONFIG"):nDelFromXML(cID)
				if(nStatus != KPI_ST_OK)
					::oOwner():oOltpController():lRollback()
					return nStatus
				endif
			endif
		else
			nStatus := KPI_ST_BADID
		endif	
	else
		nStatus := KPI_ST_NORIGHTS
	endif	                                    
	
	if nStatus != KPI_ST_OK
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

return nStatus

method nSqlCount() class TKPI002
	local nCount
	
	nCount := _Super:nSqlCount()
	
	if(::lSeek(1,{padr("0",10)}))
		nCount--
	endif

return nCount
                       
method nExecute(nID, cExecCMD) class TKPI002
	local aRequest 	:= aBIToken(cExecCMD, "|", .f.)
	local aUsuario 	:= {}
	local cScoreID 	:= ""
	local cUserID	:= ""
	local nStatus	:= KPI_ST_OK
	local oUserSco	:= ::oOWner():oGetTable("SCOR_X_USER")
	local oPlanoAcao:= ::oOWner():oGetTable("PLANOACAO")
	local nItem		:= 0
	local nPosScor	:= 0
	local lHasPlan	:= .f.

	//Gravacao da permissao de visualizacao dos scorecards.
	if(aRequest[1] == "SAVE_PERMISSAO")
		cScoreID:= aRequest[2]
				
		for nItem := 4 to len(aRequest)
			if(! empty(aRequest[nItem]))
				aadd(aUsuario,aRequest[nItem])
			endif
		next nItem		 

		oUserSco:SetOrder(2)
		oUserSco:cSQLFilter("SCORE_ID ='" + cScoreID + "'")
		oUserSco:lFiltered(.t.)
		oUserSco:_first()

		do while(! oUserSco:lEof())
			nPosScor := ascan(aUsuario, {|x| alltrim(x)  == alltrim(oUserSco:cValue("USERID"))})
			if(nPosScor == 0)//Vai remover
				oPlanoAcao:SetOrder(4)
				if(oPlanoAcao:lSeek(4,{cScoreID}))
					do while(! oPlanoAcao:lEof() .and. alltrim(cScoreID) == alltrim(oPlanoAcao:cValue("ID_SCOREC")))
						cUserID := oUserSco:cValue("USERID")
						if oPlanoAcao:lUsuResp(cUserID)  
							lHasPlan := .t.
							exit
						endif
						oPlanoAcao:_Next()
					end
				endif
			endif
			oUserSco:_Next()
		end
		oUserSco:cSQLFilter("")
		
		if(! lHasPlan)
			nStatus := oUserSco:nDelFromXML(cScoreID,"S")
			if(len(aUsuario) > 0 .and. nStatus == KPI_ST_OK)
				oUserSco:nInsFromXML(cScoreID,aUsuario)
			endif
		else
			::lSeek(1,{cUserID })
			::fcMsg := STR0026 + alltrim(::cValue("NOME")) + STR0027 //"O usuário " - " não pode ser removido, porque existe plano de ações para ele."
			nStatus :=  KPI_ST_VALIDATION  
		endif
    endif
    
return nStatus

method oGetSco(cUser,lAdmin) class TKPI002  
	Local oXMLArvore	:= Nil	
	Local oTreeNode 	:= Nil 
	Local cEnabled		:= "True"
	Local cSelected		:= "False"
	Local oParametro 	:= ::oOwner():oGetTable("PARAMETRO")
	Local lRecursive	:= xBIConvTo("L", oParametro:getValue("PERMISSAO_RECURSIVA") )               
	
	Private aScoPerm	:= ::oOWner():oGetTable("SCOR_X_USER"):aScorxUsu( cUser )
	Private oSco		:= ::oOwner():oGetTable("SCORECARD") 

	If (lAdmin)    
		cEnabled := "False"
		cSelected := "True"
	endif
           
	//Ordena pela Ordem depois por ID. 
	oSco:SetOrder(6)
	oSco:_First()   
	
	if(! oSco:lEof())

		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", "0")
		oAttrib:lSet("TIPO", "DPTOS")
		oAttrib:lSet("NOME", ::oOwner():getStrCustom():getStrSco())
		oAttrib:lSet("ENABLED", cEnabled)
		oAttrib:lSet("SELECTED", cSelected)          
		oAttrib:lSet("IMAGE"	, oSco:nTreeImgByType( oSco:nValue("TIPOSCORE") ) )		
		oXMLArvore := TBIXMLNode():New("DPTOS","",oAttrib)
                        
		while(!oSco:lEof())
			
			if ( !(alltrim(oSco:cValue("ID")) == "0") .and. Empty(oSco:cValue("PARENTID")))
				oSco:SavePos()

				If (lRecursive )  
					oTreeNode := ::oRecursiveGetChild(cUser,cEnabled,cSelected)  
				Else
					oTreeNode := ::oSimpleGetChild(cUser)
				EndIf 
		
				if !( oTreeNode == Nil )    
					oXMLArvore:oAddChild(oTreeNode)  
				endif 
				
				oSco:SetOrder(1)
				oSco:RestPos()  
				
			endif				
			oSco:_Next()
		enddo                                                     
	endif

return oXMLArvore                            

 
//Monta os nós filhos da árvore de scorecards de permissões.
//@param (Caracter) cIDUser ID do usuário.
//@return (Objeto) Nó XML.
//@see O responsável pelo scorecard não terá acesso aos filhos.

method oSimpleGetChild(cIDUser) class TKPI002
	local cId 			:= ""
	local cParentID 	:= ""  
	local cEnabled 		:= "True" 	
	local cSelected     := "False"    
	local nRec 			:= 0
	local oNode			:= nil
	local oXMLNode		:= nil
	local oAttrib   	:= nil
	Local cOrdem		:= ""   
	
	default cIDUser		:= ""		
	
	oSco:SetOrder(5) 
	nRec := oSco:nRecno()   
	
	cParentID 	:= oSco:cValue("PARENTID")
	cId			:= oSco:cValue("ID")
	cOrdem 		:= Padl(AllTrim(oSco:cValue("ORDEM")),3,"0")       

	//Desabilita e seleciona o nó caso o usuário seja responsável pelo scorecard.
	if alltrim( oSco:cValue("RESPID") ) == alltrim(cIDUser)
		cEnabled 	:= "False"
		cSelected 	:= "True"
	Else 
		//Seleciona os scorecards que o usuário recebeu permissão. 	
		If ( ascan(aScoPerm, { |x| alltrim(x[1])  == alltrim(cId)}) > 0 )
			cSelected := "True"
		endif
	EndIf
	
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID"		, cID)
	oAttrib:lSet("NOME"		, alltrim(oSco:cValue("NOME")))
	oAttrib:lSet("ENABLED"	, cEnabled)
	oAttrib:lSet("SELECTED"	, cSelected)
	oAttrib:lSet("IMAGE"	, oSco:nTreeImgByType( oSco:nValue("TIPOSCORE") ) )
	
	oXMLNode := TBIXMLNode():New("DPTOS" + "." + cOrdem + "." + alltrim(cID),"",oAttrib)	
	
	if oSco:lSeek(2,{cID}) 
		while(oSco:cValue("PARENTID") == cID .and. ! oSco:lEof())                 
			if oSco:lSeek(1, {oSco:cValue("ID")}) 
				oNode := ::oSimpleGetChild( cIDUser )
				if !oNode==nil 
					if oXMLNode==nil   
						oXMLNode:= oNode
					else                         
						oXMLNode:oAddChild(oNode)
					endif
				endif
			endif    
			oSco:_Next()
		enddo		
	endif

	oSco:lGoTo(nRec)

return oXMLNode    


//Monta os nós filhos da árvore de scorecards de permissões.
//@param (Caracter) cIDUser ID do usuário.
//@param (Caracter) cEnabled Indica se o nó estará habilitado.
//@param (Caracter) cSelected Indica se o nó estará selecionado.
//@return (Objeto) Nó XML.  
//@see O responsável pelo scorecard terá acesso aos filhos.     
method oRecursiveGetChild(cUserID,cEnabled,cSelected) class TKPI002
	local cId 			:= ""
	local cParentID 	:= ""     
	local nRec 			:= 0
	local oNode			:= nil
	local oXMLNode		:= nil
	local oAttrib   	:= nil
	Local cOrdem 		:= ""   
	
	default cUserId		:= ""		
	
	oSco:SetOrder(5) 
	nRec := oSco:nRecno()   
	
	cParentID 	:= oSco:cValue("PARENTID")
	cId			:= oSco:cValue("ID")
	cOrdem 		:= Padl(AllTrim(oSco:cValue("ORDEM")),3,"0")           

	//Desabilitamos caso o usuário seja responsável pelo departamento
	if cEnabled == "True" .and. alltrim(oSco:cValue("RESPID")) == alltrim(cUserID)
		cEnabled = "False"
	endif  
	
	//Caso o usuário seja responsável pelo departamento pai terá acesso aos filhos    
	cSelected := "False"
	if cEnabled = "False"
		cSelected := "True"
	elseif ascan(aScoPerm, { |x| alltrim(x[1])  == alltrim(cId)}) > 0
		cSelected := "True"
	endif

	
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID"		, cID)
	oAttrib:lSet("NOME"		, alltrim(oSco:cValue("NOME")))
	oAttrib:lSet("ENABLED"	, cEnabled)
	oAttrib:lSet("SELECTED"	, cSelected)
	oAttrib:lSet("DESCRICAO", alltrim(oSco:cValue("DESCRICAO")))
	oAttrib:lSet("PARENTID"	, oSco:cValue("PARENTID") )  
	oAttrib:lSet("IMAGE"	, oSco:nTreeImgByType( oSco:nValue("TIPOSCORE") ) )
	
	oXMLNode := TBIXMLNode():New("DPTOS" + "." + cOrdem + "." + alltrim(cID),"",oAttrib)	         

	if oSco:lSeek(2,{cID}) //Tem nos filhos
		while(oSco:cValue("PARENTID") == cID .and. ! oSco:lEof())                 
			if oSco:lSeek(1, {oSco:cValue("ID")}) 
				oNode := ::oRecursiveGetChild(cUserID , cEnabled , cSelected)
				if !oNode==nil 
					if oXMLNode==nil   
						oXMLNode:= oNode
					else                         
						oXMLNode:oAddChild(oNode)
					endif
				endif
			endif    
			oSco:_Next()
		enddo		
	endif

	oSco:lGoTo(nRec)

return oXMLNode

method getFaRegra() class TKPI002
	local oPar 	:=	::oOwner():oGetTable("PARAMETRO")	
	local nI	:=	0
	local aRet	:=	{}
	
	//Modo de análise BSC
	If oPar:getValue("MODO_ANALISE") == ANALISE_BSC//modo=2

 		For	nI := 1 To Len(::faRegra)
			If ::faRegra[nI][COL_ANALISE] != ANALISE_PDCA
				aAdd(aRet,aClone(::faRegra[nI]))
			EndIf
 		Next

	Else//modo=1

 		For	nI := 1 To Len(::faRegra)
			If ::faRegra[nI][COL_ANALISE] != ANALISE_BSC
				aAdd(aRet,aClone(::faRegra[nI]))
			EndIf
 		Next

	EndIf

return aRet

function _KPI002_Usu()
return nil