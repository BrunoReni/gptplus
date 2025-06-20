#INCLUDE "ATFR490.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

Static aStatus	 		:= {}	//Descricao de Status possiveis para um controle de provis鉶

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � ATFR490  � Autor 矼auricio Pequim Jr.    � Data � 16/12/11 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Demonstrativo: Provisao e realizado de AVP de projeto de   潮�
北�          � imobilizado                                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � SIGAATF                                                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function ATFR490()

Local oReport
Local lTReport	:= TRepInUse()
Local lDefTop	:= IfDefTopCTB() // verificar se pode executar query (TOPCONN)
Local lRet		:= .T.
//Verifica implementacao da Controle de Provisao
Local lProvis	:= AFPrvAtf()


Private cPerg   := "ATFR490"
Private aSelFil	:= {}
Private cOcorSel:= {}

If !lDefTop
	Help("  ",1,"AFR490TOP",,STR0012 ,1,0)  //"Fun玢o dispon韛el apenas para ambientes TopConnect"
	lRet := .F.
EndIf

If !lTReport
	Help("  ",1,"AFR490R4",,STR0013,1,0) //"Fun玢o dispon韛el apenas para TReport, por favor atualizar ambiente e verificar parametro MV_TREPORT"
	lRet := .F.
ENdIf

If !lProvis
	Help("  ",1,"AFR490NPRV",,STR0018,1,0) //'Para utilizar este relat髍io, � necess醨io que esteja implementado o processo de Controle de Provis鉶. Por favor, atualize o ambiente'
	lRet := .F.
ENdIf

If lRet
	If Pergunte( cPerg , .T. )
		If mv_par08 == 1 .And. Len( aSelFil ) <= 0
			aSelFil := AdmGetFil()
			If Len( aSelFil ) <= 0
				Return
			EndIf
		EndIf

		//Seleciona Ocorrencias
		If mv_par12 == 1 .And. !IsBlind()
			cOcorSel := AFSelTpPrv()
			If Empty( cOcorSel )
				Help(" ",1,"AF490GETOC",,STR0027,1,0) //"Favor selecionar ao menos uma Ocor阯cia"
				Return
			EndIf
		EndIf

		oReport:= ReportDef()
		oReport:PrintDialog()
	Endif
EndIf

Return

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � ReportDef� Autor 矼auricio Pequim Jr.    � Data � 16/12/11 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Definicao do relatorio                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � ATFR490                                                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function ReportDef()

Local oReport		:= nil
Local oFNU   		:= nil
Local oFNW			:= nil
Local cDesc			:= STR0014 //"Este relat髍io tem o objetivo de demonstrar os movimentos do Controle de Provis鉶."
Local cTitulo		:= STR0015 //"Demonstrativo Planejamento de Provis鉶"
Local cAliasPrv 	:= GetNextAlias()
Local lTotalPer		:= .F.
Local lTotalPrv		:= .F.
Local lTotalFil		:= .F.

Pergunte(cPerg,.F.)

lTotalPer	:= MV_PAR09 == 1
lTotalPrv	:= MV_PAR10 == 1
lTotalFil	:= MV_PAR11 == 1
lTotalRev	:= (MV_PAR03 > 1 .and. MV_PAR05 > MV_PAR04)


DEFINE REPORT oReport NAME "ATFR490" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| PrintReport(oReport,cPerg,cAliasPrv)} DESCRIPTION cDesc TOTAL IN COLUMN

oReport:ParamReadOnly()
oReport:SetUseGc(.F.)   //DESABILITA OPCAO GESTAO CORPORATIVA

DEFINE SECTION oFNU OF oReport TITLE STR0016 TABLES "FNU" //"Controle de Provis鉶"
	DEFINE CELL NAME "FNU_FILIAL" OF oFNU ALIAS "FNU"
	DEFINE CELL NAME "FNU_COD"    OF oFNU ALIAS "FNU" TITLE STR0001 //"Provisao Cod.:"
	DEFINE CELL NAME "FNU_REV"    OF oFNU ALIAS "FNU"
	DEFINE CELL NAME "FNU_DTINI"  OF oFNU ALIAS "FNU"
	DEFINE CELL NAME "FNU_DESCR"  OF oFNU ALIAS "FNU"
	DEFINE CELL NAME "FNUSTATUS"  OF oFNU TITLE STR0026 SIZE 30 ALIGN LEFT AUTO SIZE HEADER ALIGN LEFT BLOCK {|| Afr490Stat((cAliasPrv)->FNU_STATUS) }  //"Status"

