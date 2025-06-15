#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC927.CH"

#define INFO_ZOOM_OBJETO 2

/*/{Protheus.doc} PRAC927
@author   Aline Briesemeister Xavier
@version  P12
@since    23/07/2012
@obs      2.2.14 - Consulta por Sequencial
/*/
Function PRAC927()
	Local cValorPadrao :=''
	Local aCoors       := FWGetDialogSize(oMainWnd)
	Local oBrowse      := nil
	Local aFilParser   := {}
	Local oLayer       := nil
	Local oDlg         := nil
	Local oPanel       := nil
	Local nTotal       := 1
	
	Public aFields      := {}
	Public cAliasTb     := SGetNAlias()
	Private nColSize    := 0
	Private aStructDesc := nil
	Private aStruct	    := nil
	Private cChave     :=' '
	Private cIndice    :=' '
	Private cDe        :=' '
	Private cAte       :=' '
	Private cConsultaEsp  := C927PARAM('CONSULTA_RF_ESPECIFICO')
	Private CtipPesquisa := Strim(SGetParam('PADRAO_PESQUISA_2_14'))
	Private aTabMov      := {}
	Private aTabCad      := {}
	Static nTamTabMov    := 0
	Static nTamTabCad    := 0
	Static aChaves       := {}
	
	//os campos da tabelas de movimentações e de cadastros
	aTabCad       := A927TabCAD()
	nTamTabCad    := Len(aTabCad)
	aTabMov       := A927TabMOV()
	nTamTabMov    := Len(aTabMov)
	
	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

	oLayer := FWLayer():new()
	oLayer:init(oDlg,.F.)
	oLayer:addColumn('Col01',100,.F.)
	oLayer:addWindow('Col01','C1_Win01',STR0001,100,.T.,.F.,,,)

	oPanel  := oLayer:getWinPanel('Col01','C1_Win01')
		
	cValorPadrao:=Str(YEAR(DATE()))
	if (CtipPesquisa == '0' )
		Aadd(aFields, {"P1"  , STR0002 , "C" , 30    , nil  , nil, nil, "C927ZOOM_1(o)"   , {|xConteud, o| C927VALIDA(xConteud, o) } ,"tab_acesso"})
		Aadd(aFields, {"P2" , STR0006 , "C" , 50    , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , "1         "})
		Aadd(aFields, {"P3"  , STR0004 , "C" , 50    , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , "99999999999999999.99"})
	else
		         //Campo, Descricao, Tipo, Tamanho  , Alias, Mascara  , Nil, Zoom            , Validacao , ValorPadrao 					  
		Aadd(aFields, {"P1"  , 'Chave de', "C" , 30   , nil  , "@E 99999999999999999.99" , nil, nil, nil ,Alltrim(cValorPadrao+"00000000000000000.00")})
		Aadd(aFields, {"P2"  , 'até'     , "C" , 30   , nil  , "@E 99999999999999999.99" , nil, nil, nil ,Alltrim(cValorPadrao+"99999999999999999.99")})
		Aadd(aFields, {"P3"  , 'Chave de', "C" , 30   , nil  , "@E 99999999999999999.99"    , nil, nil, nil ,Alltrim(cValorPadrao+"00000000000000000.00")})
		Aadd(aFields, {"P4"  , 'até'     , "C" , 30   , nil  , "@E 99999999999999999.99"    , nil, nil, nil ,Alltrim(cValorPadrao+"99999999999999999.99")})
		Aadd(aFields, {"P5"  , 'Chave de', "C" , 30   , nil  , "@E 99999999999999999.99"    , nil, nil, nil ,Alltrim(cValorPadrao+"00000000000000000.00")})
		Aadd(aFields, {"P6"  , 'até'     , "C" , 30   , nil  , "@E 99999999999999999.99"    , nil, nil, nil ,Alltrim(cValorPadrao+"99999999999999999.99")})
		Aadd(aFields, {"P7"  , 'Chave de', "C" , 30   , nil  , "@E 99999999999999999.99"   , nil, nil, nil ,})
		Aadd(aFields, {"P8"  , 'até'     , "C" , 30   , nil  , "@E 99999999999999999.99"   , nil, nil, nil ,})
		if (cConsultaEsp <> '1') // Padrão
		   Aadd(aFields, {"P9"  , 'Chave de', "C" , 30   , nil  , "@E 99999999999999999.99"   , nil, nil, nil ,Alltrim(cValorPadrao+"00000000000000000.00")})
		   Aadd(aFields, {"P10" , 'até'     , "C" , 30   , nil  , "@E 99999999999999999.99"   , nil, nil, nil ,Alltrim(cValorPadrao+"99999999999999999.99")})
		else // específico Rocha
		   Aadd(aFields, {"P9"  , 'Chave de', "C" , 30   , nil  , "@E 99999999999999999.99"   , nil, nil, nil ,Alltrim(cValorPadrao+"00000000000000000.00")})
		   Aadd(aFields, {"P10" , 'até'     , "C" , 30   , nil  , "@E 99999999999999999.99"   , nil, nil, nil ,Alltrim(cValorPadrao+"99999999999999999.99")})		
		endif
		Aadd(aFields, {"P11" , 'Chave de', "C" , 30   , nil  , "@E 99999999999999999.99"   , nil, nil, nil ,Alltrim(cValorPadrao+"00000000000000000.00")})
		Aadd(aFields, {"P12" , 'até'     , "C" , 30   , nil  , "@E 99999999999999999.99"   , nil, nil, nil ,Alltrim(cValorPadrao+"99999999999999999.99")})
		Aadd(aFields, {"P13" , STR0007   , "C" , 50   , nil  , "@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'00000000000000000.00')})
		Aadd(aFields, {"P14" , STR0004   , "C" , 50   , nil  , "@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'99999999999999999.99')})
		
		Aadd(aFields, {"P15" , STR0007   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'00000000000000000.00')})
		Aadd(aFields, {"P16" , STR0004   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'99999999999999999.99')})
		Aadd(aFields, {"P17" , STR0007   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'00000000000000000.00')})
		Aadd(aFields, {"P18" , STR0004   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'99999999999999999.99')})
		Aadd(aFields, {"P19" , STR0007   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'00000000000000000.00')})
		Aadd(aFields, {"P20" , STR0004   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'99999999999999999.99')})
		Aadd(aFields, {"P21" , STR0007   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'00000000000000000.00')})
		Aadd(aFields, {"P22" , STR0004   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'99999999999999999.99')})
		Aadd(aFields, {"P23" , STR0007   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'00000000000000000.00')})
		Aadd(aFields, {"P24" , STR0004   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'99999999999999999.99')})
		Aadd(aFields, {"P25" , STR0007   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'00000000000000000.00')})
		Aadd(aFields, {"P26" , STR0004   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'99999999999999999.99')})
		Aadd(aFields, {"P27" , STR0007   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'00000000000000000.00')})
		Aadd(aFields, {"P28" , STR0004   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'99999999999999999.99')})
		Aadd(aFields, {"P29" , STR0007   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'00000000000000000.00')})
		Aadd(aFields, {"P30" , STR0004   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'99999999999999999.99')})
		Aadd(aFields, {"P31" , STR0007   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'00000000000000000.00')})
		Aadd(aFields, {"P32" , STR0004   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'99999999999999999.99')})
		
		For nTotal := 1 To nTamTabCad
		   Aadd(aFields, {"P"+cValToChar(aTabCad[nTotal][2]) ,   'Chave de '   , "C" , 50   , nil  ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'00000000000000000.00')})
		   Aadd(aFields, {"P"+cValToChar(aTabCad[nTotal][3]) , 'até '         , "C" , 50   , nil   ,"@E 99999999999999999.99", nil, nil   , nil       , alltrim(cValorPadrao+'99999999999999999.99')})
		Next
		
	endif

	aStructDesc := C927CTMP(@aStruct)
		
	oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)
	if (CtipPesquisa == '0' )
		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)
		oBrowse:AddFilter(STR0002, "P1=='%P1%'.AND. P2=='%P2%' .AND. P3=='%P3%'", .T., .T.,nil,.T., aFilParser)
	else
		A927FILTRO(oBrowse)
	endif
			
    oBrowse:CleanProfile() 			
	oBrowse:Activate()
	DES_FIL_BW(oBrowse)//Desabilita edicao filtros
	oBrowse:oFWFilter:SetOnStart({||C927ONSTART(oBrowse)})
	oBrowse:oFWFilter:SetExecute({||C927FILTER(oBrowse)})
	oBrowse:oFWFilter:FilterBar(nil,.F.,.F.)

	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTb(cAliasTb)
