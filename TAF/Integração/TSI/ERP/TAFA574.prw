#INCLUDE "TOTVS.CH" 
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

/*
	Posição do array aRegT013AP conforme o layout do TAF do registro T013AP.
*/
#Define NAPREGISTR	01	// REGISTRO
#Define NAPCODTRIB	02	// COD_TRIB
#Define NAPBS		03	// BASE
#Define NAPBSQTD	04	// BASE_QUANT
#Define NAPBSNT		05	// BASE_NT
#Define NAPVLR		06	// VALOR
#Define NAPVLRTRIB	07	// VLR_TRIBUTAVEL
#Define NAPVLRISEN	08	// VLR_ISENTO
#Define NAPVLROUTR	09	// VLR_OUTROS
#Define NAPVLRNT	10	// VALOR_NT
#Define NAPCST		11	// CST
#Define NAPCFOP		12	// CFOP
#Define NAPALIQ		13	// ALIQUOTA
#Define NAPCODLST	14	// COD_LST
#Define NAPVLROPER	15	// VL_OPER
#Define NAPVLRSCRE	16	// VL_SCRED
#Define TRIBICMSST	17	// TRIBICMSST

/* 
	Posição do array a_RgT015AE conforme o layout do TAF do registro T015AE.
*/
#Define NAEREGISTR	01	// REGISTRO
#Define NAECODTRIB	02	// COD_TRIB
#Define NAECST		03	// CST
#Define NAEMODBC	04	// MODBC
#Define NAEMVA		05	// MVA
#Define NAEPRREDBS	06	// PERC_RED_BC
#Define NAEBS		07	// BASE
#Define NAEBSQTD	08	// BASE_QUANT
#Define NAEBSNT		09	// BASE_NT
#Define NAEALIQ		10	// ALIQUOTA
#Define NAEALIQQTD	11	// ALIQUOTA_QUANT
#Define NAEVLR		12	// VALOR
#Define NAEVLRTRIB	13	// VLR_TRIBUTAVEL
#Define NAECODENQ	14	// COD_ENQ
#Define NAEVLRISEN	15	// VLR_ISENTO
#Define NAEVLROUTR	16	// VLR_OUTROS
#Define NAEVLRNT	17	// VALOR_NT
#Define NAEBSICMUF	18	// VL_BC_ICMS_UF
#Define NAEVLICMUF	19	// VL_ICMS_UF
#Define NAECODANT	20	// COD_ANT
#Define NAEMTDSICM	21	// MT_DES_ICMS
#Define NAEVLRSCRE	22	// VL_SCRED
#Define NAEMTINCID	23	// MOT_INCIDENCIA
#Define NAEVLCONTR	24	// VLSCONTR
#Define NAEVLRADIC	25	// VLRADIC
#Define NAEVLRNPAG	26	// VLRNPAG
#Define NAEVLRCE15	27	// VLRCE15
#Define NAEVLRCE20	28	// VLRCE20
#Define NAEVLRCE25	29	// VLRCE25
#Define NAEVRDICPG	30	// VLRADICNPAG

static cTagJs     := "invoice"
static cTagT015   := "fiscalDocumentItems"
static cTagT015AI := "transportComplement"
static cTagT015AK := "indicativeOfSuspensionByJudicialProcess"
static cTag13AP   := "valuesByTax"
static cTag15AE   := "valuesByTaxPerItem"
static cTag013AA  := "complementaryInformationByTaxDocument"
static cTag013AI  := "ticketsByInvoice"
static cMVEstado  := GetNewPar("MV_ESTADO" , '' )
static cUFIPM     := GetNewPar("MV_UFIPM" , .F.) //ICMS/IPI participacao municipios
static lIntTms    := GetNewPar("MV_INTTMS" , .F.)
static lTmsUfPg   := GetNewPar("MV_TMSUFPG", .T.)
static cUFRESpd   := GetNewPar( 'MV_UFRESPD' , '' )
static cOpSemF    := GetNewPar( 'MV_OPSEMF' , '' )
static nTmNumIte  := GetSx3Cache( 'C30_NUMITE' , 'X3_TAMANHO' )
static nTmIndPro  := GetSx3Cache( 'C1G_INDPRO' , 'X3_TAMANHO' )
static nTmNmPro   := GetSx3Cache( 'C1G_NUMPRO' , 'X3_TAMANHO' )
static nTmVers    := GetSx3Cache( 'C1G_VERSAO' , 'X3_TAMANHO' )

static lINDISEN   := SFT->(FieldPos("FT_INDISEN")) > 0

static lTableCDG  := TcCanOpen(RetSqlName( 'CDG' )) .and. ExistStamp(,,"CDG")
static lTableCDT  := TcCanOpen(RetSqlName( 'CDT' )) .and. ExistStamp(,,"CDT") //!(CDT->(Eof()) .And. CDT->(Bof())) // Verifica se a tabelas DT6 existe na base.
static lTableDT6  := TcCanOpen(RetSqlName( 'DT6' )) //!(DT6->(Eof()) .And. DT6->(Bof())) // Verifica se a tabelas DT6 existe na base.
static lTableV80  := TcCanOpen(RetSqlName( 'V80' )) //!(V80->(Eof()) .And. V80->(Bof())) // Verifica se a tabelas V80 existe na base.
static lTableSON  := TcCanOpen(RetSqlName( 'SON' ))
static lTableCDC  := TcCanOpen(RetSqlName( 'CDC' )) //Protejo o fonte pois a tabela CDC pode não existir na base do cliente.
static lTableDHR  := TcCanOpen(RetSqlName( 'DHR' ))
static lTableFKX  := TcCanOpen(RetSqlName( 'FKX' ))
Static oHashC07   := HMNew()
Static oHashC09   := HMNew()
Static oHashC01   := HMNew()
Static oHashC02   := HMNew()
Static oHashC0U   := HMNew()
Static oHashC1H   := HMNew()
Static oHashC0X   := HMNew()
Static oHashT9C   := HMNew()
Static oHashC1L   := HMNew()
Static oHashC0Y   := HMNew()
Static oHashC1N   := HMNew()
Static oHashC03   := HMNew()
Static oHashC1J   := HMNew()
Static oHashC0B   := HMNew()
Static oHashC8C   := HMNew()
Static oHashLF0   := HMNew()
Static oHashC3S   := HMNew()
Static oHashC1G   := HMNew()
Static oHashC0J   := HMNew()
Static oHashCHY   := HMNew()
Static oHashC3Q   := HMNew()
Static oHashDUY   := HMNew()
Static oHashV3O   := HMNew()

static __oStatCDA   := nil
static __oStatEnt	:= nil
static __oStatSai   := nil
static __oStatCDT   := nil

/*/{Protheus.doc} TSINFISCAL
	( Classe que contém query com preparedstatament de Nota Fiscal para posterior integração )
    @type Class
	@author Henrique Pereira 
	@since 16/09/2020
	@return Nil, nulo, não tem retorno.
/*/ 

Class TSINFISCAL
  
    Data TSITQRY     as String
    Data cFinalQuery as String
    Data oStatement  as Object
	Data aTbls		 as Array
	Data aJSonDoc	 as array
	//Data oTempTable  as object  //Objeto do FwTemporaryTable() que é utilizada nos registros não integrados
	//Data cTmpTable   as String  //Alias da tabela temporária para controle dos registros não integrados
	Data cRefStamp   as String  //Ultimo stamp da V80 que foi recebido no construtor new()
	Data cAlias      as String  //Alias que será usado na query principal
	Data cUpStamp    as String  //Maior stamp que foi processado pelo CommitRegs
	Data nSizeMax    as numeric //Qtd Limite Lote
	Data nQtNotas    as numeric //Contador registro ( para controle de lote, limpado a cada 500)
	Data nProcReg    as numeric //Contador acumulado
    Method New() Constructor 
	Method RetTabela()
	Method HasTMS()
	Method LoadQuery()
    Method PrepQuery()
	Method GetQry()
    Method TempTable()
	Method CommitRegs()
	Method GetJsn()
	Method GetHashCahed()
	Method Create() Constructor

EndClass 

 /*/{Protheus.doc} New
	(Método construtor )
	@author Henrique Pereira
	@since 16/09/2020
	@return Nil, nulo, não tem retorno.
/*/

Method New(cSourceBr,cRefStamp) Class TSINFISCAL
	self:cRefStamp 	:= cRefStamp
	self:cUpStamp	:= "" //Proteção para evitar problemas quando não tem nada para integrar
	self:nSizeMax   := 500
	self:nQtNotas   := 0
	self:nProcReg   := 0
	self:RetTabela()
    Self:LoadQuery()
    Self:PrepQuery()
    Self:TempTable()
	Self:CommitRegs()

Return Nil

/*/{Protheus.doc} Create
	(Método construtor para chamadas via API)
	@author Karen Yoshie|José Felipe
	@since 02/01/2022
	@return Nil, nulo, não tem retorno.
/*/

Method Create() Class TSINFISCAL
	self:nSizeMax   := 500
	self:nQtNotas   := 0
	self:nProcReg   := 0

Return self
/*/{Protheus.doc} RetTabela
	Relação das tabelas envolvidas na query
	Segundo indice M = Movimentação C = Cadastro
    @type Class
	@author Henrique Pereira
	@since 16/09/2020
	@return Nil, nulo, não tem retorno.
/*/

Method RetTabela() Class TSINFISCAL
	Local aRet 		:= {}

	if lTableCDT; aadd(aRet,{"CDT","ST"}); endif//ST SetString //01
	if lTableCDT; aadd(aRet,{"CDT","ST"}); endif//ST SetString //02
	aadd(aRet,{"SE2","ST"}) // ST SetString //03
	aadd(aRet,{"SE1","ST"}) // ST SetString //04
	aadd(aRet,{"SF1","ST"}) // ST SetString	//07
	aadd(aRet,{"SD1","ST"}) // ST SetString	//08
	aadd(aRet,{"SA2","ST"})	// ST SetString //09
	aadd(aRet,{"SF2","ST"})	// ST SetString //10
	aadd(aRet,{"SD2","ST"})	// ST SetString //11
	aadd(aRet,{"SA1","ST"})	// ST SetString //12
	aadd(aRet,{"SB1","ST"})	// ST SetString //13
    aadd(aRet,{"SF3","ST"})	// ST SetString //14
	aadd(aRet,{"SF4","ST"})	// ST SetString //15
	aadd(aRet,{"F2Q","ST"})	// ST SetString //16
	aadd(aRet,{"CDN","ST"})	// ST SetString //17
	aadd(aRet,{"CDN","ST"})	// ST SetString //18
	if lTableDT6; aadd(aRet,{"DT6","ST"}); endif // ST SetString //19
	if lTableDHR; aadd(aRet,{"DHR","ST"}); endif // ST SetString //20
	aadd(aRet,{"SFT","ST"}) // ST SetString //21

	self:aTbls := aRet
Return

/*/{Protheus.doc} PrepQuery
	(Método responsável por Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final já com os parâmetros )
    @type Class
	@author Henrique Pereira
	@since 16/09/2020
	@return Nil, nulo, não tem retorno.
/*/

Method PrepQuery() Class TSINFISCAL
	
	Local nx := 0

    self:oStatement := FWPreparedStatement():New()
    self:oStatement:SetQuery(self:TSITQRY)

	for nx := 1 to len(self:aTbls)
		if self:aTbls[nx][2] == "ST" //SetString
			self:oStatement:SetString(nx,xFilial(self:aTbls[nx][1]))
		elseif self:aTbls[nx][2] == "IN" //SetIn
			self:oStatement:SetIn(nx, &("self:aFil" + self:aTbls[nx][1]) )
		endif
	next nx

    self:cFinalQuery := self:oStatement:GetFixQuery()

Return Nil

 /*/{Protheus.doc} LoadQuery
	(Método responsável por montar a query para o preparedstatemen, por hora ainda com '?'
    nos parâmetros variáveis
	@author Henrique Pereira
	@since 16/09/2020
	@return Nil, nulo, não tem retorno.
/*/

Method LoadQuery() Class TSINFISCAL

Local cQuery	:= ""
Local cConcat 	:= ""
Local cDbType 	:= Upper(Alltrim(TCGetDB()))
Local cCoalesce := xFunExpSql( "COALESCE" )
Local lTableTMS := .F. 
Local i			:= 0
Local cUltStmp  := ::cRefStamp
Local cConvSFT	:= ""
Local cConvSF3	:= ""
Local cMaxCDG   := ""
Local cMaxCDT   := ""
Local cTopRow   := ""
Local nTmStmp   := 0

if "ORACLE" $ cDbType //Tratamento para retirar os milesimos apenas no oracle ":000"
	nTmStmp := Len( Alltrim(cUltStmp) )
	cUltStmp := SubSTr( Alltrim(cUltStmp),1, nTmStmp-4 )
	cUltStmp := cUltStmp + ".999"
endif

for i := 1 to len(self:aTbls)
	do case
		case self:aTbls[i][1] == 'DT6'
			lTableTMS := .T.
	endcase
next i

//Converte o conteúdo do campo conforme o banco de dados usado.
if cDbType $ 'MSSQL/MSSQL7'
	cConvSFT := ' CONVERT(VARCHAR(23), SFT.S_T_A_M_P_, 21) '
	cMaxStamp:= ' (SELECT CONVERT(varchar(23), MAX(TABLE.S_T_A_M_P_), 21) '
	cConvSF3 := ' CONVERT(VARCHAR(23), SF3.S_T_A_M_P_, 21) '
elseif cDbType $ 'ORACLE'
	cConvSFT  := " SFT.S_T_A_M_P_ "
	cConvSF3  := " SF3.S_T_A_M_P_ "
	cMaxStamp := " (SELECT MAX(TABLE.S_T_A_M_P_) "
elseif cDbType $ "POSTGRES"
	cConvSFT := ' cast(SFT.S_T_A_M_P_ AS character(23)) '
	cConvSF3 := ' cast(SF3.S_T_A_M_P_ AS character(23)) '
	cMaxStamp := ' (SELECT cast( MAX(TABLE.S_T_A_M_P_) as character(23)) '
endif

cMaxCDG := strtran(cMaxStamp,'TABLE','CDGTOT')
cMaxCDG += "					FROM "+RetSqlName("CDG")+" CDGTOT "
cMaxCDG += "					WHERE CDGTOT.CDG_FILIAL = SFT.FT_FILIAL "
cMaxCDG += "					AND CDGTOT.CDG_TPMOV = SFT.FT_TIPOMOV "
cMaxCDG += "					AND CDGTOT.CDG_DOC = SFT.FT_NFISCAL "
cMaxCDG += "					AND CDGTOT.CDG_SERIE = SFT.FT_SERIE "
cMaxCDG += "					AND CDGTOT.CDG_CLIFOR = SFT.FT_CLIEFOR "
cMaxCDG += "					AND CDGTOT.CDG_LOJA = SFT.FT_LOJA)"

cMaxCDT := strtran(cMaxStamp,'TABLE','CDTTOT')
cMaxCDT += "					FROM "+RetSqlName("CDT")+" CDTTOT
cMaxCDT += "				     WHERE CDTTOT.CDT_FILIAL = SFT.FT_FILIAL
cMaxCDT += "			         AND CDTTOT.CDT_TPMOV = SFT.FT_TIPOMOV
cMaxCDT += "			         AND CDTTOT.CDT_DOC = SFT.FT_NFISCAL
cMaxCDT += "			         AND CDTTOT.CDT_SERIE = SFT.FT_SERIE
cMaxCDT += "				     AND CDTTOT.CDT_CLIFOR = SFT.FT_CLIEFOR
cMaxCDT += "					 AND CDTTOT.CDT_LOJA = SFT.FT_LOJA
cMaxCDT += "					 AND CDTTOT.CDT_IFCOMP <> ' ')"

// VerIfica o tipo de concatenação para o banco
If "MSSQL" $ cDbType
	cConcat := "+"
Else
	cConcat := "||"
EndIf

cQuery := " SELECT DISTINCT "

cQuery += " SFT.R_E_C_N_O_ RECNOSFT "
cQuery += " ,SFT.FT_FILIAL FILIAL "
cQuery += " ,SFT.FT_TIPOMOV TIPOMOV "
cQuery += " ,SFT.FT_NFISCAL NFISCAL "
cQuery += " ,SFT.FT_SERIE SERIE "
cQuery += " ,SFT.FT_CLIEFOR CLIEFOR "
cQuery += " ,SFT.FT_LOJA LOJA "
cQuery += " ,SFT.FT_ITEM ITEM "
cQuery += " ,SFT.FT_IDTRIB IDTRIB "

cQuery += " ,CASE "
cQuery += " WHEN SFT.FT_TIPO = 'S' AND SFT.FT_CODISS <> '' AND SFT.FT_NFELETR <> '' THEN SFT.FT_NFELETR "
cQuery += " ELSE SFT.FT_NFISCAL "
cQuery += " END NUM_DOC "

cQuery += " ,CASE "
cQuery += " WHEN SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('B','D') THEN 'F'"+ cConcat +" SFT.FT_CLIEFOR "+ cConcat +"RTRIM(SFT.FT_LOJA) "
cQuery += " WHEN SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO IN ('B','D') THEN 'C'"+ cConcat +" SFT.FT_CLIEFOR "+ cConcat +"RTRIM(SFT.FT_LOJA) "
cQuery += " WHEN SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO NOT IN ('B','D') THEN 'C'"+ cConcat +" SFT.FT_CLIEFOR "+ cConcat +"RTRIM(SFT.FT_LOJA) "
cQuery += " WHEN SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('B','D') THEN 'F'"+ cConcat +" SFT.FT_CLIEFOR "+ cConcat +"RTRIM(SFT.FT_LOJA) "
cQuery += " END COD_PART "

cQuery += "	,CASE "
cQuery += "	WHEN SFT.FT_TIPOMOV = 'E' THEN SF1.R_E_C_N_O_ "
cQuery += "	ELSE SF2.R_E_C_N_O_ "
cQuery += "	END RECCABEC "

cQuery += "	,CASE "
cQuery += "	WHEN SFT.FT_TIPOMOV = 'E' THEN SD1.R_E_C_N_O_ "
cQuery += "	ELSE SD2.R_E_C_N_O_ "
cQuery += "	END RECITENS "

cQuery += " ," + cCoalesce + "(SA1.R_E_C_N_O_,0) RECSA1 "

cQuery += " ," + cCoalesce + "(SA2.R_E_C_N_O_, 0) RECSA2 "

