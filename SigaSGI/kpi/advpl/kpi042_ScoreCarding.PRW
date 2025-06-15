/* ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI042_ScoreCarding.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 20.10.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------*/
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI042_ScoreCarding.ch"
/*--------------------------------------------------------------------------------------
@entity ScoreCarding
Monta os itens para demonstracao do scorecarding.
@table KPI042
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "SCORECARDING"
#define TAG_GROUP  "SCORECARDINGS"
#define TEXT_ENTITY STR0001/*//"ScoreCarding"*/
#define TEXT_GROUP  STR0002/*//"ScoreCardings"*/    

//Constantes para o array aIndStatus
#define IND_STATUS 	01
#define PESO	 	02

//aValores
#define VAL_REAL			1
#define VAL_META			2
#define VAL_REAL_ACU		3
#define VAL_META_ACU		4
#define VAL_REAL_STATUS		5
#define VAL_ACUM_STATUS		6
#define VAL_PREVIA			7

class TKPIScoreCarding from TBITable
	data aIndStatus //Status dos indicadores para calculo do status do scorecard. 
    
	method New() constructor
	method NewKPI042()

	// registro atual
	method oToXMLNode(cID,cRequest)
	method lAddIndicador(cID,cTipoRequest,oXMLPlanilha,aDataAnalise,cScorID,aIndPac)//Atencao! oXMLPlanilha deve ser passado por referencia.
	method nScoreStatus()
	method nExecute(cID, cExecCMD)
    
	method oToXMLScoStatus(aIndPac, aScoID, dDataAlvo)
	method cBuildPacFilter(aPacAcess)   
	method oScoDefault(aScoId, cID)       
	
endclass
	
method New() class TKPIScoreCarding
	::NewKPI042()
return

method NewKPI042() class TKPIScoreCarding
	::NewObject() 
	::aIndStatus	:= {}
return

/*-------------------------------------------------------------------------------------
Carrega o statos dos scorecards filhos solicitados
@param aIndPac (Array)
@param aScoID (Array) 
@param dDataAlvo (Data)
@return 
--------------------------------------------------------------------------------------*/
method oToXMLScoStatus(aIndPac, aScoID, dDataAlvo) class TKPIScoreCarding
	local oIndicador	:= ::oOwner():oGetTable("INDICADOR")
	local oPlaValor		:= ::oOwner():oGetTable("PLANILHA")
	local nQtd			:= 0
	local nGrpQtd 		:= len(aIndPac)	
	local oXMLNode		:= nil
	local oAttrib		:= nil
	local oNode			:= nil

	default dDataAlvo := aColPeriodo[1,1]
		
	//Colunas
	oAttrib := TBIXMLAttrib():New()
	//Tipo
	oAttrib:lSet("TIPO", "SCORECARDS_STATUS")
	oAttrib:lSet("RETORNA", .f.)

	//Gera o principal
	oXMLNode := TBIXMLNode():New("SCORECARDS_STATUS",,oAttrib)

	oIndicador:setOrder(1)
	 
	for nQtd := 1 to len(aScoID)
		::aIndStatus := {} 
		
		//Verificando o status dos indicadores deste scorecards    
		if (nGrpQtd > 0) 
			if nGrpQtd == 1    
				oIndicador:cSQLFilter("ID_SCOREC = '" + aScoID[nQtd] + "' AND VISIVEL <> 'F' AND ID_GRUPO = '" + aIndPac[1] + "'")
			else 
				/*Realiza o tratamento da expressão de filtro SQL para ser convertida para ADVPL para DB2400.*/
				If (cBIGetSGDB() =='DB2/400')		
					/*Insere o filtro que será convertido para ADVPL.*/
					oIndicador:cSQLFilter("ID_SCOREC = '" + aScoID[nQtd]	+ "' AND VISIVEL <> 'F' AND ID_GRUPO = " + cBIConcatWSep(" OR ID_GRUPO = ",  ::cBuildPacFilter(aIndPac) ) )
				Else	
					oIndicador:cSQLFilter("ID_SCOREC = '" + aScoID[nQtd]	+ "' AND VISIVEL <> 'F' AND ID_GRUPO IN (" + ::cBuildPacFilter(aIndPac) + ")")
				EndIf
			endif
		else
			oIndicador:cSQLFilter("ID_SCOREC = '" + aScoID[nQtd]	+ "' AND VISIVEL <> 'F' AND ID_INDICA = '0' ")
		endif
		
		oIndicador:lFiltered(.t.)
		oIndicador:_First()
        
		//Verificao status do indicador. 	
		while(!oIndicador:lEof()) 
			if(oPlaValor:lDateSeek(oIndicador:cValue("ID"),dDataAlvo,oIndicador:nValue("FREQ")))
				nIndStatus	:= oIndicador:nIndStatus(oPlaValor)
			else
				nIndStatus	:= ESTAVEL_GRAY
			endif
			
			aadd(::aIndStatus,{nIndStatus,oIndicador:nValue("PESO")})
			oIndicador:_Next()	
		end
		
		oIndicador:cSQLFilter("")	

    	//Status do ScoreCards
		oNode := oXMLNode:oAddChild(TBIXMLNode():New("SCORECARD_STATUS"))
		oNode:oAddChild(TBIXMLNode():New("ID", aScoID[nQtd]))
		oNode:oAddChild(TBIXMLNode():New("SCORE_OWNER",""))		
		oNode:oAddChild(TBIXMLNode():New("STATUS_DATAALVO", ::nScoreStatus()))
	next
	
