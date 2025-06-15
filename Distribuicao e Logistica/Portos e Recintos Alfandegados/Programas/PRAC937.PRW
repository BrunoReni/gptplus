#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC937.CH"

/*/{Protheus.doc} PRAC937
@author   Marcio Franklin Carvalho de Noronha
@version  P12
@since    16/07/2012
@obs      Ocupação armazém
/*/

Function PRAC937()
	Local oDlg       := nil                       //Janela
	Local aFields    := {}                        //Campos de pesquisa
	Local oPanel     := nil                       //Painel
	Local oLayer     := nil                       //Layout
	Local aFilParser := {}                        //Configuração dos filtros
	Local aCoors     := FWGetDialogSize(oMainWnd) //Coordenada da janela
	Local oBrowse    := nil                       //GRID
	Local nI         := 0
	Local nMax       := 0
	Local aSeek      := {}
	Local aIndex     := {}

	Private cAliasTb := SGetNAlias()              //Tabela temporária
	Private nColSize := 0                         //Quantidade de registros
	Private nTipoDoc := '-1'
	Private aStructDesc
	Private aStruct
	Private cArma := ''

	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

		oLayer := FWLayer():new() //Cria uma camada na janela
		oLayer:init(oDlg,.F.)
		oLayer:addColumn('Col01',100,.F.) //Adiciona uma coluna na camada
		oLayer:addWindow('Col01','C1_Win01',STR0001,100,.T.,.F.,,,) //Adiciona um componente de windows na camada e coluna

		oPanel  := oLayer:getWinPanel('Col01','C1_Win01') //Recupera o objeto do Window

		//Adiciona no array os campos de filtro da tela
						//Campo, Descricao   , Tipo, Tamanho, Alias, Mascara            , Nil, Zoom            , Validacao                               , ValorPadrao
		Aadd(aFields, {"P1"  , STR0002     , "C" , 10     , nil  , ""                 , nil, ""              , nil                                     , nil})
		Aadd(aFields, {"P2"  , STR0003     , "C" ,  30    , nil  , ""                 , nil, "C937ZOOMP(o, 1)", {|xConteud, o| C937VLARM(xConteud, o)}   , nil})
		Aadd(aFields, {"P3"  , "Opcao"     , "C" ,  1     , nil  , ""                 , nil, nil             , nil                                     , nil})

		C937CTB()

		//Cria um componente de browse no window
		oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","0"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0002, "P1==NULL .AND. P2=='%P2%' .AND. P3=='0'", .T., .T.,nil,.T., aFilParser, '0')

		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros
		oBrowse:oFWFilter:SetExecute({||C937FILTER(oBrowse)})
		oBrowse:oFWFilter:FilterBar(nil,.F.,.F.)

	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTb(cAliasTb)
Return

Static Function C937FILTER(oBrowse)
	Local cQuery      := "proc_calc_ocup_armazem_w "
	Local cParams     := ""
	Local nMax        := 0
	Local oColumn
	Local nI          := 0
	Local oFilter     := oBrowse:FWFilter()
	Local aFilter     := nil
	Local cMsg := ""
	Local cRet := ''
	Local cCampo := ''

	if !SVALFILTRO(oFilter)
		alert(STR0016)
		return
	endif

	aFilter := oFilter:GetFilter(.T.)

	if (!C937GF(aFilter, @cParams, @cMsg))
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

    oBrowse:SetBlkBackColor( { || C937COLORB()} )	
	oBrowse:SetBlkColor( { || C937COLOR()} )
	
	oBrowse:updateBrowse()

Return .T.

static function C937GF(aFilter, cParams, cMsg)
	Local cCampo1

	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif

	cParams := ""
	cCampo1 := STrim(cArma)
	cParams += "'"+cCampo1+"'"
	cParams += ",'"+SGetDBOwner()+cAliasTb+"'"
return .T.

function C937ZOOMP(oObj, nTipoZoom)
	Local aZoom := {}
	Local aRetZoom := {}
	Local lRet := .T.

   aZoom := SZoomArm()
	aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

	if !SEmpty(aRetZoom)
		oObj:cText := STransType(aRetZoom[2],"C")
		cArma := STransType(aRetZoom[1],"C")
	else
		oObj:cText := '                              '
		cArma := ''
	endif
return lRet

function C937VLARM(xConteud, o)
	cArma := ''

	if !SEmpty(xConteud)
		if C937ZOOMP(o, 1)
			return .T.
		else
			Alert(STR0015)
			return .F.
		end
	end
return

static function C937CTB()
	    aStructDesc := {  ;	    
		{STR0006, 10},;
		{STR0003, 25},;
		{STR0004, 40},;
		{STR0005, 10},;
		{STR0007, 10},;
		{STR0008, 10},;
		{STR0009, 10},;
		{STR0010, 10},;
		{STR0011, 10},;
		{STR0012, 10},;
		{STR0013, 10},;
		{STR0014, 10} ;
	}

	aStruct := {    ;
	    {'CP1'     ,'C',100 ,0}, ;
	    {'CP2'     ,'C',100 ,0}, ;
	    {'CP3'     ,'C',100 ,0}, ;
	    {'CP4'     ,'C',100 ,0}, ;
	    {'CP5'     ,'C',100 ,0}, ;
	    {'CP6'     ,'C',100 ,0}, ;
	    {'CP7'     ,'C',100 ,0}, ;
	    {'CP8'     ,'C',100 ,0}, ;
	    {'CP9'     ,'C',100 ,0}, ;
	    {'CP10'    ,'C',100 ,0}, ;
	    {'CP11'    ,'C',100 ,0}, ;
	    {'CP12'    ,'C',100 ,0}  ;
	    }

	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
return aStructDesc

/*Funções criadas para alterar a cor da linha do grid e do fonte da linha, quando é uma linha de agrupamento*/
//-------------------------------------------------------------------
/*/{Protheus.doc} C937COLOR
Funcao que sera executada para trocar a cor do fonte do grid

@author  A
@since   dd/mm/yyyy
@version P12
@protected
/*/
//-------------------------------------------------------------------

Static Function C937COLOR()
  if (Substr(AllTrim((cAliasTb)->CP2),1,12) == "Área Recinto") .OR. (Substr(AllTrim((cAliasTb)->CP2),1,5) == "Total")  
     Return CLR_HBLUE
  endif  
return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} C937COLORB
Funcao que sera executada para trocar a cor de fundo do grid

@author  A
@since   dd/mm/yyyy
@version P12
@protected
/*/
//-------------------------------------------------------------------

Static Function C937COLORB()
  if (Substr(AllTrim((cAliasTb)->CP2),1,12) == "Área Recinto") .OR. (Substr(AllTrim((cAliasTb)->CP2),1,5) == "Total")  
     Return CLR_HGRAY
  endif    
return Nil