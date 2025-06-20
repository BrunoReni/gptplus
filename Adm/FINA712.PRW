#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FwSchedule.ch"
#INCLUDE "FINA712.CH"

Static  __oFontTit    := TFont():New(,,-25,.T.,.T.,,,,,)
Static  __oFont2      := TFont():New(,,-14,.T.,,,,,,)
Static  __oFont2N     := TFont():New(,,-14,.T.,.T.,,,,,)


//-------------------------------------------------------------------
/*/{Protheus.doc} F712Wiz
Wizard de configura��o do Novo Gestor Financeiro

@author renato.ito
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Function F712Wiz()

	Local oStepWiz As Object
	Local o1stPage As Object
	Local o2stPage As Object
	Local o3stPage As Object
	Local o4stPage As Object
	Local o5stPage As Object
	Local o6stPage As Object
	Local oDlg     As Object
	Local lTravou  As Logical

	If !IsBlind()

		FwCustomMetrics():setSumMetric("FINA712 - Wizard NGF", "financeiro-protheus_qtd-por-acesso_total", 1)

    	// verifica se o processo j� est� em execu��o
		lTravou := .T.
		If FWIsAdmin( __cUserID )
    		lTravou := LockByName('FINA712', .T./*lEmpresa*/, .F./*lFilial*/)    
    	EndIf

    	If lTravou

			DEFINE DIALOG oDlg TITLE ' ' PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )

				oDlg:nWidth  := 750
				oDlg:nHeight := 550

				oStepWiz := FWWizardControl():New(oDlg)  //Instancia a classe FWWizardControl
				oStepWiz:ActiveUISteps()

				//----------------------
				// Pagina 1 - In�cio
				//----------------------
				o1stPage := oStepWiz:AddStep("1STSTEP",{|Panel| cria_pn1(Panel)}) // Adiciona um Step
				o1stPage:SetStepDescription(OemToAnsi(STR0039))   // 'In�cio'
				If FWIsAdmin( __cUserID )
					o1stPage:SetNextTitle(OemToAnsi(STR0002))       // Define o t�tulo do bot�o next -- "Avan�ar"
					o1stPage:SetNextAction({||.T.})                 // Define o bloco ao clicar no bot�o next
				Else
					o1stPage:SetNextTitle(OemToAnsi(STR0040))       // 'Terminar'
					o1stPage:SetNextAction({||Help(' ', 1, 'F712WIZADM' , , STR0025 , 1 , 0),oDlg:End()})                 // Define o bloco ao clicar no bot�o next
				EndIf
				o1stPage:SetCancelAction({|| .T.})              // Define o bloco ao clicar no bot�o Cancelar

				//----------------------
				// Pagina 2 - Recomenda��es Adm
				//----------------------
				o2stPage := oStepWiz:AddStep("2STSTEP",{|Panel| cria_pn2(Panel)}) // Adiciona um Step
				o2stPage:SetStepDescription(OemToAnsi(STR0041)) // 'Avisos'
				o2stPage:SetNextTitle(OemToAnsi(STR0002))       // Define o t�tulo do bot�o next -- "Avan�ar"
				o2stPage:SetNextAction({||.T.})                  // Define o bloco ao clicar no bot�o next
				o2stPage:SetCancelAction({|| .T.})              // Define o bloco ao clicar no bot�o Cancelar

				//----------------------
				// Pagina 3 - Porta Multiprotocolo
				//----------------------
				o3stPage := oStepWiz:AddStep("3STSTEP",{|Panel| cria_pn3(Panel)}) // Adiciona um Step
				o3stPage:SetStepDescription(OemToAnsi(STR0042)) // 'Multiprotocolo'
				o3stPage:SetNextTitle(OemToAnsi(STR0002))       // Define o t�tulo do bot�o next -- "Avan�ar"
				If F710VMProt()
					o3stPage:SetNextTitle(OemToAnsi(STR0002))       // Define o t�tulo do bot�o next -- "Avan�ar"
					o3stPage:SetNextAction({||.T.})                 // Define o bloco ao clicar no bot�o next
				Else
					o3stPage:SetNextTitle(OemToAnsi(STR0040))       // 'Terminar'
					o3stPage:SetNextAction({||oDlg:End()})                 // Define o bloco ao clicar no bot�o next
				EndIf
				o3stPage:SetCancelAction({|| .T.})              // Define o bloco ao clicar no bot�o Cancelar

				//----------------------
				// Pagina 4 - Dicion�rio - STAMP
				//----------------------
				o4stPage := oStepWiz:AddStep("4STSTEP",{|Panel| cria_pn4(Panel)}) // Adiciona um Step
				o4stPage:SetStepDescription(OemToAnsi(STR0006))  // "Dicion�rio"
				o4stPage:SetNextTitle(OemToAnsi(STR0002))        // Define o t�tulo do bot�o next -- "Avan�ar"
				o4stPage:SetNextAction({||F712Dic()})            // Define o bloco ao clicar no bot�o next
				o4stPage:SetCancelAction({|| .T.})               // Define o bloco ao clicar no bot�o Cancelar

				//----------------------
				// Pagina 5 - Job
				//----------------------
				o5stPage := oStepWiz:AddStep("5STSTEP",{|Panel| cria_pn5(Panel)}) // Adiciona um Step
				o5stPage:SetStepDescription(OemToAnsi(STR0043))  // 'Agendamento'
				o5stPage:SetNextTitle(OemToAnsi(STR0013))        // Define o t�tulo do bot�o next -- "Configurar"
				o5stPage:SetNextAction({||F712Job()})            // Define o bloco ao clicar no bot�o Pr�ximo
				o5stPage:SetCancelAction({|| .T.})               // Define o bloco ao clicar no bot�o Cancelar

				//----------------------
				// Pagina 6 - Conclus�o
				//----------------------
				o6stPage := oStepWiz:AddStep("6STSTEP",{|Panel| cria_pn6(Panel)}) // Adiciona um Step
				o6stPage:SetStepDescription(OemToAnsi(STR0019)) // "Finalizar"
				o6stPage:SetNextTitle(OemToAnsi(STR0019))       // Define o t�tulo do bot�o next -- "Finalizar"
				o6stPage:SetNextAction({||.T.})                 // Define o bloco ao clicar no bot�o next
				o6stPage:SetCancelAction({|| .T.})              // Define o bloco ao clicar no bot�o Cancelar

				oStepWiz:activate()

			ACTIVATE DIALOG oDlg CENTER      

			If FWIsAdmin( __cUserID )
				UnLockByName('FINA712', .T./*lEmpresa*/, .F./*lFilial*/ )
			EndIf
      
		Else
			Help(' ', 1, 'F712WIZRUN' , , STR0026 , 1 , 0) // 'Wizard de configura��o do Novo Gestor Financeiro j� est� em execu��o em outra inst�ncia!'
		EndIf
	Else
		//Somente ser� executado se for chamado por JOB.
		F712Dic()
		F712Job()
	Endif


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pn1
Fun��o para constru��o p�gina do wizard
step 1 informa��es gerais do wizard
@param oPanel

