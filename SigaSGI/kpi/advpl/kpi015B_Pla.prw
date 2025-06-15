// ######################################################################################
// Projeto: KPI 
// Modulo : Database
// Fonte  : KPI015B_Grupo.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 30.08.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI015B_Pla.ch"
/*--------------------------------------------------------------------------------------
@entity Planilha de Valores
Indicador no KPI. Contém os alvos.
Indicador de performance. Planilha de valores dos indicadores
@table KPI015B
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "PLANILHA"
#define TAG_GROUP  "PLANILHAS"
#define TEXT_ENTITY STR0001/*//"Planilha"*/
#define TEXT_GROUP  STR0002/*//"Planilhas"*/   

#define KPI_VLR_REAL		1
#define KPI_VLR_META		2
#define KPI_VLR_PREVIA		3

class TKPI015B from TBITable
	method New() constructor
	method NewKPI015B()

	// diversos registros
	method oToXMLRecList()
	method oToXMLNode()
	method oToXMLList(cParentID,nFrequencia)

	// registro atual
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)

	//diversos
	method montaCabPeriodo(iPeriodo)
	method lDateSeek(nParentID, dDataIni, nFrequencia)
	method aDateConv(dData, nFrequencia)
	method dPerToDate(nAno,nMes,nDia,nAgrupFreq)
	method lValidDate(cCampoData,cValorData,nFrequencia)
	method nCompFreq(aDataDig,aData)   
	method oGetAllYear() 
	
	method nPermiteAlt(nTipo,aData,nFrequencia,cIndicId) // nTipo 1=Real - 2=Meta - 3=Previa	
	method nRegraGeral(nTipo,aData,nFrequencia)  
	method nRegraUsuario(nTipo,aData,nFrequencia)  
	method nRegraScorecard(nTipo,aData,nFrequencia,cIndicId)  
	method cMsgDiaLimErr(nFrequencia,cAno,cMes,cDia, cIdIndic)
	method cBuildMsgErr(lPrevia, nFrequencia,cAno,cMes,cDia)    
	method aQtdFrequencia(aDataDe, aDataAte, nFrequencia)  
	method cMesAbrev(nMes)
	method aGetPeriodo(dData, nFrequencia)  
	method nValidaPeriodo(aData, dDataDe, dDataAte, nFrequencia, nTipo)    
	method nRegraDiaLimite(nTipo,aData,nFrequencia,cIndicId)   
	method nConvFreq(cFreq)	  
	
endclass
	
method New() class TKPI015B
	::NewKpi015B()
return

