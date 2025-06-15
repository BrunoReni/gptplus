#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC922.CH"

#define INFO_ZOOM_TIPO_EXECUCAO_SQL   1

/*/{Protheus.doc} PRAC922
@author   Felipe Machado de Oliveira
@version  P12
@since    14/06/2012
@obs      2.2.6 - Histórico de Movimentação de Veículos e Containers
/*/ 
Function PRAC922()

	Local oDlg         := nil
	Local aFields      := {}
	Local oPanel       := nil
	Local oLayer       := nil
	Local aFilParser   := {}
	Local aCoors       := FWGetDialogSize(oMainWnd)
	Local oBrowse      := nil
	Private cAliasTb   := ''
	Private nColSize   := 0
	Private aStructDesc
	Private aStruct
	Private nCodAll
	Private cOpcao := ''
	Private cTipoAg := ''
	static a_TPO_AG := {'1=Documento de Saída','2=CESV'}

	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

		oLayer := FWLayer():new()
		oLayer:init(oDlg,.F.) 
		oLayer:addColumn('Col01',100,.F.)
		oLayer:addWindow('Col01','C1_Win01',STR0001,100,.T.,.F.,,,)

		oPanel  := oLayer:getWinPanel('Col01','C1_Win01')
                    //Campo , Descricao     ,Tipo , Tam , Ali  , Mascara , Nil     , Zoom             , Vali                                   , ValorPadrao
		Aadd(aFields, {"P1"  , STR0002       , "D" , 20  , nil  , nil     , nil     , nil              , nil                                    , (Date() - 30)})
		Aadd(aFields, {"P2"  , STR0003       , "D" , 20  , nil  , nil     , nil     , nil              , nil                                    ,  Date()})
		Aadd(aFields, {"P3"  , STR0004       , "C" , 20  , nil  , nil     , nil     , "C922ZOOMM(o, 1)", {|xConteud, o| C922VPLAC(xConteud, o)} ,  nil})
		Aadd(aFields, {"P4"  , STR0005       , "C" , 23  , nil  , nil     , nil     , "C922ZOOMM(o, 2)", {|xConteud, o| C922VTRAN(xConteud, o)} ,  nil})
		Aadd(aFields, {"P5"  , STR0006       , "C" , 30  , nil  , nil     , nil     , "C922ZOOMM(o, 3)", {|xConteud, o| C922VCOND(xConteud, o)} ,  nil})
		Aadd(aFields, {"P6"  , STR0007       , "C" , 20  , nil  , nil     , nil     , "C922ZOOMM(o, 4)", {|xConteud, o| C922VPAI(xConteud, o)}  ,  nil})
		Aadd(aFields, {"P7"  , STR0008       , "C" , 20  , nil  , nil     , nil     , "C922ZOOMM(o, 5)", {|xConteud, o| C922VCNTA(xConteud, o)} ,  nil})
		Aadd(aFields, {"P8"  , STR0009       , "C" ,  2  , nil  , nil     , nil     , nil              , nil                                    ,  nil})
		Aadd(aFields, {"P9"  , "Agrupamento" , "C" , 20  , nil  , nil     , a_TPO_AG, nil              , nil                                    ,  nil})

		cAliasTb := SCTBTMPG() 

		oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)  

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","0",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		oBrowse:AddFilter(STR0010, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3=='%P3%' .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8=='0' .AND. P9==NULL", .F., .F.,nil,.T., aFilParser, '0')

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","%P4%",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","1",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		oBrowse:AddFilter(STR0011, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3==NULL .AND. P4=='%P4%' .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8=='1' .AND. P9==NULL", .F., .F.,nil,.T., aFilParser, '1')

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","%P5%",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","2",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		oBrowse:AddFilter(STR0012, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3==NULL .AND. P4==NULL .AND. P5=='%P5%' .AND. P6==NULL .AND. P7==NULL .AND. P8=='2' .AND. P9==NULL", .F., .F.,nil,.T., aFilParser, '2')

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","%P6%",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","3",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		oBrowse:AddFilter(STR0013, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6=='%P6%' .AND. P7==NULL .AND. P8=='3' .AND. P9==NULL", .F., .F.,nil,.T., aFilParser, '3')

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","4",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		oBrowse:AddFilter(STR0014, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8=='4' .AND. P9==NULL", .F., .F.,nil,.T., aFilParser, '4')

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","5",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		oBrowse:AddFilter(STR0015, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8=='5' .AND. P9==NULL", .F., .F.,nil,.T., aFilParser, '5')

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","6",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		oBrowse:AddFilter(STR0016, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8=='6' .AND. P9==NULL", .F., .F.,nil,.T., aFilParser, '6')

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","%P7%",@aFilParser)
		SAddFilPar("P8","==","7",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		oBrowse:AddFilter(STR0017, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7=='%P7%' .AND. P8=='7' .AND. P9==NULL", .F., .F.,nil,.T., aFilParser, '7')

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","8",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		oBrowse:AddFilter(STR0018, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8=='8' .AND. P9==NULL", .F., .F.,nil,.T., aFilParser, '8')

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","9",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		oBrowse:AddFilter(STR0019, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8=='9' .AND. P9==NULL", .F., .F.,nil,.T., aFilParser, '9')

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","10",@aFilParser)
		SAddFilPar("P9","==","%P9%",@aFilParser)
		oBrowse:AddFilter(STR0020, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8=='10' .AND. P9=='%P9%'", .F., .F.,nil,.T., aFilParser, '10')

		oBrowse:SetDoubleClick({|| C922DBLCLI()})
		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros
			   
		oBrowse:oFWFilter:SetExecute({||C922FILTER(oBrowse)})
		oBrowse:oFWFilter:FilterBar(nil,.F.,.F.)

	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTb(cAliasTb)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} C922FILTER
