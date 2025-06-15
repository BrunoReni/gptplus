#Include 'Protheus.ch'
#Include 'GPEM038.ch'

//Integração com o TAF
Static lIntTaf 		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 2 )
Static lMiddleware  := If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

/*/{Protheus.doc} GPEM038
Programa responsável por executar os eventos:
[x] S-2500 - Processos Trabalhistas
[-] S-2501 - Reabertura dos Eventos Periódicos
[X] S-2501- Informações de Tributos Decorrentes de Processo Trabalhista

@Return	Nil

@Author   Silvia Taguti
@Since    01/11/2022 
@Version  1.0 
@Type     Function
/*/
Function GPEM038()
Local aArea			:= GetArea()
Local cTitle  		:= OemToAnsi(STR0001) + "-" + OemToAnsi(STR0002) //"Geração dos Eventos de Processos Trabalhistas" - "eSocial"
Local cAliasTRB		:= GetNextAlias()
Local nOpcA			:= 1
Local aObjSize		:= {}
Local aArrayFil		:= {}
Local aCheck		:= {.F., .F., .F.,.F.} /*Caso seja criado novos itens, deve ser alimentado*/
Local bFilt			:= { || fSisParam() }  
Local aObjCheck		:= Array(Len(aCheck)) //Objetos dos eventos
Local aObjCoords	:= {}
Local oFont
Local aItens 		:= {}
Local bFecha		:= {||nOpcA := 2, oDlg:End()}
Local nOpcB			:= 0
Local oBtFechar
Local lInt2500 	
Local lInt2501		 	
Local lInt3500 	
Local bOK1			:= {||Iif(fGp38TdOk1(aCheck,cAliasTRB,SubStr(cCompete,3,4) + SubStr(cCompete,1,2), aArrayFil, aItens), (oDlg:End(), nOpcB := 1), Nil)}
Local lMArcar		:= .F.  
Local cExpFiltro	:= ""

Local aAdvSize		:= MsAdvSize(.F.)  
Local oBtFiltrar
Local oBtProcessar

Private cCompete	:= Space(6)
Private dDataIni    := CtoD("")
Private dDataFim    := CtoD("")
Private aSM0    	:= FWLoadSM0(.T.,,.T.)
Private nRadio		:= 1
Private oArq1Tmp
Private cRotina		:= "GPEM038"
Private lPar06		:= .F.
Private oMark
Private oDlg                              

Private aLogs		:= {}
Private cPeriodo

Private cVersEnvio	:= ""
Private cVersGPE	:= ""
Private lIntegra	:= .T.
Private oTempTable	:= Nil
Private lSX1Perg	:= SX1->( dbSeek("GPM038") )
Private aPergAux	:= {}
Private oPanel3	
Private aColumns	:= {}
Private cExp2500	:= ""
Private lExistMatriz:= .F.
Private cCPFDe		:= ""
Private cCPFAte		:= ""
Private cProcDe		:= ""
Private cProcAte	:= ""

//Verifica Versão de Layout Disponível
lInt2500 	:= fVersEsoc("S2500", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio,@cVersGPE)

//------------------------------------
//| Verifica se o MV_RHTAF esta ativo 
//------------------------------------
If !lIntTaf .And. !lMiddleware
	MsgStop(OemToAnsi(STR0003))
	Return()
EndIf

If cVersGPE < "9.1"
	MsgStop(OemToAnsi(STR0033))
	Return()
Endif	

If !ChkFile("E0B")
	//ATENCAO"###"Tabelas de eventos de processos trabalhistas não encontrada. Atualize o ambiente
	MsgStop(OemToAnsi(STR0034))
	Return
EndIf

If FindFunction("ESocMsgVer") .And. lIntTaf .And. !lMiddleware .And. cVersGPE <> cVersEnvio .And. (cVersGPE >= "9.1" .Or. cVersEnvio >= "9.1")
	//# "Atenção! # A versão do leiaute GPE é XXX e a do TAF é XXXX, sendo assim, estão divergentes. A rotina será encerrada"
	ESocMsgVer(.T., /*cEvento*/, cVersGPE, cVersEnvio)
	Return()
