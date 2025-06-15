#INCLUDE "PROTHEUS.CH"
#INCLUDE "RUP_PFS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"

Static _lExecutou    := .F.
Static _cEmpresa     := ""
Static _lAjuBrw      := .F. // Indica se deve ajustar o X3_BROWSE
Static _lCriaMot     := .T. // Indica se deve entrar na rotina de criação de motivo de baixa
Static _aTableSinc   := {}  // Verifica se a tabela deve ser sincronizada ao final de processamento da Filial
Static _aTabExist    := {}  // Verifica se as tabelas existem
Static _aColExist    := {}  // Verifica se as colunas Existem

//-------------------------------------------------------------------
/*/{Protheus.doc} RUP_PFS
Função para compatibilização do release incremental.
Esta função é relativa ao módulo pré-faturamento de Serviços (PFS).

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release de chegada Ex: 005
@param  cLocaliz   - Localização (país). Ex: BRA

@Author Cristina Cintra
@since 15/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function RUP_PFS(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
Local aSX3         := {}
Local aSX3Old      := {}
Local aSX3Estr     := {"X3_ARQUIVO", "X3_CAMPO", "X3_ORDEM"}

Local aSX9         := {}
Local aSX9Estr     := {"X9_DOM","X9_IDENT","X9_CDOM","X9_EXPDOM","X9_EXPCDOM","X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR", "lApaga" }

Local aSX7         := {}
Local aSX7Estr     := {"X7_CAMPO","X7_SEQUENC","X7_REGRA","X7_CDOMIN","X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_CONDIC","X7_PROPRI", "lApaga" }

Local aSX5         := {}

Local aSX6         := {}
Local aSX6Estr     := { "X6_FIL", "X6_VAR", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG", "X6_PYME" }
Local cSX6Conteudo := ""

#IFNDEF TOP
	Return Nil
#ENDIF

If _cEmpresa == cEmpAnt //Controle para permitir a atualização de todas as empresas
	_lExecutou := .T.
Else
	//Reinicia as variáveis estáticas a cada mudança de empresa, para alteração de dicionário de dados
	_lExecutou  := .F.
	_cEmpresa   := cEmpAnt
	_aTableSinc := {}
	_aTabExist  := {}
	_aColExist  := {}
EndIf

//----------------------------------------------------------------
// Solução paliativa sugerida pelo FrameWork para solucionar
// o errolog na função "SomaAbat", pois quando RUP_PFS é
// executado via UPDDISTR o SE1 está aberto de forma exclusiva
// e o "ChkFile" na linha 14283 (finxfin.prw) não consegue
// criar um novo alias.
//----------------------------------------------------------------
If FunName() == "UPDDISTR"
	DbSelectArea("SE1")
	SE1->(DbCloseArea())
	Chkfile("SE1", .F.)
EndIf

//------------------------------------------------------
// Atualizações necessárias a patir do release V12.1.23
//------------------------------------------------------
If cRelFinish >= "023"

	//------------------------------------------------------------
	// DJURFAT1-8082 - Tarifador x Lançamentos financeiros
	//------------------------------------------------------------
	If JChkfile("NVE")
		JURPFS8082()
		JURPFS11409()
	EndIf
	
	//----------------------------------------------------------------------
	// DJURFAT1-9006  - Data de movimentação no adiantamento
	// DJURFAT1-12122 - Permitir informar cotação no adiantamento
	//----------------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NWF") .And. NWF->(JColumnPos("NWF_DTMOVI")) > 0
		AtuOrdem("NWF", 26, "NWF_DTMOVI")
		JPFS12122()
	EndIf

	//------------------------------------------------------------
	// DJURFAT1-9069 - Grid Configuração Tarifador
	//------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NYT") .And. JChkfile("NYV") .And. NYV->(JColumnPos("NYV_IDPART")) > 0
		AtuOrdem("NYV", 07, "NYV_IDPART")
		JURPFS9069()
	EndIf

	//----------------------------------------------------------------------
	// DJURFAT1-9097 - Hora da conclusão da revisão
	//----------------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NX0") .And. NX0->(JColumnPos("NX0_HRLIB")) > 0
		AtuOrdem("NX0", 65, "NX0_HRLIB")
	EndIf
	
	//--------------------------------------------------------------
	// DJURFAT1-9110 - Tarifador - Revisão/Aprovação de Lançamentos
	//--------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NYX") .And. NYX->(JColumnPos("NYX_STATUS")) > 0
		JURPFS9110()
	EndIf

	//-----------------------------------------------------------------------
	// DJURFAT1-9072 - Máscara das horas no histórico de participantes 
	//-----------------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NUR") .And. JChkfile("NUS")
		JURPFS9072()
	EndIf
	
	If !_lExecutou .And. JChkfile("NUE")
		aSX3      := {}
		aSX3Old   := {{"NUE", "NUE_ANOMES", ''}}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_VALID"}
		Aadd(aSX3, {"NUE", "NUE_ANOMES", 'JA144VLCPO("NUE_ANOMES")'})
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

	//-----------------------------------------------------------------------
	// DJURFAT1-8857 - Emissão de Nota Fiscal com cotação do recebimento
	// Criação do campo NXA_NFCOTA e ajuste de ordem na NXA
	//-----------------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NXA") .And. NXA->(JColumnPos("NXA_NFCOTA")) > 0
		AtuOrdem("NXA", Val(RetAsc('B4', 3, .F.)), "NXA_CCDPGT")
		AtuOrdem("NXA", Val(RetAsc('B5', 3, .F.)), "NXA_DCDPGT")
		AtuOrdem("NXA", Val(RetAsc('B6', 3, .F.)), "NXA_NFGER")
		AtuOrdem("NXA", Val(RetAsc('B7', 3, .F.)), "NXA_SERIE")
		AtuOrdem("NXA", Val(RetAsc('B8', 3, .F.)), "NXA_DOC")
		AtuOrdem("NXA", Val(RetAsc('B9', 3, .F.)), "NXA_NFCOTA")
		AtuOrdem("NXA", Val(RetAsc('C0', 3, .F.)), "NXA_TITGER")
		AtuOrdem("NXA", Val(RetAsc('C1', 3, .F.)), "NXA_PERFAT")
		AtuOrdem("NXA", Val(RetAsc('C2', 3, .F.)), "NXA_ESCATU")
		AtuOrdem("NXA", Val(RetAsc('C3', 3, .F.)), "NXA_FATATU")
		AtuOrdem("NXA", Val(RetAsc('C4', 3, .F.)), "NXA_CIDIO")
		AtuOrdem("NXA", Val(RetAsc('C5', 3, .F.)), "NXA_DIDIO")
		AtuOrdem("NXA", Val(RetAsc('C6', 3, .F.)), "NXA_CIDIO2")
		AtuOrdem("NXA", Val(RetAsc('C7', 3, .F.)), "NXA_DIDIO2")
		AtuOrdem("NXA", Val(RetAsc('C8', 3, .F.)), "NXA_CTPFAT")
		AtuOrdem("NXA", Val(RetAsc('C9', 3, .F.)), "NXA_TPREL")
		AtuOrdem("NXA", Val(RetAsc('D0', 3, .F.)), "NXA_DTPREL")
		AtuOrdem("NXA", Val(RetAsc('D1', 3, .F.)), "NXA_CCARTA")
		AtuOrdem("NXA", Val(RetAsc('D2', 3, .F.)), "NXA_DCARTA")
		AtuOrdem("NXA", Val(RetAsc('D3', 3, .F.)), "NXA_CTIPOF")
		AtuOrdem("NXA", Val(RetAsc('D4', 3, .F.)), "NXA_DTIPOF")
		AtuOrdem("NXA", Val(RetAsc('D5', 3, .F.)), "NXA_SIGLA2")
	EndIf

	//-----------------------------------------------------------------------
	//DJURFAT1-9713 Revisão de campos na Browse da Pré-fatura e Fatura
	//-----------------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NXA") .And. JChkfile("NXC") .And. JChkfile("NX0") .And. JChkfile("NX1")
		JURPFS9713()
	EndIf

	//========================================================================================
	// Funções para alterações no pacote de ajustes da JURA202 (006364) issue  DJURFAT1-8103
	// colocar todas alterações referente a esse pacote dentro dessa função.
	//========================================================================================
	If !_lExecutou
		JRUP202()
	EndIf

	//----------------------------------------------------------------------------------------------
	//DJURFAT1-9726 Aprovação de Despesas - Ajuste de naturezas com tipo de conta jurídica definida
	//----------------------------------------------------------------------------------------------
	If !_lExecutou .And. JChkfile("SED") .And. SED->(JColumnPos("ED_CCJURI")) .And. SED->(JColumnPos("ED_TPCOJR"))
		JURPFS9726()
	EndIf

	//-----------------------------------------------------------------------------------
	// DJURFAT1-7923 - Envio do link da NFS-e no envio de e-mail das faturas/Pesquisa por NFe
	//-----------------------------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NXA") 
		If NXA->(JColumnPos("NXA_NFELET")) > 0 .And. NXA->(JColumnPos("NXA_LINKNF")) > 0
			AtuOrdem("NXA", Val(RetAsc('C0', 3, .F.)), "NXA_NFELET")
			AtuOrdem("NXA", Val(RetAsc('C1', 3, .F.)), "NXA_LINKNF")
		EndIf
		If NXA->(JColumnPos("NXA_NFGER")) > 0
			aSX3      := {}
			aSX3Old   := {}
			aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TITULO", "X3_DESCRIC"}	
			Aadd(aSX3, {"NXA", "NXA_NFGER", "Doc Fis Ger?", "Documento Fiscal gerado?" } )		
			AtuSX3(aSX3, aSX3Estr, aSX3Old)
		EndIf
	EndIf

	If !_lExecutou .And. JChkfile("NS7") .And. NS7->(JColumnPos("NS7_LINKNF")) > 0
		AtuOrdem("NS7", 15, "NS7_LINKNF")
	EndIf

	//--------------------------------------------------------
	// DJURFAT1-8900 - Alteração formato da data no corpo do e-mail (envio de faturas)
	//--------------------------------------------------------
	If JChkfile("NRU") .And. NRU->(JColumnPos("NRU_DTFORM")) > 0
		JURPFS8900()
	EndIf

	//--------------------------------------------------------
	// DJURFAT1-9125 - Importação de Extrato Bancário
	//--------------------------------------------------------
	If JChkfile("OHB") .And. OHB->(JColumnPos("OHB_ORIGEM")) > 0  .And. OHB->(JColumnPos("OHB_CODLD")) > 0
		JURPFS9125()
	EndIf
	
	//-------------------------------------------------------------
	// DJURFAT1-10113 - Data de Revisão na Solicitação de Despesas
	//-------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NZQ") .And. NZQ->(JColumnPos("NZQ_DTREVI")) > 0
		AtuOrdem("NZQ", 16, "NZQ_DTREVI")
	EndIf

	//-----------------------------------------------------------------------
	// DJURFAT1-10442 - Atualiza campo de arquivo e-billing gerado na fatura
	//-----------------------------------------------------------------------
	If !_lExecutou .And. NXA->(JColumnPos("NXA_ARQEBI")) > 0
		JPFS10442()
	EndIf

	If !_lExecutou .And. JChkfile("NUH") .And. NUH->(JColumnPos("NUH_AGRUPA")) > 0
		AtuOrdem("NUH", 11, "NUH_AGRUPA")
		AtuOrdem("NUH", 12, "NUH_CEMAIL")
		AtuOrdem("NUH", 44, "NUH_CLIEBI")

		JURPFS10452() // Preenchimento do NUH_AGRUPA com 2-Não
	EndIf

	If !_lExecutou .And. JChkfile("NUH") .And. NUH->(JColumnPos("NUH_CORFAT")) > 0 .AND.;
	   JChkfile("NXA")  .AND. NXA->(JColumnPos("NXA_CORFAT")) > 0 
		JPFS10654() // Preenchimento dos campos NUH_CORFAT e NXA_CORFAT com 2-Não
	EndIf

	If !_lExecutou .And. JChkfile("NUH") .And. NUH->(JColumnPos("NUH_TPDESC")) > 0 .And. ;
	   JChkfile("NXP") .And. NXP->(JColumnPos("NXP_TPDESC")) > 0 .And. ;
	   JChkfile("NXG") .And. NXG->(JColumnPos("NXG_TPDESC")) > 0 .And. ;
	   JChkfile("NXA") .And. NXA->(JColumnPos("NXA_TPDESC")) > 0 .And. ;
	   JPFS10444() // DJURFAT1-10444 - Preenchimento dos campos de Tipo de Desconto (_TPDESC) com 1=Fixo.
	EndIf

	//-----------------------------------------------------------------------
	// DJURFAT1-11033 - Gravação E1_JURFAT para tabela OHT (Títulos x Faturas)
	//-----------------------------------------------------------------------
	If JChkfile("OHT") .And. FindFunction("JurTitFat") .And. FindFunction("JurGrvOHT")
		If JPFS11033() // Cria OHT das Faturas
			JLIQ11033() // Cria OHT de títulos liquidados
		EndIf
	EndIf

	//-------------------------------------------------------------
	// DJURFAT1-10179 - Filtro do Tipo de Fechamento na Pré-Fatura
	//-------------------------------------------------------------
	If !_lExecutou .And. NX0->(JColumnPos("NX0_TPFECH")) > 0
		AtuOrdem("NX0", 42, "NX0_TPFECH")
		AtuOrdem("NX0", 43, "NX0_DESFEC")
	EndIf

	//----------------------------------------------------------------------
	// DJURFAT1-10870 - Usabilidade na aprovação de solicitações de despesa
	//----------------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NZQ")
		aSX7      := {}
		aSX7Estr  := {"X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "lApaga" }
		Aadd(aSX7, {"NZQ_CTADES", "003", '""', "NZQ_SIGPRO", "__lApaga"} )
		Aadd(aSX7, {"NZQ_CTADES", "004", '""', "NZQ_NOMPRO", "__lApaga"} )
		Aadd(aSX7, {"NZQ_CTADES", "005", 'JGetTabRat(FWFldGet("NZQ_CTADES"), FWFldGet("NZQ_CRATEI"))', "NZQ_CRATEI", "__lApaga"} )
		Aadd(aSX7, {"NZQ_CTADES", "006", '""', "NZQ_DRATEI", "__lApaga"} )
		AtuSX7(aSX7, aSX7Estr)
	EndIf

	If !_lExecutou .And. JChkfile("NT1")
		// Remoção do When do campo NT1_DESCRI
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_WHEN"}
		Aadd(aSX3, {"NT1", "NT1_DESCRI", ""} )
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

	//-------------------------------------------------------------
	// DJURFAT1-11240 - Total do saldo anterior: Limite por Fatura
	//-------------------------------------------------------------
	If !_lExecutou .And. NX8->(JColumnPos("NX8_VSLDAC")) > 0
		AtuOrdem("NX8", 30, "NX8_VSLDAC")
	EndIf

	//-------------------------------------------------------------
	// DJURFAT1-10338 - Alteração do Nome do Arquivo Unificado
	//-------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NXM") .AND. NXM->(JColumnPos("NXM_CTPARQ")) > 0
		AtuNXMTPAR()
	EndIf
	
	//-------------------------------------------------------------
	// DJURFAT1-10371 - Log de envio de faturas por e-mail
	//-------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NXA") .And. NXA->(JColumnPos("NXA_PARTEN")) > 0
		AtuOrdem("NXA", 87, "NXA_PARTEN")
		AtuOrdem("NXA", 88, "NXA_DTHREN")
		AtuOrdem("NXA", 89, "NXA_LOGENV")
	EndIf

	//-------------------------------------------------------------
	// DJURFAT1-11609 - E-Mail CC Fatura
	//-------------------------------------------------------------
	If JChkfile("NXA") .And. NXA->(JColumnPos("NXA_CEMAIL")) > 0
		If !_lExecutou  
			AtuOrdem("NXA", 83, "NXA_CEMAIL")
		EndIf
		JPFS11609() // DJURFAT1-11609 - Preenchimento do campo NXA_ECMAIL
	EndIf

	//-------------------------------------------------------------
	// DJURFAT1-12607 - Ajuste X3_RELACAO do campo ED_JURDVER
	//-------------------------------------------------------------
	If !_lExecutou .And. JChkfile("SED") .And. SED->(JColumnPos("ED_JURVERB")) > 0
		aSX3      := {}
		aSX3Old   := {{"SED", "ED_JURDVER", "IF(!INCLUI,POSICIONE('SRV',1,xFilial('SRV')+FwFldGet('ED_JURVERB'),'RV_DESC'),'')"}}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO"}
		Aadd(aSX3, {"SED", "ED_JURDVER", "IF(!INCLUI,POSICIONE('SRV',1,xFilial('SRV')+SED->ED_JURVERB,'RV_DESC'),'')"})
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

	//------------------------------------------------------------
	// DJURFAT1-12128 - Grid Histórico de Cobrança
	//------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NX4") .And. NX4->(JColumnPos("NX4_CPART1")) > 0
		AtuOrdem("NX4", 07, "NX4_SIGLA1")
		AtuOrdem("NX4", 08, "NX4_CPART1")
		AtuOrdem("NX4", 09, "NX4_DPART1")
	EndIf

	//-------------------------------------------------------------
	// DJURFAT1-12834 - Ajuste X3_RELACAO dos campos OHB_DNATOR, OHB_DPROJE, OHB_DITPRJ, OHB_DNATDE, OHB_DPROJD e OHB_DITPRD
	//-------------------------------------------------------------
	If !_lExecutou .And. JChkfile("OHB") .And. OHB->(JColumnPos("OHB_NATORI")) > 0 .And. OHB->(JColumnPos("OHB_CPROJE")) > 0 .And. OHB->(JColumnPos("OHB_CITPRJ")) > 0 .And. OHB->(JColumnPos("OHB_CPROJD")) > 0
		JPFS12834()
	EndIf

	//------------------------------------------------------------
	// DJURFAT1-12093 - Pré-Fatura WO de Despesas
	//------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NXV") .And. NXV->(JColumnPos("NXV_TPLANC")) > 0
		JPFS12093() // DJURFAT1-12093 - Preenchimento do campo NXV_TPLANC
	EndIf

	//------------------------------------------------------------
	// DJURFAT1-12872 - Contabilização WO Filial
	//------------------------------------------------------------
	If JChkfile("NVY") .And. NVY->(JColumnPos("NVY_CPAGTO")) > 0 .And. NVY->(JColumnPos("NVY_FILLAN")) > 0 .And. JChkfile("NWZ") .And. NWZ->(JColumnPos("NWZ_FILLAN")) > 0
		JPFS12872() // DJURFAT1-12872 - Contabilização WO Filial
	EndIf

	//----------------------------------------------------------------------------
	// DJURFAT1-12841 - Ajustes no cadastro de Configuração de Envio de E-mails
	//----------------------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NRU") .And. NRU->(JColumnPos("NRU_ASSUNT")) > 0 
		JPFS12841()
	EndIf

	//----------------------------------------------------------------------------
	// DJURFAT1-12842 - Ajustes no Fechamento de Período
	//----------------------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NVQ") .And. NVQ->(JColumnPos("NVQ_RECALC")) > 0 
		JPFS12842()
	EndIf

	//----------------------------------------------------------------------------
	// DJURFAT1-13504 - Ajustes na Natureza transitória de pagamento
	//----------------------------------------------------------------------------
	If JChkfile("OHP")
		JPFS13504()
	EndIf

	//----------------------------------------------------------------------------
	// DJURFAT1-14913 - Ajustes para permitir várias naturezas de desp. cliente
	//----------------------------------------------------------------------------
	JPFS14913()

	//----------------------------------------------------------------------------
	// DJURFAT1-16035 - Indicação de adiantamento na Aprovação de Despesas
	//----------------------------------------------------------------------------
	If NZQ->(JColumnPos("NZQ_ADIANT")) > 0
		JPFS16035()
	EndIf
EndIf

If _lCriaMot
	CriaMotBx("CNF", "CANCELA NF", "ANNN") // Cria motivo de baixa CNF
	_lCriaMot := .F.
EndIf

//----------------------------------------------------------------
// DJURFAT1-10547 - Limpa registros da fila de emissão de faturas
//----------------------------------------------------------------
JPFS10547()

If JChkfile("OHH")
	//---------------------------------------------------------------------------------------
	// DJURFAT1-9839 - Relatório Aging por Sócio (Mostrando valor bruto). - JURAPAD037
	//---------------------------------------------------------------------------------------
	If OHH->(JColumnPos( "OHH_ABATIM" )) > 0 .And. FwIsInCallStack("UPDPFS")
		AbatOHH() //Atualiza a tabela OHH para preencher os abatimentos do título
	EndIf

	//---------------------------------------------------------------------------------------
	// DJURFAT1-11034 - Desmembramento do campo OHH_JURFAT nos campos OHH_CESCR e OHH_CFATUR
	//---------------------------------------------------------------------------------------
	If OHH->(JColumnPos( "OHH_CESCR" )) > 0
		JPFS11034()
	EndIf

	//----------------------------------------------------------------------
	// DJURFAT1-12801 - Campo para envio de Minuta
	//----------------------------------------------------------------------
	If !_lExecutou .And.  JChkfile("NUH") .And. NUH->(JColumnPos("NUH_EMLMIN")) > 0
		JPFS12801()
	EndIf

	//----------------------------------------------------------------------
	// DJURFAT1-12959 - Campo recalcula no Calendário Contábil
	//----------------------------------------------------------------------
	If !_lExecutou .And. JChkfile("CQD") .And. CQD->(JColumnPos("CQD_PFSREC")) > 0
		JPFS12959()
	EndIf

EndIf

//------------------------------------------------------------------------------------
// DJURFAT1-12765 - Exclusão de relacionamentos que foram substituídos
//------------------------------------------------------------------------------------
If !_lExecutou .And. JChkfile("NXA")
	aSX9     := {}
	aSX9Estr := {"X9_DOM","X9_IDENT","X9_CDOM","X9_EXPDOM","X9_EXPCDOM","X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR", "lApaga" }

	//         {"X9_DOM","X9_IDENT","X9_CDOM" ,"X9_EXPDOM" ,"X9_EXPCDOM" ,"X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR", "lApaga"}
	aAdd(aSX9, {"NXA"   ,"001"     ,"NVN"     ,"NXA_CESCR" , "NVN_CESCR" ,           ,           ,            ,            ,           ,           ,           ,           ,"__lApaga"})
	aAdd(aSX9, {"NXA"   ,"002"     ,"NVN"     ,"NXA_COD"   , "NVN_CFATUR",           ,           ,            ,            ,           ,           ,           ,           ,"__lApaga"})
	AtuSX9(aSX9, aSX9Estr)
EndIf

If !_lExecutou .And. JChkfile("NVE")
	aSX9     := {}
	aSX9Estr := {"X9_DOM","X9_IDENT","X9_CDOM","X9_EXPDOM","X9_EXPCDOM","X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR", "lApaga" }
	//         {"X9_DOM","X9_IDENT","X9_CDOM" ,"X9_EXPDOM" ,"X9_EXPCDOM" ,"X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR", "lApaga"}
	aAdd(aSX9, {"NVE"   ,"004"     ,"NWN"     ,"NVE_NUMCAS" , "NWN_CCASO" ,           ,           ,            ,            ,           ,           ,           ,           ,"__lApaga"})
	AtuSX9(aSX9, aSX9Estr)
EndIf

If !_lExecutou
	//--------------------------------------------------------
	// DJURFAT1-12084 - Débitos técnicos Ajustes SX9 Parte 3
	//--------------------------------------------------------
	JPFS12084()

	//--------------------------------------------------------
	// DJURFAT1-13046 - Débitos técnicos Ajustes SX9 Parte 4
	//--------------------------------------------------------
	JPFS13046()

	//--------------------------------------------------------
	// DJURFAT1-13184 - Débitos técnicos Ajustes SX9 Parte 5
	//--------------------------------------------------------
	JPFS13184()

	//--------------------------------------------------------
	// DJURFAT1-13063 - Ajustes no WO de Despesas
	//--------------------------------------------------------
	JPFS13063()
	
	//--------------------------------------------------------
	// DJURFAT1-13704 - Ajustes no Controle de Adiantamentos
	//--------------------------------------------------------
	JPFS13704()

	//----------------------------------------------------------------------
	// DJURFAT1-13791 - Ajuste nas validações de réplica a partir da Despesa
	//----------------------------------------------------------------------
	JPFS13791()

	//------------------------------------------------------------
	// DJURFAT1-13015 - Ajuste Fechamento de Conta do Parcipante
	//------------------------------------------------------------
	If JChkfile("OHB") .And. OHB->(JColumnPos("OHB_DTLANC")) > 0
		AtuOrdem("OHB", 04, "OHB_DTLANC")
	EndIf

	//----------------------------------------------------------------------
	// DJURFAT1-14432 - Revisão de TSs de contratos fixos e não cobráveis e 
	// Débitos Técnicos, exclusão de relacionamento
	//----------------------------------------------------------------------
	JPFS14432()

	//----------------------------------------------------------------------
	// DJURFAT1-14119 - Vínculo de TimeSheet não cobrável na emissão 
	//----------------------------------------------------------------------
	JPFS14119()

	//---------------------------------------------------------------------------------
	// DJURFAT1-14546 - Agrupamento no envio de faturas por e-mail - encaminhamentos
	//---------------------------------------------------------------------------------
	JPFS14546()

	//----------------------------------------------------------------------
	// DJURFAT1-14594 - Gross up de Impostos / Honorários
	//----------------------------------------------------------------------
	JPFS14594()

	//----------------------------------------------------------------------
	// DJURFAT1-14640 - Quantidade de casos para cálculo de faixa
	//----------------------------------------------------------------------
	JPFS14640()

	//--------------------------------------------------
	// DJURFAT1-JPFS14504 - Ajuste tamanho do campo NWF_COD
	//------------------------------------------------------
	JPFS14504()

	//---------------------------------------------------------
	// DJURFAT1-JPFS15624 - Ajuste na ordem do campo NUH_ENCCAS
	//---------------------------------------------------------
	JPFS15624()

	//------------------------------------------------------------------------------------
	// DJURFAT1-15881 - Desconto não é preenchido no Participante da Fatura (NXD_DESCTO)
	//------------------------------------------------------------------------------------
	If FindFunction("J201DesLin")
		JPFS15881()
	EndIf

	//----------------------------------------------------------------------------
	// DJURFAT1-15929 - Tira usado do campo NRC_FUTURO
	//----------------------------------------------------------------------------
	JPFS15929()

	//----------------------------------------------------------------------------
	// DJURFAT1-16328 - Novos campos na tela de Casos (GAP V11) - Itens 28 e 29
	//----------------------------------------------------------------------------
	JPFS16328()

	//----------------------------------------------------------------------------
	// DJURDEP-11582 - Ajuste na Ordem dos campos de Relatório Unificado.
	//----------------------------------------------------------------------------
	JJUR11582()
EndIf

//--------------------------------------------------------
// DJURFAT1-13102 - Ajustes no Controle de Adiantamentos
//--------------------------------------------------------
If !_lExecutou
	aSX7      := {}
	aSX7Estr  := {"X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "lApaga" }
	Aadd(aSX7, {"NWF_CCLIEN", "005", '""', "NWF_CESCR ", "__lApaga"} )
	Aadd(aSX7, {"NWF_CLOJA ", "005", '""', "NWF_CESCR ", "__lApaga"} )
	Aadd(aSX7, {"NWF_CLOJA ", "008", "NUH->NUH_CESCR2                                                                                     ", "NWF_CESCR ", "__lApaga"} )
	AtuSX7(aSX7, aSX7Estr)
EndIf

If !_lExecutou .And. SuperGetMV('MV_JUTPROJ', , .F.)
	JDEP10299()
EndIf

If FunName() == "UPDDISTR"
	SE1->(DbCloseArea())
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSX3(aSX3)
Função para ajustar o SX3. Caso aSX3Old tenha conteúdo, a alteração é
realizada apenas se o conteúdo for igual a base do cliente.
Uso Geral

@Param aSX3 Array com alterações do arquivo SX3

@author Cristina Cintra
@since 15/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuSX3(aSX3, aSX3Estr, aSX3Old, cLog)
Local nI        := 0
Local nJ        := 0
Local cKey      := ""
Local xValue    := Nil
Local xValueOld := Nil
Local xValueDic := Nil
Local lAtualiza := .F.
Local cCabec    := ""
Local cAux      := ""
Local cValType  := ""
Local lOrdem    := aScan(aSX3Estr, "X3_ORDEM") > 0
Local nPosRec   := aScan(aSX3Estr, "RECNO")
Local lAchou    := .F.

Default cLog    := ""
Default aSX3Old := {}

/*
aSX3Estr/aSX3
[1]X3_ARQUIVO
[2]X3_CAMPO
*/

