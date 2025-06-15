#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC920.CH"

#define INFO_ZOOM_TIPO_EXECUCAO_SQL   1

/*/{Protheus.doc} PRAC920
@author   Felipe Machado de Oliveira
@version  P12
@since    08/06/2012
@obs      2.2.4 - Conteúdo de nota fiscal
/*/
Function PRAC920()

   Local oDlg          := nil                       //Janela
   Local aFields       := {}                        //Campos de pesquisa
   Local oPanel        := nil                       //Painel
   Local oLayer        := nil                       //Layout
   Local aFilParser    := {}                        //Configuração dos filtros
   Local aCoors        := FWGetDialogSize(oMainWnd) //Coordenada da janela
   Local oBrowse       := nil                       //GRID
   Private cAliasTb    := SGetNAlias()              //Tabela temporária
   Private nColSize    := 0                         //Quantidade de registros
   Private aStructDesc
   Private aStruct
   Private nAno

   nAno := year(date())

   DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

      oLayer := FWLayer():new() //Cria uma camada na janela
      oLayer:init(oDlg,.F.)
      oLayer:addColumn('Col01',100,.F.) //Adiciona uma coluna na camada
      oLayer:addWindow('Col01','C1_Win01',STR0001,100,.T.,.F.,,,) //Adiciona um componente de windows na camada e coluna

      oPanel  := oLayer:getWinPanel('Col01','C1_Win01')
                  //Campo  , Descricao, Tipo, Tamanho, Alias, Mascara  , Nil, Zoom            , Validacao     , ValorPadrao
      Aadd(aFields, {"P1"  , STR0002 , "N" , 4      , nil  , '####'   , nil, nil             , {|xConteud| C920VALANO(xConteud)}       , nAno})
      Aadd(aFields, {"P2"  , STR0003 , "C" , 50     , nil  , nil      , nil, "C920ZOOMP(o,1)", {|xConteud, o| C920VALNUM(xConteud, o)} , nil})
      Aadd(aFields, {"P3"  , 'CNPJ emissor', "C", 14, nil  , "@R 99.999.999/9999-99", nil, "C920ZOOMP(o,2)", {|xConteud, o| C920VALEMI(xConteud, o)} , nil})      

      aStructDesc := C920CTB(@aStruct)

		oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)

		oBrowse:AddFilter(STR0004, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3=='%P3%'", .T., .T.,nil,.T., aFilParser, '0')

		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros
		oBrowse:oFWFilter:SetExecute({||C920FILTER(oBrowse)})
		oBrowse:oFWFilter:FilterBar(nil,.F.,.F.)

	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTb(cAliasTb)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} C920FILTER
Funcao que sera executada no momento em que o filtro for acionado, para tratar as informações

@param oBrowse Variavel que contem a GRID do programa

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function C920FILTER(oBrowse)

	Local cQuery      := "exec proc_rfb_busca_notas_w"
	Local cParams     := ""
	Local oColumn
	Local nI          := 0
	Local oFilter     := oBrowse:FWFilter()
	Local aFilter     := nil
	Local cMsg := ""
	Local cCampo := ''

	aFilter := oFilter:GetFilter(.T.)

	if !SVALFILTRO(oFilter)
		alert(STR0005)
		return
	endif

	if (!C920GF(aFilter, @cParams, @cMsg))
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

	for nI := 1 to nColSize
		oColumn := nil

		cCampo := STransType(aStruct[nI][1])
		cCampo := "{|| "+cCampo+"}"

		oColumn := FWBrwColumn():New()
		oColumn:SetData(  &(cCampo) )
		oColumn:SetTitle( aStructDesc[nI][1]   )
		oColumn:SetSize(  aStructDesc[nI][2]   )

		oBrowse:SetColumns({oColumn})
	next
	
    oBrowse:SetBlkBackColor( { || C920COLORB()} )	
	oBrowse:SetBlkColor( { || C920COLOR()} )
	
	oBrowse:UpdateBrowse()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} C920GF
Processa os filtros para recuperar os parametros para as procedures