EndIf

Pergunte("GPEM038",.F.)
cCPFDe		:= MV_PAR01
cCPFAte		:= MV_PAR02
cProcDe		:= MV_PAR03
cProcAte	:= MV_PAR04

//------------------------------
//| Criação das medidas da tela 
//| Foi mantida a mesma proporção do prog GPEM034
//------------------------------------------------
aAdvSize			:= MsAdvSize( .F.,.F.,570)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 15 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

//----------------------------------
//| Criação da tela de apresentação 
//------------------------------------------------
Define MsDialog oDlg FROM 0, 0 To 400, 930 Title cTitle Pixel

//Cria o conteiner onde serão colocados os paineis
	oTela1	:= FWFormContainer():New( oDlg )
	cIdTel1	:= oTela1:CreateHorizontalBox( 15 )
	cIdTel2	:= oTela1:CreateHorizontalBox( 23 )
	cIdTel3	:= oTela1:CreateHorizontalBox( 57 )

oTela1:Activate( oDlg, .F. )

//Cria os paineis onde serao colocados os browses
oPanel1	:= oTela1:GeTPanel(cIdTel1)
oPanel2	:= oTela1:GeTPanel(cIdTel2)
oPanel3	:= oTela1:GeTPanel(cIdTel3)

//------------------
//| Primeiro Painel
//| Armazena a data de competência
//---------------------------------
@ aObjSize[1,1]*0.5, aObjSize[1,2]+3       SAY OemToAnsi(STR0005) SIZE 048,008 OF oPanel1 PIXEL //Data Inicial
@ (aObjSize[1,1]*0.5)+8, aObjSize[1,2]+3   MSGET dDataIni SIZE 038,008	OF oPanel1 PIXEL WHEN .T. PICTURE "@D 99/99/9999" 

@ aObjSize[1,1]*0.5, aObjSize[1,2]+70      SAY OemToAnsi(STR0006) SIZE 048,008 OF oPanel1 PIXEL //Data Final
@ (aObjSize[1,1]*0.5)+8, aObjSize[1,2]+70  MSGET dDataFim SIZE 038,008	OF oPanel1 PIXEL WHEN .T. PICTURE "@D 99/99/9999" 

//-----------------
//| Segundo Painel
//| Armazena os checkbox com todos os eventos da folha
//-----------------------------------------------------
@ 0, aObjSize[1,2] GROUP oGroup TO 47 ,aObjSize[1,4]*0.68 LABEL OemToAnsi(STR0007) OF oPanel2  PIXEL	//"Eventos "

oGroup:oFont:=oFont