method NewKpi015B() class TKPI015B
	// Table
	::NewTable("SGI015B")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C"	,15))
	::addField(TBIField():New("PARENTID"	,"C"	,10))
	::addField(TBIField():New("DIA"	,"C"	,02))//Para Periodo em mes VALOR3 = DIA
	::addField(TBIField():New("MES"	,"C"	,02))//Para Periodo em mes VALOR2 = MES
	::addField(TBIField():New("ANO"	,"C"	,04))//Para Periodo em mes VALOR1 = ANO
	::addField(TBIField():New("VALOR"		,"N"	,18,06))
	::addField(TBIField():New("META"		,"N"	,18,06))
	::addField(TBIField():New("PREVIA"		,"N"	,18,06)) 
	::addField(TBIField():New("LOG"   		,"C"	,45))     

	// Indexes
	::addIndex(TBIIndex():New("SGI015BI01",{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI015BI02",{"PARENTID", "ANO", "MES", "DIA"},	.t.))
return

// Lista XML para anexar ao pai
method oToXMLList(cParentID,nFrequencia,cFiltroAno) class TKPI015B
	local oParametro	:= ::oOwner():oGetTable("PARAMETRO")
	local oNode         := nil
	local oXMLNode		:= nil
	local nInd			:= 0
	local aData 		:= {}  
	local cFilter		:= ""     
	local lDeleteLine	
	local nPermAlt
	default cFiltroAno 	:= ""
	
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,::montaCabPeriodo(nFrequencia))	
	
	if ::oOwner():foSecurity:lHasAccess("PLANILHA", "0", "CARREGAR")
	    
	    if len(cFiltroAno) > 0 
		    cFilter := "PARENTID = '"+ cParentID +"' AND ANO ='" + cFiltroAno +"'" 
	    else                                         
	    	cFilter := "PARENTID = '"+ cParentID +"'"
	    endif 
			
		// Gera recheio
		::SetOrder(2)//ParentID
		::cSQLFilter(cFilter)// Filtra pelo pai
		::lFiltered(.t.)
		::_First()
	
		
		while(! ::lEof())
			
			lDeleteLine := ::oOwner():foSecurity:lHasAccess("PLANILHA", "0", "EXCLUIR")

			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY)
	
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
	
		 	aData	:= {::cValue("ANO"),::cValue("MES"),::cValue("DIA")}  

			nPermAlt := ::nPermiteAlt(1,aData,nFrequencia,::cValue("PARENTID"))
			lDeleteLine := lDeleteLine .And. nPermAlt == KPI_PLANIND_OK 
			
		 	oNode:oAddChild(TBIXMLNode():New("EDIT_LINE_REAL"	, nPermAlt))   
		 	
			nPermAlt := ::nPermiteAlt(2,aData,nFrequencia,::cValue("PARENTID"))
			lDeleteLine := lDeleteLine .And. nPermAlt == KPI_PLANIND_OK 
			
		 	oNode:oAddChild(TBIXMLNode():New("EDIT_LINE_META"	, nPermAlt))
		 	
		 	if(oParametro:lSeek(1, {"VALOR_PREVIO"}) .And. oParametro:lValue("DADO"))
			 	nPermAlt := ::nPermiteAlt(3,aData,nFrequencia,::cValue("PARENTID"))
			else
				nPermAlt :=  KPI_PLANIND_OK
			endif
			
			lDeleteLine := lDeleteLine .And. nPermAlt == KPI_PLANIND_OK
		 	
		 	oNode:oAddChild(TBIXMLNode():New("EDIT_LINE_PREVIA"	, nPermAlt))
			oNode:oAddChild(TBIXMLNode():New("EDIT_LINE"		, ::oOwner():foSecurity:lHasAccess("PLANILHA", "0", "ALTERAR")))
		 	oNode:oAddChild(TBIXMLNode():New("DELETE_LINE"		, lDeleteLine))    
		 	oNode:oAddChild(TBIXMLNode():New("UPDATED"			, "F" ))

			::_Next()
		end
	
		::cSQLFilter("") // Encerra filtro
	endif		

return oXMLNode

/**
Verifica se o usuário tem permissão por periodo para alterar os valores na planilha. 
@nTipo 		- Tipo do dado a ser verificado - 1(Real) 2(Meta) 3(Previa) 
@aData 		- Data em array  Ano/Mes/Dia - aData[1] = 2006
@nFrequencia	- Frequencia do indicador - Diario/Mensal etc...     
@cIndicId	- Código do indicador - String    
@return:
nRet = 4 KPI_PLANIND_PERIOD  	Manutenção bloqueada para esse período.
nRet = 5 KPI_PLANIND_PERIODUSER 	Manutenção bloqueada por usuário para esse período.
nRet = 6 KPI_PLANIND_PERIODSCO 	Manutenção bloqueada por departamento para esse período.
nRet = 0 KPI_PLANIND_OK  		Permitido
*/
method nPermiteAlt(nTipo,aData,nFrequencia,cIndicId) class TKPI015B     
	local oUser 		:= ::oOwner():foSecurity:oLoggedUser()  
	local isAdmin		:= oUser:lValue("ADMIN")
	local nRet 			:= KPI_PLANIND_PERIOD 

	if(! isAdmin)        
			
		nRet := ::nRegraDiaLimite(nTipo,aData,nFrequencia,cIndicId)
		If nRet == KPI_PLANIND_OK
				   
			//Verifica permissão geral.
			nRet := ::nRegraGeral(nTipo,aData,nFrequencia) 
		       
			//Verifica permissão de usuário.
		 	if nRet != KPI_PLANIND_OK 
		 		nRet := ::nRegraUsuario(nTipo,aData,nFrequencia) 
		 	endif
	 	     
	 		//Verifica permissão de scorecard.
		 	if nRet != KPI_PLANIND_OK 
	 		   	nRet := ::nRegraScorecard(nTipo,aData,nFrequencia,cIndicId)	
		 	endif
		 EndIf
		 	
	else 
		nRet := KPI_PLANIND_OK 
	endif
	
return nRet	
         
/**
Verifica se o usuário tem permissão por DIA LIMITE para alterar os valores na planilha. 
@nTipo 			- Tipo do dado a ser verificado - 1(Real) 2(Meta) 3(Previa) 
@aData 			- Data em array  Ano/Mes/Dia - aData[1] = 2006
@nFrequencia	- Frequencia do indicador - Diario/Mensal etc...     
@cIndicId		- Código do indicador - String    
@return:		- Permite alteracao ou nao
nRet = 0 KPI_PLANIND_OK  		Permitido
nRet = 7 KPI_PLANIND_DIALIMITE	Bloqueado
*/
method nRegraDiaLimite(nTipo,aData,nFrequencia,cIndicId) class TKPI015B

	local oIndicador	:= ::oOwner():oGetTable("INDICADOR")
	local oParametro	:= ::oOwner():oGetTable("PARAMETRO")
	local nRet 			:= KPI_PLANIND_OK    
	local dDtAtual		:= date()               
	local lBlqDiaLim	:= .F.
	local aDataRef		:= {}
	local nDiaLimite         
	local dDataRef                               
	
	if(oParametro:lSeek(1, {"BLOQ_POR_DIA_LIMITE"}))
		lBlqDiaLim := oParametro:lValue("DADO")
	endif
	                                            
	if oIndicador:lSeek(1,{cIndicId}) .And. lBlqDiaLim //Bloqueio por dia limite
            
		if nFrequencia != KPI_FREQ_QUINZENAL .and. nFrequencia != KPI_FREQ_SEMANAL .and. nFrequencia != KPI_FREQ_DIARIA
			
			nDiaLimite 	:= oIndicador:nValue("DIA_LIMITE")
			dDataRef	:= dDtAtual - nDiaLimite
			aDataRef 	:= ::aDateConv(dDataRef ,nFrequencia)
			nDataDif	:= ::nCompFreq(aData,aDataRef)
			
			if nDataDif == -1 //bloqueia
				nRet := KPI_PLANIND_DIALIMITE			
			endif

		endif

	endif	

return nRet                                            


/**
Verifica permissão global para alterar valores na planilha	
@nTipo Tipo do dado a ser verificado - 1(Real) 2(Meta) 3(Previa) 
@aData Data em array  Ano/Mes/Dia - aData[1] = 2006
@nFrequencia Frequencia do indicador- Diario/Mensal etc...
*/
method nRegraGeral(nTipo,aData,nFrequencia) class TKPI015B     
	local oParametro	:= ::oOwner():oGetTable("PARAMETRO")
	local dDtCfgDe		:= cTod("//")
	local dDtCfgAte		:= cTod("//")

	do case 
		//Real
		case nTipo == KPI_VLR_REAL 
			dDtCfgDe 	:= cToD(oParametro:getValue("DATA_ALT_REALDE"))
			dDtCfgAte 	:= cToD(oParametro:getValue("DATA_ALT_REALATE"))
			
		//Meta	
		case nTipo == KPI_VLR_META 
			dDtCfgDe 	:= cToD(oParametro:getValue("DATA_ALT_METADE"))
			dDtCfgAte 	:= cToD(oParametro:getValue("DATA_ALT_METAATE"))
		
		//Previa	
		case nTipo == KPI_VLR_PREVIA 
			dDtCfgDe 	:= cToD(oParametro:getValue("DATA_ALT_PREVIADE"))
			dDtCfgAte 	:= cToD(oParametro:getValue("DATA_ALT_PREVIAATE"))
	endcase

return ::nValidaPeriodo(aData, dDtCfgDe, dDtCfgAte, nFrequencia, KPI_PLANIND_PERIOD)

/**
Verifica permissão de usuário para alterar valores na planilha
@nTipo Tipo do dado a ser verificado - 1(Real) 2(Meta) 3(Previa) 
@aData Data em array  Ano/Mes/Dia - aData[1] = 2006
@nFrequencia Frequencia do indicador - Diario/Mensal etc...  
*/
method nRegraUsuario(nTipo,aData,nFrequencia) class TKPI015B     
	local oUserCofig	:= ::oOwner():oGetTable("USU_CONFIG")   
	local dDtUsuDe		:= cTod("//")
	local dDtUsuAte		:= cTod("//")

	Do case    
		//Real
		Case nTipo == KPI_VLR_REAL 
			dDtUsuDe 	:= cToD(oUserCofig:getUserConfig("DT_USER_REALDE"))
			dDtUsuAte 	:= cToD(oUserCofig:getUserConfig("DT_USER_REALATE"))
	   
		//Meta	
		Case nTipo == KPI_VLR_META 
			dDtUsuDe 	:= cToD(oUserCofig:getUserConfig("DT_USER_METADE"))
			dDtUsuAte 	:= cToD(oUserCofig:getUserConfig("DT_USER_METAATE"))
	   
		//Previa			
		Case nTipo == KPI_VLR_PREVIA 
			dDtUsuDe 	:= cToD(oUserCofig:getUserConfig("DT_USER_PREVIADE"))
			dDtUsuAte 	:= cToD(oUserCofig:getUserConfig("DT_USER_PREVIAATE"))
	Endcase
			
return ::nValidaPeriodo(aData, dDtUsuDe, dDtUsuAte, nFrequencia, KPI_PLANIND_PERIODUSER) 

/**
Verifica permissão de scorecard para alterar valores na planilha
@nTipo Tipo do dado a ser verificado - 1(Real) 2(Meta) 3(Previa) 
@aData Data em array  Ano/Mes/Dia - aData[1] = 2006
@nFrequencia Frequencia do indicador - Diario/Mensal etc...
@cIndicId Código do indicador - "1 " 
*/ 
method nRegraScorecard(nTipo,aData,nFrequencia, cIndicId) class TKPI015B
	local oUserCofig	:= ::oOwner():oGetTable("USU_CONFIG")
	local oSco			:= ::oOwner():oGetTable("INDICADOR")
	local cScoID		:= ""
	local dDtScoDe		:= cTod("//")
	local dDtScoAte		:= cTod("//")
	local nRet 			:= KPI_PLANIND_PERIODSCO
		
	If oSco:lSeek(1,{cIndicId}) 	    
		//Recupera o ID do Scorecard. 
		cScoID := oSco:cValue("ID_SCOREC")
		
		Do Case     
	   		//Real
			Case nTipo == KPI_VLR_REAL 
				dDtScoDe 	:= cToD(oUserCofig:getUserConfig("DT_DPTO_REALDE" , cScoID, "D"))
				dDtScoAte 	:= cToD(oUserCofig:getUserConfig("DT_DPTO_REALATE", cScoID, "D"))
			
			//Meta	
			Case nTipo == KPI_VLR_META 
				dDtScoDe 	:= cToD(oUserCofig:getUserConfig("DT_DPTO_METADE" , cScoID, "D"))
				dDtScoAte 	:= cToD(oUserCofig:getUserConfig("DT_DPTO_METAATE", cScoID, "D"))
			
			//Previa	
			Case nTipo == KPI_VLR_PREVIA 
				dDtScoDe 	:= cToD(oUserCofig:getUserConfig("DT_DPTO_PREVIADE" , cScoID, "D"))
				dDtScoAte 	:= cToD(oUserCofig:getUserConfig("DT_DPTO_PREVIAATE", cScoID, "D"))
		EndCase
        
        nRet := ::nValidaPeriodo(aData, dDtScoDe, dDtScoAte, nFrequencia, KPI_PLANIND_PERIODSCO)
  	Endif
return nRet

/**  
Valida o período de alteração da planilha de valores. 
@param aData Período em alteração na planilha de valores. 
@param dDataDe Data inicial do período de alteração da planilha de valores. 
@param dDataAte Data final do período de alteração da planilha de valores. 
@param nFrequencia Frequência do indicador cuja planilha está sendo alterada. 
@param nTipo Tipo de excessão a ser lançada.
*/  
method nValidaPeriodo(aData, dDataDe, dDataAte, nFrequencia, nTipo) class TKPI015B
	Local aDataDe 	:= ::aDateConv(dDataDe ,nFrequencia)
	Local aDataAte 	:= ::aDateConv(dDataAte, nFrequencia)
	Local nRet 		:= 0
	Local nDifDe	:= 0 
	Local nDifAte   := 0
	   
	If( Empty( dDataDe ) .And. Empty( dDataAte ) )
		
		//Quando for excessão a data da excessão deve estar preenchida. 
		If (nTipo == KPI_PLANIND_PERIODUSER .Or. nTipo == KPI_PLANIND_PERIODSCO)
		  	nRet = nTipo 
		Else     
			//Quando for regra padrão a data vazia significa ausência de restrição.  
			nRet = KPI_PLANIND_OK 
		EndIf		
		
	Else        

		nDifDe := ::nCompFreq(aData,aDataDe)
		nDifAte:= iif(Empty(dDataAte), -1 , ::nCompFreq(aData,aDataAte)) 
		
		If( (nDifDe >= 0 .and. nDifDe != -99 ) .and. (nDifAte <= 0 .and. nDifAte != -99 ) )
			nRet = KPI_PLANIND_OK
		Else
			nRet = nTipo
		Endif  
		
	Endif

Return nRet

// Lista XML para anexar ao pai
method oToXMLRecList(cCmdSQL) class TKPI015B
	local oXMLNodeLista, oAttrib, oXMLNode, nInd

	oXMLNodeLista := TBIXMLNode():New("LISTA")
	
	//Colunas
	oAttrib := TBIXMLAttrib():New()
	//Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	//Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", KPI_STRING)

	//Gera o principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	//Gera o no de detalhes
	if empty(cCmdSQL)
		::SetOrder(1)
		::_First()
	else
		::cSQLFilter(cCmdSQL)
		::lFiltered(.t.)
	endif
	
	while(!::lEof())
		if( !(alltrim(::cValue("ID")) == "0"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"DESCRICAO"})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
		endif			
		::_Next()		
	end
	
	oXMLNodeLista:oAddChild(oXMLNode)
	::cSQLFilter("")

return oXMLNodeLista

// Carregar
method oToXMLNode() class TKPI015B
	local aFields, nInd
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	next

return oXMLNode
	
// Insere nova entidade
method nInsFromXML(oXML,cParentID,nFrequencia) class TKPI015B
	Local aFields
	Local nInd
	Local nStatus := KPI_ST_OK
	Local aIndTend
	Local nQtdReg:=0  
	
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID","PARENTID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))

		//Padroniza a gravacao dos campos
		if(! ::lValidDate(aFields[nInd][1],aFields[nInd][2],nFrequencia))
			nStatus	:=  KPI_ST_VALIDATION  
			exit
		endif

		if(aFields[nInd][1] == "DIA" .or. aFields[nInd][1] == "MES") 
			aFields[nInd][2] := strTran(padl(alltrim(aFields[nInd][2]),2,"0"), ".", "")
			if(val(aFields[nInd][2]) < 10)
				aFields[nInd][2] := "0" + aFields[nInd][2]
			endif
		
		elseif(aFields[nInd][1] == "ANO")
			aFields[nInd][2] := strTran(padl(alltrim(aFields[nInd][2]),4,"0"), ".", "")
		
		elseif(aFields[nInd][1] == "LOG")
		  	//Grava a data e hora de atualização da linha da planilha de valores. 
		  	aFields[nInd][2] := ( cBIStr( Date() ) + "|" + Time() ) 
		endif
	next

	if nStatus == KPI_ST_OK 
		aAdd(aFields, {"ID", ::cMakeID()})
		aAdd(aFields, {"PARENTID", cParentID})	
		
		// Grava
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		else
			//Atualizando o WorkStatus
			putGlbValue("bKpiIndUpdate","T")
		endif
	endif
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML,cParentID,nFrequencia) class TKPI015B
	local aFields, nInd, nStatus := KPI_ST_OK, aIndTend,nQtdReg:=0  
	local cAno,cMes,cDia       
	local nAReal 		:= KPI_PLANIND_OK
	local nAMeta   		:= KPI_PLANIND_OK
	local nAPrevia 		:= KPI_PLANIND_OK
	local lAddNew  		:= .f.  
	local lValorPrevio	:= .f.
	local oParametro	:= ::oOwner():oGetTable("PARAMETRO")  
		
	private oXMLInput 	:= oXML

	if(oParametro:lSeek(1, {"VALOR_PREVIO"}))
		lValorPrevio := oParametro:lValue("DADO")
	endif
	
	aFields := ::xRecord(RF_ARRAY, {"PARENTID"})
	
	// Extrai valores do XML
	for nInd := 1 to len(aFields)

		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))

		//Padroniza a gravacao dos campos
		if(! ::lValidDate(aFields[nInd][1],aFields[nInd][2],nFrequencia))
			nStatus	:=  KPI_ST_VALIDATION  
			exit
		endif
        
	
		if(aFields[nInd][1] == "DIA")  
			aFields[nInd][2] := strTran(padl(alltrim(aFields[nInd][2]),2,"0"), ".", "")
			if(val(aFields[nInd][2]) < 10)
				aFields[nInd][2] := "0" + aFields[nInd][2]
			endif
			cDia := aFields[nInd][2] 
			
		elseif(aFields[nInd][1] == "MES")
			aFields[nInd][2] := strTran(padl(alltrim(aFields[nInd][2]),2,"0"), ".", "")
			if(val(aFields[nInd][2]) < 10)
				aFields[nInd][2] := "0" + aFields[nInd][2]
			endif    
			cMes := aFields[nInd][2] 
			
		elseif(aFields[nInd][1] == "ANO")
			aFields[nInd][2] := strTran(padl(alltrim(aFields[nInd][2]),4,"0"), ".", "")
			cAno := aFields[nInd][2] 
			
		elseif(aFields[nInd][1] == "LOG")  
			//Grava a data e hora de atualização da linha da planilha de valores. 
		  	aFields[nInd][2] := ( cBIStr( Date() ) + "|" + Time() ) 
		endif
		
		if(aFields[nInd][1] == "ID")
			if(aFields[nInd][2] == "N_E_W_")
				aFields[nInd][2]:= ::cMakeID()
				lAddNew := .T.  
			endif				
			cCodID := aFields[nInd][2]			
		endif
		
	next

	//Inclusão de um novo registro em uma planilha existente.
	if(lAddNew .and. nStatus == KPI_ST_OK)
		nAReal := ::nPermiteAlt(1,{cAno,cMes,cDia},nFrequencia,cParentID)
		nAMeta := ::nPermiteAlt(2,{cAno,cMes,cDia},nFrequencia,cParentID)
		if(lValorPrevio)
			nAPrevia := ::nPermiteAlt(3,{cAno,cMes,cDia},nFrequencia,cParentID)
		endif

		 if(nAReal == KPI_PLANIND_OK .and. nAMeta == KPI_PLANIND_OK .and. nAPrevia == KPI_PLANIND_OK)
			
			aAdd(aFields, {"PARENTID", cParentID})	
            
			if(::lAppend(aFields, .T.))
				putGlbValue("bKpiIndUpdate","T")
			endif
		else          
			if nAReal == KPI_PLANIND_DIALIMITE //para o dia limite o erro é comum para todas as colunas (real,meta e previa)
				::fcMsg := ::cMsgDiaLimErr(nFrequencia,cAno,cMes,cDia,cParentId)
			else
				::fcMsg := ::cBuildMsgErr(lValorPrevio,nFrequencia,cAno,cMes,cDia)
			endif
			nStatus := KPI_ST_VALIDATION    //sem permissão
		endif
	
	//Atualização de registros em uma planilha existente.
	elseif(nStatus == KPI_ST_OK)		
		if(!::lSeek(1, {cCodID}))
			nStatus := KPI_ST_BADID
		else       
			//Gravacao do Indicador
			if(!::lUpdate(aFields))
				if(::nLastError()==DBERROR_UNIQUE)
					nStatus := KPI_ST_UNIQUE
				else
					nStatus := KPI_ST_INUSE
				endif  
			else
				//Atualizando o WorkStatus
				putGlbValue("bKpiIndUpdate","T")
			endif	
		endif		
	endif

