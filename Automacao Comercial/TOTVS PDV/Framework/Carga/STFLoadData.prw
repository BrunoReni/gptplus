#INCLUDE "Protheus.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "STFLoadData.ch"

/*
	Estrutura da Tabela MH1
	
	X3_ARQUIVO  X3_ORDEM	X3_CAMPO	 X3_TIPO X3_TAMANHO	X3_TITULO			X3_DESCRIC				X3_PICTURE
	MH1			 01			MH1_FILIAL	 C		  2				Filial	Sucursal	Filial do Sistema	 	@!
	MH1			 02			MH1_COD	 C		  6				Cod. Carga			Cod. Carga	 			@!
	MH1			 03			MH1_TIME	 N		  5				Tempo				Tempo					99999
	MH1			 04			MH1_STATUS	 C		  1				Status				Status					@!
	MH1			 05			MH1_HORAI	 C		  5				Hora Inicial		Hora Inicial			99:99
	MH1			 06			MH1_HORAF	 C		  5				Hora Final			Hora Final				99:99
*/


//User function para testes dos jobs em debug.
/*
User Function TestLoadRet()
STFLoadRet( "T1", "D MG 01")
Return .T. 
*/
User Function TestLoadpdv()
STFLoadPdv("EMP_PDV", "FIL_PDV", "AMB_RET", "EMP_RET", "FIL_RET")
Return .T. 



//--------------------------------------------------------
/*/{Protheus.doc} STFLoadRet
Gera as cargas incrementais na retaguarda, automaticamente via Scheduler

[STFLoadRet]
Main=STFLoadRet
Environment=<Ambiente>                                                                                                                                                                                                                                                                                                                                                                                                                                                       
nParms=6
Parm1=<cEmp>
Parm2=<cFil>                 
Parm3=<cInterval>
Parm4=<cIpType>
Parm5=<cLoadDel>
Parm6=<cLoAutDel>
[OnStart]
Jobs=STFLoadRet
RefreshRate=30

@param 		
@author  	Varejo
@version 	P11.8
@since   	29/08/2013
@return	.T.
/*/
//--------------------------------------------------------

Function STFLoadRet(  cEmp		, cFil			, cInterval, cIpType	,;
						 cLoadDel 	, cLoAutDel	)

Local cIpExt	  := ""   //Endereco IP externo
Local cRetAmb	  := ""   //Ambiente retaguarda
Local cFileName   := ""   //Nome do arquivo de Semaforo
Local nSleep	  := 0    //Tempo de intervalo
Local nLoads	  := 0    //Contador de cargas
Local nSizeLoad   := 0	  //Retorna o numero de cargas geradas na tabela MBU
Local nI		  := 0	  //Contador	
Local aLoads	  := {}   //Array de cargas
Local aFiliais    := {}   //Filiais para processamento	
Local aTables    := {"MBU", "MD3", "MD4", "MH1"} //Tabelas de trabalho


Default cEmp 		:= "" 			//Empresa de trabalho
Default cFil 		:= "" 		 	//Filial de trabalho
Default cInterval	:= "3600000" 	//Tempo de intervalo. Padrao para gerar carga 1 hora = 3600000 Milisegundos
Default cIpType 	:= "2" 			//Tipo do endereco IP
Default cLoadDel 	:= "0"  		//Limite para iniciar o processo de exclusao das cargas processadas em todos os pdvs
Default cLoAutDel	:= "0"  		//Define quantas cargas ira excluir sem analisar os PDVs essa exlusão garante que a carga nao trava ao atingir limite do param MV_LJILQTD

/*
	Ex Job no appserver.ini no ambiente da Retaguarda

	[STFLoadRet]
	Main=STFLoadRet
	Environment=<Ambiente> - Ambiente Local Retaguarda
	nParms=6
	Parm1=<cRetEmp>	- Empresa da Retaguarda
	Parm2=<cRetFils>	- Filiais da Retaguarda podendo ser separados por ponto e virgula 
	Parm3=<3600000>	- Tempo para repetição da execução do Job LOJA1156 Job em milissegundos 
	Parm4=<cIpType>	- 1=Dinâmico (Ip Atualizado automaticamente); 2=Estático (O Ip permanece com a configuração Inicial)
	Parm5=<cLoadDel>	- Limite para exclusao apos baixas dos PDVs
	Parm6=<cDelAut>	- Define quantas cargas ira excluir sem analisar os PDVs essa exlusão garante que a carga nao trava ao atingir limite do param MV_LJILQTD	
	
	[ONSTART]
	JOBS=STFLoadRet
*/