Funcao que sera executada no momento em que o filtro for acionado, para tratar as informações

@param oBrowse Variavel que contem a GRID do programa

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function C922FILTER(oBrowse)

	Local cQuery      := "exec proc_rfb_s_hist_mov_vei_cnt_w"
	Local cParams     := ""
	Local oColumn
	Local nI          := 0
	Local oFilter     := oBrowse:FWFilter()
	Local aFilter     := nil
	Local cMsg := ""
	Local cCampo := ''
	Local nX := 0

    ncodall := ''
	if !SVALFILTRO(oFilter)
		alert(STR0021)
		return
	endif

	aFilter := oFilter:GetFilter(.T.)

	if (!C922GF(aFilter, @cParams, @cMsg))
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

    if cOpcao == '10'
    	nX := 2
    else
    	nX := 1
    endif

	for nI := nX to nColSize
		oColumn := nil

		cCampo := STransType(aStruct[nI][1])
		cCampo := "{|| "+cCampo+"}"

		oColumn := FWBrwColumn():New()
		oColumn:SetData(  &(cCampo) )
		oColumn:SetTitle( aStructDesc[nI][1]   )
		oColumn:SetSize(  aStructDesc[nI][2]   )

		oBrowse:SetColumns({oColumn})
	next
    if cOpcao == '10'
      oBrowse:SetBlkBackColor( { || C922COLORB()} )	
	  oBrowse:SetBlkColor( { || C922COLOR()} )
	end if
	oBrowse:UpdateBrowse()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} C922GF
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
static function C922GF(aFilter, cParams, cMsg)	
   Local aRetZoom := {}
	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif

	cOpcao := STransType(aFilter[1][4][24][1])
   cTipoAg := STransType(aFilter[1][4][27][1])
   
	C922CTMP()

	do case
		case cOpcao == '0' //Por veículo

			if SEmpty(aFilter[1][4][9][1])
				cMsg := STR0061
				return .F.
			endif

			cParams += "'"+STrim(SDBDate(aFilter[1][4][3][1], '00:00:00'))+"',"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][6][1], '23:59:59'))+"',"
			cParams += "NULL,"
			cParams += "'"+STrim(STransType(aFilter[1][4][9][1]))+"'"
			cParams += ",NULL,NULL,NULL,NULL,"

		case cOpcao == '1' // Veículos por transportador

			cParams += "'"+STrim(SDBDate(aFilter[1][4][3][1], '00:00:00'))+"',"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][6][1], '23:59:59'))+"',"
			cParams += "NULL,NULL,NULL,"
			
			if (SEmpty(nCodAll)) .AND. (.NOT.(SEmpty(aFilter[1][4][12][1])))
			  aRetZoom := PRAC938(SZoomTransp(.T., .T., .F., .T.),; 
			                      STrim(STransType(aFilter[1][4][12][1])), .T.)
			  if !SEmpty(aRetZoom)
			    nCodAll := STrim(STransType(aRetZoom[1]))
			  endif	  
			endif
			
			if SEmpty(nCodAll)
				cParams += "NULL"
			else
				cParams += "'"+STransType(nCodAll)+"'"
			endif
			cParams += ",NULL,NULL,"
			
		case cOpcao == '2' //Veículos por condutor          
			cParams += "'"+STrim(SDBDate(aFilter[1][4][3][1], '00:00:00'))+"',"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][6][1], '23:59:59'))+"',"
			if (SEmpty(nCodAll)) .AND. (.NOT.(SEmpty(aFilter[1][4][15][1])))
			  aRetZoom := PRAC938(SZoomPesRod(.T., .T., .F., .F., .T., .F., .F., .F.),; 
			                      STrim(STransType(aFilter[1][4][15][1])), .T.)
			  if !SEmpty(aRetZoom)
			    nCodAll := STrim(STransType(aRetZoom[1]))
			  endif	  
			endif
			
			if SEmpty(nCodAll)
				cParams += "NULL"
			else
				cParams += "'"+STransType(nCodAll)+"'"
			endif
			cParams += ",NULL,NULL,NULL,NULL,NULL,"

		case cOpcao == '3' //Veículos por país de destino

			cParams += "'"+STrim(SDBDate(aFilter[1][4][3][1], '00:00:00'))+"',"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][6][1], '23:59:59'))+"',"
			cParams += "NULL,NULL,"
			
			if (SEmpty(nCodAll)) .AND. (.NOT.(SEmpty(aFilter[1][4][18][1])))
			  aRetZoom := PRAC938(SZoomPais(.T.,.T.),; 
			                      STrim(STransType(aFilter[1][4][18][1])), .T.)
			  if !SEmpty(aRetZoom)
			    nCodAll := STrim(STransType(aRetZoom[1]))
			  endif	  
			endif
			
			if SEmpty(nCodAll)
				cParams += "NULL,"
			else
				cParams += "'"+STransType(nCodAll)+"',"
			endif
			cParams += "NULL,NULL,NULL,"

		case cOpcao == '4'  //Veículos sem entrada ou sem saída
			
			cParams += "'"+STrim(SDBDate(aFilter[1][4][3][1], '00:00:00'))+"',"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][6][1], '23:59:59'))+"',"
			cParams += "NULL,NULL,NULL,NULL,NULL,NULL,"

		case cOpcao == '5' //Veículos com entrada ou saída sem condutor

			cParams += "'"+STrim(SDBDate(aFilter[1][4][3][1], '00:00:00'))+"',"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][6][1], '23:59:59'))+"',"
			cParams += "NULL,NULL,NULL,NULL,NULL,NULL,"

		case cOpcao == '6' //Entrada e saída de veículos em lastre

			// cParams += "NULL,NULL,NULL,NULL,NULL,NULL,NULL,"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][3][1], '00:00:00'))+"',"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][6][1], '23:59:59'))+"',"
			cParams += "NULL,NULL,NULL,NULL,NULL,NULL,"

		case cOpcao == '7' //Por contêineres

			cParams += "'"+STrim(SDBDate(aFilter[1][4][3][1], '00:00:00'))+"',"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][6][1], '23:59:59'))+"',"
			cParams += "NULL,NULL,NULL,NULL,"
			
			if SEmpty(aFilter[1][4][21][1])
				cMsg := 'Campo Container obrigatório!'
				return .F.
			else
				cParams += "'"+STrim(STransType(aFilter[1][4][21][1]))+"',"
			endif
          cParams += "NULL,"
		case cOpcao == '8' //Contêineres com entrada ou saída sem veículo

			cParams += "'"+STrim(SDBDate(aFilter[1][4][3][1], '00:00:00'))+"',"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][6][1], '23:59:59'))+"',"
			cParams += "NULL,NULL,NULL,NULL,NULL,NULL,"

		case cOpcao == '9' //Entrada e saída de contêineres em lastre

			cParams += "'"+STrim(SDBDate(aFilter[1][4][3][1], '00:00:00'))+"',"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][6][1], '23:59:59'))+"',"
			cParams += "NULL,NULL,NULL,NULL,NULL,NULL,"

		case cOpcao == '10' //Divergência no peso bruto

			cParams += "'"+STrim(SDBDate(aFilter[1][4][3][1], '00:00:00'))+"',"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][6][1], '23:59:59'))+"',"
			cParams += "NULL,NULL,NULL,NULL,NULL,"+cTipoAg+","

	endcase

	cParams += STransType(aFilter[1][4][24][1])
	cParams += ",'"+SGetDBOwner() + cAliasTb+"'"
