/* ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : kpi031_CalcIndicador.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 02.12.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------*/
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "kpi031_CalcIndicador.ch"
/*--------------------------------------------------------------------------------------
@entity CalcIndicador
Calcula os valores dos indicadores e metas.
@table KPI031
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "CALC_INDICADOR"
#define TAG_GROUP  "CALC_INDICADORES"
#define TEXT_ENTITY STR0001 //"Calculo do Indicador"
#define TEXT_GROUP  STR0002 //"Calculo do Indicadores" 

//Define da constante aParms.
#define FILE_NAME		1
#define KPI_PATH		2
#define KPI_USER		3
#define KPI_REQUEST		4
#define KPI_SITE		5

//Constante para o tipo da formula.
#define FORMULA		1
#define VALOR		2

//Constante para o array aVlrCalculado.
#define AC_VALOR	1
#define AC_META		2
#define AC_PREVIA	3
#define AC_PESO		4  

//Constante para agendamento de cálculo com período dinâmico.
#define SCHED_DINAMIC  "DINAMICO"    
   
//Constante para controle de status de execução. 
#define PARADO  		0 
#define EXECUTANDO  	1
#define FINALIZADO  	2
                              
//Constante de controle global do cálculo dos indicadores. 
#define GLOBAL_LOCK   "bKpiLock"       
#define GLOBAL_RUN    "bKpiCalcRun"        
#define GLOBAL_UPDADE "bKpiIndUpdate"          

class TKPICalcInd from TBITable
    //Cache dos Indicadores calculados. 
    data cacheCalculo
    //Frequencia do Indicador que está sendo cálculado.
    data freqCalculo	
    //Nome do Indicador que está sendo calculado. 
    data nomeCalculo
    //Objeto do Indicador que está sendo calculado. 
    data oIndicador
    //Objeto da Planilha de Valores. 
    data oPlanilha
    //Identificador do Job do cálculo dos indicadores. 
    data cJobName
    //Log do cálculo dos indicadores.
    data calcLog
	
	method New() constructor
	method NewKPI031()
	method oToXMLNode(cID,cRequest)
	method aCalc_Indicador(ID,dData) 
	method aChkItemFormula(cItemFormula,dData, lConsolidador)
	method lUpdateValores(aVlrCalculado)
	method nExecute(cID, cExecCMD)
	method seekHistorico(aDataCalc)
	method addHistorico(aTmpVlrForm,aDataCalc)
	method lOpcUpdate(cValue,nCampo)
	method lCal_CriaLog(cPathSite,cLogName) 
	method lCal_WriteLog()
	method lCal_CloseLog()	
endclass
	
method New() class TKPICalcInd
	::NewKPI031()
return

method NewKPI031() class TKPICalcInd
	::cacheCalculo	:=	{}
	::cJobName		:=	alltrim(getJobProfString("INSTANCENAME", "SGI")+"_CalcInd.lck")	
	::NewObject() 
return

/**
Carrega o no requisitado.
@param cID 		- ID da entidade.
@param cRequest - Sequencia de caracteres com as instrucoes de execuxao
@return 		- No XML com os dados
*/
method oToXMLNode(cID,cRequest) class TKPICalcInd
	Local oXMLNode 		:=	TBIXMLNode():New(TAG_ENTITY)    
	Local oListaSco		:=	::oOwner():oGetTable("SCORECARD"):oToXMLList(.F., .T., STR0003)
	Local nStatus		:=	PARADO
	Local nHandle		:=  fCreate(::cJobName,1)    

	If( nHandle == -1)
		nStatus	:=	EXECUTANDO
	Else
		nStatus	:=	PARADO
		unlockKpiCalc(::cJobName,nHandle)		
	EndIf

	If ! ( Empty( getGlbValue(GLOBAL_LOCK) ) )	
		nStatus	:=	FINALIZADO
	endif
	
	oXMLNode:oAddChild(TBIXMLNode():New("DATADE"	, date()))
	oXMLNode:oAddChild(TBIXMLNode():New("DATAATE"	, date()))	
	oXMLNode:oAddChild(TBIXMLNode():New("STATUS"	, nStatus))			
	oXMLNode:oAddChild(oListaSco)		                        
	
return oXMLNode
  
/**
*/
method nExecute(cID, cRequest)  class TKPICalcInd
	local aParms 		:= {}
	local aRet			:= {}
	local nHandle		:=	0	
	local cPathSite		:=	left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))
    local oProgress

	default cRequest 	:= ""	
	
	if(cRequest == "JOBSTOP")
		putGlbValue(GLOBAL_LOCK, "STOP")   
	else		
		nHandle	:=	fCreate(::cJobName,1)
		 
		//Verifica se o job esta em execucao.
		if(nHandle != -1) 
		
			unlockKpiCalc(::cJobName,nHandle)

			aadd(aParms,::cJobName)							//Nome do arquivo de job.
			aadd(aParms,::oOwner():cKpiPath())				//Kpi Path.
			aadd(aParms,::oOwner():foSecurity:fnUserCard)	//Usuario Logado.
			aadd(aParms,cRequest)							//Requisicao do java.
			aadd(aParms,cPathSite)							//Site do KPI.
			
			//Caso o calculo seja executado do form KpiCalcIndicador inicia ProgressBar
			aRet := aBIToken(cRequest,"|",.f.)    
			
			if (len(aRet) >= 4)
				if (alltrim(aRet[4]) == "True")  					
					oProgress := KPIProgressbar():New("indcalc_1")
					oProgress:setMessage(STR0024) 
					//STR0024 -> "Iniciando Processamento..."
					oProgress:setPercent(05)
				endif	
			endif  			
			StartJob("KpiCalc_Indicador", GetEnvServer(), .F., aParms) 
		else
			oKPICore:Log(STR0004 , KPI_LOG_SCRFILE)  //"Atenção. Existe um cálculo em andamento."
		endif
	endif
return KPI_ST_OK

