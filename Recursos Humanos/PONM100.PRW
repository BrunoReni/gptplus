#INCLUDE "TOTVS.CH"
#INCLUDE "PONM100.CH"

/*/{Protheus.doc} PONM100
Realiza a reabertura do banco de horas
@type  Function
@author C�cero Alves
@since 17/03/2023
@see (links_or_references)
/*/
Function PONM100()
	
	Local cDescricao := STR0001 // "Essa rotina realiza a reabertura do Banco de Horas para eventos que foram baixados durante o per�odo de apontamento atual."
	
	Private oArqSPI
	Private oArqSPB
	Private oArqRGB
	Private aLogs := {}
	Private aLogTitle := {}
	Private lBlind := IsBlind()
	
	If !fExistPerg("PONM100")
		// "Funcionalidade n�o dispon�vel para esta vers�o do sistema."
		Help(,, "Help",, STR0002, 1, 0,,,,,, {STR0003}) // "Para utilizar a rotina de Reabertura do Banco de Horas � necess�rio atualizar o sistema."
		Return
	EndIf
	
	Pergunte("PONM100", .F.)
	
	tNewProcess():New( "PONM100", STR0004, {|oSelf| PNM100Proc(oSelf) }, cDescricao, "PONM100",,,,,, .T.) // "Reabertura do Banco de Horas"
	
	LimpaObj()
	
	MsAguarde( { || fMakeLog( aLogs, aLogTitle, "PONM100", !lBlind, "PONM100", STR0005 )}, STR0006 ) // "Resumo das Altera��es" - Gerando log...
	
Return

