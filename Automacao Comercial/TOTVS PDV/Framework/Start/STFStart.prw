#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"  
#INCLUDE "STFSTART.CH"

Static oSTConfig 		:= STFConfAmb():New()				// Objeto de Configuracoes gerais
Static lShowMsg			:= .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STFStart
Inicializa��o do Sistema

@param   	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna se inicializou com sucesso  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFStart()
Local lRet 			:= .T.													// Retorna se inicializou com sucesso
Local aRet			:= {}
Local aDados		:= {"23", space(SLG->(TamSx3("LG_CRO")[1])) } 
Local cCRO			:= ""
Local cCOO			:= ""
Local lEmptySale	:= .F.													// Caso haja um cupom aberto, porem nao haja nada gravado, evita a chamada do cancelamento de uma venda que nao existe.
Local lFiscal		:= .F.													// Usa impressora fiscal
Local lUsesNotFiscal:= .F.													// Usa impresora nao fiscal   
Local lFinServ    	:= SuperGetMV("MV_LJCSF",,.F.)	// Define se habilita o controle de servicos financeiros
Local lJobConPrd	:= (SuperGetMV("MV_LJAJCP",,"2") == "1")				// Atualizacao da variavel global da consulta de produto ser� realizada por JOB 1=Sim e 2=Nao
Local lUpData		:= ExistFunc("STWUpData") 								// Verifica se existe a rotina de subida de dados
Local lDowndata		:= ExistFunc("STWDownData") 							// Verifica se existe a rotina de descida de dados
Local lFirst		:= .F. 													// Integra��o com o First
Local lMobile		:= ExistFunc("STFIsMobile") .AND. STFIsMobile() 		// Pdv Mobile?
Local lNFCETSS		:= .T. 													// Envio de NFCe por TSS
Local cIntegration	:= "" 													// Tipo da Integra��o
Local lPOS			:= STFIsPOS()  											// TO DO: Colocar a regra de como identificar de est� sendo executado Front ou POS
Local lLjNfPafEcf	:= .F.
Local uRet			:= nil
Local lUsaSAT		:= LjUseSat() 			// Verifica se usa SAT
Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Local cNfceURL 		:= PadR(GetNewPar("MV_NFCEURL",""),250)
Local lIsMDI 		:= Iif(ExistFunc("LjIsMDI"),LjIsMDI(),oApp:lMDI) //Verifica se acessou via SIGAMDI
Local cMvRelt		:= SuperGetMv("MV_RELT",.F.,"")	// Validar diretorio para impressao danfe A4
Local lFunTTd707	:= ExistFunc("LjVldTTD707")
Local cMsg			:= ""
/*
	!!!!!!!!!!    ATENCAO      !!!!!!!!!!!!
	
	NAO RETIRAR O METODO oSTConfig:LoadConfig()	DO INICIO DA FUNCAO.
	ESTE METODO TER SEMPRE QUE SER CARREGADO NO INICIO	
	
	!!!!!!!!!!    ATENCAO      !!!!!!!!!!!!
*/

// -- Inicio Job de checagem de comunica��o com a retaguarda
StartJob("STFCheckCo",GetEnvServer(),.F.,cEmpAnt,cFilAnt) 

//Configura esta��o como mobile antes do oSTConfig:LoadConfig(), pois o LoadConfig utiliza essa configura��o
If lMobile //Mobile sempre ser� NFC-e
	 STFSetStat({{ "NFCE", .t.}})
	 AjstSX6Mbl() //Cria o par�metro da integra��o First
EndIf

//Desabilita a subida de dados 
lUpData := .F.

//Carrega as configuracoes globais logo no inicio
oSTConfig:LoadConfig()  // Carrega configuracoes gerais	 


/*Caso esteja habilitado o PAF-NFC-e, precisa estar cadastrado o IE do cliente na rotina  LjVldTTD707(), 
caso contr�rio n�o sobe a aplica��o*/
If STFGetCfg("lPAFNFCE") .AND. lFunTTd707 .AND. !LjVldTTD707()
	Return .F.
Endif 


/*-------------------------------------------------------------
	Avisa ao usu�rio sobre a desativa��o da NFC-e 3.10
-------------------------------------------------------------*/
If LjEmitNFCe() .AND. !lUsaSAT
	If ExistFunc("LjNfceMsg")
		cMsg := LjNfceMsg()

		If !Empty(cMsg)
			STPosMSG( "NT 2016.002" , cMsg, .T., .F., .F.)
		EndIf 
	EndIf
