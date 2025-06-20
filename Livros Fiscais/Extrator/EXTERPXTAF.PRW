#Include "Protheus.ch"
#Include "TOPCONN.ch"
#Include "FWCOMMAND.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ExtMainDipj
Fun��o Main para chamada de gera��o dos Blocos da DIPJ/ECF - Extrator TAF, utilizada
pelo Extrator Cont�bil

@Param cFil        = C�digo da filial que ser� gravada na TAFFIL
		cTicket     = Numero do Ticket a ser gravado na TAFST1 
		aReg        = Registros que desejam  { 'T118', 'T111', etc... } 
		dDataDe     = Data Inicio ( Formato DDMMAAAA )
		dDataAte    = Data Final ( Formato DDMMAAAA )
		aFiliais    = array com as filiais a serem consideradas no processamento( 1 = CGC, 2 = C�digo Empresa, 3 = codigo da filial )
		cNrLivro    = Numero do livro
		lVndaPjExp  = PJ Efetuou Vendas a Comercial Exportadora - Preencha com 0-Nao, 1-Sim"
		lPjComExp   = PJ Comercial Exportadora - Preencha com 0-Nao, 1-Sim"
		cTpExp      = Wizard Extrator ( Tipo das Exportacoes - 01 - Bens ; 02 - Servi�os ; 03 - Direitos ; 04 - Operacoes Financeiras ; 05 - N�o Especificadas )
		cMetodo     = Wizard Extrator ( Metodo - 1 - PVE ; 2 - PVA ; 3- PVV ; 4-CAP ; 5-PECEx )
		cTpImp      = Wizard Extrator ( Tipo das Importacoes - 01 - Bens ; 02 - Servi�os ; 03 - Direitos ; 04 - Operacoes Financeiras ; 05 - N�o Especificadas )
		cAlterCap   = Alteracao de capital ? ( 0 - N�o Preenchido, 1 - Sim, 2 - N�o )
		cEscBcCsll  = Opcao escrit. no ativo, da base de calculo negativa da CSLL ( 0 - N�o preenchido, 1 - N�o, 2 - Sim )
		cPessoaVinc = '1' - Possui operacoes com Pessoa vinculada, '2' - Possui operacoes com Pessoa nao vinculada 
		dDtaEntQS   = Data de Entrada no Quadro Societ�rio ( Incluir op��o no par�metro MV_REGSOC )
		dDtaSaiQS   = Data de Sa�da do Quadro Societ�rio  ( Incluir op��o no par�metro MV_REGSOC ) 

@author Rodrigo Aguilar
@since 05/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------

function ECFInfoEcon( cFil, cTicket, aReg , dDataDe , dDataAte, aFiliais, cNrLivro, lVndaPjExp, lPjComExp,;
						 cTpExp, cMetodoExp, cMetodoImp, cTpImp, cAlterCap, cEscBcCsll, cPessoaVinc, nMedSelic, aFilY540, lCentraliz )
	
private cFilProc    := cFil
private cTicketProc := cTicket	
Default aFilY540    := { }
Default lCentraliz  := .F.

ExtMainDipj( aReg , dDataDe , dDataAte, aFiliais, cNrLivro, lVndaPjExp, lPjComExp, +;
						 cTpExp, cMetodoExp, cMetodoImp, cTpImp, cAlterCap, cEscBcCsll, cPessoaVinc, nMedSelic, aFilY540, lCentraliz )

return ( nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} ExtMainDipj
Fun��o Main para chamada de gera��o dos Blocos da DIPJ - Extrator TAF

