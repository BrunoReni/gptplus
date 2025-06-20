#INCLUDE 'Protheus.ch'
#INCLUDE 'TBICONN.CH'
#DEFINE LIMITE 80
#DEFINE ARQ_CPRJOB 'WMSXJOB.CFG'

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪目北
北矲un噭o    砏MSXJOB   � Autor � Nilton A. Rodrigues   � Data � 16.09.2004潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪拇北
北矰escri噭o 矪iblioteca dos jobs das APIs do WMS                          潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       矼ateriais                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/
Function JobWMS()

Local aRotina    := {}
Local cAuxiliar  := ''
Local nX         := 0
Local nY         := 0
Local nZ         := 0
Local nIntervalo := 0
Local nJobs      := 0
Local nSleepJob  := 0
Local cHoraIni   := ''
Local cHoraFim   := ''
Local cAtivo     := ''
Local lContinua  := .T.
Local cPath      := Iif(IsSrvUnix(),'/BIN/APPSERVER/','\BIN\APPSERVER\')
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//砎erifica os parametros da rotina                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
WmsLogMsg(Repl('=',LIMITE))
WmsLogMsg(PadC('STARTING JOBS - Warehouse Management System',LIMITE))
WmsLogMsg('INIT TIME: ' + Time() + ' - ' + DtoC(Date()))
WmsLogMsg(Repl('=',LIMITE))
WmsLogMsg('')
If !File(cPath+ARQ_CPRJOB)
	WmsLogMsg('WARNING: '+'Configuration File not found'+': '+cPath+ARQ_CPRJOB)
	lContinua := .F.
EndIf
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//砎erificando as Empresas e Rotinas Habilitadas                      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If lContinua
	//-- Executa Servicos de Entrada
	If !Empty(GetPvProfString('JOBS','WMSJOBSENT','',ARQ_CPRJOB))
			cAuxiliar := GetPvProfString('JOBS','WMSJOBSENT','',ARQ_CPRJOB)
			Do While !Empty(cAuxiliar)
				aadd(aRotina,{'WMSJOBSENT',SubStr(cAuxiliar,1,2),SubStr(cAuxiliar,3,2),'01:00:00','23:59:59',0,'ON',Time()})
				nX := At(cAuxiliar,';')
				If nX == 0
					cAuxiliar := ''
				Else
					cAuxiliar := SubStr(cAuxiliar,nX+1)
				EndIf
			EndDo
	EndIf
	//-- Executa Servicos de Saida
	If !Empty(GetPvProfString('JOBS','WMSJOBSSAI','',ARQ_CPRJOB))
		cAuxiliar := GetPvProfString('JOBS','WMSJOBSSAI','',ARQ_CPRJOB)
		Do While !Empty(cAuxiliar)
			aadd(aRotina,{'WMSJOBSSAI',SubStr(cAuxiliar,1,2),SubStr(cAuxiliar,3,2),'01:00:00','23:59:59',0,'ON',Time()})
			nX := At(cAuxiliar,';')
			If nX == 0
				cAuxiliar := ''
			Else
				cAuxiliar := SubStr(cAuxiliar,nX+1)
			EndIf
		EndDo
	EndIf
	//-- Executa Servicos de Ordens de Servico Manuais
	If !Empty(GetPvProfString('JOBS','WMSJOBSOSM','',ARQ_CPRJOB))
		cAuxiliar := GetPvProfString('JOBS','WMSJOBSOSM','',ARQ_CPRJOB)
		Do While !Empty(cAuxiliar)
			aadd(aRotina,{'WMSJOBSOSM',SubStr(cAuxiliar,1,2),SubStr(cAuxiliar,3,2),'01:00:00','23:59:59',0,'ON',Time()})
			nX := At(cAuxiliar,';')
			If nX == 0
				cAuxiliar := ''
			Else
				cAuxiliar := SubStr(cAuxiliar,nX+1)
			EndIf
		EndDo
	EndIf
	If Empty(aRotina)
		WmsLogMsg(Repl('=',LIMITE))
		WmsLogMsg('WARNING: '+'Routine not found')
		WmsLogMsg(Repl('=',LIMITE))
		WmsLogMsg('Section: JOBS ')
		WmsLogMsg('{Process Name}: {Company/Branch[;...]}')
		WmsLogMsg('Example: [JOBS])')
		WmsLogMsg('         WMSJOBSENT  =9901;9902;9903;...')
		WmsLogMsg('')
		WmsLogMsg(Repl('-',LIMITE))
		lContinua := .F.
	EndIf
EndIf
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//砎erificando os Parametros de cada Rotina                           �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If lContinua
	For nX := 1 To Len(aRotina)
		cHoraIni   := GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'START_TIME','01:00:00',ARQ_CPRJOB)
		cHoraFim   := GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'FINISH_TIME','23:59:59',ARQ_CPRJOB)
		nIntervalo := GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'INTERVAL','5',ARQ_CPRJOB)
		cAtivo     := GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'ACTIVATE','ON',ARQ_CPRJOB)
		nJobs      := Val(GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'JOBS','1',ARQ_CPRJOB))
		nSleepJob  := Max(Val(GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'SLEEPJOB','1',ARQ_CPRJOB)),10)

		aRotina[nX][4] := cHoraIni
		aRotina[nX][5] := cHoraFim
		aRotina[nX][6] := nIntervalo
		aRotina[nX][7] := cAtivo
		aRotina[nX][8] := cHoraIni

		WmsLogMsg('Processing in: ')
		WmsLogMsg('          COMPANY    ='+aRotina[nX][2])
		WmsLogMsg('          BRANCH     ='+aRotina[nX][3])
		WmsLogMsg('')
		WmsLogMsg('['+aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3]+']')
		WmsLogMsg('          START_TIME ='+aRotina[nX][4])
		WmsLogMsg('          FINISH_TIME='+aRotina[nX][5])
		WmsLogMsg('          INTERVAL   ='+aRotina[nX][6])
		WmsLogMsg('          ACTIVATE   ='+aRotina[nX][7])
		WmsLogMsg('          JOBS       ='+StrZero(nJobs,2))
		WmsLogMsg('          SLEEPJOB   ='+StrZero(nSleepJob,3))
		WmsLogMsg('')
	Next nX
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//砅rocessamento das Rotinas                                          �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	Do While !KillApp()
		For nX := 1 To Len(aRotina)
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//砎erifica se a Rotina deve ser executada                            �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

			cHoraIni   := GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'START_TIME','01:00:00',ARQ_CPRJOB)
			cHoraFim   := GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'FINISH_TIME','23:59:59',ARQ_CPRJOB)
			nIntervalo := Val(GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'INTERVAL','5',ARQ_CPRJOB))
			cAtivo     := GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'ACTIVATE','OFF',ARQ_CPRJOB)
			nJobs      := Val(GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'JOBS','1',ARQ_CPRJOB))
			nSleepJob  := Max(Val(GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'SLEEPJOB','1',ARQ_CPRJOB)),10)
			If cAtivo == 'ON'
				For nY := 1 To nJobs
					StartJob(aRotina[nX][1],GetEnvServer(),.F.,aRotina[nX][2],aRotina[nX][3],nY)
					For nZ := 0 To nSleepJob
						Sleep(1000)
						If KillApp()
							Exit
						EndIf
					Next nZ
					If KillApp()
						Exit
					EndIf
				Next nY
			EndIf
		Next nX
		Sleep(1000)
	EndDo
