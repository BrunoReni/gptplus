#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"    
#INCLUDE "STBNOTFISCAL.CH"
#INCLUDE "AUTODEF.CH"  

#DEFINE ARQLJINI GetClientDir()+"SIGALOJA.INI"		// caminho do ini do SIGALOJA

Static lMVLJPRDSV := SuperGetMv("MV_LJPRDSV",.F.,.F.) // Verifica se esta ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas (RPS)

//-------------------------------------------------------------------
/* {Protheus.doc} STBSumNotFiscal
Adiciona valor no totalizador n�o fiscal

@param   nValue				Valor
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STBSumNotFiscal( nValue, lIsRPS )

Local oTotal := STFGetTot()		// Totalizador

Default nValue  	:= 0	
Default lIsRPS 		:= .F.

ParamType 0 Var  nValue As Numeric	 Default 0

oTotal:SetValue( "L1_NOTFISCAL" , nValue + oTotal:GetValue("L1_NOTFISCAL") )

If lIsRPS
	//Adiciona valor do servi�o (RPS) no totalizador n�o fiscal do RPS
	STBSumVRPS( nValue )
EndIf

Return Nil                                                                      


//-------------------------------------------------------------------
/*/ {Protheus.doc} STBFactor
Calcula fatores Fiscal e N�o-Fiscal

@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet - Fatores fiscais e nao fiscais
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STBFactor(lUseServ)

Local nFiscalFactor		:= 0								// Fator Fiscal
Local nNotFiscalFactor	:= 0								// Fator N�o Fiscal
Local nTotFiscal		:= 0								// Total Fiscal
Local oTotal	 		:= STFGetTot() 						// Totalizador
Local nTotNaoFisc		:= oTotal:GetVaLue("L1_NOTFISCAL")	// Totalizador Nao Fiscal
Local lItEntrega		:= STBTemEntr()						// Indica se a venda tem item de entrega
Local nTotalVda 		:= 0								// Total da venda
Local nTotServic		:= 0								// Total de Itens de servi�o (RPS)
Local nPedFactor		:= 1								// Fator N�o Fiscal (Pedido)
Local nRPSFactor		:= 1								// Fator N�o Fiscal (RPS)

Default lUseServ 		:= .T. 								// Controla se considera servicos no totalizador nao fiscal

If lMVLJPRDSV
	If oTotal:HasField("L1_NOTFISRPS") //Verifica se o campo est� na estrutura do Model
		nTotServic := oTotal:GetValue("L1_NOTFISRPS")
	Else
		nTotServic := STFTotalServ()
	EndIf
EndIf

nTotalVda := oTotal:GetValue("L1_VLRTOT") + oTotal:GetValue("L1_DESCONT") - oTotal:GetValue("L1_ACRSFIN")

/*------------------------------------------------------------------------------------- 
 Adiciona os valores de Frete + Seguro + Despesa no total n�o-fiscal quando existir 
 item de entrega na venda, para o fator fiscal e n�o-fiscal ficarem corretos.
-------------------------------------------------------------------------------------*/
If lItEntrega
	nTotNaoFisc := nTotNaoFisc + oTotal:GetValue("L1_FRETE") + oTotal:GetValue("L1_SEGURO") + oTotal:GetValue("L1_DESPESA")
EndIf	

//Se nao considera servicos no totalizador nao fiscal, armazena os valores de servicos
If !lUseServ
	nTotNaoFisc -= nTotServic
EndIf

nNotFiscalFactor := (nTotNaoFisc / nTotalVda)
If nTotServic > 0
	nRPSFactor := (nTotServic / nTotalVda)
EndIf
If nTotNaoFisc > 0
	nPedFactor := (nTotNaoFisc-nTotServic) / nTotalVda
else
	nPedFactor := nNotFiscalFactor
EndIf
nFiscalFactor 	:= (1 - nNotFiscalFactor)  
nTotFiscal		:= (nTotalVda - nTotNaoFisc)

nFiscalFactor := IIf(nFiscalFactor == 0, 1, nFiscalFactor)

aRet := { nFiscalFactor, nNotFiscalFactor, nTotFiscal, nPedFactor, nRPSFactor } 

Return aRet
            
