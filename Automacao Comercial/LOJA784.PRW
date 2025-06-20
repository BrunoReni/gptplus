#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "LOJA784.CH"

Static oMark                //Armazena o objeto FWMarkBrowse
Static cFiltro              //Armazena o filtro padr�o do browse

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA784
FWMarkBrowse, Browse responsavel por apresentar um monitor da tabela SLX

@author  Lucas Novais (lnovais)
@version P12.1.17
@since   28/03/2019
@return
@obs
@sample
/*/
//-------------------------------------------------------------------

Function LOJA784() 

oMark   := FWMarkBrowse():New()
cFiltro := "LX_SITUA = 'OK' .OR. LX_SITUA = 'X0' .OR. LX_SITUA = 'X1' .OR. LX_SITUA = 'X3' .OR. LX_SITUA = 'ER'"

//-- Defini��o da tabela a ser utilizada 
oMark:SetAlias("SLX")

//-- Define a titulo do browse de marcacao
oMark:SetDescription(STR0001)//"Acompanhamento de Inutiliza��es"

oMark:AddLegend( "LX_SITUA=='OK'", "RED"       , STR0002)//"Inutiliza��o recebida."
oMark:AddLegend( "LX_SITUA=='X0'", "BR_PRETO_0", STR0003)//"Processo de inutiliza��o iniciado."
oMark:AddLegend( "LX_SITUA=='X1'", "BR_PRETO_1", STR0004)//"Inutiliza��o enviada ao TSS."
oMark:AddLegend( "LX_SITUA=='X3'", "BR_PRETO_3", STR0005)//"Inutiliza��o rejeitada."
oMark:AddLegend( "LX_SITUA=='ER'", "BR_PRETO"  , STR0012)//"ERRO no Canelamento / Inutiliza��o"

//-- Define o campo que sera utilizado para a marca��o 
oMark:SetFieldMark("LX_MARK") 

//-- Defini��o do filtro de aplicacao 
oMark:SetFilterDefault(cFiltro) 

//-- Ativacao da classe
oMark:Activate()

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author  Lucas Novais (lnovais)
@version P12.1.17
@since   28/03/2019
@return aRotina -  retorna o menu para o browse
@obs
@sample
/*/
//-------------------------------------------------------------------

Static Function MenuDef() 
Local aRotina := {}     //Armazena o Menu
 
ADD OPTION aRotina TITLE STR0006  ACTION "LjReproc()" OPERATION 2 ACCESS 0 //"Reprocessar"
 
Return aRotina 

//-------------------------------------------------------------------
/*/{Protheus.doc} LjReproc
Reprocessa inutiliza��es que foram rejeitadas (Campo LX_SITUA = X3)

@author  Lucas Novais (lnovais)
@version P12.1.17
@since   28/03/2019
@return
@obs
@sample
/*/
//-------------------------------------------------------------------

Function LjReproc()

Local nOk      := 0             //Variavel de controle para SLX  processadas        
Local nErro    := 0             //Variavel de controle para SLX n�o processadas
Local aArea    := GetArea()     //Armazeno a Area atual
Local cMarca   := oMark:Mark()  //Armazeno a usada  

SLX->( dbSetFilter( {|| &(cFiltro) } , cFiltro ) )
SLX->( dbGoTop() ) 

While !SLX->( EOF() ) 
    
    If oMark:IsMark(cMarca)
        If SLX->LX_SITUA == "X3" .AND. !Empty(SLX->LX_MODDOC)
            RecLock( "SLX", .F. )
                SLX->LX_SITUA := "X0"  
            SLX->( MsUnlock() )
            nOk ++
        ElseIf SLX->LX_SITUA == "ER" .AND. Empty(SLX->LX_MODDOC) //Indica que � um cancelamento, neste caso atualiza a SL1
            
            DbSelectArea("SL1") 
            SL1->(DbSetOrder(1))//L1_FILIAL+L1_NUM
            
            If SL1->(DbSeek(xFilial("SL1") + SLX->LX_NUMORC))
                
                If SL1->L1_SITUA == "X2" .OR. SL1->L1_SITUA == "X3"
                    RecLock( "SL1", .F. )
                        SL1->L1_SITUA := "X0"  
                    SL1->( MsUnlock() )

                    RecLock( "SLX", .F. )
                        Replace SLX->LX_ITERACA with 0
                        Replace SLX->LX_DULTPRC with cToD("  /  /  ")
                        Replace SLX->LX_HULTPRC with ""
                        Replace SLX->LX_SITUA   with "  "
                    SLX->( MsUnlock() )

                    nOk ++
                Else
                    LjGrvLog("Reprocessar","Or�amento: " +  SL1->L1_NUM + " N�o � passivel de reprocessamento, verifique se a tabela SL1 esta com  compo L1_SITUA Como X2 ou X3.") 
                    nErro ++  
                EndIf 
            Else
                LjGrvLog("Reprocessar","Or�amento: " +  SLX->LX_NUMORC + " N�o encontrado, Chave para busca: [" + xFilial("SL1") + SLX->LX_NUMORC + "]") 
                nErro ++  
            EndIf 
        Else
            nErro ++        
        EndIf 
    EndIf 
 
    SLX->( dbSkip() ) 
End 

If nErro > 0
    cMensagem := cValToChar(nOk)     + STR0007 + Chr(10) + Chr(13) +;//" Nota(s) reprocessada(s). "
                 cValToChar(nErro)   + STR0008 + Chr(10) + Chr(13) +;//" Nota(s) n�o foram reprocessada(s)."
                 STR0009                                             //" Verifique se todas as notas s�o passiveis de reprocessamento (Tabela SLX, Campo LX_SITUA = X3 Ou ER, Tabela SL1, Campo L1_SITUA = X2 Ou X3)"
Else
    cMensagem := cValToChar(nOk)     + STR0007 + Chr(10) + Chr(13) +;//" Nota(s) reprocessada(s). "
                cValToChar(nErro)    + STR0008                       //" Nota(s) n�o foram reprocessada(s)."
EndIf 

If (nOk + nErro) > 0
    MsgInfo(cMensagem,STR0010)  //"Reprocessamento de inutiliza��o."
Else
    MsgInfo(STR0011,STR0010)    //"Selecione pelo menos uma nota para efetuar Reprocessamento!","Reprocessamento de inutiliza��o."
EndIf 

SLX->(dbClearFilter())   
RestArea( aArea ) 
 
Return 

