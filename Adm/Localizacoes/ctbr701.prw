#Include "ctbr701.ch"
#Include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CTBR701	³ Autor ³ Marcelo Akama			³ Data ³ 17-09-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Estado de Cambios en el Patrimonio Neto						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³26/06/15³PCREQ-4256³Se elimina la funcion Ctr701Sx1() la  ³±±
±±³            ³        ³          ³cual realiza modificacion a SX1 por   ³±±
±±³            ³        ³          ³motivo de adecuacion a fuentes a nueva³±±
±±³            ³        ³          ³estructura de SX para Version 12.     ³±±
±±³Jonathan Glz³09/10/15³PCREQ-4261³Merge v12.1.8                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ctbr701()

Private cProg     := "CTBR701"
Private cPerg     := "CTR701"
Private aItems    := {}
Private aSetOfBook:= {}
Private oReport
Private oSection1
Private oSection2

//Verifica si los informes personalizables están disponibles
If TRepInUse()
	If Pergunte(cPerg,.T.)
		oReport:=ReportDef()
		oReport:PrintDialog()
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ ReportDef³ Autor ³ Marcelo Akama			 ³ Data ³ 17/09/10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³															   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum													   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ Nenhum													   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ReportDef()

Local cTitulo := STR0001 //"ESTADO DE CAMBIOS EN EL PATRIMONIO NETO"
Local cDescri := STR0002+Chr(10)+Chr(13)+STR0003 //"Este programa imprimira el Estado de Cambios en el Patrimonio Neto"##"Se imprimira de acuerdo con los Param. solicitados por el usuario."
Local bReport := { |oReport|	ReportPrint( oReport ) }

aSetOfBook:= CTBSetOf(mv_par04)

If ValType(mv_par08)=="N" .And. (mv_par08 == 1)
	cTitulo := CTBNomeVis( aSetOfBook[5] )
EndIf

oReport  := TReport():New(cProg, cTitulo, cPerg , bReport, cDescri,.T.,,.F.)
oReport:SetCustomText( {|| CustHeader(oReport, cTitulo, mv_par02, mv_par05) } )
oReport:ParamReadOnly()
oSection1:= TRSection():New(oReport  ,OemToAnsi(""),{"",""})
oSection2:= TRSection():New(oReport  ,OemToAnsi(""),{"",""})
//                         (oParent  ,cTitle,uTable,aOrder,lLoadCells,lLoadOrder,uTotalText,lTotalInLine,lHeaderPage,lHeaderBreak,lPageBreak,lLineBreak,nLeftMargin,lLineStyle,nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage)

oSection1:SetPageBreak(.F.)
oSection1:SetLineBreak(.F.)
oSection1:SetHeaderPage(.F.)
oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderSection(.F.)
oSection2:SetHeaderSection(.F.)

Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ ReportPrint³ Autor ³ Marcelo Akama		 ³ Data ³ 17/09/10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³															   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum													   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ Nenhum													   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)
Local x			:= 1
Local y			:= 1
Local cAlign
Local oFntReg
Local oFntBld

//mv_par01	"¿Fecha Inicial ?              "
//mv_par02	"¿Fecha Final ?                "
//mv_par03	"¿Orientacion de las cuentas ? "
//mv_par04	"¿Codigo Config Libros ?       "
//mv_par05	"¿Moneda ?                     "

//mv_par06	"¿Saldos igual a cero ?        "

//mv_par07	"¿Tipo de Saldo?               "
//mv_par08	"¿Tit como nombre de la vision?"

If (mv_par08 == 1)
	oReport:SetTitle( CTBNomeVis( aSetOfBook[5] ) )
EndIf  

If Empty(aSetOfBook[5])
	ApMsgAlert(STR0013) 
	Return .F.
Endif

aItems := CriaArray()

