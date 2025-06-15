#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TAFCSS.CH"
#INCLUDE "TAFMONDEF.CH"
#INCLUDE "TAFMONTES.CH"

#DEFINE GRID_MOVEUP       	0
#DEFINE GRID_MOVEDOWN     	1
#DEFINE GRID_MOVEHOME     	2
#DEFINE GRID_MOVEEND      	3
#DEFINE GRID_MOVEPAGEUP   	4
#DEFINE GRID_MOVEPAGEDOWN	5
#DEFINE CRLF 			  	Chr(13) + Chr(10)

// Por causa de atualiza��o de Lib, verifica se existe a fun��o FindClass e com a fun��o verifica se existe a classe FWCSSTools.
// Na vers�o 12.1.25, a fun��o FindCLass (framework) est� com erro. Portanto, ela n�o � avaliada e por conta da obrigatoriedade da atualiza��o da Lib, n�o � necess�rio avaliar a existencia da classe.

Static lLaySimplif 	:= taflayEsoc("S_01_00_00")
Static lFindClass	:= FindFunction("TAFFindClass") .And. TAFFindClass( "FWCSSTools" )
Static dDataLim		:= Nil 

//--------------------------------------------------------------------
/*/{Protheus.doc} TAFMONTES
Tela de Par�metros do Monitor e-Social
@author evandro.oliveira
@param lFirstTime - Indica de a tela est� sendo chamada do monitor
ou se � a primeira execu��o.
@since 26/01/2016
@version 1.0
@return ${nil}
/*/
//--------------------------------------------------------------------
Function TafMontES(lFirstTime)

	Local oSize				:= FwDefSize():New(.F.)
	Local nTop				:= 0
	Local nLeft				:= 0
	Local nBottom			:= 0
	Local nRight			:= 0
	Local nX				:= 0
	Local nLVisao			:= 0
	Local nAVisao			:= 0
	Local nLEvento			:= 0
	Local nAEvento			:= 0
	Local nLPeriod			:= 0
	Local nAPeriod			:= 0
	LoCAL nLStatus			:= 0
	Local aRowsGer			:= {}
	Local lChkPenT			:= .T.
	Local lChkTras			:= .T.
	Local nCursorPos		:= 0
	Local nRecNo			:= 1
	Local nLenData			:= 0
	Local oCPendTr			:= Nil
	Local oCNProce			:= Nil
	Local oCValido			:= Nil
	Local oCInvali			:= Nil
	Local oSayAmb			:= Nil
	Local oSayFim			:= Nil
	Local lCloseDlg			:= .F.
	Local cMsgAmb			:= ""
	Local cMsgFim			:= ""
	Local cAmbEsocial		:= GetNewPar( "MV_TAFAMBE", "2" )
	Local cNmAmb			:= ""
	Local cVerSchema		:= SuperGetMv('MV_TAFVLES',.F.,"02_05_00")
	Local cIniEsoc			:= SuperGetMv('MV_TAFINIE',.F.," ")
	Local cTamFont			:= ""
	Local cTamFont1			:= ""
	Local cTamFont2			:= ""
	Local cTamFont3			:= ""
	Local cTamFont4			:= ""
	Local cTamFont5			:= ""
	Local cTamFont6			:= ""
	Local nVerLib			:= ""
	Local lOkC8E			:= .T.
	Local lTransFil			:= SuperGetMv('MV_TAFTFIL',.F.,.F.) //Permite que seja realizado a transmiss�o pela Filial
	Local lNoVldEst     	:= SuperGetMv("MV_TAFVLUF", .F., .F.) //Permite que seja realizado a integra��o de codigos de municipios incompativeis com a UF
	Local lehMatriz			:= .F.
	Local oGrid				:= Nil
	Local oTabFilSel		:= Nil //Armazena as filiais selecionadas por tabelas de evento
	Local lWebApp			:= IIF(lFindClass,GetRemoteType() == REMOTE_HTML .or. (FWCSSTools():GetInterfaceCSSType() == 5),.F.)
	Local aItems 			:= {'RM','DATASUL','PROTHEUS','OUTROS','TODOS'}

	Private aHeadGer		:= {}
	Private aParamES		:= Array(17)
	Private aEventosParm	:= {}
	Private oMBrwTabs		:= Nil
	Private aStatus			:= {}
	Private aLegEvts		:= {}
	Private lMarkAll		:= .F.
	Private lInformix		:= (TcGetDb()=="INFORMIX")
	Private lPostgre		:= (TcGetDb()=="POSTGRES")
	Private lLockAuton 		:= .F.

	Default lFirstTime		:= .T.

	If dDataLim == Nil 
	
		cAmbTopId := GetEnv('tph_topologyid') 

		If Empty(cAmbTopId)
			dDataLim := CtoD("01/04/2022")	// Data limite para o uso do Monitor eSocial QT GERAL
		Else 
			dDataLim := CtoD("01/07/2022")	// Data limite para o uso do Monitor eSocial QT NO CLOUD
		EndIf 
	EndIf 

	If NewPanESoc(dDataLim)
		Return
	EndIf

	aStatus := { {01,STR0001 ,STR0007}; //"Pendente/Inv�lido"#"TRANSMISS�O N�O EFETUADA - Informa��es inv�lidas que necessitam de revis�o."
	,{02,STR0002 ,STR0008}; //"Transmitido/Aguardando"#"Aguardando retorno do RET."
	,{03,STR0003 ,STR0009}; //"Retornado/Inconsitente"#"Retornado do Governo com inconsit�ncias. NECESS�RIO INTERVEN��O MANUAL."
	,{04,STR0004 ,STR0010}; //"Retornado/Consistente"#"Validado e Protocolado pelo Governo"
	,{06,STR0209 ,STR0210}; //"Transmitido/Aguardando Exclus�o"#"Aguardando retorno da Exclus�o do RET."
	,{07,STR0004 ,STR0211}; //"Evento de Exclus�o validado e protocolado pelo Governo."
	,{99,STR0005 ,STR0011}; //"Pendente/N�o Validado"#"N�o realizado a valida��o do registro pelo usu�rio."
	,{00,STR0006 ,STR0012}; //"Pendente/Valido"#"Pronto para Transmiss�o."
	}

	aLegEvts := { {01,"C"};
		,{02,"I"};
		,{03,"M"};
		,{04,"E"};
		}

	//Verifica se a filial logada � a filial matriz
	DBSelectArea("C1E")
	C1E->( DBSetOrder(3) )
	If C1E->( MSSeek( xFilial("C1E") + PadR( SM0->M0_CODFIL, TamSX3( "C1E_FILTAF" )[1] ) + "1" ) )
		If C1E->C1E_MATRIZ == .T.
			lehMatriz := .T.
		EndIf
	EndIf

	DbSelectArea("C8E")
	C8E->(DbSetOrder(2))
	C8E->(DbGoTop())
	If C8E->( Eof() )
		lOkC8E := .F.
	EndIf

	If FindFunction("PROTDATA") .And. ProtData() .Or. !FindFunction("PROTDATA")
		If (lehMatriz .Or. lTransFil) .And. TAFAlsInDic('T0X') .And. TAFColumnPos( "T0X_USER" ) .And. lOkC8E .And. !lNoVldEst
			nVerLib:= GetRemoteType()
			cTamFont := IIF(lWebApp ,'-18','-11')
			cTamFont1:= IIF(lWebApp,'-1','2')
			cTamFont2:= IIF(lWebApp,FONT_HELP_2,FONT_HELP)
			cTamFont3:= IIF(lWebApp,FONT_HELP_4,FONT_HELP_1)
			cTamFont4:= IIF(lWebApp,FONT_BLACK_5,FONT_BLACK_3)
			cTamFont5:= IIF(lWebApp,'-2','3')
			cTamFont6:= IIF(lWebApp,'-19','-12')

			//Verifica qual tipo de ambiente foi configurado
			//pela wizard de configura��o do esocial.
			If cAmbEsocial == "1"
				cNmAmb := STR0171 //Produ��o
			ElseIf cAmbEsocial == "2"
				cNmAmb := STR0172 //Pr�-produ��o - dados reais
			Else
				cNmAmb := STR0173 //Pr�-produ��o - dados fict�cios
			EndIf

			FRetEvts()
			If !FLoadProf()
				aParamES[1]		:=	.T.			//paramStsNaoProcessados
				aParamES[2]		:=	.T.			//paramStsValidos
				aParamES[3]		:=	.T.			//paramStsInvalidos
				aParamES[4]		:=	.T.			//paramStsSemRetorno
				aParamES[5]		:=	.T.			//paramStsConsistente
				aParamES[6]		:=	.T.			//paramStsInconsistente
				aParamES[7]		:=	1				//paramVisao
				aParamES[8]		:=	.T.			//paramEtvTabelas
				aParamES[9]		:=	.T.			//paramEtvIniciais ** Descontinuado **
				aParamES[10]	:=	.T.			//paramEtvPeriodicos
				aParamES[11]	:=	.T.			//paramEtvNaoPeriodicos
				aParamES[12]	:=	dDatabase	//paramDataInicial
				aParamES[13]	:=	dDatabase	//paramDataFim
				aParamES[14]	:=	{}			//paramFiliais
				aParamES[15]	:=	{}			//paramTAFKEY
				aParamES[16]	:=	'TODOS'		//paramERPOwner
				aParamES[17]    :=  .F.
			Else
				If !(paramStsNaoProcessados .Or. paramStsValidos .Or. paramStsInvalidos)
					lChkPenT := .F.
				EndIf
				If !(paramStsSemRetorno .Or. paramStsConsistente .Or. paramStsInconsistente)
					lChkTras := .F.
				Endif
			EndIf

			oSize:lLateral := .T.
			oSize:AddObject( "LAYER", 100, 100, .T., .T. )

			oSize:Process()

			nTop    := oSize:aWindSize[1] - (oSize:aWindSize[1] * 0.08)
			nLeft   := oSize:aWindSize[2] - (oSize:aWindSize[2] * 0.08)
			nBottom := oSize:aWindSize[3] - (oSize:aWindSize[3] * 0.08)
			nRight  := oSize:aWindSize[4] - (oSize:aWindSize[4] * 0.08)

			Define MsDialog oDlg Title STR0013 From nTop,nLeft To nBottom,nRight  Pixel //"Par�metros - Monitor de Integra��o e-Social"

			oLayer := FWLayer():New()
			oLayer:Init( oDlg, .F. )
			oLayer:AddLine( "LINE01", 37 )
			oLayer:AddLine( "LINE02", 58 )
			oLayer:AddLine( "LINE03", 05 )

			oLayer:AddCollumn( "BOX_SUPERIOR",100,,"LINE01" )
			oLayer:AddCollumn( "BOX_ESQUERDO",50,,"LINE02" )
			oLayer:AddCollumn( "BOX_DIREITO",50,,"LINE02" )

			oLayer:AddWindow( "BOX_SUPERIOR","PANEL00",STR0014, 100, .F.,,,"LINE01" ) //"Status Geral das movimenta��es:"

			oLayer:AddWindow( "BOX_DIREITO"	, "PANEL01",STR0015,033, .F.,,,"LINE02" ) //"Eventos:"
			oLayer:AddWindow( "BOX_DIREITO"	, "PANEL03",STR0016 + ' / ' + STR0272 + ' / ' + STR0274 ,033, .F.,,,"LINE02" ) //"Vis?o / ERP Origem:"
			oLayer:AddWindow( "BOX_DIREITO"	, "PANEL04",STR0017,034, .F.,,,"LINE02" ) //"Per�odo*:"

			oLayer:AddWindow( "BOX_ESQUERDO", "PANEL02",STR0018,100, .F.,,,"LINE02" ) //"Status:"

			oGeral   := oLayer:GetWinPanel("BOX_SUPERIOR","PANEL00","LINE01")
			oVisao	  := oLayer:GetWinPanel("BOX_DIREITO","PANEL03","LINE02")
			oStatus  := oLayer:GetWinPanel("BOX_ESQUERDO" ,"PANEL02","LINE02")
			oEventos := oLayer:GetWinPanel("BOX_DIREITO","PANEL01","LINE02")
			oPeriodo := oLayer:GetWinPanel("BOX_DIREITO","PANEL04","LINE02")
			oRodape  := oLayer:getLinePanel("LINE03")

		/*+----------------------------------------------------+
		  | Cria��o do Objeto TGRID - Painel Status Geral Mov. |
		  +----------------------------------------------------+*/
		IF !(lWebApp)
			oPGeral := TPanel():New(00,00,"",oGeral,,.F.,.F.,,,0,oGeral:NCLIENTHEIGHT * 0.13,.F.,.F.)
			oPGeral:Align = CONTROL_ALIGN_TOP

			cMsgAmb := '<font size="' + cTamFont1 + '" color="RED">'
			cMsgAmb += STR0170 + '<b>' + cNmAmb + '</b>' //Ambiente do eSocial configurado para transmiss�o de Eventos
			cMsgAmb += '</font>'
			
			oSayAmb := TSay():New(000,005,{||cMsgAmb},oPGeral,,,,,,.T.,,,oPGeral:NCLIENTWIDTH * 0.49,030,,,,,,.T.)

			cMsgFim := '<font size="' + cTamFont5 + '" color="RED">'
			cMsgFim += STR0278 + ' <b>' + DtoC(dDataLim) + '</b>, ' +  STR0282 + ' <b>' + STR0283 + '</b>.' // "A partir do dia" / "todas as transmiss�es de eventos do e-Social, dever�o ser realizadas atrav�s do novo" / "Painel e-Social"
			cMsgFim += '</font>'

			oSayFim := TSay():New(006,005,{||cMsgFim},oPGeral,,,,,,.T.,,,oPGeral:NCLIENTWIDTH * 0.49,030,,,,,,.T.)

			cMsg := cTamFont2
			cMsg += STR0019 //'Este Painel ilustra um resumo de todas as movimenta��es do eSocial contidas no sistema, '
			cMsg += STR0020 //'dando uma vis�o gen�rica sobre poss�veis problemas junto ao Goveno e a possibilidade '
			cMsg += STR0021 //'de explor�-los com mais detalhes e objetividade na interface de monitoramento;  '
			cMsg += STR0022 //'passo seguinte as parametriza��es abaixo."

			oSInfoSG1 := TSay():New(012,005,{||cMsg},oPGeral,,,,,,.T.,,,oPGeral:NCLIENTWIDTH * 0.49,030,,,,,,.T.)

			oPGrid := TPanel():New(00,00,"",oGeral,,.F.,.F.,,,0,oGeral:NCLIENTHEIGHT * 0.28,.F.,.F.) //40.88       //146 total
			oPGrid:Align = CONTROL_ALIGN_TOP
			/*+-----------------------------------+
			| Montagem da barra de rolagem	   |
			+-----------------------------------+*/
			oPBarra := TPanel():New(0,0,,oPGrid,,,,,, 10,200,.F.,.T. )
			oPBarra:Align:= CONTROL_ALIGN_RIGHT
			
			If !lWebApp
				oPBarra:SetCSS(QLABEL_AZUL_A)
			EndIf
	   	Else
			oPGeral := TPanel():New(00,00,"",oGeral,,.F.,.F.,,,0,oGeral:NCLIENTHEIGHT * 0.13,.F.,.F.)
			oPGeral:Align = CONTROL_ALIGN_TOP

			cMsgAmb := '<font size="' + cTamFont + '" color="RED">'
			cMsgAmb += STR0170 + '<b>' + cNmAmb + '</b>' //Ambiente do eSocial configurado para transmiss�o de Eventos
			cMsgAmb += '</font>'

			cMsgFim := '<font size="' + cTamFont5 + '" color="RED">'
			cMsgFim += STR0278 + ' <b>' + DtoC(dDataLim) + '</b>, ' +  STR0282 + ' <b>' + STR0283 + '</b>.' // "A partir do dia" / "todas as transmiss�es de eventos do e-Social, dever�o ser realizadas atrav�s do novo" / "Painel e-Social"
			cMsgFim += '</font>'
		
			cMsg := ""

			oSayAmb 	:= TSay():New(000,005,{||cMsgAmb},oPGeral,,,,,,.T.,,,oPGeral:NCLIENTWIDTH  * 0.49,030,,,,,,.T.)
			oSayFim 	:= TSay():New(006,005,{||cMsgFim},oPGeral,,,,,,.T.,,,oPGeral:NCLIENTWIDTH * 0.49,030,,,,,,.T.)
			oSInfoSG1 	:= TSay():New(012,005,{||cMsg}   ,oPGeral,,,,,,.T.,,,oPGeral:NCLIENTWIDTH  * 0.49,030,,,,,,.T.)
			oPGrid 		:= TPanel():New(00,00,""         ,oGeral,,.F.,.F.,,,0,oGeral:NCLIENTHEIGHT * 0.28,.F.,.F.) //40.88       //146 total
			oPGrid:Align = CONTROL_ALIGN_TOP
		 	/*+-----------------------------------+
			  | Montagem da barra de rolagem	   |
			  +-----------------------------------+*/
			oPBarra := TPanel():New(0,0,,oPGrid,,,,,, 10,200,.F.,.T. )
			oPBarra:Align:= CONTROL_ALIGN_RIGHT
			
			If !lWebApp
				oPBarra:SetCSS(QLABEL_AZUL_A)
			EndIf
	   	Endif
	    oBttUp := TBtnBmp():NewBar( "VCUP.BMP",,,,,{||FMvGoUp(1,oGrid,@nCursorPos,@nRecno,aRowsGer)},,oPBarra)
	    oBttUp:Align:= CONTROL_ALIGN_TOP

	    oBttDown := TBtnBmp():NewBar( "VCDOWN.BMP",,,,, {||FMvGoDown(1,oGrid,@nCursorPos,@nRecno,aRowsGer,@nLenData)},,oPBarra)
	    oBttDown:Align:= CONTROL_ALIGN_BOTTOM

		/*+------------------------------------------------------------+
		  | Esse array controla quais dados devem ser exibidos na TGrid|
		  | pode-se incluir/alterar posi��o/remover itens desde que os |
		  | mesmos tenham na terceira posi��o um status v�lido para o  |
		  | eSocial												       |
		  +-----------------------------------------------------------+*/
	   	aHeadGer := {  {STR0023,CONTROL_ALIGN_LEFT,Nil}; //'Eventos'
	   					,{STR0024,0,Nil}; //'Geral'
	   					,{STR0025,0,STATUS_NAO_PROCESSADO[1]}; //'N�o Processados'
	   					,{STR0026,0,STATUS_VALIDO[1]}; //'Aguardando Transmiss�o'
	   					,{STR0027,0,STATUS_INVALIDO[1]}; //'Inv�lidos'
	   					,{STR0028,0,STATUS_SEM_RETORNO_GOV[1]}; //'Sem Retorno do Governo'
	   					,{STR0029,0,STATUS_INCONSISTENTE[1]}} //'Inconsitente'

		nTamCol := ((oPGrid:NCLIENTWIDTH) * 0.97)/ Len(aHeadGer)

	   	aRowsGer := FCountRegs(cVerSchema,cIniEsoc)

		IF !(nVerLib == 5)
		oGrid:= tGrid():New(oPGrid,000,000,oPGrid:NCLIENTWIDTH * 0.492,oPGrid:NCLIENTHEIGHT * 0.50)
		else
			oGrid:= tGrid():New(oPGrid,000,000,oPGrid:NCLIENTWIDTH * 0.492,oPGrid:NCLIENTHEIGHT * 0.50)
		Endif
		oGrid:SetSelectionMode(1)
		oGrid:lShowGrid := .F.
		oGrid:SetCSS(TGRID_HEADER_GRADIENTE_B)
		nLenData := Len(aRowsGer)
		oGrid:bCursorMove:= {|o,nMvType,nCurPos,nOffSet,nVisRows|FOnMove(o,nMvType,nCurPos,nOffSet,nVisRows,@nCursorPos,@nRecno,aRowsGer,@nLenData) }
		oGrid:bLDblClick := {|o|FMarkPar(o,nRecno)}

		aEval(aHeadGer,{|h|oGrid:AddColumn(1,h[1]	,nTamCol,h[2],.F.)})

	  	For nX := 1 To Len(aRowsGer)
	   		oGrid:SetRowData(nX,{||aRowsGer[nX]})
		Next nX

		oPRodp := TPanel():New(00,00,"",oGeral,,.F.,.F.,,,0,oGeral:NCLIENTHEIGHT * 0.30,.F.,.F.)
		oPRodp:Align = CONTROL_ALIGN_TOP

	   	oBRefresh := TButton():New(002,003,STR0030,oPRodp,{||FWMsgRun(oGrid,{||FRfTGrid(oGrid,cVerSchema,cIniEsoc,@aRowsGer)})  }, 70,10,,,.F.,.T.,.F.,,.F.,,,.F. )  //"Atualizar Resumo"
	   	oBRefresh:SetCSS(BTNLINK)

		cMsg1 := cTamFont4
		cMsg1 += STR0032 //'* Por serem relacionadas a uma apura��o, os n�meros apresentados '
		cMsg1 += '<b>' + STR0033 + ' - ' + Substr(DTOC(dDatabase),4,7) + '</b> ' //correspondem ao per�odo atual
		cMsg1 += STR0034 //'da data base informada no login. '

		oSInfoSG2 := TSay():New(004,oPRodp:NCLIENTWIDTH  * 0.155,{||cMsg1},oPRodp,,,,,,.T.,,,oPRodp:NCLIENTWIDTH * 0.35,030,,,,,,.T.)

		/*+-----------------------------------------+
		  | Cria��o do Objeto TPanel - Painel Vis�o |
		  +-----------------------------------------+*/
		nAVisao := oVisao:NCLIENTHEIGHT * 0.50
		nLVisao := oVisao:NCLIENTWIDTH
	   	oPVisao := TPanel():New(00,00,"",oVisao,,.F.,.F.,,,nLVisao,nAVisao,.F.,.F.)
		cMsgVisao := cTamFont2
		cMsgVisao += STR0035 //'Determina a forma de apresenta��o das informa��es para monitoramento'
		oSInfoVis := TSay():New(002,005,{||cMsgVisao},oPVisao,,,,,,.T.,,,100,030,,,,,,.T.)

		oRadio := TRadMenu():New (nAVisao * 0.62,010,{STR0036,STR0037},,oPVisao,,,,,,,,100,30,,,,.T.,.T.) //"Por Evento"#"Por Trabalhor"
		oRadio:bSetGet := {|u|Iif (PCount()==0,aParamES[7],aParamES[7]:=u)}
		oRadio:bWhen   := {|| Empty(aParamES[15]) }


		cMsgOwner	:= cTamFont2
		cMsgOwner	+= STR0271 //"Selecione o ERP de Origem"
		oSInfoOwn 	:= TSay():New(005,/*240*/nLVisao * 0.2604,{||cMsgOwner},oPVisao,,,,,,.T.,,,nLVisao,nAVisao,,,,,,.T.)

		aParamES[16] := aItems[5]
		oCombo1 := TComboBox():New(oPVisao:NCLIENTHEIGHT * 0.30,oPVisao:NCLIENTWIDTH * 0.135	,{|u|if(PCount()>0,aParamES[16]:=u,aParamES[16])},aItems,60,11,oPVisao,,{||},,,,.T.,,,,,,,,,'cCombo1')
		
		Iif(aParamES[17], aParamES[14] := XFunFilLog(aParamES[17]), aParamES[14] := NIl )
		oChkBox := TCheckBox():New(oPVisao:NCLIENTHEIGHT * 0.30,oPVisao:NCLIENTWIDTH * 0.200 ,STR0273,{||aParamES[17]},oPVisao,200,250,,{ || aParamES[17] := !aParamES[17], aParamES[14] := XFunFilLog(aParamES[17]) },,,,,,.T.,,,)
	   

		/*+-------------------------------------------+
		  | Cria��o do Objeto TPanel - Painel Eventos |
		  +-------------------------------------------+*/
		nAEvento := oEventos:NCLIENTHEIGHT * 0.50
		nLEvento := oEventos:NCLIENTWIDTH

	  	oPEvento := TPanel():New(00,00,"",oEventos,,.F.,.F.,,,nLEvento,nAEvento,.F.,.F.)
	  	lCheck := .T.

	  	cMsgEvts := cTamFont2
		cMsgEvts += STR0038 //'Permite Filtrar os tipos de eventos a serem visualizados durante o monitoramento.'
		oSInfEvts := TSay():New(002,005,{||cMsgEvts},oPEvento,,,,,,.T.,,,oPEvento:NCLIENTWIDTH * 0.49,030,,,,,,.T.)

	  	oCTab  := TCheckBox():New(oPEvento:NCLIENTHEIGHT * 0.30,oPEvento:NCLIENTWIDTH * 0.010,STR0215,{||aParamES[8]},oPEvento,200,050,,{||aParamES[8] := !aParamES[8]},,,,,,.T.,,,) //"Tabelas e Eventos Sem Rela��o com o Trabalhador"
	  	oCPer  := TCheckBox():New(oPEvento:NCLIENTHEIGHT * 0.30,oPEvento:NCLIENTWIDTH * 0.145,STR0041,{||aParamES[10]},oPEvento,100,050,,{||aParamES[10] := !aParamES[10]},,,,,,.T.,,,)//'Peri�dicos'
	  	oCNPer := TCheckBox():New(oPEvento:NCLIENTHEIGHT * 0.30,oPEvento:NCLIENTWIDTH * 0.200,STR0042,{||aParamES[11]},oPEvento,100,050,,{||aParamES[11] := !aParamES[11]},,,,,,.T.,,,)//'N�o Peri�dicos'

		/*+-------------------------------------------+
		  | Cria��o do Objeto TPanel - Painel Per�odo |
		  +-------------------------------------------+*/
		nLPeriod := oPeriodo:NCLIENTWIDTH
		nAPeriod := oPeriodo:NCLIENTHEIGHT * 0.50

	  	oPPeriodo := TPanel():New(00,00,"",oPeriodo,,.F.,.F.,,,nLPeriod,nAPeriod,.F.,.F.)

	  	cMsgPer := cTamFont2
		cMsgPer += STR0043 +  "<b><u> " + STR0044+ " </u></b>" + STR0045 //Permite Filtrar os eventos#Peri�dicos e N�o peri�dicos#que s�o controlados por per�odo de apura��o.
		oSInfPer 	:= TSay():New(002,005,{||cMsgPer},oPPeriodo,,,,,,.T.,,,oPPeriodo:NCLIENTWIDTH * 0.49,030,,,,,,.T.)

		oSDtIni 	:= TSay():New(nAPeriod * 0.58,oPPeriodo:NCLIENTWIDTH * 0.010,{||STR0046},oPPeriodo,,,,,,.T.,,,oPPeriodo:NCLIENTWIDTH * 0.49,030,,,,,,.T.) //"Data Inicial "
	  	oTDataIni 	:= TGet():New(nAPeriod * 0.50,oPPeriodo:NCLIENTWIDTH * 0.048,{|u|If( PCount()==0,aParamES[12],aParamES[12] := u )},oPPeriodo,065,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,STR0046,,,,.T.) //"Data Inicial"

		oSDtFim 	:= TSay():New(nAPeriod * 0.58,oPPeriodo:NCLIENTWIDTH * 0.141,{||STR0047},oPPeriodo,,,,,,.T.,,,oPPeriodo:NCLIENTWIDTH * 0.49,030,,,,,,.T.) //"Data Fim"
	  	oTDataFIm 	:= TGet():New(nAPeriod * 0.50,oPPeriodo:NCLIENTWIDTH * 0.170,{|u|If( PCount()==0,aParamES[13],aParamES[13] := u )},oPPeriodo,065,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,STR0048,,,,.T.) //"Data Final"

		/*+-------------------------------------------+
		  | Cria��o do Objeto TPanel - Painel Status  |
		  +-------------------------------------------+*/
		nLStatus := oStatus:NCLIENTWIDTH

	  	oPStatus := TPanel():New(00,00,"",oStatus,,.F.,.F.,,,nLStatus,oStatus:NCLIENTHEIGHT,.F.,.F.)
	 	nAStatus := oPStatus:NCLIENTHEIGHT
	 	cMsgSts := cTamFont2
		cMsgSts += STR0049 //'Estas op��es permitem filtrar as movimenta��es a serem apresentados para monitoramento conforme status de processamento.'
		oSatus  := TSay():New(nAStatus*0.005,005,{||cMsgSts},oPStatus,,,,,,.T.,,,oPStatus:NCLIENTWIDTH * 0.24,030,,,,,,.T.)

	  	oCPendTr := TCheckBox():New(nAStatus*0.045,005,STR0050,{||lChkPenT},oPStatus,100,210,,; //'Pendentes de TRANSMISS�O'
	  	{||lChkPenT := !lChkPenT,(aParamES[1] := lChkPenT,aParamES[2] := lChkPenT,aParamES[3] := lChkPenT),oCNProce:Refresh(),oCValido:Refresh(),oCInvali:Refresh()},,,,,,.T.,,,)
	  	cMsgPTr := cTamFont2
		cMsgPTr += STR0051 // 'Permite filtrar registros antes da TRANSMISS�O do Governo para monitoramento.'
		oSPenTr := TSay():New(nAStatus*0.060,005,{||cMsgPTr},oPStatus,,,,,,.T.,,,oPStatus:NCLIENTWIDTH * 0.45,030,,,,,,.T.)

	 	oCNProce := TCheckBox():New(nAStatus*0.083,oPStatus:NCLIENTWIDTH * 0.015,STR0052,{||aParamES[1]},oPStatus,100,210,,; //'N�o processados'
	 	{||aParamES[1] := FVldChk(aParamES[1],aParamES[2],aParamES[3],@lChkPenT),oCPendTr:Refresh()},,,,,,.T.,,,)
	  	cMsgNP := cTamFont2
		cMsgNP +=  STR0053 //'Ainda n�o avalidados pelo sistema.'
		oSPenTr := TSay():New(nAStatus*0.100,oPStatus:NCLIENTWIDTH * 0.015,{||cMsgNP},oPStatus,,,,,,.T.,,,oPStatus:NCLIENTWIDTH * 0.07,030,,,,,,.T.)

	  	oCValido := TCheckBox():New(nAStatus*0.083,oPStatus:NCLIENTWIDTH * 0.100,STR0054,{||aParamES[2]},oPStatus,100,210,,; //'V�lidos'
	  	{||aParamES[2] := FVldChk(aParamES[2],aParamES[1],aParamES[3],@lChkPenT),oCPendTr:Refresh()},,,,,,.T.,,,)
	  	cMsgVld := cTamFont2
		cMsgVld +=  STR0055 // 'Registros prontos para transmiss�o.'
		oSPenTr := TSay():New(nAStatus*0.100,oPStatus:NCLIENTWIDTH * 0.100,{||cMsgVld},oPStatus,,,,,,.T.,,,oPStatus:NCLIENTWIDTH * 0.07,030,,,,,,.T.)

	  	oCInvali := TCheckBox():New(nAStatus*0.083,oPStatus:NCLIENTWIDTH * 0.170,STR0056,{||aParamES[3]},oPStatus,100,210,,; //'Inv�lidos'
	  	{||aParamES[3] := FVldChk(aParamES[3],aParamES[1],aParamES[2],@lChkPenT),oCPendTr:Refresh()},,,,,,.T.,,,)
	  	cMsgInv := cTamFont2
		cMsgInv += STR0057 + "<b><i> " + STR0058 + " </i></b>"	//Registros com inconsist�ncias#N�O SER�O TRANSMITIDOS
		oSPenIv := TSay():New(nAStatus*0.100,oPStatus:NCLIENTWIDTH * 0.170,{||cMsgInv},oPStatus,,,,,,.T.,,,oPStatus:NCLIENTWIDTH * 0.08,030,,,,,,.T.)

		//-------------------------

	  	oCTrans := TCheckBox():New(nAStatus*0.142,005,STR0059,{||lChkTras},oPStatus,150,210,,; //'Transmitidos/Retornados pelo Governo'
	  	{||lChkTras := !lChkTras,aParamES[4] := lChkTras,oCSRet:Refresh(),aParamES[5] := lChkTras,oCRtns:Refresh(),aParamES[6] := lChkTras,oCIncos:Refresh()},,,,,,.T.,,,)
	  	cMsgTrs := cTamFont2
		cMsgTrs += STR0060
		oSPenTr := TSay():New(nAStatus*0.156,005,{||cMsgTrs},oPStatus,,,,,,.T.,,,oPStatus:NCLIENTWIDTH * 0.40,030,,,,,,.T.)

	  	oCSRet  := TCheckBox():New(nAStatus*0.177,oPStatus:NCLIENTWIDTH * 0.015,STR0061,{||aParamES[4]},oPStatus,100,210,,; //'Sem retorno'
	  	{||aParamES[4] := FVldChk(aParamES[4],aParamES[5],aParamES[6],@lChkTras),oCTrans:Refresh()},,,,,,.T.,,,)
	  	cMsgST := cTamFont2
		cMsgST += STR0062 //'Registros pendentes com o Governo; Aguardando retorno do mesmo.'
		oSPenTr := TSay():New(nAStatus*0.194,oPStatus:NCLIENTWIDTH * 0.015,{||cMsgST},oPStatus,,,,,,.T.,,,oPStatus:NCLIENTWIDTH * 0.07,030,,,,,,.T.)

	 	oCRtns := TCheckBox():New(nAStatus*0.177,oPStatus:NCLIENTWIDTH * 0.100,STR0063,{||aParamES[5]},oPStatus,100,210,,; //'Consistente'
	 	{||aParamES[5] := FVldChk(aParamES[5],aParamES[4],aParamES[6],@lChkTras),oCTrans:Refresh()},,,,,,.T.,,,)
	  	cMsgCst := cTamFont2
		cMsgCst += STR0064 //'Registro processados com sucesso.'
		oSRetor := TSay():New(nAStatus*0.194,oPStatus:NCLIENTWIDTH * 0.100,{||cMsgCst},oPStatus,,,,,,.T.,,,oPStatus:NCLIENTWIDTH * 0.07,030,,,,,,.T.)

	  	oCIncos  := TCheckBox():New(nAStatus*0.177,oPStatus:NCLIENTWIDTH * 0.170,STR0065,{||aParamES[6]},oPStatus,100,210,,; //'Inconsistente'
	  	{||aParamES[6] := FVldChk(aParamES[6],aParamES[4],aParamES[5],@lChkTras),oCTrans:Refresh()},,,,,,.T.,,,)
	  	cMsgInc := cTamFont2
		cMsgInc += STR0066 + ' <b><i> ' + STR0067 + ' </i></b>'
		oSPenTr := TSay():New(nAStatus*0.194,oPStatus:NCLIENTWIDTH * 0.170,{||cMsgInc},oPStatus,,,,,,.T.,,,oPStatus:NCLIENTWIDTH * 0.08,030,,,,,,.T.)

		oBCancl := TButton():New(000,oRodape:NCLIENTWIDTH * 0.015,STR0068,oRodape,{||IIf(lFirstTime,(oDlg:End(),lCloseDlg := .F.),(lCloseDlg := .F.,oDlg:End()) ) }, 55,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"#'Monitor eSocial'#'Carregando Monitor eSocial'

		If lehMatriz
			oBApli3 := TButton():New(000,oRodape:NCLIENTWIDTH * 0.335,STR0201,oRodape,{|| IIF(aParamES[7] == 1, aParamES[15] := PergTAFKEY(), MsgAlert("N�o � poss�vel inserir a Chave de Integra��o (TAFKEY) na vis�o por Trabalhador. Favor utilizar a vis�o por Evento.", "Consulta n�o permitida"))},55,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Chave de Integra��o"
			oBApli2 := TButton():New(000,oRodape:NCLIENTWIDTH * 0.390,"Selecionar Filiais",oRodape,{||aParamES[14] := xFunTelaFil(.T.,Nil,Nil,Nil,Nil,.F.,,.T.,"TAFMONTES"),If(oTabFilSel <> NIL,oTabFilSel:Delete(),Nil)},55,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Selecionar Filiais'
		Else
			oBApli3 := TButton():New(000,oRodape:NCLIENTWIDTH * 0.390,STR0201,oRodape,{|| IIF(aParamES[7] == 1, aParamES[15] := PergTAFKEY(), MsgAlert("N�o � poss�vel inserir a Chave de Integra��o (TAFKEY) na vis�o por Trabalhador. Favor utilizar a vis�o por Evento.", "Consulta n�o permitida"))},55,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Chave de Integra��o"
			aParamES[14] := TafMSelFilias()
		Endif

		oBAplic := TButton():New(000,oRodape:NCLIENTWIDTH * 0.445,STR0069,oRodape,{||IIf(FValdPar(aParamES[14],lehMatriz),(lCloseDlg := .T.,oDlg:End()),.F.)},55,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Aplicar Filtro"#'Monitor eSocial'#'Carregando Monitor eSocial'

		Activate MsDialog oDlg Centered

		If lCloseDlg
			FWMsgRun(,{||FCriaMonit(@lFirstTime,@oTabFilSel)},STR0070,STR0071)
		EndIf

		If oTabFilSel <> Nil
			oTabFilSel:Delete()
		EndIf

	Else

		If !lehMatriz .And. !lTransFil
			//"S� � possivel acessar a rotina do monitor de transmiss�o do eSocial logado na filial matriz."
			Aviso(STR0213 , STR0212, { STR0214 }, 2 ) // "#Rotina indispon�vel#Encerrar"
		ElseIf !lOkC8E
			Aviso(STR0213 , STR0231, { STR0214 }, 2 ) // "Autocontidas desatualizadas. � necess�rio executar o Wizard de Configura��o do TAF e a atualiza��o das Tabelas AutoContidas para o correto funcionamento do monitor."
		ElseIf lNoVldEst
			Aviso(STR0213 , "N�o � permitido realizar a transmiss�o de eventos com o par�metro MV_TAFVLUF habilitado. Este par�metro desabilita a valida��o do c�digo de municipio e pode gerar inconsist�ncias nos envios de eventos relativos ao trabalhador, o mesmo deve ser utilizado somente para a carga de XMLs na rotina de Migra��o.", { STR0214 }, 2 ) 
		Else
			Aviso(STR0213 , STR0222 , { STR0214 }, 2 ) //"Dicion�rio de dados desatualizado, � necess�rio que as atualiza��es de dicion�rio do layout 2.04.01 estejam aplicadas para o correto funcionamento do monitor. "
		EndIf
	EndIf
EndIf
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} PergTAFKEY

Interface de par�metros do filtro de Chaves de Integra��o.

@Author		Felipe C. Seolin
@Since		05/07/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function PergTAFKEY()

Local oDlg			:= Nil
Local oFont			:= Nil
Local cTAFKEY		:= ""
Local nTamTAFKEY	:= 500
Local nPos			:= 0
Local nLarguraBox	:= 0
Local nAlturaBox	:= 0
Local nLarguraSay	:= 0
Local nTop			:= 0
Local nAltura		:= 250
Local nLargura		:= 1040
Local nPosIni		:= 0
Local aTAFXERP		:= {}
Local lRet			:= .F.
Local nVerLib		:= GetRemoteType()
Local cTamFont1		:= IIF(nVerLib == 5,'-1','2')
Local cTamFont2		:= IIF(nVerLib == 5,FONT_HELP_2,FONT_HELP)


aTAFXERP := xTAFGetStru( "TAFXERP" )[1]
If ( nPos := aScan( aTAFXERP, { |x| AllTrim( x[1] ) == "TAFKEY" } ) ) > 0
	nTamTAFKEY := aTAFXERP[nPos,3]
	nTamTAFKEY *= 10
EndIf

cTAFKEY	:=	Space( nTamTAFKEY )

oFont := TFont():New( "Arial",, -11 )

oDlg := MsDialog():New( 0, 0, nAltura, nLargura, STR0202,,,,,,,,, .T. ) //"Seleciona Chaves de Integra��o"

nAlturaBox := ( nAltura - 60 ) / 2
nLarguraBox := ( nLargura - 20 ) / 2

@10,10 to nAlturaBox,nLarguraBox of oDlg Pixel

nLarguraSay := nLarguraBox - 30
nTop := 20

@15,15 to 50,nLarguraBox - 10 of oDlg Pixel

cMsgAmb := "<font size='"+cTamFont1+"' color='RED'>"
cMsgAmb += "<b>" + STR0203 + "</b>" //"Orienta��es de uso do filtro de Chaves de Integra��o"
cMsgAmb += "</font>"

TSay():New( nTop, 20, { || cMsgAmb }, oDlg,,,,,, .T.,,, oDlg:nClientWidth * 0.46, 010,,,,,, .T. )

nTop += 10

cMsg := cTamFont2
cMsg += "- " + STR0204 //"Digite o c�digo da Chave de Integra��o ( TAFKEY ) que voc� deseja considerar no filtro."
cMsg += "<br>"
cMsg += "- " + STR0205 //"Separe os diversos c�digos com uma v�rgula para que o sistema considere mais de um c�digo no filtro."

TSay():New( nTop, 20,{ || cMsg} , oDlg,,,,,, .T.,,, oDlg:nClientWidth * 0.46, 020,,,,,, .T. )

nTop += 30

TGet():New( nTop, 20, { |x| If( PCount() == 0, cTAFKEY, cTAFKEY := x ) }, oDlg, oDlg:nClientWidth * 0.46, 10,,,,,,,, .T.,,,,,,,,,, "cTAFKEY",,,,,,, STR0201, 1, oFont ) //"Chave de Integra��o"
nTop += 10

nPosIni := ( ( nLargura - 20 ) / 2 ) - ( 2 * 32 )

SButton():New( nAlturaBox + 10, nPosIni, 1, { |x| Iif( lRet := VldTAFKEY( cTAFKEY ), x:oWnd:End(), ) }, oDlg )
SButton():New( nAlturaBox + 10, nPosIni + 32, 2, { |x| x:oWnd:End() }, oDlg )

oDlg:Activate( ,,,.T. )

Return( cTAFKEY )

//---------------------------------------------------------------------
/*/{Protheus.doc} VldTAFKEY

Valida��o da entrada de dados dos par�metros do filtro de Chaves de Integra��o.

@Param		cTAFKEY	- Conte�do do campo de Chaves de Integra��o

@Return		lRet 	- Indica se todas as condi��es foram respeitadas

@Author		Felipe C. Seolin
@Since		06/07/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function VldTAFKEY( cTAFKEY )

Local cAliasQry	:= ""
Local cSelect	:= ""
Local cFrom		:= ""
Local cWhere	:= ""
Local cIN		:= ""
Local nI		:= 0
Local aTAFKEY	:= Separa( cTAFKEY, "," )
Local aCompare	:= {}
Local lRet		:= .T.


For nI := 1 to Len( aTAFKEY )
	If Empty( aTAFKEY[nI] )
		MsgInfo( STR0206 ) //"C�digo para busca digitado incorretamente. Favor seguir orienta��es de uso."
		lRet := .F.
		Exit
	Else
		cIN += Iif( Empty( cIN ), "", "," ) + "'" + AllTrim( aTAFKEY[nI] ) + "'"
	EndIf
Next nI

If lRet
	cAliasQry := GetNextAlias()

	cSelect	:= "DISTINCT TAFXERP.TAFKEY "
	cFrom	:= "TAFXERP TAFXERP "
	cWhere	:= "     TAFXERP.TAFKEY IN( " + cIN + " ) "
	cWhere	+= "AND TAFXERP.D_E_L_E_T_ = '' "

	cSelect	:= "%" + cSelect + "%"
	cFrom  	:= "%" + cFrom   + "%"
	cWhere 	:= "%" + cWhere  + "%"

	BeginSql Alias cAliasQry
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
	EndSql

	( cAliasQry )->( DBGoTop() )

	While ( cAliasQry )->( !Eof() )
		aAdd( aCompare, AllTrim( ( cAliasQry )->TAFKEY ) )
		( cAliasQry )->( DBSkip() )
	EndDo

	( cAliasQry )->( DBCloseArea() )

	For nI := 1 to Len( aTAFKEY )
		If aScan( aCompare, { |x| AllTrim( x ) == AllTrim( aTAFKEY[nI] ) } ) <= 0
			MsgInfo( I18N( STR0207, { AllTrim( aTAFKEY[nI] ) } ) ) //"O c�digo #1 n�o existe na base de dados do TAF."
			lRet := .F.
			Exit
		EndIf
	Next nI
EndIf

Return( lRet )
//--------------------------------------------------------------------
/*/{Protheus.doc} FValdPar
Valida a consist�ncia dos par�metros selecionados
@author evandro.oliveira
@since 19/02/2016
@version 1.0
@return ${logico}, ${Verifica se o monitor pode ser criado ou n�o}
@example
(examples)
@see (links_or_references)
/*/
//--------------------------------------------------------------------
Static Function FValdPar( aFSelFil, lehMatriz)

Local cMsg		:= ""
Local lValid	:= .T.
Local lCancSel	:= .F.

Default aFSelFil	:=	{}

	/*+----------------------------------------------------------------+
	  | Quando selecionado somente o par�metro evento cadastro inicial |
	  | a vis�o obrigatoriamente deve ser por trabalhador              |
	  +----------------------------------------------------------------+*/
	If !paramEtvTabelas .And. !paramEtvPeriodicos .And. !paramEtvNaoPeriodicos
		cMsg := STR0072 //"Selecionar ao menos 1 par�metro do grupo Eventos"
		lValid := .F.
	ElseIf (paramEtvIniciais .And. (!paramEtvTabelas .And. !paramEtvPeriodicos .And. !paramEtvNaoPeriodicos) .And. (paramVisao == 1))
		cMsg := STR0073 //"Quando selecionado somente o par�metro INICIAIS (Box Eventos) a VIS�O deve obrigatoriamente ser por trabalhador."
		lValid := .F.

	ElseIf !paramStsNaoProcessados .And. !paramStsValidos .And. !paramStsInvalidos .And. !paramStsSemRetorno .And. !paramStsConsistente .And. !paramStsInconsistente
		cMsg := STR0075 //"Selecionar ao menos 1 item do Box Status."
		lValid := .F.
	ElseIf paramDataFim < paramDataInicial
		cMsg := STR0161 // "Data Final n�o pode ser menor que a Data Inicial"
		lValid := .F.
	ElseIf Len(aFSelFil) <= 0

		If lehMatriz 
			lCancSel := .F.

			While Empty(aParamES[14]) .And. !lCancSel
				aParamES[14] := xFunTelaFil(.T., Nil, Nil, Nil, Nil, .F.,@lCancSel,.T.,"TAFMONTES")
			EndDo
		

			If lCancSel
				lValid := .F.
				cMsg := STR0232 // "Nenhuma filial selecionada"
			EndIf
		EndIf

	EndIf

	If !lValid
		Aviso(STR0076,cMsg,{STR0077},3) //"Diverg�ncia de Par�metros"#"Ok"
	Else
		FSalvProf()
	EndIf

Return (lValid)
//--------------------------------------------------------------------
/*/{Protheus.doc} FVldChk
Valida a a��o de mudan�a de estado do checkbox e verifica se
o valor do Check pai deve receber o valor do check filho
@author evandro.oliveira
@since 16/03/2016
@version 1.0
@param cChkAtu, character, (CheckBox que est� executando a a��o)
@param cChkGrp1, character, (CheckBox Pertencente ao Grupo)
@param cChkGrp2, character, (CheckBox Pertencente ao Grupo)
@param lChkPai, ${param_type}, (Descri��o do par�metro)
@return ${!cChkAtu}, ${Valor do CheckBox ap�s a a��o}
@obs Cada grupo tem 3 checkboxs
//--------------------------------------------------------------------
/*/
Static Function FVldChk(cChkAtu,cChkGrp1,cChkGrp2,lChkPai)

	If lChkPai
		If !cChkAtu != lChkPai
			If  (cChkGrp1 != lChkPai) .And. (cChkGrp2 != lChkPai)
				lChkPai := !cChkAtu
			EndIf
		EndIf
	Else
		If !cChkAtu != lChkPai
			If  (cChkGrp1 == lChkPai) .And. (cChkGrp2 == lChkPai)
				lChkPai := !cChkAtu
			EndIf
		EndIf
	EndIf

Return !cChkAtu
//--------------------------------------------------------------------
/*/{Protheus.doc} FMarkPar
Marca Par�metro de Status na a��o do duplo clique na grid
de status geral das movimenta��es
@author evandro.oliveira
@since 15/03/2016
@version 1.0
@param oGrid, objeto, (Descri��o do par�metro)
@param nCursorPos, num�rico, (Descri��o do par�metro)
@return ${Nil}
/*/
//--------------------------------------------------------------------
Static Function FMarkPar(oGrid,nRecno)
Local nPosCol := oGrid:ColPos()

	If nPosCol == 3
		aParamES[1] := !aParamES[1] //paramStsNaoProcessados
	ElseIf nPosCol == 4
		aParamES[2] := !aParamES[2] //paramStsValidos
	ElseIf nPosCol == 5
		aParamES[3] := !aParamES[3] //paramStsInvalidos
	ElseIf nPosCol == 6
		aParamES[4] := !aParamES[4] //paramStsSemRetorno
	ElseIf nPosCol == 7
		aParamES[6] := !aParamES[6]	//paramStsInconsistente
	EndIf

Return Nil
//--------------------------------------------------------------------
/*/{Protheus.doc} FRfTGrid
Atualiza Grid de Status Geral das movimenta��es
@author evandro.oliveira
@since 18/02/2016
@version 1.0
@param oGrid, objeto, (Objeto TGrid da tela de par�metros)
@param cVerSchema, char, (Versao do Layout e-Social)
@param cIniEsoc, char, (Data de Inicio do e-Social)
@return ${true}
/*/
//--------------------------------------------------------------------
Static Function FRfTGrid(oGrid,cVerSchema,cIniEsoc,aRowsGer)
Local nX := 0

aRowsGer := {}

oGrid:ClearRows()
aRowsGer := FCountRegs(cVerSchema,cIniEsoc)

For nX := 1 To Len(aRowsGer)
	oGrid:SetRowData(nX,{||aRowsGer[nX]})
Next nX

Return .T.
//--------------------------------------------------------------------
/*/{Protheus.doc} FRetEvts
Alimenta os arrays aEventosParm e aRotESoc com as informa��es dos
eventost eSocial separados por tipo.

@author evandro.oliveira
@since 22/02/2016
@version 1.0
@return ${nil}
/*/
//--------------------------------------------------------------------
Static Function FRetEvts()

	Local nX		:= 0
	Local aRotESoc	:= {}
	Local cEvtsNT	:= Iif(ExistFunc("TAFEvtsNT"), TAFEvtsNT(), "")

	aEventosParm := Array(4)
	aRotESoc := TAFRotinas(,,.T.,2)

	//Incluida fun��o que avalia todas as rotinas de acordo com as permiss�es de usu�rio para trava de Aut�nomos nos eventos S-1200 e S-1210.
	TafPermUsu(aRotESoc) 

	//Inicio os Sub Arrays baseando-se nos defines de eventos
	//[1] - Array com eventos
	//[2] - Determina se o parametro relacionado ao evento foi selecionado na tela de filtro.
	//[3] - Informa o Tipo do Evento (I=inicial, M=mensal etc)
	aEventosParm[EVENTO_INICIAL_VINCULO[1]] := {{},.T.,EVENTO_INICIAL_VINCULO[2]} /** Compatibilidade - Fora de Uso */
	aEventosParm[EVENTOS_INICIAIS[1]] := {{},.T.,EVENTOS_INICIAIS[2]} //Aqui est�o tamb�m os eventos sem rela��o com o trabalhador
	aEventosParm[EVENTOS_MENSAIS[1]] := {{},.T.,EVENTOS_MENSAIS[2]}
	aEventosParm[EVENTOS_EVENTUAIS[1]] := {{},.T.,EVENTOS_EVENTUAIS[2]}

	dbSelectArea("C8E")
	C8E->(dbSetOrder(2))

	For nX := 1 To Len(aRotESoc)
		If !Empty(aRotESoc[nX][4]) .AND. C8E->(MsSeek(xFilial("C8E")+aRotESoc[nX][4])) .AND. !aRotESoc[nX][4] $ cEvtsNT
			If aRotESoc[nX][12] == EVENTOS_INICIAIS[2] .Or. aRotESoc[nX][15] == "S"

				criaArraydeEventos(EVENTOS_INICIAIS[1],nX,aRotESoc)

			ElseIf aRotESoc[nX][12] == EVENTOS_MENSAIS[2] .And. aRotESoc[nX][15] != "S"

				criaArraydeEventos(EVENTOS_MENSAIS[1],nX,aRotESoc)

			ElseIf aRotESoc[nX][12] == EVENTOS_EVENTUAIS[2] .And. aRotESoc[nX][15] != "S"
				If aRotESoc[nX][4] != "TAUTO"
					criaArraydeEventos(EVENTOS_EVENTUAIS[1],nX,aRotESoc)
				EndIf
			EndIf
		EndIf
	Next nX

Return 

//--------------------------------------------------------------------
/*/{Protheus.doc} criaArraydeEventos
Fun��o auxiliar para a cria��o do array aEventosParm

@param cTipoEvento - Tipo do evento e-Social (inicial, periodico etc..)
@param nX 		- Indexador do la�o
@param aRotESoc - Array com os eventos do e-Social e seus atributos


@author evandro.oliveira
@since 24/08/2017
@version 1.0
@return ${return}, ${return_description}
/*/
//--------------------------------------------------------------------
Static Function criaArrayDeEventos(cTipoEvento,nX,aRotESoc)


	If TAFAlsInDic(aRotESoc[nX][3])
		aAdd(aEventosParm[cTipoEvento][1]; 	//Tipo do Evento
			,{aRotESoc[nX][3];  		//[1]Alias
			,aRotESoc[nX][4];   		//[2]Codigo do Evento
			,AllTrim(C8E->C8E_DESCRI);  //[3]Descri��o do Evento
			,aRotESoc[nX][8];   		//[4]Fun��o de gera��o do XML
			,aRotESoc[nX][9];   		//[5]Tag de Identifica��o do Evento
			,aRotESoc[nX][11];			//[6]Nome do campo relativo ao Id do Trabalhador
			,aRotESoc[nX][6];   		//[7]Data do Evento
			,aRotESoc[nX][12];			//[8]Tipo do Evento (I-Inicial,M-Mensal,E-Eventual,C-Carga,T-Totalizador)
			,aRotESoc[nX][13];			//[9]�ndice chave do protocolo(recibo) (Filial + PROTUL + ATIVO)
			,aRotESoc[nX][14];			//[10]Campo de descri��o do evento no monitor do e-Social. Deve ser um campo que identifique o registro ex: Nome do trabalhador, Desc. Rubrica etc.
			,aRotESoc[nX][15];			//[11]Eventos Periodicos/N�o Periodicos que n�o tem rela��o com o trabalhador. Marcar com S.
			,.F.;  						//[12]Determona se o evento foi selecionado no browse  (DEFAULT - false)
		})

	EndIf

Return Nil

Function FTableCodTabs()

	Local aStru := {}

	If Select(cAliasCodTab) == 0

		aAdd(aStru,{ "FILIAL"  		, "C",  FWSizeFilial(), 0})
		aAdd(aStru,{ "ID"  			, "C",  036, 0})
		aAdd(aStru,{ "VERSAO"  		, "C",  044, 0})
		aAdd(aStru,{ "EVENTO"  		, "C",  006, 0})
		aAdd(aStru,{ "CODIGO"    	, "C",  255, 0})
		aAdd(aStru,{ "DESCRICAO"    , "C",  200, 0})

		cArqCodTabs := FWTemporaryTable():New(cAliasCodTab)
		cArqCodTabs:SetFields(aStru)
		cArqCodTabs:AddIndex("I1",{"FILIAL","ID","EVENTO"})
		cArqCodTabs:Create()

	EndIf

Return


//--------------------------------------------------------------------
/*/{Protheus.doc} FCountRegs
Cria a consulta do Painel de Status Geral das Movimenta��es,
buscando as informa��es dos eventos do TafRotinas.

@param cVerSchema -> Vers�o do layout e-Social
@param cIniEsoc -> Data de inicio do e-Social

@author evandro.oliveira
@since 26/01/2016
@version 1.0
@return ${return}, ${return_description}
/*/
//--------------------------------------------------------------------
Static Function FCountRegs(cVerSchema,cIniEsoc)

	Local cQuery	:= ""
	Local nX		:= 0
	Local nI		:= 0
	Local nEventos	:= 0
	Local aRet		:= {}
	Local lAuxU		:= .F.
	Local aEventos	:= {}
	Local aRotinas	:= {}
	Local cAliasEvt	:= ""
	Local cLayout	:= ""
	Local cCmpData	:= ""
	Local cTipoEvt	:= ""
	Local cIndApu	:= ""

	aEventos := Array(4)
	aRotinas := TAFRotinas(,,.T.,2)

	// Incluida fun��o que avalia todas as rotinas de acordo com as permiss�es de usu�rio para eventos S-1210 e S-1200 para aut�nomos.
	//TafPermUsu(aRotinas) 
	
	//Inicio os Sub Arrays baseando-se nos defines de eventos
	aEventos[EVENTO_INICIAL_VINCULO[1]] := {} //**Compatibilidade */
	aEventos[EVENTOS_INICIAIS[1]] 		:= {}
	aEventos[EVENTOS_MENSAIS[1]] 		:= {}
	aEventos[EVENTOS_EVENTUAIS[1]] 		:= {}


	For nX := 1 To Len(aRotinas)
		If aRotinas[nX][12] == EVENTOS_INICIAIS[2]
			aAdd(aEventos[EVENTOS_INICIAIS[1]],{aRotinas[nX][3],aRotinas[nX][4],aRotinas[nX][6],aRotinas[nX][12]})
		ElseIf aRotinas[nX][12] == EVENTOS_MENSAIS[2]
			aAdd(aEventos[EVENTOS_MENSAIS[1]],{aRotinas[nX][3],aRotinas[nX][4],aRotinas[nX][6],aRotinas[nX][12]})
		ElseIf aRotinas[nX][12] == EVENTOS_EVENTUAIS[2]
			aAdd(aEventos[EVENTOS_EVENTUAIS[1]],{aRotinas[nX][3],aRotinas[nX][4],aRotinas[nX][6],aRotinas[nX][12]})
		EndIf
	Next nX


	For nI := 1 To Len(aEventos)

		nEventos := Len(aEventos[nI])
		lAuxU	  := .F.
		If nEventos > 0
			cQuery :=	"SELECT  TB.XSTATUS  XSTATUS"
			cQuery +=	" ,COUNT(TB.XSTATUS) NREG "
			cQuery += " FROM ("

			For nX := 1 To nEventos

				cAliasEvt := aEventos[nI][nX][1]
				cLayout   := aEventos[nI][nX][2]
				cCmpData  := aEventos[nI][nX][3]  //Campo que determina o periodo ou data do eventos periodicos/nao periodicos
				cTipoEvt  := aEventos[nI][nX][4]  //Tipo do Evento

				If TAFAlsInDic(cAliasEvt)

					If lAuxU
						cQuery +=	" UNION ALL "
					EndIf

					cQuery +=	" SELECT " + cAliasEvt +"_STATUS XSTATUS "
					cQuery +=	" FROM " + RetSqlName(cAliasEvt) + " " + cAliasEvt

					If cLayout = "S-2200"

						cQuery += " LEFT JOIN " + RetSqlName("CUP") + " CUP ON C9V_FILIAL = CUP_FILIAL "
						cQuery += " AND C9V_ID = CUP_ID "
						cQuery += " AND C9V_VERSAO = CUP_VERSAO "
						cQuery += " AND CUP.D_E_L_E_T_ <> '*' "
						cQuery += TafMonPVinc(cIniEsoc,cVerSchema,cLayout,DTOS(FirstDate(dDatabase)),DTOS(LastDate(dDatabase)),cTipoEvt)

					EndIf

					cQuery +=	" WHERE " + cAliasEvt + "_ATIVO = '1' "
					cQuery +=	" AND " + cAliasEvt + ".D_E_L_E_T_ <> '*' "
					//Pego somente as tabelas do periodo atual considerando a database

					If cLayout == "S-2300"
						cQuery +=  TafMonPSVinc(cIniEsoc,cVerSchema,cLayout)
					Else

						If cTipoEvt == EVENTOS_INICIAIS[2]
							cQuery +=	" AND " + cAliasEvt + "_DTINI = '" + StrZero(Month(dDatabase),2) + AllTrim(Str(Year(dDatabase))) + "'"
						ElseIf cTipoEvt == EVENTOS_MENSAIS[2] .Or. cLayout $ "CMJ"

							If lLaySimplif

								cIndApu := Space(GetSx3Cache(cAliasEvt + "_INDAPU", "X3_TAMANHO"))

							EndIf
				
							cQuery += " AND ( "
							
							If !lLaySimplif

								cQuery += " (" + cAliasEvt + "_INDAPU = '1' "

							Else

								cQuery += " ((" + cAliasEvt + "_INDAPU = '1' "
								cQuery += " OR " + cAliasEvt + "_INDAPU = '" + cIndApu + "') "

							EndIf

							cQuery += " AND " + cCmpData + " = '" + AnoMes(dDatabase) + "')"

							If !lLaySimplif

								cQuery += " OR (" + cAliasEvt + "_INDAPU = '2' "

							Else

								cQuery += " OR ((" + cAliasEvt + "_INDAPU = '2' "
								cQuery += " OR " + cAliasEvt + "_INDAPU = '" + cIndApu + "') "

							EndIf

							cQuery += " AND " + cCmpData +  " = '" + AllTrim(Str(Year(dDatabase))) + "')"
							cQuery += ")"
						ElseIf cTipoEvt == EVENTOS_EVENTUAIS[2] .And. !Empty(AllTrim(cCmpData)) .And.  cLayout <> "CMJ"

							If cAliasEvt ==  "CM6"
								cQuery += "AND  "
								cQuery += TafMonPAfast(cVerSchema,DTOS(FirstDate(dDatabase)),DTOS(LastDate(dDatabase)))
							ElseIf cAliasEvt ==  "T3A"
								cQuery += " AND T3A_STATUS = '0'"
							Else
								cQuery += " AND " + cCmpData + " >= '" + DTOS(FirstDate(dDatabase)) + "'"
								cQuery += " AND " + cCmpData + " <= '" + DTOS(LastDate(dDatabase)) + "'"
							EndIf
						EndIf

					EndIf

					If cAliasEvt == "C9V"
						cQuery += 	" AND C9V_NOMEVE = '" + StrTran(cLayout,"-","") + "'"
						cQuery += 	" AND C9V_NOMEVE <> 'TAUTO' " 
					EndIf

					//S� fa�o contagem do registro da Matriz
					If cAliasEvt == "C1E"
						cQuery += " AND C1E_MATRIZ = 'T' "
					EndIf

					// Tratamento para n�o duplicar os eventos de folha que utilizam a tabela C91
					If cAliasEvt == 'C91'
						If cLayout == "S-1200"
							cQuery += 	" AND C91_NOMEVE = 'S1200' "
						Else
							cQuery += 	" AND C91_NOMEVE = 'S1202' "
						EndIf
					EndIf

					// Realiza trava para eventos S-1200 e S-1210 para apenas visualiza��o de aut�nomos.
					If lLockAuton
						If cAliasEvt == "C91"
							cQuery += " AND C91_TRABEV= 'TAUTO' "
						EndIf
						If cAliasEvt == "T3P"
							cQuery += " AND T3P_TRABEV= 'TAUTO' "
						EndIf
					EndIf

					//N�o colocar filtro de Filiais aqui !! O Correto � pegar de todas.
					lAuxU := .T.
				EndIf

			Next nX

			cQuery +=	") TB "
			cQuery +=	" GROUP BY XSTATUS "

			cQuery := ChangeQuery(cQuery)
			TCQuery cQuery New Alias 'TMP1'
			/*+----------------------------------------------------------------+
			  | Agrupo os registros por Status e Quantidade, troco o status    |
			  | "em branco" por 99 para controle interno dos registros sem     |
			  | valida��o													           |
			  +----------------------------------------------------------------+*/
			aAux := {}
			nTotal  := 0
			While TMP1->(!EOF())
				aAdd(aAux,{nI,IIf(Empty(TMP1->XSTATUS),STATUS_NAO_PROCESSADO[1],Val(TMP1->XSTATUS)),TMP1->NREG})
				//Soma o Total Geral por linha
				nTotal += TMP1->NREG
				TMP1->(dbSkip())
			EndDo

			aAdd(aRet,FRetTotLin(aAux,nTotal,nI))
			TMP1->(dbCloseArea())
		Else
			If EVENTO_INICIAL_VINCULO[1] != nI
				aAdd(aRet,FRetTotLin({},0,nI,.T.))
			EndIf
		EndIf

	Next nI

Return aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} FRetTotLin
Retorna a Linha formatada para a cria��o do objeto TGrid,
subdividindo os eventos por linha.
@author evandro.oliveira
@since 26/01/2016
@version 1.0
@param aDados, array, (Totalizador do evento "quebrado" por status)
@param nTotal, num�rico, ()
@param nLinha, num�rico, (Descri��o do par�metro)
@return ${aLin}, ${Array contendo o totalizador da linha de acordo com o Evento x Status}
/*/
//--------------------------------------------------------------------
Static Function FRetTotLin(aDados,nTotal,nLinha,lVazio)
Local aLin		:= Array(Len(aHeadGer))
Local cTitulo	:= ""
Local nX		:= 0
Local nAux		:= 0

Default lVazio	:= .F.

	If !lVazio
		aLin[2] := AllTrim(Str(nTotal))

		For nX := 1 To Len(aHeadGer)
			If aHeadGer[nX][3] <> Nil
				aLin[nX] := AllTrim(Str(IIf((nAux := aScan(aDados,{|x|x[2] == aHeadGer[nX][3]})) > 0,aDados[nAux][3],0)))
			EndIf
		Next nX
	Else
		For nX := 1 To Len(aLin)
			aLin[nX] := "0"
		Next nX
	EndIf

	cTitulo := FRetTitulo(nLinha)
	aLin[1] := cTitulo

Return aLin
//--------------------------------------------------------------------
/*/{Protheus.doc} FRetTitulo
Retorna o Titulo das Colunas do Painel Status Geral das Movimenta��es
@author evandro.oliveira
@since 27/01/2016
@version 1.0
@param nLinha, num�rico, (Linha determinada para o evento no "DEFINE")
@return ${cTitulo}, ${Titulo do Painel}
/*/
//--------------------------------------------------------------------
Static Function FRetTitulo(nLinha)
Local cTitulo := ""

	Do Case
		Case EVENTOS_INICIAIS[1] == nLinha
			cTitulo := STR0039 // "Tabelas"
		Case EVENTOS_MENSAIS[1] == nLinha
			cTitulo := STR0041 //"Peri�dicos *"
		Case EVENTOS_EVENTUAIS[1] == nLinha
			cTitulo := STR0042 //"N�o Peri�dicos *"
	End Case

Return (cTitulo)

//--------------------------------------------------------------------
/*/{Protheus.doc} FCriaMonit
Define Variaveis para os Paineis/Alias/Browse e executa a View Principal
@author evandro.oliveira
@since 03/03/2016
@version 1.0
@param lFirstTime - logico (Variavel criada para controlar se a tela de par�metros
descende da FCriaMonit, neste caso ao voltar para os par�metros o bot�o cancelar ir�
retornar para para esta interface (monitor) ao inves de sair da aplica��o.)
@return ${Nil}
/*/
//--------------------------------------------------------------------
Static Function FCriaMonit(lFirstTime,oTabFilSel)

	Local oSize				:= FwDefSize():New(.F.)
	Local nPercAux			:= 0
	Local oBttExpTb			:= Nil
	Local oBttEdtTb			:= Nil
	Local oBttExpTr			:= Nil
	Local oBttExpSc			:= Nil
	Local oDlgMon				:= Nil
	Local lBackPar			:= .F.
	Local aChecks				:= {}
	Local nRegSelTrb		:= 0
	Local nRegSelEvt		:= 0
	Local oMBrwTabs			:= Nil
	Local oMarkPer			:= Nil 
	Local lTempTable		:= .F.

	Private oMarkTrb		:= Nil
	Private oMarkEvt		:= Nil
	Private oPanelTbl		:= Nil
	Private oPanelTrb		:= Nil
	Private oPanelEvt		:= Nil
	Private cAliasTab		:= "TMPTAB"
	Private cAliasEvt		:= "TMPEVT"
	Private cAliasTrb		:= "TMPTRB"
	Private oTmpTabls		:= Nil
	Private cArqCodTabs		:= ""

	Private cAliasTotEvt	:= "TMPTOTEVT"
	Private cArqCountEvt	:= ""
	Private cArqREtTss		:= ""
	Private cAliasRetTss	:= "TMPRETTSS"
	Private cAlsCodTab		:= "TMPCODTAB"

	Private cArqMark		:= ""
 	Private cAliasMark		:= "TMPMARK"

	Private nCountTrb		:= 0
	Private nCountEvt		:= 0

	Default lFirstTime		:= .F.
	Default oTabFilSel		:= Nil

	FechaAlias()

	/* aChecks
	[1]Parametro
	[2]Campo
	[3]Descri��o
	[4]Status (numerico)
	*/
			aChecks :=   {{    paramStsNaoProcessados	,"REGNPROC",STR0052	,STATUS_NAO_PROCESSADO[1]}; 	//"N�o Processados"
			, {paramStsValidos			,"REGVALID",STR0054	,STATUS_VALIDO[1]}; 			//"V�lidos"
			, {paramStsInvalidos	 	,"REGINVLD",STR0056	,STATUS_INVALIDO[1]}; 			//"Invalidos"
			, {paramStsSemRetorno		,"REGSRET" ,STR0061	,STATUS_SEM_RETORNO_GOV[1]}; 	//"Sem Retorno"
			, {paramStsInconsistente	,"REGINCOS",STR0065	,STATUS_INCONSISTENTE[1]}; 		//"Inconsistente"
			, {paramStsConsistente		,"REGCONST",STR0063	,STATUS_TRANSMITIDO_OK[1]}}		//"Consistente"

			aEventosParm[EVENTOS_INICIAIS[1]][2] := paramEtvTabelas
			aEventosParm[EVENTOS_MENSAIS[1]][2] := paramEtvPeriodicos
			aEventosParm[EVENTOS_EVENTUAIS[1]][2] := paramEtvNaoPeriodicos

			If FindFunction("TafDicInDb")
				lTempTable := TafDicInDb()
			Else
				lTempTable := .F.
			EndIf

			FCountStatus(,@oTabFilSel)

			FTableTSSErr()

			Define MsDialog oDlgMon Title STR0216 From oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4]  Pixel //"Painel e-Social - Vis�o Consolidada"

			oLayer := FWLayer():New()
			oLayer:Init( oDlgMon, .F. )

			oLayer:AddLine("BOX_PARAMETRO", 006)
			oPanelPar := oLayer:getLinePanel("BOX_PARAMETRO")
			TAFBrwPar(oPanelPar,oDlgMon,@lBackPar,aChecks,@nRegSelTrb,@nRegSelEvt,@oMBrwTabs,lTempTable,@oTabFilSel)

			oLayer:AddLine("BOX_AMBIENTE", 005)
			oPanelAmb := oLayer:getLinePanel("BOX_AMBIENTE")

			TAFBrwAmb(oPanelAmb,@oDlgMon)

			If paramEtvTabelas
				nPercAux := IIf(paramEtvPeriodicos .Or. paramEtvNaoPeriodicos ,40,79)
				oLayer:AddLine("BOX_TABELAS", nPercAux)
				oPanelTbl := oLayer:getLinePanel("BOX_TABELAS")
				TafMonETab(oPanelTbl,,aChecks,@oMBrwTabs,lTempTable,@oTabFilSel)
				oLayer:AddLine("BOX_RODAPE_TABELAS",005)
				oRodTabs := oLayer:getLinePanel("BOX_RODAPE_TABELAS")
				TAFBrwRod(oRodTabs,'Tabelas',.T.,.T.,.T.,.T.,oBttExpTb,oBttEdtTb,oBttExpTr,oBttExpSc,aChecks,@nRegSelTrb,@nRegSelEvt,oMBrwTabs,lTempTable,@oTabFilSel,oDlgMon)
			EndIf
	/*+-----------------------------------------------------+
	  | Cria as Views do Trabalhador e Eventos de acordo    |
	  | com os filtros Vis�o e Eventos					    	|
	  +-----------------------------------------------------+*/
	If !paramEtvTabelas .And. (paramEtvPeriodicos .Or. paramEtvNaoPeriodicos)

		If (paramVisao == 1)
			oLayer:AddLine("BOX_PERIODICOS"		, 040) 
			oLayer:AddLine("BOX_TRABALHADOR"	, 044)
			oLayer:AddLine("BOX_RODPERIODICOS"	, 005)

			oPanelEvt := oLayer:getLinePanel("BOX_PERIODICOS")
			oPanelTrb := oLayer:getLinePanel("BOX_TRABALHADOR")
			oRodEvts  := oLayer:getLinePanel("BOX_RODPERIODICOS") 

			oMarkPer := TafMonEPer(oPanelEvt,,aChecks,@nRegSelTrb,@nRegSelEvt,lTempTable,@oTabFilSel)
			TafMonETrb(oPanelTrb,,aChecks,@nRegSelTrb,@nRegSelEvt,lTempTable,@oTabFilSel)
			TAFBrwRod(oRodEvts,'Eventos',.T.,.T.,.T.,.T.,oBttExpTb,oBttEdtTb,oBttExpTr,oBttExpSc,aChecks,@nRegSelTrb,@nRegSelEvt,oMBrwTabs,lTempTable,@oTabFilSel,oDlgMon)
			oMarkPer:oBrowse:GoColumn(1) 

		Else
			oLayer:AddLine("BOX_TRABALHADOR"	, 040)
			oLayer:AddLine("BOX_PERIODICOS"		, 044)
			oLayer:AddLine("BOX_RODPERIODICOS"	, 005)

			oPanelTrb := oLayer:getLinePanel("BOX_TRABALHADOR")
			oPanelEvt := oLayer:getLinePanel("BOX_PERIODICOS")
			oRodEvts  := oLayer:getLinePanel("BOX_RODPERIODICOS")

			TafMonETrb(oPanelTrb,,aChecks,@nRegSelTrb,@nRegSelEvt,lTempTable,@oTabFilSel)
			oMarkPer := TafMonEPer(oPanelEvt,,aChecks,@nRegSelTrb,@nRegSelEvt,lTempTable,@oTabFilSel)
			TAFBrwRod(oRodEvts,'Eventos',.T.,.T.,.T.,.T.,oBttExpTb,oBttEdtTb,oBttExpTr,oBttExpSc,aChecks,@nRegSelTrb,@nRegSelEvt,oMBrwTabs,lTempTable,@oTabFilSel,oDlgMon)
			oMarkPer:oBrowse:GoColumn(1)
		EndIf
	Else
		If paramEtvPeriodicos .Or. paramEtvNaoPeriodicos

			oLayer:AddLine("BOX_EVENTOS",040)
			oLayer:AddLine("BOX_RODAPE_EVENTOS",005)

			If (paramVisao == 1)
				oLayer:addCollumn("COL_EVENTOS_PER", 050 ,.F.,"BOX_EVENTOS")
				oPanelEvt := oLayer:getColPanel("COL_EVENTOS_PER","BOX_EVENTOS")
				TafMonEPer(oPanelEvt,,aChecks,@nRegSelTrb,@nRegSelEvt,lTempTable,@oTabFilSel)

				oLayer:addCollumn("COL_EVENTOS_TRB", 050 ,.F.,"BOX_EVENTOS")
				oPanelTrb := oLayer:getColPanel("COL_EVENTOS_TRB","BOX_EVENTOS")
				TafMonETrb(oPanelTrb,,aChecks,@nRegSelTrb,@nRegSelEvt,lTempTable,@oTabFilSel)

				oLayer:addCollumn("COL_RODEVENTOS_PER"	, 100 ,.F.,"BOX_RODAPE_EVENTOS" )
				oRodEvts  := oLayer:getColPanel("COL_RODEVENTOS_PER","BOX_RODAPE_EVENTOS")
				TAFBrwRod(oRodEvts,'Eventos',.T.,.T.,.T.,.T.,oBttExpTb,oBttEdtTb,oBttExpTr,oBttExpSc,aChecks,@nRegSelTrb,@nRegSelEvt,oMBrwTabs,lTempTable,@oTabFilSel,oDlgMon)

			Else
				oLayer:addCollumn("COL_EVENTOS_TRB", 050 ,.F.,"BOX_EVENTOS")
				oPanelTrb := oLayer:getColPanel("COL_EVENTOS_TRB","BOX_EVENTOS")
				TafMonETrb(oPanelTrb,,aChecks,@nRegSelTrb,@nRegSelEvt,lTempTable,@oTabFilSel)

				oLayer:addCollumn("COL_EVENTOS_PER", 050 ,.F.,"BOX_EVENTOS")
				oPanelEvt := oLayer:getColPanel("COL_EVENTOS_PER","BOX_EVENTOS")
				TafMonEPer(oPanelEvt,,aChecks,@nRegSelTrb,@nRegSelEvt,lTempTable,@oTabFilSel)

				oLayer:addCollumn("COL_RODEVENTOS_PER"	, 100 ,.F.,"BOX_RODAPE_EVENTOS" )
				oRodEvts  := oLayer:getColPanel("COL_RODEVENTOS_PER","BOX_RODAPE_EVENTOS")
				TAFBrwRod(oRodEvts,'Eventos',.T.,.T.,.T.,.T.,oBttExpTb,oBttEdtTb,oBttExpTr,oBttExpSc,aChecks,@nRegSelTrb,@nRegSelEvt,oMBrwTabs,lTempTable,@oTabFilSel,oDlgMon)
			EndIf
		EndIf
	EndIf

	If !Empty(oMarkPer)
		Activate MsDialog oDlgMon Centered On Init(oMarkPer:oBrowse:oBrowse:SetFocus(.T.))
	Else
		Activate MsDialog oDlgMon Centered
	EndIf

	If lBackPar
		FWMsgRun(,{||TafMontes(.F.)},'Par�metros de filtros','Carregando tela de par�metros')
		lBackPar := .F.
	EndIf

	IIf(oDlgMon <> Nil,FreeObj(oDlgMon),)

	FechaAlias()

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} FechaAlias
Fecha os Alias Utilizados na Fun��o FCriaMonit
@author brunno.costa
@since 19/08/2018
@version 1.0
@return ${Nil}
/*/
//--------------------------------------------------------------------

Static Function FechaAlias()

	If Select(cAliasTab) > 0
		(cAliasTab)->(DbCloseArea())
	EndIf

	If Select(cAliasEvt) > 0
		(cAliasEvt)->(DbCloseArea())
	EndIf

	If Select(cAliasTrb) > 0
		(cAliasTrb)->(DbCloseArea())
	EndIf

	If Select(cAliasTotEvt) > 0
		(cAliasTotEvt)->(DbCloseArea())
	EndIf

	If Select(cAliasRetTss) > 0
		(cAliasRetTss)->(DbCloseArea())
	EndIf

	If Select(cAlsCodTab) > 0
		(cAlsCodTab)->(DbCloseArea())
	EndIf

	If Select(cAliasMark) > 0
		(cAliasMark)->(DbCloseArea())
	EndIf

Return

Function FTableTSSErr()

	Local aStru := {}

	If Select(cAliasRetTss) == 0

		aAdd(aStru,{ "FILIAL"  		, "C",  FWSizeFilial(), 0})
		aAdd(aStru,{ "ID"  			, "C",  036, 0})
		aAdd(aStru,{ "EVENTO"  		, "C",  006, 0})
		aAdd(aStru,{ "DETSTATUS"    , "C",  250, 0})
		aAdd(aStru,{ "DSCRECEITA"   , "C",  250, 0})
		aAdd(aStru,{ "RECIBO"		, "C",  044, 0})
		aAdd(aStru,{ "HISTPROC"  	, "C",  Iif( lInformix .Or. lPostgre, 250, 500 ), 0})
		aAdd(aStru,{ "XMLERRORET"   , "C",  Iif( lInformix .Or. lPostgre, 250, 2000 ), 0})
		aAdd(aStru,{ "CODRECEITA" 	, "C",  003, 0})
		aAdd(aStru,{ "STATUS" 		, "C",  001, 0})


		cArqREtTss := FWTemporaryTable():New(cAliasRetTss)
		cArqREtTss:SetFields(aStru)
		cArqREtTss:AddIndex("I1",{"FILIAL","ID","EVENTO"})
		cArqREtTss:Create()

	EndIf

Return

Function FCountStatus(cIdTrab, oTabFilSel)

	Local aStru 		:= {}
	Local cSql 			:= ""
	Local cSqlInsert 	:= ""
	Local nX 			:= 0
	Local nI 			:= 0
	Local nTotal 		:= 0
	Local cAliasLay 	:= ""
	Local cLayout   	:= ""
	Local cDescEvt  	:= ""
	Local cTipoEvt  	:= ""
	Local cCmpData  	:= ""
	Local cRelacTrb 	:= ""
	Local cSqlCollumn 	:= ""
	Local cSqlValues 	:= ""
	Local cIndApu		:= ""

	aAdd(aStru,{ "EVENTO"   , "C",  006, 0})
	aAdd(aStru,{ "BRANCO"   , "N",  009, 0})
	aAdd(aStru,{ "ZERO"		, "N",  009, 0})
	aAdd(aStru,{ "UM"  		, "N",  009, 0})
	aAdd(aStru,{ "DOIS"  	, "N",  009, 0})
	aAdd(aStru,{ "TRES" 	, "N",  009, 0})
	aAdd(aStru,{ "QUATRO" 	, "N",  009, 0})
	aAdd(aStru,{ "SEIS" 	, "N",  009, 0})
	aAdd(aStru,{ "SETE" 	, "N",  009, 0})
	aAdd(aStru,{ "TOTAL" 	, "N",  009, 0})

	cArqCountEvt := FWTemporaryTable():New(cAliasTotEvt)
	cArqCountEvt:SetFields(aStru)
	cArqCountEvt:AddIndex("I1",{"EVENTO"})
	cArqCountEvt:Create()

	For nX := 1 To Len(aEventosParm)
		If aEventosParm[nX][2]
			For nI := 1 To Len(aEventosParm[nX][1])

				If aEventosParm[nX][2]

					cAliasLay := aEventosParm[nX][1][nI][1] //Alias do Evento
					cLayout   := aEventosParm[nX][1][nI][2] //Layout
					cDescEvt  := aEventosParm[nX][1][nI][3] //Descri��o do evento
					cTipoEvt  := aEventosParm[nX][1][nI][8] //Tipo do Evento
					cCmpData  := aEventosParm[nX][1][nI][7] //Campo que determina o periodo ou data do evento
					cRelacTrb := aEventosParm[nX][1][nI][11] //Define se o evento tem rela��o com o Trabalhador

					cSql := " SELECT CASE "
					cSql += " WHEN " + cAliasLay + "_STATUS = ' ' THEN 'BRANCO' "
					cSql += " WHEN " + cAliasLay + "_STATUS = '0' THEN 'ZERO' "
					cSql += " WHEN " + cAliasLay + "_STATUS = '1' THEN 'UM' "
					cSql += " WHEN " + cAliasLay + "_STATUS = '2' THEN 'DOIS' "
					cSql += " WHEN " + cAliasLay + "_STATUS = '3' THEN 'TRES' "
					cSql += " WHEN " + cAliasLay + "_STATUS = '4' THEN 'QUATRO' "
					cSql += " WHEN " + cAliasLay + "_STATUS = '6' THEN 'SEIS' "
					cSql += " WHEN " + cAliasLay + "_STATUS = '7' THEN 'SETE' "
					cSql += "   END XSTATUS "
					cSql += " , COUNT(*) QTD "
					cSql += " FROM " + RetSqlName(cAliasLay) + " " + cAliasLay + " "

					//---------------------------------------------------------------------------
					// No caso da C9V, � nessario filtrar quando for S2200 ou S2300 (CUP OU CUU)
					//---------------------------------------------------------------------------
					If cAliasLay == "C9V"

						If AllTrim( cLayout ) == "S-2200"

							cSql += " INNER JOIN " + RetSqlName("CUP") + " CUP ON "
							cSql += " C9V.C9V_FILIAL = CUP.CUP_FILIAL "
							cSql += " AND C9V.C9V_ID = CUP.CUP_ID "
							cSql += " AND C9V.C9V_VERSAO = CUP.CUP_VERSAO "
							cSql += " AND CUP.D_E_L_E_T_ = ' ' "

						ElseIf AllTrim( cLayout ) == "S-2300"

							cSql += " LEFT OUTER JOIN " + RetSqlName("CUU") + " CUU ON "
							cSql += " C9V.C9V_FILIAL = CUU.CUU_FILIAL "
							cSql += " AND C9V.C9V_ID = CUU.CUU_ID "
							cSql += " AND C9V.C9V_VERSAO = CUU.CUU_VERSAO "
							cSql += " AND CUU.D_E_L_E_T_ = ' ' "

						EndIf

					EndIf

					If TafColumnPos( cAliasLay + "_STASEC" )
						cSql += " WHERE " + "(" + cAliasLay + "." + cAliasLay + "_ATIVO = '1' OR " + cAliasLay + "." + cAliasLay + "_STASEC = 'E' )"
					Else
						cSql += " WHERE " + cAliasLay + "." + cAliasLay + "_ATIVO = '1' "
					EndIf

					//Os Eventos que n�o s�o os de tabela usam o S-3000 por isso eu desconsidero os Excluidos
					If cTipoEvt != EVENTOS_INICIAIS[2]
						cSql += " AND " + cAliasLay + "_EVENTO <> 'E'
					EndIf

					If cAliasLay == "C9V" 
						If AllTrim( cLayout ) == "S-2200" 
							cSql += TafMonPVinc()
						ElseIf AllTrim( cLayout ) == "S-2300"
							cSql +=  TafMonPSVinc()
						EndIf
					EndIf 

					If cAliasLay == "CM6"
						cSql += " AND ( "
						cSql += TafMonPAfast()
						cSql += " ) "
					EndIf				

					cSql += " AND " + cAliasLay + ".D_E_L_E_T_ <> '*' "

					//---------------------------------------------------------------------------
					// No caso da C9V, � nessario filtrar quando for S2200 ou S2300 (CUP OU CUU)
					//---------------------------------------------------------------------------
					If cAliasLay == "C9V"
						If AllTrim( cLayout ) == "S-2200"
							cSql += " AND " + cAliasLay + "." + cAliasLay + "_NOMEVE = 'S2200' "
						ElseIf AllTrim( cLayout ) == "S-2300"
							cSql += " AND " + cAliasLay + "." + cAliasLay + "_NOMEVE = 'S2300' "
						EndIf
					EndIf

					//--------------------------------------------------------------
					// No caso da C91, � nessario filtrar quando for S1200 ou S1202
					//--------------------------------------------------------------
					If cAliasLay == "C91"
						If AllTrim( cLayout ) == "S-1200"
							cSql += " AND " + cAliasLay + "." + cAliasLay + "_NOMEVE = 'S1200' "
						ElseIf AllTrim( cLayout ) == "S-1202"
							cSql += " AND " + cAliasLay + "." + cAliasLay + "_NOMEVE = 'S1202' "
						EndIf
					EndIf

					// Realiza trava para eventos S-1200 e S-1210 para apenas visualiza��o de aut�nomos.
					If lLockAuton
						If cAliasLay == "C91"
							cSql += " AND C91_TRABEV= 'TAUTO' "
						EndIf

						If cAliasLay == "T3P"
							cSql += " AND T3P_TRABEV= 'TAUTO' "
						EndIf
					EndIf

					//para C1E devo olhar para o campo _FILTAF ao inv�s de _FILIAL
					If cAliasLay == "C1E"
						cSql += " AND " + cAliasLay + "." + cAliasLay + "_FILTAF IN ( "
					Else
						cSql += " AND " + cAliasLay + "." + cAliasLay + "_FILIAL IN ( "
					Endif
					cSql += TafMonPFil(cAliasLay,@oTabFilSel)
					cSql += ") "

					If AllTrim( cLayout ) $ "S-1070"
						cSql += "  AND " + cAliasLay + "." + cAliasLay + "_ESOCIA = '1' "
					EndIf

					If cTipoEvt == EVENTOS_MENSAIS[2] .Or. cAliasLay = "CMJ"
					
						If lLaySimplif

							cIndApu := Space(GetSx3Cache(cAliasLay + "_INDAPU", "X3_TAMANHO"))

						EndIf

						cSql += " AND ( "
						
						If !lLaySimplif

							cSql += " (" + cAliasLay + "_INDAPU = '1' "

						Else

							cSql += " ((" + cAliasLay + "_INDAPU = '1' "
							cSql += " OR " + cAliasLay + "_INDAPU = '" + cIndApu + "') "

						EndIf

						cSql += " AND " + cAliasLay + "." + cCmpData + " >= '" + AnoMes(paramDataInicial) + "'"
						cSql += " AND " + cAliasLay + "." + cCmpData + " <= '" + AnoMes(paramDataFim) + "')"

						If !lLaySimplif

							cSql += " OR (" + cAliasLay + "_INDAPU = '2' "

						Else

							cSql += " OR ((" + cAliasLay + "_INDAPU = '2' "
							cSql += " OR " + cAliasLay + "_INDAPU = '" + cIndApu + "') "

						EndIf

						cSql += " AND " + cAliasLay + "." + cCmpData +  " BETWEEN '" + AllTrim(Str(Year(paramDataInicial))) + "' AND '" + AllTrim(Str(Year(paramDataFim))) + "')"
						cSql += " OR (" + cAliasLay + "_INDAPU = '" + cIndApu + "' "
						cSql += " AND " + cAliasLay + "." + cCmpData + " = ' ' AND '" + cAliasLay + "' = 'CMJ')" //Gera o evento 3000 quando nao for mensal.
						cSql += ")"
					ElseIf cTipoEvt == EVENTOS_EVENTUAIS[2] .And. !Empty(AllTrim(cCmpData)) .And. cAliasLay != "CMJ"
						cSql += " AND " + cAliasLay + "." + cCmpData + " >= '" + DtoS(paramDataInicial) + "'"
						cSql += " AND " + cAliasLay + "." + cCmpData + " <= '" + DtoS(paramDataFim) + "'"
					EndIf
					//S� pego o registro da Matriz
					If cAliasLay == "C1E"
						cSql += " AND C1E_MATRIZ = 'T' "
					EndIf

					cSql += "GROUP BY " + cAliasLay + "." + cAliasLay + "_STATUS "

				EndIf

				TCQuery cSql New Alias "AliasTot"


				While AliasTot->(!Eof())

					If Empty(cSqlCollumn)
						cSqlCollumn += "(EVENTO,"
						cSqlValues += " VALUES('" + cLayout + "',"
					EndIf

					cSqlCollumn += AllTrim(AliasTot->XSTATUS) + ","
					cSqlValues += cValToChar(AliasTot->QTD) + ","
					nTotal += AliasTot->QTD

					AliasTot->(dBSkip())
				EndDo

				If !Empty(cSqlCollumn)
					cSqlCollumn += "TOTAL)"
					cSqlValues += cValToChar(nTotal)  + ")"

					cSqlInsert := "INSERT INTO " + cArqCountEvt:GetRealName()
					cSqlInsert += " "
					cSqlInsert += cSqlCollumn
					cSqlInsert += " "
					cSqlInsert += cSqlValues

					If TCSQLExec (cSqlInsert) < 0
						MsgInfo (TCSQLError(),"Inclus�o de Totalizadores dos Eventos.")
					EndIf

				EndIf


				cSqlInsert  := ""
				cSqlValues  := ""
				cSqlCollumn := ""
				nTotal := 0

				AliasTot->(DBCloseArea())

			Next nI
		EndIf
	Next nX

Return Nil



//--------------------------------------------------------------------
/*/{Protheus.doc} TAFBrwRod
Cria painel com os bot�es para transmiss�o,exporta��o e edi��o dos registros
@author evandro.oliveira
@since 26/02/2016
@version 1.0
@param oPanel, objeto, (Objeto no qual os elemento devem ser criados)
@param cIDBrowse, character, (Id do Browse que os bot�es ser�o relacionados)
@param lBtnTrans, logico, (Indica que deve ser criado o bot�o de Transmiss�o)
@param lBtnExp, logico, (Indica que deve ser criado o bot�o de Exporta��o)
@param lBtnEdt, logico, (Indica que deve ser ciado o bot�o de Edi��o)
@param lBtnSch, logico, (Indica que deve ser ciado o bot�o de Valida Schema)
@param aChecks, array, (Contem informa��es dos status selecionados na tela de par�metros)
@param 	nRegSelTrb, numerico, Contador de Registros selecionados no browse trabalhador
@param 	nRegSelEvt, numerico, Contador de Registros selecionados no browse eventos
@param oMBrwTabs, objeto, (Browse dos Eventos de Tabelas)
@param lTempTable - Indica que o arquivo de trabalho foi criado no banco
@param oTabFilSel - Recebido como referencia, guarda as filiais selecionadas por tabelas de evento
@return ${nil}
/*/
//--------------------------------------------------------------------
Function TAFBrwRod( oPanel, cIDBrowse, lBtnExp, lBtnTrans, lBtnEdt, lBtnSch, oBtnExp, oBtnTrans, oBtnEdt, oBtnSche, aChecks, nRegSelTrb, nRegSelEvt, oMBrwTabs, lTempTable, oTabFilSel, oDlgMon )

Local oPanLeg		:=	Nil
Local cTafAmbE		:=	GetNewPar( "MV_TAFAMBE", "3" )
Local nLargura		:=	001
Local lTrans2230	:=	GetNewPar( "MV_TAF2230", .F. )

Default lBtnTrans	:=	.T.
Default oBtnSche	:= Nil

oPanLeg := TPanel():New( 00, 00, "", oPanel,, .F., .F.,,, 10, 20, .F., .F. )
oPanLeg:Align := CONTROL_ALIGN_ALLCLIENT
oPanLeg:SetCSS( QLABEL_AZUL_C )

If lBtnTrans
	oBtnExp := TButton():New( 001, nLargura, STR0082, oPanLeg, { || FSelItens( cIDBrowse, "EX", aChecks, @nRegSelTrb, @nRegSelEvt, oMBrwTabs, lTempTable, @oTabFilSel, lTrans2230 ) }, 75, 10,,, .F., .T., .F.,, .F.,,, .F. ) //"Exportar XMLs"
	oBtnExp:SetCSS( BTNLINK )
	nLargura += 100
EndIf

If lBtnExp
	oBtnTrans := TButton():New( 001, nLargura, STR0083, oPanLeg, { || FSelItens( cIDBrowse, "TG", aChecks, @nRegSelTrb, @nRegSelEvt, oMBrwTabs, lTempTable, @oTabFilSel, lTrans2230 ) }, 75, 10,,, .F., .T., .F.,, .F.,,, .F. ) //"Transmitir ao Governo"
	oBtnTrans:SetCSS( BTNLINK )
	nLargura += 100
EndIf

If lTrans2230 .and. cIDBrowse == "Eventos"
	oBtn2230 := TButton():New( 001, nLargura, "Transmiss�o S-2230", oPanLeg, { || Transm2230( oDlgMon, @oTabFilSel ) }, 75, 10,,, .F., .T., .F.,, .F.,,, .F. )
	oBtn2230:SetCSS( BTNLINK )
EndIf

If lBtnEdt
	If cIDBrowse == "Eventos"
		nLargura := oPanLeg:NCLIENTWIDTH * 0.43
	EndIf

	oBtnEdt := TButton():New( 001, nLargura, "Detalhamento", oPanLeg, { || FSelItens( cIDBrowse, "EM", aChecks, @nRegSelTrb, @nRegSelEvt, oMBrwTabs, lTempTable, @oTabFilSel, lTrans2230 ) }, 75, 10,,, .F., .T., .F.,, .F.,,, .F. ) //"Editar Movimenta��o"
	oBtnEdt:SetCSS( BTNLINK )
	nLargura += 100
EndIf

If cIDBrowse == "Tabelas" .and. cTafAmbE == "2"
	oBtnSche := TButton():New( 001, nLargura, STR0230, oPanLeg, { || TafLimpEmp(  ) }, 150, 10,,, .F., .T., .F.,, .F.,,, .F. ) //"Remover empregador da base de dados"
	oBtnSche:SetCSS( BTNLINK )
	nLargura += 100
EndIf

Return()

//--------------------------------------------------------------------
/*/{Protheus.doc} TAFBrwPar
Cria Painel com o bot�o da Tela de Par�metros
@author evandro.oliveira
@since 29/02/2016
@version 1.0

@param oPanel, objeto, (Objeto no qual os elemento devem ser criados)
@param oDlgMon, objeto, Dialog principal
@param lBackPar, logico, Informa se a chamada originou do bot�o de retorno para tela de par�metros
@param cIDBrowse, character, (Id do Browse que os bot�es ser�o relacionados)
@param aChecks, array, (Contem informa��es dos status selecionados na tela de par�metros)
@param 	nRegSelTrb, numerico, Contador de Registros selecionados no browse trabalhador
@param 	nRegSelEvt, numerico, Contador de Registros selecionados no browse eventos
@param oMBrwTabs, objeto, (Browse dos Eventos de Tabelas)
@param lTempTable - Indica que o arquivo de trabalho foi criado no banco
@param oTabFilSel - Recebido como referencia, guarda as filiais selecionadas por tabelas de evento
@return ${Nil}
/*/
//--------------------------------------------------------------------
Function TAFBrwPar(oPanel,oDlgMon,lBackPar,aChecks,nRegSelTrb,nRegSelEvt,oMBrwTabs,lTempTable,oTabFilSel)

	Local nHeight	:= 0
	Local cTamFont1	:= ""
	Local cTamFont2	:= ""
	Local cMsgLegd	:= ""
	Local lHTML		:= Iif(lFindClass,FWCSSTools():GetInterfaceCSSType() == 5 .Or. (GetRemoteType() == REMOTE_HTML),.F.)

	If lHTML
		cTamFont1 := '2'
		cTamFont2 := '1'
	Else
		cTamFont1 := '3'
		cTamFont2 := '2'
	EndIf

	oPanPar  := TPanel():New(00,00,"",oPanel,,.F.,.F.,,,020,012,.F.,.F.)
	oPanPar:Align := CONTROL_ALIGN_ALLCLIENT
	oPanPar:setCSS( "QLabel{background-color:#D6E4EA}" )

	cCss := "QPushButton{border-radius: 3px;border: 1px solid #000000; background-color: #F0F0F0;  }"

	nHeight := oPanPar:NCLIENTHEIGHT * 0.090

	oBttPar := TButton():New(nHeight, oPanPar:NCLIENTWIDTH * 0.355, STR0099,oPanel,{||oDlgMon:End(),lBackPar := .T.}, 67,16,,,.F.,.T.,.F.,,.F.,,,.F. ) //Par�metros de Filtro
	

	oBttRef := TButton():New(nHeight, oPanPar:NCLIENTWIDTH * 0.41,"Atualizar Informa��es",oPanel,;
	{||;
	FWMsgRun(,{|oMsgRun|atualizaInformacoes(oMsgRun,aChecks,@nRegSelTrb,@nRegSelEvt,@oMBrwTabs,lTempTable,@oTabFilSel)},"Rotina de Ajuste de Status Autorizado","Realizando Processamento ...");
	}, 67,16,,,.F.,.T.,.F.,,.F.,,,.F. ) //Atualizar Informa��es

	

	oBttSair := TButton():New(nHeight, oPanPar:NCLIENTWIDTH * 0.47, STR0106,oPanel,{||oDlgMon:End()}, 42,16,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Sair"
	

	cMsgLegd += '<b><font size="' + cTamFont1 + '" color="#848484">'+ STR0102 + '</font></b> - <font size="' + cTamFont2 + '" color="#000000"> '+ STR0104 + '</font><br>' //Com Pend�ncia#Alguma pend�ncia de algum evento existe para este trabalhador, ou at� mesmo a inexist�ncia de qualquer um deles.
	cMsgLegd += '<b><font size="' + cTamFont1 + '" color="#848484">'+ STR0103 + '</font></b> - <font size="' + cTamFont2 + '" color="#000000">' + STR0105 + '</font>' //Sem Pend�ncia#Trabalhador com eventos transmitidos e validados pelo Governo.
	oSayLeg 	:= TSay():New(nHeight,005,{||cMsgLegd},oPanPar,,,,,,.T.,,,oPanPar:NCLIENTWIDTH * 0.30,050,,,,,,.T.)

	If lHTML
		oSayLeg:LTRANSPARENT := .T.
	EndIf
	
	If (GetRemoteType() == REMOTE_HTML)
		oSayLeg:setCSS( "QLabel{background-color:#D6E4EA}" )
	EndIf

	If !lHTML
		oBttPar:SetCSS(setCssButton("11","#FFFFFF","#3C7799","#191970"))
		oBttRef:SetCSS(setCssButton("11","#FFFFFF","#3C7799","#191970"))
		oBttSair:SetCSS(setCssButton("11","#FFFFFF","#808080","#696969"))
	EndIf

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} atualizaInformacoes
Atualiza as informa��es dos browses
@author evandro.oliveira
@since 18/03/2019
@version 1.0

@param oMsgRun, objeto, Objeto FWMsgRun
@param aChecks, array, (Contem informa��es dos status selecionados na tela de par�metros)
@param 	nRegSelTrb, numerico, Contador de Registros selecionados no browse trabalhador
@param 	nRegSelEvt, numerico, Contador de Registros selecionados no browse eventos
@param oMBrwTabs, objeto, (Browse dos Eventos de Tabelas)
@param lTempTable - Indica que o arquivo de trabalho foi criado no banco
@param oTabFilSel - Recebido como referencia, guarda as filiais selecionadas por tabelas de evento

@return ${Nil}
/*/
//--------------------------------------------------------------------
Static Function atualizaInformacoes(oMsgRun,aChecks,nRegSelTrb,nRegSelEvt,oMBrwTabs,lTempTable,oTabFilSel)

	If paramEtvTabelas
		IncMessagens(oMsgRun,"Atualizando Grid Tabelas/Sem Rela��o com o Trabalhador")
		TafMonETab(,.T.,aChecks,@oMBrwTabs,lTempTable,@oTabFilSel)
	EndIf 

	//Mesmo quando somente 1 dos par�metros est� marcado na tela sempre � criado os 2 browses, por este motivo temos sempre que atualizar os 2.
	If paramEtvPeriodicos .Or. paramEtvNaoPeriodicos
		IncMessagens(oMsgRun,"Atualizando Grid Eventos Peri�dicos/N�o Peri�dicos")
		TafMonEPer(,.T.,aChecks,@nRegSelTrb,@nRegSelEvt,lTempTable,@oTabFilSel)

		IncMessagens(oMsgRun,"Atualizando Grid do Trabalhador")
		TafMonETrb(,.T.,aChecks,@nRegSelTrb,@nRegSelEvt,lTempTable,@oTabFilSel)
	EndIf 

Return Nil 

//--------------------------------------------------------------------
/*/{Protheus.doc} atualizaInformacoes

Cria objeto TButton utilizando CSS

@author evandro.oliveira
@since 18/03/2019
@version 1.0

@param cTamFonte - Tamanho da Fonte
@param cFontColor - Cor da Fonte
@param cBackColor - Cor de Fundo do Bot�o
@param cBorderColor - Cor da Borda

@return ${Nil}
/*/
//--------------------------------------------------------------------
Static Function setCssButton(cTamFonte,cFontColor,cBackColor,cBorderColor)

	Local cCSS := ""

	cCSS := "QPushButton{ background-color: " + cBackColor + "; "
	cCSS += "border: none; "
	cCSS += "font: bold; "
	cCSS += "color: " + cFontColor + ";" 
	cCSS += "padding: 2px 5px;" 
	cCSS += "text-align: center; "
	cCSS += "text-decoration: none; "
	cCSS += "display: inline-block; "
	cCSS += "font-size: " + cTamFonte + "px; "
	cCSS += "border: 1px solid " + cBorderColor + "; "
	cCSS += "border-radius: 3px "
	cCSS += "}"

Return cCSS

//--------------------------------------------------------------------
/*/{Protheus.doc} TAFBrwAmb
Painel com a Indentifica��o do Ambiente
@author evandro.oliveira
@since 29/02/2016
@version 1.0
@param oPanel, objeto, (Objeto no qual a legenda deve ser criada)
@param oDlgMon,objeto, (Parent)
@return ${Nil}
/*/
//--------------------------------------------------------------------
Function TAFBrwAmb(oPanel,oDlgMon)

	Local cMsgAmb		:= ""
	Local cMsgFim		:= ""
	Local cAmbEsocial	:= GetNewPar( "MV_TAFAMBE", "2" )
	Local cNmAmb		:= ""
	Local cTamFont1		:= ""
	Local cTamFont2		:= ""

	If lFindClass .And. ( (GetRemoteType() == REMOTE_HTML) .or. (FWCSSTools():GetInterfaceCSSType() == 5) )
		cTamFont1 := '1'
		cTamFont2 := '2'
	Else
		cTamFont1 := '2'
		cTamFont2 := '3'
	EndIf

	//Verifica qual tipo de ambiente foi configurado
	//pela wizard de configura��o do esocial
	If cAmbEsocial == "1"
		cNmAmb := STR0171 //Produ��o
	ElseIf cAmbEsocial == "2"
		cNmAmb := STR0172 //Pr�-produ��o - dados reais
	Else
		cNmAmb := STR0173 //Pr�-produ��o - dados fict�cios
	EndIf

	oPanLgTop  := TPanel():New(00,00,"",oPanel,,.F.,.F.,,,005,020,.F.,.F.)
	oPanLgTop:Align := CONTROL_ALIGN_ALLCLIENT

	cMsgAmb := '<font size="' + cTamFont1 + '" color="RED">'
	cMsgAmb +=  STR0170 + '</font>'
	cMsgAmb += '<b><font size="' + cTamFont2 + '" color="RED">' + cNmAmb + '</font></b>' //Ambiente do eSocial configurado para transmiss�o de Eventos
	cMsgAmb += '</font>'

	oSayAmb := TSay():New(001,005,{||cMsgAmb},oPanLgTop,,,,,,.T.,,,oPanLgTop:NCLIENTWIDTH * 0.49,030,,,,,,.T.)

	cMsgFim := '<font size="' + cTamFont2 + '" color="RED">'
	cMsgFim += STR0278 + ' <b>' + DtoC(dDataLim) + '</b>, ' +  STR0282 + ' <b>' + STR0283 + '</b>.' // "A partir do dia" / "todas as transmiss�es de eventos do e-Social, dever�o ser realizadas atrav�s do novo" / "Painel e-Social"
	cMsgFim += '</font>'

	oSayFim := TSay():New(008,005,{||cMsgFim},oPanLgTop,,,,,,.T.,,,oPanLgTop:NCLIENTWIDTH * 0.49,030,,,,,,.T.)

Return Nil
//--------------------------------------------------------------------
/*/{Protheus.doc} FOnMove
Valida a mudan�a de linha do TGrid
@author evandro.oliveira
@since 16/03/2016
@version 1.0
@param o, objeto, (instancia do objeto TGrid)
@param nMvType, num�rico, (indica o tipo de movimento)
@param nCurPos, num�rico, (indica a posi��o visual da linha selecionada)
@param nOffSet, num�rico, (Indica a diferen�a de linhas, entre a posi��o
inicial e final)
@param nVisRows, num�rico, (Indica o numero de linha visiveis na grade
no momento da movimenta��o)
@param nCursorPos, num�rico, (Variavel de controle do cursor no momento
movimenta��o)
@param nRecno, num�rico, (Numero da linha selecionada)
@param aRowsGer, array, (Array com o conteudo da Grid)
@param nLenData, num�rico, (Numero de linhas da Grid)
@return ${Nil}
/*/
//--------------------------------------------------------------------
Static Function FOnMove(o,nMvType,nCurPos,nOffSet,nVisRows,nCursorPos,nRecno,aRowsGer,nLenData)

	//Evita erro de posicionamento quando executado pela primeira vez
	if nCurPos == -1
		nOffSet -= 1
	endif

	If nMvType == GRID_MOVEUP
	    FMvGoUp(nOffSet,o,@nCursorPos,@nRecno,aRowsGer)
	Elseif nMvType == GRID_MOVEDOWN
	    FMvGoDown(nOffSet,o,@nCursorPos,@nRecno,aRowsGer,@nLenData)
/*	ElseIf nMvType == GRID_MOVEPAGEDOWN
		FMvGoEnd(nOffSet,o,@nCursorPos,@nRecno,aRowsGer,@nLenData)*/
	Endif

Return Nil
//--------------------------------------------------------------------
/*/{Protheus.doc} FMvGoUp
Movimenta uma linha do TGrid para cima.
@author evandro.oliveira
@since 16/03/2016
@version 1.0
@param nOffSet, num�rico, (Indica a diferen�a de linhas, entre a posi��o
inicial e final)
@param o, objeto, (instancia do objeto TGrid)
@param nCursorPos, num�rico, (Variavel de controle do cursor no momento
movimenta��o)
@param nRecno, num�rico, (Numero da linha selecionada)
@param aRowsGer, array, (Array com o conteudo da Grid)
@return ${Nil}
/*/
//--------------------------------------------------------------------
Static Function FMvGoUp(nOffSet,oGrid,nCursorPos,nRecno,aRowsGer)
Local lAdjustCursor := .F.

    If nRecNo==1
        Return
    Endif

    If nCursorPos==0
        oGrid:scrollLine(-1)
        lAdjustCursor:= .T.
    Else
        nCursorPos -= nOffSet
    Endif
    nRecno -= nOffSet

    // atualiza linha corrente
    oGrid:setRowData(nCursorPos, {|o| {aRowsGer[nRecno,1],aRowsGer[nRecno,2],aRowsGer[nRecno,3],aRowsGer[nRecno,4],aRowsGer[nRecno,5],aRowsGer[nRecno,6],aRowsGer[nRecno,7] } } )

    If lAdjustCursor
        nCursorPos:= 0
    Endif
    oGrid:setSelectedRow(nCursorPos)

Return Nil
//--------------------------------------------------------------------
/*/{Protheus.doc} FMvGoDown
Movimenta uma linha do TGrid para baixo.
@author evandro.oliveira
@since 16/03/2016
@version 1.0
@param nOffSet, num�rico, (Indica a diferen�a de linhas, entre a posi��o
inicial e final)
@param o, objeto, (instancia do objeto TGrid)
@param nCursorPos, num�rico, (Variavel de controle do cursor no momento
movimenta��o)
@param nRecno, num�rico, (Numero da linha selecionada)
@param aRowsGer, array, (Array com o conteudo da Grid)
@param nLenData, num�rico, (Numero de linha do TGrid)
@return ${Nil}
/*/
//--------------------------------------------------------------------
Static Function FMvGoDown(nOffSet,oGrid,nCursorPos,nRecno,aRowsGer,nLenData)
Local lAdjustCursor	:= .F.
Local nVisRows		:= oGrid:getVisibleRows()

	If nRecno==nLenData
	    Return Nil
	EndIf

	If nCursorPos== nVisRows-1
	    oGrid:scrollLine(1)
	    lAdjustCursor:= .T.
	Else
	    nCursorPos += nOffSet
	EndIf
	nRecno += nOffSet

	// atualiza linha corrente
	 oGrid:setRowData(nCursorPos, {|o| {aRowsGer[nRecno,1],aRowsGer[nRecno,2],aRowsGer[nRecno,3],aRowsGer[nRecno,4],aRowsGer[nRecno,5],aRowsGer[nRecno,6],aRowsGer[nRecno,7] } } )
	If lAdjustCursor
	    nCursorPos:= nVisRows-1
	EndIf
	oGrid:setSelectedRow(nCursorPos)

Return Nil
//--------------------------------------------------------------------
Static Function FMvGoEnd(nOffSet,oGrid,nCursorPos,nRecno,aRowsGer,nLenData)
Local nVisRows := oGrid:getVisibleRows()

	If nRecno==nLenData
	    Return Nil
	EndIf

    nRecno := nLenData
    oGrid:ClearRows()
    ShowData(nRecno - nVisRows + 1, nVisRows,nLenData,oGrid)
    nCursorPos := nVisRows-1
    oGrid:setSelectedRow(nCursorPos)
Return Nil
//--------------------------------------------------------------------
/*/{Protheus.doc} ShowData
Cria uma nova linha no TGrid
@author evandro.oliveira
@since 16/03/2016
@version 1.0
@param nFirstRec, num�rico, (linha q deve come�ar a inclus�o)
@param nCount, num�rico, (quantidade de linhas a serem criadas)
@param nLenData, num�rico, (total de linhas do Grid)
@param oGrid, objeto, (instancia do objeto TGrid)
@return ${Nil}
/*/
//--------------------------------------------------------------------
Static Function ShowData( nFirstRec, nCount,nLenData,oGrid )
Local nX		:= 0
Local nRec		:= 0
Local nY		:= 0
Local bLinha	:= {||}

Default nCount	:= 30


    For nX:=0 to nCount-1
        nRec:= nFirstRec+nX
        If nRec > nLenData
            Return Nil
        EndIf
        nY:= Str( nRec )
        bLinha:= "{|o| { Self:aData["+nY+",1], Self:aData["+nY+",2], Self:aData["+nY+",3], Self:aData["+nY+",4], Self:aData["+nY+",5], Self:aData["+nY+",6], Self:aData["+nY+",7] } }"
        oGrid:setRowData( nX, &bLinha )
    Next i

Return Nil
//--------------------------------------------------------------------
/*/{Protheus.doc} FSalvProf
Grava os Par�mentros em um arquivo de profile
@author evandro.oliveira
@since 07/04/2016
@version 1.0
@return ${boolean}, ${A fun��o MemoWrite Retorna True ou False}
/*/
//--------------------------------------------------------------------
Static Function FSalvProf ()
 
Local  cWrite		:= ""
Local  cBarra		:= If ( IsSrvUnix () , "/" , "\" )
Local  cUserName	:= __cUserID
Local  cNomeProf	:= ""

// --> Gera a string em formato JSON
cWrite := FwJsonSerialize(aParamES)

cNomeProf	:=	FunName() +"_" +cUserName

Return (MemoWrite ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeProf ) + ".PRB" , cWrite ))
//--------------------------------------------------------------------
/*/{Protheus.doc} FConvType
Verifica o Tipo de dado do par�metro e o retorna
em uma String.
@author evandro.oliveira
@since 07/04/2016
@version 1.0
@param cPar, character, (Valor do Par�metro)
@return ${string}, ${string com o tipo de dado}
/*/
//--------------------------------------------------------------------
Static Function FConvType(cPar)
	Local cString	:= ""
	Local nX		:= 0
	Local nY		:= 0

	If ValType(cPar) == "L"
		cString := IIf(cPar,'.T.','.F.')
	ElseIf ValType(cPar) == "D"
		cString := "'" + DTOC(cPar)	+ "'"
	ElseIf ValType(cPar) == "N"
		cString := AllTrim(Str(cPar))
	ElseIf ValType(cPar) == "C"
		cString := cPar
	ElseIf ValType(cPar) == "A"
		cString += "'["
		For nX := 1 to Len(cPar)
			cString += "["
			For	nY := 1 to Len(cPar[nX])
				If ValType(cPar[nX][nY]) == "L"
					If Len(cPar[nX]) = nY
						cString += IIf(cPar[nX][nY],'true','false')
					Else
						cString += IIf(cPar[nX][nY],'true','false') + ","
					EndIf
				Else
					If Len(cPar[nX]) = nY
						cString +=  '|' + AllTrim(cPar[nX][nY])+ '|'
					Else
						cString +=  '|' + AllTrim(cPar[nX][nY])+ '|' + ","
					EndIf
				EndIf

			Next

			If Len(cPar) = nX
				cString += "]]'"
			Else
				cString += "],"
			EndIf

		Next
	Else
		MsgInfo('Problemas na tentativa de gravar o profile dos par�metros.')
	EndIf