cQuery += " ," + cCoalesce + "(SF4.R_E_C_N_O_, 0) RECSF4 "

cQuery += " ,SB1.R_E_C_N_O_ RECSB1 "

cQuery += " , CASE "
cQuery += " WHEN SFT.FT_TIPOMOV = 'E' THEN '0' "
cQuery += " ELSE '1' END IND_OPER " // indicador de operação de entrada ou saída

cQuery += " , CASE "
cQuery += " WHEN SFT.FT_TIPO = 'D' THEN '01' "
cQuery += " WHEN SFT.FT_TIPO = 'I' THEN '02' "
cQuery += " WHEN SFT.FT_TIPO = 'P' THEN '03' "
cQuery += " WHEN SFT.FT_TIPO = 'C' THEN '04' "
cQuery += " WHEN SFT.FT_TIPO = 'B' THEN '05' "
cQuery += " WHEN SFT.FT_TIPO = 'S' THEN '06' "
cQuery += " ELSE '00' END TIPO_DOC "

cQuery += " , CASE "
cQuery += " WHEN SFT.FT_FORMUL = 'S' OR ( SFT.FT_FORMUL = ' ' AND SFT.FT_TIPOMOV = 'S' ) THEN '0' "
cQuery += " ELSE '1' "
cQuery += " END IND_EMIT "
 
cQuery += "	,CAST( CASE "
cQuery += "		WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('B','D')) THEN 'SA2' "
cQuery += "		WHEN (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('B','D')) THEN 'SA2' "
cQuery += "		ELSE 'SA1' "
cQuery += "	 END as char(3)) FOR_CLI "

cQuery += " , A2_CALCIRF CALC_IRF"

cQuery += " , SFT.FT_EMISSAO DT_DOC "
cQuery += " , SFT.FT_CHVNFE CHV_DOC_E "

cQuery += " , CASE "
cQuery += " WHEN SFT.FT_TIPOMOV = 'E' THEN SF1.F1_VALBRUT "
cQuery += " WHEN SFT.FT_TIPOMOV = 'S' THEN SF2.F2_VALBRUT "
cQuery += "	END VL_DOC "

//SPEDPROSE1/SPEDPROSE2

cQuery += " , CASE "
cQuery += " WHEN SFT.FT_TIPOMOV = 'E' THEN SF1.F1_DESCONT "
cQuery += " WHEN SFT.FT_TIPOMOV = 'S' THEN SF2.F2_DESCONT "
cQuery += " END VL_DESC "

//amodnot
cQuery += " , SFT.FT_ESPECIE COD_MOD "

cQuery += " , CASE "
cQuery += " WHEN SFT.FT_TIPOMOV = 'E' AND SFT.FT_CODISS = '' AND SFT.FT_TIPO <> 'S' THEN SF1.F1_VALMERC "
cQuery += " WHEN SFT.FT_TIPOMOV = 'S' AND SFT.FT_CODISS = '' AND SFT.FT_TIPO <> 'S' THEN SF2.F2_VALMERC "
cQuery += " END VL_MERC "

cQuery += " , SFT.FT_ENTRADA DT_E_S "

cQuery += " , CASE "
cQuery += " WHEN SFT.FT_TIPOMOV = 'E' THEN SF1.F1_DESPESA "
cQuery += " WHEN SFT.FT_TIPOMOV = 'S' THEN SF2.F2_DESPESA "
cQuery += " END VL_DA "

cQuery += " , CASE "
cQuery += " WHEN SFT.FT_TIPOMOV = 'S' THEN SF2.F2_TPFRETE "
cQuery += " ELSE '' "
cQuery += " END TPFRETE "

cQuery += " , CASE "
cQuery += " WHEN SFT.FT_TIPOMOV = 'E' THEN SF1.F1_SEGURO "
cQuery += " WHEN SFT.FT_TIPOMOV = 'S' THEN SF2.F2_SEGURO "
cQuery += " END VL_SEG "

cQuery += " , CASE "
cQuery += " WHEN SFT.FT_TIPOMOV = 'E' THEN SF1.F1_SEGURO + SF1.F1_DESPESA + SF1.F1_FRETE "
cQuery += " WHEN SFT.FT_TIPOMOV = 'S' THEN SF2.F2_SEGURO + SF2.F2_DESPESA + SF2.F2_FRETE "
cQuery += " END VL_OUT_DESP "

cQuery += " , CASE "
cQuery += " WHEN SFT.FT_TIPOMOV = 'E' THEN SF1.F1_FRETE "
cQuery += " WHEN SFT.FT_TIPOMOV = 'S' THEN SF2.F2_FRETE "
cQuery += " END VL_FRT "

cQuery += " ,SFT.FT_DESCICM + SFT.FT_DESCZFR VL_ABAT_NT "

cQuery += " , CASE "
cQuery += " WHEN SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO = 'S' AND SFT.FT_CODISS <> '' THEN SF1.F1_VALMERC "
cQuery += " WHEN SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO = 'S' AND SFT.FT_CODISS <> '' THEN SF2.F2_VALMERC "
cQuery += " END VL_SERV "

//Adicionado extração do campo _MENNOTA para utilização na função compInfoByTax
//Integração do layout T013AA Informações complementares por documentos fiscais.
cQuery += " , CASE "
cQuery += " WHEN SFT.FT_TIPOMOV = 'E' THEN SF1.F1_MENNOTA "
cQuery += " WHEN SFT.FT_TIPOMOV = 'S' THEN SF2.F2_MENNOTA "
cQuery += " END MENNOTA "

cQuery += " ,SFT.FT_DTCANC DT_CANC "

//Doc Entrada com formulario proprio = nao ou vazio, ao ser excluido apaga registro SFT, nao preenche DT Cancelamento, 
//o tratamento abaixo se faz necessario para que na gravacao, exclua o modelo da C20 e filhos ( C30,C2F,C35... )
//O OBSERV eh preenchido com NF CANCELADA se DT_CANC esta preenchido, nessa situacao devera atualizar a nota no TAF p/ situacao cancelada
//Demais casos a OBSERV eh preenchido com vazio se DT_CANC vazio ( nada acontece ).
cQuery += " , CASE "
cQuery += " WHEN SFT.FT_DTCANC = ' ' AND SFT.FT_FORMUL = ' ' AND (SD1.R_E_C_N_O_ IS NULL OR (SD1.R_E_C_N_O_ IS NOT NULL AND SF1.F1_STATUS<>'A')) AND SFT.FT_TIPOMOV = 'E' AND SFT.D_E_L_E_T_ = '*' THEN 'NF EXCLUIDA' "
cQuery += " ELSE SFT.FT_OBSERV "
cQuery += " END OBSERV "

cQuery += " , CASE "
cQuery += " WHEN SFT.FT_TIPOMOV = 'E' THEN SF1.F1_MODAL "
cQuery += " END MODAL_TRANSP "
cQuery += " ,SFT.FT_ESTADO UF_ORIGEM "

cQuery += " ,SFT.FT_PRODUTO PRODUTO "
if "ORACLE" $ cDbType
	cQuery += " ,( cast(to_char("+cConvSFT+",'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23)) ) STAMP "
else
	cQuery += " ,(" + cConvSFT + ") STAMP "
endif

cQuery += "	,CAST( CASE "
cQuery += "		WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('B','D')) THEN SF1.F1_PREFIXO "
cQuery += "		WHEN (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('B','D')) THEN SF2.F2_PREFIXO "
cQuery += "	 END as char(3)) INDPAG "

cQuery += " , CASE "
cQuery += " WHEN SFT.FT_TIPOMOV = 'E' THEN SF1.F1_ESTPRES "
cQuery += " WHEN SFT.FT_TIPOMOV = 'S' THEN SF2.F2_ESTPRES "
cQuery += " END ESTPRES "

cQuery += " , CASE "
cQuery += " WHEN SFT.FT_TIPOMOV = 'E' THEN SF1.F1_INCISS "
cQuery += " WHEN SFT.FT_TIPOMOV = 'S' THEN SF2.F2_MUNPRES "
cQuery += " END MUNPRES "

cQuery += " ,SFT.FT_TIPO TIPO "

cQuery += " ,SFT.FT_FORMUL FORMUL "

cQuery += " ,SF4.F4_TRFICM TRFICM "
 
cQuery += " ,SF4.F4_ESTCRED ESTCRED "

cQuery += " ,SFT.FT_ESTCRED FTESTCRED "

cQuery += " ,SFT.FT_CFOP CFOP "

cQuery += " ,F2Q.F2Q_TPSERV F2QTPSERV "

cQuery += " ,PROD.CDN_TPSERV PRODTPSERV "

cQuery += " ,PROD.CDN_CODLST PRODCODLST "

cQuery += " ,ISS.CDN_TPSERV ISSTPSERV "

cQuery += " ,ISS.CDN_CODLST ISSCODLST "

If lTableTMS
	cQuery += "	,DT6.DT6_CDRORI DT6CDRORI "
	cQuery += "	,DT6.DT6_CLIDES DT6CLIDES "
	cQuery += "	,DT6.DT6_LOJDES DT6LOJDES "
	cQuery += "	,DT6.DT6_CLIREM DT6CLIREM "
	cQuery += "	,DT6.DT6_LOJREM DT6LOJREM "
	cQuery += "	,DT6.DT6_CDRCAL DT6CDRCAL "
	cQuery += " ,DT6.DT6_DEVFRE "
	cQuery += " ,coalesce(DT6.R_E_C_N_O_,0) RECDT6 "
Else
	cQuery += "	,' ' DT6CDRORI "
	cQuery += "	,' ' DT6CLIDES "
	cQuery += "	,' ' DT6LOJDES "
	cQuery += "	,' ' DT6CLIREM "
	cQuery += "	,' ' DT6LOJREM "
	cQuery += "	,' ' DT6CDRCAL "
	cQuery += " ,' ' DT6_DEVFRE "
	cQuery += " ,0 RECDT6 "	
EndIf

if lTableCDT
	//Subquery para retornar o maior stamp da tabela CDT Informações complementares
	//por documentos fiscais.
	cQuery += ", ( SELECT "
	If cDbType $ "MSSQL/MSSQL7"
		cQuery += " CONVERT(VARCHAR(23), MAX(CDTTOT.S_T_A_M_P_), 21) "
	Elseif cDbType $ "ORACLE"
		cQuery += " cast(to_char( MAX(CDTTOT.S_T_A_M_P_),'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23)) " 
	Elseif cDbType $ "POSTGRES"
		cQuery += " cast(to_char( MAX(CDTTOT.S_T_A_M_P_),'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23)) "
	Endif
	
	cQuery += " FROM " + RetSqlName("CDT") + " CDTTOT "
	cQuery += "	WHERE CDTTOT.CDT_FILIAL = SFT.FT_FILIAL " 
	cQuery += "	AND CDTTOT.CDT_TPMOV = SFT.FT_TIPOMOV "
	cQuery += "	AND CDTTOT.CDT_DOC = SFT.FT_NFISCAL "
	cQuery += "	AND CDTTOT.CDT_SERIE = SFT.FT_SERIE "
	cQuery += "	AND CDTTOT.CDT_CLIFOR = SFT.FT_CLIEFOR "
	cQuery += "	AND CDTTOT.CDT_LOJA = SFT.FT_LOJA "
	cQuery += " AND CDTTOT.CDT_IFCOMP <> ' ' ) CDTSTAMP " 
	
	//Retirei o Delete pois
	// quero que seja integrado novamente o documento fiscal e seus filhos e netos caso uma
	// informação complementar atribuida ao documento fiscal seja excluída.
	//cQuery += "   AND CDTTOT.D_E_L_E_T_ ' ' ) CDTSTAMP "

	cQuery += " , ( SELECT DISTINCT( CDT.CDT_INDFRT ) FROM "
	cQuery += RetSqlName("CDT") + " CDT "
	cQuery += " WHERE CDT.CDT_FILIAL = ? " //par01
	cQuery += " AND CDT.CDT_TPMOV = SFT.FT_TIPOMOV "
	cQuery += " AND CDT.CDT_DOC = SFT.FT_NFISCAL "
	cQuery += " AND CDT.CDT_SERIE = SFT.FT_SERIE "
	cQuery += " AND CDT.CDT_CLIFOR = SFT.FT_CLIEFOR "
	cQuery += " AND CDT.CDT_LOJA = SFT.FT_LOJA "
	cQuery += " AND CDT.D_E_L_E_T_ = ' ' ) CDT_INDFRT "

	cQuery += " , coalesce( ( SELECT MAX( CDT.R_E_C_N_O_ ) FROM "
	cQuery += RetSqlName("CDT") + " CDT "
	cQuery += " WHERE CDT.CDT_FILIAL = ? " //par02
	cQuery += " AND CDT.CDT_TPMOV = SFT.FT_TIPOMOV "
	cQuery += " AND CDT.CDT_DOC = SFT.FT_NFISCAL "
	cQuery += " AND CDT.CDT_SERIE = SFT.FT_SERIE "
	cQuery += " AND CDT.CDT_CLIFOR = SFT.FT_CLIEFOR "
	cQuery += " AND CDT.CDT_LOJA = SFT.FT_LOJA "
	cQuery += " AND CDT.D_E_L_E_T_ = ' ' ),0) RECCDT "
else
	cQuery += ", ' ' CDT_INDFRT"
	cQuery += " ,0 RECCDT "
endif

//------------------------------------------------------------------------------------
// Caso tenha, busco o numero da fatura para utilizar no T013AI (ticketsByInvoice)

cQuery += " , CASE WHEN SFT.FT_TIPOMOV = 'E' THEN (SELECT "

If cDbType $ "ORACLE|POSTGRES"
	cQuery += " SE2.E2_NUM "
	If cDbType $ "ORACLE"
		cTopRow := " AND ROWNUM <= 1 "
	ElseIf cDbType $ "POSTGRES"
		cTopRow := " LIMIT 1 "
	EndIf
ElseIf cDbType $ "MSSQL/MSSQL7"
	cQuery += " TOP 1 SE2.E2_NUM "
Endif

cQuery += " FROM " + RetSqlName("SE2") + " SE2 " + "WHERE "
cQuery += " SE2.E2_FILIAL = ? " //par03
cQuery += " AND SE2.E2_NUM = SF1.F1_DUPL "
cQuery += " AND SE2.E2_FORNECE = SF1.F1_FORNECE "
cQuery += " AND SE2.E2_LOJA = SF1.F1_LOJA "
cQuery += " AND SE2.E2_TITPAI = ' ' "
cQuery += " AND SE2.D_E_L_E_T_ = ' ' "

If cDbType $ "ORACLE"
	cQuery += cTopRow
EndIf

If cDbType $ "POSTGRES"
	cQuery += " ORDER BY SE2.E2_NUM " + cTopRow
EndIf

cQuery += " ) ELSE "
cQuery += " (SELECT "

If cDbType $ "ORACLE|POSTGRES"
	cQuery += " SE1.E1_NUM "
	If cDbType $ "ORACLE"
		cTopRow := " AND ROWNUM <= 1 "
	ElseIf cDbType $ "POSTGRES"
		cTopRow := " LIMIT 1 "
	EndIf
ElseIf cDbType $ "MSSQL/MSSQL7"
	cQuery += " TOP 1 SE1.E1_NUM "
Endif

cQuery += " FROM " + RetSqlName("SE1") + " SE1 " + "WHERE "
cQuery += " SE1.E1_FILIAL = ? " //par04
cQuery += " AND SE1.E1_NUM = SF2.F2_DUPL "
cQuery += " AND SE1.E1_CLIENTE = SF2.F2_CLIENTE "
cQuery += " AND SE1.E1_LOJA = SF2.F2_LOJA "
cQuery += " AND SE1.E1_TITPAI = ' ' "
cQuery += " AND SE1.D_E_L_E_T_ = ' '

If cDbType $ "ORACLE"
	cQuery += cTopRow
EndIf

If cDbType $ "POSTGRES"
	cQuery += " ORDER BY SE1.E1_NUM " + cTopRow
EndIf

cQuery += " ) END NUMFAT "
//------------------------------------------------------------------------------------

if lTableCDG
	//SUBQUERY INDICATIVO DE SUSPENSAO PROCESSOS ADMINISTRATIVOS E JUDICIAIS
	//Existe a possibilidade de retornar registros provenientes da SFT, portanto a subquery ira retornar o stamp maximo da CDG.
	//O complemento lançado no Fiscal para processos referenciados nao eh o responsavel por gerar escrituracao na SFT / SF3.
	cQuery += ", ( SELECT "
	If cDbType $ "MSSQL/MSSQL7"
		cQuery += " CONVERT(VARCHAR(23), MAX(CDG.S_T_A_M_P_), 21) "
	Elseif cDbType $ "ORACLE"
		cQuery += " cast(to_char( MAX(CDG.S_T_A_M_P_),'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23)) " 
	Elseif cDbType $ "POSTGRES"
		cQuery += " cast(to_char( MAX(CDG.S_T_A_M_P_),'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23)) "
	Endif
	cQuery += " FROM " + RetSqlName("CDG") + " CDG "
	cQuery += "WHERE CDG.CDG_FILIAL = SFT.FT_FILIAL AND CDG.CDG_TPMOV = SFT.FT_TIPOMOV AND CDG.CDG_DOC = SFT.FT_NFISCAL AND CDG.CDG_SERIE = SFT.FT_SERIE "
	//cQuery += "AND CDG.CDG_CLIFOR = SFT.FT_CLIEFOR AND CDG.CDG_LOJA = SFT.FT_LOJA AND CDG.CDG_ITEM = SFT.FT_ITEM ) CDGSTAMP "
	cQuery += "AND CDG.CDG_CLIFOR = SFT.FT_CLIEFOR AND CDG.CDG_LOJA = SFT.FT_LOJA ) CDGSTAMP "
	//Importante o filtro do FT_ITEM com CDG_ITEM com FT_ITEM nao eh necessario pois aqui retorna o maior stamp da nota completa.
	//Importante o filtro do D_E_L_E_T_ deverá ser retirado, a query devera retornar o maior stamp independente se foi incluido ou excluido

	cQuery += " , coalesce( ( SELECT MIN( CDG.R_E_C_N_O_ ) FROM "
	cQuery += RetSqlName("CDG") + " CDG "
	cQuery += "WHERE CDG.CDG_FILIAL = SFT.FT_FILIAL AND CDG.CDG_TPMOV = SFT.FT_TIPOMOV AND CDG.CDG_DOC = SFT.FT_NFISCAL AND CDG.CDG_SERIE = SFT.FT_SERIE "
	cQuery += "AND CDG.CDG_CLIFOR = SFT.FT_CLIEFOR AND CDG.CDG_LOJA = SFT.FT_LOJA "
	cQuery += "AND CDG.D_E_L_E_T_ = ' ' ),0) RECCDG "

