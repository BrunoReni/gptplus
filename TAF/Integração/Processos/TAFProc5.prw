#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE TAMMAXXML 075000  //Tamanho Maximo do XML
#DEFINE TAMMSIGN  004000  //Tamanho m�dio da assinatura

//--------------------------------------------------------------------------- -
/*/{Protheus.doc} TAFProc5
Chama rotina responsavel por verificar os registros que devem ser
Consultados
@return Nil

@author Evandro dos Santos Oliveira
@since 07/11/2013 - Alterado 18/05/2015
@version 1.0
@obs - Rotina separada do fonte TAFAINTEG e realizado tratamentos especificos
		para a utiliza��o do Job5 realizando a chamada individualmente e utilizando
		o schedDef para a execu��o no schedule.
/*/
//----------------------------------------------------------------------------

Function TAFProc5(lPrepare, cEmp, cFil)

	Local lJob := .F.
	Local lEnd := .F.

	If lPrepare
		RpcSetType(3)
		RpcSetEnv(cEmp, cFil,,,"TAF","TAFPROC5")
	EndIf

	lJob := IsBlind()
	If TAFAtualizado(!lJob)
		TafConOut('Rotina de Transmiss�o de eventos e-Social - Empresa: ' + cEmpAnt + ' Filial: ' + cFilAnt)

		If lJob
			TAFProc5TSS(lJob,,,,,@lEnd)
		Else
			Processa( {||TAFProc5TSS(lJob,,,,,@lEnd)}, "Aguarde...", "Executando rotina de Transmiss�o",  )
		EndIf

		If lEnd .And. !lJob
			MsgInfo("Processo finalizado.")
		EndIf
	EndIf

	If lPrepare
		RpcClearEnv()
	EndIf

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFProc5Tss
Processo responsavel por verificar os registros que devem ser consultados no
TSS.

Altera��o: Evandro dos Santos
Data: 05/04/2016
Descri��o: - Alterado a forma de gera��o dos registros, para a rotina possibilitar
a gera��o de XMLs em disco, foram incluidos uma s�rie de par�metros que permitem
a gera��o de layouts especificos e filtros por status, recno e Id.
- Alterado a Origem do array dos layouts, antes os mesmos eram baseados no array
aTafSocial deste fonte, agora os layouts considerados s�o os especificados no
fonte TAFROTINAS.

@param	lJob - Flag para Identifica��o da chamada de Fun��o por Job
@param 	aEvtsESoc 	- Array com os Eventos a serem considerados, quando vazio s�o considerados
		todos os eventos contidos no TAFROTINAS.
		Obs: Quando informados os eventos devem seguir a mesma estrutura dos eventos e-Social
		contidos no TAFROTINAS.
@param 	cStatus - Status dos eventos que devem ser transmitidos, quando vazio  o sistema usa o 0
        para tranmiss�o e o 2 para consulta; o par�metro pode conter mais de 1 status par isso
        passar os status separados por virgula ex: "1,3,4"
@param aIdTrab - Array com o Id dos trabalhadores (para filtro dos eventos que tem rela��o com o
	    trabalhador)
@param cRecNos - Filtra os registro pelo RecNo do Evento, pode ser utilizado um range de recnos
		ex;"1,5,40,60"
@param lEnd - Verifica o fim do processamento(vari�vel referenciada)
@param cMsgRet - Mensagem de retorno do WS (refer�ncia)
@param aFiliais - Array de Filiais
@param dDataIni	-> Data Inicial dos eventos
@param dDataFim	-> Data Fim dos dos eventos
@param lEvtInicial -> Informa se o par�metro de evento inicial foi marcado. (** Descontinuado)
@param lCommit -> Indica se ser� comitado na tabela
@param cIdEnt -> Id da Entidade
@param oProcess -> Objeto FWNewProcess
@param lForceRetorno -> For�a o Retorno da consulta, mesmo quando h� grava��o no tempTable
@param lMV -> Utiliza��o de Multiplos vinculos
@return Nil

