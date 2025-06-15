// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI030_Agendador.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 13.10.05 | 2487 Eduardo Konigami Miyoshi
// 27.11.07 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI030_Agendador.ch"

/*--------------------------------------------------------------------------------------
@entity Agendador de Importação
Agendamento de importação de arquivos que contêm indicadores folha(indicadores que não possuem fórmula)
@table KPI030
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "AGENDAMENTO"
#define TAG_GROUP  "AGENDAMENTOS
#define TEXT_ENTITY STR0001/*//"Agendador"*/
#define TEXT_GROUP  STR0002/*//"Agendadores"*/

class TKPI030 from TBITable
	data idImportacao
	
	method New() constructor
	method NewKPI030()

	// diversos registros
	method oToXMLRecList()
	method oToXMLNode(cID,cLoadCMD)
	method oToXMLList()
	method lAddScorecard(oXMLNode) 
	
	// registro atual
	method cCriaImportacao(cDiretorio,cKpiPath)//Cria o comando de importacao
	method cGetDiretorio(cAcao)   
	method nGetDiaLimite(cAcao)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method nExecute(nID, cLoadCMD)

endclass
	
method New() class TKPI030
	::NewKpi030()
return

method NewKpi030() class TKPI030
	// Table
	::NewTable("SGI030")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C"	,010))
	::addField(TBIField():New("IDACAO"		,"C"	,010)) 	//ID DA ACAO //Ver combo de acoes
	::addField(TBIField():New("NOME"		,"C"	,060)) 	//nome do agendamento
	::addField(TBIField():New("DATAINI"		,"D"	,8))   	//data inicial válida
	::addField(TBIField():New("HORAINI"		,"C"	,5))   	//hora inicial válida
	::addField(TBIField():New("DATAFIM"		,"D"	,8))   	//data final válida
	::addField(TBIField():New("HORAFIM"		,"C"	,5))   	//hora final válida
	::addField(TBIField():New("FREQ"		,"N"	  ))	//frequencia: 1-Diário 2-Semanal 3-Mensal
	::addField(TBIField():New("DIAFIRE"		,"N"	  ))	//dia do mês ou semana que será executado
	::addField(TBIField():New("HORAFIRE"	,"C"	,5))   	//horário que será executado
	::addField(TBIField():New("ATIVO"		,"C"	,1))
	::addField(TBIField():New("DATAEXE"		,"D"	,8))	//data da última execução
	::addField(TBIField():New("HORAEXE"		,"C"	,5))    //horário da última execução
	::addField(TBIField():New("DATANEXT"	,"D"	,8))	//data da próxima execução
	::addField(TBIField():New("HORANEXT"	,"C"	,5))	//horário da próxima execução
	::addField(TBIField():New("ACAO"		,"C"	,120))	//acao a ser executada neste agendamento
	::addField(TBIField():New("ENV"			,"C"	,50))	//Enviroment da execucao
	::addField(TBIField():New("DTCALCDE"	,"D"	,8))   	//data de 
	::addField(TBIField():New("DTCALCATE"	,"D"	,8))   	//data ate
	::addField(TBIField():New("DINAMICO"	,"L"))   		/*Identifica se o cálculo usa período dinâmico ou fixo.*/ 
	::addField(TBIField():New("DATAMENOS"	,"N"))			/*Usado para definir a data de dinamicamente.*/
	::addField(TBIField():New("DATAMAIS"	,"N"))			/*Usado para definir a data até dinamicamente.*/
	//Indexs	
	::addIndex(TBIIndex():New("SGI030I01",	{"ID"},		.t.))	
return

method lAddScorecard(oXMLNode) class TKPI030
	oXMLNode:oAddChild(	::oOwner():oGetTable("SCORECARD"):oToXMLList(.F., .T., STR0015) ) //"Calcular todos"
return  .T.

