#include 'totvs.ch'
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF
#DEFINE ARQUIVO_LOG "job_valida_sib_espelho.log"
#DEFINE JOBESPELHO 	"2"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSSIBESP

Funcao criada para carregar os jobs de sentetizacao referente ao SIB para a central de obrigacoes (B3L)

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSSIBESP(nRecno, oMark)
	Local aSay     := {}
	Local aButton  := {}
	Local nOpc     := 0
	Local Titulo	:= 'Valida�oes - SIB - Base Central x Espelho ANS'
	Local cDesc1	:= 'Esta rotina far� as valida��es entre a base do'
	Local cDesc2	:= 'n�cleo de informa��es e obriga��es e a base da.'
	Local cDesc3	:= "ANS "
	Local cDataRef	:= "" //Data informada pelo usuaio
	Local cRegANS	:= "" //Codigo de registro da operadora
	Local cTipProc	:= "" //Tipo de processamento 1=Beneficiarios; 2=Eventos x Despesa
	Default nRecno	:= 0
	Default oMark   := Nil

	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	aAdd( aSay, cDesc3 )

	aAdd( aButton, { 5, .T., { || nOpc := 1, Pergunte('PLSVALESP',.T.,Titulo,.F.) } } )
	aAdd( aButton, { 1, .T., { || nOpc := 2, Iif( ValidaPergunta(), FechaBatch(), nOpc := 0 ) } } )
	aAdd( aButton, { 2, .T., { || FechaBatch() } } )

	FormBatch( Titulo, aSay, aButton, , 200, 450 )

	If nOpc == 2

		cRegANS		:= mv_par01
		cTipProc	:= "2"//AllTrim(mv_par04)

		If !Empty(cRegANS) .Or. !Empty(cTipProc)

			If nRecno > 0 .And. Valtype(oMark) <> "U" .And. !Empty(oMark:cMark)

				MsgInfo("A valida��o ser� realizada em segundo plano. Para acompanhar a execu��o clique em Atualizar na tela principal.","TOTVS")
				CenValEsp(oMark,cDataRef,cRegANS,cTipProc)

			Else
				Processa( { || lOk := PLSVALESP(cDataRef,cRegANS,cTipProc,nRecno) },'Aguarde','Processando...',.F.)

			EndIf
		Else
			MsgInfo("Para confirmar o processamento informe todos os par�metros.","TOTVS")
			Pergunte('PLSVALESP',.T.,Titulo,.F.)
		EndIf

	EndIf

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidaPergunta

Funcao criada para verificar se todas perguntas foram respondidas

@return lRet	Verdadeiro (.T.) se todas as perguntas foram respondidas, senao Falso (.F.)

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ValidaPergunta()
	Local lRet	:= .T.
	Local cMsg	:= ""

	If Empty(mv_par01)
		lRet := .F.
		cMsg += "Qual a operadora padrao ?" + CRLF
	EndIf

	If !lRet
		MsgInfo("Os seguintes parametros nao foram respondidos: " + CRLF + CRLF + cMsg ,"TOTVS")
	EndIf

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSVALESP

Funcao de importacao de eventos x despesas do PLS para o NIO - B3L