EndIf

/*----------------------------------------------------------------
	Avisa ao usu�rio sobre o vencimento do certificado digital
----------------------------------------------------------------*/
If !Empty(cNfceURL) .And. !lAutomato .And. lShowMsg .And. LjEmitNFCe() .And. !lUsaSAT
	If ExistFunc("LjTSSIDENT")
		cIdEnt := LjTSSIDENT("65")
		oLOJGNFCE := LOJGNFCE():New()
		oLOJGNFCE:LjChkCert(cIdEnt)
		lShowMsg := .F.
	EndIf
EndIf

//Faz validacoes importantes para o PDV
If ExistFunc("STFVldCfg")
	uRet := STFVldCfg()
	If (ValType(uRet) = "L") .AND. !uRet	//H� vers�o anterior de STFVldCfg() que retorna nil
		Return .F.
	EndIf
EndIf

// verifica a propriedade do objeto verdadeiro se MDI
If lIsMDI															
	MsgStop(STR0001)	//"O acesso a rotina atendimento na interface SIGAMDI n�o � permitido."
	Return .F.
EndIf

// Protege rotina para que seja usada apenas no SIGALOJA / Front Loja
If !AmIIn(12,23)
	Return .F.
EndIf

If !lPOS
	MsgStop(STR0039) //"Para utiliza��o do TotvsPdv, adicione/altere o conte�do da chave PosLight = 1 no AppServer.ini deste ambiente"		
	Return .F.
EndIf

/*----------------------------------------------------------------
	Evitar errorlog durante a impressao por FWMSPRINTER
	devido n�o existir o diretorio de spool
----------------------------------------------------------------*/
if Empty(cMvRelt)
	MsgStop("Para utiliza��o do TotvsPdv, deve-se preencher o parametro MV_RELT!")		
	Return .F.

elseif !ExistDir(cMvRelt)
	if Makedir(cMvRelt) <> 0
		MsgStop("Para utiliza��o do TotvsPdv, verifique o parametro MV_RELT e se o diretorio existe no protheus_data!")		
		Return .F.
	endif

endif

lNFCETSS			:= STFGetCfg("lNFCETSS", .T.)
lNFCETSS := IIF(ValType(lNFCETSS)="U", .T., lNFCETSS)

If !lNFCETSS .AND. SL1->(FieldPos("L1_PRONFCE")) == 0
	STFMessage("STFStart", "STOP", STR0008) // "Para transmiss�o de NFCe direta pelo PDV, faz-se necess�ria a cria��o do campo L1_PRONFCE"
	STFShowMessage("STFStart")
	Return .F.

EndIf

If STFGetStation("NFCE") <> NIL .AND. STFGetStation("NFCE")
	AjustaSX5()	
EndIf

cIntegration := STFGetCfg("cIntegration", "DEFAULT")

If Valtype(cIntegration) <> "C"
	cIntegration := "DEFAULT"
EndIf   
lFirst := cIntegration  == "FIRST"

//retirada da chamada das fun��es STFVldCadEmp() e STFCadEmp()

//Integra��o First 
If lFirst .AND. !STFTypeOperation() == "DEMONSTRACAO"  
	AjustaSX6()	
	//Execu��o da rotina de carga de dados
		
	If lUpData
		STFMessage("UpData", "FWMSGRUN", STR0010, {|| STWUpData(  ,  , STFGetStat("CODIGO")) }) // "Executando subida de dados"
		STFShowMessage("UpData")
	EndIf
Endif

// Validacoes de usuario e estacao
If !STFVldUser(lMobile .AND. lFirst )
	Return .F.
EndIf

lLjNfPafEcf := STFGetCfg("lPafEcf")

If lLjNfPafEcf  .AND. ! LjEmitNFCe()
	If !LjGtIsPaf()
		MsgStop( STR0007 + " [SIGAPAF.exe]") //"Nos estados aonde � obrigat�rio o uso do PAF-ECF, o acesso deve ser realizado pelo execut�vel homologado"
		Return .F.
	EndIf
EndIf