@Param 	aReg       = Registros que desejam  { 'T118', 'T111', etc... } 
		dDataDe    = Data Inicio ( Formato DDMMAAAA )
		dDataAte   = Data Final ( Formato DDMMAAAA )
		aFiliais   = array com as filiais a serem consideradas no processamento( 1 = CGC, 2 = C�digo Empresa, 3 = codigo da filial )
		cNrLivro   = Numero do livro
		lVndaPjExp = PJ Efetuou Vendas a Comercial Exportadora - Preencha com 0-Nao, 1-Sim"
		lPjComExp  = PJ Comercial Exportadora - Preencha com 0-Nao, 1-Sim"
		cTpExp     = Wizard Extrator ( Tipo das Exportacoes - 01 - Bens ; 02 - Servi�os ; 03 - Direitos ; 04 - Operacoes Financeiras ; 05 - N�o Especificadas )
		cMetodo    = Wizard Extrator ( Metodo - PVE ; PVA ; PVV ; CAP ; PECEx )
		cTpImp     = Wizard Extrator ( Tipo das Importacoes - 01 - Bens ; 02 - Servi�os ; 03 - Direitos ; 04 - Operacoes Financeiras ; 05 - N�o Especificadas )
		cAlterCap  = Alteracao de capital ? ( 0 - N�o Preenchido, 1 - Sim, 2 - N�o )
		cEscBcCsll = Opcao escrit. no ativo, da base de calculo negativa da CSLL ( 0 - N�o preenchido, 1 - N�o, 2 - Sim )

@author Rodrigo Aguilar
@since 05/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
function ExtMainDipj( aReg , dDataDe , dDataAte, aFiliais, cNrLivro, lVndaPjExp, lPjComExp,;
						 cTpExp, cMetodoExp, cMetodoImp, cTpImp, cAlterCap, cEscBcCsll, cPessoaVinc, nMedSelic, aFilY540, lCentraliz )

local cArqMerc   := ''
local cArqDado   := ''
local cArqRem    := ''

local cPrdAcum	:= ''

local nForFilial := 0
Local nX         := 0

local aEnt       := { {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0} }
local aSai       := { {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0} }
local aRegT108   := {}
local aEmpAux	 := {}
Local aAuxY540   := { }

local lDipiArq   := ( ExistBlock( 'DIPIARQ' ) )

Default aFilY540 := { }
Default lCentraliz := .F.

//Guardo a filial corrente que esta logado para restaurar no final do processo
aAdd( aEmpAux , { cEmpAnt , cFilAnt } )