@param aFilter Informacoes selecionadas pelo usuario
@param cParams Variavel que retornara os parametros da procedure
@param cMsg Variavel que retorna mensagem de erro caso houver

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function C920GF(aFilter, cParams, cMsg)
	Local nNota
	Local nTipo
	Local nNum
	Local nCNPJEmi

	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif

   nAno  := (aFilter[1][4][3][1])
   nNota := (aFilter[1][4][6][1])
   nCNPJEmi := (aFilter[1][4][9][1])

	if SEmpty(nNota)
		cMsg := STR0036
		return .F.
	endif

   C920STNF(nAno, nNota, @nTipo, @nNum)

	cParams += "'"+STransType(nNum)+"',"
	cParams += "'"+STransType(nTipo)+"',"
	if Rtrim(Ltrim(STransType(nCNPJEmi))) <> ''
	  cParams += "'"+Rtrim(Ltrim(STransType(nCNPJEmi)))+"',"
	else
	  cParams += "null,"
	end if

	cParams += "'"+SGetDBOwner()+cAliasTb+"'"
return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} C920STNF
Funcao que busca o tipo da nota fiscal e o codigo do mesmo.

@param nAno Ano selecionado pelo usuario
@param nNota Nota Fiscal selecionada pelo usuario
@param nTipo Variavel que retorna o tipo da nota fiscal
@param nNum Variavel que retorna o numero da nota fiscal que sera passado como parametro para a procidure

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function C920STNF(nAno, nNota, nTipo, nNum)

	Local cAlias := ''
	Local cQuery := ''

	if (!SEmpty(nAno) .and. !SEmpty(nNota))
		cAlias := SGetNAlias()

		if (!SEmpty(nAno) .and. !SEmpty(nNota))
			cQuery := "select distinct " +;
	                 "  tipo_nota, " +;
	                 "  numero " +;
	                 "from " +;
	                 "  vw_not_fisc_compil  "+;
	                 "where " +;
	                 "  ano_nota_fiscal = '" +STransType(nAno)+ "'" +;
	                 "  and num_nota_fiscal = '" +STransType(nNota)+ "'"
		endif

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		nTipo := (cAlias)->(Fieldget(1))
		nNum  := (cAlias)->(Fieldget(2))

		(cAlias)->(dbCloseArea())
	endif

return

*-------------------------*
function C920VALANO(xConteud)
*-------------------------*

   if xConteud != nAno
      nAno := xConteud
   endif

return

*-------------------------*
Function C920VALNUM(xConteud, o)
*-------------------------*
	if !SEmpty(xConteud)
		if C920ZOOMP(o,1)
			return .T.
		else
			Alert(STR0006)
			return .F.
		endif
	endif
return

Function C920VALEMI(xConteud, o)
*-------------------------*
	if !SEmpty(xConteud)
		if C920ZOOMP(o,2)
			return .T.
		else
			Alert('CNPJ do emissor inválido')
			return .F.
		endif
	endif
return

