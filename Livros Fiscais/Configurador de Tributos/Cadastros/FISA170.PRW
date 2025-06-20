#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA170.CH"


#DEFINE	cNodFin	'200'

//------------------------------------------------------------------
/*/{Protheus.doc} FISA170

Rotina com a concetra��o de todos os cadastros do motor fiscal tribut�rio

@author Erick G. Dias
@since 21/06/1028
@version 12.1.17

/*/
//------------------------------------------------------------------
Function FISA170(lAutomato)

	Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
	Private oBrowse
	Private oPanelBrw
	Private lclicked     := .T.
	Private lclickedI     := .T.
	Private lclickedO     := .T.
	Private c170AlsHist  := ""

	Default lAutomato := .F.

    If lVerpesssen
		If AliasIndic("F20")

			DbSelectArea ("F20")
			DbSelectArea ("F21")
			DbSelectArea ("F22")
			DbSelectArea ("F23")
			DbSelectArea ("F24")
			DbSelectArea ("F25")		
			DbSelectArea ("F26")
			DbSelectArea ("F27")
			DbSelectArea ("F28")
			DbSelectArea ("F29")
			DbSelectArea ("F2A")
			DbSelectArea ("F2B")
			DbSelectArea ("F2C")
			DbSelectArea ("F2E")
			DbSelectArea ("F2F")
			DbSelectArea ("F2G")
			DbSelectArea ("F2H")
			DbSelectArea ("F2I")
			DbSelectArea ("F2J")
			DbSelectArea ("F2K")
			DbSelectArea ("F2L") 
			DbSelectArea ("F2M")
			DbSelectArea ("F2N")
			If AliasIndic("CIQ") .and. AliasIndic("CIR")
				DbSelectArea ("CIQ")
				DbSelectArea ("CIR")
			Endif
			If AliasIndic("CIS") .AND. AliasIndic('CIT') .AND. AliasIndic('CIU')
				DbSelectArea ("CIS")
				DbSelectArea ("CIT")
				DbSelectArea ("CIU")
				DbSelectArea ("CIZ")
			Endif
			If AliasIndic("CIV")
				DbSelectArea ("CIv")
			EndIf
			If AliasIndic("CIX") .And. AliasIndic("CIY")
				DbSelectArea ("CIX")
				DbSelectArea ("CIY")
			EndIf
			If AliasIndic("CJ0") .And. AliasIndic("CJ1")
				DbSelectArea ("CJ0")
				DbSelectArea ("CJ1")
			EndIf
			If AliasIndic("CJ2")
				DbSelectArea ("CJ2")
			EndIf			
			If AliasIndic("CJ4")
				DbSelectArea ("CJ4")
			EndIf
			If AliasIndic("CJ5") .And. AliasIndic("CJ6") .And. AliasIndic("CJ7")
				DbSelectArea ("CJ5")
				DbSelectArea ("CJ6")
				DbSelectArea ("CJ7")
			EndIf
			If AliasIndic('F0R') 
				DbSelectArea ("F0R")
			Endif
			if AliasIndic('CJ8') 
				DbSelectArea ("CJ8")
			Endif

			//Ajuste de Dicionario Valid do campo F24_CDPROD
			FSA166X3()

			//Faz Chamada para verifica��o da carga inicial dos cadastros			
			FwMsgRun(,{|oSay| x170Carga(lAutomato,  oSay ) },STR0001,"") //"Processando carga inicial dos perfis"
			
			If !lAutomato
				FWExecView(STR0002,'FISA170', MODEL_OPERATION_INSERT,, { || .T. } ,{ || .T. }  ) //"Rotinas do Motor de C�lculo de Tributos Fiscais"
			Endif
		Else
			Alert(STR0003) //"Dicion�rio desatualizado, favor verificar atualiza��es do motor de c�lculo fiscal."
		EndIf
	EndIf 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
 
Local aRotina := {}

Return ( aRotina )


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStructABA := FWFormStruct( 1, 'F2B')

oModel	:=	MPFormModel():New('MODEL_ABA',,{|oModel| .T. },{|oModel| .T. })
oModel:AddFields( 'MODEL_ABA' ,, oStructABA )
oModel:SetPrimaryKey( { 'ABA_CMP1'} )
oModel:SetDescription( 'TOTVS')

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel    := FWLoadModel( 'FISA170' )
Local oView     := FWFormView():New()
Local oStruABA   := FWFormStruct( 2, 'F2B' )

oView:SetModel( oModel )

oView:AddField( 'VIEW_ABA', oStruABA, 'MODEL_ABA' )

//Retiro o ID da view
oStruABA:RemoveField('F2B_ID')

oView:AddOtherObject( 'PANEL_TREE',  { |oPanel| MONTATREE( oPanel ) } )
oView:AddOtherObject( 'PANEL_EMPTY', { |oPanel| } )
oView:AddOtherObject( 'PANEL_BROWSE',{ |oPanel| oPanelBrw := oPanel, FBrowseMon( oPanel ) } )

oView:EnableTitleView('PANEL_TREE',STR0005) //"Rotinas Dispon�veis"

