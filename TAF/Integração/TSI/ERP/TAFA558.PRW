#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

Static lNewCtrl := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")

/*/{Protheus.doc} TSIFATNFIS
	( Classe que cont�m query com preparedstatament sobre movimenta��es
	Fatura Financeiro e Nota Fiscal X Cadastros )
    @type Class
	@author Henrique Pereira / Denis Souza
	@since 10/06/2020
	@return Nil, nulo, n�o tem retorno.
/*/

Class TSIFATNFIS
 
    Data aFilC1H     as Array	ReadOnly
	Data aFilC20     as Array 	ReadOnly
	Data aFilLEM     as Array 	ReadOnly
	Data aUpdates	 as Array 
	Data cRefStamp	 as character 

    Method New() Constructor
    Method FilC1H()
	Method FilC20()
	Method FilLEM()
	Method UpdQuery()
	Method ExUpdate()
	Method CheckTable() 

EndClass

 /*/{Protheus.doc} New
	(M�todo construtor )
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, n�o tem retorno.
/*/

Method New(cSourceBr,cRefStamp) Class TSIFATNFIS
	Self:cRefStamp  := cRefStamp
	Self:CheckTable()	
    Self:FilC1H(cSourceBr)
	Self:FilC20(cSourceBr)
	Self:FilLEM(cSourceBr)
	Self:UpdQuery()
	Self:ExUpdate()
	
Return Nil

 /*/{Protheus.doc} CheckTable
	(M�todo respons�vel por for�ar a cria��o das tabelas no banco de dados para evitar error log no dbaccess
	@author Renan Gomes
	@since 10/12/2021
	@return Nil, nulo, n�o tem retorno.
/*/

Method CheckTable() Class TSIFATNFIS

    ChkFile("CDG",.F.)
	ChkFile("SON",.F.)
	ChkFile("CDT",.F.)
	ChkFile("CKX",.F.)
	
Return

 /*/{Protheus.doc} FilC1H
	(M�todo respons�vel por montar o conte�do da filial da C1H
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, n�o tem retorno.
/*/

Method FilC1H(cSourceBr) Class TSIFATNFIS
     self:aFilC1H := TafTSIFil(cSourceBr, 'C1H')
Return

 /*/{Protheus.doc} FilC20
	(M�todo respons�vel por montar o conte�do da filial da C20
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, n�o tem retorno.
/*/

Method FilC20(cSourceBr) Class TSIFATNFIS
     self:aFilC20 := TafTSIFil(cSourceBr, 'C20')
Return

 /*/{Protheus.doc} FilLEM
	(M�todo respons�vel por montar o conte�do da filial da LEM
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, n�o tem retorno.
/*/

Method FilLEM(cSourceBr) Class TSIFATNFIS
     self:aFilLEM := TafTSIFil(cSourceBr, 'LEM')