@param cDataRef		Data de referencia
@param cRegANS		Numero de registro da operadora na ANS
@param cTipProd		1-Produtos, 2-Beneficiario, 3-Despesas

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSVALESP(cDataRef,cRegANS,cTipProc,nRecno,lMark)
	Local   nArquivo	:= 0 //handle do arquivo/semaforo
	Local   nFor			:= 0
	Local   lContinua := .T. //Indica se deve .T. ou nao .F. continuar
	Local   aThreads	:= {}
	Local   aTipProc	:= {}
	Local   nCriBenNoANS := MV_PAR03
	Default cDataRef	:= DTOS(dDataBase)
	Default cRegANS	  := MV_PAR01
	Default cTipProc	:= '2'
	Default nRecno	  := 0
	Default lMark	    := .F.

	If !Empty(MV_PAR02)
		cDataRef := DTOS(MV_PAR02)
	EndIf

	If Empty(MV_PAR02) .Or. valtype(MV_PAR03)=="C"
		nCriBenNoANS := 1 //Critica benefici�rios que n�o est�o na ANS
	EndIf

	aTipProc := StrTokArr(cTipProc,',')
	For nFor := 1 TO Len(aTipProc)
		AdicionaThreads(aThreads,Val(aTipProc[nFor]))
	Next nFor

	//abrir semaforo
	nArquivo := Semaforo('A',0)

	//Se abriu o semaforo e carregou os beneficiarios do PLS
	If nArquivo <= 0
		lContinua := .F.
	EndIf

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Inicio PLSVALESP",ARQUIVO_LOG)

	//Validacao do espelho de beneficiarios
	StartJob("PLSIBVLES",GetEnvServer(),.F.,cEmpAnt,cFilAnt,;
		aThreads,cDataRef,cRegANS,cEmpAnt,Nil,;
		nRecno,,nCriBenNoANS)

	//Fecha semaforo
	nArquivo := Semaforo('F',nArquivo)

	If !isBlind() .AND. !lMark
		MsgInfo("A valida��o ser� realizada em segundo plano. Para acompanhar a execu��o clique em Atualizar na tela principal.","TOTVS")
	EndIf


Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AdicionaThreads

Funcao criada para alimentar de forma padronizada a matriz de threads

@param aThreads		Matriz com as informacoes referente as threads
@param nTipProc		Tipo de processamento a ser realizado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function AdicionaThreads(aThreads,nTipProc)
	Default aThreads	:= {}
	Default nTipProc	:= 0

	aAdd(aThreads,{;
		{2},;								//01-
		"JobSIBESP"+StrZero(nTipProc,2),;		//02-
		"Nao",;								//03-
		nTipProc,;							//04-
		0,;									//05-
		Time(),;							//06-
		"",;								//07-
		"",;								//08-
		"JobSIBSta"+StrZero(nTipProc,2),;	//09-
		"BR_VERDE",;						//10-
		"JobSIBPerc"+StrZero(nTipProc,2),;	//11-
		Nil,;								//12-
		"JobSIBProc"+StrZero(nTipProc,2),;	//13-
		"JobSIBEvPr"+StrZero(nTipProc,2),;	//14-
		0,;									//15-
		"JobSIBEvDs"+StrZero(nTipProc,2),;	//16-
		0,;									//17-
		"Normal",;							//18-
		0,;									//19-
		0,;									//20-
		.F.,;								//21-
		{},;								//22-
		})

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSIBVLES

Funcao criada para validar os registros de beneficiarios da Central de Obrigacoes

@param cEmp			Empresa do sistema
@param cFil			Filial do sistema
@param aThreads		Matriz de informacoes da thread
@param cDataRef		Data de referencia
@param cTipData		1-Digitacao,2-Pagamento,3-Procedimento
@param cRegANS			Numero de registro da operadora na ANS
@param cEmpresa		Codigo do grupo empresa