return nStatus 
       

/**
Constroi mensagem de erro para bloqueio por dia limite
@param lPrevia Indica se a prévia será exibida. 
@param nFrequencia Frequência do indicador. 
@param cAno Ano.
@param cMes Mes.
@param cDia Dia. 
@return cRet Mensagem de erro. 
*/
method cMsgDiaLimErr(nFrequencia,cAno,cMes,cDia, cIdIndic) class TKPI015B
    
	local oIndicador := ::oOwner():oGetTable("INDICADOR")
	local cRet 
	local nFreq          
	local nMesPeriodo
	local dData                                      
	local cPeriodo
	                          
	if oIndicador:lSeek(1,{cIdIndic})
	             
		nFreq		:= ::nConvFreq(nFrequencia)
		nMesPeriodo	:= nFreq * Val(cMes)// ultimo mês do periodo  

		if nMesPeriodo == 0 //para periodicidade anual o nMesPeriodo retorna 0
			nMesPeriodo := 12 
		endif

		dData		:= lastDay(cToD('01/'+cValToChar(nMesPeriodo)+'/'+cAno))
		cPeriodo	:= oIndicador:cGetPeriodo(nFrequencia, dData)

	endif
       
    cRet := "<html><b>"
    cRet += STR0025	+ "</b><br>" //"O prazo para atualização de valores deste periodo foi ultrapassado."
    cRet += STR0026 + cPeriodo + "<br>" //"Período: "
    cRet += STR0027 + dToC(dData+oIndicador:nValue("DIA_LIMITE")) + "<br>" //"Prazo: "
	cRet += "</html>"
	
return cRet
           
/**
Converte a frequencia para multiplo de meses
@param nFreq - Frequência do indicador. 
@return nRet - multiplo da frequencia ex.(anual=12; semestral=6...)
*/
method nConvFreq(cFreq) class TKPI015B
    
	local aFreq	:= {12,6,3,4,2,1}

return aFreq[cFreq]

/**
Constroi mensagem de erro
@param lPrevia Indica se a prévia será exibida. 
@param nFrequencia Frequência do indicador. 
@param cAno Ano.
@param cMes Mes.
@param cDia Dia. 
@return cRet Mensagem de erro. 
*/
method cBuildMsgErr(lPrevia, nFrequencia,cAno,cMes,cDia) class TKPI015B   
	local oParametro	:= ::oOwner():oGetTable("PARAMETRO")
	local cRet 			:= ""
	local cRealDe       := ""	
	local cRealAte		:= ""
	local cMetaDe		:= ""
	local cMetaAte		:= ""
	local cPreviaDe		:= ""
	local cPreviaAte	:= ""
	local cRealMsg		:= ""
	local cMetaMsg		:= ""
	local cPreviaMsg	:= ""

   //Recupera a data para o Real     
	cRealDe 	:=  Alltrim(oParametro:getValue("DATA_ALT_REALDE"))
	cRealAte 	:=  Alltrim(oParametro:getValue("DATA_ALT_REALATE"))
	
	//Recupera a data para a Meta     
	cMetaDe 	:=  Alltrim(oParametro:getValue("DATA_ALT_METADE"))
	cMetaAte 	:=  Alltrim(oParametro:getValue("DATA_ALT_METAATE"))
	    
   	//Recupera a data para a Previa
   	If(lPrevia)
		cPreviaDe :=  alltrim(oParametro:getValue("DATA_ALT_PREVIADE"))
		cPreviaAte := alltrim(oParametro:getValue("DATA_ALT_PREVIAATE"))
	Endif  
         
    //Monta a mensagem para o Real.
    if(len(allTrim(cRealAte)) > 4)
		cRealMsg = STR0019 + cRealDe + STR0021 + cRealAte //"REAL - A partir de "
    else
    	cRealMsg = STR0019 + cRealDe
    endif
       
    //Monta a mensagem para a Meta.    
    if(len(allTrim(cMetaAte)) > 4)
		cMetaMsg = STR0020 + cMetaDe + STR0021 + cMetaAte //"META - A partir de "
    else
    	cMetaMsg = STR0020 + cMetaDe
    endif
    
    //Monta a mensagem para a Previa.    
   	If(lPrevia)
		If(len(allTrim(cPreviaAte)) > 4)
			cPreviaMsg = STR0018 + cPreviaDe + STR0021 + cPreviaAte //"PRÉVIA - A partir de "
		Else
    		cPreviaMsg = STR0018 + cPreviaDe
	    Endif
	Endif  

    
    cRet := "<html><b>"
    cRet += STR0022 	+ "</b><br>" //"Usuário sem permissão para incluir registro na Planilha de Valores." 
    cRet += STR0023 	+ "<br>" 	 //"Inclusão permitida para: "
    cRet += cRealMsg 	+ "<br>"
    cRet += cMetaMsg 	+ "<br>"
    cRet += cPreviaMsg	+ "<br>"
	cRet += "</html>"
