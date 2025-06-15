// ######################################################################################
// Projeto: KPI
// Modulo : 
// Fonte  : KPIProgressbar.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 02.05.06 | 1776 - Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "kpiProgressBar.ch"

/*--------------------------------------------------------------------------------------
@class KPIProgressbar
@entity KPIProgressbar
Barra de progresso, para mostrar o status de um tarefa em execucao.
--------------------------------------------------------------------------------------*/
class KPIProgressbar from TBIObject
	data	oThreadFile 	//Arquivo de gravacao.
	data 	oXMLThread 		//Use para adicionar um nova propriedades.
	data	oXMLRespostas 	//Dados a serem gravados.
	data	oNodeStatus		//Status atual do processamento.
	data	oNodePercent	//Porcentagem do processamento.
	data 	oNodeMessage	//No de mensagens.
    
	method New(cThreadName) constructor
	method NewKPIProgressbar()
	method setStatus(nStatus)
	method setPercent(nPercent)
	method setMessage(cMessage)
	method endProgress()

endclass

method New(cThreadName) class KPIProgressbar
	::NewKPIProgressbar(cThreadName)
return

method NewKPIProgressbar(cArquivo) class KPIProgressbar  
	local oResposta
	local oRetornos
	local oAttrib	
	
	cArquivo += ".xml"
	::oThreadFile := TBIFileIO():New(oKPICore:cKpiPath()+"thread\"+cArquivo)

	//Se existir o arquivo de thread, exclui
	if ::oThreadFile:lExists()
		if(!::oThreadFile:lErase())
			oKPICore:Log(STR0002 + "["+cArquivo+"]", KPI_LOG_SCRFILE) //"Arquivo de controle de thread ja esta em uso
			oKPICore:Log(STR0003, KPI_LOG_SCRFILE) //"Operação abortada"
			return
		endif               
	endif

	// Cria o arquivo de Thread Collector
	if ! ::oThreadFile:lCreate(FO_READWRITE,.t.)
		oKPICore:Log(STR0004 + "["+cArquivo+"]", KPI_LOG_SCRFILE) //"Erro na criação do arquivo de Thread Collector 
		oKPICore:Log(STR0003, KPI_LOG_SCRFILE) //"Operação abortada"
		return
	endif	

	// Cria a estrutura do arquivo de Thread Collector
	::oXMLRespostas:= TBIXMLNode():New("REPOSTAS")
	
	oResposta		:= 	::oXMLRespostas:oAddChild(TBIXMLNode():New("RESPOSTA"))
	oResposta:oAddChild(TBIXMLNode():New("STATUS",0,))
	oRetornos		:=	oResposta:oAddChild(TBIXMLNode():New("RETORNOS"))
	::oXMLThread	:=	oRetornos:oAddChild(TBIXMLNode():New("THREAD"))

	oAttrib 	:= TBIXMLAttrib():New()
	oAttrib:lSet("DATA", Date())
	oAttrib:lSet("HORA", Time())
	
	::oNodeStatus	:=	TBIXMLNode():New("STATUS",PROGRESS_BAR_OK)
	::oNodePercent	:=	TBIXMLNode():New("PERCENT",0)
	::oNodeMessage	:=	TBIXMLNode():New("MESSAGE",STR0001) //"Iniciando o processamento"

	::oXMLThread:oAddChild(TBIXMLNode():New("BEGIN",,oAttrib))
	::oXMLThread:oAddChild(::oNodeStatus)
	::oXMLThread:oAddChild(::oNodePercent)
	::oXMLThread:oAddChild(::oNodeMessage)

	// Grava estrutura XML no arquivo de Thread Collector
	::oThreadFile:nWrite(::oXMLRespostas:cXMLString(.t., "ISO-8859-1"))     
	::oThreadFile:lClose()	
	
return .t.

method setStatus(nStatus) class KPIProgressbar  
	local lOpen := .t.
	
	if ! ::oThreadFile:lIsOpen()	
		if ! ::oThreadFile:lCreate(FO_READWRITE,.t.)
			::oThreadFile:Free()
			lOpen	:=	 .f.
		endif
	endif			
	
	if lOpen
		::oThreadFile:nGoBOF()
		::oNodeStatus:SetValue(nStatus)	
		::oThreadFile:nWrite(::oXMLRespostas:cXMLString(.t., "ISO-8859-1"))	
	endif

	::oThreadFile:lClose()				
	
return .t.

method setPercent(nPercent) class KPIProgressbar  
	local lOpen := .t.

	if ! ::oThreadFile:lIsOpen()	
		if ! ::oThreadFile:lCreate(FO_READWRITE,.t.)
			::oThreadFile:Free()
			lOpen	:=	 .f.
		endif
	endif			

	if lOpen
		::oThreadFile:nGoBOF()
		::oNodePercent:SetValue(nPercent)
		::oThreadFile:nWrite(::oXMLRespostas:cXMLString(.t., "ISO-8859-1"))		
	endif

	::oThreadFile:lClose()	
	
return .t.


method setMessage(cMessage) class KPIProgressbar  
	local lOpen := .t.

	if ! ::oThreadFile:lIsOpen()	
		if ! ::oThreadFile:lCreate(FO_READWRITE,.t.)
			::oThreadFile:Free()
			lOpen	:=	 .f.
		endif
	endif			

	if lOpen
		::oThreadFile:nGoBOF()
		::oNodeMessage:SetValue(cMessage)
		::oThreadFile:nWrite(::oXMLRespostas:cXMLString(.t., "ISO-8859-1"))		
	endif

	::oThreadFile:lClose()	
	
return .t.


method endProgress() class KPIProgressbar  
	// Cria estrutura de finalização de processos no arquivo de Thread Collector		
	local oAttrib 	:= TBIXMLAttrib():New()
	
	oAttrib:lSet("DATA", Date())
	oAttrib:lSet("HORA", Time())
		
	::oXMLThread:oAddChild(TBIXMLNode():New("END",,oAttrib))

	// Grava estrutura XML no arquivo de Thread Collector
	::oThreadFile:nGoBOF()
	::oThreadFile:nWrite(::oXMLRespostas:cXMLString(.t., "ISO-8859-1"))
	                  
	// Fecha arquivo de Thread Collector
	::oThreadFile:lClose()

	::setStatus(PROGRESS_BAR_END)

return .t.

function _KPIProgressbar()
return nilw