Return

Static Function C927ONSTART(oBrowse)
	local aAreaAnt  := getarea()
	local sMemoProf := ""
	local cUserName := ""
	local nTamanho  := 0
	local nFindProf := 0
	local cFindProf := ""
	local nLinha    := 0
	local aLinhas   := {}
	local lContinua := .T.
	local cValorPadrao:=""
    
	PswOrder(1)
	If PswSeek(RetCodUsr())
		cUserName := PswRet(1)[1][1]
		For nFindProf := 1 To 16
			cFindProf := Alltrim(Str(nFindProf))
			If FindProfDef(cUserName, "PRAC927", "FILTER", cFindProf )
     		   // Carrega memo com o profile do usuario
				sMemoProf := RetProfDef (cUserName, "PRAC927", "FILTER", cFindProf )
     		
     		   // Monta array com as linhas do memo (tem uma pergunta por linha)
				aLinhas = {}
				If MLCount (sMemoProf) > 0
					for nLinha = 1 to 3//MLCount (sMemoProf)
						aadd (aLinhas, alltrim (MemoLine (sMemoProf,, nLinha)) )
					next
                  //A patir deste ponto o array pode ser manipulado para ser alterado o valor
                  //antes de ser incluido os valors novamente no memo.
					if (CtipPesquisa == "0" )
						aLinhas[2]:="D#G#"+"0"+CRLF
						aLinhas[3]:="D#G#"+"9999999999"+CRLF
					else
						aLinhas[2]:="D#G#"+" "+CRLF
						aLinhas[3]:="D#G#"+" "+CRLF
					endif
                         
                  // Remonta memo para gravar no profile - GFEA050B
					sMemoProf = ""
            
					for nLinha = 1 to len (aLinhas)
						sMemoProf += aLinhas [nLinha]
					next

                  // Grava o memo no profile
					WriteProfDef(cUserName, "PRAC927", "FILTER", cFindProf, ; // Chave antiga
					cUserName, "PRAC927", "FILTER", cFindProf, ; // Chave nova
					sMemoProf) // Novo conteudo do memo.
				Endif
			EndIf
		Next
	EndIf
	restarea (aAreaAnt)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} C927FILTER
