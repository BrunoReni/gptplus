#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FOLDER.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RHIMP01.CH"

/****###***************************************************************************
***********************************************************************************
***********************************************************************************
***Func�o.....: RHIMP01.PRW Autor: Rafael Luis da Silva  Data:30/07/2015 		***
***********************************************************************************
***Descri��o..:Fun��o Principal respons�vel por inicializar o Conversor         ***
***Logix -> Protheus															***
***********************************************************************************
***Uso........:        															***
***********************************************************************************
***Par�metros.:				     									            ***
***********************************************************************************
***Retorno....:                                                                 ***
***********************************************************************************
***					Altera��es feitas desde a constru��o inicial       	 		***
***********************************************************************************
***RESPONS�VEL.|DATA....|C�DIGO|BREVE DESCRI��O DA CORRE��O.....................***
***********************************************************************************
***P. Pompeu...|17/03/16|TUSA71|Chamada fun��o SetDefaultSkin, melhorar visual  ***
***P. Pompeu...|07/04/16|TUUEAS|Altera��es visuais para melhor usabilidade      ***
***P. Pompeu...|29/04/16|TSQIFS|Corre��o na Exclus�o de Tabelas(Aba 3)          ***
***P. Pompeu...|28/06/16|TVMS78|Melhoria na Exibi��o das Mensagens de Erro e    ***
***inclus�o da op��o de Plano de Sa�de.                                         ***
***P. Pompeu...|04/01/16|TVUVBW|Inclus�o da op��o de Hist�rico de Plano de Saude***
***Jaqueline   |04/01/16|DRHPAG|Declarado a var�avel lErroNoFim como private,   ***
***Laurenti    |        |12557 |para evitar errorLog.                           ***   
**********************************************************************************/
/*/{Protheus.doc} RHIMP01
	Funcao responsavel em inicializar variaveis utilizadas pelo
	sistema e chamar a tela de importacao/exportacao.
@author Rafael Luis da Silva
@since 22/02/2010
@version P11
@return Nil, Valor Nulo
@obs Reformulado em 07/2015 por philipe.pompeu
/*/
Main Function RHIMP01()	
	Local bErro	:= {|oErro|U_RIM01ERR(oErro:Description,.T.)}
	Public dDataBase := Date()
	Public cModulo	:= 'GPE'
	Public nModulo	:= 07
	Public __LPYME	:= .F.	
	
	/*Configura ambiente inicial.Inicializa vari�veis necessarias
	para o processamento.*/
	U_RHImpEnv()
		
	/*Configura um bloco de erro personalizado, dessa forma qualquer erro
	ser� mostrado no log(inclusive error.log etc).*/
	ErrorBlock(bErro)
	
	MontaTela()
	
	Set(_SET_DATEFORMAT, cDtFormat)	
	aSize(aInconsistencia,0)
	aInconsistencia := Nil	
	RpcClearEnv()
Return(Nil)

