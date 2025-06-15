#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC926.CH"

#define INFO_ZOOM_TIPO_EXECUCAO_SQL   1

/*/{Protheus.doc} PRAC926
@author   Felipe Machado de Oliveira
@version  P12
@since    22/06/2012
@obs      2.2.10 - Movimentação e Armazenagem de Cargas
/*/
Function PRAC926()

	Local oDlg         := nil
	Local aFields      := {}
	Local oPanel       := nil
	Local oPanel2      := nil
	Local oPanel3      := nil
	Local aFilParser   := {}
	Local aCoors       := FWGetDialogSize(oMainWnd)
	Local oBrowse      := nil
	Local oBrowse2    := nil
	Local oBrowse3     := nil
	Static cOpcaoFiltro := ''	
	Private cAliasTb   := ""
	Private cAliasTb2  := ""
	Private cAliasTb3  := ""
	Private nColSize   := 0
	Private nColSize2  := 0
	Private nColSize3  := 0
	Private aStructDesc
	Private aStruct
	Private aStruct2
	Private aStructD2
	Private aStruct3
	Private aStructD3
	
	Private nCodAll    := nil
	Private nSer       := nil
	Private nTipDoc    := nil
	Private cAno       := ''
	Private cTipo      := ''
	Private cTipoCT    := ''
	Private cStatuGrd2 := 'F'
	Private cStatuGrd3 := 'F'
	Private oLayer     := nil
    
	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

	oLayer := FWLayer():new()
	oLayer:init(oDlg,.F.)
	oLayer:addColumn('Col01',100,.F.)
	oLayer:addWindow('Col01','C1_Win01',STR0001,100,.T.,.F.,,,)
	oLayer:addWindow('Col01','C1_Win02','',100,.T.,.F.,,,)
	oLayer:addWindow('Col01','C1_Win03','',100,.T.,.F.,,,)
	oLayer:winChgState('Col01','C1_Win02')
	oLayer:winChgState('Col01','C1_Win03')

	oPanel  := oLayer:getWinPanel('Col01','C1_Win01')
	oPanel2  := oLayer:getWinPanel('Col01','C1_Win02')
	oPanel3  := oLayer:getWinPanel('Col01','C1_Win03')
                        //Campo                       ,Descricao ,Tipo , Tam , Ali  , Mascara        , Nil , Zoom                 , Vali                                , ValorPadrao
	Aadd(aFields, {"P1"  ,/*Lote*/                  STR0002 , "C"   , 20  , nil  , "@R 99/999999-9", nil , "C926ZOOMM(o, 2, 2)" , {|xConteud,o| C926VALOT(xConteud,o)} , nil})
	Aadd(aFields, {"P2"  ,/*Lote*/                  STR0002 , "C"   , 20  , nil  , "@R 99/999999-9", nil , "C926ZOOMM(o, 1)"    , {|xConteud,o| C926VALOE(xConteud,o)} , nil})
	Aadd(aFields, {"P3"  ,/*Documento de entrada*/STR0003 , "C"   , 20  , nil  , nil               , nil , "C926ZOOMM(o, 2)"    , {|xConteud,o| C926VADOE(xConteud,o)} , nil})
	Aadd(aFields, {"P4"  ,/*Numero*/                STR0004 , "C"   , 20  , nil  , nil               , nil , "C926ZOOMM(o, 3)"    , {|xConteud,o| C926VALNU(xConteud,o)} , nil})
	Aadd(aFields, {"P5"  ,/*Data inicial*/         STR0005 , "D"   , 20  , nil  , nil               , nil , nil                   , nil                                       , (Date() - 30)})
	Aadd(aFields, {"P6"  ,/*Data final*/           STR0006 , "D"   , 20  , nil  , nil               , nil , nil                    , nil                                       , Date()})
	Aadd(aFields, {"P7"  ,/*cosig/import/export*/ STR0007 , "C"   , 30  , nil  , nil               , nil , "C926ZOOMM(o, 4)"    , {|xConteud,o| C926VACIE(xConteud,o)} , nil})
	Aadd(aFields, {"P8"  ,/*Veiculo*/               STR0008 , "C"   , 20  , nil  , nil               , nil , "C926ZOOMM(o, 5)"    , {|xConteud,o| C926VAVEI(xConteud,o)} , nil})
	Aadd(aFields, {"P9"  ,/*Container*/             STR0009 , "C"  , 20  , nil   , nil               , nil , "C926ZOOMM(o, 6)"    , {|xConteud,o| C926VACOT(xConteud,o)} , nil})
	Aadd(aFields, {"P10" ,/*Conhecimento*/         STR0010 , "C"   , 20  , nil  , nil               , nil , "C926ZOOMM(o, 7)"    , {|xConteud,o| C926VACON(xConteud,o)} , nil})
	Aadd(aFields, {"P11" ,/*opcao*/                 STR0011 , "C"   ,  1  , nil  , nil               , nil , nil                    , nil                                       , nil})

	Aadd(aFields, {"P12" ,/*Tipo documento*/       STR0087 , "C"  , 20  , nil   , nil              , nil , "C926ZOOMM(o, 8)"    , {|xConteud,o| C926VALTP(xConteud, o)} , nil})
	Aadd(aFields, {"P13" ,/*Ano*/         		 	 STR0086 , "C"  , 4   , nil   , nil              , nil , nil                    , {|xConteud, o| C926VALAN(xConteud, o)}, '2012'})
	Aadd(aFields, {"P14"  ,/*Numero*/                STR0004 , "C"   , 20  , nil  , nil               , nil , "C926ZOOMM(o, 9)"    , {|xConteud,o| C926VALNU(xConteud,o)} , nil})

	cAliasTb := SCTBTMPG()
	cAliasTb2 := SCTBTMPG()
	cAliasTb3 := SCTBTMPG()

	oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)
	oBrowse2 := SCBROWSE(oPanel2, cAliasTb2, {})
	oBrowse2:DisableConfig()
	oBrowse2:DisableFilter()
	
	oBrowse3 := SCBROWSE(oPanel3, cAliasTb3, {})
	oBrowse3:DisableConfig()
	oBrowse3:DisableFilter()
	

	aFilParser := {}
	SAddFilPar("P1","==","%P1%",@aFilParser)
	SAddFilPar("P2","==","NULL",@aFilParser)
	SAddFilPar("P3","==","NULL",@aFilParser)
	SAddFilPar("P4","==","NULL",@aFilParser)
	SAddFilPar("P5","==","NULL",@aFilParser)
	SAddFilPar("P6","==","NULL",@aFilParser)
	SAddFilPar("P7","==","NULL",@aFilParser)
	SAddFilPar("P8","==","NULL",@aFilParser)
	SAddFilPar("P9","==","NULL",@aFilParser)
	SAddFilPar("P10","==","NULL",@aFilParser)
	SAddFilPar("P11","==","0",@aFilParser)
	SAddFilPar("P12","==","NULL",@aFilParser)
	SAddFilPar("P13","==","NULL",@aFilParser)
	SAddFilPar("P14","==","NULL",@aFilParser)
	oBrowse:AddFilter(STR0012, "P1=='%P1%' .AND. P2==NULL .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11=='0' .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL", .F., .F.,nil,.T., aFilParser, '0')

	aFilParser := {}
	SAddFilPar("P1","==","NULL",@aFilParser)
	SAddFilPar("P2","==","NULL",@aFilParser)
	SAddFilPar("P3","==","%P3%",@aFilParser)
	SAddFilPar("P4","==","NULL",@aFilParser)
	SAddFilPar("P5","==","NULL",@aFilParser)
	SAddFilPar("P6","==","NULL",@aFilParser)
	SAddFilPar("P7","==","NULL",@aFilParser)
	SAddFilPar("P8","==","NULL",@aFilParser)
	SAddFilPar("P9","==","NULL",@aFilParser)
	SAddFilPar("P10","==","NULL",@aFilParser)
	SAddFilPar("P11","==","1",@aFilParser)
	SAddFilPar("P12","==","NULL",@aFilParser)
	SAddFilPar("P13","==","NULL",@aFilParser)
	SAddFilPar("P14","==","NULL",@aFilParser)
	oBrowse:AddFilter(STR0013, "P1==NULL .AND. P2=='NULL' .AND. P3=='%P3%' .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11=='1' .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL", .F., .F.,nil,.T., aFilParser, '1')

	aFilParser := {}
	SAddFilPar("P1","==","NULL",@aFilParser)
	SAddFilPar("P2","==","NULL",@aFilParser)
	SAddFilPar("P3","==","NULL",@aFilParser)
	SAddFilPar("P5","==","NULL",@aFilParser)
	SAddFilPar("P6","==","NULL",@aFilParser)
	SAddFilPar("P7","==","NULL",@aFilParser)
	SAddFilPar("P8","==","NULL",@aFilParser)
	SAddFilPar("P9","==","NULL",@aFilParser)
	SAddFilPar("P10","==","NULL",@aFilParser)
	SAddFilPar("P12","==","%P12%",@aFilParser)
	SAddFilPar("P11","==","2",@aFilParser)
	SAddFilPar("P13","==","%P13%",@aFilParser)
	SAddFilPar("P4","==","%P4%",@aFilParser)
	SAddFilPar("P14","==","NULL",@aFilParser)
	oBrowse:AddFilter(STR0014, "P1==NULL .AND. P2==NULL .AND. P3==NULL AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P12==%P12% .AND. P11=='2' .AND. P13==%P13% .AND. P4==%P4% .AND. P14==NULL", .F., .F.,nil,.T., aFilParser, '2')

	aFilParser := {}
	SAddFilPar("P1","==","NULL",@aFilParser)
	SAddFilPar("P2","==","%P2%",@aFilParser)
	SAddFilPar("P3","==","NULL",@aFilParser)
	SAddFilPar("P5","==","NULL",@aFilParser)
	SAddFilPar("P6","==","NULL",@aFilParser)
	SAddFilPar("P7","==","NULL",@aFilParser)
	SAddFilPar("P8","==","NULL",@aFilParser)
	SAddFilPar("P9","==","NULL",@aFilParser)
	SAddFilPar("P10","==","NULL",@aFilParser)
	SAddFilPar("P12","==","%P12%",@aFilParser)
	SAddFilPar("P11","==","3",@aFilParser)
	SAddFilPar("P13","==","NULL",@aFilParser)
	SAddFilPar("P4","==","NULL",@aFilParser)
	SAddFilPar("P14","==","%P14%",@aFilParser)
	oBrowse:AddFilter(STR0015, "P1==NULL .AND. P2=='%P2%' .AND. P3==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P12=='%P12%' .AND. P11=='3' .AND. P13==NULL .AND. P4==NULL .AND. P14==%P14%", .F., .F.,nil,.T., aFilParser, '3')

	aFilParser := {}
	SAddFilPar("P1","==","NULL",@aFilParser)
	SAddFilPar("P2","==","NULL",@aFilParser)
	SAddFilPar("P3","==","NULL",@aFilParser)
	SAddFilPar("P4","==","NULL",@aFilParser)
	SAddFilPar("P5","==","NULL",@aFilParser)
	SAddFilPar("P6","==","NULL",@aFilParser)
	SAddFilPar("P7","==","%P7%",@aFilParser)
	SAddFilPar("P8","==","NULL",@aFilParser)
	SAddFilPar("P9","==","NULL",@aFilParser)
	SAddFilPar("P10","==","NULL",@aFilParser)
	SAddFilPar("P11","==","4",@aFilParser)
	SAddFilPar("P12","==","NULL",@aFilParser)
	SAddFilPar("P13","==","NULL",@aFilParser)
	SAddFilPar("P14","==","NULL",@aFilParser)
	oBrowse:AddFilter(STR0016, "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7=='%P7%' .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11=='4' .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL", .F., .F.,nil,.T., aFilParser, '4')

	aFilParser := {}
	SAddFilPar("P1","==","NULL",@aFilParser)
	SAddFilPar("P2","==","NULL",@aFilParser)
	SAddFilPar("P3","==","NULL",@aFilParser)
	SAddFilPar("P4","==","NULL",@aFilParser)
	SAddFilPar("P5","==","%P5%",@aFilParser)
	SAddFilPar("P6","==","%P6%",@aFilParser)
	SAddFilPar("P7","==","NULL",@aFilParser)
	SAddFilPar("P8","==","NULL",@aFilParser)
	SAddFilPar("P9","==","NULL",@aFilParser)
	SAddFilPar("P10","==","NULL",@aFilParser)
	SAddFilPar("P11","==","5",@aFilParser)
	SAddFilPar("P12","==","NULL",@aFilParser)
	SAddFilPar("P13","==","NULL",@aFilParser)
	SAddFilPar("P14","==","NULL",@aFilParser)
	oBrowse:AddFilter(STR0017, "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4==NULL .AND. P5=='%P5%' .AND. P6=='%P6%' .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11=='5' .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL", .F., .F.,nil,.T., aFilParser, '5')

	aFilParser := {}
	SAddFilPar("P1","==","NULL",@aFilParser)
	SAddFilPar("P2","==","NULL",@aFilParser)
	SAddFilPar("P3","==","NULL",@aFilParser)
	SAddFilPar("P4","==","NULL",@aFilParser)
	SAddFilPar("P5","==","%P4%",@aFilParser)
	SAddFilPar("P6","==","%P5%",@aFilParser)
	SAddFilPar("P7","==","NULL",@aFilParser)
	SAddFilPar("P8","==","NULL",@aFilParser)
	SAddFilPar("P9","==","NULL",@aFilParser)
	SAddFilPar("P10","==","NULL",@aFilParser)
	SAddFilPar("P11","==","6",@aFilParser)
	SAddFilPar("P12","==","NULL",@aFilParser)
	SAddFilPar("P13","==","NULL",@aFilParser)
	SAddFilPar("P14","==","NULL",@aFilParser)
	oBrowse:AddFilter(STR0018, "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4==NULL .AND. P5=='%P5%' .AND. P6=='%P6%' .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11=='6' .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL", .F., .F.,nil,.T., aFilParser, '6')

	aFilParser := {}
	SAddFilPar("P1","==","NULL",@aFilParser)
	SAddFilPar("P2","==","NULL",@aFilParser)
	SAddFilPar("P3","==","NULL",@aFilParser)
	SAddFilPar("P4","==","NULL",@aFilParser)
	SAddFilPar("P5","==","%P4%",@aFilParser)
	SAddFilPar("P6","==","%P5%",@aFilParser)
	SAddFilPar("P7","==","NULL",@aFilParser)
	SAddFilPar("P8","==","%P8%",@aFilParser)
	SAddFilPar("P9","==","NULL",@aFilParser)
	SAddFilPar("P10","==","NULL",@aFilParser)
	SAddFilPar("P11","==","7",@aFilParser)
	SAddFilPar("P12","==","NULL",@aFilParser)
	SAddFilPar("P13","==","NULL",@aFilParser)
	SAddFilPar("P14","==","NULL",@aFilParser)
	oBrowse:AddFilter("h.1) Veículo Desconsolidados", "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4==NULL .AND. P5=='%P5%' .AND. P6=='%P6%' .AND. P7==NULL .AND. P8=='%P8%' .AND. P9==NULL .AND. P10==NULL .AND. P11=='7' .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL", .F., .F.,nil,.T., aFilParser, '7')

	aFilParser := {}
	SAddFilPar("P1","==","NULL",@aFilParser)
	SAddFilPar("P2","==","NULL",@aFilParser)
	SAddFilPar("P3","==","NULL",@aFilParser)
	SAddFilPar("P4","==","NULL",@aFilParser)
	SAddFilPar("P5","==","%P4%",@aFilParser)
	SAddFilPar("P6","==","%P5%",@aFilParser)
	SAddFilPar("P7","==","NULL",@aFilParser)
	SAddFilPar("P8","==","NULL",@aFilParser)
	SAddFilPar("P9","==","%P9%",@aFilParser)
	SAddFilPar("P10","==","NULL",@aFilParser)
	SAddFilPar("P11","==","8",@aFilParser)
	SAddFilPar("P12","==","NULL",@aFilParser)
	SAddFilPar("P13","==","NULL",@aFilParser)
	SAddFilPar("P14","==","NULL",@aFilParser)
	oBrowse:AddFilter("h.2) Container Desconsolidados", "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4==NULL .AND. P5=='%P5%' .AND. P6=='%P6%' .AND. P7==NULL .AND. P8==NULL .AND. P9=='%P9%' .AND. P10==NULL .AND. P11=='8' .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL", .F., .F.,nil,.T., aFilParser, '8')

	aFilParser := {}
	SAddFilPar("P1","==","NULL",@aFilParser)
	SAddFilPar("P2","==","NULL",@aFilParser)
	SAddFilPar("P3","==","NULL",@aFilParser)
	SAddFilPar("P4","==","NULL",@aFilParser)
	SAddFilPar("P5","==","NULL",@aFilParser)
	SAddFilPar("P6","==","NULL",@aFilParser)
	SAddFilPar("P7","==","NULL",@aFilParser)
	SAddFilPar("P8","==","NULL",@aFilParser)
	SAddFilPar("P9","==","NULL",@aFilParser)
	SAddFilPar("P10","==","%P10%",@aFilParser)
	SAddFilPar("P11","==","9",@aFilParser)
	SAddFilPar("P12","==","NULL",@aFilParser)
	SAddFilPar("P13","==","NULL",@aFilParser)
	SAddFilPar("P14","==","NULL",@aFilParser)
	oBrowse:AddFilter("i) Conhecimento Master", "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10=='%P10%' .AND. P11=='9' .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL", .F., .F.,nil,.T., aFilParser, '9')

	oBrowse:SetChange({|| C926CHANGE(oBrowse, oBrowse2, oBrowse3)})
	oBrowse:Activate()
	DES_FIL_BW(oBrowse)//Desabilita edicao filtros

	oBrowse:oFWFilter:SetExecute({||C926FILTER(oBrowse,oBrowse2,oBrowse3)})
	oBrowse:oFWFilter:FilterBar(nil,.F.,.F.)
		
    oBrowse2:Activate()
    oBrowse3:Activate()

	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTb(cAliasTb)
	SDelTb(cAliasTb2)
	SDelTb(cAliasTb3)