//Executo todas as filiais
for nForFilial := 1 to  len( aFiliais )
	
	//Seto empresa e filial para processamento
	cEmpAnt := aFiliais[ nForFilial, 2 ]
	cFilAnt := aFiliais[ nForFilial, 3 ] 
			
	//Alimento tabela tempor�ria referemente ao resumo do per�odo, dentro da fun��o A975Resumo a variavel cFilAnt
	//� alimentada com o valor da filial corrente			  		
	if aScan( aReg, { |x| x $ 'T105|T106|T107' } ) > 0
		//Alimento tabela tempor�ria referemente aos movimentos do per�odo, dentro da fun��o A975Moviment a variavel cFilAnt
		//� alimentada com o valor da filial corrente
		if lDipiArq
			cArqDado := ExecBlock( 'DIPIARQ', .F., .F. )
		else	
			cArqDado := A975Moviment( , , cNrLivro, dDataDe, dDataAte, .F.,,.T. )
		endif
		//Alimento os arquivos tempor�rios necess�rios para gera��o dos eventos
		cArqRem  := a975CriaRem()
		cArqMerc := a975CriaMerc()
		cPrdAcum := a975PrdAcum()

		A975Resumo( cArqDado, cArqRem, cArqMerc, cPrdAcum, aEnt, aSai, ,Year( dDataDe ),.T. )	   	
	EndIf	
	
	//Registros do Transfer Price
	DIPJTransferPrice( dDataDe , dDataAte , aReg , cTpExp , cMetodoExp, cMetodoImp, cPessoaVinc, cTpImp, nMedSelic )
	cFilAnt := aFiliais[ nForFilial, 3] //Reposiciono a Filial em execu��o
	SM0->(MsSeek(cEmpAnt+cFilAnt,.T.))
	
	//Realiza a grava��o do registro T105
	if aScan( aReg, { |x| x == 'T105' } ) > 0
	
		// -------------------------
		// Opera��es com o Exterior - Exporta��es (Entradas de Divisas)
		// - DIPJ: R30 / R31
		// - ECF: X300 / X310
		// - Layout TOTVS: T097 / T097AA
		// -------------------------		
		ExtT105( cArqMerc, dDataAte, dDataDe )
	endif

	//Realiza a grava��o do registro T106
	if aScan( aReg, { |x| x == 'T106' } ) > 0
		ExtT106( cArqMerc, dDataAte, lVndaPjExp )
	endif

	//Realiza a grava��o do registro T107
	if aScan( aReg, { |x| x == 'T107' } ) > 0
		ExtT107( cArqMerc, dDataDe, dDataAte, lPjComExp )
	endif
	
	//Realiza a grava��o do registro T111
	if aScan( aReg, { |x| x == 'T111' } ) > 0
		ExtT111( dDataAte )
	endif	
	
	//Realiza a grava��o do registro T118
	if aScan( aReg, { |x| x == 'T118' } ) > 0
		ExtT118( dDataAte, cAlterCap, cEscBcCsll )
	endif
	if aScan( aReg, { |x| x $ 'T105|T106|T107' } ) > 0
		( cArqDado )->( DBCloseArea() )
		FErase( cArqDado + GetDBExtension() )
		FErase( cArqDado + OrdBagExt() )
	
		( cArqRem )->( DBCloseArea() )
		FErase( cArqRem + GetDBExtension() )
		FErase( SubStr( cArqRem, 1, 7 ) + "A" + OrdBagExt() )
		FErase( SubStr( cArqRem, 1, 7 ) + "B" + OrdBagExt() )
		FErase( SubStr( cArqRem, 1, 7 ) + "C" + OrdBagExt() )

		( cArqMerc )->( DBCloseArea() )
		FErase( cArqMerc + GetDBExtension() )
		FErase( SubStr( cArqMerc, 1, 7 ) + "D" + OrdBagExt() )
		FErase( SubStr( cArqMerc, 1, 7 ) + "E" + OrdBagExt() )

		( cPrdAcum )->( DBCloseArea() )
		FErase( cPrdAcum + GetDBExtension() )
		FErase( SubStr( cPrdAcum, 1, 7 ) + "F" + OrdBagExt() )
		FErase( SubStr( cPrdAcum, 1, 7 ) + "G" + OrdBagExt() )
	EndIf
next

/*
	Se a escritura��o do tipo "Com centraliza��o" e o usu�rio tenha selecionado as filiais para o Y540 da DIPJ ( layout T105 ), 
	alimento array aAuxY540 que ser� utilizado na gera��o do registro.

	Exemplo de como o array aFilY540 � preenchido e as informa��es que s�o utilizadas:

	aFilY540[11][1]:.T.  -> MarkBrowse
	aFilY540[11][2]:"T1" -> Empresa
	aFilY540[11][3]:"X CT101     " -> Filial
	aFilY540[11][4]:"TOTVS S.A - FILIAL 01                                       "
	aFilY540[11][5]:"53113791000122" -> CNPJ
	aFilY540[11][6]:"E"
	aFilY540[11][7]:"Grupo TOTVS 1                           "

*/