/*/{Protheus.doc} MontaTela
	Monta a Tela de Importacao/Exportacao
@author Rafael F. B.
@since 27/08/2009
@version P11
@return Nil, Valor Nulo
@Obs Reformulada em 07/2015, antiga RIM01Tela
/*/
Static Function MontaTela()
	Local aFolder
	Local aTam := {420,600}
	Local oBtnOk	:= Nil
	Public oMainWnd := Nil		
	Private aTarefas := {}	
	Private oFolder := Nil	
	Private lErroNoFim
		
	Define MSDialog oMainWnd Title OemToAnsi(STR0006) From 000,000 To aTam[1], aTam[2] Pixel
				/*'Cad. B�sico/Hist�ricos','Ponto Eletr�nico','Exclus�o de Tabelas'*/	
	aFolder :=	{OemToAnsi(STR0001),OemToAnsi(STR0002),OemToAnsi(STR0003),OemToAnsi(STR0062)}
	
	/*A largura do oFolder agora � zero, pq ele sempre tera a largura total da janela*/	
	oFolder := TFolder():New(3, 3, aFolder, aFolder, oMainWnd,,,, .T., .F., 0,(aTam[1]*0.40))
	oFolder:Align := CONTROL_ALIGN_TOP
	aEval(oFolder:aDialogs,{|x|x:oFont := oMainWnd:oFont})
		
	@ 10, (aTam[2]*0.43) Button OemToAnsi(STR0004) Size 30, 10 Pixel Of oFolder:aDialogs[1] Action (ShowHelp('1'))
	@ 10, (aTam[2]*0.43) Button OemToAnsi(STR0004) Size 30, 10 Pixel Of oFolder:aDialogs[2] Action (ShowHelp('1'))
	@ 10, (aTam[2]*0.43) Button OemToAnsi(STR0004) Size 30, 10 Pixel Of oFolder:aDialogs[3] Action (ShowHelp('2'))		
	
	/*Para adicionar checkboxes na tela basta incluir nova posi��o no vetor aTarefas com o seguinte formato:
		[1]Boolean->Para informar se deve vir pr�-selecionado;
		[2]String->Descri��o;
		[3]String->Nome do Arquivo(sem a parte _logix.unl);
		[4]Block->Bloco de c�digo � ser executado;
		[5]Object->Aba no qual o checkbox deve ser exibido;
		[6]Numeric->Ordem de execu��o, quando se � marcado mais de um item por vez o sistema executar� nessa ordem; 
	*/
	aAdd(aTarefas,{.F.,OemToAnsi(STR0009)	,'cargo'				,{||U_RHIMP02(cFile)},oFolder:aDialogs[1],1})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0010)	,'ccusto'				,{||U_RHIMP03(cFile)},oFolder:aDialogs[1],2})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0011)	,'unidade_funcional'	,{||U_RHIMP04(cFile)},oFolder:aDialogs[1],3})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0012)	,'funcionario'		,{||U_RHIMP08(cFile)},oFolder:aDialogs[1],7})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0013)	,'afastamento'		,{||U_RHIMP10(cFile)},oFolder:aDialogs[1],16})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0014)	,'folha_pagto'		,{||U_RHIMP12(cFile)},oFolder:aDialogs[1],11})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0015)	,'ferias'				,{||U_RHIMP15(cFile)},oFolder:aDialogs[1],13})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0016)	,'transferencias'		,{||U_RHIMP13(cFile)},oFolder:aDialogs[1],10})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0017)	,'sindicato'			,{||U_RHIMP05(cFile)},oFolder:aDialogs[1],4})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0018)	,'evento'				,{||U_RHIMP06(cFile)},oFolder:aDialogs[1],5})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0019)	,'escala'				,{||U_RHIMP07(cFile)},oFolder:aDialogs[1],6})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0020)	,'dependente'			,{||U_RHIMP09(cFile)},oFolder:aDialogs[1],8})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0021)	,'historico_salarial',{||U_RHIMP11(cFile)},oFolder:aDialogs[1],9})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0022)	,'rescisao'			,{||U_RHIMP14(cFile)},oFolder:aDialogs[1],12})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0023)	,'13_salario'			,{||U_RHIMP16(cFile)},oFolder:aDialogs[1],14})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0024)	,'area_linha_negocio',{||U_RHIMP22(cFile)},oFolder:aDialogs[1],17})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0025)	,''						,{||U_RHIMP23(cFile)},oFolder:aDialogs[1],15})/*Per�odos*/
	aAdd(aTarefas,{.F.,OemToAnsi(STR0059)	,'banco_agencia'		,{||U_RHIMP24(cFile)},oFolder:aDialogs[1],44})/*Bancos*/
	aAdd(aTarefas,{.F.,OemToAnsi(STR0060)	,'pensionista'		,{||U_RHIMP25(cFile)},oFolder:aDialogs[1],45})/*Benefici�rios*/
	aAdd(aTarefas,{.F.,OemToAnsi(STR0061)	,'alimentacao'		,{||U_RHIMP26(cFile)},oFolder:aDialogs[1],46})/*Vale Alimenta��o*/
	aAdd(aTarefas,{.F.,OemToAnsi(STR0064)	,'plano_saude'		,{||U_RHIMP28(cFile)},oFolder:aDialogs[1],47})/*Plano de Sa�de.*/
	
	/*Recebe o nome do arquivo completo, pois n�o segue o padr�o das demais tarefas.*/
	aAdd(aTarefas,{.F.,OemToAnsi(STR0067)	,'rhu_rend_isen_saud.unl',{||U_RHIMP27(cFile)},oFolder:aDialogs[1],48})/*Historico PLA.*/
	
	aAdd(aTarefas,{.F.,OemToAnsi(STR0030)	,'horarios'			,{||U_RHIMP17(cFile)},oFolder:aDialogs[2],18})	
	aAdd(aTarefas,{.F.,OemToAnsi(STR0027)	,'relogio'				,{||U_RHIMP18(cFile)},oFolder:aDialogs[2],19})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0028)	,'cracha_provisorio'	,{||U_RHIMP19(cFile)},oFolder:aDialogs[2],20})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0026)	,'ocorrencias'		,{||U_RHIMP21(cFile)},oFolder:aDialogs[2],21})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0029)	,'banco_horas'		,{||U_RHIMP20(cFile)},oFolder:aDialogs[2],22})
	
	aAdd(aTarefas,{.F.,OemToAnsi(STR0009),''	,{||TruncTable(cFile,"SRJ")},oFolder:aDialogs[3],23})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0010),''	,{||TruncTable(cFile,"CTT")},oFolder:aDialogs[3],24})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0011),''	,{||TruncTable(cFile,"SQB")},oFolder:aDialogs[3],25})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0012),''	,{||TruncTable(cFile,"SRA")},oFolder:aDialogs[3],26})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0013),''	,{||TruncTable(cFile,"SR8")},oFolder:aDialogs[3],27})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0014),''	,{||aEval({"SRC","SRD","RGB"},{|x|TruncTable(cFile,x)})},oFolder:aDialogs[3],28})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0015),''	,{||aEval({"SRF","SRR","SRH"},{|x|TruncTable(cFile,x)})},oFolder:aDialogs[3],29})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0016),''	,{||TruncTable(cFile,"SRE")},oFolder:aDialogs[3],30})	
	aAdd(aTarefas,{.F.,OemToAnsi(STR0017),''	,{||TruncTable(cFile,"RCE")},oFolder:aDialogs[3],31})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0018),''	,{||TruncTable(cFile,"SRV")},oFolder:aDialogs[3],32})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0019),''	,{||TruncTable(cFile,"SR6")},oFolder:aDialogs[3],33})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0020),''	,{||TruncTable(cFile,"SRB")},oFolder:aDialogs[3],34})	
	aAdd(aTarefas,{.F.,OemToAnsi(STR0021),''	,{||aEval({"SR3","SR7"},{|x|TruncTable(cFile,x)})},oFolder:aDialogs[3],35})		
	aAdd(aTarefas,{.F.,OemToAnsi(STR0022),''	,{||aEval({"SRG","SRR","RFY"},{|x|TruncTable(cFile,x)})},oFolder:aDialogs[3],36})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0023),''	,{||TruncTable(cFile,"SRD")},oFolder:aDialogs[3],37})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0024),''	,{||TruncTable(cFile,"CTD")},oFolder:aDialogs[3],38})	
	aAdd(aTarefas,{.F.,OemToAnsi(STR0026),''	,{||TruncTable(cFile,"SP9")},oFolder:aDialogs[3],39})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0027),''	,{||TruncTable(cFile,"SP0")},oFolder:aDialogs[3],40})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0028),''	,{||TruncTable(cFile,"SPE")},oFolder:aDialogs[3],41})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0029),''	,{||TruncTable(cFile,"SPI")},oFolder:aDialogs[3],42})
	aAdd(aTarefas,{.F.,OemToAnsi(STR0030),''	,{||TruncTable(cFile,"SPJ")},oFolder:aDialogs[3],43})
	
	aAdd(aTarefas,{.F.,OemToAnsi(STR0059),''	,{||TruncTable(cFile,"SA6")},oFolder:aDialogs[3],44}) //Banco-Ag�ncia
	aAdd(aTarefas,{.F.,OemToAnsi(STR0060),''	,{||TruncTable(cFile,"SRQ")},oFolder:aDialogs[3],45}) // Benefici�rios
	aAdd(aTarefas,{.F.,OemToAnsi(STR0061),''	,{||aEval({"RFO","SR0"},{|x|TruncTable(cFile,x)})},oFolder:aDialogs[3],46})
	
	/*Par�metros(Aba Op��es)*/	
	aAdd(aTarefas,{.T.,OemToAnsi(STR0063)	,'lIgnHrNorm'	,{||},oFolder:aDialogs[4],47})/*Ignora campo Hrs. Normais(R6_HRNORMA)?*/
	aAdd(aTarefas,{.F.,OemToAnsi(STR0066)	,'lUsaZap'		,{||},oFolder:aDialogs[4],47})// Delete e Zap?
	aAdd(aTarefas,{.T.,OemToAnsi(STR0065)	,'lErroNoFim'	,{||},oFolder:aDialogs[4],47})// Erros no Final?
	
	/* Por algum motivo � preciso ter um registro a mais no final, por favor n�o remover */
	aAdd(aTarefas,{.F.,'NULL'	,'',{||},Nil,0})
	aEval(aTarefas, {|x|aAdd(x,Nil)} )	
	aSort(aTarefas,1,Len(aTarefas)- 1,{|x,y| (x[5]:HWND*100 + x[6])  < (y[5]:HWND*100 + y[6])})
	
	/*Adiciona as tarefas a tela.*/
	PutTarefas(aTam)
	
	@ (aTam[1]*0.42), (aTam[2]*0.05) Say OemToAnsi(STR0037)+":"  Size 25, 20 	Of oMainWnd Pixel
	@ (aTam[1]*0.42), (aTam[2]*0.10) Msget cTargetDir 	Size 150, 09 	Of oMainWnd Pixel	READONLY
	Define SButton From (aTam[1]*0.42), (aTam[2]*0.35) Type 14 Enable Of oMainWnd Action (OpenDir())
			
	@ (aTam[1]*0.46), (aTam[2]*0.10) 		Button oBtnOk Prompt OemToAnsi(STR0007) Size 40, 15 Pixel Of oMainWnd Action (ExecTarefas())	
	@ (aTam[1]*0.46), (aTam[2]*0.10)+ 45 	Button OemToAnsi(STR0008) Size 40, 15 Pixel Of oMainWnd Action (oMainWnd:End())
	
	Activate MSDialog oMainWnd Centered	
	
	aEval(aTarefas,{|x|aSize(x,0),x:= Nil})	
	aSize(aTarefas,0)
	aTarefas := Nil	