return

static function C926CHANGE(oBrowse, oBrowse2, oBrowse3)
	Local cLotePai := ''
	Local cLtPaiRf := ''
	Local cLtPaiRf2 := ''
	Local cCampo := ''
	Local cCesv_id := ''
	Local cDiferenca := ''
	Local cPesoAferido := ''
	Local oColumn
	Local nI          := 0
	Local oColumn
	
	Local cQryAux := ''
	Local cQryAux2 := ''
	Local cAliasAux := GetNextAlias()
	Local cAliasAux2 := GetNextAlias()
	
	Local nContReg := 0
	Local nCP2Tot := 0
	Local nCP3Tot := 0
	Local nCP4Tot := 0
	

	if cOpcaoFiltro == '5'
		cLtPaiRf := Alltrim(STrim((cAliasTb)->(FieldGet(1))))
		if Alltrim(cLtPaiRf) <> ''
			cLtPaiRf2 := StrTran(cLtPaiRf,'/','',1,1)
			cLtPaiRf2 := StrTran(cLtPaiRf2,'-','',1,1)
			cQryAux := " select lote_id from tab_lote where lote_id_rf = '"+cLtPaiRf2+"'"
			cQryAux := ChangeQuery(cQryAux)
			DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQryAux),cAliasAux,.F.,.T.)
			cLotePai := allTrim(CValToChar((cAliasAux)->lote_id))
			(cAliasAux)->(dbCloseArea())
	
			TcSqlExec("Delete from "+SGetDBOwner() + cAliasTb2)
	
			if cLotePai <> ''
				
				cQryAux2:= "select distinct substring(a.lote_id_rf,1,2) +'/'+"
				cQryAux2+= "                +substring(a.lote_id_rf,3,6)+'-'+"
				cQryAux2+= "                +substring(a.lote_id_rf,9,1) as 'CP1',"
				cQryAux2+= "       isnull((select sum(isnull(c.hcar_qt_ret,0))"
				cQryAux2+= "                 from tab_historico_carga c"
				cQryAux2+= "                where c.hcar_lote = a.lote_id),0) as 'CP2',"
				cQryAux2+= "       isnull((select sum(isnull(d.latu_qt_saldo,0))"
				cQryAux2+= "                 from vw_opr_GCI_LoteAtual d"
				cQryAux2+= "                where d.latu_lote = a.lote_id),0) as 'CP3',"
				cQryAux2+= "       isnull((select sum(isnull(e.oitem_peso,0)) "
				cQryAux2+= "                 from tab_os_item e"
				cQryAux2+= "                where e.lote_id = a.lote_id),0) as 'CP4',"
				cQryAux2+= "       isnull((case substring(b.dsai_id,5,1)"
				cQryAux2+= "                 when '9' then                 "
				cQryAux2+= "                   (case substring(b.dsai_id,6,1)"
				cQryAux2+= "                      when '0' then              "
				cQryAux2+= "                        'DA'"
				cQryAux2+= "                      when '1' then"
				cQryAux2+= "                        'CDA'"
				cQryAux2+= "                    end)  "
				cQryAux2+= "                 else   "
				cQryAux2+= "                   (select doc_id "
				cQryAux2+= "                      from tab_documentos  "
				cQryAux2+= "                     where doc_ordem1 = substring(b.dsai_id,5,1) "
				cQryAux2+= "                    )                         "
				cQryAux2+= "	 end),' ') as 'CP5',"
				cQryAux2+= "   IsNull(case isnull(b.dsai_id,'')"
				cQryAux2+= "         when '' then ''"
				cQryAux2+= "         else   "
				cQryAux2+= "           isnull(substring(b.dsai_id,1,4)++'/'++"
				cQryAux2+= "                  substring(b.dsai_id,7,len(b.dsai_id)"
				cQryAux2+= "                  ) ,'')"
				cQryAux2+= "       end,' ') as 'CP6'"
				cQryAux2+= "  from tab_lote a   "
				cQryAux2+= "       left join tab_di_item b "
				cQryAux2+= "              on b.latu_lote = a.lote_id "
				cQryAux2+= " where a.lote_id in (select lote_filho   "
				cQryAux2+= "                       from rel_lote    "
				cQryAux2+= "                      where lote_pai = '"+cLotePai+"'"
				cQryAux2+= "                     )"
				cQryAux2+= "   and a.lote_tipo not in ('M','S')"
				cQryAux2+= "   and a.lote_cancelado is null"
				cQryAux2 := ChangeQuery(cQryAux2)
				DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQryAux2),cAliasAux2,.F.,.T.)
		
				while (cAliasAux2)->(!EOF())
					nContReg += 1
					if nContReg == 1
						TcSqlExec("Insert into "+SGetDBOwner() + cAliasTb2+" values ('Lote Original : "+cLtPaiRf+"',' ',' ',' ',' ',' ',' ',' ',1)")
						nContReg += 1
					end if
					nCP2Tot += (cAliasAux2)->CP2
					nCP3Tot += (cAliasAux2)->CP3
					nCP4Tot += (cAliasAux2)->CP4
					TcSqlExec("Insert into "+SGetDBOwner() + cAliasTb2+" values (' ','"+AllTrim((cAliasAux2)->CP1)+"','"+;
						AllTrim(CValToChar(TRANSFORM((cAliasAux2)->CP2,'9999999.9999')))+"','"+;
						AllTrim(CValToChar(TRANSFORM((cAliasAux2)->CP3,'9999999.9999')))+"','"+;
						AllTrim(CValToChar(TRANSFORM((cAliasAux2)->CP4,'9999999.9999')))+"','"+;
						AllTrim((cAliasAux2)->CP5)+"','"+;
						AllTrim((cAliasAux2)->CP6)+"','"+;
						" ',"+;
						AllTrim(CValToChar(nContReg))+")")
					(cAliasAux2)->(DbSkip())
				EndDo
				(cAliasAux2)->(dbCloseArea())
				if nContReg > 0
					nContReg += 1
					TcSqlExec("Insert into "+SGetDBOwner() + cAliasTb2+" values ('Total : ',' ','"+AllTrim(CValToChar(TRANSFORM(nCP2Tot,'9999999.9999')))+;
						"','"+AllTrim(CValToChar(TRANSFORM(nCP3Tot,'9999999.9999')))+"','"+AllTrim(CValToChar(TRANSFORM(nCP4Tot,'9999999.9999')))+;
						"',' ',' ',' ',"+AllTrim(CValToChar(nContReg))+")")
				end if
			
				(cAliasTb2)->(dbCloseArea())
				DbUseArea(.T.,'TOPCONN',cAliasTb2,cAliasTb2,.T.,.F.)

				nColSize2 := Len(oBrowse2:aColumns)

				for nI := 1 to nColSize2
					oBrowse2:DelColumn(nI)
				next
				nColSize2 := Len(aStruct2)

				for nI := 1 to nColSize2
					oColumn := nil

					cCampo := STransType(aStruct2[nI][1])
					cCampo := "{|| "+cCampo+"}"

					oColumn := FWBrwColumn():New()
					oColumn:SetData(  &(cCampo) )
					oColumn:SetTitle( aStructD2[nI][1]   )
					oColumn:SetSize(  aStructD2[nI][2]   )

					oBrowse2:SetColumns({oColumn})
				next
			endif
			oBrowse2:SetBlkBackColor( { || C926COLOR2()} )
			oBrowse2:SetBlkColor( { || C926COLOR3()} )
	
			oBrowse2:updateBrowse()
			oBrowse:SetFocus()
		end if
	end if
	if cOpcaoFiltro == '7' .or. cOpcaoFiltro == '8'
	  cCesv_id:= Alltrim(STrim((cAliasTb)->(FieldGet(1))))
	  if cCesv_id <> ''
	    cDiferenca := Alltrim(CValToChar((cAliasTb)->(FieldGet(6))))
	    cPesoAferido := Alltrim(CValToChar((cAliasTb)->(FieldGet(4))))
	    cQryAux2   := 'exec proc_rfb_sel_lote_orig_w "'+cCesv_id+'",'+cDiferenca+','+cPesoAferido+',"'+SGetDBOwner() + cAliasTb2+'", null'
	    TcSqlExec(cQryAux2)

	    (cAliasTb2)->(dbCloseArea())
	    DbUseArea(.T.,'TOPCONN',cAliasTb2,cAliasTb2,.T.,.F.)
	    
	    nColSize2 := Len(oBrowse2:aColumns)

		 for nI := 1 to nColSize2		 
		   oBrowse2:DelColumn(nI)
		 next
  		
  		 nColSize2 := Len(aStruct2)
		 
		 for nI := 1 to nColSize2
		   	oColumn := nil

			cCampo := STransType(aStruct2[nI][1])
			cCampo := "{|| "+cCampo+"}"

			oColumn := FWBrwColumn():New()
			oColumn:SetData(  &(cCampo) )
			oColumn:SetTitle( aStructD2[nI][1]   )
			oColumn:SetSize(  aStructD2[nI][2]   )

			oBrowse2:SetColumns({oColumn})
		 next		 
	  end if
	  oBrowse2:SetChange({|| C926CHANGB(oBrowse2,oBrowse3)})
	  oBrowse2:SetBlkBackColor( { || C926COLOR2()} )
	  oBrowse2:SetBlkColor( { || C926COLOR3()} )
	  oBrowse2:updateBrowse()
	  C926CHANGB(oBrowse2, oBrowse3)
	  oBrowse:SetFocus()	
	end if 