If ( aScan( aReg, { |x| x == 'T105' } ) > 0 ) .and. ( lCentraliz ) .and. ( !Empty( aFilY540 ) )

	For nX := 1 To Len( aFilY540 )

		/* Valido se a Filial selecionada � a centralizadora que j� foi adicionada no array aFiliais
			evitando assim gerar o Y540 duas vezes para a mesma filial
		*/
		nPos := aScan( aFiliais, {|x| Alltrim( x[3] ) == Alltrim(  aFilY540[nX,3] ) } )

		// Valido se a filial foi selecionada 
		If aFilY540[nX,1] .and. ( nPos == 0 ) 
			aadd( aAuxY540, { aFilY540[nX,5], aFilY540[nX,2], aFilY540[nX,3] } )
		EndIf

	Next nX

	for nForFilial := 1 to Len( aAuxY540 )

		//Seto empresa e filial para processamento
		cEmpAnt := aAuxY540[ nForFilial, 2 ]
		cFilAnt := aAuxY540[ nForFilial, 3 ] 
				
		//Alimento tabela tempor�ria referemente aos movimentos do per�odo, dentro da fun��o A975Moviment a variavel cFilAnt
		//� alimentada com o valor da filial corrente
		if lDipiArq
			cArqDado := ExecBlock( 'DIPIARQ', .F., .F. )			
		else	
			cArqDado := A975Moviment( , , cNrLivro, dDataDe, dDataAte, .F.,,.T. )			
		endif
			
		//Alimento os arquivos tempor�rios necess�rios para gera��o dos eventos
		cArqMerc := a975CriaMerc()
		
		//Alimento tabela tempor�ria referemente ao resumo do per�odo, dentro da fun��o A975Resumo a variavel cFilAnt
		//� alimentada com o valor da filial corrente			  		
		A975Resumo( cArqDado, /*cArqRem*/, cArqMerc, /*cPrdAcum*/, aEnt, aSai, ,Year( dDataDe ),.T. )
		
		cFilAnt := aAuxY540[ nForFilial, 3] //Reposiciono a Filial em execu��o
		SM0->(MsSeek(cEmpAnt+cFilAnt,.T.))
		
		//Realiza a grava��o do registro T105
		// -------------------------
		// Opera��es com o Exterior - Exporta��es (Entradas de Divisas)
		// - DIPJ: R30 / R31
		// - ECF: X300 / X310
		// - Layout TOTVS: T097 / T097AA
		// -------------------------		
		ExtT105( cArqMerc, dDataAte, dDataDe )

		( cArqDado )->( DBCloseArea() )
		FErase( cArqDado + GetDBExtension() )
		FErase( cArqDado + OrdBagExt() )

		( cArqMerc )->( DBCloseArea() )
		FErase( cArqMerc + GetDBExtension() )
		FErase( SubStr( cArqMerc, 1, 7 ) + "D" + OrdBagExt() )
		FErase( SubStr( cArqMerc, 1, 7 ) + "E" + OrdBagExt() )

	next

EndIf

if aScan( aReg, { |x| x == 'T108' } ) > 0 
	
	//Para geracao do registro T108, utilizo a funcao do fonte MATA975 que eh executada para todas as filiais.
	//Por isso esta fora do laco de filiais acima, que eh utilizado para os demais registros.
	aRegT108	:=	MTA97550( aFiliais , .F. , .T., dDataDe, dDataAte )
	
	if len( aRegT108 ) > 0
		ExtT108( aRegT108 , dDataAte )
	endif
	
endif

//Restauro a filial que estava logado no inicio do processo
SM0->( MsSeek( aEmpAux[ 1 , 1 ] + aEmpAux[ 1 , 2 ] , .T. ) )

cFilAnt	:=	FWGETCODFILIAL

return ( nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} DIPJTransferPrice

@author Luccas Curcio
@since 05/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
static function DIPJTransferPrice( dDataDe , dDataAte , aReg , cTpExp , cMetodoExp, cMetodoImp, cPessoaVinc, cTpImp, nMedSelic )

local	aTempFile	:=	R933CriaArq()

local	aTotal		:=	{}
local	aTotalProd	:=	{}

