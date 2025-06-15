#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDAPI37

Rotina de gera��o do Detalhamento Tipo 37 da DAPI-MG

@Param aWizard	->	Array com as informacoes da Wizard
		nCont ->	Contador das linhas do arquivo
		aFil	->	Array com as informa��es da filial em processamento

@Author Leandro Dourado
@Since 16/07/2019
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFDAPI37(aWizard, nCont, aFil)

Local cTxtSys  	 := CriaTrab( , .F. ) + ".TXT"
Local nHandle    := MsFCreate( cTxtSys )
Local cStrTxt	 := ""
Local nPos		 := 0
Local cPeriodo   := StrZero(Year(aWizard[1][1]),4,0) + StrZero(Month(aWizard[1][1]),2,0)
Local lFound     := .T.
Local cFilDapi   := aFil[1]
Local nPerAjust  := GetNewPar( "MV_ALQPONT",0,cFilDapi)
Local nTotRec    := 0
Local nVlrPer    := 0
Local nVlrAjust  := 0
Local cReg       := "37"

Begin Sequence
	
	
	/*
			***** IMPORTANTE!! DETALHAMENTO TIPO 37 - Incentivo � pontualidade *****
	*/
	
	If nPerAjust > 0
		nCont++
		
		nTotRec   := GetDapiTot()
		nVlrPer   := nTotRec * Val("0." + StrZero(nPerAjust,2))
		
		nVlrAjust := GetDapiPntVlr( nPerAjust, nVlrPer )
		
		cStrTxt := cReg 									            		//Tipo Linha		 - Valor Fixo: "37"
		cStrTxt += Substr(aFil[5],1,13)					              			//Inscri��o Estadual - M0_INSC ( SIGAMAT )
		cStrTxt := Left(cStrTxt,15) + StrZero(Year(aWizard[1][1]),4,0)			//Ano Refer�ncia
		cStrTxt := Left(cStrTxt,19) + StrZero(Month(aWizard[1][1]),2,0)			//M�s Refer�ncia
		cStrTxt := Left(cStrTxt,21) + StrZero(Day(aWizard[1][2]),2,0)			//Dia final refer�ncia
		cStrTxt := Left(cStrTxt,23) + StrZero(Day(aWizard[1][1]),2,0)			//Dia Inicial refer�ncia
	
		cStrTxt := Left(cStrTxt,25) + PadL(cValtoChar(nPerAjust),2,"0")         //Percentual de desconto
		cStrTxt := Left(cStrTxt,27) + StrTran(StrZero(nVlrAjust, 16, 2),".","")	//Valor de desconto
		
		cStrTxt := Left(cStrTxt,42) + Replicate("0",2)							//Percentual de desconto(??)
		cStrTxt := Left(cStrTxt,44) + Replicate("0",15)  						//Valor de desconto(??)
		cStrTxt += CRLF
		WrtStrTxt( nHandle, cStrTxt)
	
		GerTxtDAPI( nHandle, cTxtSys, cReg, cFilDapi)
	EndIf

Recover
	lFound := .F.

End Sequence

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GetDapiPntVlr

Retorna o valor de ajuste por pontualidade, de acordo com o decreto 47.226/2017.

@Param nPerAjust -> Numerico, Percentual de ajuste por pontualidade.	
@param nVlrPer   -> Numerico, Valor correspondente ao percentual informado.

@return nRet     -> Numerico, Valor de ajuste calculado conforme o decreto.
@Author Leandro Dourado
@Since 16/07/2019
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GetDapiPntVlr( nPerAjust, nVlrPer )
Local nRet        := 0

Default nPerAjust := 0
Default nVlrPer   := 0

/*
	*************************************************************************************
Deve ser observado o decreto 47.226/2017, dispon�vel em http://www.fazenda.mg.gov.br/empresas/legislacao_tributaria/decretos/2017/d47226_2017.htm
		
Art. 91-C - Verificada a pontualidade no cumprimento da obriga��o tribut�ria principal, nos termos do inciso III do art. 91-B deste Regulamento, 
e observado o disposto em resolu��o do Secret�rio de Estado de Fazenda, o contribuinte far� jus a um dos seguintes percentuais de desconto, 
a ser usufru�do mensalmente, por estabelecimento, durante o per�odo concessivo:

I - 1% (um por cento) sobre o saldo devedor do ICMS a t�tulo de opera��o pr�pria apurado no estabelecimento, 
caso comprovada a situa��o de total adimpl�ncia durante um per�odo aquisitivo, 
limitado ao valor equivalente a 3.000 (tr�s mil) Ufemg por m�s;

II - 2% (dois por cento) sobre o saldo devedor do ICMS a t�tulo de opera��o pr�pria apurado no estabelecimento, 
caso comprovada a situa��o de total adimpl�ncia durante tr�s ou mais per�odos aquisitivos consecutivos, 
limitado ao valor equivalente a 6.000 (seis mil) Ufemg por m�s.
	*************************************************************************************
*/

If     nPerAjust == 1 .And. nVlrPer > 3000
	nRet := 3000
ElseIf nPerAjust == 2 .And. nVlrPer > 6000
	nRet := 6000
EndIf

Return nRet