oView:CreateHorizontalBox( 'INFO_FUNC'	  	,00 )
oView:CreateHorizontalBox( 'EVENTO_FUNC'	,98 )
oView:CreateHorizontalBox( 'FIM_TELA'   	,02 )

oView:CreateVerticalBox( 'INFO_FUNC_ESQ'		, 100	,'INFO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_ESQ'		, 27	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_CENTER'	, 01	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_DIR'		, 72	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'FIM_TELA_EMPTY'		, 100	, 'FIM_TELA' )

oView:SetOwnerView( 'VIEW_ABA'		, 'INFO_FUNC_ESQ' )
oView:SetOwnerView( 'PANEL_TREE'	, 'EVENTO_FUNC_ESQ' )
oView:SetOwnerView( 'PANEL_EMPTY'	, 'EVENTO_FUNC_CENTER' )
oView:SetOwnerView( 'PANEL_BROWSE'	, 'EVENTO_FUNC_DIR' )
oView:SetOwnerView( 'PANEL_EMPTY'	, 'FIM_TELA_EMPTY' )

oView:AddUserButton(STR0046,"", {|| x174Rotinas() }) //"Rela��o de Rotinas"

Return oView       

//-------------------------------------------------------------------
/*/{Protheus.doc} x174Rotinas

@author joao.pellegrini
@since 26/10/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function x174Rotinas(lAutomato)

Local oDialog := NIL
Local aRotinas := {}
Local aLines := {}
Local aSize := MsAdvSize()
Local oBrwRot := NIL
Local oColluns := NIL
Local oPanel := NIL
Local nX := 0
Local aData := {}
Local cVersao 	:= GetVersao(.F.)

Default lAutomato := .F.

aAdd(aRotinas, {"FISA168.PRW", STR0007}) //"Tributo"
aAdd(aRotinas, {"FISA167.PRW", STR0008}) //"Unidade Ref. Fiscal"
aAdd(aRotinas, {"FISA160A.PRW",STR0063}) //"Regra de tabela Progressiva"
aAdd(aRotinas, {"FISA160B.PRW",STR0064}) //"Regras por NCM"
aAdd(aRotinas, {"FISA160C.PRW",STR0065}) //"Regra por Dependentes"
aAdd(aRotinas, {"FISA160D.PRW",STR0072}) //"Regras por ISS"
aAdd(aRotinas, {"FISA160I.PRW",STR0073}) //"C�digo Situa��o Tribut�ria"
aAdd(aRotinas, {"FISA160L.PRW",STR0077}) //"Guia de Escritura��o"
aAdd(aRotinas, {"FISA160M.PRW",STR0076}) //"Guia de Escritura��o"
aAdd(aRotinas, {"FISA121.PRW",STR0079})  //"Indicadores Econ�micos FCA"


aAdd(aRotinas, {"FISA163.PRW", STR0014}) //"Perfil de Origem/Destino"
aAdd(aRotinas, {"FISA164.PRW", STR0013}) //"Perfil de Participante"
aAdd(aRotinas, {"FISA165.PRW", STR0012}) //"Perfil de Opera��o"
aAdd(aRotinas, {"FISA166.PRW", STR0011}) //"Perfil de Produto"

aAdd(aRotinas, {"FISA161.PRW", STR0009}) //"Regra de Base de C�lculo"
aAdd(aRotinas, {"FISA162.PRW", STR0010}) //"Regra de Al�quota"
aAdd(aRotinas, {"FISA160J.PRW",STR0074}) //"Regra de Escritura��o"
aAdd(aRotinas, {"FISA160.PRW", STR0016}) //"Regra de C�lculo - Documentos Fiscais"
aAdd(aRotinas, {"FISA178.PRW","Cadastro de Mensagem"})  //"Cadastro de Mensagem"

aAdd(aRotinas, {"FISA169.PRW", STR0015}) //"Regra de Apura��o"
aAdd(aRotinas, {"FISA171.PRW", STR0047}) //"dor de Manuten��o - Perfis Tribut�rios"
aAdd(aRotinas, {"FISA172.PRW", STR0048}) //"Facilitador de Amarra��o - Perfis Tribut�rios"
aAdd(aRotinas, {"FISA173.PRW", STR0018}) //"Apura��o dos Tributos Gen�ricos"
aAdd(aRotinas, {"FISA174.PRW", STR0049}) //"Visualiza��o da Apura��o"
aAdd(aRotinas, {"FISA174AJU.PRW", STR0050}) //"Detalhamento dos Ajustes de Apura��o"
aAdd(aRotinas, {"FISA174DET.PRW", STR0051}) //"Detalhamento dos Saldos de Apura��o"
aAdd(aRotinas, {"FISA175.PRW", STR0055}) //"Processamento da Apura��o"
aAdd(aRotinas, {"FISA175WIZ.PRW", STR0052}) //"Wizard de Parametriza��o da Apura��o"
aAdd(aRotinas, {"FISA176.PRW", STR0017}) //"Regra de T�tulo da Apura��o"
aAdd(aRotinas, {"FISR160.PRW", STR0042}) //"Relat�rio dos Tributos Gen�ricos por Documento Fiscal"
aAdd(aRotinas, {"FISR161.PRW", STR0057}) //"Relat�rio de Confer�ncia de Apura��o"
aAdd(aRotinas, {"FISR160A.PRW", STR0078}) //"Relat�rio de Confer�ncia de Apura��o"
aAdd(aRotinas, {"FISR181.PRW", STR0083}) //"Relat�rio de Confer�ncia Estorno ICMS"

aAdd(aRotinas, {"FINA024CAL.PRW", STR0023}) //"Regra de C�lculo - T�tulos Financeiros"
aAdd(aRotinas, {"FINA024CUM.PRW", STR0026}) //"Regra de Cumulatividade"
aAdd(aRotinas, {"FINA024DED.PRW", STR0021}) //"Regra de Dedu��o"
aAdd(aRotinas, {"FINA024RET.PRW", STR0025}) //"Regra de Reten��o"
aAdd(aRotinas, {"FINA024RFI.PRW", STR0028}) //"Regra Financeira"
aAdd(aRotinas, {"FINA024TIT.PRW", STR0020}) //"Regra de T�tulo"
aAdd(aRotinas, {"FINA024TPR.PRW", STR0022}) //"Regra de Tabelas Progressivas"
aAdd(aRotinas, {"FINA024VA.PRW",  STR0027}) //"Regra de Valores Acess�rios"
aAdd(aRotinas, {"FINA024VCT.PRW", STR0024}) //"Regra de Vencimento"

aAdd(aRotinas, {"IMPXFIS.PRW", STR0053}) //"Rotina Auxiliar de C�lculo de Tributos"
aAdd(aRotinas, {"MATXFIS.PRX", STR0054}) //"Rotina de C�lculo de Tributos"

IF !lAutomato
	oDialog := FWDialogModal():New()
	oDialog:SetBackground(.T.) // .T. -> escurece o fundo da janela 
	oDialog:SetTitle(STR0046) //"Rela��o de Rotinas"
	oDialog:SetEscClose(.F.)//permite fechar a tela com o ESC
	oDialog:SetSize(aSize[4] * 0.8, aSize[3] * 0.8) // chamar sempre antes do CreateDialog
	oDialog:EnableFormBar(.T.) 
	oDialog:CreateDialog() //cria a janela (cria os paineis)
	oDialog:addCloseButton()
	oDialog:CreateFormBar()//cria barra de botoes

	// Crio as linhas do browse com base na lista de rotinas relacionadas
	For nX := 1 to Len(aRotinas)

		aData := GetAPOInfo( aRotinas[nX, 1] )

		If Len(aData) >= 5

			aAdd(aLines, {})
			aAdd(aLines[Len(aLines)], .F.)
			aAdd(aLines[Len(aLines)], aRotinas[nX, 1]) // Rotina
			aAdd(aLines[Len(aLines)], aRotinas[nX, 2]) // Descri��o
			aAdd(aLines[Len(aLines)], DtoC(aData[4])) // Data no RPO
			aAdd(aLines[Len(aLines)], aData[5]) // Hor�rio no RPO

		EndIf

	Next nX

	oPanel := oDialog:GetPanelMain()

	DEFINE FWBROWSE oBrwRot DATA ARRAY ARRAY aLines LINE BEGIN 1 OF oPanel

	ADD COLUMN oColluns DATA &("{ || aLines[oBrwRot:At()][2]}") TITLE STR0043 SIZE 10 OF oBrwRot // "Rotina"
	ADD COLUMN oColluns DATA &("{ || aLines[oBrwRot:At()][3]}") TITLE STR0056 SIZE 100 OF oBrwRot // "Descri��o"
	ADD COLUMN oColluns DATA &("{ || aLines[oBrwRot:At()][4]}") TITLE STR0044 SIZE 10 OF oBrwRot // "Data no RPO"
	ADD COLUMN oColluns DATA &("{ || aLines[oBrwRot:At()][5]}") TITLE STR0045 SIZE 10 OF oBrwRot // "Hora no RPO"

	oBrwRot:DisableReport()
	oBrwRot:OptionConfig(.F.)


	ACTIVATE FWBROWSE oBrwRot

	oDialog:Activate()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaTree
Fun��o que cria tree com as rotinas dispon�veis

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------

STATIC FUNCTION MontaTree(oPanel)

Local oTree
Local aCoors 	:= {} //FWGetDialogSize( oPanel )
Local bChange 	:= { || FChgTree( oTree,oPanel )  }
Local aNodes	:= {}
Local IMAGE1 	:= "FOLDER5"
Local IMAGE2 	:= "FOLDER6"
Local Icon		:= "PMSEDT3"
Local lOnda2 	:= (AliasIndic("CIN") .and. FindFunction("FisExecNPI"))
Local lVersao 	:= GetVerRls()

aadd(aNodes,{'00',"000","",STR0006,IMAGE1,IMAGE2})  //"Regras Fiscais"
//*************************
//CADASTROS
//*************************
aadd(aNodes,{'01',"000","",STR0066,IMAGE1,IMAGE2})  //"Cadastros"
aadd(aNodes,{'02',"001","",STR0007 + Space(10),Icon,Icon})  //"Tributo"
aadd(aNodes,{'02',"002","",STR0008,Icon,Icon})  //"Unidade Ref. Fiscal"
IF lOnda2
	aadd(aNodes,{'02',"003","",STR0063,Icon,Icon})  //"Regra de Tabela Progressiva"
	aadd(aNodes,{'02',"004","",STR0064,Icon,Icon})  //"Regras por NCM"
	aadd(aNodes,{'02',"005","",STR0065,Icon,Icon})  //"Dependentes"
	aadd(aNodes,{'02',"006","",STR0072,Icon,Icon})  //"ISS"
	aadd(aNodes,{'02',"007","",STR0073,Icon,Icon})  //"CST
	aadd(aNodes,{'02',"008","",STR0077,Icon,Icon})  //"Guia de Escritura��o"
	aadd(aNodes,{'02',"009","",STR0076,Icon,Icon})  //"C�digo da Receita"
EndIf
aadd(aNodes,{'02',"010","",STR0079,Icon,Icon})  //""Indicadores Econ�micos FCA""

//*************************
//PERFIS
//*************************
aadd(aNodes,{'01',"000","",STR0067,IMAGE1,IMAGE2})  //"Perfis"
aadd(aNodes,{'02',"021","",STR0011,Icon,Icon})  //"Perfil de Produto"
aadd(aNodes,{'02',"022","",STR0012,Icon,Icon})  //"Perfil de Opera��o"
aadd(aNodes,{'02',"023","",STR0013,Icon,Icon})  //"Perfil de Participante"
aadd(aNodes,{'02',"024","",STR0014,Icon,Icon})  //"Perfil de Origem/Destino"

//*************************
//REGRAS
//*************************
aadd(aNodes,{'01',"000","",STR0068,IMAGE1,IMAGE2})  //"Regras de C�lculo"
aadd(aNodes,{'02',"041","",STR0009,Icon,Icon})  //"Regra de Base de C�lculo"
aadd(aNodes,{'02',"042","",STR0010,Icon,Icon})  //"Regra de Al�quota"
If lOnda2
	aadd(aNodes,{'02',"043","",STR0074,Icon,Icon})  //"Regra de Escritura��o"
EndIf
aadd(aNodes,{'02',"044","",STR0016,Icon,Icon})  //"Regra de C�lculo - Documentos Fiscais" 


//********************************
//REGRAS DE AJUSTES DE LAN�AMENTO
//********************************
If lVersao
	aadd(aNodes,{'01',"000","","Regra de Ajuste de Lan�amento",IMAGE1,IMAGE2})  //"Regras de Ajuste de Lan�amento"
	aadd(aNodes,{'02',"045","","Cadastro de Mensagem",Icon,Icon})  //""Cadastro de Mensagem""
	aadd(aNodes,{'02',"046","","Regra de Ajuste de Lan�amento",Icon,Icon})  //"Regra de Ajuste de Lan�amento"
Endif


//*************************
//APURA��O
//*************************
aadd(aNodes,{'01',"000","",STR0069,IMAGE1,IMAGE2})  //"Apura��o"
aadd(aNodes,{'02',"061","",STR0017,Icon,Icon})  //"Regra de T�tulo da Apura��o"
aadd(aNodes,{'02',"062","",STR0015,Icon,Icon})  //"Regra de Apura��o"
aadd(aNodes,{'02',"063","",STR0018,Icon,Icon})  //"Apura��o dos Tributos Gen�ricos"

//*************************
//RELAT�RIOS
//*************************
aadd(aNodes,{'01',"000","",STR0070,IMAGE1,IMAGE2})  //"Relat�rios"
aadd(aNodes,{'02',"081","",STR0042,Icon,Icon})  //"Relat�rio dos Tributos Gen�ricos por Documento Fiscal"
aadd(aNodes,{'02',"082","",STR0078,Icon,Icon})  //"Relat�rio dos Tributos Gen�ricos por Documento Fiscal"
aadd(aNodes,{'02',"083","",STR0083,Icon,Icon})  //"Relat�rio dos Tributos Gen�ricos por Documento Fiscal"

//-----------------------------------------------------------------------------------------

aadd(aNodes,{'00',"200","",STR0019,IMAGE1,IMAGE2}) //"Regras Financeiras"
aadd(aNodes,{'01',"201","",STR0020,Icon,Icon})  //"Regra de T�tulo"
aadd(aNodes,{'01',"202","",STR0021,Icon,Icon})  //"Regra de Dedu��o"
aadd(aNodes,{'01',"203","",STR0022,Icon,Icon})  //"Regra de Tabelas Progressivas"
aadd(aNodes,{'01',"204","",STR0023,Icon,Icon})  //"Regra de C�lculo - T�tulos Financeiros"
aadd(aNodes,{'01',"205","",STR0024,Icon,Icon}) //"Regra de Vencimento"
aadd(aNodes,{'01',"206","",STR0025,Icon,Icon})  //"Regra de Reten��o"
aadd(aNodes,{'01',"207","",STR0026,Icon,Icon})  //"Regra de Cumulatividade"
aadd(aNodes,{'01',"208","",STR0027,Icon,Icon}) //"Regra de Valores Acess�rios"
aadd(aNodes,{'01',"209","",STR0028,Icon,Icon})  //"Regra Financeira"


oSize := FwDefSize():New(.T.,,,.T.)
oSize:AddObject('PANEL_TREE'  ,100,100,.T.,.T.)
oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins 	:= { 0, 0, 0, 0 } // Espaco ao lado dos objetos 0, entre eles 3 
oSize:Process()

aAdd(aCoors,{oSize:GetDimension("PANEL_TREE", "COLINI"),oSize:GetDimension("PANEL_TREE", "LININI"),oSize:GetDimension("PANEL_TREE", "YSIZE")*0.97,oSize:GetDimension("PANEL_TREE", "COLEND")*0.26})

oTree := DbTree():New( aCoors[1][2], aCoors[1][1], aCoors[1][3], aCoors[1][4], oPanel,bChange , , .T. )
oTree:PTSendTree( aNodes )
oTree:CurrentNodeId := "000" 
oTree:TreeSeek("000")
oTree:SetScroll(1,.T.)
oTree:SetScroll(2,.T.)
//oTree:SetCss(GetCssTree())
oTree:PTRefresh()

Return ()

//-------------------------------------------------------------------
/*/{Protheus.doc} FChgTree 

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------