oFntReg := TFont():New(oReport:cFontBody,0,(oReport:nFontBody+2)*(-1),,.F.,,,,.F. /*Italic*/,.F. /*Underline*/)
oFntBld := TFont():New(oReport:cFontBody,0,(oReport:nFontBody+2)*(-1),,.T.,,,,.F. /*Italic*/,.F. /*Underline*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Crea la sección, el encabezado y el totalizador              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aItems) > 0
	For x:=1 To Len(aItems[1])
		nTam := 0
		cAlign := "LEFT"
		For y := 1 to Len(aItems)
			If ValType(aItems[y][x])=='N'
				cAlign := "RIGHT"
				If nTam < 35
					nTam := 35
				EndIf
			Else
				If nTam < Len(alltrim(aItems[y][x]))
					nTam := Len(alltrim(aItems[y][x]))
				EndIf
			EndIf
		Next y
		TRCell():New(oSection1,aItems[1][x],"",aItems[1][x],,nTam,.F.,,cAlign,.T.,cAlign,,,x>1/*AutoSize*/,CLR_WHITE,CLR_BLACK)
		oSection1:Cell(oSection1:aCell[x]:cName):SetValue(alltrim(aItems[1][x]))
		oSection1:Cell(oSection1:aCell[x]:cName):oFontBody := oFntBld
	Next x
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Elimina la primera línea para no imprimir de nuevo como item ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDel(aItems,1)
	aSize(aItems,Len(aItems)-1)
EndIf

//          (oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore) CLASS TRCell
TRCell():New(oSection2,"LEFT"    ,"","",,50,.F.,,"CENTER",,"CENTER",,,.T.)
TRCell():New(oSection2,"GERENTE" ,"","",,50,.F.,,"CENTER",,"CENTER")
TRCell():New(oSection2,"MID"     ,"","",,20,.F.,,"CENTER",,"CENTER")
TRCell():New(oSection2,"CONTADOR","","",,50,.F.,,"CENTER",,"CENTER")
TRCell():New(oSection2,"RIGHT"   ,"","",,50,.F.,,"CENTER",,"CENTER",,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa la impresión                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetMeter(Len(aItems))
oSection1:Init()

oSection1:PrintLine()

oReport:ThinLine()

For x:=1 To Len(aItems)
	If oReport:Cancel()
		x:=Len(aItems)
	EndIf

	For y:=1 To Len(aItems[x])
		If ValType(aItems[x][y])='N'
			oSection1:Cell(oSection1:aCell[y]:cName):SetValue( ValorCTB(aItems[x][y],,,14,02,.T.,"@E 999,999,999.99","1",,,,,,mv_par06==1,.F.) )
		Else
			oSection1:Cell(oSection1:aCell[y]:cName):SetValue(alltrim(aItems[x][y]))
		EndIf
		If x = Len(aItems) .Or. (mv_par03==2 .And. x = 1 .And. y = 1)
			oSection1:Cell(oSection1:aCell[y]:cName):oFontBody := oFntBld
		Else
			oSection1:Cell(oSection1:aCell[y]:cName):oFontBody := oFntReg
		EndIf
	Next y
	oSection1:PrintLine()
	If x=Len(aItems)-1
		oReport:ThinLine()
	EndIf
	oReport:IncMeter()
Next x     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprimir mensaje si no hay registros para imprimir           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aItems) == 0
	oReport:PrintText(STR0004)//"No hay datos por mostrarse"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza la sección de impresión                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:Finish()

oSection2:Cell("GERENTE"):SetValue(STR0011) // "GERENTE"
oSection2:Cell("GERENTE"):SetBorder("TOP")
oSection2:Cell("CONTADOR"):SetValue(STR0012) // "CONTADOR"
oSection2:Cell("CONTADOR"):SetBorder("TOP")
oReport:SkipLine(5)
oSection2:Init()
oSection2:PrintLine()
oSection2:Finish()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DataExtens³ Autor ³ Marcelo Akama         ³ Data ³ 21/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Devuelve la fecha larga									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DataExtens(dData)

Local aMeses := {STR0015, STR0016, STR0017, STR0018, STR0019, STR0020, STR0021, STR0022, STR0023, STR0024, STR0025, STR0026 } //Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre
Local cDia	 := Strzero(Day(dData),2)
Local nMes	 := Month(dData)
Local cAno	 := Alltrim(Str(Year(dData)))
Local cRet   := STR0027 + cDia + STR0028 + aMeses[nMes] + STR0029 + cAno // Saldo al ## de ## del