Return cString
//--------------------------------------------------------------------
/*/{Protheus.doc} FLoadProf
L� arquivo de profile e "alimenta" os par�metros
@author evandro.oliveira
@since 07/04/2016
@version 1.0
@return ${lRetorno}, ${Informa se a rotina foi executada com sucesso}
/*/
//--------------------------------------------------------------------
Static Function FLoadProf()
	Local nJ			:=	0
	Local cBarra		:= 	Iif ( IsSrvUnix() , "/" , "\" )
	Local cUserName		:= __cUserID
	Local cNomeProf		:= ""
	Local lRetorno		:= .F.
	Local cJsonProf		:= ""
	Local aObjProf		:= Nil
	Local cArquivo		:= ""

	Private cLinha		:= ""

	If !ExistDir ( cBarra + "PROFILE" + cBarra )
		Makedir ( cBarra + "PROFILE" + cBarra )
	EndIf

	cNomeProf	:=	FunName() +"_" +cUserName
	cArquivo := cBarra + "PROFILE" + cBarra + Alltrim ( cNomeProf ) + ".PRB"
	If File (cArquivo)

		If FT_FUse (cArquivo ) <> -1

			FT_FGoTop ()
			While ( !FT_FEof () )
				cLinha := FT_FReadLn ()
				cJsonProf += cLinha
				FT_FSkip ()
			Enddo
			If FT_FUse() != -1
				lRetorno := .T.
			EndIf

			// Deserializa a String JSON
			If FwJsonDeserialize(cJsonProf, @aObjProf)
				If Len(aObjProf) == Len(aParamES)
					For nJ := 1 To Len(aObjProf)
						If nJ <> 15 .And. nJ <> 14  //filiais e paramTAFKEY n�o devem ser reaproveit�veis
							aParamES[nJ] := aObjProf[nJ]
						EndIf
					Next nJ

					//Tratamento para converter a data de 2010/01/15 15:00:00:000 para 15/01/2010
					aParamES[12] := CTOD(DTOC(aParamES[12]))
					aParamES[13] := CTOD(DTOC(aParamES[13]))
				Else
					lRetorno := .F.
				EndIf
			Else
				//Apago o arquivo quando n�o est� de acordo para que na proxima execu��o
				//o sistema recrie corretamente evitando error.log.
				FErase(cArquivo,,.T.)
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
Return (lRetorno)
//--------------------------------------------------------------------
/*/{Protheus.doc} FSelItens
Verifica os itens com "Marca" para a edi��o ou transmiss�o dos mesmos.
@author evandro.oliveira
@since 26/02/2016
@version 1.0
@param cIdBrowse, 	character, (Identificador do Browse)
@param cIdBotao, 		character, (Identificador do bot�o que est� executando
@param aChecks, 		array, 		(Status selecionados nos par�metros)
@param nRegSelTrb, 	numerico, 	(Contador de Itens selecionados no browse trabalhador)
@param nRegSelEvt, 	numerico, 	(Contador de Itens selecionados no browse eventos)
@param oMBrwTabs, 	objeto, 	(Browse dos eventos de tabela)
@pram lTempTable, logico, Indica que o arquivo temporario foi criado no banco
a chamada da fun��o)
@param oTabFilSel - Recebido como referencia, guarda as filiais selecionadas por tabelas de evento
@param lTrans2230 - Indica se o par�metro MV_TAF2230 est� habilitado ( Limpeza dos Afastamentos )
@return ${Nil}
/*/
//--------------------------------------------------------------------
Static Function FSelItens(cIdBrowse,cIdBotao,aChecks,nRegSelTrb,nRegSelEvt,oMBrwTabs,lTempTable,oTabFilSel,lTrans2230, lMV, oMarkDet, oTempTable ) //--> Acrescentado lMV

Local nTop				:= 0
Local nLeft				:= 0
Local nBottom			:= 0
Local nRight			:= 0
Local nLin				:= 005
Local nCol				:= 0
Local nTamCol			:= 0
Local oSize				:= FwDefSize():New(.F.)
Local aSelStus			:= Array(Len(aChecks))
Local aRetEvts			:= {}
Local nX				:= 0
Local cMsgBtt			:= ""
Local cRadio1			:= "" //???
Local cRadio2			:= "" //???
Local lDetal			:= .F.
Local lOk				:= .F.
Local lVirgula			:= .F.
Local cStatus			:= ""
Local cRecNos			:= ""
Local lAtualiza			:= .T.
Local aEvtsSel			:= {}
Local aIdsSel			:= {}
Local cMsgRet			:= ""
Local lMultEvt			:= .F.
Local cMsgErr			:= ""
Local cMsgTit			:= ""
Local aInfoTrab			:= {}
Local oCBoxTodos		:= Nil
Local lSelTodos			:= .F.
Local lSemAcesso		:= .F.
Local cBarra			:= Iif(IsSrvUnix() , "/" , "\")
Local lElectron			:= IIf(lFindClass, (FWCSSTools():GetInterfaceCSSType() == 5), .F.)
Local lRemote			:= GetRemoteType() == REMOTE_HTML

DEFAULT cIdBrowse		:= ''
DEFAULT cIdBotao		:= ''
DEFAULT aChecks			:= {}
DEFAULT nRegSelTrb	:= 0
DEFAULT nRegSelEvt	:= 0
DEFAULT oMBrwTabs		:= NIL
Default lTrans2230	:=	.F.
Default lMV         := .F.
Default oMarkDet    := Nil 
Default oTempTable  := Nil


FVerChks(@lDetal,@cRecNos,@aEvtsSel,@aIdsSel,@lMultEvt,cIdBrowse,cIdBotao,@nRegSelTrb,@nRegSelEvt,oMBrwTabs, @aInfoTrab, lMV, oMarkDet, oTempTable )

If lTrans2230 .and. cIDBotao == "TG"
	If aScan( aEvtsSel, { |x| AllTrim( x[4] ) == "S-2230" } ) > 0
		MsgInfo( "Opera��o de transmiss�o do evento de afastamento ( S-2230 ) permitida apenas a partir do bot�o 'Transmiss�o S-2230' enquando o par�metro MV_TAF2230 estiver habilitado." )
		Return()
	EndIf
EndIf

If !lDetal
	
	If (nCountTrb > 0 .Or. nCountEvt > 0) .Or. (Len(aEvtsSel) > 0 .Or. Len(aIdsSel) > 0)

		nTop    := oSize:aWindSize[1] - (oSize:aWindSize[1] * 0.73)
		nLeft   := oSize:aWindSize[2] - (oSize:aWindSize[2] * 0.70)

		If lElectron .Or. lRemote
			nBottom := oSize:aWindSize[3] - (oSize:aWindSize[3] * 0.60)
		Else
			nBottom := oSize:aWindSize[3] - (oSize:aWindSize[3] * 0.67)
		EndIf

		nRight  := oSize:aWindSize[4] - (oSize:aWindSize[4] * 0.70)

		Define MsDialog oDlgT Title "Sele��o de Status" From nTop,nLeft To nBottom,nRight  Pixel

		oPanel := TPanel():New(00,00,"",oDlgT,,.F.,.F.,,,10,20,.F.,.F.)
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT
		If !lElectron .And. !lRemote
			oPanel:setCSS(QLABEL_AZUL_D)
		EndIf

		cMsgTit := "Selecione os Status que devem ser considerados para "
		cMsgTit += IIf(cIdBotao == 'EM',"Consulta - Edi��o ",IIf(cIdBotao == "EX"," Gera��o dos Xmls ","Transmiss�o "))
		cMsgTit += "dos registros Selecionados."

		oSayTit := TSay():New(nLin,oPanel:NCLIENTWIDTH  * 0.02,{||cMsgTit},oPanel,,,,,,.T.,,,oPanel:NCLIENTWIDTH * 0.45,030,,,,,,.T.)
		nLin += 25

		/* aChecks
		[1]Parametro
		[2]Campo
		[3]Descri��o
		[4]Status (numerico)
		*/

			For nX := 1 To Len(aChecks)

				nCol++
				nTamCol := IIf(nCol==1,oPanel:NCLIENTWIDTH * 0.14,oPanel:NCLIENTWIDTH * 0.30)
				If aChecks[nX][1]

			 	/*+---------------------------------------------------------------------------------------+
			 	  | Quando a chamada da fun��o for oriunda do bot�o for TG (Transmissao ao Governo)       |
			 	  | a marca��o default do checkBox deve ser True somente para o check dos eventos Validos.|
			 	  | Para os demais bot�es a Marca��o default � sempre True                                |
			 	  +---------------------------------------------------------------------------------------+*/
				If cIdBotao == "TG" .And. aChecks[nX][4] == STATUS_VALIDO[1] .Or. cIdBotao != "TG"
					aSelStus[nX] := .T.
				Else
					aSelStus[nX] := .F.
				EndIf

	  			&('oChk' + AllTrim(Str(nX))) := TCheckBox():New(nLin,nTamCol,aChecks[nX][3],&("{|u|IIf (PCount()==0,aSelStus[" + AllTrim(Str(nX)) + " ],aSelStus[" + AllTrim(Str(nX)) + "] := u)}"),oPanel,100,210,,,,,,,,.T.,,,)

				If cIdBotao == "TG" .And. (aChecks[nX][4] == STATUS_TRANSMITIDO_OK[1] .Or. aChecks[nX][4] == STATUS_SEM_RETORNO_GOV[1])  //N�o Habilita a transmiss�o de um item j� autorizado e aguardando retorno do TSS.
					&('oChk' + AllTrim(Str(nX))):Disable()
				Else
					&('oChk' + AllTrim(Str(nX))):Enable()
				EndIf

			Else
				aSelStus[nX] := .F.
	  			&('oChk' + AllTrim(Str(nX))) := TCheckBox():New(nLin,nTamCol,aChecks[nX][3],&("{|u|IIf (PCount()==0,aSelStus[" + AllTrim(Str(nX)) + " ],aSelStus[" + AllTrim(Str(nX)) + "] := u)}"),oPanel,100,210,,,,,,,,.T.,,,)
				&('oChk' + AllTrim(Str(nX))):Disable()
			EndIf
			nLin += IIf(nCol==2,10,0)
			nCol := IIf(nCol==2,0,nCol)

		Next nX

		cRadio1 := "Peri�dicos/N�o Peri�dicos" //???
		cRadio2 := "Trabalhador" //???

		nLin+= 10
		cMsgBtt := IIf(cIdBotao == 'EM',"Consultar/Editar",IIf(cIdBotao == "EX","Gerar Xmls","Transmitir"))

		if Len(aChecks) > 0
			lSelTodos := (cIdBotao != "TG") //todos selecionados caso nao seja Transmissao ao Governo
			@ 52,10 CheckBox oCBoxTodos var lSelTodos Prompt "Todos" Size 50,10 Of oDlgT Pixel On Click( SelTodosStus(lSelTodos, aSelStus) )
		endif

		//oBttOK   := TButton():New(nLin,oPanel:NCLIENTWIDTH * 0.05,cMsgBtt,oDlgT,{||lOk := .T.,oDlgT:End() }, 70,12,,,.F.,.T.,.F.,,.F.,,,.F. )
		//oBttSair := TButton():New(nLin,oPanel:NCLIENTWIDTH * 0.3,"Cancelar",oDlgT,{||oDlgT:End()},70,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	   //	oBttOK:SetCSS(BTNLINK)
		Activate MsDialog oDlgT Centered On Init (EnchoiceBar(oDlgT,{||lOk :=.T.,oDlgT:End()},{||oDlgT:End()},,,,,.F.,.F.,.F.,.T.,.F.))

		If lOk
			//Considera os Status Selecionados
			For nX := 1 To Len(aSelStus)
				If 	aSelStus[nX]
					IIf (lVirgula,cStatus += ",",lVirgula := .T.)
					cStatus += IIf(aChecks[nX][4] == STATUS_NAO_PROCESSADO[1],"' '","'" + AllTrim(Str(aChecks[nX][4])) + "'")
				EndIf
			Next nX
		EndIf
	Else
		cMsgErr := IIf(cIdBotao == 'EM',STR0097,IIf(cIdBotao == "EX",STR0096,STR0092)) //"Edi��o"#"Exporta��o"#"Transmiss�o"
		MsgStop(STR0098 + cMsgErr) //"Selecionar ao menos 1 item para a opera��o de "
	EndIf
Else
	lOk := .T.
EndIf

If lOk
	//Quando selecionado registros do painel da direita eu considero os status dos par�metros
	If lDetal
		For nX := 1 To Len(aChecks)
			If 	aChecks[nX][1]
				IIf (lVirgula,cStatus += ",",lVirgula := .T.)
				cStatus += IIf(aChecks[nX][4] == STATUS_NAO_PROCESSADO[1],"' '","'" + AllTrim(Str(aChecks[nX][4])) + "'")
			EndIf
		Next nX
	EndIf

	If cIdBotao == "EX"
		
		If lRemote
			
			If !ExistDir( cBarra + "xmlexport" )
				MakeDir( cBarra + "xmlexport" )
			EndIf

			cPathXml := cBarra + "xmlexport" + cBarra

		Else
			cPathXml := cGetFile(STR0087 + "|*.*", STR0088, 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T. ) //Diretorio#Procurar
		EndIf

		If !Empty(AllTrim(cPathXml))
			If paramVisao == 2
				Processa({|lCancel|TAFProc4Tss(.F.,aEvtsSel,cStatus,cPathXml,aIdsSel,,,@cMsgRet,.T.,paramFiliais,aParamES[12],aParamES[13],@lCancel,,@oTabFilSel,@lSemAcesso)},STR0089,STR0090,.T.)//"Gera��o de XMLs"#"Gerando os Xmls Selecionados"
			Else
				Processa({|lCancel|TAFProc4Tss(.F.,aEvtsSel,cStatus,cPathXml,aIdsSel,cRecNos,,@cMsgRet,.T.,paramFiliais,aParamES[12],aParamES[13],@lCancel,,@oTabFilSel,@lSemAcesso )},STR0089,STR0090,.T.)//"Gera��o de XMLs"#"Gerando os Xmls Selecionados"
			EndIf

			If lSemAcesso
				MsgInfo(STR0091 + CRLF + CRLF + STR0269) //"Processamento Finalizado" - "NOTA: Um ou mais eventos n�o foram exportados devido a restri��es de acesso da rotina relacionada para o usu�rio corrente na filial do registro. Cheque os privil�gios do usu�rio no configurador."
			Else
				MsgInfo(STR0091) //"Processamento Finalizado"
			EndIf

		EndIf

	ElseIf cIdBotao == "TG" 
		If paramVisao == 2
			Processa({|lCancel|aRetEvts := TAFProc4Tss(.F.,aEvtsSel,cStatus,,aIdsSel,,@lAtualiza,@cMsgRet,,paramFiliais,paramDataInicial,paramDataFim,@lCancel,,@oTabFilSel,@lSemAcesso)},"Transmiss�o de Eventos","Consultando eventos para a transmiss�o",.T.)
		Else
			Processa({|lCancel|aRetEvts := TAFProc4Tss(.F.,aEvtsSel,cStatus,,aIdsSel,cRecNos,@lAtualiza,@cMsgRet,,paramFiliais,paramDataInicial,paramDataFim,@lCancel,,@oTabFilSel,@lSemAcesso)},"Transmiss�o de Eventos","Consultando eventos para a transmiss�o",.T.)
		EndIf

		TAFMErrT0X(aRetEvts) //Verificar o uso cFilAnt

		If lSemAcesso
			MsgInfo(cMsgRet  + CRLF + CRLF + STR0270, STR0094) //"Transmiss�o e-Social" - "NOTA: Um ou mais eventos n�o foram transmitidos devido a restri��es de acesso da rotina relacionada para o usu�rio corrente na filial do registro. Cheque os privil�gios do usu�rio no configurador."
		Else //ElseIf!lMV
			MsgInfo(cMsgRet, STR0094) //"Transmiss�o e-Social"
		EndIf

		If !lMV
			If lAtualiza 

				If MsgYesNo( STR0163 , STR0164 ) //"Deseja abrir os detalhes da transmiss�o?" ## "Painel e-Social - Detalhes"

				oProcess := Nil
				//oProcess:= MsNewProcess():New( {|lCancel|TafMonDet(Nil,"'1','2','3'",'',aEvtsSel,.T.,lMultEvt,cRecNos,aIdsSel,lDetal,cIdBrowse,lTempTable,@oProcess,@lCancel)} , "Detalhamento/Consulta TSS" , "Aguarde ... Consultando registros.",.T.)
				//oProcess:Activate()

				oProcess := Nil
				lCancel := .F.
				FWMsgRun(,{||TafMonDet(Nil,"'1','2','3'",'',aEvtsSel,.T.,lMultEvt,cRecNos,aIdsSel,lDetal,cIdBrowse,lTempTable,@oProcess,@lCancel,@oTabFilSel,aParamES[12],aParamES[13])} , "Detalhamento/Consulta TSS" , "Aguarde ... Consultando registros.",.T.)  
			Endif
		EndIf

			If cIdBrowse == 'Tabelas'
				FWMsgRun(,{||TafMonETab(,.T.,aChecks,@oMBrwTabs,lTempTable,@oTabFilSel)},STR0166,STR0167) //"Atualizar Browser"#"Atualizando Browser"
			ElseIf cIdBrowse == 'EvtsPer'
				FWMsgRun(,{||TafMonEPer(,.T.,aChecks,@nRegSelTrb,@nRegSelEvt,lTempTable,@oTabFilSel)},STR0166,STR0167) //"Atualizar Browser"#"Atualizando Browser"
			ElseIf cIdBrowse == 'Trabalhador'
				FWMsgRun(,{||TafMonETrb(,.T.,aChecks,@nRegSelTrb,@nRegSelEvt,lTempTable,@oTabFilSel)},STR0166,STR0167) //"Atualizar Browser"#"Atualizando Browser"
			EndIf

		EndIf	

	Else

		//oProcess:= MsNewProcess():New( {|lCancel|ConsultaRegs(aEvtsSel,aIdsSel,cStatus,lCancel,oProcess),TafMonDet(Nil,cStatus,'',aEvtsSel,.T.,lMultEvt,cRecNos,aIdsSel,lDetal,cIdBrowse,lTempTable,@oProcess,@lCancel)} , "Detalhamento/Consulta TSS" , "Aguarde ... Consultando registros.",.T. )
		// oProcess:Activate()

		lCancel := .F.
		FWMsgRun(,{|oMsgRun| ConsultaRegs(aEvtsSel,aIdsSel,"'2','3'",lCancel,,@oTabFilSel,oMsgRun),;
					 TafMonDet(Nil,cStatus,'',aEvtsSel,.T.,lMultEvt,cRecNos,aIdsSel,lDetal,cIdBrowse,lTempTable,,@lCancel,@oTabFilSel,aParamES[12],aParamES[13])},;
	    "Detalhamento/Consulta TSS" , "Aguarde ... Consultando registros.",.T. )

		If cIdBrowse == 'Tabelas'
			FWMsgRun(oPanelTbl:oParent,{||TafMonETab(,.T.,aChecks,@oMBrwTabs,lTempTable,@oTabFilSel)})
		ElseIf cIdBrowse == 'EvtsPer'
			FWMsgRun(oPanelEvt:oParent,{||TafMonEPer(,.T.,aChecks,@nRegSelTrb,@nRegSelEvt,lTempTable,@oTabFilSel)})
		ElseIf cIdBrowse == 'Trabalhador'
			FWMsgRun(oPanelTrb:oParent,{||TafMonETrb(,.T.,aChecks,@nRegSelTrb,@nRegSelEvt,lTempTable,@oTabFilSel)})
		EndIf
	EndIf
EndIf

Return Nil

Static Function ConsultaRegs(aEvtsSel,aIdsSel,cStatus,lEnd,oProcess,oTabFilSel,oMsgRun)

	Default oProcess := Nil

	If !FWGetRunSchedule()
		TAFProc5Tss(.F.,aEvtsSel,cStatus,aIdsSel,,lEnd,,paramFiliais,paramDataInicial,paramDataFim,,,,oProcess,,@oTabFilSel,,,oMsgRun)
	EndIf 
	
Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} SelTodosStus()

Seleciona todos os status

@author Felipe Rossi Moreira
@since 26/03/2018
@version 1.0
@param aSelStus -> Array com os status de cada checkbox

@return Nil
/*/
//--------------------------------------------------------------------
Static Function SelTodosStus(lSelTodos, aSelStus)
Local nX := 0
For nX := 1 To Len(aSelStus)
	If &('oChk' + AllTrim(Str(nX))):lActive
		aSelStus[nX] := lSelTodos// .T. //!aSelStus[nX]
		&('oChk' + AllTrim(Str(nX))):Refresh()
	EndIf
Next nX
Return


//--------------------------------------------------------------------
/*/{Protheus.doc} TAFMErrT0X()

Grava erros de transmiss�o com origem na camada TAF/TSS

@author evandro.oliveira
@since 27/11/2017
@version 1.0
@param aRetEvts -> Array com o Retorno da Transmiss�o

@return Nil
/*/
//--------------------------------------------------------------------
Function TAFMErrT0X(aRetEvts,lJob)

	Local nI 			:= 0
	Local nX 			:= 0
	Local lRec 			:= .T.
	Local cIdUnic 		:= ""
	Local cErro 		:= ""
	Local cTpErro 		:= ""
	Local lTramitido 	:= .F.
	Local cFilBkp		:= cFilAnt //Backup da Filial

	Default lJob := .F.

	dbSelectArea("T0X")
	T0X->(dbSetOrder(3))

	BEGIN TRANSACTION
	For nI := 1 To Len(aRetEvts)
		//Tratar Erros no Lote

		For nX := 1 To Len(aRetEvts[nI][3])

			lTramitido := aRetEvts[nI][3][nX][1]
			cTpErro := aRetEvts[nI][3][nX][5]

			If !lTramitido .And. cTpErro $ "SA" //Erros de Schema e Ambiente

				cIdUnic	:= aRetEvts[nI][3][nX][3]
				cErro	:= aRetEvts[nI][3][nX][4]

				//Ajuste da filial com a filial do registro
				If Len(aRetEvts[nI][3][nX]) > 5
					cFilAnt	:= aRetEvts[nI][3][nX][6]
				Else
					cFilAnt	:= cFilBkp
				EndIf

				limpaRegV2H( cIdUnic, xFilial("T0X") )

				lRec := !TafSeekT0X(cIdUnic)

				If RecLock( "T0X", lRec )

					T0X->T0X_FILIAL := xFilial("T0X")

					If lRec
						T0X->T0X_ID := TafGeraID("TAF")
					EndIf

					T0X->T0X_IDCHVE	:= cIdUnic
					T0X->T0X_DCERRO	:= cErro
					T0X->T0X_TPERRO	:= cTpErro
					T0X->T0X_IDEVEN	:= Transform(SubStr(cIdUnic,1,5),"@R X-XXXX")
					
					If TAFColumnPos("T0X_CDERRO") .And. Len(aRetEvts[nI][3][nX]) > 6 //Avalia somente um dos campos pois os tr�s foram criados juntos e verifica tamanho do array pois para reinf n�o existem tais informa��es
						T0X->T0X_CDERRO	:= aRetEvts[nI][3][nX][7]
						T0X->T0X_DATA	:= aRetEvts[nI][3][nX][8]
						T0X->T0X_HORA	:= aRetEvts[nI][3][nX][9]
					EndIf

					If lJob
						T0X->T0X_USER := "__Schedule"
					Else
						T0X->T0X_USER := cUserName
					Endif
					T0X ->(MsUnlock())
				EndIf

			EndIf
		Next nX
	Next nI
	END TRANSACTION

	cFilAnt := cFilBkp //Restaura a Filial

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} FVerChks
Verifica a Sele��o dos Itens dos Browses de Tabelas,Trabalhador e Eventos
Os Browses Trabalhador e Eventos variam de posi��o na tela de acordo com os
par�metros, o Browse localizado a esquerda � um aglutinado dos itens do browse
da direita, sendo assim o browse da direita tem um detalhamento do item
posicionado no da direita; N�o � permitido que os 2 browses sejam marcados.
@author evandro.oliveira
@since 07/04/2016
@version 1.0
@param lDetal, ${param_type}, (Descri��o do par�metro)
@param cRecNos, character, (Descri��o do par�metro)
@param aEvtSel, array, (Descri��o do par�metro)
@param aIdsSel, array, (Descri��o do par�metro)
@param lMultEvt, ${param_type}, (Descri��o do par�metro)
@param cIdBrowse, character, (Descri��o do par�metro)
@param cIdBotao, character, (Descri��o do par�metro)
@param nRegSelTrb, num�rico, (Descri��o do par�metro)
@param nRegSelEvt, num�rico, (Descri��o do par�metro)
@param oMBrwTabs, objeto, (Descri��o do par�metro)
@return ${Nil}
/*/
//--------------------------------------------------------------------
Static Function FVerChks(lDetal,cRecNos,aEvtSel,aIdsSel,lMultEvt,cIdBrowse,cIdBotao,nRegSelTrb,nRegSelEvt,oMBrwTabs, aInfoTrab, lMV, oMarkDet, oTempTable )

	Local nPos			:= 0
	Local nX			:= 0
	Local aAuxSel		:= {}

	Default cRecNos		:= ""
	Default	aInfoTrab	:= {}
	Default aIdsSel		:= {}
	Default lMV         := .F.
	Default oMarkDet    := Nil
	Default oTempTable	:= Nil

	If cIdBrowse == "Tabelas"

		nLinBrw := oMBrwTabs:oBrowse:nAt

		dbSelectArea(cAliasTab)
		(cAliasTab)->(dbGoTop())
		While (cAliasTab)->(!Eof())
			If !Empty((cAliasTab)->MARK)
				aAdd(aEvtSel,TAFRotinas(Substr((cAliasTab)->XEVENTO,1,6),4,.F.,2))
			EndIf
			(cAliasTab)->(dbSkip())
		EndDo 
		
		oMBrwTabs:GoTo(nLinBrw)
	Else

		If paramEtvPeriodicos .Or. paramEtvNaoPeriodicos

			If lMV						 
 				cTableTrb := oMarkDet:oBrowse:oData:oTempDB:GetRealName()	
			 	cTableEvt := oTempTable:GetRealName() 				 
			Else
				cTableTrb := oMarkTrb:oBrowse:oData:oTempDB:GetRealName()
				cTableEvt := oMarkEvt:oBrowse:oData:oTempDB:GetRealName()
			EndIf

			//Conta Itens Selecionados no browse do Trabalhador
			cQryTrb := " SELECT COUNT(*) NREGSTRB "
			cQryTrb += " FROM  " + cTableTrb
			cQryTrb += " WHERE MARK != ' ' "

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQryTrb ),'trbCount', .F., .T. )

			nCountTrb :=  trbCount->NREGSTRB
			trbCount->(dbCloseArea())

			//Conta Itens Selecionados no browse de eventos
			cQryEvt := " SELECT COUNT(*) NREGSEVT "
			cQryEvt += " FROM  " + cTableEvt 
			cQryEvt += " WHERE MARK != ' ' "

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQryEvt ),'evtCount', .F., .T. )

			nCountEvt :=  evtCount->NREGSEVT 
			evtCount->(dbCloseArea())  

			//Cria RecordSet dos Itens Marcados
			If Select('SelItTRB') > 0
				SelItTRB->(dbCloseArea())
			EndIf

			If lMV
				cQryTrb := " SELECT RECNO, FILIAL, ID, CPF "
			Else
				cQryTrb := " SELECT RECNO, C9V_FILIAL FILIAL, C9V_ID ID, C9V_VERSAO VERSAO "
			EndIf

			cQryTrb += " FROM  " + cTableTrb
			cQryTrb += " WHERE MARK != ' ' "
			If paramVisao == 2
				cQryEvt += " OR RECNO = '" + cValToChar((cAliasTrb)->RECNO) + "'"
			EndIf

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQryTrb ),'SelItTRB', .F., .T. )

			SelItTRB->(dbGoTop())
			While  SelItTRB->(!Eof())

				nPos := 0
				For nX := 1 To Len(aIdsSel)
					If aIdsSel[nX][1] == SelItTRB->FILIAL//C9V_FILIAL
						nPos := nX
						Exit
					Endif
				Next nX

				If nPos == 0
					aAuxSel := {SelItTRB->FILIAL,{SelItTRB->ID}}
					aAdd(aIdsSel,aAuxSel)
					aAuxSel := {}
				Else
					aAdd(aIdsSel[nPos][2],SelItTRB->ID)
				EndIf

				aAdd(aInfoTrab,{SelItTRB->FILIAL,SelItTRB->ID})

				SelItTRB->(dbSkip())
			EndDo

			If Select('SelItEvt') > 0
				SelItEvt->(dbCloseArea())
			EndIf

			If lMV
				cQryEvt := " SELECT EVENTO "
			Else
				cQryEvt := " SELECT XEVENTO "
			EndIf

			cQryEvt += " FROM  " + cTableEvt
			cQryEvt += " WHERE MARK != ' ' "
			If paramVisao == 1 .and. !Empty( aIdsSel )
				If lMV
					cQryEvt += " OR EVENTO = '" + AllTrim((oTempTable:oStruct:CALIAS)->EVENTO) + "'"
				Else
					cQryEvt += " OR XEVENTO = '" + AllTrim((cAliasEvt)->XEVENTO) + "'"
				EndIf
			EndIf

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQryEvt ),'SelItEvt', .F., .T. )

			SelItEvt->(dbGoTop())
			While SelItEvt->(!Eof())
				If lMV
					aAdd(aEvtSel,TAFRotinas(AllTrim(SelItEvt->EVENTO),4,.F.,2))
				Else
					aAdd(aEvtSel,TAFRotinas(AllTrim(SelItEvt->XEVENTO),4,.F.,2))
				EndIf

				SelItEvt->(dbSkip())
			EndDo


		EndIf
	EndIf

