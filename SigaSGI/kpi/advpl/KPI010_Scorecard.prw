// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI010_Scorecard
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 05.09.05 | Alexandre Alves da Silva
// 07.09.05 | Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI010_Scorecard.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->TKPI010
Container principal do sistema, contém todos os elementos.
@entity: Scorecard (Departamento)
@table KPI010
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "SCORECARD"
#define TAG_GROUP  "SCORECARDS"
#define TEXT_ENTITY STR0001 //"Scorecard"
#define TEXT_GROUP  STR0002 //"Scorecards"

//Defines para o retorno de metodo aScoXRegraUsu
#Define ID			1
#Define NOME		2
#Define TIPOSCORE	3

class TKPI010 from TBITable
	Method New() constructor
	Method NewKPI010()
                                  
   	//Árvore.
	Method oArvore(lAccess)
	Method oArvoreMatrix()	      
	Method oArvoreTema(cIdEstrat,aSelNode)
	Method oBuildTree(cIDUser, cIDPacote, lChkAccess) 
	Method oBuildWait(cID, oXMLNode) 
	Method oBuildChild(cIDScorecard, cIDPacote, lChkAccess)	    
	
	//Interface.
	Method oToXMLList()
	Method oToXMLNode()
	Method oToXMLRecList(cCmdSQL) 
	Method nExecute(cID, cExecCMD)
    
	//CRUD.
	Method nInsFromXML(oXML, cPath)
	Method nUpdFromXML(oXML, cPath)
	Method nDelFromXML(cID)  
	Method nDelCascade(cID) 
	
	// Delete - Override
	method lDelete()

    //Sessão. 
	Method aGetAccess()
	Method aGetPacAccess(cIDPacote)	
	Method xClearCache()  
	
	//Lógica.
	Method oStatusPlanoAcao()  
	Method lChkAccess(aScoPorUsuario)  
	Method lPacAccess()
	Method nCalcQtdPAVen(lAvencer,cIdScorec,dDataDe,dDataAte)
	Method aScoXRegraUsu(cIDScoreCard, cRespID, lVerificar, aScorecard, aScoPorUsuario, lNome)
	Method oXMLLstScoPai() 	
	Method aScoXResponsavel(cIDUser, aScorecard)   
	Method aGetAllChilds(cID, aChilds)
	Method cGetXMLCommand(oXmlCommand,cCommand)
	Method nTreeImgByType(nTipo)        
	
	Method cGetScoreName(cID)    
	Method enableObj()
	Method PersOrder(aFields)
	Method aGetPer(cID)
	Method nGenNew(aFields)
endclass
	
Method New() class TKPI010
	::NewKPI010() 
return

Method NewKPI010() class TKPI010
	// Table
	::NewTable("SGI010")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C",	10))
	::addField(TBIField():New("NOME"		,"C",	120))
	::addField(TBIField():New("DESCRICAO"	,"C",	255))
	::addField(TBIField():New("PARENTID"	,"C",	10))
	::addField(TBIField():New("VISIVEL"		,"C",	1))	  
	//Ordem dos Scorecards	
	::addField(TBIField():New("ORDEM"		,"N"	,003,00	)) 
	// Responsável
	::addField(TBIField():New("RESPID"		,"C",	10)) // ID do usuario responsavel
	::addField(TBIField():New("TIPOPESSOA"	,"C",	1)) //G = Grupo, P = Individual
	
	// Tipo de Entidade
	::addField(TBIField():New("TIPOSCORE"	,"C",	1)) //"" = Scorecard, "1" = Organização, "2" = Estratégia, "3" = Perspectiva, "4" = Objetivo

	// Indexes
	::addIndex(TBIIndex():New("SGI010I01",	{"ID"}					, .T.))
	::addIndex(TBIIndex():New("SGI010I02",	{"PARENTID"}   	   		, .F.))
	::addIndex(TBIIndex():New("SGI010I03",	{"RESPID"}				, .F.))
	::addIndex(TBIIndex():New("SGI010I04",	{"NOME"}				, .F.))	     
	::addIndex(TBIIndex():New("SGI010I05",	{"PARENTID" , "ORDEM"}	, .F.))
	::addIndex(TBIIndex():New("SGI010I06",	{"ORDEM"	, "ID" }	, .F.))       

return

Method oArvoreMatrix()	class TKPI010
	local oXMLNode 	:= TBIXMLNode():New(TAG_ENTITY)	
	
	oXMLNode:oAddChild(::oArvore(.t.,"0"))
	
Return oXMLNode


//-------------------------------------------------------------------
/*/{Protheus.doc} oArvore
Monta o XML do primeiro nível da árvore de scorecard.
@Param 	lChkAccess 	(Lógico) 	Identifica se deve ser verificado o acesso do usuário corrente.
@Param 	cIDPacote 	(Caracter) 	ID do pacote desejado.
@Param	lNoWait		(Logico)	Montar arvore sem no wait. 	
@Return (Objeto) Primeiro nível da árvore de scorecards.
@Author  BI Team
/*/
//-------------------------------------------------------------------  
Method oArvore(lChkAccess, cIDPacote, lNoWait,aSelNode) class TKPI010
	Local oUser 		:= ::oOwner():foSecurity:oLoggedUser()	
	Local lVisivel		:= .T. 
	Local oTreeNode 	:= Nil  
	Local oXMLArvore	:= Nil
	Local aPosicao		:= {}    

	Default lChkAccess 	:= .F.
	Default cIDPacote	:=	""              
	Default lNoWait		:= .F.   
	Default aSelNode	:= .F.

	aPosicao 	 	:= ::SavePos() //Guarda a posição original da tabela de scorecards.		   
    
	::SetOrder(6) //Ordena pela Ordem depois por ID.
	::_First() 
	
	If !(::lEof())
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", "0")
		oAttrib:lSet("TIPO", TAG_GROUP)
		oAttrib:lSet("NOME", ::oOwner():getStrCustom():getStrSco() )
		oAttrib:lSet("IMAGE",::nTreeImgByType(0))
        
		If (valType(aSelNode) == "A")
			oAttrib:lSet("SELECTED", IIf((aScan(aSelNode,::cValue("ID")) == 0) ,.F.,.T.))
		EndIf
                                               
		If !(cIDPacote == "" .or. cIDPacote == "0")   
			//Guarda na sessão os scorecards liberados no pacote.
			::aGetPacAccess(cIDPacote)
		EndIf

		oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)

		While(!::lEof())
 			lVisivel := Iif ( lChkAccess , !(::cValue("VISIVEL") == "F") , .T.)       
			
			If ( lVisivel .And. !(alltrim(::cValue("ID")) == "0") .And. Empty(::cValue("PARENTID")))
				//Monta um nó para ser adicionado a arvore de scorecards.				
				oTreeNode :=  ::oBuildTree(oUser:cValue("ID"), cIDPacote, lChkAccess,lNoWait,aSelNode)
				
				If !(oTreeNode == Nil) 
					//Adiciona os nós a árvore de scorecards.   
					oXMLArvore:oAddChild(oTreeNode)  
				EndIf  		 
			EndIf 
			::_Next()			
		EndDo                                                               
	EndIf  
	
	::RestPos(aPosicao) //Restaura a posição original da tabela de scorecards.
Return oXMLArvore
 
//-------------------------------------------------------------------
/*/{Protheus.doc} oArvoreTema
Monta o XML do primeiro nível da árvore de scorecard.
@Return (Objeto) Primeiro nível da árvore de scorecards.
@Author  BI Team
/*/
//------------------------------------------------------------------- 
Method oArvoreTema(cIdEstrat,aSelNode) class TKPI010
	Local oUser 		:= ::oOwner():foSecurity:oLoggedUser()	
	Local oTreeNode 	:= Nil  
	Local oXMLArvore	:= Nil
	Local aPosicao		:= {}   

	aPosicao 	 	:= ::SavePos() //Guarda a posição original da tabela de scorecards.		   
	
	If ::lSeek( 1, {cIdEstrat} )
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", "0")
		oAttrib:lSet("TIPO", TAG_GROUP)
		oAttrib:lSet("NOME", ::oOwner():getStrCustom():getStrSco() )
		oAttrib:lSet("IMAGE",::nTreeImgByType(0))
        
		oAttrib:lSet("SELECTED", IIf((aScan(aSelNode,::cValue("ID")) == 0) ,.F.,.T.))

		oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)

		//Monta um nó para ser adicionado a arvore de scorecards.				
		oTreeNode :=  ::oBuildTree(oUser:cValue("ID"),"",.F.,.T.,aSelNode)
		
		If !(oTreeNode == Nil) 
			//Adiciona os nós a árvore de scorecards.   
			oXMLArvore:oAddChild(oTreeNode)  
		EndIf  		 
	EndIf  
	
	::enableObj(oXMLArvore) //deixa apenas objetivos com enable true

	::RestPos(aPosicao) //Restaura a posição original da tabela de scorecards.
