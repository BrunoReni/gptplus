#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

WSRESTFUL FreightDocuments DESCRIPTION ('Serviço para consulta e alteração de documentos de frete do módulo SIGAGFE - GESTÃO DE FRETE EMBARCADOR');
FORMAT "application/json,text/html" 
	
	WSDATA InternalId As CHARACTER
	
	WSDATA Page 	AS INTEGER 		OPTIONAL
    WSDATA PageSize AS INTEGER		OPTIONAL
    WSDATA Order    AS CHARACTER   	OPTIONAL
    WSDATA Fields   AS CHARACTER   	OPTIONAL
	
	WSMETHOD GET v1;
	DESCRIPTION ("Permite a consulta de todos os documentos de frete cadastrados.");
    WSSYNTAX "/api/gfe/v1/FreightDocuments" ;
	PATH "/api/gfe/v1/FreightDocuments" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET v1_ID;
	DESCRIPTION ("Retorna apenas um documento de frete, requerido através da chave do registro (InternalId).");
	WSSYNTAX "/api/gfe/v1/FreightDocuments/{InternalId}" ;
    PATH "/api/gfe/v1/FreightDocuments/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj	
	
//	WSMETHOD POST v1;
//	DESCRIPTION ("Inclui um novo documento de frete.");
//	PATH "/api/agr/v1/Teste123" ;
//	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD PUT v1;
	DESCRIPTION ("Altera o documento de frete informado através da chave (InternalId).");
	WSSYNTAX "/api/gfe/v1/FreightDocuments/{InternalId}" ;
    PATH "/api/gfe/v1/FreightDocuments/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj 
	
//  WSMETHOD DELETE v1;
//	DESCRIPTION ("Exclui um documento de frete.");
//	PATH "/api/agr/v1/Teste123/{InternalId}" ;
//	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
END WSRESTFUL


WSMETHOD GET v1 QUERYPARAM Page,PageSize,Order,Fields  WSREST FreightDocuments
	Local lRet    				as LOGICAL
	Local oFWFreightDocument 	as OBJECT
	Local oJsonfilter   		as OBJECT
	Local aQryParam				as ARRAY
	Local nX					as NUMERIC

	aQryParam 	:= {}	
	lRet 		:= .T. 

	oFWFreightDocument := FWFreightDocumentsAdapter():new()
	oFWFreightDocument:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWFreightDocument:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWFreightDocument:oEaiObjRec:setPage(self:Page)
    Else
        oFWFreightDocument:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWFreightDocument:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWFreightDocument:oEaiObjRec:setPageSize(10)
    endIf
    
    If !empty(Self:Order)
        oFWFreightDocument:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWFreightDocument:cSelectedFields := Self:Fields
    endIf
    
    oFWFreightDocument:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWFreightDocument:oEaiObjRec:Activate()
    
    oFWFreightDocument:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWFreightDocument:lApi := .T.
	oFWFreightDocument:GetFreightDocument()
	
	if oFWFreightDocument:lOk
		if oFWFreightDocument:cTipRet = '1'
			::SetResponse(EncodeUTF8(oFWFreightDocument:oEaiObjSnd:GetJson(,.T.)))
		else
			::SetResponse(EncodeUTF8(oFWFreightDocument:oEaiObjSn2:GetJson(,.T.)))
		endIf
    Else
        SetRestFault(400,EncodeUtf8( oFWFreightDocument:cError ))
        lRet := .F.
    EndIf
	
Return lRet

WSMETHOD GET v1_ID QUERYPARAM Fields PATHPARAM InternalId WSREST FreightDocuments
	Local lRet 					as LOGICAL
	Local oFWFreightDocument  	as OBJECT
	Local oJsonfilter   		as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWFreightDocument := FWFreightDocumentsAdapter():new()
    oFWFreightDocument:oEaiObjRec := FWEaiObj():new()
    
    oFWFreightDocument:oEaiObjRec:setRestMethod('GET')  

    If !empty(Self:Fields)
        oFWFreightDocument:cSelectedFields := Self:Fields
    endIf
    
    oFWFreightDocument:oEaiObjRec:activate()    
    
    oFWFreightDocument:oEaiObjRec:setPathParam('InternalId',Self:InternalId)
    
    oFWFreightDocument:cTipRet := '2' //Tipo de retorno Não array

    oFWFreightDocument:lApi := .T.
    oFWFreightDocument:GetFreightDocument()
    
    If oFWFreightDocument:lOk
    	lRet := oFWFreightDocument:lOk

        ::SetResponse(EncodeUTF8(oFWFreightDocument:oEaiObjSn2:GetJson(,.T.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWFreightDocument:cError ))
        lRet := .F.
    EndIf

Return lRet


/*WSMETHOD POST V1 WSREST FreightDocuments
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	Local oRequest 	as OBJECT
	
	cBody := ::GetContent()
	
    oFWCottonGinMachine := FWCottonGinMachinesAdapter():new()
    oFWCottonGinMachine:oEaiObjRec := FWEaiObj():new()
    
    oFWCottonGinMachine:oEaiObjRec:setRestMethod('POST')
    
    oFWCottonGinMachine:oEaiObjRec:activate()

    oFWCottonGinMachine:oEaiObjRec:loadJson(cBody)
    
    oFWCottonGinMachine:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonGinMachine:lApi := .T.
    cCodId := oFWCottonGinMachine:IncludeFreightDocuments()

    If oFWCottonGinMachine:lOk
        lRet := .T.
        
        //Realizando o GET do conjunto incluido para gerar a resposta
        oFWCottonGinMachine:GetFreightDocument(cCodId)
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGinMachine:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWCottonGinMachine:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonGinMachine:cError))
    EndIf

Return lRet
*/


WSMETHOD PUT V1 PATHPARAM InternalId WSREST FreightDocuments
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	
	cBody 	:= ::GetContent()
	lRet 	:= .T.
 
    oFWFreightDocument := FWFreightDocumentsAdapter():new()
    oFWFreightDocument:oEaiObjRec := FWEaiObj():new()
    
    oFWFreightDocument:oEaiObjRec:setRestMethod('PUT')    
    oFWFreightDocument:oEaiObjRec:activate()
    
    oFWFreightDocument:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    oFWFreightDocument:oEaiObjRec:loadJson(cBody)
    
    oFWFreightDocument:cTipRet := '2' //Tipo de retorno Não array

    oFWFreightDocument:lApi := .T.
    cCodId := oFWFreightDocument:UpdateFreightDocuments()

    If oFWFreightDocument:lOk
        lRet := .T.
		//Realizando o GET do conjunto incluido para gerar a resposta
		oFWFreightDocument:GetFreightDocument(cCodId)
		::SetResponse(EncodeUTF8(FWJsonSerialize(oFWFreightDocument:oEaiObjSn2, .F., .F., .T.)))

    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWFreightDocument:cError))
    EndIf
Return lRet