DbSelectArea("SX3")
SX3->( DbSetOrder(2) ) //X3_CAMPO

For nI := 1 To Len(aSX3)

	If !Empty(aSX3[nI][1]) .And. (aSX3[nI][1] == SubStr(aSX3[nI][2], 1, 3) .Or. ;
	                               (SubStr(aSX3[nI][1], 1, 1) == 'S' .And. ;
	                                SubStr(aSX3[nI][1], 2, 3) == SubStr(aSX3[nI][2], 1, 2) ) ) // Tabelas com a letra S no início

		cKey := PadR( aSX3[nI][2], 10)
		If nPosRec == 0
			SX3->(DbSeek(cKey))
			lAchou := SX3->(Found())
		Else
			lAchou := .T.
			SX3->(DbGoTo(aSX3[nI][nPosRec]))
		EndIf

		If lAchou .And. (lOrdem .Or. UPPER(SX3->X3_PROPRI) != "U") // Quando for campo de usuário atualiza somente o X3_ORDEM

			RecLock("SX3", .F.)
			cCabec := aSX3[nI][aScan(aSX3Estr, "X3_CAMPO")] + CRLF //Nome do campo
			cAux   := ""

			For nJ := 1 To Len(aSX3Estr)
				If nJ <> nPosRec .And. FieldPos(aSX3Estr[nJ]) > 0

					xValueDic := FieldGet(FieldPos(Alltrim(aSX3Estr[nJ])))
					xValueDic := Iif(ValType(xValueDic) == "C", Alltrim(xValueDic), xValueDic) //Valor  no dicionario do cliente

					If Len(aSX3Old) > 0 //Só altera se não tiver conteudo anterior ou o conteudo do campo X3_XXX atual for igual ao conteudo do release para não alterar customizações.
						xValueOld := aSX3Old[nI][nJ]
						xValueOld := Iif(ValType(xValueOld) == "C", Alltrim(xValueOld), xValueOld)
						lAtualiza := xValueDic == xValueOld
					Else
						lAtualiza := .T.
					EndIf

					If lAtualiza
						//Adiciona novo valor no X3_XXX do campo
						cValType := ValType(aSX3[nI,nJ])
						If cValType != "U" // Torna possível ignorar uma determinada posição passando Nil.
							xValue := Iif(cValType == "C", Alltrim(aSX3[nI,nJ]), aSX3[nI,nJ])

							If !(xValue == xValueDic)
								FieldPut(FieldPos(Alltrim(aSX3Estr[nJ])), xValue)
								cAux += aSX3Estr[nJ] + Space(10 - Len(aSX3Estr[nJ])) + ": [" + Alltrim(AllToChar(xValueDic)) + "] -> [" + Alltrim(AllToChar(xValue)) + "] " + CRLF
							EndIf
						EndIf
					EndIf
				EndIf

			Next nJ

			If !Empty(cAux)
				cLog += cCabec + cAux + Replicate( "-", 78 ) + CRLF + CRLF
			EndIf

			SX3->(MsUnLock())
			SX3->(dbCommit())
		Else
			JurLogMsg(cEmpAnt + "] " + JurTimeStamp(2) +" ["+ STR0001 + cKey) //"Campo não encontrado: "
		EndIf

	EndIf
Next nI

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSX9(aSX9)
Função para ajustar o SX9.
lApaga -> A funcao compatibilizadora procura pelo rotulo 'lApaga'  no array aSX9ESTR e
verifica se a posição correspondente no array aSX9 possui o conteudo '__lApaga'.
Nessas condicoes o relacionamento será apagado se o conteudo existir, e se não existir
ou for diferente, todas as informacoes do mesmo serao substituidas pelas informadas em aSX9.
No procedimento padrao, o relacionamento é adicionado no caso de não existir.

Uso Geral

@Param aSX9 Array com alterações do arquivo SX9

@author Ricardo Ferreira Neves
@since 25/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuSX9(aSX9, aSX9Estr)
Local i         := 0
Local j         := 0
Local nPosUpd   := Ascan(aSX9Estr,{|x| x == "lApaga"} )
Local lApaga    := .F.
Local lRecLock  := .F. // Indica se foi feito RecLock para atualização do registro
Local cDominio  := ""
Local cCDominio := ""

dbSelectArea("SX9")
dbSetOrder(2) // X9_CDOM + X9_DOM

For i := 1 To Len(aSX9)
	If !Empty(aSX9[i][2])

		If ( Len(aSX9[i] ) >= Len(aSX9Estr) )
			// Se existir a coluna de atualizacao no array aSX9Est e se no array de parametros existir
			// a instrucao de exclusão do parametro força a exclusão do registro.
			If( nPosUpd > 0 ) .and. aSX9[i, nPosUpd ] ==  "__lApaga"
				lApaga	:= .T.
			Else
				lApaga	:= .F.
			Endif
		Endif

		If SX9->(DbSeek(aSX9[i,3] + aSX9[i,1])) // X9_CDOM + X9_DOM
			
			cDominio  := aSX9[i,1]
			cCDominio := aSX9[i,3]

			While SX9->(!EOF()) .And. SX9->X9_DOM == cDominio .And. SX9->X9_CDOM == cCDominio
			
				If AllTrim(SX9->X9_EXPDOM) == aSX9[i,4] .And. AllTrim(SX9->X9_EXPCDOM) == aSX9[i,5]
					RecLock("SX9",.F.)
					lRecLock := .T.
				EndIf

				If lRecLock
					If lApaga
						SX9->(DbDelete())
					Else
						For j := 1 To Len(aSX9[i])
							If !Empty(FieldName(FieldPos(aSX9Estr[j])))
								FieldPut(FieldPos(aSX9Estr[j]), aSX9[i, j])
							EndIf
						Next j
					EndIf

					SX9->(MsUnLock())
					SX9->(dbCommit())
				EndIf

				lRecLock := .F.

				SX9->( DbSkip() )
			
			EndDo

		EndIf

		lApaga   := .F.
		lRecLock := .F.

	EndIf
Next i

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSX7(aSX7, aSX7ESTR)
Função para ajustar o SX7.
lApaga -> A funcao compatibilizadora procura pelo rotulo 'lApaga'  no array aSX7ESTR e
verifica se a posição correspondente no array aSX7 possui o conteudo '__lApaga'.
Nessas condicoes o gatilho será apagado se o conteudo existir, e se não existir
ou for diferente, todas as informacoes do mesmo serao substituidas pelas informadas em aSX7.
No procedimento padrao, o relacionamento é adicionado no caso de não existir.

Uso Geral

@Param aSX7      Array com alterações do arquivo SX7
@Param aSX7ESTR  Array com os campos da estrutura do arquivo SX7

@author Luciano Pereira dos Santos
@since 28/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuSX7(aSX7, aSX7ESTR)
Local i         := 0
Local j         := 0
Local lGravaSX7 := .T.
Local lNovo     := .F.
Local lApaga    := .F.
Local cEspaco   := ''
Local nPosNCria := Ascan(aSX7Estr,{|x| x == "lNaoCria"})
Local nPosDel   := Ascan(aSX7Estr,{|x| x == "lApaga"} )
Local nPosCdom  := Ascan(aSX7Estr,{|x| x == "X7_CDOMIN"})
Local nPosRegr  := Ascan(aSX7Estr,{|x| x == "X7_REGRA"})
Local nPosAlia  := Ascan(aSX7Estr,{|x| x == "X7_ALIAS"})
Local nPosOrdm  := Ascan(aSX7Estr,{|x| x == "X7_ORDEM"})
Local nPosChav  := Ascan(aSX7Estr,{|x| x == "X7_CHAVE"})
Local nPosCond  := Ascan(aSX7Estr,{|x| x == "X7_CONDIC"})

dbSelectArea("SX7")
SX7->(dbSetOrder(1))