Return oXMLArvore

//-------------------------------------------------------------------
/*/{Protheus.doc} oBuildTree
Monta o XML da arvore com as permissoes.
@Param 	cIDUser 	(Caracter) 	ID do usuário corrente.
@Param 	cIDPacote 	(Caracter) 	ID do pacote desejado.
@Param	lNoWait	(Logico)		Montar arvore sem no wait. 	
@Return 			(Objeto)		Item da árvore de scorecards.
@Author  BI Team
/*/
//-------------------------------------------------------------------
Method oBuildTree(cIDUser, cIDPacote, lChkAccess,lNoWait,aSelNode) class TKPI010
	Local lHasAccess	:= .T.
	Local oAttrib 		:= TBIXMLAttrib():New()  
	Local oXMLNode		:= nil
	Local aPosicao		:= {} 
	Local cOrdem 		:= Padl(AllTrim(::cValue("ORDEM")),3,"0") 
	Local cIDSco		:= AllTrim(::cValue("ID") )           
		
	Default cIDUser		:=	""		
	Default cIDPacote	:=	""     
	Default lNoWait		:= .F.
	Default aSelNode	:= .F.
    
 	aPosicao := ::SavePos() //Guarda a posição original da tabela de scorecards.
	
	//Verifica se a permissão está sendo definida por pacote.
	If !(cIDPacote == "" .or. cIDPacote == "0")
		lHasAccess := ::lPacAccess()
	Else
		If( lChkAccess )
			//Verifica se o usuário é o responsável pelo scorecard.
			If(! empty(cIDUser) .and. alltrim(::cValue("RESPID")) == alltrim(cIDUser))
				lHasAccess := .T.
			Else 
				lHasAccess := ::lChkAccess()
			EndIf
		EndIf
	EndIf

	oAttrib:lSet("ID"		, ::cValue("ID"))
	oAttrib:lSet("NOME"		, alltrim(::cValue("NOME")))
	oAttrib:lSet("TIPOSCORE", alltrim(::cValue("TIPOSCORE")))
	oAttrib:lSet("ENABLE"	, lHasAccess)	
	oAttrib:lSet("IMAGE"   , ::nTreeImgByType(::nValue("TIPOSCORE") ) )	
    If (valType(aSelNode) == "A")
		oAttrib:lSet("SELECTED",IIf((aScan(aSelNode,::cValue("ID")) == 0) ,.F.,.T.))
	EndIf

	oXMLNode := TBIXMLNode():New(TAG_GROUP + "." + cOrdem + "." + cIDSco, "", oAttrib)	

    //Verifica se o scorecard tem filhos. 
	If (lNoWait)
		::oBuildChild(::cValue("ID"),cIdPacote,lChkAccess,.T., oXMLNode,aSelNode)		
	ElseIf ( ::lSeek(2,{::cValue("ID")}) )
		oXMLNode:oAddChild(::oBuildWait(::cValue("ID"),valType(aSelNode) == "A")) 
	EndIf

	::RestPos(aPosicao) //Restaura a posição original da tabela de scorecards.  
return oXMLNode 
  
/*-------------------------------------------------------
Monta o XML contendo o scorecard que apenas ativa o simbolo (+) da árvore de scorecards.
@Param 	cIDScorecard (Caracter) ID do scorecard no qual será indicada a existência de filhos.
@Return (Objeto) Item com conteúdo 'Aguarde...'
-------------------------------------------------------*/
Method oBuildWait(cIDScorecard,lSelect) class TKPI010
	Local oAttrib 	:= TBIXMLAttrib():New()    
	Local cOrdem 	:= Padl(AllTrim(::cValue("ORDEM")),3,"0") 
	Local cIDSco	:= AllTrim(cIDScorecard)
	
	Local oNodeWait := TBIXMLNode():New(TAG_GROUP + "." + cOrdem + "." + cIDSco + "." + "WAIT","",oAttrib)
    
	oAttrib:lSet("ID"		, AllTrim(cIDScorecard) + "." + "WAIT")
	oAttrib:lSet("NOME"		, STR0022) //"Aguarde..."
	oAttrib:lSet("TIPOSCORE", "")
	oAttrib:lSet("ENABLE"	, .F.)                                    
	oAttrib:lSet("IMAGE"   , ::nTreeImgByType(0)) 
	If (lSelect)
		oAttrib:lSet("SELECTED",.F.)
	EndIf	   
Return oNodeWait 

/*-------------------------------------------------------
Monta o XML contendo os scorecards filhos de determinado scorecard.
@Param 	cIDScorecard (Caracter) ID do scorecard do qual os filhos serão listados.
@Param 	cIDPacote (Caracter) ID do pacote desejado.   
@Param 	lChkAccess (Lógico) Identifica se deve ser verificada a permissão do usuário logado. 
@Param	lNoWait		(Logico)	Montar arvore sem no wait. 	  
@Return (Objeto) Lista de scorecards filhos.
-------------------------------------------------------*/ 
Method oBuildChild(cIDScorecard, cIDPacote, lChkAccess, lNoWait, oXMLNode, aSelNode) class TKPI010
	Local oAttrib 		:= TBIXMLAttrib():New()
	local cIDUser 		:= ::oOwner():foSecurity:oLoggedUser():cValue("ID")	

	Local oNodeChild     
 	Local aPosicao		:= {}
 	Local lAnaliseBSC	:= ::oOwner():oGetTable("PARAMETRO"):getValue("MODO_ANALISE") == ANALISE_BSC
 
	Default cIDScorecard 	:= ""
	Default cIDPacote		:= "" 
	Default lChkAccess 		:= .T.    
	Default	lNoWait			:= .F.
	Default oXMLNode 		:= TBIXMLNode():New( TAG_GROUP + "." + AllTrim( cIDScorecard ), "", oAttrib )	
	Default aSelNode		:= .F.
    
	aPosicao := ::SavePos() //Guarda a posição original da tabela de scorecards. 
    
	If  alltrim( cIDScorecard ) == "0"
		cIDScorecard := ""
	EndIf
    
	//Verifica se o scorecard tem filho.
	If ( ::lSoftSeek( 5, {cIDScorecard} ) )   
	    //Itera por todos os filhos do scorecard.
		While ( !( ::lEof() ) .And. ( AllTrim( ::cValue("PARENTID") ) == AllTrim( cIDScorecard ) ) )
			//---------------------------------------------------------
			// Apresenta o registro se o usuário tem permissão ou  
			// se o scorecard estiver visível ou se utilizar a 
			// metodologia BSC
			//---------------------------------------------------------
			iF (!lChkAccess .Or. ( lChkAccess .And. ::cValue("VISIVEL") == "T" )) .Or. lAnaliseBSC
				//Monta um nó para ser adicionado a arvore de scorecards.
				oNodeChild := ::oBuildTree( cIDUser, cIDPacote, lChkAccess, lNoWait, aSelNode )
	
		   		//Adiciona os nós a árvore de scorecards..  		                      
				oXMLNode:oAddChild( oNodeChild )	
			EndIf
			::_Next() 			
		EndDo		
	EndIf    
    
	::RestPos(aPosicao) //Restaura a posição original da tabela de scorecards.	
Return oXmlNode