//-------------------------------------------------------------------
/*/{Protheus.doc} C920ZOOMP
Funcao que seleciona o ZOOM para o usuario

@param oObj Objeto que o resultado do zoom ira retornar

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function C920ZOOMP(oObj, nTipoZoom)

	Local aZoom    := {}
	Local aRetZoom := {}
	Local lRet := .T.
    
    if nTipoZoom == 1
	  aZoom    := C920ZNFANO(nAno)
	  aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)
  
      if (!SEmpty(aRetZoom))
        oObj:cText := aRetZoom[1]
	  else
		oObj:cText := nil
	  endif
	end if
	
	if nTipoZoom == 2
	  aZoom    := SZoomCliCJ()// SZoomConsig(.F.,.T.,.F.)

	  aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)
  
      if (!SEmpty(aRetZoom))
        oObj:cText := aRetZoom[1]
	  else
		oObj:cText := nil
	  endif
	end if

return lRet

*-----------------------*
Function C920ZNFANO(nAno)
*-----------------------*
	Local aRet := {}
	Local aFields := {}

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	Aadd(aRet,'select distinct '+;
				' tipo_nota, ' +;
              ' numero, ' +;
              ' num_nota_fiscal, ' +;
              ' ser_nota_fiscal, ' +;
              ' ano_nota_fiscal ' +;
				' from '+;
				' vw_not_fisc_compil '+;
				" where ano_nota_fiscal = '"+STransType(nAno)+"'")
	Aadd(aRet, '')

   SAddPField(@aFields , "tipo_nota"        , STR0007 , "C"  , 20  , 0  , ""  , .F.   , .F.)
   SAddPField(@aFields , "numero"           , STR0008 , "C"  , 20  , 0  , ""  , .F.   , .F.)
   SAddPField(@aFields , "num_nota_fiscal"  , STR0003 , "C"  , 20  , 0  , ""  , .T.   , .T., .T., 1)
   SAddPField(@aFields , "ser_nota_fiscal"  , STR0009 , "C"  , 20  , 0  , ""  , .T.   , .F.)
   SAddPField(@aFields , "ano_nota_fiscal"  , STR0002 , "C"  , 20  , 0  , ""  , .T.   , .F.)

	aadd(aRet, aFields)

return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C920CTB
Funcao que cria a estrutura da tabela

@param aStruct Variave que retornara a estrutura dos campos da tabela
@return aStructDesc Variavel que retornara a descricao dos campos da tabela

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function C920CTB(aStruct)

	aStructDesc := {;
	    {STR0003 , 20}, ;
	    {'Série' , 20}, ;	    
	    {STR0026 , 20}, ;	    
	    {"Valor Item" , 20}, ;
	    {STR0011 , 20}, ;
	    {STR0014 , 20}, ;
	    {STR0015 , 20}, ;
	    {STR0016 , 20}, ;
	    {STR0017 , 20}, ;
	    {STR0018 , 20}, ;
	    {STR0019 , 20}, ;
	    {STR0020 , 20}, ;
	    {STR0021 , 20}, ;
	    {STR0022 , 20}, ;
	    {STR0012 , 20}, ;
	    {STR0023 , 20}, ;
	    {STR0024 , 20}, ;
	    {STR0025 , 20}, ;
	    {STR0027 , 20}, ;
	    {STR0028 , 20}, ;
	    {STR0029 , 20}, ;
	    {STR0030 , 20}, ;
	    {STR0031 , 20}, ;
	    {STR0032 , 20}, ;
	    {STR0033 , 20}, ;
	    {STR0034 , 20}, ;
	    {STR0035 , 20}  ;
	}

	aStruct := {;
	    {'CP1' ,'C',100,0} , ;
	    {'CP2','C',100,0}, ;
	    {'CP3' ,'C',100,0} , ;
	    {'CP4' ,'C',100,0}, ;
	    {'CP5' ,'C',100,0}, ;
	    {'CP6' ,'C',100,0}, ;
	    {'CP7' ,'C',100,0} , ;
	    {'CP8' ,'C',100,0} , ;
	    {'CP9' ,'C',100,0} , ;
	    {'CP10' ,'C',100,0} , ;
	    {'CP11','C',100,0} , ;
	    {'CP12','C',100,0} , ;
	    {'CP13','C',100,0} , ;
	    {'CP14','C',100,0} , ;
	    {'CP15','C',100,0} , ;
	    {'CP16','C',100,0}, ;
	    {'CP17','C',100,0} , ;	    
	    {'CP18','C',100,0}, ;
	    {'CP19','C',100,0} , ;
	    {'CP20','C',100,0} , ;
	    {'CP21','C',100,0}, ;
	    {'CP22','C',100,0}, ;
	    {'CP23','C',100,0}, ;
	    {'CP24','C',100,0}, ;
	    {'CP25','C',100,0}, ;
	    {'CP26','C',100,0}, ;
	    {'CP27','C',100,0}  ;
	}
	
	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
	
return aStructDesc


/*Funções criadas para alterar a cor da linha do grid e do fonte da linha, quando é uma linha de agrupamento*/
//-------------------------------------------------------------------
/*/{Protheus.doc} C920COLOR
Funcao que sera executada para trocar a cor do fonte do grid

@author  A
@since   dd/mm/yyyy
@version P12
@protected
/*/
//-------------------------------------------------------------------

Static Function C920COLOR()
  if (Substr(AllTrim((cAliasTb)->CP4),1,17) == "Descrição do Item") .OR. (Substr(AllTrim((cAliasTb)->CP4),1,11) == "Nota Fiscal")  
     Return CLR_HBLUE
  endif  
return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} C920COLORB
Funcao que sera executada para trocar a cor de fundo do grid

@author  A
@since   dd/mm/yyyy
@version P12
@protected
/*/
//-------------------------------------------------------------------

Static Function C920COLORB()
  if (Substr(AllTrim((cAliasTb)->CP4),1,17) == "Descrição do Item") .OR. (Substr(AllTrim((cAliasTb)->CP4),1,11) == "Nota Fiscal")  
     Return CLR_HGRAY
  endif    
return Nil