/**
Calculo o valor do indicador     
@param dData Data para o calculo do indicador.
@return aVlrCalculado Valores calculados. 
@see Formula pronta. 1-Valor / 2-Meta / 3-Previa / 4-Peso
*/
method aCalc_Indicador(aData,cForm_Ind) class TKPICalcInd
	Local aItemFormula	:=	{}
	Local aItem			:=	{}
	Local aTmpVlrForm	:=	{}
	Local aVlrCalculado	:=	{"","","",""} 
	Local aPosInd		:=  {}	 	
	Local cFormula		:=	""
	Local cItemFormula	:=	"" 
	Local iItem			:=	0
	Local nCalculado	:=	0	
	Local nStatus 		:= ESTAVEL_GRAY
	Local lPrivado 		:= ::oIndicador:lValue("ISPRIVATE")
	Local lConsolidador	:= ::oIndicador:lValue("ISCONSOLID")    
    
    Private aDataCalc	:=	aData
         
	Default cForm_Ind   := "" 
                    
	If (cForm_Ind == "")
		If (lPrivado) .And. !(Vazio(KPILimpaFormula(::oIndicador:cValue("FORMULA"))))
			//Atribui a expressão descriptografada a variável cFormula para ser utilizada no processamento.			
	  		cFormula:= "|(" + KPIUncripto( KPILimpaFormula(::oIndicador:cValue("FORMULA"))) + " |)" 
		Else
			//Atribui a expressão a variável cFormula para ser utilizada no processamento.
			cFormula:= "|(" +  ::oIndicador:cValue("FORMULA") + " |)"
		EndIf		
	else
		cFormula:= "|(" + cForm_Ind + "|)"
	endif
	
	aItemFormula:= aBIToken(cFormula, "|",.f.)

	for iItem := 1 to len(aItemFormula)
		cItemFormula := aItemFormula[iItem]
		//Verifica se e uma formula.
		if(at("I.", cItemFormula) != 0 .or. at("M.", cItemFormula) != 0)			
			//Verifica se o item da formula, e uma outra formula.
			aItem	:= ::aChkItemFormula(cItemFormula,aDataCalc, lConsolidador)

			if(len(aItem) > 0 .and. aItem[1] == FORMULA )                
                //Verifica no histórico se a fórmula do indicador já foi calculado.                    
				nCalculado	:=	::seekHistorico(aDataCalc)		 
			    //Se a fórmula não tiver sido calculada.			    
               	if(nCalculado == 0) 										 
					aPosInd :=	{IndexOrd(), recno(), ::oIndicador:cSqlFilter()}					
					//Realiza do cálculo através de chamada recursiva.
					aTmpVlrForm	:= ::aCalc_Indicador(aDataCalc,aItem[2]) 
					::oIndicador:faSavePos:= aPosInd
					::oIndicador:RestPos()
					//Atualizando as tabelas					
					::lUpdateValores(@aTmpVlrForm,aDataCalc)  
					//Verifica se o indicador é consolidador.
					If (lConsolidador)
						//Posiciono na planilha de valores para recuperar os dados do período calculado   
					    if(::oPlanilha:lSeek(2,{::oIndicador:cValue("ID"),aDataCalc[1],aDataCalc[2],aDataCalc[3]}))
							//Recupero o STATUS do indicador*/	      
							nStatus	:= ::oIndicador:nIndStatus(::oPlanilha)
							//Se o STATUS dor VERDE [META ATINGIDA] retorna o PESO do indicador.   
							aVlrCalculado[AC_VALOR] += iif(nStatus == STATUS_GREEN,::oIndicador:cValue("PESO"),"0")
							aVlrCalculado[AC_META]	+=  "0"
							aVlrCalculado[AC_PREVIA]+=  "0" 
						 Else
						 	aVlrCalculado[AC_VALOR]	+=  "0"
							aVlrCalculado[AC_META]	+=  "0"
							aVlrCalculado[AC_PREVIA]+=  "0" 
						 EndIf 
						   
					Else   
						//Indicador comum.
						aVlrCalculado[AC_VALOR]	+=  aTmpVlrForm[1]
						aVlrCalculado[AC_META]	+=  aTmpVlrForm[2]
						aVlrCalculado[AC_PREVIA]+=  aTmpVlrForm[3]   								
					EndIf				       
					//Salva o historico do indicador calculado.
					::addHistorico(aTmpVlrForm, aDataCalc) 			
				Else 
					//Verifica se o indicador é consolidador.
					If (lConsolidador) 					
						//Posiciono na planilha de valores.  
					    If(::oPlanilha:lSeek(2,{::oIndicador:cValue("ID"),aDataCalc[1],aDataCalc[2],aDataCalc[3]}))
							//Recupera o STATUS atual do indicador.
							nStatus	:= ::oIndicador:nIndStatus(::oPlanilha)
							//Se o STATUS for VERDE [META ATINGIDA] retorna o PESO do indicador.     
							aVlrCalculado[AC_VALOR] += iif(nStatus == STATUS_GREEN,::oIndicador:cValue("PESO"),"0")
							aVlrCalculado[AC_META]	+=  "0"
							aVlrCalculado[AC_PREVIA]+=  "0" 
						 Else
						 	aVlrCalculado[AC_VALOR]	+=  "0"
							aVlrCalculado[AC_META]	+=  "0"
							aVlrCalculado[AC_PREVIA]+=  "0" 
						 EndIf 
					Else  
						//Indicador comum.
						aVlrCalculado[AC_VALOR]	+=	::cacheCalculo[nCalculado,3]
						aVlrCalculado[AC_META]	+=	::cacheCalculo[nCalculado,4]
						aVlrCalculado[AC_PREVIA]+=	::cacheCalculo[nCalculado,5]     							
					EndIf  			
				Endif 								
				//Verifica se o indicador é consolidador.
		   		If(lConsolidador) 
					//Acumula o valor do PESO TOTAL.	 
					aVlrCalculado[AC_PESO] := cBIStr( nBIVal(aVlrCalculado[AC_PESO]) + nBIVal(aItem[3/*Peso*/]) )
				EndIf     
				
			ElseIf(len(aItem) >0 .and. aItem[1] == VALOR)
				aVlrCalculado[AC_VALOR]	+=  aItem[2]
				aVlrCalculado[AC_META]	+=  aItem[3]
				aVlrCalculado[AC_PREVIA]+=  aItem[4]
				
				//Verifica se o indicador é consolidador.
				If(lConsolidador) 
					//Acumula o valor do PESO TOTAL.	 
					aVlrCalculado[AC_PESO] := cBIStr( nBIVal(aVlrCalculado[AC_PESO]) + nBIVal(aItem[5/*Peso*/]) )
				EndIf
			Endif
		Else        
			//Concatena os operadores à fórmula.
			if(! empty(cItemFormula))
				aVlrCalculado[AC_VALOR]	+= cItemFormula
				aVlrCalculado[AC_META]	+= cItemFormula
				aVlrCalculado[AC_PREVIA]+= cItemFormula
			endif
		endif
	next iItem   