Return (Nil)

/*/{Protheus.doc} ExecTarefas
	Faz as Devidas Validacoes e Importa os Dados dos Arquivos
@author Rafael Luis da Silva
@since 27/08/2009
@version P11
@return xValor, Retorna Verdadeiro caso executado, Nulo caso contr�rio
@Obs Reformulada em 07/2015 para a Vers�o 12, antiga U_RIM01Importar
/*/
Static Function ExecTarefas()	
	Local nI := 0	
	Local cTempTitle := ''
	Private cStart := ''
	Private aLogTitle := {}
	//Inicializa o Array de Inconsistencias a ser apresentada no final do processo
	aInconsistencia = {}	
 	
 	for nI:= 1 to Len(aTarefas)-1
 		/*Se for Par�metro(Aba "Op��es)*/
 		if(oFolder:aDialogs[4]:HWND == aTarefas[nI,5]:HWND)
 			/*Declara a vari�vel como Private pra deixar dispon�vel
 			 pro escopos das fun��es chamadas pelo aTarefas!*/
 			Private &(aTarefas[nI,3]) := aTarefas[nI,1]	
 		endIf 			
 	next nI
 	
	if ((oFolder:nOption == 1) .Or. (oFolder:nOption == 2))
		
		if!(AScan(aTarefas, {|x|x[1]}) > 0)
			MsgAlert(OemToAnsi(STR0031), OemToAnsi(STR0032))
			Return(Nil)
		endIf
		If Empty(cTargetDir) .And. (!OnlyEmptyFile())
			MsgAlert(OemToAnsi(STR0033), OemToAnsi(STR0032))//Informe a pasta dos arquivo a serem importados!
			Return(Nil)
		EndIf
		if!(MsgYesNo(OemToAnsi(STR0034))) //'Confirma a importa��o?' 
			Return(Nil)	
		endIf
		
		/*Limpa o hist�rico de erros.*/
		aSize(aTitles,1)
		aSize(aLogs,1)
		aLogs[1] := {}
		
		/*Inicio do Processamento*/
		cStart := Time()
		for nI:= 1 to Len(aTarefas)-1
			if(aTarefas[nI,1]) .And. (oFolder:aDialogs[oFolder:nOption]:HWND == aTarefas[nI,5]:HWND)				
				cFile := cTargetDir + aTarefas[nI,3]
								
				cFile +=  IIF(At('.',aTarefas[nI,3]) > 0,'',"_logix.unl")/*Se o arquivo n�o tem extens�o*/
				
				lFirst := .T.
				aInconsistencia := {}
				if!(Empty(aTarefas[nI,3]))				 	
					if(File(cFile))						
						Begin Sequence
							/* Exemplo : Processa(<bAction>,<cTitle>,<cMsg>,<lAbort>) */
							Processa(aTarefas[nI,4], OemToAnsi(STR0035)+ "["+ aTarefas[nI,2] +"]",,.T.)
						RECOVER							
							/*Garante que caso a opera��o tenha sido abortada,qualquer arquivo ainda aberto ser� fechado*/						
							FT_FUSE() 
						End Sequence
						
						RenameFile(cTargetDir,aTarefas[nI,3]+ IIF(At('.',aTarefas[nI,3]) > 0,'',"_logix.unl"))
						
						/*N�o processa demais tarefas caso tenha dado algum erro.*/
						if(lStopOnErr)
							Exit
						endIf						
					Else
						MsgAlert(OemToAnsi(STR0036) + ':' + cFile, OemToAnsi(STR0032))
						Return(Nil)
					endIf				
				Else				
					Begin Sequence
						Processa(aTarefas[nI,4], OemToAnsi(STR0035)+ "["+ aTarefas[nI,2] +"]",,.T.)					
					End Sequence					
				EndIf													
				aTarefas[nI,1] := .F.
				
				if(Len(aInconsistencia) > 0)
					/*Entidade [ XXXXXX ]  - Tempo Decorrido : 00:10:33 */
					cTempTitle := OemToAnsi(STR0050) + "[ " + aTarefas[nI,2] + " ]"
					cTempTitle += ' - ' + OemToAnsi(STR0051) +':'+ ElapTime(cStart, TIME()) + '.'
					if(nQtdLinhas > 0)						
						cTempTitle += ' Total de linhas: ' + cValToChar(nQtdLinhas)
					endIf					
					
					aAdd(aTitles,cTempTitle)
					aAdd(aLogs,aInconsistencia)					
				endIf				
			endIf
		next nI
					
	Elseif (oFolder:nOption == 3)
		
		if!(AScan(aTarefas, {|x|x[1]}) > 0)
			MsgAlert(OemToAnsi(STR0040), OemToAnsi(STR0032)) //'Informe a tabela a ser Apagada!'
			Return(Nil)
		endIf
		If Empty(cTargetDir) 
			MsgAlert(OemToAnsi(STR0041), OemToAnsi(STR0032))//'Informe a pasta do arquivo de empresas a serem Apagados!'
			Return(Nil)
		EndIf
		if!(MsgYesNo(OemToAnsi(STR0039))) //'Confirma a Limpeza de Tabelas?' 
			Return(Nil)	
		endIf
		
		cStart := Time()		
		cFile := cTargetDir + "valida_empresas_protheus.unl"		
		if(File(cFile))
			for nI:= 1 to Len(aTarefas)-1
				aInconsistencia := {}
				if(aTarefas[nI,1]) .And. (oFolder:aDialogs[oFolder:nOption]:HWND == aTarefas[nI,5]:HWND)									
					Begin Sequence
						Processa(aTarefas[nI,4], OemToAnsi(STR0038)+ "["+ aTarefas[nI,2] +"]",,.T.)					
					End Sequence																		
				endIf
				
				if(Len(aInconsistencia) > 0)
					aAdd(aTitles,OemToAnsi(STR0050) + "[" + aTarefas[nI,2] + "]")
					aAdd(aLogs,aInconsistencia)
				endIf
			next nI						
			RenameFile(cTargetDir,"valida_empresas_protheus.unl")
		Else
			MsgAlert(OemToAnsi(STR0036) + ':' + cFile, OemToAnsi(STR0032))
			Return(Nil)
		EndIf
	EndIf	
	TrataLog()	
