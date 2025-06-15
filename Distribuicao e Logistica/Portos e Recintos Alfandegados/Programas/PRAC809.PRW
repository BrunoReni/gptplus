#INCLUDE "PRAC809.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"


Function PRAC809() 
	Local oBrowse
	Local oButton
	Local oColumn
	Local aIndex := {}
	Local aSeek  := {}
	Local cAlias2 := GetNextAlias()
	Local cAliasAGE := 'AGEN'
	Local aCamposAGE := {}
	Local oLayer := nil
	Local oTopGrid := nil
	Local aStruct := nil
	Local nMax := 0
	Local nStart := 0
	Local cCampo := ''
	Local aCols := {}
	Local aArrData := {}
	Local cCampo := ''
	Local oSayDtInicial := nil
	Local oPanel := nil
	Local oTopGrid2 := nil
	Local oFont := nil
	Local oSay1 := nil
	Local oSay2 := nil
	Local oTGet01 := nil
	Local oTGet02 := nil
	Local cDataInicial := nil
	Local cDataFinal := nil
	Local oTButtonAdd := nil
	Local oTButtonOK  := nil
	Local oTButtonEST := nil
	Local oTButtonCancel  := nil
	Local cConsulta  := ''
	Local cQuery := ''
	Local oTButtonSAIR := nil
	Local cAlias := getnextalias()
	Private dData := ctod('  /  /    ')
	Private cHora := '  :  '
	Private bLiberado := .F.
	
	cQuery := " select CONVERT(VARCHAR, dt_liberacao ,103) as data_dt_liberacao, CONVERT(VARCHAR, dt_liberacao ,108) as hora_dt_liberacao from tab_programacao where prog_id = " + alltrim(cProg_id)
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
   if alltrim((cAlias)->data_dt_liberacao) <> ''
   		dData := ctod(alltrim((cAlias)->data_dt_liberacao))
		cHora := substr(alltrim((cAlias)->hora_dt_liberacao),1,5)
   		bLiberado := .T.
   	else
   		dData := date()
		cHora := substr(time(),1,5)
		bLiberado := .F.
   endif
   
	
	//-------------------------------------------------------------------
	// Define a janela do Browse
	//-------------------------------------------------------------------
	DEFINE MSDIALOG oDlg Title STR0001 FROM 0,0 TO 175,320 PIXEL
	
	oLayer := FWLayer():new()
	oLayer:Init(oDlg,.F.)
	
	oLayer:addLine('LinhaSuperior',100,.F.,)
	
	oLayer:addColumn('ColSuperior',100,.F.,'LinhaSuperior')
	
	oLayer:addWindow('ColSuperior','C1_Win01',STR0002 + " " + cProg_ID  ,100,.F.,.F.,,'LinhaSuperior',)
	
	oTopGrid2   := oLayer:getwinpanel('ColSuperior','C1_Win01','LinhaSuperior')
	
	oFont := TFont():New('Arial',,15,.T.)	
	oSay1 := TSay():Create(oTopGrid2,{||STR0003},4 ,0,,oFont,,,,.T.,CLR_BLACK,CLR_RED,50,50)
	
	@ 2,20 MSGET oData VAR dData PICTURE "@D" SIZE 45, 10 OF oTopGrid2 PIXEL HASBUTTON

	
	oSay2 := TSay():Create(oTopGrid2,{||STR0004},25 ,0,,oFont,,,,.T.,CLR_BLACK,CLR_RED,50,50)
      
	@ 23,20 MSGET oData VAR cHora PICTURE "@E 99:99" SIZE 15, 10 OF oTopGrid2 PIXEL HASBUTTON
	
	oTButtonOK     := TButton():Create(  oLayer:getColPanel('ColSuperior','LinhaSuperior'),65,5,'Liberar'     ,{||A809OK()},40,10,,,,.T.,,,,{||WHEN_OK()},,)
	oTButtonEST    := TButton():Create(  oLayer:getColPanel('ColSuperior','LinhaSuperior'),65,55,'Estornar' ,{||A809EST()},40,10,,,,.T.,,,,{||WHEN_EST()},,)
	oTButtonSAIR    := TButton():Create(  oLayer:getColPanel('ColSuperior','LinhaSuperior'),65,105,'Sair'  ,{||A809SAIR()},40,10,,,,.T.,,,,,,)
	//oTButtonCancel := TButton():Create(  oLayer:getColPanel('ColSuperior','LinhaSuperior'),65,155,'Fechar'  ,{||A809CAN()},40,10,,,,.T.,,,,,,)
	
		

	ACTIVATE MSDIALOG oDlg CENTERED

