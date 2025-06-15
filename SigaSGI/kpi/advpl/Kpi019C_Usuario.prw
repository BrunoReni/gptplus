// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI019C_Usuario
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 03.01.07 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI019C_Usuario.ch"
/*--------------------------------------------------------------------------------------
Pacotes, Permissão por usuário
@entity: Pacote
@table KPI019C
------------------------------------------------------------	--------------------------*/
#define TAG_ENTITY "PACOTEXUSER"
#define TAG_GROUP  "PACOTEXUSERS"
#define TEXT_ENTITY STR0001 //"Permissão de usuário"
#define TEXT_GROUP  STR0002 //"Permissão de usuários"

class TKPI019C from TBITable
	method New() constructor
	method NewKPI019C()
   
	method oToXMLList(cUserId)
	method nInsFromXML(aFields	)
	method nDelFromXML(cPacID) 
	method nUpdFromArray(aUserPerm,cPacID)
	
	method oToXMLPacxUsu(cPacId)
endclass
	
method New() class TKPI019C
	::NewKPI019C()
return

method NewKPI019C() class TKPI019C

	// Table
	::NewTable("SGI019C")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"			,"C",	010))
	::addField(TBIField():New("PACOTE_ID"	,"C",	010))
	::addField(TBIField():New("USER_ID"		,"C",	010))

	// Indexes
	::addIndex(TBIIndex():New("SGI019CI01",{"ID"},	.t.))
	::addIndex(TBIIndex():New("SGI019CI02",{"USER_ID"}, .f.))
	::addIndex(TBIIndex():New("SGI019CI03",{"PACOTE_ID","USER_ID"}, .f.))

return


//retorna a lista de pacotes filtrado por usuario
method oToXMLList(cUserId) class TKPI019C
	local oAttrib, oXMLNode
	local oPacote	 	:= ::oOwner():oGetTable("PACOTE")
	local cUserAtual 	:= ::oOwner():foSecurity:oLoggedUser()
	default cUserID 	:= cUserAtual::cValue("ID")
	
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
    
    //Caso seja admin exibi todos os pacotes
    if cUserAtual:lValue("ADMIN") 
		//Gera o no de detalhes
		oPacote:SetOrder(2)
		oPacote:_First()
		while(!oPacote:lEof())
			if( !(alltrim(oPacote:cValue("ID")) == "0"))
				oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))   
				oNode:oAddChild(TBIXMLNode():New("ID", oPacote:cValue("ID")))
				oNode:oAddChild(TBIXMLNode():New("NOME"	, oPacote:cValue("NOME")))
			endif			
		oPacote:_Next()		
		enddo
    else
		//Gera o no de detalhes
		::SetOrder(2)
		::lSoftSeek(2,{cUserId})
		while(!::lEof() .and. ::cValue("USER_ID") == cUserId ) 
			if( !(alltrim(::cValue("ID")) == "0"))
				oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
				oNode:oAddChild(TBIXMLNode():New("ID", ::cValue("PACOTE_ID")))
	
				if (oPacote:lSeek(1,{::cValue("PACOTE_ID")}))
					oNode:oAddChild(TBIXMLNode():New("NOME"	, oPacote:cValue("NOME")))
				endif
			endif
	
			::_Next()
		enddo
    endif
return oXMLNode


//retorna a lista de usuarios com permissão ao pacote
method oToXMLPacxUsu(cPacId) class TKPI019C
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
	::lSoftSeek(3,{cPacId})
	while(!::lEof() .and. ::cValue("PACOTE_ID") == cPacId ) 
		if( !(alltrim(::cValue("ID")) == "0"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			oNode:oAddChild(TBIXMLNode():New("ID", ::cValue("USER_ID")))

			if (oUsuario:lSeek(1,{::cValue("USER_ID")}))
				oNode:oAddChild(TBIXMLNode():New("NOME"	, oUsuario:cValue("NOME")))
			endif
		endif

		::_Next()
	enddo

return oXMLNode


/*
*Faz a atualizacao dos registros.
*/
method nUpdFromArray(aUserPerm,cPacID) class TKPI019C
	local 	nStatus 	:= KPI_ST_OK
	local 	nFoundItem	:= {}
	local 	aItemOk 	:= {} 
	local	nItem 		:= 0
	private nPosID		:= 0

	//Verificando qual e a posicao do campo ID
    aeval(aUserPerm, { |aValue| nPosID := ascan(aValue, {|x| x[1] == "ID"})})

	::cSQLFilter("PACOTE_ID = '" + cPacID + "'")
	::lFiltered(.t.)
	::_First()

	while(!::lEof())
		
		nFoundItem := ascan(aUserPerm, {|aVal| alltrim(aVal[nPosID,2]) == alltrim(::cValue("USER_ID"))})
		
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
method nInsFromXML(aFields) class TKPI019C
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
method nDelFromXML(cPacId) class TKPI019C
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

function _KPI019C_Usuario()
return nil