@return lRetorno	Retorna .T. para processamento ok e .F. para problema

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSIBVLES(cEmp,cFil,aThreads,cDataRef,cRegANS,;
		cEmpresa,oModel,nRecno,lJob,nCriBenNoANS)
	Local lValido			:= .T.

	Local cCodObri		:= ""
	Local cAnoComp		:= ""
	Local cSazComp		:= ""
	Local cCodComp		:= ""
	Local cAlias	 	:= "TRBBEN"
	Local cAliasRec		:= getNextAlias()
	Local cObri			:= "2"
	Local aCritBen		:= {}
	Local aCriticas		:= {}

	Local nContador		:= 0

	Default cEmp 		:= ""
	Default cFil		:= ""
	Default aThreads	:= {}
	Default cDataRef	:= DTOS(dDataBase)
	Default cRegANS		:= ""
	Default cEmpresa	:= ""
	Default oModel	:= nil
	Default nRecno	:= 0
	Default lJob	:= .T.


	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf
	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Inicio PLSIBVLES" + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "]",""),ARQUIVO_LOG)
	PtInternal(1,AllTrim("PLSIBVLES " + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "]","") + ": " + " validando beneficiarios"))


	If oModel == Nil

		If LocCmpSib(cDataRef,@cCodObri,@cAnoComp,@cSazComp,@cCodComp,;
				cRegANS)

			//O benefici�rio est� na base da Central e da ANS
			If BenefCntANS(cAliasRec,cRegANS,cEmpresa,nRecno,cDataRef)

				//Valida��es que devem ser executadas em apenas uma opera��o
				PlMntCriEs(aCritBen)

				While !(cAliasRec)->(Eof())
					
					//Retorna todos os campos da consulta original (BenefCntANS), por�m, de somente um benefici�rio
					If PosBenRec(cAlias,cDataRef,(cAliasRec)->R_E_C_N_O_,(cAliasRec)->B3W_RECNO,cEmpresa)

					 	nContador++

						lValido := PlObVldCri(cRegANS,cCodObri,cAnoComp,cCodComp,aCritBen,;
							"B3K",TRBBEN->R_E_C_N_O_,Nil,Nil,JOBESPELHO,;
							aCriticas,TRBBEN->B3K_MATRIC,TRBBEN->B3K_NOMBEN,cObri,TRBBEN->B3K_CODCCO+TRBBEN->B3K_MATRIC)

						If nContador % 100 == 0 .Or. nContador == 1
							PtInternal(1,AllTrim("PLSIBVLES " + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "] "," ") + AllTrim(Str(nContador)) + " registros validados"))
						EndIf		

					Endif									
					
					TRBBEN->(dbCloseArea())

					(cAliasRec)->(dbSkip())

				EndDo //!(cAliasRec)->(Eof())

			EndIf //BenefCntANS

			(cAliasRec)->(dbCloseArea())

			//O benefici�rio est� na Base da Operadora, mas n�o na ANS
			If BenefCnt(cAlias,cRegANS,cEmpresa,nRecno) .AND. nCriBenNoANS == 1 //Critica = 1

				aCritBen := {}
				aAdd(aCritBen,{"E029",;
					"    ",;
					"SIBVLDE029"	,;
					"O benefici�rio est� cadastrado na Base da Operadora, mas n�o na ANS",;
					"Envie o benefici�rio como inclus�o para a ANS.",;
					.F.,"B3K_MATRIC"})

				While !TRBBEN->(Eof())
					nContador++

					lValido := PlObVldCri(cRegANS,cCodObri,cAnoComp,cCodComp,aCritBen,;
						"B3K",TRBBEN->R_E_C_N_O_,Nil,Nil,JOBESPELHO,;
						aCriticas,TRBBEN->B3K_MATRIC,TRBBEN->B3K_NOMBEN,cObri,TRBBEN->B3K_CODCCO+TRBBEN->B3K_MATRIC)

					TRBBEN->(dbSkip())

					If nContador % 100 == 0 .Or. nContador == 1
						PtInternal(1,AllTrim("PLSIBVLES " + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "] "," ") + AllTrim(Str(nContador)) + " registros validados"))
					EndIf

				EndDo //!TRBBEN->(Eof())

			EndIf //BenefCnt

			TRBBEN->(dbCloseArea())

			//O benefici�rio est� na ANS, mas n�o na Base da Operadora
			If nRecno == 0
				BenefANS(cAlias,cRegANS,cEmpresa)

				aCritBen := {}
				aAdd(aCritBen,{"E030",;
					"    ",;
					"SIBVLDE030"	,;
					"O benefici�rio est� cadastrado na ANS, mas n�o na Base da Operadora",;
					"Inclua o benefici�rio na base da Operadora.",;
					.F.,"B3W_MATRIC"})

				While !TRBBEN->(Eof())
					nContador++

					lValido := PlObVldCri(cRegANS,cCodObri,cAnoComp,cCodComp,aCritBen,;
						"B3W",TRBBEN->R_E_C_N_O_,Nil,Nil,JOBESPELHO,;
						aCriticas,TRBBEN->B3W_MATRIC,TRBBEN->B3W_NOMBEN,cObri,TRBBEN->B3W_CODCCO+TRBBEN->B3W_MATRIC)

					TRBBEN->(dbSkip())

					If nContador % 100 == 0 .Or. nContador == 1
						PtInternal(1,AllTrim("PLSIBVLES " + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "] "," ") + AllTrim(Str(nContador)) + " registros validados"))
					EndIf

				EndDo //!TRBBEN->(Eof())

				TRBBEN->(dbCloseArea())

			EndIf //BenefANS

		EndIf //LocCmpSib()

	Else
		lValido := PlObVldCri(cRegANS,cCodObri,cAnoComp,cCodComp,aCritBen,;
			"B3K",nil,nil,oModel,JOBESPELHO,;
			aCriticas,TRBBEN->B3K_MATRIC,TRBBEN->B3K_NOMBEN,cObri,TRBBEN->B3K_CODCCO+TRBBEN->B3K_MATRIC)
	EndIf //oModel == Nil

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Termino PLSIBVLES" + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "]. Total Reg. Proc.: " + Alltrim(str(nContador)),""),ARQUIVO_LOG)