@author rafael.rondon
@since 25/07/2022
/*/
//-------------------------------------------------------------------
Static Function cria_pn1(oPanel As Object)

	Local cLinkTdn  As Character
	Local cMsg001   As Character
	Local oSay1     As Character

	cLinkTdn := 'https://tdn.totvs.com/pages/releaseview.action?pageId=611007335'

	cMsg001 := "<b><a target='_blank' href='"+cLinkTDN+"'> "
	cMsg001 += STR0044 // "Clique aqui para saber mais."
	cMsg001 += " </a></b>"
	cMsg001 += "<span color: #565759;'>" + "</span>"

	TSay():New(10,15,{|| STR0003},oPanel,,__oFontTit,,,,.T.,CLR_BLUE,)   // 'Boas vindas ao Novo Gestor Financeiro'
	TSay():New(35,15,{|| STR0046},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        // 'O Novo Gestor Financeiro fornece um conjunto de funcionalidades para gerir as atividades financeiras de'
	TSay():New(45,15,{|| STR0047},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        // 'forma �gil com uma interface moderna.'

	If !(FWIsAdmin( __cUserID ))
		TSay():New(65,15,{|| STR0048 },oPanel,,__oFont2,,,,.T.,CLR_BLUE,)  //   'Algumas configura��es s�o necess�rias para acessar essa rotina.'
		TSay():New(85,15,{|| STR0049 },oPanel,,__oFont2N,,,,.T.,CLR_RED,)  //   'Por favor, solicite ao administrador do sistema que acesse essa mesma rotina para realizar'
		TSay():New(95,15,{|| STR0050 },oPanel,,__oFont2N,,,,.T.,CLR_RED,)    //   'as configura��es necess�rias.'
		oSay1 := TSay():New(115,15,{||cMsg001},oPanel,,__oFont2,,,,.T.,,,220,20,,,,,,.T.)    
	else
		TSay():New(65,15,{|| STR0051 },oPanel,,__oFont2,,,,.T.,CLR_BLUE,)  //   'Algumas configura��es s�o necess�rias para acessar essa rotina. Voc� ser� guiado nos pr�ximos passos.'
		oSay1 := TSay():New(85,15,{||cMsg001},oPanel,,__oFont2,,,,.T.,,,220,20,,,,,,.T.)
	EndIf

	oSay1:bLClicked := {|| MsgRun( STR0052, "URL",{|| ShellExecute("open",cLinkTDN,"","",1) } ) } // "Abrindo o link... Aguarde..."

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pn2
Fun��o para constru��o p�gina do wizard
step 1 informa��es gerais do wizard
@param oPanel

@author renato.ito
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Static Function cria_pn2(oPanel As Object)

	Local cLinkTdn  As Character
	Local cMsg001   As Character
	Local oSay1     As Character

	cLinkTdn := 'https://tdn.totvs.com/pages/releaseview.action?pageId=602610545'

	TSay():New(10,15,{|| STR0041},oPanel,,__oFontTit,,,,.T.,CLR_BLUE,)    //    'Avisos'
	TSay():New(35,15,{|| STR0004},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        // 'Nesse wizard vamos verificar todas as necessidades para execu��o do Novo Gestor Financeiro.'
	TSay():New(55,15,{|| STR0054},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)   //    'Ser� necess�rio o acesso exclusivo de algumas tabelas do m�dulo financeiro para atualiza��o do dicion�rio'
	TSay():New(75,15,{|| STR0037},oPanel,,__oFont2,,,,.T.,CLR_RED,)  // 'Este wizard deve ser executado no ambiente onde est� configurado o servi�o de'

	cMsg001 := "<b><a target='_blank' href='"+cLinkTDN+"'> "
	cMsg001 += STR0045 // "Clique aqui para mais detalhes das configura��es."
	cMsg001 += " </a></b>"
	cMsg001 += "<span color: #565759;'>" + "</span>"
	oSay1 := TSay():New(95,15,{||cMsg001},oPanel,,__oFont2,,,,.T.,,,220,20,,,,,,.T.)
	oSay1:bLClicked := {|| MsgRun( STR0052, "URL",{|| ShellExecute("open",cLinkTDN,"","",1) } ) } // "Abrindo o link... Aguarde..." 

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pn3
Fun��o para constru��o p�gina do wizard
step 3 porta multiprotocolo
@param oPanel

@author rafael.rondon
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Static Function cria_pn3(oPanel As Object)

	Local cLinkTdn  As Character
	Local cMsg001   As Character
	Local oSay1     As Character

	cLinkTdn := 'https://tdn.totvs.com/display/tec/Application+Server+-+Porta+Multiprotocolo'

	TSay():New(10,15,{|| STR0056 },oPanel,,__oFontTit,,,,.T.,CLR_BLUE,)   //    'Porta Multiprotocolo'

	If F710VMProt() // Multiprotocolo configurada?

		TSay():New(35,15,{|| STR0057},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)    //    'A porta Multiprotocolo est� configurada.'
		TSay():New(55,15,{|| STR0058},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        //  'Nenhuma a��o � necess�ria neste passo.'

	Else

		TSay():New(35,15,{|| STR0059},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)   //    '� preciso que o sistema esteja configurado com o uso da porta multiprotocolo para utilizar o Novo'
		TSay():New(45,15,{|| STR0060},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)   //    'Gestor Financeiro.'

		TSay():New(65,15,{|| STR0061},oPanel,,__oFont2N,,,,.T.,CLR_RED,)    //    'Somente ap�s configurar a porta multiprotocolo, ser� poss�vel continuar a configura��o.'

		cMsg001 := "<b><a target='_blank' href='"+cLinkTDN+"'> "
		cMsg001 += STR0044 // "Clique aqui para saber mais."
		cMsg001 += " </a></b>"
		cMsg001 += "<span color: #565759;'>" + "</span>"
		oSay1 := TSay():New(85,15,{||cMsg001},oPanel,,__oFont2,,,,.T.,,,220,20,,,,,,.T.)
		oSay1:bLClicked := {|| MsgRun( STR0052, "URL",{|| ShellExecute("open",cLinkTDN,"","",1) } ) } // "Abrindo o link... Aguarde..."

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pn4
Fun��o para constru��o p�gina do wizard
step 2 vali��o das tabelas e par�metros
@param oPanel

@author renato.ito
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Static Function cria_pn4(oPanel As Object)

	Local cLinkTdn  As Character
	Local cMsg001   As Character
	Local oSay1     As Character

	cLinkTdn := 'https://tdn.totvs.com/pages/releaseview.action?pageId=602610545'

	TSay():New(10,15,{|| STR0008},oPanel,,__oFontTit,,,,.T.,CLR_BLUE,)   // 'Dicion�rio de dados'

	If F710VDic()

		TSay():New(35,15,{|| STR0062},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)    //    'Dicion�rio Ok.'
		TSay():New(55,15,{|| STR0063},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        //   'Nenhuma a��o � necess�ria neste passo.'

	Else  

		TSay():New(35,15,{|| STR0064},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        //    "Neste passo faz-se necess�rio que o dicion�rio do m�dulo financeiro esteja com acesso exclusivo,"
		TSay():New(45,15,{|| STR0065},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)            //    "onde ao avan�ar, ser�o criados campos de controle e novas tabelas no sistema."

		cMsg001 := "<b><a target='_blank' href='"+cLinkTDN+"'> "
		cMsg001 += STR0044 // "Clique aqui para saber mais."
		cMsg001 += " </a></b>"
		cMsg001 += "<span color: #565759;'>" + "</span>"
		oSay1 := TSay():New(65,15,{||cMsg001},oPanel,,__oFont2,,,,.T.,,,220,20,,,,,,.T.)
		oSay1:bLClicked := {|| MsgRun( STR0052, "URL",{|| ShellExecute("open",cLinkTDN,"","",1) } ) } // "Abrindo o link... Aguarde..."

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pn5
Fun��o para constru��o p�gina do wizard
step 4 configura��o do job
@param oPanel

@author renato.ito
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Static Function cria_pn5( oPanel As Object )

	Local cLinkTdn  As Character
	Local cMsg001   As Character
	Local oSay1     As Character

	cLinkTdn := 'https://tdn.totvs.com/pages/releaseview.action?pageId=602610545'

	TSay():New(10,15,{|| STR0014},oPanel,,__oFontTit,,,,.T.,CLR_BLUE,)   // 'Configura��o do Job' 
	TSay():New(35,15,{|| STR0015},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        // 'Nesta etapa, cadastraremos um novo job no schedule automaticamente. Ele tem o nome  FINA711.'                                                                                                                                                                                                                                                                                                                                                                                                                      
	TSay():New(55,15,{|| STR0066},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)          //  'Este job ser� configurado com intervalo de 15 minutos.'
	TSay():New(75,15,{|| STR0016},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        //'Para altera��o no intervalo de execu��o, realize a manuten��o pelo agendamento do Job no Schedule'                                                                                                                                                                                                                                                                                                                                                                                                                 
	TSay():New(85,15,{|| STR0017},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        // 'do m�dulo configurador.'

	cMsg001 := "<b><a target='_blank' href='"+cLinkTDN+"'> "
	cMsg001 += STR0044 // "Clique aqui para saber mais."
	cMsg001 += " </a></b>"
	cMsg001 += "<span color: #565759;'>" + "</span>"
	oSay1 := TSay():New(105,15,{||cMsg001},oPanel,,__oFont2,,,,.T.,,,220,20,,,,,,.T.)
	oSay1:bLClicked := {|| MsgRun( STR0052, "URL",{|| ShellExecute("open",cLinkTDN,"","",1) } ) } // "Abrindo o link... Aguarde..."

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pn6
Fun��o para constru��o p�gina do wizard
step 5 mensagens finais
@param oPanel

@author renato.ito
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Static Function cria_pn6( oPanel As Object )

	TSay():New(10,15,{|| STR0020},oPanel,,__oFontTit,,,,.T.,CLR_BLUE,)      // 'Configura��o finalizada'
	TSay():New(35,15,{|| STR0021},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        // 'Configura��o realizada com sucesso!'
	TSay():New(55,15,{|| STR0022},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        // 'Para acesso ao Novo Gestor Financeiro � necess�rio aguardar a execu��o da primeira carga de dados.'
	TSay():New(75,15,{|| STR0067},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        //  'Dependendo do volume da base de dados do financeiro, esta carga pode demorar um tempo consider�vel.'

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F712Dic
Fun��o para valida��o da p�gina 2 do wizard
Verifica o campo S_T_A_M_P_ das tabelas e par�metros

@author renato.ito
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Static Function F712Dic()

	Local lRet    As Logical
	Local aTables As Array
	Local aFiles  As Array
	Local i       As Numeric
	Local cFn     As Character

	lRet    := .T.
	aTables := {}
	aFiles  := {}
	cFn     := "TCCONFIG"

	// Tabelas que devem ter o campo S_T_A_M_P_
	aTables := STRTOKARR('SE1|SE2|FKD|SC5|SC6|SC7|SC9', '|' )
	// Carrego o array com os dados para abertura das tabelas.
	aEval( aTables, { |x| aadd(aFiles,{RetSqlName(x),x}) } )

	If (&cFn.('SETAUTOSTAMP = ON') == 'OK') .And. (&cFn.('SETUSEROWSTAMP = ON') == 'OK')
		//Verifico se todas as tabelas puderam ser abertas em modo excluivo.
		For i := 1 To Len(aFiles)
			// fechando �rea caso aberta
			If (Select(aFiles[i][2]) > 0)
				&(aFiles[i][2])->(DbCloseArea())
			EndIf
			TCRefresh(aFiles[i][1])
			DbUseArea(.T., 'TOPCONN', aFiles[i][1], aFiles[i][2], .F. , .F.)
			&(aFiles[i][2])->(DbCloseArea())
			// Verifica se o campo S_T_A_M_P_ foi criado
			If aScan(TCStruct(aFiles[i][1] ), {|x| x[1] == 'S_T_A_M_P_'}) = 0
				lRet := .f.
				Help(' ', 1,'F712Stamp' ,,STR0010 ,1,0) // 'N�o foi poss�vel obter acesso exclusivo para adequa��o do dicion�rio.'
				Exit
			Endif
		Next
		&cFn.('SETAUTOSTAMP = OFF')
		&cFn.('SETUSEROWSTAMP = OFF')
	Else
		// Caso apresente esse erro, verifique se o banco de dados � homologado para o campo S_T_A_M_P_ e se o DbAcess est� atualizado
		lRet := .F.
		Help(' ', 1,'F712DBStamp' ,,STR0011 ,1,0) // 'N�o foi poss�vel ativar o recurso S_T_A_M_P_ para o banco de dados.'
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F712Job
Fun��o para valida��o da p�gina 4 do wizard
configura��o do job

@author renato.ito
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Static Function F712Job()

	Local cAgend  as Character
	Local cPeriod as Character
	Local lRet    as Logical

	lRet    := .T.
	cAgend  := '' 
	cPeriod := ''

	// Verifica se j� existe o job configurado
	cAgend := FwSchdByFunction("FINA711('" + cEmpAnt + "')")
	//Somente cria o agendamento do schedule caso o mesmo ainda n�o exista
	If (Empty(cAgend))
		//Executa a cada 15 minutos
		cPeriod := "D(Each(.T.);Day(1);EveryDay(.T.););Execs(0096);Interval(00:15);"
		//(cFunction, cUserID, cParam, cPeriod, cTime, cEnv, cEmpFil, cStatus, dDate, nModule, aParamDef)
		cAgend := FwInsSchedule("FINA711('" + cEmpAnt + "')", "000000",, cPeriod, "00:00", Upper(GetEnvServer()), cEmpAnt + "/" + cFilAnt + ";",;
			SCHD_ACTIVE, Date(), 6, )
		If Empty(cAgend)
			lRet := .F.
			Help(' ', 1,'F712Job' ,,STR0018 ,1,0) // 'N�o foi poss�vel criar o agendamento Job FINA711 de forma autom�tica.'
		EndIf
	EndIf

Return lRet


