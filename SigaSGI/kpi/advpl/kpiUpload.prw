// ######################################################################################
// Projeto: KPI
// Modulo : Controle de uploads
// Fonte  : KPIUPLOAD.PRW
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 28.11.06 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPIUpload.CH"

#define TAG_ENTITY "KPIUPLOAD"
#define TAG_GROUP  "KPIUPLOADS"
#define TEXT_ENTITY "Upload"
#define TEXT_GROUP  "Uploads"

class TKPIUpload from TBITable
	method New() constructor
	method NewKPIUpload()

	method oToXMLNode(nParentID)
	method nExecute(cID, cExecCMD)
	method writeFile(cContentFile,cNameFile)    
	method delFile(cNameFile)
	method delFileS(cNameFile)
	method moveFile(cNameFile, cPathDest)
	method moveFiles(cNameFile, cPathDest)
	
endclass

method New() class TKPIUpload
	::NewKPIUpload()
return

method NewKPIUpload() class TKPIUpload
	::NewObject()
return

// Carregar
method oToXMLNode() class TKPIUpload  
	local oXMLNode   	:= TBIXMLNode():New(TAG_ENTITY)
return oXMLNode


// Execute
method nExecute(cID, cExecCMD) class TKPIUpload    
	local aParam 	:= aBIToken(cExecCMD, "|")   
	local nStatus := KPI_ST_OK
	
	do case
		case aParam[1] == "DELFILE"
			::delFile(aParam[2])
		case aParam[1] == "DELFILES"
			::delFileS(aParam[2])
		case aParam[1] == "MOVEFILE"
			::moveFile(aParam[2],aParam[3])
		case aParam[1] == "MOVEFILES"
			::moveFileS(aParam[2],aParam[3])
	endcase	
return nStatus


