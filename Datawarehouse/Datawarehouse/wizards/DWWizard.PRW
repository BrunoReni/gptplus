#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"    
#INCLUDE "DBTREE.CH"                                                                    
#INCLUDE "XMLXFUN.CH"
#INCLUDE "DWWIZARD.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "dwincs.ch"

#define NAME_XML_ORIGEM		"indicadoresnativos.xml"
#define NAME_XML_DESTINO	StrTran("dwtplindnat" + DToS(date()) + time() + ".xml", ":", "")
#define ENCODING 			"ISO-8859-1"
#define NAME_XML_QUERY      "indnativosquery.xml"
#define F_BLOCK				1024

// ########################################################################################
// Projeto: DATAWAREHOUSE
// Modulo : Wizard
// Fonte  : WizardDW - Wizard de Instalacao do DW para os indicadores nativos
// ---------+---------------------+--------------------------------------------------------
// Data     | Autor               | Descricao
// ---------+---------------------+--------------------------------------------------------
// 24.01.07 | 2147-Tatiane Matias | Versão 3
// ----------------------------------------------------------------------------------------
function DWWizard()       
	local aItens		:= {}
	local aQuery 		:= {}
	local aQuerysResult := {}      
 	local cDestFileName := NAME_XML_DESTINO
	local cIntro        := STR0003 + CRLF + CRLF + STR0058 + CRLF + STR0059 + CRLF + STR0060 + CRLF + STR0061 + CRLF +  CRLF + STR0062
	local cServidor	    := space(255)
	local cEnvironment  := space(255)    
	local cPath			:= getPathStart()
	local cXmlName 	    := cPath + NAME_XML_ORIGEM
	local cDriver		:= ""    
	local cPort			:= ""
	local cURL			:= space(255)
	local cDW			:= space(255)
	local cUser			:= "DWADMIN" + space(13)
	local cPassword	    := space(20)
	local nOpcYesNo		:= 1
	local nOpcLegend	:= 1
	local nVar			:= 0
	local lNewDW            := .F. 
	local oPanel
	local oEmpFilTree
	local oConsTree 
	local oConsSel      
	local oConsResult
	local oPanelCenter
	local oButton
	local oEmpFilResult
	local oDimTree
	local oCubesTree   
	local oNewDW
	local oRadio
	local oEdtUser
	local oEdtPsw
	local oSigaDWRadio

	private oPanelBottom
	private oMeter
	private oImpMeter
	private nMaxTamMeter	:= 0
	private oWizard                

	//-- Copia o arquivo do systemload para o startpath
	if !File(cXmlName)	
		if !File("\systemload\" + NAME_XML_ORIGEM)
		    conout(STR0088) //###"ATENÇÃO: Arquivo de Indicadores Nativos não encontrado!"
		    return nil
		else
			COPY FILE &("\systemload\" + NAME_XML_ORIGEM) TO &(cXmlName)
		endif
	endif
		       
	//-- Valida o arquivo XML - verifica se eh o XML dos Indicadores Nativos
	if !isValidMetaWizard(cXmlName)
		msgStop("XML Invalido")
		return nil
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³1º Panel - Apresentacao       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                             
	DEFINE WIZARD oWizard TITLE STR0001 MESSAGE STR0002 TEXT cIntro NEXT {|| .T. } FINISH {|| .T.} PANEL

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³2º Panel - Conexao            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// -- NEXT - verifica se o Servidor, porta e ambiente foram informados.
		//           Após validação dos campos, carrega a Tree de empresas do próximo panel
		//           com as empresa e filiais do SIGAMAT.
		CREATE PANEL oWizard HEADER STR0001 MESSAGE STR0004 BACK {|| .T. };
		    NEXT {|| if(VldCpos(1,{cServidor,cEnvironment}), MontaPanels(1, oEmpFilTree,,,, aItens),.F.) } ;
		    FINISH {|| .F.} PANEL
		oPanel := oWizard:GetPanel(2)

			cDriver 	:= GetPVProfString("Drivers",'ACTIVE',"",GetADV97())
			cPort 	    := GetPVProfString(cDriver,'PORT',"",GetADV97())
			cServidor  	:= GetServerIP() + ":" + cPort
			cServidor  	:= cServidor + space(255-len(cServidor))

			//Informar o Servidor, Porta e Ambiente
			@ 15,05 SAY STR0005         OF oPanel SIZE 90,8 PIXEL  
			@ 25,05 MsGet cServidor     OF oPanel SIZE 200,10 When .T. PIXEL	

			@ 45,05 SAY STR0006		    OF oPanel SIZE 120,8 PIXEL  
			@ 55,05 MsGet cEnvironment	OF oPanel SIZE 200,10 When .T. PIXEL	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³3º Panel - Empresa/Filial        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// -- NEXT - verifica se alguma empresa/filial foi selecionada.
		//           Após validação dos campos, carrega a Tree de consultas do próximo panel
		//           com as consultas existentes no arquivo XML de Indicadores Nativos.
		CREATE PANEL oWizard HEADER STR0001 MESSAGE STR0007 BACK {|| .T. };
		    NEXT {|| if(VldCpos(2,aItens), MontaPanels(2,,, oConsTree,,, aQuery,, cXMLName),.F.) };
		    FINISH {|| .F.} PANEL

		oPanel := oWizard:GetPanel(3)

			// Cria o DbTree co checkbox das Empresas e Filiais
			DEFINE DBTREE oEmpFilTree FROM 05,05 TO 120,270 OF oPanel CARGO

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³4º Panel - Consultas             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// -- NEXT - verifica se alguma consulta foi selecionada.
		//           Após validação dos campos, carrega os Tree de empresa/filial e 
		//           de consultas do próximo panel com as empresas/filiais e consultas
		//           selecionadas nos panels anteriores.
		CREATE PANEL oWizard HEADER STR0001 MESSAGE STR0009 BACK {|| .T. } ;
			NEXT {|| if(VldCpos(4,aQuerysResult), ;
			MontaPanels(3,, oEmpFilResult,, oConsResult, aItens,, aQuerysResult,, cServidor, cEnvironment), .F.) };
		 	FINISH {|| .F.} PANEL
		oPanel := oWizard:GetPanel(4)

			//Painel Central - botoes
			oPanelCenter 		 := tPanel():New(10,10,"",oPanel,,,,,CLR_WHITE,100,100) // cria o painel
			oPanelCenter:align	 := CONTROL_ALIGN_ALLCLIENT
	
			//Painel conterá a documentação das consultas
			oPanelBottom		 := tPanel():New(10,10,"",oPanel,,,,,CLR_WHITE,0,0)
			oPanelBottom:align 	 := CONTROL_ALIGN_BOTTOM 
			oPanelBottom:nHeight := 60
	
			// Botão Adicionar
			oButton 		:= tButton():New(0,10,STR0010,oPanelCenter,{ ||tranferNodeTree(oConsTree, oConsSel,  aQuery, aQuerysResult, .F. ) },100,20,,,,.T.) 
			oButton:nWidth	:= oPanelCenter:nWidth/2                                   
	
			// Botão Remover
			oButton			:= tButton():New(25,10,STR0011,oPanelCenter,{||tranferNodeTree(oConsSel, oConsTree, aQuerysResult, aQuery, .T.)},100,20,,,,.T.) 	
			oButton:nWidth	:= oPanelCenter:nWidth/2
	
			// Botão Adicionar Todos
			oButton			:= tButton():New(50,10,STR0012,oPanelCenter,{||transferTree(oConsTree, oConsSel, aQuery, aQuerysResult, .F.)},100,20,,,,.T.) 
			oButton:nWidth	:= oPanelCenter:nWidth/2
	
			// Botão Remover Todos
			oButton			:= tButton():New(75,10,STR0013,oPanelCenter,{||transferTree(oConsSel, oConsTree, aQuerysResult, aQuery, .T.)},100,20,,,,.T.) 
			oButton:nWidth	:= oPanelCenter:nWidth/2
	
			// Cria o DbTree no diálogo, ocupando o tamanho total do mesmo
			DEFINE DBTREE oConsTree FROM 00,00 TO 100,100 OF oPanel CARGO PIXEL 
				oConsTree:align := CONTROL_ALIGN_LEFT
				oConsTree:nWidth := 200    
				oConsTree:bchange := {|| clickedNode(oConsTree, aQuery) }
	
			//Tree com as consultas selecionadas
			DEFINE DBTREE oConsSel FROM 00,100  TO 100,200 OF oPanel CARGO PIXEL
				oConsSel:align	:= CONTROL_ALIGN_RIGHT
				oConsSel:nWidth 	:= 200       
				oConsSel:bchange := {|| clickedNode(oConsSel, aQuerysResult) }

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿    
		//³5º Panel - Resumo - Origem dos dados, Empresas, Filiais e Consultas selecionadas     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// -- NEXT - Carregará os Tree de dimensões e cubos do próximo panel com as
		//           dimensões, cubos e suas respectivas fonte de dados que estão no 
		//           arquivo XML de Indicadores Nativos.
		CREATE PANEL oWizard HEADER STR0001 MESSAGE STR0014 BACK {|| .T. };
		    NEXT {|| MontaPanels(4,,,,, aItens,, aQuerysResult, cXMLName, cServidor, cEnvironment, oDimTree, oCubesTree) };
		    FINISH {|| .F.} PANEL
		oPanel := oWizard:GetPanel(5)

			//Tree com as Empresas e Filiais selecionadas
			@ 25,05 SAY STR0016 	OF oPanel SIZE 90,8 PIXEL  
			DEFINE DBTREE oEmpFilResult FROM 35,05 TO 120,140 OF oPanel CARGO

  			//Tree com as consultas selecionadas
			@ 25,150 SAY STR0017	OF oPanel SIZE 60,8 PIXEL  
			DEFINE DBTREE oConsResult FROM 35,150 TO 120,280 OF oPanel CARGO

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿    
		//³6º Panel - Resumo (cont.) - Dimensoes, Cubos e fontes de dados    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CREATE PANEL oWizard HEADER STR0001 MESSAGE STR0014 BACK {|| .T. } NEXT {|| .T. } FINISH {|| .F.} PANEL
		oPanel := oWizard:GetPanel(6)
		 
			// Tree contento todas as Dimensoes
			@ 05,05 SAY STR0018 OF oPanel SIZE 90,8 PIXEL  
			DEFINE DBTREE oDimTree FROM 15,05 TO 110,140 OF oPanel CARGO OPEN
                        
			// Tree contento todos os Cubos
			@ 05,150 SAY STR0019	OF oPanel SIZE 80,8 PIXEL  
			DEFINE DBTREE oCubesTree FROM 15,150 TO 110,280 OF oPanel CARGO

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿    
		//³7º Panel - Inicio da instalação do SigaDW     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// -- EXEC - Ao ativar esse panel um novo metadados (arquivo XML) será criado.
		//           Será criado de acordo com os parâmetros informados nos panels anteriores.
		CREATE PANEL oWizard HEADER STR0001 MESSAGE STR0063 BACK {|| .F. } NEXT {|| .T. } FINISH {|| .F. } ;
		       EXEC {|| procIndNativos(cPath, cXmlName, cDestFileName, cServidor, cEnvironment, aItens, aQuerysResult) } PANEL
		oPanel := oWizard:GetPanel(7)

			@ 015,05 SAY STR0021 OF oPanel SIZE 100, 8 PIXEL  
			@ 060,10 METER oMeter VAR nVar SIZE 230,010 TOTAL nMaxTamMeter OF oPanel PIXEL    

		//================================================
		//= 8º Panel - Informar URL e DW                 =
		//================================================
		// -- NEXT - Verifica se a URL e o DW foi informado.
		CREATE PANEL oWizard HEADER STR0001 MESSAGE STR0065 BACK {|| oWizard:SetPanel(6), .F. };
			    NEXT {|| VldCpos(3,{cURL,cDW,aItens}) } ;
				FINISH {|| .F. } PANEL
		oPanel := oWizard:GetPanel(8)

			@ 15,05 	SAY STR0036		OF oPanel SIZE 400, 8 PIXEL  
			@ 25,05 	MsGet cURL 		OF oPanel SIZE 200,10 When .T. PIXEL	
			@ 45,05 	SAY STR0037		OF oPanel SIZE 400, 8 PIXEL  
			@ 55,05 	MsGet cDW		OF oPanel SIZE 200,10 When .T. PIXEL	

			oNewDW 					:= TCHECKBOX():Create(oPanel)
			oNewDW:cName 			:= "oNewDW"
			oNewDW:cCaption 		:= STR0075
			oNewDW:nLeft 			:= 05
			oNewDW:nTop 			:= 135
			oNewDW:nWidth 			:= 300
			oNewDW:nHeight 			:= 17
			oNewDW:lShowHint 		:= .F.
			oNewDW:lReadOnly 		:= .F.
			oNewDW:Align 			:= 0
			oNewDW:cVariable 		:= "lNewDW"
			oNewDW:bSetGet 			:= {|u| If(PCount()>0,lNewDW:=u,lNewDW) }
			oNewDW:lVisibleControl 	:= .T.

		//================================================
		//= 9º Panel - Download ou importacao do XML     =
		//================================================
		// -- NEXT - Verifica qual a opção foi selecionada (download ou importação).
		//           Se a opção for download do arquivo, irá ativar direto o panel 11. 
		//           Se a opção for importação do arquivo para o DW, irá ativar primeiro
		//			 o panel 10 para informar usuário e senha do SIGADW.
		CREATE PANEL oWizard HEADER STR0001 MESSAGE STR0064 BACK {|| .T. } ;
			NEXT {|| if(nOpcLegend == 1, oWizard:SetPanel(11), oWizard:SetPanel(10)), .F. } ;
			FINISH {|| .F. } PANEL
		oPanel := oWizard:GetPanel(9)

		@ 015,05 SAY STR0032 OF oPanel SIZE 400, 8 PIXEL  
		
 		oRadio 			:= TRadMenu():New( 035 , 010 , {STR0034,STR0035} , NIL , oPanel , NIL , NIL , NIL , NIL , NIL , NIL , NIL , 115 , 010 , NIL , NIL , NIL , .T. )
		oRadio:bSetGet	:= { |nItem| IF( nItem <> NIL , nOpcLegend := nItem , nOpcLegend ) }                                                                             
		oRadio:bChange	:= { || ChangeMsGet(nOpcLegend, oEdtUser, oEdtPsw) }
		                            
		//=================================================================================
		//= 10º Panel - Importacao do arquivo XML - Informar usuário e senha do SIGADW    =
		//=================================================================================
		CREATE PANEL oWizard HEADER STR0001 MESSAGE STR0064 BACK {|| .T. } ;
			NEXT {|| .T.  } ;
			FINISH {|| .F. } PANEL
		oPanel := oWizard:GetPanel(10)
		
		@ 015,05 SAY STR0033 OF oPanel SIZE 400, 8 PIXEL  
		
		@ 30,05 SAY STR0030 					OF oPanel SIZE 400, 8 PIXEL  
		@ 40,05 MsGet oEdtUser Var cUser		OF oPanel SIZE 200,10 When .F. PIXEL	
		@ 55,05 SAY STR0031 					OF oPanel SIZE 400, 8 PIXEL  
		@ 65,05 MsGet oEdtPsw  Var cPassword 	OF oPanel SIZE 200,10 When .F. PIXEL PASSWORD

		//==============================================================================
		//= 11º Panel - Download ou Importacao do arquivo XML - barra de progressao    =
		//==============================================================================
		// -- EXEC - Ao ativar esse panel será iniciado o processo de download ou 
		//		     importação (dependendo da opção selecionada no panel 9) do metadados 
		//			 gerados.
		CREATE PANEL oWizard HEADER STR0001 MESSAGE STR0064 BACK {|| .T. } ;
			NEXT {|| .T. } ;
			FINISH {|| .F. } ;
	        EXEC {|| if(nOpcLegend == 1, DownloadXML(cDestFileName), ImportDW(cURL, cDW, cUser, cPassword, lNewDW, cPath, cDestFileName)) } PANEL

		oPanel := oWizard:GetPanel(11)

		@ 015,05 SAY STR0077 OF oPanel SIZE 250, 8 PIXEL  
		@ 060,10 METER oImpMeter VAR nVar SIZE 230,010 TOTAL nMaxTamMeter OF oPanel PIXEL    

		//==================================================================
		//= 12º Panel - Abrir SigaDW                     				   =	
		//==================================================================
		// -- FINISH - Ao finalizar esse panel, caso a opção selecionada for
		//			   "sim", irá abrir o browser na tela de logindo SIGADW.
		CREATE PANEL oWizard HEADER STR0001 MESSAGE "" ;
			FINISH {|| if(nOpcYesNo == 2, OpenDW(cURL), .T.) } PANEL

//		CREATE PANEL oWizard HEADER STR0001 MESSAGE "" BACK {|| .F. } NEXT {|| .F. } ;
//			FINISH {|| if(nOpcYesNo == 2, OpenDW(cURL), .T.) } PANEL
		oPanel := oWizard:GetPanel(12)

		@ 015,05 SAY STR0066 OF oPanel SIZE 400, 8 PIXEL  

 		oSigaDWRadio		 := TRadMenu():New( 035 , 010 , {STR0068,STR0067} , NIL , oPanel , NIL , NIL , NIL , NIL , NIL , NIL , NIL , 115 , 010 , NIL , NIL , NIL , .T. )
		oSigaDWRadio:bSetGet := { |nItem| IF( nItem <> NIL , nOpcYesNo := nItem , nOpcYesNo ) }                                                                             

		@ 060,05 SAY STR0072 OF oPanel SIZE 250, 10 PIXEL  
		@ 070,05 SAY STR0073 OF oPanel SIZE 250, 10 PIXEL  

	ACTIVATE WIZARD oWizard CENTERED  WHEN {||.T.}

    //Liberar memoria
	aItens			:= NIL
	aQuery 			:= NIL
	aQuerysResult 	:= NIL
 	cDestFileName 	:= NIL
	cIntro        	:= NIL
	cServidor	    := NIL
	cEnvironment  	:= NIL
	cPath			:= NIL
	cXmlName 	    := NIL
	cDriver			:= NIL
	cPort			:= NIL
	cURL			:= NIL
	cDW				:= NIL
	cUser			:= NIL
	cPassword	    := NIL
	nOpcYesNo		:= NIL
	nOpcLegend		:= NIL
	lNewDW          := NIL
	oPanel			:= NIL
	oEmpFilTree		:= NIL
	oConsTree 		:= NIL
	oConsSel      	:= NIL
	oConsResult    	:= NIL
	oPanelCenter	:= NIL
	oButton			:= NIL
	oEmpFilResult	:= NIL
	oDimTree		:= NIL
	oCubesTree   	:= NIL
	oNewDW			:= NIL
	oRadio			:= NIL
	oEdtUser		:= NIL
	oEdtPsw			:= NIL
	oSigaDWRadio	:= NIL
	DelClassIntf()
	
return nil
                             
// --------------------------------------------------------------------------------------
// Essa funcao ira montar o panel solicitado.
// ----------------------------------------------------------------------------------------
static function MontaPanels(nPanel, oEmpFilTree, oEmpFilResult, oConsTree, oConsResult, aItens, aQuery, ;
                            aQuerysResult, cXMLName, cServidor, cEnvironment, oDimTree, oCubesTree, cPath, ;
                            cDestFileName, nOpcLegend, cURL, cDW, cUser, cPassword, lNewDW)
	local lRetorno := .T.
	
	//-- Panel de Empresas e Filial
	if nPanel == 1
		MsgRun(STR0074 + STR0080,, {|| lRetorno := MontaEmpFilPanel(oEmpFilTree, aItens)})
		
	//-- Panel de Consultas
	elseif nPanel == 2
		MsgRun(STR0074 + STR0081,, {|| lRetorno := MontaQuerysPanel(oConsTree, aQuery, cXMLName)})

	//-- Panel de Resumo
	elseif nPanel == 3
		MsgRun(STR0074 + STR0082,, {|| lRetorno := MontaResumoPanel(cServidor, cEnvironment, oEmpFilResult, aItens, oConsResult, aQuerysResult)})

	//-- Panel de Dimensões e Cubos
	elseif nPanel == 4
		MsgRun(STR0074 + STR0083,, {|| lRetorno := MontaRes2Panel(oDimTree, oCubesTree, cServidor, cEnvironment, aItens, aQuerysResult, cXmlName)})
	endif

return lRetorno

// --------------------------------------------------------------------------------------
// Essa funcao ira montar o panel de Empresas e Filial
// ----------------------------------------------------------------------------------------
static function MontaEmpFilPanel(poTree, paItens)
	local aAreaSM0 		:= SM0->( GetArea() )
	local cEmpresa		:= ""    
	local cPrompt		:= ""

	oPanel := oWizard:GetPanel(3)
	
	poTree:Reset()

	dbSelectArea("SM0")
	SM0->( dbSetOrder(1) )
	SM0->( dbGoTop() )
			                              	
	SM0->( dbGoTop() )
	while SM0->(! Eof())
		cEmpresa := SM0->M0_CODIGO
		cPrompt 	:= (cEmpresa + " - " + SM0->M0_NOME)
		cPrompt 	+= Space(33 - len(cPrompt))
				                            
		//Adiciona o no Empresa
		DBADDTREE poTree PROMPT cPrompt CARGO Padr(cEmpresa, 30)
					
		//Adiciona o item "Todas as filiais dessa empresa"
		//DBADDITEM poTree PROMPT (STR0008) RESOURCE "UNCHECKED" CARGO  ("*" + cEmpresa)
		//aAdd(paItens, {cEmpresa, "  ", SM0->M0_NOME, "UNCHECKED"})
				  
		//Adiciona as filiais abaixo do no Empresa
		while SM0->(! Eof() .and. cEmpresa == SM0->M0_CODIGO)
			DBADDITEM poTree PROMPT (SM0->M0_CODFIL + " - " + SM0->M0_FILIAL) RESOURCE "UNCHECKED" CARGO  ("#" + cEmpresa + "/" + dwStr(SM0->M0_CODFIL))
			aAdd(paItens, {cEmpresa, SM0->M0_CODFIL, SM0->M0_FILIAL, "UNCHECKED"})
			SM0->( dbSkip() )                                 
		enddo
		DBENDTREE poTree
	enddo                  

	poTree:Refresh()
	poTree:bLDblClick := { || dwTreeChk(@poTree, paItens) }       

	RestArea( aAreaSM0 )

	aAreaSM0 		:= NIL
	cEmpresa		:= NIL
	cPrompt			:= NIL
	DelClassIntf()
return .T.

// --------------------------------------------------------------------------------------
// Essa funcao ira mudar a imagem do item da Tree para selecionado ou tirar a selecaorsrs
// poTree: o objeto Tree que sera modificado 
// paItens: Array contendo todos os Itens da Tree
// paItensResult: Array contendo apenas os Itens da Tree selecionados
// ----------------------------------------------------------------------------------------
static function dwTreeChk(poTree, paItens)
	local cCargo			:= poTree:GetCargo()
	local nPos 				:= 0
	local nItem				:= 0
	local cPai 				:= substr(cCargo,2,2)   
	local nChecked			:= 0 
	local nItens			:= 1   
	local nChecado			:= 0

	//Trocar a imagem apenas quando for filho (#-Item filho *-Item "Todos os filhos")  
	
	if (substr(cCargo,1,1) == "#" .or. substr(cCargo,1,1) == "*")
		if substr(cCargo,1,1) == "#"
			nPos := aScan(paItens,{|x| x[1]==Alltrim(substr(cCargo,2,2)) .and. rTrim(x[2])==rTrim( substr(cCargo,5,12) )})   
		else             
			nPos := aScan(paItens,{|x| x[1]==Alltrim(substr(cCargo,2,2)) .and. x[2]=="  "})
		endif
	
		//Se estiver selecionado, mudar a imagem para "UNCHECKED"
		If (paItens[nPos][4] == "CHECKED") //Se a sala estiver com a figura 'checked.bmp'
			poTree:ChangeBMP("UNCHECKED","CHECKED",,,cCargo) //Sua figura mudara para 'unchecked.bmp' 
			paItens[nPos][4] := "UNCHECKED"                   
		else  
			aEval(paItens, { |x| if(x[4] == "CHECKED" .and. !empty(x[2]), nChecked++, nChecked) })
			if nChecked < 5 .or. substr(cCargo,1,1) == "*"
				//Se nao estiver selecionado, mudar a imagem para "CHECKED"
				poTree:ChangeBMP("CHECKED","UNCHECKED",,,cCargo) //Sua figura mudara para 'unchecked.bmp' 
							
				paItens[nPos][4] := "CHECKED"                

			else
				msgAlert(STR0097) //###"Seleção de Filiais limitado a 5."
			endif                           
        endif
		poTree:Refresh()
               
		//Se for item filho e nao esta selecionado (UNCHECKED), o item 
 		// "Todas as filiais dessa Empresa" tambem devera nao estar selecionado
		if substr(cCargo,1,1) == "#" .and. paItens[nPos][4] == "UNCHECKED"
			if poTree:TreeSeek("*" + cPai)
				nItem := aScan(paItens,{|x| x[1]==Alltrim(cPai) .and. x[2]=="  "})  				
				poTree:ChangeBMP("UNCHECKED","CHECKED",,,poTree:GetCargo()) //Sua figura mudara para 'unchecked.bmp' 
				paItens[nItem][4] := "UNCHECKED"                
			endif

		//Se for item "Todas as filiais dessa Empresa" e esta selecionado (CHECKED), todos os itens
  		// filhos (itens da mesma Empresa) tambem deverao estar selecionados
		elseif substr(cCargo,1,1) == "*" .and. paItens[nPos][4] == "CHECKED"
			For nItem := 1 to len(paItens)
				if paItens[nItem][1] == cPai
					if poTree:TreeSeek("#"+paItens[nItem][1]+"/"+paItens[nItem][2])
						poTree:ChangeBMP("CHECKED","UNCHECKED",,,poTree:GetCargo()) //Sua figura mudara para 'unchecked.bmp' 
						paItens[nItem][4] := "CHECKED"
					endif
				endif
			next nItem
		elseif substr(cCargo,1,1) == "*" .and. paItens[nPos][4] == "UNCHECKED"
			For nItem := 1 to len(paItens)
				if paItens[nItem][1] == cPai
					if poTree:TreeSeek("#"+paItens[nItem][1]+"/"+paItens[nItem][2])
						poTree:ChangeBMP("UNCHECKED","CHECKED",,,poTree:GetCargo()) //Sua figura mudara para 'unchecked.bmp' 
						paItens[nItem][4] := "UNCHECKED"
					endif
				endif
			next nItem
		endif           
		poTree:TreeSeek(cCargo)
		poTree:Refresh()
	endif

	cCargo	:= NIL
	nPos 	:= NIL
	nItem	:= NIL
	cPai 	:= NIL
	DelClassIntf()
return .t.
                      
// -------------------------------------------------------------------
// Essa funcao ira montar o Panel de consultas dos indicadores nativos
// -------------------------------------------------------------------
static function MontaQuerysPanel(poTree, paQuery, pcXMLName)

	//Retorna em array todas as tags de consulta do arquivo XML
	paQuery 		:= getConsXML(pcXMLName)

	//Monta a Tree de Consulta
	createTree(poTree, paQuery)

return .T.
                
// -------------------------------------------------------------------
// Essa funcao ira montar o Panel de resumo (Servidor:Porta, Ambiente, 
// empresas selecionas e consultas selecionadas).
// -------------------------------------------------------------------
static function MontaResumoPanel(pcServidor, pcEnvironment, poEmpFilTree, paItens, poConsResult, paQuerysResult)
	local oPanel    
	local nItem		  := 0  
	local cEmpresa	  := ""
	local lCreateTree := .F.  
	local cPaiAnt	  := ""
	local nAddedTreeItem := 0

	oPanel := oWizard:GetPanel(5)
	poEmpFilTree:Reset()
	poConsResult:Reset()

		//Servidor, Porta e Ambiente informados no primeiro Panel.
		@ 05,05 SAY STR0015 	OF oPanel SIZE 90,8 PIXEL  
		@ 15,10 SAY (AllTrim(pcServidor) + " / " + AllTrim(pcEnvironment)) OF oPanel SIZE 200,200 PIXEL  

		aSort( paItens,,, { |x,y| x[1]+x[2] < y[1]+y[2] } )

		//Para cada Empresa/Filial selecionada incluir no Tree poTree
		for nItem := 1 to len(paItens)
			if !(cEmpresa == paItens[nItem][1])
				lCreateTree := .F.
				cEmpresa :=  paItens[nItem][1]
				
				if nAddedTreeItem > 0
					DBENDTREE poEmpFilTree
				endif
				
				if aScan(paItens, {|x| x[1] == cEmpresa .and. x[4] == "CHECKED"} ) > 0
					DBADDTREE poEmpFilTree PROMPT Padr(paItens[nItem][1] + " - " + paItens[nItem][3],30) CARGO Space(30)
					lCreateTree := .T.
					nAddedTreeItem++
				endif
			elseif paItens[nItem][4] == "CHECKED"
				DBADDITEM poEmpFilTree PROMPT (paItens[nItem][2] + " - " + paItens[nItem][3]) CARGO Space(30)
				nAddedTreeItem++
			endif
		next nItem
			
		if lCreateTree
			DBENDTREE poEmpFilTree
		endif  

		//Ordena por Grupo
		aSort( paQuerysResult,,, { |x,y| x[1] < y[1] } )

		//Para cada consulta selecionada incluir no Tree poSelConsTree
		for nItem := 1 to len(paQuerysResult)
			if !(cPaiAnt == paQuerysResult[nItem][1])
				if nItem > 1
					DBENDTREE poConsResult
				endif
				DBADDTREE poConsResult PROMPT Padr(paQuerysResult[nItem][1],30) CARGO Space(30)
				lCreateTree := .T.
				cPaiAnt 	:= paQuerysResult[nItem][1]
			endif          
			DBADDITEM poConsResult PROMPT (paQuerysResult[nItem][2] + " - " + paQuerysResult[nItem][3]) CARGO Space(30)
	   next nItem    
		      
	   if lCreateTree
			DBENDTREE poConsResult
		endif
		
	oPanel    	:= NIL
	nItem		:= NIL
	cEmpresa	:= NIL
	lCreateTree := NIL  
	cPaiAnt	  	:= NIL
	DelClassIntf()

return .T.

// -------------------------------------------------------------------
// Essa funcao ira montar o Panel de dimensões e cubos existentes no
// arquivo de indicadores nativos.
// -------------------------------------------------------------------
static function MontaRes2Panel(poDimTree, poCubesTree, pcServidor, pcEnvironment, paItens, paQuerysResult, pcXmlName)
	local aDimensoes		:= {}
	local aCubos			:= {}    
	local oPanel			:= oWizard:GetPanel(6)
	local oIndXML

	//Carrega o arquivo XML de indicadores nativos
	oIndXML := DWLoadXML(pcXmlName,.F.)

	//Retorna as dimensoes do XML em array
	aDimensoes 	:= retNode2Arr(oIndXML:_DATAWAREHOUSE:_DIMENSIONS, "DIMENSOES")
	//Adiciona as informacoes do array na Tree de dimensoes
	poDimTree:Reset()
	DWcreateTree(poDimTree, aDimensoes)

	//Retorna os cubos do XML em array
	aCubos		:= retNode2Arr(oIndXML:_DATAWAREHOUSE:_CUBES, "CUBOS")
	//Adiciona as informacoes do array na Tree de cubos
	poCubesTree:Reset()
	DWcreateTree(poCubesTree, aCubos)

	oButton	:= tButton():New(120,240,STR0020,oPanel,{ || GeraHtml(pcServidor, pcEnvironment, paItens, paQuerysResult, aDimensoes, aCubos) },40,13,,,,.T.) 
	
	oPanel			:= NIL
	oIndXML			:= NIL

	DelClassIntf()      
	
return .T.

// --------------------------------------------------------------------------------------
// Essa funcao ira gerar o arquivo ResumoWizard.html. Esse arquivo ira conter os dados
// informados pelo usuario no Wizard (Informacoes de conexao, empresas/filiais e consultas
// selecionadas, dimensoes e cubos e suas respectivas fontes de dados.
// pcServidor: Servidor e Porta informados pelo usuario
// pcEnvironment: Ambiente informado pelo usuario
// paItensResult: Empresas e Filiais selecionadas
// paQuerysResult: COnsultas selecionadas
// paDimensoes: Dimensoes e suas Fontes de Dados
// paCubos: Cubos e suas fontes de dados
// ----------------------------------------------------------------------------------------
static function GeraHtml(pcServidor, pcEnvironment, paItens, paQuerysResult, paDimensoes, paCubos)
	local cHtml 	:= ""                
	local cGrupoAnt := ""
	local cPath		:= ""
	local nInd		:= 0
	local nAuxInd	:= 0  
	local nHandle	:= 0    
	local aAux		:= {}

	cHtml := "<html>"
	cHtml += " <head>"
	cHtml += "<title>" + STR0014 + "-" + STR0001 + "</title>"
	cHtml += "<style type='text/css'>"
	cHtml += "	.titulo"
	cHtml += "{"
	cHtml += "	color: #FFFFFF;"
	cHtml += "	background-color: #19167D;"
	cHtml += "	font-weight: bold;"
	cHtml += "	text-align: left;"
	cHtml += "	padding-left:15px;"
	cHtml += "}"
	cHtml += "tr.meiaLinha"
	cHtml += "{"
	cHtml += "  height:5px;"
	cHtml += "}"
	cHtml += ".zebraOff, .zebraOff:hover, tr.rollOverZebraOff"
	cHtml += "{"
	cHtml += "	background-color: #EFEFEF;"
	cHtml += "	color: #666666;"
	cHtml += "}"
	cHtml += ".zebraOn, .zebraOn:hover, tr.rollOverZebraOn"
	cHtml += "{    "
	cHtml += "	background-color: #FFFFFF;"
	cHtml += "	color: #666666;"
	cHtml += "}"
	cHtml += "</style>"
	cHtml += "</head>"
	cHtml += "<body>"
	cHtml += "<table width='100%'>"
	cHtml += "<tr><td colspan='3' class='titulo'>" + STR0014 + "-" + STR0001 + "</td></tr>"
	cHtml += "<tr class='meiaLinha'><td>&nbsp;</td><td width='40%'></td><td></td></tr>"
	cHtml += "<tr class='zebraOff'><td colspan='3'>" + STR0015 + "</td></tr>"
	cHtml += "<tr class='zebraOn'><td>&nbsp;</td><td width='40%'>" + STR0005 + "</td><td>" + pcServidor + "</td></tr>"
	cHtml += "<tr class='zebraOn'><td>&nbsp;</td><td width='40%'>" + STR0006 + "</td><td>" + pcEnvironment + "</td></tr>
	cHtml += "<tr class='meiaLinha'><td>&nbsp;</td><td width='40%'></td><td></td></tr>"
	cHtml += "<tr class='zebraOff'><td colspan='3'>" + STR0016 + "</td></tr>"
	cHtml += "<tr class='zebraOn'><td>&nbsp;</td><td width='40%'><u>"+STR0022+"</u></td><td><u>"+STR0023+"</u></td></tr>"

	aSort( paItens,,, { |x,y| x[1]+x[2] < y[1]+y[2] } )
	for nInd := 1 to len(paItens)  
		if paItens[nInd][2] <> "  " .and. paItens[nInd][4] == "CHECKED"
			cHtml += "		<tr><td>&nbsp;</td><td width='40%'>" + paItens[nInd][1] + "</td><td>" + paItens[nInd][2] + "</td></tr>
		endif
	next nInd

	cHtml += "<tr class='meiaLinha'><td>&nbsp;</td><td width='40%'></td><td></td></tr>"
	cHtml += "<tr class='zebraOff'><td colspan='3'>"+STR0017+"</td></tr>"
	cHtml += "<tr class='zebraOn'><td>&nbsp;</td><td width='40%'><u>"+STR0024+"</u></td><td><u>"+STR0025+"</u></td></tr>"
	
	for nInd := 1 to len(paQuerysResult)  
		if paQuerysResult[nInd][1] == cGrupoAnt
			cHtml += "		<tr><td>&nbsp;</td><td width='40%'>&nbsp;</td><td>" + paQuerysResult[nInd][2] + "</td></tr>"
		else 
			cHtml += "		<tr><td>&nbsp;</td><td width='40%'>"+paQuerysResult[nInd][1]+"</td><td>" + paQuerysResult[nInd][2] + "</td></tr>"
			cGrupoAnt := paQuerysResult[nInd][1]
		endif
	next nInd

	cHtml += "<tr class='meiaLinha'><td>&nbsp;</td><td width='40%'></td><td></td></tr>"
	cHtml += "<tr class='zebraOff'><td colspan='3'>"+STR0018+"</td></tr>"
	cHtml += "<tr class='zebraOn'><td>&nbsp;</td><td width='40%'><u>"+STR0026+"</u></td><td><u>"+STR0027+"</u></td></tr>"

	aAux := paDimensoes[1][2]
	for nInd := 1 to len(aAux)                              
		if len(aAux[nInd][2][2]) > 0 
			for nAuxInd := 1 to len(aAux[nInd][2][2])
				cHtml += "		<tr><td>&nbsp;</td><td width='40%'>" + aAux[nInd][1] + "</td><td>" + aAux[nInd][2][2][nAuxInd] + "</td></tr>"
			next nAuxInd
		else
			cHtml += "		<tr><td>&nbsp;</td><td width='40%'>" + aAux[nInd][1] + "</td><td>&nbsp;</td></tr>"
		endif
	next nInd

	cHtml += "<tr class='meiaLinha'><td>&nbsp;</td><td width='40%'></td><td></td></tr>"
	cHtml += "<tr class='zebraOff'><td colspan='3'>"+STR0019+"</td></tr>"
	cHtml += "<tr class='zebraOn'><td>&nbsp;</td><td width='40%'><u>"+STR0028+"</u></td><td><u>"+STR0027+"</u></td></tr>"

	aAux := paCubos[1][2]
	for nInd := 1 to len(aAux)                   
		if len(aAux[nInd][2][2]) > 0
			for nAuxInd := 1 to len(aAux[nInd][2][2])
				cHtml += "		<tr><td>&nbsp;</td><td width='40%'>" + aAux[nInd][1] + "</td><td>" + aAux[nInd][2][2][nAuxInd] + "</td></tr>"
			next nAuxInd
		else
			cHtml += "		<tr><td>&nbsp;</td><td width='40%'>" + aAux[nInd][1] + "</td><td>&nbsp;</td></tr>"
		endif
	next nInd

	cHtml += "</table>"
	cHtml += "</body>"
	cHtml += "</html>"         
	
	cPath := AllTrim(cGetFile( "*.htm|*.html" , STR0029 , 0 ,  , .F. , GETF_LOCALHARD+GETF_RETDIRECTORY ))
	If Empty(cPath)
		MsgInfo( STR0038, STR0039 )
		return .f.
	elseif substr(cPath, len(cPath),1) == "\"
		MsgInfo( STR0057, STR0039 )
		return .f.     
	elseif at(".htm", cPath) == 0 .and. at(".html", cPath) == 0
		cPath += ".html"
	EndIf

	nHandle := MSFCREATE(cPath)
	If FERROR() # 0 .Or. nHandle < 0
		MsgInfo( STR0040 + cPath, STR0039 )
		FClose(nHandle)
		return nil
	EndIf               

	FWrite(nHandle,cHtml)
	FClose(nHandle)
	MsgInfo( STR0041 + cPath + STR0042, STR0039 )

	cHtml 		:= NIL
	cGrupoAnt 	:= NIL
	cPath		:= NIL
	nInd		:= NIL
	nAuxInd		:= NIL
	nHandle		:= NIL
	aAux		:= NIL
	DelClassIntf()
	
return nil

// --------------------------------------------------------------------------------------
// Essa funcao ira abrir o SigaDW. O browse a ser aberto será o informado no parâmetro
// MV_WFTIBRW
// ----------------------------------------------------------------------------------------
static function OpenDW(pcURL)
	local cExecBrowser := GetMV("MV_WFTIBRW")
	local cHttpServer  := ""
	local cHtmlFile    := ""
	local lRetorno     := .T.
	
	if !empty(cExecBrowser)
		cHttpServer := AllTrim(pcURL)
		cHtmlFile	:= "w_sigadw3.apw"
	
		if Right( cHttpServer, 1 ) <> "/"
			cHttpServer += "/"
		end
		
		WinExec( cExecBrowser + " " + cHttpServer + cHtmlFile )
	else
		msgAlert(STR0070)
		lRetorno := .F.
	endif

	cExecBrowser := NIL
	cHttpServer  := NIL
	cHtmlFile    := NIL
	DelClassIntf()
	
return lRetorno

// -------------------------------------------------------------------
// Essa funcao ira validar os campos de cada panel.
// -------------------------------------------------------------------
static function VldCpos(pnTela, paInfo)
	local lReturn := .T.   
	
	default pnTela := 0
	default paInfo := {}

	//-- Validar o 2º panel - Servidor:porta e Ambiente devem ser informados.
	if pnTela == 1
		if Empty(AllTrim(paInfo[1])) .or. Empty(AllTrim(paInfo[2])) //Servidor ou Environment
			msgAlert(STR0004)
			lReturn := .F.
		endif                                                                         
		
	//-- Valida o 3º panel - pelo menos 1 filial deve ser selecioanda.
	elseif pnTela == 2      
		if aScan(paInfo, {|x| Upper(x[4]) == "CHECKED"} ) == 0
			msgAlert(STR0007)
			lReturn := .F.
		endif

	//-- Valida o 8º panel - URL e DW devem ser informados.
	//   Se informados irá criar os parâmetros MV_DWURL e MV_DWNAME para
	//   cada empresa/filial selecionada.
	elseif pnTela == 3
		if empty(AllTrim(paInfo[1])) .or. empty(AllTrim(paInfo[2])) // URL e DW
			msgAlert(STR0069)
			lReturn := .F.
		else        
			oWizard:oBack:Show()
			CriaMv(paInfo[1], paInfo[2], paInfo[3]) // URL, DW e Empresas selecionadas
    	endif

	//-- Valida o 4º panel - pelo menos 1 consulta deve ser selecionada.
	elseif pnTela == 4
		if len(paInfo) == 0
			msgAlert(STR0009)
			lReturn := .F.
		endif
	endif
	                       
return lReturn

// --------------------------------------------------------------------------------------
// Essa funcao ira criar os parametros MV_DWURL e MV_DWNAME no SX6 conforme os dados 
// informados pelo usuário.
// pcURL: URL do SigaDW
// pcDW: Datawarehouse para importação
// paEmpresas: Empresas selecionadas nas quais deverão ser criadas os parâmetros
// ----------------------------------------------------------------------------------------
static function CriaMv(pcURL, pcDW, paEmpresas)
	local nEmp    := 0
	local cEmpAnt := ""
	local aSXs	   := RetSXs()
	
	default paEmpresas := {}
                                    
	if left(trim(lower(pcURL)), 7) <> "http://"
		pcURL := "http://" + pcURL
	endif
	
	cEmpAnt := ""
	for nEmp := 1 to len(paEmpresas)
		if !(cEmpAnt == paEmpresas[nEmp][1])
			if !Empty(paEmpresas[nEmp][2])
				if aDir(aSXs[2][1] + paEmpresas[nEmp][1] + "0*") > 0
					StartJob( "JobCriaMV", GetEnvServer(), .f., paEmpresas[nEmp][1], paEmpresas[nEmp][2], {pcURL,pcDW} )
				else
					msgAlert(STR0089 + paEmpresas[nEmp][1]) //###"Favor executar o configurador para a empresa: "
					Conout(STR0089 + paEmpresas[nEmp][1]) //###"Favor executar o configurador para a empresa: "
				endif
				cEmpAnt := paEmpresas[nEmp][1]
			endif
		endif
	next nEmp

return nil

function JobCriaMV(cEmpSel, cFilSel, paParams)     

	local cURL     := paParams[1]
	local cDW      := paParams[2]
	
	RPCSetType(3)
	PREPARE ENVIRONMENT EMPRESA cEmpSel FILIAL cFilSel //TABLES "SX6"
			
	dbSelectArea("SX6")
	SX6->( dbSetOrder(1) )

	SX6->( dbGoTop() )
	if SX6->( dbSeek(xFilial("SX6")+"MV_DWURL"))
		RecLock( "SX6", .F. )
	else
		RecLock( "SX6", .T. )
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "MV_DWURL"
		SX6->X6_TIPO    := "C"
		SX6->X6_PROPRI  := "S"
		SX6->X6_DESCRIC := "URL do SigaDW"
		SX6->X6_DSCSPA	:= "URL del SigaDw"
		SX6->X6_DSCENG  := "SigaDW URL"
	endif              
	SX6->X6_CONTEUD := cURL
	SX6->X6_CONTSPA := cURL
	SX6->X6_CONTENG := cURL
	SX6->( MsUnlock() )
			
	SX6->( dbGoTop() )
	if SX6->( dbSeek(xFilial("SX6")+"MV_DWNAME"))
		RecLock( "SX6", .F. )
	else
		RecLock( "SX6", .T. )
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "MV_DWNAME"
		SX6->X6_TIPO    := "C"
		SX6->X6_PROPRI  := "S"
		SX6->X6_DESCRIC := "Nome do Datawarehouse"
		SX6->X6_DSCSPA	:= "Nombre del Datawarehouse"
		SX6->X6_DSCENG  := "SigaDW Name"
	endif
	SX6->X6_CONTEUD := cDW
	SX6->X6_CONTSPA := cDW
	SX6->X6_CONTENG := cDW
	SX6->( MsUnlock() )
	
	cEmpSel  := NIL
	cFilSel  := NIL
	cURL     := NIL
	cDW      := NIL
	DelClassIntf()

return nil

// --------------------------------------------------------------------------------------
// Essa funcao ira habilitar ou desabilitar os campos URL,DW, usuario e Senha conforme
// opção escolhida no TRadio: desabilita qdo a opção for "Download" - habilita qdo a
// opção for "Importação no DW".
// pnOpcao: Opcao selecionada no TRadio.
// ----------------------------------------------------------------------------------------
static function ChangeMsGet(pnOpcao, poEdtUser, poEdtPsw) 

	poEdtPsw:bWhen	:= {|| !(pnOpcao == 1)} 
	poEdtPsw:SetFocus()
	
	poEdtUser:bWhen	:= {|| !(pnOpcao == 1)} 
	poEdtUser:SetFocus()

return .t.
		
// --------------------------------------------------------------------------------------
// Essa funcao ira retornar num array todas as Dimensoes ou Cubos e suas fontes de dados 
// do XML.
// poXmlNode: node dimensao ou cubo
// pcNameNode: nome do node principal
// ----------------------------------------------------------------------------------------
static function retNode2Arr(poXmlNode, pcNameNode)

	local oNode       
	local oFonteDados
	local nInd				:= 0
	local nFDInd			:= 0   
	local aFonteDados		:= {}
	local aNode				:= {}
	local aResultNode		:= {}    
	
	//Verifica se existe informacoes
	if valtype(poXmlNode) == "O"

		//Retorna todos os filhos do Node.
		oNode := XmlGetChild ( poXmlNode, 1 )     
		oNode := if(valtype(oNode) == "A", oNode, {oNode})
			
		for nInd := 1 to len(oNode)

			//Verifica se existe o Node DataSources
			aFonteDados := {}
			if xmlNodeExist( oNode[nInd], "_Datasources") .and. xmlNodeExist( oNode[nInd]:_Datasources, "_Datasource")
					
				//Retorna todos os datasources
				oFonteDados	 	:= XmlGetChild ( oNode[nInd]:_DATASOURCES, 1 )
				oFonteDados 	:= if(valtype(oFonteDados) == "A", oFonteDados, {oFonteDados})
					
				//Adiciona Todos os datasources no array
				for nFDInd := 1 to len(oFonteDados)
					aAdd(aFonteDados, (oFonteDados[nFDInd]:_NOME:TEXT  + " - " + oFonteDados[nFDInd]:_DESCRICAO:TEXT))
					nMaxTamMeter++
				next nFDInd
				
			endif
		
			//Adiciona as Dimensoes ou Cubos e seus Datasources
			aAdd(aNode, { oNode[nInd]:_NOME:TEXT + " - " + oNode[nInd]:_DESCRICAO:TEXT, { STR0078, aFonteDados } })

			nMaxTamMeter++
		next nInd

	endif

	aAdd(aResultNode, { pcNameNode + space(30), aNode } )

	oNode       	:= NIL
	oFonteDados		:= NIL
	nInd			:= NIL
	nFDInd			:= NIL  
	aFonteDados		:= NIL
	aNode			:= NIL

return aResultNode

// --------------------------------------------------------------------------------------
// Essa funcao ira incluir os itens na tree (poTree) de acordo com o array (paQuerys)
// poTree: objeto Tree que ira ser incluido os itens
// paQuerys: array contendo as informacoes que iram na Tree
// ----------------------------------------------------------------------------------------
static function DWcreateTree(poTree, paQuerys)
	local nInd		:= 0
	local lVazio 	:= .T.
	
	poTree:beginUpdate() 
	
	for nInd := 1 to len(paQuerys) 
		lVazio := .F.
		if valtype(paQuerys[nInd]) == "A"
			DWcreateTree(poTree, paQuerys[nInd])
		else                                           
			if !(AllTrim(paQuerys[nInd]) $ "DIMENSOES*CUBOS")
				if nInd == 1 .and. len(paQuerys) > 1
		   			DBADDTREE poTree PROMPT paQuerys[nInd] CARGO "$" + dwStr(nInd)
		  		else
	 				DBADDITEM poTree PROMPT paQuerys[nInd] CARGO dwStr(nInd)
		  		endif
		  endif
		endif
	next                              
	
	if lVazio == .F.
		DBENDTREE poTree
	endif
	
	poTree:endUpdate()
return nil

//******************************************************************************************
//******************************************************************************************
//DESABILITADO PARA FUTURA IMPLEMENTACAO - ALTERACAO DE PERFORMANCE
//******************************************************************************************
//******************************************************************************************
// --------------------------------------------------------------------------------------
// Essa funcao ira gerar o XML conforme os parametros informados pelo usuario
// poWizard: objeto wizard
// poXML: XML de origem
// pcServidor: Servidor e portal (Protheus) informado pelo usuário
// pcAmbiente: Ambiente de produção da Fonte de dados
// paEmpresas: array com as empresas e filiais selecionadas
// paQuerys: array das consultas selecionadas                                                 
// ----------------------------------------------------------------------------------------
/*static function procIndNativos(pcStartPath, pcXmlName, pcDestFileName, pcServidor, pcAmbiente, paEmpresas, paQuerys)
	local oDestXML   
	local oServers
	local oServer   
	local oXMLQuery
	local nChild			:= 0
	local cAuxName			:= ""

	oWizard:oBack:Hide()
	oWizard:oNext:Hide()
	oWizard:oCancel:Hide()

	oMeter:Show()
	oMeter:SetTotal(10)
	oMeter:Set(0)
	nMaxTamMeter := 0

	//-------------------------------------------
	//-- Criar arquivo XML com os nós servers, dimensions, cubes e querys 
	//-- (conforme empresas/filiais e consultas selecionadas)
	//-------------------------------------------
	cAuxName := NAME_XML_DESTINO
	COPY FILE &(pcXmlName) TO &(pcStartPath + cAuxName)
	oMeter:Set(++nMaxTamMeter)
	
	oDestXML := DWLoadXML(pcStartPath + cAuxName,.F.)
	oMeter:Set(++nMaxTamMeter)
                                           
	// Servidor, Porta e Ambiente selecionados
	oServers := oDestXML:_DATAWAREHOUSE:_SERVERS:_SERVER
	For nChild := 1 to len(oServers)
		oServer 	:= oServers[nChild]

		oServer:_SERVER:TEXT := Alltrim(pcServidor)
		oServer:_AMBIENTE:TEXT := Alltrim(pcAmbiente)
		
		if Val(oServer:_TIPO:TEXT) == 3
			oServer:_CAMINHO:TEXT := Alltrim(pcStartPath)
		endif
		
	next nChild
	oMeter:Set(++nMaxTamMeter)
	                   
	// Dimensões                   
	procDatasources(oDestXML:_DATAWAREHOUSE:_DIMENSIONS:_DIMENSION, paEmpresas)
	oMeter:Set(++nMaxTamMeter)
	
	// Cubes
	procDatasources(oDestXML:_DATAWAREHOUSE:_CUBES:_CUBE, paEmpresas)
	oMeter:Set(++nMaxTamMeter)

	//-------------------------------------------
	//-- Gravar XML
	//-------------------------------------------
	SAVE oDestXML XMLFILE cAuxName
	oMeter:Set(++nMaxTamMeter)

	AddEncoding(cAuxName, pcStartPath + pcDestFileName)
	oMeter:Set(++nMaxTamMeter)
                                                                               	
	//-------------------------------------------
	//-- Cria arquivo XML apenas com as consultas que irão para o Painel Offline
	//-------------------------------------------
	cAuxName := NAME_XML_DESTINO
	COPY FILE &(pcXmlName) TO &(pcStartPath + cAuxName)

	oXMLQuery := DWLoadXML(pcStartPath + cAuxName,.F.)
	oMeter:Set(++nMaxTamMeter)

	//XmlDelNode( oXMLQuery:_DATAWAREHOUSE:_SERVERS, "_SERVER" )
	//XmlDelNode( oXMLQuery:_DATAWAREHOUSE:_DIMENSIONS, "_DIMENSION" )
	//XmlDelNode( oXMLQuery:_DATAWAREHOUSE:_CUBES, "_CUBE" )
	oMeter:Set(++nMaxTamMeter)

	SAVE oXMLQuery XMLFILE cAuxName
	oMeter:Set(++nMaxTamMeter)
	
	AddEncoding(cAuxName, pcStartPath + NAME_XML_QUERY)
	oMeter:Set(++nMaxTamMeter)

	oWizard:oBack:Show()
	oWizard:oNext:Show()
	oWizard:oCancel:Show()
	
	oWizard:SetPanel(8)

	oDestXML	:= NIL
	oServers	:= NIL
	oServer   	:= NIL
	oXMLQuery	:= NIL
	nChild		:= NIL
	cAuxName	:= NIL
	DelClassIntf()
	
return .t.*/
static function procIndNativos(pcStartPath, pcXmlName, pcDestFileName, pcServidor, pcAmbiente, paEmpresas, paQuerys)
	local oXML 				:= DWLoadXML(pcXmlName,.F.)
	local oXMLQuery
	local oDestXML
	local oServers
	local oServer                           
	local aAttrib			:= {}  
	local nTotal			:= 0
	local nPos				:= 0
	local nChild			:= 0
	local nAttrib			:= 0   

	oWizard:oBack:Hide()
	oWizard:oNext:Hide()
	oWizard:oCancel:Hide()

	nTotal := nMaxTamMeter + xmlChildCount(oXML:_DATAWAREHOUSE:_SERVERS) + xmlChildCount(oXML:_DATAWAREHOUSE:_QUERYS) + 6

	oMeter:Show()
	oMeter:SetTotal(nTotal)
	oMeter:Set(0)
              
	nMaxTamMeter	:= 0
	
	//-------------------------------------------
	//-- Cria arquivo XML apenas com as consultas que irão para o Painel Offline
	//-------------------------------------------
	oXMLQuery := procNode(oXML:_DATAWAREHOUSE,,,,.F., pcStartPath)
	oXMLQuery:oAddChild(procNode(oXML:_DATAWAREHOUSE:_QUERYS,,,,,pcStartPath))
	oXMLQuery:XMLFile(NAME_XML_QUERY,.T.,ENCODING)
	oXMLQuery := NIL
		
	oMeter:Set(++nMaxTamMeter)
                                           
	//-------------------------------------------
	//-- Criar arquivo XML com os nós servers, dimensions, cubes e querys 
	//-- (conforme empresas/filiais e consultas selecionadas)
	//-------------------------------------------
	oDestXML  := procNode(oXML:_DATAWAREHOUSE, paEmpresas,paQuerys,,,pcStartPath)

	// Servidor, Porta e Ambiente selecionados
	oServers := oDestXML:oChildByName("servers")
	For nChild := 1 to oServers:nChildCount("server")
		oServer 	:= oServers:oChildByName("server",nChild)
		aAttrib 	:= oServer:oAttrib():FAFIELDS
		                 
		if (nPos := aScan(aAttrib, {|x| Upper(x[1]) == "SERVER"})) > 0
			aAttrib[nPos][2] := Alltrim(pcServidor)
		endif
		
		if (nPos := aScan(aAttrib, {|x| Upper(x[1]) == "AMBIENTE"})) > 0
			aAttrib[nPos][2] := Alltrim(pcAmbiente)
		endif
		
		if (nPos := aScan(aAttrib, {|x| Upper(x[1]) == "TIPO"})) > 0
			if Val(aAttrib[nPos][2]) == 3 .and. (nPos := aScan(aAttrib, {|x| Upper(x[1]) == "CAMINHO"})) > 0
				aAttrib[nPos][2] := Alltrim(pcStartPath)
			endif
		endif
		oMeter:Set(++nMaxTamMeter)
	next nChild
	
	//-------------------------------------------
	//-- Gravar XML
	//-------------------------------------------
	oDestXML:XMLFile(pcDestFileName,.T.,ENCODING)
	oMeter:Set(nTotal)    

	oWizard:oBack:Show()
	oWizard:oNext:Show()
	oWizard:oCancel:Show()
	
	oWizard:SetPanel(8)

	oDestXML	:= NIL
	oServers	:= NIL
	oServer   	:= NIL
	oXMLQuery	:= NIL
	nChild		:= NIL
	oXML 		:= NIL
	aAttrib		:= NIL
	nTotal		:= NIL
	nPos		:= NIL
	nAttrib		:= NIL 
   
	If (ValType(oXML) == 'O', freeObj( oXML ), '' ) 
	If (ValType(oXMLQuery) == 'O', freeObj( oXMLQuery ), '' ) 
	If (ValType(oDestXML) == 'O', freeObj( oDestXML ), '' ) 
	
	DelClassIntf()    
return .t.

// --------------------------------------------------------------------------------------
// Essa funcao ira gerar os Datasources das dimensões e cubos para cada empresa/filial 
// selecionada.
// oNode: node onde será criado o datasource
// paEmpresas: array com as empresas e filiais selecionadas
// ----------------------------------------------------------------------------------------
function procDatasources(oNode, paEmpresas)
	local nChild    := 0
	local nQtdDS    := 0
	local nDS       := 0  
	local nEmpresas := 0
	local nAtt		:= 0      
	local nChecked	:= 0
	local oAttOrig
	local oAttDest

	For nChild := 1 to len(oNode)
		if XmlChildCount ( oNode[nChild]:_DATASOURCES ) > 0
			if ValType(oNode[nChild]:_DATASOURCES:_DATASOURCE) == "A"
				nQtdDS := len(oNode[nChild]:_DATASOURCES:_DATASOURCE)
			else
				nQtdDS := 1
			endif          
			
			for nDS := 1 to nQtdDS
				nChecked := 0
				for nEmpresas := 1 to len(paEmpresas)
					if paEmpresas[nEmpresas][4] == "CHECKED" .and. !(paEmpresas[nEmpresas][2] = "  ") .and.;
					   !(paEmpresas[nEmpresas][1] == "99" .and. paEmpresas[nEmpresas][2] == "01") 
					   		nChecked++
						
							if XmlCloneNode ( oNode[nChild]:_DATASOURCES:_DATASOURCE , "_DATASOURCE" ) 
                	        	oNode[nChild]:_DATASOURCES:_DATASOURCE[nQtdDS + nChecked]:REALNAME := oNode[nChild]:_DATASOURCES:_DATASOURCE[nDS]:REALNAME
                	        	oNode[nChild]:_DATASOURCES:_DATASOURCE[nQtdDS + nChecked]:TEXT := oNode[nChild]:_DATASOURCES:_DATASOURCE[nDS]:TEXT
                	        	oNode[nChild]:_DATASOURCES:_DATASOURCE[nQtdDS + nChecked]:TYPE := oNode[nChild]:_DATASOURCES:_DATASOURCE[nDS]:TYPE
                                        
								for nAtt := 1 to XmlChildCount(oNode[nChild]:_DATASOURCES:_DATASOURCE[nDS])
									oAttOrig := XmlGetChild( oNode[nChild]:_DATASOURCES:_DATASOURCE[nDS], nAtt) 
									oAttDest := XmlGetChild( oNode[nChild]:_DATASOURCES:_DATASOURCE[nQtdDS + nChecked], nAtt) 

	                	        	oAttDest:REALNAME 	:= oAttOrig:REALNAME
        	        	        	oAttDest:TYPE 		:= oAttOrig:TYPE
        	        	        	
									if Upper(oAttOrig:REALNAME) == "EMPFIL"
										oAttDest:TEXT := paEmpresas[nEmpresas][1] + "/" + paEmpresas[nEmpresas][2]
										
									elseif Upper(oAttOrig:REALNAME) == "NOME"
										oAttDest:TEXT := if(len(alltrim(oAttOrig:TEXT)) > 8, substr(alltrim(oAttOrig:TEXT),1,8), alltrim(oAttOrig:TEXT)) + paEmpresas[nEmpresas][1] + paEmpresas[nEmpresas][2]
										
									//elseif Upper(oAttOrig:REALNAME) == "CAMINHO" .and. lTipo3
									//  if Upper(oAttOrig:REALNAME) == "TIPO_CONN" .and. oAttOrig:TEXT	== "3" 
									//	   oAttDest:TEXT := Alltrim(pcStartPath)
									//  endif
										
									else
    	            	        		oAttDest:TEXT := oAttOrig:TEXT
									endif

								next nAtt
                			endif
					endif
				next nEmpresas
			next nDS
		endif	
	next nChild  

return nil

// --------------------------------------------------------------------------------------
// Essa funcao ira adicionar ao metadados criado o Encoding no começo do arquivo.
// ----------------------------------------------------------------------------------------
function AddEncoding(cFileOrig, cFileDest)

	local oFile
	local oDestFile
	local nTamArquivo		:= 0
	local nBytesFalta		:= 0
	local cHeader			:= '<?xml version="1.0"  encoding="' + ENCODING + '" ?>'
	local nBytesLer			:= 0
	local cBuffer			:= ""

	oFile := TBIFileIO():New(cFileOrig)
	if oFile:lOpen()
		// Determina o tamanho do arquivo de origem
		nTamArquivo := oFile:nSeek(0,2)
		// Move o ponteiro do arquivo de origem para o inicio do arquivo
		oFile:nGoBOF()
		// Define que a quantidade que falta copiar é o próprio tamanho do Arquivo
		nBytesFalta := nTamArquivo

		oDestFile := TBIFileIO():New(cFileDest)
        if oDestFile:lCreate()
			oDestFile:nGoBOF()
			oDestFile:nWriteLn(cHeader)

			// Enquanto houver dados a serem copiados
			While nBytesFalta > 0

				// Determina quantidade de dados a serem lidos
				nBytesLer 	:= Min(nBytesFalta , F_BLOCK )
	
				// lê os dados do Arquivo
				oFile:nRead(@cBuffer, nBytesLer)

				// Salva os dados lidos no arquivo de destino
				oDestFile:nWriteLn(cBuffer,nBytesLer)

				// Elimina do Total do Arquivo a quantidade de bytes copiados
				nBytesFalta -= nBytesLer
        	enddo
			oDestFile:lClose()                     
			oDestFile:Free()
		endif
		oFile:lClose()                     
		oFile:lErase()
		oFile:Free()
	endif      
	
return nil

// --------------------------------------------------------------------------------------
// Essa funcao ira gerar, a partir do XML de Origem, o XML que ira ser importado no DW, 
// respeitando as configuracoes informadas pelo usuario (Dados de conexao, Empresas, 
// Filiais e Consultas)
// poXML: Node que sera copiado do XML Original
// paEmpresas: array das empresas e filiais selecionadas
// paQuerys: array das consultas selecionadas                  
// plDSReplicate: se deseja ou não replicar a fonte de dados
// ----------------------------------------------------------------------------------------
static function procNode(poXML,paEmpresas,paQuerys,plDSReplicate,plAddChild, pcStartPath)
	local oAuxXML					//Objeto de retorno
	local oAttrib 					//Atributos
	local oChild					//Filhos do Node (ATT e NODE)
	local oChildDS
	local oAuxChild
	local aAttrib			:= {}  
	local nChild			:= 0
	local nEmp				:= 0
	local nFil				:= 0
	local nAttrib			:= 0   
	local nArrChild			:= 0		
	local nPos 				:= 0
	local cQryNome    		:= ""
	local cQryGrupo			:= ""
	local lDimEmpFil		:= .F.
	
	default paEmpresas		:= {}
	default plDSReplicate	:= .T.
	default plAddChild 		:= .T.
	
	if valtype(poXML) == "O" 
		if poXML:TYPE == "NOD"   
			oAuxXML 		:= TBIXMLNODE():NEW(poXML:REALNAME,poXML:TEXT)
			//Quando a dimensão for "EMPFIL" não deverá ser replicado o Datasource.
			//Apenas os atributos M0_CODIGO e M0_CODFIL deverão ser alterados para a
			// primeira empresa e filial selecionados na Tree.
			if upper(poXML:REALNAME) == "DIMENSION" .and. xmlNodeExist(poXml, "_NOME") 
				if upper(poXML:_NOME:TEXT) == "EMPFIL"                   
					lDimEmpFil := .T.            
				endif
			endif
		endif

		oAttrib := TBIXMLAttrib():New()  
		for nChild := 1 to xmlChildCount(poXML)
			oChild 	:= xmlGetChild(poXML,nChild)
			
			if valtype(oChild) == "O"
				if oChild:TYPE == "ATT"
					oAttrib:lSet(oChild:REALNAME, DWTrataImpXML(oChild:TEXT))
				elseif oChild:TYPE == "NOD" .and. plAddChild
					oAuxChild := oAuxXML:oAddChild(procNode(oChild,paEmpresas,paQuerys,!lDimEmpFil,,pcStartPath))
	
					//-------------------------------------------------------
					//-- Clonar Datasource por Empresas/Filiais Selecionadas
					//-------------------------------------------------------
					if poXML:REALNAME == "datasources" 
						for nEmp := 1 to len(paEmpresas)   
							if paEmpresas[nEmp][4] == "CHECKED" .and. !(paEmpresas[nEmp][2] = "  ")
								//Apenas replica os Datasources para os cubos e para as 
								//dimensões diferentes de "EMPFIL".
								//Se o datasource for dessa dimensão ("EMPFIL"), deverá apenas
								//alterar os atributos empfil e nome do datasource existente.
								if plDSReplicate .and. !(paEmpresas[nEmp][1] == "99" .and. paEmpresas[nEmp][2] == "01")
									oChildDS:= oAuxXML:oAddChild(procNode(oChild,paEmpresas,paQuerys,!lDimEmpFil,,pcStartPath))
		  							aAttrib	:= oChildDS:oAttrib():FAFIELDS
		  						else
		  							aAttrib := oAuxChild:oAttrib():FAFIELDS
			  					endif       
			  					
								if (nAttrib := aScan(aAttrib, {|x| Upper(x[1]) == "EMPFIL"})) > 0
									aAttrib[nAttrib][2]	:= paEmpresas[nEmp][1] + "/" + paEmpresas[nEmp][2]
								endif
								
								if (nAttrib := aScan(aAttrib, {|x| Upper(x[1]) == "NOME"})) > 0 .and. plDSReplicate
									aAttrib[nAttrib][2]	:=  if(len(alltrim(aAttrib[nAttrib][2])) > 8, substr(alltrim(aAttrib[nAttrib][2]),1,8), alltrim(aAttrib[nAttrib][2])) + paEmpresas[nEmp][1] + paEmpresas[nEmp][2]
								endif
								
								if (nAttrib := aScan(aAttrib, {|x| Upper(x[1]) == "TIPO_CONN"})) > 0
									if Val(aAttrib[nAttrib][2]) == 3 .and. (nAttrib := aScan(aAttrib, {|x| Upper(x[1]) == "CAMINHO"})) > 0
										aAttrib[nAttrib][2] := Alltrim(pcStartPath)
									endif
								endif
						
								if !plDSReplicate
									exit
								endif
							endif
						next nEmp
						oMeter:Set(++nMaxTamMeter)
					endif
				endif			
			elseif valtype(oChild) == "A" .and. plAddChild
				for nArrChild := 1 to len(oChild)  
					if !(oChild[nArrChild]:REALNAME = "query")
						oAuxXML:oAddChild(procNode(oChild[nArrChild],paEmpresas,paQuerys,!lDimEmpFil,,pcStartPath))
					else
						//-------------------------------------------
						//-- Consultas Selecionadas     
						//-------------------------------------------
						cQryNome 	:= oChild[nArrChild]:_NOME:TEXT
						cQryGrupo 	:= oChild[nArrChild]:_GRUPO:TEXT
					
						//Se não passar o array deverá copiar todas as querys
						if valType(paQuerys) == "U"
							nPos := 1
						else
							if empty(cQryGrupo)
								nPos := aScan(paQuerys, {|x| Upper(x[1]) == "INDEFINIDO" .and. x[2] == cQryNome  })    
							else
								nPos := aScan(paQuerys, {|x| x[1] == cQryGrupo .and. x[2] == cQryNome  })    
							endif
						endif
					
						if  nPos > 0 
							oAuxXML:oAddChild(procNode(oChild[nArrChild],paEmpresas,paQuerys,!lDimEmpFil,,pcStartPath))
						endif
					endif
	
					//-------------------------------------------------------
					//-- Clonar Datasource por Empresas/Filiais Selecionadas
					//-------------------------------------------------------
					if poXML:REALNAME == "datasources"
						for nEmp := 1 to len(paEmpresas)
							if paEmpresas[nEmp][4] == "CHECKED" .and. !(paEmpresas[nEmp][2] = "  ")

								//Apenas replica os Datasources para os cubos e para as 
								//dimensões diferentes de "EMPFIL".
								//Se o datasource for dessa dimensão ("EMPFIL"), deverá apenas
								//alterar os atributos empfil e nome do datasource existente.
								if plDSReplicate .and. !(paEmpresas[nEmp][1] == "99" .and. paEmpresas[nEmp][2] == "01")
									oChildDS := oAuxXML:oAddChild(procNode(oChild,paEmpresas,paQuerys,!lDimEmpFil,,pcStartPath))
			  						aAttrib 	:= oChildDS:oAttrib():FAFIELDS

									if (nAttrib := aScan(aAttrib, {|x| Upper(x[1]) == "EMPFIL"})) > 0
										aAttrib[nAttrib][2]	:= paEmpresas[nEmp][1] + "/" + paEmpresas[nEmp][2]
									endif
	
									if (nAttrib := aScan(aAttrib, {|x| Upper(x[1]) == "NOME"})) > 0 .and. plDSReplicate
										aAttrib[nAttrib][2]	:=  if(len(alltrim(aAttrib[nAttrib][2])) > 8, substr(alltrim(aAttrib[nAttrib][2]),1,8), alltrim(aAttrib[nAttrib][2])) + paEmpresas[nEmp][1] + paEmpresas[nEmp][2]
									endif
	
									if (nAttrib := aScan(aAttrib, {|x| Upper(x[1]) == "TIPO_CONN"})) > 0
										if Val(aAttrib[nAttrib][2]) == 3 .and. (nAttrib := aScan(aAttrib, {|x| Upper(x[1]) == "CAMINHO"})) > 0
											aAttrib[nAttrib][2] := Alltrim(pcStartPath)
										endif
									endif    
								endif
								if !plDSReplicate
									exit
								endif
							endif
						next nEmp
						oMeter:Set(++nMaxTamMeter)
					endif
				next nArrChild
			endif
	
		next nChild   
	else
		for nChild := 1 to len(poXML)
			oAuxXML := procNode(poXML[nChild],paEmpresas,paQuerys,!lDimEmpFil,,pcStartPath)
		next nChild
	endif
	
	oAuxXML:oAttrib(oAttrib)
	
	oAttrib 	:= NIL
	oChild		:= NIL
	oChildDS	:= NIL
	oAuxChild	:= NIL
	aAttrib		:= NIL
	nChild		:= NIL
	nEmp		:= NIL
	nFil		:= NIL
	nAttrib		:= NIL
	nArrChild	:= NIL
	nPos 		:= NIL
	cQryNome    := NIL
	cQryGrupo	:= NIL
	lDimEmpFil	:= NIL

return oAuxXML

// --------------------------------------------------------------------------------------
// Essa funcao ira fazer o download do XML gerado
// ----------------------------------------------------------------------------------------
static function DownloadXML(pcDestFileName)
	local cPath			:= ""   
	local lOk		 	:= .F.

	oWizard:oBack:Hide()
	oWizard:oNext:Hide()
	oWizard:oCancel:Hide()

	while !lOk
	
		cPath := cGetFile( "*.xml" , STR0029 , 0 ,  , .F. , GETF_LOCALHARD+GETF_RETDIRECTORY )
		If Empty(cPath)
			MsgInfo( STR0038, STR0039 )
		elseif substr(cPath, len(cPath),1) == "\"
			MsgInfo( STR0057, STR0039 )
		elseif at(".xml", cPath) == 0
			cPath += ".xml"
			lOk := .T.
		EndIf
	
	enddo
                     
	oWizard:oBack:Hide()
	
	//-------------------------------------------
	//-- Gravar XML
	//-------------------------------------------
	oImpMeter:Show()
	oImpMeter:SetTotal(100)

	oImpMeter:Set(50)
	COPY FILE &(pcDestFileName) TO &(cPath)
	oImpMeter:Set(100)

	MsgInfo( STR0041 + cPath + STR0042, STR0039 )

	oWizard:oBack:Show()
	oWizard:oNext:Show()
	oWizard:oCancel:Show()

	oWizard:SetPanel(12)
	
	DelClassIntf()
	
return .t.

// --------------------------------------------------------------------------------------
// Essa funcao ira importar para o DW XML gerado
// pcURL: URL do SIGADW
// pcDW: em qual o DW que devera ser importado   
// pcUsuario: Usuário para acesso ao SigaDW                 
// pcSenha: senha para acesso ao SigaDW                                                       
// plNewDW: se cria o DW caso este não exista
// pcStartPath: caminho onde está o arquivo XML criado
// pcDestFileName: arquivo XML criado que será utilizado para a importação
// ----------------------------------------------------------------------------------------
static SESSION_ID := nil

static function ImportDW(pcURL, pcDW, pcUsuario, pcSenha, plNewDW, pcStartPath, pcDestFileName)
                         
	local oDestXML     
	local oXMLDW
	local cRet
	local cHeader		:= ""
	local cPath			:= ""     
	local cPost			:= ""   
	local cboundary 	:= Replicate("-",27) + strTran(dwStr(seconds()),".", "")
	local nMeter		:= 0
	
	local nChild		:= 0   
	local nQtd			:= 0   
	local oAux                                                                  
	local lArray 		:= .F.
	local nTotal		:= 0

	oWizard:oBack:Hide()
	oWizard:oNext:Hide()
	oWizard:oCancel:Hide()

	if substr(pcStartPath, len(pcStartPath),1) <> "\"
		pcStartPath += "\"
	endif
                     
	//Carrega o metadados
	oDestXML	:= DWLoadXML(pcStartPath + pcDestFileName,.F.)

	if ValType(oDestXML) == "U"
		return ImpErro(STR0079)
	else
		nTotal += if( ValType(oDestXML:_DATAWAREHOUSE:_DIMENSIONS:_DIMENSION) == "A", len(oDestXML:_DATAWAREHOUSE:_DIMENSIONS:_DIMENSION), 1)
		nTotal += if( ValType(oDestXML:_DATAWAREHOUSE:_CUBES:_CUBE) == "A", len(oDestXML:_DATAWAREHOUSE:_CUBES:_CUBE), 1)
		nTotal += if( ValType(oDestXML:_DATAWAREHOUSE:_QUERYS:_QUERY) == "A", len(oDestXML:_DATAWAREHOUSE:_QUERYS:_QUERY), 1)
		nTotal += 6

		oImpMeter:Show()
		oImpMeter:SetTotal(nTotal)
		oImpMeter:Set(nMeter)
                        
		// Verifica se todas as informações necessárias foram informadas
		if empty(pcURL)
			return ImpErro(STR0043)
		elseif empty(pcDW)
			return ImpErro(STR0044)
		elseif empty(pcUsuario)
			return ImpErro(STR0053)
		endif
	
		oImpMeter:Set(nMeter++)

		// valida usuário no SigaDW
		cRet := dwHttpPost(AllTrim(pcUrl)+"/w_sigadw3.apw", "action=" + AC_LOGIN + "&ws=on", ;
						"edScreenWidth=1024&edScreenHeight=704&edUser=" + upper(AllTrim(pcUsuario)) + "&edPassword=" + AllTrim(pcSenha), , ;
						aGetCook())
	   	oImpMeter:Set(nMeter++)

		if !empty(cRet)
   			if !("aph/apl: h_dwSelectDW()" $ cRet)
				return ImpErro(STR0054 + STR0055)
		   endif
		else
			return ImpErro(STR0054 + STR0071)
 		endif

	   	// tratar o SESSIONID
	   	SESSION_ID := substr(cRet, at("DWSESSIONID",cRet) + 22 )
		SESSION_ID := substr(SESSION_ID, 1, at("'",SESSION_ID)-1)
		
		if !plNewDW
			// seleciona DW
	   		cRet := dwHttpPost(AllTrim(pcUrl)+"/w_sigadw3.apw", "action=" + AC_SELECT_DW + "&ws=on&dwname=" + Alltrim(pcDW), , , aGetCook())
	   		oImpMeter:Set(nMeter++)
	   		
			if empty(cRet)
				return ImpErro(STR0054 + STR0056)
			endif
		else
	  		if !("aph/apl: h_dwBuildAba()" $ cRet)  
        		if plNewDW
					//Cria o DW
					cRet := dwHttpPost(AllTrim(pcUrl)+"/w_sigadw3.apw", "action=" + AC_NEW_DW + "&dw=0", , , aGetCook())
					if empty(cRet)
						return ImpErro(STR0054 + STR0076)
					else
						if !("aph/apl: h_dwNewDW()" $ cRet)  
							return ImpErro(STR0054 + STR0076)
						else            
							cRet := dwHttpPost(AllTrim(pcUrl)+"/w_sigadw3.apw", "action=" + AC_NEW_DW + "&oper=1&suboper= ", "edNome="+Alltrim(pcDW)+"&edDescricao='" + STR0098 + "'&edIcone=dw_new.gif", , aGetCook()) //###"DW criado atraves do Wizard"
							if empty(cRet)
								return ImpErro(STR0054 + STR0076)
							else
								if !("aph/apl: h_dwNewDW()" $ cRet)  
									return ImpErro(STR0054 + STR0076)
								else               
									//Seleciona DW criado
        				            cRet := dwHttpPost(AllTrim(pcUrl)+"/w_sigadw3.apw", "action=" + AC_SELECT_DW + "&ws=on&dwname=" + Alltrim(pcDW), , , aGetCook())
									if empty(cRet)
										return ImpErro(STR0054 + STR0056)
									else
	            	    			    if !("aph/apl: h_dwBuildAba()" $ cRet)  
											return ImpErro(STR0054 + STR0056)
        			    	    	    endif
        							endif
        						endif
							endif		
						endif
					endif
				else
					return ImpErro(STR0054 + STR0056)
				endif
		  	endif
        endif

		//Select Aba tools
		cRet := dwHttpPost(AllTrim(pcUrl)+"/w_sigadw3.apw", "action=" + AC_SELECT_ABA + "&aba=tools", , , aGetCook())
	   	oImpMeter:Set(nMeter++)

		if empty(cRet)
			return ImpErro(STR0054 + STR0056 + "(SELECT_ABA)")
		else
		   	if !("buildForm start aph/apl BUILDTMFIRSTSTEP:BUILDCHECKLIST" $ cRet)
				return ImpErro(STR0054 + STR0056 + "(SELECT_ABA)")
		   	endif
		endif	
		
		//Select Aba tools_importacao
		cRet := dwHttpPost(AllTrim(pcUrl)+"/w_sigadw3.apw", "action=" + AC_SELECT_ABA + "&aba=tools_importacao", , , aGetCook())
	   	oImpMeter:Set(nMeter++)

		if empty(cRet)
			return ImpErro(STR0054 + STR0056 + "(SELECT_ABA_IMP)")
	   	else
	   		if !("buildForm start aph/apl H_DWPROCABA:H_DWTOOLIMPORT" $ cRet)
				return ImpErro(STR0054 + STR0056 + "(SELECT_ABA_IMP)")
		   	endif 
		endif

		//import SERVERS
		cPath := Alltrim(GetPvProfString(getEnvServer(), "RootPath", "", GetADV97()))
		if substr(cPath, len(cPath),1) <> "\"
			cPath += "\"
		endif
		cPath += pcStartPath 

		cHeader	:= "--" + cboundary + CRLF
		cHeader += "Content-Disposition: form-data;"
		cHeader += ' name="edFileImport"; '
		cHeader += 'filename="' + cPath + pcDestFileName + '"' + CRLF
		cHeader += "Content-Type: text/xml" + CRLF + CRLF
	
		oXMLDW := procNode(oDestXML:_DATAWAREHOUSE,,,,.F.,pcStartPath)
		oXMLDW:oAddChild(procNode(oDestXML:_DATAWAREHOUSE:_SERVERS,,,,,pcStartPath))
		cPost := cHeader
		cPost += oXMLDW:cXMLString(.T., ENCODING) + CRLF + CRLF
		cPost += "--" + cboundary + "--"

		cRet := dwHttpPost(AllTrim(pcUrl)+"/w_sigadw3.apw", "action=" + AC_TOOLS_IMPORT + "&oper="+dwStr(OP_REC_NEW)+"&suboper=&edFileImport=" + cPath + pcDestFileName,cPost, , aGetCook("multipart/form-data; boundary="+cboundary))
	   	oImpMeter:Set(nMeter++)
	
		if valtype(cRet) == "U"
			return ImpErro(STR0054)
	  	elseif !("aph/apl: h_dwBuildAba()" $ cRet)
			return ImpErro(STR0054)
	   	endif             
   
    	// Importar DIMENSIONS           
		if ValType(oDestXML:_DATAWAREHOUSE:_DIMENSIONS:_DIMENSION) == "A"
			nQtd := len(oDestXML:_DATAWAREHOUSE:_DIMENSIONS:_DIMENSION)  
			lArray := .T.
		else	
			nQtd := 1
			lArray := .F.
		endif
	
		for nChild := 1 to nQtd
			oXMLDW := procNode(oDestXML:_DATAWAREHOUSE,,,,.F.,pcStartPath)
			oAux := oXMLDW:oAddChild(procNode(oDestXML:_DATAWAREHOUSE:_DIMENSIONS,,,,.F.,pcStartPath))
			if lArray
				oAux:oAddChild(procNode(oDestXML:_DATAWAREHOUSE:_DIMENSIONS:_DIMENSION[nChild],,,,,pcStartPath))
			else
				oAux:oAddChild(procNode(oDestXML:_DATAWAREHOUSE:_DIMENSIONS:_DIMENSION,,,,,pcStartPath))
			endif
			cPost := cHeader
			cPost += oXMLDW:cXMLString(.T., ENCODING) + CRLF + CRLF
			cPost += "--" + cboundary + "--"

			cRet := dwHttpPost(AllTrim(pcUrl)+"/w_sigadw3.apw", "action=" + AC_TOOLS_IMPORT + "&oper="+dwStr(OP_REC_NEW)+"&suboper=",cPost, , aGetCook("multipart/form-data; boundary="+cboundary))
	   		oImpMeter:Set(nMeter++)

		   	if valtype(cRet) == "U"
				return ImpErro(STR0054)
		  	elseif !("aph/apl: h_dwBuildAba()" $ cRet)
				return ImpErro(STR0054)
		   	endif             
	    next nChild
    
		// Importar CUBES
		if ValType(oDestXML:_DATAWAREHOUSE:_CUBES:_CUBE) == "A"
			nQtd := len(oDestXML:_DATAWAREHOUSE:_CUBES:_CUBE)
			lArray := .T.
		else	
			nQtd := 1
			lArray := .F.
		endif

		for nChild := 1 to nQtd
			oXMLDW := procNode(oDestXML:_DATAWAREHOUSE,,,,.F.,pcStartPath)
			oAux := oXMLDW:oAddChild(procNode(oDestXML:_DATAWAREHOUSE:_CUBES,,,,.F.,pcStartPath))
			if lArray
				oAux:oAddChild(procNode(oDestXML:_DATAWAREHOUSE:_CUBES:_CUBE[nChild],,,,,pcStartPath))
			else
				oAux:oAddChild(procNode(oDestXML:_DATAWAREHOUSE:_CUBES:_CUBE,,,,,pcStartPath))
			endif
			cPost := cHeader
			cPost += oXMLDW:cXMLString(.T., ENCODING) + CRLF + CRLF
			cPost += "--" + cboundary + "--"

			cRet := dwHttpPost(AllTrim(pcUrl)+"/w_sigadw3.apw", "action=" + AC_TOOLS_IMPORT + "&oper="+dwStr(OP_REC_NEW)+"&suboper=",cPost, , aGetCook("multipart/form-data; boundary="+cboundary))
	   		oImpMeter:Set(nMeter++)

		   	if valtype(cRet) == "U"
				return ImpErro(STR0054)
		  	elseif !("aph/apl: h_dwBuildAba()" $ cRet)
				return ImpErro(STR0054)
		   	endif             
    	next nChild

		// Importar QUERYS
		oXMLDW := procNode(oDestXML:_DATAWAREHOUSE,,,,.F.,pcStartPath)
		oXMLDW:oAddChild(procNode(oDestXML:_DATAWAREHOUSE:_QUERYS,,,,,pcStartPath))
		cPost := cHeader
		cPost += oXMLDW:cXMLString(.T., ENCODING) + CRLF + CRLF
		cPost += "--" + cboundary + "--"
    
		cRet := dwHttpPost(AllTrim(pcUrl)+"/w_sigadw3.apw", "action=" + AC_TOOLS_IMPORT + "&oper="+dwStr(OP_REC_NEW)+"&suboper=",cPost, , aGetCook("multipart/form-data; boundary="+cboundary))
		oImpMeter:Set(nMeter++)

		if valtype(cRet) == "U"
			return ImpErro(STR0054)
  		elseif !("aph/apl: h_dwBuildAba()" $ cRet)
			return ImpErro(STR0054)
   		endif
	             
		oWizard:oBack:Show()
		oWizard:oNext:Show()
		oWizard:oCancel:Show()
	
		oWizard:SetPanel(12)
	endif
	
	oDestXML    := NIL
	oXMLDW		:= NIL
	cRet		:= NIL
	cHeader		:= NIL
	cPath		:= NIL
	cPost		:= NIL
	cboundary 	:= NIL
	nMeter		:= NIL
	DelClassIntf()
	
return .t.
                                     
static function ImpErro(Mensagem)

	MsgInfo( Mensagem, STR0039 )
	oImpMeter:Set(0)

	oWizard:oBack:Show()
	oWizard:oNext:Show()
	oWizard:oCancel:Show()
	oWizard:SetPanel(10)

return .F.

static function dwHttpPost(cURL, cpGet, cpPost, nTimeout, aHeader)
	local cRet := ""
                               
	if valType(cpGet) == "C"
    	cpGet += "&_sigaAdv=1"
	endif                                 
	if valType(nTimeout) == "U"
		nTimeOut := 60
	endif

	cRet := httppost(cURL, cpGet, cpPost, nTimeout, aHeader)
   
return cRet

static function aGetCook(acEncyType)
	local aCook  := {}  
	
	default acEncyType := ""
	                                        
	// ATENCAO: Esta linha eh apenas uma indicação do SigaDW, para o correto tratamento
	//          na geração de mensagens de erro. A URL não tem influência sobre a geração
	//          ou no tratamento efetuado.
	//          Recomenda-se manter este valor, exceto se for necessário novos paramatros 
	//          para o GET. 
	aadd(aCook, "Referer: http://localhost/w_sigadw3.apw?_sigaAdv=1")
	
	if empty(acEncyType)
 		aadd(aCook, "Content-Type: application/x-www-form-urlencoded")
	else
 		aadd(aCook, "Content-Type: " + acEncyType)
 	endif
    
	if valType(SESSION_ID) == "U"
		aadd(aCooK, "Cookie:" )
  	else
		aadd(aCooK, "Cookie: SESSIONID="+SESSION_ID)
	endif
     
return aCook

function WzHabCons()

local oWizard     
local cTextStep1 := ""
local nInd
local aQuerys := getConsXML(getPathStart() + NAME_XML_ORIGEM)    
local validMeta := isValidMetaWizard("\systemload\" + NAME_XML_ORIGEM)
local aQuerysResult := {}
local paiAnt := ""
local cTemp := ""    
local aTreeSel := {}
local aTreeResult := {}         

cTextStep1 := STR0051

DEFINE WIZARD oWizard ;
	TITLE STR0045 ;
	MESSAGE STR0046 ;
	TEXT cTextStep1 ;
	NEXT {||.T. } ;
	FINISH {||.T.} 
	
CREATE PANEL oWizard  ;
	HEADER STR0045 ;
	MESSAGE STR0045	;
	BACK {||.T.} ;
	NEXT {||confirmHab(oWizard, aQuerysResult), .T.} ;
	FINISH {||.T.}  ;
	PANEL 
	
CREATE PANEL oWizard  ;
	HEADER STR0045 ;
	MESSAGE STR0047	;
	BACK {||.F.} ;
	FINISH {||.T.} ;
	PANEL 
@ 010,010 GET STR0052 MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3] 

DEFINE DBTREE oTreeQuery FROM 00,00  TO 100,200 OF oWizard:oMPanel[2] CARGO PIXEL
oTreeQuery:align := CONTROL_ALIGN_LEFT
oTreeQuery:nWidth := 220  
oTreeQuery:bchange := {||clickedNode(oTreeQuery, aQuerys)}

DEFINE DBTREE oTreeResult FROM 00,100  TO 100,200 OF oWizard:oMPanel[2] CARGO PIXEL
oTreeResult:align:=CONTROL_ALIGN_RIGHT
oTreeResult:nWidth := 220                                 
oTreeResult:bchange := {||clickedNode(oTreeResult, aQuerysResult)}

oPanelCenter:= tPanel():New(10,10,"",oWizard:oMPanel[2],,,,,CLR_WHITE,100,100) 
oPanelCenter:align:= CONTROL_ALIGN_ALLCLIENT

oPanelBottom:= tPanel():New(10,10,"",oWizard:oMPanel[2],,,,,CLR_WHITE,0,0)
oPanelBottom:align := CONTROL_ALIGN_BOTTOM 
oPanelBottom:nHeight := 60

oButtonAdd:=tButton():New(0,10,STR0010,oPanelCenter,{ ||tranferNodeTree( oTreeQuery, oTreeResult , aQuerys, aQuerysResult,.F. ) },100,20,,,,.T.) 
oButtonAdd:nWidth:= oPanelCenter:nWidth/2                                   

oButtonRem:=tButton():New(25,10,STR0011,oPanelCenter,{||tranferNodeTree(oTreeResult, oTreeQuery, aQuerysResult, aQuerys, .T.)},100,20,,,,.T.) 
oButtonRem:nWidth:= oPanelCenter:nWidth/2

oButtonAddAll:=tButton():New(50,10,STR0012,oPanelCenter,{||transferTree(oTreeQuery, oTreeResult, aQuerys, aQuerysResult,.F.)},100,20,,,,.T.) 
oButtonAddAll:nWidth:= oPanelCenter:nWidth/2                        

oButtonRemAll:=tButton():New(75,10,STR0013,oPanelCenter,{||transferTree(oTreeResult, oTreeQuery, aQuerysResult, aQuerys,.T.)},100,20,,,,.T.) 
oButtonRemAll:nWidth:= oPanelCenter:nWidth/2                        
                       
createTree(oTreeQuery, aQuerys )
if validMeta == .T.
	ACTIVATE WIZARD oWizard CENTERED
else
	msgStop(STR0090) //###"XML Invalido"
	oWizard:setFinish()
endif
      
return

static function clickedNode(oTree, aQuerys)
	Local cMsg := ""

	if left(oTree:getCargo(),1) == "$"
		clrMsg()
	else
		cMsg := STR0091 + CRLF + aQuerys[val(oTree:getCargo())][3] //###"Descrição: "
		oPanelBottom:cCaption := cMsg
	endif
return    

static function clrMsg()
	oPanelBottom:cCaption := ""
return 

static function confirmHab( oWizard, aQuerysResult )
	if len(aQuerysResult) == 0
	    msgStop(STR0048, STR0099) //###"Wizard DW"
	    oWizard:SetPanel(1)
	else
		if msgYesNo(STR0049, STR0099) //###"Wizard DW"
		    createMail( aQuerysResult )
		else
			oWizard:SetPanel(1)
		endif
	endif                                                                                     
return

static function createMail( aQuerysResult )
	local cHtml, nInd, cPaiAnt
	local cMailUser
	
	cHtml := "<html>"
	cHtml += "<head>"
	cHtml += "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
	cHtml += "</head>"
	cHtml += "<body>"
	cHtml += "<p><font size='2' face='Verdana, Arial, Helvetica, sans-serif'>" + STR0092 + " " + alltrim(subs(cUsuario,7,15)) //###"O usuario"
  	cHtml += " " + STR0093 + " " + dwStr(WFCodUser(alltrim(subs(cUsuario,7,15)))) + ", " + STR0094 + "</font></p>" //###"código"###"está pedindo permissão para acessar as seguintes consultas dos indicadores nativos:"
  	
	cHtml += "<table width='100%' border='0'>
	orderArray( aQuerysResult )
	for nInd := 1 to len( aQuerysResult )
		if !aQuerysResult[nInd][1] == cPaiAnt
			cHtml += "<tr>"
			cHtml += "<td width='9%'><font size='2' face='Verdana, Arial, Helvetica, sans-serif'><b>"+ aQuerysResult[nInd][1] +"</b></font></td>
			cHtml += "<td width='81%'>&nbsp;</td>
			cHtml += "<td width='10%'>&nbsp;</td>
			cHtml += "</tr>
			cPaiAnt := aQuerysResult[nInd][1]
		endif                                
		cHtml += "<tr>
		cHtml += "<td>&nbsp;</td>
		cHtml += "<td><font size='2' face='Verdana, Arial, Helvetica, sans-serif'>" + aQuerysResult[nInd][3] + " ( " + aQuerysResult[nInd][2] + " )</font></td>"
		cHtml += "<td>&nbsp;</td>
		cHtml += "</tr>
	next
	cHtml += "</table>
	cHtml += "</body>"
	cHtml += "</html>"
	
	PSWOrder(1)
	if PSWSeek(WFCodUser(alltrim(subs(cUsuario,7,15))), .T.)
	     cMailUser := PSWRet()[1][14]                              
	else
		cMailUser := ""
	endif		                                                   
	if GetMV("MV_WFADMIN") == ""
	    msgStop(STR0095) //###"Não foi possível concluir sua solicitação, não existe email de administrador do sistema cadastrado."
		oWizard:Finish()
	else
		WFNewMsg(GetMV("MV_WFMLBOX"),GetMV("MV_WFADMIN"),"", "" , STR0096, cHtml, {} ) //###"Pedido de Acesso à consultas do DW"
		WFSndMsg(GetMV("MV_WFMLBOX"))
	endif
return

static function tranferNodeTree( oTreeOrigem, oTreeDestino, aQuerys, aQuerysResult, lRemove )
	local nPos, nTemp, cCompar
   	if left(oTreeOrigem:getCargo(), 1) == "$" // selecionou node pai
    	nPos    := dwVal(substr(oTreeOrigem:getCargo(),2))
		nTemp   := aScan(aQuerys, {|x| x[1] == aQuerys[nPos][1]}) 			
		cCompar := aQuerys[nPos][1]
		nTemp   := 1
		while nTemp <= len(aQuerys)
			if aQuerys[nTemp][1] == cCompar
				if lRemove
					aDel(aQuerys, nTemp)
					aSize(aQuerys, len(aQuerys) - 1)
					nTemp--
				else
		       		if aScan(aQuerysResult, {|x| x[1] == aQuerys[nTemp][1] .and. x[2] == aQuerys[nTemp][2]}) == 0
						aAdd(aQuerysResult, aQuerys[nTemp])                   
					endif
				endif
			endif
			nTemp++
		enddo
	else                 
        nPos 	 := dwVal(oTreeOrigem:getCargo()) 
        if nPos > 0
	        if lRemove
    	    	aDel (aQuerys, nPos)
				aSize(aQuerys, len(aQuerys) -1)
			else
		       	if aScan(aQuerysResult, {|x| x[1] == aQuerys[nPos][1] .and. x[2] == aQuerys[nPos][2]}) == 0
    		    	aAdd(aQuerysResult, aQuerys[nPos])
				endif       	
			endif
		endif
	endif             
	
	if lRemove
		createTree( oTreeOrigem, aQuerys)
	else
    	createTree( oTreeDestino, aQuerysResult )
	endif
	
    clrMsg()
return

static function transferTree( oTreeOrigem, oTreeDestino, aQuerysOrigem, aQuerysDestino, lRemove )
	local aRet := {}

	if !lRemove
		aEval(aQuerysOrigem, { |x| aAdd(aRet, aClone(x))} )
		aQuerysDestino := aRet
		createTree( oTreeDestino, aQuerysDestino )
    else
		aQuerysOrigem := {} 
		createTree( oTreeOrigem, aQuerysOrigem )
	endif
	clrMsg()
return

function getConsXML(cFileName)

	Local oXML, nInd
	Local aQuerys := {}
	Local cError   := STR0050
	Local cWarning := ""    
	Local aTemp := {}
                               
	oXML := XmlParserFile(cFileName, "_", @cError, @cWarning )      
	if xmlChildCount(oXML:_DATAWAREHOUSE:_QUERYS) > 0
		aTemp := iif(valType(oXML:_DATAWAREHOUSE:_QUERYS:_QUERY)== "A" , oXML:_DATAWAREHOUSE:_QUERYS:_QUERY, { oXML:_DATAWAREHOUSE:_QUERYS:_QUERY })
		for nInd := 1 to len(aTemp)
			aAdd(aQuerys, { iif(aTemp[nInd]:_GRUPO:TEXT == "","Indefinido",aTemp[nInd]:_GRUPO:TEXT), aTemp[nInd]:_NOME:TEXT, aTemp[nInd]:_DESCRICAO:TEXT, aTemp[nInd]:_HABPONL:TEXT, ;
				iif(xmlNodeExist( aTemp[nInd]:_TABLE:_MEASURES, "_Attributes"), "T", "F"),;
				iif(xmlNodeExist( aTemp[nInd]:_GRAPHIC:_MEASURES, "_Attributes"), "T", "F") } )
		next      
	endif
    
	DelClassIntf()
	
return aQuerys

function isValidMetaWizard(cFileName)
	local isValid := .F. 
	Local oXML
	Local cError   := STR0050
	Local cWarning := "" 
	
	if File(cFileName)
		oXML := XmlParserFile(cFileName, "_", @cError, @cWarning )  	               
		if oXML:_DATAWAREHOUSE:_TEMPLATE:TEXT == "T" .AND. oXML:_DATAWAREHOUSE:_DW:TEXT == "IndNativosTemplate"
			isValid := .T.
  		endif
  	endif 
                          
	DelClassIntf()           
	
return isValid

static function orderArray( aValue )
	aSort(aValue ,,, {|x,y| x[1] < y[1]})	
return aValue    
  
static function clearTree( oTree, aValues )
	oTree:Reset()
return

static function createTree ( oTree, aQuerys ) 
	local nInd, cPaiAnt, lVazio := .T.  
	clearTree ( oTree )
	orderArray( aQuerys )
	oTree:beginUpdate()
	for nInd := 1 to len(aQuerys) 
		lVazio := .F.
		if !cPaiAnt == aQuerys[nInd][1]
			if !nInd == 1
		   		DBENDTREE oTree
	   		endif
	   		DBADDTREE oTree PROMPT padr(aQuerys[nInd][1], 30) CARGO "$" + Padr(nInd, 6)
		endif
	   	DBADDITEM oTree PROMPT aQuerys[nInd][2] CARGO Padr(nInd,6)
		cPaiAnt := aQuerys[nInd][1]
	next                              
	if lVazio == .F.
		DBENDTREE oTree
	endif
	oTree:endUpdate()
	clrMsg()
	
return  NIL   

Function getPathStart()
return DwFixPath(Alltrim(GetPvProfString(getEnvServer(), "StartPath", "", GetADV97())))