@author Evandro dos Santos Oliveira
@since 07/11/2013
@version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFProc5Tss( lJob as logical, aEvtsESoc as array, cStatus as character, aIdTrab as array, cRecNos as character,;
					lEnd as logical, cMsgRet as character, aFiliais as array, dDataIni as date, dDataFim as date,;
					lEvtInicial as logical, lCommit as logical, cIdEnt as date, oProcess as object,;
					lForceRetorno as logical, oTabFilSel as object, lMV as logical, lReavPen as logical,;
					oMsgRun as object, cPeriod as character, lRetResponse as logical, lCallApi as logical )

	Local aXmls				as array
	Local aRetConsulta		as array
	Local aRetorno			as array
	Local cQry				as character
	Local cFunction			as character
	Local cId				as character
	Local cTabOpen			as character
	Local cMsgProc			as character
	Local cUrl				as character
	Local cCheckURL			as character
	Local cLog				as character
	Local cAlsEvt			as character
	Local cJobName			as character
	Local cFuncP5			as character
	Local cAliasRegs		as character
	Local cAmbte			as character
	Local cBancoDB			as character
	Local cTimeProc			as character
	Local cIdThread			as character
	Local lAllEventos		as logicaL
	Local lTransFil			as logical
	Local lNewProcess		as logical
	Local lGravaErrTab		as logical
	Local lMThread			as logical
	Local lTabTmpExt		as logical
	Local nItem				as numeric
	Local nQtdLote			as numeric
	Local nLote				as numeric
	Local nTry				as numeric
	Local nCont             as numeric
	Local nQtdRegs			as numeric
	Local nQtdPorLote		as numeric
	Local nMaxTry			as numeric
	Local nTopSlct			as numeric
	Local nMThread			as numeric
	Local nQtLoteMT			as numeric

	Default aEvtsESoc		:= {}
	Default aIdTrab			:= {}
	Default cRecNos			:= ""
	Default cMsgRet			:= ""
	Default cPeriod			:= ""
	Default cIdEnt			:= ""
	Default cStatus			:= "'2'"
	Default dDataIni		:= SToD("")
	Default dDataFim		:= SToD("")
	Default lForceRetorno	:= .F.
	Default lMV				:= .F.
	Default lReavPen		:= .F.
	Default lRetResponse	:= .F.
	Default lCallApi		:= .F.
	Default lEnd			:= .T.
	Default lCommit			:= .T.
	Default oTabFilSel		:= Nil
	Default oProcess		:= Nil
	Default oMsgRun			:= Nil

	aXmls			:= {}
	aRetConsulta	:= {}
	aRetorno		:= {}
	cQry			:= ""
	cFunction		:= ""
	cId				:= ""
	cTabOpen		:= ""
	cMsgProc		:= ""
	cUrl			:= ""
	cCheckURL		:= ""
	cLog			:= ""
	cAlsEvt			:= ""
	cJobName		:= "TAFPROC5MT_" + AllTrim(cEmpAnt) + "_" + AllTrim(cFilAnt)
	cFuncP5			:= "TAFPROC5MT"
	cAliasRegs		:= GetNextAlias()
	cAmbte			:= SuperGetMv("MV_TAFAMBE", .F., "2")
	cBancoDB		:= Upper(AllTrim(TcGetDB()))
	cTimeProc		:= Time()
	cIdThread		:= StrZero(ThreadID(), 10)
	lAllEventos		:= .F.
	lTransFil		:= .F.
	lNewProcess		:= .F.
	lMThread		:= .F.
	lTabTmpExt		:= oTabFilSel <> Nil
	lGravaErrTab    := FindFunction("FTableTSSErr");
						.And. Substr(GetRpoRelease(), 1, 2) == "12";
						.And. IsInCallStack("TAFMONTES")
	nItem			:= 0
	nQtdLote		:= 0
	nLote			:= 0
	nTry			:= 0
	nCont			:= 0
	nQtdRegs		:= 0
	nQtdPorLote		:= 50
	nMaxTry			:= 150
	nTopSlct		:= 999999
	nMThread		:= SuperGetMv("MV_TAFQTMT", .F., 0)
	nQtLoteMT		:= SuperGetMv("MV_TAFLTMT", .F., 0) 

	If FindFunction("TafGetUrlTSS")
		cURL := PadR(TafGetUrlTSS(),250)
	Else
		cURL := PadR(GetNewPar("MV_TAFSURL","http://"),250)
	EndIf

	cURL := AllTrim(cURL)

	If !("TSSWSSOCIAL.APW" $ Upper(cUrl))
		cCheckURL := cUrl
		If RAT("/",cUrl) != Len(cUrl)
			cUrl += "/"
		EndIf 
		cUrl += "TSSWSSOCIAL.apw"
	Else
		cCheckURL := Substr(cUrl,1,Rat("/",cUrl)-1)
	EndIf

	If ValType(oProcess) == "O"
		lNewProcess := .T. // Informa que a barra de processamento � um MsNewProcess
		oProcess:IncRegua1("Consultando registros no Servidor TSS ... ")
	EndIf

	If ValType(oMsgRun) == "O" .AND. !lJob
		IncMessagens(oMsgRun,"Consultando registros no Servidor TSS ... ")
	EndIf

	If Empty(AllTrim(cUrl))
		If lJob 
			TafConOut("O par�metro MV_TAFSURL n�o est� preenchido")
		Else
			cMsgRet := "O par�metro MV_TAFSURL n�o est� preenchido"
		EndIf
	Else
		If FindFunction("TAFTransFil")
			lTransFil := TAFTransFil(lJob) 
		EndIf
		
		If Empty(cIdEnt)
			If TAFCTSpd(cCheckURL,,, @cMsgRet,, lTransFil)
				cIdEnt := TAFRIdEnt(lTransFil,,,,, .T.) 
			Else
				If lJob
					TafConOut("N�o foi possivel conectar com o servidor TSS")
					TafConOut(cMsgRet)
				Else
					If Empty(AllTrim(cMsgRet))
						cMsgRet := "N�o foi possivel conectar com o servidor TSS"
					EndIf 
				EndIf
			EndIf
		EndIf
		
		If !Empty(cIdEnt)

			If TAFAlsInDic("V2H")
				dbSelectArea("V2H")
				dbSetOrder(2)
			EndIf 

			If TAFAlsInDic("V2J")
				dbSelectArea("V2J")
				dbSetOrder(1)
			EndIf 

			dbSelectArea("T0X")
			T0X->(dbSetOrder(3))

			If lJob
				cLog := "* Inicio Consulta TAFProc5 TheadId: " + cIdThread + " - Data de Inicio: " + DTOC(dDataBase) + " - " + cTimeProc
				TAFConOut(cLog)	

			EndIf

			lAllEventos	:= Empty(aEvtsESoc) //Quando n�o vem eventos selecionados devo considerar todos por que n�o houve marca��o no browse

			// Tratamento para funcionalidade via Job/Schedule
			If !lJob
			//	ProcRegua(Len(aEvtsESoc))
			EndIf

			cMsgProc := "Verificando itens transmitidos para o RET. "

			If lJob
				cQry := TAFQryXMLeSocial(cBancoDB,nTopSlct,,cStatus,aEvtsESoc,aIdTrab,cRecNos, cMsgProc,,aFiliais,,lJob,,lCommit,,@oTabFilSel,, cPeriod,,,,,,, dDataIni, dDataFim)
			Else
				cQry := TAFQryMonTSS(cBancoDB,nTopSlct,,cStatus,aEvtsESoc,aIdTrab,cRecNos, cMsgProc,,aFiliais,lAllEventos,dDataIni,dDataFim,,@oTabFilSel,lMV,lReavPen)
			EndIf
			
			cQry := ChangeQuery(cQry)
		
			TcQuery cQry New Alias (cAliasRegs)
			Count To nQtdRegs

			nQtdLote := Ceiling(nQtdRegs/nQtdPorLote)

			//-- Verifica se deve habilitar o processamento multithread de acordo com a quantidade de registros / lotes
			If IPcCount(cFuncP5) > 0

				lMThread := .T.

			ElseIf nQtdLote >= nQtLoteMT

				//-- Cria as threads de acordo com o parametro definido
				//-- Se for multithread
				lMThread := IIF(nMThread > 1, .T., .F.)

				If lMThread

					cJobName := StrTran(cJobName, " ", "")

					ManualJob(cFuncP5,;
						GetEnvServer(),;
						"IPC"/*Type*/,;
						"TAF_START"/*OnStart*/,;
						"TAF_CONJ5M"/*OnConnect*/,;
						""/*OnExit*/,;
						cEmpAnt,;
						60,;
						nMThread,;
						nMThread,;
						1,;
						1)
				EndIf
			EndIf		


			If lJob			
				TAFConOut("Quantidade de Lotes a serem consultados: " + AllTrim(Str(nQtdLote)))
			EndIf

			If lNewProcess
				oProcess:SetRegua2(nQtdLote)
			EndIf

			If nQtdRegs > 0
				(cAliasRegs)->(dbGoTop())	
				While (cAliasRegs)->(!Eof())
				
					cAlsEvt := Alltrim( ( cAliasRegs )->ALIASEVT )
				
					If TAFAlsInDic( cAlsEvt )
					
						cFunction := AllTrim( (cAliasRegs)->FUNCXML )
						
						If !(cAlsEvt $ cTabOpen)
							dbSelectArea(cAlsEvt)
							cTabOpen += "|" + cAlsEvt
						EndIf
						
						( cAlsEvt )->( dbGoTo( ( cAliasRegs )->RECTAB ) )
						
						cId := AllTrim ( STRTRAN( ( cAliasRegs )->LAYOUT , "-" , "" ) ) + AllTrim( ( cAliasRegs )->ID ) + AllTrim( ( cAliasRegs )->VERSAO )
						aAdd( aXmls , { "" , cId , ( cAliasRegs )->RECTAB , AllTrim( ( cAliasRegs )->LAYOUT ) , cAlsEvt, ( cAliasRegs )->FILIAL,(cAliasRegs )->ID } )
						nItem++
		
						If nItem == nQtdPorLote

							If lMThread

								While !IPCGo(cFuncP5, aXmls,cAmbte,,cUrl,lJob,cIdEnt,lNewProcess,oProcess,nQtdLote,@nLote,lGravaErrTab )

									If nTry <= nMaxTry
										Sleep(nTry * 1000)
										TafConOut("["+cFuncP5+"]["+ProcName()+"] Aguardando thread disponivel - Tentativa " + cValToChar(nTry))
										nTry++
									Else
										Exit 
									EndIf
								Enddo

								If nTry > nMaxTry 
									MsgAlert("Execu��o abortada por falta de Threads Dispon�veis. ")
									Exit
								Else
									nTry := 0
								EndIf
								
							Else
								aRetorno := TAFConRg(aXmls, cAmbte,, cUrl, lJob, cIdEnt, lNewProcess, oProcess, nQtdLote, @nLote, lGravaErrTab, oMsgRun, lTransFil, @cMsgRet, lRetResponse, lCallApi)
							EndIf

							If !lGravaErrTab .And. !lForceRetorno
								Aadd( aRetConsulta, aClone(aRetorno))
							EndIf

							aSize(aRetorno,0)
							aSize(aXmls,0)
							nItem := 0
						EndIf
		
					EndIf

					nCont := nCont + 1
					If ValType(oMsgRun) == "O" .AND. !lJob
						SetIncPerc( oMsgRun, "Consultando", nQtdRegs , nCont )
					EndIf

					(cAliasRegs)->(dbSkip())
				EndDo

				//Se houver, adiciono o residuo no array de lote
				If Len(aXmls) > 0
					aRetorno := TAFConRg(aXmls, cAmbte,, cUrl, lJob, cIdEnt, lNewProcess, oProcess, nQtdLote, @nLote, lGravaErrTab, oMsgRun, lTransFil, @cMsgRet, lRetResponse, lCallApi)
					If !lGravaErrTab .Or. lForceRetorno
						Aadd( aRetConsulta, aClone(aRetorno))
					EndIf
					aSize(aRetorno,0)
					aSize(aXmls,0)
				EndIf

			Else
				cMsgProc := "0 documento(s)  consultado(s)."			
				TafConOut(cMsgProc)
			EndIf

			If lNewProcess
				oProcess:IncRegua1("Finalizado.")
			EndIf

			If ValType(oMsgRun) == "O" .AND. !lJob
				IncMessagens(oMsgRun,"Finalizado.")
			EndIf

			cLog := "* Fim Consulta TAFProc5 TheadId: " + cIdThread + " - Data de Inicio: " + DTOC(dDataBase) + " - " + Time() + " - Tempo de processamento: " + ElapTime(cTimeProc,Time())  + " - Quantidade de Registros: " + AllTrim(Str(nQtdRegs))
			TafConOut(cLog)
			
		EndIf
	EndIf

	//--------------------------------------------------------------------
	// Deleta a tabela temporaria desde que n�o seja chamada da TAFMontES
	//--------------------------------------------------------------------
	If !lTabTmpExt .And. oTabFilSel <> NIL .And. Substr(GetRpoRelease(),1,2) == '12'
		oTabFilSel:Delete()
	EndIf

Return aRetConsulta

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFConRg  
Realiza consulta dos registros transmitidos.

@param	aXmlsLote  	- Array com os dados do Xml    
		cAmbiente	- Ambiente de Transmiss�o/Consulta 		  
					  [x][1] - Xml do Evento
					  [x][2] - Id(chave para transmiss�o)
					  [x][3] - RecNo do Evento na sua respectiva tabela
					  [x][4] - Layout que correspondente ao evento
					  [x][5] - Alias correspondente ao Evento
		lGrvRet		- Determina se deve ocorrer a grava��o dos status    
		cUrl		- Url - Url do servidor TSS para o Ambiente e-Social
		lJob		- Identifica se a rotina est� sendo executada por Job ou tela
		cIdEnt 		- Id da Entidade