Return lValido
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSIBVLES

Funcao criada carregar as cr�ticas que ser�o validadas

@param aCritBen	Array de cr�ticas. Estrututa:	[1]C�digo da cr�tica,
														[2]C�digo da cr�tica na ANS,
														[3]Fun��o de valida��o,
														[4]Descri��o da cr�tica,
														[5]Solu��o,
														[6]Indica��o de cr�tica totalizadora (SIP),
														[7]Campo afetado pela cr�tica
@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function PlMntCriEs(aCritBen)
	//Criticas que apenas comparam as bases
	aAdd(aCritBen,{"E001",;
		"    ",;
		"SIBVLDE001"	,;
		"O nome do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS."	,;
		.F.,;
		"B3K_NOMBEN"})
	aAdd(aCritBen,{"E002",;
		"    ",;
		"SIBVLDE002"	,;
		"A data de nascimento n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_DATNAS"})
	aAdd(aCritBen,{"E003",;
		"    ",;
		"SIBVLDE003"	,;
		"O c�digo do sexo do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_SEXO"})
	aAdd(aCritBen,{"E004",;
		"    ",;
		"SIBVLDE004"	,;
		"O CPF do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_CPF"})
	aAdd(aCritBen,{"E005",;
		"    ",;
		"SIBVLDE005"	,;
		"O PIS/PASEP do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_PISPAS"})
	aAdd(aCritBen,{"E006",;
		"    ",;
		"SIBVLDE006"	,;
		"O CNS do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_CNS"})
	aAdd(aCritBen,{"E007",;
		"    ",;
		"SIBVLDE007"	,;
		"O Nome da M�e do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_NOMMAE"})
	aAdd(aCritBen,{"E008",;
		"    ",;
		"SIBVLDE008"	,;
		"O N�mero da Declara��o Nascido Vivo do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_DN"})
	aAdd(aCritBen,{"E009",;
		"    ",;
		"SIBVLDE009"	,;
		"O Logradouro do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_ENDERE"})
	aAdd(aCritBen,{"E010",;
		"    ",;
		"SIBVLDE010"	,;
		"O N�mero do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_NR_END"})
	aAdd(aCritBen,{"E011",;
		"    ",;
		"SIBVLDE011"	,;
		"O Complemento do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_COMEND"})
	aAdd(aCritBen,{"E012",;
		"    ",;
		"SIBVLDE012"	,;
		"O Bairro do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_BAIRRO"})
	aAdd(aCritBen,{"E013",;
		"    ",;
		"SIBVLDE013"	,;
		"O C�digo Munic�pio Resid�ncia do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_CODMUN"})
	aAdd(aCritBen,{"E014",;
		"    ",;
		"SIBVLDE014"	,;
		"O CEP do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_CEPUSR"})
	aAdd(aCritBen,{"E015",;
		"    ",;
		"SIBVLDE015"	,;
		"O Tipo Endere�o do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_TIPEND"})
	aAdd(aCritBen,{"E016",;
		"    ",;
		"SIBVLDE016"	,;
		"O c�digo Reside Exterior do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_RESEXT"})
	aAdd(aCritBen,{"E017",;
		"    ",;
		"SIBVLDE017"	,;
		"O C�digo do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_MATRIC"})
	aAdd(aCritBen,{"E018",;
		"    ",;
		"SIBVLDE018"	,;
		"A Rela��o Depend�ncia do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_TIPDEP"})
	aAdd(aCritBen,{"E019",;
		"    ",;
		"SIBVLDE019"	,;
		"O C�digo Benefici�rio Titular do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_CODTIT"})

	aAdd(aCritBen,{"E020",;
		"    ",;
		"SIBVLDE020"	,;
		"A Data Contrata��o do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_DATINC"})
	aAdd(aCritBen,{"E021",;
		"    ",;
		"SIBVLDE021"	,;
		"A Data Bloqueio do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_DATBLO"})
	aAdd(aCritBen,{"E022",;
		"    ",;
		"SIBVLDE022"	,;
		"N�mero de Registro do Plano na ANS (SUSEP) do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_SUSEP"})
	aAdd(aCritBen,{"E023",;
		"    ",;
		"SIBVLDE023"	,;
		"O C�digo do Cadastro do Plano na ANS (SCPA) do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_SCPA"})
	aAdd(aCritBen,{"E024",;
		"    ",;
		"SIBVLDE024"	,;
		"O Plano Origem (portabilidade) do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_PLAORI"})
	aAdd(aCritBen,{"E025",;
		"    ",;
		"SIBVLDE025"	,;
		"Cobertura Parcial Tempor�ria do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_COBPAR"})
	aAdd(aCritBen,{"E026",;
		"    ",;
		"SIBVLDE026"	,;
		"Itens CPT do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_ITEEXC"})
	aAdd(aCritBen,{"E027",;
		"    ",;
		"SIBVLDE027"	,;
		"O CNPJ Contratante do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_CNPJCO"})
	aAdd(aCritBen,{"E028",;
		"    ",;
		"SIBVLDE028"	,;
		"O CEI Contratante do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_CEICON"})
	aAdd(aCritBen,{"E031",;
		"    ",;
		"SIBVLDE031"	,;
		"Situa��o da Central n�o condiz com a situa��o da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_SITANS"})
	aAdd(aCritBen,{"E032",;
		"    ",;
		"SIBVLDE032"	,;
		"A Data Reativa��o do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_DATREA"})
	aAdd(aCritBen,{"E033",;
		"    ",;
		"SIBVLDE033"	,;
		"O Motivo Bloqueio do benefici�rio n�o condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
		.F.,"B3K_MOTBLO"})
	If B3K->(FieldPos("B3K_CAEPF")) > 0
		aAdd(aCritBen,{"E034",;
			"    ",;
			"SIBVLDE034"	,;
			"O CAEPF do benefici�rio n�o condiz com o cadastro da ANS",;
			"Atualizar o sistema conforme o cadastro na ANS ou enviar retifica��o cadastral para a ANS.",;
			.F.,"B3K_CAEPF"})
	EndIf
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Semaforo