endif

If lTableDHR
	cQuery += " , DHR.DHR_NATREN NATREN "
	cQuery += " , DHR.R_E_C_N_O_ RECDHR "
EndIf

if lTableSON
	cQuery += " , SON.ON_CNO CNO "
	cQuery += " , SON.ON_TPINSCR TPINSCR "
else
	cQuery += " , ' ' CNO "
	cQuery += " , ' ' TPINSCR "
Endif

//SFT
cQuery += " FROM "
cQuery += RetSqlName("SFT") + " SFT "

//SF1 - Cabecalho Entrada ( necessario devido codigo da transportadora )
cQuery += " LEFT JOIN "
cQuery += RetSqlName("SF1") + " SF1 "
cQuery += " 	ON (SFT.FT_TIPOMOV = 'E') "
cQuery += "		AND SF1.F1_FILIAL = ? " //par07
cQuery += "		AND SF1.F1_DOC = SFT.FT_NFISCAL "
cQuery += "		AND SF1.F1_SERIE = SFT.FT_SERIE "
cQuery += "		AND SF1.F1_FORNECE = SFT.FT_CLIEFOR "
cQuery += "		AND SF1.F1_LOJA = SFT.FT_LOJA "
cQuery += "     AND SF1.F1_ESPECIE = SFT.FT_ESPECIE "
cQuery += "		AND SF1.D_E_L_E_T_ = ' ' "

//SD1 - Itens nota de entrada
cQuery += " LEFT JOIN 
cQuery += RetSqlName( "SD1" ) + " SD1 "
cQuery += " ON SD1.D1_FILIAL = ? " //par08
cQuery += " 	AND SD1.D1_DOC = SFT.FT_NFISCAL "
cQuery += " 	AND SD1.D1_SERIE = SFT.FT_SERIE "
cQuery += " 	AND SD1.D1_FORNECE = SFT.FT_CLIEFOR "
cQuery += " 	AND SD1.D1_LOJA = SFT.FT_LOJA "
cQuery += " 	AND SD1.D1_COD = SFT.FT_PRODUTO "
cQuery += " 	AND SD1.D1_ITEM = SFT.FT_ITEM "
cQuery += " 	AND SD1.D_E_L_E_T_ = ' ' "

//SA2 - Fornecedores
cQuery += " LEFT JOIN "
cQuery += RetSqlName( "SA2" ) + " SA2 "
cQuery += "		ON ((SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ( 'B', 'D' )) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ( 'B', 'D' ))) "
cQuery += " 	AND SA2.A2_FILIAL = ? " //par09
cQuery += " 	AND SA2.A2_COD = SFT.FT_CLIEFOR "
cQuery += " 	AND SA2.A2_LOJA = SFT.FT_LOJA "
cQuery += " 	AND SA2.D_E_L_E_T_ = ' ' "

//SF2 - Cabecalho Saida ( necessario devido codigo da transportadora )
cQuery += " LEFT JOIN "
cQuery += RetSqlName( "SF2" ) + " SF2 "
cQuery += " 	ON (SFT.FT_TIPOMOV = 'S') "
cQuery += "		AND SF2.F2_FILIAL = ? " //par10
cQuery += "		AND SF2.F2_DOC = SFT.FT_NFISCAL "
cQuery += "		AND SF2.F2_SERIE = SFT.FT_SERIE "
cQuery += "		AND SF2.F2_CLIENTE = SFT.FT_CLIEFOR "
cQuery += "		AND SF2.F2_LOJA = SFT.FT_LOJA "
cQuery += "		AND (SF2.D_E_L_E_T_ = ' ' ) "

//SD2 - Itens nota de saída
cQuery += " LEFT JOIN "
cQuery += RetSqlName( "SD2" ) + " SD2 "
cQuery += "		ON SD2.D2_FILIAL = ? " //par11
cQuery += " 	AND SD2.D2_DOC = SFT.FT_NFISCAL "
cQuery += " 	AND SD2.D2_SERIE = SFT.FT_SERIE "
cQuery += " 	AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR "
cQuery += " 	AND SD2.D2_LOJA = SFT.FT_LOJA "
cQuery += " 	AND SD2.D2_COD = SFT.FT_PRODUTO "
cQuery += " 	AND SD2.D2_ITEM = SFT.FT_ITEM "
cQuery += "		AND SD2.D_E_L_E_T_ = ' ' "

//SA1 - Clientes
cQuery += "	LEFT JOIN "
cQuery += RetSqlName( "SA1" ) + " SA1 "
cQuery += " ON ((SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO NOT IN ( 'B', 'D' )) OR (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO IN ( 'B', 'D' ))) "
cQuery += "		AND SA1.A1_FILIAL = ? " //par12
cQuery += "		AND SA1.A1_COD = SFT.FT_CLIEFOR "
cQuery += "		AND SA1.A1_LOJA = SFT.FT_LOJA "
cQuery += "		AND SA1.D_E_L_E_T_ = ' ' "

//SB1 - Produtos
cQuery += " LEFT JOIN "
cQuery += RetSqlName( "SB1" ) + " SB1 "
cQuery += "		ON SB1.B1_FILIAL = ? " //par13
cQuery += " 	AND SB1.B1_COD = SFT.FT_PRODUTO "
cQuery += " 	AND SB1.D_E_L_E_T_ = ' ' "

//SF3 - Livros fiscais
cQuery += " INNER JOIN "
cQuery += RetSqlName("SF3") + " SF3 "
cQuery += "		ON SF3.F3_FILIAL = ? " //par14
cQuery += "		AND SF3.F3_NFISCAL = SFT.FT_NFISCAL "
cQuery += "		AND SF3.F3_SERIE = SFT.FT_SERIE "
cQuery += "		AND SF3.F3_CLIEFOR = SFT.FT_CLIEFOR "
cQuery += "		AND SF3.F3_LOJA = SFT.FT_LOJA "
cQuery += "		AND SF3.F3_IDENTFT = SFT.FT_IDENTF3 "
cQuery += "		AND SF3.F3_ENTRADA = SFT.FT_ENTRADA "
cQuery += "		AND SF3.F3_ESPECIE = SFT.FT_ESPECIE "
cQuery += "		AND (SF3.D_E_L_E_T_ = ' ' "
cQuery += "			OR ( SF3.D_E_L_E_T_ = '*' AND SF3.F3_FORMUL = ' ' AND SF3.F3_DTCANC = ' ' ) " //Considera Excluidos na Entrada com Formulario Proprio Nao
cQuery += "		) "

cQuery += " AND SF3.S_T_A_M_P_ IS NOT NULL "

if "ORACLE" $ cDbType
	cQuery += " AND (" + cConvSF3 + " > TO_TIMESTAMP('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff')  "
else
	cQuery += " AND (" + cConvSF3 + " > '" + cUltStmp + "' "
endif
cQuery += " ) "

//SF4 - TES
cQuery += " INNER JOIN "
cQuery += RetSqlName("SF4") + " SF4 "
cQuery += " 	ON SF4.F4_FILIAL = ? " //par15
cQuery += " 	AND (SF4.F4_MSBLQL = '2' OR SF4.F4_MSBLQL = ' ') "
cQuery += " 	AND SF4.F4_CODIGO = SFT.FT_TES "
cQuery += " 	AND SF4.D_E_L_E_T_ = ' ' "

//F2Q - Complemento Fiscal
cQuery += " LEFT JOIN "
cQuery += RetSqlName( "F2Q" ) + " F2Q "
cQuery += "		ON F2Q.F2Q_FILIAL = ? " //par16
cQuery += " 	AND F2Q.F2Q_PRODUT = SFT.FT_PRODUTO "
cQuery += " 	AND F2Q.D_E_L_E_T_ = ' ' "

//CDN - Cod. ISS
cQuery += " LEFT JOIN "
cQuery += RetSqlName("CDN") + " PROD "
cQuery += "		ON  PROD.CDN_FILIAL = ? " //par17
cQuery += "		AND PROD.CDN_CODISS = SFT.FT_CODISS "
cQuery += "		AND PROD.CDN_PROD = SFT.FT_PRODUTO "
cQuery += "		AND PROD.D_E_L_E_T_ = ' ' "

//CDN - Cod. ISS
cQuery += " LEFT JOIN "
cQuery += RetSqlName("CDN") + " ISS "
cQuery += " 	ON ISS.CDN_FILIAL = ? " //par18
cQuery += " 	AND ISS.CDN_CODISS = SFT.FT_CODISS "
cQuery += " 	AND ISS.CDN_PROD = ' ' "
cQuery += " 	AND ISS.D_E_L_E_T_ = ' ' "

If lTableTMS
	//Documentos de Transporte
	cQuery += " LEFT JOIN "
	cQuery += RetSqlName("DT6") + " DT6 "
	cQuery += " 	ON DT6.DT6_FILIAL = ? " //par19
	cQuery += " 	AND DT6.DT6_FILDOC = SFT.FT_FILIAL " //DT6_FILIAL, DT6_FILDOC, DT6_DOC, DT6_SERIE, R_E_C_N_O_, D_E_L_E_T_
	cQuery += " 	AND DT6.DT6_DOC = SFT.FT_NFISCAL "
	cQuery += " 	AND DT6.DT6_SERIE = SFT.FT_SERIE "
	cQuery += " 	AND DT6.D_E_L_E_T_ = ' ' "
EndIf

If lTableDHR
	//NF x Natureza de Rendimento
	cQuery += " LEFT JOIN "
	cQuery += RetSqlName("DHR") + " DHR "
	cQuery += " 	ON DHR.DHR_FILIAL = ? " //par20
	cQuery += " 	AND DHR.DHR_DOC = SFT.FT_NFISCAL " //DT6_FILIAL, DT6_FILDOC, DT6_DOC, DT6_SERIE, R_E_C_N_O_, D_E_L_E_T_
	cQuery += " 	AND DHR.DHR_SERIE = SFT.FT_SERIE "
	cQuery += " 	AND DHR.DHR_FORNEC = SFT.FT_CLIEFOR "
	cQuery += " 	AND DHR.DHR_LOJA = SFT.FT_LOJA "
	cQuery += " 	AND DHR.DHR_ITEM = SFT.FT_ITEM "
	cQuery += " 	AND DHR.D_E_L_E_T_ = ' ' "
EndIf

If ChkFile("SON",.F.)
	dbSelectArea("SON")
	// CNO - Cadastro Nacional de Obras
	cQuery += " LEFT JOIN " 
	cQuery += RetSqlName( "SON" ) + " SON "
	cQuery += " ON (SON.ON_CODIGO = "
	cQuery += " CASE "
	cQuery += "  WHEN ( SFT.FT_TIPOMOV = 'S' ) THEN SF2.F2_CNO "
	cQuery += "  WHEN ( SFT.FT_TIPOMOV = 'E' ) THEN SD1.D1_CNO "
	cQuery += " END "
	cQuery += " AND SON.ON_FILIAL = '" + xFilial( "SON" ) + "' " 
	cQuery += " AND SON.D_E_L_E_T_ = ' ' ) "
Endif

cQuery += " WHERE "
cQuery += " 	SFT.FT_FILIAL = ? " //par21
cQuery += " 	AND ( SFT.D_E_L_E_T_ = ' ' "

cQuery += " OR ( SFT.D_E_L_E_T_ = '*' AND (SD1.R_E_C_N_O_ IS NULL OR (SD1.R_E_C_N_O_ IS NOT NULL AND SF1.F1_STATUS<>'A')) AND SFT.FT_TIPOMOV = 'E' AND SFT.FT_FORMUL = ' ' "
cQuery += " ) "

cQuery += " ) "

cQuery += " AND SFT.S_T_A_M_P_ IS NOT NULL "

if "ORACLE" $ cDbType
	cQuery += " AND (" + cConvSFT + " > TO_TIMESTAMP('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff')  "
else
	cQuery += " AND (" + cConvSFT + " > '" + cUltStmp + "' "
endif

//Passa a comparar tambem o complemento do processo referenciado do ERP com o TAF, caso exista CDG superior a C20,
//ira trazer o registro, consequentemente a subquery ira indicar se existe processos vinculados a nota.
if lTableCDG
	cQuery += " OR "
	if "ORACLE" $ cDbType
		cQuery += cMaxCDG +" > TO_TIMESTAMP('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff')  "
	else
		cQuery += cMaxCDG +" > '" + cUltStmp + "' "
	Endif
endif   

// Comparo com o campo C20.STAMP o maior Stamp da tabela CDT retornado na subquery.
// Isso precisa ser feito pois pode ser adicionado uma informação complementar a um documento fiscal sem que o stamp da tabela SFT sejá atualizado,
// ficando assim o Stamp da tabela CDT maior que o Stamp da tabela SFT.
if lTableCDT
	cQuery += " OR "
	if "ORACLE" $ cDbType
		cQuery += cMaxCDT +" > TO_TIMESTAMP('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff')  "
	else
		cQuery += cMaxCDT +" > '" + cUltStmp + "' "
	Endif
endif
cQuery += " ) "

cQuery += " ORDER BY "
cQuery += " 	TIPOMOV "
cQuery += " 	,NUM_DOC "
cQuery += " 	,SERIE "
cQuery += " 	,COD_PART "
cQuery += " 	,COD_MOD "
cQuery += " 	,ITEM "

self:TSITQRY := cQuery
cQuery := ''

Return Nil

 /*/{Protheus.doc} TempTable
 Execucao da query
	@author Denis Souza / Karen
	@since 09/12/2021
	@return Nil, nulo, não tem retorno.
/*/
Method TempTable() Class TSINFISCAL

	Self:cAlias := getNextAlias( )
	TAFConOut("TSILOG000034: Execucao da query de extracao das notas [ Início query TSILOG000034 " + TIME() + " ]" + self:GetQry(), 1, .f., "TSI" )
  	dbUseArea( .T., "TOPCONN", TCGenQry( ,, self:GetQry( ) ), Self:cAlias, .F., .T. )
	TAFConOut("TSILOG000034: [ Fim query TSILOG000034 " + TIME(), 1, .f., "TSI" )

	//TafConout("Utilizando a tabela temporária "+self:oTempTable:GetRealName() +" - Thread " + cValtoChar(ThreadId()),1,.t.,"TSI")
	//(Self:cAlias)->(dbGoTop())
	//(Self:cAlias )->(DBEVAL({|| self:nTotReg++,InsertTmp(self:cTmpTable,Self:cAlias) }))
	//(Self:cAlias)->(dbGoTop())

	TafConout( "TSILOG000027 - Processando query de extracao de Notas Fiscais " + alltrim(cEmpAnt+"|"+cFilAnt),1,.t.,"TSI")
	//TafConout( "Serao processados os stamps que estao no range "+ RangeStamp(self:oTempTable) +"- Thread " + cValtoChar(ThreadId()),1,.t.,"TSI")

Return Nil
/*/{Protheus.doc} GetQry
	(Método responsável por retornar a propriedade self:cFinalQuery
	@author Henrique Pereira / Denis Souza
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method GetQry() Class TSINFISCAL
return self:cFinalQuery

 /*/{Protheus.doc} GetJsn
Gerar o json completo por nota x itens
	@author Denis Souza / Karen
	@since 09/12/2021
	@return Nil, nulo, não tem retorno.
