/* ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : TKPIGraphInd.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 20.10.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------*/
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI060_GraphInd.ch"
/*--------------------------------------------------------------------------------------
@entity Graph
Monta os itens para demonstracao do Graph.
@table KPI060
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "GRAPH"
#define TAG_GROUP  "GRAPHS"
#define TEXT_ENTITY STR0001/*//"Grafico do Indicador"*/
#define TEXT_GROUP  STR0002/*//"Grafico dos Indicadores"*/    

class TKPI060 from TBITable
	data aIndStatus//Status dos indicadores para calculo do status do scorecard.   
	data aGraphProp//Proriedades do grafico

	method New() constructor
	method NewKPI060()

	// registro atual
	method oToXMLNode(cID,cRequest)
	method lPutUserConfig(cInd_ID,oXMLNode,cUsuID)
	method nUpdFromXML(oXML,cPath,cUserID,nItemAtu) 

	method lAddIndicador(cIdInd,aPeriodo,oXMLColunas)//Atencao! oXMLColunas deve ser passado por referencia.
	method cSetLabelX(nFrequencia,oPlaValor)//Prepara o labelX
endclass
	
method New() class TKPI060
	::NewKPI060()
return

method NewKPI060() class TKPI060
	::NewObject() 
	::aIndStatus	:= {}
	
	::NewTable("SGI060")
	::cEntity(TAG_ENTITY)

	// Campos
	::addField(TBIField():New("ID"			,"C",010))
	::addField(TBIField():New("USUARIO"		,"C",010))
	::addField(TBIField():New("INDICADOR"	,"C",010))
	::addField(TBIField():New("PROP_NOME"	,"C",30))
	::addField(TBIField():New("PROP_VALOR"	,"C",50))	

	// Indices
	::addIndex(TBIIndex():New("SGI060I01",	{"ID"},.t.))
	::addIndex(TBIIndex():New("SGI060I02",	{"USUARIO","INDICADOR","PROP_NOME"},.t.))

	//Arrays
	::aGraphProp := {;	
						{"TIPO"				,"2"}	,;//Tipo do grafico.
						{"POS_LEGENDA"		,"0"}	,;//Posicao da legenda
						{"COR_FUNDO"		,"16777215"},;//Cor de fundo.
						{"LINHA_COLUNA"		,"F"}	,;//Mostra linha X coluna invertido?
						{"LEGENDA_X"		,"T"}	,;//Mostra a legenda do eixo X.
						{"LEGENDA_Y"		,"T"}	,;//Mostra a legenda do eixo Y.
						{"MES_EXTENSO"		,"F"}	,;//Mostra o nome do mes por extenso?
						{"MOSTRA_VALOR"		,"T"}	,;//Mostra a valor
						{"MOSTRA_META"		,"T"}	,;//Mostra a meta
						{"MOSTRA_PREVIA"	,"F"}	,;//Mostra a previa
						{"MOSTRA_VALOR_ACUM"	,"F"}	,;//Mostra o valor acumulado
						{"MOSTRA_META_ACUM"	,"F"}	,;//Mostra a meta acumulada
						{"MOSTRA_PREVIA_ACUM","F"}	,;//Mostra a previa acumulada
						{"MOSTRA_DIFERENCA"	,"F"}	,;//Mostra a diferenca
						{"COR_VALOR"		,"-2434342" }	,;//Cor do valor
						{"COR_META"			,"-16777069"}	,;//Cor da meta
						{"COR_PREVIA"		,"-7618666" }	,;//Cor da previa
						{"COR_VALOR_ACUM"		,"-2434342" }	,;//Cor do valor acumulado
						{"COR_META_ACUM"		,"-16777069"}	,;//Cor da meta acumulada
						{"COR_PREVIA_ACUM"	,"-7618666" }	,;//Cor da previa acumulada
						{"COR_DIFERENCA"	,"-7618666" }	,;//Cor da diferenca
						{"TIPO_VALOR"		,"5"}	,;//Tipo da serie do valor
						{"TIPO_META"		,"0"}	,;//Tipo da serie da meta
						{"TIPO_PREVIA"		,"0"}	,;//Tipo da serie previa
						{"TIPO_VALOR_ACUM"	,"5"}	,;//Tipo da serie do valor acumulado
						{"TIPO_META_ACUM"		,"0"}	,;//Tipo da serie da meta acumulada
						{"TIPO_PREVIA_ACUM"	,"0"}	,;//Tipo da serie previa
						{"TIPO_DIFERENCA"	,"0"}	,;//Tipo da serie diferenca
						{"POS_SPLIT_VERT"	,"300"}	,;//Posicao do split vertical.
						{"GRAPH_DATADE"		,""}	,;//Posicao do split vertical.
						{"GRAPH_DATAATE"	,""}	,;//Posicao do split vertical.
						{"ZOOM"				,"100"}	,;//Valor do Zoom
						{"MOSTRA_ACUMULADO"	,"F"}	,;//Mostra a coluna de acumulados    
						{"LEGENDA_VAL"		,"F"} 	; //Mostra a legenda de valores.
					}                         
	
