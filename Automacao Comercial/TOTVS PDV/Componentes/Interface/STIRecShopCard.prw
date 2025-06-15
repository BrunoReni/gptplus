#Include 'Protheus.ch'
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "POSCSS.CH"
#INCLUDE "STIRECSHOPCARD.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} STIRecShopCard

@param   
@author  Vendas & CRM
@version P11.7
@since   15/10/2012
@return  oMainPanel - Objeto contendo o painel principal de selecao de clientes.
*/
//-------------------------------------------------------------------

Function STIRecShopCard(cItemCode)

STIExchangePanel( { || STIPanRecSC(cItemCode) } )

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STIPanRecSC
Funcao responsavel pela criacao do Painel de recarga de Shop Card.

@author Vendas CRM
@since 26/04/2013
@version 11.80
@return oMainPanel - Objeto contendo o painel principal de selecao de clientes.
*/
//-------------------------------------------------------------------

Static Function STIPanRecSC(cItemCode)
Local oPanItCancel		:= Nil 							// Painel Cancelamento de Venda
Local oPanBtnSale  		:= Nil							// Painel de Bot�es da Venda
Local oPanelMVC  		:= STIGetPanel()				// Objeto do Panel onde a interface de selecao de clientes sera criada
Local oMainPanel 		:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) // Painel de Get de Consulta

Local nAltGets			:= oMainPanel:nHeight/2 * 0.04 					//Tamanho: Altura do Get

/*/
	T�tulo - "Recarga de Cart�o Fidelidade"
/*/
Local oLblCab			:= Nil							// Objeto do label "Recarga de Cart�o Fidelidade"
Local nSay1HorPerc		:= 0.015						// Percentual de Posi��o Horizontal do Say "Recarga de Cart�o Fidelidade"

/*
	Say - 'Num. Cart�o'
*/
Local oLblNumCart		:= Nil							// Objeto do label 'Num. Cart�o'
Local nSay2HorPerc		:= oMainPanel:nWidth/2 * 0.06	// Posicao horizontal do label oLblNumCart
Local nSay2VerPerc		:= oMainPanel:nHeight/2 * 0.06	// Posicao vertical do label oLblNumCart

/*/
	Get de 'Num. Cart�o'
/*/
Local oGetNumCart		:= Nil							// TGet 'Num. Cart�o'
Local cGetNumCart		:= Space(30)					// Vari�vel do Get
Local nHorNumCart		:= oMainPanel:nWidth/2 * 0.06	// Posi��o Horizontal do Get
Local nVerNumCart		:= oMainPanel:nHeight/2 * 0.13	// Posi��o Vertical do Get

/*/
	Say - "Valor do Saldo"
/*/
Local oLblSaldo			:= NIl							// Objeto do label "Valor do Saldo"
Local nSay3HorPerc		:= oMainPanel:nWidth/2 * 0.06	// Posi��o Horizontal do Say "Valor do Saldo"
Local nSay3VerPerc		:= oMainPanel:nHeight/2 * 0.20	// Posi��o Vertical do Say "Valor do Saldo"

/*/
	Get de "Valor do Saldo"
/*/
Local oGetSaldo			:= Nil							// TGet "Valor do Saldo"
Local cGetSaldo			:= 0							// Vari�vel do Get
Local nGetHorPerc		:= oMainPanel:nWidth/2 * 0.06	// Percentual da Posi��o Horizontal do Get
Local nGetVerPerc		:= oMainPanel:nHeight/2 * 0.27	// Percentual da Posi��o Vertical do Get

/*/
	Say - "Validade do Saldo"
/*/
Local oLblDtValid		:= NIl							// Objeto do label "Validade do Saldo"
Local nSay4HorPerc		:= oMainPanel:nWidth/2 * 0.32	// Posi��o Horizontal do Say "Validade do Saldo"
Local nSay4VerPerc		:= oMainPanel:nHeight/2 * 0.20	// Posi��o Vertical do Say "Validade do Saldo"

/*/
	Get de "Validade do Saldo"
/*/
Local oGetDtValid		:= Nil							// TGet Validade do Saldo
Local cGetDtValid		:= dDataBase+30					// Vari�vel do Get
Local nHorDtVld			:= oMainPanel:nWidth/2 * 0.32	// Posi��o Horizontal do Get
Local nVerDtVld			:= oMainPanel:nHeight/2 * 0.27	// Posi��o Vertical do Get

/*/
	Bot�o 'Confirmar'
/*/
Local oBtnOk			:= Nil							// Botao 'Confirmar'
Local nBtnOkLarg		:= oMainPanel:nWidth/2 * 0.25	// Largura do Bot�o 'Confirmar'
Local nBtnOkAlt			:= oMainPanel:nHeight/2 * 0.08	// Altura do Bot�o 'Confirmar'
Local nBtnOkVer			:= oMainPanel:nHeight/2 * 0.8	// Posi��o Vertical do Bot�o 'Confirmar'
Local nBtnOkHor			:= oMainPanel:nWidth/2 * 0.65	// Posi��o Horizontal do Bot�o 'Confirmar'

