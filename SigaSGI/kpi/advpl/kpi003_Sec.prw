// ######################################################################################
// Projeto: KPI
// Modulo : Core
// Fonte  : KPI003_Sec.prw -Seguranca do sistema KPI. Atua junto com usuarios.
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// 22.08.05 | 1776 Alexandre Alves da Silva - Importado para uso no KPI.
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI003_Sec.ch"

/*-------------------------------------------------------------------------------------
@class TKPI003
@entity Seguranca
Seguranca do sistema KPI. Atua junto com usuarios.
@table KPI003
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "REGRA"
#define TAG_GROUP  "REGRAS"
#define TEXT_ENTITY STR0001/*//"Regra"*/
#define TEXT_GROUP  STR0002/*//"Regras"*/

class TKPI003 from TBITable

	method New() constructor
	method NewKPI003() 

	method oToXMLNode(nIDOwner, cOwner)
	method nUpdFromXML(oXML, cPath, nIDOwner, cOwner)
	method nDelFromXML(cIdOwner)
	method GravaRegra(oXML, cPath, nIDOwner, cOwner, cEntity, nItem)
	method RegraNode(cIDOwner,cOwner)
	method oGetUserAccess(cUserID)
	method oArvoreSeg()

endclass
	
method New() class TKPI003
	::NewKPI003()
return

method NewKPI003() class TKPI003
	// Table
	::NewTable("SGI003")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID", 		"C",10))
	::addField(TBIField():New("OWNER",		"C",01))	// U = Usuário / G = Grupo
	::addField(TBIField():New("IDOWNER",	"C",10))	// ID do Usuário ou Grupo
	::addField(TBIField():New("ENTITY", 	"C",30))	// Nome da Entidade
	::addField(TBIField():New("IDOPERACAO", "C",02))	// ID da Operação
	::addField(TBIField():New("PERMITIDA",	"C",01))	// Permite acesso a Operação

	// Indexes
	::addIndex(TBIIndex():New("SGI003I01",	{"ID"},	.T.))
	::addIndex(TBIIndex():New("SGI003I02",	{"OWNER", "IDOWNER", "ENTITY", "IDOPERACAO"}, .F.))
Return

