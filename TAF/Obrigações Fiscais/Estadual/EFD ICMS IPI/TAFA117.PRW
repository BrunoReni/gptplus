#Include "Protheus.ch"
#Include "TbiConn.ch"
#Include "ApWizard.ch"
#Include "SpedPisCof.ch"

#Define _Enter Chr(13) + Chr(10)
#Define cTabSped "TAFSPED" + "_" + cEmpAnt //Tabela de informacoes geradas pelos SPED´s
#Define cTabCtl  "TAFGERCTL"				 //Tabela de controle de transacoes ( Todas Obrigações )
#Define cObrig   "SPEDFIS"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFA117
Esta Rotina tem como objetivo a Emissao do Arquivo Magnetico do Sped Fiscal

@Author Rodrigo Aguilar
@Since  28/12/2012
@Version 1.0

Alterações Realizadas:

Altered By: Rodrigo Aguilar ( 25/11/2014 )
- Implementação da geração do Sped Fiscal em Multi Thread

- Geração do bloco 0 passa a ser realizada durante o processamento dos demais blocos
e não de forma separada.

- O Bloco 9 e os registros de encerramento de cada bloco também deixam de ser
gerados de forma separada e passam a ser gerados após o final do processamento
de todos os blocos.

- Foram criadas as tabelas de controle de geração com o conceito de farois, ou seja,
caso o usuário deseje reprocessar o mesmo período pode optar por apenas gerar o arquivo
magnético sem refazer todo o processamento, ou até mesmo selecionar apenas alguns blocos
para serem refeitos.

@Return ( Nil )
/*/
//--------------------------------------------------------------------------------------------------
Function TAFA117()
	Local lEnd				:=	.F.
	Local cSpedAlias		:=	""
	Local cCtlAlias		:=	""
	Local aTopInfo		:=	FwGetTopInfo()
	Local cDriver			:=	__CRDD
	Local cTopBuild		:=	Iif( FindFunction( "TCGetBuild" ), TCGetBuild(), "" )
	Local aEstruSped		:=	xTAFGetStru( "TAFSPED" )
	Local aEstruCtl		:=	xTAFGetStru( "TAFGERCTL" )
	Local aErros			:= {}
	Local oProcess		:=	Nil
	Local cFunction 	:= ProcName()
	Local nOpc      	:= 2 //View

	Local cCode		:= "LS006"
	Local cUser		:= RetCodUsr()
	Local cModule	:= "84"
	Local cRoutine  := ProcName()

	//Função para gravar o uso de rotinas e enviar ao LS (License Server)
	Iif(FindFunction('FWLsPutAsyncInfo'),FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine),)

	/*-------------------------------------------------------------------------------------------
	Prepara informacoes das tabelas de controle
	-------------------------------------------------------------------------------------------*/
	cSpedAlias := GetNextAlias()
	cCtlAlias  := GetNextAlias()

	/*-------------------------------------------------------------------------------------------
	Realiza a criacao das duas tabelas de controle de geração do Sped Fiscal ( Caso não exista )
	-------------------------------------------------------------------------------------------*/
	If xTAFCriaTB( , aTopInfo, cTabSped, cSpedAlias, cDriver, aEstruSped[1], aEstruSped[2], cTopBuild,,,,@aErros ) .And. ;
			xTAFCriaTB( , aTopInfo, cTabCtl, cCtlAlias, cDriver, aEstruCtl[1], aEstruCtl[2], cTopBuild,,,,@aErros )
		If !Empty( aErros )
			Aviso( "Erro Encontrado", aErros[1,6], { "OK" }, 3 ) //##"Erro Encontrado" ##"Ok"
		Else
			//Protect Data / Log de acesso / Central de Obrigacoes
			Iif(FindFunction('FwPDLogUser'),FwPDLogUser(cFunction, nOpc), )

			oProcess := TAFProgress():New( { |lEnd| A117ProcSp( @lEnd, @oProcess, cCTLAlias, cSpedAlias ) }, "Processando Sped Fiscal" )
			oProcess:Activate()
		EndIf

	/*-------------------------------------------------------------------------------------------
	Tratameto para quando ocorre erro de conexão/criação das tabelas temporarias
	-------------------------------------------------------------------------------------------*/
	Else
		If !Empty( aErros )
			Aviso( "Erro Encontrado", aErros[1,6], { "OK" }, 3 ) //##"Erro Encontrado" ##"Ok"
		Else
			xTAFMsgJob( "Problema ao criar tabelas de controle do TAF." )
		EndIf
	EndIf

	/*-------------------------------------------------------------------------------------------
	Fechando os alias utilizados durante o processamento
	-------------------------------------------------------------------------------------------*/
	If Select(cSpedAlias)  > 0
		( cSpedAlias )->( DBCloseArea() )
	EndIf

	If Select(cCtlAlias)  > 0
		( cCtlAlias )->( DBCloseArea() )
	EndIf

	/*-------------------------------------------------------------------------------------------
	Zerando os arrays utilizados durante o processamento
	-------------------------------------------------------------------------------------------*/
	aSize( aEstruSped	, 0 )
	aSize( aEstruCtl	, 0 )

	/*-------------------------------------------------------------------------------------------
	Zerando as Variaveis utilizadas
	-------------------------------------------------------------------------------------------*/
	aEstruSped := Nil
	aEstruCtl  := Nil

	/*-------------------------------------------------------------------------------------------
	Limpando a memoria
	-------------------------------------------------------------------------------------------*/
	DelClassIntf()