/*-------------------------------------------------------
Monta o XML contendo a lista de registros.
@Param 	cComando (Caracter) Comando a ser executado.
@Return (Objeto) Lista de scorecards selecionada.
-------------------------------------------------------*/ 
Method oToXMLRecList(cComando) class TKPI010
	Local oXMLNodeLista := Nil
	Local aComandos		:= {""} 

	Local oEntity		:= nil
 	local cEntity		:= ""
	Local oPar			:= ::oOwner():oGetTable("PARAMETRO")

	Local cId
	
	Local cTipoScore	:= ""

	Default cComando 	:= ""

	//Recupera os parâmetros passados para o método.
  	aComandos := aBIToken(cComando, "|", .F.)

	Do Case  
		//Quantidade de scorecards vencidos e a vencer.
		Case aComandos[1] == "LISTA_STATUS_ACAO"
			oXMLNodeLista := ::oStatusPlanoAcao()
			
		//Lista de scorecards que o usuario possui acesso.
		Case aComandos[1] == "LISTA_SCO_OWNER"
			oXMLNodeLista := TBIXMLNode():New("LISTA")
			oXMLNodeLista:oAddChild(::oToXMLList(.T., .F.)) 
			
		//Lista de filhos de determinado scorecard. 
		Case aComandos[1] == "LISTA_SCO_CHILD"		
			oXMLNodeLista := ::oBuildChild(	aComandos[2], aComandos[3], xBIConvTo("L",aComandos[4]))
		
		//Lista os dados de determinado scorecard.				
		Case aComandos[1] == "LISTA_SCORECARD_BY_ID" 
			//Retorna apenas scorecard cujo o ID foi passado parâmetro. 			
			If ( ::lSeek(1,{aComandos[2]}) ) 			
				oXMLNodeLista := TBIXMLNode():New(TAG_ENTITY)

				cId := ::cValue("ID")

				oXMLNodeLista:oAddChild(TBIXMLNode():New("ID"		, cId))			
				oXMLNodeLista:oAddChild(TBIXMLNode():New("NOME"		, ::cValue("NOME")))              			 
			    oXMLNodeLista:oAddChild(TBIXMLNode():New("DESCRICAO", ::cValue("DESCRICAO")))                            
			 	oXMLNodeLista:oAddChild(TBIXMLNode():New("PARENTID"	, ::cValue("PARENTID")))  
				oXMLNodeLista:oAddChild(TBIXMLNode():New("VISIVEL"	, !(::cValue("VISIVEL") == "F")))
				oXMLNodeLista:oAddChild(TBIXMLNode():New("RESPID"	, ::cValue("RESPID")))
				oXMLNodeLista:oAddChild(TBIXMLNode():New("TIPOSCORE", ::cValue("TIPOSCORE")))

				//Modo de análise BSC
				If oPar:getValue("MODO_ANALISE") == ANALISE_BSC
					cTipoScore := ::cValue("TIPOSCORE")

					cEntity := ::oOwner():entityByCode( cTipoScore )

					oEntity := ::oOwner():oGetTable(cEntity)

					// Carrega Entidade
					oEntity:oToXmlNode(cId, oXMLNodeLista, {"ID"})
				EndIf
			EndIf
	EndCase
return oXMLNodeLista

/**
Carregar a entidade.
*/
Method oToXMLNode(oXMLCommand) class TKPI010
	local aFields	:= {}
	local nInd		:= 0
	local oEntity 	:= nil
 	local cEntity	:= ""
	local oPar 		:= ::oOwner():oGetTable("PARAMETRO")	
	local oXMLNode 	:= TBIXMLNode():New(TAG_ENTITY)	
	local cId 		:= ::cValue("ID")
	local cTipoScore:= ""

	aFields := ::xRecord(RF_ARRAY, {"TIPOSCORE"})// Acrescenta os valores ao XML

 	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	next
    
	//Modo de análise BSC
	If oPar:getValue("MODO_ANALISE") == ANALISE_BSC
		cTipoScore:= ::cGetXMLCommand(oXMLCommand,"ENTITY_TYPE_CODE")
	
		cEntity := ::cGetXMLCommand(oXMLCommand,"ENTITY_TYPE_NAME")

		If !empty(cEntity)
			oEntity := ::oOwner():oGetTable(cEntity)  
			oEntity:lSeek(1,{cId}) //reposicionar o registro para utilizacao do 1 em branco.
			oEntity:oToXmlNode(cId, oXMLNode, {"ID"})
		EndIf
		oEntity := nil
	EndIf

	oXMLNode:oAddChild(TBIXMLNode():New("TIPOSCORE", cTipoScore))

	oXMLNode:oAddChild(::oOwner():oGetTable("USUARIO"):oToXMLList())
	oXMLNode:oAddChild(::oArvore())
	oXMLNode:oAddChild(::oXMLLstScoPai())
return oXMLNode

