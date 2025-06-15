// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI014_Projeto.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 28.09.05 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI014_Projeto.ch"

/*--------------------------------------------------------------------------------------
@entity Projeto de Scorecards
Projetos agrupam plano de ações.
Projetos estao atreladas a Scorecards.
@table KPI014
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "PROJETO"
#define TAG_GROUP  "PROJETOS"
#define TEXT_ENTITY STR0001/*//"Projeto"*/
#define TEXT_GROUP  STR0002/*//"Projetos"*/

#define REDUZIDO  	1
#define DETALHADO  	2 

class TKPI014 from TBITable
	method New() constructor
	method NewKPI014()

	// diversos registros
	method oToXMLRecList(cRequest)
	method oToXMLNode()
	method oToXMLList(cScorecard)

	// registro atual                                             	
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID) 
	
	method lUsuResp(cUsuAtual) 
	method hasUserPermission()
	method oXMLUsuAtual()
	method nCalcPorcentagem(nTotal, nValor)
	method nCalculaVencido(cIdProj)
	method nPercFinVenc(cIdProj) 
	method nTotalAcoes(cIdProj)
	method nTotalFin(cIdProj)
    method oToXMLAttrib()
endclass
	
method New() class TKPI014
	::NewKPI014()
return

method NewKPI014() class TKPI014
	// Table
	::NewTable("SGI014")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C"	,010))
	::addField(TBIField():New("NOME"		,"C"	,255))
	::addField(TBIField():New("DESCCOD"		,"C"	,050))
	::addField(TBIField():New("DESCRICAO"	,"M"	))
	::addField(TBIField():New("ID_SCORE"	,"C"	,010))
	::addField(TBIField():New("OWNER"		,"C"	,010)) //Id do Usuário proprietario do projeto
	::addField(TBIField():New("DESCTIPO"	,"C"	,255))
	::addField(TBIField():New("ID_RESP"		,"C"	,10))  //Id do Usuário reponsável pelo projeto

	// Indexes
	::addIndex(TBIIndex():New("SGI014I01",	{"ID"}				,.T.))
	::addIndex(TBIIndex():New("SGI014I02",	{"NOME"}			,.F.))
	::addIndex(TBIIndex():New("SGI014I03",	{"ID_SCORE"	, "ID"}	,.T.))
	::addIndex(TBIIndex():New("SGI014I04",	{"OWNER"}			,.F.)) 
	::addIndex(TBIIndex():New("SGI014I05",	{"ID_RESP"} 		,.F.))  
	::addIndex(TBIIndex():New("SGI014I06",	{"ID_SCORE"}		,.F.))
return
  
/** 
*/     
method oToXMLAttrib(nTipo) class TKPI014	
	//Colunas
	Local oAttrib := TBIXMLAttrib():New()
	
	Default nTipo := REDUZIDO
		
	//Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	//Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", KPI_STRING)
    
	If (nTipo == DETALHADO)
		//Vencidas
		oAttrib:lSet("TAG001", "VENCIDAS")
		oAttrib:lSet("CAB001", STR0004) //"Vencidas"
		oAttrib:lSet("CLA001", KPI_INT)
		
		//% Finalizadas Vencidas
		oAttrib:lSet("TAG002", "PORCFINVENC")
		oAttrib:lSet("CAB002", "<html><center>% "+STR0005+"<br>"+STR0004+"</center></html>") //"% Finalizadas Vencidas"
		oAttrib:lSet("CLA002", KPI_FLOAT)
		
		//% Atrasadas Vencidas 
		oAttrib:lSet("TAG003", "PORCATRASVENC")
		oAttrib:lSet("CAB003", "<html><center>% "+STR0006+"<br>"+STR0004+"</center></html>") //"% Atrasadas Vencidas"
		oAttrib:lSet("CLA003", KPI_FLOAT)
	
		//Total de Ações 
		oAttrib:lSet("TAG004", "TOTALACOES")
		oAttrib:lSet("CAB004", "<html><center>"+STR0007+"<br>"+STR0008+"</center></html>") //"Total de Ações"
		oAttrib:lSet("CLA004", KPI_INT)
		
		//% Finalizadas 
		oAttrib:lSet("TAG005", "FINALIZADAS")
		oAttrib:lSet("CAB005", "<html><center>%<br>"+STR0005+"</center></html>") //"Finalizadas"
		oAttrib:lSet("CLA005", KPI_FLOAT)     
	EndIf