return .T.

*---------------------------*
Function C922VPLAC(xConteud, o)
*---------------------------*
   nCodAll := ''
	if !SEmpty(xConteud)
		if C922ZOOMM(o, 1)
			return .T.
		else
			Alert(STR0022)
			return .F.
		endif
	endif
return

*---------------------------*
Function C922VTRAN(xConteud, o)
*---------------------------*
	nCodAll := ''
	if !SEmpty(xConteud)
		if C922ZOOMM(o, 2)
			return .T.
		else
			Alert(STR0023)
			return .F.
		endif
	endif
return .T.

*---------------------------*
Function C922VCOND(xConteud, o)
*---------------------------*
	nCodAll := ''
	if !SEmpty(xConteud)
		if C922ZOOMM(o, 3)
			return .T.
		else
			return .F.
		endif
	endif
return .T.

*--------------------------*
Function C922VPAI(xConteud, o)
*--------------------------*
	nCodAll := ''
	if !SEmpty(xConteud)
		if C922ZOOMM(o, 4)
			return .T.
		else
			Alert(STR0025)
			return .F.
		endif
	endif
return .T.

*---------------------------*
Function C922VCNTA(xConteud, o)
*---------------------------*
   nCodAll := ''
	if !SEmpty(xConteud)
		if C922ZOOMM(o, 5)
			return .T.
		else
			Alert(STR0026)
			return .F.
		endif
	endif