Return (.T.)

/*/{Protheus.doc} TruncTable
	Valida as empresas, para limpeza das tabelas
@author Luis Trombini
@since 17/07/2014
@version P11
@param cFileName, caractere, (Descri��o do par�metro)
@param cAlias, character, (Descri��o do par�metro)
@return ${return}, ${return_description}
/*/
Static Function TruncTable(cFileName,cAlias)
	Local cBuffer       := ""
	Local cEmpresaLog   := ""
	Local cEmpresaArq   := ""
	Local cFilialArq    := ""	
	Local lExiste		:= .F.
	Local lIncluiu 		:= .F.
	Local aTabelas 		:= {cAlias}	
	Local cErrMsg	:= ''
	Local cCommand	:= ""
	Private aErro       := {}
	
	FT_FUSE(cFileName)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	
	While !FT_FEOF()
		cBuffer := FT_FREADLN()
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)
		
		cEmpresaLog :=aLinha[1]
		cEmpresaArq	:=aLinha[2]
		cFilialArq  :=aLinha[3]	
		
		IncProc('['+ cEmpresaArq +'/'+ cFilialArq +'] - '+ OemToAnsi(STR0044) +' :' + RetSqlname(cAlias) + '('+ cAlias + ')')
		
		cErrMsg := 'Logix ' + OemToAnsi(STR0042) + ': '+ AllTrim(cEmpresaLog)
		cErrMsg += ' -> Protheus ' + OemToAnsi(STR0042) + '/' + OemToAnsi(STR0043) + ': ' + AllTrim(cEmpresaArq)+"/"+ AllTrim(cFilialArq)   
		
		U_RHPREARE(cEmpresaArq,cFilialArq,'','',.T.,@lExiste,,aTabelas,,@aErro,cErrMsg)		
		
		if lExiste			
			if(lUsaZap)				
				cCommand := "DELETE FROM " + RetSqlname(cAlias) 			
				TcSQLExec(cCommand)
			else			
				(cAlias)->(dbGoTop())
				while ( (cAlias)->(!Eof()) )
					RecLock(cAlias,.F.)
					(cAlias)->(dbDelete())
					(cAlias)->(MsUnlock())
					(cAlias)->(dbSkip())
				End
			endIf			
		else
			aAdd(aErro,cErrMsg)
		Endif								
		
		FT_FSKIP()			
	ENDDO	
	
	if(Len(aErro) > 0)		
		U_RIM01ERR(aErro)
	endIf
	
	aSize(aErro,0)
	aErro := Nil		
Return (.T.)

/*/{Protheus.doc} RHPREARE
	Fun��o respons�vel por determinar o ambiente correto;
	Fun��o j� existia e foi otimizada
@since 16/07/2015
@version P11
@author Equipe RH
@param cEmpAux, character, (Descri��o do par�metro)
@param cFilAux, character, (Descri��o do par�metro)
@param cEmpOri, character, (Descri��o do par�metro)
@param cFilOri, character, (Descri��o do par�metro)
@param lChangeEnv, ${param_type}, (Descri��o do par�metro)
@param lExiste, ${param_type}, (Descri��o do par�metro)
@param cFunName, character, (Descri��o do par�metro)
@param aTabelas, array, (Descri��o do par�metro)
@param cMod, character, (Descri��o do par�metro)
@param aErro, array, (Descri��o do par�metro)
@param cDesc, character, (Descri��o do par�metro)
@return ${return}, ${return_description}
/*/	
User Function RHPREARE(cEmpAux,cFilAux,cEmpOri,cFilOri,lChangeEnv,lExiste,cFunName,aTabelas,cMod,aErro,cEntidade)		
	Local cDescErro	:= ""
	Local lRet 		:= .F.
	Local cMsg			:= ' - ' + OemToAnsi(STR0045)
	Default cEmpAux := cEmpAnt
	Default cFilAux := ''		
	Default cFunName := 'RHIMP01' 
	Default aTabelas := {}
	Default cMod := 'GPE'
	Default aErro:= {}
	Default cEntidade:=''
	
	if(Empty(cFilAux))
		cFilAux := ''
	Else
		cFilAux := PadR(cFilAux,nTamFilSM0)
	endIf	
	
	if(cEmpAux == cEmpAnt .And. cFilAux == cFilAnt) .Or. (cEmpAux == cEmpAnt .And. cFilAux = '')
		lExiste := .T.
		
		if(lFirst)
			lFirst := .F.
			lChangeEnv:= .T.	
			aEval(aTabelas,{|x|CHKFILE(x)})		
		Else
			lChangeEnv:= .F.		
		endIf
				
		Return (.T.)
	endIf
			
	SM0->(DbSetOrder(1))	//M0_CODIGO+M0_CODFIL	
	lExiste := SM0->(DbSeek(cEmpAux + cFilAux))
	if(lExiste)
		cEmpOri := SM0->M0_CODIGO
		cFilOri := SM0->M0_CODFIL
		RpcClearEnv()
		RpcSetType(3)
		OpenSm0()
		SM0->(DbSetOrder(1))
		SM0->(DbSeek(cEmpOri + cFilOri))
		PREPARE ENVIRONMENT EMPRESA (cEmpOri) FILIAL (cFilOri) MODULO cMod FUNNAME cFunName
		__cInternet := Nil
		lChangeEnv := .T.
		aEval(aTabelas,{|x|CHKFILE(x)})		
		
		If(FindFunction( "RetPadEpoch" ))
			RetPadEpoch()
		EndIf
		lRet  := .T.
	Else		
		lRet  := .F.
		lChangeEnv := .F.
		cMsg := '['+ cEmpAux + '/' + cFilAux + ']'+ OemToAnsi(STR0050) + ':' + cEntidade + cMsg		
		aAdd(aErro,cMsg)
	endIf
