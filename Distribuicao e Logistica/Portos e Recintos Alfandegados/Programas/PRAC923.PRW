#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"   
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC923.CH"

/*/{Protheus.doc} PRAC923
@author   Felipe Machado de Oliveira
@version  P12
@since    18/06/2012
@obs      2.2.7 - Histórico de Movimentação de Lotes
/*/
Function PRAC923()

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
	Private nCodAll  := ''
	Private nCodReg  := ''

	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

		oLayer := FWLayer():new()
		oLayer:init(oDlg,.F.)
		oLayer:addColumn('Col01',100,.F.)
		oLayer:addWindow('Col01','C1_Win01',STR0001,100,.T.,.F.,,,)

		oPanel  := oLayer:getWinPanel('Col01','C1_Win01')
                    //Campo , Descric , Tipo , Tam , Ali  , Mascara , Nil , Zoom                 , Vali                                    , ValorPadrao
		Aadd(aFields, {"P1"  , STR0002 , "D"  , 20  , nil  , nil     , nil , nil                  , nil                                     , (Date() - 30)})
		Aadd(aFields, {"P2"  , STR0003 , "D"  , 20  , nil  , nil     , nil , nil                  , nil                                     ,  Date()})
		Aadd(aFields, {"P3"  , STR0004 , "C"  , 20  , nil  , nil     , nil , "C923ZOOMP(o, 1)"     , {|xConteud, o| C923VCONS(xConteud, o)} ,  nil})
		Aadd(aFields, {"P4"  , STR0005 , "C"  , 50  , nil  , nil     , nil , "C923ZOOMP(o, 2)"     , {|xConteud, o| C923VREGI(xConteud, o)} ,  STR0009})
		Aadd(aFields, {"P5"  , STR0006 , "C"  , 20  , nil  , nil     , nil , "C923ZOOMP(o, 1)"     , {|xConteud, o| C923VCONS(xConteud, o)} ,  nil})
		Aadd(aFields, {"P6"  , STR0007 , "C"  , 20  , nil  , nil     , nil , "C923ZOOMP(o, 1)"     , {|xConteud, o| C923VCONS(xConteud, o)} ,  nil})
		Aadd(aFields, {"P7"  , STR0008 , "C"  ,  1  , nil  , nil     , nil , nil                  , nil                                     ,  nil})

		cAliasTb := SCTBTMPG()

		oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","0",@aFilParser)
		oBrowse:AddFilter(STR0010, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7=='0'", .F., .F.,nil,.T., aFilParser, '0')

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","1",@aFilParser)
		oBrowse:AddFilter(STR0011, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3=='%P3%' .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7=='1'", .F., .F.,nil,.T., aFilParser, '1')

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","2",@aFilParser)
		oBrowse:AddFilter(STR0012, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3=='%P3%' .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7=='2'", .F., .F.,nil,.T., aFilParser, '2')

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","%P6%",@aFilParser)
		SAddFilPar("P7","==","3",@aFilParser)
		oBrowse:AddFilter(STR0013, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6=='%P6%' .AND. P7=='3'", .F., .F.,nil,.T., aFilParser, '3')

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","%P4%",@aFilParser)
		SAddFilPar("P5","==","%P5%",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","4",@aFilParser)
		oBrowse:AddFilter(STR0014, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3==NULL .AND. P4=='%P4%' .AND. P5=='%P5%' .AND. P6==NULL .AND. P7=='4'", .F., .F.,nil,.T., aFilParser, '4')

		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros
		oBrowse:oFWFilter:SetExecute({||C923FILTER(oBrowse)})
		oBrowse:oFWFilter:FilterBar(nil,.F.,.F.)

	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTb(cAliasTb)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} C923FILTER
Funcao que sera executada no momento em que o filtro for acionado, para tratar as informações

@param oBrowse Variavel que contem a GRID do programa

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function C923FILTER(oBrowse)

	Local cQuery      := "exec proc_rfb_s_hist_mov_lotes_w"
	Local cParams     := ""
	Local oColumn
	Local nI          := 0
	Local oFilter     := oBrowse:FWFilter()
	Local aFilter     := nil
	Local cMsg := ""
	Local cCampo := ''
   Local cOpcao := '0'
   Local vIni_nI  
    
	if !SVALFILTRO(oFilter)
		alert(STR0015)
		return
	endif

	aFilter := oFilter:GetFilter(.T.)

	if (!C923GF(aFilter, @cParams, @cMsg, @cOpcao))
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
     
   vIni_nI := 1
    
	for nI := vIni_nI to nColSize
	    
		oColumn := nil

		cCampo := STransType(aStruct[nI][1])
		cCampo := "{|| "+cCampo+"}"

		oColumn := FWBrwColumn():New()
		oColumn:SetData(  &(cCampo) )
		oColumn:SetTitle( aStructDesc[nI][1]   )
		oColumn:SetSize(  aStructDesc[nI][2]   )

		oBrowse:SetColumns({oColumn})
	Next

	oBrowse:UpdateBrowse()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} C923GF
Processa os filtros para recuperar os parametros para as procedures

@param aFilter Informacoes selecionadas pelo usuario
@param cParams Variavel que retornara os parametros da procedure
@param cMsg Variavel que retorna mensagem de erro caso houver
@param cOpcao Varival que retorna a opção escolhida

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function C923GF(aFilter, cParams, cMsg, cOpcao)
	Local aRetZoom := {}
	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif

	cOpcao := STransType(aFilter[1][4][21][1])

	C923CTMP(cOpcao)

	do case
		case cOpcao == '0' //A) Lotes que entraram

			cParams += "'"+STrim(SDBDate(aFilter[1][4][3][1], '00:00:00'))+"',"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][6][1], '23:59:59'))+"',"
			if SEmpty(aFilter[1][4][21][1])
				cParams += "NULL"
			else
				cParams += STransType(aFilter[1][4][21][1])
			endif
			cParams += ",NULL,NULL"

		case cOpcao == '1' //B) Lotes que saíram

			cParams += "'"+STrim(SDBDate(aFilter[1][4][3][1], '00:00:00'))+"',"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][6][1], '23:59:59'))+"',"
			if SEmpty(aFilter[1][4][21][1])
				cParams += "NULL"
			else
				cParams += STransType(aFilter[1][4][21][1])
			endif
			cParams += ",NULL,NULL"

		case cOpcao == '2' //C) Lotes que entraram por consignatário

			cParams += "'"+STrim(SDBDate(aFilter[1][4][3][1], '00:00:00'))+"',"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][6][1], '23:59:59'))+"',"
			if SEmpty(aFilter[1][4][21][1])
				cParams += "NULL"
			else
				cParams += STransType(aFilter[1][4][21][1])
			endif
			cParams += ",NULL"
			/*
			if !(SEmpty(aFilter[1][4][9][1]))
			  aRetZoom := PRAC938(SZoomConsig(.T.,.F.,.T.), STrim(STransType(aFilter[1][4][9][1])), .T.)
			  if !SEmpty(aRetZoom)
			    nCodAll := STrim(STransType(aRetZoom[1]))
			  endif	  
			endif*/
			
			if SEmpty(nCodAll)
				cParams += ",NULL"
			else
				cParams += ",'"+STrim(STransType(nCodAll))+"'"
			endif


		case cOpcao == '3' //D) Lotes que saíram por remetente

			cParams += "'"+STrim(SDBDate(aFilter[1][4][3][1], '00:00:00'))+"',"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][6][1], '23:59:59'))+"',"
			cParams += STransType(aFilter[1][4][21][1])
			cParams += ",NULL,
			
			/*if .NOT.(SEmpty(aFilter[1][4][18][1]))
			  aRetZoom := PRAC938(SZoomConsig(.T.,.F.,.T.),; 
			                      STrim(STransType(aFilter[1][4][18][1])), .T.)
			  if !SEmpty(aRetZoom)
			    nCodAll := STrim(STransType(aRetZoom[1]))
			  endif	  
			endif*/
			
			if SEmpty(nCodAll)
				cParams += "NULL"
			else
				cParams += "'"+STrim(STransType(nCodAll))+"'"
			endif

		case cOpcao == '4' //E) Lotes por regime aduaneiro

			cParams += "'"+STrim(SDBDate(aFilter[1][4][3][1], '00:00:00'))+"',"
			cParams += "'"+STrim(SDBDate(aFilter[1][4][6][1], '23:59:59'))+"',"
			cParams += STransType(aFilter[1][4][21][1])
			
			/*if .NOT.(SEmpty(aFilter[1][4][12][1]))
			  aRetZoom := PRAC938(SZoomReg(.T.,.T.),; 
			                      STrim(STransType(aFilter[1][4][12][1])), .T.)
			  if !SEmpty(aRetZoom)
			    nCodReg := STrim(STransType(aRetZoom[1]))
			  endif	  
			endif*/
			
			if (SEmpty(nCodReg) .OR. (nCodReg == '0'))
				cParams += ",NULL,"
			else
				cParams += ","+STrim(STransType(nCodReg))+","
			endif

			/*if .NOT.(SEmpty(aFilter[1][4][15][1]))
			  aRetZoom := PRAC938(SZoomConsig(.T.,.F.,.T.),; 
			                      STrim(STransType(aFilter[1][4][15][1])), .T.)
			  if !SEmpty(aRetZoom)
			    nCodAll := STrim(STransType(aRetZoom[1]))
			  endif	  
			endif*/

			if SEmpty(nCodAll)
				cParams += "NULL"
			else
				cParams += "'"+STrim(STransType(nCodAll))+"'"
			endif

	endcase
	cParams += ",'"+SGetDBOwner() + cAliasTb+"'"

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} C922ZOOM
Funcao que seleciona o ZOOM para o usuario

