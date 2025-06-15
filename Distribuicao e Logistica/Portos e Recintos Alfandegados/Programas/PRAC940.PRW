#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC940.CH"

/*/{Protheus.doc} PRAC940 
@author   Andre Luiz Custodio
@version  P12
@since    20/06/2013
@obs      Secao 3 - Da Taxa de Ocupacao do Local ou Recinto
/*/
Function PRAC940()

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
 						//Campo, Descricao, Tipo, Tamanho, Alias, Mascara      , Nil, Zoom              , Validacao                              , ValorPadrao
		Aadd(aFields, {"P1"  , STR0002 , "C" , 1         , nil  , nil        , nil, nil               , nil                                    , nil})

		aStructDesc := C940CTB(@aStruct)

		oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)

		aFilParser := {}
		SAddFilPar("P1","==","a",@aFilParser)
		oBrowse:AddFilter(STR0003, "P1=='a'", .F., .F.,nil,.T., aFilParser, '0')

		aFilParser := {}
		SAddFilPar("P1","==","b",@aFilParser)
		oBrowse:AddFilter(STR0004, "P1=='b'", .F., .F.,nil,.T., aFilParser, '1')

		aFilParser := {}
		SAddFilPar("P1","==","c",@aFilParser)
		oBrowse:AddFilter(STR0005, "P1=='c'", .F., .F.,nil,.T., aFilParser, '2')

		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros

		oBrowse:oFWFilter:SetExecute({||C940FILTER(oBrowse)})

		oBrowse:oFWFilter:FilterBar(nil,.F.,.F.)

	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTb(cAliasTb)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} C940FILTER
Funcao que sera executada no momento em que o filtro for acionado, para tratar as informações

@param oBrowse Variavel que contem a GRID do programa

@author  Andre Luiz Custodio
@since   20/06/2013
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function C940FILTER(oBrowse)

	Local cQuery      :="insert into "+cAliasTb+" exec proc_rfb_taxa_ocupacao_w"
	Local cParams     := ""
	Local oColumn
	Local nI          := 0
	Local oFilter     := oBrowse:FWFilter()
	Local aFilter     := nil
	Local cMsg := ""
	Local cCampo := ''

	if !SVALFILTRO(oFilter)
		Alert(STR0006)
		return
	endif

	aFilter := oFilter:GetFilter(.T.)

	if (!C940GF(aFilter, @cParams, @cMsg))
		if (!SEmpty(cMsg))
			alert(cMsg)
		endif
		return
	endif

	 TcSqlExec(" delete from "+cAliasTb)

	cQuery += " " + cParams //+ ", 1"

	TcSqlExec(cQuery)
	TcRefresh(cAliasTb) 

	(cAliasTb)->(dbCloseArea())
	DbUseArea(.T.,'TOPCONN',cAliasTb,cAliasTb,.T.,.F.)

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
	  oColumn:SetData(  &(cCampo) )
	  oColumn:SetTitle( aStructDesc[nI][1]   )
	  oColumn:SetSize (  aStructDesc[nI][2]   )
	  oColumn:SetAlign(aStructDesc[nI][3])

	  oBrowse:SetColumns({oColumn})

	  if (aStructDesc[nI][3] = 2) .and. (aStruct[nI][2] = "N")
		oColumn:SetPicture("########.##")
	  endif

    next


	oBrowse:SetBlkBackColor( { || C940COLORB()} )

	oBrowse:SetBlkColor( { || C940COLOR()} )

	oBrowse:UpdateBrowse()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} C940COLOR
Funcao que sera executada para trocar a cor do fonte do grid

@author  Andre Luiz Custodio
@since   20/06/2013
@version P12
@protected
/*/
//-------------------------------------------------------------------

Static Function C940COLOR()

  if ((cAliasTb)->CP2 <> " ") .Or.((cAliasTb)->CP3 = "TOTAL")
    Return CLR_HBLUE
  endif

return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} C940COLORB
Funcao que sera executada para trocar a cor de fundo do grid

@author  Andre Luiz Custodio
@since   20/06/2013
@version P12
@protected
/*/
//-------------------------------------------------------------------

Static Function C940COLORB()

  if ((cAliasTb)->CP2 <> " ")
    Return CLR_YELLOW
  endif

  if ((cAliasTb)->CP3 = "TOTAL")
    Return CLR_HGRAY
  endif

return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} C940GF
Processa os filtros para recuperar os parametros para as procedures

@param aFilter Informacoes selecionadas pelo usuario
@param cParams Variavel que retornara os parametros da procedure
@param cMsg Variavel que retorna mensagem de erro caso houver

@author  Andre Luiz Custodio
@since   20/06/2013
@version P12
@protected
/*/
//-------------------------------------------------------------------
static function C940GF(aFilter, cParams, cMsg)

	Local cOpcao    := 'b'

	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif

	cOpcao := STransType(aFilter[1][4][3][1])

	do case
		case cOpcao == "a"

 		    cParams = "0"

		case cOpcao == "b"

			cParams = "1"

		case cOpcao == "c"

			cParams = "2"

	endcase

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} C940CTB
Funcao que cria a estrutura da tabela

@param aStruct Variave que retornara a estrutura dos campos da tabela
@return aStructDesc Variavel que retornara a descricao dos campos da tabela

@author Andre Luiz Custodio
@since   20/06/2013
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function C940CTB(aStruct)

	aStructDesc := {     ;
	    {"Armazém" , 5, 1}, ;
	    {"Descrição" , 50, 1}, ;
	    {"Célula", 20, 1}, ;
	    {"Área Total" , 10, 2}, ;
	    {"Área Ocupada" , 10, 2}, ;
	    {"Taxa Ocupação" , 10, 2} ;
	}

	aStruct := {    ;
	    {'CP1' ,'C',100 ,0}, ;
	    {'CP2' ,'C',100 ,0}, ;
	    {'CP3' ,'C',100 ,0}, ;
	    {'CP4' ,'N',18 ,4}, ;
	    {'CP5' ,'N',18 ,4}, ;
	    {'CP6' ,'C',100 ,8} ;
	}

	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
return aStructDesc