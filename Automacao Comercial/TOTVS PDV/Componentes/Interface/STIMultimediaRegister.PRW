#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "POSCSS.CH"  
#INCLUDE "STIMULTIMEDIAREGISTER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STIMultiMedia
Interface Registro de M�dia

@param   
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  Nil 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIMultiMedia()            

Local aMidias			:= STDMRGet()						// Armazena Midias Cadastradas

If Len(aMidias) > 0

	STIExchangePanel( { || STIPanMultiMedia() } )

Else

	STFMessage("STIMultimedia","STOP",STR0001) //"N�o existe nenhum registro de m�dia cadastrado"
	STFShowMessage("STIMultimedia","STOP",STR0001)	 //"N�o existe nenhum registro de m�dia cadastrado"

EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STIPanMultiMedia
Contexto Registro de M�dia

@param   	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  oPanMultiMedia			Painel Registro de M�dia
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIPanMultiMedia()

Local oPanMultiMedia	:= Nil					// Painel Registro de M�dia
Local oPanGetMedia	:= Nil					// Painel Get Sele��o de Midia
Local oPanBtnSale  	:= Nil					// Painel de Bot�es da Venda
Local oMedia			:= Nil					// ListBox para Sele��o de M�dia
Local oButton			:= Nil					// Botao "Adicionar Midias"
Local aMidias			:= {}					// Armazena Midias para sele��o
Local oPanelMVC		:= STIGetDlg() 			// Dialog da tela principal

/*/
	T�tulo - "Or�amento"
/*/
Local nPosLb1Alt		:= oPanelMVC:nHeight/2 * 0.02 //Posicao: Altura
Local nPosLb1Hoz		:= oPanelMVC:nWidth/2 * 0.039 //Posicao: Horizontal
/*/
	T�tulo - "Sele��o de M�dia"
/*/
Local nPosLb2Alt		:= (oPanelMVC:nHeight/2 * 0.02) * 3.7 //Posicao: Altura
Local nPosLb2Hoz		:= oPanelMVC:nWidth/2 * 0.039 //Posicao: Horizontal
/*/
	ListBox
/*/
Local nLisVerPerc		:= 6 					// Pencentual de Posi��o Vertical do ListBox
Local nLisHorPerc		:= 0.039				// Pencentual de Posi��o Horizontal do ListBox
Local nLisHeiPerc		:= 0.11				// Percentual de Altura do ListBox

/*/
	Bot�o "Adicionar M�dia"
/*/
Local nBtnWidPerc		:= oPanelMVC:nWidth/2 * 0.25			// Percentual de Largura do Bot�o "Adicionar M�dia"
Local nBtnHeiPerc		:= oPanelMVC:nHeight/2 * 0.07			// Percentual de Altura do Bot�o "Adicionar M�dia"
Local nBtnVerPerc		:= (oPanelMVC:nHeight/2 * 0.02) * 14				// Percentual da Posi��o Vertical do Bot�o "Adicionar M�dia"
Local nBtnHorPerc		:= oPanelMVC:nWidth/2 * 0.40			// Percentual da Posi��o Horizontal do Bot�o "Adicionar M�dia"
/*/
	Bot�o "Cancelar"
/*/
Local nBtnCWidPerc		:= oPanelMVC:nWidth/2 * 0.25			// Percentual de Largura do Bot�o "Adicionar M�dia"
Local nBtnCHeiPerc		:= oPanelMVC:nHeight/2 * 0.07			// Percentual de Altura do Bot�o "Adicionar M�dia"
Local nBtnCVerPerc		:= (oPanelMVC:nHeight/2 * 0.02) * 14				// Percentual da Posi��o Vertical do Bot�o "Adicionar M�dia"
Local nBtnCHorPerc		:= oPanelMVC:nWidth/2 * 0.71			// Percentual da Posi��o Horizontal do Bot�o "Adicionar M�dia"
/*/
	Panel 
/*/
Local nPosPnlHoz := ((oPanelMVC:nHeight/2)/2 * 0.2) + 135 //Posicao: horizontal do painel


