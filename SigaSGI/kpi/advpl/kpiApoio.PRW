#include "KPIDefs.ch"
#include "kpiApoio.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//Cores
#DEFINE VERDE 'rgb(0,255,0)'
#DEFINE AMARELO 'rgb(255,255,0)'
#DEFINE VERMELHO 'rgb(255,0,0)'

#define CRLF 		chr(10)+chr(13)

static __MSG_ERROR

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} sgiDshServices
Retorna a definição dos serviços disponíveis no SigaDW

@author		2481 - Paulo R Vieira
@version	P11 
@since		10/12/2009
@return		
/*/
//-------------------------------------------------------------------------------------
static function sgiServices(acuUserName, acPassword)
	Local nInd, nInd2, nInd3, aAux := {}
	Local aServices := {}
	Local oScorecards, aScorecards, aIndicadores := {}
	Local cXML
	
	sgiStart(acuUserName, acPassword)
	
	// Extrai valores do XML
	oScorecards := oKPICore:oGetTable("SCORECARD"):oToXMLList(.T.)
	aScorecards := oScorecards:FACHILDREN
	For nInd := 1 to len(aScorecards)
		aScorecards[nInd] := {allTrim(aScorecards[nInd]:FACHILDREN[2]:FCVALUE), allTrim(aScorecards[nInd]:FACHILDREN[1]:FCVALUE)}

		aAux := oKPICore:oGetTable("INDICADOR"):oToXMLList("ID_SCOREC = '" + aScorecards[nInd, 2] + "'")
		aAux := aAux:FACHILDREN
		
		For nInd2 := 1 to len(aAux)
			aAdd( aIndicadores, { ;
					allTrim(aAux[nInd2]:FACHILDREN[2]:FCVALUE) + " [" + aScorecards[nInd, 1] + "]", ;
					allTrim(aAux[nInd2]:FACHILDREN[1]:FCVALUE) ;
				} )
		Next
	Next
	
	// monta os parâmetros para o serviço de Tabelas do SGI
	aAux := { ;
				{"scorecard", STR0001, "String", "true", aScorecards}, /*###Selecione o Scorecard:*/ ;
				{"dataAlvo", STR0002, "Date", "true", {}}, /*###Data Alvo:*/ ;
				{"dataDe", STR0003, "Date", "true", {}}, /*###Data De:*/ ;
				{"dataAte", STR0004, "Date", "true", {}} /*###Data Até:*/ ;
			}
	aAdd(aServices, { "scoretable", STR0005, "TABLE", aAux }) /*###"Visualização de Scorecards"*/
	
	// monta os parâmetros para o serviço de Painel de Indicador do SGI
	aAux := { ;
				{"indicador", STR0006, "String", "true", aIndicadores}, /*###"Selecione o Indicador:"*/ ;
				{"dataAlvo", STR0002, "Date", "true", {}}, /*###Data Alvo:*/ ;
				{"dataDe", STR0003, "Date", "true", {}}, /*###Data De:*/ ;
				{"dataAte", STR0004, "Date", "true", {}}, /*###Data Até:*/ ;
				{"analyse", STR0021, "Date", "true", {{STR0022, "1"}, {STR0023, "2"}} } /*###"Tipo da análise"###"Parcelada"###"Acumulada"*/ ;
			}
	aAdd(aServices, { "scoregraph", STR0007, "GRAPH", aAux }) /*###"Painel de Indicadores"*/
	
	// monta o XML de retorno ao Dashboard
	cXML := "" +;
		'<?xml version="1.0" encoding="ISO-8859-1"?>' +CRLF+;
		'<dashboard xmlns="http://www.w3schools.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' +CRLF+;
		'		xsi:schemaLocation="http://www.w3schools.com">' +CRLF+;
		'	<services>'+CRLF
	
	For nInd := 1 to len(aServices)
		cXML +=	'		<service>' +CRLF+;
				'			<name>' + aServices[nInd, 1] + '</name>' +CRLF+;
				'			<description>' + aServices[nInd, 2] + '</description>' +CRLF+;
				'   		<type>' + aServices[nInd, 3] + '</type>' +CRLF+;
				'   		<parameters>'+CRLF
		
		aAux := aServices[nInd, 4]
		For nInd2 := 1 to len(aAux)
			aSize(aAux[nInd2], 5)
			cXML += '	 		<parameter>'+CRLF+;
					'	  			<name>'+ aAux[nInd2, 1] +'</name>'+CRLF+;
					'	 			<description>'+ aAux[nInd2, 2] +'</description>'+CRLF+;
					'	 			<type>'+ aAux[nInd2, 3] +'</type>'+CRLF+;
					'	 			<required>'+ aAux[nInd2, 4] +'</required>'+CRLF+;
					'	  			<options>'+CRLF
			
			For nInd3 := 1 to len(aAux[nInd2, 5])
				cXML += '		 			<option>'+CRLF+;
						'						<label>' + aAux[nInd2, 5][nInd3, 1] +'</label>'+CRLF+;
						'						<value>' + aAux[nInd2, 5][nInd3, 2] +'</value>'+CRLF+;
						'		 			</option>'+CRLF
			Next
			
			cXML += '		 		</options>'+CRLF+;
					'	  		</parameter>'+CRLF
		Next
		
		cXML += '	 		</parameters>' +CRLF+;
				' 		</service>'+CRLF
	Next
	cXML += ''+;
		'		<genericServiceEntry>sigaSgiDshService</genericServiceEntry>' +CRLF+;
		'	</services>'+CRLF+;
		'</dashboard>'+CRLF
		