@author Evandro dos Santos Oliveira
@since 19/11/2013
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function TAFConRg( aXmlsLote as array, cAmbiente as character, lGrvRet as logical, cUrl as character,;
						lJob as logical, cIdEnt as character, lNewProcess as logical, oProcess as object,;
						nQtdLote as numeric, nLote as numeric, lGravaErrTab as logical, oMsgRun as object,;
						lTransFil as logical, cMsgRet as character, lRetResponse as logical,;
						lCallApi as logical )

	Local aAreaTab      as array
	Local aEvtEsocial   as array
	Local aRetorno      as array
	Local cAliasTb      as character
	Local cAuxSts       as character
	Local cCodErroRet   as character
	Local cEmpEnv       as character
	Local cError        as character
	Local cEvtRetXml    as character
	Local cEvtTab       as character
	Local cFilErp       as character
	Local cFilEvt       as character
	Local cIdAux        as character
	Local cLayOut       as character
	Local cRecibo       as character
	Local cStatus       as character
	Local cTabOpen      as character
	Local cWarning      as character
	Local lGrvTotFilial as logical
	Local lMvTotExdt    as logical
	Local lRet          as logical
	Local lTotaliz      as logical
	Local lVersion12    as logical
	Local nJ            as numeric
	Local nSizeFil      as numeric
	Local nY            as numeric
	Local oErroRet      as object
	Local oHashXML      as object

	Local xRetXML       := Nil

	Default aXmlsLote		:= {}
	Default cAmbiente		:= ""
	Default lGrvRet			:= .T.
	Default cIdEnt			:= ""
	Default nLote			:= 0
	Default lGravaErrTab	:= .F.
	Default oMsgRun         := Nil
	Default cMsgRet			:= ""
	Default lTransFil		:= .F.
	Default lRetResponse	:= .F.
	Default lCallApi		:= .F.

	aAreaTab      := {}
	aEvtEsocial   := TAFRotinas(,,.T.,2)
	aRetorno      := {}
	cAliasTb      := ""
	cAuxSts       := ""
	cCodErroRet   := ""
	cEmpEnv       := ""
	cError        := ""
	cEvtRetXml    := ""
	cEvtTab       := ""
	cFilErp       := ""
	cFilEvt       := ""
	cIdAux        := ""
	cLayOut       := ""
	cRecibo       := ""
	cStatus       := ""
	cTabOpen      := ""
	cWarning      := ""
	lGrvTotFilial := .F.
	lMvTotExdt    := .F.
	lRet          := .F.
	lTotaliz      := .F.
	lVersion12    := Substr(GetRpoRelease(),1,2) == '12'
	nJ            := 0
	nSizeFil      := 0
	nY            := 0
	oErroRet      := Nil
	oHashXML      := Nil

	If lCallApi .And. lRetResponse

		cEvtRetXml := "S-1299|S-2210"

	ElseIf !lCallApi .AND. !lRetResponse

		cEvtRetXml := "S-1200|S-1210|S-1295|S-1299|S-2299|S-2399"

	EndIf

	For nJ := 1 to Len(aEvtEsocial)
		If aEvtEsocial[nJ,12] == 'C'
			cEvtTab +=  aEvtEsocial[nJ,3] + "|"
		EndIf
	Next nJ


	If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
		lMvTotExdt := .T. 
	EndIf 

	nLote++

	If lNewProcess
		oProcess:IncRegua2("Consultando Eventos no TSS - Lote " + AllTrim(Str(nLote)) + "/" + AllTrim(Str(nQtdLote)) + ". " )
	Else
		ProcRegua(Len(aXmlsLote))
	EndIf

	If ValType(oMsgRun) == "O" .AND. !lJob
		IncMessagens(oMsgRun,"Consultando Eventos no TSS - Lote " + AllTrim(Str(nLote)) + "/" + AllTrim(Str(nQtdLote)) + ". ")
	EndIf

	aRetorno := GetXmlRetTss(aXmlsLote, cUrl, cIdEnt, cAmbiente, cEvtRetXml, @lRet,, lTransFil, @cMsgRet)
																															
	If ValType(lRet) == "L"   
	
		If lRet
			If lVersion12
				oHashXML	:=	AToHM(aXmlsLote, 2, 3 )
			Else
				oHashXML	:=	TafXAToHM(aXmlsLote, 2, 3 )	
			EndIf 

			If (lGrvRet)	
				For nY := 1 To Len(aRetorno)

					cIdAux := AllTrim(aRetorno[nY]:CID)
					If lVersion12
						HMGet( oHashXML , cIdAux ,@xRetXML )
					Else
						TafXHMGet( oHashXML , cIdAux ,@xRetXML )
					EndIf 

					If ValType(xRetXML[1][3]) == "N"

						cAliasTb := xRetXML[1][5]
						If !(cAliasTb $ cTabOpen)
							cTabOpen += "|" + cAliasTb
							dbSelectArea(cAliasTb)
						EndIf

						(cAliasTb)->(dbGoTo(xRetXML[1][3]))
						cLayOut := xRetXML[1][4]

						dbSelectArea("C1E")
						C1E->(dbSetOrder(3))
						
						If lMvTotExdt .And. (AllTrim(FwCodFil()) != AllTrim((cAliasTb)->&(cAliasTb + "_FILIAL"))) 
							If ( cLayOut $ cEvtRetXml ) .and. !Empty( ( cAliasTb )->&( cAliasTb + "_FILIAL" ) )
								C1E->(MsSeek(xFilial("C1E")+(cAliasTb)->&(cAliasTb + "_FILIAL")+"1"))
								lGrvTotFilial := .T.
							Else
								C1E->(MsSeek(xFilial("C1E")+cFilAnt+"1"))
							Endif
						Else
							C1E->(MsSeek(xFilial("C1E")+cFilAnt+"1"))
						Endif

						cFilErp := AllTrim(C1E->C1E_CODFIL )

						//dbGoTo(xRetXML[1][3])
						If aRetorno[nY]:LSUCESSO

							// |Status de Retorno dos Documentos
							// |
							//1 � Recebido
							//2 � Assinado
							//3 � Erro de schema
							//4 � Aguardando transmiss�o
							//5 � Rejei��o
							//6 � Autorizado
					   
							cStatus :=  aRetorno[nY]:CSTATUS
							cChave 	:=  aRetorno[nY]:CCHAVE
							//Retorno do N�mero do Recibo de Transmiss�o do TSS.
							cRecibo := 	AllTrim(aRetorno[nY]:CRECIBO)
							(cAliasTb)->(dbGoTo(xRetXML[1][3]))
							cFilEvt := xRetXML[1][6]
							nSizeFil := FWSizeFilial()
							cFilEvt := PADR(cFilEvt,nSizeFil)
							cEmpEnv := FWGrpCompany()
	

							//Retirado de dentro do transaction por que quando ocorre erro na gravacao de 1 totalizador a exception faz rollback
							//do totalizador ja gravador - Issue DSERTAF1-21025	
							If cStatus == "6"
								lTotaliz := .F.
								If cLayout $ cEvtRetXml .And. ValType(aRetorno[nY]:CXMLEVENTO) <> "U"
									aAreaTab	:= (cAliasTb)->(GetArea())
									cFilBkp 	:= cFilAnt

									If lGrvTotFilial
										//Posiciona na filial para a correta gravacao do totalizador mediante ao parametro MV_TOTEXDT
										If SM0->(MsSeek(cEmpEnv + PADR(cFilEvt,nSizeFil)))
											cEmpAnt := SM0->M0_CODIGO
											cFilAnt := SM0->M0_CODFIL
										Else
											TafConOut("Parametro MV_TOTEXDT preenchido e Filial n�o encontrada no arquivo de empresas.",2)	
										Endif
									EndIf 

									cMsgRet += GeraEvtTot(aRetorno[nY]:CXMLEVENTO, cLayout, cAliasTb, cFilErp, @lTotaliz, cIdAux, cFilEvt, @cRecibo, xRetXML[1][3])
									cFilAnt := cFilBkp
									SM0->(MsSeek(cEmpEnv + PADR(cFilBkp,nSizeFil)))
														
									If TAFAlsInDic("V2J") 
										limpaTotV2J(cIdAux,cFilEvt)
									EndIf 

									RestArea(aAreaTab)
								EndIf
							EndIf 							

							BEGIN TRANSACTION

								If cLayOut $ "S-3000|S-3500"

									cMsgRet += gravaStsExclusao(cStatus,cFilEvt,cLayOut)[2]

								EndIf

								If cStatus == "6" .AND. !lRetResponse

									limpaRegT0X(cIdAux)
									If TAFAlsInDic("V2H")
										limpaRegV2H(cIdAux,cFilEvt)
									EndIf 

									If  AllTrim(aRetorno[nY]:CCODRECEITA) == "202"

										aAreaTab := (cAliasTb)->(GetArea())
										If lGravaErrTab .Or. TAFAlsInDic("V2H")
											gravaErr(aRetorno[nY],cFilEvt,AllTrim(xRetXML[1][7]),AllTrim(xRetXML[1][4]),lJob,cMsgRet)
										EndIf
										RestArea(aAreaTab)

									EndIf 

								ElseIf cStatus == "5"
									cError := ""
									// � necess�rio   se realmente foi retornado o XML do erro pelo RET.
									If ValType(aRetorno[nY]:CXMLERRORET) <> "U"
										oErroRet  := XmlParser( EncodeUTF8(aRetorno[nY]:CXMLERRORET), "_", @cError, @cWarning )
										If Empty(cError) .And. ValType(oErroRet) == "O" 									
											If Valtype(XmlChildEx(oErroRet,"_OCORRENCIAS")) == "O" 										
												If Valtype(XmlChildEx(oErroRet:_OCORRENCIAS,"_OCORRENCIA")) == "O" .And. Valtype(XmlChildEx(oErroRet:_OCORRENCIAS:_OCORRENCIA,"_CODIGO")) == "O"
											
													cCodErroRet := oErroRet:_OCORRENCIAS:_OCORRENCIA:_CODIGO:Text
												ElseIf  Valtype(XmlChildEx(oErroRet:_OCORRENCIAS,"_OCORRENCIA")) == "A"

													cCodErroRet := oErroRet:_OCORRENCIAS:_OCORRENCIA[1]:_CODIGO:Text
												EndIf 	
											ElseIf Valtype(XmlChildEx(oErroRet,"_RETORNOPROCESSAMENTOLOTEEVENTOS")) == "O"
													cCodErroRet := oErroRet:_RETORNOPROCESSAMENTOLOTEEVENTOS:_STATUS:_CDRESPOSTA:Text
											EndIf	
										EndIf
									EndIf
									
									limpaRegT0X(cIdAux)
									
									//Os codigos de erro 402, 543 ou 609 s�o apresentados quando h� duplicidade no XMLID ou mesmo esta gerado de forma incorreta, por isso ele � apagado para ser regerado.
									If TAFColumnPos( cAliasTb+"_XMLID" )
										If AllTrim(cCodErroRet) $ "402|543|609"
											RecLock((cAliasTb),.F.)
											(cAliasTb)->&(cAliasTb+"_XMLID") := ""
											(cAliasTb)->(MsUnlock())
										// Todos os outros codigos de erros s�o tratados e realizada a grava��o do XMLID.										
										ElseIf !Empty(cChave) .AND. Empty( (cAliasTb)->&(cAliasTb+"_XMLID") )
											RecLock((cAliasTb),.F.)
											(cAliasTb)->&(cAliasTb+"_XMLID")	:=	cChave
											(cAliasTb)->(MsUnlock())
										EndIf
									Endif

									aAreaTab := (cAliasTb)->(GetArea())
									If lGravaErrTab .Or. TAFAlsInDic("V2H")

										cFilEvt := xRetXML[1][6]
										nSizeFil := FWSizeFilial()
										cFilEvt := PADR(cFilEvt,nSizeFil)

										If !gravaErr(aRetorno[nY],cFilEvt,AllTrim(xRetXML[1][7]),AllTrim(xRetXML[1][4]),lJob,cMsgRet)

											//Refa�o o request deste item para tentar obter o erro buscando o XML completo de retorno 
											aRetAux := GetXmlRetTss(xRetXML, cUrl, cIdEnt, cAmbiente, cEvtRetXml, @lRet, .T., lTransFil, @cMsgRet)	
											If Len(aRetAux) > 0
												gravaErr(aRetAux[1],cFilEvt,AllTrim(xRetXML[1][7]),AllTrim(xRetXML[1][4]),lJob,cMsgRet)		
											EndIf 
										EndIf 
									EndIf
									RestArea(aAreaTab)
								
								EndIf
								
								cAuxSts := TAFStsXTSS(cStatus) 
		
								//Gravo o status do registro de retorno
								If !Empty(cAuxSts)
									DbSelectArea(cAliasTb)
									(cAliasTb)->(DbGoTo(xRetXML[1][3]))

									If (cAliasTb)->(RecLock(cAliasTb, .F.))
										If TAFColumnPos(cAliasTb + "_STATUS")
											If (cAliasTb)->&(cAliasTb+"_STATUS") <> "4"
												(cAliasTb)->&(cAliasTb+"_STATUS") := cAuxSts 
											EndIf
										EndIf
										
										If cLayout $ cEvtRetXml
											If TAFColumnPos(cAliasTb+"_GRVTOT")
												(cAliasTb)->&(cAliasTb+"_GRVTOT") := lTotaliz
											EndIf 
										EndIf 
			
										//Gravo o numero do protocolo de transmiss�o do TSS.
										If !Empty(cRecibo)
											If TAFColumnPos(cAliasTb + "_PROTUL")
												(cAliasTb)->&(cAliasTb+"_PROTUL") := cRecibo 
											EndIf

											//Verificar se � um evento de tabela e de exclus�o
											//Caso seja, inativo a exclus�o transmitida corretamente para que um novo registro igual possa ser incluido
											If cAliasTb $(cEvtTab) .And. (cAliasTb)->&(cAliasTb+"_EVENTO") == 'E'
												(cAliasTb)->&(cAliasTb+"_ATIVO") := '2'
											EndIf

											If TafColumnPos(cAliasTb + "_DTRECP")
												(cAliasTb)->&(cAliasTb + "_DTRECP") := DATE()
												(cAliasTb)->&(cAliasTb + "_HRRECP") := TIME()
											EndIf
										EndIf
		
										(cAliasTb)->(MsUnlock())
									EndIf	
								EndIf

				   			END TRANSACTION
						Else
							BEGIN TRANSACTION
							If TAFColumnPos(cAliasTb + "_STATUS")
								If (cAliasTb)->&(cAliasTb+"_STATUS") <> '4'
									cMsgRet := "Layout " + cLayOut + " - Id " + cIdAux  + " Problemas no Arquivo: "
									cMsgRet += aRetorno[nY]:CDETSTATUS
								
									RecLock((cAliasTb),.F.)
										(cAliasTb)->&(cAliasTb+"_STATUS") := '3'
									(cAliasTb)->(MsUnlock())
									
									aAreaTab := (cAliasTb)->(GetArea())
									If lGravaErrTab .Or. TAFAlsInDic("V2H")

										cFilEvt := xRetXML[1][6]
										nSizeFil := FWSizeFilial()
										cFilEvt := PADR(cFilEvt,nSizeFil)
										gravaErr(aRetorno[nY],cFilEvt,AllTrim(xRetXML[1][7]),AllTrim(xRetXML[1][4]),lJob,cMsgRet)
									EndIf
									RestArea(aAreaTab)
								EndIf
							EndIf
							END TRANSACTION
						EndIf
						
						
					Else
						cMsgRet := "Id " + cIdAux +" n�o encontrado no lote de envio. "
					EndIf

					If (lGravaErrTab .Or. TAFAlsInDic("V2H") .And. IsInCallStack("TAFMONDET")) .And. !IsInCallStack("mostraXMLErro")
						If ValType(aRetorno[nY]) == "O"
							FreeObj(aRetorno[nY])
							aRetorno[nY] := Nil 
						EndIf 
					EndIf 

				Next nY
			EndIf
		Else
			cMsgRet := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)) //SOAPFAULT
		EndIf
	Else
		cMsgRet := "Retorno do WS n�o � do tipo l�gico. "
		cMsgRet += CRLF + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
	EndIf
	
	If ValType("oHashXML") == "O"
		FreeObj(oHashXML)
		oHashXML := Nil
	EndIf

	aSize(aXmlsLote,0)

	DelClassIntF()

	If !Empty(cMsgRet)
		TafConOut(cMsgRet)
	EndIf

