#Include "CTBA215.CH"
#Include "PROTHEUS.CH"

STATIC __aJaClean := {}
Static lAtSldBase := Nil
Static lEntidad05 := (cPaisLoc $ "COL|PER" .And. CtbMovSaldo("CT0",,"05"))

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯TBA215   � Autor � Simone Mie Sato       � Data � 06.12.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Estorno de Apuracao de Resultados -Lucros/Perdas	          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � Ctba215()                                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Ctba215                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
FUNCTION CTBA215()

Local aSays 		:= {}
Local aButtons		:= {}
LOCAL nOpca    		:= 0
Local oProcess
Local lExclusivo := IIF(FindFunction("ADMTabExc"), ADMTabExc("CT2") , !Empty(xFilial("CT2") ) )

Private cCadastro 	:= OemToAnsi(STR0001)  //"Estorno de Apuracao Lucros/Perdas"
PRIVATE cString   	:= "CT2"
PRIVATE cDesc1    	:= OemToAnsi(STR0002)  //"Esta rotina ir� excluir os lancamentos contabeis de lucros e perdas."
PRIVATE cDesc2    	:= ""
PRIVATE cDesc3    	:= ""
PRIVATE nomeprog  	:= "CTBA215"
PRIVATE aLinha    	:= { },nLastKey := 0

If lAtSldBase	:= Nil
	lAtSldBase	:= Iif(GetMV("MV_ATUSAL")== "S",.T.,.F.)
Endif

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Variaveis utilizadas para parametros                         �
//� mv_par01 // Data de Apuracao                                 �
//� mv_par02 // Moedas(Todas/Especifica)		                 �
//� mv_par03 // Qual Moeda?                                      �
//� mv_par04 // Tipo de Saldo 				                     �
//� mv_par05 // Atualiza Saldos ? (Sim/N鉶)	                     �
//� mv_par06 // Seleciona FIlial                     		 �
//� mv_par07 // Filial De                     		 �
//� mv_par08 // Filial At�                     		 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Pergunte("CTB215",.f.)
AADD(aSays,OemToAnsi( STR0002 ) )	//"Esta rotina ir� excluir os lancamentos contabeis de lucros e perdas."

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Inicializa o log de processamento                            �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
ProcLogIni( aButtons )

