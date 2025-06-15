// ######################################################################################
// Projeto: KPI
// Modulo : KPI070_UsuConfig 
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.09-04 | 1776 Alexandre Silva 
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI070_UsuConfig.ch"   

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->TKPI070
Criacao da classe de personalizacao de visializacao do usuario
@entity: Configuracao de Usuario
@table KPI070
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "USU_CONFIG"
#define TAG_GROUP  "USU_CONFIGS"
#define TEXT_ENTITY STR0001/*//"Configuracao do usuario"*/
#define TEXT_GROUP  STR0002/*//"Configuracoes dos usuarios"*/

class TKPI070 from TBITable
	data aDeskProp //Propriedades default

	method New() constructor
	method NewKPI070()

	//Registro Unico
	method oToXMLNode()
	method lPutUserConfig(cUsuID,oXMLNode)//E obrigatorio passar o oXMLNode por referencia
	method getUserConfig(cAtrib,cUserID, cOwner)  
	method setUserConfig(cUserID,cAtributo, cValAtributo, cOwner)
	
	//Gravacao
	method nUpdFromXML(oXML, cPath,cUserID)
	method nDelFromXML(cUserID)
		
endclass
	
method New() class TKPI070
	::NewKPI070()
return

method NewKPI070() class TKPI070
	// Tabela
	::NewTable("SGI070")
	::cEntity(TAG_ENTITY)

	// Campos
	::addField(TBIField():New("ID"				,"C",010))
	::addField(TBIField():New("USUARIOID"		,"C",010))
	::addField(TBIField():New("ATRIBUTO"		,"C",060))
	::addField(TBIField():New("VALATRIB"		,"C",255))
	::addField(TBIField():New("OWNER"			,"C",001))	// "" = Usuário / D = Departamento

	// Indices
	::addIndex(TBIIndex():New("SGI070I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI070I02",	{"USUARIOID","ATRIBUTO","OWNER"},	.t.))

	//Arrays
	::aDeskProp := {;	
						{"DESKVIEWTYPE"		,"1"},	;//Tipo da visualizacao para o desktop.
						{"CONFIGVIEWTYPE"	,"1"},	;//Tipo da visualizacao para a configuracao.
						{"SHOWSCORECARDING"	,"T"},	;//Mostrar o scorecarding na inicializacao?
						{"SHOWMAPAESTRATEGICO", "F" }, ; //Mostrar o mapa estrategico na inicializacão?
						{"IDESTRATEGIA", ""}, ; // Código da estratégia (para filtrar mapa estrategico ligado a ela)						
						{"DT_USER_REALDE"	,"//"},	;//Data a partir da qual e permito fazer alteracao na planilha de valores.
						{"DT_USER_REALATE"	,"//"},	;//Data a partir da qual e permito fazer alteracao na planilha de valores.
						{"DT_USER_METADE"	,"//"},	;//Data a partir da qual e permito fazer alteracao na planilha de valores.
						{"DT_USER_METAATE"	,"//"},	;//Data a partir da qual e permito fazer alteracao na planilha de valores.
						{"DT_USER_PREVIADE"	,"//"},	;//Data a partir da qual e permito fazer alteracao na planilha de valores.
						{"DT_USER_PREVIAATE","//"},	;//Data a partir da qual e permito fazer alteracao na planilha de valores.																								
						{"DT_DPTO_REALDE"	,"//"},	;//Data a partir da qual e permito fazer alteracao na planilha de valores.
						{"DT_DPTO_REALATE"	,"//"},	;//Data a partir da qual e permito fazer alteracao na planilha de valores.
						{"DT_DPTO_METADE"	,"//"},	;//Data a partir da qual e permito fazer alteracao na planilha de valores.
						{"DT_DPTO_METAATE"	,"//"},	;//Data a partir da qual e permito fazer alteracao na planilha de valores.
						{"DT_DPTO_PREVIADE"	,"//"},	;//Data a partir da qual e permito fazer alteracao na planilha de valores.
						{"DT_DPTO_PREVIAATE","//"},	;//Data a partir da qual e permito fazer alteracao na planilha de valores.																								
						{"SCOAUTOREFRESH"	,"F"},	;//Ativar atualização automática ao abrir o scorecarding.
						{"SCOHIDETREE"		,"F"},	;//Ocultar árvore de departamentos ao abrir o scorecarding.
						{"SCODEFAULT"		,"F"},	;//Ao abrir a tela do scorecarging definir como padrão:
						{"IDSCODEFAULT"		,"" },	;//Código do scorecarding default
						{"SCOWIDTHCOL"		,"" },  ;//Tamanho padrão das colunas no scorecarding
						{"SCOFREEZECOL"		,"T"}   ;//Congelar colunas sem valores?
					}                         