Return Nil
//--------------------------------------------------------------------
/*/{Protheus.doc} MtFCalOk
Checa marcacao das filiais para calculo por empresa
@author eduardo.mantoan
@since 20/03/2017
@version 1.0
@return ${lRetorno}, ${Informa se a rotina foi executada com sucesso}
/*/
//--------------------------------------------------------------------
Function MtFCalOk(aFilsCalc,lValidaArray,lMostraTela,lConsolida,nValida)
	Local lRet    	:= .F.
	Local nX   	  	:= 0
	Local nOpca		:= 0
	Local nPos		:= 0
	Local aEmpresas := {}

	Default lMostraTela := .T.
	Default lConsolida	:= .F.
	Default nValida		:= 0

	If !lValidaArray
		aFilsCalc := {}
		lRet := .T.
	Else
		//-- Checa se existe alguma filial marcada na confirmacao
		If !(lRet := aScan(aFilsCalc,{|x| x[1]}) > 0) .And. lMostraTela
			Aviso(OemToAnsi("Aten��o"),OemToAnsi("Nenhuma filial foi selecionada"),{"Ok"})
		EndIf

		//-- Se rotina consolidada, valida se todas as filiais da empresa (CNPJ+IE) foram marcadas
		If lRet .And. lConsolida
			For nX := 1 To Len(aFilsCalc)
				If nValida == 1         		// CNPJ Igual
					nPos := aScan(aEmpresas,{|x| x[3] == aFilsCalc[nX,4]})
				ElseIf nValida == 2			// CNPJ + I.E. iguais
					nPos := aScan(aEmpresas,{|x| x[1] == aFilsCalc[nX,4]+aFilsCalc[nX,5]})
				ElseIf nValida == 3			// CNPJ Raiz
					nPos := aScan(aEmpresas,{|x| x[4] == Substr(aFilsCalc[nX,4],1,8)})
				ElseIf nValida == 4			// CNPJ + Insc.Municipal iguais
					nPos := aScan(aEmpresas,{|x| x[5] == aFilsCalc[nX,4]+aFilsCalc[nX,6] })
				Else						// Legado - n valida
					nPos := 0
				EndIf

				If !Empty(nPos) .And. aFilsCalc[nX,1] # aEmpresas[nPos,2]
					If Empty(nOpca)
						If lMostraTela
							nOpca := Aviso(STR0030,STR0056,{STR0057,STR0058,STR0059},2) //"A execuo desta rotina foi parametrizada para modo consolidado   foram selecionadas todas as filiais de uma ou mais empresas. Deseja que estas filiais sejam adicionadas a seleo ou mant a seleo atual?"
						Else
							nOpca := 1
						EndIf
					EndIf
					If nOpca == 1
						aEmpresas[nPos,2] := .T.
					Else
						If nOpca == 3
							lRet := .F.
						EndIf
						Exit
					EndIf
				ElseIf Empty(nPos)
					aAdd(aEmpresas,{aFilsCalc[nX,4]+aFilsCalc[nX,5], aFilsCalc[nX,1], aFilsCalc[nX,4], Substr(aFilsCalc[nX,4],1,8), aFilsCalc[nX,4]+aFilsCalc[nX,6] })
				EndIf
			Next nX

			If nOpca == 1
				aFilsCalc := {}

				//-- Percorre SM0 adicionando filiais com CNPJ+IE marcados
				SM0->(dbGoTop())
				If nValida < 2         		// CNPJ Igual
					SM0->(dbEval({|| If(aScan(aEmpresas,{|x| M0_CODIGO == cEmpAnt .And. x[3] == M0_CGC .And. x[2]}) == 0,NIL,aAdd(aFilsCalc,{.T.,M0_CODFIL,M0_FILIAL,M0_CGC,M0_INSC,M0_INSCM}))}))
				ElseIf nValida == 2			// CNPJ + I.E. iguais
					SM0->(dbEval({|| If(aScan(aEmpresas,{|x| M0_CODIGO == cEmpAnt .And. x[1] == M0_CGC+M0_INSC .And. x[2]}) == 0,NIL,aAdd(aFilsCalc,{.T.,M0_CODFIL,M0_FILIAL,M0_CGC,M0_INSC,M0_INSCM}))}))
				ElseIf nValida == 3			// CNPJ Raiz
					SM0->(dbEval({|| If(aScan(aEmpresas,{|x| M0_CODIGO == cEmpAnt .And. x[4] == SubStr(M0_CGC,1,8) .And. x[2]}) == 0,NIL,aAdd(aFilsCalc,{.T.,M0_CODFIL,M0_FILIAL,M0_CGC,M0_INSC,M0_INSCM}))}))
				ElseIf nValida == 4			// CNPJ + Insc.Municipal iguais
					SM0->(dbEval({|| If(aScan(aEmpresas,{|x| M0_CODIGO == cEmpAnt .And. x[5] == M0_CGC+M0_INSCM .And. x[2]}) == 0,NIL,aAdd(aFilsCalc,{.T.,M0_CODFIL,M0_FILIAL,M0_CGC,M0_INSC,M0_INSCM}))}))
				EndIf

				//-- Ordena por CNPJ+IE+Ins.Mun+Codigo para facilitar a quebra da rotina
				aSort(aFilsCalc,,,{|x,y| x[4]+x[5]+x[6]+x[2] < y[4]+y[5]+x[6]+y[2]})

			ElseIf nOpca # 3
				//-- Deleta filiais que nao serao processadas
				nX := 1
				While nX <= Len(aFilsCalc)
					If !aFilsCalc[nX,1]
						aDel(aFilsCalc,nX)
						aSize(aFilsCalc,Len(aFilsCalc)-1)
					Else
						nX++
					EndIf
				End
			EndIf
		EndIf
	EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} MtFClTroca
