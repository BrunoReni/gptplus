// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI002A_UsuGru.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 10.03.04 | 1645 Leandro Marcelino Santos
// 22.08.05 | 1776 Alexandre Alves da Silva - Importado para uso no KPI.
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI002b_UsuGru.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->TKPI002A
@entity Usuario x Grupo
Usuarios do sistema KPI.
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "GRPUSUARIO"
#define TAG_GROUP  "GRPUSUARIOS"
#define TEXT_ENTITY STR0001/*//"Usuário x Grupo"*/
#define TEXT_GROUP  STR0002/*//"Usuários x Grupos"*/

class TKPI002B from TBITable
	method New() constructor
	method NewKPI002B() 
	method oToXMLUsersByGroup(nIDGrupo)
	method oToXMLGroupsByUser(nUserID)
	method nUpdFromXML(oXML,cPath,cParentID)
	method aUsersByGroup(nIDGrupo)
	method aGroupsByUser(nUserID)
	method oToXMLList(nIDGrupo)	
	method nDelFromXML(cId, cTipo)
endclass

	
method New() class TKPI002B
	::NewKPI002B()
return
   

method NewKPI002B() class TKPI002B
	::NewTable("SGI002B")
	::cEntity(TAG_ENTITY)

	::addField(TBIField():New("ID"				,"C",10))
	::addField(TBIField():New("PARENTID"		,"C",10))
	::addField(TBIField():New("IDUSUARIO"		,"C",10))

	::addIndex(TBIIndex():New("SGI002BI01",	{"ID"},.t.))
	::addIndex(TBIIndex():New("SGI002BI02",	{"IDUSUARIO","PARENTID"}, .t.))
	::addIndex(TBIIndex():New("SGI002BI03",	{"PARENTID","IDUSUARIO"}, .t.))
return

// Lista todos os usuarios de um grupo, devolve array de IDs
method aUsersByGroup( nIDGrupo ) class TKPI002B
	local aUsuarios := {}
	
	::SetOrder(1)    
	::cSQLFilter("PARENTID = '" + cBIStr(nIDGrupo) + "'")
	::lFiltered(.t.)
	::_First()
	while(!::lEof()) 
		aAdd(aUsuarios, ::cValue("IDUSUARIO") )
		::_Next()
	end
	::cSQLFilter("") 
return aUsuarios
                     

// Lista todos os grupos que um usuario esta inserido, devolve array de IDs
method aGroupsByUser(cUserID) class TKPI002B
	local aGrupos := {}
	 
	::cSQLFilter("IDUSUARIO = '" + cBIStr(cUserID) + "'") 
	::lFiltered(.t.)
	::_First()
	while(!::lEof()) 
		aAdd(aGrupos, ::cValue("PARENTID"))
		::_Next()
	end
	::cSQLFilter("") 
return aGrupos
             

// Lista XML com todos os usuarios de um grupo
method oToXMLUsersByGroup(nIDGrupo) class TKPI002B
	Local oNode		:= Nil
	Local oXMLNode  := Nil
	Local oUsuario 	:= ::oOwner():oGetTable("USUARIO")    
    Local oAttrib 	:= TBIXMLAttrib():New()
		
	oUsuario:SetOrder(1) 

	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", "USUARIOS")
	oAttrib:lSet("NOME", "Usuario")  
	
	oXMLNode :=	TBIXMLNode():New("USUARIOS","",oAttrib)

	::cSQLFilter("PARENTID = '" + cBIStr( nIDGrupo ) + "'") 
	::lFiltered(.t.)
	::_First() 
	
	while(!::lEof()) 
		oUsuario:lSeek(1,{::nValue("IDUSUARIO")})
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", oUsuario:nValue("PARENTID"))
		oAttrib:lSet("NOME", alltrim(oUsuario:cValue("NOME")))
		oNode:oAddChild(TBIXMLNode():New("USUARIO", "", oAttrib))
		::_Next()
	end         
	
	::cSQLFilter("") 
return oXMLNode
          

