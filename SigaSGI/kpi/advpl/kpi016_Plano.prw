// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI016_Plano.prw
// ---------+-------------------+--------------------------------------------------------      
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 21.09.05 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI016_Plano.ch"

/*--------------------------------------------------------------------------------------
@entity Plano de Ação
Plano de Ação no KPI. Contém os alvos.
Plano de Ação de indicadores.
@table KPI016
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "PLANOACAO"
#define TAG_GROUP  "PLANOSACAO"
#define TEXT_ENTITY STR0001/*//"Plano de Ação"*/
#define TEXT_GROUP  STR0002/*//"Planos de Ação"*/

class TKPI016 from TBITable
	method New() constructor
	method NewKPI016()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(cParentID, nTipo)  //1=Indicador, 2=Projeto  3=Grupo Assunto
	method oToXMLRecList( cCMDSQL )
	
	// registro atual
	method oToXMLNode( cParentId, cTipoAcao )
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(cID)
	method oXMLStatus()
	method oToXmlPendencia()
	method lUsuResp(cUsuAtual)
	method cGetStatusDescricao(nStatus)
	method cCriaMensagem(cRespNome, cUsuLogado, cNomePlano, dDataFimAntes, dDataFimDepois)  
	method lSendMailOwner(cIdResp,lTipoGrupo)
	method nGetColorStatus(cStatus,dDataFim)
	method cGetClassStatus(cStatus,dDataFim) 
	method lHasUserAccess(cUserId,cScoreID)
	method oToXMLCboFilters() 
	method oToXMLBuildList()
	method oToXMLAcao()         
	method lAddToList()
	method lRespGrupo(cUserId, cUserTp)

endclass
	
method New() class TKPI016
	::NewKPI016()
return

method NewKPI016() class TKPI016
	// Table
	::NewTable("SGI016")
	::cEntity(TAG_ENTITY)

	//Chave primaria e chaves estrangeiras.
	::addField(TBIField():New("ID"        ,	"C"	,10))
	::addField(TBIField():New("ID_IND"    ,	"C"	,10))//Id do indicador. (parentId)
	::addField(TBIField():New("ID_PROJ"	  ,	"C"	,10))//Id do projeto. (parentId)
	::addField(TBIField():New("ID_SCOREC" ,	"C"	,10))//Id do Scorecard. (parentId)
	::addField(TBIField():New("ID_OWNER"  ,	"C"	,10))//Id do Usuário que criou o plano de ação   
	::addField(TBIField():New("ID_ASSUNTO", "C"	,10))//Id do Grupo de Assunto
	/* Temporario
	::addField(TBIField():New("ID_DEPTO"  , "C"	,10))//Id do Departamento
	*/

	//Campos
	::addField(TBIField():New("NOME"		,"C"	,255))
	::addField(TBIField():New("DESCRICAO"	,"C"	,255))
	::addField(TBIField():New("OBJETIVO"	,"C"	,255))
	::addField(TBIField():New("COMO"		,"C"	,255))
	::addField(TBIField():New("INVESTIMEN"	,"C"	,255))
	::addField(TBIField():New("CAUSA"		,"C"	,500))
	::addField(TBIField():New("RESULTADO"	,"C"	,255))
	::addField(TBIField():New("OBSERVACAO"	,"C"	,255))
	::addField(TBIField():New("STATUS"		,"C"	,001))	//"1=Näo Iniciada","2=Em Execucäo","3=Executada","4=Pendente","5=Adiada","6=Cancelada"
	::addField(TBIField():New("TIPOACAO"	,"C"	,001)) 	//1=por Indicador 2=por Projeto  3= por Assunto
	::addField(TBIField():New("DATAINICIO"	,"D"	))     	
	::addField(TBIField():New("DATAFIM"		,"D"	))
	::addField(TBIField():New("DATATERM"	,"D"	))
	::addField(TBIField():New("PERCREAL"	,"N"	, 6,2)) // Percentual Realizado
	::addField(TBIField():New("VLRINVEST"	,"N"	,19,2))	// Numero de casas decimais
	::addField(TBIField():New("DATACADAST"	,"D"	))
	::addField(TBIField():New("JUSTIFICA"	,"C"	,255))	//Justificativa de cancelamento do plano
	::addField(TBIField():New("LOGACAO"		,"M"	))		//Log de operacoes	
	::addField(TBIField():New("CATEGORIA"	,"N"	))  	//Tipo do ação [0-Corretiva 1-Preventiva]   
	::addField(TBIField():New("ID_RESP"		,"C",	10))  	//id do responsável (ou do grupo)
	::addField(TBIField():New("TP_RESP"		,"C",	01))  	//Tipo do responsável (U = Usuário, G = Grupo)

	// Indexes
	::addIndex(TBIIndex():New("SGI016I01",	{"ID"}					, .t.))
	::addIndex(TBIIndex():New("SGI016I02",	{"ID_IND", "DATAFIM"}	, .f.))
	::addIndex(TBIIndex():New("SGI016I03",	{"ID_PROJ", "DATAFIM"}	, .f.))
	::addIndex(TBIIndex():New("SGI016I04",	{"ID_SCOREC"}			, .f.))
	::addIndex(TBIIndex():New("SGI016I05",	{"ID_OWNER"}			, .f.))
	::addIndex(TBIIndex():New("SGI016I06",	{"ID_ASSUNTO"}			, .f.))
	::addIndex(TBIIndex():New("SGI016I07",	{"ID_RESP", "TP_RESP"}	, .f.))
	/* Temporario
//	::addIndex(TBIIndex():New("SGI016I08",	{"ID_DEPTO"}			, .f.))*/
return

// Arvore
method oArvore(nParentID) class TKPI016
return oXMLArvore