Return aRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} gravaErr

Grava os Erros da transmiss�o.

@param aRetorno - Array com o Retorno do TSS
@param cFil - Filial do Registro
@param cId - Id do Registro
@param cEvento - Evento relacionado ao Registro
@parma lJob - Informa se a rotina est� sendo executada por um Job
@parm cMsgRet - Mensagem de retorno

@Author		Evandro dos Santos O. Teixeira
@Since		29/05/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function gravaErr(aRetorno,cFil,cId,cEvento,lJob,cMsgRet)

	Local cSql 			:= ""
	Local cBanco		:= AllTrim(TCGetDB())
	Local cXml			:= ""
	Local nItem			:= 1
	Local cTipoErr  	:= ""
	Local cCodErr		:= ""
	Local cDescErr  	:= ""
	Local cDescResp 	:= ""
	Local nTamChv		:= 0
	Local lVersion12 	:= Substr(GetRpoRelease(),1,2) == '12'
	Local lCommitV2H 	:= .F.  
	Local lNoOcorr   	:= .F. 
	Local lRet202    	:= .F.
	Local cLocalErr  	:= ""
	Local cSequencia	:= "" 
	
	Private oXml  := Nil

	Default lJob := IsBlind()

	If TAFAlsInDic("V2H")

		nTamChv := GetSx3Cache("V2H_IDCHVE","X3_TAMANHO")

		//Se retornar Nil � por que n�o est� com EncodeUTF8
		//o Servidor TSS as vezes retorna o XML sem Encode
		//ocasionando erro no Parser.

		If ValType(DecodeUTF8(aRetorno:CXMLERRORET)) == "U"
			cXml := EncodeUTF8(aRetorno:CXMLERRORET)
		Else
			cXml := aRetorno:CXMLERRORET
		EndIf 

		If AllTrim(cEvento) == "S-1000"
			cFil := xFilial("C1E")							
		EndIf
		
		oXml := tXmlManager():New()		

		If !Empty(cXml) .And. oXML:Parse( cXml )
			
			oXml:bDecodeUtf8 := .T.
			
			If oXml:XPathHasNode("/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]")

				While oXml:XPathHasNode("/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]")

					If nItem >= 1

						If oXml:xPathHasNode( "/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]/tipo" )
							cTipoErr := oXml:xPathGetNodeValue( "/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]/tipo" )
						EndIf

						If oXml:xPathHasNode( "/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]/codigo" )
							cCodErr := oXml:xPathGetNodeValue( "/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]/codigo" )
						EndIf

						If oXml:xPathHasNode( "/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]/descricao" )
							cDescErr := oXml:xPathGetNodeValue( "/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]/descricao" )
						EndIf

						If oXml:xPathHasNode( "/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]/localizacao" )
							cLocalErr := oXml:xPathGetNodeValue( "/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]/localizacao" )
						EndIf

						cSequencia := StrZero(nItem, GetSX3Cache("V2H_SEQERR", "X3_TAMANHO"))
						
						If V2H->(MsSeek(cFil + PADR(fixNull(aRetorno:CID), nTamChv) + cSequencia))
							limpaRegV2H(PADR(fixNull(aRetorno:CID),nTamChv),cFil)
						EndIf

						lCommitV2H := recV2H(aRetorno, cFil, cEvento, cTipoErr, cDescErr, cUserName, cCodErr, cDescResp, cSequencia, lJob, cLocalErr)

					EndIf

					nItem++

				EndDo	

			Else

				lNoOcorr := .T.

				If oXml:XPathHasNode("/retornoProcessamentoLoteEventos/status")

					cTipoErr	:= "001" 	// Tipo Advert�ncia
					cCodErr 	:= oXml:xPathGetNodeValue( "/retornoProcessamentoLoteEventos/status/cdResposta" )		// C�digo do Erro
					cDescErr	:= oXml:xPathGetNodeValue( "/retornoProcessamentoLoteEventos/status/descResposta" )	// Descri��o do Erro	
					cSequencia	:= StrZero(nItem, GetSX3Cache("V2H_SEQERR", "X3_TAMANHO"))

					If V2H->(MsSeek(cFil + PADR(fixNull(aRetorno:CID), nTamChv) + cSequencia))
						limpaRegV2H(PADR(fixNull(aRetorno:CID),nTamChv),cFil)
					EndIf
	
					If RecLock( "V2H", .T. )
	
						V2H->V2H_FILIAL := cFil
						V2H->V2H_ID 	:= TafGeraID("TAF")
						V2H->V2H_IDCHVE := fixNull(aRetorno:CID)
						V2H->V2H_EVENTO := cEvento
						V2H->V2H_DETAIL := fixNull(aRetorno:CDETSTATUS)
						V2H->V2H_TPERRO := cTipoErr
						V2H->V2H_DSCREC := fixNull(aRetorno:CDSCRECEITA)
						V2H->V2H_PROTUL := fixNull(aRetorno:CPROTOCOLO)
						V2H->V2H_DCERRO := cDescErr
						V2H->V2H_CODREC := fixNull(aRetorno:CCODRECEITA,3)
						V2H->V2H_DATA   := dDataBase
						V2H->V2H_HORA   := Time()
						V2H->V2H_SEQERR := cSequencia
						V2H->V2H_CODERR	:= cCodErr
	
						If lJob
							V2H->V2H_USER := "__Schedule"
						Else
							V2H->V2H_USER := cUserName
						Endif
						V2H ->(MsUnlock())
	
					EndIf
	
				EndIf
			EndIf
		Else
			 lNoOcorr := .T. 
		EndIf 

		If lNoOcorr

			If ValType(DecodeUTF8(aRetorno:CXMLEVENTO)) == "U"
				cXml := EncodeUTF8(aRetorno:CXMLEVENTO)
			Else
				cXml := aRetorno:CXMLEVENTO
			EndIf 

			If !Empty(cXml) .And. oXML:Parse( cXml )

				//Tratativa para recuperar as mensagens de inconssit�ncia quando o RET nao retorna as ocorr�ncias
				oXml:XPathRegisterNS( "ns1", "http://www.esocial.gov.br/schema/evt/retornoEvento/v1_2_0" )
				oXml:XPathRegisterNS( "ns2", "http://www.esocial.gov.br/schema/evt/retornoEvento/v1_2_1" )

				cDescResp := getDescResposta(oXml,"/")
				If Empty(AllTrim(cDescResp))
					getDescResposta(oXml)
				EndIf 

				If aRetorno:CCODRECEITA = "202"

					lRet202 := gravaOcorr202(oXml,"/","ns2",cFil,cEvento,nTamChv,aRetorno,cDescResp,cUserName,lJob)
					If !lRet202

						lRet202 := gravaOcorr202(oXml,"/","ns1",cFil,cEvento,nTamChv,aRetorno,cDescResp,cUserName,lJob)
					
						If !lRet202 

							lRet202 := gravaOcorr202(oXml,"","ns2",cFil,cEvento,nTamChv,aRetorno,cDescResp,cUserName,lJob)
							
							If !lRet202
								gravaOcorr202(oXml,"","ns1",cFil,cEvento,nTamChv,aRetorno,cDescResp,cUserName,lJob)
							EndIf 
						EndIf 
					EndIf 
					
				Else

					cSequencia := StrZero(nItem, GetSX3Cache("V2H_SEQERR", "X3_TAMANHO")) 
				
					If  V2H->(MsSeek(cFil + PADR(fixNull(aRetorno:CID), nTamChv) + cSequencia))
						limpaRegV2H(PADR(fixNull(aRetorno:CID),nTamChv),cFil)
					EndIf

					lCommitV2H := recV2H(aRetorno, cFil, cEvento, cTipoErr, cDescErr, cUserName, cCodErr, cDescResp, cSequencia, lJob, cLocalErr)
				
				EndIf 
			EndIf 	
		EndIf

		If ValType(oXml) == "O"
			FreeObj(oXml)
			oXml := Nil 
		EndIf

	ElseIf lVersion12

		cSql := " INSERT INTO " + cArqREtTss:GetRealName()
		cSql += " (FILIAL,ID,EVENTO,DETSTATUS,DSCRECEITA,RECIBO,XMLERRORET,CODRECEITA,STATUS)
		cSql += " VALUES ("
		cSql +=  "'" + cFil +"'"
		cSql +=  ",'" + cId +"'"
		cSql +=  ",'" + cEvento +"'"
		cSql +=  ",'" + fixNull(aRetorno:CDETSTATUS,250)  	+"'"
		cSql +=  ",'" + fixNull(aRetorno:CDSCRECEITA,250) 	+"'"
		cSql +=  ",'" + fixNull(aRetorno:CRECIBO,44) 		+"'"
	//	cSql +=  ",'" + fixNull(aRetorno:CHISTPROC) 	+"'"
		cSql +=  ",'" + fixNull(aRetorno:CXMLERRORET, Iif( cBanco == "INFORMIX" .Or. cBanco == "POSTGRES", 250, 2000 )) + "'"
		cSql +=  ",'" + fixNull(aRetorno:CCODRECEITA,3) 	+"'"
		cSql +=  ",'" + fixNull(aRetorno:CSTATUS,1)			+"'"
		cSql += " )"


		If TCSQLExec (cSql) < 0
			If lJob
				TafConOut(TCSQLError())
			Else
				cMsgRet += TCSQLError()
			EndIf
		EndIf
	EndIf 