Return lRet

/*/{Protheus.doc} RIM01ERR
	Adiciona mensagens de inconsist�ncias na vari�vel aInconsistencia
@author Edna Dalfovo
@since 06/09/2012
@version P11
@param uDescErro, vari�vel, (Descri��o do par�metro)
@return Nil, Valor Nulo
@Obs Reformulada em 07/2015
/*/
User Function RIM01ERR(uDescErro,lSystem)
	Local cType := ValType(uDescErro)
	Default lSystem := .F.
	
	if(Type('aInconsistencia') == 'U')
		_SetOwnerPrvt('aInconsistencia',{})
	endIf
	
	if(!lSystem)		
		if(cType == 'C')
			aAdd(aInconsistencia, uDescErro)	
		ElseIf (cType == 'A')
			aEval(uDescErro, { |x| Aadd(aInconsistencia, x)  } )
		EndIf
	else
		aAdd(aLogs[1],uDescErro)
	endIf
	
	/*Checa se deve parar o processamento.*/
	U_StopProc()		
Return(Nil)

/*/{Protheus.doc} FormatDate
Responsavel em retornar a data atual formatada para renomear o arquivo importado.
@author Rafael Luis da Silva
@since 22/02/2010
@version P11
@return dData, Data Formatada no seguinte formado : DD-MM-YYYY_
@obs Antiga fun��o RIM01RetData, reformulada
/*/
Static Function FormatDate()
	Local dData
	Local cDia := ""
	Local cMes := ""
	Local cAno := ""
	
	dData := Date()
	cDia  := StrZero(Day(dData), 2)
	cMes  := StrZero(Month(dData), 2)
	cAno  := LTrim(Str(Year(dData)))
	
Return (cDia + "-" + cMes + "-" + cAno + "_")

/*/{Protheus.doc} OpenDir
	Responsavel por definir o tipo de arquivo a ser selecionado 
	e por abrir uma caixa de selecao para procurar o arquivo.
@author Rafael Luis da Silva
@since 22/02/2010
@version P12
@return Nil, Valor Nulo
@obs Antiga fun��o RIM01OpenFile, reformulada
/*/
Static Function OpenDir()
	Local cType := ""	
	cType      := '*.unl'	
	cTargetDir := cGetFile(cType,OemToAnsi(STR0046),, cTargetDir, .T., GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_LOCALFLOPPY + 128, .F.)		
Return (Nil)

/*/{Protheus.doc} TrataLog
(long_description)
@author philipe.pompeu
@since 14/07/2015
@version P12
@return ${return}, ${return_description}
/*/
Static Function TrataLog()
	Local bMakeLog := { || NIL }
	
	if(Len(aLogs[1]) == 0)
		aDel(aLogs,1)
		aSize(aLogs,Len(aLogs)-1)
		aDel(aTitles,1)
		aSize(aTitles,Len(aTitles)-1)
	endIf
		
	if(Len(aLogs) > 0)		
		If (MsgNoYes(OemToAnsi(STR0048), OemToAnsi(STR0047)))		
			bMakeLog := { || fMakeLog(  aLogs , aTitles , NIL , .T. , "RHIMP01_"+ FormatDate() + cValToChar(Seconds()), NIL,"G","L",NIL,.F.) }
			MsAguarde( bMakeLog , OemToAnsi(STR0049) )
		EndIf	
	endIf

Return nil

/*/{Protheus.doc} RenameFile
	Renomeia Arquivos
@author philipe.pompeu
@since 14/07/2015
@version P12
@param cDir, character, (Descri��o do par�metro)
@param cFileName, character, (Descri��o do par�metro)
@return Nil, Valor Nulo
/*/
Static Function RenameFile(cDir,cFileName)
	Local cNewName := cDir + FormatDate() + cFileName
	Local cOldFile := cDir + cFileName
	Default cDir := cTargetDir
	FRename(cOldFile, cNewName)	
Return nil

/*/{Protheus.doc} RIM01MVC
	Importacao dos dados via MVC
@author Edna Dalfovo
@since 06/09/2012
@version P11
@param cAlias, character, (Descri��o do par�metro)
@param aCampos, array, (Descri��o do par�metro)
@param cModel, character, (Descri��o do par�metro)
@param cDesc, character, (Descri��o do par�metro)
@param cChave, character, (Descri��o do par�metro)
@param cGetModel, character, (Descri��o do par�metro)
@param lSetOrder, ${param_type}, (Descri��o do par�metro)
@return ${return}, ${return_description}
/*/
User Function RIM01MVC( cAlias, aCampos,cModel,cDesc,cChave,cGetModel,lSetOrder,oModel,aAux)
	Local aArea	:= GetArea()
	Local oAux,oStruct
	Local nI 		:= 0
	Local lRet 		:= .T.
	Local cDescErro := ""
	Local nTamP 	:= 0
	Local nTamE 	:= 0
	Local aErrTmp	:= {}
	Local lExtModel:= .F.
	Local nOperation	:= 3
	Local aProblems := {}
	Local nPosCampo := 0
	Default lSetOrder:= .T.	
	Default oModel := Nil
	Default aAux := {} 
	
	if(lSetOrder)		
		dbSelectArea(cAlias)
		(cAlias)->(dbSetOrder(1))
	endIf
	
	if(oModel == Nil)
		oModel := FWLoadModel( cModel )	
	Else
		lExtModel := .T.			
	endIf
	
	// Temos que definir qual a opera��o deseja: 3 � Inclus�o / 4 � Altera��o / 5 - Exclus�o	
	If !(cAlias)->(DbSeek(xFilial(cAlias) + aCampos[2,2]))
		oModel:SetOperation( 3 )
	Else
		oModel:SetOperation( 4 )
	EndIf
	
	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	oModel:Activate()		
	
	nOperation	:= oModel:GetOperation()	
	nStart := IIF(nOperation == 4,3,1)
		
	For nI := nStart To Len( aCampos )
		If( nOperation == 4 )
			If aCampos[nI,1] $ '_FILIAL' .Or. aCampos[nI,1] == aCampos[2,1]
				Loop
			EndIf
		EndIf
		
		nPosCampo	:= aScan(aAux,{|x| AllTrim( x[3] )== AllTrim(aCampos[nI][1]) } )	
		If (nPosCampo > 0 ) .Or.(Len(aAux) == 0)
			if(aAux[nPosCampo,4] == 'C')
				aCampos[nI,2] := PadR(aCampos[nI,2],aAux[nPosCampo,5])
			endIf
			/*N�o valida campo � campo!*/
			oModel:LoadValue(cGetModel, aCampos[nI][1], aCampos[nI][2])		
		EndIf
	Next nI
	
	If (oModel:VldData()) /*Valida o modelo como um todo*/
		oModel:CommitData()
	Else
		aProblems := oModel:GetErrorMessage()
	EndIf	
	
	oModel:DeActivate()
	
	if(!lExtModel)		
		oModel:Destroy()
		oModel:= nil
	endIf
	
	U_RIM01ERR(aProblems)
	
	aSize(aProblems,0)
	aProblems := Nil
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} ShowHelp
	Respons�vel por mostrar o Help