return


static function C926CHANGB(oBrowse2, oBrowse3)
	Local cLotePai := ''
	Local cLtPaiRf := ''
	Local cLtPaiRf2 := ''
	Local cCampo := ''
	Local cCesv_id := ''
	Local cDiferenca := ''
	Local cPesoVeif  := ''
	Local oColumn
	Local nI          := 0
	Local oColumn
	
	Local cQryAux := ''
	Local cQryAux2 := ''
	Local cAliasAux := GetNextAlias()


	if cOpcaoFiltro == '7' .or. cOpcaoFiltro == '8'
	
      cLtPaiRf := Alltrim(STrim((cAliasTb2)->(FieldGet(2))))
	  if Alltrim(cLtPaiRf) <> ''
		 cLtPaiRf2 := StrTran(cLtPaiRf,'/','',1,1)
		 cLtPaiRf2 := StrTran(cLtPaiRf2,'-','',1,1)
		 cQryAux := " select lote_id from tab_lote where lote_id_rf = '"+cLtPaiRf2+"'"
		 cQryAux := ChangeQuery(cQryAux)
		
		 DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQryAux),cAliasAux,.F.,.T.)
		
		 cLotePai := allTrim(CValToChar((cAliasAux)->lote_id))
		(cAliasAux)->(dbCloseArea())
		
		 cPesoVeif  := Alltrim(CValToChar((cAliasTb2)->(FieldGet(4))))
		 cDiferenca := Alltrim(CValToChar((cAliasTb2)->(FieldGet(5))))	
		
		 cQryAux2   := 'exec proc_rfb_sel_lote_filho_w "'+cLotePai+'",'+cDiferenca+','+cPesoVeif+',"'+SGetDBOwner() + cAliasTb3+'"'
	    
	     TcSqlExec(cQryAux2)

	    (cAliasTb3)->(dbCloseArea())
	    DbUseArea(.T.,'TOPCONN',cAliasTb3,cAliasTb3,.T.,.F.)
	    
	    nColSize3 := Len(oBrowse3:aColumns)

		 for nI := 1 to nColSize3		 
		   oBrowse3:DelColumn(nI)
		 next
  		
  		 nColSize3 := Len(aStruct3)
		 
		 for nI := 1 to nColSize3
		   	oColumn := nil

			cCampo := STransType(aStruct3[nI][1])
			cCampo := "{|| "+cCampo+"}"

			oColumn := FWBrwColumn():New()
			oColumn:SetData(  &(cCampo) )
			oColumn:SetTitle( aStructD3[nI][1]   )
			oColumn:SetSize(  aStructD3[nI][2]   )

			oBrowse3:SetColumns({oColumn})
		 next	

	  end if
	  oBrowse3:SetBlkBackColor( { || C926COLOR4()} )
      oBrowse3:SetBlkColor( { || C926COLOR5()} )
      oBrowse3:updateBrowse()	 
	end if  	 	
	
