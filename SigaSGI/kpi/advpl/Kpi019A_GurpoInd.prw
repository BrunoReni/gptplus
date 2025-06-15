// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI019A_GrupoInd
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 03.01.07 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "Kpi019A_GurpoInd.ch"
/*--------------------------------------------------------------------------------------
Pacotes, Permissão por grupo de indicadores
@entity: Pacote
@table KPI019A
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "PACOTEXGRPIND"
#define TAG_GROUP  "PACOTEXGRPINDS"
#define TEXT_ENTITY STR0001 //"Grupo de Indicador"
#define TEXT_GROUP  STR0002 //"Grupo de Indicadores"

class TKPI019A from TBITable
	method New() constructor
	method NewKPI019A()

	method nInsFromXML(aFields)
	method nDelFromXML(cProjID) 
	method nUpdFromArray(aUserPerm,cPacID)
	
	method oToXMLPacxGrpInd(cPacId)  
	method aGrpIndFilter(cPacId)
endclass
	
method New() class TKPI019A
	::NewKPI019A()
return

method NewKPI019A() class TKPI019A

	// Table
	::NewTable("SGI019A")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"			,"C",	010))
	::addField(TBIField():New("PACOTE_ID"	,"C",	010))
	::addField(TBIField():New("GRPIND_ID"	,"C",	010))

	// Indexes
	::addIndex(TBIIndex():New("SGI019AI01",{"ID"},	.t.))
	::addIndex(TBIIndex():New("SGI019AI02",{"GRPIND_ID"}, .f.))
	::addIndex(TBIIndex():New("SGI019AI03",{"PACOTE_ID","GRPIND_ID"}, .f.))

return


//retorna a lista do grupo de indicadores com permissão ao pacote
method oToXMLPacxGrpInd(cPacId) class TKPI019A
	local oAttrib, oXMLNode
	local oGrpInd := ::oOwner():oGetTable("GRUPO_IND")

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

	//Gera o no de detalhes
	::SetOrder(3)
	::lSoftSeek(3,{cPacId})
	while(!::lEof() .and. ::cValue("PACOTE_ID") == cPacId ) 
		if( !(alltrim(::cValue("ID")) == "0"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			oNode:oAddChild(TBIXMLNode():New("ID", ::cValue("GRPIND_ID")))

			if (oGrpInd:lSeek(1,{::cValue("GRPIND_ID")}))
				oNode:oAddChild(TBIXMLNode():New("NOME"	, oGrpInd:cValue("NOME")))
			endif
		endif

		::_Next()
	enddo

return oXMLNode


/*
*Faz a atualizacao dos registros.
*/
method nUpdFromArray(aPerm,cPacID) class TKPI019A
	local 	nStatus 	:= KPI_ST_OK
	local 	nFoundItem	:= {}
	local 	aItemOk 	:= {} 
	local	nItem 		:= 0
	private nPosID		:= 0

	//Verificando qual e a posicao do campo ID
    aeval(aPerm, { |aValue| nPosID := ascan(aValue, {|x| x[1] == "ID"})})

	::cSQLFilter("PACOTE_ID = '" + cPacID + "'")
	::lFiltered(.t.)
	::_First()

	while(!::lEof())
		
		nFoundItem := ascan(aPerm, {|aVal| alltrim(aVal[nPosID,2]) == alltrim(::cValue("GRPIND_ID"))})
		
		if(nFoundItem > 0)
			aadd(aItemOk, nFoundItem)
		endif			
		
		if(nFoundItem == 0)
			//Nao encontrou no XML apaga.
			if(!::lDelete())
				nStatus := KPI_ST_INUSE
				exit							
			endif
		else
			//Encontrou atualiza.
		endif    
		
		::_Next()
	end
	::cSQLFilter("")

	for nItem := 1 to len(aPerm)
		nFoundItem := ascan(aItemOk , {|x| x == nItem})
		if nFoundItem == 0
			//Nao esta no array de itemOk Inclui.
			::nInsFromXML(aPerm[nItem])
		endif
	next nItem

return nStatus
		
//Insere nova entidade
method nInsFromXML(aFields) class TKPI019A
	local nStatus := KPI_ST_OK

	// Grava
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	endif
	
return nStatus

// Excluir entidade do server
method nDelFromXML(cPacId) class TKPI019A
	local nStatus := KPI_ST_OK 
	
	if !empty(alltrim(cPacId)) .and. !(alltrim(cPacId)=="0")
			::cSQLFilter(" PACOTE_ID = '" + padr(cPacId,10) + "'")
			::lFiltered(.t.)
			::_First()
			// Deleta o elemento
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

//retorna uma array com ID do grupo de indicadores filtrados pelo pacote
method aGrpIndFilter(cPacId) class TKPI019A
	local aFilter := {}

	//Gera o no de detalhes
	::SetOrder(3)
	::lSoftSeek(3,{cPacId})
	while(!::lEof() .and. ::cValue("PACOTE_ID") == cPacId ) 
		if( !(alltrim(::cValue("ID")) == "0"))
        	aAdd(aFilter,::cValue("GRPIND_ID"))
		endif
		::_Next()
	enddo

return aFilter

function _KPI019A_GrupoInd()
return nil