return cRet


// Excluir entidade do server
method nDelFromXML(oXML) class TKPI015B
	Local aFields       := {}
	Local nInd          := 0
	Local nStatus 		:= KPI_ST_OK
	Local cIDPlanilha   := ""
	Local oAnalitico	:= oKpiCore:oGetTable("ANALITICO")
	private oXMLInput 	:= oXML
	
	aFields := ::xRecord(RF_ARRAY, {"PARENTID","DIA","MES","ANO","VALOR"})
	
	for nInd := 1 to len(aFields)
		if(aFields[nInd][1] == "ID")
			cType := ::aFields(aFields[nInd][1]):cType()
			aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))
			cIDPlanilha := aFields[nInd][2]
			exit
		endif	
	next

	If(::lSeek(1,{cIDPlanilha}))
		If(!::lDelete())
			nStatus := KPI_ST_INUSE  
		Else	
			oAnalitico:lRemove( cIDPlanilha )
		EndIf
	Else
		nStatus := KPI_ST_BADID
	EndIf	
return nStatus

/*Retorna os atributos corretos de cada periodo*/
method montaCabPeriodo(iPeriodo) class TKPI015B
	local oAttrib 		:= TBIXMLAttrib():New()
	local lValorPrevio	:= .f.
	local oParametro	:= ::oOwner():oGetTable("PARAMETRO")
	local sReal       	:= ::oOwner():getStrCustom():getStrReal() 	//"Real"
	local sMeta       	:= ::oOwner():getStrCustom():getStrMeta() 	//"Meta"
	local sPrevia     	:= ::oOwner():getStrCustom():getStrPrevia() //"Prévia"
	Local cLog			:= ""
	
	if(oParametro:lSeek(1, {"VALOR_PREVIO"}))
		lValorPrevio := oParametro:lValue("DADO")
	endif
	
	oAttrib:lSet("TIPO"		,"VALOR")
	oAttrib:lSet("RETORNA"	,"F")
	
	Do Case
		case iPeriodo == KPI_FREQ_ANUAL
			//Coluna Ano.
			oAttrib:lSet("TAG000","ANO")
			oAttrib:lSet("CAB000",STR0006)//"Ano"
			oAttrib:lSet("CLA000",KPI_FLOAT)
			oAttrib:lSet("EDT000","T")
			oAttrib:lSet("CUM000","F")
			//Coluna Valor.
			oAttrib:lSet("TAG001","VALOR")
			oAttrib:lSet("CAB001",sReal ) //"Real"
			oAttrib:lSet("CLA001",KPI_FLOAT)
			oAttrib:lSet("EDT001","T")
			oAttrib:lSet("CUM001","F")    
			//Coluna Meta.
			oAttrib:lSet("TAG002","META")
			oAttrib:lSet("CAB002",sMeta ) //"Meta"
			oAttrib:lSet("CLA002",KPI_FLOAT)
			oAttrib:lSet("EDT002","T")
			oAttrib:lSet("CUM002","F")
			
			If( lValorPrevio )
				//Coluna Previa.
				oAttrib:lSet("TAG003","PREVIA")
				oAttrib:lSet("CAB003",sPrevia ) //"Prévia"
				oAttrib:lSet("CLA003",KPI_FLOAT)
				oAttrib:lSet("EDT003","T")
				oAttrib:lSet("CUM003","F")  
			
				cLog := "4"
			Else
				cLog := "3"
			endif                           

			//Coluna Log.
			oAttrib:lSet("TAG00" + cLog,"LOG")
			oAttrib:lSet("CAB00" + cLog,"Log")//"Log"
			oAttrib:lSet("CLA00" + cLog,KPI_STRING)
			oAttrib:lSet("EDT00" + cLog,"T")
			oAttrib:lSet("CUM00" + cLog,"F")

		case iPeriodo == KPI_FREQ_SEMESTRAL
			//Coluna Semestre.
			oAttrib:lSet("TAG000","MES")
			oAttrib:lSet("CAB000",STR0007)//"Semestre"	
			oAttrib:lSet("CLA000",KPI_FLOAT)
			oAttrib:lSet("EDT000","T")
			oAttrib:lSet("CUM000","F")
			//Coluna Ano.
			oAttrib:lSet("TAG001","ANO")
			oAttrib:lSet("CAB001",STR0006)//"Ano"
			oAttrib:lSet("CLA001",KPI_FLOAT)
			oAttrib:lSet("EDT001","T")
			oAttrib:lSet("CUM001","F")
			//Coluna Valor.
			oAttrib:lSet("TAG002","VALOR")
			oAttrib:lSet("CAB002",sReal)//"Valor"
			oAttrib:lSet("CLA002",KPI_FLOAT)
			oAttrib:lSet("EDT002","T")
			oAttrib:lSet("CUM002","F")
			//Coluna Meta.
			oAttrib:lSet("TAG003","META")
			oAttrib:lSet("CAB003",sMeta)//"Meta"
			oAttrib:lSet("CLA003",KPI_FLOAT)
			oAttrib:lSet("EDT003","T")
			oAttrib:lSet("CUM003","F") 
			
			if( lValorPrevio )
				//Coluna Previa.
				oAttrib:lSet("TAG004","PREVIA")
				oAttrib:lSet("CAB004",sPrevia)//"PREVIA"
				oAttrib:lSet("CLA004",KPI_FLOAT)
				oAttrib:lSet("EDT004","T")
				oAttrib:lSet("CUM004","F")
				
				cLog := "5"
			Else
				cLog := "4"
			endif       
			
			//Coluna Log.
			oAttrib:lSet("TAG00" + cLog,"LOG")
			oAttrib:lSet("CAB00" + cLog,"Log")//"Log"
			oAttrib:lSet("CLA00" + cLog,KPI_STRING)
			oAttrib:lSet("EDT00" + cLog,"T")
			oAttrib:lSet("CUM00" + cLog,"F")
						 			
		case iPeriodo == KPI_FREQ_QUADRIMESTRAL
			//Coluna Quadrimestre.
			oAttrib:lSet("TAG000","MES")
			oAttrib:lSet("CAB000",STR0008)//"Quadrimestre"
			oAttrib:lSet("CLA000",KPI_FLOAT)
			oAttrib:lSet("EDT000","T")
			oAttrib:lSet("CUM000","F")
			//Coluna Ano.
			oAttrib:lSet("TAG001","ANO")
			oAttrib:lSet("CAB001",STR0006)//"Ano"
			oAttrib:lSet("CLA001",KPI_FLOAT)
			oAttrib:lSet("EDT001","T")
			oAttrib:lSet("CUM001","F")
			//Coluna Valor.
			oAttrib:lSet("TAG002","VALOR")
			oAttrib:lSet("CAB002",sReal)//"Valor"
			oAttrib:lSet("CLA002",KPI_FLOAT)
			oAttrib:lSet("EDT002","T")
			oAttrib:lSet("CUM002","F")     
			//Coluna Meta.
			oAttrib:lSet("TAG003","META")
			oAttrib:lSet("CAB003",sMeta)//"Meta"
			oAttrib:lSet("CLA003",KPI_FLOAT)
			oAttrib:lSet("EDT003","T")
			oAttrib:lSet("CUM003","F")  
			
			if(lValorPrevio)
				//Coluna Previa.
				oAttrib:lSet("TAG004","PREVIA")
				oAttrib:lSet("CAB004",sPrevia)//"PREVIA"
				oAttrib:lSet("CLA004",KPI_FLOAT)
				oAttrib:lSet("EDT004","T")
				oAttrib:lSet("CUM004","F")
				
				cLog := "5"
			Else
				cLog := "4"
			endif   
			
			//Coluna Log.
			oAttrib:lSet("TAG00" + cLog,"LOG")
			oAttrib:lSet("CAB00" + cLog,"Log")//"Log"
			oAttrib:lSet("CLA00" + cLog,KPI_STRING)
			oAttrib:lSet("EDT00" + cLog,"T")
			oAttrib:lSet("CUM00" + cLog,"F")
						 			
		case iPeriodo == KPI_FREQ_TRIMESTRAL
			//Coluna Trimestre.
			oAttrib:lSet("TAG000","MES")
			oAttrib:lSet("CAB000",STR0009)//"Trimestre"
			oAttrib:lSet("CLA000",KPI_FLOAT)
			oAttrib:lSet("EDT000","T")
			oAttrib:lSet("CUM000","F")
			//Coluna Ano.
			oAttrib:lSet("TAG001","ANO")
			oAttrib:lSet("CAB001",STR0006)//"Ano"
			oAttrib:lSet("CLA001",KPI_FLOAT)
			oAttrib:lSet("EDT001","T")
			oAttrib:lSet("CUM001","F")
			//Coluna Valor.
			oAttrib:lSet("TAG002","VALOR")
			oAttrib:lSet("CAB002",sReal)//"Valor"
			oAttrib:lSet("CLA002",KPI_FLOAT)
			oAttrib:lSet("EDT002","T")
			oAttrib:lSet("CUM002","F")
			//Coluna Meta.
			oAttrib:lSet("TAG003","META")
			oAttrib:lSet("CAB003",sMeta)//"Meta"
			oAttrib:lSet("CLA003",KPI_FLOAT)
			oAttrib:lSet("EDT003","T")
			oAttrib:lSet("CUM003","F") 
			
			if(lValorPrevio)
				//Coluna Previa.
				oAttrib:lSet("TAG004","PREVIA")
				oAttrib:lSet("CAB004",sPrevia)//"PREVIA"
				oAttrib:lSet("CLA004",KPI_FLOAT)
				oAttrib:lSet("EDT004","T")
				oAttrib:lSet("CUM004","F")
				
				cLog := "5"
			Else
				cLog := "4"
			endif   
			
			//Coluna Log.
			oAttrib:lSet("TAG00" + cLog,"LOG")
			oAttrib:lSet("CAB00" + cLog,"Log")//"Log"
			oAttrib:lSet("CLA00" + cLog,KPI_STRING)
			oAttrib:lSet("EDT00" + cLog,"T")
			oAttrib:lSet("CUM00" + cLog,"F")
						 			
		case iPeriodo == KPI_FREQ_BIMESTRAL
			//Coluna Bimestre.
			oAttrib:lSet("TAG000","MES")
			oAttrib:lSet("CAB000",STR0010)//"Bimestre"
			oAttrib:lSet("CLA000",KPI_FLOAT)
			oAttrib:lSet("EDT000","T")
			oAttrib:lSet("CUM000","F")
			//Coluna Ano.
			oAttrib:lSet("TAG001","ANO")
			oAttrib:lSet("CAB001",STR0006)//"Ano"
			oAttrib:lSet("CLA001",KPI_FLOAT)
			oAttrib:lSet("EDT001","T")
			oAttrib:lSet("CUM001","F")
			//Coluna Valor.
			oAttrib:lSet("TAG002","VALOR")
			oAttrib:lSet("CAB002",sReal)//"Valor"
			oAttrib:lSet("CLA002",KPI_FLOAT)
			oAttrib:lSet("EDT002","T")
			oAttrib:lSet("CUM002","F")
			//Coluna Meta.
			oAttrib:lSet("TAG003","META")
			oAttrib:lSet("CAB003",sMeta)//"Meta"
			oAttrib:lSet("CLA003",KPI_FLOAT)
			oAttrib:lSet("EDT003","T")
			oAttrib:lSet("CUM003","F")
			
			if(lValorPrevio)
				//Coluna Previa.
				oAttrib:lSet("TAG004","PREVIA")
				oAttrib:lSet("CAB004",sPrevia)//"PREVIA"
				oAttrib:lSet("CLA004",KPI_FLOAT)
				oAttrib:lSet("EDT004","T")
				oAttrib:lSet("CUM004","F")
				
				cLog := "5"
			Else
				cLog := "4"
			endif   
			
			//Coluna Log.
			oAttrib:lSet("TAG00" + cLog,"LOG")
			oAttrib:lSet("CAB00" + cLog,"Log")//"Log"
			oAttrib:lSet("CLA00" + cLog,KPI_STRING)
			oAttrib:lSet("EDT00" + cLog,"T")
			oAttrib:lSet("CUM00" + cLog,"F")
						 			
		case iPeriodo == KPI_FREQ_MENSAL
			//Coluna Mes.
			oAttrib:lSet("TAG000","MES")
			oAttrib:lSet("CAB000",STR0011)//  "Mês"
			oAttrib:lSet("CLA000",KPI_FLOAT)
			oAttrib:lSet("EDT000","T")
			oAttrib:lSet("CUM000","F")
			oAttrib:lSet("RETURN","F")
			//Coluna Ano.
			oAttrib:lSet("TAG001","ANO")
			oAttrib:lSet("CAB001",STR0006)//"Ano"
			oAttrib:lSet("CLA001",KPI_FLOAT)
			oAttrib:lSet("EDT001","T")
			oAttrib:lSet("CUM001","F")
			oAttrib:lSet("RETURN","F")
			//Coluna Valor.
			oAttrib:lSet("TAG002","VALOR")
			oAttrib:lSet("CAB002",sReal)//"Valor"
			oAttrib:lSet("CLA002",KPI_FLOAT)
			oAttrib:lSet("EDT002","T")
			oAttrib:lSet("CUM002","F")
			//Coluna Meta.
			oAttrib:lSet("TAG003","META")
			oAttrib:lSet("CAB003",sMeta)//"Meta"
			oAttrib:lSet("CLA003",KPI_FLOAT)
			oAttrib:lSet("EDT003","T")
			oAttrib:lSet("CUM003","F")
			
			if(lValorPrevio)
				//Coluna Previa.
				oAttrib:lSet("TAG004","PREVIA")
				oAttrib:lSet("CAB004",sPrevia)//"Previa"
				oAttrib:lSet("CLA004",KPI_FLOAT)
				oAttrib:lSet("EDT004","T")
				oAttrib:lSet("CUM004","F")
				
				cLog := "5"
			Else
				cLog := "4"
			endif   
			
			//Coluna Log.
			oAttrib:lSet("TAG00" + cLog,"LOG")
			oAttrib:lSet("CAB00" + cLog,"Log")//"Log"
			oAttrib:lSet("CLA00" + cLog,KPI_STRING)
			oAttrib:lSet("EDT00" + cLog,"T")
			oAttrib:lSet("CUM00" + cLog,"F")
						 			
		case iPeriodo == KPI_FREQ_QUINZENAL
			//Quinzena
			oAttrib:lSet("TAG000","DIA")
			oAttrib:lSet("CAB000",STR0012)//"Quinzena"
			oAttrib:lSet("CLA000",KPI_FLOAT)
			oAttrib:lSet("EDT000","T")
			oAttrib:lSet("CUM000","F")
			//Coluna Mes.
			oAttrib:lSet("TAG001","MES")
			oAttrib:lSet("CAB001",STR0011)//Mes.
			oAttrib:lSet("CLA001",KPI_FLOAT)
			oAttrib:lSet("EDT001","T")
			oAttrib:lSet("CUM001","F")
			//Coluna Ano.
			oAttrib:lSet("TAG002","ANO")
			oAttrib:lSet("CAB002",STR0006)//"Ano"
			oAttrib:lSet("CLA002",KPI_FLOAT)
			oAttrib:lSet("EDT002","T")
			oAttrib:lSet("CUM002","F")
			//Coluna Valor.
			oAttrib:lSet("TAG003","VALOR")
			oAttrib:lSet("CAB003",sReal)//"Valor"
			oAttrib:lSet("CLA003",KPI_FLOAT)
			oAttrib:lSet("EDT003","T")
			oAttrib:lSet("CUM003","F")
			//Coluna Meta.
			oAttrib:lSet("TAG004","META")
			oAttrib:lSet("CAB004",sMeta)//"Meta"
			oAttrib:lSet("CLA004",KPI_FLOAT)
			oAttrib:lSet("EDT004","T")
			oAttrib:lSet("CUM004","F")  
			
			if(lValorPrevio)
				//Coluna Previa.
				oAttrib:lSet("TAG005","PREVIA")
				oAttrib:lSet("CAB005",sPrevia)//"PREVIA"
				oAttrib:lSet("CLA005",KPI_FLOAT)
				oAttrib:lSet("EDT005","T")
				oAttrib:lSet("CUM005","F")
				
				cLog := "6"
			Else
				cLog := "5"
			endif  
			
			//Coluna Log.
			oAttrib:lSet("TAG00" + cLog,"LOG")
			oAttrib:lSet("CAB00" + cLog,"Log")//"Log"
			oAttrib:lSet("CLA00" + cLog,KPI_STRING)
			oAttrib:lSet("EDT00" + cLog,"T")
			oAttrib:lSet("CUM00" + cLog,"F")
						 			 
		case iPeriodo == KPI_FREQ_SEMANAL
			//Coluna Semana.
			oAttrib:lSet("TAG000","MES")
			oAttrib:lSet("CAB000",STR0014)//"Semana"
			oAttrib:lSet("CLA000",KPI_FLOAT)
			oAttrib:lSet("EDT000","T")
			oAttrib:lSet("CUM000","F")
			//Coluna Ano.
			oAttrib:lSet("TAG001","ANO")
			oAttrib:lSet("CAB001",STR0006)//"Ano"
			oAttrib:lSet("CLA001",KPI_FLOAT)
			oAttrib:lSet("EDT001","T")
			oAttrib:lSet("CUM001","F")
			//Coluna Valor.
			oAttrib:lSet("TAG002","VALOR")
			oAttrib:lSet("CAB002",sReal)//"Valor"
			oAttrib:lSet("CLA002",KPI_FLOAT)
			oAttrib:lSet("EDT002","T")
			oAttrib:lSet("CUM002","F")
			//Coluna Meta.
			oAttrib:lSet("TAG003","META")
			oAttrib:lSet("CAB003",sMeta)//"Meta"
			oAttrib:lSet("CLA003",KPI_FLOAT)
			oAttrib:lSet("EDT003","T")
			oAttrib:lSet("CUM003","F") 
			
			if(lValorPrevio)
				//Coluna Previa.
				oAttrib:lSet("TAG004","PREVIA")
				oAttrib:lSet("CAB004",sPrevia)//"PREVIA"
				oAttrib:lSet("CLA004",KPI_FLOAT)
				oAttrib:lSet("EDT004","T")
				oAttrib:lSet("CUM004","F")
				
				cLog := "5"
			Else
				cLog := "4"
			endif        
			
			//Coluna Log.
			oAttrib:lSet("TAG00" + cLog,"LOG")
			oAttrib:lSet("CAB00" + cLog,"Log")//"Log"
			oAttrib:lSet("CLA00" + cLog,KPI_STRING)
			oAttrib:lSet("EDT00" + cLog,"T")
			oAttrib:lSet("CUM00" + cLog,"F")
						 
		case iPeriodo == KPI_FREQ_DIARIA
			//Dia
			oAttrib:lSet("TAG000","DIA")
			oAttrib:lSet("CAB000",STR0015)//"Dia"
			oAttrib:lSet("CLA000",KPI_FLOAT)
			oAttrib:lSet("EDT000","T")
			oAttrib:lSet("CUM000","F")
			//Coluna Mes.
			oAttrib:lSet("TAG001","MES")
			oAttrib:lSet("CAB001",STR0011)//"Mês"
			oAttrib:lSet("CLA001",KPI_FLOAT)
			oAttrib:lSet("EDT001","T")
			oAttrib:lSet("CUM001","F")
			//Coluna Ano.
			oAttrib:lSet("TAG002","ANO")
			oAttrib:lSet("CAB002",STR0006)//"Ano"
			oAttrib:lSet("CLA002",KPI_FLOAT)
			oAttrib:lSet("EDT002","T")
			oAttrib:lSet("CUM002","F")
			//Coluna Valor.
			oAttrib:lSet("TAG003","VALOR")
			oAttrib:lSet("CAB003",sReal)//"Valor"
			oAttrib:lSet("CLA003",KPI_FLOAT)
			oAttrib:lSet("EDT003","T")
			oAttrib:lSet("CUM003","F")
			//Coluna Meta.
			oAttrib:lSet("TAG004","META")
			oAttrib:lSet("CAB004",sMeta)//"Meta"
			oAttrib:lSet("CLA004",KPI_FLOAT)
			oAttrib:lSet("EDT004","T")
			oAttrib:lSet("CUM004","F")
			
			if(lValorPrevio)
				//Coluna Previa.
				oAttrib:lSet("TAG005","PREVIA")
				oAttrib:lSet("CAB005",sPrevia)//"PREVIA"
				oAttrib:lSet("CLA005",KPI_FLOAT)
				oAttrib:lSet("EDT005","T")
				oAttrib:lSet("CUM005","F")
				
				cLog := "6"
			Else
				cLog := "5"
			endif   
			
			//Coluna Log.
			oAttrib:lSet("TAG00" + cLog,"LOG")
			oAttrib:lSet("CAB00" + cLog,"Log")//"Log"
			oAttrib:lSet("CLA00" + cLog,KPI_STRING)
			oAttrib:lSet("EDT00" + cLog,"T")
			oAttrib:lSet("CUM00" + cLog,"F")
	endcase