Iif(lInt2500, Aadd(aItens, OemToAnsi(STR0008) ),"") //S-2500 - Processos Trabalhistas
Iif(lInt2501, Aadd(aItens, OemToAnsi(STR0009) ),"") //S-2501- Informações de Tributos Decorrentes de Processo Trabalhista
Iif(lInt3500, Aadd(aItens, OemToAnsi(STR0010) ),"") //S-3500 - Exclusão Processos Trabalhistas

	@ aObjSize[1,1]*0.62, aObjSize[1,2]+5	CHECKBOX aObjCheck[1] VAR aCheck[1] PROMPT "" SIZE 010,007 OF oPanel2 PIXEL WHEN .T.
	@ aObjSize[1,1]*0.62, aObjSize[1,2]+15	SAY OemToAnsi(STR0008)  SIZE 200,060 OF oPanel2 PIXEL	//"S-2500 - Processos Trabalhistas
	@ aObjSize[1,1]*0.62, aObjSize[1,2]+205 CHECKBOX aObjCheck[2] VAR aCheck[2] PROMPT "" SIZE 010,007 OF oPanel2 PIXEL WHEN  .T.
	@ aObjSize[1,1]*0.62, aObjSize[1,2]+220 SAY   OemToAnsi(STR0009)  SIZE 200,060 OF oPanel2 PIXEL	//"S-2501- Informações de Tributos Decorrentes de Processo Trabalhista

	@ aObjSize[1,1]*1.402, aObjSize[1,2]+5	CHECKBOX aObjCheck[3] VAR aCheck[3] PROMPT "" SIZE 010,007 OF oPanel2 PIXEL WHEN .T.
	@ aObjSize[1,1]*1.402, aObjSize[1,2]+15	SAY OemToAnsi(STR0010)  SIZE 250,060 OF oPanel2 PIXEL	//"S-3500 - Exclusão Processos Trabalhistas

	@ aObjSize[1,1]*2.105, aObjSize[1,2]+5	CHECKBOX aObjCheck[4] VAR aCheck[4] PROMPT "" SIZE 010,007 OF oPanel2 PIXEL WHEN .T.
	@ aObjSize[1,1]*2.105, aObjSize[1,2]+15	SAY OemToAnsi(STR0019)  SIZE 250,060 OF oPanel2 PIXEL	//"Gera Retificador

	fGP38MrkS1(aArrayFil,cAliasTRB,aItens, aObjSize,@aColumns)

	oMark:= FWMarkBrowse():New()
	oMark:SetAlias(cAliasTRB)
	oMark:DisableReport(.T.)
	oMark:DisableFilter(.T.)
	oMark:SetTemporary(.T.)
	oMark:SetColumns(aColumns)
	oMark:SetOwner(oPanel3)	

	//--------------------------------------
	//| Aponta para qual browse sera criado
	//--------------------------------------
	oMark:SetFieldMark('OK')
	oMark:SetValid({||.T.})
	
	oBtFiltrar		:= TButton():New( aObjSize[1,1]*0.5, aObjSize[1,2]+15+230,OemToAnsi(STR0018),NIL,bFilt, 060 , 012 , NIL , NIL , NIL , .T. )	// "Filtro"
	oBtProcessar	:= TButton():New( aObjSize[1,1]*0.5, aObjSize[1,2]+15+300,OemToAnsi(STR0011),NIL,bOK1	, 060 , 012 , NIL , NIL , NIL , .T. )	// "Processar"
	oBtFechar		:= TButton():New( aObjSize[1,1]*0.5, aObjSize[1,2]+15+370,OemToAnsi(STR0012),NIL,bFecha, 060 , 012 , NIL , NIL , NIL , .T. )	// "Fechar"

	oMark:SetMenuDef("GPEM038")

	oMark:bAllMark := {|| SetMarkAll(oMark:Mark(), lMarcar := !lMarcar,cAliasTRB), oMark:Refresh(.T.)}

	oMark:Activate()

	ACTIVATE MSDIALOG oDlg CENTERED

	//Finaliza qualquer área ainda aberta
	If ValType(oTempTable) == "O"
		oTempTable:Delete()
		oTempTable	:= Nil
	EndIf
	RestArea(aArea)

Return

/*/{Protheus.doc}
@Author   Silvia Taguti
@Date      03/11/2022
@Type      Static Function
Função responsável por fazer a criação dos dados temporários das filiais cadastradas no TAF
/*/
Static Function fCriaTmp(cAliasTRB)   

Local cQryWhere		:= ""
Local nPos			:= 0
Local aArea			:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())
Local aAreaC1E		:= C1E->(GetArea())
Local cAliasC1E  	:= GetNextAlias()
Local aStru   		:= {}
Local lContinua		:= .T.

Private cCadastro	:= OemToAnsi(STR0015) //"Filiais"
Private aRotina		:= {}

IIf(Select(cAliasTRB) > 0,(cAliasTRB)->(DbCloseArea()), .T.)