@author philipe.pompeu
@since 17/07/2015
@version P12
@param cOption, character, (Descri��o do par�metro)
@return ${return}, ${return_description}
/*/
Static Function ShowHelp(cOption)
	Local oMyDialog := Nil
	Local oMemo:= Nil
	Local cMemo:= ''
	Local oBtnCancel:= Nil
	Local oBtnConfir:= Nil
	Local aHelp	:= {}
	Local cTitle := OemToAnsi(STR0004)
	
	Do Case
		Case (cOption == '1')			
			aAdd(aHelp,"1- Verifique se o arquivo valida_empresas_protheus.unl, contem apenas as empresas a serem tratadas")
			aAdd(aHelp,"2- Rode o migrador de acordo com a ordem indicada abaixo, para eliminar as inconsistencias por ")
			aAdd(aHelp,"Falta de informa��es, ordem de migra��o dos cadastros:")
			aAdd(aHelp,"1 - Cadastro de Fun��o  / 2 - Sindicato  /  3 - Centro de Custo /  4 - Verba 			")
			aAdd(aHelp,"5 - Departamento  /  6 - Turno  /  7 - Item Cont�bil  /  8 - Funcionarios")
			aAdd(aHelp,"9 - Dependentes  /  10 - Afastamentos  /  11 - Hist. Salarial  /  12 - Folha Pgto")
			aAdd(aHelp,"13 - Rescis�es  /  14 - F�rias  /  15 - 13� Salario  /  16 - Transfer�ncias")
			aAdd(aHelp,"Obs.: Para uma nova importa��o dos Cadastros Basicos, caso o sistema encontre uma informa��o ja ")
			aAdd(aHelp,"cadatrada o sistema ira alterar os dados de acordo com novo arquivo.")
			aAdd(aHelp,"Obs.: Para uma nova importa��o dos Movimentos de F�rias,13�Sal. e Rescis�o o sistema ira apagar")
			aAdd(aHelp,"apagar a filial que esta sendo migrada novamente.")
			aAdd(aHelp,"Obs.: Para migra o movimento de folha, o sistema ira perguntar se apaga o movimento, em caso de")
			aAdd(aHelp,"de Substitui��o confirmar, n�o confirmar em caso de continua��o de importa��o de varios arquivos")
		Case (cOption == '2')
			aAdd(aHelp,"Para utiliza��o da Exclus�o de Tabelas, verifique se o arquivo valida_empresas_protheus.unl;")
			aAdd(aHelp,"contenha apenas a empresa que tera as tabelas a serem excluidas.  ")
			aAdd(aHelp,"A Nova Op��o Exclus�o de Tabelas tem finalidade de Apagar a Tabela selecionada para uma nova ")
			aAdd(aHelp,"importa��o, eliminando toda e qualquer informa��o importada anteriormente.")
			aAdd(aHelp,"Obs.: Para a exclus�o dos arquivos de Movimentos de F�rias,13�Salario e Rescis�o � obrigatoria")
			aAdd(aHelp," a limpeza do movimento de Folha de Pagamento.")		
	EndCase	
	
	aEval(aHelp,{|x|cMemo+= x + Chr(13) + Chr(10)})
	aSize(aHelp,0)
	aHelp := Nil
																		  	
	DEFINE MSDIALOG oMyDialog TITLE cTitle FROM 0,0 TO 300,490 OF oMyDialog PIXEL
	oMemo:= TMultiGet():New(5,5,{|u|if(Pcount()>0,cMemo:=u,cMemo)},oMyDialog,235,110,,,,,,.T.)	
	oMemo:lReadOnly :=  .T.
	oBtnConfir:=TButton():New(125,190	,OemToAnsi(STR0005),oMyDialog,{||oMyDialog:End()},50,20,,,,.T.)
	
	ACTIVATE MSDIALOG oMyDialog CENTERED	
Return nil


/*/{Protheus.doc} IncRuler
	Incrementa a R�gua Atual
