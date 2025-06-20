#Include "CTBA211.CH"
#Include "PROTHEUS.CH"
#Include "FWLIBVERSION.CH"

STATIC lGravouLan	:= .F.
STATIC nTamCta	:= TAMSX3("CT1_CONTA")[1]
STATIC nTamCC	:= TAMSX3("CTT_CUSTO")[1]
STATIC nTamItem	:= TAMSX3("CTD_ITEM")[1]
STATIC nTamClVl	:= TAMSX3("CTH_CLVL")[1]

STATIC cSpacCt	:= REPLICATE(" ",nTamCta)
STATIC cSpacCC	:= REPLICATE(" ",nTamCC)
STATIC cSpacIt	:= REPLICATE(" ",nTamItem)
STATIC cSpacCl  := REPLICATE(" ",nTamClVl)

STATIC cArqTrb	:= ""
STATIC cArqIND1	:= ""
STATIC cArqIND2	:= ""
STATIC nMAX_LINHA := CtbLinMax(GetMv("MV_NUMLIN"))

STATIC __cKeyCTZATU := ""
STATIC __cSeqLICTZ 	:= ""

STATIC __aJaFlag := {}
STATIC __aDocsLP := {}

STATIC __lOKCusto := .F.
STATIC __lOKItem := .F.
STATIC __lOKClasse := .F.
STATIC __lOKEnt05 := .F.

STATIC _oCTBA2111
STATIC _lBlind := IsBlind()

Static nCA211Cnt	:= 0

// Manejo de entidad 05
Static lEntidad05   := (cPaisLoc $ "COL|PER" .And. CtbMovSaldo("CT0",,"05") .And. FWAliasInDic("QL6") .And. FWAliasInDic("QL7")) // Manejo de entidad 05
Static nTamE05	    := IIf(FWAliasInDic("QL6") .And. FWAliasInDic("QL7"), GetSx3Cache("QL6_ENT05","X3_TAMANHO"),0)
Static cSpacE05	    := IIf(FWAliasInDic("QL6") .And. FWAliasInDic("QL7"), Replicate(" ",nTamE05),"")

//Metricas apenas em Lib a partir de 20210517 e Binario 19.3.0.6
Static __lMetric	:= FwLibVersion() >= "20210517" .And. GetSrvVersion() >= "19.3.0.6"
Static __lCtbLgAp := SuperGetMV("MV_CTBLGAP", .F. , "0" ) == '1' //gera log de execu玢o / default 0 nao gera


/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯TBA211   � Autor � Marcos S. Lobo        � Data � 26.09.06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Apuracao de Resultados -Lucros/Perdas	                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � Ctba211()                                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Ctba211                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function CTBA211(lAuto)
Local aSays 		:= {}
Local aButtons		:= {}
LOCAL nOpca    		:= 0
Local cMens			:= ""
Local oProcess
Local cFunction		:= "CTBA211"
Local cPerg			:= "CTB211"
Local cTitle		:= STR0001	// "Apuracao de Lucros / Perdas"
Local cDescription	:= 	STR0002 + CRLF + CRLF +;	//"Esta rotina ir� gerar os lancamentos contabeis de lucros e perdas."
						STR0015 + CRLF +;	//"Recomenda-se a verifica玢o pr関ia ou reprocessamento de saldos antes "
						STR0016 + CRLF +;	//"de executar esta rotina."
						STR0017 + CRLF +;	//"Visualizar, para o Log de processamento"
						STR0018 // "Ordem, para sequencia de apura珲es ja processadas"
Local aInfoCustom	:= {}
Local lExclusivo := IIF(FindFunction("ADMTabExc"), ADMTabExc("CT2") , !Empty(xFilial("CT2") ))
Local bProcess		:= { }
Private cCadastro 	:= OemToAnsi(STR0001)  //"Apuracao de Lucros / Perdas"
PRIVATE cString   	:= "CT2"
PRIVATE cDesc1    	:= OemToAnsi(STR0002)  //"Esta rotina ir� gerar os lancamentos contabeis de lucros e perdas."
PRIVATE cDesc2    	:= ""
PRIVATE cDesc3    	:= ""
PRIVATE titulo    	:= OemToAnsi(STR0003)  //"Simulacao da Apuracao"
PRIVATE cCancel   	:= OemToAnsi(STR0004)  //"***** CANCELADO PELO OPERADOR *****"
PRIVATE nomeprog  	:= "CTBA211"
PRIVATE aLinha    	:= { },nLastKey := 0

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

//Verifica se o CT2 � compartilhado


//Atualizar o arquivo SX5 com o flag de apuracao, apenas se for execu玢o da 12.1.017
If GetRPORelease() <= "12.1.017"
	Ct210UpdX5()
EndIf

If GetNewPar("MV_ATUSAL","S") == "N"
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Mostra tela de aviso - Verificar se os saldos foram atualizados.�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	cMens := OemToAnsi(STR0011)+chr(13)  //"CASO A ATUALIZACAO DOS  SALDOS BASICOS  NAO  SEJA  FEITA  NA "
	cMens += OemToAnsi(STR0012)+chr(13)  //"DIGITACAO DOS LANCAMENTOS (MV_ATUSAL = 'N'), FAVOR VERIFICAR "
	cMens += OemToAnsi(STR0013)+chr(13)  //"SE OS SALDOS ESTAO ATUALIZADOS !!!!"

	MsgInfo(cMens,OemToAnsi(STR0014))  //"ATEN�嶰"
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Variaveis utilizadas para parametros                         �
//� mv_par01 // Data Inicial de Apuracao                         �
//� mv_par02 // Data de Apuracao                                 �
//� mv_par03 // Numero do Lote			                         �
//� mv_par04 // Numero do SubLote		                         �
//� mv_par05 // Numero do Documento                              �
//� mv_par06 // Cod. Historico Padrao                            �
//� mv_par07 // Da Conta  		        						 �
//� mv_par08 // Ate a Conta                             		 �
//� mv_par09 // Moedas        			                         �
//� mv_par10 // Qual Moeda?                                      �
//� mv_par11 // Considera Entidades Pontes                       �
//� mv_par12 // Tipo de Saldo 				                     �
//� mv_par13 // Considera Entidades de Apuracao?Cadastro/Rotina  �
//� mv_par14 // Conta Ponte   				                     �
//� mv_par15 // Conta de Apuracao de Resultados                  �
//� mv_par16 // C.Custo Ponte 				                     �
//� mv_par17 // C.Custo de Apuracao de Resultados                �
//� mv_par18 // Item Ponte    				                     �
//� mv_par19 // Item de Apuracao de Resultados                   �
//� mv_par20 // Cl. Valor Ponte				                     �
//� mv_par21 // Cl. Valor de Apuracao de Resultados              �
//� mv_par22 // Do C.Custo		        						 �
//� mv_par23 // Ate o C.Custo                           		 �
//� mv_par24 // Do Item Contabil	    						 �
//� mv_par25 // Ate o Item Contabil                     		 �
//� mv_par26 // Da Classe de Valor	    						 �
//� mv_par27 // Ate a Classe de Valor                     		 �
//� mv_par28 //Reproces. Saldos   ?
//� mv_par29 // Seleciona Filiais?	                     		 �
//� mv_par30 // Filial De	                     		 �
//� mv_par31 // Filial Ate	                     		 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Pergunte("CTB211",.F.)

Aadd( aInfoCustom, { STR0048, { |oCenterPanel| A211Ordem(oCenterPanel) }, "PROCESSA", { {} , {} } } )

If !lAuto

	bProcess := { |oSelf| If(MV_PAR29==1 .And. lExclusivo , ;// Seleciona filiais
								CTB211Fil(Nil,oSelf,MV_PAR30,MV_PAR31);
								, ;//Else
								Ctb211Proc(oProcess,oSelf) ;
							) }
	tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg, aInfoCustom )
Else
	Ctb211Proc(oProcess,oSelf,lAuto)
Endif

__lOKCusto 	:= .F.
__lOKItem 	:= .F.
__lOKClasse := .F.
__lOKEnt05	:= .F.

nCA211Cnt	:= 0

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矯tb211Fil 篈utor  矨lvaro Camillo Neto � Data �  21/09/09   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矱xecuta o processamento para cada filial                    罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � CTBA211                                                   罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function Ctb211Fil(oProcess,oSelF,cFilDe,cFilAte)
Local cFilIni 	:= cFIlAnt
Local aArea		:= GetArea()
Local aSM0 		:= Iif( FindFunction( "AdmAbreSM0" ) , AdmAbreSM0() , {} )
Local nContFil 	:= 0
Local cFilProc	:= "" // Variavel de controle

//Validar se foi executado o Conciliador Contabil - CTBA940
If GetRPORelease() >= "12.1.033"  .and. cPaisLoc=='BRA' .and. !VlConcil(mv_par01, mv_par02) 
   Return
EndIf

If Len( aSM0 ) > 0
	For nContFil := 1 to Len(aSM0)
		If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt
			Loop
		EndIf

		cFilAnt := aSM0[nContFil][SM0_CODFIL]
		If Alltrim(cFilProc) != Alltrim(xFilial("CT2"))
			cFilProc:= xFilial("CT2")
		Else
			Loop
		EndIf
        If __lCtbLgAp
			oSelf:SaveLog( STR0046 + cFilAnt)//"MENSAGEM: EXECUTANDO A APURACAO DA FILIAL "
		EndIf

		Ctb211Proc(oProcess,oSelf)
	Next nContFil

	cFIlAnt := cFilIni
Else
	ProcLogAtu("ERRO","Aten玢o!","Nenhuma empresa/filial encontrada. Verique se est� utilizando a ultima vers鉶 do ADMXFUN (MAR/2010)" )
Endif

RestArea(aArea)

Return Nil

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯tb211Proc� Autor � Marcos S. Lobo        � Data � 26.09.06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 砕eramento de Lucros/Perdas.                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � CTB211Proc()                                               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Ctba211                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function Ctb211Proc(oObj,oSelf,lAuto)
Local nx
Local dLastProc
Local dDataILP		:= mv_par01		//Data Inicial de Apura玢o
Local dDataFLP		:= mv_par02		//Data Final de Apuracao
Local cLote 		:= mv_par03		//Num. do lote que sera gerado os lancamentos
Local cSubLote		:= mv_par04		//Num. do sublote que sera gerado os lancamentos
Local cDoc			:= mv_par05		//Num. do doc. que sera gerado os lancamentos
Local nLinha		:= 0
Local cLinha		:= '000'
Local cLinhaLan		:= '001'
Local cSeqLan		:= "001"
Local lFirst 		:= .T.
Local cLoteAtu 		:= cLote
Local cSubAtu		:= cSubLote
Local cDocAtu		:= cDoc
Local cKeyEntAtu	:= ""
Local nRecLanAtu	:= 0
Local nRecLan		:= 0
Local nOpcGRV 		:= 3			/// 3 = INCLUI LANCAMENTO / 4 = ALTERA
Local cKeyDocLP		:= ""			/// CHAVE DO DOCUMENTO ATUAL DE APURACAO
Local nRecLinha		:= 0
Local nVlrCTZ		:= 0			/// VALOR DO LANCAMENTO NO CTZ (VALOR DO CT2 PODE SER SOMADO X vezes)
Local cHP			:= mv_par06		//Historico Padrao utilizado nos lancamentos
Local cContaIni		:= mv_par07		//Conta Inicial
Local cContaFim		:= mv_par08		//Conta Final
Local cCustoIni		:= mv_par22		//C.Custo Inicial
Local cCustoFim		:= mv_par23		//C.Custo Final
Local cItemIni		:= mv_par24		//Item Inicial
Local cItemFim		:= mv_par25		//Item Final
Local cClVlIni		:= mv_par26		//Classe Inicial
Local cClVlFim		:= mv_par27		//Classe Final
Local lMoedaEsp		:= Iif(mv_par09==2,.T.,.F.)	//Moedas
Local cMoeda		:= StrZero(Val(mv_par10),2)			//Define qual a moeda especifica
Local lPontes		:= Iif(mv_par11 == 1,.T.,.F.) //Considera Entidades Pontes
Local lCadastro		:= Iif(mv_par13 == 1,.T.,.F.)	//Consdera Endidades Pontes/Lp dos Cadastros
Local cTpSaldo		:= mv_par12		//Tipo de Saldo.
Local lPergOk		:= .T.
Local lClVl			:=	CtbMovSaldo("CTH")
Local lItem			:=	CtbMovSaldo("CTD")
Local lCusto		:= 	CtbMovSaldo("CTT")
Local aCtbMoeda 	:= {}
Local nInicio		:= 0
Local nFinal		:= 0
Local cDescHP		:= ""
Local dDataAILP		:= dDataILP-1	/// DATA ANTERIOR � INICIAL DE LUCROS E PERDAS
Local dDataIRep		:= dDataFLP		/// DATA INI REPROC. IGUAL DATA FINAL DE APURACAO (ENQUANTO AINDA ESTA SEM A FUNCAO CTBGRAVSALDO)
Local dDataFRep		:= dDataFLP		/// REPROCESSAMENTO DE SALDOS DEVE SER SEMPRE AT� A DATA DE APURACAO -> POSTERIOR � APENAS ACUMULADO
Local cCampo		:= ""
Local lJaExec := .F.
Local lSlbase		:= Iif(GETMV("MV_ATUSAL")=="N",.F.,.T.)
Local nIndTmp		:= 0
Local lCtbCCLP	:= Iif(ExistBlock("CTB211CC"),.T.,.F.)
Local lCtbItLP 	:= Iif(ExistBlock("CTB211IT"),.T.,.F.)
Local lCtbCVLP 	:= Iif(ExistBlock("CTB211CV"),.T.,.F.)
Local lRetSaldo	:= .T.

////////////////////////////////////////////////////////////////////////////////////////
Local lObj		:= ValType(oObj) == "O"
Local cExerc	:= alltrim(str(Year(dDataFLP),4))
Local cFilCTG	:= ""
Local nMoed		:= 1
Local cMoed		:= "01"
Local nTpSld	:= 1
Local lJaProc 	:= .F.			/// SE A ROTINA J� COMECOU A TRANSFERIR REGISTROS P/ CV6 OU N肙
Local lCriaTRB	:= .T.			/// SE DEVE OU NAO CRIAR UM TRB NOVO
Local lNovoTRB	:= .T.			/// SE FOI CRIA
Local cTpSldAnt	:= ""
Local cMoedAnt	:= ""
Local CTF_LOCK	:= 0
Local nForaCols	:= 0
Local cClVlPon	:= cSpacCL
Local cItemPon	:= cSpacIT
Local cCCPon	:= cSpacCC
Local cCtaPon	:= cSpacCT
Local cClVlLP	:= cSpacCL
Local cItemLP	:= cSpacIT
Local cCCLP		:= cSpacCC
Local cCtaLP	:= cSpacCT
Local lClVlOk	:= .T.
Local lItemOk	:= .T.
Local lCCOk		:= .T.
Local lCtaOk	:= .T.
Local cDigPon	:= ""
Local cDigLP	:= ""
Local aCriter	:= {}         		/// CRITERIO DE CONVERSAO DA CONTA DE ORIGEM (FORA DE USO)
Local aCritLP	:= {}				/// CRITERIO DE CONVERSAO DA CONTA DE APURACAO (FORA DE USO)
Local aCritPon	:= {}               /// CRITERIO DE CONVERSAO DA CONTA PONTE (FORA DE USO)
Local aFilters	:= {}
Local lSaldo	:= .F.		/// INDICA SE APURACAO SERA PELO .F.->MOVIMENTO/.T. ->SALDO
Local lCTZDeb 	:= .F.
Local lGrvCT7		:= IIf(ExistBlock("GRVCT7"),.T.,.F.)
Local lGrvCT3		:= IIf(ExistBlock("GRVCT3"),.T.,.F.)
Local lGrvCT4		:= IIf(ExistBlock("GRVCT4"),.T.,.F.)
Local lGrvCTI		:= IIf(ExistBlock("GRVCTI"),.T.,.F.)
Local lAtuSldCT7	:= .T.
Local lAtuSldCT3	:= .T.
Local lAtuSldCT4	:= .T.
Local lAtuSldCTI	:= .T.
Local nK		:= 0
Local aOutrEntid
Local aEntid
Local lFiltra	:= .F.
Local lFilCT	:= .F.
Local lFilCC	:= .F.
Local lFilIT	:= .F.
Local lFilCL	:= .F.
Local lExclusivo := IIF(FindFunction("ADMTabExc"), ADMTabExc("CT2") , !Empty(xFilial("CT2") ))
Local nCtdSemaf  := 0
Local lReproc    := mv_par28 == 1
Local cMsgErroPg := ""
Local cIdioma    := Upper(Left(FWRetIdiom(), 2))

Local aMoedas	:= {}
Local cEntDeb05 := ""	// Entidad 05 D閎ito
Local cEntCrd05 := ""	// Entidad 05 Cr閐ito
Local cEnt05LP  := ""	// Entidad 05 C醠culo PyG
Local lEnt05Ok  := .T.	// C骴igo de Entidad 05 C醠culo PyG ok?
Local lResultado:= .T.	// .T. = C醠culo de Resultados (proceso est醤dar) / .F. = Cierre Cuentas de Balance terceros (Solo si lEntidad05 == .T.)