/*/
Method GetJsn() Class TSINFISCAL

Local oJObjRet   := nil
Local cChaveSFT  := ""
Local cEspecie   := ""
Local cCodSit    := ""
Local cOpcCanc   := ""
Local aPartDoc   :={}
Local aRegT013AP :={}
Local aClasFis   :={}
Local nLen       := 0
Local lFirstItem := .T.
Local lNextNota  := .F. // Variavel utilizada para controlar montagem do array otherTaxObligationsAdjustmentsAndInformation -> antigo T013AM
Local cIndFrt    := ''
Local cIndPagto  := ''
Local cUltStamp  := ''
Local cStamp     := ''
Local lExit      := .F.
Local lAchouDT6  := .F.
Local lCdOri     := .F.
Local cEstDUY    := ""
Local cNotaUF    := ""
Local aAreaSA1   := {}
Local aPartREM   := {}
Local cUFRem     := ""
Local aPartDES   := {}
Local cUFDes     := {}
Local nSomaItem  := 0
Local cGetDUY    := ""
Local lSeekDUY 	 := .F.
Local nRecnoCDG  := 0
Local nRecnoDHR  := 0

//If ( self:cAlias )->( !EOF( ) )

	lFirstItem := .T.
	lNextNota  := .T. 
	cUltStamp  := ''

	// Função para posicionar nas tabelas referente ao cabeçalho
	fPosTabCab( ( self:cAlias )->TIPOMOV, ( self:cAlias )->FOR_CLI, ( self:cAlias )->RECCABEC, ( self:cAlias )->RECSA1, ( self:cAlias )->RECSA2 )

	cChaveSFT  := ( self:cAlias )->( TIPOMOV + SERIE + NUM_DOC + COD_PART + COD_MOD )

	// Variáveis T013AP - TRIBUTOS CAPA DOCUMENTO FISCAL
	cEspecie   := AModNot( AllTrim( ( self:cAlias )->COD_MOD ) )
	aPartDoc   := TafPartic( ( self:cAlias )->FOR_CLI )
	aRegT013AP := { }

	/*Notas fiscais de transportes vindas do TMS sempre deverah haver um DT6 correspondente, 
	caso nao haja, saltar para a proxima nota. Instrucoes passadas pela equipe do TMS.*/
	if lIntTms .And. (self:cAlias)->RECDT6 = 0 .And. (self:cAlias)->TIPOMOV == "S" .And. cEspecie $ "|07|08|09|10|11|26|27|57" .And. Empty((self:cAlias)->DT_CANC)
		//importante: se pular o registro devera incrementar o contador acumulado
		self:nProcReg++ //contador acumulado
		//Tafconout('DbSkip '+(self:cAlias)->NUM_DOC+"- Thread " + cValtoChar(ThreadId()),1,.t.,"TSI")
		(self:cAlias)->(DbSkip()) 
		lExit := .T.
	endif

	if !lExit
		//Tafconout('Processando NF '+(self:cAlias)->NUM_DOC+"- Thread " + cValtoChar(ThreadId()),1,.t.,"TSI")

		oJObjRet := JsonObject( ):New( )
		oJObjRet[cTagJs] := { }
		nSomaItem := 0
		While !(self:cAlias)->(Eof()) .And. cChaveSFT == ( self:cAlias )->( TIPOMOV + SERIE + NUM_DOC + COD_PART + COD_MOD ) 

			aRegT015AE := { }

			//Posiciona tabela de itens
			fPosTabItm( ( self:cAlias )->TIPOMOV, ( self:cAlias )->RECNOSFT, ( self:cAlias )->RECITENS, ( self:cAlias )->RECSF4, ( self:cAlias )->RECSB1 )

			//Monta a capa do documento somentete uma vez, esse laço é para montagem dos itens que vem logo apos esse "if".
			If lFirstItem

				/*-------------------------------
				| Contador por cabecalho de nota |
				--------------------------------*/
				self:nQtNotas++
				lFirstItem := .F.   

				IndFrete(self:cAlias,@cIndFrt,@cCodSit,@cOpcCanc,cEspecie)
				cIndPagto := '9'
				
				aAdd( oJObjRet[cTagJs],JsonObject():New())
				nLen := Len(oJObjRet[cTagJs])		

				cNotaUF := Alltrim( ( self:cAlias )->UF_ORIGEM )

				/*
				Regra1) Necessario considerar a UF do cálculo no TMS.
				As regras com os campos de Remetente e Destinatário não definem as UFs que foram pagos o ICMS, 
				causando divergência na operação. O TMS possui um campo para definir esta operação 
				DT6_CDRCAL ( Codigo Regiao Calculo ). Através deste campo, precisamos fazer um seek na DUY
				e pegar o conteúdo do DUY_EST para esta região. Caso o DUY_EST seja igual ao MV_ESTADO, 
				iremos fazer a mesma busca, porém com a região informada no DT6_CDRORI ( Codigo Regiao Origem )

				Regra2) Tratamento de UF na nota referente ao TMS, o cliente possui um lançamento de nota fiscal de transporte,
				onde o transporte eh de responsabilidade do pagador do frete (FOB), mas o tratamento de UF
				nao deve levar em consideracao o Estado do pagador do frete e sim o do destinatario da mercadoria.
				No Protheus a opcao eh configuravel atraves do parametro MV_TMSUFPG com conteúdo F - Destinatário da Mercadoria.
				*/

				lAchouDT6 := ( self:cAlias )->RECDT6 > 0
				If lAchouDT6 .And. lTableDT6 .And.  ( self:cAlias )->TIPOMOV == "S"
					lCdOri   := .F.
					cEstDUY  := ""
					aAreaSA1 := {}
					aPartREM := {}
					cUFRem := ""
					aPartDES := {}
					cUFDes := {}

					if !Empty(( self:cAlias )->DT6CDRCAL) .Or. !Empty(( self:cAlias )->DT6CDRORI) //Regra1
						If Select("DUY") == 0
							DbSelectArea("DUY")
						EndIf
						
						if Upper(Alltrim( DUY->(IndexKey()))) <> "DUY_FILIAL+DUY_GRPVEN"
							DUY->(DbSetOrder(1)) //DUY_FILIAL, DUY_GRPVEN
						endif
						cGetDUY := ""
						lSeekDUY := GetDUY(xFilial('DUY') + ( self:cAlias )->DT6CDRCAL, @cGetDUY)
						If lSeekDUY
							if Upper(Alltrim(cGetDUY)) == Upper(Alltrim(cMVEstado))
								lCdOri := .T.
							else
								cEstDUY := Upper(Alltrim(cGetDUY))
							endif
						else
							lCdOri := .T.
						endif

						if lCdOri
							cGetDUY := ""
							lSeekDUY := GetDUY(xFilial('DUY') + ( self:cAlias )->DT6CDRORI, @cGetDUY) 
							if lSeekDUY
								if Upper(Alltrim(cGetDUY)) <> Upper(Alltrim(cMVEstado))
									cEstDUY := Upper(Alltrim(cGetDUY))
								endif
							endif
						endif
						if !Empty( cEstDUY )
							cNotaUF := cEstDUY
						endif
					endif

					if Empty(cEstDUY) .And. !lTmsUfPg //Regra2
						aAreaSA1 := SA1->( GetArea() )
						if Upper(Alltrim( SA1->(IndexKey()))) <> "A1_FILIAL+A1_COD+A1_LOJA"
							SA1->(DbSetOrder(1)) //A1_FILIAL, A1_COD, A1_LOJA
						endif

						If SA1->(MsSeek(xFilial("SA1")+( self:cAlias )->(DT6CLIREM+DT6LOJREM)))
							aPartREM := TafPartic("SA1")
							if Valtype( aPartREM ) == "A" .And. Len( aPartREM ) >= 2
								cUFRem := aPartREM[2] //estado
							endif
						EndIf

						If SA1->(MsSeek(xFilial("SA1")+( self:cAlias )->(DT6CLIDES+DT6LOJDES)))
							aPartDES := TafPartic("SA1")
							if Valtype( aPartDES ) == "A" .And. Len( aPartDES ) >= 2
								cUFDes := aPartDES[2] //estado
							endif
						EndIf
						RestArea(aAreaSA1)
						if SubStr(Alltrim( ( self:cAlias )->CFOP),1,1)=="6"
							if Upper(Alltrim(cUFDes)) <> Upper(Alltrim(cMVEstado))
								cNotaUF := cUFDes //Destinatario
							else
								cNotaUF := cUFRem //Remetente
							endif
						endif
					endif
				endif

				oJObjRet[cTagJs][nLen]["operationType"] 				:= alltrim((self:cAlias)->IND_OPER)    					// 2 - IND_OPER
				oJObjRet[cTagJs][nLen]["documentType" ] 				:= alltrim((self:cAlias)->TIPO_DOC)    					// 3 - TIPO_DOC -> De/Para na query -> FDeParaTAF( )
				oJObjRet[cTagJs][nLen]["taxDocumentIssuer" ] 			:= alltrim((self:cAlias)->IND_EMIT)    					// 4 - IND_EMIT -> De/Para na query
				oJObjRet[cTagJs][nLen]["participatingCode" ] 			:= alltrim((self:cAlias)->COD_PART)  					// 5 - COD_PART
				oJObjRet[cTagJs][nLen]["identificationSituation" ] 		:= cCodSit    	                    					// 6 - COD_SIT  SPEDSITDOC( ) 
				oJObjRet[cTagJs][nLen]["taxDocumentSeries" ] 			:= alltrim((self:cAlias)->SERIE)     					// 7 - SER 
				oJObjRet[cTagJs][nLen]["taxDocumentNumber" ] 			:= alltrim((self:cAlias)->NUM_DOC)     					// 9 - NUM_DOC 
				oJObjRet[cTagJs][nLen]["fiscalDocumentDate" ] 			:= dtoc(sTod((self:cAlias)->DT_DOC))      				// 10 - DT_DOC 
				oJObjRet[cTagJs][nLen]["electronicKeyDocument" ] 		:= alltrim((self:cAlias)->CHV_DOC_E)   					// 11 - CHV_DOC_E
				oJObjRet[cTagJs][nLen]["documentValue" ] 				:= toNumeric((self:cAlias)->VL_DOC)  	  				// 12 - VL_DOC 
				oJObjRet[cTagJs][nLen]["typeOfPayment" ] 				:= alltrim(cIndPagto)    								// 13 - IND_PGTO
				oJObjRet[cTagJs][nLen]["discountAmount" ] 				:= toNumeric((self:cAlias)->VL_DESC)     				// 14 - VL_DESC
				oJObjRet[cTagJs][nLen]["modelIdentificationCode"]		:= cEspecie					     						// 15 - COD_MOD -> AModNot( )
				oJObjRet[cTagJs][nLen]["finalDocumentNumber"]			:= alltrim((self:cAlias)->NUM_DOC) 						// 16 - NUM_DOC_FIN
				oJObjRet[cTagJs][nLen]["valueOfGoods"]					:= toNumeric((self:cAlias)->VL_MERC) 					// 18 - VL_MERC
				oJObjRet[cTagJs][nLen]["taxDocumentEntryAndExitDate"]	:= dtoc(sTod((self:cAlias)->DT_E_S)) 					// 19 - DT_E_S
				oJObjRet[cTagJs][nLen]["amountOfAccessoryExpenses"]		:= toNumeric((self:cAlias)->VL_DA) 						// 20 - VL_DA 
				oJObjRet[cTagJs][nLen]["shippingIndicator"]				:= alltrim(cIndFrt)										// 25 - IND_FRT
				oJObjRet[cTagJs][nLen]["insuranceAmount"]				:= toNumeric((self:cAlias)->VL_SEG)						// 26 - VL_SEG
				oJObjRet[cTagJs][nLen]["otherExpenses"]					:= toNumeric((self:cAlias)->VL_OUT_DESP) 				// 27 - VL_OUT_DESP
				oJObjRet[cTagJs][nLen]["freight"]						:= toNumeric((self:cAlias)->VL_FRT) 					// 28 - VL_FRT
				oJObjRet[cTagJs][nLen]["untaxedAllowanceAmount"]		:= toNumeric((self:cAlias)->VL_ABAT_NT) 				// 30 - VL_ABAT_NT
				oJObjRet[cTagJs][nLen]["AIDFNumber"]					:= Taf558Aidf( (self:cAlias)->NUM_DOC, (self:cAlias)->SERIE ) // 31 - NUM_AUT
				oJObjRet[cTagJs][nLen]["valueOfServices"]				:= toNumeric((self:cAlias)->VL_SERV) 					// 38 - VL_SERV
				oJObjRet[cTagJs][nLen]["invoiceCancellationDate"]		:= alltrim((self:cAlias)->DT_CANC) 						// 56 - DT_CANC
				oJObjRet[cTagJs][nLen]["placeOfDelivery"]				:= Alltrim(LocPrestac(self:cAlias))						// 62 - LOC_PRESTACAO  
				oJObjRet[cTagJs][nLen]["valueReducedISSMaterials"]		:= abatMat(self:cAlias)									// 63 - VL_DED_ISS_MAT   			 
				oJObjRet[cTagJs][nLen]["federativeUnitOrigin"]		    := cNotaUF   				// 69 - UF_ORIGEM
				oJObjRet[cTagJs][nLen]["opCancelation"]				 	:= cOpcCanc												//Tag Generica para saber se atualiza ou deleta nota no TAF
				oJObjRet[cTagJs][nLen]["stamp"] 						:= (self:cAlias)->STAMP           						// 9 - STAMP
				oJObjRet[cTagJs][nLen]["paymentIndicator"] 				:= (self:cAlias)->INDPAG             					// 100 - Indicador de pagamento 
				oJObjRet[cTagJs][nLen]["registrationType"] 				:= alltrim( (self:cAlias)->TPINSCR )					// 70 -TP_INSCRICAO
				oJObjRet[cTagJs][nLen]["cnoNumber"] 					:= alltrim( (self:cAlias)->CNO )						// 65 -NR_INSC_ESTAB

				oJObjRet[cTagJs][nLen]["clieFor"] 				    	:= (self:cAlias)->CLIEFOR //Nao existe no Hash, utilizado apenas na alteracao fake da SFT ( V5R x C20 )
				oJObjRet[cTagJs][nLen]["loja"] 				    		:= (self:cAlias)->LOJA    //Nao existe no Hash, utilizado apenas na alteracao fake da SFT ( V5R x C20 )


				oJObjRet[cTagJs][nLen][cTagT015] := { } //para o primeiro item da nota cria o array no json
			
				//Gera json complementaryInfoText layout T013AA
				if lTableCDT .And. !Empty((self:cAlias)->CDTSTAMP) .And. Alltrim(cEspecie) $ "01|1B|04|55"
					oJObjRet[cTagJs][nLen][cTag013AA] := { }
					compInfoByTax( self:cAlias, @oJObjRet, nLen )
				Endif

				//Gera json tickets layout T013AI
				If !Empty((self:cAlias)->NUMFAT)
					oJObjRet[cTagJs][nLen][cTag013AI] := { }
					ticketsByInvoice( self:cAlias, @oJObjRet, nLen )
				Endif

			EndIf

			//gera array otherTaxObligationsAdjustmentsAndInformation -> antigo T013M
			Taf574CDA( self:cAlias, @oJObjRet, nLen, lNextNota )

			lNextNota := .F.

			aClasFis := SPDRetCCST( "SFT", .T., cEspecie, "SF4", "SB1", aPartDoc[02] )

			If Len( AllTrim( aClasFis[1] ) ) == 3 // Sempre que for tamanho 3 , o imposto é ICMS
				aClasFis[1] := SubStr( aClasFis[1], 2, 2 )
			EndIf

			/*
				Utiliando a função FBusTribNf no extrator anterior ( EXTFISXTAF ),
				o array aRegT015AE é alimentado/acumulado de acordo com os itens da nota que são pecorridos ( dbsKip ), 
				e ao passar para a próxima nota, o array é descarregado em txt/banco.

				Para o TSI, o array aRegT015AE é alimentado e descarregado em json no mesmo momento em que o item é pecorrido, 
				ou seja, o array não é mais acumulado, por isso é passado o valor "1" no 5o parametro.
			*/
			nRecnoCDG := 0
			If lTableCDG
				nRecnoCDG := (self:cAlias)->RECCDG
			EndIf
			nRecnoDHR := 0
			If lTableDHR
				nRecnoDHR := (self:cAlias)->RECDHR
			EndIf	
			If Empty(AllTrim((self:cAlias)->IDTRIB))
				FBusTribNf( cEspecie, aPartDoc, @aRegT013AP, @aRegT015AE, 1,,,,,,, @aClasFis, nRecnoCDG,,,,,, nRecnoDHR)
			Else
				//Caso exista IDTRIB na SFT, será enviado como parâmetro para que seja feita a busca na tabela F2D (Impostos calculados pelo configurador de tributos FISA170)
				FBusTribNf( cEspecie, aPartDoc, @aRegT013AP, @aRegT015AE, 1,,,,,,, @aClasFis, nRecnoCDG, (self:cAlias)->FILIAL, Alltrim((self:cAlias)->IDTRIB),,,,nRecnoDHR)
			Endif

			//T015 - Cadastro dos Itens dos Documentos Fiscais
			nSomaItem++
			//Tafconout('Adicionando itens para NF '+(self:cAlias)->NUM_DOC+"- Thread " + cValtoChar(ThreadId()),1,.t.,"TSI")
			fiscalDocumentItems( @self, self:cAlias, @oJObjRet, nLen, aRegT015AE, nSomaItem ) //inseri o item da nota

			//Comparo o ultimo stamp gravado com o atual e atualizao a variavel caso seja verdadeiro.
			if lTableCDG //controle para saber se o stamp do complemento da nota processo judicial eh superior ao da SFT T0015Ak
				if !FindFunction('TsiCompStamp')
					cStamp := iif( Alltrim((self:cAlias)->STAMP) >= Alltrim((self:cAlias)->CDGSTAMP) , Alltrim((self:cAlias)->STAMP), Alltrim((self:cAlias)->CDGSTAMP) )
				else
					cStamp := iif( TsiCompStamp(AllTrim((self:cAlias)->STAMP),  Alltrim((self:cAlias)->CDGSTAMP)) , AllTrim((self:cAlias)->STAMP),  Alltrim((self:cAlias)->CDGSTAMP) )
				Endif
			else
				cStamp := Alltrim((self:cAlias)->STAMP)
			endif

			//Controle para saber se o stamp da informação complementar (CDT) T013AA é superior ao armazezado na varável cStamp
			if lTableCDT
				if !FindFunction('TsiCompStamp')
					cStamp := iif( AllTrim((self:cAlias)->CDTSTAMP) > cStamp , AllTrim((self:cAlias)->CDTSTAMP), cStamp )
				else
					cStamp := iif( TsiCompStamp(AllTrim((self:cAlias)->CDTSTAMP), cStamp) , AllTrim((self:cAlias)->CDTSTAMP), cStamp )
				Endif
			endif

			if iif(FindFunction('TsiCompStamp'),TsiCompStamp(cStamp, cUltStamp),cStamp > cUltStamp)
				cUltStamp := cStamp
			endif
			( self:cAlias )->( DbSkip( ) )
		EndDo

		// gera array valueByTax -> Antigo T013AP
		valueByTax( @oJObjRet[cTagJs][nLen], aRegT013AP )

		//Gravo no stamp do cabecalho o maior stamp encontrado entre os intens do documento fiscal
		oJObjRet[cTagJs][ len(oJObjRet[cTagJs]) ]['stamp'] := cUltStamp
	endif
//endif

Return oJObjRet

/*/{Protheus.doc} CommitRegs
    (Método responsável por realizar a gravação dos dados)
    @author Denis Souza / Karen
    @since 09/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
/*/
Method CommitRegs( ) Class TSINFISCAL

Local oBjJson    := Nil
Local oModel     := Nil
Local oMldC20    := Nil
Local oMldC30    := Nil
Local oMldC35    := Nil
Local oMldC39    := Nil
Local oMldT9Q    := Nil
Local oMldC2F    := Nil
Local oMldC2D    := Nil
Local oMldC21    := Nil
Local oMldC29    := Nil
Local lERP       := .T.
Local oObjApi    := Nil //para extracao nao utiliza esse objeto
Local aObjRet    := {}
//Local nRegNot    := 0

oModel  := FwLoadModel( "TAFA062" ) //Carrego modelo fora do laco
oMldC20 := oModel:GetModel( 'MODEL_C20' )
oMldC30 := oModel:GetModel( 'MODEL_C30' )
oMldC35 := oModel:GetModel( 'MODEL_C35' )
oMldC39 := oModel:GetModel( 'MODEL_C39' )
oMldT9Q := oModel:GetModel( 'MODEL_T9Q' )
oMldC2F := oModel:GetModel( 'MODEL_C2F' )
oMldC2D := oModel:GetModel( 'MODEL_C2D' )
oMldC21 := oModel:GetModel( 'MODEL_C21' )
oMldC29 := oModel:GetModel( 'MODEL_C29' )

DbSelectArea("V5R")
V5R->(DbSetOrder(1)) //V5R_FILIAL, V5R_CODFIL, V5R_ALIAS, V5R_REGKEY

DbSelectArea("C20")
C20->(DbSetOrder(5)) //C20_FILIAL, C20_INDOPE, C20_CODMOD, C20_SERIE, C20_SUBSER, C20_NUMDOC, C20_DTDOC, C20_CODPAR, C20_CODSIT, C20_PROCID

