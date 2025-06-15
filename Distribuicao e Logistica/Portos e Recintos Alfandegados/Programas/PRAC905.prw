#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC905.CH"

#define INFO_ZOOM_TIPO_EXECUCAO_SQL   1

/*/{Protheus.doc} PRAC905
@author   Felipe Machado de Oliveira
@version  P12
@since    18/07/2012
@obs      Extrato de movimentação
/*/

Function PRAC905()
	Local oDlg         := nil
	Local aFields      := {}
	Local oPanel       := nil
	Local oLayer       := nil
	Local aFilParser   := {}
	Local aCoors       := FWGetDialogSize(oMainWnd)
	Local oBrowse      := nil
	Private cAliasTb   := SGetNAlias()
	Private nColSize   := 0
	Private aStructDesc
	Private aStruct

	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

		oLayer := FWLayer():new()
		oLayer:init(oDlg,.F.)
		oLayer:addColumn('Col01',100,.F.)
		oLayer:addWindow('Col01','C1_Win01',STR0001,100,.T.,.F.,,,)

		oPanel  := oLayer:getWinPanel('Col01','C1_Win01')
 						//Campo, Descricao, Tipo , Tamanho   , Alias , Mascara         , Nil , Zoom          , Validacao , ValorPadrao
 		Aadd(aFields, {"P0"  , STR0002   , "C"  , 20        , nil   , "@R 99/999999-9"  , nil , "C905ZOOML(o)" , {|xConteud, o| C905VLOTE(xConteud, o)} , nil})				
		
		aStructDesc := C905CTB(@aStruct)

		oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)

		aFilParser := {}
		SAddFilPar("P0","==","%P0%",@aFilParser)
	
	    oBrowse:AddFilter(STR0003, "P0=='%P0%'", .T., .T.,nil,.T., aFilParser, '0')

		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros

		oBrowse:oFWFilter:SetExecute({||C905FILTER(oBrowse)})

		oBrowse:oFWFilter:FilterBar(nil,.F.,.F.)

	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTb(cAliasTb)

return

Static Function C905FILTER(oBrowse)
	Local cQuery      := "exec proc_rfb_s_extr_mov_merc_cnt_w"
	Local cParams     := ""
	Local oColumn
	Local nI          := 0
	Local oFilter     := oBrowse:FWFilter()
	Local aFilter     := nil
	Local cMsg        := ""
	Local cCampo      := ''

	aFilter := oFilter:GetFilter(.T.)

	if !SVALFILTRO(oFilter)
		alert(STR0004)
		return
	endif

	if (!C905GF(aFilter, @cParams, @cMsg))
		if (!SEmpty(cMsg))
			alert(cMsg)
		endif
		return
	endif

	cQuery += " " + cParams

    TcSqlExec(cQuery)
    TcRefresh(cAliasTb) 

	(cAliasTb)->(dbCloseArea())
	DbUseArea(.T.,'TOPCONN',cAliasTb,cAliasTb,.T.,.F.)

	nColSize := Len(oBrowse:aColumns)
	for nI := 1 to nColSize
		oBrowse:DelColumn(nI)
	next

	nColSize := Len(aStruct)

	for nI := 2 to nColSize
		oColumn := nil

		cCampo := STransType(aStruct[nI][1])
		cCampo := "{|| "+cCampo+"}"

		oColumn := FWBrwColumn():New()
		oColumn:SetData(  &(cCampo) )
		oColumn:SetTitle( aStructDesc[nI][1]   )
		oColumn:SetSize(  aStructDesc[nI][2]   )

		oBrowse:SetColumns({oColumn})
	next
	
	oBrowse:SetBlkBackColor( { || C905COLORB()} )	
	oBrowse:SetBlkColor( { || C905COLOR()} )
	oBrowse:UpdateBrowse()

return


Static Function C905GF(aFilter, cParams, cMsg)
	Local cPar := ''

	if SEmpty(aFilter)
		cMsg := STR0005
		return .F.
	endif
	
	if (aFilter == nil .OR. SEmpty(aFilter[1][4][3][1]))
		cMsg := STR0005
		return .F.
	endif
	
	cPar := STransType(aFilter[1][4][3][1],"C")
	
	cParams += "'"+STrim(cPar)+"',"
	cParams += "'"+SGetDBOwner()+cAliasTb+"'"

return .T.