Return


 /*/{Protheus.doc} UpdQuery
	M�todo respons�vel por montar o update fake dos cadastros em cima dos selects realizados
	@author Henrique Pereira / Denis Souza
	@since 08/06/2020
	@return Nil, nulo, n�o tem retorno.

	@OBS: Foi refeito as querys para retornar RECNOS distintos - Wesley Pinheiro em 30/12/2020
	@OBS: Foi refeito as querys para realizar o update direto nos RECNOS selecionados - Karen em 10/09/2021
/*/
Method UpdQuery( ) Class TSIFATNFIS

	Local cQuery    := ""
	Local cConcat   := ""
	Local cDbType   := Upper( Alltrim( TCGetDB( ) ) )
	Local cInC1H    := FormatIN( ArrTokStr( ::aFilC1H ), "|" )
	Local cInC20    := FormatIN( ArrTokStr( ::aFilC20 ), "|" )
	Local lTableCDG := TcCanOpen(RetSqlName( 'CDG' )) .and. ExistStamp(,,"CDG")
	Local lTableCCF := TcCanOpen(RetSqlName( 'CCF' )) .and. ExistStamp(,,"CCF")
	Local lTableSON := TcCanOpen(RetSqlName( 'SON' )) .and. ExistStamp(,,"SON")

	::aUpdates := {}
	// VerIfica o tipo de concatena��o para o banco
	If "MSSQL" $ cDbType
		cConcat := "+"
	Else
		cConcat := "||"
	EndIf

	// SB1 - Produto
	cQuery := " UPDATE " + RetSqlName( "SB1" ) + " SET  D_E_L_E_T_ = ' ' "
	cQuery += " WHERE R_E_C_N_O_ IN ( "
	cQuery += " SELECT " 
	cQuery += "	DISTINCT ( SB1.R_E_C_N_O_ ) RECNO "
	cQuery += "	FROM " 
	cQuery += RetSqlName( "SFT" ) + " SFT "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " INNER JOIN "
	cQuery += RetSqlName( "SB1" ) + " SB1 "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " ON SB1.B1_FILIAL = '" + xFilial( "SB1" ) + "' "
	cQuery += "	AND SB1.B1_COD = SFT.FT_PRODUTO "
	cQuery += "	AND SB1.D_E_L_E_T_ = ' ' "

	cQuery += TsiDtCorte( cDbType, ::cRefStamp, "FT_FILIAL", "SFT" )	
	cQuery += " ) "

	aAdd(::aUpdates, cQuery)

	// SB5 - Complemento de Produto 
	cQuery := " UPDATE " + RetSqlName( "SB5" ) + " SET  D_E_L_E_T_ = ' ' "
	cQuery += " WHERE R_E_C_N_O_ IN ( "
	cQuery += " SELECT "
	cQuery += " DISTINCT ( SB5.R_E_C_N_O_ ) RECNO "
	cQuery += " FROM "
	cQuery += RetSqlName( "SFT" ) + " SFT "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " INNER JOIN "
	cQuery += RetSqlName( "SB5" ) + " SB5 "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " ON SB5.B5_FILIAL = '" + xFilial( "SB5" ) + "' "
	cQuery += " AND SB5.B5_COD = SFT.FT_PRODUTO "
	cQuery += " AND SB5.D_E_L_E_T_ = ' ' "
	cQuery += " AND SB5.S_T_A_M_P_ IS NULL "

	cQuery += TsiDtCorte( cDbType, ::cRefStamp, "FT_FILIAL", "SFT" )

	cQuery += " ) "
	aAdd(::aUpdates, cQuery)

	// SA1 - Clientes
	cQuery := " UPDATE " + RetSqlName( "SA1" ) + " SET  D_E_L_E_T_ = ' ' WHERE R_E_C_N_O_ IN  ( "
	cQuery += " SELECT DISTINCT SA1.R_E_C_N_O_ FROM "
	cQuery += RetSqlName( "SA1" ) + " SA1 "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " INNER JOIN ( "
	cQuery += " SELECT SF3.F3_FILIAL, SF3.F3_CLIEFOR, SF3.F3_LOJA, SF3.F3_CFO, SF3.F3_TIPO "
	cQuery += " FROM " + RetSqlName( "SF3" ) + " SF3 "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += TsiDtCorte( cDbType, ::cRefStamp, "F3_FILIAL", "SF3" )
	cQuery += " AND ( "
	//se for saida sem beneficiario ou devolucao eh proveniente de cliente
	cQuery += " ( SF3.F3_CFO >= '5' AND SF3.F3_TIPO NOT IN ( 'B', 'D' ) ) "
	cQuery += " OR "
	//se for entrada de beneficiario ou devolucao eh proveniente de cliente
	cQuery += " ( SF3.F3_CFO <= '4' AND SF3.F3_TIPO IN ( 'B', 'D' ) ) "
	cQuery += " ) "
	cQuery += " GROUP BY  SF3.F3_FILIAL, SF3.F3_CLIEFOR, SF3.F3_LOJA, SF3.F3_CFO, SF3.F3_TIPO "
	cQuery += " ) SF3TMP ON "
	cQuery += " SF3TMP.F3_FILIAL = '" + xFilial( "SF3" ) + "' "
	cQuery += " AND SF3TMP.F3_CLIEFOR = SA1.A1_COD "
	cQuery += " AND SF3TMP.F3_LOJA = SA1.A1_LOJA "
	cQuery += " WHERE SA1.A1_FILIAL = '" + xFilial( "SA1" ) + "' AND SA1.D_E_L_E_T_ = ' ' "

	cQuery += " ) "

	aAdd(::aUpdates, cQuery)

	// SA2 - Fornecedores
	cQuery := " UPDATE " + RetSqlName( "SA2" ) + " SET  D_E_L_E_T_ = ' ' WHERE R_E_C_N_O_ IN  ( "
	cQuery += " SELECT DISTINCT SA2.R_E_C_N_O_ FROM "
	cQuery += RetSqlName( "SA2" ) + " SA2 "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " INNER JOIN ( "
	cQuery += " SELECT SF3.F3_FILIAL, SF3.F3_CLIEFOR, SF3.F3_LOJA, SF3.F3_CFO, SF3.F3_TIPO "
	cQuery += " FROM " + RetSqlName( "SF3" ) + " SF3 "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += TsiDtCorte( cDbType, ::cRefStamp, "F3_FILIAL", "SF3" )
	cQuery += " AND ( "
	//se for entrada eh proveniente de forcenecedor desde que nao seja uma devolucao beneficiario
	cQuery += " ( SF3.F3_CFO <= '4' AND SF3.F3_TIPO NOT IN ( 'B', 'D' ) ) "
	cQuery += " OR "
	//se for saida com beneficiario ou devolucao eh proveniente de fornecedor
	cQuery += " ( SF3.F3_CFO >= '5' AND SF3.F3_TIPO IN ( 'B', 'D' ) ) "
	cQuery += " ) "
	cQuery += " GROUP BY  SF3.F3_FILIAL, SF3.F3_CLIEFOR, SF3.F3_LOJA, SF3.F3_CFO, SF3.F3_TIPO "
	cQuery += " ) SF3TMP ON "
	cQuery += " SF3TMP.F3_FILIAL = '" + xFilial( "SF3" ) + "' "
	cQuery += " AND SF3TMP.F3_CLIEFOR = SA2.A2_COD "
	cQuery += " AND SF3TMP.F3_LOJA = SA2.A2_LOJA "
	cQuery += " WHERE SA2.A2_FILIAL = '" + xFilial( "SA2" ) + "' AND SA2.D_E_L_E_T_ = ' ' "
	cQuery += " ) "

	aAdd(::aUpdates, cQuery)

	// SF4 - TES 
	cQuery := " UPDATE " + RetSqlName( "SF4" ) + " SET  D_E_L_E_T_ = ' ' "
	cQuery += " WHERE R_E_C_N_O_ IN ( "
	cQuery += " SELECT "
	cQuery += " DISTINCT ( SF4.R_E_C_N_O_ ) RECNO "
	cQuery += " FROM "
	cQuery += RetSqlName( "SFT" ) + " SFT "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " INNER JOIN "
	cQuery += RetSqlName( "SF4" ) + " SF4 "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " ON SF4.F4_FILIAL = '" + xFilial( "SF4" ) + "' "
	cQuery += " AND (SF4.F4_MSBLQL = '2' OR SF4.F4_MSBLQL = ' ') "
	cQuery += " AND SF4.F4_CODIGO = SFT.FT_TES "
	cQuery += " AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += " AND SF4.S_T_A_M_P_ IS NULL "

	cQuery += TsiDtCorte( cDbType, ::cRefStamp, "FT_FILIAL", "SFT" )

	cQuery += " ) "
	aAdd(::aUpdates, cQuery)

	// CCE - Informa��es Complementares NF
	cQuery := " UPDATE " + RetSqlName( "CCE" ) + " SET  D_E_L_E_T_ = ' ' "
	cQuery += " WHERE R_E_C_N_O_ IN ( "
	cQuery += " SELECT "
	cQuery += " DISTINCT ( CCE.R_E_C_N_O_ ) RECNO "
	cQuery += " FROM "
	cQuery += RetSqlName( "SFT" ) + " SFT "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " INNER JOIN "
	cQuery += RetSqlName( "CDA" ) + " CDA "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " ON CDA.CDA_FILIAL = '" + xFilial( "CDA" ) + "' "
	cQuery += " AND SFT.FT_NFISCAL = CDA.CDA_NUMERO "
	cQuery += " AND SFT.FT_SERIE = CDA.CDA_SERIE "
	cQuery += " AND SFT.FT_CLIEFOR = CDA.CDA_CLIFOR "
	cQuery += " AND SFT.FT_LOJA = CDA.CDA_LOJA "
	cQuery += " AND SFT.D_E_L_E_T_ = CDA.D_E_L_E_T_ "
	cQuery += " AND SFT.FT_ITEM = CDA.CDA_NUMITE "
	cQuery += " INNER JOIN "
	cQuery += RetSqlName( "CCE" ) + " CCE "
	cQuery += " ON  CCE.CCE_FILIAL = '" + xFilial( "CCE" ) + "' "
	cQuery += " AND CCE.CCE_COD = CDA.CDA_IFCOMP "
	cQuery += " AND CCE.D_E_L_E_T_ = ' ' "
	cQuery += " AND CCE.S_T_A_M_P_ IS NULL "

	cQuery += TsiDtCorte( cDbType, ::cRefStamp, "FT_FILIAL", "SFT" )
			
	cQuery += " ) "
	aAdd(::aUpdates, cQuery)

	// SAH - Unidade de medida
	cQuery := " UPDATE " + RetSqlName( "SAH" ) + " SET  D_E_L_E_T_ = ' ' "
	cQuery += " WHERE R_E_C_N_O_ IN ( "
	cQuery += " SELECT "
	cQuery += " DISTINCT ( SAH.R_E_C_N_O_ ) RECNO "
	cQuery += " FROM "
	cQuery += RetSqlName( "SFT" ) + " SFT "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " INNER JOIN "
	cQuery += RetSqlName( "SB1" ) + " SB1 "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " ON SB1.B1_FILIAL = '" + xFilial( "SB1" ) + "' "
	cQuery += " AND SB1.B1_COD = SFT.FT_PRODUTO "
	cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN "
	cQuery += RetSqlName( "SAH" ) + " SAH "  
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " ON SAH.AH_FILIAL = '" + xFilial( "SAH" ) + "' "
	cQuery += " AND SAH.AH_UNIMED = SB1.B1_UM "
	cQuery += " AND SAH.D_E_L_E_T_ = ' ' "
	cQuery += " AND SAH.S_T_A_M_P_ IS NULL "

	cQuery += TsiDtCorte( cDbType, ::cRefStamp, "FT_FILIAL", "SFT" )

	cQuery += " ) "
	aAdd(::aUpdates, cQuery)

	// SYD - NCM ( Nomenclatura Comum Mercosul )
	cQuery := " UPDATE " + RetSqlName( "SYD" ) + " SET  D_E_L_E_T_ = ' ' "
	cQuery += " WHERE R_E_C_N_O_ IN ( "
	cQuery += " SELECT "
	cQuery += " DISTINCT ( SYD.R_E_C_N_O_ ) RECNO "
	cQuery += " FROM "
	cQuery += RetSqlName( "SFT" ) + " SFT "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " INNER JOIN "
	cQuery += RetSqlName( "SB1" ) + " SB1 "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " ON SB1.B1_FILIAL = '" + xFilial( "SB1" ) + "' "
	cQuery += " AND SB1.B1_COD = SFT.FT_PRODUTO "
	cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN "
	cQuery += RetSqlName( "SYD" ) + " SYD "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " ON SYD.YD_FILIAL = '" + xFilial( "SYD" ) + "' "
	cQuery += " AND SYD.YD_TEC = SB1.B1_POSIPI "
	cQuery += " AND SYD.D_E_L_E_T_ = ' ' "
	cQuery += " AND SYD.S_T_A_M_P_ IS NULL "
	
	cQuery += TsiDtCorte( cDbType, ::cRefStamp, "FT_FILIAL", "SFT" )

	cQuery += " ) "
	aAdd(::aUpdates, cQuery)

	// CDN - Codigo ISS
	cQuery := " UPDATE " + RetSqlName( "CDN" ) + " SET  D_E_L_E_T_ = ' ' "
	cQuery += " WHERE R_E_C_N_O_ IN ( "
	cQuery += " SELECT "
	cQuery += " DISTINCT ( CDNISS.R_E_C_N_O_ ) RECNO "
	cQuery += " FROM "
	cQuery += RetSqlName( "SFT" ) + " SFT "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " INNER JOIN "
	cQuery += RetSqlName( "SB1" ) + " SB1 "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " ON SB1.B1_FILIAL = '" + xFilial( "SB1" ) + "' "
	cQuery += " AND SB1.B1_COD = SFT.FT_PRODUTO "
	cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN "
	cQuery += RetSqlName( "CDN" ) + " CDNISS "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " ON CDNISS.CDN_FILIAL = '" + xFilial( "CDN" ) + "' "
	cQuery += " AND CDNISS.CDN_CODISS = SB1.B1_CODISS "
	cQuery += " AND CDNISS.D_E_L_E_T_ = ' ' "
	cQuery += " AND CDNISS.S_T_A_M_P_ IS NULL "
	
	cQuery += TsiDtCorte( cDbType, ::cRefStamp, "FT_FILIAL", "SFT" )

	cQuery += " ) "
	aAdd(::aUpdates, cQuery)

	// F2Q - Complemento Fiscal
	if TAFAlsInDic('F2Q') .and. TafColumnPos('F2Q_TPSERV')
		//cQuery += " UNION "
		cQuery := " UPDATE " + RetSqlName( "F2Q" ) + " SET  D_E_L_E_T_ = ' ' "
		cQuery += " WHERE R_E_C_N_O_ IN ( "
		cQuery += " SELECT "
		cQuery += " DISTINCT ( F2Q.R_E_C_N_O_ ) RECNO "
		cQuery += " FROM "
		cQuery += RetSqlName( "SFT" ) + " SFT "
		If "MSSQL" $ cDbType
			cQuery += " (NOLOCK) "
		EndIf
		cQuery += " INNER JOIN "
		cQuery += RetSqlName( "SB1" ) + " SB1 "
		If "MSSQL" $ cDbType
			cQuery += " (NOLOCK) "
		EndIf
		cQuery += " ON SB1.B1_FILIAL = '" + xFilial( "SB1" ) + "' "
		cQuery += " AND SB1.B1_COD = SFT.FT_PRODUTO "
		cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " INNER JOIN "
		cQuery += RetSqlName( "F2Q" ) + " F2Q "
		If "MSSQL" $ cDbType
			cQuery += " (NOLOCK) "
		EndIf
		cQuery += " ON F2Q.F2Q_FILIAL = '" + xFilial( "F2Q" ) + "' "
		cQuery += " AND F2Q.F2Q_PRODUT = SB1.B1_COD "
		cQuery += " AND F2Q.D_E_L_E_T_ = ' ' "
		cQuery += " AND F2Q.S_T_A_M_P_ IS NULL "
		
		cQuery += TsiDtCorte( cDbType, ::cRefStamp, "FT_FILIAL", "SFT" )
		cQuery += " ) "
		aAdd(::aUpdates, cQuery)

	endIf

	If lTableSON
		// SON - Cadastro de Obras
		cQuery := " UPDATE " + RetSqlName( "SON" ) + " SET  D_E_L_E_T_ = ' ' "
		cQuery += " WHERE R_E_C_N_O_ IN ( "
		cQuery += " SELECT "
		cQuery += " DISTINCT ( SON.R_E_C_N_O_ ) RECNO "
		cQuery += " FROM "
		cQuery += RetSqlName( "SFT" ) + " SFT "
		If "MSSQL" $ cDbType
			cQuery += " (NOLOCK) "
		EndIf
		cQuery += " LEFT JOIN "
		cQuery += RetSqlName( "SD1" ) + " SD1 "
		If "MSSQL" $ cDbType
			cQuery += " (NOLOCK) "
		EndIf
		cQuery += " ON ( SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ( 'B', 'D' ) ) " 
		cQuery += " AND SD1.D1_FILIAL = '" + xFilial( "SD1" ) + "' "
		cQuery += " AND SD1.D1_DOC = SFT.FT_NFISCAL "
		cQuery += " AND SD1.D1_SERIE = SFT.FT_SERIE "
		cQuery += " AND SD1.D1_FORNECE = SFT.FT_CLIEFOR "
		cQuery += " AND SD1.D1_LOJA = SFT.FT_LOJA "
		cQuery += " AND SD1.D1_COD = SFT.FT_PRODUTO "
		cQuery += " AND SD1.D1_ITEM = SFT.FT_ITEM "
		cQuery += " AND SD1.D_E_L_E_T_ = ' ' "
		cQuery += " LEFT JOIN "
		cQuery += RetSqlName( "SF2" ) + " SF2 "
		If "MSSQL" $ cDbType
			cQuery += " (NOLOCK) "
		EndIf
		cQuery += " ON ( SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO NOT IN ( 'B', 'D' ) ) "
		cQuery += " AND SF2.F2_FILIAL = '" + xFilial( "SF2" ) + "' "
		cQuery += " AND SF2.F2_DOC = SFT.FT_NFISCAL "
		cQuery += " AND SF2.F2_SERIE = SFT.FT_SERIE "
		cQuery += " AND SF2.F2_CLIENTE = SFT.FT_CLIEFOR "
		cQuery += " AND SF2.F2_LOJA = SFT.FT_LOJA "
		cQuery += " AND SF2.D_E_L_E_T_ = ' ' "
		cQuery += " INNER JOIN " 
		cQuery += RetSqlName( "SON" ) + " SON "
		If "MSSQL" $ cDbType
			cQuery += " (NOLOCK) "
		EndIf
		cQuery += " ON (SON.ON_CODIGO = "
		cQuery += " CASE "
		cQuery += "  WHEN ( SFT.FT_TIPOMOV = 'S' ) THEN SF2.F2_CNO "
		cQuery += "  WHEN ( SFT.FT_TIPOMOV = 'E' ) THEN SD1.D1_CNO "
		cQuery += " END "
		cQuery += " AND SON.ON_FILIAL = '" + xFilial( "SON" ) + "' " 
		cQuery += " AND SON.D_E_L_E_T_ = ' ' ) "

		cQuery += TsiDtCorte( cDbType, ::cRefStamp, "FT_FILIAL", "SFT" )
		cQuery += " ) "
		aAdd(::aUpdates, cQuery)
	Endif
	
	IF lTableCDG .and. lTableCCF
		//CCF - Processos referenciados ( Fiscal )
		//Identificar os processos judiciais que estao lancados no complemento da nota no SIGAFIS e se o stamp 
		//desse lancamento que nao fica na SFT e sim na CDG (Processos refer. no documento) eh superior ao da C20. 
		//Importante: A Nota ja devera existir na C20 do TAF, consequentemente ter gerado escrituracao na SFT.
		cQuery := " UPDATE " + RetSqlName( "CCF" ) + " SET  D_E_L_E_T_ = ' ' "
		cQuery += " WHERE R_E_C_N_O_ IN ( "
		cQuery += " SELECT "
		cQuery += " DISTINCT ( CCF.R_E_C_N_O_ ) RECNO "
		cQuery += " FROM "+ RetSqlName( "CDG" ) + " CDG " 		//Processos refer. no documento
		If "MSSQL" $ cDbType
			cQuery += " (NOLOCK) "
		EndIf

		cQuery += " INNER JOIN "+ RetSqlName( "CCF" ) + " CCF " //Processos referenciados
		If "MSSQL" $ cDbType
			cQuery += " (NOLOCK) "
		EndIf
		cQuery += " ON CCF.CCF_FILIAL = '" + xFilial( "CCF" ) + "' "
		cQuery += " AND CCF.CCF_NUMERO = CDG.CDG_PROCES "
		cQuery += " AND CCF.CCF_TIPO = CDG.CDG_TPPROC "
		cQuery += " AND CCF.D_E_L_E_T_= ' ' "
		//Importante: Nao amarrar o item, pois a alteracao fake, ira refazer o processo com todas as suspensoes.
		//cQuery += " AND CCF.CCF_IDITEM = CDG.CDG_ITPROC "
		cQuery += QryCDGC20( cConcat, cDbType, cInC1H, cInC20, ::cRefStamp )
		cQuery += " ) "
		aAdd(::aUpdates, cQuery)
	Endif