AADD(aButtons, { 9,.T.,{|| MostraSX5LP() } } )		/// MOSTRA APURACOES JA EFETUADAS.
AADD(aButtons, { 5,.T.,{|| Pergunte("CTB215",.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( CtbOk(), FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Atualiza o log de processamento   �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	ProcLogAtu("INICIO")
	If !CTBSerialI("CTBPROC","OFF")
		Return
	EndIf

	If MV_PAR06 == 1 .And. lExclusivo // Seleciona filiais
		oProcess := MsNewProcess():New({|lEnd| Ctb215Fil(oProcess,MV_PAR07,MV_PAR08)},"","",.F.)
	Else
		oProcess := MsNewProcess():New({|lEnd| Ctb215Proc(oProcess)},"","",.F.)
	EndIf

	oProcess:Activate()

	CTBSerialF("CTBPROC","OFF")

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Atualiza o log de processamento   �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	ProcLogAtu("FIM")

Endif

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矯tb215Fil 篈utor  矨lvaro Camillo Neto � Data �  21/09/09   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矱xecuta o processamento para cada filial                    罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � CTBA215                                                   罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function Ctb215Fil(oProcess,cFilDe,cFilAte)
Local cFilIni 	:= cFIlAnt
Local aArea		:= GetArea()
Local aSM0 		:= Iif( FindFunction( "AdmAbreSM0" ) , AdmAbreSM0() , {} )
Local nContFil := 0
Local cFilProc := ""
Local lFirst		:= .T.

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

		ProcLogAtu("MENSAGEM",STR0021 + cFilAnt) // "EXECUTANDO A APURACAO DA FILIAL "

		Ctb215Proc(oProcess,@lFirst)
	Next nContFil

	cFIlAnt := cFilIni
Else
	ProcLogAtu("ERRO","Aten玢o!","Nenhuma empresa/filial encontrada. Verique se est� utilizando a ultima vers鉶 do ADMXFUN (MAR/2010)" )
Endif

RestArea(aArea)
Return


/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯tb215Proc� Autor � Simone Mie Sato       � Data � 06.12.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 矱storno da rotina de Apuracao de Lucros Perdas              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � CTB215Proc()                                               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Ctba215                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
FUNCTION Ctb215Proc(oObj,lFirst)

Local dDataLP		:= mv_par01						//Data de Apuracao
Local lMoedaEsp		:= Iif(mv_par02==2,.T.,.F.)		//Moedas
Local cMoeda		:= StrZero(Val(mv_par03),2)		//Define qual a moeda especifica
Local cTpSald		:= mv_par04						//Tipo de Saldo.
Local aCtbMoeda 	:= {}
Local nInicio		:= 0
Local nFinal		:= 0
Local dDataFim
Local dDataIni
Local cFilDe		:= 	""
Local cFilAte		:=	""
Local lAtuSaldos	:= .F.
Local lReproc		:= If(mv_par05==1,.T.,.F.)
Local dDTIFlg		:= CTOD("  /  /  ")				//DATA PARA INICIO DA REMARCA茿O DE FLAGS (APURACAO ANTERIOR +1)
Local lApLanctos	:= .F.							//.T. INDICA QUE APAGOU LANCAMENTOS
Local lPergOk		:= .F.
Local lExclusivo := IIF(FindFunction("ADMTabExc"), ADMTabExc("CT2") , !Empty(xFilial("CT2") ))
Local lEApCtPon	:=.F.
Local cQryZerAnt  := ""
lOCAL cAliasQry   := GetNextAlias()  // Data de Zeramento anteriror
Local dDataZerAnt := Ctod(" /  /  ")  // ultimadata de Zera/to no CW0
Local lResultado	:= .T.	// .T. = Revertir C醠culo de Resultado (proceso est醤dar) / .F. = Cierre Cuentas de Balance terceros (Solo si lEntidad05 == .T.)
Local cLote			:= ""
Local cSublote		:= ""
Local cDoc			:= ""
Local cDocFin		:= ""

Default lFirst	:= .T.

If MV_PAR06 == 1 .And. !lExclusivo
	ProcLogAtu("MENSAGEM","TRATAMENTO MULTI FILIAL DESABILITADO: CT2 COMPARTILHADO")
EndIf

If lMoedaEsp					// Moeda especifica
	cMoeda	:= mv_par03
	aCtbMoeda := CtbMoeda(cMoeda)
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Atualiza o log de processamento com o erro  �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		ProcLogAtu("ERRO","NOMOEDA",Ap5GetHelp("NOMOEDA"))


		Return
	EndIf
	nInicio := val(cMoeda)
	nFinal	:= val(cMoeda)
Else
	nInicio	:= 1
	nFinal	:= __nQuantas
EndIf

// Trecho localizado COL|PER vari醰el static.
If lEntidad05 .And. cPaisLoc == "COL" .And. FindFunction("Ct215Resul")
	// Determina si es reversi髇 de c醠culo de resultado o cierre de cuentas de balance
	cLote := mv_par09
	cSublote := mv_par10
	cDoc := mv_par11
	cDocFin := mv_par12
	If !Ct215Resul(@lResultado, dDataLP, cLote, cSublote, cDoc, cDocFin)
		Return(.F.)
	EndIf
EndIf

If lResultado .And. CtLPCW0Tab() // lResultado no padr鉶 deve ser sempre .T.
	If !CtLPCW0Vdt(dDataLP,,@lPergOk,,cTpSald,,.F.)
		Return(.F.)
	EndIf
Else

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� ANTES DE INICIAR O PROCESSAMENTO, VERIFICO OS PARAMETROS.	 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	//Data de Apuracao nao preenchida.
	If Empty(dDataLP)
		Help(" ",1,"NOCTBDTLP")

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Atualiza o log de processamento com o erro  �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		ProcLogAtu("ERRO","NOCTBDTLP",Ap5GetHelp("NOCTBDTLP"))

		Return(.F.)
	Else //Se a data estiver preenchida, verifica se ja foi rodado nessa data.
		//Verificar se o calendario da data solicitada esta encerrado
		lPergOk	:= CtbValiDt(1,dDataLP,,cTpSald)
	Endif
EndIf

//Se for moeda especifica, verificar se a moeda esta preenchida
If lMoedaEsp
	If Empty(cMoeda)
		Help(" ",1,"NOCTMOEDA")

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Atualiza o log de processamento com o erro  �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		ProcLogAtu("ERRO","NOCTMOEDA",Ap5GetHelp("NOCTMOEDA"))

		lPergOk := .F.
	Endif
EndIf

//Tipo de saldo nao preenchido
If Empty(cTpSald)
	Help(" ",1,"NO210TPSLD")

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Atualiza o log de processamento com o erro  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	ProcLogAtu("ERRO","NO210TPSLD",Ap5GetHelp("NO210TPSLD"))

	lPergOk := .F.
Endif

If lResultado // lResultado no padr鉶 deve ser sempre .T.
	If lPergOk
		//Verificar se a data solicitada eh o ultimo zeramento.
		lPergOk	:= Ct215VldDt(dDataLp,cTpSald,lMoedaEsp,cMoeda)
	EndIf

	dDTIFlg := Ct215LPAnt(dDataLp,cTpSald,lMoedaEsp,cMoeda)
EndIf

If !lPergOk
	Return
EndIf

If !lReproc .And. lFirst
	//"Ao final dos Estornos, antes de executar nova apura玢o, processos ou consultas,"
	//"executar reprocessamento de saldos !"
	//"Continuar mesmo assim ?"
	//"ATEN敲O ! Estorno configurado para n鉶 atualizar saldos."
	If !MsgYesNo(STR0014+CRLF+STR0015+CRLF+STR0016,STR0017)
		Return
	EndIf
EndIf

//Verifica se tem algum saldo basico desatualizado. Definido que essa verificacao so sera
//feita em top connect, pois se fosse fazer em codebase iria degradar muito a performance
//do sistema.
If !lAtSldBase .OR. !lReproc //So ira fazer a verificacao, caso o parametro MV_ATUSAL esteja com "N"
	dLastProc := GetCv7Date(cTpSald,cMoeda)

	If dDataLP > dLastProc .And. !lReproc
		MsgAlert(STR0022 + cTpSald + STR0019 + cMoeda )
		Return
	EndIf
EndIf

//Zerar os valores dos lancamentos de apuracao de lucros/perdas que deverao ser estornados.
If Ct215Atual(dDataLP,lMoedaEsp,cMoeda,cTpSald,nInicio,nFinal,oObj,dDTIFlg,lReproc,@lEApCtPon,lResultado,cLote,cSublote,cDoc,cDocFin)
	lAtuSaldos := .T.
	If !lReproc
		lAtuSaldos := .F.
	EndIf
	lApLanctos := .T.
Else
	If !lReproc
		lAtuSaldos := .F.
	Else
		If !IsBlind()
			If MsgNoYes(STR0005+CRLF+"Filial "+cFilAnt)//"N鉶 foram localizados lan鏰mentos de apura玢o no per韔do, for鏰r reprocessamento de saldos ?"
				lAtuSaldos := .T.
			Else
				lAtuSaldos := .F.
			EndIf
		Else
			lAtuSaldos := .T.
		EndIf
	EndIf
EndIf

If lAtuSaldos

 	//Voltar o indice 1 do CT2
	dbSelectArea("CT2")
	dbSetOrder(1)

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� ATUALIZACAO DOS SALDOS							 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	//Verifico qual a data inicial a ser passada para o Reprocessamento.
	//Ct215MinDt(dDataLp,@dDataIni,lMoedaEsp,cMoeda,cTpSald)

	//Verifico qual a data final a ser passada para o Reprocessamento.
	Ct215MaxDt(dDataLP,@dDataFim)
	If lApLanctos					/// SE APAGOU LANCAMENTOS
		dDataIni := CTOD("01/01/"+ALLTRIM(STR(YEAR(dDataLP))))	/// REPROCESSA DESDE O 1� DIA DO ANO (AVALIAR 1� DATA DO CALENDARIO CORRENTE)
	Else							/// SE NAO APAGOU LANCAMENTOS
		If Empty(dDTIFlg)			/// SE N肙 HOUVER APURACAO ANTERIOR
			dbSelectArea("CT2")
			dbSetOrder(1)
			dbSeek(xFilial("CT2"),.T.)
			dDataIni := CTOD("01/01/"+ALLTRIM(STR(YEAR(dDataLP))))	/// REPROCESSA DESDE O 1� DIA DO ANO (AVALIAR 1� DATA DO CALENDARIO CORRENTE)
		Else
			dDataIni := dDTIFlg			/// REPROCESSA DESDE A APURACAO ANTERIOR P/ REM. TAMBEM OS FLAGS DE SALDO
		EndIf
	Endif

	If !Empty(dDataFim) .And. ( dDataLP > dDataFim .Or. dDataFim > dDataLP )
		dDataFim	:= dDataLP
	EndIf
	/*  Data de zeramento anteriror */
	cQryZerAnt := "Select IsNull(MAX(CW0_DESC01), ' ') ULTAP "
	cQryZerAnt += "  From "+RetSqlName("CW0")
 	cQryZerAnt += " WHERE CW0_FILIAL  = '"+ xFilial("CW0")+"' "
 	cQryZerAnt += "  and CW0_TABELA  = 'LP'"
	cQryZerAnt += "  and CW0_DESC01  < '"+DTOS(dDataLP)+cMoeda+cTpSald+"Z'"
	cQryZerAnt += "  and CW0_CHAVE   = '"+cEmpAnt+cFilAnt+"'"
	cQryZerAnt += "  and SUBSTRING (CW0_DESC01, 9, 04) = '"+cMoeda+cTpSald+"Z'"
	cQryZerAnt += "  and D_E_L_E_T_ = ' '"+CRLF

	cQryZerAnt := ChangeQuery(cQryZerAnt)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryZerAnt),cAliasQry,.T.,.F.)

	dDataZerAnt := Stod(Substring((cAliasQry)->(ULTAP),1,8))
	(cAliasQry)->(DbCloseArea())

	If !Empty(dDataIni) .And. dDataIni > dDataFim
		dDataIni := CTOD("01/01/"+ALLTRIM(STR(YEAR(dDataLP))))	/// REPROCESSA DESDE O 1� DIA DO ANO (AVALIAR 1� DATA DO CALENDARIO CORRENTE)
	ElseIf !Empty(dDataZerAnt)
		dDataIni := DaySum(dDataZerAnt,1)
	EndIf

	If !lExclusivo
		cFilDe	:= "  "
		cFilAte	:= "  "
	Else
		cFilDe	:= xFilial("CT2")
		cFilAte	:= xFilial("CT2")
	EndIf

	If !Empty(dDataIni) .And. !Empty(dDataFim)
		// Chamada do CTBA190 para reprocessar os saldos do per韔do (dt.apuracao ou periodo)
		CTBA190(.T.,dDataIni,dDataFim,cFilDe,cFilAnt,cTpSald,lMoedaEsp,cMoeda)
	EndIf
Else
	// For鏾 a atualiza玢o do flag de reprocessamento de saldo.
	PutCv7Date(cTpSald,cMoeda,cTod(""))
EndIf

If lResultado // lResultado no padr鉶 deve ser sempre .T.
	//Atualizar a tabela SX5
	Ct215AtSX5(dDataLP,lMoedaEsp,cMoeda,nInicio,nFinal,cTpSald,lEApCtPon)
EndIf

lFirst := .F.

Return

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯t215Atual� Autor � Simone Mie Sato       � Data � 06.12.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 砕era/Exclui os lancamentos contabeis de apuracao LP.        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矯t215Atual()                                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      矯t215Atual())                                               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function Ct215Atual(dDataLP,lMoedaEsp,cMoeda,cTpSald,nInicio,nFinal,oObj,dDTIFlg,lReproc,lEApCtPon,lResultado,cLote,cSublote,cDoc,cDocFin)

Local aSaveArea	:= GetArea()
Local aRecTmp   := {}
Local nMoeda	:= 0
Local nTotRegua	:= (CQ7->(Reccount())+CQ5->(Reccount())+CQ3->(Reccount())+CQ1->(RecCount()))
Local cTamMoed	:= ""
Local cFilCT2	:= ""
Local lTemLcto	:= .F.
Local lCont		:= .F.
Local lSair		:= .F.
Local lAprZ		:= .T.
Local lJaPerg	:= .f.

local cChaveCT2	:= ""

Local lCntrlQry := .F.
Local bCondWhile := {||.T.}
Local bCondInter := {||.T.}
Local cQryCT2 := ""
Local cEC05DB := ""
Local cEC05CR := ""

DEFAULT lEApCtPon	:= .F.
DEFAULT dDTIFlg := dDataLP
DEFAULT lReproc	:= .T.
DEFAULT lResultado	:= .T.

If lResultado	// Proceso est醤dar de Reversi髇 de C醠culo de Resultado
	BeginSQL Alias "CTZXCT2"
		SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_EMPORI, CT2_FILORI, CT2_MOEDLC
		FROM %Table:CT2% CT2
			INNER JOIN %Table:CTZ% CTZ ON
				CT2.CT2_FILIAL=CTZ.CTZ_FILIAL AND
				CT2.CT2_DATA= %Exp:DtoS(dDataLP)% AND
				CT2.CT2_LOTE=CTZ.CTZ_LOTE AND
				CT2.CT2_SBLOTE=CTZ.CTZ_SBLOTE AND
				CT2.CT2_DOC=CTZ.CTZ_DOC AND
				CT2.CT2_LINHA=CTZ.CTZ_LINHA AND
				CT2.CT2_EMPORI=CTZ.CTZ_EMPORI AND
				CT2.CT2_FILORI=CTZ.CTZ_FILORI AND
				CT2.CT2_MOEDLC=CTZ.CTZ_MOEDLC
		WHERE CT2.CT2_FILIAL=%xFilial:CT2% AND
		CT2.%NotDel%
	EndSQL

	IF CTZXCT2->(! Eof()) // EXISTEM REGISTROS PARA SE TRABALHAR NO WHILE
		lCont := .T.
	EndIf

	///////////////////////////////////
	//// APAGA REGISTROS DE CONTA PONTE
	///////////////////////////////////
	dbSelectArea("CTZ")

	If CtbRegCTZ(,dDataLP)	//1� VERIFICA SE EXISTEM LANCAMENTO DO CTZ NO DIA

		For nMoeda	:= nInicio to nFinal

			If CtbRegCTZ(StrZero(nMoeda,2),dDataLP,cTpSald)	/// SE HOUVER LANCAMENTO COM CONTA PONTE

				If CtDtExcLPCW0(dDataLp,cTpSald,lMoedaEsp,cMoeda,.T.) // verifica se existe Zeramento na data

					If ( !lJaPerg )
						lEApCtPon := MsgNoYes(STR0002+CRLF+"Deseja excluir inclusive apura玢o em Conta Ponte?")	  // .t. PERMITE EXCLUIR AMBAS APURA钦ES DE MESMA DATA P OU Z
						lJaPerg := .T.
					EndIf

					If lEApCtPon	//"Esta rotina ir� excluir os lancamentos contabeis de lucros e perdas."
						lAprZ := .T.
						CtbDelCTZ(dDataLP,StrZero(nMoeda,2),cTpSald,dDTIFlg)	/// APAGA LANCAMENTOS CTZ DA MOEDA
					EndIf
				Else
					lEApCtPon := .T. ///?
					lAprZ := .F.
					CtbDelCTZ(dDataLP,StrZero(nMoeda,2),cTpSald,dDTIFlg)	/// APAGA LANCAMENTOS CTZ DA MOEDA
				EndIf

				lTemLcto	:= .T.

			EndIf
		Next

	Else
		lEApCtPon := .T.
	EndIf
EndIf

///////////////////////////////////
//// APAGA REGISTROS DE LAN茿MENTO NO CT2
///////////////////////////////////
dbSelectArea("CT2")
cTamMoed := CriaVar("CT2_MOEDAS")
dbSetOrder(1)
cFilCT2	:= xFilial("CT2")
If MsSeek(cFilCT2+DTOS(dDataLP),.F.)
	oObj:SetRegua1(nTotRegua)
	//criar query da CT2 para pegar somente que tem data LP preenchido quando
	//variavel lEApCtPon for .T. elCont for .F.
	lCntrlQry := ( (lEApCtPon.And. !lCont) .Or. !lResultado )
	If lCntrlQry
		//faz query que vai somente filtrar CT2 na data LP com CT2_DTLP preenchido e tipo de saldo igual informado
		cQryCT2 := ""
		cQryCT2 += " SELECT R_E_C_N_O_ RECCT2 FROM "
		cQryCT2 += RetSqlName("CT2")
		cQryCT2 += " WHERE "
		cQryCT2 += "     CT2_FILIAL = '"+cFilCT2+"'"
		cQryCT2 += " AND CT2_DATA = '"+DTOS(dDataLP)+"'"
		cQryCT2 += " AND CT2_TPSALD = '"+cTpSald+"' "
		cQryCT2 += " AND CT2_DTLP = '"+DTOS(dDataLP)+"'"
		cQryCT2 += " AND D_E_L_E_T_ = ' ' "

		If lEntidad05 .And. cPaisLoc == "COL"	// Filtrar solo el proceso espec韋ico; resultados / cierre de terceros
			cQryCT2 += " AND CT2_LOTE = '"+cLote+"'"
			cQryCT2 += " AND CT2_SBLOTE = '"+cSublote+"'"
			cQryCT2 += " AND CT2_DOC BETWEEN '"+cDoc+"' AND '"+cDocFin+"'"
		EndIf

		cQryCT2 := ChangeQuery(cQryCT2)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCT2),"QRYCT2",.T.,.F.)

		dbSelectArea("QRYCT2")

		bCondWhile := {|| QRYCT2->( !Eof() ) }

		dbSelectArea("CT2")  //VOLTA PARA CT2

	Else
		bCondWhile := {||.T.}
	EndIf

	If Eval(bCondWhile)

		If lCntrlQry
			CT2->(dbGoto( QRYCT2->RECCT2 ))
		EndIf

		cLoteAtu := CT2->CT2_LOTE
		While Eval(bCondWhile) .And. CT2->(!Eof()) .And. CT2->CT2_FILIAL == cFilCT2 .And. CT2->CT2_DATA == dDataLP

			lSair:=.F.

			IF !lEApCtPon .And. lCont .And. lAprZ
				CTZXCT2->(dbGoTop())
				cChaveCT2:= CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC)
				While CTZXCT2->(! Eof()) // N鉶 permitir excluir a Apura玢o de conta ponte!
					If CTZXCT2->(CT2_FILIAL+CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC) == cChaveCT2
						lSair := .T.
						Exit
					EndIf
					CTZXCT2->(dbskip())
				Enddo

				If 	lSair
					CT2->( dbskip() )
					If lCntrlQry                //se laco esta baseado na query pula tambem
						QRYCT2->( dbSkip() )
					EndIf
					Loop
				EndIf
			EndIf

			If ! lCntrlQry  //quando controla pela query esta condicao ja esta no Where
				If Empty(CT2->CT2_DTLP) .Or. CT2->CT2_TPSALD <> cTpSald
					dbskip()
					Loop
				EndIf
			EndIf

			If CT2->CT2_DTLP == dDataLP
				If lCntrlQry  //quando controla pela query esta condicao ja esta no Where
					bCondInter := {|| QRYCT2->( !Eof() ) }
				Else
					bCondInter := {|| CT2->(!Eof()) .And. CT2->CT2_FILIAL == cFilCT2 .And. CT2->CT2_DTLP == dDataLP .And. CT2->CT2_TPSALD == cTpSald }
				EndIf

				While Eval(bCondInter)

					If lCntrlQry
						CT2->(dbGoto( QRYCT2->RECCT2 ))
					EndIf

					lTemLcto := .T.
					oObj:IncRegua1(OemToAnsi(STR0003))//Selecionando Registros...

					aAdd(aRecTmp, aClone({}))

					If lMoedaEsp 					/// SE FOR MOEDA ESPECIFICA

						If CT2->CT2_MOEDLC <> cMoeda	/// SE N肙 FOR A MOEDA SOLICITADA
							CT2->(dbSkip())				/// MANTEM O REGISTRO NO CT2
							If lCntrlQry                //se laco esta baseado na query pula tambem
								QRYCT2->( dbSkip() )
							EndIf
							Loop
						EndIf

						dbSelectArea("CT2")
						nRecCT2 := (CT2->(Recno()))
						dbSetOrder(1)

						If lEntidad05
							// D閎ito y cr閐ito de entidad 05
							cEC05DB := CT2->CT2_EC05DB
							cEC05CR := CT2->CT2_EC05CR
						EndIf

						If cMoeda == '01'
							cCt2Atual := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD)
							dbSeek(cCt2Atual+CT2->(CT2_EMPORI+CT2_FILORI)+"02",.T.)
							If cCt2Atual == CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD) .and. CT2->CT2_MOEDLC <> "01"

								/// LIMPA OS FLAGS DE APURACAO NAS TABELAS DE SALDO
								//CT215FlgLp(CT2->CT2_DEBITO,CT2->CT2_CCD,CT2->CT2_ITEMD,CT2->CT2_CLVLDB, CT2->CT2_MOEDLC, CT2->CT2_TPSALD, dDTIFlg, CT2->CT2_DATA, lReproc)
								//CT215FlgLp(CT2->CT2_CREDIT,CT2->CT2_CCC,CT2->CT2_ITEMC,CT2->CT2_CLVLCR, CT2->CT2_MOEDLC, CT2->CT2_TPSALD, dDTIFlg, CT2->CT2_DATA, lReproc)

								//CT215FlgLp(cConta,cCusto,cItem,cCLVL, cMoeda, cTpSald, dDataILP, dDataFLP, lReproc)

								//Se existir valor de conversao, apenas zera o registro do CT2
								CT2->(MsGoto(nRecCT2))
								Reclock("CT2",.F.,.T.)
								CT2->CT2_VALOR := 0
								CT2->CT2_CRCONV := "5"
								MsUnlock()
							Else
								// Se n鉶 existe valor de convers鉶, apaga registro no CT2.
								CT2->(MsGoto(nRecCT2))

								/// LIMPA OS FLAGS DE APURACAO NAS TABELAS DE SALDO
								//CT215FlgLp(CT2->CT2_DEBITO,CT2->CT2_CCD,CT2->CT2_ITEMD,CT2->CT2_CLVLDB, CT2->CT2_MOEDLC, CT2->CT2_TPSALD, dDTIFlg, CT2->CT2_DATA, lReproc)
								//CT215FlgLp(CT2->CT2_CREDIT,CT2->CT2_CCC,CT2->CT2_ITEMC,CT2->CT2_CLVLCR, CT2->CT2_MOEDLC, CT2->CT2_TPSALD, dDTIFlg, CT2->CT2_DATA, lReproc)

								// Exclui a CT2
								CtbExclCT2(aRecTmp)
							EndIf

						Else
							//Se for valor de convers鉶

							/// LIMPA OS FLAGS DE APURACAO NAS TABELAS DE SALDO
							//CT215FlgLp(CT2->CT2_DEBITO,CT2->CT2_CCD,CT2->CT2_ITEMD,CT2->CT2_CLVLDB, CT2->CT2_MOEDLC, CT2->CT2_TPSALD, dDTIFlg, CT2->CT2_DATA, lReproc)
							//CT215FlgLp(CT2->CT2_CREDIT,CT2->CT2_CCC,CT2->CT2_ITEMC,CT2->CT2_CLVLCR, CT2->CT2_MOEDLC, CT2->CT2_TPSALD, dDTIFlg, CT2->CT2_DATA, lReproc)

							// Exclui a CT2
							CtbExclCT2(aRecTmp)
						EndIf
					Else
						//Apaga registro de lan鏰mento (vai apagar para todas as moedas)

						/// LIMPA OS FLAGS DE APURACAO NAS TABELAS DE SALDO
						//CT215FlgLp(CT2->CT2_DEBITO,CT2->CT2_CCD,CT2->CT2_ITEMD,CT2->CT2_CLVLDB, CT2->CT2_MOEDLC, CT2->CT2_TPSALD, dDTIFlg, CT2->CT2_DATA, lReproc)
						//CT215FlgLp(CT2->CT2_CREDIT,CT2->CT2_CCC,CT2->CT2_ITEMC,CT2->CT2_CLVLCR, CT2->CT2_MOEDLC, CT2->CT2_TPSALD, dDTIFlg, CT2->CT2_DATA, lReproc)

						// Exclui a CT2
						CtbExclCT2(aRecTmp)
					EndIf

					If lCntrlQry
						QRYCT2->( dbSkip() )
					Else
						CT2->(dbSkip())
					EndIf
				EndDo
			Else
				CT2->( MsSeek(cFilCT2+DTOS(dDataLP)+Soma1(cLoteAtu),.T.) )
			EndIf
			cLoteAtu := CT2->CT2_LOTE
		EndDo

	Endif

	If lCntrlQry
		QRYCT2->(dbCloseArea())
	EndIf