/*/{Protheus.doc} PNM100Proc
Filtra as informa��es conforme os par�metros selecionados e apresenta uma tela
@type  Static Function
@author C�cero Alves
@since 17/03/2023
@param oProcess, Objeto, Intancia da classe tnewProcess
/*/
Static Function PNM100Proc(oProcess)
	
	Local aSRAColumns	:= {}
	Local aSPIColumns	:= {}
	Local aSPBColumns	:= {}
	Local aRGBColumns	:= {}
	Local aCoors 		:= FWGetDialogSize( oMainWnd )
	
	Private cAliasSRA := GetNextAlias()
	Private cAliasSPI := GetNextAlias()
	Private cAliasSPB := GetNextAlias()
	Private cAliasRGB := GetNextAlias()
	Private oDlgPrinc, oFWLayer, oPanelUp, oPanelSPI, oPanelSPB, oPanelRGB, oRelacSPI, oRelacSPB, oRelacRGB, oBrowseRGB, oBrowseSPI, oBrowseSRA, oBrowseSPB
	
	// Cria as tabelas tempor�rias
	aSPIColumns := CriaTmpSPI(cAliasSPI)
	aSPBColumns := CriaTmpSPB(cAliasSPB)
	aRGBColumns := CriaTmpRGB(cAliasRGB)
	If !CriaTmpSRA(cAliasSRA, @aSRAColumns)
		// "Nenhum funcion�rio encontrado"
		Help(,, "Help",, STR0020, 1, 0,,,,,, {STR0021}) //"Nenhum funcion�rio foi encontrado com os filtros informados, o sistema busca por funcion�rios que tenham banco de horas baixado dentro do per�odo atual de apontamento."
		Return
	EndIf
	
	
	Define MsDialog oDlgPrinc Title STR0004 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )
	oFWLayer:AddLine( "FUNCIONARIOS", 40, .F. )
	oFWLayer:AddCollumn( "ALL", 100, .T., "FUNCIONARIOS" )
	oPanelUp := oFWLayer:GetColPanel( 'ALL', "FUNCIONARIOS" )
	
	oFWLayer:AddLine( "BANCO", 30, .F. )
	oFWLayer:AddCollumn( "EVENTOS", 100, .T., "BANCO" )
	oPanelSPI := oFWLayer:GetColPanel( "EVENTOS", "BANCO" )
	
	oFWLayer:AddLine( "VERBAS", 30, .F. )
	oFWLayer:AddCollumn( "RESULTADOS" , 50, .T., "VERBAS" )
	oFWLayer:AddCollumn( "FOLHA", 50, .T., "VERBAS" )
	
	oPanelSPB := oFWLayer:GetColPanel( "RESULTADOS" , "VERBAS" )
	oPanelRGB := oFWLayer:GetColPanel( "FOLHA", "VERBAS" )
	
	//-- Funcion�rios
	oBrowseSRA:= FWMarkBrowse():New()
	oBrowseSRA:SetOwner( oPanelUp )
	oBrowseSRA:SetDescription( STR0007 ) // "Funcion�rios"
	oBrowseSRA:SetMenuDef( '' )
	oBrowseSRA:ForceQuitButton()
	oBrowseSRA:SetAlias( cAliasSRA )
	oBrowseSRA:SetColumns(aSRAColumns)
	oBrowseSRA:SetFieldMark("OK")
	oBrowseSRA:SetProfileID( '1' )
	oBrowseSRA:SetTemporary(.T.)
	oBrowseSRA:DisableReport()
	oBrowseSRA:AddButton(STR0008, {|| oDlgPrinc:End()}, , 1, 0) // "Cancelar"
	oBrowseSRA:AddButton(STR0009, {|| fGrava(), oDlgPrinc:End()}, , 4, 0) // "Confirmar"
	oBrowseSRA:SetAfterMark({|| MarkOthers() })
	oBrowseSRA:SetAllMark({|| })
	oBrowseSRA:Activate()
	lAtualiza := .F. // Controle para a fun��o de marca��o do funcion�rio
	oBrowseSRA:AllMark() // Marca todos os registros
	
	//-- Banco de Horas
	oBrowseSPI:= FWMarkBrowse():New()
	oBrowseSPI:SetOwner( oPanelSPI )
	oBrowseSPI:SetDescription( STR0010 ) // "Banco de Horas"
	oBrowseSPI:SetMenuDef( '' )
	oBrowseSPI:DisableDetails()
	oBrowseSPI:SetAlias( cAliasSPI )
	oBrowseSPI:SetColumns(aSPIColumns)
	oBrowseSPI:SetFieldMark("OK")
	oBrowseSPI:SetProfileID( '2' )
	oBrowseSPI:SetTemporary(.T.)
	oBrowseSPI:DisableConfig()
	oBrowseSPI:DisableReport()
	oBrowseSPI:SetValid({|| (cAliasSRA)->(!Empty(OK)) .Or. lSRANMark })
	oBrowseSPI:Activate()
	oBrowseSPI:AllMark() // Marca todos os registros
	
	//-- Resultados
	oBrowseSPB := FWMarkBrowse():New()
	oBrowseSPB:SetOwner( oPanelSPB )
	oBrowseSPB:SetDescription( STR0011 ) // "Resultados"
	oBrowseSPB:SetMenuDef( '' )
	oBrowseSPB:DisableDetails()
	oBrowseSPB:SetAlias( cAliasSPB )
	oBrowseSPB:SetColumns(aSPBColumns)
	oBrowseSPB:SetFieldMark("OK")
	oBrowseSPB:SetProfileID( '3' )
	oBrowseSPB:SetTemporary(.T.)
	oBrowseSPB:DisableConfig()
	oBrowseSPB:DisableReport()
	oBrowseSPB:SetValid({|| (cAliasSRA)->(!Empty(OK)) .Or. lSRANMark })
	oBrowseSPB:Activate()
	oBrowseSPB:AllMark() // Marca todos os registros
	
	//-- Lan�amentos mensais
	oBrowseRGB:= FWMarkBrowse():New()
	oBrowseRGB:SetOwner( oPanelRGB )
	oBrowseRGB:SetDescription( STR0012 ) // "Lan�amentos Mensais - Folha"
	oBrowseRGB:SetMenuDef( '' )
	oBrowseRGB:DisableDetails()
	oBrowseRGB:SetAlias( cAliasRGB )
	oBrowseRGB:SetColumns(aRGBColumns)
	oBrowseRGB:SetFieldMark("OK")
	oBrowseRGB:SetProfileID( '4' )
	oBrowseRGB:SetTemporary(.T.)
	oBrowseRGB:DisableConfig()
	oBrowseRGB:DisableReport()
	oBrowseRGB:SetValid({|| (cAliasSRA)->(!Empty(OK)) .Or. lSRANMark })
	oBrowseRGB:Activate()
	oBrowseRGB:AllMark() // Marca todos os registros
	
	//Relacionamento funcin�rio - Banco de Horas
	oRelacSPI := FWBrwRelation():New()
	oRelacSPI:AddRelation( oBrowseSRA, oBrowseSPI, {{ "PI_FILIAL", "RA_FILIAL"}, {"PI_MAT", "RA_MAT"}})
	oRelacSPI:Activate()
	
	//Relacionamento funcin�rio - Resultados
	oRelacSPB := FWBrwRelation():New()
	oRelacSPB:AddRelation( oBrowseSRA, oBrowseSPB, {{ "PB_FILIAL", "RA_FILIAL"}, {"PB_MAT", "RA_MAT"}})
	oRelacSPB:Activate()
	
	//Relacionamento funcin�rio - Lan�amentos mensais
	oRelacRGB := FWBrwRelation():New()
	oRelacRGB:AddRelation( oBrowseSRA, oBrowseRGB, {{ "RGB_FILIAL", "RA_FILIAL"}, {"RGB_MAT", "RA_MAT"}})
	oRelacRGB:Activate()
	
	// Controle para a fun��o de marca��o do funcion�rio
	lAtualiza := .T.
	
	Activate MsDialog oDlgPrinc Center
	
Return NIL