//-------------------------------------------------------------------
// Permite o uso do sistema sem impressora fiscal 
lUsesNotFiscal := STFGetCfg("lUsesNotFiscal")

//Usa impressora fiscal
lFiscal := STFGetCfg("lUseECF")

If !lUsesNotFiscal

	//Abertura de Disposivitos
	lRet := STWOpenDevi() 

	If STFGetCfg("lUseECF") 
	
		If lRet
			STBNSrAval() 							//Verifica o numero de s�rie
			aRet := STFFireEvent(ProcName(0),"STPrinterStatus",	aDados)  
						
			If Len(aRet) > 0 .AND. aRet[1] == 0  .AND. Len(aDados) > 1  .AND. !Empty(aDados[2])
				//Verifica o numero de s�rie
				cCRO := aDados[2]
			EndIf  
		 
			aDados := {space(20), nil}
		
			aRet :=	STFFireEvent(	ProcName(0) ,"StGetReceipt", aDados )
			
			If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 0 .AND. !Empty(aDados[1])
				cCOO := PadL(AllTrim(aDados[1]), TamSX3("L1_DOC")[1])	
			EndIf
			
			If !Empty(cCRO) .AND. !Empty(cCOO) 
				STBSerieAlt( cCOO, cCRO  )
			EndIf
			
			//Grava no INI as configura��es de Arredondamento do ECF
			If ExistFunc("STBTaxDec") .AND. !lAutomato     
				STBTaxDec("1") // 1 = Grava no  ini , 2 = Recupera informacao do ini
			EndIf			
			
		Else
			
			//Se for PAf ECF e nao conseguiu abrir os perifericos
			//Abre a tela inical so com o menu fiscal
			If lLjNfPafEcf
				//Seta o a configuracao para somente Menu fiscal
				STFSetCfg( "lOnlyMenuFiscal" , .T. )
				//Retorna .T. mesmo nao abrindo os perifericos
				lRet := .T.
			EndIf			  
		EndIf
		
		//Chama rotina para armazenar MD-5 do arquivo paflista.txt no arquivo criptografado, para utilizar na impressao do Cupom 
		//Requisito IX: "...gravar o resultado no arquivo auxiliar criptografado"
		If lLjNfPafEcf .AND. LjGtIsPaf()  .AND. !LjEmitNFCe()
			STBGrvMd5Ls(.T.)
			STWValGT(.T.)
			
			//Homologacao 2017 - ER-PAF-ECF 02.05
			If ExistFunc("STBIniPAF")
				lRet := STBIniPAF( .T. , .F.)
			EndIf
		EndIf

	Else
		/* Nao utiliza impressora nao fiscal*/
		
		STBNSrAval() 	//Verifica o numero de s�rie      
		//Carrega as configuracoes globais logo no inicio
		oSTConfig:LoadConfig()  // Carrega configuracoes gerais
	EndIf
EndIf

//Inicializa componentes da venda
If lRet

 	STDInitPBasket()			// Inicializa Cesta
	STFTotUpd()		   		// Inicializa Totalizador
	STWCurrency() 	  		// Define Moeda Corrente Padr�o
	STWMRIniVal()				// Verifica��o Registro de Midia
	STBStartTax()				// Inicia Fun��es fiscais
	
	/* Limpa informacoes do objeto de Garantia Estendida */
	If ExistFunc("STWItemGarEst")
		STWItemGarEst(3) //(1=Set - 2=Get - 3=Clear)
	EndIf

	/* Tratamento Servico Financeiro */
	If lFinServ
		STWItemFin(3) 			// Limpa informacoes do objeto de Servi�os Financeiros (1=Set - 2=Get - 3=Clear)
	EndIf

EndIf

If lRet .AND. !lUsesNotFiscal .AND. !STFGetCfg( "lOnlyMenuFiscal" )
	
	If !STWRecoverySale( @lEmptySale )
		If !lEmptySale 
			/*/
				Verifica cupom aberto. Caso haja um cupom aberto que nao pode ser recuperado o mesmo sera cancelado.
			/*/	
			aRet := STFFireEvent( ProcName(0),"STPrinterStatus",{ "5" , "" } )
			If Len(aRet) > 0 .AND. ValType(aRet[1]) == "N" .AND. aRet[1] == 7 
				STWCancelSale( .T. )
			EndIf
		EndIf
	EndIf
	
