#Include 'Protheus.ch'

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFDBHH 

Esta rotina tem como objetivo a gera��o dos documentos fiscais de servi�o da
DES - Belo Horizonte MG


@Author joao.spieker
@Since 19/09/2017
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFDBHH(cCNPJ as char, cInsc as char)

	Local cTxtSys    as char
	Local nHandle    as Numeric	
	Local cStrTxt    as char
	Local cIdentific as char
	Local cReg       as char 
	Local cCPFCNPJ   as char
	Local cInscMunic as char
	Local cVrsSys 	 as char


    cIdentific := "H"
	cReg	   := "DBH_H"
	cInscMunic := cInsc	
	cVrsSys	   := "VERS�O300"
	cCPFCNPJ   := cCNPJ
	cTxtSys    := CriaTrab( , .F. ) + ".txt"
	nHandle    := MsFCreate( cTxtSys )	
	   
	 Begin Sequence 
			
			//Carrega a var�avel cStrTxt para gera��o do arquivo 
			cStrTxt := Alltrim(cIdentific)   + "|" 	// Indicador do Tipo do Layout
			cStrTxt += Alltrim(cInscMunic)	 + "|"	// Inscri��o Municipal da empresa
			cStrTxt += Alltrim(cCPFCNPJ)	 + "|"	// CNPJ/CPF da empresa
			cStrTxt += Alltrim(cVrsSys)  		  	// Vers�o do Sistema
								
			cStrTxt += CRLF 
	
    	    WrtStrTxt( nHandle, cStrTxt )
	
    	    GerTxtDBH( nHandle, cTxtSys, cReg )
	 
    	    Recover
	
    	    lFound := .F.
    	    
 	End Sequence	
					
Return
