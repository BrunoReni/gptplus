#INCLUDE "PLSA2X.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'  
#include "PLSMGER.CH" 
#include "TOPCONN.CH"

#DEFINE PLS_MODELO_CABECALHO	"VIEWDEF.PLSA2X"
#DEFINE PLS_MODELO_ITENS 		"PLSA3X"
#DEFINE PLS__ALIAS_CABECALHO 	"B1J"
#DEFINE PLS__ALIAS_ITENS 		"B1L"
#DEFINE PLS_TITULO 				 STR0001 //"Faixa Salarial da tabela de reembolso patronal"
#DEFINE PLS_CORLIN 				"#D6E4EA"

Function PLSA2X()                

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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Private
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PRIVATE _CodPad_  := ""
PRIVATE cCadastro := ""
PRIVATE aRotina   := {}
PRIVATE oB1J
PRIVATE oB1L
Inclui := .F.    
                     
cFiltro := "B1J_FILIAL = '"+xFilial("B1J")+"' .AND. B1J_CODOPE = '"+B1I->B1I_CODOPE+"' .AND. B1J_CODIGO = '"+B1I->B1I_CODIGO+"' "

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� MsDialog																 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],STR0002,,,,,,,,,.T.) //"Tabela de Reembolso Patronal"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Cria o conteiner onde ser�o colocados s browses							 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oFWLayer := FWLayer():New()
oFWLayer:Init( oDlg, .F.)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Divisao da tela em duas linhas de 50%									 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oFWLayer:AddLine('UpTop',4,.F.)
oFWLayer:AddLine('Up'	,46,.F.)
oFWLayer:AddLine('Down'	,50,.F.)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Monta obj de Linha														 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oPLUpTop := oFWLayer:GetLinePanel( 'UpTop' )
oPLUp 	 := oFWLayer:GetLinePanel( 'Up' )
oPLDown  := oFWLayer:GetLinePanel( 'Down' )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Painel																	 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
cStyle 		 := "Q3Frame{ border-style:solid; border-color:#FFFFFF; border-bottom-width:3px; border-top-width:1px; background-color:#D6E4EA }"
oPanel 		 := TPanelCss():New(000,000,"",oPLUpTop,,.F.,.F.,,,012,012,.T.,.F.)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT
oPanel:setCSS( cStyle )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Browse dos registros das guias em auditoria								 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oB1J := FWmBrowse():New()
oB1J:SetOwner( oPLUp )
oB1J:SetProfileID( '0' )
oB1J:SetAlias( PLS__ALIAS_CABECALHO ) 
oB1J:SetDescription( PLS_TITULO )
oB1J:SetMenuDef("PLSA2X")
oB1J:DisableDetails()                                         
oB1J:ForceQuitButton()
oB1J:SetAmbiente(.T.)
oB1J:SetWalkThru(.T.)
oB1J:SetBlkBackColor( {||PLS_CORLIN} )
oB1J:SetFilterDefault(cFiltro)
oB1J:Activate()                  

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Browse demanda
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oB1L := FWmBrowse():New()
oB1L:SetOwner( oPLDown )
oB1L:SetProfileID( "1" )
oB1L:SetAlias( PLS__ALIAS_ITENS )
oB1L:SetDescription( STR0003 ) //"Itens da Tabela de Pre�os"
oB1L:SetMenuDef(PLS_MODELO_ITENS)
oB1L:DisableDetails()
oB1L:SetAmbiente(.T.)
oB1L:SetWalkThru(.T.)
oB1L:SetBlkBackColor( {||PLS_CORLIN} )
oB1L:ForceQuitButton()
oB1L:Activate()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Relacao do Browse Mestre com os Detail
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oRB1LB1J := FWBrwRelation():New()
oRB1LB1J:AddRelation( oB1J, oB1L, {	{ 'B1L_FILIAL', 'xFilial( "B1L" )' },;
									{ 'B1L_CODOPE', 'B1J_CODOPE' },;
									{ 'B1L_CODTAB', 'B1J_CODIGO' },;
									{ 'B1L_CDFXSL', 'B1J_CODFAI' }} )
									
oRB1LB1J:Activate()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Ativando componentes de tela											 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oDlg:lCentered	:= .T.