/*/{Protheus.doc} CriaTmpSPI
Cria uma tabela tempor�ria com as informa��es do banco de horas e cria as colunas que ser�o apresentadas em tela
@type  Static Function
@author C�cero Alves
@since 20/03/2023
@param cAliasSPI, Caractere, Alias utilizado na tabela tempor�ria
@return aColumnSPI, Array, Colunas que ser�o apresentadas em tela
/*/
Static Function CriaTmpSPI(cAliasSPI)
	
	Local aCamposSPI	:= {"PI_FILIAL", "PI_MAT", "PI_DATA", "PI_PD", "PI_DESC", "PI_CC", "PI_QUANT", "PI_QUANTV", "PI_STATUS", "PI_DTBAIX"}
	Local aColumnSPI	:= {}
	Local aStructSPI	:= {}
	Local aLstIndices	:= {}
	Local cSQLAlias		:= GetNextAlias()
	Local dPerIni		:= cTod("//")
	Local dPerFim		:= cTod("//")
	Local cLastFil		:= "***"
	Local cWhere		:= GetSRAWhere()
	
	Default cAliasSPI := GetNextAlias()
	
	cWhere := "%" + cWhere + "%"
	
	aAdd( aStructSPI, { "OK"		, "C", 2					 , 0 } )
	aAdd( aStructSPI, { "PI_FILIAL"	, "C", FwGetTamFilial		 , 0 } )
	aAdd( aStructSPI, { "PI_MAT"	, "C", TamSX3("PI_MAT")[1]	 , 0 } )
	aAdd( aStructSPI, { "PI_DATA"	, "D", 8					 , 0 } )
	aAdd( aStructSPI, { "PI_PD"		, "C", TamSX3("PI_PD")[1]	 , TamSX3("PI_PD")[2] })
	aAdd( aStructSPI, { "PI_DESC"	, "C", 30					 , 0 } )
	aAdd( aStructSPI, { "PI_CC"  	, "C", TamSX3("PI_CC")[1]	 , 0 } )
	aAdd( aStructSPI, { "PI_QUANT" 	, "N", TamSX3("PI_QUANT")[1] , TamSX3("PI_QUANT")[2] })
	aAdd( aStructSPI, { "PI_QUANTV"	, "N", TamSX3("PI_QUANTV")[1], TamSX3("PI_QUANTV")[2] })
	aAdd( aStructSPI, { "PI_STATUS"	, "C", 1					 , 0 } )
	aAdd( aStructSPI, { "PI_DTBAIX"	, "D", 8					 , 0 } )
	aAdd( aStructSPI, { "RECNO"		, "N", 16					 , 0 } )
	
	aAdd( aLstIndices, { "PI_FILIAL", "PI_MAT" } )
	
	oArqSPI := RhCriaTrab(cAliasSPI, aStructSPI, aLstIndices)
	
	BeginSQL ALIAS cSQLAlias
		COLUMN PI_DATA AS DATE
		COLUMN PI_DTBAIX AS DATE
		SELECT PI_FILIAL, PI_MAT, PI_DATA, PI_PD, PI_CC, PI_QUANT, PI_QUANTV, PI_STATUS, PI_DTBAIX, SPI.R_E_C_N_O_ RECNO
		FROM %Table:SPI% SPI
		LEFT JOIN %Table:SRA% SRA 
		ON SPI.PI_FILIAL = SRA.RA_FILIAL AND 
		SPI.PI_MAT = SRA.RA_MAT
		WHERE 
		SPI.PI_STATUS = 'B' AND 
		SPI.%NotDel% AND 
		%Exp:cWhere%
		ORDER BY PI_FILIAL, PI_MAT
	EndSQL
	
	While (cSQLAlias)->(!EoF())
		
		If !(cSQLAlias)->PI_FILIAL == cLastFil
			cLastFil := (cSQLAlias)->PI_FILIAL
			GetPonMesDat( @dPerIni, @dPerFim, cLastFil )
		EndIf
		
		If (cSQLAlias)->PI_DTBAIX < dPerIni .Or. (cSQLAlias)->PI_DTBAIX > dPerFim
			(cSQLAlias)->(dbSkip())
			LOOP
		EndIf
		
		RecLock(cAliasSPI, .T.)
			(cAliasSPI)->OK			:= ""
			(cAliasSPI)->PI_FILIAL 	:= (cSQLAlias)->PI_FILIAL
			(cAliasSPI)->PI_MAT 	:= (cSQLAlias)->PI_MAT
			(cAliasSPI)->PI_DATA	:= (cSQLAlias)->PI_DATA
			(cAliasSPI)->PI_PD 		:= (cSQLAlias)->PI_PD
			(cAliasSPI)->PI_DESC   	:= (cSQLAlias)->(PosSP9( PI_PD, PI_FILIAL, "P9_DESC", 1, .F.))
			(cAliasSPI)->PI_CC		:= (cSQLAlias)->PI_CC
			(cAliasSPI)->PI_QUANT	:= (cSQLAlias)->PI_QUANT
			(cAliasSPI)->PI_QUANTV	:= (cSQLAlias)->PI_QUANTV
			(cAliasSPI)->PI_STATUS	:= (cSQLAlias)->PI_STATUS
			(cAliasSPI)->PI_DTBAIX	:= (cSQLAlias)->PI_DTBAIX
			(cAliasSPI)->RECNO		:= (cSQLAlias)->RECNO
		(cAliasSPI)->(MsUnlock())
		
		(cSQLAlias)->(dbSkip())
	EndDo
	
	(cSQLAlias)->(dbCloseArea())
	
	//Cria as colunas para o Browse
	GetColumns(aCamposSPI, @aColumnSPI)
	
Return aColumnSPI