//Lista dos Registros de PLANOACOES
method oToXMLAcao( cCMDSQL, cTipo ) class TKPI016
	local oSysParameters 	:= ::oOwner():oGetTable("PARAMETRO")
	local oIndicador		:= ::oOwner():oGetTable("INDICADOR")
	local oScoreCard 		:= ::oOwner():oGetTable("SCORECARD")
	local oGrupo			:= ::oOwner():oGetTable("GRUPO")
	local oUsuario			:= ::oOwner():oGetTable("USUARIO")
	local oUsrGrp			:= ::oOwner():oGetTool("USERGROUP")  
	/* Temporario
//	local oDepartamento     := ::oOwner():oGetTool("CADDEPTO") 
	*/
	local oUser				:= nil
	local oXMLNodeLista		:= nil
	local oAttrib			:= nil
	local oXMLNode			:= nil
	local cScoreID			:= ""
	local cUsuAtual 		:= ""
	local cSqlFilter		:= ""
	local cIdOwner			:= ""
	local cIdPlano			:= ""
	local cIdResp			:= ""
	local cTpResp			:= ""
	local aRequest			:= {}
	local nInd				:= 0
	local nDias 			:= val(oSysParameters:getValue("NUM_DIA_PRO_FIN")) //Numero de dias para exibir ações finalizadas ou canceladas
	local nVencDias			:= val(oSysParameters:getValue("PRAZO_PARA_VENC")) //Numero de dias para exibir ações a vencer
	local xValue			:= nil
	local lAddPlano			:= .F.
	local lResp				:= .F.      
	local lAdmin			:= .F.  
	Local oGrupoUsu	:= ::oOwner():oGetTable("GRPUSUARIO")
	local aGrupos  := ""   
	local nContador :=0

	oXMLNodeLista := TBIXMLNode():New("LISTA")

	//Colunas
	oAttrib := TBIXMLAttrib():New()

	//Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)

	// Tipo de plano de acao 1=por Indicador 2=por Projeto
	oAttrib:lSet("TAG000", "IMG_OWNER")
	oAttrib:lSet("CAB000", "")
	oAttrib:lSet("CLA000", KPI_IMAGEM)

	//Id do Indicador
	oAttrib:lSet("TAG001", "IND_NAME")
	oAttrib:lSet("CAB001", STR0019) //"Indicador"
	oAttrib:lSet("CLA001", KPI_STRING)
         
	If oSysParameters:getValue("MODO_ANALISE") == ANALISE_BSC
		//Objetivo Estratégico
		oAttrib:lSet("TAG002", "SCORE_NAME")
		oAttrib:lSet("CAB002", STR0053) //"Objetivo Estratégico"
		oAttrib:lSet("CLA002", KPI_STRING)
	Else
		//Scorecard
		oAttrib:lSet("TAG002", "SCORE_NAME")
		oAttrib:lSet("CAB002", ::oOwner():getStrCustom():getStrSco()) //"Scorecard"
		oAttrib:lSet("CLA002", KPI_STRING)
	EndIf

	//Plano de Ação
	oAttrib:lSet("TAG003", "NOME")
	oAttrib:lSet("CAB003", STR0020) //"Ação"
	oAttrib:lSet("CLA003", KPI_STRING)
	
	//Data de Cadastro
	oAttrib:lSet("TAG004", "DATACADAST")
	oAttrib:lSet("CAB004", STR0021) //"Cadastro"
	oAttrib:lSet("CLA004", KPI_STRING)
	
	//Responsavel
	oAttrib:lSet("TAG005", "RESP_NAME")
	oAttrib:lSet("CAB005", STR0011) //"Responsável"
	oAttrib:lSet("CLA005", KPI_STRING)
	
	//Responsavel 
	/*Temporario
	oAttrib:lSet("TAG006", "IND_DEPTO")
	oAttrib:lSet("CAB006", ::oOwner():getStrCustom():getStrDepart()) //"Departamento"
	oAttrib:lSet("CLA006", KPI_STRING)*/

	//Data Prev.
	oAttrib:lSet("TAG006", "DATAFIM")
	oAttrib:lSet("CAB006", STR0017)  //"Término Prev."
	oAttrib:lSet("CLA006", KPI_STRING)
	
	//Status
	oAttrib:lSet("TAG007", "STATUS")
	oAttrib:lSet("CAB007", STR0012) //"Status"
	oAttrib:lSet("CLA007", KPI_STRING)		
	
	//Gera o principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)

	//Verifica o usuario atual
	oUser		:= oKpiCore:foSecurity:oLoggedUser()
	cUsuAtual 	:= oUser:cValue("ID")
	lAdmin		:= oUser:lValue("ADMIN")
	
	/*
	*ATENCAO!
	*Como existem varias opcoes para o carregamento da lista de planos.
	*Foi necessario fazer o tratamento atravez do comando cCMDSQL, para cada caso.
	*/
        
	//Tipo de Ação:  1=indicador , 2=projeto
	cSqlFilter := "TIPOACAO = '" + cTipo  + "'"

	//Gera o no de detalhes
	::SetOrder(1)
	if ! empty(cCMDSQL) 
		aRequest := aBIToken(cCmdSQL, "|", .F.)
		do case
			case aRequest[1] == "PLANO_GRUPO_ACAO" 
				//Todas ações de um determindo grupo de ação
				cSqlFilter	+=	" AND ID_ASSUNTO = '" + padr(aRequest[2],10)+ "'"
				
			case aRequest[1] == "PLANO_SCORECARD" 
				//Todas ações de um Scorecard
				cScoreID	:=	cBIStr(aRequest[2])
				cSqlFilter	+=	" AND ID_SCOREC   = '" + cScoreID 	+ "'"
				
			case aRequest[1] == "LIST_PA_VENCIDO"
				//Lista de acoes vencidas
				cSqlFilter +=	" AND STATUS !=	'6' AND STATUS != '3'"
				cSqlFilter +=	" AND DATAFIM < '"+ dTos(date()) + "'"
	
			case aRequest[1] == "LIST_PA_AVENCER" 
				//Lista de acoes que irao vencer 
				cSqlFilter +=	" AND STATUS != '6' AND STATUS != '3'"
				cSqlFilter +=	" AND DATAFIM < '"+ dTos(date() + nVencDias) + "'"			
				cSqlFilter +=	" AND DATAFIM >= '"+ dTos(date()) + "'" 
				
			case aRequest[1] == "PLANO_USUARIO" 
				//Lista de acoes de um usuário ou grupo específico
				cSqlFilter +=	" AND ID_RESP IN ('" + aRequest[2] + "'" 
				
				if ( aRequest[3] =="U" ) //Se for um usuário específico, procura por todos os grupos que o mesmo participa
					aGrupos:= oGrupoUsu:aGroupsByUser(aRequest[2])
 				    
					For nContador:=1 to Len(aGrupos)
						cSqlFilter += " , '" + aGrupos[nContador]  + " ' "
					Next  
				endif 
				
				cSqlFilter += " )"   
				cSqlFilter += " AND D_E_L_E_T_<>'*' "
				
			case aRequest[1] == "PLANO_USER_ALL" 
				//Lista de acoes do usuário que está logado no SGI
				cSqlFilter +=	" AND ID_RESP IN ('" + cBIStr( cUsuAtual ) + "'" 
				
				aGrupos:= oGrupoUsu:aGroupsByUser(cUsuAtual)
 				    
				For nContador:=1 to Len(aGrupos)
					cSqlFilter += " , '" + cBIStr( aGrupos[nContador] ) + "'"
				Next  
 			     
				cSqlFilter += " )"   
				cSqlFilter += " AND D_E_L_E_T_<>'*' "
		endcase
	endif

	//Exibi ações canceladas ou finalizadas pelo tempo cadastrado nos parametros do sistema                 
	cSqlFilter	+=	" AND ((DATATERM >= '"	+ dtos(date() - nDias) + "'"
	cSqlFilter	+=	" AND DATATERM <= '" + dtos(date()) + "')"
	cSqlFilter	+=	" OR DATATERM = ' ')" //Ações em aberto

	::cSQLFilter(cSqlFilter) // 1=indicador , 2=projeto
	::lFiltered(.t.)
	::_First()

	while !::lEof()
		lAddPlano := !( alltrim( ::cValue("ID") ) == "0" )

		if lAddPlano
			if aRequest[1] == "PLANO_USUARIO" 
				cIdResp := padr( aRequest[2], 10 )
				cTpResp := allTrim( aRequest[3] )

				if cTpResp == TIPO_GRUPO
					if ::cValue("TP_RESP") == TIPO_GRUPO
						lAddPlano := (cIdResp == ::cValue("ID_RESP"))
					else
						lAddPlano := .F.
					endif
				else
					lAddPlano := ::lUsuResp(cIdResp, cTpResp)
				endif
			elseif aRequest[1] == "PLANO_USER_ALL" .or. aRequest[1] == "LIST_PA_VENCIDO" .or. aRequest[1] == "LIST_PA_AVENCER"
				cIdResp := cUsuAtual
				cTpResp := TIPO_USUARIO

				lAddPlano := ::lUsuResp(cIdResp, cTpResp)			
			else
				cIdResp := cUsuAtual
				cTpResp := TIPO_USUARIO

				lAddPlano := lAdmin .or. ::lUsuResp(cIdResp, cTpResp)
			endif
		endif

		lAddPlano := lAddPlano .And. ::lAddToList()

		if lAddPlano
			cIdOwner	:= alltrim(::cValue("ID_OWNER"))
			cIdPlano	:= alltrim(::cValue("ID"))
	
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {	"DATATERM"	,"PERCREAL",;
					"VLRINVEST"	,"OBJETIVO","INVESTIM",;
					"CAUSA"		,"RESULTADO"})

			for nInd := 1 to len(aFields)
				xValue := aFields[nInd][2]

				if(aFields[nInd][1] == "STATUS")
					xValue := ::cGetStatusDescricao(aFields[nInd][2])
				elseif(aFields[nInd][1] == "ID_OWNER")
					//Adicionando o responsavel
					if(! empty(cIdOwner) .and. oUser:lSeek(1,{cIdOwner}))
						oNode:oAddChild(TBIXMLNode():New("RESPONSAVEL", alltrim(oUser:cValue("NOME"))))
					else
						oNode:oAddChild(TBIXMLNode():New("RESPONSAVEL", ""))
					endif
				endif

				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], xValue))
			next

			//Adicionando o nome do Reponsável pelo plano
			if ::cValue("TP_RESP") == TIPO_GRUPO
				if oGrupo:lSeek(1, {alltrim(::cValue("ID_RESP"))})
					oNode:oAddChild(TBIXMLNode():New("RESP_NAME", alltrim(oGrupo:cValue("NOME"))))
				else
					oNode:oAddChild(TBIXMLNode():New("RESP_NAME", STR0014))//Sem Responsavel
				endif
			else//TIPO_USUARIO
				if oUsuario:lSeek(1, {alltrim(::cValue("ID_RESP"))})
					oNode:oAddChild(TBIXMLNode():New("RESP_NAME", alltrim(oUsuario:cValue("COMPNOME"))))
				else
					oNode:oAddChild(TBIXMLNode():New("RESP_NAME", STR0014))//Sem Responsavel
				endif
			endif

			//Imagem do Onwer  
			if ::cValue("TP_RESP") == TIPO_GRUPO
				lResp := oUsrGrp:lUserInGrp( cUsuAtual, ::cValue("ID_RESP") )
			else
				lResp := ( cUsuAtual == ::cValue("ID_RESP") )
			endif

			if lResp
				oNode:oAddChild(TBIXMLNode():New("IMG_OWNER", KPI_IMG_PLANO_RESP))
			elseif alltrim(cUsuAtual) == alltrim(cIdOwner)
				oNode:oAddChild(TBIXMLNode():New("IMG_OWNER", KPI_IMG_PLANO_OWNER))
			else
				oNode:oAddChild(TBIXMLNode():New("IMG_OWNER", KPI_IMG_PLANO_LOCK))
			endif

			//Adicionando o nome do Indicador
			oIndicador := ::oOwner():oGetTable("INDICADOR")
			if(oIndicador:lSeek(1, {alltrim(::cValue("ID_IND"))}))
				oNode:oAddChild(TBIXMLNode():New("IND_NAME", alltrim(oIndicador:cValue("NOME"))))
			endif                            
			
			//Adicionando o nome do departamento - Temporario
			/*
			oDepartamento := ::oOwner():oGetTable("CADDEPTO")
			if(oDepartamento:lSeek(1, {alltrim(::cValue("ID_DEPTO"))}))
				oNode:oAddChild(TBIXMLNode():New("IND_DEPTO", alltrim(oDepartamento:cValue("NOME"))))
			Else
				oNode:oAddChild(TBIXMLNode():New("IND_DEPTO", ""))
			EndIf*/

			//Adicionando o nome do Scorecard
			if( oScorecard:lSeek( 1, { alltrim(::cValue("ID_SCOREC")) } ) )
				oNode:oAddChild(TBIXMLNode():New("SCORE_NAME", alltrim(oScorecard:cValue("NOME"))))
			Else
				oNode:oAddChild(TBIXMLNode():New("SCORE_NAME", ""))
			EndIf

			oNode:oAddChild(TBIXMLNode():New("STATUS_ID", ::cValue("STATUS")))
			oNode:oAddChild(TBIXMLNode():New("STATUS_COLOR"	,::nGetColorStatus(::cValue("STATUS"), ::dValue("DATAFIM")) ))
		endif

		::_Next()
	end


	oXMLNodeLista:oAddChild(oXMLNode)

	::cSQLFilter("") // Encerra filtro	

return oXMLNodeLista



//Requisições dos formularios relacionados com PA
method oToXMLRecList( cCMDSQL, cTipo ) class TKPI016
	local oUsrGrp			:= ::oOwner():oGetTool("USERGROUP")   
	local oXMLNodeLista		:= nil
	
	Default cCMDSQL := ""
	Default cTipo 	:= "1" //indicador (default) para projetos eh chamado no cadastro de projetos

	if(cCMDSQL=="CBOFILTER")
    	oXMLNodeLista := ::oToXMLCboFilters()
	elseif(cCMDSQL=="LEMBRETE")
		oXMLNodeLista := ::oToXmlPendencia()
	elseif(cCMDSQL=="USUARIOS")
		oXMLNodeLista := TBIXMLNode():New("LISTA")
		oXMLNodeLista:oAddChild(oUsrGrp:oTreeUsrGrp())
		oXMLNodeLista:oAddChild(oUsrGrp:oUsuGroup())
	else
    	oXMLNodeLista := ::oToXmlAcao(cCMDSQL, cTipo) 
	endif