EndIf

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篎uncao    砏MSJOBSENT篈utor  矼icrosiga           � Data �  09/20/04   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矲uncao que executa Servicos de Entrada via JOB              罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � Advanced Protheus                                          罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function WMSJOBSENT(cCodEmp, cCodFil, nIDJob)

WMSJOBSERV(cCodEmp, cCodFil, nIDJob, 'WMSJOBSENT', 1) //-- Servicos de Entrada

Return Nil

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篎uncao    砏MSJOBSSAI篈utor  矼icrosiga           � Data �  09/20/04   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矲uncao que executa Servicos de Saida via JOB                罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � Advanced Protheus                                          罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function WMSJOBSSAI(cCodEmp, cCodFil, nIDJob)

WMSJOBSERV(cCodEmp, cCodFil, nIDJob, 'WMSJOBSSAI', 2) //-- Servicos de Saida  

Return Nil

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篎uncao    砏MSJOBSOSM篈utor  矼icrosiga           � Data �  09/20/04   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矲uncao que executa Servicos de Ordem de Servicos Manuais via罕�
北�          矹OB                                                         罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � Advanced Protheus                                          罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function WMSJOBSOSM(cCodEmp, cCodFil, nIDJob)

WMSJOBSERV(cCodEmp, cCodFil, nIDJob, 'WMSJOBSOSM', 4) //-- Servicos de Ordem de Servicos Manuais

