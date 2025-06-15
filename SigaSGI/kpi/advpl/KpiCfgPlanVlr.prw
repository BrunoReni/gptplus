// ######################################################################################
// Projeto: KPI
// Modulo : Configuração - Restrição de acesso 
// Fonte  : KPICFGPLANVLR.PRW
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 12.12.07 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch" 
#include "KPI001_Par.ch"     


#define TAG_ENTITY "CFGPLANVLR"
#define TAG_GROUP  "CFGPLANVLR"


class TKPICfgPlanVlr from TBITable
	method New() constructor
	method NewKPIChangeImg()

	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath,cUserID)
	method nExecute(cID, cExecCMD)
	method oPermAltIndicador()   
	method oPermDptoAlt()
	
endclass

method New() class TKPICfgPlanVlr
	::NewKPIChangeImg()
return

method NewKPIChangeImg() class TKPICfgPlanVlr
	::NewObject()
return
                                                                              
// Carregar
method oToXMLNode() class TKPICfgPlanVlr
	local oXMLNode 		:= TBIXMLNode():New(TAG_ENTITY)
	local oParametro	:= ::oOwner():oGetTable("PARAMETRO") 


	oXMLNode:oAddChild(TBIXMLNode():New("DATA_ALT_REALDE",		oParametro:getValue("DATA_ALT_REALDE")))
	oXMLNode:oAddChild(TBIXMLNode():New("DATA_ALT_REALATE",		oParametro:getValue("DATA_ALT_REALATE")))   
	oXMLNode:oAddChild(TBIXMLNode():New("DATA_ALT_METADE",		oParametro:getValue("DATA_ALT_METADE")))   
	oXMLNode:oAddChild(TBIXMLNode():New("DATA_ALT_METAATE",		oParametro:getValue("DATA_ALT_METAATE")))   
	oXMLNode:oAddChild(TBIXMLNode():New("DATA_ALT_PREVIADE",	oParametro:getValue("DATA_ALT_PREVIADE")))   
	oXMLNode:oAddChild(TBIXMLNode():New("DATA_ALT_PREVIAATE",	oParametro:getValue("DATA_ALT_PREVIAATE")))   
	oXMLNode:oAddChild(TBIXMLNode():New("BLOQ_POR_DIA_LIMITE",	oParametro:getValue("BLOQ_POR_DIA_LIMITE")))
	oXMLNode:oAddChild(TBIXMLNode():New("MSG_BLOQ_DIA_LIMITE",	oParametro:getValue("MSG_BLOQ_DIA_LIMITE")))
	
	oXMLNode:oAddChild(::oPermAltIndicador())	
	oXMLNode:oAddChild(::oPermDptoAlt())				
	
return oXMLNode