//-------------------------------------------------------------------
/*/ {Protheus.doc} STBPrintNotFiscal
Imprime cupom nao fiscal

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet[1] -  Retorna se executou corretamente 
@return  aRet[2] -  Numero do cupom
@return  aRet[3] -  Numero do PDV
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBPrintNotFiscal()

Local aRet			:= { .T. , "" , "" }				// Retrono Fun��o
Local oTotal		:= STFGetTot()						// Totalizador
Local aPrinter		:= {}			   					// Armazena Retorno da impressora
Local cText			:= ""			   					// Texto para impress�o
Local cValue		:= ""			  					// Valor para impress�o
Local lContinue		:= .T.			  					// Fluxo funcao
Local aCupom 		:= {Space(6), Nil} 					// Retorno Evento GetCupom
Local aPDV			:= {""}			   					// Retorno evento pegar PDV
Local cCupom		:= ""			  					// Retorno n�mero do Cupom   
Local cPDV			:= ""			  					// Armazena PDV
Local cUseTef		:= ""			 					// Indica se utiliza tef. "S" ou "N"
Local cPayTef		:= ""			 					// Condi��o de pagamento TEF
Local lGuil			:= SuperGetMV("MV_FTTEFGU",, .T.)	// Ativa guilhotina 
Local lIsImpOrc 	:= If(FindFunction("STBIsImpOrc"),STBIsImpOrc(),(!(Empty(STDGPBasket("SL1","L1_NUMORIG"))))) //Verifica se � importa��o de or�amento
Local cSerieRPS		:= SuperGetMv("MV_LOJARPS",,"RPS") 	// Serie da NF de Servico RPS configurada no parametro MV_LOJARPS
Local lPedido 		:= STBTemEntr()						// Verifica se tem item de "Entrega" ou "Retira Posterior".
Local lRPS 			:= lMVLJPRDSV .And. (lIsImpOrc .Or. (ExistFunc("Lj7RPSNew") .And. Lj7RPSNew() .And. !STFGetCfg("lUseECF"))) .And. STBTemServ()	// Verifica se tem item de "Servico".
Local aNotas		:= {}
Local lTemItProd	:= .F.								// item fiscal
Local lTemItServ	:= .F.								// item de servico
Local lIsValePres	:= .F. 								//Verifica se � vale presente
Local lExistSer 	:= .F.								// verifica se existe a Serie N�o Fiscal
Local lSFinanc      :=  AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.) //Se .T. indica que o Servi�o financeiro esta ativo
local lFindExist	:= Iif(ExistFunc("LjFindServ"),Iif(LjFindServ(STDGPBasket("SL1","L1_NUM")),.T.,.F.),.F. ) //Verifico se a fun��o LjFindServ existe e se existe verifico se todos os itens s�o servi�o
Local lLjVpCnf		:= SuperGetMV("MV_LJVPCNF",,.F.) 	//verifica se imprime vale presente no cupom fiscal
Local lOnlyServ 	:= .F.
Local nPrintNFis	:= 0
Local cTxtCpvPED	:= "" //Texto do comprovante nao fiscal "SCRPED"
Local cTxtCpvRPS	:= "" //Texto do comprovante nao fiscal "SCRRPS"
Local aComprovan	:= {}
Local nI 			:= 0

cSerieRPS := PadR(cSerieRPS , TamSX3("L1_SERRPS")[1])

If !STFGetCfg("lUseECF") .AND. STBExistNItemFiscal() 

		If lRPS //RPS (Recibo Provisorio de Servico)

			cTxtCpvRPS := LJSCRPS( {.F., {}, STBFactor()[5]} ) //No array, elem. 2, fator do comprovante n�o-fiscal         	
			cTxtCpvRPS := StrTran( cTxtCpvRPS, ',', '.' )
			
			If !Empty(cTxtCpvRPS)
				aAdd( aComprovan, cTxtCpvRPS )
			EndIf

		EndIf

		If (!lRPS .Or. lPedido)
			
			cTxtCpvPED := LJSCRPED( {"",STBFactor()[4]} ) //No array, elem. 2, fator do comprovante n�o-fiscal         	
			cTxtCpvPED := StrTran( cTxtCpvPED, ',', '.' )
			
			If !Empty(cTxtCpvPED)
				aAdd( aComprovan, cTxtCpvPED )
			EndIf

		EndIf

		If !Empty(cTxtCpvRPS) .Or. !Empty(cTxtCpvPED)

			//Verifica se � vale presente:
			lIsValePres := iIf(FindFunction("STDExistVP"),STDExistVP(),.F.)

			If lPedido .Or. lIsValePres  //Pedido ou Vale presente
				cSerie := STFGetStation("SERNFIS")

				lExistSer:=	LjxDNota( cSerie, 3, .F., 1, @aNotas )  
				If lExistSer
					cCupom := aNotas[1][2]

					STDSPBasket( "SL1" , "L1_DOCPED"	, cCupom   				)
					STDSPBasket( "SL1" , "L1_SERPED"	, cSerie				)
					STDSPBasket( "SL1" , "L1_SITUA"		, "00"					)
					/*	Se o campo L1_DOC estiver vazio, entao deve-se limpar o campo L1_SERIE
						melhoria: o campo L1_SERIE s� deve ser preenchido quando a venda for fiscal	*/
					If lPedido .Or. (lIsValePres .And. !lLjVpCnf)				 				
						If !STBExistItemFiscal() 
							STDSPBasket( "SL1", "L1_DOC", "" )
							STDSPBasket( "SL1", "L1_SERIE", "" )
						EndIf
					EndIf
				Else
					aRet			:= { .F. , "" , "" }
				Endif
			EndIf

			If aRet[1] .And. lRPS //RPS (Recibo Provisorio de Servico)
				cSerie := cSerieRPS	// Serie da NF de Servico RPS configurada no parametro MV_LOJARPS

				STDSPBasket( "SL1" , "L1_SERRPS"	, cSerie				) // Numero de serie da nota fiscal de servico (RPS)
				STDSPBasket( "SL1" , "L1_SITUA"		, "00"					)
				
				LjCheckRPS(STDGPBasket("SL1","L1_NUM"),@lTemItProd,@lTemItServ)
				lOnlyServ := lTemItServ .And. !lTemItProd .And. !Empty(cSerie)
				If lOnlyServ //A venda possui apenas itens de Servico
					lExistSer := LjxDNota( cSerie, 3, .F., 1, @aNotas )
					If lExistSer
						cCupom := aNotas[1][2]						
						STDSPBasket( "SL1" , "L1_DOC"	, ""				)
						STDSPBasket( "SL1" , "L1_SERIE"	, ""				)
						STDSPBasket( "SL1" , "L1_DOCRPS", cCupom				)
					Else
						aRet := { .F. , "" , "" }
					EndIf
				ElseIf Empty(STDGPBasket( "SL1" , "L1_DOC")) //Se DOC estiver vazio � porque na venda s� tem produtos de servico (RPS)
					STDSPBasket( "SL1" , "L1_DOC"	, cCupom				)
					STDSPBasket( "SL1" , "L1_SERIE"	, cSerie				)
					STDSPBasket( "SL1" , "L1_DOCRPS", cCupom				)					 	
				EndIf
										
			EndIf			 		

			If aRet[1]
				For nI := 1 To Len(aComprovan)
					cText := aComprovan[nI]
					nPrintNFis := STWPrintTextNotFiscal(cText)
					If nPrintNFis <> 0
						aRet := { .F. , "" , "" }
						Exit
					EndIf
					If lGuil
						cText := Replic(CHR(10)+CHR(13),6)
						cText += TAG_GUIL_INI+TAG_GUIL_FIM //Corte de Papel
						STWPrintTextNotFiscal(cText)
					EndIf
				Next nI
			EndIf

			If aRet[1]
				aRet := { .T. , cCupom , STFGetStation("PDV") }
			EndIf

		EndIf
		
