// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI018_GrupoAcao.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 23.08.06 | 0739 Lucio Pelinson
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI018_GrupoAcao.ch"

/*--------------------------------------------------------------------------------------
@entity Projeto de Scorecards
Projetos agrupam plano de ações.
Projetos estao atreladas a Scorecards.
@table KPI018
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "GRUPO_ACAO"
#define TAG_GROUP  "GRUPO_ACOES"
#define TEXT_ENTITY STR0001 //"Plano de Ação"  
#define TEXT_GROUP  STR0002 //"Planos de Ação" 

class TKPI018 from TBITable
	method New() constructor
	method NewKPI018()

	// diversos registros
	method oToXMLRecList(cRequest) // Lista dos Assuntos no form pai
	method oToXMLNode()            //Carregar e Novo
	method oToXMLList()

	// registro atual                                             	
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID) 
	                            
	method cGetStatus(cStatus)
	method oXMLStatus()
	method oXMLUsuAtual()
	method nCalcPorcentagem(nTotal, nValor)
	method nCalculaVencido(cId)
	method nPercFinVenc(cId) 
	method nTotalAcoes(cId)
	method nTotalFin(cId)
	method lAddToList()
	method lUsuResp(cUserId, cUserTp)    
	method lRespAcao(cUsuario)

endclass
	
method New() class TKPI018
	::NewKPI018()
return

method NewKPI018() class TKPI018
	// Table
	::NewTable("SGI018")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C"	,010))
	::addField(TBIField():New("NOME"		,"C"	,255))
	::addField(TBIField():New("DESCRICAO"	,"M"	))
	::addField(TBIField():New("ID_RESP"		,"C"	,10))  //Id do Usuário reponsável pelo projeto
	::addField(TBIField():New("TP_RESP"		,"C"	,01))  //Tipo do responsavel: U - Usuario / G - Grupo
	::addField(TBIField():New("ID_EFEITO"	,"C"	,10))  //Id da Espinha de Peixe (EFEITO ROOT)
	::addField(TBIField():New("ID_CAUSA"	,"C"	,10))  //Id da Causa   
	::addField(TBIField():New("STATUS"		,"C"	,001)) //"1=Näo Aprovado","2=Em Aprovacao","3=Aprovado"
	::addField(TBIField():New("OBSERVACAO"	,"C"	,255)) //Observacao de Status
	
	// Indexes
	::addIndex(TBIIndex():New("SGI018I01",	{"ID"}					, .t.))
	::addIndex(TBIIndex():New("SGI018I02",	{"NOME"}				, .f.))
	::addIndex(TBIIndex():New("SGI018I03",	{"ID_RESP", "TP_RESP"}	, .f.))
	::addIndex(TBIIndex():New("SGI018I04",	{"ID_CAUSA"}			, .f.))

return

// Lista XML para anexar ao pai
method oToXMLList(cStatus) class TKPI018
	local oNode, oAttrib, oXMLNode, nInd
	default cStatus := ""	

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
	
	::SetOrder(2)
	::_First()
	while(!::lEof())
		if( !(alltrim(::cValue("ID")) == "0"))
			if Empty( cStatus ) .Or. ( ( alltrim(::cValue("STATUS")) == cStatus ))
				oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
				aFields := ::xRecord(RF_ARRAY, {"DESCRICAO"})
				for nInd := 1 to len(aFields) 
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], trim( aFields[nInd][2]) ))
				next
			endif
		endif			
		::_Next()		
	end

return oXMLNode

// Lista XML para anexar ao pai
method oToXMLRecList(cRequest) class TKPI018
	local oXMLNodeLista, oAttrib, oXMLNode, nInd
	local nVencidas := 0, nFinVenc := 0, nAtraVenc := 0
	local nTotalAcoes := 0, nFinTot := 0

	default cRequest := ""	
	oXMLNodeLista := TBIXMLNode():New("LISTA")
	
	//Colunas
	oAttrib := TBIXMLAttrib():New()
	//Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	//Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", KPI_STRING)       
	
	//Status
	oAttrib:lSet("TAG001", "STATUS")
	oAttrib:lSet("CAB001", STR0012) //"Status"
	oAttrib:lSet("CLA001", KPI_STRING)       

	//Observacao do Status
	oAttrib:lSet("TAG002", "OBSERVACAO")
	oAttrib:lSet("CAB002", STR0013) //"Obs. Status"
	oAttrib:lSet("CLA002", KPI_STRING)       

	//Vencidas
	oAttrib:lSet("TAG003", "VENCIDAS")
	oAttrib:lSet("CAB003", STR0004) //"Vencidas"
	oAttrib:lSet("CLA003", KPI_INT)
	
	//% Finalizadas Vencidas
	oAttrib:lSet("TAG004", "PORCFINVENC")
	oAttrib:lSet("CAB004", "<html><center>% " + STR0005 + "<br>" + STR0004 + "</center></html>") //Finalizadas Vencidas
	oAttrib:lSet("CLA004", KPI_FLOAT)
	
	//% Atrasadas Vencidas 
	oAttrib:lSet("TAG005", "PORCATRASVENC")
	oAttrib:lSet("CAB005", "<html><center>% " + STR0006 + "<br>" + STR0004 + "</center></html>") //Atrasadas Vencidas
	oAttrib:lSet("CLA005", KPI_FLOAT)

	//Total de Ações 
	oAttrib:lSet("TAG006", "TOTALACOES")
	oAttrib:lSet("CAB006", "<html><center>" + STR0007 + "<br>" + STR0008 + "</center></html>") //Total de Ações
	oAttrib:lSet("CLA006", KPI_INT)
	
	//% Finalizadas 
	oAttrib:lSet("TAG007", "FINALIZADAS")
	oAttrib:lSet("CAB007", "<html><center>%<br>" + STR0005 + "</center></html>") //Finalizadas
	oAttrib:lSet("CLA007", KPI_FLOAT)

	//Gera o principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	//Gera o no de detalhes
	::SetOrder(2)
	if(!empty(cRequest)) 
		::lFiltered(.t.)
		::cSQLFilter(cRequest)
	endif
	::_First()

	while(!::lEof())

		if( !(alltrim(::cValue("ID")) == "0"))    
		
			if ::lAddToList()
		
				oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
				aFields := ::xRecord(RF_ARRAY, {"DESCRICAO"}) 
				
				for nInd := 1 to len(aFields)
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
				next         
				
				nVencidas 	:= ::nCalculaVencido( alltrim(::cValue("ID")) )
				nFinVenc	:= ::nPercFinVenc( alltrim(::cValue("ID")) )
				nAtraVenc	:= nVencidas - nFinVenc
				nTotalAcoes	:= ::nTotalAcoes( alltrim(::cValue("ID")) )
				nFinTot		:= ::nTotalFin( alltrim(::cValue("ID")) )                           
				
				oNode:oAddChild(TBIXMLNode():New("STATUS", ::cGetStatus(::cValue("STATUS"))))
				oNode:oAddChild(TBIXMLNode():New("OBSERVACAO", alltrim(::cValue("OBSERVACAO"))))
				oNode:oAddChild(TBIXMLNode():New("VENCIDAS", nVencidas))
				oNode:oAddChild(TBIXMLNode():New("PORCFINVENC", ::nCalcPorcentagem(nVencidas, nFinVenc)))
				oNode:oAddChild(TBIXMLNode():New("PORCATRASVENC", ::nCalcPorcentagem(nVencidas, nAtraVenc)))
				oNode:oAddChild(TBIXMLNode():New("TOTALACOES", nTotalAcoes))
				oNode:oAddChild(TBIXMLNode():New("FINALIZADAS", ::nCalcPorcentagem(nTotalAcoes, nFinTot)))

			endif

		endif      
		
		::_Next()		
	end
	::cSQLFilter("")
	oXMLNodeLista :oAddChild(oXMLNode)	
		
return oXMLNodeLista

// Carregar
method oToXMLNode() class TKPI018
	local aFields, nInd, cId
	local oXMLNode	:= TBIXMLNode():New(TAG_ENTITY)
	local oCore		:= ::oOwner()	
	local oUsrGrp	:= ::oOwner():oGetTool("USERGROUP")
	local oParam	:= ::oOwner():oGetTable("PARAMETRO")
	local cTpResp	:= ""   
	local xValue	:= ""

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)

		xValue := aFields[nInd][2]
		If aFields[nInd][1] == "TP_RESP" 
			If empty(xValue)
				xValue := TIPO_USUARIO
			EndIf
			cTpResp := xValue		
		elseif aFields[nInd][1] == "STATUS"
			If empty(xValue)
				xValue := GRUPOACAO_NAO_INICIADO
			EndIf
		elseif aFields[nInd][1]=="ID"
			cId:=aFields[nInd][2]
		endif

		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], xValue))		
	next 
	          
	oXMLNode:oAddChild(oUsrGrp:oTreeUsrGrp())		
	oXMLNode:oAddChild(oUsrGrp:oUsuGroup())
	
	// Acrescenta combos
	oXMLNode:oAddChild(oCore:oGetTable("PLANOACAO"):oToXMLList(cId,3))//Plano de Ação
	oXMLNode:oAddChild(oCore:oGetTable("ESP_PEIXE"):oToXMLList())//Lista dos efeitos
	//Combo de Status	                                
	oXMLNode:oAddChild(::oXMLStatus())
	
	oXMLNode:oAddChild(TBIXMLNode():New("TP_RESP_ID_RESP",	cTpResp + ::cValue("ID_RESP")))
	//Indica se o usuario logado e responsavel
	oXMLNode:oAddChild(TBIXMLNode():New("ISRESP", ::lUsuResp(::oOwner():foSecurity:oLoggedUser():cValue("ID"),TIPO_USUARIO)))
	//Indica se o usuario logado e administrador
	oXMLNode:oAddChild(TBIXMLNode():New("ISADMIN", ::oOwner():foSecurity:oLoggedUser():lValue("ADMIN")))
	//Parametro - CTR_APROV_PLANACAO - Habilitar controle de aprovacao do plano de acao
	oXMLNode:oAddChild(TBIXMLNode():New("CTR_APROV_PLANACAO", oParam:getValue("CTR_APROV_PLANACAO") == "T"))

return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TKPI018
	local nStatus 	:= KPI_ST_OK 
	local aFields 	:= {}
	local nInd		:= 1
	local cGrupoID	:=	""
	private oXMLInput	:= oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	next
	cGrupoID		:=	::cMakeID()
	aAdd(aFields, {"ID", cGrupoID})

	// Grava
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	endif	

return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPI018
	local nStatus 	:= KPI_ST_OK
	local aFields 	:= {}
	local cID		:= ""
	local cStatus	:= ""
	local nInd		:= 1
	local oPlano	:= ::oOwner():oGetTable("PLANOACAO")
	local oParam	:= ::oOwner():oGetTable("PARAMETRO")
	private oXMLInput	:= oXML
	
	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))

		if aFields[nInd][1] == "ID"
			cID := aFields[nInd][2]
		elseif aFields[nInd][1] == "STATUS"
			cStatus := aFields[nInd][2]
		endif
	next
	
	// Verifica condições de gravação (append ou update)
	if(!::lSeek(1, {cID}))
		nStatus := KPI_ST_BADID
	else
	
	    //Se o controle de aprovacao estiver habilitado, so permite alterar status se todas as acoes estiverem "Em Execucao"
		if 	oParam:getValue("CTR_APROV_PLANACAO") == "T" .and. ;
			cStatus != ::cValue("STATUS") .and. ;
			::cValue("STATUS") == GRUPOACAO_NAO_INICIADO

			if(oPlano:lSeek(6,{cID}))

				while !oPlano:lEOF() .and. oPlano:cValue("ID_ASSUNTO") == cID .and. nStatus == KPI_ST_OK
					if !(oPlano:cValue("STATUS") == ACAO_EM_EXECUCAO)
						::fcMsg := STR0014 //"O Plano de Ação somente pode ser Aprovado após todas as Ações estarem Em Execução."
						nStatus := KPI_ST_VALIDATION
					endif

					oPlano:_Next()

				enddo
			else
				::fcMsg := STR0015 //"O Plano de Ação somente pode ser Aprovado caso existam Ações."
				nStatus := KPI_ST_VALIDATION
			endif

		endif

		if nStatus == KPI_ST_OK
			if !::lUpdate(aFields)
				if ::nLastError()==DBERROR_UNIQUE
					nStatus := KPI_ST_UNIQUE
				else
					nStatus := KPI_ST_INUSE
				endif
			endif
		endif
		
	endif     
	
return nStatus

// Excluir entidade do server
method nDelFromXML(cID) class TKPI018
	local nStatus	:= KPI_ST_OK
	local oKpiCore	:= ::oOwner()
	local oPlano	:= oKpiCore:oGetTable("PLANOACAO")
	
	//Verificar se o registro possui relacionamento com outras tabelas
	//KPI016: Plano de Ação
	oPlano:_first()
	if(oPlano:lSoftSeek(6,{cID}))
		::fcMsg := STR0003 //"Este plano de ação possui ação e não pode ser excluído."
		nStatus := KPI_ST_VALIDATION
	else
		::fcMsg := ""
	endif
			
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

return nStatus                        
      

/*
 *Lista de Status do plano de acao
 */
