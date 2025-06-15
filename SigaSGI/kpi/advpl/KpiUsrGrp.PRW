// #######################################################################################
// Projeto: KPI
// Modulo : SGI
// Fonte  : TKPIUSRGRP.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 			| 
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"        
#include "KpiUsrGrp.ch"

class TKPIUSRGRP from TBITable

	method New() constructor  
	method NewKPIUSRGRP()
	method oUsuGroup()        
	method oTreeUsrGrp()      
	method getMailUser(cId,cTipo)        
	method lUserInGrp(cIdUser,cIdGroup)
	
endclass	
	
method New() class TKPIUSRGRP
	::NewKPIUSRGRP() 
return

method NewKPIUSRGRP() class TKPIUSRGRP
return

method oUsuGroup() class TKPIUSRGRP

	Local oNode		:= TBIXMLNode():New("RESPONSAVEIS")
	Local oTabUsr 	:= ::oOwner():oGetTable("USUARIO")  
	Local oTabGrp 	:= ::oOwner():oGetTable("GRUPO")  
	Local oNodeAux 
	Local oNodeResp
	Local oNodeUsr
	Local oNodeGrp
	Local nX     

	oNodeAux := oTabUsr:oToXMLList()
	for nX := 1 To oNodeAux:nChildCount() 
		oNodeUsr := oNodeAux:oChildByPos(nX)
   		
  		oNodeResp := TBIXMLNode():New("RESPONSAVEL")
		oNodeResp:oAddChild(TBIXMLNode():New("ID"	,"U"+oNodeUsr:oChildByName("ID"):cGetValue()))
		oNodeResp:oAddChild(TBIXMLNode():New("NOME"	,oNodeUsr:oChildByName("NOME"):cGetValue()))

		oNode:addChild(oNodeResp)
	next
                                    
	oNodeAux := oTabGrp:oToXMLList()
	for nX := 1 To oNodeAux:nChildCount()
		oNodeGrp := oNodeAux:oChildByPos(nX)
   		
  		oNodeResp := TBIXMLNode():New("RESPONSAVEL")
		oNodeResp:oAddChild(TBIXMLNode():New("ID"	,"G"+oNodeGrp:oChildByName("ID"):cGetValue()))
		oNodeResp:oAddChild(TBIXMLNode():New("NOME"	,oNodeGrp:oChildByName("NOME"):cGetValue()))

		oNode:addChild(oNodeResp)
	next

Return oNode                               
            

method oTreeUsrGrp() class TKPIUSRGRP   

	local oTabUsr		:= ::oOwner():oGetTable("USUARIO")
	local oTabGrp		:= ::oOwner():oGetTable("GRUPO")     
	local oAttrib 		:= TBIXMLAttrib():New()      
	local oXMLRootUsr	:= nil

	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("NOME", STR0001)///*Responsável*/
	oAttrib:lSet("ID", "0")
	oAttrib:lSet("TIPO", "TREEUSERS")
	oAttrib:lSet("IMAGE", KPI_IMG_PASTINHA)      
      
	oXMLRootUsr := TBIXMLNode():New("TREEUSERS","",oAttrib)

	oXMLRootUsr:oAddChild(oTabUsr:oAllUsers("U"))
	oXMLRootUsr:oAddChild(oTabGrp:oAllGroups("G"))

return oXMLRootUsr           

           
/*
	Retorna uma string com os e-mails de todos os usuarios
	@param - cId: 	ID do usuario/grupo
	@param - cTipo:	Tipo de ID (U = Usuario / G = Grupo)
*/
method getMailUser(cId, cTipo) class TKPIUSRGRP
	Local oUsuario 	:= ::oOwner():oGetTable("USUARIO")
	Local oGrupoUsr	:= Nil
	Local cRet		:= ""  
	Local cMail		:= ""
	Local aRet		:= {}
	Local nI		:= 0

	Default cTipo := "U" // Por padrão é considerado que é usuário.

	// Verifica se é usuário ou grupo de usuários.
	If cTipo == TIPO_USUARIO
        aAdd(aRet, cId)
	ElseIf cTipo == TIPO_GRUPO
		oGrupoUsr := ::oOwner():oGetTable("GRPUSUARIO")
		aRet := oGrupoUsr:aUsersByGroup(cId) //ID do Grupo.
	EndIf

	// Varredura nos usuários/grupos.
	For nI := 1 To Len(aRet)
		If oUsuario:lSeek(1,{aRet[nI]})
			cMail := AllTrim(oUsuario:cValue("EMAIL"))

			If !Empty(cRet) .And. !Empty(cMail)
				cRet += ','
			EndIf

			cRet += cMail
	    EndIf
	Next

Return cRet                  

/*
	Verifica se o usuario pertence ao grupo
	@param - cIdUser	- ID do usuario
	@param - cIdGroup	- ID do grupo de usuarios
*/                                               
method lUserInGrp(cIdUser,cIdGroup) class TKPIUSRGRP

	local oGroup	:= ::oOwner():oGetTable("GRPUSUARIO")
	local lRet 		:= .F.
    local aUsers	:= {}

    cIdUser := alltrim(cIdUser)
    cIdGroup := alltrim(cIdGroup)

	aUsers := oGroup:aUsersByGroup(cIdGroup) //array com todos os usuarios do grupo

	lRet := (aScan(aUsers, { |x| allTrim(x) == cIdUser}) > 0)

return lRet