ElseIf STFUseFiscalPrinter() .AND. oTotal:GetValue("L1_NOTFISCAL") > 0 // Utiliza impressora fiscal e possui itens n�o fiscais

	If STBValPrintNotFiscal(If(lPedido,"PED",If(lRPS,"RPS","")))
		
		If lPedido  //Pedido

			cText := LJSCRPED( {"",STBFactor()[4]} ) //No array, elem. 2, fator do comprovante n�o-fiscal         	
			
		ElseIf lRPS //RPS (Recibo Provisorio de Servico)

			cText := LJSCRPS( {.F., {}, STBFactor()[5]} ) //No array, elem. 2, fator do comprovante n�o-fiscal

		EndIf
		
		cText := StrTran( cText, ',', '.' )                                    
		
		// Se n�o tiver item fiscal na venda n�o multiplica total (L1_VLRLIQ) pelo fator fiscal/n�o-fiscal
		If Empty(STDGPBasket( "SL1" , "L1_DOC"))
			cValue := Str(( oTotal:GetValue("L1_VLRTOT")) , 15 , 2 )
		Else
			cValue := Str(( oTotal:GetValue("L1_VLRTOT") * STBFactor()[2] ) , 15 , 2 )
		EndIf
			
		/*/
			Imprime N�o Fiscal
		/*/                                                                                                        
		aPrinter := STFFireEvent(	ProcName(0)				, ;
										"STSalesOrder" 			, ; 
										{	cUseTef				, ;
											cText					, ;
											cValue					, ;
											cPayTef				} )
											
		If ValType(aPrinter) <> "A" .OR. Len(aPrinter) == 0 .OR. aPrinter[1] <> 0 
			lContinue := .F.		
		EndIf							
					
		/*/
			Pega o numero do Comprovante Nao Fiscal
		/*/
		If lContinue		
			aPrinter := STFFireEvent( ProcName(0) , "STGetReceipt" , aCupom )		
			If Len(aPrinter) == 0 .OR. aPrinter[1] <> 0 .OR. Len(aCupom) < 1
				If lPedido  //Pedido
					MsgStop(STR0001) // "Erro ao pegar o n�mero do cupom ap�s a impress�o do pedido. Verifique o ECF."
				ElseIf lRPS //RPS (Recibo Provisorio de Servico)
					MsgStop(STR0009) // "Erro ao pegar o n�mero do cupom ap�s a impress�o do comprovante RPS (Recibo Provis�rio de Servi�o). Verifique o ECF."
				EndIf
				lContinue 	:= .F.
			Else
				cCupom := aCupom[1]
			EndIf 
		EndIf 
		
		//------------------------------------------------------------------------------------------------------
		cCupom := StrZero( Val(cCupom) - 1 , Len(AllTrim(cCupom)) , 0 )
		
		//Se a impress�o do comprovante n�o foi um relat�rio gerencial, ent�o pode-se alterar                  
		//a vari�vel cNumCupom. Sem esta valida��o, poder� causar um erro de chave duplicada no Banco de Dados,
		//pois o n�mero t�tulo financeiro poder� se repetir.                                                   
		
		// TODO: Verificar
		/*
		If !lRelGer .OR. Val(cValor) == 0
			If STFGetCfg("lEcfArg")
				cNumCupom:=StrZero(Val(cNumCupom)-1,Len(AllTrim(cNumCupom)) ,0)
			EndIf
		EndIf
		*/      
		//--------------------------------------------------------------------------------------------------------
		
		/*/
			Get PDV
		/*/
		If lContinue
			aPrinter := STFFireEvent( ProcName(0) , "STGetPDV" , aPDV )		
			If ValType(aPrinter) <> "A" .OR. Len(aPrinter) == 0 .OR. aPrinter[1] <> 0 .OR. Len(aPDV) < 1     
				If lPedido  //Pedido
					MsgStop(STR0002) // "Erro ao pegar o n�mero do PDV ap�s a impress�o do pedido. Verifique o ECF."
				ElseIf lRPS //RPS (Recibo Provisorio de Servico)
					MsgStop(STR0010) // "Erro ao pegar o n�mero do PDV ap�s a impress�o do comprovante RPS (Recibo Provis�rio de Servi�o). Verifique o ECF."
				EndIf
				lContinue 	:= .F.
			Else
				cPDV := aPDV[1]
			EndIf 
		EndIf
		
		If lContinue
			
			aRet := { .T. , cCupom , cPDV }
		 	
		 	//Verifica se � vale presente:
		 	lIsValePres := iIf(FindFunction("STDExistVP"),STDExistVP(),.F.)
		 	
		 	/*/
		 		Atualiza Cesta
		 	/*/
			If lPedido .Or. lIsValePres  //Pedido
			 	cSerie := STFGetStat("SERIE")

			 	STDSPBasket( "SL1" , "L1_DOCPED"	, cCupom	)
			 	STDSPBasket( "SL1" , "L1_SERPED"	, cSerie	)
			 	STDSPBasket( "SL1" , "L1_SITUA"		, "00"		)
			 	/* 	Se o campo L1_DOC estiver vazio, entao deve-se limpar o campo L1_SERIE
			 		melhoria: o campo L1_SERIE s� deve ser preenchido quando a venda for fiscal	*/
			 	If lPedido .AND. !STBExistItemFiscal()
			 		STDSPBasket( "SL1", "L1_DOC", "" )
			 		STDSPBasket( "SL1", "L1_SERIE", "" )
			 	EndIf
			ElseIf lSFinanc .AND. lFindExist //Servi�o Financeiro a avulso
				cSerie := STFGetStat("SERIE")
				
			 	STDSPBasket( "SL1" , "L1_DOCRPS", cCupom	)
			 	STDSPBasket( "SL1" , "L1_SERRPS", cSerie	)
			 	STDSPBasket( "SL1" , "L1_SITUA"	, "00"		)
			 	 	
			ElseIf lRPS  //RPS (Recibo Provisorio de Servico)
			 	cSerie := cSerieRPS	// Serie da NF de Servico RPS configurada no parametro MV_LOJARPS

			 	STDSPBasket( "SL1" , "L1_SERRPS"	, cSerie	)	// Numero de serie da nota fiscal de servico (RPS)
			 	STDSPBasket( "SL1" , "L1_SITUA"		, "00"		)
			 	
				LjCheckRPS(STDGPBasket("SL1","L1_NUM"),@lTemItProd,@lTemItServ)
				lOnlyServ := lTemItServ .And. !lTemItProd .And. !Empty(cSerie)
			 	If lOnlyServ //A venda possui apenas itens de Servico
					STDSPBasket( "SL1" , "L1_DOC"	, ""				)
					STDSPBasket( "SL1" , "L1_SERIE"	, ""				)
					STDSPBasket( "SL1" , "L1_DOCRPS", cCupom			)			 	
			 	ElseIf Empty(STDGPBasket( "SL1" , "L1_DOC")) 			//Se DOC estiver vazio � porque na venda s� tem produtos de servico (RPS)
					STDSPBasket( "SL1" , "L1_DOC"	, cCupom	)
					STDSPBasket( "SL1" , "L1_SERIE"	, cSerie	)
					STDSPBasket( "SL1" , "L1_DOCRPS", cCupom	)
			 	EndIf
			EndIf
			
		 Else
		 	aRet := { .F. , "" , "" }
		 EndIf
		
	Else	
	   	aRet := { .F. , "" , "" }	   	
   	EndIf		