Funcao que sera executada no momento em que o filtro for acionado, para tratar as informações

@param oBrowse Variavel que contem a GRID do programa

@author  Aline Briesemeister Xavier	
@since   24/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function C927FILTER(oBrowse)

	Local cQuery       := " exec proc_s_campos_tab_log_w "
	Local oColumn
	Local nI           := 0
	Local oFilter      := oBrowse:FWFilter()
	Local aFilter      := nil
	Local cMsg         := ""
	Local cCampo       := ''
	local cAlias       := ''
	local cListaCampos := ''
	local cCampos2     := ''
	local aStructSelect
	local i            :=0
	//local cExpress     :=' '
	Local aSX3Cadastro := {}
	Local aSX3CamposTab:= {}
	Local aFieldTAB    := {}
	Local cAnoDe       := 0
	Local cAnoAte      := 0
	Local arrayDe      := {}
	Local arrayAte     := {}
	Local nEncontrado  := 0
	Local cFiltro      := ''
	Local cIDChave     := '0'
	Local DeChave      := '0'
	Local AteChave     := '0'
	Local nI           := 0
	local cCamposList  := ''
	Local cIDAte       := '0'
	Local cIDDe        := '0'
	Local cSquencial   := ''
	Local cCamposTab   := ''
	Local logDe        := 0
	Local logAte       := 0
	Local aDe          := {}
	Local aAte         := {}
	Local cAnoBase     := ''
	
	Private cParams      := ""
	
	If (!Empty(oFilter:Acheckfil))
		For nI := 1 To Len(aTabMov)
		   If(oFilter:Acheckfil[nI] == .T.)
		      cParams := AllTrim(aTabMov[nI][1])
		      nI := (Len(aTabMov)+1)
		   EndIf
		Next
	EndIf

	if !SVALFILTRO(oFilter)
		Alert(STR0005)
		return
	endif

	aFilter := oFilter:GetFilter(.T.)

	if (!C927GF(aFilter, @cParams, @cMsg))
		if (!SEmpty(cMsg))
			alert(cMsg)
		endif
		return
	endif
	
	cAlias := SGetNAlias()
	
	cQuery += " " + cParams
	
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
   
	aStructDesc := {}
	aStruct     := {}
	aFieldTAB   := A907FieldSize(cParams)
	If(!Empty(aFieldTAB[1][1]))
		cChave      := AllTrim(aFieldTAB[1][1])
	EndIf
	
	If (cParams == 'tab_adi_item')
	   cChave      := 'adi_numero'
	EndIf
	
	Aadd(aStructDesc, {'Sequencial', 30})
	Aadd(aStruct,     {'CP1', 'C', 100, 0})
	Aadd(aStructDesc, {cChave, 30})
	Aadd(aStruct,     {'CP2', 'C', 100, 0})
	
	cAnoBase := "(select min(log_datahora) from sara_log.."+StrTran(cParams,"'")+;
                " where Datepart(year, log_datahora) BETWEEN "+substr(cDe,1,4)+" AND "+substr(cAte,1,4)+"  "+;
                " and "+cChave+" = RFBConsulta."+cChave+")                           " 
	
	cCamposTab := " Sequencial, " +; 
	              cChave +", " 
	
	i := 3
	While (cAlias)->(!Eof())
	    If(STrim((cAlias)->(FieldGet(1))) = 'pes_foto')
	    Else
			cCampo := STrim((cAlias)->(FieldGet(1)))
			if (At('sequencial',cCampo) = 0) 
				if ((cCampo != cChave).and.(SubStr(cCampo,1,4) != 'log_') .and.(cCampo != StrTran(cChave, 'sequencial', 'id')) .and. (cCampo != 'lote_filho'))
					if ('CHAR' $ Upper(STrim((cAlias)->(FieldGet(2)))))
						cListaCampos := cListaCampos + "IsNull(substring(a."+cCampo+",1,100), ' ') as "+cCampo+","
						cCamposTab += cCampo + ','
					elseif ('DATETIME' $ Upper(STrim((cAlias)->(FieldGet(2)))))
						cListaCampos := cListaCampos + "isnull(convert(varchar(10),a."+cCampo+",103)++' '++convert(varchar(08),a."+cCampo+",108),' ') as "+cCampo+","
						cCamposTab += cCampo + ','
					elseif ('TEXT' $ Upper(STrim((cAlias)->(FieldGet(2)))))
						cListaCampos := cListaCampos + "IsNull(substring(a."+cCampo+",1,100), ' ') as "+cCampo+","
						cCamposTab += cCampo + ','
					elseif ('IMAGE' $ Upper(STrim((cAlias)->(FieldGet(2)))))
						//cListaCampos := cListaCampos + "IsNull("+cCampo+", ' '),"
					else
						If AllTrim(cChave) <> AllTrim(cCampo)
						     cListaCampos := cListaCampos + "IsNull(a."+cCampo+", 0) as "+cCampo+","
						     cCamposTab += cCampo + ','
						Else
						    cListaCampos := cListaCampos + ","
						    cCamposTab := cCampo + ','
						EndIf
					endif
					Aadd(aStructDesc, {cCampo, 30})
					Aadd(aStruct,     {'CP'+STransType(i), 'C', 200, 0}) 
					i++
				endif
			EndIf
			(cAlias)->(dbSkip())
		EndIf
	EndDo
	(cAlias)->( dbCloseArea ())
	(cAliasTb)->( dbCloseArea ())
	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
	(cAliasTb)->(dbCloseArea()) 
	
	cFiltro  := " datepart(year, a.log_datahora) between " + substr(cDe,1,4) +" and " + substr(cAte,1,4)
  
    TcSqlExec(' delete from '+cAliasTb)
    
    cCamposTab += "' ' AS D_E_L_E_T, "
	cCamposTab += " ROW_NUMBER() OVER(ORDER BY log_datahora ASC) AS R_E_C_N_O_ "
	
	cQuery  = "insert into " + cAliasTb + " "
	cQuery += " select "+cCamposTab+" from (select "
	
	  
	cQuery += " convert(varchar(4),Datepart(year, "
    cQuery += "      (select min(lga.log_datahora) from sara_log.."+StrTran(cParams,"'")+ " lga where lga."+cChave+" = a."+cChave+" and lga.log_operacao = 'I') "
	cQuery += "    )) + RIGHT('0000000000000'+CONVERT(VARCHAR(15),a."+cChave+"),13)+'.'+RIGHT('00'+convert(varchar(15),a.log_registro),2)  AS Sequencial, " 
	//cQuery += cValToChar(cDe) + " + Row_number() OVER(ORDER BY "+cChave+",log_datahora) as Sequencial, "
	
	cQuery += " isNull(a."+cChave+", '0') as "+cChave+", "
	cQuery += " a.log_datahora, " 
	cQuery += cListaCampos
	cQuery += "' ' AS D_E_L_E_T, "
	cQuery += "  ROW_NUMBER() OVER(ORDER BY a.log_datahora ASC) AS R_E_C_N_O_, a.log_registro "
	cQuery += " from "
	cQuery += "   sara_log.." +StrTran(cParams,"'") + " a "
	//cQuery += " where "
	//cQuery += cFiltro 
	cQuery += " ) as RFBConsulta "
	cQuery += " where Sequencial >= '"+cDe+"' and Sequencial <= '"+cAte+"'"


 	TcSqlExec(cQuery)
 	TcRefresh(cAliasTb) 
	DbUseArea(.T.,'TOPCONN',cAliasTb,cAliasTb,.T.,.F.)
	DBCreateIndex("CONSULTA", "CP1+CP2" , {|| CP1+CP2 })
	DBSetOrder(1)

	nColSize := Len(oBrowse:aColumns)
	for nI := 1 to nColSize
		oBrowse:DelColumn(nI)
	next
	nColSize := Len(aStruct)

	for nI := 1 to nColSize
		oColumn := nil
		
		cCampo := STransType(aStruct[nI][1])
		cCampo := "{|| "+cCampo+"}"

		oColumn := FWBrwColumn():New()
		oColumn:SetData(&(cCampo))
		oColumn:SetTitle(aStructDesc[nI][1])
		oColumn:SetSize(aStructDesc[nI][2])

		oBrowse:SetColumns({oColumn})
	next

    TcRefresh(cAliasTb) 
	oBrowse:UpdateBrowse()
	
    cParams:=''
    cChave:=''
    cIndice:=''
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} C927GF
Processa os filtros para recuperar os parametros para as procedures