return oAttrib

/**
*/
method oToXMLList(cScorecard) class TKPI014
	Local oNode 
	Local oXMLNode
	Local nInd
		
	Default cScorecard := ""
	
	oXMLNode := TBIXMLNode():New( TAG_GROUP, , ::oToXMLAttrib( REDUZIDO ) )
	
	if(!empty(cScorecard))
		::cSQLFilter("ID_SCORE = '"+ cScorecard +"'")
		::lFiltered(.t.)
	endif
	
	::SetOrder(2)
	::_First()
	
	while(!::lEof())
		if( !(alltrim(::cValue("ID")) == "0"))
			if(::hasUserPermission())
				oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
				aFields := ::xRecord(RF_ARRAY, {"DESCRICAO"})
				for nInd := 1 to len(aFields)
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
				next
			endif
		endif			
		::_Next()		
	end
	::cSQLFilter("")
	::lFiltered(.f.)

return oXMLNode

/**
*/
method oToXMLRecList(cRequest) class TKPI014
	Local oXMLNodeLista := Nil
	Local oXMLNode		:= Nil  
	local oUser			:= ::oOwner():foSecurity:oLoggedUser()
	Local nInd			:= 0
	Local nVencidas 	:= 0
	Local nFinVenc 		:= 0
	Local nAtraVenc 	:= 0
	Local nTotalAcoes 	:= 0
	Local nFinTot 		:= 0
	Local cSQLFilter	:= ""
	Local aComandos		:= {"","",""} 
	local oUsrGrp		:= ::oOwner():oGetTool("USERGROUP")    
	Local oGrupoUsu	    := ::oOwner():oGetTable("GRPUSUARIO")
	local aGrupos       := ""    
	local nContador     := 0          
	local cUsuAtual 	:= oUser:cValue("ID")

	Default cRequest := ""
     
    //Ajuste temporário da string cRequest (está vindo faltando uma | )
    if( at ( '|U' , cRequest) <> 0 )
	    cRequest := StrTran ( cRequest, '|U', '|U|') 
	elseif( at ( '|G' , cRequest) <> 0 )  
        cRequest := StrTran ( cRequest, '|G', '|G|')
    EndIf    

	//Recupera os parâmetros passados para o método.
  	aComandos := aBIToken(cRequest, "|", .F.)

	Do Case  
		Case aComandos[1] == "PROJETO_USER_ALL"
			cSQLFilter +=	"ID_RESP IN ('" + cBIStr(cUsuAtual) + "'" 	
 			aGrupos:= oGrupoUsu:aGroupsByUser(cUsuAtual)
 				    
 		     For nContador:=1 to Len(aGrupos)
	 		     cSQLFilter += " , '" + aGrupos[nContador] + "'" 
 		     Next  
		
			cSQLFilter += " )"   
			cSQLFilter += " AND D_E_L_E_T_<>'*' "
			
		Case aComandos[1] == "PROJETO_SCORECARD"   
 			cSQLFilter :=  " ID_SCORE = '" + cBIStr(aComandos[2]) + "'" 
                         
		Case aComandos[1] == "PROJETO_USUARIO"    
			//Lista de acoes de um usuário ou grupo específico
				cSQLFilter +=	"ID_RESP IN ('" + cBIStr(aComandos[LEN(aComandos)]) + "'" 
				
				if ( aComandos[2] =="U" ) //Se for um usuário específico, procura por todos os grupos que o mesmo participa
 				    aGrupos:= oGrupoUsu:aGroupsByUser(aComandos[3])
 				    
 				     For nContador:=1 to Len(aGrupos)
	 				     cSQLFilter += " , '" + aGrupos[nContador] + "'" 
 				     Next  
 				     
 				      
				endif 
				
				cSQLFilter += " )"   
				cSQLFilter += " AND D_E_L_E_T_<>'*' "
			  
		Case aComandos[1] =="USUARIOS"
			oXMLNodeLista := TBIXMLNode():New("LISTA")
	   		oXMLNodeLista:oAddChild(oUsrGrp:oTreeUsrGrp())
	   		oXMLNodeLista:oAddChild(oUsrGrp:oUsuGroup())
		     
			return oXMLNodeLista
		OtherWise
			oXMLNode := ::oToXMLList(cRequest)
	End Case

	oXMLNodeLista := TBIXMLNode():New("LISTA")

	if !( Empty(cSQLFilter) )

		oXMLNode := TBIXMLNode():New( TAG_GROUP, , ::oToXMLAttrib( DETALHADO ) )
		
		::SetOrder(2)
		::cSQLFilter(cSQLFilter)
		::lFiltered(.t.)
		::_First()
		
		While ( !::lEof() )

			If ( ::hasUserPermission() )  
			
				oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
				aFields := ::xRecord(RF_ARRAY, {"DESCRICAO"})
				
				For nInd := 1 To Len(aFields)
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
				Next
				
				nVencidas 	:= ::nCalculaVencido( alltrim(::cValue("ID")) )
				nFinVenc	:= ::nPercFinVenc( alltrim(::cValue("ID")) )
				nAtraVenc	:= nVencidas - nFinVenc
				nTotalAcoes	:= ::nTotalAcoes( alltrim(::cValue("ID")) )
				nFinTot		:= ::nTotalFin( alltrim(::cValue("ID")) )   
				
				oNode:oAddChild(TBIXMLNode():New("VENCIDAS"		, nVencidas))
				oNode:oAddChild(TBIXMLNode():New("PORCFINVENC"	, ::nCalcPorcentagem(nVencidas, nFinVenc)))
				oNode:oAddChild(TBIXMLNode():New("PORCATRASVENC", ::nCalcPorcentagem(nVencidas, nAtraVenc)))
				oNode:oAddChild(TBIXMLNode():New("TOTALACOES"	, nTotalAcoes))
				oNode:oAddChild(TBIXMLNode():New("FINALIZADAS"	, ::nCalcPorcentagem(nTotalAcoes, nFinTot)))
				
			Endif

			::_Next()		
		End  
		
		::cSQLFilter("")
	Endif
	
	oXMLNodeLista:oAddChild(oXMLNode)	  