/*variavel criada para permitir visualiza玢o do lan鏰mento
 caso n鉶 tenha sido solicitada apura玢o na moeda 01*/
Local lApurMoeda1 := .F.

Private  aCols 		:= {} // Utilizada na conversao das moedas
Private cSeqCorr  := ""

Default oObj	:= Nil
Default oSelf	:= Nil

//inicializando as vari醰eis est醫icas para n鉶 ocorrer problemas de valores existentes
__aJaFlag 		:= {}
__aDocsLP 		:= {}

__cKeyCTZATU 	:= ""
__cSeqLICTZ		:= ""
//Fim da inicializa玢o das vari醰eis est醫icas

//Iniciar telemetria - Tempo m閐io
If __lMetric
	nStart := Seconds()
EndIf

If lGrvCT7
	lAtuSldCT7	:= ExecBlock("GRVCT7",.F.,.F.)
Endif
If lGrvCT3
	lAtuSldCT3	:= ExecBlock("GRVCT3",.F.,.F.)
Endif
If lGrvCT4
	lAtuSldCT4	:= ExecBlock("GRVCT4",.F.,.F.)
Endif
If lGrvCTI
	lAtuSldCTI	:= ExecBlock("GRVCTI",.F.,.F.)
Endif

If cPaisLoc == 'CHI' .and. Val(cLinha) < 2  // a partir da segunda linha do lanc., o correlativo eh o mesmo
	cSeqCorr := CTBSqCor( CTBSubToPad(cSubLote) )
EndIf

If MV_PAR29 == 1 .And. !lExclusivo .and. __lCtbLgAp
	oSelf:SaveLog(STR0057) //"TRATAMENTO MULTI FILIAL DESABILITADO: CT2 COMPARTILHADO"
EndIf

// Sub-Lote somente eh informado se estiver em branco
mv_par04 := Iif(Empty(GetMV("MV_SUBLOTE")), mv_par04, GetMV("MV_SUBLOTE"))

If lMoedaEsp					// Moeda especifica
	cMoeda	:= mv_par10
	aCtbMoeda := CtbMoeda(cMoeda)
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Atualiza o log de processamento com o erro  �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		oSelf:SaveLog(GtDescHelp("NOMOEDA"))
		Return
	EndIf
	nInicio := val(cMoeda)
	nFinal	:= val(cMoeda)
Else
	nInicio	:= 1
	nFinal	:= __nQuantas
EndIf

If Empty(mv_par01)
	mv_par01 := CTOD("01/01/80")
EndIf

cTpApu := IIf(lPontes,"P","Z")

If ( !lMoedaEsp )

	For nX := nInicio to nFinal
		aAdd(aMoedas,StrZero(nX,2))
	Next nX

Else
	aMoedas := {cMoeda}
Endif

// Trecho localizado COL|PER vari醰el static.
If lEntidad05
	// Asegurar que las tablas de saldos cubo est閚 creadas
	If FWAliasInDic("QL6") .And. FWAliasInDic("QL7")
		dbSelecTArea("QL6")
		dbSelecTArea("QL7")
		dbSelectArea("CT2")
	Else
		Help(NIL, NIL, STR0014, NIL, STR0138, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0125})	//"TENCION !"##"No existen las tablas de saldos por entidad 05."##"Antes debe crear las tablas de saldos contables de la entidad 05 (QL6 y QL7) a trav閟 del configurador de Protheus."
		// Atualiza o log de processamento com o erro
		oSelf:SaveLog(STR0138) //"No existen las tablas de saldos por entidad 05."
		lPergOk := .F.
	EndIf

	If cPaisLoc == "COL"
		If cContaIni >= "4" .And. cContaFim >= cContaIni .And. cContaFim < "8"
			// C醠culo de resultado
			lResultado := .T.
		ElseIf cContaFim >= cContaIni .And. (cContaFim < "4" .Or. cContaIni >= "8")
			// Cierre de Balance Terceros
			lResultado := .F.
		Else
			Help(NIL, NIL, STR0014, NIL, STR0139 + CRLF + STR0140 + CRLF + STR0141, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0142})	//"TENCION !"##"Los rangos de cuentas son incorrectos."##"Para C醠culo de Resultado, indique de la '4' hasta final de la '7'."##"Para Cierre de Cuentas de Balance de terceros, indique de la '1' hasta final de la '3'."##"Configure correctamente los par醡etros del proceso."
			// Atualiza o log de processamento com o erro
			oSelf:SaveLog(STR0139) //"Los rangos de cuentas son incorrectos."
			lPergOk := .F.
		EndIf
	EndIf

	If !lPergOk
		Return
	Endif
EndIf

If !lResultado //Trecho localizado COL|PER
	/*
		lResultado siempre es .T.; Solo cambia si cPaisLoc == "COL" y los par醡etros de cuentas indican que son de balance
	 */

	// Caso a tabela LP exista na tabela CW0 o processo ser� feito por ela e nao pela SX5
ElseIf CtLPCW0Tab()
	If !CtLPCW0Vdt(dDataFLP,@lJaExec,@lPergOk,cMoeda,cTpSaldo,lMoedaEsp,!_lBlind)
		Return(.F.)
	EndIf
Else
	Do Case
	Case cIdioma == "PT"
		cCampo	:= "SX5->X5_DESCRI"
	Case cIdioma == "ES"
		cCampo	:= "SX5->X5_DESCSPA"
	Case cIdioma == "EN"
		cCampo	:= "SX5->X5_DESCENG"
	EndCase
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� ANTES DE INICIAR O PROCESSAMENTO, VERIFICO OS PARAMETROS.	 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	//Data de Apuracao nao preenchida.
	If Empty(dDataFLP)
		Help(" ",1,"NOCTBDTLP")

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Atualiza o log de processamento com o erro  �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		oSelf:SaveLog(GtDescHelp("NOCTBDTLP"))
		Return(.F.)
	Else //Se a data estiver preenchida, verifica se ja foi rodado nessa data.
		dbSelectarea("SX5")
		dbSetOrder(1)
		If MsSeek(xFilial()+"LP"+cEmpAnt+cFilAnt)
			While !Eof() .and. SX5->X5_TABELA == "LP"
				If Subs(&(cCampo),1,8) == Dtos(dDataFLP)
					If (!lMoedaEsp .Or. (lMoedaEsp .And. Subs(&(cCampo),9,2) == cMoeda)) .And.;
							Subs(&(cCampo),11,1) == cTpSaldo
							If ! MsgYesNo(STR0008,OemToAnsi(STR0014+"Filial "+cFilAnt))
								Return(.F.)
							Else
								lJaExec := .T.
								Exit
							Endif
						EndIf
				Endif
				dbSkip()
			End
		EndIf
		//Verificar se o calendario da data solicitada esta encerrado
		lPergOk	:= CtbValiDt(1,dDataFLP,,cTpSaldo)
	Endif
EndIf

//Historico Padrao nao preenchido.
If Empty(cHP)
	Help(" ",1,"CTHPVAZIO")

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Atualiza o log de processamento com o erro  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	oSelf:SaveLog(GtDescHelp("CTHPVAZIO"))
	lPergOk := .F.
Else
	dbSelectArea("CT8")
	dbSetOrder(1)
	MsSeek(xFilial("CT8")+cHP)
	If found()
		cDescHP 	:= CT8->CT8_DESC
	Else
		//Historico Padrao nao existe no cadastro.
	   	Help(" ",1,"CT210NOHP",,"FILIAL "+cFilAnt,2,0)

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Atualiza o log de processamento com o erro  �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		oSelf:SaveLog(GtDescHelp("CT210NOHP"))
		lPergOk := .F.
	Endif
Endif

//Lote nao preenchido.
If Empty(cLote)
	Help(" ",1,"NOCT210LOT")

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Atualiza o log de processamento com o erro  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	oSelf:SaveLog(GtDescHelp("NOCT210LOT"))
	lPergOk := .F.
Endif

//Sub Lote nao preenchido.
If Empty(cSubLote)
	Help(" ",1,"NOCTSUBLOT")

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Atualiza o log de processamento com o erro  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	oSelf:SaveLog(GtDescHelp("NOCTSUBLOT"))
	lPergOk := .F.
Endif

//Documento nao preenchido.
If Empty(cDoc)
	Help(" ",1,"NOCT210DOC")

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Atualiza o log de processamento com o erro  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	oSelf:SaveLog(GtDescHelp("NOCT210DOC"))
	lPergOk := .F.
Else	//Se o documento estiver preenchido, verifico se existe lancamento com mesmo numero
		//de lote, sublote, documento e data
	dbSelectArea("CT2")
	dbSetOrder(1)

//	If ! lJaExec .And. MsSeek(xFilial()+dtos(dDataFLP)+cLote+cSubLote+cDoc)

	If MsSeek(xFilial()+dtos(dDataFLP)+cLote+cSubLote+cDoc)
		lPergOk := .F.
		MsgAlert(OemtoAnsi(STR0009))//Data+Lote+Sublote+documento ja existe.
    Endif

	If !lResultado .And. lPergOk //Trecho localizado COL|PER
		// Cierre cuentas de balance (COL). Validar que no duplique Lote + Sublote
		If MsSeek(xFilial()+DtoS(dDataFLP)+cLote+cSubLote, .T.)
			Help(NIL, NIL, STR0014, NIL, STR0146 + cLote + " - " + cSubLote, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0147})	//"TENCION !"##"Ya existe uno o m醩 documentos del Lote y Sublote "##"Si desea hacer rec醠culo de cuentas de balance, antes debe revertir el c醠culo correspondiente."
			lPergOk := .F.
		EndIf
	EndIf
Endif

//Conta Inicial e Conta Final nao preenchidos.
If Empty(cContaIni) .And. Empty(cContaFim)
	Help(" ",1,"NOCT210CT")

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Atualiza o log de processamento com o erro  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	oSelf:SaveLog(GtDescHelp("NOCT210CT"))
	lPergOk := .F.
Endif

//Se for moeda especifica, verificar se a moeda esta preenchida
If lMoedaEsp
	If Empty(cMoeda)
		Help(" ",1,"NOCTMOEDA")

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Atualiza o log de processamento com o erro  �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		oSelf:SaveLog(GtDescHelp("NOCTMOEDA"))
		lPergOk := .F.
	Endif
EndIf

//Tipo de saldo nao preenchido
If Empty(cTpSaldo)
	Help(" ",1,"NO210TPSLD")

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Atualiza o log de processamento com o erro  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	oSelf:SaveLog(GtDescHelp("NO210TPSLD"))
	lPergOk := .F.
Endif

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//砎ALIDACAO DAS ENTIDADES PONTE E DE APURACAO - ENTIDADES PELA ROTINA�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//Se utiliza as entidades ponte/LP da Rotina, verificar se os parametros estao preenchidos
If !lCadastro
	If lPontes .And. ( Empty( Mv_Par14 ) .Or. Empty( Mv_Par15 ) )
		If Empty( Mv_Par14 ) .And. Empty( Mv_Par15 )
			cMsgErroPg := OemToAnsi( STR0116 )
		ElseIf Empty( Mv_Par15 )
			cMsgErroPg := OemToAnsi( STR0115 )
		Else
			cMsgErroPg := OemToAnsi( STR0114 )
		EndIf

		If !_lBlind
			MsgAlert( cMsgErroPg )
		Else
			Help( " " , 1 , "NOCT210CT" )
		EndIf

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Atualiza o log de processamento com o erro  �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		oSelf:SaveLog( GtDescHelp("NOCT210CT") + Space( 1 ) + cMsgErroPg )
		lPergOk := .F.
	ElseIf !lPontes .And. Empty( Mv_Par15 )
		cMsgErroPg := OemToAnsi( STR0115 )

		If !_lBlind
			MsgAlert( cMsgErroPg )
		Else
			Help( " " , 1 , "NOCT210CT" )
		EndIf

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Atualiza o log de processamento com o erro  �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		oSelf:SaveLog( GtDescHelp("NOCT210CT") + Space( 1 ) + cMsgErroPg )
		lPergOk := .F.
	EndIf

	cCtaPon := Mv_Par14
	cCtaLP  := Mv_Par15

	Ct211ValCt(cCtaLP,@cCtaPon,@cDigPon,@cCtaLP,@cDigLP,lPontes,@lCtaOk,@aCriter,@aCritPon,@aCritLP,lCadastro, .F. ,@cMsgErroPg)

	If !lCtaOk
		lPergOk := .F.

		If !Empty( cMsgErroPg )
			oSelf:SaveLog( cMsgErroPg )
		EndIf
	EndIf

    // Verifica se a Conta ponte est� sendo apurada tamb閙
    If lPergOk .And. lPontes .And. !Empty(cCtaPon) .And.  ( cCtaPon >= cContaIni .And.  cCtaPon <= cContaFim )
    	Help("  ",1,"CT211PONTCT1",,STR0049 ,1,0) //"Conta ponte n鉶 pode estar no intervalo das contas apuradas"
    	lPergOk := .F.
		oSelf:SaveLog(STR0049)//"Conta ponte n鉶 pode estar no intervalo das contas apuradas"
    EndIf

    If lPergOk .And. !Empty(cCtaLP) .And.  ( cCtaLP >= cContaIni .And.  cCtaLP <= cContaFim )
    	Help("  ",1,"CT211APRCT1",,STR0050 ,1,0) //"Conta de Apura玢o n鉶 pode estar no intervalo das contas apuradas "
    	lPergOk := .F.
		oSelf:SaveLog(STR0050)//"Conta de Apura玢o n鉶 pode estar no intervalo das contas apuradas "
    EndIf

	If lCusto .and. lPergOk
		If Empty(mv_par17)
			If _lBlind .OR. __lOKCusto
				lCCOk := .T.
			Else
				If MsgYesNo(STR0043+CRLF+STR0044,ALLTRIM(RetTitle("CTT_CUSTO"))+STR0045 ) //"Entidade em uso, por閙 n鉶 indicado codigo para apura玢o."#"Entidade n鉶 ser� considerada para os lan鏰mentos. Continuar ?"#" de apura玢o vazio."
					lCCOk := .T.
					__lOKCusto := .T.
				Else
					lCCOk := .F.
				EnDif
			EndIf
		Else
			cCCPon	:= mv_par16
			cCCLP	:= mv_par17
			Ct211ValCC(cCCLP,@cCCPon,@cCCLP,lPontes,@lCCOk,lCadastro)
		EndIf
		Iif(!lCCOk, lPergOk := .F., )


	    // Verifica se ao Centro de Custo ponte est� sendo apurada tamb閙
	    If lPergOk .And. lPontes .And. !Empty(cCCPon) .And.  ( cCCPon >= cCustoIni .And.  cCCPon <= cCustoFim )
	    	Help("  ",1,"CT211PONTCTT",,STR0051 ,1,0) //"Centro Custo ponte n鉶 pode estar no intervalo dos centros de Custos apurados"
	    	lPergOk := .F.
			oSelf:SaveLog(STR0051)//"Centro Custo ponte n鉶 pode estar no intervalo dos centros de Custos apurados"
	    EndIf

	    If lPergOk .And. !Empty(cCCLP) .And. ( cCCLP >= cCustoIni .And.  cCCLP <= cCustoFim )
	    	Help("  ",1,"CT211APRCTT",,STR0052 ,1,0) //"Centro Custo de Apuracao n鉶 pode estar no intervalo dos centros de Custos apurados "
	    	lPergOk := .F.
			oSelf:SaveLog(STR0052)//"Centro Custo de Apuracao n鉶 pode estar no intervalo dos centros de Custos apurados "
	    EndIf
	EndIf

	If lItem .and. lPergOk
	    If Empty(mv_par19)
			If _lBlind .OR. __lOKItem
				lItemOk := .T.
			Else
				If MsgYesNo(STR0043+CRLF+STR0044,ALLTRIM(RetTitle("CTD_ITEM"))+STR0045 ) //"Entidade em uso, por閙 n鉶 indicado codigo para apura玢o."#"Entidade n鉶 ser� considerada para os lan鏰mentos. Continuar ?"#" de apura玢o vazio."
					lItemOk := .T.
					__lOKItem := .T.
				Else
					lItemOk := .F.
				EnDif
			EndIf
		Else
			cItemPon	:= mv_par18
			cItemLP		:= mv_par19
			Ct211ValIt(cItemLP,@cItemPon,@cItemLP,lPontes,@lItemOk,lCadastro)
		Endif
		Iif(!lItemOk, lPergOk := .F., )


		// Verifica se o Item Contabil ponte est� sendo apurada tamb閙
	    If lPergOk .And. lPontes .And.  !Empty(cItemPon) .And. ( cItemPon >= cItemIni .And.  cItemPon <= cItemFim )
	    	Help("  ",1,"CT211PONTCTD",,STR0053 ,1,0) //"Item Cont醔il Ponte n鉶 pode estar no intervalo dos itens cont醔eis apurados"
	    	lPergOk := .F.
			oSelf:SaveLog(STR0053)//"Item Cont醔il Ponte n鉶 pode estar no intervalo dos itens cont醔eis apurados"
	    EndIf

	    If lPergOk .And. !Empty(cItemLP) .And.  ( cItemLP >= cItemIni .And.  cItemLP <= cItemFim )
	    	Help("  ",1,"CT211APRCTD",,STR0054 ,1,0) //"Item Cont醔il de Apuracao n鉶 pode estar no intervalo dos itens cont醔eis apurados "
	    	lPergOk := .F.
			oSelf:SaveLog(STR0054)//"Item Cont醔il de Apuracao n鉶 pode estar no intervalo dos itens cont醔eis apurados "
	    EndIf

	EndIf

	If lClvl .and. lPergOk
		If Empty(mv_par21)
			If _lBlind .OR. __lOKClasse
				lCLVLOk := .T.
			Else
				If MsgYesNo(STR0043+CRLF+STR0044,ALLTRIM(RetTitle("CTH_CLVL"))+STR0045 ) //"Entidade em uso, por閙 n鉶 indicado codigo para apura玢o."#"Entidade n鉶 ser� considerada para os lan鏰mentos. Continuar ?"#" de apura玢o vazio."
					lCLVLOk := .T.
					__lOKClasse := .T.
				Else
					lCLVLOk := .F.
				EnDif
			EndIf
		Else
			cClVlPon	:= mv_par20
			cClVlLP		:= mv_par21
			Ct211ValCV(cClVlLP,@cClVlPon,@cClVlLP,lPontes,@lClVlOk,lCadastro)
		EndIf
		Iif(!lCLVLOk, lPergOk := .F., )

	    If lPergOk .And. lPontes .And. !Empty(cClVlPon) .And.  ( cClVlPon >= cClVlIni .And.  cClVlPon <= cClVlFim )
	    	Help("  ",1,"CT211PONTCTH",,STR0055 ,1,0) //"Classe de Valor Ponte n鉶 pode estar no intervalo das classes de valor apuradas"
	    	lPergOk := .F.
			oSelf:SaveLog(STR0055)//"Classe de Valor Ponte n鉶 pode estar no intervalo das classes de valor apuradas"
	    EndIf

	    If lPergOk .And. !Empty(cClVlLP) .And. ( cClVlLP >= cClVlIni .And.  cClVlLP <= cClVlFim )
	    	Help("  ",1,"CT211APRCTH",,STR0056 ,1,0) //"Classe de Valor de Apuracao n鉶 pode estar no intervalo das classes de valor apuradas "
	    	lPergOk := .F.
			oSelf:SaveLog(STR0056)//"Classe de Valor de Apuracao n鉶 pode estar no intervalo das classes de valor apuradas "
	    EndIf

	EndIf

	// Trecho localizado COL|PER vari醰el static.
	If lEntidad05 .And. lPergOk
		If Empty(mv_par32)
			If _lBlind .OR. __lOKEnt05
				lEnt05Ok := .T.
			Else
				If MsgYesNo(STR0043+CRLF+STR0143+CRLF+STR0144,Alltrim(Posicione("CT0",1,xFilial("CT0")+"05","CT0_DSCRES"))+STR0045) //"Ente en uso, sin embargo, no se indico un codigo para calculo"#"Se usar醤 las entidades de origen de los asientos contables."#"緿esea continuar?"#" de calculo vacio."
					lEnt05Ok := .T.
					__lOKEnt05 := .T.
				Else
					lEnt05Ok := .F.
				EnDif
			EndIf
		Else
			cEnt05LP := mv_par32
			If FindFunction("Ct211ValE5") // CTBXMI
				Ct211ValE5(cEnt05LP,@cEnt05LP,@lEnt05Ok,lCadastro)
				If !lEnt05Ok
					If !_lBlind
						Help(NIL, NIL, STR0014, NIL, STR0145 + Alltrim(Posicione("CT0",1,xFilial("CT0")+"05","CT0_DSCRES")), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0142})	//"TENCION !"##"No existe el c骴igo de la entidad 05 "##"Configure correctamente los par醡etros del proceso."
					EndIf
					// Atualiza o log de processamento com o erro
					oSelf:SaveLog(STR0145) //"No existe el c骴igo de la entidad 05 "
				EndIf
			EndIf
		EndIf
		Iif(!lEnt05Ok, lPergOk := .F., )
	EndIf