return 	oAttrib 

// Devolve um array com { cAno, cMes, cDia } convertida
method aDateConv(dData, nFrequencia) class TKPI015b
	Local nTempMes
	Local nTempDia
	Local cAno := "0000"
	Local cMes := "00"
	Local cDia := "00"
	          
	dData := xBIConvTo("D", dData)	
	
	// Atenção - Manter cAno, cMes e cDia com zeros na frente para evitar erros de indice
	if(nFrequencia == KPI_FREQ_ANUAL)
		cAno := strzero(year(dData), 4)
		cMes := "00"
		cDia := "00"    
		
	elseif(nFrequencia == KPI_FREQ_SEMESTRAL)
		nTempMes := iif(month(dData)>6, 2, 1)
		cAno := strzero(year(dData),4)
		cMes := strzero(nTempMes,2)
		cDia := "00"            
		
	elseif(nFrequencia == KPI_FREQ_QUADRIMESTRAL)
		nTempMes := iif(month(dData)<=4, 1, iif(month(dData)<=8, 2, 3))
		cAno := strzero(year(dData),4)
		cMes := strzero(nTempMes,2)
		cDia := "00"            
		
	elseif(nFrequencia == KPI_FREQ_TRIMESTRAL)
		nTempMes := iif(month(dData)<=3, 1, iif(month(dData)<=6, 2, iif(month(dData)<=9, 3, 4)))
		cAno := strzero(year(dData),4)
		cMes := strzero(nTempMes,2)
		cDia := "00"
	elseif(nFrequencia == KPI_FREQ_BIMESTRAL)
		nTempMes := iif(month(dData)<=2, 1, iif(month(dData)<=4, 2, iif(month(dData)<=6, 3, ;
					iif(month(dData)<=8, 4, iif(month(dData)<=10, 5, 6)))))
		cAno := strzero(year(dData),4)
		cMes := strzero(nTempMes,2)
		cDia := "00"       
		
	elseif(nFrequencia == KPI_FREQ_MENSAL)
		nTempMes := month(dData)
		cAno := strzero(year(dData),4)
		cMes := strzero(nTempMes,2)
		cDia := "00" 
		
	elseif(nFrequencia == KPI_FREQ_QUINZENAL)
		nTempDia := iif(day(dData)>15, 2, 1)
		cAno := strzero(year(dData),4)
		cMes := strzero(month(dData),2)
		cDia := strzero(nTempDia,2) 
		
	elseif(nFrequencia == KPI_FREQ_SEMANAL) 	
		   
		If( ! empty( DToS( dData ) ) ) 
			//-------------------------------------------------------------------
			// Verifica em qual semana do ano uma data se enquadra. 
			//-------------------------------------------------------------------
			If( ( Month( dData ) == 1 ) .And. ( Day( dData ) <= 3 ) .And. ( nBIWeekOfYear( dData ) > 1 ) )              
				//-------------------------------------------------------------------
				// Retorna o ano anterior. 
				//-------------------------------------------------------------------  
				cAno := StrZero( Year( dData ) - 1 ,4 )					
			ElseIf ( ( Month( dData ) == 12 ) .And. ( Day( dData ) >= 29 ) .And. ( nBIWeekOfYear( dData ) == 1 ) ) 
				//-------------------------------------------------------------------
				// Retorna o ano seguinte. 
				//-------------------------------------------------------------------  
				cAno := StrZero( Year( dData ) + 1 ,4 )				
			Else   
				//-------------------------------------------------------------------
				// Retorna o ano corrente. 
				//-------------------------------------------------------------------                               
				cAno := StrZero( Year( dData ), 4 )
			EndIf   
					
			cMes := StrZero(nBIWeekOfYear(dData),2)
			cDia := "00"
		Else
			cAno := strzero(year(dData),4)
			cMes := strzero(month(dData),2)
			cDia := strzero(day(dData),2)  
		EndIf
          
	elseif(nFrequencia == KPI_FREQ_DIARIA)
		cAno := strzero(year(dData),4)
		cMes := strzero(month(dData),2)
		cDia := strzero(day(dData),2)  
		
	endif