Else	
	aRet := { .T. , "" , "" }		
EndIf
	        	
Return aRet


//-------------------------------------------------------------------
/* {Protheus.doc} STBValPrintNotFiscal
Adiciona valor no totalizador n�o fiscal

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet			Retorna se pode imprimir o cupom nao fiscal
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STBValPrintNotFiscal(cOpc)
                                                                     
Local lRet	   			:= .T.				// Retorno da fun��o
Local aRet				:= {}				// Armazena Retorno da impressora
Local aIsOpenReceipt   	:= { "5" , "" }		// Armazena retorno se o cupom est� aberto

Default cOpc 			:= ""


/*/
	Valida Data/Hora
/*/
aRet := STFFireEvent( 	ProcName(0)	   		,; // Nome do processo
   							"STCheckDate"			,; // Nome do evento
							{} 			   			)	
												
If Len(aRet) > 0 .AND. ValType(aRet[1]) == "L" .AND. aRet[1]
	lRet := .T.
Else
	lRet := .F.
	MsgStop(STR0003)	// TODO //"Imposs�vel continuar impress�o. Ajustar Data/Hora da impressora."
EndIf
 

/*/
	Verifica cupom aberto
/*/	
If lRet
	aRet := STFFireEvent( 	ProcName(0)					   		,; // Nome do processo
   								"STPrinterStatus"						,; // Nome do evento
					   			aIsOpenReceipt	  					)
					
	If Len(aIsOpenReceipt) >= 2 .AND. ValType(aIsOpenReceipt[2]) == "N"						    
		If aIsOpenReceipt[2] == 7
	 		nRet := IFCancCup( nHdlECF ) // TODO: Criar evento cancelamento
			If Lj7VerCmd( nRet ) // TODO: Mudar para <> 0
				/*/
					Espera um tempo para a impressora fazer a impressao do cancelamento
				/*/
				Inkey(8)
			EndIf
		EndIf
	EndIf
EndIf


/*/
	Valida RdMake Impressao
