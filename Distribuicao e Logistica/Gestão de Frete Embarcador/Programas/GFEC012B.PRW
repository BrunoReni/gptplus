#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC012B
Frete Realizado por Per�odo
Generico

@sample
GFEC012B(aParam)

Estrutura aParam
aParam[1] - Array com as filiais
aParam[2] - Tipo de Periodo
aParam[3] - Data Ref
aParam[4] - Qtd de periodos
aParam[5] - Grupo de Transp 
aParam[6] - Transp de
aParam[7] - Transp at�

@author Felipe M. / Alan Victor Lamb
@since 26/07/12
@version 1.0                                                                                      
*/
//------------------------------------------------------------------------------------------------  
Function GFEC012B(aParam)   
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local cTitulo := 'An�lise de Frete Realizado por Per�odo' 
	
	Private aParamPadrao := aParam
	Private oTree 
	Private cNodeAnt := "1"  // armazena o n� anterior 
	Private oProcess := Nil  // barras de processamento
	
	// Carrega os intervalos de datas conforme par�metros informados
	Private aIntervalos := GFEC011INT(aParam[2],aParam[4],aParam[3])
	
	/*
	Frete Realizado por Per�odo
	*/
	
	// Array com os dados do grafico
	Private aFrtReal := {}
	Private aFrtTon := {}
	Private aFrtVol := {}
	Private aFrtVal := {}
	Private aFrtQtd := {}
	
	//Objetos Grafico
	Private oGrf
	Private oPnlGraf 
	Private oFolder
	Private oBrwGraf 	
	Private aObjetos // Array com a rela��o de obejtos graficos e os arrays de dados. Utilizado no loop de constru��o dos graficos	
	
	/*
	Estrutura aObjetos 
	aObjetos[][1] - Nome do Array com os dados para o Grafico
	aObjetos[][2] - Titulo do Grafico
	aObjetos[][2] - Picture dos dados 
	*/
	aObjetos := {{"aFrtReal", "Frete Realizado", "@E 999,999,999.99"},;
				   {"aFrtTon", "Frete Realizado por Tonelada", "@E 999,999,999.99"},;
				   {"aFrtVol", "Frete Realizado por Volume", "@E 999,999,999.99"},;
				   {"aFrtVal", "Frete Realizado por Valor Carga", "@E 999,999,999.99"},;
				   {"aFrtQtd", "Frete Realizado por Quantidade", "@E 999,999,999.99"}}
				     
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel     
	
	/*Criando objeto Layer*/
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDLG, .F. )  
	
	/***Criando coluna esquerda (Tree)****/
	oFWLayer:AddLine('LINE_TOP',50,.F.) 							
	oFWLayer:AddCollumn('COL_TOP_LEFT',20,.T.,'LINE_TOP') 			
	oFWLayer:AddWindow('COL_TOP_LEFT','WIN_TOP_LEFT','Op��es',100,.T.,.F.,,'LINE_TOP',)
    oWIN_TOP_LEFT := oFWLayer:GetWinPanel('COL_TOP_LEFT','WIN_TOP_LEFT','LINE_TOP')
	
	/***Criando coluna direita (Browse)****/	
	oFWLayer:AddCollumn('COL_TOP_RIGHT',80,.T.,'LINE_TOP') 			
	oWIN_TOP_RIGHT := oFWLayer:GetColPanel('COL_TOP_RIGHT','LINE_TOP') 			
    
 	/***Criando Linha abaixo (Grafico)****/
   	oFWLayer:AddLine('LINE_BOTTOM',50,.F.) 					   		
	oFWLayer:AddCollumn('COL_BOTTOM',100,.T.,'LINE_BOTTOM') 			
	oFWLayer:AddWindow('COL_BOTTOM','WIN_BOTTOM',,100,.T.,.F.,,'LINE_BOTTOM',)
    oWIN_BOTTOM := oFWLayer:GetWinPanel('COL_BOTTOM','WIN_BOTTOM','LINE_BOTTOM')
    
	oProcess := MsNewProcess():New({||Carregar(aParam,oWIN_TOP_LEFT,oWIN_TOP_RIGHT,oWIN_BOTTOM)}, "Carregando consultas", "Iniciando processo...")
     
 	// Ativa a janela e efetua a carga das consultas e cria��o dos browsers
	oDLG:Activate(,,,.T.,,,{||oProcess:Activate()} )