return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} C922ZOOMM
Funcao que seleciona o ZOOM para o usuario

@param oObj Objeto que o resultado do zoom ira retornar
@param nTipoZoom Variavel que distingue o tipo de zoom uilizado

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
function C922ZOOMM(oObj, nTipoZoom)
	Local aZoom := {}
	Local aRetZoom := {}
	Local lRet := .T.

	do case
		case nTipoZoom == 1
		aZoom := SZoomVeiculo()

		case nTipoZoom == 2
		aZoom := SZoomTransp(.T., .T., .F., .T.)

		case nTipoZoom == 3
		aZoom := SZoomPesRod(.T., .T., .F., .F., .T., .F., .F., .F.)

		case nTipoZoom == 4
		aZoom := SZoomPais(.T.,.T.)

		case nTipoZoom == 5
		aZoom := SZoomContUni()

	endcase
	
	aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

	if !SEmpty(aRetZoom)
		if ((nTipoZoom == 2) .OR. (nTipoZoom == 3) .OR. (nTipoZoom == 4))
			oObj:cText := aRetZoom[2]
			nCodAll := STrim(STransType(aRetZoom[1]))
		else
			oObj:cText := aRetZoom[1]
		endif
	else
		oObj:cText := nil
	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C922CTB
Funcao que cria a estrutura da tabela