Return

static function A809SAIR()
	lCancelou := .F.
	oDlg:end()
return

static function WHEN_EST()
	Local cQuery := ''
	Local cAlias := GetNextAlias()
	Local lResult := .F.
	
	/*
	cQuery := " select dt_liberacao from tab_programacao where prog_id = " + alltrim(cProg_id)
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

   if alltrim(dtoc((cAlias)->dt_liberacao)) <> ''
   		lResult := .T.
   endif
   */
return bLiberado

static function WHEN_OK()
	Local cQuery := ''
	Local cAlias := GetNextAlias()
	Local lResult := .F.
	/*
	cQuery := " select dt_liberacao from tab_programacao where prog_id = " + alltrim(cProg_id)
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
	
	if alltrim(dtoc((cAlias)->dt_liberacao)) = ''
   		lResult := .T.
   endif
   */
   if bLiberado = .F.
   		lResult := .T.
   else
   		lResult := .F.
   endif
return lResult

static function A809EST()
	Local cQuery := ''
	Local cHoraAlterado := ''
	Local cAlias := GetNextAlias()
	
	
	If Type("cViag_id") == "C" .And. !Empty(cViag_id)
			cQuery := " SELECT count(*) qtd, vf_id FROM TAB_programacao WHERE status = 1 and vf_id = '" + alltrim(cViag_ID) + "' group by vf_id"
			dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
			If (cAlias)->qtd > 1 .And. MsgYesNo("Deseja estornar todas as programações referente a viagem " + cViag_ID + "?")
				(cAlias)->(dbCloseArea())
				A809ESTBATCH()
				A809SAIR()
				Return
			Else
				(cAlias)->(dbCloseArea())	
			EndIf
			
		EndIf
	cQuery := " update tab_programacao set status = 0, dt_liberacao = null  where prog_id = " + alltrim(cProg_id)
	TCSqlexec(cQuery)
	
	
	cQuery := " update tab_programacao set eve_id = (select max(eve_id) from tab_programacao_eventos where prog_id = " + alltrim(cProg_id) + " ) where prog_id = " + alltrim(cProg_id)
	TCSqlexec(cQuery)
	
	cHora := '  :  '
	dData := ctod('  /  /    ')
	
	bLiberado := .F.
	
	MsgInfo("A programação foi estornada com sucesso.")
	A809SAIR()
	