return oXMLNodeLista

// Carregar
method oToXMLNode() class TKPI014
	local aFields		:= {} 
	local nInd			:= 0 
	local cId			:= ""
	local oXMLNode		:= TBIXMLNode():New(TAG_ENTITY)
	local oCore			:= ::oOwner()	
	local oPermissao	:= oCore:oGetTable("PERM_PROJETO")
	local oUsrGrp		:= ::oOwner():oGetTool("USERGROUP")  
	
	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1]=="ID")
			cId:=aFields[nInd][2]
		endif
	next

	// Veririfica se o usuário atual é criador do projeto
	oUser := oKpiCore:foSecurity:oLoggedUser()
	if( ( oUser:lValue("ADMIN") ) .or. ( alltrim(::cValue("OWNER")) == alltrim(oUser:cValue("ID")) ) )
		oXMLNode:oAddChild(TBIXMLNode():New("PERMISSAO", .t.))
	else
		oXMLNode:oAddChild(TBIXMLNode():New("PERMISSAO", .f.))
	endif

	//Verifica se o usuario pode incluir plano de acao para o projeto.
	//0-Nao pode incluir projeto, 1-Pode Fazer manutencao, 2-Pode visualizar.
	if(oPermissao:lSeek(3,{cId,oUser:cValue("ID")}) .or.  alltrim(::cValue("ID_RESP"))  == alltrim(oUser:cValue("ID")))
		oXMLNode:oAddChild(TBIXMLNode():New("ACAO_PERMISSAO", 1))
	else
		oXMLNode:oAddChild(TBIXMLNode():New("ACAO_PERMISSAO", 0))
	endif
	
	// Acrescenta combos
	oXMLNode:oAddChild(oCore:oGetTable("SCORECARD"):oToXMLList(.T.))//Scorecard
	oXMLNode:oAddChild(oCore:oGetTable("PLANOACAO"):oToXMLList(cId,2))//Plano de Ação
   	oXMLNode:oAddChild(oCore:oGetTable("USUARIO"):oToXMLList())//Lista dos usuarios
	oXMLNode:oAddChild(oUsrGrp:oTreeUsrGrp()) 								//Arvore de Usuários e Grupos 	
	oXMLNode:oAddChild(oUsrGrp:oUsuGroup())   								//Lista de Usuários e Grupos
	oXMLNode:oAddChild(oPermissao:oToXMLProjxUsu(cId))//usuarios com permissao para alterar o projeto.
	
	//oXMLNodeLista:oAddChild(oUsrGrp:oTreeUsrGrp()) //Árvore de Usuários e Grupos 	
	//oXMLNodeLista:oAddChild(oUsrGrp:oUsuGroup())   //Lista de Usuários e Grupos
	