@param oObj Objeto que o resultado do zoom ira retornar
@param nTipoZoom Variavel que distingue o tipo de zoom uilizado

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function C923ZOOMP(oObj, nTipoZoom)
	Local aZoom := {}
	Local aRetZoom := {}
	Local lRet := .T.

	do case
		case nTipoZoom == 1
			aZoom := SZoomConsig(.T.,.F.,.T.)

		case nTipoZoom == 2
			aZoom := SZoomReg(.T.,.T.)
	endcase
 
    if(len(aRetZoom) <= 0)
	   aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)
	endif

	if !SEmpty(aRetZoom)
		oObj:cText := STrim(STransType(aRetZoom[2]))
		if nTipoZoom == 2
			nCodReg := STrim(STransType(aRetZoom[1]))
		else
			nCodAll := STrim(STransType(aRetZoom[1]))
		endif
	else
		oObj:cText := '                                        '
		nCodAll := ''
	endif
return lRet

*---------------------------*
Function C923VREGI(xConteud, o)
*---------------------------*
	nCodAll := ''
	if !SEmpty(xConteud)
		if C923ZOOMP(o, 2)
			return .T.
		else
			Alert(STR0016)
			return .F.
		endif
	endif
return .T.

*---------------------------*
Function C923VCONS(xConteud, o)
*---------------------------*
	nCodAll := ''
	if !SEmpty(xConteud)
		if C923ZOOMP(o, 1)
			return .T.
		else
			Alert(STR0017)
			return .F.
		endif
	endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} C922CTB