Static Function FChgTree(oTree) 

Local cIdTreePos := ""

Local aInfTree := {}

//Busco a identifica��o de qual item da Tree estamos posicionadoss
oTree:PTRefresh()
cIdTreePos := oTree:CurrentNodeId
oPanelBrw:FreeChildren()
oBrowse:DeActivate()
aInfTree := FSA170FUNC( cIdTreePos )
FBrowseMon( oPanelBrw, aInfTree[1], aInfTree[2], aInfTree[3], aInfTree[4] , oTree:GetPrompt(.T.) == STR0019, cIdTreePos,aInfTree[5]) //"Regras Financeiras"
oBrowse:Refresh()

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FBrowseMon

@author Erick G. Dias
@since 07/03/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function FBrowseMon( oPanel, cFonteTree, cAliasTree, cFiltroBrw, cDescBrw, lFinanceiro, cIdTreePos, cIndxBrw )

Local cFunc := "MethIsMemberOf"

Default cFonteTree := ""
Default cAliasTree := ""
Default cFiltroBrw := ""
Default cDescBrw   := ""
Default cIndxBrw   := ""
Default cIdTreePos	:= "000"

oBrowse := FWmBrowse():New()

If &cFunc.(oBrowse,"SetMainProc")
	oBrowse:SetMainProc("FISA170")