/*/{Protheus.doc} CriaTmpSPB
Cria uma tabela tempor�ria com as informa��es do resultados do ponto e cria as colunas que ser�o apresentadas em tela
@type  Static Function
@author C�cero Alves
@since 20/03/2023
@param cAliasSPB, Caractere, Alias utilizado na tabela tempor�ria
@return aColumnSPB, Array, Colunas que ser�o apresentadas em tela
/*/
Static Function CriaTmpSPB(cAliasSPB)
	
	Local aCamposSPB	:= {"PB_FILIAL", "PB_MAT", "PB_PD", "PB_DESCPD", "PB_TIPO1", "PB_HORAS", "PB_VALOR", "PB_DATA", "PB_CC"}
	Local aColumnSPB	:= {}
	Local aStructSPB	:= {}
	Local aLstIndices	:= {}
	Local cSQLAlias		:= GetNextAlias()
	Local dPerIni		:= cTod("//")
	Local dPerFim		:= cTod("//")
	Local cLastFil		:= "***"
	Local cWhere		:= GetSRAWhere()
	Local cJoin			:= "%" + FWJoinFilial("SPB", "SP9") + "%"
	
	Default cAliasSPB := GetNextAlias()
	
	// Monta a estrutura da tabela tempor�ria 
	aAdd( aStructSPB, { "OK"		, "C", 2					 , 0 } )
	aAdd( aStructSPB, { "PB_FILIAL"	, "C", FwGetTamFilial		 , 0 } )
	aAdd( aStructSPB, { "PB_MAT"	, "C", TamSX3("PB_MAT")[1]	 , 0 } )
	aAdd( aStructSPB, { "PB_DATA"	, "D", 8					 , 0 } )
	aAdd( aStructSPB, { "PB_PD"		, "C", TamSX3("PB_PD")[1]	 , TamSX3("PB_PD")[2] })
	aAdd( aStructSPB, { "PB_DESCPD ", "C", 30					 , 0 } )
	aAdd( aStructSPB, { "PB_CC"  	, "C", TamSX3("PB_CC")[1]	 , 0 } )
	aAdd( aStructSPB, { "PB_HORAS" 	, "N", TamSX3("PB_HORAS")[1] , TamSX3("PB_HORAS")[2] })
	aAdd( aStructSPB, { "PB_VALOR"	, "N", TamSX3("PB_VALOR")[1], TamSX3("PB_VALOR")[2] })
	aAdd( aStructSPB, { "PB_TIPO1"	, "C", 1					 , 0 } )
	aAdd( aStructSPB, { "RECNO"		, "N", 16					 , 0 } )
	
	aAdd( aLstIndices, { "PB_FILIAL", "PB_MAT" } )
	
	oArqSPB := RhCriaTrab(cAliasSPB, aStructSPB, aLstIndices)
	
	cWhere := "%" + cWhere + "%"
	
	BeginSQL ALIAS cSQLAlias
		COLUMN PB_DATA AS DATE
		SELECT PB_FILIAL, PB_MAT, PB_PD, PB_TIPO1, PB_HORAS, PB_VALOR, PB_DATA, PB_CC, SPB.R_E_C_N_O_ RECNO
		FROM %Table:SPB% SPB
		LEFT JOIN %Table:SP9% SP9 
		ON PB_PD = P9_CODFOL AND 
		%Exp:cJoin%
		LEFT JOIN %Table:SRA% SRA 
		ON SPB.PB_FILIAL = SRA.RA_FILIAL AND 
		SPB.PB_MAT = SRA.RA_MAT
		WHERE 
		SP9.P9_IDPON IN ('023A', '024A', '042A') AND 
		SP9.%NotDel% AND
		SPB.%NotDel% AND
		%Exp:cWhere%
		ORDER BY PB_FILIAL, PB_MAT
	EndSQL
	
	While (cSQLAlias)->(!EoF())
		
		If !(cSQLAlias)->PB_FILIAL == cLastFil
			cLastFil := (cSQLAlias)->PB_FILIAL
			GetPonMesDat( @dPerIni, @dPerFim, cLastFil )
		EndIf
		
		If (cSQLAlias)->PB_DATA < dPerIni .Or. (cSQLAlias)->PB_DATA > dPerFim
			(cSQLAlias)->(dbSkip())
			LOOP
		EndIf
		
		RecLock(cAliasSPB, .T.)
			(cAliasSPB)->OK			:= ""
			(cAliasSPB)->PB_FILIAL 	:= (cSQLAlias)->PB_FILIAL
			(cAliasSPB)->PB_MAT 	:= (cSQLAlias)->PB_MAT
			(cAliasSPB)->PB_DATA	:= (cSQLAlias)->PB_DATA
			(cAliasSPB)->PB_PD 		:= (cSQLAlias)->PB_PD
			(cAliasSPB)->PB_DESCPD 	:= (cSQLAlias)->(PosSrv( PB_PD, PB_FILIAL, "RV_DESC", 1, .F. ))
			(cAliasSPB)->PB_CC		:= (cSQLAlias)->PB_CC
			(cAliasSPB)->PB_HORAS	:= (cSQLAlias)->PB_HORAS
			(cAliasSPB)->PB_VALOR	:= (cSQLAlias)->PB_VALOR
			(cAliasSPB)->PB_TIPO1	:= (cSQLAlias)->PB_TIPO1
			(cAliasSPB)->RECNO		:= (cSQLAlias)->RECNO
		(cAliasSPB)->(MsUnlock())
		
		(cSQLAlias)->(dbSkip())
	EndDo
	
	(cSQLAlias)->(dbCloseArea())
	
	//Cria as colunas para o Browse
	GetColumns(aCamposSPB, @aColumnSPB)
	