//Atualizacao 
method nUpdFromXML(oXML, cPath,cUserID) class TKPICfgPlanVlr
	local oUserCofig	:= ::oOwner():oGetTable("USU_CONFIG")
	local oParametro	:= ::oOwner():oGetTable("PARAMETRO")
	local nStatus 		:= KPI_ST_OK
	local nDatas 		:= 0
	local nQtdReg		:= 0
	private oTmpNode
	private oXMLInput	:= oXML

    if nStatus == KPI_ST_OK
    	nStatus := oParametro:setValue( "DATA_ALT_REALDE", alltrim(oXMLInput:_REGISTROS:_CFGPLANVLR:_DATA_ALT_REALDE:TEXT) )
    endif
    if nStatus == KPI_ST_OK
    	nStatus := oParametro:setValue( "DATA_ALT_REALATE", alltrim(oXMLInput:_REGISTROS:_CFGPLANVLR:_DATA_ALT_REALATE:TEXT) )
    endif
    if nStatus == KPI_ST_OK
    	nStatus := oParametro:setValue( "DATA_ALT_METADE", alltrim(oXMLInput:_REGISTROS:_CFGPLANVLR:_DATA_ALT_METADE:TEXT) )
    endif
    if nStatus == KPI_ST_OK
    	nStatus := oParametro:setValue( "DATA_ALT_METAATE", alltrim(oXMLInput:_REGISTROS:_CFGPLANVLR:_DATA_ALT_METAATE:TEXT) )
    endif
    if nStatus == KPI_ST_OK
    	nStatus := oParametro:setValue( "DATA_ALT_PREVIADE", alltrim(oXMLInput:_REGISTROS:_CFGPLANVLR:_DATA_ALT_PREVIADE:TEXT) )
    endif
    if nStatus == KPI_ST_OK
    	nStatus := oParametro:setValue( "DATA_ALT_PREVIAATE", alltrim(oXMLInput:_REGISTROS:_CFGPLANVLR:_DATA_ALT_PREVIAATE:TEXT) )
    endif        
    if nStatus == KPI_ST_OK
    	nStatus := oParametro:setValue( "BLOQ_POR_DIA_LIMITE", alltrim(oXMLInput:_REGISTROS:_CFGPLANVLR:_BLOQ_POR_DIA_LIMITE:TEXT) )
    endif                
    if nStatus == KPI_ST_OK
    	nStatus := oParametro:setValue( "MSG_BLOQ_DIA_LIMITE", alltrim(oXMLInput:_REGISTROS:_CFGPLANVLR:_MSG_BLOQ_DIA_LIMITE:TEXT) )
    endif        
 
	//Gravando da datas de execao para alteracao da planilha de valores.
	if nStatus == KPI_ST_OK
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_PERMISSOES_ALTERACAO"), "_PERMISSAO_ALTERACAO"))!="U")
			aRegNode := &("oXMLInput:"+cPath+":_PERMISSOES_ALTERACAO")
			if(valtype(aRegNode:_PERMISSAO_ALTERACAO)=="A")
				for nQtdReg := 1 to len(aRegNode:_PERMISSAO_ALTERACAO)
					oTmpNode 	:= aRegNode:_PERMISSAO_ALTERACAO
					for nDatas := 4 to 9  //Atualiza os campos de datas
						nStatus		:= oUserCofig:nUpdFromXML(oTmpNode[nQtdReg],"",cBiStr(oTmpNode[nQtdReg]:_USUARIOID:TEXT),nDatas,"")
						if(nStatus != KPI_ST_OK)
							exit
						endif
					next nDatas	
				next nQtdReg
			elseif(valtype(aRegNode:_PERMISSAO_ALTERACAO)=="O")
				oTmpNode	:= aRegNode:_PERMISSAO_ALTERACAO 
				for nDatas 	:= 4 to 9  //Atualiza os campos de datas
				nStatus		:= oUserCofig:nUpdFromXML(oTmpNode	,"",cBiStr(oTmpNode:_USUARIOID:TEXT),nDatas,"")
					if(nStatus != KPI_ST_OK)
						exit
					endif
				next nDatas	
			endif
		endif
	endif
	
    
	//Gravando da datas de execao do scorecarding para alteracao da planilha de valores.
	if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_PERMISSOES_ALTERACAO_DPTO"), "_PERMISSAO_ALTERACAO_DPTO"))!="U")
		aRegNode := &("oXMLInput:"+cPath+":_PERMISSOES_ALTERACAO_DPTO")
		if(valtype(aRegNode:_PERMISSAO_ALTERACAO_DPTO)=="A")
			for nQtdReg := 1 to len(aRegNode:_PERMISSAO_ALTERACAO_DPTO)
				oTmpNode 	:= aRegNode:_PERMISSAO_ALTERACAO_DPTO  
				for nDatas := 10 to 15  //Atualiza os campos de datas
						nStatus	:= oUserCofig:nUpdFromXML(oTmpNode[nQtdReg],"",cBiStr(oTmpNode[nQtdReg]:_SCORECARDID:TEXT),nDatas,"D")
					if(nStatus != KPI_ST_OK)
					   	exit
					endif
				next nDatas	
			next nQtdReg
		elseif(valtype(aRegNode:_PERMISSAO_ALTERACAO_DPTO)=="O")
			oTmpNode	:= aRegNode:_PERMISSAO_ALTERACAO_DPTO    
			for nDatas 	:= 10 to 15  //Atualiza os campos de datas
			nStatus		:= oUserCofig:nUpdFromXML(oTmpNode,"",cBiStr(oTmpNode:_SCORECARDID:TEXT),nDatas,"D")
				if(nStatus != KPI_ST_OK)
				   	exit
				endif
			next nDatas	
		endif
	endif    
return nStatus