Troca marcador entre x e branco
@author eduardo.mantoan
@since 20/03/2017
@version 1.0
@return ${lRetorno}, ${Informa se a rotina foi executada com sucesso}
/*/
//--------------------------------------------------------------------
Static Function MtFClTroca(nIt,aArray,nValida,nSelCNPJIE,cSelCNPJIE)
	Default nValida := 0 	//1= Valida apenas CNPJ com mesmo numero MatFilCalc() / 2=Valida apenas CNPJ+IE com mesmo numero MatFilCalc()
							//3= Valida CNPJ Raiz (8 primeiros ditos) com mesmo nero/ 4= Valida CNPJ+IE+Insc.Municipal com mesmo nero
	If nValida == 0
		aArray[nIt,1] := !aArray[nIt,1]
	Else
		If aArray[nIt,1]
		   	nSelCNPJIE--
			If nSelCNPJIE==0
	 	   		cSelCNPJIE:=""
			Endif
			aArray[nIt,1] := !aArray[nIt,1]
		Else
	 		If nSelCNPJIE > 0
	 	    	If ( nValida==1 .and. aArray[nIt,4]==cSelCNPJIE ) .or. ( nValida==2 .and. aArray[nIt,4]+aArray[nIt,5]==cSelCNPJIE ) .or.;
	 	    		( nValida==3 .and. Substr(aArray[nIt,4],1,8) == Substr(cSelCNPJIE,1,8) ) .or. ( nValida==4 .and. aArray[nIt,4]+aArray[nIt,6] == cSelCNPJIE )
		 	   		nSelCNPJIE++
			 	   	aArray[nIt,1] := !aArray[nIt,1]
		 	  	Else
		 	  		If nValida == 1
		 	  			//'SIGACUSCNPJ' ; 'A Consolidao por CNPJ est?habilitado. Selecione apenas Filiais com o mesmo CNPJ [' ; '] j?marcado, ou refasua seleo!'
			 	  		Help(nil,1,STR0060,nil,STR0061+Transform(cSelCNPJIE,"@R 99.999.999/9999-99")+STR0062,3,0)
			 	  	ElseIf nValida == 2
			 	  	   //'SIGACUSCNPJIE' ; 'A Consolidao por CNPJ+IE est?habilitado. Selecione apenas Filiais com o mesmo CNPJ+IE [' ; '] j?marcado, ou refa sua seleo!'
			 	  		Help(nil,1,STR0063,nil,STR0064+Transform(Substr(cSelCNPJIE,1,14),"@R 99.999.999/9999-99")+" - "+Substr(cSelCNPJIE,15)+STR0062,3,0)
			 	  	ElseIf nValida == 3
						//'SIGACUSCNPJP' ; 'A Consolidao por CNPJ Raiz est?habilitado. Selecione apenas Filiais com o mesmo CNPJ Raiz [' ; '] j?marcado, ou refa sua seleo!'
						Help(nil,1,STR0066,nil,STR0067+Transform(Substr(cSelCNPJIE,1,8),"@R 99.999.999")+" - "+Substr(cSelCNPJIE,15)+STR0062,3,0)
			 	  	Else
						//'SIGACUSCNPJIM' ; 'A Consolidao por CNPJ + Insc.Municiap est?habilitado. Selecione apenas Filiais com o mesmo CNPJ e Inscrio Municipal [' ; '] j?marcado, ou refa sua seleo!'
						Help(nil,1,STR0068,nil,STR0069+Transform(Substr(cSelCNPJIE,1,14),"@R 99.999.999/9999-99")+" - "+Substr(cSelCNPJIE,15)+STR0062,3,0)
			 	  	Endif
		 	   	Endif
			Else
				nSelCNPJIE++
				If nValida==1									// Valida CNPJ
					cSelCNPJIE := aArray[nIt,4]
				ElseIf nValida ==2								// Valida CNPJ + I.E.
					cSelCNPJIE := aArray[nIt,4]+aArray[nIt,5]
				ElseIf nValida ==3								// Valida CNPJ Raiz (oito primeiros ditos)
					cSelCNPJIE := Subs(aArray[nIt,4],1,8)
				Else											// Valida CNPJ + Insc.Municipal
					cSelCNPJIE := aArray[nIt,4]+aArray[nIt,6]
				Endif
				aArray[nIt,1] := !aArray[nIt,1]
	 		Endif
	 	Endif
	Endif
Return aArray

//--------------------------------------------------------------------
/*/{Protheus.doc} TafVldSche