return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TKPI014
	local aFields, nInd, nStatus := KPI_ST_OK, aPermAlt 
	local cProjID		:=	""
	local cScorID		:=	""
	local oScoreCard	:= ::oOwner():oGetTable("SCORECARD")
	local oUser 		:= oKpiCore:foSecurity:oLoggedUser()
	Local cTextScor	:= alltrim( getJobProfString("ScoreCardName", "ScoreCard") )	
	    
	private oXMLInput	:= oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		
		if(aFields[nInd][1] == "ID_SCORE" .and. ! oUser:lValue("ADMIN") )		
			//Somente o usuario dono do departamento pode incluir projetos.
			if oScoreCard:lSeek(1,{aFields[nInd][2]}) .and. ! (oUser:cValue("ID") == oScoreCard:cValue("RESPID"))
				::fcMsg := STR0012 + cTextScor + STR0013	//"Somente o responsável pelo "###" pode incluir projetos."
				return KPI_ST_VALIDATION  
			endif
		endif
	next
	
	cProjID		:=	::cMakeID()
	aAdd(aFields, {"ID", cProjID})
	aAdd(aFields, {"OWNER", oUser:cValue("ID")})

	// Grava
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	else
		oTablePer	:= ::oOwner():oGetTable("PERM_PROJETO")
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_PERM_PROJETOS"), "_PERM_PROJETO"))!="U")
			if(valtype(&("oXMLInput:"+cPath+":_PERM_PROJETOS:_PERM_PROJETO"))=="A")
				for nInd := 1 to len(&("oXMLInput:"+cPath+":_PERM_PROJETOS:_PERM_PROJETO"))
					aPermAlt := &("oXMLInput:"+cPath+":_PERM_PROJETOS:_PERM_PROJETO["+cBIStr(nInd)+"]")
					aFields := {}
					aAdd( aFields, {"ID"		,	oTablePer:cMakeID()	} )
					aAdd( aFields, {"PROJ_ID"	, 	cProjID		} )	
					aAdd( aFields, {"USERID"	, 	aPermAlt:_ID:TEXT} )	
					nStatus := oTablePer:nInsFromXML(aFields)
					if(nStatus != KPI_ST_OK)
						exit
					endif
				next	
			elseif(valtype(&("oXMLInput:"+cPath+":_PERM_PROJETOS:_PERM_PROJETO"))=="O")
				aPermAlt := &("oXMLInput:"+cPath+":_PERM_PROJETOS:_PERM_PROJETO")
				aFields := {}
				aAdd( aFields, {"ID"		,	oTablePer:cMakeID()	} )
				aAdd( aFields, {"PROJ_ID"	, 	cProjID		} )	
				aAdd( aFields, {"USERID"	, 	aPermAlt:_ID:TEXT} )	
				nStatus := oTablePer:nInsFromXML(aFields)
			endif	
		endif			
	endif	