DEFINE SECTION oFNW OF oFNU TITLE STR0017 TABLES ""  //"Movimentos de Provis鉶"

	DEFINE CELL NAME "CPERIODO"   OF oFNW TITLE STR0002 SIZE TamSX3('FNW_PERIOD')[1]+1 PICTURE "@R 99/9999" ALIGN LEFT AUTO SIZE HEADER ALIGN LEFT BLOCK {|| Afr490Per((cAliasPrv)->FNW_PERIOD) }  //"Periodo"
	DEFINE CELL NAME "FNW_OCOR"   OF oFNW ALIAS "FNW"
	DEFINE CELL NAME "SLDCURTO"   OF oFNW TITLE STR0004 SIZE 18 PICTURE '@E 999,999,999,999,999.99' ALIGN RIGHT AUTO SIZE HEADER ALIGN RIGHT BLOCK {|| IIF((cAliasPrv)->FNW_PRAZO == '2',(cAliasPrv)->FNW_VALOR,0) }  //"Curto Prazo"
  	DEFINE CELL NAME "SLDLONGO"   OF oFNW TITLE STR0005 SIZE 18 PICTURE '@E 999,999,999,999,999.99' ALIGN RIGHT AUTO SIZE HEADER ALIGN RIGHT BLOCK {|| IIF((cAliasPrv)->FNW_PRAZO == '1',(cAliasPrv)->FNW_VALOR,0) }  //"Longo Prazo"
	DEFINE CELL NAME "CONTABIL"   OF oFNW ALIAS "FNW" TITLE STR0003 SIZE 20 ALIGN CENTER HEADER ALIGN CENTER BLOCK {|| Afr490DSC( (cAliasPrv)->FNW_LA ) }

DEFINE BREAK oBreakFil OF oReport WHEN oFNU:Cell("FNU_FILIAL") TITLE STR0006 //"Total Filial"

If lTotalPer
	DEFINE BREAK oBreakPer OF oFNW WHEN oFNW:Cell("CPERIODO") TITLE STR0007 //"Total Periodo"
	DEFINE FUNCTION oTPerSlCP FROM oFNW:Cell("SLDCURTO")  FUNCTION SUM BREAK oBreakPer NO END REPORT NO END SECTION
	DEFINE FUNCTION oTPerSlLP FROM oFNW:Cell("SLDLONGO")  FUNCTION SUM BREAK oBreakPer NO END REPORT NO END SECTION
EndIf

If lTotalPrv
	DEFINE BREAK oBreakPrv OF oFNU WHEN oFNU:Cell("FNU_COD") TITLE STR0009 //"Total Provis鉶"
	DEFINE FUNCTION oTPrvSlCP FROM oFNW:Cell("SLDCURTO")  FUNCTION SUM BREAK oBreakPrv NO END REPORT NO END SECTION
	DEFINE FUNCTION oTPrvSlLP FROM oFNW:Cell("SLDLONGO")  FUNCTION SUM BREAK oBreakPrv NO END REPORT NO END SECTION
	oBreakPrv:OnPrintTotal({||oReport:SkipLine(),oReport:SkipLine(),oReport:SkipLine()})
EndIf

If lTotalFil
	DEFINE FUNCTION oTFilSlCP FROM oFNW:Cell("SLDCURTO")  FUNCTION SUM BREAK oBreakFil NO END SECTION
	DEFINE FUNCTION oTFilSlLP FROM oFNW:Cell("SLDLONGO")  FUNCTION SUM BREAK oBreakFil NO END SECTION
EndIf

oFNU:SetHeaderPage(.T.)
oFNW:SetHeaderPage(.T.)
oFNU:SetAutoSize()
oFNW:SetAutoSize()

Return oReport


/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    砅rintReport� Autor 矼auricio Pequim Jr.   � Data � 16/12/11 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Definicao do relatorio                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � ATFR490                                                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function PrintReport(oReport,cPerg,cAliasPrv)

Local oFNU := oReport:Section(1)
Local oFNW := oReport:Section(1):Section(1)
Local cProvDe  := ""
Local cProvAte := ""
Local lRevAtv  := .F.
Local cRevDe   := ""
Local cRevAte  := ""
Local cCondRev := ""
Local cCondFil := ""
Local cCondOcor:= ""
Local cTmpFil

Pergunte( cPerg , .F. )

cProvDe  := MV_PAR01
cProvAte := MV_PAR02
lRevAtv  := MV_PAR03 == 1
cRevDe   := MV_PAR04
cRevAte  := MV_PAR05
cDataDe	 := DTOS(MV_PAR06)
cDataAte := DTOS(MV_PAR07)
nContab	 := MV_PAR13		//1=Todos 2=Contabilizados 3=Nao Contabilizados

//Provisao ativa ou selecionada
If lRevAtv
	//Condicao de revisao ativa
	cCondRev := " (FNU_STATUS <> '3') AND (FNU_MSBLQL = '2') "
Else
	//Condicao de revisao especifica
	cCondRev := " FNU_REV BETWEEN '" + cRevDe + "' AND '" + cRevAte + "' "
EndIf

//Controle de contabilizacao
If nContab == 1 //Todos
	cCondCtb := " "
ElseIf nContab == 2	//Contabilizados
	cCondCtb := " AND FNW_LA <> ' ' "
Else					//Nao Contabilizados
	cCondCtb := " AND FNW_LA = ' ' "
Endif