EndIf

//���������������������������������������������������������������������������������Ŀ
//�Se nao logar como admin, verifica se existe carga do server, para ser baixada    �
//�����������������������������������������������������������������������������������
If (RetCodUsr() <> "000000") .AND.  SuperGetMV("MV_LJILOLE",,"0") == "1" .And. ExistFunc("LOJA1157EXPRESS")
	LOJA1157Express()
EndIf


If !SuperGetMV("MV_LJPESPC",,.F.)
	If lRet .AND. ExistFunc("STDStartProd")
		If lJobConPrd
			StartJob("STDJobCPrd", GetEnvServer(), .F., cEmpAnt, cFilAnt)
		Else
			MsgRun ( STR0005, STR0006, { || STDStartProd() } ) // "Inicializando! Esse processo pode levar alguns minutos..." ### "Aguarde"
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STFGetCfg
Pega as configuracoes do parametro solicitado 
@param   	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Self
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFGetCfg( cParam , xDefault )

Local uRet			:= Nil  // Parametro a ser retornado

Default cParam 		:= ""
Default xDefault 	:= Nil

If !Empty(cParam) .AND. Type("oSTConfig:" + cParam) <> "U"
	uRet := &( "oSTConfig:" + cParam )
EndIf

// tratamento para usar o valor default
If ValType(uRet) == "U" .AND. ValType(xDefault) <> "U"
	uRet := xDefault
EndIf

Return uRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFSetCfg
Seta as configuracoes do parametro solicitado 
@param   	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Self
@obs     Cuidado ao alterar esse conteudo pois o mesmo � refletido para todo sistema
@sample
/*/
//-------------------------------------------------------------------
Function STFSetCfg( cParam , uValue )

Local uRet 		:= Nil  // Parametro a ser retornado

Default cParam := ""
Default uValue := Nil

If !Empty(cParam) .AND. Type("oSTConfig:" + cParam) <> "U" .AND. ValType(uValue) <> "U"

	//Macroexecuta	
	&("oSTConfig:" + cParam) := uValue	
	
EndIf

Return uRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFVldUser
Verifica diversas atributos para liberar o acesso a venda 
para o caixa que esta tentando entrar na rotina de venda
@param  lMobFrst - Usu�rio Mobile e First (default .f.) 	
@author  Varejo
@version P11.8
@since   07/05/2012
@return  Retorna se permiti abrir o sistema 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFVldUser(lMobFrst)

Local lRet 				:= .T.			//Retorno
Local aAreaSLF			:= {}             //WorkArea SLF
Local cStrAcesso		:= ""				//Acessos do Totvs PDV, exceto gaveta
Local aRet				:= {}  

Default lMobFrst := .F. 

// Se for administrador nao deixa fazer a venda 
If __cUserID == "000000"
	
	MsgInfo( STR0002			+; // O administrador nao podera efetuar vendas. Utilize a opcao
				STR0003 		+; // Senhas/Caixas no Menu Miscelanea para incluir um Caixa. Caso
				STR0004  	)  // ja exista um cadastrado, reentre no sistema com a senha de Caixa
	lRet := .F.
EndIf

If lRet
	aRet := STFProFile( 3 )	//Valida se usuario eh caixa (SLF-3 - Usuario Caixa)
		
	If !aRet[1]
		MsgInfo( STR0035+SA6->A6_COD+STR0036 +Chr(13)+; 	//"Usu�rio logado [Caixa:" ## "] n�o possui permiss�o de Caixa."
				  STR0037+Chr(13)+;							//"Verifique na rotina de Caixas (LOJA120) a permiss�o para o acesso: Usu�rio Caixa."
				  STR0038)										//"(Totvs PDV n�o ser� iniciado)" 
		lRet := .F.
	EndIf
EndIf

// A ocorrencia 25 (ACS), verifica se o usuario 
// podera ou nao efetuar um Atendimento        
If lRet
	If !ChkPsw(25)
		lRet := .F.
	EndIf
EndIf


// Validacoes de estacao e caixa
If lRet

	xNumCaixa()
	DbSelectArea("SLF")
	DbSetOrder(1)
	If lMobFrst .AND. DbSeek(xFilial("SLF")+SA6->A6_COD)
		aAreaSLF := GetArea()
		cStrAcesso := LF_ACESSO
		

		
		If Empty(cStrAcesso) .OR. LF_DESCPER = 0 .OR. LF_DESCVAL = 0 .OR. LF_TOTDESP = 0 .OR. LF_TOTDESP = 0 .OR. LF_TOTDESV = 0 
	
			RecLock("SLF", .F.)
			Replace LF_ACESSO With replicate("S", SLF->(TamSX3("LF_ACESSO")[1]))

			Replace LF_DESCPER With  Val(replicate("9", SLF->(TamSX3("LF_DESCPER"))[1]-1 ))/(10**SLF->(TamSX3("LF_DESCPER"))[2])
			
			Replace LF_TOTDESP With Val(replicate("9", SLF->(TamSX3("LF_TOTDESP"))[1]-1 ))/(10**SLF->(TamSX3("LF_TOTDESP"))[2])
			
			Replace LF_DESCVAL With  Val(replicate("9", SLF->(TamSX3("LF_DESCVAL"))[1]-1 ))/(10**SLF->(TamSX3("LF_DESCVAL"))[2])
			
			Replace LF_TOTDESV With  Val(replicate("9", SLF->(TamSX3("LF_DESCVAL"))[1]-1 ))/(10**SLF->(TamSX3("LF_DESCVAL"))[2])
			
			SLF->(MsUnLock())
			
			//Realimenta configura��es
			oSTConfig:LoadConfig() 
	
		EndIf 

		

	ElseIf lMobFrst
		Help(" ",1,"NOESTACAO")
		lRet := .F.	
	EndIf

	If Empty(cEstacao)
		cEstacao := "001"
	EndIf
	
	DbSelectArea("SLG")
	If !DbSeek(xFilial("SLG")+cEstacao)
		Help(" ",1,"NOESTACAO")
		lRet := .F.
	EndIf
	
EndIf	

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AjstSX6Mbl
Cria��o de par�metros se PDV for Mobile
@param   	
@author  Varejo
@version P11.8
@since   28/04/2015
@return   
@obs     
@sample
/*/
//-------------------------------------------------------------------