return {cAno, cMes, cDia}

// lDateSeek - busca pela data já convertida
method lDateSeek(cParentID, dDataIni, nFrequencia) class TKPI015B
	local aKeys := ::aDateConv(dDataIni, nFrequencia)
	aSize(aKeys, 4)
	aIns(aKeys, 1)
	aKeys[1] := cParentID
return ::lSeek(2, aKeys)

method dPerToDate(nAno,nMes,nDia,nAgrupFreq) class TKPI015B
	local dData := ctod("")
	
	do case
		case nAgrupFreq == KPI_FREQ_ANUAL          
			dData := cTod("01/01/"+ str(nAno,4) )
		case nAgrupFreq == KPI_FREQ_SEMESTRAL
			if(nMes == 1)
				dData := cTod("01/01/"+ str(nAno,4) )
			else
				dData := cTod("01/07/"+ str(nAno,4) )
			endif
		case nAgrupFreq == KPI_FREQ_QUADRIMESTRAL     
			if(nMes == 1)
				dData := cTod("01/01/"+ str(nAno,4))                                                                                                               
			elseif(nMes ==2)
				dData := cTod("01/05/"+ str(nAno,4))                                                                                                               
			else
				dData := cTod("01/09/"+ str(nAno,4))                                                                                                                           
			endif
		case nAgrupFreq == KPI_FREQ_TRIMESTRAL 
			if(nMes == 1)
				dData := cTod("01/01/"+ str(nAno,4))                                                                                                               
			elseif(nMes == 2)
				dData := cTod("01/04/"+ str(nAno,4))                                                                                                               
			elseif(nMes == 3)
				dData := cTod("01/07/"+ str(nAno,4))                                                                                                                           
			else
				dData := cTod("01/10/"+ str(nAno,4))                                                                                                                                                               
			endif
		case nAgrupFreq == KPI_FREQ_BIMESTRAL
			if(nMes == 1)
				dData := cTod("01/01/"+ str(nAno,4))
			elseif(nMes == 2)
				dData := cTod("01/03/"+ str(nAno,4))
			elseif(nMes == 3)
				dData := cTod("01/05/"+ str(nAno,4))
			elseif(nMes == 4)
				dData := cTod("01/07/"+ str(nAno,4))
			elseif(nMes == 5)
				dData := cTod("01/09/"+ str(nAno,4))
			else
				dData := cTod("01/11/"+ str(nAno,4))
			endif
		case nAgrupFreq == KPI_FREQ_MENSAL
			dData := cTod("01/" + str(nMes,2)+"/"+ str(nAno,4) )
		case nAgrupFreq == KPI_FREQ_QUINZENAL
			if(nDia == 1)
				dData := cTod("01/" + str(nMes,2)+"/"+ str(nAno,4) )
			else
				dData := cTod("16/" + str(nMes,2)+"/"+ str(nAno,4) )
			endif
		case nAgrupFreq == KPI_FREQ_SEMANAL
			dData := dBIWeekToDate(nMes, nAno)
		case nAgrupFreq == KPI_FREQ_DIARIA                      
			dData := cTod( str(nDia,2)+ "/" + str(nMes,2)+"/"+ str(nAno,4) )
		endcase