return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPI014
	local nFrequencia, nStatus := KPI_ST_OK, cID, nInd, lAscendente
	local oMeta, nAzul1, nVerde, nAmarelo, nVermelho, lFCumula
	local aUserPerm		:=	{},aPermAlt	:={}
	local oScoreCard	:= ::oOwner():oGetTable("SCORECARD")
	local oUser 		:= oKpiCore:foSecurity:oLoggedUser()
	Local cTextScor	:= alltrim( getJobProfString("ScoreCardName", "ScoreCard") )	

	private oXMLInput	:= oXML
	
	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		endif	

		if(aFields[nInd][1] == "ID_SCORE" .and. ! oUser:lValue("ADMIN") )		
			//Somente o usuario dono do departamento pode incluir projetos.
			if oScoreCard:lSeek(1,{aFields[nInd][2]}) .and. ! (oUser:cValue("ID") == oScoreCard:cValue("RESPID"))
				::fcMsg := STR0012 + cTextScor + STR0014 //"Somente o responsável pelo "###" pode alterar projetos."
				return KPI_ST_VALIDATION  
			endif
		endif
	next

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
			oTablePer	:= ::oOwner():oGetTable("PERM_PROJETO")
			if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_PERM_PROJETOS"), "_PERM_PROJETO"))!="U")
				if(valtype(&("oXMLInput:"+cPath+":_PERM_PROJETOS:_PERM_PROJETO"))=="A")
					for nInd := 1 to len(&("oXMLInput:"+cPath+":_PERM_PROJETOS:_PERM_PROJETO"))
						aPermAlt := &("oXMLInput:"+cPath+":_PERM_PROJETOS:_PERM_PROJETO["+cBIStr(nInd)+"]")
						aFields := {}
						aAdd( aFields, {"ID"		,	oTablePer:cMakeID()	} )
						aAdd( aFields, {"PROJ_ID"	, 	cID		} )	
						aAdd( aFields, {"USERID"	, 	aPermAlt:_ID:TEXT} )	
						aadd(aUserPerm,aFields)
					next	

				elseif(valtype(&("oXMLInput:"+cPath+":_PERM_PROJETOS:_PERM_PROJETO"))=="O")
					aPermAlt := &("oXMLInput:"+cPath+":_PERM_PROJETOS:_PERM_PROJETO")
					aFields := {}
					aAdd( aFields, {"ID"		,	oTablePer:cMakeID()	} )
					aAdd( aFields, {"PROJ_ID"	, 	cID		} )	
					aAdd( aFields, {"USERID"	, 	aPermAlt:_ID:TEXT} )	
					aadd(aUserPerm,aFields)
				endif
				//Faz a atualizacao dos usuarios
				nStatus := oTablePer:nUpdFromArray(aUserPerm,cID)
			else
				//Nao tem nada apaga todos;
				nStatus := oTablePer:nDelFromXML(cID)
			endif
		endif	
	endif
return nStatus

// Excluir entidade do server
method nDelFromXML(cID) class TKPI014
	local nStatus		:= KPI_ST_OK
	local oKpiCore		:= ::oOwner()
	local oPlano 		:= ::oOwner():oGetTable("PLANOACAO")
	local oScoreCard	:= ::oOwner():oGetTable("SCORECARD")
	local oUser 		:= oKpiCore:foSecurity:oLoggedUser()
	Local cTextScor	:= alltrim( getJobProfString("ScoreCardName", "ScoreCard") )	

	//Somente o usuario dono do departamento pode excluir projetos.
	if ! oUser:lValue("ADMIN") .and. ::lSeek(1,{cID}) .and. oScoreCard:lSeek(1,{::cValue("ID_SCORE")});
		.and. ! (oUser:cValue("ID") == oScoreCard:cValue("RESPID"))
	
		::fcMsg := STR0012 + cTextScor + STR0015	//"Somente o responsável pelo "###" pode excluir projetos."
		nStatus := KPI_ST_VALIDATION  
	else
		::oOwner():oOltpController():lBeginTransaction()
		
		//Verificar se o registro possui relacionamento com outras tabelas KPI016: Plano de Ação
		if(oPlano:lSoftSeek(3,{cID}))
			::fcMsg := STR0003 + alltrim(oPlano:cValue("NOME")) + "'!"
			::oOwner():oOltpController():lRollback()
			return KPI_ST_VALIDATION
		else
			::fcMsg := ""
		endif
				
		//Apaga as permissoes
		nStatus := ::oOwner():oGetTable("PERM_PROJETO"):nDelFromXML(cID, "P")
	
		// Deleta o elemento
		if(nStatus == KPI_ST_OK)
			if(::lSeek(1,{cID}))
				if(!::lDelete())
					nStatus := KPI_ST_INUSE
				endif
			else
				nStatus := KPI_ST_BADID
			endif	
	    endif
	
		if(nStatus != KPI_ST_OK)
			::oOwner():oOltpController():lRollback()
		endif
	
		::oOwner():oOltpController():lEndTransaction()
	endif
	
return nStatus                        

method lUsuResp(cUsuAtual) class TKPI014
	local lIsResp	:= .F.
	local oPlano	:= ::oOwner():oGetTable("PLANOACAO")
	local oUsrGrp	:= ::oOwner():oGetTool("USERGROUP")
	
	oPlano:cSQLFilter("ID_PROJ = '"+ ::cValue("ID") +"'")
	oPlano:lFiltered(.t.)
	oPlano:_First()

	while !oPlano:lEof() .and. !lIsResp

		if oPlano:cValue("TP_RESP") == TIPO_GRUPO
			lIsResp := oUsrGrp:lUserInGrp(cUsuAtual, oPlano:cValue("ID_RESP"))
		else
			lIsResp := ( alltrim(oPlano:cValue("ID_RESP")) == cUsuAtual )
		endif

		oPlano:_next()
	enddo

	oPlano:cSqlFilter("")

