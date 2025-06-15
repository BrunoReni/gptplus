#Include "TOTVS.ch"
#Include "GFER002.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} GFER002()
Relatório de Visão Geral de Fretes
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFER002()
	Private _aFields   := {}
	Private _cMvPar01  := Nil
	Private _cMvPar02  := Nil
	Private _cMvPar03  := Nil
	Private _cMvPar04  := Nil
	Private _cMvPar05  := Nil
	Private _cMvPar06  := Nil
	Private _cMvPar07  := Nil
	Private _IntGFE    := SuperGetMV('MV_ERPGFE',,'1') == '1'
	Private nHandle    := Nil
	Private oReport    := Nil
	Private oSection   := Nil
	// Variáveis Impressão
	Private cGW1FILIAL := Nil
	Private cGW1NMFIL  := Nil
	Private cGW1CDTPDC := Nil
	Private cGW1EMISDC := Nil
	Private cCNPJEMIS  := Nil
	Private cNMEMIS    := Nil
	Private cGW1SERDC  := Nil
	Private cGW1NRDC   := Nil
	Private cGW1DANFE  := Nil
	Private cGW1DTEMIS := Nil
	Private cGW1DTIMPL := Nil
	Private cGW1DTSAI  := Nil
	Private cGW1USO    := Nil
	Private cGW1REGCOM := Nil
	Private cGW8ITEM   := Nil
	Private cGW8DSITEM := Nil
	Private cGW8QTDE   := Nil
	Private cGW8VALOR  := Nil
	Private cGW8VOLUME := Nil
	Private cGW8PESOC  := Nil
	Private cGW8PESOR  := Nil
	Private cGW8QTDALT := Nil
	Private cGUBDSCLFR := Nil
	Private cGW8CFOP   := Nil
	Private cGW8INFO1  := Nil
	Private cGW8INFO2  := Nil
	Private cGW8INFO3  := Nil
	Private cGW8INFO4  := Nil
	Private cGW8INFO5  := Nil
	Private cGW1CDREM  := Nil
	Private cCNPJREM   := Nil
	Private cNMREM     := Nil
	Private cGW1CDDEST := Nil
	Private cCNPJDEST  := Nil
	Private cNMDEST    := Nil
	Private cGW1SIT    := Nil
	Private cGW0MSG    := Nil
	Private cGW1CALCAT := Nil
	Private cGW1ROMTV  := Nil
	Private cGW1ROMCF  := Nil
	Private cGW1ROMTO  := Nil
	Private cGU3NRCID  := Nil
	Private cGWUNRCIDO := Nil
	Private cNMCIDO    := Nil
	Private cUFO       := Nil
	Private cGWUNRCIDD := Nil
	Private cNMCIDD    := Nil
	Private cUFD       := Nil
	Private cNMREGP    := Nil
	Private cNMREGD    := Nil
	Private cGWUSEQ    := Nil
	Private cGWUPAGAR  := Nil
	Private cGWUCDTRP  := Nil
	Private cCNPJTRP   := Nil
	Private cNMTRP     := Nil
	Private cAUTON     := Nil
	Private cMODAL     := Nil
	Private cTPTRIB    := Nil
	Private cGWNNRROM  := Nil
	Private cGWNSIT    := Nil
	Private cGWNCDTPVC := Nil
	Private cGWNCDCLFR := Nil
	Private cGWNCDTPOP := Nil
	Private cGWNCALC   := Nil
	Private cGWNMTCALC := Nil
	Private cGWNVPVAL  := Nil
	Private cGWUDTPENT := Nil
	Private cGWUHRPENT := Nil
	Private cGWUDTENT  := Nil
	Private cGWUHRENT  := Nil
	Private cGWFNRCALC := Nil
	Private cGWFTPFRET := Nil
	Private cVLFRET    := Nil
	Private cVLICMS    := Nil
	Private cVLPIS     := Nil
	Private cVLCOFI    := Nil
	Private cGWFTPTRIB := Nil
	Private cGWFCRDICM := Nil
	Private cGWFCRDPC  := Nil
	Private cGWGNRTAB  := Nil
	Private cGWGNRNEG  := Nil
	Private cGWGCDFXTV := Nil
	Private cGWGCDTPOP := Nil
	Private cGWGCDTPVC := Nil
	Private cGWGCDCLFR := Nil
	Private cGV9UNIFAI := Nil
	Private cGWGNRROTA := Nil
	Private cDESCROTA  := Nil
	Private cGWJNRPF   := Nil
	Private cGWJDTIMPL := Nil
	Private cGWJSIT    := Nil
	Private cGWJSITFIN := Nil
	Private cCODLOTE   := Nil
	Private cGXFVALOR  := Nil
	Private cPERLOTE   := Nil
	Private cSITLOTE   := Nil
	Private cGXTNRCT   := Nil
	Private cGW3CDESP  := Nil
	Private cGW3NRDF   := Nil
	Private cGW3SERDF  := Nil
	Private cGW3TPDF   := Nil
	Private cGW3DTENT  := Nil
	Private cGW3DTEMIS := Nil
	Private cVLFRETDF  := Nil
	Private cVLICMSDF  := Nil
	Private cVLPISDF   := Nil
	Private cVLCOFIDF  := Nil
	Private cGW3SIT    := Nil
	Private cGXGEDISIT := Nil
	Private cGW3MOTBLQ := Nil
	Private cGW3SITFIS := Nil
	Private cGW3DTFIS  := Nil
	Private cGW3SITREC := Nil
	Private cGW3DTREC  := Nil
	Private cGW3SITCUS := Nil
	Private cGW3DTCUS  := Nil
	Private cGW3SITMLA := Nil
	Private cGW6NRFAT  := Nil
	Private cGW6DTEMIS := Nil
	Private cGW6VLFATU := Nil
	Private cGW6SITAPR := Nil
	Private cGW6DTFIN  := Nil
	Private cGW6SITFIN := Nil

	If Pergunte('GFER002')
		_cMvPar01 := DToS(MV_PAR01)
		_cMvPar02 := DToS(MV_PAR02)
		_cMvPar03 := DToS(MV_PAR03)
		_cMvPar04 := DToS(MV_PAR04)
		_cMvPar05 := MV_PAR05
		_cMvPar06 := IIf(!Empty(MV_PAR06),MV_PAR06,1)
		_cMvPar07 := IIf(!Empty(MV_PAR07),AllTrim(MV_PAR07),'')

		If _cMvPar06 == 1
			GFER002Rep()
		Else
			GFER002Txt()
		EndIf
	EndIf
Return Nil