LjGrvLog( "Carga","STFLoadRet Início ")
Conout("STFLoadRet Inicio ")
//Armazena tempo de intervalo
nSleep := Val(cInterval)

If nSleep	< 3600000
	Conout( "Atencao, Intervalo para geracao da carga(" + AllTrim(cInterval) + ") menor que o recomendado(3600000).")
	LjGrvLog( "Carga","Atenção, Intervalo para geração da carga(" + AllTrim(cInterval) + ") menor que o recomendado(3600000).")
EndIf

aFiliais := StrTokArr(AllTrim(cFil), ",")

If !Empty(cEmp) 
		
	For nI := 1 To Len(aFiliais)
		//Se o arquivo de semáforo existir, pode ser que o server tenha sido interrompido no meio e neste caso exlui o arquivo.
		If File("LJAUTOLOAD" + cEmp + aFiliais[nI] + ".txt")
			//Apaga arquivo de controle Semaforo
			FErase("LJAUTOLOAD" + cEmp + aFiliais[nI] + ".txt")	
		EndIf
	Next nI
	
	For nI := 1 To Len(aFiliais) 	           	
		//Nao consome licenca
		RPCSetType(3)	  	
		RpcSetEnv(cEmp, aFiliais[nI],,,"FRT",,aTables)	
		//Nome do arquivo de Semaforo
		cFileName := cEmp + aFiliais[nI]	
		
		//Semaforo do controle de execucao da filial
		If !File("LJAUTOLOAD" + cFileName + ".txt")		
			Conout("Job LOJA1156job Iniciado para a filial " + aFiliais[nI])
			LjGrvLog( "Carga","Job LOJA1156job Iniciado para a filial " + aFiliais[nI])
			
			//Cria o arquivo de Semaforo
			MSFCreate("LJAUTOLOAD" + cFileName + ".txt")
			
			//Define a quantidade de cargas geradas
			nSizeLoad 	:= LJ1156CountLoads()
			
			//Se o numero de cargas for superior ao desejado, aplica o processo para apagar os dados da MBU com base nos PDVs filhos
			If Val(cLoadDel) > 0 .And. nSizeLoad > Val(cLoadDel) 						
				If !STFLoadDel()
					Conout("JOB LOJA1156job: STFLoadDel(): Aguardando a liberacao do(s) PDV(s) para excluir o proximo lote na retaguarda. Sera feita uma nova tentativa para a filial " + aFiliais[nI])
					LjGrvLog( "Carga","JOB LOJA1156job: STFLoadDel(): Aguardando a liberacao do(s) PDV(s) para excluir o proximo lote na retaguarda. Sera feita uma nova tentativa para a filial " + aFiliais[nI])
				EndIf
			EndIf
			
			//Apaga as cargas independente de os PDVs terem baixado por ter atingido o limite do parametro MV_LJILQTD
			If Val(cLoAutDel) > 0 .AND. nSizeLoad >= SuperGetMV("MV_LJILQTD", .F., 200)					
				STFLoAutDel( Val(cLoAutDel ), nSizeLoad )
			EndIf
			
			//Armazena cargas
			aLoads	:= STFLoadItem()	
			
			//Efetua cargas
			For nLoads := 1 To Len(aLoads)
 
				//Verifica e atualiza IP dinamico
				If cIpType == "1"
					MD3->(dbSetOrder(1))
					cIpExt  := LjIpPrxy()	
					cRetAmb := Padr(SuperGetMv("MV_LJAMBIE", .F., ""), TamSx3("MD3_CODAMB")[1])													
					
					//Atualiza endereco IP na MD3
					If !Empty(cIpExt) .And. !Empty(cRetAmb) .And. MD3->(dbSeek(xFilial("MD3") + cRetAmb + "R"))
						MD3->(RecLock("MD3", .F.))
						MD3->MD3_IP := cIpExt
						MD3->(MsUnlock())
						
						//Atualiza parametro do Ip Assistente de Carga
						PutMv("MV_LJILLIP", cIpExt)
					EndIf
				EndIf
				
				//Executa a carga na Retaguarda
				If  LOJA1156Job(aLoads[nLoads][1])
					MH1->(DBGoTo(aLoads[nLoads][6]))
					
					MH1->(RecLock("MH1", .F.))
						MH1->MH1_DTULT 	:= Date()
						MH1->MH1_ULTIMA := Round(Seconds(), 0)
					MH1->(MsUnlock())
					
					Conout("Job LOJA1156Job executado para a carga " + aLoads[nLoads][1] + " Agendamento: " + aLoads[nLoads][2])
					LjGrvLog( "Carga","Job LOJA1156Job executado para a carga " + aLoads[nLoads][1] + " Agendamento: " + aLoads[nLoads][2])
				EndIf  

			Next nLoads
			
			//Apaga arquivo de controle Semaforo
			FErase("LJAUTOLOAD" + cFileName + ".txt")	
			
			Conout("Job LOJA1156job Executado para a filial " + aFiliais[nI])		
			LjGrvLog( "Carga","Job LOJA1156job Executado para a filial " + aFiliais[nI])
								
		EndIf
		RPCClearEnv()
	Next nI		