method oXMLStatus() class TKPI018
	local oAttrib, oNode, oXMLOutput
	local nInd, aStatus := { STR0009, STR0010, STR0011}
	//"Näo Aprovado" # "Em Aprovacao" # "Aprovado"
	
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
        

/*
*Retorna a Descrição do status
*/
method cGetStatus(cStatus) class TKPI018
	local cDescricao := ""

	do case
		case cStatus == "1"
			cDescricao	:= STR0009 //"Não Aprovado"
		case cStatus == "2"
			cDescricao	:= STR0010 //"Em Aprovacao"
		case cStatus == "3"
			cDescricao	:= STR0011 //"Aprovado"
	endcase		

return cDescricao    
                     

/*
 *Calcula a porcentagem
 */
method nCalcPorcentagem(nTotal, nValor) class TKPI018
	local nPorcentagem := 0
	if(nTotal != 0)
		nPorcentagem := round( ( (nValor*100)/nTotal ), 2 )
	endif
return nPorcentagem

/*
 *Calcula o valor do campo Vencidos
 */
method nCalculaVencido(cId) class TKPI018
	local nValorAcum := 0
	
	//Para efeito de melhoria de performance a soma dos planos vencidos e realizada via comando SQL.
	cOldAlias := alias()
	
	cSql :=	"SELECT COUNT(ID)"
	cSql +=	" FROM SGI016"
	cSql +=	" WHERE ID_ASSUNTO='"+ cId +"' AND DATAFIM<'"+ dtos(date()) +"' AND D_E_L_E_T_<>'*'"
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"__TRB",.f.,.t.)
	nValorAcum := FieldGet(1)
	dbCloseArea()
	dbSelectArea(cOldAlias)

