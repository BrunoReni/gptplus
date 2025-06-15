// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI010A_ScorXuser
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 18.10.05 | Alexandre Alves da Silva
// 05.02.09 | Lucio Pelinson - Permissão por Grupo
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI010A_ScorXuser.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->TKPI010A
Container principal do sistema, contém todos os elementos.
@entity: Scorecard (Departamento)
@table KPI010A
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "SCOR_X_USER"
#define TAG_GROUP  "SCORS_X_USERS"
#define TEXT_ENTITY STR0001/*//"Scorecard"*/
#define TEXT_GROUP  STR0002/*//"Scorecards"*/


class TKPI010A from TBITable
	method New() constructor
	method NewKPI010A()
	method aScorxUsu(cUserId)  
   	method aSimpleSearch( cIDUser )
	method aRecursiveSearch( cIDUser )
	method aUsuxScor(cScorId) 
	method aScorxGrp(cGrupoId) 
	method nInsFromXML(cUserID,aSco)
	method nDelFromXML(cId,cTipo)
endclass
	
method New() class TKPI010A
	::NewKPI010A()
return

method NewKPI010A() class TKPI010A




	// Table
	::NewTable("SGI010A")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"			,"C",	010))
	::addField(TBIField():New("SCORE_ID"	,"C",	010))
	::addField(TBIField():New("TIPOUSER"	,"C",	001))//'G'=Grupo ' '=Usuário
	::addField(TBIField():New("USERID"		,"C",	010))//Usuario Autorizado a visualizar

	// Indexes
	::addIndex(TBIIndex():New("SGI010AI01",	{"ID"},	.t.))
	::addIndex(TBIIndex():New("SGI010AI02",	{"USERID"}, .f.))
	
return

/**
Lista dos Scorecards que o Usuario recebeu direito de visualizar.
@Param (Lógico) cUserId  ID do usuário.
@Return	(Array) aScorCards  Lista contendo os scorecards que o usuário pode acessar.
*/
method aScorxUsu( cIDUser ) class TKPI010A
   	Local aScorecard := {} 
	Local oParametro := ::oOwner():oGetTable("PARAMETRO") 

	If ( xBIConvTo("L", oParametro:getValue("PERMISSAO_RECURSIVA") ) )   
	   	aScorecard 	:= ::aRecursiveSearch( cIDUser ) 
	Else 
		aScorecard 	:= ::aSimpleSearch( cIDUser )
	EndIf	
Return aScorecard   

/**
Lista dos scorecards que o usuário recebeu direito de visualizar.
@Param (Lógico) cUserId  ID do usuário.
@Return	(Array) aScorCards  Lista contendo os scorecards que o usuário pode acessar.
@See A pesquisa simples não considera que o responsável do scorecard tem acesso aos filhos.
*/ 
method aSimpleSearch( cIDUser ) class TKPI010A
	Local cAlias   := getNextAlias()
	Local aScorecard := {}
	
	cSql := " SELECT "   
	cSql += "	A.SCORE_ID ID, "    
	cSql += "	B.NOME NOME, "
	cSql += "	B.TIPOSCORE TIPOSCORE "
	cSql += " FROM "
	cSql += "	SGI010A A, SGI010 B "
	cSql += " WHERE "    
	cSql += "	B.ID = A.SCORE_ID "
	cSql += " AND "
	cSql += " ( " 	
	//Todos os scorecards que o usuário recebeu permissão.
	cSql += "	( A.TIPOUSER = ' ' AND  A.USERID = '" + cIDUser + "' ) "
	cSql += " OR " 	
	//Todos os scorecards que os grupos que o usuário pertence receberam permissão.  
	cSql += " 	( A.TIPOUSER = 'G' AND A.USERID IN ( SELECT C.PARENTID  FROM SGI002B C WHERE  C.IDUSUARIO = '" + cIDUser + "' AND C.D_E_L_E_T_ = ' ' ) ) 
	cSql += " ) "
	cSql += " AND "
	cSql += "	A.D_E_L_E_T_ = ' ' "
	cSql += " AND 
	cSql += "	B.D_E_L_E_T_ = ' ' "
	
	cSql += " UNION  "
	
	cSql += " ( "
	cSql += "	SELECT "
	cSql += "		ID ID, "   
	cSql += "		NOME NOME, "
	cSql += "		TIPOSCORE TIPOSCORE "
	cSql += "	FROM  "
	cSql += "		SGI010 "
	cSql += "	WHERE "
	//Todos os scorecards que o usuário é responsável. 
	cSql += "		RESPID = '" + cIDUser + "' "
	cSql += "	AND " 
	cSql += "		D_E_L_E_T_ = ' ' "
	cSql += " ) "
	
	cSql += " ORDER BY NOME "
	
	dbUseArea(.T., "LOCAL", tcGenQry(,, changeQuery(cSql) ), cAlias, .F., .T.)
	
	DBSelectArea(cAlias)
	
	While !(cAlias)->(Eof())
		aAdd(aScorecard, { (cAlias)->ID, (cAlias)->NOME, (cAlias)->TIPOSCORE } )		
		(cAlias)->(Dbskip())
	EndDo
	
	DBCloseArea()