return cXML

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} getKpiDashboardServices
Retorna a lista de serviços disponíveis no SigaDW para o Dashboard

@author		2481 - Paulo R Vieira
@version	P11 
@since		01/12/2009
@return		XML com os serviços
@parameter	Usuário e senha 
/*/
//-------------------------------------------------------------------------------------
function getKpiDashboardServices(cXML)

	Local oXml, oDsh, cRet
	
	oXml := loadXML(cXML)
	If valType(oXml) == "O"
		oDsh := XmlChildEx(oXml, "_DASHBOARD")
		cRet := sgiServices(XmlChildEx(oDsh, "_USERNAME"):Text, XmlChildEx(oDsh, "_PASSWORD"):Text)
	EndIf
	
return showAnyError(cRet)

function sigaSgiDshService(cXML)
	Local oXml, cError := cWarning := "", aParms := {}, aParameters, nParms, nInd, oDsh, cRet, cService
	Local aOperations, nOpers, command
	
	oXml := loadXML(cXML)
	If ! valType(oXml) == "O"
		return showAnyError(cRet)
	EndIf
	
	oDsh		:= XmlChildEx(oXml, "_DASHBOARD")
	cService 	:= XmlChildEx(oDsh, "_SERVICE"):Text
	
	sgiStart(XmlChildEx(oDsh, "_USERNAME"):Text, XmlChildEx(oDsh, "_PASSWORD"):Text)
	
	aParameters := XmlChildEx(oDsh:_PARAMETERS,"_PARAMETER")
	aParameters := iif(valType(aParameters) == "O", {aParameters}, aParameters)
	nParms 		:= len(aParameters)
	For nInd := 1 to nParms
		aAdd(aParms, aParameters[nInd]:_Value:Text)
	Next
	
	aOperations := XmlChildEx(oDsh:_OPERATIONS, "_OPERATION")
	aOperations := iif(valType(aOperations) == "O", {aOperations}, aOperations)
	nOpers 		:= len(aOperations)
	For nInd := 1 to nOpers
		command := aOperations[nInd]:_Command:Text
		//aOperations[nInd]:_Id:Text //aOperations[nInd]:_Command:Text
		//aOperations[nInd]:_Type:Text //aOperations[nInd]:_Value:Text
		If command == "DSHBI->LOAD" .OR. command == "DSHBI->REFRESH"
			If cService == "scoretable"
				cRet := dshSgiTable(aParms)
			ElseIf cService == "scoregraph"
				cRet := dshSgiWidget(aParms)
			EndIf
		ElseIf command == "DSHBI->ALTER_PROPS"
			// TODO
		ElseIf command == "DSHBI->ATTR_ALERT"
			// TODO
		ElseIf command == "DSHBI->ATTR_FILTER"
			// TODO
		ElseIf command == "DSHBI->PAGE_NEXT"
			// TODO
		ElseIf command == "DSHBI->PAGE_PREV"
			// TODO
		ElseIf command == "DSHBI->DRILL_DOWN"
			// TODO
		ElseIf command == "DSHBI->DRILL_UP"
			// TODO
		EndIf
	Next
	
return showAnyError(cRet)
        

static function dshSgiTable(aParms)
	local oXmlInd		:= nil
	local aData 		:= {}
	local aFlds			:= {}
	local aInd			:= {}
	local nInd			:= 0
	local nInd2			:= 0
	local nPosInd 		:= 0   
	local nStatus 		:= ESTAVEL_GRAY
	local cXML			:= ""
	local cValue		:= ""
	local oParametro	:= oKPICore:oGetTable("PARAMETRO")

	Local aFields := { ;
			{"ACAO", STR0008 /*"Ação"*/}, ;
			{"TENDENCIA", oParametro:getValue("STR_TEND") /*"Tendência"*/}, ;  //Pega o conteúdo definido no parâmetro
			{"INDICADOR", PadR( STR0010, 30 ) /*"Indicador"*/}, ;
			{"UNIDADE", STR0011 /*"Unidade de " "Medida"*/}, ;
			{"FREQNOME", PadR( STR0012, 15 ) /*"Período"*/}, ;
			{"VALOR", PadR( STR0013, 15 ) /*"Real"*/}, ;
			{"META", PadR( STR0014,15 ) /*"Meta"*/}, ;
			{"VARIACAO", PadR( STR0015, 15) /*"Variação"*/}, ;
			{"ACUMULADO_PERIDO", STR0016 /*"Valor Acumulado"*/}, ;
			{"ACUMULADO_META", STR0017 /*"Meta Acumulado"*/}, ;
			{"VARIA_ACUMULADA", STR0018 /*"Variação Acumulada"*/} ;
		}
	                             
	
	Local cAux := "SCORECARD|"+cBIStr(cToD(aParms[2]))+"|"+cBIStr(cToD(aParms[3]))+"|"+cBIStr(cToD(aParms[4]))+"|"+aParms[1]+"|F|F|T|0|F|"
		
	oXmlInd :=  oKPICore:oGetTable("SCORECARDING"):oToXMLNode(aParms[1], cAux)
	
	nPosInd := aScan(oXmlInd:FACHILDREN, {|x| x:FCTAGNAME == "PLANILHAS"})
	aInd := oXmlInd:FACHILDREN[nPosInd]:FACHILDREN
	if len(aInd) > 0
		aData := Array(len(aInd))
		For nInd := 1 to len(aInd)
			aFlds := aInd[nInd]:FACHILDREN
			aData[nInd] := Array(len(aFields))
			For nInd2 := 1 to len(aFlds)
				If (nPos := aScan(aFields, {|x| x[1] == left(aFlds[nInd2]:FCTAGNAME, len(x[1]) ) })) > 0
					cValue := aFlds[nInd2]:FCVALUE
					If "ACAO" == left(aFlds[nInd2]:FCTAGNAME, 4)
						If cValue == "0"
							cValue := '&lt;img src="imagensExternas/ic_scorecardacao.gif" alt="" /&gt;'
						Else
							cValue := '&lt;img src="imagensExternas/ic_vazio.gif" alt="" /&gt;'
						EndIf
					ElseIf "TENDENCIA" == left(aFlds[nInd2]:FCTAGNAME, 9)
						nStatus := val(cValue)
						If nStatus == STATUS_GREEN 
							cValue := '&lt;img src="imagensExternas/ic_status_green.gif" alt="" /&gt;'
						ElseIf nStatus == STATUS_RED
							cValue := '&lt;img src="imagensExternas/ic_status_red.gif" alt="" /&gt;'
						ElseIf nStatus == STATUS_YELLOW
							cValue := '&lt;img src="imagensExternas/ic_status_yellow.gif" alt="" /&gt;'
						ElseIf nStatus == ESTAVEL_GREEN
							cValue := '&lt;img src="imagensExternas/ic_estavel_green.gif" alt="" /&gt;'
						ElseIf nStatus == ESTAVEL_RED
							cValue := '&lt;img src="imagensExternas/ic_estavel_redlg.gif" alt="" /&gt;'
						ElseIf nStatus == ESTAVEL_YELLOW
							cValue := '&lt;img src="imagensExternas/ic_estavel_yellowlg.gif" alt="" /&gt;'
						ElseIf nStatus == TEND_GREENDN
							cValue := '&lt;img src="imagensExternas/ic_tendencia_greendn.gif" alt="" /&gt;'
						ElseIf nStatus == TEND_GREENUP
							cValue := '&lt;img src="imagensExternas/ic_tendencia_greenup.gif" alt="" /&gt;'
						ElseIf nStatus == TEND_REDDN
							cValue := '&lt;img src="imagensExternas/ic_tendencia_reddn.gif" alt="" /&gt;'
						ElseIf nStatus == TEND_REDUP
							cValue := '&lt;img src="imagensExternas/ic_tendencia_redup.gif" alt="" /&gt;'
						ElseIf nStatus == TEND_YELLOWDN
							cValue := '&lt;img src="imagensExternas/ic_tendencia_yellowdn.gif" alt="" /&gt;'
						ElseIf nStatus == TEND_YELLOWUP
							cValue := '&lt;img src="imagensExternas/ic_tendencia_yellowup.gif" alt="" /&gt;'
						ElseIf nStatus == ESTAVEL_GRAY
							cValue := '&lt;img src="imagensExternas/ic_graysm.gif" alt="" /&gt;'
						EndIf
					EndIf
					aData[nInd, nPos] := cValue
				EndIf
			Next
		Next
		
		cXML := ''
		cXML += '<?xml version="1.0" encoding="ISO-8859-1" ?>'+CRLF+;
		        '<dashboard xmlns="http://www.w3schools.com" '+CRLF+;
		        '	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '+CRLF+;
		        ' 		xsi:schemaLocation="http://www.w3schools.com">'+CRLF+;
		        '    <table>'+CRLF+;
		        '        <definition>'+CRLF+;
		        '            <title>'+ "Scorecard" +'</title>'+CRLF+;
		        '            <drilldown></drilldown>'+CRLF+;
		        '            <drillup></drillup>'+CRLF+;
		        '            <pagenext></pagenext>'+CRLF+;
		        '            <pageprev></pageprev>'+CRLF+;
		        '            <refresh></refresh>'+CRLF+;
				'            <cols>'+CRLF
		
		For nInd := 1 to len(aFields)
			cXML += ''+;
		        '                <col>'+CRLF+;
		        '                    <id></id>'+CRLF+;
		        '                    <title>'+aFields[nInd, 2] +'</title>'+CRLF+;
		        '                    <size>'+cBIStr(len(aFields[nInd, 2]))+'</size>'+CRLF+;
		        '                    <sorteable>false</sorteable>'+CRLF+;
		        '                    <searchable>false</searchable>'+CRLF+;
		        '                    <align>LEFT</align>'+CRLF+;
		        '                </col>'+CRLF
		Next
		
		cXML += '            </cols>'+CRLF+;
		        '            <alerts>'+CRLF+;
		        '            </alerts>'+CRLF+;
		        '            <filters>'+CRLF+;
				'            </filters>'+CRLF+;
				'        </definition>'+CRLF+;
				'        <data>'+CRLF+;
				'            <rows>'+CRLF
		
		For nInd := 1 to len(aData)
			cXML += ''+;
				'                <row>'+CRLF+;
				'                    <cols>'+CRLF
				
				For nInd2 := 1 to len(aData[nInd])
					cXML += ''+;
						'                     <col>'+CRLF+;
						'                         <id></id>'+CRLF+;
						'                         <colData>'+cBIStr(aData[nInd, nInd2]) +'</colData>'+CRLF+;
						'                      </col>'+CRLF
				Next
		
			cXML += ''+;
				'                    </cols>'+CRLF+;
				'                </row>'+CRLF
		Next
				
		cXML += '            </rows>'+CRLF+;
				'        </data>'+CRLF+;
				'    </table>'+CRLF+;
				'</dashboard>'
	else
		__MSG_ERROR := "ScoreCard não possui indicadores cadastrados."
	endif
	