/**
Insere uma nova entidade.
*/
Method nInsFromXML(oXML, cPath, oCmd) class TKPI010
	local cNome 	:= ""
	local nInd		:= 0
	local nStatus 	:= KPI_ST_OK   
	local aFields	:= {}
	local ULTIMO 	:= 999   
	local cId		:= ""

	local oEntity 	:= nil
	local cEntity 	:= ""	
	local cTipoScore:= ""
	local oPar 		:= ::oOwner():oGetTable("PARAMETRO")

	local cModoAnalise := oPar:getValue("MODO_ANALISE")

	private oXMLInput := oXML

	If cModoAnalise == ANALISE_BSC
		cEntity := ::cGetXMLCommand(oCmd, "ENTITY_TYPE_NAME")
		cTipoScore := ::cGetXMLCommand(oCmd, "ENTITY_TYPE_CODE")
	EndIf

	aFields := ::xRecord(RF_ARRAY, {"ID","TIPOSCORE"})

	For nInd := 1 To Len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))

		if aFields[nInd][1] == "ORDEM"
			If !(cModoAnalise == ANALISE_BSC .and. cEntity == "PERSPECTIVA")
				aFields[nInd][2] := ULTIMO
			EndIf
		endif
	Next 

	cId := ::cMakeID()
	aAdd( aFields, {"ID", cId} )
	aAdd( aFields, {"TIPOSCORE", cTipoScore} )

	// Caso seja perspectiva gera um novo número para ordem.
	If (cEntity == "PERSPECTIVA" .And. cTipoScore == CAD_PERSPECTIVA)
		aFields[5, 2] := ::nGenNew(aFields)
	EndIf

 	::oOwner():oOltpController():lBeginTransaction()

	If(!::lAppend(aFields))
		If(::nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		Else
			nStatus := KPI_ST_INUSE
		EndIf
	EndIf

	if nStatus == KPI_ST_OK
		//Modo de análise BSC
		If cModoAnalise == ANALISE_BSC
			oEntity := ::oOwner():oGetTable(cEntity)

			//Incluir Entidade	
			nStatus := oEntity:nInsFromXML(oXMLInput, cPath, cId)
		EndIf
	EndIf

	if nStatus != KPI_ST_OK
		::oOwner():oOltpController():lRollback()
	endif

   	::oOwner():oOltpController():lEndTransaction()

	if nStatus == KPI_ST_OK
   		::xClearCache()
	endif
return nStatus

/**
Atualiza uma entidade existente.
*/
Method nUpdFromXML(oXML, cPath, oCmd) class TKPI010
	Local cID			:= ""  
	Local cVisibilidade := ""
 	Local nInd          := 0
 	Local nStatus 		:= KPI_ST_OK
 	Local aScorecards	:= {}

	Local oEntity		:= nil
	Local cEntity		:= ""	
	Local cTipoScore	:= ""

	Local oPar			:= ::oOwner():oGetTable("PARAMETRO")

	private oXMLInput	:= oXML

	aFields := ::xRecord(RF_ARRAY)

	For nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		
		If(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		Endif	
		  
		If(aFields[nInd][1] == "VISIVEL")
			cVisibilidade := aFields[nInd][2]
		Endif

		If(aFields[nInd][1] == "TIPOSCORE")
			cTipoScore := aFields[nInd][2]
		EndIf
	Next

	If(!::lSeek(1, {cID}))		
		nStatus := KPI_ST_BADID		
	Else  		
	 	::oOwner():oOltpController():lBeginTransaction()
	
		// Rotina para modificar a ordem corretamente das perspectivas.
		If aFields[9, 2] == CAD_PERSPECTIVA
			::PersOrder(aFields)
		EndIf
	
		If(!::lUpdate(aFields))
			If(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			Else
				nStatus := KPI_ST_INUSE
			Endif			
		Else   
			//Recupera a lista de todos os scorecards filhos.
			aScorecards	:= ::aGetAllChilds(cID)

			//Replica a visibilidade do pai para todos os filhos. 
			For nInd := 1 to Len(aScorecards)					
				If(::lSeek(1,{ aScorecards[nInd] }) ) 
					If !(::lUpdate({{"VISIVEL", cVisibilidade }}))							
						If(::nLastError() == DBERROR_UNIQUE)
							nStatus := KPI_ST_UNIQUE
						Else
							nStatus := KPI_ST_INUSE
						EndIf
					EndIf
				EndIf

				if !(nStatus==KPI_ST_OK)
					EXIT
				endif
			Next i

			if nStatus == KPI_ST_OK
				//Modo de análise BSC
				If oPar:getValue("MODO_ANALISE") == ANALISE_BSC
					cEntity := ::oOwner():entityByCode( cTipoScore )

					oEntity := ::oOwner():oGetTable(cEntity)

					// Atualizar Entidade
					nStatus := oEntity:nUpdFromXML(oXMLInput, cPath, cId)
				EndIf
			EndIf

		EndIf

		if nStatus != KPI_ST_OK
			::oOwner():oOltpController():lRollback()
		endif

	   	::oOwner():oOltpController():lEndTransaction()

		if nStatus == KPI_ST_OK
	   		::xClearCache()
		endif
	Endif
return nStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} nGenNew
Método que gera um novo número de ordem para uma perspectiva com base 
na última perspectiva gerada (incrementa um).
@Param   aFields array com a estrutura da perspectiva a ser inserida.
@Return  Número com o novo número de ordem gerado.
@Author  Helio Leal
@Since   08/10/2013
/*/
//-------------------------------------------------------------------
Method nGenNew(aFields) Class TKPI010
	Local cSql 	:= ""
	Local aPos 	:= {}
	Local aOrdem 	:= {}
	Local nCnt 	:= 0
	Local nMaior	:= 0

	//Guarda a posição original da tabela de scorecards.  
	aPos := ::SavePos()
	
	//Ordena por ID.
	::SetOrder(1)
	
	// Varredura em todas as perspectivas de uma determinada estratégia.
	cSql = "PARENTID	= '" + aFields[3, 2] + "'"	
	cSql += " AND TIPOSCORE = '3'"
	cSql += " AND D_E_L_E_T_ !=	'*' "
	
	::cSQLFilter(cSql)
	::lFiltered(.t.)
	::_First()
	
	// Rotina que recebe as ordens.
	While(!::lEof())
		aAdd(aOrdem, ::nValue("ORDEM"))
		
		::_Next()
	EndDo

	::cSQLFilter("")

	//Restaura a posição original da tabela de scorecards.  
	::RestPos(aPos)

	// Rotina que recebe o maior número do array.
	For nCnt := 1 To Len(aOrdem)
		If (nMaior < aOrdem[nCnt])
			nMaior := aOrdem[nCnt]
		EndIf
	Next nCnt

Return nMaior + 1 // Incrementa um no maior.

//-------------------------------------------------------------------
/*/{Protheus.doc} PersOrder
Método Organiza a ordem da perspectiva.
@Param   aFields Array = no formato scorecards
@Author  Helio Leal
@Since   04/10/2013
/*/
//-------------------------------------------------------------------
Method PersOrder(aFields) Class TKPI010
	Local cSql 		:= ""
	Local aPosicao	:= 0
	Local aEst 		:= aClone(aFields)
	Local aPivotPer	:= {} // Perspectiva pivot.
	
	// Recebe informações da perspectiva pivot.
	aPivotPer := ::aGetPer(aFields[1, 2])

	//Guarda a posição original da tabela de scorecards.  
	aPosicao := ::SavePos()
	
	//Ordena por ID.
	::SetOrder(1)
	
	// Varredura em todas as perspectivas de uma determinada estratégia.
	cSql = "PARENTID	= '" + aFields[4, 2] + "'"	
	cSql += " AND TIPOSCORE = '3'"
	cSql += " AND D_E_L_E_T_ !=	'*' "

	::cSQLFilter(cSql)
	::lFiltered(.t.)
	::_First()

	While(!::lEof())
		// Caso a ordem seja igual e não seja o próprio registro.
		If ::nValue("ORDEM") == aFields[6, 2] .And. (!::cValue("ID") == aFields[1, 2])	
			aEst[1, 2] := ::cValue("ID")
			aEst[2, 2] := ::cValue("NOME")
			aEst[3, 2] := ::cValue("DESCRICAO")
			aEst[4, 2] := ::cValue("PARENTID")
			aEst[5, 2] := ::cValue("VISIVEL")
			aEst[6, 2] := aPivotPer[6, 2] // Passa a ordem antiga da perspectiva pivot.
			aEst[7, 2] := ::cValue("RESPID")
			aEst[8, 2] := ::cValue("TIPOPESSOA")
			aEst[9, 2] := ::cValue("TIPOSCORE")

			If !::lUpdate(aEst)
				ConOut("Erro ao alterar ordem da perspectiva.")
			EndIf
		EndIf
		::_Next()
	EndDo
	
	::cSQLFilter("")   
	
	//Restaura a posição original da tabela de scorecards.  
	::RestPos(aPosicao)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} aGetPer
Método que retorna uma perspectiva em forma de array.
@Param   cID Caracter =  Id da perspectiva que deseja.
@Author  Helio Leal
@Since   07/10/2013
/*/
//-------------------------------------------------------------------
Method aGetPer(cID) Class TKPI010	
	Local aPos := 0
	Local aPer := {}
	
	//Guarda a posição original da tabela de scorecards.  
	aPos := ::SavePos()
	
	//Ordena por ID.
	::SetOrder(1)
	::cSQLFilter("ID	= '" + cID + "'")
	::lFiltered(.t.)
	::_First()

	While(!::lEof())
		// Monta a estrutura do array conforme a tabela.
		aAdd(aPer, {"ID", 			::cValue("ID")})
		aAdd(aPer, {"NOME", 			::cValue("NOME")})
		aAdd(aPer, {"DESCRICAO", 	::cValue("DESCRICAO")})
		aAdd(aPer, {"PARENTID", 		::cValue("PARENTID")})
		aAdd(aPer, {"VISIVEL", 		::cValue("VISIVEL")})
		aAdd(aPer, {"ORDEM", 		::nValue("ORDEM")})
		aAdd(aPer, {"RESPID", 		::cValue("RESPID")})
		aAdd(aPer, {"TIPOPESSOA",	::cValue("TIPOPESSOA")})
		aAdd(aPer, {"TIPOSCORE", 	::cValue("TIPOSCORE")})

		::_Next()
	EndDo
	
	::cSQLFilter("")   
	
	//Restaura a posição original da tabela de scorecards.  
	::RestPos(aPos) 
Return aPer

/** 
Exclui uma entidade.
*/
Method nDelFromXML(cID, cDelCMD) class TKPI010
	Local nStatus 	:= KPI_ST_OK
	Local oProjeto 	:= nil
	Local oIndicador	:= nil
	Local oPlano 		:= nil
	Local oEntity 	:= nil    
	Local oTema		:= nil
	Local oTemaXObj	:= nil
	Local cTipoScore	:= ""
 	local cEntity		:= ""
	Local oPar 		:= ::oOwner():oGetTable("PARAMETRO")
	Local cMsgAux		:= ""
	Local cTextScor	:= alltrim( getJobProfString("ScoreCardName", "ScoreCard") )	

 	::oOwner():oOltpController():lBeginTransaction()

 	Do Case  
  		//Deleta o registro e todos os seus relacionamentos.  
		Case cDelCMD == "CASCATA"
			If ! ( AllTrim( cID ) == "0" .Or. Empty( AllTrim( cID ) ) )
	   			nStatus := ::nDelCascade( cID ) 
   			EndIf     
   			
		//Verifica se o registro possui relacionamento com outras tabelas
		Case cDelCMD == "NORMAL"	         
			If ! ( AllTrim( cID ) == "0" .Or. Empty( AllTrim( cID ) ) )
				//KPI014: Projeto
				oProjeto := ::oOwner():oGetTable("PROJETO") 
				
				if(oProjeto:lSeek(6,{cID}))
					::fcMsg := cErrMsg(STR0004, oProjeto:cValue("NOME"))

					nStatus := KPI_ST_VALIDATION   
				endif

				if nStatus == KPI_ST_OK
					//KPI015: Indicador
					oIndicador := ::oOwner():oGetTable("INDICADOR") 
					
					if(oIndicador:lSeek(3,{cID}))
						::fcMsg := cErrMsg(STR0005, oIndicador:cValue("NOME"))

						nStatus := KPI_ST_VALIDATION  
					endif
				endif

				if nStatus == KPI_ST_OK
					//KPI016: Plano
					oPlano := ::oOwner():oGetTable("PLANOACAO")  

					if(oPlano:lSeek(4,{cID}))
						::fcMsg := cErrMsg(STR0006, oPlano:cValue("NOME"))

						nStatus := KPI_ST_VALIDATION   
					endif
				endif

				if nStatus == KPI_ST_OK
					//Verifica se possui filhos  
					if( ::lSeek(2, {cId}) )      
						//Modo de análise BSC
						If oPar:getValue("MODO_ANALISE") == ANALISE_BSC
							Do Case
								Case ::cValue("TIPOSCORE") == CAD_ORGANIZACAO
									cMsgAux := STR0018	//"Existe a seguinte Organização relacionada a esta Entidade:"

								Case ::cValue("TIPOSCORE") == CAD_ESTRATEGIA
									cMsgAux := STR0017	//"Existe a seguinte Estratégia relacionada esta Entidade:"

								Case ::cValue("TIPOSCORE") == CAD_PERSPECTIVA
									cMsgAux := STR0019	//"Existe a seguinte Perspectiva relacionada a esta Entidade:"

								Case ::cValue("TIPOSCORE") == CAD_OBJETIVO
									cMsgAux := STR0020	//"Existe o seguinte Objetivo relacionada a esta Entidade:"

								Otherwise
									cMsgAux := STR0027 + cTextScor + STR0028 	//"Existe o seguinte "###" relacionado a esta Entidade:"
							EndCase
						Else
							cMsgAux := STR0027 + cTextScor + STR0028	//"Existe o seguinte "###" relacionado a esta Entidade:"
						EndIf						

						::fcMsg := cErrMsg(cMsgAux, ::cValue("NOME"))
						nStatus := KPI_ST_VALIDATION  
					endif
				endif

				If nStatus == KPI_ST_OK
					//KPI013: Tema Estrategico				     
					oTema := ::oOwner():oGetTable("TEMAESTRATEGICO")

					If oTema:lSeek(2,{cId})
						::fcMsg := cErrMsg(STR0015, oTema:cValue("NOME"))	//"Existe o seguinte Tema Estratégico relacionado a esta Entidade:"
						nStatus := KPI_ST_VALIDATION 					     
					EndIf
				EndIf    

				If nStatus == KPI_ST_OK
					//KPI013A: Tema Estrategigo X Objetivo
					oTemaXObj := ::oOwner():oGetTable("TEMAXOBJETIVO")

					If oTemaXObj:lSeek(3,{cId})
						If oTema:lSeek(1,{oTemaXObj:cValue("TEMAESTID")})
							::fcMsg := cErrMsg(STR0015, oTema:cValue("NOME"))	//"Existe o seguinte Tema Estratégico relacionado a esta Entidade:"
							nStatus := KPI_ST_VALIDATION
						EndIf
					EndIf
				EndIf

				if nStatus == KPI_ST_OK
					//Remove o scorecard. 
					if(::lSeek(1, {cID}))  
						cTipoScore := ::cValue("TIPOSCORE")

						//Modo de análise BSC
						If oPar:getValue("MODO_ANALISE") == ANALISE_BSC
							cEntity := ::oOwner():entityByCode( cTipoScore )

							oEntity := ::oOwner():oGetTable(cEntity)

							// Excluir Entidade
							nStatus := oEntity:nDelFromXML(cID)
						EndIf

						if nStatus == KPI_ST_OK
							if( ! ::lDelete() )
								nStatus := KPI_ST_INUSE
							else  
								//Remove as permissões. 
								nStatus := 	::oOWner():oGetTable("SCOR_X_USER"):nDelFromXML(cID, "S") 
							endif
						endif
					else
						nStatus := KPI_ST_BADID
					endif
				endif
			EndIf  
	EndCase

	if nStatus != KPI_ST_OK
		::oOwner():oOltpController():lRollback()
	endif

   	::oOwner():oOltpController():lEndTransaction()

	if nStatus == KPI_ST_OK
   		::xClearCache()
	endif
return nStatus

  
/**
Executa a remoção em cascata de um scorecards e todos os registros relacionados.
@param cID ID do Scorecards a ser removido. 
@return nStatus Indica o status da executação do processo. 
*/
Method nDelCascade(cID) class TKPI010
	Local oProjeto 		:= ::oOwner():oGetTable("PROJETO")     
	Local oIndicador 	:= ::oOwner():oGetTable("INDICADOR") 
	Local oPlano 		:= ::oOwner():oGetTable("PLANOACAO")      
	Local oTemaXObj		:= ::oOwner():oGetTable("TEMAXOBJETIVO")

	Local oEntity		:= nil
	local cEntity		:= ""
	Local oPar			:= ::oOwner():oGetTable("PARAMETRO")

	Local cIDIndicador  := ""
	Local nStatus 		:= KPI_ST_OK

	Local cTipoScore	:= ""

	Local aPosicao		:= {}

	//Remove todos os projetos do scorecard.
	if( oProjeto:lSeek(6,{cID} ))
		while(!oProjeto:lEof() .and. oProjeto:cValue("ID_SCORE") == cID )
			if(!oProjeto:lDelete())
				nStatus := KPI_ST_VALIDATION
				::fcMsg := STR0023 + alltrim(oProjeto:cValue("NOME")) + STR0024 //"O projeto "###" nao pode ser removido." 
				EXIT
			endif
			oProjeto:_Next()
		enddo
	endif

	//Remove todos os indicadores do scorecard. 
	If nStatus == KPI_ST_OK .and. oIndicador:lSeek(3,{cID})
		While(!oIndicador:lEof() .and. oIndicador:cValue("ID_SCOREC") == cID )
			cIDIndicador := oIndicador:cValue("ID")

			nStatus := oIndicador:nDelDepend(cIDIndicador, .T.)

			If nStatus == KPI_ST_OK
				If oIndicador:lSeek(3,{cID})
					If !oIndicador:lDelete()
						::fcMsg	:= STR0026 +  oIndicador:cValue("NOME") + STR0024 //"O indicador "###" nao pode ser removido."
						nStatus := KPI_ST_VALIDATION
					EndIf
				EndIf
			EndIf

			If nStatus == KPI_ST_OK
				oIndicador:_Next()
			Else
				EXIT
			EndIf
		EndDo
	EndIf

	//Remove os planos de ação do scorecard.
	if( nStatus == KPI_ST_OK .and. oPlano:lSeek(4,{cID}) )
		while(!oPlano:lEof() .And. oPlano:cValue("ID_SCOREC") == cID )
			if(!oPlano:lDelete())
				nStatus := KPI_ST_VALIDATION
				::fcMsg	:= STR0025 + alltrim(oPlano:cValue("NOME")) + STR0024 //"A ação "###" nao pode ser removido."
				EXIT
			endif
			oPlano:_Next()
		enddo
	Endif    
	
	//remove relacionamento tema estrategico x objetivo
	If nStatus == KPI_ST_OK .And.oTemaXObj:lSeek(3,{cId})
		While nStatus == KPI_ST_OK .And.oTemaXObj:lSeek(3,{cId})
			If !oTemaXObj:lDelete()
				nStatus := KPI_ST_VALIDATION
			EndIf
		End
	EndIf

	//Remove recursivamente os scorecards filhos. 
	if( nStatus == KPI_ST_OK .and. ::lSeek(2, {cId}) )	   
		while( !::lEof() .And. ::cValue("PARENTID") == cID )
			aPosicao := ::SavePos()

			nStatus := ::nDelCascade( ::cValue("ID") )

			::RestPos(aPosicao)

			if nStatus == KPI_ST_OK
				::_Next()
			else
				EXIT
			endif
		enddo		
	endif

	//Remove o scorecard. 
	if nStatus == KPI_ST_OK
		if ::lSeek(1, {cID}) 
			cTipoScore := ::cValue("TIPOSCORE")		

			//Modo de análise BSC
			If oPar:getValue("MODO_ANALISE") == ANALISE_BSC
				cEntity := ::oOwner():entityByCode( cTipoScore )

				oEntity := ::oOwner():oGetTable(cEntity)

				// Excluir Entidade
				nStatus := oEntity:nDelFromXML(cID)
			EndIf

			if nStatus == KPI_ST_OK
				if(!::lDelete())
					nStatus := KPI_ST_INUSE
				else
					//Remove as permissões dos usuário para o scorecard.
					nStatus := ::oOWner():oGetTable("SCOR_X_USER"):nDelFromXML(cID, "S")
				endif
			endif
		else
			nStatus := KPI_ST_BADID
		endif
	endif
Return nStatus


/*-------------------------------------------------------
Verifica se o usuário corrente tem acesso ao scorecard.
@Param  (Array)	 Lista de scorecards que o usuário tem acesso.	
@Return (Lógico) lHasAccess  Identifica se o usuário tem acesso.	
-------------------------------------------------------*/
Method lChkAccess(aSco_X_Usu) class TKPI010
	Local lHasAccess 	:= .F.
	Local oUser 		:= ::oOwner():foSecurity:oLoggedUser()    
    
	If (oUser:lValue("ADMIN"))
		lHasAccess	:= .T.
	Else
		Default aSco_X_Usu	:= ::aGetAccess()
		
		lHasAccess := ( ascan( aSco_X_Usu, { |x| allTrim(x[1])  == alltrim(::cValue("ID")) } ) ) > 0  
	EndIf
return lHasAccess

/*-------------------------------------------------------
Verifica se o usuário corrente tem acesso ao scorecard.
@Return lHasAccess (Lógico) Identifica se o usuário tem acesso.	
-------------------------------------------------------*/
Method lPacAccess() class TKPI010
	local lHasAccess 	:= .F.
	local aPacSco		:= ::aGetPacAccess()

	lHasAccess := ( ascan( aPacSco, { |x| alltrim(x)  == alltrim(::cValue("ID")) } ) ) > 0 
return lHasAccess
  
/**
Recupera a lista de scorecards que o usuário possui acesso.
@Return aScorecard (Array) Lista de scorecards que o usuário possui acesso.	
*/         
Method aGetAccess() class TKPI010
	Local oUsuario 	:= ::oOwner():foSecurity:oLoggedUser()
	Local aAcesso		:= {}     
         
	If ( HTTPIsWebex() ) 
		If ( ::oOwner():xSessionValue("ScoCache") == Nil )
			::oOwner():xSessionValue( "ScoCache" , ::oOwner():oGetTable("SCOR_X_USER"):aScorxUsu( oUsuario:cValue("ID") ) )	
	 	EndIf   
	 	
		aAcesso := ::oOwner():xSessionValue("ScoCache")       
	Else
		aAcesso := ::oOwner():oGetTable("SCOR_X_USER"):aScorxUsu( oUsuario:cValue("ID") )
	EndIf       
Return aClone( aAcesso )
     
/**
Recupera a lista de scorecards que o usuário possui acesso em um pacote.
@Param cIDPacote ID do pacote.
@Return aScorecard (Array) Lista de scorecards que o usuário possui acesso em um pacote.	
*/         
Method aGetPacAccess(cIDPacote) class TKPI010	 
	Local aAcesso	:= {}    	
    
    If ( HTTPIsWebex() )                 
	    If !( cIDPacote == Nil )
			::oOwner():xSessionValue( "PacCache" , ::oOwner():oGetTable("PACOTEXDEPTO"):aNodeSelect( cIDPacote ) )	
	 	EndIf  
	 	
	 	aAcesso := ::oOwner():xSessionValue("PacCache")
	Else
  		aAcesso	:= ::oOwner():oGetTable("PACOTEXDEPTO"):aNodeSelect( cIDPacote )
	EndIf     
Return aClone( aAcesso )

/*-------------------------------------------------------
Limpa o cache de scorecard do usuário.
@Return Nil 
-------------------------------------------------------*/       
Method xClearCache()  class TKPI010
Return HTTPSESSION->ScoCache := Nil      
       
/*-------------------------------------------------------
Lista com os scorecards que o usuario tem permissao de acessar respeitando a hierarquia de pais e filhos.
@Param cIDScoreCard (Caracter) ID do Scorecard que será analisado.
@Param cRespID (Caracter) ID do usuário que será analisado.
@Param lVerificar (Lógico) Indica se deves ser verificados os scorecads que o usuário tem permissão na SGI010A. 
@Param aScorecard (Array) Lista com os scorecards que o usuario tem permissao de acessar respeitando a hierarquia.
@Param aSco_X_Usu (Array) Lista com os scorecards que o usuário tem permisão de acesso.
@Param lNome (Lógico) Indica se o nome do scorecard deve ser retornado.
@Return	aScorecard (Array) Lista com os scorecards que o usuario tem permissao de acessar respeitando a hierarquia.	
-------------------------------------------------------*/
Method aScoXRegraUsu(cIDScoreCard, cRespID, lVerificar, aScorecard, aSco_X_Usu, lNome) class TKPI010
	Local 	lAddScorecard	:= .f.
	Local 	cParentID		:=	""
	//Posicionamento da tabela.
	Local aPosicao		:= {}       
	
	Default aSco_X_Usu 		:= {}
	Default aScorecard		:= {}
	Default lVerificar		:= .F.
	Default lNome 			:= .T. 
	
	//Guarda a posição original da tabela de scorecards.
	aPosicao := ::SavePos()
	
	//Posiciona no scorecard que será verificado.
	If (::lSeek(1,{cIDScoreCard}))
		//Verificar se o usuário tem acesso ao scorecard.		
		If (lVerificar)  
		    //Somente busca os dados do banco de dados se eles não estiverem em memória.
		    If ( Len(aSco_X_Usu) == 0 )
		    	//Lista todos os scorecards que o usuário tem acesso.
				aSco_X_Usu := ::oOwner():oGetTable("SCOR_X_USER"):aScorxUsu(cRespID)
		    EndIf
		    
			//Verifica se o usuário é o responsável ou possue acesso ao scorecard.
			If( (AllTrim(::cValue("RESPID")) == AllTrim(cRespID)) .Or. ::lChkAccess(aSco_X_Usu) )
				lAddScorecard	:= .T. 
			Endif
		Else
			lAddScorecard	:= .T.
		EndIf
             
        //Inclui o scorecard que está sendo verificado na lista de retorno.  
		If (lAddScorecard)
			//Inclui apenas o ID, NOME e TIPOSCORE.
			If (lNome) 
				aadd(aScorecard,{AllTrim(::cValue("ID")), AllTrim(::cValue("NOME")), AllTrim(::cValue("TIPOSCORE")) })
			//Inclui apenas o ID.
			Else
				aadd(aScorecard,AllTrim(::cValue("ID")) )
			EndIf 
		Endif
				     
        //Verifica os filhos.
		::SetOrder(2)
		
		If(::lSeek(2,{::cValue("ID")}))		
			cParentID	:= ::cValue("PARENTID")  
			
			//Realiza chamada recursiva ao método até que todos os filhos (e seus filhos) tenham sido listados.
			While(::cValue("PARENTID") == cParentID .and. ! ::lEof())                
				::aScoXRegraUsu(::cValue("ID"),cRespID,lVerificar,@aScorecard,@aSco_X_Usu,lNome)
				::_Next()
			EndDo
		Endif
	Endif
	
	::RestPos(aPosicao) //Restaura a posição original da tabela de scorecards.
return aScorecard
  
/**
Lista de todos Scorecards
@Param 	lUserFilter (Lógico) Identifica se devem ser listados apenas os scorecards que o usuário possui acesso.
@Param	lListaTudo (Lógico)Identifica se deve ser listado o scorecard ZERO.   
@Param	cZeroDesc (Caracter) Descrição a ser dada para o scorecard Zero.
@Return	oXMLNode (Objeto) XML de retorno contendo a lista de scorecads.
*/
Method oToXMLList(lUserFilter, lListaTudo, cZeroDesc) class  TKPI010
	//Armazena o objeto do usuário logado.
	local oUser			:= ::oOwner():foSecurity:oLoggedUser()
	//Objetos utilizados para a montagem do XML de retorno.
	local oNode			:= Nil 
	local oAttrib 		:= Nil 
	local oXMLNode  	:= Nil 
	//Armazena os scorecads que o usuário pode acessar.
	local aSco_X_Usu 	:= {}
	//Contador.
	Local nCount		:= 0

	Default lUserFilter := .F.  
	Default lListaTudo 	:= .F.
	Default cZeroDesc	:= STR0014 /*Todos*/ 
       
	//Montagem dos atributos do XML.
	oAttrib := TBIXMLAttrib():New()

	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)

	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", ::oOwner():getStrCustom():getStrSco())
	oAttrib:lSet("CLA000", KPI_STRING)

    //Montagem da tag SCORECARDS do XML de retorno.
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	    
	//Lista todos os scorecars.
	If(oUser:lValue("ADMIN") .Or. !(lUserFilter))
		::SetOrder(4) //Por ordem de nome.
		::_First()   
		
		While(!::lEof())			
			//Verifica se o scorecard padrão de ser listado.
			if ( !(AllTrim( SELF:cValue("ID") ) == "0") .Or. lListaTudo )				
				//Montagem das tags SCORECARD do XML de retorno.
				oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))   
				oNode:oAddChild(TBIXMLNode():New("ID"		,	::cValue("ID")))
				
				If ((lListaTudo) .And. Vazio(SELF:cValue("NOME")))  
					oNode:oAddChild(TBIXMLNode():New("NOME"		, cZeroDesc	))					 
					oNode:oAddChild(TBIXMLNode():New("TIPOSCORE", "" ))
				Else
					oNode:oAddChild(TBIXMLNode():New("NOME"		, ::cValue("NOME") ))	 
					oNode:oAddChild(TBIXMLNode():New("TIPOSCORE", ::cValue("TIPOSCORE") ))
				EndIf
			EndIf 
			::_Next()
		End
    //Lista somente os scorecars que o usuário possui acesso. 	
 	Else   
 		//Recupera todos os scorecards que o usuário tem acesso.
 		aSco_X_Usu :=  ::aGetAccess()
         
		For nCount = 1 to len(aSco_X_Usu)			
			//Montagem das tags SCORECARD do XML de retorno.
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))   
			oNode:oAddChild(TBIXMLNode():New("ID"			, aSco_X_Usu[nCount][ID]))			
			oNode:oAddChild(TBIXMLNode():New("NOME"			, aSco_X_Usu[nCount][NOME]))
			oNode:oAddChild(TBIXMLNode():New("TIPOSCORE"	, aSco_X_Usu[nCount][TIPOSCORE] ))
		Next nCount 
	EndIf