/*
*Xml com os usuario e datas que eles estao autorizado a fazer alteracao na planilha de valor
*/
method oPermAltIndicador() class TKPICfgPlanVlr
	local oUserCofig	:= ::oOwner():oGetTable("USU_CONFIG")
	local oUser			:= ::oOwner():oGetTable("USUARIO")
	local cUserID		:= ""
	local dValorProp	:= cTod("//")	
	local oAttrib 		:= TBIXMLAttrib():New()
	local oNode, oXMLNode
	
	// Tipo
	oAttrib:lSet("TIPO", "PERMISSOES_ALTERACAO")
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "USUARIO")
	oAttrib:lSet("CAB000", STR0011) //"Usuário"
	oAttrib:lSet("CLA000", KPI_STRING)
	oAttrib:lSet("EDT000",	"F")	
	oAttrib:lSet("CUM000",	"F")
	oAttrib:lSet("RETORNA", .f.)	

	//Data Real-De
	oAttrib:lSet("TAG001", "DT_USER_REALDE")
	oAttrib:lSet("CAB001", STR0004) //"Real-De"
	oAttrib:lSet("CLA001",  KPI_DATE)        
	oAttrib:lSet("CUM001",	"F")	
	oAttrib:lSet("EDT001",	"T")	
	
	//Data Real-Até
	oAttrib:lSet("TAG002", "DT_USER_REALATE")
	oAttrib:lSet("CAB002", STR0005) //"Real-Até"
	oAttrib:lSet("CLA002",  KPI_DATE)
	oAttrib:lSet("CUM002",	"F")	
	oAttrib:lSet("EDT002",	"T")	
	
	//Data Meta-De
	oAttrib:lSet("TAG003", "DT_USER_METADE")
	oAttrib:lSet("CAB003", STR0006) //"Meta-De"
	oAttrib:lSet("CLA003",  KPI_DATE)
	oAttrib:lSet("CUM003",	"F")	
	oAttrib:lSet("EDT003",	"T")	
	
	//Data Meta-Até
	oAttrib:lSet("TAG004", "DT_USER_METAATE")
	oAttrib:lSet("CAB004", STR0007) //"Meta-Até"
	oAttrib:lSet("CLA004",  KPI_DATE)
	oAttrib:lSet("CUM004",	"F")	
	oAttrib:lSet("EDT004",	"T")	
	
	//Data Prévia-De
	oAttrib:lSet("TAG005", "DT_USER_PREVIADE")
	oAttrib:lSet("CAB005", STR0008) //"Prévia-De"
	oAttrib:lSet("CLA005",  KPI_DATE)
	oAttrib:lSet("CUM005",	"F")	
	oAttrib:lSet("EDT005",	"T")	
	
	//Data Prévia-Até
	oAttrib:lSet("TAG006", "DT_USER_PREVIAATE")
	oAttrib:lSet("CAB006", STR0009) //"Prévia-Até"
	oAttrib:lSet("CLA006",  KPI_DATE)
	oAttrib:lSet("CUM006",	"F")	
	oAttrib:lSet("EDT006",	"T")	
	

	// Gera no principal
	oXMLNode := TBIXMLNode():New("PERMISSOES_ALTERACAO",,oAttrib)

	oUser:SetOrder(3)//COMPNOME
	oUser:_First()
	
	do while ! oUser:lEof()
		cUserID := oUser:cValue("ID")

		if !( alltrim(cUserID) == "0" )
			oNode := oXMLNode:oAddChild(TBIXMLNode():New("PERMISSAO_ALTERACAO"))

			oNode:oAddChild(TBIXMLNode():New("USUARIOID",cUserID))		
			oNode:oAddChild(TBIXMLNode():New("USUARIO"	,oUser:cValue("COMPNOME")))
            
			//Real-De
			if oUserCofig:lSeek(2,{cUserID,oUserCofig:aDeskProp[4,1],""})
				dValorProp	:= oUserCofig:dValue("VALATRIB")
			else
				dValorProp	:= cToD(oUserCofig:aDeskProp[4,2])
			endif
			oNode:oAddChild(TBIXMLNode():New("DT_USER_REALDE",dValorProp))
			
			//Real-Ate
			if oUserCofig:lSeek(2,{cUserID,oUserCofig:aDeskProp[5,1],""})
				dValorProp	:= oUserCofig:dValue("VALATRIB")
			else
				dValorProp	:= cToD(oUserCofig:aDeskProp[5,2])
			endif
			oNode:oAddChild(TBIXMLNode():New("DT_USER_REALATE",dValorProp))			
			 
			//Meta-De
			if oUserCofig:lSeek(2,{cUserID,oUserCofig:aDeskProp[6,1],""})
				dValorProp	:= oUserCofig:dValue("VALATRIB")
			else
				dValorProp	:= cToD(oUserCofig:aDeskProp[6,2])
			endif
			oNode:oAddChild(TBIXMLNode():New("DT_USER_METADE",dValorProp))
			
			//Meta-Ate
			if oUserCofig:lSeek(2,{cUserID,oUserCofig:aDeskProp[7,1],""})
				dValorProp	:= oUserCofig:dValue("VALATRIB")
			else
				dValorProp	:= cToD(oUserCofig:aDeskProp[7,2])
			endif
			oNode:oAddChild(TBIXMLNode():New("DT_USER_METAATE",dValorProp))
			
			//Previa-De
			if oUserCofig:lSeek(2,{cUserID,oUserCofig:aDeskProp[8,1],""})
				dValorProp	:= oUserCofig:dValue("VALATRIB")
			else
				dValorProp	:= cToD(oUserCofig:aDeskProp[8,2])
			endif
			oNode:oAddChild(TBIXMLNode():New("DT_USER_PREVIADE",dValorProp))
			
			//Previa-Ate
			if oUserCofig:lSeek(2,{cUserID,oUserCofig:aDeskProp[9,1],""})
				dValorProp	:= oUserCofig:dValue("VALATRIB")
			else
				dValorProp	:= cToD(oUserCofig:aDeskProp[9,2])
			endif
			oNode:oAddChild(TBIXMLNode():New("DT_USER_PREVIAATE",dValorProp))
		endif			

		oUser:_Next()
	end