@return aStructDesc Variavel que retornara a descricao dos campos da tabela

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function C922CTMP()

	do case
		case cOpcao == '0' 
			aStructDesc := {   ;
				{STR0027 ,  12}, ;
				{STR0028 ,  12}, ;
				{STR0029 ,  12}, ;
				{STR0030 ,  6}, ;
				{STR0031 ,  6}, ;
				{"Entrada em lastre" ,  6}, ;
				{"Saída em lastre" ,  6}, ;
				{STR0033 , 12}, ;
				{STR0005 , 40}, ;
				{'Condutor' , 20}, ;
				{'CPF Condutor' , 12}, ;
				{'CNH Condutor' , 12}, ;
				{'Situação Transporte Entrada' , 13}, ;
				{'Situação Transporte Saída' , 13}, ;
				{STR0037 ,  18}, ;
				{'Tipo' , 5}, ;
				{STR0038 , 25}, ;
				{'Tipo' , 5}, ;
				{STR0039 , 25}, ;
				{STR0055 , 25}  ;
			}

			aStruct := {   ;
				{'CP1'  ,'C', 100 ,0}, ;
				{'CP2'  ,'C', 100 ,0}, ;
				{'CP3'  ,'C', 100 ,0}, ;
				{'CP4'  ,'C', 100 ,0}, ;
				{'CP5'  ,'C', 100 ,0}, ;
				{'CP6'  ,'C', 100 ,0}, ;
				{'CP7'  ,'C', 100 ,0}, ;
				{'CP8'  ,'C', 100 ,0}, ;
				{'CP9'  ,'C', 100 ,0}, ;
				{'CP10' ,'C', 100 ,0}, ;
				{'CP11' ,'C', 100 ,0}, ;
				{'CP12' ,'C', 100 ,0}, ;
				{'CP13' ,'C', 100 ,0}, ;
				{'CP14' ,'C', 100 ,0}, ;
				{'CP15' ,'C', 100 ,0}, ;
				{'CP16' ,'C', 100 ,0}, ;
				{'CP17' ,'C', 100 ,0}, ;
				{'CP18' ,'C', 100 ,0}, ;
				{'CP19' ,'C', 100 ,0}  ;
			}
			
		case cOpcao == '1' .OR. cOpcao == '2'
			aStructDesc := {   ;
				{STR0027 ,  12}, ;
				{STR0028 ,  12}, ;
				{STR0029 ,  12}, ;
				{STR0030 ,  6}, ;
				{STR0031 ,  6}, ;
				{"Entrada em lastre" ,  6}, ;
				{"Saída em lastre" ,  6}, ;
				{STR0033 , 12}, ;
				{STR0005 , 40}, ;
				{'Condutor' , 20}, ;
				{'CPF Condutor' , 12}, ;
				{'CNH Condutor' , 12}, ;
				{'Situação Transporte Entrada' , 13}, ;
				{'Situação Transporte Saída' , 13}, ;
				{STR0037 ,  18}, ;
				{'Tipo' , 5}, ;
				{STR0038 , 25}, ;
				{'Tipo' , 5}, ;
				{STR0039 , 25}, ;
				{STR0055 , 25}  ;
			}

			aStruct := {   ;
				{'CP1'  ,'C', 100 ,0}, ;
				{'CP2'  ,'C', 100 ,0}, ;
				{'CP3'  ,'C', 100 ,0}, ;
				{'CP4'  ,'C', 100 ,0}, ;
				{'CP5'  ,'C', 100 ,0}, ;
				{'CP6'  ,'C', 100 ,0}, ;
				{'CP7'  ,'C', 100 ,0}, ;
				{'CP8'  ,'C', 100 ,0}, ;
				{'CP9'  ,'C', 100 ,0}, ;
				{'CP10' ,'C', 100 ,0}, ;
				{'CP11' ,'C', 100 ,0}, ;
				{'CP12' ,'C', 100 ,0}, ;
				{'CP13' ,'C', 100 ,0}, ;
				{'CP14' ,'C', 100 ,0}, ;
				{'CP15' ,'C', 100 ,0}, ;
				{'CP16' ,'C', 100 ,0}, ;
				{'CP17' ,'C', 100 ,0}, ;
				{'CP18' ,'C', 100 ,0}, ;
				{'CP19' ,'C', 100 ,0}  ;
			}

		case cOpcao == '3'
			aStructDesc := {   ;
				{STR0027 , 12}, ;
				{STR0028 , 12}, ;
				{STR0033 , 12}, ;
				{STR0005 , 40}, ;
				{STR0030 ,  6}, ;
				{STR0031 ,  6}, ;
				{STR0038 , 25}, ;
				{STR0040 , 20}, ;
				{STR0041 , 10}, ;
				{STR0055 , 10}  ;
			}

			aStruct := {   ;
				{'CP1'   ,'C', 100 ,0}, ;
				{'CP2'   ,'C', 100 ,0}, ;
				{'CP3'   ,'C', 100 ,0}, ;
				{'CP4'   ,'C', 100 ,0}, ;
				{'CP5'   ,'C', 100 ,0}, ;
				{'CP6'   ,'C', 100 ,0}, ;
				{'CP7'   ,'C', 100 ,0}, ;
				{'CP8'   ,'C', 100 ,0}, ;
				{'CP9'   ,'C', 100 ,0}, ;
				{'CP10'  ,'C', 100 ,0} ;
			}

		case cOpcao == '4'
			aStructDesc := {   ;
				{STR0027 ,  12}, ;
				{STR0028 ,  12}, ;
				{STR0030 ,  6}, ;
				{STR0031 ,  9}, ;
				{STR0055 ,  9}  ;
			}

			aStruct := {   ;
				{'CP1'  ,'C', 100 ,0}, ;
				{'CP2'  ,'C', 100 ,0}, ;
				{'CP3'  ,'C', 100 ,0}, ;
				{'CP4'  ,'C', 100 ,0}, ;
				{'CP5'  ,'C', 100 ,0}  ;
			}

		case cOpcao == '5' .OR. cOpcao == '6'
			aStructDesc := {   ;
				{STR0027 , 12}, ;
				{STR0028 , 12}, ;
				{STR0030 ,  9}, ;
				{STR0042 , 14}, ;
				{STR0043 , 14}, ;
				{STR0044 , 10}, ;
				{STR0045 ,  5}, ;
				{STR0031 , 15}, ;
				{STR0055 , 15}  ;
			}

			aStruct := {   ;
				{'CP1'  ,'C', 100 ,0}, ;
				{'CP2'  ,'C', 100 ,0}, ;
				{'CP3'  ,'C', 100 ,0}, ;
				{'CP4'  ,'C', 100 ,0}, ;
				{'CP5'  ,'C', 100 ,0}, ;
				{'CP6'  ,'C', 100 ,0}, ;
				{'CP7'  ,'C', 100 ,0}, ;
				{'CP8'  ,'C', 100 ,0}, ;
				{'CP9'  ,'C', 100 ,0}  ;
			}

		case cOpcao == '7'
			aStructDesc := {   ;
				{STR0027 , 12}, ;
				{STR0028 , 12}, ;
				{STR0008 ,  6}, ;
				{"Entrada em lastre" ,  6}, ;
				{"Saída em lastre" ,  6}, ;
				{"Situação Transporte Entrada" ,  13}, ;
				{"Situação Transporte Saída" ,  13}, ;
				{STR0033 , 12}, ;
				{STR0005 , 40}, ;
				{STR0048 , 10}, ;
				{STR0049 , 10}, ;
				{STR0050 , 10}, ;
				{STR0051 , 10}, ;
				{'Tipo'  , 5}, ;
				{STR0038 , 28}, ;
				{'Tipo'  , 5}, ;				
				{STR0039 , 25} ;				
			}

			aStruct := {   ;
				{'CP1'  ,'C', 100 ,0}, ;
				{'CP2'  ,'C', 100 ,0}, ;
				{'CP3'  ,'C', 100 ,0}, ;
				{'CP4'  ,'C', 100 ,0}, ;
				{'CP5'  ,'C', 100 ,0}, ;
				{'CP6'  ,'C', 100 ,0}, ;
				{'CP7'  ,'C', 100 ,0}, ;
				{'CP8'  ,'C', 100 ,0}, ;
				{'CP9'  ,'C', 100 ,0}, ;
				{'CP10' ,'C', 100 ,0}, ;
				{'CP11' ,'C', 100 ,0}, ;
				{'CP12' ,'C', 100 ,0}, ;
				{'CP13' ,'C', 100 ,0}, ;
				{'CP14' ,'C', 100 ,0}, ;
				{'CP15' ,'C', 100 ,0}, ;
				{'CP16' ,'C', 100 ,0}, ;
				{'CP17' ,'C', 100 ,0}  ;
			}

		case cOpcao == '8'
			aStructDesc := { ;
				{STR0008 , 11}, ;
				{STR0027 , 12}, ;
				{STR0028 , 12}, ;
				{STR0048 , 20}, ; 
				{STR0049 , 26}, ;
				{STR0050 , 11}, ;
				{STR0051 , 24}, ;
				{STR0055 , 24}  ;
			}

			aStruct := { ;
				{'CP1'  ,'C', 100 ,0}, ;
				{'CP2'  ,'C', 100 ,0}, ;
				{'CP3'  ,'C', 100 ,0}, ;
				{'CP4'  ,'C', 100 ,0}, ;
				{'CP5'  ,'C', 100 ,0}, ;
				{'CP6'  ,'C', 100 ,0}, ;
				{'CP7'  ,'C', 100 ,0}, ;
				{'CP8'  ,'C', 100 ,0}  ;
			}

		case cOpcao == '9'
			aStructDesc := { ;
				{STR0027 , 12}, ;
				{STR0028 , 12}, ;
				{STR0008 ,  11}, ;
				{STR0052 ,  6}, ;
				{STR0029 ,  6}, ;
				{STR0053 ,  6}, ;
				{STR0055 ,  6}  ;
			}

			aStruct := {	;
				{'CP1'  ,'C', 100 ,0}, ;
				{'CP2'  ,'C', 100 ,0}, ;
				{'CP3'  ,'C', 100 ,0}, ;
				{'CP4'  ,'C', 100 ,0}, ;
				{'CP7'  ,'C', 100 ,0},  ;
				{'CP6'  ,'C', 100 ,0}, ;
				{'CP5'  ,'C', 100 ,0} ;
			}

		case cOpcao == '10'
			aStructDesc := {	;
				{STR0056 , 15}, ;		//Doc. Saida		
				{STR0054 , 35}, ;       //Veiculo/Conteiner
				{If(cTipoAg $ "1","Cert.Entr.e Saida de Veic.","Doc. Saída" ),15}, ;
				{STR0057 , 15}, ;       //Peso Bruto Documental
				{STR0058 , 10}, ;       //Divergencia
				{STR0059 , 10}, ;       //Diferenca
				{STR0060 , 10}, ;       //Peso de Saida
				{"Saida Fracionada Doc. Saida",10};
			}

			aStruct := {	;
				{'CP1'  ,'C', 100 ,0}, ; //Doc. Saida		
				{'CP2'  ,'C', 100 ,0}, ; //Veiculo/Conteiner
				{'CP3'  ,'C', 100 ,0}, ; //Cert.Entr.e Saida de Veic.","Doc. Saída
				{'CP4'  ,'C', 100 ,0}, ; //Peso Bruto Documental
				{'CP7'  ,'C', 100 ,0}, ; //Divergencia
				{'CP6'  ,'C', 100 ,0}, ; //Diferenca
				{'CP5'  ,'C', 100 ,0}, ; //Peso de Saida
				{'CP8'  ,'C', 100 ,0}  ; //Saida Fracionada Doc. Saida
			}
	endcase

	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
return aStructDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} C922DBLCLI
Funcao que sera executada no momento do double click.

@param

@author  Luan Eli Oliveira
@since   02/04/2013
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function C922DBLCLI()

	Local cCesv := ''

	do case
		case cOpcao == '0' .OR. cOpcao == '1' .OR. cOpcao == '2' .OR. cOpcao == '7'
			nCol := 16
		case cOpcao == '3'
			nCol := 10
		case cOpcao == '4'
			nCol := 5
		case cOpcao == '5' .OR. cOpcao == '6'
			nCol := 9
		case cOpcao == '9'
			nCol := 8
		case cOpcao == '9'
			nCol := 7
		case cOpcao == '10'
			nCol := 2
	endcase

	cCesv := (cAliasTb)->(Fieldget(nCol))
	
	PRAC939(cCesv)
Return


/*Funções criadas para alterar a cor da linha do grid e do fonte da linha, quando é uma linha de agrupamento*/
//-------------------------------------------------------------------
/*/{Protheus.doc} C922COLOR
Funcao que sera executada para trocar a cor do fonte do grid

@author  A
@since   dd/mm/yyyy
@version P12
@protected
/*/
//-------------------------------------------------------------------

Static Function C922COLOR()
  if (Substr(AllTrim((cAliasTb)->CP2),1,10) == "Doc. Saída") .OR. (Substr(AllTrim((cAliasTb)->CP2),1,5) == "Total")  
     Return CLR_HBLUE
  endif
  
 if (Substr(AllTrim((cAliasTb)->CP2),1,10) <> "Doc. Saída") .AND.; 
     (Substr(AllTrim((cAliasTb)->CP2),1,5) <> "Total") .AND.;
     (AllTrim((cAliasTb)->CP2) <> '')  
     Return CLR_BLACK  
  endif  
  
  if (AllTrim((cAliasTb)->CP2) = '')  
     Return CLR_WHITE       
  endif
