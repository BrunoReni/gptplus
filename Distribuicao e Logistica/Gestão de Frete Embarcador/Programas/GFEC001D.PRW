#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC001D
Painel Gerencial - Informa��es sobre o Agendamentos de Coleta/Entrega

Uso Restrito. 

Param:
aParam[1] := Filial de
aParam[2] := Filial ate
aParam[3] := Data de
aParam[4] := Data ate
aParam[5] := Codigo do Emitente     

@sample
GFEC001D(aParam)

@author Felipe Mendes / Alan Victor Lamb
@since 05/05/12
@version 1.0
---------------------------------------------------------------------------------------------------/*/  
Function GFEC001D(aParam)   
	Local aCoors  := FWGetDialogSize(oMainWnd)
	Local cTitulo := 'Painel Gerencial - Transportador'     
	
	Private oBrowseAge, oBrowseEst
	Private aDados, aFiltros, aBrowse
	Private oGrfSit
	Private cFilialDe  := aParam[1]
	Private cFilialAte := aParam[2]
	Private dDataDe  := If(Empty(aParam[3]),DDATABASE -30 ,aParam[3])
	Private dDataAte := If(Empty(aParam[4]),DDATABASE     ,aParam[4])                   
	Private cCodEmit := aParam[5]
	
	aFiltros := {{"GWV","GWV_CDEMIT","=" ,cCodEmit},;
				   {"GWV","GWV_FILIAL",">=",cFilialDe},;
				   {"GWV","GWV_FILIAL","<=",cFilialAte},;   
				   {"GWV","GWV_DTAGEN",">=",Dtos(dDataDe)},;
				   {"GWV","GWV_DTAGEN","<=",Dtos(dDataAte)}}  
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)
	oFWLayer:AddLine('LINE_TOP',50,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',50,.F.)
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_LEFT',40,.T.,'LINE_MIDDLE')
	oFWLayer:AddCollumn('COL_RIGHT',60,.T.,'LINE_MIDDLE')
    oFWLayer:AddWindow('COL_LEFT','WIN_LEFT','Estat�sticas',100,.F.,.F.,,'LINE_MIDDLE',)
  	oFWLayer:AddWindow('COL_RIGHT','WIN_RIGHT','Gr�fico',100,.F.,.F.,,'LINE_MIDDLE',)
    
    oWIN_TOP   := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWIN_LEFT  := oFWLayer:GetWinPanel('COL_LEFT','WIN_LEFT','LINE_MIDDLE')
	oWIN_RIGHT := oFWLayer:GetWinPanel('COL_RIGHT','WIN_RIGHT','LINE_MIDDLE')
	
	oDLG:Activate(,,,.T.,,,{||Processa({||Iniciar()})})
Return 

Static Function Iniciar()
	Local cBrowseFiltro  
	
	//Filtro do Browse
	cBrowseFiltro := "GWV_CDEMIT == '" + cCodEmit         + "' .AND. "  
	cBrowseFiltro += "GWV_FILIAL >= '" + cFilialDe        + "' .AND. GWV_FILIAL <= '" + cFilialAte     + "' .AND. "  
	cBrowseFiltro += "GWV_DTAGEN >= '" + DtoS(dDataDe)    + "' .AND. GWV_DTAGEN <= '" + DtoS(dDataAte) + "'"
	
	CarregaDados(aFiltros)
	
	// Agendamentos
	oBrowseAge:= FWMBrowse():New()
	oBrowseAge:SetOwner(oWIN_TOP)
	oBrowseAge:SetAlias('GWV')
	oBrowseAge:SetDescription("Agendamentos")
	oBrowseAge:SetLocate()
	oBrowseAge:SetAmbiente(.F.)
	oBrowseAge:SetWalkthru(.F.)
	oBrowseAge:DisableDetails()
	oBrowseAge:SetMenuDef("")
	oBrowseAge:AddButton("Visualizar","VIEWDEF.GFEA517",,2)
	oBrowseAge:ForceQuitButton(.T.) 
	oBrowseAge:SetFilterDefault(cBrowseFiltro)
	oBrowseAge:BVLDEXECFILTER := {|aParam| GFEC001DV(aParam)}
	oBrowseAge:Activate()
	
	// Estat�sticas
	oBrowseEst := FWBrowse():New()
	oBrowseEst:SetOwner(oWIN_LEFT)
	oBrowseEst:SetDescription("Dados") 
	oBrowseEst:SetDataArray()
	oBrowseEst:DisableFilter()
	oBrowseEst:DisableConfig()
	oBrowseEst:SetArray(aBrowse)
   	oBrowseEst:SetColumns(GFEC001COL("Descri��o",1,,1,20,"oBrowseEst"))
	oBrowseEst:SetColumns(GFEC001COL("Unidade",2,,1,2,"oBrowseEst"))
	oBrowseEst:SetColumns(GFEC001COL("Conte�do",3,,1,20,"oBrowseEst"))
	oBrowseEst:Activate()
	
	//Agendamentos por Situa��o
	GFEC001GRC("oGrfSit","Agendamentos por Situa��o",oWIN_RIGHT,aDados)
Return Nil

/*/--------------------------------------------------------------------------------------------------
DadosAge_Sit()
Fun��o que carrega os dados do Grafico e Grid