// Valida se pode excluir ou nao!
oB1J:BBEFOREEXEC := {|CFUNCTION,NOPTION,NVERIFY,CTITLE,NREALOPC| WhenB1J(CFUNCTION,NOPTION,NVERIFY,CTITLE,NREALOPC)}

// Evento executado apos o fechamento da janela de edi豫o do grid Pai, para atualizar o grid Filho.
oB1J:BAFTEREXEC	 := {|CFUNCTION,NOPTION,NVERIFY| RefrB23()}

// Valida se pode incluir ou nao!
oB1L:BBEFOREEXEC := {|CFUNCTION,NOPTION,NVERIFY,CTITLE,NREALOPC| WhenB1L(CFUNCTION,NOPTION,NVERIFY,CTITLE,NREALOPC)}
oDlg:Activate()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Rest nas linhas do browse e na area										 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
RestArea( aArea )                   
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Fim da Rotina															 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Return NIL

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽굇
굇쿑uncao    � MenuDef � Autor � Totvs                  � Data � 16.02.11 낢굇
굇쳐컴컴컴컴컵컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙굇
굇쿏escricao � MenuDef													  낢굇
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/
Static Function MenuDef()
PRIVATE aRotina := {}
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Opcoes de menu															 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

ADD OPTION aRotina Title 'Pesquisar'  	Action 'PesqBrw'	   		OPERATION 1 ACCESS 0
ADD OPTION aRotina Title 'Visualizar' 	Action PLS_MODELO_CABECALHO	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir'  	Action PLS_MODELO_CABECALHO OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar'  	Action PLS_MODELO_CABECALHO OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir'  	Action PLS_MODELO_CABECALHO OPERATION 5 ACCESS 0 

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruB1J := FWFormStruct( 1, 'B1J', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   := MPFormModel():New('PLSA2XMD', /*bPreValidacao*/, {|oX|PlsVldB1J(oX)},/*bCommit*/, /*bCancel*/ ) //

// Adiciona ao modelo uma estrutura de formul�rio de edi豫o por campo
oModel:AddFields( 'B1JMASTER', /*cOwner*/, oStruB1J, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0003 ) //"Faixa Salarial"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'B1JMASTER' ):SetDescription( STR0003 ) //"Faixa Salarial"

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruB1J := FWFormStruct( 2, 'B1J' )

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSA2X' )

Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_B1J', oStruB1J, 'B1JMASTER' )  

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o ID da View com o "box" para exibicao               admin
oView:SetOwnerView( 'VIEW_B1J', 'SUPERIOR' )

Return oView

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿛LSA2X   튍utor  쿘icrosiga           � Data �  03/18/11   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     �                                                            볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                        볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function RefrB23()

Eval(oB1J:BCHANGE)

Return(.T.)
                        
                        
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿛LSB1JFX  튍utor  쿒eraldo Felix Junior� Data �  09/29/11   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Gera codigo da faixa salarial.                             볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                         볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function PLSB1JFX(cTipo)
Local cSql 		:= ""   
Local cCodFai   := ""
                       
If cTipo == "1"
	cSql := "SELECT Max(B1J_CODFAI) CODFAI FROM "+RetSqlName("B1J")+" Where B1J_FILIAL = '"+xFilial('B1J')+"' "
	cSql += "AND B1J_CODOPE = '"+B1I->B1I_CODOPE+"' "
	cSql += "AND B1J_CODIGO = '"+B1I->B1I_CODIGO+"' "
	cSql += "AND D_E_L_E_T_ = ' ' "
Else
	cSql := "SELECT Max(B1L_CODFAI) CODFAI FROM "+RetSqlName("B1L")+" Where B1L_FILIAL = '"+xFilial('B1L')+"' "
	cSql += "AND B1L_CODOPE = '"+B1I->B1I_CODOPE+"' "
	cSql += "AND B1L_CODTAB = '"+B1I->B1I_CODIGO+"' "
	cSql += "AND B1L_CDFXSL = '"+B1J->B1J_CODFAI+"' "
	cSql += "AND D_E_L_E_T_ = ' ' "
Endif
                                       
PlsQuery(cSql,'Trb2X')

If !Trb2X->( Eof() )		
	// Incrementa codigo da faixa.
	cCodFai :=  StrZero(Val(Soma1(Trb2X->CODFAI)), TamSX3("B1J_CODFAI")[1])
Endif

// Focar geracao do codigo!                        
If Empty(cCodFai)
	cCodFai := StrZero("1", TamSX3("B1J_CODFAI")[1])
Endif
                        
// Encerra area de trabalho.
Trb2X->( dbCloseArea() )
                            
// Retorna codigo da faixa.
Return(cCodFai)




/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿛LSA2X    튍utor  쿘icrosiga           � Data �  10/03/11   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     �                                                            볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                        볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function WhenB1J(CFUNCTION,NOPTION,NVERIFY,CTITLE,NREALOPC)
Local lRet		:= .T.
Local nOpc      := NOPTION //oModel:GetOperation()
Local aArea 	:= GetArea()
                      
If nOpc == MODEL_OPERATION_DELETE
	B1L->( dbSetorder(01) )
	If B1L->( dbSeek(xFilial("B1L") + B1J->B1J_CODOPE + B1J->B1J_CODIGO + B1J->B1J_CODFAI) )
		Help( ,, 'HELP',,STR0004, 1, 0) //"Impossivel excluir a Faixa Salarial porque existem Faixas Et�rias relacionadas a ela."
		lRet := .F.
	Endif 		
Endif
                                                                                                               
RestArea(aArea)

Return( lRet )

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿛LSA2X    튍utor  쿘icrosiga           � Data �  10/03/11   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     �                                                            볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                      	                  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function PlsVldB1J(oModel)

Local lRet := .T.
Local cSql := ""   

If oModel:nOperation <> 3 .And. oModel:nOperation <> 4 //Valida apenas inclusao e alteracao
	Return .T.
EndIf	

If oModel:GetValue("B1JMASTER","B1J_VLSLFN") < oModel:GetValue("B1JMASTER","B1J_VLSLIN")
	Help( ,, 'HELP',,STR0005, 1, 0) //"O valor final deve ser maior ou igual ao valor inicial."
	Return  .F.
EndIf

cSql := "SELECT B1J_CODFAI FROM "+RetSqlName("B1J")+" Where B1J_FILIAL = '"+xFilial('B1J')+"' "
cSql += "AND B1J_CODOPE = '"+B1I->B1I_CODOPE+"' "
cSql += "AND B1J_CODIGO = '"+B1I->B1I_CODIGO+"' "

If Empty(oModel:GetValue("B1JMASTER","B1J_VLSLIN"))
	cSql += "AND B1J_VLSLIN <= "+CValToChar(oModel:GetValue("B1JMASTER","B1J_VLSLFN"))+" "
Else
	cSql += "AND ((B1J_VLSLIN <= "	+ CValToChar(oModel:GetValue("B1JMASTER","B1J_VLSLFN")) + " AND B1J_VLSLFN >= " + CValToChar(oModel:GetValue("B1JMASTER","B1J_VLSLIN")) + ") "
	cSql += "OR (B1J_VLSLFN >= "	+ CValToChar(oModel:GetValue("B1JMASTER","B1J_VLSLIN")) + " AND B1J_VLSLIN <= " + CValToChar(oModel:GetValue("B1JMASTER","B1J_VLSLFN")) + ")) "
EndIf

If oModel:nOperation == 4 // Na alteracao desconsidera o registro que esta sendo alterado
	cSql += "AND B1J_CODFAI <> " + oModel:GetValue("B1JMASTER","B1J_CODFAI") + " "
EndIf

cSql += "AND D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
TCQUERY cSQL New ALIAS "TrbB1J"

If !TrbB1J->( Eof() )
	Help( ,, 'HELP',,STR0006 +Chr(10)+Chr(13)+ STR0007 + TrbB1J->B1J_CODFAI, 1, 0) //"As informa寤es digitadas conflitam com uma(ou mais) faixa(s) j� registrada(s)." //"C�digo da Faixa: "
	lRet :=  .F.
Endif

// Encerra area de trabalho.
TrbB1J->( dbCloseArea() )

Return lRet