return showAnyError(cXml)

static function showAnyError(cXml)
	
	Local oXml
	
	If ! empty(__MSG_ERROR)
		oAttr := TBIXMLAttrib():new()
		oAttr:lSet("xmlns", 'http://www.w3schools.com')
		oAttr:lSet("xmlns:xsi", 'http://www.w3.org/2001/XMLSchema-instance')
		oAttr:lSet("xsi:schemaLocation", 'http://www.w3schools.com')
  		oXml := TBIXMLNode():New("dashboard", , oAttr)
  
		oXml:oAddChild(TBIXMLNode():New("error", __MSG_ERROR))
		cXml := oXml:cXMLString(.t., "ISO-8859-1")
	EndIf
	
return cXml

static function sgiStart(acuUserName, acPassword)
	
	public oKPICore
	
	oKPICore := TKPICore():New("")
    oKPICore:nDBOpen()
  	If oKPICore:nLogin(acuUserName, acPassword) <= 0
  		__MSG_ERROR := STR0019 /*Usuário ou senha inválidos"*/
  	EndIf
  	
return oKPICore

static function loadXML(cXml)
	Local oXml, cError := cWarning := ""
	
	oXml := XmlParser(cXml, '_', @cError, @cWarning)
	If !empty(cError)
		__MSG_ERROR := "RPC Call Error - " + cError
	ElseIf !empty(cWarning)
		__MSG_ERROR := "RPC Call Error - " + cWarning
	ElseIf valType(oXml) == "U"
		__MSG_ERROR := "RPC Call Error - " + STR0020 + cXml /*"Não foi possível criar o Objeto XML. Verifique o XML: "*/
	EndIf
	
