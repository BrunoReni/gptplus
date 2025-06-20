#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STIIMPORTSALE.CH"

#DEFINE CTXTSEL "[SELECIONADO] - "

Static oButton 			:= Nil	//Objeto do button
Static oReasons			:= Nil 	//ListBox Sele��o de Motivo de Cancelamento
Static aOptionSales		:= {}	//Armazena op��es de ir�amento buscadas
Static aViewOptionsSales:= {} 	//Armazena op��es de pagamento para apresenta��o e sele��o na view
Static oSay3			:= Nil	//Label da importacao
Static aGetOrc			:= {}	//Grava o orcamento que esta sendo importado

//-------------------------------------------------------------------
/*/{Protheus.doc} STIImportSale
Interface Importa��o de Or�amento

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIImportSale()
Local cMsg		:= ""
Local lVPProd 	:= SuperGetMv("MV_LJVPPRO",,.F.) //Permite vender Vale Presente e produtos na mesma venda 
Local lContinua := .T.

//Tratativa para LGPD
If ExistFunc("LjPDAcesso")
	lContinua := LjPDAcesso({"L1_NOMCLI","L1_CGCCLI"}) //Verifica se o usu�rio pode acessar uma determinada rotina devido a regra de prote��o de dados.
EndIf

If lContinua

	lContinua := !STBExistVP() .OR. lVPProd

	If lContinua
		
		lContinua := STBISMultSales() //Valida se esta liberado para importar orcamento

		//Valida se esta liberado para importar orcamento
		If lContinua
			STIExchangePanel( { || STIPanImportSale(@cMsg) } )
			STIChangeCssBtn('oBtnOrc')
			
			If !Empty(cMsg)
				STFMessage("STIImportSale", "STOP", cMsg)
				STFShowMessage("STIImportSale")
				LjGrvLog("Importa_Orcamento:STIImportSale", cMsg)
			EndIf	
		Else
			STFMessage("STIImportSale", "STOP", STR0008 ) // "S� � possivel importar um or�amento por venda"
			STFShowMessage("STIImportSale")	
			LjGrvLog("Importa_Orcamento:STIImportSale", STR0008)	//"S� � possivel importar um or�amento por venda"
		EndIf
	Else
		STFMessage(ProcName(0),"STOP",STR0015) //"A venda do vale presente deve ser feita separada."
		STFShowMessage(ProcName(0))
		LjGrvLog("Importa_Orcamento:STIImportSale", STR0015)	//"A venda do vale presente deve ser feita separada."
	EndIf
	
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPanImportSale
Contexto Importa��o de Or�amento

@param   	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  oPanGetImportSale	Painel Importa��o de Or�amento 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIPanImportSale(cMsg)

Local oPanGetImportSale	:= Nil								// Painel Get busca de or�amento
Local oGet1				:= Nil								// Get Principal
Local oGet2				:= Nil								// Get Adicional
Local cGet1				:= ""								// Vari�vel do get de busca principal
Local cGet2				:= ""								// Vari�vel do Get de busca adicional
Local cField1			:= ""								// Campo de busca utilizado
Local cField2			:= ""								// Campo de busca adicional
Local oPanelMVC	 		:= STIGetPanel() 					// Painel principal
Local aField1			:= {}								// Armazena informa��e do campo de busca de or�amento
Local aField2			:= {}								// Armazena informa��e do campo adicional de busca de or�amento
Local nGetHeiPerc		:= 90								// Percentual da Altura do Get de Busca

Default cMsg := ""

/* Panel Get do Produto */
oPanGetImportSale := TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight/2))
oPanGetImportSale:SetCSS( POSCSS (GetClassName(oPanGetImportSale), CSS_PANEL_CONTEXT )) 

oSay1 := TSay():New(POSVERT_CAB,POSHOR_1,{||STR0001},oPanGetImportSale,,,,,,.T.,,,,) //"Vendas > Or�amento"
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_BREADCUMB )) 


/* Campo de busca principal*/
cField1 := AllTrim(SuperGetMv("MV_LJORCAM ",,""))	// Campo de busca principal

If Empty(cField1)  
	cField1 := IIF(STFGetCfg("lPafEcf") .OR. STFGetCfg("lPAFNFCE"),"L1_NUMORC","A1_CGC")
EndIf

aField1 := STDISSearchField(cField1)