Function C905ZOOML(oObj)
	Local aZoom    := {}
	Local aRetZoom := {}
	Local lRet := .T.

	aZoom    := C905ZLOTE()
	aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

	if (!SEmpty(aRetZoom))
	   oObj:cText := StrTran(StrTran(STransType(aRetZoom[1],"C"),"/",""),"-","")
	else
	   oObj:cText := nil
	endif
return lRet

Function C905VLOTE(xConteud, o)
	if !SEmpty(xConteud)
		if C905ZOOML(o)
			return .T.
		else
			Alert(STR0006)
			return .F.
		endif
	endif
return .T.


Function C905ZLOTE()
	Local aRet := {}
	Local aFields := {}
	Local cQuery := ""

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	cQuery := "select "+;
	                 " substring(tab_lote.lote_id_rf,1,2)+'/'+"+;
                     " substring(tab_lote.lote_id_rf,3,6)+'-'+"+;
                     " substring(tab_lote.lote_id_rf,9,1) as lote_id_rf,"+;
	                 "tab_lote.lote_id, tab_clientes.cli_nome, "+;
	                 "tab_lote.lote_conhec from tab_clientes, tab_lote "+;
	                 "where tab_clientes.cli_id = tab_lote.ben_id "+;
	                 "and tab_lote.lote_cancelado is null "
	
	Aadd(aRet, cQuery)
	Aadd(aRet, 'order by tab_lote.lote_id')

              //aFields, cCampo        , cDesc    , cTipo, nTamanho, nPrecisao, cMascara , lVisivel, lRetorna
	SAddPField(@aFields , "lote_id_rf"  , STR0002 , "C"  , 12      , 0        , "@R 99/999999-9" , .T.     , .T., .T., 1)
	SAddPField(@aFields , "lote_id"     , STR0020 , "C"  , 12      , 0        , ""       , .T.     , .T., .T., 1)
	SAddPField(@aFields , "cli_nome"    , STR0007 , "C"  , 30      , 0        , ""       , .T.     , .F.)
	SAddPField(@aFields , "lote_conhec" , STR0008 , "C"  , 30      , 0        , ""       , .T.     , .F.)

	Aadd(aRet, aFields)

Return aRet

Static Function C905CTB(aStruct)
		
	aStructDesc := {;	    
	    {STR0010 , 20}, ;
	    {STR0002 , 35}, ;	 	    
	    {STR0011 , 10}, ;
	    {STR0012 , 20}, ;
	    {STR0013 , 20}, ;
	    {STR0014 , 10}, ;
	    {STR0015 , 10}, ;
	    {STR0016 , 10}, ;
	    {STR0017 , 10}, ;
	    {STR0018 , 10}, ;
	    {STR0019 , 10}  ;
	}

	aStruct := {;
	    {'CP1'  ,'C',100,0}, ;
	    {'CP2'  ,'C',100,0}, ;
	    {'CP3'  ,'C',100,0}, ;
	    {'CP4'  ,'C',100,0}, ;
	    {'CP5'  ,'C',100,0}, ;
	    {'CP6'  ,'C',100,0}, ;
	    {'CP7'  ,'C',100,0}, ;
	    {'CP8'  ,'C',100,0}, ;
	    {'CP9'  ,'C',100,0}, ;
	    {'CP10' ,'C',100,0}, ;
	    {'CP11' ,'C',100,0}  ;
	}

	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
	
return aStructDesc


/*Funções criadas para alterar a cor da linha do grid e do fonte da linha, quando é uma linha de agrupamento*/
//-------------------------------------------------------------------
/*/{Protheus.doc} C940COLOR
Funcao que sera executada para trocar a cor do fonte do grid

@author  A
@since   dd/mm/yyyy
@version P12
@protected
/*/
//-------------------------------------------------------------------

Static Function C905COLOR()
  if (Substr(AllTrim((cAliasTb)->CP2),1,7) == "Armazém")  
     Return CLR_HBLUE
  endif  
return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} C940COLORB
Funcao que sera executada para trocar a cor de fundo do grid

@author  A
@since   dd/mm/yyyy
@version P12
@protected
/*/
//-------------------------------------------------------------------

Static Function C905COLORB()
  if (Substr(AllTrim((cAliasTb)->CP2),1,7) == "Armazém")
     Return CLR_HGRAY
  endif    
return Nil


