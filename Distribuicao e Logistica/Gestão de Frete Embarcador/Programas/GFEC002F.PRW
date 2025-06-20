#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC002F
Painel Gerencial de Filial - Informa��es sobre Documentos de Frete

Uso Restrito. 

Param:
aParam[1] := Data de
aParam[2] := Data ate
aParam[3] := Filial     

@sample
GFEC002F(aParam)

@author Alan Victor Lamb
@since 01/07/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC002F(aParam)   
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local cTitulo := 'Painel Gerencial - Filial'     
	
	Private oBrowseDF
	Private aGrfQtd, aGrfVal
	Private oGrfQtd, oGrfVal 
	Private cFil  := aParam[3]
	Private dDataDe  := If(Empty(aParam[1]),DDATABASE -30 ,aParam[1])
	Private dDataAte := If(Empty(aParam[2]),DDATABASE     ,aParam[2])                   
	
	aFiltros := {{"GW3","GW3_FILIAL","=",cFil},;
				   {"GW3","GW3_DTENT",">=",Dtos(dDataDe)},;
				   {"GW3","GW3_DTENT","<=",Dtos(dDataAte)}}
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)
	oFWLayer:AddLine('LINE_TOP',50,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',50,.F.)
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_LEFT',50,.T.,'LINE_MIDDLE')
	oFWLayer:AddCollumn('COL_RIGHT',50,.T.,'LINE_MIDDLE')
    oFWLayer:AddWindow('COL_LEFT','WIN_LEFT','Documentos de Frete por Situa��o em Quantidade',100,.F.,.F.,,'LINE_MIDDLE',)
  	oFWLayer:AddWindow('COL_RIGHT','WIN_RIGHT','Documentos de Frete por Situa��o em Valor',100,.F.,.F.,,'LINE_MIDDLE',)
    
    oWIN_TOP   := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWIN_LEFT  := oFWLayer:GetWinPanel('COL_LEFT','WIN_LEFT','LINE_MIDDLE')
	oWIN_RIGHT := oFWLayer:GetWinPanel('COL_RIGHT','WIN_RIGHT','LINE_MIDDLE')
	
	oDLG:Activate(,,,.T.,,,{||Processa({||Iniciar()})})
Return 

Static Function GetSituacao()
	Local aSituacao := StrToKArr(Posicione("SX3",2,"GW3_SIT","X3_CBOX"),";")
	Local cRet := ""
	
	If !Empty(GW3->GW3_SIT) .AND.;
	   Val(GW3->GW3_SIT) > 0 .AND.;
	   Val(GW3->GW3_SIT) <= Len(aSituacao)
		cRet := SUBSTR(aSituacao[Val(GW3->GW3_SIT)],3)
	EndIf
Return cRet 

Static Function Iniciar()
	Local cBrowseFiltro  
	
	cBrowseFiltro := "GW3_FILIAL == '" + cFil + "' .AND. "  
	cBrowseFiltro += "GW3_DTENT >= '" + DtoS(dDataDe) + "' .AND. GW3_DTENT <= '" + DtoS(dDataAte) + "'"
		
	CarregaDados(aFiltros)
	
	// Documentos de Frete
	oBrowseDF:= FWMBrowse():New()
	oBrowseDF:SetOwner(oWIN_TOP)
	oBrowseDF:SetAlias('GW3')
	oBrowseDF:SetDescription("Documentos de Frete")
	oBrowseDF:SetLocate()
	oBrowseDF:SetAmbiente(.F.)
	oBrowseDF:SetWalkthru(.F.)
	oBrowseDF:DisableDetails()
	oBrowseDF:SetMenuDef("")
	oBrowseDF:AddButton("Visualizar","VIEWDEF.GFEC065",,2)
	oBrowseDF:ForceQuitButton(.T.)
	oBrowseDF:SetFilterDefault(cBrowseFiltro)
	oBrowseDF:BVLDEXECFILTER := {|aParam| GFEC002FV(aParam)}
	oBrowseDF:SetFields({{"Situa��o", {|| GetSituacao() }, "C","",1,10,0,.F.}})
	oBrowseDF:Activate()
	
	// Documentos de Frete por Situa��o de Aprova��o em quantidade de registros 
   	GFEC001GRC("oGrfQtd","Doc Frete Quantidade",oWIN_LEFT,aGrfQtd)
    
    // Documentos de Frete por Situa��o de Aprova��o em valor dos documentos
    GFEC001GRC("oGrfVal","Doc Frete Valor",oWIN_RIGHT,aGrfVal,"@E 999,999,999.99")
Return Nil

Static Function CarregaDados(aFiltros,cBrwFiltro)
	Local cQuery := ''
	Local cTmp   := ''
	Default cBrwFiltro := ''
		
	cQuery += "SELECT SUM(CASE WHEN GW3_SIT = '1' THEN GW3_VLDF ELSE 0 END) VAL_SIT1,"
	cQuery += "	       COUNT(CASE WHEN GW3_SIT = '1' THEN 1 END) QTD_SIT1,"
	cQuery += "	       SUM(CASE WHEN GW3_SIT = '2' THEN GW3_VLDF ELSE 0 END) VAL_SIT2,"
	cQuery += "	       COUNT(CASE WHEN GW3_SIT = '2' THEN 1 END) QTD_SIT2,"
	cQuery += "	       SUM(CASE WHEN GW3_SIT = '3' THEN GW3_VLDF ELSE 0 END) VAL_SIT3,"
	cQuery += "	       COUNT(CASE WHEN GW3_SIT = '3' THEN 1 END) QTD_SIT3,"
	cQuery += "	       SUM(CASE WHEN GW3_SIT = '4' THEN GW3_VLDF ELSE 0 END) VAL_SIT4,"
	cQuery += "	       COUNT(CASE WHEN GW3_SIT = '4' THEN 1 END) QTD_SIT4,"
	cQuery += "	       SUM(CASE WHEN GW3_SIT = '5' THEN GW3_VLDF ELSE 0 END) VAL_SIT5,"
	cQuery += "	       COUNT(CASE WHEN GW3_SIT = '5' THEN 1 END) QTD_SIT5"
	cQuery += "	  FROM " + RetSQLName("GW3") + " GW3"
	cQuery += "	 WHERE GW3.D_E_L_E_T_ = ' ' " + cBrwFiltro + CriaQueryCondicao(aFiltros,"")
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	aGrfVal := {}
	aGrfQtd := {}
	
	If (cTmp)->(Recno()) > 0
		aADD(aGrfVal, {"Recebido",(cTmp)->VAL_SIT1})
		aADD(aGrfVal, {"Bloqueado",(cTmp)->VAL_SIT2})
		aADD(aGrfVal, {"Aprov.Sistema",(cTmp)->VAL_SIT3})
		aADD(aGrfVal, {"Aprov.Usuario",(cTmp)->VAL_SIT4})
		aADD(aGrfVal, {"Bloqueado por Entrega",(cTmp)->VAL_SIT5})
		aADD(aGrfQtd, {"Recebido",(cTmp)->QTD_SIT1})
		aADD(aGrfQtd, {"Bloqueado",(cTmp)->QTD_SIT2})
		aADD(aGrfQtd, {"Aprov.Sistema",(cTmp)->QTD_SIT3})
		aADD(aGrfQtd, {"Aprov.Usuario",(cTmp)->QTD_SIT4})
		aADD(aGrfQtd, {"Bloqueado por Entrega",(cTmp)->QTD_SIT5})
	EndIf
	
	(cTmp)->(dbCloseArea())
Return Nil

//=========================================================================/ 
// Aplica o filtro do browse na consulta SQL
//=========================================================================/
Function GFEC002FV(aParam) 
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