Return

/*----------------------------------------------------------------------
{Protheus.doc} TsiDtCorte()
Filtro na SFT ou SF3 com a data de corte
@author Denis Souza / Jose Felipe
@since 12/01/2023
@return cQuery
//----------------------------------------------------------------------*/
Static Function TsiDtCorte( cDbType, cUltStmp, cCmpFil, cAlias )

Local cQuery   	  := ""
Local nTmUltStm   := 0

Default cDbType   := ""
Default cUltStmp  := ""
Default cCmpFil   := ""
Default cAlias    := ""

cQuery += " WHERE "
cQuery += cAlias + "." + cCmpFil + " = '" + xFilial( cAlias ) + "' "
cQuery += " AND " + cAlias + ".S_T_A_M_P_ IS NOT NULL "

If cDbType $ "MSSQL/MSSQL7"
	cQuery += " AND CONVERT(VARCHAR(23), " + cAlias + ".S_T_A_M_P_, 21) > '" + Alltrim(cUltStmp) + "' "
Elseif cDbType $ "ORACLE"
	nTmUltStm := len( alltrim( cUltStmp ) )
	cUltStmp  := substr(alltrim( cUltStmp ),1,nTmUltStm-4)
	cQuery += " AND " + cAlias + ".S_T_A_M_P_ > to_timestamp('" + ( cUltStmp + ".999" ) + "','dd.mm.yyyy hh24:mi:ss.ff') "