Return aColumnSPB

/*/{Protheus.doc} CriaTmpRGB
Cria uma tabela tempor�ria com as informa��es do lan�amento mensal da folha e cria as colunas que ser�o apresentadas em tela
@type  Static Function
@author C�cero Alves
@since 20/03/2023
@param cAliasRGB, Caractere, Alias utilizado na tabela tempor�ria
@return aColumnRGB, Array, Colunas que ser�o apresentadas em tela
/*/
Static Function CriaTmpRGB(cAliasRGB)
	
	Local aCamposRGB	:= {"RGB_FILIAL", "RGB_MAT", "RGB_PD", "RGB_DESCPD", "RGB_TIPO1", "RGB_HORAS", "RGB_VALOR", "RGB_DTREF", "RGB_CC", "RGB_ROTEIR"}
	Local aColumnRGB	:= {}
	Local aStructRGB	:= {}
	Local aLstIndices	:= {}
	Local cSQLAlias		:= GetNextAlias()
	Local cWhere		:= GetSRAWhere()
	Local cJoin			:= "%" + FWJoinFilial("RGB", "SP9") + "%"
	
	Default cAliasRGB := GetNextAlias()
	
	// Monta a estrutura da tabela tempor�ria 
	aAdd( aStructRGB, { "OK"		, "C", 2					  , 0 } )
	aAdd( aStructRGB, { "RGB_FILIAL", "C", FwGetTamFilial		  , 0 } )
	aAdd( aStructRGB, { "RGB_MAT"	, "C", TamSX3("RGB_MAT")[1]	  , 0 } )
	aAdd( aStructRGB, { "RGB_DTREF"	, "D", 8					  , 0 } )
	aAdd( aStructRGB, { "RGB_PD"	, "C", TamSX3("RGB_PD")[1]	  , TamSX3("RGB_PD")[2] })
	aAdd( aStructRGB, { "RGB_DESCPD", "C", 30					  , 0 } )
	aAdd( aStructRGB, { "RGB_CC"  	, "C", TamSX3("RGB_CC")[1]	  , 0 } )
	aAdd( aStructRGB, { "RGB_HORAS" , "N", TamSX3("RGB_HORAS")[1] , TamSX3("RGB_HORAS")[2] })
	aAdd( aStructRGB, { "RGB_VALOR"	, "N", TamSX3("RGB_VALOR")[1] , TamSX3("RGB_VALOR")[2] })
	aAdd( aStructRGB, { "RGB_TIPO1"	, "C", 1					  , 0 } )
	aAdd( aStructRGB, { "RGB_ROTEIR", "C", TamSX3("RGB_ROTEIR")[1], 0 } )
	aAdd( aStructRGB, { "RECNO"		, "N", 16					  , 0 } )
	
	aAdd( aLstIndices, { "RGB_FILIAL", "RGB_MAT" } )
	
	oArqRGB := RhCriaTrab(cAliasRGB, aStructRGB, aLstIndices)
	
	cWhere := "%" + cWhere + "%"
	
	BeginSQL ALIAS cSQLAlias
		COLUMN RGB_DTREF AS DATE
		SELECT RGB_FILIAL, RGB_MAT, RGB_PD, RGB_TIPO1, RGB_HORAS, RGB_VALOR, RGB_DTREF, RGB_CC, RGB_ROTEIR, RGB.R_E_C_N_O_ RECNO
		FROM %Table:RGB% RGB
		LEFT JOIN %Table:SP9% SP9 
		ON RGB_PD = P9_CODFOL AND 
		%Exp:cJoin%
		LEFT JOIN %Table:SRA% SRA 
		ON RGB.RGB_FILIAL = SRA.RA_FILIAL AND 
		RGB.RGB_MAT = SRA.RA_MAT
		WHERE 
		SP9.P9_IDPON IN ('023A', '024A', '042A') AND 
		SP9.%NotDel% AND
		RGB.%NotDel% AND
		%Exp:cWhere%
		ORDER BY RGB.RGB_FILIAL, RGB.RGB_MAT
	EndSQL
	
	While (cSQLAlias)->(!EoF())
		
		RecLock(cAliasRGB, .T.)
			(cAliasRGB)->OK			:= ""
			(cAliasRGB)->RGB_FILIAL	:= (cSQLAlias)->RGB_FILIAL
			(cAliasRGB)->RGB_MAT 	:= (cSQLAlias)->RGB_MAT
			(cAliasRGB)->RGB_DTREF	:= (cSQLAlias)->RGB_DTREF
			(cAliasRGB)->RGB_PD 	:= (cSQLAlias)->RGB_PD
			(cAliasRGB)->RGB_DESCPD := (cSQLAlias)->(PosSrv( RGB_PD, RGB_FILIAL, "RV_DESC", 1, .F. ))
			(cAliasRGB)->RGB_CC		:= (cSQLAlias)->RGB_CC
			(cAliasRGB)->RGB_HORAS	:= (cSQLAlias)->RGB_HORAS
			(cAliasRGB)->RGB_VALOR	:= (cSQLAlias)->RGB_VALOR
			(cAliasRGB)->RGB_TIPO1	:= (cSQLAlias)->RGB_TIPO1
			(cAliasRGB)->RGB_ROTEIR	:= (cSQLAlias)->RGB_ROTEIR
			(cAliasRGB)->RECNO		:= (cSQLAlias)->RECNO
		(cAliasRGB)->(MsUnlock())
		
		(cSQLAlias)->(dbSkip())
	EndDo
	
	(cSQLAlias)->(dbCloseArea())
	
	//Cria as colunas para o Browse
	GetColumns(aCamposRGB, @aColumnRGB)
	
