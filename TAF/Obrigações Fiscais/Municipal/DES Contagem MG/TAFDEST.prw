#Include 'Protheus.ch'

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFDESNI

Esta rotina tem como objetivo a gera��o das informa��es em rela��o ao
registro 'T' fiscais de servi�o da DES - Contagem MG

@Param
 aTotais - Informa��es da Nota
 
@Author gustavo.pereira
@Since 07/08/2017
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFDEST(aTotais)

	Local cTxtSys    as char
	Local nHandle    as Numeric
	
    Local cReg       := "DES_T"
    
	Local cLayout    as char
	Local cIdentific as char
	Local nQtdNotas  as Numeric
	Local nQtdNFS    as Numeric
	Local nSomaNF    as Numeric
	Local nSomaImp1  as Numeric // Soma do imposto das notas ou recibos emitidos
	Local nSomaImp2  as Numeric // Soma do imposto das notas ou recibos emitidos que foi retido por outras empresas
	Local nQtdRegN   as Numeric
	Local nSomVlBrt  as Numeric 
	Local nSomaImp3  as Numeric	
	
	cAliasImp  := GetNextAlias()	
	cLayout    := "3"
	cIdentific := "T"
	nQtdNotas  := aTotais[1]
	nQtdNFS    := aTotais[2]
	nSomaNF    := aTotais[3]
	nSomaImp1  := aTotais[4]
	nSomaImp2  := aTotais[5]
	nQtdRegN   := aTotais[6]	
	nSomVlBrt  := aTotais[7]		
	nSomaImp3  := aTotais[8]		
	
	cTxtSys    := CriaTrab( , .F. ) + ".txt"
	nHandle    := MsFCreate( cTxtSys )			
			
	Begin Sequence		
	
			//Carrega a var�avel cStrTxt para gera��o do registro N 
			cStrTxt := Alltrim("'" + cLayout     + "'") + ","	// Indicador do Tipo do Layout
			cStrTxt += Alltrim("'" + cIdentific	 + "'")	+ ","	// Identifica��o pro Registros
			cStrTxt += cValToChar(nQtdNotas)   		    + ","	// Quantidade total de notas no arquivo
			cStrTxt += cValToChar(nQtdNFS)               	+ ","	// Quantidade de notas (documento de sa�da) 
			cStrTxt += cValToChar(nSomaNF)             	+ ","	// Somat�rio do valor bruto das notas de sa�da
			cStrTxt += cValToChar(nSomaImp1)       		+ ","	// Somat�rio do valor do impostoso de Doc de sa�da
			cStrTxt += cValToChar(nSomaImp2)       		+ ","	// Somat�rio do valor dos impostos de doc de sa�da retido por outras empresas			
			cStrTxt += cValToChar(nQtdRegN)               	+ ","	// Quantidade total de documentos de entrada
			cStrTxt += cValToChar(nSomVlBrt)              	+ ","	// Somat�rio do valor bruto das notas de entrada
			cStrTxt += cValToChar(nSomaImp3)              	     	// Somat�rio do valor do imposto de doc de entrada	
			
			cStrTxt += CRLF 
	
    	    WrtStrTxt( nHandle, cStrTxt )
	
    	    GerTxtDES( nHandle, cTxtSys, cReg )
	 
    	    Recover
	
    	    lFound := .F.
    	    
	End Sequence
	
Return 