Static Function AjstSX6Mbl()
Local aArea := GetArea() //WorkArea
Local aSX6		:= {} //Parametros
Local nI		:= 0 //Contadora
Local nX		:= 0 //Contadora


aEstru := { "X6_FIL"    , "X6_VAR"  , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , "X6_DSCSPA1",;
             "X6_DSCENG1", "X6_DESC2", "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG", "X6_PROPRI" , "X6_PYME" }

			 
///		   				X6_FIL,			X6_VAR	,X6_TIPO,	X6_DESCRIC		,				X6_DSCSPA		,			X6_DSCENG		,				X6_DESC1		,X6_DSCSPA1	,X6_DSCENG1	,X6_DESC2		,X6_DSCSPA2	,X6_DSCENG2 ,	X6_CONTEUD	,X6_CONTSPA	,X6_CONTENG	,X6_PROPRI	,X6_PYME
aAdd(aSX6,{ Space(FWSIZEFILIAL()),"MV_LJRETIN","C"	, STR0011,							STR0011,					STR0011,""				,""				,""				,""				,""				,""				,"FIRST"		,""		,""		,"S"		,"S"}) //"Retaguarda da Integra��o"
aAdd(aSX6,{ Space(FWSIZEFILIAL()),"MV_LJEMPPK","C"	, STR0012,							STR0012,					STR0012,""				,""				,""				,""				,""				,""				,"edWAil9NxzyzJb0IRbVIgQ=="		,""		,""		,"S"		,"S"}) //"Codigo da Empresa Parceira - Daruma Migrate"
aAdd(aSX6,{ Space(FWSIZEFILIAL()),"MV_LJEMPCK","C"	, STR0013,							 STR0013,					STR0013,""				,""				,""				,""				,""				,""				,""		,""		,""		,"S"		,"S"}) //"Codigo da Empresa - Daruma Migrate"
aAdd(aSX6,{ Space(FWSIZEFILIAL()),"MV_NFCEIDT","C"	, STR0018,							 STR0018,					STR0018,""				,""				,""				,""				,""				,""				,"000001"		,""		,""		,"S"		,"S"}) //"ID Token (SCS) fornecido ao Cliente pelo SEFAZ."
//PARA TESTES ESTE AMBIENTE � 3 DESENVOLVIMENTO, MAS DEVE SER CONFIGURADO COMO 1 - PRODUCAO  
aAdd(aSX6,{ Space(FWSIZEFILIAL()),"MV_AMBNFCE","C"	, STR0019,							STR0019,					STR0019,STR0020				,STR0020				,STR0020				,""				,""				,""				,"1"		,""		,""		,"S"		,"S"}) //"Define Ambiente 1=Produ��o,2=Homologa��o," "3=Desenvolvimento(Daruma Migrate)"
aAdd(aSX6,{ Space(FWSIZEFILIAL()),"MV_LJNFCET","N"	, STR0021,							STR0021,					STR0021,""				,""				,""				,""				,""				,""				,"10"		,""		,""		,"S"		,"S"}) // "TimeOut(seg) do WebService NFCe TotvsApi"
aAdd(aSX6,{ Space(FWSIZEFILIAL()),"MV_LJQTITE","N"	, STR0022,							STR0022,					STR0022,""				,""				,""				,""				,""				,""				,"9"		,""		,""		,"S"		,"S"}) //"Qtd inicial de itens na grid do TOTVS PDV"