For i := 1 To Len(aSX7)
	lGravaSX7 := .T.
	lNovo     := .F.
	lApaga    := .F.
	cEspaco   := space(10-(len(aSX7[i,1])))
	If SX7->(DbSeek(aSX7[i,1]+cEspaco+aSX7[i,2]))
		If Iif(nPosCdom > 0, Upper(AllTrim(SX7->X7_CDOMIN)) == Upper(AllTrim(aSX7[i,4])), .T.) .And. ;
		   Iif(nPosRegr > 0, Upper(AllTrim(SX7->X7_REGRA))  == Upper(AllTrim(aSX7[i,3])), .T.) .And. ;
		   Iif(nPosAlia > 0, Upper(AllTrim(SX7->X7_ALIAS))  == Upper(AllTrim(aSX7[i,7])), .T.) .And. ;
		   Iif(nPosOrdm > 0, Upper((AllTrim(AllToChar(SX7->X7_ORDEM)))) == Upper(AllTrim(AllToChar(aSX7[i,8]))), .T.) .And. ;
		   Iif(nPosChav > 0, Upper(AllTrim(SX7->X7_CHAVE))  == Upper(AllTrim(aSX7[i,9])), .T.) .And. ;
		   Iif(nPosCond > 0, Upper(AllTrim(SX7->X7_CONDIC)) == Upper(AllTrim(aSX7[i,10])), .T.)

			lGravaSX7 := .F.
		Endif

		If ( Len(aSX7[i] ) >= Len(aSX7Estr) )
			//-- Se existir a coluna de atualizacao no array aSX7Est e se no array de parametros existir
			//-- a instrucao de exclusão do parametro força a exclusão do registro desde que atenda as
			//-- condições definidas no array aSX7.
			If( nPosDel > 0 ) .and. aSX7[i, nPosDel ] == "__lApaga"
				lApaga := .T.
			Else
				lApaga := .F.
			Endif
		Endif

	Else
		If( nPosDel > 0 ) .and. aSX7[i, nPosDel ] == "__lApaga" // Não achou e é para apagar
			lGravaSX7 := .F.
		EndIf
		
		If lGravaSX7 .And. ( nPosNCria > 0 ) .And. aSX7[i, nPosNCria ] == "__lNaoCria" // Não achou e não pode criar o novo registro
			lGravaSX7 := .F.
		EndIf
		lNovo := .T.
	Endif

	If lApaga
		If !lGravaSX7 // Encontrou o registro para excluir
			RecLock("SX7", .F.)
			SX7->(DbDelete())
			SX7->(MsUnLock())
			SX7->(dbCommit())
		EndIf
	Else
		If lGravaSX7 // Verifica se não encontrou o registro
			lSX7 := .T.
			RecLock("SX7", lNovo)
			For j:=1 To Len(aSX7[i])
				If FieldPos(aSX7Estr[j])>0
					FieldPut(FieldPos(aSX7Estr[j]),aSX7[i,j])
				EndIf
			Next j

			SX7->(MsUnLock())
			SX7->(dbCommit())
		Endif
	EndIf

Next i

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuOrdem
Libera a ordem dos campos das tabelas passadas como parametro e atualiza a ordem no SX3.
Funcao como base da versao 11 - JurcOrdem

@author Rafael Tenorio da Costa
@since 27/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuOrdem(cTabela, nOrdem, cCampo)
Local aArea		:= GetArea()
Local aSX3Area	:= SX3->( GetArea() )
Local aOrdem	:= {}
Local aSX3Estr	:= {"X3_ARQUIVO", "X3_CAMPO", "X3_ORDEM"}
Local aCampos	:= {}
Local nOldOrder	:= 0
Local nPasso	:= 0
Local aCpo      := {}
Local nX        := 0
Local cNewOrder := ""
Local nQtdCpos  := 0

	SX3->( DbSetOrder(2) )	//X3_CAMPO
	If SX3->( DbSeek( cCampo ) )

		//Carrega todos os campos da tabela
		SX3->( DbSetOrder(1) )	//X3_ARQUIVO + X3_ORDEM
		SX3->( DbSeek( cTabela ) )
		Do While SX3->( ! EoF() ) .And. SX3->X3_ARQUIVO == cTabela

			Aadd(aCampos, {SX3->X3_CAMPO, SX3->X3_ORDEM} )
			SX3->( DbSkip() )
		End Do

		//Acerta todas as ordens caso tenha pulado alguma ou tenha ordem iguais
		For nX:= 1 To Len(aCampos)

			cNewOrder := RetAsc(Str(nX),2,.T.)

			If cNewOrder <> aCampos[nX][2]

				SX3->( DbSetOrder(2) )	//X3_CAMPO
				If SX3->( DbSeek( aCampos[nX][1] ) )

					RecLock("SX3", .F.)
					SX3->X3_ORDEM	:= cNewOrder
					aCampos[nX][2]	:= cNewOrder
					SX3->( MsUnLock() )
				EndIf
			EndIf
		Next nX

		//Pega ordem atual do campo na base
		SX3->( DbSetOrder(2) )	//X3_CAMPO
		If SX3->( DbSeek( cCampo ) )
			nOldOrder   := Val( RetAsc(SX3->X3_ORDEM, 2, .F.) )
			nPasso      := IIF(nOrdem > nOldOrder, 1, -1)
			If nOldOrder <= Len(aCampos)
				aCpo    := aClone( aCampos[nOldOrder] )
			Else
				nOldOrder := nOrdem + 2
			EndIf
		EndIf

		//Carrega novas ordens
		nQtdCpos := Len(aCampos)
		For nX := nOldOrder To nOrdem Step nPasso

			cNewOrder := RetAsc(Str(nX),2,.T.)

			If nX == nOrdem	.And. nX <= nQtdCpos .And. nX >= 1
				aCampos[nX]   := aClone(aCpo)
				aCampos[nX,2] := cNewOrder
			Else
				If nX+nPasso <= nQtdCpos  .And. nX+nPasso >= 1
					aCampos[nX] := aClone(aCampos[nX+nPasso])
					aCampos[nX,2] := cNewOrder
				EndIf
			EndIf

			//Novas ordens
			If nX <= nQtdCpos .And. nX >= 1
				AAdd(aOrdem, {cTabela, aCampos[nX][1], aCampos[nX][2]} )
			EndIf
		Next nX

		If Len( aOrdem ) > 0

			//Ordena array
			aOrdem := aSort(aOrdem,,,{|x,y| x[3] < y[3] })

			//Reposiciona os campos
			AtuSX3(aOrdem, aSX3Estr, {})
		EndIf

	EndIf

	RestArea(aSX3Area)
	RestArea(aArea)

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} AtuSX5
Função de processamento da gravação do SX5 - Tabelas Genéricas

@author Jorge Martins
@since  24/09/2018
/*/
//--------------------------------------------------------------------
//Static Function AtuSX5(aSX5)
//Local aEstrut   := {}
//Local nI        := 0
//Local nJ        := 0
//Local lInclui   := 0
//Local nTamFil   := Len( SX5->X5_FILIAL )
//
//Default aSX5 := {}
//
//aEstrut := { "X5_FILIAL", "X5_TABELA", "X5_CHAVE", "X5_DESCRI", "X5_DESCSPA", "X5_DESCENG" }
//
//dbSelectArea( "SX5" )
//SX5->( dbSetOrder( 1 ) )
//
//For nI := 1 To Len( aSX5 )
//
//	lInclui = !SX5->( dbSeek( PadR( aSX5[nI][1], nTamFil ) + aSX5[nI][2] + aSX5[nI][3] ) )
//	RecLock( "SX5", lInclui )
//
//	For nJ := 1 To Len( aSX5[nI] )
//		If FieldPos( aEstrut[nJ] ) > 0
//			FieldPut( FieldPos( aEstrut[nJ] ), aSX5[nI][nJ] )
//		EndIf
//	Next nJ
//
//	SX5->( MsUnLock() )
//
//Next nI
//
//Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} AtuSX6
Função para alteração do SX6 - Parâmetros

@param aSX6      Array com alterações do arquivo SX6
@param aSX6Estr  Array com os campos da estrutura do arquivo SX6

@author Jorge Martins
@since  26/09/2018
@version 1.0
/*/
//--------------------------------------------------------------------
//Static Function AtuSX6(aSX6, aSX6Estr)
//Local nI         := 0
//Local nJ         := 0
//Local nTamFil    := Len( SX6->X6_FIL )
//Local nTamVar    := Len( SX6->X6_VAR )
//
//Default aSX6     := {}
//Default aSX6Estr := {}
//
//// Atualizando dicionário
//dbSelectArea( "SX6" )
//dbSetOrder( 1 )
//
//If Len(aSX6) > 0 .And. Len(aSX6Estr) > 0
//
//	For nI := 1 To Len( aSX6 )
//
//		If SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
//			RecLock( "SX6", .F. )
//			For nJ := 1 To Len( aSX6[nI] )
//				If FieldPos( aSX6Estr[nJ] ) > 0
//					FieldPut( FieldPos( aSX6Estr[nJ] ), aSX6[nI][nJ] )
//				EndIf
//			Next nJ
//
//			SX6->( MsUnLock() )
//			dbCommit()
//
//		EndIf
//
//	Next nI
//
//EndIf
//
//Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} UPDPFS()
Função para executar a atualização do RUPPFS fora do release incremental.

@Author Luciano Pereira dos Santos
@since 17/01/2019
@version P12
/*/
//-------------------------------------------------------------------
Main Function UPDPFS()
	Local oModal     := FWDialogModal():New()
	Local aTFolder   := {STR0015, STR0016} //#"Compatibilizador" ##"Selecionar Empresas"
	Local aEmp       := RupGetEmp()
	Local oMarkNo    := LoadBitmap( GetResources(), "LBNO" )
	Local oMarkOk    := LoadBitmap( GetResources(), "LBOK" )
	Local cRelStart  := "12.1.014" //"Release inicial"
	Local cRelFinish := GetRpoRelease()
	Local cMemo      := ""
	Local oMemoTermo := Nil
	Local oAceite    := Nil
	Local lAceite    := .F.
	Local oAjuBrw    := Nil
	Local oListbox   := Nil

	oModal:SetFreeArea(300, 150)
	oModal:SetEscClose(.T.)
	oModal:SetTitle(STR0014) //"Compatibilizador de releases - SIGAPFS"
	oModal:CreateDialog()
	oModal:addOkButton({|| Iif(lAceite, (RupProc(aEmp, cRelStart, cRelFinish), oModal:oOwner:End()), ApMsgStop(STR0017, STR0015 )) }) //# "É necessário confirmar a realização dos procedimentos antes executar o compatibilizador."  ##"Compatibilizador"
	oModal:addCloseButton()
	oMainPnl := oModal:GetPanelMain()

	oTFolder := TFolder():New( 0, 0, aTFolder, , oMainPnl, , , , .T., , , )
	oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
	oTFolder:bSetOption := ({||})
	oTfolder1 := oTFolder:aDialogs[1]
	oTfolder2 := oTFolder:aDialogs[2]

	//Folder 1
	cMemo := + CRLF
	cMemo += STR0018 + CRLF + CRLF //"Por se tratar de um processo crítico é necessário fazer uma cópia de segurança do diretório de dicionários e demais arquivos locais, bem como da base de dados."
	cMemo += STR0019 + CRLF + CRLF //"Note que a base de dados pode estar armazenada em arquivos locais ou em banco de dados relacional, isto varia de acordo com sua instalação."
	cMemo += STR0020 + CRLF + CRLF //"Verifique se há espaço livre em disco para os arquivos locais e no banco de dados relacional, quando utilizado."
	cMemo += STR0021 + CRLF + CRLF //"A atualização de versão pode interferir em customizações existentes."
	cMemo += STR0022 //"Desta forma, se você possui customizações, é impreterível que você analise o impacto da atualização em suas customizações."
	oMemoTermo := TMultiget():New(010, 010, {| u | If( pCount() > 0, cMemo := u, cMemo ) }, oTfolder1, 279, 100, , , , , , .T., , , , , , .T., , , , , .T.)
	oAceite := TCheckBox():New(115, 010, STR0029, {|u| If(PCount() > 0, lAceite := u, lAceite)}, oTfolder1, 200, 008, , , , , , , ,.T., , , , ) // "Verifiquei os procedimentos antes de executar o compatibilizador."
	oAjuBrw := TCheckBox():New(125, 010, STR0034 + " - " + STR0033, {|u| If(PCount() > 0, _lAjuBrw := u, _lAjuBrw)}, oTfolder1, 300, 008, , , , , , , ,.T., , , , ) // "(Opcional)" - "Deseja ajustar a flag de browse dos campos (X3_BROWSE) para o valor padrão?"

	@ 121, 250 BUTTON STR0035 SIZE 030, 017 /*FONT oFont*/ PIXEL OF oTfolder1 ACTION (Info()) // "Mais info..."

	//Folder 2
	@ 10, 10 Listbox oListbox /*Var cVar*/ Fields Header " ", STR0023, STR0024 Size 279, 100 Of oTfolder2 Pixel //#"Código" ## "Grupo de Empresa"
	oListbox:SetArray(aEmp[1])
	oListbox:bLine := {|| {IIf( aEmp[1][oListbox:nAt, 1], oMarkOk, oMarkNo ), ;
	aEmp[1][oListbox:nAt, 2], ;
	aEmp[1][oListbox:nAt, 3]}}
	oListbox:BlDblClick   := { || aEmp[1][oListbox:nAt, 1] := !aEmp[1][oListbox:nAt, 1], oListbox:Refresh()}
	oListbox:BHeaderClick := { || aEval(aEmp[1], {|a, n| aEmp[1][n, 1] := !aEmp[1][n,1]}), oListbox:Refresh() }
	oListbox:cToolTip     := oModal:cTitle
	oListbox:lHScroll     := .F. // NoScroll

	oModal:Activate()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Info
Apresenta o link do TDN quanto aos ajustes de browse.