return oXMLNode



/*
*Xml com os departamentos e datas que estao autorizado a fazer alteracao na planilha de valor
*/
method oPermDptoAlt() class TKPICfgPlanVlr
	local oUserCofig	:= ::oOwner():oGetTable("USU_CONFIG")
	local oDpto			:= ::oOwner():oGetTable("SCORECARD")
	local cDptoID		:= ""
	local dValorProp	:= cTod("//")	
	local oAttrib 		:= TBIXMLAttrib():New()
	local oNode, oXMLNode
	
	// Tipo
	oAttrib:lSet("TIPO", "PERMISSOES_ALTERACAO")
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "SCORECARD")
	oAttrib:lSet("CAB000", STR0010) //"Scorecarding"
	oAttrib:lSet("CLA000", KPI_STRING)
	oAttrib:lSet("EDT000",	"F")	
	oAttrib:lSet("CUM000",	"F")
	oAttrib:lSet("RETORNA", .f.)	

	//Data Real-De
	oAttrib:lSet("TAG001", "DT_DPTO_REALDE")
	oAttrib:lSet("CAB001", STR0004) //"Real-De"
	oAttrib:lSet("CLA001",  KPI_DATE)        
	oAttrib:lSet("CUM001",	"F")	
	oAttrib:lSet("EDT001",	"T")	
	
	//Data Real-Até
	oAttrib:lSet("TAG002", "DT_DPTO_REALATE")
	oAttrib:lSet("CAB002", STR0005) //"Real-Até"
	oAttrib:lSet("CLA002",  KPI_DATE)
	oAttrib:lSet("CUM002",	"F")	
	oAttrib:lSet("EDT002",	"T")	
	
	//Data Meta-De
	oAttrib:lSet("TAG003", "DT_DPTO_METADE")
	oAttrib:lSet("CAB003", STR0006) //"Meta-De"
	oAttrib:lSet("CLA003",  KPI_DATE)
	oAttrib:lSet("CUM003",	"F")	
	oAttrib:lSet("EDT003",	"T")	
	
	//Data Meta-Até
	oAttrib:lSet("TAG004", "DT_DPTO_METAATE")
	oAttrib:lSet("CAB004", STR0007) //"Meta-Até"
	oAttrib:lSet("CLA004",  KPI_DATE)
	oAttrib:lSet("CUM004",	"F")	
	oAttrib:lSet("EDT004",	"T")	
	
	//Data Prévia-De
	oAttrib:lSet("TAG005", "DT_DPTO_PREVIADE")
	oAttrib:lSet("CAB005", STR0008) //"Prévia-De"
	oAttrib:lSet("CLA005",  KPI_DATE)
	oAttrib:lSet("CUM005",	"F")	
	oAttrib:lSet("EDT005",	"T")	
	
	//Data Prévia-Até
	oAttrib:lSet("TAG006", "DT_DPTO_PREVIAATE")
	oAttrib:lSet("CAB006", STR0009) //"Prévia-Até"
	oAttrib:lSet("CLA006",  KPI_DATE)
	oAttrib:lSet("CUM006",	"F")	
	oAttrib:lSet("EDT006",	"T")	
	

	// Gera no principal
	oXMLNode := TBIXMLNode():New("PERMISSOES_ALTERACAO_DPTO",,oAttrib)

	oDpto:SetOrder(4) //NOME
	oDpto:_First()
	
	do while ! oDpto:lEof()
		cDptoID := oDpto:cValue("ID")

		if !( alltrim(cDptoID) == "") .and.  !(alltrim(cDptoID) == "0")
			oNode := oXMLNode:oAddChild(TBIXMLNode():New("PERMISSAO_ALTERACAO_DPTO"))

			oNode:oAddChild(TBIXMLNode():New("SCORECARDID",cDptoID))		
			oNode:oAddChild(TBIXMLNode():New("SCORECARD"	,oDpto:cValue("NOME")))
            
			//Real-De
			if oUserCofig:lSeek(2,{cDptoID,oUserCofig:aDeskProp[10,1],"D"})
				dValorProp	:= oUserCofig:dValue("VALATRIB")
			else
				dValorProp	:= cToD(oUserCofig:aDeskProp[10,2])
			endif
			oNode:oAddChild(TBIXMLNode():New("DT_DPTO_REALDE",dValorProp))
			
			//Real-Ate
			if oUserCofig:lSeek(2,{cDptoID,oUserCofig:aDeskProp[11,1],"D"})
				dValorProp	:= oUserCofig:dValue("VALATRIB")
			else
				dValorProp	:= cToD(oUserCofig:aDeskProp[11,2])
			endif
			oNode:oAddChild(TBIXMLNode():New("DT_DPTO_REALATE",dValorProp))			
			 
			//Meta-De
			if oUserCofig:lSeek(2,{cDptoID,oUserCofig:aDeskProp[12,1],"D"})
				dValorProp	:= oUserCofig:dValue("VALATRIB")
			else
				dValorProp	:= cToD(oUserCofig:aDeskProp[12,2])
			endif
			oNode:oAddChild(TBIXMLNode():New("DT_DPTO_METADE",dValorProp))
			
			//Meta-Ate
			if oUserCofig:lSeek(2,{cDptoID,oUserCofig:aDeskProp[13,1],"D"})
				dValorProp	:= oUserCofig:dValue("VALATRIB")
			else
				dValorProp	:= cToD(oUserCofig:aDeskProp[13,2])
			endif
			oNode:oAddChild(TBIXMLNode():New("DT_DPTO_METAATE",dValorProp))
			
			//Previa-De
			if oUserCofig:lSeek(2,{cDptoID,oUserCofig:aDeskProp[14,1],"D"})
				dValorProp	:= oUserCofig:dValue("VALATRIB")
			else
				dValorProp	:= cToD(oUserCofig:aDeskProp[14,2])
			endif
			oNode:oAddChild(TBIXMLNode():New("DT_DPTO_PREVIADE",dValorProp))
			
			//Previa-Ate
			if oUserCofig:lSeek(2,{cDptoID,oUserCofig:aDeskProp[15,1],"D"})
				dValorProp	:= oUserCofig:dValue("VALATRIB")
			else
				dValorProp	:= cToD(oUserCofig:aDeskProp[15,2])
			endif
			oNode:oAddChild(TBIXMLNode():New("DT_DPTO_PREVIAATE",dValorProp))
		endif			

		oDpto:_Next()
	end

return oXMLNode

function _KPICFGPLANVLR()
return nil