/*-------------------------------------------------------------------------------------
@method writeFile(cContentFile,cNameFile)
Salvar Arquivo no Servidor  (base64)  
@cContentFile 	- Conteudo do arquivo
@cNameFile 		- Caminho e nome do arquivo 
--------------------------------------------------------------------------------------*/
method writeFile(cContentFile,cNameFile) class TKPIUpload    
	local oFile 	:= TBIFileIO():New(::oOwner():cKpiPath() + "\" + cNameFile )     
	local nStatus := KPI_ST_OK
	
	if oFile:lExists() 
		if oFile:lOpen(FO_READWRITE)              
			oFile:nGoEOF()   
			oFile:nWrite(decode64(cContentFile))
		else
			nStatus := KPI_ST_INUSE
		endif
	else 
		// Cria o arquivo 
		if ! oFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
			nStatus := KPI_ST_INUSE
			conout(STR0001) //"erro na criacao do arquivo"
		endif
		oFile:nWrite(decode64(cContentFile))
	endif
	oFile:lClose()
return nStatus


/*-------------------------------------------------------------------------------------
@method delFile(cNameFile)
Deletar arquivo no servidor
@cNameFile 	- Caminho e nome do arquivo 
--------------------------------------------------------------------------------------*/                                
method delFile(cNameFile) class TKPIUpload    
	local oFile 	:= TBIFileIO():New(::oOwner():cKpiPath() + "\" + cNameFile )     
	local nStatus := KPI_ST_OK
	
	if oFile:lExists() 
		oFile:lErase()
	endif
return nStatus

/*-------------------------------------------------------------------------------------
@method delFileS(cNameFile)
Deletar arquivos no servidor
@cNameFile 	- Caminho e nome do arquivo 
--------------------------------------------------------------------------------------*/                                
method delFileS(cNameFile) class TKPIUpload    
	local cPath		:= ::oOwner():cKpiPath()
	local cPathOri	:= ""
	local cArquivo	:= ""
	local aArquivos	:= {}
	local oFile		:= nil
	local nStatus	:= KPI_ST_OK
	local nArq		:= 0
	local nLenArq	:= 0
	local nPos		:= 0
	local lOK		:= .T.

	nPos := Rat("\",cNameFile)
	cArquivo := cNameFile
	
	While nPos > 0 
		cPathOri += AllTrim(Substr(cArquivo,1,nPos))
		cArquivo := AllTrim(Substr(cArquivo,nPos + 1))
		nPos := Rat("\",cArquivo)
	Enddo   
	
	aArquivos := Directory(cPath + cPathOri + If(Empty(cArquivo),"*.*",cArquivo))
	nLenArq := Len(aArquivos)
	nArq := 0
	
	While (nArq < nLenArq) .And. lOk
		nArq++
		oFile := TBIFileIO():New(cPath + cPathOri + aArquivos[nArq,1])
		if oFile:lExists() 
			oFile:lErase()
		endif
		oFile:Free()
	Enddo   
	
	//remove o diretorio caso nao contenha mais arquivos
	if ExistDir(cPath + cPathOri)
		aArquivos := Directory(cPath + cPathOri + "\*.*")
		If Len(aArquivos) == 0   
			If !DirRemove(cPath + cPathOri)
				cArquivo := "delFileS (kpiupload) - " + STR0002 + cPath + cPathOri //"Nao foi possivel remover o diretorio "
				conout(" ")
				conout(Replicate("*",80))
				conout(cArquivo)
				conout(Replicate("*",80))
				conout(" ")
			Endif
		Endif                        
	Endif
return nStatus


/*-------------------------------------------------------------------------------------
@method moveFile(cNameFile, cPathDest)   
Move arquivo 
@cNameFile 	- Caminho e nome do arquivo 
@cPathDest	- Caminho de destino do arquivo
--------------------------------------------------------------------------------------*/
method moveFile(cNameFile, cPathDest) class TKPIUpload    
	local cPath 	:= ::oOwner():cKpiPath()
	local oFile 	:= TBIFileIO():New(cPath + cNameFile )  
	local nStatus := KPI_ST_OK

	if oFile:lCopyFile( right(cNameFile, len(cNameFile) - rat("\", cNameFile)), cPath + cPathDest)
		::lClose()
		::delFile(cNameFile)
	endif
return nStatus


/*-------------------------------------------------------------------------------------
@method moveFiles(cNameFile, cPathDest)   
Move arquivos correspondentes a uma mascara (exemplo c:\temp\manuais.*)
@cNameFile 	- Caminho e mascara para os arquivo 
@cPathDest	- Caminho de destino do arquivo
--------------------------------------------------------------------------------------*/
method moveFiles(cNameFile, cPathDest) class TKPIUpload
	local cPath		:= ::oOwner():cKpiPath()
	local cPathOri	:= ""
	local cArquivo	:= ""
	local aArquivos	:= {}
	local oFile		:= nil
	local nStatus	:= KPI_ST_OK
	local nArq		:= 0
	local nLenArq	:= 0
	local nPos		:= 0
	local lOK		:= .T.

	nPos := Rat("\",cNameFile)
	cArquivo := AllTrim(cNameFile)
	While nPos > 0
		cPathOri += Substr(cArquivo,1,nPos)
		cArquivo := AllTrim(Substr(cArquivo,nPos + 1))
		nPos := Rat("\",cArquivo)
	Enddo
	
	aArquivos := Directory(cPath + cNameFile + If(Empty(cArquivo),"*.*",cArquivo))
	nLenArq := Len(aArquivos)
	nArq := 0
	nPos := Len(cArquivo)
	While (nArq < nLenArq) .And. lOk
		nArq++
		oFile := TBIFileIO():New(cPath + cPathOri + aArquivos[nArq,1])
		lOk := oFile:lCopyFile(Substr(aArquivos[nArq,1],nPos + 1), cPath + cPathDest)
		if lOk
			::lClose()
			::delFile(cPathOri + aArquivos[nArq,1])
		endif
		oFile:Free()
	Enddo  
	
	//remove o diretorio caso nao contenha mais arquivos
	if ExistDir(cPath + cPathOri)
		aArquivos := Directory(cPath + cPathOri + "\*.*")
		If Len(aArquivos) == 0
			If !DirRemove(cPath + cPathOri)
				cArquivo := "MoveFileS (kpiupload) - " + STR0002 + cPath + cPathOri //"Nao foi possivel remover o diretorio "
				conout(" ")
				conout(Replicate("*",80))
				conout(cArquivo)
				conout(Replicate("*",80))
				conout(" ")
			Endif
		Endif                        
	Endif
return nStatus

function _KPIUPLOAD()
return nil