Uso Restrito. 

Param: Array com informa��es da Tabela, Campo, Operador Codigo
aParam[1] := Transportador
aParam[2] := Filial de
aParam[3] := Filial ate
aParam[4] := Data de
aParam[5] := Data ate

cBrwFiltro - Express�o em SQL do Filtro aplicado no Browse    

@sample
DadosAge_Sit(aFiltros,cBrwFiltro)

@author Felipe Mendes
@since 05/05/12
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function CarregaDados(aFiltros,cBrwFiltro)
	Local cQuery := ''
	Local cTmp   := ''
	Local aQuery := {}
	Default cBrwFiltro := ''
	
	// Array do browse estat�sticas
	aBrowse := {}
	cQuery += "	SELECT COUNT(CASE WHEN GWV.GWV_SIT = '1' THEN 1 END) SIT_ABERTO, "
	cQuery += "	       COUNT(CASE WHEN GWV.GWV_SIT = '2' THEN 1 END) SIT_CONCLU, "
	cQuery += "	       COUNT(CASE WHEN GWV.GWV_SIT = '3' THEN 1 END) SIT_CANCEL, "
	cQuery += "	       COUNT(*) TOTAL "
	cQuery += "     FROM " + RetSQLName("GWV") + " GWV "
	cQuery += "    WHERE GWV.D_E_L_E_T_ = ' ' " + cBrwFiltro + CriaQueryCondicao(aFiltros,"")
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(Recno()) > 0
		aADD(aQuery,  {"Abertos"   ,(cTmp)->SIT_ABERTO } ) //Numero de Agendamentos em Aberto
		aADD(aQuery,  {"Concluidos",(cTmp)->SIT_CONCLU } ) //Numero de Agendamentos Concluidos
		aADD(aQuery,  {"Cancelados",(cTmp)->SIT_CANCEL } ) //Numero de Agendamentos Cancelados
		
		aADD(aBrowse, {"Transportador"   ,"-" ,Posicione("GU3", 1, xFilial("GU3")+cCodEmit,"GU3_NMEMIT")})
		aADD(aBrowse, {"Qtd Agendamentos","Un",AllTrim(Transform((cTmp)->TOTAL ,'@E 99,999,999,999'))})
	EndIf
	
	(cTmp)->(dbCloseArea())
	aDados := aQuery
Return Nil

//=========================================================================/ 
//Valida��o do filtro do Browse, adapta a express�o do filtro para uma express�o SQL
//=========================================================================/
Function GFEC001DV(aParam) 
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
	GFEC001GRA(oGrfSit,.T.,aDados)
	oBrowseEst:SetArray(aBrowse)
	oBrowseEst:UpdateBrowse()
Return Nil      