Elseif cDbType $ "POSTGRES"
	cQuery += " AND cast( to_char( " + cAlias + ".S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) > '" + Alltrim(cUltStmp) + "' "
Endif

cQuery += "	AND " + cAlias + ".D_E_L_E_T_ = ' ' "

Return cQuery

/*----------------------------------------------------------------------
{Protheus.doc} QryCDGC20()
Fun��o auxiliar para montagem de query entre as tabelas CDG, C1H e C20
@author Denis Souza
@since 22/10/2021
@return cQuery - query CDG, C1H e C20
//----------------------------------------------------------------------*/
Static Function QryCDGC20( cConcat, cDbType, cInC1H, cInC20, cUltStmp )

Local cQuery     := ""
Local nTmUltStm  := 0

cQuery += " LEFT JOIN "
cQuery += RetSqlName( "C1H" ) + " C1H "
If "MSSQL" $ cDbType
	cQuery += " (NOLOCK) "
EndIf
cQuery += " ON C1H_FILIAL IN " + cInC1H + " "
cQuery += " AND C1H.D_E_L_E_T_ = ' ' "
cQuery += " AND C1H.C1H_CODPAR = "
cQuery += " CASE WHEN "
cQuery += "  CDG.CDG_TPMOV = 'E' "
cQuery += "  THEN 'F' " + cConcat + " CDG.CDG_CLIFOR " + cConcat + " CDG.CDG_LOJA "
cQuery += "  ELSE 'C' " + cConcat + " CDG.CDG_CLIFOR " + cConcat + " CDG.CDG_LOJA "
cQuery += " END "

