#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#include "FISA160H.ch"

/*
Este fonte tem objetivo de montar a tela para exibi��o do hist�rico de altera��es
das regras. Ser� uma tela em comum para todas as regras

A princ�pio somente ser� utilizada para a visualiza��o das altera��es.

*/

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Erick G. Dias
@since 07/10/2013
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function MenuDef()    

Local aRotina := {}

ADD OPTION aRotina TITLE STR0001 ACTION 'FSA160HHist' OPERATION 2 ACCESS 0 //"Visualizar"
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160HHist
Fun��o que executar� a respectiva View do hist�rico, para ver como o cadastro estav

@author Erick Dias
@since 24/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA160HHist()
Local cTitle := ""

IF c170AlsHist == "F2B"
    //Exibe visualiza��o do cadastro de regra de c�lculo do tributo
    If F2B->F2B_ALTERA == '1'
        cTitle := STR0002 + DToc(F2B->F2B_DTALT) + STR0003 + F2B->F2B_HRALT + ")"
    Else
        cTitle := STR0004//"Regra Ativa"
    EndIF

    FWExecView(cTitle,'FISA160', MODEL_OPERATION_VIEW,, { || .T. } ,{ || .T. }  ) //"Regra N�o Ativa(Data: " - " - Hora:"

ElseIf c170AlsHist == "F27"
 
    //Exibe visualiza��o do cadastro de regra de Base de C�lculo
    If F27->F27_ALTERA == '1'
        cTitle := STR0002 + DToc(F27->F27_DTALT) + STR0003 + F27_HRALT + ")"
    Else
        cTitle := STR0004//"Regra Ativa"
    EndIF
    
    FWExecView(cTitle,'FISA161', MODEL_OPERATION_VIEW,, { || .T. } ,{ || .T. }  ) //"Regra N�o Ativa(Data: " - " - Hora:"    

ElseIf c170AlsHist == "F28"
    
    //Exibe visualiza��o do cadastro de regra de al�quota    
    If F28->F28_ALTERA == '1'
        cTitle := STR0002 + DToc(F28->F28_DTALT) + STR0003 + F28_HRALT + ")"
    Else
        cTitle := STR0004//"Regra Ativa"
    EndIF

    FWExecView(cTitle,'FISA162', MODEL_OPERATION_VIEW,, { || .T. } ,{ || .T. }  ) //"Regra N�o Ativa(Data: " - " - Hora:"

ElseIf c170AlsHist == "CIV"

    //Exibe visualiza��o do cadastro de regra de dependentes
    If CIV->CIV_ALTERA == '1'
        cTitle := STR0002 + DToc(CIV->CIV_DTALT) + STR0003 + CIV_HRALT + ")"
    Else
        cTitle := STR0004//"Regra Ativa"
    EndIF

    FWExecView(cTitle,'FISA160C', MODEL_OPERATION_VIEW,, { || .T. } ,{ || .T. }  ) //"Regra N�o Ativa(Data: " - " - Hora:"

ElseIf c170AlsHist == "CJ2"

    //Exibe visualiza��o do cadastro de regra de dependentes
    If CJ2->CJ2_ALTERA == '1'
        cTitle := STR0002 + DToc(CJ2->CJ2_DTALT) + STR0003 + CJ2_HRALT + ")"
    Else
        cTitle := STR0004//"Regra Ativa"
    EndIF

    FWExecView(cTitle,'FISA160J', MODEL_OPERATION_VIEW,, { || .T. } ,{ || .T. }  ) //"Regra N�o Ativa(Data: " - " - Hora:"

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA16XHist
Fun��o que exibir� Browse com o hist�rico de altea��es da rotina

@author Erick Dias
@since 24/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA16XHist(cAlias, cFiltro, cDescr, ACampos)

Local oBrowse := FWmBrowse():New()

//Monto Borwse para exibir as linhas alteradas
oBrowse:SetDescription( cDescr)
oBrowse:SetAlias( cAlias )
oBrowse:SetMenuDef( 'FISA160H' ) 
oBrowse:DisableDetails()
oBrowse:ForceQuitButton()
oBrowse:SetFilterDefault( cFiltro )
oBrowse:SetFields(ACampos)
oBrowse:Activate()

Return