return

/*-------------------------------------------------------------------------------------
Carrega o no requisitado.
@param cID 		- ID da entidade.
@param cRequest - Sequencia de caracteres com as instrucoes de execuxao
@return 		- No XML com os dados
--------------------------------------------------------------------------------------*/
method oToXMLNode(cIdInd,cRequest) class TKPI060
	local cUsuID		:=	::oOwner():foSecurity:oLoggedUser():cValue("ID")
	local oIndicador	:= 	::oOwner():oGetTable("INDICADOR")	
	local oUnidade		:= 	::oOwner():oGetTable("UNIDADE")	
	local oXMLNode 		:= 	TBIXMLNode():New(TAG_ENTITY)
	local aRequest 		:= 	aBIToken(cRequest, "|", .f.)	
	local nItem			:= 	0	
	local aPeriodo		:= 	{}//[1]-DataDe [2]-DataAte
	local lValorPrevio	:= 	.f.
	local oParametro	:= 	::oOwner():oGetTable("PARAMETRO")
	local oAttrib			:= 	nil
	local oXMLColunas		:=	nil
	local lMesExtenso 	:=  .f.
	local lLoadDefault 	:=  .f.
	local nPosData			:=	0
	local cTempData		:=  ""   
	local cUnMedida		:= ""
	local nCol				:= 0
	
	default cRequest 		:=  ""	

	if(oParametro:lSeek(1, {"VALOR_PREVIO"}))
		lValorPrevio := oParametro:lValue("DADO")
	endif

	oAttrib := TBIXMLAttrib():New()
	//Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)

	//Periodo
	oAttrib:lSet("TAG00"+cBIStr(nCol), "LABELX")
	oAttrib:lSet("CAB00"+cBIStr(nCol), STR0012) //"Período"
	oAttrib:lSet("CLA00"+cBIStr(nCol), KPI_STRING)

	//Valor
	nCol++
	oAttrib:lSet("TAG00"+cBIStr(nCol), "VALOR")
	oAttrib:lSet("CAB00"+cBIStr(nCol), ::oOwner():getStrCustom():getStrReal()) //"Valor"
	oAttrib:lSet("CLA00"+cBIStr(nCol), KPI_FLOAT)
	
	//Meta
	nCol++
	oAttrib:lSet("TAG00"+cBIStr(nCol), "META")
	oAttrib:lSet("CAB00"+cBIStr(nCol), ::oOwner():getStrCustom():getStrMeta()) //"Meta"
	oAttrib:lSet("CLA00"+cBIStr(nCol), KPI_FLOAT)

	//Diferenca
	nCol++
	oAttrib:lSet("TAG00"+cBIStr(nCol), "DIFERENCA")
	oAttrib:lSet("CAB00"+cBIStr(nCol), STR0015) //"Diferença"
	oAttrib:lSet("CLA00"+cBIStr(nCol), KPI_FLOAT)
          
	if(lValorPrevio)      
	    //Prévia
		nCol++
		oAttrib:lSet("TAG00"+cBIStr(nCol), "PREVIA")
		oAttrib:lSet("CAB00"+cBIStr(nCol), ::oOwner():getStrCustom():getStrPrevia()) //"Previa"
		oAttrib:lSet("CLA00"+cBIStr(nCol), KPI_FLOAT)
	
		//Prévia Acumulada
		nCol++
		oAttrib:lSet("TAG00"+cBIStr(nCol), "PREVIA_ACUM")
		oAttrib:lSet("CAB00"+cBIStr(nCol), ::oOwner():getStrCustom():getStrPrevia() + STR0022) //"Previa Acumulada"
		oAttrib:lSet("CLA00"+cBIStr(nCol), KPI_FLOAT)
	endif
   
	//Valor Acumulado
	nCol++
	oAttrib:lSet("TAG00"+cBIStr(nCol), "VALOR_ACUM")
	oAttrib:lSet("CAB00"+cBIStr(nCol), ::oOwner():getStrCustom():getStrReal() + STR0023) //"Valor Acumulado"
	oAttrib:lSet("CLA00"+cBIStr(nCol), KPI_FLOAT)

   
	//Meta Acumulada
	nCol++
	oAttrib:lSet("TAG00"+cBIStr(nCol), "META_ACUM")
	oAttrib:lSet("CAB00"+cBIStr(nCol), ::oOwner():getStrCustom():getStrMeta() + STR0022) //"Meta Acumulada"
	oAttrib:lSet("CLA00"+cBIStr(nCol), KPI_FLOAT)
	
	//Verificando as opcao de requisicao	
	lLoadDefault := lower(aRequest[1]) == "true"
	for nItem := 2 to len(aRequest)
		do case
			case nItem == 2 
				cTempData := ctod(aRequest[nItem])
				aadd(aPeriodo,cTempData)
				nPosData :=	 ascan(::aGraphProp, {|x| , alltrim(x[1])==  "GRAPH_DATADE" })
				::aGraphProp[nPosData,2] := dToc(cTempData)
			case nItem == 3 
				cTempData := ctod(aRequest[nItem])
				aadd(aPeriodo,cTempData)
				nPosData :=	 ascan(::aGraphProp, {|x| , alltrim(x[1])==  "GRAPH_DATAATE" })
				::aGraphProp[nPosData,2] := dToc(cTempData)
			case nItem == 4 
				if(::lSeek(2, {cUsuID,cIdInd,"MES_EXTENSO"}).and. lLoadDefault)//Opcao e carregada so partir da gravacao do grafico
					lMesExtenso := alltrim(::cValue("PROP_VALOR")) == "T"
				elseif(!lLoadDefault)
					lMesExtenso := (aRequest[nItem] == "true")
				endif	
		endcase
	next nItem

	oXMLColunas	:= TBIXMLNode():New("COLUNAS",,oAttrib)
	oXMLNode:oAddChild(TBIXMLNode():New("VALOR_PREVIO"	, lValorPrevio))
	//Adicionando as linhas.	
	if (!(alltrim(cIdInd)=="0") .and. oIndicador:lSeek(1,{cIdInd}))
		//Capturando unidade de medida
		if(oUnidade:lSeek(1, {oIndicador:cValue("UNIDADE")}))
			cUnMedida := oUnidade:cValue("NOME")
		endif
	
		::lAddIndicador(cIdInd,aPeriodo,@oXMLColunas,lMesExtenso)
		oXMLNode:oAddChild(TBIXMLNode():New("IND_NOME"	, STR0003 + oIndicador:cValue("NOME")))	//"Indicador: "
		oXMLNode:oAddChild(TBIXMLNode():New("INDICADOR"	, oIndicador:cValue("ID")))				//Id do Indicador
		oXMLNode:oAddChild(TBIXMLNode():New("ASCEND"	, oIndicador:lValue("ASCEND")))			//Quanto maior melhor
		oXMLNode:oAddChild(TBIXMLNode():New("UNMEDIDA"	, cUnMedida))					   		//Unidade de Medida
		// Insere o valor da definição de "Melhor na faixa" do indicador no XML
		oXMLNode:oAddChild(TBIXMLNode():New("MELHORF"	, oIndicador:lValue("MELHORF")))		//Melhor na Faixa
	endif		

	//Adicionando o no de planilha ao no principal.
	oXMLNode:oAddChild(oXMLColunas)

	::lPutUserConfig(oIndicador:cValue("ID"),@oXMLNode,cUsuID)	