return


//-------------------------------------------------------------------
/*/{Protheus.doc} C926FILTER
Funcao que sera executada no momento em que o filtro for acionado, para tratar as informações

@param oBrowse Variavel que contem a GRID do programa

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static function C926FILTER(oBrowse,oBrowse2, oBrowse3)

	Local cQuery      := "exec proc_rfb_sel_movarm_carga_w"
	Local cParams     := ""
	Local oColumn
	Local nI          := 0
	Local nX          := 0
	Local oFilter     := oBrowse:FWFilter()
	Local aFilter     := nil
	Local cMsg := ""
	Local cCampo := ' '
	Local cOpcao := ' '

	aFilter := oFilter:GetFilter(.T.)

	if !SVALFILTRO(oFilter)
		alert(STR0021)
		return
	endif

	if (!C926GF(aFilter, @cParams, @cMsg, @cOpcao))
		if (!SEmpty(cMsg))
			alert(cMsg)
		endif
		return
	endif
   cOpcaoFiltro := cOpcao
    
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
    
	if cOpcao == '9'
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
	
	oBrowse:SetBlkBackColor( { || C926COLORB()} )
	oBrowse:SetBlkColor( { || C926COLOR()} )
	
	oBrowse:UpdateBrowse()
	
	
	C926CHANGE(oBrowse, oBrowse2, oBrowse3)
		
	if cOpcao == '5'
		if cStatuGrd2 == 'F'
			oLayer:winChgState('Col01','C1_Win02')			
			cStatuGrd2 := 'A'
			oBrowse2:Show()
		end if
		if cStatuGrd3 == 'A'
		  oLayer:winChgState('Col01','C1_Win03')
		  oLayer:setWinTitle('Col01','C1_Win03','')
		  cStatuGrd3 := 'F'
		  oBrowse3:Hide()
		end if		
		oLayer:setWinTitle('Col01','C1_Win02','Lotes Gerados / Saídas')
	else
	   if cOpcao == '7' .or. cOpcao == '8'
	   		if cStatuGrd2 == 'F'
			  oLayer:winChgState('Col01','C1_Win02')		  	  
			  cStatuGrd2 := 'A'
			  oBrowse2:Show()
		    end if
	   		if cStatuGrd3 == 'F'
			  oLayer:winChgState('Col01','C1_Win03')
		  	  
			  cStatuGrd3 := 'A'
			  oBrowse3:Show()
		    end if
		    oLayer:setWinTitle('Col01','C1_Win02','Lotes Originais')	
		    oLayer:setWinTitle('Col01','C1_Win03','Lotes Gerados')	    
	   else
		   if cStatuGrd2 == 'A'
			  oLayer:winChgState('Col01','C1_Win02')
			  oLayer:setWinTitle('Col01','C1_Win02','')
			  cStatuGrd2 := 'F'
			  oBrowse2:Hide()
		   end if
		   if cStatuGrd3 == 'A'
			  oLayer:winChgState('Col01','C1_Win03')
			  oLayer:setWinTitle('Col01','C1_Win03','')
			  cStatuGrd3 := 'F'
			  oBrowse3:Hide()
		   end if
       end if
	end if
	
return

//-------------------------------------------------------------------
/*/{Protheus.doc} C926GF
Processa os filtros para recuperar os parametros para as procedures