return dData

/*
* Verifica se a data e valida
*
*/
method lValidDate(cCampoData,cValorData,nFrequencia) class TKPI015B
	local lValid := .t.

	if nFrequencia == KPI_FREQ_DIARIA .and. nFrequencia == KPI_FREQ_QUINZENAL
		if (cCampoData == "DIA" .or. cCampoData == "MES" .or. cCampoData == "ANO");
			.and. cValorData == "0"
			lValid := .f.
		endif
	elseif nFrequencia == KPI_FREQ_ANUAL
		if cCampoData == "ANO"	.and. cValorData == "0"
			lValid := .f.
		endif
	else
		if (cCampoData == "MES" .or. cCampoData == "ANO")	.and. cValorData == "0"
			lValid := .f.
		endif			
	endif

	if !lValid
		::fcMsg 	:= STR0017
	endif		

return lValid
	
/*-------------------------------------------------------------------------------------
@method nCompFreq(aDataComp,aData)
Compara os periodos.
@param	aDataComp	Data de comparacao [1]:= Ano,[2]:= Mes,[3]:= Dia
		aData 		Data de comparacao [1]:= Ano,[2]:= Mes,[3]:= Dia
@return - nRetorno
			0=A Data comparada e igual a data.
			1=A Data comparada e maior que a data.
		   -1=A Data comparada e menor que a data.
		  -99=Os array tem tamanhos diferentes.
		  
create siga1776 - 04/04/2006
--------------------------------------------------------------------------------------*/
method nCompFreq(aDataComp,aData) class TKPI015B
	local	nRetorno 	:=	0
	local	nCampoDia	:=	0//Valor -1 / 0 / 1 Menor, Igual, Maior
	local 	nCampoMes	:=	0//Valor -1 / 0 / 1 Menor, Igual, Maior
	local 	nCampoAno	:=	0//Valor -1 / 0 / 1 Menor, Igual, Maior
	local 	nItem		:=	0
	local 	nTempRet	:=	0
	
	if(len(aDataComp) == len(aData))	
		//nItem := 1-Ano,2-Mes,3-Dia
		for nItem := 1 to 3
			if(nBIVal(aDataComp[nItem]) > nBIVal(aData[nItem]))
				nTempRet := 1
			elseif (nBIVal(aDataComp[nItem]) < nBIVal(aData[nItem]))
				nTempRet := -1
			else
				nTempRet := 0
			endif

			if(nItem == 1)		 
				nCampoAno	:= nTempRet
			elseif(nItem == 2)
				nCampoMes	:= nTempRet
			else
				nCampoDia	:= nTempRet
			endif
	
		next nItem

		if(nCampoAno == 0 )
			if(nCampoMes == 0)
				nRetorno := nCampoDia
			else
				nRetorno := nCampoMes
			endif
		else
			nRetorno := nCampoAno
		endif
	else
		nRetorno := -99	
	endif		
	
return nRetorno	
        

/**
Retorna todos os anos no qual exitam valores cadastrados  
@param cParentID ID do Indicador.  
@return oXMLNode
*/
method oGetAllYear(cParentID) class TKPI015B
	local oAttrib  		:= nil
	local oXMLNode   	:= nil 
	local oNode			:= nil
    local cSql			:= ""     
    local cAlias		:= getNextAlias()
    local cYear			:= alltrim(str(year(date()))) 
    local lYear			:= .f.      
	
	//Colunas
	oAttrib := TBIXMLAttrib():New()
	//Tipo
	oAttrib:lSet("TIPO", "ALLYEAR")
	oAttrib:lSet("RETORNA", .f.) 
	//ID
	oAttrib:lSet("TAG000", "ID")
	oAttrib:lSet("CAB000", "ALLYEAR")
	oAttrib:lSet("CLA000", "ID")
	
	//Nome
	oAttrib:lSet("TAG001", "NOME")
	oAttrib:lSet("CAB001", "ALLYEAR")
	oAttrib:lSet("CLA001", "NOME")

	//Gera o principal
	oXMLNode := TBIXMLNode():New("ALLYEARS",,oAttrib)
	
	cSql := "SELECT DISTINCT ANO FROM SGI015B WHERE PARENTID = '"+ cParentID +"' AND D_E_L_E_T_ <> '*'"
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),cAlias,.f.,.t.)
	DbSelectArea(cAlias)                                        
	
	oNode := oXMLNode:oAddChild(TBIXMLNode():New("ALLYEAR"))
	oNode:oAddChild(TBIXMLNode():New("ID", ""))	
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0024)) //"(Todos)"
	
	while !(cAlias)->(Eof())
		//Verifica se existe registros cadastrados para o Ano corrente  
		if cYear == alltrim((cAlias)->ANO)
			lYear := .t.
		endif  
		
		oNode := oXMLNode:oAddChild(TBIXMLNode():New("ALLYEAR"))
		oNode:oAddChild(TBIXMLNode():New("ID", (cAlias)->ANO))	
		oNode:oAddChild(TBIXMLNode():New("NOME", (cAlias)->ANO))	
		(cAlias)->(Dbskip())
	EndDo
	dbCloseArea()                             
	
	//Caso não existam registros cadastrados para o Ano corrente forçamos a inclusão
	if lYear == .f.                                             
		oNode := oXMLNode:oAddChild(TBIXMLNode():New("ALLYEAR"))
		oNode:oAddChild(TBIXMLNode():New("ID", cYear))
		oNode:oAddChild(TBIXMLNode():New("NOME", cYear))
	endif

return oXMLNode