return

// Carregar
method oToXMLNode() class TKPI070
	local cUsuID	:=	::oOwner():foSecurity:oLoggedUser():cValue("ID")
	local oXMLNode 	:= TBIXMLNode():New(TAG_ENTITY)
	local oTabRegra := ::oOWner():oGetTable("REGRA")	

	oXMLNode:oAddChild(oTabRegra:oGetUserAccess(cUsuID)) 		
	::lPutUserConfig(cUsuID,@oXMLNode)
return oXMLNode


method lPutUserConfig(cUsuID,oXMLNode) class TKPI070
	local oUsuario	:= ::oOWner():oGetTable("USUARIO")
	local oParam	:= ::oOWner():oGetTable("PARAMETRO")
	local cUser 	:= ""
	local cComp 	:= ""
	local aFields	:= {}
	local nIndProp 	:= 0
	local cValorProp:= ""	
	Local cUserID	:= ""

	//Posicionando no usuario pedido
	if(oUsuario:lSeek(1,{cUsuID}))
		cUser 	:= alltrim(oUsuario:cValue("NOME"))
		cComp 	:= alltrim(oUsuario:cValue("COMPNOME"))
		cUserID := alltrim(oUsuario:cValue("ID"))
	endif    

	//Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY,{"ID","USERID"})   

	//Se nao existir carrega os registros defaults.
	for nIndProp := 1 to len(::aDeskProp)
		if ::lSeek(2,{cUsuID,::aDeskProp[nIndProp,1]})
			cValorProp	:= alltrim(::cValue("VALATRIB"))
		else
			//Retorna a propriedade padrao quando nao a encontra no banco
			cValorProp	:= alltrim(::aDeskProp[nIndProp,2])
		endif

		if(::aDeskProp[nIndProp,1] == "SHOWSCORECARDING" .and.  cValorProp == "T")
			cValorProp := iif(::oOwner():foSecurity:lHasAccess("SCORECARDING", "0", "CARREGAR"),"T","F")
		endif
		
		oXMLNode:oAddChild(TBIXMLNode():New(::aDeskProp[nIndProp,1],cValorProp))		
	next nIndProp      
	
	oXMLNode:oAddChild(TBIXMLNode():New("ID","0"))

	//Identificacao e diretos dos usuario                               
	oXMLNode:oAddChild(TBIXMLNode():New("USUARIO"			, cComp+" ("+cUser+") "))
	oXMLNode:oAddChild(TBIXMLNode():New("ISADMIN"			, oUsuario:lValue("ADMIN")))
	oXMLNode:oAddChild(TBIXMLNode():New("CFGDTMESANTERIOR"	, oParam:getValue("CFGDTMESANTERIOR") ))
	oXMLNode:oAddChild(TBIXMLNode():New("CFGDTACUMULADO"	, oParam:getValue("CFGDTACUMULADO") ))   
	oXMLNode:oAddChild(TBIXMLNode():New("IDUSER"			, cUserID))                                           

	//Labels customizados pelo usuario
	oXMLNode:oAddChild(TBIXMLNode():New("STR_SCO"	, oParam:getValue("STR_SCO") ))                     
	oXMLNode:oAddChild(TBIXMLNode():New("STR_REAL"	, oParam:getValue("STR_REAL") ))                     
	oXMLNode:oAddChild(TBIXMLNode():New("STR_META"	, oParam:getValue("STR_META") ))                     
	oXMLNode:oAddChild(TBIXMLNode():New("STR_PREVIA", oParam:getValue("STR_PREVIA") ))                     
	
	//Armazena o texto informado no parâmetro
	oXMLNode:oAddChild(TBIXMLNode():New("STR_TEND", oParam:getValue("STR_TEND") ))                     	
return .t.