//Importante: A CDG nao armazena a data de emissao, portanto nao eh possivel cruzar a chave completa com a C20
If !lNewCtrl .OR. Empty(cUltStmp)
	cQuery += " LEFT JOIN "
	cQuery += RetSqlName( "C20" ) + " C20 "
	If "MSSQL" $ cDbType
		cQuery += " (NOLOCK) "
	EndIf
	cQuery += " ON C20.C20_FILIAL IN " + cInC20 + " "
	cQuery += "	AND ( "
	cQuery += "  CASE " 
	cQuery += "   WHEN C20.C20_INDOPE = '0' "
	cQuery += "    THEN 'E' "
	cQuery += "   WHEN C20.C20_INDOPE = '1' "
	cQuery += "    THEN 'S' "
	cQuery += "  END "
	cQuery += " ) = CDG.CDG_TPMOV "
	cQuery += " AND C20.C20_SERIE = CDG.CDG_SERIE "
	cQuery += " AND C20.C20_NUMDOC = CDG.CDG_DOC "
	cQuery += " AND C20.C20_CODPAR = C1H.C1H_ID " //ID do Join acima
	cQuery += " AND C20.D_E_L_E_T_ = ' ' "
EndIf

cQuery += " WHERE CDG.CDG_FILIAL = '" + xFilial( "CDG" ) + "' "