return oXMLNode

/*-------------------------------------------------------------------------------------
Pacote 
@param aPacAcess- Array
--------------------------------------------------------------------------------------*/
method cBuildPacFilter(aPacAcess) class TKPIScoreCarding
	local nGrpQtd 		:= len(aPacAcess)
	local cGrpFilter 	:= ""
	local iGrpInd		:= 1
	
	if nGrpQtd > 0
		for iGrpInd := 1 to nGrpQtd
			if iGrpInd == nGrpQtd                                
				cGrpFilter += "'" + aPacAcess[iGrpInd] + "'"
			else
				cGrpFilter += "'" + aPacAcess[iGrpInd] + "',"			
			endif
		next
	endif

return cGrpFilter

/*----------------------------------------------
Lista o caminho para chegar no departamento default.
@param (Caracter)cID ID do scorecard.
@param (Array) aTreePath Caminho para chegar no departamento default.
@return (Objeto) No XML a lista de scorecards que formam o path até o scorecard escolhido.
------------------------------------------------*/
method oScoDefault(cID, aTreePath) class TKPIScoreCarding
	local oScoreCard	:= ::oOwner():oGetTable("SCORECARD") 
	Local oXMLNode 		:= Nil
 	
 	Default aTreePath 	:= {}
                      
	if oScoreCard:lSeek(1,{cID})
		::oScoDefault(oScoreCard:cValue("PARENTID"), @aTreePath)
		aAdd(aTreePath,  cID) 	 
	endif   
	
	oXMLNode := TBIXMLNode():New("TREEPATH", cBIConcatWSep("|", aTreePath))
return oXMLNode

