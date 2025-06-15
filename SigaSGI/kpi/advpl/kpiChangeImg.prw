// ######################################################################################
// Projeto: KPI
// Modulo : Alteração de imagem 
// Fonte  : KPICHANGEIMG.PRW
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 21.09.07 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"


#define TAG_ENTITY "KPICHANGEIMG"
#define TAG_GROUP  "KPICHANGEIMGS"
#define TEXT_ENTITY "Imagem"
#define TEXT_GROUP  "Imagem"

class TKPIChangeImg from TBITable
	method New() constructor
	method NewKPIChangeImg()

	method oToXMLNode(nParentID)
	method nExecute(cID, cExecCMD)
	method writeFile(cContentFile,cNameFile)    
	method delFile(cNameFile)
	method moveFile(cNameFile, cPathDest)
	
endclass

method New() class TKPIChangeImg
	::NewKPIChangeImg()  
		if (getBuild() > "7.00.101202A")
	    CHMOD("web\sgi\imagens\art_logo_clie.sgi",2) // remove o atributo "Somente Leitura" do arquivo
    endif
return

method NewKPIChangeImg() class TKPIChangeImg
	::NewObject()
return
                                                                              
// Carregar
method oToXMLNode() class TKPIChangeImg  
	local oXMLNode   	:= TBIXMLNode():New(TAG_ENTITY) 
	local oUser		 	:= oKpiCore:foSecurity:oLoggedUser()                                                                 
	local lIsAdmin	 	:= oUser:lValue("ADMIN")
	
	oXMLNode:oAddChild(TBIXMLNode():New("ISADMIN",if(lIsAdmin,"T","F")))
return oXMLNode


// Execute
method nExecute(cID, cExecCMD) class TKPIChangeImg    
	local cPath := ::oOwner():cKpiPath()
	local oFile := TBIFileIO():New(cPath + "\imagens\art_logo_clie_bkp.sgi" )  
	local nStatus := KPI_ST_OK
	if oFile:lCopyFile( "art_logo_clie.sgi", cPath + "\imagens\")
		::lClose()
	endif
return nStatus


function _KPICHANGEIMG()
return nil