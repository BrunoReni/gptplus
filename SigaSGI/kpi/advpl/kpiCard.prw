// ######################################################################################
// Projeto: KPI
// Modulo : Core
// Fonte  : KPICard.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 24.10.05 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"

#DEFINE VERDE 'rgb(0,255,0)'
#DEFINE AMARELO 'rgb(255,255,0)'
#DEFINE VERMELHO 'rgb(255,0,0)'


/*--------------------------------------------------------------------------------------
@class TKPICard
Cards - objeto eh um cartao de indicadores completo coletado e comparado.
Deve retornar de operacao makecard de alguma tabela boa para tal.
Não possui tabela propria. (Objeto gerado em tempo de execuçao)
--------------------------------------------------------------------------------------*/
class TKPICard from TBIObject

	// dados     
	data fnID
	data fnOrdem
	data fnCardX
	data fnCardY
	data flVisivel

	data fcNome
	data fcDescricao
	data fcEntity
	data fnEntID

	data fnVermelho
	data fnAmarelo
	data fnVerde
	data fnIndicador	
	data fnPercMeta
	data fnDifRealMeta
	
	data fdDataAlvo
	data fnTendencia

	data fcUnidade
	data fnInicial
	data fnFinal
	data fnCor
	data fnAtual
	data fnAnterior
	data fnAlvo

	data fcPercMeta

	data fnDecimais
	data fcTipoInd
	data fcInfluencia
	data fnAscend
	data fnValorPrevio
	data fnScorecard 
	data fnScoID   

	// construtores
	method New() constructor
	method NewKPICard()

	method oToXMLCard()
	Method oToDshWidget()
endclass
	
method New() class TKPICard
	::NewKPICard()
return
method NewKPICard() class TKPICard
	::fnId := 0
	::fnOrdem := 0
	::fnCardx := 0
	::fnCardy := 0
	::flVisivel := .f.
return

// oToXMLCard()
method oToXMLCard() class TKPICard
	local oXMLCard := TBIXMLNode():New("CARD")
	local lValorPrevio	:= .f.
	local oParametro	:= oKpiCore:oGetTable("PARAMETRO")
	if(oParametro:lSeek(1, {"VALOR_PREVIO"}))
		lValorPrevio := oParametro:lValue("DADO")
	endif

	oXMLCard:oAddChild(TBIXMLNode():New("ID", 			::fnID))
	oXMLCard:oAddChild(TBIXMLNode():New("ORDEM", 		::fnOrdem))

	oXMLCard:oAddChild(TBIXMLNode():New("CARDX", 		::fnCardx))	// Coord dashboard
	oXMLCard:oAddChild(TBIXMLNode():New("CARDY", 		::fnCardy))	// Coord dashboard
	oXMLCard:oAddChild(TBIXMLNode():New("VISIVEL", 		::flVisivel))// Visible dashboard

	oXMLCard:oAddChild(TBIXMLNode():New("NOME", 		::fcNome))
	oXMLCard:oAddChild(TBIXMLNode():New("DESCRICAO",	::fcDescricao))
	oXMLCard:oAddChild(TBIXMLNode():New("ENTITY", 		::fcEntity))
	oXMLCard:oAddChild(TBIXMLNode():New("ENTID", 		::fnEntID))

	oXMLCard:oAddChild(TBIXMLNode():New("PERCENTUAL", 	::fnPercMeta))
	oXMLCard:oAddChild(TBIXMLNode():New("DIF_REAL_META",::fnDifRealMeta))
	oXMLCard:oAddChild(TBIXMLNode():New("META", 		::fnAlvo))
	oXMLCard:oAddChild(TBIXMLNode():New("ATUAL", 		::fnAtual))
	
	if(lValorPrevio)
		oXMLCard:oAddChild(TBIXMLNode():New("PREVIA", 	::fnValorPrevio))
	endif
	oXMLCard:oAddChild(TBIXMLNode():New("TENDENCIA", 	::fnTendencia))
	oXMLCard:oAddChild(TBIXMLNode():New("INDICADOR", 	::fnIndicador))
	oXMLCard:oAddChild(TBIXMLNode():New("DECIMAIS", 	::fnDecimais))

	oXMLCard:oAddChild(TBIXMLNode():New("VERMELHO", 	::fnVermelho))
	oXMLCard:oAddChild(TBIXMLNode():New("AMARELO", 		::fnAmarelo))
	oXMLCard:oAddChild(TBIXMLNode():New("VERDE", 		::fnVerde))

	oXMLCard:oAddChild(TBIXMLNode():New("UNIDADE", 		::fcUnidade))
	oXMLCard:oAddChild(TBIXMLNode():New("INICIAL", 		::fnInicial))
	oXMLCard:oAddChild(TBIXMLNode():New("FINAL", 		::fnFinal))
	oXMLCard:oAddChild(TBIXMLNode():New("COR", 			::fnCor))
	oXMLCard:oAddChild(TBIXMLNode():New("ANTERIOR", 	::fnAnterior))

	oXMLCard:oAddChild(TBIXMLNode():New("TIPOIND", 		::fcTipoInd))
	oXMLCard:oAddChild(TBIXMLNode():New("INFLUENCIA", 	::fcInfluencia))
	oXMLCard:oAddChild(TBIXMLNode():New("ASCEND", 		::fnAscend ))   
	oXMLCard:oAddChild(TBIXMLNode():New("IDSCOREC", 	::fnScoID))
	oXMLCard:oAddChild(TBIXMLNode():New("NOMESCOREC", 	::fnScorecard ))    
	
return oXMLCard

/*Retorna o XML necessário para a montagem de um widget no dashboard.*/     
Method oToDshWidget() Class TKPICard 
	Local aRanges := {}
	Local aDados    
	/*Define a posicao do ponteiro.*/
	Local cPonteiro :=  cBIStr((100 * ::fnPercMeta) / 50)
	
	/*Define a posição da seta e o título do rodapé.*/
	aDados := {{ cPonteiro , ::fcNome }}
	
	/*Inicia a construção do XML.*/
	oXml := BIDshXmlGraphView():BIDshXmlGraphView()
	/*Define o título do gráfico.*/
	oXml:defineTitles( ::fcNome)
	/*Define links para drill down.*/
	oXml:defineLinks() 	
	
	/*Faixas de valores.*/    
	If (::fnAscend)  
		
		aAdd(aRanges, oXml:buildRangeProperties( 0, ::fnVermelho, VERMELHO))			
		If (::fnAmarelo > 0)
			aAdd(aRanges, oXml:buildRangeProperties( ::fnVermelho, (::fnVermelho + ::fnAmarelo), AMARELO) ) 
		EndIf 		
		aAdd(aRanges, oXml:buildRangeProperties( (::fnVermelho + ::fnAmarelo), 100, VERDE) )
	Else    
		
		aAdd(aRanges, oXml:buildRangeProperties( 0, ::fnVerde, VERDE) )  
		If (::fnAmarelo > 0)
			aAdd(aRanges, oXml:buildRangeProperties( ::fnVerde, (::fnVerde + ::fnAmarelo ), AMARELO) )  
		EndIf  		
		aAdd(aRanges, oXml:buildRangeProperties( (::fnVerde + ::fnAmarelo ), 100, VERMELHO) )	
	EndIf                
	
	/*Título do eixo.*/
	oXml:addAnalogGaugeAxis( (cPonteiro + " %") , aDados, "", "", "", aRanges, min, max)
		
Return oXml:getXml()


function _KPICard()
return nil