@param aFilter Informacoes selecionadas pelo usuario
@param cParams Variavel que retornara os parametros da procedure
@param cMsg Variavel que retorna mensagem de erro caso houver

@author  Aline Briesemeister Xavier
@since   24/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
static function C927GF(aFilter, cParams, cMsg) 
	
	aZoom := SZoomTb()

	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif
	
	A927SP_FILT(aFilter,aTabMov)
	
return .T.

Function A927SP_FILT(aFilter,aTabMov)	
    Local aResult            := aFilter[1][4]
	Local nI                 := 1
	Local nY                 := 1
	Local bTabelaIndividual  :=.T.
	Local aZoom              := {}
	Local aIdInformado       := StrTokArr(aFilter[1][2],"'")
	Local cValor             := '' 
	
	aZoom := SZoomTb()
	
	if CtipPesquisa == "1"	
	
	    cDe  := aIdInformado[2]
		cAte := aIdInformado[4]
			    
	    For nY := 1 To Len(aIdInformado)
	        cValor := aIdInformado[nY]
	        cValor := StrTran(cValor,'.','')
	        If(IsNumeric(cValor))
			    nY := (Len(aIdInformado)+1)
	        EndIf
	    Next
	
		if bTabelaIndividual
		   for nI:=1 to len(aZoom[2])
			   if aZoom[2][nI][2]==cParams
				  cChave := Alltrim(aZoom[2][nI][1])
				  cIndice:= Alltrim(aZoom[2][nI][4])
			   endif
		   next
		endif  
	
	Else
	    cParams += STransType(aResult[3][1])
	    cDe  = STrim(STransType(aResult[6][1]))
	    cAte =	STrim(STransType(aResult[9][1]))
	EndIf
	
	if !Empty(cParams) .AND. (Empty(cChave) .AND. Empty(cIndice))
		cParams := lower(cParams)
		C927VALIDA(cParams, nil)
        
		if (Empty(cChave) .AND. Empty(cIndice))
		   Alert("Foram selecionadas uma ou mais tabelas!")
		endif
	endif
	if !Empty(cParams)		
	   cParams:="'"+cParams+"'"
	endif 
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} C927ZOOM
Funcao que seleciona o ZOOM para a tabela