/* Campo de busca adicional*/
If !STFGetCfg("lPafEcf") .OR. SuperGetMv("MV_LJORCAA ",,"") <> ""

	cField2 := AllTrim(SuperGetMv("MV_LJORCAA ",,"L1_NUM")) // Campo de busca adicional
	aField2 := STDISSearchField(cField2)

EndIf

If Len(aField1) > 0

	/* Primeiro Get */
	oSay3 := TSay():New(POSVERT_LABEL1,POSHOR_1,{||aField1[1]},oPanGetImportSale,,,,,,.T.,,,LARG_SAY,)
	oSay3:SetCSS( POSCSS (GetClassName(oSay3), CSS_LABEL_FOCAL )) 
	
	cGet1 := Space(aField1[5])
	
	oGet1 := TGet():New(POSVERT_GET1,POSHOR_1,{|u| If(PCount()>0,cGet1:=u,cGet1)}, oPanGetImportSale,nGetHeiPerc,,,/*bValid*/,,,,,,.T.,,,,,,,,,,"cGet1")
	oGet1:SetCSS( POSCSS (GetClassName(oGet1), CSS_GET_FOCAL ))
	
    oGet1:bLostFocus    := {|| Iif(ValType(oButton)== "O",oButton:SetFocus(),Nil) } //Tratamento para n�o perder o foco do Buscar Or�amento 
	
    oGet1:SetFocus()
    
    If GetFocus() <> oGet1:HWND
       oGet1:SetFocus()
    Endif    

	If Len(aField2) > 0
	
		/* Get Par�metro */
		oSay2 := TSay():New(POSVERT_LABEL2,POSHOR_1,{||aField2[1]},oPanGetImportSale,,,,,,.T.,,,LARG_SAY,)
		oSay2:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_FOCAL )) 
		
		cGet2	:= Space(aField2[5])
	
		oGet2	:= TGet():New(POSVERT_GET2,POSHOR_1,{|u| If(PCount()>0,cGet2:=u,cGet2)}, oPanGetImportSale,nGetHeiPerc,,,/*bValid*/,,,,,,.T.,,,,,,,,,,"cGet2")
		oGet2:SetCSS( POSCSS (GetClassName(oGet2), CSS_GET_FOCAL )) 
			
		/* Sem When*/
        oGet1:bLostFocus        := {|| IIf( !Empty(cGet1) , ;
        													( ;
        														IIf( !Empty(cGet2) , ;
        																			Eval( {|| cGet2 := Space(Len(cGet2)) , ;
                                    															STFMessage("STIImportSale", "STOP", STR0009) , ; //"S� � possivel buscar por 1 campo preenchido"
                                    															STFShowMessage("STIImportSale") } ) ;
                                    											, ),;
                                    						 	oButton:SetFocus() ;
                                    						) ;
                                    					 	,IIf( Empty(cGet2), ;
                                    											oGet2:SetFocus(),;
                                    		 									) ) }
        oGet2:bLostFocus    := {|| IIf( !Empty(cGet2) , ;
        												( ;
        													IIf( !Empty(cGet1) , ;
        																		Eval( {|| cGet1 := Space(Len(cGet1)) , ;
                                    														STFMessage("STIImportSale", "STOP", STR0009) , ; //"S� � possivel buscar por 1 campo preenchido"
                                    														STFShowMessage("STIImportSale") } ) ;
                                    										, ) ;
                                    						,oButton:SetFocus()   ;
                                    					);
			                                    		, IIf( Empty(cGet1), ;
			                                    						oGet1:SetFocus(),;
			                                    		 				) ) }
	
	EndIf   
	
	oButton := TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0002,oPanGetImportSale,{ || STIISSearch( oPanGetImportSale, oPanelMVC , cField1, cGet1 , cField2 , cGet2 ) }, ;  //"Buscar Or�amento"
									LARGBTN,ALTURABTN,,,,.T.)
	oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL )) 									
																																			
Else
	cMsg := STR0011 //"Erro na configura��o de busca. Verificar par�metro MV_LJORCAM."
	
EndIf

Return oPanGetImportSale