EndIf

If Empty( cFonteTree ) .And. Empty( cAliasTree ) 
	aInf := FSA170FUNC("")

	cFonteTree := aInf[1]
	cAliasTree := aInf[2]
	cFiltroBrw := aInf[3]
	cDescBrw   := aInf[4]		
	cIndxBrw   := aInf[5]
EndIf

If !Empty(cAliasTree)
	oBrowse:SetOwner( oPanel )
	oBrowse:SetDescription( cDescBrw )
	oBrowse:SetAlias( cAliasTree )

	If (cIdTreePos >= "200" .And. cIdTreePos <= "300")
		(cAliasTree)->(DbSetOrder(2))
	EndIf

	IF !Empty(cIndxBrw)
		(cAliasTree)->(DbSetOrder(cIndxBrw))
	Endif

	Do Case

		Case cAliasTree == "FKK"
			oBrowse:AddLegend( "FKK_ATIVO == '1' " , "GREEN", STR0029 )  //"Regra Financeira Ativa"
			oBrowse:AddLegend( "FKK_ATIVO == '2' " , "RED"  , STR0030 )  //"Regra Financeira Inativa"
		Case cAliasTree == "F2H"
			oBrowse:AddLegend( "F2H_STATUS == '1' " , "BR_VERMELHO" , STR0031 ) //"Saldo Devedor - N�o Gerou T�tulo"
			oBrowse:AddLegend( "F2H_STATUS == '2' " , "BR_AMARELO"  , STR0032 ) //"Saldo Devedor - T�tulo Gerado"
			oBrowse:AddLegend( "F2H_STATUS == '3' " , "BR_AZUL"     , STR0033 ) //"Saldo Credor"
			oBrowse:AddLegend( "F2H_STATUS == '4' " , "BR_BRANCO"   , STR0034 ) //"Sem Saldos"
			oBrowse:AddLegend( "F2H_STATUS == '5' " , "BR_VERDE"    , STR0035 ) //"Contabilizado"

	EndCase

	oBrowse:SetMenuDef( cFonteTree )
	oBrowse:DisableDetails()
	oBrowse:SetFilterDefault( cFiltroBrw )

	oBrowse:Activate()