return oXml


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} dshSgiWidget
Widget do tipo odometro
@author		Lucio Pelinson
@version	P11.5 
@since		23/06/2010
@return String com XML para o protocolodo de comunicação		
/*/
//-------------------------------------------------------------------------------------
static function dshSgiWidget(aParms)   
	local aRanges 		:= {}   
	local aValores		:= {}
	local oIndicador	:= nil
	local oPlanilha	:= nil
	local dAlvo			:= nil
	local dAcumDe		:= nil
	local dAcumAte		:= nil
	local oXml			:= nil
	local cTipo			:= ""
	local cIndId		:= ""    
	local cRequest		:= ""
	local nPonteiro	:= 0
	local nRangeTol	:= 0
	local nMinValue	:= 0
	local nMaxValue	:= 200
	local nMetaPct		:= 100
	local nMeta			:= 0
	local nReal			:= 0   
	local nToleran		:= 0

	cIndId	:= aParms[1]
	dAlvo 	:= cToD(aParms[2])
	dAcumDe	:= cToD(aParms[3])
	dAcumAte	:= cToD(aParms[4])
	cTipo 	:= aParms[5] //1=Parcelado 2=Acumulado
	
	
	//Inicia a construção do XML.
	oXml := BIDshXmlGraphView():BIDshXmlGraphView()
	
	//Posicionando o indicador
	oIndicador := oKPICore:oGetTable("INDICADOR")
	if oIndicador:lSeek(1, {cIndId})
	
		//Posicionando a planilha de valores
		oPlanilha  := oKPICore:oGetTable("PLANILHA")	
		if(oPlanilha:lDateSeek(oIndicador:cValue("ID"), dAlvo, oIndicador:nValue("FREQ")))
			//Recupera valores do indicador                                 
			/*
			aValores[VAL_REAL]			:= nReal	
			aValores[VAL_META]			:= nMeta
			aValores[VAL_REAL_ACU]		:= nRealAcum
			aValores[VAL_META_ACU]		:= nMetaAcum
			aValores[VAL_REAL_STATUS]	:= nStatus
			aValores[VAL_ACUM_STATUS]	:= nAcuStatus
		   aValores[VAL_PREVIA]		:= nPrevia                         
	   	*/
			aValores 	:= oIndicador:aGetIndValores(dAlvo,dAcumDe,dAcumAte)
		else
			aValores	:= {0,0,0,0,ESTAVEL_GRAY,ESTAVEL_GRAY,0}
			nDecimais 	:= 2
		endif                  
      
		
		//Valores Parcelado ou Acumulado
		if cTipo == "1" //Parcelado
			nMeta := aValores[VAL_META]
			nReal := aValores[VAL_REAL]
		else                          
			nMeta := aValores[VAL_META_ACU]
			nReal := aValores[VAL_REAL_ACU]
		endif
		 
		//Verificamos a tolerancia do indicador
		nToleran := oIndicador:nGetTolPercent()                           
		
		//Range de cor		
		if oIndicador:lValue("ASCEND")                    
			nRangeTol := nMetaPct - nToleran
			aAdd(aRanges, oXml:buildRangeProperties(nMinValue, nRangeTol, VERMELHO))
			aAdd(aRanges, oXml:buildRangeProperties(nRangeTol, nMetaPct, AMARELO))
			aAdd(aRanges, oXml:buildRangeProperties(nMetaPct, nMaxValue, VERDE))
		else              
			nRangeTol := nMetaPct + nToleran 
			aAdd(aRanges, oXml:buildRangeProperties(nMaxValue, nRangeTol, VERMELHO) )
			aAdd(aRanges, oXml:buildRangeProperties(nRangeTol, nMetaPct, AMARELO))
			aAdd(aRanges, oXml:buildRangeProperties(nMetaPct, nMinValue, VERDE))
		endif	


		//Ponteiro
		if (nMeta > 0) 
			nPonteiro = (nReal * 100) / nMeta
		endif

		//Limitamos o valor do ponteiro no caso de estouro
		if (nPonteiro < nMinValue) 
			nPonteiro = nMinValue - 8
		elseif (nPonteiro > nMaxValue) 
			nPonteiro = nMaxValue + 8
		endif


		//Define o título do gráfico.
		oXml:defineTitles(alltrim(oIndicador:cValue("NOME")))
		
		//Define links para drill down.
		oXml:defineLinks() 	                                                
		
		//Título do eixo.     
		if oIndicador:lValue("ASCEND")    
			oXml:addAnalogGaugeAxis( (cBIStr(nPonteiro) + " %"),;
										 {{ cBIStr(nPonteiro) , alltrim(oIndicador:cValue("NOME")) }},;
										 "", nil, nil, aRanges, nMinValue, nMaxValue)
		else
			oXml:addAnalogGaugeAxis( (cBIStr(nPonteiro) + " %"),;
										 {{ cBIStr(nPonteiro) , alltrim(oIndicador:cValue("NOME")) }},;
										 "", nil, nil, aRanges, nMaxValue, nMinValue)
		endif
		cRequest := oXml:getXml()
   else
   	__MSG_ERROR := "Indicador não localizado Indicador ID = " + cBIStr(cIndId)
	endif		  

return showAnyError(cRequest)

/*
user function testeDsh()          

	local aParms := {"0000000001","23/06/10","01/01/10","31/12/10","1"}
	prepare environment empresa "99" filial "01"
	sgiStart("SGIADMIN", "SGI")
	conout(dshSgiWidget(aParms))

	local aParms := {"0000000001","23/06/10","01/01/10","31/12/10"}
	prepare environment empresa "99" filial "01"
	sgiStart("SGIADMIN", "SGI")
	conout(dshSgiTable(aParms))	
return   
*/
