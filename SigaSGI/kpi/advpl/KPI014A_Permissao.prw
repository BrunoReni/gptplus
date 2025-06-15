// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI014A_Permissao
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 16.12.05 | Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI014A_Permissao.ch"
/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->TKPI014A
Container principal do sistema, contém todos os elementos.
@entity: Projeto
@table KPI014A
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "PERM_PROJETO"
#define TAG_GROUP  "PERM_PROJETOS"
#define TEXT_ENTITY STR0001
#define TEXT_GROUP  STR0002

class TKPI014A from TBITable
	method New() constructor
	method NewKPI014A()

	method oToXMLRecList(cCmdSQL)
	method oToXMLProjxUsu(cProjID)	//retorna a lista de Projetos que o Usuario recebeu direito de alterar
	method oToXMLList(cParentID) 
	method nUpdFromArray(aUserPerm,cProjID)//Faz a atualização dos registros a partir do array.

	method nInsFromXML(aFields)
	method nDelFromXML(cProjID)
	
endclass
	
method New() class TKPI014A
	::NewKPI014A()
return

method NewKPI014A() class TKPI014A

	// Table
	::NewTable("SGI014A")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"			,"C",	010))
	::addField(TBIField():New("PROJ_ID"		,"C",	010))
	::addField(TBIField():New("USERID"		,"C",	010))//Usuario Autorizado a visualizar

	// Indexes
	::addIndex(TBIIndex():New("SGI014AI01",{"ID"},	.t.))
	::addIndex(TBIIndex():New("SGI014AI02",{"USERID"}, .f.))
	::addIndex(TBIIndex():New("SGI014AI03",{"PROJ_ID","USERID"}, .f.))

return

/*
Retorna a lista dos usuario autorizados a alterar o projeto.
Lista XML para anexar ao pai
*/
method oToXMLList(cParentID) class TKPI014A
	local oNode, oAttrib, oXMLNode, nInd, nRespId //,cTipoPessoa
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0003)  //"Nome"
	oAttrib:lSet("CLA000", KPI_STRING)

	oAttrib:lSet("TAG001", "CARGO")
	oAttrib:lSet("CAB001", STR0004)  //"Cargo"
	oAttrib:lSet("CLA001", KPI_STRING)

	// Gera recheio
	::cSQLFilter("PROJ_ID = '"+cBIStr(cParentID)+"'") // Filtra pelo pai
	::setOrder(2)
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"ID", "AUTENTIC","CARGO","FONE","RAMAL","EMAIL", "ADMIN", "USERPROT", "COMPNOME", "FEEDBACK"})
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1]=="PROJ_ID")
				aFields[nInd][1] := "ID"
			endif
			if(aFields[nInd][1]=="ID")
				nRespId := aFields[nInd][2]
			endif
			//if(aFields[nInd][1]=="TIPOPESSOA")
			//	cTipoPessoa := aFields[nInd][2]
			//endif
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		// Virtuais
		//if(cTipoPessoa=="G")
		//	oTable := ::oOwner():oGetTable("PGRUPO")
		//	oTable:lSeek(1, {nRespId})
		//	oNode:oAddChild(TBIXMLNode():New("NOME", oTable:cValue("NOME")))
		//	oNode:oAddChild(TBIXMLNode():New("CARGO", ""))
		//else
			oTable := ::oOwner():oGetTable("USUARIO")
			oTable:lSeek(1, {nRespId})
			oNode:oAddChild(TBIXMLNode():New("NOME", oTable:cValue("NOME")))
			oNode:oAddChild(TBIXMLNode():New("CARGO", oTable:cValue("CARGO")))
		//endif
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro

return oXMLNode

//retorna a lista de Usuario que podem alterar o projeto
method oToXMLProjxUsu(cProjId) class TKPI014A
	local oAttrib, oXMLNode
	local oUsuario	:= ::oOwner():oGetTable("USUARIO")

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
	::lSoftSeek(3,{cProjId})
	while(!::lEof() .and. ::cValue("PROJ_ID") == cProjId ) 
		if( !(alltrim(::cValue("ID")) == "0"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			oNode:oAddChild(TBIXMLNode():New("ID", ::cValue("USERID")))

			if (oUsuario:lSeek(1,{::cValue("USERID")}))
				oNode:oAddChild(TBIXMLNode():New("NOME"	, oUsuario:cValue("NOME")))
			endif
		endif

		::_Next()
	enddo

return oXMLNode


/*
*Faz a atualizacao dos registros.
*/
method nUpdFromArray(aUserPerm,cProjID) class TKPI014A
	local 	nStatus 	:= KPI_ST_OK
	local 	nFoundItem	:= {}
	local 	aItemOk 	:= {} 
	local	nItem 		:= 0
	private nPosID		:= 0

	//Verificando qual e a posicao do campo ID
    aeval(aUserPerm, { |aValue| nPosID := ascan(aValue, {|x| x[1] == "ID"})})

	::cSQLFilter("PROJ_ID = '" + cProjID + "'")
	::lFiltered(.t.)
	::_First()

	while(!::lEof())
		
		nFoundItem := ascan(aUserPerm, {|aVal| alltrim(aVal[nPosID,2]) == alltrim(::cValue("USERID"))})
		
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

	for nItem := 1 to len(aUserPerm)
		nFoundItem := ascan(aItemOk , {|x| x == nItem})
		if nFoundItem == 0
			//Nao esta no array de itemOk Inclui.
			::nInsFromXML(aUserPerm[nItem])
		endif
	next nItem

return nStatus
		
//Insere nova entidade
method nInsFromXML(aFields) class TKPI014A
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
method nDelFromXML(cId, cTipo) class TKPI014A
	local nStatus := KPI_ST_OK //, oTableChild
	
	if !empty(alltrim(cId)) .and. !(alltrim(cId)=="0")
		//"P" Se for id de um projeto / "U" Se for id de um usuario
		if(alltrim(cTipo) == "P")
			::cSQLFilter(" PROJ_ID = '" + padr(cId,10) + "'")
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
		elseif(alltrim(cTipo) == "U")
			::cSQLFilter(" USERID = '" + padr(cId,10) + "'")
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
		endif
		::cSQLFilter("")	
	else
		nStatus := KPI_ST_BADID
	endif
return nStatus

function _KPI014A_Permissao()
return nil