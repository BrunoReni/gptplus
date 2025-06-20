#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STICANCELSALE.CH"
#INCLUDE "STPOS.CH"

Static aCancel	:= {}		// Armazena informa�oes para cancelamento

//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetCancel
Recupera informa��es cancelamento

@param
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  aCancel					Retorna informa��es cancelamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGetCancel()

Return aCancel

//-------------------------------------------------------------------
/*/{Protheus.doc} STISetCancel
Adiciona informa��es cancelamento

@param   aInfCancel					Array com informa��es do cancelamento
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  aCancel					Retorna informa��es cancelamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STISetCancel( aInfCancel )

aCancel := aInfCancel

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STICancelSale
Chamada Interface Cancelamento de Venda

@param cGetCanc, string,    	 
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return nenhum  

/*/
//-------------------------------------------------------------------
Function STICancelSale(cGetCanc, cGetSerie)
Local lRet			:= .F. 		// Retorna se pode cancela a venda
Local aValidCancel	:= {}		// Armazena informa��es para cancelamento da venda
Local lEmitNFCe		:= STBGetNFCE()	// Indica se NFC-e
Local nTamDoc		:= 0
Local cAuxDoc		:= ""

Default cGetCanc 	:= ""



If !lEmitNFCe .AND. !Empty(cGetCanc)
	
	LjGrvLog( "STICancelSale", "Antes de capturar o DOC para avaliar o tamanho")
	STWGetReceipt( @cAuxDoc )
	LjGrvLog( "STICancelSale", "Depois de capturar o DOC para avaliar o tamanho",cAuxDoc)
	
	nTamDoc := Len(cAuxDoc)
	LjGrvLog( "STICancelSale", "Tamanho do DOC - provindo do ECF", nTamDoc)
	cGetCanc := StrZero( Val(cGetCanc), nTamDoc )	//tamanho fixo para COO do ECF
EndIf

aValidCancel:= STBCSCanCancel(cGetCanc,,cGetSerie)
lRet		:= aValidCancel[1]

If lRet
	/*/
		Seta Informa��es cancelamento
	/*/
	STISetCancel( aValidCancel )
	
	If !Empty(cGetCanc)
        STICancel(cGetCanc)
	Elseif !lEmitNFCe 
        STIExchangePanel( { || STIPanSaleCancel() } )
	EndIf

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STIGerCancel
Contexto Cancelar de Venda

@param   nenhum   
@author  Lucas Novais
@version P12
@since   29/08/2017
@return  nenhum
/*/
//-------------------------------------------------------------------
Function STIGerCancel()

Local aValidCancel	:= {}		// Armazena informa��es para cancelamento da venda
Local lRet			:= .F.

aValidCancel	:= STBCSCanCancel(,.F.)
lRet			:= aValidCancel[1]

If lRet
	STISetCancel( aValidCancel )
    STIExchangePanel( { || STIPanSaleCancel() } )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPanSaleCancel
Contexto Cancelar de Venda

@param nenhum   	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  oPanSaleCancel, objeto
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIPanSaleCancel()
Local oPanSaleCancel	:= Nil 				// Painel Cancelamento de Venda
Local oPanelMVC			:= STIGetPanel() 	// Painel Principal
Local oBtnConfirm		:= Nil				// Botao de confirma��o "Cancelar Venda"
Local oBtnCancel		:= Nil
Local cTotalSale		:= ""				// Valor total da venda
Local cNumberSale		:= ""				// Numera��o da venda
Local oGetDoc			:= Nil				// Get do Doc a ser cancelado
Local cMoedaSimb    	:= SuperGetMV( "MV_SIMB" + Str(STBGetCurrency() ,1 ) )	// Simbolo da moeda corrente
Local cPictTotalSale	:= PesqPict("SL1","L1_VLRTOT")
Local lEmitNfce			:= LjEmitNFCe()		 // Sinaliza se utiliza NFC-e
Local nGetHeiPerc		:= 90										// Percentual da Altura do Get de Busca	
Local oLblCancel		:= Nil										// Objeto Label do cancelamento
Local cGetCanc			:= Space(TamSX3("L1_DOC")[1])			// Conteudo inserido no Get de Cancelamento.
Local lSAT 				:= STFGetCfg("lUseSAT",.F.)
Local cDocAnt			:= ""   //Ultimo documento com Total
Local oSay1				:= NIL	//say 1 - Confirma o Cancelamento da Venda?"
Local oSay3				:= NIL //say 3 - "Num. da Venda
Local oSay4				:= NIL //say 4 - "Num. da Venda
Local oSay6				:= NIL //say 6 - "Valor Total da Venda"
Local oSay5				:= NIL //say 5 - "Valor Total da Venda"
Local cGetSerie			:= STFGetStation("SERIE")
Local oGetSerie			:= Nil
Local cSerConf			:= GetNewPar("MV_LOJANF","UNI")
Local lNFeActive		:= SuperGetMV("MV_FISNOTA", .F., .F.) .and. !Empty(cSerConf) .and. cSerConf <> "UNI

if lNFeActive .OR. lSAT 
	cGetCanc := STDLastSat("L1_DOC", @cGetSerie)
else
	cGetCanc := STDCSLastSale("L1_DOC", @cGetSerie) 
EndIf	

//Cancelamento RPS
If (lEmitNFCE .OR. lSAT) .AND. Empty(cGetCanc) .AND. Empty(cGetSerie) .AND. Len(aCancel)>=11 .AND. !Empty(aCancel[10]) .AND. !Empty(aCancel[11])
	cGetCanc	:= aCancel[10]
	cGetSerie	:= aCancel[11]
Endif 

/*/
	Panel Abertura de Caixa                  	