@param aFilter Informacoes selecionadas pelo usuario
@param cParams Variavel que retornara os parametros da procedure
@param cMsg Variavel que retorna mensagem de erro caso houver
@param cOpcao Variavel que retorna opcao

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
static function C926GF(aFilter, cParams, cMsg, cOpcao)
	local aRetTpCT := {}
	local aZoomTpCt := {}
	local lRetTpCt := .T.

	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif

	cOpcao := STransType(aFilter[1][4][33][1])

	C926CTMP(cOpcao)
	C926CTMP2(cOpcao)

	do case
	case cOpcao == '8'
		cParams := '7'

	case cOpcao == '9'
		cParams := '8'

	otherwise
		cParams := STransType(aFilter[1][4][33][1])
	endcase

	if cOpcao == '5' .OR. cOpcao == '6' .OR. cOpcao == '7' .OR. cOpcao == '8'
		if SDBDate(aFilter[1][4][15][1]) == "0-0-0" .OR. SDBDate(aFilter[1][4][18][1]) == "0-0-0"
			cMsg := STR0081
			return .F.
		endif
	endif

	do case
	case cOpcao == '0' //a) Histórico de Ocorrências  --- @w_lote_id

		if SEmpty(aFilter[1][4][3][1])
			cMsg := STR0082
			return .F.
		endif

		cParams += ",NULL,NULL,NULL,NULL,NULL,"
		cParams += "'"+STrim(STransType(aFilter[1][4][3][1]))+"',"
		cParams += "NULL,NULL,NULL,NULL,NULL,NULL, NULL"

	case cOpcao == '1' // b) Lotes Gerados para o  Documento Aduaneiro  --- @w_dsai_id

		cParams += ",NULL,NULL,NULL,NULL,NULL,NULL,NULL,"
		if SEmpty(STrim(STransType(nCodAll)))
			cParams += "NULL,"
		else
			cParams += "'"+STrim(STransType(nCodAll))+"',"
		endif
		cParams += "NULL,NULL,NULL,NULL, NULL"

	case cOpcao == '2' //c) Lotes Gerados para o Documento de Transporte --- @w_dtran_nr_doc, @w_dtran_nr_serie, @w_dtran_tp_id

		cParams += ",NULL,NULL,NULL,NULL,"
		if SEmpty(STrim(STransType(aFilter[1][4][39][1])))
			cParams += "NULL,"
		else
			cParams += "'"+STrim(STransType(aFilter[1][4][39][1]))+"',"
		endif
		cParams += "NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL"

	case cOpcao == '3' //d) Lotes Desconsolidados --- @w_conhec, @w_lote_id, @w_conhec_id

		if SEmpty(aFilter[1][4][6][1]) // obriga o preechimento do campo lote e/ou tipo conhec + número conhec
			if (SEmpty(aFilter[1][4][30][1])) .or.(SEmpty(aFilter[1][4][42][1]))
				cMsg := STR0091
				return .F.
			endif
		else
			if !SEmpty(aFilter[1][4][30][1])
				if SEmpty(aFilter[1][4][42][1])
					cMsg := STR0091
					return .F.
				endif
			else
				if !SEmpty(aFilter[1][4][42][1])
					cMsg := STR0091
					return .F.
				endif
			endif
		endif
			
		cParams += ",NULL,NULL,NULL,NULL,"
			
		if !SEmpty(aFilter[1][4][30][1]) // usa @w_conhec somente se @w_conhec_id estiver preenchido
			if SEmpty(aFilter[1][4][42][1])
				cParams += "NULL,"
			else
				cParams += "'"+STrim(STransType(aFilter[1][4][42][1]))+"',"
			endif
		else
			cParams += "NULL,"
		endif
			

		if SEmpty(aFilter[1][4][6][1]) // usa @w_lote_id
			cParams += "NULL,"
		else
			cParams += "'"+STrim(STransType(aFilter[1][4][6][1]))+"',"
		endif
			
		cParams += "NULL,NULL,NULL,NULL,NULL,NULL,"
			
		if !SEmpty(aFilter[1][4][42][1]) // usa @w_conhec_id somente se @w_conhec estiver preenchido
			if SEmpty(aFilter[1][4][30][1])
				cParams += "NULL"
			else
				if SEmpty(cTipoCT)
					aZoomTpCt := SZoomDoc() // força a procura pelo campo conhec_id da tab_tipo_conhecimento
					aRetTpCt  := PRAC938(aZoomTpCt, STrim(STransType(aFilter[1][4][30][1])), @lRetTpCt)
					cTipoCT := aRetTpCt[1]
					cParams += cTipoCT
				else
					cParams += cTipoCT
				endif
			endif
		else
			cParams += "NULL"
		endif

	case cOpcao == '4'  //e) Lotes Gerados para o Consolidador --- @w_ben_id

		cParams += ",NULL,NULL,NULL,NULL,NULL,NULL,"
		if SEmpty(STrim(STransType(nCodAll)))
			cParams += "NULL,"
		else
			cParams += "'"+STrim(STransType(nCodAll))+"',"
		endif

		cParams += "NULL,NULL,NULL,NULL,NULL,NULL"

	case cOpcao == '5' //f)  Lotes Masters Desconsolidados ---  @w_dataini, @w_datafim

		cParams += ",'"+STrim(SDBDate(aFilter[1][4][15][1], '00:00:00'))+"',"
		cParams += "'"+STrim(SDBDate(aFilter[1][4][18][1], '23:59:59'))+"',"
		cParams += "NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL"

	case cOpcao == '6' //g) Lotes Avariados --- @w_dataini, @w_datafim

		cParams += ",'"+STrim(SDBDate(aFilter[1][4][15][1], '00:00:00'))+"',"
		cParams += "'"+STrim(SDBDate(aFilter[1][4][18][1], '23:59:59'))+"',"
		cParams += "NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL"

	case cOpcao == '7' //h) Veículo Desconsolidados --- @w_dataini, @w_datafim, @w_cnt_id, @w_vei_id

		if SEmpty(aFilter[1][4][24][1])
			cMsg := STR0083
			return .F.
		endif

		cParams += ",'"+STrim(SDBDate(aFilter[1][4][15][1], '00:00:00'))+"',"
		cParams += "'"+STrim(SDBDate(aFilter[1][4][18][1], '23:59:59'))+"',"
		cParams += "NULL,"
		cParams += "'"+STrim(STransType(aFilter[1][4][24][1]))+"',"
		cParams += "NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL"

	case cOpcao == '8' //i) Container Desconsolidados --- @w_dataini, @w_datafim, @w_cnt_id, @w_vei_id

		if SEmpty(aFilter[1][4][27][1])
			cMsg := STR0084
			return .F.
		endif

		cParams += ",'"+STrim(SDBDate(aFilter[1][4][15][1], '00:00:00'))+"',"
		cParams += "'"+STrim(SDBDate(aFilter[1][4][18][1], '23:59:59'))+"',"
		cParams += "'"+STrim(STransType(aFilter[1][4][27][1]))+"',"
		cParams += "NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL"

	case cOpcao == '9' //j)  Conhecimento Master  --- @w_conhec

		if SEmpty(aFilter[1][4][30][1])
			cMsg := STR0085
			return .F.
		endif

		cParams += ",NULL,NULL,NULL,NULL,"
		cParams += "'"+STrim(STransType(aFilter[1][4][30][1]))+"',"
		cParams += "NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL"

	endcase

	cParams += ",'"+SGetDBOwner() + cAliasTb+"'"