Return 

//=============================================================
Static Function Carregar(aParam,oWIN_TOP_LEFT,oWIN_TOP_RIGHT,oWIN_BOTTOM)
	oProcess:setRegua1(6)
	
	oProcess:incRegua1("Iniciando... ")
	CriaTree(oWIN_TOP_LEFT)
	
	oProcess:incRegua1()
	CriaGrid(oWIN_TOP_RIGHT)
	
	oProcess:incRegua1()
	CarregaDados(aParam,,.T.)
	
	oProcess:incRegua1()
	CriaPanel(oWIN_BOTTOM)
	
	oProcess:incRegua1() 
	CriaGrafico()
	
	oProcess:incRegua1()
	CriaGrGraf(aParam, GridArray())
Return Nil

//-------------------------------------------------------------------------------------------------
/*CriaTree()
Fun��o que Cria a Tree
Uso Interno

As chaves de indica��o dos itens devem seguir este padr�o:
 [*] N�vel superior
 	 3 Caracteres + '____'. Exemplo: DOC____
 [*] Sub-itens
 	3 Caracteres igual ao n�vel superior + n�mero identifica��o. Exemplo DOC1111
 	
Estas instru��es s�o necess�rias pelas seguintes limita��es:
- A fun��o de evento de clique � uma s� e retorna de forma geral a chave de identifca��o do item selecionado,
assim, a fun��o que trata o evento de sele��o do item (clique) pode tratar qual item foi selecionado.
- A chave de identifica��o do sub-item � limitada a quantidade de caracteres do n�vel superior em que o item pertence

@author Felipe Mendes
@since 07/05/12
@version 1.0                                                                                      
*/
//------------------------------------------------------------------------------------------------    
Static Function CriaTree(oDialog)
    /* Cria o objeto Tree*/
	oFont := TFont():New('Arial',,-12,.T.)
	oTree := DbTree():New(0,0,0,0,oDialog,{|| ChangeItem()},,.T.,,oFont)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT                                        

	/*Adiciona os N�s*/
	oTree:AddItem("Frete Realizado  ", "1" , "FOLDER5" ,,,,1)
	oTree:AddItem("$ por Tonelada"    ,  "2" , "FOLDER5" ,,,,1)
	oTree:AddItem("$ por m�"      , "3" , "FOLDER5" ,,,,1)
	oTree:AddItem("$ por Valor Carga", "4" , "FOLDER5" ,,,,1)
	oTree:AddItem("$ por Qtde Itens" , "5" , "FOLDER5" ,,,,1)
Return Nil

//
// Cria array de dados para o grid que exibe as s�ries dos gr�ficos
// 
Static Function GridArray()
	Local nCount := 0
	Local aGraf := {}
	
	For nCount := 1 To Len(aFrtReal)
		AADD(aGraf, {aFrtReal[nCount, 1], aFrtReal[nCount, 2], ;
			  aFrtReal[nCount, 3], aFrtTon[nCount, 3], aFrtVol[nCount, 3],;
			  aFrtVal[nCount, 3], aFrtQtd[nCount, 3]})
	Next nCount
Return aGraf

//
// Utilizada para atualizar o Grid de dados das s�ries
//
Static Function AtuGrid(aDados)
	oBrwGraf:SetArray(aDados)
	oBrwGraf:UpdateBrowse()
Return	