//Atualizacao 
method nUpdFromXML(oXML,cPath,cUserID,nItemAtu,cOwner) class TKPI070
	local nStatus 		:= KPI_ST_OK,nInd,nProp, nPosID
	private oXMLInput 	:= oXML
	
	default nItemAtu 	:= 0 // Indica qual propriedade deve ser atualizada, conforme o array ::aDeskProp, zero todas.
	default cOwner 		:= "" //Usuário

	aFields := ::xRecord(RF_ARRAY,{"OWNER"})
	nPosID	:= ascan(aFields,{|x| x[1] == "ID"})	

	for nProp := 1 to len(::aDeskProp)
		if( nItemAtu == nProp .or. nItemAtu == 0 )		
			// Extrai valores do XML                     
			for nInd := 1 to len(aFields)
				if(aFields[nInd][1] == "USUARIOID" .or. aFields[nInd][1] == "SCORECARDID")
					aFields[nInd][2] := cUserID                                         	
				elseif(aFields[nInd][1] == "ATRIBUTO" )
					aFields[nInd][2] := ::aDeskProp[nProp,1]
				elseif(aFields[nInd][1] == "VALATRIB")
					if(empty(cPath))
						aFields[nInd][2] :=	 &("oXMLInput:_" + ::aDeskProp[nProp,1] + ":TEXT")
					else
						aFields[nInd][2] :=	 &("oXMLInput:"+cPath+":_" + ::aDeskProp[nProp,1] + ":TEXT")
					endif
				elseif(	aFields[nInd][1] == "ID" .or. aFields[nInd][1] == "PARENTID" .or.;
						aFields[nInd][1] == "OWNER" .or. aFields[nInd][1] == "CONTEXTID")
	 					//Campos acertados posteriormente.
				else
					cType := ::aFields(aFields[nInd][1]):cType()
					if(empty(cPath))					
						aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))
					else
						aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
					endif						
				endif	
			next nInd

			aadd(aFields,{"OWNER",cOwner})	
			//Verificar se a propriedade ja existe.
			if(!::lSeek(2, {cUserID,::aDeskProp[nProp,1],cOwner}))
				aFields[nPosID,2] := ::cMakeID()
				// Grava
				if(!::lAppend(aFields))
					if(::nLastError()==DBERROR_UNIQUE)
						nStatus := KPI_ST_UNIQUE
					else
						nStatus := KPI_ST_INUSE
					endif
				endif
			else
				//Altera
				aFields[nPosID,2] := ::cValue("ID")
				if(!::lUpdate(aFields))
					if(::nLastError()==DBERROR_UNIQUE)
						nStatus := KPI_ST_UNIQUE
					else
						nStatus := KPI_ST_INUSE
					endif
				endif	 
			endif
        endif
    next nProp

return nStatus

// Excluir entidade do server
method nDelFromXML(cUserID) class TKPI070
	local nStatus := KPI_ST_OK 

	::cSQLFilter("USUARIOID = '" + padr(cUserID,10) + "'")
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
return nStatus   
           
//Retorna a configuração do usuário
method getUserConfig(cAtrib,cUserID, cOwner) class TKPI070
	Local cRet 		:= ""
	Local nPos		:= 0       
	                       
	Default cUserID := oKpiCore:foSecurity:oLoggedUser():cValue("ID")
	Default cOwner 	:= ""          

	if ( ::lSeek(2, {cUserID, cAtrib, cOwner} ) )
		cRet := alltrim(::cValue("VALATRIB"))	
	else                
		nPos := aScan(::aDeskProp,{|x| x[1] == cAtrib})
		if nPos > 0 
			cRet := ::aDeskProp[nPos][2]
		endif
	endif

return cRet


//Grava o valor da propriendade no banco
//@cUserId 		= ID do usuário
//@cAtributo 	= Indetificação do atributo
//@cValAtributo	= Valor do atributo 
//@cOwner		= "" = Usuário / D = Departamento
//Lucio Pelinson 20/08/2008
method setUserConfig(cUserID,cAtributo, cValAtributo, cOwner) class TKPI070
	local nStatus := KPI_ST_OK
	local aFields := {;
						{"ID"		,""},;
						{"USUARIOID",cUserID},;
						{"ATRIBUTO"	,cAtributo},;
						{"VALATRIB"	,cValAtributo},;
						{"OWNER"	,cOwner}; 
					 }
	
	if ::lSeek(2,{cUserID,cAtributo})
		//Altera
		aFields[1][2] := ::cValue("ID")
		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	 
	else                    
		// Grava	
		aFields[1][2] := ::cMakeID() 
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif
	endif

return nStatus

function _KPI070()
return nil