@param oObj Objeto que o resultado do zoom ira retornar
@param nTipoZoom Variavel que distingue o tipo de zoom uilizado

@author  Aline Briesemeister Xavier
@since   24/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function C927ZOOM_1(oObj)
	Local aZoom := {}
	Local aRetZoom := {}
	Local I:=0
	
    //Local nTotalTabelas := (nTamTabMov)
    
    aZoom := SZoomTb()
	
	If (CtipPesquisa == '1' )
		For i := nTamTabMov to 1 step -1
		    
		    If((aZoom[2][i][2] == aTabMov[i][1]) .Or. (aZoom[2][i][2] == aTabMov[i][1])) 
		        aDel(aZoom[2],i)
		    EndIf
		Next i
		aSize(aZoom[2],10)
	EndIf
	
	aRetZoom := PRAC938(aZoom)
	
	//lugar para inserir validacao da tabela aRetZoom[2]="tab_acesso"
	if !SEmpty(aRetZoom)
		oObj:cText := aRetZoom[2]
		cChave:=aRetZoom[1]
		cIndice:=aRetZoom[3]
	else
		oObj:cText := nil
	endif

return
//-------------------------------------------------------------------
/*/{Protheus.doc} C927CTB
Funcao que cria a estrutura da tabela

@param aStruct Variave que retornara a estrutura dos campos da tabela
@return aStructDesc Variavel que retornara a descricao dos campos da tabela

@author  Aline Briesemeister Xavier
@since   24/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
static function C927CTMP()
                      
	aStructDesc := {    ;
		{STR0002 , 10}, ;
		{STR0002 , 10}, ;
		{STR0002 , 10} 	;
		}

	aStruct := {    ;
		{'CP1' ,'C',100 ,0}, ;
		{'CP2' ,'C',100 ,0}, ;
		{'CP3' ,'C',100 ,0}  ;
		}
         
	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
return aStructDesc
//-------------------------------------------------------------------
function C927VALIDA(xConteud, o)
	Local aZooom := SZoomTb()
	Local aPos := 1

	if !Empty(xConteud)
		aPos := Ascan(aZooom[INFO_ZOOM_OBJETO], {|x,y| (x[2] == AllTrim(xConteud)) })
		if aPos > 0
			cChave := aZooom[INFO_ZOOM_OBJETO][aPos][1]
			cIndice := aZooom[INFO_ZOOM_OBJETO][aPos][4]
		endif
	endif
return (aPos > 0)

//-----------------------------------
/*{Protheus.doc}
Retorna parametro SARA

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Esta funcao retorna o valor configurado no parametro no sistema SARA
*/
//-----------------------------------

