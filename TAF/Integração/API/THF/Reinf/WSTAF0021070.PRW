#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE R1070 1,1

Function WS0021070(aApurac, oEstruct, oValidationError)

local cTpProc       as character
local nTSintetic    as numeric

default oValidationError["registryKey"] = {}

cTpProc     := ""
nTSintetic 	:= 0

While (aApurac[R1070])->(!eof())

    aadd(oEstruct["eventDetail"],JsonObject():New())  
    nTSintetic := len(oEstruct["eventDetail"])

    If (aApurac[R1070])->TPPROC == "1"
        cTpProc := "Judicial"
    ElseIf (aApurac[R1070])->TPPROC == "2"
        cTpProc := "Administrativo"
    ElseIf (aApurac[R1070])->TPPROC == "3"
        cTpProc := "N�mero do benef�cio (NB) do INSS"
    ElseIf (aApurac[R1070])->TPPROC == "4"
        cTpProc := "Processo FAP"
    EndIf

    // C�digo da filial
    oEstruct["eventDetail"][nTSintetic]["branchId"]                 := (aApurac[R1070])->FILIAL

    // Tipo de processo
    oEstruct["eventDetail"][nTSintetic]["proccesType"]              := alltrim(EncodeUTF8(cTpProc))

    // RN�mero do processo
    oEstruct["eventDetail"][nTSintetic]["proccesNumber"]            := (aApurac[R1070])->NUMPROC

    // UF Vara
    oEstruct["eventDetail"][nTSintetic]["courtFederatedUnit"]       := alltrim(EncodeUTF8((aApurac[R1070])->DESCUFVARA))

    // Munic�pio
    oEstruct["eventDetail"][nTSintetic]["cityCode"]                 := (aApurac[R1070])->CODMUN + " - " + alltrim(EncodeUTF8((aApurac[R1070])->DESCMUN))

    //C�digo munic�pio
    oEstruct["eventDetail"][nTSintetic]["courtId"]                  := (aApurac[R1070])->IDMUN 

    // Data ini
    oEstruct["eventDetail"][nTSintetic]["beginingDate"]   	        := (aApurac[R1070])->DTINI

    // Data fim
    oEstruct["eventDetail"][nTSintetic]["finishingDate"]   	        := (aApurac[R1070])->DTFIM

    // Status
    oEstruct["eventDetail"][nTSintetic]["status"]   	            := Iif(Empty((aApurac[R1070])->STATUS), 'notValidated', 'validated')

    //Id de apura��o
    oEstruct["eventDetail"][nTSintetic]["key"]                      := (aApurac[R1070])->NUMPROC

    //Propriedade errors que habilita o icone no frontend
    oEstruct["eventDetail"][nTSintetic]['errors']                   := 'errors'

    If Len(oValidationError["registryKey"]) > 0
        // Chave de busca do erro da apura��o
        oEstruct["eventDetail"][nTSintetic]["keyValidationErrors"]  := KeyError(oEstruct["eventDetail"][nTSintetic], oValidationError)
    EndIf

    (aApurac[R1070])->(dbSkip())
EndDo

return oEstruct

Function WS002D1070(aApurac, oEstruct)

local nTAnalytic  as numeric

nTAnalytic :=  0 

(aApurac[R1070])->(dbGoTop())

While !(aApurac[R1070])->(eof())

    aAdd( oEstruct["invoices"],JsonObject():New())
    nTAnalytic   :=  len(oEstruct["invoices"])
    
    //C�digo da suspens�o
    oEstruct["invoices"][nTAnalytic]["suspensionCode"]          :=  (aApurac[R1070])->CODSUSP
    
    //Indicativo da suspens�o
    oEstruct["invoices"][nTAnalytic]["suspensionIndicator"]     :=  alltrim(EncodeUTF8((aApurac[R1070])->INDICSUSP))
    
    //Data da decis�o
    oEstruct["invoices"][nTAnalytic]["decisionDate"]            :=  SToD((aApurac[R1070])->DECISIONDATE)
    
    //Indicativo de dep�sito        
    oEstruct["invoices"][nTAnalytic]["depositIndicator"]        :=  (aApurac[R1070])->DEPINDICATOR  

    (aApurac[R1070])->(DbSkip()) 
EndDo

return oEstruct

