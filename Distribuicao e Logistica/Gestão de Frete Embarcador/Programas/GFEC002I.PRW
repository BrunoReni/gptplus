#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC002I
Painel Gerencial de Filiais - Informa��es sobre Contratos

Uso Restrito. 

Param:
aParam[1] := Data de
aParam[2] := Data ate
aParam[3] := Filial     

@sample
GFEC002I(aParam)

@author Alan Victor Lamb
@since 01/07/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC002I(aParam)   
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local cTitulo := 'Painel Gerencial - Filial'     
	
	Private oBrowsePF
	Private aGrfQtd, aGrfVal
	Private oGrfQtd, oGrfVal
	Private cFil  := aParam[3]
	Private dDataDe  := If(Empty(aParam[1]),DDATABASE -30 ,aParam[1])
	Private dDataAte := If(Empty(aParam[2]),DDATABASE     ,aParam[2])                   
	
	aFiltros := {{"GW2","GW2_FILIAL","=",cFil},;   
				   {"GW2","GW2_DTCRIA",">=",Dtos(dDataDe)},;
				   {"GW2","GW2_DTCRIA","<=",Dtos(dDataAte)}}
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)
	oFWLayer:AddLine('LINE_TOP',50,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',50,.F.)
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_LEFT',50,.T.,'LINE_MIDDLE')
	oFWLayer:AddCollumn('COL_RIGHT',50,.T.,'LINE_MIDDLE')
    oFWLayer:AddWindow('COL_LEFT','WIN_LEFT','Contratos por Situa��o em Quantidade',100,.F.,.F.,,'LINE_MIDDLE',)
  	oFWLayer:AddWindow('COL_RIGHT','WIN_RIGHT','Contratos por Situa��o em Valor',100,.F.,.F.,,'LINE_MIDDLE',)
    
    oWIN_TOP   := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWIN_LEFT  := oFWLayer:GetWinPanel('COL_LEFT','WIN_LEFT','LINE_MIDDLE')
	oWIN_RIGHT := oFWLayer:GetWinPanel('COL_RIGHT','WIN_RIGHT','LINE_MIDDLE')
	
	oDLG:Activate(,,,.T.,,,{||Processa({||Iniciar()})})
Return

Static Function Iniciar()
	Local cBrowseFiltro
	cBrowseFiltro := "GW2_FILIAL == '" + cFil + "' .AND. "
	cBrowseFiltro += "GW2_DTCRIA >= '" + DtoS(dDataDe) + "' .AND. GW2_DTCRIA <= '" + DtoS(dDataAte) + "'"
	
	CarregaDados(aFiltros)
	
	// Faturas de Frete
	oBrowsePF:= FWMBrowse():New()
	oBrowsePF:SetOwner(oWIN_TOP)
	oBrowsePF:SetAlias('GW2')
	oBrowsePF:SetDescription("Contratos com aut�nomos")
	oBrowsePF:SetLocate()
	oBrowsePF:SetAmbiente(.F.)
	oBrowsePF:SetWalkthru(.F.)
	oBrowsePF:DisableDetails()
	oBrowsePF:SetMenuDef("")
	oBrowsePF:AddButton("Visualizar","VIEWDEF.GFEC100",,2)
	oBrowsePF:ForceQuitButton(.T.)
	oBrowsePF:SetFilterDefault(cBrowseFiltro)
	oBrowsePF:BVLDEXECFILTER := {|aParam| GFEC002IIV(aParam)}
	oBrowsePF:Activate()
	
	// Contratos por Situa��o em quantidade de registros 
    GFEC001GRC("oGrfQtd","Contratos em quantidade",oWIN_LEFT,aGrfQtd)
    
    // Contratos por Situa��o em valor
    GFEC001GRC("oGrfVal","Contratos em valor",oWIN_RIGHT,aGrfVal,"@E 999,999,999.99")
Return Nil

Static Function CarregaDados(aFiltros,cBrwFiltro)
	Local   cQuery      := ""
	Local   cTmp        := ""
	Default cBrwFiltro := ""
	
	aGrfVal := {}
	aGrfQtd := {}
	
	cQuery += "SELECT COUNT(CASE WHEN GW2.GW2_SITCON = '1' THEN 1 END) QTD_SIT1, "
	cQuery += "		COUNT(CASE WHEN GW2.GW2_SITCON = '2' THEN 1 END) QTD_SIT2, "
	cQuery += "       COUNT(CASE WHEN GW2.GW2_SITCON = '3' THEN 1 END) QTD_SIT3, "
	cQuery += "       COUNT(CASE WHEN GW2.GW2_SITCON = '4' THEN 1 END) QTD_SIT4, "
	cQuery += "       SUM(CASE WHEN GW2.GW2_SITCON = '2' THEN GW2_VLFRET + GW2_VLADIC - GW2_VLDESC + GW2_VLINEM END) VAL_SIT2, "
	cQuery += "       SUM(CASE WHEN GW2.GW2_SITCON = '3' THEN GW2_VLFRET + GW2_VLADIC - GW2_VLDESC + GW2_VLINEM END) VAL_SIT3, "
	cQuery += "       SUM(CASE WHEN GW2.GW2_SITCON = '4' THEN GW2_VLFRET + GW2_VLADIC - GW2_VLDESC + GW2_VLINEM END) VAL_SIT4 "
	cQuery += "  FROM " + RetSQLName("GW2") + " GW2 "
	cQuery += " WHERE GW2.D_E_L_E_T_ = ' ' " + cBrwFiltro + CriaQueryCondicao(aFiltros,"")
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	If (cTmp)->(Recno()) > 0
		aADD(aGrfQtd, {"Criado",(cTmp)->QTD_SIT1})
		aADD(aGrfQtd, {"Confirmado",(cTmp)->QTD_SIT2})
		aADD(aGrfQtd, {"Emitido",(cTmp)->QTD_SIT3})
		aADD(aGrfQtd, {"Cancelado",(cTmp)->QTD_SIT4})
		aADD(aGrfVal, {"Confirmado",(cTmp)->VAL_SIT2})
		aADD(aGrfVal, {"Emitido",(cTmp)->VAL_SIT3})
		aADD(aGrfVal, {"Cancelado",(cTmp)->VAL_SIT4})
	EndIf
	
	(cTmp)->(dbCloseArea())
Return Nil

//=========================================================================/ 
// Aplica o filtro do browse na consulta SQL
//=========================================================================/
Function GFEC002IIV(aParam) 
	Local nCont 
	Local cFiltro := ""
	
	For nCont := 1 To Len(aParam)
		If !aParam[nCont][5]
	       	If !Empty(cFiltro)
	       		cFiltro := cFiltro + " AND (" +  aParam[nCont][3] + ")"
	       	Else
	       	    cFiltro := " AND (" +  aParam[nCont][3] + ")"
	       	Endif
		EndIf
	Next nCont	
	
	Processa({||Atualiza(cFiltro)})
Return .T.   

Static Function Atualiza(cFiltro)
	CarregaDados(aFiltros,cFiltro)
	GFEC001GRA(oGrfQtd,.T.,aGrfQtd)
	GFEC001GRA(oGrfVal,.T.,aGrfVal)
Return Nil      