return oXMLNodeLista


method oToXMLCboFilters() class TKPI016
	local oSysParameters := ::oOwner():oGetTable("PARAMETRO")
	local oXMLNodeLista	 := TBIXMLNode():New("LISTA")
	local aMyActioFilter := {}
	local cVencDia		 := oSysParameters:getValue("PRAZO_PARA_VENC") //Numero de dias para exibir ações a vencer

	aMyActioFilter := {	{STR0056	,"0"} ,; //"[Todas]"
			{STR0057	,"1"} ,; //"Vencidas"
			{STR0058 + cVencDia + STR0059 ,"2"} } //"A vencer em "###" dias"

	oXMLNodeLista:oAddChild(::oToXMLBuildList(aMyActioFilter,"MYACTION_FILTER","MYACTION_FILTERS"))

return oXMLNodeLista


// Constroi o xml a partir de um array
method oToXMLBuildList(aValues,cEntity,cGroup) class TKPI016
	local oNode		:= nil
	local oAttrib	:= nil
	local oXMLNode	:= nil
	local nI		:= 0

	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", cEntity)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", KPI_STRING)

	// Gera no principal
	oXMLNode := TBIXMLNode():New(cGroup,,oAttrib)
	
	
	for nI := 1 to len(aValues)
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(cEntity))
		oNode:oAddChild(TBIXMLNode():New("NOME", aValues[nI][1]))
		oNode:oAddChild(TBIXMLNode():New("ID", aValues[nI][2]))
	next
	
return oXMLNode



// Lista XML para anexar ao pai
// nTipo 1=Indicador , 2=Projeto, 3= Grupo_Assunto 
method oToXMLList(cParentId, nTipo) class TKPI016
	local oNode, oAttrib, oXMLNode, nInd, cFiltro := "", nOrdem
	local oScoreCard	:= ::oOwner():oGetTable("SCORECARD")       
	local oPar 	   		:= ::oOwner():oGetTable("PARAMETRO")
	local oUsuario		:= nil
	local oGrupo 		:= nil
	local cIDStatus		:= "0"
	local isAdmin		:= .f.
	local lUserResp		:= .f.
	local oUser			:= nil
	local cIdOwner		:= "" 
	local cUsuAtual		:= ""                                    
	/* Temporario
	local oDepartamento := nil */
	
	local lAddPlano		:= .F.
	
	Default cParentID := ""
	Default nTipo := 0 

	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	
	// Tipo de plano de acao 1=por Indicador 2=por Projeto
	oAttrib:lSet("TAG000", "IMG_OWNER")
	oAttrib:lSet("CAB000", " ")
	oAttrib:lSet("CLA000", KPI_IMAGEM)

	//Id do Indicador
	oAttrib:lSet("TAG001", "ID_IND")
	oAttrib:lSet("CAB001", STR0019) //"Indicador"
	oAttrib:lSet("CLA001", KPI_STRING)
		
	If oPar:getValue("MODO_ANALISE") == ANALISE_BSC
		//Scorecard
		oAttrib:lSet("TAG002", "SCORE_NAME")
		oAttrib:lSet("CAB002", "Objetivo Estratégico") //Objetivo Estratégico
		oAttrib:lSet("CLA002", KPI_STRING)		
	Else
		//Scorecard
		oAttrib:lSet("TAG002", "SCORE_NAME")
		oAttrib:lSet("CAB002", ::oOwner():getStrCustom():getStrSco()) //"Scorecard"
		oAttrib:lSet("CLA002", KPI_STRING)
	EndIf
		
	//Plano de Ação
	oAttrib:lSet("TAG003", "NOME")
	oAttrib:lSet("CAB003", STR0020) //"Ação"
	oAttrib:lSet("CLA003", KPI_STRING)
		                         
	//Tipo de Acao: Indicador / Projeto
	oAttrib:lSet("TAG004", "RELACIONADO")
	oAttrib:lSet("CAB004", STR0045) //"Relacionado a"
	oAttrib:lSet("CLA004", KPI_STRING)
		
	//Data de Cadastro
	oAttrib:lSet("TAG005", "DATACADAST")
	oAttrib:lSet("CAB005", STR0021) //"Cadastro"
	oAttrib:lSet("CLA005", KPI_STRING)
		
	//Responsavel
	oAttrib:lSet("TAG006", "RESP_NAME")
	oAttrib:lSet("CAB006", STR0011) //"Responsável"
	oAttrib:lSet("CLA006", KPI_STRING)  
		
		//Departamento - Temporario
		/*
		oAttrib:lSet("TAG007", "IND_DEPTO")
		oAttrib:lSet("CAB007", ::oOwner():getStrCustom():getStrDepart()) //"Departamento"
		oAttrib:lSet("CLA007", KPI_STRING)  */
			
	//Data Prev.
	oAttrib:lSet("TAG007", "DATAFIM")
	oAttrib:lSet("CAB007", STR0017)  //"Término Prev."
	oAttrib:lSet("CLA007", KPI_STRING)
		
	//Status
	oAttrib:lSet("TAG008", "STATUS")
	oAttrib:lSet("CAB008", STR0012) //"Status"
	oAttrib:lSet("CLA008", KPI_STRING)		
		
	//Observacao
	oAttrib:lSet("TAG009", "OBSERVACAO")
	oAttrib:lSet("CAB009", STR0013) //"Obs. Status"
	oAttrib:lSet("CLA009", KPI_STRING)
		
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	//Verifica o usuario atual
	oUser		:= oKpiCore:foSecurity:oLoggedUser()
	cUsuAtual 	:= alltrim(oUser:cValue("ID"))
	isAdmin		:= oUser:lValue("ADMIN")
	
	// Gera recheio
	//Gera o no de detalhes
	::SavePos()	

	::SetOrder(1)
	nOrdem := 1
	if(nTipo==1) //indicador
		nOrdem := 2
		cFiltro := "ID_IND = '"+cParentID + "'"
	elseif(nTipo==2)
		nOrdem := 3
		cFiltro := "ID_PROJ = '"+cParentID + "'"
	elseif(nTipo==3)
		nOrdem := 2
				
		if( alltrim(cParentID)== "0")//Quando o da consulta for zero não carregar nenhum plano.
			cParentID := "-1"
		endif

		cFiltro := "ID_ASSUNTO = '"+cParentID + "'"	
	endif   
	
	::SetOrder(nOrdem)
	if(!empty(cParentId))
		::cSQLFilter(cFiltro) // Filtra pelo pai
	endif
	
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		cIdOwner	:= alltrim(::cValue("ID_OWNER"))
		cIdPlano	:= alltrim(::cValue("ID")) 
		lUserResp	:= ::lUsuResp(cUsuAtual)
		
		lAddPlano	:= !(alltrim(::cValue("ID")) == "0") .and. ( isAdmin .or. lUserResp .or. nTipo == 2 .or. nTipo == 3)

		lAddPlano := lAddPlano .And. ::lAddToList()

		if lAddPlano
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {	"DATATERM"	,"PERCREAL",;
					"VLRINVEST"	,"OBJETIVO","INVESTIM",;
					"CAUSA"		,"RESULTADO", "ID_RESP", "TP_RESP"})
						
			for nInd := 1 to len(aFields)
				if(aFields[nInd][1]== "STATUS")
					cIDStatus := aFields[nInd][2]
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1],::cGetStatusDescricao(aFields[nInd][2]) ))
				elseif(aFields[nInd][1]== "ID_OWNER")
					//Adicionando o responsavel
					if(! empty(cIdOwner) .and. oUser:lSeek(1,{cIdOwner}))
						oNode:oAddChild(TBIXMLNode():New("RESPONSAVEL", alltrim(oUser:cValue("NOME"))))
					else
						oNode:oAddChild(TBIXMLNode():New("RESPONSAVEL", ""))
					endif

					//Adicionando o campo de owner
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))

					//Imagem do Onwer						
					if(cUsuAtual==cIdOwner)
						oNode:oAddChild(TBIXMLNode():New("IMG_OWNER", KPI_IMG_PLANO_OWNER))
					elseif (lUserResp .or. isAdmin)
						oNode:oAddChild(TBIXMLNode():New("IMG_OWNER", KPI_IMG_PLANO_RESP))
					elseif (nTipo == 2 .or. nTipo == 3)
						oNode:oAddChild(TBIXMLNode():New("IMG_OWNER", KPI_IMG_PLANO_LOCK))
					endif
				else
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
				endif
			next
			
			//Adicionando o nome do Reponsável pelo plano
			if ::cValue("TP_RESP") == TIPO_GRUPO
				oGrupo := ::oOwner():oGetTable("GRUPO")
				if oGrupo:lSeek(1, {alltrim(::cValue("ID_RESP"))})
					oNode:oAddChild(TBIXMLNode():New("RESP_NAME", alltrim(oGrupo:cValue("NOME"))))
				else
					oNode:oAddChild(TBIXMLNode():New("RESP_NAME", STR0014))//Sem Responsavel
				endif
			else//TIPO_USUARIO
				oUsuario := ::oOwner():oGetTable("USUARIO")
				if oUsuario:lSeek(1, {alltrim(::cValue("ID_RESP"))})
					oNode:oAddChild(TBIXMLNode():New("RESP_NAME", alltrim(oUsuario:cValue("COMPNOME"))))
				else
					oNode:oAddChild(TBIXMLNode():New("RESP_NAME", STR0014))//Sem Responsavel
				endif
			endif
	
			//Adicionando o nome do Scorecard
			if oScorecard:lSeek( 1, { alltrim(::cValue("ID_SCOREC")) } )
				oNode:oAddChild(TBIXMLNode():New("SCORE_NAME", alltrim(oScorecard:cValue("NOME"))))
			endif       
			
			//Adicionando o nome do Departamento  - Temporario
			/*
			oDepartamento := ::oOwner():oGetTable("CADDEPTO") 
			if oDepartamento:lSeek( 1, { alltrim(::cValue("ID_DEPTO")) } )
				oNode:oAddChild(TBIXMLNode():New("IND_DEPTO", alltrim(oDepartamento:cValue("NOME"))))
			endif       			*/
			
			//Adicionando o tipo Indicador / Projeto
			if !Empty(::cValue("ID_IND"))
				oNode:oAddChild(TBIXMLNode():New("RELACIONADO", STR0019)) //Indicador
			elseif !Empty(::cValue("ID_PROJ"))
				oNode:oAddChild(TBIXMLNode():New("RELACIONADO", STR0046)) //Projeto
			endif
			
			oNode:oAddChild(TBIXMLNode():New("STATUS_ID"	, cIDStatus))
			oNode:oAddChild(TBIXMLNode():New("STATUS_COLOR"	,::nGetColorStatus(cIDStatus, ::dValue("DATAFIM")) ))
		endif			
		::_Next()		                   	
	end
	

	::cSQLFilter("") // Encerra filtro	
	::RestPos()