return oXMLNode

/*-------------------------------------------------------
Lista o status dos planos de acoes por scorecard.
@Return	oXMLNode (Objeto) XML de retorno contendo a lista de status dos planos de acoes.
-------------------------------------------------------*/
Method oStatusPlanoAcao() class TKPI010
	//Armazena o objeto do usuário logado.
	local oUser			:= ::oOwner():foSecurity:oLoggedUser()
    //Objetos utilizados para a montagem do XML de retorno.  
	local oXMLNodeLista
	local oAttrib
	local oXMLNode
	//Referencia os parâmetros do sistema.
	local oParametro		:= ::oOwner():oGetTable("PARAMETRO")
	//Identifica se o usuário pode visualizar todos os planos de acções de um scorecad.
	Local lShowAllPA		:= .F.
	//Define o prazo padrão para visualização de planos de ação.
	local nPrazoVenc		:= 7
	//Contador
	Local nCount 

	/*Montagem dos atributos do XML.*/
	oAttrib := TBIXMLAttrib():New()
	//Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	//Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", ::oOwner():getStrCustom():getStrSco())
	oAttrib:lSet("CLA000", KPI_STRING)
	//Vencidos
	oAttrib:lSet("TAG001", "VENCIDOS")
	oAttrib:lSet("CAB001", STR0008)//"Plano de ação Vencidos"
	oAttrib:lSet("CLA001", KPI_INT)
	//A vencer em n dias (n - é definido nos parâmetros do sistema)
	oAttrib:lSet("TAG002", "VENCIDO_7DIA")
	oAttrib:lSet("CAB002", STR0009+alltrim(str(nPrazoVenc))+iif(nPrazoVenc>1,STR0011,STR0010))//"A vencer em n dias" / (n - é definido nos parâmetros do sistema)
	oAttrib:lSet("CLA002", KPI_INT)

	//Montagem da tag "SCORECARDS" do XML de retorno. 
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
    
    //Recupera dos parâmetros do sistema o valor definido para prazo de vencimento.  
	if(oParametro:lSeek(1, {"PRAZO_PARA_VENC"}))
		nPrazoVenc := oParametro:nValue("DADO")
	endif

	//Lista todos os scorecards.
	if(oUser:lValue("ADMIN"))
		::SetOrder(4) //Ordena por nome.
		::_First()   
		   
		//Lista todos os scorecars.
		While(!::lEof())			
		    //Não lista o scorecard padrão.
			If ( !(AllTrim( ::cValue("ID") ) == "0"))				 
				 //Montagem das tags "SCORECARDS" do XML de retorno. 
				oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))   
				oNode:oAddChild(TBIXMLNode():New("ID"				,	::cValue("ID") ))
				oNode:oAddChild(TBIXMLNode():New("NOME"				,	::cValue("NOME") ))
				oNode:oAddChild(TBIXMLNode():New("TIPOSCORE"		,	::cValue("TIPOSCORE") ))
				oNode:oAddChild(TBIXMLNode():New("VENCIDOS"			,	::nCalcQtdPAVen(.f., ::cValue("ID") ,(date()-1))))
				oNode:oAddChild(TBIXMLNode():New("VENCIDO_7DIA"		,	::nCalcQtdPAVen(.t., ::cValue("ID") ,date(),date()+nPrazoVenc)))
				oNode:oAddChild(TBIXMLNode():New("SHOWALLPA"		,	.T. ))	
		    EndIf 
			::_Next()	
		Enddo
    //Lista somente os scorecars que o usuário possui acesso. 	
 	Else   	     
		//Recupera todos os scorecards que o usuário tem acesso.
 		aSco_X_Usu := ::aGetAccess()
         
		For nCount = 1 to len(aSco_X_Usu)			
			//Montagem das tags "SCORECARD" do XML de retorno.
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))   
			oNode:oAddChild(TBIXMLNode():New("ID"			, aSco_X_Usu[nCount][ID]))			
			oNode:oAddChild(TBIXMLNode():New("NOME"			, aSco_X_Usu[nCount][NOME]))  
			oNode:oAddChild(TBIXMLNode():New("TIPOSCORE"	, aSco_X_Usu[nCount][TIPOSCORE]))
			oNode:oAddChild(TBIXMLNode():New("VENCIDOS"		, ::nCalcQtdPAVen(.F., aSco_X_Usu[nCount][ID] , (date()-1))))
			oNode:oAddChild(TBIXMLNode():New("VENCIDO_7DIA"	, ::nCalcQtdPAVen(.T., aSco_X_Usu[nCount][ID] , date(),date()+nPrazoVenc)))

			//Verifica se o usuário é responsável pelo scorecard para permitir acesso a todos os scorecads.		
			If ( ::lSeek(1, {aSco_X_Usu[nCount][ID]}) ) 
				lShowAllPA := AllTrim(::cValue("RESPID")) == AllTrim(oUser:cValue("ID"))			  						
			Else
			 	lShowAllPA := .F.
			EndIf  
			
			oNode:oAddChild(TBIXMLNode():New("SHOWALLPA"	, lShowAllPA ))	
		Next nCount
    EndIf
	
	oXMLNodeLista := TBIXMLNode():New("LISTA")
	oXMLNodeLista:oAddChild(TBIXMLNode():New("DATA_ANALISE",date()))
	oXMLNodeLista:oAddChild(oXMLNode)
