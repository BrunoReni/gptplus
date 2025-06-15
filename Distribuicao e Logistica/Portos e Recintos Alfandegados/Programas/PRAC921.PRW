#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC921.CH"

/*/{Protheus.doc} PRAC921
@author   Felipe Machado de Oliveira
@version  P12
@since    12/06/2012
@obs      2.2.5 - Histórico de Movimentação de pessoas
/*/
Function PRAC921()

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
	Public cpes_id     := ""
	

	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

		oLayer := FWLayer():new()
		oLayer:init(oDlg,.F.)
		oLayer:addColumn('Col01',100,.F.)
		oLayer:addWindow('Col01','C1_Win01',STR0001,100,.T.,.F.,,,)

		oPanel  := oLayer:getWinPanel('Col01','C1_Win01')
 						//Campo, Descricao, Tipo, Tamanho, Alias, Mascara      , Nil, Zoom              , Validacao                              , ValorPadrao
		Aadd(aFields, {"P1"  , STR0002 , "D" , 10        , nil  , nil        , nil, nil               , nil                                    , (Date() - 30)})
		Aadd(aFields, {"P2"  , STR0003 , "C" , 8         , nil  , "##:##:##" , nil, nil               , nil                                    , "00:00:00"})
		Aadd(aFields, {"P3"  , STR0004 , "D" , 10        , nil  , nil        , nil, nil               , nil                                    , Date()})
		Aadd(aFields, {"P4"  , STR0005 , "C" , 8         , nil  , "##:##:##" , nil, nil               , nil                                    , "23:59:59"})
		Aadd(aFields, {"P5"  , STR0006 , "C" , 50        , nil  , nil        , nil, "C921ZOOM1(o, 1)"  , {|xConteud, o| C921VLPESS(xConteud, o)} , nil})
		Aadd(aFields, {"P6"  , STR0007 , "C" , 3         , nil  , nil        , nil, "C921ZOOM1(o, 2)"  , {|xConteud| C921VTPDO(xConteud)}      , nil})
		Aadd(aFields, {"P7"  , STR0008 , "C" , 30        , nil  , nil        , nil, nil               , nil                                    , nil})
    	Aadd(aFields, {"P8"  , STR0011 , "C" , 1         , nil  , nil        , nil, nil               , nil                                    , nil})
    	Aadd(aFields, {"P9"  , 'CPF'   , "C" , 30        , nil  , '@R 999.999.999-99', nil, nil          , nil                                    , nil})

		aStructDesc := C921CTB(@aStruct)

		oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)
		SAddFilPar("P4","==","%P4%",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","a",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		oBrowse:AddFilter(STR0012, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3=='%P3%' .AND. P4=='%P4%' .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8=='a' .AND. P9==NULL", .F., .F.,nil,.T., aFilParser, '0')

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)
		SAddFilPar("P4","==","%P4%",@aFilParser)
		SAddFilPar("P5","==","%P5%",@aFilParser)
		SAddFilPar("P6","==","%P6%",@aFilParser)
		SAddFilPar("P7","==","%P7%",@aFilParser)
		SAddFilPar("P8","==","b",@aFilParser)
		SAddFilPar("P9","==","%P9%",@aFilParser)
		oBrowse:AddFilter(STR0013, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3=='%P3%' .AND. P4=='%P4%' .AND. P5=='%P5%' .AND. P6=='%P6%' .AND. P7=='%P7%' .AND. P8=='b' .AND. P9=='%P9%'", .F., .F.,nil,.T., aFilParser, '1')

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)
		SAddFilPar("P4","==","%P4%",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","c",@aFilParser)
       SAddFilPar("P9","==","NULL",@aFilParser)
		oBrowse:AddFilter(STR0014, "P1==%P1% .AND. P2==%P2% .AND. P3==%P3% .AND. P4==%P4% .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8=='c' .AND. P9==NULL", .F., .F.,nil,.T., aFilParser, '2')

		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros

		oBrowse:oFWFilter:SetExecute({||C921FILTER(oBrowse)})

		oBrowse:oFWFilter:FilterBar(nil,.F.,.F.)

	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTb(cAliasTb)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} C921FILTER
Funcao que sera executada no momento em que o filtro for acionado, para tratar as informações

