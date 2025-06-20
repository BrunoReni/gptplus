#INCLUDE "PMPROMEVE.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "TOPCONN.CH"

#DEFINE PLS_CORLIN 	"#D6E4EA"    

Static oSUW  
Static oBOG
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PMPROMEVE�Autor  �Microsiga           � Data �  10/09/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun�ao que chama a tela da rotina Campanhas e Eventos.     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PMPROMEVE()
Local oBrowse1
LOCAL aArea     := GetArea()  
LOCAL nI		:= 0
LOCAL nFldId  	:= 1
LOCAL nAtuSec	:= 60
LOCAL aTFolder 	:= {}
LOCAL aHeader	:= {}
LOCAL aFiles	:= {}
LOCAL aCoors  	:= FWGetDialogSize( oMainWnd )
LOCAL oPanelUp 	:= NIL
LOCAL oFWLayer 	:= NIL 
LOCAL oPLUpTop 	:= NIL
LOCAL oPLUp 	:= NIL
LOCAL oPLDown  	:= NIL
LOCAL oDlg		:= NIL       
LOCAL cFiltro	:= ""

//����������������������������������������������������������������������������
//� Private
//����������������������������������������������������������������������������
PRIVATE _CodPad_  := ""
PRIVATE cCadastro := ""

If FunName() == "PLSMPROM"
	dbselectArea("BOG")
	dbSetOrder(1) //BOG_FILIAL, BOG_CODPRO, BOG_ITEM, BOG_CODCAM
	If !DbSeek(xFilial("BOG") + BOA->BOA_CODPRO)
		Return
	EndIf
EndIf

Inclui := .F.    
aRotina   := {}
                     
cFiltro := "BOG->BOG_CODPRO == '" + BOA->BOA_CODPRO + "'"

//����������������������������������������������������������������������������
//� MsDialog																 
//����������������������������������������������������������������������������
oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],STR0001,,,,,,,,,.T.) //"Campanhas e Eventos"
//����������������������������������������������������������������������������
//� Cria o conteiner onde ser�o colocados s browses							 
//����������������������������������������������������������������������������
oFWLayer := FWLayer():New()
oFWLayer:Init( oDlg, .F.)
//����������������������������������������������������������������������������
//� Divisao da tela em duas linhas de 50%									 
//����������������������������������������������������������������������������
oFWLayer:AddLine('UpTop',4,.F.)
oFWLayer:AddLine('Up'	,46,.F.)
oFWLayer:AddLine('Down'	,50,.F.)
//����������������������������������������������������������������������������
//� Monta obj de Linha														 
//����������������������������������������������������������������������������
oPLUpTop := oFWLayer:GetLinePanel( 'UpTop' )
oPLUp 	 := oFWLayer:GetLinePanel( 'Up' )
oPLDown  := oFWLayer:GetLinePanel( 'Down' )

//����������������������������������������������������������������������������
//� Painel																	 
//����������������������������������������������������������������������������
cStyle 		 := "Q3Frame{ border-style:solid; border-color:#FFFFFF; border-bottom-width:3px; border-top-width:1px; background-color:#D6E4EA }"
oPanel 		 := TPanelCss():New(000,000,"",oPLUpTop,,.F.,.F.,,,012,012,.T.,.F.)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT
oPanel:setCSS( cStyle ) 

//����������������������������������������������������������������������������
//� Browse demanda
//����������������������������������������������������������������������������
oBOG := FWmBrowse():New()
oBOG:SetOwner(oPLUp)
oBOG:SetProfileID( "0" )
oBOG:SetAlias( "BOG" )
oBOG:SetDescription( STR0001 )   //"Campanhas e Eventos"
oBOG:SetMenuDef("")
oBOG:DisableDetails()
oBOG:SetAmbiente(.T.)
oBOG:SetWalkThru(.T.)
oBOG:SetBlkBackColor( {||PLS_CORLIN} )
oBOG:ForceQuitButton()             
oBOG:SetChange({|| PProEveFil() })           
oBOG:SetFilterDefault(cFiltro)
oBOG:Activate()   