Return aVlrCalculado

/**
Checa o item da formuala.
Caso contenha outra formula, retorna o item da formula senao retorna o valor da formula.
@param cItemFormula
@param aDataCalc 
@param lConsolidador
*/			 
method aChkItemFormula(cItemFormula,aDataCalc, lConsolidador) class TKPICalcInd
	Local aFormula 		:= {}
	Local cID			:=	""
	//Tipo do Item (INDICADOR, METAFORMULA)
	Local cTipoItem		:=	""	
	Local lFound		:=	.f. 
	//Tabela (INDICADOR, METAFORMULA)
	Local oTable 	
	Local cTempFormula	:=	""
	Local cFormula		:= 	""     
	//Recebe o STATUS do indicador para cálculo do consolidador.
	Local nStatus 		:= ESTAVEL_GRAY
	Local dData  		 
	Local aPeriodo  	:= {}
	Local aDataDe  		:= {}
	Local aDataAte   	:= {}
	Local aDataBase		:= {}            

	//Verifica o tipo da formula (INDICADOR, METAFORMULA).
	If(at("I", cItemFormula) != 0)
		cTipoItem	:=	"INDICADOR" 
		cID			:=	strTran(cItemFormula, "I.", "")
		oTable 		:=	::oIndicador 	
	ElseIf(at("M", cItemFormula) != 0)
		cTipoItem	:=	"METAFORMULA" 
		cID			:=	strTran(cItemFormula, "M.", "")
		oTable 		:= ::oOwner():oGetTable(cTipoItem) 		
	Else
		Return .T.
	Endif
        
	lFound	:= oTable:lSeek(1,{cID})                                     
    
	if( lFound .and. !empty(oTable:cValue("FORMULA")))	    
	    //Verifica se é FORMULA ou METAFORMULA 
		If (cTipoItem == "INDICADOR")
			//Verifica se a formula do indicador foi exportada como proprietária.
			If(oTable:lValue("ISPRIVATE"))
		   		//Atribui a expressão descriptografada a variável cFormula para ser utilizada no processamento.			
				cFormula := KPIUnCripto( KPILimpaFormula(oTable:cValue("FORMULA")) ) 
			Else 
				//Atribui a expressão a variável cFormula para ser utilizada no processamento.
				cFormula := oTable:cValue("FORMULA")
			endIf    
		Else
			//Atribui a expressão a variável cFormula para ser utilizada no processamento.		
			cFormula := oTable:cValue("FORMULA")
		EndIf
				
		aadd(aFormula, FORMULA)
		//Formula
		aadd(aFormula, cFormula )         
		//Peso		
		aAdd(aFormula, oTable:cValue("PESO"))  
				   		
	elseif(cTipoItem == "INDICADOR")
		aadd(aFormula,VALOR)

		if(lFound)	 
			If ( oTable:nValue("FREQ") > ::freqCalculo )	
		   		dData 	 	:= ::oPlanilha:dPerToDate( nBIVal(aDataCalc[1]), nBIVal(aDataCalc[2]), nBIVal(aDataCalc[3]), ::freqCalculo )
				aPeriodo 	:= ::oPlanilha:aGetPeriodo(dData, ::freqCalculo)
			 	aDataDe 	:= ::oPlanilha:aDateConv(aPeriodo[1], oTable:nValue("FREQ")) 
				aDataAte    := ::oPlanilha:aDateConv(aPeriodo[2], oTable:nValue("FREQ"))   
			    					    
				//Verifica se o indicador é consolidador.
				If (lConsolidador)  				
					//Recupero o STATUS ACUMULADO do indicador	      
					nStatus	:= oIndicador:aGetIndValores( aPeriodo[2] , aPeriodo[1], aPeriodo[2] )[6]
					//Se o STATUS dor VERDE [META ATINGIDA] retorna o PESO do indicador.					    
					aAdd(aFormula, Iif( nStatus == STATUS_GREEN, oTable:cValue("PESO"), "0") ) 
					//Meta					 					
					aAdd(aFormula,"0")									
					//Prévia					
			   		aAdd(aFormula,"0")			   		
			   		//Peso
			   		aAdd(aFormula, oTable:cValue("PESO"))										
				Else     
				    //Verrifica se o tipo do acumulado é o último valor.
					If(oTable:cValue("ACUM_TIPO") == "2") 
						aDataBase := aClone(aDataAte)
					Else
						aDataBase := aClone(aDataDe)					
					EndIf
				
					//Real
					aadd(aFormula, cBIStr( oTable:calcIndAcum(  aDataBase, aDataAte, oTable:cValue("ACUM_TIPO") ) ) )
					//Meta
					aadd(aFormula, cBIStr( oTable:calcMetaAcum( aDataBase, aDataAte, oTable:cValue("ACUM_TIPO") ) ) )
					//Previa
					aadd(aFormula, cBIStr( oTable:calcPreviaAcum( aDataBase, aDataAte, oTable:cValue("ACUM_TIPO") ) ) )
				EndIf     

			ElseIf ( oTable:nValue("FREQ") < ::freqCalculo )						
				//Real
				aadd(aFormula,"0")
				//Meta
				aadd(aFormula,"0")
				//Previa
				aadd(aFormula,"0")     
				//Peso
				aadd(aFormula,"0")
				
				::lCal_WriteLog(STR0041 + ::nomeCalculo + STR0042 + oTable:cValue("NOME") + STR0043)	 	  				
				//STR0041 -> "Inconsistência no resultado do indicador: "  
				//STR0042 -> ". A fórmula utilizada aponta para o indicador "   
				//STR0043 -> " que possui frequência superior." 
			
			ElseIf ( ::oPlanilha:lSeek (2 , {cID, aDataCalc[1], aDataCalc[2], aDataCalc[3]} ) )				
				//Verifica se o indicador é consolidador.
				If (lConsolidador) 
				
					//Recupero o STATUS do indicador.	      
					nStatus	:= oIndicador:nIndStatus(::oPlanilha)
					//Se o STATUS dor VERDE [META ATINGIDA] retorna o PESO do indicador.					    
					aAdd(aFormula, Iif(nStatus == STATUS_GREEN , oTable:cValue("PESO") , "0")) 
					//Meta 					 					
					aAdd(aFormula,"0")									
					//Prévia					
			   		aAdd(aFormula,"0")			   		
			   		//Peso
			   		aAdd(aFormula, oTable:cValue("PESO"))			   											     
				Else   					
					//Real
					if(::oPlanilha:nValue("VALOR") < 0)
						cTempFormula := "("+alltrim(::oPlanilha:cValue("VALOR"))+")"
					else
						cTempFormula := alltrim(::oPlanilha:cValue("VALOR"))	
					endif  
					
					aadd(aFormula,cTempFormula)	
				   
					//Meta 					
					if(::oPlanilha:nValue("META") < 0)
						cTempFormula := "("+alltrim(::oPlanilha:cValue("META"))+")"
					else
						cTempFormula := alltrim(::oPlanilha:cValue("META"))
					endif	 
								
					aadd(aFormula,cTempFormula)				
					
					//Prévia					
					if(::oPlanilha:nValue("PREVIA") < 0)
						cTempFormula := "("+alltrim(::oPlanilha:cValue("PREVIA"))+")"
					else
						cTempFormula := alltrim(::oPlanilha:cValue("PREVIA"))
					endif
									
					aadd(aFormula,cTempFormula)   
			  	EndIf				  								
			Else   
				//Real
				aadd(aFormula,"0")
				//Meta
				aadd(aFormula,"0")
				//Previa
				aadd(aFormula,"0")
				//Peso
				aadd(aFormula,"0")	 
							
				//Adicionando zero a planilha
				::lUpdateValores(@{aFormula[2],aFormula[3],aFormula[4],aFormula[5]},aDataCalc)   	
			endif         
		else    
			//Real
			aadd(aFormula,"0")
			//Meta
			aadd(aFormula,"0")
			//Previa
			aadd(aFormula,"0")  
			//Peso
			aadd(aFormula,"0")	   
			
			::lCal_WriteLog(STR0041 + ::nomeCalculo + ". " + STR0005) 
			//STR0041 -> "Inconsistência no resultado do indicador: "  
			//STR0005 -> "A fórmula fez referência a um indicador que não foi encontrado."   
		endif                      
	endif