return .T.

*---------------------------*
Function C926VADOE(xConteud,o)
*---------------------------*
	nCodAll := ''
	if !SEmpty(xConteud)
		if C926ZOOMM(o, 2)
			return .T.
		else
			Alert(STR0073)
			return .F.
		endif
	endif
return .T.

*---------------------------*
Function C926VALNU(xConteud, o)
*---------------------------*
	if !SEmpty(xConteud)
		if C926ZOOMM(o, 3)
			return .T.
		else
			Alert(STR0074)
			return .F.
		endif
	endif
return .T.

*---------------------------*
Function C926VACIE(xConteud,o)
*---------------------------*
	nCodAll := ''
	if !SEmpty(xConteud)
		if C926ZOOMM(o, 4)
			return .T.
		else
			Alert(STR0075)
			return .F.
		endif
	endif
return .T.

*---------------------------*
Function C926VALOT(xConteud,o)
*---------------------------*
	if !SEmpty(xConteud)
		if C926ZOOMM(o, 2, 2)
			return .T.
		else
			Alert(STR0077)
			return .F.
		endif
	endif
return .T.

*---------------------------*
Function C926VALOE(xConteud,o)
*---------------------------*
	nCodAll := ''
	if !SEmpty(xConteud)
		if C926ZOOMM(o, 1)
			return .T.
		else
			Alert(STR0077)
			return .F.
		endif
	endif
return .T.

*---------------------------*
Function C926VAVEI(xConteud, o)
*---------------------------*
	if !SEmpty(xConteud)
		if C926ZOOMM(o, 5)
			return .T.
		else
			Alert(STR0078)
			return .F.
		endif
	endif
return

*---------------------------*
Function C926VACOT(xConteud, o)
*---------------------------*
	if !SEmpty(xConteud)
		if C926ZOOMM(o, 6)
			return .T.
		else
			Alert(STR0079)
			return .F.
		endif
	endif
return

*---------------------------*
Function C926VACON(xConteud, o)
*---------------------------*
	if !SEmpty(xConteud)
		if C926ZOOMM(o, 7)
			return .T.
		else
			Alert(STR0080)
			return .F.
		endif
	endif
return .T.

*------------------------------------------*
function C926GETCO(xConteud, nGetCod , nOp)
*------------------------------------------*
	Local cAlias := ''
	Local cQuery := ''
	Local aRet   := .T.

	cAlias := SGetNAlias()

	if 	!SEmpty(xConteud)
		do case
		case nOp == 1
			cQuery := " = '" +STrim(STransType(xConteud))+ "'"

		case nOp == 2
			cQuery := "select distinct a.dent_id "+;
				"from tab_doc_entrada a "+;
				"left outer join tab_clientes d "+;
				"on a.ben_id = d.cli_id, "+;
				"rel_dent_cnt b, "+;
				"tab_lote c "+;
				"where a.dent_id = b.dent_id "+;
				"and c.lote_id = b.lote_id "+;
				"and a.dent_numero = '" +STrim(STransType(xConteud))+ "'"

		case nOp == 3
			cQuery := "select distinct "+;
				"a.dtran_nr_doc, "+;
				"a.dtran_nr_serie, "+;
				"g.dtran_tp_id "+;
				"from tab_doc_transporte a "+;
				"left join rel_dent_doctrans b "+;
				"on b.dtran_id = a.dtran_id "+;
				"left join rel_cesv_dent c "+;
				"on b.dent_id = c.dent_id "+;
				"left join tab_cesv "+;
				"on tab_cesv.cesv_id = c.cesv_id "+;
				"left outer join tab_transportadora "+;
				"on tab_transportadora.trans_id = tab_cesv.trans_id "+;
				"left join rel_dent_cnt d "+;
				"on c.dent_id = d.dent_id "+;
				"left join tab_lote e "+;
				"on d.lote_id = e.lote_id "+;
				"left join tab_clientes f "+;
				"on e.ben_id = f.cli_id, "+;
				"tab_doc_transporte_tipo g "+;
				"where a.dtran_tp_id = g.dtran_tp_id "+;
				"and a.dtran_nr_doc = '" +STrim(STransType(xConteud))+ "'"

		case nOp == 4
			cQuery := "select cli_id from tab_clientes "+;
				"where cli_nome = '" +STrim(STransType(xConteud))+ "'"

		endcase

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		aRet := (cAlias)->(!EoF())
		if aRet == .T.
			nGetCod := (cAlias)->(Fieldget(1))
			if nOp == 3
				nSer    := (cAlias)->(Fieldget(2))
				nTipDoc := (cAlias)->(Fieldget(3))
			endif
		endif

		(cAlias)->(dbCloseArea())
	endif

return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C926ZOOMM
Funcao que seleciona o ZOOM para o usuario

@param oObj Objeto que o resultado do zoom ira retornar
@param nTipoZoom Variavel que distingue o tipo de zoom uilizado
@param nOp Variavel que distingue o retorna do zoom SZoomDEnt

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
function C926ZOOMM(oObj, nTipoZoom, nOp)
	Local lRet := .T.
	Local aZoom    := {}
	Local aRetZoom := {}
	Default nOp    := 1

	if nTipoZoom == 3 .or. nTipoZoom = 9
		if SEmpty(cTipo)
			alert('Favor informar o tipo.')
			return .F.
		endif
	endif

	do case
	case nTipoZoom == 1
		aZoom := SZoomLote()

	case nTipoZoom == 2
		if nOp == 1
			aZoom := C926ZDEN()
		else
			aZoom := SZoomDEnt(.F.,.F.,.T.)
		endif

	case nTipoZoom == 3
		aZoom := SZoomConh3(cAno, cTipo)

	case nTipoZoom == 4
		aZoom := SZoomConCli(.T.,.T.,.F., .F., .T., .F.)

	case nTipoZoom == 5
		aZoom := SZoomVei2()

	case nTipoZoom == 6
		aZoom := SZoomCNTR()

	case nTipoZoom == 7
		aZoom := SZoomConh2()

	case nTipoZoom == 8
		aZoom := SZoomDoc()

	case nTipoZoom == 9
		aZoom := SZoomConh4(cAno, cTipo)

	endcase

	aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

	if !SEmpty(aRetZoom)
		if nTipoZoom == 8
			oObj:cText := aRetZoom[2]
			cTipo := aRetZoom[1]
			cTipoCT := aRetZoom[1]
		elseif ((nTipoZoom == 2) .AND. (nOp == 1))
			oObj:cText := aRetZoom[2]
			nCodAll := aRetZoom[1]
		elseif nTipoZoom == 4
			oObj:cText := aRetZoom[1]
			nCodAll := aRetZoom[2]
		elseif nTipoZoom == 1
			oObj:cText := StrTran(StrTran(STransType(aRetZoom[1],"C"),"/",""),"-","")
		elseif ((nTipoZoom == 2) .AND. (nOp == 2))
			oObj:cText := StrTran(StrTran(STransType(aRetZoom[1],"C"),"/",""),"-","")
		else
			oObj:cText := aRetZoom[1]
		endif
	else
		oObj:cText := '                   '
		if nTipoZoom == 8
			cTipo := ''
		elseif ((nTipoZoom == 4) .OR. ((nTipoZoom == 2) .AND. (nOp == 1)))
			nCodAll := ''
		endif
	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C926CTMP