//--------------------------------
//| Estrutura da tabela | Colunas
//--------------------------------
Aadd(aStru, {"OK"		, "C", 2						, 0})
Aadd(aStru, {"FILTAF"	, "C", TamSx3("C1E_FILTAF")[1]	, 0})
Aadd(aStru, {"NOME"  	, "C", 100						, 0})
Aadd(aStru, {"CNPJ"  	, "C", TamSx3("CTT_CEI")[1]  	, 0})
Aadd(aStru, {"DTINI" 	, "C", TamSx3("C1E_DTINI")[1]	, 0})
Aadd(aStru, {"DTFIN" 	, "C", TamSx3("C1E_DTFIN")[1]	, 0})

oTempTable := FWTemporaryTable():New(cAliasTRB)
oTempTable:SetFields( aStru )
oTempTable:Create()

//------------------------------------------
//| Buscando dados Complemento Empresa (C1E)
//------------------------------------------	
cQryWhere := "%C1E_ATIVO = '1' AND C1E_MATRIZ = 'T'%"
	
//Query para buscar informacoes de processos e varas		
BeginSql alias cAliasC1E
	SELECT 
		C1E_FILTAF, C1E_NOME, C1E_DTINI, C1E_DTFIN 	, 	C1E_CODFIL 		
	FROM 
		%table:C1E% C1E									
	WHERE
		%exp:cQryWhere% AND C1E.%notDel%	
EndSql				

//Posiciona no inicio do arquivo
dbSelectArea(cAliasC1E)

//----------------------------------------
//| "Gravando" dados na tabela temporária
//---------------------------------------- 
While (cAliasC1E)->(!EOF())
	lContinua := .T.	
	
	//Busca CNPJ
	nPos := aScan(aSM0, {|x| alltrim(x[1] + X[2]) == AllTrim((cAliasC1E)->C1E_CODFIL/*FILTAF*/)})  
	//Alimentando a tabela 
	RecLock(cAliasTRB, .T.)
		(cAliasTRB)->FILTAF	:= (cAliasC1E)->C1E_FILTAF
		(cAliasTRB)->NOME  	:= (cAliasC1E)->C1E_NOME
		(cAliasTRB)->CNPJ 	:= IIF(nPos > 0, aSM0[nPos, 18], "")
		(cAliasTRB)->DTINI 	:= (cAliasC1E)->C1E_DTINI
		(cAliasTRB)->DTFIN 	:= (cAliasC1E)->C1E_DTFIN
	(cAliasTRB)->(MsUnlock()) 
	
	(cAliasC1E)->(dbSkip())
EndDo

//--------------------------------------------
//| Apontando para o primeiro registro válido
//--------------------------------------------
(cAliasTRB)->(dbGoTop())
(cAliasC1E)->(DbCloseArea())

RestArea(aAreaSM0)
RestArea(aAreaC1E)
RestArea(aArea)

Return()


/*/{Protheus.doc}
@Author    Silvia Taguti
@Date      03/11/2022
@Type      Static Function
Função responsável por fazer a execução das funções de acordo com o Check marcado
/*/
Static Function fGp38InTaf(aCheck, dDataIni, dDataFim, aArrayFil,cExpFiltro)

Local aArea	 		:= GetArea()
Local aLogs			:= {}
Local aTitle		:= {}
Local nCont			:= 0
Local lRetific 		:= .F.

Aadd(aTitle, OemToAnsi(STR0023)) //"Registros do evento S-2500 integrados corretamente: "##1
Aadd(aTitle, OemToAnsi(STR0024)) //"Registros do evento S-2500 que NÃO foram integrados: "##2
Aadd(aTitle, OemToAnsi(STR0025)) //"Resumo de processamento do evento S-2500"##3
Aadd(aTitle, OemToAnsi(STR0026)) //"Registros do evento S-2501 integrados corretamente: "##4
Aadd(aTitle, OemToAnsi(STR0027)) //"Registros do evento S-2501 que NÃO foram integrados: "##5
Aadd(aTitle, OemToAnsi(STR0028)) //"Resumo de processamento do evento S-2501"##6
Aadd(aTitle, OemToAnsi(STR0029)) //"Registros do evento S-3500 integrados corretamente: "##7
Aadd(aTitle, OemToAnsi(STR0030)) //"Registros do evento S-3500 que NÃO foram integrados: "##8
Aadd(aTitle, OemToAnsi(STR0031))  //"Resumo de processamento do evento S-3500"##9