EndIf

Sleep(nSleep)
LjGrvLog( "Carga","STFLoadRet Fim ")

Return .T.

//--------------------------------------------------------
/*/{Protheus.doc} STFLoadPdv()
 Roda no Onstart dos PDVs e importa as cargas incrementais

[STFLoadPdv]
Main=STFLoadPdv
Environment=<Embiente>                                                                                                                                                                                                                                                                                                                                                                                                                                                       
nParms=2
Parm1=<cPdvEmp>
Parm2=<cPdvFil>  
Parm3=<cRetAmb>
Parm4=<cRetEmp>
Parm5=<cRetFil>
Parm6=<cInterval>
Parm7=<cIpType>

[OnStart]
Jobs=STFLoadPdv
RefreshRate=30

@param 		
@author  	Varejo
@version 	P11.8
@since   	29/08/2013
@return	.T.
/*/
//--------------------------------------------------------

Function STFLoadPdv(cPdvEmp, cPdvFil, cRetAmb, cRetEmp, cRetFil, cInterval, cIpType)

Local cIP					:= "" 			//Ip
Local cPorta				:= "" 			//Porta
Local cIpExt	  			:= ""  		//Endereco IP externo
Local cFilAmb 			:= ""  		//Ambiente filial
Local nSleep	   			:= 0   		//Tempo de intervalo 
Local lImport				:= .T. 		//Se efetuara a importacao da carga de dados
Local lDownload			:= .T. 		//Se efetuara o download da carga de dados
Local lActInChildren 	:= .F. 		//Se as acoes serao replicadas nos dependentes
Local lKillOtherThreads	:= .T. 		//Se derrubara os outros processos que estaoo em execucao caso nao consiga abrir as tabelas exclusivamente
Local lOnlyIfNewer		:= .T. 		//Somente atualiza se a carga disponivel no servidor for mais atual que a carga anteriormente baixada

Default cPdvEmp 	:= "" 			//Empresa do Pdv
Default cPdvFil 	:= "" 		 	//Filial do PDV
Default cRetAmb 	:= "" 			//Ambiente da Retaguarda
Default cRetEmp 	:= "" 			//Empresa da Retaguarda
Default cRetFil 	:= "" 		 	//Filial da Retaguarda
Default cInterval	:= "600000" 	//Tempo de intervalo. Padrao para buscar carga 10 minutos = 600000 Milisegundos
Default cIpType 	:= "2" 		//Tipo do endereco IP

LjGrvLog( "Carga","STFLoadPdv Início ")
Conout("STFLoadPdv Inicio ")
/*
	Ex Job no appserver.ini no ambiente do PDV
	
	[STFLoadPdv]
	Main=STFLoadPdv
	Environment=<Ambiente> - Ambiente Local PDV
	nParms=7
	Parm1=<cPdvEmp> - Empresa do Pdv
	Parm2=<cPdvFil> - Filial do Pdv
	Parm3=<cRetAmb> - Ambiente da Retaguarda  
	Parm4=<cRetEmp> - Empresa da Retaguarda
	Parm5=<cRetFil> - Filial da Retaguarda
	Parm6=<600000>  - Tempo para repetição da execução do Job LOJA1157Job em milissegundos 
	Parm7=<nIpType> - 1=Dinâmico (Ip Atualizado automaticamente); 2=Estático (O Ip permanece com a configuração Inicial)
	
	[ONSTART]
	JOBS=STFLoadPdv
*/

//Armazena tempo de intervalo
nSleep := Val(cInterval)