return aFormula
   
/**
Realiza a atualização da planilha de valores.
@param aVlrCalculado
@param aDataCalc 
*/
method lUpdateValores(aVlrCalculado,aDataCalc) class TKPICalcInd
	Local cInd_ID		:=	::oIndicador:cValue("ID")   
	Local cItenCalc		:=	::oIndicador:cValue("ITENS_CAL")
	Local cValor		:=	aVlrCalculado[1]
	Local cMeta			:=	aVlrCalculado[2]
	Local cPrevia		:=	aVlrCalculado[3] 
	Local cPeso			:=	aVlrCalculado[4]  		
	Local nValor		:=	0
	Local nMeta			:=	0
	Local nPrevia		:=	0	
	Local aFields		:=	{}
	Local bError		
	Local oScoreCard 	:= nil
	Local lConsolidador := ::oIndicador:lValue("ISCONSOLID")
	Local cLog			:= ""    
	
	Private lRet 		:=	.t.

	BEGIN SEQUENCE
		bError  :=	ErrorBlock({|e| conout("Erro calculando a fórmula.Indicador: " + cInd_ID ),lRet:= .F.})		
		//Realiza a macroexecução da fórmula parseada para obter o REAL.
		nValor := &(cValor)

        //Verifica se o indicador é consolidador.		
		If (lConsolidador)  	   
        	//Realiza o cálculo da porcentagem [Fórmula: ((PESO * 100)/ PESO TOTAL)].
        	nValor := ((nValor * 100) / nBIVal(cPeso))  
      	EndIf  
      	
      	//Realiza a macroexecução da fórmula parseada para obter a META.
		nMeta	:=	&(cMeta)
		//Realiza a macroexecução da fórmula parseada para obter a PREVIA.
		nPrevia	:=	&(cPrevia)    
	END SEQUENCE
	ErrorBlock(bError) 
    
	If(lRet)  
		// Verifica condições de gravação (append ou update)
		If(::oPlanilha:lSeek(2,{cInd_ID,aDataCalc[1],aDataCalc[2],aDataCalc[3]}))
			aFields := {}
			
			//Valor
			if ::lOpcUpdate(cItenCalc,"VALOR")	
				aadd(aFields,{"VALOR", nValor})
				aVlrCalculado[1] := "(" + alltrim(str(nValor)) + ")" 
			else
				aVlrCalculado[1] := "(" + ::oPlanilha:cValue("VALOR") + ")"
			endif 
			
			//Meta
			if ::lOpcUpdate(cItenCalc,"META")	
				aadd(aFields ,{"META",nMeta})
				aVlrCalculado[2] := "(" + alltrim(str(nMeta)) + ")" 
			else
				aVlrCalculado[2] := "(" + ::oPlanilha:cValue("META") + ")" 
			endif

			//Previa
			if ::lOpcUpdate(cItenCalc,"PREVIA")	
				aadd(aFields ,{"PREVIA",nPrevia})
				aVlrCalculado[3] := "(" + alltrim(str(nPrevia)) + ")"
			else
				aVlrCalculado[3] := "(" + ::oPlanilha:cValue("PREVIA") + ")"
			endif
			
			If( ! ::oPlanilha:lUpdate(aFields))
				if(::oPlanilha:nLastError()==DBERROR_UNIQUE)
					nStatus := KPI_ST_UNIQUE
					::lCal_WriteLog(STR0006) 
					//STR0006 -> "Erro de chave única. Não foi possível fazer a gravação do indicador "
				else
					nStatus := KPI_ST_INUSE
					::lCal_WriteLog(STR0007) 
					//STR0007 -> "O registro está em uso. Não foi possível fazer a gravação do indicador "
				endif  
			endif	
		else     		  
			aAdd(aFields, {"ID"			, ::oPlanilha:cMakeID()})
			aAdd(aFields, {"PARENTID"	, cInd_ID})	
			aAdd(aFields, {"DIA"		, aDataCalc[3]})	
			aAdd(aFields, {"MES"		, aDataCalc[2]})	
			aAdd(aFields, {"ANO"		, aDataCalc[1]})	
              
			//Valor
			If ( ::lOpcUpdate(cItenCalc,"VALOR") )
				aAdd(aFields, {"VALOR"		, nValor})
				aVlrCalculado[1] := "(" + alltrim(str(nValor)) + ")" 
			Else
				aVlrCalculado[1] := "(0)" 
			EndIf
			
			//Meta
			If ( ::lOpcUpdate(cItenCalc,"META") )
				aAdd(aFields, {"META"		, nMeta})
				aVlrCalculado[2] := "(" + alltrim(str(nMeta)) + ")" 
			Else
				aVlrCalculado[2] := "(0)" 	
			EndIf				
            
			//Previa
			If ( ::lOpcUpdate(cItenCalc,"PREVIA") )
				aAdd(aFields, {"PREVIA"		, nPrevia})	
				aVlrCalculado[3] := "(" + alltrim(str(nPrevia)) + ")"
			else
				aVlrCalculado[3] := "(0)" 
			endif				
			 
			//Insere os valores na planilha. 
			If(!::oPlanilha:lAppend(aFields))	
				if(::oPlanilha:nLastError()==DBERROR_UNIQUE)
					nStatus := KPI_ST_UNIQUE
				else
					nStatus := KPI_ST_INUSE
				endif  
			endif
		endif
	else
		oScoreCard := ::oOwner():oGetTable("SCORECARD")
		oScoreCard:lSeek(1,{::oIndicador:cValue("ID_SCOREC")})
		
		cLog := STR0021  
		//STR0021 -> "Erro calculando a fórmula do indicador: "
		cLog += ::oIndicador:cValue("NOME")
		cLog += "<br>" 
		cLog += oKPICore:getStrCustom():getStrSco()
		cLog += ": "
		cLog += oScoreCard:cValue("NOME")
		cLog += "<br>"
		cLog += STR0023 
		//STR0023 -> "Valor"
		cLog += cValor
		cLog += "<br>"
		cLog += STR0022 
		//STR0022 -> "Meta"
		cLog += " " 
		cLog += cMeta 
		cLog += "<br>"
		cLog += STR0028 
		//STR0028 -> "Previa"
		cLog += " "
		cLog += cPrevia
		
		::lCal_WriteLog(cLog)
	Endif	
