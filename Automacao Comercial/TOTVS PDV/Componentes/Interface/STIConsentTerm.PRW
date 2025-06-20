#Include 'TOTVS.ch'
#INCLUDE "STPOS.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STIConsentTerm.CH"

/*/
{Protheus.doc} STIConsentTerm

Fun��o responsavem por criar o texto que ser� exibido no termo de consentimento

@type function
@author Lucas Novais (lnovais)
@since 20/09/2019
@version P12.1.25
@return Nil, Nulo

/*/

Function STIConsentTerm()

Local lLjTermCo 	:= ExistBlock("LjTermCo")   // Indica se ponto de entrada LjTermCo esta compilado no RPO
Local cTextHtml     := ""                       // Texto contendo informa��es presentes no Termo.

/* Template Padr�o do termo de consentimento */
cTextHtml += '<br>'
cTextHtml += '<font size="10" color="black" >' + STR0001 + '</font><br/>' //"Termo de consentimento"
cTextHtml += '<br>'
cTextHtml += '<br>'
cTextHtml += '<font size="5" color="#424242">' + STR0002 + '</font><br/>'//"Informar ao cliente que os dados pessoais cadastrados ser�o utilizados com as finalidades de sua identifica��o na realiza��o de: "
cTextHtml += '<br>'
cTextHtml += '<font size="5" color="#424242">' + STR0003 + '</font><br/>'//" - Vendas"
cTextHtml += '<br>'
cTextHtml += '<font size="5" color="#424242">' + STR0004 + '</font><br/>'//" - Devolu��es"
cTextHtml += '<br>'
cTextHtml += '<font size="5" color="#424242">' + STR0005 + '</font><br/>'//" - Entrega a domic�lio"
cTextHtml += '<br>'
cTextHtml += '<font size="5" color="#424242">' + STR0006 + '</font><br/>'//" - An�lise de cr�dito"
cTextHtml += '<br>'
cTextHtml += '<font size="5" color="#424242">' + STR0007 + '</font><br/>'//" - T�tulos financeiro"
cTextHtml += '<br>'
cTextHtml += '<font size="5" color="#424242">' + STR0008 + '</font><br/>'//" - Campanhas de propaganda"

If lLjTermCo
    cTextHtml := ExecBlock("LjTermCo",.F.,.F.,{cTextHtml})
EndIf 

If Empty(cTextHtml)
    STIIncCustomer()
    LjGrvLog("STIConsentTerm","Ponto de entrada LjTermCo Compilado")
    LjGrvLog("STIConsentTerm","A Tela com Termo de consentimento n�o ser� exibida pois o retorno do ponto de entrada LjTermCo esta vazio.")
Else
    LjGrvLog("STIConsentTerm","Mensagem que ser� exibida para o termo de consentimento: ",cTextHtml)
    STFCleanInterfaceMessage()
    STIExchangePanel({|| STITerm(cTextHtml) })
Endif 

return

/*/
{Protheus.doc} STITerm

Fun��o resposavel por Printar o parametro cTextHtml contendo as informa��es do termo de consentimento 

@type function
@author Lucas Novais (lnovais)
@since 20/09/2019
@version P12.1.25
@param cTextHtml, caracter, Texto que ser� exibido como termo de consentimento
@return oMainPanel, Objeto com infoma��es da Painel que ser� aberto.

/*/

Static Function STITerm(cTextHtml)

Local oPanelMVC		:= STIGetDlg()		                                                                //Painel principal do dialog
Local oMainPanel 	:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2)   //Painel do Termo de consentimento
Local lHtml         := .T.                                                                              //Indica que o Say sera em HTML
Local oFont         := TFont():New('Courier new',,-18,.T.)                                              //Fonte padr�o do Say
Local oTexto                                                                                            //Objeto TSAY
Local oBtnAceito                                                                                        //Bot�o Aceito
Local oBtnDeclino                                                                                       //Bot�o Declino

oMainPanel:SetCSS(POSCSS(GetClassName(oMainPanel),CSS_PANEL_CONTEXT))

oTexto := TSay():New(020,008, {||cTextHtml},oMainPanel,,oFont,,,,.T.,,,oMainPanel:nWidth/2.10,oPanelMVC:nHeight/2,,,,,,lHtml)
oTexto:SetCSS( POSCSS(GetClassName(oTexto),CSS_LABEL_FOCAL))

oBtnAceito:= TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0009,oMainPanel,{ || STIIncCustomer()},LARGBTN,ALTURABTN,,,,.T.)//"Aceitar"
oBtnAceito:SetCSS(POSCSS(GetClassName(oBtnAceito),CSS_BTN_FOCAL))	

oBtnDeclino:= TButton():New(POSVERT_BTNFOCAL,POSHOR_1,STR0010,oMainPanel,{ || STIRegItemInterface() },LARGBTN,ALTURABTN,,,,.T.)//"Declinar"				
oBtnDeclino:SetCSS(POSCSS(GetClassName(oBtnDeclino),CSS_BTN_NORMAL))

Return oMainPanel