EndIf

If lResultado // lResultado no padr鉶 deve ser sempre .T.
	CTZXCT2->(dbCloseArea())
EndIf

CtbPcoLanc(aRecTmp)

RestArea(aSaveArea)
Return lTemLcto

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯t215AtSX5� Autor � Simone Mie Sato       � Data � 06.12.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 矨tualizo a tabela do SX5.                                   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矯t215AtSX5(dDataLP)                                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      矯t210AtSX5()                                                潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
FUNCTION Ct215AtSX5(dDataLP,lMoedaEsp,cMoeda,nInicio,nFinal,cTpSald,lEApCtPon)

Local aSaveArea	:= GetArea()

DEFAULT lEApCtPon :=.F.

If CtLPCW0Tab()
	CtExcLPCW0(dDataLP,lMoedaEsp,cMoeda,nInicio,nFinal,cTpSald,lEApCtPon)
EndIf

RestArea(aSaveArea)
Return

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯t215CrInd� Autor � Simone Mie Sato       � Data � 06.12.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 矯ria indice temporario                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矯t215CrInd()                                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      矯t215CrInd()                                                潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function Ct215CrInd()

Local cIndex	:= ""
Local cChave	:= ""
Local nIndex	:= 0

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Crio arq. de trab. p/ gravar as inconsistencias.           �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cIndex		:= CriaTrab(nil,.f.)
cChave		:= "CT2_FILIAL+DTOS(CT2_DTLP)+CT2->CT2_TPSALD"