return oXMLNode

/*-------------------------------------------------------------------------------------
Adiciona o indicador requisitado
@param cIdInd 			- ID da entidade.
@param oXMLPlanilha 	- XML onde sera adicionado, o indicador atual.
@param aPeriodo 		- Data de analise do indicador.
@return 				- status do processamento.
--------------------------------------------------------------------------------------*/
method lAddIndicador(cIdInd,aPeriodo,oXMLColunas,lMesExtenso)  class TKPI060
	local oPlaValor		:= ::oOwner():oGetTable("PLANILHA")
	local oIndicador	:= ::oOwner():oGetTable("INDICADOR")
	local nAlvoVerd		:=	oIndicador:nValue("ALVO1")
	local nAlvoVerm		:=	oIndicador:nValue("ALVO2")
	local aDataDe		:=	oPlaValor:aDateConv(aPeriodo[1], oIndicador:nValue("FREQ"))
	local aDataAte		:=	oPlaValor:aDateConv(aPeriodo[2], oIndicador:nValue("FREQ"))      
	local oParametro	:= ::oOwner():oGetTable("PARAMETRO")    
	local lMelhorF      := oIndicador:lValue("MELHORF")
	local aDataAcum		:= {}
	local nValor		:=	0	
	local nTotValor		:=	0
	local nMeta			:=	0	
	local nTotMeta	:=	0
	local nPrevia		:=	0
	local oNodeColuna
	local cSqlCMD		:=	""
	local nValorAcum 	:= 0
	local nMetaAcum  	:= 0
	local nPreviaAcum	:= 0
	Local nTotPrevia	:= 0	
	    
  	cSqlCMD +=	"PARENTID = '" + cIdInd + "' and "
 	cSqlCMD +=	cBISQLConcat({"ANO","MES","DIA"}) + " >= '" + aDataDe[01] 	+ aDataDe[02] 	+ aDataDe[03] 	+ "' and "	
   	cSqlCMD +=	cBISQLConcat({"ANO","MES","DIA"}) + " <= '" + aDataAte[01] 	+ aDataAte[02] 	+ aDataAte[03] 	+ "' and "	
	cSqlCMD +=	"D_E_L_E_T_ <> '*'"  
	
	oPlaValor:cSQLFilter(cSqlCMD) 
	
	oPlaValor:lFiltered(.t.)
	oPlaValor:_First()
	
	while(!oPlaValor:lEof())  
		oNodeColuna:= TBIXMLNode():New("COLUNA")//Cria um nova linha
		nValor 	:= oPlaValor:nValue("VALOR")
         
	/*      If(nAlvoVerd == 0 .and. nAlvoVerm == 0)
				nMeta	:=	oPlaValor:nValue("META")
			Else
				nMeta	:=	nAlvoVerd
			EndIf  */
            
		If oParametro:getValue("AVAL_META_SCORE") == "T"   
			nMeta := oPlaValor:nValue("META")
		Else
			If lMelhorF
				nMeta := oPlaValor:nValue("META")
			Else			
				If(nAlvoVerd == 0 .and. nAlvoVerm == 0)
					nMeta	:=	oPlaValor:nValue("META")
				Else
					nMeta	:=	nAlvoVerd
				EndIf 
			EndIf
		EndIf    
		
		nPrevia	:= oPlaValor:nValue("PREVIA")   
		
		aDataAcum 	:= {oPlaValor:cValue("ANO"),oPlaValor:cVAlue("MES"),oPlaValor:cVAlue("DIA")}  
		If lMelhorF
			nValorAcum 	:= oIndicador:calcIndAcum(  aDataDe, aDataAcum, oIndicador:cValue("ACUM_TIPO")) 
			nMetaAcum  	:= oIndicador:calcMetaAcum(  aDataDe, aDataAcum, oIndicador:cValue("ACUM_TIPO"))
		Else
			nValorAcum 	:= oIndicador:calcIndAcum(  aDataDe, aDataAcum, oIndicador:cValue("ACUM_TIPO")) 
			nMetaAcum  	:= oIndicador:calcMetaAcum(  aDataDe, aDataAcum, oIndicador:cValue("ACUM_TIPO"))
		EndIf		 
		nPreviaAcum := oIndicador:calcPreviaAcum(  aDataDe, aDataAcum, oIndicador:cValue("ACUM_TIPO")) 

		oNodeColuna:oAddChild(TBIXMLNode():New("INDICADOR"		,oIndicador:cValue("ID") ))  
		oNodeColuna:oAddChild(TBIXMLNode():New("ALVO"			,DToS( oPlaValor:dPerToDate(oPlaValor:nValue("ANO"), oPlaValor:nValue("MES"), oPlaValor:nValue("DIA"), oIndicador:nValue("FREQ") ) ) ) )  
		oNodeColuna:oAddChild(TBIXMLNode():New("ROWTYPE"		,1))//Valores
		oNodeColuna:oAddChild(TBIXMLNode():New("STATUS"			,oIndicador:nIndStatus(oPlaValor)))
		oNodeColuna:oAddChild(TBIXMLNode():New("DECIMAIS"		,oIndicador:nValue("DECIMAIS")))
    	oNodeColuna:oAddChild(TBIXMLNode():New("VALOR"			,round(nValor, oIndicador:nValue("DECIMAIS")) ))
		oNodeColuna:oAddChild(TBIXMLNode():New("META"			,round(nMeta, oIndicador:nValue("DECIMAIS")) ))
		oNodeColuna:oAddChild(TBIXMLNode():New("PREVIA"			,round(nPrevia, oIndicador:nValue("DECIMAIS")) ))                                                    
		oNodeColuna:oAddChild(TBIXMLNode():New("DIFERENCA" 		,round(nValor - nMeta, oIndicador:nValue("DECIMAIS")) ))
		oNodeColuna:oAddChild(TBIXMLNode():New("LABELX"			,::cSetLabelX(oIndicador:nValue("FREQ"),oPlaValor,lMesExtenso)))
	 	oNodeColuna:oAddChild(TBIXMLNode():New("VALOR_ACUM"		,round(nValorAcum, oIndicador:nValue("DECIMAIS"))))
		oNodeColuna:oAddChild(TBIXMLNode():New("META_ACUM"		,round(nMetaAcum, oIndicador:nValue("DECIMAIS"))))
		oNodeColuna:oAddChild(TBIXMLNode():New("PREVIA_ACUM"	,round(nPreviaAcum, oIndicador:nValue("DECIMAIS"))))
		
		oPlaValor:_Next()
		oXMLColunas:oAddChild(oNodeColuna)//Adicina a linha ao no principal
	end while

	oPlaValor:cSQLFilter("")   
		                   
	//Acumulando o valor total.	
	nTotValor 	:= oIndicador:calcIndAcum(aDataDe,aDataAte,oIndicador:cValue("ACUM_TIPO")) 
	nTotMeta  	:= oIndicador:calcMetaAcum(aDataDe,aDataAte,oIndicador:cValue("ACUM_TIPO"))
	nTotPrevia 	:= oIndicador:calcPreviaAcum(aDataDe,aDataAte,oIndicador:cValue("ACUM_TIPO"))
	
	oNodeColuna:= TBIXMLNode():New("COLUNA")//Cria uma nova linha
    
	oNodeColuna:oAddChild(TBIXMLNode():New("ROWTYPE"		,2))//Acumulado
	oNodeColuna:oAddChild(TBIXMLNode():New("VALOR"			,nTotValor))		
	oNodeColuna:oAddChild(TBIXMLNode():New("META"			,nTotMeta))
	oNodeColuna:oAddChild(TBIXMLNode():New("PREVIA"			,nTotPrevia))
	oNodeColuna:oAddChild(TBIXMLNode():New("DIFERENCA"		,nTotValor - nTotMeta))			
	oNodeColuna:oAddChild(TBIXMLNode():New("LABELX"			,STR0004)) //"Acumulado"
	oNodeColuna:oAddChild(TBIXMLNode():New("STATUS"			, 0))
	oNodeColuna:oAddChild(TBIXMLNode():New("DECIMAIS"		,oIndicador:nValue("DECIMAIS")))
 	oNodeColuna:oAddChild(TBIXMLNode():New("VALOR_ACUM"		,round(nValorAcum, oIndicador:nValue("DECIMAIS"))))
	oNodeColuna:oAddChild(TBIXMLNode():New("META_ACUM"		,round(nMetaAcum, oIndicador:nValue("DECIMAIS"))))
	oNodeColuna:oAddChild(TBIXMLNode():New("PREVIA_ACUM"	,round(nPreviaAcum, oIndicador:nValue("DECIMAIS"))))

	oXMLColunas:oAddChild(oNodeColuna)