For nCont := 1 To 9
	aAdd( aLogs, {} )
Next nCont

lRetific := aCheck[4]

//Se existirem filiais com periodo vigente aArrayFil contera informacoes
If Len(aArrayFil) > 0

	// Trecho comentado para não ficar pendente na issue x cobertura. Retirar quando rotina estiver pronta
	
	//S-2500 - Processos Trabalhistas"
	If aCheck[1] .And. Findfunction("fNew2500")
		fNew2500(dDataIni, dDataFim, aArrayFil, lRetific, @aLogs[1], aCheck, @aLogs[2],cVersEnvio,cCPFDe,cCPFAte,cProcDe,cProcAte)
	EndIf

	//S-2501- Informações de Tributos Decorrentes de Processo Trabalhista"
	If aCheck[2] .And. Findfunction("fNew2501")
		fNew2501(dDataIni, aArrayFil, lRetific, @aLogs[4], @aLogs[5])
	EndIf

	//S-3500 - Exclusão Processos Trabalhistas
	If aCheck[3] .And. Findfunction("fNew3500")
		fNew3500(dDataIni, dDataFim, aArrayFil,@aLogs[7], aCheck, @aLogs[8])
	EndIf

	If  Len(aLogs) > 0
		fMakeLog(aLogs, aTitle, Nil, Nil, , OemToAnsi(STR0001), "M", "L",, .F.) //"Log de Ocorrencias"
		aLogs := {}
    Endif 
EndIf

RestArea(aArea)
		
Return()

/*/{Protheus.doc}
@Author   Silvia Taguti
@Date      03/11/2022
@Type      Static Function
Função responsável por Marcar/Desmarcar todos os itens
/*/
Static Function SetMarkAll(cMarca,lMarcar,cAliasTRB)

Local cAliasMark:=cAliasTRB
Local aAreaMark  := (cAliasMark)->( GetArea() )

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

While !(cAliasMark)->( Eof() )
	RecLock( (cAliasMark), .F. )
	(cAliasMark)->OK := IIf( lMarcar , cMarca, '  ' )
	MsUnLock()
	(cAliasMark)->( dbSkip() )
EndDo

RestArea(aAreaMark)
Return .T.

/*/{Protheus.doc}
@Author   Silvia Taguti  
@Date      13/11/2019
@Type      Static Function
Função responsável por fazer a criação dos dados temporários das filiais cadastradas no Middleware
/*/
Static Function fCriaTmpMd(cAliasTRB)   

Local aArea			:= GetArea()
Local aAreaRJ9		:= RJ9->(GetArea())
Local nPos			:= 0
Local aStru   		:= {}
Local aSM0    		:= FWLoadSM0(.T.,,.T.)

Private cCadastro	:= OemToAnsi(STR0015) //"Filiais"
Private aRotina		:= {}

IIf(Select(cAliasTRB) > 0 , (cAliasTRB)->(DbCloseArea()), .T.)