Return aColumnRGB

/*/{Protheus.doc} CriaTmpSRA
Cria uma tabela tempor�ria com as informa��es funcion�rios e cria as colunas que ser�o apresentadas em tela
@type  Static Function
@author C�cero Alves
@since 31/03/2023
@param cAliasSRA, Caractere, Alias utilizado na tabela tempor�ria
@param aColumnSRA, Array, Colunas que ser�o apresentadas em tela
@return lFuncFil, L�gico, Indica se foram encontrados funcion�rios com os filtros selecionados
/*/
Static Function CriaTmpSRA(cAliasSRA, aColumnSRA)
	
	Local aCamposSRA	:= {"RA_FILIAL", "RA_MAT", "RA_NOME", "RA_CC", "RA_ADMISSA"}
	Local aStructSRA	:= {}
	Local aLstIndices	:= {}
	Local cSQLAlias		:= GetNextAlias()
	Local cWhere		:= GetSRAWhere()
	Local cFilMat		:= ""
	
	Default cAliasSRA 	:= GetNextAlias()
	Default aColumnSRA	:= {}
	
	// Monta a estrutura da tabela tempor�ria 
	aAdd( aStructSRA, { "OK"		, "C", 2					  , 0 } )
	aAdd( aStructSRA, { "RA_FILIAL" , "C", FwGetTamFilial		  , 0 } )
	aAdd( aStructSRA, { "RA_MAT"	, "C", TamSX3("RA_MAT")[1]	  , 0 } )
	aAdd( aStructSRA, { "RA_ADMISSA", "D", 8					  , 0 } )
	aAdd( aStructSRA, { "RA_NOME"	, "C", 30					  , 0 } )
	aAdd( aStructSRA, { "RA_CC"  	, "C", TamSX3("RA_CC")[1]	  , 0 } )
	
	aAdd( aLstIndices, { "RA_FILIAL", "RA_MAT" } )
	
	oArqRGB := RhCriaTrab(cAliasSRA, aStructSRA, aLstIndices)
	
	cWhere := "%" + cWhere + "%"
	
	BeginSQL ALIAS cSQLAlias
		COLUMN RA_ADMISSA AS DATE
		SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_CC, RA_ADMISSA
		FROM %Table:SRA% SRA
		WHERE 
		%Exp:cWhere%
		ORDER BY RA_FILIAL, RA_MAT
	EndSQL
	
	(cAliasSPI)->(dbGoTop())
	(cAliasSPB)->(dbGoTop())
	(cAliasRGB)->(dbGoTop())
	
	While (cSQLAlias)->(!EoF())
		cFilMat := (cSQLAlias)->( RA_FILIAL + RA_MAT)
		If (cAliasSPI)->(dbSeek(cFilMat)) .Or. (cAliasSPB)->(dbSeek(cFilMat)) .OR. (cAliasRGB)->(dbSeek(cFilMat))
			RecLock(cAliasSRA, .T.)
				(cAliasSRA)->OK			:= ""
				(cAliasSRA)->RA_FILIAL	:= (cSQLAlias)->RA_FILIAL
				(cAliasSRA)->RA_MAT 	:= (cSQLAlias)->RA_MAT
				(cAliasSRA)->RA_NOME	:= (cSQLAlias)->RA_NOME
				(cAliasSRA)->RA_CC 		:= (cSQLAlias)->RA_CC
				(cAliasSRA)->RA_ADMISSA	:= (cSQLAlias)->RA_ADMISSA
			(cAliasSRA)->(MsUnlock())
		EndIf
		(cSQLAlias)->(dbSkip())
	EndDo
	
	(cSQLAlias)->(dbCloseArea())
	
	// Verifica se foi encontrado algum funcion�rio
	(cAliasSRA)->(dbGoTop())
	If (cAliasSRA)->(EoF())
		Return .F.
	EndIf
	
	//Cria as colunas para o Browse
	GetColumns(aCamposSRA, @aColumnSRA)
	
Return .T.