/*/
	Panel Get de M�dia
/*/
oPanGetMedia := TPanel():New(nPosPnlHoz,00,"",Nil,,,,,,(oPanelMVC:nWidth/2),(oPanelMVC:nHeight/2) * 0.60)
oPanGetMedia:SetCSS( POSCSS (GetClassName(oPanGetMedia), CSS_PANEL_CONTEXT )) 

/*/
	Busca M�dias Cadastradas para sele��o
/*/
aMidias := STIGetMedias()

/*/
	Objetos
/*/
oSay1 := TSay():New(nPosLb1Alt,nPosLb1Hoz,{||STR0002},oPanGetMedia,,,,,,.T.,,,,) //"Vendas > Registro de M�dia"
oSay2 := TSay():New(nPosLb2Alt,nPosLb1Hoz,{||STR0003},oPanGetMedia,,,,,,.T.,,,,) //"Sele��o de M�dia"
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_BREADCUMB )) 
oSay2:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_FOCAL )) 

oMedia := TListBox():Create(oPanGetMedia, (oPanelMVC:nHeight/2 * 0.02) * nLisVerPerc, oPanelMVC:nWidth/2 * nLisHorPerc, Nil, aMidias, ( oPanelMVC:nWidth/2  - (2*nLisHorPerc*oPanelMVC:nWidth/2) ),oPanelMVC:nHeight/2 * nLisHeiPerc,,,,,.T.,,{ || oButton:SetFocus() })
oMedia:SetCSS( POSCSS (GetClassName(oMedia), CSS_LISTBOX )) 

oButton := TButton():New(	nBtnVerPerc,nBtnHorPerc,STR0004,oPanGetMedia,{ || STISetMedia( oMedia ) }, ; //"Adicionar M�dia"
								nBtnWidPerc,nBtnHeiPerc,,,,.T.)  
oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL )) 


oBtnCanc := TButton():New(	nBtnCVerPerc,nBtnCHorPerc,STR0005,oPanGetMedia,{ || STIExchangePanel( { || STIPanItemRegister() } ) }, ; //"Cancelar"
								nBtnCWidPerc,nBtnCHeiPerc,,,,.T.)   
oBtnCanc:SetCSS( POSCSS (GetClassName(oBtnCanc), CSS_BTN_FOCAL )) 

oMedia:GoTop()
oMedia:SetFocus()
	
Return oPanGetMedia


//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetMedias
Busca Midias para sele��o na interface

@param   	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  aMidias				Retorna Midias para sele��o		
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGetMedias()

Local aMidias			:= {}				// Retorna Midias para sele��o		
Local aDataMidias		:= STDMRGet()		// Armazena Midias Cadastradas
Local nI				:= 0				// Contador
                               
/*/
	Prepara as m�dias cadastradas para sele��o
/*/
For nI := 1 To Len(aDataMidias)

	AADD( aMidias , cValToChar(nI) + " - " + aDataMidias[nI][2] )

Next nI

Return aMidias


//-------------------------------------------------------------------
/*/{Protheus.doc} STISetMedia
Adicionar Midia

@param   oMedia					ListBox Registro de Midia   	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STISetMedia( oMedia )

Local cCodMidia		:= ""	   		// C�digo de Midia a ser adicionado
Local aDataMidias	:= STDMRGet()	// Armazena Midias Cadastradas

Default oMedia		:= Nil

If oMedia <> Nil

	If oMedia:GetPos() > 0
		
		cCodMidia := aDataMidias[oMedia:GetPos()][1]
	
		STBMRSetMedia( cCodMidia )
		
		STIExchangePanel( { || STIPanItemRegister() } )
	
	Else
		
		STFMessage("STIMultiMedia","STOP",STR0006) //"M�dia n�o adicionada"
		STFShowMessage("STIMultiMedia")
		
	EndIf

EndIf

Return