//
// Cria o Grid para exibi��o dos valores das s�ries dos gr�ficos
//
Static Function CriaGrGraf(aParam, aDados)
	Local cTpPeriodo 	:= aParam[2]
	
	oBrwGraf := FWBrowse():New()
	oBrwGraf:SetOwner(oFolder:aDialogs[2])
	oBrwGraf:SetDescription("Dados") 
	oBrwGraf:SetDataArray()
	oBrwGraf:DisableFilter()
	oBrwGraf:DisableConfig()
	oBrwGraf:SetArray(aDados)
	
	oBrwGraf:SetColumns(GFEC011COL("De",1,,1,10))
	
	If cTpPeriodo != 5 // Se for di�rio n�o adiciona a coluna "At�"
		oBrwGraf:SetColumns(GFEC011COL("At�",2,,1,10))
	EndIf
	
	oBrwGraf:SetColumns(GFEC011COL("Frete Realizado",3,"@E 999,999,999.99",2,20))
	oBrwGraf:SetColumns(GFEC011COL("$ por Tonelada",4,"@E 999,999,999.99",2,20))
	oBrwGraf:SetColumns(GFEC011COL("$ por m�",5,"@E 999,999,999.99",2,20))
	oBrwGraf:SetColumns(GFEC011COL("$ por Valor Carga",6,"@E 999,999,999.99",2,20))
	oBrwGraf:SetColumns(GFEC011COL("$ por Qtde Itens",7,"@E 999,999,999.99",2,20))
	oBrwGraf:SetColumns(GFEC011COL("",,,,2))
	oBrwGraf:Activate()
Return Nil

//=========================================================================/
//Fun��o responsavel por criar o grid, recebe o painel "pai"
//=========================================================================/
Static Function CriaGrid(oDialog)
    oProcess:setRegua2(3)
	oProcess:incRegua2("Criando browse rateios de frete...")
	
	oBrowse := FWMBrowse():New()  
	oBrowse:SetAlias("GWM")	
	oBrowse:DisableConfig()
	oBrowse:SetDescription("Rateios de Frete")
	oBrowse:SetLocate()
	oBrowse:SetMenuDef("")
	oBrowse:SetOwner(oDialog)
	oBrowse:DisableDetails()
	oBrowse:SetProfileID("1")
	oBrowse:BVLDEXECFILTER := {|aParam| GFEC012BFL(aParam)}
	oBrowse:ForceQuitButton(.T.)
	oBrowse:SetFilterDefault("@"+GFEC012BBR())
	
	oProcess:incRegua2()	
	oBrowse:Activate()
	oProcess:incRegua2()
Return Nil
//=========================================================================/
Function GFEC012BBR()                                                       
Local nQtdFil := Len(aParamPadrao[1])
Local cQuery  := ""

	/*
	aParam[1] - Array com as filiais
	aParam[2] - Tipo de Periodo
	aParam[3] - Data Ref
	aParam[4] - Qtd de periodos
	aParam[5] - Grupo de Transp 
	aParam[6] - Transp de
	aParam[7] - Transp at� */

	// Valida as filiais selecionadas no browse
	// O primeiro 'AND' o pr�prio totvstec coloca
	If nQtdFil == 1
		cQuery := " GWM_FILIAL = '"+aParamPadrao[1][1]+"'"
	Else
		cQuery := " GWM_FILIAL >= '"+aParamPadrao[1][1]+"' AND GWM_FILIAL <= '"+aParamPadrao[1][nQtdFil]+"'"
	EndIf

	// Valida o tipo do documento de carga, deve ser igual a
	// 2 = CTRC/NFS, 3 = Contrato Autonomo ou 4 = Estimativa Frete (realizado)
	cQuery := " GWM_TPDOC <> '1'" // O primeiro 'AND' o pr�prio totvstec coloca

	// Valida a data de emiss�o do documento de carga
	cQuery += " AND EXISTS(SELECT 1 FROM "+RetSqlName('GW1')+" GW1"
	cQuery +=             " WHERE GW1.GW1_FILIAL = GWM_FILIAL"
	cQuery +=               " AND GW1.GW1_CDTPDC = GWM_CDTPDC"
	cQuery +=               " AND GW1.GW1_EMISDC = GWM_EMISDC"
	cQuery +=               " AND GW1.GW1_SERDC  = GWM_SERDC"
	cQuery +=               " AND GW1.GW1_NRDC   = GWM_NRDC"
	cQuery +=               " AND GW1.GW1_DTEMIS >= '"+DtoS(aIntervalos[Len(aIntervalos)][1])+"'"
	cQuery +=               " AND GW1.GW1_DTEMIS <= '"+DtoS(aIntervalos[1][2])+"'"
	cQuery +=               " AND GW1.D_E_L_E_T_ = ' ')"

	// Valida grupo do transportador
	If !Empty(aParamPadrao[5]) 
		cQuery += " AND EXISTS(SELECT 1 FROM "+RetSqlName('GU3')+" GU3"
		cQuery +=             " WHERE GU3.GU3_FILIAL = '"+xFilial('GU3')+"'"
		cQuery +=               " AND GU3.GU3_CDEMIT = GWM_CDTRP"
		cQuery +=               " AND GU3.GU3_CDGRGL = '"+aParamPadrao[5]+"'"
		cQuery +=               " AND GU3.D_E_L_E_T_ = ' ')"
	Else
		cQuery += " AND GWM_CDTRP >= '"+aParamPadrao[6]+"'"
		cQuery += " AND GWM_CDTRP <= '"+aParamPadrao[7]+"'"
	EndIf