//-------------------------------------------------------------------
/*/{Protheus.doc} STIISSearch
Busca de Or�amento

@param   cGet2
@param   oPanGetImportSale
@param   oPanelMVC
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIISSearch( oPanGetImportSale, oPanelMVC , cField1, cGet1 , cField2 , cGet2 )

Local aAux				:= {}							// Armazena retorno fun��o temporariamente
Local lUserSelect		:= .F.		   					// Indica se or�amento deve ser selecionado
Local nLisHorPerc		:= 0.039						// Pencentual de Posi��o Horizontal do ListBox
Local nLisHeiPerc		:= 0.27							// Percentual de Altura do ListBox
Local aListOrc			:= {}							// Lista de orcamentos
Local cTextLabel		:= SuperGetMV("MV_LJORDESC",,"Codigo Orc.   -   Cliente  -   Valor")// Label para exibicao do listbox //"Codigo Orc.   -   Cliente  -   Valor"

STFCleanInterfaceMessage()

If Empty(cGet1) .AND. Empty(cGet2)
	
	STFMessage("STIImportSale", "STOP", STR0010 ) //"Campo de busca deve ser preenchido"
	STFShowMessage("STIImportSale")	
	LjGrvLog("Importa_Orcamento:STIImportSale",STR0010)	//"Campo de busca deve ser preenchido"
	
Else
	 
	/* Chamada Busca de op��es de or�amento */
	If !Empty(cGet1)
		MsgRun(STR0016,'Aguarde.....',{||aAux := STWISSearchOptions( cField1 , cGet1 )})	 //"Buscando Orcamentos"
	Else
		MsgRun(STR0016,'Aguarde.....',{||aAux := STWISSearchOptions( cField2 , cGet2 )})	 //"Buscando Orcamentos"					
	EndIf
	
	lUserSelect 	:= aAux[1]
	aOptionSales	:= aAux[2]
	
	/*
	Removido valida��o para importar or�amento direto quando era realizado
	busca atrav�s do n�mero do or�amento. Sistema esta apresentando erro ao 
	importar um or�amento filho (venda com retira posterior) gerado na retaguarda.
	*/

	/* Formata o array para exibicao do listbox */
	
	aListOrc := STIISFormOrc(aOptionSales)
			
	/* Alimenta o array aViewOptionsSales */
	STIISSetViewOptions( aOptionSales )
			
	If STFGetCfg("lPafEcf") .OR. STFGetCfg("lPAFNFCE")
	
		If SuperGetMv("MV_LJPRVEN",,.T.)
			cTextLabel := STR0012 // "Pr�-Venda   /   Cliente   /   Valor"
		Else
			cTextLabel := STR0013 // "DAV   /   Cliente   /   Valor"
		EndIf
			
	EndIf

	oSay3:SetText( cTextLabel )

	oSay3:CtrlRefresh()

	/* Cria listbox com os orcamentos para selecionar */
	oReasons := TListBox():Create(oPanGetImportSale, POSVERT_GET1, POSHOR_1, Nil, aListOrc, ( oPanelMVC:nWidth/2  - (2*nLisHorPerc*oPanelMVC:nWidth/2) ),oPanelMVC:nHeight/2 * nLisHeiPerc,,,,,.T.,,{|| STIMarkImport()} )	
	oReasons:SetCSS( POSCSS (GetClassName(oReasons), CSS_LISTBOX )) 
	oReasons:SetFocus()
			
	oBtn := TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0005,oPanGetImportSale,{ || MsgRun(STR0017,'Aguarde.....',{||STIFinishImp()}) }, ; //"Importar" //"Importanto Orcamento Selecionado"
											LARGBTN,ALTURABTN,,,,.T.)
	oBtn:SetCSS( POSCSS( GetClassName(oBtn), CSS_BTN_FOCAL ) )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STIISSetSales
Seta Or�amentos a importar

@param   aAllSales	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIISSetSales( aAllSales )

Default aAllSales	:= {}

ParamType 0 Var aAllSales As Array Default {}

aSetSale := aAllSales

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STIISFormOrc
Formata os orcamentos para apresenta�ao na tela 

@param   aOrcs
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIISFormOrc( aOrcs )

Local aListOrc 		:= {}					//Retorno dos orcamentos
Local nI			:= 0 					//Variavel de loop
Local nJ			:= 0					//Variavel Loop
Local nZ			:= 0					//Contador
Local cOrc			:= ""					//String a ser apresentada no LisBox
Local aFieldsAdd	:= STIISFieldsAdd()		//Campos a serem apresentados na interface
Local aFieldsInt	:= STIISParamFields(.F.)//Campos a apresentar na interface
Local aFieldValue	:= {}					//Corresponcia campo valor entre interface e o resultado da busca
Local nPos			:= 0
Local oCesta 		:= STDGPBModel()
Local cNumOrc		:= ""
Local aPEOrcs		:= {}