return oXMLNodeLista

/*-------------------------------------------------------
Quantidade de ações vencidas.
@Return	nQtdAcao (Inteiro) Quanidade de planos de ação vencidos.
@See	Status: "1=Nao Iniciada""2=Em Execucao","3=Completada","4=Esperando","5=Adiada","6=Cancelada"
-------------------------------------------------------*/ 
Method nCalcQtdPAVen(lAvencer,cIdScorec,dDataDe,dDataAte) class TKPI010
	local nQtdAcao 	:= 0
	local cOldAlias := ""
	local cSql 		:= ""
	
	cOldAlias := alias()
	
	cSql :=	" SELECT COUNT(ID)"
	cSql +=	" FROM SGI016"
	cSql +=	" WHERE STATUS		!=	'6' AND  STATUS	!= '3'"
	cSql +=	" AND TIPOACAO		=	'1'"
	cSql +=	" AND ID_SCOREC		=	'"+ cIdScorec	+ "'"

	if(lAvencer)
		cSql +=	" AND DATAFIM 		>=	'" + dTos(dDataDe)	+ "'"
		cSql +=	" AND DATAFIM 		<=	'" + dTos(dDataAte)	+ "'"		
	else
		if(! empty(dDataDe))
			cSql +=	" AND DATAFIM 	<=	'"+ dTos(dDataDe)	+ "'"
		endif
	
		if(! empty(dDataAte))
			cSql +=	" AND DATAFIM 	>=	'"+ dTos(dDataAte)	+ "'"
		endif
	endif
			
	cSql +=	" AND D_E_L_E_T_ !=	'*' "

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"__TRB",.f.,.t.)
	nQtdAcao := FieldGet(1)
	dbCloseArea()
	dbSelectArea(cOldAlias)