return .t.

method cSetLabelX(nFrequencia,oPlaValor,lMesExtenso)  class TKPI060
	local cLabelX := ""
	local dData		

	do case
		case nFrequencia == KPI_FREQ_DIARIA
			dData	:= cTod(oPlaValor:cValue("DIA")+ "/" + oPlaValor:cValue("MES") + "/"+ oPlaValor:cValue("ANO"))
			cLabelX := dtoC(dData)
		case nFrequencia == KPI_FREQ_SEMANAL//Semana
			cLabelX := oPlaValor:cValue("MES") + STR0005+ oPlaValor:cValue("ANO") //" semana de "
		case nFrequencia == KPI_FREQ_QUINZENAL//Quinzena
			cLabelX	:= oPlaValor:cValue("DIA")+ STR0006 + oPlaValor:cValue("MES") + STR0007+ oPlaValor:cValue("ANO") //" quinzena de "###" de "
		case nFrequencia == KPI_FREQ_MENSAL//Meses
			if(lMesExtenso)
				cLabelX	:=	MesExtenso(oPlaValor:nValue("MES")) + STR0007+ oPlaValor:cValue("ANO") //" de "
			else
				cLabelX	:=	strzero(oPlaValor:nValue("MES"),2) + "/" + oPlaValor:cValue("ANO") //
			endif				
		case nFrequencia == KPI_FREQ_BIMESTRAL//Bimestre
			cLabelX := oPlaValor:cValue("MES") + STR0008+ oPlaValor:cValue("ANO") //" bimestre de "
		case nFrequencia == KPI_FREQ_TRIMESTRAL//Trimestre
			cLabelX := oPlaValor:cValue("MES") + STR0009+ oPlaValor:cValue("ANO") //" trimestre de "
		case nFrequencia == KPI_FREQ_QUADRIMESTRAL//Quadrimestre
			cLabelX := oPlaValor:cValue("MES") + STR0010+ oPlaValor:cValue("ANO") //" quadrimestre de "
		case nFrequencia == KPI_FREQ_SEMESTRAL//Semestre
			cLabelX := oPlaValor:cValue("MES") + STR0011+ oPlaValor:cValue("ANO") //" semestre de "
		case nFrequencia == KPI_FREQ_ANUAL//Ano
			cLabelX := oPlaValor:cValue("ANO")
	endcase