/*/
If lRet
	If Empty(cOpc) .Or. cOpc == "PED" 
		If !ExistBlock("SCRPED") .AND. !ExistFunc("LJSCRPED")
			MsgStop(STR0004) //"O rdmake SCRPED.PRW n�o est� compilado e n�o ser� poss�vel imprimir o comprovante de venda. Informe essa mensagem ao administrador do sistema."	  
			lRet := .F.
		EndIf
	ElseIf cOpc == "RPS"
		If !ExistBlock("SCRRPS") .AND. !ExistFunc("LJSCRPS")
			MsgStop(STR0011) //"O rdmake SCRRPS.PRW n�o est� compilado e n�o ser� poss�vel imprimir o comprovante RPS (Recibo Provis�rio de Servi�o). Informe essa mensagem ao administrador do sistema."	  
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCheckFiscalItens
Verifia se cupom fiscal est� aberto e se eistem itens fiscais para o cupom.
Se o cupom estiver aberto mas n�o existir itens, cancela o cupom.

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet - Successful Check
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCheckFiscalItens()

Local oTotal		:= STFGetTot() 	// Totalizador
Local cNumDoc		:= "" 			//Numero do CF
Local cSupervisor 	:= ""
Local lRet 			:= .T. 			//Execu��o com sucesso  - realiza o prosseguimento da venda

If STWGetIsOpenReceipt() .AND. !( STBExistItemFiscal(.F.) )	.AND. ( oTotal:GetVaLue("L1_NOTFISCAL") > 0 )
	/*/
		Cancela o Cupom Fiscal, pois os itens registrados no cupom fiscal foram cancelados
	/*/

	//Envia o comando de cancelamento do cupom fiscal
	
	cNumDoc := STDGPBasket( "SL1" , "L1_DOC")	
	
	
	lRet := STBCSCancCupPrint( cSupervisor , cNumDoc )
	
	If lRet
		STWSetIsOpenReceipt( .F. )
	EndIf
EndIf	

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBExistItemFiscal
Verifia se existe item fiscal na venda

@param	  lDeleted - N�o Verifica registros deletados (.t.)
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lExist				Retorna se existe item fiscal na venda
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBExistItemFiscal(lDeleted)

Local lExist			:= .F.									// Retorno fun��o
Local aLines      := FwSaveRows()	
Local oModelCesta		:= STDGPBModel()						// Armazena model da cesta
Local oModelItens		:= oModelCesta:GetModel("SL2DETAIL")	// Model Itens
Local nI				:= 0									// Contador

Default lDeleted := .T. //Considera registros deletados (default)

For nI := 1 To oModelItens:Length()

	oModelItens:GoLine(nI)

	If (!oModelItens:IsDeleted()  .or. lDeleted) .AND. oModelItens:GetValue("L2_FISCAL")

		lExist := .T.
		Exit

	EndIf

Next nI

FwRestRows(aLines)

Return lExist

//-------------------------------------------------------------------
/*/{Protheus.doc} STBExistNItemFiscal
Verifia se existe item n�o-fiscal na venda