/*/{Protheus.doc} GFER002GerRep
	Geração do relatório padrão
	@type  Static Function
	@author SQuad GFE
	@since 26/03/2020
	@version 1.0
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function GFER002Rep()
	//Teste padrão
	If TRepInUse()
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Definição do obejto TReport
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local aGW1FILIAL := {}
Local aGW1NMFIL  := {}
Local aGW1CDTPDC := {}
Local aGW1EMISDC := {}
Local aCNPJEMIS  := {}
Local aNMEMIS    := {}
Local aGW1SERDC  := {}
Local aGW1NRDC   := {}
Local aGW1DANFE  := {}
Local aGW1DTEMIS := {}
Local aGW1DTIMPL := {}
Local aGW1DTSAI  := {}
Local aGW1USO    := {}
Local aGW1REGCOM := {}
Local aGW8ITEM   := {}
Local aGW8DSITEM := {}
Local aGW8QTDE   := {}
Local aGW8VALOR  := {}
Local aGW8VOLUME := {}
Local aGW8PESOC  := {}
Local aGW8PESOR  := {}
Local aGW8QTDALT := {}
Local aGUBDSCLFR := {}
Local aGW8CFOP   := {}
Local aGW8INFO1  := {}
Local aGW8INFO2  := {}
Local aGW8INFO3  := {}
Local aGW8INFO4  := {}
Local aGW8INFO5  := {}
Local aGW1CDREM  := {}
Local aCNPJREM   := {}
Local aNMREM     := {}
Local aGW1CDDEST := {}
Local aCNPJDEST  := {}
Local aNMDEST    := {}
Local aGW1SIT    := {}
Local aGW0MSG    := {}
Local aGW1CALCAT := {}
Local aGW1ROMTV  := {}
Local aGW1ROMCF  := {}
Local aGW1ROMTO  := {}
Local aGU3NRCID  := {}
Local aGWUNRCIDO := {}
Local aNMCIDO    := {}
Local aUFO       := {}
Local aGWUNRCIDD := {}
Local aNMCIDD    := {}
Local aUFD       := {}
Local aNMREGP    := {}
Local aNMREGD    := {}
Local aGWUSEQ    := {}
Local aGWUPAGAR  := {}
Local aGWUCDTRP  := {}
Local aCNPJTRP   := {}
Local aNMTRP     := {}
Local aAUTON     := {}
Local aMODAL     := {}
Local aTPTRIB    := {}
Local aGWNNRROM  := {}
Local aGWNSIT    := {}
Local aGWNCDTPVC := {}
Local aGWNCDCLFR := {}
Local aGWNCDTPOP := {}
Local aGWNCALC   := {}
Local aGWNMTCALC := {}
Local aGWNVPVAL  := {}
Local aGWUDTPENT := {}
Local aGWUHRPENT := {}
Local aGWUDTENT  := {}
Local aGWUHRENT  := {}
Local aGWFNRCALC := {}
Local aGWFTPFRET := {}
Local aVLFRET    := {}
Local aVLICMS    := {}
Local aVLPIS     := {}
Local aVLCOFI    := {}
Local aGWFTPTRIB := {}
Local aGWFCRDICM := {}
Local aGWFCRDPC  := {}
Local aGWGNRTAB  := {}
Local aGWGNRNEG  := {}
Local aGWGCDFXTV := {}
Local aGWGCDTPOP := {}
Local aGWGCDTPVC := {}
Local aGWGCDCLFR := {}
Local aGV9UNIFAI := {}
Local aGWGNRROTA := {}
Local aDESCROTA  := {}
Local aGWJNRPF   := {}
Local aGWJDTIMPL := {}
Local aGWJSIT    := {}
Local aGWJSITFIN := {}
Local aCODLOTE   := {}
Local aGXFVALOR  := {}
Local aPERLOTE   := {}
Local aSITLOTE   := {}
Local aGXTNRCT   := {}
Local aGW3CDESP  := {}
Local aGW3NRDF   := {}
Local aGW3SERDF  := {}
Local aGW3TPDF   := {}
Local aGW3DTENT  := {}
Local aGW3DTEMIS := {}
Local aVLFRETDF  := {}
Local aVLICMSDF  := {}
Local aVLPISDF   := {}
Local aVLCOFIDF  := {}
Local aGW3SIT    := {}
Local aGXGEDISIT := {}
Local aGW3MOTBLQ := {}
Local aGW3SITFIS := {}
Local aGW3DTFIS  := {}
Local aGW3SITREC := {}
Local aGW3DTREC  := {}
Local aGW3SITCUS := {}
Local aGW3DTCUS  := {}
Local aGW3SITMLA := {}
Local aGW6NRFAT  := {}
Local aGW6DTEMIS := {}
Local aGW6VLFATU := {}
Local aGW6SITAPR := {}
Local aGW6DTFIN  := {}
Local aGW6SITFIN := {}
Local oSection1  := Nil
Local oFieldHide := Nil
Local cData      := __FWLibVersion()


	GFEFindSx3("GW1_FILIAL",aGW1FILIAL,,,,,"@!")
	GFEFindSx3(,aGW1NMFIL,,30,0,"C","@!")
	GFEFindSx3("GW1_CDTPDC",aGW1CDTPDC)
	GFEFindSx3("GW1_EMISDC",aGW1EMISDC)
	GFEFindSx3("GU3_IDFED",aCNPJEMIS)
	GFEFindSx3("GU3_NMEMIT",aNMEMIS)
	GFEFindSx3("GW1_SERDC",aGW1SERDC)
	GFEFindSx3("GW1_NRDC",aGW1NRDC)
	GFEFindSx3("GW1_DANFE",aGW1DANFE)
	GFEFindSx3("GW1_DTEMIS",aGW1DTEMIS)
	GFEFindSx3("GW1_DTIMPL",aGW1DTIMPL)
	GFEFindSx3("GW1_DTSAI",aGW1DTSAI)
	GFEFindSx3("GW1_USO",aGW1USO,,25)
	GFEFindSx3("GW1_REGCOM",aGW1REGCOM)
	GFEFindSx3("GW8_ITEM",aGW8ITEM)
	GFEFindSx3("GW8_DSITEM",aGW8DSITEM)
	GFEFindSx3("GW8_QTDE",aGW8QTDE)
	GFEFindSx3("GW8_VALOR",aGW8VALOR)
	GFEFindSx3("GW8_VOLUME",aGW8VOLUME)
	GFEFindSx3("GW8_PESOC",aGW8PESOC)
	GFEFindSx3("GW8_PESOR",aGW8PESOR)
	GFEFindSx3("GW8_QTDALT",aGW8QTDALT)
	GFEFindSx3("GUB_DSCLFR",aGUBDSCLFR)
	GFEFindSx3("GW8_CFOP",aGW8CFOP)
	GFEFindSx3("GW8_INFO1",aGW8INFO1)
	GFEFindSx3("GW8_INFO2",aGW8INFO2)
	GFEFindSx3("GW8_INFO3",aGW8INFO3)
	GFEFindSx3("GW8_INFO4",aGW8INFO4)
	GFEFindSx3("GW8_INFO5",aGW8INFO5)
	GFEFindSx3("GW1_CDREM",aGW1CDREM)
	aCNPJREM   := aCNPJEMIS
	aNMREM     := aNMEMIS
	GFEFindSx3("GW1_CDREM",aGW1CDDEST)
	aCNPJDEST  := aCNPJEMIS
	aNMDEST    := aNMEMIS
	GFEFindSx3("GW1_SIT",aGW1SIT,,25)
	GFEFindSx3("GW0_CHAR01",aGW0MSG)
	GFEFindSx3("GW1_CALCAT",aGW1CALCAT,,25)
	GFEFindSx3("GW1_ROMTV",aGW1ROMTV)
	GFEFindSx3("GW1_ROMCF",aGW1ROMCF)
	GFEFindSx3("GW1_ROMTO",aGW1ROMTO)
	GFEFindSx3("GU3_NRCID",aGU3NRCID)
	GFEFindSx3("GWU_NRCIDO",aGWUNRCIDO)
	aNMCIDO    := aGU3NRCID
	GFEFindSx3("GU7_CDUF",aUFO)
	aGWUNRCIDD := aGWUNRCIDO
	GFEFindSx3("GU7_NMCID",aNMCIDD)
	GFEFindSx3("GU7_CDUF",aUFD)
	GFEFindSx3("GU9_NMREG",aNMREGP)
	aNMREGD    := aNMREGP
	GFEFindSx3("GWU_SEQ",aGWUSEQ)
	GFEFindSx3("GWU_PAGAR",aGWUPAGAR,,3)
	GFEFindSx3("GWU_CDTRP",aGWUCDTRP)
	aCNPJTRP   := aGWUCDTRP
	GFEFindSx3("GU3_NMEMIT",aNMTRP)
	GFEFindSx3("GU3_AUTON",aAUTON,,15)
	GFEFindSx3("GU3_MODAL",aMODAL,,25)
	GFEFindSx3("GU3_TPTRIB",aTPTRIB,,25)
	GFEFindSx3("GWN_NRROM",aGWNNRROM)
	GFEFindSx3("GWN_SIT",aGWNSIT,,25)
	GFEFindSx3("GWN_CDTPVC",aGWNCDTPVC)
	GFEFindSx3("GWN_CDCLFR",aGWNCDCLFR)
	GFEFindSx3("GWN_CDTPOP",aGWNCDTPOP)
	GFEFindSx3("GWN_CALC",aGWNCALC,,25)
	GFEFindSx3("GWN_MTCALC",aGWNMTCALC)
	GFEFindSx3("GWN_VPVAL",aGWNVPVAL)
	GFEFindSx3("GWU_DTPENT",aGWUDTPENT)
	GFEFindSx3("GWU_HRPENT",aGWUHRPENT)
	GFEFindSx3("GWU_DTENT",aGWUDTENT)
	GFEFindSx3("GWU_HRENT",aGWUHRENT)
	GFEFindSx3("GWF_NRCALC",aGWFNRCALC)
	GFEFindSx3("GWF_TPFRET",aGWFTPFRET,,25)
	GFEFindSx3("GWM_VLFRET",aVLFRET)
	GFEFindSx3("GWM_VLICMS",aVLICMS)
	GFEFindSx3("GWM_VLPIS",aVLPIS)
	GFEFindSx3("GWM_VLCOFI",aVLCOFI)
	GFEFindSx3("GWF_TPTRIB",aGWFTPTRIB,,25)
	GFEFindSx3("GWF_CRDICM",aGWFCRDICM,,3)
	GFEFindSx3("GWF_CRDPC",aGWFCRDPC,,3)
	GFEFindSx3("GWG_NRTAB",aGWGNRTAB)
	GFEFindSx3("GWG_NRNEG",aGWGNRNEG)
	GFEFindSx3("GWG_CDFXTV",aGWGCDFXTV)
	GFEFindSx3("GWG_CDTPOP",aGWGCDTPOP)
	GFEFindSx3("GWG_CDTPVC",aGWGCDTPVC)
	GFEFindSx3("GWG_CDCLFR",aGWGCDCLFR)
	GFEFindSx3("GV9_UNIFAI",aGV9UNIFAI)
	GFEFindSx3("GWG_NRROTA",aGWGNRROTA)
	GFEFindSx3("GV6_INFROT",aDESCROTA)
	GFEFindSx3("GWJ_NRPF",aGWJNRPF)
	GFEFindSx3("GWJ_DTIMPL",aGWJDTIMPL)
	GFEFindSx3("GWJ_SIT",aGWJSIT)
	GFEFindSx3("GWJ_SITFIN",aGWJSITFIN)
	GFEFindSx3("GXE_CODLOT",aCODLOTE)
	GFEFindSx3("GXF_VALOR",aGXFVALOR)
	GFEFindSx3("GXE_PERIOD",aPERLOTE)
	GFEFindSx3("GXE_SIT",aSITLOTE)
	GFEFindSx3("GXT_NRCT",aGXTNRCT)
	GFEFindSx3("GW3_CDESP",aGW3CDESP)
	GFEFindSx3("GW3_NRDF",aGW3NRDF)
	GFEFindSx3("GW3_SERDF",aGW3SERDF)
	GFEFindSx3("GW3_TPDF",aGW3TPDF,,25)
	GFEFindSx3("GW3_DTENT",aGW3DTENT)
	GFEFindSx3("GW3_DTEMIS",aGW3DTEMIS)
	GFEFindSx3("GWM_VLFRET",aVLFRETDF)
	GFEFindSx3("GWM_VLICMS",aVLICMSDF)
	GFEFindSx3("GWM_VLPIS",aVLPISDF)
	GFEFindSx3("GWM_VLCOFI",aVLCOFIDF)
	GFEFindSx3(,aGW3SIT,,25,0,"C","@!")
	GFEFindSx3(,aGXGEDISIT,,25,0,"C","@!")
	GFEFindSx3("GW3_MOTBLQ",aGW3MOTBLQ)
	GFEFindSx3("GW3_SITFIS",aGW3SITFIS,,25)
	GFEFindSx3("GW3_DTFIS",aGW3DTFIS)
	GFEFindSx3("GW3_SITREC",aGW3SITREC,,25)
	GFEFindSx3("GW3_DTREC",aGW3DTREC)
	GFEFindSx3("GW3_SITCUS",aGW3SITCUS,,25)
	GFEFindSx3("GW3_DTCUS",aGW3DTCUS)
	GFEFindSx3("GW3_SITMLA",aGW3SITMLA,,25)
	GFEFindSx3("GW6_NRFAT",aGW6NRFAT)
	GFEFindSx3("GW6_DTEMIS",aGW6DTEMIS)
	GFEFindSx3("GW6_VLFATU",aGW6VLFATU)
	GFEFindSx3(,aGW6SITAPR,,25,0,"C","@!")
	GFEFindSx3("GW6_DTFIN",aGW6DTFIN)
	GFEFindSx3("GW6_SITFIN",aGW6SITFIN,,25)

	oReport := TReport():New("GFER002","Relatório Visão Geral de Fretes","GFER002", {|oReport| ReportPrint(oReport)},)
	oReport:SetLandscape()
	oReport:HideParamPage()
	oReport:NDEVICE := 4    //DEFINE COMO EXCEL A SAÍDA

	If (cData >= "20180413") // Somente a partir desta versão existe a propriedade lExcelWrXml no TReport
		oReport:lExcelWrXml := .T.
	EndIf
	
	oSection1 := TRSection():New(oReport,STR0001,) // Relatório Visão Geral de Fretes
	oSection1:SetTotalInLine(.F.)
	TRCell():New(oSection1, "cGW1FILIAL", aGW1FILIAL[5], STR0002 , aGW1FILIAL[4] ,aGW1FILIAL[2] ,.T.,{||cGW1FILIAL}) // Código Filial
	TRCell():New(oSection1, "cGW1NMFIL" , aGW1NMFIL[5] , STR0003 , aGW1NMFIL[4]  ,aGW1NMFIL[2]  ,.T.,{||cGW1NMFIL})  // Nome Filial
	TRCell():New(oSection1, "cGW1CDTPDC", aGW1CDTPDC[5], STR0004 , aGW1CDTPDC[4] ,aGW1CDTPDC[2] ,.T.,{||cGW1CDTPDC}) // Tipo DC
	TRCell():New(oSection1, "cGW1EMISDC", aGW1EMISDC[5], STR0005 , aGW1EMISDC[4] ,aGW1EMISDC[2] ,.T.,{||cGW1EMISDC}) // Cód. Emissor
	TRCell():New(oSection1, "cCNPJEMIS" , aCNPJEMIS[5] , STR0006 , aCNPJEMIS[4]  ,aCNPJEMIS[2]  ,.T.,{||cCNPJEMIS})  // CNPJ/CPF Emis.
	TRCell():New(oSection1, "cNMEMIS"   , aNMEMIS[5]   , STR0007 , aNMEMIS[4]    ,aNMEMIS[2]    ,.T.,{||cNMEMIS})    // Nome Emissor
	TRCell():New(oSection1, "cGW1SERDC" , aGW1SERDC[5] , STR0008 , aGW1SERDC[4]  ,aGW1SERDC[2]  ,.T.,{||cGW1SERDC})  // Série DC
	TRCell():New(oSection1, "cGW1NRDC"  , aGW1NRDC[5]  , STR0009 , aGW1NRDC[4]   ,aGW1NRDC[2]   ,.T.,{||cGW1NRDC})   // Número DC

	oFieldHide := TRCell():New(oSection1, "cGW1DANFE" , aGW1DANFE[5], STR0010 , aGW1DANFE[4] ,aGW1DANFE[2] ,.T.,{||cGW1DANFE}) // Chave Acesso
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "cGW1DTEMIS", aGW1DTEMIS[5], STR0011 , aGW1DTEMIS[4] ,aGW1DTEMIS[2] ,.T.,{||cGW1DTEMIS}) // Dt. Emissão
	TRCell():New(oSection1, "cGW1DTIMPL", aGW1DTIMPL[5], STR0012 , aGW1DTIMPL[4] ,aGW1DTIMPL[2] ,.T.,{||cGW1DTIMPL}) // Dt. Implantação
	TRCell():New(oSection1, "cGW1DTSAI" , aGW1DTSAI[5] , STR0013 , aGW1DTSAI[4]  ,aGW1DTSAI[2]  ,.T.,{||cGW1DTSAI})  // Dt. Saída
	TRCell():New(oSection1, "cGW1USO"   , aGW1USO[5]   , STR0014 , aGW1USO[4]    ,aGW1USO[2]    ,.T.,{||cGW1USO})    // Finalidade

	oFieldHide := TRCell():New(oSection1, "cGW1REGCOM", aGW1REGCOM[5], STR0015 , aGW1REGCOM[4] ,aGW1REGCOM[2] ,.T.,{||cGW1REGCOM}) // Região Comercial
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "cGW8ITEM"  , aGW8ITEM[5]  , STR0016 , aGW8ITEM[4]   ,aGW8ITEM[2]   ,.T.,{||cGW8ITEM})   // Item
	TRCell():New(oSection1, "cGW8DSITEM", aGW8DSITEM[5], STR0017 , aGW8DSITEM[4] ,aGW8DSITEM[2] ,.T.,{||cGW8DSITEM}) // Descrição Item
	TRCell():New(oSection1, "cGW8QTDE"  , aGW8QTDE[5]  , STR0018 , aGW8QTDE[4]   ,aGW8QTDE[2]   ,.T.,{||cGW8QTDE})   // Quantidade Item
	TRCell():New(oSection1, "cGW8VALOR" , aGW8VALOR[5] , STR0019 , aGW8VALOR[4]  ,aGW8VALOR[2]  ,.T.,{||cGW8VALOR})  // Valor Item
	TRCell():New(oSection1, "cGW8VOLUME", aGW8VOLUME[5], STR0020 , aGW8VOLUME[4] ,aGW8VOLUME[2] ,.T.,{||cGW8VOLUME}) // Volume Item
	TRCell():New(oSection1, "cGW8PESOC" , aGW8PESOC[5] , STR0021 , aGW8PESOC[4]  ,aGW8PESOC[2]  ,.T.,{||cGW8PESOC})  // Peso Cubado Item
	TRCell():New(oSection1, "cGW8PESOR" , aGW8PESOR[5] , STR0022 , aGW8PESOR[4]  ,aGW8PESOR[2]  ,.T.,{||cGW8PESOR})  // Peso Real Item
	TRCell():New(oSection1, "cGW8QTDALT", aGW8QTDALT[5], STR0023 , aGW8QTDALT[4] ,aGW8QTDALT[2] ,.T.,{||cGW8QTDALT}) // Quantidade/Peso Alt.
	TRCell():New(oSection1, "cGUBDSCLFR", aGUBDSCLFR[5], STR0024 , aGUBDSCLFR[4] ,aGUBDSCLFR[2] ,.T.,{||cGUBDSCLFR}) // Classificação De Frete
	TRCell():New(oSection1, "cGW8CFOP"  , aGW8CFOP[5]  , STR0025 , aGW8CFOP[4]   ,aGW8CFOP[2]   ,.T.,{||cGW8CFOP})   // CFOP

	oFieldHide := TRCell():New(oSection1, "cGW8INFO1", aGW8INFO1[5], IIf(_IntGFE ,STR0026 ,STR0027) ,aGW8INFO1[4] ,aGW8INFO1[2] , .T.,{||cGW8INFO1}) // Natureza de Operação // Info Contábil 1
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "cGW8INFO2", aGW8INFO2[5], IIf(_IntGFE ,STR0028 ,STR0029) ,aGW8INFO2[4] ,aGW8INFO2[2] , .T.,{||cGW8INFO2}) // Canal de Vendas      // Info Contábil 2
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "cGW8INFO3", aGW8INFO3[5], IIf(_IntGFE ,STR0030 ,STR0031) ,aGW8INFO3[4] ,aGW8INFO3[2] , .T.,{||cGW8INFO3}) // Grupo de Estoque     // Info Contábil 3
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "cGW8INFO4", aGW8INFO4[5], IIf(_IntGFE ,STR0032 ,STR0033) ,aGW8INFO4[4] ,aGW8INFO4[2] , .T.,{||cGW8INFO4}) // Família Comercial    // Info Contábil 4
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "cGW8INFO5", aGW8INFO5[5], IIf(_IntGFE ,STR0034 ,STR0035) ,aGW8INFO5[4] ,aGW8INFO5[2] , .T.,{||cGW8INFO5}) // Família de Materiais // Info Contábil 5
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "cGW1CDREM"  , aGW1CDREM[5], STR0036 , aGW1CDREM[4] ,aGW1CDREM[2] ,.T.,{||cGW1CDREM}) // Código Remetente

	oFieldHide := TRCell():New(oSection1, "cCNPJREM" , aCNPJREM[5], STR0037 , aCNPJREM[4]  ,aCNPJREM[2]  ,.T.,{||cCNPJREM}) // CNPJ/CPF Remetente
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "cNMREM"     , aNMREM[5]    , STR0038 , aNMREM[4]    ,aNMREM[2]    ,.T.,{||cNMREM})     // Nome Remetente
	TRCell():New(oSection1, "cGW1CDDEST" , aGW1CDDEST[5], STR0039 , aGW1CDDEST[4],aGW1CDDEST[2],.T.,{||cGW1CDDEST}) // Código Destinatário

	oFieldHide := TRCell():New(oSection1, "cCNPJDEST" , aCNPJDEST[5], STR0040 , aCNPJDEST[4] ,aCNPJDEST[2] ,.T.,{||cCNPJDEST}) // CNPJ/CPF Destinatário
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "cNMDEST"     , aNMDEST[5]   , STR0041 , aNMDEST[4]   ,aNMDEST[2]   ,.T.,{||cNMDEST})    // Nome Destinatário
	TRCell():New(oSection1, "cGW1SIT"     , aGW1SIT[5]   , STR0042 , aGW1SIT[4]   ,aGW1SIT[2]   ,.T.,{||cGW1SIT})    // Situação
	TRCell():New(oSection1, "cGW0MSG"     , aGW0MSG[5]   , STR0043 , aGW0MSG[4]   ,aGW0MSG[2]   ,.T.,{||cGW0MSG})    // Motivo Bloqueio
	TRCell():New(oSection1, "cGW1CALCAT"  , aGW1CALCAT[5], STR0044 , aGW1CALCAT[4],aGW1CALCAT[2],.T.,{||cGW1CALCAT}) // Sit. Cálc Automático

	oFieldHide := TRCell():New(oSection1, "cGW1ROMTV" , aGW1ROMTV[5] , STR0045 , aGW1ROMTV[4] ,aGW1ROMTV[2] ,.T.,{||cGW1ROMTV}) // Tipo Veículo Romaneio
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "cGW1ROMCF" , aGW1ROMCF[5] , STR0046 , aGW1ROMCF[4] ,aGW1ROMCF[2] ,.T.,{||cGW1ROMCF}) // Classificação de Frete Romaneio
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "cGW1ROMTO" , aGW1ROMTO[5] , STR0047 , aGW1ROMTO[4] ,aGW1ROMTO[2] ,.T.,{||cGW1ROMTO}) // Tipo de Operação Romaneio
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "cGU3NRCID" , aGU3NRCID[5] , STR0048 , aGU3NRCID[4] ,aGU3NRCID[2] ,.T.,{||cGU3NRCID}) // Cód. Cidade Emit
	oFieldHide:lUserEnabled := .F. 

	oFieldHide := TRCell():New(oSection1, "cGWUNRCIDO", aGWUNRCIDO[5], STR0049 , aGWUNRCIDO[4],aGWUNRCIDO[2],.T.,{||cGWUNRCIDO}) // Cód. Cidade Origem
	oFieldHide:lUserEnabled := .F.    

	TRCell():New(oSection1, "cNMCIDO"     , aNMCIDO[5] , STR0050 , aNMCIDO[4] ,aNMCIDO[2] ,.T.,{||cNMCIDO}) // Nome Cidade Origem
	TRCell():New(oSection1, "cUFO"        , aUFO[5]    , STR0051 , aUFO[4]    ,aUFO[2]    ,.T.,{||cUFO})    // UF Cidade Origem

	oFieldHide := TRCell():New(oSection1, "cGWUNRCIDD" , aGWUNRCIDD[5], STR0052 , aGWUNRCIDD[4],aGWUNRCIDD[2],.T.,{||cGWUNRCIDD}) // Cód. Cidade Destino
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "cNMCIDD"     , aNMCIDD[5], STR0053 , aNMCIDD[4]   ,aNMCIDD[2]   ,.T.,{||cNMCIDD}) // Nome Cidade Destino
	TRCell():New(oSection1, "cUFD"        , aUFD[5]   , STR0054 , aUFD[4]      ,aUFD[2]      ,.T.,{||cUFD})    // UF Cidade Destino

	oFieldHide := TRCell():New(oSection1, "cNMREGP" , aNMREGP[5], STR0055 , aNMREGP[4]   ,aNMREGP[2]   ,.T.,{||cNMREGP}) // Região Própria
	oFieldHide:lUserEnabled := .F.   

	oFieldHide := TRCell():New(oSection1, "cNMREGD" , aNMREGD[5], STR0056 , aNMREGD[4]   ,aNMREGD[2]   ,.T.,{||cNMREGD}) // Região Negociação Frete
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "cGWUSEQ"    , aGWUSEQ[5]  , STR0057 , aGWUSEQ[4]   ,aGWUSEQ[2]   ,.T.,{||cGWUSEQ})   // Sequência do Itinerário
	TRCell():New(oSection1, "cGWUPAGAR"  , aGWUPAGAR[5], STR0058 , aGWUPAGAR[4] ,aGWUPAGAR[2] ,.T.,{||cGWUPAGAR}) // Pagar
	TRCell():New(oSection1, "cGWUCDTRP"  , aGWUCDTRP[5], STR0059 , aGWUCDTRP[4] ,aGWUCDTRP[2] ,.T.,{||cGWUCDTRP}) // Código Transportador

	oFieldHide := TRCell():New(oSection1, "cCNPJTRP" , aCNPJTRP[5], STR0060 , aCNPJTRP[4]  ,aCNPJTRP[2]  ,.T.,{||cCNPJTRP}) // CNPJ/CPF Transportador
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "cNMTRP"     , aNMTRP[5], STR0061 , aNMTRP[4]    ,aNMTRP[2]    ,.T.,{||cNMTRP}) // Nome Transportador

	oFieldHide := TRCell():New(oSection1, "cAUTON"   , aAUTON[5] , STR0062 , aAUTON[4]    ,aAUTON[2]    ,.T.,{||cAUTON}) // Tipo Transportador
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "cMODAL"     , aMODAL[5], STR0063 , aMODAL[4]    ,aMODAL[2]    ,.T.,{||cMODAL}) // Modal Transportador

	oFieldHide := TRCell():New(oSection1, "cTPTRIB"  , aTPTRIB[5], STR0064 , aTPTRIB[4]   ,aTPTRIB[2]   ,.T.,{||cTPTRIB}) // Regime Tributário Transp.
	oFieldHide:lUserEnabled := .F.

	TRCell():New(oSection1, "cGWNNRROM"  , aGWNNRROM[5] , STR0065 , aGWNNRROM[4] ,aGWNNRROM[2] ,.T.,{||cGWNNRROM})  // Número Romaneio
	TRCell():New(oSection1, "cGWNSIT"    , aGWNSIT[5]   , STR0066 , aGWNSIT[4]   ,aGWNSIT[2]   ,.T.,{||cGWNSIT})    // Situação Romaneio
	TRCell():New(oSection1, "cGWNCDTPVC" , aGWNCDTPVC[5], STR0067 , aGWNCDTPVC[4],aGWNCDTPVC[2],.T.,{||cGWNCDTPVC}) // Tipo de Veículo
	TRCell():New(oSection1, "cGWNCDCLFR" , aGWNCDCLFR[5], STR0068 , aGWNCDCLFR[4],aGWNCDCLFR[2],.T.,{||cGWNCDCLFR}) // Classificação de Frete Romaneio
	TRCell():New(oSection1, "cGWNCDTPOP" , aGWNCDTPOP[5], STR0069 , aGWNCDTPOP[4],aGWNCDTPOP[2],.T.,{||cGWNCDTPOP}) // Tipo de Operação
	TRCell():New(oSection1, "cGWNCALC"   , aGWNCALC[5]  , STR0070 , aGWNCALC[4]  ,aGWNCALC[2]  ,.T.,{||cGWNCALC})   // Situação Cálculo
	TRCell():New(oSection1, "cGWNMTCALC" , aGWNMTCALC[5], STR0071 , aGWNMTCALC[4],aGWNMTCALC[2],.T.,{||cGWNMTCALC}) // Motivo Cálculo
	TRCell():New(oSection1, "cGWNVPVAL"  , aGWNVPVAL[5] , STR0072 , aGWNVPVAL[4] ,aGWNVPVAL[2] ,.T.,{||cGWNVPVAL})  // Valor Pedágio
	TRCell():New(oSection1, "cGWUDTPENT" , aGWUDTPENT[5], STR0073 , aGWUDTPENT[4],aGWUDTPENT[2],.T.,{||cGWUDTPENT}) // Data Prevista Entrega
	TRCell():New(oSection1, "cGWUHRPENT" , aGWUHRPENT[5], STR0074 , aGWUHRPENT[4],aGWUHRPENT[2],.T.,{||cGWUHRPENT}) // Hora Prevista Entrega
	TRCell():New(oSection1, "cGWUDTENT"  , aGWUDTENT[5] , STR0075 , aGWUDTENT[4] ,aGWUDTENT[2] ,.T.,{||cGWUDTENT})  // Data Entrega
	TRCell():New(oSection1, "cGWUHRENT"  , aGWUHRENT[5] , STR0076 , aGWUHRENT[4] ,aGWUHRENT[2] ,.T.,{||cGWUHRENT})  // Hora Entrega
	TRCell():New(oSection1, "cGWFNRCALC" , aGWFNRCALC[5], STR0077 , aGWFNRCALC[4],aGWFNRCALC[2],.T.,{||cGWFNRCALC}) // Número Cálculo
	TRCell():New(oSection1, "cGWFTPFRET" , aGWFTPFRET[5], STR0078 , aGWFTPFRET[4],aGWFTPFRET[2],.T.,{||cGWFTPFRET}) // Tipo de Frete do Cálculo
	TRCell():New(oSection1, "cVLFRET"    , aVLFRET[5]   , STR0079 , aVLFRET[4]   ,aVLFRET[2]   ,.T.,{||cVLFRET})    // Valor Frete
	TRCell():New(oSection1, "cVLICMS"    , aVLICMS[5]   , STR0080 , aVLICMS[4]   ,aVLICMS[2]   ,.T.,{||cVLICMS})    // Valor ICMS
	TRCell():New(oSection1, "cVLPIS"     , aVLPIS[5]    , STR0081 , aVLPIS[4]    ,aVLPIS[2]    ,.T.,{||cVLPIS})     // Valor PIS
	TRCell():New(oSection1, "cVLCOFI"    , aVLCOFI[5]   , STR0082 , aVLCOFI[4]   ,aVLCOFI[2]   ,.T.,{||cVLCOFI})    // Valor COFINS
	TRCell():New(oSection1, "cGWFTPTRIB" , aGWFTPTRIB[5], STR0083 , aGWFTPTRIB[4],aGWFTPTRIB[2],.T.,{||cGWFTPTRIB}) // Tipo de Tributação
	TRCell():New(oSection1, "cGWFCRDICM" , aGWFCRDICM[5], STR0084 , aGWFCRDICM[4],aGWFCRDICM[2],.T.,{||cGWFCRDICM}) // Gera Crédito ICMS
	TRCell():New(oSection1, "cGWFCRDPC"  , aGWFCRDPC[5] , STR0085 , aGWFCRDPC[4] ,aGWFCRDPC[2] ,.T.,{||cGWFCRDPC})  // Gera Crédito PIS/COFINS
	TRCell():New(oSection1, "cGWGNRTAB"  , aGWGNRTAB[5] , STR0086 , aGWGNRTAB[4] ,aGWGNRTAB[2] ,.T.,{||cGWGNRTAB})  // Número Tabela de Frete
	TRCell():New(oSection1, "cGWGNRNEG"  , aGWGNRNEG[5] , STR0087 , aGWGNRNEG[4] ,aGWGNRNEG[2] ,.T.,{||cGWGNRNEG})  // Negociação
	TRCell():New(oSection1, "cGWGCDFXTV" , aGWGCDFXTV[5], STR0088 , aGWGCDFXTV[4],aGWGCDFXTV[2],.T.,{||cGWGCDFXTV}) // Faixa
	TRCell():New(oSection1, "cGWGCDTPOP" , aGWGCDTPOP[5], STR0089 , aGWGCDTPOP[4],aGWGCDTPOP[2],.T.,{||cGWGCDTPOP}) // Tipo de Operação
	TRCell():New(oSection1, "cGWGCDTPVC" , aGWGCDTPVC[5], STR0090 , aGWGCDTPVC[4],aGWGCDTPVC[2],.T.,{||cGWGCDTPVC}) // Tipo de Veículo
	TRCell():New(oSection1, "cGWGCDCLFR" , aGWGCDCLFR[5], STR0091 , aGWGCDCLFR[4],aGWGCDCLFR[2],.T.,{||cGWGCDCLFR}) // Class. Frete da Tab. de Frete
	TRCell():New(oSection1, "cGV9UNIFAI" , aGV9UNIFAI[5], STR0092 , aGV9UNIFAI[4],aGV9UNIFAI[2],.T.,{||cGV9UNIFAI}) // Unid. Faixa
	TRCell():New(oSection1, "cGWGNRROTA" , aGWGNRROTA[5], STR0093 , aGWGNRROTA[4],aGWGNRROTA[2],.T.,{||cGWGNRROTA}) // Rota
	TRCell():New(oSection1, "cDESCROTA"  , aDESCROTA[5] , STR0094 , aDESCROTA[4] ,aDESCROTA[2] ,.T.,{||cDESCROTA})  // Descrição da Rota

	oFieldHide := TRCell():New(oSection1, "cGWJNRPF"  , aGWJNRPF[5]  , STR0095 , aGWJNRPF[4]  ,aGWJNRPF[2]  ,.T.,{||cGWJNRPF})   // Número Pré-Fatura
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "cGWJDTIMPL", aGWJDTIMPL[5], STR0096 , aGWJDTIMPL[4],aGWJDTIMPL[2],.T.,{||cGWJDTIMPL}) // Data de Implantação Pré-Fatura
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "cGWJSIT"   , aGWJSIT[5]   , STR0097 , aGWJSIT[4]   ,aGWJSIT[2]   ,.T.,{||cGWJSIT})    // Situação Pré-Fatura
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "cGWJSITFIN", aGWJSITFIN[5], STR0098 , aGWJSITFIN[4],aGWJSITFIN[2],.T.,{||cGWJSITFIN}) // Situação Pré-Fatura Financeiro
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "cCODLOTE"  , aCODLOTE[5]  , STR0099 , aCODLOTE[4]  ,aCODLOTE[2]  ,.T.,{||cCODLOTE})   // Código Lote
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "cGXFVALOR" , aGXFVALOR[5] , STR0100 , aGXFVALOR[4] ,aGXFVALOR[2] ,.T.,{||cGXFVALOR})  // Valor Lote
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "cPERLOTE"  , aPERLOTE[5]  , STR0101 , aPERLOTE[4]  ,aPERLOTE[2]  ,.T.,{||cPERLOTE})   // Período Lote
	oFieldHide:lUserEnabled := .F.

	oFieldHide := TRCell():New(oSection1, "cSITLOTE"  , aSITLOTE[5]  , STR0102 , aSITLOTE[4]  ,aSITLOTE[2]  ,.T.,{||cSITLOTE})   // Situação Lote
	oFieldHide:lUserEnabled := .F.

	If GFXTB12117("GXT")
		TRCell():New(oSection1, "cGXTNRCT" , aGXTNRCT[5], STR0103 , aGXTNRCT[4]  ,aGXTNRCT[2]  ,.T.,{||cGXTNRCT}) // Número Contrato Transp
	EndIf
	
	TRCell():New(oSection1, "cGW3CDESP"  , aGW3CDESP[5] , STR0104 , aGW3CDESP[4] ,aGW3CDESP[2] ,.T.,{||cGW3CDESP})  // Espécie Doc. Frete
	TRCell():New(oSection1, "cGW3NRDF"   , aGW3NRDF[5]  , STR0105 , aGW3NRDF[4]  ,aGW3NRDF[2]  ,.T.,{||cGW3NRDF})   // Número Doc. Frete
	TRCell():New(oSection1, "cGW3SERDF"  , aGW3SERDF[5] , STR0106 , aGW3SERDF[4] ,aGW3SERDF[2] ,.T.,{||cGW3SERDF})  // Série Doc. Frete
	TRCell():New(oSection1, "cGW3TPDF"   , aGW3TPDF[5]  , STR0107 , aGW3TPDF[4]  ,aGW3TPDF[2]  ,.T.,{||cGW3TPDF})   // Tipo Doc. Frete
	TRCell():New(oSection1, "cGW3DTENT"  , aGW3DTENT[5] , STR0108 , aGW3DTENT[4] ,aGW3DTENT[2] ,.T.,{||cGW3DTENT})  // Data de Entrada Doc. Frete
	TRCell():New(oSection1, "cGW3DTEMIS" , aGW3DTEMIS[5], STR0109 , aGW3DTEMIS[4],aGW3DTEMIS[2],.T.,{||cGW3DTEMIS}) // Data de Emissão Doc. Frete
	TRCell():New(oSection1, "cVLFRETDF"  , aVLFRETDF[5] , STR0110 , aVLFRETDF[4] ,aVLFRETDF[2] ,.T.,{||cVLFRETDF})  // Valor Doc. Frete
	TRCell():New(oSection1, "cVLICMSDF"  , aVLICMSDF[5] , STR0111 , aVLICMSDF[4] ,aVLICMSDF[2] ,.T.,{||cVLICMSDF})  // Valor ICMS Doc. Frete
	TRCell():New(oSection1, "cVLPISDF"   , aVLPISDF[5]  , STR0112 , aVLPISDF[4]  ,aVLPISDF[2]  ,.T.,{||cVLPISDF})   // Valor PIS Doc. Frete
	TRCell():New(oSection1, "cVLCOFIDF"  , aVLCOFIDF[5] , STR0113 , aVLCOFIDF[4] ,aVLCOFIDF[2] ,.T.,{||cVLCOFIDF})  // Valor COFINS Doc. Frete
	TRCell():New(oSection1, "cGW3SIT"    , aGW3SIT[5]   , STR0114 , aGW3SIT[4]   ,aGW3SIT[2]   ,.T.,{||cGW3SIT})    // Situação Documento de Frete
	TRCell():New(oSection1, "cGXGEDISIT" , aGXGEDISIT[5], STR0115 , aGXGEDISIT[4],aGXGEDISIT[2],.T.,{||cGXGEDISIT}) // Situação EDI
	TRCell():New(oSection1, "cGW3MOTBLQ" , aGW3MOTBLQ[5], STR0116 , aGW3MOTBLQ[4],aGW3MOTBLQ[2],.T.,{||cGW3MOTBLQ}) // Motivo Divergência Conferência
	TRCell():New(oSection1, "cGW3SITFIS" , aGW3SITFIS[5], STR0117 , aGW3SITFIS[4],aGW3SITFIS[2],.T.,{||cGW3SITFIS}) // Situação Integração Fiscal
	TRCell():New(oSection1, "cGW3DTFIS"  , aGW3DTFIS[5] , STR0118 , aGW3DTFIS[4] ,aGW3DTFIS[2] ,.T.,{||cGW3DTFIS})  // Data Integração Fiscal
	TRCell():New(oSection1, "cGW3SITREC" , aGW3SITREC[5], STR0119 , aGW3SITREC[4],aGW3SITREC[2],.T.,{||cGW3SITREC}) // Situação Integração Recebedoria
	TRCell():New(oSection1, "cGW3DTREC"  , aGW3DTREC[5] , STR0120 , aGW3DTREC[4] ,aGW3DTREC[2] ,.T.,{||cGW3DTREC})  // Data Integração Recebedoria
	TRCell():New(oSection1, "cGW3SITCUS" , aGW3SITCUS[5], STR0121 , aGW3SITCUS[4],aGW3SITCUS[2],.T.,{||cGW3SITCUS}) // Situação Integ. Custo de Frete
	TRCell():New(oSection1, "cGW3DTCUS"  , aGW3DTCUS[5] , STR0122 , aGW3DTCUS[4] ,aGW3DTCUS[2] ,.T.,{||cGW3DTCUS})  // Data Integ. Custo de Frete
	TRCell():New(oSection1, "cGW3SITMLA" , aGW3SITMLA[5], STR0123 , aGW3SITMLA[4],aGW3SITMLA[2],.T.,{||cGW3SITMLA}) // Situação Integração MLA
	TRCell():New(oSection1, "cGW6NRFAT"  , aGW6NRFAT[5] , STR0124 , aGW6NRFAT[4] ,aGW6NRFAT[2] ,.T.,{||cGW6NRFAT})  // Número Fatura
	TRCell():New(oSection1, "cGW6DTEMIS" , aGW6DTEMIS[5], STR0125 , aGW6DTEMIS[4],aGW6DTEMIS[2],.T.,{||cGW6DTEMIS}) // Data Emissão Fatura
	TRCell():New(oSection1, "cGW6VLFATU" , aGW6VLFATU[5], STR0126 , aGW6VLFATU[4],aGW6VLFATU[2],.T.,{||cGW6VLFATU}) // Valor Fatura
	TRCell():New(oSection1, "cGW6SITAPR" , aGW6SITAPR[5], STR0127 , aGW6SITAPR[4],aGW6SITAPR[2],.T.,{||cGW6SITAPR}) // Situação Fatura
	TRCell():New(oSection1, "cGW6DTFIN"  , aGW6DTFIN[5] , STR0128 , aGW6DTFIN[4] ,aGW6DTFIN[2] ,.T.,{||cGW6DTFIN})  // Data Integração Fatura
	TRCell():New(oSection1, "cGW6SITFIN" , aGW6SITFIN[5], STR0129 , aGW6SITFIN[4],aGW6SITFIN[2],.T.,{||cGW6SITFIN}) // Situação Integração Fatura
Return oReport
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint(oReport as object)
Função de impressão do relatório. Dentro dela que é chamada a função de carga do alias da Query.
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport as object)
	oSection := oReport:Section(1)
	oSection:Init()
	LoadTable()
	oSection:Finish()
Return Nil

Static Function GFER002Line()
	Local cLinha := ""
	If _cMvPar06 == 1
		oSection:PrintLine()
		oReport:IncMeter()
	Else
		cLinha := cGW1FILIAL+";"
		cLinha += cGW1NMFIL+";"
		cLinha += cGW1CDTPDC+";"
		cLinha += cGW1EMISDC+";"
		cLinha += cCNPJEMIS+";"
		cLinha += cNMEMIS+";"
		cLinha += cGW1SERDC+";"
		cLinha += cGW1NRDC+";"
		cLinha += cGW1DANFE+";"
		cLinha += DtoC(cGW1DTEMIS)+";"
		cLinha += DtoC(cGW1DTIMPL)+";"
		cLinha += DtoC(cGW1DTSAI)+";"
		cLinha += cGW1USO+";"
		cLinha += cGW1REGCOM+";"
		cLinha += cGW8ITEM+";"
		cLinha += cGW8DSITEM+";"
		cLinha += cValToChar(cGW8QTDE)+";"
		cLinha += cValToChar(cGW8VALOR)+";"
		cLinha += cValToChar(cGW8VOLUME)+";"
		cLinha += cValToChar(cGW8PESOC)+";"
		cLinha += cValToChar(cGW8PESOR)+";"
		cLinha += cValToChar(cGW8QTDALT)+";"
		cLinha += cGUBDSCLFR+";"
		cLinha += cGW8CFOP+";"
		cLinha += cGW8INFO1+";"
		cLinha += cGW8INFO2+";"
		cLinha += cGW8INFO3+";"
		cLinha += cGW8INFO4+";"
		cLinha += cGW8INFO5+";"
		cLinha += cGW1CDREM+";"
		cLinha += cCNPJREM+";"
		cLinha += cNMREM+";"
		cLinha += cGW1CDDEST+";"
		cLinha += cCNPJDEST+";"
		cLinha += cNMDEST+";"
		cLinha += cGW1SIT+";"
		cLinha += cGW0MSG+";"
		cLinha += cGW1CALCAT+";"
		cLinha += cGW1ROMTV+";"
		cLinha += cGW1ROMCF+";"
		cLinha += cGW1ROMTO+";"
		cLinha += cGU3NRCID+";"
		cLinha += cGWUNRCIDO+";"
		cLinha += cNMCIDO+";"
		cLinha += cUFO+";"
		cLinha += cGWUNRCIDD+";"
		cLinha += cNMCIDD+";"
		cLinha += cUFD+";"
		cLinha += cNMREGP+";"
		cLinha += cNMREGD+";"
		cLinha += cGWUSEQ+";"
		cLinha += cGWUPAGAR+";"
		cLinha += cGWUCDTRP+";"
		cLinha += cCNPJTRP+";"
		cLinha += cNMTRP+";"
		cLinha += cAUTON+";"
		cLinha += cMODAL+";"
		cLinha += cTPTRIB+";"
		cLinha += cGWNNRROM+";"
		cLinha += cGWNSIT+";"
		cLinha += cGWNCDTPVC+";"
		cLinha += cGWNCDCLFR+";"
		cLinha += cGWNCDTPOP+";"
		cLinha += cGWNCALC+";"
		cLinha += cGWNMTCALC+";"
		cLinha += cValToChar(cGWNVPVAL)+";"
		cLinha += DtoC(cGWUDTPENT)+";"
		cLinha += cGWUHRPENT+";"
		cLinha += DtoC(cGWUDTENT)+";"
		cLinha += cGWUHRENT+";"
		cLinha += cGWFNRCALC+";"
		cLinha += cGWFTPFRET+";"
		cLinha += cValToChar(cVLFRET)+";"
		cLinha += cValToChar(cVLICMS)+";"
		cLinha += cValToChar(cVLPIS)+";"
		cLinha += cValToChar(cVLCOFI)+";"
		cLinha += cGWFTPTRIB+";"
		cLinha += cGWFCRDICM+";"
		cLinha += cGWFCRDPC+";"
		cLinha += cGWGNRTAB+";"
		cLinha += cGWGNRNEG+";"
		cLinha += cGWGCDFXTV+";"
		cLinha += cGWGCDTPOP+";"
		cLinha += cGWGCDTPVC+";"
		cLinha += cGWGCDCLFR+";"
		cLinha += cGV9UNIFAI+";"
		cLinha += cGWGNRROTA+";"
		cLinha += cDESCROTA+";"
		cLinha += cGWJNRPF+";"
		cLinha += DtoC(cGWJDTIMPL)+";"
		cLinha += cGWJSIT+";"
		cLinha += cGWJSITFIN+";"
		cLinha += cCODLOTE+";"
		cLinha += cValToChar(cGXFVALOR)+";"
		cLinha += cPERLOTE+";"
		cLinha += cSITLOTE+";"
		cLinha += cGXTNRCT+";"
		cLinha += cGW3CDESP+";"
		cLinha += cGW3NRDF+";"
		cLinha += cGW3SERDF+";"
		cLinha += cGW3TPDF+";"
		cLinha += DtoC(cGW3DTENT)+";"
		cLinha += DtoC(cGW3DTEMIS)+";"
		cLinha += cValToChar(cVLFRETDF)+";"
		cLinha += cValToChar(cVLICMSDF)+";"
		cLinha += cValToChar(cVLPISDF)+";"
		cLinha += cValToChar(cVLCOFIDF)+";"
		cLinha += cGW3SIT+";"
		cLinha += cGXGEDISIT+";"
		cLinha += cGW3MOTBLQ+";"
		cLinha += cGW3SITFIS+";"
		cLinha += DtoC(cGW3DTFIS)+";"
		cLinha += cGW3SITREC+";"
		cLinha += DtoC(cGW3DTREC)+";"
		cLinha += cGW3SITCUS+";"
		cLinha += DtoC(cGW3DTCUS)+";"
		cLinha += cGW3SITMLA+";"
		cLinha += cGW6NRFAT+";"
		cLinha += DtoC(cGW6DTEMIS)+";"
		cLinha += cValToChar(cGW6VLFATU)+";"
		cLinha += cGW6SITAPR+";"
		cLinha += DtoC(cGW6DTFIN)+";"
		cLinha += cGW6SITFIN

		FWrite(nHandle, cLinha + CRLF)
	EndIf
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} LoadTable()
Query que carrega a tabela temporária
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadTable()
	Local cDtDe      := ""
	Local cDtAte     := ""
	Local cDtEmisDe  := ""
	Local cDtEmisAte := ""
	Local cCampos    := ""
	Local cWhere     := ""
	Local cJoinGWN   := ""
	Local cAliasQry  := Nil
	Local cAliasGW0  := Nil
	Local cAliasGXZ  := Nil
	Local cAliasGXY  := Nil
	Local cChave     := ""
	//Tipo de Rateio configurado no sistema
	Local cTpRat     := SuperGetMV('MV_CRIRAT', .F., '1')
	Local cTpReg     := SuperGetMV('MV_TIPREG', .F., '1')
	
	cDtDe       := _cMvPar01
	cDtAte      := _cMvPar02
	cDtEmisDe   := _cMvPar03
	cDtEmisAte  := _cMvPar04

	If _cMvPar05 == 1 .Or. _cMvPar05 == 2
		cCampos := ""
		Do Case
			Case cTpRat == "1"
				cCampos += " SUM(GWM.GWM_VLFRET) AS VLFRET,"
				cCampos += " SUM(GWM.GWM_VLICMS) AS VLICMS,"
				cCampos += " SUM(GWM.GWM_VLPIS)  AS VLPIS,"
				cCampos += " SUM(GWM.GWM_VLCOFI) AS VLCOFI,"
				cCampos += " SUM(GWMDF.GWM_VLFRET) AS VLFRETDF,"
				cCampos += " SUM(GWMDF.GWM_VLICMS) AS VLICMSDF,"
				cCampos += " SUM(GWMDF.GWM_VLPIS)  AS VLPISDF ,"
				cCampos += " SUM(GWMDF.GWM_VLCOFI) AS VLCOFIDF,"
			Case cTpRat == "2"
				cCampos += " SUM(GWM.GWM_VLFRE1) AS VLFRET,"
				cCampos += " SUM(GWM.GWM_VLICM1) AS VLICMS,"
				cCampos += " SUM(GWM.GWM_VLPIS1) AS VLPIS,"
				cCampos += " SUM(GWM.GWM_VLCOF1) AS VLCOFI,"
				cCampos += " SUM(GWMDF.GWM_VLFRE1) AS VLFRETDF,"
				cCampos += " SUM(GWMDF.GWM_VLICM1) AS VLICMSDF,"
				cCampos += " SUM(GWMDF.GWM_VLPIS1) AS VLPISDF ,"
				cCampos += " SUM(GWMDF.GWM_VLCOF1) AS VLCOFIDF,"
			Case cTpRat == "3"
				cCampos += " SUM(GWM.GWM_VLFRE3) AS VLFRET,"
				cCampos += " SUM(GWM.GWM_VLICM3) AS VLICMS,"
				cCampos += " SUM(GWM.GWM_VLPIS3) AS VLPIS,"
				cCampos += " SUM(GWM.GWM_VLCOF3) AS VLCOFI,"
				cCampos += " SUM(GWMDF.GWM_VLFRE3) AS VLFRETDF,"
				cCampos += " SUM(GWMDF.GWM_VLICM3) AS VLICMSDF,"
				cCampos += " SUM(GWMDF.GWM_VLPIS3) AS VLPISDF,"
				cCampos += " SUM(GWMDF.GWM_VLCOF3) AS VLCOFIDF,"
			Case cTpRat == "4"
				cCampos += " SUM(GWM.GWM_VLFRE2) AS VLFRET,"
				cCampos += " SUM(GWM.GWM_VLICM2) AS VLICMS,"
				cCampos += " SUM(GWM.GWM_VLPIS2) AS VLPIS,"
				cCampos += " SUM(GWM.GWM_VLCOF2) AS VLCOFI,"
				cCampos += " SUM(GWMDF.GWM_VLFRE2) AS VLFRETDF,"
				cCampos += " SUM(GWMDF.GWM_VLICM2) AS VLICMSDF,"
				cCampos += " SUM(GWMDF.GWM_VLPIS2) AS VLPISDF,"
				cCampos += " SUM(GWMDF.GWM_VLCOF2) AS VLCOFIDF,"
			Otherwise
				cCampos += " SUM(GWM.GWM_VLFRET) AS VLFRET,"
				cCampos += " SUM(GWM.GWM_VLICMS) AS VLICMS,"
				cCampos += " SUM(GWM.GWM_VLPIS)  AS VLPIS,"
				cCampos += " SUM(GWM.GWM_VLCOFI) AS VLCOFI,"
				cCampos += " SUM(GWMDF.GWM_VLFRET) AS VLFRETDF,"
				cCampos += " SUM(GWMDF.GWM_VLICMS) AS VLICMSDF,"
				cCampos += " SUM(GWMDF.GWM_VLPIS)  AS VLPISDF,"
				cCampos += " SUM(GWMDF.GWM_VLCOFI) AS VLCOFIDF,"
		EndCase
		cCampos := "%" + cCampos + "%"
		cWhere := ""
		If !Empty(cDtAte) .And. cDtAte >= cDtDe
			cWhere += " AND GW1.GW1_DTIMPL >= '"+cDtDe+"' AND GW1.GW1_DTIMPL <= '"+cDtAte+"'"
		EndIf
		If !Empty(cDtEmisAte) .And. cDtEmisAte >= cDtEmisDe
			cWhere += " AND GW1.GW1_DTEMIS >= '"+cDtEmisDe+"' AND GW1.GW1_DTEMIS <= '"+cDtEmisAte+"'"
		EndIf
		cWhere := "%" + cWhere + "%"

		If GFXCP1212210('GW1_FILROM')
			cJoinGWN := "GW1.GW1_FILROM"
		Else
			cJoinGWN := "GW1.GW1_FILIAL"
		EndIf
		cJoinGWN := "%" + cJoinGWN + "%"

		cAliasQry := GetNextAlias()
		BeginSQL Alias cAliasQry
			SELECT GW1.GW1_FILIAL,
					GW1.GW1_CDTPDC,
					GW1.GW1_EMISDC,
					GW1.GW1_SERDC,
					GW1.GW1_NRDC,
					GW1.GW1_TPFRET,
					GU3EMIS.GU3_NMEMIT AS NMEMIS,
					GU3EMIS.GU3_IDFED AS CNPJEMIS,
					GU3EMIS.GU3_NRCID AS GU3NRCID,
					GW1.GW1_DANFE, 
					GW1.GW1_DTEMIS, 
					GW1.GW1_DTIMPL,
					GW1.GW1_DTSAI,
					GW1.GW1_USO,
					GW1.GW1_REPRES,
					GW1.GW1_REGCOM,
					GW8.GW8_ITEM,
					GW8.GW8_DSITEM,
					GW8.GW8_QTDE,
					GW8.GW8_VALOR,
					GW8.GW8_VOLUME,
					GW8.GW8_PESOC,
					GW8.GW8_PESOR,
					GW8.GW8_QTDALT,
					GUB.GUB_DSCLFR,
					GW8.GW8_CFOP,
					GW8.GW8_INFO1,
					GW8.GW8_INFO2,
					GW8.GW8_INFO3,
					GW8.GW8_INFO4,
					GW8.GW8_INFO5,
					GW1.GW1_CDREM,
					GU3REM.GU3_NMEMIT AS NMREM,
					GU3REM.GU3_IDFED AS CNPJREM,
					GW1.GW1_CDDEST,
					GU3DES.GU3_NMEMIT AS NMDEST,
					GU3DES.GU3_IDFED AS CNPJDEST,
					GW1.GW1_SIT,
					GW1.GW1_CALCAT,
					GW1.GW1_ROMTV,
					GW1.GW1_ROMCF,
					GW1.GW1_ROMTO,
					GWU.GWU_NRCIDO,
					GU7ORI.GU7_NMCID AS NMCIDO,
					GU7ORI.GU7_CDUF AS UFO,
					GWU.GWU_NRCIDD,
					GU7DST.GU7_NMCID AS NMCIDD,
					GU7DST.GU7_CDUF AS UFD,
					GWU.GWU_SEQ,
					GWU.GWU_PAGAR,
					GWU.GWU_CDTRP,
					GU3TRP.GU3_IDFED AS CNPJTRP,
					GU3TRP.GU3_NMEMIT AS NMTRP,
					GU3TRP.GU3_AUTON AS AUTON,
					GU3TRP.GU3_MODAL AS MODAL,
					GU3TRP.GU3_TPTRIB AS TPTRIB,
					GWN.GWN_NRROM,
					GWN.GWN_SIT,
					GWN.GWN_CDTPVC,
					GWN.GWN_CDCLFR,
					GWN.GWN_CDTPOP,
					GWN.GWN_CALC,
					GWN.GWN_VPVAL,
					GWU.GWU_DTPENT,
					GWU.GWU_HRPENT,
					GWU.GWU_DTENT,
					GWU.GWU_HRENT,
					GWF.GWF_NRCALC,
					GWF.GWF_TPFRET,
					GWF.GWF_TPCALC,
					%Exp:cCampos%
					GWF.GWF_TPTRIB,
					GWF.GWF_CRDICM,
					GWF.GWF_CRDPC,
					GWG.GWG_NRTAB,
					GWG.GWG_NRNEG,
					GWG.GWG_CDFXTV,
					GWG.GWG_NRROTA,
					GWG.GWG_CDTPOP,
					GWG.GWG_CDTPVC,
					GWG.GWG_CDCLFR,
					GWJ.GWJ_NRPF,
					GWJ.GWJ_DTIMPL,
					GWJ.GWJ_SIT,
					GWJ.GWJ_SITFIN,
					GXE.GXE_CODLOT AS CODLOTE,
					SUM(GXF.GXF_VALOR) AS GXF_VALOR,
					GXE.GXE_PERIOD AS PERLOTE,
					GXE.GXE_SIT AS SITLOTE,
					GWF.GWF_NRDF,
					GWF.GWF_CDESP,
					GWF.GWF_EMISDF,
					GWF.GWF_SERDF,
					GV8.GV8_NRREDS,
					GW1.GW1_NRREG,
					GU9A.GU9_NMREG AS NMNRREDS,
					GU9B.GU9_NMREG AS NMNRREG,
					GW3.GW3_FILIAL,
					GW3.GW3_CDESP,
					GW3.GW3_NRDF,
					GW3.GW3_SERDF,
					GW3.GW3_EMISDF,
					GW3.GW3_TPDF,
					GW3.GW3_DTENT,
					GW3.GW3_DTEMIS,
					GW3.GW3_SIT,
					GW3.GW3_SITFIS,
					GW3.GW3_DTFIS,
					GW3.GW3_SITREC,
					GW3.GW3_DTREC,
					GW3.GW3_SITCUS,
					GW3.GW3_DTCUS,
					GW3.GW3_SITMLA,
					GW6.GW6_NRFAT,
					GW6.GW6_DTEMIS,
					GW6.GW6_VLFATU,
					GW6.GW6_SITAPR,
					GW6.GW6_DTFIN,
					GW6.GW6_SITFIN,
					GV9.GV9_UNIFAI
			FROM %Table:GW1% GW1

			INNER JOIN %Table:GW8% GW8
			ON GW8.GW8_FILIAL = GW1.GW1_FILIAL
			AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC
			AND GW8.GW8_EMISDC = GW1.GW1_EMISDC
			AND GW8.GW8_SERDC = GW1.GW1_SERDC
			AND GW8.GW8_NRDC = GW1.GW1_NRDC
			AND GW8.%NotDel%

			INNER JOIN %Table:GWU% GWU
			ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
			AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
			AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
			AND GWU.GWU_SERDC = GW1.GW1_SERDC
			AND GWU.GWU_NRDC = GW1.GW1_NRDC
			AND GWU.%NotDel%

			INNER JOIN %Table:GUB% GUB
			ON GUB.GUB_FILIAL = %xFilial:GUB%
			AND GUB.GUB_CDCLFR = GW8.GW8_CDCLFR
			AND GUB.%NotDel%

			INNER JOIN %Table:GU3% GU3EMIS
			ON GU3EMIS.GU3_FILIAL = %xFilial:GU3%
			AND GU3EMIS.GU3_CDEMIT = GW1.GW1_EMISDC
			AND GU3EMIS.%NotDel%

			INNER JOIN %Table:GU3% GU3REM
			ON GU3REM.GU3_FILIAL = %xFilial:GU3%
			AND GU3REM.GU3_CDEMIT = GW1.GW1_CDREM
			AND GU3REM.%NotDel%

			INNER JOIN %Table:GU3% GU3DES
			ON GU3DES.GU3_FILIAL = %xFilial:GU3%
			AND GU3DES.GU3_CDEMIT = GW1.GW1_CDDEST
			AND GU3DES.%NotDel%

			LEFT JOIN %Table:GU3% GU3TRP
			ON GU3TRP.GU3_FILIAL = %xFilial:GU3%
			AND GU3TRP.GU3_CDEMIT = GWU.GWU_CDTRP
			AND GU3TRP.%NotDel%

			LEFT JOIN %Table:GWH% GWH
			ON GWH.GWH_FILIAL = GW1.GW1_FILIAL
			AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC
			AND GWH.GWH_EMISDC = GW1.GW1_EMISDC
			AND GWH.GWH_SERDC = GW1.GW1_SERDC
			AND GWH.GWH_NRDC = GW1.GW1_NRDC
			AND GWH.GWH_TRECHO = GWU.GWU_SEQ
			AND GWH.%NotDel%

			LEFT JOIN %Table:GWF% GWF
			ON GWF.GWF_FILIAL = GWH.GWH_FILIAL
			AND GWF.GWF_NRCALC = GWH.GWH_NRCALC
			AND GWF.%NotDel%

			LEFT JOIN %Table:GWN% GWN
			ON GWN.GWN_FILIAL = %Exp:cJoinGWN%
			AND GWN.GWN_NRROM = GW1.GW1_NRROM
			AND GWN.%NotDel%

			LEFT JOIN %Table:GU7% GU7ORI
			ON GU7ORI.GU7_FILIAL = %xFilial:GU7%
			AND GU7ORI.GU7_NRCID = GWU.GWU_NRCIDO
			AND GU7ORI.%NotDel%

			LEFT JOIN %Table:GU7% GU7DST
			ON GU7DST.GU7_FILIAL = %xFilial:GU7%
			AND GU7DST.GU7_NRCID = GWU.GWU_NRCIDD
			AND GU7DST.%NotDel%

			LEFT JOIN %Table:GUB% GUBROM
			ON GUBROM.GUB_FILIAL = %xFilial:GUB%
			AND GUBROM.GUB_CDCLFR = GWN.GWN_CDCLFR
			AND GUBROM.%NotDel%

			LEFT JOIN %Table:GWG% GWG
			ON GWG.GWG_FILIAL = GWH.GWH_FILIAL
			AND GWG.GWG_NRCALC = GWH.GWH_NRCALC
			AND GWG.%NotDel%

			LEFT JOIN %Table:GV8% GV8
			ON GV8.GV8_FILIAL = %xFilial:GV8%
			AND GV8.GV8_CDEMIT = GWG.GWG_CDEMIT
			AND GV8.GV8_NRTAB = GWG.GWG_NRTAB
			AND GV8.GV8_NRNEG = GWG.GWG_NRNEG
			AND GV8.GV8_NRROTA = GWG.GWG_NRROTA
			AND GV8.GV8_TPDEST = '2'
			AND GV8.%NotDel%

			LEFT JOIN %Table:GU9% GU9A
			ON GU9A.GU9_FILIAL = %xFilial:GU9%
			AND GU9A.GU9_NRREG = GV8.GV8_NRREDS
			AND GU9A.%NotDel%

			LEFT JOIN %Table:GU9% GU9B
			ON GU9B.GU9_FILIAL = %xFilial:GU9%
			AND GU9B.GU9_NRREG = GW1.GW1_NRREG
			AND GU9B.%NotDel%

			LEFT JOIN %Table:GWJ% GWJ
			ON GWJ.GWJ_FILIAL = GWF.GWF_FILPRE
			AND GWJ.GWJ_NRPF = GWF.GWF_NRPREF
			AND GWJ.%NotDel%

			LEFT JOIN %Table:GXD% GXD
			ON GXD.GXD_FILCAL = GWF.GWF_FILIAL
			AND GXD.GXD_NRCALC = GWF.GWF_NRCALC
			AND GXD.%NotDel%

			LEFT JOIN %Table:GXE% GXE
			ON GXE.GXE_FILIAL = GXD.GXD_FILIAL
			AND GXE.GXE_CODLOT = GXD.GXD_CODLOT
			AND GXE.%NotDel%

			LEFT JOIN %Table:GXF% GXF
			ON GXF.GXF_FILIAL = GXE.GXE_FILIAL
			AND GXF.GXF_CODLOT = GXE.GXE_CODLOT
			AND GXF.%NotDel%

			LEFT JOIN %Table:GW4% GW4
			ON GW4.GW4_FILIAL = GW1.GW1_FILIAL
			AND GW4.GW4_TPDC = GW1.GW1_CDTPDC
			AND GW4.GW4_EMISDC = GW1.GW1_EMISDC
			AND GW4.GW4_SERDC = GW1.GW1_SERDC
			AND GW4.GW4_NRDC = GW1.GW1_NRDC
			AND GW4.GW4_EMISDF = GWU.GWU_CDTRP
			AND GW4.%NotDel%

			LEFT JOIN %Table:GW3% GW3
			ON GW3.GW3_FILIAL = GW4.GW4_FILIAL
			AND GW3.GW3_CDESP = GW4.GW4_CDESP
			AND GW3.GW3_EMISDF = GW4.GW4_EMISDF
			AND GW3.GW3_DTEMIS = GW4.GW4_DTEMIS
			AND GW3.GW3_NRDF = GW4.GW4_NRDF
			AND GW3.GW3_SERDF = GW4.GW4_SERDF
			AND GW3.%NotDel%

			LEFT JOIN %Table:GWM% GWM
			ON GWM.GWM_FILIAL = GWF.GWF_FILIAL
			AND GWM.GWM_CDTRP = GWF.GWF_TRANSP
			AND GWM.GWM_NRDOC = GWF.GWF_NRCALC
			AND GWM.GWM_DTEMIS = GWF.GWF_DTCRIA
			AND GWM.GWM_CDTPDC = GWH.GWH_CDTPDC
			AND GWM.GWM_EMISDC = GWH.GWH_EMISDC
			AND GWM.GWM_SERDC = GWH.GWH_SERDC
			AND GWM.GWM_NRDC = GWH.GWH_NRDC 
			AND GWM.GWM_SEQGW8 = GW8.GW8_SEQ
			AND GWM.GWM_DTEMDC = GW1.GW1_DTEMIS
			AND GWM.GWM_TPDOC = '1'
			AND GWM.%NotDel%

			LEFT JOIN %Table:GWM% GWMDF
			ON GWMDF.GWM_FILIAL = GW3.GW3_FILIAL 
			AND GWMDF.GWM_CDESP = GW3.GW3_CDESP 
			AND GWMDF.GWM_CDTRP = GW3.GW3_EMISDF 
			AND GWMDF.GWM_SERDOC = GW3.GW3_SERDF 
			AND GWMDF.GWM_NRDOC = GW3.GW3_NRDF
			AND GWMDF.GWM_DTEMIS = GW3.GW3_DTEMIS
			AND GWMDF.GWM_SEQGW8 = GW8.GW8_SEQ 
			AND GWMDF.GWM_TPDOC = '2' 
			AND GWMDF.D_E_L_E_T_ = ' '

			LEFT JOIN %Table:GW6% GW6
			ON GW6.GW6_FILIAL = GW3.GW3_FILFAT
			AND GW6.GW6_EMIFAT = GW3.GW3_EMIFAT
			AND GW6.GW6_SERFAT = GW3.GW3_SERFAT
			AND GW6.GW6_NRFAT = GW3.GW3_NRFAT
			AND GW6.GW6_DTEMIS = GW3.GW3_DTEMFA
			AND GW6.%NotDel%

			LEFT JOIN %Table:GV9% GV9
			ON GV9.GV9_FILIAL = %xFilial:GV9%
			AND GV9.GV9_CDEMIT = GWU.GWU_CDTRP
			AND GV9.GV9_NRTAB = GWG.GWG_NRTAB
			AND GV9.GV9_NRNEG = GWG.GWG_NRNEG
			AND GV9.%NotDel%
			WHERE GW1.%NotDel%
			%Exp:cWhere%

			GROUP BY GW1.GW1_FILIAL,
						GW1.GW1_TPFRET,
						GW1.GW1_CDTPDC,
						GW1.GW1_EMISDC,
						GU3EMIS.GU3_NMEMIT,
						GU3EMIS.GU3_IDFED,
						GU3EMIS.GU3_NRCID,
						GW1.GW1_SERDC,
						GW1.GW1_NRDC,
						GW1.GW1_DANFE,
						GW1.GW1_DTEMIS,
						GW1.GW1_DTIMPL,
						GW1.GW1_DTSAI,
						GW1.GW1_USO,
						GW1.GW1_REPRES,
						GW1.GW1_REGCOM,
						GW8.GW8_ITEM,
						GW8.GW8_DSITEM,
						GW8.GW8_QTDE,
						GW8.GW8_VALOR,
						GW8.GW8_VOLUME,
						GW8.GW8_PESOC,
						GW8.GW8_PESOR,
						GW8.GW8_QTDALT,
						GUB.GUB_DSCLFR,
						GW8.GW8_CFOP,
						GW8.GW8_INFO1,
						GW8.GW8_INFO2,
						GW8.GW8_INFO3,
						GW8.GW8_INFO4,
						GW8.GW8_INFO5,
						GW1.GW1_CDREM,
						GU3REM.GU3_NMEMIT,
						GU3REM.GU3_IDFED,
						GW1.GW1_CDDEST,
						GU3DES.GU3_NMEMIT,
						GU3DES.GU3_IDFED,
						GW1.GW1_SIT,
						GW1.GW1_CALCAT,
						GW1.GW1_ROMTV,
						GW1.GW1_ROMCF,
						GW1.GW1_ROMTO,
						GUBROM.GUB_DSCLFR,
						GWU.GWU_NRCIDO,
						GU7ORI.GU7_NMCID,
						GU7ORI.GU7_CDUF,
						GWU.GWU_NRCIDD,
						GU7DST.GU7_NMCID,
						GU7DST.GU7_CDUF,
						GWU.GWU_SEQ,
						GWU.GWU_PAGAR,
						GWU.GWU_CDTRP,
						GU3TRP.GU3_IDFED,
						GU3TRP.GU3_NMEMIT,
						GU3TRP.GU3_AUTON,
						GU3TRP.GU3_MODAL,
						GU3TRP.GU3_TPTRIB,
						GWN.GWN_NRROM,
						GWN.GWN_SIT,
						GWN.GWN_CDTPVC,
						GWN.GWN_CDCLFR,
						GWN.GWN_CDTPOP,
						GWN.GWN_CALC,
						GWN.GWN_VPVAL,
						GWU.GWU_DTPENT,
						GWU.GWU_HRPENT,
						GWU.GWU_DTENT,
						GWU.GWU_HRENT,
						GWF.GWF_NRCALC,
						GWF.GWF_TPFRET,
						GWF.GWF_TPCALC,
						GWF.GWF_TPTRIB,
						GWF.GWF_CRDICM,
						GWF.GWF_CRDPC,
						GWG.GWG_NRTAB,
						GWG.GWG_NRNEG,
						GWG.GWG_CDFXTV,
						GWG.GWG_NRROTA,
						GWG.GWG_CDTPOP,
						GWG.GWG_CDTPVC,
						GWG.GWG_CDCLFR,
						GWJ.GWJ_NRPF,
						GWJ.GWJ_DTIMPL,
						GWJ.GWJ_SIT,
						GWJ.GWJ_SITFIN,
						GXE.GXE_CODLOT,
						GXE.GXE_PERIOD,
						GXE.GXE_SIT,
						GWF.GWF_NRDF,
						GWF.GWF_CDESP,
						GWF.GWF_EMISDF,
						GWF.GWF_SERDF,
						GV8.GV8_NRREDS,
						GW1.GW1_NRREG,
						GU9A.GU9_NMREG,
						GU9B.GU9_NMREG,
						GW3.GW3_FILIAL,
						GW3.GW3_CDESP,
						GW3.GW3_NRDF,
						GW3.GW3_SERDF,
						GW3.GW3_EMISDF,
						GW3.GW3_TPDF,
						GW3.GW3_DTENT,
						GW3.GW3_DTEMIS,
						GW3.GW3_SIT,
						GW3.GW3_SITFIS,
						GW3.GW3_DTFIS,
						GW3.GW3_SITREC,
						GW3.GW3_DTREC,
						GW3.GW3_SITCUS,
						GW3.GW3_DTCUS,
						GW3.GW3_SITMLA,
						GW6.GW6_NRFAT,
						GW6.GW6_DTEMIS,
						GW6.GW6_VLFATU,
						GW6.GW6_SITAPR,
						GW6.GW6_DTFIN,
						GW6.GW6_SITFIN,
						GV9.GV9_UNIFAI
			ORDER BY GWN.GWN_NRROM,
						GW1.GW1_DTIMPL,
						GW1.GW1_NRDC,
						GWU.GWU_SEQ,
						GWF.GWF_NRCALC
		EndSQL
		TcSetField(cAliasQry,"GW1_DTEMIS","D",8,0)
		TcSetField(cAliasQry,"GW1_DTIMPL","D",8,0)
		TcSetField(cAliasQry,"GW1_DTSAI" ,"D",8,0)
		TcSetField(cAliasQry,"GWU_DTPENT","D",8,0)
		TcSetField(cAliasQry,"GWU_DTENT" ,"D",8,0)
		TcSetField(cAliasQry,"GWJ_DTIMPL","D",8,0)
		TcSetField(cAliasQry,"GW3_DTENT" ,"D",8,0)
		TcSetField(cAliasQry,"GW3_DTEMIS","D",8,0)
		TcSetField(cAliasQry,"GW3_DTFIS" ,"D",8,0)
		TcSetField(cAliasQry,"GW3_DTREC" ,"D",8,0)
		TcSetField(cAliasQry,"GW3_DTCUS" ,"D",8,0)
		TcSetField(cAliasQry,"GW6_DTEMIS","D",8,0)
		TcSetField(cAliasQry,"GW6_DTFIN" ,"D",8,0)

		Do While (cAliasQry)->(!Eof())
			// Inicializa as variáveis
			cGW1FILIAL := (cAliasQry)->GW1_FILIAL
			cGW1NMFIL  := FwFilName(cEmpAnt,cGW1FILIAL)
			cGW1CDTPDC := (cAliasQry)->GW1_CDTPDC
			cGW1EMISDC := (cAliasQry)->GW1_EMISDC
			cCNPJEMIS  := (cAliasQry)->CNPJEMIS
			cNMEMIS    := (cAliasQry)->NMEMIS
			cGW1SERDC  := (cAliasQry)->GW1_SERDC
			cGW1NRDC   := (cAliasQry)->GW1_NRDC
			cGW1DANFE  := (cAliasQry)->GW1_DANFE
			cGW1DTEMIS := (cAliasQry)->GW1_DTEMIS
			cGW1DTIMPL := (cAliasQry)->GW1_DTIMPL
			cGW1DTSAI  := (cAliasQry)->GW1_DTSAI
			cGW1USO    := RetUso((cAliasQry)->GW1_USO)
			cGW1REGCOM := (cAliasQry)->GW1_REGCOM
			cGW8ITEM   := (cAliasQry)->GW8_ITEM
			cGW8DSITEM := FWNoAccent((cAliasQry)->GW8_DSITEM)
			cGW8QTDE   := (cAliasQry)->GW8_QTDE
			cGW8VALOR  := (cAliasQry)->GW8_VALOR
			cGW8VOLUME := (cAliasQry)->GW8_VOLUME
			cGW8PESOC  := (cAliasQry)->GW8_PESOC
			cGW8PESOR  := (cAliasQry)->GW8_PESOR
			cGW8QTDALT := (cAliasQry)->GW8_QTDALT
			cGUBDSCLFR := (cAliasQry)->GUB_DSCLFR
			cGW8CFOP   := (cAliasQry)->GW8_CFOP
			cGW8INFO1  := (cAliasQry)->GW8_INFO1
			cGW8INFO2  := (cAliasQry)->GW8_INFO2
			cGW8INFO3  := (cAliasQry)->GW8_INFO3
			cGW8INFO4  := (cAliasQry)->GW8_INFO4
			cGW8INFO5  := (cAliasQry)->GW8_INFO5
			cGW1CDREM  := (cAliasQry)->GW1_CDREM
			cCNPJREM   := (cAliasQry)->CNPJREM
			cNMREM     := (cAliasQry)->NMREM
			cGW1CDDEST := (cAliasQry)->GW1_CDDEST
			cCNPJDEST  := (cAliasQry)->CNPJDEST
			cNMDEST    := (cAliasQry)->NMDEST
			cGW1SIT    := RetSitGW1((cAliasQry)->GW1_SIT)
			cGW0MSG     := ""
			If (cAliasQry)->GW1_SIT == "2" .and. _IntGFE
				cAliasGW0 := GetNextAlias()
				cChave := (cAliasQry)->GW1_FILIAL + (cAliasQry)->GW1_CDTPDC + (cAliasQry)->GW1_EMISDC + (cAliasQry)->GW1_SERDC  + (cAliasQry)->GW1_NRDC
				BeginSql Alias cAliasGW0
					SELECT GW0.GW0_CHAR01,
							GW0.GW0_CHAR02,
							GW0.GW0_CHAR03
					FROM %Table:GW0% GW0
					WHERE
					GW0.GW0_FILIAL = %Exp:(cAliasQry)->GW1_FILIAL%
					AND GW0.GW0_TABELA = 'GW1'
					AND GW0.GW0_CHAVE = %Exp:cChave%
					AND GW0.%NotDel%
				EndSql
				If (cAliasGW0)->(!Eof())
					cGW0MSG := FWNoAccent((cAliasGW0)->GW0_CHAR01 + (cAliasGW0)->GW0_CHAR02 + (cAliasGW0)->GW0_CHAR03)
				EndIf
				(cAliasGW0)->(dbCloseArea())
			EndIf
			cGW1CALCAT := RetCalcGW1((cAliasQry)->GW1_CALCAT)
			cGW1ROMTV  := (cAliasQry)->GW1_ROMTV
			cGW1ROMCF  := (cAliasQry)->GW1_ROMCF
			cGW1ROMTO  := (cAliasQry)->GW1_ROMTO
			cGU3NRCID  := (cAliasQry)->GU3NRCID
			cGWUNRCIDO := (cAliasQry)->GWU_NRCIDO
			cNMCIDO    := (cAliasQry)->NMCIDO
			cUFO       := (cAliasQry)->UFO
			cGWUNRCIDD := (cAliasQry)->GWU_NRCIDD
			cNMCIDD    := (cAliasQry)->NMCIDD
			cUFD       := (cAliasQry)->UFD
			cNMREGP    := IIf(cTpReg == '2',(cAliasQry)->NMNRREG,"")
			cNMREGD    := (cAliasQry)->NMNRREDS
			cGWUSEQ    := (cAliasQry)->GWU_SEQ
			cGWUPAGAR  := IIf((cAliasQry)->GWU_PAGAR == "1","Sim","Não")
			cGWUCDTRP  := (cAliasQry)->GWU_CDTRP
			cCNPJTRP   := (cAliasQry)->CNPJTRP
			cNMTRP     := (cAliasQry)->NMTRP
			cAUTON     := IIf((cAliasQry)->AUTON == "1", "Autônomo","Transportador")
			cMODAL     := RetTpMod((cAliasQry)->MODAL)
			cTPTRIB    := RetTpTrb((cAliasQry)->TPTRIB)
			cGWNNRROM  := (cAliasQry)->GWN_NRROM
			cGWNSIT    := RetSitRom((cAliasQry)->GWN_SIT)
			cGWNCDTPVC := (cAliasQry)->GWN_CDTPVC
			cGWNCDCLFR := (cAliasQry)->GWN_CDCLFR
			cGWNCDTPOP := (cAliasQry)->GWN_CDTPOP
			cGWNCALC   := RetCalcGWN((cAliasQry)->GWN_CALC)
			cGWNMTCALC := rTrim(MemoLine(FWNoAccent(Posicione("GWN", 1, (cAliasQry)->GW1_FILIAL+(cAliasQry)->GWN_NRROM, "GWN_MTCALC")),128,1))
			cGWNVPVAL  := (cAliasQry)->GWN_VPVAL
			cGWUDTPENT := (cAliasQry)->GWU_DTPENT
			cGWUHRPENT := (cAliasQry)->GWU_HRPENT
			cGWUDTENT  := (cAliasQry)->GWU_DTENT
			cGWUHRENT  := (cAliasQry)->GWU_HRENT
			cGWFNRCALC := (cAliasQry)->GWF_NRCALC
			cGWFTPFRET := RetTpFrtCalc((cAliasQry)->GW1_TPFRET)
			cVLFRET    := (cAliasQry)->VLFRET
			cVLICMS    := (cAliasQry)->VLICMS
			cVLPIS     := (cAliasQry)->VLPIS
			cVLCOFI    := (cAliasQry)->VLCOFI
			cGWFTPTRIB := RetTpTrbGWF((cAliasQry)->GWF_TPTRIB)
			cGWFCRDICM := IIf((cAliasQry)->GWF_CRDICM == "1", "Sim", "Não")
			cGWFCRDPC  := IIf((cAliasQry)->GWF_CRDPC == "1", "Sim", "Não")
			cGWGNRTAB  := (cAliasQry)->GWG_NRTAB
			cGWGNRNEG  := (cAliasQry)->GWG_NRNEG
			cGWGCDFXTV := (cAliasQry)->GWG_CDFXTV
			cGWGCDTPOP := (cAliasQry)->GWG_CDTPOP
			cGWGCDTPVC := (cAliasQry)->GWG_CDTPVC
			cGWGCDCLFR := (cAliasQry)->GWG_CDCLFR
			cGV9UNIFAI := (cAliasQry)->GV9_UNIFAI
			cGWGNRROTA := (cAliasQry)->GWG_NRROTA
			cDESCROTA  := GFEAINFROT(cGWUCDTRP,cGWGNRTAB,cGWGNRNEG,cGWGNRROTA)
			cGWJNRPF   := (cAliasQry)->GWJ_NRPF
			cGWJDTIMPL := (cAliasQry)->GWJ_DTIMPL
			cGWJSIT    := (cAliasQry)->GWJ_SIT
			cGWJSITFIN := (cAliasQry)->GWJ_SITFIN
			cCODLOTE   := (cAliasQry)->CODLOTE
			cGXFVALOR  := (cAliasQry)->GXF_VALOR
			cPERLOTE   := (cAliasQry)->PERLOTE
			cSITLOTE   := (cAliasQry)->SITLOTE
			cGXTNRCT   := ""
			If GFXTB12117("GXT") .And. GFXTB12117("GXY")
				cAliasGXZ := GetNextAlias()
				BeginSql Alias cAliasGXZ
					SELECT GXZ.GXZ_NRCT
					FROM %Table:GXZ% GXZ
					WHERE GXZ.GXZ_FILDF = %Exp:(cAliasQry)->GW3_FILIAL%
					AND GXZ.GXZ_CDESP = %Exp:(cAliasQry)->GW3_CDESP%
					AND GXZ.GXZ_EMISDF = %Exp:(cAliasQry)->GW3_EMISDF%
					AND GXZ.GXZ_SERDF = %Exp:(cAliasQry)->GW3_SERDF%
					AND GXZ.GXZ_NRDF = %Exp:(cAliasQry)->GW3_NRDF%
					AND GXZ.GXZ_DTEMIS = %Exp:(cAliasQry)->GW3_DTEMIS%
					AND GXZ.%NotDel%
				EndSql
				If (cAliasGXZ)->(!Eof())
					cGXTNRCT := (cAliasGXZ)->GXZ_NRCT
				EndIf
				(cAliasGXZ)->(dbCloseArea())
				If Empty(cGXTNRCT)
					cAliasGXY := GetNextAlias()
					BeginSql Alias cAliasGXY
						SELECT GXY.GXY_NRCT
						FROM %Table:GXY% GXY
						WHERE GXY.GXY_FILCA = %Exp:(cAliasQry)->GW1_FILIAL%
						AND GXY.GXY_NRCALC = %Exp:(cAliasQry)->GWF_NRCALC%
						AND GXY.%NotDel%
					EndSql
					If (cAliasGXY)->(!Eof())
						cGXTNRCT := (cAliasGXY)->GXY_NRCT
					EndIf
					(cAliasGXY)->(dbCloseArea())
				EndIf
			EndIf
			cGW3CDESP  := (cAliasQry)->GW3_CDESP
			cGW3NRDF   := (cAliasQry)->GW3_NRDF
			cGW3SERDF  := (cAliasQry)->GW3_SERDF
			cGW3TPDF   := RetTipGW3((cAliasQry)->GW3_TPDF)
			cGW3DTENT  := (cAliasQry)->GW3_DTENT
			cGW3DTEMIS := (cAliasQry)->GW3_DTEMIS
			cVLFRETDF  := (cAliasQry)->VLFRETDF
			cVLICMSDF  := (cAliasQry)->VLICMSDF
			cVLPISDF   := (cAliasQry)->VLPISDF
			cVLCOFIDF  := (cAliasQry)->VLCOFIDF
			cGW3SIT    := RetSit((cAliasQry)->GW3_SIT)
			cGXGEDISIT := ""
			cGW3MOTBLQ := rTrim(MemoLine(FWNoAccent(Posicione("GW3", 1, (cAliasQry)->GW3_FILIAL+(cAliasQry)->GW3_CDESP+(cAliasQry)->GW3_EMISDF+(cAliasQry)->GW3_SERDF+(cAliasQry)->GW3_NRDF, "GW3_MOTBLQ")),128,1))
			cGW3SITFIS := RetFisGW3((cAliasQry)->GW3_SITFIS)
			cGW3DTFIS  := (cAliasQry)->GW3_DTFIS
			cGW3SITREC := RetFisGW3((cAliasQry)->GW3_SITREC)
			cGW3DTREC  := (cAliasQry)->GW3_DTREC
			cGW3SITCUS := RetSitCusGW3((cAliasQry)->GW3_SITCUS)
			cGW3DTCUS  := (cAliasQry)->GW3_DTCUS
			cGW3SITMLA := RetSitMLA((cAliasQry)->GW3_SITMLA)
			cGW6NRFAT  := (cAliasQry)->GW6_NRFAT
			cGW6DTEMIS := (cAliasQry)->GW6_DTEMIS
			cGW6VLFATU := (cAliasQry)->GW6_VLFATU
			cGW6SITAPR := RetSit((cAliasQry)->GW6_SITAPR)
			cGW6DTFIN  := (cAliasQry)->GW6_DTFIN
			cGW6SITFIN := RetFinGW6((cAliasQry)->GW6_SITFIN)

			GFER002Line()

			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
	If _cMvPar05 == 1 .Or. _cMvPar05 == 3
		cWhere := ""
		If !Empty(cDtAte) .And. cDtAte >= cDtDe
			cWhere += " AND GXG.GXG_DTIMP >= '"+cDtDe+"' AND GXG.GXG_DTIMP <= '"+cDtAte+"'"
		EndIf
		If !Empty(cDtEmisAte) .And. cDtEmisAte >= cDtEmisDe
			cWhere += " AND GXG.GXG_DTEMIS >= '"+cDtEmisDe+"' AND GXG.GXG_DTEMIS <= '"+cDtEmisAte+"'"
		EndIf
		cWhere := "%" + cWhere + "%"
		// Select para buscar apenas os documentos de frete que estão com situação rejeitado na importação Conemb
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT GXH.GXH_FILDC,
					GXH.GXH_TPDC,
					GXH.GXH_EMISDC,
					GXH.GXH_SERDC,
					GXH.GXH_NRDC,
					GXH.GXH_DANFE,
					GXG.GXG_CDESP,
					GXG.GXG_SERDF,
					GXG.GXG_NRDF,
					GXG.GXG_TPDF,
					GXG.GXG_EMISDF,
					GXG.GXG_DTENT,
					GXG.GXG_DTEMIS,
					GXG.GXG_VLDF,
					GXG.GXG_NRIMP,
					GXG.GXG_VLIMP,
					GXG.GXG_TPIMP,
					GXG.GXG_EDISIT,
					GU3EMIS.GU3_NMEMIT AS NMEMIS,
					GU3TRP.GU3_IDFED AS CNPJTRP,
					GU3TRP.GU3_NMEMIT AS NMTRP,
					GU3TRP.GU3_AUTON AS AUTON,
					GU3TRP.GU3_MODAL AS MODAL,
					GU3TRP.GU3_TPTRIB AS TPTRIB
			FROM %Table:GXG% GXG
			INNER JOIN %Table:GXH% GXH 
			ON GXG.GXG_FILIAL = GXH.GXH_FILIAL 
			AND GXG.GXG_NRIMP = GXH.GXH_NRIMP 
			AND GXH.%NotDel% 
			LEFT JOIN %Table:GU3% GU3EMIS
			ON GU3EMIS.GU3_FILIAL = %xFilial:GU3% 
			AND GXH.GXH_EMISDC = GU3EMIS.GU3_CDEMIT
			AND GU3EMIS.%NotDel%
			LEFT JOIN %Table:GU3% GU3TRP
			ON GU3TRP.GU3_FILIAL = %xFilial:GU3%
			AND GXG.GXG_EMISDF = GU3TRP.GU3_CDEMIT
			AND GU3TRP.%NotDel%
			WHERE GXG.GXG_EDISIT = '3'
			AND GXG.%NotDel%
		EndSql
		TcSetField(cAliasQry,"GXG_DTENT","D",8,0)
		TcSetField(cAliasQry,"GXG_DTEMIS","D",8,0)
		Do While (cAliasQry)->(!Eof())
			// Inicializa as variáveis
			cGW1FILIAL  := (cAliasQry)->GXH_FILDC
			cGW1NMFIL  := FwFilName(cEmpAnt,cGW1FILIAL)
			cGW1CDTPDC  := (cAliasQry)->GXH_TPDC
			cGW1EMISDC  := (cAliasQry)->GXH_EMISDC
			cGW1SERDC   := (cAliasQry)->GXH_SERDC
			cGW1NRDC    := (cAliasQry)->GXH_NRDC
			cGWFTPFRET  := ""
			cCNPJEMIS   := ""
			cNMEMIS     := (cAliasQry)->NMEMIS
			cGU3NRCID   := ""
			cGW1DANFE   := (cAliasQry)->GXH_DANFE
			cGW1DTEMIS  := SToD("  /  /    ")
			cGW1DTIMPL  := SToD("  /  /    ")
			cGW1DTSAI   := SToD("  /  /    ")
			cGW1USO     := ""
			cGW1REGCOM  := ""
			cGW8ITEM    := ""
			cGW8DSITEM  := ""
			cGW8QTDE    := ""
			cGW8VALOR   := ""
			cGW8VOLUME  := ""
			cGW8PESOC   := ""
			cGW8PESOR   := ""
			cGW8QTDALT  := ""
			cGUBDSCLFR  := ""
			cGW8CFOP    := ""
			cGW8INFO1   := ""
			cGW8INFO2   := ""
			cGW8INFO3   := ""
			cGW8INFO4   := ""
			cGW8INFO5   := ""
			cGW1CDREM   := ""
			cNMREM      := ""
			cCNPJREM    := ""
			cGW1CDDEST  := ""
			cNMDEST     := ""
			cCNPJDEST   := ""
			cGW1SIT     := ""
			cGW1CALCAT  := ""
			cGW1ROMTV   := ""
			cGW1ROMCF   := ""
			cGW1ROMTO   := ""
			cGWUNRCIDO  := ""
			cNMCIDO     := ""
			cUFO        := ""
			cGWUNRCIDD  := ""
			cNMCIDD     := ""
			cUFD        := ""
			cNMREGD     := ""
			cGWUSEQ     := ""
			cGWUPAGAR   := ""
			cGWUCDTRP   := (cAliasQry)->GXG_EMISDF
			cCNPJTRP    := (cAliasQry)->CNPJTRP
			cNMTRP      := (cAliasQry)->NMTRP
			cAUTON      := (cAliasQry)->AUTON
			cMODAL      := (cAliasQry)->MODAL
			cTPTRIB     := (cAliasQry)->TPTRIB
			cGWNNRROM   := ""
			cGWNSIT     := ""
			cGWNCDTPVC  := ""
			cGWNCDCLFR  := ""
			cGWNCDTPOP  := ""
			cGWNCALC    := ""
			cGWUDTPENT  := SToD("  /  /    ")
			cGWUHRPENT  := ""
			cGWUDTENT   := SToD("  /  /    ")
			cGWUHRENT   := ""
			cGWNMTCALC  := ""
			cNMREGP     := ""
			cGWFNRCALC  := ""
			cGWFTPFRET  := ""
			cVLFRET     := ""
			cVLICMS     := ""
			cVLPIS      := ""
			cVLCOFI     := ""
			cGWFTPTRIB  := ""
			cGWFCRDICM  := ""
			cGWFCRDPC   := ""
			cGWGNRTAB   := ""
			cGWGNRNEG   := ""
			cGWGCDFXTV  := ""
			cGWGNRROTA  := ""
			cDESCROTA   := ""
			cGV9UNIFAI  := ""
			cGWGCDTPOP  := ""
			cGWGCDTPVC  := ""
			cGWGCDCLFR  := ""
			cGXTNRCT    := ""
			cGWJNRPF    := ""
			cGWJDTIMPL  := SToD("  /  /    ")
			cGWJSIT     := ""
			cGWJSITFIN  := ""
			cCODLOTE    := ""
			cGXFVALOR   := ""
			cPERLOTE    := ""
			cSITLOTE    := ""
			cGW3CDESP   := (cAliasQry)->GXG_CDESP
			cGW3NRDF    := (cAliasQry)->GXG_NRDF
			cGW3SERDF   := (cAliasQry)->GXG_SERDF
			cGW3TPDF    := (cAliasQry)->GXG_TPDF
			cGW3DTENT   := (cAliasQry)->GXG_DTENT
			cGW3DTEMIS  := (cAliasQry)->GXG_DTEMIS
			cVLFRETDF   := (cAliasQry)->GXG_VLDF
			cVLICMSDF   := (cAliasQry)->GXG_VLIMP
			cVLPISDF    := ""
			cVLCOFIDF   := ""
			cGW3SIT     := ""
			cGW3MOTBLQ  := rTrim(MemoLine(FWNoAccent(Posicione('GXG', 1, FWxFilial('GXG')+(cAliasQry)->GXG_NRIMP, 'GXG_EDIMSG')),128,1))
			cGW3SITFIS  := ""
			cGW3DTFIS   := SToD("  /  /    ")
			cGW3SITREC  := ""
			cGW3DTREC   := SToD("  /  /    ")
			cGW3SITCUS  := ""
			cGW3DTCUS   := SToD("  /  /    ")
			cGW3SITMLA  := ""
			cGW6NRFAT   := ""
			cGW6DTEMIS  := SToD("  /  /    ")
			cGW6VLFATU  := ""
			cGW6SITAPR  := ""
			cGW6DTFIN   := SToD("  /  /    ")
			cGW6SITFIN  := ""
			CGXGEDISIT  := RetSitEdi((cAliasQry)->GXG_EDISIT)
			cGW0MSG     := ""
			cGWNVPVAL   := ""

			GFER002Line()

			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	Endif
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} RetUso(cCodUso)
Retorna a finalidade do documento de carga
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function RetUso(cCodUso)
	
	Local cDesc := ""

	Do Case
		Case cCodUso == '1'
			cDesc := 'Industrialização/Venda'
		Case cCodUso == '2'
			cDesc := 'Uso/Consumo'
		Case cCodUso == '3'
			cDesc := 'Ativo Imobilizado'
		Otherwise
			cDesc := 'Finalidade Não Encontrada'
	EndCase

Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetTpMod(cTp)
Retorna o tipo de modal
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetTpMod(cTp )
	Local cDesc := ""
	
		Do Case
			Case cTp == "1"
				cDesc := "Nao-Informado"
			Case cTp == "2"
				cDesc := "Rodoviario"
			Case cTp == "3"
				cDesc := "Ferroviario"
			Case cTp == '4'
				cDesc := 'Aereo'
			Case cTp == '5'
				cDesc := 'Aquaviario'
			Case cTp == '6'
				cDesc := 'Dutoviario'
			Case cTp == '7'
				cDesc := 'Multimodal'
		EndCase

Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetSitGW1(cSit)
Retorna a situação do documento de carga
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetSitGW1(cSit)
	Local cDesc := ""
	
		Do Case
			Case cSit == "1"
				cDesc := "Digitado"
			Case cSit == "2"
				cDesc := "Bloqueado"
			Case cSit == "3"
				cDesc := "Liberado"
			Case cSit == '4'
				cDesc := 'Embarcado'
			Case cSit == '5'
				cDesc := 'Entregue'
			Case cSit == '6'
				cDesc := 'Retornado'
			Case cSit == '7'
				cDesc := 'Cancelado'
            Case cSit == '8'
				cDesc := 'Sinistrado'
		EndCase

Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetCalcGW1(cCalc)
Retorna a situação de cálculo do documento de carga
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetCalcGW1(cCalc)
	Local cDesc := ""
	
		Do Case
			Case cCalc == "0"
				cDesc := "Não se Aplica"
			Case cCalc == "1"
				cDesc := "Cálculo Aut. Pendente"
			Case cCalc == "2"
				cDesc := "Cálculo Automático"
			Case cCalc == "3"
				cDesc := "Cálculo Sem Sucesso"
			Case cCalc == '4'
				cDesc := 'Romaneio Sem Sucesso'
		EndCase

Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc}  RetTpTrb(cTp)
Retorna o tipo de tributação
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetTpTrb(cTp )
	Local cDescTp := ""
	
		Do Case
			Case cTp == "1"
				cDescTp := "Normal"
			Case cTp == "2"
				cDescTp := "Simplificado"
			Case cTp == "3"
				cDescTp := "Especial"
			Case cTp == '4'
				cDescTp := 'Imune'
		EndCase
Return cDescTp
//-------------------------------------------------------------------
/*/{Protheus.doc} RetSitRom(cSit)
Retorna a situação do romaneio
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetSitRom(cSit )
	Local cDesc := ""
	
		Do Case
			Case cSit == "1"
				cDesc := "Digitado"
			Case cSit == "2"
				cDesc := "Emitido"
			Case cSit == "3"
				cDesc := "Liberado"
			Case cSit == '4'
				cDesc := 'Encerrado'
		EndCase

Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetCalcGWN(cCalc)
Retorna a situação de cálculo do romaneio
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetCalcGWN(cCalc)
	Local cDesc := ""
	
		Do Case
			Case cCalc == "1"
				cDesc := "Cálculo com Sucesso"
			Case cCalc == "2"
				cDesc := "Não Calculado"
			Case cCalc == "3"
				cDesc := "Tentativa Sem Sucesso"
			Case cCalc == "4"
				cDesc := "Necessita Recálculo"
		EndCase
Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetTpFrtCalc(cTpFrt)
Retorna o tipo de frete do cálculo
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetTpFrtCalc(cTpFrt)
	Local cDesc := ""
	
		Do Case
			Case cTpFrt == "1"
				cDesc := "CIF"
			Case cTpFrt == "2"
				cDesc := "CIF Redesp"
			Case cTpFrt == "3"
				cDesc := "FOB"
			Case cTpFrt == "4"
				cDesc := "FOB Redesp."
			Case cTpFrt == "5"
				cDesc := "Consignado"
			Case cTpFrt == "6"
				cDesc := "Consig. Redesp."
		EndCase

Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetTpTrbGWF(cTpTrib)
Retorna o tipo de tributo do cálculo
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetTpTrbGWF(cTpTrib)
	Local cDesc := ""
	
		Do Case
			Case cTpTrib == "1"
				cDesc := "Tributado"
			Case cTpTrib == "2"
				cDesc := "Isento/Não-Tributado"
			Case cTpTrib == "3"
				cDesc := "Subs. Tributária"
			Case cTpTrib == "4"
				cDesc := "Diferido"
			Case cTpTrib == "5"
				cDesc := "Reduzido"
			Case cTpTrib == "6"
				cDesc := "Outros"
			Case cTpTrib == "Presumido"
				cDesc := "Outros"
		EndCase

Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetTipGW3(cTip)
Retorna o tipo de documento de frete
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetTipGW3(cTip)
	Local cDesc := ""
	
		Do Case
			Case cTip == "1"
				cDesc := "Normal"
			Case cTip == "2"
				cDesc := "Complementar Valor"
			Case cTip == "3"
				cDesc := "Complementar Imposto"
			Case cTip == '4'
				cDesc := 'Reentrega'
			Case cTip == '5'
				cDesc := 'Devolução'
			Case cTip == '6'
				cDesc := 'Redespacho'
			Case cTip == '7'
				cDesc := 'Serviço'
		EndCase

Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetFisGW3(cSit)
Retorna a situação de integração fiscal
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetFisGW3(cSit)
	Local cDesc := "" 
	
	Do Case
		Case cSit == "1"
			cDesc := "Não Enviado"
		Case cSit == "2"
			cDesc := "Pendente"
		Case cSit == "3"
			cDesc := "Rejeitado"
		Case cSit == "4"
			cDesc := "Atualizado"
		Case cSit == "5"
			cDesc := "Pendente Desatualização"
		Case cSit == "6"
			cDesc := "Não se Aplica"
	EndCase
Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetSitCusGW3(cSit)
Retorna a situação de integração de centro de custo
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetSitCusGW3(cSit)
	Local cDesc := ""
	
	Do Case
		Case cSit == "0"
			cDesc := "Não se Aplica"
		Case cSit == "1"
			cDesc := "Não Enviado"
		Case cSit == "2"
			cDesc := "Atualizado"
		Case cSit == "3"
			cDesc := "Rejeitado"
		Case cSit == "4"
			cDesc := "Pendente Atualização"            
	EndCase
Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetFinGW6(cSit)
Retorna o tipo de situação financeira
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetFinGW6(cSit)
	Local cDesc := ""
	
	Do Case 
		Case cSit == "1"
			cDesc := "Não enviada"
		Case cSit == "2"
			cDesc := "Pendente"
		Case cSit == "3"
			cDesc := "Rejeitada"
		Case cSit == "4"
			cDesc := "Atualizada"
		Case cSit == "5"
			cDesc := "Pendente Desatualização"
	EndCase
Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} RetSitMLA(cSit)
Retorna o tipo de situação MLA
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetSitMLA(cSit)
	Local cDesc := ""
	
		Do Case
			Case cSit == "1"
				cDesc := "Não Enviado"
			Case cSit == "2"
				cDesc := "Pendente"
			Case cSit == "3"
				cDesc := "Rejeitado"
			Case cSit == '4'
				cDesc := 'Aprovado'
			Case cSit == '5'
				cDesc := 'Pend. Desatualização'
			Case cSit == '6'
				cDesc := 'Não se Aplica'
			Case cSit == '7'
				cDesc := 'Enviado/Aguardando'
			Case cSit == '8'
				cDesc := 'Pendente Atualização'
		EndCase
Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSitMLA(cSit)
Retorna o tipo de situação MLA
@author  Lucas Briesemeister
@since   03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetSit(cSit)
	Local cDesc := ""
	
		Do Case
			Case cSit == "1"
				cDesc := "Recebido(a)"
			Case cSit == "2"
				cDesc := "Bloqueado(a)"
			Case cSit == "3"
				cDesc := "Aprovado(a) Sistema"
			Case cSit == '4'
				cDesc := 'Aprovado(a) Usuário'
		EndCase