(Self:cAlias)->(dbGoTop())
while (Self:cAlias)->(!EOF())
	//Montagem do json por notas x itens (ou seja para o primeiro registro eh possivel ter N itens que serao percorridos no dbskip dentro da GetJsn)
	oBjJson := Self:GetJsn()

	//Tafconout('Dentro do while NF '+iif(Empty((self:cAlias)->NUM_DOC),'VAZIA',(self:cAlias)->NUM_DOC)+"- Thread " + cValtoChar(ThreadId()),1,.t.,"TSI")

	if valtype( oBjJson ) <> "U"
		aadd( aObjRet , oBjJson )
	endif

	//STEP 1 - Nesse IF iremos processar apenas se atingir o limite de 500 NF
	If Self:nQtNotas == self:nSizeMax

		TafConout('TSILOG000028 - Processando lote de 500 NF(s)'+" - "+alltrim(cEmpAnt+"|"+cFilAnt),1,.T.,"TSI")
		//Tafconout('Primeiro NF do lote '+aObjRet[1]['invoice'][1]['taxDocumentNumber']+" - "+alltrim(cEmpAnt+"|"+cFilAnt),1,.t.,"TSI")
		//Tafconout('Ultima NF do lote '+aObjRet[len(aObjRet)]['invoice'][1]['taxDocumentNumber']+" - "+alltrim(cEmpAnt+"|"+cFilAnt),1,.t.,"TSI")
		Ws034Proc(oObjApi,lERP,aObjRet,@Self,oModel,oMldC20,oMldC30,oMldC35,oMldC39,oMldT9Q,oMldC2F,oMldC2D,oMldC21)

		aSIZE( aObjRet , 0 )
		aObjRet := { }

		FreeObj(oBjJson)
		oBjJson := NIL

		TafConout("TSILOG000029 - Foram adicionadas/alterados " + cvaltochar(self:nQtNotas) + " notas ao TAF - "+alltrim(cEmpAnt+"|"+cFilAnt),1,.T.,"TSI" )

		//Atualiza Contador de qtd de notas após insercao de lote
		self:nQtNotas := 0
	Endif
EndDo

/*
	STEP 2 - Nesse IF após o WHILE, iremos processar as NF que existirem no aObjRet. Não é preciso comparar total de registros
	pois já terminou a laço na tabela
*/
If len(aObjRet) > 0

	TafConout('TSILOG000028 - Processando lote de '+cValToChar(len(aObjRet))+' NF(s)'+" - "+alltrim(cEmpAnt+"|"+cFilAnt),1,.t.,"TSI")
	//Tafconout('Primeiro NF do lote '+aObjRet[1]['invoice'][1]['taxDocumentNumber']+" - "+alltrim(cEmpAnt+"|"+cFilAnt),1,.t.,"TSI")
	//Tafconout('Ultima NF do lote '+aObjRet[len(aObjRet)]['invoice'][1]['taxDocumentNumber']+" - "+alltrim(cEmpAnt+"|"+cFilAnt),1,.t.,"TSI")
	Ws034Proc(oObjApi,lERP,aObjRet,@Self,oModel,oMldC20,oMldC30,oMldC35,oMldC39,oMldT9Q,oMldC2F,oMldC2D,oMldC21,oMldC29)

	aSIZE( aObjRet , 0 )
	aObjRet := { }

	FreeObj(oBjJson)
	oBjJson := NIL

	TafConout("TSILOG000029 - Foram adicionadas/alterados " + cvaltochar(self:nQtNotas) + " notas ao TAF - "+alltrim(cEmpAnt+"|"+cFilAnt),1,.T.,"TSI" )
Endif
/*
if Self:nTotReg > 0
	Tafconout('Analisando se ainda tem alguma NF para integrar com stamp menor que '+cValtoChar(self:cUpStamp)+"- Thread " + cValtoChar(ThreadId()),1,.t.,"TSI")
	sleep(3000)
	(self:cTmpTable)->(dbGoTop())
	(self:cTmpTable)->(dbEval({|| nRegNot++,Conout('Registro nao integrado '+(self:cTmpTable)->NFISCAL + " / "+(self:cTmpTable)->STAMP)}))
Endif

If nRegNot > 0
	sleep(2000)
	Tafconout('Foram encontrados '+cValtoChar(nRegNot)+' registros nao integrados'+"- Thread " + cValtoChar(ThreadId()),1,.t.,"TSI")
Endif

//Deleto tabela temporária
delTsiTmp(self:oTempTable )
*/

Return Nil

/*/{Protheus.doc} GetHashCahed
	Retorno Hash static que está no fonte TAFA574 para ser utilizado no WS034Proc
	@since 03/08/2022
	@return Nil, nulo, não tem retorno.
/*/

Method GetHashCahed(cAlias) Class TSINFISCAL

Return &('oHash'+cAlias)

/*/{Protheus.doc} Taf558Aidf
	Regraas para AIDF
	@since 05/10/2020
	@return Nil, nulo, não tem retorno.
/*/

static function Taf558Aidf(cNum, cSerie)

Local cDisp := ""
Local aAidf := {}

	// Utilizo a funcao do MATXMAG para retornar o dispositivo AIDF do documento
	aAidf := RetAidf( cNum, cSerie )
	
	If !Empty(aAidf[1])
		Do Case
		Case Alltrim(aAidf[2]) == "1"
			cDisp :="04"
		Case Alltrim(aAidf[2]) == "2"
			cDisp :="03"
		Case Alltrim(aAidf[2]) == "3"
			cDisp :="00"
		Case Alltrim(aAidf[2]) == "4"
			cDisp :="05"
		Case Alltrim(aAidf[2]) == "6"
			cDisp :="02"
		Case Alltrim(aAidf[2]) == "7"
			cDisp :="01"
		EndCase
	EndIf

Return cDisp

 /*/{Protheus.doc} LocPrestac
	(Function responsável por retornar o local de prestação de serviço:
    Regra:
    Notas de entrada: Se o serviço for configurado como “EP” (B1_MEPLES = 1 ou Branco), 
    ou seja, ISS devido no estabelecimento do prestador, o ISS será considerado devido 
    no município do fornecedor do documento (A2_COD_MUN).
    Se o serviço for configurado como “LES” (B1_MEPLES = 2), ou seja, ISS devido 
    no local de execução do serviço, primeiramente serão avaliados os campos F1_ESTPRES e 
    F1_INCISS, que podem ser informados no momento da digitação do documento de entrada. 
    Se estes campos estiverem preenchidos, o ISS será considerado devido no município ali definido. 
    Caso contrário, o ISS será considerado devido no município do SIGAMAT (M0_CODMUN).

    Notas de saída: Se o serviço for configurado como “EP” (B1_MEPLES = 1 ou Branco), ou seja, ISS devido no 
    estabelecimento do prestador, o ISS será considerado devido no município do SIGAMAT (M0_CODMUN).
    Se o serviço for configurado como “LES” (B1_MEPLES = 2), ou seja, ISS devido no local de execução do serviço, 
    primeiramente serão avaliados os campos F2_ESTPRES e F2_MUNPRES, preenchidos através dos campos C5_ESTPRES e C5_MUNPRES 
    no pedido de venda. Se estes campos estiverem prenchidos o ISS será considerado devido no município ali definido. 
    Caso contrário o ISS será considerado devido no município do cliente de faturamento (A1_COD_MUN).
    
	@author Henrique Pereira
	@since 11/09/2020  
	@return Nil, nulo, não tem retorno.
/*/

static function LocPrestac(cAlias)
Local cLocPRest :=	''
Local aAreaSA2	:=	SA2->(GetArea()) 
Local aAreaSB1	:=	SB1->(GetArea())

SA2->(DbSetOrder(1))
SB1->(DbSetOrder(1))

	If (cAlias)->TIPOMOV == 'E' .and. !((cAlias)->TIPO $ ( 'B', 'D' ))

		If SB1->(MsSeek(xFilial('SB1')+(cAlias)->PRODUTO))
			If SB1->B1_MEPLES = '1' .or. empty(SB1->B1_MEPLES)			
				if SA2->(MsSeek(xFilial('SA2')+(cAlias)->CLIEFOR+(cAlias)->LOJA))
					cLocPRest := SA2->A2_COD_MUN
				endif
			elseIf SB1->B1_MEPLES = '2' 
				if !empty((cAlias)->ESTPRES) .and. !empty((cAlias)->MUNPRES)
					cLocPRest := (cAlias)->MUNPRES
				else 
					cLocPRest := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {'M0_CODMUN'} )[1][2]  
				endif
			endif
		endif
 
	elseIf (cAlias)->TIPOMOV == 'S' .and. !((cAlias)->TIPO $ ( 'B', 'D' ))

		If SB1->(MsSeek(xFilial('SB1')+(cAlias)->PRODUTO))
			If SB1->B1_MEPLES = '1' .or. empty(SB1->B1_MEPLES)	
				cLocPRest := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {'M0_CODMUN'} )[1][2]  				
			elseIf SB1->B1_MEPLES = '2' 

				if !empty((cAlias)->ESTPRES) .and. !empty((cAlias)->MUNPRES)
					if SA1->(MsSeek(xFilial('SA1')+(cAlias)->CLIEFOR+(cAlias)->LOJA))
						cLocPRest := SA1->A1_COD_MUN
					endif
				else 
					cLocPRest := (cAlias)->MUNPRES
				endif

			endif
		endif

	endif

restarea(aAreaSA2)
restarea(aAreaSB1)

return cLocPRest

 /*/{Protheus.doc} abatMat
	(Static Function responsável retornar o valor de abatimento 
	@author Henrique Pereira
	@since 11/09/2020  
	@return Nil, nulo, não tem retorno.
/*/

static function abatMat(cAlias)
Local nValAbat 	:=	0
Local cQuery	:=	''
Local cAlaisEnt	:=  getNextAlias()
Local cAlaisSai	:=  getNextAlias()
    
	If (cAlias)->TIPOMOV == 'E' .and. !((cAlias)->TIPO $ ( 'B', 'D' ))

		If __oStatSai == nil

			cQuery += " SELECT SUM(SD1.D1_ABATMAT) ABATMAT FROM "
			cQuery += RetSqlName("SD1") + " SD1 "
			cQuery += " 	WHERE SD1.D1_FILIAL = ? "
			cQuery += " 	AND SD1.D1_DOC      = ? " 
			cQuery += " 	AND SD1.D1_SERIE    = ? "
			cQuery += " 	AND SD1.D1_FORNECE  = ? "
			cQuery += " 	AND SD1.D1_LOJA     = ? "
			cQuery += " 	AND SD1.D1_COD      = ? "
			cQuery += " 	AND SD1.D1_ITEM     = ? "
			cQuery += " 	AND SD1.D_E_L_E_T_  = ? "
			
			__oStatSai := FWPreparedStatement():New()
			__oStatSai:SetQuery(cQuery)
			
		Endif

		__oStatSai:SetString(1,xFilial('SD1'))
		__oStatSai:SetString(2,(cAlias)->NUM_DOC)
		__oStatSai:SetString(3,(cAlias)->SERIE)
		__oStatSai:SetString(4,(cAlias)->CLIEFOR)
		__oStatSai:SetString(5,(cAlias)->LOJA)
		__oStatSai:SetString(6,(cAlias)->PRODUTO)
		__oStatSai:SetString(7,(cAlias)->ITEM) 
		__oStatSai:SetString(8,' ')

		dbUseArea(.T., "TOPCONN", TCGenQry(, , __oStatSai:GetFixQuery()), cAlaisSai, .F., .T.)
		nValAbat := (cAlaisSai)->ABATMAT

		(cAlaisSai)->(DbCloseArea())
	
    elseIf (cAlias)->TIPOMOV == 'S' .and. !((cAlias)->TIPO $ ( 'B', 'D' ))

		If __oStatEnt == nil

			cQuery += " SELECT SUM(SD2.D2_ABATMAT) ABATMAT FROM "
			cQuery += RetSqlName("SD2") + " SD2 "
			cQuery += " 	WHERE SD2.D2_FILIAL = ? "
			cQuery += " 	AND SD2.D2_DOC      = ? " 
			cQuery += " 	AND SD2.D2_SERIE    = ? "
			cQuery += " 	AND SD2.D2_CLIENTE  = ? "
			cQuery += " 	AND SD2.D2_LOJA     = ? "
			cQuery += " 	AND SD2.D2_COD      = ? "
			cQuery += " 	AND SD2.D2_ITEM     = ? "
			cQuery += " 	AND SD2.D_E_L_E_T_  = ? "
			
			__oStatEnt := FWPreparedStatement():New()
			__oStatEnt:SetQuery(cQuery)
		Endif 

		__oStatEnt:SetString(1,xFilial('SD2'))
		__oStatEnt:SetString(2,(cAlias)->NUM_DOC)
		__oStatEnt:SetString(3,(cAlias)->SERIE)
		__oStatEnt:SetString(4,(cAlias)->CLIEFOR)
		__oStatEnt:SetString(5,(cAlias)->LOJA)
		__oStatEnt:SetString(6,(cAlias)->PRODUTO)
		__oStatEnt:SetString(7,(cAlias)->ITEM) 
		__oStatEnt:SetString(8,' ')

		dbUseArea(.T., "TOPCONN", TCGenQry(, , __oStatEnt:GetFixQuery()), cAlaisEnt, .F., .T.)
		nValAbat := (cAlaisEnt)->ABATMAT
		(cAlaisEnt)->(DbCloseArea())

	endif

return nValAbat

 /*/{Protheus.doc} Taf574CDA
	Executa a query em CDA e monta o json
	@author Henrique Pereira
	@since 11/09/2020  
	@return Nil, nulo, não tem retorno.
/*/