@author  Cristina Cintra
@since   23/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Info()
	
	ShellExecute( "Open", "http://tdn.totvs.com/x/YLltHg", "", "C:\", 1 )
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RupGetEmp()
Função para retonar o grupo de empresas e filiais do sistema.

@Return aEmp    Array com as informaçoes das SM0

@Author Luciano Pereira dos Santos
@since 17/01/2019
@version P12
/*/
//-------------------------------------------------------------------
Static function RupGetEmp()
	Local aEmp     := {}
	Local aSM0     := {}
	Local nI       := 0
	Local cEmpAux  := ""
	Local aMarcEmp := {}
	Local aProcEmp := {}

	OpenSm0()
	aSM0 := FWLoadSM0(.T., .F.)

	For nI := 1 To Len(aSM0)
		If cEmpAux != aSM0[nI][1]
			Aadd(aMarcEmp, {.T., aSM0[nI][1], aSM0[nI][6]})
			cEmpAux := aSM0[nI][1]
		EndIf
		Aadd(aProcEmp, {aSM0[nI][1], aSM0[nI][2]})
	Next nI

	aEmp := {aClone(aMarcEmp), aClone(aProcEmp)}
	JurFreeArr(@aMarcEmp)
	JurFreeArr(@aProcEmp)

Return aEmp

//-------------------------------------------------------------------
/*/{Protheus.doc} RupSetcEmp(aEmp, cMsgEmp)
Função para retonar as empresas selecionadas para executar o Rup.

@Param aEmp      Array gerado pela rotina RupGetEmp()
@Param cMsgEmp   Mensagem com as empresas selecionada sem dicionário
                 carregado, passado por referencia

@Return aEmpRup  Array com as empresas selecionadas

@Author Luciano Pereira dos Santos
@since 17/01/2019
@version P12
/*/
//-------------------------------------------------------------------
Static function RupSetcEmp(aEmp, cMsgEmp)
	Local aEmpRup   := {}
	Local aEmpMark  := aEmp[1]
	Local aEmpAll   := aEmp[2]
	Local nI        := 0
	Local aEmpMsg   := {}

	Default cMsgEmp := ""

	For nI := 1 To Len(aEmpAll)
		If aScan(aEmpMark, {|x| x[1] .And. x[2] == aEmpAll[nI][1]}) > 0
			If MpDicInDb() .Or. RpcChkSxs(aEmpAll[nI][1], @aEmpMsg, .F.)
				aAdd(aEmpRup, aClone(aEmpAll[nI]))
			EndIf
		EndIf
	Next nI

	Aeval(aEmpMsg, {|x| cMsgEmp += I18N(STR0025 + CRLF, {x[1]})} ) //"A Empresa '#1' não tem dados para serem compatibilizados."
	JurFreeArr(@aEmpAll)

Return aEmpRup

//-------------------------------------------------------------------
/*/{Protheus.doc} RupProc()
Função para retonar o grupo de empresas e filiais do sistema.

@Return aEmp    Array com as informaçoes das SM0

@Author Luciano Pereira dos Santos
@since 17/01/2019
@version P12
/*/
//-------------------------------------------------------------------
Static function RupProc(aEmp, cRelStart, cRelFinish)
	Local lRet      := .T.
	Local cEmpMsg   := ""
	Local aEmpresas := RupSetcEmp(aEmp, @cEmpMsg)
	Local cRelIni   := SubStr(cRelStart, rat('.', cRelStart) + 1)
	Local cRelFin   := SubStr(cRelFinish, rat('.', cRelFinish) + 1)

	FWMsgRun(, {|| lRet := RupProcRun(aEmpresas, cRelIni, cRelFin) }, STR0015, STR0026) //"Compatibilizando as empresas selecionadas..."

	If lRet
		ApMsgInfo(cEmpMsg + CRLF + STR0027, STR0015) //# "Compatibilizador finalizado com sucesso." ## "Compatibilizador"
	Else
		ApMsgStop(cEmpMsg + CRLF + STR0028, STR0015) //# "Compatibilizador finalizado com erro." ## "Compatibilizador"
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RupProcRun()
Rotina de abertura de ambiente e execução do Rup por empresa e filial.

@Return aEmpresas   Array com as informaçoes das empresas
@param  cRelStart   Release de partida Ex: 014
@param  cRelFinish  Release de chegada Ex: 017

@Author Luciano Pereira dos Santos
@since 17/01/2019
@version P12
/*/
//-------------------------------------------------------------------
Static function RupProcRun(aEmpresas, cRelStart, cRelFinish)
	Local lRet     := .T.
	Local cEmpOld  := ""
	Local cEmpAux  := ""
	Local cFilAux  := ""
	Local nI       := 0
	Local nP       := 0

	Private __CINTERNET := Nil // Habilita mensagens em tela após a preparação de ambiente

	For nI := 1 To Len(aEmpresas)
		cEmpAux  := aEmpresas[nI][1]
		cFilAux  := aEmpresas[nI][2]

		If cEmpOld != cEmpAux // Monta ambiente com nova empresa
			cEmpOld := cEmpAux
			RPCSetType(3)
			lRet := RpcSetEnv(cEmpAux, cFilAux, /*cEnvUser*/, /*cEnvPass*/, "PFS", /*cFunName*/ "RUP_PFS", /*aTables*/, /*lShowFinal*/, /*lAbend*/,  /*lOpenSX*/ .T., /*lConnect*/.T.)
			__CINTERNET := Nil
		Else
			cFilAnt := cFilAux // Troca filial da mesma empresa
		EndIf

		If lRet
			FWMsgRun(, {|| RUP_PFS( , , cRelStart, cRelFinish, )}, STR0015, I18N(STR0031, {"["+cEmpAnt+"]", "["+cFilAnt+"] "})) // "Compatibilizando a empresa: #1 e filial: #2..."
		EndIf

		nP := nI + 1
		If nP <= Len(aEmpresas) .And. aEmpresas[nP][1] != cEmpAux
			RpcClearEnv()
		EndIf
	Next nI

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurOpenSX5()
Rotina de abertura de tabela genérica do ambiente.

@Return lRet  .T. Se a tabela genérica foi aberta.

@Author Luciano Pereira dos Santos
@since 30/01/2019
@version P12
/*/
//-------------------------------------------------------------------
//Static function JurOpenSX5()
//Local lRet   := .F.
//Local cQuery := ""
//
//Private cQAlias := "SX5"
//
//If Select(cQAlias) == 0
//	cQuery := " SELECT * FROM " + RetSqlName(cQAlias) + " "
//	cQuery += " WHERE X5_FILIAL = '" + xFilial(cQAlias) + "' "
//	cQuery += " AND D_E_L_E_T_ = ' ' "
//	DbUseArea(.T.,"TOPCONN", TcGenQry( , , cQuery), cQAlias, .T., .F.)
//	lRet := Select(cQAlias) > 0
//Else
//	lRet := .T.
//EndIf
//
//Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS8082
Preencher campo do Tarifador x Lançamentos financeiros

@author Jonatas Martins
@since  30/05/2019
@Obs    DJURFAT1-8082
/*/
//-------------------------------------------------------------------
Static Function JURPFS8082()
	
	If !_lExecutou .AND. JColumnPos("NVE_DBTPES") > 0
		TCSqlExec("UPDATE " + RetSqlName("NVE") + " SET NVE_DBTPES = '2' WHERE NVE_DBTPES = ' ' AND D_E_L_E_T_ = ' '")
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS9069
Transfere a informação da configuração do taridador para o grid 'Configurações por tipo de despesa'

@author Abner Fogaça de Oliveira
@since  18/06/2019
@Obs    DJURFAT1-9069
/*/
//-------------------------------------------------------------------
Static Function JURPFS9069()
Local aDados  := {}
Local cQuery  := ""
Local nI      := 0
Local cFilNYV := xFilial('NYV')
Local cFilNYT := xFilial("NYT")

cQuery := " SELECT NYT_COD, NYT_IDPART "
cQuery +=   " FROM " + RetSqlName("NYT")
cQuery +=  " WHERE NYT_FILIAL = '" + cFilNYT + "' "
cQuery +=    " AND D_E_L_E_T_ = ' ' "

aDados := JurSQL(cQuery, {"NYT_COD", "NYT_IDPART"})

If !Empty(aDados)
	NYV->(DbSetOrder(1)) // NYV_FILIAL+NYV_CODCFG+NYV_TIPO
	For nI := 1 To Len(aDados)
		If NYV->(Dbseek(cFilNYV + aDados[nI][1]))
			While !NYV->(EOF()) .And. NYV->NYV_CODCFG == aDados[nI][1] .And. NYV->NYV_FILIAL == cFilNYV
				If Empty(NYV->NYV_IDPART)
					RecLock("NYV", .F.)
					NYV->NYV_IDPART := aDados[nI][2]
					NYV->(MsUnlock())
					NYV->(DbCommit())
				EndIf
				NYV->(DbSkip())
			EndDo
		EndIf
	Next

EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS9110
Preencher campo do Status nos registros antigos do Tarifador.

O Status para registros antigos deve ser 5=Despesa Gerada

@author Jorge Martins
@since  21/06/2019
@Obs    DJURFAT1-9110
/*/
//-------------------------------------------------------------------
Static Function JURPFS9110()

	TCSqlExec("UPDATE " + RetSqlName("NYX") + " SET NYX_STATUS = '5' WHERE NYX_STATUS = ' ' AND D_E_L_E_T_ = ' '")

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS9223
Ajusta o X3_F3 do campo NUE_CTAREF

@author Bruno Ritter / Anderson Carvalho
@since  24/06/2019
@Obs    DJURFAT1-9223
        - Foi criado esse ajuste, pois o campo NUE_CTAREF não podia ser alterado na SX3
        devido o pacote 006463 da issue DJURFAT1-8103 - Validações nas regras do modelo JURA202
        - Quando for possível, é importante ajustar o atusx para o campo NUE_CTAREF ficar
        com o campo X3_F3 = NUENRZ
/*/
//-------------------------------------------------------------------
Static Function JURPFS9223()
	Local cSXBTmp   := GetNextAlias()
	Local cF3       := "NUENRZ"
	Local aSX3      := {}
	Local aSX3Old   := {}
	Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_F3"}

	OpenSxs(,,,, cEmpAnt, cSXBTmp, "SXB", , .F.)

	If Select(cSXBTmp) > 0
		(cSXBTmp)->( DbSetOrder(1) )

		If (cSXBTmp)->( DbSeek( cF3 ) )
			Aadd(aSX3   , {"NUE", "NUE_CTAREF", cF3} )
			Aadd(aSX3Old, {"NUE", "NUE_CTAREF", "NRZNUE"} )

			AtuSX3(aSX3, aSX3Estr, aSX3Old)
		EndIf
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS9072()
Ajusta máscara das horas no histórico de participantes

@author  Abner Fogaça de Oliveira
@since   21/06/2019
/*/
//-------------------------------------------------------------------
Static Function JURPFS9072()
Local aSX3     := {}
Local aSX3Old  := {}
Local aSX3Estr := {}

aSX3Estr := {"X3_ARQUIVO", "X3_CAMPO", "X3_PICTURE"}

Aadd(aSX3, {"NUR", "NUR_HRDIAD", "@R 99:99"})
Aadd(aSX3, {"NUR", "NUR_HRDIAB", "@R 99:99"})
Aadd(aSX3, {"NUS", "NUS_HRDIAD", "@R 99:99"})
Aadd(aSX3, {"NUS", "NUS_HRDIAB", "@R 99:99"})

AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return Nil

//--------------------------------------------------------------------------
/*/{Protheus.doc} JRUP202
Função para encapsular as alterações feitas no pacote (006364) de ajustes 
da JURA202 issue  DJURFAT1-8103.

@author Jonatas Martins
@since  14/08/2019
/*/
//---------------------------------------------------------------------------
Static Function JRUP202()
	Local aSX3     := {}
	Local aSX3Old  := {}
	Local aSX3Estr := {}

	//----------------------------------------
	// DJURFAT1-8543 - AçãoLD nos Lançamentos
	//----------------------------------------
	If JChkfile("NUE")
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_CBOX" ,"X3_CBOXSPA","X3_CBOXENG", "X3_VALID"}
		Aadd(aSX3, {"NUE", "NUE_ACAOLD", "1=Retirar;2=Transferir;3=WO;4=Lançamento indevido;5=Transferir e retirar;6=Vincular",;
		                                 "1=Retirar;2=Transferir;3=WO;4=Asiento indebido;5=Transferir y retirar;6=Vincular",;
		                                 "1=Pick up;2=Transfer;3=WO;4=Improper entry;5=Transfer and pick up;6=Link",;
		                                 "Vazio().Or.Pertence('123456')"} )
		/*Forço o ajuste do valid pois no ATUSX foi feito num pacote que ainda não sabemos quando será liberado*/
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

	If JChkfile("NVY")
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_CBOX" ,"X3_CBOXSPA","X3_CBOXENG", "X3_VALID"}
		Aadd(aSX3, {"NVY", "NVY_ACAOLD", "1=Retirar;2=Transferir;3=WO;4=Lançamento indevido;5=Transferir e retirar;6=Vincular",;
		                                 "1=Retirar;2=Transferir;3=WO;4=Asiento indebido;5=Transferir y retirar;6=Vincular",;
		                                 "1=Pick up;2=Transfer;3=WO;4=Improper entry;5=Transfer and pick up;6=Link",;
		                                 "Vazio().Or.Pertence('123456')"} )
		/*Forço o ajuste do valid pois no ATUSX foi feito num pacote que ainda não sabemos quando será liberado*/
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

	If JChkfile("NV4")
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_CBOX" ,"X3_CBOXSPA","X3_CBOXENG", "X3_VALID"}
		Aadd(aSX3, {"NV4", "NV4_ACAOLD", "1=Retirar;2=Transferir;3=WO;4=Lançamento indevido;5=Transferir e retirar;6=Vincular",;
		                                 "1=Retirar;2=Transferir;3=WO;4=Asiento indebido;5=Transferir y retirar;6=Vincular",;
		                                 "1=Pick up;2=Transfer;3=WO;4=Improper entry;5=Transfer and pick up;6=Link",;
		                                 "Vazio().Or.Pertence('123456')"} )
		/*Forço o ajuste do valid pois no ATUSX foi feito num pacote que ainda não sabemos quando será liberado*/
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

	//---------------------------------------------
	// DJURFAT1-9223 - Lentidão na Consulta NRZNUE
	//---------------------------------------------
	If JChkfile("NUE")
		// Ajusta o X3_F3 do campo NUE_CTAREF
		JURPFS9223()
	EndIf

	//---------------------------------------------------------------------------------------------------
	// DJURFAT1-9682 - Junção de contratos fixos para mesmo cliente, loja e caso com multiplos revisores
	//----------------------------------------------------------------------------------------------------
	If JChkfile("OHN")
		JURPFS9682(OHN->(JColumnPos("OHN_CCONTR")) == 0)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS9682
Cria campo de contrato na tabela sócio/revisores (OHN). Ajusta X2_UNICO
e índice incluindo o novo campo de contrato.

@author Jonatas Martins
@since  24/06/2019
@Obs    DJURFAT1-9582 - Ajusta para corrigir error log ao emitir
        a pré-fatura de dois contratos fixos com mesmo cliente, loja
		e caso com sócios/revisores que estão em junção.
		Devido as alterações de dicionário estar no pacote da JURA202 006463
		os ajustes serão feitos via UPDPFS.
/*/
//-------------------------------------------------------------------
Static Function JURPFS9682(lCriaCtt)
	Local aArea     := GetArea()

	Default lCriaCtt := .T. 

	// Cria campo no SX3 e/ou processa alteração de indice e x2_unico
	If OHN->(JColumnPos("OHN_CCONTR")) > 0
		// Atualiza ordem dos campos
		If !_lExecutou
			AtuOrdem("OHN", 3, "OHN_CCONTR")
		EndIf
		
		// Ajusta dados existentes na base
		JPFS9682B() 
	EndIf

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS9682B
Ajusta dados de sócios/revisores (OHN) preenchendo o código do contrato
em registros que possuem vínculo com pré-fatura.

@author Jonatas Martins
@since  24/06/2019
/*/
//-------------------------------------------------------------------
Static Function JPFS9682B()
	Local aAreaOHN  := OHN->(GetArea())
	Local cQueryOHN := ""
	Local cAlsTmp   := GetNextAlias()

	cQueryOHN := "SELECT OHN.R_E_C_N_O_ RECOHN, NX1.NX1_CCONTR CONTRATO "
	cQueryOHN +=   "FROM " + RetSqlName("OHN") + " OHN "
	cQueryOHN +=  "INNER JOIN " + RetSqlName("NX1") + " NX1 "
	cQueryOHN +=     "ON NX1.NX1_FILIAL = '"  + xFilial("NX1") + "' "
	cQueryOHN +=    "AND NX1.NX1_CPREFT = OHN.OHN_CPREFT "
	cQueryOHN +=    "AND NX1.NX1_CCLIEN = OHN.OHN_CCLIEN "
	cQueryOHN +=    "AND NX1.NX1_CLOJA  = OHN.OHN_CLOJA "
	cQueryOHN +=    "AND NX1.NX1_CCASO  = OHN.OHN_CCASO "
	cQueryOHN +=    "AND NX1.D_E_L_E_T_ = ' ' "
	cQueryOHN +=  "WHERE OHN.OHN_FILIAL = '" + xFilial("OHN") + "' "
	cQueryOHN +=    "AND OHN.OHN_CPREFT <> ' ' "
	cQueryOHN +=    "AND OHN.OHN_CCONTR = ' ' "
	cQueryOHN +=    "AND OHN.D_E_L_E_T_ = ' ' "
	cQueryOHN := ChangeQuery(cQueryOHN)

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQueryOHN), cAlsTmp, .T., .T.)

	While (cAlsTmp)->(!EOF())
		OHN->(DbGoTo((cAlsTmp)->RECOHN))

		If OHN->(!EOF())
			RecLock("OHN", .F.)
			OHN->OHN_CCONTR := (cAlsTmp)->CONTRATO
			OHN->(MsUnLock())
		Else
			Exit
		EndIf

		(cAlsTmp)->(DbSkip())
	End

	(cAlsTmp)->(DbCloseArea())
	RestArea(aAreaOHN)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS9713
Ajuste do X3_BROWSE das tabelas NXA, NXC, NX0 e NX1 devido a performance
de abertura e navegação - DJURFAT1-9713.

@author Cristina Cintra
@since  21/08/2019
/*/
//-------------------------------------------------------------------
Static Function JURPFS9713()
Local aAjuBrwNo   := {}
Local aAjuBrwYes  := {}
Local aSX3        := {}
Local aSX3Old     := {}
Local aSX3Estr    := {"X3_ARQUIVO", "X3_CAMPO", "X3_BROWSE"}
Local nI          := 0

If IsBlind() .Or. _lAjuBrw
	aAjuBrwNo := {"NXA_PIRRF", "NXA_PPIS", "NXA_PCOFIN", "NXA_PCSLL", "NXA_PINSS", "NXA_WO", "NXA_DREFIH", "NXA_DREFFH", "NXA_DREFID", "NXA_DREFFD", "NXA_DREFIT", "NXA_DREFFT", ;
	              "NXA_SIGLA", "NXA_CPART", "NXA_DPART", "NXA_OBS", "NXA_TPPAG", "NXA_CGCCPF", "NXA_LOGRAD", "NXA_ENDENT", "NXA_CEP", "NXA_BAIRRO", "NXA_CIDADE", "NXA_ESTADO",  ; 
	              "NXA_PAIS", "NXA_INSEST", "NXA_INSMUN", "NXA_VLFIXH", "NXA_VLORIH", "NXA_VLFIXO", "NXA_VLORID", "NXA_CMOTCA", "NXA_DMOTCA", "NXA_TXTFAT", "NXA_CALDIS", "NXA_VUADIA", ;
	              "NXA_VSADIA", "NXA_EMAIL", "NXA_CRTENV", "NXA_RELENV", "NXA_RECENV", "NXA_MAILEN", "NXA_SIGLA4", "NXA_USRCAN", "NXA_DUSRCA", "NXA_FPAGTO", "NXA_CFATADC", "NXA_CBANCO", ;
	              "NXA_CAGENC", "NXA_CCONTA", "NXA_CESCSU", "NXA_CFTSUB", "NXA_CCONT", "NXA_DCONT", "NXA_CCDPGT", "NXA_DCDPGT", "NXA_TITGER", "NXA_ESCATU", "NXA_FATATU", "NXA_CIDIO", ;
	              "NXA_DIDIO", "NXA_CIDIO2", "NXA_DIDIO2", "NXA_CTPFAT", "NXA_TPREL", "NXA_DTPREL", "NXA_CCARTA", "NXA_DCARTA", "NXA_CTIPOF", "NXA_DTIPOF", "NXA_SIGLA2", "NXA_USUEMI", ;
	              "NXA_DUSUEM", "NXA_SIGLA3", "NXA_USRALT", "NXA_DUSRAL", "NXA_DTALVE", "NXA_STATUS", ; // NXA
	              "NXC_DRATE", "NXC_DRATL", "NXC_DRATP", "NXC_VLTSTB", "NXC_VLHFV", "NXC_VTBVIN", "NXC_REDAC", "NXC_PDESCH", "NXC_VLEXIT", "NXC_VFXVIN", ; // NXC
	              "NX0_TPDESC", "NX0_PDESCH", "NX0_DESCH", "NX0_DESCON", "NX0_PACREH", "NX0_CESCR", "NX0_DESCR", "NX0_SIGLA", "NX0_CPART", "NX0_DPART", "NX0_DFIMTS", "NX0_DINIDP", ;
	              "NX0_DFIMDP", "NX0_DINITB", "NX0_DINITS", "NX0_DFIMTB", "NX0_DINIFX", "NX0_DFIMFX", "NX0_CFTADC", "NX0_CPAREX", "NX0_CCONTA", "NX0_DCONTA", "NX0_SITCB", "NX0_DSITCB", ;
	              "NX0_DTINC", "NX0_DUSUEM", "NX0_TPEMI", "NX0_OBSFAT", "NX0_DTALT", "NX0_CODUSR", "NX0_USUEMI", "NX0_USRALT", "NX0_USRCAN", "NX0_DUSRCA", "NX0_ESCOLD", "NX0_FATOLD", ;
	              "NX0_CIDIO", "NX0_DIDIO", "NX0_RELPRE", "NX0_DRELPR", "NX0_FATURA", "NX0_TPSERV", ; // NX0
	              "NX1_VTBVIN", "NX1_DESP", "NX1_TABREV", "NX1_VFXVIN", "NX1_TS", "NX1_VEXITO", "NX1_DSPREV", "NX1_DMOETH", "NX1_CPAREX", "NX1_CTPREL", "NX1_TSREV", "NX1_DTPREL", ;
	              "NX1_CMOETH", "NX1_PDESCH", "NX1_SIGLA", "NX1_VDESCO", "NX1_PCDESC", "NX1_VLDESC", "NX1_CODEXI", "NX1_LANTAB", "NX1_REDAC", "NX1_VFXFAT", "NX1_VTSTAB", "NX1_VSLDPX", ;
	              "NX1_INSFAT", "NX1_VUTFAT", "NX1_CPART", "NX1_VEXLIM", "NX1_INSREV"} //NX1

	aAjuBrwYes  := {"NX1_VHON", "NX1_VFIXO", "NXC_VFIXO"}
	
	For nI := 1 To Len(aAjuBrwNo)
		Aadd(aSX3, {Substr(aAjuBrwNo[nI], 1, 3), aAjuBrwNo[nI], "N"} )
	Next nI

	For nI := 1 To Len(aAjuBrwYes)
		Aadd(aSX3, {Substr(aAjuBrwNo[nI], 1, 3), aAjuBrwYes[nI], "S"} )
	Next nI
	
	If Len(aSX3) > 0
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS9726
Limpa centro de custo jurídico de naturezas que possuam o tipo de
de conta definido como 1-Banco/Caixa ou 7-Centro de Custo Profissional

@author Jonatas Martins
@since  27/09/2019
/*/
//-------------------------------------------------------------------
Static Function JURPFS9726()
	Local cUpdateSED := ""

	If SuperGetMV("MV_JURXFIN",, .F.)
		cUpdateSED := "UPDATE " + RetSqlName("SED")
		cUpdateSED +=   " SET ED_CCJURI = ' '"
		cUpdateSED += " WHERE ED_TPCOJR = '6'" // 6-Obrigações
		cUpdateSED +=   " AND ED_CCJURI <> ' '"
		cUpdateSED +=   " AND D_E_L_E_T_ = ' '"
		TcSqlExec(cUpdateSED)

		// Ajuste campo de bloqueado da natureza
		cUpdateSED := "UPDATE " + RetSqlName("SED") + " SET ED_MSBLQL = '2' WHERE D_E_L_E_T_ = ' ' AND ED_MSBLQL = ' '"
		TcSqlExec(cUpdateSED)

	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}  CriaMotBx()