return oXMLNode

// Carregar
method oToXMLNode( cParentId, cTipoAcao ) class TKPI016
	local aFields, nInd, oTable, cScorecard, oAttrib, oNode, nPosTipo, nPosProj, lAlteraFim := .f.
	local oUsuario		:= ::oOwner():oGetTable("USUARIO")
	local oXMLNode		:= TBIXMLNode():New(TAG_ENTITY)
	local oParametro	:= ::oOwner():oGetTable("PARAMETRO")
	local oPlanDoc		:= ::oOwner():oGetTable("PLANODOC")
	local oUsrGrp		:= ::oOwner():oGetTool("USERGROUP")
	local oGrupo		:= ::oOwner():oGetTable("GRUPO_ACAO")
	local xValue		:= ""
	local cTpResp		:= ""
	local lResp			:= .T.
	local cCombo        := ""
	local cStatus       := ""

	if(oParametro:lSeek(1, {"ALT_DATAFIM_PLANO"}))
		lAlteraFim := oParametro:lValue("DADO")
	endif

	Default cParentId 	:= ""
	Default cTipoAcao 	:= "1"
	 
	if ( At("#", cTipoAcao) > 0 )
		cCombo    := SUBSTR(cTipoAcao, At("#", cTipoAcao)+1, len(cTipoAcao)- At("#", cTipoAcao) )
		cTipoAcao := SUBSTR(cTipoAcao, 1, At("#", cTipoAcao)-1)	
		
		if ( At("#", cCombo) > 0 )
			cStatus   := SUBSTR(cCombo, At("#", cCombo)+1, len(cCombo)- At("#", cCombo) )
			cCombo := SUBSTR(cCombo, 1, At("#", cCombo)-1)	
		endif	
	endif	

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		if( alltrim(::cValue("ID")) == "0" .and. !empty(cTipoAcao))
			do case
				case aFields[nInd][1] == "TIPOACAO"
					aFields[nInd][2] := cTipoAcao
				case aFields[nInd][1] == "ID_PROJ" .and. cTipoAcao=="2"
					aFields[nInd][2] := cParentId
				case aFields[nInd][1] == "ID_ASSUNTO" .and. cTipoAcao=="3"
					aFields[nInd][2] := cParentId	
				case aFields[nInd][1] == "STATUS"
					aFields[nInd][2] := ACAO_NAO_INICIADA
			endcase
		endif

		if aFields[nInd][1] == "TIPOACAO"
			nPosTipo := nInd
		elseif aFields[nInd][1] == "ID_PROJ"
			nPosProj := nInd
		endif

		if(aFields[nInd][1] == "ID_OWNER")
			if(oUsuario:lSeek(1, {alltrim(aFields[nInd][2])}))
				oXMLNode:oAddChild(TBIXMLNode():New("OWNER_NAME", alltrim(oUsuario:cValue("NOME"))))
			endif
			oUsuario:_First()
		endif

		xValue := aFields[nInd][2]
		If aFields[nInd][1] == "TP_RESP" 
			If empty(xValue)
				xValue := TIPO_USUARIO
			EndIf
			cTpResp := xValue		
		endif

		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], ( xValue ) ))
	next

	if ( cCombo == "SCORECARD")
		// Acrescenta combos
		if(aFields[nPosTipo][2]=="2")
			oTable:= ::oOwner():oGetTable("PROJETO")
			oTable:lSeek(1, {aFields[nPosProj][2]})
			cScorecard := oTable:cValue("ID_SCORE")
			oXMLNode:oAddChild(TBIXMLNode():New("ID_SCOREC", cScorecard))
	
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("TIPO", "PROJETO")
			oAttrib:lSet("RETORNA", "F")
			oAttrib:lSet("TAG000", "NOME")
			oAttrib:lSet("CAB000", "PROJETO")
			oAttrib:lSet("CLA000", KPI_STRING)
			oNode := oXmlNode:oAddChild(TBIXMLNode():New("PROJETOS", "", oAttrib))
	
			oNode := oNode:oAddChild(TBIXMLNode():New("PROJETO", "", oAttrib))
			oNode:oAddChild(TBIXMLNode():New("ID", oTable:cValue("ID")))
			oNode:oAddChild(TBIXMLNode():New("NOME", alltrim(oTable:cValue("NOME"))))
	
			oTable:= ::oOwner():oGetTable("SCORECARD")
			oTable:lSeek(1, {cScorecard})
	
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("TIPO", "SCORECARD")
			oAttrib:lSet("RETORNA", "F")
			oAttrib:lSet("TAG000", "NOME")
			oAttrib:lSet("CAB000", "SCORECARD")
			oAttrib:lSet("CLA000", KPI_STRING)
			oNode := oXmlNode:oAddChild(TBIXMLNode():New("SCORECARDS", "", oAttrib))
	
			oNode := oNode:oAddChild(TBIXMLNode():New("SCORECARD", "", oAttrib))
			oNode:oAddChild(TBIXMLNode():New("ID", oTable:cValue("ID")))
			oNode:oAddChild(TBIXMLNode():New("NOME", alltrim(oTable:cValue("NOME"))))
		else
			oXMLNode:oAddChild(::oOwner():oGetTable("SCORECARD"):oToXMLList(.T.))//Scorecard
		endif
	endif
	
	oUser := oKpiCore:foSecurity:oLoggedUser()	    
	oXMLNode:oAddChild(TBIXMLNode():New("ISADMIN", oUser:lValue("ADMIN") ))

	if ( cCombo == "GRUPOACOES")
		oXMLNode:oAddChild(::oOwner():oGetTable("GRUPO_ACAO"):oToXMLList(cStatus))//Grupo de Assuntos
	endif
	
	// Acrescenta se o usuário corrente é criador do projeto / ou o responsável / ou está em modo de inserção (id=0)
	if( (alltrim(aFields[1][2]) == "0") .or. ( oUser:lValue("ADMIN") ) .or. ( alltrim(::cValue("ID_OWNER")) == alltrim(oUser:cValue("ID")) ) )
		oXMLNode:oAddChild(TBIXMLNode():New("PERMISSAO", "1")) //1 - TOTAL
	else    
		if ::cValue("TP_RESP") == TIPO_GRUPO
			lResp := oUsrGrp:lUserInGrp( oUser:cValue("ID"), ::cValue("ID_RESP") )
		else
			lResp := ( oUser:cValue("ID") == ::cValue("ID_RESP") )
		endif

		if lResp
			oXMLNode:oAddChild(TBIXMLNode():New("PERMISSAO", "2")) //2 - PARCIAL
		else
			oXMLNode:oAddChild(TBIXMLNode():New("PERMISSAO", "3")) //3 - NENHUMA
		endif
	endif

	oXMLNode:oAddChild(oUsrGrp:oTreeUsrGrp())		
	oXMLNode:oAddChild(oUsrGrp:oUsuGroup())

	oXMLNode:oAddChild(TBIXMLNode():New("TP_RESP_ID_RESP",	cTpResp + ::cValue("ID_RESP")))                 
	
	//Indica se o usuario logado e responsavel
	oXMLNode:oAddChild(TBIXMLNode():New("ISRESP", ::lUsuResp(::oOwner():foSecurity:oLoggedUser():cValue("ID"),TIPO_USUARIO)))
	//Parametro - CTR_APROV_PLANACAO - Habilitar controle de aprovacao do plano de acao
	oXMLNode:oAddChild(TBIXMLNode():New("CTR_APROV_PLANACAO", oParametro:getValue("CTR_APROV_PLANACAO") == "T"))
	//Status do Plano de Acao (GrupoAcao)              
	oGrupo:savePos()                                   

	if oGrupo:lSeek(1,{::cValue("ID_ASSUNTO")})
		oXMLNode:oAddChild(TBIXMLNode():New("GRUPOACAO_STATUS", oGrupo:cValue("STATUS")))
		oXMLNode:oAddChild(TBIXMLNode():New("GRUPOACAO_ISRESP", oGrupo:lUsuResp(::oOwner():foSecurity:oLoggedUser():cValue("ID"),TIPO_USUARIO)))
	else
		oXMLNode:oAddChild(TBIXMLNode():New("GRUPOACAO_STATUS", ""))
		oXMLNode:oAddChild(TBIXMLNode():New("GRUPOACAO_ISRESP", .F.))
	endif
	oGrupo:restPos()

	oXMLNode:oAddChild(::oXMLStatus())
	oXMLNode:oAddChild(TBIXMLNode():New("ALTERAFIM", if(lAlteraFim,"T","F")))  
	
	//Documentos
	oXMLNode:oAddChild(oPlanDoc:oToXMLList(::cValue("ID")))
	