Valida Schema do XML comunicando com o TSS

@aParam	[1] -> C�digo do evento
 		[2] -> ID do Evento
 		[3] -> XML

@Return cQryParam -> String com as filiais para uso na query

@Author	Leonardo Kichitaro/Helena Leal
@Since	13/12/2017

@Version 1.0
/*/
//---------------------------------------------------------------------
Function TafVldSche( aSchema, cError, cWarning )

Local oSocial		:=	Nil
Local cURL			:=	""
Local cCheckURL		:=	""
Local cIDEnt		:=	TAFRIDEnt( ,,,,, .T. )
Local cVerSchema	:=	IIF(TafLayESoc("S_01_00_00"),'S_01_00_00','02_05_00')
LocaL nX			:=	0
Local aRet			:=	{}

Default aSchema		:=	{}
Default cError		:=	""
Default cWarning	:=	""

If FindFunction( "TAFGetUrlTSS" )
	cURL := PadR( TAFGetUrlTSS(), 250 )
Else
	cURL := PadR( GetNewPar( "MV_TAFSURL", "http://" ), 250 )
EndIf

cURL := AllTrim( cURL )

If Empty( AllTrim( cURL ) )
	cError := STR0225 //"Erro de comunica��o."
	cWarning := STR0226 //"O par�metro 'MV_TAFSURL' n�o est� preenchido."
Else
	If !( "TSSWSSOCIAL.APW" $ Upper( cURL ) )
		cCheckURL := cURL
		cURL += "/TSSWSSOCIAL.apw"
	Else
		cCheckURL := SubStr( cURL, 1, Rat( "/", cURL ) - 1 )
	EndIf

	oSocial := WSTSSWSSOCIAL():New()
	oSocial:_Url := cURL
	oSocial:oWSENTXSDDADOS:cUSERTOKEN := "TOTVS"
	oSocial:oWSENTXSDDADOS:cID_ENT := cIDEnt
	oSocial:oWSENTXSDDADOS:oWSENTXSDDOCS := WsClassNew( "TSSWSSOCIAL_ARRAYOFENTXSDDOC" )
	oSocial:oWSENTXSDDADOS:oWSENTXSDDOCS:OWSENTXSDDOC := {}

	For nX := 1 to Len( aSchema )
		aAdd( oSocial:oWSENTXSDDADOS:oWSENTXSDDOCS:OWSENTXSDDOC, WsClassNew( "TSSWSSOCIAL_ENTXSDDOC" ) )
		aTail( oSocial:oWSENTXSDDADOS:oWSENTXSDDOCS:OWSENTXSDDOC ):CCODIGO := aSchema[nX,1]
		aTail( oSocial:oWSENTXSDDADOS:oWSENTXSDDOCS:OWSENTXSDDOC ):CID := aSchema[nX,2]
		aTail( oSocial:oWSENTXSDDADOS:oWSENTXSDDOCS:OWSENTXSDDOC ):CVERSAO := cVerSchema
		aTail( oSocial:oWSENTXSDDADOS:oWSENTXSDDOCS:OWSENTXSDDOC ):CXML := aSchema[nX,3]
	Next nX

	lRetWS := oSocial:ValidarDocumentos()

	If ValType( lRetWS ) == "L"
		If ValType( oSocial:oWSVALIDARDOCUMENTOSRESULT:oWSSAIDAXSDDOCS ) <> "U"
			For nX := 1 to Len( oSocial:oWSVALIDARDOCUMENTOSRESULT:oWSSAIDAXSDDOCS:oWSSAIDAXSDDOC )
				aAdd( aRet, { AllTrim( oSocial:oWSVALIDARDOCUMENTOSRESULT:oWSSAIDAXSDDOCS:oWSSAIDAXSDDOC[nX]:CID ),;
				AllTrim( oSocial:oWSVALIDARDOCUMENTOSRESULT:oWSSAIDAXSDDOCS:oWSSAIDAXSDDOC[nX]:CCODIGO ),;
				AllTrim( oSocial:oWSVALIDARDOCUMENTOSRESULT:oWSSAIDAXSDDOCS:oWSSAIDAXSDDOC[nX]:CMENSAGEM ),;
				oSocial:oWSVALIDARDOCUMENTOSRESULT:oWSSAIDAXSDDOCS:oWSSAIDAXSDDOC[nX]:LSUCESSO } )
			Next nX
		Else
			cError := STR0227 //"Erro no retorno do WS."
			cWarning := STR0228 //"Tipo de dado indefinido no retorno do WS."
		EndIf
	Else
		cError := STR0227 //"Erro no retorno do WS."
		cWarning := STR0229 //"Retorno do WS n�o � do Tipo L�gico."
	EndIf
EndIf

Return( aRet )

//--------------------------------------------------------------------
/*/{Protheus.doc} TafMonPFil