Função para criar automaticamente motivo de baixa no cadastro Mot Baixas
(Arquivo SIGAADV.MOT na pasta system)

@param  cMot     - Código do motivo de baixa.
@param  cNomMot  - Nome do motivo da baixa.
@param  cConfMot - Configuração do Motivo da baixa - Composto por 4 letras onde
                   1ª - Carteira do Motivo da Baixa : [R] Receber - [P] Pagar - [A] Ambas
                   2ª - Motivo de Baixa gera movimentação financeira ? [S]im ou [N]ão
                   3ª - Motivo da Baixa gera Comissão ? [S]im ou [N]ão.
                   4ª - Motivo da Baixa gera cheque ? [S]im ou [N]ão.

@return Nil

@author Jorge Martins
@since  28/10/2019
/*/
//-------------------------------------------------------------------
Static Function CriaMotBx(cMot, cNomMot, cConfMot)
	Local lMotBxEsp := .F.
	Local aMotbx    := ReadMotBx(@lMotBxEsp)
	Local nHdlMot   := 0
	Local nI        := 0
	Local cFile     := "SIGAADV.MOT"
	Local nTamLn    := 19
	Local xBuffer   := Nil

	If lMotBxEsp
		nTamLn   := 20
		cConfMot := cConfMot + "N"
	EndIf

	If ExistBlock("FILEMOT")
		cFile := ExecBlock("FILEMOT",.F.,.F.,{cFile})
	Endif

	If Ascan(aMotbx, {|x| Substr(x,1,3) == Upper(cMot)}) < 1
		nHdlMot := FOPEN(cFile, FO_READWRITE)
		If nHdlMot < 0
			HELP(" ",1,"SIGAADV.MOT")
			Final("SIGAADV.MOT")
		EndIf

		nTamArq := FSEEK(nHdlMot,0,2) // Verifica tamanho do arquivo
		FSEEK(nHdlMot,0,0)            // Volta para inicio do arquivo

		For nI := 0 to nTamArq step nTamLn // Processo para ir para o final do arquivo
			xBuffer := Space(nTamLn)
			FREAD(nHdlMot, @xBuffer, nTamLn)
		Next

		fWrite(nHdlMot, cMot + cNomMot + cConfMot + chr(13) + chr(10))
		fClose(nHdlMot)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS8900()
Função para preencher o novo campo NRU_DTFORM.

@author Cristina Cintra
@since  28/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURPFS8900()
Local aArea   := GetArea()
Local cUpdate := ""

cUpdate := " UPDATE " + RetSqlName("NRU")
cUpdate += " SET NRU_DTFORM = '1'"
cUpdate += " WHERE NRU_FILIAL = '" + xFilial("NRU") + "' AND NRU_DTFORM = ' ' AND D_E_L_E_T_ = ' '"
TcSqlExec(cUpdate)

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS9125()
Função para ajustar lançamentos gerados através do LegalDesk.
Os lançamentos antigos eram gerados com OHB_ORIGEM = '5' e OHB_CODLD preenchido.
Novos lançamentos serão gerados com OHB_ORIGEM = '4'.

@author Jorge Martins
@since  19/11/2019
/*/
//-------------------------------------------------------------------
Static Function JURPFS9125()
Local aArea   := GetArea()
Local cUpdate := ""

cUpdate := " UPDATE " + RetSqlName("OHB")
cUpdate +=    " SET OHB_ORIGEM = '4'"
cUpdate +=  " WHERE OHB_FILIAL = '" + xFilial("OHB") + "' AND OHB_ORIGEM = '5' AND OHB_CODLD <> '" + Space(TamSx3('OHB_CODLD')[1]) + "' AND D_E_L_E_T_ = ' '"
TcSqlExec(cUpdate)

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS10547()
Função para deletar registros da NX6 e NX7 que não foram excluídos 
corretamente ao finalizar a fila.

@author Jorge Martins
@since  30/01/2020
/*/
//-------------------------------------------------------------------
Static Function JPFS10547()
	Local cUpdate := ""

	cUpdate := " UPDATE " + RetSqlName("NX6")
	cUpdate +=    " SET D_E_L_E_T_ = '*', "
	cUpdate +=        " R_E_C_D_E_L_ = R_E_C_N_O_ "
	cUpdate +=  " WHERE NX6_FILIAL = '" + xFilial("NX6") + "' "
	cUpdate +=    " AND NOT EXISTS (SELECT 1 "
	cUpdate +=                      " FROM " + RetSqlName("NX5") 
	cUpdate +=                     " WHERE NX5_FILIAL = '" + xFilial("NX5") + "' "
	cUpdate +=                       " AND NX5_COD = NX6_CFILA "
	cUpdate +=                       " AND D_E_L_E_T_ = ' ') "
	cUpdate +=    " AND D_E_L_E_T_ = ' ' "

	TcSqlExec(cUpdate)

	cUpdate := " UPDATE " + RetSqlName("NX7")
	cUpdate +=    " SET D_E_L_E_T_ = '*', "
	cUpdate +=        " R_E_C_D_E_L_ = R_E_C_N_O_ "
	cUpdate +=  " WHERE NX7_FILIAL = '" + xFilial("NX7") + "' "
	cUpdate +=    " AND NOT EXISTS (SELECT 1 "
	cUpdate +=                      " FROM " + RetSqlName("NX5") 
	cUpdate +=                     " WHERE NX5_FILIAL = '" + xFilial("NX5") + "' "
	cUpdate +=                       " AND NX5_COD = NX7_CFILA "
	cUpdate +=                       " AND D_E_L_E_T_ = ' ') "
	cUpdate +=    " AND D_E_L_E_T_ = ' ' "

	TcSqlExec(cUpdate)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AbatOHH()
Ajute na tabela OHH para preencher OHH_ABATIM como o valor de abatimentos
título no contas a receber (SE1)

@author Bruno Ritter
@since 17/02/2020
/*/
//-------------------------------------------------------------------
Static Function AbatOHH()
	Local cQryOHH    := ""
	Local cAliasOHH  := ""
	Local aArea      := GetArea()
	Local cSeekOHH   := ""
	Local cTitulo    := ""
	Local nSomaAbat  := 0
	Local cTituloOld := ""

	DbSelectArea("SE1")

	cQryOHH := "SELECT SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, OHH.OHH_NUM, OHH_JURFAT "
	cQryOHH += "       , SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_EMISSAO, SE1.R_E_C_N_O_ RECSE1 "
	cQryOHH += "       , OHH.OHH_VALOR, OHH.R_E_C_N_O_, OHH.OHH_ANOMES, OHH.OHH_PARCEL, OHH.OHH_SALDO, OHH.OHH_SALDOD, OHH.OHH_SALDOH, OHH.OHH_VLFATD, OHH.OHH_VLFATH"
	cQryOHH +=  " FROM "+RetSqlName("OHH")+" OHH "
	cQryOHH += " INNER JOIN "+RetSqlName("SE1")+" SE1 "
	cQryOHH +=    " ON OHH.OHH_FILIAL = SE1.E1_FILIAL "
	cQryOHH +=   " AND OHH.OHH_PREFIX = SE1.E1_PREFIXO "
	cQryOHH +=   " AND OHH.OHH_NUM = SE1.E1_NUM "
	cQryOHH +=   " AND OHH.OHH_PARCEL = SE1.E1_PARCELA "
	cQryOHH +=   " AND OHH.OHH_TIPO = SE1.E1_TIPO "
	cQryOHH +=   " AND OHH.OHH_ABATIM = 0 "
	cQryOHH +=   " AND OHH.D_E_L_E_T_ = ' ' "
	cQryOHH += " WHERE SE1.D_E_L_E_T_ = ' ' "
	cQryOHH +=   " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
	cQryOHH +=   " AND SE1.E1_SALDO > 0 "
	cQryOHH += " ORDER BY SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_EMISSAO"

	cAliasOHH := GetNextAlias()
	cQryOHH   := ChangeQuery(cQryOHH)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryOHH),cAliasOHH,.T.,.T.)

	OHH->(DBSetOrder(1)) // OHH_FILIAL+OHH_PREFIX+OHH_NUM+OHH_PARCEL+OHH_TIPO+OHH_ANOMES

	While !(cAliasOHH)->(EOF())

		cSeekOHH   := (cAliasOHH)->E1_FILIAL + (cAliasOHH)->E1_PREFIXO + (cAliasOHH)->E1_NUM +;
		              (cAliasOHH)->E1_PARCELA + (cAliasOHH)->E1_TIPO + (cAliasOHH)->OHH_ANOMES
		cTitulo    := (cAliasOHH)->E1_FILIAL + (cAliasOHH)->E1_PREFIXO + (cAliasOHH)->E1_NUM +;
		              (cAliasOHH)->E1_PARCELA + (cAliasOHH)->E1_TIPO + (cAliasOHH)->E1_CLIENTE +;
		              (cAliasOHH)->E1_LOJA + (cAliasOHH)->E1_EMISSAO

		If (cTitulo != cTituloOld)
			SE1->(DbGoTo((cAliasOHH)->RECSE1))
			nSomaAbat := SomaAbat((cAliasOHH)->E1_PREFIXO,;
			                     (cAliasOHH)->E1_NUM,;
			                     (cAliasOHH)->E1_PARCELA,;
			                     "R", 1,,;
			                     (cAliasOHH)->E1_CLIENTE,;
			                     (cAliasOHH)->E1_LOJA,;
			                     (cAliasOHH)->E1_FILIAL,;
			                     StoD((cAliasOHH)->E1_EMISSAO),;
			                     (cAliasOHH)->E1_TIPO)
		EndIf

		If nSomaAbat > 0 .And. OHH->(DbSeek(cSeekOHH))
			RecLock("OHH",.F.)
			OHH->OHH_ABATIM := nSomaAbat
			OHH->(MsUnLock())

			//Grava na fila de sincronização a alteração
			J170GRAVA("OHH", (cAliasOHH)->E1_FILIAL+;
			                 (cAliasOHH)->E1_PREFIXO+;
			                 (cAliasOHH)->E1_NUM+;
			                 (cAliasOHH)->E1_PARCELA +;
			                 (cAliasOHH)->E1_TIPO+;
			                 (cAliasOHH)->OHH_ANOMES, "4")
		EndIf

		cTituloOld := cTitulo
		(cAliasOHH)->(DbSkip())
	End Do

	If Select(cAliasOHH) > 0
		(cAliasOHH)->(DbCloseArea())
	EndIf

	RestArea(aArea)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS10442
Atualiza campo de arquivo e-billing gerado na fatura

@author Jonatas Martins
@since  07/04/2020
/*/
//-------------------------------------------------------------------
Static Function JPFS10442()
	Local cUpdate := ""

	cUpdate := "UPDATE " + RetSqlName("NXA") + " SET NXA_ARQEBI = '2' "
	cUpdate += "WHERE NXA_ARQEBI = ' ' AND D_E_L_E_T_ = ' '"

	TcSqlExec(cUpdate)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS10452
Preenche o novo campo NUH_AGRUPA com 2=Não.

@author Cristina Cintra
@since  07/04/2020
@Obs    DJURFAT1-10452
/*/
//-------------------------------------------------------------------
Static Function JURPFS10452()
Local aArea   := GetArea()

TCSqlExec("UPDATE " + RetSqlName("NUH") + " SET NUH_AGRUPA = '2' WHERE NUH_AGRUPA = ' ' AND D_E_L_E_T_ = ' '")

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS10654
Preenche os novos campos NUH_CORFAT e NXA_CORFAT com 2=Não.

@author fabiana.silva
@since  07/04/2020
@Obs    DJURFAT1-10654
/*/
//-------------------------------------------------------------------
Static Function JPFS10654()
Local aArea   := GetArea()

TCSqlExec("UPDATE " + RetSqlName("NUH") + " SET NUH_CORFAT = '2' WHERE NUH_CORFAT = ' ' AND D_E_L_E_T_ = ' ' ")

TCSqlExec("UPDATE " + RetSqlName("NXA") + " SET NXA_CORFAT = '2' WHERE NXA_CORFAT = ' ' AND D_E_L_E_T_ = ' ' ")

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS10444
Preenche os novos campos de Tipo de Desconto (_TPDESC) com 1=Fixo.

@author Jorge Martins
@since  22/04/2020
@Obs    DJURFAT1-10444
/*/
//-------------------------------------------------------------------
Static Function JPFS10444()
Local aArea   := GetArea()

TCSqlExec("UPDATE " + RetSqlName("NUH") + " SET NUH_TPDESC = '1' WHERE NUH_TPDESC = ' ' AND D_E_L_E_T_ = ' '")
TCSqlExec("UPDATE " + RetSqlName("NXP") + " SET NXP_TPDESC = '1' WHERE NXP_TPDESC = ' ' AND D_E_L_E_T_ = ' '")
TCSqlExec("UPDATE " + RetSqlName("NXG") + " SET NXG_TPDESC = '1' WHERE NXG_TPDESC = ' ' AND D_E_L_E_T_ = ' '")
TCSqlExec("UPDATE " + RetSqlName("NXA") + " SET NXA_TPDESC = '1' WHERE NXA_TPDESC = ' ' AND D_E_L_E_T_ = ' '")

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS11033
Efetiva a gravação na tabela OHT (Faturas x Títulos) com base nos 
títulos e faturas existentes.

@author Abner Fogaça
@since  22/04/2020
/*/
//-------------------------------------------------------------------
Static Function JPFS11033()
Local aArea     := GetArea()
Local cAlsOHT   := GetNextAlias()
Local cAlsTmp   := Nil
Local nRecnoFat := 0
Local aChaveTit := {}
Local lRet      := .F.
	
	BeginSql Alias cAlsOHT
		SELECT COUNT(R_E_C_N_O_) TOTAL
		FROM %Table:OHT%
		WHERE %NotDel%
	EndSql

	If (cAlsOHT)->TOTAL == 0
		cAlsTmp := GetNextAlias()
		BeginSql Alias cAlsTmp
			SELECT NXA.R_E_C_N_O_ RECNONXA,
			       SE1.E1_FILIAL,
			       SE1.E1_PREFIXO,
			       SE1.E1_NUM,
			       SE1.E1_PARCELA,
			       SE1.E1_TIPO,
			       SE1.E1_CLIENTE,
			       SE1.E1_LOJA,
			       SE1.E1_EMISSAO
			  FROM %table:NXA% NXA
			 INNER JOIN %table:NS7% NS7
			    ON NS7.%notDel%
			   AND NS7.NS7_FILIAL = %xfilial:NS7%
			   AND NS7.NS7_COD = NXA_CESCR
			   AND NS7.%notDel%
			 INNER JOIN %table:SE1% SE1
			    ON SE1.%notDel%
			   AND SE1.E1_FILIAL = NS7.NS7_CFILIA
			   AND SE1.E1_JURFAT = NXA.NXA_FILIAL || '-' || NXA.NXA_CESCR || '-' || NXA.NXA_COD || '-' || NS7.NS7_CFILIA
			   AND SE1.E1_NUMLIQ = %exp:Space(TamSX3('E1_NUMLIQ')[1])%
			   AND SE1.E1_ORIGEM = 'JURA203'
			 WHERE NXA.NXA_FILIAL = %xfilial:NXA%
			   AND NXA.%notDel%
			   AND NXA.NXA_SITUAC = '1'
			   AND NXA.NXA_TIPO = 'FT'
			 ORDER BY SE1.E1_JURFAT
		EndSql

		OHT->(DbSetOrder(2)) // OHT_FILIAL + OHT_FILTIT + OHT_PREFIX + OHT_TITNUM + OHT_TITPAR + OHT_TITTPO

		lRet := (cAlsTmp)->(!Eof())

		BEGIN TRANSACTION
			While (cAlsTmp)->(!Eof())

				nRecnoFat := (cAlsTmp)->RECNONXA

				While (cAlsTmp)->(!Eof()) .And. nRecnoFat == (cAlsTmp)->RECNONXA
				
					aAdd(aChaveTit, (cAlsTmp)->E1_FILIAL + (cAlsTmp)->E1_PREFIXO + ;
					                (cAlsTmp)->E1_NUM + (cAlsTmp)->E1_PARCELA + (cAlsTmp)->E1_TIPO)

					(cAlsTmp)->(DbSkip())
				End

				JurTitFat(aChaveTit, nRecnoFat)
				JurFreeArr(@aChaveTit)
			End

		END TRANSACTION

		(cAlsTmp)->(DbCloseArea())
	EndIf
	
	(cAlsOHT)->(DbCloseArea())
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JLIQ11033
Efetiva a gravação na tabela OHT (Faturas x Títulos) com base nas 
liquidações (FO0).

@author Cristina Cintra
@since  25/04/2020
/*/
//-------------------------------------------------------------------
Static Function JLIQ11033()
Local aArea      := GetArea()
Local cAlsTmp    := GetNextAlias()

BeginSql Alias cAlsTmp
	SELECT FO0.FO0_FILIAL,
			FO0.FO0_NUMLIQ,
			FO0.FO0_CLIENT,
			FO0.FO0_LOJA,
			FO0.FO0_PROCES,
			FO0.FO0_VERSAO
		FROM %table:FO0% FO0
		WHERE FO0.FO0_FILIAL = %xfilial:FO0%
		AND FO0.%notDel%
		AND FO0.FO0_STATUS = '4'
	   AND NOT EXISTS (SELECT 1 
	                     FROM %table:OHT% OHT
	                    WHERE OHT.OHT_FILIAL = %xfilial:OHT%
	                      AND OHT.OHT_NUMLIQ = FO0.FO0_NUMLIQ
	                      AND OHT.%notDel%)
EndSql

Begin Transaction
	While (cAlsTmp)->(!Eof())
		JurGrvOHT((cAlsTmp)->FO0_FILIAL, (cAlsTmp)->FO0_NUMLIQ, (cAlsTmp)->FO0_CLIENT, (cAlsTmp)->FO0_LOJA)
		(cAlsTmp)->(DbSkip())
	EndDo