Funcao criada para abrir e fechar semaforo em arquivo

@param cOpcao		A-abrir; F-Fechar
@param nArquivo		Handle do arquivo no disco

@return nArquivo	Handle do arquivo criado o zero quando fechar

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function Semaforo(cOpcao,nArquivo)
	Local cArquivo		:= 'job_eventodespesa.smf'
	Default nArquivo	:= 0
	Default cOpcao		:= 'A'

	Do Case

		Case cOpcao == 'A' //Vou criar/abrir o semaforo/arquivo

			nArquivo := FCreate(cArquivo)

		Case cOpcao == 'F' //Vou apagar/fechar o semaforo/arquivo

			If FClose(nArquivo)
				nArquivo := 0
			EndIf

	EndCase

Return nArquivo
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BenefCntANS

Funcao cria a area de trabalho TRBBEN com as informacoes de beneficiarios a validarem

@param cAlias		Area de trabalho corrente
@param cDataRef	Data de referencia
@param cRegANS		Numero de registro da operadora na ANS


@return lRetorno	retorno logico indicando se foi .T. ou nao .F. encontrado registros

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function BenefCntANS(cAliasRec,cRegANS,cEmpresa,nRecno, cDataRef)
	Local cSql			:= ""
	Local lRetorno		:= .F.
	Default cAliasRec	:= ""
	Default cRegANS		:= '000000'
	Default nRecno		:= 0
	
	cSql := " SELECT '" + cDataRef + "' DATA_BASE, "
	cSql += " B3K.R_E_C_N_O_ R_E_C_N_O_, "
	cSql += " B3W.R_E_C_N_O_ B3W_RECNO "
	cSql += " FROM " + RetSqlName("B3K") + " B3K "
	cSql += " FULL OUTER JOIN "
	cSql += " " + RetSqlName("B3W") + " B3W "
	cSql += " ON B3K_FILIAL = B3W_FILIAL "
	cSql += " AND B3K_CODCCO = B3W_CODCCO "
	cSql += " WHERE B3K_FILIAL = '" + xFilial("B3K") + "' "
	cSql += " AND B3K_CODOPE = '" + cRegANS + "' "
	cSql += " AND B3W_CODCCO <> '' "
	If nRecno > 0
		cSql += " AND B3K.R_E_C_N_O_ = " + Alltrim(str(nRecno)) + " "
	EndIf
	cSql += " AND B3K.D_E_L_E_T_ = ' '"
	cSql += " AND B3W.D_E_L_E_T_ = ' '"

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasRec,.F.,.T.)

	If Empty(cAliasRec) .Or. (cAliasRec)->(Eof())
		lRetorno := .F.
	Else
		lRetorno := .T.
	EndIf

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] " + cAliasRec + "(" + AllTrim(cEmpresa) + "): " + cSql,ARQUIVO_LOG)


Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BenefCnt