dbSelectArea("SX6")
SX6->(dbSetOrder(1))
For nI := 1 to Len(aSX6)
	IncProc()
	If !SX6->(dbSeek(aSX6[nI][1] + PadR(aSX6[nI][2],Len(SX6->X6_VAR))))
		RecLock("SX6",.T.)
		For nX := 1 to Len(aEstru)
			If SX6->(FieldPos(aEstru[nx])) > 0
				SX6->&(aEstru[nX]) := aSX6[nI][nX]
			Endif
		Next nX
		dbCommit()
		MsUnlock()
	Endif 	

Next nI	

RestArea(aArea)


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX6
Cria��o de par�metros se PDV for First
@param   	
@author  Varejo
@version P11.8
@since   28/04/2015
@return   
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function AjustaSX6()
Local aArea := GetArea() //WorkArea
Local aSX6		:= {} //Parametros
Local nI		:= 0 //Contador
Local nX		:= 0 //Contador


aEstru := { "X6_FIL"    , "X6_VAR"  , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , "X6_DSCSPA1",;
             "X6_DSCENG1", "X6_DESC2", "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG", "X6_PROPRI" , "X6_PYME" }

			 
///		   X6_FIL,X6_VAR	,X6_TIPO,X6_DESCRIC		,X6_DSCSPA		,X6_DSCENG		,X6_DESC1		,X6_DSCSPA1		,X6_DSCENG1		,X6_DESC2		,X6_DSCSPA2		,X6_DSCENG2 ,X6_CONTEUD	,X6_CONTSPA	,X6_CONTENG	,X6_PROPRI	,X6_PYME
aAdd(aSX6,{ Space(FWSIZEFILIAL()),"MV_LJFRSET","C"	, STR0014,	STR0014,STR0014,""				,""				,""				,""				,""				,""				,""		,""		,""		,"S"		,"S"}) //"Token da Integra��o First"
aAdd(aSX6,{ Space(FWSIZEFILIAL()),"MV_LJFRSEP","C"	, STR0015,STR0015,STR0015,""				,""				,""				,""				,""				,""				,""		,""		,""		,"S"		,"S"}) //"Codigo da Entidade PDV"
aAdd(aSX6,{ Space(FWSIZEFILIAL()),"MV_LJFRSEF","C"	, STR0016,STR0016,STR0016,""				,""				,""				,""				,""				,""				,""		,""		,""		,"S"		,"S"}) //"Codigo da Entidade First"
aAdd(aSX6,{ Space(FWSIZEFILIAL()),"MV_LJFRFIL","N"	, STR0017,STR0017,STR0017,""				,""				,""				,""				,""				,""				,"4"		,""		,""		,"S"		,"S"}) //"Tamanho do campo filial no First"
aAdd(aSX6,{ Space(FWSIZEFILIAL()),"MV_LJFILIN","C"	, STR0023,STR0023,STR0023,""				,""				,""				,""				,""				,""				,"01"		,""		,""		,"S"		,"S"}) //"Filial da Integra��o"