// Lista XML para anexar ao pai
method oToXMLList() class TKPI030
	local oNode, oAttrib, oXMLNode, nInd
	local dExec, hExec 
	
	//Colunas
	oAttrib := TBIXMLAttrib():New()
	//Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	//Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0006) //Tarefa
	oAttrib:lSet("CLA000", KPI_STRING)
	//Data Início
	oAttrib:lSet("TAG001", "DATAINI")
	oAttrib:lSet("CAB001", STR0003)
	oAttrib:lSet("CLA001", KPI_DATE)
	//Data Fim
	oAttrib:lSet("TAG002", "DATAFIM")
	oAttrib:lSet("CAB002", STR0004)
	oAttrib:lSet("CLA002", KPI_DATE) 
	//Execução
	oAttrib:lSet("TAG003", "EXEC")
	oAttrib:lSet("CAB003", STR0012) //"Próx. Execução"
	oAttrib:lSet("CLA003", KPI_STRING)

	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	::SetOrder(1)
	::_First()    
	
	While(!::lEof())
		If( !(alltrim(::cValue("ID")) == "0"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"HORAINI", "HORAFIM", "DIRETORIO", "ATIVO", "DATAEXE", "HORAEXE","DIRETORIO",})

			For nInd := 1 to Len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
				If ( aFields[nInd][1] == "DATANEXT" )
					dExec := aFields[nInd][2]
				ElseIf aFields[nInd][1] == "HORANEXT" 
					hExec := aFields[nInd][2]
				EndIf
			Next
			
			If ( alltrim(hExec) == "" )
				oNode:oAddChild(TBIXMLNode():New("EXEC", STR0013)) //"Encerrado!"
			else
				oNode:oAddChild(TBIXMLNode():New("EXEC", dtoc(dExec) + " - " + hExec))
			endif
		endif			
		::_Next()		
	end

return oXMLNode

// Lista XML para anexar ao pai
method oToXMLRecList() class TKPI030
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
	//Data Início
	oAttrib:lSet("TAG001", "DATAINI")
	oAttrib:lSet("CAB001", STR0003)
	oAttrib:lSet("CLA001", KPI_DATE)
	//Data Fim
	oAttrib:lSet("TAG002", "DATAFIM")
	oAttrib:lSet("CAB002", STR0004)
	oAttrib:lSet("CLA002", KPI_DATE)
   
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)

	::SetOrder(1)
	::_First() 
	
	While(!::lEof())
		If( !(alltrim(::cValue("ID")) == "0"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"HORAINI", "HORAFIM", "DIRETORIO", "ATIVO", "DATAEXE", "HORAEXE","DIRETORIO"})
			
			For nInd := 1 To Len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			Next
		Endif			
		::_Next()		
	End

	oXMLNodeLista:oAddChild(oXMLNode)

return oXMLNodeLista

// Carregar
method oToXMLNode(cID,cLoadCMD) class TKPI030
	local aFields	,nInd
	local oXMLNode 	:= TBIXMLNode():New(TAG_ENTITY)      
	local oParametro	:= ::oOwner():oGetTable("PARAMETRO") 
	local cIDAcao	:= "0"
	local cDiretorio:= ""  
	local nDiaLimite:= 1
	local cAcao		:= ""

	//Verifica a existencia do servico de importacao Se o ID for zero.
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))

		//Captura o ID da Acao
		if(aFields[nInd][1] == "IDACAO"	)
			cIDAcao		:= aFields[nInd][2]
		endif

		//Captura a posicao do item da acao
		if(aFields[nInd][1] == "ACAO")		
			cAcao	:= aFields[nInd][2]
		endif				
	next

	if(alltrim(cIDAcao) == "2")
		cDiretorio	:= ::cGetDiretorio(cAcao) 
	elseif(alltrim(cIDAcao) == "6")	
		nDiaLimite	:= ::nGetDiaLimite(cAcao) 
	endif		
	
	oXMLNode:oAddChild(TBIXMLNode():New("DIRETORIO", cDiretorio))
	oXMLNode:oAddChild(TBIXMLNode():New("DIA_LIMITE", nDiaLimite))    
	oXMLNode:oAddChild(TBIXMLNode():New("BLOQ_POR_DIA_LIMITE",	oParametro:getValue("BLOQ_POR_DIA_LIMITE")))

	// Gera no principal
	oNode := oXMLNode:oAddChild(TBIXMLNode():New("COMANDOS"))
	
	oComando := oNode:oAddChild(TBIXMLNode():New("COMANDO"))
	oComando:oAddChild(TBIXMLNode():New("ID"	, "1"))
	oComando:oAddChild(TBIXMLNode():New("NOME"	, STR0007))//"Função ADVPL"
	oComando:oAddChild(TBIXMLNode():New("ACAO"	, ""))

	oComando := oNode:oAddChild(TBIXMLNode():New("COMANDO"))
	oComando:oAddChild(TBIXMLNode():New("ID"	, "2"))
	oComando:oAddChild(TBIXMLNode():New("NOME"	, STR0008))//"Importação de dados"
	oComando:oAddChild(TBIXMLNode():New("ACAO"	, "kpiImportData"))
	
	oComando := oNode:oAddChild(TBIXMLNode():New("COMANDO"))
	oComando:oAddChild(TBIXMLNode():New("ID"	, "3"))
	oComando:oAddChild(TBIXMLNode():New("NOME"	, STR0009))//"Notificação de Planos Atrasados"
	oComando:oAddChild(TBIXMLNode():New("ACAO"	, ""))
	
	oComando := oNode:oAddChild(TBIXMLNode():New("COMANDO"))
	oComando:oAddChild(TBIXMLNode():New("ID"	, "4"))
	oComando:oAddChild(TBIXMLNode():New("NOME"	, STR0010))//"Importação de fonte de dados".
	oComando:oAddChild(TBIXMLNode():New("ACAO"	, "KpiDataSrcJob"))

	oComando := oNode:oAddChild(TBIXMLNode():New("COMANDO"))
	oComando:oAddChild(TBIXMLNode():New("ID"	, "5"))
	oComando:oAddChild(TBIXMLNode():New("NOME"	, STR0011))//"Calculo dos indicadores".
	oComando:oAddChild(TBIXMLNode():New("ACAO"	, "KpiCalc_Indicador"))
	
	oComando := oNode:oAddChild(TBIXMLNode():New("COMANDO"))
	oComando:oAddChild(TBIXMLNode():New("ID"	, "6"))
	oComando:oAddChild(TBIXMLNode():New("NOME"	, STR0014))//"Alerta para preenchimento da planilha de valores"
	oComando:oAddChild(TBIXMLNode():New("ACAO"	, ""))

	// Acrescenta children - Fonte de dados
	oXMLNode:oAddChild(::oOwner():oGetTable("DATASRC"):oToXMLList())

	oXMLNode:oAddChild(oNode)
	::lAddScorecard(oXMLNode) 