Funcao cria a area de trabalho TRBBEN com as informacoes de beneficiarios a validarem

@param cAlias		Area de trabalho corrente
@param cDataRef	Data de referencia
@param cRegANS		Numero de registro da operadora na ANS


@return lRetorno	retorno logico indicando se foi .T. ou nao .F. encontrado registros

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function BenefCnt(cAlias,cRegANS,cEmpresa,nRecno)
	Local cSql			:= ""
	Local lRetorno		:= .F.
	Default cAlias		:= ""
	Default cRegANS		:= '000000'
	Default nRecno		:= 0

	cSql := " SELECT B3K.* FROM " + RetSqlName("B3K") + " B3K "
	cSql += " WHERE B3K_FILIAL = '" + xFilial("B3K") + "' "
	cSql += " 		AND ( B3K.B3K_CODCCO = ''  "
	cSql += " 		OR B3K_CODCCO NOT IN (
	cSql += " 			SELECT B3W_CODCCO
	cSql += " 			FROM " + RetSqlName("B3W") + " B3W "
	cSql += " 			WHERE B3W.D_E_L_E_T_ = ' ' "
	cSql += " 			AND B3W.B3W_CODOPE = '" + cRegANS + "' ) ) "
	cSql += " 		AND B3K.B3K_CODOPE = '" + cRegANS + "' "
	If nRecno > 0
		cSql += " AND B3K.R_E_C_N_O_ = " + Alltrim(str(nRecno)) + " "
	EndIf
	cSql += " 		AND B3K.D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

	If Empty(cAlias) .Or. (cAlias)->(Eof())
		lRetorno := .F.
	Else
		lRetorno := .T.
	EndIf

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] " + cAlias + "(" + AllTrim(cEmpresa) + "): " + cSql,ARQUIVO_LOG)


Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BenefANS

Funcao cria a area de trabalho TRBBEN com as informacoes de beneficiarios a validarem

@param cAlias		Area de trabalho corrente
@param cDataRef	Data de referencia
@param cRegANS		Numero de registro da operadora na ANS