Return Nil

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    砏MSJOBSERV� Autor 砃ilton A. Rodrigues    � Data �16.09.2004潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矹ob de processamento                                        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   砃enhum                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros矱xpC1: Codigo da Empresa                                    潮�
北�          矱xpC2: Codigo da Filial                                     潮�
北�          矱xpN3: Codigo do Job, utilizado no controle de execucao     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao Efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function WMSJOBSERV(cCodEmp, cCodFil, nIDJob, cJobName, nTipoJob)
Local lContinua  := .T.
Local lExecuta   := .F.
Local cHoraUlt   := '01:00:00'
Local cHora      := cHoraUlt
Local cHoraIni   := GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'START_TIME','01:00:00',ARQ_CPRJOB)
Local cHoraFim   := GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'FINISH_TIME','23:59:59',ARQ_CPRJOB)
Local cAtivo     := GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'ACTIVATE','OFF',ARQ_CPRJOB)
Local nIntervalo := Val(GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'INTERVAL','5',ARQ_CPRJOB))
Local nJobs      := Val(GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'JOBS','1',ARQ_CPRJOB))
Local nLenVar    := SetVarNameLen(255)
Local cTipoJob   := If(nTipoJob==1,'Entradas',If(nTipoJob==2,'Saidas',If(nTipoJob==3,'Cargas','Ordens de Servico Manuais')))
Local nC         := 0

	PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil ;
	TABLES 'SD1', 'SD2', 'SD3', 'SD4', 'SDA', 'SC1', 'SC2', 'SC4', 'SC6', 'SC7', 'DC1', 'DC2', 'DC3', 'DC4', ;
	'DC5', 'DC7', 'DC8', 'DCD', 'DCF', 'DCI', 'SAH', 'SB1', 'SB2', 'SB3', 'SB4', 'SB5', 'SB6', 'SB8', ;
	'SBE', 'SBF', 'SBJ' MODULO 'WMS'
   
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矯ontrole de execucao. Nao permite que o mesmo JOB seja inicializado mais�
//砫e uma vez                                                              �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
While !LockByName("WMSJOBSERV", .T., .F.)
	Sleep(50)
	nC++
	If nC == 60
		lContinua := .F.
		Exit
	EndIf
EndDo

If lContinua
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//砅reparando o ambiente para execucao                                     �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	WmsLogMsg(Repl('-',LIMITE))
	WmsLogMsg(cJobName+'('+StrZero(nIDJob,2)+'): '+'Starting environment')
	WmsLogMsg(Repl('-',LIMITE))
    
	Do While cAtivo == 'ON' .And. nJobs >= nIDJob .And. !Killapp()
		lExecuta := .F.
		cAtivo   := GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'ACTIVATE','OFF',ARQ_CPRJOB)
		If cHoraIni > cHoraFim
			If !(Time() >= cHoraFim .And. Time() <= cHoraIni)
				cHora := cHoraUlt
				SomaDiaHor(Date(),@cHora,nIntervalo/60)
				If Time() >= cHora .Or. nIntervalo == 0
					cHoraUlt := Time()
					lExecuta := .T.
				EndIf
			Else
				cAtivo := 'OFF'
			EndIf
		Else
			If Time() >= cHoraIni .And. Time() <= cHoraFim
				cHora := cHoraUlt
				SomaDiaHor(Date(),@cHora,nIntervalo/60)
				If Time() >= cHora .Or. nIntervalo == 0
					cHoraUlt := Time()
					lExecuta := .T.
				EndIf
			Else
				cAtivo := 'OFF'
			EndIf
		EndIf

		If lExecuta
			DLA150Job(nTipoJob, cTipoJob)
		EndIf

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//砎erificando o ambiente novamente para assumir novos parametros          �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		cHoraIni   := GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'START_TIME','01:00:00',ARQ_CPRJOB)
		cHoraFim   := GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'FINISH_TIME','23:59:59',ARQ_CPRJOB)
		nIntervalo := Val(GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'INTERVAL','5',ARQ_CPRJOB))
		nJobs      := Val(GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'JOBS','1',ARQ_CPRJOB))
		cAtivo     := GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'ACTIVATE','OFF',ARQ_CPRJOB)
		WmsLogMsg('Searching Service... ('+Time()+' - '+DtoC(Date())+')')
		Sleep(5000)
	EndDo
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//矲inalisando o ambiente para execucao                                    �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	WmsLogMsg(Repl('=',LIMITE))
	WmsLogMsg(PadC('FINISHING JOB - Warehouse Management System',LIMITE))
	WmsLogMsg(PadC(cTipoJob,LIMITE))
	WmsLogMsg('END TIME: ' + Time() + ' - ' + DtoC(Date()))
	WmsLogMsg(cJobName+'('+StrZero(nIDJob,2)+'): '+'Environment reseted')
	WmsLogMsg(Repl('=',LIMITE))
	WmsLogMsg('')
	RESET ENVIRONMENT
	UnLockByName("WMSJOBSERV", .T., .F.)