static Function C927PARAM(cParam)
	Local tTabParam := GetNextAlias()
   //Local cParam := ""
	cQuery :=     " SELECT  "
	cQuery +=            " PARAM_VALOR AS PARAMETRO"
	cQuery +=       " FROM TAB_PARAMETRO"
	cQuery +=      " WHERE PARAM_DESC = '"+cParam+"'"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),tTabParam,.F.,.T.)

	DbSelectArea(tTabParam)
	cParam := AllTrim((tTabParam)->PARAMETRO)
	(tTabParam)->(DbCloseArea())
Return cParam

/*/{Protheus.doc} A927FILTRO
//TODO Descrição auto-gerada.
O Objetivo desta função é montar os checklist das tabelas de todas a tabelas
@author MOHAMED S B DJALO
@since 04/08/2019
@version undefined
@param oBrowse, object, descricao
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Function A927FILTRO(oBrowse)
        Local ini        := 1
        Local nDe        := 0
        Local nAte       := 0
        Local cChecked   := ''
        Local nTotal     := 0
        Local cCampo1    := ''
        Local cValor1    := ''
        Local cCampo2    := ''
        Local cValor2    := ''
        
        //Monta os filtros para as tabelas de movimentações e cadastros
        For nTotal := 1 To nTamTabMov
            aFilParser := {}
            cChecked := ''
	        For ini := 1 To ((2*nTamTabMov))
	           
	           nDe  := aTabMov[nTotal][2] 
	           nAte := aTabMov[nTotal][3] 
	           
	           cCampo1 := ''
	           cValor1 := ''
	           
	           If (!Empty(cChecked))
	               cChecked += " .AND. "
	           EndIf
	           
	           If (ini >= nDe .And. ini <= nAte)
	              cCampo1 := "P"+cValToChar(ini)
	              cValor1 := "'%P"+cValToChar(ini)+"%'"
	              
	              SAddFilPar("P"+cValToChar(ini),"==","%P"+cValToChar(ini)+"%",@aFilParser)
	           Else
	              cCampo1 := "P"+cValToChar(ini)
	              cValor1 := "NULL"
	              
	              SAddFilPar("P"+cValToChar(ini),"==","NULL",@aFilParser)
	           EndIf
	           
	           If(!Empty(cValor1))
	              cChecked += cCampo1+" == "+cValor1
	           Else
	              cChecked += cCampo1
	           EndIf
	           
	        Next
	        
		    oBrowse:AddFilter(aTabMov[nTotal][1], cChecked, .F., .F.,nil,.T., aFilParser,'0')

        Next
return

/*/{Protheus.doc} A927TabMOV
//TODO Descrição auto-gerada.
Retorna os campos das tabelas de movimentações e de cadastro
@author MOHAMED S B DJALO
@since 04/08/2019
@version undefined