return cLabelX	

method lPutUserConfig(cInd_ID,oXMLNode,cUsuID) class TKPI060
	local nIndProp 		:=	0
	local nPropFound	:=	0
	local cValorProp	:=	""	
	local aProp			:=	{}
	
	private cPropName	:=	""
	
	if ::lSoftSeek(2,{cUsuID,cInd_ID})
		//Adiciona todas as propriedades que estao gravadas no banco.
		while !::lEof() .and. alltrim(::cValue("INDICADOR")) == alltrim(cInd_ID);
			.and. alltrim(::cValue("USUARIO")) == alltrim(cUsuID)
			
			oXMLNode:oAddChild(TBIXMLNode():New(alltrim(::cValue("PROP_NOME")),alltrim(::cValue("PROP_VALOR"))))		
			
			::_next()			
		end 
	endif
		
	//Verifica se todas as propriedades foram adicionas, caso contrario adiciona a default.
	aProp := oXMLNode:FACHILDREN
	
	for nIndProp := 1 to len(::aGraphProp)
		cPropName	:=	::aGraphProp[nIndProp,1]		
		nPropFound	:=	ascan( aProp, {|x| alltrim(x:FCTAGNAME) == alltrim(cPropName)})
		
		if(nPropFound == 0)
			//Retorna a propriedade padrao quando nao a encontra no banco
			cValorProp	:= alltrim(::aGraphProp[nIndProp,2])
			oXMLNode:oAddChild(TBIXMLNode():New(::aGraphProp[nIndProp,1],cValorProp))
		endif
	next nIndProp
	
	oXMLNode:oAddChild(TBIXMLNode():New("ID","0"))