return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath)  class TKPI030
	local aFields, nInd, nStatus := KPI_ST_OK
	local cIDAcao		:=	""
	local cDiretorio	:=	""       
	local nDiaLimite	:=  0
	local cKpiPath		:=  ::oOwner():cKpiPath()
	local nPosAcao		:=	0  
	local cJobName 		:=	""
	local cPathSite		:=	""	
	local nEndCut		:=	0
	local dNextFire		:=  nil
	
	private oXMLInput	:=  oXML

	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
        
		do case 
			case aFields[nInd][1] == "IDACAO" 
				//Captura o ID da Acao
				cIDAcao	:= alltrim(aFields[nInd][2])
			case aFields[nInd][1] == "ACAO"
				//Captura a posicao do item da acao
				nPosAcao := nInd
			case aFields[nInd][1] == "DATANEXT"
				//Captura a posicao data da próxima execução
				nPosDtNext := nInd
			case aFields[nInd][1] == "HORANEXT"
				//Captura a posicao hora da próxima execução
				nPosHrNext := nInd
			case aFields[nInd][1] == "ENV" 
				//Verifica o environment
				if(empty(aFields[nInd][2]))
					aFields[nInd][2] :=  getEnvServer()
				endif
		end case
	next

	//Se for Importacao de dados
	if(alltrim(cIDAcao) == "2")
		cDiretorio				:=	oXMLInput:_REGISTROS:_AGENDAMENTO:_DIRETORIO:TEXT
		aFields[nPosAcao][2]	:= ::cCriaImportacao(cDiretorio,cKpiPath)
	endif
	
	//Se for Notificação de Planos Atrasados
	if(alltrim(cIDAcao) == "3")
		aFields[nPosAcao][2]	:= "KpiNotiPlanAtra('\"+cKpiPath+"\')"
	endif
         
	//Se for importacao da fonte de dados.
	if(alltrim(cIDAcao) == "4")
		aFields[nPosAcao][2]	:=  strTran(aFields[nPosAcao][2], ")",	",'\" + cKpiPath + "\')")
	endif
	
	//Calculo dos indicadores
	if(alltrim(cIDAcao) == "5")		
		nEndCut		:=	at("(",aFields[nPosAcao][2]) + 1
		cJobName 	:=	alltrim(getJobProfString("INSTANCENAME", "SGI")+"_CalcInd.lck")	
		cPathSite	:=	left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))  

		//Traramento do campo request.
		cRequest	:= substr(aFields[nPosAcao][2], nEndCut ,  len(aFields[nPosAcao][2])- nEndCut  )		

		aFields[nPosAcao][2]	:= "KpiCalc_Indicador('" + cJobName + "'"
		aFields[nPosAcao][2]	+=	",'\" + cKpiPath + "\'"
		aFields[nPosAcao][2]	+=	",'0'"
		aFields[nPosAcao][2]	+=	",'" + cRequest + "'"
		aFields[nPosAcao][2]	+=	",'')"
	endif                 
	
	//Se for alerta de cadastro da planilha de valores
	if(alltrim(cIDAcao) == "6")  
		nDiaLimite				:= oXMLInput:_REGISTROS:_AGENDAMENTO:_DIA_LIMITE:TEXT
		aFields[nPosAcao][2]	:= "KpiNotiCadVlr('\"+cKpiPath+"\'," + nDiaLimite + ")"
	endif
    
    //Calcula a proxima execução
	dNextFire := buildNextFire(		val(oXMLInput:_REGISTROS:_AGENDAMENTO:_FREQ:TEXT),; 
									allTrim(oXMLInput:_REGISTROS:_AGENDAMENTO:_HORAFIRE:TEXT),;  
									cTod(oXMLInput:_REGISTROS:_AGENDAMENTO:_DATAINI:TEXT),;  
									val(oXMLInput:_REGISTROS:_AGENDAMENTO:_DIAFIRE:TEXT),;
									allTrim(oXMLInput:_REGISTROS:_AGENDAMENTO:_HORAFIM:TEXT),;  
									cTod(oXMLInput:_REGISTROS:_AGENDAMENTO:_DATAFIM:TEXT) )

	if dNextFire == nil
		aFields[nPosHrNext][2] := space(5)
		aFields[nPosDtNext][2] := space(8)
	else
		aFields[nPosHrNext][2] := oXMLInput:_REGISTROS:_AGENDAMENTO:_HORAFIRE:TEXT 
		aFields[nPosDtNext][2] := dNextFire
	endif
												

	aAdd(aFields, {"ID", ::cMakeID()} )

	// Grava
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	endif	
	
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPI030
	local nStatus 		:= KPI_ST_OK
	local cIDAcao		:= ""
	local cDiretorio	:= ""        
	local cID 			:= "" 
	local nInd 			:= 1
	local nDiaLimite	:= 0
	local nPosAcao		:= 0
	local nPosDtNext	:= 0
	local nPosHrNext	:= 0
	local nIniCut		:= 0
	local nEndCut		:= 0	
	local oKpiCore 		:= ::oOwner()
	local cKpiPath		:= oKpiCore:cKpiPath()	 
	local dNextFire		:= nil
	
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY)

	//Extrai valores do XML
	for nInd := 1 to len(aFields)   
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		
		do case 
			case aFields[nInd][1] == "ID"
				//Captura o ID
				cID := aFields[nInd][2]  
			case aFields[nInd][1] == "IDACAO" 
				//Captura o ID da Acao
				cIDAcao	:= alltrim(aFields[nInd][2])
			case aFields[nInd][1] == "ACAO"
				//Captura a posicao do item da acao
				nPosAcao := nInd
			case aFields[nInd][1] == "DATANEXT"
				//Captura a posicao data da próxima execução
				nPosDtNext := nInd
			case aFields[nInd][1] == "HORANEXT"
				//Captura a posicao hora da próxima execução
				nPosHrNext := nInd
			case aFields[nInd][1] == "ENV"    
				If ( cIDAcao == "1" ) //Função ADVPL 
					If( Empty( aFields[nInd][2] ) )
						aFields[nInd][2] :=  getEnvServer()
					EndIf 			
				Else 			
					aFields[nInd][2] :=  getEnvServer()
				EndIf
		end case
	next

	// Verifica condições de gravação (append ou update)
	if(!::lSeek(1, {cID}))
		nStatus := KPI_ST_BADID
	else  
	    do case 
	    	case cIDAcao == "2" //Se for Importacao de dados
	    		cDiretorio := oXMLInput:_REGISTROS:_AGENDAMENTO:_DIRETORIO:TEXT
				aFields[nPosAcao][2] := ::cCriaImportacao(cDiretorio,cKpiPath)
				
			case cIDAcao == "3" //Se for Notificação de Planos Atrasados
				aFields[nPosAcao][2] := "KpiNotiPlanAtra('\"+cKpiPath+"\')"
				
			case cIDAcao == "4" //Se for importacao da fonte de dados 
				nEndCut	:=	at(",",aFields[nPosAcao][2])
				if(nEndCut == 0)
					aFields[nPosAcao][2] :=  strTran(aFields[nPosAcao][2], ")",	",'\" + cKpiPath + "\')")
				else
					aFields[nPosAcao][2] :=	substr(aFields[nPosAcao][2],1,nEndCut) + "'\" + cKpiPath + "\')"
				endif
				
			case cIDAcao == "5" //Calculo dos indicadores
				nEndCut		:=	at("(",aFields[nPosAcao][2]) + 1
				cJobName 	:=	alltrim(getJobProfString("INSTANCENAME", "SGI")+"_CalcInd.lck")	
				cPathSite	:=	left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))  
		
				//Traramento do campo request.
				cRequest	:= substr(aFields[nPosAcao][2], nEndCut ,  len(aFields[nPosAcao][2])- nEndCut  )		
		
				aFields[nPosAcao][2]	:= "KpiCalc_Indicador('" + cJobName + "'"
				aFields[nPosAcao][2]	+=	",'\" + cKpiPath + "\'"
				aFields[nPosAcao][2]	+=	",'0'"
				aFields[nPosAcao][2]	+=	",'" + cRequest + "'"
				aFields[nPosAcao][2]	+=	",'')"       
				
			case cIDAcao == "6" //Se for alerta de cadastro da planilha de valores 
				nDiaLimite			 := oXMLInput:_REGISTROS:_AGENDAMENTO:_DIA_LIMITE:TEXT
				aFields[nPosAcao][2] := "KpiNotiCadVlr('\"+cKpiPath+"\'," + nDiaLimite + ")"
	    end case                                                      
        

		//Calcula a proxima execução
		dNextFire := buildNextFire(	val(oXMLInput:_REGISTROS:_AGENDAMENTO:_FREQ:TEXT),; 
				allTrim(oXMLInput:_REGISTROS:_AGENDAMENTO:_HORAFIRE:TEXT),;  
				cTod(oXMLInput:_REGISTROS:_AGENDAMENTO:_DATAINI:TEXT),;  
				val(oXMLInput:_REGISTROS:_AGENDAMENTO:_DIAFIRE:TEXT),;
				allTrim(oXMLInput:_REGISTROS:_AGENDAMENTO:_HORAFIM:TEXT),;  
				cTod(oXMLInput:_REGISTROS:_AGENDAMENTO:_DATAFIM:TEXT) )

		if dNextFire == nil
			aFields[nPosHrNext][2] := space(5)
			aFields[nPosDtNext][2] := space(8)
		else
			aFields[nPosHrNext][2] := oXMLInput:_REGISTROS:_AGENDAMENTO:_HORAFIRE:TEXT 
			aFields[nPosDtNext][2] := dNextFire
		endif
												

		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	
	endif