/*----------------------------------------------
Carrega o no requisitado.
@param (Caracter)cID ID da entidade.
@param (Caracter) cRequest Sequencia de caracteres com as instrucoes de execuxao
@return (Objeto) No XML com os dados
------------------------------------------------*/
method oToXMLNode(cID,cRequest) class TKPIScoreCarding
	local oParametro		:= ::oOwner():oGetTable("PARAMETRO")
	local oScoreCard	:= ::oOwner():oGetTable("SCORECARD")
	local oUserConfig	:= ::oOwner():oGetTable("USU_CONFIG")
	local oXMLNode 		:= TBIXMLNode():New(TAG_ENTITY)
	local aRequest 		:= aBIToken(cRequest, "|", .f.)	
	local lLoadTree		:= .t.	
	local lChildStatus	:= .t.
	local aDataAnalise	:=	{}
	local cTipoRequest 	:= ""		
	local cScorID		:= ""
	local cIdPacote		:= "" 
	local cVarTitle		:= "" 
	local cVarAcumTitle  := ""
	local nColCount		:= 0
	local aIndPac 		:= {}
	local aIdScoTree	:= {}
	local cDataDe		:= cToD("01/01/"+str(year(date())))
	local cDataAte		:= cToD("31/12/"+str(year(date())))
	local lLoadIndicador:= .f.
	local nColFreeze	:= 3    
	local oXMLPlanilha
	local oAttrib
	local oXMLArvore 

	private aColPeriodo		:= 	{}	//Colunas de valor
	private lVarPercent	 	:= .F.  //Exibir variação em percentual    
	private lShowPeriodo	:= .T.  //Exibir coluna periodo
	private lShowUnMedida	:= .T.  //Exibir coluna unidade de medida
	private lValorPrevio		:= .F.  //Possui prévia
	private nVarDecimal 		:=  2	  //Quantidade de casas decimais da variação em percentual
	   
	Default cRequest 	:= ""	
	
	//Idenfifica se deve ser exibida a prévia.
	lValorPrevio := (oParametro:getValue("VALOR_PREVIO") == "T") 
	
	//Numero de casas decimais
	nVarDecimal  := val(oParametro:getValue("DECIMALVAR"))
   
	//Idenfifica se deve ser exibida a variação em percentual	
	lVarPercent := (oParametro:getValue("SHOWVARCOL") == "T") 
	
	if lVarPercent	               
      	cVarTitle 		:= "%" + STR0022 
		cVarAcumTitle  := cVarTitle + "<br>" + STR0012 
	else
	    cVarTitle 		:= STR0010  
		cVarAcumTitle  := cVarTitle + "<br>" + STR0016 
	endif
	
	if oParametro:getValue("SHOWCOLPERIODO") == "T"
    	lShowPeriodo := .T. 
    	nColFreeze ++
	else                   
		lShowPeriodo := .F.
	endif
	
	if oParametro:getValue("SHOWCOLMEDIDA") == "T"
    	lShowUnMedida := .T.
    	nColFreeze++
	else                   
		lShowUnMedida := .F.
	endif
    
   //Numero de colunas congeladas no scorecarding 
	oXMLNode:oAddChild(TBIXMLNode():New("NCOLFREEZE", 	  nColFreeze)) 	
	
	//Define de congela coluna sem valores no scorecard
	oXMLNode:oAddChild(TBIXMLNode():New("SCOFREEZECOL",   oUserConfig:getUserConfig("SCOFREEZECOL"))) 
	
	//Define se inicia o refresh automático
	oXMLNode:oAddChild(TBIXMLNode():New("SCOAUTOREFRESH", oUserConfig:getUserConfig("SCOAUTOREFRESH"))) 
	
	//Define o intervalo de refresh do scorecarding.
	oXMLNode:oAddChild(TBIXMLNode():New("SCRDING_INTERVAL_UPD", val(oParametro:getValue("SCRDING_INTERVAL_UPD")) )) 
	
	//Define se a árvore deve ser ocultada na inicialização do scorecarding.
	oXMLNode:oAddChild(TBIXMLNode():New("SCOHIDETREE", 	  oUserConfig:getUserConfig("SCOHIDETREE"))) 
	
	//Define o scorecard a ser exibido na inicialização do scorecard.
	oXMLNode:oAddChild(TBIXMLNode():New("SCODEFAULT", 	  oUserConfig:getUserConfig("SCODEFAULT"))) 
	
	//Define a largura das colunas
	oXMLNode:oAddChild(TBIXMLNode():New("SCOWIDTHCOL", 	  oUserConfig:getUserConfig("SCOWIDTHCOL"))) 
	                              
	//Permite visualizar formulas	
	oXMLNode:oAddChild(TBIXMLNode():New("VISUALFORMULAS", ::oOwner():foSecurity:lHasAccess("IND_FORMULA", oUserConfig:cValue("ID"), "CARREGAR")))
	                      
	//Permite visualizar espinha de peixe	
	oXMLNode:oAddChild(TBIXMLNode():New("VISUALESPINHAPEIXE", ::oOwner():foSecurity:lHasAccess("ESP_PEIXE", oUserConfig:cValue("ID"), "CARREGAR")))
	
	//Scorecard para posicionamento padrão
	oXMLNode:oAddChild(::oScoDefault(oUserConfig:getUserConfig("IDSCODEFAULT")))
	
	//Lista com os visualizações de pacote
	oXMLNode:oAddChild(::oOwner():oGetTable("PACOTEXUSER"):oToXMLList())	
	
	//Ordem do scorecard
	oXMLNode:oAddChild(TBIXMLNode():New("ORDEM_SCD", oParametro:getValue("ORDEM_SCD")))
     
	//Exibir variação em percentual (% Atingido)
	oXMLNode:oAddChild(TBIXMLNode():New("VARPERCENT", lVarPercent)) 
	

	//Verifica as opcões de requisicao.	
	If( len(aRequest) > 0 ) 
		//Tipo da Requisicao por Scorecard || Indicador.
		cTipoRequest:= aRequest[1]
		//Data alvo de:
		if(!empty(cToD(aRequest[2])))
			aadd(aDataAnalise,cToD(aRequest[2]))
		else
			aadd(aDataAnalise,cDataDe)
		endif			

		//Data Alvo ate:
		if(!empty(cToD(aRequest[2])))
			aadd(aDataAnalise,cToD(aRequest[2]))
		else
			aadd(aDataAnalise,cDataAte)
		endif

		//Data Acumulado de:
		if(!empty(cToD(aRequest[3])))
			aadd(aDataAnalise,cToD(aRequest[3]))
		else
			aadd(aDataAnalise,cDataDe)
		endif			

		//Data Acumulado ate:
		if(!empty(cToD(aRequest[4])))
			aadd(aDataAnalise,cToD(aRequest[4]))
		else
			aadd(aDataAnalise,cDataAte)
		endif       
		//Filtro por ID do scorecard.	
		cScorID			:= aRequest[5]  
		//Atualiza o status dos scorecards filhos.
		lChildStatus	:= aRequest[6] == "T" 
		//Atualiza a arvore.
		lLoadTree		:= aRequest[7] == "T" 
		//Carrega os indicadores.	
		lLoadIndicador	:= aRequest[8] == "T" 
		//Filtro por pacote.
		cIdPacote		:= aRequest[9]
		//ID dos Scorecards que terão o status atualizado.
		aIdScoTree	:= aBIToken(aRequest[10], ",", .f.) 

		aadd(aColPeriodo,{aDataAnalise[1]})
	endif
	
	//Adicionando as colunas
	oAttrib := TBIXMLAttrib():New()	
	
	//Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	
	//Peso
	cColInd :=  padl(nColCount,3,"0")
	oAttrib:lSet("TAG"+cColInd, "PESO")
	oAttrib:lSet("CAB"+cColInd, STR0017) //"Peso"
	oAttrib:lSet("CLA"+cColInd, KPI_STRING)    
	
	//Ordem
	cColInd :=  padl(nColCount+=1,3,"0")
	oAttrib:lSet("TAG"+cColInd, "ORDEM")
	oAttrib:lSet("CAB"+cColInd, STR0018) //"Ordem"
	oAttrib:lSet("CLA"+cColInd, KPI_INT)

	//Tendencia
	cColInd :=  padl((nColCount+=1),3,"0")
	oAttrib:lSet("TAG"+cColInd, "TENDENCIA")
	// altera o cabeçalho da coluna Tendência pelo conteúdo informado nos parâmetros do sistema.
	oAttrib:lSet("CAB"+cColInd, ::oOwner():getStrCustom():getStrTend()) //"Real"
	oAttrib:lSet("CLA"+cColInd, KPI_IMAGEM)	
	
	//Indicador	
	cColInd :=  padl((nColCount+=1),3,"0")
	oAttrib:lSet("TAG"+cColInd, "INDICADOR")
	oAttrib:lSet("CAB"+cColInd, STR0005) //"Indicador"
	oAttrib:lSet("CLA"+cColInd, KPI_STRING)	
	     
	//Acao
	cColInd :=  padl((nColCount+=1),3,"0")
	oAttrib:lSet("TAG"+cColInd, "ACAO")
	oAttrib:lSet("CAB"+cColInd, STR0003) //"Ação"
	oAttrib:lSet("CLA"+cColInd, KPI_IMAGEM)

	//Nota
	cColInd :=  padl((nColCount+=1),3,"0")
	oAttrib:lSet("TAG"+cColInd, "NOTA")
	oAttrib:lSet("CAB"+cColInd, STR0024) //"Nota"
	oAttrib:lSet("CLA"+cColInd, KPI_IMAGEM) 
	
	//Unidade
	if(lShowUnMedida)
		cColInd :=  padl((nColCount+=1),3,"0")
		oAttrib:lSet("TAG"+cColInd, "UNIDADE")
		oAttrib:lSet("CAB"+cColInd, "<html> <center>" + STR0006 + "<br>" +STR0007+"</center></html>") //"Unidade de"###" Medida"
		oAttrib:lSet("CLA"+cColInd, KPI_STRING)
	endif	
	
	//Período                          
	if lShowPeriodo
		cColInd :=  padl((nColCount+=1),3,"0")
		oAttrib:lSet("TAG"+cColInd, "FREQNOME")
		oAttrib:lSet("CAB"+cColInd, "<html> <center>" + STR0019+"</center></html>") //"Período
		oAttrib:lSet("CLA"+cColInd, KPI_STRING)
    endif

	//Verifica se é para exibir a coluna de valor prévio		
	if(lValorPrevio)
		nColCount++
		cColInd :=  padl(nColCount,3,"0")
		oAttrib:lSet("TAG"+cColInd, "PREVIA")
		oAttrib:lSet("CAB"+cColInd, ::oOwner():getStrCustom():getStrPrevia()) //"Prévia"
		oAttrib:lSet("CLA"+cColInd, KPI_FLOAT)
	endif
	
	//Coluna de valor 
	nColCount++
	cColInd :=  padl(nColCount,3,"0")
	oAttrib:lSet("TAG"+cColInd, "VALOR")          
	oAttrib:lSet("CAB"+cColInd, ::oOwner():getStrCustom():getStrReal()) //"Real"
	oAttrib:lSet("CLA"+cColInd, KPI_FLOAT)

	//Coluna de Meta
	nColCount++
	cColInd :=  padl(nColCount,3,"0")
	oAttrib:lSet("TAG"+cColInd, "META")
	oAttrib:lSet("CAB"+cColInd, ::oOwner():getStrCustom():getStrMeta()) //"Meta"
	oAttrib:lSet("CLA"+cColInd, KPI_FLOAT)
	    	
	//Coluna de Variacao
	nColCount++		
	cColInd :=  padl(nColCount,3,"0")
	oAttrib:lSet("TAG"+cColInd, "VARIACAO")
	oAttrib:lSet("CAB"+cColInd, cVarTitle ) //"Variação"
	oAttrib:lSet("CLA"+cColInd, KPI_STRING)

	//Coluna de acumulado ate a data pedida.
	cColInd :=  padl((nColCount+=1),3,"0")
	oAttrib:lSet("TAG"+cColInd, "ACUMULADO_PERIDO")
	oAttrib:lSet("CAB"+cColInd, "<html> <center>" + ::oOwner():getStrCustom():getStrReal() + "<br>" + STR0012+"</center></html>") //"Valor "###"Acumulado"
	oAttrib:lSet("CLA"+cColInd, KPI_FLOAT)
	
	//Coluna de acumulado do periodo
	cColInd :=  padl((nColCount+=1),3,"0")
	oAttrib:lSet("TAG"+cColInd, "ACUMULADO_META")
	oAttrib:lSet("CAB"+cColInd, "<html><center>" + ::oOwner():getStrCustom():getStrMeta() + "<br>"+STR0014+"</center></html>") //"Meta "###" Acumulada"
	oAttrib:lSet("CLA"+cColInd, KPI_FLOAT)	
	
	//Variacao do acumulado
	cColInd :=  padl((nColCount+=1),3,"0")
	oAttrib:lSet("TAG"+cColInd, "VARIA_ACUMULADA")
	oAttrib:lSet("CAB"+cColInd, "<html> <center> " + cVarAcumTitle + "</center></html>") //"Variação  "###"Acumulada"
	oAttrib:lSet("CLA"+cColInd, KPI_STRING)


	oXMLPlanilha := TBIXMLNode():New("PLANILHAS",,oAttrib)
    
    //Permissão por pacote
	if !(cIdPacote == "0" .or. cIdPacote =="")
		aIndPac := ::oOwner():oGetTable("PACOTEXGRPIND"):aGrpIndFilter(cIdPacote)  
	endif
    
	//Adicionando as linhas.	
	if (!(alltrim(cID)=="0") .and. lLoadIndicador)
		::lAddIndicador(cID,cTipoRequest,@oXMLPlanilha,aDataAnalise,cScorID,aIndPac)
	endif		

	//Adicionando o no de planilha ao no principal.
	oXMLNode:oAddChild(oXMLPlanilha)
	oXMLNode:oAddChild(TBIXMLNode():New("USER"	   		, ::oOwner():foSecurity:oLoggedUser():cValue("ID")))
	oXMLNode:oAddChild(TBIXMLNode():New("ISADMIN"  		, ::oOwner():foSecurity:oLoggedUser():lValue("ADMIN")))
	oXMLNode:oAddChild(TBIXMLNode():New("VALOR_PREVIO"	, lValorPrevio))
	oXMLNode:oAddChild(TBIXMLNode():New("PACOTE"		, cIdPacote)) 
	
	//Caso seja requisitada a arvore envio novamente.
	if(lLoadTree)
		//Adicionando a arvore ao no principal.
		oXMLArvore	:= TBIXMLNode():New("ARVORES",,)
		oNode 		:= oXMLArvore:oAddChild(TBIXMLNode():New("ARVORE"))
		oNode:oAddChild(oScoreCard:oArvore(.T., cIdPacote))
		oXMLNode:oAddChild(oXMLArvore)    
		oXMLNode:oAddChild(::oToXMLScoStatus(aIndPac,aIdScoTree)) 
	elseif(cTipoRequest=="SCORECARD" .and. lChildStatus )   
		oXMLNode:oAddChild(::oToXMLScoStatus(aIndPac,aIdScoTree))
	endif
	