return nValorAcum

/*
 *Calcula o valor do campo % Finalizadas Vencidas
 */
method nPercFinVenc(cId) class TKPI018
	local nValorAcum := 0
	
	//Para efeito de melhoria de performance a soma dos planos vencidos e realizada via comando SQL.
	cOldAlias := alias()

	cSql :=	"SELECT COUNT(ID)"
	cSql +=	" FROM SGI016" 
	cSql +=	" WHERE ID_ASSUNTO='"+ cId +"' AND DATAFIM<'"+ dtos(date()) + "' AND STATUS='3' AND D_E_L_E_T_<>'*'" //Status 3 - Executada
			
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"__TRB",.f.,.t.)
	nValorAcum := FieldGet(1)
	dbCloseArea()
	dbSelectArea(cOldAlias)

return nValorAcum

/*
 *Calcula o valor do campo Total de Ações
 */
method nTotalAcoes(cId) class TKPI018
	local nValorAcum := 0
	
	//Para efeito de melhoria de performance a soma dos planos vencidos e realizada via comando SQL.
	cOldAlias := alias()

	cSql :=	"SELECT COUNT(ID)"
	cSql +=	" FROM SGI016" 
	cSql +=	" WHERE ID_ASSUNTO='"+ cId +"'  AND D_E_L_E_T_<>'*'"
			
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"__TRB",.f.,.t.)
	nValorAcum := FieldGet(1)
	dbCloseArea()
	dbSelectArea(cOldAlias)

