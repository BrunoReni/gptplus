#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC002H
Painel Gerencial de Filial - Informa��es sobre Faturas

Uso Restrito. 

Param:
aParam[1] := Data de
aParam[2] := Data ate
aParam[3] := Filial     

@sample
GFEC002H(aParam)

@author Alan Victor Lamb
@since 01/07/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC002H(aParam)   
	Local aCoors  := FWGetDialogSize(oMainWnd)
	Local cTitulo := 'Painel Gerencial - Filial'     
	
	Private oBrowsePF
	Private aGrfQtd, aGrfVal
	Private oGrfQtd, oGrfVal 
	Private cFil     := aParam[3]
	Private dDataDe  := If(Empty(aParam[1]),DDATABASE -30 ,aParam[1])
	Private dDataAte := If(Empty(aParam[2]),DDATABASE     ,aParam[2])                   
	
	aFiltros := {{"GW6","GW6_FILIAL","=",cFil},;   
				   {"GW6","GW6_DTEMIS",">=",Dtos(dDataDe)},;
				   {"GW6","GW6_DTEMIS","<=",Dtos(dDataAte)}}
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)
	oFWLayer:AddLine('LINE_TOP',50,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',50,.F.)
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_LEFT',50,.T.,'LINE_MIDDLE')
	oFWLayer:AddCollumn('COL_RIGHT',50,.T.,'LINE_MIDDLE')
    oFWLayer:AddWindow('COL_LEFT','WIN_LEFT','Faturas por Situa��o em Quantidade',100,.F.,.F.,,'LINE_MIDDLE',)
  	oFWLayer:AddWindow('COL_RIGHT','WIN_RIGHT','Faturas por Situa��o em Valor',100,.F.,.F.,,'LINE_MIDDLE',)
    
    oWIN_TOP   := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWIN_LEFT  := oFWLayer:GetWinPanel('COL_LEFT','WIN_LEFT','LINE_MIDDLE')
	oWIN_RIGHT := oFWLayer:GetWinPanel('COL_RIGHT','WIN_RIGHT','LINE_MIDDLE')
	
	oDLG:Activate(,,,.T.,,,{||Processa({||Iniciar()})})
Return 

Static Function GetSituacao()
	Local aSituacao := StrToKArr(Posicione("SX3",2,"GW6_SITAPR","X3_CBOX"),";")
	Local cRet := ""
	
	If !Empty(GW6->GW6_SITAPR) .AND.;
	   Val(GW6->GW6_SITAPR) > 0 .AND.;
	   Val(GW6->GW6_SITAPR) <= Len(aSituacao)
		cRet := SUBSTR(aSituacao[Val(GW6->GW6_SITAPR)],3)
	EndIf
Return cRet 

Static Function Iniciar()
	Local cBrowseFiltro
	cBrowseFiltro := "GW6_FILIAL == '" + cFil + "' .AND. "  
	cBrowseFiltro += "GW6_DTEMIS >= '" + DtoS(dDataDe) + "' .AND. GW6_DTEMIS <= '" + DtoS(dDataAte) + "'"
	
	CarregaDados(aFiltros)
	
	// Faturas de Frete
	oBrowsePF:= FWMBrowse():New()
	oBrowsePF:SetOwner(oWIN_TOP)
	oBrowsePF:SetAlias('GW6')
	oBrowsePF:SetDescription('Faturas de Frete')
	oBrowsePF:SetLocate()
	oBrowsePF:SetAmbiente(.F.)
	oBrowsePF:SetWalkthru(.F.)
	oBrowsePF:DisableDetails()
	oBrowsePF:SetMenuDef("")
	oBrowsePF:AddButton("Visualizar","VIEWDEF.GFEC070",,2)
	oBrowsePF:ForceQuitButton(.T.)
	oBrowsePF:SetFilterDefault(cBrowseFiltro)
	oBrowsePF:BVLDEXECFILTER := {|aParam| GFEC002HIV(aParam)}
	oBrowsePF:SetFields({{"Situa��o", {|| GetSituacao() }, "C","",1,10,0,.F.,,.F.,,,,.F.,.F.}})
	oBrowsePF:Activate()
	
	// Faturas por Situa��o em quantidade de registros 
    GFEC001GRC("oGrfQtd","Faturas em quantidade",oWIN_LEFT,aGrfQtd)
    
    // Faturas por Situa��o em valor
    GFEC001GRC("oGrfVal","Faturas em valor",oWIN_RIGHT,aGrfVal,"@E 999,999,999.99")
Return Nil

Static Function CarregaDados(aFiltros,cBrwFiltro)
	Local   cQuery      := ""
	Local   cTmp        := ""
	Default cBrwFiltro := ""
	
	aGrfVal := {}
	aGrfQtd := {}
	
	cQuery += "SELECT COUNT(CASE WHEN GW6_SITAPR = '1' THEN 1 END) QTD_SIT1,"
	cQuery += " 		COUNT(CASE WHEN GW6_SITAPR = '2' THEN 1 END) QTD_SIT2,"
	cQuery += " 		COUNT(CASE WHEN GW6_SITAPR = '3' THEN 1 END) QTD_SIT3,"
	cQuery += " 		COUNT(CASE WHEN GW6_SITAPR = '4' THEN 1 END) QTD_SIT4,"
	cQuery += " 		SUM(CASE WHEN GW6_SITAPR = '1' THEN GW6_VLFATU END) VAL_SIT1,"
	cQuery += " 		SUM(CASE WHEN GW6_SITAPR = '2' THEN GW6_VLFATU END) VAL_SIT2,"
	cQuery += " 		SUM(CASE WHEN GW6_SITAPR = '3' THEN GW6_VLFATU END) VAL_SIT3,"
	cQuery += " 		SUM(CASE WHEN GW6_SITAPR = '4' THEN GW6_VLFATU END) VAL_SIT4"
	cQuery += "   FROM " + RetSQLName("GW6") + " GW6"
	cQuery += "  WHERE GW6.D_E_L_E_T_ = ' '" + cBrwFiltro + CriaQueryCondicao(aFiltros,"")
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	If (cTmp)->(Recno()) > 0
		aADD(aGrfQtd, {"Recebida",(cTmp)->QTD_SIT1})
		aADD(aGrfQtd, {"Bloqueada",(cTmp)->QTD_SIT2})
		aADD(aGrfQtd, {"Aprovada Sistema",(cTmp)->QTD_SIT3})
		aADD(aGrfQtd, {"Aprovada Usuario",(cTmp)->QTD_SIT4})	
		aADD(aGrfVal, {"Recebida",(cTmp)->VAL_SIT1})
		aADD(aGrfVal, {"Bloqueada",(cTmp)->VAL_SIT2})
		aADD(aGrfVal, {"Aprovada Sistema",(cTmp)->VAL_SIT3})
		aADD(aGrfVal, {"Aprovada Usuario",(cTmp)->VAL_SIT4})
	EndIf
	
	(cTmp)->(dbCloseArea())
Return Nil

//=========================================================================/ 
// Aplica o filtro do browse na consulta SQL
//=========================================================================/
Function GFEC002HIV(aParam) 
	Local nCont 
	Local cFiltro := ""
	
	For nCont := 1 to Len(aParam)
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