For nZ := 1 To Len(aFieldsInt)
	
	Do Case
	
		Case aFieldsInt[nZ] == "L1_NUM"
			 AADD( aFieldValue , { "L1_NUM" , 1 } )
		Case aFieldsInt[nZ] == "L1_NUMORC"
			AADD( aFieldValue , { "L1_NUMORC" , 2 } )
		Case aFieldsInt[nZ] == "A1_NOME"
			AADD( aFieldValue , { "A1_NOME" , 3 } )
		OtherWise
			AADD( aFieldValue , { aFieldsInt[nZ] , AScan( aFieldsAdd , { |x| x == aFieldsInt[nZ] } ) + 3 } ) // Adiciona 3 pq os 3 primeiros s�o padr�o:= NUM,NUMOR,NOME
				
	EndCase	
	
Next nZ

// Busca se ja foi importado ja algum or�amento, caso sim elimina do array
If STDPBLength("SL2") > 0
	oCesta := oCesta:GetModel("SL2DETAIL")
	For nZ := 1 To STDPBLength("SL2")
		oCesta:GoLine(nZ)
		If !oCesta:IsDeleted()
			cNumOrc := STDGPBasket( "SL2" , "L2_NUMORIG" , nZ )
			nPos := Ascan( aOrcs,{ |x| Alltrim(x[1]) == Alltrim(cNumOrc) } )
			If nPos > 0 
				ADel(aOrcs,nPos)
				ASize(aOrcs,len(aOrcs)-1)
			EndIf
		EndIf
	Next nZ
EndIf

If ExistBlock("STORDIIMPORT")//Ordena os or�amentos a serem importados.
	aPEOrcs := ExecBlock("STORDIIMPORT",.F.,.F.,{aOrcs})
	If ValType(aPEOrcs) == "A"
		aOrcs := aClone(aPEOrcs)	
	EndIf
Endif

For nI := 1 To Len(aOrcs)
	
	cOrc := ""

	For nJ := 1 To Len(aFieldsInt)
	
		nPos := AScan( aFieldValue , { |x| x[1] == aFieldsInt[nJ] } )
			
		If aFieldsInt[nJ] == "L1_VLRTOT"
			cOrc := cOrc + "R$ " //Colocar simbolo moeda	
			cOrc := cOrc + AllTrim(Str(Val(STIISConvertToStr(aOrcs[nI][aFieldValue[nPos][2]])),16,2))
		ElseIf aFieldsInt[nJ] == "A1_NOME"
			cOrc := cOrc + AllTrim(STIISConvertToStr(aOrcs[nI][aFieldValue[nPos][2]]) )
		Else
			cOrc := cOrc + STIISConvertToStr(aOrcs[nI][aFieldValue[nPos][2]])			
		EndIf						

		If nJ == Len(aFieldsInt)
		
			AADD( aOptionSales[nI] , cOrc )
			AADD( aListOrc , cOrc )
		Else
		
			cOrc := cOrc + ' - '
						
		EndIf
		
	Next nJ

Next nI
				
Return aListOrc


//-------------------------------------------------------------------
/*/{Protheus.doc} STIISSetViewOptions
Seta op�oes de or�amento para carregar no modelo depois de ativo

@param   aOptionSales	Op��es de or�amento buscados da retaguarda
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIISSetViewOptions( aOptionSales )

Default aOptionSales		:= {}

ParamType 0 Var aOptionSales As Array Default {}

aViewOptionsSales := aOptionSales

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} STIISAfterSelected
Seta op�oes de or�amento para carregar no modelo depois de ativo

@param   aOptionSales	Op��es de or�amento buscados da retaguarda
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIISAfterSelected()

Local lRet				:= .T.							// Retorno fun��o
Local nI				:= 0							// Variavel de loop
Local aSelectedSales	:= {}
Local lContinua 		:= .T.
Local lCFRetPos	 		:= .F. 							// Indica se faz somente a impressao do Cupom Fiscal devido ser uma finalizacao de venda com itens de "RETIRA POSTERIOR"
Local nPosImpOrc		:= 0							// Linha do or�amento na qual esta posicionado
Local aImported			:= {}
							
If Len(aViewOptionsSales) > 0

	nPosImpOrc := oReasons:GetPos() //Posi��o atual

	For nI := 1 To Len(aViewOptionsSales)
		oReasons:Select(nI) //Posiciona na linha
		If CTXTSEL $ oReasons:GetSelText()
			aAdd(aSelectedSales, {aViewOptionsSales[oReasons:GetPos(),1], aViewOptionsSales[oReasons:GetPos(),2],;
									aViewOptionsSales[oReasons:GetPos(),3], aViewOptionsSales[oReasons:GetPos(),4],;
									aViewOptionsSales[oReasons:GetPos(),5]}) // Armazena op��es de or�amento selecionadas
		EndIf
	Next
	
	If Len(aSelectedSales) == 0
		oReasons:Select(nPosImpOrc) //Posiciona na linha em que estava posicionado
		aSelectedSales	:= {{	aViewOptionsSales[oReasons:GetPos(),1], aViewOptionsSales[oReasons:GetPos(),2],;
									aViewOptionsSales[oReasons:GetPos(),3], aViewOptionsSales[oReasons:GetPos(),4],;
									aViewOptionsSales[oReasons:GetPos(),5]	}}	// Armazena op��es de or�amento selecionadas
	EndIf
	
EndIf							

/* Valida��es */
If Len(aSelectedSales) == 0
	
	lRet := .F.
	STFMessage("STIImportSale", "STOP", STR0006 ) //"Nenhum or�amento foi selecionado"
	STFShowMessage("STIImportSale")	
	LjGrvLog("Importa_Orcamento:STIISAfterSelected",STR0006)	//"Nenhum or�amento foi selecionado"
	