EndIf
SetVarNameLen(nLenVar)

Return(.T.)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    矰LA150Job � Autor � Fernando Joly Siquini � Data �16.09.2004潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Executa os Servicos via Job                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � DLA150Job()                                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   � Nil                                                        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Generico                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function DLA150Job(nTipoJob, cTipoJob)

Local aRecnos  := {}
Local aJaExec  := {}
Local aAExec   := {}
Local cSeekDCF := ''
Local cCompara := ''
Local cQryDCF  := ''
Local nExec    := 0
Local nY       := 0
Local nX       := 0
Local lRetPE   := .T.
Local lWMSJBDCF:= ExistBlock("WMSJBDCF")

Private cMarca  := '+J'

Static cTitProd := ''
Static cTitQtd  := ''
Static cTitEnd  := ''

cTitProd := FWX3Titulo("DCF_CODPRO")
cTitQtd  := FWX3Titulo("DCF_QUANT")
cTitEnd  := FWX3Titulo("DCF_ENDER")

//-- Seleciona os Servicos a Executar e Interrompidos no DCF
dbSelectArea('DCF')
cQryDCF := "SELECT DCF_FILIAL, DCF_STSERV , R_E_C_N_O_ DCFRECNO "
cQryDCF += "FROM " + RetSqlName('DCF') + " DCF "
cQryDCF += "WHERE DCF_FILIAL='"+xFilial('DCF')+"'"
cQryDCF += " AND DCF_STSERV<>'3'"
cQryDCF += " AND DCF_OK='  '"
cQryDCF += " AND D_E_L_E_T_=' '"

If	nTipoJob == 1
	//-- Entradas
	cQryDCF  += "AND (DCF_ORIGEM = 'SD1' OR DCF_ORIGEM = 'SD2' OR DCF_ORIGEM = 'SDA' OR DCF_ORIGEM = 'SCM')"
ElseIf nTipoJob == 2
	//-- Saidas
	cQryDCF  += "AND (DCF_ORIGEM = 'SC9' OR DCF_ORIGEM = 'SCN')"
ElseIf nTipoJob == 4
	//-- Ordem de Servico Manual
	cQryDCF  += "AND (DCF_ORIGEM = 'DCF' OR DCF_ORIGEM = 'SD3')"
EndIf
cQryDCF := ChangeQuery(cQryDCF)
dbUseArea(.T., 'TOPCONN', TcGenQry(,,cQryDCF), 'SELECTDCF')
dbSelectArea('SELECTDCF')
Do While !SELECTDCF->(Eof()) .And. !KillApp()
	//-- Ponto de entrada para definir servicos (DCF) que serao executados.
	If	lWMSJBDCF
		lRetPE := ExecBlock("WMSJBDCF",.F.,.F.,{SELECTDCF->DCFRECNO})
		lRetPE := If(ValType(lRetPE)=="L",lRetPE,.T.)
		If	!lRetPE
			SELECTDCF->(dbSkip())
			Loop
		EndIf
	EndIf
	aAdd(aRecnos, SELECTDCF->DCFRECNO)
	SELECTDCF->(dbSkip())
EndDo
SELECTDCF->(dbCloseArea())

