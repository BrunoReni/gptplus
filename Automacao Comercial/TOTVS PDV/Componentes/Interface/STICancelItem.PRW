#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STICANCELITEM.CH"
#INCLUDE "STPOS.CH" 

Static oLblProdDados	:= Nil					// Label pro dados

//-------------------------------------------------------------------
/*/{Protheus.doc} STICancelItem
Interface Cancelamento de Item

@param
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STICancelItem()

Local oTotal  		:= STFGetTot() 					// Recebe o Objeto totalizador
Local nTotalVend		:= oTotal:GetValue("L1_VLRTOT") // Valor total da venda 

If nTotalVend > 0 
	/* 
		Chamo workflow que avalia qual a forma de cancelamento,
		sendo que é possivel excluir qualquer item ou apenas o ultimo registrado.
 	*/
	STWChkCancel()
	STIBtnDeActivate()
Else
	STFMessage(ProcName(),"STOP",STR0008)  //"Nenhum item foi registrado!"
	STFShowMessage(ProcName())	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPanItCancel
Contexto Cancelamento de Item

@param   	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  oPanConsult			Painel Consulta de Produto  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIPanItCancel()

Local oPanelMVC		:= Nil					// Painel Principal
Local oPanGetCancel  := Nil				 	// Painel de Get de Consulta
Local oGetCancel		:= Nil					// TGet Cancelamento de Item
Local cGetProd		:= Space(40)			// Variável do Get
Local oReasons		:= Nil					// ListBox Seleção de Motivo de Cancelamento
Local oButton			:= Nil					// Botao "Consultar Produto"
Local oLblCab			:= Nil					// Label Cabecario
Local oLblItem		:= Nil					// Label Itens
Local oLblDados		:= Nil					// Label com a primeira coluna de dados
Local cDados			:= ""					// String da primeira coluna de dados
Local lMotVen			:= SuperGetMV( "MV_LJMVPE", Nil, .F. ) //Motivo de venda perdida
Local nPosVert		:= 0					// Posicao vertical
Local aReasons		:= {}					// Retorna Motivos de Venda Perdida para seleção
Local aDataReasons	:= STDRFLSGet()		// Armazena Motivos de Venda Perdida Cadastrados
Local nI				:= 0					// Contador
Local nCol				:= 0					//Coordenada horizontal
Local nLargura		:= 0					//Largura
Local nTamAltListBox	:= 0					//Tamanho: Altura do ListBox
Local oButCan			:= Nil 				//Botao cancelar 
Local cLabel			:= ""
Local nTpPesquisa		:= SuperGetMv("MV_LJTPESQ",, 1) 		//Define tipo de pesquisa no cancelamento do produto, 0 sera por Numero do Item
Local lCancel			:= .T.				// indica que eh cancelamento para a pesquisa de produto, assim a pesquisa de produto nao pedira peso para produto balanca

oPanelMVC		:= STIGetPanel()		// Painel Principal
oPanGetCancel := TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) // Painel de Get de Consulta
nPosVert		:= oPanelMVC:nHeight/3.365
nCol			:= (oPanGetCancel:nWidth / 2) * 0.03			//Coordenada horizontal
nLargura		:= (oPanGetCancel:nWidth / 2) - (2 * nCol)	//Largura
nTamAltListBox	:= oPanelMVC:nHeight * 0.11						//Tamanho: Altura do ListBox

cLabel := iif(nTpPesquisa==1,STR0017,STR0010)  //  STR0017 =="Produto" STR0010 =="Número do Item"
/*
	Objetos
*/
oLblCab := TSay():New(POSVERT_CAB,POSHOR_1,{||STR0009},oPanGetCancel,,,,,,.T.,,,,) //"Venda > Cancelamento de Item"
oLblCab:SetCSS( POSCSS (GetClassName(oLblCab), CSS_BREADCUMB )) 

oLblItem := TSay():New(POSVERT_LABEL1,POSHOR_1,{||cLabel},oPanGetCancel,,,,,,.T.,,,,) 
oLblItem:SetCSS( POSCSS (GetClassName(oLblItem), CSS_LABEL_FOCAL )) 
                                                        
oGetCancel	:= TGet():New(	POSVERT_GET1,POSHOR_1,{|u| If(PCount()>0,cGetProd:=u,cGetProd)}, ;
							oPanGetCancel,150,ALTURAGET,,,,,,,,.T.,,,,,,,,,,"cGetProd")
oGetCancel:SetCSS( POSCSS (GetClassName(oGetCancel), CSS_GET_FOCAL )) 