@param
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lExist				Retorna se existe item n�o-fiscal
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBExistNItemFiscal()

Local lExist			:= .F.									// Retorno fun��o
Local oModelCesta		:= STDGPBModel()						// Armazena model da cesta
Local oModelItens		:= oModelCesta:GetModel("SL2DETAIL")	// Model Itens
Local nI				:= 0									// Contador

For nI := 1 To oModelItens:Length()

	If !oModelItens:IsDeleted(nI)
		If !oModelItens:GetValue( "L2_FISCAL" , nI )
			lExist := .T.
			Exit
		EndIf
	EndIf

Next nI

Return lExist

//-------------------------------------------------------------------
/*/{Protheus.doc} STBIANotFiscal
Imprime Cupom n�o-fiscal de Doa��o
@param nDoacao		Total da doa��o
@param
@author  Varejo
@version P11.8
@since   25/10/2013
@return
@obs     
@sample
/*/
*/
//-------------------------------------------------------------------
Function STBIANotFiscal( nDoacao, cSerie, cDoc, cCliente,;
									 cLojaCli, cCPFCli, cFormPg )

Local cTickForm									// Texto do cupom n�o-fiscal
Local cFormaPgto 	 := ""							// Ler qual cond. pagto. no Sigaloja.ini
Local cTotalizNFis := ""							// Ler qual totalizador no Sigaloja.ini
Local lRetorno     := .T.                    // Retorna se a impress�o foi efetuada com sucesso
Local lRecNaoFis := (nModulo == 5 .OR. nModulo == 6) .OR.;	//Recebimento pelo Venda Direta
			 		((nModulo == 12 .OR. nModulo == 23) .AND. ExistFunc("LjEmitNFCe") .AND. LjEmitNFCe())	//Recebimento pelo Loja/Front com NFC-e
			 															//Sinaliza recebimento por modulo n�o fiscal(sem ECF) *NFC-e, Venda Direta
Local cMsgComprovante	:= ""					//Mensagem para Comprovante, se NFC-e ou SAT
Local lGuil				:= ""					//Ativa guilhotina

Default nDoacao := 0								//Par�metro do valor da doa��o
Default cSerie	:= ""							//Serie
Default cDoc		:= ""							//Documento
Default cCliente	:= ""							//C�digo do Cliente
Default cLojaCli	:= ""							//Loja do Cliente
Default cCPFCli	:= ""							//CPF/CNPJ do Cliente
Default cFormPg	:= ""							//Forma de Pagamento

If lRecNaoFis		//Se NFC-e ou SAT

	lGuil				:= SuperGetMV("MV_FTTEFGU",, .T.)	// Ativa guilhotina
	cMsgComprovante := Lj950TxtIA(nDoacao, cSerie, cDoc, cCliente,;
											 cLojaCli, cCPFCli, cFormPg)	
	nRet := STWPrintTextNotFiscal(cMsgComprovante)
	lRetorno := (nRet = 0)
		
	If lGuil .AND. lRetorno
		STWPrintTextNotFiscal(TAG_GUIL_INI+TAG_GUIL_FIM)
	EndIf

Else		//Se ECF, entrar� no STBIAPrinReceipt(), com fun�oes espec�ficas somente para o SIGAFRT.

	cFormaPgto 	 := GetPvProfString("Instituto Arredondar", "FormaPgto", " ", ARQLJINI )	// Ler qual cond. pagto. no Sigaloja.ini
	cTotalizNFis := GetPvProfString("Instituto Arredondar", "Totalizador", "01", ARQLJINI )  // Ler qual totalizador no Sigaloja.ini
	// cTickform � a descri��o do texto.
	cTickForm := STR0012 + chr(10) + chr(13);	//"DOA��O - INSTITUTO ARREDONDAR"
					+ STR0013 + chr(10) + chr(13);	//"CNPJ 14.416.996/0001-25"
					+ STR0014							//"www.arredondar.org.br"
					
	/*
		A impressora dever� estar cadastrada como:
		Forma de Pagamento: A VISTA ou RECEBER, ou o c�digo cadastrado de um deles
		Totalizador n�o-fiscal: DOACAO
	*/
	lRetorno := STBIAPrinReceipt( cFormaPgto, nDoacao, cTotalizNFis, cTickform )