EndIf

//Verifica se tem algum saldo basico desatualizado. Definido que essa verificacao so sera
//feita em top connect, pois se fosse fazer em codebase iria degradar muito a performance
//do sistema.
If !lSlBase .OR. !lReproc //So ira fazer a verificacao, caso o parametro MV_ATUSAL esteja com "N"
	For nx := nInicio to nFinal
		dLastProc := GetCv7Date(cTpSaldo,StrZero(nx,2))
		If dDataFLP > dLastProc
			lPergOk := .F.
			MsgAlert(OemToAnsi(STR0010)+"Saldo : "+ cTpSaldo+" Moeda : "+StrZero(nx,2))//"Ha saldos basicos desatualizados. Favor atualizar os saldos."
			Exit
		EndIf
	Next
EndIf

//SE OS PARAMETROS NAO ESTIVEREM DEVIDAMENTE PREENCHIDOS
If !lPergOk
	Return
Endif
////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////
/// CRIA ARQUIVO DE TRABALHO PARA GUARDAR OS SALDOS A SEREM ZERADOS
////////////////////////////////////////////////////////////////////////////////////////
aTpSaldos	:= {cTpSaldo}

// Inclui (_) antes do LP para que ao renomear nao seja enviado ao periferico LPT1 quando
// o codigo da empresa inicia com T1. Caso encontrado pelo SQA
cArqTRB := "_LP" + cEmpAnt + StrTran(cFilAnt, " ", "") + Right( cExerc, 2)

//criar semaforo para nao permitir outro usuario logado na mesma empresa filial possa executar a rotina
nCtdSemaf := 0
//inicia o semaforo
While !LockByName(cArqTRB+"_APUR",.T.,.T.,.T.) .And. nCtdSemaf <= 15
	nCtdSemaf++
	Sleep(1)
	If nCtdSemaf > 15
		Exit
	EndIf
EndDo

If nCtdSemaf > 15
	MsgAlert(STR0032+cArqTRB+GetDbExtension(),STR0033)//"N鉶 foi poss韛el excluir o arquivo: "//"Erro - Arquivo em uso ou travado."
	Return
EndIf

/// CRIACAO DE ARQUIVO TEMPORARIO.
If ! Ct211CrTrb(cArqTRB,lJaProc,lCriaTRB,@lNovoTRB)
	Return
EndIf

If Empty(cContaFim)
	cContaFim := Replicate("Z",nTamCta)
Endif

aAdd(aFilters,{"CT", cContaIni,cContaFim} ) //Da Conta | a Conta

If lCusto
	If Empty(cCustoIni).And. Empty(cCustoFim)
		lCusto := .F.
	ElseIf Empty(cCustoFim)
		cCustoFim := Replicate("Z",nTamCC)
	Endif
	aAdd(aFilters,{"CC", cCustoIni,cCustoFim} ) //Do C.Custo| ao C.Custo
EndIf
If lItem
	If Empty(cItemIni).And. Empty(cItemFim)
		lItem := .F.
	ElseIf Empty(cItemFim)
		cItemFim := Replicate("Z",nTamItem)
	Endif
	aAdd(aFilters,{"IT", cItemIni,cItemFim} ) //Do Item | ao Item
EndIf
If lClVL
	If Empty(cClVlIni).And. Empty(cClVlFim)
		lClVL := .F.
	ElseIf Empty(cClVlFim)
		cClVlFim := Replicate("Z",nTamClVl)
	Endif
	aAdd(aFilters,{"CL", cClVlIni,cClVlFim} ) //Da Classe | a Classe
EndIf