Return lCommitV2H

Static Function getDescResposta(oXml,cTagRaiz)

	Local cDescResp := ""
	Default cTagRaiz := ""

	If oXml:xPathHasNode(cTagRaiz + "evento/retornoEvento/ns1:eSocial/ns1:retornoEvento/ns1:processamento/ns1:descResposta" ) 
		cDescResp := oXml:xPathGetNodeValue(cTagRaiz +"evento/retornoEvento/ns1:eSocial/ns1:retornoEvento/ns1:processamento/ns1:descResposta" )
	ElseIf oXml:xPathHasNode(cTagRaiz + "evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:descResposta" )
		cDescResp := oXml:xPathGetNodeValue(cTagRaiz + "evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:descResposta" )
	EndIf

Return cDescResp 

Static Function gravaOcorr202(oXml,cTagRaiz,ns,cFil,cEvento,nTamChv,aRetorno,cDescResp,cUserName,lJob)

	Local cNodeNs 		:= ""
	Local nItem 		:= 1
	Local cTipoErr 		:= ""
	Local cCodErr 		:= ""
	Local cDescErr 		:= ""
	Local lCommitV2H 	:= .F.
	Local cSequencia	:= "" 
	
	Default cTagRaiz := ""

	cNodeNs := cTagRaiz + "evento/retornoEvento/" + ns + ":eSocial/" + ns + ":retornoEvento/" + ns + ":processamento/" + ns + ":ocorrencias" 

	If oXml:xPathHasNode(cNodeNs) 

		While oXml:XPathHasNode(cNodeNs + "/" + ns + ":ocorrencia[" + cValToChar(nItem)+ "]")
			
			If nItem >= 1
				If oXml:xPathHasNode(cNodeNs + "/" + ns + ":ocorrencia[" + cValToChar(nItem)+ "]/" + ns + ":tipo" )
					cTipoErr := oXml:xPathGetNodeValue(cNodeNs + "/" + ns + ":ocorrencia["+ cValToChar(nItem)+ "]/" + ns + ":tipo" )
				EndIf

				If oXml:xPathHasNode(cNodeNs + "/" + ns + ":ocorrencia[" + cValToChar(nItem)+ "]/" + ns + ":codigo" )
					cCodErr := oXml:xPathGetNodeValue(cNodeNs + "/" + ns + ":ocorrencia[" + cValToChar(nItem)+ "]/" + ns + ":codigo" )
				EndIf

				If oXml:xPathHasNode(cNodeNs + "/" + ns + ":ocorrencia[" + cValToChar(nItem) + "]/" + ns + ":descricao" )
					cDescErr := oXml:xPathGetNodeValue(cNodeNs + "/" + ns + ":ocorrencia[" + cValToChar(nItem)+ "]/" + ns + ":descricao" )
				EndIf

				If oXml:xPathHasNode(cNodeNs + "/" + ns + ":ocorrencia[" + cValToChar(nItem) + "]/" + ns + ":localizacao" )
					cLocalErr := oXml:xPathGetNodeValue(cNodeNs + "/" + ns + ":ocorrencia[" + cValToChar(nItem)+ "]/" + ns + ":localizacao" )
				EndIf

				cSequencia := StrZero(nItem, GetSX3Cache("V2H_SEQERR", "X3_TAMANHO"))

				If  V2H->(MsSeek(cFil + PADR(fixNull(aRetorno:CID), nTamChv) + cSequencia))
					limpaRegV2H(PADR(fixNull(aRetorno:CID),nTamChv),cFil)
				EndIf

				lCommitV2H := recV2H(aRetorno, cFil, cEvento, cTipoErr, cDescErr, cUserName, cCodErr, cDescResp, cSequencia, lJob, cLocalErr)

				nItem++

			EndIf

		EndDo 
	EndIf

Return lCommitV2H

Static Function recV2H(aXmlsRetorno,cFil,cEvento,cTipoErr,cDescErr,cUserName,cCodErr,cDescResp,cSequencia,lJob,cLocalErr)

	Local lRecOk := .F. 

	Default cSequencia := "000001"

	lRecOk := RecLock( "V2H", .T. )

	If lRecOk

		V2H->V2H_FILIAL := cFil
		V2H->V2H_ID 	:= TafGeraID("TAF")
		V2H->V2H_IDCHVE := fixNull(aXmlsRetorno:CID)
		V2H->V2H_EVENTO := cEvento
		V2H->V2H_DETAIL := fixNull(aXmlsRetorno:CDETSTATUS)
		V2H->V2H_TPERRO := cTipoErr
		V2H->V2H_DSCREC := fixNull(aXmlsRetorno:CDSCRECEITA)
		V2H->V2H_PROTUL := fixNull(aXmlsRetorno:CPROTOCOLO)
		V2H->V2H_DCERRO := cDescErr
		V2H->V2H_CODREC := fixNull(aXmlsRetorno:CCODRECEITA,3)
		V2H->V2H_DATA   := dDataBase
		V2H->V2H_HORA   := TIme()
		V2H->V2H_SEQERR := cSequencia
		V2H->V2H_CODERR	:= cCodErr

		If TafColumnPos("V2H_LOCERR")
			V2H->V2H_LOCERR := cLocalErr
		EndIf 

		If TafColumnPos("V2H_DCRESP")
			V2H->V2H_DCRESP := cDescResp
		EndIf 

		If lJob
			V2H->V2H_USER := "__Schedule"
		Else
			V2H->V2H_USER := cUserName
		Endif
		V2H ->(MsUnlock())
	EndIf 