return oXMLNode

	
// Insere nova entidade
method nInsFromXML(oXML, cPath) class TKPI016
	local oScorXUser	:= ::oOwner():oGetTable("SCOR_X_USER")
	local oUser 		:= ::oOwner():foSecurity:oLoggedUser()	
	local oTabPlanDoc	:= ::oOwner():oGetTable("PLANODOC")
	local oParametro 	:= ::oOwner():oGetTable("PARAMETRO")     
	local oGrupoAcao	:= ::oOwner():oGetTable("GRUPO_ACAO")
	local nStatus 		:= KPI_ST_OK
	local aRegNode		:= {}
	local nQtdReg		:= 0
	local aFields, nInd, aIndTend	
	local cLog
	local oScorecard
	local oIndicador          
	local cIdAssunto	:= ""    
	local cIdResp       := "" 
	local cIdGrupo      := ""
	local lTipoGrupo    := .F.

	private oXMLInput := oXML	
	
	aFields := ::xRecord(RF_ARRAY, {"ID","ID_OWNER"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))

		if aFields[nInd][1] == "ID_ASSUNTO"
			cIdAssunto := aFields[nInd][2]
		endif 
		
		if ( ( aFields[nInd][1] == "TP_RESP" )  .and. aFields[nInd][2]== TIPO_GRUPO)
			lTipoGrupo := .T.
		else
			lTipoGrupo:= .F.      
		endif
		  
		if ( aFields[nInd][1] == "ID_RESP")
		    cIdResp:= aFields[nInd][2]
		endif
	next  

	aAdd(aFields, {"ID", 		::cMakeID()})  
	aAdd(aFields, {"ID_OWNER", oUser:cValue("ID")})
	     
	oGrupoAcao:savePos()
	if oParametro:getValue("CTR_APROV_PLANACAO") == "T" .and. !(alltrim(cIdAssunto)=="0") .and. oGrupoAcao:lSeek(1,{cIdAssunto})
		if oGrupoAcao:cValue("STATUS") != GRUPOACAO_NAO_INICIADO
			nStatus := KPI_ST_VALIDATION    
			::fcMsg := STR0047
		endif
	endif
	oGrupoAcao:restPos()
	
	if nStatus == KPI_ST_OK
		// Grava
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		else
			cLog := STR0039 // "Incluido o plano de ação"
			cLog += ": " + alltrim( ::cValue( "NOME" ) )

			oScorecard := ::oOwner():oGetTable("SCORECARD")

			if oScoreCard:lSeek(1, { ::cValue("ID_SCOREC") } )
				cLog += "<br>"
				cLog += "Scorecard"
				cLog += ": " + alltrim( oScoreCard:cValue("NOME") )
			endif 

			oIndicador := ::oOwner():oGetTable("INDICADOR")

			if oIndicador:lSeek(1, {::cValue("ID_IND")})
				cLog += "<br>"
				cLog += STR0019  // Indicador
				cLog += ": " + oIndicador:cValue("NOME")
			endif 

			oKpiCore:LogUser( cLog )
		endif
	endif              

    //Gravacao da planilha de documentos
	if(nStatus == KPI_ST_OK .and. valtype(XmlChildEx(&("oXMLInput:"+cPath+":_PLANODOCS"), "_PLANODOC"))!="U")
		aRegNode := &("oXMLInput:"+cPath+":_"+"PLANODOCS")//Pegando os valores 

		if(valtype(aRegNode:_PLANODOC)=="A")
			for nQtdReg := 1 to len(aRegNode:_PLANODOC)
				nStatus	:= oTabPlanDoc:nInsFromXML(aRegNode:_PLANODOC[nQtdReg],::cValue("ID"))
				if(nStatus != KPI_ST_OK)
					::fcMsg := oTabPlanDoc:fcMsg
					exit
				endif			
			next nQtdReg
		elseif(valtype(aRegNode:_PLANODOC)=="O")
			nStatus	:= oTabPlanDoc:nInsFromXML(aRegNode:_PLANODOC,::cValue("ID"))
			::fcMsg := oTabPlanDoc:fcMsg
		endif
	endif
	 
	//Envia e-mail para o responsavel
	If ( nStatus == KPI_ST_OK .And. ( oParametro:getValue("WFINSERTACTION") == "T" ) )
		::lSendMailOwner(cIdResp,lTipoGrupo)    
	EndIf
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPI016
	local oScorXUser	:= ::oOwner():oGetTable("SCOR_X_USER")
	local oConexao 		:= ::oOwner():oGetTable("SMTPCONF")
	local oPessoas		:= ::oOwner():oGetTable("USUARIO")       
	local oParametro 	:= ::oOwner():oGetTable("PARAMETRO")     
	local oGrupoAcao	:= ::oOwner():oGetTable("GRUPO_ACAO")
	local oScorecard
	local oProjeto		:= ::oOwner():oGetTable("PROJETO")
	local oIndicador	:= ::oOwner():oGetTable("INDICADOR")
	local oUser			:= ::oOwner():foSecurity:oLoggedUser() 
	local oPlanDoc		:= ::oOwner():oGetTable("PLANODOC")
	local nFrequencia, nStatus := KPI_ST_OK, cID, nInd, lAscendente
	local oMeta, nAzul1, nVerde, nAmarelo, nVermelho, lFCumula, aIndTend
	local cServer, cPorta, cConta, cAutUsuario, cAutSenha, lEnviarEmail := .f.
	local cTo:="", cAssunto, cCorpo, cAnexos:="", cFrom, cCopia, dDataFimAntes , dDataFimDepois
	local aTo := {}, cRespDep := "", cRespProj := "", cUsuLogado := "", cNomePlano := "", i, cTipoAcao
	local cNomeProjeto := "", cNomeIndicador := ""   
	local nQtdReg, aRegNode
	local cLog
	Local lReinicia     := .F.
	Local cLogAcao		:= ""
	local cIdAssunto	:= ""  
	Local cProtocol	:= "0" // Por padrão não é utilizado nenhum protocolo. 
	
	private oXMLInput 	:= oXML
	
	aFields := ::xRecord(RF_ARRAY)
 	
    // Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		endif	
		
		//Define a mensagem de Log caso a acao seja marcada como Cancelada, Executada, ou Reiniciada
		if (aFields[nInd][1] == "STATUS") .and. (alltrim(aFields[nInd][2]) == '3')   	//EXECUTADA
			cLogAcao := STR0042
		elseif (aFields[nInd][1] == "STATUS") .and. (alltrim(aFields[nInd][2]) == '6') //CANCELADA
			cLogAcao := STR0043
		elseif aFields[nInd][1] == "ID_ASSUNTO"
			cIdAssunto := aFields[nInd][2]
		Endif
	Next nInd
	
	//Verifica se eh reinicio de acao
	if ValType(oXMLInput) == "O" .and. alltrim(oXMLInput:_REGISTROS:_PLANOACAO:_REINICIA:TEXT) == "T"
		cLogAcao := STR0044
	endif

	//Grava o Log
	if !Empty(cLogAcao)
		For nInd := 1 to len(aFields)
			if aFields[nInd][1] == "LOGACAO"
				aFields[nInd][2] := aFields[nInd][2] + chr(13)+chr(10)+DTOC(Date())+ "  " + Time() + "  " +  alltrim(oUser:cValue("NOME")) + "  " + cLogAcao
			endif
		next
	endif

	// Verifica condições de gravação (append ou update)
	if(!::lSeek(1, {cID}))
		nStatus := KPI_ST_BADID
	else
		dDataFimAntes := ::dValue("DATAFIM")
		
		if oParametro:getValue("CTR_APROV_PLANACAO") == "T" .and. !(alltrim(cIdAssunto) == alltrim(::cValue("ID_ASSUNTO")))
			oGrupoAcao:savePos()
			if !(alltrim(cIdAssunto)=="0") .and. oGrupoAcao:lSeek(1,{cIdAssunto})
				if oGrupoAcao:cValue("STATUS") != GRUPOACAO_NAO_INICIADO
					nStatus := KPI_ST_VALIDATION    
					::fcMsg := STR0047
				endif
			endif
			oGrupoAcao:restPos()
		endif    
		   
		if ( (!alltrim(cIdAssunto)=="0") .and. oGrupoAcao:lSeek(1,{cIdAssunto}) .and. oParametro:getValue("CTR_APROV_PLANACAO") == "T")
	    	if (aFields[15][2]=='1' .AND. oGrupoAcao:cValue("STATUS")=='3' .and. nStatus == KPI_ST_OK)
				nStatus := KPI_ST_VALIDATION    
				::fcMsg := STR0052 //"O status da Ação não pode ser alterado para 'Não Iniciada' pois o seu Plano de Ação já foi aprovado."
			endif 
	  	ENDIF
		
		
	 	if nStatus == KPI_ST_OK
			if(!::lUpdate(aFields))
				if(::nLastError()==DBERROR_UNIQUE)
					nStatus := KPI_ST_UNIQUE
				else
					nStatus := KPI_ST_INUSE
				endif
			else
				cLog := STR0040 // "Alterado o plano de ação"
				cLog += ": " + alltrim( ::cValue( "NOME" ) )
		
				oScorecard := ::oOwner():oGetTable("SCORECARD")
		
				if oScoreCard:lSeek(1, { ::cValue("ID_SCOREC") } )
					cLog += "<br>"
					cLog += "Scorecard"
					cLog += ": " + alltrim( oScoreCard:cValue("NOME") )
				endif 
		
				if oIndicador:lSeek(1, {::cValue("ID_IND")})
					cLog += "<br>"
					cLog += STR0019 // "Indicador"
					cLog += ": " + oIndicador:cValue("NOME")
				endif 
		
				oKpiCore:LogUser( cLog )
			
				//Atualizando os valores da planilha
				if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_PLANODOCS"), "_PLANODOC"))!="U")
					aRegNode := &("oXMLInput:"+cPath+":_PLANODOCS")//Pegando os valores da planilhas
					if(valtype(aRegNode:_PLANODOC)=="A")
						for nQtdReg := 1 to len(aRegNode:_PLANODOC)
							nStatus	:= oPlanDoc:nUpdFromXML(aRegNode:_PLANODOC[nQtdReg],::cValue("ID"))
							if(nStatus != KPI_ST_OK)
								::fcMsg := oPlanDoc:fcMsg
								exit
							endif			
						next nQtdReg
					elseif(valtype(aRegNode:_PLANODOC)=="O")
						nStatus	:= oPlanDoc:nUpdFromXML(aRegNode:_PLANODOC,::cValue("ID"))
						if(nStatus != KPI_ST_OK)
							::fcMsg := oPlanDoc:fcMsg
					 	endif							
					endif
				endif
				
				//Gravando os registros marcado para exclusao
				if(nStatus == KPI_ST_OK)
					if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_PLANODOCS"), "_REG_EXCLUIDO"))!="U")
						aRegNode := &("oXMLInput:"+cPath+":_PLANODOCS:_REG_EXCLUIDO")//Pegando os valores da planilhas
		
						if(valtype(aRegNode:_EXCLUIDOS:_PLANODOC)=="A")		
							aRegNode := aRegNode:_EXCLUIDOS:_PLANODOC
							for nQtdReg := 1 to len(aRegNode)
								nStatus	:= oPlanDoc:nDelFromXML(aRegNode[nQtdReg])
								if(nStatus != KPI_ST_OK)
									exit
								endif			
							next nQtdReg
						else
							nStatus	:= oPlanDoc:nDelFromXML(aRegNode:_EXCLUIDOS:_PLANODOC)
						endif
					endif				
		 		endif
			endif	 
		endif
	endif

	dDataFimDepois	:= ::dValue("DATAFIM")
	cNomePlano		:= alltrim(::cValue("NOME"))
	cUsuLogado		:= alltrim(oUser:cValue("NOME"))
	cTipoAcao		:= alltrim(::cValue("TIPOACAO"))//1=por Indicador 2=por Projeto

	if(nStatus==KPI_ST_OK)
		lEnviarEmail := if(xBIConvTo("L",oXMLInput:_REGISTROS:_PLANOACAO:_EMAIL:TEXT),.t.,.f.)
	endif

	if(lEnviarEmail .and. nStatus==KPI_ST_OK)
		//posiciona na configuração de email
		oConexao:cSQLFilter("ID = '"+cBIStr(1)+"'") // Filtra o ID 1 onde tem a configuracao SMTP
		oConexao:lFiltered(.t.)
		oConexao:_First()
		if(!::lEof() .and. !oConexao:lEof()) //posiciona cfg. da organização
			cServer		:= alltrim(oConexao:cValue("SERVIDOR"))
			cPorta			:= alltrim(oConexao:cValue("PORTA"))
			cConta			:= alltrim(oConexao:cValue("NOME"))
			cAutUsuario	:= alltrim(oConexao:cValue("USUARIO"))
			cAutSenha		:= alltrim(oConexao:cValue("SENHA"))
			cFrom			:= alltrim(oConexao:cValue("NOME"))
			cProtocol		:= AllTrim(cBIStr(oConexao:nValue("PROTOCOLO")))
            
			if(cTipoAcao == "1")
				if(oIndicador:lSeek(1, {::cValue("ID_IND")}))
					cNomeIndicador := alltrim(oIndicador:cValue("NOME"))
				endif

				oScorecard := ::oOwner():oGetTable("SCORECARD")
				if(oScorecard:lSeek(1, {::cValue("ID_SCOREC")}))
					cRespId		:= oScorecard:cValue("RESPID")
					aAdd(aTo, cRespId)
					if(oPessoas:lSeek(1, { cRespId }))
						cRespDep := alltrim(oPessoas:cValue("NOME"))
						cCorpo 	:= ::cCriaMensagem(cRespDep, cUsuLogado, cNomePlano, dDataFimAntes, dDataFimDepois, cTipoAcao, cNomeIndicador)
					endif
				endif
			else
				if(oProjeto:lSeek(1, { ::cValue("ID_PROJ") }))
					cRespId		:= oProjeto:cValue("OWNER")
					cNomeProjeto:= alltrim(oProjeto:cValue("NOME"))
					aAdd(aTo, cRespId)
					if(oPessoas:lSeek(1, { cRespId }))
						cRespProj	:= alltrim(oPessoas:cValue("NOME"))
						cCorpo 		:= ::cCriaMensagem(cRespProj, cUsuLogado, cNomePlano, dDataFimAntes, dDataFimDepois, cTipoAcao, cNomeProjeto)
					endif
				endif
			endif
			// inclusao do email dos Destinatarios
			cTo := ""
			for i := 1 to len(aTo)
				if(oPessoas:lSeek(1, {aTo[i]}))
					cTo	+= if(empty(cTo),"",",")+alltrim(oPessoas:cValue("EMAIL"))
				endif
			next

			cCopia	:= ""
			cAssunto:= STR0022
			cAnexos	:= ""

			oConexao:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo, cAssunto, cCorpo, cAnexos, cFrom, cCopia, /*cOculto*/"", cProtocol)
		endif
		oConexao:cSQLFilter("") // Retira filtro
	endif
	