End Transaction

(cAlsTmp)->(DbCloseArea())
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuNXMTPAR
Atualiza o campo NXM_CTPARQ - Tipo do Arquivo

@author fabiana.silva
@since  20/10/2020
/*/
//-------------------------------------------------------------------
Static Function AtuNXMTPAR()
Local cTab :=  RetSqlName("NXM")
Local aArquivos := {{ STR0036 ,"'1'"},; //"CARTA_"
					{ STR0037, "'2'"},; //"RELATORIO_"
					{ STR0038, "'3'"},; //"RECIBO_"
					{ STR0039,"'4'"} ,; //"BOLETO_"
					{ STR0040, "'5'"},; //"UNIFICADO_"
					{ STR0041, "'6'"}} //"ADICIONAL_"
Local nC := 0
Local cSql := ""
For nC := 1 to Len(aArquivos)
	cSql := "UPDATE " + cTab + " SET NXM_CTPARQ = " + aArquivos[nC, 02] + " WHERE (NXM_CTPARQ = '' OR NXM_CTPARQ = ' ' ) AND UPPER(NXM_NOMARQ) LIKE '" + Upper(aArquivos[nC, 01]) + "%' AND D_E_L_E_T_ = ' '"
	TCSqlExec(cSql)

Next nC

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS11034
Desmembramento do campo OHH_JURFAT nos campos OHH_CESCR e OHH_CFATUR

@author Jonatas Martins
@since  17/08/2020
/*/
//-------------------------------------------------------------------
Static Function JPFS11034()
	Local cUpdate   := ""
	Local nTamFil   := TamSX3("NXA_FILIAL")[1]
	Local nTamEsc   := TamSX3("NXA_CESCR")[1]
	Local cIniEscr  := cValToChar(nTamFil + 2)
	Local cTamEscr  := cValToChar(nTamEsc)
	Local cIniFatur := cValToChar(nTamFil + 1 + nTamEsc + 2)
	Local cTamFatur := cValToChar(TamSX3("NXA_COD")[1])

	cUpdate := "UPDATE " + RetSqlName("OHH")
	cUpdate += " SET OHH_CESCR = SUBSTRING(OHH_JURFAT, " + cIniEscr  + "," + cTamEscr  + "),"
	cUpdate += " OHH_CFATUR = SUBSTRING(OHH_JURFAT, " + cIniFatur + "," + cTamFatur + ")"
	cUpdate += " WHERE OHH_FILIAL = '" + xFilial("OHH") + "'"
	cUpdate += "   AND D_E_L_E_T_ = ' '"
	cUpdate += "   AND OHH_CESCR = ' '"
	cUpdate += "   AND OHH_JURFAT <> ' '"

	cUpdate := ChangeQuery(cUpdate)
	cUpdate := "UPDATE" + SubStr(cUpdate, AT("ATE", cUpdate) + 3) // Ajuste devido falha no ChangeQuery
	TcSqlExec(cUpdate)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS12122
Preenche a data de movimentação dos adiantamentos com a data de inclusão
caso esse campo não estiver preenchido.

@author Abner Fogaça | Jonatas Martins
@since  25/11/2020
/*/
//-------------------------------------------------------------------
Static Function JPFS12122()
	Local cUpdate := ""

	cUpdate := "UPDATE " + RetSqlName("NWF")
	cUpdate += "   SET NWF_DTMOVI = NWF_DATAIN "
	cUpdate += " WHERE NWF_FILIAL = '" + xfilial("NWF") + "'"
	cUpdate += "   AND NWF_DTMOVI = ' ' "
	cUpdate += "   AND NWF_TITGER = '1' "
	cUpdate += "   AND D_E_L_E_T_ = ' ' "

	TcSqlExec(cUpdate)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS11609
Preenche o campo e-mail cópia da fatura

@author fabiana.silva
@since  12/12/2020
/*/
//-------------------------------------------------------------------
Static Function JPFS11609()
Local cUpdate  := ""
Local cDb :=  AllTrim(Upper(TCGetDB()))

	If cDb ==  "ORACLE"
		cUpdate := " UPDATE "+RetSqlName("NXA")+ " " //Update não tem alias
		cUpdate +=  " SET NXA_CEMAIL = COALESCE((SELECT NUH_CEMAIL "
		cUpdate +=                                  " FROM "+RetSqlName("NUH")+" NUH "
		cUpdate +=                                   " WHERE NUH.NUH_FILIAL = '" + xFilial("NUH") + "' "
		cUpdate +=                                    " AND NUH.NUH_COD = NXA_CLIPG "
		cUpdate +=                                    " AND NUH.NUH_LOJA = NXA_LOJPG "
		cUpdate +=                                    " AND NUH.D_E_L_E_T_ = ' ' "
		cUpdate +=                           " ), ' ' )" //Usa Coalesce para não tentar gravar campo nulo caso a query não volte nada
		cUpdate += " WHERE NXA_FILIAL = '" + xFilial("NXA") + "' "
		cUpdate +=   " AND NXA_CEMAIL = ' ' "
		cUpdate +=   " AND D_E_L_E_T_ = ' ' "
	Else
		cUpdate := "UPDATE "+RetSqlName("NXA")+" SET NXA_CEMAIL = NUH.NUH_CEMAIL
		cUpdate += " FROM "+RetSqlName("NXA")+" NXA "
		cUpdate += " INNER JOIN "+RetSqlName("NUH")+" NUH "
		cUpdate +=             " ON NUH.NUH_FILIAL = '" + xFilial("NUH") + "' "
		cUpdate +=            " AND NUH.NUH_COD = NXA.NXA_CLIPG "
		cUpdate +=            " AND NUH.NUH_LOJA = NXA.NXA_LOJPG "
		cUpdate +=            " AND NUH.D_E_L_E_T_ = ' ' "
		cUpdate += " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
		cUpdate +=   " AND NXA.NXA_CEMAIL = ' ' "
		cUpdate +=   " AND NXA.D_E_L_E_T_ = ' ' "
	EndIF
	TcSqlExec(cUpdate)
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS11409
Preencher campo situação do caso

@author fabiana.silva
@since  18/01/2021
@Obs    DJURFAT1-11409
/*/
//-------------------------------------------------------------------
Static Function JURPFS11409()
	Local cConcat := IIf(Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX", "||", "+")

	If JColumnPos("NVE_SITCAD") > 0
		TCSqlExec("UPDATE " + RetSqlName("NVE") + " SET NVE_SITCAD = '1' WHERE NVE_FILIAL = '" + xFilial("NVE") + "' AND D_E_L_E_T_ = ' ' AND NVE_CCLIEN " + cConcat + " NVE_LCLIEN IN (SELECT NUH_COD " + cConcat + " NUH_LOJA FROM " + RetSqlName("NUH") + " WHERE NUH_FILIAL = '" + xFilial("NUH") + "' AND NUH_SITCAD = '1' AND D_E_L_E_T_ = ' ')")
		TCSqlExec("UPDATE " + RetSqlName("NVE") + " SET NVE_SITCAD = '2' WHERE NVE_FILIAL = '" + xFilial("NVE") + "' AND D_E_L_E_T_ = ' ' AND NVE_CCLIEN " + cConcat + " NVE_LCLIEN IN (SELECT NUH_COD " + cConcat + " NUH_LOJA FROM " + RetSqlName("NUH") + " WHERE NUH_FILIAL = '" + xFilial("NUH") + "' AND NUH_SITCAD = '2' AND D_E_L_E_T_ = ' ')")

		NUY->(DbSetOrder(1)) //NUY_FILIAL, NUY_TABELA, NUY_FUNCAO, NUY_CODGRP, NUY_CAMPO
		If !NUY->(DbSeek(xFilial("NUY")+"NVE"+ space(TamSx3("NUY_FUNCAO")[1])+"001"+"NVE_SITCAD"))
			RecLock("NUY", .T.)
			NUY->NUY_FILIAL := xFilial("NUY")
			NUY->NUY_TABELA := "NVE"
			NUY->NUY_CODGRP := "001"
			NUY->NUY_CAMPO := "NVE_SITCAD"
			NUY->(MsUnLock())
		EndIf
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS12834
Atualiza o inicializador padrão (X3_RELACAO) dos campos OHB_DNATOR,
OHB_DPROJE, OHB_DITPRJ, OHB_DNATDE, OHB_DPROJD e OHB_DITPRD

@author Abner Fogaça
@since  15/04/2021
/*/
//-------------------------------------------------------------------
Static Function JPFS12834()
Local aSX3      := {}
Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO"}
Local aSX3Old   := {}

	aSX3Old  := {{"OHB", "OHB_DNATOR", "IF(!INCLUI,POSICIONE('SED',1,xFilial('SED')+FwFldGet('OHB_NATORI'),'ED_DESCRIC'),'')"},;
	             {"OHB", "OHB_DPROJE", "IF(!INCLUI,POSICIONE('OHL',1,xFilial('OHL')+" + 'FwFldGet("OHB_CPROJE")' + ",'OHL_DPROJE'),'')"},;
				 {"OHB", "OHB_DITPRJ", "IF(!INCLUI,POSICIONE('OHM',1,xFilial('OHM')+" + 'FwFldGet("OHB_CPROJE")+FwFldGet("OHB_CITPRJ")' + ",'OHM_DITEM'),'')"},;
				 {"OHB", "OHB_DNATDE", "IF(!INCLUI,POSICIONE('SED',1,xFilial('SED')+FwFldGet('OHB_NATDES'),'ED_DESCRIC'),'')"},;
				 {"OHB", "OHB_DPROJD", "IF(!INCLUI,POSICIONE('OHL',1,xFilial('OHL')+" + 'FwFldGet("OHB_CPROJD")' + ",'OHL_DPROJE'),'')"},;
				 {"OHB", "OHB_DITPRD", "IF(!INCLUI,POSICIONE('OHM',1,xFilial('OHM')+" + 'FwFldGet("OHB_CPROJD")+FwFldGet("OHB_CITPRD")' + ",'OHM_DITEM'),'')"}}

	aSX3 := {{"OHB", "OHB_DNATOR", "IF(!INCLUI,POSICIONE('SED',1,xFilial('SED')+OHB->OHB_NATORI,'ED_DESCRIC'),'')"},;
	         {"OHB", "OHB_DPROJE", "IF(!INCLUI,POSICIONE('OHL',1,xFilial('OHL')+OHB->OHB_CPROJE,'OHL_DPROJE'),'')"},;
			 {"OHB", "OHB_DITPRJ", "IF(!INCLUI,POSICIONE('OHM',1,xFilial('OHM')+OHB->OHB_CPROJE+OHB->OHB_CITPRJ,'OHM_DITEM'),'')"},;
			 {"OHB", "OHB_DNATDE", "IF(!INCLUI,POSICIONE('SED',1,xFilial('SED')+OHB->OHB_NATDES,'ED_DESCRIC'),'')"},;
			 {"OHB", "OHB_DPROJD", "IF(!INCLUI,POSICIONE('OHL',1,xFilial('OHL')+OHB->OHB_CPROJD,'OHL_DPROJE'),'')"},;
			 {"OHB", "OHB_DITPRD", "IF(!INCLUI,POSICIONE('OHM',1,xFilial('OHM')+OHB->OHB_CPROJD+OHB->OHB_CITPRD,'OHM_DITEM'),'')"}}
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS12093
Atualiza o campo NXV_TPLANC - Tipo do Lançamento

@author fabiana.silva
@since  17/03/2021
/*/
//-------------------------------------------------------------------
Static Function JPFS12093()
Local cSql := ""

	cSql := "UPDATE " + RetSqlName("NXV") + " SET NXV_TPLANC = '6' WHERE NXV_TPLANC = ' ' AND D_E_L_E_T_ = ' '"
	TCSqlExec(cSql)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS12872
Atualiza os campos - NWZ_FILLAN, NWZ_DTCCAN e NWZ_DTCEMI

@author fabiana.silva
@since  08/04/2021
/*/
//-------------------------------------------------------------------
Static Function JPFS12872()
Local cDb     := AllTrim(Upper(TCGetDB()))
Local cDtCEmi := Space(TamSX3("NWZ_DTCEMI")[1])
Local cDtCCan := Space(TamSX3("NWZ_DTCCAN")[1])
Local cUpdate := ""
Local lExecOnce := Empty(xFilial("NUF")) .AND. Empty(xFilial("NWZ"))

	If (!_lExecutou .AND. lExecOnce) .OR. !lExecOnce
		If cDb ==  "ORACLE"
			cUpdate := " UPDATE " + RetSqlName("NWZ") + " "
			cUpdate +=    " SET NWZ_DTCEMI = COALESCE((SELECT NUF_DTCEMI "
			cUpdate +=                                 " FROM " + RetSqlName("NUF") + " NUF "
			cUpdate +=                                " WHERE NUF.NUF_FILIAL = '" + xFilial("NUF") + "' "
			cUpdate +=                                  " AND NUF.NUF_COD = NWZ_CODWO"
			cUpdate +=                                  " AND NUF.D_E_L_E_T_ = ' ' ), '" + cDtCEmi + "')" // Usa Coalesce para não tentar gravar campo nulo caso a query não volte nada
			cUpdate +=  " WHERE NWZ_FILIAL = '" + xFilial("NWZ") + "' "
			cUpdate +=    " AND NWZ_DTCEMI = '" + cDtCEmi + "' "
			cUpdate +=    " AND D_E_L_E_T_ = ' ' "
			TcSqlExec(cUpdate)

			cUpdate := " UPDATE " + RetSqlName("NWZ") + " " // Update não tem alias
			cUpdate +=    " SET NWZ_DTCCAN = COALESCE((SELECT NUF_DTCCAN "
			cUpdate +=                                 " FROM " + RetSqlName("NUF") + " NUF "
			cUpdate +=                                " WHERE NUF.NUF_FILIAL = '" + xFilial("NUF") + "' "
			cUpdate +=                                  " AND NUF.NUF_COD = NWZ_CODWO"
			cUpdate +=                                  " AND NUF.D_E_L_E_T_ = ' ' ), '" + cDtCCan + "')" // Usa Coalesce para não tentar gravar campo nulo caso a query não volte nada
			cUpdate +=  " WHERE NWZ_FILIAL = '" + xFilial("NWZ") + "' "
			cUpdate +=    " AND NWZ_DTCCAN = '" + cDtCCan + "' "
			cUpdate +=    " AND D_E_L_E_T_ = ' ' "
			TcSqlExec(cUpdate)

		Else

			cUpdate := " UPDATE " + RetSqlName("NWZ") + " "
			cUpdate +=    " SET NWZ_DTCEMI = NUF_DTCEMI "
			cUpdate +=   " FROM " + RetSqlName("NWZ") + " NWZ "
			cUpdate +=  " INNER JOIN " + RetSqlName("NUF") + " NUF "
			cUpdate +=     " ON ( NUF.NUF_FILIAL = '" + xFilial("NUF") + "' "
			cUpdate +=    " AND   NUF.NUF_COD = NWZ_CODWO"
			cUpdate +=    " AND   NUF.D_E_L_E_T_ = ' ' )"
			cUpdate += " WHERE NWZ.NWZ_FILIAL = '" + xFilial("NWZ") + "' "
			cUpdate +=   " AND NWZ.NWZ_DTCEMI = '" + cDtCEmi + "' "
			cUpdate +=   " AND NWZ.D_E_L_E_T_ = ' ' "
			TcSqlExec(cUpdate)

			cUpdate := " UPDATE " + RetSqlName("NWZ") + " "
			cUpdate +=    " SET NWZ_DTCCAN = NUF_DTCCAN "
			cUpdate +=   " FROM "+RetSqlName("NWZ")+ " NWZ "
			cUpdate +=  " INNER JOIN "+RetSqlName("NUF")+" NUF "
			cUpdate +=     " ON ( NUF.NUF_FILIAL = '" + xFilial("NUF") + "' "
			cUpdate +=    " AND   NUF.NUF_COD = NWZ_CODWO"
			cUpdate +=    " AND   NUF.D_E_L_E_T_ = ' ' )"
			cUpdate +=  " WHERE NWZ.NWZ_FILIAL = '" + xFilial("NWZ") + "' "
			cUpdate +=    " AND NWZ.NWZ_DTCCAN = '" + cDtCCan + "' "
			cUpdate +=    " AND NWZ.D_E_L_E_T_ = ' ' "
			TcSqlExec(cUpdate)
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS12841
Preenche o campo NRU_ASSUNT com o conteudo do campo NRU_DESC

@author Victor Hayashi
@since  14/04/2021
/*/
//-------------------------------------------------------------------
Static Function JPFS12841()
Local cUpdate   := ""
Local nPosCorpo := Val(GetSx3Cache("NRU_CORPO", "X3_ORDEM"))
Local nOrdem    := 0

	nOrdem := Iif(nPosCorpo > 0, nPosCorpo, 12)
	AtuOrdem("NRU", nOrdem, "NRU_ASSUNT")

	cUpdate := " UPDATE " + RetSqlName("NRU")
	cUpdate +=    " SET NRU_ASSUNT = NRU_DESC"
	cUpdate +=  " WHERE NRU_ASSUNT = ' '"
	cUpdate +=    " AND D_E_L_E_T_ = ' '"
	TcSqlExec(cUpdate)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS12842
Preenche o campo NVQ_RECAL como 1 se o periodo estiver em aberto ou 
2 se o periodo estiver fechado.

@author Victor Hayashi
@since  20/04/2021
/*/
//-------------------------------------------------------------------
Static Function JPFS12842()
Local cUpdate   := ""

	cUpdate := " UPDATE " + RetSqlName("NVQ")
	cUpdate +=    " SET NVQ_RECALC = NVQ_SITUAC"
	cUpdate +=  " WHERE NVQ_RECALC = ' '"
	cUpdate +=    " AND D_E_L_E_T_ = ' '"
	TcSqlExec(cUpdate)

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS12084
Ajustes de débitos técnicos dos relacionamentos SX9 da issue DJURFAT1-12084