@return aTabMov, return_description
@example
(examples)
@see (links_or_references)
/*/
Function A927TabMOV()

    Local nTotal       := 1
    
    aadd(aTabMov,{'tab_usuarios',1,2})
	aadd(aTabMov,{'tab_lote',3,4})
	aadd(aTabMov,{'rel_lote',5,6})
	aadd(aTabMov,{'tab_cesv',7,8})
	aadd(aTabMov,{'tab_doc_entrada',9,10})
	aadd(aTabMov,{'tab_doc_saida',11,12})
	aadd(aTabMov,{'tab_acesso',13,14})
	aadd(aTabMov,{'tab_os',15,16})
	aadd(aTabMov,{'tab_registro_manifesto',17,18})
	aadd(aTabMov,{'tab_hist_benef_lote',19,20})
	aadd(aTabMov,{'tab_apreensao',21,22})
	aadd(aTabMov,{'tab_lacres',23,24})
	aadd(aTabMov,{'tab_os_item',25,26})
	aadd(aTabMov,{'tab_lote_ova_cnt',27,28})
	aadd(aTabMov,{'tab_consolidacao',29,30})
	aadd(aTabMov,{'rel_lote_consolidacao',31,32})
	
	For nTotal := 1 To nTamTabCad
	   aadd(aTabMov,{aTabCad[nTotal][1],aTabCad[nTotal][2],aTabCad[nTotal][3]})
	Next
    
return aTabMov

/*/{Protheus.doc} A927TabCAD
//TODO Descrição auto-gerada.
Retorna supostas tabelas de cadastro do sistema
@author MOHAMED S B DJALO
@since 04/08/2019
@version undefined