cDados := STR0012+CRLF+CRLF+STR0013+CRLF+CRLF+STR0014+CRLF+CRLF+STR0015  // "Item no." + "Código" + "Descrição do Produto" + "Qtd x Preço unitário = Total do Item" 
							
oLblDados:= TSay():New(POSVERT_LABEL2,POSHOR_1,{||cDados},oPanGetCancel,,,,,,.T.,,,,100)
oLblDados:SetCSS( POSCSS (GetClassName(oLblDados), CSS_LABEL_FOCAL )) 


oGetCancel:bGotFocus := { ||  STWReaderFocus(.T.) }
oGetCancel:bLostFocus := { ||  STWReaderFocus(.F.),STIShowProdData(cGetProd,oPanGetCancel,lCancel),oButton:SetFocus() }

oButton		:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0007,oPanGetCancel,{ || IIf(STWItemCancel(cGetProd , oReasons,lCancel ),(oLblProdDados := Nil,STIRegItemInterface()),Nil) }, ; //"Cancelar Item"
								LARGBTN,ALTURABTN,,,,.T.) 
oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL )) 

oButCan	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_1,STR0016,oPanGetCancel,{|| STIRegItemInterface() }, ;  //"Não Cancelar"
							LARGBTN,ALTURABTN,,,,.T.,,,,{||.T.})
oButCan:SetCSS( POSCSS (GetClassName(oButCan), CSS_BTN_NORMAL )) 
oButCan:bLostFocus := {|| oButton:SetFocus() } // Tratamento para não perder o foco do Cancelar Item

oGetCancel:SetFocus()

If GetFocus() <> oGetCancel::HWND
    oGetCancel:SetFocus()
Endif

/*	Motivo de Nao Venda */
If lMotVen
	
	For nI := 1 To Len(aDataReasons)
	
		AADD( aReasons , aDataReasons[nI][1] + " - " + UPPER(aDataReasons[nI][2]) )

	Next nI
	
	If Len(aReasons) > 0 .AND. ValType(oPanGetCancel) <> "U"
		
		oReasons := TListBox():Create(oPanGetCancel, POSVERT_GET3*1.20, POSHOR_1, Nil, aReasons, nLargura, nTamAltListBox,,,,,.T.,,/*{ || STISetReason(oReasons), oButton:SetFocus() }*/)	
		oReasons:SetCSS( POSCSS (GetClassName(oReasons), CSS_LISTBOX )) 
		
	EndIf
	
	
EndIf
								
oLblProdDados := Nil
								
Return oPanGetCancel