//Somo a condicao de contabilizacao na condicao de revisao
//para que nao necessite disponibilizar uma condicao para nContab = 1 (Todos)
cCondRev += cCondCTB

//Condicao de Filial
cCondFil  := "FNW_FILIAL " + GetRngFil( aSelfil , "FNW", .T., @cTmpFil ) + " "
cCondData := "FNW_DTMOV BETWEEN '" + cDataDe + "' AND '" + cDataAte + "' "
If !Empty(cOcorSel)
	cCondOcor := "AND FNW_OCOR IN " + FormatIn(cOcorSel,"/") + " "
EndIf

cCondRev  := "%" + cCondRev  + "%"
cCondData := "%" + cCondData + "%"
cCondFil  := "%" + cCondFil  + "%"
cCondOcor := "%" + cCondOcor + "%"


BEGIN REPORT QUERY oFNU

BeginSql alias cAliasPrv

	SELECT FNU_FILIAL  ,
            FNU_COD     ,
    	       FNU_REV     ,
    	       FNU_DTINI   ,
           FNU_DESCR   ,
           FNU_STATUS  ,
           FNU_MSBLQL  ,
           FNW_FILIAL  ,
	       FNW_COD     ,
	       FNW_REV     ,
	       FNW_PERIOD  ,
	       FNW_OCOR    ,
	       FNW_VALOR   ,
	       FNW_PRAZO   ,
	       FNW_LA      ,
           FNW_DTMOV

	FROM %table:FNU% FNU INNER JOIN %table:FNW% FNW  ON
	    FNU.FNU_FILIAL = FNW.FNW_FILIAL AND
	    FNU.FNU_COD = FNW.FNW_COD AND
	    FNU.FNU_REV = FNW.FNW_REV

	WHERE
	       FNW.FNW_COD >= %exp:cProvDe% AND
	       FNW.FNW_COD <= %exp:cProvAte% AND
	       %exp:cCondFil% AND
	       %exp:cCondRev% AND
	       %exp:cCondData% AND
	       FNU.%notDel% AND
	       FNW.%notDel%
	       %exp:cCondOcor%

	ORDER BY FNW_FILIAL,FNW_COD,FNW_REV,FNW_DTMOV,FNW_OCOR

EndSql

END REPORT QUERY oFNU

oFNW:SetParentQuery()
oFNW:SetParentFilter({|cParam| (cAliasPrv)->(FNW_FILIAL+FNW_COD+FNW_REV) == cParam},{|| (cAliasPrv)->(FNU_FILIAL+FNU_COD+FNU_REV) })
CtbTmpErase(cTmpFil)
oFNU:Print()

Return


/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � Afr490Per  � Autor 矼auricio Pequim Jr.  � Data � 09/11/12 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Transforma o periodo de AnoMes em MesAno                   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � ATFR490                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function Afr490Per(cPeriod)

Local cMesAno := ""

//cPeriod = AnoMes (AAAAMM)
//Transformo em MesAno(MMAAAA)
cMesAno := Substr(cPeriod,5,2)+Substr(cPeriod,1,4)

Return cMesAno


/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � Afr490DSC  � Autor 矼auricio Pequim Jr.  � Data � 09/11/12 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Retorna a descricao da ocorrencia                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � ATFR490                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function Afr490DSC( cOcor )

Local cDescOcor := ""

DEFAULT cOcor = ""

If cOcor == '1'
	cDescOcor := STR0019		//Sim
ElseIf cOcor == '2'
	cDescOcor := STR0021		//Revisado
Else
	cDescOcor := STR0020		//Nao
Endif

Return cDescOcor




/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯屯送屯屯脱屯屯屯屯屯屯屯屯屯屯送屯屯脱屯屯屯屯屯屯槐�
北篜rograma  矨FR490STAT  篈utor 矼auricio Pequim Jr. � Data � 31/07/2012 罕�
北掏屯屯屯屯拓屯屯屯屯屯屯释屯屯拖屯屯屯屯屯屯屯屯屯屯释屯屯拖屯屯屯屯屯屯贡�
北篋esc.     � Combo box dos campos de Status do controle de provisao     罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function AFR490STAT(cCodStatus)

Local cStatus := ""

DEFAULT cCodStatus := ""

cStatus := "0="+STR0022 +";" //"Gerado"
cStatus += "1="+STR0023 +";" //"Atualizado"
cStatus += "2="+STR0024 +";" //"Efetivado"
cStatus += "3="+STR0021 +";" //"Revisado"
cStatus += "A="+STR0025      //"Realiza玢o Pendente"

//Utilizado apenas para o retorno da descricao do Status
If !Empty(cCodStatus)

	If Len(aStatus) == 0
		aStatus := STRTOKARR(cStatus,";")
	Endif

	If (nPos := Ascan(aStatus,{|aCod| Substr(aCod,1,1) == Alltrim(cCodStatus)}) ) > 0
		cStatus := Alltrim(Substr(aStatus[nPos],3))
	Endif
Endif

Return cStatus