static function Taf574CDA(cAliasSFT, oJObjRet, nLen, lNextNota )
	
	Local cAlaisCDA  as character
	Local cQuery     as character
	Local cFormul    as character
	Local cProduto	 as character
	Local cCodSubIte as character
	Local cChave     as character
	Local cIsNull    as character
	Local nLenCDA    as numeric

	
	cAlaisCDA	:= getNextAlias()
	cFormul		:= Iif(Empty((cAliasSFT)->FORMUL),Iif((cAliasSFT)->TIPOMOV == "S","S"," "),(cAliasSFT)->FORMUL)
	cProduto	:= (cAliasSFT)->PRODUTO
	cCodSubIte	:=	''
	cChave		:=	''
	nLenCDA		:= 0
	cIsNull		:=  ''
	cBD 		:= TcGetDb()

	If cBD $ "ORACLE"
		cIsNull := "NVL"
	ElseIf  cBD $ "POSTGRES"
		cIsNull := "COALESCE" 
	Else
		cIsNull := "ISNULL"
	EndIf

	If __oStatCDA == nil

		cQuery := " SELECT "
		cQuery += "		CDA.CDA_FILIAL FILIAL, "
		cQuery += " 	CDA.CDA_CODLAN CODLAN, "
		cQuery += 		cIsNull + " (CCE.CCE_DESCR, ' ') DESCRI_IFCOM, "
		cQuery += " 	CDA.CDA_ALIQ ALIQ, "
		cQuery += " 	SUM(CDA.CDA_BASE) BASE, "
		cQuery += " 	SUM(CDA.CDA_VALOR) VALOR "
		cQuery += " FROM " + RetSqlName("CDA") + " CDA " 
		cQuery += " LEFT JOIN " + RetSqlName("CCE") + " CCE "
		cQuery += " 	ON CDA.CDA_IFCOMP = CCE.CCE_COD AND CCE.CCE_FILIAL = '" + xFilial( "CCE" ) + "' AND CCE.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE CDA.CDA_FILIAL  = ? "
		cQuery += " 	AND CDA.CDA_TPMOVI  = ? " 
		cQuery += " 	AND CDA.CDA_ESPECI  = ? "
		cQuery += " 	AND CDA.CDA_FORMUL  = ? "
		cQuery += " 	AND CDA.CDA_NUMERO  = ? "
		cQuery += " 	AND CDA.CDA_CLIFOR  = ? "
		cQuery += " 	AND CDA.CDA_LOJA 	= ? "
		cQuery += " 	AND CDA.CDA_TPLANC	= ? "
		cQuery += " 	AND CDA.CDA_NUMITE	= ? "			
		cQuery += " 	AND CDA.D_E_L_E_T_  = ? "
		cQuery += " GROUP BY CDA.CDA_FILIAL, CDA.CDA_CODLAN, " + cIsNull + " (CCE.CCE_DESCR, ' ') , CDA.CDA_ALIQ  "

		__oStatCDA 	:= FWPreparedStatement():New()
		__oStatCDA:SetQuery(cQuery)

	Endif
	
	__oStatCDA:SetString(1,xFilial('CDA'))
	__oStatCDA:SetString(2,(cAliasSFT)->TIPOMOV)
	__oStatCDA:SetString(3,(cAliasSFT)->COD_MOD)
	__oStatCDA:SetString(4,cFormul)
	__oStatCDA:SetString(5,(cAliasSFT)->NFISCAL)
	__oStatCDA:SetString(6,(cAliasSFT)->CLIEFOR )
	__oStatCDA:SetString(7,(cAliasSFT)->LOJA) 
	__oStatCDA:SetString(8,"2")
	__oStatCDA:SetString(9,(cAliasSFT)->ITEM) 	
	__oStatCDA:SetString(10,' ')

	dbUseArea(.T., "TOPCONN", TCGenQry(, , __oStatCDA:GetFixQuery()), cAlaisCDA, .F., .T.)

	if (cAlaisCDA)->(!EOF())

		if lNextNota .Or. ValType(oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"]) == "U"
			oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"] := {}
		EndIf
		(cAlaisCDA)->(!DbGoTop())	
		While  (cAlaisCDA)->(!EOF()) // Pode se ter mais de um código de lançamento amarrado a TES do item, por isso exite a necessidade do laço while
			
			cCodSubIte	:=	Taf574SI(cAliasSFT)

			cChave := (cAlaisCDA)->CODLAN+cProduto+cCodSubIte+cvaltochar((cAlaisCDA)->ALIQ)

			If ValType(oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"]) <> "U"

				nLenCDA := aScan(oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"],{|x|x["adjustmentCode"]+x["product"]+x["subitemCode"];
				+cValToChar(x["aliquot"])==cChave})

			Endif

			If nLenCDA == 0 
			
				//if cChave <> (cAlaisCDA)->FILIAL+(cAlaisCDA)->CODLAN+cProduto+cCodSubIte+cvaltochar((cAlaisCDA)->ALIQ)	
			
				aAdd( oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"],JsonObject():New())
				nLenCDA := Len(oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"])
																																						// Campos da Planilha Layout TAF - T013AM												
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["adjustmentCode"]		:=	(cAlaisCDA)->CODLAN 		//02-COD_AJ                                                    
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["settingDescription"]	:=	(cAlaisCDA)->DESCRI_IFCOM	//03-DESCR_COMPL_AJ
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["product"]				:=	cProduto					//04-COD_ITEM
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["basisOfCalculation"]	:=	(cAlaisCDA)->BASE			//05-VL_BC_ICMS
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["aliquot"]				:=	(cAlaisCDA)->ALIQ			//06-ALIQ_ICMS
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["value"]				:=	(cAlaisCDA)->VALOR  		//07-VL_ICMS
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["subitemCode"]			:=	cCodSubIte					//09-COD_SUBITEM
			
			else
			
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["basisOfCalculation"]	+=	(cAlaisCDA)->BASE			//05-VL_BC_ICMS
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["value"]				+=	(cAlaisCDA)->VALOR			//07-VL_ICMS
			
			endif
			
			(cAlaisCDA)->(DbSkip())

		enddo

	endif

	( cAlaisCDA )->( DBCloseArea( ) )

return 

/*/{Protheus.doc} Taf574SI()
	Função responsavel por realizar o tratamento dos códigos de SubItem pra notas fiscais
	que devem ser enviados para o TAF

	@author Henrique Pereira
	@since 05/10/2020
/*/

Static Function Taf574SI(cAliasSFT)

	Local cRet		:= ''

	/*
	TRATAMENTO PARA O ESTADO DE MINAS GERAIS 
	Atende a regra de geração da DAPI/MG
	*/
	If cMVEstado == "MG"

			/*
			Caso o campo da TES esteja como '1' apenas verifico se a operação em questão é
			de entrada ou saída para definir qual o código de Subitem que devo mandar
			para o TAF
			*/

			If (cAliasSFT)->TRFICM == "1"  
				If (cAliasSFT)->IND_OPER == "0"  // entrada 
					cRet := "00066"
				Else
					cRet := "00073"
				EndIf
			EndIf

			// F4_ESTCRED
			If  (cAliasSFT)->ESTCRED > 0 // SF4
				cRet := "00090"
			EndIf

			// FT_ESTCRED
			If (cAliasSFT)->IND_OPER == "0" .and. (cAliasSFT)->FTESTCRED > 0
				cRet := "00095" 
			EndIf
	ElseIf cMVEstado == "SP"
		// Relaciona o código do subitem referente a CFOP enviada na chamada da Função, para atender a GIA-SP
		If (cAliasSFT)->CFOP $ "5601|1605"
			cRet := "00219"
		ElseIf (cAliasSFT)->CFOP $ "1601|1602"
			cRet := "00730"
		ElseIf (cAliasSFT)->CFOP == "5602"
			cRet := "00218"
		ElseIf (cAliasSFT)->CFOP == "5605"
			cRet := "00729"
		ElseIf (cAliasSFT)->CFOP $ "5603|6603" 
			cRet := "00210"
		ElseIf (cAliasSFT)->CFOP $ "5603|6603"
			cRet := "00701"
		EndIf
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} valueByTax
Função responsável por elaborar json do registro T013AP - Cadastro de tributos por documento fiscal

@param  oJObjRet   -> Objeto que será utilizado para gerar o json de extração das notas fiscais 
@param  aRegT013AP -> array com as inforrmações e valores de tributos da nota fiscal

@author Wesley Pinheiro
@since 14/10/2020

/*/
//-------------------------------------------------------------------
static function valueByTax( oJObjRet, aRegT013AP )

	Local nI       := 0
	Local nLen13AP := 0
	Local nTam13AP := Len( aRegT013AP )

	If nTam13AP > 0

		oJObjRet[cTag13AP] := { }

		for nI:= 1 to nTam13AP

			aAdd( oJObjRet[cTag13AP], JsonObject( ):New( ) )
			nLen13AP := Len( oJObjRet[cTag13AP] )

			oJObjRet[cTag13AP][nLen13AP]["taxCode"]                 := aRegT013AP[nI][NAPCODTRIB] // 02 - COD_TRIB       -> C2F_CODTRI  
			oJObjRet[cTag13AP][nLen13AP]["calculationBase"]	        := aRegT013AP[nI][NAPBS]      // 03 - BASE           -> C2F_BASE 
			oJObjRet[cTag13AP][nLen13AP]["calculationBaseAmount"]   := aRegT013AP[nI][NAPBSQTD]   // 04 - BASE_QUANT     -> C2F_BASEQT
			oJObjRet[cTag13AP][nLen13AP]["calculationBaseNotTaxed"] := aRegT013AP[nI][NAPBSNT]    // 05 - BASE_NT        -> C2F_BASENT
			oJObjRet[cTag13AP][nLen13AP]["taxValue"]                := aRegT013AP[nI][NAPVLR]     // 06 - VALOR          -> C2F_VALOR			
			oJObjRet[cTag13AP][nLen13AP]["taxBaseValue"]            := aRegT013AP[nI][NAPVLRTRIB] // 07 - VLR_TRIBUTAVEL -> C2F_VLRPAU
			oJObjRet[cTag13AP][nLen13AP]["exemptValue"]             := aRegT013AP[nI][NAPVLRISEN] // 08 - VLR_ISENTO     -> C2F_VLISEN
			oJObjRet[cTag13AP][nLen13AP]["otherValue"]              := aRegT013AP[nI][NAPVLROUTR] // 09 - VLR_OUTROS     -> C2F_VLOUTR
			oJObjRet[cTag13AP][nLen13AP]["nonTaxedValue"]           := aRegT013AP[nI][NAPVLRNT]   // 10 - VALOR_NT       -> C2F_VLNT
			oJObjRet[cTag13AP][nLen13AP]["cst"]                     := aRegT013AP[nI][NAPCST]     // 11 - CST            -> C2F_CST
			oJObjRet[cTag13AP][nLen13AP]["cfop"]                    := aRegT013AP[nI][NAPCFOP]    // 12 - CFOP           -> C2F_CFOP
			oJObjRet[cTag13AP][nLen13AP]["taxRate"]                 := aRegT013AP[nI][NAPALIQ]    // 13 - ALIQUOTA       -> C2F_ALIQ
			oJObjRet[cTag13AP][nLen13AP]["serviceCode"]             := aRegT013AP[nI][NAPCODLST]  // 14 - COD_LST        -> C2F_CODSER
			oJObjRet[cTag13AP][nLen13AP]["operationValue"]          := aRegT013AP[nI][NAPVLROPER] // 15 - VL_OPER        -> C2F_VLOPE
			oJObjRet[cTag13AP][nLen13AP]["valueWithoutCredit"]      := aRegT013AP[nI][NAPVLRSCRE] // 16 - VL_SCRED       -> C2F_VLSCRE
			oJObjRet[cTag13AP][nLen13AP]["previousICMSSTvalue"]     := aRegT013AP[nI][TRIBICMSST] // 17 - ICMNDES        -> C2F_ICMNDES

		next nI

	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} fiscalDocumentItems
Função responsável por elaborar json do registro T015

@param  cAlias     -> Alias da query corrente
@param  oJObjRet   -> Objeto que será utilizado para gerar o json de extração das notas fiscais 
@param  nLen       -> indice atual do objeto json ( oJObjRet )

@author Denis Naves
@since 19/10/2020

/*/
//-------------------------------------------------------------------
static function fiscalDocumentItems( oTsiNFis, cAlias, oJObjRet, nLen, aRegT015AE, nSomaItem )
 
	Local cCodIss  	 := SFT->FT_CODISS //Caso não encontre registro na CDN, utilizar FT_CODISS
	Local nLen15   	 := 0
	Local nVlItem  	 := 0
	Local cCfop    	 := ""
	Local cTpServ  	 := ""
	Local cDipam   	 := ""
	Local cClasFis	 := ''
	Local cTpRepasse := ""
	Local cIndDTerc  := ""
	Default oTsiNFis := Nil
	Default cAlias   := ""
	Default nLen	 := 1

	cIndDTerc        := ""

	//Quando CFOP estiver com 3 dígitos, converter para o CFOP 5949 (Saídas) ou 1949 (Entradas)
	if Len(AllTrim(SFT->FT_CFOP)) <= 3 .And. !Empty(SFT->FT_TIPOMOV)
		If SFT->FT_TIPOMOV == "S"
			cCfop := '5949'
		Else
			cCfop := '1949'
		EndIf
	else
		cCfop := SFT->FT_CFOP
	endif

	//Se nota complementar, FT_TOTAL
	if alltrim((cAlias)->TIPO_DOC)  $ "02|03|04"
 		nVlItem := SFT->FT_TOTAL
 	else //Para notas normais usar FT_PRCUNIT
 		if Empty(SFT->FT_PRCUNIT)
			nVlItem := SFT->FT_TOTAL
		else
			nVlItem := SFT->FT_PRCUNIT
		endif
	endif

	//Priorizo o tipo de serviço da reinf que esta no cadastro do produto.
	cTpServ := (cAlias)->F2QTPSERV

	if !Empty( (cAlias)->PRODCODLST ) //CDN + FT_CODISS + FT_PRODUTO
		cCodIss := AllTrim((cAlias)->PRODCODLST)
		if empty(cTpServ)
			cTpServ := (cAlias)->PRODTPSERV
		endif
	elseif !Empty( (cAlias)->ISSCODLST ) //CDN + FT_CODISS
		cCodIss := AllTrim((cAlias)->ISSCODLST)
		if empty(cTpServ)
			cTpServ := (cAlias)->ISSTPSERV
		endif
	EndIf
	// Tiro todos os pontos que estiverem no cadastro. Sem pontos (Exemplo: 06.01 deve enviar 0601). 
	cCodIss := alltrim((StrTran(cCodIss,".","")))

	if !Empty(cTpServ); cTpServ := '1' + StrZero(Val(cTpServ),08); endif

	//Se UF do parametro MV_UFCODIPM = UF do MV_ESTADO Buscar na tabela F09 o código IPM gravado no campo F09_CODIPM
	If !Empty( cMVEstado ) .and. (cMVEstado $ cUFIPM )
		cDipam := Alltrim( Posicione( "F09", 1, xFilial( "F09" ) + SFT->FT_TES + cMVEstado, "F09_CODIPM" ) )
	EndIf

	If SFT->FT_TIPOMOV == 'E'
		cTpRepasse := SD1->D1_TPREPAS
	ElseIf SFT->FT_TIPOMOV == 'S'
		cTpRepasse := SD2->D2_TPREPAS
	EndIf

	//Verifico indicativo de 13º salário
	If lTableDHR
		If !Empty((cAlias)->NATREN)
			If lTableFKX
				cIndDTerc := Posicione("FKX", 1, xFilial("FKX") + (cAlias)->NATREN, "FKX_DECSAL")
			Else
				cIndDTerc := ''
			EndIf
		Else
			cIndDTerc := ''
		EndIf
	EndIf

	//Formatando a informação de origem do produto.
	if empty(left(SFT->FT_CLASFIS,1))
		cClasFis := '0'
	else
		cClasFis := left(SFT->FT_CLASFIS,1)	
	endif

	aAdd( oJObjRet[cTagJs][nLen][cTagT015], JsonObject( ):New( ) )
	nLen15 := Len( oJObjRet[cTagJs][nLen][cTagT015] )

	oTsiNFis:nProcReg++ //contador acumulado

	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["itemNumber"]			    := StrZero(nSomaItem,nTmNumIte) 		        //2 NUM_ITEM
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["itemCode"]			    := SFT->FT_PRODUTO								//3 COD_ITEM
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["itemTotalValue"]		    := SFT->FT_TOTAL								//5 VL_TOT_ITEM
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["discountValue"]		    := SFT->FT_DESCONT								//6 VL_DESC
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["itemAmount"]              := SFT->FT_QUANT								//11 QTD
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["unitOfMeasurement"]	    := SB1->B1_UM									//12 UNID
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["cfopIndicator"]		    := cCfop										//13 CFOP
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["operationNature"]	        := SF4->F4_CODIGO								//14 COD_NAT
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["originIdentCode"]		    := cClasFis										//28 ORIGEM
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["physicalMovement"]		:= iif(alltrim(SF4->F4_MOVFIS) == 'S','0','1')	//29 IND_MOV
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["itemValue"]		        := nVlItem										//31 VL_ITEM
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["serviceCode"]			    := cCodIss										//32 COD_LST
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["accountingValue"]         := SFT->FT_VALCONT								//35 VLR_CONTABIL
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["itemAdditions"]		    := SFT->(FT_SEGURO+FT_DESPESA+FT_FRETE)			//37 VL_ACRE
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["acessoryExpense"]		    := SFT->FT_DESPESA								//38 VL_DA
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["cityServiceCode"]		    := AllTrim(SFT->FT_CODISS)						//40 COD_SERV_MUN
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["typeOfTransfer"]		    := cTpRepasse									//42 TPREPASSE
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["serviceType"]			    := cTpServ 										//43 TIP_SERV
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["dipamCode"]			    := cDipam										//44 COD_DIPAM
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["socialSecurityExemption"] := Iif(lINDISEN,SFT->FT_INDISEN,"")				//45 IND_ISENCAO_PREVID
	If lTableDHR
		oJObjRet[cTagJs][nLen][cTagT015][nLen15]["natureOfIncome"]          := AllTrim((cAlias)->NATREN)               		//46 NATUREZA_RENDIMENTO
		oJObjRet[cTagJs][nLen][cTagT015][nLen15]["indicator13Salary"]       := cIndDTerc                    				//47 IND_DEC_TERC
	EndIf
	
	valTaxPerItm( @oJObjRet[cTagJs][nLen][cTagT015][nLen15], aRegT015AE )

	if !Empty( (cAlias)->DT6CLIDES ) .Or. !Empty( (cAlias)->DT6CDRORI ) //T015AI - Complemento do documento fiscal - Transportes
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AI] := { } //para cada item da nota cria o array no json
		transportComplement( cAlias, oJObjRet, nLen, nLen15 )
	endif

	//T015AK - Indicativo de suspensão para os processos administrativos e judiciais
	if lTableCDG .OR. lTableDHR
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK] := { } //para cada item da nota cria o array no json
		SuspByJudProcess( cAlias, @oJObjRet, nLen, nLen15 )
	endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} transportComplement
Função responsável por elaborar json do registro T015AI
Complemento do documento fiscal - Transportes
59.Serviço de Transporte (Mod. 07)

@param  cAlias     -> Alias da query corrente
@param  oJObjRet   -> Objeto que será utilizado para gerar o json de extração das notas fiscais 
@param  nLen       -> indice atual do objeto json ( oJObjRet )
@param  nLen15     -> posicao do item

@author Denis Naves
@since 19/10/2020

/*/
//-------------------------------------------------------------------
Static Function transportComplement( cAlias, oJObjRet, nLen, nLen15 )

	Local nLen15AI	 := 0
	Local cCodEstOrg := ""
	Local cCodMunOrg := ""
	Local cCodMunDes := ""
	Local cCodEstDes := ""

	alGetSA1 := SA1->(GetArea())

	//Para origem ja esta posicionado na SA1 correspondente
	cCodEstOrg := ExtTmsMun( (cAlias)->DT6CDRORI/*, .T., .T. */)  //TMSCodMun -> Livros Fiscais/SPEDXFUN.PRW

	If Len(cCodEstOrg) > 5
		If Upper( SubStr( cCodEstOrg, 1, 2 ) ) != "EX"
			cCodMunOrg := SubStr(cCodEstOrg,3,5)
		Else
			cCodMunOrg := "9999999"
		EndIf
		cCodEstOrg := SubStr(cCodEstOrg,1,2)
	EndIf

	//Necessario reposicionar para o destino pois TMSCodMun trabalha com cursores da SA1
	If SA1->(MsSeek(xFilial("SA1")+(cAlias)->(DT6CLIDES+DT6LOJDES) )) 
		cCodEstDes := ExtTmsMun( (cAlias)->DT6CDRCAL/*, .T., .T. */)
		If Len( cCodEstDes ) > 5
			If Upper( SubStr( cCodEstDes, 1, 2 ) ) != "EX"
				cCodMunDes := SubStr( cCodEstDes, 3, 5 )
			Else
				cCodMunDes := "9999999"
			EndIf
			cCodEstDes := SubStr( cCodEstDes, 1, 2 )
		EndIf
	EndIf

	aAdd( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AI], JsonObject( ):New( ) )
	nLen15AI := Len( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AI] )

	oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AI][nLen15AI]["originFUCode"]	  := cCodEstOrg //2 UF_MUN_ORIG
	oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AI][nLen15AI]["originCityCode"]  := cCodMunOrg //3 COD_MUN_ORIG
	oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AI][nLen15AI]["destinyFUCode"]	  := cCodEstDes //4 UF_MUN_DEST
	oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AI][nLen15AI]["destinyCityCode"] := cCodMunDes //5 COD_MUN_DEST

	RestArea(alGetSA1)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} compInfoByTax
Função responsável por elaborar json do registro T013AA
Informações complementares de documentos fiscais

@param  cAlias     -> Alias da query corrente
@param  oJObjRet   -> Objeto que será utilizado para gerar o json de extração das notas fiscais 
@param  nLen       -> indice atual do objeto json ( oJObjRet )

MV_SPDIFC - Impressao do campo TXT_COMPL do Reg. C110
0 = CCE_DESCR
1 ou 3 = CDT_DCCOMP Se campo existir e não vazio
      	            Senão CDC_DCCOMP
2 = Se Entrada F1_MENNOTA
    Se Saída   F2_MENNOTA

@author Rafael de Paula Leme
@since 21/10/2021