return
/*
static function  A809CAN()
	lCancelou := .T.
	oDlg:end()
return
*/
static function A809OK()
	Local cQuery := ''
	Local cHoraAlterado := ''
	Local cAlias := GetNextAlias()
	
	cData := dtoc(dData)
	cHoraAlterado := strtran(substring(cHora,1,5),':','')
	
	if alltrim(cData) = '/  /'
		alert(STR0007)		
	elseif  alltrim(cHoraAlterado) = ':'
		alert(STR0008)
	elseif  len(alltrim(cHoraAlterado)) != 4 
		alert(STR0009)
	elseif (val(alltrim(cHoraAlterado)) > 2459)  .or. (val(alltrim(cHoraAlterado)) < 0)
		alert(STR0009)
	else
		If Type("cViag_id") == "C" .And. !Empty(cViag_id)
			cQuery := " SELECT count(*) qtd, vf_id FROM TAB_programacao WHERE (status = 0 or status is null) and vf_id = '" + alltrim(cViag_ID) + "' group by vf_id"
			dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
			If (cAlias)->qtd > 1 .And. MsgYesNo("Deseja liberar todas as programações referente a viagem " + cViag_ID + "?")
				(cAlias)->(dbCloseArea())
				A809OKBATCH()
				A809SAIR()
				Return
			Else
				(cAlias)->(dbCloseArea())	
			EndIf
			
		EndIf
		
		
		cQuery := " SELECT cesv_id FROM TAB_programacao WHERE prog_id = " + alltrim(cProg_ID)
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)	
		IF AllTrim((cAlias)->cesv_id) = ''
			
			cQuery := " update tab_programacao set status = 1, dt_liberacao = '" + SDBDate(dData,alltrim(cHora) )+ "' where prog_id = " + alltrim(cProg_id)
			TCSqlexec(cQuery)
			cHora := cHora
			dData := ctod(cData)
			bLiberado := .T.
			MsgInfo("A programação foi liberada com sucesso.")
			A809SAIR()
		else
			alert('Operação não permitida. Esta programação possui uma CESV.')	 
		endif
	EndIf
	
	
return

Function A809OKBATCH()
	Local cQuery := ''
	Local cAlias := GetNextAlias()
	Local cMsg	:= "Programações liberadas."
	Local nCont := 1
	
	cHora := cHora
	dData := ctod(cData)

	cQuery := " SELECT prog_id FROM TAB_programacao WHERE (status = 0 or status is null) and vf_id = '" + alltrim(cViag_ID) + "'"
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
	
	While !(cAlias)->(eof()) .And. !Empty((cAlias)->prog_id)
		cQuery := " update tab_programacao set status = 1, dt_liberacao = '" + SDBDate(dData,alltrim(cHora) )+ "' where prog_id = " + cValToChar((cAlias)->prog_id) + " and cesv_id is null"
		TCSqlexec(cQuery)
		(cAlias)->(dbskip())
	EndDo
	
	(cAlias)->(dbCloseArea())	
	cQuery := " SELECT prog_id FROM TAB_programacao WHERE (status = 0 or status is null) and vf_id = '" + alltrim(cViag_ID) + "'"
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
	IF !(cAlias)->(eof()) .And. !Empty((cAlias)->prog_id)
		cMsg += "Com exceção das abaixo: " + CRLF
		While !(cAlias)->(eof()) .And. !Empty((cAlias)->prog_id)
			If nCont > 1
				cMsg += ","
			EndIf
			cMsg += cValToChar((cAlias)->prog_id)
			nCont++
			(cAlias)->(dbskip())
		EndDo
		MsgAlert(cMsg)
	Else
		MsgInfo(cMsg)
	EndIf
	(cAlias)->(dbCloseArea())
Return

Function A809ESTBATCH()
	Local cQuery
	Local cAlias := GetNextAlias()
	Local cMsg	:= "Programações estornadas."
	
	cQuery := " SELECT prog_id FROM TAB_programacao WHERE status = 1 and vf_id = '" + alltrim(cViag_ID) + "'"
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
	
	While !(cAlias)->(eof()) .And. !Empty((cAlias)->prog_id)

		cQuery := " update tab_programacao set status = 0, dt_liberacao = null  where prog_id = " + cValToChar((cAlias)->prog_id)
		TCSqlexec(cQuery)
		
		cQuery := " update tab_programacao set eve_id = (select max(eve_id) from tab_programacao_eventos where prog_id = " + cValToChar((cAlias)->prog_id) + " ) where prog_id = " + cValToChar((cAlias)->prog_id)
		TCSqlexec(cQuery)
		
		(cAlias)->(dbskip())
	EndDo
	
	cHora := '  :  '
	dData := ctod('  /  /    ')
	(cAlias)->(dbCloseArea())
	MsgInfo(cMsg)
Return