return nStatus

// Excluir entidade do server
method nDelFromXML(cID) class TKPI016
	local nStatus 	:= KPI_ST_OK
	local oKpiCore	:= ::oOwner()
	local cLog
	local oScorecard
	local oIndicador
	
	// Deleta o elemento
	if(::lSeek(1, {cID}))
		if(!::lDelete())
			nStatus := KPI_ST_INUSE
		endif
	else
		nStatus := KPI_ST_BADID
	endif	

	if(nStatus == KPI_ST_OK)
		cLog := STR0041 // "Excluido o plano de ação"
		cLog += ": " + alltrim( ::cValue( "NOME" ) )

		oScorecard := ::oOwner():oGetTable("SCORECARD")

		if oScoreCard:lSeek(1, { ::cValue("ID_SCOREC") } )
			cLog += "<br>"
			cLog += "Scorecard"
			cLog += ": " + alltrim( oScoreCard:cValue("NOME") )
		endif 

		oIndicador := ::oOwner():oGetTable("INDICADOR")

		if oIndicador:lSeek(1, {::cValue("ID_IND")})
			cLog += "<br>"
			cLog += STR0019 // "Indicador"
			cLog += ": " + oIndicador:cValue("NOME")
		endif 

		oKpiCore:LogUser( cLog )
	endif

return nStatus

// Unidade
method oXMLStatus() class TKPI016
	local oAttrib, oNode, oXMLOutput
	local nInd, aStatus := { STR0003, STR0004, STR0005, STR0006, STR0007, STR0008 } //"Näo Iniciada"#"Em Execucäo"#"Realizada"#"Esperando"#"Adiada"#"Cancelada"
	
	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("LSTSTATUS",,oAttrib)

	for nInd := 1 to len(aStatus)
		oNode := oXMLOutput:oAddChild(TBIXMLNode():New("LSTSTATUS"))
		oNode:oAddChild(TBIXMLNode():New("ID", nInd))
		oNode:oAddChild(TBIXMLNode():New("NOME", aStatus[nInd]))
	next
return oXMLOutput

//lista Pendencias para Lembrete
method oToXmlPendencia() class TKPI016
	local oSysParameters	:= ::oOwner():oGetTable("PARAMETRO")
	local cIdUsuario		:= ::oOwner():foSecurity:oLoggedUser():cValue("ID")
	local oUsrGrp			:= ::oOwner():oGetTool("USERGROUP")   
	local oXMLNodeLista		:= nil
	local oAttrib			:= nil
	local oXMLNode			:= nil
	local nInd				:= 0 
	local nAux				:= 0
	local nDias 			:= val(oSysParameters:getValue("NUM_DIA_PRO_FIN")) //Numero de dias para exibir ações finalizadas ou canceladas
	local nVencDias			:= val(oSysParameters:getValue("PRAZO_PARA_VENC")) //Numero de dias para exibir ações a vencer
	local lResp				:= .T.
	local cFiltro			:= "" 
	local aFiltro			:= {}
	local aEntity			:= {}

	oXMLNodeLista := TBIXMLNode():New("LISTA")

	oXMLNodeLista:oAddChild(TBIXMLNode():New("PRAZO_PARA_VENC",nVencDias) )  

	//Colunas
	oAttrib := TBIXMLAttrib():New()
	//Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Tipo de plano de acao 1=por Indicador 2=por Projeto
	oAttrib:lSet("TAG000", "IMG_OWNER")
	oAttrib:lSet("CAB000", "")
	oAttrib:lSet("CLA000", KPI_IMAGEM)

	//Nome
	oAttrib:lSet("TAG001", "NOME")
	oAttrib:lSet("CAB001", "")
	oAttrib:lSet("CLA001", KPI_STRING)
	//Data Final
	oAttrib:lSet("TAG002", "DATAFIM")
	oAttrib:lSet("CAB002", "") //"Data Fim" )
	oAttrib:lSet("CLA002", KPI_DATE)

	//Gera o principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)

	::SetOrder(2)

	cFiltro :=	" STATUS !=	'6' AND STATUS != '3'"
	cFiltro +=	" AND DATAFIM < '"+ dTos(date()) + "'"
	cFiltro	+=	" AND ((DATATERM >= '"	+ dtos(date() - nDias) + "'"
	cFiltro	+=	" AND DATATERM <= '" + dtos(date()) + "')"
	cFiltro	+=	" OR DATATERM = ' ')" //Ações em aberto

	aAdd(aFiltro, cFiltro)

	cFiltro := " STATUS != '6' AND STATUS != '3'"
	cFiltro += " AND DATAFIM < '"+ dTos(date() + nVencDias) + "'"			
	cFiltro += " AND DATAFIM >= '"+ dTos(date()) + "'"
	cFiltro	+= " AND ((DATATERM >= '"	+ dtos(date() - nDias) + "'"
	cFiltro	+= " AND DATATERM <= '" + dtos(date()) + "')"
	cFiltro	+= " OR DATATERM = ' ')" //Ações em aberto

	aAdd(aFiltro, cFiltro)

	aEntity := {TAG_ENTITY, "ACOESFUTURAS"}

	for nAux := 1 to len(aEntity)
		::cSQLFilter("")
		::cSQLFilter(aFiltro[nAux])
		::lFiltered(.t.)
		::_First()             
	
		//Gera o no de detalhes
		while !::lEof()
			if !(alltrim(::cValue("ID")) == "0") .and. ::lUsuResp(cIdUsuario, TIPO_USUARIO)
				oNode := oXMLNode:oAddChild(TBIXMLNode():New(aEntity[nAux]))

				aFields := ::xRecord(RF_ARRAY, {"DESCRICAO","DATAINICIO","DATATERM","STATUS",;
						"PERCREAL", "VLRINVEST", "ID_IND", "OBJETIVO", "COMO", "INVESTIM",;
						"CAUSA", "RESULTADO", "OBSERVACAO"})

				// TipoAcao 1=por Indicador 2=por Projeto
				for nInd := 1 to len(aFields)
					if(aFields[nInd][1]=="TIPOACAO")
						if(aFields[nInd][2]=="2")
							oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], KPI_IMG_PROJETO))
						else
							oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], KPI_IMG_INDICADOR))
						endif
					else
						oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
					endif
				next
				
				//Adicionando imagem do Onwer	 
				if ::cValue("TP_RESP") == TIPO_GRUPO
					lResp := oUsrGrp:lUserInGrp( cIdUsuario, ::cValue("ID_RESP") )
				else
					lResp := ( cIdUsuario == ::cValue("ID_RESP") )
				endif
	
				if lResp
					oNode:oAddChild(TBIXMLNode():New("IMG_OWNER", KPI_IMG_PLANO_RESP))
				elseif alltrim(cIdUsuario) == alltrim(::cValue("ID_OWNER"))
					oNode:oAddChild(TBIXMLNode():New("IMG_OWNER", KPI_IMG_PLANO_OWNER))
				else
					oNode:oAddChild(TBIXMLNode():New("IMG_OWNER", KPI_IMG_PLANO_LOCK))
				endif
			endif  
			
			::_Next()		
		enddo
	next

	oXMLNodeLista:oAddChild(oXMLNode)  
	::cSQLFilter("")       