return nValorAcum

method nTotalFin(cId) class TKPI018
	local nValorAcum := 0
	
	//Para efeito de melhoria de performance a soma dos planos vencidos e realizada via comando SQL.
	cOldAlias := alias()

	cSql :=	"SELECT COUNT(ID)"
	cSql +=	" FROM SGI016" 
	cSql +=	" WHERE ID_ASSUNTO='"+ cId +"' AND STATUS='3' AND D_E_L_E_T_<>'*'" //Status 3 = Executada
			
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"__TRB",.f.,.t.)
	nValorAcum := FieldGet(1)
	dbCloseArea()
	dbSelectArea(cOldAlias)

return nValorAcum                                    

/*
	Filtra o plano de acao e acao pelo usuario responsavel 
	de acordo com o parametro "FILTER_ACAO_PLANACAO"
*/
method lAddToList() class TKPI018

	local lRet		:= .T.
	local oParam	:= ::oOwner():oGetTable("PARAMETRO")
	local cIdUsuario:= ::oOwner():foSecurity:oLoggedUser():cValue("ID")
	local isAdmin	:= ::oOwner():foSecurity:oLoggedUser():lValue("ADMIN")

	if (!isAdmin .and. oParam:getValue("FILTER_ACAO_PLANACAO") == "T")

		lRet := ::lUsuResp(cIdUsuario, TIPO_USUARIO)// verifica se usuario logado é responsavel pelo plano de acao

		if !lRet

			lRet := ::lRespAcao(cIdUsuario) //verifica se o usuario logado é responsavel por alguma acao do plano de acao

		endif

	endif