Funcao que cria a estrutura da tabela

@param cOpcao Variavel que contem a opcao selecionada pelo usuario
@return aStructDesc Variavel que retornara a descricao dos campos da tabela

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
static function C926CTMP(cOpcao)

	do case
	case cOpcao == '0' .OR. cOpcao == '1' .OR. cOpcao == '2'
		aStructDesc := {  ;
			{STR0022 , 12}, ;
			{STR0023 , 25}, ;
			{STR0024 , 30}, ;
			{STR0025 , 20}, ;
			{STR0026 , 20}, ;
			{STR0027 , 20}, ;
			{'Saldo Remanescente (Volume)' , 20}, ;
			{STR0029 , 20}, ;
			{'Saldo Remanescente (Peso)' , 20}, ;
			{STR0031 , 20}, ;
			{STR0032 , 20}, ;
			{STR0033 , 20}, ;
			{STR0034 , 40}  ;
			}

		aStruct := { ;
			{'CP1' ,'C',100,0}, ;
			{'CP2' ,'C',100,0}, ;
			{'CP3' ,'C',100,0}, ;
			{'CP4' ,'C',100,0}, ;
			{'CP5' ,'C',100,0}, ;
			{'CP6' ,'C',100,0}, ;
			{'CP7' ,'C',100,0}, ;
			{'CP8' ,'C',100,0}, ;
			{'CP9' ,'C',100,0}, ;
			{'CP10','C',100,0}, ;
			{'CP11','C',100,0}, ;
			{'CP12','C',100,0}, ;
			{'CP13','C',100,0}  ;
			}

	case cOpcao == '3' .OR. cOpcao == '4'
		do case
		case cOpcao == '3'
			aStructDesc := { ;
				{STR0035 , 20}, ;
				{STR0036 , 20}, ;
				{STR0037 , 20}, ;
				{STR0038 , 20}, ;
				{STR0039 , 20}, ;
				{STR0040 , 20}, ;
				{STR0041 , 20}, ;
				{STR0042 , 20}, ;
				{STR0043 , 20}, ;
				{STR0044 , 20}, ;
				{STR0045 , 20}  ;
				}
		case cOpcao == '4'
			aStructDesc := {   ;
				{STR0002 , 20}, ;
				{STR0046 , 20}, ;
				{STR0047 , 20}, ;
				{STR0004 , 20}, ;
				{STR0042 , 20}, ;
				{STR0043 , 20}, ;
				{STR0044 , 20}, ;
				{STR0045 , 20}, ;
				{STR0048 , 20}, ;
				{STR0049 , 20}, ;
				{STR0050 , 20}  ;
				}
		endcase

		aStruct := { ;
			{'CP1' ,'C',100,0}, ;
			{'CP2' ,'C',100,0}, ;
			{'CP3' ,'C',100,0}, ;
			{'CP4' ,'C',100,0}, ;
			{'CP5' ,'C',100,0}, ;
			{'CP6' ,'C',100,0}, ;
			{'CP7' ,'C',100,0}, ;
			{'CP8' ,'C',100,0}, ;
			{'CP9' ,'C',100,0}, ;
			{'CP10','C',100,0}, ;
			{'CP11','C',100,0} ;
			}
	case  cOpcao == '7'
		aStructDesc := { ;
			{'CESV', 35}, ;
			{'Data entrada' , 20}, ;
			{'Veículo' , 10}, ;
			{'Peso aferido entrada' , 10}, ;
			{'Soma peso (lotes originais)' , 10}, ;
			{'Diferença' , 10} ;
			}
           	
		aStruct := { ;
			{'CP1' ,'C',100,0}, ;
			{'CP2' ,'C',100,0}, ;
			{'CP3' ,'C',100,0}, ;
			{'CP4' ,'C',100,0}, ;
			{'CP5' ,'C',100,0}, ;
			{'CP6' ,'C',100,0} ;
			}
	case cOpcao == '5' .OR. cOpcao == '8'
		do case
		case cOpcao == '5'
			
			aStructDesc := { ;
				{'Lote' , 12}, ;
				{'Quatidade' , 12}, ;
				{'Discrepancia Quantidade' , 12}, ;
				{'Peso Bruto' , 12}, ;
				{'Discrepancia Peso' ,  12}  ;
				}
			aStruct := { ;
				{'CP1' ,'C',100,0}, ;
				{'CP2' ,'C',100,0}, ;
				{'CP3' ,'C',100,0}, ;
				{'CP4' ,'C',100,0}, ;
				{'CP5' ,'C',100,0}  ;
				}
		case  cOpcao == '8'
		aStructDesc := { ;
			{'CESV' , 35}, ;
			{'Data entrada' , 20}, ;
			{'Container' , 10}, ;
			{'Peso aferido entrada' , 10}, ;
			{'Soma peso (lotes originais)' , 10}, ;
			{'Diferença' , 10} ;
			}
           	
		aStruct := { ;
			{'CP1' ,'C',100,0}, ;
			{'CP2' ,'C',100,0}, ;
			{'CP3' ,'C',100,0}, ;
			{'CP4' ,'C',100,0}, ;
			{'CP5' ,'C',100,0}, ;
			{'CP6' ,'C',100,0} ;
			}
		endcase


	case cOpcao == '6' .OR. cOpcao == '9'
		do case
		case cOpcao == '6'
			aStructDesc := { ;
				{'Lote' , 25}, ;
				{STR0062 ,  5}, ;
				{STR0063 ,  5}, ;
				{STR0064 , 10}, ;
				{STR0065 ,  5}, ;
				{STR0066 , 12}, ;
				{STR0067 , 20}  ;
				}
		case cOpcao == '9'
			aStructDesc := { ;
				{STR0069 , 15}, ;
				{STR0068 , 25}, ;
				{STR0070 , 10}, ;
				{STR0062 , 10}, ;
				{STR0065 , 10}, ;
				{STR0071 , 10}, ;
				{STR0072 , 10}  ;
				}
		endcase

		aStruct := { ;
			{'CP1' ,'C',100,0}, ;
			{'CP2' ,'C',100,0}, ;
			{'CP3' ,'C',100,0}, ;
			{'CP4' ,'C',100,0}, ;
			{'CP5' ,'C',100,0}, ;
			{'CP6' ,'C',100,0}, ;
			{'CP7' ,'C',200,0}  ;
			}
	endcase

	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
return aStructDesc

*---------------------------*
Function C926VALAN(xConteud, o)
*---------------------------*
	cAno := xConteud
return .T.

*---------------------------*
Function C926VALTP(xConteud, o)
*---------------------------*
	if !SEmpty(xConteud)
		if C926ZOOMM(o, 8)
			return .T.
		else
			Alert(STR0080)
			return .F.
		endif
	endif
return .T.