////////////////////////////////////////////////////////////////////
/// LE OS SALDOS DAS ENTIDADES E GUARDA NO ARQUIVO DE TRABALHO
////////////////////////////////////////////////////////////////////
If lNovoTRB

	If !lAuto
		/// VERIFICO OS SALDOS DA ENTIDADE 05 (QL7) GRAVANDO NO TRB.
		If lEntidad05
			If __lCtbLgAp
				oSelf:SaveLog(STR0126) //"MENSAJE: OBTENIENDO SALDOS DE QL7"
			EndIf
			CTB211GTRB('QL7',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
			If __lCtbLgAp
				oSelf:SaveLog(STR0127) //"MENSAJE: FIN OBTENIENDO SALDOS DE QL7"
			EndIf
		EndIf
		/// VERIFICO OS SALDOS DA CLASSE DE VALOR (CQ7) GRAVANDO NO TRB.
		If lClvl
			If __lCtbLgAp
				oSelf:SaveLog(STR0058) //"MENSAGEM: OBTENDO SALDOS DO CQ7"
			EndIf
			CTB211GTRB('CQ7',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
			If __lCtbLgAp
				oSelf:SaveLog(STR0060) //"MENSAGEM: FIM OBTENDO SALDOS CQ7"
			EndIF
		EndIf
		/// VERIFICO OS SALDOS DO ITEM CONTABIL (CQ5) GRAVANDO NO TRB.
		If lItem
			If __lCtbLgAp
				oSelf:SaveLog(STR0062) //"MENSAGEM: OBTENDO SALDOS DO CQ5"
			EndIf
			CTB211GTRB('CQ5',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
			If __lCtbLgAp
				oSelf:SaveLog(STR0064) //"MENSAGEM: FIM OBTENDO SALDOS DO CQ5"
			EndIf
		EndIf
		/// VERIFICO OS SALDOS DO CENTRO DE CUSTO(CQ3) GRAVANDO NO TRB.
		If lCusto
			If __lCtbLgAp
				oSelf:SaveLog(STR0065) //"MENSAGEM: OBTENDO SALDOS DO CQ3"
			EndIf
			CTB211GTRB('CQ3',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
			If __lCtbLgAp
				oSelf:SaveLog(STR0067) //"MENSAGEM: FIM OBTENDO SALDOS DO CQ3"
			EndIf
		EndIf

		/// VERIFICO OS SALDOS DA CONTA.(CQ1) GRAVANDO NO TRB.
		If __lCtbLgAp
			oSelf:SaveLog(STR0069) //"MENSAGEM: OBTENDO SALDOS DO CQ1"
		EndIf
		CTB211GTRB('CQ1',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
		If __lCtbLgAp
			oSelf:SaveLog(STR0071) //"MENSAGEM: FIM OBTENDO SALDOS DO CQ1"
		EndIf
	Else
		/// VERIFICO OS SALDOS DA ENTIDADE 05 (QL7) GRAVANDO NO TRB.
		If lEntidad05
			CTB211GTRB('QL7',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
		EndIf
		/// VERIFICO OS SALDOS DA CLASSE DE VALOR (CQ7) GRAVANDO NO TRB.
		If lClvl
			CTB211GTRB('CQ7',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
		EndIf
		/// VERIFICO OS SALDOS DO ITEM CONTABIL (CQ5) GRAVANDO NO TRB.
		If lItem
			CTB211GTRB('CQ5',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
		EndIf
		/// VERIFICO OS SALDOS DO CENTRO DE CUSTO(CQ3) GRAVANDO NO TRB.
		If lCusto
			CTB211GTRB('CQ3',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
		EndIf
		/// VERIFICO OS SALDOS DA CONTA.(CQ1) GRAVANDO NO TRB.
		CTB211GTRB('CQ1',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
	Endif

EndIf

////////////////////////////////////////////////////////////////////////////////////////
/// LE O ARQUIVO DE TRABALHO E GRAVA OS LAN茿MENTOS DE APURACAO
////////////////////////////////////////////////////////////////////////////////////////
If !lAuto .and. __lCtbLgAp
	oSelf:SaveLog(STR0073) //"MENSAGEM: INICIANDO A LEITURA/GRAVA敲O DOS LAN茿MENTOS"
Endif

dbSelectArea("TRB")
dbSetOrder(1)
dbGoTop()

If !lAuto
	If lObj
		oObj:SetRegua2(TRB->(RecCount()))
	Else
		oSelf:SetRegua2(TRB->(RecCount()))
	EndIf
Endif

nExecLin := 0

lFiltra := ValType(aFilters) == "A"

If lFiltra
	lFilCT := Len(aFilters) >= 1 .and. Len(aFilters[1]) >= 3 .and. (!Empty(aFilters[1][2]) .or. !Empty(aFilters[1][3]) )
	lFilCC := Len(aFilters) >= 2 .and. Len(aFilters[2]) >= 3 .and. (!Empty(aFilters[2][2]) .or. !Empty(aFilters[2][3]) )
	lFilIT := Len(aFilters) >= 3 .and. Len(aFilters[3]) >= 3 .and. (!Empty(aFilters[3][2]) .or. !Empty(aFilters[3][3]) )
	lFilCL := Len(aFilters) >= 4 .and. Len(aFilters[3]) >= 3 .and. (!Empty(aFilters[4][2]) .or. !Empty(aFilters[4][3]) )
EndIf


While TRB->(!Eof())

	If lFilCT
		If TRB->CONTA < aFilters[1][2] .or. TRB->CONTA > aFilters[1][3]
			TRB->(dbSkip())
			Loop
		EndIf
	EndIf
	If lFilCC
		If TRB->CUSTO < aFilters[2][2] .or. TRB->CUSTO > aFilters[2][3]
			TRB->(dbSkip())
			Loop
		EndIf
	EndIf
	If lFilIT
		If TRB->ITEM < aFilters[3][2] .or. TRB->ITEM > aFilters[3][3]
			TRB->(dbSkip())
			Loop
		EndIf
	EndIf
	If lFilCL
		If TRB->CLVL < aFilters[4][2] .or. TRB->CLVL > aFilters[4][3]
			TRB->(dbSkip())
			Loop
		EndIf
	EndIf

	If !lAuto
		If lObj
			oObj:IncRegua2(OemToAnsi(STR0021+TRB->MOEDA+STR0022+TRB->TPSALDO))//"Passo 2 -> Gravando lan鏰mentos Moeda "//" Saldo "
		Else
			oSelf:IncRegua2(OemToAnsi(STR0021+TRB->MOEDA+STR0022+TRB->TPSALDO))//"Passo 2 -> Gravando lan鏰mentos Moeda "//" Saldo "
		EndIf
	Endif

	If lJaProc
		If TRB->JAPROC == "S"
			TRB->(dbSkip())
			Loop
		EndIf
	EndIf

   	nSaldo := TRB->SALDOC - TRB->SALDOD

	nExecLin++
	If nExecLin == 1
		nSaldo := TRB->SALDOC
	ElseIf nExecLin == 2
		nSaldo := TRB->SALDOD * -1
	EndIf

    If nSaldo <> 0
		nLinha := DecodSoma1( cLinha )   // a funcao esta no fonte ctbxfuna.prx

		If lFirst .or. nLinha > nMAX_LINHA .or. TRB->TPSALDO <> cTpSldAnt .or. TRB->MOEDA <> cMoedAnt
			cMoedAnt	:= TRB->MOEDA
			cTpSldAnt	:= TRB->TPSALDO

			Do While ! ProxDoc(dDataFLP,cLote,cSubLote,cDoc,@CTF_LOCK)
				//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
				//� Caso o N� do Doc estourou, incrementa o lote         �
				//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
				cLote := CtbInc_Lot(cLote, "CTB", .T.) // True para forcar chave pelo modulo CTB

			Enddo

			If cPaisLoc == 'CHI' .and. Val(cLinha) < 2  // a partir da segunda linha do lanc., o correlativo eh o mesmo
				cSeqCorr := CTBSqCor( CTBSubToPad(cSubLote) )
			EndIf

			cDoc   := IIF(nLinha > nMAX_LINHA .And. !lFirst .And. TRB->MOEDA == cMoedAnt, Soma1(cDoc), cDoc) //Identifica se est� na ultima linha do maximo, soma1 no numero de documento

			lFirst := .F.
			cLinha := "001"
			nLinha := 1
			cSeqLan:= "001"
			If cPaisLoc $ "BOL" // a partir da segunda linha do lanc., o correlativo eh o mesmo
				cSeqCorr := CTBSqCor( CTBSubToPad(cSubLote),,dDataFLP)
				CTBSQGrv(cSeqCorr, dDataFLP )
			EndIf
		EndIf
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//砎ALIDACAO DAS ENTIDADES PONTE E DE APURACAO - ENTIDADES PELO CAD.  �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		If lCadastro
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//砈E UTILIZAR ENTIDADES DO CADASTRO �
			//砈UBSTITUI VARIAVEIS DAS           �
			//�- ENTIDADES PONTE                 �
			//�- ENTIDADES DE APURACAO           �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

			lPergOk := .T.
			cCtaPon	:= cSpacCT
			cCtaLP	:= cSpacCT

			Ct211ValCt(TRB->CONTA,@cCtaPon,@cDigPon,@cCtaLP,@cDigLP,lPontes,@lCtaOk,@aCriter,@aCritPon,@aCritLP,lCadastro)

			If lPontes .And. (Empty(cCtaPon) .Or. Empty(cCtaLP))
				lPergOk	:= .F.
			ElseIf !lPontes .And. Empty(cCtaLP)
				lPergOk	:= .F.
			EndIf

			cCCPon	:= cSpacCC
			cCCLP	:= cSpacCC
			If lPergOk .and. lCusto .and. !Empty(TRB->CUSTO)
				Ct211ValCC(TRB->CUSTO,@cCCPon,@cCCLP,lPontes,@lPergOk,lCadastro)
			EndIf

			cItemPon	:= cSpacIT
			cItemLP		:= cSpacIT
			If lPergOk .and. lItem .and. !Empty(TRB->ITEM)
				Ct211ValIt(TRB->ITEM,@cItemPon,@cItemLP,lPontes,@lPergOk,lCadastro)
			EndIf

			cClVlPon	:= cSpacCL
			cClVlLP		:= cSpacCL
			If lPergOk .and. lClvl .and. !Empty(TRB->CLVL)
				Ct211ValCV(TRB->CLVL,@cClVlPon,@cClVlLP,lPontes,@lPergOk,lCadastro)
			EndIf

			cEnt05LP	:= cSpacE05 //cSpacE05 estar� vazio no padr鉶, somente � preenchido localizado COL|PER
			// Trecho localizado COL|PER vari醰el static.
			If lPergOk .And. lEntidad05 .And. !Empty(TRB->ENT05) .And. FindFunction("Ct211ValE5")
				Ct211ValE5(TRB->ENT05,@cEnt05LP,@lPergOk,lCadastro)
			EndIf

			/// SE HOUVER ALGUM PROBLEMA COM AS ENTIDADES PONTE/APURACAO DO CADASTRO
			If !lPergOk
				/// PASSA PARA O PROXIMO DO TRB SEM MARCAR COMO "J� PROCESSADO"
				/// AVALIAR CORRE敲O NO CADASTRO E PROCESSAMENTO S� DOS PENDENTES PELO TRB
				TRB->(dbSkip())
				nExecLin := 0
				Loop
			EndIf

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//砈e as entidades ponte/apura玢o est鉶 Ok        �
		//�                                               �
		//矨VALIA SALDO OBTIDO PARA LAN茿MENTO DE APURACAO�
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		Else
			// Trecho localizado COL|PER vari醰el static.
			If lEntidad05 .And. !Empty(TRB->ENT05) .And. Empty(mv_par32)	// Usar Entidad de C醠culo pero est� vac韆; enviar a la origen
				cEnt05LP := TRB->ENT05
			EndIf

		EndIf

		cTipo		:= "3"

		If nSaldo > 0					/// SE O SALDO FOR A CREDITO / CREDOR
			If !lPontes
				cDebito		:= TRB->CONTA	/// LANCAMENTO A DEBITO NA CONTA ORIGEM (PARA ZERAR)
				cCustoDeb	:= TRB->CUSTO
				cItemDeb	:= TRB->ITEM
				cClVlDeb	:= TRB->CLVL
			Else
				cDebito		:= cCtaPon	/// LANCAMENTO A DEBITO NA CONTA PONTE (PARA N肙 ZERAR ORIGEM)
				If !Empty(TRB->CUSTO)
					cCustoDeb	:= cCCPon
				Else
					cCustoDeb	:= cSpacCC
				EnDif
				If !Empty(TRB->ITEM)
					cItemDeb	:= cItemPon
				Else
					cItemDeb	:= cSpacIT
				EndIf
				If !Empty(TRB->CLVL)
					cClVlDeb	:= cClVlPon
				Else
					cClVlDeb	:= cSpacCL
				EndIf
			EndIf

			cCredito	:= cCtaLP		/// LANCAMENTO A CREDITO NA CONTA DE APURACAO
			If !Empty(TRB->CUSTO)
				cCustoCrd	:= cCCLP
			Else
				cCustoCrd	:= cSpacCC
			EndIf
			If !Empty(TRB->ITEM)
				cItemCrd	:= cItemLP
			Else
				cItemCrd	:= cSpacIT
			EndIf
			If !Empty(TRB->CLVL)
				cClVlCrd	:= cClVlLP
			Else
				cClVlCrd	:= cSpacCL
			EndIf

			If lEntidad05 // Trecho localizado COL|PER vari醰el static.
				// Entidad 05 no usa c骴igo puente, usar el mismo clasificador como d閎ito
				cEntDeb05	:= TRB->ENT05
				If !Empty(cEntDeb05)
					cEntCrd05	:= cEnt05LP
				Else
					cEntCrd05	:= cSpacE05
				EndIf
			EndIf

			lCTZDeb := .T.
		Else                        	/// SE O SALDO FOR A DEBITO / DEVEDOR
			cDebito		:= cCtaLP		/// LANCAMENTO A DEBITO NA CONTA DE APURACAO
			If !Empty(TRB->CUSTO)
				cCustoDeb	:= cCCLP
			Else
				cCustoDeb	:= cSpacCC
			EndIf
			If !Empty(TRB->ITEM)
				cItemDeb	:= cItemLP
			Else
				cItemDeb	:= cSpacIT
			EndIf
			If !Empty(TRB->CLVL)
				cClVlDeb	:= cClVlLP
			Else
				cClVlDeb	:= cSpacCL
			EndIf

			If !lPontes
				cCredito	:= TRB->CONTA	/// LANCAMENTO A CREDITO NA CONTA ORIGEM (PARA ZERAR)
				cCustoCrd	:= TRB->CUSTO
				cItemCrd	:= TRB->ITEM
				cClVlCrd	:= TRB->CLVL
			Else
				cCredito	:= cCtaPon	/// LANCAMENTO A DEBITO NA CONTA PONTE (PARA N肙 ZERAR ORIGEM)
				If !Empty(TRB->CUSTO)
					cCustoCrd	:= cCCPon
				Else
					cCustoCrd	:= cSpacCC
				EndIf
				If !Empty(TRB->ITEM)
					cItemCrd	:= cItemPon
				Else
					cItemCrd	:= cSpacIT
				EndIf
				If !Empty(TRB->CLVL)
					cClVlCrd	:= cClVlPon
				Else
					cClVlCrd	:= cSpacCL
				EndIf
			EndIf

			// Trecho localizado COL|PER vari醰el static.
			If lEntidad05
				// Entidad 05 no usa c骴igo puente, usar el mismo clasificador como cr閐ito
				cEntCrd05 := TRB->ENT05
				If !Empty(cEntCrd05)
					cEntDeb05	:= cEnt05LP
				Else
					cEntDeb05	:= cSpacE05
				EndIf
			EndIf

			lCTZDeb := .F.
		EndIf

		//Grava lancamento na moeda 01
		nSaldo 		:= ABS(nSaldo)
		nMoedAtu	:= VAL(TRB->MOEDA)

		// Trecho localizado COL|PER vari醰el static.
		If lEntidad05
			aEntid 		:= {{cEntDeb05, cEntCrd05}}
		EndIf

	    //////////////////////////////////////////////////////////////////////////////////////////
	    //////////////////////////////////////////////////////////////////////////////////////////
		If TRB->MOEDA == "01"
			lApurMoeda1 := .T.
			If !lAuto .and. __lCtbLgAp
				oSelf:SaveLog(STR0075) //"MENSAGEM: INICIANDO A GRAVA敲O DOS SALDOS (MOEDA 01)"
			Endif

			If !lEntidad05 //Trecho n鉶 localizado (nega玢o)
				aOutrEntid 	:= CtbOutrEnt(.F., "TRB")
				aEntid 		:= aOutrEntid[1]
			EndIf

			If lReproc
				//////////////////////////////////////////////////////////////////////////////////////////
				/// FUNCAO GRAVACTx AINDA ESTA GRAVANDO SALDO ANTERIOR INCORRETO QDO J� EXISTE LANC. NO DIA DE LP
				/// CHAMA A GRAVSALDO PARA ATUALIZAR OS ACUMULADOS CORRETAMENTE E
				/// CHAMA REPROCESSAMENTO DO DIA DE APURACAO AO FINAL DO PROCESSAMENTO PARA ACERTAR SLD.ANTERIOR DO DIA.
				//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
				//�	/// GRAVA SALDO RELATIVO AO LAN茿MENTO DE LUCROS E PERDAS (CTx_LP = 'Z')�
				//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
				CtbGravSaldo(cLote,cSubLote,cDoc,dDataFLP,cTipo,"01",;
					cDebito,cCredito,;
					cCustoDeb,cCustoCrd,;
					cItemDeb,cItemCrd,;
					cClVlDeb,cClVlCrd,;
					nSaldo,TRB->TPSALDO,3,;
					cDebito,cCredito,;
					cCustoDeb,cCustoCrd,;
					cItemDeb,cItemCrd,;
					cClVlDeb,cClVlCrd,;
					0,cTipo,TRB->TPSALDO,"01",;
					lCusto,lItem,lClVL,;
					,.T.,.F.,dDataFLP,;
					lGrvCT7,lGrvCT3,lGrvCT4,lGrvCTI,;
					lAtuSldCT7,lAtuSldCT3,lAtuSldCT4,lAtuSldCTI,,"+"/*cOperacao*/, aEntid,;
					,cDescHP)
			EndIf

			If !lAuto .and. __lCtbLgAp
				oSelf:SaveLog(STR0077) //"MENSAGEM: FINALIZANDO A GRAVA敲O DOS SALDOS"
			Endif

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//砅REPARA VARIAVEIS PARA INCLUSAO/ALTERACAO DE LANCAMENTO NO CT2�
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			If !lAuto .and. __lCtbLgAp
				oSelf:SaveLog(STR0079) //"MENSAGEM: INICIANDO A INCLUSAO/ALTERACAO DOS LANCAMENTOS NO CT2 (01)"
			Endif

			nOpcGRV := 3
			If lPontes
				/// SE FOR APURACAO COM CONTA PONTE
				cLoteBak := cLote
				cSubBak	 := cSubLote
				cDocBak	 := cDoc
				cLinBak	 := cLinha
				cSeqLBak := cSeqLan

				nVlrCTZ := nSaldo

				// Trecho localizado COL|PER vari醰el static.
				If lEntidad05
					If cKeyEntAtu <> '01'+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd+cEntDeb05+cEntCrd05
						cKeyDocLP := DTOS(dDataFLP)+cLote+cSubLote+cDoc
						If Len(__aDocsLP) <= 0 .or. Ascan(__aDocsLP, {|x| x[1] == cKeyDocLP }) <= 0
							aAdd(__aDocsLP, { cKeyDocLP , dDataFLP , cLote, cSubLote, cDoc } )
						EndIf
						/// VERIFICA DENTRO DOS LOTES/DOCS J� GERADOS NA APURACAO SE EXISTE LANCAMENTO IGUAL
						nRecLinha := Ct211Seek(__aDocsLP,'01',TRB->TPSALDO,;
								cDebito,cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,cEntDeb05,cEntCrd05)

						nRecLanAtu := nRecLinha
						cKeyEntAtu := '01'+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd+cEntDeb05+cEntCrd05
					EndIf
				ElseIf cKeyEntAtu <> '01'+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd

					cKeyDocLP := DTOS(dDataFLP)+cLote+cSubLote+cDoc
					If Len(__aDocsLP) <= 0 .or. Ascan(__aDocsLP, {|x| x[1] == cKeyDocLP }) <= 0
						aAdd(__aDocsLP, { cKeyDocLP , dDataFLP , cLote, cSubLote, cDoc } )
					EndIf
					/// VERIFICA DENTRO DOS LOTES/DOCS J� GERADOS NA APURACAO SE EXISTE LANCAMENTO IGUAL
					nRecLinha := Ct211Seek(__aDocsLP,'01',TRB->TPSALDO,;
							cDebito,cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd)

					nRecLanAtu := nRecLinha
					cKeyEntAtu := '01'+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd

				Else		/// ENQUANTO FOR A MESMA CHAVE DE ENTIDADES N肙 PRECISA MODIFICAR LOTE, DOC, LINHA ETC.
					nRecLinha := nRecLanAtu
				EndIf

				If nRecLinha > 0
					/// SE JA EXISTE LAN茿MENTO IGUAL ALTERA A MESMA LINHA SOMANDO O VALOR.
					CT2->(dbGoTo(nRecLinha))
					nSaldo 		:= nSaldo + CT2->CT2_VALOR
					cLote		:= CT2->CT2_LOTE
					cSubLote	:= CT2->CT2_SBLOTE
					cDoc		:= CT2->CT2_DOC
					cLinha 		:= CT2->CT2_LINHA
					cSeqLan		:= CT2->CT2_SEQLAN
					nOpcGrv := 4
				EnDif
			EndIf

			cLinhaLan := cLinha ///SE HOUVER CONT. DE HISTORICO GRAVA CTZ NA LINHA DE LAN茿MENTO
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//矴RAVA LANCAMENTO DE APURACAO NO CT2�
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			aCols := { { "01", " ", nSaldo, "2", .F., nSaldo } }

			If !lAuto .and. __lCtbLgAp
				oSelf:SaveLog(STR0081) //"MENSAGEM: GRAVA敲O DO LAN茿MENTO (01)"
			Endif

			BEGIN TRANSACTION
			If cPaisLoc=="BOL"
				GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,'01',cHP,cDebito,;
						cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,;
						cClVlCrd,nSaldo,cDescHP,TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,;
						cEmpAnt,cFilAnt,,,,,,"CTBA211",;
						.F., , ,dDataFLP,@nRecLan,,,cSeqCorr)
			ElseIf lEntidad05
				GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,'01',cHP,cDebito,cCredito,;
					cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,nSaldo,cDescHP,;
					TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,,,,,,"CTBA211",.F., , ,dDataFLP,@nRecLan,,,,,,,,,aEntid)
			Else
				GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,'01',cHP,cDebito,cCredito,;
					cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,nSaldo,cDescHP,;
					TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,,,,,,"CTBA211",.F., , ,dDataFLP,@nRecLan)
			EndIf
		 	lGravouLan := .T.

		 	If !lAuto .and. __lCtbLgAp
				oSelf:SaveLog(STR0083) //"MENSAGEM: FIM DA GRAVA敲O DO LAN茿MENTO (01)"
			Endif

			If lPontes
				//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
				//砈E UTILIZAR CONTA PONTE ATUALIZA TABELA CTZ COM AS CONTAS DE ORIGEM�
				//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
				If !lAuto .and. __lCtbLgAp
					oSelf:SaveLog(STR0085) //"MENSAGEM: GRAVA敲O DO CTZ (01)"
				Endif
				If lEntidad05 // Trecho localizado COL|PER vari醰el static.
					Ct211GrCTZ(dDataFLP,cLote,cSubLote,cDoc,cLinhaLan,"01",TRB->TPSALDO,;
						Iif(lCTZDeb,"1","2"),nVlrCTZ,TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL,TRB->ENT05)
				Else
					Ct211GrCTZ(dDataFLP,cLote,cSubLote,cDoc,cLinhaLan,"01",TRB->TPSALDO,;
						Iif(lCTZDeb,"1","2"),nVlrCTZ,TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL)
				EndIf

				If nOpcGrv == 4	/// SE FOI ALTERACAO DE LANCAMENTO, RESTAURA PROXIMO "ORIGINAL"
					cLote		:= cLoteBak
					cSubLote	:= cSubBak
					cDoc		:= cDocBak
					cLinha		:= cLinBak
					cSeqLan		:= cSeqLBak
				Else			/// SE FOI INCLUSAO, GUARDA O REC. ATUAL P/ ALT. SE O PROX. FOR MESMA CHAVE
					nRecLanAtu	:= nRecLan
					If lEntidad05 // Trecho localizado COL|PER vari醰el static.
						cKeyEntAtu := '01'+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd+cEntDeb05+cEntCrd05
					Else
						cKeyEntAtu := '01'+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd
					EndIf
				EndIf

				If !lAuto .and. __lCtbLgAp
					oSelf:SaveLog(STR0087) //"MENSAGEM: FIM DA GRAVA敲O DO CTZ (01)"
				Endif

			EndIf

			END TRANSACTION

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//矨TUALIZA FLAG DE LUCROS E PERDAS (CTx_LP e CTx_DTLP)�
			//砃OS REGISTROS DE SALDO NO PERIODO.                  �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			If !lAuto .and. __lCtbLgAp
				oSelf:SaveLog(STR0089) //"MENSAGEM: GRAVA敲O DA FLGLP (01)"
				If lEntidad05 // Trecho localizado COL|PER vari醰el static.
					Ct211FlgLP(TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL, dDataILP, TRB->TPSALDO, dDataFLP, TRB->MOEDA, TRB->ENT05)
				Else
					Ct211FlgLP(TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL, dDataILP, TRB->TPSALDO, dDataFLP, TRB->MOEDA)
				EndIf
				oSelf:SaveLog(STR0091) //"MENSAGEM: FIM DA GRAVA敲O DA FLGLP (01)"
				oSelf:SaveLog(STR0093) //"MENSAGEM: FINALIZANDO A INCLUSAO/ALTERACAO DOS LANCAMENTOS NO CT2 (01)"
			Else
				If lEntidad05 // Trecho localizado COL|PER vari醰el static.
					Ct211FlgLP(TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL, dDataILP, TRB->TPSALDO, dDataFLP, TRB->MOEDA, TRB->ENT05)
				Else
					Ct211FlgLP(TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL, dDataILP, TRB->TPSALDO, dDataFLP, TRB->MOEDA)
				EndIf
			Endif

				//////////////////////////////////////////////////////////////////////////////////////////
		Else	/// Grava Lancamento na moeda 0X com valor zerado na moeda 01
				//////////////////////////////////////////////////////////////////////////////////////////
			If !lAuto .and. __lCtbLgAp
				oSelf:SaveLog(STR0095+" ("+TRB->MOEDA+")") //"MENSAGEM: INICIANDO A INCLUSAO/ALTERACAO DOS LANCAMENTOS NO CT2 ("+TRB->MOEDA+")"
    		Endif

			If val(TRB->MOEDA) > 2
				nForaCols	:= VAL(TRB->MOEDA)-2
			Else
				nForaCols	:= 0
			EndIf

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//砅REPARA VARIAVEIS PARA INCLUSAO/ALTERACAO DE LANCAMENTO NO CT2�
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		    nOpcGRV := 3
			If lPontes
				/// SE FOR APURACAO COM CONTA PONTE
				cLoteBak := cLote
				cSubBak	 := cSubLote
				cDocBak	 := cDoc
				cLinBak	 := cLinha
				cSeqLBak := cSeqLan

				nVlrCTZ := nSaldo
				If lEntidad05 // Trecho localizado COL|PER vari醰el static.
					If cKeyEntAtu <> TRB->MOEDA+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd+cEntDeb05+cEntCrd05
						cKeyDocLP := DTOS(dDataFLP)+cLote+cSubLote+cDoc
						If Len(__aDocsLP) <= 0 .or. Ascan(__aDocsLP, {|x| x[1] == cKeyDocLP }) <= 0
							aAdd(__aDocsLP, { cKeyDocLP , dDataFLP , cLote, cSubLote, cDoc } )
						EndIf
						/// VERIFICA DENTRO DOS LOTES/DOCS J� GERADOS NA APURACAO SE EXISTE LANCAMENTO IGUAL
						nRecLinha := Ct211Seek(__aDocsLP,TRB->MOEDA,TRB->TPSALDO,;
								cDebito,cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,cEntDeb05,cEntCrd05)

						nRecLanAtu := nRecLinha
						cKeyEntAtu := TRB->MOEDA+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd+cEntDeb05+cEntCrd05
					EndIf
				ElseIf cKeyEntAtu <> TRB->MOEDA+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd

					cKeyDocLP := DTOS(dDataFLP)+cLote+cSubLote+cDoc
					If Len(__aDocsLP) <= 0 .or. Ascan(__aDocsLP, {|x| x[1] == cKeyDocLP }) <= 0
						aAdd(__aDocsLP, { cKeyDocLP , dDataFLP , cLote, cSubLote, cDoc } )
					EndIf
					/// VERIFICA DENTRO DOS LOTES/DOCS J� GERADOS NA APURACAO SE EXISTE LANCAMENTO IGUAL
					nRecLinha := Ct211Seek(__aDocsLP,TRB->MOEDA,TRB->TPSALDO,;
							cDebito,cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd)

					nRecLanAtu := nRecLinha
					cKeyEntAtu := TRB->MOEDA+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd

				Else /// ENQUANTO FOR A MESMA CHAVE DE ENTIDADES N肙 PRECISA MODIFICAR LOTE, DOC, LINHA ETC.
					nRecLinha := nRecLanAtu
				EndIf

				If nRecLinha > 0
					/// SE JA EXISTE LAN茿MENTO IGUAL ALTERA A MESMA LINHA SOMANDO O VALOR.
					CT2->(dbGoTo(nRecLinha))
					nSaldo 		:= nSaldo + CT2->CT2_VALOR
					cLote		:= CT2->CT2_LOTE
					cSubLote	:= CT2->CT2_SBLOTE
					cDoc		:= CT2->CT2_DOC
					cLinha 		:= CT2->CT2_LINHA
					cSeqLan		:= CT2->CT2_SEQLAN
					nOpcGrv := 4
				EnDif
			EndIf

			cLinhaLan := cLinha ///SE HOUVER CONT. DE HISTORICO GRAVA CTZ NA LINHA DE LAN茿MENTO
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//矴RAVA LANCAMENTO DE APURACAO - RELATIVO A MOEDA 01 COM VALOR ZERADO�
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			aCols := { { "01", " ", 0.00, "2", .F., 0 },{ TRB->MOEDA, "4", nSaldo, "2", .F., nSaldo } }

			BEGIN TRANSACTION

			If nOpcGrv <> 4	/// NAO PRECISA ALTERAR SE O VALOR NA MOEDA 01 � ZERO
				If cPaisLoc=="BOL"


				GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,'01',cHP,cDebito,cCredito,;
					  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
					  TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,0,,,,,"CTBA211",.F., , ,dDataFLP,,,,cSeqCorr)

				Else
					/*caso nao tenha solicita玢o na moeda 01 dever ser gerado lan鏰mento
					com valor 0 para que possa ser visualizado o lan鏰mento de apura玢o*/
					If !lApurMoeda1
						If lEntidad05 // Trecho localizado COL|PER vari醰el static.
							GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,'01',cHP,cDebito,cCredito,;
								cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
								TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,0,,,,,"CTBA211",.F., , ,dDataFLP,,,,,,,,,,aEntid)
						Else
							GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,'01',cHP,cDebito,cCredito,;
								cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
								TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,0,,,,,"CTBA211",.F., , ,dDataFLP)
						Endif
					Endif
				EndIf
			EndIf

			/// FUNCAO GRAVACTx AINDA ESTA GRAVANDO SALDO ANTERIOR INCORRETO QDO J� EXISTE LANC. NO DIA DE LP
			/// CHAMA A GRAVSALDO PARA ATUALIZAR OS ACUMULADOS CORRETAMENTE E
			/// CHAMA REPROCESSAMENTO DO DIA DE APURACAO AO FINAL DO PROCESSAMENTO PARA ACERTAR SLD.ANTERIOR DO DIA.
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//�	/// GRAVA SALDO RELATIVO AO LAN茿MENTO DE LUCROS E PERDAS (CTx_LP = 'Z')�
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			CtbGravSaldo(cLote,cSubLote,cDoc,dDataFLP,cTipo,TRB->MOEDA,;
				cDebito,cCredito,;
				cCustoDeb,cCustoCrd,;
				cItemDeb,cItemCrd,;
				cClVlDeb,cClVlCrd,;
				nSaldo,TRB->TPSALDO,3,;
				cDebito,cCredito,;
				cCustoDeb,cCustoCrd,;
				cItemDeb,cItemCrd,;
				cClVlDeb,cClVlCrd,;
				0,cTipo,TRB->TPSALDO,TRB->MOEDA,;
				lCusto,lItem,lClVL,;
				,.T.,.F.,dDataFLP,;
				lGrvCT7,lGrvCT3,lGrvCT4,lGrvCTI,;
				lAtuSldCT7,lAtuSldCT3,lAtuSldCT4,lAtuSldCTI,,"+"/*cOperacao*/, aEntid,;
				,cDescHP)

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//矴RAVA LANCAMENTO DE APURACAO NO CT2�
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			cLinha := cLinhaLan			/// GRAVA LANCAMENTO DA MOEDA 0X NA MESMA LINHA DA MOEDA 01
			If cPaisLoc=="BOL"
				GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,TRB->MOEDA,cHP,cDebito,cCredito,;
				  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
				  TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,nForaCols,,,,,"CTBA211",.F.,,,dDataFLP,@nRecLan,,,cSeqCorr)

			ElseIf lEntidad05
			GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,TRB->MOEDA,cHP,cDebito,cCredito,;
				  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
				  TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,nForaCols,,,,,"CTBA211",.F.,,,dDataFLP,@nRecLan,,,,,,,,,aEntid)
			Else
			GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,TRB->MOEDA,cHP,cDebito,cCredito,;
				  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
				  TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,nForaCols,,,,,"CTBA211",.F.,,,dDataFLP,@nRecLan)
			EndIf
			If lPontes
				If lEntidad05 // Trecho localizado COL|PER vari醰el static.
					//Gravar zerado para a moeda 01 na CTZ para considerar na tabela 'LP' da CW0
					Ct211GrCTZ(dDataFLP,cLote,cSubLote,cDoc,cLinhaLan,"01",TRB->TPSALDO,;
						Iif(lCTZDeb,"1","2"),0,TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL,TRB->ENT05)

					//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
					//砈E UTILIZAR CONTA PONTE ATUALIZA TABELA CTZ COM AS CONTAS DE ORIGEM�
					//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
					Ct211GrCTZ(dDataFLP,cLote,cSubLote,cDoc,cLinhaLan,TRB->MOEDA,TRB->TPSALDO,;
						IIf(lCTZDeb,"1","2"),nVlrCTZ,TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL,TRB->ENT05)

					If nOpcGrv == 4	/// SE FOI ALTERACAO DE LANCAMENTO, RESTAURA PROXIMO "ORIGINAL"
						cLote		:= cLoteBak
						cSubLote	:= cSubBak
						cDoc		:= cDocBak
						cLinha		:= cLinBak
						cSeqLan		:= cSeqLBak
					Else			/// SE FOI INCLUSAO, GUARDA O REC. ATUAL P/ ALT. SE O PROX. FOR MESMA CHAVE
						nRecLanAtu	:= nRecLan
						cKeyEntAtu	:= TRB->MOEDA+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd+cEntDeb05+cEntCrd05
					EndIf
				Else
					//Gravar zerado para a moeda 01 na CTZ para considerar na tabela 'LP' da CW0
					Ct211GrCTZ(dDataFLP,cLote,cSubLote,cDoc,cLinhaLan,"01",TRB->TPSALDO,;
						Iif(lCTZDeb,"1","2"),0,TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL)

					//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
					//砈E UTILIZAR CONTA PONTE ATUALIZA TABELA CTZ COM AS CONTAS DE ORIGEM�
					//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
					Ct211GrCTZ(dDataFLP,cLote,cSubLote,cDoc,cLinhaLan,TRB->MOEDA,TRB->TPSALDO,;
						IIf(lCTZDeb,"1","2"),nVlrCTZ,TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL)

					If nOpcGrv == 4	/// SE FOI ALTERACAO DE LANCAMENTO, RESTAURA PROXIMO "ORIGINAL"
						cLote		:= cLoteBak
						cSubLote	:= cSubBak
						cDoc		:= cDocBak
						cLinha		:= cLinBak
						cSeqLan		:= cSeqLBak
					Else			/// SE FOI INCLUSAO, GUARDA O REC. ATUAL P/ ALT. SE O PROX. FOR MESMA CHAVE
						nRecLanAtu	:= nRecLan
										cKeyEntAtu := TRB->MOEDA+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd
					EndIf
				EndIf
			EndIf

			END TRANSACTION

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//矨TUALIZA FLAG DE LUCROS E PERDAS (CTx_LP e CTx_DTLP)�
			//砃OS REGISTROS DE SALDO NO PERIODO.                  �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			If lEntidad05 // Trecho localizado COL|PER vari醰el static.
				Ct211FlgLP(TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL, dDataILP, TRB->TPSALDO, dDataFLP, TRB->MOEDA, TRB->ENT05)
			Else
				Ct211FlgLP(TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL, dDataILP, TRB->TPSALDO, dDataFLP, TRB->MOEDA)
			EndIf

			If !lAuto .and. __lCtbLgAp
				oSelf:SaveLog(STR0097+" ("+TRB->MOEDA+")") //"MENSAGEM: FINALIZANDO A INCLUSAO/ALTERACAO DOS LANCAMENTOS NO CT2 ("+TRB->MOEDA+")"
			Endif

			lGravouLan := .T.
		EndIf
	EndIf

	If nExecLin <= 0 .or. nExecLin >= 2	/// Se houve quebra em 2 linhas (pois Deb e Cred estavam iguais) vai manter na mesma conta.
		If !lAuto .and. __lCtbLgAp
			oSelf:SaveLog(STR0099) //"MENSAGEM: GRAVANDO FLAG DO PROCESSAMENTO"
		Endif

		RecLock("TRB",.F.)
		Field->JAPROC := "S"
		TRB->(MsUnlock())

		TRB->(dbSkip())
		nExecLin := 0

		If !lAuto .and. __lCtbLgAp
			oSelf:SaveLog(STR0101) //"MENSAGEM: FINALIZANDO A GRAVA敲O DO FLAG DO PROCESSAMENTO"
		Endif

	EndIf
EndDo

If !lAuto .and. __lCtbLgAp
	oSelf:SaveLog(STR0103) //"MENSAGEM: FINAL DA LEITURA/GRAVA敲O DOS LAN茿MENTOS"
Endif

////////////////////////////////////////////////////////////////////////////////////////
//Atualiza tabela do SX5 com a data de apuracao, mesmo antes de reprocessar pois
//reprocessamento pode ser rodado posteriormente para ajuste dos saldos
//observa玢o, tem influencia no retorno da data de lucros e perdas anterior
//(para o intervalo de datas na marca玢o dos flags _LP no reprocessamento).

If lGravouLan .And. lResultado // lResultado no padr鉶 deve ser sempre .T.
	Ct211AtSx5(dDataFLP,lMoedaEsp,cMoeda,nInicio,nFinal,cTpSaldo,lPontes)
Endif

//termina o semaforo
UnLockByName(cArqTRB+"_APUR",.T.,.T.,.T.)

If lGravouLan
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� ATUALIZA OS SALDOS COM DATA POSTERIOR AO L/P -REPROCESSAMENTO�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	//Verifico qual a data final a ser passada para o Reprocessamento.
	/// MANTIDA DATA DA APURACAO PARA N肙 REPROCESSAR PERIODOS POSTERIORES
	//Ct211MaxDt(dDataFLP,@dDataFRep,cContaIni,cContaFim, cCustoIni, cCustoFim, cItemIni, cItemFim, cClVlIni, cClVlFim)

	//Caso exista algum ponto de entrada, o reprocessamento sera rodado a partir da data de apuracao para
	//atualizar os saldos de todas as tabelas
	If lCtbCCLP .Or. lCtbItLP .Or. lCtbCVLP
		dDataIRep	:= dDataFLP
		If Empty(dDataFRep)
			dDataFRep	:= dDataIRep
		EndIf
	EndIf

	//Chamo o Reprocessamento, se tiver saldos com data posterior ao zeramento.
	//Somente atualizo os saldos basicos
	If lReproc .AND. (!Empty(dDataFRep) .Or. (lCtbCCLP .Or. lCtbItLP .Or. lCtbCVLP))
		If !lAuto .and. __lCtbLgAp
			oSelf:SaveLog(STR0105) //"MENSAGEM: REPROCESSANDO OS SALDOS"
			CTBA190(.T.,dDataILP,dDataFRep,cFilAnt,cFilAnt,cTpSaldo,lMoedaEsp,cMoeda)
			oSelf:SaveLog(STR0107) //"MENSAGEM: FINALIZANDO O REPROCESSANDO OS SALDOS"
		Else
			CTBA190(.T.,dDataILP,dDataFRep,cFilAnt,cFilAnt,cTpSaldo,lMoedaEsp,cMoeda)
		Endif
	EndIf
EndIf

If !lAuto .and. __lCtbLgAp
	oSelf:SaveLog(STR0109) //"MENSAGEM: APAGANDO O ARQUIVO DE TRABALHO"
Endif

///	APAGA O ARQUIVO DE TRABALHO
dbSelectArea("TRB")
dbCloseArea()

//Apaga tabela temporaria do banco de dados
If  _oCTBA2111<> Nil
	_oCTBA2111:Delete()
	_oCTBA2111 := Nil
Endif

If !lAuto .and. __lCtbLgAp
	oSelf:SaveLog(STR0111) //"MENSAGEM: FINALIZANDO - APAGANDO O ARQUIVO DE TRABALHO"
Endif

If __lMetric
	CTB211Metrics("01" /*cEvent*/, nStart, "001" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/)
Endif

Return

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯t211CrTrb� Autor � Marcos S. Lobo        � Data � 26.09.06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 矯ria arquivo de trabalho									  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矯t211CrTrb()                                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      矯t211CrTrb()                                                潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function Ct211CrTrb(cNomeArq,lJaProc,lCriaTRB,lNovoTRB)

Local cTrb		:= ""
Local aCampos	:=  {}
Local aTamVlr	:= {}

Local cTitMsg 	:= ""
Local cMsg	  	:= ""

Local cCpoDeb 	:= ""
Local cCpoCrd 	:= ""
Local nInc		:= 0
Local nQtdEntid	:= Iif(FindFunction("CtbQtdEntd"),CtbQtdEntd(),4) //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor

If lEntidad05
	aAdd(aTamVlr, GetSx3Cache("CQ1_DEBITO","X3_TAMANHO"))
	aAdd(aTamVlr, GetSx3Cache("CQ1_DEBITO","X3_DECIMAL"))
Else
	aTamVlr := TamSX3("CQ1_DEBITO")
EndIf
aCampos := {{"IDENT"	,"C",3			,0},;
 		    {"CONTA" 	,"C",nTamCta	,0},;
 		    {"CUSTO" 	,"C",nTamCC		,0},;
 			{"ITEM"  	,"C",nTamItem	,0},;
 			{"CLVL" 	,"C",nTamClvl	,0},;
   			{"SALDOD"	,"N",aTamVlr[1]+2,aTamVlr[2]},;
   			{"SALDOC"	,"N",aTamVlr[1]+2,aTamVlr[2]},;
   			{"TPSALDO"	,"C",1			,0},;
			{"MOEDA"	,"C",2			,0},;
			{"JAPROC"	,"C",1			,0}}

If lEntidad05
	aAdd(aCampos, {"ENT05" 	,"C",nTamE05	,0})
EndIf

// Inclui as novas entidades
For nInc := 1 To ( nQtdEntid - 4 )
    cCpoDeb := CtbCposCrDb("", "D", StrZero(nInc + 4,2))
	cCpoCrd := CtbCposCrDb("", "C", StrZero(nInc + 4,2))

	aAdd( aCampos, { cCpoDeb, "C", 200, 0 } )
	aAdd( aCampos, { cCpoCrd, "C", 200, 0 } )
Next

If Empty(cArqTRB)
	cArqTRB := cNomeArq
EndIf

If Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
Endif

If lCriaTRB
	If _oCTBA2111 <> Nil	  // Se tabela temporaria de saldos finais j� existir

		cTitMsg := STR0023//"Arquivo de saldos finais j� existe."
		cMsg	:= STR0024+_oCTBA2111:GetRealName()+CHR(13)+CHR(10)         ///"Arquivo encontrado: "
		cMsg	+= STR0025//"Carregar novamente saldos ? "

		nRetMsg := Aviso(cTitMsg,cMsg, { STR0026,STR0027,STR0028 } )//"Sim"//"N鉶"//"Sair"

		If nRetMsg == 1
			/// CASO A TRANSFER蔔CIA DE LANCAMENTOS J� TENHA SIDO INICIADA
			If lJaProc .and. !MsgNoYes(STR0029+chr(13)+chr(10)+STR0030,STR0031)//"Recalcular os saldos pode afetar os valores de apuracao, caso j� existam lan鏰mentos de apuracao."//"Deseja Realmente continuar ?"//"A T E N C � O !!!"
				Return .F.
			EndIf

			_oCTBA2111:Delete()
			_oCTBA2111 := Nil

			lNovoTRB := .T.					/// UTILIZA O ARQUIVO DE SALDOS J� CALCULADO (RECOMENDADO SE N肙 TRANSFERIU LANCAMENTOS)
		ElseIf nRetMsg == 2
			lNovoTRB := .F.
		Else
			Return .F.
		EndIf
	EndIf
Else
    If _oCTBA2111 == Nil

		cMsg := STR0034+cArqTRB+GetDbExtension()+STR0035+CHR(13)+CHR(10)+STR0036//"Arquivo de Saldos "//" n鉶 encontrado ! "//"Recalcular saldos e continuar ?"

		If lJaProc
			cMsg += CHR(13)+CHR(10)+STR0037//"(Recalcular os saldos finais podera afetar o valor de apuracao se j� foram movidos lan鏰mentos)."
		EndIf

		nRetMsg := Aviso(STR0031,cMsg, { STR0026,STR0027 } )//"Aten玢o!!!"//"Sim"//"N鉶"

		If nRetMsg == 1
			lNovoTRB := .T.
		Else
			Return .F.
		EndIf
	Else
		lNovoTRB := .F.
	EndIf
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪�11哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Crio arq. de trab. p/ gravar as inconsistencias.           �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If lNovoTRB

	If _oCTBA2111 <> Nil
		_oCTBA2111:Delete()
		_oCTBA2111 := Nil
	Endif

	_oCTBA2111 := FWTemporaryTable():New( "TRB" )
	_oCTBA2111:SetFields(aCampos)

	If !lEntidad05
		_oCTBA2111:AddIndex("1", {"TPSALDO","MOEDA","CONTA","CUSTO","ITEM","CLVL","IDENT"})
		_oCTBA2111:AddIndex("2", {"TPSALDO","MOEDA","IDENT","CONTA","CUSTO","ITEM","CLVL"})
	Else
		_oCTBA2111:AddIndex("1", {"TPSALDO","MOEDA","CONTA","CUSTO","ITEM","CLVL","ENT05","IDENT"})
		_oCTBA2111:AddIndex("2", {"TPSALDO","MOEDA","IDENT","CONTA","CUSTO","ITEM","CLVL","ENT05"})
	EndIf

	//------------------
	//Cria玢o da tabela temporaria
	//------------------
	_oCTBA2111:Create()

EndIf

dbSelectArea( "TRB" )
dbSetOrder(1)

Return .T.

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯TB211GTRB� Autor � Marcos S. Lobo        � Data � 26.09.06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 砎erifico os Saldos e Grava no Arquivo de Trabalho			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矯TB211GTRB()                                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � CTBA211                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
FUNCTION CTB211GTRB(cAlias,dDataILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoedaEsp,oSelf,lAuto)

Local lObj := ValType(oObj) == "O"

Local nRecno	:=	0
Local nTotRegua	:= ((cAlias)->(Reccount()))
Local cConta 	:= SPACE(nTamCta)
Local cCusto 	:= SPACE(nTamCC)
Local cItem  	:= SPACE(nTamItem)
Local cClVl		:= SPACE(nTamClVl)

Local nMoedAtu	:= 1
Local cMoedAtu	:= "01"
Local nTpSldAtu	:= 1
Local cTpSldAtu	:= "1"

Local aSldAnt	:= {}
Local aSldAtu	:= {}
Local nDebTrb	:= 0
Local nCrdTrb	:= 0
Local nTrbSlD	:= 0
Local nTrbSlC	:= 0
Local cKeyAtu	:= ""

Local lFiltra	:= ValType(aFilters) == "A"
Local lFilCT	:= .F.
Local lFilCC	:= .F.
Local lFilIT	:= .F.
Local lFilCL	:= .F.
Local lVai		:= .F.
Local lApZero	:= GetNewPar( "MV_CTAPMVZ" , .T. )
Local cEnt05	:= IIF(lEntidad05, cSpacE05, "")

DEFAULT lSaldo  := .F.			/// PADRAO .F. OBTEM MOVIMENTO / .T. OBTEM SALDO
DEFAULT dDataILP:= CTOD("01/01/80")-1

If lFiltra
	lFilCT := Len(aFilters) >= 1 .and. Len(aFilters[1]) >= 3 .and. (!Empty(aFilters[1][2]) .or. !Empty(aFilters[1][3]) )
	lFilCC := Len(aFilters) >= 2 .and. Len(aFilters[2]) >= 3 .and. (!Empty(aFilters[2][2]) .or. !Empty(aFilters[2][3]) )
	lFilIT := Len(aFilters) >= 3 .and. Len(aFilters[3]) >= 3 .and. (!Empty(aFilters[3][2]) .or. !Empty(aFilters[3][3]) )
	lFilCL := Len(aFilters) >= 4 .and. Len(aFilters[3]) >= 3 .and. (!Empty(aFilters[4][2]) .or. !Empty(aFilters[4][3]) )
EndIf

dbSelectArea(cAlias)
If cAlias $ "CQ0/CQ1"
	dbSetOrder(2)
Else
	dbSetOrder(3)
Endif
cFilAlias := xFilial(cAlias)



If !lMoedaEsp
	//// FAZ O PROCESSAMENTO PARA TODAS AS MOEDAS
	nMoedaIni := 1
Else
	/// SE FOR MOEDA ESPEC虵ICA INICIA PELA MOEDA INDICADA
	nMoedaIni := Val(cMoedaEsp)
EndIf

For nMoedAtu := nMoedaIni to __nQuantas
	cMoedAtu := STRZERO(nMoedAtu,2)

	//// FAZ O PROCESSAMENTO PARA TODOS OS TIPOS DE SALDOS
	For nTpSldAtu := 1 to Len(aTpSaldos)
		// cTpSldAtu := STRZERO(nTpSldAtu,1)
		//
		cTpSldAtu := aTpSaldos[nTpSldAtu]

		If !lAuto
			If lObj
				oObj:SetRegua2(nTotRegua)
			Else
				oSelf:SetRegua1(nTotRegua)
			EndIf
		Endif

		If lFilCT
			MsSeek(cFilAlias+aFilters[1][2],.T.) //Procuro pela primeira conta a ser zerada
		Else
			MsSeek(cFilAlias,.T.) //Procuro pela primeira conta a ser zerada
		EndIf

		While (cAlias)->(!Eof()) .And. (cAlias)->&(cAlias+"_FILIAL") == cFilAlias .and. (If(lFilCT,(cAlias)->&(cAlias+"_CONTA") <= aFilters[1][3],.T.))

			If !lAuto
				If lObj
					oObj:IncRegua2(OemToAnsi(STR0019+cMoedAtu+STR0020+cTpSldAtu))//#"Passo 1 -> Obtendo Saldos... Moeda "//" Saldo "
				Else
					oSelf:IncRegua1(OemToAnsi(STR0019+cMoedAtu+STR0020+cTpSldAtu))//#"Passo 1 -> Obtendo Saldos... Moeda "//" Saldo "
				EndIf
			Endif

			If cAlias == 'CQ7'
				cChave := CQ7->(CQ7_CONTA+CQ7_CCUSTO+CQ7_ITEM+CQ7_CLVL)
				cConta := CQ7->CQ7_CONTA
				cCusto := CQ7->CQ7_CCUSTO
				cItem  := CQ7->CQ7_ITEM
				cClVl  := CQ7->CQ7_CLVL
			ElseIf cAlias == 'CQ5'
				cChave := CQ5->(CQ5_CONTA+CQ5_CCUSTO+CQ5_ITEM)
				cConta := CQ5->CQ5_CONTA
				cCusto := CQ5->CQ5_CCUSTO
				cItem  := CQ5->CQ5_ITEM
			ElseIf cAlias == 'CQ3'
				cChave := CQ3->(CQ3_CONTA+CQ3_CCUSTO)
				cConta := CQ3->CQ3_CONTA
				cCusto := CQ3->CQ3_CCUSTO
			ElseIf cAlias == 'CQ1'
				cChave := CQ1->CQ1_CONTA
				cConta := CQ1->CQ1_CONTA
			ElseIf lEntidad05 .And. cAlias == 'QL7'
				cChave := QL7->(QL7_CONTA+QL7_CCUSTO+QL7_ITEM+QL7_CLVL+QL7_ENT05)
				cConta := QL7->QL7_CONTA
				cCusto := QL7->QL7_CCUSTO
				cItem  := QL7->QL7_ITEM
				cClVl  := QL7->QL7_CLVL
				cEnt05 := QL7->QL7_ENT05
			EndIf

			cNxtChav:= IncLast(cChave)		/// DETERMINA A PROXIMA CHAVE DE PESQUISA COM O CODIGO DAS ENTIDADES

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//矨valia filtro das entidades para apuracao�
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			If lEntidad05 .And. cAlias == 'QL7'
				If lFilCT
					If QL7->QL7_CONTA < aFilters[1][2] .or. QL7->QL7_CONTA > aFilters[1][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf
				If lFilCC
					If QL7->QL7_CCUSTO < aFilters[2][2] .or. QL7->QL7_CCUSTO > aFilters[2][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf
				If lFilIT
					If QL7->QL7_ITEM < aFilters[3][2] .or. QL7->QL7_ITEM > aFilters[3][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf
				If lFilCL
					If QL7->QL7_CLVL < aFilters[4][2] .or. QL7->QL7_CLVL > aFilters[4][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf

			ElseIf cAlias == 'CQ7'
				If lFilCT
					If CQ7->CQ7_CONTA < aFilters[1][2] .or. CQ7->CQ7_CONTA > aFilters[1][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf
				If lFilCC
					If CQ7->CQ7_CCUSTO < aFilters[2][2] .or. CQ7->CQ7_CCUSTO > aFilters[2][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf
				If lFilIT
					If CQ7->CQ7_ITEM < aFilters[3][2] .or. CQ7->CQ7_ITEM > aFilters[3][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf
				If lFilCL
					If CQ7->CQ7_CLVL < aFilters[4][2] .or. CQ7->CQ7_CLVL > aFilters[4][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf

			ElseIf cAlias == 'CQ5'
				If lFilCT
					If CQ5->CQ5_CONTA < aFilters[1][2] .or. CQ5->CQ5_CONTA > aFilters[1][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf
				If lFilCC
					If CQ5->CQ5_CCUSTO < aFilters[2][2] .or. CQ5->CQ5_CCUSTO > aFilters[2][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf
				If lFilIT
					If CQ5->CQ5_ITEM < aFilters[3][2] .or. CQ5->CQ5_ITEM > aFilters[3][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf

			ElseIf cAlias == 'CQ3'
				If lFilCT
					If CQ3->CQ3_CONTA < aFilters[1][2] .or. CQ3->CQ3_CONTA > aFilters[1][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf
				If lFilCC
					If CQ3->CQ3_CCUSTO < aFilters[2][2] .or. CQ3->CQ3_CCUSTO > aFilters[2][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf

			ElseIf cAlias == 'CQ1'
				If lFilCT
					If CQ1->CQ1_CONTA < aFilters[1][2] .or. CQ1->CQ1_CONTA > aFilters[1][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf

			EndIf

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪T�
			//矨pos filtragem , obtem saldos ate a data.�
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪T�
			If cAlias == 'CQ7'
				If !lSaldo
					aSldAnt	:= SaldoCTI(cConta,cCusto,cItem,cClVL,dDataILP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)
				EndIf
				aSldAtu	:= SaldoCTI(cConta,cCusto,cItem,cClVL,dDataFLP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)
			ElseIf cAlias == 'CQ5'
				If !lSaldo
					aSldAnt	:= SaldoCT4(cConta,cCusto,cItem,dDataILP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)
				EndIf
				aSldAtu	:= SaldoCT4(cConta,cCusto,cItem,dDataFLP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)
			ElseIf cAlias == 'CQ3'
				If !lSaldo
					aSldAnt	:= SaldoCT3(cConta,cCusto,dDataILP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)
				EndIf
				aSldAtu	:= SaldoCT3(cConta,cCusto,dDataFLP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)
			ElseIf cAlias == 'CQ1'
				If !lSaldo
					aSldAnt	:= SaldoCT7(cConta,dDataILP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)
				EndIf
				aSldAtu	:= SaldoCT7(cConta,dDataFLP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)
			ElseIf lEntidad05 .And. cAlias == 'QL7'
				If !lSaldo
					aSldAnt := SaldoCQ("CV0",cConta,cCusto,cItem,cClVL,/*cIdent*/,dDataILP,cMoedAtu,cTpSldAtu,"CTBXFUN",.F.,/*dDataLP*/,/*cFilEsp*/,/*lUltDtVl*/,cEnt05)
				EndIf
				aSldAtu := SaldoCQ("CV0",cConta,cCusto,cItem,cClVL,/*cIdent*/,dDataFLP,cMoedAtu,cTpSldAtu,"CTBXFUN",.F.,/*dDataLP*/,/*cFilEsp*/,/*lUltDtVl*/,cEnt05)
			EndIf

			nTrbSlD := 0
			nTrbSlC := 0
			dbSelectArea("TRB")
			dbSetOrder(2)

			lVai := .F.
			If lSaldo								/// SE FOR APURACAO PELO SALDO
				If aSldAtu[1] <> 0 					/// SE HOUVER SALDO
					lVai := .T.
				EndIf
			Else
				If ( aSldAtu[4] - aSldAnt[4]) <> 0 .or. (aSldAtu[5] - aSldAnt[5] <> 0  )     /// SE HOUVER MOVIMENTO
					IF !lApZero
						lVai := ( (( aSldAtu[4] - aSldAnt[4]) - (aSldAtu[5] - aSldAnt[5] ) ) <> 0 )
					Else
					    lVai := .T.
					Endif
				EndIf
			EndIf

			If lVai
				If lEntidad05 .And. cAlias == "CQ7"
					cKeyAtu := cTpSldAtu+cMoedAtu+"QL7"+cConta+cCusto+cItem+cClVL
					If dbSeek(cKeyAtu,.F.)
						While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA+CUSTO+ITEM+CLVL)
							nTrbSlD += TRB->SALDOD
							nTrbSlC += TRB->SALDOC
							TRB->(dbSkip())
						EndDo
					EndIf
				ElseIf cAlias == "CQ5" //.or. (cAlias == "CT3" .and. !lItem)
					If lClvl
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ7"+cConta+cCusto+cItem
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA+CUSTO+ITEM)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo
						EndIf
					EndIf
					If lEntidad05
						cKeyAtu := cTpSldAtu+cMoedAtu+"QL7"+cConta+cCusto+cItem
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA+CUSTO+ITEM)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo
						EndIf
					EndIf
				ElseIf cAlias == "CQ3" //.or. (cAlias == "CT7" .and. !lCusto)
					If lItem
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ5"+cConta+cCusto
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA+CUSTO)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo
						EndIf
					EndIf

					/// SE N肙 LOCALIZOU CHAVE NO CT4 VERIFICA SE H� NO CTI
					If lClvl
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ7"+cConta+cCusto
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA+CUSTO)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo
						EndIf
					EndIf

					If lEntidad05
						cKeyAtu := cTpSldAtu+cMoedAtu+"QL7"+cConta+cCusto
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA+CUSTO)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo
						EndIf
					EndIf
				ElseIf cAlias == "CQ1"
					If lCusto
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ3"+cConta
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo
						EndIf
					EndIf
					/// SE N肙 LOCALIZOU CHAVE NO CT3 VERIFICA SE H� NO CT4
					If lItem
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ5"+cConta
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo
						EndIf
					EndIf

					/// SE N肙 LOCALIZOU CHAVE NO CT4 VERIFICA SE H� NO CTI
					If lClvl
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ7"+cConta
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo
						EndIf
					EndIf

					If lEntidad05
						cKeyAtu := cTpSldAtu+cMoedAtu+"QL7"+cConta
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo
						EndIf
					EndIf
				EndIf

				/// CALCULA OS VALORES A DEBITO E A CREDITO PARA LANCAMENTO
				/// ABATENDO OS VALORES J� LAN茿DOS COM OUTRAS ENTIDADES
				If lSaldo
					nDebTrb := ABS(aSldAtu[4]) - nTrbSlD
					nCrdTrb := ABS(aSldAtu[5]) - nTrbSlC
				Else
					nDebTrb := (ABS(aSldAtu[4]) - ABS(aSldAnt[4])) - nTrbSlD
					nCrdTrb := (ABS(aSldAtu[5]) - ABS(aSldAnt[5])) - nTrbSlC
				EndIf

				dbSelectArea("TRB")
				dbSetOrder(1)
				If lEntidad05 // Trecho localizado COL|PER vari醰el static.
					If (nDebTrb <> 0 .or. nCrdTrb <> 0) .and. !dbSeek(cTpSldAtu+cMoedAtu+cConta+cCusto+cItem+cClvl+cEnt05+cAlias,.F.)
						dbSetOrder(2)
						RecLock("TRB",.T.)
						Field->TPSALDO	:= cTpSldAtu
						Field->MOEDA	:= cMoedAtu
						Field->CONTA	:= cConta
						Field->CUSTO	:= cCusto
						Field->ITEM		:= cItem
						Field->CLVL		:= cClVL
						Field->IDENT	:= cAlias
						Field->SALDOD	:= ABS(nDebTrb)
						Field->SALDOC	:= ABS(nCrdTrb)
						If lEntidad05
							Field->ENT05  := cEnt05
						EndIf
						Field->CT2_EC05DB := cEnt05
						Field->CT2_EC05CR := cEnt05
						TRB->(MsUnlock())
					EndIf
				ElseIf (nDebTrb <> 0 .or. nCrdTrb <> 0) .and. !dbSeek(cTpSldAtu+cMoedAtu+cConta+cCusto+cItem+cClvl+cAlias,.F.)
					dbSetOrder(2)
					RecLock("TRB",.T.)
					Field->TPSALDO	:= cTpSldAtu
					Field->MOEDA	:= cMoedAtu
					Field->CONTA	:= cConta
					Field->CUSTO	:= cCusto
					Field->ITEM		:= cItem
					Field->CLVL		:= cClVL
					Field->IDENT	:= cAlias
					Field->SALDOD	:= ABS(nDebTrb)
					Field->SALDOC	:= ABS(nCrdTrb)
					TRB->(MsUnlock())
				EndIf
			EndIf

			dbSelectArea(cAlias)
			(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
		EndDo
	Next nTpSldAtu
	If lMoedaEsp		/// SE FOR MOEDA ESPEC虵ICA ENCERRA AO FINAL DA 1� PASSAGEM (FOR NEXT)
		nMoedAtu := __nQuantas
		Exit
	Endif
Next nMoedAtu

Return
/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯t211ValIt� Autor � Simone Mie Sato       � Data � 22.01.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 砎erifica se o item ponte e item L/P estao preenchidos.      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矯t211ValIt()                                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Ct211ValIt()                                               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
FUNCTION Ct211ValIt(cItem,cItemPon,cItemLp,lPontes,lItemOk,lCadastro)

Local aSaveArea	:= GetArea()

dbSelectArea("CTD")
dbSetOrder(1)
If lCadastro	//Se utiliza item ponte/LP do Cadastro de Item.
	MsSeek(xFilial("CTD")+cItem)
	If Found()
		If	lPontes .And. Empty(CTD->CTD_ITPON)
			lItemOk 	:= .F.
		ElseIf Empty(CTD->CTD_ITLP)
			lItemOk 	:= .T.
			cItemPon	:= CTD->CTD_ITPON
			cItemLP		:= cItem
		Else
			lItemOk 	:= .T.
			cItemPon	:= CTD->CTD_ITPON
			cItemLP		:= CTD->CTD_ITLP
		Endif
	Endif
Else
	If lPontes
		If Subs(CTD->CTD_ITPON,1,1) = "*"
			lItemOk	:= .F.
		EndIf
		MsSeek(xFilial("CTD")+cItemPon)
	Else
		If Subs(CTD->CTD_ITLP,1,1) = "*"
			lItemOk	:= .F.
		EndIf
		MsSeek(xFilial("CTD")+cItemLP)
	EndIf

	If lItemOk .And. !Found()
		lItemOk		:= .F.
	EndIf
EndIf

RestArea(aSaveArea)

Return


/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯t211ValCC� Autor � Simone Mie Sato       � Data � 02.01.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 砎erifica se o C.C. ponte e C.C. L/P estao preenchidos.      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矯t211ValCC()                                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Ct211ValCC()                                               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
FUNCTION Ct211ValCC(cCusto,cCCPon,cCCLp,lPontes,lCCOk,lCadastro)

Local aSaveArea	:= GetArea()

dbSelectArea("CTT")
dbSetOrder(1)
If lCadastro//Se utiliza c.cust Ponte/LP do Cadastro de Centro de Custo
	MsSeek(xFilial("CTT")+cCusto)
	If Found()
		If lPontes .And. Empty(CTT->CTT_CCPON)
			lCCOk 		:= .F.
		ElseIf Empty(CTT->CTT_CCLP)
			lCCOk		:= .T.
			cCCPon 		:= CTT->CTT_CCPON
			cCCLP		:= cCusto
		Else
			lCCOk		:= .T.
			cCCPon 		:= CTT->CTT_CCPON
			cCCLP		:= CTT->CTT_CCLP
		Endif
	Endif
Else
	If lPontes
		If Subs(CTT->CTT_CCPON,1,1) = "*"
			lCCOk		:= .F.
		EndIf
		MsSeek(xFilial("CTT")+cCCPon)
	Else
		If Subs(CTT->CTT_CCLP,1,1) = "*"
			lCCOk		:= .F.
		EndIf
		MsSeek(xFilial("CTT")+cCCLP)
	EndIf
	If lCCOk .And. !Found()
		lCCOk	:= .F.
	EndIf
EndIf

RestArea(aSaveArea)

Return

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯t211ValCV� Autor � Simone Mie Sato       � Data � 02.01.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 砎erifica se a Cl.Vlr Ponte e Cl.Vlr LP estao preenchidos.   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矯t211ValCV()                                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Ct211ValCV()                                               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
FUNCTION Ct211ValCV(cClVl,cClVlPon,cClVlLP,lPontes,lClVlOk,lCadastro)

Local aSaveArea	:= GetArea()

dbSelectArea("CTH")
dbsetOrder(1)
MsSeek(xFilial("CTH")+cClVl)

If lCadastro//Se utiliza Cl.Valor Ponte/LP do Cadastro de Cl.Valor
	If Found()
		If	lPontes .And. Empty(CTH->CTH_CLPON)
			lClVlOk 	:= .F.
		ElseIf Empty(CTH->CTH_CLVLLP)
			lClVlOk 	:= .T.
			cClVlPon	:= CTH->CTH_CLPON
			cClVlLP		:= cClVl
		Else
			lClVlOk 	:= .T.
			cClVlPon	:= CTH->CTH_CLPON
			cClVlLP		:= CTH->CTH_CLVLLP
		Endif
	Endif
Else
	If lPontes
		If Subs(CTH->CTH_CLPON,1,1) = "*"
			lClVlOk		:= .F.
		EndIf
		MsSeek(xFilial("CTH")+cClVlPon)
	Else
		If Subs(CTH->CTH_CLVLLP,1,1) = "*"
			lClVlOk		:= .F.
		EndIf
		MsSeek(xFilial("CTH")+cClVlLP)
	EndIf
	If lClVlOk .And. !Found()
		lClVlOk	:= .F.
	EndIf
EndIf

RestArea(aSaveArea)

Return

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯t211ValCt� Autor � Simone Mie Sato       � Data � 02.01.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 砎erifica se a Conta Ponte e Conta LP estao preenchidas.     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矯t211ValCt()                                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � CTBA211()                                                  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function Ct211ValCt(cConta,cCtaPon,cDigPon,cCtaLP,cDigLP,lPontes,lCtaOk,aCriter,aCritPon,aCritLP,lCadastro,lAutomato,cMsgErroPg)
Local aSaveArea := GetArea()
Local nMoedas   := __nQuantas
Local nCont     := 0
Local lExibeMsg := .F.

Default lAutomato  := _lBlind
Default cMsgErroPg := ""

dbSelectArea( "CT1" )
dbsetOrder( 1 )
MsSeek( xFilial( "CT1" ) + cConta )
lExibeMsg := Empty( cMsgErroPg )

If lCadastro	//Se utiliza Conta Ponte/LP do Cadastro de Plano de Contas
	If Found()
		If	( Empty( CT1->CT1_CTALP )  .Or. ;
			( lPontes .And. Empty( CT1->CT1_CTAPON ) ) )
			lCtaOk 	:= .F.
		Else
			lCtaOk 	:= .T.
			cCtaPon	:= CT1->CT1_CTAPON
			cCtaLP 	:= CT1->CT1_CTALP
		EndIf
	EndIf
Else
	If lPontes
		If Subs( CT1->CT1_CTAPON , 1 , 1 ) == "*"
			lCtaOk	:= .F.
		EndIf

		MsSeek( xFilial("CT1") + cCtaPon )
	Else
		If Subs( CT1->CT1_CTALP , 1 , 1 ) == "*"
			lCtaOk	:= .F.
		EndIf

		MsSeek( xFilial("CT1") + cCtaLP )
	EndIf

	If lCtaOk .And. !Found()
		lCtaOk	:= .F.
	EndIf
EndIf

If lCtaOk
	For nCont := 1 To (nMoedas - 1 )
		aAdd( aCriter , &("CT1->CT1_CVD"+StrZero(nCont+1,2)) )
	Next nCount

	MsSeek( xFilial( "CT1" ) + cCtaPon )
	cDigPon := CT1->CT1_DC

	For nCont := 1 To ( nMoedas - 1 )
		aAdd( aCritPon , &("CT1->CT1_CVD"+StrZero(nCont+1,2)) )
	Next nCount

	MsSeek( xFilial( "CT1" ) + cCtaLP )
	cDigLP	:= CT1->CT1_DC

	For nCont := 1 To ( nMoedas - 1 )
		aAdd( aCritLP , &("CT1->CT1_CVD"+StrZero(nCont+1,2)) )
	Next nCount
Else
	If lExibeMsg .And. !lCadastro
		If lPontes
			cMsgErroPg := OemToAnsi( STR0118 )
		Else
			cMsgErroPg := OemToAnsi( STR0117 )
		EndIf

		If !_lBlind .And. !lAutomato
			MsgInfo( cMsgErroPg )
		EndIf
	Else
		cMsgErroPg := ""
	EndIf
EndIf

RestArea( aSaveArea )

Return Nil

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯t211AtSX5� Autor � Simone Mie Sato       � Data � 11.01.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 矨tualizo a tabela do SX5.                                   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矯t211AtSX5(dDataFLP)                                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      矯t211AtSX5()                                                潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
FUNCTION Ct211AtSX5(dDataFLP,lMoedaEsp,cMoeda,nInicio,nFinal,cTpSaldo,lPontes)

Local aSaveArea	:= GetArea()
Local cChave	:= cEmpAnt+cFilant
Local cCampo	:= ""
Local lExiste	:= .F.
Local nContad
Local cChar		:= ""

// Caso a tabela LP exista na tabela CW0 o processo ser� feito por ela e nao pela SX5
If CtLPCW0Tab()
	CtAtLPCW0(dDataFLP,lMoedaEsp,cMoeda,nInicio,nFinal,cTpSaldo,lPontes)
	dbSelectArea("CW0")
	FKCOMMIT()
EndIf


RestArea(aSaveArea)

Return




/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯t211GrCTZ� Autor � Marcos S. Lobo        � Data � 26.09.06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 矴rava Registros ref. o arquivo CTZ.                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矯t211GrCTZ(aGrvLan)                                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      矯t211GrCTZ()                                                潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function Ct211GrCTZ(dDataFLP,cLote,cSubLote,cDoc,cLinha,cMoedLC,cTpSald,;
					cTipo,nValorLC,cConta,cCusto,cItem,cCLVL,cEnt05)

Local aSaveArea		:= GetArea()
Local cSeqLiCTZ		:= ""
Local nLCTZSeqLin	:= 0
Local cFilCTZ		:= ""
Local cLastSeqLin	:= ""

Default cEnt05		:= ""

dbSelectArea("CTZ")
dbSetOrder(1)	//DATA+LOTE+SUBLOTE+DOC+TP SALDO+EMPORI+FILORI+MOEDA+LINHA+SEQLIN
cFilCTZ	:= xFilial("CTZ")
nLCTZSeqLin := Len(CTZ->CTZ_SEQLIN)				/// TAMANHO DO CTZ_SEQLIN
cSeqLiCTZ	:= StrZero(0,nLCTZSeqLin)			/// INICIALIZA CTZ_SEQLIN
cLastSeqLin	:= Replicate("z",nLCTZSeqLin)		/// ULTIMO CTZ_SEQLIN POSS蚔EL

/// CASO MUDE A LINHA DE LAN茿MENTO OU DOCUMENTO
/// FAZ VERIFICA钦ES DE EXISTENCIA DA LINHA NO CTZ
If __cKeyCTZATU <> cFilCTZ+dtos(dDataFLP)+cLote+cSubLote+cDoc+cTpSald+cEmpAnt+cFilAnt+cMoedLC+cLinha
	/// SE ENCONTRAR MESMA LINHA DO CT2 NO CTZ -> INCREMENTA SEQUENCIAL DO CTZ
	If MsSeek(cFilCTZ+dtos(dDataFLP)+cLote+cSubLote+cDoc+cTpSald+cEmpAnt+cFilAnt+cMoedLC+cLinha,.F.)
		/// LOCALIZA 贚TIMA SEQUENCIA DE CTZ UTILIZADA PARA A LINHA
		MsSeek(cFilCTZ+dtos(dDataFLP)+cLote+cSubLote+cDoc+cTpSald+cEmpAnt+cFilAnt+cMoedLC+cLinha+cLastSeqLin,.T.)
		dbSkip(-1)
		/// DETERMINA A PR覺IMA SEQUECIA DE CTZ
		cSeqLiCTZ := Soma1(CTZ->CTZ_SEQLIN)
	Else
		/// SE N肙 ENCONTRAR A MESMA LINHA DO CT2 NO CTZ
	    cSeqLiCTZ := StrZero(1,nLCTZSeqLin)
	EndIf

	__cKeyCTZATU := cFilCTZ+dtos(dDataFLP)+cLote+cSubLote+cDoc+cTpSald+cEmpAnt+cFilAnt+cMoedLC+cLinha
Else
	cSeqLICTZ := Soma1(__cSeqLICTZ)
EndIf

/// VERIFICA SE A PROXIMA SEQUENCIA DE CTZ N肙 EXISTE
While MsSeek(cFilCTZ+dtos(dDataFLP)+cLote+cSubLote+cDoc+cTpSald+cEmpAnt+cFilAnt+cMoedLC+cLinha+cSeqLiCTZ,.F.)
	If cSeqLiCTZ >= cLastSeqLin
		/// SE HOUVER ESTOURO DA QUANTIDADE DE SEQUENCIAS PARA 1 LINHA
		If !_lBlind
			MsgAlert("Contact the Administrator. "+CRLF+;
			"The CTZ_SEQLIN Field Length it磗 too short, try to increase field length."+CRLF+;
			"The next sequences of this line will be recorded with line 'zzz',"+;
			 "duplicate key errors can happen.","CTBA211 Alert")
		EndIf
		CONOUT("CTBA211 ALERT!"+CRLF+"Contact the Administrator."+CRLF+"The CTZ_SEQLIN Field Length it磗 too short, try to increase field length.")
		cLinha := Replicate("z",Len(CTZ->CTZ_LINHA))
		cSeqLiCTZ := StrZero(0,nLCTZSeqLin)
	EndIf
	cSeqLiCTZ := Soma1(cSeqLiCTZ)
EndDo

__cSeqLICTZ := cSeqLiCTZ

dbSelectArea("CTZ")
//Sempre sera incluido um novo registro no CTZ
Reclock("CTZ",.T.)
CTZ_FILIAL	:= cFilCTZ
CTZ_DATA	:= dDataFLP
CTZ_LOTE	:= cLote
CTZ_SBLOTE	:= cSubLote
CTZ_DOC		:= cDoc
CTZ_LINHA	:= cLinha
CTZ_SEQLIN	:= cSeqLiCTZ
CTZ_TPSALD	:= cTPSald
CTZ_CONTA	:= cConta
CTZ_CUSTO	:= cCusto
CTZ_ITEM	:= cItem
CTZ_CLVL	:= cCLVL
CTZ_MOEDLC	:= cMoedLC
CTZ_EMPORI	:= cEmpAnt
CTZ_FILORI	:= cFilAnt
If cTipo == "1"
	CTZ_VLRDEB	:= nValorLC
ElseIf cTipo == "2"
	CTZ_VLRCRD	:= nValorLC
EndIf
If lEntidad05
	If cTipo == "1"
		CTZ_EC05DB := cEnt05
	ElseIf cTipo == "2"
		CTZ_EC05CR := cEnt05
	EndIf
EndIf
MsUnlock()

RestArea(aSaveArea)

Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矯TBA211   篈utor  矼arcos S. Lobo      � Data �  26.09.06   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     �                                                            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function Ct211FlgLP(cConta,cCusto,cItem,cCLVL, dDataILP, cTpSald, dDataFLP, cMoeda, cEnt05)

Local cKeyFlag := alltrim(cFilAnt+cMoeda+cTpSald+cConta+cCusto+cItem+cClVL)
Local nLenKey	  := Len(alltrim(cKeyFlag))
Local lReproc := mv_par28 == 1

Default cEnt05	:= ""
/*Foi necess醨ia prote玢o para nao fazer atualiza玢o nesse processo pois causava errorlog
a atualiza玢o das flags j� � realizada no reprocessamento com ou sem procedure
protegido para Brasil para n鉶 afetar regras de apura玢o MI */
If !(cPaisLoc == 'BRA' )

	If AsCan(__aJaFlag,{|x| Substr(x,1,nLenKey) == cKeyFlag }) <= 0
		If lReproc
			If lEntidad05 .And. !Empty(cEnt05)
				Ct190FlgLP(cFilAnt, "QL6", cConta,cCusto,cItem,cCLVL, dDataILP, cTpSald, dDataFLP, cMoeda,,"S",cEnt05)
			EndIf
			If !Empty(cCLVL)
				Ct190FlgLP(cFilAnt, "CTI", cConta,cCusto,cItem,cCLVL, dDataILP, cTpSald, dDataFLP, cMoeda,,"S")
			EndIf
			If !Empty(cITEM)
				Ct190FlgLP(cFilAnt, "CT4", cConta,cCusto,cItem,"", dDataILP, cTpSald, dDataFLP, cMoeda,,"S")
			EndIf
			If !Empty(cCUSTO)
				Ct190FlgLP(cFilAnt, "CT3", cConta,cCusto,"","", dDataILP, cTpSald, dDataFLP, cMoeda,,"S")
			EndIf
			If !Empty(cConta)
				Ct190FlgLP(cFilAnt, "CT7", cConta,"","","", dDataILP, cTpSald, dDataFLP, cMoeda,,"S")
			EndIf
		Endif

		If lReproc
			/// MARCA FLAG NAS TABELAS DE SALDOS COMPOSTOS
			If lEntidad05 .And. !Empty(cEnt05)
				Ct190FlgLP(cFilAnt, "CTU", "","","","", dDataILP, cTpSald, dDataFLP, cMoeda,"QL6","S",cEnt05)
			EndIf
			If !Empty(cCLVL)
				Ct190FlgLP(cFilAnt, "CTU", "","","",cCLVL, dDataILP, cTpSald, dDataFLP, cMoeda,"CTH","S")
			EndIf
			If !Empty(cITEM)
				Ct190FlgLP(cFilAnt, "CTU", "","",cITEM,"", dDataILP, cTpSald, dDataFLP, cMoeda,"CTD","S")
			EndIf
			If !Empty(cCUSTO)
				Ct190FlgLP(cFilAnt, "CTU", "",cCUSTO,"","", dDataILP, cTpSald, dDataFLP, cMoeda,"CTT","S")
			EndIf
		Endif
		AAdd(__aJaFlag,cKeyFlag)
	EndIf

	If !lReproc
		// for鏾 a atualiza玢o do flag de reprocessamento de saldo.
		PutCv7Date(cTpSald,cMoeda,cTod(""))
	Endif
Endif

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矯TBA211   篈utor  矼arcos S. Lobo      � Data �  26/09/06   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     �                                                            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function MostraSX5LP()

Local a
Local b
Local c
Local aAreaOri := GetArea()
Local aAreaX5  := SX5->(GetArea())

// Caso a tabela LP exista na tabela CW0 o processo ser� feito por ela e nao pela SX5
If CtLPCW0Tab()
	CtMosLPCW0()
Else
	dbSelectArea("SX5")
	aAreax5 := GetArea()
	dbSetOrder(1)
	If !MsSeek(xFilial("SX5")+"LP",.F.)
		MsgInfo(STR0041,STR0042)//"N鉶 existem apura珲es registradas."//"Tabela LP - Apura珲es de resultado"
	Else
		ConPad1(a,b,c,"CTZ",,,.F.)
	EndIf
EndIf

RestArea(aAreaX5)
RestArea(aAreaOri)

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矯TBA211   篈utor  矼icrosiga           � Data �  09/27/06   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     �                                                            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function Ct211Seek(aDocsLP,cMoeda,cTpSald,cDebito,cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,cEnt05DB,cEnt05CR)

Local nRecFound := 0
Local _nD		:= 1
Local cFilCT2	:= ""

DEFAULT aDocsLP := {}
DEFAULT cEnt05DB:= ""
DEFAULT cEnt05CR:= ""

If Len(aDocsLP) == 0 .or. ValType(aDocsLP) <> "A"
	Return(nRecFound)
EndIf

For _nD := 1 to Len(aDocsLP)			/// RODA TODOS OS DOCUMENTOS GERADOS PELA APURACAO
	dbSelectArea("CT2")
	dbSetOrder(1)
	cFilCT2 := xFilial("CT2")
	If MsSeek(cFilCT2+DTOS(aDocsLP[_nD][2])+aDocsLP[_nD][3]+aDocsLP[_nD][4]+aDocsLP[_nD][5],.F.)
		While CT2->(!Eof()) .and. CT2->CT2_FILIAL == cFilCT2 .and. CT2->CT2_DATA == aDocsLP[_nD][2] .and.;
			CT2->CT2_LOTE == aDocsLP[_nD][3] .and. CT2->CT2_SBLOTE == aDocsLP[_nD][4] .and.;
			CT2->CT2_DOC == aDocsLP[_nD][5]
			// LE ENQUANTO FOR O DOCUMENTO DE APURACAO
			If CT2->CT2_MOEDLC == cMoeda .and. CT2->CT2_TPSALD == cTpSald
				// SE FOR A MESMA MOEDA E TIPO DE SALDO A SER GERADO
				If lEntidad05
					If CT2->CT2_DEBITO == cDebito .and. CT2->CT2_CREDIT == cCredito .and.;
						CT2->CT2_CCD == cCustoDeb .and. CT2->CT2_CCC == cCustoCrd .and.;
						CT2->CT2_ITEMD == cItemDeb .and. CT2->CT2_ITEMC == cItemCrd .and.;
						CT2->CT2_CLVLDB == cClVlDeb .and. CT2->CT2_CLVLCR == cClVlCrd .And. ;
						CT2->CT2_EC05DB == cEnt05DB .And. CT2->CT2_EC05CR == cEnt05CR
						/// E POSSUIR A MESMA COMBINA敲O DE ENTIDADES PARA O LANCAMENTO (DEB E CRED).
						nRecFound := CT2->(Recno())	 /// RETORNA O RECNO PARA SOMAR NO MESMO.
					EndIf
				ElseIf CT2->CT2_DEBITO == cDebito .and. CT2->CT2_CREDIT == cCredito .and.;
				   CT2->CT2_CCD == cCustoDeb .and. CT2->CT2_CCC == cCustoCrd .and.;
				   CT2->CT2_ITEMD == cItemDeb .and. CT2->CT2_ITEMC == cItemCrd .and.;
				   CT2->CT2_CLVLDB == cClVlDeb .and. CT2->CT2_CLVLCR == cClVlCrd
				   /// E POSSUIR A MESMA COMBINA敲O DE ENTIDADES PARA O LANCAMENTO (DEB E CRED).
				   nRecFound := CT2->(Recno())	 /// RETORNA O RECNO PARA SOMAR NO MESMO.
				EndIf
			EndIf

			dbSkip()
		EndDo
	EndIf
Next

Return(nRecFound)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � A211Ordem篈utor  � Gustavo Henrique   � Data �  14/12/07   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋escricao � Funcao customizada para apresentar consulta de apuracoes   罕�
北�          � jah realizadas no objeto tNewProcess                       罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � Contabilidade Gerencial                                    罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function A211Ordem(oCenterPanel)

MsAguarde( { || MostraSX5LP() },,STR0005)	//Selecionando Registros...

Return Nil

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � GtDescHelp篈utor  � Daniel Mendes   � Data �  13/07/2016   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋escricao � Retorna o help informado removendo a quebra de linha       罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � CTBA211                                                    罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function GtDescHelp( cHelp )
Local cDescHelp := ""

cDescHelp := Ap5GetHelp( cHelp )
cDescHelp := StrTran( cDescHelp , CRLF , Space( 1 ) )

Return cDescHelp


/*/{Protheus.doc} CTB211Metrics

	CTB211Metrics - Funcao utilizada para metricas no CTBA211

	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function CTB211Metrics(cEvent, nStart, cSubEvent, cSubRoutine, nQtdReg)

Local cFunBkp	:= ""
Local cFunMet	:= ""

Local nFim := 0

Local cIdMetric  := ""
Local dDateSend := CtoD("")
Local nLapTime := 0
Local cTotal := ""

Default cEvent := ""
Default nStart := Seconds()
Default cSubEvent := ""
Default cSubRoutine := Alltrim(ProcName(1))
Default nQtdReg := 0

//S� capturar metricas se a vers?o da lib for superior a 20210517
If __lMetric .And. !Empty(cEvent)

	//grava funname atual na variavel cFunBkp
	cFunBkp := FunName()

	If cEvent == "01" //Evento 01 - Metrica de tempo m閐io


		If cSubEvent == '001'

			cFunMet := cFunBkp
			SetFunName(cFunMet)

			nFim := Seconds() - nStart // Capturar tempo final | Diferen鏰 com o tempo inicial

			//atribuicao das variaveis que serao utilizadas pelo FwCustomMetrics

			cSubRoutine := Alltrim(cSubRoutine)
			cIdMetric  := "contabilidade-gerencial-protheus_apuracao-de-resultados-tempo-total_seconds"
			dDateSend := LastDay( Date() )
			nLapTime := nFim
			cTotal	:= "1"
			// Metrica
			FWCustomMetrics():SetMetric(cSubRoutine, cIdMetric, cTotal, dDateSend, nLapTime)

		EndIf

	Endif
	//Restaura setfunname a partir da variavel salva cFunBkp
	SetFunName(cFunBkp)
EndIf

Return

/*/{Protheus.doc} VlConcil
Verifica se foi executado o Conciliador
@type  Function
@author Totvs
@since 03/02/2023
@version 12.1.2210
@return
/*/
Static Function	VlConcil(dDatApIni, dDatApFim, lForce)
Local lRet          := .T.
Local cMsg          := ""
Local lTabConc      := .F.
Local lSeekFil      := .F.
Local aArea         
Local oBtnLink     
Local oBtnCancel
Local oBtnOK

Default lForce := .F.

If ! IsBlind() .Or. lForce   // lForce para automacao passar .T.
	aArea := GetArea()

	lTabConc := AliasIndic("QLC")

	If ! lTabConc
		cMsg += "<b> </b><br>"	    //
		cMsg += "<b> " + STR0128 + " </b><br>"	    //"N鉶 identificamos o uso do Conciliador Cont醔il."
		cMsg += "<b> </b><br>"
		cMsg += "<b> " + STR0129 + " </b><br>"		//"Ferramenta importante para Concilia玢o dos lan鏰mentos."
		cMsg += "<b> " + STR0130 + " </b><br>"		//"Continua Apura玢o ?"

	Else
		dbSelectArea("QLC")
		QLC->(dbSetOrder(1))
		lSeekFil := QLC->( dbSeek( xFilial("QLC") ) )
		If ! lSeekFil 
			cMsg += "<b> </b><br>"	    //
			cMsg += "<b> " + STR0131 + " </b><br>"	    //"N鉶 identificamos o uso do Conciliador Cont醔il nesta filial."
			cMsg += "<b> </b><br>"
			cMsg += "<b> " + STR0129 + " </b><br>"		//"Ferramenta importante para Concilia玢o dos lan鏰mentos."
			cMsg += "<b> " + STR0130 + " </b><br>"		//"Continua Apura玢o ?"
		Else
			If ! QLCFound(dDatApIni, dDatApFim)
				cMsg += "<b> </b><br>"	    //
				cMsg += "<b> " + STR0131 + " </b><br>"	    //"N鉶 identificamos o uso do Conciliador Cont醔il nesta filial."
				cMsg += "<b> " + STR0132+DtoC(dDatApIni)+STR0133+DtoC(dDatApFim)+ " </b><br>"		//"No per韔do de "##" a "
				cMsg += "<b>  </b><br>"			
				cMsg += "<b> " + STR0129 + " </b><br>"		//"Ferramenta importante para Concilia玢o dos lan鏰mentos."
				cMsg += "<b> " + STR0130 + " </b><br>"	    //"Continua Apura玢o ?"
			EndIf
		EndIf
	EndIf

	If !Empty(cMsg) .And. ! IsBlind()
		DEFINE DIALOG oDlg TITLE STR0134 FROM 080,080 TO 450,640 PIXEL //"Aten玢o"
	
		// Cria fonte para ser usada no TSay
		oFont := TFont():New('Courier new',,-15,.T.)
	
		lHtml := .T.
		oSay := TSay():New(01,01,{||cMsg},oDlg,,oFont,,,,.T.,,,400,300,,,,,,lHtml)

		oBtnLink := TButton():New( 120, 5, STR0135 , oDlg,, 120 ,12,,,.F.,.T.,.F.,,.F.,,,.F. )   //'Doc.TDN-Conciliador'
		oBtnLink:SetCSS("QPushButton {text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 0px;Text-align:left;font-size:16px}")
		oBtnLink:bLClicked := {|| ShellExecute("open", "https://tdn.totvs.com/x/9xKsJg","","",3) }

		oBtnCancel := TButton():New( 160, 5, STR0136          , oDlg,, 120 ,15,,,.F.,.T.,.F.,,.F.,,,.F. )  //'Cancelar'
		oBtnCancel:bLClicked := {|| lRet := .F., oDlg:End()}

		oBtnOk := TButton():New( 160, 150, STR0137            , oDlg,, 120 ,15,,,.F.,.T.,.F.,,.F.,,,.F. )  //'Continuar'  
		oBtnOk:bLClicked := {|| lRet := .T., oDlg:End() }
		oBtnOk:SetFocus()

		ACTIVATE DIALOG oDlg CENTERED

	EndIf

	RestArea(aArea)
EndIf

Return lRet	

/*/{Protheus.doc} QLCFound
Verifica se foi executado o Conciliador no periodo informado
@type  Function
@author Totvs
@since 03/02/2023
@version 12.1.2210
@return
/*/
Static Function QLCFound(dDatApIni, dDatApFim)
Local lRet := .F.
Local cQryQLC := ""
Local aArea := GetArea()
Local cAliasQLC     := GetNextAlias()
Local lCloseAlia    := .T.

cQryQLC += " SELECT COUNT(QLC_FILIAL) QLCNREGS FROM "+RetSqlName("QLC")
cQryQLC += " WHERE "
cQryQLC += "     QLC_FILIAL = '"+xFilial("QLC")+"' "
cQryQLC += " AND QLC_DATCON BETWEEN '"+DTOS(dDatApIni)+"' AND '"+DTOS(dDatApFim)+"' "
cQryQLC += " AND D_E_L_E_T_ = ' ' "

lCloseAlia := If( Select(cAliasQLC) > 0, ((cAliasQLC)->(dbCloseArea()),.T.), .T.)

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryQLC), cAliasQLC, .T., .T.)

lRet := (cAliasQLC)->(!EOF() .And. QLCNREGS > 0 )
(cAliasQLC)->(dbCloseArea())

RestArea(aArea)

Return(lRet)
