#INCLUDE "PCOC350.ch"
#include "protheus.ch"
#include "msgraphi.ch"

/*/
_F_U_N_C_苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲UNCAO    � PCOC350  � AUTOR � Edson Maricate        � DATA � 26.11.2003 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰ESCRICAO � Programa de Consulta ao arquivo de saldos mensais dos Cubos  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� USO      � SIGAPCO                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡DOCUMEN_ � PCOC350                                                      潮�
北砡DESCRI_  � Programa de Consulta ao arquivo de saldos mensair dos Cubos  潮�
北砡FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    潮�
北�          � partir do Menu ou a partir de uma funcao pulando assim o     潮�
北�          � browse principal e executando a chamada direta da rotina     潮�
北�          � selecionada.                                                 潮�
北�          � Exemplo: PCOC350(2) - Executa a chamada da funcao de visua-  潮�
北�          �                       zacao da rotina.                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCOC350(nCallOpcx)

Local bBlock
Local nPos
Private cCadastro	:= STR0001 //"Consulta Saldos na Data - Visoes"
Private aRotina := MenuDef()

	If nCallOpcx <> Nil
		nPos := Ascan(aRotina,{|x| x[4]== nCallOpcx})
		If ( nPos # 0 )
			bBlock := &( "{ |x,y,z,k,w,a,b,c,d,e,f,g| " + aRotina[ nPos,2 ] + "(x,y,z,k,w,a,b,c,d,e,f,g) }" )
			Eval( bBlock,Alias(),AKN->(Recno()),nPos)
		EndIf
	Else
		If SuperGetMV("MV_PCOCNIV",.F., .F.)
			PCOC351(nCallOpcx)
		Else
			mBrowse(6,1,22,75,"AKN")
		EndIf
	EndIf

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砅co350View篈utor  矱dson Maricate      � Data �  24/05/05   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     砯uncao que solicita parametros para utilizacao na montagem  罕�
北�          砫a grade e grafico ref. saldo gerencial do pco              罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function Pco350View(cAlias,nRecno,nOpcx)
Local aProcessa
Local nTpGraph
Local nDetalhe
Local aCfgAuxCube := {}
Local aAuxCube := {} 
Local lContinua := .T.
Local dData	 := dDataBase
Local nDirAcesso 	:= 0
Local aListArq := {}
Local aVarPriv := {}
Local cPicture := PadR("@E 999,999,999,999.99",25)

Local aTpGrafico:= {STR0004,; //"1=Linha"
							STR0005,; //"2=Area"
							STR0006,; //"3=Pontos"
							STR0007   ,; //"4=Barra"
							STR0008  ,; //"5=Piramide"
							STR0009    ,; //"6=Cilindro"
							STR0010,; //"7=Barra Horizontal"
							STR0011,; //"8=Piramide Horizontal"
							STR0012,; //"9=Cilindro Horizontal"
							STR0013,; //"10=Pizza"
							STR0014,; //"11=Forma"
							STR0015,; //"12=Linha Rapida"
							STR0016,; //"13=Flechas"
							STR0017,; //"14=Gantt"
							STR0018 } //"15=Bolha"

Private aConfig := {}

If SuperGetMV("MV_PCO_AKN",.F.,"2")!="1"  //1-Verifica acesso por entidade
	lContinua := .T.                        // 2-Nao verifica o acesso por entidade
Else
	nDirAcesso := PcoDirEnt_User("AKN", AKN->AKN_CODIGO, __cUserID, .F.)
    If nDirAcesso == 0 //0=bloqueado
		Aviso(STR0026,STR0037,{STR0028},2)//"Aten玢o"###"Usuario sem acesso a esta configura玢o de visao gerencial. "###"Fechar"
		lContinua := .F.
	Else
	    lContinua := .T. 
	EndIf
EndIf

If lContinua
	If ParamBox({ { 1 ,STR0019,Space(LEN(AL3->AL3_CODIGO))		  ,"@!" 	 ,""  ,"AL3" ,"" ,25 ,.F. },; //"Config Cubo"
						{3,STR0020,1,{STR0021,STR0022},40,,.F.},; //"Exibe Configura珲es"###"Sim"###"Nao"
						{ 1 ,STR0023,dData,"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Saldo em"
						{2,STR0038,2,{"1="+STR0021,"2="+STR0022},80,"",.F.},;//"Detalhar Cubos"###"Sim"###"Nao"
						{2,STR0024,4,aTpGrafico,80,"",.F.},;
						{3,STR0042,2,{STR0043,STR0044,STR0045},40,,.F.},; //"Mostrar valores"##"Unidade"##"Milhar"##"Milhao"
						{1,IIf(cPaisLoc$"RUS",STR0052,"Picture"),cPicture,"@!" 	 ,""  ,"" ,"" ,75 ,.F. };
						},STR0025,aConfig,,,,,,,"PCOC350",,.T.) //"Tipo do Grafico"###"Parametros"
	
		nDetalhe  := If(ValType(aConfig[4])=="N", aConfig[4], Val(aConfig[4]))

		aVarPriv := {}
		aAdd(aVarPriv, {"aConfig", aClone(aConfig)})                
		                                                             
		aProcessa := PcoCubeVis(AKN->AKN_CODIGO,1,"Pcoc350Sld",aConfig[1],aConfig[2], nDetalhe,.T.,aClone(aVarPriv))

		aAdd(aCfgAuxCube, aClone(aAuxCube))
	
		If !Empty(aProcessa)
			nTpGraph  := If(ValType(aConfig[5])=="N", aConfig[5], Val(aConfig[5]))
			PCOC350PFI(aProcessa,nTpGraph,aCfgAuxCube,If(nDetalhe==1,STR0039,STR0040),aConfig[6],,aListArq,aConfig[7])//"Conta Gerencial / Detalhes"###"Conta Gerencial"
		Else
			Aviso(STR0026,STR0027,{STR0028},2) //"Aten玢o"###"N鉶 existem valores a serem visualizados na configura玢o selecionada. Verifique as configura珲es da consulta."###"Fechar"
		EndIf
						
	EndIf
EndIf
	
Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砅coC350Sld篈utor  矱dson Maricate      � Data �  24/05/05   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     砯uncao utilizada na rotina de processamento do cubo         罕�
北�          砱erencial do pco                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PcoC350Sld(cConfig,cChave)
Local aRetFim
Local nCrdFim := 0
Local nDebFim := 0
Local nSldFim := 0

aRetFim := PcoRetSld(cConfig,cChave,aConfig[3])
nCrdFim := aRetFim[1, 1]
nDebFim := aRetFim[2, 1]

nSldFim := nCrdFim-nDebFim

Return {nSldFim}

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砅COC350PFI篈utor  矱dson Maricate      � Data �  24/05/05   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     砯uncao que processa o cubo gerencial do pco e exibe uma     罕�
北�          砱rade com o grafico                                         罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function PCOC350PFI(aProcessa,nTpGrafico,aCfgAuxCube,cDescri,nCasas, lShowGraph, aListArq, cPicture)

Local oDlg,oPanel,oPanel1,oPanel2
Local oView
Local oGraphic
Local aArea    := GetArea()
Local cAlias
Local nRecView
Local nStep
Local dx
Local nSerie
Local cTexto
Local aSize    := {}
Local aPosObj  := {}
Local aObjects := {}
Local aInfo    := {}
Local aView    := {}
Local nNivCub  := 0
Local nx
Local aButtons := {}
Local bEncerra := {|| If(Aviso(STR0029,STR0030, {STR0021, STR0022},2)==1, ( PcoArqSave(aListArq), oDlg:End() ), NIL) } //"Atencao"###"Deseja abandonar a consulta ?"###"Sim"###"Nao"
Local aTabMail :=	{}
Local cFiltro  := 'DTOS(AKD->AKD_DATA) <= "' +DTOS(aConfig[3])+'"'
Local nDivisor :=	1
Local lPergNome  := ( SuperGetMV("MV_PCOGRAF",.F.,"2") == "1" )
Local aTitle     := {cDescri,STR0035,STR0036}
Local lPCOC3502 := ExistBlock("PCOC3502")
Local lPCO350GRF := ExistBlock("PCO350GRF") 
Local lRetPe  := .T.

DEFAULT lShowGraph := .T.
DEFAULT aListArq := {}
DEFAULT cPicture := PadR("@E 999,999,999,999.99",25)

nCasas    := Iif(nCasas==1,0,IIf(nCasas==2,-3,-6))
nDivisor  := 10**(Abs(nCasas))
//cPicture  := If(nCasas==-6,"@E 999,999,999,999.99","@E 999,999,999,999")
cCadastro += IIf(nCasas==0,"" ,IIf(nCasas==-3,STR0046,STR0047))//" - (Valores em milhares)"##" - (Valores em milhoes)"

aButtons := { 	{"BMPPOST"	, {|| PmsGrafMail(oGraphic,Padr(cDescri,150),{cCadastro },aTabMail, NIL, 2, .T.) },STR0033,STR0034 }, ; //"Enviar Email"##"Email"
               	{"GRAF2D"	, {|| HideShowGraph(oPanel2, oPanel1, @lShowGraph) },STR0048,STR0049 },;//"Exibir/Esconder Grafico"###"Grafico"
				{"SALVAR"	, {|| PcoSaveGraf(oGraphic, lPergNome, .T., .F., aListArq) },STR0050,STR0051 } ; //"Imprimir/Gerar Grafico em formato BMP"##"Salva/BMP"
			}

aadd(aTabMail, aClone(aTitle) )

For nx := 1 to Len(aProcessa)
	aAdd(aView,{Substr(aProcessa[nx,1],1),aProcessa[nx,6],TransForm(Round(aProcessa[nx,2,1],2)/nDivisor* If(aProcessa[nx, 18] == "1",1,-1),cPicture)})
	aadd(aTabMail,{Substr(aProcessa[nx,1],1),aProcessa[nx,6],Alltrim(Transform(Round(aProcessa[nx,2,1],2)/nDivisor, cPicture) ) } )
Next


If !Empty(aView) 

	If lPCOC3502 
		ExecBlock( "PCOC3502",.F.,.F.,{ aView, aTabMail, aProcessa }) 
	EndIf 
	
	aSize := MsAdvSize(,.F.,400)
	aObjects := {}
	
	AAdd( aObjects, { 100, 100 , .T., .T. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE FONT oBold NAME "Arial" SIZE 0, -11 BOLD
	DEFINE FONT oFont NAME "Arial" SIZE 0, -10 
	DEFINE MSDIALOG oDlg TITLE cCadastro  From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	oDlg:lMaximized := .T.
	
	oPanel := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,10,22,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP

	oPanel1 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,40,40,.T.,.T. )
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel2 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,40,120,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_BOTTOM
	If !lShowGraph
		oPanel2:Hide()
	EndIf	

	@ 2,4 SAY AKN->AKN_DESCRI  of oPanel SIZE 120,9 PIXEL FONT oBold COLOR RGB(80,80,80)
	@ 3,3 BITMAP oBar RESNAME "MYBAR" Of oPanel SIZE BrwSize(@oDlg,0)/2,8 NOBORDER When .F. PIXEL ADJUST

	@ 12,2 SAY STR0041+DTOC(mv_par03) + IIf(nCasas==0,"" ,IIf(nCasas==-3,STR0046,STR0047)) Of oPanel PIXEL SIZE 640 ,79 FONT oBold //"Saldo em : "
	
	@ 3,2 MSGRAPHIC oGraphic SIZE aPosObj[1,4]-10,aPosObj[1,3]-aPosObj[1,1]-30 OF oPanel2
	oGraphic:Align := CONTROL_ALIGN_ALLCLIENT
	oGraphic:oFont := oFont
	
	oGraphic:SetMargins( 20,20,10,10 )
	oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	oGraphic:SetTitle( "", "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE )
	oGraphic:SetLegenProp( GRP_SCRRIGHT, CLR_WHITE, GRP_SERIES, .F. )
	nSerie	:= oGraphic:CreateSerie( nTpGrafico )
	oGraphic:l3D := .F.
	
	For nx := 1 to Len(aProcessa)
		If ExistBlock("PCO350GRF")
	   		lRetPe :=	ExecBlock("PCO350GRF",.F.,.F.,{aProcessa,nX})
   		EndIf	
   		If lRetPe
			oGraphic:Add(nSerie,aProcessa[nx,2,1],Substr(aProcessa[nx,1],1),CLR_BLUE)
   		EndIf
	Next 


	oView	:= TWBrowse():New( 2,2,aPosObj[1,4]-6,aPosObj[1,3]-aPosObj[1,1]-16,,aTitle,,oPanel1,,,,,,,oFont,,,,,.F.,,.T.,,.F.,,,) //"Descricao"###"Valor"
	oView:Align := CONTROL_ALIGN_ALLCLIENT
	oView:SetArray(aView)
	oView:bLine := { || aView[oView:nAT]}

	aButtons := aClone(AddToExcel(aButtons,{ {"ARRAY",STR0041+DTOC(mv_par03)+ IIf(nCasas==0,"" ,IIf(nCasas==-3,STR0046,STR0047)),{cDescri,STR0035,STR0036},aView} } ))//"Saldo em : "

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Eval(bEncerra)},{||Eval(bEncerra)},, aButtons)
EndIf

RestArea(aArea)

Return

Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1},; //"Pesquisar"
							{ STR0003, 	"Pco350View" , 0 , 2} }  //"Visualizar"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Adiciona botoes do usuario no Browse                                   �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ExistBlock( "PCOC3501" )
		//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de Centros Orcamentarios                                            �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOC3501                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		If ValType( aUsRotina := ExecBlock( "PCOC3501", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)
