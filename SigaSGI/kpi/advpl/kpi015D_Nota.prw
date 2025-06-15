// ######################################################################################
// Projeto: KPI
// Fonte  : KPI015d_Nota.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 21.09.10 | 3174 Valdiney V GOMES
// --------------------------------------------------------------------------------------
#INCLUDE "kpi015D_Nota.ch"
#include "BIDefs.ch"
#include "KPIDefs.ch"

/*--------------------------------------------------------------------------------------
@entity Notas
Tabela que contém as anotações relacionadas com indicadores. 
@table KPI015d
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "NOTA"
#define TAG_GROUP  "NOTAS"
#define TEXT_ENTITY STR0001 //"Nota"
#define TEXT_GROUP  STR0002 //"Notas"
    
/**
Definição da classe. 
*/
class TKPI015d from TBITable
	//Construção. 
	method New() constructor
	method NewKPI015d()
	
    //Exibição. 
	method oToXMLRecList()
	method oToXMLNode() 
	
    //Manutenção.
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)  
	
	//Funcionalidade.
	method nImagemNota(cID)
endclass
	  
/**
Construtor.
*/	
method New() class TKPI015D
	::NewKpi015d()
return   

/**
Construtor.
*/
method NewKpi015d() class TKPI015D
	::NewTable("SGI015D")
	::cEntity(TAG_ENTITY)

	::addField(TBIField():New("ID"			,"C"	,010))   
	::addField(TBIField():New("ID_INDICA"	,"C"	,010))
	::addField(TBIField():New("NOME" 		,"C"	,255))	  
	::addField(TBIField():New("TPNOTA" 		,"C"	,001))//Tipo da Nota I=Nota para o Indicador O=Nota para o Objetivo
	::addField(TBIField():New("AUTOR"		,"C"	,010))  
	::addField(TBIField():New("HORA"		,"C"	,005))	
	::addField(TBIField():New("VALOR"		,"N"	,18,06))
	::addField(TBIField():New("META"		,"N"	,18,06))	
	::addField(TBIField():New("NOTA" 		,"M"	))	
	::addField(TBIField():New("PUBLICA"		,"D"	)) 	
	::addField(TBIField():New("DATAALVO"	,"D"	)) 	

	::addIndex(TBIIndex():New("SGI015DI01",	{"ID"}	,.T.)) 
	::addIndex(TBIIndex():New("SGI015DI02",	{"ID_INDICA"},.F.)) 
	
return 

/**
Carrega a estrutura de dados. 
*/
method oToXMLNode() class TKPI015D
	Local aFields 		:= {}
	Local nI	   		:= 0
	Local oXMLNode 		:= TBIXMLNode():New(TAG_ENTITY)     
	Local oUsuario 		:= ::oOwner():foSecurity:oLoggedUser()
	Local cUsuarioID	:= oUsuario:cValue("ID") 
	Local lUsuarioADM	:= oUsuario:lValue("ADMIN")
	Local oAutor 		:= ::oOwner():oGetTable("USUARIO") 
	Local cAutorNome	:= ""
	
	aFields := ::xRecord(RF_ARRAY)
	
	For nI := 1 To Len(aFields) 
   		If (aFields[nI][1] = "AUTOR")  
   		           
   		 	If ( Vazio( ::cValue("AUTOR") ) )
   		   		cAutorNome :=  oUsuario:cValue("COMPNOME")
   		 	Else
   		 		If ( oAutor:lSeek(1, { ::cValue("AUTOR") }) )	
			        cAutorNome :=  oAutor:cValue("COMPNOME")
				EndIf
   		 	EndIf
					
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nI][1], cAutorNome ) )  
			oXMLNode:oAddChild( TBIXMLNode():New( "PERMISSAO", lUsuarioADM .Or. (aFields[nI][2] == cUsuarioID) ) )
		Else	
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nI][1], aFields[nI][2]))   
		EndIf		
	Next 
	
	oXMLNode:oAddChild(TBIXMLNode():New("PERIODO",""))   

return oXMLNode