@param oBrowse Variavel que contem a GRID do programa

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function C921FILTER(oBrowse)

	Local cQuery      := "exec proc_rfb_histmovpes_2_5_w"
	Local cParams     := ""
	Local oColumn
	Local nI          := 0
	Local oFilter     := oBrowse:FWFilter()
	Local aFilter     := nil
	Local cMsg := ""
	Local cCampo := ''

	if !SVALFILTRO(oFilter)
		Alert(STR0015)
		return
	endif

	aFilter := oFilter:GetFilter(.T.)

	if (!C921GF(aFilter, @cParams, @cMsg))
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
		
		if (aStructDesc[nI][1]<>'Motivação do acesso') 
		    oBrowse:SetColumns({oColumn})
		else
		  if C921MOTIVO() 
		     oBrowse:SetColumns({oColumn})		  
		  endif 		   
		endif
	next

	oBrowse:UpdateBrowse()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} C921GF
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
static function C921GF(aFilter, cParams, cMsg)

	Local cOpcao    := 'b'
	Local cDataIni
	Local cDataFim
        Local  aZoom := {}
	Local  aRetZoom := {}
	Local  lRet := .T.	


	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif

	cOpcao := STransType(aFilter[1][4][24][1])

	do case
		case cOpcao == "a"

			if (aFilter[1][4][6][1]) == "  :  :  " .OR. (aFilter[1][4][12][1]) == "  :  :  "
				cMsg := STR0027
				return .F.
			endif

			cParams += "'"+(SDBDate(aFilter[1][4][3][1], STrim(STransType(aFilter[1][4][06][1])))) +"',"
			cParams += "'"+(SDBDate(aFilter[1][4][9][1], STrim(STransType(aFilter[1][4][12][1])))) +"',"
			cParams += "NULL,NULL,NULL,NULL,NULL,"

		case cOpcao == "b"

			if (aFilter[1][4][6][1]) == "  :  :  " .OR. (aFilter[1][4][12][1]) == "  :  :  "
				cMsg := STR0027
				return .F.
			endif

			if SEmpty(aFilter[1][4][15][1]) .AND. SEmpty(aFilter[1][4][21][1]) .AND. SEmpty(aFilter[1][4][27][1])
				cMsg := 'Nome, documento ou CPF deve ser preenchido!'
				return .F.
		        else
		          if STransType(cpes_id) == ""
 	                    aZoom := SZoomPess(.T., .T., .F., .F., .T., .F., .F., .F.)
	                    aRetZoom := PRAC938(aZoom, aFilter[1][4][15][1], @lRet)

	                    if !SEmpty(aRetZoom)
	                      cpes_id    := aRetZoom[1]			
                            else
	                      cpes_id := ""
	                    endif
			    		       
		          end if 
			endif

			cParams += "'"+(SDBDate(aFilter[1][4][3][1], STrim(STransType(aFilter[1][4][06][1])))) +"',"
			cParams += "'"+(SDBDate(aFilter[1][4][9][1], STrim(STransType(aFilter[1][4][12][1])))) + "',"
			if SEmpty(aFilter[1][4][15][1])
				cParams += "NULL,"
			else
				cParams += "'"+STrim(STransType(aFilter[1][4][15][1]))+"',"
			endif

			if SEmpty(aFilter[1][4][18][1])
				cParams += "NULL,"
			else
				cParams += STransType(aFilter[1][4][18][1])+","
			endif

			do case
				case (aFilter[1][4][18][1]) == '1'
					//cParams += "NULL,NULL,"
					cParams += "NULL,"
					
					if SEmpty(aFilter[1][4][27][1])
						cParams += "NULL,"
					else
						cParams += "'"+STrim(STransType(aFilter[1][4][27][1]))+"',"
					endif
					
					if SEmpty(aFilter[1][4][21][1])
						cParams += "NULL,"
					else
						cParams += "'"+STrim(STransType(aFilter[1][4][21][1]))+"',"
					endif
				otherwise
					if SEmpty(aFilter[1][4][21][1])
						cParams += "NULL,"
					else
						cParams += "'"+STrim(STransType(aFilter[1][4][21][1]))+"',"
					endif
					
					if SEmpty(aFilter[1][4][27][1])
						cParams += "NULL,"
					else
						cParams += "'"+STrim(STransType(aFilter[1][4][27][1]))+"',"
					endif
					//cParams += "NULL,NULL,"
					cParams += "NULL,"

			endcase

		case cOpcao == "c"

			if (aFilter[1][4][6][1]) == "  :  :  " .OR. (aFilter[1][4][12][1]) == "  :  :  "
				cMsg := STR0027
				return .F.
			endif

			cParams += "'"+(SDBDate(aFilter[1][4][3][1], STrim(STransType(aFilter[1][4][06][1])))) +"',"
			cParams += "'"+(SDBDate(aFilter[1][4][9][1], STrim(STransType(aFilter[1][4][12][1])))) +"',"
			cParams += "NULL,NULL,NULL,NULL,NULL,"

	endcase
	
	if !SEmpty(cpes_id)
	  cParams += STrim(STransType(cpes_id)) +","
	else
	  cParams += "NULL,"
        endif 

	cParams += "'"+STransType(aFilter[1][4][24][1])+"'"
	cParams += ",'"+SGetDBOwner()+cAliasTb+"'"

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} C921ZOOM1
Funcao que seleciona o ZOOM para o usuario