Return lRet

/**
Verifica as opcoes de atualizacao  
@param cValue
@param cCampo  
*/
method lOpcUpdate(cValue,cCampo) class TKPICalcInd
	Local lUpdate := .f.

    do case
	    case alltrim(cValue) == "0"
			lUpdate := .t.
		case cCampo == "VALOR"	.and. "1" $ cValue 
			lUpdate := .t.			
		case cCampo == "META" 	.and. "2" $ cValue 
			lUpdate := .t.
		case cCampo == "PREVIA" .and. "3" $ cValue 
			lUpdate := .t.		
		otherwise
			lUpdate := .f.
	endcase		
return lUpdate

/**
Adiciona um indicador calculado no chache. 
@param aTmpVlrForm
@param aDataCalc 
*/
method addHistorico(aTmpVlrForm,aDataCalc) class TKPICalcInd
	Local aTmpIndicador := {}

	aadd(aTmpIndicador,::oIndicador:cValue("ID"))
	aadd(aTmpIndicador,aDataCalc[1]+aDataCalc[2]+aDataCalc[3])   
	aadd(aTmpIndicador,aTmpVlrForm[1])
	aadd(aTmpIndicador,aTmpVlrForm[2])
	aadd(aTmpIndicador,aTmpVlrForm[3])	

	aadd(::cacheCalculo,aTmpIndicador) 
return

/*
Verifica se o valor calculado de um indicador está em cache. 
@param aDataCalc
@return Posição do valor no array de cache. 
*/
method seekHistorico(aDataCalc) class TKPICalcInd
	Local cDataCalculo	:=	aDataCalc[1]+aDataCalc[2]+aDataCalc[3]
	Local cIndID		:=	::oIndicador:cValue("ID") 
Return aScan(::cacheCalculo, {|aCalculado|	aCalculado[1] == cIndID .and. aCalculado[2] == cDataCalculo})