/**
Lista as notas filhas de um indicador.
@param cID ID do indicador.
@return oXMLLista
*/
method oToXMLRecList(oXMLCmd) class TKPI015D
	Local oNode 		:= Nil
	Local oAttrib		:= Nil
	Local oXMLNode		:= Nil
	Local oXMLLista 	:= TBIXMLNode():New("LISTA")
	local oTbInd		:= ::oOwner():oGetTable("INDICADOR")
	Local nI	   		:= 0
	Local oAutor 		:= ::oOwner():oGetTable("USUARIO") 
	Local cAutorNome	:= ""
	Local cPerNome 		:= ""
	Local cID			:= oXMLCmd:_ID_INDICADOR:TEXT
	Local cDataDe		:= DtoS(cToD(oXMLCmd:_DATA_DE:TEXT))
	Local cDataAte 		:= DtoS(cToD(oXMLCmd:_DATA_ATE:TEXT))
	Local oUserLog	 	:= ::oOwner():foSecurity:oLoggedUser()	
	Local oScorec		:= ::oOwner():oGetTable("SCORECARD")       
	Local oParam		:= ::oOwner():oGetTable("PARAMETRO")
	Local isAdmin 		:= oUserLog:lValue("ADMIN")
	Local cUserLogID	:= oUserLog:cValue("ID")     
	Local lRespObj		:= isAdmin     
	Local lVlrParam		:= .F.

	oAttrib := TBIXMLAttrib():New()

	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .F.)

	oAttrib:lSet("TAG000", "SEGURANCA")
	oAttrib:lSet("CAB000", STR0003) //"Edição"
	oAttrib:lSet("CLA000", KPI_IMAGEM) 
         
	oAttrib:lSet("TAG001", "PUBLICA")
	oAttrib:lSet("CAB001", STR0004) //"Publicação"
	oAttrib:lSet("CLA001", KPI_DATE)   

	oAttrib:lSet("TAG002", "HORA")
	oAttrib:lSet("CAB002", STR0005) //"Hora"
	oAttrib:lSet("CLA002", KPI_STRING)   
	
	oAttrib:lSet("TAG003", "AUTOR")
	oAttrib:lSet("CAB003", STR0006) //"Autor"
	oAttrib:lSet("CLA003", KPI_STRING)
	
	oAttrib:lSet("TAG004", "PERIODO")
	oAttrib:lSet("CAB004", STR0007) //"Período"
	oAttrib:lSet("CLA004", KPI_STRING)   
	
	oAttrib:lSet("TAG005", "NOME")
	oAttrib:lSet("CAB005", STR0008) //"Assunto"
	oAttrib:lSet("CLA005", KPI_STRING)    
                                        
	//Seguranca para inclusao e manutensao de Nota.  
	If oTbInd:lSeek(1, {cID})
       	oAttrib1 := TBIXMLAttrib():New()
        //Exibir variação em percentual	
		If(oParam:lSeek(1, {"SEGURANCA_NOTA"}))
			lVlrParam := oParam:getValue("SEGURANCA_NOTA")
		endif  
       
		If !isAdmin .And. oScorec:lSeek(1,{oTbInd:cValue("ID_SCOREC")})
			lRespObj := oScorec:cValue("RESPID") == cUserLogID
		EndIf
		
		oAttrib1:lSet("RESPIND"			, oTbInd:isResp(cUserLogID,RESP_COL))	//responsavel pela coleta
		oAttrib1:lSet("RESPCOL"			, oTbInd:isResp(cUserLogID,RESP_IND))	//responsavel pelo indicador
		oAttrib1:lSet("RESPOBJ"			, lRespObj) 							//responsavel pelo objetivo
		oAttrib1:lSet("SEGURANCA_NOTA"	, lVlrParam)							//parametro
        
		oNodeSeg := TBIXMLNode():New("SEGURANCA_NOTA",,oAttrib1)
	EndIf                                            

	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)

	::cSQLFilter("DATAALVO >= '" + cDataDe + "' And DATAALVO <= '" + cDataAte+"'" )
	::lFiltered(.T.)
	::_First()
	
	If ::lSeek(2, { AllTrim(cID) } )  .And. oTbInd:lSeek(1, {alltrim(::cValue("ID_INDICA"))})
	
		While !::lEof() .And. ::cValue("ID_INDICA") == AllTrim(cID) 
			
			If( !(alltrim(::cValue("ID")) == "0"))     
			
				oNode 	:= oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
				aFields := {{"ID", ""}			,{"PUBLICA", ""}	,{"NOME", ""}	,{"AUTOR",""},;
							{"ID_INDICA",""}	,{"NOTA",""}		,{"TPNOTA",""}	,{"VALOR", 0},;
							{"META", 0}	  		,{"HORA", 0}		,{"PERIODO",""} }		   
				
				For nI := 1 To Len(aFields)
				   	
				   	If aFields[nI][1] = "PUBLICA"
						oNode:oAddChild(TBIXMLNode():New(aFields[nI][1], ::dValue( aFields[nI][1]))) 
					ElseIf aFields[nI][1] = "PERIODO"  
						cPerNome := oTbInd:cGetPeriodo(oTbInd:nValue("FREQ"), ::dValue("DATAALVO"))
						oNode:oAddChild(TBIXMLNode():New(aFields[nI][1], cPerNome))
					ElseIf aFields[nI][1] = "AUTOR" 
			   			If oAutor:lSeek(1, { ::cValue("AUTOR") }) 
					        cAutorNome :=  oAutor:cValue("COMPNOME")
						EndIf						
						oNode:oAddChild(TBIXMLNode():New(aFields[nI][1], cAutorNome ) ) 

						//Icones de seguranca
						if isAdmin .Or. ::cValue("AUTOR") == cUserLogID
							oNode:oAddChild(TBIXMLNode():New("SEGURANCA",KPI_IMG_CAD_ABERTO))
						else
							oNode:oAddChild(TBIXMLNode():New("SEGURANCA",KPI_IMG_CAD_VERMELHO))						
						endif
					ElseIf aFields[nI][1] = "TPNOTA" .And. Empty( ::cValue("TPNOTA"))
						oNode:oAddChild(TBIXMLNode():New(aFields[nI][1],"I")) 						
					Else
						oNode:oAddChild(TBIXMLNode():New(aFields[nI][1], Alltrim(::cValue( aFields[nI][1] )) ) ) 
					EndIf
				
				Next
			Endif
						
			::_Next()		
		End 
	
	Endif  
	::cSQLFilter("")		                                           
	::lFiltered(.F.)		
	                              
	oXMLLista:oAddChild(oNodeSeg)
	oXMLLista:oAddChild(oXMLNode)