Return aScorecard   
  
/**
Lista dos scorecards que o usuário recebeu direito de visualizar.
@Param (Lógico) cUserId  ID do usuário.
@Return	(Array) aScorCards  Lista contendo os scorecards que o usuário pode acessar.
@See A pesquisa recursiva considera que o responsável do scorecard tem acesso aos filhos.
*/             
method aRecursiveSearch( cIDUser ) class TKPI010A  

	local aGrupos 		:= ::oOwner():oGetTable("GRPUSUARIO"):aGroupsByUser( cIDUser )
	local oScorecard 	:= ::oOwner():oGetTable("SCORECARD")
	local aScorecard 	:= {}
	Local aScoXRegra	:= {}
	local cFilter		:= "" 
	local nCount		:= 0
    //Posicionamento da tabela.
	local aPosicao		:= {}
	 
	//Guarda a posição original da tabela de scorecards.  
	aPosicao := oScorecard:SavePos()

    //Cria a expressão SQL que será utilizada como filtro considerando o acessos do usuário e do grupo.
	cFilter := "(TIPOUSER <> 'G' AND USERID = '" + cIDUser +"')"    
   
	if len(aGrupos) == 1					
		cFilter += " OR (TIPOUSER = 'G' AND USERID ='" +  aGrupos[1] + "')"			
	elseif len(aGrupos) > 1
		
		cFilter += " OR (TIPOUSER = 'G' AND USERID IN ("
		
		for nCount:= 1 to len(aGrupos)            
			
			if nCount > 1
				cFilter += ","
			endif 
			
			cFilter += "'" + aGrupos[nCount] + "'"
			  				
		next nCount
		
		cFilter += "))"			
	endif
	       
	//Ordena por USERID.
	::SetOrder(2) 
	//Aplica a expressão de filtro criada anteriormente.
	::cSQLFilter(cFilter) 
	::lFiltered(.t.)
	::_First()
	
	while(!::lEof())  
		        
		If( oScorecard:lSeek( 1 , { ::cValue("SCORE_ID") } ))  
			//Recupera o nome do scorecard da tabela de scorecards.
			aadd(aScorecard, { alltrim(::cValue("SCORE_ID")), alltrim(oScorecard:cValue("NOME")), alltrim(oScorecard:cValue("TIPOSCORE")) } )
		EndIf										             

		::_Next()			
	enddo 
	
	::cSQLFilter("") 	
   
	//Lista contendo ID e NOME dos scorecards e filhos que o usuário é responsável.
	oScorecard:aScoXResponsavel(cIDUser, aScorecard, .T.)

	//Restaura a posição original da tabela de scorecards.
    oScorecard:RestPos(aPosicao)

    //Remove duplicidade na lista de retorno.	 
    aBIDelDuplicado(aScorecard)   
    
    //Retorna a lista detalhada [ID, Nome] por ordem de nome do scorecard.      
	aSort(aScorecard,,,{ |x,y| Upper(x[2]) < Upper(y[2])})

Return aScorecard