@return lRetorno	retorno logico indicando se foi .T. ou nao .F. encontrado registros

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function BenefANS(cAlias,cRegANS,cEmpresa)
	Local cSql			:= ""
	Local lRetorno		:= .F.
	Default cAlias		:= ""
	Default cRegANS		:= '000000'

	cSql := " SELECT B3W.* FROM " + RetSqlName("B3W") + " B3W "
	cSql += " WHERE B3W_FILIAL = '" + xFilial("B3W") + "' "
	cSql += " 		AND B3W_CODCCO NOT IN (   "
	cSql += " 			SELECT B3K_CODCCO     "
	cSql += " 			FROM " + RetSqlName("B3K") + " B3K "
	cSql += " 			WHERE B3K.D_E_L_E_T_ = ' '         "
	cSql += " 			AND B3K.B3K_CODOPE = '" + cRegANS + "' "
	cSql += " 			AND B3K.B3K_CODCCO <> '' ) "
	cSql += " 		AND B3W.B3W_CODOPE = '" + cRegANS + "' "
	cSql += " 		AND B3W.D_E_L_E_T_ = '' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

	If Empty(cAlias) .Or. (cAlias)->(Eof())
		lRetorno := .F.
	Else
		lRetorno := .T.
	EndIf

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] " + cAlias + "(" + AllTrim(cEmpresa) + "): " + cSql,ARQUIVO_LOG)


Return lRetorno

/*
Funcao criada para definir o pergunte do schedule
*/
Static Function SchedDef()
	Local aOrdem := {}
	Local aParam := {}

	aParam := { "P",;
		"PLSVALESP",;
		,;
		aOrdem,;
		""}


Return aParam

