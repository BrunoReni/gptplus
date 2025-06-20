#INCLUDE "TOTVS.CH"
#INCLUDE "REPORT.CH"

/*/{Protheus.doc} TafRelMig
Relat�rio de Erros de Inconsist�ncias no processo de
Migra��o.
@type  Static Function
@author Diego Santos
@since 25-10-2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
/*/
Function TafRelMigr( oPanel, aErros )

Local oReport
Local lProcessa := .T.

If !TRepInUse()
    Alert("A impress�o em TREPORT dever� estar habilitada. Favor verificar o par�metro MV_TREPORT.")
    lProcessa := .F.
EndIf

If lProcessa
    oReport:=ReportDef( aErros )
    oReport:PrintDialog()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Instacia a classe TReport e monta a section 

@author Diego Santos
@since 19/08/2018/
@version 1.0 

@aParam

@return Nil
/*/
//-------------------------------------------------------------------

Static Function ReportDef( aErros )

Local oReport   

oReport 	:= TReport():New("TAFRELMIGR", "Relat�rio de inconsist�ncias de migra��o TAF", "TAFRELMIGR", {|oReport| PrintReport(@oReport, aErros)},"Inconsist�ncias de Migra��o TAF",.T.,,,,,,,,,.T.)
oSection    := TRSection():New(oReport,"Relat�rio de inconsist�ncias de migra��o",{""},{""})
    
oReport:SetDevice(4) //Impress�o em Tabela Excel

TRCell():New(oSection,"FILREG"   ,	"", "Filial do Registro", /*Picture*/,TamSx3("V2I_FILREG")[1]   ,	/*lPixel*/, { || cFilReg        }  ) // -> Filial do Registro
TRCell():New(oSection,"EVENTO"   ,	"", "Evento E-Social"   , /*Picture*/,006                       ,	/*lPixel*/, { || cEvento        }  ) // -> C�digo do Evento
TRCell():New(oSection,"CHAVE"    ,	"", "Chave TAF x TSS"   , /*Picture*/,055                       ,	/*lPixel*/, { || cChave         }  ) // -> Evento
TRCell():New(oSection,"CODERR"   ,	"", "C�digo do Erro"    , /*Picture*/,006                       ,	/*lPixel*/, { || cCodErr        }  ) // -> C�digo do Erro
TRCell():New(oSection,"DESCERR"  ,	"", "Descri��o do Erro" , /*Picture*/,255                       ,	/*lPixel*/, { || cDescErr       }  ) // -> Descri��o do Erro
TRCell():New(oSection,"TABTAF"   ,	"", "Tabela TAF"        , /*Picture*/,003                       ,	/*lPixel*/, { || cTabTAF        }  ) // -> Tabela TAF

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Rotina para realizar a impressao do relat�rio.

@author Diego Santos
@since 19/08/2018/
@version 1.0 

@aParam

@return Nil
/*/
//-------------------------------------------------------------------

Static Function PrintReport( oReport, aErros )

Local cQry      := ""
Local cAlsQry   := GetNextAlias()
Local aArea     := GetArea()

Local nY
Local aFilsLog :=  {}
Local cEmp      := ""


cEmp := FWCodEmp() 
aFilsLog := FWAllFilial(cEmp,,,.F.)

cQry += "SELECT V2I.R_E_C_N_O_ AS RECV2I "
cQry += "FROM " + RetSqlName("V2I") + " V2I " 
cQry += "WHERE "
cQry += "V2I.V2I_FILIAL		= '"+ xFilial('V2I') + "' AND " // -> Se a V2I for compartilhada por empresa, haver� erro no relat�rio.
cQry += "V2I.V2I_CODERR		<> ' ' AND "
cQry += "V2I.D_E_L_E_T_     =  ' ' AND "
cQry += "V2I.V2I_FILREG IN "+FormatIn(ArrayToStr(aFilsLog),";")+ "  "  // -> Retorna todas as filiais conforme a empresa informada (cEmp).
cQry += "ORDER BY V2I.V2I_FILIAL, V2I.V2I_FILREG, V2I.V2I_EVENTO, V2I.V2I_ID, V2I.V2I_VERSAO "

oReport:SetTitle("Inconsist�ncias de Migra��o")

oReport:Section(1):SetHeaderSection(.T.)

DBUseArea(.T.,"TopConn",TCGenQry(,,cQry),cAlsQry)

oReport:SetMeter((cAlsQry)->(RecCount()) + Len(aErros))

oReport:Section(1):Init()
oReport:IncMeter()

oReport:SkipLine()


For nY := 1 To Len(aErros)

    cFilReg     := aErros[nY][1]
    cEvento     := aErros[nY][2]
    cChave      := aErros[nY][3]
    cCodErr     := aErros[nY][4]
    cDescErr    := aErros[nY][5]
    cTabTAF     := aErros[nY][6]

Next nY 

While (cAlsQry)->(!Eof())

    V2I->(DbGoTo( (cAlsQry)->RECV2I ) )
    
    cFilReg     := V2I->V2I_FILREG
    cEvento     := V2I->V2I_EVENTO
    cChave      := AllTrim(StrTran(V2I->V2I_EVENTO, "-", "")) + AllTrim(V2I->V2I_ID) + AllTrim(V2I->V2I_VERSAO)
    cCodErr     := V2I->V2I_CODERR
    cDescErr    := V2I->V2I_OBS
    cTabTAF     := V2I->V2I_TABTAF

    oReport:Section(1):PrintLine()

    (cAlsQry)->(DbSkip())

End

(cAlsQry)->(DbCloseArea())

RestArea(aArea)

Return