IndRegua("CT2",cIndex,cChave,,,STR0003) // "Selecionando Registros..."

nIndex := RetIndex("CT2")
dbSelectArea("CT2")
dbSetIndex(cIndex+OrdBagExt())
dbSetOrder(nIndex+1)
dbGoTop()

Return

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯t215MaxDt� Autor � Simone Mie Sato       � Data � 06.12.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 砎erifica a data final a ser reprocessada.                   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矯t215MaxDt()                                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      矯t215MaxDt()                                                潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
FUNCTION Ct215MaxDt(dDataLp,dDataFim)
Local aSaveArea	:= GetArea()
Local cQuery	:= ""
Local cTab		:= GetNextAlias()

If Select(cTab) > 0
	(cTab)->(dbCloseArea())
EndIf
cQuery := " SELECT MAX(CT2_DATA) CT2_DATA FROM " + RetSQLTab("CT2")+ " WHERE "
cQuery += " CT2_FILIAL = '" +xFilial("CT2")+"' AND"
cQuery += " CT2_DC IN ('1' , '2', '3' )  AND "
cQuery += " D_E_L_E_T_ = '' "
cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTab )
TCSetField(cTab, "CT2_DATA" ,"D", 8, 0 )
If (cTab)->(!EOF())
	dDataFim := (cTab)->CT2_DATA