@author Jonatas Martins
@since  29/04/2021
/*/
//-------------------------------------------------------------------------
Static Function JPFS12084()
Local aSX7      := {}
Local aSX7Estr  := {}
Local aSX9      := {}
Local aSX9Estr  := {}
Local lDicInDdb := MPDicInDB()
Local cUsado    := IIf(lDicInDdb, "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ", "€€€€€€€€€€€€€€ ")
Local cNaoUsado := IIf(lDicInDdb, X3TreatUso("€€€€€€€€€€€€€€€"), "€€€€€€€€€€€€€€€")

	If JChkfile("OHG")
		aSX7      := {}
		aSX7Estr  := {"X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "lApaga" }
		Aadd(aSX7, {"OHG_CPART", "001", "RD0->RD0_NOME", "OHG_CPART", "__lApaga"} )
		AtuSX7(aSX7, aSX7Estr)
	EndIf

	If JChkfile("NWF")
		aSX7     := {}
		aSX7Estr := {"X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "lApaga" }
		Aadd(aSX7, {"NWF_FILIAL", "001", "ACY->ACY_DESCRI", "NWF_DGRPCL", "__lApaga"} )
		Aadd(aSX7, {"NWF_FILIAL", "002", '""'             , "NWF_CCLIEN", "__lApaga"} )
		Aadd(aSX7, {"NWF_FILIAL", "003", '""'             , "NWF_CLOJA" , "__lApaga"} )
		Aadd(aSX7, {"NWF_FILIAL", "004", '""'             , "NWF_CCASO" , "__lApaga"} )
		Aadd(aSX7, {"NWF_FILIAL", "005", '""'             , "NWF_DCASO" , "__lApaga"} )
		AtuSX7(aSX7, aSX7Estr)
	EndIf

	If JChkfile("NWZ") .And. JChkfile("NX0")
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_F3"}
		Aadd(aSX3, {"NWZ", "NWZ_CCASO" , ""} )
		Aadd(aSX3, {"NX0", "NX0_CCONTA", ""} )
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		aSX3      := {}
		aSX3Old   := {{"NX0", "NX0_DCONTA", cUsado, "POSICIONE('SU5',1,xFilial('SU5')+NX0->NX0_CCONTA,'U5_CONTAT')", "POSICIONE('SU5',1,xFilial('SU5')+NX0->NX0_CCONTA,'U5_CONTAT')"}}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_USADO", "X3_RELACAO", "X3_INIBRW"}
		Aadd(aSX3, {"NX0", "NX0_DCONTA", cNaoUsado, "", ""} )
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

	If JChkfile("NRI")
		aSX9     := {}
		aSX9Estr := {"X9_DOM","X9_IDENT","X9_CDOM","X9_EXPDOM","X9_EXPCDOM","X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR", "lApaga" }
		aAdd(aSX9,  {"NRI"   ,"003"     ,"NU9"    ,"NRI_TIPO" , "NU9_CTIPO",           ,           ,            ,            ,           ,           ,           ,           ,"__lApaga"})
		AtuSX9(aSX9, aSX9Estr)
	EndIf

	If JChkfile("NTQ")
		aSX9     := {}
		aSX9Estr := {"X9_DOM","X9_IDENT","X9_CDOM","X9_EXPDOM","X9_EXPCDOM","X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR", "lApaga" }
		aAdd(aSX9,  {"NTQ"   ,"001"     ,"NRX"    ,"NTQ_CEMP" , "NRX_CDOC" ,           ,           ,            ,            ,           ,           ,           ,           ,"__lApaga"})
		AtuSX9(aSX9, aSX9Estr)
	EndIf

	If JChkfile("NUR")
		aSX9     := {}
		aSX9Estr := {"X9_DOM","X9_IDENT","X9_CDOM" ,"X9_EXPDOM","X9_EXPCDOM","X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR", "lApaga" }
		aAdd(aSX9,  {"NUR"   ,"001"     ,"NUS"     ,"NUR_CPART", "NUS_CPART",           ,           ,            ,            ,           ,           ,           ,           ,"__lApaga"})
		AtuSX9(aSX9, aSX9Estr)
	EndIf

	If JChkfile("NUH")
		aSX9     := {}
		aSX9Estr := {"X9_DOM","X9_IDENT","X9_CDOM","X9_EXPDOM"        ,"X9_EXPCDOM"            ,"X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR", "lApaga" }
		aAdd(aSX9,  {"NUH"   ,"002"     ,"NW2"     ,"NUH_COD+NUH_LOJA" , "NW2_CCLIEN+NW2_CLOJA" ,           ,           ,            ,            ,           ,           ,           ,           ,"__lApaga"})
		AtuSX9(aSX9, aSX9Estr)
	EndIf

	If JChkfile("NX8")
		aSX9     := {}
		aSX9Estr := {"X9_DOM","X9_IDENT","X9_CDOM" ,"X9_EXPDOM"             ,"X9_EXPCDOM"            ,"X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR", "lApaga" }
		aAdd(aSX9,  {"NX8"   ,"001"     ,"NT1"     ,"NX8_CCONTR+NX8_CPREFT" , "NT1_CCONTR+NT1_CPREFT",           ,           ,            ,            ,           ,           ,           ,           ,"__lApaga"})
		AtuSX9(aSX9, aSX9Estr)
	EndIf

	If JChkfile("NX0")
		aSX9     := {}
		aSX9Estr := {"X9_DOM","X9_IDENT","X9_CDOM" ,"X9_EXPDOM"          ,"X9_EXPCDOM"            ,"X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR", "lApaga" }
		aAdd(aSX9,  {"NX0"   ,"001"     ,"NX1"     ,"NX0_COD+NX0_CCONTR" , "NX1_CPREFT+NX1_CCONTR",           ,           ,            ,            ,           ,           ,           ,           ,"__lApaga"})
		AtuSX9(aSX9, aSX9Estr)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS13046
Ajustes de débitos técnicos dos relacionamentos SX9 da issue DJURFAT1-13046.
Exclusão de gatilho.

@author Reginaldo Borges
@since  25/05/2021
/*/
//-------------------------------------------------------------------------
Static Function JPFS13046()
Local aSX7     := {}
Local aSX7Estr := {}

	If JChkfile("NS7")
		aSX7      := {}
		aSX7Estr  := {"X7_CAMPO", "X7_SEQUENC","X7_REGRA"      ,"X7_CDOMIN"  ,"lApaga" }
		Aadd(aSX7,   {"NS7_COD" , "001"       , "NS7->NS7_NOME", "NVE_DESCRI", "__lApaga"} )
		AtuSX7(aSX7, aSX7Estr)
	EndIf

	If JChkfile("OHG")
		aSX7      := {}
		aSX7Estr  := {"X7_CAMPO" ,"X7_SEQUENC","X7_REGRA"      ,"X7_CDOMIN" ,"lApaga" }
		Aadd(aSX7,   {"OHG_CPART", "001"      , "RD0->RD0_NOME", "OHG_CPART", "__lApaga"} )
		AtuSX7(aSX7, aSX7Estr)
	EndIf

	If JChkfile("NRY")
		aSX9     := {}
		aSX9Estr := {"X9_DOM","X9_IDENT" ,"X9_CDOM" ,"X9_EXPDOM" ,"X9_EXPCDOM" ,"X9_PROPRI"  ,"X9_LIGDOM" , "X9_LIGCDOM", "X9_CONDSQL", "X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR","lApaga" }
		aAdd(aSX9,  {"NRY"   , "003"     , "NRZ"    , "NRY_COD"  , "NRZ_CFASE"  ,            ,            ,             ,             ,            ,           ,           ,           ,"__lApaga"})
		AtuSX9(aSX9, aSX9Estr)
	EndIf

	If JChkfile("NRY")
		aSX9     := {}
		aSX9Estr := {"X9_DOM","X9_IDENT","X9_CDOM","X9_EXPDOM"  ,"X9_EXPCDOM","X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR","lApaga" }
		aAdd(aSX9,  {"NRY"   , "001"    , "NS0"   , "NRY_CFASE" , "NS0_CFASE",           ,           ,            ,            ,           ,           ,           ,           ,"__lApaga"})
		AtuSX9(aSX9, aSX9Estr)
	EndIf

	If JChkfile("NS0")
		aSX9     := {}
		aSX9Estr := {"X9_DOM","X9_IDENT","X9_CDOM","X9_EXPDOM"  ,"X9_EXPCDOM" ,"X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR","lApaga" }
		aAdd(aSX9,  {"NS0"   , "001"    , "NS1"   , "NS0_CATIV" , "NS1_CATIV" ,           ,           ,            ,            ,           ,           ,            ,          ,"__lApaga"})
		AtuSX9(aSX9, aSX9Estr)
	EndIf

	If JChkfile("NS0")
		aSX9     := {}
		aSX9Estr := {"X9_DOM","X9_IDENT","X9_CDOM","X9_EXPDOM" ,"X9_EXPCDOM"  ,"X9_PROPRI","X9_LIGDOM","X9_LIGCDOM", "X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR","lApaga" }
		aAdd(aSX9,  {"NS0"   , "002"    , "NUE"   , "NS0_CATIV", "NUE_CTAREB" ,           ,           ,            ,             ,           ,           ,           ,           ,"__lApaga"})
		AtuSX9(aSX9, aSX9Estr)
	EndIf

	If JChkfile("NRV")
		aSX9     := {}
		aSX9Estr := {"X9_DOM","X9_IDENT" ,"X9_CDOM","X9_EXPDOM","X9_EXPCDOM","X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL", "X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR","lApaga" }
		aAdd(aSX9,  {"NRV"   , "002"     , "NS2"   , "NRV_COD" , "NS2_CCATE",           ,           ,            ,            ,            ,           ,           ,           ,"__lApaga"})
		AtuSX9(aSX9, aSX9Estr)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS13184
Ajustes de débitos técnicos dos relacionamentos SX9 da issue DJURFAT1-13184.
Exclusão de gatilho.

@author Reginaldo Borges
@since  04/06/2021
/*/
//-------------------------------------------------------------------------
Static Function JPFS13184()
Local aSX7     := {}
Local aSX7Estr := {}

	If JChkfile("NUE")
		aSX7Estr  := {"X7_CAMPO"   , "X7_SEQUENC", "X7_REGRA"      , "X7_CDOMIN" , "lApaga" }
		Aadd(aSX7,   {"NUE_CUSERA" , "001"       , "RD0->RD0_SIGLA", "NUE_SIGLAA", "__lApaga"} )
		Aadd(aSX7,   {"NUE_SIGLAA" , "001"       , "RD0->RD0_NOME" , "NUE_DUSERA", "__lApaga"} )
		AtuSX7(aSX7, aSX7Estr)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS13063
Ajuste na rotina de WO de Despesas - Issue DJURFAT1-13063.
Exclusão de gatilho e ajuste de ordem na tabela NVY

@author Jorge Martins
@since  11/06/2021
/*/
//-------------------------------------------------------------------------
Static Function JPFS13063()
Local aSX3     := {}
Local aSX3Old  := {}
Local aSX3Estr := {}
Local aSX7     := {}
Local aSX7Estr := {}
Local nPosCpo  := 0

	If JChkfile("NVY") .And. NVY->(JColumnPos("NVY_CMOTWR")) > 0
		nPosCpo := Val(GetSx3Cache("NVY_USRNCB", "X3_ORDEM"))
		AtuOrdem("NVY", nPosCpo + 1, "NVY_CMOTWR")
		AtuOrdem("NVY", nPosCpo + 2, "NVY_DMOTWR")
		
		aSX7Estr  := {"X7_CAMPO"   , "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN" , "lApaga"  }
		Aadd(aSX7,   {"NVY_COBRAR" , "004"       , '""'      , "NVY_OBSWOR", "__lApaga"} )
		AtuSX7(aSX7, aSX7Estr)

		aSX3      := {}
		aSX3Old   := {{"NVY", "NVY_CMOTWR", "V"}}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_VISUAL"}
		Aadd(aSX3, {"NVY", "NVY_CMOTWR", "A"})
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JChkfile
Execução da Rotina de Verificação de Tabelas em Buffer

@return lRet, Indica se a tabela existe

@author fabiana.silva
@since  25/06/2021
/*/
//-------------------------------------------------------------------------
Static Function JChkfile(cAlias)
Local nPos := {}
Local lRet := .F.

	If (nPos := aScan(_aTabExist, {|t| t[1] == cAlias})) > 0
		lRet := _aTabExist[nPos, 2]
	Else
		lRet := Chkfile(cAlias)
		aAdd(_aTabExist, {cAlias, lRet})
	EndIf

Return lRet

//-------------------------------------------------------------------------
/*/{Protheus.doc} JColumnPos
Execução da Rotina de Verificação de Colunas em Buffer

@param  cCampo, Campo a ser verificado

@return nRet  , Indica a posição do campo no banco

@author fabiana.silva
@since  25/06/2021
/*/
//-------------------------------------------------------------------------
Static Function JColumnPos(cCampo)
Local nPos := {}
Local nRet := 0
Local cAls := ""

	If (nPos := aScan(_aColExist, {|t| t[1] == cCampo})) > 0
		nRet := _aColExist[nPos, 2]
	Else
		cAls := Substr(cCampo, 1, At("_", cCampo) - 1)

		If Len(cAls) < 3
			cAls := "S" + cAls
		EndIf

		nRet := (cAls)->(ColumnPos(cCampo))
		aAdd(_aColExist, {cCampo, nRet})
	EndIf

Return nRet

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS12801
DJURFAT1-12801 - Campo para envio de Minuta.
Ajuste do tamanho do campo NXA_EMAIL e da ordem do campo NUH_EMLMIN.

@author Victor Hayashi
@since  16/06/2021
/*/
//-------------------------------------------------------------------------
Static Function JPFS12801()
Local nPosCpo  := 0

	nPosCpo := Val(GetSx3Cache("NUH_CEMAIL", "X3_ORDEM"))
	AtuOrdem("NUH", nPosCpo + 1, "NUH_EMLMIN")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS12959
Preenche o campo CQD_PFSREC como 1 se o periodo estiver em aberto ou 
2 se o periodo estiver fechado/bloqueado.

@author Victor Hayashi
@since  24/08/2021
/*/
//-------------------------------------------------------------------
Static Function JPFS12959()
Local cUpdate   := ""

	cUpdate := " UPDATE " + RetSqlName("CQD")
	cUpdate +=    " SET CQD_PFSREC = CASE WHEN CQD_STATUS = '1' THEN '1'"
	cUpdate +=                          " ELSE '2' END"
	cUpdate +=  " WHERE CQD_PFSREC = ' '"
	cUpdate +=    " AND D_E_L_E_T_ = ' '"
	TcSqlExec(cUpdate)

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS13704()
Ajuste na rotina de Controle de Adiantamentos - Issue DJURFAT1-13704.
Ajuste na ordem do campos da NWF.

@author Reginaldo Borges
@since  26/10/2021
/*/
//-------------------------------------------------------------------------
Static Function JPFS13704()
Local nPosCpo := Val(GetSx3Cache("NWF_DCASO", "X3_ORDEM"))

	AtuOrdem("NWF", nPosCpo + 1, "NWF_TPADI" )
	AtuOrdem("NWF", nPosCpo + 2, "NWF_EXCLUS")
	AtuOrdem("NWF", nPosCpo + 3, "NWF_CCLIAD")
	AtuOrdem("NWF", nPosCpo + 4, "NWF_CLOJAD")
	AtuOrdem("NWF", nPosCpo + 5, "NWF_DCLIAD")

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JDEP10299
Migração dos dados do Projeto de Origem para o Projeto de Destino por conta
da reativação dos campos de Projeto e Item de Projeto do Destino do Lançamento

DJURDEP-10299
@author Willian Kazahaya
@since  07/03/2022
/*/
//-------------------------------------------------------------------------
Function JDEP10299()
Local cQuery   := ""
Local cAliasDb := ""
	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery +=   " FROM " + RetSqlName("OHB") 
	cQuery +=  " WHERE OHB_CPROJE <> ' ' "
	cQuery +=    " AND OHB_CPROJD = ' ' "
	cQuery +=    " AND D_E_L_E_T_ = ' ' "

	cAliasDb := GetNextAlias()
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasDb, .T., .T.)

	While (cAliasDb)->(!Eof())
		DbSelectArea('OHB')
		OHB->( dbGoTo((cAliasDb)->(RECNO)) )

		RecLock("OHB", .F.)
		OHB->OHB_CPROJD := OHB->OHB_CPROJE
		OHB->OHB_CITPRD := OHB->OHB_CITPRJ
		OHB->OHB_CPROJE := Space(TamSx3('OHB_CPROJE')[1])
		OHB->OHB_CITPRJ := Space(TamSx3('OHB_CITPRJ')[1])
		OHB->(MsUnLock())

		(cAliasDb)->( DbSkip() )
	End
Return Nil
//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS13791
Inativação dos gatilhos que fazem referência aos campos OHB_CTPDPD e OHF_CTPDSP
da issue DJURFAT1-13791.

@author Abner Fogaça
@since  27/10/2021
/*/
//-------------------------------------------------------------------------
Static Function JPFS13791()
Local aSX7     := {}
Local aSX7Estr := {}

	If JChkfile("OHB") .And. JChkfile("OHF")
		aSX7Estr  := {"X7_CAMPO"  , "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN" , "X7_TIPO", "X7_SEEK", "X7_ALIAS", "X7_ORDEM", "X7_CHAVE", "X7_CONDIC", "lNaoCria"  }
		Aadd(aSX7,   {"OHB_CCASOD", "004"       , '""'      , "OHB_CTPDPD", "P"      , "N"      , ""        , 0         , ""        , ".F."      , "__lNaoCria"})
		Aadd(aSX7,   {"OHB_CCLID" , "006"       , '""'      , "OHB_CTPDPD", "P"      , "N"      , ""        , 0         , ""        , ".F."      , "__lNaoCria"})
		Aadd(aSX7,   {"OHB_CLOJD" , "004"       , '""'      , "OHB_CTPDPD", "P"      , "N"      , ""        , 0         , ""        , ".F."      , "__lNaoCria"})
		Aadd(aSX7,   {"OHF_CCASO" , "004"       , '""'      , "OHF_CTPDSP", "P"      , "N"      , ""        , 0         , ""        , ".F."      , "__lNaoCria"})
		Aadd(aSX7,   {"OHF_CLOJA" , "004"       , '""'      , "OHF_CTPDSP", "P"      , "N"      , ""        , 0         , ""        , ".F."      , "__lNaoCria"})
		AtuSX7(aSX7, aSX7Estr)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS14432
Exclusão de relacionamentos (SX9) incorretos, e ajuste de ordem de campos
novos da NX0 de TSs de contratos fixos e não cobráveis