Return lRecOk 
//---------------------------------------------------------------------
/*/{Protheus.doc} ajustaNull

Verifica se o valor da String � '', nesses casos � necess�rio inserir
1 espa�o por que o Banco Oracle considera este valor Null e retorna
o erro ORA-01400

@Param  cField - Campo a ser avaliado.
@param  nTamanho - Tamanho maximo do campo

@Author		Evandro dos Santos O. Teixeira
@Since		29/05/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function fixNull(cField,nTamanho)

	Local cValueRet := ""
	Default nTamanho := 0

	If nTamanho == 0
		cValueRet := IIf(Empty(cField),' ',cField)
	Else
		cValueRet := IIf(Empty(cField),' ',Substr(cField,1,nTamanho))
	EndIf

Return  (cValueRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFStsXTSS

De/Para dos C�digos de Retorno do TSS x TAF

@Param  cStatus - Status de retorno do TSS
@return cStatusTAF - Status de retorno do TAF

@Author		Evandro dos Santos O. Teixeira
@Since		13/08/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFStsXTSS(cStatus)

	Local cStatusTAF := "9"

	//Aguardando retorno
	If cStatus $ "124"
		cStatusTAF :=  '2'
	Endif
	//Documento recusado
	If cStatus $ "35"
		cStatusTAF := '3'
	Endif
	//Documento autorizado
	If cStatus == "6"
		cStatusTAF := '4'
	Endif
	
Return cStatusTAF

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFStsEXTSS

De/Para dos C�digos de Retorno do TSS x TAF (Eventos Excluidos)
Obs. Quando � enviado um registro S-3000 o evento que est� sendo
vinculado na exclus�o � identificado com os status 6 - Aguardando
Exclus�o e 7 - Registro excluido com sucesso.

@Param  cStatus - Status de retorno do TSS
@return cStatusTAF - Status de retorno do TAF

@Author		Evandro dos Santos O. Teixeira
@Since		13/08/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFStsEXTSS(cStatus)

	Local cRetorno := ""

	//Documento autorizado (exclus�o)
	If cStatus == "6"
		//Registro Excluido
		cRetorno := '7'
	Else
		//Aguardando retorno da Exclusao
		cRetorno :=  '6'
	Endif
		
Return cRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} gravaStsExclusao

Atualiza registros excluidos de acordo com o retorno do S-3000
Obs. O registro S-3000 deve estar posicionado.

@Param  cStatus - Status de retorno do TSS
@Param  cFilEvt - Filial do Evento de acordo com o Browse
@return x - [1] - Status da grava��o (logico)
		    [2] - Descri��o efetividade da grava��o

@Author		Evandro dos Santos O. Teixeira
@Since		13/08/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function gravaStsExclusao( cStatus as character, cFilEvt as character, cLayOut as character)

	Local cAlias       as character
	Local cEvtExcluido as character
	Local cAliasExclu  as character
	Local cMsgRet      as character
	Local cStatusEx    as character
	Local cIdCM6       as character
	Local cAliasCM6    as character
	Local cAliasTot    as character
	Local cNrRecTot    as character
	Local nOrdRecibo   as numeric
	Local nRecNo       as numeric
	Local lGravaOk     as logical
	Local aEvtExcluido as array
	Local aChaveV3N    as array
	Local oReport      as object

	Default cStatus := ""
	Default cFilEvt := ""
	Default cLayOut := ""

	cAlias          := IIF(cLayOut=="S-3500", "V7J", "CMJ")
	cEvtExcluido    := Posicione( 'C8E' ,1,xFilial("C8E")+(cAlias)->&(cAlias + "_TPEVEN"),"C8E_CODIGO")
	cAliasExclu     := ""
	cMsgRet         := ""
	cStatusEx       := ""
	cIdCM6          := ""
	cAliasCM6       := ""
	cAliasTot       := ""
	cNrRecTot       := ""
	nOrdRecibo      := 0
	nRecNo          := 0
	lGravaOk        := .T.
	aEvtExcluido    := TAFRotinas(cEvtExcluido,4,.F.,2)
	aChaveV3N       := {}
	oReport         := Nil
	
	If Len(aEvtExcluido) > 1
		cAliasExclu  := aEvtExcluido[3]
		nOrdRecibo	 := aEvtExcluido[13]

		dbSelectArea(cAliasExclu)
		dbSetOrder(nOrdRecibo)
		
		If ( cAliasExclu )->( MsSeek( cFilEvt + PADR( AllTrim((cAlias)->&(cAlias + "_NRRECI")), GetSx3Cache( cAlias + "_NRRECI", "X3_TAMANHO" ) ) ) )
			//Posiciono primeiro para achar o Id, deixando assim a consulta + performatica pois n�o tenho um indice
			//para o campo PROTPN
			nRecNo := foundPendExclusao( cAliasExclu, cFilEvt, (cAliasExclu)->&(cAliasExclu + "_ID"), AllTrim( (cAlias)->&(cAlias + "_NRRECI") ) )

			If nRecNo > 0

				(cAliasExclu)->(dbGoTo(nRecNo))
				
				cStatusEx := TAFStsEXTSS(cStatus)
				
				RecLock((cAliasExclu),.F.)
					(cAliasExclu)->&(cAliasExclu+"_STATUS") := cStatusEx
					(cAliasExclu)->&(cAliasExclu+"_ATIVO")  := IIF(cStatusEx == '6','1','2')
				(cAliasExclu)->(MsUnlock())

				cMsgRet := "Atualiza��o do Status de exclus�o do evento " + cEvtExcluido + " realizado com sucesso."

				//Opera��o para casos em que foi transmitido um S-3000 de um Evento que possui rela��o com o Totalizador S-5001 e/ou S-5003
				If cAliasExclu == "CMD" .or. cAliasExclu == "T92" .or. cAliasExclu == "C91"
					cNrRecTot := ( cAliasExclu )->&( cAliasExclu + "_PROTPN" )

					//Realiza a limpeza da tabela de Movimenta��o de Remunera��es
					If TAFAlsInDic( "V3N" )
						aChaveV3N := GetV3NChv( cAliasExclu )

						oReport := TAFSocialReport():New()
						oReport:Delete(aChaveV3N[1],aChaveV3N[2],aChaveV3N[3],aChaveV3N[4],aChaveV3N[5],'','',.T. )
						FreeObj( oReport )
					EndIf

					//S-5001
					cAliasTot := GetNextAlias()

					BeginSql Alias cAliasTot
						SELECT T2M.R_E_C_N_O_ RECNOT2M
						FROM %table:T2M% T2M
						WHERE T2M.T2M_NRRECI = %exp:cNrRecTot%
						  AND T2M.T2M_ATIVO = '1'
						  AND T2M.%notDel%
					EndSql

					( cAliasTot )->( DBGoTop() )
					If ( cAliasTot )->( !Eof() )
						T2M->( DBGoTo( ( cAliasTot )->RECNOT2M ) )

						RecLock( "T2M", .F. )
						T2M->T2M_ATIVO := "2"
						T2M->( MsUnlock() )
					EndIf

					( cAliasTot )->( DBCloseArea() )

					//S-5003

					//-- Prote��o para n�o causar erro no layout 2.4
					If TAFAlsInDic("V2P")
						cAliasTot := GetNextAlias()

						BeginSql Alias cAliasTot
							SELECT V2P.R_E_C_N_O_ RECNOV2P
							FROM %table:V2P% V2P
							WHERE V2P.V2P_NRRECI = %exp:cNrRecTot%
							AND V2P.V2P_ATIVO = '1'
							AND V2P.%notDel%
						EndSql

						( cAliasTot )->( DBGoTop() )
						If ( cAliasTot )->( !Eof() )
							V2P->( DBGoTo( ( cAliasTot )->RECNOV2P ) )

							RecLock( "V2P", .F. )
							V2P->V2P_ATIVO := "2"
							V2P->( MsUnlock() )
						EndIf

						( cAliasTot )->( DBCloseArea() )
					EndIf
				EndIf

				// Ao excluir o t�rmino de um afastamento j� transmitido, ser� necess�rio buscar o registro de in�cio para reativ�-lo, possibilitando assim o envio de um novo t�rmino.
				If cAliasExclu == "CM6" .And. cStatusEx == '7' .And. CM6->CM6_XMLREC == 'TERM'
				
					cIdCM6     := CM6->CM6_ID
					cAliasCM6  := GetNextAlias()
				
					BeginSql Alias cAliasCM6
						SELECT MAX(CM6.R_E_C_N_O_) RECNOCM6
						FROM %table:CM6% CM6
						WHERE CM6.CM6_FILIAL = %xfilial:CM6% 
						AND	CM6.CM6_ID       = %exp:cIdCM6%
						AND CM6.CM6_XMLREC   = 'INIC'
						AND	CM6.%notDel%
					EndSql
					
					(cAliasCM6)->(DbGoTop())
					
					If (cAliasCM6)->(!Eof()) .And. (cAliasCM6)->RECNOCM6 > 0
						CM6->( DBGoTo( (cAliasCM6)->RECNOCM6 ) )
						Reclock('CM6', .F.)
						CM6->CM6_ATIVO := '1'
						CM6->(MsUnlock())
					EndIf
					
					(cAliasCM6)->(DbCloseArea())
				EndIf

			Else
				lGravaOk := .F.
			EndIf
		Else
			lGravaOk := .F.
		EndIf
	Else
		lGravaOk := .F.
	EndIf

	If !lGravaOk
		MsgRet := "Evento n�o encontrado para atualiza��o do Status de exclus�o."
	EndIf

Return {lGravaOk,cMsgRet}

//---------------------------------------------------------------------
/*/{Protheus.doc} foundPendExclusao

Retorna o RecNo do registro que est� pendente de Exclus�o

@Param  cAliasEvt  - Alias do Evento pendente de Exclus�o
@Param  cFilEvt    - Filial do Evento pendente de Exclus�o
@Param  cIdEvt     - Id do Evento pendente de Exclus�o
@Param  cReciboEvt - Numero do recibo que se encontra no campo _PROTPN