Else
	dDataFim := dDataLp
EndIf
(cTab)->(dbCloseArea())

RestArea(aSaveArea)

Return


/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯t215MinDt� Autor � Simone Mie Sato       � Data � 09.12.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 砎erifica a data inicial a ser reprocessada.                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矯t215MinDt()                                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      矯t215MinDt()                                                潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
FUNCTION Ct215MinDt(dDataLp,dDataIni,lMoedaEsp,cMoeda,cTpSald)

Local aSaveArea	:= GetArea()
Local cIndex	:= ""
Local cChave	:= ""
Local nIndex	:= 0

If !lMoedaEsp
	cMoeda	:= '01'
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Crio arq. de trab. p/ gravar as inconsistencias.           �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cIndex		:= CriaTrab(nil,.f.)
cChave		:= "CT7_FILIAL+DTOS(CT7_DTLP)+CT7_MOEDA+CT7_TPSALD"

IndRegua("CT7",cIndex,cChave,,,STR0003) // "Selecionando Registros..."

nIndex := RetIndex("CT7")
dbSelectArea("CT7")
dbSetIndex(cIndex+OrdBagExt())
dbSetOrder(nIndex+1)
dbGoTop()
If lMoedaEsp
	MsSeek(xFilial()+dtos(dDataLP)+cMoeda+cTpSald)
	If Found() .And. !Eof()
		dDataIni	:= CT7->CT7_DATA
	EndIf