/*/
oPanSaleCancel := TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2)
oPanSaleCancel:bGotFocus := { ||  STWReaderFocus(.T.) }
oPanSaleCancel:bLostFocus := { ||  STWReaderFocus(.F.),STIShowProdData(cGetCanc,oPanSaleCancel,lCancel),oBtnConfirm:SetFocus() }

oSay1	:= TSay():New(POSVERT_CAB,POSHOR_1,{||STR0002},oPanSaleCancel,,,,,,.T.,,,,) //"Confirma o Cancelamento da Venda?"
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_BREADCUMB )) 

oBtnConfirm	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0008,oPanSaleCancel,;
							{ || IIF(ExistFunc("STBActionCancel"),STBActionCancel(cGetCanc,cGetSerie), .F. ) }, ; //"Cancelar Venda"
							LARGBTN,ALTURABTN,,,,.T.)
oBtnConfirm:SetCSS( POSCSS (GetClassName(oBtnConfirm), CSS_BTN_FOCAL ))

oBtnCancel := TButton():New(	POSVERT_BTNFOCAL,POSHOR_1,STR0009,oPanSaleCancel,{ || IIf(STIRInPay(oPanSaleCancel),STIRegItemInterface(),Nil) }, ; //"N�o Cancelar"
							LARGBTN,ALTURABTN,,,,.T.)
oBtnCancel:SetCSS( POSCSS (GetClassName(oBtnCancel), CSS_BTN_NORMAL ))

oBtnCancel:bLostFocus := {|| oBtnConfirm:SetFocus() } // Tratamento para n�o perder o foco do Cancelar VENDA

oBtnConfirm:SetFocus()

If lEmitNfce .AND. !STBCSIsProgressSale()

	//Preenche o DOC da ultima venda
	If !lSAT
		cGetCanc := aCancel[4]
		If Empty(cGetCanc) .AND. Len(aCancel) > 5
			If Len(aCancel)>=11 .AND. !Empty(aCancel[10]) .AND. !Empty(aCancel[11]) //Cancelamento RPS
				cGetCanc 	:= aCancel[10]   
				cGetSerie	:= aCancel[11]
			Else
				cGetCanc := aCancel[6]
			Endif 
		EndIf
	EndIf

	If !Empty(cGetCanc)
		cTotalSale := cMoedaSimb+AllTrim(Transform(STBCSTotalSale(.F.,;
														STDCSNum(cGetCanc, STFGetStation("PDV"),IIF((Len(aCancel) > 5 .AND. !Empty(aCancel[6]));
														.OR. (Len(aCancel) >=11 .AND. !Empty(aCancel[10]) .AND. !Empty(aCancel[11])),.T.,.F.),;
														 cGetSerie)),cPictTotalSale))
	EndIf
	
	oSay6 := TSay():New(POSVERT_GET1,POSHOR_2,{||cTotalSale},oPanSaleCancel,,,,,,.T.,,,,)
	oSay6:SetCSS( POSCSS (GetClassName(oSay6), CSS_LABEL_FOCAL ))
	
	If lNFeActive
		oLblCancel := TSay():New(POSVERT_LABEL1,POSHOR_1,{|| STR0012 },oPanSaleCancel,,,,,,.T.,,,,) //"Informe a s�rie e o n�mero do Documento Fiscal"
	Else
		oLblCancel := TSay():New(POSVERT_LABEL1,POSHOR_1,{|| STR0010 },oPanSaleCancel,,,,,,.T.,,,,) //"Informe o n�mero do Documento Fiscal"
	EndIf
	oLblCancel:SetCSS( POSCSS (GetClassName(oLblCancel), CSS_LABEL_FOCAL )) 	
	
	oGetSerie:= TGet():New(POSVERT_GET1,POSHOR_1,{|u| If(PCount()>0,cGetSerie:=u,cGetSerie)},;
						oPanSaleCancel,nGetHeiPerc-70,,,/*bValid*/,,,,,,.T.,,,,,,,!lNFeActive,,,"cGetSerie")
	oGetSerie:SetCSS( POSCSS (GetClassName(oGetSerie), CSS_GET_FOCAL ))

	oGetDoc	:= TGet():New(POSVERT_GET1,POSHOR_1 + 30,{|u| If(PCount()>0,cGetCanc:=u,cGetCanc)},;
						oPanSaleCancel,nGetHeiPerc,,,/*bValid*/ ,,,,,,.T.,,,,,,,,,,"cGetCanc")
	oGetDoc:SetCSS( POSCSS (GetClassName(oGetDoc), CSS_GET_FOCAL ))
	cDocAnt := cGetCanc

	oSay5 := TSay():New(POSVERT_LABEL1,POSHOR_2,{||STR0007},oPanSaleCancel,,,,,,.T.,,,,) //"Valor Total da Venda"
	oSay5:SetCSS( POSCSS (GetClassName(oSay5), CSS_LABEL_FOCAL )) 
	
 	oGetDoc:bLostFocus := { || IF( cDocAnt <> cGetCanc, ;
 														(    IIF( !Empty(cGetCanc), ;
 																cTotalSale := cMoedaSimb+AllTrim(Transform(STBCSTotalSale(.F.,STDCSNum(cGetCanc, STFGetStation("PDV"))),cPictTotalSale)),;
 																""), ;
 																oSay6:Refresh(), cDocAnt := cGetCanc;
 														 ),;
 								  ),;
 								oBtnConfirm:SetFocus() }

	If lNFeActive
		oGetSerie:SetFocus() //Tratamento para n�o perder o foco no campo S�rie
	Else
		oGetDoc:SetFocus() //Tratamento para n�o perder o foco no campo N�mero do Documento Fiscal
	EndIf		
	