return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} C922COLORB
Funcao que sera executada para trocar a cor de fundo do grid

@author  A
@since   dd/mm/yyyy
@version P12
@protected
/*/
//-------------------------------------------------------------------

Static Function C922COLORB()
  if (Substr(AllTrim((cAliasTb)->CP2),1,10) == "Doc. Saída") .OR. (Substr(AllTrim((cAliasTb)->CP2),1,5) == "Total")  
     Return CLR_HGRAY       
  endif    
  
  if (Substr(AllTrim((cAliasTb)->CP2),1,10) <> "Doc. Saída") .AND.; 
     (Substr(AllTrim((cAliasTb)->CP2),1,5) <> "Total") .AND.;
     (AllTrim((cAliasTb)->CP2) <> '')   
     Return RGB(232, 232, 232)  
  endif
  
  if (AllTrim((cAliasTb)->CP2) = '')
     Return CLR_WHITE       
  endif    
  
return Nil

/* Pesquisa de pessoas no modal Rodoviário */
Function SZoomPesRod (lRetNome, lRetCodigo, lRetTpDoc, lRetDoc, lPesqNome, lPesqCod, lPesqTpDoc, lPesqDoc)

      Local aRet := {}
      Local aFields := {}
      default lRetNome := .F.
      default lRetCodigo := .F.
      default lRetTpDoc := .F.
      default lRetDoc := .F.
      default lPesqNome := .F.
      default lPesqCod := .F.
      default lPesqTpDoc := .F.
      default lPesqDoc := .F.

      Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array

      Aadd(aRet, "select tab_pessoas.pes_id, tab_pessoas.pes_nome,(case when tab_pessoas.pes_cpf is not null "+;
                        "then 'CPF' else (case tab_pessoas.pes_tipo_doc when 0 then 'RG' when 1 then 'CNH' when 2 then 'CTPS' "+;
                        "when 3 then 'PASSAPORTE' when 4 then 'OUTROS' end) end) as tipo_doc, (case when tab_pessoas.pes_cpf is not null "+;
                        "then 'RFB' else tab_pessoas.pes_orgao_emissor end "+;
                        ")as pes_orgao_emissor, (case when tab_pessoas.pes_cpf is not null then substring(tab_pessoas.pes_cpf,1,3) ++'.'++ "+;
                        "substring(tab_pessoas.pes_cpf,4,3) ++'.'++substring(tab_pessoas.pes_cpf,7,3) ++ '-' ++substring(tab_pessoas.pes_cpf,10,2) "+;
                        "else (case tab_pessoas.pes_tipo_doc when 1 then tab_pessoas.pes_cnh else tab_pessoas.pes_rg end) "+;
                        "end) as documento from tab_pessoas where exists ( select distinct 1 from tab_acesso where tab_pessoas.pes_id = tab_acesso.pes_id "+; 
                                                                          " and tab_acesso.ace_entrada > ( getdate() - 740) "+; 
                                                                          " and (substring(tab_acesso.cesv_id, 5, 1) = 'V'))")
	   Aadd(aRet, "order by tab_pessoas.pes_id")

              //aFields,  cCampo             , cDesc                        , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
      SAddPField(@aFields , "pes_id"           , "Código"/*"Código"*/           , "N"  , 7       , 0        , ""      , .F.     , lRetCodigo, lPesqCod, 1) //Monta a estrutura de campos
      SAddPField(@aFields , "pes_nome"         , "Nome"/*"Nome"*/             , "C"  , 30      , 0        , ""      , .T.     , lRetNome, lPesqNome, 1)
      SAddPField(@aFields , "tipo_doc"         , "Tipo de documento"/*"Tipo de documento"*/, "C"  , 15      , 0        , ""      , .T.     , lRetTpDoc, lPesqTpDoc, 1)
      SAddPField(@aFields , "pes_orgao_emissor", "Orgão emissor"/*"Orgão emissor"*/    , "C"  , 15      , 0        , ""      , .T.     , .F.)
      SAddPField(@aFields , "documento"        , "Documento"/*"Documento"*/        , "C"  , 15      , 0        , ""      , .T.     , lRetDoc, lPesqDoc, 1)

      Aadd(aRet, aFields)

Return aRet