@Author		Evandro dos Santos O. Teixeira
@Since		18/03/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function foundPendExclusao(cAliasEvt,cFilEvt,cIdEvt,cReciboEvt)

	Local nRecNo := 0
	Local cQuery := ""
	Local cAlias := GetNextAlias()

	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName(cAliasEvt)
	cQuery += " WHERE " + cAliasEvt + "_FILIAL = '" + cFilEvt + "'"
	cQuery += " AND " + cAliasEvt + "_ID = '" + cIdEvt + "'"
	cQuery += " AND " + cAliasEvt + "_PROTPN = '" + cReciboEvt + "'"    
	cQuery += " AND " + cAliasEvt + "_STATUS = '6'
	cQuery += " AND " + cAliasEvt + "_EVENTO = 'E'
	cQuery += " AND D_E_L_E_T_ = ' '

	cQuery := ChangeQuery(cQuery)

	TCQuery cQuery New Alias (cAlias)

		If !Empty((cAlias)->RECNO)
			nRecNo := (cAlias)->RECNO
		EndIf 

	(cAlias)->(dbCloseArea())

Return nRecNo

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraEvtTot
Gera��o dos eventos totalizadores (5000|5001|5012) no retorno do 1200/1210/1290
@Return  Mensagem com status 
@author Victor Andrade
@since  17/05/2016
@version 1.0
/*///----------------------------------------------------------------
Static Function GeraEvtTot(cXmlTot as character, cLayout as character, cAliasTb as character, cFilErp as character,;
					lTotaliz as logical, cChvV2J as character, cFil as character, cRecibo as character, nRecEvtOri as numeric)

	Local aRetorno 			as array
	Local aEvtTotal			as array
	Local cErrorXML			as character
	Local cWarningXML		as character
	Local cMsgRetorno		as character
	Local lInsert			as logical
	Local nX				as numeric
	Local oXmlTot			as object
	Local xEvtTotalizador	as variant

	Default cXmlTot			:= ""
	Default cLayout			:= ""
	Default cFilErp			:= ""
	Default cRecibo 		:= ""
	Default cAliasTb		:= "C1E"
	Default lTotaliz		:= .F.
	Default nRecEvtOri		:= 0

	aRetorno		:= {}
	aEvtTotal		:= {}
	cErrorXML		:= ""
	cWarningXML		:= ""
	cMsgRetorno		:= ""
	lInsert			:= .T. 
	nX				:= 0
	oXmlTot			:= Nil
	xEvtTotalizador	:= Nil

	// --> Faz o "parse" do XML para pegar somente o bloco do eSocial, pois a tag possui o retorno do governo completo
	oXmlTot := XmlParser( cXmlTot,"", @cErrorXML, @cWarningXML )

	If Empty(cErrorXML)
		If ValType(oXmlTot) == "O"
			If XmlChildEx(oXmlTot, '_EVENTO' ) <> Nil
				If Empty(cRecibo)
					cRecibo := oXmlTot:_EVENTO:_RETORNOEVENTO:_ESOCIAL:_RETORNOEVENTO:_RECIBO:_NRRECIBO:TEXT
				EndIf 

				xEvtTotalizador := XmlChildEx(oXmlTot:_EVENTO, "_TOT")
				aEvtTotal		:= IIf(ValType(xEvtTotalizador) == "O", {xEvtTotalizador}, xEvtTotalizador)

				If !Empty(aEvtTotal)
					For nX := 1 To Len(aEvtTotal)
						aRetorno := gravaTotalizador(aEvtTotal[nX], cFilErp, cLayout, cAliasTb, nRecEvtOri)

						If !aRetorno[1] 
							cMsgRetorno += aRetorno[4] + CRLF
						EndIf 

						lTotaliz 	:= aRetorno[1] 
						nX 			:= IIf(!lTotaliz, Len(aEvtTotal) + 1, nX)
					Next nX
				Else
					cMsgRetorno := "Evento " + cLayout + " sem retorno de totalizador."
				EndIf
			Else
				cMsgRetorno := "Evento " + cLayout + " sem retorno de totalizador."
			EndIf
		Else
			cMsgRetorno := "--- Falha ao efetuar XmlParser - Tipo oXmlTot " + ValType(oXmlTot) + " ---"
			if valtype(cWarningXML) == 'C'
				cMsgRetorno += "--- Warning --- " + cWarningXML
			endif
		endif
	Else
		cMsgRetorno := cErrorXML
	EndIf

	If !lTotaliz
	
		If Valtype(cMsgRetorno) == 'C' 

			If Empty(cMsgRetorno) 
				cMsgRetorno := "Nao foi possivel obter o erro ocorrido na gravacao do totalizador. Chave: " + cChvV2J
			EndIf 
		Else
			cMsgRetorno := "Tipo de dado indefinido no retorno do Totalizador. Chave: " + cChvV2J
		EndIf 

		If TAFAlsInDic("V2J")

			lInsert := V2J->(MsSeek(cFil+PADR(AllTrim(cChvV2J),GetSx3Cache("V2J_CHVTAF","X3_TAMANHO"))))
			lInsert := !lInsert

			RecLock("V2J",lInsert)
				V2J->V2J_FILIAL := cFil
				V2J->V2J_CHVTAF := AllTrim(cChvV2J)
				V2J->V2J_DSCERR := AllTrim(cMsgRetorno)
				V2J->V2J_DTOCOR := dDataBase
				V2J->V2J_HROCOR := Time()
			V2J->(MsUnlock())
		EndIf 

		TafConOut(cMsgRetorno)
		
	Endif
	
	If ValType(oXmlTot) == "O"
		FreeObj(oXmlTot)
	EndIf
	oXmlTot  := Nil
	aSize(aRetorno,0)

	FwFreeArray(aEvtTotal)

	If ValType(xEvtTotalizador) == "O"

		FreeObj(xEvtTotalizador)
		xEvtTotalizador := Nil 
	ElseIf ValType(xEvtTotalizador) == "A"

		For nX := 1 To Len(xEvtTotalizador)

			If ValType(xEvtTotalizador) == "O"
				FreeObj(xEvtTotalizador[nX])
				xEvtTotalizador[nX] := Nil 
			EndIf 
		Next nX

		aSize(xEvtTotalizador,0)
	EndIf 

Return (cMsgRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} gravaTotalizador
Grava evento totalizador utilizado a API de integra�ao TafPrepInt
@Return  aRetInt - Retorno da grava��o do totalizador
			[1] - logico - determina se a mensagem � de uma integra��o bem sucedida
			[2] - caracter - status do registro (codigo utilizado na TAFXERP)
				1 - Incluido
				2 - Alterado
				3 - Excluido
				4 - Aguardando na Fila
				8 - Filhos Duplicado
				9 - Erro
			[3] - Codigo do Erro
			[4] - Descri��o da Mensagem de Integra��o
@author Evandro dos Santos Oliveira	
@since  19/08/2017
@version 1.0
/*///----------------------------------------------------------------
Static Function gravaTotalizador(xEvtTotalizador as Object, cFilErp as Character,;
					cEvtOri as Character, cAliasTb as Character, nRecEvtOri as Numeric)

	Local lLaySmpTot		as Logical
	Local nPosIni   		as Numeric
	Local cXMLConv  		as Character
	Local cEvtTot   		as Character
	Local cVersTot			as Character
	Local aRetInt   		as Array
	Local aLayouts 			as Array
	
	Default cEvtOri 		:= ""
	Default cFilErp			:= ""
	Default cAliasTb		:= ""
	Default nRecEvtOri		:= 0
	Default xEvtTotalizador := Nil

	cXMLConv   := ""
	cEvtTot    := ""
	aRetInt    := {}
	lLaySmpTot := .F.
	nPosIni    := 0
	aLayouts   := StrTokArr2("S_01_00_00|S_01_01_00", "|")
	
	cXMLConv := XMLSaveStr(xEvtTotalizador)
		
	nPosIni := (At("eSocial", cXMLConv) - 1)
	cXmlConv := SubStr( cXMLConv, nPosIni )

	cEvtTot := xEvtTotalizador:_TIPO:TEXT

	cVersTot := TAFNameEspace(xEvtTotalizador:_ESOCIAL:_XMLNS:TEXT)
	
	If !Empty(cVersTot)
		If AScan(aLayouts, cVersTot) > 0
			lLaySmpTot := .T.
		EndIf
	EndIf	 
	
	TafPrepInt(cEmpAnt, cFilErp, cXmlConv,, "4", cEvtTot,,,, @aRetInt, .F.,,,,,,,, cEvtOri,,,, lLaySmpTot, cAliasTb, nRecEvtOri)
	
Return aRetInt

//-------------------------------------------------------------------
/*/{Protheus.doc} limpaRegT0X
Limpa inconsist�nca da tabela T0X.

@Return cIdAux - Chave da inconsist�ncia a ser excluida 

@author Evandro dos Santos Oliveira	
@since  15/01/2018
@version 1.0

/*///----------------------------------------------------------------
Static Function limpaRegT0X(cIdAux)

	If TcSqlExec("DELETE FROM " + RetSqlName("T0X") + " WHERE T0X_IDCHVE = '" + cIdAux + "' AND (T0X_USER = '" + cUserName + "' OR T0X_USER = '__Schedule')") < 0
		If lJob
			TafConOut("Erro na limpeza das inconsist�ncias: " + TCSQLError())
		Else
			MsgStop(TCSQLError(),"Erro na limpeza das inconsist�ncias")
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} limpaRegV2H
Limpa inconsist�nca da tabela V2H.

@Return cIdAux - Chave da inconsist�ncia a ser excluida 

@author Evandro dos Santos Oliveira	
@since  21/10/2018
@version 1.0