If nSleep	< 600000
	Conout( "Atencao, Intervalo para Importacao da carga(" + AllTrim(cInterval) + ") menor que o recomendado(600000).")
	LjGrvLog( "Carga","Atenção, Intervalo para Importação da carga(" + AllTrim(cInterval) + ") menor que o recomendado(600000).")
EndIf

If !Empty(cPdvEmp) .AND. !Empty(cPdvFil)                                                             
	RPCSetType(3)               
	RpcSetEnv(cPdvEmp,cPdvFil,Nil,Nil,"FRT")
	
	//Valida se existe alguma venda em andamento
	If !STBGetAct()		
		Conout("Job LOJA1157Job Iniciado")
		LjGrvLog( "Carga","Job LOJA1157Job Iniciado")

	
		//Verifica e atualiza IP dinamico
		If cIpType == "1"
			MD3->(dbSetOrder(1))
			cIpExt  := LjIpPrxy()	
			cFilAmb := Padr(SuperGetMv("MV_LJAMBIE", .F., ""), TamSx3("MD3_CODAMB")[1])													
			
			//Atualiza endereco IP na MD3
			If !Empty(cIpExt) .And. !Empty(cFilAmb) .And. MD3->(dbSeek(xFilial("MD3") + cFilAmb + "R"))
				MD3->(RecLock("MD3", .F.))
				MD3->MD3_IP := cIpExt
				MD3->(MsUnlock())
				
				//Atualiza parametro do Ip Assistente de Carga
				PutMv("MV_LJILLIP", cIpExt)
			EndIf
		EndIf
				
		cIP 	:= SuperGetMV("MV_LJILLIP", .F., "") 	//Ip
		cPorta	:= SuperGetMV("MV_LJILLPO", .F., "") 	//Porta
		
		//Executa a carga no PDV
		LOJA1157Job(cIP, Val(cPorta), cRetAmb , cRetEmp, cRetFil, lImport, lDownload,; 
						lActInChildren, lKillOtherThreads, lOnlyIfNewer)
				
		Conout("Job LOJA1157Job Executado") 
		LjGrvLog( "Carga","Job LOJA1157Job Executado")
	EndIf
	
	RPCClearEnv()
EndIf

Sleep(nSleep)
LjGrvLog( "Carga","STFLoadPdv Fim ")

Return .T.

//--------------------------------------------------------
/*/{Protheus.doc} STFLoadDel
Exclui as cargas na Retaguarda de acordo com cada PDV ou lista de cargas recebidas
@param 		aMbyGeral , array , Cargas a apagar
@author  	Varejo
@version 	P11.8
@since   	10/03/2015
@return	lRet - Retorna se excluiu as cargas
/*/
//--------------------------------------------------------

Static Function STFLoadDel(aMbyGeral)