Else	//Procurar pela moeda 01
	MsSeek(xFilial()+dtos(dDataLP)+'01'+cTpSald,.T.)
	If DTOS(CT7->CT7_DTLP) == DTOS(dDataLP)
		dDataIni	:= CT7->CT7_DATA
	EndIf
EndIf
//Apagar indice temporario

RestArea(aSaveArea)

Return
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯tbDelCTZ � Autor � Simone Mie Sato       � Data � 06.12.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矰eleta os registros no CTZ                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矯tbDelCTZ()                                   		 	  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�															  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Generico                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function CtbDelCTZ(dData,cMoeda,cTpSald,dDTIFlg)

Local aSaveArea	:= GetArea()
Local cFilCTZ	:= ""

DEFAULT dDTIFlg := dData

dbSelectArea("CTZ")
dbSetOrder(1)
cFilCTZ	:= xFilial("CTZ")
If MsSeek(cFilCTZ+dtos(dData),.F.)
	While !Eof() .And. CTZ->CTZ_FILIAL == cFilCTZ .And. CTZ->CTZ_DATA == dData
		If !Empty(cMoeda)		/// SE FOR INFORMADA MOEDA VERIFICA SE LANCAMENTO � DA MOEDA INFORMADA
			If cMoeda <> CTZ->CTZ_MOEDLC 	/// SE LAN茿MENTO FOR EM OUTRA MOEDA
				CTZ->(dbSkip())
				Loop
			EndIf
		EndIf

		If !Empty(cTpSald)					/// SE FOR INFORMADO TIPO DE SALDO
			If cTpSald <> CTZ->CTZ_TPSALD	/// E  O LAN茿MENTO FOR DIFERENTE DO SALDO INFORMADO
				CTZ->(dbSkip())				/// NAO DELETA
				Loop
			EndIf
		EndIf

		///CT215FlgLp(CTZ->CTZ_CONTA,CTZ->CTZ_CUSTO,CTZ->CTZ_ITEM,CTZ->CTZ_CLVL, CTZ->CTZ_MOEDLC, CTZ->CTZ_TPSALD, dDTIFlg, CTZ->CTZ_DATA)

		Reclock("CTZ",.F.,.T.)
		dbDelete()
		CTZ->(MsUnlock())
		CTZ->(dbSkip())
	EndDo