/*--------------------------------------------------------------------------------------
@oToXMLNode(nIDOwner, cOwner)
@param 	cIdOwner
@param 	cOwner
--------------------------------------------------------------------------------------*/
method oToXMLNode(nIDOwner, cOwner) class TKPI003
	Local aFields
	Local  nInd
	Local oXMLNode
	Local  oNode
	Local  oAttrib

	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .t.)
	// Operação
	oAttrib:lSet("TAG000", "IDOPERACAO")
	oAttrib:lSet("CAB000", STR0003)/*//"Operacao"*/
	oAttrib:lSet("CLA000", KPI_STRING)
	// Permitida
	oAttrib:lSet("TAG001", "PERMITIDA")
	oAttrib:lSet("CAB001", STR0004)/*//"Permitida"*/
	oAttrib:lSet("CLA001", KPI_BOOLEAN)
	oAttrib:lSet("EDT001", .t.)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	::SetOrder(2) 
	::cSQLFilter("IDOWNER = '" + cBISTR(nIDOwner) + "' and OWNER = '" + cOwner + "'")
	::lFiltered(.t.)
	::_First() 
	
	While(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID", "CONTEXTID"})
		
		For nInd := 1 To Len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		Next
		::_Next()
	End
	
	::cSQLFilter("") 
return oXMLNode

/*--------------------------------------------------------------------------------------
@nUpdFromXML(oXML, cPath, cIDOwner, cOwner)
@param 	oXML, Dados a serem gravados.
@param 	cPath Caminho para padrao do no.
@param Id do proriatario
@param 	cOwner tipo do proprietario = "U" = Usuario, "G" =Grupo.
Atualiza e/ou Insere novas entidades 
--------------------------------------------------------------------------------------*/
method nUpdFromXML(oXML, cPath, cIDOwner, cOwner, nTipoOperacao) class TKPI003
	Local nStatus 		:= KPI_ST_OK
	
	Private oXMLInput 	:= oXML
	
	Default nTipoOperacao := 0
	                                                                      
 	if (! (alltrim(cIDOwner)=="0"))
		::nDelFromXML( Padr(cIDOwner,10), cOwner)
	endif 
	        
	::GravaRegra(oXML, cPath, cIDOwner, cOwner, nTipoOperacao)
return nStatus

/*--------------------------------------------------------------------------------------
@nDelFromXML(cIdOwner,cOwner)
Remove todas a regras de segurança de um determinado usuário. 
@param 	cIdOwner
@param 	cOwner
--------------------------------------------------------------------------------------*/
method nDelFromXML(cIdOwner, cOwner) class TKPI003
	local nStatus := KPI_ST_OK, cQuery, cMsg := ""
                                                                      
 	if ( ! (alltrim(cIDOwner)=="0"))
		cQuery:="DELETE FROM SGI003 WHERE IDOWNER = '"+padr(cIDOwner,10)+"' AND OWNER = '"+cOwner+"'"
		
		TCSQLEXEC(cBIParseSQL(cQuery, @cMsg))
		TCREFRESH("SGI003")
 	endif
return nStatus

/*--------------------------------------------------------------------------------------
@GravaRegra(oXML, cPath, cIDOwner, cOwner, nTipoOperacao)
Grava as regras de acesso do usuário. 
@param 	oXML
@param 	cPath 
@param 	cIDOwner
@param 	cOwner
@param 	nTipoOperacao
--------------------------------------------------------------------------------------*/
method GravaRegra(oXML, cPath, cIDOwner, cOwner, nTipoOperacao) class TKPI003
	Local nRegras   	:= 0
	Local nTotRegras	:= 0
	Local nItem			:= 0
	Local nNoRegra      := 0
	Local nIdOperacao  	:= 0   
	Local nStatus		:= 0
	Local aRegras 		:= ::oOwner():oGetTable("USUARIO"):getFaRegra()
    Local aFields		:= {}
    
	Private oXMLInput := oXML 
	
	Default nTipoOperacao := 0	   

    for nItem := 1 to len(aRegras)
		oNoRegra := XmlChildEx( &("oXMLInput:"+cPath) ,"_"+alltrim(aRegras[nItem,1]))
		
		If (valtype(XmlChildEx(&("oNoRegra:_ITEMREGRA"), "_REGRA"))=="A")			
				nTotRegras := Len(oNoRegra:_ITEMREGRA:_REGRA)    
			
			For nRegras := 1 To nTotRegras  
				aFields		:= {}  
				cOperacao 	:=  oNoRegra:_ITEMREGRA:_REGRA[nRegras]:_REGRAID:TEXT                  
  
		   		aAdd(aFields, {"ID"			, ::cMakeID()} )
			   	aAdd(aFields, {"OWNER"		, cOwner} )
			   	aAdd(aFields, {"IDOWNER"	, cIDOwner} )		
			   	aAdd(aFields, {"ENTITY"		, aRegras[nItem,4]} )		
			   	aAdd(aFields, {"IDOPERACAO"	, cOperacao } )

				If( nTipoOperacao == 1) 
					aAdd(aFields, {"PERMITIDA"	, oNoRegra:_ITEMREGRA:_REGRA[nRegras]:_VALOR:TEXT} )
				Else
					If( cOperacao == "2")
						aAdd(aFields, {"PERMITIDA"	, aRegras[nItem, 5] })
					else
						aAdd(aFields, {"PERMITIDA"	, "0"})
					endif
				endif
				      
				If(!::lAppend(aFields))
					If(::nLastError()==DBERROR_UNIQUE)
						nStatus := KPI_ST_UNIQUE
					Else
						nStatus := KPI_ST_INUSE
					EndIf
				EndIf 				
			Next nRegras 
		else  
			aFields		:= {}  
			cOperacao 	:=  oNoRegra:_ITEMREGRA:_REGRA:_REGRAID:TEXT                  
  
	   		aAdd(aFields, {"ID"			, ::cMakeID()} )
		   	aAdd(aFields, {"OWNER"		, cOwner} )
		   	aAdd(aFields, {"IDOWNER"	, cIDOwner} )		
		   	aAdd(aFields, {"ENTITY"		, aRegras[nItem,4]} )		
		   	aAdd(aFields, {"IDOPERACAO"	, cOperacao } )

			If( nTipoOperacao == 1) 
				aAdd(aFields, {"PERMITIDA"	, oNoRegra:_ITEMREGRA:_REGRA:_VALOR:TEXT } )
			Else
				If( cOperacao == "2")
					aAdd(aFields, {"PERMITIDA"	, aRegras[nItem, 5] })
				else
					aAdd(aFields, {"PERMITIDA"	, "0"})
				endif
			endif
			      
			If(!::lAppend(aFields))
				If(::nLastError()==DBERROR_UNIQUE)
					nStatus := KPI_ST_UNIQUE
				Else
					nStatus := KPI_ST_INUSE
				EndIf
			EndIf 				
		EndIf
	Next nItem      
Return  nStatus

/*--------------------------------------------------------------------------------------
@RegraNode(cIDOwner,cOwner) class TKPI003
Carrega as regras para o grupo ou usuario.
@param 	cIDOwner
@param 	cOwner
--------------------------------------------------------------------------------------*/
method RegraNode(cIDOwner,cOwner) class TKPI003
	Local oNode         := Nil
	Local oAttrib		:= Nil
	Local nItem
	Local nRegra
	Local cEntidade		:= ""    
	Local aRegra 		:= ::oOwner():oGetTable("USUARIO"):getFaRegra()
	Local nTotal 		:= len(aRegra)	
	Local oXMLArvore := TBIXMLNode():New("REGRAS",,oAttrib)   
	
	For nItem := 1 to nTotal
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("NOME", aRegra[nItem,1])

		oXMLNode 	:= oXMLArvore:oAddChild(TBIXMLNode():New(aRegra[nItem,1],"",oAttrib))
		oNode 		:= oXMLNode:oAddChild(TBIXMLNode():New("ITEMREGRA"))
		cEntidade 	:= aRegra[nItem,4]

		for nRegra := 1 to len(aRegra[nItem,3])
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("REGRAID",aRegra[nItem,3,nRegra,2])
			
			If(::lSeek(2, {cOwner, cIDOwner, Padr(cEntidade, 30), Padr(aRegra[nItem, 3, nRegra, 2] ,2) } ))
				oAttrib:lSet("VALOR", ::cValue("PERMITIDA") )
			Else
				oAttrib:lSet("VALOR", "0")
			Endif

			oNode:oAddChild(TBIXMLNode():New("REGRA","",oAttrib))
		Next nRegra			
	Next nItem
return oXMLArvore
     
/*--------------------------------------------------------------------------------------
@oGetUserAccess(cUserID)
Verifica se o grupo tem permissao para as propriedades que o usuario nao tem.
@param  cUserID
--------------------------------------------------------------------------------------*/
method oGetUserAccess(cUserID) class TKPI003
	Local oNode	
	Local oAttrib
	Local nItem
	Local nRegra
	local cEntidade	:= ""    
	local aGrupos 	:= ::oOwner():oGetTable("GRPUSUARIO"):aGroupsByUser(cUserID)
	local aRegra 	:= ::oOwner():oGetTable("USUARIO"):getFaRegra()
	local nTotal 	:= len(aRegra)	
	local cAcesso 	:= "0"
	local nI		:=	0

	oXMLArvore := TBIXMLNode():New("REGRAS",,oAttrib)
	
	for nItem := 1 to nTotal
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("NOME", aRegra[nItem,1])

		oXMLNode := oXMLArvore:oAddChild(TBIXMLNode():New(aRegra[nItem,1],"",oAttrib))
		oNode := oXMLNode:oAddChild(TBIXMLNode():New("ITEMREGRA"))
		cEntidade 	:= aRegra[nItem,4]

		for nRegra := 1 to len(aRegra[nItem,3])
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("REGRAID",aRegra[nItem,3,nRegra,2])
			  
			//Verifica o acesso do usuário. 
			If( ::lSeek( 2, { "U", Padr(cUserID,10), Padr(cEntidade,30), Padr(aRegra[nItem,3,nRegra,2],2) } ))
				cAcesso := ::cValue("PERMITIDA")
			Else
				cAcesso := "0"
			Endif

			//Verifica o acesso do grupo. 
			if( cAcesso == "0" )
				for nI := 1 to len(aGrupos)
				
					If ( ::lSeek( 2, {"G", Padr(aGrupos[nI],10), Padr(cEntidade,30), Padr(aRegra[nItem,3,nRegra,2],2) } ))
						cAcesso := ::cValue("PERMITIDA")
					else
						cAcesso := "0"
					endif
		
					If (cAcesso == "1")
						Exit
					EndIf
				Next
			EndIf
			
			oAttrib:lSet("VALOR",cAcesso )
			oNode:oAddChild(TBIXMLNode():New("REGRA","",oAttrib))
		next nRegra			
	next nItem
return oXMLArvore

/*--------------------------------------------------------------------------------------
@oArvoreSeg()
Monta a árvore de segurança ed usuário/grupo.
--------------------------------------------------------------------------------------*/
method oArvoreSeg() class TKPI003
	local oNode, oAttrib,nItem
	local aRegra := ::oOwner():oGetTable("USUARIO"):getFaRegra()
	local nTotal := len(aRegra)	

	oXMLArvore := TBIXMLNode():New("ARVORES_SEG",,oAttrib)
	oXMLNode := oXMLArvore:oAddChild(TBIXMLNode():New("ARVORE_SEG","",oAttrib))
	
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", "1")
	oAttrib:lSet("TIPO", "ARVORE_SEG")
	oAttrib:lSet("NOME", STR0005) //"Direitos do usuário"
	oNode := TBIXMLNode():New("ARVORE_SEG","",oAttrib)

	for nItem := 1 to nTotal
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", nItem)
		oAttrib:lSet("NOME", aRegra[nItem,2])
		oNode:oAddChild(TBIXMLNode():New(aRegra[nItem,1],"",oAttrib))	
	next nItem

	oXMLNode:oAddChild(oNode)
return oXMLArvore                             

function _KPI003_Sec()
return nil