/*/
//-------------------------------------------------------------------
Static Function compInfoByTax( cAlias, oJObjRet, nLen )

	Local nLen13AA  As numeric
	Local nSPDIFC   As numeric
	Local cSelect	As character
	Local cFrom		As character
	Local cWhere	As character
	Local cAliasCDT As character
	Local cTxtCompl As character
	
	cAliasCDT := getNextAlias()       
	nSPDIFC   := GetMV( "MV_SPDIFC" )
	nLen13AA  := 0
	cTxtCompl := ''

	DbSelectArea( "CDT" )
	 
	cSelect := "% CDT.CDT_IFCOMP IFCOMP"

	//Protejo o fonte pois o campo CDT_DCCOMP pode não existir na base do cliente.
	if FieldPos("CDT_DCCOMP") > 0
		cSelect += ", CDT.CDT_DCCOMP DCCOMP"
	endif

	cSelect += " %"

	cFrom := "% " + RetSqlName("CDT") + " CDT" + " %" //Informações complementares de documentos fiscais

	cWhere  := "% CDT.CDT_FILIAL = '"    + (cAlias)->FILIAL + "' "  // SFT.FT_FILIAL
	cWhere  += " AND CDT.CDT_TPMOV = '"  + (cAlias)->TIPOMOV + "' " // SFT.FT_TIPOMOV
	cWhere  += " AND CDT.CDT_DOC = '"    + (cAlias)->NFISCAL + "' "	// SFT.FT_NFISCAL
	cWhere  += " AND CDT.CDT_SERIE = '"  + (cAlias)->SERIE +   "' "	// SFT.FT_SERIE
	cWhere  += " AND CDT.CDT_CLIFOR = '" + (cAlias)->CLIEFOR + "' " // SFT.FT_CLIEFOR
	cWhere  += " AND CDT.CDT_LOJA = '"   + (cAlias)->LOJA +    "' "	// SFT.FT_LOJA
	cWhere  += " AND CDT.D_E_L_E_T_ = ' ' %"

	BeginSql Alias cAliasCDT
		SELECT %Exp:cSelect%
		FROM %Exp:cFrom%
		WHERE %Exp:cWhere%
	EndSql

	While (cAliasCDT)->(!EOF())

		aAdd( oJObjRet[cTagJs][nLen][cTag013AA], JsonObject( ):New( ) ) 
		nLen13AA := Len( oJObjRet[cTagJs][nLen][cTag013AA] )
		
		// Abaixo repito o envio do campo CDT_IFCOMP pois o mesmo deve preencher dois campos na tabela de destino C21.
		// Por se tratar de um controle interno, não visível ao cliente, foi decidido fazer dessa forma, ao invés de tratar isso no fonte WSTAF034.
		// Para as APIs PUT e POST do layout T013 não será necessário informar as duas tags com o mesmo valor.
		oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["complementaryInfoCode"] := (cAliasCDT)->IFCOMP // CDT_IFCOMP -> C21_CODINF
		oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["auxiliaryCode"]         := (cAliasCDT)->IFCOMP  // CDT_IFCOMP -> C21_CDINFO

		cTxtCompl := Alltrim(Posicione("CCE", 1, xFilial("CCE") + (cAliasCDT)->IFCOMP, "CCE_DESCR"))	

		if nSPDIFC == 0
			oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["complementaryInfoText"] := cTxtCompl // CCE_DESCR -> C21_DESCRI
		elseif nSPDIFC == 1 .or. nSPDIFC == 3
			if FieldPos("CDT_DCCOMP") > 0 .and. !empty((cAliasCDT)->DCCOMP)
				oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["complementaryInfoText"] := Alltrim((cAliasCDT)->DCCOMP) // CDT_DCCOMP -> C21_DESCRI
			elseif lTableCDC
				oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["complementaryInfoText"] := Alltrim(Posicione("CDC", 1, xFilial("CDC") + (cAlias)->TIPOMOV + (cAlias)->NFISCAL + (cAlias)->SERIE + (cAlias)->CLIEFOR + (cAlias)->LOJA, "CDC_DCCOMP")) // CDC_DCCOMP -> C21_DESCRI	
			else
				oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["complementaryInfoText"] := ' '
			endif
		elseif nSPDIFC == 2
			oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["complementaryInfoText"] := Alltrim((cAlias)->MENNOTA) // _MENNOTA -> C21_DESCRI
		else
			oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["complementaryInfoText"] := ' '
		endif

		oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["complementaryInfoDesc"] := cTxtCompl // CCE_DESCRI -> C21_DCODIN
			
		(cAliasCDT)->(DbSkip())

	EndDo
	
	( cAliasCDT )->( DBCloseArea( ) )

	( "CDT" )->( DBCloseArea() )

Return Nil

/*/{Protheus.doc} ticketsByInvoice
	
	Inicialmente, a função foi desenvolvida apenas para enviar o numero da fatura.
	Quando for necessário enviar todas as informações do layout T013AI, criar query SFT x SE1 ou SE2
	retornando todas as informações necessárias.
	
	@type  Function
	@author Rafael Leme
	@since 28/09/2022
/*/
Static Function ticketsByInvoice(cAlias, oJObjRet, nLen)

	Local nLen13AI  As numeric
	
	nLen13AI := 0

	//Inicialmente, a função foi desenvolvida apenas para enviar o numero da fatura.
	//Quando for necessário enviar todas as informações do layout T013AI, criar query SFT x SE1 ou SE2
	//retornando todas as informações necessárias.
	
	aAdd( oJObjRet[cTagJs][nLen][cTag013AI], JsonObject( ):New( ) ) 
	nLen13AI := Len( oJObjRet[cTagJs][nLen][cTag013AI] )
		
	oJObjRet[cTagJs][nLen][cTag013AI][nLen13AI]["ticketIssuer"]         := '0'
	oJObjRet[cTagJs][nLen][cTag013AI][nLen13AI]["ticketType"]           := '00'
	oJObjRet[cTagJs][nLen][cTag013AI][nLen13AI]["ticketDescription"]    := ''
	oJObjRet[cTagJs][nLen][cTag013AI][nLen13AI]["ticketNumber"]         := (cAlias)->NUMFAT
	oJObjRet[cTagJs][nLen][cTag013AI][nLen13AI]["numberOfInstallments"] := 1
	oJObjRet[cTagJs][nLen][cTag013AI][nLen13AI]["totalTicketValue"]     := (cAlias)->VL_DOC
	oJObjRet[cTagJs][nLen][cTag013AI][nLen13AI]["valueOfDiscounts"]     := 0
	oJObjRet[cTagJs][nLen][cTag013AI][nLen13AI]["ticketNetValue"]       := 0

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SuspByJudProcess
Função responsável por elaborar json do registro T015AK

Mod 09 SIGAFIS Complemento do documento fiscal - Processos Referenciados
Mod 84 SIGATAF 60.Indicativo de Suspensao Processos Administrativos e Judiciais

@param  cAlias     -> Alias da query corrente
@param  oJObjRet   -> Objeto que será utilizado para gerar o json de extração das notas fiscais 
@param  nLen       -> indice atual do objeto json ( oJObjRet )
@param  nLen15     -> posicao do item

@author Denis Naves
@since 21/10/2021

/*/
//-------------------------------------------------------------------
Static Function SuspByJudProcess( cAlias, oJObjRet, nLen, nLen15 )

Local nLen15AK   As numeric
Local cAliasQry  As char
Local cSelect	 As char
Local cFrom		 As char
Local cInJoin	 As char
Local cWhere	 As char
Local cCodTrib	 As char
Local cVersao    As char
Local cCalcIr    As char

Default cAlias 	 := ''
Default oJObjRet := Nil
Default nLen 	 := 0
Default nLen15 	 := 0

nLen15AK  := 0
cAliasQry := ''
cCalcIr   := ''
cCodTrib  := ''

If lTableCDG .AND. !Empty( (cAlias)->CDGSTAMP )

	cAliasQry := GetNextAlias()

	cSelect := "% CCF.CCF_TIPO, CCF.CCF_NUMERO, CCF.CCF_INDSUS, CCF.CCF_TRIB, CDG.CDG_VALOR %"
	cFrom   := "% " + RetSqlName("CDG") + " CDG" + " %" //Processos refer. no documento

	cInJoin := "% " + RetSqlName("CCF") + " CCF ON " //Processos referenciados
	cInJoin += " CCF.CCF_FILIAL = CDG.CDG_FILIAL AND CCF.CCF_NUMERO = CDG.CDG_PROCES AND CCF.CCF_TIPO = CDG.CDG_TPPROC "
	cInJoin += " AND CCF.CCF_IDITEM = CDG.CDG_ITPROC AND CCF.D_E_L_E_T_= ' ' %"

	//Sempre sera refeito o processo por completo, porem aqui deve ser por cada item da nota.
	cWhere := "%"
	cWhere += " CDG.CDG_FILIAL = '" + (cAlias)->FILIAL + "' "		 // SFT.FT_FILIAL
	cWhere += " AND CDG.CDG_TPMOV = '" + (cAlias)->TIPOMOV + "' " 	 // SFT.FT_TIPOMOV
	cWhere += " AND CDG.CDG_DOC = '" + (cAlias)->NFISCAL + "' "		 // SFT.FT_NFISCAL
	cWhere += " AND CDG.CDG_SERIE = '" + (cAlias)->SERIE + "' "		 // SFT.FT_SERIE
	cWhere += " AND CDG.CDG_CLIFOR = '" + (cAlias)->CLIEFOR + "' "	 // SFT.FT_CLIEFOR
	cWhere += " AND CDG.CDG_LOJA = '" + (cAlias)->LOJA + "' "		 // SFT.FT_LOJA
	cWhere += " AND CDG.CDG_ITEM = '" + (cAlias)->ITEM + "' "		 // SFT.FT_ITEM
	cWhere += " AND CDG.D_E_L_E_T_ = ' ' "
	cWhere += "%"

	BeginSql Alias cAliasQry
		SELECT %Exp:cSelect%
		FROM %Exp:cFrom%
		INNER JOIN %Exp:cInJoin%
		WHERE %Exp:cWhere%
		ORDER BY CCF.CCF_TIPO, CCF.CCF_NUMERO, CCF.CCF_INDSUS
	EndSql

	While (cAliasQry)->( !Eof() )
		//DE x PARA (C3S TAF)
		If (cAliasQry)->CCF_TRIB $ "1|2" 	//1=Contribuição previdenciária (INSS) ou 2=Contribuição previdenciária especial (INSS)
			cCodTrib := "13" 	 	//PREVIDENCIA
		ElseIf (cAliasQry)->CCF_TRIB == "3" //3=FUNRURAL
			cCodTrib := "24"		//GILRAT (GRAU DE INCIDÊNCIA DE INCAPACIDADE LABORATIVA DECORRENTE DOS RISCOS AMBIENTAIS DO TRABALHO)
		ElseIf (cAliasQry)->CCF_TRIB == "4" //4=SENAR
			cCodTrib := "25"		//SENAR
		ElseIf (cAliasQry)->CCF_TRIB == "5" //5=CPRB
			cCodTrib := "23"		//CPRB (IMPOSTO SOBRE SERVICOS DE QUALQUER NATUREZA)
		ElseIf (cAliasQry)->CCF_TRIB == "6" //6=ICMS
			cCodTrib := "02"		//ICMS (IMPOSTO SOBRE A CIRCULACAO DE MERCADORIAS E SERVICOS)
		ElseIf (cAliasQry)->CCF_TRIB == "7" //7=PIS
			cCodTrib := "06"		//PIS/PASEP (PROGRAMA DE INTEGRACAO SOCIAL - PROGRAMA DE FORMACAO DO PATRIMONIO DO SERVIDOR PUBLICO)
		ElseIf (cAliasQry)->CCF_TRIB == "8" //8=COFINS
			cCodTrib := "07"		//COFINS (CONTRIBUICAO PARA O FINANCIAMENTO DA SEGURIDADE SOCIAL)
		ElseIf (cAliasQry)->CCF_TRIB == "9" //9=IR
			cCodTrib := "12"		//12 IR (IMPOSTO DE RENDA EMISSÃO)
		ElseIf (cAliasQry)->CCF_TRIB == "A" //A=CSLL
			cCodTrib := "18"		//CSLL (CONTRIBUICAO SOCIAL SOBRE O LUCRO LIQUIDO)
		EndIf

		aAdd( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK], JsonObject( ):New( ) )
		nLen15AK := Len( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK] )

		//typeOfProcess -> T9Q_TPPROC (Pertence(" 12") ) 1=Processo sobre a contribuição previdenciária principal;2=Processo sobre a contribuição previdenciária adicional
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["typeOfProcess" ]          := iif((cAliasQry)->CCF_TRIB $ "1|2",(cAliasQry)->CCF_TRIB,' ') //02 TP_PROC
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["processNumber" ]          := (cAliasQry)->CCF_NUMERO                                      //03 NUM_PROC
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["suspensionCode"]          := (cAliasQry)->CCF_INDSUS                                      //05 COD_SUS
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["retentionValue"]          := (cAliasQry)->CDG_VALOR 						                                      //06 VAL_SUS
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["tributeCode"   ]          := cCodTrib				                                      //07 COD_TRIB
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["baseValueOfSuspendedTax"] := 0                                                            //08 BASE_SUSPENSA
		//Vide extrator fiscal, manter zerado por enquanto. Sera alimentado com a DHR (implementado pelo SIGACOM para o REINF 2.0)
		cVersao := GetVerProc("C1G", (PadR((cAliasQry)->CCF_TIPO,nTmIndPro)+PadR((cAliasQry)->CCF_NUMERO,nTmNmPro) ), 4 )                                         //C1G_FILIAL, C1G_INDPRO, C1G_NUMPRO
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["versionSuspensionCode"] := PadR( cVersao, nTmVers )

		(cAliasQry)->( DbSkip() )
	EndDo

	(cAliasQry)->( DBCloseArea() )

EndIf

If lTableDHR .AND. (cAlias)->TIPOMOV == 'E'

	cAliasQry := GetNextAlias()

	cSelect := "% DHR.DHR_PSIR, DHR.DHR_ISIR, DHR.DHR_TSIR, DHR.DHR_PSPIS, DHR.DHR_ISPIS, DHR.DHR_TSPIS, DHR.DHR_PSCOF, DHR.DHR_ISCOF, DHR.DHR_TSCOF, DHR.DHR_PSCSL, DHR.DHR_ISCSL, DHR.DHR_TSCSL, DHR.DHR_BASEIR, "
	cSelect += " DHR.DHR_VLRIR, DHR.DHR_BASUIR, DHR.DHR_VLRSIR, DHR.DHR_BANFIR, DHR.DHR_VLNFIR, DHR.DHR_BASPIS, DHR.DHR_VLRPIS, DHR.DHR_BSUPIS, DHR.DHR_VLSPIS, DHR.DHR_BNFPIS, DHR.DHR_VNFPIS, DHR.DHR_BASCOF, "
	cSelect += " DHR.DHR_VLRCOF, DHR.DHR_BSUCOF, DHR.DHR_VLSCOF, DHR.DHR_BNFCOF, DHR.DHR_VNFCOF, DHR.DHR_BASCSL, DHR.DHR_VLRCSL, DHR.DHR_BSUCSL, DHR.DHR_VLSCSL, DHR.DHR_BNFCSL, DHR.DHR_VNFCSL %"

	cFrom   := "% " + RetSqlName("DHR") + " DHR" + " %"

	cWhere := "% DHR.DHR_FILIAL =    '" + (cAlias)->FILIAL  + "' "
	cWhere += " AND DHR.DHR_DOC =    '" + (cAlias)->NFISCAL + "' "
	cWhere += " AND DHR.DHR_SERIE =  '" + (cAlias)->SERIE   + "' "	
	cWhere += " AND DHR.DHR_FORNEC = '" + (cAlias)->CLIEFOR + "' "
	cWhere += " AND DHR.DHR_LOJA =   '" + (cAlias)->LOJA    + "' "	
	cWhere += " AND DHR.DHR_ITEM =   '" + (cAlias)->ITEM    + "' "
	cWhere += " AND DHR.D_E_L_E_T_ = ' ' %"

	BeginSql Alias cAliasQry
		SELECT %Exp:cSelect%
		FROM %Exp:cFrom%
		WHERE %Exp:cWhere%
	EndSql

	While (cAliasQry)->( !Eof() )

		//IR
		If  (cAliasQry)->(DHR_BASUIR+DHR_VLRSIR) > 0
			
			cCalcIr := SA2->A2_CALCIRF
			
			If cCalcIr <> '2'
				cCodTrib := '12'
			ElseIf cCalcIr == '2'
				cCodTrib := '28'
			EndIf

			aAdd( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK], JsonObject( ):New( ) )
			nLen15AK := Len( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK] )

			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["typeOfProcess"]           := ''                      //02 TP_PROC
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["processNumber"]           := (cAliasQry)->DHR_PSIR   //03 NUM_PROC
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["suspensionCode"]          := (cAliasQry)->DHR_ISIR   //05 COD_SUS
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["retentionValue"]          := (cAliasQry)->DHR_VLRSIR //06 VAL_SUS
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["tributeCode"   ]          := cCodTrib                //07 COD_TRIB
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["baseValueOfSuspendedTax"] := (cAliasQry)->DHR_BASUIR //08 BASE_SUSPENSA
			cVersao := GetVerProc("C1G", (PadR((cAliasQry)->DHR_TSIR,nTmIndPro)+PadR((cAliasQry)->DHR_PSIR,nTmNmPro) ), 4 )      //C1G_FILIAL, C1G_INDPRO, C1G_NUMPRO
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["versionSuspensionCode"]   := PadR( cVersao, nTmVers )

		Endif

		//PIS
		If (cAliasQry)->(DHR_BSUPIS+DHR_VLSPIS) > 0

			cCodTrib := '10'

			aAdd( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK], JsonObject( ):New( ) )
			nLen15AK := Len( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK] )

			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["typeOfProcess"]           := ''                      //02 TP_PROC
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["processNumber"]           := (cAliasQry)->DHR_PSPIS  //03 NUM_PROC
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["suspensionCode"]          := (cAliasQry)->DHR_ISPIS  //05 COD_SUS
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["retentionValue"]          := (cAliasQry)->DHR_VLSPIS //06 VAL_SUS
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["tributeCode"   ]          := cCodTrib                //07 COD_TRIB
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["baseValueOfSuspendedTax"] := (cAliasQry)->DHR_BSUPIS //08 BASE_SUSPENSA
			cVersao := GetVerProc("C1G", (PadR((cAliasQry)->DHR_TSPIS,nTmIndPro)+PadR((cAliasQry)->DHR_PSPIS,nTmNmPro) ), 4 )    //C1G_FILIAL, C1G_INDPRO, C1G_NUMPRO
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["versionSuspensionCode"]   := PadR( cVersao, nTmVers )

		EndIf

		//COFINS
		IF (cAliasQry)->(DHR_BSUCOF+DHR_VLSCOF) > 0
			
			cCodTrib := '11'

			aAdd( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK], JsonObject( ):New( ) )
			nLen15AK := Len( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK] )

			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["typeOfProcess"]           := ''                      //02 TP_PROC
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["processNumber"]           := (cAliasQry)->DHR_PSCOF  //03 NUM_PROC
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["suspensionCode"]          := (cAliasQry)->DHR_ISCOF  //05 COD_SUS
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["retentionValue"]          := (cAliasQry)->DHR_VLSCOF //06 VAL_SUS
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["tributeCode"   ]          := cCodTrib                //07 COD_TRIB
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["baseValueOfSuspendedTax"] := (cAliasQry)->DHR_BSUCOF //08 BASE_SUSPENSA
			cVersao := GetVerProc("C1G", (PadR((cAliasQry)->DHR_TSCOF,nTmIndPro)+PadR((cAliasQry)->DHR_PSCOF,nTmNmPro) ), 4 )    //C1G_FILIAL, C1G_INDPRO, C1G_NUMPRO
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["versionSuspensionCode"]   := PadR( cVersao, nTmVers )

		EndIf
		
		//CSLL
		IF (cAliasQry)->(DHR_BSUCSL+DHR_BSUCSL) > 0
			
			cCodTrib := '18'

			aAdd( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK], JsonObject( ):New( ) )
			nLen15AK := Len( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK] )

			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["typeOfProcess"]           := ''                      //02 TP_PROC
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["processNumber"]           := (cAliasQry)->DHR_PSCSL  //03 NUM_PROC
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["suspensionCode"]          := (cAliasQry)->DHR_ISCSL  //05 COD_SUS
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["retentionValue"]          := (cAliasQry)->DHR_VLSCSL //06 VAL_SUS
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["tributeCode"   ]          := cCodTrib                //07 COD_TRIB
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["baseValueOfSuspendedTax"] := (cAliasQry)->DHR_BSUCSL //08 BASE_SUSPENSA
			cVersao := GetVerProc("C1G", (PadR((cAliasQry)->DHR_TSCSL,nTmIndPro)+PadR((cAliasQry)->DHR_PSCSL,nTmNmPro) ), 4 )    //C1G_FILIAL, C1G_INDPRO, C1G_NUMPRO
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["versionSuspensionCode"]   := PadR( cVersao, nTmVers )

		EndIf

		(cAliasQry)->( DbSkip() )

	EndDo

	(cAliasQry)->( DBCloseArea() )
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} valTaxPerItm
Função responsável por elaborar json do registro T015AE - Cadastro de tributos por item de documento