EndIF

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA170FUNC
Fun��o que identifica a op��o selecionada pelo usu�rio e abre a rotina
pertinente a op��o selecionada.

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA170FUNC( cIdTreePos )

Local aRet   			:= Array( 05 )
Do Case

	//*************************
	//CADASTROS
	//*************************
	Case cIdTreePos == "001" //Tributo
		aRet[1] 	:= 'FISA168'
		aRet[2] 	:= "F2E"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0007	 //"Tributo"	
	Case cIdTreePos == "002" // unidade referencial fiscal		
        aRet[1] 	:= 'FISA167'
		aRet[2] 	:= "F29"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0008 //"Unidade Ref. Fiscal"
	Case cIdTreePos == "003" //Tabela Progressiva
		aRet[1] 	:= 'FISA160A'
		aRet[2] 	:= IIF ((AliasIndic("CIQ") .and. AliasIndic("CIR")),"CIQ", HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= STR0063	 //"Regra de Tabela Progressiva"
	Case cIdTreePos == "004" //Enquadramento por NCM
		aRet[1] 	:= 'FISA160B'
		aRet[2] 	:= IIF ((AliasIndic("CIS") .AND. AliasIndic('CIT') .AND. AliasIndic('CIU')),"CIS", HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= STR0064	 //"Regras por NCM"

	Case cIdTreePos == "005" //Regra por Dependentes
        aRet[1] 	:= 'FISA160C'
		aRet[2] 	:= IIF ((AliasIndic("CIV")),"CIV", HelpDic() )
		aRet[3] 	:= "CIV_ALTERA == '2'"
		aRet[4] 	:= STR0065 //"Regra por Dependentes"
	
	Case cIdTreePos == "006" //Regra de ISS
        aRet[1] 	:= 'FISA160D'
		aRet[2] 	:= IIF ((AliasIndic("CIX") .And. AliasIndic("CIY") .And. AliasIndic("CIT")),"CIX", HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= STR0072//"Regra por ISS"

	Case cIdTreePos == "007" //Cadastro de CST
        aRet[1] 	:= 'FISA160I'
		aRet[2] 	:= IIF( AliasIndic("CJ0") .And. AliasIndic("CJ1") ,"CJ0" , HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= STR0073 //"C�digo Situa��o Tribut�ria"
		aRet[5] 	:= 2// Indice a ser utilizado no browser

	Case cIdTreePos == "008" //Regras para gera��o da Guia de Escritura��o
        aRet[1] 	:= 'FISA160L'
		aRet[2] 	:= IIF( AliasIndic("CJ4"),"CJ4" , HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= STR0077
		aRet[5] 	:= 1// Indice a ser utilizado no browser

	Case cIdTreePos == "009" //Regras para gera��o da Guia de Escritura��o
        aRet[1] 	:= 'FISA160M'
		aRet[2] 	:= IIF( AliasIndic("CJ5"),"CJ5" , HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= STR0076
		aRet[5] 	:= 1// Indice a ser utilizado no 
	Case cIdTreePos == "010" //Indicadores Econ�micos FCA (Fator de Convers�o e Atualiza��o)
        aRet[1] 	:= 'FISA121'
		aRet[2] 	:= IIF( AliasIndic("F0R"),"F0R" , HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= STR0079
		aRet[5] 	:= 1// Indice a ser utilizado no browser			

	//*************************
	//PERFIS
	//*************************
    Case cIdTreePos == "021" //Perfil de Produto		
        aRet[1] 	:= 'FISA166'
		aRet[2] 	:= "F20"
		aRet[3] 	:= "F20_TIPO == '04'"
		aRet[4] 	:= STR0011 //"Perfil de Produto"

    Case cIdTreePos == "022" // perfil de opera��o		
        aRet[1] 	:= 'FISA165'
		aRet[2] 	:= "F20"
        aRet[3] 	:= "F20_TIPO == '03'"
		aRet[4] 	:= STR0012 //"Perfil de Opera��o"

	Case cIdTreePos == "023" //Perfil de Participante		
        aRet[1] 	:= 'FISA164'
		aRet[2] 	:= "F20"
		aRet[3] 	:= "F20_TIPO == '02'"
		aRet[4] 	:= STR0013 //"Perfil de Participante"

	Case cIdTreePos == "024" //Perfil de Origem e Destino		
		aRet[1] 	:= 'FISA163'
		aRet[2] 	:= "F20"
		aRet[3] 	:= "F20_TIPO == '01'"
		aRet[4] 	:= STR0014 //"Perfil de Origem/Destino"

	//*************************
	//REGRAS
	//*************************
	Case cIdTreePos == "041"		        
        aRet[1] 	:= 'FISA161'
		aRet[2] 	:= "F27"
		aRet[3] 	:= "F27_ALTERA == '2'"
		aRet[4] 	:= STR0009 //"Regra de Base de C�lculo"

	Case cIdTreePos == "042" //Cadastro de Regra de Al�quota
        aRet[1] 	:= 'FISA162'
		aRet[2] 	:= "F28"
		aRet[3] 	:= "F28_ALTERA == '2'"
		aRet[4] 	:= STR0010 //"Regra de Al�quota"

	Case cIdTreePos == "043" //Cadastro de Regra de Escritura��o
        aRet[1] 	:= 'FISA160J'
		aRet[2] 	:= IIF( AliasIndic("CJ2") ,"CJ2" , HelpDic() )
		aRet[3] 	:= "CJ2_ALTERA == '2'"
		aRet[4] 	:= STR0074 //"Regra de Escritura��o"

	Case cIdTreePos == "044" //Regra de C�lculo
		aRet[1] 	:= 'FISA160'
		aRet[2] 	:= "F2B"
		aRet[3] 	:= Iif(F2B->(Fieldpos("F2B_ALTERA")) > 0,"F2B_ALTERA =='2' .or. Empty(F2B_ALTERA)","")
		aRet[4] 	:= STR0016 //"Regra de C�lculo - Documentos Fiscais"


	
	//********************************
	//REGRAS DE AJUSTES DE LAN�AMENTO
	//********************************
	Case cIdTreePos == "045"		        
        aRet[1] 	:= 'FISA178'
		aRet[2] 	:= IIF( AliasIndic("CJ8") ,"CJ8" , HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= "Cadastro de Mensagem"
	Case cIdTreePos == "046" //Cadastro de Regra de Ajuste de Lan�amento.
        aRet[1] 	:= 'FISA181'
		aRet[2] 	:= IIF( AliasIndic("CJ9") .And. AliasIndic("CJA") ,"CJ9" , HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= "Regra de Ajuste de Lan�amento"


	//*************************
	//APURA��O
	//*************************
	Case cIdTreePos == "061"
		aRet[1] 	:= 'FISA176'
		aRet[2] 	:= "F2N"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0017 //"Regra de T�tulo da Apura��o"

	Case cIdTreePos == "062" //Regra de Apura��o
		aRet[1] 	:= 'FISA169'
		aRet[2] 	:= "F2G"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0015 //"Regra de Apura��o"

	Case cIdTreePos == "063"
		aRet[1] 	:= 'FISA173'
		aRet[2] 	:= "F2H"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0018 //"Apura��o dos Tributos Gen�ricos"

	//*************************
	//RELAT�RIOS
	//*************************
	Case cIdTreePos == "081"
		FISR160()	
		aRet[1] 	:= ""
		aRet[2] 	:= ""
		aRet[3] 	:= ""
		aRet[4] 	:= ""

	Case cIdTreePos == "082"
		FISR160A()	
		aRet[1] 	:= ""
		aRet[2] 	:= ""
		aRet[3] 	:= ""
		aRet[4] 	:= ""

	Case cIdTreePos == "083"
		//totvs.protheus.backoffice.fiscal.relatorioEstornocredito()
		FISR181()
		aRet[1] 	:= ""
		aRet[2] 	:= IIF( AliasIndic("CJM") ,"CJM" , HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= ""

		//Menu Financeiro
	Case cIdTreePos == "200" // Motor Financeiro		
        aRet[1] 	:= ''
		aRet[2] 	:= ""
		aRet[3] 	:= ""
		aRet[4] 	:= "" //"Motor Financeiro"
		
	Case cIdTreePos == "201" //Regra de T�tulos
		aRet[1] 	:= 'FINA024TIT'
		aRet[2] 	:= "FKL"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0020 //"Regra de T�tulo"
	
	Case cIdTreePos == "202" //Regra de Dedu��es
		aRet[1] 	:= 'FINA024DED'
		aRet[2] 	:= "FKV"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0021 //"Regra de Dedu��o"
		
	Case cIdTreePos == "203" //Regras Tabelas Progressivas
		aRet[1] 	:= 'FINA024TPR'
		aRet[2] 	:= "FKS"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0022 //"Regra de Tabelas Progressivas"
			
	Case cIdTreePos == "204" //Regra de C�lculo
		aRet[1] 	:= 'FINA024CAL'
		aRet[2] 	:= "FKN"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0023 //"Regra de C�lculo - T�tulos Financeiros"
		
	Case cIdTreePos == "205" //Regra de Vencimento
		aRet[1] 	:= 'FINA024VCT'
		aRet[2] 	:= "FKP"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0024 //"Regra de Vencimento"

	Case cIdTreePos == "206" //Regra de Reten��o
		aRet[1] 	:= 'FINA024RET'
		aRet[2] 	:= "FKO"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0025 //"Regra de Reten��o"
	
	Case cIdTreePos == "207" //Regra de Cumulatividade
		aRet[1] 	:= 'FINA024CUM'
		aRet[2] 	:= "FKT"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0026 //"Regra de Cumulatividade"

	Case cIdTreePos == "208" //Regra Valores Acess�rios
		aRet[1] 	:= 'FINA024VA'
		aRet[2] 	:= "FKU"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0027 //"Regra de Valores Acess�rios"
	
	Case cIdTreePos == "209" //Regras Financeiras de Reten��o
		aRet[1] 	:= 'FINA024RFI'
		aRet[2] 	:= "FKK"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0028 //"Regra Financeira"

    OtherWise
		aRet[1] 	:= ""
		aRet[2] 	:= ""
		aRet[3] 	:= ""
		aRet[4] 	:= ""		      
EndCase

Return ( aRet )

//------------------------------------------------------------------
/*/{Protheus.doc} x170Carga

Fun��o que far� a chamada da carga inicial das tabelas de cadastros

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Function x170Carga( lAutomato, oSay ) 
Local lCIN := AliasIndic("CIN") .And. FindFunction("xFisFormul") .and. F2B->(FieldPos("F2B_ALTERA")) > 0 .and. F2B->(FieldPos("F2B_DTALT")) > 0  .and. F2B->(FieldPos("F2B_HRALT")) > 0
Local lCJ := AliasIndic("CJ1") .And. AliasIndic("CJ0")

Default lAutomato	:= .F.

Begin Transaction

//Faz Carga inicial do perfil de Origem e Destino
AtualizaMsg( oSay, STR0036, lAutomato ) //"Processando carga inicial dos perfis de origem e destino"
FSA163CARG()

//Faz carga/atualiza��o dos ID's internos dos tributos.
AtualizaMsg( oSay, STR0037, lAutomato ) //"Processando carga/atualiza��o dos ID's internos"
FSA168F2C()

AtualizaMsg( oSay, STR0038, lAutomato ) //"Processando carga dos tributos"
FSA168F2E()

AtualizaMsg( oSay,  STR0039, lAutomato ) //"Processando carga dos perfis de opera��o"
FSA165CARG()

AtualizaMsg( oSay,  STR0040, lAutomato ) //"Processando carga das regras de apura��o"
FSA169CARG()

If lCIN
	AtualizaMsg( oSay,  STR0058, lAutomato ) //"Processando carga dos operandos prim�rios"
	FORMCARG()

	AtualizaMsg( oSay,  STR0062, lAutomato ) //"Processando carga Formulas de moedas estaduais"
	FSA167F29()	

	AtualizaMsg( oSay,  STR0061, lAutomato ) //"Processando carga Formulas de regras de Aliquota"
	FSA161F27()
	
	AtualizaMsg( oSay,  STR0060, lAutomato ) //"Processando carga Formulas de regras de base de c�lculo"		
	FSA162F28()

	AtualizaMsg( oSay,  STR0059, lAutomato ) //"Processando carga Formulas de regras de c�lculo dos tributos"
	FSA160F2B()	
Endif

If lCJ
	AtualizaMsg( oSay,  STR0075, lAutomato ) //"Processando carga do C�digo Situa��o Tribut�ria"
	FSA160ICJ0()
EndIf

AtuTpPF01() // Atualiza campos de tipo de perfil nas tabelas F21,F22,F23,F26,CIO,F24,F25

AtuTpPF02() // Atualiza campos de tipo de perfil nas tabelas F21,F22,F23,F26,CIO,F24,F25

AtuTpPF03() // Atualiza campos de tipo de perfil nas tabelas F21,F22,F23,F26,CIO,F24,F25

AtuTpPF04() // Atualiza campos de tipo de perfil nas tabelas F24,F25

AtualizaMsg( oSay, STR0041, lAutomato ) //"Cargas Conclu�das"

End Transaction

Return

//------------------------------------------------------------------
/*/{Protheus.doc} AtualizaMsg

Fun��o que ser� chamada para atualizar descri��o da barra de status

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function AtualizaMsg( oSay, cMsg, lAutomato )

If !lAutomato
	oSay:cCaption := (cMsg)
	ProcessMessages()
EndIF

Return

//------------------------------------------------------------------
/*/{Protheus.doc} GetCssTree

Fun��o que monta o CSS do menu lateral

@author Erick G. Dias
@since 04/02/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
static function GetCssTree()

Local cCSS	:= ""

cCSS +=	 "QTreeView{"
cCSS += "  font-size: 14px; /*tamanho do fonte*/"
cCSS +="  border: 2px solid #40698d; /*cor da borda*/"
cCSS +="  background: #F5FBE7"
cCSS +="}"
cCSS +="/*Caracteristicas do item*/"
cCSS +="QTreeView::item {"
cCSS +="  color: #40698d; /*cor da font*/"
cCSS +=""
cCSS +="  /*Pintura da barra esquerda do item selecionado*/"
cCSS +="  border: 1px solid #40698d; "
cCSS +="  border-top-color: transparent;"
cCSS +="  border-bottom-color: transparent;"
cCSS +="}"
cCSS +="/*Caracteristicas do item selecionado*/"
cCSS +="QTreeView::item:selected {"
cCSS +="  background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,"
cCSS +="              stop: 0 #FAC08F, stop: 1 #FDEADA); /*cor de fundo*/"
cCSS +="}"
cCSS +="/*Caracteristicas do item, quando mouse posicionado sobre ele*/"
cCSS +="QTreeView::item:hover {"
cCSS +="  background: #d8dfe7; /*cor de fundo*/"
cCSS += "}"

Return cCSS

//------------------------------------------------------------------
/*/{Protheus.doc} DicConf
    (Funcao respons�vel por Exibir Help de dicionario)
    
    @author Rafael Oliveira
    @since 16/06/2020
    @version P12.1.27
/*/
//------------------------------------------------------------------
Static Function HelpDic()
	Help("",1,"Help","Help",STR0003 ,1,0) //"Dicion�rio desatualizado, favor verificar atualiza��es do motor de c�lculo fiscal."
Return ""


//-------------------------------------------------------------------
/*/{Protheus.doc} GetVerRls Retorna a versao do release para liberar acesso as novas rotinas. 
@description Com essa fun��o podemos restringir a libera��o de algumas melhorias por release.
@author Bruce Mello
@since 22/02/2022
@version 12.1.37
/*/
//------------------------------------------------------------------
Function GetVerRls()
Local cVersao 	:= GetRpoRelease()
Local lVersao   := .F.

	If cVersao ==  ("12.1.033") .or. cVersao >= ("12.1.2210") 
		lVersao  := .T.
	EndIf

Return lVersao