Return cRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ CriaArray³ Autor ³ Marcelo Akama			 ³ Data ³ 20/09/10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³															   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum                                                      ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ Nenhum                                                      ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CriaArray()        
Local aArea		:= GetArea()
Local aAreaCTS	:= CTS->(GetArea())
Local cAlias
Local nX
Local nY
Local nI
Local aCab
Local aRet
Local cMvPar01   := DTOS(mv_par01)
Local cMvPar02   := DTOS(mv_par02)

aCab := {}
dbSelectArea("CTS")
CTS->(DbSetOrder(1))
If CTS->(DbSeek(xFilial("CTS")+aSetOfBook[5]))
	Do While !CTS->(Eof())
		If CTS->CTS_CLASSE=='2' .And. AScan(aCab, {|x| x[1] == CTS->CTS_CONTAG}) == 0
			AADD(aCab, {CTS->CTS_CONTAG, CTS->CTS_DESCCG})
		EndIf
		CTS->(DbSkip())
	Enddo
EndIf

cAlias := GetNextAlias()

BeginSql Alias cAlias

    SELECT CTS_CONTAG, CT2_LP, SUM(VALOR) VALOR
    FROM ( 
        SELECT CTS.CTS_CONTAG, CT2.CT2_LP, CT2.CT2_VALOR*-1 VALOR 
        FROM %table:CTS% CTS 
        INNER JOIN %table:CT2% CT2 
        ON CT2.%NotDel%
        AND CT2.CT2_FILIAL = %xFilial:CT2% 
        AND CT2.CT2_DATA BETWEEN %exp:cMvPar01% AND %exp:cMvPar02% 
        AND CT2.CT2_MOEDLC = %exp:mv_par05% 
        AND CT2.CT2_TPSALD = %exp:mv_par07% 
        AND TRIM(CT2.CT2_LP) <> '' 
        AND CT2.CT2_DC IN ('1','3') 
        AND ( CT2.CT2_DEBITO BETWEEN CTS.CTS_CT1INI AND CTS.CTS_CT1FIM OR TRIM(CTS.CTS_CT1FIM) = '' ) 
        AND ( CT2.CT2_CCD    BETWEEN CTS.CTS_CTTINI AND CTS.CTS_CTTFIM OR TRIM(CTS.CTS_CTTFIM) = '' ) 
        AND ( CT2.CT2_ITEMD  BETWEEN CTS.CTS_CTDINI AND CTS.CTS_CTDFIM OR TRIM(CTS.CTS_CTDFIM) = '' ) 
        AND ( CT2.CT2_CLVLDB BETWEEN CTS.CTS_CTHINI AND CTS.CTS_CTHFIM OR TRIM(CTS.CTS_CTHFIM) = '' ) 
        WHERE CTS.%NotDel%
        AND CTS.CTS_FILIAL = %xFilial:CTS% 
        AND CTS.CTS_CODPLA = %exp:aSetOfBook[5]% 
        AND CTS.CTS_CLASSE = '2' 
        UNION ALL "
        SELECT CTS.CTS_CONTAG, CT2.CT2_LP, CT2.CT2_VALOR VALOR 
        FROM %table:CTS% CTS 
        INNER JOIN %table:CT2% CT2 
        ON CT2.%NotDel%
        AND CT2.CT2_FILIAL = %xFilial:CT2% 
        AND CT2.CT2_DATA BETWEEN %exp:cMvPar01% AND %exp:cMvPar02% 
        AND CT2.CT2_MOEDLC = %exp:mv_par05% 
        AND CT2.CT2_TPSALD = %exp:mv_par07% 
        AND TRIM(CT2.CT2_LP) <> '' 
        AND CT2.CT2_DC IN ('2','3') 
        AND ( CT2.CT2_CREDIT BETWEEN CTS.CTS_CT1INI AND CTS.CTS_CT1FIM OR TRIM(CTS.CTS_CT1FIM) = '' ) 
        AND ( CT2.CT2_CCC    BETWEEN CTS.CTS_CTTINI AND CTS.CTS_CTTFIM OR TRIM(CTS.CTS_CTTFIM) = '' ) 
        AND ( CT2.CT2_ITEMC  BETWEEN CTS.CTS_CTDINI AND CTS.CTS_CTDFIM OR TRIM(CTS.CTS_CTDFIM) = '' ) 
        AND ( CT2.CT2_CLVLCR BETWEEN CTS.CTS_CTHINI AND CTS.CTS_CTHFIM OR TRIM(CTS.CTS_CTHFIM) = '' ) 
        WHERE CTS.%NotDel%
        AND CTS.CTS_FILIAL = %xFilial:CTS% 
        AND CTS.CTS_CODPLA = %exp:aSetOfBook[5]% 
        AND CTS.CTS_CLASSE = '2' 
        UNION ALL "
        SELECT CTS.CTS_CONTAG, '' CT2_LP, COALESCE(CT2.CT2_VALOR,0)*-1 VALOR 
        FROM %table:CTS% CTS 
        LEFT OUTER JOIN %table:CT2% CT2 
        ON CT2.%NotDel%
        AND CT2.CT2_FILIAL = %xFilial:CT2% 
        AND CT2.CT2_DATA < %exp:cMvPar01%
        AND CT2.CT2_MOEDLC = %exp:mv_par05% 
        AND CT2.CT2_TPSALD = %exp:mv_par07% 
        AND TRIM(CT2.CT2_LP) <> '' 
        AND CT2.CT2_DC IN ('1','3') 
        AND ( CT2.CT2_DEBITO BETWEEN CTS.CTS_CT1INI AND CTS.CTS_CT1FIM OR TRIM(CTS.CTS_CT1FIM) = '' ) 
        AND ( CT2.CT2_CCD    BETWEEN CTS.CTS_CTTINI AND CTS.CTS_CTTFIM OR TRIM(CTS.CTS_CTTFIM) = '' ) 
        AND ( CT2.CT2_ITEMD  BETWEEN CTS.CTS_CTDINI AND CTS.CTS_CTDFIM OR TRIM(CTS.CTS_CTDFIM) = '' ) 
        AND ( CT2.CT2_CLVLDB BETWEEN CTS.CTS_CTHINI AND CTS.CTS_CTHFIM OR TRIM(CTS.CTS_CTHFIM) = '' ) 
        WHERE CTS.%NotDel%
        AND CTS.CTS_FILIAL = %xFilial:CTS% 
        AND CTS.CTS_CODPLA = %exp:aSetOfBook[5]% 
        AND CTS.CTS_CLASSE = '2' 
        UNION ALL 
        SELECT CTS.CTS_CONTAG, '' CT2_LP, COALESCE(CT2.CT2_VALOR,0) VALOR 
        FROM %table:CTS% CTS 
        LEFT OUTER JOIN %table:CT2% CT2 
        ON CT2.%NotDel%
        AND CT2.CT2_FILIAL = %xFilial:CT2% 
        AND CT2.CT2_DATA < %exp:cMvPar01% 
        AND CT2.CT2_MOEDLC = %exp:mv_par05% 
        AND CT2.CT2_TPSALD = %exp:mv_par07% 
        AND TRIM(CT2.CT2_LP) <> '' 
        AND CT2.CT2_DC IN ('2','3') 
        AND ( CT2.CT2_CREDIT BETWEEN CTS.CTS_CT1INI AND CTS.CTS_CT1FIM OR TRIM(CTS.CTS_CT1FIM) = '' ) 
        AND ( CT2.CT2_CCC    BETWEEN CTS.CTS_CTTINI AND CTS.CTS_CTTFIM OR TRIM(CTS.CTS_CTTFIM) = '' ) 
        AND ( CT2.CT2_ITEMC  BETWEEN CTS.CTS_CTDINI AND CTS.CTS_CTDFIM OR TRIM(CTS.CTS_CTDFIM) = '' ) 
        AND ( CT2.CT2_CLVLCR BETWEEN CTS.CTS_CTHINI AND CTS.CTS_CTHFIM OR TRIM(CTS.CTS_CTHFIM) = '' ) 
        WHERE CTS.%NotDel%
        AND CTS.CTS_FILIAL = %xFilial:CTS% 
        AND CTS.CTS_CODPLA = %exp:aSetOfBook[5]% 
        AND CTS.CTS_CLASSE = '2' 
    ) A 
    GROUP BY CT2_LP, CTS_CONTAG 
    ORDER BY CT2_LP, CTS_CONTAG 