@param  oJObjRet   -> Objeto que será utilizado para gerar o json de extração das notas fiscais
@param  aRegT013AP -> array com as inforrmações e valores de tributos da nota fiscal

@author Wesley Pinheiro
@since 14/10/2020

/*/
//-------------------------------------------------------------------
static function valTaxPerItm( oJObjRet, aRegT015AE )

	Local nI       := 0
	Local nLen15AE := 0
	Local nTam15AE := Len( aRegT015AE )

	If nTam15AE > 0

		oJObjRet[cTag15AE] := { }

		for nI:= 1 to nTam15AE

			aAdd( oJObjRet[cTag15AE], JsonObject( ):New( ) )
			nLen15AE := Len( oJObjRet[cTag15AE] )

			oJObjRet[cTag15AE][nLen15AE]["taxCode"]                         := aRegT015AE[nI][2][1][NAECODTRIB] // 02 - COD_TRIB    -> C35_CODTRI  
			oJObjRet[cTag15AE][nLen15AE]["cst"]                             := aRegT015AE[nI][2][1][NAECST]     // 03 - CST         -> C35_CST
			oJObjRet[cTag15AE][nLen15AE]["mva"]                             := aRegT015AE[nI][2][1][NAEMVA]     // 05 - MVA         -> C35_MVA
			oJObjRet[cTag15AE][nLen15AE]["calculationBase"]	                := aRegT015AE[nI][2][1][NAEBS]      // 07 - BASE        -> C35_BASE
			oJObjRet[cTag15AE][nLen15AE]["calculationBaseNotTaxed"]         := aRegT015AE[nI][2][1][NAEBSNT]    // 09 - BASE_NT     -> C35_BASENT
			oJObjRet[cTag15AE][nLen15AE]["taxRate"]                         := aRegT015AE[nI][2][1][NAEALIQ]    // 10 - ALIQUOTA    -> C35_ALIQ
			oJObjRet[cTag15AE][nLen15AE]["taxValue"]                        := aRegT015AE[nI][2][1][NAEVLR]     // 12 - VALOR       -> C35_VALOR
			oJObjRet[cTag15AE][nLen15AE]["exemptValue"]                     := aRegT015AE[nI][2][1][NAEVLRISEN] // 15 - VLR_ISENTO  -> C35_VLISEN
			oJObjRet[cTag15AE][nLen15AE]["otherValue"]                      := aRegT015AE[nI][2][1][NAEVLROUTR] // 16 - VLR_OUTROS  -> C35_VLOUTR
			oJObjRet[cTag15AE][nLen15AE]["nonTaxedValue"]                   := aRegT015AE[nI][2][1][NAEVLRNT]   // 17 - VALOR_NT    -> C35_VLNT
			oJObjRet[cTag15AE][nLen15AE]["valueWithoutCredit"]              := aRegT015AE[nI][2][1][NAEVLRSCRE] // 22 - VL_SCRED    -> C35_VLSCRE
			oJObjRet[cTag15AE][nLen15AE]["subContractServiceValue"]         := aRegT015AE[nI][2][1][NAEVLCONTR] // 24 - VLSCONTR    -> C35_VLSCON	
			oJObjRet[cTag15AE][nLen15AE]["addRetentionAmount"]              := aRegT015AE[nI][2][1][NAEVLRADIC] // 25 - VLRADIC     -> C35_VLRADI
			oJObjRet[cTag15AE][nLen15AE]["UnpaidRetentionAmount"]           := aRegT015AE[nI][2][1][NAEVLRNPAG] // 26 - VLRNPAG     -> C35_VLRNPG
			oJObjRet[cTag15AE][nLen15AE]["serviceValueSpecialCondition15A"] := aRegT015AE[nI][2][1][NAEVLRCE15] // 27 - VLRCE15     -> C35_VLCE15
			oJObjRet[cTag15AE][nLen15AE]["serviceValueSpecialCondition20A"] := aRegT015AE[nI][2][1][NAEVLRCE20] // 28 - VLRCE20     -> C35_VLCE20
			oJObjRet[cTag15AE][nLen15AE]["serviceValueSpecialCondition25A"] := aRegT015AE[nI][2][1][NAEVLRCE25] // 29 - VLRCE25     -> C35_VLCE25
			oJObjRet[cTag15AE][nLen15AE]["addUnpaidRetentionAmount"]        := aRegT015AE[nI][2][1][NAEVRDICPG] // 30 - VLRADICNPAG -> C35_VLRANP

		next nI

	EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} toNumeric
Transforma  possíveis caracteres em numérico

@author Henrique Pereira
@since 12/111/2020

/*/
//-------------------------------------------------------------------
static function toNumeric(xConteud) 
Local nRet as numeric
nRet	:=	0 

Default xConteud := ''

	if ValType( xConteud ) == "C" 
		nRet :=	val(xConteud)
	else
		nRet := xConteud
	endif

return nRet


//-----------------------------------------------------------------------------
/*/{Protheus.doc} IndFrete()
Função responsável por tratar das informações do frete do documento fiscal

@author Carlos Eduardo (Boy)
@since 
/*///--------------------------------------------------------------------------
Static Function IndFrete(cAlias,cIndFrt,cCodSit,cOpcCanc,cEspecie)
Local lRet 		:= .t.

Local cCpoFrete := iif( (cAlias)->TIPOMOV == 'E', 'F1_FRETE','F2_FRETE')
Local cFrete 	:= ''


Default cEspecie := ""

// Adaptando o código de frete de acordo com o layout do extrator fiscal
cFrete := (cAlias)->CDT_INDFRT
cCpoSimpN := iif((cAlias)->FOR_CLI == 'SA1','SA1->A1_SIMPNAC','SA2->A2_SIMPNAC')
cCodSit := SPEDSitDoc(,'SFT',(cAlias)->FOR_CLI,cCpoSimpN,,,(cMVEstado $ cUFRESpd),.F.,,,'SF4')

if lIntTMS .And. (cAlias)->RECDT6 != 0 .And.(cAlias)->TIPOMOV == "S" .And. cEspecie $ "|07|08|09|10|11|26|27|57"
	If !empty(cOpSemF) .And. alltrim((cAlias)->FT_CFOP) $ cOpSemF
		cFrete := "9"
	ElseIf (cAlias)->DT6_DEVFRE $ "1"
		cFrete := '0'	// Por conta do emitente = CIf = 1
	ElseIf (cAlias)->DT6_DEVFRE $ "2"
		cFrete := '1' 	// Por conta do destinatario = FOB = 2
	Else
		cFrete := '2'	// Apesar do sistema gravar 2=FOB, o devedor do frete pode ser o consignatario, espachante ou outros.
	EndIf		
else
	If empty(cFrete)
		If !empty(cOpSemF) .And. alltrim(SFT->FT_CFOP) $ cOpSemF
			cFrete := "9"
		Else
			// Utilizo a informacao configurada nos pedidos de venda/campra
			cFrete := SPEDSitFrt("SFT",IIf((cAlias)->TIPOMOV == "S","SD2","SD1"),.T.,IIf((cAlias)->TIPOMOV == "S","SF2","SF1"),cCpoFrete,,.F.,)		
		EndIf
	EndIf
	
	If (cAlias)->RECCDT != 0
		If Alltrim(cFrete) == "1"	// 0 - Por conta do emitente
			cFrete := "0"
		ElseIf Alltrim(cFrete)=="2"	// 1 - Por conta do destinatário/remetente
			cFrete := "1" 
		ElseIf Alltrim(cFrete)=="0"	// 2 - Por conta de terceiros
			cFrete := "2"
		EndIf
	EndIf
endif	
	
// Adaptando o código de frete de acordo com o layout do extrator fiscal
If cCodSit $ "02#03"
	cIndFrt := ""
ElseIf AllTrim(cFrete) == "0"
	cIndFrt := "1"
ElseIf AllTrim(cFrete) == "1"
	cIndFrt := "2"
ElseIf AllTrim(cFrete) == "2"
	cIndFrt := "0"
Else
	cIndFrt := cFrete
EndIf	

//Regra de Exclusão ou Cancelamento de Nota no Protheus
if cCodSit == '02' 
	cOpcCanc := '4'  //alteracao da situação da nota
elseif Upper( Alltrim( (cAlias)->(OBSERV) ) ) == 'NF EXCLUIDA'
	cCodSit := '02'
	cOpcCanc := '5'  //excluido
else
	cOpcCanc := '' 
endif

//Caso nao exista conteudo eh necessario enviar um default pois eh um campo obrigatorio para integração do documento no TAF.
if Empty(cIndFrt)
	cIndFrt := "9" //sem ocorrencia de transporte
endif

return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} IndPagto()
Função responsável por tratar das informações do pagamento  do cdocumento fiscal

@author Carlos Eduardo (Boy)
@since 14/10/2020
/*///--------------------------------------------------------------------------
Static Function IndPagto()
Local cRet := ''
Local aCmpSFT := array(28)
Local aParcTit := {}

//Para utilizar a funcao Padrao do Protheus SpedProSE2/SE1 deve-se passar o Array aCmpSFT na estrutura conforme foi montada
aCmpSFT[01] := SFT->FT_NFISCAL
aCmpSFT[02] := SFT->FT_SERIE	
aCmpSFT[03] := SFT->FT_CLIEFOR
aCmpSFT[04] := SFT->FT_LOJA	
//aCmpSFT[27] ---> Prefixo, podendo vir da SF1 ou SF2 
//aCmpSFT[28] ---> Duplicata, podendo vir da SF1 ou SF2

//Busca a Quantidade de Parcelas da NF
If SFT->FT_TIPOMOV == 'E'
	aCmpSFT[27] := SF1->F1_PREFIXO
	aCmpSFT[28]	:= SF1->F1_DUPL
	aParcTit := SpedProSE2(aCmpSFT,.t.)
Else
	aCmpSFT[27] := SF2->F2_PREFIXO
	aCmpSFT[28] := SF2->F2_DUPL
	aParcTit :=	SpedProSE1(aCmpSFT,.t.)					
EndIf

// Tratamento para gerar a condicao de pagamento da NF
If empty(aParcTit)
	cRet := '2'		//Sem Pagamento
ElseIf Len( aParcTit) == 1 .And. SFT->FT_EMISSAO == aParcTit[1][7]
	cRet := '0'		//A Vista
Else
	cRet := '1'		//A Prazo
EndIf

return cRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} DestroyObj()
Função responsável por destruir os objetos

@author José Felipe|Karen Honda
@since 05/07/2021
/*///--------------------------------------------------------------------------
Static Function DestroyObj()

	If __oStatCDA <> Nil
		__oStatCDA:Destroy()
		__oStatCDA := Nil
	Endif

	If __oStatSai <> Nil
		__oStatSai:Destroy()
		__oStatSai := Nil
	Endif

	If __oStatEnt <> Nil
		__oStatEnt:Destroy()
		__oStatEnt := Nil
	Endif

	If __oStatCDT <> Nil
		__oStatCDT:Destroy()
		__oStatCDT := Nil
	Endif

Return Nil

/*/{Protheus.doc} createTsiTmp
    (cria tabela temporário do TSI para controle de registros não encontrados)
    @type  Static Function
    @author Renan Gomes
    @since 04/07/2022
	@return Nil, nulo, não tem retorno. 
/*/
/*static Function createTsiTmp(cAliasTMP)
Local oTempTable := nil
Local aFields    := {}

Default cAliasTMP := getNextAlias( )

//Cria a temporária
oTempTable := FWTemporaryTable():New(cAliasTMP)
 
//Adiciona no array das colunas as que serão incluidas (Nome do Campo, Tipo do Campo, Tamanho, Decimais)
aFields := {}
aAdd(aFields, {"FILIAL",  "C",  FwSizeFilial(), 0})
aAdd(aFields, {"NFISCAL", "C",  9, 0})
aAdd(aFields, {"SERIE",   "C",  3, 0})
aAdd(aFields, {"EMISSAO", "D",  8, 0})  
aAdd(aFields, {"CLIFOR",  "C",  6, 0})  
aAdd(aFields, {"LOJA",    "C",  2, 0})  
aAdd(aFields, {"TIPO",    "C",  1, 0})   //E = Entrada , S = Saida
aAdd(aFields, {"STAMP",   "C",  23, 0})
aAdd(aFields, {"RECNO",   "N",  16, 0})
 
//Define as colunas usadas
oTempTable:SetFields( aFields )
 
//Cria índice com colunas setadas anteriormente
oTempTable:AddIndex("INDICE1",{"FILIAL", "NFISCAL","SERIE","CLIFOR","LOJA"} )
 
//Efetua a criação da tabela
oTempTable:Create()

return oTempTable*/
/*/{Protheus.doc} DelTsiTmp
    (deleto tabela temporário do TSI para controle de registros não encontrados)
    @type  Static Function
    @author Renan Gomes
    @since 04/07/2022
	@return Nil, nulo, não tem retorno. 
/*/
/*static Function DelTsiTmp(oTempTable )

If oTempTable <> Nil
	oTempTable:Delete()
    oTempTable := Nil
EndIf

return*/
/*/{Protheus.doc} InsertTmp
	(Função responsável por inserir registros na tabela temporária
	@author Renan
	@since 04/07/2022
	@return Nil, nulo, não tem retorno.
/*/
/*static function InsertTmp(cAliasTmp,cAliasSelf)
 	(cAliasTmp)->(RecLock(cAliasTmp,.T.))
	(cAliasTmp)->FILIAL  := (cAliasSelf)->FILIAL
	(cAliasTmp)->NFISCAL := (cAliasSelf)->NFISCAL
	(cAliasTmp)->SERIE   := (cAliasSelf)->SERIE
	(cAliasTmp)->EMISSAO := stod((cAliasSelf)->DT_DOC)
	(cAliasTmp)->CLIFOR  := (cAliasSelf)->CLIEFOR
	(cAliasTmp)->LOJA    := (cAliasSelf)->LOJA
	(cAliasTmp)->TIPO    := (cAliasSelf)->TIPOMOV
	(cAliasTmp)->STAMP   := (cAliasSelf)->STAMP
	(cAliasTmp)->RECNO   := (cAliasSelf)->RECNOSFT
    (cAliasTmp)->(MsUnLock())
Return*/
/*/{Protheus.doc} RangeStamp
	(Função responsável por buscar o stamp minimo e máximo que está sendo executado
	@author Renan
	@since 04/07/2022
	@return Nil, nulo, não tem retorno.
/*/
/*static function RangeStamp(oTmpTable)
Local cAliasStamp := GetNextAlias()
Local cRangeStamp := ""
Local cQryRange   := ""

If ValType(oTmpTable) == "O"
	cQryRange := "SELECT MIN(STAMP) MIN_STAMP, MAX(STAMP) MAX_STAMP FROM "+oTmpTable:GetRealName()+" "

	dbUseArea( .T., "TOPCONN", TCGenQry( ,, cQryRange ), cAliasStamp, .F., .T. )

	cRangeStamp := (cAliasStamp)->MIN_STAMP + " e " +  (cAliasStamp)->MAX_STAMP
	
	(cAliasStamp)->(DbCloseArea())
	
Endif

Return cRangeStamp*/

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetDUY()
Busca a chave FILIAL + DUY_GRPVEN na tabela DUY e retorna a DUY_EST 
e armazena no hash para posterior consulta sem necessidade de fazer dbseek
@author Karen Honda
@since 19/08/2022
/*/ 
//-----------------------------------------------------------------------
Static Function GetDUY( cChave, cGetDUY )
Local   lRet := .F.
Default cChave := ''
Default cGetDUY := ''

if ValType(oHashDUY) == "O"
    HMGet( oHashDUY, cChave, @cGetDUY )
    if Empty(cGetDUY)
		If Select("DUY") == 0
			DbSelectArea("DUY")
			DBSetOrder(1)
		EndIf

		If DUY->( DBSeek(cChave) )
        	cGetDUY := DUY->DUY_EST
        	SetHashKey(oHashDUY, cChave, cGetDUY) 
			lRet := .T.	
		EndIf
	else
		lRet := .T.		
    Endif
endif

Return lRet