@author PHILIPE.POMPEU
@since 27/07/2015
@version P12
@param cEntity, character, (Descri��o do par�metro)
@param cIdentity, character, (Descri��o do par�metro)
@param cStartTime, character, (Descri��o do par�metro)
@param lIgnore, ${param_type}, (Descri��o do par�metro)
@return ${return}, ${return_description}
/*/
User Function IncRuler(cEntity,cIdentity,cStartTime,lIgnore,lOnlyMsg,oObjRegua)
	Local cMsg		:= ''
	Default cEntity 	:= ''
	Default cIdentity	:= ''
	Default cStartTime 	:= cStart
	Default lIgnore 	:= .F.
	Default lOnlyMsg 	:= .F.
	Default oObjRegua   := nil
	
	if(lOnlyMsg)
		cMsg := cEntity + " - " + OemToAnsi(STR0051) +':'+ ElapTime( cStartTime, TIME() )
	else	
		if(lIgnore)
			cMsg := OemToAnsi(STR0052)+' ['+ cEmpAnt + '/'+ cFilAnt +'] '+ cEntity +' : ['+ cIdentity +'] - ' + OemToAnsi(STR0051) +':'+ ElapTime( cStartTime, TIME() ) 
		Else
			cMsg := '['+ cEmpAnt + '/'+ cFilAnt +'] '+ cEntity +' : ['+ cIdentity +'] - ' + OemToAnsi(STR0051) +':'+ ElapTime( cStartTime, TIME() ) 
		endIf	
	endIf
	if(oObjRegua == nil)
		IncProc(cMsg)
	else
		oObjRegua:IncRegua2(cMsg)		
	endIf
Return cMsg

/*/{Protheus.doc} VldValue
Valida valor n�merico
@author Daniel Augusto Braga
@since 26/12/2013
@version P11
@param cValue, vari�vel, valor a ser convertido
@return nValue, valor n�merico convertido.
/*/
User Function VldValue(cValue)
	Local nValue := 0
	if valType(cValue) == "C"
		//Tratamento para valores monet�rios
		if At(",",cValue) > 0
			cValue := strTran(cValue,".","")
			cValue := strTran(cValue,",",".")
			nValue := val(cValue)
		else
			nValue := val(cValue)
		endIf
	endIf
	
Return nValue

/*/{Protheus.doc} PerInval
	Retorna todos os per�odos inv�lidos.
@author philipe.pompeu
@since 28/07/2015
@version P11
@return ${return}, ${return_description}
/*/
User Function PerInval()
	Local cAliasAux := GetNextAlias()	
	Local aRet 		:= {}
	
	BeginSql alias cAliasAux
		
		SELECT DISTINCT RC_PROCES AS PROCES,RC_PERIODO AS PERIODO,RC_SEMANA AS SEMANA,RC_ROTEIR AS ROTEIR,RCH_PER 
		FROM %table:SRC% SRC
		LEFT OUTER JOIN %table:RCH% RCH ON(RCH_PROCES = RC_PROCES AND RCH_PER = RC_PERIODO AND RCH_NUMPAG = RC_SEMANA AND RCH_ROTEIR = RC_ROTEIR)
		WHERE 
		RC_FILIAL = %xFilial:SRC%
		AND
		RCH_FILIAL = %xFilial:RCH%
		AND
		RCH.%NotDel%
		AND
		SRC.%NotDel%
		AND
		RCH_PER IS NULL		
		UNION		
		SELECT DISTINCT RD_PROCES AS PROCES,RD_PERIODO AS PERIODO,RD_SEMANA AS SEMANA,RD_ROTEIR AS ROTEIR,RCH_PER 
		FROM %table:SRD% SRD
		LEFT OUTER JOIN %table:RCH% RCH ON(RCH_PROCES = RD_PROCES AND RCH_PER = RD_PERIODO AND RCH_NUMPAG = RD_SEMANA AND RCH_ROTEIR = RD_ROTEIR)
		WHERE 
		RD_FILIAL = %xFilial:SRD%
		AND
		SRD.%NotDel%
		AND
		RCH_PER IS NULL		
	EndSql	
	
	while ((cAliasAux)->(!Eof()) )		
		aAdd(aRet,{(cAliasAux)->PROCES,(cAliasAux)->PERIODO})		
		(cAliasAux)->(dbSkip())
	End
				
	(cAliasAux)->(DbCloseArea())	
Return (aRet)

/*/{Protheus.doc} CanTrunk
	Pede permiss�o pra truncar os campos em <aCampos>
@author philipe.pompeu
@since 04/08/2015
@version P11
@param aCampos, vetor, cont�m o nome dos arquivos
@return lResult, Verdadeiro se pode truncar
/*/
User Function CanTrunk(aCampos)
	Local aArea	:= 	GetArea()
	Local lResult := .T.
	Local oMyDialog := Nil
	Local oMemo:= Nil
	Local cMemo:= ''
	Local oBtnCancel	:= Nil
	Local oBtnConfir	:= Nil
	Local aHelp		:= {}
	Local cTitle 		:= OemToAnsi(STR0032)	
	Default aCampos 	:= {}
	
	if(IsInCallStack('RHIMPGEN'))
		Return .T.
	endIf
	
	aAdd(aHelp, PadR(OemToAnsi(STR0054),10,'.') + '->' + OemToAnsi(STR0055))	
	
	aEval(aCampos,{|x|aAdd(aHelp,PadR(x,10,'.') + '->' + StrZero(TamSx3(x)[1], Len(OemToAnsi(STR0055))))})
	
	aEval(aHelp,{|x|cMemo+= x + Chr(13) + Chr(10)})
	aSize(aHelp,0)
	aHelp := Nil
																		  	
	DEFINE MSDIALOG oMyDialog TITLE cTitle FROM 0,0 TO 280,420 OF oMyDialog PIXEL
	@ 5,5 SAY OemToAnsi(STR0053) Size 235,90 OF oMyDialog Pixel
	oMemo:= TMultiGet():New(15,5,{|u|if(Pcount()>0,cMemo:=u,cMemo)},oMyDialog,200,90,,,,,,.T.)	
	oMemo:lReadOnly :=  .T.
	
	@ 110,90 SAY OemToAnsi(STR0056) Size 235,90 OF oMyDialog Pixel
	oBtnCancel:=TButton():New(120,5		,OemToAnsi(STR0008),oMyDialog,{||lResult:=.F.,oMyDialog:End()},50,20,,,,.T.)	
	oBtnConfir:=TButton():New(120,155	,OemToAnsi(STR0007),oMyDialog,{||lResult:=.T.,oMyDialog:End()},50,20,,,,.T.)
	
	ACTIVATE MSDIALOG oMyDialog CENTERED
	RestArea(aArea)
Return (lResult)

/*/{Protheus.doc} CarregaCid
	Carrega a tabela de C.I.D
@author philipe.pompeu
@since 14/09/2015
@version P12
@return Nil, valor nulo
/*/
Static Function CarregaCid()
	Local aArea	:= TMR->(GetArea())
	Local cFil		:= xFilial("TMR")
	
	TMR->(dbSetOrder(1))	
	If	!(TMR->(dbSeek(cFil+"A00.0"))) .Or. ;
		!(TMR->(dbSeek(cFil+"D00.0"))) .Or. ;
		!(TMR->(dbSeek(cFil+"H00.0"))) .Or. ;
		!(TMR->(dbSeek(cFil+"R00.0"))) .Or. ;
		!(TMR->(dbSeek(cFil+"Z00.0")))
		If Type('cPaisLoc') == 'C'
			If cPaisLoc == "BRA"				
				Processa({|| MDT080CID()},OemToAnsi(STR0057))
			EndIf
		EndIf
	EndIf
	
	RestArea(aArea)
Return (Nil)

/*/{Protheus.doc} OnlyEmptyFile
	N�o solicita o diret�rio se todas as tarefas selecionadas n�o tiverem arquivo.