/*/{Protheus.doc} GetSRAWhere
Retorna a cl�sula whera utilizada para filtrar a SRA com base nos par�metros selecionados
@type  Static Function
@author C�cero Alves
@since 20/03/2023
@return cWhereSRA, Caractere, cl�sula whera utilizada para filtrar a SRA
/*/
Static Function GetSRAWhere()
	
	Local cAcessaSRA	:= ""
	Static cWhereSRA	:= ""
	
	If !Empty(cWhereSRA)
		Return cWhereSRA
	EndIf
	
	cAcessaSRA	:= fSFiltrSQL(ChkRH("PONM100", "SRA", "2"))
	
	MV_PAR06 := fSqlIn(StrTran(MV_PAR06, '*'), 1)
	MV_PAR07 := fSqlIn(StrTran(MV_PAR07, '*'), 1)
	
	MakeSqlExp("PONM100")
	
	cWhereSRA += "SRA.D_E_L_E_T_ = '' "
	cWhereSRA += If(!Empty(MV_PAR01), " AND " + MV_PAR01, "") 							// Filiais
	cWhereSRA += If(!Empty(MV_PAR02), " AND " + MV_PAR02, "") 							// Centros de Custo
	cWhereSRA += If(!Empty(MV_PAR03), " AND " + MV_PAR03, "")							// Turnos
	cWhereSRA += If(!Empty(MV_PAR04), " AND " + MV_PAR04, "") 							// Matr�culas
	cWhereSRA += If(!Empty(MV_PAR05), " AND " + MV_PAR05, "") 							// Regras de Apontamento
	cWhereSRA += If(!Empty(MV_PAR06), " AND RA_SITFOLH IN (" + MV_PAR06 + ")", "") 	// Situa��es
	cWhereSRA += If(!Empty(MV_PAR07), " AND RA_CATFUNC IN (" + MV_PAR07 + ")", "") 	// Categorias
	
	// Controle de Acesso
	cWhereSRA += If(!Empty(cAcessaSRA) .And. cAcessaSRA != ".T.", " AND " + cAcessaSRA, "")
	
Return cWhereSRA

/*/{Protheus.doc} GetColumns
Cria as colunas para o Browse dos campos passados com base nas informa��es da SX3
@type  Static Function
@author C�cero Alves
@since 20/03/2023
@param aCampos, Array, Nomes dos campos base para as colunas
@param aColumns, Array, Array com as colunas - Deve ser passado por refer�ncia
/*/
Static Function GetColumns(aCampos, aColumns)
	
	Local nI
	
	Default aCampos := {}
	Default aColumns := {}
	
	For nI := 1 To Len(aCampos)
		AAdd( aColumns, FWBrwColumn():New() )
		aTail(aColumns):SetID( aCampos[nI] )
		aTail(aColumns):SetData( &("{ || " + aCampos[nI] + " }") )
		aTail(aColumns):SetType( GetSx3Cache(aCampos[nI], "X3_TIPO") )
		aTail(aColumns):SetSize( GetSx3Cache(aCampos[nI], "X3_TAMANHO"))
		aTail(aColumns):SetTitle( GetSx3Cache(aCampos[nI], "X3_TITULO") )
		aTail(aColumns):SetPicture(GetSx3Cache(aCampos[nI], "X3_PICTURE"))
		aTail(aColumns):SetDecimal( GetSx3Cache(aCampos[nI], "X3_DECIMAL") )
	Next nI
	
Return

/*/{Protheus.doc} fGrava
Realiza a grava��o dos registros selecionados
@type  Static Function
@author C�cero Alves
@since 21/03/2023
/*/
Static Function fGrava()
	
	Local lFrist	:= .T.
	Local cLastFunc	:= "***"
	
	//-- Grava��o Banco de Horas
	oBrowseSPI:SetFilterDefault("")
	oBrowseSPI:CleanFilter()
	(cAliasSPI)->(dbGoTop())
	dbSelectArea("SPI")
	
	While (cAliasSPI)->(!EoF())
		If !Empty((cAliasSPI)->OK)
			
			If lFrist
				aAdd(aLogTitle, STR0013) // "Banco de Horas - Registros Alterados"
				aAdd(aLogs, {})
				lFrist := .F.
			EndIf
			
			If !(cAliasSPI)->(PI_FILIAL + PI_MAT) == cLastFunc
				cLastFunc := (cAliasSPI)->(PI_FILIAL + PI_MAT)
				// "Funcion�rio: " - 
				aAdd(aTail(aLogs), STR0014 + (cAliasSPI)->(PI_FILIAL + " - " + PI_MAT) + ": " + Posicione("SRA", 1, cLastFunc, "RA_NOME") )
			EndIf
			
			// "Evento: " - " Horas: "
			aAdd(aTail(aLogs), STR0015 + (cAliasSPI)->(PI_PD + " - " + PI_DESC) + STR0016 + cValToChar((cAliasSPI)->PI_QUANT))
			
			SPI->(dbGoTo((cAliasSPI)->RECNO))
			RecLock("SPI", .F.)
				SPI->PI_STATUS := ""
				SPI->PI_DTBAIX := cTod("//")
			SPI->(MsUnlock())
		EndIf
		(cAliasSPI)->(dbSkip())
	EndDo
	
	lFrist := .T.
	cLastFunc := "***"
	
	//-- Grava��o dos Resultados
	oBrowseSPB:SetFilterDefault("")
	oBrowseSPB:CleanFilter()
	(cAliasSPB)->(dbGoTop())
	dbSelectArea("SPB")
	
	While (cAliasSPB)->(!EoF())
		If !Empty((cAliasSPB)->OK)
			
			If lFrist
				aAdd(aLogTitle, STR0017) // "Resultados do Ponto - Registros Exclu�dos"
				aAdd(aLogs, {})
				lFrist := .F.
			EndIf
			
			If !(cAliasSPB)->(PB_FILIAL + PB_MAT) == cLastFunc
				cLastFunc := (cAliasSPB)->(PB_FILIAL + PB_MAT)
				aAdd(aTail(aLogs), STR0014 + (cAliasSPB)->(PB_FILIAL + " - " + PB_MAT) + ": " + Posicione("SRA", 1, cLastFunc, "RA_NOME") )
			EndIf
			
			// "Verba: "
			aAdd(aTail(aLogs), STR0018 + (cAliasSPB)->(PB_PD + " - " + PB_DESCPD) + STR0016 + cValToChar((cAliasSPB)->PB_HORAS))
			
			SPB->(dbGoTo((cAliasSPB)->RECNO))
			RecLock("SPB", .F.)
				SPB->(dbDelete())
			SPB->(MsUnlock())
		EndIf
		(cAliasSPB)->(dbSkip())
	EndDo
	
	lFrist := .T.
	cLastFunc := "***"
	
	//-- Grava��o Lan�amentos Mensais - Folha
	oBrowseRGB:SetFilterDefault("")
	oBrowseRGB:CleanFilter()
	(cAliasRGB)->(dbGoTop())
	dbSelectArea("RGB")
	
	While (cAliasRGB)->(!EoF())
		If !Empty((cAliasRGB)->OK)
			
			If lFrist
				aAdd(aLogTitle, STR0019) // "Lan�amentos Mensais da Folha de Pagamento - Registros Exclu�dos"
				aAdd(aLogs, {})
				lFrist := .F.
			EndIf
			
			If !(cAliasRGB)->(RGB_FILIAL + RGB_MAT) == cLastFunc
				cLastFunc := (cAliasRGB)->(RGB_FILIAL + RGB_MAT)
				aAdd(aTail(aLogs), STR0014 + (cAliasRGB)->(RGB_FILIAL + " - " + RGB_MAT) + ": " + Posicione("SRA", 1, cLastFunc, "RA_NOME") )
			EndIf
			
			aAdd(aTail(aLogs), STR0018 + (cAliasRGB)->(RGB_PD + " - " + RGB_DESCPD) + STR0016 + cValToChar((cAliasRGB)->RGB_HORAS))
			
			RGB->(dbGoTo((cAliasRGB)->RECNO))
			RecLock("RGB", .F.)
				RGB->(dbDelete())
			RGB->(MsUnlock())
		EndIf
		(cAliasRGB)->(dbSkip())
	EndDo
	