return oXMLNodeLista


/*
	Filtra o plano de acao e acao pelo usuario responsavel 
	de acordo com o parametro "FILTER_ACAO_PLANACAO"
*/
method lAddToList() class TKPI016
	local lRet			:= .T.
	local oParam		:= ::oOwner():oGetTable("PARAMETRO")
	local cIdUsuario	:= ::oOwner():foSecurity:oLoggedUser():cValue("ID")
	local isAdmin		:= ::oOwner():foSecurity:oLoggedUser():lValue("ADMIN")

	if (!isAdmin .and. oParam:getValue("FILTER_ACAO_PLANACAO") == "T")
		lRet := ::lUsuResp(cIdUsuario, TIPO_USUARIO)// verifica se usuario logado é responsavel pelo plano de acao

		if !lRet
			lRet := ::lRespGrupo(cIdUsuario, TIPO_USUARIO)		
		endif
	endif

return lRet

/*
*Verifica se o usuario/grupo tem responsabilidade sobre a ação
*/
method lUsuResp(cUserId, cUserTp) class TKPI016
	local lAccess	:= .F.
	local cUserId	:= padr( cUserId, 10 )
	local oUsrGrp	:= ::oOwner():oGetTool("USERGROUP")   
	
	default cUserTp := TIPO_USUARIO

	if cUserTp == TIPO_GRUPO
		lAccess := oUsrGrp:lUserInGrp( ::cValue("ID_OWNER"), cUserId )
	
		if !lAccess
			if ::cValue("TP_RESP") == TIPO_GRUPO
				lAccess := ( cUserId == ::cValue("ID_RESP") )
			else
				lAccess := oUsrGrp:lUserInGrp( ::cValue("ID_RESP"), cUserId )
			endif
		endif
	else
		lAccess := ( ::cValue("ID_OWNER") == cUserId )
	
		if !lAccess
			if ::cValue("TP_RESP") == TIPO_GRUPO
				lAccess := oUsrGrp:lUserInGrp( cUserId, ::cValue("ID_RESP") )
			else
				lAccess := ( cUserId == ::cValue("ID_RESP") )
			endif
		endif
	endif

return lAccess

/*
	Verifica se o usuario e responsavel por alguma acao do plano de acao.
*/
method lRespGrupo(cUserId, cUserTp) class TKPI016
	local oGrupo	:= ::oOwner():oGetTable("GRUPO_ACAO")
	local lRet		:= .F.
	local aArea		:= oGrupo:SavePos()
	
	if oGrupo:lSeek(1,{::cValue("ID_ASSUNTO")})
		lRet := oGrupo:lUsuResp(cUserId, cUserTp)
	endif
    
	oGrupo:restPos(aArea)    
	
return lRet

/*
*Retorna a Descrição do status
*/
method cGetStatusDescricao(cStatus) class TKPI016
	local cDescricao := ""

	do case
		case cStatus == "1"
			cDescricao	:= STR0015 //"Não iniciada"
		case cStatus == "2"
			cDescricao	:= STR0016 //"Em execução"
		case cStatus == "3"
			cDescricao	:= STR0005 //"Executada"
		case cStatus == "4"
			cDescricao	:= STR0006 //"Esperando"
		case cStatus == "5"
			cDescricao	:= STR0007 //"Adiada"
		case cStatus == "6"
			cDescricao	:= STR0008 //"Cancelada"
	endcase		

return cDescricao                                


/*
*Retorna a cor do status  
* Status Não Iniciada : Cor Branca
* Qualquer status ( com exceção de Cancelada e Executada ), se atrasado, colocar em vermelho.
*/
method nGetColorStatus(cStatus,dDataFim) class TKPI016
	local AMARELA  := 1
	local BRANCA   := 2
	local CINZA    := 3
	local VERMELHA := 4
	local VERDE    := 5
	local nRet	   := 0
     
    if cStatus == "3" //Executada
    	nRet := VERDE
    elseif cStatus == "6" //Cancelada  
    	nRet := CINZA
    else	
		if  dDataFim >= MsDate()
			do case
			case cStatus = "1" //Não iniciada
				nRet := BRANCA 	             
			case cStatus = "2" //Em execução
				nRet := AMARELA 	
			case cStatus = "4" //Esperando
				nRet := BRANCA 	             
			case cStatus = "5" //Adiada
				nRet := CINZA 	
			endcase
		else
			nRet := VERMELHA
		endif
	endif

return nRet

/*                            
*Retorna a cor do staus do plano de acao com o nome do class css(html)
*/
method cGetClassStatus(cStatus,dDataFim) class TKPI016 
	local nCor	   :=  ::nGetColorStatus(cStatus,dDataFim)
	local AMARELA  := "cabecalho_amarelo"
	local BRANCA   := "cabecalho_branco"
	local CINZA    := "cabecalho_cinza"
	local VERMELHA := "cabecalho_verm"
	local VERDE    := "cabecalho_verde"
	local cRet	   := ""
	
	do case
		case nCor = 1 
			cRet := AMARELA 	             
		case nCor = 2 
			cRet := BRANCA 	
		case nCor = 3 
			cRet := CINZA 	             
		case nCor = 4 
			cRet := VERMELHA 	
		case nCor = 5 
			cRet := VERDE 				
	endcase
	
return cRet



method cCriaMensagem(cRespNome, cUsuLogado, cNomePlano, dDataFimAntes, dDataFimDepois, cTipo, cNomeTipo) class TKPI016
	local cMensagem := ""
	
	cMensagem += cRespNome + ", "
	cMensagem += "<br><br>"
	if(cTipo == "1")
		cMensagem += STR0023 + cNomePlano + STR0024 + cNomeTipo + STR0026 +  dToc(dDataFimAntes) + STR0027 + dToc(dDataFimDepois)
	else
		cMensagem += STR0023 + cNomePlano + STR0025 + cNomeTipo + STR0026 +  dToc(dDataFimAntes) + STR0027 + dToc(dDataFimDepois)
	endif
	cMensagem += STR0028 + cUsuLogado + STR0029
return cMensagem