Function WSQry1070(aFil, nView, cNumProc)
    
    local cAlias1070    as character
    Local cSelect		as character
    Local cFrom			as character
    Local cWhere		as character
    Local cOrder        as character
    Local cFiliais      as character
    local aRet          as array

    cAlias1070  := getNextAlias()
    cSelect     := ""
    cFrom	    := ""
    cWhere      := ""
    cOrder      := ""
    cFiliais    := RetFil(aFil)
    aRet        := {}

    if nView == 1
        cSelect += " DISTINCT C1G_FILIAL AS FILIAL, C1G_TPPROC AS TPPROC, C1G_NUMPRO AS NUMPROC, "
        cSelect += " C1G_DTINI AS DTINI, C1G_DTFIN AS DTFIM, C1G_UFVARA AS CODUFVARA, "
        cSelect += " C1G_CODMUN AS IDMUN, C1G_VARA AS VARA, C07_CODIGO AS CODMUN, "
        cSelect += " C07_DESCRI AS DESCMUN, C09_UF AS UFVARA, C09_DESCRI AS DESCUFVARA, "
        cSelect += " CASE "
        cSelect += " WHEN C1G.C1G_PROCID <> ' ' THEN '3' "
        cSelect += " WHEN C1G.C1G_PROCID = ' ' THEN ' ' "
        cSelect += " END AS STATUS "
    ElseIf nView == 2
        cSelect += " DISTINCT T5L_CODSUS AS CODSUSP, T5L_DTDEC AS DECISIONDATE, "
        cSelect += " T5L_INDDEP AS DEPINDICATOR, C8S_DESCRI AS INDICSUSP "
    EndIf
    
    cFrom		:= RetSqlName( "C1G" ) + " C1G "

    if nView == 1
        cFrom		+= " LEFT JOIN " + RetSqlName( "C09" ) + " C09 ON "
        cFrom		+= " C09.C09_ID = C1G.C1G_UFVARA "
        cFrom		+= " AND C09.C09_FILIAL = '" + xFilial( "C09" ) + "' "
        cFrom		+= " AND C09.D_E_L_E_T_ = ' ' "
        
        cFrom		+= " LEFT JOIN  " + RetSqlName( "C07" ) + " C07 ON "
        cFrom		+= " C07.C07_ID = C1G.C1G_CODMUN "
        cFrom		+= " AND C07.C07_FILIAL = '" + xFilial( "C07" ) + "' "
        cFrom		+= " AND C07.D_E_L_E_T_ = ' ' "
    ElseIf nView == 2
        cFrom		+= " INNER JOIN " + RetSqlName( "T5L" ) + " T5L ON "
        cFrom		+= " T5L.T5L_ID = C1G.C1G_ID "
        cFrom		+= " AND T5L.T5L_VERSAO = C1G.C1G_VERSAO "
        cFrom		+= " AND T5L.T5L_FILIAL = C1G.C1G_FILIAL "
        cFrom		+= " AND T5L.D_E_L_E_T_ = ' '"

        cFrom		+= " LEFT JOIN " + RetSqlName( "C8S" ) + " C8S ON "
        cFrom		+= " C8S.C8S_ID = T5L.T5L_INDDEC "
        cFrom		+= " AND C8S.C8S_FILIAL = '" + xFilial( "C8S" ) + "' "
        cFrom		+= " AND C8S.D_E_L_E_T_ = ' ' "
    EndIf
	
	cWhere		:= " C1G.C1G_ATIVO IN (' ', '1') AND C1G.D_E_L_E_T_ = ' ' "
	If !Empty( xFilial("C1G") )
		cWhere		+= " AND C1G.C1G_FILIAL IN (" + cFiliais + ") "
    EndIf
    
    cWhere		+= " AND C1G.C1G_ESOCIA = '' "
    
    If nView == 2 .And. !Empty(cNumProc)
        cWhere    += " AND C1G_NUMPRO = '" + cNumProc + "' " 
    EndIf

    cOrder += " ORDER BY 1, 2, 3, 4"

    cSelect	:= "%" + cSelect 	+ "%"
	cFrom  	:= "%" + cFrom   	+ "%" 
    cWhere 	:= "%" + cWhere  	+ "%"
    cOrder  := "%" + cOrder     + "%"

	BeginSql Alias cAlias1070
		SELECT %Exp:cSelect% FROM %Exp:cFrom% WHERE %EXP:cWhere%
	EndSql

    aAdd(aRet, { cAlias1070 })
return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetFil()

Trata o array de filiais passado pela tela da apuração
para que fique no formato de execução do IN no SQL

@author Henrique Pereira
@since 08/03/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function RetFil(aFil)
	Local cRetFils	as Character
	Local nX		as Numeric

	cRetFils	:= ""
	nX			:= 0

	If !Empty(xFilial("C1G")) .And. Len(aFil) > 0
	
        For nX := 1 to Len(aFil)
            If nX > 1
                cRetFils += " , '" + xFilial("C1G", aFil[nX][2]) + "'"
            Else
                cRetFils += "'" + xFilial("C1G", aFil[nX][2]) + "'"
            EndIf
        Next nX
    Else
        cRetFils := "'" + xFilial("C1G") + "'"
    EndIf

Return cRetFils

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} KeyError
Fun��o respons�vel por retornar o procid da tabela de log que cont�m o motivo do erro da apura��o

@author Leticia Campos
@since 30/07/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function KeyError(oEstruct, oValidationError)
    local cKeyError as character
    local nX        as numeric

    cKeyError       := ""
    nX              := 1

    For nX := 1 to Len(oValidationError["registryKey"])
        if alltrim(oValidationError["registryKey"][nX]["id"]) == alltrim(oEstruct["key"])
            cKeyError := oValidationError["registryKey"][nX]["error"]
        endif
    Next nX

return ( cKeyError )