Return

/*/{Protheus.doc} MarkOthers
Realiza a marca��o dos demais browses quando o funcion�rio � marcado/desmarcado
@type  Static Function
@author C�cero Alves
@since 21/03/2023
/*/
Static Function MarkOthers()
	
	Local nI
	
	Static lAtualiza := .F.
	Static lSRANMark := .F.
    
	If !lAtualiza
		Return
	EndIf
	
	If !oBrowseSRA:IsMark()
		lSRANMark := .T. // Altera para permitir marcar/desmarcar os demais browses
	EndIf
	
	// Banco de Horas
	oBrowseSPI:GoTop()
	
	If oBrowseSPI:At() == 1 // Caso retorne 5000 o browse est� vazio
		oBrowseSPI:GoBottom()
		nI := oBrowseSPI:At()
		While nI >= 1
			If !oBrowseSPI:IsMark()
				oBrowseSPI:MarkRec()
			EndIf
			oBrowseSPI:GoUp()
			nI--
		EndDo
	EndIf
	
	// Resultados
	oBrowseSPB:GoTop()
	
	If oBrowseSPB:At() == 1 // Caso retorne 5000 o browse est� vazio
		oBrowseSPB:GoBottom()
		nI := oBrowseSPB:At()
		While nI >= 1
			If !oBrowseSPB:IsMark()
				oBrowseSPB:MarkRec()
			EndIf
			oBrowseSPB:GoUp()
			nI--
		EndDo
	EndIf
	
	// Lan�amentos mensais
	oBrowseRGB:GoTop()
	
	If oBrowseRGB:At() == 1 // Caso retorne 5000 o browse est� vazio
		oBrowseRGB:GoBottom()
		nI := oBrowseRGB:At()
		While nI >= 1
			If !oBrowseRGB:IsMark()
				oBrowseRGB:MarkRec()
			EndIf
			oBrowseRGB:GoUp()
			nI--
		EndDo
	EndIf
	
	If !oBrowseSRA:IsMark() // Desmarca todos os registros
		oBrowseSPI:AllMark()
		oBrowseSPB:AllMark()
		oBrowseRGB:AllMark()
	EndIf
	
	oBrowseSPI:Refresh()
	oBrowseSPB:Refresh()
	oBrowseRGB:Refresh()
	
	lSRANMark := .F.
	
Return

/*/{Protheus.doc} LimpaObj
Destroi os objetos criados para as tabelas tempor�rias e Browses
@type  Static Function
@author C�cero Alves
@since 22/03/2023
/*/
Static Function LimpaObj()
	
	If oArqSPI != Nil
		oArqSPI:Delete()
		Freeobj(oArqSPI)
	EndIf
	
	If oArqSPB != Nil
		oArqSPB:Delete()
		Freeobj(oArqSPB)
	EndIf
	
	If oArqRGB != Nil
		oArqRGB:Delete()
		Freeobj(oArqRGB)
	EndIf
	
	cWhereSRA := ""
	
Return