return nQtdAcao

/*-------------------------------------------------------
Lista dos scorecards para ser mostrada na combo de scorecard pai.
@Return	oXMLNode (Objeto) XML de retorno contendo a lista de scorecads.
-------------------------------------------------------*/
Method oXMLLstScoPai() class TKPI010
    //Objetos utilizados para a montagem do XML de retorno.  
	local oNode 
	local oXMLNode 

    //Montagem da tag "LTS_SCO_PAIS" do XML de retorno.
	oXMLNode := TBIXMLNode():New("LTS_SCO_PAIS")		
	
	 //Montagem das tags "LTS_SCO_PAI" do XML de retorno. 	
	oNode := oXMLNode:oAddChild(TBIXMLNode():New("LTS_SCO_PAI"))	
	oNode:oAddChild(TBIXMLNode():New("ID"			,	""))
	oNode:oAddChild(TBIXMLNode():New("NOME"			,	__ScoreName))
	oNode:oAddChild(TBIXMLNode():New("TIPOSCORE"	,	""))

	::SetOrder(4) //Ordena por nome.
	::_First()   
	   
	//Lista todos os scorecars.
	While(!::lEof())			
	    //Não lista o scorecard padrão.
		If ( !(AllTrim( ::cValue("ID") ) == "0"))				
			 //Montagem das tags "LTS_SCO_PAI" do XML de retorno.
			oNode := oXMLNode:oAddChild(TBIXMLNode():New("LTS_SCO_PAI"))

			oNode:oAddChild(TBIXMLNode():New("ID"		, ::cValue("ID")))
			oNode:oAddChild(TBIXMLNode():New("NOME"		, ::cValue("NOME")))
			oNode:oAddChild(TBIXMLNode():New("TIPOSCORE", ::cValue("TIPOSCORE")))
	    EndIf 
		::_Next()	
	EndDo
Return oXMLNode   