//--------------------------------
//| Estrutura da tabela | Colunas
//--------------------------------
DbSelectArea("RJ9")
RJ9->(dbSetOrder(5))

    //Estrutura da tabela temporaria
    Aadd(aStru, {"OK"		, "C", 2						, 0})
    Aadd(aStru, {"FILTAF"	, "C", TamSx3("RJ9_FILIAL")[1]	, 0})
    Aadd(aStru, {"NOME"  	, "C", 100						, 0})
    Aadd(aStru, {"CNPJ"  	, "C", TamSx3("RJ9_NRINSC")[1]  	, 0})
    Aadd(aStru, {"DTINI" 	, "C", TamSx3("RJ9_INI")[1]	, 0})

    oTempTable := FWTemporaryTable():New(cAliasTRB)
    oTempTable:SetFields(aStru)
    oTempTable:AddIndex( "01", {"FILTAF"} )
    oTempTable:Create()

	RJ9->(dbGoTop())
	While !RJ9->(EOF())
		nPos := aScan(aSM0, {|x| Alltrim(x[1] + X[18]) ==  Alltrim(cEmpAnt+RJ9->RJ9_NRINSC) })
		If nPos > 0
			RecLock(cAliasTRB, .T.)
				(cAliasTRB)->FILTAF	:= aSM0[nPos, 2]		
				(cAliasTRB)->NOME  	:= RJ9->RJ9_NOME       
				(cAliasTRB)->CNPJ 	:= RJ9->RJ9_NRINSC		
				(cAliasTRB)->DTINI  := RJ9->RJ9_INI
				(cAliasTRB)->(MsUnlock())
		Endif
		RJ9->(dbSkip())
	Enddo

//--------------------------------------------
//| Apontando para o primeiro registro válido
//--------------------------------------------
RJ9->(DbCloseArea())

RestArea(aAreaRJ9)
RestArea(aArea)

Return()

/*/{Protheus.doc}
@Author   Silvia Taguti
@Date      12/04/2021
@Type      Static Function
Função responsável por realizar a checagem das filiais para carga
/*/
Static Function fGP38MrkS1(aArrayFil, cAliasTRB, aItens,aObjSize,aColumns)

Local aStru			:= {}
Local aStruCTT		:= {}
Local nPosFilTaf	:= 0	
Local nPosNome		:= 0 	
Local nPosCnpj		:= 0 
Local nPosDini		:= 0 
Local nPosDfin		:= 0 
Local cPrefixo      := ""
Local cAliasTaf		:= ""

Private cRotina		:= "GPEM038"
Private oMark
Private oDlgGrid
//Private aColumns	:= {}

//Tabela Auxiliar
If !lMiddleware
	fCriaTmp(cAliasTRB)
	cPrefixo 	:= "C1E_"
	cAliasTaf 	:= "C1E"
	Dbselectarea(cAliasTaf)
	aStru		    := C1E->(DBSTRUCT())
	Dbselectarea('CTT')
	aStruCTT		    := CTT->(DBSTRUCT())
		
	nPosFilTaf	:= aScan( aStru , { |x| x[1] == "C1E_FILTAF" } )
	nPosNome	:= aScan( aStru , { |x| x[1] == "C1E_NOME" } )
	nPosCnpj	:= aScan( aStruCTT , { |x| x[1] == "CTT_CEI" } )
	nPosDini	:= aScan( aStru , { |x| x[1] == "C1E_DTINI" } )
	nPosDfin	:= aScan( aStru , { |x| x[1] == "C1E_DTFIN" } )
Else
	fCriaTmpMd(cAliasTRB)
	cPrefixo 	:= "RJ9_"
	cAliasTaf 	:= "RJ9"
	Dbselectarea(cAliasTaf)
	aStru		    := RJ9->(DBSTRUCT())
		
	nPosFilTaf	:= aScan( aStru , { |x| x[1] == "RJ9_FILIAL" } )
	nPosNome	:= aScan( aStru , { |x| x[1] == "RJ9_NOME" } )
	nPosCnpj	:= aScan( aStru , { |x| x[1] == "RJ9_NRINSC" } )
	nPosDini	:= aScan( aStru , { |x| x[1] == "RJ9_INI" } )
Endif	