Function CenValEsp(oMark,cDataRef,cRegANS,cTipProc)
	Local cSql := ""
	Local cAliasMrk := ""
	Local cRec := ""
	Local cAliasMrk	:= getNextAlias()
	Default oMark   := Nil
	Default cDataRef:= ""
	Default cRegANS := ""
	Default cTipProc:= "2"

	If oMark:cfieldMArk == "B3F_MARK"
		cSql := " SELECT B3F_CHVORI "
		cSql += " FROM " + oTmpTab:getrealName() + ""
		cSql += " WHERE B3F_MARK = '" + oMark:cMark + "' "
	Else
		cSql := " SELECT R_E_C_N_O_ B3KREC "
		cSql += " FROM " + RetSqlName("B3K") + " "
		cSql += " WHERE B3K_MARK = '" + oMark:cMark + "' "
	EndIf

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasMrk,.F.,.T.)

	(cAliasMrk)->(dbGoTop())

	While !(cAliasMrk)->(Eof())
		If oMark:cfieldMArk == "B3F_MARK"
			cRec := allTrim((cAliasMrk)->B3F_CHVORI)
			PLSVALESP(cDataRef,cRegANS,cTipProc,Val(cRec),.T.)
		Else
			PLSVALESP(cDataRef,cRegANS,cTipProc,(cAliasMrk)->B3KREC,.T.)

		EndIF
		(cAliasMrk)->(dbSkip())

	EndDo

	(cAliasMrk)->(dbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosBenRec

Funcao cria area de trabalho com a informa��o do beneficiario

@param cAlias		Area de trabalho corrente
@param cRecnoB3K	R_E_C_N_O_ do registro na B3K
@param cRecnoB3W	R_E_C_N_O_ do registro na B3W
@return lRetorno	retorno logico indicando se foi .T. ou nao .F. encontrado registros

@author TOTVS PLS Team
@since 08/05/2023
/*/
//--------------------------------------------------------------------------------------------------

Static Function PosBenRec(cAlias,cDataRef,nRecnoB3K,nRecnoB3W,cEmpresa)

	Local cQuery := ""
	Local cRecnoB3K := cValtoChar(nRecnoB3K)
	Local cRecnoB3W := cValtoChar(nRecnoB3W)

	Local lRet	:= .F.

	cQuery := " SELECT '" + cDataRef + "' DATA_BASE, "
	cQuery += " B3K.R_E_C_N_O_ R_E_C_N_O_, "
	cQuery += " B3K_BAIRRO, B3K_CEICON, B3K_CEPUSR, B3K_CNPJCO, "
	cQuery += " B3K_CNS, B3K_COBPAR, B3K_CODCCO, B3K_CODMUN, "
	cQuery += " B3K_CODOPE, B3K_CODPRO, B3K_CODTIT, B3K_COMEND, "
	cQuery += " B3K_CPF, B3K_CPFMAE, B3K_CPFPRE, B3K_DATBLO, "
	cQuery += " B3K_DATINC, B3K_DATNAS, B3K_DATREA, B3K_DIACOB, "
	cQuery += " B3K_DN, B3K_DTINSI, B3K_DTINVL, B3K_DTTESI, "
	cQuery += " B3K_DTTEVL, B3K_ENDERE, B3K_FILIAL, B3K_HRINSI, "
	cQuery += " B3K_HRINVL, B3K_HRTESI, B3K_HRTEVL, B3K_ITEEXC, "
	cQuery += " B3K_MATANT, B3K_MATRIC, B3K_MOTBLO, B3K_MUNICI, "
	cQuery += " B3K_NOMBEN, B3K_NOMMAE, B3K_NR_END, B3K_OPESIB, "
	cQuery += " B3K_PISPAS, B3K_PLAORI, B3K_RESEXT, B3K_SCPA, "
	cQuery += " B3K_SEXO, B3K_SITANS, B3K_STAESP, B3K_STASIB, "
	cQuery += " B3K_STATUS, B3K_SUSEP , B3K_TIPDEP, B3K_TIPEND, "
	cQuery += " B3K_TRADES, B3K_TRAORI, B3K_UF, "
	cQuery += " B3W_BAIRRO, B3W_CEICON, B3W_CEPUSR, B3W_CNPJCO, "
	cQuery += " B3W_CNS, B3W_COBPAR, B3W_CODCCO, B3W_CODMUN, "
	cQuery += " B3W_CODOPE, B3W_CODTIT, B3W_COMEND, B3W_CPF, "
	cQuery += " B3W_DATBLO, B3W_DATINC, B3W_DATNAS, B3W_DATREA, "
	cQuery += " B3W_DN, B3W_ENDERE, B3W_FILIAL, B3W_ITECPT, "
	cQuery += " B3W_ITEEXC, B3W_MATRIC, B3W_MOTBLO, B3W_MUNICI, "
	cQuery += " B3W_NOMBEN, B3W_NOMMAE, B3W_NR_END, B3W_PISPAS, "
	cQuery += " B3W_PLAORI, B3W_RESEXT, B3W_SCPA , B3W_SEXO , "
	cQuery += " B3W_SITANS, B3W_SUSEP, B3W_TIPDEP, B3W_TIPEND "
	If B3K->(FieldPos("B3K_CAEPF")) > 0 .And. B3W->(FieldPos("B3W_CAEPF")) > 0
		cQuery += " ,B3K_CAEPF, B3W_CAEPF "
	EndIf
	cQuery += " FROM " + RetSqlName("B3K") + " B3K "
	cQuery += " FULL OUTER JOIN "
	cQuery += " " + RetSqlName("B3W") + " B3W "
	cQuery += " ON B3K_FILIAL = B3W_FILIAL "
	cQuery += " AND B3K_CODCCO = B3W_CODCCO "
	cQuery += " WHERE            
	cQuery += " B3K.R_E_C_N_O_ = '" + cRecnoB3K + "'
	cQuery += " AND B3W.R_E_C_N_O_ = '" + cRecnoB3W + "'
	cQuery += " AND B3K.D_E_L_E_T_ = ' '
	cQuery += " AND B3W.D_E_L_E_T_ = ' '

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)

	If Empty(cAlias) .Or. (cAlias)->(Eof())
		lRet := .F.
	Else
		lRet := .T.
	EndIf

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] " + cAlias + "(" + AllTrim(cEmpresa) + "): " + cQuery,ARQUIVO_LOG)

Return lRet