/*-------------------------------------------------------
Lista os scorecards e filhos que o usuário é responsável.
@Param	cIDUser (Caracter) ID do usuário.
@Param	aScorecard (Array) Array no formato [ID][Scorecadname] para ser complementado. 
@Param	lNome (Lógico) Indica que deve ser retornado apenas o ID do Scorecard na lista
@Return	aScorecard (Array) Lista dos scorecards e filhos que o usuário é responsável
-------------------------------------------------------*/
Method aScoXResponsavel(cIDUser, aScorecard, lNome) Class TKPI010
	Local nScorecard 	:= 0
   	Local aOwner 		:= {}
   	Local aPosicao 	:= {} //Posicionamento da tabela
   	
	Default aScorecard 	:= {}
	
	aPosicao := ::SavePos() //Guarda a posição original da tabela de scorecards.
	 
	::SetOrder(4) //Ordena por nome. 
	//Filtra os scorecads que o usuário é responsável.
	::cSQLFilter("RESPID = '" + cIDUser + "'")
	::lFiltered(.t.)
	::_First()
	
	//Recupera todos os scorecards que o usuário é responsável.
	while(!::lEof())
		aAdd(aOwner , ::cValue("ID"))	   
		::_Next()
	enddo                     

	::cSQLFilter("")   
	
	::RestPos(aPosicao) //Restaura a posição original da tabela de scorecards. 
    
    //Itera por cada scorecard que o usuário é o responsável.  
	For nScorecard := 1 To Len(aOwner)		
		//Recupera o ID e o NOME do scorecard e de todos os filhos.
		::aScoXRegraUsu(aOwner[nScorecard], cIDUser, .F. , aScorecard , {} , lNome)	
	Next nScorecard
Return aScorecard     

/** 
Executa uma ação para determinado scorecard.
@Param cID ID do scorcard.
@Param cExecCMD Identificador da ação a ser executada.
@Rerturn nStatus Status da execução. 
*/
Method nExecute(cID, cExecCMD) Class TKPI010
	Local nStatus 		:= KPI_ST_OK 
Return nStatus     

/**   
Método recursivo para recuperação de todos os filhos de um scorecard.
@param cID ID do scorecard pai   
@param aChilds 
@return 
*/
Method aGetAllChilds(cID, aChilds) Class TKPI010
	Local aPosicao	:= ::SavePos() 
	
	Default aChilds	:= {}

	cID :=  Padr( cID, 10 )      

	If(::lSeek(2,{ cID }) )
		While( ::cValue("PARENTID") == cID .And. ! ::lEof() ) 
			aAdd(aChilds, ::cValue("ID")) 
			
			::aGetAllChilds(::cValue("ID"), aChilds)
			::_Next()
		EndDo
	Endif   
	 
	::RestPos(aPosicao)	
return aChilds
                    
/**   
Método para ler os commandos XML.
@param oXmlCommand - XML com as instrucoes 
@param cCommand - Comando que se deseja recuperar
@return 
*/
Method cGetXMLCommand(oXmlCommand,cCommand) Class TKPI010
	local oIns			:= oXmlCommand:oChildByName("INSTRUCTIONS")
	local oCommand	:= oIns:oChildByName(cCommand)
	local cValue		:= "INVALID_COMMAND"
			
	if oCommand !=  Nil
		cValue := oCommand:cGetValue()
	else
		Conout(cCommand + " is not recognized as a valid command.")	
	endif
Return cValue

Method nTreeImgByType(nTipo) Class TKPI010
	local nImgTipo := 0
	
	do case
		case nTipo == 1
			nImgTipo := KPI_IMG_ORGANIZACAO
		case nTipo == 2 
			nImgTipo := KPI_IMG_ESTRATEGIA		
		case nTipo == 3
			nImgTipo :=  KPI_IMG_PERSPECTIVA		
		case nTipo == 4
			nImgTipo :=  KPI_IMG_OBJETIVO		
	endcase
return nImgTipo 
                    
/**   
Método para retornar a hierarquia de um objetivo selecionado.
@param cID - Numero do ScoreCard 
@return - Hierarquia do ID selecionado
*/
Method cGetScoreName(cID) Class TKPI010
	Local cRet			:= ''                       
	Local aPosicao	:= ::SavePos() //Guarda a posição original da tabela de scorecards.  
	Local lParentID
	Local aCampos		:= {}          
	Local nI       
	Local oPar			:= ::oOwner():oGetTable("PARAMETRO")  
	
	::lFiltered(.F.) //DESABILITA O FILTRO
	
	lParentID := ::lSeek(1,{ cID }) //POSICIONA NO ID SELECIONADO
	 
	//Modo de análise BSC
	If oPar:getValue("MODO_ANALISE") == ANALISE_BSC           
		While( lParentID )
			aAdd(aCampos,AllTrim(::cValue("NOME")))
		    	
			lParentID := ::lSeek(1,{ ::cValue("PARENTID") })
		EndDo     
		
		For nI := Len(aCampos) To 1 Step -1
			If nI > 1
				cRet += aCampos[nI]+' > '
		    Else
		    	cRet += aCampos[nI]
			EndIf    
		Next
	Else
		cRet := AllTrim(::cValue("NOME"))
	EndIf
	
	::RestPos(aPosicao) //Restaura a posição original da tabela de scorecards. 
Return cRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} lDelete
Exclui entidade

@author		BI TEAM
@version	P11 
@since		25/11/2011
/*/
//-------------------------------------------------------------------------------------
//override lDelete
method lDelete() class TKPI010
	local lOk		:= .T.
	local oPar		:= ::oOwner():oGetTable("PARAMETRO")  
	local oMapAux	:= nil
	local oMapElm	:= nil
	local nIndex	:= 0
	local cId		:= ""

	//Modo de análise BSC
	if oPar:getValue("MODO_ANALISE") == ANALISE_PDCA ;
	   .or. ::cValue("TIPOSCORE") == CAD_SCORECARD ;
	   .or. ::cValue("TIPOSCORE") == CAD_ORGANIZACAO

			lOk := _Super:lDelete()
	else	   
		//Inicia transação	
		::oOwner():oOltpController():lBeginTransaction()

		do case
			case ::cValue("TIPOSCORE") == CAD_ESTRATEGIA
				oMapAux := ::oOwner():oGetTable("MAPAESTRATEGICO")
				nIndex := 2
				cId := ::cValue("ID")
				
			case ::cValue("TIPOSCORE") == CAD_PERSPECTIVA
				oMapAux := ::oOwner():oGetTable("MAPAPERSPECTIVA")
				nIndex := 4
				cId := ::cValue("ID")

			case ::cValue("TIPOSCORE") == CAD_OBJETIVO
				cId := ""

				oMapAux := ::oOwner():oGetTable("MAPAOBJETIVO")
				oMapElm := ::oOwner():oGetTable("MAPAELEMENTO")

				while lOk .and. oMapAux:lSeek(2, {::cValue("ID")})
					//localiza elemento principal (mapa elemento)
					if oMapElm:lSeek(1, {oMapAux:cValue("ID")})
						//remove mapa objetivo via cascade
						lOk := oMapElm:lDelete()
					else
						//base inconsistente, remove elemento órfão
						lOk := oMapAux:lDelete()
					endif
				enddo
		endcase

		if lOk .and. !empty(cId)
			//Elimina elementos do mapa
			while lOk .and. oMapAux:lSeek(nIndex, {cId})
		    	lOk := oMapAux:lDelete()
			enddo
		endif

		//Elimina scorecard
		if lOk
			lOk := _Super:lDelete()
		endif

		//Commit/Rollback

		if !lOk
			::oOwner():oOltpController():lRollback()
		endif

		::oOwner():oOltpController():lEndTransaction()
	endif
return lOk
      

Method enableObj(oXML) Class TKPI010
	Local nI
	Local oNodeAux	:= nil        

	For nI := 1 To oXML:nChildCount()
		oNodeAux := oXML:oChildByPos(nI)	
    	
    	If oNodeAux:oAttrib():cValue("TIPOSCORE") == CAD_OBJETIVO
    		oNodeAux:oAttrib():lSet("ENABLE", .T.)
    	Else                                      
    		oNodeAux:oAttrib():lSet("ENABLE", .F.)
		EndIf    	 
    	 
		::enableObj(oNodeAux)     
	Next
Return

/**
Monta a mensagem de erro para tratamento de exclusão segura
@param cMsg Mensagem identificando o tipo de tabela
@param cName Nome do elemento que causou o erro
@return cRetMsg Mensagem de erro em formato HTML
*/
Static Function cErrMsg(cMsg, cName)
	Local cRetMsg := ""

	cRetMsg := "<html>"
	cRetMsg += STR0003  	//###'Exclusão não permitida'
	cRetMsg += "<br/><br/>" 
	cRetMsg += cMsg
	cRetMsg += "<br/>"
	cRetMsg += cName
	cRetMsg += "<br/><br/>"
	cRetMsg += STR0021		//###'Para prosseguir com a exclusão é necessário excluir primeiro este item.'
	cRetMsg += "</html>"
Return cRetMsg

//-------------------------------------------------------------------------------------
function _KPI010_Scorecard()
return nil 