Return cQuery 
 
//=========================================================================/
//Fun��o responsavel por adaptar o filtro do Browse na Query SQL
//=========================================================================/
Function GFEC012BFL(aParam) 
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
	
	CarregaDados(aParamPadrao,cFiltro)
	GFEC011GRA(oGrf,&(aObjetos[Val(cNodeAnt)][1]),.T.,aObjetos[Val(cNodeAnt)][2],aObjetos[Val(cNodeAnt)][3])
	AtuGrid(GridArray())
Return Nil
//=========================================================================/ 
//Cria todos os paineis que conteram os graficos, recebe como parametro o Dialog "pai" 
//=========================================================================/
Static Function CriaPanel(oOwner)
	oFolder :=  tFolder():New(30,0,{"Gr�fico","Dados"},{"GRAFICO","TABELA"}, oOwner,)
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPnlGraf := tPanel():New(30,0,,oFolder:aDialogs[1],,,,,,)
	oPnlGraf:Align := CONTROL_ALIGN_ALLCLIENT
Return Nil
//=========================================================================/ 
//Fun��o responsavel por criar os graficos, utiliza o array aObjetos para criar os graficos dinamicamente
//=========================================================================/
Static Function CriaGrafico()   
	Local nCont, nCont1
	
 	oGrf := FWChartFactory():New()
 	oGrf := oGrf:getInstance( BARCHART )
 	oGrf:Init(oPnlGraf,.F.)
 	oGrf:setTitle( aObjetos[1][2], CONTROL_ALIGN_CENTER) 
 	oGrf:setLegend( CONTROL_ALIGN_RIGHT  )
 	GFEC011GRA(oGrf,&(aObjetos[1][1]),,aObjetos[1][2],aObjetos[1][3])               
Return Nil
 	
/*===================================================================*/
//Fun��o responsavel por criar a condi��o SQL de filiais, Param: Campo (ex: GW1_FILIAL) e o Array com as filiais
//Retorna a express�o Query montada
/*===================================================================*/
Static function QueryFilial(cCampo,aFilial)
	Local cQuery
	Local nCont
	
	cQuery := " ( "
	For nCont := 1 to len(aFilial)    
	
		If nCont > 1
			cQuery += " OR "	
		EndIf  
		cQuery += cCampo + " = '" +aFilial[nCont]+ "' "
	
	Next nCont
	cQuery += " ) "
Return cQuery  