Funcao que cria a estrutura da tabela

@param cOpcao Variavel que contem a opcao selecionada pelo usuario
@return aStructDesc Variavel que retornara a descricao dos campos da tabela

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function C923CTMP(cOpcao)
   if cOpcao == '0'
      aStructDesc := {;
                       {STR0019 ,  8}, ;
                       {STR0018 , 14}, ;
                       {'Tipo de Documento'  , 5},  ;
                       {'Documento de Transporte Nacional' , 15}, ;
                       {'Tipo de Documento', 5},  ;                       
                       {'Documento de Transporte Internacional' , 15}, ;
                       {STR0021 , 33}, ;
                       {STR0022 , 33}, ;
                       {STR0023 , 20}  ;
                       }
					
      aStruct := {;
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
   end if
   if cOpcao == '1'
      aStructDesc := {;
                       {STR0019 ,  8}, ;
                       {STR0027 , 12}, ;
                       {'Tipo de Documento'  , 5}, ;
                       {'Documento de Transporte Nacional' , 15}, ;
                       {'Tipo de Documento'  , 5}, ;
                       {'Documento de Transporte Internacional' , 15}, ;
                       {STR0021 , 12}, ;
                       {STR0022 , 25}, ;
                       {STR0023 , 12}  ;
                       }
				
      aStruct := {;
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
   end if	
   if cOpcao == '2'
      aStructDesc := {;
                       {STR0019 , 8},  ;                       
                       {STR0018 , 14}, ;                      
                       {STR0021 , 12}, ;                   
                       {STR0024 , 35}, ;
                       {'Tipo de Documento'  , 5}, ;                       
                       {'Documento de Transporte Nacional' , 15}, ;
                       {'Tipo de Documento'  , 5}, ;                       
                       {'Documento de Transporte Internacional' , 15}, ;
                       {'Tipo de Documento'  , 5}, ;
                       {STR0026 , 15} ;
                       }
					
      aStruct := {;
                  {'CP1'  ,'C', 100 ,0}, ;
                  {'CP2'  ,'C', 100 ,0}, ;
                  {'CP3'  ,'C', 100 ,0}, ;
                  {'CP4'  ,'C', 100 ,0}, ;
                  {'CP5'  ,'C', 100 ,0}, ;
                  {'CP6'  ,'C', 100 ,0}, ;
                  {'CP7'  ,'C', 100 ,0}, ;
                  {'CP8'  ,'C', 100 ,0}, ;
                  {'CP9'  ,'C', 100 ,0}, ;
                  {'CP10' ,'C', 100 ,0} ;
                  }						
   end if
   if cOpcao == '3'
      aStructDesc := {;   
                       {STR0019 , 8}, ;
                       {STR0027 , 12}, ;
                       {STR0021 , 12}, ;
                       {STR0029 , 30}, ;
                       {'Tipo de Documento'  , 5}, ;
                       {'Documento de Transporte Nacional' , 15}, ;
                       {'Tipo de Documento'  , 5}, ;
                       {'Documento de Transporte Internacional' , 15}, ;
                       {'Tipo'  , 5}, ;
                       {STR0026 , 15}, ;
                       {STR0023 , 12}  ;
                       }
					
      aStruct := {				 ;
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
                  {'CP11' ,'C', 100 ,0} ;
                  }
   end if
   if cOpcao == '4'
      aStructDesc := {	;
                       {STR0019 ,  8}, ;
                       {STR0030 ,  8}, ;
                       {STR0005 , 22}, ;
                       {STR0031 , 12}, ;
                       {'Tipo'  , 5}, ;                    
                       {STR0026 , 15}, ;              
                       {STR0021 , 12}, ;
                       {STR0022 , 30}  ;
                       }
      aStruct := {				 ;
      	           {'CP1'  ,'C', 100 ,0}, ;
                  {'CP2'  ,'C', 100 ,0}, ;
                  {'CP3'  ,'C', 100 ,0}, ;
                  {'CP4'  ,'C', 100 ,0}, ;
                  {'CP5'  ,'C', 100 ,0}, ;
                  {'CP6'  ,'C', 100 ,0}, ;
                  {'CP7'  ,'C', 100 ,0}, ;
                  {'CP8'  ,'C', 100 ,0} ;
                  }
   end if
			
   SDelTb(cAliasTb)
   SCriaTb(cAliasTb, aStruct)
return aStructDesc