//chamada da funcao R933CriaArq ( MATR933 ) para montar os arquivos de trabalho 
if len( aTempFile ) > 0
	
	//Monta dois arquivos de trabalho: SAI e ENT. Serao utilizados na geracao dos registros no Layout TOTVS
	R933Transfer( .F. , , , , dDataDe , dDataAte , .T. , @aTotal , @aTotalProd, .T., nMedSelic )
	
	// -----------------------------------------------------------------
	// Registros gerados no Layout TOTVS com base no Transfer Price.
	// -----------------------------------------------------------------
	
	// ------------------------------------------------------------------------------------------------
	// Opera��es com o Exterior - Pessoa Vinculada/Interposta/Pa�s com Tributa��o Favorecida
	// - DIPJ: R29A
	// - ECF: X291
	// - Layout TOTVS: T096 ( Generico )
	// ------------------------------------------------------------------------------------------------
	// Opera��es com o Exterior - Pessoa N�o Vinculada/N�o Interposta/Pa�s sem Tributa��o Favorecida
	// - DIPJ: R29B
	// - ECF: X292
	// - Layout TOTVS: T096 ( Generico )
	// ------------------------------------------------------------------------------------------------
	
	//Realiza a grava��o do registro T096
	if aScan( aReg, { |x| x == 'T096' } ) > 0
		ExtT096( cPessoaVinc , dDataAte )
	endif
	
	// -------------------------
	// Opera��es com o Exterior - Exporta��es (Entradas de Divisas)
	// Opera��es com o Exterior - Contratantes das Exporta��es
	// - DIPJ: R30 / R31
	// - ECF: X300 / X310
	// - Layout TOTVS: T097 / T097AA
	// -------------------------
	
	//Realiza a grava��o do registro T097
	if aScan( aReg, { |x| x == 'T097' } ) > 0
		ExtT097( cPessoaVinc , cTpExp , cMetodoExp , dDataAte, aTotalProd, aTotal )
	endif
	
	// -------------------------
	// Opera��es com o Exterior - Importa��es (Sa�da de Divisas)
	// Opera��es com o Exterior - Contratantes das Importa��es
	// - DIPJ: R32 / R33
	// - ECF: X320 / X330
	// - Layout TOTVS: T098 / T098AA
	// -------------------------
	
	//Realiza a grava��o do registro T098
	if aScan( aReg, { |x| x == 'T098' } ) > 0
		ExtT098( cTpImp , cMetodoImp , dDataAte, aTotalProd, aTotal )
	endif

	//Verifico se o arquivo de trabalho que pe aberto em R933Transfer j� esta sendo usado, se sim,
	//finalizo antes de chamar a fun��o
	ENT->( dbCloseArea () )
	SAI->( dbCloseArea () )
				
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} ECFParseDIPJ

@Return

@author Luccas Curcio
@since 05/09/2015
@version  

/*/
//-------------------------------------------------------------------
function ECFParseDIPJ( cContent, cOrdem )

default cOrdem := ''

CommitST1( cContent, cOrdem )

return

//-------------------------------------------------------------------
/*/{Protheus.doc} CommitST1

@Param cMsg - Mensagem para grava��o na tabela TAFST1

@author Luccas Curcio / Rodrigo Aguilar
@since 05/09/2015
@version  

/*/
//-------------------------------------------------------------------
function CommitST1( cMsg, cOrdem )

local cAlias := 'TAFST1'
local cReg   := SubStr( cMsg, 2, 4 )
local cSeq   := '001'
local cKey   := ''
local cBanco	:=	Upper( AllTrim( TcGetDB() ) )

//Tratamento para adicionar o Pipe ( '|' ) ao final da string de linha do texto
//pois o comando TCSQLExec est� inserindo informa��es sem o �ltimo caracter em ORACLE
If cBanco == "ORACLE"
	cMsg += "|"
EndIf

//Retirada dos Pipes para os Leiautes Espec�ficos, pois na integra��o os registros eram exclu�dos indevidamente.
if cReg $ ("T108|T111")
	cKey := AllTrim(SubStr(StrTran(StrTran(StrTran(StrTran(StrTran(AllTrim(cMsg),"|",""),",","")," ",""),"-",""),"&",""),1,82)+"-"+dtoS(Date())+StrTran(StrTran(TimeFull(),":",""),".",""))
else
	cKey := cReg + dtoS( Date() ) + StrTran( Time(), ":", "" ) + cMsg
endif

recLock( cAlias , .T. )
	TAFST1->TAFFIL	  := cFilProc
	TAFST1->TAFCODMSG := '1'
	TAFST1->TAFSEQ	  := cSeq
	TAFST1->TAFTPREG  := cReg
	TAFST1->TAFKEY	  := cKey
	TAFST1->TAFMSG	  := cMsg
	TAFST1->TAFSTATUS := '1'
	TAFST1->TAFDATA	  := dDataBase
	TAFST1->TAFHORA	  := Time()
	TAFST1->TAFTICKET := cTicketProc
msUnLock()

dbCommit()

return ( nil )