Retorna as filias selecionadas na tela e filtro

@Param	cAliasTab -> Alias do evento
@param oTabFilSel - Recebido como referencia, guarda as filiais selecionadas por tabelas de evento
@Return cQryParam -> String com as filiais para uso na query

@Author	Evandro dos Santos Oliveira
@Since	27/06/2017

@Version 1.0
/*/
//---------------------------------------------------------------------
Function TafMonPFil(cAliasTab,oTabFilSel,aFilMrkBrw)
	Local aSaveArea		:= GetArea()
	Local aFilSel		:= {}

	Local nY			:= 0
	Local nX			:= 0

	Local cQryParam		:= ""
	Local cFilTab		:= ""
	Local cTabFilSel	:= ""
	Local cTmpAlias		:= ""

	Default oTabFilSel	:= Nil
	Default aFilMrkBrw	:= paramFiliais

	//----------------------------------------------------------------------------------------
	// N�o cria a tabela temporaria se j� existente, devido chamada em la�o por todos eventos
	//----------------------------------------------------------------------------------------
	If oTabFilSel == Nil
		//----------------------------------------------------------------------------------------
		// Estrutura da tabela temporaria com as filiais selecionadas pelo cliente. Criada tabela
		// para reduzir a query que � montada quando o cliente seleciona muitas filiais
		//----------------------------------------------------------------------------------------
		oTabFilSel := FWTemporaryTable():New()
		oTabFilSel:SetFields({{"ALIAS","C",3,0}})
		oTabFilSel:SetFields({{"FILIAL","C",FWSizeFilial(),0}})
		oTabFilSel:AddIndex("1", {"ALIAS","FILIAL"})
		oTabFilSel:Create()
	EndIf

	cTabFilSel	:= oTabFilSel:GetRealName()
	cTmpAlias	:= oTabFilSel:GetAlias()

	//----------------------------------------------------------
	// Avalia se o Alias j� est� informado na tabela temporaria
	//----------------------------------------------------------
	DBSelectArea(cTmpAlias)
	(cTmpAlias)->(DBSetOrder(1))
	If !(cTmpAlias)->(DBSeek(cAliasTab))

		//-------------------------------------------------------------------------------
		// Adequa as filiais selecionadas conforme a regra de compartilhamento da tabela
		//-------------------------------------------------------------------------------
		For nY := 1 To Len(aFilMrkBrw)

			If aFilMrkBrw[nY][1]

				If cAliasTab == 'C1E'

					AAdd(aFilSel,aFilMrkBrw[nY][2])

				Else

					cFilTab := XFilial(cAliasTab, aFilMrkBrw[nY][2])

					If AScan(aFilSel,cFilTab) == 0

						AAdd(aFilSel,cFilTab)

					EndIf

				EndIf

			EndIf

		Next nY

		//------------------------------------------------------------------------------------------------
		// Grava��o dos dados na tabela temporaria
		// Utilizado reclock ao inves de INSERT INTO devido o PostGres s� aceitar uma linha por instru��o
		//------------------------------------------------------------------------------------------------
		For nX := 1 To Len(aFilSel)
			RecLock(cTmpAlias,.T.)
			(cTmpAlias)->ALIAS	:= cAliasTab
			(cTmpAlias)->FILIAL	:= aFilSel[nX]
			(cTmpAlias)->(MSUnlock())
		Next nX

	EndIf

	cQryParam := " SELECT FILIAL FROM " + cTabFilSel + " WHERE ALIAS = '" + cAliasTab + "' "

	RestArea(aSaveArea)

Return  cQryParam

//--------------------------------------------------------------------
/*/{Protheus.doc} TafMonPVinc

Condi��o SQL para Filtro do Evento do Trabalhador COM Vinculo
(S-2200)

@Param cIniEsoc -> Data de Inicio do e-Social
@param cVerSchema -> Vers�o do Layout e-Social
@param cLayout -> Nome do Layout
@param cDataIni -> Data Inicial do Filtro
@param cDataIni -> Data Final do Filtro
@param cTipoEvt -> Tipo do Evento (C-Carga,I-Inicial etc..)

@return cQry -> trecho de query para filtro do evento.

@Author	Evandro dos Santos Oliveira
@Since	03/10/2017

@Version 1.0
/*/
//---------------------------------------------------------------------
Function TafMonPVinc(cIniEsoc,cVerSchema,cLayout,cDataIni,cDataFim,cTipoEvt)

	Local cQry := ""

	Default cIniEsoc := SuperGetMv('MV_TAFINIE',.F.," ")
	Default cDataIni := DtoS(paramDataInicial)
	Default cDataFim := DtoS(paramDataFim)
	Default cTipoEvt := ""

	cQry := ""

	cQry += " AND ( "

	cQry += " (C9V_CADINI = '2' "
	cQry += "  AND (CUP_DTADMI >= '" + cDataIni + "'"
	cQry += "  AND  CUP_DTADMI <= '" + cDataFim + "'"

	cQry += " OR "
	
	cQry += "  CUP_DTINVI >= '" + cDataIni + "'"
	cQry += "  AND CUP_DTINVI <= '" + cDataFim + "'))"
	
	cQry += " OR "

	cQry += " (C9V_CADINI = '1' "
	cQry += " AND '" + cIniEsoc + "' >= '" + cDataIni + "'"
	cQry += " AND '" + cIniEsoc + "' <= '" + cDataFim + "')"

	cQry += " ) "

Return cQry

//--------------------------------------------------------------------
/*/{Protheus.doc} TafMonPSVinc

Condi��o SQL para Filtro do Evento do Trabalhador SEM Vinculo
(S-2300)

@Param cIniEsoc -> Data de Inicio do e-Social
@param cVerSchema -> Vers�o do Layout e-Social
@param cLayout -> Nome do Layout
@param cDataIni -> Data Inicial do Filtro
@param cDataIni -> Data Final do Filtro
@param cTipoEvt -> Tipo do Evento (C-Carga,I-Inicial etc..)

@return cQry -> trecho de query para filtro do evento.

@Author	Evandro dos Santos Oliveira
@Since	03/10/2017

@Version 1.0
/*/
//---------------------------------------------------------------------
Function TafMonPSVinc(cIniEsoc,cVerSchema,cLayout,cDataIni,cDataFim,cTipoEvt)

	Local cQry := ""

	Default cIniEsoc := SuperGetMv('MV_TAFINIE',.F.," ")
	Default cDataIni := DtoS(paramDataInicial)
	Default cDataFim := DtoS(paramDataFim)
	Default cTipoEvt := ""

	cQry := " AND ("

	cQry += " (C9V_CADINI = '2' "
	cQry += " AND C9V_DTINIV >= '" + cDataIni + "'"
	cQry += " AND C9V_DTINIV <= '" + cDataFim + "')"

	cQry += " OR "

	cQry += " (C9V_CADINI = '1' "
	cQry += " AND '" + cIniEsoc + "' >= '" + cDataIni + "'"
	cQry += " AND '" + cIniEsoc + "' <= '" + cDataFim + "')"

	cQry += " ) "

Return cQry


//--------------------------------------------------------------------
/*/{Protheus.doc} TafMonPAfast

Condi��o SQL para Filtro do Evento de Afastamento Tempor�rio

@param cVerSchema -> Vers�o do Layout e-Social
@return cQry -> trecho de query para filtro do evento.

@Author	Evandro dos Santos Oliveira
@Since	03/10/2017

@Version 1.0
/*/
//---------------------------------------------------------------------
Function TafMonPAfast(cVerSchema,cDataIni,cDataFim,lAliasCM6)

	Local cQry := ""

	Default cDataIni 	:= DtoS(paramDataInicial)
	Default cDataFim 	:= DtoS(paramDataFim)
	Default lAliasCM6	:= .F.

	cQry := ""
	
	If lAliasCM6
		cQry += " AND ( "
	EndIf

		cQry += " CM6_DTAFAS >= '"  + cDataIni + "'"
		cQry += " AND CM6_DTAFAS <= '"  + cDataFim + "'"

		cQry += " OR CM6_DTFAFA >= '"  + cDataIni + "'"
		cQry += " AND CM6_DTFAFA <= '"  + cDataFim + "'"
	
	If lAliasCM6
		cQry += " AND CM6_FUNC = C9V.C9V_ID	)
	EndIf


Return cQry



//--------------------------------------------------------------------
/*/{Protheus.doc} TafLimpEmp

Fun��o utilizada para limpeza do empregador da base de dados do governo e grava��o de erros na tabela T0X.

@Author	anieli.rodrigues
@Since	26/12/2017

@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function TafLimpEmp()

	Local aRetEvts := TafTrmLimp()

	If Len(aRetEvts) > 0
		TAFMErrT0X(aRetEvts)
	EndIf

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} TafSeekT0X

Verificar se existe inconsist�ncia na tabela T0X para o usu�rio logado

@param cIdUnic - Chave do registro no TSS e no monitor de detalhamento


@Author	Evandro dos Santos Oliveira
@Since	14/01/2018

@Version 1.0
/*/
//---------------------------------------------------------------------
Function TafSeekT0X(cIdUnic)

	Local lSeek := .F.

	Default cIdUnic := ""

	If T0X->(MsSeek(xFilial("T0X")+cIdUnic))
		//Tem que fazer a opera��o abaixo at� ser incluido o usu�rio no indice utilizado
		//N�o foi incluido por que os pacotes estavam fechados.
		While T0X->(!Eof()) .And. AllTrim(T0X->T0X_IDCHVE) == AllTrim(cIdUnic)
			If AllTrim(T0X->T0X_USER) == AllTrim(cUserName) .Or. AllTrim(T0X->T0X_USER) == "__Schedule"
				lSeek := .T.
				Exit
			EndIf
			T0X->(dbSkip())
		EndDo
	EndIf

Return lSeek


//---------------------------------------------------------------------
/*/{Protheus.doc} TafMSelFilias

Retorna as informa��es da Filial

@Author		Evandro dos Santos Oliveira
@Since		01/03/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function TafMSelFilias()

	Local aFiliais  := {}
	Local aParamFil := {}


	aParamFil	:= Array(6)

	aParamFil[1] := .T.
	aParamFil[2] := AllTrim(SM0->M0_CODFIL)
	aParamFil[3] := AllTrim(SM0->M0_FILIAL)
	aParamFil[4] := AllTrim(SM0->M0_CGC)
	aParamFil[5] := AllTrim(SM0->M0_INSC)
	aParamFil[6] := ""

	aAdd(aFiliais,aParamFil)

Return aFiliais

Function TafMCountBrw(oBrowseMark)

	Local cQuery := ""
	Local nRegs  := 0
	Local oDataMark := Nil

	oDataMark := oBrowseMark:Data()


	//Conta Itens Selecionados no browse do Trabalhador
	cQuery := " SELECT COUNT(*) NREGS "
	cQuery += " FROM  " + oDataMark:oTempDB:GetRealName()
	cQuery += " WHERE MARK  != '  ' "

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),'evtCount', .F., .T. )

	nRegs :=  evtCount->NREGS
	evtCount->(dbCloseArea())


Return nRegs

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFMAJREC

Realiza Ajuste dos eventos e-Social que est�o com status 3 porem
contem protocolo

@param lMsgRun - Determina se deve fazer a chamada da fun��o
utilizando o objeto FWMsgRun.

@Author		Evandro dos Santos Oliveira
@Since		02/10/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFMAJREC(lMsgRun,oMsgRun)

	Default lMsgRun := .T. 

	If lMsgRun .Or. !IsBlind()
		FWMsgRun(,{|oMsgRun|ProcAjRec(oMsgRun)},"Rotina de Ajuste de Status Autorizado","Realizando Processamento ...")
	Else
		ProcAjRec(oMsgRun)
	EndIf 


Return Nil 

//---------------------------------------------------------------------
/*/{Protheus.doc} ProcAjRec

Realiza o processameto da fun��o TAFMAJREC, varrendo o TAFROTINAs
e realizando update para status 4 para todos os campos com protocolo
e status 3.

@Author		Evandro dos Santos Oliveira
@Since		02/10/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ProcAjRec(oMsgRun)

	Local nX := 0
	Local aEvts	:= {}
	Local cAliasTab := ""
	Local cLay := ""
	Local cQuery := ""
	Local cErroSQL := ""
	Local cMsg := ""
	Local cTipoEvt := ""

	aEvts := TAFRotinas(,,.T.,2)

	For nX := 1 To Len(aEvts)

		cAliasTab := AllTrim(aEvts[nX][3])
		cLay := AllTrim(aEvts[nX][4])
		cTipoEvt := AllTrim(aEvts[nX][12])

		If cTipoEvt $ " CEM " .And. !Empty(cLay) .And. TAFAlsInDic(cAliasTab)

			cMsg := "Verificando evento " + cLay	
			If ValType(oMsgRun) == "O"
				IncMessagens(oMsgRun,cMsg)
			EndIf 

			cQuery := " UPDATE " + RetSqlName(cAliasTab)
			cQuery += " SET " 	 + cAliasTab + "_STATUS = '4' "
			cQuery += " WHERE "  + cAliasTab + "_STATUS != '4' "
			cQuery += " AND " 	 + cAliasTab + "_PROTUL != '" + PADR(' ',GetSx3Cache(cAliasTab + "_PROTUL","X3_TAMANHO")) + "'"

			If TCSQLExec (cQuery) < 0
				cErroSQL := TCSQLError()
			EndIf
			
		EndIf

	Next nX

Return Nil 

//---------------------------------------------------------------------
/*/{Protheus.doc} IncMessagens

Atualiza o label do objeto FWMSGRUN

@Author		Evandro dos Santos Oliveira
@Since		02/10/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function IncMessagens(oMsgRun,cMsg)

    oMsgRun:cCaption := cMsg
    ProcessMessages()

Return Nil 

//---------------------------------------------------------------------
/*/{Protheus.doc} Transm2230
@type			function
@description	Inteface para transmiss�o dos registros do evento de afastamento ( S-2230 ).
@author			Felipe C. Seolin
@since			12/11/2018
@param			oDlgMon		-	Objeto da interface de painel de eventos
@param			oTabFilSel	-	Armazena as filiais selecionadas por tabelas de evento
/*/
//---------------------------------------------------------------------
Static Function Transm2230( oDlgMon, oTabFilSel )

