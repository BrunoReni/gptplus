#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDAPI99

Rotina de gera��o da linha 99 da DAPI-MG

@Param aWizard	->	Array com as informacoes da Wizard
		nCont ->	Contador das linhas do arquivo
		aFil	->	Array com as informa��es da filial em processamento

@Author Rafael V�ltz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFDAPI99(aWizard, nCont, aFil)

Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )
Local cREG 		:= "99"
Local cStrTxt 	:= ""
Local lFound      := ""

nCont++

Begin Sequence

cStrTxt := cREG 									               	    	 				  //Tipo Linha					- Valor Fixo: 00
cStrTxt += Substr(aFil[5],1,13)					              	 				  //Inscri��o Estadual		- M0_INSC ( SIGAMAT )
cStrTxt := Left(cStrTxt,15) + StrZero(Year(aWizard[1][1]),4,0)    		 				  //Ano Refer�ncia
cStrTxt := Left(cStrTxt,19) + StrZero(Month(aWizard[1][1]),2,0)		 				  //M�s Refer�ncia
cStrTxt := Left(cStrTxt,21) + StrZero(Day(aWizard[1][2]),2,0)			 				  //Dia final refer�ncia
cStrTxt := Left(cStrTxt,23) + StrZero(Day(aWizard[1][1]),2,0)			 				  //Dia Inicial refer�ncia
cStrTxt += StrZero(nCont,4,0)
cStrTxt += CRLF

WrtStrTxt( nHandle, cStrTxt )

GerTxtDAPI( nHandle, cTxtSys, cReg, aFil[1])

Recover
lFound := .F.

End Sequence


Return