Else
	
	If !lEmitNfce .Or. lSAT
		/*/
			Numera��o da Venda
		/*/
		cNumberSale := STBCSNumberSale(aCancel[2],aCancel[4])
		
		oSay3 := TSay():New(POSVERT_LABEL1,POSHOR_1,{||STR0006},oPanSaleCancel,,,,,,.T.,,,,) //"Num. da Venda"
		oSay3:SetCSS( POSCSS (GetClassName(oSay3), CSS_LABEL_FOCAL ))
		
		oSay4 := TSay():New(POSVERT_GET1,POSHOR_1,{||cNumberSale},oPanSaleCancel,,,,,,.T.,,,,)
		oSay4:SetCSS( POSCSS (GetClassName(oSay4), CSS_LABEL_FOCAL )) 
	
	EndIf	
	/*/
		Valor total da venda
	/*/
	cTotalSale := cMoedaSimb+AllTrim(Transform(STBCSTotalSale(aCancel[2],aCancel[5]),cPictTotalSale))

	oSay5 := TSay():New(POSVERT_LABEL1,POSHOR_2,{||STR0007},oPanSaleCancel,,,,,,.T.,,,,) //"Valor Total da Venda"
	oSay5:SetCSS( POSCSS (GetClassName(oSay5), CSS_LABEL_FOCAL )) 
	
	oSay6 := TSay():New(POSVERT_GET1,POSHOR_2,{||cTotalSale},oPanSaleCancel,,,,,,.T.,,,,)
	oSay6:SetCSS( POSCSS (GetClassName(oSay6), CSS_LABEL_FOCAL )) 
	oBtnConfirm:SetFocus() 

EndIf                                                                 
								
Return oPanSaleCancel


//-------------------------------------------------------------------
/*/{Protheus.doc} STICanCancel
Valida��o Interface Cancelar Venda

@param
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  lRet						Retorna se pode cancela a venda
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STICanCancel()
Local lRet			:= .F. 			// Retorna se pode cancela a venda
Local cPergunte		:= ""			// Armazena mensagem de confirma��o
Local aValidCancel	:= {}			// Armazena informa��es para cancelamento da venda

aValidCancel	:= STBCSCanCancel()
lRet			:= aValidCancel[1]

If lRet
	/*/
		Seta Informa��es cancelamento
	/*/
	STISetCancel( aValidCancel )
		
	/*/                                           
		Chamada Pergunte Wizard
	/*/
	
	cPergunte := STBCSQuestion( aCancel[2] , Nil , aCancel[4] )
	
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STICSExit
Aborta Cancelamento de Venda

@param   oCancel			ListBox de Confirma��o de Cancelamento
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STICSExit()

/*/
	Limpa vari�vel