//--------------------------------------------------------------
//| Criando coluna Filial | Atribuindo nome | Dados estruturais 
//--------------------------------------------------------------
If nPosFilTaf > 0 			
	AAdd(aColumns,FWBrwColumn():New())
	If !lMiddleware
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran( aStru[nPosFilTaf][1], cPrefixo, "",1,1   ) +"}") )
	Else
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosFilTaf][1],"RJ9_FILIAL", "FILTAF",1,1   )+"}") )
	Endif	
	aColumns[Len(aColumns)]:SetTitle("Filial" ) 
	aColumns[Len(aColumns)]:SetSize(aStru[nPosFilTaf][3]) 
	aColumns[Len(aColumns)]:SetDecimal(aStru[nPosFilTaf][4])
	aColumns[Len(aColumns)]:SetPicture(PesqPict( cAliasTaf ,  aStru[nPosFilTaf][1]))
EndIf		

//--------------------------------------------------------------
//| Criando coluna Nome   | Atribuindo nome | Dados estruturais 
//--------------------------------------------------------------
If nPosNome > 0 		 	
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosNome][1],cPrefixo, "",1,1   )+"}") )
	aColumns[Len(aColumns)]:SetTitle("Nome") 
	aColumns[Len(aColumns)]:SetSize(aStru[nPosNome][3]) 
	aColumns[Len(aColumns)]:SetDecimal(aStru[nPosNome][4])
	aColumns[Len(aColumns)]:SetPicture(PesqPict( cAliasTaf,  aStru[nPosNome][1]))
EndIf	

//--------------------------------------------------------------
//| Criando coluna CNPJ   | Atribuindo nome | Dados estruturais 
//--------------------------------------------------------------
If nPosCnpj > 0 		 	
	AAdd(aColumns,FWBrwColumn():New())	
	If !lMiddleware
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStruCTT[nPosCnpj][1],"CTT_CEI", "CNPJ",1,1   )+"}") )
	Else
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosCnpj][1],"RJ9_NRINSC", "CNPJ",1,1   )+"}") )
	Endif	
	aColumns[Len(aColumns)]:SetTitle("Cnpj") 
	If !lMiddleware
		aColumns[Len(aColumns)]:SetSize(aStruCTT[nPosCnpj][3]) 
		aColumns[Len(aColumns)]:SetDecimal(aStruCTT[nPosCnpj][4])
	Else
		aColumns[Len(aColumns)]:SetSize(aStru[nPosCnpj][3]) 
		aColumns[Len(aColumns)]:SetDecimal(aStru[nPosCnpj][4])
	Endif	
	aColumns[Len(aColumns)]:SetPicture(  "@R 99.999.999/9999-99"   )
EndIf	

//-------------------------------------------------------------------
//| Criando coluna Data Inicio | Atribuindo nome | Dados estruturais 
//-------------------------------------------------------------------
If nPosDini > 0 		 	
	AAdd(aColumns,FWBrwColumn():New())
	If !lMiddleware
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosDini][1], cPrefixo, "",1,1   )+"}") )
	Else
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosDini][1],"RJ9_INI", "DTINI",1,1   )+"}") )
	Endif	
	aColumns[Len(aColumns)]:SetTitle("Dt. Ini. Validade") 
	aColumns[Len(aColumns)]:SetSize(aStru[nPosDini][3]) 
	aColumns[Len(aColumns)]:SetDecimal(aStru[nPosDini][4])
	aColumns[Len(aColumns)]:SetPicture(PesqPict( cAliasTaf,  aStru[nPosDini][1]))
EndIf	

//-------------------------------------------------------------------
//| Criando coluna Data Final  | Atribuindo nome | Dados estruturais 
//-------------------------------------------------------------------
If nPosDfin > 0 .And. !lMiddleware 		 	
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosDfin][1],"C1E_", "",1,1   )+"}") )
	aColumns[Len(aColumns)]:SetTitle("Dt. Fin. Validade") 
	aColumns[Len(aColumns)]:SetSize(aStru[nPosDfin][3]) 
	aColumns[Len(aColumns)]:SetDecimal(aStru[nPosDfin][4])
	aColumns[Len(aColumns)]:SetPicture(PesqPict("C1E",  aStru[nPosDfin][1]))