Local oDialog	:=	Nil
Local oLayer	:=	Nil
Local oBrwTrab	:=	Nil
Local oBrwAfas	:=	Nil
Local oTempTrab	:=	Nil
Local oTempAfas	:=	Nil
Local aSize		:=	FWGetDialogSize( oMainWnd )

oDialog := MsDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], "Transmiss�o S-2230",,,, nOr( WS_VISIBLE, WS_POPUP ),,,,, .T.,,,, .F. )

oLayer := FWLayer():New()

oLayer:Init( oDialog, .F. )

oLayer:AddLine( "LINE01", 100 )

oLayer:AddCollumn( "BOX01", 45,, "LINE01" )
oLayer:AddCollumn( "BOX02", 45,, "LINE01" )
oLayer:AddCollumn( "BOX03", 10,, "LINE01" )

oLayer:AddWindow( "BOX01", "PANEL01", "Trabalhadores", 100, .F.,,, "LINE01" )
oLayer:AddWindow( "BOX02", "PANEL02", "Afastamentos",100, .F.,,, "LINE01" )
oLayer:AddWindow( "BOX03", "PANEL03", "A��es", 100, .F.,,, "LINE01" )

FPanel01( oLayer, @oBrwTrab, @oBrwAfas, @oTempTrab, @oTempAfas, @oTabFilSel ) //Constru��o do Painel de Trabalhadores
FPanel02( oLayer, @oBrwAfas, oBrwTrab, @oTempAfas ) //Constru��o do Painel de Afastamentos dos Trabalhadores
FPanel03( oDlgMon, oDialog, oLayer, @oBrwTrab, oBrwAfas, oTabFilSel ) //Constru��o do Painel de A��es

oDialog:Activate()

TAFEncArr( @aSize )

oTempTrab:Delete()
oTempAfas:Delete()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FPanel01
@type			function
@description	Constru��o do Painel de Trabalhadores com pend�ncias de Afastamentos.
@author			Felipe C. Seolin
@since			12/11/2018
@param			oLayer		-	Objeto para constru��o da interface
@param			oBrwTrab	-	Browse com as informa��es dos Trabalhadores ( Refer�ncia )
@param			oBrwAfas	-	Browse com as informa��es dos Afastamentos do Trabalhador ( Refer�ncia )
@param			oTempTrab	-	Tabela Tempor�ria com as informa��es dos Trabalhadores ( Refer�ncia )
@param			oTempAfas	-	Tabela Tempor�ria com as informa��es dos Afastamentos do Trabalhador ( Refer�ncia )
@param			oTabFilSel	-	Armazena as filiais selecionadas por tabelas de evento ( Refer�ncia )
/*/
//---------------------------------------------------------------------
Static Function FPanel01( oLayer, oBrwTrab, oBrwAfas, oTempTrab, oTempAfas, oTabFilSel )

Local oPanel		:=	oLayer:GetWinPanel( "BOX01", "PANEL01", "LINE01" )
Local oColumn		:=	Nil
Local cAlias		:=	""
Local cAliasQry		:=	GetNextAlias()
Local cQuery		:=	""
Local cCombo		:=	""
Local cFilPar		:=	""
Local nI			:=	0
Local nPos			:=	0
Local aColumnTmp	:=	{ "C9V_FILIAL", "C9V_ID", "C9V_CPF", "C9V_NOME" }
Local aStructTmp	:=	{}
Local aFieldsTmp	:=	{}
Local aColumnBrw	:=	{ "C9V_FILIAL", "C9V_ID", "C9V_CPF", "C9V_NOME" }
Local aStructBrw	:=	{}
Local aFieldsBrw	:=	{}
Local aStructC9V	:=	C9V->( DBStruct() )
Local aCombo		:=	{}
Local aAreaSX3		:=	SX3->( GetArea() )

For nI := 1 to Len( aStructC9V )
	If aScan( aColumnTmp, { |x| AllTrim( x ) == AllTrim( aStructC9V[nI,1] ) } ) > 0
		aAdd( aStructTmp, { aStructC9V[nI,1], aStructC9V[nI,2], aStructC9V[nI,3], aStructC9V[nI,4] } )
	EndIf
Next nI

For nI := 1 to Len( aColumnTmp )
	nPos := aScan( aStructTmp, { |x| AllTrim( x[1] ) == aColumnTmp[nI] } )
	If nPos > 0
		aAdd( aFieldsTmp, aStructTmp[nPos] )
	EndIf
Next nI

oTempTrab := FWTemporaryTable():New()
oTempTrab:SetFields( aFieldsTmp )
oTempTrab:AddIndex( "01", { "C9V_ID" } )
oTempTrab:AddIndex( "02", { "C9V_CPF" } )
oTempTrab:AddIndex( "03", { "C9V_NOME" } )
oTempTrab:Create()

cAlias := oTempTrab:GetAlias()

cFilPar := TafMonPFil( "CM6", @oTabFilSel )

cQuery := "SELECT C9V.C9V_FILIAL, C9V.C9V_ID, C9V.C9V_CPF, C9V.C9V_NOME "
cQuery += "FROM " + RetSqlName( "CM6" ) + " CM6 "
cQuery += "LEFT JOIN " + RetSqlName( "C9V" ) + " C9V "
cQuery += "  ON C9V.C9V_FILIAL = CM6.CM6_FILIAL "
cQuery += " AND C9V.C9V_ID = CM6.CM6_FUNC "
cQuery += " AND C9V.C9V_ATIVO = '1' "
cQuery += " AND C9V.D_E_L_E_T_ = '' "
cQuery += "WHERE CM6.CM6_FILIAL IN ( " + cFilPar + " ) "
cQuery += "  AND ( CM6.CM6_ATIVO = '1' OR CM6.CM6_STASEC = 'E' ) "
cQuery += "  AND CM6.CM6_EVENTO <> 'E' "
cQuery += "  AND CM6.CM6_STATUS IN ( ' ', '0', '1', '2', '3' ) "
cQuery += "  AND CM6.D_E_L_E_T_ = '' "
cQuery += "GROUP BY C9V.C9V_FILIAL, C9V.C9V_ID, C9V.C9V_CPF, C9V.C9V_NOME "

cQuery := ChangeQuery( cQuery )

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

While ( cAliasQry )->( !Eof() )
	If RecLock( cAlias, .T. )
		( cAlias )->C9V_FILIAL	:= ( cAliasQry )->C9V_FILIAL
		( cAlias )->C9V_ID		:= ( cAliasQry )->C9V_ID
		( cAlias )->C9V_CPF		:= ( cAliasQry )->C9V_CPF
		( cAlias )->C9V_NOME	:= ( cAliasQry )->C9V_NOME
		( cAlias )->( MsUnlock() )
	EndIf
	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

For nI := 1 to Len( aStructC9V )
	If aScan( aColumnBrw, { |x| AllTrim( x ) == AllTrim( aStructC9V[nI,1] ) } ) > 0
		oColumn := FWBrwColumn():New()
		oColumn:SetData( &( "{ || " + aStructC9V[nI,1] + " }" ) )
		oColumn:SetTitle( RetTitle( aStructC9V[nI,1] ) )
		oColumn:SetSize( aStructC9V[nI,3] )
		oColumn:SetDecimal( aStructC9V[nI,4] )
		oColumn:SetPicture( PesqPict( SubStr( aStructC9V[nI,1], 1, At( "_", aStructC9V[nI,1] ) - 1 ), aStructC9V[nI,1] ) )
		oColumn:SetType( aStructC9V[nI,2] )
		oColumn:SetAlign( Iif( aStructC9V[nI,2] == "N", 2, 1 ) )

		If aStructC9V[nI,2] == "C"
			DBSelectArea( "SX3" )
			SX3->( DBSetOrder( 2 ) )
			If SX3->( MsSeek( aStructC9V[nI,1] ) )
				cCombo := X3Cbox()
			EndIf

			If !Empty( cCombo )
				aCombo := StrToKarr( cCombo, ";" )
				oColumn:SetOptions( aCombo )
				cCombo := ""
			EndIf
		EndIf

		aAdd( aStructBrw, { aStructC9V[nI,1], oColumn } )
	EndIf
Next nI

RestArea( aAreaSX3 )

For nI := 1 to Len( aColumnBrw )
	nPos := aScan( aStructBrw, { |x| AllTrim( x[1] ) == AllTrim( aColumnBrw[nI] ) } )
	If nPos > 0
		aAdd( aFieldsBrw, aStructBrw[nPos,2] )
	EndIf
Next nI

oBrwTrab := FWBrowse():New()
oBrwTrab:SetOwner( oPanel )
oBrwTrab:SetDataTable()
oBrwTrab:SetAlias( cAlias )
oBrwTrab:DisableReport()
oBrwTrab:DisableConfig()
oBrwTrab:SetSeek()
oBrwTrab:SetUseFilter()
oBrwTrab:SetColumns( aFieldsBrw )
oBrwTrab:SetChange( { || Iif( !Empty( oBrwAfas ), Processa( { || FChgPan02( @oBrwAfas, oBrwTrab ), "Processando", "Construindo Interface" } ), Nil ) } )
oBrwTrab:Activate()

TAFEncArr( @aColumnTmp )
TAFEncArr( @aStructTmp )
TAFEncArr( @aFieldsTmp )
TAFEncArr( @aColumnBrw )
TAFEncArr( @aStructBrw )
TAFEncArr( @aFieldsBrw )
TAFEncArr( @aStructC9V )
TAFEncArr( @aCombo )
TAFEncArr( @aAreaSX3 )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FChgPan01
@type			function
@description	Atualiza��o do Painel de Trabalhadores com pend�ncias de Afastamentos na consulta de transmiss�o.
@author			Felipe C. Seolin
@since			21/11/2018
@param			oBrwTrab	-	Browse com as informa��es dos Trabalhadores ( Refer�ncia )
@param			oTabFilSel	-	Armazena as filiais selecionadas por tabelas de evento
/*/
//---------------------------------------------------------------------
Static Function FChgPan01( oBrwTrab, oTabFilSel )

Local cAlias	:=	oBrwTrab:Alias()
Local cAliasQry	:=	GetNextAlias()
Local cQuery	:=	""
Local cFilPar	:=	""

( cAlias )->( DBGoTop() )
While ( cAlias )->( !Eof() )
	If RecLock( cAlias, .F. )
		( cAlias )->( DBDelete() )
		( cAlias )->( MsUnlock() )
	EndIf
	( cAlias )->( DBSkip() )
EndDo

cFilPar := TafMonPFil( "CM6", @oTabFilSel )

cQuery := "SELECT C9V.C9V_FILIAL, C9V.C9V_ID, C9V.C9V_CPF, C9V.C9V_NOME "
cQuery += "FROM " + RetSqlName( "CM6" ) + " CM6 "
cQuery += "LEFT JOIN " + RetSqlName( "C9V" ) + " C9V "
cQuery += "  ON C9V.C9V_FILIAL = CM6.CM6_FILIAL "
cQuery += " AND C9V.C9V_ID = CM6.CM6_FUNC "
cQuery += " AND C9V.C9V_ATIVO = '1' "
cQuery += " AND C9V.D_E_L_E_T_ = '' "
cQuery += "WHERE CM6.CM6_FILIAL IN ( " + cFilPar + " ) "
cQuery += "  AND ( CM6.CM6_ATIVO = '1' OR CM6.CM6_STASEC = 'E' ) "
cQuery += "  AND CM6.CM6_EVENTO <> 'E' "
cQuery += "  AND CM6.CM6_STATUS IN ( ' ', '0', '1', '2', '3' ) "
cQuery += "  AND CM6.D_E_L_E_T_ = '' "
cQuery += "GROUP BY C9V.C9V_FILIAL, C9V.C9V_ID, C9V.C9V_CPF, C9V.C9V_NOME "

cQuery := ChangeQuery( cQuery )

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

While ( cAliasQry )->( !Eof() )
	If RecLock( cAlias, .T. )
		( cAlias )->C9V_FILIAL	:= ( cAliasQry )->C9V_FILIAL
		( cAlias )->C9V_ID		:= ( cAliasQry )->C9V_ID
		( cAlias )->C9V_CPF		:= ( cAliasQry )->C9V_CPF
		( cAlias )->C9V_NOME	:= ( cAliasQry )->C9V_NOME
		( cAlias )->( MsUnlock() )
	EndIf
	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

oBrwTrab:SetAlias( cAlias )
oBrwTrab:Refresh( .T. )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FPanel02
@type			function
@description	Constru��o do Painel de Afastamentos por Trabalhador.
@author			Felipe C. Seolin
@since			13/11/2018
@param			oLayer		-	Objeto para constru��o da interface
@param			oBrwAfas	-	Browse com as informa��es dos Afastamentos do Trabalhador ( Refer�ncia )
@param			oBrwTrab	-	Browse com as informa��es dos Trabalhadores
@param			oTempAfas	-	Tabela Tempor�ria com as informa��es dos Afastamentos do Trabalhador ( Refer�ncia )
/*/
//---------------------------------------------------------------------
Static Function FPanel02( oLayer, oBrwAfas, oBrwTrab, oTempAfas )

Local oPanel		:=	oLayer:GetWinPanel( "BOX02", "PANEL02", "LINE01" )
Local oColumn		:=	Nil
Local cAlias		:=	""
Local cAliasQry		:=	GetNextAlias()
Local cQuery		:=	""
Local nI			:=	0
Local nPos			:=	0
Local aColumnTmp	:=	{ "CM6_ID", "CM6_DTAFAS", "CM6_DTFAFA", "CM6_XMLREC", "CM6_EVENTO", "CM6_STATUS", "RECNO", "DATAEVT" }
Local aStructTmp	:=	{}
Local aFieldsTmp	:=	{}
Local aColumnBrw	:=	{ "CM6_ID", "CM6_DTAFAS", "CM6_DTFAFA", "CM6_XMLREC", "CM6_EVENTO" }
Local aStructBrw	:=	{}
Local aFieldsBrw	:=	{}
Local aStructCM6	:=	CM6->( DBStruct() )
Local aCombo		:=	{}
Local aAreaSX3		:=	SX3->( GetArea() )

For nI := 1 to Len( aStructCM6 )
	If aScan( aColumnTmp, { |x| AllTrim( x ) == AllTrim( aStructCM6[nI,1] ) } ) > 0
		aAdd( aStructTmp, { aStructCM6[nI,1], aStructCM6[nI,2], aStructCM6[nI,3], aStructCM6[nI,4] } )
	EndIf
Next nI

aAdd( aStructTmp, { "RECNO", "N", 8, 0 } )

If ( nPos := aScan( aStructCM6, { |x| AllTrim( x[1] ) == "CM6_DTAFAS" } ) ) > 0
	aAdd( aStructTmp, { "DATAEVT", aStructCM6[nPos,2], aStructCM6[nPos,3], aStructCM6[nPos,4] } )
EndIf

For nI := 1 to Len( aColumnTmp )
	nPos := aScan( aStructTmp, { |x| AllTrim( x[1] ) == aColumnTmp[nI] } )
	If nPos > 0
		aAdd( aFieldsTmp, aStructTmp[nPos] )
	EndIf
Next nI

oTempAfas := FWTemporaryTable():New()
oTempAfas:SetFields( aFieldsTmp )
oTempAfas:Create()

cAlias := oTempAfas:GetAlias()

cQuery := "SELECT CM6.CM6_ID, CM6.CM6_DTAFAS, CM6.CM6_DTFAFA, CM6.CM6_XMLREC, CM6.CM6_EVENTO, CM6.CM6_STATUS, CM6.R_E_C_N_O_ RECNO "
cQuery += ",CASE WHEN CM6.CM6_EVENTO = 'F' THEN CM6.CM6_DTFAFA "
cQuery += "       ELSE CM6.CM6_DTAFAS "
cQuery += "  END DATAEVT "
cQuery += "FROM " + RetSqlName( "CM6" ) + " CM6 "
cQuery += "WHERE CM6.CM6_FILIAL = '" + ( oBrwTrab:Alias() )->C9V_FILIAL + "' "
cQuery += "  AND CM6.CM6_FUNC = '" + ( oBrwTrab:Alias() )->C9V_ID + "' "
cQuery += "  AND CM6.D_E_L_E_T_ = '' "
cQuery += "ORDER BY DATAEVT, RECNO "

cQuery := ChangeQuery( cQuery )

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

TCSetField( cAliasQry, "CM6_DTAFAS", "D" )
TCSetField( cAliasQry, "CM6_DTFAFA", "D" )
TCSetField( cAliasQry, "DATAEVT", "D" )

While ( cAliasQry )->( !Eof() )
	If RecLock( cAlias, .T. )
		( cAlias )->CM6_ID		:= ( cAliasQry )->CM6_ID
		( cAlias )->CM6_DTAFAS	:= ( cAliasQry )->CM6_DTAFAS
		( cAlias )->CM6_DTFAFA	:= ( cAliasQry )->CM6_DTFAFA
		( cAlias )->CM6_XMLREC	:= ( cAliasQry )->CM6_XMLREC
		( cAlias )->CM6_EVENTO	:= ( cAliasQry )->CM6_EVENTO
		( cAlias )->CM6_STATUS	:= ( cAliasQry )->CM6_STATUS
		( cAlias )->RECNO		:= ( cAliasQry )->RECNO
		( cAlias )->DATAEVT		:= ( cAliasQry )->DATAEVT
		( cAlias )->( MsUnlock() )
	EndIf
	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

For nI := 1 to Len( aStructCM6 )
	If aScan( aColumnBrw, { |x| AllTrim( x ) == AllTrim( aStructCM6[nI,1] ) } ) > 0
		oColumn := FWBrwColumn():New()
		oColumn:SetData( &( "{ || " + aStructCM6[nI,1] + " }" ) )
		oColumn:SetTitle( RetTitle( aStructCM6[nI,1] ) )
		oColumn:SetSize( aStructCM6[nI,3] )
		oColumn:SetDecimal( aStructCM6[nI,4] )
		oColumn:SetPicture( PesqPict( SubStr( aStructCM6[nI,1], 1, At( "_", aStructCM6[nI,1] ) - 1 ), aStructCM6[nI,1] ) )
		oColumn:SetType( aStructCM6[nI,2] )
		oColumn:SetAlign( Iif( aStructCM6[nI,2] == "N", 2, 1 ) )

		If aStructCM6[nI,1] == "CM6_XMLREC"
			oColumn:SetOptions( { "INIC=In�cio", "COMP=Completo", "TERM=T�rmino" } )
		ElseIf aStructCM6[nI,1] == "CM6_EVENTO"
			oColumn:SetOptions( { "I=Inclus�o", "A=Altera��o", "E=Exclus�o", "R=Retifica��o", "F=Finaliza��o" } )
		EndIf

		aAdd( aStructBrw, { aStructCM6[nI,1], oColumn } )
	EndIf
Next nI

RestArea( aAreaSX3 )

For nI := 1 to Len( aColumnBrw )
	nPos := aScan( aStructBrw, { |x| AllTrim( x[1] ) == AllTrim( aColumnBrw[nI] ) } )
	If nPos > 0
		aAdd( aFieldsBrw, aStructBrw[nPos,2] )
	EndIf
Next nI

oBrwAfas := FWBrowse():New()
oBrwAfas:SetOwner( oPanel )
oBrwAfas:SetDataTable()
oBrwAfas:SetAlias( cAlias )
oBrwAfas:DisableReport()
oBrwAfas:DisableConfig()
oBrwAfas:SetSeek()
oBrwAfas:SetUseFilter()
oBrwAfas:AddLegend( "CM6_STATUS $ ' 01'"	, "WHITE"	, "Pronto para Transmiss�o" )
oBrwAfas:AddLegend( "CM6_STATUS == '2'"		, "BLUE"	, "Aguardando Retorno de Transmiss�o" )
oBrwAfas:AddLegend( "CM6_STATUS == '3'"		, "RED"		, "Transmiss�o com Inconsist�ncia" )
oBrwAfas:AddLegend( "CM6_STATUS == '4'"		, "GREEN"	, "Transmiss�o com Sucesso" )
oBrwAfas:AddLegend( "CM6_STATUS == '6'"		, "GRAY"	, "Aguardando Retorno da Transmiss�o do Evento S-3000" )
oBrwAfas:AddLegend( "CM6_STATUS == '7'"		, "BLACK"	, "Transmiss�o do Evento S-3000 com Sucesso" )
oBrwAfas:SetColumns( aFieldsBrw )
oBrwAfas:Activate()

TAFEncArr( @aColumnTmp )
TAFEncArr( @aStructTmp )
TAFEncArr( @aFieldsTmp )
TAFEncArr( @aColumnBrw )
TAFEncArr( @aStructBrw )
TAFEncArr( @aFieldsBrw )
TAFEncArr( @aStructCM6 )
TAFEncArr( @aCombo )
TAFEncArr( @aAreaSX3 )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FChgPan02
@type			function
@description	Atualiza��o do Painel de Afastamentos por Trabalhador na sele��o de outro Trabalhador.
@author			Felipe C. Seolin
@since			13/11/2018
@param			oBrwAfas	-	Browse com as informa��es dos Afastamentos do Trabalhador ( Refer�ncia )
@param			oBrwTrab	-	Browse com as informa��es dos Trabalhadores
/*/
//---------------------------------------------------------------------
Static Function FChgPan02( oBrwAfas, oBrwTrab )

Local cAlias	:=	oBrwAfas:Alias()
Local cAliasQry	:=	GetNextAlias()
Local cQuery	:=	""

( cAlias )->( DBGoTop() )
While ( cAlias )->( !Eof() )
	If RecLock( cAlias, .F. )
		( cAlias )->( DBDelete() )
		( cAlias )->( MsUnlock() )
	EndIf
	( cAlias )->( DBSkip() )
EndDo

cQuery := "SELECT CM6.CM6_ID, CM6.CM6_DTAFAS, CM6.CM6_DTFAFA, CM6.CM6_XMLREC, CM6.CM6_EVENTO, CM6.CM6_STATUS, CM6.R_E_C_N_O_ RECNO "
cQuery += ",CASE WHEN CM6.CM6_EVENTO = 'F' THEN CM6.CM6_DTFAFA "
cQuery += "       ELSE CM6.CM6_DTAFAS "
cQuery += "  END DATAEVT "
cQuery += "FROM " + RetSqlName( "CM6" ) + " CM6 "
cQuery += "WHERE CM6.CM6_FILIAL = '" + ( oBrwTrab:Alias() )->C9V_FILIAL + "' "
cQuery += "  AND CM6.CM6_FUNC = '" + ( oBrwTrab:Alias() )->C9V_ID + "' "
cQuery += "  AND CM6.D_E_L_E_T_ = '' "
cQuery += "ORDER BY DATAEVT, RECNO "

cQuery := ChangeQuery( cQuery )

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

TCSetField( cAliasQry, "CM6_DTAFAS", "D" )
TCSetField( cAliasQry, "CM6_DTFAFA", "D" )
TCSetField( cAliasQry, "DATAEVT", "D" )

While ( cAliasQry )->( !Eof() )
	If RecLock( cAlias, .T. )
		( cAlias )->CM6_ID		:= ( cAliasQry )->CM6_ID
		( cAlias )->CM6_DTAFAS	:= ( cAliasQry )->CM6_DTAFAS
		( cAlias )->CM6_DTFAFA	:= ( cAliasQry )->CM6_DTFAFA
		( cAlias )->CM6_XMLREC	:= ( cAliasQry )->CM6_XMLREC
		( cAlias )->CM6_EVENTO	:= ( cAliasQry )->CM6_EVENTO
		( cAlias )->CM6_STATUS	:= ( cAliasQry )->CM6_STATUS
		( cAlias )->RECNO		:= ( cAliasQry )->RECNO
		( cAlias )->DATAEVT		:= ( cAliasQry )->DATAEVT
		( cAlias )->( MsUnlock() )
	EndIf
	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

oBrwAfas:SetAlias( cAlias )
oBrwAfas:Refresh( .T. )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FPanel03
@type			function
@description	Constru��o do Painel de A��es.
@author			Felipe C. Seolin
@since			14/11/2018
@param			oDlgMon		-	Objeto da interface de painel de eventos
@param			oDialog		-	Objeto da inteface para transmiss�o dos registros do evento de afastamento ( S-2230 ).
@param			oLayer		-	Objeto para constru��o da interface
@param			oBrwTrab	-	Browse com as informa��es dos Trabalhadores ( Refer�ncia )
@param			oBrwAfas	-	Browse com as informa��es dos Afastamentos do Trabalhador
@param			oTabFilSel	-	Armazena as filiais selecionadas por tabelas de evento
/*/
//---------------------------------------------------------------------
Static Function FPanel03( oDlgMon, oDialog, oLayer, oBrwTrab, oBrwAfas, oTabFilSel )

Local oPanel	:=	oLayer:GetWinPanel( "BOX03", "PANEL03", "LINE01" )
Local bTransmit	:=	{ || FWMsgRun( ,{ |oMsgRun| ( FTransmit( oMsgRun, oBrwTrab ), FChgPan01( @oBrwTrab, oTabFilSel ) ) }, "Transmitindo", "Aguarde..." ) }
Local bConsult	:=	{ || FWMsgRun( ,{ |oMsgRun| ( FConsult( oMsgRun, oBrwTrab ), FChgPan01( @oBrwTrab, oTabFilSel ) ) }, "Consultando", "Aguarde..." ) }
Local bCheck	:=	{ || FWMsgRun( ,{ || FCheck( oBrwAfas ) }, "Verificando", "Aguarde..." ) }
Local bClose	:=	{ || ( oDialog:End(), oDlgMon:End() ) }

TButton():New( 005, 005, "Transmitir", oPanel, bTransmit, 050, 015,,,, .T. )
TButton():New( 025, 005, "Consultar", oPanel, bConsult, 050, 015,,,, .T. )
TButton():New( 045, 005, "Verificar", oPanel, bCheck, 050, 015,,,, .T. )
TButton():New( 065, 005, "Fechar", oPanel, bClose, 050, 015,,,, .T. )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FTransmit
@type			function
@description	Realiza a transmiss�o dos registros de afastamentos pendentes que n�o possuem predecessor pendente.
@author			Felipe C. Seolin
@since			14/11/2018
@param			oMsgRun		-	Objeto do FWMsgRun
@param			oBrwTrab	-	Browse com as informa��es dos Trabalhadores
@return			lRet		-	Indica se a transmiss�o foi executada com sucesso
/*/
//---------------------------------------------------------------------
Static Function FTransmit( oMsgRun, oBrwTrab )

Local oSocial		:=	Nil
Local cURL			:=	AllTrim( PadR( TAFGetUrlTSS(), 250 ) )
Local cUserTk		:=	"TOTVS"
Local cIDEnt		:=	TAFRIDEnt( ,,,,, .T. )
Local cAmbES		:=	GetNewPar( "MV_TAFAMBE", "2" )
Local cVerSchema	:=	IIF(TafLayESoc("S_01_00_00"),'S_01_00_00','02_05_00')
Local cTSSID		:=	""
Local cMessage		:=	""
Local nI			:=	0
Local nJ			:=	0
Local nPos			:=	0
Local nQtdLote		:=	0
Local nLote			:=	1
Local aXmls			:=	FGetXmls( oBrwTrab, "TRANSMIT" )
Local aRetorno		:=	{}
Local lBuildWS		:=	.T.
Local lRetTransm	:=	.F.
Local lRet			:=	.F.

If !( "TSSWSSOCIAL.APW" $ Upper( cURL ) )
	cURL += "/TSSWSSOCIAL.apw"
EndIf

If !FVldTransm( oBrwTrab )
	lRet := .F.
	cMessage := "Opera��o n�o permitida enquanto houver registros aguardando retorno do governo."
ElseIf Empty( aXmls )
	lRet := .F.
	cMessage := "N�o h� registros para transmiss�o."
ElseIf Empty( cURL )
	lRet := .F.
	cMessage := "URL do servi�o do TSS n�o informado no par�metro 'MV_TAFSURL': '" + cURL + "'"
ElseIf Empty( cIDEnt )
	lRet := .F.
	cMessage := "Entidade do TSS n�o localizado: '" + cIDEnt + "'"
ElseIf Empty( cAmbES )
	lRet := .F.
	cMessage := "Ambiente de transmiss�o do eSocial n�o informado no par�metro 'MV_TAFAMBE': '" + cAmbES + "'"
ElseIf Empty( cVerSchema )
	lRet := .F.
	cMessage := "Vers�o do Schema de transmiss�o do eSocial n�o informado no par�metro 'MV_TAFVLES': '" + cVerSchema + "'"