dbSelectArea('DCF')
For nX := 1 to Len(aRecnos)

	If KillApp()
		Exit
	EndIf

	//-- Ignora Registros Jah Executados
	If aScan(aJaExec, aRecnos[nX]) > 0
		Loop
	EndIf

	Begin Transaction

		//-- Marca o Servico A Executar
		dbGoto(aRecnos[nX])
		Reclock('DCF', .F.)
		Replace DCF_OK With cMarca
		MsUnlock()
		aAdd(aAExec, Recno())

		//-- Marca Servicos que possuam mesma Carga ou Documento
		IF !Empty(DCF_CARGA)
			dbSetOrder(4) //-- DCF_FILIAL+DCF_SERVIC+DCF_CARGA+DCF_UNITIZ
			cSeekDCF := xFilial('DCF')+DCF_SERVIC+DCF_CARGA
			cCompara := 'DCF_FILIAL+DCF_SERVIC+DCF_CARGA'
		Else
			dbSetOrder(2) //-- DCF_FILIAL+DCF_SERVIC+DCF_DOCTO+DCF_SERIE+DCF_CLIFOR+DCF_LOJA+DCF_CODPRO
			cSeekDCF := xFilial('DCF')+DCF_SERVIC+DCF_DOCTO
			cCompara := 'DCF_FILIAL+DCF_SERVIC+DCF_DOCTO'
		EndIf
		If MsSeek(cSeekDCF, .F.)
			Do While !Eof() .And. cSeekDCF == &(cCompara) .And. !KillApp()
				If !(DCF_STSERV) == '3' .And. !(aRecnos[nX]==Recno()) //-- Somente para servicos "1-Nao Executados" ou "2-Interrompidos"
					Reclock('DCF', .F.)
					Replace DCF_OK With cMarca
					MsUnlock()
					aAdd(aAExec, Recno())
				EndIf
				dbSkip()
			Enddo
		EndIf

		//-- Executa os Servicos
		If !KillApp()
			For nY := 1 to Len(aAExec)
			If KillApp()
				Exit
			EndIf
			DCF->(dbGoTo(aAExec[nY]))
				WmsLogMsg(Repl('-', LIMITE))
				WmsLogMsg(PadC('JOB MESSAGE - Warehouse Management System',LIMITE))
				WmsLogMsg(PadC(cTipoJob,LIMITE))
				WmsLogMsg('EXECUTING WMS SERVICE...')
				WmsLogMsg('DCF RECNO...: ' +AllTrim(Str(aAExec[nY])))
				WmsLogMsg('DCF Service : ' +DCF->DCF_SERVIC)
				WmsLogMsg(Padr(cTitProd,12)+'.: ' + DCF->DCF_CODPRO)
				WmsLogMsg(Padr(cTitQtd,12)+'.: ' + TransForm(DCF->DCF_QUANT,PesqPict('DCF','DCF_QUANT')))
				WmsLogMsg(Padr(cTitEnd,12)+'.: ' + DCF->DCF_ENDER)
				WmsLogMsg('INIT TIME....: ' + Time() + ' - ' + DtoC(Date()))
				DLA150SerJ(aAExec[nY])
				WmsLogMsg('END TIME.....: ' + Time() + ' - ' + DtoC(Date()))
				WmsLogMsg(Repl('-', LIMITE))
				WmsLogMsg('')
				nExec ++
				aAdd(aJaExec, aAExec[nY])
			Next nY
			aAExec := {}
		EndIf

	End Transaction	
Next nX
MsUnlockAll()
Return Nil

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    矰LA150SerJ� Autor � Alex Egydio           � Data �17.01.2001潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Executa o Servico via JOB                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � DLA150SerJ(ExpL1)                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpL1 = Recno do Servico a ser Executado                   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � DLGA150                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function DLA150SerJ(nRecno)

Local aAreaAnt   := GetArea()
Local aAreaDC5   := DC5->(GetArea())
//-- Variaveis utilizadas pela funcao wmsexedcf
Local lRet       := Nil
Private aLibSDB  := {}
Private aWmsAviso:= {}
//--
Private lExec150:= .T.
Private lRadioF	:= (GetMV('MV_RADIOF', .F., 'N')=='S') //-- Como Default o parametro MV_RADIOF e verificado

dbSelectArea('SD1')
dbSetOrder(1)

dbSelectArea('SD2')
dbSetOrder(3)

dbSelectArea('SD3')
dbSetOrder(2)

dbSelectArea('SC9')
dbSetOrder(1)

dbSelectArea('DC6')
dbSetOrder(1)

If !(cPaisLoc=='BRA')
	dbSelectArea('SCM')
	dbSetOrder(9)

	dbSelectArea('SCN')
	dbSetOrder(6)
Endif

dbSelectArea('DCF')
dbGoto(nRecno)

dbSelectArea('DC5')
dbSetOrder(1)
If	DCF->DCF_OK==cMarca
	WmsExeDCF('1',.T.)
	WmsExeDCF('2')
	If	lRet == Nil
		lRet := lExec150
	EndIf
EndIf

If lRet == Nil
	lRet := .F.
EndIf

RestArea(aAreaDC5)
RestArea(aAreaAnt)

Return lRet

Static Function WmsLogMsg(cMsg)

	FWLogMsg("INFO", "", "BusinessObject", "WMSXJOB", "", "", cMsg, 0, 0)

Return