//����������������������������������������������������������������������������
//� Browse dos registros das guias em auditoria								 
//����������������������������������������������������������������������������
oSUW := FWmBrowse():New()
oSUW:SetOwner( oPLDown )
oSUW:SetProfileID( '1' )
oSUW:SetAlias( "SUW" ) 
oSUW:SetDescription( STR0002 ) //"Eventos"
oSUW:SetMenuDef("PMPROMEVE")
oSUW:DisableDetails()                                         
oSUW:ForceQuitButton()
oSUW:SetAmbiente(.T.)
oSUW:SetWalkThru(.T.)
oSUW:SetBlkBackColor( {||PLS_CORLIN} )
oSUW:Activate()     

//����������������������������������������������������������������������������
//� Relacao do Browse Mestre com os Detail
//����������������������������������������������������������������������������
oRBOGSUW := FWBrwRelation():New()
oRBOGSUW:AddRelation( oBOG,oSUW,  {	{ 'BOG->BOG_FILIAL', 'xFilial( "BOG" )' },;
									{ 'BOG->BOG_CODCAM', 'SUW->UW_CODCAMP' }} )
oRBOGSUW:Activate()

//����������������������������������������������������������������������������
//� Ativando componentes de tela											 
//����������������������������������������������������������������������������
oDlg:lCentered	:= .T.

// Evento executado apos o fechamento da janela de edi��o do grid Pai, para atualizar o grid Filho.
//oSUW:BAFTEREXEC	 := {|CFUNCTION,NOPTION,NVERIFY| RefrB23()}

// Valida se pode incluir ou nao!
//oBOG:BBEFOREEXEC := {|CFUNCTION,NOPTION,NVERIFY,CTITLE,NREALOPC| WhenB1L(CFUNCTION,NOPTION,NVERIFY,CTITLE,NREALOPC)}
oDlg:Activate()
//����������������������������������������������������������������������������
//� Rest nas linhas do browse e na area										 
//����������������������������������������������������������������������������
RestArea( aArea )                   
//����������������������������������������������������������������������������
//� Fim da Rotina															 
//����������������������������������������������������������������������������
Return NIL

Return     
             
//----------------------------------------------------------------------------
// ATUALIZA O BROWSE DA SUW
//---- ------------------------------------------------------------------------
Static Function PProEveFil() 
	
If  oSUW <> Nil
	oSUW:SetFilterDefault("UW_CODCAMP == " + BOG->BOG_CODCAM + "")
	oSUW:Refresh()
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Saude               � Data �  02/26/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta Menu de a��es relacionadas das campanhas e eventos.  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SEGMENTO SAUDE                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function MenuDef()
Private aRotina := {}

aAdd( aRotina, { "Pesquisar" , 			"PesqBrw"     , 0, 1, 					   0, .T. } )
AaDd( aRotina, { STR0003, 	"PROMLIST", 0, MODEL_OPERATION_INSERT, 0, NIL } ) //"Lista de Presen�a"

Return aRotina   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PROMLIST �Autor  �Microsiga           � Data �  10/09/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Fun��o para chamar a lista de enventos do Call Center.    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PROMLIST() 
Local aArea	  := GetArea()
Local cAlias  := ""
Local nOpc    := 6
Local nreg    := 1
Local cCodEve := SUW->UW_CODEVE
Local dDataEv	:=CtoD(" / / ")
Local cFilCamp	:=""


DbSelectarea("ACD")
dbSetOrder(1)//ACD_FILIAL, ACD_CODIGO
DbSeek(xFilial("ACD") + cCodEve) 
cAlias  := Alias()

DbSelectarea("ACE")
dbSetOrder(1)//ACE_FILIAL, ACE_CODIGO, ACE_GRADE
DbSeek(xFilial("ACE") + cCodEve) 
dDataEv:=ACE->ACE_DATA

DbSelectarea("AG5")
dbSetOrder(2)//AG5_FILIAL, AG5_EVENT, AG5_GRADE, AG5_CODCO
DbSeek(xFilial("AG5") + cCodEve) 

Tk340Eventos(cAlias,nreg,nOpc) 

If PLSALIASEX("BO7")
	cFilCamp :=PMBRINFIL() 
	If !Empty(cFilCamp )
	 	PMPROBRIN(BOG->BOG_CODPRO,BOG->BOG_CODCAM,BOG->BOG_ITEM,cCodEve,dDataEv,cFilCamp)
	Endif
Endif 	

RestArea(aArea)    

Return  