return lIsResp

/*
*Verifica se o usuario tem permissao para visualizar o projeto
*/
method hasUserPermission() class TKPI014
	local lPermission := .f.
	local oUser		:= ::oOwner():foSecurity:oLoggedUser()
	local cUsuAtual := alltrim(oUser:cValue("ID"))
	local cIdOwner	:= alltrim(::cValue("OWNER"))
	local cIdProj	:= alltrim(::cValue("ID"))
	local oPermissao:= ::oOwner():oGetTable("PERM_PROJETO")

	if	oUser:lValue("ADMIN") .or.;
		::cValue("ID_RESP")  == cUsuAtual .or.;
		cUsuAtual == cIdOwner .or.;
		::lUsuResp(cUsuAtual) .or.;
		oPermissao:lSeek(3,{cIdProj,oUser:cValue("ID")})

		lPermission := .t.

	endif

return lPermission

/*
 *Calcula a porcentagem
 */
method nCalcPorcentagem(nTotal, nValor) class TKPI014
	local nPorcentagem := 0
	if(nTotal != 0)
		nPorcentagem := round( ( (nValor*100)/nTotal ), 2 )
	endif
return nPorcentagem

/*
 *Calcula o valor do campo Vencidos
 */
method nCalculaVencido(cIdProj) class TKPI014
	local nValorAcum := 0
	
	//Para efeito de melhoria de performance a soma dos planos vencidos e realizada via comando SQL.
	cOldAlias := alias()
	
	cSql :=	"SELECT COUNT(ID)"
	cSql +=	" FROM SGI016"
	cSql +=	" WHERE ID_PROJ='"+ cIdProj +"' AND DATAFIM<'"+ dtos(date()) +"' AND D_E_L_E_T_<>'*'"
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"__TRB",.f.,.t.)
	nValorAcum := FieldGet(1)
	dbCloseArea()
	dbSelectArea(cOldAlias)

return nValorAcum

/*
 *Calcula o valor do campo % Finalizadas Vencidas
 */
method nPercFinVenc(cIdProj) class TKPI014
	local nValorAcum := 0
	
	//Para efeito de melhoria de performance a soma dos planos vencidos e realizada via comando SQL.
	cOldAlias := alias()

	cSql :=	"SELECT COUNT(ID)"
	cSql +=	" FROM SGI016" 
	cSql +=	" WHERE ID_PROJ='"+ cIdProj +"' AND DATAFIM<'"+ dtos(date()) + "' AND STATUS='3' AND D_E_L_E_T_<>'*'" //Status 3 - Executada
			
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"__TRB",.f.,.t.)
	nValorAcum := FieldGet(1)
	dbCloseArea()
	dbSelectArea(cOldAlias)

return nValorAcum

/*
 *Calcula o valor do campo Total de Ações
 */
method nTotalAcoes(cIdProj) class TKPI014
	local nValorAcum := 0
	
	//Para efeito de melhoria de performance a soma dos planos vencidos e realizada via comando SQL.
	cOldAlias := alias()

	cSql :=	"SELECT COUNT(ID)"
	cSql +=	" FROM SGI016" 
	cSql +=	" WHERE ID_PROJ='"+ cIdProj +"'  AND D_E_L_E_T_<>'*'"
			
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"__TRB",.f.,.t.)
	nValorAcum := FieldGet(1)
	dbCloseArea()
	dbSelectArea(cOldAlias)

return nValorAcum

method nTotalFin(cIdProj) class TKPI014
	local nValorAcum := 0
	
	//Para efeito de melhoria de performance a soma dos planos vencidos e realizada via comando SQL.
	cOldAlias := alias()

	cSql :=	"SELECT COUNT(ID)"
	cSql +=	" FROM SGI016" 
	cSql +=	" WHERE ID_PROJ='"+ cIdProj +"' AND STATUS='3' AND D_E_L_E_T_<>'*'" //Status 3 = Executada
			
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"__TRB",.f.,.t.)
	nValorAcum := FieldGet(1)
	dbCloseArea()
	dbSelectArea(cOldAlias)

return nValorAcum

function _KPI014_Projeto()
return nil