method lSendMailOwner(cToUserId,lTipoGrupo) class TKPI016
	Local oPessoas			:= ::oOwner():oGetTable("USUARIO")
	Local oConexao 			:= ::oOwner():oGetTable("SMTPCONF")  
	Local oIndicador    		:= ::oOwner():oGetTable("INDICADOR")      
   	Local oGrupo				:= ::oOwner():oGetTable("GRUPO_ACAO")
 	Local oGrupoUsu	    	:= ::oOwner():oGetTable("GRPUSUARIO") 
 	Local oParametro   		:= ::oOwner():oGetTable("PARAMETRO")
	Local cPathSite			:= left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER)) + "sgiindex.apw"
	Local cAssunto			:= STR0032 //"Ação criada para você"
	Local cServer				:= ""
	Local cPorta				:= "" 
	Local cConta				:= ""
	Local cAutUsuario			:= ""
	Local cAutSenha			:= ""
	Local cFrom				:= ""  
	Local cTo					:= ""    
	Local cCriador			:= ""   
	Local cCorpo				:= ""  
	Local cIndicador    		:= ""
	Local cPlanoAcao    		:= ""
	Local cPathImg      		:= ::oOwner():cKpiPath()+"imagens\" 
	Local cUsuarioSemEmail 	:= ""  
	Local lRet 				:= .f. 
	Local aUsuarios     		:= {""} 
	Local nTotalUsuarios		:= 0
	Local nTotalEmails  		:= 0
	Local nContador     		:= 0
	Local cProtocol			:= "0" // Por padrão não é utilizado nenhum protocolo.
    
    If( lTipoGrupo )      
	    aUsuarios:= oGrupoUsu:aUsersByGroup(cToUserId)  
	    nTotalUsuarios:= Len( aUsuarios )   
	    For nContador:=1 to nTotalUsuarios
	    	If( oPessoas:lSeek(1, { aUsuarios[nContador] }))  
	     		If( !Empty( oPessoas:cValue("EMAIL") ) )	            
   	    			cTo += alltrim(oPessoas:cValue("EMAIL")) + ","   
   	      			nTotalEmails++ 
   	      		Else
   	      		 	cUsuarioSemEmail += oPessoas:cValue("COMPNOME") + "<br>"
   	      		EndIf           
	     	EndIf 	                                          
      	Next
	Else
		nTotalUsuarios := 1
		if(oPessoas:lSeek(1, { cToUserId }))
			cTo := alltrim(oPessoas:cValue("EMAIL"))
			//Verifica se há email cadastrado para o usuário. 
			If ( ! Empty( cTo ) )
				nTotalEmails++  
			EndIf
		endif   
	EndIf	
	
	If (oPessoas:lSeek(1, { ::cValue("ID_OWNER") }))
		cCriador := Alltrim(oPessoas:cValue("COMPNOME"))+" ("+Alltrim(oPessoas:cValue("NOME"))+")"
	EndIf   
	
	If (oIndicador:lSeek(1, {alltrim(::cValue("ID_IND"))}))
		cIndicador := alltrim(oIndicador:cValue("NOME"))
	endif 
	                                    
	If oGrupo:lSeek(1,{::cValue("ID_ASSUNTO")})
		cPlanoAcao := alltrim(oGrupo:cValue("NOME")) 
	endif  
	
	cCorpo := "<!--"                                     	+ CRLF	
	cCorpo += STR0033 + cPlanoAcao                          + CRLF	//"SGI - Plano de Ação" 
	cCorpo += CRLF 		                                    + CRLF	
	cCorpo += STR0034 	  + alltrim(::cValue("NOME")) 		+ CRLF //"Nome da Ação: " 
	cCorpo += STR0019+":" + cIndicador     					+ CRLF //"Indicador: " 
	cCorpo += STR0035 	+ alltrim(::cValue("CAUSA"))		+ CRLF //"Causa:"
	cCorpo += STR0048 	  + alltrim(::cValue("DATAINICIO"))	+ CRLF //"Data Inicio:"
	cCorpo += STR0036 	+ alltrim(::cValue("DATAFIM"))		+ CRLF //"Data Fim:"
	cCorpo += STR0049 	  + alltrim(cCriador) 				+ CRLF //"Autor:"
	cCorpo += CRLF 		+ CRLF 								+ CRLF
	cCorpo += STR0038 										+ CRLF //"Para mais informações acesse:"
	cCorpo += cPathSite + CRLF  		
	cCorpo += "-->" + CRLF
	
	cCorpo += "<table width='100%' border='0' cellpadding='0' cellspacing='0'>"
	cCorpo += "<tr>"
	cCorpo += "<td width='10%'><img src='art_logo_clie.sgi'></td>"
	cCorpo += "<td width='40%' style='color: #406496; font-weight: bold; font-size: 18px; font-family: Verdana, Arial, Helvetica, sans-serif;'><div align='center'>" + "E-Mail de Notificação" + "<br></br></div></td>" //E-Mail de Notificacao
	cCorpo += "<td width='10%'></td>"
	cCorpo += "</tr>"
	cCorpo += "</table>"
	
	cCorpo += "<table width='100%' cellpadding='0' cellspacing='0'>"
	cCorpo += "<font face='Calibri, Verdana, Ariel, sans-serif' size='5'>
	
	cCorpo += "<hr colspan='3' width='100%' size='3' noshade style='color: #000000;'/>"
	
	cCorpo += "<tr>"
	cCorpo += "<td colspan='4' align='left'></td>"
	cCorpo += "</tr>" 
	cCorpo += "<br>"
	
	cCorpo += "<tr>"
	cCorpo += "<td width='05%' height='30'></td>"
	cCorpo += "<td width='25%' height='30'></br><strong>"+STR0033 + ": "+"</strong></td>" //SGI - Plano de Acao: <Plano de ação>
	cCorpo += "<td width='60%' height='30'></br>"+cPlanoAcao+"</td>"
	cCorpo += "</tr>"  
	     
	cCorpo += "</font>" 	
	cCorpo += "</table>" 	
	
	cCorpo += "<br>"
	cCorpo += "<br>"  
	
	cCorpo += "<table width='100%' cellpadding='0' cellspacing='0'>"
	cCorpo += "<font face='Calibri, Verdana, Ariel, sans-serif'>
	
	cCorpo += "<tr>"
	cCorpo += "<td width='05%' height='30'></td>"
	cCorpo += "<td width='15%' height='30'><strong>"+KPIEncode(STR0034)+"</strong></td>" //Nome da Ação: 
	cCorpo += "<td width='80%' height='30'>" + alltrim(::cValue("NOME")) + "</td>"
	cCorpo += "</tr>"
	
	cCorpo += "<tr>"
	cCorpo += "<td width='05%' height='30'></td>"
	cCorpo += "<td width='15%' height='30'><strong>"+KPIEncode(STR0019)+":"+"</strong></td>" //Indicador:  
	cCorpo += "<td width='80%' height='30'>" + cIndicador + "</td>"
	cCorpo += "</tr>"
	
	cCorpo += "<tr>"
	cCorpo += "<td width='05%' height='30'></td>"
	cCorpo += "<td width='15%' height='30'><strong>"+KPIEncode(STR0035)+"</strong></td>" //Causa:
	cCorpo += "<td width='80%' height='30'>" + alltrim(::cValue("CAUSA")) + "</td>"
	cCorpo += "</tr>"
	
	cCorpo += "<tr>"
	cCorpo += "<td width='05%' height='30'></td>"
	cCorpo += "<td width='15%' height='30'><strong>"+KPIEncode(STR0048)+"</strong></td>" //Data Inicio:
	cCorpo += "<td width='80%' height='30'>" + alltrim(::cValue("DATAINICIO")) + "</td>"
	cCorpo += "</tr>"
	
	cCorpo += "<tr>"
	cCorpo += "<td width='05%' height='30'></td>"
	cCorpo += "<td width='15%' height='30'><strong>"+KPIEncode(STR0036)+"</strong></td>" //Data Fim:
	cCorpo += "<td width='80%' height='30'>" + alltrim(::cValue("DATAFIM")) + "</td>"
	cCorpo += "</tr>"
	
	cCorpo += "<tr>"
	cCorpo += "<td width='05%' height='30'></td>"
	cCorpo += "<td width='15%' height='30'><strong>"+KPIEncode(STR0049)+"</strong></td>" //Autor:
	cCorpo += "<td width='80%' height='30'>" + alltrim(cCriador) + "</td>"
	cCorpo += "</tr>"  
	
	cCorpo += "</font>"
	cCorpo += "</table>"  
	
	cCorpo += "<br>"
	cCorpo += "<br>"
	
	cCorpo += "<table width='100%' border='0' cellpadding='0' cellspacing='0'>"  
	cCorpo += "<font face='Calibri, Verdana, Ariel, sans-serif'> 
	
	cCorpo += "<tr>"
	cCorpo += "<td width='05%' height='30'></td>"
	cCorpo += "<td width='80%' height='30'><strong>"+KPIEncode(STR0038)+"</strong></td>" //Para mais informações acesse:
	cCorpo += "<td width='15%' height='30'></td>"
	cCorpo += "</tr>"
	 
	cCorpo += "<tr>"
	cCorpo += "<td width='05%' height='30'></td>"
	cCorpo += "<td width='80%' height='30'><strong><a href='" + cPathSite + "'>" + cPathSite + "</a></strong></td>" //Link
	cCorpo += "<td width='15%' height='30'></td>"
	cCorpo += "</tr>"     
	
	cCorpo += "</font>"	
	cCorpo += "</table>"   

	cAnexos := cPathImg+"art_logo_clie.sgi"
	
	oConexao:cSQLFilter("ID = '"+cBIStr(1)+"'") // Filtra o ID 1 onde tem a configuracao SMTP
	oConexao:lFiltered(.t.)
	oConexao:_First()    
	
	if(!::lEof() .and. !oConexao:lEof()) //posiciona cfg. da organização
		cServer		:= AllTrim(oConexao:cValue("SERVIDOR"))
		cPorta			:= AllTrim(oConexao:cValue("PORTA"))
		cConta			:= AllTrim(oConexao:cValue("NOME"))
		cAutUsuario	:= AllTrim(oConexao:cValue("USUARIO"))
		cAutSenha		:= AllTrim(oConexao:cValue("SENHA"))
		cFrom			:= AllTrim(oConexao:cValue("NOME"))
		cProtocol		:= AllTrim(cBIStr(oConexao:nValue("PROTOCOLO")))	                     

		oConexao:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo, cAssunto, cCorpo, cAnexos, cFrom, "",/*cOculto*/"", cProtocol)
		
		If( nTotalUsuarios > nTotalEmails )	
			//Alertar somente quando NENHUM responsável puder ser notificado por e-mail.
			If ( oParametro:getValue("NENHUM_MAIL_ALERTA") == "T" ) 
				If ( nTotalEmails == 0 )
				  	::fcMsg 		:= STR0050 //"Os responsáveis não serão notificado via e-mail devido a falta de cadastro de endereço de e-mail."
					
					::flCanAlert 	:= .T. 
				EndIf					
			Else 
				::fcMsg        	:= "<html><body>"
			  	::fcMsg 		+= STR0051 //"Os seguintes responsáveis não serão notificados via e-mail devido a falta de cadastro de endereço de e-mail:"
			  	::fcMsg 		+= "<br>" 
			  	::fcMsg 		+= "<br>"
			  	::fcMsg 		+= cUsuarioSemEmail  
			  	::fcMsg  		+= "</html></body>
			  		
			  	::flCanAlert 	:= .T.
			EndIf 
			 
			lRet := .F.                    
		Else
			lRet := .T. 
		EndIf 
	EndIf  
	oConexao:cSQLFilter("") // Retira filtro	
return lRet    

method lHasUserAccess(cUserId,cScoreID)  class TKPI016
	Local oScorecard 	:= ::oOwner():oGetTable("SCORECARD")
	Local oUser 		:= ::oOwner():oGetTable("USUARIO")  
	Local aScoreCards	:= {}  
	Local lHasAccess	:= .F.                   

	/*Localiza o usuário.*/	
	If (oUser:lSeek(1,{cUserId}))		
		/*Verifica se o usuário é administrador.*/
		If(oUser:lValue("ADMIN"))
			/*O administrador acessa todos os scorecards.*/
			lHasAccess	:= .T.
		Else			
			/*Recupera a lista de scorecards que o usuário tem acesso.*/
			aScoreCards	:=	oScorecard:aScoXRegraUsu(cScoreID,cUserId,.T., {}, Nil )
			/*Verifica se o usuário tem acesso ao scorecard solicitado.*/
			If ascan(aScoreCards, { |x| alltrim(x[1])  == alltrim(cScoreID)}) > 0
				lHasAccess	:= .T.
			EndIf
		EndIf
	EndIf
	
return lHasAccess

function _KPI016_Plano()
return nil