/*===================================================================*/
//Fun��o que esconde o painel do n� anterior e mostra o painel do n� selecionado  
/*===================================================================*/  
Static Function ChangeItem()
	Local cNode := AllTrim(Substr(oTree:GetCargo(), 1, 6))

	CursorWait()   
     
    GFEC011GRA(oGrf,&(aObjetos[Val(cNode)][1]),.T.,aObjetos[Val(cNode)][2],aObjetos[Val(cNode)][3])
	
	oBrwGraf:SetColumnOrder((Val(cNode)+2),3)
	oBrwGraf:UpdateBrowse()
	
	cNodeAnt := cNode // Armazena o n�  
	
	CursorArrow()
Return Nil

//=========================================================================/
//Carrega os dados para os graficos
/*
Estrutura aParam
aParam[1] - Array com as filiais
aParam[2] - Tipo de Periodo
aParam[3] - Data Ref
aParam[4] - Qtd de periodos
aParam[5] - Grupo de Transp 
aParam[6] - Transp de
aParam[7] - Transp at�

*/
//=========================================================================/
Static Function CarregaDados(aParam,cBrwFiltro,lProcess)
	Local nCont
	Local cTpPeriodo   	:= aParam[2]
	Local cGrupoTransp 	:= aParam[5] 
	Local cTranspDe  	    := aParam[6]
	Local cTranspAte   	:= aParam[7]
	Local cParamData      := ""
	Local cQuery           := ""
	Default cBrwFiltro := ''
	Default lProcess    := .F.   
	Private cWhere      := ''
	
	If lProcess
		oProcess:setRegua2(Len(aIntervalos))
		oProcess:incRegua2("Realizando consultas")
	EndIf
	
    If !Empty(cGrupoTransp)
	    cQueryTransp := " ( GU3_CDGRGL = '"+cGrupoTransp+"' ) AND "
	Else
		cQueryTransp := " ( GU3_CDEMIT >= '"+cTranspDe+"' AND GU3_CDEMIT <= '"+cTranspAte+"' ) AND "   
	Endif
 	
	aFrtReal := {}
	aFrtTon := {}
	aFrtVol := {}
	aFrtVal := {}
	aFrtQtd := {}
	
	For nCont := 1 To Len(aIntervalos)
        If cTpPeriodo != 5
			cParamData := " GW1_DTEMIS >= '"+DtoS(aIntervalos[nCont][1])+"' AND GW1_DTEMIS <= '"+DtoS(aIntervalos[nCont][2])+"' "
		Else
			cParamData := " GW1_DTEMIS = '"+DtoS(aIntervalos[nCont][1])+"' "
		EndIf
		
		/*Cria a variavel cWhere*/
		cWhere := cQueryTransp 
		cWhere += cParamData + " AND  "
		cWhere += QueryFilial("GW1_FILIAL",aParam[1]) +  cBrwFiltro 
		cWhere += " AND GWM.D_E_L_E_T_ =  ' ' "
		cWhere += " AND GW1.D_E_L_E_T_ =  ' ' "
		cWhere += " AND GU3.D_E_L_E_T_ =  ' ' "
		
		cQuery := ""
		cQuery += "  SELECT SUM(GWM_VLFRET)FRT_REAL,"
		cQuery += "		  CASE WHEN SUM(GW8_PESOR) > 0 THEN (SUM(GWM_VLFRET) / SUM(GW8_PESOR) * 1000) ELSE 0 END FRT_PES,"
		cQuery += "		  CASE WHEN SUM(GW8_VOLUME) > 0 THEN (SUM(GWM_VLFRET) / SUM(GW8_VOLUME)) ELSE 0 END FRT_VOL,"
		cQuery += "		  CASE WHEN SUM(GW8_VALOR) > 0 THEN (SUM(GWM_VLFRET) / SUM(GW8_VALOR)) ELSE 0 END FRT_VAL,"
		cQuery += "		  CASE WHEN SUM(GW8_QTDE) > 0 THEN (SUM(GWM_VLFRET) / SUM(GW8_QTDE)) ELSE 0 END FRT_QTD"
		cQuery += "    FROM "+RetSQLName( 'GWM' ) + " GWM " 
		cQuery += "   INNER JOIN "+RetSQLName( 'GW1' )+ " GW1 ON GWM_FILIAL = GW1.GW1_FILIAL" 
		cQuery += " 					AND GWM_CDTPDC = GW1.GW1_CDTPDC" 
		cQuery += " 					AND GWM_EMISDC = GW1.GW1_EMISDC "
		cQuery += " 					AND GWM_SERDC  = GW1.GW1_SERDC"  
		cQuery += " 					AND GWM_NRDC   = GW1.GW1_NRDC"  
		cQuery += "   INNER JOIN (SELECT GW8_FILIAL,"
		cQuery += " 					  GW8_CDTPDC,"
		cQuery += " 					  GW8_EMISDC,"
		cQuery += " 					  GW8_SERDC,"
		cQuery += " 					  GW8_NRDC,"
		cQuery += " 					  SUM(GW8_PESOR) GW8_PESOR,"
		cQuery += " 					  SUM(GW8_VOLUME) GW8_VOLUME,"
		cQuery += " 					  SUM(GW8_VALOR) GW8_VALOR,"
		cQuery += " 					  SUM(GW8_QTDE) GW8_QTDE"
		cQuery += " 				 FROM "+RetSQLName( 'GW8' )
		cQuery += "			    WHERE D_E_L_E_T_ =  ' ' "
		cQuery += " 				GROUP BY GW8_FILIAL," 
		cQuery += " 				GW8_CDTPDC,"
		cQuery += " 				GW8_EMISDC,"
		cQuery += " 				GW8_SERDC,"
		cQuery += " 				GW8_NRDC) GW8 ON GW8.GW8_FILIAL = GW1.GW1_FILIAL" 
		cQuery += " 				    AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC "
		cQuery += " 					AND GW8.GW8_EMISDC = GW1.GW1_EMISDC "
		cQuery += " 					AND GW8.GW8_SERDC  = GW1.GW1_SERDC  "
		cQuery += " 					AND GW8.GW8_NRDC   = GW1.GW1_NRDC "
		cQuery += "    INNER JOIN "+RetSQLName('GU3')+ " GU3 ON GWM_CDTRP = GU3_CDEMIT"  
		cQuery += "    WHERE (GWM_TPDOC = '2' OR GWM_TPDOC = '3') AND " + cWhere
		
		cTmp := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
		dbSelectArea(cTmp)
		(cTmp)->(dbGoTop())
		
		If (cTmp)->(Eof())
			aADD(aFrtReal,{aIntervalos[nCont][1],aIntervalos[nCont][2], 0})
			aADD(aFrtTon,{aIntervalos[nCont][1],aIntervalos[nCont][2], 0})
			aADD(aFrtVol,{aIntervalos[nCont][1],aIntervalos[nCont][2], 0})
			aADD(aFrtVal,{aIntervalos[nCont][1],aIntervalos[nCont][2], 0})
			aADD(aFrtQtd,{aIntervalos[nCont][1],aIntervalos[nCont][2], 0})
		EndIf
		
		While (cTmp)->(!Eof())
			aADD(aFrtReal,{aIntervalos[nCont][1],aIntervalos[nCont][2], (cTmp)->FRT_REAL})
			aADD(aFrtTon,{aIntervalos[nCont][1],aIntervalos[nCont][2], (cTmp)->FRT_PES})
			aADD(aFrtVol,{aIntervalos[nCont][1],aIntervalos[nCont][2], (cTmp)->FRT_VOL})
			aADD(aFrtVal,{aIntervalos[nCont][1],aIntervalos[nCont][2], (cTmp)->FRT_VAL})
			aADD(aFrtQtd,{aIntervalos[nCont][1],aIntervalos[nCont][2], (cTmp)->FRT_QTD})
			
			(cTmp)->(dbskip())	
		EndDo

		(cTmp)->(dbCloseArea())
		
		If lProcess
			oProcess:incRegua2()
		EndIf
	Next nCont 
	GFEDelTab(cTmp)
Return                  