EndSql

DbSelectArea(cAlias)
(cAlias)->(dbGoTop())
aRet := {}
If !(cAlias)->(Eof())
	Do While !(cAlias)->(Eof())
		nY := AScan(aRet, {|x| x[1] == (cAlias)->CT2_LP})
		If nY == 0
			AADD(aRet, Array( len(aCab) + 2 ))
			nY := Len(aRet)
			aRet[nY][1] := (cAlias)->CT2_LP
			For nX := 2 to Len(aRet[nY])
				aRet[nY][nX] := 0
			Next
		EndIf
		nX := AScan(aCab, {|x| x[1] == (cAlias)->CTS_CONTAG})
		If nX > 0
			aRet[nY][nX+1] += (cAlias)->VALOR
			aRet[nY][len(aRet[nY])] += (cAlias)->VALOR
		EndIf
		(cAlias)->(DbSkip())
	Enddo
	(cAlias)->(dbCloseArea())
	
	dbSelectArea("CT5")
	CT5->(DbSetOrder(1))
	aRet[1][1] := DataExtens(mv_par01-1)
	For nY:=2 to Len(aRet)
		If CT5->(DbSeek(xFilial("CT5")+aRet[nY][1]))
			aRet[nY][1] := CT5->CT5_DESC
		EndIf
	Next
	
	// Adiciona línea de Total
	AADD(aRet, Array( len(aCab) + 2 ))
	nY := Len(aRet)
	aRet[nY][1] := DataExtens(mv_par02)
	For nX := 2 to Len(aRet[nY])
		aRet[nY][nX] := 0
		For nI := 1 to nY-1
			aRet[nY][nX] += aRet[nI][nX]
		Next
	Next
	
	// Adiciona encabezado
	AADD(aRet, nil)
	AINS(aRet, 1)
	aRet[1] := Array( len(aCab) + 2 )
	For nX := 1 to Len(aCab)
		aRet[1][nX+1] := aCab[nX][2]
	Next
	aRet[1][1] := STR0007 // "Cuenta"
	aRet[1][len(aRet[1])] := STR0008 // "Total"
	
	If mv_par03==1
		aRet := PivotTable(aRet)
	EndIf