EndIf

/* Realizar importa��o */
If lRet
	
	/* Get dos or�amentos a partir das op��es selecionadas */
	aImported := STWISImpAllSelected( aSelectedSales , "S" )
	lContinua := aImported[1]
	
	IF lContinua .AND. len (aImported[5])>0 //Existe or�amento com erro e sem erro.
		STFMessage("STIImportSale", "YESNO", aImported[3]) //"Confirma a impress�o do cupom fiscal?"
		lContinua := STFShowMessage("STIImportSale")
	ElseIf !lContinua
		LjGrvLog("Importa_Orcamento:STIISAfterSelected","aImported  : ", aImported)
	EndIf

	LjGrvLog("Importa_Orcamento:STIISAfterSelected","lContinua  : ", lContinua)
	
	If lContinua
		/* Verifica se � finalizacao de venda de orcamento somente com itens de "RETIRA POSTERIOR", para imprimir o Cupom  Fiscal e Finalizar. */
		lCFRetPos := STBISRetPos(aImported[4][1][1])
		
		If lCFRetPos 
			STFMessage("STIImportSale", "YESNO", STR0014) //"Confirma a impress�o do cupom fiscal?"
			lContinua := STFShowMessage("STIImportSale")
		EndIf
	EndIf
	
	If lContinua		// Continua?
	
		If lCFRetPos
			
			LjGrvLog("Importa_Orcamento:STIISAfterSelected", "Chama a importa��o de Or�amento filho com apenas itens de Retira Posterior")
			//Chama a importa��o de Or�amento filho com apenas itens de Retira Posterior" (Imprime o Cupom direto e finaliza)
			STBISFinPos(aImported[4][1])

		Else
			
			/* Guarda o orcamento que esta sendo importado  */
			aGetOrc := aImported[4]
			
			//Verifico se tem permiss�o para alterar a forma de pagamento
			If STFGetCfg("lChangePay", .F.) 
				If MsgYesNo(STR0019,STR0020) //Deseja alterar as formas de pagamento?/Aten��o
					STIChangePay(@aGetOrc[1][3])
				EndIf
			EndIf
			
			/* Cadastra cliente na base local caso n�o exista */
			STBCadCli(aGetOrc)

			/* Chamar Importa��o direto */
			STWISRegSale( aImported[4] ) // aAllSales
			
			/* Atualiza interface */
			STIGridCupRefresh()
			
			/* Pagamento */
			//Nao utilizar nesse ponto o comando STICallPayment. Motivo: Utilizando o comando STWBtFimVnd o fluxo padrao para solicitar o CPF ser� respeitado  
			STWBtFimVnd()	//Rotina com tratamento padrao para finalizar a venda

			STIISSetViewOptions() // Zera statica	

		EndIf						 
	Else		
		If ExistFunc("STWGetMsg") .AND. !Empty(STWGetMsg())
			STFMessage("STIImportSale", "POPUP", STWGetMsg() )
			LjGrvLog("Importa_Orcamento:STIISAfterSelected", STWGetMsg())
		Else
			STFMessage("STIImportSale", "ALERT", STR0007 ) //"N�o foi poss�vel importar o or�amento"
			LjGrvLog("Importa_Orcamento:STIISAfterSelected",STR0007)	//"N�o foi poss�vel importar o or�amento"
		EndIf

		STFShowMessage("STIImportSale")	
		lRet := .F.		

	EndIf	
		