/*///----------------------------------------------------------------
Function limpaRegV2H(cIdAux,cFil)

	Local nTamChv  := 0
	Local cSqlExec := ""
	
	Default cFil  := ""

	nTamChv  := GetSx3Cache("V2H_IDCHVE","X3_TAMANHO")
	
	cSqlExec := "DELETE FROM " + RetSqlName("V2H") + " WHERE V2H_IDCHVE = '" + PADR(cIdAux,nTamChv) + "'"
	
	If !Empty(cFil)
		cSqlExec += " AND V2H_FILIAL = '" + cFil + "'"
	EndIf

	If TcSqlExec( cSqlExec ) < 0
		If lJob
			TAFConOut("Erro na limpeza das inconsist�ncias do RET: " + TCSQLError())
		Else
			MsgStop(TCSQLError(),"Erro na limpeza das inconsist�ncias do RET")
		EndIf
	EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} limpaTotV2J
Limpa inconsist�nca da tabela V2J.

@Return cIdAux - Chave da inconsist�ncia a ser excluida 

@author Evandro dos Santos Oliveira	
@since  09/11/2018
@version 1.0

/*///----------------------------------------------------------------
Static Function limpaTotV2J(cIdAux,cFil)

	Local nTamChv := 0

	nTamChv := GetSx3Cache("V2J_CHVTAF","X3_TAMANHO")

	If TcSqlExec("DELETE FROM " + RetSqlName("V2J") + " WHERE V2J_FILIAL = '" + cFil + "' AND  V2J_CHVTAF = '" + PADR(cIdAux,nTamChv) + "'" ) < 0
		If lJob
			TAFConOut("Erro na limpeza das inconsist�ncias dos Totalizadores: " + TCSQLError())
		Else
			MsgStop(TCSQLError(),"Erro na limpeza das inconsist�ncias dos Totalizadores")
		EndIf
	EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Informacoes de definicao dos parametros do schedule
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)

@author Evandro dos Santos Oliveira	
@since  17/05/2016
@version 1.0

/*///----------------------------------------------------------------
Static Function SchedDef()

Local aParam := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            "TAFESXTSS",;	//Pergunte do relatorio, caso nao use passar ParamDef
            ,"SM0";			//Alias
            ,;			//Array de ordens
            }				//Titulo

Return ( aParam )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetXmlRetTss
@type			function
@description	Rotina que ir� realizar a consulta dos eventos no TSS para retorno do recibo e do XML de envio.
@author			Eduardo Sukeda
@since			09/04/2019
/*/
//---------------------------------------------------------------------

Static Function GetXmlRetTss(aXmlsLote, cUrl, cEntidade, cAmbiente, cEvtRetXml, lRequest, lRetXml, lTransFil, cMsgErro)

	Local nItemLote 	:= 0
	Local aXmlsRetorno 	:= {}
	Local oSocial		:= Nil
	Local lCngFil 		:= .F.
	Local aArea  		:= SM0->(GetArea())
	Local cFilBack		:= cFilAnt

	Default lRequest 	:= .F. 
	Default lRetXml 	:= .F. 
	Default cEvtRetXml 	:= ""
	Default lTransFil	:= .F.
	Default cMsgErro	:= ""
	
	If lTransFil
		lCngFil := TAFChgFil(@cMsgErro)
	Else
		lCngFil := .T.
	EndIf

	If lCngFil
		oSocial	:= WSTSSWSSOCIAL():New()

		If oSocial <> Nil
			oSocial:_Url 						:= cUrl 
			oSocial:oWSENTCONSDADOS:cUSERTOKEN 	:= "TOTVS"
			oSocial:oWSENTCONSDADOS:cID_ENT    	:= cEntidade
			oSocial:oWSENTCONSDADOS:cAMBIENTE   := cAmbiente    

			oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS := WsClassNew("TSSWSSOCIAL_ARRAYOFENTCONSDOC")  
			oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC := {}

			For nItemLote := 1 To Len(aXmlsLote)

				aAdd(oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC,WsClassNew("TSSWSSOCIAL_ENTCONSDOC"))
				Atail(oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC):CCODIGO	:= aXmlsLote[nItemLote][4]
				Atail(oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC):CID		:= aXmlsLote[nItemLote][2]

				If AllTrim(aXmlsLote[nItemLote][4]) $ cEvtRetXml .Or. lRetXml
					Atail(oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC):lRETORNAXML	:= .T.
				Else
					Atail(oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC):lRETORNAXML	:= .F.
				EndIf
				Atail(oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC):lHISTPROC := .T.

			Next nItemLote 

			lRequest := oSocial:consultarDocumentos() 
			
			If oSocial:oWSCONSULTARDOCUMENTOSRESULT <> Nil
				If oSocial:oWSCONSULTARDOCUMENTOSRESULT:oWSSAIDACONSDOCS <> Nil 
					If oSocial:oWSCONSULTARDOCUMENTOSRESULT:oWSSAIDACONSDOCS:oWSSAIDACONSDOC <> Nil
						aXmlsRetorno := oSocial:oWSCONSULTARDOCUMENTOSRESULT:oWSSAIDACONSDOCS:oWSSAIDACONSDOC
					EndIf
				EndIf
			EndIf

			FreeObj(oSocial)
			oSocial := Nil
		EndIf
	EndIf

	RestArea(aArea)
	cFilAnt := cFilBack

Return aXmlsRetorno

//---------------------------------------------------------------------
/*/
{Protheus.doc} getUrlTSS
Rotina para retornar a URL do TSS
@type  Static Function
@author Diego Santos
@since 15-10-2018
@version 1.0
@return return, return_type, return_description
/*/
//---------------------------------------------------------------------

Static Function getUrlTSS()

Local cUrl := ""

If FindFunction("TafGetUrlTSS")
    cUrl := AllTrim((TafGetUrlTSS()))
Else
    cUrl := AllTrim(GetNewPar("MV_TAFSURL","http://"))
EndIf 

If !("TSSWSSOCIAL.APW" $ Upper(cUrl)) 
    cUrl += "/TSSWSSOCIAL.apw"
EndIf	

Return cUrl

//---------------------------------------------------------------------
/*/
{Protheus.doc} getUrlTSS
Rotina para retornar a URL do TSS.
@type  Static Function
@author Diego Santos
@since 15-10-2018
@version 1.0
@return return, return_type, return_description
/*/
//---------------------------------------------------------------------

Static Function getIdEntidade(cUrl,cIdEntidade,cMsgErro)

Local lTransFil := .F.
Local lJob := IsBlind()
Local cCheckURL := ""
Local lRet := .T. 


If FindFunction("TAFTransFil")
    lTransFil := TAFTransFil(lJob)
EndIf

If !("TSSWSSOCIAL.APW" $ Upper(cUrl))
    cCheckURL := cUrl
Else
    cCheckURL := Substr(cUrl,1,Rat("/",cUrl)-1)
EndIf

If TAFCTSpd(cCheckURL,,,@cMsgErro)
    cIdEntidade := TAFRIdEnt(lTransFil)
Else
    lRet := .F.

    If lJob
    	TafConOut("N�o foi possivel conectar com o servidor TSS")
    	TafConOut(cMsgErro)
    EndIf
EndIf
    
Return lRet

//--------------------------------------------------------------------------- -
/*/{Protheus.doc} TAF_CONJ5M
Recebe a conex�o via IPCGO e passa os dados para a rotina processar o lote espec�fico.

@return Nil

@author Robson Santos
@since 07/05/2019
@version 1.0

/*/
//----------------------------------------------------------------------------
Function TAF_CONJ5M(aXmlsLote, cAmbiente, lGrvRet,cUrl,lJob,cIdEnt,lNewProcess,oProcess,nQtdLote,nLote,lGravaErrTab )

Local oBlock	:=	Nil

//-- ConOut( "[TAFPROC5MT] Started IPCGo [InitializeProcess]" )
//-- ConOut( "[TAFPROC5MT] Thread ID: "+ cValtochar(ThreadID()) )

oBlock := ErrorBlock( { |x| TAFConOut( "[TAFPROC5MT][ERROR] " + Chr( 10 ) + x:Description + Chr( 10 ) + x:ErrorStack ) } )

BEGIN SEQUENCE
	TafConRG(aXmlsLote, cAmbiente, lGrvRet,cUrl,lJob,cIdEnt,lNewProcess,oProcess,nQtdLote,nLote,lGravaErrTab)
END SEQUENCE

ErrorBlock( oBlock )
	
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} GetV3NChv
@type			function
@description	Retorna a chave para que seja poss�vel posicionar na tabela V3N.
@author			Victor A. Barbosa
@since			18/11/2019
@version		1.0
@param			cAliasExclu	-	Alias do evento pendente de exclus�o
@return			cChvRet		-	Chave de neg�cio para busca na tabela V3N
/*/
//---------------------------------------------------------------------
Static Function GetV3NChv( cAliasExclu )

Local cCPF		:=	""
Local cPeriodo	:=	""
Local aChvRet	:=	""

Do Case
	Case cAliasExclu == "C91"
		cCPF := C91->C91_CPF

		If Empty( cCPF )
			cCPF := GetAdvFVal( "C9V", "C9V_CPF", xFilial( "C9V" ) + C91->C91_TRABAL + "1", 2, "", .T. )
		EndIf
		aChvRet := {C91->C91_FILIAL,C91->C91_INDAPU,C91->C91_PERAPU,cCPF,"S-1200"}

	Case cAliasExclu == "CMD"
		cCPF		:= GetAdvFVal( "C9V", "C9V_CPF", xFilial( "C9V" ) + CMD->CMD_FUNC + "1", 2, "", .T. )
		cPeriodo	:= SubStr( DToS( CMD->CMD_DTDESL ), 1, 6 )
		aChvRet		:= {CMD->CMD_FILIAL,"1",cPeriodo,cCPF,"S-2299"}

	Case cAliasExclu == "T92"
		cCPF		:= GetAdvFVal( "C9V", "C9V_CPF", xFilial( "C9V" ) + T92->T92_TRABAL + "1", 2, "", .T. )
		cPeriodo	:= SubStr( DToS( T92->T92_DTERAV ), 1, 6 )
		aChvRet		:= {T92->T92_FILIAL,"1",cPeriodo,cCPF,"S-2399"}
EndCase

Return( aChvRet )

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