If !lNewCtrl .OR. Empty(cUltStmp)
	cQuery += " AND CDG.S_T_A_M_P_ IS NOT NULL "
	If cDbType $ "MSSQL/MSSQL7"
		cQuery += " AND ( (CONVERT(VARCHAR(23), CDG.S_T_A_M_P_, 21) > C20.C20_STAMP ) OR C20.C20_STAMP IS NULL ) "		
	Elseif cDbType $ "ORACLE"
		cQuery += " AND ( (C20.C20_STAMP IS NULL OR Length(trim(C20.C20_STAMP)) = 0 OR Length(trim(C20.C20_STAMP)) IS NULL ) OR (Length(trim(C20.C20_STAMP)) > 0 AND CDG.S_T_A_M_P_ > TO_TIMESTAMP(C20.C20_STAMP,'dd.mm.yyyy hh24:mi:ss.ff') ) ) "
	Elseif cDbType $ "POSTGRES"
		cQuery += " AND ( (cast(to_char(CDG.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23)) > C20.C20_STAMP) OR C20.C20_STAMP IS NULL ) "
	Endif
Else
	If cDbType $ "MSSQL/MSSQL7"
		cQuery += " AND CONVERT(VARCHAR(23), CDG.S_T_A_M_P_, 21) > '" + Alltrim(cUltStmp) + "' "
	Elseif cDbType $ "ORACLE"
		nTmUltStm := len( alltrim( cUltStmp ) )
		cUltStmp  := substr(alltrim( cUltStmp ),1,nTmUltStm-4)
		cQuery += " AND CDG.S_T_A_M_P_ > to_timestamp('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff')  "
	Elseif cDbType $ "POSTGRES"
		cQuery += " AND cast( to_char( CDG.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) > '" + Alltrim(cUltStmp) + "' "
	Endif