return lRet

/*
*Verifica se o usuario/grupo tem responsabilidade sobre o Plano de ação
*/
method lUsuResp(cUserId, cUserTp) class TKPI018
 
	local lAccess	:= .F.
	local cUserId	:= padr( cUserId, 10 )
	local oUsrGrp	:= ::oOwner():oGetTool("USERGROUP")   
	
	default cUserTp := TIPO_USUARIO

	if cUserTp == TIPO_GRUPO

		if ::cValue("TP_RESP") == TIPO_GRUPO
			lAccess := ( cUserId == ::cValue("ID_RESP") )
		else
			lAccess := oUsrGrp:lUserInGrp( ::cValue("ID_RESP"), cUserId )
		endif

	else

		if ::cValue("TP_RESP") == TIPO_GRUPO
			lAccess := oUsrGrp:lUserInGrp( cUserId, ::cValue("ID_RESP") )
		else
			lAccess := ( cUserId == ::cValue("ID_RESP") )
		endif

	endif

return lAccess
               
/*
	Verifica se o usuario e responsavel por alguma acao do plano de acao.
*/
method lRespAcao(cUsuario) class TKPI018

	local oPlano	:= ::oOwner():oGetTable("PLANOACAO")
	local oUsrGrp	:= ::oOwner():oGetTool("USERGROUP")
	local lRet		:= .F.
	local aArea		:= oPlano:SavePos()
	
	oPlano:lSeek(6,{::cValue("ID")})
	
	while !lRet .and. !oPlano:lEof() .and. oPlano:cValue("ID_ASSUNTO") == ::cValue("ID")

		if oPlano:cValue("TP_RESP") == TIPO_GRUPO
			lRet := oUsrGrp:lUserInGrp(cUsuario, oPlano:cValue("ID_RESP"))
		else
			lRet := ( alltrim(oPlano:cValue("ID_RESP")) == cUsuario )
		endif

		oPlano:_next()
	enddo
    
	oPlano:restPos(aArea)    
	
return lRet                                                  

function _KPI018_GrupoAcao()
return nil