Function C926ZDEN()
	Local aRet := {}
	Local aFields := {}
	Local cQuery := ""

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	cQuery := "select distinct a.dent_id, "+;
		"a.dent_numero, "+;
		" substring(c.lote_id_rf,1,2)+'/'+"+;
		" substring(c.lote_id_rf,3,6)+'-'+"+;
		" substring(c.lote_id_rf,9,1) as lote_id_rf,"+;
		"b.lote_id, "+;
		"c.lote_conhec "+;
		"from tab_doc_entrada a "+;
		"left outer join tab_clientes d "+;
		"on a.ben_id = d.cli_id, "+;
		"rel_dent_cnt b, "+;
		"tab_lote c "+;
		"where a.dent_id = b.dent_id "+;
		"and c.lote_id = b.lote_id "+;
		"and c.lote_dt_conhec > (getdate() - 740)"

	Aadd(aRet, cQuery)
	Aadd(aRet, '')

              //aFields,    cCampo ,   cDesc , cTipo, nTamanho, nPrecisao, cMascara , lVisivel, lRetorna
	SAddPField(@aFields , "a.dent_id"     , "dent_id"                  , "C"  , 50 , 0 , "" , .F. , .T., .F., 1)
	SAddPField(@aFields , "a.dent_numero" , STR0004/*"Nr. Documento"*/ , "C"  , 20 , 0 , "" , .T. , .T., .T., 1)
	SAddPField(@aFields , "c.lote_id_rf"     , STR0002/*"Lote"*/          , "C"  , 15 , 0 , "@R 99/999999-9" , .T. , .F.)
	SAddPField(@aFields , "b.lote_id"     , STR0088/*"Lote"*/          , "C"  , 15 , 0 , "" , .T. , .F.)
	SAddPField(@aFields , "c.lote_conhec" , STR0010/*"Conhecimento"*/  , "C"  , 20 , 0 , "" , .T. , .F.)

	Aadd(aRet, aFields)

Return aRet


/*Funções criadas para alterar a cor da linha do grid e do fonte da linha, quando é uma linha de agrupamento*/
//-------------------------------------------------------------------
/*/{Protheus.doc} C926COLOR
Funcao que sera executada para trocar a cor do fonte do grid

@author  A
@since   dd/mm/yyyy
@version P12
@protected
/*/
//-------------------------------------------------------------------

Static Function C926COLOR()
	if (Substr(AllTrim((cAliasTb)->CP2),1,4) == "Cesv") .OR. (Substr(AllTrim((cAliasTb)->CP2),1,10) == "Lote House") .OR. (Substr(AllTrim((cAliasTb)->CP2),1,5) == "Total")
		Return CLR_HBLUE
	endif
return Nil

Static Function C926COLOR3()
	if (AllTrim((cAliasTb2)->CP1) <> '')
		Return CLR_HBLUE
	endif
return Nil

Static Function C926COLOR5()
	if (AllTrim((cAliasTb3)->CP1) <> '')
		Return CLR_HBLUE
	endif
return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} C926COLORB
Funcao que sera executada para trocar a cor de fundo do grid

@author  A
@since   dd/mm/yyyy
@version P12
@protected
/*/
//-------------------------------------------------------------------

Static Function C926COLORB()
	if (Substr(AllTrim((cAliasTb)->CP2),1,4) == "Cesv") .OR. (Substr(AllTrim((cAliasTb)->CP2),1,10) == "Lote House") .OR. (Substr(AllTrim((cAliasTb)->CP2),1,5) == "Total")
		Return CLR_HGRAY
	endif
return Nil

Static Function C926COLOR2()
	if (AllTrim((cAliasTb2)->CP1) <> '')
		Return CLR_HGRAY
	endif
return Nil

Static Function C926COLOR4()
	if (AllTrim((cAliasTb3)->CP1) <> '')
		Return CLR_YELLOW
	endif
return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} C926CTMP
Funcao que cria a estrutura da tabela do Grid 2

@param cOpcao Variavel que contem a opcao selecionada pelo usuario
@return aStructDesc Variavel que retornara a descricao dos campos da tabela 2

@author  Marcelo Nunes
@since   26/02/2015
@version P12
@protected
/*/
//-------------------------------------------------------------------
static function C926CTMP2(cOpcao)
	do case
	case cOpcao == '5'
		aStructD2 := {  ;
			{' ' , 15}, ;
			{'Lote Gerado' , 15}, ;
			{'Quantidade Retirada' , 15}, ;
			{'Saldo' , 15}, ;
			{'Peso' , 15}, ;
			{'Tipo Do. Aduaneiro' , 15}, ;
			{'Documento Aduaneiro' , 30}  ;
			}

		aStruct2 := { ;
			{'CP1' ,'C',100,0}, ;
			{'CP2' ,'C',100,0}, ;
			{'CP3' ,'C',100,0}, ;
			{'CP4' ,'C',100,0}, ;
			{'CP5' ,'C',100,0}, ;
			{'CP6' ,'C',100,0}, ;
			{'CP7' ,'C',100,0}  ;
			}
		SDelTb(cAliasTb2)
		SCriaTb(cAliasTb2, aStruct2)
	
	case cOpcao == '7'
		aStructD2 := {  ;
			{'CESV' , 15}, ;
			{'Lote' , 15}, ;
			{'Peso lote' , 15}, ;
			{'Peso verificado' , 15}, ;
			{'Diferença' , 15}, ;
			{'Diferença relativa' , 15} ;			
			}

		aStruct2 := { ;
			{'CP1' ,'C',100,0}, ;
			{'CP2' ,'C',100,0}, ;
			{'CP3' ,'C',100,0}, ;
			{'CP4' ,'C',100,0}, ;
			{'CP5' ,'C',100,0}, ;
			{'CP6' ,'C',100,0} ;
			}
		SDelTb(cAliasTb2)
		SCriaTb(cAliasTb2, aStruct2)
		
		aStructD3 := {  ;
			{'Lote original' , 15}, ;
			{'Lote gerado' , 15}, ;
			{'Peso lote' , 15}, ;
			{'Peso verificado' , 15}, ;
			{'Diferença' , 15}, ;
			{'Diferença relativa' , 15} ;			
			}

		aStruct3 := { ;
			{'CP1' ,'C',100,0}, ;
			{'CP2' ,'C',100,0}, ;
			{'CP3' ,'C',100,0}, ;
			{'CP4' ,'C',100,0}, ;
			{'CP5' ,'C',100,0}, ;
			{'CP6' ,'C',100,0} ;
			}
		SDelTb(cAliasTb3)
		SCriaTb(cAliasTb3, aStruct3)		
		
		
		
	case cOpcao == '8'
		aStructD2 := {  ;
			{'CESV' , 15}, ;
			{'Lote' , 15}, ;
			{'Peso lote' , 15}, ;
			{'Peso verificado' , 15}, ;
			{'Diferença' , 15}, ;
			{'Diferença relativa' , 15} ;
			}

		aStruct2 := { ;
			{'CP1' ,'C',100,0}, ;
			{'CP2' ,'C',100,0}, ;
			{'CP3' ,'C',100,0}, ;
			{'CP4' ,'C',100,0}, ;
			{'CP5' ,'C',100,0}, ;
			{'CP6' ,'C',100,0} ;
			}
		SDelTb(cAliasTb2)
		SCriaTb(cAliasTb2, aStruct2)
		
		aStructD3 := {  ;
			{'Lote original' , 15}, ;
			{'Lote gerado' , 15}, ;
			{'Peso lote' , 15}, ;
			{'Peso verificado' , 15}, ;
			{'Diferença' , 15}, ;
			{'Diferença relativa' , 15} ;			
			}

		aStruct3 := { ;
			{'CP1' ,'C',100,0}, ;
			{'CP2' ,'C',100,0}, ;
			{'CP3' ,'C',100,0}, ;
			{'CP4' ,'C',100,0}, ;
			{'CP5' ,'C',100,0}, ;
			{'CP6' ,'C',100,0} ;
			}
		SDelTb(cAliasTb3)
		SCriaTb(cAliasTb3, aStruct3)			
		
	endcase
	
return aStructDesc2