/**
Retorna os período para uma frequência dentro de um período determinado. 
@param aDataDe
@param aDataAte
@param nFrequencia 
@return aFreq
*/
method aQtdFrequencia(aDataDe, aDataAte, nFrequencia) class TKPI015B
    local aFreq	  := {}
	local nVezes  := 1
	local nAnoDe  := val(aDataDe[1])
	local nMesDe  := val(aDataDe[2])
	local nDiaDe  := val(aDataDe[3])
	local nAnoAte := val(aDataAte[1])
	local nMesAte := val(aDataAte[2])
	local nAno	  := 0
	local nMes	  := 0 
	local nDia	  := 0
	local iCount  := 0
	local cLbl	  := ""
	local oPlan
	local dDtTemp
		
	do case
		case nFrequencia == KPI_FREQ_ANUAL
			nVezes  := (nAnoAte - nAnoDe) + 1
			for iCount := 1 to nVezes
				cLbl := padl(nAnoDe + (iCount -1), 4, "0000")
				aadd(aFreq, { {padl(nAnoDe + (iCount -1), 4) , "00", "00"},;
							   cLbl })
			next iCount
			
		case nFrequencia == KPI_FREQ_SEMESTRAL
			nAno := nAnoDe
            nMes := nMesDe 
            
			do while (nAno < nAnoAte) .or. (nMes <= nMesAte)
				cLbl := alltrim(str(nMes)) + "º " + Left(STR0007 , 3) + right(padl(nAno, 4, "0000"),2) //"º Sem/"
				aadd(aFreq, { {padl(nAno, 4, "0000"), padl(nMes, 2, "00"), "00"}, cLbl }) 
				
				nMes += 1    
				if nMes == 3
					nAno += 1
					nMes := 1
				endif
				
				if (nAno > nAnoAte) .and. (nMes == 1)                   
					exit
				endif 
			enddo
		
		case nFrequencia == KPI_FREQ_QUADRIMESTRAL
		    nAno := nAnoDe
            nMes := nMesDe 
            
			do while (nAno < nAnoAte) .or. (nMes <= nMesAte)
				cLbl := alltrim(str(nMes)) + "º " + Left(STR0008,3) + right(padl(nAno, 4, "0000"),2) //"º Qua/"
				aadd(aFreq, { {padl(nAno, 4, "0000"), padl(nMes, 2, "00"), "00"},;
				 			   cLbl	}) 
				
				nMes += 1    
				if nMes == 4
					nAno += 1
					nMes := 1
				endif
				
				if (nAno > nAnoAte) .and. (nMes == 1)                   
					exit
				endif 
			enddo
			
		case nFrequencia == KPI_FREQ_TRIMESTRAL
			nAno := nAnoDe
            nMes := nMesDe
            
			do while (nAno < nAnoAte) .or. (nMes <= nMesAte) 
				cLbl := alltrim(str(nMes)) + "º " +  Left(STR0009,3) + right(padl(nAno, 4, "0000"),2) //"º Tri/"
				aadd(aFreq, { {padl(nAno, 4, "0000"), padl(nMes, 2, "00"), "00"} ,  cLbl }) 
				
				nMes += 1    
				if nMes == 5
					nAno += 1
					nMes := 1
				endif
				
				if (nAno > nAnoAte) .and. (nMes == 1)                   
					exit
				endif 
			enddo
			
		case nFrequencia == KPI_FREQ_BIMESTRAL
			nAno := nAnoDe
            nMes := nMesDe
			do while (nAno < nAnoAte) .or. (nMes <= nMesAte)
				cLbl := alltrim(str(nMes)) + "º " + Left(STR0010,3) + right(padl(nAno, 4, "0000"),2) //"º Bim/"
				aadd(aFreq, { {padl(nAno, 4, "0000"), padl(nMes, 2, "00"), "00"},  cLbl }) 
				
				nMes += 1    
				if nMes == 7
					nAno += 1
					nMes := 1
				endif
				
				if (nAno > nAnoAte) .and. (nMes == 1)                   
					exit
				endif 
			enddo
			
		case nFrequencia == KPI_FREQ_MENSAL
            nAno := nAnoDe
            nMes := nMesDe 
            
			do while (nAno < nAnoAte) .or. (nMes <= nMesAte)
				cLbl := ::cMesAbrev(nMes) + "/" + right(padl(nAno, 4, "0000"), 2)
				aadd(aFreq, { {padl(nAno, 4, "0000"), padl(nMes, 2, "00"), "00"},  cLbl }) 
				
				nMes += 1    
				if nMes == 13
					nAno += 1
					nMes := 1
				endif   
				     
				if (nAno > nAnoAte) .and. (nMes == 1)                   
					exit
				endif 
			enddo
			
		case nFrequencia == KPI_FREQ_QUINZENAL
			nAno := nAnoDe
            nMes := nMesDe
            nDia := nDiaDe
			do while (nAno < nAnoAte) .or. (nMes < nMesAte) .or. (nDia <= nDiaDe)
				cLbl := alltrim(str(nDia)) + "º " + Left(STR0012 ,3) + ::cMesAbrev(nMes) + "/" + right(padl(nAno, 4, "0000"),2)
						
				aadd(aFreq, { {padl(nAno, 4, "0000"), padl(nMes, 2, "00"), padl(nDia, 2, "00")}, cLbl }) 
				
				nDia += 1
				if nDia == 3	 
				   	nDia := 1				
					nMes += 1    
					if nMes == 13
						nAno += 1
						nMes := 1
					endif
				 endif
				 
				if (nAno > nAnoAte) .and. (nMes == 1) .and. (nDia == 1)                 
					exit
				endif 
			enddo
			
		case nFrequencia == KPI_FREQ_SEMANAL
			nAno := nAnoDe
            nMes := nMesDe  
 
   			do while (nAno < nAnoAte) .or. (nMes <= nMesAte)
				cLbl := alltrim(str(nMes)) + "º " + Left(STR0014,3) + right(padl(nAno, 4, "0000"),2) //"º Sema/"
				aadd(aFreq, { {padl(nAno, 4, "0000"), padl(nMes, 2, "00"), "00"},  cLbl }) 
				
				nMes += 1  

				If ( nMes >= 52 )  
					dFWeekDay   	:= CToD( "04/01/" + cBIStr( nAno + 1 ) ) 
				  	dFDayLastWeek := dBIWeekToDate( nMes, nAno )
			
				    If ( dFWeekDay >= dFDayLastWeek .And. dFWeekDay <= dFDayLastWeek + 6 )                                             
						nAno += 1
						nMes := 1
					EndIf			   	
				EndIf
				
				if (nAno > nAnoAte) .and. (nMes == 1)                   
					exit
				endif 
			enddo                    
			
		case nFrequencia == KPI_FREQ_DIARIA
		 	oPlan   := ::oOwner():oGetTable("PLANILHA")
		 	dDtTemp := cTod(aDataDe[3]+'/'+aDataDe[2]+'/'+aDataDe[1])
			nVezes  := cTod(aDataAte[3]+'/'+aDataAte[2]+'/'+aDataAte[1]) - dDtTemp
			for iCount := 1 to (nVezes + 1)  
				aadd(aFreq, { oPlan:aDateConv(xbiconvto("D",dDtTemp),  KPI_FREQ_DIARIA), dtoC(dDtTemp)	})
							
				dDtTemp := cTod(aDataDe[3]+'/'+aDataDe[2]+'/'+aDataDe[1]) + iCount
			next iCount 
	endcase

return aFreq  

/**
Nome do mês abreviado.
@param nMes Número do mês que deverá ter o nome abreviado.
@return Abreviatura do nome do mês. 
*/
method cMesAbrev(nMes) class TKPI015B
	Local dData := cToD("01/" + cBIStr(nMes) + "/" + cBIStr(Year(Date())))	
return Left(mesExtenso(dData),3)

/** 
Retorna a primeira e última data de um período para uma frequênia qualquer.
@param dData Data a ser analisada.
@param nFrequencia Frequência desejada.  
@return Primeira e última data do período para a frequência.
*/
method aGetPeriodo(dData, nFrequencia) class TKPI015B                       
	Local aData 	:= ::aDateConv(dData, nFrequencia ) 
	Local nAno 		:= nBIVal(aData[1])
	Local nMes 		:= nBIVal(aData[2])	
	Local nDia 		:= nBIVal(aData[3])
	Local dInicial
	Local dFinal
	
	//Recupera a data inicial do período para qualquer a frequência. 	  
	dInicial := ::dPerToDate(nAno, nMes, nDia, nFrequencia)	  
		  	  
	do Case          
	
		//Recupera a data final do período para a frequência ANUAL.
		Case nFrequencia == KPI_FREQ_ANUAL
			dFinal := CToD("31/12/" + cBIStr(nAno)) 
		
		//Recupera a data final do período para a frequência SEMESTRAL.	
		Case nFrequencia == KPI_FREQ_SEMESTRAL  		
			If(nMes == 1)
				dFinal := cTod("30/06/" + cBIStr(nAno) )
			Else
				dFinal := cTod("31/12/" + cBIStr(nAno) )
			endIf
       
		//Recupera a data final do período para a frequência QUADRIMESTRAL.
		Case nFrequencia == KPI_FREQ_QUADRIMESTRAL
			If(nMes == 1)
				dFinal := cTod("30/04/" + cBIStr(nAno))                                                                                                               
			ElseIf(nMes ==2)
				dFinal := cTod("31/08/" + cBIStr(nAno))                                                                                                               
			Else
				dFinal := cTod("31/12/" + cBIStr(nAno))                                                                                                                           
			EndIf                       
 
		//Recupera a data final do período para a frequência TRIMESTRAL.
		Case nFrequencia == KPI_FREQ_TRIMESTRAL
  			If(nMes == 1)
				dFinal := cTod("31/03/" + cBIStr(nAno))                                                                                                               
			ElseIf(nMes == 2)
				dFinal := cTod("30/06/" + cBIStr(nAno))                                                                                                               
			ElseIf(nMes == 3)
				dFinal := cTod("30/09/" + cBIStr(nAno))                                                                                                                           
			Else
				dFinal := cTod("31/12/" + cBIStr(nAno))                                                                                                                                                               
			EndIf                                         
     
		//Recupera a data final do período para a frequência BIMESTRAL.
		Case nFrequencia == KPI_FREQ_BIMESTRAL 
			if(nMes == 1)
				dFinal := LastDay( cTod("28/02/" + cBIStr(nAno) ) )
			elseif(nMes == 2)
				dFinal := cTod("30/04/" + cBIStr(nAno))
			elseif(nMes == 3)
				dFinal := cTod("30/06/" + cBIStr(nAno))
			elseif(nMes == 4)
				dFinal := cTod("31/08/" + cBIStr(nAno))
			elseif(nMes == 5)
				dFinal := cTod("31/10/" + cBIStr(nAno))
			else
				dFinal := cTod("31/12/" + cBIStr(nAno))
			endif
       
		//Recupera a data final do período para a frequência MENSAL.
		Case nFrequencia == KPI_FREQ_MENSAL
			dFinal := LastDay( cTod("01/" + cBIStr(nMes) + "/" + cBIStr(nAno) ) )
          
   		//Recupera a data final do período para a frequência QUINZENAL.        	
		Case nFrequencia == KPI_FREQ_QUINZENAL
			If(nDia == 1)
				dFinal := cTod("15/" + cBIStr(nMes) + "/" + cBIStr(nAno) )
			Else
				dFinal := LastDay( cTod("01/" + cBIStr(nMes) + "/" + cBIStr(nAno) ) )
			EndIf  
			            
   		//Recupera a data final do período para a frequência SEMANAL.
		Case nFrequencia == KPI_FREQ_SEMANAL
			dFinal := ( dBIWeekToDate(nMes, nAno) + 6 )           

   		//Recupera a data final do período para a frequência DIARIA.
		Case nFrequencia == KPI_FREQ_DIARIA	
   			dfinal := dInicial
	EndCase	

Return { dInicial, dFinal }

function _KPI015B_Grupo()
return nil