dbSelectArea("SX6")
SX6->(dbSetOrder(1))
For nI := 1 to Len(aSX6)
	IncProc()
	If !SX6->(dbSeek(aSX6[nI][1] + PadR(aSX6[nI][2],Len(SX6->X6_VAR))))
		RecLock("SX6",.T.)
		For nX := 1 to Len(aEstru)
			If SX6->(FieldPos(aEstru[nx])) > 0
				SX6->&(aEstru[nX]) := aSX6[nI][nX]
			Endif
		Next nX
		dbCommit()
		MsUnlock()
	Endif 	

Next nI	

RestArea(aArea)


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX5
Cria��o de tabelas para numeradores NFCe
@param   	
@author  Varejo
@version P11.8
@since   28/04/2015
@return   
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function AjustaSX5()
Local aArea := GetArea() //WorkArea
Local nTamTab   := Len( SX5->X5_TABELA) //Tabela
Local cSerie	 := SuperGetMv("MV_LJSERE5", .F., "SE5")	//Serie da Sangria/Suprimento de ECNF		
Local cSerieNF := STFGetStat("SERIE") //Serie da Esta��o
Local aSX5      := {} //Campos SX5
Local nI        := 0 //Contador 1
Local nJ        := 0 //Contador


aEstrut := { "X5_FILIAL", "X5_TABELA", "X5_CHAVE", "X5_DESCRI", "X5_DESCSPA", "X5_DESCENG" }

aAdd( aSX5, { ;
	Space(FWSIZEFILIAL())																	, ; //X5_FILIAL
	PadR('01',nTamTab)																	, ; //X5_TABELA
	cSerie																	, ; //X5_CHAVE
	'000001'																	, ; //X5_DESCRI
	'000001'																	, ; //X5_DESCSPA
	'000001'																	} ) //X5_DESCENG
	
If !Empty(cSerieNF)
	aAdd( aSX5, { ;
		Space(FWSIZEFILIAL())																	, ; //X5_FILIAL
		PadR('01',nTamTab)																	, ; //X5_TABELA
		cSerieNF																	, ; //X5_CHAVE
		'000001'																	, ; //X5_DESCRI
		'000001'																	, ; //X5_DESCSPA
		'000001'																	} ) //X5_DESCENG
EndIf

dbSelectArea( "SX5" )
SX5->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSX5 )


	If !SX5->( dbSeek( aSX5[nI][1] + aSX5[nI][2] + aSX5[nI][3]) )
		RecLock( "SX5", .T. )
		For nJ := 1 To Len( aSX5[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX5[nI][nJ] )
			EndIf
		Next nJ
	
		MsUnLock()

	EndIf


Next nI

RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STFCheckCo
Fun��o responsavel por realizar o teste de conex�o com a retaguarda (o teste � realizado em backgroud, n�o influencia na venda)

@author  	Lucas Novais
@version 	P12.1.27
@since   	18/03/2020
@param   	cEmp, Caracter, Empresa para abertura de ambiente
@param   	cFil, Caracter, Filial para abertura de ambiente 
@return		Nil, Nulo	  
/*/
//-------------------------------------------------------------------

Function STFCheckCo(cEmp,cFil)
Local lConnHost 	:= .F.	// -- Variavel local que indica se existe comunica��o com a retaguarda					
Local lPosOpen		:= .T.	// -- Indica se o TOTVS PDV esta aberto (STIPOSMAIN)

// -- Necessario abertura de ambiente devido ao uso da fun��o FWHostPing()
RPCSetType(3)
PutGlbVars("lConnHost", .F.)  
lOpenEnv :=  RpcSetEnv(cEmp,cFil,Nil,Nil,"FRT")

If lOpenEnv

	PutGlbVars("lPosOpen", .T.) // -- Indica que o PDV esta aberto.

	While lPosOpen // -- Enquanto o PDV continuar aberto continuo testando a comunica��o, a variavel Global lPosOpen � alimentada com .F. no STFExit
		lConnHost := FWHostPing()
		PutGlbVars("lConnHost", lConnHost)
		Sleep(10000)
		GetGlbVars( "lPosOpen",  @lPosOpen)
	End
	
	// -- Caso saia da tela do TOTVS PDV limpo as variaveis de memoria. 
	ClearGlbValue("lConnHost")
	ClearGlbValue("lPosOpen")
	RpcClearEnv()

EndIf 

Return 
