#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSR100.CH"
//------------------------------------------------------------------------------------------//
//-------------------------Rotina que permite gerar um relat�rio do-------------------------//
//--------------------------------Reabastecimento de Picking--------------------------------//
//------------------------------------------------------------------------------------------//
Function WMSR100(aMsg)
	
	Local oReport	
	Private aMsgLog := aMsg
	Private nLin 	 := 1
		
	If FindFunction("TRepInUse") .And. TRepInUse() //Teste padr�o
		//Interface de impress�o
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf

Return

//-------------------------------------------------------------------------------------//
//-------------------------Define as propriedades do relat�rio-------------------------//
//-------------------------------------------------------------------------------------//
Static Function ReportDef()

	Local oReport, oSection
		
	oReport 	:= TReport():New('WMSR100',STR0001,'',{|oReport| ReportPrint(oReport)},'')
	oReport:HideParamPage()
	
	oSection	:= TRSection():New(oReport,STR0001)
	TRCell():New(oSection,'BE_LOCALIZ','SBE',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{||,aMsgLog[nLin,3]})
	TRCell():New(oSection,'B1_COD','SB1',,,,,{||,aMsgLog[nLin,4]})
	TRCell():New(oSection,'B1_DESC','SB1',,,,,{||,aMsgLog[nLin,5]})
	TRCell():New(oSection,STR0002,,,'@E 999999.99',9,,{||,aMsgLog[nLin,7]})
	TRCell():New(oSection,STR0003,,,'@E 999999.99',9,,{||,aMsgLog[nLin,8]})
	TRCell():New(oSection,STR0004,,,'@#',120,,{||,aMsgLog[nLin,9]})

Return(oReport)

//-------------------------------------------------------------------------------------------//
//-------------------------Executa a impress�o da se��o do relat�rio-------------------------//
//-------------------------------------------------------------------------------------------//
Static Function ReportPrint(oReport)
	
	Local oSection := oReport:Section(1)
	Local nCount
	
	oSection:Init()
	For nCount := 1 To Len(aMsgLog)
		oSection:PrintLine()
		nLin++
	Next
	oSection:Finish()
	
	oReport:IncMeter()
	
Return