// Lista XML com todos os grupos de um usuario
method oToXMLGroupsByUser(nUserID) class TKPI002B
	Local oNode		:= Nil
	Local oAttrib 	:= TBIXMLAttrib():New()
	Local oXMLNode  := Nil	    
	Local oGrupo 	:= ::oOwner():oGetTable("GRUPO")   
	
	oGrupo:SetOrder(1) 

	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", "GRUPOS")
	oAttrib:lSet("NOME", "Grupo")
	oXMLNode :=	TBIXMLNode():New("GRUPOS","",oAttrib)

	::cSQLFilter("IDUSUARIO = '" + cBIStr(::nValue(nUserID)) + "'")
	::lFiltered(.t.)
	::_First()     
	
	while(!::lEof()) 
		oGrupo:lSeek(1,{::nValue("PARENTID")})
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", oGrupo:nValue("PARENTID"))
		oAttrib:lSet("NOME", alltrim(oGrupo:cValue("NOME")))
		oNode:oAddChild(TBIXMLNode():New("GRUPO", "", oAttrib))
		::_Next()
	end      
	
	::cSQLFilter("")
return oXMLNode
                 

// Lista XML para anexar ao pai
method oToXMLList(nIDGrupo) class TKPI002B
	Local oNode			:= Nil
	Local oAttrib		:= TBIXMLAttrib():New()
	Local oXMLNode		:= Nil
	Local nUsuario      := 1
	Local oUsuario     	:= ::oOwner():oGetTable("USUARIO")
	Local aUsuarios 	:= {}

	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .F.) 
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", KPI_STRING)   

	oXMLNode 	:= TBIXMLNode():New(TAG_GROUP,,oAttrib)
	aUsuarios 	:= aClone(::oOwner():oGetTable("GRPUSUARIO"):aUsersByGroup( nIDGrupo ) ) 
  
  	For nUsuario := 1 To Len( aUsuarios )    
  		If ( oUsuario:lSeek(1, {aUsuarios[nUsuario] } ) )   
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))   
			oNode:oAddChild(TBIXMLNode():New("ID"		, oUsuario:cValue("ID"))) 
  			oNode:oAddChild(TBIXMLNode():New("NOME"		, oUsuario:cValue("NOME"))) 
  	   	EndIf 
  	Next nUsuario                      
Return oXMLNode
 

method nUpdFromXML(oXML,cPath,cParentID) class TKPI002B
	local nStatus 	:= KPI_ST_OK
	local nInd 		:= 0
	private oXMLInput := oXML
	
	::cSQLFilter("PARENTID = '"+ cParentID + "'") 
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		::lDelete()
		::_Next()
	enddo
	::cSQLFilter("")

	if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_GRPUSUARIOS"), "_GRPUSUARIO"))!="U")
		if(valtype(&("oXMLInput:"+cPath+":_GRPUSUARIOS:_GRPUSUARIO"))=="A")
			for nInd := 1 to len(&("oXMLInput:"+cPath+":_GRPUSUARIOS:_GRPUSUARIO"))

				aGrpUsuario := &("oXMLInput:"+cPath+":_GRPUSUARIOS:_GRPUSUARIO["+cBIStr(nInd)+"]")

				::lAppend({	{"ID"		,::cMakeID()}, ;
							{"PARENTID"	,cParentID}, ;
							{"IDUSUARIO",cBIStr(aGrpUsuario:_ID:TEXT)}})
					
			next	
		elseif(valtype(&("oXMLInput:"+cPath+":_GRPUSUARIOS:_GRPUSUARIO"))=="O")
			aGrpUsuario := &("oXMLInput:"+cPath+":_GRPUSUARIOS:_GRPUSUARIO")
			
			::lAppend({ 	{"ID"		, ::cMakeID()},;
							{"PARENTID"	, cParentID},;
							{"IDUSUARIO", cBIStr(aGrpUsuario:_ID:TEXT)}})
		endif
	endif     
return nStatus
             

method nDelFromXML(cId, cTipo) class TKPI002B
	Local nStatus 	:= KPI_ST_OK
	Local cQuery 	:= ""
	Local cMsg 		:= ""
                                                                      
 	if ( ! (alltrim(cId)=="0"))
 		if(cTipo == "U")
			cQuery:="DELETE FROM KPI002B WHERE IDUSUARIO = '"+padr(cId,10)+"'"
		elseif(cTipo == "G")
			cQuery:="DELETE FROM KPI002B WHERE PARENTID = '"+padr(cId,10)+"'"
		endif
		TCSQLEXEC(cBIParseSQL(cQuery, @cMsg))
		TCREFRESH("KPI002B")
	else
		nStatus := KPI_ST_BADID
 	endif
return nStatus

function _KPI002A_UsuGru()
return nil