//-------------------------------------------------------------------
/*{Protheus.doc} STIShowProdData
Mostra na tela as informacoes do item que sera cancelado

@param   	
@author  Vendas & CRM
@version P12
@since   23/05/2013
@return  Nil  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STIShowProdData(cGetProd,oPanGetCancel,lCancel)

Local oPanelMVC	    := STIGetPanel()		// Painel Principal
Local aLines        := FwSaveRows()	// Array de linhas
Local oModelCesta   := STDGPBModel()			// Model da cesta
Local nItem			:= 0
Local cProdData     := ""
Local cMoedaSimb    := SuperGetMV( "MV_SIMB" + Str(STBGetCurrency() ,1 ) ) 	// Simbolo da moeda corrente
Local lContinua     := .F.

DEFAULT cGetProd := ""	
DEFAULT lCancel 	:= .F. // indica que eh cancelamento para a pesquisa de produto, assim a pesquisa de produto nao pedira peso para produto balanca

nItem				:= STBCnFindItem( cGetProd ,lCancel) //Procura Cod. produto recebido pois pode ser um codigo de barras , e passa indicador se vem ou nao de um cancelamento

oModelCesta := oModelCesta:GetModel("SL2DETAIL")

If !Empty(cGetProd) .AND. nItem > 0
	lContinua := STBValCnItem( nItem , oModelCesta )
	
	If lContinua
		
		oModelCesta:GoLine(nItem)
		cProdData := AllTrim(oModelCesta:GetValue("L2_ITEM"))+CRLF+CRLF
		cProdData += AllTrim(oModelCesta:GetValue("L2_PRODUTO"))+CRLF+CRLF
		cProdData += AllTrim(oModelCesta:GetValue("L2_DESCRI"))+CRLF+CRLF
		cProdData += AllTrim(Str(oModelCesta:GetValue("L2_QUANT")))+" x "+;
					cMoedaSimb+AllTrim(Transform(oModelCesta:GetValue("L2_VRUNIT"),PesqPict("SL2","L2_VRUNIT")))+" = "+;
					cMoedaSimb+AllTrim(Transform(oModelCesta:GetValue("L2_VLRITEM"),PesqPict("SL2","L2_VLRITEM")))
		
		If ValType(oLblProdDados) <> "U"
			oLblProdDados:SetText(cProdData)
		Else
			oLblProdDados:= TSay():New(POSVERT_LABEL2,POSHOR_1+130,{||cProdData},oPanGetCancel,,,,,,.T.,,,,100)
			oLblProdDados:SetCSS( POSCSS (GetClassName(oLblProdDados), CSS_LABEL_FOCAL )) 
		EndIf 
	EndIf
EndIf

FwRestRows(aLines)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STILastItCancel
Interface de Cancelamento do Ultimo Item

@param   	
@author  Vendas & CRM
@version P12
@since   22/05/2013
@return  oPanGetCancel			Painel Cancelamento de Produto  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STILastItCancel()
Local oPanelMVC		:= STIGetPanel()										// Painel Principal
Local oPanGetCancel := TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) // Painel do Cancelamento
Local oLblCab		:= Nil													// Label do Cabecalho
Local oModelCesta 	:= STDGPBModel()										// Model da cesta
Local cMoedaSimb	:= SuperGetMV( "MV_SIMB" + Str(STBGetCurrency() ,1 ) ) 	// Simbolo da moeda corrente
Local oLblDados1	:= Nil													// Label com a primeira coluna de dados
Local oLblDados2	:= Nil													// Label com a segunda coluna de dados
Local cDados1		:= ""													// String da primeira coluna de dados
Local cDados2		:= ""													// String da segunda coluna de dados

oLblCab:= TSay():New(POSVERT_CAB,POSHOR_1,{||STR0011},oPanGetCancel,,,,,,.T.,,,,) //"Apenas o último item poderá ser cancelado. Confirma?"
oLblCab:SetCSS( POSCSS (GetClassName(oLblCab), CSS_BREADCUMB )) 

oModelCesta := oModelCesta:GetModel("SL2DETAIL")
oModelCesta:GoLine(oModelCesta:Length()) 

/* Item */
cDados1 := STR0012+CRLF+CRLF  //"Item nº"
cDados2 := AllTrim(oModelCesta:GetValue("L2_ITEM"))+CRLF+CRLF

/* Código */
cDados1 += STR0013+CRLF+CRLF  //"Código"
cDados2 += AllTrim(oModelCesta:GetValue("L2_PRODUTO"))+CRLF+CRLF

/* Descrição */
cDados1 += STR0014+CRLF+CRLF  //"Descrição do Produto"
cDados2 += AllTrim(oModelCesta:GetValue("L2_DESCRI"))+CRLF+CRLF

/* Quantidade x Preço unitário = Total */
cDados1 += STR0015  //"Qtd x Preço unitário = Total do Item"
cDados2 += AllTrim(Str(oModelCesta:GetValue("L2_QUANT")))+" x "+;
			cMoedaSimb+AllTrim(Transform(oModelCesta:GetValue("L2_VRUNIT"),PesqPict("SL2","L2_VRUNIT")	))+" = "+;
			cMoedaSimb+AllTrim(Transform(oModelCesta:GetValue("L2_VLRITEM"),PesqPict("SL2","L2_VLRITEM")))

oLblDados1:= TSay():New(POSVERT_LABEL1,POSHOR_1,{||cDados1},oPanGetCancel,,,,,,.T.,,,,100)
oLblDados1:SetCSS( POSCSS (GetClassName(oLblDados1), CSS_LABEL_FOCAL )) 

oLblDados2:= TSay():New(POSVERT_LABEL1,POSHOR_1+130,{||cDados2},oPanGetCancel,,,,,,.T.,,,,100)
oLblDados2:SetCSS( POSCSS (GetClassName(oLblDados2), CSS_LABEL_FOCAL )) 

oBtnOk := TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0007,oPanGetCancel,{|| STWLastCancel(),STIRegItemInterface() }, ; //"Cancelar Item"
							LARGBTN,ALTURABTN,,,,.T.)
							
oBtnCa := TButton():New(POSVERT_BTNFOCAL,POSHOR_1,STR0016,oPanGetCancel,{ || STIRegItemInterface()}, ; //"Não Cancelar"
							LARGBTN,ALTURABTN,,,,.T.)	

oBtnOk:SetCSS( POSCSS (GetClassName(oBtnOk), CSS_BTN_FOCAL )) 
oBtnCa:SetCSS( POSCSS (GetClassName(oBtnCa), CSS_BTN_ATIVO )) 

Return oPanGetCancel