EndIf

RestArea(aSaveArea)
Return


/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯t215VldDt� Autor � Simone Mie Sato       � Data � 09.12.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 砎erifica se a data solicitada eh ref. o ult. zeramento      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   �				                                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      �                                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
FUNCTION Ct215VldDt(dDataLp,cTpSald,lMoedaEsp,cMoeda)

Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local cDataLP	:= DTOS(dDataLp)
Local lSaiW		:= .F.
Local cEmpFil	:= cEmpAnt+cFilAnt
Local cFilSX5	:= ""

If CtLPCW0Tab()
	lRet := CtDtExcLPCW0(dDataLp,cTpSald,lMoedaEsp,cMoeda)
Else
	dbSelectArea("SX5")
	dbSetOrder(1)
	cFilSX5	:= xFilial("SX5")

	dbSeek(xFilial("SX5")+"LP"+cEmpAnt+Soma1(cFilAnt),.T.)
	SX5->(dbSkip(-1))
	While !lSaiW .AND. SX5->X5_FILIAL == cFilSX5 .and. ALLTRIM(SX5->X5_TABELA) == "LP" .and. ALLTRIM(SX5->X5_CHAVE) == cEmpFil
		If cTpSald == SubStr(SX5->X5_DESCRI,11,1)	/// TIPO DE SALDO DEVE SER VERIFICADO INDEPENDENTE DA MOEDA
			lMoedaChk := .T.
			/// SE FOR APURACAO DE MOEDA ESPECIFICA
			If lMoedaEsp .and. cMoeda <> SubStr(SX5->X5_DESCRI,9,2)
				lMoedaChk := .F.
			Endif
			If lMoedaChk	/// SE FOR A MESMA MOEDA / OU PROCESSAMENTO DE TODAS AS MOEDAS
				lSaiW := .T.
				Exit		/// FOR茿 SAIDA PRA NAO DESPOSICIONAR O X5 (VAI PEGAR A DATA)
			EndIf
		EndIf
		SX5->(dbSkip(-1))
	EndDo

	If lSaiW .AND. SX5->X5_FILIAL == cFilSX5 .and. ALLTRIM(SX5->X5_TABELA) == "LP" .and. ALLTRIM(SX5->X5_CHAVE) == cEmpFil
		If cDataLP < Substr(SX5->X5_DESCRI,1,8)
			/// SE N肙 FOR A 贚TIMA DATA DE APURA敲O NA EMPRESA E FILIAL
			lRet	:= .F.
			MsgInfo(STR0004,STR0018+DTOC(dDataLP)+STR0019+If(lMoedaEsp,cMoeda,SUBSTR(SX5->X5_DESCRI,9,2))+STR0020+cTPSald)//"Verifique se a data solicitada refere-se ao ultimo zeramento efetuado..."//"Data: "//" Moeda: "//" Tp.Saldo: "
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)/// ATEN敲O ! MANTER SX5 POSICIONADO NO RETORNO Ct215LPAnt( OBTEM DATA ANTERIOR E IRA DESPOSICIONAR )
Return(lRet)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矯TBA215   篈utor  矼icrosiga           � Data �  09/26/06   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     �                                                            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function CT215FlgLp(cConta,cCusto,cItem,cCLVL, cMoeda, cTpSald, dDataILP, dDataFLP, lReproc, cEnt05)

Local cKeyJaClean := Alltrim(cMoeda+cTpSald+cConta+cCusto+cItem+cClVL)
Local nLenKey	  := Len(alltrim(cKeyJaClean))

Default lReproc := .T.

If lAtSldBase	== Nil
	lAtSldBase	:= Iif(GetMV("MV_ATUSAL")== "S",.T.,.F.)