return oXMLNode

/*-------------------------------------------------------------------------------------
Adiciona o indicador requisitado
@param cID 			- ID da entidade.
@param cReqTipo 	- Tipo da requisicao (SCORECARD ou INDICADOR)
@param oXMLPlanilha - XML onde sera adicionado, o indicador atual.
@param aDataAnalise - Data de analise do indicador.
@return 			- status do processamento.
--------------------------------------------------------------------------------------*/
method lAddIndicador(cID,cReqTipo,oXMLPlanilha,aDataAnalise,cScorID,aIndPac)  class TKPIScoreCarding
	Local oIndicador	:= ::oOwner():oGetTable("INDICADOR")
	Local oScoreCard	:= ::oOwner():oGetTable("SCORECARD")
	Local oUser			:= oKpiCore:foSecurity:oLoggedUser()
	Local nPacote 		:= 0
	Local lExibe		:= .F.
	Local lResponsavel	:= .F.	
	Local oXMLIndicador	:= Nil 		 	 

	If ( oScoreCard:lSeek(1,{cScorID}) )
		lResponsavel := ( oScoreCard:cValue("RESPID") == oUser:cValue("ID") ) .Or. ( oUser:lValue("ADMIN") )
	EndIf
     
    //Adiciona todos os indicadores filhos de um scorecard. 
	If ( cReqTipo=="SCORECARD" ) 	
		nPacote := len(aIndPac)	
		 
		//Identifica se o scorecard possui pacate.   
		If ( nPacote > 0 )  		
			if nPacote == 1                                        
				oIndicador:cSQLFilter("ID_SCOREC = '" + cBIStr(cID)	+ "' AND VISIVEL <> 'F' AND ID_GRUPO = '" + aIndPac[1] + "'")  
			else  		
				If (cBIGetSGDB() =='DB2/400')		
					//Realiza o tratamento da expressão de filtro SQL para ser convertida para ADVPL para DB2400.
					oIndicador:cSQLFilter("ID_SCOREC = '" + oScoreCard:cValue("ID")	+ "' AND VISIVEL <> 'F' AND ID_GRUPO = " + cBIConcatWSep(" OR ID_GRUPO = ",  ::cBuildPacFilter(aIndPac)))
				Else	
					oIndicador:cSQLFilter("ID_SCOREC = '" + oScoreCard:cValue("ID")	+ "' AND VISIVEL <> 'F' AND ID_GRUPO IN (" + ::cBuildPacFilter(aIndPac) + ")")
				EndIf			
			endif
		else			
			oIndicador:cSQLFilter("ID_SCOREC = '" + cBIStr(cID)	+ "' AND VISIVEL <> 'F' AND ID_INDICA = '0' ")
		endif
	else 
		//Adiciona todos os indicadores filhos de um indicador.
		oIndicador:cSQLFilter("ID_INDICA = '" + cBIStr(cID)	+ "'") 
	endif

	oIndicador:setOrder(1)  
	oIndicador:lFiltered(.T.)
	oIndicador:_First()

	While( ! oIndicador:lEof() ) 	
		If(cReqTipo=="SCORECARD")
			lExibe := .T.
		ElseIf(cReqTipo=="INDICADOR" .and.  oIndicador:nValue("ID_INDICA") != 0)
			lExibe := .T.
		Else
			lExibe := .F.	
		EndIf

		If(lExibe) 
			If (oIndicador:lValue("VISIVEL"))		
				oXMLIndicador := oIndicador:oAddIndItem(aDataAnalise, lResponsavel, oUser:cValue("ID"))
				oXMLPlanilha:oAddChild(oXMLIndicador) 
			EndIf				
		Endif

		oIndicador:_Next()
	End While
	
	oIndicador:cSQLFilter("")	