EndIf

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} STBIAPrinReceipt
Imprime o Cabe�alho do Cupom n�o-fiscal de Doa��o
@param cFormaPagto		Forma de Pagamento
@param nValor				Valor da Doa��o
@param cTotalizador		Nome do Totalizador para cupom n�o-fiscal
@param cTexto				Texto informativo
@author  Varejo
@version P11.8
@since   25/10/2013
@return
@obs     
@sample
/*/

//-------------------------------------------------------------------
Function STBIAPrinReceipt(cFormaPgto, nValor, cTotalizador, cTexto)     

Local lContinua  := .F.   //Laco de continuidade do processo
Local lReimprime := .F.   //Indica��o de reimpress�o do comprovante 
Local lImprimiu  := .F.   //Impress�o do comprovante com sucesso?
Local aRet	     := {}    //Retorno do ECF
	
Default cFormaPgto := ""					// Par�metro 1: Forma de Pagamento cadastrado no ECF
Default nValor := 0						// Par�metro 2: Valor de doa��o ao Instituto Arredondar
Default cTotalizador := ""				// Par�metro 3: Totalizador cadastrado no ECF
Default cTexto := ""						// Par�metro 4: Texto livre
	
lContinua := .T.
Do While lContinua  

	//Abre cupom fiscal n�o vinculado
	
	aRet := 	STFFireEvent(	ProcName(0)																	,;		// Nome do processo
				"STOpenNotFiscalReceipt",;
				{cFormaPgto,;
					 Alltrim(Str(nValor,14,2)),;  //totalizar nformas de pagamento
					 cTotalizador,;
					 cTexto,;
					 NIL})	
					
	If !STBIAVerifyPrint(aRet, @lReimprime ) 
	//Erro de Impressao e pode reimprimir OU USU�RIO N�O TEM PERMISS�O PARA CANCELAR  //LjTEFAskImp(@nOpt,nRet) .OR. (nOpt == 0 .And. !LjSenSupTEF())
						
		If lReimprime
			Loop
		Else
			lContinua := .F.    
		EndIf

	EndIf 
					
	If !lContinua
		Loop
	Endif
					
	//bufferizar as linhas do comprovante e enviar conforme contador   
	aRet := STBIAPrinTxtFisc(@cTexto)
					
	If !STBIAVerifyPrint(aRet, @lReimprime ) 
	//Erro de Impressao e pode reimprimir OU USU�RIO N�O TEM PERMISS�O PARA CANCELAR  //LjTEFAskImp(@nOpt,nRet) .OR. (nOpt == 0 .And. !LjSenSupTEF())
						
		If lReimprime
			Loop
		Else
			lContinua := .F. 
		EndIf
								                
	EndIf 
					
	If !lContinua
		Loop
	Endif
	InKey(2)
			
	aRet := 	STFFireEvent(	ProcName(0)																	,;		// Nome do processo
				  		"STCloseNotFiscalReceipt",;
						{})
										
	If !STBIAVerifyPrint(aRet, @lReimprime ) 
		//Erro de Impressao e pode reimprimir OU USU�RIO N�O TEM PERMISS�O PARA CANCELAR  //LjTEFAskImp(@nOpt,nRet) .OR. (nOpt == 0 .And. !LjSenSupTEF())
		If lReimprime
			Loop
		Else
			lContinua := .F. 
		EndIf
	Else 
		lImprimiu := .T.
		lContinua := .F. 
	EndIf 
					
	If !lContinua
		Loop
	EndIf

End
	
Return lImprimiu   

//-------------------------------------------------------------------
/*/{Protheus.doc} STBIAVerifyPrint
Verifica o status da impress�o
@param 	aRet			Retorno do Array
@param 	lReimprime		Permiss�o de reimpress�o 
@author  Varejo
@version P11.8
@since   25/10/2013
return  lImprime
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBIAVerifyPrint(aRet, lReimprime )

Local lImprime 		:= .T.      //Impress�o com sucesso?
Local nOpt 			:= 2        //Op��o selecionada pelo usu�rio
Local lTentaTiva 	:= .T.      //controle de tentativa

Default lReimprime := .F.    //Reimprime o cupom?
	