return .t.

//Atualizacao 
method nUpdFromXML(oXML,cPath) class TKPI060
	local cUsuID		:=	::oOwner():foSecurity:oLoggedUser():cValue("ID")
	local nStatus 		:= 	KPI_ST_OK
	local nInd  		:=	0
	local nProp			:=	0
	local nPosID		:=	0     
	local cInd_ID		:=	""

	private oXMLInput 	:= oXML
	
	aFields := ::xRecord(RF_ARRAY)
	nPosID	:= ascan(aFields,{|x| x[1] == "ID"})	

	for nProp := 1 to len(::aGraphProp)
		// Extrai valores do XML                     
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1] == "USUARIO")
				aFields[nInd][2] := cUsuID                                         	
			elseif(aFields[nInd][1] == "PROP_NOME" )
				aFields[nInd][2] := ::aGraphProp[nProp,1]
			elseif(aFields[nInd][1] == "PROP_VALOR")
				if(empty(cPath))
					aFields[nInd][2] :=	 &("oXMLInput:_" + ::aGraphProp[nProp,1] + ":TEXT")
				else
					aFields[nInd][2] :=	 &("oXMLInput:"+cPath+":_" + ::aGraphProp[nProp,1] + ":TEXT")
				endif
			elseif(	aFields[nInd][1] == "ID" .or. aFields[nInd][1] == "PARENTID")
				//Campos acertados posteriormente.
			else
				cType := ::aFields(aFields[nInd][1]):cType()
				if(empty(cPath))					
					aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))
				else
					aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
				endif						
				
				if(aFields[nInd][1]=="INDICADOR") 
					cInd_ID := padr(aFields[nInd][2],10)
				endif					
			endif	
		next nInd

		//Verificar se a propriedade ja existe.
		if(!::lSeek(2, {cUsuID,cInd_ID,::aGraphProp[nProp,1]}))
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
    next nProp
return nStatus

function _TKPIGraphInd()
return nil