Return .T.

/*---------------------------------------------
Veridica o status do scorecard
@return (Númerico)Status do indicador.
-----------------------------------------------*/
method nScoreStatus() class TKPIScoreCarding
	local nVerdeTotal	:=	0
	local nVermeTotal	:=	0
	local nAmareTotal	:=	0   
	local nAzulTotal	:=  0
	local nValorCinza	:=	0
	local nIndicador	:=	0
	local nStatus		:=	ESTAVEL_GRAY	
	local nQtdInd		:=	len(::aIndStatus)

	for nIndicador := 1 to nQtdInd
		nStatus := ::aIndStatus[nIndicador,IND_STATUS]
        do case 
	        case nStatus == STATUS_GREEN
				nVerdeTotal	+= ::aIndStatus[nIndicador,PESO]
	        case nStatus == STATUS_RED
				nVermeTotal	+= ::aIndStatus[nIndicador,PESO]	        
	        case nStatus == STATUS_YELLOW
				nAmareTotal	+= ::aIndStatus[nIndicador,PESO]  
			case nStatus == STATUS_BLUE
				nAzulTotal  += ::aIndStatus[nIndicador,PESO]
			otherwise
				nValorCinza++
		endcase	        
	next nIndicador

    //Verifica se existe status para ser considerado.
	if(nValorCinza != nQtdInd )
		//Verica qual dos status e o maior
		do case
			case (nVerdeTotal + nAzulTotal 	== 	nVermeTotal)
				nStatus := STATUS_YELLOW
			case nAzulTotal > nVerdeTotal	.And.	nAzulTotal > nVermeTotal	.And.	nAzulTotal >= nAmareTotal
				nStatus := STATUS_BLUE
			case (nVerdeTotal + nAzulTotal)	> 	nVermeTotal .and. (nVerdeTotal + nAzulTotal) >= nAmareTotal
				nStatus := STATUS_GREEN
			case nVermeTotal >= (nVerdeTotal + nAzulTotal) 	.and. nVermeTotal >= nAmareTotal
				nStatus := STATUS_RED           
			otherwise
				nStatus	:=	ESTAVEL_YELLOW
		endcase
	else
		nStatus	:=	ESTAVEL_GRAY									
	endif

return nStatus


method nExecute(cID, cExecCMD) class TKPIScoreCarding
	local oUsuConfig:= ::oOwner():oGetTable("USU_CONFIG") 
	local oUser		:= oKpiCore:foSecurity:oLoggedUser()
	local cUserID	:= oUser:cValue("ID") 
	local aRequest 	:= aBIToken(cExecCMD, ";", .f.)	
	local nReturn   := KPI_ST_OK
	
	nReturn := oUsuConfig:setUserConfig(cUserID,"SCOWIDTHCOL" , aRequest[1], "")
	nReturn := oUsuConfig:setUserConfig(cUserID,"SCOFREEZECOL", aRequest[2], "")
	
return nReturn

function kpi042_scorecarding()
return .t.