/*/
STISetCancel( {} )

STIExchangePanel( { || STIPanItemRegister() } )

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STICancel
Acionado Cancelamento de Venda

@param   
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STICancel(cGetCanc,cNFisCanc)
Local aInfCancel	:= {}							// Armazena informa��es cancelamento
Local lUseSat		:= STFGetCfg("lUseSAT", .F.)	//Utiliza SAT
Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Local lNFeAtv		:= .F.
Local lUsaPD		:= .F.
Local lDocRPS 		:= .F.  //Cancelamento RPS

Default cGetCanc := ""

aInfCancel	:= STIGetCancel()
lNFeAtv		:= len(aInfCancel) > 6
lUsaPD		:= len(aInfCancel) >= 9
lDocRPS		:= Len(aInfCancel) >= 11 .AND. !Empty(aInfCancel[10]) .AND.  !Empty(aInfCancel[11])

If !lUseSat
	STWCancelSale( .F.			, ;			// For�a cancelamento?
				aInfCancel[2]	, ;			// Venda em andamento?
				aInfCancel[3]	, ;			// Superior que autorizou cancelamento
				aInfCancel[4]	, ;			// Numero Doc a Cancelar (L1_DOC)
				aInfCancel[5]	, ;			// Numera��o venda a cancelar (L1_NUM)
				, ;
				, ;
				, ;
				iif( lNFeAtv, aInfCancel[7],"") ,;				//-- TBC-GO Serie da nota
				iif(lUsaPD,aInfCancel[8],.F.)   ,;				// -- Usa CC/CD
				iif(lUsaPD,aInfCancel[9],.F.)   ,;				// -- Usa PD
				lDocRPS )
ElseIf lDocRPS
	STWCancelSale( .F.				, ;		// For�a cancelamento?
					aInfCancel[2]	, ;		// Venda em andamento?
					aInfCancel[3]	, ;		// Superior que autorizou cancelamento
					aInfCancel[10]	, ;		// Numero Doc a Cancelar (L1_DOCRPS)
					aInfCancel[5]	, ;		// Numera��o venda a cancelar (L1_NUM)
					.F.				, ;
					cNFisCanc		, ;
					, ;
					iif( lNFeAtv, aInfCancel[11],"") ,;			//-- L1_SERRPS
					iif(lUsaPD,aInfCancel[8],.F.)   ,;			// -- Usa CC/CD
					iif(lUsaPD,aInfCancel[9],.F.) 	,;			// -- Usa PD
					lDocRPS )		
Else 
	STWCancelSale( .F.				, ;		// For�a cancelamento?
					aInfCancel[2]	, ;		// Venda em andamento?
					aInfCancel[3]	, ;		// Superior que autorizou cancelamento
					aInfCancel[4]	, ;		// Numero Doc a Cancelar (L1_DOC)
					aInfCancel[5]	, ;		// Numera��o venda a cancelar (L1_NUM)
					.F.				, ;
					cNFisCanc		, ;
					, ;
					iif( lNFeAtv, aInfCancel[7],"") ,;			//-- TBC-GO Serie da nota	
					iif(lUsaPD,aInfCancel[8],.F.)   ,;			// -- Usa CC/CD
					iif(lUsaPD,aInfCancel[9],.F.)   ,;			// -- Usa PD
					lDocRPS )
EndIf					

If !lAutomato // variavel de controle do Robo 
	STIGridCupRefresh() // Sincroniza a Cesta com a interface

	STIRegItemInterface()
Endif

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STIRInPay
Retorna para a interface de pagamento

@param   oPanSaleCancel , objeto , objeto da tela de cancelamento
@author  julio.nery
@version P12
@since   06/02/2017
@return  lRet, l�gico, se executa a a��o do bot�o ou sai sem executar
/*/
//-------------------------------------------------------------------
Function STIRInPay(oPanSaleCancel)
Local lRet		:= .T.

If ExistFunc("STIVerCTef") .And. !STIVerCTef(.F.)
	oPanSaleCancel:Hide()
	oPanSaleCancel:= Nil
	lRet := .F.
	STIPayment(.T.)
EndIf

Return lRet