/**
Retorna a lista de Scorecards que o Grupo recebeu direito de visualizar
@param (Caracter) ID do grupo.
@return (Array) Lista de scorecards que o grupo possui acesso. 
*/
method aScorxGrp(cGrupoId) class TKPI010A
	local aScorCards 	:= {}
	local cFilter		:= "" 
		                     
	cFilter := "TIPOUSER = 'G' AND USERID = '" + cGrupoId + "'"		
	::SetOrder(2)
	::cSQLFilter(cFilter) // Filtra pelo parametro passado
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		aadd(aScorCards,alltrim(::cValue("SCORE_ID")))
		::_Next()
	enddo
	::cSQLFilter("") // Encerra filtro	

return aScorCards

/**
Retorna a lista de Usuarios que receberam direito de visualizar o scorecard.
@param (Caracter) ID do grupo.
@return (Array)  lista de Usuarios que receberam direito de visualizar o scorecard. 
*/
method aUsuxScor(cScorId) class TKPI010A
	local oUser 	:= ::oOwner():oGetTable("USUARIO")   
	local oUserGrp	:= ::oOwner():oGetTable("GRPUSUARIO") 
	local aUserGrp	:= {} 
	local aUsuarios := {} 
	local i			:= 0
 
	//Gera o no de detalhes
	::cSQLFilter("SCORE_ID = '"+cScorId+"'")
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		if( !(alltrim(::cValue("ID")) == "0"))          
			if ::cValue("TIPOUSER") == "G" 
				aUserGrp := oUserGrp:aUsersByGroup(::cValue("USERID"))
				for i := 1 to len(aUserGrp)
					if (oUser:lSeek(1,{aUserGrp[i]}))
						aAdd(aUsuarios,{oUser:cValue("ID"),oUser:cValue("NOME"),TIPO_GRUPO})
					endif
				next i
			else
				if (oUser:lSeek(1,{::cValue("USERID")}))
					aAdd(aUsuarios,{oUser:cValue("ID"),oUser:cValue("NOME"),TIPO_USUARIO})
				endif
			endif
		endif
		::_Next()		
	end
	::cSQLFilter("")
	
return aUsuarios

/**
Insere registro.
@param (Caracter) cUserID ID do usuário.  
@param (Array) aSco Array de scorecards. 
@param (cTipoUser) cTipo Tipo do usuário.  
@return (Numérico) Status da operação. 
*/
method nInsFromXML(cUserID,aSco,cTipoUser) class TKPI010A
	local aFields	:= {}
	local nInd		:= 0
	local nStatus 	:= KPI_ST_OK
	default cTipoUser := " "
	// Grava
	for nInd := 1 to len(aSco)
		aFields := {}
		aAdd( aFields, {"ID"		,	::cMakeID()	} )
		aAdd( aFields, {"SCORE_ID"	, 	aSco[nInd]	} )	
		aAdd( aFields, {"TIPOUSER"	, 	cTipoUser	} )	
		aAdd( aFields, {"USERID"	, 	cUserID} )	
			
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE				
			endif
			exit
		endif
	next
	
return nStatus

/**
Remove registros.
@param (Caracter) cID ID da entidade.  
@param (Caracter) cTipo Tipo do usuário.  
@return (Numérico) Status da operação. 
*/
method nDelFromXML(cId, cTipo) class TKPI010A
	local nStatus := KPI_ST_OK 
	local cFilter := "" 
	default cTipo := " "
	
	if ! empty(alltrim(cId)) .and. ! (alltrim(cId) == "0")
		if cTipo == "G"           	
			cFilter := " USERID = '" + padr(cId,10) + "' AND TIPOUSER = 'G'"
		else
			cFilter := " USERID = '" + padr(cId,10) + "' AND TIPOUSER <>'G'"
		endif
		
		::cSQLFilter(cFilter)
		::lFiltered(.t.)
		::_First()
		while(!::lEof())
			if(nStatus == KPI_ST_OK)
				if(!::lDelete())
					nStatus := KPI_ST_INUSE
					exit
				endif
		    endif
			::_Next()		
		end
		::cSQLFilter("")	
	else
		nStatus := KPI_ST_BADID
	endif
return nStatus


function _KPI010A_ScorXuser()
return nil