return oXMLLista

/**
Insere uma nova nota em um indicador.
@param oXML
@param cPath
@return nStatus
*/
method nInsFromXML(oXML, cPath) class TKPI015D
	Local aFields	:= {}
	Local nI        := 0
	Local nStatus 	:= KPI_ST_OK   
	Local oUser 	:=	::oOwner():foSecurity:oLoggedUser()	

	Private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	For nI := 1 To Len(aFields)
		cType := ::aFields(aFields[nI][1]):cType()
				
		If(aFields[nI][1] == "AUTOR")
			aFields[nI][2] := oUser:cValue("ID")
		ElseIf(aFields[nI][1] == "HORA") 
			aFields[nI][2] := Time()
		ElseIf(aFields[nI][1] == "PUBLICA")
			aFields[nI][2] := date()
		Else
			aFields[nI][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nI][1]+":TEXT")) 
		EndIf		
	Next

	aAdd(aFields, {"ID", ::cMakeID()})

	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	endif	

return nStatus

/**
Atualiza uma nova nota em um indicador.
@param oXML
@param cPath
@return nStatus
*/
method nUpdFromXML(oXML, cPath) class TKPI015D
	Local nStatus 	:= KPI_ST_OK
	Local cID 		:= ""
	Local nI      	:= 0 
	Local oUser 	:=	::oOwner():foSecurity:oLoggedUser()	
	
	Private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY,{"HORA","PUBLICA","DATAALVO"})

	For nI := 1 To Len(aFields)
		cType := ::aFields(aFields[nI][1]):cType()
				
		If(aFields[nI][1] == "AUTOR")
			aFields[nI][2] := oUser:cValue("ID")
		Else
			aFields[nI][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nI][1]+":TEXT")) 
		EndIf		

		If(aFields[nI][1] == "ID")
			cID := aFields[nI][2]
		EndIf	
	Next

	If(!::lSeek(1, {cID}))
		nStatus := KPI_ST_BADID
	Else       
		If(!::lUpdate(aFields))
			If(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			Else
				nStatus := KPI_ST_INUSE
			Endif
		Endif	
	Endif
Return nStatus

/**
Remove uma nova nota em um indicador.
@param oXML
@param cPath
@return nStatus
*/
method nDelFromXML(cID) class TKPI015D
	local nStatus	:= KPI_ST_OK

	if(::lSeek(1,{cID}))
		if(!::lDelete())
			nStatus := KPI_ST_INUSE
		endif
	else
		nStatus := KPI_ST_BADID
	endif	

return nStatus

/**
Identifica se existe nota cadastrada para um indicador.
@param nID ID do indicador.
@retunr nImagem Imagem a ser exibida no scorearding.
*/
method nImagemNota(cID) class TKPI015D    
 	Local nImagem 	:= KPI_IMG_VAZIO
	Local cTab015D	:= GetNextAlias()
	Local lFoundInd := .F.
	Local lFoundObj	:= .F.
 	
 	If(::lSeek(2,{cID}))
		nImagem := KPI_IMG_NOTA
    EndIf
    
	BeginSql Alias cTab015D
    	Select TPNOTA
		From SGI015D SGI15D       
		Where ID_INDICA = %Exp:cID% 		
		      And SGI15D.%notDel%
		Group By TPNOTA		      
	EndSql 

	Do While (! (cTab015D)->(Eof()))  
    	If (cTab015D)->(TPNOTA) == "I"  .Or. Empty((cTab015D)->(TPNOTA))
			lFoundInd	:= .T.   
			nImagem 	:= KPI_IMG_NOTA			
        ElseIf (cTab015D)->(TPNOTA) == "O"
	        lFoundObj	:=	.T.
			nImagem 	:=	KPI_IMG_NOTA_VERDE
    	EndIf

		(cTab015D)->(dbSkip())
	EndDo
	(cTab015D)->(DbCloseArea())
	
	If lFoundInd .And. lFoundObj
		nImagem :=	KPI_IMG_NOTA_AZUL
	EndIf

return nImagem       

           
/**
Torna a classe visível no inspetor de objetos.
*/
function _KPI015D_Nota()
return nil