@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Function A927TabCAD()
    Local aTabCad    := {}
    Local nIndex     := 33 //começa em 33 porque ja tem ate 32
    Local cAliasEmp  := GetNextAlias()
    Local i          := 1
    Local cQuery     := ''
    
    Local aTabMov := A927MOV_TAB()
    Local cTabMov := ''
    
    For i := 1 To Len(aTabMov)
        If (!Empty(cTabMov))
            cTabMov += ','
        EndIf
        
        cTabMov += "'"+aTabMov[i][1]+"'"
    Next
    
    cQuery += ' select tab.[name] as table_name,                              '
	cQuery += '        col.[name] as column_name,                             '
	cQuery += '        schema_name(tab.schema_id) as [schema_name],           '  
	cQuery += '        pk.[name] as pk_name,                                  '
	cQuery += '        ic.index_column_id as column_id                        '
	cQuery += ' from sara_log.sys.tables tab                                  '
	cQuery += '     inner join sara_log.sys.indexes pk                        '
	cQuery += '         on tab.object_id = pk.object_id                       '
	cQuery += '         and pk.is_primary_key = 1                             '
	cQuery += '     inner join sara_log.sys.index_columns ic                  '
	cQuery += '         on ic.object_id = pk.object_id                        '
	cQuery += '         and ic.index_id = pk.index_id                         '
	cQuery += '     inner join sara_log.sys.columns col                       ' 
	cQuery += '         on pk.object_id = col.object_id                       '
	cQuery += '         and col.column_id = ic.column_id                      ' 
	cQuery += " WHERE substring(tab.[name],1,4) = 'tab_'                      "
	cQuery += '   and tab.[name] NOT IN ('+cTabMov+')                         '
	cQuery += '   and substring(tab.[name],5,3) = substring(col.[name],1,3)   '
	cQuery += '   ORDER BY TABLE_NAME                                         ' 
	
    cQuery := ChangeQuery(cQuery)
    
    DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasEmp,.F.,.T.)
    
    dbSelectArea(cAliasEmp)
    (cAliasEmp)->(DbGoTop())
    while (cAliasEmp)->(!EOF())
         Aadd(aTabCad,{(cAliasEmp)->table_name,nIndex,(nIndex+1)})
         nIndex := nIndex + 2
        (cAliasEmp)->(DbSkip())
    EndDo
    (cAliasEmp)->(dbCloseArea())
return aTabCad

Function A907FieldSize(cTabela)
    Local cQuery     := ''
    Local cAliasEmp  := GetNextAlias()
    Local aTabRet    := {}
    
   
    cQuery := 'select top 1  max_length,col.name             '    
	cQuery += 'from sara_log.sys.tables tab                  '      
	cQuery += '    inner join sara_log.sys.indexes pk        '      
	cQuery += '        on tab.object_id = pk.object_id       '      
	cQuery += '        and pk.is_primary_key = 1             '      
	cQuery += '    inner join sara_log.sys.index_columns ic  '      
	cQuery += '        on ic.object_id = pk.object_id        '      
	cQuery += '        and ic.index_id = pk.index_id         '      
	cQuery += '    inner join sara_log.sys.columns col       '      
	cQuery += '        on pk.object_id = col.object_id       '      
	cQuery += '        and col.column_id = ic.column_id      ' 
	cQuery += ' where tab.[name] = '+cTabela+'               '
	//cQuery += " and substring(tab.[name],5,3)+'%id' like substring(col.name,1,3)+'%id'"
	
	cQuery := ChangeQuery(cQuery)
    
    DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasEmp,.F.,.T.)
    
    dbSelectArea(cAliasEmp)
    (cAliasEmp)->(DbGoTop())
     Aadd(aTabRet,{(cAliasEmp)->name,(cAliasEmp)->max_length})
    (cAliasEmp)->(dbCloseArea())
   
Return aTabRet