@author Reginaldo Borges
@since  04/04/2022
/*/
//-------------------------------------------------------------------------
Static Function JPFS14432()
Local aSX9Estr  := {}
Local nPosExito := 0
Local cUpdate   := ""

	If JChkfile("NVN")
		aSX9     := {}
		aSX9Estr := {"X9_DOM","X9_IDENT","X9_CDOM","X9_EXPDOM"  ,"X9_EXPCDOM"  ,"X9_PROPRI","X9_LIGDOM","X9_LIGCDOM", "X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR","lApaga" }
		aAdd(aSX9,  {"NT1"   , "001"    , "NVN"   , "NT1_SEQUEN", "NVN_CFATAD" ,           ,           ,            ,             ,           ,           ,           ,           ,"__lApaga"})
		aAdd(aSX9,  {"NVV"   , "003"    , "NVN"   , "NVV_COD"   , "NVN_CFIXO"  ,           ,           ,            ,            ,            ,           ,           ,           ,"__lApaga"})
		AtuSX9(aSX9, aSX9Estr)
	EndIf

	If JChkfile("NX0") .And. NX0->(JColumnPos("NX0_FXNC")) > 0
		nPosExito := Val(GetSx3Cache("NX0_DFIMFX", "X3_ORDEM")) // Os campos novos ficarão após o campo de exito
		AtuOrdem("NX0", nPosExito + 1, "NX0_FXNC")
		AtuOrdem("NX0", nPosExito + 2, "NX0_DIFXNC")
		AtuOrdem("NX0", nPosExito + 3, "NX0_DFFXNC")

		cUpdate := " UPDATE " + RetSqlName("NX0")
		cUpdate +=    " SET NX0_FXNC = '2'"
		cUpdate +=  " WHERE NX0_FXNC = ' '"
		cUpdate +=    " AND D_E_L_E_T_ = ' '"
		TcSqlExec(cUpdate)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS14119
Ajuste de ordem dos campos novos de valor de TimeSheet não cobrável

@author Jonatas Martins / Jorge Martins
@since  13/04/2022
/*/
//-------------------------------------------------------------------------
Static Function JPFS14119()

	If JChkfile("NX1") .And. NX1->(JColumnPos("NX1_VTSNC")) > 0
		AtuOrdem("NX1", Val(GetSx3Cache("NX1_VTSVIN", "X3_ORDEM")) + 1, "NX1_VTSNC")
		AtuOrdem("NX8", Val(GetSx3Cache("NX8_VTSVIN", "X3_ORDEM")) + 1, "NX8_VTSNC")
		AtuOrdem("NXC", Val(GetSx3Cache("NXC_VTSVIN", "X3_ORDEM")) + 1, "NXC_VTSNC")
		AtuOrdem("NXB", Val(GetSx3Cache("NXB_VTSVIN", "X3_ORDEM")) + 1, "NXB_VTSNC")
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS14546
Preenche novo campo (NVN_ENVENC) de envio de encaminhamentos

@author Jonatas Martins
@since  13/04/2022
/*/
//-------------------------------------------------------------------------
Static Function JPFS14546()
Local cUpdate := ""

	// Atualiza flag de envio dos encaminhamentos de e-mail
	If JChkfile("NVN") .And. NVN->(JColumnPos("NVN_ENVENC")) > 0
		cUpdate := "UPDATE " + RetSqlName("NVN")
		cUpdate +=   " SET NVN_ENVENC = '2' " // "2" = Não
		cUpdate +=  "WHERE NVN_ENVENC = ' ' "
		cUpdate +=    "AND D_E_L_E_T_ = ' ' "
		TcSqlExec(cUpdate)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS14594
Ajuste na ordem dos campos relacionados a Gross Up de Impostos / Honorários.
Issue DJURFAT1-14594.

@author Cristina Cintra
@since  01/06/2022
/*/
//-------------------------------------------------------------------------
Static Function JPFS14594()

	If JChkfile("NUH") .And. JChkfile("NXP") .And. JChkfile("NXG") .And. JChkfile("NXA");
	   .And. NUH->(JColumnPos("NUH_GROSHN")) > 0
		AtuOrdem("NUH", 60, "NUH_GROSHN")
		AtuOrdem("NUH", 61, "NUH_PERCGH")
		AtuOrdem("NXP", 32, "NXP_GROSHN")
		AtuOrdem("NXP", 33, "NXP_PERCGH")
		AtuOrdem("NXG", 40, "NXG_GROSHN")
		AtuOrdem("NXG", 41, "NXG_PERCGH")
		AtuOrdem("NXA", 22, "NXA_VGROSH")
	
		TCSqlExec("UPDATE " + RetSqlName("NUH") + " SET NUH_GROSHN = '1' WHERE D_E_L_E_T_ = ' ' AND NUH_GROSHN = ' '")
		TCSqlExec("UPDATE " + RetSqlName("NXP") + " SET NXP_GROSHN = '1' WHERE D_E_L_E_T_ = ' ' AND NXP_GROSHN = ' '")
		TCSqlExec("UPDATE " + RetSqlName("NXG") + " SET NXG_GROSHN = '1' WHERE D_E_L_E_T_ = ' ' AND NXG_GROSHN = ' '")

	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS14640
Ajuste no X3_VISUAL de V para A do campo NT1_QTDADE - Issue DJURFAT1-14640.

@author Cristina Cintra
@since  20/05/2022
/*/
//-------------------------------------------------------------------------
Static Function JPFS14640()
Local aSX3     := {}
Local aSX3Old  := {}
Local aSX3Estr := {}

	If JChkfile("NT1") .And. NT1->(JColumnPos("NT1_QTDADE")) > 0
		aSX3Old   := {{"NT1", "NT1_QTDADE", "V"}}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_VISUAL"}
		Aadd(aSX3, {"NT1", "NT1_QTDADE", "A"})
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS13504
Criação da classificação de natureza 016 - Transitória de pagamento

A Classificação nova será criada e a natureza dela será preenchida com 
a única natureza transitória de pagamento que existe. Após aplicação
do pacote dessa issue, será liberado o uso de várias transitórias de
pagamento.

@author Jorge Martins
@since  04/10/2022
/*/
//-------------------------------------------------------------------------
Static Function JPFS13504()
Local aDadosOHP := {}

	If SuperGetMV("MV_JURXFIN",, .F.)
		JA266Carga(.F.) // Carga inicial da classificação de naturezas

		aDadosOHP := JurGetDados("OHP", 1, xFilial("OHP") + "1" + "TP", {"OHP_COD", "OHP_CNATUR"})

		If !Empty(aDadosOHP) .And. !Empty(aDadosOHP[1]) .And. Empty(AllTrim(aDadosOHP[2])) // Valida se a nova classificação foi criada
			JurOperacao(4, "OHP", 1, xFilial("OHP") + "1" + "TP", {"OHP_CNATUR"}, {JurBusNat("7")}) // Se a natureza estiver vazia, preenche com a natureza transitória de pagamento que existe
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS14913
Preenche novo campo ED_DESFAT e faz a criação da classificação de 
natureza 017 - Despesa de cliente

A Classificação nova será criada e a natureza dela será preenchida com 
a única natureza de despesa que existe. Após aplicação
do pacote dessa issue, será liberado o uso de várias naturezas de despesa.

@author Jorge Martins
@since  26/10/2022
/*/
//-------------------------------------------------------------------------
Static Function JPFS14913()
Local cUpdate   := ""

	If SED->(JColumnPos("ED_DESFAT")) > 0
		cUpdate := " UPDATE " + RetSqlName("SED")
		cUpdate +=    " SET ED_DESFAT  = '1'"
		cUpdate +=  " WHERE ED_DESFAT  = ' '"
		cUpdate +=    " AND ED_CCJURI = '5'"
		cUpdate +=    " AND D_E_L_E_T_ = ' '"
		TcSqlExec(cUpdate)
		
		cUpdate := " UPDATE " + RetSqlName("SED")
		cUpdate +=    " SET ED_DESFAT  = '2'"
		cUpdate +=  " WHERE ED_DESFAT  = ' '"
		cUpdate +=    " AND D_E_L_E_T_ = ' '"
		TcSqlExec(cUpdate)

		If SuperGetMV("MV_JURXFIN",, .F.)
			JA266Carga(.F.) // Carga inicial da classificação de naturezas

			aDadosOHP := JurGetDados("OHP", 1, xFilial("OHP") + "3" + "DP", {"OHP_COD", "OHP_CNATUR"})

			If !Empty(aDadosOHP) .And. !Empty(aDadosOHP[1]) .And. Empty(AllTrim(aDadosOHP[2])) // Valida se a nova classificação foi criada
				JurOperacao(4, "OHP", 1, xFilial("OHP") + "3" + "DP", {"OHP_CNATUR"}, {JurBusNat("5")}) // Se a natureza estiver vazia, preenche com a natureza transitória de pagamento que existe
			EndIf
		EndIf

	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS14504
Função para complementar o código do adiantamento (NWF_COD) com zeros
a esqueda após o aumento do tamanho de 4 para 9.

@author Jonatas Martins
@since  19/12/2022
/*/
//-------------------------------------------------------------------------
Static Function JPFS14504()
Local cDataBase := ""
Local cUpdate   := ""
Local nTam      := GetSX3Cache("NWF_COD", "X3_TAMANHO")
Local cCaracter := Replicate("0", nTam - 4)

	If JChkfile("NWF") .And. nTam > 4 // @12.1.2310
		cDataBase := AllTrim(Upper(TCGetDB()))

		If cDataBase $ "ORACLE|POSTGRES"
			cUpdate := "UPDATE " + RetSqlName("NWF") + " SET NWF_COD = '" + cCaracter + "' || LTRIM(RTRIM(NWF_COD)) WHERE LENGTH(LTRIM(RTRIM(NWF_COD))) = 4"
		Else
			cUpdate := "UPDATE " + RetSqlName("NWF") + " SET NWF_COD = '" + cCaracter + "' + LTRIM(RTRIM(NWF_COD)) WHERE LEN(LTRIM(RTRIM(NWF_COD))) = 4"
		EndIf

		TCSqlExec(cUpdate)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS15624()
Ajuste na rotina de Clientes - Issue DJURFAT1-15624.
Ajuste na ordem de campo da NUH.

@author Reginaldo Borges
@since  02/01/2023
/*/
//-------------------------------------------------------------------------
Static Function JPFS15624()
Local nPosCpo := 0
	
	If NUH->(JColumnPos("NUH_ENCCAS")) > 0
		nPosCpo := Val(GetSx3Cache("NUH_CASAUT", "X3_ORDEM"))
		AtuOrdem("NUH", nPosCpo + 1, "NUH_ENCCAS")
		TCSqlExec("UPDATE " + RetSqlName("NUH") + " SET NUH_ENCCAS = '2' WHERE NUH_ENCCAS = ' ' AND D_E_L_E_T_ = ' '")
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS15881
Ajusta valor de desconto não é preenchido no Participante da Fatura (NXD_DESCTO)

@author Jonatas Martins
@since  06/03/2023
/*/
//-------------------------------------------------------------------------
Static Function JPFS15881()
Local aArea   := GetArea()
Local cQuery  := ""
Local cTemp   := GetNextAlias()
Local cDecFat := cValToChar(GetSX3Cache("NXA_VLDESC", "X3_DECIMAL"))

	cQuery := "SELECT A.NXA_CESCR, A.NXA_COD, A.NXA_VLDESC, A.TOT_ADVG"
	cQuery +=  " FROM (SELECT NXA.NXA_CESCR,"
	cQuery +=               " NXA.NXA_COD,"
	cQuery +=               " NXA.NXA_VLDESC,"
	cQuery +=               " SUM(NXD.NXD_VLCORR) TOT_ADVG,"
	cQuery +=               " SUM(NXD.NXD_DESCTO) TOT_DESCNXD"
	cQuery +=          " FROM " + RetSqlName("NXA") + " NXA," + RetSqlName("NXD") + " NXD"
	cQuery +=         " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "'"
	cQuery +=           " AND NXA.NXA_SITUAC = '1'"
	cQuery +=           " AND NXA.NXA_VLDESC > 0"
	cQuery +=           " AND NXA.D_E_L_E_T_ = ' '"
	cQuery +=           " AND NXD.NXD_FILIAL = '" + xFilial("NXD") + "'"
	cQuery +=           " AND NXD.NXD_CESCR = NXA.NXA_CESCR"
	cQuery +=           " AND NXD.NXD_CFATUR = NXA.NXA_COD"
	cQuery +=           " AND NXD.D_E_L_E_T_ = ' '"
	cQuery +=         " GROUP BY NXA.NXA_CESCR, NXA.NXA_COD, NXA.NXA_VLDESC) A"
	cQuery += " WHERE A.NXA_VLDESC <> ROUND(A.TOT_DESCNXD, " + cDecFat + ")"

	MPSysOpenQuery(cQuery, cTemp)

	// Percorre Faturas e Minutas
	While (cTemp)->(! EOF())
		J201DesLin((cTemp)->NXA_COD, (cTemp)->NXA_CESCR, .F.)
		(cTemp)->(DbSkip())
	EndDo

	(cTemp)->(DbCloseArea())
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS15929
Tira usado do campo NRC_FUTURO

@author Jorge Martins
@since  21/03/2023
/*/
//-------------------------------------------------------------------------
Static Function JPFS15929()
Local aSX3      := {}
Local aSX3Old   := {}
Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_USADO"}
Local cUsado    := "€€€€€€€€€€€€€€ " // Formato quando NÃO É dicionário no banco
Local cNaoUsado := "€€€€€€€€€€€€€€€" // Formato quando NÃO É dicionário no banco

	If JChkfile("NRC")

		If MPDicInDB() // Dicionário no banco - Muda o formato
			cUsado    := "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     "
			cNaoUsado := X3TreatUso("€€€€€€€€€€€€€€€")
		EndIf

		aSX3Old   := {{"NRC", "NRC_FUTURO", cUsado}}
		Aadd(aSX3, {"NRC", "NRC_FUTURO", cNaoUsado})
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS16328
Ajusta a posição dos campos NVE_DTEFT e NVE_DESCAS. Ajusta a base de dados
para que o campo NVE_DTEFT seja preenchido com a Data de entrada.

DJURFAT1-16328

@author Victor Hayashi
@since  12/05/2023
/*/
//-------------------------------------------------------------------------
Static Function JPFS16328()
Local cQuery  := ""
Local cUpdate := ""
Local nPosCpo := 0
Local nX      := 0
Local aDados  := {}

	If JColumnPos("NVE_DTEFT") > 0 .And. JColumnPos("NVE_DESCAS") > 0

		// Adiciona o campo no agrupamento de caso
		NUY->(DbSetOrder(1)) //NUY_FILIAL, NUY_TABELA, NUY_FUNCAO, NUY_CODGRP, NUY_CAMPO
		If !NUY->(DbSeek(xFilial("NUY")+"NVE"+ space(TamSx3("NUY_FUNCAO")[1])+"001"+"NVE_DTEFT"))
			RecLock("NUY", .T.)
			NUY->NUY_FILIAL := xFilial("NUY")
			NUY->NUY_TABELA := "NVE"
			NUY->NUY_CODGRP := "001"
			NUY->NUY_CAMPO := "NVE_DTEFT"
			NUY->(MsUnLock())
		EndIf

		// Adiciona o campo no agrupamento de caso
		If !NUY->(DbSeek(xFilial("NUY")+"NVE"+ space(TamSx3("NUY_FUNCAO")[1])+"001"+"NVE_DESCAS"))
			RecLock("NUY", .T.)
			NUY->NUY_FILIAL := xFilial("NUY")
			NUY->NUY_TABELA := "NVE"
			NUY->NUY_CODGRP := "001"
			NUY->NUY_CAMPO := "NVE_DESCAS"
			NUY->(MsUnLock())
		EndIf

		If !Val(GetSx3Cache("NVE_DTEFT", "X3_ORDEM")) == 58 // Ordem do campo no AtuSx

			// Ajusta ordenação da tabela NVE
			cQuery := " SELECT X2_CHAVE, X3_CAMPO"
			cQuery +=   " FROM " + RetSqlName("SX2")
			cQuery +=  " INNER JOIN " + RetSqlName("SX3")
			cQuery +=     " ON X2_CHAVE = X3_ARQUIVO "
			cQuery +=    " AND X3_ORDEM ='9A'"
			cQuery +=  " WHERE X2_MODULO = '77' AND X2_CHAVE = 'NVE'"
			aDados := JurSQL(cQuery, {"*"})

			For nX := 1 to Len(aDados)
				AtuOrdem(aDados[nX][01], Val(RetAsc('A0', 3, .F.)), aDados[nX][02])
			Next nX

			// Atualiza a ordem do campo NVE_DTEFT para ficar depois do campo NVE_SITCAD
			nPosCpo := Val(RetAsc(GetSx3Cache("NVE_SITCAD", "X3_ORDEM"), 2, .F.))
			AtuOrdem("NVE", nPosCpo + 1, "NVE_DTEFT")

			// Atualiza a ordem do campo NVE_DESCRC para ficar depois do campo
			nPosCpo := Val(RetAsc(GetSx3Cache("NVE_REDFAT", "X3_ORDEM"), 2, .F.))
			AtuOrdem("NVE", nPosCpo + 1, "NVE_DESCAS")

			// Realiza ajuste na base, para que todos os casos tenham o campo novo preenchido.
			cUpdate := " UPDATE " + RetSqlName("NVE")
			cUpdate +=    " SET NVE_DTEFT = NVE_DTENTR"
			cUpdate +=  " WHERE NVE_SITCAD = '2'"
			cUpdate +=    " AND NVE_DTEFT = ' '"
			cUpdate +=    " AND D_E_L_E_T_ = ' '"
			TcSqlExec(cUpdate)
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JJUR11582
Reordena os campos da NUH para incluir o campo de Vincula Comprovante de 
despesa no Relatório Unificado (NUH_VINCOM) proximo do campo de Unifica 
Relatório (NUH_UNIREL)

@author Willian Kazahaya
@since  23/05/2023
/*/
//-------------------------------------------------------------------------
Function JJUR11582()
Local nOrdUniRel := GetSx3Cache("NUH_UNIREL", "X3_ORDEM")
	AtuOrdem("NUH", Val(nOrdUniRel) + 1, "NUH_VINCOM")
Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS16035
Preenche conteúdo padrão do campo NZQ_ADIANT e ajusta ordem do campo

@author Jonatas Martins
@since  06/06/2023
/*/
//-------------------------------------------------------------------------
Function JPFS16035()
Local cUpdate := ""
Local nPosCpo := Val(GetSx3Cache("NZQ_NOMRES", "X3_ORDEM"))

	AtuOrdem("NZQ", nPosCpo + 1, "NZQ_ADIANT")

	// Realiza ajuste na base, para que todos os casos tenham o campo novo preenchido.
	cUpdate := " UPDATE " + RetSqlName("NZQ")
	cUpdate +=    " SET NZQ_ADIANT = '2'"
	cUpdate +=  " WHERE NZQ_ADIANT = ' '"
	cUpdate +=    " AND D_E_L_E_T_ = ' '"
	TcSqlExec(cUpdate)

Return Nil