Return cDesc

Static Function RetSitEdi(cSit)
	Local cDesc := ""

		Do Case
			Case cSit == "1"
				cDesc := "Importado"
			Case cSit == "2"
				cDesc := "Importado Com Erro"
			Case cSit == "3"
				cDesc := "Rejeitado"
			Case cSit == "4"
				cDesc := "Processado"
			Case cSit == "5"
				cDesc := "Erro Impeditivo"
			Otherwise
				cDesc := "  "
		EndCase
Return cDesc

Static Function SchedDef()

Local aParam := {}
Local aOrd   := {""}

aParam := { "R",;       //Tipo R para relatorio P para processo
			"GFER002",; // Pergunte do relatorio, caso nao use passar ParamDef
			"GW1",;     // Alias
			aOrd,;      //Array de ordens
			"Schedule GFER002"}
Return aParam

/*/{Protheus.doc} GFER002Txt
	Geração do relatório em CSV
	@type  Static Function
	@author SQuad GFE
	@since 26/03/2020
	@version 1.0
	@return lRet, Logical, .T. com sucesso, .F. sem sucesso
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function GFER002Txt()
	Local lRet     := .T.
	Local cLogFile := ""
	Local cGFEDoc  := ""
	Local cHora    := Time()

	cLogFile := "GFER002"+DToS(dDataBase)+StrTran(cHora,":","")+".txt"
	cGFEDoc  := _cMvPar07
	If !Empty(cGFEDoc)
		cGFEDoc := AllTrim(cGFEDoc)
		If Right(cGFEDoc,1) $ "/\"
			cGFEDoc := Left(cGFEDoc,Len(cGFEDoc)-1)
		EndIf
		cLogFile := cGFEDoc+"/"+cLogFile
	EndIf

	If !File(cLogFile)
		If (nHandle := MSFCreate(cLogFile,0)) <> -1
			lRet := .T.
		EndIf
	Else
		If (nHandle := FOpen(cLogFile,2)) <> -1
			FSeek(nHandle,0,2)
			lRet := .T.
		EndIf
	EndIf
	If lRet
		GFER002Def()
		LoadTable()
		
		FClose(nHandle)
	Else
		MsgAlert("Erro durante criação do arquivo.")
	EndIf
Return lRet

/*/{Protheus.doc} GFER002Def
	Definição leioute CSV
	@type  Static Function
	@author SQuad GFE
	@since 26/03/2020
	@version 1.0
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function GFER002Def()
	Local cLinha := ""

	// Define cabeçalho
	cLinha := STR0002+";" // Código Filial
	cLinha += STR0003+";" // Nome Filial
	cLinha += STR0004+";" // Tipo DC
	cLinha += STR0005+";" // Cód. Emissor
	cLinha += STR0006+";" // CNPJ/CPF Emis.
	cLinha += STR0007+";" // Nome Emissor
	cLinha += STR0008+";" // Série DC
	cLinha += STR0009+";" // Número DC
	cLinha += STR0010+";" // Chave Acesso
	cLinha += STR0011+";" // Dt. Emissão
	cLinha += STR0012+";" // Dt. Implantação
	cLinha += STR0013+";" // Dt. Saída
	cLinha += STR0014+";" // Finalidade
	cLinha += STR0015+";" // Região Comercial
	cLinha += STR0016+";" // Item
	cLinha += STR0017+";" // Descrição Item
	cLinha += STR0018+";" // Quantidade Item
	cLinha += STR0019+";" // Valor Item
	cLinha += STR0020+";" // Volume Item
	cLinha += STR0021+";" // Peso Cubado Item
	cLinha += STR0022+";" // Peso Real Item
	cLinha += STR0023+";" // Quantidade/Peso Alt.
	cLinha += STR0024+";" // Classificação De Frete
	cLinha += STR0025+";" // CFOP
	cLinha += IIf(_IntGFE,STR0026,STR0027)+";" // Natureza de Operação // Info Contábil 1
	cLinha += IIf(_IntGFE,STR0028,STR0029)+";" // Canal de Vendas      // Info Contábil 2
	cLinha += IIf(_IntGFE,STR0030,STR0031)+";" // Grupo de Estoque     // Info Contábil 3
	cLinha += IIf(_IntGFE,STR0032,STR0033)+";" // Família Comercial    // Info Contábil 4
	cLinha += IIf(_IntGFE,STR0034,STR0035)+";" // Família de Materiais // Info Contábil 5
	cLinha += STR0036+";" // Código Remetente
	cLinha += STR0037+";" // CNPJ/CPF Remetente
	cLinha += STR0038+";" // Nome Remetente
	cLinha += STR0039+";" // Código Destinatário
	cLinha += STR0040+";" // CNPJ/CPF Destinatário
	cLinha += STR0041+";" // Nome Destinatário
	cLinha += STR0042+";" // Situação
	cLinha += STR0043+";" // Motivo Bloqueio
	cLinha += STR0044+";" // Sit. Cálc Automático
	cLinha += STR0045+";" // Tipo Veículo Romaneio
	cLinha += STR0046+";" // Classificação de Frete Romaneio
	cLinha += STR0047+";" // Tipo de Operação Romaneio
	cLinha += STR0048+";" // Cód. Cidade Emit
	cLinha += STR0049+";" // Cód. Cidade Origem
	cLinha += STR0050+";" // Nome Cidade Origem
	cLinha += STR0051+";" // UF Cidade Origem
	cLinha += STR0052+";" // Cód. Cidade Destino
	cLinha += STR0053+";" // Nome Cidade Destino
	cLinha += STR0054+";" // UF Cidade Destino
	cLinha += STR0055+";" // Região Própria
	cLinha += STR0056+";" // Região Negociação Frete
	cLinha += STR0057+";" // Sequência do Itinerário
	cLinha += STR0058+";" // Pagar
	cLinha += STR0059+";" // Código Transportador
	cLinha += STR0060+";" // CNPJ/CPF Transportador
	cLinha += STR0061+";" // Nome Transportador
	cLinha += STR0062+";" // Tipo Transportador
	cLinha += STR0063+";" // Modal Transportador
	cLinha += STR0064+";" // Regime Tributário Transp.
	cLinha += STR0065+";" // Número Romaneio
	cLinha += STR0066+";" // Situação Romaneio
	cLinha += STR0067+";" // Tipo de Veículo
	cLinha += STR0068+";" // Classificação de Frete Romaneio
	cLinha += STR0069+";" // Tipo de Operação
	cLinha += STR0070+";" // Situação Cálculo
	cLinha += STR0071+";" // Motivo Cálculo
	cLinha += STR0072+";" // Valor Pedágio
	cLinha += STR0073+";" // Data Prevista Entrega
	cLinha += STR0074+";" // Hora Prevista Entrega
	cLinha += STR0075+";" // Data Entrega
	cLinha += STR0076+";" // Hora Entrega
	cLinha += STR0077+";" // Número Cálculo
	cLinha += STR0078+";" // Tipo de Frete do Cálculo
	cLinha += STR0079+";" // Valor Frete
	cLinha += STR0080+";" // Valor ICMS
	cLinha += STR0081+";" // Valor PIS
	cLinha += STR0082+";" // Valor COFINS
	cLinha += STR0083+";" // Tipo de Tributação
	cLinha += STR0084+";" // Gera Crédito ICMS
	cLinha += STR0085+";" // Gera Crédito PIS/COFINS
	cLinha += STR0086+";" // Número Tabela de Frete
	cLinha += STR0087+";" // Negociação
	cLinha += STR0088+";" // Faixa
	cLinha += STR0089+";" // Tipo de Operação
	cLinha += STR0090+";" // Tipo de Veículo
	cLinha += STR0091+";" // Class. Frete da Tab. de Frete
	cLinha += STR0092+";" // Unid. Faixa
	cLinha += STR0093+";" // Rota
	cLinha += STR0094+";" // Descrição da Rota
	cLinha += STR0095+";" // Número Pré-Fatura
	cLinha += STR0096+";" // Data de Implantação Pré-Fatura
	cLinha += STR0097+";" // Situação Pré-Fatura
	cLinha += STR0098+";" // Situação Pré-Fatura Financeiro
	cLinha += STR0099+";" // Código Lote
	cLinha += STR0100+";" // Valor Lote
	cLinha += STR0101+";" // Período Lote
	cLinha += STR0102+";" // Situação Lote
	If GFXTB12117("GXT")
		cLinha += STR0103+";" // Número Contrato Transp
	EndIf
	cLinha += STR0104+";" // Espécie Doc. Frete
	cLinha += STR0105+";" // Número Doc. Frete
	cLinha += STR0106+";" // Série Doc. Frete
	cLinha += STR0107+";" // Tipo Doc. Frete
	cLinha += STR0108+";" // Data de Entrada Doc. Frete
	cLinha += STR0109+";" // Data de Emissão Doc. Frete
	cLinha += STR0110+";" // Valor Doc. Frete
	cLinha += STR0111+";" // Valor ICMS Doc. Frete
	cLinha += STR0112+";" // Valor PIS Doc. Frete
	cLinha += STR0113+";" // Valor COFINS Doc. Frete
	cLinha += STR0114+";" // Situação Documento de Frete
	cLinha += STR0115+";" // Situação EDI
	cLinha += STR0116+";" // Motivo Divergência Conferência
	cLinha += STR0117+";" // Situação Integração Fiscal
	cLinha += STR0118+";" // Data Integração Fiscal
	cLinha += STR0119+";" // Situação Integração Recebedoria
	cLinha += STR0120+";" // Data Integração Recebedoria
	cLinha += STR0121+";" // Situação Integ. Custo de Frete
	cLinha += STR0122+";" // Data Integ. Custo de Frete
	cLinha += STR0123+";" // Situação Integração MLA
	cLinha += STR0124+";" // Número Fatura
	cLinha += STR0125+";" // Data Emissão Fatura
	cLinha += STR0126+";" // Valor Fatura
	cLinha += STR0127+";" // Situação Fatura
	cLinha += STR0128+";" // Data Integração Fatura
	cLinha += STR0129 // Situação Integração Fatura

	FWrite(nHandle, cLinha + CRLF)
Return Nil