EndIf



Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} STIISFieldsAdd
Retorna campos adicionais que foram configurados a aparecer na view

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aFieldsAdd	Campos adicionais configurados a aparecer na view
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIISFieldsAdd()

Local aFieldsAdd	:= {}						// Retorno fun��o
Local aConfFields	:= STIISParamFields(.T.)	// Armazena todos os campos configurados para aparecer na interface
Local nI			:= 0						// Contador

For nI := 1 To Len(aConfFields)
	
	If !( aConfFields[nI] $ "L1_NUM|L1_NUMORC|A1_NOME" )
	
		AADD( aFieldsAdd , aConfFields[nI] )
		
	EndIf
	
Next nI

Return(aFieldsAdd)

//-------------------------------------------------------------------
/*/{Protheus.doc} STIFinishImp
Chama a rotina para pesquisar os orcamentos

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIFinishImp()
STIISAfterSelected()
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetOrc
Retorna o orcamento importado

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGetOrc()
Return aGetOrc


//-------------------------------------------------------------------
/*/{Protheus.doc} STIISConvertToStr
Converte valor passado para caractere

@param   xValeu 			Valor a ser convertido
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIISConvertToStr( xValue )

Do Case
	Case Valtype(xValue) == "N"
		cRet := AllTrim(Str(xValue))
	Case Valtype(xValue) == "C"
		cRet := xValue
	Case Valtype(xValue) == "D"
		cRet := DTOC(xValue)
	Case Valtype(xValue) == "L"
		If xValue
			cRet := "T"
		Else
			cRet := "F"
		EndIf
	Otherwise
		cRet := xValue
EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Retorna campos que vao aparecer na interface

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRetFields		Campos aparecer interface
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIISParamFields(lBusca)

Local cParam		:= Iif(lBusca,"L1_NUM/A1_NOME/L1_VLRTOT/L1_DESCONT/L1_JUROS" + IIF(SL1->(ColumnPos("L1_VLRJUR")) > 0 , "/L1_VLRJUR", "" ), "L1_NUM/A1_NOME/L1_VLRTOT")//CAMPOS PARA A BUSCA E PARA A INTERFACE
Local aRetFields	:= STRTOKARR ( cParam , "/" )		// Retorno Fun��o

If STFGetCfg("lPafEcf") .OR. STFGetCfg("lPafNFCE")
	If AScan( aRetFields , { |x| x == "L1_NUM" } ) > 0
		aRetFields[AScan( aRetFields , { |x| x == "L1_NUM" } )] := "L1_NUMORC"
	EndIf
Else
	If AScan( aRetFields , { |x| x == "L1_NUMORC" } ) > 0
		aRetFields[AScan( aRetFields , { |x| x == "L1_NUMORC" } )] := "L1_NUM"
	EndIf
EndIf

Return aRetFields

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Fun��o para limpar variavel estatica

@param   
@author  Varejo
@version P11.8
@since   20/01/2016
@return  .T.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIClrVar()

If Len(aGetOrc) > 0
	aGetOrc := {}
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIMarkImport
Fun��o marcar sele��o de multi or�amentos

@param   
@author  Varejo
@version P11.8
@since   20/01/2016
@return  .T.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STIMarkImport()
Local cTxtList	:= ""
Local nMax		:= 0

If !SuperGetMv( "MV_LJMLTOR" , NIl , .T. ) //Valida se esta liberado para importar orcamento
	STFMessage(ProcName(), "ALERT", STR0018 ) //"Sele��o de multiplos or�amentos desabilitada(MV_LJMLTOR)"
	STFShowMessage(ProcName())	
	LjGrvLog("Importa_Orcamento:STIMarkImport", STR0018)		//"Sele��o de multiplos or�amentos desabilitada(MV_LJMLTOR)"
Else
	If oReasons <> Nil
		cTxtList := oReasons:GetSelText()
		If CTXTSEL $ cTxtList //retira a sele��o.
			nMax := RAt(CTXTSEL,cTxtList)
			oReasons:Modify( SubStr(cTxtList, nMax+lEN(CTXTSEL)), oReasons:GetPos() )
		Else //coloca a sela��o
			oReasons:Modify( CTXTSEL + AllTrim(cTxtList) , oReasons:GetPos() )
		EndIf
	EndIf 
EndIf

Return .T.
