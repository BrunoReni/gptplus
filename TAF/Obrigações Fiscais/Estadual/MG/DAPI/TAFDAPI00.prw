#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDAPI00

Rotina de gera��o da Linha Tipo 00 da DAPI-MG

@Param aWizard	->	Array com as informacoes da Wizard
		nCont ->	Contador das linhas do arquivo
		aFil	->	Array com as informa��es da filial em processamento

@Author Rafael V�ltz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFDAPI00(aWizard, nCont, aFil, lTermo)

Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   := MsFCreate( cTxtSys )
Local cREG 		:= "00"
Local cStrTxt 	:= ""
Local cTermoAc  := "N"
Local lFound    := .T.

Default lTermo  := .F.

nCont++

Begin Sequence

cStrTxt := cREG 									               	    	 		 	                       		//Tipo Linha					- Valor Fixo: 00
cStrTxt += Substr(aFil[5],1,13)					              	 				                             	//Inscri��o Estadual		- M0_INSC ( SIGAMAT )
cStrTxt := Left(cStrTxt,15) + StrZero(Year(aWizard[1][1]),4,0)    		 				                       	//Ano Refer�ncia
cStrTxt := Left(cStrTxt,19) + StrZero(Month(aWizard[1][1]),2,0)		 				                         //M�s Refer�ncia
cStrTxt := Left(cStrTxt,21) + StrZero(Day(aWizard[1][2]),2,0)			 				                         //Dia final refer�ncia
cStrTxt := Left(cStrTxt,23) + StrZero(Day(aWizard[1][1]),2,0)			 				                         //Dia Inicial refer�ncia
cStrTxt := Left(cStrTxt,25) + "D1"                                     				                         //Modelo DAPI      - FIXO 'D1'
cStrTxt := Left(cStrTxt,27) + If(aWizard[2][2] == '0 - N�o', "N", "S") 				                         //DAPI para substitui��o?
cStrTxt := Left(cStrTxt,28) + Replicate("0",7)                            		                            //CAE (n�o necess�rio, pois existe CNAE-F)
cStrTxt := Left(cStrTxt,35) + Replicate("0",2)                           				                      	//Desmembramento do CAE (n�o necess�rio)
cStrTxt := Left(cStrTxt,37) + If(aWizard[1][5] == '1 - D�bito e Cr�dito', "01", "03")                        //Regime de Recolhimento
cStrTxt := Left(cStrTxt,39) + If(aWizard[2][3] == '0 - N�o', "N", "S") 				                         //Regime especial de fiscaliza��o?
cStrTxt := Left(cStrTxt,40) + IIF(EMPTY(aWizard[1][6]) == .F., DtoS(aWizard[1][6]), + '00000000')            //Data limite para pagamento
cStrTxt := Left(cStrTxt,48) + "N"                                     				                         //Optante pelo FUNDESE?  SE Modelo da DAPI = �D1� ENT�O FUNDESE = "N"
cStrTxt := Left(cStrTxt,49) + If(aWizard[2][1] == '0 - N�o', "N", "S") 				                         //DAPI com movimento?
cStrTxt := Left(cStrTxt,50) + "N"                                     				                         //Movimento de Caf�? Apenas para DAPI Modelo 01 e at� referencia 07/2005.
cStrTxt := Left(cStrTxt,51) + Substr(aFil[4],1,7)	               				  	                         //CNAE-F
cStrTxt := Left(cStrTxt,58) + IIF(Empty(Substr(aWizard[1][7],1,2)) == .F.,Substr(aWizard[1][7],1,2), + "00") //Desmembramento CNAE-F

cTermoAc := IIF(SubStr(aWizard[2][4],1,1) <> '0' .And.; 
				StrZero(Year(aWizard[1][1]),4,0) + StrZero(Month(aWizard[1][1]),2,0) >= "201805", "S", "N")
				
lTermo := cTermoAc == "S"			

cStrTxt := Left(cStrTxt,60) + cTermoAc																		 //Termo de Aceite (Somente ser� preenchido com Sim a partir do per�odo de refer�ncia de 05/2018

cStrTxt += CRLF

WrtStrTxt( nHandle, cStrTxt )

GerTxtDAPI( nHandle, cTxtSys, cReg, aFil[1] )

Recover
	lFound    := .F.
End Sequence


Return