Else
	If Len(aCab) == 0
	ApMsgAlert(STR0014) 
	EndIf
EndIf

RestArea(aAreaCTS)
RestArea(aArea)

Return(aRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ CustHeader³ Autor ³ Marcelo Akama		 ³ Data ³ 22/09/10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³															   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum                                                      ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ Nenhum                                                      ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CustHeader(oReport, cTitulo, dData, cMoeda)
Local cNmEmp   
Local cChar		:= chr(160)  // carácter falso para la alineación del encabezado
Local cTitMoeda := Alltrim(GETMV("MV_MOEDAP"+Alltrim(Str(val(cMoeda)))))

DEFAULT dData    := cTod('  /  /  ')

If SM0->(Eof())                                
	SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
Endif

cNmEmp	:= AllTrim( SM0->M0_NOMECOM )

RptFolha := GetNewPar( "MV_CTBPAG" , RptFolha )

aCabec := {	"__LOGOEMP__" + "         " + cChar + "         " + cNmEmp + "         " + cChar + "         " + RptFolha+ TRANSFORM(oReport:Page(),'999999'),; 
			"SIGA /" + cProg + "/v." + cVersao + "         " + cChar + AllTrim(cTitulo) + "         " + cChar + RptDtRef + " " + DTOC(dDataBase),;
			RptHora + " " + time() + cChar + "         " + STR0009 + " " + DTOC(dData) + "         " + cChar + RptEmiss + " " + Dtoc(date()),;
			cChar + "         " + "(" + STR0010 + " " + cTitMoeda + ")" + "         " + cChar }

Return aCabec