Endif

If AsCan(__aJaClean,{|x| Substr(x,1,nLenKey) == cKeyJaClean }) <= 0

	If lAtSldBase .And. lReproc
		If lEntidad05 .And. !Empty(cEnt05)
			Ct190FlgLP(cFilAnt, "QL6", cConta, cCusto, cItem, cCLVL, dDataILP, cTpSald, dDataFLP, cMoeda,, "N", cEnt05)
		EndIf
		If !Empty(cCLVL)
			Ct190FlgLP(cFilAnt, "CTI", cConta,cCusto,cItem,cCLVL, dDataILP, cTpSald, dDataFLP, cMoeda,,"N")
		EndIf
		If !Empty(cITEM)
			Ct190FlgLP(cFilAnt, "CT4", cConta,cCusto,cItem,"", dDataILP, cTpSald, dDataFLP, cMoeda,,"N")
		EndIf
		If !Empty(cCUSTO)
			Ct190FlgLP(cFilAnt, "CT3", cConta,cCusto,"","", dDataILP, cTpSald, dDataFLP, cMoeda,,"N")
		EndIf
		If !Empty(cConta)
			Ct190FlgLP(cFilAnt, "CT7", cConta,"","","", dDataILP, cTpSald, dDataFLP, cMoeda,,"N")
		EndIf
	EndIf

	If lReproc

		/// REMARCA FLAG NAS TABELAS DE SALDOS COMPOSTOS
		If lEntidad05 .And. !Empty(cEnt05)
			Ct190FlgLP(cFilAnt, "CTU", "", "", "", "", dDataILP, cTpSald, dDataFLP, cMoeda, "QL6", "N", cEnt05)
		EndIf
		If !Empty(cCLVL)
			Ct190FlgLP(cFilAnt, "CTU", "","","",cCLVL, dDataILP, cTpSald, dDataFLP, cMoeda,,"N")
		EndIf
		If !Empty(cITEM)
			Ct190FlgLP(cFilAnt, "CTU", "","",cITEM,"", dDataILP, cTpSald, dDataFLP, cMoeda,,"N")
		EndIf
		If !Empty(cCUSTO)
			Ct190FlgLP(cFilAnt, "CTU", "",cCUSTO,"","", dDataILP, cTpSald, dDataFLP, cMoeda,,"N")
		EndIf
	Endif

	AAdd(__aJaClean,cKeyJaClean)

EndIf

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矯TBA215   篈utor  矼icrosiga           � Data �  09/26/06   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     �                                                            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function Ct215LPAnt(dDataLp,cTpSald,lMoedaEsp,cMoeda)

Local dDTLPAnt := CTOD('  /  /  ')
Local cEmpFil	:= cEmpAnt+cFilAnt
Local cDataLP  := DTOS(dDataLp)
Local cFilSX5  := ""
Local lMoedaChk:= .T.

If CtLPCW0Tab()
	dDTLPAnt := CtLPAntCW0(dDataLp,cTpSald,lMoedaEsp,cMoeda)
Else

	dbSelectArea("SX5")
	cFilSX5 := xFilial("SX5")

	If !Eof() .AND. SX5->X5_FILIAL == cFilSX5 .and. ALLTRIM(SX5->X5_TABELA) == "LP" .and.;
		ALLTRIM(SX5->X5_CHAVE) == cEmpFil .and. cDataLP == Substr(SX5->X5_DESCRI,1,8)
		/// SE JA ESTIVER POSICIONADO NA 贚TIMA DATA NAO PRECISA PESQUISAR
	Else
		/// SE N肙 ESTIVER POSICIONADO LOCALIZA A 贚TIMA DATA PARA USAR A MESMA LOGICA
		dbSelectArea("SX5")
		dbSetOrder(1)
		dbSeek(cFilSX5+"LP"+cEmpAnt+Soma1(cFilAnt),.T.)
		dbSkip(-1)
		dDataLP := STOD(Substr(SX5->X5_DESCRI,1,8))
	EndIf

	SX5->(dbSkip(-1))
	While SX5->X5_FILIAL == cFilSX5 .and. ALLTRIM(SX5->X5_TABELA) == "LP" .and. ALLTRIM(SX5->X5_CHAVE) == cEmpFil
		If cTpSald == SubStr(SX5->X5_DESCRI,11,1)	/// TIPO DE SALDO DEVE SER VERIFICADO INDEPENDENTE DA MOEDA
			lMoedaChk := .T.
			/// SE FOR APURACAO DE MOEDA ESPECIFICA
			If lMoedaEsp .and. cMoeda <> SubStr(SX5->X5_DESCRI,9,2)
				lMoedaChk := .F.
			Endif
			If lMoedaChk	/// SE FOR A MESMA MOEDA / OU PROCESSAMENTO DE TODAS AS MOEDAS
				If Substr(SX5->X5_DESCRI,1,8) < cDataLP
					/// SE A DATA DE APURACAO FOR MENOR QUE A DATA FINAL DE APURACAO
					/// OBTEM A DATA DA APURACAO ANTERIOR
					dDTLPAnt := STOD(Substr(SX5->X5_DESCRI,1,8))
					Exit
				EndIf
			EndIf
		EndIf
		SX5->(dbSkip(-1))
	EndDo
EndIf
Return(dDTLPAnt)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矯tbExclCT2篈utor  矼icrosiga           � Data �  10/09/09   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矱xclui o lancamento na tabela CT2 e armazena no array       罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function CtbExclCT2(aRecTmp)

aAdd(aRecTmp[Len(aRecTmp)], {Nil, CT2->(RECNO()), 5, NIL})

Reclock("CT2", .F., .T. )
	CT2->( DbDelete() )
MsUnlock()

Return()