/*/
	Bot�o "Cancelar"
/*/
Local oBtnCa			:= Nil							// Botao "Cancelar"
Local nBtnCaLarg		:= oMainPanel:nWidth/2 * 0.25	// Largura do Bot�o "Cancelar"
Local nBtnCaAlt			:= oMainPanel:nHeight/2 * 0.08	// Altura do Bot�o "Cancelar"
Local nBtnCaVer			:= oMainPanel:nHeight/2 * 0.8	// Posi��o Vertical do Bot�o "Cancelar"
Local nBtnCaHor			:= oMainPanel:nWidth/2 * 0.1	// Posi��o Horizontal do Bot�o "Cancelar"

/*
	Posicoes do oCustomerPanel
*/
Local nCustPanHor		:= 15						// Posicao horizontal de oCustomerPanel
Local nCustPanVer		:= oMainPanel:nHeight/15	// Posicao vertical de oCustomerPanel
/*/
	Objetos
/*/

oLblCab:= TSay():New(000,oMainPanel:nWidth * nSay1HorPerc,{||STR0001},oMainPanel,,,,,,.T.,,,,) //"Recarga de Cart�o Fidelidade"

oLblCab:SetCSS( POSCSS(CSS_BREADCUMB) )

 /* Label e Get: Numero do Cartao */
oLblNumCart := TSay():New(nSay2VerPerc,nSay2HorPerc, {||STR0002}, oMainPanel,,,,,,.T.,,,,) //'Num. Cart�o'
oGetNumCart := TGet():New(nVerNumCart,nHorNumCart,{|u| If(PCount()>0,cGetNumCart:=u,cGetNumCart)},oMainPanel,,nAltGets,"@!",,,,,,,.T.,,,,,,,,,,"cGetNumCart")

oLblNumCart:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
oGetNumCart:SetCSS( POSCSS(CSS_GET_NORMAL) )

 /* Label e Get: Valor do Saldo */
oLblSaldo := TSay():New(nSay3VerPerc, nSay3HorPerc, {||STR0003}, oMainPanel,, ,,,,.T.,,,,) //'Valor do Saldo'
oGetSaldo := TGet():New(nGetVerPerc,nGetHorPerc,{|u| If(PCount()>0,cGetSaldo:=u,cGetSaldo)},oMainPanel,,nAltGets,"@E 99,999,999.99",,,,,,,.T.,,,,,,,,,,"cGetSaldo") 

oLblSaldo:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
oGetSaldo:SetCSS( POSCSS(CSS_GET_NORMAL) )

/* Label e Get: Validade do Saldo */
oLblDtValid := TSay():New(nSay4VerPerc, nSay4HorPerc, {||STR0004}, oMainPanel,, ,,,,.T.,,,,) //'Validade do Saldo'
oGetDtValid := TGet():New(nVerDtVld,nHorDtVld,{|u| If(PCount()>0,cGetDtValid:=u,cGetDtValid)},oMainPanel,,nAltGets,,,,,,,,.T.,,,,,,,,,,"cGetDtValid")

oLblDtValid:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
oGetDtValid:SetCSS( POSCSS(CSS_GET_NORMAL) )


/* Botoes Ok e Cancelar */
oBtnOk	:= TButton():New(	nBtnOkVer,nBtnOkHor,STR0005,oMainPanel,{ ||STIConfSCRecharge(cGetNumCart,cGetSaldo,cGetDtValid,cItemCode) }, ;
							nBtnOkLarg,nBtnOkAlt,,,,.T.) //'Confirmar'

oBtnCa	:= TButton():New(	nBtnCaVer,nBtnCaHor,STR0006,oMainPanel,{ || STIExchangePanel( { || STIPanItemRegister() } )}, ;
							nBtnCaLarg,nBtnCaAlt,,,,.T.) //'Cancelar'

oBtnOk:SetCSS(POSCSS(CSS_BTN_FOCAL))
oBtnCa:SetCSS(POSCSS(CSS_BTN_FOCAL))							

oGetNumCart:SetFocus()

Return oMainPanel

//-------------------------------------------------------------------
/*{Protheus.doc} STIConfSCRecharge


@author Vendas CRM
@since 26/04/2013
@version 11.80
@return oMainPanel - Objeto contendo o painel principal de selecao de clientes.
*/
//-------------------------------------------------------------------

Static Function STIConfSCRecharge(cGetNumCart,cGetSaldo,cGetDtValid,cItemCode)
Local lRet 		:= .F.
Local cCliCode	:= STDGPBasket("SL1","L1_CLIENTE")
Local cCliLoja	:= STDGPBasket("SL1","L1_LOJA")
Local cCliType	:= STDGPBasket("SL1","L1_TIPOCLI")

lRet := STWUpdShopCardFunds(cGetNumCart,cGetSaldo,cGetDtValid)

If lRet
	STWItemReg(	1, cItemCode, cCliCode, cCliLoja, 1, , , , , cCliType, ,  cGetSaldo)
	STICallPayment()
EndIf

Return lRet
