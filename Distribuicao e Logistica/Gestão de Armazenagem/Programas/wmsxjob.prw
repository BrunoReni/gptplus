#INCLUDE 'Protheus.ch'
#INCLUDE 'TBICONN.CH'
#DEFINE LIMITE 80
#DEFINE ARQ_CPRJOB 'WMSXJOB.CFG'

/*
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �WMSXJOB   � Autor � Nilton A. Rodrigues   � Data � 16.09.2004���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Biblioteca dos jobs das APIs do WMS                          ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       �Materiais                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
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
//������������������������������������������������������������������������Ŀ
//�Verifica os parametros da rotina                                        �
//��������������������������������������������������������������������������
WmsLogMsg(Repl('=',LIMITE))
WmsLogMsg(PadC('STARTING JOBS - Warehouse Management System',LIMITE))
WmsLogMsg('INIT TIME: ' + Time() + ' - ' + DtoC(Date()))
WmsLogMsg(Repl('=',LIMITE))
WmsLogMsg('')
If !File(cPath+ARQ_CPRJOB)
	WmsLogMsg('WARNING: '+'Configuration File not found'+': '+cPath+ARQ_CPRJOB)
	lContinua := .F.
EndIf
//�������������������������������������������������������������������Ŀ
//�Verificando as Empresas e Rotinas Habilitadas                      �
//���������������������������������������������������������������������
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
//�������������������������������������������������������������������Ŀ
//�Verificando os Parametros de cada Rotina                           �
//���������������������������������������������������������������������
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
	//�������������������������������������������������������������������Ŀ
	//�Processamento das Rotinas                                          �
	//���������������������������������������������������������������������
	Do While !KillApp()
		For nX := 1 To Len(aRotina)
			//�������������������������������������������������������������������Ŀ
			//�Verifica se a Rotina deve ser executada                            �
			//���������������������������������������������������������������������

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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �WMSJOBSENT�Autor  �Microsiga           � Data �  09/20/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao que executa Servicos de Entrada via JOB              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Advanced Protheus                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function WMSJOBSENT(cCodEmp, cCodFil, nIDJob)

WMSJOBSERV(cCodEmp, cCodFil, nIDJob, 'WMSJOBSENT', 1) //-- Servicos de Entrada

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �WMSJOBSSAI�Autor  �Microsiga           � Data �  09/20/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao que executa Servicos de Saida via JOB                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Advanced Protheus                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function WMSJOBSSAI(cCodEmp, cCodFil, nIDJob)

WMSJOBSERV(cCodEmp, cCodFil, nIDJob, 'WMSJOBSSAI', 2) //-- Servicos de Saida  

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �WMSJOBSOSM�Autor  �Microsiga           � Data �  09/20/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao que executa Servicos de Ordem de Servicos Manuais via���
���          �JOB                                                         ���
�������������������������������������������������������������������������͹��
���Uso       � Advanced Protheus                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function WMSJOBSOSM(cCodEmp, cCodFil, nIDJob)

WMSJOBSERV(cCodEmp, cCodFil, nIDJob, 'WMSJOBSOSM', 4) //-- Servicos de Ordem de Servicos Manuais

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �WMSJOBSERV� Autor �Nilton A. Rodrigues    � Data �16.09.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Job de processamento                                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Codigo da Empresa                                    ���
���          �ExpC2: Codigo da Filial                                     ���
���          �ExpN3: Codigo do Job, utilizado no controle de execucao     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
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
   
//������������������������������������������������������������������������Ŀ
//�Controle de execucao. Nao permite que o mesmo JOB seja inicializado mais�
//�de uma vez                                                              �
//��������������������������������������������������������������������������
While !LockByName("WMSJOBSERV", .T., .F.)
	Sleep(50)
	nC++
	If nC == 60
		lContinua := .F.
		Exit
	EndIf
EndDo

If lContinua
	//������������������������������������������������������������������������Ŀ
	//�Preparando o ambiente para execucao                                     �
	//��������������������������������������������������������������������������
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

		//������������������������������������������������������������������������Ŀ
		//�Verificando o ambiente novamente para assumir novos parametros          �
		//��������������������������������������������������������������������������
		cHoraIni   := GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'START_TIME','01:00:00',ARQ_CPRJOB)
		cHoraFim   := GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'FINISH_TIME','23:59:59',ARQ_CPRJOB)
		nIntervalo := Val(GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'INTERVAL','5',ARQ_CPRJOB))
		nJobs      := Val(GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'JOBS','1',ARQ_CPRJOB))
		cAtivo     := GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'ACTIVATE','OFF',ARQ_CPRJOB)
		WmsLogMsg('Searching Service... ('+Time()+' - '+DtoC(Date())+')')
		Sleep(5000)
	EndDo
	//������������������������������������������������������������������������Ŀ
	//�Finalisando o ambiente para execucao                                    �
	//��������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �DLA150Job � Autor � Fernando Joly Siquini � Data �16.09.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Executa os Servicos via Job                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � DLA150Job()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �DLA150SerJ� Autor � Alex Egydio           � Data �17.01.2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Executa o Servico via JOB                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � DLA150SerJ(ExpL1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpL1 = Recno do Servico a ser Executado                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � DLGA150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
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