If Valtype(aRet) == "A" .AND. Len(aRet) > 0 .AND. aRet[1] <> 0 //Erro na impress�o  
	
	//Erro na Impress�o - Trata a mensagem
	lImprime := .F.

	While lTentaTiva 
							
		STFMessage("IA_Imprime", "YESNO", STR0005 + " " + STR0006) //"Impressora n�o responde."#"Deseja imprimir novamente?"
		nOpt := If(STFShowMessage("IA_Imprime"),2,0) 
			
		//2=SIM
		If nOpt == 2
			
			Sleep(1000)
				
			aRet :=	STFFireEvent(	ProcName(0)																	,;		// Nome do processo
										"STCloseNotFiscalReceipt"													,;		// Nome do evento
										{""} )  
			
			If Valtype(aRet) == "A" .AND. Len(aRet) > 0 .AND. aRet[1] <> 0 //Erro na impress�o				
				lTentaTiva := .T.
			Else
				lTentaTiva := .F.	
				lReimprime := .F.
			EndIf
			
		Else				
			lTentaTiva := .F.					
		EndIf	
	
	EndDo
										
	If nOpt == 2 // .OR. !Self:ReimpSenSup()  //Superior n�o digitou senha para desfazer a transacao
		lReimprime := .T. 
		STFMessage("IA", "RUN", STR0007)  //"Aguarde a impress�o do comprovante n�o fiscal...." 
		STFShowMessage("IA")
	EndIf

Else
	If ValType(aRet) <> "A"
		STFMessage("IA_Imprime", "ALERT", STR0008)  //"Problemas com a Impressora Fiscal"
		STFShowMessage("IA_Imprime") 				
	EndIf
EndIf
	
Return lImprime 


//-------------------------------------------------------------------
/*/{Protheus.doc} STBIAPrinTxtFisc
Retorna o texto do cupom n�o fiscal
@param	cTexto					Texto Informativo
@author  Varejo
@version P11.8
@since   25/10/2013
@return  aRet
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBIAPrinTxtFisc(cTexto)

Local aRet := {0}  //Array de Retorno

Default cTexto := ""			// Texto livre
	
aRet := STFFireEvent(	ProcName(0)				,;		// Nome do processo
							"STTxtNotFiscalReceipt",;
							{cTexto,;
									 1})	   

Return aRet       

//-------------------------------------------------------------------
/*/{Protheus.doc} STBTemEntr
Verifia se tem item de "Entrega" ou "Retira Posterior".

@param
@author  Varejo
@version P11.8
@since   25/08/2015
@return  lExist				Retorna se tem item de "Entrega" ou "Retira Posterior".
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBTemEntr()
Local lExist			:= .F.									// Retorno fun��o
Local oModelCesta		:= STDGPBModel()						// Armazena model da cesta
Local oModelItens		:= oModelCesta:GetModel("SL2DETAIL")	// Model Itens
Local nI				:= 0									// Contador

For nI := 1 To oModelItens:Length()
	
	If !oModelItens:IsDeleted(nI)
		If (!Empty( oModelItens:GetValue("L2_RESERVA", nI) ) .And. oModelItens:GetValue("L2_ENTREGA", nI) <> "2") .OR.;//2=Retira
			(Empty( oModelItens:GetValue("L2_RESERVA", nI) ) .And. oModelItens:GetValue("L2_ENTREGA", nI) == "5") // 5= ENTREGA C/ PEDIDO S/ RESERVA
			lExist := .T.
			Exit
	
		EndIf
	EndIf

Next nI

Return lExist

//-------------------------------------------------------------------
/*/{Protheus.doc} STBTemServ
Verifia se tem item de "Servico".

@param
@author  Varejo
@version P11.8
@since   25/08/2015
@return  lExist				Retorna se tem item de "Servico".
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBTemServ()
Local lExist			:= .F.									// Retorno fun��o
Local oModelCesta		:= STDGPBModel()						// Armazena model da cesta
Local oModelItens		:= oModelCesta:GetModel("SL2DETAIL")	// Model Itens
Local nI				:= 0									// Contador

For nI := 1 To oModelItens:Length()
	
	If !oModelItens:IsDeleted(nI)
		If (Empty(oModelItens:GetValue("L2_ENTREGA", nI)) .Or. oModelItens:GetValue("L2_ENTREGA", nI) == "2") .And. ; //2=Retira
			LjIsTesISS( oModelItens:GetValue("L2_NUM", nI), oModelItens:GetValue("L2_TES", nI) ) //Verifica se eh item de servico
			
			lExist := .T.
			Exit
			
		EndIf
	EndIf

Next nI

Return lExist

//-------------------------------------------------------------------
/* {Protheus.doc} STBSumVRPS
Adiciona valor do servi�o (RPS) no totalizador n�o fiscal do RPS.

@author  Alberto Deviciente
@version P12
@since   12/08/2022

@param nValue, Num�rico, Valor do Item de servi�o (RPS)

@return  Nil
*/
//-------------------------------------------------------------------
Function STBSumVRPS( nValue )
Local oTotal := STFGetTot()		// Totalizador

Default nValue  	:= 0	

If lMVLJPRDSV // Verifica se esta ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas (RPS)
	If oTotal:HasField("L1_NOTFISRPS") //Verifica se o campo est� na estrutura do Model
		oTotal:SetValue( "L1_NOTFISRPS" , nValue + oTotal:GetValue("L1_NOTFISRPS") )
	EndIf
EndIf

Return Nil
