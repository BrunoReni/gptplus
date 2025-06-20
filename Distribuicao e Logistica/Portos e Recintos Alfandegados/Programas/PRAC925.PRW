#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC925.CH"
 
/*/{Protheus.doc} PRAC925
@author   Felipe Machado de Oliveira
@version  P12
@since    21/06/2012
@obs      2.2.9 - Prazo de perman�ncia
/*/

Function PRAC925()

	Local oDlg          := nil
	Local aFields       := {}
	Local oPanel        := nil
	Local oLayer        := nil
	Local aFilParser    := {}
	Local aCoors        := FWGetDialogSize(oMainWnd)
	Local oBrowse       := nil
	Private cAliasTb    := ""
	Private nColSize    := 0
	Private aStructDesc
	Private aStruct

	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

		oLayer := FWLayer():new()
		oLayer:init(oDlg,.F.)
		oLayer:addColumn('Col01',100,.F.)
		oLayer:addWindow('Col01','C1_Win01',STR0001,100,.T.,.F.,,,)

		oPanel  := oLayer:getWinPanel('Col01','C1_Win01')
                    //Campo , Descricao                 , Tipo , Tam , Ali  , Mascara , Nil , Zoom , Vali, ValorPadrao
		Aadd(aFields, {"P1"  , STR0002 , "N"  ,  4  , nil  , "####"  , nil , nil  , nil , nil})
		Aadd(aFields, {"P2"  , STR0003 , "D"  , 20  , nil  , nil     , nil , nil  , nil , Date()})
		Aadd(aFields, {"P3"  , STR0004 , "D"  , 20  , nil  , nil     , nil , nil  , nil , nil})
		Aadd(aFields, {"P4"  , STR0005 , "C"  ,  1  , nil  , nil     , nil , nil  , nil , nil})

		cAliasTb := SCTBTMPG()

		oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","0",@aFilParser)
		oBrowse:AddFilter(STR0006, "P1=='%P1%' .AND. P2==NULL .AND. P3==NULL .AND. P4=='0'", .F., .F.,nil,.T., aFilParser, '0')

		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","1",@aFilParser)
		oBrowse:AddFilter(STR0007, "P1==NULL .AND. P2=='%P2%' .AND. P3==NULL .AND. P4=='1'", .F., .F.,nil,.T., aFilParser, '1')

		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","2",@aFilParser)
		oBrowse:AddFilter(STR0008, "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4=='2'", .F., .F.,nil,.T., aFilParser, '2')

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)
		SAddFilPar("P4","==","3",@aFilParser)
		oBrowse:AddFilter(STR0009, "P1=='%P1%' .AND. P2==NULL .AND. P3==NULL .AND. P4=='3'", .F., .F.,nil,.T., aFilParser, '3')

		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros

		oBrowse:oFWFilter:SetExecute({||C925FILTER(oBrowse)})

		oBrowse:oFWFilter:FilterBar(nil,.F.,.F.)

	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTb(cAliasTb)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} C925FILTER
Funcao que sera executada no momento em que o filtro for acionado, para tratar as informa��es