EndIf	
	
Return()

/*/{Protheus.doc}
@Author   Silvia Taguti
@Date      12/04/2021
@Type      Static Function
Função responsável por fazer a validação de TudOk da tela de seleção de filiais
/*/
Function fGp38TdOk1(aCheck,cAliasTRB,cCompete,aArrayFil, aItens)
Local aArea	:= GetArea()
Local nErro	:= 0
Local lRet	:= .T.
Local nx 	:= 0	

//---------------------------------
//| Consiste a datas (vazias)
//---------------------------------	
If Empty(dDataIni) .and. nErro = 0
	//Help( ,, OemToAnsi(STR0004) ,,OemToAnsi(STR0013), 1, 0 )//#"Necessário preencher a data inicial."
	MsgStop(OemToAnsi(STR0013))
	lRet := .F.	
	nErro += nErro
Endif

If Empty(dDataFim) .and. nErro = 0
	//Help( ,, OemToAnsi(STR0004) ,,OemToAnsi(STR0014), 1, 0 )//#"Necessário preencher a data final."
	MsgStop(OemToAnsi(STR0014))
	lRet := .F.	
	nErro += nErro
Endif

If AnoMes(dDataIni) <> AnoMes(dDataFim) .and.  nErro = 0
	//Help( ,, OemToAnsi(STR0004) ,,OemToAnsi(STR0022), 1, 0 )//#A data inicial e final deve ser dentro do mesmo mês e ano
	MsgStop(OemToAnsi(STR0022))
	lRet := .F.	
	nErro += nErro
Endif
If dDataIni > dDataFim .and.  nErro = 0
	MsgStop(OemToAnsi(STR0032)) //"A data final deve ser maior que a data inicial"
	lRet := .F.	
	nErro += nErro
Endif

If !aCheck[1] .And.  !aCheck[2] .And. !aCheck[3] .and.  nErro = 0
	MsgStop(OemToAnsi(STR0035))
	lRet := .F.	
Endif

If lRet
	 aArrayFil		:= {}
	//Adiciona filiais selecionadas
	(cAliasTRB)->(dbGoTop())
	
	While (cAliasTRB)->(!EOF())
		If !Empty((cAliasTRB)->OK) 
			aAdd(aArrayFil, {Padr((cAliasTRB)->FILTAF, FWSIZEFILIAL()),substr((CALIASTRB)->CNPJ,1,8),{Padr((cAliasTRB)->FILTAF, FWSIZEFILIAL())}})
			For nX := 1 To Len(aSM0)
				If aSM0[nX, 1] == cEmpAnt .And. aSM0[nX, 2] != Padr((cAliasTRB)->FILTAF, FwSizeFilial()) .And. SubStr((cAliasTRB)->CNPJ, 1, 8) == SubStr(aSM0[nX, 18], 1, 8)
					aAdd( aArrayFil[Len(aArrayFil), 3], aSM0[nX, 2] )
				EndIf
			Next nX
		EndIf
		(cAliasTRB)->(dbSkip())	
	EndDo 
		//Valida filiais 
	If Len(aArrayFil) == 0 		
		MsgStop(If(!lMiddleware,OemToAnsi(STR0016),OemToAnsi(STR0017))) //#"Necessário selecionar uma filial para integração com o TAF"//Middleware
		lRet := .F.
	EndIf
	If lRet
		fGp38InTaf(aCheck, dDataIni, dDataFim, aArrayFil )
	Endif	
Endif	

RestArea(aArea)

Return(lRet)

/*/{Protheus.doc}
@Author   Silvia Taguti
@Date      03/11/2022
@Type      Static Function
Função responsável para Habilitar a seleção dos filtros
/*/
Static Function fSisParam()

	Pergunte("GPEM038",.T.)
	cCPFDe		:= MV_PAR01
	cCPFAte		:= MV_PAR02
	cProcDe		:= MV_PAR03
	cProcAte	:= MV_PAR04

Return