Local aAreaMD4	:= MD4->(GetArea())	//Guarda area
Local aAreaMD3	:= MD3->(GetArea())	//Guarda area
Local cPath 		:= GetPvProfString("LJFileServer", "Path", "\LJFileServer\", GetAdv97()) //Caminho da carga
Local nCount		:= 0					//Contador       
Local nCountPdv	:= 0					//Variavel que controla o numero de PDVs lidos
Local nLoads		:= 0					//Numero de carga
Local nPosPdv		:= 0					//Pesquisa carga no novo PDV pesquisado
Local nI			:= 0					//Contador
Local aMBYPdv		:= {}					//Retorno da consulta no Pdv com base na Tabela MBY
Local aAuxMby		:= {}					//Auxiliar do controle de cargas dos Pdvs
Local aPdvs		:= {}					//Armazena todos os PDVs cadastrados na Retaguarda
Local aDirectory 	:= {}					//Array de diretorios
Local lRet			:= .T.					//Retorno
Local oServer		:= Nil					//Objeto de conexao com o server
Local bOldError	:= {||} 				//Variavel de backup de erro de execucao para proteger a comunicacao RPC caso algum PDV caia durante a consulta.

Default aMbyGeral	:= {}					//Array com cargas a deletar

LjGrvLog( "Carga","STFLoadDel Início ")

If Len(aMbyGeral) == 0

	MD4->(dbSetOrder(1))
	//Posiciona no primeiro registro com Filial + Codigo
	If MD4->(dbSeek(xFilial("MD4"))) 
		While MD4->(!Eof())  .AND. ( MD4->MD4_FILIAL == xFilial("MD4") )
			//Processa somente ambiente PDV
			If !Empty(MD4->MD4_AMBPAI) 
				Aadd(aPdvs, MD4->MD4_CODIGO)
			EndIf
			
			MD4->(DbSkip())
		EndDo
	EndIf
	
	//Busca os dados de cada PDV para realizar a pesquisa das cargas processadas
	MD3->(dbSetOrder(1))
	
	If Len(aPdvs) > 0
		For nCount := 1 To Len(aPdvs) //Realiza a leitura de todos os PDVs encontrados
			If MD3->(dbSeek(xFilial("MD3") + aPdvs[nCount] + "R"))
				//Cria objeto da conexao RPC
				oServer := TRPC():New(AllTrim(MD3->MD3_NOMAMB))          
				
				If oServer:Connect(AllTrim(MD3->MD3_IP), Val(MD3->MD3_PORTA))
					bOldError := ErrorBlock({|x| STFLoadError(x)}) //Muda code-block de erro
					//Este tratamento protege o JOB caso a comunicacao caia durante este processo de consulta. Do contrario o JOB ficaria inativo 
					
					Begin Sequence														
						oServer:CallProc("RPCSetType", 3) //Tipo de Licenca consumida 
						oServer:CallProc("RPCSetEnv", MD3->MD3_EMP, MD3->MD3_FIL, Nil, Nil, "FRT", "", {"MBY"}) //Abre conexao com outra empresa
						
						//Retorna as Cargas Liberadas neste PDV
						aMBYPdv := oServer:CallProc("STFLoadGetPdv") 
	
						oServer:CallProc("RpcClearEnv") //Limpa Thread
						oServer:Disconnect() //Encerra conexao
						nCountPdv++								
					Recover
						Conout("JOB LOJA1156Job: Ocorreu um erro inesperado durante a consulta com o PDV " + MD3->MD3_NOMAMB + ". Pode estar off-line")
						LjGrvLog( "Carga","JOB LOJA1156Job: Ocorreu um erro inesperado durante a consulta com o PDV " + MD3->MD3_NOMAMB + ". Pode estar off-line")
						
						Conout("JOB LOJA1156Job: Detalhes do ambiente PDV : MD3_IP " + AllTrim(MD3->MD3_IP) + " | MD3_PORTA : " + MD3->MD3_PORTA)
						LjGrvLog( "Carga","JOB LOJA1156Job: Detalhes do ambiente PDV : MD3_IP " + AllTrim(MD3->MD3_IP) + " | MD3_PORTA : " + MD3->MD3_PORTA)
						
						//Como ocorreu um erro dentro da conexao, nada sera feito pois nao tem como garantir os dados ate nova tentativa
						aMbyGeral := {}	
					End Sequence
													
					ErrorBlock(bOldError) //Restaura rotina de erro anterior
				Else
					Conout("JOB LOJA1156Job: Nao foi possivel estabelecer uma conexao com o PDV " + MD3->MD3_NOMAMB + "," + "nenhuma carga foi apagada!")
					LjGrvLog( "Carga","JOB LOJA1156Job: Nao foi possivel estabelecer uma conexao com o PDV " + MD3->MD3_NOMAMB + "," + "nenhuma carga foi apagada!")
					
					Conout("JOB LOJA1156Job: Detalhes do ambiente PDV : MD3_IP " + AllTrim(MD3->MD3_IP) + " | MD3_PORTA : " + MD3->MD3_PORTA)
					LjGrvLog( "Carga","JOB LOJA1156Job: Detalhes do ambiente PDV : MD3_IP " + AllTrim(MD3->MD3_IP) + " | MD3_PORTA : " + MD3->MD3_PORTA)
					
					aMbyGeral := {} //Se algum Pdv nao conectar, aborta o processamento e nao apaga nenhuma carga
					Exit
				EndIf
				
				//Se existe carga liberada no PDV
				If Valtype(aMBYPdv) == "A" .AND. Len(aMBYPdv) > 0 
					If nCountPdv > 1 //Leitura do segundo PDV em diante
						aAuxMby := {}
						
						For nLoads := 1 To Len(aMBYPdv) 
							nPosPdv := Ascan(aMbyGeral, {|x| x == aMBYPdv[nLoads]}) //Pesquisa se existe a carga do novo PDV no anterior pesquisado
							
							If nPosPdv > 0
								Aadd(aAuxMby,aMBYPdv[nLoads]) //Inclui apenas os registros encontrados nos 2 ambientes
							EndIf
						Next nLoads
						
						aMbyGeral := aClone(aAuxMby) //Vetor aMbyGeral consolida as validacoes a cada leitura de um novo PDV
					Else
						aMbyGeral := aClone(aMBYPdv) //Faz uma copia da primeiro PDV para usar como base para os proximos
					Endif
				EndIf
			EndIf
		Next nCount
	EndIf

EndIf	

//Apos analise em cada Pdv apenas as cargas encontradas em TODOS os ambientes poderao ser excluidas
//Ou caso tenha recebido a lista de cargas, deleta diretamente mesmo sem analisar os PDVs
If Len(aMbyGeral) > 0 	
	
	LjGrvLog( "Carga","Deleta cargas")

	MBU->(dbSetOrder(1)) //MBU_FILIAL+MBU_CODIGO
	MBV->(dbSetOrder(1)) //MBV_FILIAL+MBV_CODGRP+MBV_TABELA 
	MBW->(dbSetOrder(1)) //MBW_FILIAL+MBW_CODGRP+MBW_TABELA 
	MBX->(dbSetOrder(1)) //MBX_FILIAL+MBX_CODGRP+MBX_TABELA+MBX_FIL
	
	For nCount := 1 To Len(aMbyGeral)
		//Se achar a carga na Retaguarda apaga o registro
		If MBU->(dbSeek(xFilial("MBU")+ aMbyGeral[nCount])) 
			//Limpa MBU	
			If RecLock("MBU", .F.)															
				MBU->(dbDelete())
				MBU->(MsUnLock())
				//Exclui os registros fisicamente da tabela MBU//LjPackTb("MBU")
				//Limpa MBV							
				If MBV->(dbSeek(xFilial("MBV")+ aMbyGeral[nCount])) 
					While MBV->(!EOF()) .And. MBV->(MBV_FILIAL + MBV_CODGRP) == xFilial("MBV") + aMbyGeral[nCount]
						RecLock("MBV", .F.)
							MBV->(dbDelete())
						MBV->(MsUnLock())
												
						MBV->(dbSkip())
					EndDo
					//Exclui os registros fisicamente da tabela MBV//LjPackTb("MBV")				
				EndIf
												
				//Limpa MBW
				If MBW->(dbSeek(xFilial("MBW")+ aMbyGeral[nCount])) 
					While MBW->(!EOF()) .And. MBW->(MBW_FILIAL + MBW_CODGRP) == xFilial("MBW") + aMbyGeral[nCount]
						RecLock("MBW", .F.)
							MBW->(dbDelete())
						MBW->(MsUnLock())
												
						MBW->(dbSkip())
					EndDo
					
					//Exclui os registros fisicamente da tabela MBW//LjPackTb("MBW")
				EndIf								
				
				//Limpa MBX
				If MBX->(dbSeek(xFilial("MBX")+ aMbyGeral[nCount])) 
					While MBX->(!EOF()) .And. MBX->(MBX_FILIAL + MBX_CODGRP) == xFilial("MBX") + aMbyGeral[nCount]
						RecLock("MBX", .F.)
							MBX->(dbDelete())
						MBX->(MsUnLock())
												
						MBX->(dbSkip())
					EndDo
					
					//Exclui os registros fisicamente da tabela MBX//LjPackTb("MBX")
				EndIf
							
				
				//Limpa MH1 
				If MH1->( DbSeek(xFilial("MH1")+ aMbyGeral[nCount])) 

					RecLock("MH1", .F.)
					MH1->( dbDelete() )
					MH1->( MsUnLock() )
					// Exclui os registros fisicamente da tabela MH1 -- Agendamento de Cargas

				EndIf
				
				
				Conout("JOB LOJA1156Job: Carga " + aMbyGeral[nCount] + " apagado com sucesso")
				LjGrvLog( "Carga","JOB LOJA1156Job: Carga " + aMbyGeral[nCount] + " apagado com sucesso")
							
				//Limpa os arquivos físicos do servidor				
				aDirectory := Directory(cPath + aMbyGeral[nCount] + "\" +  "*.*", "D" ) //Leitura de todos os niveis da pasta da carga
				
				For nI := 1 To Len(aDirectory)
					//Se for um arquivo
					If  aDirectory[nI][5] == "A" 
						Conout("JOB LOJA1156Job: Apagando arquivo " + cPath + aMbyGeral[nCount] + "\" + aDirectory[nI][1])
						LjGrvLog( "Carga","JOB LOJA1156Job: Apagando arquivo " + cPath + aMbyGeral[nCount] + "\" + aDirectory[nI][1])
						FErase( cPath + aMbyGeral[nCount] + "\" + aDirectory[nI][1] )
					ElseIf	aDirectory[nI][5] == "D" //Se for um diretorio auxiliar usado pelo Ctree
						Conout("JOB LOJA1156Job: Apagando Diretorio " + cPath + aMbyGeral[nCount] + "\" + aDirectory[nI][1])
						LjGrvLog( "Carga","JOB LOJA1156Job: Apagando Diretorio " + cPath + aMbyGeral[nCount] + "\" + aDirectory[nI][1])
						DirRemove(cPath + aMbyGeral[nCount] + "\" + aDirectory[nI][1]) //Apaga diretorio especifico do ambiente Ctree
					EndIf
				Next nI			
				
				DirRemove(cPath + aMbyGeral[nCount]) //Apaga a pasta principal com o numero da carga		 				
			Else
				Conout("JOB LOJA1156Job: Nao foi possivel obter acesso exclusivo da carga " +  aMbyGeral[nCount] + ". Este registro sera apagado posteriormente" )
				LjGrvLog( "Carga","JOB LOJA1156Job: Nao foi possivel obter acesso exclusivo da carga " +  aMbyGeral[nCount] + ". Este registro sera apagado posteriormente")
			EndIf
		EndIf
	Next nCount
Else
	lRet := .F.
Endif

RestArea(aAreaMD4)
RestArea(aAreaMD3)

LjGrvLog( "Carga","STFLoadDel Fim Retorno: " ,lRet )

Return lRet


//--------------------------------------------------------
/*/{Protheus.doc} STFLoAutDel
Exclui as cargas na Retaguarda sem analisar se os PDVs baixaram.
Para evitar atingir o numero maximo de cargas permitidos(MV_LJILQTD) e travar as cargas automaticas.
Apaga somente cargas incrementais
@type function
@author  	rafael.pessoa
@since   	14/09/2016
@version 	P12
@param 		nQtdeDel  , numérico, Quantidade de cargas para apagar
@param 		nSizeLoad , numérico, Quantidade de cargas ativas
@return	lRet - Retorna se excluiu as cargas
/*/
//--------------------------------------------------------
Static Function STFLoAutDel( nQtdeDel , nSizeLoad )

Local aArea		:= GetArea()	// Guarda area
Local aDelLoad 	:= {} 			// Array de cargas a apagar
Local lRet       	:= .T.			// Retorno

Default nQtdeDel  := 0  
Default nSizeLoad := 0

LjGrvLog( "Carga","STFLoAutDel Início" )

If (nQtdeDel > 0 .AND. nSizeLoad > 0 ) 

	DbSelectArea("MBU")
	MBU->(dbSetOrder(2)) //MBU_FILIAL+MBU_TIPO
	If MBU->(dbSeek(xFilial("MBU")+ "2" ))
		While MBU->(!EOF()) .AND. (MBU->MBU_FILIAL + MBU->MBU_TIPO == xFilial("MBU") + "2") .AND. (Len(aDelLoad) < nQtdeDel)
			If AllTrim(MBU->MBU_INTINC) == "2"
				Aadd(aDelLoad, MBU->MBU_CODIGO ) 
			EndIf	
			MBU->(dbSkip())
		EndDo	
	EndIf

EndIf 

If Len(aDelLoad) > 0
	LjGrvLog( "Carga","Cargas a deletar " ,aDelLoad )
	STFLoadDel(aDelLoad)
EndIf 

RestArea(aArea)

LjGrvLog( "Carga","STFLoAutDel Fim Retorno: " ,lRet )

Return lRet


//--------------------------------------------------------
/*/{Protheus.doc} STFLoadError
Trata erro na consulta Rpc para nao cair o JOB
@param 		
@author  	Varejo
@version 	P11.8
@since   	10/03/2015
@return	Nil
/*/
//--------------------------------------------------------

Static Function STFLoadError(e)

Local lRet := .F. //Retorno da funcao 

//Verifica se encontrou erros
If e:gencode > 0  
	Conout("Ocorreu o erro: " + e:DESCRIPTION) 
	LjGrvLog( "Carga","Ocorreu o erro: " + e:DESCRIPTION )
	
	Conout("Pilha de chamada: " + e:ERRORSTACK)
	LjGrvLog( "Carga","Pilha de chamada: " + e:ERRORSTACK ) 
    
    lRet := .T.
    Break
EndIf  

Return(lRet)

//--------------------------------------------------------
/*/{Protheus.doc} STFLoadGetPdv
Retorna as cargas atualizadas no PDV
@param 		
@author  	Varejo
@version 	P11.8
@since   	10/03/2015
@return	aRet - Retorna as cargas atualizadas no PDV
/*/
//--------------------------------------------------------

Function STFLoadGetPdv()

Local aArea := GetArea()	//Guarda area
Local aRet  := {}			//Array de retorno

MBY->(DbSetOrder(1)) //MBY_FILIAL + MBY_CODGRP
 
//Posiciona no primeiro registro 
If MBY->(dbSeek(xFilial("MBY"))) 
	While MBY->(!Eof())
		//Processa apenas cargas recebidas e atualizadas no PDV
		If MBY->MBY_STATUS == "2"
			Aadd(aRet, MBY->MBY_CODGRP)
		EndIf
		
		MBY->(dbSkip())
	EndDo
Endif

RestArea(aArea)

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc} STFLoadItem
Retorna o Vetor com a informações  da carga e seu tempo 
@param 		
@author  	Varejo
@version 	P11.8
@since   	13/02/2015
@return	aRet - Array de cargas e tempo de execucao
/*/
//--------------------------------------------------------

Static Function STFLoadItem()

Local aRet			:= {}				 					//Array de retorno
Local aMBU 			:= MBU->( GetArea() )					//Guarda Area MBU 
Local lDelLoadAut 	:= .F.									//Controla se deleta a carga automatica
Local oAgenda		:= LjAgendaDeCargas():New(,,,,,.F.)		// -- Cria objeto Agenda de cargas
Local cDiaSemana 	:= STFDayWeek()							// -- Retorna o dia da semana em minusculo e apenas as 3 primeiras letras

MBU->(dbSetOrder(1)) //MBU_FILIAL+MBU_CODIGO	
MH1->(dbSetOrder(2)) // -- MH1_FILIAL+MH1_COD

//Busca cargas agendadas
If MH1->(dbSeek(xFilial("MH1")))
	While !MH1->(EOF())
				
		If MBU->( DbSeek( xFilial("MBU") + MH1->MH1_COD ) )				
			//Se achar a carga verifica se eh tipo template e incremental
			If !( AllTrim(MBU->MBU_TIPO) = "1" )//.AND. AllTrim(MBU->MBU_INTINC) = "2") 
				lDelLoadAut := .T.
			EndIf
		Else
			//Se nâo Achar a Carga deleta Geracao automatica(MH1)
			lDelLoadAut := .T.
		EndIf
		
		If lDelLoadAut

			RecLock("MH1", .F. )
			MH1->( DbDelete() )
			MH1->( MsUnLock() )
				
			lDelLoadAut := .F.
			MH1->( DbSkip() )
			Loop
		EndIf
		
		If MH1->MH1_STATUS == "A"
			aAgenda := oAgenda:preparaLeituraDaAgenda(MH1->MH1_AGENDA)
			nPos := AScan(aAgenda,{|x| x[1] == cDiaSemana})
			
			If nPos > 0 .AND. (TIME() >= aAgenda[nPos][2][1] .and. TIME() <= aAgenda[nPos][2][2]) .AND. ((Round(Seconds(), 0) - MH1->MH1_ULTIMA ) > MH1->MH1_TIME .Or. MH1->MH1_DTULT <> Date())
				Aadd(aRet,{MH1->MH1_COD,MH1->MH1_CODAGE, MH1->MH1_TIME,MH1->MH1_ULTIMA,aAgenda,MH1->(Recno())})
			EndIf 

		Endif
		
		MH1->(DbSkip())
	EndDo
EndIf

RestArea(aMBU)	

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc} STFDayWeek
Retorna o dia em formato de 3 letras em minusculo
		
@author  	Varejo
@version 	P11.8
@since   	10/03/2015
@param		Date ,dData, data que deseja saber o dia da semana no formato proposto
@return	Nil
/*/
//--------------------------------------------------------

Static Function STFDayWeek(dData)
Local cIniDia := ""
Default dData := Date()

Do case 
Case DOW(dData) == 1
	cIniDia := "dom"
Case DOW(dData) == 2 
	cIniDia := "seg" 
Case DOW(dData) == 3 
	cIniDia := "ter" 
Case DOW(dData) == 4
	cIniDia := "qua" 
Case DOW(dData) == 5 
	cIniDia := "qui" 
Case DOW(dData) == 6 
	cIniDia := "sex" 
Case DOW(dData) == 7
	cIniDia := "sab"
Endcase

Return cIniDia