return nStatus

//Excluir entidade do server
method nDelFromXML(nID) class TKPI030
	local nStatus := KPI_ST_OK

	// Deleta o elemento
	if(nStatus != KPI_ST_HASCHILD)
		if(::lSeek(1, {nID}))
			if(!::lDelete())
				nStatus := KPI_ST_INUSE
			endif
		else
			nStatus := KPI_ST_BADID
		endif	
    endif

return nStatus

method nExecute(nID, cLoadCMD) class TKPI030
	local nStatus := KPI_ST_OK

    //Redireciona a chamada para o Scheduler pois não tem uma entidade real
	if(valtype(::oOwner():foScheduler) != "U")
		nStatus := ::oOwner():foScheduler:nExecute(nID, cLoadCMD)
	else
		::fcMsg := STR0005//"Não foi possível reiniciar o agendamento de importação!"
		nStatus := KPI_ST_VALIDATION
	endif		
	
return nStatus

/*
*Cria a acao de importacao
*/	
method cCriaImportacao(cDiretorio,cKpiPath) class TKPI030
	local cAcao	:=	""
	
	cKpiPath	:=	iif(empty(cKpiPath), ::oOwner():cKpiPath(),cKpiPath)
	cDiretorio	:=	iif(empty(cDiretorio),"sgiimport",cDiretorio)
	cAcao	:=	"kpiImportData("
	cAcao	+=	"'\"+cKpiPath+"\',"
	cAcao	+=	"'" +cDiretorio+"'"
	cAcao	+=	")"
	
return cAcao
                    
method cGetDiretorio(cAcao) class TKPI030
	local 	aAcao	:= 	aBIToken(cAcao,",", .f.)
	local 	cDir	:=	strTran(aAcao[2],"'","")
	 		cDir	:=	strTran(cDir,")","")

return cDir

method nGetDiaLimite(cAcao) class TKPI030
	local 	aAcao	:= 	aBIToken(cAcao,",", .f.)
	local 	nDia	:=	strTran(aAcao[2],"'","")
	 		nDia	:=	alltrim(strTran(nDia,")",""))

return nDia

function _KPI030_Agendador()
return nil