/**
Cria o arquivo de log 
@param cPathSite 
@param cLogName 
*/
method lCal_CriaLog(cPathSite,cLogName) class TKPICalcInd
	cPathSite	:=	strtran(cPathSite,"\","/")
	::calcLog	:= 	TBIFileIO():New(oKpiCore:cKpiPath()+"logs\calcs\"+ cLogName + ".html")

	If ! ::calcLog:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oKPICore:Log(STR0008) 
		//STR0008 -> "Erro na criacao do arquivo de log dos cálculos."
	else
		::calcLog:nWriteLN('<html>')
		::calcLog:nWriteLN('<head>')
		::calcLog:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')     
		
		::calcLog:nWriteLN('<meta http-equiv="Pragma" content="no-cache">')
		::calcLog:nWriteLN('<meta http-equiv="expires" content="0">')
		
  		::calcLog:nWriteLN('<title>'+STR0018+'</title>')
		::calcLog:nWriteLN('<link href= "'+ cPathSite + 'imagens/report.css" rel="stylesheet" type="text/css">')
		::calcLog:nWriteLN('</head>')
		::calcLog:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
		::calcLog:nWriteLN('<table width="80%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::calcLog:nWriteLN('<tr>')
		::calcLog:nWriteLN('<td class="titulo"><div align="center">'+STR0018+ '</div></td>')
		::calcLog:nWriteLN('</tr>')
		::calcLog:nWriteLN('</table>')
		::calcLog:nWriteLN('<table width="80%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::calcLog:nWriteLN('<tr>')
		::calcLog:nWriteLN('<td width="21%" class="cabecalho_1">'+STR0019+'</td>')
		::calcLog:nWriteLN('<td width="79%" class="cabecalho_1">'+STR0020+'</td>')
		::calcLog:nWriteLN('</tr>')
	endif
return .T.

/**
Grava um evento no log.  
@param cMensagem
*/
method lCal_WriteLog(cMensagem) class TKPICalcInd
	  ::calcLog:nWriteLN('<tr>')
	  ::calcLog:nWriteLN('<td class="texto">'+dToC(date())+ " " + time()+ '</td>')
	  ::calcLog:nWriteLN('<td class="texto">'+cMensagem+'</td>')
	  ::calcLog:nWriteLN('</tr>')
return .T.

/**
Fecha o arquivo de log.
*/
method lCal_CloseLog() class TKPICalcInd
	::calcLog:nWriteLN('</table>')
	::calcLog:nWriteLN('<br>')
	::calcLog:nWriteLN('</body>')
	::calcLog:nWriteLN('</html>')
	::calcLog:lClose()
return .T.

/**
Envia email em caso de erro. 
@param cEndSite
@param cArqLog
@param oKPICore
*/
Static Function envLogMail(cEndSite,cArqLog,oKPICore)
	Local cTo			:=""
	Local cAssunto	:=""
	Local cCorpo		:=""
	Local cAnexos		:=""
	Local cCopia		:=""
	Local cServer		:=""
	Local cPorta		:=""
	Local cConta		:=""
	Local cAutUsuario	:=""
	Local cAutSenha 	:=""
	Local cFrom		:=""
	Local cCamArq   	:=""
	Local oConexao	:= Nil	
	Local oPessoas	:= Nil
	Local cProtocol	:= "0"

	If (oKPICore:oOltpController() <> Nil) .Or. (oKPICore:nDBOpen() >= 0)
		oConexao := oKPICore:oGetTable("SMTPCONF")
		oPessoas := oKPICore:oGetTable("USUARIO")
		
		If( oConexao:lSeek(1,{cBIStr(1)}) )
			cServer		:= AllTrim(oConexao:cValue("SERVIDOR"))
			cPorta			:= AllTrim(oConexao:cValue("PORTA"))
			cConta			:= AllTrim(oConexao:cValue("NOME"))
			cAutUsuario	:= AllTrim(oConexao:cValue("USUARIO"))
			cAutSenha		:= AllTrim(oConexao:cValue("SENHA"))
			cFrom			:= AllTrim(oConexao:cValue("NOME"))
			cProtocol		:= AllTrim(cBIStr(oConexao:nValue("PROTOCOLO")))
		EndIf  
		                                   
		//Filtra os administradores. 
		oPessoas:cSQLFilter("ADMIN = 'T'") 
		oPessoas:lFiltered(.t.)
		oPessoas:_First()	 
		//Monta a lista de destinatários. 
		while(!oPessoas:lEof())
	   		cTo	+= if(empty(cTo),"",",")+alltrim(oPessoas:cValue("EMAIL"))   
	   		oPessoas:_Next()
		enddo     
		oPessoas:cSQLFilter("") 	
	
		If len(alltrim(cArqLog)) > 4 
			cCamArq := cEndSite + "logs\calcs\" + cArqLog + ".html"
		endif
	
		cCopia	:= ""
		cAssunto:= STR0029 
		//STR0029 -> "SGI - Cálculo dos Indicadores"
		cAnexos	:= cCamArq    
		cCorpo  := STR0030 
		//STR0030 -> "Ocorreu um erro no cálculo dos indicadores, favor verificar o arquivo de log. " 
		oConexao:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo, cAssunto, cCorpo, cAnexos, cFrom, cCopia, "", cProtocol)			
	else
		oKPICore:Log("(logmail) " + STR0010, KPI_LOG_SCRFILE) 
		//STR0010 -> "Erro na abertura do banco de dados.(Job KpiCalc_Indicador)"
	endif
return

/**
Job do calculo dos indicadores.
@param aParms
*/
function KpiCalc_Indicador(aParms)
   	Local oProgress     := Nil  
 	Local oScoreCard	:= Nil  
	//Armazena os valores a utilizados para formar o período dinamicamente.
	Local aDinamico		:= {}
	Local aScorecard	:= {} 
	Local aRequest 		:= aBIToken(aParms[KPI_REQUEST],"|",.f.)	
	Local dDataDe		:= date()
	Local dDataAte		:= date()    
    Local nHandleFile 	:= fCreate(aParms[FILE_NAME],1)
	//Variação da ProgressBar
	Local nProgVar   	:= 0  
	//Numero de Indicadores a ser calculado  
	Local nRegInd		:= 0 
	//Posição atual do registro calculado.	
	Local nInt		 	:= 0 
	//Andamento em percentual do calculo.	 
	Local nAndCalc		:= 7 
	//Varialvel auxiliar verifica se atualiza ou nao a ProgressBar.	  
	Local nAuxVar		:= 1 
	//Verifica se o calculo esta sendo executado pelo form
	Local lExecProg		:= .F.	
	//Eviar log por email 
	Local lErro			:= .F.  
	Local cScoreID		:= "0"
	Local cLogName		:= "log_"  
	Local cScoreName	:= ""   
	Local cLog			:= "" 
	
	Private oCalculo	:= Nil
	Private oIndicador	:= Nil		
	Public oKPICore		:= Nil
    
	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on

	cLogName += alltrim(getJobProfString("INSTANCENAME", "SGI"))+"_"
	cLogName += strtran(dToc(date()),"/","") +"_"
	cLogName += strtran(time(),":","")

	oKPICore := TKPICore():New(aParms[KPI_PATH])
	
	if(nHandleFile != -1)
	   
		putGlbValue(GLOBAL_LOCK,"")

		ErrorBlock( {|oE| __KPIError(oE)})
	
		oKPICore:LogInit()
		oKPICore:Log(STR0009 , KPI_LOG_SCRFILE)
		//STR0009 -> "Iniciando cálculo dos indicadores."   

		//Seta o WorkStatus para ser apresentado na barra de ferramentas.
		putGlbValue(GLOBAL_RUN, "T")
		
		//Verifica se o calculo esta sendo executado do form KpiCalcIndicador.
		If (len(aRequest) >= 4)			
			If ( xBIConvTo("L", aRequest[4]) ) 
				sleep(2000)
				lExecProg := .T.
			Else               
				lExecProg := .F.
			Endif
		Endif
		
		oProgress := KPIProgressbar():New("indcalc_1")
		oProgress:setMessage(STR0025 )
		//STR0025 -> "Calculando..." 
		oProgress:setPercent(07)
	
		if(oKPICore:nDBOpen() < 0)			
			oKPICore:Log(STR0010, KPI_LOG_SCRFILE)  
			lErro := .T.
			oProgress:setStatus(PROGRESS_BAR_ERROR) 
	   		oProgress:setMessage(STR0010) 
			//STR0010 -> "Erro na abertura do banco de dados."
			envLogMail(aParms[KPI_PATH],cLogName,oKPICore) 
			putGlbValue(GLOBAL_RUN, "F")		   			
			
			Return
		else   
			If(valtype(aParms[KPI_USER]) == "C")
				aParms[KPI_USER] := val(aParms[KPI_USER])
			EndIf
			
			if(aParms[KPI_USER] != 0)
				oKPICore:lSetupCard(aParms[KPI_USER])
			endif				
		endif
		
		oCalculo			:=	oKPICore:oGetTable("CALC_INDICADOR")
		oIndicador			:=	oKPICore:oGetTable("INDICADOR")		
		oCalculo:oPlanilha	:=	oKPICore:oGetTable("PLANILHA")
		oCalculo:oIndicador	:=	oIndicador
		
		//Criando o arquivo de log.
		oCalculo:lCal_CriaLog(aParms[KPI_SITE],cLogName)

		//Seta a quantidade maxima de registros na ProgressBar.
		oIndicador:SetOrder(4)
		oIndicador:lSeek( 4, {"0"} )
		nRegInd  := oIndicador:nCountRoot()  
		
		If ( nRegInd > 0 )			
			nProgVar := 93/nRegInd
		else  		
			nProgVar := 0
		endif

    	//Preparando o processamento da requisicao;
		if(len(aRequest)>0)
			 
			//Recupera o ID do scorecard a ser calculado;
			cScoreID	:=	aRequest[1]      
			
			//Cálculo com período Dinâmico.
			If (aRequest[2] == SCHED_DINAMIC)
				//Recupera os valores a serem usados para montar o período dinâmicamente.
				aDinamico  	:= aBIToken(aRequest[3],"-",.f.)             
                //Decrementa o número de dias informado pelo usuário para montar a data de ínicio do cálculo.
				dDataDe		:= (Date() - nBIVal(aDinamico[1]))
                //Decrementa o número de dias informado pelo usuário para montar a data final do cálculo.
				dDataAte	:= (Date() + nBIVal(aDinamico[2]))

				oKPICore:Log(STR0039 + cBIStr(dDataDe) + STR0040 + cBIStr(dDataAte), KPI_LOG_SCRFILE)              
				//STR0039 -> "Período Dinâmico de "       
		   		//STR0040 -> " até "
			
			//Cálculo com período Fixo.
			Else          
			    //Recupera a data de ínicio do cálculo.
			    dDataDe		:= cToD(aRequest[2])
			    //Recupera a data final do cálculo.
				dDataAte	:= cToD(aRequest[3]) 
			EndIf

			If ( Alltrim( cScoreID ) == "0" )			
				cScoreName := STR0034   
				//STR0034 -> "(Todos)"
				aAdd(aScorecard, cScoreID )	
			else 
				oScoreCard 	:= oKPICore:oGetTable("SCORECARD")
				oScoreCard:lSeek( 1, { Padr( cScoreID, 10 ) } )
				cScoreName 	:= oScoreCard:cValue("NOME")       
				aScorecard 	:= oScoreCard:aGetAllChilds( cScoreID )  
				aAdd( aScorecard, cScoreID )					
			endif                     
			 
			cLog := STR0011  
			//STR0011 -> "Iniciado o cálculo dos indicadores."  
			cLog += "<br>"
			cLog += STR0035  
			//STR0035 ->"Período: de" __/__/__ "
			cLog += dToc(dDataDe) 
			cLog += STR0036     
			//STR0036 -> até " __/__/__
			cLog += dToc(dDataAte) 
			cLog += "<br>" 
			cLog += oKPICore:getStrCustom():getStrSco()
			cLog += ": " 
			cLog += cScoreName 

			oCalculo:lCal_WriteLog( cLog )	 
		else 		
			oCalculo:lCal_WriteLog(STR0012) 
			//STR0012 -> "Erro no recebimento dos parametros.(Job KpiCalc_Indicador"
			lErro := .t.
		endif

	    //Iniciando a chamada para execucao dos calculos.
		While(	!( oIndicador:lEof() ) .And. ( alltrim( oIndicador:cValue("ID_INDICA") ) == "0" ) )
			//Funcao recursiva para cÁlculo dos indicadores.
			KpiCalcIndicador(oIndicador:cValue("ID"), aScorecard ,dDataDe ,dDataAte)
			oIndicador:_Next() 
						
			//Atualiza a ProgressBar.
			nAndCalc += nProgVar
			oProgress:setPercent(round(nAndCalc,0))  
			
			//Interrompe o JOB em caso de erro. 
			If ! empty(getGlbValue(GLOBAL_LOCK))  
		   		lErro := .T.
				oProgress:setStatus(PROGRESS_BAR_ERROR) 
		   		oProgress:setMessage(STR0026) 
		   		//"Processamento interrompido."
		   		oCalculo:lCal_WriteLog(STR0013)  
				Exit
			EndIf
		End While

		//Atualizando o WorkStatus
		putGlbValue(GLOBAL_RUN, "F")
		putGlbValue(GLOBAL_UPDADE,"F")
		  	     
		if !( lErro )		
		    oProgress:setMessage(STR0027)
		    //STR0027 -> "Cálculo Finalizado"
			oProgress:setPercent(100)
			oProgress:endProgress()  
			sleep(1000)
		endif
        
		//Força a limpeza de memória
		oCalculo:cacheCalculo := {}

		//Ao terminar libera a thread
		if(! unlockKpiCalc(aParms[FILE_NAME],nHandleFile))			
			oCalculo:lCal_WriteLog(STR0014 ) 
			//STR0014 -> "Não foi possivel liberar a thread do calculo do indicador"
		endif		

		oCalculo:lCal_WriteLog(STR0015) 
		//STR0015 -> "Finalizado o cálculo dos indicadores."
		oCalculo:lCal_CloseLog() 
		oKPICore:Log(STR0016 , KPI_LOG_SCRFILE) 
		//STR0016 -> "Cálculo dos indicadores finalizado."
		oKPICore:ResetMakeID()	
	else
		oKPICore:Log(STR0017 , KPI_LOG_SCRFILE) 
		//STR0017 -> "Atenção. Já existe um cálculo em andamento." 
		lErro := .T.
	endif		
         
	//Limpa variáveis globais.
	putGlbValue(GLOBAL_LOCK, "") 
	putGlbValue(GLOBAL_RUN, "F")
	putGlbValue(GLOBAL_UPDADE, "F")   
	                          
	//Notifica o administrador em caso de erro. 
    If (lErro == .t.) .and. (lExecProg == .f.)	    
	    envLogMail(aParms[KPI_PATH],cLogName,oKPICore)
    EndIf    
Return .T.

/**
Realiza a chamada para o cálculo do indicados.
@param cIndID  Indicador a ser calculado. 
@param cScoreID Scorecard a ser calculado. 
@param dDataDe Período Inicial para o cálculo
@param dDataAte Período Final para o cálculo. 
@return .T.
*/
static function KpiCalcIndicador( cIndID, aScorecard, dDataDe, dDataAte )
	Local cParentID 	:= cIndID
	Local aSaveArea		:=	{}
	Local aSavePos		:=	{}
	Local aVlrAcumulado	:=	{}	
	Local aDataCalc		:=	{}	 
	Local dDataAtual	:=	date()	
	Local dProxData		:=	date()   
	Local lTemFormula	:= .F.
	Local lCalcular 	:= .F. 
	Local lTodos 		:= .F.
	
	dbSelectArea(oIndicador:cAlias())     
 	//Salva a posição da tabela. 
 	aSaveArea := oIndicador:savePos()	
	//Ordena por Parent.
	oIndicador:SetOrder(4)	
	 
	lTemFormula 	:= ! Empty( oIndicador:cValue("FORMULA") ) 
	lCalcular		:= ! aScan(aScorecard,{|x| x == oIndicador:cValue("ID_SCOREC")}) == 0  
	lTodos 			:= ! aScan(aScorecard,{|x| x == "0"}) == 0 
	
	//Verifica se o indicador será calculado. 
	if( lTemFormula .And. ( lCalcular .Or. lTodos ) ) 
	
		oKPICore:Log(STR0038 + oIndicador:cValue("NOME"), KPI_LOG_SCRFILE)   
		 //STR0038 -> Calculando o indicador: 
	   	dbSelectArea(oIndicador:cAlias())
		//Salva a posição da tabela.
	   	aSavePos := oIndicador:savePos()

		dDataAtual		:=	dDataDe
		dProxData		:=	dDataDe
		
		Do While ( dDataAtual >= dDataDe ) .and. ( dDataAtual <= dDataAte )		
			If ( dProxData == dDataAtual  .or. ! oIndicador:lCompDataFreq(oIndicador:nValue("FREQ"), dDataAtual, dProxData) )
				aDataCalc				:=	oCalculo:oPlanilha:aDateConv(dProxData,oIndicador:nValue("FREQ"))
				oCalculo:freqCalculo 	:= oIndicador:nValue("FREQ") 
				oCalculo:nomeCalculo 	:= oIndicador:cValue("NOME") 
				aVlrAcumulado			:= oCalculo:aCalc_Indicador(aDataCalc)
		        //Restaura a posição da tabela.	
				oIndicador:RestPos(aSavePos)
				
				If ( len(aVlrAcumulado) > 0 ) 
					oCalculo:lUpdateValores(aVlrAcumulado,aDataCalc)
				Endif					
				
				aVlrAcumulado := {}
			Endif

			dDataAtual		:= dProxData
			dProxData		:= dDataAtual + 1
		End While					
	Endif
    
 	//Calcula os indicadores filhos. 
	if oIndicador:lSeek(4,{cParentID}) 
		while(oIndicador:cValue("ID_INDICA") == padr(cParentID,10) .and. ! oIndicador:lEof())
			KpiCalcIndicador(oIndicador:cValue("ID"), aScorecard, dDataDe, dDataAte)
			oIndicador:_Next()
		enddo		
	endif
	//Restaura a posição da tabela.
	oIndicador:RestPos(aSaveArea)    
Return .T.

/**       
Fecha o arquivo de lock do cálculo de indicadores. 
@param cFileName
@param nHandle 
*/
Static Function unlockKpiCalc(cFileName,nHandle)
	Local lUnLock := .t.

    If ! fClose(nHandle) 
		lUnLock := .f.
	EndIf
Return lUnLock