Return( .T. )


//-------------------------------------------------------------------
/*/{Protheus.doc} A117ProcSp
Inicia o Processamento para Emissao do Sped Fiscal

@author Rodrigo Aguilar
@since  28/12/2012
@version 1.0

Altered By: Rodrigo Aguilar
Date:25/11/2014
Incluída geração do Sped Fiscal em Mult Thread

@Param	lEnd        -> Verifica se a Operacao Foi Abortada Pelo Usuario
		oProcess   -> Objeto Para criacao da Barra de Andamento da Emissao do Sped Fiscal
		cCTLAlias  -> Alias da tabela de Controle
		cSpedAlias -> Alias da tabela onde as informações estão sendo geradas

@Return ( Nil )
/*/
//-------------------------------------------------------------------
Static Function A117ProcSp( lEnd, oProcess, cCTLAlias, cSpedAlias )
	Local cDir		   		:= ""
	Local cFileDest  		:= ""
	Local cFilSel    		:= ""
	Local cSemaphore 		:= ""
	Local nFil       		:= 0
	Local nlI        		:= 0
	Local nProgress1 		:= 0
	Local nQtdThread 		:= 0
	Local lMultThread 	:= .F.
	Local aWizard	   		:= {}
	Local aLisFil	   		:= {}
	Local aBlocosSpd 		:= {}
	Local cNomeCfp  		:= ( "SPDFISCAL" + FWGETCODFILIAL )
	Local cStartPath 		:=	AllTrim( GetSrvProfString( "StartPath" , "" ) )
	Local lProcArq 		:= .T.

	/*-------------------------------------------------------------------------------------------
	Função genérica para realizar a preperação do ambiente e iniciar as Threads no caso de Mult
	Processsamento
	-------------------------------------------------------------------------------------------*/
	xParObrMT( cObrig, @cSemaphore, @lMultThread, @nQtdThread )

	/*-------------------------------------------------------------------------------------------
	Nao sendo Job posso chamar a Funcao de Criar/Carregar a Wizard
	-------------------------------------------------------------------------------------------*/
	If !XFUNLoadProf( cNomeCfp , @aWizard )
		Return ( Nil )
	EndIf

	/*-------------------------------------------------------------------------------------------
	Carrego as Variaveis com as Informacoes passadas na Wizard
	-------------------------------------------------------------------------------------------*/
	cDir := AllTrim( aWizard[1][3] )

	/*-------------------------------------------------------------------------------------------
	Confirmando com o usuario se ele quer que o Sped Fiscal seja gerado atraves de MultiThreads
	-------------------------------------------------------------------------------------------*/
	If lMultThread .And. ( nQtdThread > 0 )
		Conout("*** Iniciando a Execução do Sped Fiscal em Multi Thread ***" )
		lProcArq := MsgYesNo( "Esse processamento será realizado utilizando " + StrZero( nQtdThread, 2 ) + " threads." + _Enter + _Enter  + "Deseja confirmar ?" + _Enter )
	EndIf

	/*-------------------------------------------------------------------------------------------
	Caso Nao tenha sido cancelado ate o momento realizo a geração do bloco
	-------------------------------------------------------------------------------------------*/
	If lProcArq

		/*-------------------------------------------------------------------------------------------
		Tratamento para Linux onde a barra eh invertida
		-------------------------------------------------------------------------------------------*/
		If GetRemoteType() == 2
			If !Empty(cDir) .And. (SubStr (cDir, Len (cDir), 1)<>"/")
				cDir	+=	"/"
			EndIf
		Else
			If !Empty(cDir) .And. (SubStr (cDir, Len (cDir), 1)<>"\")
				cDir	+=	"\"
			EndIf
		EndIf

		/*-------------------------------------------------------------------------------------------
		Monto nome do Arquivo que sera gerado
		-------------------------------------------------------------------------------------------*/
		cFileDest	:=	AllTrim(cDir) + AllTrim( aWizard[1][4] )

		/*-------------------------------------------------------------------------------------------
		Verifico se o usuario escolheu a opcao de seleciona filiais na Wizard, neste caso eu
		armazendo as filiais escolhidas na variavel cFilSel
		-------------------------------------------------------------------------------------------*/
		If "1" $ aWizard[1][6]

			/*-------------------------------------------------------------------------------------------
			Realizo a Verificacao das Filiais Selecionadas
			-------------------------------------------------------------------------------------------*/
			aLisFil  :=	xFunTelaFil(.T.,,,.T.)

			/*-------------------------------------------------------------------------------------------
			Tratamento para caso o usuário cancele a tela de seleção de filiais
			-------------------------------------------------------------------------------------------*/
			If Empty( aLisFil )
				lProcArq := .F.
			Else
				If Len( aLisFil ) > 0
					For nFil := 1 To Len( aLisFil )
						If ( aLisFil[nFil,1] )
							cFilSel += "'" + Alltrim( aLisFil[nFil,2] ) + "',"
						EndIf
					Next

					If Right( cFilSel, 1 ) == ","
						cFilSel := Substr( cFilSel, 1, Len( cFilSel) - 1 )
					EndIf
				EndIf
			EndIf
		Else
			cFilSel := "'" + Alltrim( cFilAnt ) + "' "
		EndIf

		/*-------------------------------------------------------------------------------------------
		Verifica antes de iniciar o processamento se o diretorio selecionado existe.
		-------------------------------------------------------------------------------------------*/
		If !ExistDir(cDir)
			Aviso( "Não é possível gerar o arquivo" , "Não existe o diretório informado: " + Alltrim(cDir) + CRLF + "Selecione um diretório válido.",{"Fechar"},2)
			lProcArq := .F.
		EndIf
	EndIf

	/*-------------------------------------------------------------------------------------------
	Caso Nao tenha sido cancelado ate o momento realizo a geração do bloco
	-------------------------------------------------------------------------------------------*/
	If lProcArq

		/*-------------------------------------------------------------------------------------------
		Alimentando o Array com os blocos que devem ser processados
		-------------------------------------------------------------------------------------------*/
		aBlocosSpd := xTafGetObr( cObrig, aWizard )

		/*-------------------------------------------------------------------------------------------
		Seleção dos blocos que serão processados no Sped
		-------------------------------------------------------------------------------------------*/
		lProcArq := SelBlcObrg( cObrig, cCTLAlias, aWizard, cFilSel, @aBlocosSpd )

		If lProcArq

			/*-------------------------------------------------------------------------------------------
			Alimentado a variavel de controle da barra de Status do processamento
			-------------------------------------------------------------------------------------------*/
			For nlI := 1 to Len( aBlocosSpd )
				If aBlocosSpd[nlI,1]
					nProgress1 ++
				EndIf
			Next nlI

			A117SpdFis( cFilSel, lMultThread, aWizard, cFileDest, aBlocosSpd, nProgress1, cCTLAlias, cSpedAlias, cSemaphore, nQtdThread, oProcess )

		/*-------------------------------------------------------------------------------------------
		Processamento Cancelado
		-------------------------------------------------------------------------------------------*/
		Else
			oProcess:Inc1Progress( "Processamento cancelado." )
			oProcess:Inc2Progress( "Clique em Finalizar." )
		EndIf

	/*-------------------------------------------------------------------------------------------
	Processamento Cancelado
	-------------------------------------------------------------------------------------------*/
	Else
		oProcess:Inc1Progress( "Processamento cancelado." )
		oProcess:Inc2Progress( "Clique em Finalizar." )
	EndIf

	/*-------------------------------------------------------------------------------------------
	Zerando os arrays utilizados durante o processamento
	-------------------------------------------------------------------------------------------*/
	aSize( aWizard, 0 )
	aSize( aLisFil, 0 )
	aSize( aBlocosSpd, 0 )

	/*-------------------------------------------------------------------------------------------
	Zerando as Variaveis utilizadas
	-------------------------------------------------------------------------------------------*/
	aWizard    := Nil
	aLisFil    := Nil
	aBlocosSpd := Nil
Return ( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} A117SpdFis

Realiza a Chamada das Funoes de Geracao dos Registros do Sped Fiscal

@Param		cFilSel      -> Filiais Escolhidas pelo Usuario para processamento
            lMultThread  -> Indica se o Processamento sera feito com MultiThread
            aWizard      -> Wizard de Geracao do Sped
            cFileDest    -> Caminho para a Gravacao do TXT
            aBlocosSpd   -> Blocos do Sped que serão gerados
            nProgress1   -> Quantidade de Blocos que serão gerados
			cCTLAlias    -> Alias da tabela de Controle
			cSpedAlias   -> Alias da tabela onde as informações estão sendo geradas
			cSemaphore   -> Semaforo do processamento em MultThread
			nQtdThread   -> Quantidade de Threads utilizadas
			oProcess     -> Objeto Para criacao da Barra de Andamento da Emissao do Sped Fiscal

@Return ( Nil )

@author Rodrigo Aguilar
@since  02/01/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function A117SpdFis( cFilSel, lMultThread, aWizard, cFileDest, aBlocosSpd, nProgress1, cCTLAlias, cSpedAlias, cSemaphore, nQtdThread, oProcess )
	Local cFunction  	:= ""
	Local cJobAux    	:= ""
	Local cErrorSpd  	:= ""
	Local cErrorTrd  	:= ""
	Local cTxtUsu	  	:= cFileDest
	Local cFilBkp   	:= cFilAnt
	Local nI       	:= 0
	Local nTryExec 	:= 0
	Local cTxtSys 	:= CriaTrab(,.F.) + ".TXT"
	Local nHdlTxt		:=	MsFCreate( cTxtSys )
	Local lConv115 	:= ( SubStr( aWizard[2][7], 1, 1 ) == "0" )
	Local aJobAux 	:= {}

	/*-------------------------------------------------------------------------------------------
	Variavel contendo o perfil selecionado pelo usuario na Wizard
	-------------------------------------------------------------------------------------------*/
	Local cPerfilSPD := AllTrim(SubStr( aWizard[2][2], 1, 1 ))

	/*-------------------------------------------------------------------------------------------
	Tratamento para quando a extensao nao é informada na Wizard
	-------------------------------------------------------------------------------------------*/
	If Upper( Right( Alltrim(cTxtUsu), 4 ) ) <> ".TXT"
		cTxtUsu := ( cTxtUsu + ".TXT" )
	EndIf

	oProcess:Set1Progress( nProgress1 + 2 )
	oProcess:Set2Progress( nProgress1 + 2 )

	/*-------------------------------------------------------------------------------------------
	Iniciando o Processamento
	-------------------------------------------------------------------------------------------*/
	oProcess:Inc1Progress( "Gerando Sped Fiscal..." )
	oProcess:Inc2Progress( "Preparando o Ambiente..." )

	Conout( "Tempo de Inicio " + Time() )

	/*-------------------------------------------------------------------------------------------
	Este for realiza a verificação de todos os blocos do Sped que o usuário selecionou
	para o processamento
	-------------------------------------------------------------------------------------------*/
	For nI := 1 to Len( aBlocosSpd )

		/*-------------------------------------------------------------------------------------------
		Indica se o Usuário Selecionou o Bloco
		-------------------------------------------------------------------------------------------*/
		If aBlocosSpd[nI,1]

			/*-------------------------------------------------------------------------------------------
			Deleta as informações do mesmo periodo/filial contidos na tabela temporaria
			-------------------------------------------------------------------------------------------*/
			xDelObrig( cObrig, aBlocosSpd[nI,3], aWizard, cFilSel, cTabSped, cTabCtl )


			/*-------------------------------------------------------------------------------------------
			Funcao que realiza o controle da tabela de gerenciamento de geração dos blocos
			-------------------------------------------------------------------------------------------*/
			xTafCTLObr( "1", aBlocosSpd[nI,3], aWizard, cFilSel, cCTLAlias, cTabCtl, cObrig )


			/*-------------------------------------------------------------------------------------------
			Busco função de geração do Bloco
			-------------------------------------------------------------------------------------------*/
			cFunction := Alltrim( aBlocosSpd[nI,2] )

			/*-------------------------------------------------------------------------------------------
			Processamento Multi Thread
			-------------------------------------------------------------------------------------------*/
			If lMultThread

				/*-------------------------------------------------------------------------------------------
				Inicializa variavel global de controle das Threads
				-------------------------------------------------------------------------------------------*/
				cJobAux := StrTran( "cSped_" + FWGrpCompany() + FWCodFil() , ' ' , '_' ) + StrZero( nI , 2 )

				/*-------------------------------------------------------------------------------------------
				Seto o Status da Variavel como "0", ou seja, pendente de processamento
				-------------------------------------------------------------------------------------------*/
				PutGlbValue( cJobAux , "0" )
				GlbUnlock()

				/*-------------------------------------------------------------------------------------------
				Adiciona o nome do arquivo de Job no array aJobAux
				-------------------------------------------------------------------------------------------*/
				aAdd( aJobAux , { cJobAux, aBlocosSpd[nI,3] } )

				/*-------------------------------------------------------------------------------------------
				Variavel de controle de Start das Execuções
				-------------------------------------------------------------------------------------------*/
				nTryExec := 0

				/*-------------------------------------------------------------------------------------------
				Inicio a execução dos Blocos
				-------------------------------------------------------------------------------------------*/
				While .T.
					If IPCGo( cSemaphore, cObrig, cFunction, aWizard, cFilSel, lConv115, cPerfilSPD, cTabSped, cJobAux )
						Conout("*** Iniciando a Função  " + cFunction + " ***" )
						Exit
					Else
						nTryExec++
						Sleep( 1000 )
					EndIf

					/*-------------------------------------------------------------------------------------------
					Caso ocorra erro em 10 tentativas de iniciar a Thread aborto informando ao usuário o erro
					-------------------------------------------------------------------------------------------*/
					If nTryExec > 10
						cErrorTrd := "Ocorreu um erro fatal durante a inicialização das Threads, por favor reinicie o processo, caso o erro persista entre em contato com o administrador do Sistema"
						Exit
					EndIf
				EndDo

			/*-------------------------------------------------------------------------------------------
			MonoThread
			-------------------------------------------------------------------------------------------*/
			Else

				oProcess:Inc1Progress( "Gerando Sped Fiscal..." )
				oProcess:Inc2Progress( "Executando o Bloco..." + aBlocosSpd[nI,3] )
				&cFunction.( aWizard, cFilSel, lConv115, cPerfilSPD, cTabSped, cJobAux )
			EndIf
		EndIf

		/*-------------------------------------------------------------------------------------------
		Caso seja encontrado algum erro durante o processamento aborto a execução
		-------------------------------------------------------------------------------------------*/
		If !Empty( cErrorTrd )
			Exit
		EndIf

	Next nI

	/*-------------------------------------------------------------------------------------------
	Verifico se não ocorreu erro na inicialização das Threads
	-------------------------------------------------------------------------------------------*/
	If Empty( cErrorTrd )

		/*-------------------------------------------------------------------------------------------
		Quando o processamento se realizar em Mult Thread eu realizo a verificacao do Status de Processamento
		da geracao do bloco
		-------------------------------------------------------------------------------------------*/
		If lMultThread

			While .T.

				/*-------------------------------------------------------------------------------------------
				Neste laço eu verifico quais blocos ja foram encerrados para atualizar a barra de processamento
				de geracao do Sped
				-------------------------------------------------------------------------------------------*/
				For nI := 1 To Len( aJobAux )

					/*-------------------------------------------------------------------------------------------
					Nome da Variavel Globo de Gerenciamento das Threads
					-------------------------------------------------------------------------------------------*/
					cJobAux := aJobAux[nI][1]

					Do Case

						/*-------------------------------------------------------------------------------------------
						Quando o Status for igual a 1 significa que o bloco foi encerrado, sendo assim
						atribou +1 na barra de processamento
						-------------------------------------------------------------------------------------------*/
						Case GetGlbValue( cJobAux ) == '1'

							/*-------------------------------------------------------------------------------------------
							Atualizando a barra de processamento
							-------------------------------------------------------------------------------------------*/
							nProgress1--
							oProcess:Inc1Progress( "Gerando Sped Fiscal..." )
							oProcess:Inc2Progress( "Encerrando o Bloco..." + aJobAux[nI][2] )

							/*-------------------------------------------------------------------------------------------
							Encerro da execução da variavel em memoria
							-------------------------------------------------------------------------------------------*/
							ClearGlbValue( cJobAux )

						/*-------------------------------------------------------------------------------------------
						O Tipo 9 ocorre quando ocorre Error Log na execução do Bloco
						-------------------------------------------------------------------------------------------*/
						Case GetGlbValue( cJobAux ) == '9'

							nProgress1--
							cErrorSpd += "," + aJobAux[nI][2] + " "

							/*-------------------------------------------------------------------------------------------
							Encerro da execução da variavel em memoria
							-------------------------------------------------------------------------------------------*/
							ClearGlbValue( cJobAux )
					EndCase
				Next

				/*-------------------------------------------------------------------------------------------
				Quando a variavel for menor que zero significa que todos os blocos foram encerrados
				-------------------------------------------------------------------------------------------*/
				If nProgress1 <= 0
					Exit
				EndIf

				/*-------------------------------------------------------------------------------------------
				Aguarda 1 Segundo antes de executar a proxima verificacao
				-------------------------------------------------------------------------------------------*/
				Sleep( 1000 )
			EndDo

			/*-------------------------------------------------------------------------------------------
			Encerrando as Threads utilizadas no processamento
			-------------------------------------------------------------------------------------------*/
			xFinalThread( cSemaphore, nQtdThread )
		EndIf
	Else

		/*-------------------------------------------------------------------------------------------
		Encerrando as Threads utilizadas no processamento
		-------------------------------------------------------------------------------------------*/
		xFinalThread( cSemaphore, nQtdThread )

	EndIf

	/*-------------------------------------------------------------------------------------------
	Tratamento para quando o processamento tem problemas
	-------------------------------------------------------------------------------------------*/
	If oProcess:nCancel = 1 .Or. !Empty( cErrorSpd ) .Or. !Empty( cErrorTrd )

		/*-------------------------------------------------------------------------------------------
		Cancelado o processamento
		-------------------------------------------------------------------------------------------*/
		If oProcess:nCancel = 1
			MsgAlert( "A geração do arquivo foi cancelada com sucesso!" )

		/*-------------------------------------------------------------------------------------------
		Erro na inicialização das Threads
		-------------------------------------------------------------------------------------------*/
		ElseIf !Empty( cErrorTrd )
			MsgAlert( cErrorTrd )

		/*-------------------------------------------------------------------------------------------
		Erro na execução dos Blocos
		-------------------------------------------------------------------------------------------*/
		Else
			cErrorSpd := "Ocorreu um erro fatal durante a geração do(s) Bloco(s) " + Substr( cErrorSpd, 2, Len( cErrorSpd ) )
			cErrorSpd += "do Sped Fiscal " + Chr(10) + Chr(10)
			cErrorSpd += "Favor reprocessar a geração deste(s) bloco(s), caso o erro persista entre em contato "
			cErrorSpd += "com o administrador de sistemas / Suporte Totvs" + Chr(10) + Chr(10)
			MsgAlert( cErrorSpd )
		EndIf
	Else

		/*-------------------------------------------------------------------------------------------
		Tratamento para exibir mensagem no console quando processamento multi Thread
		-------------------------------------------------------------------------------------------*/
		If lMultThread
			Conout("*** Realizando geração do arquivo magnético ***" )
		EndIf


		/*-------------------------------------------------------------------------------------------
		Atualizando a barra de processamento
		-------------------------------------------------------------------------------------------*/
		oProcess:Inc1Progress( "Gerando Sped Fiscal..." )
		oProcess:Inc1Progress( "Consolidando as informações e Gerando Arquivo..." )


		/*-------------------------------------------------------------------------------------------
		Totalizando o registro 0990 do bloco 0, deve ser realizado neste momento pois esse
		bloco eh gerado em função dos demais, sendo assim eh necessario aguardar todo
		o processamento
		-------------------------------------------------------------------------------------------*/
		Reg990Spd( "0", cTabSped, cFilSel, aWizard )


		/*-------------------------------------------------------------------------------------------
		Deleta as informações do mesmo periodo/filial contidos na tabela temporaria do bloco 9
		-------------------------------------------------------------------------------------------*/
		xDelObrig( cObrig, "9", aWizard, cFilSel, cTabSped, cTabCtl )


		/*-------------------------------------------------------------------------------------------
		Geração do Bloco 9
		-------------------------------------------------------------------------------------------*/
		oProcess:Inc2Progress( "Gerando o Bloco 9... " )
		Bloco9( , , .T., cTabSped, cFilSel, aWizard )


		/*-------------------------------------------------------------------------------------------
		Realiza as querys responsáveis por gerar o Arquivo TXT Final do Sped após o Processamento
		-------------------------------------------------------------------------------------------*/
		xConsSped( aWizard, @nHdlTxt, cFilsel, cTabSped, cSpedAlias )


		/*-------------------------------------------------------------------------------------------
		Gerando arquivo texto no local indicado pelo usuário
		-------------------------------------------------------------------------------------------*/
		SaveTxt( nHdlTxt , cTxtSys , cTxtUsu )


		/*-------------------------------------------------------------------------------------------
		Atualizando a barra de processameno
		-------------------------------------------------------------------------------------------*/
		oProcess:Inc1Progress( "Arquivo Gerado com Sucesso!!!" )
		oProcess:Inc2Progress( "Finalizado " )

		Conout( "Tempo Final " + Time() )

		MsgInfo( "Arquivo Gerado com Sucesso!" )
	EndIf

	/*-------------------------------------------------------------------------------------------
	Restaurando a Filial inicial do Processamento
	-------------------------------------------------------------------------------------------*/
	cFilAnt := cFilBkp

	/*-------------------------------------------------------------------------------------------
	Zerando os arrays utilizados durante o processamento
	-------------------------------------------------------------------------------------------*/
	aSize( aJobAux, 0 )

	/*-------------------------------------------------------------------------------------------
	Zerando as Variaveis utilizadas
	-------------------------------------------------------------------------------------------*/
	aJobAux := Nil
Return ( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} getObrigParam

Construção dos painéis para geração do arquivo.

@Return	aRet	-	Parametrização necessária para a rotina xFunWizard

@Author	Rodrigo Aguilar
@Since		28/12/2012
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function getObrigParam()
	Local	cNomWiz   	:= "SPDFISCAL" + FWGETCODFILIAL
	Local	cNomeAnt  	:= ""
	Local	cTitObj1	:=	""
	Local	cTitObj2	:=	""
	Local	aTxtApre	:=	{}
	Local	aPaineis	:=	{}
	Local	aItens1	:=	{}
	Local	aItens2	:=	{}
	Local	aRet		:=	{}
	Local	cTamProd 	:=	TamSx3("B1_COD")[1]

	Default	cNomeAnt	:= ""

	aAdd (aTxtApre, "Parâmetros necessários.")
	aAdd (aTxtApre, "")
	aAdd (aTxtApre, "Preencha corretamente as informações solicitadas.")
	aAdd (aTxtApre, "Informações necessárias para a geração do meio-magnético SPED FISCAL.")


	/*-------------------------------------------------------------------------------------------
	PAINEL 0
	-------------------------------------------------------------------------------------------*/
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)

	aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
	aAdd (aPaineis[nPos], "Parâmetros para Geração")
	aAdd (aPaineis[nPos], {})

	cTitObj1	:=	"Data de"
	cTitObj2	:=	"Data até"

	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	aAdd (aPaineis[nPos][3], {2,,,3,,,,})
	aAdd (aPaineis[nPos][3], {2,,,3,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	cTitObj1	:=	"Diretório do Arquivo Destino"
	cTitObj2	:=	"Nome do Arquivo Destino"

	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	cTitObj1	:=	Replicate ("X", 50)
	cTitObj2	:=	Replicate ("X", 20)

	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50})
	aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	cTitObj1	:=	"Versão"
	cTitObj2	:=	"Seleciona Filiais ?"

	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	cTitObj1	:=	Replicate ("X", 03)
	aItens2	:=	{"1-Sim","2-Nao"}

	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,03})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})


	/*-------------------------------------------------------------------------------------------
	PAINEL 1
	-------------------------------------------------------------------------------------------*/
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)

	aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
	aAdd (aPaineis[nPos], "Identificação do Contribuinte")
	aAdd (aPaineis[nPos], {})

	cTitObj1	:=	"Código da Finalidade do Arquivo"
	cTitObj2	:=	"Perfil de Apresentação"

	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	aItens1	:=	{}
	aItens2	:=	{}

	aAdd (aItens1, "0-Remessa regular de arquivo")
	aAdd (aItens2, "A - Perfil A")
	aAdd (aItens1, "1-Remessa de arquivo substituto")
	aAdd (aItens2, "B - Perfil B")
	aAdd (aItens2, "C - Perfil C")

	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	cTitObj1	:=	"Tipo de Atividade"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	aItens1	:=	{}

	aAdd (aItens1, "0 - Industrial ou Equiparado")
	aAdd (aItens1, "1 - Outros")

	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	cTitObj1	:=	"Informações Cadastrais"

	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	cTitObj1	:=	"Email"
	cTitObj2	:=	"Segmento de Combustível"

	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	cTitObj1	:=	Replicate ("X", 50)
	cTitObj2	:=	Replicate ("X", 50)
	aItens1	:=	{}

	aAdd (aItens1, "0 - Sim")
	aAdd (aItens1, "1 - Não")

	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	cTitObj1	:=	"Segmento de Energia Elétrica"
	cTitObj2	:=	"Convênio 115/2003"

	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	cTitObj1	:=	Replicate ("X", 03)
	cTitObj2	:=	Replicate ("X", 50)

	aItens1	:=	{}
	aItens2	:=	{}

	aAdd (aItens1, "0 - Sim")
	aAdd (aItens2, "0 - Sim")
	aAdd (aItens1, "1 - Não")
	aAdd (aItens2, "1 - Não")

	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})


	/*-------------------------------------------------------------------------------------------
	PAINEL 2
	-------------------------------------------------------------------------------------------*/
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)

	aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
	aAdd (aPaineis[nPos], "Dados do contabilista")
	aAdd (aPaineis[nPos], {})

	cTitObj1	:=	"Contabilista"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})

	cTitObj1	:=	Replicate ("X", 36)

	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,36,,,"C2JFIL",{"xValWizCmp",1,{"C2J","5"}}} )
	aAdd( aPaineis[nPos,3], { 0, "",,,,,,} )
	aAdd( aPaineis[nPos,3], { 0, "",,,,,,} )


	/*-------------------------------------------------------------------------------------------
	PAINEL 3
	-------------------------------------------------------------------------------------------*/
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)

	aAdd (aPaineis[nPos], "Preencha corretamente as informacoes solicitadas.")
	aAdd (aPaineis[nPos], "Informacoes para processamento do Bloco 1")
	aAdd (aPaineis[nPos], {})


	aItens1		:=	{}
	aAdd (aItens1, "1 - Sim")
	aAdd (aItens1, "2 - Não")

	aItens2		:=	{}
	aAdd (aItens2, "1 - Sim")
	aAdd (aItens2, "2 - Não")


	cTitObj1	:=	"Gera Registro 1100 - Exportação?"
	cTitObj2	:=	"Gera Registro 1200 - Créditos Fiscais?"

	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})

	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	cTitObj1	:=	"Gera Registro 1300 - Combustíveis?"
	cTitObj2	:=	"Gera Registro 1390 - Usina de açúcar/álcool?"

	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})

	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	cTitObj1	:=	"Gera Registro 1400 - Valores Agregados?"
	cTitObj2	:=	"Gera Registro 1500 - Energia Elétrica?"

	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	cTitObj1	:=	"Gera Registro 1600 - Cartão de Crédito/Débito?"
	cTitObj2	:=	"Gera Registro 1700 - Documentos Fiscais?"

	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	cTitObj1	:=	"Gera Registro 1800 - Transporte Aéreo?"

	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})


	/*-------------------------------------------------------------------------------------------
	PAINEL 4
	-------------------------------------------------------------------------------------------*/
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)

	aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
	aAdd (aPaineis[nPos], "Informações do Inventário")
	aAdd (aPaineis[nPos], {})

	cTitObj1	:=	"Data do Inventário de"
	cTitObj2	:=	"Data do Inventário até"

	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	aAdd (aPaineis[nPos][3], {2,,,3,,,,})
	aAdd (aPaineis[nPos][3], {2,,,3,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})



	/*-------------------------------------------------------------------------------------------
	PAINEL 5
	-------------------------------------------------------------------------------------------*/
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)

	aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
	aAdd (aPaineis[nPos], "Informações para processamento do Bloco D")
	aAdd (aPaineis[nPos], {})

	cTitObj1	:=	"Gerar o registro D300 consolidado?"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})

	cTitObj1	:=	Replicate ("X", 03)
	aItens1	:=	{}

	aAdd (aItens1, "0 - Sim")
	aAdd (aItens1, "1 - Não")
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	/*-------------------------------------------------------------------------------------------
	PAINEL 6
	-------------------------------------------------------------------------------------------*/
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)

	aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
	aAdd (aPaineis[nPos], "Informações para processamento do Bloco K")
	aAdd (aPaineis[nPos], {})

	cTitObj1	:=	"Gerar o Bloco K?"
	cTitObj2	:=	"Gera Registro 0210 - Consumo Especifíco "

	aItens1	:=	{}
	aItens2	:=	{}
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})	
	aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	aAdd (aItens1, "0 - Sim")
	aAdd (aItens1, "1 - Não")
	aAdd (aItens1, "2 - Sim - K200/K280")

	aAdd (aItens2, "0 - Sim")
	aAdd (aItens2, "1 - Não")



	/*-------------------------------------------------------------------------------------------
	PAINEL FINAL
	-------------------------------------------------------------------------------------------*/
	aAdd( aRet, aTxtApre )
	aAdd( aRet, aPaineis )
	aAdd( aRet, cNomWiz )
	aAdd( aRet, cNomeAnt )
	aAdd( aRet, Nil )
	aAdd( aRet, Nil )
	aAdd( aRet, { || TAFA117() } )	//Code Block para o botão "Finalizar" deve executar a rotina responsável pela geração do arquivo
Return( aRet )
