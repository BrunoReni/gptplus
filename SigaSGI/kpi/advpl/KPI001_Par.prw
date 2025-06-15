// ######################################################################################
// Projeto: KPI
// Modulo : Core
// Fonte  : KPIDatabase - Rotinas para controle do base de dados do kpi
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-------------------------------------------------------- 
// 08.04.03 | 1728 Fernando Patelli
// 18.08.05 | 1776 Alexandre Alves da Silva	- Importado para o sistema kpi.
// 12.12.07 | 2516 Lucio Pelinson			- Adaptado para servir a todas configurações
// --------------------------------------------------------------------------------------       

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI001_Par.ch"           

/*-------------------------------------------------------------------------------------
@class TKPI001
@entity Parametro
Tabela com os flags de controle.
@table KPI001
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "PARAMETRO"
#define TAG_GROUP  "PARAMETROS"
#define TEXT_ENTITY "Parâmetro"
#define TEXT_GROUP  "Parâmetros"

class TKPI001 from TBITable
	data aSystemProp //Propriedades default
	
	method New() constructor
	method NewKPI001() 

	//Registro Unico
	method oToXMLNode()
	method lPutSystemConfig(oXMLNode)//E obrigatorio passar o oXMLNode por referencia
	method oItensSCD() // Itens ScoreCarding
	method getValue(cKey)
	method setValue(cKey, cValue)
	method getScoDefName() 
	method getDataName(cKey)
	
	//Gravacao
	method nUpdFromXML(oXML, cPath,cUserID)
	
endclass
	
method New() class TKPI001
	::NewKPI001()
return

method NewKPI001() class TKPI001    

	Local cModoAnal	:= getJobProfString("AnalysisMode", ANALISE_PDCA)
	Local cStrUser	:= getJobProfString("ScoreCardName", ::getScoDefName())

	// Table
	::NewTable("SGI001")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("CHAVE",	"C",	16))
	::addField(TBIField():New("TIPO",	"C",	1))
	::addField(TBIField():New("DADO",	"C",	255))
	::addField(TBIField():New("DADOM",	"M"))

	// Indexes
	::addIndex(TBIIndex():New("SGI001I01",	{"CHAVE"},	.t.))
     
	//Arrays
	::aSystemProp := {;	
						{"LOG_USER_ENABLE"		,"F"			, "C"},;//Tipo da visualizacao para a configuracao.
						{"KPIDBVERSION"			,"1.10.070410"	, "C"},;//Versão
						{"NUM_DIA_PRO_FIN"		,"90"			, "C"},;//Numero de dias para mostrar os projetos finalizados.
						{"PRAZO_PARA_VENC"		,"7"			, "C"},;//Número de dias a vencer para Planos de Ações
						{"VALOR_PREVIO"			,"F"			, "C"},;//Indica se vai usar o valor prévio do indicador
						{"DATA_ALT_PLANILHA"	,"01/01/2000"	, "C"},;//Data a partir da qual e permito fazer alteracao na planilha de valores.
						{"ALT_DATAFIM_PLANO"	,"F"			, "C"},;//Indica se pode alterar a data final do plano de ação de indicadores/projetos
						{"BLQ_ALT_VLR"  		,"F"			, "C"},;//Bloquear alteracoes de valor quando o indicador for formula T/F
						{"ORDEM_SCD"  			,"F"			, "C"},;//Ordem padrao do ScoreCarding
						{"DATA_ALT_REALDE"		,"01/01/2000"	, "C"},;//Data a partir da qual e permito fazer alteracao na planilha de valores.
						{"DATA_ALT_REALATE"		,"  /  /  "		, "C"},;//Data a partir da qual e permito fazer alteracao na planilha de valores.
						{"DATA_ALT_METADE"		,"01/01/2000"	, "C"},;//Data a partir da qual e permito fazer alteracao na planilha de valores.
						{"DATA_ALT_METAATE"		,"  /  /  "		, "C"},;//Data a partir da qual e permito fazer alteracao na planilha de valores.
						{"DATA_ALT_PREVIADE"	,"01/01/2000"	, "C"},;//Data a partir da qual e permito fazer alteracao na planilha de valores.
						{"DATA_ALT_PREVIAATE"	,"  /  /  "		, "C"},;//Data a partir da qual e permito fazer alteracao na planilha de valores.												
						{"CFGDTMESANTERIOR"		,"0"			, "C"},;//Utilizar como padrão para data alvo o mês anterior.(0=DtAtual) (-1=DtmesAnterior)
						{"INDVERM_APRESENT"		,"F"			, "C"},;//Incluir obrigatoriamente na apresentação, indicadores que não atingiram a meta.
						{"WFINSERTACTION"		,"F"			, "C"},;//Ao incluir plano de ações notificar o responsável por e-mail.
						{"RESTRINGI_IP"			,"F"			, "C"},;//Restringir por IP.
						{"RESTRINGI_HORARIO"	,"F"			, "C"},;//Restringir por horário.
						{"HORARIO_ACESSO"		,"00:00|23:59"	, "C"},;//Horario de restrição de acesso.
						{"WS_DW_INTEGRATION"	,""				, "C"},;//Endereco WSDL de integracao com o DataWareHouse
						{"SCRDING_INTERVAL_UPD"	,"0"			, "C"},;//Intervalor entre os refresh da tela do scorecarding 0 desabilitado.
						{"OWNER_ALT_PLANILHA"	,"F"			, "C"},;//Somente Responsáveis pelo departamento, indicador e coleta alteram planilha de valores.
						{"INFO_INC_META"		,"F"			, "C"},;//Habilitar auditoria da meta e notificaçao via e-mail - Inclusao
						{"INFO_ALT_META"		,"F"			, "C"},;//Habilitar auditoria da meta e notificaçao via e-mail - Alteracao
						{"INFO_EXC_META"		,"F"			, "C"},;//Habilitar auditoria da meta e notificaçao via e-mail - Exclusao
						{"DECIMALVAR"			,"2"			, "C"},;//Número de casas decimais a ser exibido na coluna variação(percentual).
						{"SHOWVARCOL"			,"F"			, "C"},;//Exibir variação em percentual na tela do scorecarding.
						{"CFGDTACUMULADO"		,"F"			, "C"},;//Utilizar como padrão para o período acumulado de Janeiro até a data alvo.
						{"SHOWCOLPERIODO"		,"T"			, "C"},; //Exibir coluna de período
						{"SHOWCOLMEDIDA"		,"T"			, "C"},; //Exibir coluna Unidade de Medida
						{"DW_URL"				,""				, "C"},; //URL de integracao com o DataWareHouse
						{"DW_USER"				,"SGIADMIN"		, "C"},; //Usuário utilizado na integracao com o DataWareHouse
						{"DW_PWD"				,"SGI"			, "C"},; //Senha do usuário utilizado na integracao com o DataWareHouse
						{"PERMISSAO_RECURSIVA"	,"F"			, "C"},; //Indica se o responsável por um scorecard deve ter acesso a todos os seus filhos.
						{"STR_REAL"				,"Real"			, "C"},; //String personalizada pelo usuário
						{"STR_META"				,"Meta"			, "C"},; //String personalizada pelo usuário
						{"STR_SCO"				, cStrUser		, "C"},; //String personalizada pelo usuário
						{"STR_PREVIA"			,"Previa"		, "C"},; //String personalizada pelo usuário
						{"SEGURANCA_NOTA"		,"F"			, "C"},; //Seguranca para permissao de inclusao de nota para indicador/objetivo						
						{"MODO_ANALISE"			, cModoAnal		, "C"},; //modo de análise "1"=PDCA, "2"=BSC
						{"BLOQ_POR_DIA_LIMITE"	, "F"			, "C"},; //Bloqueio da alteração da Planilha Valores, baseado no campo Dia Limite
						{"MSG_BLOQ_DIA_LIMITE"	, ""			, "M"},; //Mensagem a ser inserida no corpo do e-mail a ser enviado na notificação de prazo final de atualização dos indicadores.
						{"FILTER_ACAO_PLANACAO"	, "F"			, "C"},; //Filtrar plano de acao e acao pelo usuario responsavel
						{"CTR_APROV_PLANACAO"	, "F"			, "C"},; //Habilitar controle de aprovacao do plano de acao
						{"AVAL_META_SCORE"	    , "F"			, "C"},; //Respeita valores da planilha independente da meta do indicador  
						{"NENHUM_MAIL_ALERTA"	, "F"			, "C"},; //Alertar somente quando o email não puder ser enviada para nenhum destinatário. 
						{"STR_TEND"				, STR0106		, "C"} } //String personalizada pelo usuário ### "Tendência"
return

// Carregar
method oToXMLNode() class TKPI001
	local oXMLNode 		:= TBIXMLNode():New(TAG_ENTITY)
	
	::lPutSystemConfig(@oXMLNode)
	oXMLNode:oAddChild(::oItensSCD())
return oXMLNode

method oItensSCD() class TKPI001
	local oNode, oXMLNode, i     
	local aItensSCD := {;
						{00, STR0001	},;	//"Indicador"
						{01, STR0002	},; //"Peso (decrescente)"
						{02, STR0003	};	//"Personalizada"
	    		   	   }

	oXMLNode := TBIXMLNode():New("ITENS_SCD")
    
	for i:= 1 to len(aItensSCD) 
			oNode := oXMLNode:oAddChild(TBIXMLNode():New("ITENS_SCD"))
			oNode:oAddChild(TBIXMLNode():New("ID",aItensSCD[i][1]))		
			oNode:oAddChild(TBIXMLNode():New("NOME"	,aItensSCD[i][2]))                           
	next
return oXMLNode


method lPutSystemConfig(oXMLNode) class TKPI001
	local nIndProp 	:= 0
	local cValorProp:= ""	
	local cField := ""
    
	//Se nao existir carrega os registros defaults.
	for nIndProp := 1 to len(::aSystemProp)

		if ::lSeek(1,{::aSystemProp[nIndProp][1]})
		    
			cField := ::getDataName(::aSystemProp[nIndProp][1])

			cValorProp	:= alltrim(::cValue(cField))

		else
			//Retorna a propriedade padrao quando nao a encontra no banco
			cValorProp	:= alltrim(::aSystemProp[nIndProp,2])
		endif

		oXMLNode:oAddChild(TBIXMLNode():New(::aSystemProp[nIndProp,1],cValorProp))

	next nIndProp

return .T.

//Atualizacao 
method nUpdFromXML(oXML, cPath,cUserID) class TKPI001
	local nStatus 		:= KPI_ST_OK 
	local cEnableLog	:= "F"
	private oTmpNode
	private oXMLInput	:= oXML

	if nStatus == KPI_ST_OK 
		cEnableLog := alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_LOG_USER_ENABLE:TEXT)
		::oOwner():foEnableLogUser := cEnableLog == "T"
    	nStatus := ::setValue( "LOG_USER_ENABLE", cEnableLog )
    endif  
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "NUM_DIA_PRO_FIN", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_NUM_DIA_PRO_FIN:TEXT) )
    endif  
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "PRAZO_PARA_VENC", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_PRAZO_PARA_VENC:TEXT) )
    endif  
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "SCRDING_INTERVAL_UPD", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_SCRDING_INTERVAL_UPD:TEXT) )
    endif    
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "DECIMALVAR", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_DECIMALVAR:TEXT) )
    endif  
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "SHOWVARCOL", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_SHOWVARCOL:TEXT) )
    endif  
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "VALOR_PREVIO", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_VALOR_PREVIO:TEXT) )
    endif   
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "ALT_DATAFIM_PLANO", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_ALT_DATAFIM_PLANO:TEXT) )
    endif  
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "CFGDTACUMULADO", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_CFGDTACUMULADO:TEXT) )
    endif  
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "INDVERM_APRESENT", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_INDVERM_APRESENT:TEXT) )
    endif    
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "BLQ_ALT_VLR", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_BLQ_ALT_VLR:TEXT) )
    endif    
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "WFINSERTACTION", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_WFINSERTACTION:TEXT) )
    endif  
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "OWNER_ALT_PLANILHA", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_OWNER_ALT_PLANILHA:TEXT) )
    endif                                         

    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "INFO_INC_META", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_INFO_INC_META:TEXT) )
    endif                                         
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "INFO_ALT_META", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_INFO_ALT_META:TEXT) )
    endif                               
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "INFO_EXC_META", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_INFO_EXC_META:TEXT) )
    endif                                         
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "ORDEM_SCD", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_ORDEM_SCD:TEXT) )
    endif  
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "CFGDTMESANTERIOR", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_CFGDTMESANTERIOR:TEXT) )
    endif       
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "SHOWCOLPERIODO", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_SHOWCOLPERIODO:TEXT) )
    endif    
    
  	if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "SHOWCOLMEDIDA", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_SHOWCOLMEDIDA:TEXT) )
    endif     
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "PERMISSAO_RECURSIVA", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_PERMISSAO_RECURSIVA:TEXT) )
    endif      

    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "SEGURANCA_NOTA", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_SEGURANCA_NOTA:TEXT) )
    endif      
 
	if nStatus == KPI_ST_OK
		nStatus := ::setValue( "STR_SCO", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_STR_SCO:TEXT) )
	endif 
	if nStatus == KPI_ST_OK
		nStatus := ::setValue( "STR_REAL", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_STR_REAL:TEXT) )
	endif 
	if nStatus == KPI_ST_OK
		nStatus := ::setValue( "STR_META", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_STR_META:TEXT) )
	endif 
	if nStatus == KPI_ST_OK
		nStatus := ::setValue( "STR_PREVIA", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_STR_PREVIA:TEXT) )
	endif
	
	if nStatus == KPI_ST_OK
		nStatus := ::setValue( "BLOQ_POR_DIA_LIMITE", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_BLOQ_POR_DIA_LIMITE:TEXT) )
	endif

	if nStatus == KPI_ST_OK
		nStatus := ::setValue( "MSG_BLOQ_DIA_LIMITE", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_MSG_BLOQ_DIA_LIMITE:TEXT) )
	endif

	if nStatus == KPI_ST_OK
		nStatus := ::setValue( "FILTER_ACAO_PLANACAO", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_FILTER_ACAO_PLANACAO:TEXT) )
	endif

	if nStatus == KPI_ST_OK
		nStatus := ::setValue( "CTR_APROV_PLANACAO", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_CTR_APROV_PLANACAO:TEXT) )
	endif      
	
	if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "AVAL_META_SCORE", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_AVAL_META_SCORE:TEXT) )
    endif    
    
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "NENHUM_MAIL_ALERTA", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_NENHUM_MAIL_ALERTA:TEXT) )
    endif   

	//Atribui o texto informado no parâmetro
    if nStatus == KPI_ST_OK
    	nStatus := ::setValue( "STR_TEND", alltrim(oXMLInput:_REGISTROS:_PARAMETRO:_STR_TEND:TEXT) )
    endif   

	::oOwner():getStrCustom():doRefresh()

return nStatus


//Retorna o valor da propriendade no banco caso não seja
//encontrado, retorna o valor default da propriedade
//Lucio Pelinson 12/12/2007
method getValue(cKey) class TKPI001
	local cRet := ""
	local nPos := 0
	local cField := ""

	if( ::lSeek(1,{cKey}) )
		cField := ::getDataName(cKey)
		cRet := alltrim(::cValue(cField))
	else
		nPos := aScan(::aSystemProp, {|aVal| aVal[1] == cKey})
		if nPos > 0
			cRet := ::aSystemProp[npos][2]
		endif
	endif

return cRet

//Grava o valor da propriendade no banco
//Lucio Pelinson 12/12/2007
method setValue(cKey, cValue) class TKPI001
	local nStatus	:= KPI_ST_OK
	local aFields	:= {}
	local cField	:= ::getDataName(cKey)
	local nPos		:= 0
	local cType		:= "C"
	
	nPos := aScan(::aSystemProp, {|x| x[1] == cKey})
	if nPos > 0
		cType := ::aSystemProp[nPos][3]
	endif

	aFields := {{"CHAVE", cKey},{cField, cValue}, {"TIPO", cType}}
	
	//Verificar se a propriedade ja existe.
	if(!::lSeek(1, {cKey}))                         	
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
		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	 
	endif

return nStatus


method getDataName(cKey) class TKPI001

	local nPos := 0
	local cAux := "C"
	local cName := "DADO"

	nPos := aScan(::aSystemProp, {|x| x[1] == cKey})
	if nPos > 0
		cAux := ::aSystemProp[nPos][3]
	endif

	if cAux == "M"	
		cName := "DADOM"
	else
		cName := "DADO"
	endif

return cName


//Retorna o nome padrao do scorecard dependendo do tipo de analise.
method getScoDefName() class TKPI001
	local cScoDefName := "Scorecard"
	local nAnaMod 	  := getJobProfString("AnalysisMode", ANALISE_PDCA)

	if nAnaMod == ANALISE_BSC
		cScoDefName := STR0087 //Entidades
	endif
	
return cScoDefName

function _KPI001_Par()
return nil