@param oObj Objeto que o resultado do zoom ira retornar
@param nTipoZoom Variavel que distingue o tipo de zoom uilizado

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function C921ZOOM1(oObj, nTipoZoom)
	Local aZoom := {}
	Local aRetZoom := {}
	Local lRet := .T.

	if nTipoZoom == 1
		aZoom := SZoomPess(.T., .T., .F., .F., .T., .F., .F., .F.)
		aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

		if !SEmpty(aRetZoom)
		  cpes_id    := aRetZoom[1]
		  oObj:cText := aRetZoom[2]
		else
			oObj:cText := nil
		endif

	elseif nTipoZoom == 2
		aZoom := SZoomTpDoc(.T., .T., .T., .T., .T., .F.)
		aRetZoom := PRAC938(aZoom)
		if !SEmpty(aRetZoom)
			oObj:cText := aRetZoom[1]
		else
			oObj:cText := nil
		endif
	endif

return lRet

*--------------------------*
function C921VLPESS(xConteud, o)
*--------------------------*
	if !SEmpty(xConteud)
		if C921ZOOM1(o, 1)
			return .T.
		else
			Alert(STR0016)
			return .F.
		endif
	endif
return

*-------------------------*
function C921VTPDO(oTpDoc)
*-------------------------*
	if (SValTpDoc(oTpDoc))
		return .T.
	else
		Alert(STR0017)
		return .F.
	end
return

//-------------------------------------------------------------------
/*/{Protheus.doc} C921CTB
Funcao que cria a estrutura da tabela

@param aStruct Variave que retornara a estrutura dos campos da tabela
@return aStructDesc Variavel que retornara a descricao dos campos da tabela

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function C921CTB(aStruct)

	aStructDesc := {     ;
	    {STR0018 , 5}, ;
	    {STR0019 , 50}, ;
	    {STR0009 , 10}, ;
	    {STR0010 , 10}, ;
	    {STR0020 , 10}, ;
	    {STR0021 , 5}, ;
	    {STR0022 , 10}, ;
	    {STR0023 , 7}, ;
	    {STR0024 , 2} , ;
	    {STR0029 , 15},;
	    {STR0025 , 10}, ;
	    {STR0026 , 10},  ;
	    {STR0030 , 255};
	}

	aStruct := {    ;
	    {'CP1' ,'C',100 ,0}, ;
	    {'CP2' ,'C',100 ,0}, ;
	    {'CP3' ,'C',100 ,0}, ;
	    {'CP4' ,'C',100 ,0}, ;
	    {'CP5' ,'C',100 ,0}, ;
	    {'CP6' ,'C',100 ,0}, ;
	    {'CP7' ,'C',100 ,0}, ;
	    {'CP8' ,'C',100 ,0}, ;
	    {'CP9' ,'C',100 ,0}, ;
	    {'CP10','C',100 ,0}, ;
	    {'CP11','C',100 ,0}, ;
	    {'CP12','C',100 ,0}, ;
	    {'CP13','C',255 ,0}  ;
	}

	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
return aStructDesc

function C921MOTIVO()
	Local lRet := .T.
	Local cQuery := ''
	Local cAlias := GetNextAlias()
	
	cQuery := " select param_valor from tab_parametro where param_desc = 'Utiliza_Motivo_Acesso' "
	           
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)
	
	if (cAlias)->(param_valor) = 'S'
		lRet := .T.
	else
		lRet := .F.
	endif
	
return lRet