@param oBrowse Variavel que contem a GRID do programa

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function C925FILTER(oBrowse)

	Local cQuery      := ""
	Local cParams     := ""
	Local oColumn
	Local nI          := 0
	Local oFilter     := oBrowse:FWFilter()
	Local aFilter     := nil
	Local cMsg := ""
	Local cCampo := ""
	Local cOpcao := ""

	aFilter := oFilter:GetFilter(.T.)

	if !SVALFILTRO(oFilter)
		alert(STR0010)
		return
	endif

	if (!C925GF(aFilter, @cParams, @cMsg, @cOpcao))
		if (!SEmpty(cMsg))
			alert(cMsg)
		endif
		return
	endif

	if cOpcao != '3'
		cQuery := 'exec proc_rfb_pesq_prazo_perman_w'
	else
		cQuery := 'exec proc_rfb_prazo_perm_inter_data_w'
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

	oBrowse:UpdateBrowse()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} C925GF
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
static function C925GF(aFilter, cParams, cMsg, cOpcao)

	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif

	cOpcao := STransType(aFilter[1][4][12][1])

	if cOpcao != '3'
		cParams += STransType(aFilter[1][4][12][1])
	endif

	C925CTMP(cOpcao)

	do case
		case cOpcao == '0' //a) N�meros de lotes de carga que estejam armazenados
								//h� mais de certo n�mero de dias

			cParams += ",NULL,NULL,"
			cParams += STrim(STransType(aFilter[1][4][3][1]))

		case cOpcao == '1' //b) N�meros de lotes de carga cujo prazo de dep�sito,
  								 //ou no regime aduaneiro, vencer�o a partir de certa data
			if SDBDate(aFilter[1][4][6][1]) == "0-0-0"
				cMsg := STR0029
				return .F.
			endif

			cParams += ",'"+STrim(SDBDate(aFilter[1][4][6][1], '23:59:59'))+"',"
			cParams += "NULL,"
			cParams += "NULL"

		case cOpcao == '2' //c) N�meros de lotes de carga cujo prazo de dep�sito,
								 //ou no regime aduaneiro vencidos at� a data atual

			cParams += ",'"+STrim(SDBDate(date(), '23:59:59'))+"',"
			cParams += "NULL,"
			cParams += "NULL"

		case cOpcao == '3' //d) N�meros de lotes de carga, em que a sa�da total do
		  						 //recinto tenha ocorrido em prazo inferior a certo n�mero de dias
			if SDBDate(aFilter[1][4][6][1]) == "0-0-0" .OR. SDBDate(aFilter[1][4][9][1]) == "0-0-0"
				cMsg := STR0029
				return .F.
			endif

			cParams += "'"+STrim(SDBDate(aFilter[1][4][6][1], '00:00:00'))+"',"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][9][1], '23:59:59'))+"',"
			cParams += STrim(STransType(aFilter[1][4][3][1]))

	endcase

	cParams += ",'"+SGetDBOwner() + cAliasTb+"'"

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} C925CTMP
Funcao que cria a estrutura da tabela

@param cOpcao Variavel que contem a opcao selecionada pelo usuario
@return aStructDesc Variavel que retornara a descricao dos campos da tabela

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
static function C925CTMP(cOpcao)

	do case
		case cOpcao == '0'
			aStructDesc := { ;
				{STR0011 , 10}, ;
				{STR0012 , 12}, ;
				{"Lote de origem" , 10}  ;
			}
			aStruct := {				 ;
				{'CP1'  ,'C', 100 ,0}, ;
				{'CP2'  ,'C', 100 ,0}, ;
				{'CP3'  ,'C', 100 ,0}  ;
			}

		case cOpcao == '1' .OR. cOpcao == '2'
			aStructDesc := {	;
				{STR0011 , 10}, ;
				{STR0014 , 12}, ;
				{STR0015 , 18}, ;
				{STR0016 , 20}, ;
				{STR0017 , 13}, ;
				{STR0018 ,  8}  ;
			}
			aStruct := {	;
				{'CP1'  ,'C', 100 ,0}, ;
				{'CP2'  ,'C', 100 ,0}, ;
				{'CP3'  ,'C', 100 ,0}, ;
				{'CP4'  ,'C', 100 ,0}, ;
				{'CP5'  ,'C', 100 ,0}, ;
				{'CP6'  ,'C', 100 ,0} ;
			}
		case cOpcao == '3'
			aStructDesc := {	;
				{STR0011 , 10}, ;
				{STR0019 , 14}, ;
				{'Modal' , 14}, ;
				{STR0014 , 12}, ;
				{STR0020 , 18}, ;
				{STR0021 , 13}, ;
				{STR0022 , 22}, ;
				{STR0023 , 12}, ;
				{STR0024 , 12}, ;
				{STR0025 , 20}, ;
				{STR0026 , 15}, ;
				{STR0027 , 40}, ;
				{STR0028 , 24}  ;
			}
			aStruct := {	;
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
				{'CP13' ,'C', 100 ,0}  ;				
			}
	endcase

	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
return aStructDesc
                