Endif

cQuery += "	AND CDG.D_E_L_E_T_ = ' ' "

//A condicional abaixo garante que a alteracao fake seja efetuada, apenas se o cadastro de processo (CCF) 
//seja inferior ao stamp do movimento (CDG). Se por algum motivo o documento fiscal nao for integrado
//e nao atualizar o stamp na C20 com o da CDG, ficaria em loop, uma vez que os processos ja entraram 
//e estao atualizados na C1G, nao tem necessidade de ficar efetuando update na CCF, 
//ateh que o movimento (CDG) seja novamente alterado e superior ao da CCF.
cQuery += " AND ( CDG.S_T_A_M_P_ > CCF.S_T_A_M_P_  OR CCF.S_T_A_M_P_ IS NULL ) "

Return cQuery

/*----------------------------------------------------------------------
{Protheus.doc} ExUpdate()
Fun��o para executar os updates fakes 
@author Karen Honda
@since 10/09/2021

//----------------------------------------------------------------------*/
Method ExUpdate() Class TSIFATNFIS

	Local nI := 0
 	Local cUpdate	:= ""
	Local nStatus	:= 0

	For nI := 1 to Len(::aUpdates)

		cUpdate	 := ::aUpdates[nI]
		TAFConOut("TSILOG00007: Update dos registros que sofrer�o altera��o fake [ In�cio update TSILOG00003 ]"  + cUpdate)

		nStatus := tcsqlexec( cUpdate ) 
		if nStatus < 0
			TAFConOut("TSILOG00008: Erro de altera��o fake [ In�cio erro TSILOG00004 ]" + TCSQLError() + " [ Fim erro TSILOG00004 ] " )
		else
			TAFConOut("-->Update realizado, trigger executado com sucesso na tabela: ")
		endif

	Next nI

Return Nil