@author PHILIPE.POMPEU
@since 17/09/2015
@version P12
@return lResult, l�gico, verdadeiro se todos os selecionados tiverem arquivo vazio.
/*/
Static Function OnlyEmptyFile()
	Local lResult := .F.	
	Local nHasFile := 0
	
	aEval(aTarefas,{|x|IIF((x[1] .And. !Empty(x[3]) .And. (oFolder:aDialogs[4]:HWND != x[5]:HWND)),nHasFile++,Nil)})
	
	lResult := !(nHasFile > 0)	
	
Return (lResult)

/*/{Protheus.doc} Proceed
@author PHILIPE.POMPEU
@since 15/09/2015
@version P12
@param nTamCerto, num�rico, (Descri��o do par�metro)
@param nTamReal, num�rico, (Descri��o do par�metro)
@return ${return}, ${return_description}
/*/
User Function Proceed(nTamCerto,nTamReal)
	Local aArea	:= 	GetArea()	
	Local lResult	:= .T.
	Default nSize	:= 1
	
	if(nTamReal < nTamCerto)	
		if(lObgESocial)
			MsgAlert( OemtoAnsi(STR0058), OemtoAnsi(STR0032))
			lResult := .F.		
		endIf
	endIf
	
	RestArea(aArea)
Return (lResult)

/*/{Protheus.doc} StopProc
	Verifica se deve parar o processamento.
@author PHILIPE.POMPEU
@since 15/09/2015
@version P12
@param aErr, vetor, contem os erros
@return ${return}, ${return_description}
/*/
User Function StopProc(aErr)
	Default aErr := {}	
	/*Se n�o for pra exibir o Erro no final do processamento...*/
	if(!lErroNoFim)		
		lStopOnErr := ((Len(aInconsistencia) + Len(aErr))> 0)
	endIf
Return lStopOnErr

/*/{Protheus.doc} RHImpEnv
	Configura o ambiente inicial para o RHIMP01 e pro RHIMPGEN,
	implementa��o unificada para facilitar a manuten��o.
@author PHILIPE.POMPEU
@since 22/11/2016
@version P12
/*/
User Function RHImpEnv()	
	Local cModuloEnv := ''
	_SetOwnerPrvt("cDtFormat",'')
	_SetOwnerPrvt("lFirst",.T.)
	_SetOwnerPrvt("lObgESocial",.F.) 
	_SetOwnerPrvt("nTamFilSM0",2)
	_SetOwnerPrvt("cTargetDir","")	
	_SetOwnerPrvt("cFile","")
	_SetOwnerPrvt("aLogs",{{}})
	_SetOwnerPrvt("aTitles",{OemToAnsi(STR0047)})
	_SetOwnerPrvt("aInconsistencia",{})
	_SetOwnerPrvt("lAutoErrNoFile",.T.)
	_SetOwnerPrvt("lMsErroAuto",.F.)
	_SetOwnerPrvt("lPicFormat",(Upper(GetSrvProfString("PictFormat", "DEFAULT")) == "DEFAULT"))
	_SetOwnerPrvt("lStopOnErr",.F.)
	_SetOwnerPrvt("nQtdLinhas",0)
	
	cModuloEnv := IIF(Type('cModulo')=='U','GPE',cModulo)
	
	RpcSetType(3)
	OpenSm0()
	SM0->(DbGoTop())
	PREPARE ENVIRONMENT EMPRESA (SM0->M0_CODIGO) FILIAL (SM0->M0_CODFIL) MODULO cModuloEnv
	__cInternet := Nil
	
	aEval({'SX2','SX3','SX5','SX6','TMR','CC2','RCB','RCC'},{|x|CHKFILE(x)})
		
	lObgESocial := (SuperGetMv("MV_EFDAVIS",NIL,"2") == "1")	
	
	/*Carrega a tabela de CID do SIGAMNT*/
	CarregaCid()
	
	/*Criacao das Definicoes de Tabelas Padroes*/
	GpIniTab()
	
	nTamFilSM0:= TamSX3('RA_FILIAL')[1]
		
	cDtFormat := Set(_SET_DATEFORMAT)
	Set(_SET_DATEFORMAT, "dd/mm/yyyy")
		
	SetSkinDefault()
Return nil

/*/{Protheus.doc} PutTarefas
	Essa fun��o � respons�vel por colocar o vetor <aTarefas> na tela;
@author PHILIPE.POMPEU
@since 22/11/2016
@version P12
/*/
Static Function PutTarefas(aTam)
	Local nI := 1
	Local nX := 10
	Local nY := 10
	Local nOrig	:= 0
	Local nPosition := 1
	
	nI:=1
	while(nI <= Len(aTarefas)-1)
		nX := 10
		nY := 10
		nPosition := 1
		nOrig := aTarefas[nI,5]:HWND
		
		@ nY, nX To (aTam[1]*0.33), (aTam[2]*0.48) Of aTarefas[nI,5] Pixel
		nX += 10		
		while(nI <= Len(aTarefas)-1) .And. (aTarefas[nI,5]:HWND == nOrig)
			nY += 10		 
			@ nY, nX Checkbox aTarefas[nI,7] Var aTarefas[nI,1] 	Prompt aTarefas[nI,2] Size 75, 7 Of aTarefas[nI,5] Pixel		
			aTarefas[nI,7]:bSetGet := &("{|u| if( Pcount( )>0, aTarefas["+ cValToChar(nI) +",1]:= u,aTarefas["+ cValToChar(nI) +",1] ) }")
			if(Mod ( nPosition, 10 ) == 0)
				nX += 80
				nY := 10	
			endIf			
			nPosition ++			
			nI++
		EndDo		
	EndDo	
Return Nil

User Function ImpRegua(oSelf,nFator1, nFator2)
	Local nFileSize := 0
	Default oSelf := Nil
	Default nFator1 := 1
	Default nFator2 := 1
	
	nFileSize := FT_FLASTREC()	
	If oSelf == Nil		
		ProcRegua(nFileSize * nFator1)
	Else
		oSelf:SetRegua2(nFileSize * nFator2)
	EndIf
	
	/*Atualiza vari�vel Private com a
	quantidade total de linhas da importacao atual.*/
	nQtdLinhas := nFileSize
Return nFileSize