Else
	For nI := 1 to Len( aXmls )
		If lBuildWS
			oSocial := WSTSSWSSOCIAL():New()
			oSocial:_Url := cURL
			oSocial:oWSENTENVDADOS:cUSERTOKEN := cUserTk
			oSocial:oWSENTENVDADOS:cID_ENT := cIDEnt
			oSocial:oWSENTENVDADOS:cAMBIENTE := cAmbES
			oSocial:oWSENTENVDADOS:oWSENTENVDOCS := WsClassNew( "TSSWSSOCIAL_ARRAYOFENTENVDOC" )
			oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC := {}

			lBuildWS := .F.
		EndIf

		aAdd( oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC, WsClassNew( "TSSWSSOCIAL_ENTENVDOC" ) )
		aTail( oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC ):CCODIGO := "S-2230"
		aTail( oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC ):CID := aXmls[nI,1]
		aTail( oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC ):CXML := aXmls[nI,2]
		aTail( oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC ):CVERSAO := cVerSchema

		nQtdLote ++

		If nQtdLote == 50 .or. nI == Len( aXmls )
			lRetTransm := oSocial:EnviarDocumentos()

			If ValType( lRetTransm ) == "L"
				If lRetTransm
					If ValType( oSocial:oWSENVIARDOCUMENTOSRESULT:oWSSAIDAENVDOCS ) <> "U"
						lRet := .T.
					Else
						lRet := .F.
						cMessage += "Lote " + AllTrim( Str( nLote ) ) + " n�o foi transmitido com sucesso devido ao problema relatado abaixo. Favor transmitir novamente os registros."
						cMessage += Chr( 13 ) + Chr( 10 )
						cMessage += "Problema: Tipo de dado indefinido no retorno da transmiss�o."
						cMessage += Chr( 13 ) + Chr( 10 )
						cMessage += Chr( 13 ) + Chr( 10 )
					EndIf
				Else
					lRet := .F.
					cMessage += "Lote " + AllTrim( Str( nLote ) ) + " n�o foi transmitido com sucesso devido ao problema relatado abaixo. Favor transmitir novamente os registros."
					cMessage += Chr( 13 ) + Chr( 10 )
					cMessage += "Problema: Servidor TSS n�o conseguiu processar a requisi��o."
					cMessage += Chr( 13 ) + Chr( 10 )
					cMessage += Chr( 13 ) + Chr( 10 )
				EndIf
			Else
				lRet := .F.
				cMessage += "Lote " + AllTrim( Str( nLote ) ) + " n�o foi transmitido com sucesso devido ao problema relatado abaixo. Favor transmitir novamente os registros."
				cMessage += Chr( 13 ) + Chr( 10 )
				cMessage += "Problema: Retorno da transmiss�o n�o � do tipo l�gico."
				cMessage += Chr( 13 ) + Chr( 10 )
				cMessage += Chr( 13 ) + Chr( 10 )
			EndIf

			If lRet
				aRetorno := oSocial:oWSENVIARDOCUMENTOSRESULT:oWSSAIDAENVDOCS:oWSSAIDAENVDOC

				Begin Transaction
					For nJ := 1 to Len( aRetorno )
						cTSSID := AllTrim( aRetorno[nJ]:CID )

						If ( nPos := aScan( aXmls, { |x| AllTrim( x[1] ) == AllTrim( cTSSID ) } ) ) > 0
							CM6->( DBGoTo( aXmls[nPos,3] ) )
							If RecLock( "CM6", .F. )
								If aRetorno[nJ]:LSUCESSO
									CM6->CM6_STATUS := "2"
								Else
									CM6->CM6_STATUS := "3"
								EndIf

								CM6->( MsUnlock() )
							EndIf
						EndIf
					Next nJ
				End Transaction
			EndIf

			nQtdLote := 0
			lBuildWS := .T.
			nLote ++
		EndIf

		SetIncPerc( oMsgRun, "Transmitindo", Len( aXmls ), nI )
	Next nI
EndIf

If !lRet .or. !Empty( cMessage )
	MsgInfo( cMessage )
EndIf

TAFEncArr( @aXmls )
TAFEncArr( @aRetorno )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} FVldTransm
@type			function
@description	Valida a permiss�o da opera��o de transmiss�o.
@author			Felipe C. Seolin
@since			21/11/2018
@param			oBrwTrab	-	Browse com as informa��es dos Trabalhadores
@return			lRet		-	Indica se a opera��o de transmiss�o � v�lida
/*/
//---------------------------------------------------------------------
Static Function FVldTransm( oBrwTrab )

Local cAlias	:=	oBrwTrab:Alias()
Local cAliasQry	:=	""
Local cQuery	:=	""
Local aArea		:=	( cAlias )->( GetArea() )
Local lRet		:=	.T.

( cAlias )->( DBGoTop() )
While ( cAlias )->( !Eof() ) .and. lRet
	cAliasQry := GetNextAlias()

	cQuery := "SELECT CM6.CM6_STATUS "
	cQuery += "FROM " + RetSqlName( "CM6" ) + " CM6 "
	cQuery += "WHERE CM6.CM6_FILIAL = '" + ( cAlias )->C9V_FILIAL + "' "
	cQuery += "  AND CM6.CM6_FUNC = '" + ( cAlias )->C9V_ID + "' "
	cQuery += "  AND CM6.CM6_STATUS = '2' "
	cQuery += "  AND CM6.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery( cQuery )

	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

	If ( cAliasQry )->( !Eof() )
		lRet := .F.
	EndIf

	( cAliasQry )->( DBCloseArea() )

	( cAlias )->( DBSkip() )
EndDo

RestArea( aArea )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} FGetXmls
@type			function
@description	Empacotamento das informa��es do evento de Afastamento ( S-2230 ) a serem transmitidas.
@author			Felipe C. Seolin
@since			15/11/2018
@param			oBrwTrab	-	Browse com as informa��es dos Trabalhadores
@param			cOper		-	Opera��o em execu��o
@return			aXmls		-	Array com o arquivo XML, o XMLID e o RECNO de cada informa��o a ser transmitida
/*/
//---------------------------------------------------------------------
Static Function FGetXmls( oBrwTrab, cOper )

Local cAlias	:=	oBrwTrab:Alias()
Local cAliasQry	:=	""
Local cQuery	:=	""
Local cTSSID	:=	""
Local cXml		:=	""
Local cFilBkp	:=	""
Local aArea		:=	( cAlias )->( GetArea() )
Local aXmls		:=	{}
Local lLoop		:=	.T.

( cAlias )->( DBGoTop() )
While ( cAlias )->( !Eof() )
	cAliasQry := GetNextAlias()

	cQuery := "SELECT CM6.CM6_FILIAL, CM6.CM6_ID, CM6.CM6_VERSAO, CM6.CM6_XMLREC, CM6.CM6_STATUS, CM6.R_E_C_N_O_ RECNO "
	cQuery += ",CASE WHEN CM6.CM6_EVENTO = 'F' THEN CM6.CM6_DTFAFA "
	cQuery += "       ELSE CM6.CM6_DTAFAS "
	cQuery += "  END DATAEVT "
	cQuery += "FROM " + RetSqlName( "CM6" ) + " CM6 "
	cQuery += "WHERE CM6.CM6_FILIAL = '" + ( cAlias )->C9V_FILIAL + "' "
	cQuery += "  AND CM6.CM6_FUNC = '" + ( cAlias )->C9V_ID + "' "
	cQuery += "  AND CM6.D_E_L_E_T_ = '' "
	cQuery += "ORDER BY DATAEVT, RECNO "

	cQuery := ChangeQuery( cQuery )

	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

	TCSetField( cAliasQry, "CM6_DTAFAS", "D" )
	TCSetField( cAliasQry, "CM6_DTFAFA", "D" )
	TCSetField( cAliasQry, "DATAEVT", "D" )

	While ( cAliasQry )->( !Eof() ) .and. lLoop
		If cOper == "TRANSMIT"
			If ( cAliasQry )->CM6_STATUS $ "26"
				lLoop := .F.
			ElseIf ( cAliasQry )->CM6_STATUS $ "47"
				lLoop := .T.
			Else
				cFilBkp := cFilAnt
				cFilAnt := ( cAliasQry )->CM6_FILIAL
				CM6->( DBGoTo( ( cAliasQry )->RECNO ) )
				cXml := TAF261Xml( "CM6", ( cAliasQry )->RECNO,, .T. )
				cTSSID := AllTrim( "S2230" + AllTrim( ( cAliasQry )->CM6_ID ) + AllTrim( ( cAliasQry )->CM6_VERSAO ) )

				aAdd( aXmls, { cTSSID, EncodeUTF8( cXml ), ( cAliasQry )->RECNO } )
				lLoop := .F.
				cFilAnt := cFilBkp
			EndIf
		ElseIf cOper == "CONSULT"
			If ( cAliasQry )->CM6_STATUS $ "2"
				cFilBkp := cFilAnt
				cFilAnt := ( cAliasQry )->CM6_FILIAL
				CM6->( DBGoTo( ( cAliasQry )->RECNO ) )
				cXml := TAF261Xml( "CM6", ( cAliasQry )->RECNO,, .T. )
				cTSSID := AllTrim( "S2230" + AllTrim( ( cAliasQry )->CM6_ID ) + AllTrim( ( cAliasQry )->CM6_VERSAO ) )

				aAdd( aXmls, { cTSSID, EncodeUTF8( cXml ), ( cAliasQry )->RECNO } )
				lLoop := .F.
				cFilAnt := cFilBkp
				lLoop := .F.
			Else
				lLoop := .T.
			EndIf
		EndIf

		( cAliasQry )->( DBSkip() )
	EndDo

	( cAliasQry )->( DBCloseArea() )

	lLoop := .T.

	( cAlias )->( DBSkip() )
EndDo

RestArea( aArea )

Return( aXmls )

//---------------------------------------------------------------------
/*/{Protheus.doc} FConsult
@type			function
@description	Realiza a consulta dos registros de afastamentos pendentes que n�o possuem predecessor pendente.
@author			Felipe C. Seolin
@since			14/11/2018
@param			oMsgRun		-	Objeto do FWMsgRun
@param			oBrwTrab	-	Browse com as informa��es dos Trabalhadores
@return			lRet		-	Indica se a consulta foi executada com sucesso
/*/
//---------------------------------------------------------------------
Static Function FConsult( oMsgRun, oBrwTrab )

Local oSocial	:=	Nil
Local cURL		:=	AllTrim( PadR( TAFGetUrlTSS(), 250 ) )
Local cUserTk	:=	"TOTVS"
Local cIDEnt	:=	TAFRIDEnt( ,,,,, .T. )
Local cAmbES	:=	GetNewPar( "MV_TAFAMBE", "2" )
Local cTSSID	:=	""
Local cStatus	:=	""
Local cAuxSts	:=	""
Local cRecibo	:=	""
Local nI		:=	0
Local nPos		:=	0
Local aXmls		:=	FGetXmls( oBrwTrab, "CONSULT" )
Local aRetorno	:=	{}
Local lRetCons	:=	.F.
Local lRet		:=	.F.

If !( "TSSWSSOCIAL.APW" $ Upper( cURL ) )
	cURL += "/TSSWSSOCIAL.apw"
EndIf

If Empty( aXmls )
	lRet := .F.
	MsgInfo( "N�o h� registros para consulta." )
ElseIf Empty( cURL )
	lRet := .F.
	MsgInfo( "URL do servi�o do TSS n�o informado no par�metro 'MV_TAFSURL': '" + cURL + "'" )
ElseIf Empty( cIDEnt )
	lRet := .F.
	MsgInfo( "Entidade do TSS n�o localizado: '" + cIDEnt + "'" )
ElseIf Empty( cAmbES )
	lRet := .F.
	MsgInfo( "Ambiente de transmiss�o do eSocial n�o informado no par�metro 'MV_TAFAMBE': '" + cAmbES + "'" )
Else
	oSocial := WSTSSWSSOCIAL():New()
	oSocial:_Url := cURL
	oSocial:oWSENTCONSDADOS:cAMBIENTE := cAmbES
	oSocial:oWSENTCONSDADOS:cID_ENT := cIDEnt
	oSocial:oWSENTCONSDADOS:cUSERTOKEN := cUserTk
	oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS := WsClassNew( "TSSWSSOCIAL_ARRAYOFENTCONSDOC" )
	oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC := {}

	For nI := 1 to Len( aXmls )
		aAdd( oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC, WsClassNew( "TSSWSSOCIAL_ENTCONSDOC" ) )
		aTail( oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC ):CCODIGO := "S-2230"
		aTail( oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC ):CID := aXmls[nI,1]
		aTail( oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC ):LRETORNAXML := .F.
		aTail( oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC ):LHISTPROC := .F.
	Next nI

	lRetCons := oSocial:consultarDocumentos()

	If ValType( lRetCons ) == "L"
		If lRetCons
			If ValType( oSocial:oWSCONSULTARDOCUMENTOSRESULT:oWSSAIDACONSDOCS ) <> "U"
				lRet := .T.
			Else
				lRet := .F.
				MsgInfo( "Tipo de dado indefinido no retorno da transmiss�o." )
			EndIf
		Else
			lRet := .F.
			MsgInfo( "Servidor TSS n�o conseguiu processar a requisi��o." )
		EndIf
	Else
		lRet := .F.
		MsgInfo( "Retorno da consulta n�o � do tipo l�gico." )
	EndIf

	If lRet
		aRetorno := oSocial:oWSCONSULTARDOCUMENTOSRESULT:oWSSAIDACONSDOCS:oWSSAIDACONSDOC

		Begin Transaction
			For nI := 1 to Len( aRetorno )
				cTSSID := AllTrim( aRetorno[nI]:CID )

				If ( nPos := aScan( aXmls, { |x| AllTrim( x[1] ) == AllTrim( cTSSID ) } ) ) > 0
					CM6->( DBGoTo( aXmls[nPos,3] ) )

					If aRetorno[nI]:LSUCESSO
						//Status de Retorno dos Documentos
						//1 � Recebido
						//2 � Assinado
						//3 � Erro de Schema
						//4 � Aguardando Transmiss�o
						//5 � Rejei��o
						//6 � Autorizado
						cStatus := aRetorno[nI]:CSTATUS
						cAuxSts := TAFStsXTSS( cStatus )
						cRecibo := AllTrim( aRetorno[nI]:CRECIBO )

						If !Empty( cAuxSts )
							If RecLock( "CM6", .F. )
								If CM6->CM6_STATUS <> "4"
									CM6->CM6_STATUS := cAuxSts
								EndIf

								If !Empty( cRecibo )
									CM6->CM6_PROTUL := cRecibo
								EndIf

								CM6->( MsUnlock() )
							EndIf
						EndIf
					Else
						If CM6->CM6_STATUS <> "4"
							If RecLock( "CM6", .F. )
								CM6->CM6_STATUS := "3"
								CM6->( MsUnlock() )
							EndIf
						EndIf
					EndIf
				EndIf

				SetIncPerc( oMsgRun, "Consultando", Len( aXmls ), nI )
			Next nI
		End Transaction
	EndIf
EndIf

TAFEncArr( @aXmls )
TAFEncArr( @aRetorno )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} FCheck
@type			function
@description	Realiza a consulta do registro de afastamento inconsistente.
@author			Felipe C. Seolin
@since			21/11/2018
@param			oBrwAfas	-	Browse com as informa��es dos Afastamentos do Trabalhador
/*/
//---------------------------------------------------------------------
Static Function FCheck( oBrwAfas )

Local oModal	:=	Nil
Local oSocial	:=	Nil
Local cURL		:=	AllTrim( PadR( TAFGetUrlTSS(), 250 ) )
Local cUserTk	:=	"TOTVS"
Local cIDEnt	:=	TAFRIDEnt( ,,,,, .T. )
Local cAmbES	:=	GetNewPar( "MV_TAFAMBE", "2" )
Local cTSSID	:=	""
Local cXml		:=	""
Local cMessage	:=	""
Local cAlias	:=	oBrwAfas:Alias()
Local cFilBkp	:=	""
Local aSchema	:=	{}
Local aRetorno	:=	{}
Local lRetCons	:=	.F.
Local lRet		:=	.F.

If !( "TSSWSSOCIAL.APW" $ Upper( cURL ) )
	cURL += "/TSSWSSOCIAL.apw"
EndIf

If ( cAlias )->( Eof() )
	lRet := .F.
	MsgInfo( "N�o h� registros para verifica��o." )
ElseIf ( cAlias )->CM6_STATUS <> "3"
	lRet := .F.
	MsgInfo( "Opera��o permitida apenas para registros inconsistentes." )
ElseIf Empty( cURL )
	lRet := .F.
	MsgInfo( "URL do servi�o do TSS n�o informado no par�metro 'MV_TAFSURL': '" + cURL + "'" )
ElseIf Empty( cIDEnt )
	lRet := .F.
	MsgInfo( "Entidade do TSS n�o localizado: '" + cIDEnt + "'" )
ElseIf Empty( cAmbES )
	lRet := .F.
	MsgInfo( "Ambiente de transmiss�o do eSocial n�o informado no par�metro 'MV_TAFAMBE': '" + cAmbES + "'" )
Else
	CM6->( DBGoTo( ( cAlias )->RECNO ) )
	cFilBkp := cFilAnt
	cFilAnt := CM6->CM6_FILIAL
	cXml := TAF261Xml( "CM6", ( cAlias )->RECNO,, .T. )
	cTSSID := AllTrim( "S2230" + AllTrim( CM6->CM6_ID ) + AllTrim( CM6->CM6_VERSAO ) )
	aAdd( aSchema, { "S-2230", cTSSID, EncodeUTF8( cXml ) } )
	cFilAnt := cFilBkp

	aRetorno := TafVldSche( aSchema )

	If !Empty( aRetorno ) .and. !aRetorno[1,4]
		cMessage := "Erro(s) na valida��o de schema"
		cMessage +=  Chr( 13 ) + Chr( 10 )
		cMessage +=  Chr( 13 ) + Chr( 10 )
		cMessage += AllTrim( aRetorno[1,3] )
	Else
		oSocial := WSTSSWSSOCIAL():New()
		oSocial:_Url := cURL
		oSocial:oWSENTCONSDADOS:cAMBIENTE := cAmbES
		oSocial:oWSENTCONSDADOS:cID_ENT := cIDEnt
		oSocial:oWSENTCONSDADOS:cUSERTOKEN := cUserTk
		oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS := WsClassNew( "TSSWSSOCIAL_ARRAYOFENTCONSDOC" )
		oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC := {}

		aAdd( oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC, WsClassNew( "TSSWSSOCIAL_ENTCONSDOC" ) )
		aTail( oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC ):CCODIGO := "S-2230"
		aTail( oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC ):CID := cTSSID
		aTail( oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC ):LRETORNAXML := .T.
		aTail( oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC ):LHISTPROC := .T.

		lRetCons := oSocial:consultarDocumentos()

		If ValType( lRetCons ) == "L"
			If lRetCons
				If ValType( oSocial:oWSCONSULTARDOCUMENTOSRESULT:oWSSAIDACONSDOCS ) <> "U"
					lRet := .T.
				Else
					lRet := .F.
					MsgInfo( "Tipo de dado indefinido no retorno da transmiss�o." )
				EndIf
			Else
				lRet := .F.
				MsgInfo( "Servidor TSS n�o conseguiu processar a requisi��o." )
			EndIf
		Else
			lRet := .F.
			MsgInfo( "Retorno da consulta n�o � do tipo l�gico." )
		EndIf

		If lRet
			aRetorno := oSocial:oWSCONSULTARDOCUMENTOSRESULT:oWSSAIDACONSDOCS:oWSSAIDACONSDOC

			cMessage := "C�digo: " + AllTrim( aRetorno[1]:CCODRECEITA )
			cMessage +=  Chr( 13 ) + Chr( 10 )
			cMessage += "Descri��o: " + AllTrim( aRetorno[1]:CDSCRECEITA )
			cMessage +=  Chr( 13 ) + Chr( 10 )
			cMessage +=  Chr( 13 ) + Chr( 10 )
			cMessage += "Ocorr�ncias: " + AllTrim( aRetorno[1]:CXMLERRORET )
		EndIf
	EndIf
EndIf

If !Empty( cMessage )
	oModal := FWDialogModal():New()
	oModal:SetTitle( "Inconsist�ncia" )
	oModal:SetFreeArea( 290, 250 )
	oModal:SetEscClose( .T. )
	oModal:SetBackground( .T. )
	oModal:CreateDialog()

	TMultiGet():New( 030, 020, { || cMessage }, oModal:GetPanelMain(), 250, 190,,,,,, .T.,,,,,, .T.,,,,, .T. )

	oModal:Activate()
EndIf

TAFEncArr( @aSchema )
TAFEncArr( @aRetorno )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} SetIncPerc
@type			function
@description	Incrementa o progresso realizado.
@author			Felipe C. Seolin
@since			03/12/2018
@version		1.0
@param			oMsgRun		-	Objeto do FWMsgRun
@param			cOper		-	Opera��o em curso de execu��o
@param			nQtdTotal	-	Quantidade total de registros a processar
@param			nQtdProc	-	Quantidade de registros processados
/*/
//---------------------------------------------------------------------
Static Function SetIncPerc( oMsgRun, cOper, nQtdTotal, nQtdProc )

Local cMessage	:=	""
Local cPercent	:=	cValToChar( Int( ( nQtdProc / nQtdTotal ) * 100 ) )

cMessage := I18N( "#1 - Progresso: #2%", { cOper, cPercent } )

oMsgRun:cCaption := cMessage
ProcessMessages()

Return()

//------------------------------------------------------------------------------------
/*/{Protheus.doc} TafPermUsu
@type			Function
@description	Retira do aRotinas apenas eventos n�o permitidos para o usuario
@author			Ricardo Lovrenovic
@since			20/09/2018
@version		1.0
@param			oInfoRot	-	Array com todas as rotinas do E-Social
/*/
//------------------------------------------------------------------------------------
Function TafPermUsu( aInfoRot )

Local cNomeRot 	:= ""
Local nRotina 	:= 0

Default aInfoRot := {}

If TafColumnPos( "C91_TRABEV" ) .AND. TafColumnPos( "T3P_TRABEV" )
	For nRotina := 1 to len( aInfoRot )
	
		If nRotina <= len( aInfoRot )
	
			cNomeRot := aInfoRot[ nRotina , 1 ]
	
			If !(MPUserHasAccess(cNomeRot, /*nOpc*/ , /*[cCodUser]*/, /*[lShowMsg]*/, /*[lAudit]*/  ))	
	
				If cNomeRot $ "TAFA250|TAFA407"
			
					lLockAuton := .T.
					Exit

				EndIf

			EndIf
	
		EndIf

	Next nRotina
EndIf

Return()

//------------------------------------------------------------------------------------
/*/{Protheus.doc} monGetTrbName
@type			Function
@description	Retorna o Nome Atual do trabalhador olhando 
@author			Evadnro dos Santos Oliveira
@since			12/08/2020
@version		1.0
@param			cBanco - nome do banco de dados
@param 			cFilialTrab - Filial do Trabalhador
@param 			cCPF - Cpf do Trabalhador
/*/
//------------------------------------------------------------------------------------
Function monGetTrbName(cBanco,cFilialTrab,cCPF)

	Local cSql := ""
	Local cNome := ""

	cSql := " SELECT "

	If !( cBanco $ ( "INFORMIX|ORACLE|DB2|OPENEDGE|MYSQL|POSTGRES" ) )
		cSql += " TOP 1  "
	ElseIf cBanco == "INFORMIX"
		cSql += " FIRST 1  "
	EndIf	

	cSql += " T1U_NOME NOME "
	cSql += " ,R_E_C_N_O_ RECNO "
	cSql += " FROM "
	cSql += RetSqlName("T1U")
	cSql += " WHERE "
	cSql += " T1U_FILIAL = '" + cFilialTrab + "'"
	cSql += " AND T1U_CPF = '" + cCPF + "'"
	cSql += " AND T1U_ATIVO = '1' "
	cSql += " AND T1U_EVENTO != 'E'
	cSql += " AND D_E_L_E_T_ =  ' ' "

	If cBanco == "ORACLE"
		cSql += " AND ROWNUM <= 1 "
	EndIf 

	If cBanco == "DB2"
		cSql += " ORDER BY R_E_C_N_O_ DESC  "
		cSql += " FETCH FIRST 1 ROWS ONLY "

	Elseif cBanco $ "POSTGRES|MYSQL"
		cSql += " ORDER BY R_E_C_N_O_ DESC LIMIT 1 "
	Else
		cSql += " ORDER BY R_E_C_N_O_ DESC "
	Endif

	cSql := ChangeQuery(cSql)
	TCQuery cSql New Alias 'rsT1U'
	cNome := AllTrim(rsT1U->NOME)
	rsT1U->(dbCloseArea())

Return cNome

//------------------------------------------------------------------------------------
/*/{Protheus.doc} XFunFilLog
Retorna o array da filial logada.
@type			Function
@author			Alexandre L.S/Bruno de Oliveira 
@since			20/10/2020
@version		1.0
@param			lFilcheck - Indetifica se utiliza a filial logada quado o valor for verdade.
@Return			aRet - retona a filial logada ou null.
/*/
//------------------------------------------------------------------------------------
Static Function XFunFilLog(lFilcheck)

Local aRet     := { }
Local cFillog  := FwCodFil()
local cFilName := FWFilialName()
local cCodGrup := FWGrpCompany()
Local cCgc 	   := Posicione("SM0",1,cCodGrup + cFillog ,"M0_CGC")
Local cIsnc    := Posicione("SM0",1,cCodGrup + cFillog ,"M0_INSC")
Local cIsncM   := Posicione("SM0",1,cCodGrup + cFillog ,"M0_INSCM")

if lFilcheck
	aAdd(aRet,{ .T.,;
				cFillog,;
				cFilName,;
				cCgc,;
				cIsnc,;
				cIsncM;
						})
Else
	aRet := Nil
EndIf

Return aRet

//------------------------------------------------------------------------------------
/*/{Protheus.doc} NewPanESoc
Apresenta mensagem de descontinua��o do Painel e-Social.
@type			Function
@author			Felipe Guarnieri
@since			12/11/2020
@version		1.0
@param			lQTDesc - Indica se o Painel eSocial QT foi descontinuado	
@Return			lReturn - Informa se deve voltar para o menu inicial
/*/
//------------------------------------------------------------------------------------

Static Function NewPanESoc(dDataFim)

	Local cButton		:= ""
	Local cMsg  		:= ""
	Local lReturn		:= .F.
	Local oModal 		:= Nil
	Local oContainer 	:= Nil

	Default dDataFim	:= CtoD("01/04/2022")

	oFontSub 				:= TFont():New('Arial',, -16, .T.)
	oFontText 				:= TFont():New('Arial',, -16, .T.)
	oFontTitle 				:= TFont():New('Arial',, -18, .T.)
	oFontTitle:Bold 		:= .T.
	oFontButtons 			:= TFont():New('Arial',, -16, .T.)
	oFontButtons:Underline 	:= .T.
	oFontButtons:Bold 		:= .T.

	oModal := FWDialogModal():New()

	oModal:SetEscClose(.T.)
	oModal:SetTitle(STR0297) 																						// "Utilize o novo Painel e-Social!"
	oModal:SetSize(190, 400)
	oModal:CreateDialog()

	oFont := TFont():New('Courier new',, -18, .T.)

	cMsg := '<div align="justify">'
	cMsg += '	<br>' + STR0277 + ',</br>'																			// "Prezado Cliente"

	If GetRPORelease() == "12.1.2210"
		cMsg 	+= '	<p>' + STR0296 + '</b></p>' 																// "Para realizar consultas e transmiss�es dos eventos e obriga��es do e-Social utilize o novo Painel e-Social."

		cButton := STR0298																							// "Fechar"
		lReturn	:= .T.
	Else
		cMsg 	+= '	<p>' + STR0278 + ' <b>' + DtoC(dDataLim) + '</b>, ' +  STR0282 + ' <b>' + STR0283 + '</b>.' // "A partir do dia" / "todas as transmiss�es de eventos do e-Social, dever�o ser realizadas atrav�s do novo" / "Painel e-Social"						
		cMsg 	+= '	<p>' + STR0294 + '</b></p>'																	// "nenhuma nova melhoria ser� implementada nesta rotina e novas legisla��es do e-Social ser�o entregues somente atrav�s do novo Painel e-Social."
		cMsg 	+= '	<p>' + STR0295 + '</b></p>'																	// "Programe URGENTEMENTE a utiliza��o do novo Painel e-Social."

		cButton := STR0299																							// "Estou ciente" 
	EndIf
	
	cMsg += '	<p>' + STR0281 + '</p>' 																			// "Clique nos links abaixo para saber o passo a passo, de como configurar o novo Painel e-Social e tamb�m conhec�-lo com mais detalhes."
	cMsg += '</div>'

	oModal:addCloseButton(Nil, cButton)

	oFont 	:= TFont():New('Courier new',, -22, .T.)

	oSay	:= TSay():New(30, 15, {|| cMsg },,, oFontSub,,,, .T.,,, 350, 130,,,,,, .T.)

	oBtn1 	:= THButton():New(140, 10, STR0275, oContainer, {|| ShellExecute("Open", "https://tdn.totvs.com/x/TIp-Hw", "", "C:\", 1)}, 200, 20,oFontButtons, STR0275)		// "Como configurar o novo Painel e-Social?"
	oBtn2 	:= THButton():New(140, 200, STR0276, oContainer, {|| ShellExecute("Open", "https://tdn.totvs.com/x/VhKOIQ", "", "C:\", 1 )}, 165, 20, oFontButtons, STR0276)	// "Conhe�a o novo Painel e-Social!"
		
	oBtn1:SetCss("QPushButton{ color: #21a4c4; }")
	oBtn2:SetCss("QPushButton{ color: #21a4c4; }")

	oModal:Activate()

Return lReturn
